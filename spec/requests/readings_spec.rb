# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Readings', type: :request do
  let(:employee) { create(:user, role: :employee) }
  let(:manager) { create(:user, role: :manager) }
  let!(:gauge) { create(:gauge) }
  let!(:reading) { create(:reading, approved: false, gauge: gauge) }
  let!(:approved_reading) { create(:reading, approved: true, gauge: gauge) }

  describe 'GET /gauges/:gauge_id/readings/new' do
    context 'when employee is logged in' do
      before { sign_in employee }

      it 'returns successful response' do
        get new_gauge_reading_path(gauge, format: :html)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when manager tries to access' do
      before { sign_in manager }

      it 'returns forbidden status' do
        get new_gauge_reading_path(gauge)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /gauges/:gauge_id/readings/:id' do
    let(:valid_params) do
      { reading: {
        value: 200,
        date: Faker::Date.between(from: gauge.start_date, to: gauge.end_date)
      } }
    end

    let(:invalid_params) do
      { reading: { value: nil, date: nil } }
    end

    context 'when employee is logged in' do
      before { sign_in employee }

      it 'updates the reading with valid params' do
        patch gauge_reading_path(gauge, reading),
              params: valid_params,
              as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(reading.reload.value).to eq(200)
        expect(response.body).to include("reading_#{reading.id}")
      end

      it 'fails to update with invalid params' do
        patch gauge_reading_path(gauge, reading),
              params: invalid_params,
              as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns not found for non-existent reading' do
        patch gauge_reading_path(gauge, id: 'nonexistent'),
              params: valid_params,
              as: :turbo_stream

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /gauges/:gauge_id/readings' do
    let(:valid_params) do
      { reading: {
        value: 100,
        date: Faker::Date.between(from: gauge.start_date, to: gauge.end_date)
      } }
    end

    let(:invalid_params) do
      { reading: { value: nil, date: nil } }
    end

    context 'when employee is logged in' do
      before { sign_in employee }

      it 'creates a new reading with valid params' do
        expect do
          post gauge_readings_path(gauge),
               params: valid_params,
               headers: { 'Accept': 'text/vnd.turbo-stream.html' }
        end.to change(Reading, :count).by(1)
        expect(response).to have_http_status(:success)
      end

      it 'fails to create with invalid params' do
        post gauge_readings_path(gauge),
             params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when manager tries to create' do
      before { sign_in manager }

      it 'returns forbidden status' do
        post gauge_readings_path(gauge), params: valid_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /gauges/:gauge_id/readings/:id' do
    context 'when employee is logged in' do
      before { sign_in employee }

      it 'deletes the reading' do
        expect do
          delete gauge_reading_path(gauge, reading),
                 as: :turbo_stream
        end.to change(Reading, :count).by(-1)
        expect(response).to have_http_status(:success)
      end

      it 'returns not found for non-existent reading' do
        delete gauge_reading_path(gauge, id: 'nonexistent'),
               as: :turbo_stream
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /gauges/:gauge_id/readings/:id/approve' do
    context 'when manager is logged in' do
      before { sign_in manager }

      it 'approves the reading' do
        expect do
          patch approve_gauge_reading_path(gauge, reading),
                as: :turbo_stream
        end.to change { reading.reload.approved? }.from(false).to(true)
        expect(response).to have_http_status(:success)
      end

      it 'handles already approved readings' do
        patch approve_gauge_reading_path(gauge, approved_reading),
              as: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end

    context 'when employee tries to approve' do
      before { sign_in employee }

      it 'returns forbidden status' do
        patch approve_gauge_reading_path(gauge, reading),
              as: :turbo_stream
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'Error handling' do
    before { sign_in employee }

    it 'returns 404 when gauge not found' do
      get new_gauge_reading_path(gauge_id: 'nonexistent')
      expect(response).to have_http_status(:not_found)
    end
  end
end
