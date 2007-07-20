class User < ActiveRecord::Base
  belongs_to :created_by, :class_name => "User"
  belongs_to :modified_by, :class_name => "User"
  cattr_accessor :current_user
end
