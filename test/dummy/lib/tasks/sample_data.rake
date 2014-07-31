namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_people
  end
end    

def make_people
  75.times do |n|
    last_name = Faker::Name.last_name
    first_name = Faker::Name.first_name
    email = Faker::Internet.email
    title = "Sales Rep" #Faker::Name.title
    dob = Time.now - Random.rand(3_000..15_000).days
    is_manager = false
    Person.create!(last_name: last_name, first_name: first_name, is_manager: is_manager, dob: dob, title: title, email: email)
  end
end