trigger CBS_AirplaneOpportunityEvent on Event (after insert) {
    List<String> eventIds = new List<String>();
    for (Event evt : Trigger.new) {
        eventIds.add(evt.Id);
    }

    List<Event> updEvts = [SELECT Id, Airplane_Type__r.Name, WhatId FROM Event WHERE Id IN :eventIds ORDER BY ActivityDateTime];
    Contact con = [SELECT Id, Name, Account.Name, AccountId FROM Contact WHERE Id = :Trigger.new[0].WhoId];

    Opportunity opp = new Opportunity();
    opp.CloseDate = Date.today().addYears(1);
    opp.Name = Label.CBS_Airplanes_for + ' ' + con.Account.Name;
    opp.StageName = 'Prospecting';
    opp.AccountId = con.AccountId;

    List<String> airplaneIds = new List<String>();
    for (Event evt : updEvts) {
        airplaneIds.add(evt.WhatId);
    }

    List<PricebookEntry> standardPricebookEntries = [SELECT Id, UnitPrice, Product2.Name, Product2Id FROM PricebookEntry WHERE Pricebook2.IsStandard = true];
    List<PricebookEntry> promotionEntries = [SELECT Id, UnitPrice, Product2Id, Product2.Airplane_Type__c FROM PricebookEntry WHERE Product2Id IN :airplaneIds AND Pricebook2.Promotion_start__c <= :System.today()
    AND Pricebook2.Promotion_end__c >= :System.today()];

    Map<String, PricebookEntry> airplanePrices = new Map<String, PricebookEntry>();

    for (PricebookEntry standardPricebookEntry : standardPricebookEntries) {
        airplanePrices.put(standardPricebookEntry.Product2Id, standardPricebookEntry);
    }

    for (PricebookEntry promotionEntry : promotionEntries) {
        PricebookEntry entry = airplanePrices.get(promotionEntry.Product2Id);
        if (entry.UnitPrice > promotionEntry.UnitPrice) {
            airplanePrices.put(promotionEntry.Product2Id, promotionEntry);
        }
    }



    Pricebook2 opportunityPricebook = new Pricebook2();
    opportunityPricebook.Name = 'Opportunity Pricebook: ' + System.now();
    opportunityPricebook.IsActive = true;

    insert opportunityPricebook;

    List<PricebookEntry> entries = new List<PricebookEntry>();
    Set<String> airplaneIdsSet = new Set<String>();
    for (Event evt : updEvts) {
        if (airplaneIdsSet.contains(evt.WhatId)) {
            continue;
        }
        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = evt.WhatId;
        entry.IsActive = true;
        entry.UnitPrice = airplanePrices.get(evt.WhatId).UnitPrice;
        entry.Pricebook2Id = opportunityPricebook.Id;
        airplaneIdsSet.add(evt.WhatId);
        entries.add(entry);
    }

    insert entries;

    opp.Pricebook2Id = opportunityPricebook.Id;
    insert opp;

    List<OpportunityLineItem> opportunityItems = new List<OpportunityLineItem>();

    airplaneIdsSet = new Set<String>();
    for (PricebookEntry entry : entries) {
        if (airplaneIdsSet.contains(entry.Product2Id)) {
            continue;
        }
        OpportunityLineItem opportunityItem = new OpportunityLineItem();
        opportunityItem.OpportunityId = opp.Id;
        opportunityItem.PricebookEntryId = entry.Id;
        opportunityItem.Quantity = 1;
        opportunityItem.UnitPrice = entry.UnitPrice;
        airplaneIdsSet.add(entry.Product2Id);
        opportunityItems.add(opportunityItem);
    }

    insert opportunityItems;

    for (Event evt : updEvts) {
        evt.WhatId = opp.Id;
    }
}