$(function(){
  $("input[type='text']:first", document.forms[0]).focus();

//  $("form#address_edit").submit(function(){
//    $.get(this.action, $(this).serialize(), null, "script");
//    return false;
//  });
  if($('div#flash_alert').text() != ''){
    $('div#flash_alert').css("opacity",1,0).animate({opacity: 0.5}, 2000).animate({opacity: 1.0}, 2000);
  } else if($('div#flash_notice').text() != ''){
    $('div#flash_notice').css("opacity",1,0).animate({opacity: 0.5}, 2000).animate({opacity: 1.0}, 2000);
  }
//$('div#contents').before('<div id="flash_alert"><%= escape_javascript(flash.delete(:alert)) %></div><div class="clear"></div>');
});

function add_fields(link,content){
  no = ($("form p").length/2-1)
  $(link).before(content.replace("address_99","address_"+no).replace("address_99","address_"+no).replace("address[99]","address["+no+"]").replace("100",no+1))
}
