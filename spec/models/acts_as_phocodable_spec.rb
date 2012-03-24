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
#        @attr = {
#        :file => ActionDispatch::Http::UploadedFile.new(
#          :tempfile=> Rack::Test::UploadedFile.new(fixture_path + '/big_eye_tiny.jpg', 'image/jpeg'),
#          :filename=>"big_eye_tiny.jpg"
#        ) 
#        }
    ImageUpload.destroy_all
    @attr = {
      :file => fixture_file_upload(fixture_path + '/big_eye_tiny.jpg','image/jpeg')
    }
    @vid_attr = {
      :file => fixture_file_upload(fixture_path + '/video-test.mov', 'video/quicktime')
    }
    @txt_attr = {
      :file => fixture_file_upload(fixture_path + '/test.txt', 'text/plain')
    }
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
    ActsAsPhocodable.config = nil
    ActsAsPhocodable.config.should be_nil
    
    ActsAsPhocodable.read_phocodable_configuration
    ActsAsPhocodable.config.should_not be_nil
    ActsAsPhocodable.config.to_json.should_not == "{}"
    #iu = ImageUpload.new
    #iu.phocodable_config.should_not be_nil
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
  
  
  describe "create_label_from_size_string" do
    it "should transform 50x50! => 50x50_crop" do
      ImageUpload.create_label_from_size_string("50x50!").should == "50x50crop" 
    end
    it "should transform 50x50> => 50x50_preserve" do
      ImageUpload.create_label_from_size_string("50x50>").should == "50x50preserve" 
    end
  end
  
  describe "create_atts_from_size_string" do
    it "should return the right hash" do
      atts = ImageUpload.create_atts_from_size_string("100x200crop")
      atts[:width].should == "100"
      atts[:height].should == "200"
      atts[:aspect_mode].should == "crop"
    end
  end
      
  it "should create phocoder params based on the acts_as_phocodable :thumbnail options" do
    iu = ImageUpload.new(@attr)
    phorams = iu.phocoder_params
    #puts phorams.to_json
    phorams.should_not be_nil
    phorams[:input][:url].should == iu.public_url
    phorams[:thumbnails].size.should == 2
  end
  
  it "should create phocoder params based on input thumbs that are passed in" do
    iu = ImageUpload.new(@attr)
    phorams = iu.phocoder_params([{:label=>"test",:width=>60,:height=>60}])
    #puts phorams.to_json
    phorams.should_not be_nil
    phorams[:input][:url].should == iu.public_url
    phorams[:thumbnails].size.should == 1
  end
    
  
  it "should create zencooder params based on the acts_as_phocodable :videos options" do
    iu = ImageUpload.new(@vid_attr)
    zenrams = iu.zencoder_params
    #puts zenrams.to_json
    zenrams.should_not be_nil
    zenrams[:input].should == iu.public_url
    zenrams[:outputs].size.should == 2
    #the first thumbnail variant :thumbnails => { :number => 2, ...}
    zenrams[:outputs][0][:thumbnails][:base_url].should be_nil
    #the second thumbnail variant :thumbnails => [{...},{...}]
    #we removed this for now - only 1 thumb is being generated, automatically 
    #zenrams[:outputs][1][:thumbnails][0][:base_url].should be_nil
  end
  
  
  it "should create zencooder params with base_urls in s3 mode based on the acts_as_phocodable :videos options" do
    ActsAsPhocodable.storeage_mode = "s3"
    iu = ImageUpload.new(@vid_attr)
    zenrams = iu.zencoder_params
    #puts zenrams.to_json
    zenrams.should_not be_nil
    zenrams[:input].should == iu.public_url
    zenrams[:outputs].size.should == 2
    #the first thumbnail variant :thumbnails => { :number => 2, ...}
    zenrams[:outputs][0][:thumbnails][:base_url].should_not be_nil
    #the second thumbnail variant :thumbnails => [{...},{...}]
    #we removed this for now - only 1 thumb is being generated, automatically 
    #zenrams[:outputs][1][:thumbnails][0][:base_url].should_not be_nil
    ActsAsPhocodable.storeage_mode = "local"
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
    iu = ImageUpload.new(@txt_attr)
    Phocoder::Job.should_not_receive(:create)
    iu.save
    
    expected_resource_dir = "image_uploads/1"
    iu.resource_dir.should == expected_resource_dir
    
    expected_local_url = "/image_uploads/1/test.txt"
    iu.local_url.should == expected_local_url
    
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    iu.local_path.should == expected_local_path
    iu.local_url.should == "/image_uploads/#{iu.id}/#{iu.filename}"
    File.exists?(expected_local_path).should be_true
    iu.destroy
    File.exists?(expected_local_path).should_not be_true
  end
