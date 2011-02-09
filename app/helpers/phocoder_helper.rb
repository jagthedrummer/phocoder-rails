module PhocoderHelper

  require 'active_support/secure_random'
  
  def preview_reload_timeout
    #time in ms between preview reloading
    1000
  end
  
  #for now we'll assume that a thumbnail is needed
  #some files aren't displayable in a native way (NEF etc...)
  def phocoder_thumbnail(image_upload,thumbnail="small")
    
    #get the details about this particular thumbnail size
    thumbnail_atts = image_upload.class.thumbnail_attributes_for thumbnail
    if ActsAsPhocodable.storeage_mode == "offline" and (thumbnail.nil? or !thumbnail_atts.blank?)
      return offline_phocoder_thumbnail(image_upload,thumbnail_atts)
    elsif thumbnail.nil? and image_upload.phocoder_status == "ready"
      return image_tag image_upload.public_url, :size=>"#{image_upload.width}x#{image_upload.height}"
    elsif thumbnail_atts.blank?
      return error_div("'#{thumbnail}' is not a valid thumbnail size for ImageUploads")
    elsif image_upload.phocoder_status != "ready"
      return pending_phocoder_thumbnail(image_upload,thumbnail,thumbnail_atts)
    #else
    #  return "<div class='notice'>Online mode is coming soon!</div>"
    end
    
    thumb = image_upload.thumbnail_for(thumbnail)
    if thumb.blank? or thumb.phocoder_status != "ready"
      #this happens if the main image has been notified, but not this thumbnail
      return pending_phocoder_thumbnail(image_upload,thumbnail,thumbnail_atts)
    end
    image_tag thumb.public_url, :size=>"#{thumb.width}x#{thumb.height}"
    
  end
  
  def error_div(msg)
    %[<div style="border:1px solid red;background:#fee;padding:10px;">#{msg}</div>].html_safe
  end
  
  
  
  def offline_phocoder_thumbnail(photo,thumbnail_atts)
    if thumbnail_atts.blank?
      image_tag photo.local_url
    #elsif thumbnail_atts[:aspect_mode].blank? or thumbnail_atts[:aspect_mode] == "preserve" 
      #implement handling for a certain size
      #image_tag photo.local_url, :width => thumbnail_atts[:width]
    elsif thumbnail_atts[:aspect_mode] == "stretch" 
      image_tag photo.local_url, :width => thumbnail_atts[:width],:height => thumbnail_atts[:height]
    else
    #elsif thumbnail_atts[:aspect_mode] == "pad" or thumbnail_atts[:aspect_mode] == "crop"
      "<div style='overflow:hidden;background:#ccc;width:#{thumbnail_atts[:width]}px;height:#{thumbnail_atts[:height]}px'>#{image_tag(photo.local_url,:width => thumbnail_atts[:width])}</div>".html_safe
    end
    
  end
  
  
  def pending_phocoder_thumbnail(photo,thumbnail,thumbnail_atts,spinner='waiting')
    random = ActiveSupport::SecureRandom.hex(16)
    elemId = "#{photo.class.to_s}_#{photo.id.to_s}_#{random}"
    #updater = remote_function(:update=>elemId)
    width = thumbnail_atts[:width]
    height = thumbnail_atts[:height]
    tag = %[<span id="#{elemId}">
              #{ image_tag "#{spinner}.gif", :size=>"#{width}x#{height}" }
              ]
    tag +=%[
            <script type="text/javascript">
              setTimeout(function() {
                new Ajax.Request( '/phocoder/thumbnail_update', {
                    evalScripts:true,
                    parameters: { class:'#{photo.class.to_s}', id:#{photo.id.to_s},thumbnail:'#{thumbnail}',random:'#{random}' }
                });
              },#{preview_reload_timeout});
            </script>   
    ]
    tag += %[</span>]
    tag.html_safe
  end

end