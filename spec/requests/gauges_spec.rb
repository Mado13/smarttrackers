require 'rails_helper'

RSpec.describe "Gauges", type: :request do
  let(:user) { create(:user) }
  let(:gauge) { create(:gauge) }
  let(:other_user) { create(:user) }
  let(:other_gauge) { create(:gauge) }

  before { sign_in user }

  describe "GET /gauges" do
    it "returns a successful response and displays all gauges" do
      gauge
      other_gauge
      get gauges_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(gauge.name)
      expect(response.body).to include(other_gauge.name)
    end
  end

  describe "GET /gauges/new" do
    it "returns a successful Turbo Stream response with the new gauge form" do
      get new_gauge_path, xhr: true
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("form")
    end
  end

  describe "POST /gauges" do
    let(:valid_attributes) do
      {
        name: "Electricity Usage",
        start_date: Date.today,
        end_date: Date.today + 1.month,
        unit: "kWh",
        time_unit: :day
      }
    end

    let(:invalid_attributes) do
      { name: "", start_date: nil, end_date: nil, unit: "", time_unit: "" }
    end

    context "with valid attributes" do
      it "creates a new gauge and returns a Turbo Stream response" do
        expect {
          post gauges_path, params: { gauge: valid_attributes }, xhr: true
        }.to change(Gauge, :count).by(1)
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end
    end

    context "with invalid attributes" do
      it "does not create a new gauge and returns errors via Turbo Stream" do
        expect {
          post gauges_path, params: { gauge: invalid_attributes }, xhr: true
        }.not_to change(Gauge, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
        expect(response.body).to include("error")
      end
    end
  end

  describe "GET /gauges/:id" do
    it "returns a successful response and displays the gauge details" do
      get gauge_path(gauge)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(gauge.name)
    end
  end
end
