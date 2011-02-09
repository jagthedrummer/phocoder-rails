Rails.application.routes.draw do |map|
  
  match "phocoder/notifications/:class/:id", :to=>"phocoder#notification_update", :via=>:post
  match "phocoder/thumbnail_update", :to=>"phocoder#thumbnail_update", :via=>:post
  
end