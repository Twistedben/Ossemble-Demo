require 'rails_helper'

RSpec.describe "institutes/show", type: :view do
  before(:each) do
    @institute = assign(:institute, Institute.create!(
      :name => "Name",
      :type => "Type",
      :email => "Email",
      :slug => "Slug"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Slug/)
  end
end
