({
    searchForHangar : function(component, event, helper) {
        let validHangar = component.find('searchform').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (validHangar) {
            let searchedHangar = component.get("v.searchedHangar");
/*            console.log('Searched hangar:');
            console.log(searchedHangar);*/
            let action = component.get("c.searchHangars");
            action.setParams({"searchedHangar" : searchedHangar});
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.hangars", response.getReturnValue());
/*                    console.log("Returned hangars: ");
                    console.log(response.getReturnValue());
                    console.log("v.hangars = ");
                    console.log(component.get("v.hangars"));*/
/*                    if (component.get("v.hangars").length > 0) {
                        document.getElementById('resultsDiv').style.visibility = 'visible';
                    }*/
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
        /*document.getElementById('resultsDiv').style.visibility = 'hidden';*/
    }
})