var Phocodable = {};

Phocodable.Updater = function(){
  this.img_selector = "img[data-phocoder]";
  this.init = function(options){
    console.log("Phocodable.Updater.init()");
    if(options == null){ options = {}; }
    this.jslib = options.jslib || "jquery";
    
  };
  
  this.select_images = function(){
    if(this.jslib == "jquery"){
      return this.select_images_jquery();
    }else if(this.jslib == "prototype"){
      return this.select_images_prototype();
    }
  }
  
  this.select_images_jquery = function(){
    return $(this.img_selector);
  };
  
  this.select_images_prototype = function(){
    return $$(this.img_selector);
  };
  
}; // Phocodable.Updater

