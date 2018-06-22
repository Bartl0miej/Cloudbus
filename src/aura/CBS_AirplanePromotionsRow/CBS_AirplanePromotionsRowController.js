({
    callDeletePromotion : function(component, event, helper) {
        component.set("v.toDelete", true);
        let evt = component.getEvent("CBS_AirplaneAddPromotionToDeleteList");
        evt.setParam("promotionObj" , component.get("v.tPBEntrty"));
        evt.fire();
    }
})