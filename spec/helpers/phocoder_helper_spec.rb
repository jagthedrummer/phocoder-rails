require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderHelper do #, :debug=>true
  
  before(:each) do
    @fixture_path = ""
    @attr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg'),:width => 200,:height=>197 }
    @image = ImageUpload.new(@attr)
    ActsAsPhocodable.storeage_mode = "local"
    ActsAsPhocodable.processing_mode = "automatic"
  end
  
  describe "phocoder_includes" do
    it "should include a javascript tag" do
      helper.phocoder_includes.should match /phocodable.js/
    end
    it "should include a stylesheet tag" do
      helper.phocoder_includes.should match /phocodable.css/
    end
  end
  
  describe "phocoder_video_includes" do
    it "should include a javascript tag" do
      helper.phocoder_video_includes.should match /video.js/
    end
    it "should include a stylesheet tag" do
      helper.phocoder_video_includes.should match /video-js.css/
    end
  end
  
  describe "phocoder_link" do
    before(:each) do
      @attr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg') }
      @image = ImageUpload.new(@attr)
    end
    it "should return raw text if the file is not ready" do
      @image.encodable_status = "phocoding"
      helper.phocoder_link("my link",@image).should == "my link"
    end
    it "should return a link if the file is ready" do
      @image.encodable_status = "ready"
      link = helper.phocoder_link("my link",@image)
      puts "link = #{link}"
      link.should match /my link/
      link.should match /<a/
      link.should match /href/
    end 
  end
  
  
  describe "phocoder_thumbnail" do
    it "should delegate to phocoder_video_thumbnail for videos" do
      vid = ImageUpload.new(:content_type=>'video/quicktime',:zencoder_status=>'s3',:id=>1,:filename=>"test.mov")
      helper.should_receive(:phocoder_video_thumbnail).and_return(nil)
      helper.phocoder_thumbnail(vid)
    end
    it "should delegate to phocoder_image_thumbnail for images" do
      img = ImageUpload.new({ :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg') })
      helper.should_receive(:phocoder_image_thumbnail).and_return(nil)
      helper.phocoder_thumbnail(img)
    end
    it "should return an error div for elements that arent' video or image" do
      obj = ImageUpload.new(:content_type=>'text/plain')
      #puts "====================================================================================="
      #puts "encodable.video? = #{obj.video?}  -  encodable.image? = #{obj.image?}"
      #puts "helper.phocoder_thumbnail(obj) = #{helper.phocoder_thumbnail(obj)}"
      #helper.should_receive(:error_div)
      helper.phocoder_thumbnail(obj).should match /not an image or a video/
    end
  end
  
  describe "phocoder_image_thumbnail" do
    
    it "should call phocoder_image_offline if mode is offline" do
      ActsAsPhocodable.storeage_mode = "offline"
      helper.should_receive(:phocoder_image_offline).and_return(nil)
      helper.phocoder_image_thumbnail(@image,nil,{})
    end
    
    it "should call phocoder_image_online if mode is not offline" do
      ActsAsPhocodable.storeage_mode = "local"
      helper.should_receive(:phocoder_image_online).and_return(nil)
      helper.phocoder_image_thumbnail(@image,nil,{})
    end
    
    #it "should call display_image when the thumbnail is blank" do
    #  helper.should_receive(:display_image).and_return(nil)
    #  helper.phocoder_image_thumbnail(@image,nil,{})
    #end
    
    #it "should call find_or_create_thumbnail and then call display_thumbnail if a thumbnail is found" do
    #  helper.should_receive(:find_or_create_thumbnail).and_return(@image)
    #  helper.should_receive(:display_image_thumbnail).and_return(nil)
    #  helper.phocoder_image_thumbnail(@image,"test_thumb",{})
    #end
    
    #it "should call find_or_create_thumbnail and then call error_div if a thumbnail is not found" do
    #  helper.should_receive(:find_or_create_thumbnail).and_return(nil)
    #  helper.should_receive(:error_div).and_return(nil)
    #  helper.phocoder_image_thumbnail(@image,"test_thumb",{})
    #end
  end
  
  describe "phocoder_image_offline" do
    
    it "should return an error when !image.web_safe? and thumbnail.blank?" do
      @image.content_type = "image/x-nikon-nef"
      @image.web_safe?.should be_false
      output = helper.phocoder_image_offline(@image,nil,{})
      output.should match /phocoder_error/
      output.should match @image.content_type
    end
    
    it "should return an image tag when image.web_safe? and thumbnail.blank?" do
      output = phocoder_image_offline(@image,nil,{})
      output.should match /<img/
      output.should_not match /width/
      output.should match @image.filename # the path in the thumbnail
    end
        
    it "should return an img tag when the thumbnail can be resolved" do
      output = helper.phocoder_image_offline(@image,"small",{})
      output.should match /<img/
      output.should match /width=\"100\"/
    end
        
    it "should return an error if thumbnail attributes are not found" do
      output = helper.phocoder_image_offline(@image,"bad-thumb",{})
      output.should match /phocoder_error/
      output.should match /bad-thumb/
    end
    
    #it "should return an image for the thumbnail if it's found and ready?" do
    #  pending "do this look at moving the stuff below.  Refactor that shit!"
    #end
    
    #it "should return a pending image for the thumbnail if it's found and !ready?" do
    #  pending "do this"
    #end
    
  end
  
  describe "phocoder_image_online" do
    
    describe "when no thumbnail is passed" do
      it "should return an error div if !image.web_safe" do
        @image.content_type = "image/x-nikon-nef"
        @image.web_safe?.should be_false
        output = helper.phocoder_image_online(@image,nil,{})
        output.should match /phocoder_error/
        output.should match @image.content_type
      end
      it "should return an img tag with no width and height if !image.ready? and image.web_safe?" do
        @image.encodable_status = 'phocoding'
        output = phocoder_image_online(@image,nil,{})
        output.should match /<img/
        output.should_not match /width/
        output.should match @image.filename # the path in the original
      end
      it "should return an img tag with width and height if image.ready? and image.web_safe?" do
        @image.encodable_status = 'ready'
        output = phocoder_image_online(@image,nil,{})
        output.should match /<img/
        output.should match /width/
        output.should match @image.filename # the path in the original
      end
    end #describe "when no thumbnail is passed" do
    describe "when a thumbnail is passed" do
      it "should return an img tag for a thumbnail that can be resolved by label and is ready" do
        ActsAsPhocodable.storeage_mode = "local"
        @tattr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg'), :width => 100, :height => 100 }
        @thumb = ImageUpload.new(@tattr)
        @thumb.filename = "big_eye_tiny_small.jpg"
        @thumb.encodable_status = @image.encodable_status = "ready"
        helper.should_receive(:find_or_create_thumbnail).and_return(@thumb)
        output = helper.phocoder_image_online(@image,"small",{})
        output.should match /<img/
        output.should match /width="100"/
        output.should match @thumb.filename # the path in the thumbnail
      end
      
      it "should create a thumbnail and return an img tag for a new size string" do
        ActsAsPhocodable.storeage_mode = "local"
        output = helper.phocoder_image_online(@image,"100x100",{})
        output.should match /<img/
        output.should match /width="100"/
        output.should match /waiting\.gif/ # the path in the thumbnail
      end
      
      it "should call pending_phcoder_thumbnail if the thumb is not ready" do
        ActsAsPhocodable.storeage_mode = "local"
        @tattr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg'), :width => 100, :height => 100 }
        @thumb = ImageUpload.new(@tattr)
        @thumb.filename = "big_eye_tiny_small.jpg"
        @thumb.encodable_status = "phocoding"
        @image.encodable_status = "ready"
        helper.should_receive(:find_or_create_thumbnail).and_return(@thumb)
        #helper.should_receive(:pending_phocoder_thumbnail)
        output = helper.phocoder_image_online(@image,"small",{})
        output.should match /waiting\.gif/ # the path in the thumbnail
      end
      it "should call pending_phcoder_thumbnail if the image is not ready" do
        ActsAsPhocodable.storeage_mode = "local"
        @image.encodable_status = "phocoding"
        #helper.should_receive(:pending_phocoder_thumbnail)
        output = helper.phocoder_image_online(@image,"small",{})
        output.should match /waiting\.gif/ # the path in the thumbnail
      end
      it "should return an error div if the thumb can not be resolved" do
        output = helper.phocoder_image_online(@image,"bad-thumb",{})
        output.should match /phocoder_error/
        output.should match /bad-thumb/
      end
      it "should return an error div if the thumb can not be resolved when the image is ready" do
        @image.encodable_status = "ready"
        output = helper.phocoder_image_online(@image,"bad-thumb",{})
        output.should match /phocoder_error/
        output.should match /bad-thumb/
      end
    end
  end # describe "when a thumbnail is passed" do
  
  describe "find_thumbnail_attributes" do 
    it "should call @image.thumbnail_attributes_for if the thumbnail argument is a String" do
      atts = {:foo => "bar" }
      @image.should_receive(:thumbnail_attributes_for).and_return(atts)
      helper.find_thumbnail_attributes(@image,"small",{}).should == atts
    end
    it "should return the thumbnail argument if it is a Hash" do
      atts = {:foo => "bar" }
      helper.find_thumbnail_attributes(@image,atts,{}).should == atts
    end
    
  end
  
  describe "find_or_create_thumbnail" do
    it "should call @image.thumbnail_for if the thumbnail attribute is a String" do
      @image.should_receive(:thumbnail_for)
      helper.find_or_create_thumbnail(@image,"some_thumb")
    end
    # This is kind of an integration test.  maybe it should go somewhere else...
    it "should create a new thumbnail (by calling phocode) for a new size string" do
      #@image.should_receive(:phocode).and_return([{ :label => "100x100" }])
      
      Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
        "job"=>{
          "id"=>1,
          "inputs"=>["id"=>1],
          "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
        }
      }))
      @image.save
      Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
        "job"=>{
          "id"=>1,
          "inputs"=>["id"=>1],
          "thumbnails"=>[{"label"=>"100x100","filename"=>"100x100-test-file.jpg","id"=>1}]
        }
      }))
      thumb = helper.find_or_create_thumbnail(@image,"100x100")
      
      puts thumb.to_json
      thumb.encodable_status.should_not == "ready"
    end
  end
  
