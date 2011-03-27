class <%= name.classify %> < ActiveRecord::Base

  acts_as_phocodable :thumbnail_class => "<%= name.classify %>Thumbnail", 
    :thumbnails => [
      {:label=>"small",:width=>100,:height=>100 },
      {:label=>"medium",:width=>400,:height=>400, 
        :frame=>{ :width=>20, :bottom=>50, :color=>'003' }, 
        :annotations=>[
                        {:text=>"Annotation Testing",:pointsize=>30,:fill_color=>'fff',:gravity=>"South",:y=>10},
                        {:text=>"Howdy!",:pointsize=>10,:fill_color=>'ccc',:gravity=>"North",:y=>5}
                      ] 
      }
    ],
    
    :videos => [ {:label => 'mp4',:video_codec=>"h264" }, #, :thumbnails=>{ :number=>1, :start_at_first_frame=>1 } 
                 {:label => 'webm', :video_codec=>"vp8" },
                 {:label => 'ogv', :video_codec=>"theora" }
    ]

end