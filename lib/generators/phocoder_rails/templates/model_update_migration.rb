class Make<%= name.classify.pluralize %>Encodable < ActiveRecord::Migration
  def self.up
    
    
    add_column :<%= name.pluralize %>, :filename, :string
    add_column :<%= name.pluralize %>, :content_type, :string
    add_column :<%= name.pluralize %>, :duration_in_ms, :integer
    add_column :<%= name.pluralize %>, :width, :integer
    add_column :<%= name.pluralize %>, :height, :integer
    add_column :<%= name.pluralize %>, :file_size, :integer
    add_column :<%= name.pluralize %>, :upload_host, :string
    add_column :<%= name.pluralize %>, :taken_at, :datetime
    add_column :<%= name.pluralize %>, :lat, :float
    add_column :<%= name.pluralize %>, :lng, :float
    add_column :<%= name.pluralize %>, :encodable_status, :string
      
    
    
    create_table :<%= name.singularize %>_thumbnails do |t|
      t.string   "filename"
      t.string   "content_type"
      t.integer  "duration_in_ms"
      t.integer  "width"
      t.integer  "height"
      t.integer  "file_size"
      t.string   "upload_host"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "taken_at"
      t.float    "lat"
      t.float    "lng"
      t.string   "encodable_status"
      
      t.string   "thumbnail"
      t.integer  "parent_id"
      t.string   "parent_type"
      
      t.timestamps
    end
    
    add_index :<%= name.singularize %>_thumbnails, :id
    add_index :<%= name.singularize %>_thumbnails, :parent_id
    
  end

  def self.down
    
    remove_column :<%= name.pluralize %>, :filename
    remove_column :<%= name.pluralize %>, :content_type
    remove_column :<%= name.pluralize %>, :duration_in_ms
    remove_column :<%= name.pluralize %>, :width
    remove_column :<%= name.pluralize %>, :height
    remove_column :<%= name.pluralize %>, :file_size
    remove_column :<%= name.pluralize %>, :upload_host
    remove_column :<%= name.pluralize %>, :created_at
    remove_column :<%= name.pluralize %>, :updated_at
    remove_column :<%= name.pluralize %>, :taken_at
    remove_column :<%= name.pluralize %>, :lat
    remove_column :<%= name.pluralize %>, :lng
    remove_column :<%= name.pluralize %>, :encodable_status
    
    drop_table :<%= name.singularize %>_thumbnails
  end
end