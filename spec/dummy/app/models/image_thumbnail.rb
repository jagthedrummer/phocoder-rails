class ImageThumbnail < ActiveRecord::Base

  acts_as_phocodable :parent_class => "Image" 

end