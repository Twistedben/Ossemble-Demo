require 'rails_helper'

RSpec.describe "petitions/index", type: :view do
  before(:each) do
    assign(:petitions, [
      Petition.create!(
        :title => "Title",
        :goal => "Goal",
        :description => "MyText",
        :city_id => 2,
        :user_id => 3,
        :completed => false,
        :filed => false,
        :replied => false,
        :planned => false,
        :slug => "Slug"
      ),
      Petition.create!(
        :title => "Title",
        :goal => "Goal",
        :description => "MyText",
        :city_id => 2,
        :user_id => 3,
        :completed => false,
        :filed => false,
        :replied => false,
        :planned => false,
        :slug => "Slug"
      )
    ])
  end

  it "renders a list of petitions" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Goal".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
  end
end
