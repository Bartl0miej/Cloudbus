({
    onInit : function(component, event, helper) {
        let theSpinner = component.find("spinner");
        theSpinner.showSpinner(component);
        let action = component.get("c.getAirplanesWithPromotions");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrappers", response.getReturnValue());
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
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
        let tDiscount = component.get("v.discount");
        let sDate = component.get("v.startDate");
        let eDate = component.get("v.endDate");

        if (!tDiscount || !sDate || !eDate) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_promotion_information"), $A.get("$Label.c.CBS_Please_specify_all_fields_before_saving_a_promotion"));
            return;
        }

        if (tDiscount > 99 || tDiscount < 1) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_discount_percentage"), $A.get("$Label.c.CBS_Please_specify_discount_that_is_between_1_and_99_percent"));
            return;
        }

        if (sDate > eDate) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_dates"), $A.get("$Label.c.CBS_Cannot_set_a_promotion_end_date_before_promotion_start_date"));
            return;
        }

        let todayDate = new Date();
        todayDate = todayDate.setHours(0, 0, 0, 0);
        let promStartDate = new Date(sDate);

        if (todayDate > promStartDate) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_dates"), $A.get("$Label.c.CBS_You_cannot_set_a_promotion_with_start_date_before_today_s_date"));
            return;
        }

        let wrappersString = JSON.stringify(component.get("v.wrappers"));

        let action = component.get("c.createPromotionForAll");
        action.setParams({"airplaneWrappersString" : wrappersString, "discountPercent" : tDiscount, "startDate" : sDate, "endDate" : eDate});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.checked", false);
                helper.refreshAirplanes(component);
                helper.clearPromotionForm(component);
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Success"), $A.get("$Label.c.CBS_You_have_successfully_added_a_promotion"));
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    }
})