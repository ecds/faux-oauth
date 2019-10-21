require "rails_helper"

RSpec.describe TokensController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(get: "/auth/some_provider/callback").to route_to("tokens#create", provider: 'some_provider')
    end

    it "routes to #verify" do
      expect(post: "/tokens").to route_to("tokens#verify")
    end
  end
end
