({
    onAirplaneClick : function(component, event, helper) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.upcomingShowing.Airplane_Type__c")
        });
        navEvt.fire();
    }
})