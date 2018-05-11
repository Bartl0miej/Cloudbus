({
    addClass : function (component, event, helper) {
            var selectedItem = event.currentTarget;
            var hangarId = selectedItem.dataset.id;
            var Elements = component.find('listItem');

            for(var i = 0; i<Elements.length; i++) {
                var value = Elements[i].getElement().getAttribute('data-id');

                if (value != hangarId) {
                   $A.util.removeClass(Elements[i], 'itemSelect');
                }else{
                    $A.util.addClass(Elements[i], 'itemSelect');
                }
            }
        }
})