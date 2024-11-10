# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reading, type: :model do
  describe 'associations' do
    it { should belong_to(:gauge) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:gauge) }
  end

  describe '#approve' do
    let(:reading) { create(:reading, approved: false) }

    it 'approves the reading' do
      expect { reading.approve }.to change { reading.approved }.from(false).to(true)
    end
  end

  describe '#date_within_gauge_range' do
    let(:gauge) { create(:gauge, start_date: 1.month.ago, end_date: 1.month.from_now) }

    context 'when date is within gauge range' do
      let(:reading) { build(:reading, gauge: gauge, date: Time.current) }

      it 'is valid' do
        expect(reading).to be_valid
      end
    end

    context 'when date is before gauge start date' do
      let(:reading) { build(:reading, gauge: gauge, date: 2.months.ago) }

      it 'is invalid' do
        expect(reading).not_to be_valid
        expect(reading.errors[:date]).to include("must be within gauge's date range")
      end
    end

    context 'when date is after gauge end date' do
      let(:reading) { build(:reading, gauge: gauge, date: 2.months.from_now) }

      it 'is invalid' do
        expect(reading).not_to be_valid
        expect(reading.errors[:date]).to include("must be within gauge's date range")
      end
    end

    context 'when date is blank' do
      let(:reading) { build(:reading, gauge: gauge, date: nil) }

      it 'skips date range validation' do
        reading.valid?
        expect(reading.errors[:date]).not_to include("must be within gauge's date range")
      end
    end

    context 'when gauge is nil' do
      let(:reading) { build(:reading, gauge: nil, date: Time.current) }

      it 'skips date range validation' do
        reading.valid?
        expect(reading.errors[:date]).not_to include("must be within gauge's date range")
      end
    end
  end
end
