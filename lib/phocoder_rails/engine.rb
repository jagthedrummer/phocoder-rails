module PhocoderRails
  class Engine < Rails::Engine
    
    config.acts_as_phocodable = ActiveSupport::OrderedOptions.new
    
    initializer "mongo_fifo.configure_mongodb_connection" do |app|
      
      if !config.acts_as_phocodable.storage_mode.blank?
        ActsAsPhocodable.storeage_mode = config.acts_as_phocodable.storage_mode
      end
    
    end
    
    
  end
end