trigger CBS_AirplaneOpportunityEvent on Event (after insert) {
    List<String> eventIds = new List<String>();
    for (Event evt : Trigger.new) {
        eventIds.add(evt.Id);
    }

    List<Event> updEvts = [SELECT Id, Airplane_Type__r.Name, WhatId FROM Event WHERE Id IN :eventIds ORDER BY ActivityDateTime];
    Contact con = [SELECT Id, Name, Account.Name, AccountId FROM Contact WHERE Id = :Trigger.new[0].WhoId];


    Opportunity opp = new Opportunity();
    opp.CloseDate = Date.today().addYears(1);
    String oppName = '';




    oppName = oppName.removeEnd(', ');
    opp.Name = oppName;
    opp.StageName = 'Prospecting';
    opp.AccountId = con.AccountId;



    List<String> airplaneIds = new List<String>();

    for (Event evt : updEvts) {
        oppName += evt.Airplane_Type__r.Name + ', ';
        airplaneIds.add(evt.WhatId);
    }

    List<PricebookEntry> standardPricebookEntries = [SELECT Id, UnitPrice, Product2.Name, Product2Id FROM PricebookEntry WHERE Pricebook2.IsStandard = true];
    List<PricebookEntry> promotionEntries = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Product2Id = :airplaneIds AND Pricebook2.Promotion_start__c <= :System.today()
    AND Pricebook2.Promotion_end__c >= :System.today() ORDER BY UnitPrice LIMIT 1];


    Map<String, Decimal> airplanePrices = new Map<String, Decimal>();


    for (PricebookEntry standardPricebookEntry : standardPricebookEntries) {
        airplanePrices.put(standardPricebookEntry.Product2Id, standardPricebookEntry.UnitPrice);
    }

    for (PricebookEntry promotionEntry : promotionEntries) {
        airplanePrices.put(promotionEntry.Product2Id, promotionEntry.UnitPrice);
    }



    Pricebook2 opportunityPricebook = new Pricebook2();
    opportunityPricebook.Name = 'Opportunity Pricebook: ' + System.now();
    opportunityPricebook.IsActive = true;

    insert opportunityPricebook;

    List<PricebookEntry> entries = new List<PricebookEntry>();
    for (Event evt : updEvts) {
        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = evt.WhatId;
        entry.IsActive = true;
        entry.UnitPrice = airplanePrices.get(evt.WhatId);
        entry.Pricebook2Id = opportunityPricebook.Id;
        entries.add(entry);
    }

    insert entries;










//    entry.Product2Id = planeId;
//    entry.IsActive = true;
//    System.debug('pPrice = ' + pPrice);
//    Decimal pPrice2 = Decimal.valueOf(String.valueOf(Integer.valueOf(pPrice))).setScale(2, System.RoundingMode.HALF_UP);
//    System.debug('pPrice2 = ' + pPrice2);
//    entry.UnitPrice = pPrice2;
//    entry.Pricebook2Id = pricebook.Id;





    //Map<String, Map<Decimal, Integer>> pricebookEntries = new Map<String, Map<Decimal, Integer>>();

//    for (Event evt : updEvts) {
//        Integer quantity = 1;
//        Map<Decimal, Integer> pMap = pricebookEntries.get(evt.WhatId);
//        if (pMap != null) {
//            Integer quantity = pMap;
//        } else {
//            pMap.put(airplanePrices.get(evt.WhatId), 1);
//        }
//
//        Map<Decimal, Integer> utilMap = new Map<Decimal, Integer>();
//
//        pricebookEntries.put(evt.WhatId, utilMap);
//
//    }



    opp.Pricebook2Id = opportunityPricebook.Id;
    insert opp;

    List<OpportunityLineItem> opportunityItems = new List<OpportunityLineItem>();

    for (PricebookEntry entry : entries) {
        OpportunityLineItem opportunityItem = new OpportunityLineItem();
        opportunityItem.OpportunityId = opp.Id;
        opportunityItem.PricebookEntryId = entry.Id;
        opportunityItem.Quantity = 1;
        opportunityItem.UnitPrice = entry.UnitPrice;
        opportunityItems.add(opportunityItem);
    }

    insert opportunityItems;

    for (Event evt : updEvts) {
        evt.WhatId = opp.Id;
    }






//    entry.Product2Id = planeId;
//    entry.IsActive = true;
//    System.debug('pPrice = ' + pPrice);
//    Decimal pPrice2 = Decimal.valueOf(String.valueOf(Integer.valueOf(pPrice))).setScale(2, System.RoundingMode.HALF_UP);
//    System.debug('pPrice2 = ' + pPrice2);
//    entry.UnitPrice = pPrice2;
//    entry.Pricebook2Id = pricebook.Id;








//    Pricebook2 pricebook = new Pricebook2();
//    pricebook.Name = pPrice + '_' +  '_' + pEDate + System.now();
//    pricebook.IsActive = true;







    update updEvts;
}