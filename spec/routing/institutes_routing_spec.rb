require "rails_helper"

RSpec.describe InstitutesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/institutes").to route_to("institutes#index")
    end

    it "routes to #new" do
      expect(:get => "/institutes/new").to route_to("institutes#new")
    end

    it "routes to #show" do
      expect(:get => "/institutes/1").to route_to("institutes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/institutes/1/edit").to route_to("institutes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/institutes").to route_to("institutes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/institutes/1").to route_to("institutes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/institutes/1").to route_to("institutes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/institutes/1").to route_to("institutes#destroy", :id => "1")
    end

  end
end
