$(document).ready(function() {
  $(".preprocess-form").preprocessData(MapFormUpload.init());
  $("fieldset.required").sniffForCompletion();
  $("fieldset.required").sniffForSubmittable(".actions button[type=submit]");
  $("#pointer").stepAlongFieldsets();
  $("#maps.show .controls button").manageControls("#maps.show .controls");
  $("textarea.copyable").copyable();
});

$(window).unload(function() {
  if (typeof $.unblockUI != "undefined" && $.unblockUI !== null) {
    $.unblockUI();
  }
});

var MapFormUpload = {
  init: function() {
    this.automateTitleGuessing();
    this.displayColumnSamples();
    this.pleaseWaitOnSubmit();
    this.wireUndoImport();
    return this;
  },
  success: function(data) {
    console.log(data);

    var importSection = $(".import");
    var postSection = $(".post-process");
    
    importSection.removeClass("errored");
    importSection.find(".error-message").text(null);
    importSection.markCompleted(true, false, false);
    postSection.slideDown(function() { importSection.trigger("form-state-changed"); });
    $("select.column-names").setColumnOptions(data.column_names, data.column_details);
    $("#map_original_csv_data").val(data.csv).change();
    $("#map_location_column_name").val(data.guessed_location_column).change();
    $("#map_data_column_name").val(data.guessed_data_column).change();
    $("#map_location_column_type").val(null).change();
    $("#map_data_column_type").val(null).change();
  },
  error: function(data) {
    console.log("ERROR!");
    console.log(data);

    var importSection = $(".import");
    var postSection = $(".post-process");
    importSection.find(".error-message").text(data.error);
    this.reset(true, false);
  },
  reset: function(errored, clearIt) {
    var importSection = $(".import");
    var postSection = $(".post-process");
    importSection.toggleClass("errored", errored);
    postSection.slideUp();
    importSection.markCompleted(false, true, true);
    if (!errored) { $("#maps.form fieldset").removeClass("errored"); }
    $("select.column-names").setColumnOptions([]);
    $("#map_original_csv_data").val(null);
    $("#map_location_column_name").val(null);
    $("#map_data_column_name").val(null);
    $("#map_location_column_type").val(null);
    $("#map_data_column_type").val(null);
    if (clearIt) $("form.preprocess-form").each(function() { this.reset(); });
  },
  automateTitleGuessing: function() {
    var dataColumn = $("#map_data_column_name");
    var locationColumn = $("#map_location_column_name");
    $("#map_title").suggestable();
    var suggestTitle = function () {
      var title = [dataColumn.val() || "Data", locationColumn.val() || "Location"].join(" by ");
      $("#map_title").suggestValue(title);
    };
    dataColumn.change(suggestTitle);
    locationColumn.change(suggestTitle);
  },
  displayColumnSamples: function() {
    $("select.column-names").change(function () {
      var samples = $(this).find(":selected").attr("data-samples") + ", ...";
      $(this).parents("fieldset").find(".hint").text(samples);
    });
  },
  pleaseWaitOnSubmit: function() {
    $("form#new_map").pleaseWaitOnSubmit();
  },
  wireUndoImport: function() {
    var self = this;
    $("fieldset.import a.undo").click(function(event) {
      event.preventDefault();
      self.reset(false, true);
    });
  }
};

$.fn.stepAlongFieldsets = function() {
  return this.pointer("fieldset[data-step]", ":not(.completed):first", "completed");
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

    pasteArea.valueChangeObserver(500, function(input) {
      if (input.val().length > 0) submitForm();
    });
  });
};

$.fn.sniffForCompletion = function() {
  return this.each(function() {
    var fieldset = $(this);
    var inputs = fieldset.find(":input.required");
    inputs.change(function() { 
      var allFilled = _.all(inputs, function(input) { return $(input).val() && !$(input).hasClass("suggested"); });
      fieldset.markCompleted(allFilled, true, false);
    }).change();
  });
};

$.fn.sniffForSubmittable = function(submit) {
  var inputs = this.find(":input.required");
  inputs.change(function() { 
    var allFilled = _.all(inputs, function(input) { return $(input).val(); });
    if (allFilled) {
      $(submit).removeAttr("disabled"); 
    } else {
      $(submit).attr("disabled", true); 
    }
  }).change();
  return this;
};

