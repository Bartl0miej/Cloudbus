({
    callDeleteShowing : function(component, event, helper) {
        let theIndex = component.get("v.tIndex");
        let removeEvent = component.getEvent("CBS_AirplaneShowingRemovedFromList");
        removeEvent.setParams({"indexInList" : theIndex});
        removeEvent.fire();
    },
})