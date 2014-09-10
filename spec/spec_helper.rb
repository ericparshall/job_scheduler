ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment",__FILE__)
require 'rspec/rails'

module ValidUserHelper
  def signed_in_as_a_valid_user
    user_type = UserType.where(admin: true, manager: true).first
    @signed_in_user ||= Fabricate :user, user_type_id: user_type.id
    sign_in @signed_in_user # method from devise:TestHelpers
  end
end

# module for helping request specs
module ValidUserRequestHelper

  # for use in request specs
  def sign_in_as_a_valid_user
    @signed_in_user ||= Fabricate :user
    post_via_redirect user_session_path, 'user[email]' => @signed_in_user.email, 'user[password]' => @signed_in_user.password
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include ValidUserHelper, :type => :controller
  config.include ValidUserRequestHelper, :type => :request
end