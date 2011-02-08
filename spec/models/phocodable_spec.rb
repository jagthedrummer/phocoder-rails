require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionDispatch::TestProcess




#dummy migration for testing.
#class TestMigration < ActiveRecord::Migration
#  def self.up
#    create_table :images, :force => true do |t|
#      t.string   "filename"
#      t.datetime "created_at"
#      t.datetime "updated_at"
#      t.string   "content_type"
#      t.integer  "phocoder_job_id"
#      t.integer  "phocoder_input_id"
#      t.integer  "phocoder_output_id"
#      t.integer  "width"
#      t.integer  "height"
#      t.integer  "file_size"
#      t.string   "thumbnail"
#      t.integer  "parent_id"
#      t.string   "status"
#      t.string   "upload_host"
#    end
#  end
#  
#  def self.down
#    drop_table :images
#  end
#end
#
##dummy class that can become phocodeable
#class Image < ActiveRecord::Base
#  acts_as_phocodable
#end


describe ActsAsPhocodable do
  
  # the ImageUpload class in the dummy app
  # is wired up with acts_as_phocodable
  
  #before(:all){ TestMigration.up }
  #after(:all){ TestMigration.up }
  before(:each) do
        @attr = {
        :file => ActionDispatch::Http::UploadedFile.new(
          :tempfile=> Rack::Test::UploadedFile.new(fixture_path + '/big_eye_tiny.jpg', 'image/jpeg'),
          :filename=>"big_eye_tiny.jpg"
        ) 
        }
    
#    @attr = {
#      :file => fixture_file_upload(fixture_path + '/big_eye_tiny.jpg','image/jpeg')
#    }
  end
  
  it "should default into local mode" do 
    ActsAsPhocodable.storeage_mode.should == "local"
  end
 
  it "should be able to go into offline mode" do
    ActsAsPhocodable.storeage_mode = "offline" 
    ActsAsPhocodable.storeage_mode.should == "offline"
  end
  
  it "should return some thumbnail options" do
    ImageUpload.phocoder_thumbnails.should_not be_nil
    ImageUpload.phocoder_thumbnails.size.should == 2
  end
  
  it "should return attributes for a specific thumbnail" do
    ImageUpload.thumbnail_attributes_for("small").should_not be_nil
  end
  
  
  it "should be phocodable" do
    @image = ImageUpload.new
    @image.phocodable?.should be_true
  end
  
  it "should get the right file name" do
    iu = ImageUpload.new(@attr)
    iu.filename.should == "big_eye_tiny.jpg"
  end
  
  it "should save the file to a local storage location" do
    iu = ImageUpload.new(@attr)
    iu.save
    
    expected_resource_dir = "ImageUpload/1"
    iu.resource_dir.should == expected_resource_dir
    
    expected_local_url = "/ImageUpload/1/big_eye_tiny.jpg"
    iu.local_url.should == expected_local_url
    
    
    
    expected_local_path = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)),'..','dummy','public','ImageUpload',iu.id.to_s,iu.filename))
    iu.local_path.should == expected_local_path
    iu.local_url.should == "/ImageUpload/#{iu.id}/#{iu.filename}"
    File.exists?(expected_local_path).should be_true
    iu.destroy
    File.exists?(expected_local_path).should_not be_true
  end
  
end
