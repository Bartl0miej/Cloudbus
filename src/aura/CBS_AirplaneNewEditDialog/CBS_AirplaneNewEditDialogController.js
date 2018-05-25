({
    //doInit : function(component, event, helper) {
/*        let recId = component.get("v.recordId");

        if (!recId) {
            component.find("forceRecord").getNewRecord(
                    "Product2",
                    null,
                    false,
                    $A.getCallback(function() {
                        let rec = component.get("v.propertyRecord");
                        let error = component.get("v.recordError");
                        if (error || (rec === null)) {
                            console.log("Error initializing record template: " + error);
                            return;
                        }
                    })
            );
        }*/
    //},

    onInit: function(component, event, helper) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);
        let action = component.get("c.getAttachments");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
           let state = response.getState();
           if (state === "SUCCESS") {
                let listOfAttachmentIds = response.getReturnValue();
                let mainPic = {};
                if (response.getReturnValue().mainPicture != undefined) {
                    console.log('jest rozne?');
                    mainPic.isAttachment = true;
                    mainPic.Id = listOfAttachmentIds.mainPicture.Id;
                    mainPic.theData = null;
                    mainPic.hasMain = true;
                } else {
                    mainPic.isAttachment = false;
                    mainPic.Id = null;
                    mainPic.theData = null;
                    mainPic.hasMain = false;
                }

                component.set("v.mainPicture", mainPic);
                //component.set("v.mainPicture", listOfAttachmentIds.mainPicture);
                console.log('mainPicture = ' + listOfAttachmentIds.mainPicture);
                listOfAttachmentIds = listOfAttachmentIds.attachments;

                console.log('in callback');
                component.set("v.attachments", listOfAttachmentIds);
                console.log(listOfAttachmentIds);
                console.log('after');
                for (let i = 0; i < listOfAttachmentIds.length; i++) {
                    console.log('attachment: ' + listOfAttachmentIds[i]);
                }
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
        for (let i = 0; i < atts.length; i++) {
            console.log(atts[i]);
        }

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
        console.log('attachmentsList.length = ' + atts.length);

        component.set("v.attachments", atts);
    },

    setAttAsMain : function(component, event, helper) {
        let mainBeforeChange = component.get("v.mainPicture");
        console.log('mainBeforeChange: ' + mainBeforeChange);
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

        console.log('attachmentsList.length = ' + attachmentsList.length);

        component.set("v.attachments", attachmentsList);
        component.set("v.mainPicture", mainPic);

        if (!mainBeforeChange.hasMain) {
            return;
        }

        if (mainBeforeChange.isAttachment) {
            console.log('jest, tu wchodzimy');
            attachmentsList.push(mainBeforeChange);
            component.set("v.attachments", attachmentsList);
        } else {
            console.log('should be here');
            picsList.push(mainBeforeChange);
            component.set("v.pictures", picsList);
        }
    },

    setPicAsMain : function(component, event, helper) {
        let mainBeforeChange = component.get("v.mainPicture");
        console.log('mainBeforeChange: ' + mainBeforeChange);
        let attachmentsList = component.get("v.attachments");
        let picsList = component.get("v.pictures");

        let selectedItem = event.currentTarget;
        let picId = selectedItem.dataset.id;

        let mainPic = {};
        mainPic.isAttachment = false;
        mainPic.Id = null;
        mainPic.theData = picsList[picId].theData;
        mainPic.hasMain = true;

        picsList.splice(picId, 1);

        console.log('picsList.length = ' + picsList.length);

        component.set("v.pictures", picsList);
        component.set("v.mainPicture", mainPic);
        //alert(picId);

        if (!mainBeforeChange.hasMain) {
            console.log('==');
            return;
        }

        if (mainBeforeChange.isAttachment) {
            console.log('jest, tu wchodzimy');
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
            pics.unshift(mainPic);
            component.set("v.pictures", pics);
        }

        let afterChange = {};
        afterChange.isAttachment = false;
        afterChange.Id = null;
        afterChange.theData = null;
        afterChange.hasMain = false;

        component.set("v.mainPicture", afterChange);
    },

    deleteMainPic : function(component, event, helper) {
        let mainPic = component.get("v.mainPicture");

        if (mainPic.isAttachment) {
        let toDelete = component.get("v.attachmentsToDelete");

        toDelete.push(mainPic);
        component.set("v.attachmentsToDelete", toDelete);
        }

        let afterChange = {};
        afterChange.isAttachment = false;
        afterChange.Id = null;
        afterChange.theData = null;
        afterChange.hasMain = false;

        component.set("v.mainPicture", afterChange);
    },

    onDragOver: function(component, event, helper) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
    	event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        let files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one picture at a time");
        }
        helper.readFile(component, helper, files[0]);
    },

    saveRecord : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        let mainPic = component.get("v.mainPicture");
        if (!mainPic.hasMain) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "No main image",
                "message": "You cannot save airplane without main picture."
            });
            toastEvent.fire();

            return;
        }

        let pics = component.get("v.pictures");
        let attsToDelete = component.get("v.attachmentsToDelete");

        pics = JSON.stringify(pics);

        console.log(pics);

        let tempRec = component.find('forceRecord');
        let rId = component.get("v.recordId");
        console.log('tempRec = ' + rId);

        let mainPicAttachment = null;
        if (mainPic.isAttachment) {
            mainPicAttachment = mainPic;
        }

        theSpinner.showSpinner(component);
        let action = component.get("c.saveAirplane");
        action.setParams({"mainPictureAtt" : mainPicAttachment, recordId : rId, "attachmentsToDelete" : attsToDelete});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('ok');
                let resultToast = $A.get("e.force:showToast");
                resultToast.setParams({
                    "title": "Updated",
                    "message": "The airplane was successfully updated.",
                    "type": 'Success'
                });
                resultToast.fire();
                let recId = component.get("v.recordId");
                helper.navigateTo(component, recId);
            } else {
                console.log('error');
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);

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
    },

    cancelDialog : function(component, event, helper) {

        let toCancel = component.get("v.attachmentsToCancel");
        for (let i = 0; i < toCancel.length; i++) {
            console.log('to cancel: ' + toCancel[i]);
        }

        let action = component.get("c.cancelAirplaneEdit");
        action.setParams({"picsToCancel" : toCancel});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                var recId = component.get("v.recordId");
                if (!recId) {
                    var homeEvt = $A.get("e.force:navigateToObjectHome");
                    homeEvt.setParams({
                        "scope": "Product2"
                    });
                    homeEvt.fire();
                } else {
                    helper.navigateTo(component, recId);
                }
            } else {
                console.log('failure');
            }
        });

        $A.enqueueAction(action);

//        var recId = component.get("v.recordId");
//        if (!recId) {
//            var homeEvt = $A.get("e.force:navigateToObjectHome");
//            homeEvt.setParams({
//                "scope": "Product2"
//            });
//            homeEvt.fire();
//        } else {
//            helper.navigateTo(component, recId);
//        }
    },

    handleUploadFinished: function (component, event) {
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
        let airplaneEditedEvent = $A.get("e.c:CBS_AirplaneEdited");
        airplaneEditedEvent.fire();
    },

    handleFilesChange : function(component, event, helper) {
        var files = event.getSource().get("v.files");
            if(files){
                var file = files[0]
                var reader = new FileReader();
                reader.readAsDataURL(file);
                reader.onload = function () {
                    var template = component.get("v.richtextvalue");
                    if(template===undefined) template = '';
                    template += '<img src="'+reader.result+'"/>';
                    component.set("v.airplaneRecord.Main_photo__c",template);
                };
                reader.onerror = function (error) {
                    console.log('Error: ', error);
                };
                alert('Main photo updated successfully.');
            }
    }
})