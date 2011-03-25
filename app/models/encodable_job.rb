class EncodableJob < ActiveRecord::Base
  
  belongs_to :encodable, :polymorphic=>true
  
end