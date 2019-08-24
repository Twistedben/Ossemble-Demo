import census from 'citysdk';


census_btn      = $('#call_census_btn')
try_again_btn   = $('#try_again_btn')
output          = $('#geo_output')
city_name       = $('#shape_name')
city_lat_lng    = $('#shape_geo')
state_id        = $('#shape_state')
geo_id          = $('#shape_geo_id')
last_try_tier   = $('#last_try_tier')
submit_map_btn  = $('#submit_map_btn')
arrow_btn       = $('#arrow_btn')
try_arrow_btn   = $('#try_arrow_btn')
submit_tier     = $('#submit_tier')
submit_arrow_btn = $('#submit_arrow_btn')

# Begin - LEAFLET: Sets up Leaflet configuration

# Below - Instantiates Leaflet map
map = L.map('oss_map')

# Below - Map is initiated and then centered on user's location.
map.locate
  setView: true
  maxZoom: 13

# Below - Draws circle on users current location and adds popup
onLocationFound = (e) ->
  radius = e.accuracy / 2
  L.circle(e.latlng).addTo(map).bindPopup("<p class='text-15 mb-0'>Since you're located near this point, clicking around here is recommended.</p><p>Unless you are creating a channel for a separate location elsewhere.</p>").openPopup()
  L.circle(e.latlng, 150).addTo map
  return
  
# Below - If user's location isn't found, displays error message, pans to middle of America and sets zoom to further out.
onLocationError = (e) ->
  alert e.message
  map.options.minZoom = 4
  map.setView [39.7837304, -100.4458825], 4
  return

# Below - Adds the Leaflet OSM Map and attribution layer
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="&copy;"> <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>').addTo map

# Below - Button for fullscreen
L.control.fullscreen(
  fullscreenControl: true
  forceSeparateButton: true
  fullscreenControlOptions: position: 'topleft').addTo map

# Below - Reset button/Position
lc = L.control.locate(
  position: 'topleft'
  drawCircle: true
  flyTo: true
  showPopup: false
  drawMarker: false
  icon: 'fas fa-bullseye'
  strings: title: 'Recenter My Location').addTo map

# Below - Scaling Zoom and Disabling Drag/Zoom
L.control.scale().addTo map
map.options.minZoom = 10
map.options.maxZoom = 16

# Begin - MARKER: Allows Marker placement/pinning on map click
L.AwesomeMarkers.Icon::options.prefix = 'fa'

# Below - LOCATE SUCCESS: Once map loads and the locationfound event fires from Locate, executes the above function 'onLocationFound
map.on 'locationfound', onLocationFound
# Below - LOCATE ERROR: Once map loads and the locationerror event fires from Locate, executes the above function 'onLocationError
map.on 'locationerror', onLocationError
# End - LEAFLET:

# Begin - CITYSDK - Census API and control
callCensus = (lat, lng) ->
  census {
    'vintage': 2017
    'geoHierarchy': 'place':
      'lat': lat, 
      'lng': lng
    'sourcePath': [
      'acs'
      'acs5'
    ]
    'values': [ 'B00001_001E']
    'geoResolution': '500k'
  }, (err, res) ->
    addToMap res, lat, lng   
    return

# Button is disabled on first load, becomes enabled after user clicks on map, pings Census on click with lat/long of marker and enables try again button, doing same thing.
census_btn.click ->
  callCensus $(this).data('latitude'), $(this).data('longitude')
  $(this).addClass 'vanish'
  try_again_btn.delay(800).fadeIn 'slow'
  arrow_btn.addClass 'vanish'
  return

# Appears after initial census btn click for a second try. Sends data again and removes current map layer that's incorrect.
try_again_btn.click ->
  callCensus $(this).data('latitude'), $(this).data('longitude')
  $(this).fadeOut 'fast'
  last_try_tier.delay(800).fadeIn 'fast' 
  return

# Below - Creates a Layergroup for addToMap function 
layer_group = new L.layerGroup()

# Adds the Census output result ot the map as geoJson and sets form field values
addToMap = (geojson, lat, lng) -> 
  geojsonLayer = L.geoJson(geojson, onEachFeature: (feature, layer) ->
    layer.bindPopup("<p class='text-18 mb-0'>" + geojson.features[0].properties.NAME + "</p>")
    layer.options.color = 'rgba(100, 84, 150, 0.5)'
    return
  )
  layer_group.clearLayers()
  layer_group.addLayer(geojsonLayer)
  map.addLayer(layer_group)
  # Opens popup dialog
  layer_group.eachLayer (layer) ->
    layer.eachLayer (layer) ->
      layer.openPopup()
      map.fitBounds layer.getBounds()
      return
    return
  #L.geoJSON(geojson, style: 'color': 'rgba(100, 84, 150, 0.5)').addTo(map).bindPopup("<p class='text-15 mb-0'>" + geojson.features[0].properties.NAME + "</p>").openPopup()
  # Below - Fills in city information into form fields
  city_name.val geojson.features[0].properties.NAME
  city_lat_lng.val JSON.stringify(geojson.features[0].geometry)
  state_id.val geojson.features[0].properties.state
  geo_id.val geojson.features[0].properties.GEOID
  # Below - Centers the map around the returned layer area
  if submit_map_btn.hasClass('disabled')
    submit_map_btn.removeClass 'disabled'
    submit_map_btn.removeClass 'action'
    submit_map_btn.addClass 'button-cs'
    submit_arrow_btn.addClass 'add'
  $([
    document.documentElement
    document.body
  ]).animate { scrollTop: submit_map_btn.offset().top }, 500
  
  return

# Below - Used to set the call census button data attributes to the value of the placed marker's lat/lng on the map
setLatLng = (lat, lng, e) ->
  $('#call_census_btn').attr 'data-latitude', lat
  $('#call_census_btn').attr 'data-longitude', lng
  $('#try_again_btn').attr 'data-latitude', lat
  $('#try_again_btn').attr 'data-longitude', lng
  map.setView e.latlng, map._zoom
  e.originalEvent.stopPropagation
  return
  
# Begin - MARKER: Finds and sets lat long of marker on map
# Below - Allows clicking on map for pin
currentMarker = undefined
map.on 'click', (event) ->
  if currentMarker
    currentMarker._icon.style.transition = 'transform 0.35s ease-out'
    currentMarker._shadow.style.transition = 'transform 0.35s ease-out'
    currentMarker.setLatLng event.latlng
    setTimeout (->
      currentMarker._icon.style.transition = null
      currentMarker._shadow.style.transition = null
      return
    ), 350
    return
  currentMarker = L.marker(event.latlng,
    draggable: false
    icon: L.AwesomeMarkers.icon(
      markerColor: 'blue'
      icon: 'thumbtack text-20'
      iconColor: '#F8FAEE')).addTo(map).on('mouseout', (e) ->
    return
  )
  if census_btn.hasClass 'disabled'
    census_btn.removeClass 'disabled'
    census_btn.addClass 'highlighted'
    census_btn.removeClass 'action'
    census_btn.addClass 'button-cs'
    arrow_btn.addClass 'add'
    return
  return
  
# Below - Sets value of button when map is double clicked.
map.on 'click', (e) ->
  setLatLng e.latlng.lat, e.latlng.lng, e
  return

# Below - Sets value of button when map is single clicked.
map.on 'dblclick', (e) ->
  setLatLng e.latlng.lat, e.latlng.lng, e
  return

# End - MARKER: