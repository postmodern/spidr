function fail() { window.location = "/course/fail.html"; }

function getSpecs()
{
  $.getJSON("/course/specs.json",function(specs) {
    $("body").append("<a href='#' class='specs show_specs'>Show Specs</a><a href='#' class='specs hide_specs'>Hide Specs</a><ul id='specs'></ul>");

    var spec_list = $("#specs");

    spec_list.hide();

    $("a.hide_specs").hide();

    $("a.specs").click(function() {
      spec_list.slideToggle("normal",function() {
        $("a.show_specs").toggle();
        $("a.hide_specs").toggle();
      });
    });

    $.each(specs,function(index,spec_data) {
      var spec = $("<li class='spec'></li>").appendTo(spec_list);

      $("<p class='spec_message'></p>").appendTo(spec).text(spec_data.message);
      $("<pre class='spec_example'></pre>").appendTo(spec).text(spec_data.example);
    });
  });
}
