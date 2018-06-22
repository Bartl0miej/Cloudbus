({
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        component.set("v.hasPrevious", false);
    },

    prevPage: function(component, event, helper) {
        let pageNumber = Math.max(component.get("v.currentPageNumber") - 1, 1);
        component.set("v.currentPageNumber", pageNumber);
    },

    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber") + 1, component.get("v.maxPageNumber")));
    },

    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    }
})