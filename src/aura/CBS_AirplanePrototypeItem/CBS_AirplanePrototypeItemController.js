({
    airplaneSelected : function(component, event, helper) {
        let selAirplane = component.get("v.airplane");
        let selectEvent = component.getEvent("CBS_SelectedAirplaneUpdate");
        selectEvent.setParams({"chosenAirplane" : selAirplane});
        selectEvent.fire();
    }
})