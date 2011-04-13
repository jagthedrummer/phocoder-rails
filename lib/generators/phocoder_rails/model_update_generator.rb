require 'rails/generators'
require 'rails/generators/migration'
module PhocoderRails
  module Generators
        
    class ModelUpdateGenerator < Rails::Generators::NamedBase
      
      include Rails::Generators::Migration
        
      #argument :model_names, :type => :array, :default => [], :banner => "action action"
      #check_class_collision :suffix => "PhocoderRails"
 
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      
      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
    
      def create_migration_file
        migration_template 'model_update_migration.rb', "db/migrate/make_#{file_name.pluralize}_encodable.rb"
        #migration_template 'model_thumbnail_migration.rb', "db/migrate/create_#{file_name.singularize}_thumbnails.rb"
      end
      
      def create_model_file
        #template 'model.rb', File.join('app/models', class_path, "#{file_name.singularize}.rb")
        template 'model_thumbnail.rb', File.join('app/models', class_path, "#{file_name.singularize}_thumbnail.rb")
      end
      
      
    protected
 
      #def create_views_for(engine)
      #  for state in model_names do
      #    @state  = state
      #    @path   = File.join('app/cells', file_name, "#{state}.html.#{engine}")
      # 
      #    template "view.#{engine}", @path
      #  end
      #end
        
        
        
        
    end
    
  end
end 
  