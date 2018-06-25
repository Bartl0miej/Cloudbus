public with sharing class CBS_AirplaneSalesEventsController {
    @AuraEnabled
    public static UsersContactsWrapper getSalesRepresentativesAndContacts() {
        Integer eventsPerPage = Integer.valueOf(CBS_Util.getCustomSettingValue('SalesRepresentativeEventsPerPage'));
        List<User> salesReps = new List<User>();
        List<Event> events =  [SELECT WhoId FROM Event WHERE Subject = 'Airplane Showing'];

        try {
            salesReps = [SELECT Id, Name, FirstName, LastName FROM User WHERE Profile.Name = 'CBS_Sales'];
            events = [SELECT WhoId FROM Event WHERE Subject = 'Airplane Showing'];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }

        List<String> whoIds = new List<String>();
        for (Event evt : events) {
            whoIds.add(evt.WhoId);
        }

        List<Contact> contacts = new List<Contact>();
        try {
            contacts = [SELECT Id, FirstName, LastName, Name FROM Contact WHERE Id IN :whoIds];
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }

        User allUser = new User(FirstName='All', LastName='', Title='');
        salesReps.add(0, allUser);

        Contact allContact = new Contact(FirstName='All', LastName='', Title='');
        contacts.add(0, allContact);

        return new UsersContactsWrapper(salesReps, contacts);
    }

    public class UsersContactsWrapper {
        public UsersContactsWrapper(List<User> saleRepUsers, List<Contact> contactUsers) {
            this.saleRepUsers = saleRepUsers;
            this.contactUsers = contactUsers;
        }

        @AuraEnabled
        public List<User> saleRepUsers;
        @AuraEnabled
        public List<Contact> contactUsers;
    }

    @AuraEnabled
    public static List<Event> searchForEvents(String salesRepresentative, String contactUser, Datetime fromDate, Datetime toDate, String orderBy) {
        Boolean hasSalesRep, hasContactUser, hasFromDate, hasToDate = true;
        Boolean hasFirstParam = false;

        hasSalesRep = !CBS_Util.checkIfStringValueEqualsArguments(salesRepresentative, new List<String>{
                null, 'All', ''
        });
        hasContactUser = !CBS_Util.checkIfStringValueEqualsArguments(contactUser, new List<String>{
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
            List<Event> events = [SELECT Id, Description, Hangar__c, Hangar__r.Name, Airplane_Type__c, Airplane_Type__r.Name, WhoId, Who.Name, Owner.Name, OwnerId, ActivityDateTime FROM Event
                    WHERE OwnerId IN (SELECT Id FROM User WHERE Profile.Name = 'CBS_Sales') AND ActivityDateTime > :System.now() ORDER BY ActivityDateTime LIMIT :eventsPerPage];
            return new EventWrapper(events, eventsPerPage);
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class EventWrapper {
        @AuraEnabled
        public List<Event> events;
        @AuraEnabled
        public Integer eventsPerPage;

        public EventWrapper(List<Event> events, Integer eventsPerPage) {
            this.events = events;
            this.eventsPerPage = eventsPerPage;
        }
    }
}