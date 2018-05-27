({
    onSearch : function(component, event, helper) {
        let thePlanes = event.getParam('airplanes');
        console.log('onsearch: ' + thePlanes.length);
        component.set("v.airplanes", thePlanes);
    }
})