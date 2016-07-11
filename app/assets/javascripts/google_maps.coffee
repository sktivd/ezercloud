# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require e_markerclusterer
#= require gmaps/google

# Load the Visualization API and the corechart package.
google.charts.load 'current', 'packages': [ 'corechart' ]

gmapHandler = Gmaps.build('Google',
  markers: clusterer:
    gridSize: 30
    maxZoom: 25
    styles: [
      {
        height: 60
        width: 60
      }
      {
        height: 80
        width: 80
      }
      {
        width: 100
        height: 100
      }
    ]
    legend: $('#map-data').data('labels')
    legendStyle:
      id: 'gmap-legend'
      class: 'well well-sm'
      css: 'margin-top: 70px; margin-right: 15px; background-color: rgba(255, 255, 255, 0.75); padding: 10px; width: 123px')

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
  gmapMarkers = gmapHandler.addMarkers $('#map-data').data('markers')
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
