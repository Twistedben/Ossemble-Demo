require 'rails_helper'

RSpec.describe "topics/new", type: :view do
  before(:each) do
    assign(:topic, Topic.new(
      :name => "MyString",
      :description => "MyText",
      :slug => "MyString",
      :city_id => 1
    ))
  end

  it "renders new topic form" do
    render

    assert_select "form[action=?][method=?]", topics_path, "post" do

      assert_select "input[name=?]", "topic[name]"

      assert_select "textarea[name=?]", "topic[description]"

      assert_select "input[name=?]", "topic[slug]"

      assert_select "input[name=?]", "topic[city_id]"
    end
  end
end
