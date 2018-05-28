({
    doInit : function(component, event, helper) {
        let action = component.get("c.getAttachmentWrappers");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let listOfAttachmentIds = response.getReturnValue();
                let mainPict = listOfAttachmentIds.mainPicture;
                console.log('picId = ' + mainPict.Id);
                listOfAttachmentIds = listOfAttachmentIds.attachments;
                console.log(mainPict.Id);
                component.set("v.mainPicId", mainPict.Id);
                console.log('in callback');
                component.set("v.attachments", listOfAttachmentIds);
                console.log(listOfAttachmentIds);
                console.log('after');
                for (let i = 0; i < listOfAttachmentIds.length; i++) {
                    console.log('attachment: ' + listOfAttachmentIds[i]);
                }
            } else if (state === "ERROR") {
                let errors = response.getError()[0];
                let errorData = JSON.parse(errors.message);
                console.log(errorData.name + ": " + errorData.message);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": errorData.name,
                    "message": errorData.message
                });
            }
        });
        $A.enqueueAction(action);
    }
})