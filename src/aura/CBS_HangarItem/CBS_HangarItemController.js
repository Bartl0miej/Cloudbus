({
    func : function(component, event, helper) {
        let hang = component.get("v.hangar");
        console.log(hang.Id);
        component.set("v.selectedHangar", hang);
    }
})