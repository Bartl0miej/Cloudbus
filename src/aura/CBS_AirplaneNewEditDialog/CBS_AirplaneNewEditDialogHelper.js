({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },

    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
    		let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "Image file not supported."
            });
            toastEvent.fire();
    	}
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            let atts = component.get("v.pictures");
            let att = {theData : dataURL};
            att.base64Data = dataURL.match(/,(.*)$/)[1];
            att.fileName = file.name;
            att.contentType = file.type;
            //console.log(att.theFile.name);
            atts.push(att);
            for (let i = 0; i < atts.length; i++) {
                console.log('id is: ' + atts[i].Id);
            }
            component.set("v.pictures", atts);
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Success",
                "title": "Image added",
                "message": "Image successfully added to gallery."
            });
            toastEvent.fire();
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
    },

    upload: function(component, file, base64Data) {
        let action = component.get("c.saveAttachment");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data,
            contentType: file.type
        });
        action.setCallback(this, function(response) {
            component.set("v.message", "Image uploaded");
            let att = {};
            let attId = response.getReturnValue();
            att.Id = attId;
            let attsToCancel = component.get("v.attachmentsToCancel");
            attsToCancel.push(att.Id);
            component.set("v.attachmentsToCancel", attsToCancel);
            let theAttachments = component.get("v.attachments");
            theAttachments.push(att);
            component.set("v.attachments", theAttachments);
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action);
    }
})