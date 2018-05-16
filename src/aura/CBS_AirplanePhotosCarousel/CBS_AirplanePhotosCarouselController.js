({
    doInit : function(component, event, helper) {
            /*component.set("v.renderCarousel", false);*/
            let action = component.get("c.getAttachments");
            action.setParams({"recordId" : component.get("v.recordId")});
            action.setCallback(this, function(response) {
               let state = response.getState();
               if (state === "SUCCESS") {
                    /*let listOfAttachmentIds = response.getReturnValue();
                    console.log('in callback');
                    console.log(listOfAttachmentIds);
                    component.set("v.attachments", listOfAttachmentIds);*/
                    /*component.set("v.renderCarousel", true);*/
               } else {
                   console.log('failed with state: ');
                   console.log(response.getError());

               }
            });

            $A.enqueueAction(action);
        }
})