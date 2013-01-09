class EncodableJob < ActiveRecord::Base
  
  belongs_to :encodable, :polymorphic=>true
  
  scope :pending, :conditions => "phocoder_status != 'ready'"
  scope :for_components, :conditions => "tracking_mode = 'component'"
  scope :for_jobs, :conditions => "tracking_mode = 'job'"

  def initialize(params = {}, options={})
    super
    self.tracking_mode = "component" unless self.tracking_mode
  end
  
  def update_status
    job_data = Phocoder::Job.details(phocoder_job_id).body
    #puts job_data.to_json
    puts "    EncodableJob #{id} = #{job_data["aasm_state"]}"
    if phocoder_input_id
      job_data["inputs"].each do |input|
        #puts "input = #{input.to_json}"
        #puts "input id = #{input["id"]} my phocoder_input_id = #{phocoder_input_id}"
        if input["id"] == phocoder_input_id
          input.symbolize_keys!
          params = {
            :class => encodable_type,
            :id => encodable_id,
            :job => { :id => job_data["id"] },
            :input => input
          }
          EncodableJob.update_from_phocoder(params)
        end
      end
    elsif phocoder_output_id
      outputs = (job_data["thumbnails"] || []) + 
        (job_data["hdrs"] || []) + 
        (job_data["tone_mappings"] || []) + 
        (job_data["composites"] || []) + 
        (job_data["hdr_htmls"] || [])
      outputs.each do |output|
        if output["id"] == phocoder_output_id
          output.symbolize_keys!
          output[:url] = output[:base_url] + output[:filename]
          params = {
            :class => encodable_type,
            :id => encodable_id,
            :job => { :id => job_data["id"] },
            :output => output
          }
          EncodableJob.update_from_phocoder(params)
        end
      end
    end
    puts "+++++++++++++++"
    # if job_data["aasm_state"] == "complete"
    #   self.phocoder_status = "ready"
    #   self.encodable.encodable_status = "ready"
    #   self.encodable.thumbnails.each do |t|
    #     t.encodable_status = "ready"
    #   end
    #   self.save
    #   self.encodable.save
    # end
  end
  
  def self.update_pending_jobs
    EncodableJob.pending.find_each do |e|
      e.update_status
    end
  end
  

  def self.update_from_phocoder(params)
    if params.keys.include?(:inputs) && params.keys.include?(:outputs)
      update_from_phocoder_job_style(params)
    else
      update_from_phocoder_component_style(params)
    end
  end

  def self.update_from_phocoder_job_style(params)
    if params[:job][:type] == 'ThumbnailJob'
      update_from_phocoder_thumbnail_job(params)
    elsif params[:job][:type] == 'CompositeJob' || params[:job][:type] == 'ToneMappingJob'
      update_from_phocoder_generic_job_with_thumbnails(params)
    else
      update_from_phocoder_generic_job(params)
    end
  end

  def self.update_from_phocoder_thumbnail_job(params)
    #debugger
    job = self.for_jobs.find_by_phocoder_job_id params[:job][:id]
    encodable = job.encodable
    
    img_params = params[:inputs].first
    update_encodable_and_job_from_img_params(encodable,job,img_params)

    params[:outputs].each do |thumb_params|
      thumbnail = encodable.thumbnail_for(thumb_params[:label])
      update_encodable_and_job_from_img_params(thumbnail,job,thumb_params)
      thumbnail.encodable_status = "ready" if thumbnail.respond_to?(:encodable_status=)
      thumbnail.phocoder_status = "ready" if thumbnail.respond_to?(:phocoder_status=)
      thumbnail.save!
    end

    encodable.encodable_status = "ready" if encodable.respond_to?(:encodable_status=)
    encodable.phocoder_status = "ready" if encodable.respond_to?(:phocoder_status=)
    encodable.save!
    encodable.fire_ready_callback
    
    job.phocoder_status = "ready"
    job.save
    job
  end

  def self.update_from_phocoder_generic_job(params)
    #debugger
    job = self.for_jobs.find_by_phocoder_job_id params[:job][:id]
    encodable = job.encodable
    
    img_params = params[:outputs].first
    update_encodable_and_job_from_img_params(encodable,job,img_params)

    encodable.encodable_status = "ready" if encodable.respond_to?(:encodable_status=)
    encodable.phocoder_status = "ready" if encodable.respond_to?(:phocoder_status=)
    encodable.save!
    encodable.fire_ready_callback

    job.phocoder_status = "ready"
    job.save
    job
  end

  def self.update_from_phocoder_generic_job_with_thumbnails(params)
    #debugger
    job = self.for_jobs.find_by_phocoder_job_id params[:job][:id]
    encodable = job.encodable
    
    img_params = {}
    

    params[:outputs].each do |thumb_params|
      if thumb_params[:label].blank?
        img_params = thumb_params
        next
      end
      thumbnail = encodable.thumbnail_for(thumb_params[:label])
      update_encodable_and_job_from_img_params(thumbnail,job,thumb_params)
      thumbnail.encodable_status = "ready" if thumbnail.respond_to?(:encodable_status=)
      thumbnail.phocoder_status = "ready" if thumbnail.respond_to?(:phocoder_status=)
      thumbnail.save!
    end

    update_encodable_and_job_from_img_params(encodable,job,img_params)
    encodable.encodable_status = "ready" if encodable.respond_to?(:encodable_status=)
    encodable.phocoder_status = "ready" if encodable.respond_to?(:phocoder_status=)
    encodable.save!
    encodable.fire_ready_callback
    
    job.phocoder_status = "ready"
    job.save
    job
  end

  def self.update_from_phocoder_component_style(params)
    Rails.logger.debug "tying to call update from phocoder for params = #{params.to_json}"
    puts "tying to call update from phocoder for params = #{params.to_json}"
    if !params[:output].blank?
      Rails.logger.debug "find_by_phocoder_job_id_and_phocoder_output_id_and_encodable_type #{params[:job][:id]} - #{params[:output][:id]} ,#{params[:class]}"
      puts "find_by_phocoder_job_id_and_phocoder_output_id_and_encodable_type #{params[:job][:id]} - #{params[:output][:id]} ,#{params[:class]}"
      job = self.find_by_phocoder_job_id_and_phocoder_output_id_and_encodable_type params[:job][:id],params[:output][:id],params[:class]
      
      puts "the job = #{job.to_json}"
      Rails.logger.debug "the job = #{job.to_json}"
      img_params = params[:output]
      begin
        encodable = job.encodable
      rescue NoMethodError => ex
        puts "something went wrong..."
        # here we try to fall back if we can't find an Encodable
        encodable = params[:class].constantize.find params[:id]
      end       
      puts "encodable = #{encodable.to_json}"
      if encodable.respond_to?(:filename) && encodable.filename.blank?
        encodable.filename = File.basename(params[:output][:url])
      end
      if ActsAsPhocodable.storeage_mode == "local"
        encodable.save_url(params[:output][:url])
      end
    else
      puts "find_by_phocoder_job_id_and_phocoder_input_id_and_encodable_type #{params[:job][:id]}, #{params[:input][:id]}, #{params[:class]}" 
      job = find_by_phocoder_job_id_and_phocoder_input_id_and_encodable_type params[:job][:id],params[:input][:id],params[:class]
      puts "found job = #{job.to_json}"
      puts "job.encodable = #{job.encodable}"
      img_params = params[:input]
      encodable = job.encodable
    end
      
    update_encodable_and_job_from_img_params(encodable,job,img_params)
    #job.file_size = img_params[:file_size]
    #job.width = img_params[:width]
    #job.height = img_params[:height]
    encodable.encodable_status = "ready"
    
    encodable.save

    if params[:output].blank? && params[:input].blank?
      # Do nothing?  Only for tracking job status, not components...
    else
      encodable.fire_ready_callback
    end
    
    # may not have a job if the EncodableJob didn't get created for some reason
    if job
      job.phocoder_status = "ready"
      job.save
      job
    end
  end
  

  def self.update_encodable_and_job_from_img_params(encodable,job,img_params)
    [ :file_size,:width,:height,:taken_at,:lat,:lng,:saturated_pixels,:gauss,:bits_per_pixel,:camera_make, 
      :camera_model, :orientation, :exposure_time, :f_number, :iso_speed_rating, :exposure_bias_value, 
      :focal_length, :focal_length_in_35mm_film, :subsec_time, :pixels, :processing_time].each do |att|
      setter = att.to_s + "="
      if encodable.respond_to? setter and !img_params[att].blank?
        encodable.send setter, img_params[att]
      end
      if job.respond_to? setter and !img_params[att].blank?
        job.send setter, img_params[att]
      end
    end
  end
  
  
  # Updating from zencoder is a two pass operation.
  # This method gets called for each output when it's ready.
  # Once all outputs are ready, we call parent.check_zencoder_details
  def self.update_from_zencoder(params)
    Rails.logger.debug "tying to call update from zencoder for params = #{params}"
    job = find_by_zencoder_output_id params[:output][:id]
    encodable = job.encodable
    if params[:output][:url].match /%2F(.*)\?/
      encodable.filename = $1
    else
      encodable.filename = File.basename(params[:output][:url].match(/(.*)\??/)[1])
    end
    #job.filename = File.basename(params[:output][:url].match(/(.*)\??/)[1]) if job.filename.blank?
    if ActsAsPhocodable.storeage_mode == "local"
      encodable.save_url(params[:output][:url])
    end
    job.zencoder_status = encodable.encodable_status = "ready"
    encodable.save
    encodable.fire_ready_callback
    job.save
    puts "~~~~~~~~~~~~~~~~~~~~` #{encodable.to_json}"
    
    if encodable.parent
      puts " WE NEED TO CHECK ON PARENT on #{encodable.to_json}"
      encodable.parent.check_zencoder_details 
    #else
    #  puts " WE NEED TO CHECK OUR SELF!"
    #  encodable.check_zencoder_details
    end   
  end
  
  
  
  
end
