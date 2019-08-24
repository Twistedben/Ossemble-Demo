require 'rails_helper'

RSpec.describe "institutes/new", type: :view do
  before(:each) do
    assign(:institute, Institute.new(
      :name => "MyString",
      :type => "",
      :email => "MyString",
      :slug => "MyString"
    ))
  end

  it "renders new institute form" do
    render

    assert_select "form[action=?][method=?]", institutes_path, "post" do

      assert_select "input[name=?]", "institute[name]"

      assert_select "input[name=?]", "institute[type]"

      assert_select "input[name=?]", "institute[email]"

      assert_select "input[name=?]", "institute[slug]"
    end
  end
end
