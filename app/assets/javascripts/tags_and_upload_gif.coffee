# First
# When window is resized, loading modal is also resized.
# Below - Code for uploading image gif, modal letting user know.
# Function executed by the click of Submit Post.

# Begin - WUL tag JS
existingTag = (text) ->
  `var text`
  existing = false
  text = text.toLowerCase()
  $('.tags').each ->
    if $(this).text().toLowerCase() == text
      existing = true
      return ''
    return
  existing

$ ->
  $('.tags-new input').keyup ->
    tag = $(this).val().trim()
    length = tag.length
    if tag.charAt(length - 1) == ',' and tag != ','
      tag = tag.substring(0, length - 1)
      if !existingTag(tag)
        $('#app-love1').prepend('<span class="tags"><span>' + tag + '</span><i class="fa fa-times"></i></i></span>')
        $(this).val ''
      else
        $(this).val tag
    return
  $(document).on 'click', '.tags i', ->
    $(this).parent('span').remove()
    return
  return
  
# End - WUL tag JS


# Begin - Improve tag JS
existingTag = (text) ->
  `var text`
  existing = false
  text = text.toLowerCase()
  $('.tags').each ->
    if $(this).text().toLowerCase() == text
      existing = true
      return ''
    return
  existing

$ ->
  $('.tags-new2 input').keyup ->
    tag = $(this).val().trim()
    length = tag.length
    if tag.charAt(length - 1) == ',' and tag != ','
      tag = tag.substring(0, length - 1)
      if !existingTag(tag)
        $('#app-love2').prepend('<span class="tags"><span>' + tag + '</span><i class="fa fa-times"></i></i></span>')
        $(this).val ''
      else
        $(this).val tag
    return
  $(document).on 'click', '.tags i', ->
    $(this).parent('span').remove()
    return
  return
# End - Improve tag JS


# Below - Start Image Upload 
showLoading = ->
  $loading = $('.loading')
  windowH = $(window).height()
  windowW = $(window).width()
  # Creates a shadowed div and adds the modal appearnce with gif.
  $(document.body).append '<div id=\'shadow\' style=\'position:fixed;left:0px;top:0px;width:100%; height:100%; background:black; opacity: 0.5; z-index: 5001 !important;\'></div>'
  $loading.css(
    position: 'fixed'
    left: (windowW - $loading.outerWidth()) / 2 + $(document).scrollLeft()
    top: (windowH - $loading.outerHeight()) / 2 + $(document).scrollTop()).show()
  return

$(window).on 'resize', ->
  $loading = $('.loading')
  windowH = $(window).height()
  windowW = $(window).width()
  $loading.css
    position: 'fixed'
    left: (windowW - $loading.outerWidth()) / 2 + $(document).scrollLeft()
    top: (windowH - $loading.outerHeight()) / 2 + $(document).scrollTop()
  return
# When submit post is clicked, the loading class is toggled.
$ ->
  $('#loadgif').click showLoading
  return
