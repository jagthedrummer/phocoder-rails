class Create<%= name.classify.pluralize %> < ActiveRecord::Migration
  def self.up
    
    create_table :<%= name.pluralize %> do |t|
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
      
      t.timestamps
    end
    
    add_index :<%= name.pluralize %>, :id
    
    
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
    drop_table :<%= name.pluralize %>
    drop_table :<%= name.singularize %>_thumbnails
  end
end
