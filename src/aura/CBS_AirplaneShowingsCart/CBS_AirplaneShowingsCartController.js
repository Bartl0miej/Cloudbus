({
    onInit : function(component, event, helper) {
        let action = component.get("c.getUserShowingFromCache");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let showings = response.getReturnValue();
                component.set("v.showings", showings);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    onAddShowingEvent : function(component, event, helper) {
        let cachedSessions = event.getParam('userListOfShowings');
        component.set("v.showings", cachedSessions);
    },

    onShowingRemove : function(component, event, helper) {
        let sIndex = event.getParam("indexInList");
        let action = component.get("c.removeShowing");
        action.setParams({"showingIndex" : sIndex});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Removed"), $A.get("$Label.c.CBS_Successfully_removed_showing_from_the_list"));
                let showings = response.getReturnValue();
                component.set("v.showings", showings);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    clearAllShowings : function(component, event, helper) {
        let action = component.get("c.removeUserShowings");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Cleared"), $A.get("$Label.c.CBS_Successfully_removed_all_requested_showings_from_the_list"));
                component.set("v.showings", []);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    createShowingsEvent : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);
        let tUserId = $A.get('$SObjectType.CurrentUser.Id');
        let action = component.get("c.createEventsFromShowings");
        action.setParams({"uId" : tUserId});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let evt = $A.get('e.c:CBS_AirplaneShowingsAddedEvent');
                evt.fire();
                component.set("v.showings", []);
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Success"), $A.get("$Label.c.CBS_Successfully_requested_showings"));
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },
})