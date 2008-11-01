$(document).ready(function() {
  $("body").append("<a href='#' class='show'>Expected Results</a><div id='expected'><ul id='ignored'></ul><ul id='followed'></ul></div>");

  var expected = $("#expected");

  $("a.show").click(function() {
    expected.slideToggle("normal");
  });

  var ignored = $("#ignored");
  var followed = $("#followed");

  expected.hide();

  $.each($(".ignore"), function() {
    $("<li></li>").appendTo(ignored).text($(this).innerHTML);
  });

  $.each($(".follow"), function() {
    $("<li></li>").appendTo(followed).text($(this).innerHTML);
  });
});
