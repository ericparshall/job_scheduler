class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :user_type
  belongs_to :manager, class_name: "User"
  has_many :subordinates, class_name: "User", foreign_key: "manager_id"
  has_many :schedules, dependent: :delete_all
  has_many :users_skills
  has_many :skills, through: :users_skills, class_name: "Skill"
  has_many :jobs, inverse_of: :internal_point_of_contact
  
  validates :user_type, :full_name, :manager_id, presence: true
  
  before_validation do
    if self.user_type_id.nil?
      self.user_type_id = UserType.where(admin: false, manager: false).first.id
    end
  end
end
