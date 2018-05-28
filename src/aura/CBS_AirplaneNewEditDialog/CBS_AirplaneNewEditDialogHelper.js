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
            console.log('in read file');
            var dataURL = reader.result;
            let atts = component.get("v.pictures");
            let att = {theData : dataURL};
            att.base64Data = dataURL.match(/,(.*)$/)[1];
            att.fileName = file.name;
            att.contentType = file.type;
            //console.log(att.theFile.name);
            let theAttachment = dataURL;
            atts.push(theAttachment);
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
            console.log('dataURL: ' + dataURL);
            //helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
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
    },

    saveRecord : function(component) {
/*        let tempRec = component.find('forceRecord');
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            let resultToast = $A.get("e.force:showToast");
            if(result.state === 'SUCCESS') {
                resultToast.setParams({
                    "title": "Saved",
                    "message": "The record was saved.",
                    "type": 'success'
                });
                resultToast.fire();
                let recId = result.recordId;
                helper.navigateTo(component, recId);
                let airplaneEditedEvent = $A.get("e.c:CBS_AirplaneEdited");
                airplaneEditedEvent.fire();
            } else if (result.state === "ERROR") {
                console.log('ERROR: ' + JSON.stringify(result.error));
                resultToast.setParams({
                    "title": "Error",
                    "message": "There was an error saving the record: " + JSON.stringify(result.error),
                    "type": 'error'
                });
                resultToast.fire();
                let recId = result.recordId;
                helper.navigateTo(component, recId);
            } else {
                console.log('Unknown problem, state: ' + result.state + ', error: ' + JSON.stringify(result.error));
            }
        }*/
        }
})