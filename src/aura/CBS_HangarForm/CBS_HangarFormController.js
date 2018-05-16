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
            helper.showSpinner(component);
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let hangarsRtn = [];
                    for (let i = 0; i < response.getReturnValue().length; i++) {
                        hangarsRtn.push(response.getReturnValue()[i].hangar);
                    }
                    component.set("v.hangars", hangarsRtn);
                    if (response.getReturnValue().length == 1) {
                        let selHangar = response.getReturnValue()[0].hangar;
                        let selectEvent = component.getEvent("selectHangar");
                        selectEvent.setParams({"chosenHangar" : selHangar});
                        selectEvent.fire();
                    }
                    //else
                    if (response.getReturnValue().length == 0) {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Warning",
                            "title": $A.get("$Label.c.CBS_No_hangars"),
                            "message": $A.get("$Label.c.CBS_No_hangars_found")
                        });
                        toastEvent.fire();
                        return;
                    }

                    let sendCoordinatesEvent = component.getEvent("sendCoordinates");
                    sendCoordinatesEvent.setParams({"hangarsCoordinates": response.getReturnValue()});
                    sendCoordinatesEvent.fire();
                    helper.hideSpinner(component);
                } else {
                    //obsluga
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

        let sendCoordinatesEvent = component.getEvent("sendCoordinates");
        sendCoordinatesEvent.setParams({"hangarsCoordinates": new Array()});
        sendCoordinatesEvent.fire();
    },
})