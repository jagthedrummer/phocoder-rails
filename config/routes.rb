Rails.application.routes.draw do 
  
  match "phocoder/phocoder_notifications/:class/:id", :to=>"phocoder#phocoder_notification_update", :via=>:post
  match "phocoder/zencoder_notifications/:class/:id", :to=>"phocoder#zencoder_notification_update", :via=>:post
  match "phocoder/thumbnail_update", :to=>"phocoder#thumbnail_update", :via=>:post
  
end