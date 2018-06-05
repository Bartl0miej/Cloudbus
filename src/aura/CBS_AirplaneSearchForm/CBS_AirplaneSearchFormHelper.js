({
    showErrorToast : function(component, theError) {
        let errorData = JSON.parse(theError.message);
        this.showToast(component, "Error", errorData.name, errorData.message);
    },

    showToast : function(component, type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
})