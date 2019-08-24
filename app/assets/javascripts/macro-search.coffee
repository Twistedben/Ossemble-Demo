# File for loading macro search across website in navbar for cities and people

#$(document).on 'turbolinks:load', ->
#  $input = $('#macro_search')
#  options =
#    getValue: 'name'
#    requestDelay: 275
#    url: (phrase) ->
#      '/macro_search.json?q=' + phrase
#    template:
#      type: 'description'
#      fields: 
#        description: 'location'
#
#    categories: [
#      {
#        listLocation: 'cities'
#        header: "<div class='border-bottom padding-l-5'><span class='theme_color_darkest'><i class='fas fa-city margin-r-8'></i><strong class='text-18'>Cities</span></strong></div>"
#
#      }
#      {
#        listLocation: 'users'
#        header: "<div class='border-bottom padding-l-5'><span class='theme_color_darkest'><i class='fas fa-users margin-r-8'></i><strong class='text-18'>People</span></strong></div>"
#
#      }
#    ]
#    list: 
#      sort:
#        enabled: true
#      showAnimation:
#        type: 'slide'
#        time: 200
#        callback: ->
#      hideAnimation:
#        type: 'slide'
#        time: 200
#        callback: ->
#      onChooseEvent: ->
#        url = $input.getSelectedItemData().url
#        $input.val ''
#        window.location.href = url
#        return
#  $input.easyAutocomplete options
  