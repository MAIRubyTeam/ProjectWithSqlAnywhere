class Url < ActiveRecord::Base
	has_and_belongs_to_many :groups
	belongs_to :url_type
end
