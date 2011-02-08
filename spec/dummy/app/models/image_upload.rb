
#dummy class that can become phocodeable
class ImageUpload < ActiveRecord::Base
  acts_as_phocodable :thumbnails => [{:label=>"small",:width=>100,:height=>100 },
                                     {:label=>"medium",:width=>200,:height=>200 }]
end