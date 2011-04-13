require 'rails/generators'
require 'rails/generators/migration'
module PhocoderRails
  module Generators
        
    class ScaffoldGenerator < Rails::Generators::NamedBase
      
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
        migration_template 'model_migration.rb', "db/migrate/create_#{file_name.pluralize}.rb"
        #migration_template 'model_thumbnail_migration.rb', "db/migrate/create_#{file_name.singularize}_thumbnails.rb"
      end
      
      def create_model_file
        template 'model.rb', File.join('app/models', class_path, "#{file_name.singularize}.rb")
        template 'model_thumbnail.rb', File.join('app/models', class_path, "#{file_name.singularize}_thumbnail.rb")
      end
      
      def create_helper_file
        template 'helper.rb', File.join('app/helpers', class_path, "#{file_name.pluralize}_helper.rb")
      end
      
      def create_controller_file
        template 'controller.rb', File.join('app/controllers', class_path, "#{file_name.pluralize}_controller.rb")
      end
      
      def create_views
        directory 'views', File.join('app/views', class_path,  "#{file_name.pluralize}" )
        #["_form.html.erb","index.html.erb","new.html.erb","show.html.erb"].each do |view| 
        #  template "views/#{view}", File.join('app/views', class_path, "#{file_name.pluralize}", view )
        #end
      end
      
      def create_route
        route("resources :#{file_name.pluralize}, :except=>[:edit,:update]")
      end
      
      #class_option :view_engine, :type => :string, :aliases => "-t", :desc => "Template engine for the views. Available options are 'erb' and 'haml'.", :default => "erb"
      #class_option :haml, :type => :boolean, :default => false
 
      def do_a_thing
        puts "We are doing a thing!!!!!!!!!!!!!!!! #{file_name}"
      end
 
      #def create_cell_file
      #  template 'cell.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
      #end
 
      #def create_views
      #  if options[:view_engine].to_s == "haml" or options[:haml]
      #    create_views_for(:haml)
      #  else
      #    create_views_for(:erb)
      #  end
      #end
 
      #def create_test
      #  @states = model_names
      #  template 'cell_test.rb', File.join('test/cells/', "#{file_name}_cell_test.rb")
      #end
 
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
  