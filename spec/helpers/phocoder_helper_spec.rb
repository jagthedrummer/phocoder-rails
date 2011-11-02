require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderHelper do
  
  
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
      @attr = { :file => fixture_file_upload(fixture_path + '/big_eye_tiny.jpg','image/jpeg') }
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
      img = ImageUpload.new({ :file => fixture_file_upload(fixture_path + '/big_eye_tiny.jpg','image/jpeg') })
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
  
  
  describe "phocoder_video_thumbnail" do
  end
  
  
  
  describe "phocoder_image_thumbnail" do 
  
    before(:each) do
      #Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      #  "job"=>{ "id"=>1, "inputs"=>["id"=>1], "thumbnails"=>[] }
      #}))
      @attr = { :file => fixture_file_upload(fixture_path + '/big_eye_tiny.jpg','image/jpeg') }
      @image = ImageUpload.new(@attr)
    end
    
    #after(:each) do
    #  @image.destroy
    #end
    
    
    it "should return a preview_reload_timeout" do
      preview_reload_timeout.should == 10000
    end
    
    describe "phcoder_thumbnail for offline mode" do
    
      before(:each) do ActsAsPhocodable.storeage_mode = "offline" end
      #set it back to the default
      after(:each) do ActsAsPhocodable.storeage_mode = "local" end
      
     
      it "should return an img with a local url with no size for a nil thumbnail" do
        phocoder_image_thumbnail(@image,nil).should match(@image.local_url)
        phocoder_image_thumbnail(@image,nil).should_not match("width")
      end
    
      it "should return an img with a local url and a width for a known thumbnail" do
        phocoder_image_thumbnail(@image,"small").should match(@image.local_url)
        phocoder_image_thumbnail(@image,"small").should match("width")
      end
      
      it "should return an error for an unknown thumbnail name" do
        phocoder_image_thumbnail(@image,"smallish-thing").should match("red")
      end
  
    end
  
  
    describe "phcoder_thumbnail for local mode before processing" do
  
      it "should return a self updading 'pending' img" do
        phocoder_image_thumbnail(@image,"small").should match(/data-phocoder-waiting="true"/)
      end
  
      it "should return an error for an unknown thumbnail name" do
        phocoder_image_thumbnail(@image,"smallish-thing").should match("red")
      end
  
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
      
      # For now we need a thumbnail since it might be a NEF
      #it "should return a local url for a nil thumbnail" do
      #  phocoder_image_thumbnail(@image,nil).should match(@image.public_url)
      #end
      
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
  
  
  describe "video preview functions" do 
#    before(:each) do
#      @vid_attr = {
#        :file => fixture_file_upload(fixture_path + '/video-test.mov', 'video/quicktime')
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
  
end
