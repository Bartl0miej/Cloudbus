({
    onInit : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);

        let action = component.get("c.getAirplanes");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrappers", response.getReturnValue());
            } else {
                console.log('error');
            }
            theSpinner.hideSpinner();
        });

        $A.enqueueAction(action);
    },

    handleToggleChanged : function(component, event, helper) {
        let isChecked = component.get("v.checked");
        let childComponents = component.find('child');
        for (let i = 0; i < childComponents.length; i++) {
            childComponents[i].onDiscountForAll(isChecked);
        }
        if (!isChecked) {
            helper.clearPromotionForm(component);
        }
    },

    onDiscountChange : function(component, event, helper) {
        let tDiscount = component.get("v.discount");
        console.log('tDiscount = ' + tDiscount);
        let childComponents = component.find('child');
        for (let i = 0; i < childComponents.length; i++) {
            childComponents[i].calculatePrice(tDiscount);
        }
    },

    clearPromoForm : function(component, event, helper) {
        helper.clearPromotionForm(component);
    },

    savePromotionForAll : function(component, event, helper) {
        let airplanes = component.get("v.wrappers");
//        for (let i = 0; i < airplanes.length; i++) {
//            console.log('airplaneId = ' + airplanes[i].airplane.Id);
//        }
        let tDiscount = component.get("v.discount");
        let sDate = component.get("v.startDate");
        let eDate = component.get("v.endDate");

        if (!tDiscount || !sDate || !eDate) {
            helper.showToast(component, "Warning", "Incorrect promotion information", "Please specify all fields before saving a promotion.");
            return;
        }

        if (tDiscount > 99 || tDiscount < 1) {
            helper.showToast(component, "Warning", "Incorrect discount percentage", "Please specify discount that is between 1 and 99 percent.");
            return;
        }

        if (sDate > eDate) {
            helper.showToast(component, "Warning", "Incorrect dates", "You cannot set a promotion end date before promotion start date.");
            return;
        }

        let todayDate = new Date();
        todayDate = todayDate.setHours(0, 0, 0, 0);
        let promStartDate = new Date(sDate);

        if (todayDate > promStartDate) {
            helper.showToast(component, "Warning", "Incorrect dates", "You cannot set a promotion with start date before today's date.");
            return;
        }

        let wrappersString = JSON.stringify(component.get("v.wrappers"));
        console.log(wrappersString);

        let action = component.get("c.createPromotionForAll");
        action.setParams({"airplaneWrappersString" : wrappersString, "discountPercent" : tDiscount, "startDate" : sDate, "endDate" : eDate});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('ok');
                component.set("v.checked", false);
                helper.refreshAirplanes(component);
                helper.clearPromotionForm(component);
                helper.showToast(component, "Success", "Success", "You have successfully added a promotion.");
            } else {
                console.log('error');
            }
        });

        $A.enqueueAction(action);
    }

//    calculatePrice : function(component, event, helper) {
//        let airplane = component.get("v.wrappers");
//        let price = airplane[0].pbe.UnitPrice;
//        let discount = airplane[0].discount;
//
//
//
//        let priceDiscounted = price - (price * discount/100);
//
//        airplane[0].priceAfterDiscount = priceDiscounted;
//
//        component.set("v.wrappers", airplane);
//    },
//
//    saveDiscount : function(component, event, helper) {
//        let wrp = component.get("v.wrappers");
//        alert(wrp[0].discount);
//    }
})