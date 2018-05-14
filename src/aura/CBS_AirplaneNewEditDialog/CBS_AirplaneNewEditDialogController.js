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
    }
})