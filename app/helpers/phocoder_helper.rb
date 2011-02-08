module PhocoderHelper

  require 'active_support/secure_random'
  
  def preview_reload_timeout
    #time in ms between preview reloading
    1000
  end
  
  #for now we'll assume that a thumbnail is needed
  #some files aren't displayable in a native way (NEF etc...)
  def phocoder_thumbnail(image_upload,thumbnail="small")
    thumbnail_atts = ImageUpload.thumbnail_attributes_for thumbnail
    if thumbnail_atts.blank?
      return "<div class='error'>'#{thumbnail}' is not a valid thumbnail size for ImageUploads</div>".html_safe
    end
    thumb = image_upload.thumbnail_for(thumbnail)
    if thumb.blank? or thumb.width.blank?
      return pending_phocoder_thumbnail(image_upload,thumbnail,thumbnail_atts)
    end
    image_tag thumb.s3_url, :size=>"#{thumb.width}x#{thumb.height}"
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
