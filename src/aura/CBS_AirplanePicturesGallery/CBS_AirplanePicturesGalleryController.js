({
    doInit : function(component, event, helper) {
            let action = component.get("c.getAttachments");
            action.setParams({"recordId" : component.get("v.recordId")});
            action.setCallback(this, function(response) {
               let state = response.getState();
               if (state === "SUCCESS") {
                    let listOfAttachmentIds = response.getReturnValue();
                    console.log('in callback');
                    component.set("v.attachments", listOfAttachmentIds);
                    console.log(listOfAttachmentIds);
                    console.log('after');
                    for (let i = 0; i < listOfAttachmentIds.length; i++) {
                        console.log('attachment: ' + listOfAttachmentIds[i]);
                    }
               } else {
                   console.log('failed with state: ');
                   console.log(response.getError());
               }
            });

            $A.enqueueAction(action);
    }
})