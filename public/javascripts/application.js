(function($) {

$(document).ready(function() {
  $("#gallery").gallery();
  $(".preprocess-form").preprocessData(MapFormUpload.init());
  $("fieldset.required").sniffForCompletion();
  $("fieldset.required").sniffForSubmittable(".actions button[type=submit]");
  $("#pointer").stepAlongFieldsets();
  $("textarea.copyable").copyable();
  $("#maps.show .controls button").manageControls();
  initializeMapWhenReady();
});

$(window).unload(function() {
  if (typeof $.unblockUI != "undefined" && $.unblockUI !== null) {
    $.unblockUI();
  }
});

function extendMap(map) {
  map.getExtentString = function() {
    var e = this.getExtent();
    if (e) {
      // The floors and ceilings ensure subsequent renders don't put the flash
      // map at the wrong zoom level because of rounding errors.
      return [Math.ceil(e.west), Math.ceil(e.south), Math.floor(e.east), Math.floor(e.north)].join(",");
    } else {
      return "";
    }
  };
  return map;
}

var map = null;
function initializeMapWhenReady() {
  // Grab a handle to the map on the show page if it exists
  map = (typeof MAP !== "undefined" && MAP !== null) ? extendMap(MAP) : null;
  if (map) {
    // onMapReady handler doesn't seem to work correctly, so set a timeout
    // before sniffing for extents
    // map.onMapReady(function() { 
      $("#maps.show .palette").changeMapStyleOnClick(map);
      $("#maps.show .flip-colors").flipColors(map);
      $("#maps.show #save-control form").prepareMapUpdate(map);
      $(map).handleMapChanges();
      $("#maps.show #style-control button").click(function() {
        $("#maps.show .palette").guessMapStyle(map);
      });
      setTimeout(function() { $(map).sniffExtentChanges(); }, 5000);
    // });
  }                    
}

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
    $("#map_title").val(null).change();
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
      if ($(input).val().length > 0) { submitForm(); }
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

$.fn.manageControls = function() {
  return this.each(function() {
    var button = $(this);
    button.click(function() {
      var wasOn = button.parent().hasClass("active");
      button.parent().siblings().andSelf().removeClass("active");
      button.parent().toggleClass("active", !wasOn);
    });
  });
};

function updateMapColors(map) {
  var palette = $("#maps.show .palette.active");
  var colors = $.parseJSON(palette.attr("data-palette-colors"));
  var style = map.getLayer(0).styles;
  style.fill.colors = isFlipColors() ? colors.reverse() : colors;
  map.setLayerStyle(0, style);
  $(map).trigger("map-changed");
}

function setMapFormStyleValues(map, palette, flipColors) {
  $(palette).addClass("active").siblings().removeClass("active");
  var name = $(palette).attr("data-palette-name");
  $("#map_color_palette").val(name);
  $("#map_flip_colors").val(flipColors ? "1" : "");
}

function isFlipColors() {
  return !!parseInt($("#map_flip_colors").val());
}


$.fn.guessMapStyle = function(map) {
  if (!map.getLayer(0)) { return this; }
  return this.each(function() {
    var style = map.getLayer(0).styles;
    var palette = $(this);
    var colors = $.parseJSON(palette.attr("data-palette-colors"));
    var firstColor = style.fill.color;
    var firstMatch = firstColor == colors[0];
    var lastMatch  = firstColor == colors[colors.length-1];
    if (firstMatch || lastMatch) {
      setMapFormStyleValues(map, palette, false);
      if (lastMatch) { $("#maps.show .flip-colors").click(); }; 
    }
  });
};

$.fn.changeMapStyleOnClick = function(map) {
  return this.click(function() {
    var palette = $(this);
    setMapFormStyleValues(map, palette, isFlipColors());
    updateMapColors(map);
  });
};

$.fn.flipColors = function(map) {
  return this.click(function(event) { 
    event.preventDefault();
    $("#maps.show .palette").each(function() {
      var colors = $(this).find("tr");
      var parent = colors.parent();
      parent.html(colors.reverse());
    });
    $("#map_flip_colors").val(isFlipColors() ? "" : "1");
    updateMapColors(map);
  });
};

$.fn.sniffExtentChanges = function() {
  return this.valueChangeObserver(1000, 
    function(map) { return map.getExtentString(); },
    function(map) { $(map).trigger("map-changed"); }
  );
};

$.fn.handleMapChanges = function() {
  return this.bind("map-changed", function() {
    $("#save-control").fadeIn();
  });
}; 

$.fn.prepareMapUpdate = function(map) {
  return this.submit(function() {
    $("#map_extent").val(map.getExtentString());
  });
}; 

$.fn.copyable = function() {
  return this.attr("readonly", true)
    .click(function() { this.focus(); this.select();});
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

$.fn.gallery = function() {
  if (this.size() == 0) { return this; }
  var sizeScale = 0.6;
  var offsetScale = 0.7;
  var activeWidth = 300;
  var padding = 10;
  function px(n) { return n + "px"; }
  var options = {
    beforeCss: function(el, container, offset) {
      var width = 0;
      var leftOffset = 0;
      var bottom = 0;
      for (var i = 1; i <= offset + 1; i++) {
        width = activeWidth * Math.pow(sizeScale, i);
        leftOffset += (width * offsetScale);
        bottom += 40 * Math.pow(sizeScale, i);
      }
      var zIndex = 99 - offset;
      var left = (container.width() / 2) - (activeWidth / 2) - leftOffset;
      return [
        $.jcoverflip.animationElement(el, { left: px(left), bottom: px(bottom) }, { 0: { "z-index": zIndex } }),
        $.jcoverflip.animationElement(el.find("img"), { opacity: 0.5, width: px(width) }, {})
      ];
    },
    afterCss: function(el, container, offset) {
      var width = activeWidth;
      var leftOffset = 0;
      var bottom = 0;
      for (var i = 1; i <= offset + 1; i++) {
        var oldWidth = width;
        width = activeWidth * Math.pow(sizeScale, i);
        leftOffset += oldWidth - width + (width * offsetScale);
        bottom += 40 * Math.pow(sizeScale, i);
      }
      var zIndex = 99 - offset;
      var left = (container.width() / 2) - (activeWidth / 2) + leftOffset;
      return [
        $.jcoverflip.animationElement(el, { left: px(left), bottom: px(bottom) }, { 0: { "z-index": zIndex } }),
        $.jcoverflip.animationElement(el.find("img"), { opacity: 0.5, width: px(width) }, {})
      ];
    },
    currentCss: function(el, container) {
      return [
        $.jcoverflip.animationElement(el, { left: px(container.width() / 2 - activeWidth / 2), bottom: px(0) }, { 0: { "z-index": 100 } }),
        $.jcoverflip.animationElement(el.find("img"), { opacity: 1.0, width: px(activeWidth) }, {})
      ];
    },
  	titleAnimateIn: function(titleElement, time, fromRight) {
      titleElement.stop(false, true).animate({ left: "50%" }, time).fadeIn(time);
  	},
  	titleAnimateOut: function(titleElement, time, fromRight) {
  		titleElement.stop(false, true).fadeOut(time/2, function() { titleElement.hide(); });
  	},
    current: 2
  };

  this.jcoverflip(options);
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
$.fn.valueChangeObserver = function(interval, valueFn, callback) {
  if (callback == null) { 
    callback = valueFn;
    valueFn = function(elem) { return $(elem).val(); };
  }
  return this.each(function() {
    var self = this;
    var lastValue = valueFn(self);
    var check = function() {
      var value = valueFn(self);
      if (value != lastValue) {
        callback(self);
        lastValue = value;
      }
    };
    setInterval(check, interval);
  });
};

// Reverse a jQuery wrapped set
$.fn.reverse = [].reverse;

}(jQuery));

// protection against accidental left-over console.log statements
if (typeof console === "undefined" || console === null) {
  console = { log: function() { } };
}
