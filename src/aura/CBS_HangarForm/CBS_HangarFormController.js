({
    searchForHangar : function(component, event, helper) {
        let theSpinner = component.find("spinner");

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
            theSpinner.showSpinner(component);
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue().length == 0) {
                        helper.showToast(component, "Warning", $A.get("$Label.c.CBS_No_hangars"), $A.get("$Label.c.CBS_No_hangars_found"));
                        theSpinner.hideSpinner();
                        return;
                    } else if (response.getReturnValue().length == 1) {
                        let selHangar = response.getReturnValue()[0].hangar;
                        let selectEvent = component.getEvent("selectHangar");
                        selectEvent.setParams({"chosenHangar" : selHangar});
                        selectEvent.fire();
                    }

                    let hangarsRtn = [];
                    for (let i = 0; i < response.getReturnValue().length; i++) {
                        hangarsRtn.push(response.getReturnValue()[i].hangar);
                    }
                    component.set("v.hangars", hangarsRtn);
                    let sendCoordinatesEvent = component.getEvent("sendCoordinates");
                    sendCoordinatesEvent.setParams({"hangarsCoordinates": response.getReturnValue()});
                    sendCoordinatesEvent.fire();
                    theSpinner.hideSpinner();
                } else if (state === "ERROR") {
                    let errors = response.getError()[0];
                    helper.showErrorToast(component, errors);
                    theSpinner.hideSpinner();
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

        let sendCoordinatesEvent = component.getEvent("sendCoordinates");
        sendCoordinatesEvent.setParams({"hangarsCoordinates": new Array()});
        sendCoordinatesEvent.fire();
    },
})