trigger CBS_AirplaneTypePriceUpdated on Airplane_Type__c (after insert, after update) {
    Double discountPrice = Trigger.new[0].Price_after_Discount__c;

    System.debug('Discount price = ' + discountPrice);

    List<Product2> airplanes = [SELECT Id, Name FROM Product2 WHERE Airplane_Type__c = :Trigger.new[0].Id];

    System.debug('airplanes size = ' + airplanes.size());

    PriceBook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

    //List<PricebookEntry> pricebookEntries = [SELECT Id, UnitPrice]
}