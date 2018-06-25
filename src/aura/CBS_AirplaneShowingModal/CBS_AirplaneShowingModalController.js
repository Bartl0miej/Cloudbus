({
    onInit : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);
        let action = component.get("c.getPrototypesOfAirplaneType");
        action.setParams({"typeId" : component.get("v.planeId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let tPlanesPrototypes = response.getReturnValue();
                component.set("v.airplanePrototypes", tPlanesPrototypes);
                component.set("v.tAirplaneName", tPlanesPrototypes[0].airplane.Name);
                if (tPlanesPrototypes.length == 1) {
                    component.set("v.airplaneSelected", true);
                    component.set("v.selectedAirplaneForShowing", tPlanesPrototypes[0]);
                }
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },

    onSelectedAirplaneUpdate : function(component, event, helper) {
        component.set("v.airplaneSelected", true);
        let selAirplane = event.getParam("chosenAirplane");
        component.set("v.selectedAirplaneForShowing", selAirplane);
    },

    addClass : function (component, event, helper) {
        let selectedItem = event.currentTarget;
        let aPrototypeId = selectedItem.dataset.id;
        let aPrototypes = component.find('listItem');

        for(let i = 0; i< aPrototypes.length; i++) {
            let tempId = aPrototypes[i].getElement().getAttribute('data-id');

            if (tempId != aPrototypeId) {
               $A.util.removeClass(aPrototypes[i], 'itemSelected');
            } else {
                $A.util.addClass(aPrototypes[i], 'itemSelected');
            }
        }
    },

    addRequestedShowing : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        let tUserId = $A.get('$SObjectType.CurrentUser.Id');
        let date = component.get("v.showingDate");
        let pDate = new Date(date);
        let tPlane = component.get("v.selectedAirplaneForShowing");

        let d1 = +new Date();
        let d2 = +new Date(date);

        if (!date) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Select_date"), $A.get("$Label.c.CBS_Please_select_date_for_showing"));
            return;
        }

        if (d2 - d1 < 0) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Select_future_date"), $A.get("$Label.c.CBS_Please_select_date_for_showing_which_is_in_the_future"));
            return;
        }

        theSpinner.showSpinner(component);
        let action = component.get("c.putShowingInSessionCache");
        action.setParams({"uId" : tUserId, "aircraft" : tPlane.airplane, "dateTimeInfo" : date});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Requested_for_showing"), tPlane.airplane.Name + " " + $A.get("$Label.c.CBS_added_to_requested_showings_cart"));
                let returnedShowings = response.getReturnValue();
                let showingsEvent = $A.get("e.c:CBS_AirplaneAddShowingEvent");
                showingsEvent.setParams({"userListOfShowings" : returnedShowings});
                showingsEvent.fire();
                component.set("v.airplaneSelected", false);
                component.set("v.showingDate", null);
                let evt = component.getEvent('CBS_AirplaneShowingModalCloseEvent');
                evt.fire();
            } else {
                let errorMsg = response.getError()[0];
                helper.showToast(component, "Error", $A.get("$Label.c.CBS_Can_t_request_showing"), errorMsg.message);
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },

    closeShowingModal : function(component, event, helper) {
        let evt = component.getEvent('CBS_AirplaneShowingModalCloseEvent');
        evt.fire();
    }
})