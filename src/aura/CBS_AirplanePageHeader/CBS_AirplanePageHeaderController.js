({
    onInit : function(component, event, helper) {
        let envType = component.get("v.environmentType");
        if (envType == "Community") {
            component.set("v.isStandardSite", false);
        }
        let theRecordId = component.get("v.recordId");
        let action = component.get("c.getAirplaneType");
        action.setParams({"airplaneId" : theRecordId});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let tAirplane = response.getReturnValue();
                component.set("v.theName", tAirplane.Name);
                component.set("v.theNumberOfSeats", tAirplane.Number_of_Seats__c);
                component.set("v.theEngine", tAirplane.Engine__c);
                component.set("v.theEnginesNumber", tAirplane.Engines_Number__c);
                component.set("v.price", tAirplane.Price__c);
                component.set("v.discount", tAirplane.Discount__c);
                component.set("v.priceAfterDiscount", tAirplane.Price_after_Discount__c);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    openModal : function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    openDeleteModal : function(component, event, helper) {
        component.set("v.isDeleteModalOpen", true);
    },

    closeDeleteModal : function(component, event, helper) {
        component.set("v.isDeleteModalOpen", false);
    },

    saveAirplaneHeader : function(component, event, helper) {
        let childCmp = component.find('editComponent');
        let rId = component.get("v.recordId");
        childCmp.saveTheAirplane(rId);
    },

    deleteAirplaneRecord : function(component, event, helper) {
        let airplaneName = component.get("v.theName");
        let tAirplaneId = component.get("v.recordId");
        let action = component.get("c.deleteAirplane");
        action.setParams({"airplaneId" : tAirplaneId});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Deleted"), $A.get("$Label.c.CBS_Airplane") + " " + airplaneName + " " + $A.get("$Label.c.CBS_deleted_successfully"));
                let urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({"url": "/one/one.app#/n/Airplanes"});
                urlEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    openShowingModal : function(component, event, helper) {
        component.set("v.isShowingModalOpen", true);
    },

    onAirplaneShowingModalClose : function(component, event, helper) {
        component.set("v.isShowingModalOpen", false);
    }
})