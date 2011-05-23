class AddParentTypeToImageUploads < ActiveRecord::Migration
  def self.up
    add_column :image_uploads, :parent_type, :string
    add_column :image_uploads, :encodable_status, :string
  end

  def self.down
    remove_column :image_uploads, :parent_type
    remove_column :image_uploads, :encodable_status
  end
end
