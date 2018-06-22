({
    onInit : function(component, event, helper) {
        helper.doInit(component);
    },

    onSearch : function(component, event, helper) {
        let thePlanes = event.getParam('airplaneWrappers');
        component.set("v.airplanes", thePlanes);
        component.set("v.searched", true);
    },

    onClear : function(component, event, helper) {
        helper.doInit(component);
    },

    navigateToAirplaneRecord : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let planeId = selectedItem.dataset.id;

        let navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParam("recordId", planeId);
        navEvent.fire();
    },

    openShowingModal : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let planeId = selectedItem.dataset.id;
        component.set("v.tPlaneId", planeId);
        component.set("v.isShowingModalOpen", true);
    },

    onAirplaneShowingModalClose : function(component, event, helper) {
        component.set("v.isShowingModalOpen", false);
    }
})