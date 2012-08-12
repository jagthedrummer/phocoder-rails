require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionDispatch::TestProcess


describe EncodableJob do
  
  before(:each) do
    ImageUpload.destroy_all
    EncodableJob.destroy_all
    @image_upload = ImageUpload.create(:phocoder_job_id=>1,:phocoder_input_id=>1,:phocoder_output_id=>1,
      :zencoder_job_id=>1,:zencoder_input_id=>1,:zencoder_output_id=>1,
      :file_size=>1,:width=>1,:height=>1,:filename=>"test.png",:content_type=>"image/png")
    @image_upload2 = ImageUpload.create(:phocoder_job_id=>2,:phocoder_input_id=>2,:phocoder_output_id=>2,
      :zencoder_job_id=>1,:zencoder_input_id=>1,:zencoder_output_id=>1,
      :file_size=>1,:width=>1,:height=>1,:filename=>"test.png",:content_type=>"image/png")
    @encodable_job = EncodableJob.create(:phocoder_job_id=>1,:phocoder_input_id=>1,:phocoder_output_id=>nil,
      :zencoder_job_id=>nil,:zencoder_input_id=>nil,:zencoder_output_id=>nil,
      :encodable=>@image_upload)
    @encodable_job2 = EncodableJob.create(:phocoder_job_id=>2,:phocoder_input_id=>nil,:phocoder_output_id=>2,
      :zencoder_job_id=>nil,:zencoder_input_id=>nil,:zencoder_output_id=>nil,
      :encodable=>@image_upload2)
    @job_params_json = %[{"aasm_state":"complete","api_key":"idYSHSxL98zxPab21q8y8VtL3Wti1lIR","created_at":"2012-08-07T04:41:09Z","end_load_1":0.0,"end_load_15":0.05,"end_load_5":0.01,"error_msg":null,"id":1,"lock_version":3,"pixels":276400,"processing_cores":2,"processing_ended_at":"2012-08-07T04:43:24Z","processing_host":"domU-12-31-39-18-21-1E","processing_started_at":"2012-08-07T04:43:23Z","queue_name":null,"start_load_1":0.0,"start_load_15":0.05,"start_load_5":0.01,"updated_at":"2012-08-07T04:43:24Z","user_id":1,"thumbnails":[{"aasm_state":"complete","analyze_ended_at":"2012-08-07T04:43:23Z","analyze_started_at":"2012-08-07T04:43:23Z","aspect_mode":"preserve","base_url":"s3://development.phocoder.com/image_thumbnails/6/","created_at":"2012-08-07T04:41:09Z","error_msg":null,"filename":"small_super_small_dsc_7428.jpg","format":"jpg","height":100,"id":349266,"job_id":1,"label":"small","lock_version":7,"output_content_type":"image/jpeg","output_file_size":19379,"output_height":67,"output_width":100,"quality":95,"resize_ended_at":"2012-08-07T04:43:23Z","resize_started_at":"2012-08-07T04:43:23Z","updated_at":"2012-08-07T04:43:23Z","upload_ended_at":"2012-08-07T04:43:23Z","upload_started_at":"2012-08-07T04:43:23Z","upscale":null,"user_id":null,"width":100},{"aasm_state":"complete","analyze_ended_at":"2012-08-07T04:43:24Z","analyze_started_at":"2012-08-07T04:43:24Z","aspect_mode":"preserve","base_url":"s3://development.phocoder.com/image_thumbnails/6/","created_at":"2012-08-07T04:41:09Z","error_msg":null,"filename":"medium_super_small_dsc_7428.jpg","format":"jpg","height":400,"id":349267,"job_id":1,"label":"medium","lock_version":7,"output_content_type":"image/jpeg","output_file_size":54356,"output_height":309,"output_width":400,"quality":95,"resize_ended_at":"2012-08-07T04:43:24Z","resize_started_at":"2012-08-07T04:43:23Z","updated_at":"2012-08-07T04:43:24Z","upload_ended_at":"2012-08-07T04:43:24Z","upload_started_at":"2012-08-07T04:43:24Z","upscale":null,"user_id":null,"width":400}],"inputs":[{"aasm_state":"complete","analyze_ended_at":"2012-08-07T04:43:23Z","analyze_started_at":"2012-08-07T04:43:23Z","bits_per_pixel":8,"camera_make":"NIKON CORPORATION","camera_model":"NIKON D300","content_type":"image/jpeg","created_at":"2012-08-07T04:41:09Z","download_ended_at":"2012-08-07T04:43:23Z","download_started_at":"2012-08-07T04:43:23Z","error_msg":null,"exposure_bias_value":"0","exposure_time":"0.016666666","f_number":"16.000000000","file_size":93974,"focal_length":"200.000000000","focal_length_in_35mm_film":"300","height":266,"id":1,"iso_speed_rating":"400","job_id":1,"lat":null,"lng":null,"lock_version":6,"orientation":1,"subsec_time":42,"taken_at":"2009-10-12T15:17:42Z","updated_at":"2012-08-07T04:43:23Z","url":"http://development.phocoder.com.s3.amazonaws.com/images/6/super_small_dsc_7428.jpg","user_id":1,"width":400}],"hdr_thumbnails":[]}]
    @job_params_json2 = %[{"aasm_state":"complete","api_key":"idYSHSxL98zxPab21q8y8VtL3Wti1lIR","created_at":"2012-08-07T04:41:09Z","end_load_1":0.0,"end_load_15":0.05,"end_load_5":0.01,"error_msg":null,"id":2,"lock_version":3,"pixels":276400,"processing_cores":2,"processing_ended_at":"2012-08-07T04:43:24Z","processing_host":"domU-12-31-39-18-21-1E","processing_started_at":"2012-08-07T04:43:23Z","queue_name":null,"start_load_1":0.0,"start_load_15":0.05,"start_load_5":0.01,"updated_at":"2012-08-07T04:43:24Z","user_id":1,"thumbnails":[{"aasm_state":"complete","analyze_ended_at":"2012-08-07T04:43:23Z","analyze_started_at":"2012-08-07T04:43:23Z","aspect_mode":"preserve","base_url":"s3://development.phocoder.com/image_thumbnails/6/","created_at":"2012-08-07T04:41:09Z","error_msg":null,"filename":"small_super_small_dsc_7428.jpg","format":"jpg","height":100,"id":2,"job_id":1,"label":"small","lock_version":7,"output_content_type":"image/jpeg","output_file_size":19379,"output_height":67,"output_width":100,"quality":95,"resize_ended_at":"2012-08-07T04:43:23Z","resize_started_at":"2012-08-07T04:43:23Z","updated_at":"2012-08-07T04:43:23Z","upload_ended_at":"2012-08-07T04:43:23Z","upload_started_at":"2012-08-07T04:43:23Z","upscale":null,"user_id":null,"width":100},{"aasm_state":"complete","analyze_ended_at":"2012-08-07T04:43:24Z","analyze_started_at":"2012-08-07T04:43:24Z","aspect_mode":"preserve","base_url":"s3://development.phocoder.com/image_thumbnails/6/","created_at":"2012-08-07T04:41:09Z","error_msg":null,"filename":"medium_super_small_dsc_7428.jpg","format":"jpg","height":400,"id":349267,"job_id":1,"label":"medium","lock_version":7,"output_content_type":"image/jpeg","output_file_size":54356,"output_height":309,"output_width":400,"quality":95,"resize_ended_at":"2012-08-07T04:43:24Z","resize_started_at":"2012-08-07T04:43:23Z","updated_at":"2012-08-07T04:43:24Z","upload_ended_at":"2012-08-07T04:43:24Z","upload_started_at":"2012-08-07T04:43:24Z","upscale":null,"user_id":null,"width":400}],"inputs":[{"aasm_state":"complete","analyze_ended_at":"2012-08-07T04:43:23Z","analyze_started_at":"2012-08-07T04:43:23Z","bits_per_pixel":8,"camera_make":"NIKON CORPORATION","camera_model":"NIKON D300","content_type":"image/jpeg","created_at":"2012-08-07T04:41:09Z","download_ended_at":"2012-08-07T04:43:23Z","download_started_at":"2012-08-07T04:43:23Z","error_msg":null,"exposure_bias_value":"0","exposure_time":"0.016666666","f_number":"16.000000000","file_size":93974,"focal_length":"200.000000000","focal_length_in_35mm_film":"300","height":266,"id":2,"iso_speed_rating":"400","job_id":1,"lat":null,"lng":null,"lock_version":6,"orientation":1,"subsec_time":42,"taken_at":"2009-10-12T15:17:42Z","updated_at":"2012-08-07T04:43:23Z","url":"http://development.phocoder.com.s3.amazonaws.com/images/6/super_small_dsc_7428.jpg","user_id":1,"width":400}],"hdr_thumbnails":[]}]
  end
  
  after(:each) do
    @image_upload.destroy
    @encodable_job.destroy
  end
  
  
  describe "update_status" do
    it "should update inputs" do
      Phocoder::Job.should_receive(:details).and_return(double :body => JSON(@job_params_json) )
      @encodable_job.update_status
      @encodable_job.reload
      @image_upload.reload
      #@encodable_job.phocoder_status.should == "ready"
      @image_upload.encodable_status.should == "ready"
    end
    
    it "should update outputs" do
      puts "//////////////////////"
      stub_request(:get, "http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 200, :body => webmock_file("octologo.png"), :headers => {})
      Phocoder::Job.should_receive(:details).and_return(double :body => JSON(@job_params_json2) )
      @encodable_job2.update_status
      @encodable_job2.reload
      @image_upload2.reload
      #@encodable_job.phocoder_status.should == "ready"
      @image_upload2.encodable_status.should == "ready"
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
    
    
        
    it "should update outputs" do
      stub_request(:get, "http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 200, :body => webmock_file("octologo.png"), :headers => {})
      params =  {:class=>"ImageUpload",
                  :id=>2, 
                  :job=>{:id => 2}, 
                  :output=>{:id=>2,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},
                  :format=>"json" 
                }
      EncodableJob.update_from_phocoder(params);
      
      @image_upload2.reload
      @image_upload2.encodable_status.should == "ready"
      @image_upload2.file_size.should == 2
    end
    
        
  end
    
  
end