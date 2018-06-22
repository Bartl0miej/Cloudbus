({
    onInit : function(component, event, helper) {
        let action = component.get("c.getUserShowingFromCache");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let showings = response.getReturnValue();
                component.set("v.manageView", showings);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    onAddShowingEvent : function(component, event, helper) {
        let cachedSessions = event.getParam('userListOfShowings');
        component.set("v.manageView", cachedSessions);
    },

    onShowingRemove : function(component, event, helper) {
        let sIndex = event.getParam("indexInList");
        console.log('sIndex = ' + sIndex);
        let action = component.get("c.removeShowing");
        action.setParams({"showingIndex" : sIndex});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", "Removed", "Successfully removed showing from the list.");
                let showings = response.getReturnValue();
                component.set("v.manageView", showings);
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
            console.log('state');
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", "Cleared", "Successfully removed all requested showings from the list.");
                component.set("v.manageView", []);
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
            console.log('state');
            if (state === "SUCCESS") {
                let evt = $A.get('e.c:CBS_AirplaneShowingsAddedEvent');
                evt.fire();
                component.set("v.manageView", []);
                helper.showToast(component, "Success", "Success", "Successfully requested showings");
            } else {
                alert('error');
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);

    },
})