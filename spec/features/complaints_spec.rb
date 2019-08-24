# Complaint related view tests.
require 'rails_helper'

RSpec.feature "Complaints", type: :feature do
  
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
    
  before (:each) do
    @city = create(:city)
    user_logs_in
    @user_2 = create(:user_2, city_id: 1)
    @user_2 = create(:user_3, city_id: 1)
    @user_2 = create(:user_4, city_id: 1)
    @user_2 = create(:admin_user, city_id: 1)
    @category_1  = create(:complaint_category_1)
    @category_2  = create(:complaint_category_2)
    @category_3  = create(:complaint_category_3)
    @category_4  = create(:complaint_category_4)
    @complaint   = create(:complaint_v)
    @complaint_p = create(:complaint_p, user_id: 2)
    @complaint_f = create(:complaint_f, user_id: 3)
    @complaint_c = create(:complaint_c, user_id: 4)
    @complaint_failed = create(:complaint_failed, user_id: 5)
  end 
  
  context 'Complaint Index Page', type: :complaint do 
    scenario "complaints successfully appear in index" do
      visit city_complaints_path(@city)
        within 'div#complaints_list' do 
          expect(page).to have_css('div.col-d-12.card.bs_hover.light-box-shadow', count: 5)
          expect(page).to have_content('Pothole')
          expect(page).to have_link('Pothole', href: '/cities/lakewood/complaints/pothole') # Tests friendly ID.
          expect(page).to have_content('Trash')
          expect(page).to have_link('Trash', href: '/cities/lakewood/complaints/trash') # Tests friendly ID.
          expect(page).to have_content('Graffiti')
          expect(page).to have_link('Graffiti', href: '/cities/lakewood/complaints/graffiti') # Tests friendly ID.
          expect(page).to have_content('Water')
          expect(page).to have_link('Water', href: '/cities/lakewood/complaints/water') # Tests friendly ID.
          expect(page).to have_content('80%') # Tests score tracking
          expect(page).to have_content('40%') # Tests score tracking
          expect(page).to have_content('Waiting for Endorsements') # Tests process 
          expect(page).to have_content('Awaiting Verification') # Tests process 
          expect(page).to have_content('Completed') # Tests process 
          expect(page).to have_content('Sent to City') # Tests process 
          expect(page).to have_content('Failed') # Tests process 
        end
      expect(@city.complaints).to_not be_empty
      expect(@city.complaints.size).to eq(5)
    end
    scenario "verifying complaint shows in filtered complaints" do 
      visit verifying_city_complaints_path(@city)
        within 'div#complaints_list' do 
          expect(page).to have_css('div.col-d-12.card.bs_hover.light-box-shadow', count: 1)
          expect(page).to have_content('Pothole')
        end 
    end  
    scenario "pending complaint shows in filtered complaints" do 
      visit pending_city_complaints_path(@city)
        within 'div#complaints_list' do 
          expect(page).to have_css('div.col-d-12.card.bs_hover.light-box-shadow', count: 1)
          expect(page).to have_content('Trash')
        end 
    end 
    scenario "filed complaint shows in filtered complaints" do 
      visit filed_city_complaints_path(@city)
        within 'div#complaints_list' do 
          expect(page).to have_css('div.col-d-12.card.bs_hover.light-box-shadow', count: 1)
          expect(page).to have_content('Graffiti')
        end 
    end 
    scenario "finished complaint shows in filtered complaints" do 
      visit finished_city_complaints_path(@city)
        within 'div#complaints_list' do 
          expect(page).to have_css('div.col-d-12.card.bs_hover.light-box-shadow', count: 2)
          expect(page).to have_content('Graffiti')
          expect(page).to have_content('Water')
        end 
    end 
    scenario "complaint without a city fails to appear" do    
      @city_2 = create(:city_2)
      visit city_complaints_path(@city_2)
        expect(page).to_not have_link('Pothole', href: '/cities/north-royalton/complaints/pothole')
        expect(page).to_not have_link('Pothole', href: '/cities/lakewood/complaints/pothole')
        expect(@city_2.complaints).to be_empty
    end 
    scenario "complaint belonging to a separate city appears only there" do    
      @city_2 = create(:city_2)
      @user_6 = create(:user, id: 6, email: "Example@example.com")
      @complaint_2 = create(:complaint_v, user_id: 6, id: 6, city_id: 2, latitude: 41.56678, longitude: -81.73425)
      visit city_complaints_path(@city_2)
      @city_2.complaints << @complaint_2
        within 'div#complaints_list' do
          expect(page).to have_css('div.col-d-12.card.bs_hover.light-box-shadow', count: 1)
          expect(page).to have_content('Pothole')
          expect(page).to have_content('Awaiting Verification')
          expect(page).to have_link('Pothole')
          expect(page).to_not have_link('Water')
        end
      expect(@city_2.complaints).to_not be_empty
      expect(@city_2.complaints.size).to eq(1)
    end 
  end
  
  context 'Complaint Show Page', type: :complaint do
    scenario "complaint successfully appears in show" do 
      visit city_complaint_path(@city, @complaint)
        within 'div.col-d-7.col-t-10.col-p-12.center' do 
          expect(page).to have_content('Pothole Complaint')
          expect(page).to have_content('Process')
          expect(page).to have_button('Endorse Complaint')
          expect(page).to have_content('80%')
          expect(page).to have_content('There is a very big pothole')
          expect(page).to have_content('Lakewood')
          expect(page).to have_content('Near the Post Office')
          expect(page).to have_content('Ohio')
          expect(page).to have_content('44107')
          expect(page).to have_content('Submitted:')
          expect(page).to have_content('Benjamin')
          expect(page).to have_content("Lakewood's Response")
          expect(page).to have_css('div.map_area')
          expect(page).to have_css('div#oss_map')
        end
        expect(page).to have_content("Comments")
        expect(page).to have_button("Add Comment")
        expect(page).to have_link('File a Complaint', href: new_city_complaint_path(@city))
    end 
  end 
  
  context 'Complaint Comments', type: :complaint do 
    scenario "complaint comment successfully posts" do 
      visit city_complaint_path(@city, @complaint)
        expect(page).to have_content('Comments and Discussion')
        within 'div#new_comment_tier' do 
          expect(page).to have_content('Discuss this')
          fill_in 'comment_description', with: "This is a Test Comment with Capybara!"
          expect(page).to have_button('Add Comment')
          click_on('Add Comment')
        end 
        expect(page).to have_content("Your comment has successfully")
        within 'div#comments_list' do 
          expect(page).to have_link('Benjamin Broestl')
          expect(page).to have_content("This is a Test Comment with Capybara!")
          expect(page).to have_link('Edit Comment')
        end 
        expect(@complaint.comments).to_not be_empty
        expect(@complaint.comments.size).to eq(1)
    end 
    scenario "complaint comment fails to post" do 
      visit city_complaint_path(@city, @complaint)
        within 'div#new_comment_tier' do 
          click_on('Add Comment')
        end 
      expect(page).to have_content("Comment was not posted")
      expect(page).to have_content("Ensure your comment")
      expect(@complaint.comments).to be_empty
    end 
    scenario "complaint with a comment successfully shows" do 
      @comment = create(:comment)
      @complaint.comments << @comment 
      visit city_complaint_path(@city, @complaint)
        within 'div#comments_list' do 
          expect(page).to have_link('Benjamin Broestl', href: user_path(@user))
          expect(page).to have_content('Posted:')
          expect(page).to have_content('This is a test comment')
          expect(page).to have_button('Endorse')
        end 
      expect(@complaint.comments).to_not be_empty
      expect(@complaint.comments.size).to eq(1)
    end 
  end 
  
  context 'Complaint New Page', type: :complaint do 
    scenario "new complaint page successfully shows" do 
      visit city_complaint_path(@city, @complaint)
        click_link 'File a Complaint'
          within '#new_complaint_form' do 
            expect(page).to have_field('complaint_address', type: 'text')
            expect(page).to have_select('category_select', name: 'complaint[complaint_category_id]')
            expect(page).to have_field('complaint_description', name: 'complaint[description]')
            expect(page).to have_button('Create Complaint')
            expect(page).to have_css('div.oss_map')
            expect(page).to have_css('div#oss_map')
          end 
    end
    scenario 'new complaint fails due to validations' do
      visit new_city_complaint_path(@city)
        within 'form' do 
          fill_in 'complaint_address', with: '15'
          fill_in 'complaint_description', with: 'Short Description'
        end
        click_button 'Create Complaint'
        expect(page).to have_css('div.panel-heading')
          within 'div.panel-heading' do 
            expect(page).to have_content('minimum character length')
            expect(page).to have_content('Complaint Category')
            expect(page).to have_content('click on the map')
            expect(page).to have_content('You can only lodge')
          end 
        expect(@city.complaints.size).to eq(5)
        expect{@complaint.complaint_category.category}.to_not raise_error
    end
  end
  
  context 'Complaint Edit Page', type: :complaint do 
    scenario 'complaint edit page works but fails to be edited due to map' do 
      visit city_complaint_path(@city, @complaint)
        expect(page).to have_link('Edit Your Complaint')
        click_link 'Edit Your Complaint' 
        expect(page).to have_content('Please edit the location, description')
        expect(page).to have_button('Update Complaint')
        within 'form' do 
          expect(page).to have_field('complaint_address', with: 'Near the Post Office')
          expect(page).to have_field('complaint_description', with: 'There is a very big pothole near the post office off the main road.')
          fill_in 'complaint_address', with: 'By the Library'
          fill_in 'complaint_description', with: 'There is a lot of roadside litter all around the library and street nearby'
          click_on 'Update Complaint'
        end 
        expect(page).to have_content('Complaint could not be updated')
    end 
  end 
  
end