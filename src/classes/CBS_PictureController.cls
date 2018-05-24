public with sharing class CBS_PictureController {
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {

        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            //return null;
        }

        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') ORDER BY LastModifiedDate DESC LIMIT 1];
    }

    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) {

        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            throw new System.NoAccessException();
            //return null;
        }

        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.contentType = contentType;
        insert attachment;
        return attachment.id;
    }

    @AuraEnabled
    public static AttachmentsWrapper getAttachments(String recordId) {
        AttachmentsWrapper aWrapper = new AttachmentsWrapper();
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
        if (!atts.isEmpty()) {
            aWrapper.mainPicture = atts.get(0);
        } else {
            aWrapper.mainPicture = null;
        }
        aWrapper.attachments = [SELECT Id FROM Attachment WHERE ParentId = :recordId AND Name != 'main'];

        return aWrapper;
    }

    public class AttachmentsWrapper {
        @AuraEnabled public Attachment mainPicture;
        @AuraEnabled public List<Attachment> attachments;
    }
}