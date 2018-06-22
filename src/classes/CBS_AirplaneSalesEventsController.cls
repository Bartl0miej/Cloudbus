public with sharing class CBS_AirplaneSalesEventsController {
    @AuraEnabled
    public static UsersContactsWrapper getSalesRepresentativesAndContacts() {
        Integer eventsPerPage = Integer.valueOf(CBS_Util.getCustomSettingValue('SalesRepresentativeEventsPerPage'));

        List<User> salesReps = new List<User>();
        List<AggregateResult> showingEventsAR = new List<AggregateResult>();
        try {
            salesReps = [SELECT Id, Name FROM User WHERE Profile.Name = 'CBS_Sales'];
            showingEventsAR = [SELECT WhoId FROM Event WHERE Subject = 'Airplane Showing' GROUP BY WhoId];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }

        List<String> whoIds = new List<String>();
        for (AggregateResult ar : showingEventsAR) {
            whoIds.add((String) ar.get('WhoId'));
        }

        List<Contact> contacts = new List<Contact>();
        try {
            contacts = [SELECT Id, Name FROM Contact WHERE Id IN :whoIds];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }

        UsersContactsWrapper uCWrapper = new UsersContactsWrapper();
        uCWrapper.contactUsers = contacts;
        uCWrapper.saleRepUsers = salesReps;
        return uCWrapper;
    }

    public class UsersContactsWrapper {
        @AuraEnabled public List<User> saleRepUsers;
        @AuraEnabled public List<Contact> contactUsers;
    }

    @AuraEnabled
    public static List<Event> searchForEvents(String salesRepresentative, String contactUser, Datetime fromDate, Datetime toDate, String orderBy) {
        Boolean hasSalesRep, hasContactUser, hasFromDate, hasToDate = true;
        Boolean hasFirstParam = false;

        hasSalesRep = !CBS_Util.checkIfValueEqualsArguments((Object) salesRepresentative, new List<Object>{
                null, 'All', ''
        });
        hasContactUser = !CBS_Util.checkIfValueEqualsArguments((Object) contactUser, new List<Object>{
                null, 'All', ''
        });
        hasFromDate = fromDate != null ? true : false;
        hasToDate = toDate != null ? true : false;

        if (hasToDate) {
            toDate = toDate.addDays(1);
        }

        String query = 'SELECT Id, Description, Hangar__c, Hangar__r.Name, Airplane_Type__c, Airplane_Type__r.Name, WhoId, Who.Name, Owner.Name, OwnerId, ActivityDateTime FROM Event';

        if (hasSalesRep) {
            query += CBS_Util.buildQueryWithLiteralString('OwnerId', salesRepresentative, hasFirstParam, '=');
            hasFirstParam = true;
        }

        if (hasContactUser) {
            query += CBS_Util.buildQueryWithLiteralString('Who.Id', contactUser, hasFirstParam, '=');
            hasFirstParam = true;
        }

        if (hasFromDate) {
            query += CBS_Util.buildQueryWithVariable('ActivityDateTime', 'fromDate', hasFirstParam, '>=');
            hasFirstParam = true;
        }

        if (hasToDate) {
            query += CBS_Util.buildQueryWithVariable('ActivityDateTime', 'toDate', hasFirstParam, '<');
            hasFirstParam = true;
        }

        query += ' ORDER BY ActivityDateTime ' + orderBy;

        try {
            return Database.query(query);
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static EventWrapper getUpcomingRepsEvents() {
        try {
            Integer eventsPerPage = Integer.valueOf(CBS_Util.getCustomSettingValue('SalesRepresentativeEventsPerPage'));
            EventWrapper wrapper = new EventWrapper();
            wrapper.events = [SELECT Id, Description, Hangar__c, Hangar__r.Name, Airplane_Type__c, Airplane_Type__r.Name, WhoId, Who.Name, Owner.Name, OwnerId, ActivityDateTime FROM Event
                    WHERE OwnerId IN (SELECT Id FROM User WHERE Profile.Name = 'CBS_Sales') AND ActivityDateTime > :System.now() ORDER BY ActivityDateTime LIMIT 6];
            wrapper.eventsPerPage = eventsPerPage;
            return wrapper;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class EventWrapper {
        @AuraEnabled public List<Event> events;
        @AuraEnabled public Integer eventsPerPage;
    }
}