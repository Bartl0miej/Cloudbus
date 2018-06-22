({
    searchForAirplane : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        let searchedAirplane = component.get("v.searchedAirplane");
        if (searchedAirplane.Name == '' && searchedAirplane.Number_of_Seats__c == null) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_No_criteria"), $A.get("$Label.c.CBS_Please_specify_at_least_one_search_criteria"));
            theSpinner.hideSpinner();
            return;
        }

        let action = component.get("c.searchAirplanes");
        action.setParams({"searchedAirplane" : searchedAirplane});
        theSpinner.showSpinner(component);
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue().length == 0) {
                    theSpinner.hideSpinner();
                    helper.showToast(component, "Warning", $A.get("$Label.c.CBS_No_airplanes"), $A.get("$Label.c.CBS_No_airplanes_found_using_criteria"));
                    return;
                }

                let planes = response.getReturnValue();
                component.set("v.airplanes", planes);
                let searchedAirplaneEvent = $A.get('e.c:CBS_AirplaneSearchedEvent');
                searchedAirplaneEvent.setParam("airplaneWrappers", planes);
                searchedAirplaneEvent.fire();
            } else if (state === "ERROR") {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            } else {
                helper.showToast("Error", $A.get("$Label.c.CBS_Error"), $A.get("$Label.c.CBS_Errors_with_server_side_action"));
            }

            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },

    clear : function(component, event, helper) {
        component.set("v.searchedAirplane", {'sobjectType' : 'Airplane_Type__c', 'Name' : '', 'Engines_Number__c' : '', 'Number_of_Seats__c' : null});

        let clearEvent = $A.get("e.c:CBS_AirplaneClearSearch");
        clearEvent.fire();
    },
})