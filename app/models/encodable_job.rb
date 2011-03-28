class EncodableJob < ActiveRecord::Base
  
  belongs_to :encodable, :polymorphic=>true
  
  def self.update_from_phocoder(params)
    Rails.logger.debug "tying to call update from phocoder for params = #{params.to_json}"
    if !params[:output].blank?
      Rails.logger.debug "find_by_phocoder_output_id #{params[:output][:id]}"
      job = find_by_phocoder_output_id params[:output][:id]
      Rails.logger.debug "the job = #{job}"
      img_params = params[:output]
      encodable = job.encodable
      encodable.filename = File.basename(params[:output][:url]) if encodable.filename.blank?
      if ActsAsPhocodable.storeage_mode == "local"
        encodable.save_url(params[:output][:url])
      end
    else
      job = find_by_phocoder_input_id params[:input][:id]
      img_params = params[:input]
      encodable = job.encodable
    end
    [:file_size,:width,:height,:taken_at,:lat,:lng].each do |att|
      setter = att.to_s + "="
      if encodable.respond_to? setter and !img_params[att].blank?
        encodable.send setter, img_params[att]
      end
    end
    
    #job.file_size = img_params[:file_size]
    #job.width = img_params[:width]
    #job.height = img_params[:height]
    job.phocoder_status = encodable.encodable_status = "ready"
    encodable.save
    job.save
    job
  end
  
  
  
  
end