class Skill < ActiveRecord::Base
  has_many :users, through: :users_skills
end
