require 'rails_helper'

RSpec.describe "petitions/edit", type: :view do
  before(:each) do
    @petition = assign(:petition, Petition.create!(
      :title => "MyString",
      :goal => "MyString",
      :description => "MyText",
      :city_id => 1,
      :user_id => 1,
      :completed => false,
      :filed => false,
      :replied => false,
      :planned => false,
      :slug => "MyString"
    ))
  end

  it "renders the edit petition form" do
    render

    assert_select "form[action=?][method=?]", petition_path(@petition), "post" do

      assert_select "input[name=?]", "petition[title]"

      assert_select "input[name=?]", "petition[goal]"

      assert_select "textarea[name=?]", "petition[description]"

      assert_select "input[name=?]", "petition[city_id]"

      assert_select "input[name=?]", "petition[user_id]"

      assert_select "input[name=?]", "petition[completed]"

      assert_select "input[name=?]", "petition[filed]"

      assert_select "input[name=?]", "petition[replied]"

      assert_select "input[name=?]", "petition[planned]"

      assert_select "input[name=?]", "petition[slug]"
    end
  end
end
