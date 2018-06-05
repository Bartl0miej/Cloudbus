({
    openModal : function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    saveAirplaneDatatable : function(component, event, helper) {
        let saveEvent = $A.get("e.c:CBS_AirplaneSaveEvent");
        saveEvent.fire();
    },
})