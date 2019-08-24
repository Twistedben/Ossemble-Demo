# File for loading ossembly search inside Ossembly Forum feeds to find Posts, Subtopics, and Petitions.
$(document).ready ->
  $ossembly = $('#ossembly_search')
  $city = $('#ossembly_search').data('location')
  options =
    getValue: 'name'
    requestDelay: 275
    url: (phrase) ->
      '/' + $city + '=ossembly_search.json?q=' + phrase
    template:
      type: 'description'
      fields: 
        description: 'extra_info'
    categories: [
      {
        listLocation: 'topics'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/" +$city + "/ossembly'><span class=''><i class='fas fa-heart margin-r-8'></i><strong class='text-18'>Topics</span></strong></div>"
      }
      {
        listLocation: 'subtopics'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/" +$city + "/ossembly'><span class=''><i class='fas fa-heart margin-r-8'></i><strong class='text-18'>Subtopics</span></strong></div>"
      }
     {
        listLocation: 'posts'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/" +$city + "/ossembly'><span class=''><i class='fas fa-comments margin-r-8'></i><strong class='text-18'>Conversations - Posts</span></strong></div></a>"
      }
      {
        listLocation: 'petitions'
        header: "<div class='border-bottom padding-l-5'><a class='title_link padding-b-8' href='/cities/" +$city + "/petitions'><span class=''><i class='fas fa-clipboard margin-r-8'></i><strong class='text-18'>Petitions</span></strong></div></a>"
      }
    ]
    list: 
      sort:
        enabled: true
      maxNumberOfElements: 20
      showAnimation:
        type: 'slide'
        time: 200
        callback: ->
      hideAnimation:
        type: 'slide'
        time: 200
        callback: ->
      onChooseEvent: ->
        url = $ossembly.getSelectedItemData().url
        $ossembly.val ''
        window.location.href = url
        return
  $ossembly.easyAutocomplete options