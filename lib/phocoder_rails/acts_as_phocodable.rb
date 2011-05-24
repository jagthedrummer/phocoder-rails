module ActsAsPhocodable
  
  require 'phocoder'
  require 'zencoder'
  require 'open-uri'
  # Storeage mode controls how uploads are handled.
  # Valid options are:
  #     offline : For development mode with no net connection.  No processing.
  #     local : To store images locally but use Phocoder for processing.
  #     s3 : Store image in S3 and use Phocoder for processing.
  # Set this options either in evnironment.rb or
  # in environments/development.rb etc...
  
  mattr_accessor :storeage_mode
  self.storeage_mode = "local"
  
  
  # Processing mode controls when images get sent to phocoder
  # Valid options are:
  #   automatic : Send to phocoder as soon as the file is stored.
  #               With 'local' storage mode, this submits the job
  #               to phocoder while the user is still waiting.
  mattr_accessor :processing_mode
  self.processing_mode = "automatic"
  
  # This is used as the base address for phocoder notifications.
  # When storeage_mode == "local" this is also used to point
  # phocoder at the file.  
  # It should only be the host.domain portion of the URL
  # no path components.
  mattr_accessor :base_url
  self.base_url = "http://your-domain.com"
  
  # The bucket for storing s3 files
  mattr_accessor :s3_bucket_name
  self.s3_bucket_name = "your-bucket"
  
  # The access_key_id for storing s3 files
  mattr_accessor :s3_access_key_id
  self.s3_access_key_id = "your-access-key-id"
  
  # The secret_access_key for storing s3 files
  mattr_accessor :s3_secret_access_key
  self.s3_secret_access_key = "your-secret-access-key"
  
  # The javascript library to use for updates
  # either 'prototype' or 'jquery'
  mattr_accessor :javascript_library
  self.javascript_library = 'prototype'
  
  # The config file that tells phocoder where to find
  # config options.
  mattr_accessor :config_file
  self.config_file = "config/phocodable.yml"
  
  # The list of content types that will trigger image handling.
  mattr_accessor :image_types
  self.image_types = [
      'image/jpeg',
      'image/pjpeg',
      'image/jpg',
      'image/gif',
      'image/png',
      'image/x-png',
      'image/jpg',
      'image/x-ms-bmp',
      'image/bmp',
      'image/x-bmp',
      'image/x-bitmap',
      'image/x-xbitmap',
      'image/x-win-bitmap',
      'image/x-windows-bmp',
      'image/ms-bmp',
      'application/bmp',
      'application/x-bmp',
      'application/x-win-bitmap',
      'application/preview',
      'image/jp_',
      'application/jpg',
      'application/x-jpg',
      'image/pipeg',
      'image/vnd.swiftview-jpeg',
      'image/x-xbitmap',
      'application/png',
      'application/x-png',
      'image/gi_',
      'image/x-citrix-pjpeg',
      'image/x-nikon-nef',
      'image/tiff',
      'image/x-olympus-orf',
      'image/x-dcraw'
  ]
  
  # The list of content types that will trigger video handling.
  mattr_accessor :video_types
  self.video_types = [
   'application/x-flash-video',
   'video/avi',
   'video/mp4',
   'video/ogg',
   'video/quicktime',
   'video/3gp',
   'video/3gpp',
   'video/vnd.objectvideo',
   'video/x-ms-wmv',
   'video/x-ms-asf',
   'video/x-ms-wvx',
   'video/x-ms-wm',
   'video/x-ms-wmx'
  ]
  
  # Mapping for generating a file extension 
  # based on the codec passed in for zencoder
  mattr_accessor :video_extensions
  self.video_extensions = {
    "h264" => "mp4",
    "vp6" => "vp6",
    "vp8" => "webm",
    "theora" => "ogv",
    "mpeg4" => "mpg",
    "wmv" => "wmv"
  }
  
  def image?(content_type)
    image_types.include?(content_type)
  end
  
  def video?(content_type)
    video_types.include?(content_type)
  end
  
  
  #def self.storeage_mode
  #  @@storeage_mode
  #end
  
  
  def acts_as_phocodable(options = { })
    
    include InstanceMethods
    attr_reader :saved_file
    after_save :save_local_file
    before_destroy :cleanup #:remove_local_file,:destroy_thumbnails,:remove_s3_file
    
    include ActiveSupport::Callbacks

    define_callbacks :file_saved, :file_ready
    
    #cattr_accessor :phocoder_options
    #self.phocoder_options = options
    
    cattr_accessor :phocoder_thumbnails
    self.phocoder_thumbnails = options[:thumbnails] ||= []
    
    cattr_accessor :zencoder_videos
    self.zencoder_videos = options[:videos] ||= []
    
    cattr_accessor :thumbnail_class
    self.thumbnail_class = options[:thumbnail_class] ? options[:thumbnail_class].constantize : self
    
    cattr_accessor :parent_class
    self.parent_class = options[:parent_class] ? options[:parent_class].constantize : self
    
    has_many   :thumbnails, :class_name => "::#{self.thumbnail_class.name}",:as => :parent 
    if self.thumbnail_class != self.parent_class
      #we have to do this to get the poster for videos covered
      belongs_to  :parent, :polymorphic => true
    else
      belongs_to  :parent, :class_name => "::#{self.parent_class.name}" ,:foreign_key => "parent_id"
    end
    
    
    has_many :encodable_jobs, :as => :encodable 
    
    scope :top_level, where({:parent_id=>nil}) if respond_to?(:parent_id)
    scope :top_level, where({}) if !respond_to?(:parent_id)
    # we can't just call this next scope 'parents' because that is already
    # taken and returns an array of parent classes of the ruby object
    scope :parent_items, where({:parent_id=>nil}) if respond_to?(:parent_id)
    scope :parent_items, where({}) if !respond_to?(:parent_id)
    
    scope :thumbnails, where("#{base_class.table_name}.parent_id is not null")
    
    #just a writer, the reader is below
    cattr_accessor :phocodable_configuration
    read_phocodable_configuration
  end
  
  def config
    return phocodable_configuration if !phocodable_configuration.blank?
    self.read_phocodable_configuration
  end
  
  def validates_phocodable
    validates_presence_of :content_type, :filename, :if=>lambda{ parent_id.blank? }
  end
  
  def update_from_phocoder(params)
    Rails.logger.debug "tying to call update from phocoder for params = #{params.to_json}"
    if !params[:output].blank?
      Rails.logger.debug "find_by_phocoder_output_id #{params[:output][:id]}"
      iu = find_by_phocoder_output_id params[:output][:id]
      Rails.logger.debug "the item = #{iu}"
      img_params = params[:output]
      iu.filename = File.basename(params[:output][:url]) if iu.filename.blank?
      if ActsAsPhocodable.storeage_mode == "local"
        iu.save_url(params[:output][:url])
      end
    else
      iu = find_by_phocoder_input_id params[:input][:id]
      img_params = params[:input]
    end
    [:file_size,:width,:height,:taken_at,:lat,:lng].each do |att|
      setter = att.to_s + "="
      if iu.respond_to? setter and !img_params[att].blank?
        iu.send setter, img_params[att]
      end
    end
    
    #iu.file_size = img_params[:file_size]
    #iu.width = img_params[:width]
    #iu.height = img_params[:height]
    iu.phocoder_status = "ready"
    iu.save
    iu
  end
  
  
  # Updating from zencoder is a two pass operation.
  # This method gets called for each output when it's ready.
  # Once all outputs are ready, we call parent.check_zencoder_details
  def update_from_zencoder(params)
    Rails.logger.debug "tying to call update from zencoder for params = #{params}"
    iu = find_by_zencoder_output_id params[:output][:id]
    if params[:output][:url].match /%2F(.*)\?/
      iu.filename = $1
    else
      iu.filename = File.basename(params[:output][:url].match(/(.*)\??/)[1])
    end
    #iu.filename = File.basename(params[:output][:url].match(/(.*)\??/)[1]) if iu.filename.blank?
    if ActsAsPhocodable.storeage_mode == "local"
      iu.save_url(params[:output][:url])
    end
    iu.zencoder_status = "ready"
    iu.save
    iu.parent.check_zencoder_details
  end
  
  def thumbnail_attributes_for(thumbnail = "small")
    atts = self.phocoder_thumbnails.select{|atts| atts[:label] == thumbnail }
    atts.first
  end
  
  
  def read_phocodable_configuration
    config_path =  File.join(::Rails.root.to_s, ActsAsPhocodable.config_file)
    puts "looking for a config in #{config_path}"
    self.phocodable_configuration =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
    self.apply_phocodable_configuration
  end
  
  def apply_phocodable_configuration
    if self.phocodable_configuration[:base_url]
      ActsAsPhocodable.base_url = phocodable_configuration[:base_url]
    end
    if self.phocodable_configuration[:storeage_mode]
      ActsAsPhocodable.storeage_mode = phocodable_configuration[:storeage_mode]
    end
    if self.phocodable_configuration[:processing_mode]
      ActsAsPhocodable.processing_mode = phocodable_configuration[:processing_mode]
    end
    if self.phocodable_configuration[:s3_bucket_name]
      ActsAsPhocodable.s3_bucket_name = phocodable_configuration[:s3_bucket_name]
    end
    if self.phocodable_configuration[:s3_access_key_id]
      ActsAsPhocodable.s3_access_key_id = phocodable_configuration[:s3_access_key_id]
    end
    if self.phocodable_configuration[:s3_secret_access_key]
      ActsAsPhocodable.s3_secret_access_key = phocodable_configuration[:s3_secret_access_key]
    end
    if self.phocodable_configuration[:javascript_library]
      ActsAsPhocodable.javascript_library = phocodable_configuration[:javascript_library]
    end
    
    
    if self.phocodable_configuration[:phocoder_url]
      ::Phocoder.base_url = phocodable_configuration[:phocoder_url]
    end
    if self.phocodable_configuration[:phocoder_api_key]
      ::Phocoder.api_key = phocodable_configuration[:phocoder_api_key]
    end
    if self.phocodable_configuration[:zencoder_api_key]
      ::Zencoder.api_key = phocodable_configuration[:zencoder_api_key]
    end
    if ActsAsPhocodable.storeage_mode == "s3"
      self.establish_aws_connection
    end
  end
  
  def establish_aws_connection
    AWS::S3::Base.establish_connection!(
                                        :access_key_id     => ActsAsPhocodable.s3_access_key_id,
                                        :secret_access_key => ActsAsPhocodable.s3_secret_access_key
    )
  end
  
  
  
  
  
  
  module InstanceMethods
    
    
    
    def image?
      self.class.image?(content_type)
    end
    
    def video?
      self.class.video?(content_type)
    end
    
    def encode
      if image?
        phocode
      elsif video?
        zencode
      end
    end
    
    def recode
      reload #make sure that we have current thumbs
      destroy_thumbnails
      reload
      encode
    end
    
    def ready?
      if ActsAsPhocodable.storeage_mode == "offline"
        true
      #elsif image?
      #  return phocoder_status=='ready'
      #elsif video?
      #  return zencoder_status=='ready'  
      #else
      #  return false
      else
        return encodable_status == "ready"
      end
    end
    
    def error?
      if ActsAsPhocodable.storeage_mode == "offline"
        false
      #elsif image?
      #  return phocoder_status=='failed'
      #elsif video?
      #  return zencoder_status=='failed'
      #else
      #  true
      else
        return encodable_status == "ready"
      end
    end
    
    def create_thumbnails_from_response(response_thumbs,job_id)
      response_thumbs.each do |thumb_params|
        puts "creating a thumb for #{thumb_params["label"]}"
        # we do this the long way around just in case some of these
        # atts are attr_protected
        thumb = nil
        if respond_to?(:parent_id) and !self.parent_id.blank? 
          Rails.logger.debug "trying to create a thumb from the parent "
          thumb = self.parent.thumbnails.new()
          self.parent.thumbnails << thumb
        else
          Rails.logger.debug "trying to create a thumb from myself "
          thumb = self.thumbnails.new()
          self.thumbnails << thumb
        end
        
        
        thumb.thumbnail = thumb_params["label"]
        thumb.filename = thumb_params["filename"]
        tjob = thumb.encodable_jobs.new
        
        tjob.phocoder_output_id = thumb_params["id"]
        tjob.phocoder_job_id = job_id
        #thumb.parent_id = self.id
        tjob.phocoder_status  =  "phocoding"
        thumb.encodable_jobs << tjob
        thumb.encodable_status = "phocoding"
        thumb.save
        Rails.logger.debug "    thumb.errors = #{thumb.errors.to_json}"
        puts "    thumb.errors = #{thumb.errors.to_json}"
      end
    end
    
    def clear_phocoding
      @phocoding = false
    end
    
    def dedupe_input_thumbs(input_thumbs)
      needed_thumbs = []
      input_thumbs.each do |it|
        t = thumbnail_for it[:label]
        if t.blank?
          needed_thumbs << it
        end
      end
      needed_thumbs
    end
    
    def phocode(input_thumbs = self.parent_class.phocoder_thumbnails)
      puts " input_thumbs.count = #{input_thumbs.size}"
      input_thumbs = dedupe_input_thumbs(input_thumbs)
      puts " after dedupe input_thumbs.count = #{input_thumbs.size}"
      #if self.thumbnails.count >= self.class.phocoder_thumbnails.size
      #  raise "This item already has thumbnails!"
      #  return
      #end
      
      return if input_thumbs.size == 0
      # We do this because sometimes save will get called more than once
      # during a single request
      return if @phocoding
      @phocoding = true
      
      Rails.logger.debug "trying to phocode for #{Phocoder.base_url} "
      Rails.logger.debug "callback url = #{callback_url}"
      response = Phocoder::Job.create(phocoder_params(input_thumbs))
      Rails.logger.debug "the phocode response = #{response.to_json}" if Rails.env != "test"
      puts "the phocode response = #{response.to_json}" if Rails.env != "test"
      job = self.encodable_jobs.new
      job.phocoder_input_id = response.body["job"]["inputs"].first["id"]
      job.phocoder_job_id = response.body["job"]["id"]
      job.phocoder_status = "phocoding"
      self.encodable_jobs << job
      self.encodable_status = "phocoding"
      self.save #false need to do save(false) here if we're calling phocode on after_save
      response_thumbs = response.body["job"]["thumbnails"]
      Rails.logger.debug "trying to decode #{response_thumbs.size} response_thumbs = #{response_thumbs.to_json}"
      puts "trying to decode #{response_thumbs.size} response_thumbs = #{response_thumbs.to_json}"
      create_thumbnails_from_response(response_thumbs,response.body["job"]["id"])
    end
    
    def phocode_hdr
      #if self.thumbnails.count >= self.class.phocoder_thumbnails.size
      #  raise "This item already has thumbnails!"
      #  return
      #end
      
      # We do this because sometimes save will get called more than once
      # during a single request
      return if @phocoding
      @phocoding = true
      
      Rails.logger.debug "trying to phocode for #{Phocoder.base_url} "
      Rails.logger.debug "callback url = #{callback_url}"
      response = Phocoder::Job.create(phocoder_hdr_params)
      Rails.logger.debug "the response from phocode_hdr = #{response.body.to_json}"
      job = self.encodable_jobs.new
      job.phocoder_output_id = response.body["job"]["hdr"]["id"]
      job.phocoder_job_id = response.body["job"]["id"]
      job.phocoder_status = "phocoding"
      self.encodable_jobs << job
      self.encodable_status = "phocoding"
      self.save #false need to do save(false) here if we're calling phocode on after_save
     
    end
    
    
    def phocode_tone_mapping
      #if self.thumbnails.count >= self.class.phocoder_thumbnails.size
      #  raise "This item already has thumbnails!"
      #  return
      #end
      
      # We do this because sometimes save will get called more than once
      # during a single request
      return if @phocoding
      @phocoding = true
      
      destroy_thumbnails
      Rails.logger.debug "trying to phocode for #{Phocoder.base_url} "
      Rails.logger.debug "callback url = #{callback_url}"
      response = Phocoder::Job.create(phocoder_tone_mapping_params)
      Rails.logger.debug "tone_mapping response = #{response.body.to_json}"
      puts "tone_mapping response = #{response.body.to_json}"
      job = self.encodable_jobs.new
      job.phocoder_output_id = response.body["job"]["tone_mapping"]["id"]
      job.phocoder_job_id = response.body["job"]["id"]
      job.phocoder_status = "phocoding"
      self.encodable_jobs << job
      self.encodable_status = "phocoding"
      self.save #false need to do save(false) here if we're calling phocode on after_save
      response_thumbs = response.body["job"]["thumbnails"]
      Rails.logger.debug "trying to decode #{response_thumbs.size} response_thumbs = #{response_thumbs.to_json}"
      create_thumbnails_from_response(response_thumbs,response.body["job"]["id"])
    end
    
    
    def phocode_composite
      #if self.thumbnails.count >= self.class.phocoder_thumbnails.size
      #  raise "This item already has thumbnails!"
      #  return
      #end
      
      # We do this because sometimes save will get called more than once
      # during a single request
      return if @phocoding
      @phocoding = true
      
      destroy_thumbnails
      Rails.logger.debug "trying to phocode for #{Phocoder.base_url} "
      Rails.logger.debug "callback url = #{callback_url}"
      response = Phocoder::Job.create(phocoder_composite_params)
      Rails.logger.debug "composite response = #{response.body.to_json}"
      puts "composite response = #{response.body.to_json}"
      job = self.encodable_jobs.new
      job.phocoder_output_id = response.body["job"]["composite"]["id"]
      job.phocoder_job_id = response.body["job"]["id"]
      job.phocoder_status = "phocoding"
      self.encodable_jobs << job
      self.encodable_status = "phocoding"
      self.save #false need to do save(false) here if we're calling phocode on after_save
      response_thumbs = response.body["job"]["thumbnails"]
      Rails.logger.debug "trying to decode #{response_thumbs.size} response_thumbs = #{response_thumbs.to_json}"
      puts "trying to decode #{response_thumbs.size} response_thumbs = #{response_thumbs.to_json}"
      create_thumbnails_from_response(response_thumbs,response.body["job"]["id"])
    end
    
    
    def zencode
      # We do this because sometimes save will get called more than once
      # during a single request
      return if @zencoding
      @zencoding = true
      
      Rails.logger.debug "trying to zencode!!!!!"
      Rails.logger.debug "callback url = #{callback_url}"
      response = Zencoder::Job.create(zencoder_params)
      Rails.logger.debug "response from Zencoder = #{response.body.to_json}"
      job = self.encodable_jobs.new
      job.zencoder_job_id = response.body["id"]
      self.encodable_jobs << job
      
      response.body["outputs"].each do |output_params|
        thumb = self.thumbnails.new()
        thumb.thumbnail = output_params["label"]
        
        tjob = thumb.encodable_jobs.new
        tjob.zencoder_output_id = output_params["id"]
        tjob.zencoder_url = output_params["url"]
        tjob.zencoder_job_id = response.body["id"]
        tjob.zencoder_status  =  "zencoding"
        thumb.encodable_jobs << tjob
        
        self.thumbnails << thumb
        thumb.encodable_status = "zencoding"
        thumb.save
        puts "    thumb.errors = #{thumb.errors.to_json}"
      end
      
      self.save
    end
    
    def phocoder_extension
      if self.content_type.blank?
        ".jpg"
      else
        self.content_type.match(/png/) ? ".png" : ".jpg"
      end
    end
    
    def phocoder_params(input_thumbs = self.parent_class.phocoder_thumbnails)
      {:input => {:url => self.public_url, :notifications=>[{:url=>callback_url }] },
        :thumbnails => phocoder_thumbnail_params(input_thumbs)
      }
    end
    
    def phocoder_thumbnail_params(input_thumbs = self.parent_class.phocoder_thumbnails)
      input_thumbs.map{|thumb|
        thumb_filename = thumb[:label] + "_" + File.basename(self.filename,File.extname(self.filename)) + phocoder_extension 
        base_url = ActsAsPhocodable.storeage_mode == "s3" ? "s3://#{self.s3_bucket_name}/#{self.thumbnail_resource_dir}/" : ""
        th = thumb.clone
        th[:base_url] = base_url  if !base_url.blank?
        th.merge({
          :filename=>thumb_filename,
          :notifications=>[{:url=>thumbnail_callback_url }]
        })
      }
    end
    
    
    def phocoder_hdr_params
      { }
    end
    
    def phocoder_tone_mapping_params
      { }
    end
    
    def phocoder_composite_params
      { }
    end
    
    def zencoder_params
      base_url = ActsAsPhocodable.storeage_mode == "s3" ? "s3://#{self.s3_bucket_name}/#{self.thumbnail_resource_dir}/" : ""
      params = {:input =>  self.public_url ,
        :outputs => self.class.zencoder_videos.map{|video|
          vid_filename = self.new_zencoder_filename( video[:video_codec] )
          vid = video.clone
          if vid[:thumbnails] and vid[:thumbnails].is_a? Array
            vid[:thumbnails].each do |thumb|
              thumb[:base_url] = base_url if !base_url.blank?
            end
          elsif vid[:thumbnails]
            vid[:thumbnails][:base_url] = base_url  if !base_url.blank?
          end        
          
          vid[:base_url] = base_url  if !base_url.blank?
          vid.merge({
            :filename=>vid_filename,
            :public=>1,
            :notifications=>[{:url=>zencoder_thumbnail_callback_url }]
          })
        }
      }
      params[:outputs][0][:thumbnails] = { :number=>1, :start_at_first_frame=>1,:public=>1 }
      params[:outputs][0][:thumbnails][:base_url] = base_url  if !base_url.blank?
      Rails.logger.debug "for zencoder the params = #{params.to_json}"
      #puts "for zencoder the params = #{params.to_json}"
      params
    end
   
    def new_zencoder_filename(format)
      filename + "." + self.class.video_extensions[format]
    end
    
    
    def check_zencoder_details
      # we don't get a lot of info from zencoder, so we have to ask for details
      shouldCheck = true
      thumbnails.each do |t|
        if t.encodable_status != 'ready'
          shouldCheck = false
        end
      end
      
      return  if !shouldCheck
      
      details = Zencoder::Job.details(self.encodable_jobs.last.zencoder_job_id)
      
      #puts "in check_zencoder_details the details.body = #{details.body.to_json}"
      
      if details.body["job"]["state"] != 'finished'
        self.encodable_jobs.last.zencoder_status = details.body["job"]["state"]
        save
        return
      end
      
      self.encodable_jobs.last.zencoder_status = self.encodable_status = "ready"
      self.width = details.body["job"]["input_media_file"]["width"]
      self.height = details.body["job"]["input_media_file"]["height"]
      self.duration_in_ms = details.body["job"]["input_media_file"]["duration_in_ms"]
      self.file_size = details.body["job"]["input_media_file"]["file_size_bytes"]
      self.save
      
      #puts "the output files = #{details.body["job"]["output_media_files"]}"
      
      update_zencoder_outputs(details)
            
      # Now create the image thumb
      create_zencoder_image_thumb(details)
      
    end
    
    
    def update_zencoder_outputs(details)
      details.body["job"]["output_media_files"].each do |output|
        #puts "updating for output = #{output.to_json}"
        job = EncodableJob.find_by_zencoder_output_id output["id"]
        thumb = job.encodable
        thumb.width = output["width"]
        thumb.height = output["height"]
        thumb.file_size = output["file_size_bytes"]
        thumb.duration_in_ms = output["duration_in_ms"]
        thumb.save
      end
    end
    
    def create_zencoder_image_thumb(details)
      
      # for now we should only have one thumbnail
      output = details.body["job"]["thumbnails"].first
      return if output.blank?
      thumb = thumbnails.new
      thumb.thumbnail = "poster"
      thumb.width = output["width"]
      thumb.height = output["height"]
      thumb.file_size = output["file_size_bytes"]
      thumb.filename = "frame_0000.png" #File.basename(output["url"])
      thumb.content_type = "image/png"
      if ActsAsPhocodable.storeage_mode == "local"
        thumb.save_url(output["url"])
      end
      thumb.save
      #now get thumbnails for the poster
      thumb.phocode 
    end
    
    def phocodable_config
      puts "looking for config!"
      self.class.config
    end
    
    def phocodable?
      true
    end
    
    def save_url(url)
      Rails.logger.debug "We are about to download : #{url} to #{local_dir} - #{local_path}"
      FileUtils.mkdir(local_dir) if !File.exists?(local_dir)
      FileUtils.touch local_path
      writeOut = open(local_path, "wb")
      writeOut.write(open(url).read)
      writeOut.close
    end
    
    def destroy_thumbnails
      if self.class.phocoder_thumbnails.size == 0 and self.class.zencoder_videos.size == 0 
        puts "we're skipping destory_thumbnails since we don't do any processing "
        return
      end
      #puts "calling destory thumbnails for #{self.thumbnails.count} - #{self.thumbnails.size}"
      self.thumbnails.each do |thumb|
        thumb.destroy
      end
      #puts "calling destory thumbnails for #{self.thumbnails.count}"
    end
    
    def thumbnail_for(thumbnail_name)
      thumb = thumbnails.find_by_thumbnail(thumbnail_name)
      if thumb.blank? and ActsAsPhocodable.storeage_mode == "offline"
        thumb = self
      end
      thumb
      #a dirty hack for now to keep things working.  
      #Remove this!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      #Go back to just returning the thumb
      #thumb.blank? ? self : thumb
    end
    
    def get_thumbnail(thumbnail_name)
      thumbnail_for(thumbnail_name)
    end
    
    def file=(new_file)
      return if new_file.nil?
      Rails.logger.debug "we got a new file of class = #{new_file.class}"
      cleanup
      if new_file.is_a? File
        self.filename = File.basename new_file.path
        self.content_type = MIME::Types.type_for(self.filename).first.content_type
      else
        self.filename = new_file.original_filename
        self.content_type = new_file.content_type  
      end
      
      if new_file.respond_to? :tempfile
        @saved_file = new_file.tempfile
      else
        @saved_file = new_file
      end
    end
    
    #compatability method for attachment_fu
    def uploaded_data=(data)
      self.file = data
    end
    
    def save_local_file
      run_callbacks :file_saved do
        
        return if @saved_file.blank?
        FileUtils.mkdir_p local_dir
        FileUtils.cp @saved_file.path, local_path
        FileUtils.chmod 0755, local_path
        self.encodable_status = "local"
        if self.respond_to? :upload_host      
          self.upload_host = %x{hostname}.strip
        end
        @saved_file = nil
        @saved_a_new_file = true
        self.save
        if ActsAsPhocodable.storeage_mode == "s3" and ActsAsPhocodable.processing_mode == "automatic"
          self.save_s3_file
        end
        if ActsAsPhocodable.processing_mode == "automatic" and ActsAsPhocodable.storeage_mode != "offline"
          self.encode
        end
        
      end
    end
    
    def fire_ready_callback
      run_callbacks :file_ready do
      end
    end
    
    
    def cleanup
      #puts "calling cleanup!"
      destroy_thumbnails
      remove_local_file
      if ActsAsPhocodable.storeage_mode == "s3"
        remove_s3_file
      end
    end
    
    def remove_local_file
      if local_path and File.exists? local_path
        FileUtils.rm local_path
        if Dir.glob(File.join(local_dir,"*")).size == 0
          FileUtils.rmdir local_dir 
        end
      end
    end
    
    def path_id
      
      #puts "parent_id = #{parent_id}"
      #puts "parent = #{parent}"
      if respond_to?(:parent_id)
        parent_id.blank? ? id : parent.path_id
      else
        id
      end
    end
    
    def resource_dir
      File.join(self.class.table_name, path_id.to_s )
    end
    
    def thumbnail_resource_dir
      File.join(self.thumbnail_class.table_name, path_id.to_s )
    end
    
    def local_dir
      File.join(::Rails.root,'public',resource_dir)
    end
    
    def local_path
      filename.blank? ? nil : File.join(local_dir,filename)
    end
    
    def local_url
      filename.blank? ? nil : File.join("/",resource_dir,filename)
    end
    
    # This should generate a fully qualified http://something-something
    # type of a reference.  Depending on storeage_mode/base_url settings.
    def public_url
      puts "our base_url = #{base_url} and our local_url = #{local_url}"
      if ActsAsPhocodable.storeage_mode == "local" or ActsAsPhocodable.storeage_mode == "offline" 
        base_url + local_url
      else
        s3_url
      end
    end
    
    def public_filename
      public_url
    end
    
    
    def callback_url
      self.base_url + self.notification_callback_path
    end
    
    def zencoder_callback_url
      self.base_url + self.zencoder_notification_callback_path
    end
    
    def thumbnail_callback_url
      self.base_url + self.thumbnail_notification_callback_path
    end
    
    def zencoder_thumbnail_callback_url
      self.base_url + self.zencoder_thumbnail_notification_callback_path
    end
    
    def notification_callback_path
      "/phocoder/phocoder_notifications/#{self.class.name}/#{self.id}.json"
    end
  
    def zencoder_notification_callback_path
      "/phocoder/zencoder_notifications/#{self.class.name}/#{self.id}.json"
    end
      
    def thumbnail_notification_callback_path
      "/phocoder/phocoder_notifications/#{self.thumbnail_class.name}/#{self.id}.json"
    end
  
    def zencoder_thumbnail_notification_callback_path
      "/phocoder/zencoder_notifications/#{self.thumbnail_class.name}/#{self.id}.json"
    end
    
    def base_url
      self.class.base_url
    end
    
    def s3_key
      filename.blank? ? nil : File.join(resource_dir,filename)
    end
    
    def s3_url
      "http://#{s3_bucket_name}.s3.amazonaws.com/#{s3_key}"
    end
    
    def s3_bucket_name
      self.class.s3_bucket_name
    end
    
    def save_s3_file
      #I don't think we need this return check anymore.  
      #return if !@saved_a_new_file
      #@saved_a_new_file = false
      AWS::S3::S3Object.store(
                              s3_key, 
                              open(local_path), 
      s3_bucket_name,
      :access => :public_read
      )
      self.encodable_status = "s3"
      self.save
      self.encode
    end
    
    def remove_s3_file
      #if ActsAsPhocodable.storeage_mode == "s3"
        AWS::S3::S3Object.delete s3_key, s3_bucket_name
      #end
    rescue Exception => e
      #this probably means that the file never made it to S3
    end
    
    # Sanitizes a filename.
    def filename=(new_name)
      write_attribute :filename, sanitize_filename(new_name)
    end
    
    def sanitize_filename(filename)
      return unless filename
      filename.strip.tap do |name|
        # NOTE: File.basename doesn't work right with Windows paths on Unix
        # get only the filename, not the whole path
        name.gsub! /^.*(\\|\/)/, ''
        
        # Finally, replace all non alphanumeric, underscore or periods with underscore
        name.gsub! /[^A-Za-z0-9\.\-]/, '_'
      end
    end
    
    # Calculate the width for the target thumbnail atts
    def calc_width(thumbnail_atts)   
      tw = thumbnail_atts[:width].blank? ? 100000 : thumbnail_atts[:width].to_f
      th = thumbnail_atts[:height].blank? ? 100000 : thumbnail_atts[:height].to_f
      w =  width.to_f
      h =  height.to_f
      if w <= tw and h <= th
        w.round
      elsif w > h
        if (h * ( tw / w )).round < tw
          tw .round
        else
         (h * ( tw / w )).round
        end
      else
        if (w * ( th / h )).round < tw
         (w * ( th / h )).round
        else
          tw.round
        end
      end
    end #end calc_width
    
    
    def calc_height(thumbnail_atts)
      tw = thumbnail_atts[:width].blank? ? 100000 : thumbnail_atts[:width].to_f
      th = thumbnail_atts[:height].blank? ? 100000 : thumbnail_atts[:height].to_f
      w =  width.to_f
      h =  height.to_f
      if w <= tw and h <= th
        h.round
      elsif w > h
        if (h * ( tw / w )).round < th
         (h * ( tw / w )).round
        else
          th.round
        end
      else
        if (w * ( th / h )).round < tw
          th.round
        else
         (h * ( tw / w )).round
        end
      end
    end #end calc_height
    
    
    
  end#module InstanceMethods
    
end
ActiveRecord::Base.extend ActsAsPhocodable
