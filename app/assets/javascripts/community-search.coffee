# File for loading community search inside Score feed to search for Complaints, Department Reviews, and City Reviews.
$(document).ready ->
  $community = $('#community_search')
  $city = $('#community_search').data('location')
  options =
    getValue: 'name'
    requestDelay: 275
    url: (phrase) ->
      '/' + $city + '=community_search.json?q=' + phrase
    template:
      type: 'description'
      fields: 
        description: 'extra_info'
    categories: [
      {
        listLocation: 'city_reviews'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/cities/" +$city + "/whatyoulove'><span class=''><i class='fas fa-heart margin-r-8'></i><strong class='text-18'>City Reviews - What You Love</span></strong></div>"
      }
     {
        listLocation: 'complaints'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/cities/" +$city + "/complaints'><span class=''><i class='fas fa-map-marker margin-r-8'></i><strong class='text-18'>Voiced Complaints</span></strong></div></a>"
      }
      {
        listLocation: 'department_reviews'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/cities/" +$city + "/reviews'><span class=''><i class='fas fa-building margin-r-8'></i><strong class='text-18'>Department Reviews</span></strong></div></a>"
      }
    ]
    list: 
      sort:
        enabled: true
      match:
        enabled: true
      maxNumberOfElements: 15
      showAnimation:
        type: 'slide'
        time: 200
        callback: ->
      hideAnimation:
        type: 'slide'
        time: 200
        callback: ->
      onChooseEvent: ->
        url = $community.getSelectedItemData().url
        $community.val ''
        window.location.href = url
        return
  $community.easyAutocomplete options