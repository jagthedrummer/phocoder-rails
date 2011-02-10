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
  
  it "should default into automatic processing mode" do 
    ActsAsPhocodable.processing_mode.should == "automatic"
  end
  
  
  it "should be able to go into offline mode" do
    ActsAsPhocodable.processing_mode = "resque" 
    ActsAsPhocodable.processing_mode.should == "resque"
    #reset for later tests
    ActsAsPhocodable.processing_mode = "automatic" 
  end
  
  it "should default to the url in the config" do 
    ActsAsPhocodable.base_url.should == "http://actsasphocodableexample.chaos.webapeel.com"
  end
  
  it "should take a new base_url" do 
    ActsAsPhocodable.base_url = "http://new-domain.com"
    ActsAsPhocodable.base_url.should == "http://new-domain.com"
  end
  
  
  it "should default to the normal config file" do 
    ActsAsPhocodable.config_file.should == "config/phocodable.yml"
  end
  
  it "should take a new config file" do 
    ActsAsPhocodable.config_file = "new_config/phocodable.yml"
    ActsAsPhocodable.config_file.should == "new_config/phocodable.yml"
    #reset it so we don't screw up other tests
    ActsAsPhocodable.config_file = "config/phocodable.yml"
    ActsAsPhocodable.config_file.should == "config/phocodable.yml"
  end
  
    
  it "should read the config file" do
    ActsAsPhocodable.config_file == "config/phocodable.yml"
    iu = ImageUpload.new
    iu.phocodable_config.should_not be_nil
  end
  
  
  it "should read actual configs" do
    ActsAsPhocodable.config_file == "config/phocodable.yml"
    iu = ImageUpload.new()
    iu.phocodable_config.should_not be_nil
    # these values are based on a config in spec/dummy/config/phocodable.yml
    # it is currently excluded from git since it contains an API key
    # this will fail for any one other than me.
    # what to do? 
    iu.phocodable_config[:phocoder_url].should == "http://photoapi.chaos.webapeel.com"
    iu.phocodable_config[:base_url].should == "http://actsasphocodableexample.chaos.webapeel.com"
  end
  
  it "should create phocoder params based on the acts_as_phocodable :thumbnail options" do
    iu = ImageUpload.new(@attr)
    phorams = iu.phocoder_params
    puts phorams.to_json
    phorams.should_not be_nil
    phorams[:input][:url].should == iu.public_url
    phorams[:thumbnails].size.should == 2
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
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
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
  
  it "should call phocoder" do
    iu = ImageUpload.new(@attr)
    
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    expected_local_path = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)),'..','dummy','public','ImageUpload',iu.id.to_s,iu.filename))
    File.exists?(expected_local_path).should be_true
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
    iu.destroy
    ImageUpload.count.should == 0
    File.exists?(expected_local_path).should_not be_true
  end
  
  it "should update parent images from phocoder" do
    iu = ImageUpload.new(@attr.merge :phocoder_input_id=>1)
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    ImageUpload.update_from_phocoder({:input=>{:id=>1,:width=>10,:height=>20,:file_size=>30}})
    iu.reload
    iu.width.should == 10
    iu.height.should == 20
    iu.file_size.should == 30
    iu.phocoder_status.should == "ready"
    iu.destroy
  end
  
  it "should update thumbnail images from phocoder and donwload images in local mode" do
    ActsAsPhocodable.storeage_mode = "local"
    iu = ImageUpload.new(@attr.merge :phocoder_input_id=>1)
    iu.save
    thumb = iu.thumbnails.new(:phocoder_output_id=>1)
    thumb.save
    
    
    ImageUpload.update_from_phocoder({:output=>{:id=>1,:width=>10,:height=>20,:file_size=>30,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png" }})
    
    thumb.reload
    #expected_local_path = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)),'..','dummy','public','ImageUpload',iu.id.to_s,thumb.filename))
    puts "thumb.local_path = #{thumb.local_path} - #{thumb.id}"
    File.exists?(thumb.local_path).should be_true
    thumb.width.should == 10
    thumb.height.should == 20
    thumb.file_size.should == 30
    thumb.filename.should == "octologo.png"
    thumb.phocoder_status.should == "ready"
    #thumb.destroy
    #File.exists?(expected_local_path).should_not be_true
    #iu.destroy
  end
    
  
  it "in delayed s3 mode it should save the file to an AWS S3 storage location, call phocoder, then destroy" do
    ActsAsPhocodable.storeage_mode = "s3"
    ActsAsPhocodable.processing_mode = "delayed"
    ImageUpload.establish_aws_connection
    
    iu = ImageUpload.new(@attr)
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>[{"id"=>1}],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    
    #now store in S3 + phocode
    iu.save
    
    #it should not be in S3 yet
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should raise_error(Exception)
    
    iu.save_s3_file
    
    bucket = iu.s3_bucket_name
    key = iu.s3_key
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should_not raise_error(Exception)
    
    iu.destroy
    #after destroy the file should not be in S3 anymore
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should raise_error(Exception)
    
  end
  
  
  it "in automatic s3 mode it should save the file to an AWS S3 storage location, call phocoder, then destroy" do
    ActsAsPhocodable.storeage_mode = "s3"
    ActsAsPhocodable.processing_mode = "automatic"
    ImageUpload.establish_aws_connection
    
    iu = ImageUpload.new(@attr)
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>[{"id"=>1}],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    
    #now store in S3 + phocode
    iu.save
    
    bucket = iu.s3_bucket_name
    key = iu.s3_key
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should_not raise_error(Exception)
    
    iu.destroy
    #after destroy the file should not be in S3 anymore
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should raise_error(Exception)
    
  end
  
  
end
