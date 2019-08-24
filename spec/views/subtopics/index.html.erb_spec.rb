require 'rails_helper'

RSpec.describe "subtopics/index", type: :view do
  before(:each) do
    assign(:subtopics, [
      Subtopic.create!(
        :name => "Name",
        :description => "MyText",
        :slug => "Slug",
        :topic_id => 2,
        :user_id => 3
      ),
      Subtopic.create!(
        :name => "Name",
        :description => "MyText",
        :slug => "Slug",
        :topic_id => 2,
        :user_id => 3
      )
    ])
  end

  it "renders a list of subtopics" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
