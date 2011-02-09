module ActsAsPhocodable
  
  require 'phocoder'
  
  # Storeage mode controls how uploads are handled.
  # Valid options are:
  #     offline : For development mode with no net connection.  No processing.
  #     local : To store images locally but use Phocoder for processing.
  #     s3 : Store image in S3 and use Phocoder for processing.
  # Set this options either in evnironment.rb or
  # in environments/development.rb etc...
  
  mattr_accessor :storeage_mode
  self.storeage_mode = "local"
  
  # This is used as the base address for phocoder notifications.
  # When storeage_mode == "local" this is also used to point
  # phocoder at the file.  
  # It should only be the host.domain portion of the URL
  # no path components.
  mattr_accessor :base_url
  self.base_url = "http://your-domain.com"
  
  # The config file that tells phocoder where to find
  # config options.
  mattr_accessor :config_file
  self.config_file = "config/phocodable.yml"
  
  
  
  #def self.storeage_mode
  #  @@storeage_mode
  #end
  
  
  def acts_as_phocodable(options = { })
    #has_many :reviews, :as=>:reviewable, :dependent=>:destroy
    include InstanceMethods
    attr_reader :saved_file
    after_save :save_local_file
    before_destroy :remove_local_file,:destroy_thumbnails #,:remove_s3_file
    
    
    cattr_accessor :phocoder_options
    cattr_accessor :phocoder_thumbnails
    self.phocoder_options = options
    self.phocoder_thumbnails = options[:thumbnails]
    has_many   :thumbnails, :class_name => "::#{base_class.name}",:foreign_key => "parent_id"
    belongs_to  :parent, :class_name => "::#{base_class.name}" ,:foreign_key => "parent_id"
    
    #just a writer, the reader is below
    cattr_accessor :phocodable_configuration
  end
  
  def update_from_phocoder(params)
    if !params[:output].blank?
      iu = find_by_phocoder_output_id params[:output][:id]
      img_params = params[:output]
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
    if self.phocodable_configuration[:phocoder_url]
      ::Phocoder.base_url = phocodable_configuration[:phocoder_url]
    end
    
  end
  
  def config
    return phocodable_configuration if !phocodable_configuration.blank?
    self.read_phocodable_configuration
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
        thumb = ImageUpload.new(
                                :thumbnail=>thumb_params["label"],
        :filename=>thumb_params["filename"],
        :phocoder_output_id=>thumb_params["id"],
        :phocoder_job_id=>response.body["job"]["id"],
        :parent_id=>self.id,
        :phocoder_status => "phocoding"
        )
        thumb.save
      end
    end
    
    
    def phocoder_params
      {:input => {:url => self.public_url, :notifications=>[{:url=>callback_url }] },
        :thumbnails => self.class.phocoder_thumbnails.map{|thumb|
          thumb_filename = thumb[:label] + "_" + File.basename(self.filename,File.extname(self.filename)) + ".jpg" 
          #base_url = "s3://#{s3_config[:bucket_name]}/#{self.resource_dir}/"
          thumb.merge({
            :filename=>thumb_filename,
            #:base_url=>base_url,
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
    
    
    
    def destroy_thumbnails
      self.thumbnails.each do |thumb|
        thumb.destroy
      end
    end
    
    def thumbnail_for(thumbnail_name)
      thumbnails.find_by_thumbnail(thumbnail_name)
    end
    
    def file=(new_file)
      Rails.logger.debug "we got a new file of class = #{new_file.class}"
      self.filename = new_file.original_filename
      self.content_type = new_file.content_type
      @saved_file = new_file
    end
    
    def save_local_file
      return if @saved_file.blank?
      FileUtils.mkdir_p local_dir
      FileUtils.cp @saved_file.tempfile.path, local_path
      FileUtils.chmod 0755, local_path
      self.phocoder_status = "local"
      self.upload_host = %x{hostname}.strip
      @saved_file = nil
      @saved_a_new_file = true
      self.save
    end
    
    def remove_local_file
      if local_path and File.exists? local_path
        FileUtils.rm local_path
        FileUtils.rmdir local_dir
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
      "Hmm... we need to get you a decent URL.  Thx - ActsAsPhocodable"
      end
    end
    
    def callback_url
      self.base_url + self.notification_callback_path
    end
    
    def notification_callback_path
    "/phocodable/notifications/#{self.class.name}/#{self.id}"
    end
    
    def base_url
      self.class.base_url
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