$.fn.markCompleted = function(on, triggerFormStateChange, forceFormStateChange) {
  var hadClass = this.hasClass("completed");
  on = !!on;                           // forcing a boolean
  if (on) { this.removeClass("errored"); }
  this.toggleClass("completed", on); 
  var xor = hadClass ? !on : on;       // logical XOR
  if (forceFormStateChange || (xor && triggerFormStateChange)) { 
    this.trigger("form-state-changed"); 
  }
  return this;
};

$.fn.suggestable = function() {
  this.focus(function() { $(this).removeClass("suggested"); })
      .blur(function() { $(this).change(); }); // triggers possible "completion" upon acceptance of suggested value
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

$.fn.setColumnOptions = function(names, details) {
  return this.each(function() {
    var select = $(this);
    select.empty();
    _.each(names, function(name) {
      var samples = details[name].samples.join(", ");
      select.append(
        $("<option />")
          .val(name).html(name)
          .attr("data-samples", samples)
          .attr("data-guessed_type", details[name].guessed_type));
    });
  });
};

$.fn.pleaseWaitOnSubmit = function() {
  this.submit(function () { 
    $.blockUI({ 
      css: { 
        border: "none", 
        padding: "0.5em", 
        backgroundColor: "#000", 
        "-webkit-border-radius": "0.5em", 
        "-moz-border-radius": "0.5em", 
        opacity: 0.75, 
        color: "#fff",
        "font-size": "2em",
        "line-height": "1.5"
      }
     }); 
  });
};

$.fn.manageControls = function(controlsSelector) {
  return this.each(function() {
    var button = $(this);
    button.click(function() {
      var wasOn = button.parent().hasClass("active");
      $(controlsSelector).find(".control").hide();
      $(controlsSelector).find(".button-wrapper").removeClass("active");
      if (!wasOn) {
        button.parent().addClass("active");
        $(button.attr("rel")).show().trigger("control-displayed");
      }
    });
  });
};

$.fn.copyable = function() {
  return this.attr("readonly", true)
    .click(function() { this.select(); })
    .focus(function() { this.select(); });
};

$.fn.pointer = function(selector, qualifier, eventType) {
  var stepDuration = 500;
  var pointerMethods = {
    positionFor: function(element) {
      var pointerWidth    = this.outerWidth();
      var pointerHeight   = this.outerHeight();
      var pointerOverlay  = parseInt(this.attr("data-overlay"));
      var elementWidth    = element.outerWidth();
      var elementHeight   = element.outerHeight();
      var elementPosition = element.position();
  
      return {
        top: elementPosition.top + (elementHeight / 2) - (pointerHeight / 2),
        left: elementPosition.left - pointerWidth + pointerOverlay
      };
    },
    jumpTo: function(element) {
      if (element.size() == 0) { return this.fadeOut(stepDuration); }
      this.css(this.positionFor(element));
      this.find("div").text(element.attr("data-step"));
      return this.fadeIn(stepDuration);
    },
    animateTo: function(element) {
      if (element.size() == 0) { return this.fadeOut(stepDuration); }
      this.show();
      var stepText = this.find("div");
      stepText.fadeOut(stepDuration / 2, function() {
        stepText.text(element.attr("data-step"));
        stepText.fadeIn(stepDuration / 2);
      });
      return this.animate(this.positionFor(element), stepDuration);
    },
    moveTo: function(element) {
      console.log("moveTo"); console.log(element);
      if (this.is(":visible")) {
        return this.animateTo(element);
      } else {
        if (element.size() == 0) { return this; }
        return this.jumpTo(element);
      }
    }
  };
  return this.each(function() {
    var pointer = $.extend($(this), pointerMethods);
    var move = function () { pointer.moveTo($(selector + qualifier)); };
    $(selector).bind("form-state-changed", move);
    $(window).delayedResize(function() { pointer.stop(); move(); });
    move();
  });
};

$.fn.delayedResize = function(callback) {
  var t;
  return this.resize(function() { 
    if (t) { clearTimeout(t); }
    t = setTimeout(callback, 300);
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
if (typeof console === "undefined" || console === null) {
  console = { log: function() { } };
}
