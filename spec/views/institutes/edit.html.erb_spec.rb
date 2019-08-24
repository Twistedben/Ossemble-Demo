require 'rails_helper'

RSpec.describe "institutes/edit", type: :view do
  before(:each) do
    @institute = assign(:institute, Institute.create!(
      :name => "MyString",
      :type => "",
      :email => "MyString",
      :slug => "MyString"
    ))
  end

  it "renders the edit institute form" do
    render

    assert_select "form[action=?][method=?]", institute_path(@institute), "post" do

      assert_select "input[name=?]", "institute[name]"

      assert_select "input[name=?]", "institute[type]"

      assert_select "input[name=?]", "institute[email]"

      assert_select "input[name=?]", "institute[slug]"
    end
  end
end
