#$('#privilege_period').datepicker
#  format: "yyyy-mm-dd"
#  clearBtn: true
#  autoclose: true
#  todayHighlight: true
$('#role_from').datetimepicker
  format: 'YYYY-MM-DD HH:mm Z'
$('#role_to').datetimepicker
  format: 'YYYY-MM-DD HH:mm Z'

$('#roles-role-section').on 'change', '#role_role', (event) ->
  $.ajax '/accounts/roles/get_fields',
    type: 'GET'
    dataType: 'script'
    data: {
      role: $('#role_role :selected').val()
      account:
        id: $('#new_role').data('account-id')
    }
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      console.log("Dynamic select OK!")

# google map object
gmapInput = document.getElementById('role_location')
gmapSearchPlace = new (google.maps.places.SearchBox)(gmapInput)
gmapSearchPlace.addListener 'places_changed', ->
  places = gmapSearchPlace.getPlaces()
