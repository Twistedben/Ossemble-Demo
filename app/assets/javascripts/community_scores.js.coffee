# Below - Creates accordian effect on all communityscore pages on down when on mobile and tablet.  
$ ->
  $('#ms_ap_content').accordion
    heightStyle: 'content'
    collapsible: true
    active: false
  return
