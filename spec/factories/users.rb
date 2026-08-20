FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Karl Marx" }
    password { "correct horse battery staple" }
    password_confirmation { "correct horse battery staple" }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
