public with sharing class CBS_Util {
    public static String getCustomSettingValue(String customSetting) {
        CBS_Setting__c setting = CBS_Setting__c.getInstance(customSetting);
        return setting.Value__c;
    }
}