public with sharing class CBS_AirplaneController {

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

        System.debug('name ' + airplaneName);
        System.debug('seats ' + airplaneNumberOfSeats);
        System.debug('engines ' + airplaneEnginesNumber);

        System.debug('Query = ' + query);
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
    }

    public class AirplaneWrapper {
        @AuraEnabled public Product2 airplane;
        @AuraEnabled public Attachment mainPicture;
    }

    @AuraEnabled
    public static List<Attachment> getAttachments(String recordId) {
        return [SELECT Id FROM Attachment WHERE ParentId = :recordId];
    }
}