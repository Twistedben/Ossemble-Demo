# Department related view tests.
require 'rails_helper'

RSpec.feature "Departments", type: :feature do
   
  context 'Department index page', type: :department do
   # Below - Sets up a city, a department, and their association before each Context so department pages can be properly tested.
   before (:each) do
      @city = create(:city)
      @city_2 = create(:city_2)
      @department = create(:department)
      @city_departments = @city.departments
      @city_2_departments = @city_2.departments # Should be empty
    end # End - Before creation of city and department.
    scenario "department successfully appears in index" do
      visit city_departments_path(@city) # Visits Lakewood Departments to test existing department.
      # Begin - Tests view panel
      within '#ms_view_panel_center' do 
        expect(page).to have_link("List View")
        expect(page).to have_css(".disabled.underline") 
        puts "View panel test passed"
      end
      # End - Tests view panel
      within '#departments_list' do
        expect(page).to have_link('City Hall', href: '/cities/lakewood/departments/city-hall') # Tests friendly ID.
        expect(page).to have_css('p#dep_score')
        expect(page).to have_content('80%') # Tests score tracking
        expect(page).to have_css('i.fa-university')   # Tests icon next to title in relation to Department type.
      end
      expect(@city_departments).to_not be_empty
    end # End - Department index successful scenario.
 
    scenario "department without a city fails to appear" do
      visit city_departments_path(@city_2) # Visits Unpopulated City Departments to test nonexistent department.
        expect(page).to_not have_link('City Hall', href: '/cities/north-royalton/departments/city-hall')
        expect(@city_2_departments).to be_empty
    end # End - Department index from another city failing scenario.
    scenario "department belonging to a separate city appears only there" do
      @department_2 = create(:department_2)
      @city_2.departments << @department_2
      visit city_departments_path(@city_2) # Visits Unpopulated City Departments to test nonexistent department.
        within '#departments_list' do
          expect(page).to have_link('North Royalton', href: '/cities/north-royalton/departments/north-royalton-high-school')
        end
      expect(@city_2_departments.size).to eq(1)
    end
  end # End - Department index context.
  
  context 'Department show page', type: :department do
  # Below - Sets up a city, a department, and their association before each Context so department pages can be properly tested.
    before (:each) do
      @city = create(:city)
      @department = create(:department)
      @city_departments = @city.departments
    end # End - Before creation of city and department.
    scenario "department successfully appears in show" do
      visit city_department_path(@city, @department)
        within 'div.col-d-7.col-t-10.col-p-12.center' do 
          expect(page).to have_content('City Hall')
          expect(page).to have_css('div.map_area')
          expect(page).to have_css('div#oss_map')
        end
      expect(page).to have_link('Write a Review', href: new_city_department_review_path(@city, @department))
    end # End - Department show page success scenario.
  end # End - Department show page context.
  
  context 'Department Reviews', type: :department do
    # Below - Sets up a city, a department, and their association before each Context so department pages can be properly tested.
    before (:each) do
      @city = create(:city)
      @department = create(:department)      
      @city_departments = @city.departments
      @user = create(:user)
      #@review = Review.create(id: 1, description: "This is an amazing review of City Hall", score: 50, department_id: 1, user_id: 1)
    end # End - Before creation of city and department.
    scenario "department is properly linked to review" do
      visit city_department_path(@city, @department)
        expect(page).to have_link('Write a Review', href: new_city_department_review_path(@city, @department))
        click_link ('Write a Review')
        expect(page).to have_content('New Review')
      # DUe to Javascript issues with Capybara, cannot test giving a rating in real time to department review.
    end # End - Department review successful scenario.
    
    scenario "department fails to be reviewed due to validations" do
      visit new_user_session_path
        fill_in 'user_email', with: 'Benjaminb@example.com'
        fill_in 'user_password', with: 'password'
        click_button 'login_btn'
        expect(page).to have_content("You have logged in!")
      visit city_department_path(@city, @department)
        expect(page).to have_link('Write a Review', href: new_city_department_review_path(@city, @department))
        click_link ('Write a Review')
        expect(page).to have_content('New Review')
        click_on('Submit Review')
        expect(page).to have_content("Could not post your review")
        expect(page).to have_content("issues need to be corrected")
        expect(@department.reviews).to be_empty
    end # End - Department review failing scenario.
  end   # End - Department Review context.
  
end # End - Departments feature testing suite.
