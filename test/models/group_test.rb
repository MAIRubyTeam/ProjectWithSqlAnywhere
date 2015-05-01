require 'test_helper'

class UserGroupTest < ActiveSupport::TestCase
	def test_fields
    	group = groups(:user)
    	assert_not_nil group.name    		
    end

    def test_save
    	group = Group.new(
    		name: "user") 
    	group.save
    end
end
