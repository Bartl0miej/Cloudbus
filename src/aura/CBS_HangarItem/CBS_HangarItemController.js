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
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },
})