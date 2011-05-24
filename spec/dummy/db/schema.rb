# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110523165522) do

  create_table "encodable_jobs", :force => true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "encodable_jobs", ["encodable_type", "encodable_id"], :name => "index_encodable_jobs_on_encodable_type_and_encodable_id"
  add_index "encodable_jobs", ["id"], :name => "index_encodable_jobs_on_id"

  create_table "image_uploads", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "phocoder_job_id"
    t.integer  "phocoder_input_id"
    t.integer  "phocoder_output_id"
    t.string   "phocoder_status"
    t.integer  "zencoder_job_id"
    t.integer  "zencoder_input_id"
    t.integer  "zencoder_output_id"
    t.string   "zencoder_status"
    t.string   "zencoder_url"
    t.integer  "duration_in_ms"
    t.integer  "width"
    t.integer  "height"
    t.integer  "file_size"
    t.string   "thumbnail"
    t.integer  "parent_id"
    t.string   "upload_host"
    t.string   "parent_type"
    t.string   "encodable_status"
  end

end
