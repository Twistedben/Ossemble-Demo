require "rails_helper"

RSpec.describe SubtopicsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/subtopics").to route_to("subtopics#index")
    end

    it "routes to #new" do
      expect(:get => "/subtopics/new").to route_to("subtopics#new")
    end

    it "routes to #show" do
      expect(:get => "/subtopics/1").to route_to("subtopics#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/subtopics/1/edit").to route_to("subtopics#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/subtopics").to route_to("subtopics#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/subtopics/1").to route_to("subtopics#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/subtopics/1").to route_to("subtopics#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/subtopics/1").to route_to("subtopics#destroy", :id => "1")
    end

  end
end
