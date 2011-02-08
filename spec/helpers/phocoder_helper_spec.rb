require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderHelper do
    
  it "should return a preview_reload_timeout" do
    preview_reload_timeout.should == 1000
  end
  
  describe "phcoder_thumbnail for offline_mode" do
    
    before(:each) do
      ActsAsPhocodable.storeage_mode = "offline"
      @attr = {
        :file => ActionDispatch::Http::UploadedFile.new(
          :tempfile=> Rack::Test::UploadedFile.new(fixture_path + '/big_eye_tiny.jpg', 'image/jpeg'),
          :filename=>"big_eye_tiny.jpg"
        ) 
        }
      @image = ImageUpload.create(@attr)
    end
    
    after(:each) do
      #set it back to the default
      ActsAsPhocodable.storeage_mode = "local"
      @image.destroy
    end
    
    it "should return a local url with no size for a nil thumbnail" do
      phocoder_thumbnail(@image,nil).should match(@image.local_url)
      phocoder_thumbnail(@image,nil).should_not match("width")
    end
    
    it "should return a local url with a width for a known thumbnail" do
      phocoder_thumbnail(@image,"small").should match(@image.local_url)
      phocoder_thumbnail(@image,"small").should match("width")
    end
    
  end
  
  
  
end
