require 'rails_helper'

RSpec.describe "Petitions", type: :request do
  describe "GET /petitions" do
    it "works! (now write some real specs)" do
      get petitions_path
      expect(response).to have_http_status(200)
    end
  end
end
