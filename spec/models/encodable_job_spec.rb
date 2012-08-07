require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionDispatch::TestProcess


describe EncodableJob do
  
  before(:each) do
    @image_upload = ImageUpload.create(:phocoder_job_id=>1,:phocoder_input_id=>1,:phocoder_output_id=>1,
      :zencoder_job_id=>1,:zencoder_input_id=>1,:zencoder_output_id=>1,
      :file_size=>1,:width=>1,:height=>1,:filename=>"test.png",:content_type=>"image/png")
    @encodable_job = EncodableJob.create(:phocoder_job_id=>1,:phocoder_input_id=>1,:phocoder_output_id=>1,
      :zencoder_job_id=>1,:zencoder_input_id=>1,:zencoder_output_id=>1,
      :encodable=>@image_upload)
  end
  
  after(:each) do
    @image_upload.destroy
    @encodable_job.destroy
  end
  
  describe "update_status" do
    it "should call Phocoder::Job.details and then call update_from_phocoder" do
      Phocoder::Job.should_receive(:details).and_return(double :body => nil)
      EncodableJob.should_receive(:update_from_phocoder).and_return(nil)
      @encodable_job.update_status
    end
  end
  
  describe "update_from_phocoder" do
    
    
    
    it "should fupdate inputs" do
      params = {  :class=>"ImageUpload", 
                  :id=>1, 
                  :format=>"json",
                  :job=>{ :id => 1 },
                  :input=>{   :id=>1,
                              :file_size=>2,
                              :width=>2,
                              :height=>2,
                              :url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png",
                              :bits_per_pixel => "8",
                              :camera_make => "NIKON CORPORATION",
                              :camera_model => "NIKON D300",
                              :orientation => "1",
                              :exposure_time => "(1/60)",
                              :f_number => "16",
                              :iso_speed_rating => "200",
                              :exposure_bias_value => "(0/1)",
                              :focal_length => "20",
                              :focal_length_in_35mm_film => "30",
                              :subsec_time => "23"
                          },
                
              }
      EncodableJob.update_from_phocoder(params);
      
      @image_upload.reload
      @image_upload.encodable_status.should == "ready"
      @image_upload.file_size.should == 2
      @image_upload.bits_per_pixel.should == 8
      @image_upload.camera_make.should == "NIKON CORPORATION"
      @image_upload.camera_model.should == "NIKON D300"
      @image_upload.orientation.should == 1
      @image_upload.exposure_time.should == "(1/60)"
      @image_upload.f_number.should == "16"
      @image_upload.iso_speed_rating.should == "200"
      @image_upload.exposure_bias_value.should == "(0/1)"
      @image_upload.focal_length.should == "20"
      @image_upload.focal_length_in_35mm_film.should == "30"
      @image_upload.subsec_time.should == 23
    end
    
    
    
    it "should update outpus" do
      stub_request(:get, "http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 200, :body => webmock_file("octologo.png"), :headers => {})
      params =  {:class=>"ImageUpload",:id=>1, :job=>{:id => 1}, :output=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      EncodableJob.update_from_phocoder(params);
      
      @image_upload.reload
      @image_upload.encodable_status.should == "ready"
      @image_upload.file_size.should == 2
    end
    
    
    
  end
  
  
end