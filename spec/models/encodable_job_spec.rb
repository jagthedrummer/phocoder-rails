require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionDispatch::TestProcess


describe EncodableJob do
  
  describe "update_from_phocoder" do
    
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
    
    it "should fupdate inputs" do
      params = {:class=>"ImageUpload",:id=>1, :job=>{:id => 1},:input=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      EncodableJob.update_from_phocoder(params);
      
      @image_upload.reload
      @image_upload.encodable_status.should == "ready"
      @image_upload.file_size.should == 2
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