public with sharing class CBS_AirplaneCreatePromotionsController {
    @AuraEnabled
    public static List<AirplaneWrapper> getAirplanesWithPromotions() {
        List<Product2> planes = [SELECT Id, Name, Hangar__c, Hangar__r.Name, Airplane_Type__c FROM Product2 ORDER BY Name];
        List<String> planeIds = new List<String>();
        for (Product2 plane : planes) {
            planeIds.add(plane.Id);
        }

        List<PricebookEntry> entries = [SELECT Product2Id, UnitPrice, Pricebook2.IsStandard, Pricebook2.Promotion_start__c, Pricebook2.Promotion_end__c, CreatedBy.Name FROM PricebookEntry WHERE Product2Id IN :planeIds ORDER BY Pricebook2.Promotion_start__c];
        Map<String, List<PricebookEntry>> mapPlanePricebookEntries = new Map<String, List<PricebookEntry>>();

        for (PricebookEntry entry : entries) {
            List<PricebookEntry> pBEntries = mapPlanePricebookEntries.get(entry.Product2Id);
            if (pBEntries == null) {
                pBEntries = new List<PricebookEntry>();
            }
            pBEntries.add(entry);
            mapPlanePricebookEntries.put(entry.Product2Id, pBEntries);
        }

        List<AirplaneWrapper> airplaneWrappers = new List<CBS_AirplaneCreatePromotionsController.AirplaneWrapper>();
        for (Product2 plane : planes) {
            Boolean hasPromotion = false;
            AirplaneWrapper aW = new CBS_AirplaneCreatePromotionsController.AirplaneWrapper();
            PricebookEntry currentPromotion = new PricebookEntry();
            currentPromotion.UnitPrice = 999999999;
            aW.airplane = plane;
            List<PricebookEntry> promotionPricebookEntries = new List<PricebookEntry>();
            for (PricebookEntry pBE : mapPlanePricebookEntries.get(plane.Id)) {
                if (pBE.Pricebook2.IsStandard) {
                    aW.standardPrice = (Integer) pBE.UnitPrice;
                } else if (pBE.Pricebook2.Promotion_start__c <= System.today() && pBE.Pricebook2.Promotion_end__c >= System.today() && pBE.UnitPrice < currentPromotion.UnitPrice) {
                    currentPromotion = pBE;
                    hasPromotion = true;
                    promotionPricebookEntries.add(pBE);
                } else {
                    promotionPricebookEntries.add(pBE);
                }
                aW.priceAfterDiscount = (Integer) pBE.UnitPrice;
            }

            aW.pBEntries = promotionPricebookEntries;

            if (hasPromotion) {
                aW.currentPricePromotion = currentPromotion;
            }
            airplaneWrappers.add(aW);
        }

        return airplaneWrappers;
    }

    @AuraEnabled
    public static void createPromotion(String planeId, Decimal pPrice, String pSDate, String pEDate) {
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = pPrice + '_' + '_' + pEDate + System.now();
        pricebook.IsActive = true;
        pricebook.Promotion_start__c = Date.valueOf(pSDate);
        pricebook.Promotion_end__c = Date.valueOf(pEDate);

        try {
            insert pricebook;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }

        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = planeId;
        entry.IsActive = true;
        entry.UnitPrice = pPrice;
        entry.Pricebook2Id = pricebook.Id;

        try {
            insert entry;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class AirplaneWrapper {
        @AuraEnabled
        public Product2 airplane;
        @AuraEnabled
        public List<PricebookEntry> pBEntries;
        @AuraEnabled
        public PricebookEntry currentPricePromotion;
        @AuraEnabled
        public Integer discount;
        @AuraEnabled
        public Integer priceAfterDiscount;
        @AuraEnabled
        public Integer standardPrice;
    }

    @AuraEnabled
    public static void createPromotionForAll(String airplaneWrappersString, Integer discountPercent, String startDate, String endDate) {
        Date tStartDate = Date.valueOf(startDate);
        Date tEndDate = Date.valueOf(endDate);

        List<Pricebook2> pricebooks = new List<Pricebook2>();
        List<PricebookEntry> entries = new List<PricebookEntry>();

        List<AirplaneWrapper> airplaneWrappers = (List<AirplaneWrapper>) JSON.deserialize(airplaneWrappersString, List<AirplaneWrapper>.class);

        Map<Integer, Pricebook2> pricebookMap = new Map<Integer, Pricebook2>();
        Map<Integer, PricebookEntry> pricebookEntryMap = new Map<Integer, PricebookEntry>();

        for (Integer i = 0; i < airplaneWrappers.size(); i++) {
            Decimal discountPrice = (Decimal) airplaneWrappers[i].standardPrice - ((Decimal) airplaneWrappers[i].standardPrice * discountPercent / 100);
            Pricebook2 pb = new Pricebook2();
            pb.Name = airplaneWrappers[i].airplane.Name + ' ' + discountPrice + ' ' + tEndDate + ' ' + System.now();
            pb.IsActive = true;
            pb.Promotion_start__c = tStartDate;
            pb.Promotion_end__c = tEndDate;
            pricebooks.add(pb);
            pricebookMap.put(i, pb);
            PricebookEntry entry = new PricebookEntry();
            entry.Product2Id = airplaneWrappers[i].airplane.Id;
            entry.IsActive = true;
            entry.UnitPrice = discountPrice;
            entries.add(entry);
            pricebookEntryMap.put(i, entry);
        }

        try {
            insert pricebooks;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }

        for (Integer i = 0; i < airplaneWrappers.size(); i++) {
            Pricebook2 pb = pricebookMap.get(i);
            PricebookEntry entry = pricebookEntryMap.get(i);
            entry.Pricebook2Id = pb.Id;
        }

        try {
            insert entries;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static void deletePBPromotions(List<String> pbsToDelete) {
        List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE Id IN :pbsToDelete];

        try {
            delete pricebooks;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }
}