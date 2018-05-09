({
    addMarkers: function(component) {
        var map = component.get('v.map');
        var markers = component.get('v.markers');
        var coordinates = component.get('v.coordinatesList');
        let markerArray = [];
        let markerGroup = window.L.featureGroup();



        // Remove existing markers
        if (markers) {
        	markers.clearLayers();
        }

        // Add Markers
        if (map && coordinates && coordinates.length> 0) {
            for (var i=0; i<coordinates.length; i++) {
                var coordinate = coordinates[i];
                if (coordinate.latitude && coordinate.longitude) {
	                //var latLng = [parseFloat(coordinate.latitude), parseFloat(coordinate.longitude)];
    	            //var marker = window.L.marker(latLng, {coordinate: coordinate});
                   //markers.addLayer(marker);
                   markerArray.push(window.L.marker([parseFloat(coordinate.latitude), parseFloat(coordinate.longitude)]));
                    let group = window.L.featureGroup(markerArray).addTo(map);
                    map.fitBounds(group.getBounds().pad(0.50));


                }
            }
        }




        /*var markerArray = [];
                                markerArray.push(L.marker([parseFloat(cordArr[0].latitude), parseFloat(cordArr[0].longitude)]));
                                markerArray.push(L.marker([7.33, -70.33]));
                                markerArray.push(L.marker([7.55, -70.55]));
                                var group = L.featureGroup(markerArray).addTo(map);
                                map.fitBounds(group.getBounds().pad(0.50));*/
    }
})