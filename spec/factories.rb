FactoryGirl.define do
  factory :action do
    operation "Move Message to"
    destination "temp"
  end

  factory :filter do
  end

  factory :locale do
    title "en"
  end

  factory :rule do
    section "To"
    part "is"
    substance "test@example.com"
  end

  factory :translation do
    association :locale
    key "welcome"
    value "Welcome!"
  end

  factory :user do
    sequence(:username){|n| "username#{n}"}
    password "abc123"
  end
end
