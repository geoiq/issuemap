$(document).ready(function() {
  $(".preprocess-form").preprocessData();
});

// Automatically and immediately upload either a selected file or the
// copy-n-pasted data for a map.  Afterwards, populate the rest of map creation
// form with guessed defaults based on the ajax response.
$.fn.preprocessData = function() {
  return this.each(function() {
    console.log("initializing form");
    var form = $(this);
    form[0].reset();

    var submitForm = function(callback) {
      form.ajaxSubmit({
        beforeSubmit: function(a,f,o) {
          o.dataType = 'json';
        },
        complete: function(request, textStatus) {
          var json = request.responseText;
          if (textStatus == "success") {
            console.log("SUCCESS!");
            console.log(json);
          } else {
            console.log("ERROR!");
            console.log(json);
          }
          if (callback) callback();
        }
      });
    };

    var fileInput = form.find("input[type=file]");
    var pasteArea = form.find("textarea");

    fileInput.change(function() {
      submitForm(function() { form[0].reset(); });
    });

    pasteArea.valueChangeObserver(500, function() {
      if (pasteArea.val().indexOf("\n") >= 0) { // multiple lines pasted
        submitForm();
      }
    });
  });
};

// Monitors a field for value changes every interval and fires the callback
// function only when a change is recognized.  This is good for monitoring an
// input or textarea field for copy-n-pasted changes that could come from
// keypresses, mouse context menus, or application menus.
$.fn.valueChangeObserver = function(interval, callback) {
  return this.each(function() {
    var self = $(this);
    var lastValue = self.val();
    var check = function() {
      var value = self.val();
      if (value != lastValue) {
        callback(self);
        lastValue = value;
      }
    };
    setInterval(check, interval);
  });
};

// protection against accidental left-over console.log statements
if (typeof console === "undefined") {
  console = { log: function() { } };
}

// ----------------------

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