#  describe "display_image_thumbnail" do
#    it "in offline mode it should call offline_phocoder_image_thumbnail" do
#      ActsAsPhocodable.storeage_mode = "offline"
#      helper.should_receive(:offline_phocoder_image_thumbnail).and_return(nil)
#      helper.display_image_thumbnail(@image,@image,{})
#    end
#    
#    it "if the thumbnail is ready, should return an image tag with the path and dimensions of the thumbnail" do
#      
#    end
#    
#    it "if the thumbnail is not ready, should call pending_phocoder_thumbnail" do
#      ActsAsPhocodable.storeage_mode = "local"
#      @tattr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg'), :width => 100, :height => 100 }
#      @thumb = ImageUpload.new(@tattr)
#      @thumb.filename = "big_eye_tiny_thumbnail.jpg"
#      @thumb.encodable_status = "phocoding"
#      helper.should_receive(:pending_phocoder_thumbnail).and_return(nil)
#      helper.display_image_thumbnail(@image,@thumb,{})
#      #puts "-------- #{@thumb.public_url} ---- #{ActsAsPhocodable.storeage_mode}"
#      #output = helper.display_image_thumbnail(@image,@thumb,{})
#      #output.should match /<img/
#      #output.should match /width="100"/
#      #output.should match /big_eye_tiny_thumbnail.jpg/ # the path in the thumbnail
#    end
#  end

