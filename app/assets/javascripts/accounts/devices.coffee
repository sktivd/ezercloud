# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery-ui


$('#device_license_serial_number').autocomplete
  source: (request, response) ->
    $.ajax
      url: '/accounts/devices/autocomplete_sn'
      dataType: 'json'
      data:
        term: request.term
        equipment_id: $('#device_license_equipment_id :selected').val()
      success: (data) ->
        response data
        return
    return
  minLength: 2

$('#activated_at .input-group').datetimepicker
  format: 'YYYY-MM-DD HH:mm Z'
