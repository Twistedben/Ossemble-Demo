require 'rails_helper'

RSpec.describe "map_projects/edit", type: :view do
  before(:each) do
    @map_project = assign(:map_project, MapProject.create!(
      :title => "MyString",
      :status => "MyString",
      :description => "MyText",
      :address => "MyString",
      :slug => "MyString",
      :tags => "MyString",
      :admin_id => 1,
      :workplace_id => 1
    ))
  end

  it "renders the edit map_project form" do
    render

    assert_select "form[action=?][method=?]", map_project_path(@map_project), "post" do

      assert_select "input[name=?]", "map_project[title]"

      assert_select "input[name=?]", "map_project[status]"

      assert_select "textarea[name=?]", "map_project[description]"

      assert_select "input[name=?]", "map_project[address]"

      assert_select "input[name=?]", "map_project[slug]"

      assert_select "input[name=?]", "map_project[tags]"

      assert_select "input[name=?]", "map_project[admin_id]"

      assert_select "input[name=?]", "map_project[workplace_id]"
    end
  end
end
