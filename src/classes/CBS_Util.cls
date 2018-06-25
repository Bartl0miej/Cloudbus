public with sharing class CBS_Util {
    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:enterprise.soap.sforce.com';

    public static String getCustomSettingValue(String customSetting) {
        CBS_Setting__c setting = CBS_Setting__c.getInstance(customSetting);
        return setting.Value__c;
    }

    public static String transformStringToLikeQuery(String param) {
        return '\'%' + param + '%\'';
    }

    public static Boolean checkIfStringValueEqualsArguments(String valueToCheck, List<String> values) {
        if (valueToCheck.contains('All')) {
            return true;
        }

        if (valueToCheck == null) {
            for (String obj : values) {
                if (obj == null) {
                    return true;
                }
            }
        }

        for (String obj : values) {
            if (valueToCheck.equalsIgnoreCase(obj)) {
                return true;
            }
        }
        return false;
    }

    public static String buildQueryWithLiteralString(String fieldToAdd, String fieldValue, Boolean hasFirstParam, String operator) {
        String toAdd;

        toAdd = hasFirstParam ? ' AND ' : ' WHERE ';
        toAdd += fieldToAdd + ' ' + operator + ' ';
        toAdd += (operator == '=') ? +'\'' + fieldValue + '\'' : '\'%' + fieldValue + '%\'';

        return toAdd;
    }

    public static String buildQueryWithVariable(String fieldToAdd, String variableString, Boolean hasFirstParam, String operator) {
        String toAdd;

        toAdd = hasFirstParam ? ' AND ' : ' WHERE ';
        toAdd += fieldToAdd + ' ' + operator + ' ';
        toAdd += ' :' + variableString;

        return toAdd;
    }

    public static String login() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://login.salesforce.com/services/Soap/c/42.0');
        request.setHeader('SOAPAction', '""');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
                '<soapenv:Header>' + '</soapenv:Header>' + '<soapenv:Body>' + '<urn:login>' +
                '<urn:username>' + CBS_Util.getCustomSettingValue('AdminUserName') + '</urn:username>' +
                '<urn:password>' + CBS_Util.getCustomSettingValue('AdminPass') +  '</urn:password>' +
                '</urn:login>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Dom.Document responseDocument = response.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement();
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP);
            Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF);
            Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF);
            Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF);
            return sessionIdElm.getText();
        }
        return null;
    }

    public static HttpRequest setUpQueryRequest(String preparedQuery) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CBS_Util.getCustomSettingValue('StandardQueryEndpoint') + preparedQuery);
        request.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
        request.setMethod('GET');

        return request;
    }

    public static HttpRequest setUpPostListRequest(String restBody) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CBS_Util.getCustomSettingValue('RestPostEventsList'));
        request.setHeader('Authorization', 'OAuth ' + CBS_Util.login());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(restBody);

        return request;
    }
}