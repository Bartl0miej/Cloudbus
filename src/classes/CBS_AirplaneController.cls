public with sharing class CBS_AirplaneController {
    @AuraEnabled
    public static List<Attachment> getAttachments(String recordId) {
        return [SELECT Id FROM Attachment WHERE ParentId = :recordId];
    }
}