// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function capitalize(incomingString) {
	var letter = incomingString.substr(0,1);
	var str = incomingString.toLowerCase();
	return letter.toUpperCase() + str.substr(1);
}

// pasting multiple lines into chrome textarea will only submit the
// first line. All browsers require at least one newline at the end of
// input.
function fixTextareaNewlines() {
  $('textarea').each(function() {
    var newVal = $(this).val().replace("\n", "\r\n"); // chrome
    newVal += "\r\n"; // all browsers
    $(this).val(newVal);
  });
}

$(document).ready(function() {
  $('.controls .add').live('click', function(event) {
    var link = $(this);
    var container = link.parents('p.field');
    link.prev().show();
    var newContainer = container.clone();
    container.after(newContainer);
    newContainer.find('.slider').trigger('load');
    link.hide();
  });

  $('.controls .remove').live('click', function(event) {
    var wrapper = $(this).parents('.boxed');
    if (wrapper.find('p.field').length <= 1) {
      return;
    }
    var container = $(this).parents('p');
    console.log(container);
    container.remove();
    var removes = $('.controls .remove');
    if (removes.length == 1) {
      removes.hide();
    }
    $('.controls:last .add').show();
  });
});