#  describe "offline_phocoder_image_thumbnail" do
#    it "should render a thumbnail with the path to the original but the dimensions of the thumbnail" do
#      @tattr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg'),:filename=>"big_eye_tiny_thumbnail.jpg", :width => 100, :height => 100 }
#      @thumb = ImageUpload.new(@tattr)
#      @thumb.filename = "big_eye_tiny_thumbnail.jpg"
#      output = helper.offline_phocoder_image_thumbnail(@image,@thumb,{})
#      output.should match /<img/
#      output.should match /width="100"/
#      output.should match /big_eye_tiny.jpg/ # the path in the @att at the top of the file
#    end  
#  end
  
  describe "pending_phocoder_thumbnail" do
    it "should return an image tag that points to a waiting image with the dimensions of the thumbnail" do
      @tattr = { :file => fixture_file_upload(@fixture_path + '/big_eye_tiny.jpg','image/jpeg'), :width => 100, :height => 100 }
      @thumb = ImageUpload.new(@tattr)
      @thumb.filename = "big_eye_tiny_thumbnail.jpg"
      output = helper.pending_phocoder_thumbnail(@image,@thumb,{})
      output.should match /<img/
      output.should match /width="100"/
      output.should match /waiting\.gif/ # the path in the thumbnail
    end
  end
  
  ####################
  # These are more like integration tests, but whatever at least it's tested....
  ####################
  

  describe "phocoder_image_thumbnail" do 
  
    it "should return a preview_reload_timeout" do
      preview_reload_timeout.should == 10000
    end
    
    
    
  
    describe "phcoder_thumbnail for local mode after processing" do
      before(:each) do
        ActsAsPhocodable.storeage_mode = "local"
        
        @thumb = ImageUpload.new(@attr.merge :parent_id=>@image.id,:thumbnail=>"small")
        #@thumb.save 
        #set the main image to ready, but not the thumb
        @image.encodable_status = "ready"
        @image.stub!(:thumbnail_for).and_return(@thumb)
        #@image.save
      end
      
      after(:each) do
        #@thumb.destroy
      end
      
      
      it "should return a pending img for a known thumbnail that is not ready" do
        phocoder_image_thumbnail(@image,"small").should match(/data-phocoder-waiting="true"/)
      end
      
      it "should return a local url for a known thumbnail" do
        #act like we've already been updated from phocoder
        @thumb.encodable_status = "ready"
        #@thumb.save
        puts "@image.encodable_status = #{@image.encodable_status}"
        puts "@thumb.encodable_status = #{@thumb.encodable_status}"
        
        phocoder_image_thumbnail(@image,"small").should match(@thumb.public_url)
      end
      
    end

  end # describe "image operations" do 
  
  
  describe "phocoder_video_thumbnail" do
  end
  
  
  
  describe "video preview functions" do 
