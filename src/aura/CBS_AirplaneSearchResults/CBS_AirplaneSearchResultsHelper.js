({
    doInit : function(component) {
        component.set("v.searched", false);
        let action = component.get("c.getNewestAirplanes");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.airplanes", response.getReturnValue());
            } else {
                let errors = response.getError()[0];
                let errorData = JSON.parse(errors.message);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": errorData.name,
                    "message": errorData.message
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
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
})