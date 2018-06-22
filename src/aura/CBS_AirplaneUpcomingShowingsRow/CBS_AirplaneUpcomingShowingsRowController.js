({
    onInit : function(component, event, helper) {
        let number = component.get("v.view.Airplane_Type__r.Price_after_Discount__c");
        number = (number).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
        component.set("v.suggestedPrice", number);
    },

    onAirplaneClick : function(component, event, helper) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.view.Airplane_Type__c")
        });
        navEvt.fire();
    }
})