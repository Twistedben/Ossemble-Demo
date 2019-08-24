require 'rails_helper'

RSpec.describe "topics/show", type: :view do
  before(:each) do
    @topic = assign(:topic, Topic.create!(
      :name => "Name",
      :description => "MyText",
      :slug => "Slug",
      :city_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(/2/)
  end
end
