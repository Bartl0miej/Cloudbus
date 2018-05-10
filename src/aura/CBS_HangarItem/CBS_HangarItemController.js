({
    hangarSelected : function(component, event, helper) {
        let selHangar = component.get("v.hangar");
        /*console.log(selHangar.Name);
        let selectEvent = component.getEvent("selectHangar");
        selectEvent.setParams({"chosenHangar" : selHangar});
        selectEvent.fire();

/*        let sendCoordinatesEvent = component.getEvent("sendCoordinates");



        sendCoordinatesEvent.setParams({"hangarsCoordinates": selHangar});
        sendCoordinatesEvent.fire();*/

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



/*                console.log(response.getReturnValue().length);
                let hangarsRtn = [];
                for (let i = 0; i < response.getReturnValue().length; i++) {
                    console.log(response.getReturnValue()[i].hangar);
                    hangarsRtn.push(response.getReturnValue()[i].hangar);
                    console.log('latitude: ' + response.getReturnValue()[i].latitude);
                    console.log(response.getReturnValue()[i].longitude);

                }
                component.set("v.hangars", hangarsRtn);
                if (response.getReturnValue().length == 1) {
                    let selHangar = response.getReturnValue()[0].hangar;
                    let selectEvent = component.getEvent("selectHangar");
                    selectEvent.setParams({"chosenHangar" : selHangar});
                    selectEvent.fire();
                }
                if (response.getReturnValue().length == 0) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Warning",
                        "title": "No records.",
                        "message": "No records found using specified criteria."
                    });
                    toastEvent.fire();
                }

                let sendCoordinatesEvent = component.getEvent("sendCoordinates");

                console.log('sendcoordinatesevent = ');
                console.log(sendCoordinatesEvent);

                sendCoordinatesEvent.setParams({"hangarsCoordinates": response.getReturnValue()});
                sendCoordinatesEvent.fire();
                console.log("sendCoordinatesevent........")*/


    }
})