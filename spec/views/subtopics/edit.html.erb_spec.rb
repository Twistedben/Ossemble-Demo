require 'rails_helper'

RSpec.describe "subtopics/edit", type: :view do
  before(:each) do
    @subtopic = assign(:subtopic, Subtopic.create!(
      :name => "MyString",
      :description => "MyText",
      :slug => "MyString",
      :topic_id => 1,
      :user_id => 1
    ))
  end

  it "renders the edit subtopic form" do
    render

    assert_select "form[action=?][method=?]", subtopic_path(@subtopic), "post" do

      assert_select "input[name=?]", "subtopic[name]"

      assert_select "textarea[name=?]", "subtopic[description]"

      assert_select "input[name=?]", "subtopic[slug]"

      assert_select "input[name=?]", "subtopic[topic_id]"

      assert_select "input[name=?]", "subtopic[user_id]"
    end
  end
end
