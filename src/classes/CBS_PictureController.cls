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
        List<Attachment> atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
        if (!atts.isEmpty()) {
            aWrapper.mainPicture = atts.get(0);
            System.debug('--- ' + aWrapper.mainPicture.Id);
        } else {
            aWrapper.mainPicture = null;
        }
        aWrapper.attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name != 'main'];

        return aWrapper;
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
    public static void saveAirplane(Attachment mainPictureAtt, String recordId, List<Attachment> attachmentsToDelete, String picturesToUpload) {
        System.debug('In save airplane');
        List<Attachment> att = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId AND Name = 'main' LIMIT 1];
        if (!att.isEmpty()) {
            att[0].Name = 'attachment';
            update att;
        }

        System.debug('pictures to upload = ' + picturesToUpload);

        if (!attachmentsToDelete.isEmpty()) {
            delete attachmentsToDelete;
        }

        //List<PictureFile> pictureFiles = (List<PictureFile>)JSON.deserialize(picturesToUpload, List<PictureFile>.class);

        //List<Attachment> picturesToAttachments = new List<Attachment>();
        //for (PictureFile pic : pictureFiles) {
            //System.debug('pic.Name: ' + pic.fileName);
//            Attachment newAttachment = new Attachment();
//            newAttachment.parentId = String.valueOf(recordId);
//            newAttachment.body = EncodingUtil.base64Decode(pic.base64Data);
//            newAttachment.name = pic.fileName;
//            newAttachment.contentType = pic.contentType;
//            picturesToAttachments.add(newAttachment);
 //       }

        //insert picturesToAttachments;


        if (mainPictureAtt == null) {
            return;
        }

        if (mainPictureAtt != null) {
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