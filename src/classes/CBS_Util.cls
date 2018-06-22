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

    public static Boolean checkIfValueEqualsArguments(Object valueToCheck, List<Object> values) {
        if (valueToCheck == null) {
            for (Object obj : values) {
                if (obj == null) {
                    return true;
                }
            }
        }

        for (Object obj : values) {
            if (valueToCheck.equals(obj)) {
                return true;
            }
        }
        return false;
    }

    public static String buildQueryWithLiteralString(String fieldToAdd, String fieldValue, Boolean hasFirstParam, String operator) {
        String toAdd;

        toAdd =  hasFirstParam ? ' AND ' : ' WHERE ';
        toAdd += fieldToAdd + ' ' + operator + ' ';
        toAdd += (operator == '=') ? + '\'' + fieldValue + '\'' : '\'%' + fieldValue + '%\'';

        return toAdd;
    }

    public static String buildQueryWithVariable(String fieldToAdd, String variableString, Boolean hasFirstParam, String operator) {
        String toAdd;

        toAdd =  hasFirstParam ? ' AND ' : ' WHERE ';
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
                '<urn:username>bartosz@britenet.com</urn:username>' +
                '<urn:password>Grunwald1410TncjzIKk0C42JPT4FZQc5MvF</urn:password>' +
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
            System.debug('session id = ' + sessionIdElm.getText());
            return sessionIdElm.getText();
        }
        return null;
    }
}