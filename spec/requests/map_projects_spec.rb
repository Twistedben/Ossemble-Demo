require 'rails_helper'

RSpec.describe "MapProjects", type: :request do
  describe "GET /map_projects" do
    it "works! (now write some real specs)" do
      get map_projects_path
      expect(response).to have_http_status(200)
    end
  end
end
