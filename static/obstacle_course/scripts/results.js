$(document).ready(function() {
  $("body").append("<div id='expected'><ul id='ignored'></ul><ul id='followed'></ul></div>");

  var expected = $("#expected");
  var ignored = $("#ignored");
  var followed = $("#followed");

  expected.hide();
  expected.append("<a class='show'>Expected Results</a>");

  $("a.show").click(function() {
    expected.slideToggle("normal");
  });

  $.each($(".ignore"), function() {
    $("<li></li>").appendTo(ignored).innerText($(this).innerHTML);
  });

  $.each($(".follow"), function() {
    $("<li></li>").appendTo(followed).innerText($(this).innerHTML);
  });
});
