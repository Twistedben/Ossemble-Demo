# CHatrooms coffee for admins conversations and chatrooms and tags in new resources
#jQuery ->
#  $('[data-behavior="autocomplete"]').atwho(
#    at: "@", 
#    'data': " /conversations.json"
#    );
#
#scrollWin = ->
#  $('#conversation_console div.col-tier').last()[0].scrollIntoView false
#
#
#$(document).on "turbolinks:load", ->
#  $("#message_body").on "keypress", (e) ->
#    if e && e.keyCode == 13
#      e.preventDefault()
#      $("#send_message").submit()
#      $("#message_body").val("")
#      setTimeout scrollWin, 200
