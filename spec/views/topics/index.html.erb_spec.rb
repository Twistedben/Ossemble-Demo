require 'rails_helper'

RSpec.describe "topics/index", type: :view do
  before(:each) do
    assign(:topics, [
      Topic.create!(
        :name => "Name",
        :description => "MyText",
        :slug => "Slug",
        :city_id => 2
      ),
      Topic.create!(
        :name => "Name",
        :description => "MyText",
        :slug => "Slug",
        :city_id => 2
      )
    ])
  end

  it "renders a list of topics" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
