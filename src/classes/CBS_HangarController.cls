public with sharing class CBS_HangarController {
    @AuraEnabled
    public static List<CBS_Hangar__c> searchHangars(CBS_Hangar__c searchedHangar) {
        String nameParam, emailParam, cityParam;
        String query = 'SELECT Id, Name, Country__c, City__c FROM CBS_Hangar__c WHERE Country__c = \'' + searchedHangar.Country__c + '\'';

        if (String.isNotEmpty(searchedHangar.Name)) {
            nameParam = ' \'%' + searchedHangar.Name + '%\' ';
            query += ' AND Name LIKE ' + nameParam;
        }

        if (String.isNotEmpty(searchedHangar.City__c)) {
            cityParam = ' \'%' + searchedHangar.City__c + '%\' ';
            query += ' AND Name LIKE ' + cityParam;
        }

        System.debug('QUERY: ' + query);

        System.debug(Database.query(query));
        return Database.query(query);
    }
}