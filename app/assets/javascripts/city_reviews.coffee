# Javascript for City Review, especially new/edit page. Taggings for City Review love/improve 
  # City Review Taggins
$ ->
  love = [
    'Cleanliness'
    'Friendliness'
    'Parks'
    'The Police'
    'Technology'
    'Safety'
    'Pet Friendly'
    'Biking'
    'Taxes'
    'The People'
    'Traffic'
    'Public Transportation'
    'First Responders'
    'Community'
    'Culture'
    'Small Businesses'
    'Food & Restaurants'
    'Schools / Education'
    'Representatives'
    'Inclusivity'
    'Night Life'
    'Libraries'
    'Senior Care'
    'Arts'
    'Weather / Climate'
    'Universities'
    'Extracurricular'
    'Recreation'
    'Community Gardens'
    'Family Oriented'
    'Heritage'
    'Diversity'
    'Sustainability'
    'Location'
    'Highway Access'
    'Shopping District'
    'Waterfront'
    'Food District'
    'Artisanal'
    'Scenery'
    'Wildlife'
    'Walkable'
    'Housing Options'
    'Career Opportunities'
    'Athletic Opportunities'
    'Entertainment'
    'Downtown'
    'Roads'
    'Environmentally Conscious'
    'Affordable Housing'
    'Affordability'
    'Industry'
    'Kid Friendly'
    'Commuting'
    'Property'
    'Continuous Growth'
    'Business District'
    'Small Town'
    'Sports'
    'Music Scene'
    'Public Events'
    'Employment Opportunity'
    'Career Opportunity'
    'Events'
  ]

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    split(term).pop()

  $('#city_review_love_list').on('keydown', (event) ->
    if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
      event.preventDefault()
    return
  ).autocomplete
    minLength: 0
    source: (request, response) ->
      # delegate back to autocomplete, but extract the last term
      response $.ui.autocomplete.filter(love, extractLast(request.term))
      return
    focus: ->
      # prevent value inserted on focus
      false
    select: (event, ui) ->
      terms = split(@value)
      # remove the current input
      terms.pop()
      # add the selected item
      terms.push ui.item.value
      # add placeholder to get the comma-and-space at the end
      terms.push ''
      @value = terms.join(', ')
      false
  return
$ ->
  improve = [
    'Cleanliness'
    'Roads'
    'Parks'
    'Taxes'
    'Crime'
    'Policing'
    'Water'
    'Traffic'
    'Public Transportation'
    'Community'
    'Culture'
    'Weather / Climate'
    'Small Businesses'
    'Food & Restaurants'
    'Schools / Education'
    'Representatives'
    'Inclusivity'
    'Night Life'
    'Libraries'
    'Senior Care'
    'Arts'
    'Universities'
    'Extracurricular'
    'Recreation'
    'Athletic Opportunities'
    'Community Gardens'
    'Family Friendliness'
    'Sustainability'
    'Heritage'
    'Diversity'
    'Highway Access'
    'Shopping District'
    'Waterfront'
    'Food District'
    'Walking Areas'
    'Foot Traffic'
    'Parking'
    'Housing Options'
    'Employment Opportunities'
    'Career Opportunities'
    'Technology'
    'Safety'
    'Entertainment'
    'Downtown'
    'Environmental Awareness'
    'Affordable Housing'
    'Affordability'
    'Industry'
    'Kid Friendly'
    'Underdeveloped'
    'Bike Paths'
    'Commuting'
    'Property'
    'Growth'
    'Construction'
    'Business District'
    'Noise'
    'Pollution'
    'Regulations'
    'Public Events'
    'Events'
  ]

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    split(term).pop()

  $('#city_review_improve_list').on('keydown', (event) ->
    if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
      event.preventDefault()
    return
  ).autocomplete
    minLength: 0
    source: (request, response) ->
      # delegate back to autocomplete, but extract the last term
      response $.ui.autocomplete.filter(improve, extractLast(request.term))
      return
    focus: ->
      # prevent value inserted on focus
      false
    select: (event, ui) ->
      terms = split(@value)
      # remove the current input
      terms.pop()
      # add the selected item
      terms.push ui.item.value
      # add placeholder to get the comma-and-space at the end
      terms.push ''
      @value = terms.join(', ')
      false
  return
