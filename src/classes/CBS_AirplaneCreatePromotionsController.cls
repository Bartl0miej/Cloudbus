public with sharing class CBS_AirplaneCreatePromotionsController {
    @AuraEnabled
    public static List<AirplaneWrapper> getAirplanes() {
        List<Product2> planes = [SELECT Id, Name, Hangar__c, Hangar__r.Name, Airplane_Type__c FROM Product2 ORDER BY Name];
        List<String> planeIds = new List<String>();
        for (Product2 plane : planes) {
            planeIds.add(plane.Id);
        }

        List<PricebookEntry> entries = [SELECT Product2Id, UnitPrice, Pricebook2.IsStandard, Pricebook2.Promotion_start__c, Pricebook2.Promotion_end__c, CreatedBy.Name FROM PricebookEntry WHERE Product2Id IN :planeIds ORDER BY Pricebook2.Promotion_start__c];

        for (PricebookEntry entry : entries) {
            System.debug('Product2Id = ' + entry.Product2Id + ', price: ' + entry.UnitPrice);
        }

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        List<AirplaneWrapper> airplaneWrappers = new List<CBS_AirplaneCreatePromotionsController.AirplaneWrapper>();
        for (Product2 plane : planes) {
            pricebookEntries = new List<PricebookEntry>();
            Boolean hasPromotion = false;
            AirplaneWrapper aW = new CBS_AirplaneCreatePromotionsController.AirplaneWrapper();
            PricebookEntry currentPromotion = new PricebookEntry();
            currentPromotion.UnitPrice = 999999999;
            for (PricebookEntry entry : entries) {
                if (plane.Id == entry.Product2Id) {
                    aW.airplane = plane;
                    //System.debug('Pricebook entry: ' + (entry.Pricebook2__r.Promotion_start__c) + (entry.Pricebook2__r.Promotion_end__c) + (entry.UnitPrice < currentPromotion.UnitPrice));
                    if (entry.Pricebook2.IsStandard) {
                        aW.standardPrice = (Integer)entry.UnitPrice;
                    } else if (entry.Pricebook2.Promotion_start__c <= System.today() && entry.Pricebook2.Promotion_end__c >= System.today() && entry.UnitPrice < currentPromotion.UnitPrice) {
                        currentPromotion = entry;
                        hasPromotion = true;
                        pricebookEntries.add(entry);
                    } else {
                        pricebookEntries.add(entry);
                    }
                    aW.priceAfterDiscount = (Integer)entry.UnitPrice;
                }
            }
            aW.pBEntries = pricebookEntries;
            if (hasPromotion) {
                aW.currentPricePromotion = currentPromotion;
            }
            airplaneWrappers.add(aW);
            System.debug('-------------------------');
        }


        return airplaneWrappers;
    }

    @AuraEnabled
    public static void createPromotion(String planeId, Integer pPrice, String pSDate, String pEDate) {
        System.debug('Promotion start date = ' + pSDate);
        System.debug('Promotion end date = ' + pEDate);

        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = pPrice + '_' +  '_' + pEDate + System.now();
        pricebook.IsActive = true;
        pricebook.Promotion_start__c = Date.valueOf(pSDate);
        pricebook.Promotion_end__c = Date.valueOf(pEDate);

        insert pricebook;

        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = planeId;
        entry.IsActive = true;
        System.debug('pPrice = ' + pPrice);
        Decimal pPrice2 = Decimal.valueOf(String.valueOf(Integer.valueOf(pPrice))).setScale(2, System.RoundingMode.HALF_UP);
        System.debug('pPrice2 = ' + pPrice2);
        entry.UnitPrice = pPrice2;
        entry.Pricebook2Id = pricebook.Id;

        insert entry;
    }

    public class AirplaneWrapper {
        @AuraEnabled public Product2 airplane;
        @AuraEnabled public List<PricebookEntry> pBEntries;
        @AuraEnabled public PricebookEntry currentPricePromotion;
        @AuraEnabled public Integer discount;
        @AuraEnabled public Integer priceAfterDiscount;
        @AuraEnabled public Integer standardPrice;
    }

    @AuraEnabled
    public static void createPromotionForAll(String airplaneWrappersString, Integer discountPercent, String startDate, String endDate) {
        Date tStartDate = Date.valueOf(startDate);
        Date tEndDate = Date.valueOf(endDate);
        System.debug('Discount percent = ' + discountPercent);
        System.debug('start date = ' + tStartDate);
        System.debug('end date = ' + tEndDate);

        List<Pricebook2> pricebooks = new List<Pricebook2>();
        List<PricebookEntry> entries = new List<PricebookEntry>();

        List<AirplaneWrapper> airplaneWrappers = (List<AirplaneWrapper>)JSON.deserialize(airplaneWrappersString, List<AirplaneWrapper>.class);

        Map<Integer, Pricebook2> pricebookMap = new Map<Integer, Pricebook2>();
        Map<Integer, PricebookEntry> pricebookEntryMap = new Map<Integer, PricebookEntry>();


        for (Integer i = 0; i < airplaneWrappers.size(); i++) {
            Decimal discountPrice = (Decimal)airplaneWrappers[i].standardPrice - ((Decimal)airplaneWrappers[i].standardPrice * discountPercent / 100);
            Pricebook2 pb = new Pricebook2();
            pb.Name = airplaneWrappers[i].airplane.Name + ' ' +  discountPrice + ' ' + tEndDate + ' ' + System.now();
            //pb.Name = 'todelete' + i;
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

        insert pricebooks;

        for (Integer i = 0; i < airplaneWrappers.size(); i++) {
            Pricebook2 pb = pricebookMap.get(i);
            PricebookEntry entry = pricebookEntryMap.get(i);
            entry.Pricebook2Id = pb.Id;
        }

        insert entries;
    }

    @AuraEnabled
    public static void deletePBPromotions(List<String> pbsToDelete) {
        List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE Id IN :pbsToDelete];
        System.debug('pricebooks.size' + pricebooks.size());

        delete pricebooks;
    }

}






