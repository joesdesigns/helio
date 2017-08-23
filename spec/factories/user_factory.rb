# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:guid) { |n| "TESTGUID#{n}" }
    first_name "Joe"
    last_name "Jones"
    sequence(:email) { |n| "user_#{n}@test.com" }
  end
end
