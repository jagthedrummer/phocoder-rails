#dummy migration for testing.
class CreateImageUploads < ActiveRecord::Migration
  def self.up
    create_table :image_uploads, :force => true do |t|
      t.string   "filename"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "content_type"
      t.integer  "phocoder_job_id"
      t.integer  "phocoder_input_id"
      t.integer  "phocoder_output_id"
      t.integer  "width"
      t.integer  "height"
      t.integer  "file_size"
      t.string   "thumbnail"
      t.integer  "parent_id"
      t.string   "status"
      t.string   "upload_host"
    end
  end
  
  def self.down
    drop_table :image_uploads
  end
end