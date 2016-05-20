# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('#ak-reagent-checkboxes .ak-reagent-checkbox input:checkbox').on 'change', ->
  len = $('#ak-reagent-checkboxes input[name="assay_kit[reagent_list][]"]:checked').length
  $('#ak-badge').html len

