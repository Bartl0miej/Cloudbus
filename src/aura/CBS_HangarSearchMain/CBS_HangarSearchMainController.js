({
    handleHangarSelect : function(component, event, helper) {
        let sHangar = event.getParam("chosenHangar");
        component.set("v.selectedHangar", sHangar);
        console.log('Main App selected hangar:');
        console.log(sHangar.Name);
    },

    handleSearchClear : function(component, event, helper) {
        component.set("v.selectedHangar", undefined);
    },

    handleCoordinates : function(component, event, helper) {
        let coordinatesList = event.getParam("hangarsCoordinates");
        for (let i = 0; i < coordinatesList.length; i++) {
            console.log(coordinatesList[i].latitude);
        }
        component.set("v.theCoordinates", coordinatesList);
    }
})