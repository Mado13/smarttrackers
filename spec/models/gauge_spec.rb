require 'rails_helper'

RSpec.describe Gauge, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:readings).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:gauge) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:time_unit) }
    
    it { is_expected.to define_enum_for(:time_unit).with_values(day: 0, week: 1, month: 2, year: 3) }
    it { is_expected.to define_enum_for(:unit).with_values(kWh: 0) } 
  end

  describe 'custom validations' do
    describe '#end_date_after_start_date' do
      let(:user) { create(:user) }
      
      context 'when end_date is before start_date' do
        subject(:gauge) do
          build(:gauge,
            start_date: Date.today,
            end_date: Date.today - 1.day
          )
        end

        it 'is invalid' do
          expect(gauge).not_to be_valid
          expect(gauge.errors[:end_date]).to include('must be after start date')
        end
      end

      context 'when end_date is after start_date' do
        subject(:gauge) do
          build(:gauge,
            start_date: Date.today,
            end_date: Date.today + 1.day
          )
        end

        it 'is valid' do
          expect(gauge).to be_valid
        end
      end

      context 'when end_date equals start_date' do
        subject(:gauge) do
          build(:gauge,
            start_date: Date.today,
            end_date: Date.today
          )
        end

        it 'is invalid' do
          expect(gauge).not_to be_valid
          expect(gauge.errors[:end_date]).to include('must be after start date')
        end
      end

      context 'when dates are blank' do
        subject(:gauge) do
          build(:gauge,
            start_date: nil,
            end_date: nil
          )
        end

        it 'skips end_date validation' do
          gauge.valid?
          expect(gauge.errors[:end_date]).not_to include('must be after start date')
        end
      end
    end
  end
end
