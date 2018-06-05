({
    onInit : function(component, event, helper) {
        component.set("v.airplanes", []);
    },

    onSearch : function(component, event, helper) {
        let thePlanes = event.getParam('airplaneWrappers');
        component.set("v.airplanes", thePlanes);
    },

    onClear : function(component, event, helper) {
        component.set("v.airplanes", []);
    },

    navigateToAirplaneRecord : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let planeId = selectedItem.dataset.id;

        let navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParam("recordId", planeId);
        navEvent.fire();
    }
})