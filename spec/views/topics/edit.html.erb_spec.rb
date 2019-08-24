require 'rails_helper'

RSpec.describe "topics/edit", type: :view do
  before(:each) do
    @topic = assign(:topic, Topic.create!(
      :name => "MyString",
      :description => "MyText",
      :slug => "MyString",
      :city_id => 1
    ))
  end

  it "renders the edit topic form" do
    render

    assert_select "form[action=?][method=?]", topic_path(@topic), "post" do

      assert_select "input[name=?]", "topic[name]"

      assert_select "textarea[name=?]", "topic[description]"

      assert_select "input[name=?]", "topic[slug]"

      assert_select "input[name=?]", "topic[city_id]"
    end
  end
end
