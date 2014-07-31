FactoryGirl.define do

  factory :person do
    sequence(:first_name) { |n| "John_#{n}" }
    sequence(:last_name) { |n| "Doe_#{n}" }
    sequence(:email) { |n| "johndoe_#{n}@domain.com"}
    title "Sales Rep"
    dob (Time.now - 30.years)
    is_manager false
  end

  factory :credit_card_info do
  	sequence(:cardholder) { |n| "John Adams #{n}" }
  	exp_date Time.now + 2.years
  	secret_code SecureRandom.hex(8)
  end

end
