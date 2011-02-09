class PhocoderController < ApplicationController
  
  protect_from_forgery :except=>[:phocoder_update,:thumbnail_update]  

  def phocoder_update
    logger.debug "the params = #{params.to_json}"
    @image_upload = ImageUpload.update_from_phocoder(params)
    respond_to do |format|
      format.html
      format.json  { render :json => {} }
      format.xml  { render :xml => {} }
    end
  end
  
  def thumbnail_update
    @img = Kernel.const_get(params[:class]).find params[:id]
    @random = params[:random]
    respond_to do |format|
      format.js {}
    end
  end
  
end