({
    onInit : function(component, event, helper) {
        let planes = [];
        component.set("v.airplanes", planes);
    },

    onSearch : function(component, event, helper) {
        let thePlanes = event.getParam('airplaneWrappers');
        console.log('thePlanes');
        console.log(thePlanes);
        component.set("v.airplanes", thePlanes);
    }
})