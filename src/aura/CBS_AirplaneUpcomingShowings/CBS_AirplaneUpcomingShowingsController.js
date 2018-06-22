({
    onInit : function(component, event, helper) {
        let tUserId = $A.get('$SObjectType.CurrentUser.Id');
        let action = component.get("c.getUpcomingUserEvents");
        action.setParams({"uId" : tUserId});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let rValue = response.getReturnValue();
                component.set("v.manageView", rValue);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },
})