({
    navigateTo : function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
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

    setMainPicture : function(component, isAttachment, attachmentId, theData, hasMain) {
        let mainPic = {};
        mainPic.isAttachment = isAttachment;
        mainPic.Id = attachmentId;
        mainPic.theData = theData;
        mainPic.hasMain = hasMain;
        component.set("v.mainPicture", mainPic);
    },

    readFile : function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            this.showToast(component, "Error", "Not supported", "Image file not supported.");
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
        this.showToast(component, "Success", "Image added", "Image successfully added to gallery.");
        reader.readAsDataURL(file);
    },
})