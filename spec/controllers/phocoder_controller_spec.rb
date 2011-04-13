require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderController do

  before(:each) do
    @image_upload = ImageUpload.create(:phocoder_job_id=>1,:phocoder_input_id=>1,:phocoder_output_id=>1,
                                       :zencoder_job_id=>1,:zencoder_input_id=>1,:zencoder_output_id=>1,
                                       :file_size=>1,:width=>1,:height=>1,:filename=>"test.png",:content_type=>"image/png")
  end
  
  after(:each) do
    @image_upload.destroy
  end

  #at this point the image_upload does not have any thumbnails created
  describe "POST to 'thumbnail_update' " do
    
    it "should assign and update an img" do
      post 'thumbnail_update', { :class=>@image_upload.class.name.to_s,:id=>@image_upload.id,:thumbnail=>"small",:format=>"js" }  
      response.should be_success
      assigns(:img).id.should == @image_upload.id
    end
    
  end
  
  
  
  describe "POST 'phocoder_update'" do
    
    it "should update an input" do
      post 'phocoder_notification_update', {:class=>"ImageUpload",:id=>1,:input=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      @image_upload.reload
      @image_upload.file_size.should == 2
    end
    
    it "should update an output" do
      post 'phocoder_notification_update', {:class=>"ImageUpload",:id=>1,:output=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      @image_upload.reload
      @image_upload.file_size.should == 2
    end
    
  end
  
  
    
  
  describe "POST zencoder update" do
    
    before(:each) do
      @thumb = ImageUpload.create(:phocoder_job_id=>2,:phocoder_input_id=>2,:phocoder_output_id=>2,:zencoder_job_id=>2,:zencoder_input_id=>2,:zencoder_output_id=>2,:file_size=>2,:width=>2,:height=>2,:parent_id=>@image_upload.id)
    end
    
    after(:each) do
      @thumb.destroy
    end
       
        
 
    
    
    it "should update an output" do
      Zencoder::Job.should_receive(:details).and_return(mock(Zencoder::Response,:body=>{
        "job" => {"id"=>2, 
                  "state" => "finished", 
                  "input_media_file" => {"width" => 2,"height" => 2, 
                                         "duration_in_ms" => 2, "file_size_bytes" => 2 } ,
                  "output_media_files" => [{"width" => 1, "height" => 1, "duration_in_ms" => 1, "file_size_bytes" => 1, "id" => 2 }],
                  "thumbnails" => [{ "url" => "http://farm2.static.flickr.com/1243/5168720424_ea33e31d96.jpg", "id" => 1 }]
        }
       }))
      
       Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
        "job"=>{
        "id"=>1,
        "inputs"=>["id"=>1],
        "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      }
      }))
      
      #@image_upload.should_receive(:create_zencoder_image_thumb).and_return(nil)
      post 'zencoder_notification_update', {:class=>"ImageUpload",:id=>@thumb.id,
                                            "job"=>{"state"=>"finished","id"=>2},
                                            "output" => { :label => "web", :url => "http://example.com/file.mp4", :state => "finished", :id => 2},       
                                            :format=>"json" 
                                           }
      response.should be_success
      # we don't get direct info on the input, just the thumb
      @thumb.reload
      @thumb.file_size.should == 1
    end    
    
  end
  
end