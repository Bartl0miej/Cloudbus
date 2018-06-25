public class CBS_AirplaneShowingsController {
    @AuraEnabled
    public static List<PrototypeWrapper> getPrototypesOfAirplaneType(String typeId) {
        try {
            List<PrototypeWrapper> wrappers = new List<CBS_AirplaneShowingsController.PrototypeWrapper>();
            List<Product2> airplanes = [SELECT Id, Name, Hangar__c, Hangar__r.Name, Hangar__r.City__c, Hangar__r.Country__c, Airplane_Type__c FROM Product2 WHERE Airplane_Type__c = :typeId];
            List<String> planeIds = new List<String>();
            for (Product2 airplane : airplanes) {
                planeIds.add(airplane.Id);
            }
            List<PricebookEntry> standardPBE = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Product2Id IN :planeIds];

            Map<String, PricebookEntry> standardPricesMap = new Map<String, PricebookEntry>();

            for (PricebookEntry entry : standardPBE) {
                standardPricesMap.put(entry.Product2Id, entry);
            }

            List<PricebookEntry> promotions = [SELECT Id, UnitPrice, Pricebook2.Promotion_start__c, Pricebook2.Promotion_end__c, Product2Id FROM PricebookEntry WHERE Product2Id IN :planeIds AND Pricebook2.Promotion_start__c <= :System.today() AND Pricebook2.Promotion_end__c >= :System.today()];

            Map<String, PricebookEntry> promotionsMap = new Map<String, PricebookEntry>();
            for (PricebookEntry entry : promotions) {
                PricebookEntry promEntry = promotionsMap.get(entry.Product2Id);
                if (promEntry == null) {
                    promotionsMap.put(entry.Product2Id, entry);
                } else if (entry.UnitPrice < promEntry.UnitPrice) {
                    promotionsMap.put(entry.Product2Id, entry);
                }
            }

            for (Product2 plane : airplanes) {
                PrototypeWrapper wrapper = new PrototypeWrapper();
                wrapper.airplane = plane;
                wrapper.standardPricebookEntry = standardPricesMap.get(plane.Id);
                if (promotionsMap.get(plane.Id) != null) {
                    wrapper.promotionPricebookEntry = promotionsMap.get(plane.Id);
                }
                wrappers.add(wrapper);
            }

            return wrappers;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class PrototypeWrapper {
        @AuraEnabled
        public Product2 airplane;
        @AuraEnabled
        public PricebookEntry standardPricebookEntry;
        @AuraEnabled
        public PricebookEntry promotionPricebookEntry;
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
        Integer showingDuration = Integer.valueOf(CBS_Util.getCustomSettingValue('ShowingDurationInHours'));
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
            if ((toAddDt < userDt && toAddDt.addHours(showingDuration) > userDt) || toAddDt == userDt || (userDt < toAddDt && userDt.addHours(showingDuration) > toAddDt)) {
                throw new AuraHandledException(Label.CBS_You_already_requested_for_showing_on + ' ' + userDt.addHours(1));
            }
        }

        List<CBS_Hangar__c> hangars = [SELECT Sales_Representative__r.Name FROM CBS_Hangar__c WHERE Id = :sInfo.thePlane.Hangar__c];

        List<User> commUser = [SELECT ContactId FROM User WHERE Id = :uId LIMIT 1];
        List<Event> userEvents = new List<Event>();

        Http rrHttp = new Http();
        String preparedQuery = 'SELECT ActivityDateTime FROM Event WHERE WhoId=' + '\'' + commUser[0].ContactId + '\'';
        preparedQuery = preparedQuery.replaceAll('\\s+', '+');
        HttpRequest request = CBS_Util.setUpQueryRequest(preparedQuery);
        HttpResponse response = rrHttp.send(request);
        List<Event> events = new List<Event>();
        ResponseJson resJson = new ResponseJson();
        if (response.getStatusCode() == 200) {
            resJson = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
            userEvents = resJson.records;
        } else {
            throw new AuraHandledException(String.valueOf(response.getStatusCode()));
        }

        rrHttp = new Http();
        preparedQuery = 'SELECT ActivityDateTime FROM Event WHERE OwnerId=' + '\'' + hangars[0].Sales_Representative__r.Id + '\'';
        preparedQuery = preparedQuery.replaceAll('\\s+', '+');
        request = CBS_Util.setUpQueryRequest(preparedQuery);
        response = rrHttp.send(request);
        List<Event> eventsList = new List<Event>();
        resJson = new ResponseJson();
        if (response.getStatusCode() == 200) {
            resJson = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
            eventsList = resJson.records;
        } else {
            throw new AuraHandledException(String.valueOf(response.getStatusCode()));
        }

        for (Event evt : eventsList) {
            if ((toAddDt < evt.ActivityDateTime && toAddDt.addHours(showingDuration) > evt.ActivityDateTime) || toAddDt == evt.ActivityDateTime || (evt.ActivityDateTime < toAddDt && evt.ActivityDateTime.addHours(showingDuration) > toAddDt)) {
                throw new AuraHandledException(Label.CBS_There_already_is_a_booked_showing_on + ' ' + evt.ActivityDateTime.addHours(1));
            }
        }

        for (Event evt : userEvents) {
            if ((toAddDt < evt.ActivityDateTime && toAddDt.addHours(showingDuration) > evt.ActivityDateTime) || toAddDt == evt.ActivityDateTime || (evt.ActivityDateTime < toAddDt && evt.ActivityDateTime.addHours(showingDuration) > toAddDt)) {
                throw new AuraHandledException(Label.CBS_You_already_have_a_booked_event_on + ' ' + evt.ActivityDateTime.addHours(1));
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
            String preparedQuery = 'SELECT Id, Description, ActivityDateTime, Airplane_Type__c, Airplane_Type__r.Price_after_Discount__c, Hangar__c, Airplane_Type__r.Name, Hangar__r.Name FROM Event WHERE WhoId=' + '\'' + commUser[0].ContactId + '\' ORDER BY ActivityDateTime';
            preparedQuery = preparedQuery.replaceAll('\\s+', '+');
            HttpRequest request = CBS_Util.setUpQueryRequest(preparedQuery);
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
                throw new AuraHandledException(String.valueOf(response.getStatusCode()));
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
        String preparedQuery = 'SELECT ActivityDateTime FROM Event WHERE OwnerId IN ' + inQuery;
        preparedQuery = preparedQuery.replaceAll('\\s+', '+');
        HttpRequest request = CBS_Util.setUpQueryRequest(preparedQuery);
        HttpResponse response = rrHttp.send(request);
        List<Event> events = new List<Event>();
        ResponseJson resJson = new ResponseJson();
        if (response.getStatusCode() == 200) {
            resJson = (CBS_AirplaneShowingsController.ResponseJson) JSON.deserialize(response.getBody(), CBS_AirplaneShowingsController.ResponseJson.class);
            eventsList = resJson.records;
        } else {
            throw new AuraHandledException(String.valueOf(response.getStatusCode()));
        }

        Integer showingDuration = Integer.valueOf(CBS_Util.getCustomSettingValue('ShowingDurationInHours'));
        String exceptionMessage = '';
        Boolean hasExceptions = false;
        for (ShowingInfo showing : sessInfo) {
            Event evt = new Event();
            evt.WhoId = commUser[0].ContactId;
            evt.DurationInMinutes = showingDuration * 60;
            evt.OwnerId = salesRepsMap.get(showing.thePlane.Hangar__c);
            DateTime dt = (DateTime) JSON.deserialize('"' + showing.dTI + '"', DateTime.class);
            for (Event tEvent : eventsList) {
                if ((dt < tEvent.ActivityDateTime && dt.addHours(showingDuration) > tEvent.ActivityDateTime) || dt == tEvent.ActivityDateTime || (tEvent.ActivityDateTime < dt && tEvent.ActivityDateTime.addHours(showingDuration) > dt)) {
                    hasExceptions = true;
                    exceptionMessage += Label.CBS_There_already_is_a_booked_showing_on + ' ' + evt.ActivityDateTime.addHours(1) + ' ' + Label.CBS_for_airplane + ' ' + evt.Airplane_Type__r.Name + ' ' + Label.CBS_in_hangar + ' ' + evt.Hangar__r.Name;
                    continue;
                }
            }
            evt.StartDateTime = dt;
            evt.Subject = Label.CBS_Airplane_showing;
            evt.Type =Label.CBS_Airplane_showing;
            evt.Hangar__c = showing.thePlane.Hangar__c;
            evt.Airplane_Type__c = showing.thePlane.Airplane_Type__c;
            evt.WhatId = showing.thePlane.Id;
            evt.Description = Label.CBS_Showing_for + ' ' + showing.thePlane.Name + ' ' + Label.CBS_in_hangar + ' ' + showing.thePlane.Hangar__r.Name + '.';
            showingEvents.add(evt);
        }

        if (hasExceptions) {
            throw new AuraHandledException(exceptionMessage);
        }

        String restBody = JSON.serialize(showingEvents);
        System.debug(restBody);
        restBody = restBody.replace('Event"}', 'Event", "referenceId" : "ref1"}');

        for (Integer i = 0; i < showingEvents.size(); i++) {
            restBody = restBody.replaceFirst('ref1', 'ref' + i);
        }

        restBody = '{"records" :' + restBody + '}';

        rrHttp = new Http();
        request = CBS_Util.setUpPostListRequest(restBody);
        response = rrHttp.send(request);

        removeUserShowings();
    }

    public class ShowingInfo {
        @AuraEnabled
        public Product2 thePlane;
        @AuraEnabled
        public String dTI;
    }

    public class ResponseJson {
        @AuraEnabled
        public List<Event> records { get; set; }
        @AuraEnabled
        public Integer totalSize { get; set; }
    }
}