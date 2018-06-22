({
    airplaneSelected : function(component, event, helper) {
        let selAirplane = component.get("v.airplane");
        console.log('selAirplane.Id = ' + selAirplane.Id);
        let selectEvent = component.getEvent("CBS_SelectedAirplaneUpdate");
        selectEvent.setParams({"chosenAirplane" : selAirplane});
        selectEvent.fire();
    }
})