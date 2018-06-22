({
    onInit: function(component, event, helper) {
        let recId = component.get("v.recordId");
        if (!recId) {
            component.find("forceRecord").getNewRecord(
                "Airplane_Type__c",
                null,
                false,
                $A.getCallback(function() {
                    let rec = component.get("v.airplaneRecord");
                    let error = component.get("v.recordError");
                    if (error || (rec === null)) {
                        helper.showToast(component, "Error", $A.get("$Label.c.CBS_Error"), $A.get("$Label.c.CBS_Error_initializing_template") + " " + error);
                        return;
                    }
                    helper.createMainPicture(component, false, null, null, false);
                    return;
                })
            );
        }

        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);
        let action = component.get("c.getAttachmentWrappers");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let listOfAttachmentIds = response.getReturnValue();
                if (response.getReturnValue().mainPicture != undefined) {
                    helper.createMainPicture(component, true, listOfAttachmentIds.mainPicture.Id, null, true);
                } else {
                    helper.createMainPicture(component, false, null, null, false);
                }
                listOfAttachmentIds = listOfAttachmentIds.attachments;
                component.set("v.attachments", listOfAttachmentIds);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },

    deletePicture : function(component, event, helper) {
        let atts = component.get("v.pictures");
        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;
        atts.splice(picId, 1);
        component.set("v.pictures", atts);
    },

    deleteAttachment : function(component, event, helper) {
        let atts = component.get("v.attachments");
        let toDelete = component.get("v.attachmentsToDelete");
        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;
        toDelete.push(atts[picId]);
        component.set("v.attachmentsToDelete", toDelete);
        atts.splice(picId, 1);
        component.set("v.attachments", atts);
    },

    setAttAsMain : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;

        helper.setMainPicture(component, picId, true);
    },

    setPicAsMain : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;

        helper.setMainPicture(component, picId, false);
    },

    diselectFromMainPic : function(component, event, helper) {
        let mainPic = component.get("v.mainPicture");
        if (mainPic.isAttachment) {
            let atts = component.get("v.attachments");
            atts.push(mainPic);
            component.set("v.attachments", atts);
        } else {
            let pics = component.get("v.pictures");
            let tData = mainPic.theData;
            pics.push(tData);
            component.set("v.pictures", pics);
        }

        helper.createMainPicture(component, false, null, null, false);
    },

    deleteMainPic : function(component, event, helper) {
        let mainPic = component.get("v.mainPicture");

        if (mainPic.isAttachment) {
            let toDelete = component.get("v.attachmentsToDelete");
            toDelete.push(mainPic);
            component.set("v.attachmentsToDelete", toDelete);
        }
        helper.createMainPicture(component, false, null, null, false);
    },

    onDragOver: function(component, event, helper) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        event.dataTransfer.dropEffect = 'copy';
        let files = event.dataTransfer.files;
        if (files.length > 1) {
            helper.showToast(component, "Error", $A.get("$Label.c.CBS_Upload_one_picture"), $A.get("$Label.c.CBS_Upload_one_picture_at_a_time"));
            return;
        }
        helper.readFile(component, helper, files[0]);
    },

    saveRecord : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        let mainPic = component.get("v.mainPicture");
        theSpinner.showSpinner(component);
        if (!mainPic.hasMain) {
            theSpinner.hideSpinner(component);
            helper.showToast(component, "Error", $A.get("$Label.c.CBS_No_main_image"), $A.get("$Label.c.CBS_Cant_save_without_main_pic"));
            return;
        }

        let pics = component.get("v.pictures");
        let attsToDelete = component.get("v.attachmentsToDelete");

        let rId = component.get("v.recordId");
        let aircraft = component.get("v.airplaneRecord");

        let picMain = null;
        let mainPicAttachment = null;

        if (mainPic.isAttachment) {
            mainPicAttachment = mainPic;
        } else {
            picMain = mainPic.theData;
        }

        let forceRecordId = aircraft.Id;

        let action = component.get("c.saveAirplane");
        action.setParams({"theAirplane" : aircraft, "mainPictureAtt" : mainPicAttachment, "attachmentsToDelete" : attsToDelete, "picturesToUpload" : pics, "pictureMain" : picMain});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let aircraftId = response.getReturnValue();
                theSpinner.hideSpinner(component);
                if (rId) {
                    let evt = $A.get("e.c:CBS_AirplaneEdited");
                    evt.fire();
                    let savedAirplaneEvt = component.getEvent("CBS_AirplaneSavedEvent");
                    savedAirplaneEvt.fire();
                    $A.get('e.force:refreshView').fire();
                    helper.showToast(component, "Success", $A.get("$Label.c.CBS_Airplane_Edited"), $A.get("$Label.c.CBS_Successfully_edited") + " " + aircraft.Name);
                } else {
                    let navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({"recordId" : aircraftId});
                    navEvent.fire();
                    helper.showToast(component, "Success", $A.get("$Label.c.CBS_Airplane_Created"), $A.get("$Label.c.CBS_Successfully_created") + " " + aircraft.Name);
                }
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    cancelDialog : function(component, event, helper) {
        let recId = component.get("v.recordId");
        if (!recId) {
            let navEvent = $A.get("e.force:navigateToComponent");
            navEvent.setParams({"componentDef" : "c:CBS_AirplanesDatatable"})
            navEvent.fire();
        } else {
            helper.navigateTo(component, recId);
        }
    },

    calculatePrice : function(component, event, helper) {
        let airplane = component.get("v.airplaneRecord");
        let price = airplane.Price__c;
        let discount = airplane.Discount__c;

        let priceDiscounted = price - (price * discount/100);

        component.set("v.priceAfterDiscount", priceDiscounted);
    }
})