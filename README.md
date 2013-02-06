PhocoderRails
================================

PhocoderRails is a rails engine that makes it incredibly easy to integrate your rails app
with the [Phocoder](http://www.phocoder.com/) image processing service.

## Installing

Add this to your Gemfile:

```ruby
gem "phocoder-rails", :require => 'phocoder_rails'
```

And then run:

```term
bundle install
```

Then you need to generate a config file and a migration for tracking job status.

```term
rails g phocoder_rails:setup
create db/migrate/xxxxxxxx_create_encodable_jobs.rb
create config/phocodable.yml
```

## Base Configuration 

TBD

* Setting storage mode
* Setting processing mode (foreground / background processing)
* Other?

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

Then run

```term
rake db:migrate
```

## Updating an existing model

You can also update an existing model.  First generate a migration that will add some extra columns to your
table.  

```term
rails g phocoder_rails:model_update my_model
```

You should read the migration after it is generated to make 
sure that it makes sense within the context of your model.

Then run

```term
rake db:migrate
```

Then you should make sure that your form is set up for multi part encoding, and that you have a `file_field`
in your form named `file`.

```erb
<%= f.file_field :file %>
```

## Model Configuration

PhocoderRails allows you to easily set up your image processing in a simple declarative style.  The 
`acts_as_phocodable` method hooks phocoder-rails into your model and allows you to easily decalre multiple
thumbnails that will be generated any time a new model record is created.  Thumbnails can include cropping, 
framing, and annotations.

Here's an ImageUpload class that shows and example of how to use `acts_as_phocodable` :

```ruby
class ImageUpload < ActiveRecord::Base

  acts_as_phocodable :thumbnail_class => "ImageUploadThumbnail",
    :thumbnails => [
      {:label=>"small",  :width=>100, :height=>100, :aspect_mode => 'crop'},
      {:label=>"medium", :width=>400, :height=>400, :aspect_mode => 'preserve',
        :frame=>{ :width=>20, :bottom=>50, :color=>'003' },
        :annotations=>[
          {:text=>"Annotation Testing",:pointsize=>30,:fill_color=>'fff',:gravity=>"South",:y=>10},
          {:text=>"Howdy!",:pointsize=>10,:fill_color=>'ccc',:gravity=>"North",:y=>5}
        ]
      }
    ]

end
```

This will result in two 'thumbnail' images being created every time a new image is uploaded.  One will be 
exactly 100x100 square, and the other one will be scaled proportionally to fit inside 400x400, with a 20
pixel border on top, left, and right, and a 50 pixel border on bottom, with text annotations added on top
and on the bottom of the image.  

[Add images]


## Storage and Processing Modes
