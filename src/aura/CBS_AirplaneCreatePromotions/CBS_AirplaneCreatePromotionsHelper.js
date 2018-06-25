({
    clearPromotionForm : function(component) {
        component.set("v.discount", null);
        component.set("v.startDate", null);
        component.set("v.endDate", null);
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

    refreshAirplanes : function(component) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);

        let action = component.get("c.getAirplanesWithPromotions");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrappers", response.getReturnValue());
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    }
})