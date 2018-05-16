public class FCC_ShopRandomController {
    public ApexPages.StandardController controller;
    private final Integer RECORDS_ON_PAGE = 5;

    public FCC_ShopRandomController(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public List<FCC_Shop__c> getRandomShops() {
        Integer recordsCount = [SELECT COUNT() FROM FCC_Shop__c];
        Integer randomOffset = (Integer) (Math.random() * (recordsCount - RECORDS_ON_PAGE));

        return [SELECT Name, Country__c, City__c FROM FCC_Shop__c LIMIT :RECORDS_ON_PAGE OFFSET :randomOffset];
    }
}