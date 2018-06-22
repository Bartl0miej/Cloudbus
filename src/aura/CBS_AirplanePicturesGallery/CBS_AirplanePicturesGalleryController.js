({
    doInit : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);
        let action = component.get("c.getAttachmentWrappers");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let listOfAttachmentWrappers = response.getReturnValue();
                let mainPict = listOfAttachmentWrappers.mainPicture;
                let listOfAttachments = listOfAttachmentWrappers.attachments;
                component.set("v.mainPicId", mainPict.Id);
                component.set("v.attachments", listOfAttachments);
            } else if (state === "ERROR") {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }

            theSpinner.hideSpinner(component);
        });
        $A.enqueueAction(action);
    }
})