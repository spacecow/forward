$(function(){
  $("input[type='text']:first", document.forms[0]).focus();

  //$("input#add").remove()
});

function add_fields(link,content){
  $(link).before(content)
}
