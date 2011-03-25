class Create<%= name.classify.pluralize %> < ActiveRecord::Migration
  def self.up
    create_table :<%= name.pluralize %> do |t|
      t.string   "filename"
      t.string   "content_type"
      t.integer  "duration_in_ms"
      t.integer  "width"
      t.integer  "height"
      t.integer  "file_size"
      t.string   "thumbnail"
      t.integer  "parent_id"
      t.string   "upload_host"
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.integer  "phocoder_job_id"
      t.integer  "phocoder_input_id"
      t.integer  "phocoder_output_id"
      t.string   "phocoder_status"
      t.integer  "zencoder_job_id"
      t.integer  "zencoder_input_id"
      t.integer  "zencoder_output_id"
      t.string   "zencoder_status"
      t.string   "zencoder_url"
      
      t.timestamps
    end
    
    add_index :<%= name.pluralize %>, :id
    add_index :<%= name.pluralize %>, :parent_id
    
  end

  def self.down
    drop_table :<%= name.pluralize %>
  end
end