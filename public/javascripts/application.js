$(function(){
  $("input[type='text']:first", document.forms[0]).focus();

  $("input#add").remove()
  $("a#add_address_field").css("visibility", "visible")
});

function add_fields(link,content){
  no = ($("form p").length/2-1)
  $(link).before(content.replace("address_99","address_"+no).replace("address_99","address_"+no).replace("address[99]","address["+no+"]").replace("100",no+1))
}
