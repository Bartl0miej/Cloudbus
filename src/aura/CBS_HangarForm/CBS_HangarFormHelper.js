({
         // this function automatic call by aura:waiting event
            showSpinner: function(component) {
               // make Spinner attribute true for display loading spinner
                component.set("v.Spinner", true);
           },

         // this function automatic call by aura:doneWaiting event
            hideSpinner : function(component){
             // make Spinner attribute to false for hide loading spinner
               component.set("v.Spinner", false);
            }
})