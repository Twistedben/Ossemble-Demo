# User related view tests.
require 'rails_helper'



RSpec.feature "Users", type: :feature do
  # Below - Logs the user in via real time action and creates a user from Users.rb Factory file.
  def user_logs_in
    @user = create(:user)
    visit new_user_session_path
    within('form') do
      fill_in 'user_email', with: 'Benjaminb@example.com'
      fill_in 'user_password', with: 'password'
    end 
    click_button 'login_btn'
    expect(page).to have_content("You have logged in!")
  end 
   # Below - Sets up a city before each Context so forms dependent on a City being in the database can be properly tested.
  before(:each) do 
    @city = create(:city)
  end
   
  context 'Signs up through Ossemble', type: :user do
    before(:each) do # Before each scenario in this context, go to that route path and ensure elements are on the page.
      visit new_user_registration_path
      within('form') do
        has_button?('facebook_signup_btn')
        has_button?('create_profile_btn')
        has_select?('user_city_id', selected: 'Lakewood')
        has_select?('user_state', selected: 'Ohio')
        has_select?('user_zip', selected: '44107')
        has_field?('user_avatar', type: 'file')
      end 
    end # End - Before each block for scenarios inside this Ossemble signup context 
      scenario "successfully signs up through Ossemble" do 
        within('form') do 
          fill_in 'first_name', with: 'Benjamin'
          fill_in 'user_last_name', with: 'Broestl'
          fill_in 'user_dob', with: '02/09/1991'
          fill_in 'user_email', with: 'ben.broestl@example.com'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirm', with: 'password'
          fill_in 'user_address', with: '18565 Ridge Road'
          fill_in 'user_address2', with: 'Apt. 1'
          select('Male', from: 'gender_select')
          select('Lakewood', from: 'user_city_id').select_option
          select('Ohio', from: 'user_state').select_option
          select('44107', from: 'user_zip').select_option
        end
        click_button 'create_profile_btn'
        expect(page).to have_content('A message with a confirmation link has been sent')
        expect(@city.users).to_not be_empty # Ensures that the user created above has successfully joined the associated City.
      end # End - Successful Ossemble Signup Scenario.
      scenario "fails to sign up through Ossemble due to validation errors" do
        within('form') do 
          fill_in 'first_name', with: 'B'
          fill_in 'user_last_name', with: 'TooLongOfALastNameForValidationMaximumTest'
          fill_in 'user_dob', with: ''
          fill_in 'user_email', with: 'bensgamingmail@example.com'
          fill_in 'user_password', with: 'password2'
          fill_in 'user_password_confirm', with: 'password'
          fill_in 'user_address', with: '1'
          fill_in 'user_address2', with: ''
          select('Male', from: 'gender_select')
          select('Lakewood', from: 'user_city_id').select_option
          select('Ohio', from: 'user_state').select_option
          select('44107', from: 'user_zip').select_option
        end
        click_button 'create_profile_btn'
        expect(page).to have_content('Uh oh!')
        expect(page).to have_content('First name is too short')
        expect(page).to have_content('Last name is too long')
        expect(page).to have_content("Password confirmation doesn't match")
        expect(page).to have_content("Address is too short")
        expect(@city.users).to be_empty # Ensures that the user has not been commited to DB of the associated City.
      end # End - Fails Ossemble signup scenario.  
  end  # End - Ossemble sign up Context.
  
  context 'User logins', type: :user do
    before(:each) do # Before each scenario in this context, go to that route path and ensure elements are on the page.
      @user = create(:user)
      visit new_user_session_path
      within('form') do
        expect(page).to have_field('user_email', type: 'email')
        expect(page).to have_field('user_password', type: 'password')
        expect(page).to have_button('login_btn')
      end 
    end # End - Before each block for scenarios inside this Ossemble logs in context.
      scenario 'successfully logins through Ossemble' do 
        within('form') do
          fill_in 'user_email', with: 'Benjaminb@example.com'
          fill_in 'user_password', with: 'password'
        end 
        click_button 'login_btn'
        expect(page).to have_content("You have logged in!")
      end # End - Successful Ossemble Login Scenario.
      scenario 'fails to login through Ossemble' do 
        within('form') do
          fill_in 'user_email', with: 'Benjaminb@example.comd'
          fill_in 'user_password', with: 'password4'
        end 
        click_button 'login_btn'
        expect(page).to have_content("Invalid Email or password.")
      end # End - Failing Ossemble Login Scenario.
  end # End - User Logins context.
  
  context 'User logs out', type: :user do
    before(:each) do # Before each scenario in this context, go to that route path and ensure elements are on the page.
      user_logs_in
    end # End - Before each block for scenarios inside this Ossemble log out context 
    scenario 'successfully logs out' do
      click_link 'dropdownMenuLink'
      click_link 'logout_link'
      expect(page).to have_content("You have logged out.") 
    end
  end 
  
  context 'User visits show page', type: :user do
    before(:each) do # Before each scenario in this context, go to that route path and ensure elements are on the page.
     user_logs_in
    end
    scenario 'a user sucessfully visits profile show page' do
      click_link 'dropdownMenuLink'
      click_link 'profile_link' 
      expect(page).to have_link('li')
      expect(page).to have_content("Benjamin's Profile Page")
      expect(page).to have_content("#{@user.city.name} Resident")  
    end
  end 
  
  context 'User updates their profile', type: :user do
    before(:each) do # Before each scenario in this context, go to that route path and ensure elements are on the page.
      user_logs_in
    end # End - Before each block for scenarios inside this  update context .
    scenario 'successfully updates their profile' do
      visit edit_user_registration_path
      within('form') do
        fill_in 'first_name', with: 'Billy'
        fill_in 'user_last_name', with: 'Bob'
      end
      click_button 'update_profile_btn'
      expect(@user).to be_valid
      expect(page).to have_content("Your account has been updated successfully.")
    end # End - Succeeds updating context.
    scenario 'fails to update their profile' do
      visit edit_user_registration_path
      within('form') do
        fill_in 'first_name', with: 'B'
        fill_in 'user_last_name', with: 'B'
      end
      click_button 'update_profile_btn'
      expect(page).to have_content("Uh oh!")
      expect(page).to have_content("First name is too short")
      expect(page).to have_content("Last name is too short")
    end # End - Fail to update context.
  end 
  
  context 'User deletes their account' do
    
  end 

# Will test when Mailerlite works
=begin  
  context 'User subscribes through mailerlite' do
    
  end 
  

  context 'User subscribes through mailerlite', type: :user do
    scenario 'successfully requests a city' do
      visit root_path
      click_button('request_city_btn', text: 'Request City')
        page.has_field?('fields[email]', type: 'email')
        fill_in('email', with: 'BenjaminB@example.com')
        fill_in('fields[name]', with: 'Benjamin Broestl')
        fill_in('fields[city]', with: 'North Royalton')
        fill_in('fields[zip]', with: '44133')
        has_css?('btn primary', type: 'submit').click
      
    end
  end 
=end 

end