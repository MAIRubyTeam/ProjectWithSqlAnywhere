# encoding: utf-8

class ActiveRecord::Base
  class_attribute :owner
  
  self.owner = "dbo"
  
  def to_dummy_hash(options={})
    ActiveSupport::JSON.decode(self.to_json(options))
  end
  
  def self.next_id
    self.uncached do
      self.connection.select_value("select dbo.idgenerator('#{self.table_name}', '#{self.primary_key}', '#{self.owner}')")
    end
  end
end