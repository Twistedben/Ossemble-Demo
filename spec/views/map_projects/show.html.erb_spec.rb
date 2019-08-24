require 'rails_helper'

RSpec.describe "map_projects/show", type: :view do
  before(:each) do
    @map_project = assign(:map_project, MapProject.create!(
      :title => "Title",
      :status => "Status",
      :description => "MyText",
      :address => "Address",
      :slug => "Slug",
      :tags => "Tags",
      :admin_id => 2,
      :workplace_id => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(/Tags/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
