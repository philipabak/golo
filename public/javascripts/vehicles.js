replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}

  var skipUpdate = false;
var removeCarForms = false;

function yearUpdated() {
  if(skipUpdate) return;

  // complicated b/c form errors can introduce div-s
  var makeElement = $(this).closest(".vehicle").find('.make_select').attr("disabled", "")[0];
  var modelElement = $(this).closest(".vehicle").find('.model_select').attr("disabled", "")[0];

    
  $.getJSON("/users/get_makes",
			{year_id:$(this)[0].options[$(this)[0].selectedIndex].value}, 
			function(data) {
			  $(makeElement).empty().removeAttr("disabled");
			  $(modelElement).empty();
              
			  var optn = document.createElement("OPTION");
			  optn.value = null;
			  optn.text = 'Choose a make';
			  makeElement.options.add(optn);
			  
			  for (var option in data) {
				var optn = document.createElement("OPTION");
				optn.value = data[option]['value'];
				optn.text = data[option]['text'];
				makeElement.options.add(optn);
			  };
			});

  makeElement.disabled = false;
  $(this).closest(".vehicle").find('.model_select').attr('disabled', 'true');
}

function makeUpdated() {
  if(skipUpdate) return;
  
  // complicated b/c form errors can introduce div-s
  var modelElement = $(this).closest(".vehicle").find('.model_select').attr("disabled", "")[0];
  
  var yearElement = $(this).closest(".vehicle").find('.year_select')[0];
  var year_id = yearElement.options[yearElement.selectedIndex].value;
  
  var makeElement = $(this)[0];
  var make_id = makeElement.options[makeElement.selectedIndex].value;
  
  $.getJSON("/users/get_models",
			{make_id:make_id,year_id:year_id}, 
			function(data) {
			  var optn = document.createElement("OPTION");
			  optn.value = null;
			  optn.text = 'Choose a model';
			  $(modelElement).empty().removeAttr("disabled");
			  modelElement.options.add(optn);
              
			  for (var option in data) {
				var optn = document.createElement("OPTION");
				optn.value = data[option]['value'];
				optn.text = data[option]['text'];
				modelElement.options.add(optn);
			  };
			});
  
  modelElement.disabled = false;
}

function removeCar()
{
    var target = $(this)[0].href.replace(/.*#/, '.');
	if (removeCarForms) {
	  $(this).parents(target).remove();
	} else {
	  $(this).parents(target).hide();
	  var hidden_input = $(this).prevAll("input[type=hidden]");
	  if (hidden_input.get());
	    hidden_input.val('1');
	}
}

function addNestedItem() {
    var template = eval($(this)[0].href.replace(/.*#/, ''));
    var target = $('#' + $(this)[0].rel);
    var new_content = $(replace_ids(template));
    target.append(new_content);
    
    // after cloning, trigger the 'change' so the year refreshes.. but we
    setTimeout(function() {
                   new_content.find('.year_select').trigger('change');                                                      
               }, 100);
}

$(document).ready(
    function(){
	  $('.form_error_main').css("opacity", "0.0");
	  $('.form_error_main').animate({
		opacity: 1.0
			}, "slow");
	  $('.form_error').css("opacity", "0.0");
	  $('.form_error').animate({
		opacity: 1.0
			}, "slow");

	  $('.remove').live('click', removeCar); 
      
	  $('.add_nested_item').live('click', addNestedItem);
	  $('.make_select').livequery('change', makeUpdated);
	  $('.year_select').livequery('change', yearUpdated).trigger('change');
	  
      
      
	  $('#user_password').blur(function(){
		  if ($(this).val() && $(this).val().length < 6)
			$('#user_password_warning').show();
		  else
			$('#user_password_warning').hide();
		});
	  
	  $('#user_password_confirmation').blur(function(){
		  if ($('#user_password').val() && $(this).val() && $(this).val() != $('#user_password').val())
			$('#user_password_confirmation_warning').show();
		  else
			$('#user_password_confirmation_warning').hide();
		});
    });

// hack needed so livequery doesn't update the page on load...
$(window).load(function() {
	skipUpdate = false;
  });
