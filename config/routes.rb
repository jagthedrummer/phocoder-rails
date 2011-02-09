Rails.application.routes.draw do |map|
  
  match "phocoder/phocoder_update/:class/:id", :to=>"phocoder#phocoder_update", :via=>:post
  match "phocoder/thumbnail_update", :to=>"phocoder#thumbnail_update", :via=>:post
  
end