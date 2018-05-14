({
    addClass : function (component, event, helper) {
            let selectedItem = event.currentTarget;
            let hangarId = selectedItem.dataset.id;
            let hangars = component.find('listItem');

            for(let i = 0; i< hangars.length; i++) {
                let tempId = hangars[i].getElement().getAttribute('data-id');

                if (tempId != hangarId) {
                   $A.util.removeClass(hangars[i], 'itemSelected');
                } else {
                    $A.util.addClass(hangars[i], 'itemSelected');
                }
            }
    }
})