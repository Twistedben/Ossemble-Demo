# Main Javascript file for Complaints. Especially COmplaints new/edit pages. 
  # Outputs and Category select and inputs and deadlines for complaints.
  
$(document).ready ->
  $('#deadline_select').hide()
  $('#title_input').hide()
  $('#deadline_output').hide()


  $('#category_select').append $('<option value="1">Other</option>')
  $('#category_select').on 'change', ->
    if @value == '6'
      $('#complaint_pic').hide()
    else
      $('#complaint_pic').show()
    return
  $('#category_select').change ->
    if $(this).val() == '1'
      # Hides the deadline value if Other is selected, and shows title input and deadline input.
      $('#deadline_select').show()
      $('#title_input').show()
      $('#deadline_output').hide()
      $('#deadline_input option[value="2"]').text '7 Days'
      $('#deadline_input option[value="3"]').text '14 Days'
      $('#deadline_input option[value="4"]').text '30 Days'
      $('#deadline_input option[value="5"]').text '60 Days'
      $('#deadline_input').val('')
      $('#deadline_input').attr 'disabled', false
    else if $(this).val() == ''
      $('#deadline_output').hide()
      $('#deadline_input').val('')
      $('#complaint_title').val('')
      # Hides the custom deadline input and title if Other is not selected.
    else
      $('#deadline_output').show()
      $('#deadline_select').hide()
      $('#title_input').hide()
      $('#deadline_input').val('')
      $('#complaint_title').val('')
      $('#deadline_input').attr 'disabled', true
    return
  # Below - Outputs the days assigned to pre-defined categories
  $('#category_select').change ->
    if $(this).val() >= 6 and $(this).val() <= 9
      $('#deadline_day_output').text '7 Days'
    else if $(this).val() >= 10 and $(this).val() <= 12
      $('#deadline_day_output').text '14 Days'
    else if $(this).val() >= 13 and $(this).val() <= 15
      $('#deadline_day_output').text '30 Days'
    else if $(this).val() >= 16 and $(this).val() <= 17
      $('#deadline_day_output').text '60 Days'
    return
  if document.getElementById('error-panel')
    if $('#category_select :selected').text == 'Choose Complaint Category'
      $('#category_select').addClass 'invalid'
      $('#category_select').prop('selectedIndex', 0)
      $('#category_select :selected').val = ''
    else 
      $('#category_select').prepend $('<option value="">Choose Complaint Category</option>')
      $('#category_select').addClass 'invalid'
      $('#category_select').prop('selectedIndex', 0)
      $('#category_select :selected').val = ''
    return 
  return
return
