({
    searchForHangar : function(component, event, helper) {
        let validHangar = component.find('searchform').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (validHangar) {
            let clearEvent = component.getEvent("clearSearch");
            clearEvent.fire();
            let searchedHangar = component.get("v.searchedHangar");
            let action = component.get("c.searchHangars");
            action.setParams({"searchedHangar" : searchedHangar});
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.hangars", response.getReturnValue());
                    if (response.getReturnValue().length == 0) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Warning",
                            "title": "No records.",
                            "message": "No records found using specified criteria."
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);

        }
    },

    clear : function(component, event, helper) {
        component.set("v.searchedHangar", {'sobjectType': 'CBS_Hangar__c', 'Name' : '', 'E_mail__c' : '', 'Country__c' : '', 'City__c' : ''});
        component.set("v.hangars", []);
        let clearEvent = component.getEvent("clearSearch");
        clearEvent.fire();
    }
})