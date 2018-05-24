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
            let att = {theData : dataURL, theFile : file};
            att.baseSixtyFour = att.theData.match(/,(.*)$/)[1];
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
        action.setCallback(this, function(a) {
            component.set("v.message", "Image uploaded");
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action);
    }
})