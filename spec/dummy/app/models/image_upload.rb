
#dummy class that can become phocodeable
class ImageUpload < ActiveRecord::Base
  
  acts_as_phocodable :thumbnails => [{:label=>"small",:width=>100,:height=>100 },
                                     {:label=>"medium",:width=>200,:height=>200 }],
                     :videos => [ {:label => 'mp4',:video_codec=>"h264" },
                                  {:label => 'webm', :video_codec=>"vp8"}
                                 ]
                                  
end