require 'test_helper'

class UserTest < ActiveSupport::TestCase
	def test_fields
    	user = users(:user_one)
    	assert_not_nil user.name    		
    end

    def test_save
    	#user = users(:user_four)
    	user = User.new(
    		name: "Petya!!!!",
    		groups: [groups(:admin)]) 
    	user.save

    	assert groups(:admin).users.include?(user)
    end

end
