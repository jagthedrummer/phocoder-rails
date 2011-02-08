require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhocoderHelper do
    
  it "should return a preview_reload_timeout" do
    preview_reload_timeout.should == 1000
  end
  
end
