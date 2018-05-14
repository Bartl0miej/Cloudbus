public with sharing class CBS_HangarController {

    @AuraEnabled public static List<HangarResult> results { get; set; }

    @AuraEnabled
    public static List<HangarResult> searchHangars(CBS_Hangar__c searchedHangar) {
        String nameParam, emailParam, cityParam;
        String query = 'SELECT Id, Name, Country__c, City__c, Capacity__c, E_mail__c, Military__c, Street__c, Telephone__c FROM CBS_Hangar__c WHERE Country__c = \'' + searchedHangar.Country__c + '\'';

        if (String.isNotEmpty(searchedHangar.Name)) {
            nameParam = ' \'%' + searchedHangar.Name + '%\' ';
            query += ' AND Name LIKE ' + nameParam;
        }

        if (String.isNotEmpty(searchedHangar.City__c)) {
            cityParam = ' \'%' + searchedHangar.City__c + '%\' ';
            query += ' AND Name LIKE ' + cityParam;
        }
        List<CBS_Hangar__c> cbsHangars = Database.query(query);
        results = new List<HangarResult>();
        for (CBS_Hangar__c hngr : cbsHangars) {
            HangarResult tempResult = new HangarResult();
            tempResult.hangar = hngr;
            getGeoLocations(tempResult);
            results.add(tempResult);
        }

        return results;
    }

    @AuraEnabled
    public static HangarResult getHangarWrapper(CBS_Hangar__c hangarToFind) {
        HangarResult result = new HangarResult();
        result.hangar = hangarToFind;
        getGeoLocations(result);
        return result;
    }

    private static void getGeoLocations(HangarResult hangarWrapper) {
        Double geolocations;

        Http rrHttp = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + hangarWrapper.hangar.Country__c;

        if (hangarWrapper.hangar.City__c != null) {
            endpoint += '+' + hangarWrapper.hangar.City__c;
        }

        if (hangarWrapper.hangar.Street__c != null) {
            endpoint += '+' + hangarWrapper.hangar.Street__c;
        }

        endpoint += '&key=';
        endpoint += CBS_Util.getCustomSettingValue('GoogleApiKey');
        request.setEndpoint(endpoint);
        HttpResponse response = rrHttp.send(request);
        RootObject resJson = new RootObject();
        if (response.getStatusCode() == 200) {
            resJson = (RootObject)JSON.deserialize(response.getBody(), RootObject.class);
            hangarWrapper.latitude = String.valueOf(resJson.results.get(0).geometry.location.lat);
            hangarWrapper.longitude = String.valueOf(resJson.results.get(0).geometry.location.lng);
        } else {
        }

    }

    public class HangarResult {
        @AuraEnabled public CBS_Hangar__c hangar { get; set;}
        @AuraEnabled public String latitude { get; set; }
        @AuraEnabled public String longitude { get; set; }
    }

    public class Location {
        public double lat { get; set; }
        public double lng { get; set; }
    }

    public class Geometry {
        public Location location { get; set; }
    }

    public class Result {
        public Geometry geometry { get; set; }
    }

    public class RootObject {
        public List<Result> results { get; set; }
        public string status { get; set; }
    }
}