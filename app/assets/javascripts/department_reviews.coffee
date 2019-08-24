# Below includes new and edit page JS code for Department Reviews. Scoring and dropdown selection for tags is included here. Department Taggings are listed at bottom
  # javascripts/taggins.coffee. 
$(document).ready ->
  $('#tags_list').show()
  $('#department_like_list').addClass 'government_like_list' 
  $('#department_improve_list').addClass 'government_improve_list'
  government_like = [
    'Staff'
    'Communication'
    'Public Policy'
    'Property Taxes'
    'Ballots / Elections'
    'Taxes'
    'Helpfulness'
    'Budget'
    'Response Time'
    'Little Red Tape'
    'Public Relations'
    'Transparency'
    'Outreach'
    'Diligence'
    'Caring'
    'Patience'
  ]

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    split(term).pop()

  $('.government_like_list').on('keydown', (event) ->
    if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
      event.preventDefault()
    return
  ).autocomplete
    minLength: 0
    source: (request, response) ->
      # delegate back to autocomplete, but extract the last term
      response $.ui.autocomplete.filter(government_like, extractLast(request.term))
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

  government_improve = [
    'Staff'
    'Communication'
    'Public Policy'
    'Property Taxes'
    'Ballots / Elections'
    'Taxes'
    'Helpfulness'
    'Budget'
    'Response Time'
    'Transparency'
    'Red Tape'
    'Public Relations'
    'Outreach'
    'Caring'
    'Patience'
    'Diligence'
  ]

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    split(term).pop()

  $('.government_improve_list').on('keydown', (event) ->
    if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
      event.preventDefault()
    return
  ).autocomplete
    minLength: 0
    source: (request, response) ->
      # delegate back to autocomplete, but extract the last term
      response $.ui.autocomplete.filter(government_improve, extractLast(request.term))
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

  $('#department-star-rating').raty
    scoreName: 'department_review[score]'
    half: true
    size: 30
    starOff: 'fa fa-star-o'
    hints: [
      'Disastrous'
      'Inferior'
      'Adequate'
      'Great'
      'Exceptional'
    ]

  $('#scorable_type_select').on 'change', ->
    $('#tags_list').show()
    $('#department_like_list').val('')
    $('#department_improve_list').val('')
    # Below - Government is selected
    if $(this).val() == 'GovernmentScore'
      $('#department_like_list').addClass 'government_like_list' 
      $('#department_like_list').attr 'placeholder', "EG: 'Staff, Communication, Response Time'"
      $('#department_improve_list').addClass 'government_improve_list'
      $('#department_improve_list').attr 'placeholder', "EG: 'Red Tape, Budget, Taxes'"
      $('#department_improve_list').removeClass 'parks_improve_list schools_improve_list police_improve_list public_improve_list'
      $('#department_like_list').removeClass 'parks_improve_list schools_improve_list police_improve_list public_improve_list'
    # Below - Autocomplete for taggings for Government
      government_like = [
        'Staff'
        'Communication'
        'Public Policy'
        'Property Taxes'
        'Ballots / Elections'
        'Taxes'
        'Helpfulness'
        'Budget'
        'Response Time'
        'Little Red Tape'
        'Public Relations'
        'Transparency'
        'Outreach'
        'Diligence'
        'Caring'
        'Patience'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.government_like_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(government_like, extractLast(request.term))
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
    
      government_improve = [
        'Staff'
        'Communication'
        'Public Policy'
        'Property Taxes'
        'Ballots / Elections'
        'Taxes'
        'Helpfulness'
        'Budget'
        'Response Time'
        'Transparency'
        'Red Tape'
        'Public Relations'
        'Outreach'
        'Caring'
        'Patience'
        'Diligence'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.government_improve_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(government_improve, extractLast(request.term))
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
        
    else if $(this).val() == 'ParkScore'
      $('#department_like_list').addClass 'parks_like_list' 
      $('#department_like_list').attr 'placeholder', "EG: 'Playgrounds, Lakes, Hours'"
      $('#department_improve_list').addClass 'parks_improve_list'
      $('#department_improve_list').attr 'placeholder', "EG: 'Events, Tennis Courts, Soccer Fields'"
      $('#department_improve_list').removeClass 'government_improve_list schools_improve_list police_improve_list public_improve_list'
      $('#department_like_list').removeClass 'government_improve_list schools_improve_list police_improve_list public_improve_list'
      # Below - Parks Taggings 
      parks_like = [
        'Playgrounds'
        'Hours'
        'Lighting'
        'Green Space'
        'Community Events'
        'Family Friendliness'
        'Cooking Out'
        'Scenery'
        'Youth Sports'
        'Adult Sports'
        'Sports / Recreation'
        'Baseball Fields'
        'Dog Friendliness'
        'Accessibility'
        'Equipment Quality'
        'Pavilion'
        'Paved Paths'
        'Trail Paths'
        'Quietness / Seculusion'
        'Soccer Fields'
        'Basketball Courts'
        'Tennis Courts'
        'Fishing'
        'Lakes / Ponds'
        'Biking Trails'
        'Hiking Trails'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.parks_like_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(parks_like, extractLast(request.term))
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
      parks_improve = [
        'Playgrounds'
        'Hours'
        'Lighting'
        'Green Space'
        'Community Events'
        'Family Friendliness'
        'Cooking Out'
        'Scenery'
        'Youth Sports'
        'Adult Sports'
        'Sports / Recreation'
        'Baseball Fields'
        'Dog Friendliness'
        'Accessibility'
        'Equipment Quality'
        'Pavilion'
        'Paved Paths'
        'Trail Paths'
        'Quietness / Seculusion'
        'Soccer Fields'
        'Basketball Courts'
        'Tennis Courts'
        'Fishing'
        'Lakes / Ponds'
        'Biking Trails'
        'Hiking Trails'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.parks_improve_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(parks_improve, extractLast(request.term))
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
    else if $(this).val() == 'SchoolScore'
      $('#department_like_list').addClass 'schools_like_list' 
      $('#department_like_list').attr 'placeholder', "EG: 'Teachers, Safety, Curriculum'"
      $('#department_improve_list').addClass 'schools_improve_list'
      $('#department_improve_list').attr 'placeholder', "EG: 'Sports Team, PTA, Extracurricular'"
      $('#department_improve_list').removeClass 'government_improve_list parks_improve_list police_improve_list public_improve_list'
      $('#department_like_list').removeClass 'government_improve_list parks_improve_list police_improve_list public_improve_list'
      # Below - Schools taggins
      schools_like = [
        'Curriculum'
        'Discipline Policy'
        'Accommodation'
        'Policy'
        'Teachers'
        'Grade Grouping'
        'Building Quality'
        'Sport Facilities'
        'Special Sport Facilities'
        'Multi-Languages'
        'Police On-grounds'
        'Safety'
        'Academic Extracurriculars'
        'Sport Extracurriculars'
        'Books Quality'
        'Books Age'
        'Technology'
        'Computers'
        'Library'
        'Gyms'
        'Surrounding Facilities'
        'Faculty'
        'Guidance Counselor'
        'Health / Nurse'
        'Auditoriums'
        'Arts & Culture'
        'Communication'
        'Diversity'
        'Student Needs'
        'Food Options'
        'Band'
        'STEM Classes'
        'Advanced Placement'
        'College Credits'
        'After-school Programs'
        'PTA'
        'Board of Education'
        'Superintendent'
        'Principal'
        'Tutoring Availability'
        'Acceptance'
        'Special Needs'
        'Support Staff'
        'Transparency'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.schools_like_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(schools_like, extractLast(request.term))
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
      schools_improve = [
        'Curriculum'
        'Accommodation'
        'Discipline Policy'
        'Policy'
        'Teachers'
        'Grade Grouping'
        'Building Quality'
        'Sport Facilities'
        'Special Sport Facilities'
        'Multi-Languages'
        'Police On-grounds'
        'Safety'
        'Academic Extracurriculars'
        'Sport Extracurriculars'
        'Books Quality'
        'Books Age'
        'Technology'
        'Computers'
        'Library'
        'Gyms'
        'Surrounding Facilities'
        'Faculty'
        'Guidance Counselor'
        'Health / Nurse'
        'Auditoriums'
        'Arts & Culture'
        'Communication'
        'Diversity'
        'Student Needs'
        'Food Options'
        'Band'
        'STEM Classes'
        'Advanced Placement'
        'College Credits'
        'After-school Programs'
        'PTA'
        'Board of Education'
        'Superintendent'
        'Principal'
        'Tutoring Availability'
        'Acceptance'
        'Special Needs'
        'Support Staff'
        'Transparency'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.schools_improve_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(schools_improve, extractLast(request.term))
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
    else if $(this).val() == 'PoliceScore'
      $('#department_like_list').addClass 'police_like_list' 
      $('#department_like_list').attr 'placeholder', "EG: 'Selfless, Leniency, Public Policy'"
      $('#department_improve_list').addClass 'police_improve_list'
      $('#department_improve_list').attr 'placeholder', "EG: 'Helpfulness, Training, Tickets'"
      $('#department_improve_list').removeClass 'government_improve_list parks_improve_list schools_improve_list public_improve_list'
      $('#department_like_list').removeClass 'government_improve_list parks_improve_list schools_improve_list public_improve_list'
      # Below - Police Taggings List
      police_like = [
        'Friendliness'
        'Selflessness'
        'Discipline'
        'Communication'
        'Transparency'
        'Use of Force'
        'Public Policy'
        'Response Time'
        'Staff'
        'Budget'
        'Public Relations'
        'Outreach'
        'Eagerness'
        'Caring'
        'Compassion'
        'Patience'
        'Traffic Policy'
        'Training'
        'Helpfulness'
        'Leniency'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.police_like_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(police_like, extractLast(request.term))
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
    
      police_improve = [
        'Under-staffed'
        'Over-staffed'
        'Over-prosecution'
        'Tickets'
        'Friendliness'
        'Selflessness'
        'Discipline'
        'Communication'
        'Transparency'
        'Use of Force'
        'Helpfulness'
        'Public Policy'
        'Response Time'
        'Staff'
        'Budget'
        'Public Relations'
        'Outreach'
        'Eagerness'
        'Caring'
        'Compassion'
        'Patience'
        'Traffic Policy'
        'Training'
        'Helpfulness'
        'Leniency'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.police_improve_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(police_improve, extractLast(request.term))
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

    else if $(this).val() == 'PublicScore'
      $('#department_like_list').addClass 'public_like_list' 
      $('#department_like_list').attr 'placeholder', "EG: 'Effectiveness, Water Quality, Roads'"
      $('#department_improve_list').addClass 'public_improve_list'
      $('#department_improve_list').attr 'placeholder', "EG: 'Construction, Trash Pickup, Recycling'"
      $('#department_improve_list').removeClass 'government_improve_list parks_improve_list police_improve_list schools_improve_list'
      $('#department_like_list').removeClass 'government_improve_list parks_improve_list police_improve_list schools_improve_list'
      # Below - public Taggings List
      public_like = [
        'Communication'
        'Effectiveness'
        'Efficiency'
        'Water Quality'
        'Roads'
        'Construction'
        'Response Time'
        'Trash Pickup'
        'Service Department'
        'Recycling'
        'Staff'
        'Snow Plowing'
        'Road Safety'
        'Little Red Tape'
        'Budget'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.public_like_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(public_like, extractLast(request.term))
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
      public_improve = [
        'Red Tape'
        'Communication'
        'Effectiveness'
        'Efficiency'
        'Water Quality'
        'Roads'
        'Construction'
        'Response Time'
        'Trash Pickup'
        'Service Department'
        'Recycling'
        'Staff'
        'Snow Plowing'
        'Road Safety'
        'Budget'
      ]
    
      split = (val) ->
        val.split /,\s*/
    
      extractLast = (term) ->
        split(term).pop()
    
      $('.public_improve_list').on('keydown', (event) ->
        if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
          event.preventDefault()
        return
      ).autocomplete
        minLength: 0
        source: (request, response) ->
          # delegate back to autocomplete, but extract the last term
          response $.ui.autocomplete.filter(public_improve, extractLast(request.term))
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
    else
      $('#tags_list').hide()
      $('#department_like_list').val('')
      $('#department_improve_list').val('')
    return
