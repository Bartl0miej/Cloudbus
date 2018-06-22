({
    onInit : function(component, event, helper) {
        let action = component.get("c.getUpcomingRepsEvents");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.searched", false);
                let wrapper = response.getReturnValue();
                let evts = wrapper.events;
                let recordsPerPage = wrapper.eventsPerPage;
                component.set("v.repEventsPerPage", recordsPerPage);
                component.set("v.salesRepsEvents", evts);
                component.set("v.upcomingEvents", evts);
                component.set("v.maxPage", Math.floor((evts.length + recordsPerPage - 1) / recordsPerPage));
                helper.renderPage(component);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    onEventsSearched : function(component, event, helper) {
        let recordsPerPage = component.get("v.repEventsPerPage");
        let tEvents = event.getParam('theEvents');
        component.set("v.salesRepsEvents", tEvents);
        component.set("v.searched", true);
        component.set("v.pageNumber", 1);
        component.set("v.maxPage", Math.floor((tEvents.length + recordsPerPage - 1) / recordsPerPage));
        helper.renderPage(component);
    },

    onEventsCleared : function(component, event, helper) {
        let upEvents = component.get("v.upcomingEvents");
        component.set("v.salesRepsEvents", upEvents);
        component.set("v.searched", false);
        helper.renderPage(component);
    },

    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
})
 