class ClaTemplate < ActiveRecord::Base
  serialize :user_form
  serialize :owner_form
  
end
