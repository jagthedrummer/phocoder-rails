module Phocodable
  def is_phocodable
    #has_many :reviews, :as=>:reviewable, :dependent=>:destroy
    include InstanceMethods
    attr_reader :saved_file
  end
  
  module InstanceMethods
  
    def phocodable?
      true
    end
    
    def file=(new_file)
      Rails.logger.debug "we got a new file of class = #{new_file.class}"
      self.filename = new_file.original_filename
      self.content_type = new_file.content_type
      @saved_file = new_file
    end
    
  end#module InstanceMethods
  
end
ActiveRecord::Base.extend Phocodable