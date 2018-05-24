({
    doInit : function(component, event, helper) {
        let recId = component.get("v.recordId");

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
        }
    },

    saveRecord : function(component, event, helper) {
        let tempRec = component.find('forceRecord');
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            let resultToast = $A.get("e.force:showToast");
            if(result.state === 'SUCCESS') {
                resultToast.setParams({
                    "title": "Saved",
                    "message": "The record was saved.",
                    "type": 'success'
                });
                resultToast.fire();
                let recId = result.recordId;
                helper.navigateTo(component, recId);
                let airplaneEditedEvent = $A.get("e.c:CBS_AirplaneEdited");
                airplaneEditedEvent.fire();
            } else if (result.state === "ERROR") {
                console.log('ERROR: ' + JSON.stringify(result.error));
                resultToast.setParams({
                    "title": "Error",
                    "message": "There was an error saving the record: " + JSON.stringify(result.error),
                    "type": 'error'
                });
                resultToast.fire();
                let recId = result.recordId;
                helper.navigateTo(component, recId);
            } else {
                      console.log('Unknown problem, state: ' + result.state + ', error: ' + JSON.stringify(result.error));
            }
        }));
    },

    cancelDialog : function(component, event, helper) {
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