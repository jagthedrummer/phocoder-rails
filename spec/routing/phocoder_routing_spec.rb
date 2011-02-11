require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Phocoder Routes" do


  it "should accept a post to /phocoder" do
    { :post => '/phocoder/notifications/ImageUpload/1' }.should route_to(:controller => "phocoder", :action => "notification_update",:class=>"ImageUpload",:id=>"1")
  end
  
  it "should accept a post to /phocoder" do
    { :post => '/phocoder/zencoder_notifications/ImageUpload/1' }.should route_to(:controller => "phocoder", :action => "zencoder_notification_update",:class=>"ImageUpload",:id=>"1")
  end
        
  it "should accept a post to /thumbnail_update" do
    { :post => '/phocoder/thumbnail_update' }.should route_to(:controller => "phocoder", :action => "thumbnail_update")
  end
  
  
end