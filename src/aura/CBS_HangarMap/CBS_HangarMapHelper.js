({
    addMarkers: function(component) {
        var map = component.get('v.map');
        var markers = component.get('v.markers');
        var coordinates = component.get('v.coordinatesList');
        let markerArray = [];

        if (markers) {
        	map.removeLayer(markers);
        }

        if (map && coordinates && coordinates.length> 0) {
            for (var i=0; i<coordinates.length; i++) {
                var coordinate = coordinates[i];
                if (coordinate.latitude && coordinate.longitude) {
                   markerArray.push(window.L.marker([parseFloat(coordinate.latitude), parseFloat(coordinate.longitude)]));
                    let group = window.L.featureGroup(markerArray).addTo(map);
                    component.set('v.markers', group);
                    map.fitBounds(group.getBounds().pad(0.50));
                }
            }
        }
    }
})