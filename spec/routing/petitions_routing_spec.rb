require "rails_helper"

RSpec.describe PetitionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/petitions").to route_to("petitions#index")
    end

    it "routes to #new" do
      expect(:get => "/petitions/new").to route_to("petitions#new")
    end

    it "routes to #show" do
      expect(:get => "/petitions/1").to route_to("petitions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/petitions/1/edit").to route_to("petitions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/petitions").to route_to("petitions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/petitions/1").to route_to("petitions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/petitions/1").to route_to("petitions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/petitions/1").to route_to("petitions#destroy", :id => "1")
    end

  end
end
