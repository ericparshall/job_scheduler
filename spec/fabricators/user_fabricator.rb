require 'faker'

Fabricator(:user) do
  full_name "Some User"
  user_type_id 1
  manager_id 1
  email { Faker::Internet.email }
  password { Faker::Lorem.characters(15) }
end