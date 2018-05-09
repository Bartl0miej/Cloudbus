public with sharing class CBS_HangarController {
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

        System.debug('QUERY: ' + query);

        System.debug(Database.query(query));
        List<CBS_Hangar__c> cbsHangars = Database.query(query);
        List<HangarResult> results = new List<HangarResult>();
        for (CBS_Hangar__c hngr : cbsHangars) {
            HangarResult tempResult = new HangarResult();
            tempResult.hangar = hngr;
            getGeoLocations(tempResult);
            results.add(tempResult);
        }

        return results;
    }

    private static void getGeoLocations(HangarResult hangarWrapper) {
/*        for (CBS_Hangar__c hangar : ) {

        }*/

        Double geolocations;

        Http rrHttp = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
//        request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + hangarWrapper.hangar.Country__c + '&key=AIzaSyCBtvTZtClyA-axDWKzRrJnFUmIoJZC0OM');
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + hangarWrapper.hangar.Country__c;
        //request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + hangarWrapper.hangar.Country__c);

        if (hangarWrapper.hangar.City__c != null) {
            endpoint += '+' + hangarWrapper.hangar.City__c;
        }

        if (hangarWrapper.hangar.Street__c != null) {
            endpoint += '+' + hangarWrapper.hangar.Street__c;
        }

        endpoint += '&key=AIzaSyCBtvTZtClyA-axDWKzRrJnFUmIoJZC0OM';
        request.setEndpoint(endpoint);

        //request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=Lublin+Ruska&key=AIzaSyCBtvTZtClyA-axDWKzRrJnFUmIoJZC0OM');
        HttpResponse response = rrHttp.send(request);
        RootObject resJson = new RootObject();
        if (response.getStatusCode() == 200) {
            resJson = (RootObject)JSON.deserialize(response.getBody(), RootObject.class);
            System.debug(response.getBody());
            System.debug('resJson = ' + resJson);
            System.debug('lat: ' + resJson.results.get(0).geometry.location.lat);
            System.debug('lng: ' + resJson.results.get(0).geometry.location.lng);
            hangarWrapper.latitude = String.valueOf(resJson.results.get(0).geometry.location.lat);
            hangarWrapper.longitude = String.valueOf(resJson.results.get(0).geometry.location.lng);



            /*geolocations = resJson.geometry.location.lat;*/
            System.debug('geolocations: ' + geolocations);
        } else {
        }

    }

    public class HangarResult {
        @AuraEnabled public CBS_Hangar__c hangar { get; set;}
        @AuraEnabled public String latitude { get; set; }
        @AuraEnabled public String longitude { get; set; }
    }

    public class ResponseJson {
        public List<String> records { get; set; }
        public Integer totalSize { get; set; }
        public ResponseJson() { }
    }

    public class AddressComponent
    {
        public string long_name { get; set; }
        public string short_name { get; set; }
        public List<string> types { get; set; }
    }

    public class Northeast
    {
        public double lat { get; set; }
        public double lng { get; set; }
    }

    public class Southwest
    {
        public double lat { get; set; }
        public double lng { get; set; }
    }

    public class Bounds
    {
        public Northeast northeast { get; set; }
        public Southwest southwest { get; set; }
    }

    public class Location
    {
        public double lat { get; set; }
        public double lng { get; set; }
    }

    public class Northeast2
    {
        public double lat { get; set; }
        public double lng { get; set; }
    }

    public class Southwest2
    {
        public double lat { get; set; }
        public double lng { get; set; }
    }

    public class Viewport
    {
        public Northeast2 northeast { get; set; }
        public Southwest2 southwest { get; set; }
    }

    public class Geometry
    {
        public Bounds bounds { get; set; }
        public Location location { get; set; }
        public string location_type { get; set; }
        public Viewport viewport { get; set; }
    }

    public class Result
    {
        public List<AddressComponent> address_components { get; set; }
        public string formatted_address { get; set; }
        public Geometry geometry { get; set; }
        public string place_id { get; set; }
        public List<string> types { get; set; }
    }

    public class RootObject
    {
        public List<Result> results { get; set; }
        public string status { get; set; }
    }
}