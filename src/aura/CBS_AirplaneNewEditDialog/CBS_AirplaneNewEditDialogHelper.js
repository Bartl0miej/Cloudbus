({
    navigateTo : function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },

    showErrorToast : function(component, theError) {
        let errorData = JSON.parse(theError.message);
        this.showToast(component, "Error", errorData.name, errorData.message);
    },

    showToast : function(component, type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    createMainPicture : function(component, isAtt, attId, mainPicData, hasMainPicture) {
        let mainPic = {};
        mainPic.isAttachment = isAtt;
        mainPic.Id = attId;
        mainPic.theData = mainPicData;
        mainPic.hasMain = hasMainPicture;
        component.set("v.mainPicture", mainPic);
    },

    setMainPicture : function(component, tId, isAttachment) {
        let mainBeforeChange = component.get("v.mainPicture");
        let attachmentsList = component.get("v.attachments");
        let picsList = component.get("v.pictures");

        if (isAttachment) {
            this.createMainPicture(component, true, attachmentsList[tId].Id, null, true);
            attachmentsList.splice(tId, 1);
        } else {
            this.createMainPicture(component, false, null, picsList[tId], true);
            picsList.splice(tId, 1);
        }

        component.set("v.attachments", attachmentsList);
        component.set("v.pictures", picsList);
        if (!mainBeforeChange.hasMain) {
            return;
        }

        if (mainBeforeChange.isAttachment) {
            attachmentsList.push(mainBeforeChange);
            component.set("v.attachments", attachmentsList);
        } else {
            let tData = mainBeforeChange.theData;
            picsList.push(tData);
            component.set("v.pictures", picsList);
        }
    },

    readFile : function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            this.showToast(component, "Error", $A.get("$Label.c.CBS_Not_supported"), $A.get("$Label.c.CBS_Image_file_not_supported"));
            return;
    	}
        let reader = new FileReader();
        reader.onloadend = function() {
            let dataURL = reader.result;
            let atts = component.get("v.pictures");
            let theAttachment = dataURL;
            atts.push(theAttachment);
            component.set("v.pictures", atts);
        };
        this.showToast(component, "Success", $A.get("$Label.c.CBS_Image_added"), $A.get("$Label.c.CBS_Image_added_to_gallery"));
        reader.readAsDataURL(file);
    },

    getMainAndWrappers : function(component, planeId) {
        let action = component.get("c.getAttachmentWrappers");
        action.setParams({"recordId" : planeId});
        action.setCallback(this, function(response) {
            let attWrappers = response.getReturnValue();
        });

        $A.enqueueAction(action);
    }
})