require 'test_helper'

class UserGroupTest < ActiveSupport::TestCase
	def test_fields
    	url_type = url_types(:pattern)
    	assert_not_nil url_type.name    		
    end

    def test_save
    	url_type= UrlType.new(
    		name: "pattern") 
    	url_type.save
    end
end

