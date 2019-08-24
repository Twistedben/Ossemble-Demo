# Fixes the tier and col-tier issue from desktop to phone with the list being squashed.
  # TODO: Find a way to fix this using pure HTML instead of JS.
#$(document).ready ->
#  if $(window).width() < 768
#    $('#resource_list').addClass 'col-tier'
#  else
#    $('#resource_list').removeClass 'col-tier'
#  return
# On resize - Recenters the view panel.
#$(window).resize ->
#  if $(window).width() < 768
#    $('#resource_list').addClass 'col-tier'
#  else
#    $('#resource_list').removeClass 'col-tier'
#  return
#return