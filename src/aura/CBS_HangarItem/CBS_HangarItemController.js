({
    hangarSelected : function(component, event, helper) {
        let selHangar = component.get("v.hangar");
        console.log(selHangar.Name);
        let selectEvent = component.getEvent("selectHangar");
        selectEvent.setParams({"chosenHangar" : selHangar});
        selectEvent.fire();
    }
})