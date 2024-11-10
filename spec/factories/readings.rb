FactoryBot.define do
  factory :reading do
    association :gauge

    after(:build) do |reading|
      reading.date ||= Faker::Date.between(
        from: reading.gauge.start_date,
        to: reading.gauge.end_date
      )
    end

    value { rand(1.0..100.0).round(2).to_s }
    approved { false }
  end
end
