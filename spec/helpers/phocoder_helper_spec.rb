require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderHelper do
  
  before(:each) do
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[]
      }
      }))
    @attr = {
      :file => ActionDispatch::Http::UploadedFile.new(
                                                      :tempfile=> Rack::Test::UploadedFile.new(fixture_path + '/big_eye_tiny.jpg', 'image/jpeg'),
      :filename=>"big_eye_tiny.jpg"
      ) 
    }
    @image = ImageUpload.create(@attr)
  end
  
  after(:each) do
    @image.destroy
  end
  
  
  it "should return a preview_reload_timeout" do
    preview_reload_timeout.should == 10000
  end
  
  describe "phcoder_thumbnail for offline mode" do
  
    before(:each) do
      ActsAsPhocodable.storeage_mode = "offline"
    end
    
    after(:each) do
      #set it back to the default
      ActsAsPhocodable.storeage_mode = "local"
    end
    
    it "should return an img with a local url with no size for a nil thumbnail" do
      phocoder_thumbnail(@image,nil).should match(@image.local_url)
      phocoder_thumbnail(@image,nil).should_not match("width")
    end
  
    it "should return an img with a local url and a width for a known thumbnail" do
      phocoder_thumbnail(@image,"small").should match(@image.local_url)
      phocoder_thumbnail(@image,"small").should match("width")
    end
    
    it "should return an error for an unknown thumbnail name" do
      phocoder_thumbnail(@image,"smallish-thing").should match("red")
    end

  end


  describe "phcoder_thumbnail for local mode before processing" do

    it "should return a self updading 'pending' img" do
      phocoder_thumbnail(@image,"small").should match("text/javascript")
    end

    it "should return an error for an unknown thumbnail name" do
      phocoder_thumbnail(@image,"smallish-thing").should match("red")
    end

  end

  describe "phcoder_thumbnail for local mode after processing" do
    before(:each) do
      ActsAsPhocodable.storeage_mode = "local"
      
      @thumb = ImageUpload.create(@attr.merge :parent_id=>@image.id,:thumbnail=>"small")
      @thumb.save 
      #set the main image to ready, but not the thumb
      @image.phocoder_status = "ready"
      @image.save
    end
    after(:each) do
      @thumb.destroy
    end
    
    it "should return a local url for a nil thumbnail" do
      phocoder_thumbnail(@image,nil).should match(@image.public_url)
    end
    
    it "should return a pending img for a known thumbnail that is not ready" do
      phocoder_thumbnail(@image,"small").should match("text/javascript")
    end
    
    it "should return a local url for a known thumbnail" do
      #act like we've already been updated from phocoder
      @thumb.phocoder_status = "ready"
      @thumb.save
      puts "@image.phocoder_status = #{@image.phocoder_status}"
      puts "@thumb.phocoder_status = #{@thumb.phocoder_status}"
      
      phocoder_thumbnail(@image,"small").should match(@thumb.public_url)
    end
    
  end

end
