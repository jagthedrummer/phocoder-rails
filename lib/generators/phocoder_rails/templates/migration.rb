class CreateEncodableJobs < ActiveRecord::Migration
  def self.up
    create_table :encodable_jobs do |t|
      t.string   "encodable_type"
      t.integer  "encodable_id"
      t.integer  "phocoder_job_id"
      t.integer  "phocoder_input_id"
      t.integer  "phocoder_output_id"
      t.string   "phocoder_status"
      t.integer  "zencoder_job_id"
      t.integer  "zencoder_input_id"
      t.integer  "zencoder_output_id"
      t.string   "zencoder_status"
      t.string   "zencoder_url"
      t.string   "tracking_mode"
      t.integer  "user_id"
      t.timestamps
    end
    add_index :encodable_jobs, [:encodable_type, :encodable_id]
    add_index :encodable_jobs, :id
  end

  def self.down
    drop_table :encodable_jobs
  end
end
