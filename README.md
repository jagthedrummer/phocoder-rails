PhocoderRails
================================

PhocoderRails is a rails engine that makes it incredibly easy to integrate your rails app
with the [Phocoder](http://www.phocoder.com/) image processing service.

## Installing

Add this to your Gemfile:

```ruby
gem "phocoder-rails"
```

And then run:

```term
bundle install
```

Then you need to generate the config files.

```term
rails g phocoder_rails:setup
```

## Base Configuration 

TBD

## Generating a new model & scaffolding

Letting PhocoderRails generate a new model and scaffold for you is probably the easiest way to get started
and to get a feel for how Phocoder works.  

```term
rails g phocoder_rails:scaffold image_upload
create  db/migrate/20120731022844_create_image_uploads.rb
create  app/models/image_upload.rb
create  app/models/image_upload_thumbnail.rb
create  app/helpers/image_uploads_helper.rb
create  app/controllers/image_uploads_controller.rb
create  app/views/image_uploads
create  app/views/image_uploads/_form.html.erb
create  app/views/image_uploads/index.html.erb
create  app/views/image_uploads/new.html.erb
create  app/views/image_uploads/show.html.erb
 route  resources :image_uploads, :except=>[:edit,:update]
```

## Updating an existing model

First generate a migration that will add some extra columns to your table.  You should red the migration
after it is generated to make sure that it makes sense within the context of your model.

```term
rails g phocoder_rails:model_update my_model
```

Then you should make sure that your form is set up for multi part encoding, and that you have a `file_field`
in your form named `file`.

```erb
<%= f.file_field :file %>
```

## Model Configuration

PhocoderRails allows you to easily set up your image processing in a simple declarative style.

Here's an example of the ImageUpload class that would be generated with 
`rails g phocoder_rails:scaffold image_upload` :

```ruby
class ImageUpload < ActiveRecord::Base

  acts_as_phocodable :thumbnail_class => "ImageUploadThumbnail",
    :thumbnails => [
      {:label=>"small",  :width=>100, :height=>100 },
      {:label=>"medium", :width=>400, :height=>400,
        :frame=>{ :width=>20, :bottom=>50, :color=>'003' },
        :annotations=>[
                        {:text=>"Annotation Testing",:pointsize=>30,:fill_color=>'fff',:gravity=>"South",:y=>10},
                        {:text=>"Howdy!",:pointsize=>10,:fill_color=>'ccc',:gravity=>"North",:y=>5}
                      ]
      }
    ]

end
```