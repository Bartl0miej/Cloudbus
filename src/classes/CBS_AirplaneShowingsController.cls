public class CBS_AirplaneShowingsController {
    @AuraEnabled
    public static List<PrototypeWrapper> getPrototypesOfAirplaneType(String typeId) {
        try {
            List<PrototypeWrapper> wrappers = new List<CBS_AirplaneShowingsController.PrototypeWrapper>();
            List<Product2> airplanes = [SELECT Id, Name, Hangar__c, Hangar__r.Name, Hangar__r.City__c, Hangar__r.Country__c, Airplane_Type__c FROM Product2 WHERE Airplane_Type__c = :typeId];

            for (Product2 plane : airplanes) {
                PrototypeWrapper wrapper = new PrototypeWrapper();
                wrapper.airplane = plane;
                wrapper.standardPricebookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Product2Id = :plane.Id];
                List<PricebookEntry> promotions = [SELECT Id, UnitPrice, Pricebook2.Promotion_start__c, Pricebook2.Promotion_end__c FROM PricebookEntry WHERE Product2Id = :plane.Id AND Pricebook2.Promotion_start__c <= :System.today() AND Pricebook2.Promotion_end__c >= :System.today() ORDER BY UnitPrice];
                if (promotions != null && promotions.size() > 0) {
                    wrapper.promotionPricebookEntry = promotions[0];
                }
                wrappers.add(wrapper);
            }


            return wrappers;
            //return [SELECT Id, Name, Hangar__c, Hangar__r.Name, Hangar__r.City__c, Hangar__r.Country__c, Airplane_Type__c FROM Product2 WHERE Airplane_Type__c = :typeId];


        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class PrototypeWrapper {
        @AuraEnabled public Product2 airplane;
        @AuraEnabled public PricebookEntry standardPricebookEntry;
        @AuraEnabled public PricebookEntry promotionPricebookEntry;

    }

    @AuraEnabled
    public static List<ShowingInfo> getUserShowingFromCache() {
        try {
            return (List<ShowingInfo>) Cache.Session.get('ShowingsCartCache');
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static List<ShowingInfo> putShowingInSessionCache(String uId, Product2 aircraft, String dateTimeInfo) {
        ShowingInfo sInfo = new ShowingInfo();
        sInfo.thePlane = aircraft;
        sInfo.dTI = dateTimeInfo;

        DateTime toAddDt = (DateTime) JSON.deserialize('"' + sInfo.dTI + '"', DateTime.class);

        List<ShowingInfo> sessInfo = (List<ShowingInfo>) Cache.Session.get('ShowingsCartCache');
        if (sessInfo == null) {
            sessInfo = new List<CBS_AirplaneShowingsController.ShowingInfo>();
        }

        for (ShowingInfo showing : sessInfo) {
            DateTime userDt = (DateTime) JSON.deserialize('"' + showing.dTI + '"', DateTime.class);
            if ((toAddDt < userDt && toAddDt.addHours(6) > userDt) || toAddDt == userDt || (userDt < toAddDt && userDt.addHours(6) > toAddDt)) {
                throw new AuraHandledException('You already requested for showing on: ' + userDt.addHours(1));
            }
        }

        System.debug('sInfoPlaneId = ' + sInfo.thePlane.Id);
        System.debug('sInfo.Hangar__c = ' + sInfo.thePlane.Hangar__c);
        List<CBS_Hangar__c> hangars = [SELECT Sales_Representative__r.Name FROM CBS_Hangar__c WHERE Id = :sInfo.thePlane.Hangar__c];
        System.debug('hangars user ids size = ' + hangars.size());
        System.debug(hangars[0].Sales_Representative__r.Id);

        List<User> commUser = [SELECT ContactId FROM User WHERE Id = :uId LIMIT 1];
        List<Event> userEvents = new List<Event>();// = [SELECT ActivityDateTime FROM Event WHERE WhoId = :commUser[0].ContactId];

        System.debug('contact id = ' + commUser[0].ContactId);


        Http rrHttp = new Http();
        HttpRequest request = new HttpRequest();
        String preparedQuery = 'SELECT ActivityDateTime FROM Event WHERE WhoId=' + '\'' + commUser[0].ContactId + '\'';
        preparedQuery = preparedQuery.replaceAll('\\s+', '+');
        System.debug('pQ = ' + preparedQuery);
        request.setEndpoint('https://eu12.salesforce.com/services/data/v41.0/query/?q=' + preparedQuery);
        request.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
        request.setMethod('GET');
        HttpResponse response = rrHttp.send(request);
        List<Event> events = new List<Event>();
        ResponseJson resJson = new ResponseJson();
        if (response.getStatusCode() == 200) {
            resJson = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
            userEvents = resJson.records;
        } else {
            System.debug('Cos sie zjebalo');
        }

        Http rrHttp2 = new Http();
        HttpRequest request2 = new HttpRequest();
        String preparedQuery2 = 'SELECT ActivityDateTime FROM Event WHERE OwnerId=' + '\'' + hangars[0].Sales_Representative__r.Id + '\'';
        preparedQuery2 = preparedQuery2.replaceAll('\\s+', '+');
        System.debug('pQ = ' + preparedQuery2);
        request2.setEndpoint('https://eu12.salesforce.com/services/data/v41.0/query/?q=' + preparedQuery2);
        request2.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
        request2.setMethod('GET');
        HttpResponse response2 = rrHttp2.send(request2);
        List<Event> eventsList = new List<Event>();
        ResponseJson resJson2 = new ResponseJson();
        if (response.getStatusCode() == 200) {
            resJson2 = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response2.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
            eventsList = resJson2.records;
        } else {
            System.debug('Cos sie zjebalo');
        }

        for (Event evt : eventsList) {
            if ((toAddDt < evt.ActivityDateTime && toAddDt.addHours(6) > evt.ActivityDateTime) || toAddDt == evt.ActivityDateTime || (evt.ActivityDateTime < toAddDt && evt.ActivityDateTime.addHours(6) > toAddDt)) {
                throw new AuraHandledException('There already is a booked showing on: ' + evt.ActivityDateTime.addHours(1));
            }
        }

        for (Event evt : userEvents) {
            if ((toAddDt < evt.ActivityDateTime && toAddDt.addHours(6) > evt.ActivityDateTime) || toAddDt == evt.ActivityDateTime || (evt.ActivityDateTime < toAddDt && evt.ActivityDateTime.addHours(6) > toAddDt)) {
                throw new AuraHandledException('You already have a booked event on: ' + evt.ActivityDateTime.addHours(1));
            }
        }
        sessInfo.add(sInfo);
        Cache.Session.put('ShowingsCartCache', sessInfo);

        return sessInfo;
    }

    @AuraEnabled
    public static List<Event> getUpcomingUserEvents(String uId) {
        try {
            List<User> commUser = [SELECT ContactId, AccountId FROM User WHERE Id = :uId LIMIT 1];
            Http rrHttp = new Http();
            HttpRequest request = new HttpRequest();
            String preparedQuery = 'SELECT Id, Description, ActivityDateTime, Airplane_Type__c, Airplane_Type__r.Price_after_Discount__c, Hangar__c, Airplane_Type__r.Name, Hangar__r.Name FROM Event WHERE WhoId=' + '\'' + commUser[0].ContactId + '\' ORDER BY ActivityDateTime';
            preparedQuery = preparedQuery.replaceAll('\\s+', '+');
            System.debug('pQ = ' + preparedQuery);
            request.setEndpoint('https://eu12.salesforce.com/services/data/v41.0/query/?q=' + preparedQuery);
            request.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
            request.setMethod('GET');
            HttpResponse response = rrHttp.send(request);
            List<Event> events = new List<Event>();
            ResponseJson resJson = new ResponseJson();
            if (response.getStatusCode() == 200) {
                resJson = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
                for (Event evt : resJson.records) {
                    if (evt.ActivityDateTime > System.now()) {
                        events.add(evt);
                    }
                }
            } else {
                System.debug('Something went wrong.');
            }

            return events;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static List<ShowingInfo> removeShowing(String showingIndex) {
        Integer intShowingIndex = Integer.valueOf(String.valueOf(showingIndex));
        try {
            List<ShowingInfo> sessInfo = (List<ShowingInfo>) Cache.Session.get('ShowingsCartCache');

            if (sessInfo == null) {
                return null;
            }

            sessInfo.remove(intShowingIndex);

            Cache.Session.remove('ShowingsCartCache');
            Cache.Session.put('ShowingsCartCache', sessInfo);

            return sessInfo;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    @AuraEnabled
    public static void removeUserShowings() {
        List<ShowingInfo> newShowings = new List<CBS_AirplaneShowingsController.ShowingInfo>();
        try {
            List<ShowingInfo> sessInfo = (List<ShowingInfo>) Cache.Session.get('ShowingsCartCache');
            if (sessInfo == null) {
                return;
            }
            Cache.Session.remove('ShowingsCartCache');
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }


    @AuraEnabled
    public static void createEventsFromShowings(String uId) {
        String userId = uId;
        List<ShowingInfo> sessInfo = (List<ShowingInfo>) Cache.Session.get('ShowingsCartCache');

        if (sessInfo == null) {
            return;
        }

        List<User> commUser = [SELECT ContactId, AccountId, Name FROM User WHERE Id = :userId LIMIT 1];

        List<Event> showingEvents = new List<Event>();

        List<String> hangarIds = new List<String>();
        for (ShowingInfo userShowing : sessInfo) {
            hangarIds.add(userShowing.thePlane.Hangar__c);
        }

        List<CBS_Hangar__c> salesRepsIdsForHangars = [SELECT Id, Sales_Representative__c FROM CBS_Hangar__c WHERE Id IN :hangarIds];

        String inQuery = '(';
        Map<String, String> salesRepsMap = new Map<String, String>();
        for (CBS_Hangar__c hangar : salesRepsIdsForHangars) {
            salesRepsMap.put(hangar.Id, hangar.Sales_Representative__c);
            inQuery += '\'' + hangar.Sales_Representative__c + '\', ';
        }

        inQuery = inQuery.removeEnd(', ');
        inQuery += ')';

        List<Event> eventsList = new List<Event>();

        Http rrHttp = new Http();
        HttpRequest request = new HttpRequest();
        String preparedQuery = 'SELECT ActivityDateTime FROM Event WHERE OwnerId IN ' + inQuery;
        preparedQuery = preparedQuery.replaceAll('\\s+', '+');
        request.setEndpoint('https://eu12.salesforce.com/services/data/v41.0/query/?q=' + preparedQuery);
        request.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
        request.setMethod('GET');
        HttpResponse response = rrHttp.send(request);
        List<Event> events = new List<Event>();
        ResponseJson resJson = new ResponseJson();
        if (response.getStatusCode() == 200) {
            resJson = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
            eventsList = resJson.records;
        } else {
            System.debug('Error');
        }

        String exceptionMessage = '';
        Boolean hasExceptions = false;
        for (ShowingInfo showing : sessInfo) {
            Event evt = new Event();
            evt.WhoId = commUser[0].ContactId;
            evt.DurationInMinutes = 360;
            evt.OwnerId = salesRepsMap.get(showing.thePlane.Hangar__c);
            DateTime dt = (DateTime) JSON.deserialize('"' + showing.dTI + '"', DateTime.class);
            for (Event tEvent : eventsList) {
                if ((dt < tEvent.ActivityDateTime && dt.addHours(6) > tEvent.ActivityDateTime) || dt == tEvent.ActivityDateTime || (tEvent.ActivityDateTime < dt && tEvent.ActivityDateTime.addHours(6) > dt)) {
                    hasExceptions = true;
                    exceptionMessage += 'There already is a booked showing on: ' + evt.ActivityDateTime.addHours(1) + ' for airplane ' + evt.Airplane_Type__r.Name + ' in hangar ' + evt.Hangar__r.Name;
                    continue;
                }
            }
            evt.StartDateTime = dt;
            evt.Subject = 'Airplane Showing';
            evt.Type = 'Airplane Showing';
            evt.Hangar__c = showing.thePlane.Hangar__c;
            evt.Airplane_Type__c = showing.thePlane.Airplane_Type__c;
            evt.WhatId = showing.thePlane.Id;
            System.debug('evt what id = ' + evt.WhatId);
            evt.Description = 'Showing for ' + showing.thePlane.Name + ' in hangar: ' + showing.thePlane.Hangar__r.Name + ', suggested price: ' + showing.thePlane.Airplane_Type__r.Price_after_Discount__c + '.';
            showingEvents.add(evt);
        }


        String restBody = JSON.serialize(showingEvents);
        restBody = restBody.replace('Event"}', 'Event", "referenceId" : "ref1"}');



        for (Integer i = 0; i < showingEvents.size(); i++) {
            restBody = restBody.replaceFirst('ref1', 'ref' + i);
        }

        restBody = '{"records" :' + restBody + '}';
        System.debug(restBody);


        Http rrHttp3 = new Http();
        HttpRequest request3 = new HttpRequest();
        request3.setEndpoint('https://eu12.salesforce.com/services/data/v34.0/composite/tree/Event');
        request3.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
        request3.setMethod('POST');
        request3.setHeader('Content-Type', 'application/json');
        request3.setBody(restBody);
        HttpResponse response3 = rrHttp3.send(request3);


//        for (Event evt : showingEvents) {
//            String serializedEvent = serializeEvent(evt);
//            Http rrHttp3 = new Http();
//            HttpRequest request3 = new HttpRequest();
//            request3.setEndpoint('https://eu12.salesforce.com/services/data/v40.0/sobjects/Event/');
//            request3.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
//            request3.setMethod('POST');
//            request3.setHeader('Content-Type', 'application/json');
//            request3.setBody(serializedEvent);
//            HttpResponse response3 = rrHttp3.send(request3);
//            System.debug('response3 = ' + response3);
//        }
//
//        System.debug(JSON.serialize(showingEvents));

        removeUserShowings();

        if (hasExceptions) {
            throw new AuraHandledException(exceptionMessage);
        }
    }

    private static String serializeEvent(Event evt) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeDateTimeField('StartDateTime', evt.StartDateTime);
        gen.writeNumberField('DurationInMinutes', evt.DurationInMinutes);
        gen.writeIdField('OwnerId', evt.OwnerId);
        gen.writeStringField('Description', evt.Description);
        gen.writeIdField('WhoId', evt.WhoId);
        gen.writeStringField('Subject', evt.Subject);
        gen.writeStringField('Type', evt.Type);
        gen.writeIdField('Hangar__c', evt.Hangar__c);
        gen.writeIdField('Airplane_Type__c', evt.Airplane_Type__c);
        gen.writeIdField('WhatId', evt.WhatId);

        return gen.getAsString();
    }


    public class ShowingInfo {
        @AuraEnabled public Product2 thePlane;
        @AuraEnabled public String dTI;
    }

    public class ResponseJson {
        @AuraEnabled public List<Event> records { get; set; }
        @AuraEnabled public Integer totalSize { get; set; }
        public ResponseJson() {
        }
    }

}