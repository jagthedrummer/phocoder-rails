module PhocoderHelper

  require 'active_support/secure_random'
  
  def preview_reload_timeout
    #time in ms between preview reloading
    10000
  end
  
  
  def phocoder_includes
    tag =  stylesheet_link_tag '/javascripts/video-js-2.0.2/video-js.css'
    tag += "\n"
    tag += javascript_include_tag 'video-js-2.0.2/video.js'
    tag += "\n"
    tag += stylesheet_link_tag 'phocodable.css'
    tag += "\n"
    tag += %[<script type="text/javascript" charset="utf-8">VideoJS.setupAllWhenReady();</script>].html_safe
  end
  
  
  # for now we'll assume that a thumbnail is needed
  # some files aren't displayable in a native way (NEF etc...)
  # 
  def phocoder_thumbnail(image_upload,thumbnail="small",live_video=true)
    #get the details about this particular thumbnail size
    thumbnail_atts = image_upload.class.thumbnail_attributes_for thumbnail
    if ActsAsPhocodable.storeage_mode == "offline" and (thumbnail.nil? or !thumbnail_atts.blank?)
      return offline_phocoder_thumbnail(image_upload,thumbnail_atts)
    elsif image_upload.image? 
      phocoder_image_thumbnail image_upload, thumbnail,thumbnail_atts
    elsif (image_upload.video? and !live_video)
      tag =  %[<span class="phocoder_video_poster">]
      tag += phocoder_image_thumbnail(image_upload, thumbnail,thumbnail_atts)
      tag += %[<img src="/images/play_small.png" alt="Play" width="25" height="25" class="play"/>]
      tag += "</span>"
      tag.html_safe
      
    elsif image_upload.video?
      phocoder_video_thumbnail image_upload, thumbnail,thumbnail_atts
    else
      %[<span class="error">No preview available for #{image_upload.filename}</span>]
    end
  end
  
  
  def phocoder_video_thumbnail(image_upload,thumbnail="small",thumbnail_atts={},live_video = true)
    if image_upload.zencoder_status != 'ready'
      pending_phocoder_thumbnail(image_upload,thumbnail,true,thumbnail_atts)
    elsif live_video
      phocoder_video_embed(image_upload,thumbnail_atts)
    else
      %[<div class="phocoder_video_thumbnail">Video static image thumb goes here.</div>].html_safe  
    end
  end
  
  
  
  def phocoder_video_embed(image_upload,thumbnail_atts,options={} )
    options.merge!(:video => image_upload, :width=>image_upload.calc_width(thumbnail_atts),:height=>image_upload.calc_height(thumbnail_atts))
    render(:partial => 'phocoder/video_embed', :locals => options)
  end
  
  
  def phocoder_offline_video_embed(image_upload,thumbnail_atts,options={} )
    options.merge!(:video => image_upload, :width=>image_upload.calc_width(thumbnail_atts),:height=>image_upload.calc_height(thumbnail_atts))
    render(:partial => 'phocoder/offline_video_embed', :locals => options)
  end
  
  
  # for now we'll assume that a thumbnail is needed
  # some files aren't displayable in a native way (NEF etc...)
  # 
  def phocoder_image_thumbnail(image_upload,thumbnail="small",thumbnail_atts={})  
    
    
    if thumbnail.nil? and (image_upload.phocoder_status == "ready")
      return image_tag image_upload.public_url, :size=>"#{image_upload.width}x#{image_upload.height}"
    elsif thumbnail_atts.blank?
      return error_div("'#{thumbnail}' is not a valid thumbnail size for #{image_upload.class}")
    elsif image_upload.phocoder_status != "ready" and image_upload.zencoder_status != "ready"
      puts "image_upload is not ready!!!!!!!!!!!!!!!!!!!!!!!!"
      return pending_phocoder_thumbnail(image_upload,thumbnail,false,thumbnail_atts)
    #else
    #  return "<div class='notice'>Online mode is coming soon!</div>"
    end
    
    thumb = image_upload.thumbnail_for(thumbnail)
    if thumb.blank? or thumb.phocoder_status != "ready"
      puts "thumb (#{thumb.to_json}) is not ready!!!!!!!!!!!!!!!!!!!!!!!!"
      #this happens if the main image has been notified, but not this thumbnail
      return pending_phocoder_thumbnail(image_upload,thumbnail,false,thumbnail_atts)
    end
    image_tag thumb.public_url, :size=>"#{thumb.width}x#{thumb.height}"  
  end
  
  
  def error_div(msg)
    %[<div style="border:1px solid red;background:#fee;padding:10px;">#{msg}</div>].html_safe
  end
  
  
  def offline_phocoder_thumbnail(image_upload,thumbnail_atts)
    if image_upload.image?
      offline_phocoder_image_thumbnail(image_upload,thumbnail_atts)
    else
      offline_phocoder_video_embed(image_upload,thumbnail_atts)
    end
  end
  
  
  def offline_phocoder_image_thumbnail(photo,thumbnail_atts)
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
  
  
  def pending_phocoder_thumbnail(photo,thumbnail,live_video,thumbnail_atts,spinner='waiting')
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
