FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.department }
    code { Faker::Alphanumeric.alphanumeric(number: 8).upcase } 
    value { Faker::Commerce.price(range: 5..100) }
    active { Faker::Boolean.boolean }
    merchant 
  end
end