module PhocoderHelper

  require 'active_support/secure_random'
  
  def preview_reload_timeout
    #time in ms between preview reloading
    10000
  end
    
  
  def phocoder_includes   
    tag  = javascript_include_tag 'phocodable.js'
    tag += "\n"
    tag += stylesheet_link_tag 'phocodable.css'
  end
    
  
  def phocoder_video_includes
    tag =  stylesheet_link_tag '/javascripts/video-js-2.0.2/video-js.css'
    tag += "\n"
    tag += javascript_include_tag 'video-js-2.0.2/video.js'
    tag += "\n"
    tag += %[<script type="text/javascript" charset="utf-8">VideoJS.setupAllWhenReady();</script>].html_safe
  end
  
  
  def phocoder_link(text,file)
    if file.encodable_status == "ready" or file.encodable_status == "s3"
      link_to text, file.public_filename
    else
      text
    end
  end
  
  
  # for now we'll assume that a thumbnail is needed
  # some files aren't displayable in a native way (NEF etc...)
  # 
  def phocoder_thumbnail(encodable,thumbnail="small",live_video=true,options={})
    
    if encodable.video?
      return phocoder_video_thumbnail(encodable,thumbnail,live_video,options)
    elsif encodable.image?
      return phocoder_image_thumbnail(encodable,thumbnail,options)  
    else
      return error_div("This #{encodable.class} is not an image or a video.")
    end
  end
  
