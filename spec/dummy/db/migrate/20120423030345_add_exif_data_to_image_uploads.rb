class AddExifDataToImageUploads < ActiveRecord::Migration
  def self.up
    add_column :image_uploads, :bits_per_pixel, :integer
    add_column :image_uploads, :camera_make, :string
    add_column :image_uploads, :camera_model, :string
    add_column :image_uploads, :orientation, :integer
    add_column :image_uploads, :exposure_time, :string
    add_column :image_uploads, :f_number, :string
    add_column :image_uploads, :iso_speed_rating, :string
    add_column :image_uploads, :exposure_bias_value, :string
    add_column :image_uploads, :focal_length, :string
    add_column :image_uploads, :focal_length_in_35mm_film, :string
    add_column :image_uploads, :subsec_time, :integer
  end

  def self.down
    remove_column :image_uploads, :subsec_time
    remove_column :image_uploads, :focal_length_in_35mm_film
    remove_column :image_uploads, :focal_length
    remove_column :image_uploads, :exposure_bias_value
    remove_column :image_uploads, :iso_speed_rating
    remove_column :image_uploads, :f_number
    remove_column :image_uploads, :exposure_time
    remove_column :image_uploads, :orientation
    remove_column :image_uploads, :camera_model
    remove_column :image_uploads, :camera_make
    remove_column :image_uploads, :bits_per_pixel
  end
end
