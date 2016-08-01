# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require e_markerclusterer
#= require gmaps/google
#= require bootstrap-slider

# Load the Visualization API and the corechart package.
google.charts.load 'current', 'packages': [ 'corechart' ]

gmapHandler = Gmaps.build('Google',
  markers: clusterer:
    gridSize: 50
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
    ignoreHidden: true
    legend: $('#map-data').data('labels')
    legendStyle:
      id: 'gmap-legend'
      class: 'well well-sm'
      css: 'margin-top: 70px; margin-right: 15px; background-color: rgba(255, 255, 255, 0.75); padding: 10px; width: 135px')

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

# set center
gmapDisplayOnMap = (position) ->  
  pos =
    lat: position.coords.latitude
    lng: position.coords.longitude
  marker = new (google.maps.Marker)(
    icon:
      path: google.maps.SymbolPath.CIRCLE
      scale: 5
      strokeColor: "#00003F"
      strokeOpacity: 0.5
    map: gmap
    title: 'Current Position'
    animation: google.maps.Animation.DROP
    position: pos)
  gmap.setCenter pos

# selected list
gmapSelected = 
  assay: {},
  equipment: {},
  timescale: 1

Gmaps.store = {}
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
  Gmaps.store.markers = []
  Gmaps.store.markers = $('#map-data').data('markers').map((m) ->
    marker = gmapHandler.addMarker(m)
    _.extend marker, m
    if marker.hasOwnProperty('days') and marker['days'] < 7
      marker.serviceObject.setVisible(true)
    else
      marker.serviceObject.setVisible(false)
    gmapSelected['equipment'][m['equipment']] = true
    gmapSelected['assay'][m['assay']] = true
    marker
  )
  #Gmaps.store.markers = gmapHandler.addMarkers $('#map-data').data('markers')
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition gmapDisplayOnMap

# google map object
gmap = gmapHandler.getMap()

# Create the search box and link it to the UI element.
gmapInput = document.getElementById('map-input')
gmapSearchPlace = new (google.maps.places.SearchBox)(gmapInput)
gmap.controls[google.maps.ControlPosition.LEFT_TOP].push gmapInput

# Bias the SearchBox results towards current map s viewport.
gmap.addListener 'bounds_changed', ->
  gmapSearchPlace.setBounds gmap.getBounds()
  return

markers = []
gmapSearchPlace.addListener 'places_changed', ->
  places = gmapSearchPlace.getPlaces()
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

# show equipment list
gmapEquipment = document.getElementById('map-assaylist')
gmapEquipment.index = 11
gmap.controls[google.maps.ControlPosition.RIGHT_TOP].push gmapEquipment

# time slider
$('#map-timeslider').slider
  tooltip: 'always'
  orientation: 'vertical'
  tooltip_position: 'left'
  formatter: (value) ->
    ['1 day', '1 week', '1 month', '1 quarter', 'half year', '1 year', '2 years', 'whole'][value]
gmapTimeSlider = document.getElementById('time-slider')
gmap.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push gmapTimeSlider


# marker selection
gmapMarkerRedraw = ->
  days = [1, 7, 30, 90, 180, 365, 730, Infinity]
  Gmaps.store.markers.forEach (marker) ->
    marker.serviceObject.setVisible(gmapSelected['equipment'][marker['equipment']] and gmapSelected['assay'][marker['assay']] and (marker['days'] < days[gmapSelected['timescale']]))
  gmapHandler.clusterer.serviceObject.repaint()

# selected marker changed by assay or equipment
$('#map-assaylist input:checkbox').on 'change', ->
  head = $(this).attr('head')
  name = $(this).attr('name')
  len = $('#map-' + head + '-list input:checked').length
  $('#map-' + head + '-badge').html len
  gmapSelected[head][name] = this.checked
  gmapMarkerRedraw()

$('#time-slider').on 'change', (event) ->
  gmapSelected['timescale'] = event.value.newValue
  gmapMarkerRedraw()

  