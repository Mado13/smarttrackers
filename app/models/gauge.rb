class Gauge < ApplicationRecord
  has_many :readings, dependent: :destroy
  
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :unit, presence: true
  validates :time_unit, presence: true
  
  validates_inclusion_of :time_unit, in: %w[day week month year]
  validates_inclusion_of :unit, in: %w[kWh] 
  validate :end_date_after_start_date

  enum unit: {
    kWh: 0
  }
  enum time_unit: {
    day: 0,
    week: 1,
    month: 2,
    year: 3
  }
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date <= start_date # Change < to <= to catch equal dates
      errors.add(:end_date, "must be after start date")
    end
  end
end
