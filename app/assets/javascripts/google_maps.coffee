# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require gmaps/google

## Load the Visualization API and the corechart package.
#google.charts.load 'current', 'packages': [ 'corechart' ]
#
## Load the Visualization API and the corechart package.
## Callback that creates and populates a data table,
## instantiates the pie chart, passes in the data and draws it.
#drawChart = ->
#  # Create the data table.
#  data = new (google.visualization.DataTable)
#  data.addColumn 'string', 'Topping'
#  data.addColumn 'number', 'Slices'
#  data.addRows [
#    [
#      'Mushrooms'
#      3
#    ]
#    [
#      'Onions'
#      1
#    ]
#    [
#      'Olives'
#      1
#    ]
#    [
#      'Zucchini'
#      1
#    ]
#    [
#      'Pepperoni'
#      2
#    ]
#  ]
#  # Set chart options
#  options = 
#    'title': 'How Much Pizza I Ate Last Night'
#    'width': 400
#    'height': 300
#  # Instantiate and draw our chart, passing in some options.
#  chart = new (google.visualization.PieChart)(document.getElementById('chart_div'))
#  chart.draw data, options
#  return
#
## Set a callback to run when the Google Visualization API is loaded.
#google.charts.setOnLoadCallback drawChart

gmapHandler = Gmaps.build('Google',
  markers: clusterer:
    gridSize: 30
    maxZoom: 25)

gmapStyle = [
  { stylers: [
    { saturation: '-75' }
    { lightness: '50' }
  ] }
  {
    featureType: 'poi'
    stylers: [ { visibility: 'off' } ]
  }
  {
    featureType: 'transit'
    stylers: [ { visibility: 'off' } ]
  }
  {
    featureType: 'road'
    stylers: [
      { lightness: '20' }
      { visibility: 'on' }
    ]
  }
  {
    featureType: 'landscape'
    stylers: [ { lightness: '50' } ]
  }
]

gmapTypeControlOptions = {
    mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.TERRAIN, google.maps.MapTypeId.SATELLITE, google.maps.MapTypeId.HYBRID]
    position: google.maps.ControlPosition.LEFT_BOTTOM
    style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR
}

# markers
gmapMarkers = []

gmapDisplayOnMap = (position) ->
  marker = gmapHandler.addMarker(
    'lat': position.coords.latitude
    'lng': position.coords.longitude
    'infowindow': 'Current Position')
  gmapHandler.map.centerOn marker

gmapHandler.buildMap {
  provider: 
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true
    zoomControl: true
    scaleControl: true
    scrollwheel: true
    mapTypeControl: true
    mapTypeControlOptions: gmapTypeControlOptions
    styles: gmapStyle
  internal: id: 'map-canvas'
}, ->
  gmapMarkers = gmapHandler.addMarkers $('#map-fullscreen').data('hash')
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition gmapDisplayOnMap

# google map object
gmap = gmapHandler.getMap()

# Create the search box and link it to the UI element.
gmapInput = document.getElementById('map-input')
gmapSearchBox = new (google.maps.places.SearchBox)(gmapInput)
gmap.controls[google.maps.ControlPosition.LEFT_TOP].push gmapInput

# Bias the SearchBox results towards current map s viewport.
gmap.addListener 'bounds_changed', ->
  gmapSearchBox.setBounds gmap.getBounds()
  return

markers = []
gmapSearchBox.addListener 'places_changed', ->
  places = gmapSearchBox.getPlaces()
  if places.length == 0
    return
  # Clear out the old markers.
  markers.forEach (marker) ->
    marker.setMap null
    return
  markers = []
  # For each place, get the icon, name and location.
  bounds = new (google.maps.LatLngBounds)
  places.forEach (place) ->
    icon = 
      url: place.icon
      size: new (google.maps.Size)(71, 71)
      origin: new (google.maps.Point)(0, 0)
      anchor: new (google.maps.Point)(17, 34)
      scaledSize: new (google.maps.Size)(25, 25)
    # Create a marker for each place.
    markers.push new (google.maps.Marker)(
      map: gmap
      icon: icon
      title: place.name
      position: place.geometry.location)
    if place.geometry.viewport
      # Only geocodes have viewport.
      bounds.union place.geometry.viewport
    else
      bounds.extend place.geometry.location
    return
  gmap.fitBounds bounds
  return

#gmapLegend = document.getElementById('map-period')
#for style of ['a', 'b']
#  name = style.name
#  icon = style.icon
#  div = document.createElement('div')
##  div.innerHTML = '<img src="' + icon + '"> ' + name
#  gmapLegend.appendChild div

#gmapHandler.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push document.getElementById('map-peroid')

  
#handler = Gmaps.build('Google')
#handler.buildMap {
#  provider: {}
#  internal: id: 'map-canvas'
#}, ->
#  markers = handler.addMarkers([ {
#    'lat': 0
#    'lng': 0
#    'picture':
#      'url': 'http://people.mozilla.com/~faaborg/files/shiretoko/firefoxIcon/firefox-32.png'
#      'width': 32
#      'height': 32
#    'infowindow': 'hello!'
#  } ])
#  handler.bounds.extendWith markers
#  handler.fitMapToBounds()
#  return


##gmapHandler.addMarkers(<%= raw @hash.to_json %>)
##gmapHandler.addMarkers $('#map-fullscreen').data('hash')
#

#  markers = gmapHandler.addMarkers([ {
#    'lat': 36
#    'lng': 127
#    'picture':
#      'url': 'http://people.mozilla.com/~faaborg/files/shiretoko/firefoxIcon/firefox-32.png'
#      'width': 32
#      'height': 32
#    'infowindow': 'hello!'
#  } ])