#  def old_phocoder_thumbnail(image_upload,thumbnail="small",live_video=true,options={})
#    #get the details about this particular thumbnail size
#    thumbnail_atts = image_upload.class.thumbnail_attributes_for thumbnail
#    if ActsAsPhocodable.storeage_mode == "offline" and (thumbnail.nil? or !thumbnail_atts.blank?)
#      return offline_phocoder_thumbnail(image_upload,thumbnail_atts,options)
#    elsif image_upload.image? 
#      phocoder_image_thumbnail image_upload, thumbnail,options
#    elsif (image_upload.video? and !live_video)
#      tag =  %[<span class="phocoder_video_poster">]
#      tag += phocoder_image_thumbnail(image_upload, thumbnail,thumbnail_atts,options)
#      tag += %[<img src="/images/play_small.png" alt="Play" width="25" height="25" class="play"/>]
#      tag += "</span>"
#      tag.html_safe     
#    elsif image_upload.video?
#      phocoder_video_thumbnail image_upload, thumbnail,thumbnail_atts, options
#    else # this seems to happen in some rare cases.  I need to figure out which cases...
#      image_tag "error.png"
#    end
#  end
  
  
  def phocoder_video_thumbnail(image_upload,thumbnail="small",live_video = true,options={})
    thumbnail_atts = image_upload.class.thumbnail_attributes_for thumbnail
    if image_upload.encodable_status != 'ready'
      pending_phocoder_thumbnail(image_upload,thumbnail,true,thumbnail_atts)
    elsif live_video
      phocoder_video_embed(image_upload,thumbnail_atts,options)
    else # Video stuff needs work.
      tag =  %[<span class="phocoder_video_poster">]
      tag += phocoder_image_thumbnail(image_upload, thumbnail,options)
      tag += %[<img src="/images/play_small.png" alt="Play" width="25" height="25" class="play"/>]
      tag += "</span>"
      tag.html_safe
    end
  end
  
  
  
  def phocoder_video_embed(image_upload,thumbnail_atts,options={} )
    options.merge!(:video => image_upload, :width=>image_upload.calc_width(thumbnail_atts),:height=>image_upload.calc_height(thumbnail_atts))
    render(:partial => 'phocoder/video_embed', :locals => options)
  end
  
  
  def offline_phocoder_video_embed(image_upload,thumbnail_atts,options={} )
    options.merge!(:video => image_upload, :width=>image_upload.calc_width(thumbnail_atts),:height=>image_upload.calc_height(thumbnail_atts))
    render(:partial => 'phocoder/offline_video_embed', :locals => options)
  end
  
  
  # for now we'll assume that a thumbnail is needed
  # some files aren't displayable in a native way (NEF etc...)
  # 
  def phocoder_image_thumbnail(image_upload,thumbnail="small",options={})  
    puts "thumbnail = #{thumbnail}"
    thumbnail_atts = image_upload.class.thumbnail_attributes_for thumbnail
    if ActsAsPhocodable.storeage_mode == "offline" and (thumbnail.blank? or !thumbnail_atts.blank?)
      return offline_phocoder_thumbnail(image_upload,thumbnail_atts,options)
    elsif thumbnail.nil? and (image_upload.encodable_status == "ready")
      return image_tag image_upload.public_url, {:size=>"#{image_upload.width}x#{image_upload.height}"}.merge(options)
    elsif thumbnail_atts.blank?
      return error_div("'#{thumbnail}' is not a valid thumbnail size for #{image_upload.class}")
    elsif image_upload.encodable_status != "ready" #and image_upload.zencoder_status != "ready"
      puts "image_upload is not ready!!!!!!!!!!!!!!!!!!!!!!!!"
      return pending_phocoder_thumbnail(image_upload,thumbnail,false,thumbnail_atts)
    #else
    #  return "<div class='notice'>Online mode is coming soon!</div>"
    end
    
    thumb = image_upload.thumbnail_for(thumbnail)
    if thumb.blank? or thumb.encodable_status != "ready"
      puts "thumb (#{thumb.to_json}) is not ready!!!!!!!!!!!!!!!!!!!!!!!!"
      #this happens if the main image has been notified, but not this thumbnail
      return pending_phocoder_thumbnail(image_upload,thumbnail,false,thumbnail_atts)
    end
    image_tag thumb.public_url, {:size=>"#{thumb.width}x#{thumb.height}"}.merge(options)
  end
  
  
  def error_div(msg)
    %[<div style="border:1px solid red;background:#fee;padding:10px;">#{msg}</div>].html_safe
  end
  
  
  def offline_phocoder_thumbnail(image_upload,thumbnail_atts,options={})
    if image_upload.image?
      offline_phocoder_image_thumbnail(image_upload,thumbnail_atts,options)
    else
      offline_phocoder_video_embed(image_upload,thumbnail_atts,options)
    end
  end
  
  
  def offline_phocoder_image_thumbnail(photo,thumbnail_atts,options={})
    if thumbnail_atts.blank?
      image_tag photo.local_url, options
    #elsif thumbnail_atts[:aspect_mode].blank? or thumbnail_atts[:aspect_mode] == "preserve" 
      #implement handling for a certain size
      #image_tag photo.local_url, :width => thumbnail_atts[:width]
    elsif thumbnail_atts[:aspect_mode] == "stretch" 
      image_tag photo.local_url, {:width => thumbnail_atts[:width],:height => thumbnail_atts[:height]}.merge(options)
    else
    #elsif thumbnail_atts[:aspect_mode] == "pad" or thumbnail_atts[:aspect_mode] == "crop"
      "<div style='overflow:hidden;background:#ccc;width:#{thumbnail_atts[:width]}px;height:#{thumbnail_atts[:height]}px'>#{image_tag(photo.local_url,{:width => thumbnail_atts[:width]}.merge(options))}</div>".html_safe
    end
  end
  
  
  def pending_phocoder_thumbnail(photo,thumbnail,live_video,thumbnail_atts,spinner='waiting')
    random = ActiveSupport::SecureRandom.hex(16)
    #updater = remote_function(:update=>elemId)
    elemId = "#{photo.class.to_s}_#{photo.id.to_s}_#{thumbnail}_#{random}"
    width = thumbnail_atts[:width]
    height = thumbnail_atts[:height]
    tag = image_tag "#{spinner}.gif", :size=>"#{width}x#{height}", :id => elemId, "data-phocoder-waiting" => true
    #tag = %[<span id="#{elemId}">
    #          #{ image_tag "#{spinner}.gif", :size=>"#{width}x#{height}" }
    #          ]
    #if ActsAsPhocodable.javascript_library == 'prototype'
    #  tag += prototype_updater(photo,thumbnail,random)
    #else
    #  tag += jquery_updater(photo,thumbnail,random)
    #end
    #tag += %[</span>]
    #tag.html_safe
  end


  #def jquery_updater(photo,thumbnail,random)
  #  %[
  #          <script type="text/javascript">
  #            setTimeout(function() {
  #              $.ajax({ type: 'POST',
  #                       url : '/phocoder/thumbnail_update.js',
  #                       dataType : 'script',
  #                       data : { class:'#{photo.class.to_s}', id:#{photo.id.to_s},thumbnail:'#{thumbnail}',random:'#{random}' }
  #              });
  #            },#{preview_reload_timeout});
  #          </script>   
  #  ]
  #end



  #def prototype_updater(photo,thumbnail,random)
  #  %[
  #          <script type="text/javascript">
  #            setTimeout(function() {
  #              new Ajax.Request( '/phocoder/thumbnail_update', {
  #                  evalScripts:true,
  #                  parameters: { class:'#{photo.class.to_s}', id:#{photo.id.to_s},thumbnail:'#{thumbnail}',random:'#{random}' }
  #              });
  #            },#{preview_reload_timeout});
  #          </script>   
  #  ]
  #end

end
