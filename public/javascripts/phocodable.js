var Phocodable = {};



Phocodable.JQueryUpdater = function(){
  _self = this;
  this.img_selector = "img[data-phocoder-waiting]";
  
  this.init = function(options){
    console.log("Phocodable.Updater.init()");
    if(options == null){ options = {}; }
    this.jslib = options.jslib || "jquery";
    setTimeout(this.update,200);
  };
  
  this.update = function(){
    params = _self.build_update_params();
    console.debug(params);
    if(params.length == 0){
      return;
    }
    $.ajax({  type: 'POST',
              url : '/phocoder/multi_thumbnail_update.json',
              dataType : 'json',
              data : { encodables : params },
              success : _self.update_response
    });
  }
  
  this.update_response = function(data, textStatus, jqXHR){
    $.each(data,function(key,value){
      $("#"+key).replaceWith(value);
    });
    setTimeout(_self.update,15000);
  }
  
  
  this.build_update_params = function(){
    params = [];
    elements = _self.select_elements();
    $.each(elements,function(index,elem){
      // Format is : Image_1_medium_db0ce8ba5d55c25eee7c767220d654fe
      // Format is : class_id_thumbnail_random
      //match = $(elem).attr("id").match(/^(.*)_(.*)_(.*)_(.*)$/)
      //hash = { 
      //  class_name : match[1],
      //  id : match[2],
      //  thumbnail : match[3],
      //  random : match[4]
      //}
      params.push( $(elem).attr("id") ); 
    });
    return params;
  }
  
  this.select_elements = function(){
    return $(this.img_selector);
  }
  
  
}; // Phocodable.JQueryUpdater





Phocodable.Updater = function(){
  _self = this;
  this.img_selector = "img[data-phocoder-waiting]";
  
  this.init = function(options){
    console.log("Phocodable.Updater.init()");
    if(options == null){ options = {}; }
    this.jslib = options.jslib || "jquery";
    setTimeout(this.update,2000);
  };
  
  this.update = function(){
    params = _self.build_update_params();
    console.debug(params);
  }
  
  this.build_update_params = function(){
    params = {};
    elements = _self.select_elements();
    
    return params;
  }
  
  this.select_elements = function(){
    if(this.jslib == "jquery"){
      return this.select_elements_jquery();
    }else if(this.jslib == "prototype"){
      return this.select_elements_prototype();
    }
  }
  
  this.select_elements_jquery = function(){
    return $(this.img_selector);
  };
  
  this.select_elements_prototype = function(){
    return $$(this.img_selector);
  };
  
}; // Phocodable.PrototypeUpdater


