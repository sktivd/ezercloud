# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# Load the Visualization API and the corechart package.
google.charts.load 'current', 'packages': [ 'corechart' ]

# Load the Visualization API and the corechart package.
# Callback that creates and populates a data table,
# instantiates the pie chart, passes in the data and draws it.
drawChart = ->
  # Create the data table.
  data = new (google.visualization.DataTable)
  data.addColumn 'string', 'Topping'
  data.addColumn 'number', 'Slices'
  data.addRows [
    [
      'Mushrooms'
      3
    ]
    [
      'Onions'
      1
    ]
    [
      'Olives'
      1
    ]
    [
      'Zucchini'
      1
    ]
    [
      'Pepperoni'
      2
    ]
  ]
  # Set chart options
  options = 
    'title': 'How Much Pizza I Ate Last Night'
    'width': 400
    'height': 300
  # Instantiate and draw our chart, passing in some options.
  chart = new (google.visualization.PieChart)(document.getElementById('chart_div'))
  chart.draw data, options
  return

# Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback drawChart

gmapHandler = Gmaps.build('Google')

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
    styles: gmapStyle
  internal: id: 'map-canvas'
}, ->
  markers = gmapHandler.addMarkers $('#map-fullscreen').data('hash')
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition gmapDisplayOnMap

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
