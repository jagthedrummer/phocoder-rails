class PhocoderController < ApplicationController
  
  protect_from_forgery :except=>[:notification_update,:thumbnail_update]  
  
  def notification_update
    # Sometimes Rails does not like to honor either the 'Accept' or 'Content Type' headers.
    # It also wan't follow :format => js, or :format => json and just refuses to parse the body.
    # This is a brute force way around the problem for now.
    # It would be nice to know what's at the root of this problem.
    # The TVN Media project (rarearth) is a prime example.
    #payload = symbolize_keys(ActiveSupport::JSON.decode(request.body))
    #logger.debug "the params = #{params.to_json} - #{payload.to_json}"
    #full_params = params.merge payload
    #@image_upload = full_params[:class].constantize.update_from_phocoder(full_params)
    
    # This may have been due to a screwy Rails upgrade.  
    # 3.0.3 seems to break this and make routes all screwy  
    @image_upload = params[:class].constantize.update_from_phocoder(params)
    
    #@image_upload = ImageUpload.update_from_phocoder(params)
    respond_to do |format|
      #format.html  { render :json => {} }
      format.json  { render :json => {} }
      #format.xml  { render :xml => {} }
    end
  end
  
  
  def zencoder_notification_update
    # Sometimes Rails does not like to honor either the 'Accept' or 'Content Type' headers.
    # It also wan't follow :format => js, or :format => json and just refuses to parse the body.
    # This is a brute force way around the problem for now.
    # It would be nice to know what's at the root of this problem.
    # The TVN Media project (rarearth) is a prime example.
    payload = symbolize_keys(ActiveSupport::JSON.decode(request.body))
    logger.debug "the params = #{params.to_json} - #{payload.to_json}"
    full_params = params.merge payload
    @image_upload = full_params[:class].constantize.update_from_zencoder(full_params)
    
    
    #@image_upload = ImageUpload.update_from_phocoder(params)
    respond_to do |format|
      #format.html  { render :json => {} }
      format.json  { render :json => {} }
      #format.xml  { render :xml => {} }
    end
  end
  
  def thumbnail_update
    @img = Kernel.const_get(params[:class]).find params[:id]
    @random = params[:random]
    respond_to do |format|
      format.js {}
    end
  end
  
  
  # thanks to http://avdi.org/devblog/2009/07/14/recursively-symbolize-keys/
  def symbolize_keys(hash)  
    hash.inject({}){|result, (key, value)|  
      new_key = case key  
        when String then key.to_sym  
      else key  
      end  
      new_value = case value  
        when Hash then symbolize_keys(value)  
      else value  
      end  
      result[new_key] = new_value  
      result  
    }  
  end
  
  
  
end
