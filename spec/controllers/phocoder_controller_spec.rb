require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderController do

  before(:each) do
    @image_upload = ImageUpload.create(:phocoder_job_id=>1,:phocoder_input_id=>1,:phocoder_output_id=>1,:file_size=>1,:width=>1,:height=>1)
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
      post 'phocoder_update', {:class=>"ImageUpload",:id=>1,:input=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      @image_upload.reload
      @image_upload.file_size.should == 2
    end
    
    it "should update an output" do
      post 'phocoder_update', {:class=>"ImageUpload",:id=>1,:output=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      @image_upload.reload
      @image_upload.file_size.should == 2
    end
    
  end
  
end