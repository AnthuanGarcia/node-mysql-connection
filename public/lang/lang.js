$.getJSON("/estilos/lang/language.json", function(json){

  if(!localStorage.getItem("lang")){
    localStorage.setItem("lang", "en");
  }

  var lang = localStorage.getItem("lang");
  var doc = json;

  $('.lang').each(function(index, element){
    $(this).text(doc[lang][$(this).attr('key')]);
  });

  $('.translate').click(function(){
    localStorage.setItem("lang", $(this).attr('id')) ;
    var lang = $(this).attr('id');
    var doc = json;
      $('.lang').each(function(index, element){
        $(this).text(doc[lang][$(this).attr('key')]);
      }); 
  });
});