#  
  it "should call phocoder for images" do
    iu = ImageUpload.new(@attr)
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    File.exists?(expected_local_path).should be_true
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
    iu.destroy
    ImageUpload.count.should == 0
    File.exists?(expected_local_path).should_not be_true
  end
    
    
  it "should call phocoder for images and be able to add new thumbs" do
    iu = ImageUpload.new(@attr)
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    File.exists?(expected_local_path).should be_true
    # phocode is called after save in this mode
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"test","filename"=>"test-test-file.jpg","id"=>2}]
      }
    }))
    
    iu.clear_phocoding
    iu.phocode([{:label=>"test",:width=>60,:height=>60}])
    ImageUpload.count.should == 3
    
    # now to make sure that it doesn't try to recode exsiting thumbs
    iu.clear_phocoding
    iu.phocode([{:label=>"test",:width=>60,:height=>60}])
    ImageUpload.count.should == 3
    
    
    iu.destroy
    ImageUpload.count.should == 0
    File.exists?(expected_local_path).should_not be_true
  end
     
     
     
  it "should call phocoder for images and be able to add new thumbs on the fly" do
    iu = ImageUpload.new(@attr)
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    File.exists?(expected_local_path).should be_true
    # phocode is called after save in this mode
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
    
    
    #this thumbnail doesn't exist yet
    lambda{
      nt = iu.thumbnail_for("new_test")
    }.should raise_error(Exception)
    
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"anothertest","filename"=>"test-test-file.jpg","id"=>2}]
      }
    }))
     
    iu.clear_phocoding
    at = iu.thumbnail_for({:label=>"anothertest",:width=>60,:height=>60})
    at.should_not be_nil
    ImageUpload.count.should == 3
    
    # now to make sure that it doesn't try to recode exsiting thumbs
    iu.clear_phocoding
    at = iu.thumbnail_for({:label=>"anothertest",:width=>60,:height=>60})
    at.should_not be_nil
    ImageUpload.count.should == 3
    
    
    iu.destroy
    ImageUpload.count.should == 0
    File.exists?(expected_local_path).should_not be_true
  end
  
  
  
  it "should call phocoder for images and be able to add new thumbs on the fly with no label" do
    iu = ImageUpload.new(@attr)
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    File.exists?(expected_local_path).should be_true
    # phocode is called after save in this mode
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
    
    
    #this thumbnail doesn't exist yet
    lambda{
      nt = iu.thumbnail_for("new_test")
    }.should raise_error(Exception)
    
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"60x60","filename"=>"test-test-file.jpg","id"=>2}]
      }
    }))
     
    iu.clear_phocoding
    at = iu.thumbnail_for({:width=>60,:height=>60})
    at.should_not be_nil
    ImageUpload.count.should == 3
    
    # now to make sure that it doesn't try to recode exsiting thumbs
    iu.clear_phocoding
    at = iu.thumbnail_for({:width=>60,:height=>60})
    at.should_not be_nil
    ImageUpload.count.should == 3
    
    iu.destroy
    ImageUpload.count.should == 0
    File.exists?(expected_local_path).should_not be_true
  end
              
  
  it "should call phocoder for images and be able to add new thumbs on the fly with just a size string label" do
    iu = ImageUpload.new(@attr)
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    iu.save
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    File.exists?(expected_local_path).should be_true
    # phocode is called after save in this mode
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
      
    #this thumbnail doesn't exist yet
    lambda{
      nt = iu.thumbnail_for("new_test")
    }.should raise_error(Exception)
    
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"60x60","filename"=>"test-test-file.jpg","id"=>2}]
      }
    }))
    
    iu.clear_phocoding
    at = iu.thumbnail_for("60x60")
    at.should_not be_nil
    ImageUpload.count.should == 3
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"80x","filename"=>"test-test-file.jpg","id"=>3}]
      }
    }))
    
    iu.clear_phocoding
    at = iu.thumbnail_for("80x")
    at.should_not be_nil
    ImageUpload.count.should == 4
   
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"x90","filename"=>"test-test-file.jpg","id"=>4}]
      }
    }))
   
    iu.clear_phocoding
    at = iu.thumbnail_for("x90")
    at.should_not be_nil
    ImageUpload.count.should == 5
    
    Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>2,
        "inputs"=>["id"=>2],
        "thumbnails"=>[{"label"=>"","filename"=>"test.jpg","id"=>5}]
      }
    }))
   
    iu.clear_phocoding
    at = iu.thumbnail_for("100x100!")
    at.should_not be_nil
    ImageUpload.count.should == 6
    
    iu.destroy
    ImageUpload.count.should == 0
    File.exists?(expected_local_path).should_not be_true
  end
 
  
  
  
  it "should call zencoder for videos" do
    iu = ImageUpload.new(@vid_attr)  
    Zencoder::Job.should_receive(:create).and_return(mock(Zencoder::Response,:body=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "outputs"=>[{"label"=>"mp4","url"=>"http://someurl/","filename"=>"small-test-file.mp4","id"=>1}]
    }))
    #iu.should_receive(:create_zencoder_image_thumb).and_return(nil)
    iu.save
    expected_local_path = File.join('/tmp','image_uploads',iu.id.to_s,iu.filename)
    File.exists?(expected_local_path).should be_true
    #iu.phocode
    ImageUpload.count.should == 2 #it should have created a thumbnail record
    
    #iu.reload #make sure it knows aobut the thumbnail
    iu.destroy
    #puts "ImageUpload.first = #{ImageUpload.first.to_json}"
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
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[] # don't auto create thumbs since we'll make one below
      }
    }))
    iu.save
    thumb = iu.thumbnails.new(:phocoder_output_id=>1)
    #Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
    #  "job"=>{
    #    "id"=>1,
    #    "inputs"=>["id"=>1],
    #    "thumbnails"=>[]
    #  }
    #}))
    thumb.save
    
    stub_request(:get, "http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png").
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 200, :body => webmock_file("octologo.png"), :headers => {})
     
     
    ImageUpload.update_from_phocoder({:output=>{:id=>1,:width=>10,:height=>20,:file_size=>30,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png" }})
    
    thumb.reload
    #expected_local_path = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)),'..','dummy','public','ImageUpload',iu.id.to_s,thumb.filename))
    #puts "thumb.local_path = #{thumb.local_path} - #{thumb.id}"
    File.exists?(thumb.local_path).should be_true
    thumb.width.should == 10
    thumb.height.should == 20
    thumb.file_size.should == 30
    thumb.filename.should == "octologo.png"
    thumb.phocoder_status.should == "ready"
    thumb.destroy
    File.exists?(thumb.local_path).should_not be_true
    iu.destroy
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
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-thumbnail.jpg","id"=>1}]
      }
    }))
    
    #This save will work since we're in delayed mode
    iu.save
    # No thumbnail should be created yet
    iu.thumbnails.size.should == 0
    # Mock the AWS reqeust for storing 
    AWS::S3::S3Object.should_receive(:store).and_return(nil)
    # Mock the AWS request for checking file size
    AWS::S3::S3Object.should_receive(:find).and_return( mock(:size => 19494) )
    
    iu.save_s3_file
    # Now we should have a thumb
    iu.thumbnails.size.should == 1
    # Mock the AWS reqeust for deleting the file and it's thumbnail
    AWS::S3::S3Object.should_receive(:delete).twice.and_return(nil)
    iu.destroy
  end
  
  
  it "in automatic s3 mode it should save the file to an AWS S3 storage location, call phocoder, then destroy" do
    ActsAsPhocodable.storeage_mode = "s3"
    ActsAsPhocodable.processing_mode = "automatic"
    ImageUpload.establish_aws_connection
    #puts "======================================="
    iu = ImageUpload.new(@attr)
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>[{"id"=>1}],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    
    # Mock the AWS reqeust for storing 
    AWS::S3::S3Object.should_receive(:store).and_return(nil)
    # Mock the AWS request for checking file size
    AWS::S3::S3Object.should_receive(:find).and_return( mock(:size => 19494) )
    #now store in S3 + phocode
    iu.save
    #puts "======================================="
    #puts iu.thumbnails.to_json
    iu.thumbnails.size.should == 1 
    
    iu.destroy
  end
  
  
  it "in spawn s3 mode it should save the file to an AWS S3 storage location, call phocoder, then destroy" do
    # In testing we use the spawn :yield strategy, which is really just the same as
    # automatic (inline) processing.  It works for testing, and hopefully works in production.
    # Hopefully...
    ActsAsPhocodable.storeage_mode = "s3"
    ActsAsPhocodable.processing_mode = "spawn"
    ImageUpload.establish_aws_connection
    
    iu = ImageUpload.new(@attr)
    Phocoder::Job.stub!(:create).and_return(mock(Phocoder::Response,:body=>{
      "job"=>{
        "id"=>1,
        "inputs"=>[{"id"=>1}],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
    }))
    
    # Mock the AWS reqeust for storing 
    AWS::S3::S3Object.should_receive(:store).and_return(nil)
    # Mock the AWS request for checking file size
    AWS::S3::S3Object.should_receive(:find).and_return( mock(:size => 19494) )
    
    #now store in S3 + phocode
    iu.save
    iu.thumbnails.size.should == 1
    
    iu.destroy 
  end
  
  
end
