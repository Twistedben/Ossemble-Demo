# $(document).ready ->
  #Get current time
  # currentTime = (new Date).getTime()
  #Add hours function

  # Date::addHours = (h) ->
    # @setTime @getTime() + h * 60 * 60 * 1000
    # this

  #Get time after 24 hours
  # after24 = (new Date).addHours(10).getTime()
  #Hide div click
  # $('#closeSPLink').click ->
    #Hide div
    # $('#workplace_sidepanel').css("width", "0px")
    #Set desired time till you want to hide that div
    # localStorage.setItem 'desiredTime', after24
    # return
  #If desired time >= currentTime, based on that HIDE / SHOW
  # if localStorage.getItem('desiredTime') >= currentTime
    # $('#workplace_sidepanel').css("width", "0px")
  # else
    # $('#workplace_sidepanel').css("width", "210px")
  # return
  
