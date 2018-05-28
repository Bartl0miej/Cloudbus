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
        return attachment.Id;
    }

    @AuraEnabled
    public static AttachmentsWrapper getAttachments(String recordId) {
        AttachmentsWrapper aWrapper = new AttachmentsWrapper();
        try {
            List<Attachment> atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
            if (!atts.isEmpty()) {
                aWrapper.mainPicture = atts.get(0);
                System.debug('--- ' + aWrapper.mainPicture.Id);
            } else {
                aWrapper.mainPicture = null;
            }
            aWrapper.attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name != 'main'];

            return aWrapper;
        } catch (Exception exc) {
            CBS_CustomExceptionData errData = new CBS_CustomExceptionData(exc.getTypeName(), exc.getMessage());
            throw new AuraHandledException(JSON.serialize(errData));
        }
    }

    public class AttachmentsWrapper {
        @AuraEnabled public Attachment mainPicture;
        @AuraEnabled public List<Attachment> attachments;
    }

//    @AuraEnabled
//    public static void saveAirplane(List<String> mainPicture, Boolean isAttachement, String recordId) {
//        System.debug('mainPicId = ' + String.valueOf(mainPicture[0]));
//        List<Attachment> att = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
//        if (!att.isEmpty()) {
//            att[0].Name = 'attachment';
//            update  att;
//        }
//
//        if (isAttachement) {
//            Attachment toBeMain = [SELECT Id, Name FROM Attachment WHERE Id = :mainPicture[0]];
//            toBeMain.Name = 'main';
//            update toBeMain;
//        }
//
//    }

    @AuraEnabled
    public static void cancelAirplaneEdit(List<String> picsToCancel) {
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        for (String picId : picsToCancel) {
            Attachment att = new Attachment();
            att.Id = picId;
            attachmentsToDelete.add(att);
        }

        delete attachmentsToDelete;
    }

    @AuraEnabled
    public static void saveAirplane(Attachment mainPictureAtt, String recordId, List<Attachment> attachmentsToDelete, List<String> picturesToUpload, String pictureMain) {
        System.debug('In save airplane');
        List<Attachment> att = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
        if (!att.isEmpty()) {
            att[0].Name = 'attachment';
            update att;
        }

        List<Attachment> pictureAttachments = new List<Attachment>();
        for (String picture : picturesToUpload) {
            Attachment picAttachment = new Attachment();
            picAttachment.ParentId = String.valueOf(recordId);
            picAttachment.Body = EncodingUtil.base64Decode(picture.substring(picture.indexOf(',') + 1));
            picAttachment.Name = 'picAttachment';
            pictureAttachments.add(picAttachment);
        }

        upsert pictureAttachments;

        System.debug('pictures to upload length = ' + picturesToUpload.size());

        if (!attachmentsToDelete.isEmpty()) {
            delete attachmentsToDelete;
        }

        if (mainPictureAtt == null) {
            Attachment mainPicAttachment = new Attachment();
            mainPicAttachment.ParentId = String.valueOf(recordId);
            mainPicAttachment.Body = EncodingUtil.base64Decode(pictureMain.substring(pictureMain.indexOf(',') + 1));
            mainPicAttachment.Name = 'main';
            upsert mainPicAttachment;
        } else {
            Attachment toBeMain = [SELECT Id, Name FROM Attachment WHERE Id = :mainPictureAtt.Id];
            toBeMain.Name = 'main';
            update toBeMain;
        }
    }

    public class PictureFile
    {
        @AuraEnabled public String theData { get; set; }
        @AuraEnabled public String base64Data { get; set; }
        @AuraEnabled public String fileName { get; set; }
        @AuraEnabled public String contentType { get; set; }
    }

}