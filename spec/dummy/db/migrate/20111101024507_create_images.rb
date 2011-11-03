class CreateImages < ActiveRecord::Migration
  def self.up
    
    create_table :images do |t|
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
    
    add_index :images, :id
    
    
    create_table :image_thumbnails do |t|
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
    
    add_index :image_thumbnails, :id
    add_index :image_thumbnails, :parent_id
    
  end

  def self.down
    drop_table :images
    drop_table :image_thumbnails
  end
end
