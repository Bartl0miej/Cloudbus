({
    hangarSelected : function(component, event, helper) {
        let selHangar = component.get("v.hangar");
        selHangar.isActive = true;
        component.set("v.hangar", selHangar);
        let selectEvent = component.getEvent("selectHangar");
        selectEvent.setParams({"chosenHangar" : selHangar});
        selectEvent.fire();
        let action = component.get("c.getHangarWrapper");
        action.setParams({"hangarToFind" : selHangar});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let hangarLatLong = response.getReturnValue();
                let sendCoordinatesEvent = component.getEvent("sendCoordinates");
                sendCoordinatesEvent.setParams({"hangarsCoordinates": hangarLatLong});
                sendCoordinatesEvent.fire();
            } else if (state === "ERROR") {
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
                alert('Errors with server-side action:\n' + message);
            }
        });

        $A.enqueueAction(action);
    },
})