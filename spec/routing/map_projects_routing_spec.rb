require "rails_helper"

RSpec.describe MapProjectsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/map_projects").to route_to("map_projects#index")
    end

    it "routes to #new" do
      expect(:get => "/map_projects/new").to route_to("map_projects#new")
    end

    it "routes to #show" do
      expect(:get => "/map_projects/1").to route_to("map_projects#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/map_projects/1/edit").to route_to("map_projects#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/map_projects").to route_to("map_projects#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/map_projects/1").to route_to("map_projects#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/map_projects/1").to route_to("map_projects#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/map_projects/1").to route_to("map_projects#destroy", :id => "1")
    end

  end
end
