var dataColumnName = null;
var locationColumnNames = [];

$(document).ready(function() {
  determineMapTitle();
});

function ensureOnlyOneColumnChecked(element) {
  $('input#data_column[type="checkbox"]:checked').each(function() {
   $(this).attr("checked", false); 
  })
  $(element).attr("checked", true);
  dataColumnName = $(element).attr("rel");
  determineMapTitle();
}

function determineMapTitle() {
  if(dataColumnName == null) {
    if ($('input#data_column[type="checkbox"]:checked').length > 0) {
      dataColumnName = $($('input#data_column[type="checkbox"]:checked')[0]).attr("rel");
    } else {
      return true;
    }
  }
    
  var title;
  var locations = [];
  var location = "";
  if($("select#location_columns").val() == null) {
    title = capitalize(dataColumnName.replace(/_/g," "));
  } else {
    $("select#location_columns").each(function() {
      locations.push($(this).val());
    });

    for(var i = 0; i < locations.length; i++) {
      location += locations[i]
      if(i+1 !=locations.length) {
        location += ", "
      }
    }
    
    title = capitalize(dataColumnName.replace(/_/g," ")) + " by " + location.replace(/_/g," ");
  }
  $("p#map_title").html(title);
  $("input#map_title").val(title);
}