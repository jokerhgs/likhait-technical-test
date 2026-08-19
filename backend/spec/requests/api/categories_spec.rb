require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  describe "GET /api/categories" do
    let!(:food) { Category.create!(name: "Food") }
    let!(:transport) { Category.create!(name: "Transport") }
    let!(:supplies) { Category.create!(name: "Supplies") }

    it "returns all categories" do
      get "/api/categories"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to eq([ "Food", "Supplies", "Transport" ])
    end
  end

  describe "POST /api/categories" do
    context "with valid parameters" do
      let(:valid_params) { { category: { name: "Subscriptions" } } }

      it "creates a new category" do
        expect {
          post "/api/categories", params: valid_params, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Subscriptions")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity when name is blank" do
        invalid_params = { category: { name: "" } }

        expect {
          post "/api/categories", params: invalid_params, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name can't be blank")
      end

      it "returns unprocessable entity when name is duplicate" do
        Category.create!(name: "Subscriptions")
        duplicate_params = { category: { name: "subscriptions" } }

        expect {
          post "/api/categories", params: duplicate_params, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name has already been taken")
      end

      it "returns unprocessable entity when name is too short" do
        short_params = { category: { name: "A" } }

        expect {
          post "/api/categories", params: short_params, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name is too short (minimum is 2 characters)")
      end

      it "strips leading and trailing whitespace before saving" do
        padded_params = { category: { name: "  Entertainment  " } }

        post "/api/categories", params: padded_params, as: :json
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Entertainment")
      end
    end
  end
end
