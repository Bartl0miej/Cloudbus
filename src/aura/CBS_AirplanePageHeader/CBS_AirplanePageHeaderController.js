({
    onInit : function(component, event, helper) {
        let envType = component.get("v.environmentType");
        if (envType == "Community") {
            component.set("v.isStandardSite", false);
        }
        let theRecordId = component.get("v.recordId");
        let action = component.get("c.getAirplane");
        action.setParams({"airplaneId" : theRecordId});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let tAirplane = response.getReturnValue();
                component.set("v.theName", tAirplane.Name);
                component.set("v.theNumberOfSeats", tAirplane.Number_of_Seats__c);
                component.set("v.theEngine", tAirplane.Engine__c);
                component.set("v.theEnginesNumber", tAirplane.Engines_Number__c);
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

    deleteAirplane : function(component, event, helper) {
        let airplaneName = component.get("v.airplaneRecord.Name");
        component.find("forceRecord").deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                let urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/one/one.app#/n/Airplanes"
                });
                urlEvent.fire();
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Deleted"), $A.get("$Label.c.CBS_Airplane") + " " + airplaneName + " " + $A.get("$Label.c.CBS_deleted_successfully"));
            } else if (deleteResult.state === "INCOMPLETE") {
                helper.showToast(component, "Error", $A.get("$Label.c.CBS_User_offline"), $A.get("$Label.c.CBS_User_offline_no_drafts"));
            } else {
                helper.showToast(component, "Error", $A.get("$Label.c.CBS_Error"), $A.get("$Label.c.CBS_Problem_deleting_error") + JSON.stringify(deleteResult.error));
            }
        }));
    }
})