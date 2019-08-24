require 'rails_helper'

RSpec.describe "posts/new", type: :view do
  before(:each) do
    assign(:post, Post.new(
      :title => "MyString",
      :description => "MyText",
      :slug => "MyString",
      :subtopic_id => 1,
      :user_id => 1
    ))
  end

  it "renders new post form" do
    render

    assert_select "form[action=?][method=?]", posts_path, "post" do

      assert_select "input[name=?]", "post[title]"

      assert_select "textarea[name=?]", "post[description]"

      assert_select "input[name=?]", "post[slug]"

      assert_select "input[name=?]", "post[subtopic_id]"

      assert_select "input[name=?]", "post[user_id]"
    end
  end
end
