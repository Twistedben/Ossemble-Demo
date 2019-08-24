require 'rails_helper'

RSpec.describe "institutes/index", type: :view do
  before(:each) do
    assign(:institutes, [
      Institute.create!(
        :name => "Name",
        :type => "Type",
        :email => "Email",
        :slug => "Slug"
      ),
      Institute.create!(
        :name => "Name",
        :type => "Type",
        :email => "Email",
        :slug => "Slug"
      )
    ])
  end

  it "renders a list of institutes" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
  end
end
