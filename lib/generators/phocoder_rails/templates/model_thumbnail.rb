class <%= name.classify %>Thumbnail < ActiveRecord::Base

  acts_as_phocodable :parent_class => "<%= name.classify %>" 

end