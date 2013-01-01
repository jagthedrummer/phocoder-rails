require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderController do

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
      post 'phocoder_notification_update', {:class=>"ImageUpload",:id=>1, :job=>{:id => 1},:input=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      #@image_upload.reload
      #@image_upload.file_size.should == 2
    end
    
    it "should update an output" do
      EncodableJob.should_receive(:update_from_phocoder)
      post 'phocoder_notification_update', {:class=>"ImageUpload",:id=>1, :job=>{:id => 1}, :output=>{:id=>1,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      #@image_upload.reload
      #@image_upload.file_size.should == 2
    end
    
    # sometimes an encodable job doesn't get created.  Why?
    it "should fall back if no encodable job can be found" do
      EncodableJob.should_receive(:update_from_phocoder)
      post 'phocoder_notification_update', {:class=>"ImageUpload",:id=>@image_upload.id, :job=>{:id => 2}, :output=>{:id=>2,:file_size=>2,:width=>2,:height=>2,:url=>"http://production.webapeel.com/octolabs/themes/octolabs/images/octologo.png"},:format=>"json" }
      response.should be_success
      # This is a controller test, not integration test
      #@image_upload.reload
      #@image_upload.file_size.should == 2
    end
    

    it "should handle job tracking updates" do
      @encodable_job.tracking_mode = 'job'
      @encodable_job.save
      post 'phocoder_notification_update', {:class=>"ImageUpload",:id=>1, :job=>{:id => 1,:type=>"ThumbnailJob"},:format=>"json", :inputs => [{}], :outputs => []}
      response.should be_success
    end

    it "should update all the things for job tracking updates" do
      @encodable_job.tracking_mode = 'job'
      @encodable_job.save
      @thumbnail = @image_upload.thumbnails.create!(:thumbnail => "small")
      params = {
        :class=>@image_upload.class.name.to_s,:id=>@image_upload.id,
        "job"=>{"state"=>"complete", "id"=>1, "type"=>"ThumbnailJob", "pixels"=>26379158, "processing_time"=>43.0}, 
        "inputs"=>[{"id"=>50, "state"=>"complete", "file_size"=>4742478, "width"=>4288, "height"=>2848, "pixels"=>12212224, "processing_time"=>5.0, "url"=>"http://development.thephotolabs.com.s3.amazonaws.com/photos/150/dsc_8400.jpg", "lat"=>nil, "lng"=>nil, "taken_at"=>"2010-03-08T17:04:29Z", "camera_make"=>0, "camera_model"=>0, "bits_per_pixel"=>8, "exposure_time"=>"0.008000000", "f_number"=>"13.000000000", "iso_speed_rating"=>"1000", "exposure_bias_value"=>"-1.000000000", "focal_length"=>"10.000000000", "focal_length_in_35mm_film"=>"15", "subsec_time"=>74}], 
        "outputs"=>[{"id"=>85, "state"=>"complete", "file_size"=>69735, "label"=>"small", "url"=>"s3://development.thephotolabs.com/photo_thumbnails/150/small_dsc_8400.jpg", "pixels"=>6600, "processing_time"=>2.0, "width"=>100, "height"=>66}]
      }
      post 'phocoder_notification_update', params.symbolize_keys
      @encodable_job.reload
      @image_upload.reload
      @thumbnail.reload
      puts @image_upload.to_json
      @encodable_job.phocoder_status.should == 'ready'
      @image_upload.phocoder_status.should == 'ready'
      @image_upload.width.should == 4288
      @thumbnail.phocoder_status.should == 'ready'
    end

  end
  
 
   
   
  describe "POST zencoder update" do
    
    before(:each) do
      @thumb = @image_upload.thumbnails.create(:phocoder_job_id=>2,:phocoder_input_id=>2,:phocoder_output_id=>2,
                                               :zencoder_job_id=>2,:zencoder_input_id=>2,:zencoder_output_id=>2,
                                               :file_size=>2,:width=>2,:height=>2)
      @encodable_job2 = EncodableJob.create(:phocoder_job_id=>2,:phocoder_input_id=>2,:phocoder_output_id=>2,
                                            :zencoder_job_id=>2,:zencoder_input_id=>2,:zencoder_output_id=>2,
                                            :encodable=>@thumb)
    end
    
    after(:each) do
      @thumb.destroy
      @encodable_job2.destroy
    end
       
                     
 
    
    
    it "should update an output" do
      #Zencoder::Job.should_receive(:details).and_return(mock(Zencoder::Response,:body=>{
      #  "job" => {"id"=>2, 
      #            "state" => "finished", 
      #            "input_media_file" => {"width" => 2,"height" => 2, 
      #                                   "duration_in_ms" => 2, "file_size_bytes" => 2 } ,
      #            "output_media_files" => [{"width" => 1, "height" => 1, "duration_in_ms" => 1, "file_size_bytes" => 1, "id" => 2 }],
      #            "thumbnails" => [{ "url" => "http://farm2.static.flickr.com/1243/5168720424_ea33e31d96.jpg", "id" => 1 }]
      #  }
      # }))
      #
      # Phocoder::Job.should_receive(:create).and_return(mock(Phocoder::Response,:body=>{
      #  "job"=>{
      #  "id"=>1,
      #  "inputs"=>["id"=>1],
      #  "thumbnails"=>[{"label"=>"small","filename"=>"small-test-file.jpg","id"=>1}]
      #}
      #}))
                  
      
      EncodableJob.should_receive(:update_from_zencoder)
      #@image_upload.should_receive(:create_zencoder_image_thumb).and_return(nil)
      post 'zencoder_notification_update', {:class=>"ImageUpload",:id=>@thumb.id,
                                            "job"=>{"state"=>"finished","id"=>2},
                                            "output" => { :label => "web", :url => "http://example.com/file.mp4", :state => "finished", :id => 2},       
                                            :format=>"json" 
                                           }
      response.should be_success
      # Comment this out for now.  This is a controller test, not an integration test.
      # we don't get direct info on the input, just the thumb
      #@thumb.reload
      #@thumb.file_size.should == 1
    end    
    
  end # describe POST
  
  
  
end
