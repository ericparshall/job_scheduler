class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :user_type
  belongs_to :manager, class_name: "User"
  has_many :subordinates, class_name: "User", foreign_key: "manager_id"
  has_many :schedules
  
  validates :user_type, :full_name, :manager_id, presence: true
  
  before_validation do
    if self.user_type_id.nil?
      self.user_type_id = UserType.where(admin: false, manager: false).first.id
    end
  end
end
