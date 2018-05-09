({
    handleHangarSelect : function(component, event, helper) {
        let sHangar = event.getParam("chosenHangar");
        component.set("v.selectedHangar", sHangar);
        console.log('Main App selected hangar:');
        console.log(sHangar.Name);
    },

    handleSearchClear : function(component, event, helper) {
        component.set("v.selectedHangar", undefined);
    }
})