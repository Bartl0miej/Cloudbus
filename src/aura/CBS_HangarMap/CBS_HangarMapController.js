({
    rerenderMap : function (component, event, helper) {
        let cordArr = component.get("v.coordinatesList");
        for (let i = 0; i < cordArr.length; i++) {
            console.log("~~~~~~");
        }
        var map = component.get("v.map");

        if (!map) {
            var mapElement = component.find("map").getElement();
            map = L.map(mapElement, {zoomControl: true, zoom:1,zoomAnimation:false,fadeAnimation:true,markerZoomAnimation:true});
            component.set("v.map", map);
        }
        L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: 'Tiles © Esri'
                }).addTo(map);

        helper.addMarkers(component);
    },

    coordinatesChangeHandler : function(component, event, helper) {
        helper.addMarkers(component);
    },

    jsLoaded : function(component, event, helper) {
        let cordArr = component.get("v.coordinatesList");

        var action = component.get("c.rerenderMap");

        $A.enqueueAction(action);
    }
})