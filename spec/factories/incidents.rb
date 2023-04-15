FactoryBot.define do
  factory :incident do
    title { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    severity { "sev#{rand(0..2)}" }
    status { 'open' }
    creator { Faker::Name.name }
    slack_channel_id { "C#{Faker::Number.number(digits: 8)}" }
  end
end
