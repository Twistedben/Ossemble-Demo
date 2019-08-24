require 'rails_helper'

RSpec.describe "subtopics/show", type: :view do
  before(:each) do
    @subtopic = assign(:subtopic, Subtopic.create!(
      :name => "Name",
      :description => "MyText",
      :slug => "Slug",
      :topic_id => 2,
      :user_id => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
