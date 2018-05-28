({
    onInit: function(component, event, helper) {
        let theRecordId = component.get("v.theRecordId");
        component.set("v.recordId", theRecordId);
        let recId = component.get("v.recordId");

        if (!recId) {
            component.find("forceRecord").getNewRecord(
                "Product2",
                null,
                false,
                $A.getCallback(function() {
                    console.log('Create a new airplane');
                    let rec = component.get("v.airplaneRecord");
                    let error = component.get("v.recordError");
                    if (error || (rec === null)) {
                        console.log("Error initializing record template: " + error);
                        return;
                    }
                    console.log('recId = ' + recId);
                })
            );
        }

        if (!recId) {
            let tempRec = component.find('forceRecord');
            tempRec.saveRecord($A.getCallback(function(result) {
                if(result.state === 'SUCCESS') {
                    helper.showToast(component, "Success", "Saved", "The record was saved.");
                    let recId = result.recordId;
                    helper.navigateTo(component, recId);
                    let airplaneEditedEvent = $A.get("e.c:CBS_AirplaneEdited");
                    airplaneEditedEvent.fire();
                } else {
                    console.log('state is failure');
                }
            }));
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
                    helper.setMainPicture(component, true, listOfAttachmentIds.mainPicture.Id, null, true);
                } else {
                    helper.setMainPicture(component, false, null, null, false);
                }
                listOfAttachmentIds = listOfAttachmentIds.attachments;
                component.set("v.attachments", listOfAttachmentIds);
            } else {
                console.log('failed with state: ');
                console.log(response.getError());
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
        let mainBeforeChange = component.get("v.mainPicture");
        let attachmentsList = component.get("v.attachments");
        let picsList = component.get("v.pictures");
        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;

        let mainPic = {};
        mainPic.isAttachment = true;
        mainPic.Id = attachmentsList[picId].Id;
        mainPic.theData = null;
        mainPic.hasMain = true;

        attachmentsList.splice(picId, 1);
        component.set("v.attachments", attachmentsList);
        component.set("v.mainPicture", mainPic);

        if (!mainBeforeChange.hasMain) {
            return;
        }

        if (mainBeforeChange.isAttachment) {
            attachmentsList.push(mainBeforeChange);
            component.set("v.attachments", attachmentsList);
        } else {
            let tData = mainBeforeChange.theData;
            picsList.push(tData);
            component.set("v.pictures", picsList);
        }
    },

    setPicAsMain : function(component, event, helper) {
        let mainBeforeChange = component.get("v.mainPicture");
        let attachmentsList = component.get("v.attachments");
        let picsList = component.get("v.pictures");

        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;

        helper.setMainPicture(component, false, null, picsList[picId], true);

        picsList.splice(picId, 1);

        component.set("v.pictures", picsList);

        if (!mainBeforeChange.hasMain) {
            return;
        }

        if (mainBeforeChange.isAttachment) {
            attachmentsList.push(mainBeforeChange);
            component.set("v.attachments", attachmentsList);
        } else {
            picsList.push(mainBeforeChange);
            component.set("v.pictures", picsList);
        }
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

        helper.setMainPicture(component, false, null, null, false);
    },

    deleteMainPic : function(component, event, helper) {
        let mainPic = component.get("v.mainPicture");

        if (mainPic.isAttachment) {
            let toDelete = component.get("v.attachmentsToDelete");
            toDelete.push(mainPic);
            component.set("v.attachmentsToDelete", toDelete);
        }
        helper.setMainPicture(component, false, null, null, false);
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
            helper.showToast(component, "Error", "Upload one picture", "You can only upload one picture at a time.");
            return;
        }
        helper.readFile(component, helper, files[0]);
    },

    saveRecord : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        let mainPic = component.get("v.mainPicture");
        if (!mainPic.hasMain) {
            helper.showToast(component, "Error", "No main image", "You cannot save an airplane without main picture.");
            return;
        }

        let pics = component.get("v.pictures");
        let attsToDelete = component.get("v.attachmentsToDelete");

        let tempRec = component.find('forceRecord');
        let rId = component.get("v.recordId");
        console.log('tempRec = ' + rId);

        let picMain = null;
        let mainPicAttachment = null;
        if (mainPic.isAttachment) {
            mainPicAttachment = mainPic;
        } else {
            picMain = mainPic.theData;
        }

        theSpinner.showSpinner(component);
        let action = component.get("c.saveAirplane");
        action.setParams({"mainPictureAtt" : mainPicAttachment, recordId : rId, "attachmentsToDelete" : attsToDelete, "picturesToUpload" : pics, "pictureMain" : picMain});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, "Success", "Updated", "The airplane was successfully updated.");
                let recId = component.get("v.recordId");
                let tempRec = component.find('forceRecord');
                tempRec.saveRecord($A.getCallback(function(response) {
                        helper.navigateTo(component, recId);
                }));
            } else {
                console.log('error');
            }
            theSpinner.hideSpinner();
        });

          $A.enqueueAction(action);

    },

    cancelDialog : function(component, event, helper) {
        let recId = component.get("v.recordId");
        if (!recId) {
            let homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Product2"
            });
            homeEvt.fire();
        } else {
            helper.navigateTo(component, recId);
        }
    },
  //        let tempRec = component.find('forceRecord');
  //        tempRec.saveRecord($A.getCallback(function(result) {
  //            console.log(result.state);
  //            let resultToast = $A.get("e.force:showToast");
  //            if(result.state === 'SUCCESS') {
  //                resultToast.setParams({
  //                    "title": "Saved",
  //                    "message": "The record was saved.",
  //                    "type": 'success'
  //                });
  //                resultToast.fire();
  //                let recId = result.recordId;
  //                helper.navigateTo(component, recId);
  //                let airplaneEditedEvent = $A.get("e.c:CBS_AirplaneEdited");
  //                airplaneEditedEvent.fire();
  //            } else if (result.state === "ERROR") {
  //                console.log('ERROR: ' + JSON.stringify(result.error));
  //                resultToast.setParams({
  //                    "title": "Error",
  //                    "message": "There was an error saving the record: " + JSON.stringify(result.error),
  //                    "type": 'error'
  //                });
  //                resultToast.fire();
  //                let recId = result.recordId;
  //                helper.navigateTo(component, recId);
  //            } else {
  //                console.log('Unknown problem, state: ' + result.state + ', error: ' + JSON.stringify(result.error));
  //            }
})