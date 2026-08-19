require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
    let!(:older_expense) do
      Expense.create!(
        description: "Coffee",
        amount: 5.00,
        category: food_category,
        date: Date.today - 2.days,
        created_at: 1.day.ago
      )
    end
    let!(:first_today_expense) do
      Expense.create!(
        description: "Lunch",
        amount: 100.00,
        category: food_category,
        date: Date.today,
        created_at: 2.hours.ago
      )
    end
    let!(:second_today_expense) do
      Expense.create!(
        description: "Taxi",
        amount: 50.00,
        category: transport_category,
        date: Date.today,
        created_at: 1.hour.ago
      )
    end

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end

    it "returns expenses in descending order by date and created_at tie-breaker" do
      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).to eq([second_today_expense.id, first_today_expense.id, older_expense.id])
    end

    it "filters expenses by month and year based on expense date" do
      today = Date.today
      get "/api/expenses", params: { year: today.year, month: today.month }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).to include(second_today_expense.id, first_today_expense.id, older_expense.id)
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq("150.5")
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
