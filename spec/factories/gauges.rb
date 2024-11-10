FactoryBot.define do
  factory :gauge do
    name { Faker::Measurement.metric_weight }
    start_date { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    end_date { start_date + rand(1..6).months }
    unit { :kWh }
    time_unit { [:day, :week, :month, :year].sample }
  end
end
