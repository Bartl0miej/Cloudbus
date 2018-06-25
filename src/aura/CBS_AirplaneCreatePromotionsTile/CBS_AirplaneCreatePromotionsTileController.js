({
    onInit : function(component, event, helper) {
        let sPrice = component.get("v.wrapper.standardPrice");
        component.set("v.calculatedDiscountPrice", sPrice);
    },

    addPromotion : function(component, event, helper) {
        component.set("v.isAddingPromotion", true);
    },

    savePromotion : function(component, event, helper) {
        let airplaneId = component.get("v.wrapper.airplane.Id");
        let standardPrice = component.get("v.wrapper.standardPrice");
        let discountedPrice = component.get("v.promotionPrice");
        let sDate = component.get("v.startDate");
        let eDate = component.get("v.endDate");

        if (!discountedPrice || !sDate || !eDate) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_promotion_information"), $A.get("$Label.c.CBS_Please_specify_all_fields_before_saving_a_promotion"));
            return;
        }

        if (discountedPrice >= standardPrice) {
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_price"), $A.get("$Label.c.CBS_Cannot_set_a_promotion_price_that_is_not_lower_than_the_standard_price"));
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
            helper.showToast(component, "Warning", $A.get("$Label.c.CBS_Incorrect_dates"), $A.get("$Label.c.CBS_Cannot_set_a_promotion_with_start_date_before_today_s_date"));
            return;
        }

        let action = component.get("c.createPromotion");
        action.setParams({"planeId" : airplaneId, "pPrice" : discountedPrice, "pSDate" : sDate, "pEDate" : eDate});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let evt = $A.get("e.c:CBS_AirplanePromotionCreated");
                evt.fire();
                helper.clearPromotionForm(component);
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    },

    cancelAddingPromotion : function(component, event, helper) {
        helper.clearPromotionForm(component);
    },

    showPromotions : function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.promotionsToDelete", []);
    },

    discountForAll : function(component, event, helper) {
        let args = event.getParam("arguments");
        let checkd = args.isChecked;
        component.set("v.calculatedDiscountPrice", component.get("v.wrapper.standardPrice"));
        component.set("v.isAddingPromotionForAll", checkd);
        helper.clearPromotionForm(component);
    },

    onCalculatePrice : function(component, event, helper) {
        let args = event.getParam("arguments");
        let promoPercent = args.discountPercentage;
        if (promoPercent > 99 || promoPercent < 1) {
            component.set("v.calculatedDiscountPrice", component.get("v.wrapper.standardPrice"));
            return;
        }
        let price = component.get("v.wrapper.standardPrice");
        let priceDiscounted = price - (price * promoPercent / 100);
        component.set("v.calculatedDiscountPrice", priceDiscounted);
    },

    onPromoToDeleteList : function(component, event, helper) {
        let promo = event.getParam("promotionObj");
        let promotionsDeleteList = component.get("v.promotionsToDelete");
        promotionsDeleteList.push(promo);
        component.set("v.promotionsToDelete", promotionsDeleteList);
    },

    deletePromotions : function(component, event, helper) {
        let toDelete = component.get("v.promotionsToDelete");
        let priceBooksToDelete = [];
        for (let i = 0; i < toDelete.length; i++) {
            priceBooksToDelete.push(toDelete[i].Pricebook2Id);
        }

        let action = component.get("c.deletePBPromotions");
        action.setParams({"pbsToDelete" : priceBooksToDelete});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let evt = $A.get("e.c:CBS_AirplanePromotionCreated");
                evt.fire();
                component.set("v.promotionsToDelete", []);
                component.set("v.isModalOpen", false);
                helper.showToast(component, "Success", $A.get("$Label.c.CBS_Successfully_deleted"), $A.get("$Label.c.CBS_Successfully_deleted_promotions"));
            } else {
                let errors = response.getError()[0];
                helper.showErrorToast(component, errors);
            }
        });

        $A.enqueueAction(action);
    }
})