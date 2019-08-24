// Partial for rendering The tile layer, fullscreen button and repostition button to the map
var map;
var mapnik = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  className: "mapnik",
  attribution: '&copy; <a href="&copy;"> <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map); 
var osm_hot = L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
  	maxZoom: 19,
  	className: "osm_hot",
  	attribution: '&copy; <a href="&copy;"><a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Tiles style by <a href="https://www.hotosm.org/" target="_blank">Humanitarian OpenStreetMap Team</a> hosted by <a href="https://openstreetmap.fr/" target="_blank">OpenStreetMap France</a>'
});
var changeMap = function() {

  if ( map.hasLayer(mapnik)) {
    map.removeLayer(mapnik);
    map.addLayer(osm_hot);
  }
  else {
    map.removeLayer(osm_hot);
    map.addLayer(mapnik);    
  }
};

// Below - Adds fullscreen   
L.control.fullscreen({
  fullscreenControl: true,
  forceSeparateButton: true,
  fullscreenControlOptions: {
    position: 'topleft',
  }
}).addTo(map); 
// Below - Adds recenter location button. 
var lc = L.control.locate({
  position: 'topleft',
  drawCircle: false,
  flyTo: true,
  showPopup: false,
  drawMarker: false,
  icon: 'fas fa-bullseye',
  strings: {
      title: "Recenter My Location"
    }
}).addTo(map);