#    before(:each) do
#      @vid_attr = {
#        :file => fixture_file_upload(@fixture_path + '/video-test.mov', 'video/quicktime')
#      }
#      Zencoder::Job.stub!(:create).and_return(mock(Zencoder::Response,:body=>{
#        "id"=>1,
#        "inputs"=>["id"=>1],
#        "outputs"=>[{"label"=>"small","url"=>"http://someurl/","filename"=>"small-test-file.mp4","id"=>1}]
#    }))
#    end
#    
#    after(:each) do
#      
#    end
  
    it "should render a pending img for a vid that is not ready" do
      vid = ImageUpload.new(:content_type=>'video/quicktime',:zencoder_status=>'s3',:id=>1,:filename=>"test.mov")
      phocoder_video_thumbnail(vid,"small",true).should match(/data-phocoder-waiting="true"/)
    end
    
    it "should render an image for a video that is ready but live_video = false" do
      vid = ImageUpload.new(:content_type=>'video/quicktime',:zencoder_status=>'ready',:id=>1,:filename=>"test.mov",:encodable_status=>"ready")
      vid.stub!(:thumbnail_for).and_return(vid)
      vid.video?.should be_true
      phocoder_video_thumbnail(vid,"small",false).should match("video_poster")
    end
   
    

    it "should render a video js embed for a video that is ready" do
      vid = ImageUpload.new(:content_type=>'video/quicktime',:zencoder_status=>'ready',:id=>1,:filename=>"test.mov",:encodable_status=>"ready")
      vid.stub!(:thumbnail_for).and_return(vid)
      vid.video?.should be_true
      phocoder_video_thumbnail(vid,"small",true).should match("video-js")
    end
  
  end # describe "video preview functions" do 

  # describe "offline_phocoder_video_embed" do
  #   it "should render a video tag" do
  #     vid = ImageUpload.new(:content_type=>'video/quicktime',:zencoder_status=>'ready',:id=>1,:filename=>"test.mov",:encodable_status=>"ready")
  #     vid.stub!(:thumbnail_for).and_return(vid)
  #     vid.video?.should be_true
  #     offline_phocoder_video_embed(vid,"small",{}).should match("video-js")
  #   end
  #   
  # end
  
end
