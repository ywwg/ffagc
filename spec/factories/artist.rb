FactoryGirl.define do
  factory :artist do
    name { Faker::Name.name }
    email
    password { Faker::Internet.password }
    contact_name { Faker::Name.name }
    contact_phone { Faker::PhoneNumber.phone_number }
    contact_street { Faker::Address.street_address }
    contact_city { Faker::Address.city }
    contact_state { Faker::Address.state }
    contact_country { 'United States' }
    contact_zipcode { Faker::Address.zip_code }
  end
end
