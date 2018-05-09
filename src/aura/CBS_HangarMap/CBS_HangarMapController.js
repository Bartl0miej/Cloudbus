({
jsLoaded: function(component, event, helper) {
    setTimeout(function() {
        var map = L.map('map', {zoomControl: false});

        L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
                attribution: 'Tiles © Esri'
            }).addTo(map);

        var markerArray = [];
        markerArray.push(L.marker([7.33, -70.33]));
        markerArray.push(L.marker([7.55, -70.55]));
        var group = L.featureGroup(markerArray).addTo(map);
        map.fitBounds(group.getBounds().pad(0.25));

    });
}
})