({
   /*handleCoordinates : function(component, event, helper) {
       console.log('>>>MAP CONTROLLER<<<');
*//*       let coordinatesList = event.getParam("hangarsCoordinates");
       for (let i = 0; i < coordinatesList.length; i++) {
           console.log("FROM MAP CONTROLLER");
           console.log(coordinatesList.latitude);
       }*//*
   },*/

    doInit : function(component, event, helper) {
        let cordArr = component.get("v.coordinatesList");
        console.log("cordArr:" + cordArr.length);
/*        console.log(cordArr);
                for (let i = 0; i < cordArr.length; i++) {
                    console.log("~~~~~~");
                }*/
    },

    clickedButton : function(component, event, helper) {
        let cordArr = component.get("v.coordinatesList");
        console.log("cordArr:" + cordArr.length);
        console.log(cordArr[0].latitude);


    },

    jsLoaded : function(component, event, helper) {
        let cordArr = component.get("v.coordinatesList");
        for (let i = 0; i < cordArr.length; i++) {
            console.log("~~~~~~");
        }


                var map = L.map('map', {zoomControl: false});

                L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: 'Tiles © Esri'
                }).addTo(map);
                var markerArray = [];
                //markerArray.push(L.marker([parseFloat(cordArr[0].latitude), parseFloat(cordArr[0].longitude)]));
                markerArray.push(L.marker([7.33, -70.33]));
                markerArray.push(L.marker([7.55, -70.55]));
                var group = L.featureGroup(markerArray).addTo(map);
                map.fitBounds(group.getBounds().pad(0.25));

/*        setTimeout(function() {
            var map = L.map('map', {zoomControl: false});

            L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: 'Tiles © Esri'
                }).addTo(map);*/



/*

        });*/
    }
})