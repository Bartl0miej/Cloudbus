({
    searchForAirplane : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        //let clearEvent = component.getEvent("clearSearch");
        //clearEvent.fire();
        let searchedAirplane = component.get("v.searchedAirplane");
        if (searchedAirplane.Name == '' && searchedAirplane.Number_of_Seats__c == null) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Warning",
                "title": "No criteria",
                "message": "Please specify at least one search criteria."
            });
            toastEvent.fire();
            theSpinner.hideSpinner();
            return;
        }

        let action = component.get("c.searchAirplanes");
        action.setParams({"searchedAirplane" : searchedAirplane});
        theSpinner.showSpinner(component);
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                if (response.getReturnValue().length == 0) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Warning",
                        "title": "No airplanes",
                        "message": "No airplanes has beeen found using specified criteria."
                    });
                    toastEvent.fire();
                    theSpinner.hideSpinner();
                    return;
                }

                let planes = response.getReturnValue();
                for (let i = 0; i < planes.length; i++) {
                    console.log(planes[0].Name);
                }
                component.set("v.airplanes", planes);
                let searchedAirplaneEvent = $A.get('e.c:CBS_AirplaneSearchedEvent');
                searchedAirplaneEvent.setParam("airplaneWrappers", planes);
                searchedAirplaneEvent.fire();

                theSpinner.hideSpinner();
            } else if (state === "ERROR") {
                console.log('error');
                let errors = response.getError();
                if (errors) {
                    for (let i = 0; i < errors.length; i++) {
                        for (let j = 0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                        }

                        if (errors[i].fieldErrors) {
                            for (let fieldError = 0; fieldError < errors[i].fieldErrors.length; fieldError++) {
                                let thisFieldError = errors[i].fieldErrors[fieldError];
                                for (let j = 0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }

                        if (errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                } else {
                    message += (message.length > 0 ? '\n' : '') + 'Unknown error';
                }
                theSpinner.hideSpinner();
                alert('Errors with server-side action:\n' + message);
            }
        });

        $A.enqueueAction(action);
    },

    clear : function(component, event, helper) {
        component.set("v.searchedHangar", {'sobjectType': 'CBS_Hangar__c', 'Name' : '', 'E_mail__c' : '', 'Country__c' : '', 'City__c' : ''});
        component.set("v.hangars", []);
        let clearEvent = component.getEvent("clearSearch");
        clearEvent.fire();

        let sendCoordinatesEvent = component.getEvent("sendCoordinates");
        sendCoordinatesEvent.setParams({"hangarsCoordinates": new Array()});
        sendCoordinatesEvent.fire();
    },
})