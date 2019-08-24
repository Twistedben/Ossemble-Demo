require 'rails_helper'

RSpec.describe "map_projects/index", type: :view do
  before(:each) do
    assign(:map_projects, [
      MapProject.create!(
        :title => "Title",
        :status => "Status",
        :description => "MyText",
        :address => "Address",
        :slug => "Slug",
        :tags => "Tags",
        :admin_id => 2,
        :workplace_id => 3
      ),
      MapProject.create!(
        :title => "Title",
        :status => "Status",
        :description => "MyText",
        :address => "Address",
        :slug => "Slug",
        :tags => "Tags",
        :admin_id => 2,
        :workplace_id => 3
      )
    ])
  end

  it "renders a list of map_projects" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => "Tags".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
