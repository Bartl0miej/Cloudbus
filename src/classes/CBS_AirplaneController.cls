public without sharing class CBS_AirplaneController {
    @AuraEnabled
    public static List<AirplaneWrapper> searchAirplanes(Product2 searchedAirplane) {
        String airplaneName = searchedAirplane.Name;
        Decimal airplaneNumberOfSeats = searchedAirplane.Number_of_Seats__c;
        Decimal airplaneEnginesNumber = searchedAirplane.Engines_Number__c;

        Boolean hasFirstParam = false;
        String query = 'SELECT Id, Name, Number_of_Seats__c, Engines_Number__c, Engine__c, Length__c, Weight__c, Wingspan__c FROM Product2 WHERE ';

        if (String.isNotEmpty(airplaneName)) {
            if (!hasFirstParam) {
                query += ' Name LIKE \'%' + airplaneName + '%\'';
            } else {
                query += ' AND Name LIKE \'%' + airplaneName + '%\'';
            }
        }

        if (airplaneNumberOfSeats != null && airplaneNumberOfSeats != 0) {
            if (!hasFirstParam) {
                query += ' Number_of_Seats__c >= ' + airplaneNumberOfSeats;
            } else {
                query += ' AND Number_of_Seats__c >= ' + airplaneNumberOfSeats;
            }
        }

        if (airplaneEnginesNumber != null && airplaneEnginesNumber != 0) {
            if (!hasFirstParam) {
                query += ' Engines_Number__c >= ' + airplaneEnginesNumber;
            } else {
                query += ' AND Engines_Number__c >= ' + airplaneEnginesNumber;
            }
        }

        query += ' ORDER BY Id';

        try {
            List<Product2> fetchedAirplanes = Database.query(query);

            List<String> fetchedIds = new List<String>();
            for (Product2 airplane : fetchedAirplanes) {
                fetchedIds.add(airplane.Id);
            }

            List<Attachment> fetchedAttachments = [SELECT Id, Name, ParentId FROM Attachment WHERE Name = 'main' AND ParentId IN :fetchedIds ORDER BY ParentId];

            List<AirplaneWrapper> airplaneWrappers = new List<CBS_AirplaneController.AirplaneWrapper>();
            for (Integer i = 0; i < fetchedAirplanes.size(); i++) {
                AirplaneWrapper aWrapper = new AirplaneWrapper();
                aWrapper.airplane = fetchedAirplanes.get(i);
                aWrapper.mainPicture = fetchedAttachments.get(i);
                airplaneWrappers.add(aWrapper);
            }

            return airplaneWrappers;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static List<Product2> getNewestAirplanes() {
        try {
            return [SELECT Id, Name, Number_of_Seats__c, Engines_Number__c, Engine__c, Length__c, Weight__c, Wingspan__c FROM Product2 ORDER BY CreatedDate LIMIT 6];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class AirplaneWrapper {
        @AuraEnabled public Product2 airplane;
        @AuraEnabled public Attachment mainPicture;
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
    public static String saveAirplane (Product2 theAirplane, Attachment mainPictureAtt, String recordId, List<Attachment> attachmentsToDelete, List<String> picturesToUpload, String pictureMain) {
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
    public static List<Product2> getAllAirplanes() {
        try {
            return [SELECT Id, Name, Engine__c, Engines_Number__c, Length__c, Number_of_Seats__c, Weight__c, Wingspan__c FROM Product2];
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
    public static Product2 getAirplane(String airplaneId) {
        try {
            return [SELECT Id, Name, Number_of_Seats__c, Engine__c, Engines_Number__c FROM Product2 WHERE Id = :airplaneId];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }
}