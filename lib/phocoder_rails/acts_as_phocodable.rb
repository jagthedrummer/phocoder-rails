module ActsAsPhocodable
  
  require 'phocoder'
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
  self.s3_access_key_id = "your-bucket"
  
  # The secret_access_key for storing s3 files
  mattr_accessor :s3_secret_access_key
  self.s3_secret_access_key = "your-bucket"
  
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
      'image/x-citrix-pjpeg'
  ]
  
  # The list of content types that will trigger video handling.
  mattr_accessor :video_types
  self.video_types = [
   'application/x-flash-video',
   'video/avi',
   'video/mp4',
   'video/ogg',
   'video/quicktime',
   'video/vnd.objectvideo'
  ]
  
  #def self.storeage_mode
  #  @@storeage_mode
  #end
  
  
  def acts_as_phocodable(options = { })
    #has_many :reviews, :as=>:reviewable, :dependent=>:destroy
    include InstanceMethods
    attr_reader :saved_file
    after_save :save_local_file
    before_destroy :remove_local_file,:destroy_thumbnails,:remove_s3_file
    
    
    #cattr_accessor :phocoder_options
    #self.phocoder_options = options
    
    cattr_accessor :phocoder_thumbnails
    self.phocoder_thumbnails = options[:thumbnails]
    
    cattr_accessor :zencoder_videos
    self.zencoder_videos = options[:videos]
    
    has_many   :thumbnails, :class_name => "::#{base_class.name}",:foreign_key => "parent_id"
    belongs_to  :parent, :class_name => "::#{base_class.name}" ,:foreign_key => "parent_id"
    
    scope :top_level, where({:parent_id=>nil})
    
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
    Rails.logger.debug "tying to call update from phocoder for params = #{params}"
    if !params[:output].blank?
      iu = find_by_phocoder_output_id params[:output][:id]
      img_params = params[:output]
      iu.filename = File.basename(params[:output][:url]) if iu.filename.blank?
      if ActsAsPhocodable.storeage_mode == "local"
        iu.save_url(params[:output][:url])
      end
    else
      iu = find_by_phocoder_input_id params[:input][:id]
      img_params = params[:input]
    end
    iu.file_size = img_params[:file_size]
    iu.width = img_params[:width]
    iu.height = img_params[:height]
    iu.phocoder_status = "ready"
    iu.save
    iu
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
    if self.phocodable_configuration[:phocoder_url]
      ::Phocoder.base_url = phocodable_configuration[:phocoder_url]
    end
    if self.phocodable_configuration[:phocoder_api_key]
      ::Phocoder.api_key = phocodable_configuration[:pocoder_api_key]
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
    
    def phocode
      #if self.thumbnails.count >= self.class.phocoder_thumbnails.size
      #  raise "This item already has thumbnails!"
      #  return
      #end
      
      return if @phocoding
      @phocoding = true
      
      Rails.logger.debug "trying to phocode for #{Phocoder.base_url}"
      Rails.logger.debug "callback url = #{callback_url}"
      response = Phocoder::Job.create(phocoder_params)
      self.phocoder_input_id = response.body["job"]["inputs"].first["id"]
      self.phocoder_job_id = response.body["job"]["id"]
      self.phocoder_status = "phocoding"
      self.save #false need to do save(false) here if we're calling phocode on after_save
      response.body["job"]["thumbnails"].each do |thumb_params|
        puts "creating a thumb for #{thumb_params["label"]}"
        thumb = self.thumbnails.new(
        :thumbnail=>thumb_params["label"],
        :filename=>thumb_params["filename"],
        :phocoder_output_id=>thumb_params["id"],
        :phocoder_job_id=>response.body["job"]["id"],
        :parent_id=>self.id,
        :phocoder_status => "phocoding"
        )
        thumb.save
	puts "    thumb.errors = #{thumb.errors.to_json}"
      end
    end
    
    
    def phocoder_params
      {:input => {:url => self.public_url, :notifications=>[{:url=>callback_url }] },
        :thumbnails => self.class.phocoder_thumbnails.map{|thumb|
          thumb_filename = thumb[:label] + "_" + File.basename(self.filename,File.extname(self.filename)) + ".jpg" 
          base_url = ActsAsPhocodable.storeage_mode == "s3" ? "s3://#{self.s3_bucket_name}/#{self.resource_dir}/" : ""
          thumb.merge({
            :filename=>thumb_filename,
            :base_url=>base_url,
            :notifications=>[{:url=>callback_url }]
          })
        }
      }
    end
    
    def phocodable_config
      puts "looking for config!"
      self.class.config
    end
    
    def phocodable?
      true
    end
    
    def save_url(url)
      FileUtils.mkdir(local_dir) if !File.exists?(local_dir)
      FileUtils.touch local_path
      writeOut = open(local_path, "wb")
      writeOut.write(open(url).read)
      writeOut.close
    end
    
    def destroy_thumbnails
      self.thumbnails.each do |thumb|
        thumb.destroy
      end
    end
    
    def thumbnail_for(thumbnail_name)
      thumbnails.find_by_thumbnail(thumbnail_name)
    end

    def get_thumbnail(thumbnail_name)
    	thumbnail_for(thumbnail_name)
    end
    
    def file=(new_file)
      return if new_file.nil?
      Rails.logger.debug "we got a new file of class = #{new_file.class}"
      self.filename = new_file.original_filename
      self.content_type = new_file.content_type
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
      return if @saved_file.blank?
      FileUtils.mkdir_p local_dir
      FileUtils.cp @saved_file.path, local_path
      FileUtils.chmod 0755, local_path
      self.phocoder_status = "local"
      if self.respond_to? :upload_host      
	self.upload_host = %x{hostname}.strip
      end
      @saved_file = nil
      @saved_a_new_file = true
      self.save
      if ActsAsPhocodable.storeage_mode == "s3" and ActsAsPhocodable.processing_mode == "automatic"
        self.save_s3_file
      end
      if ActsAsPhocodable.processing_mode == "automatic"
        self.phocode
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
    
    def resource_dir
      File.join(self.class.name, parent_id.blank? ? id.to_s : parent_id.to_s )
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
      if ActsAsPhocodable.storeage_mode == "local" or ActsAsPhocodable.storeage_mode == "offline" 
        ActsAsPhocodable.base_url + local_url
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
    
    def notification_callback_path
    "/phocoder/notifications/#{self.class.name}/#{self.id}.json"
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
      #this is a dirty hack to see what happens when we add save_s3_file and phocode to the after_save routine
      return if !@saved_a_new_file
      @saved_a_new_file = false
      AWS::S3::S3Object.store(
        s3_key, 
        open(local_path), 
        s3_bucket_name,
        :access => :public_read
      )
      self.phocoder_status = "s3"
      self.save
      self.phocode
    end
    
    def remove_s3_file
      if ActsAsPhocodable.storeage_mode == "s3"
        AWS::S3::S3Object.delete s3_key, s3_bucket_name
      end
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
    
    
    end#module InstanceMethods
    
  end
  ActiveRecord::Base.extend ActsAsPhocodable
