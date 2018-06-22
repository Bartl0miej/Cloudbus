({
    onInit : function(component, event, helper) {
        let action = component.get("c.getSalesRepresentativesAndContacts");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let wrapper = response.getReturnValue();
                let reps = wrapper.saleRepUsers;
                let contacts = wrapper.contactUsers;
                let allOption = {};
                allOption.Id = allOption.Name = 'All';
                reps.unshift(allOption);
                contacts.unshift(allOption);
                component.set("v.salesReps", reps);
                component.set("v.eContacts", contacts);
                let orderOpts = [];
                let dateAsc = {
                    orderValue: "ASC",
                    label: $A.get("$Label.c.CBS_Date_ascending")
                };
                let dateDesc = {
                    orderValue: "DESC",
                    label: $A.get("$Label.c.CBS_Date_descending")
                };
                orderOpts.push(dateAsc, dateDesc);
                component.set("v.orderOptions", orderOpts);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    searchForEvent : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        let representativeId = component.get("v.event.OwnerId");
        let contactId = component.get("v.event.WhoId");
        let cFDate = component.get("v.startDate");
        let cTDate = component.get("v.endDate");
        let tOrder = component.get("v.order");

        if (cFDate > cTDate) {
            helper.showToast(component, 'Warning', $A.get("$Label.c.CBS_From_date_before_to_date"), $A.get("$Label.c.CBS_From_date_before_to_date_message"));
            return;
        }

        theSpinner.showSpinner(component);
        let action = component.get("c.searchForEvents");
        action.setParams({"salesRepresentative" : representativeId, "contactUser" : contactId, "fromDate" : cFDate, "toDate" : cTDate, "orderBy" : tOrder});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.events", response.getReturnValue());
                let searchedEvent = $A.get("e.c:CBS_AirplaneEventsSearched");
                searchedEvent.setParams({"theEvents" : response.getReturnValue()});
                searchedEvent.fire();
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },

    clear : function(component, event, helper) {
        helper.clearForm(component);
    }
})