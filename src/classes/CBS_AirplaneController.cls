public without sharing class CBS_AirplaneController {
    @AuraEnabled
    public static List<AirplaneWrapper> searchAirplanes(Airplane_Type__c searchedAirplane) {
        String airplaneName = searchedAirplane.Name;
        Decimal airplaneNumberOfSeats = searchedAirplane.Number_of_Seats__c;

        Boolean hasFirstParam = true;
        String query = 'SELECT Id, Name, Number_of_Seats__c, Engines_Number__c, Engine__c, Length__c, Weight__c, Wingspan__c, Price__c, Discount__c, Price_after_Discount__c FROM Airplane_Type__c WHERE Name LIKE ' + CBS_Util.transformStringToLikeQuery(searchedAirplane.Name);

        if (airplaneNumberOfSeats != null && airplaneNumberOfSeats != 0) {
            query += ' AND Number_of_Seats__c >= ' + airplaneNumberOfSeats;
        }


        query += ' ORDER BY Id';

        try {
            List<Airplane_Type__c> fetchedAirplanes = Database.query(query);

            List<String> fetchedIds = new List<String>();
            for (Airplane_Type__c airplane : fetchedAirplanes) {
                fetchedIds.add(airplane.Id);
            }

            List<Attachment> fetchedAttachments = [SELECT Id, Name, ParentId FROM Attachment WHERE Name = 'main' AND ParentId IN :fetchedIds ORDER BY ParentId];

//            List<PricebookEntry> standardPrices = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Product2.Airplane_Type__c IN :fetchedIds];
//
//            List<PricebookEntry> promotions = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Product2.Airplane_Type__c IN :fetchedIds AND Pricebook2.Promotion_start__c <= :System.today() AND Pricebook2.Promotion_end__c >= :System.today()];


            List<AirplaneWrapper> airplaneWrappers = new List<CBS_AirplaneController.AirplaneWrapper>();
            for (Integer i = 0; i < fetchedAirplanes.size(); i++) {
                AirplaneWrapper aWrapper = new AirplaneWrapper();
                aWrapper.airplane = fetchedAirplanes.get(i);
                if (fetchedAirplanes.get(i).Id == fetchedAttachments.get(i).ParentId) {
                    aWrapper.mainPicture = fetchedAttachments.get(i);
                }
                airplaneWrappers.add(aWrapper);
            }

            return airplaneWrappers;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static List<AirplaneWrapper> getNewestAirplanes() {
        try {
            List<Airplane_Type__c> newestAirplanes = [SELECT Id, Name, Number_of_Seats__c, Engines_Number__c, Engine__c, Length__c, Weight__c, Wingspan__c, Price__c, Discount__c, Price_after_Discount__c FROM Airplane_Type__c ORDER BY CreatedDate DESC LIMIT 4];
            List<AirplaneWrapper> airplaneWrappers = new List<CBS_AirplaneController.AirplaneWrapper>();

            List<String> typeIds = new List<String>();
            for (Airplane_Type__c airplane : newestAirplanes) {
                typeIds.add(airplane.Id);
            }

            List<PricebookEntry> standardPrices = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Product2.Airplane_Type__c IN :typeIds];

            //List<PricebookEntry> promotions = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Product2.Airplane_Type__c IN :typeIds AND Pricebook2.Promotion_start__c <= :System.today() AND Pricebook2.Promotion_end__c >= :System.today()];


            List<String> promotionsList = new List<String>();
            for (Airplane_Type__c tAirplane : newestAirplanes) {
                AirplaneWrapper aw = new AirplaneWrapper();
                aw.airplane = tAirplane;
                aw.mainPicture = [SELECT Id, Name, ParentId FROM Attachment WHERE Name = 'main' AND ParentId = :tAirplane.Id];
                Decimal lowestPrice = 999999999;
                Decimal highestPrice = 0;
                List<Decimal> lowestPrices = new List<Decimal>();

                List<Product2> airplanes = [SELECT Id FROM Product2 WHERE Airplane_Type__c = :tAirplane.Id];

                List<PricebookEntry> promotions = new List<PricebookEntry>();
                for (Product2 plane : airplanes) {
                    List<PricebookEntry> promEntry = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Product2Id = :plane.Id AND Pricebook2.Promotion_start__c <= :System.today() AND Pricebook2.Promotion_end__c >= :System.today() ORDER BY UnitPrice LIMIT 1];
                    if (promEntry != null && promEntry.size() > 0) {
                        promotions.add(promEntry[0]);
                    }
                }







                for (PricebookEntry prom : promotions) {
                    if (prom.Product2.Airplane_Type__c == tAirplane.Id) {
                        if (prom.UnitPrice < lowestPrice) {
                            lowestPrice = prom.UnitPrice;
                        }

                        if (prom.UnitPrice > highestPrice) {
                            highestPrice = prom.UnitPrice;
                        }

                        promotionsList.add(prom.Product2Id);
                    }
                }

                //lowestPrices.add(lowestPrice);

//                for (Decimal price : lowestPrices) {
//                    if (price > highestPrice) {
//                        highestPrice = price;
//                    }
//                }

                for (PricebookEntry pbe : standardPrices) {
                    if (pbe.Product2.Airplane_Type__c == tAirplane.Id) {
                        if (pbe.UnitPrice < lowestPrice) {
                            lowestPrice = pbe.UnitPrice;
                        }

                        if (pbe.UnitPrice > highestPrice) {
                            Boolean isOk = true;
                            for (String str : promotionsList) {
                                if (pbe.Product2Id == str) {
                                    isOk = false;
                                }
                            }
                            if (isOk) {
                                highestPrice = pbe.UnitPrice;
                            }
                        }
                    }
                }

                aw.lowestPrice = lowestPrice;
                aw.highestPrice = highestPrice;

                airplaneWrappers.add(aw);
            }

            return airplaneWrappers;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class AirplaneWrapper {
        @AuraEnabled public Airplane_Type__c airplane;
        @AuraEnabled public Attachment mainPicture;
        @AuraEnabled public PricebookEntry promotion;
        @AuraEnabled public PricebookEntry standardPrice;
        @AuraEnabled public Decimal lowestPrice;
        @AuraEnabled public Decimal highestPrice;
    }

    @AuraEnabled
    public static List<Attachment> getAttachments(String recordId) {
        try {
            return [SELECT Id FROM Attachment WHERE ParentId = :recordId];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static AttachmentsWrapper getAttachmentWrappers(String recordId) {
        AttachmentsWrapper aWrapper = new AttachmentsWrapper();
        try {
            List<Attachment> atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
            if (!atts.isEmpty()) {
                aWrapper.mainPicture = atts.get(0);
            } else {
                aWrapper.mainPicture = null;
            }
            aWrapper.attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name != 'main'];

            return aWrapper;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class AttachmentsWrapper {
        @AuraEnabled public Attachment mainPicture;
        @AuraEnabled public List<Attachment> attachments;
    }

    @AuraEnabled
    public static String saveAirplane(Airplane_Type__c theAirplane, Attachment mainPictureAtt, String recordId, List<Attachment> attachmentsToDelete, List<String> picturesToUpload, String pictureMain) {
        try {
            upsert theAirplane;
            saveAttachments(mainPictureAtt, theAirplane.Id, attachmentsToDelete, picturesToUpload, pictureMain);
            return theAirplane.Id;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    private static void saveAttachments(Attachment mainPictureAtt, String recordId, List<Attachment> attachmentsToDelete, List<String> picturesToUpload, String pictureMain) {
        List<Attachment> att = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
        if (!att.isEmpty()) {
            att[0].Name = 'attachment';
            update att;
        }

        List<Attachment> pictureAttachments = new List<Attachment>();
        for (String picture : picturesToUpload) {
            Attachment picAttachment = new Attachment();
            picAttachment.ParentId = String.valueOf(recordId);
            picAttachment.Body = EncodingUtil.base64Decode(picture.substring(picture.indexOf(',') + 1));
            picAttachment.Name = 'picAttachment';
            pictureAttachments.add(picAttachment);
        }

        upsert pictureAttachments;

        if (!attachmentsToDelete.isEmpty()) {
            delete attachmentsToDelete;
        }

        if (mainPictureAtt == null) {
            Attachment mainPicAttachment = new Attachment();
            mainPicAttachment.ParentId = String.valueOf(recordId);
            mainPicAttachment.Body = EncodingUtil.base64Decode(pictureMain.substring(pictureMain.indexOf(',') + 1));
            mainPicAttachment.Name = 'main';
            upsert mainPicAttachment;
        } else {
            Attachment toBeMain = [SELECT Id, Name FROM Attachment WHERE Id = :mainPictureAtt.Id];
            toBeMain.Name = 'main';
            update toBeMain;
        }
    }

    @AuraEnabled
    public static List<Airplane_Type__c> getAllAirplanes() {
        try {
            return [SELECT Id, Name, Engine__c, Engines_Number__c, Length__c, Number_of_Seats__c, Weight__c, Wingspan__c, Price__c, Discount__c, Price_after_Discount__c FROM Airplane_Type__c];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static void deleteAirplane(String airplaneId) {
        try {
            Product2 airplaneToDelete = [SELECT Id FROM Product2 WHERE Id = :airplaneId LIMIT 1];
            delete airplaneToDelete;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static Airplane_Type__c getAirplaneType(String airplaneId) {
        try {
            return [SELECT Id, Name, Number_of_Seats__c, Engine__c, Engines_Number__c, Price__c, Discount__c, Price_after_Discount__c FROM Airplane_Type__c WHERE Id = :airplaneId];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static List<CBS_Hangar__c> getHangars() {
        try {
            return [SELECT Id, Name, City__c, Country__c FROM CBS_Hangar__c];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }
}