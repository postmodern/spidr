function getResults(url)
{
  $.getJSON(url,function(results) {
    $("body").append("<a href='#' class='show'>Expected Results</a><div id='expected'><ul id='followed'></ul><ul id='ignored'></ul></div>");

    var expected = $("#expected");

    $("a.show").click(function() {
      expected.slideToggle("normal");
    });

    var ignored = $("#ignored");
    var followed = $("#followed");

    expected.hide();

    $.each(results.followed,function(link,example) {
      $("<li></li>").appendTo(followed).text(example);
    });

    $.each(results.ignored,function(link,example) {
      $("<li></li>").appendTo(ignored).text(example);
    });
  });
});
