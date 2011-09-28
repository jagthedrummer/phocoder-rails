class EncodableJob < ActiveRecord::Base
  
  belongs_to :encodable, :polymorphic=>true
  
  def self.update_from_phocoder(params)
    Rails.logger.debug "tying to call update from phocoder for params = #{params.to_json}"
    puts "tying to call update from phocoder for params = #{params.to_json}"
    if !params[:output].blank?
      Rails.logger.debug "find_by_phocoder_job_id_and_phocoder_output_id_and_encodable_type #{params[:job][:id]} - #{params[:output][:id]} ,#{params[:class]}"
      puts "find_by_phocoder_job_id_and_phocoder_output_id_and_encodable_type #{params[:job][:id]} - #{params[:output][:id]} ,#{params[:class]}"
      job = self.find_by_phocoder_job_id_and_phocoder_output_id_and_encodable_type params[:job][:id],params[:output][:id],params[:class]
      
      
      Rails.logger.debug "the job = #{job}"
      img_params = params[:output]
      begin
        encodable = job.encodable
      rescue NoMethodError => ex
        # here we try to fall back if we can't find an Encodable
        encodable = params[:class].constantize.find params[:id]
      end       
      encodable.filename = File.basename(params[:output][:url]) if encodable.filename.blank?
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
    [:file_size,:width,:height,:taken_at,:lat,:lng,:saturated_pixels,:gauss].each do |att|
      setter = att.to_s + "="
      if encodable.respond_to? setter and !img_params[att].blank?
        encodable.send setter, img_params[att]
      end
    end
    
    #job.file_size = img_params[:file_size]
    #job.width = img_params[:width]
    #job.height = img_params[:height]
    encodable.encodable_status = "ready"
    encodable.save
    encodable.fire_ready_callback
    # may not have a job if the EncodableJob didn't get created for some reason
    if job
      job.phocoder_status = "ready"
      job.save
      job
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