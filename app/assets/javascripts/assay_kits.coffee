# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.collapse').collapse()
$('.collapser').click ->
    label = $(this).attr('aria-controls')
    $("tr[other-target=" + label + "]").collapse('toggle')
