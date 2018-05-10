({
    hangarSelected : function(component, event, helper) {

        let clearSelectedEvent = component.getEvent("clearSelected");
        clearSelectedEvent.fire();

        let selHangar = component.get("v.hangar");
        //component.set("v.selectedItemId", selHangar.Id);
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
            } else {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})