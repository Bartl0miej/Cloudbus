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
            helper.showToast(component, "Warning", "Incorrect promotion information", "Please specify all fields before saving a promotion.");
            return;
        }


        if (discountedPrice >= standardPrice) {
            helper.showToast(component, "Warning", "Incorrect price", "Cannot set a promotion price that is not lower than the standard price.");
            return;
        }

        if (sDate > eDate) {
            helper.showToast(component, "Warning", "Incorrect dates", "Cannot set a promotion end date before promotion start date.");
            return;
        }

        let todayDate = new Date();
        todayDate = todayDate.setHours(0, 0, 0, 0);
        let promStartDate = new Date(sDate);

        if (todayDate > promStartDate) {
            helper.showToast(component, "Warning", "Incorrect dates", "Cannot set a promotion with start date before today's date.");
            return;
        }

        console.log('Discounted price = ' + discountedPrice);
        console.log('Start date = ' + sDate);
        console.log('End date = ' + eDate);

        let action = component.get("c.createPromotion");
        action.setParams({"planeId" : airplaneId, "pPrice" : discountedPrice, "pSDate" : sDate, "pEDate" : eDate});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let evt = $A.get("e.c:CBS_AirplanePromotionCreated");
                evt.fire();
                helper.clearPromotionForm(component);
            } else {
                alert('error');
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
        console.log("Promo percent = " + promoPercent);
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
            console.log('Pricebook2Id = ' + toDelete[i].Pricebook2Id);
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
                helper.showToast(component, "Success", "Successfully deleted", "Successfully deleted promotions.");
            } else {
                console.log('error');
            }
        });

        $A.enqueueAction(action);


    }
})