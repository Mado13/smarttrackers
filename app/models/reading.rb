class Reading < ApplicationRecord
  belongs_to :gauge
  
  validates :value, presence: true, numericality: true
  validates :date, presence: true
  validates :gauge, presence: true
  
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  scope :ordered, -> { order(date: :desc) }
  
  validate :date_within_gauge_range

  def approve
    update(approved: true)
  end
  
  private
  
  def date_within_gauge_range
    return if date.blank? || gauge.nil?
    
    unless date.between?(gauge.start_date, gauge.end_date)
      errors.add(:date, "must be within gauge's date range")
    end
  end
end
