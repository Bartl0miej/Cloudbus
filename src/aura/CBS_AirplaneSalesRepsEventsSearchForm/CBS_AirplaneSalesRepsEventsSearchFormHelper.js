({
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

    clearForm : function(component) {
        let reps = component.get("v.salesReps");
        component.set("v.salesReps", []);
        component.set("v.salesReps", reps);
        let contacts = component.get("v.eContacts");
        component.set("v.eContacts", []);
        component.set("v.eContacts", contacts);
        let orderOpts = component.get("v.orderOptions");
        component.set("v.orderOptions", []);
        component.set("v.orderOptions", orderOpts);
        component.set("v.event", {'sobjectType' : 'Event'});
        component.set("v.startDate", null);
        component.set("v.endDate", null);
        let clearedEvent = $A.get("e.c:CBS_AirplaneEventsCleared");
        clearedEvent.fire();
    }
})