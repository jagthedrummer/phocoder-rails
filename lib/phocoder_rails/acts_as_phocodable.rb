module ActsAsPhocodable
  
  
  
  # To work in offline mode you might put
  # a line like this in an initializer
  # ActsAsPhocodable.offline_mode = true
  mattr_writer :offline_mode
  self.offline_mode = false
  def self.offline_mode
    @@offline_mode
  end
  
  
  def acts_as_phocodable(options = { })
    #has_many :reviews, :as=>:reviewable, :dependent=>:destroy
    include InstanceMethods
    attr_reader :saved_file
    after_save :save_local_file
    before_destroy :remove_local_file#,:destroy_thumbnails,:remove_s3_file
    
    cattr_accessor :phocoder_options
    cattr_accessor :phocoder_thumbnails
    self.phocoder_options = options
    self.phocoder_thumbnails = options[:thumbnails]
    has_many   :thumbnails, :class_name => self
    belongs_to  :parent, :class_name => self
  end
  
  
  def thumbnail_attributes_for(thumbnail = "small")
    atts = self.phocoder_thumbnails.select{|atts| atts[:label] == thumbnail }
    atts.first
  end
  
  
  module InstanceMethods
  
    def phocodable?
      true
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
