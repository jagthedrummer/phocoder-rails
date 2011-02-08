require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionDispatch::TestProcess

# change this if sqlite is unavailable
dbconfig = {
  :adapter => 'sqlite3',
  :database => ':memory:'
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false

#dummy migration for testing.
class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :images, :force => true do |t|
      t.string   "filename"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "content_type"
      t.integer  "phocoder_job_id"
      t.integer  "phocoder_input_id"
      t.integer  "phocoder_output_id"
      t.integer  "width"
      t.integer  "height"
      t.integer  "file_size"
      t.string   "thumbnail"
      t.integer  "parent_id"
      t.string   "status"
      t.string   "upload_host"
    end
  end
  
  def self.down
    drop_table :images
  end
end

#dummy class that can become phocodeable
class Image < ActiveRecord::Base
  is_phocodable
end

describe Phocodable do
  
  before(:all){ TestMigration.up }
  after(:all){ TestMigration.up }
  before(:each) do
#    @attr = {
#    :file => ActionDispatch::Http::UploadedFile.new(
#      :tempfile=> Rack::Test::UploadedFile.new(fixture_path + '/big_eye_tiny.jpg', 'image/jpeg'),
#      :filename=>"big_eye_tiny.jpg"
#    ) 
#    }
    
    @attr = {
      :file => fixture_file_upload(fixture_path + '/big_eye_tiny.jpg','image/jpeg')
    }
  end
  
  
  it "should be phocodable" do
    @image = Image.new
    @image.phocodable?.should be_true
  end
  
  it "should get the right file name" do
    iu = Image.new(@attr)
    iu.filename.should == "big_eye_tiny.jpg"
  end
  
  
end
