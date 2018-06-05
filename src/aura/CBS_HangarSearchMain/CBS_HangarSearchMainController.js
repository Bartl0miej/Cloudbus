({
    handleHangarSelect : function(component, event, helper) {
        let sHangar = event.getParam("chosenHangar");
        component.set("v.selectedHangar", sHangar);
    },

    handleSearchClear : function(component, event, helper) {
        component.set("v.selectedHangar", undefined);
    },

    handleCoordinates : function(component, event, helper) {
        let coordinatesList = event.getParam("hangarsCoordinates");
        component.set("v.theCoordinates", coordinatesList);
    }
})