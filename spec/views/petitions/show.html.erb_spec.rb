require 'rails_helper'

RSpec.describe "petitions/show", type: :view do
  before(:each) do
    @petition = assign(:petition, Petition.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Goal/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Slug/)
  end
end
