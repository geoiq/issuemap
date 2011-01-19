$(document).ready(function() {
  $(".preprocess-form").preprocessData(MapFormUpload.init());
  $("fieldset.location, fieldset.data, fieldset.title").sniffForCompleted();
  $("fieldset.location, fieldset.data").sniffForSubmittable(".actions button[type=submit]");
});

var MapFormUpload = {
  init: function() {
    var dataColumn = $("#map_data_column_name");
    var locationColumn = $("#map_location_column_name");
    $("#map_title").suggestable();
    var suggestTitle = function () {
      var title = [dataColumn.val() || "Data", locationColumn.val() || "Location"].join(" by ");
      $("#map_title").suggestValue(title);
    };
    dataColumn.change(suggestTitle);
    locationColumn.change(suggestTitle);
    return this;
  },
  success: function(data) {
    console.log("SUCCESS!");
    console.log(data.column_names);
    console.log(data);

    var importSection = $(".import");
    var postSection = $(".post-process");
    importSection.markCompleted(true);
    postSection.slideDown();
    $("select.column-names").setOptions(data.column_names);
    $("#map_location_column_name").val(data.guessed_location_column).change();
    $("#map_data_column_name").val(data.guessed_data_column).change();
    $("#map_location_column_type").val(null).change();
    $("#map_data_column_type").val(null).change();
  },
  error: function(data) {
    console.log("ERROR!");
    console.log(data.error);

    var importSection = $(".import");
    var postSection = $(".post-process");
    importSection.markCompleted(false);
    postSection.slideUp();
    $("select.column-names").setOptions([]);
    $("#map_location_column_name").val(null);
    $("#map_data_column_name").val(null);
    $("#map_location_column_type").val(null);
    $("#map_data_column_type").val(null);
  }
};

// Automatically and immediately upload either a selected file or the
// copy-n-pasted data for a map.  Afterwards, populate the rest of map creation
// form with guessed defaults based on the ajax response.
$.fn.preprocessData = function(options) {
  options = options || {};
  return this.each(function() {
    var form = $(this);
    form[0].reset();

    var submitForm = function(callback) {
      form.ajaxSubmit({
        beforeSubmit: function(a,f,o) {
          o.dataType = 'json';
        },
        complete: function(request, textStatus) {
          var data = $.parseJSON(request.responseText);
          if (data.error) {
            if (options.error) options.error(data);
          } else {
            if (options.success) options.success(data);
          }
          if (callback) callback(data);
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

$.fn.sniffForCompleted = function() {
  return this.each(function() {
    var fieldset = $(this);
    var inputs = fieldset.find(":input");
    inputs.change(function() { 
      var allFilled = _.all(inputs, function(input) { return $(input).val() && !$(input).hasClass("suggested"); });
      fieldset.markCompleted(allFilled);
    }).change();
  });
};

$.fn.sniffForSubmittable = function(submit) {
  var inputs = this.find(":input");
  inputs.change(function() { 
    var allFilled = _.all(inputs, function(input) { return $(input).val(); });
    if (allFilled) {
      $(submit).removeAttr("disabled"); 
    } else {
      $(submit).attr("disabled", "disabled"); 
    }
  }).change();
  return this;
};

$.fn.markCompleted = function(on) {
  if (on) this.addClass("completed"); 
  else    this.removeClass("completed"); 
};

$.fn.setOptions = function(names) {
  return this.each(function() {
    var select = $(this);
    select.empty();
    _.each(names, function(name) {
      select.append($("<option />").val(name).text(name));
    });
  });
};

$.fn.suggestable = function() {
  this.focus(function() { $(this).removeClass("suggested"); })
      .blur(function() { $(this).change(); });
};

$.fn.suggestValue = function(text) {
  return this.each(function() {
    var input = $(this);  
    if (input.hasClass("suggested") || input.val() == input.attr("data-suggested") || input.val().length == 0) {
      input.val(text);
      input.addClass("suggested");
    }
    input.attr("data-suggested", text);
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

