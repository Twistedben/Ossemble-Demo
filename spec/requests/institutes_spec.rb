require 'rails_helper'

RSpec.describe "Institutes", type: :request do
  describe "GET /institutes" do
    it "works! (now write some real specs)" do
      get institutes_path
      expect(response).to have_http_status(200)
    end
  end
end
