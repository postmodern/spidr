var sections = {
  empty: {
    name: "Empty Links",
    results_url: "/course/empty/results.json"
  },

  javascript: {
    name: "JavaScript Links",
    results_url: "/course/javascript/results.json"
  },

  loop: {
    name: "Looping Links",
    results_url: "/course/loop/results.json"
  },

  relative: {
    name: "Relative Links",
    results_url: "/course/relative/results.json"
  }
};

function fail() { window.location = "/course/fail.html"; }

function addResults()
{
  $("body").append("<a href='#' class='results show_results'>Show Expected Results</a><a href='#' class='results hide_results'>Hide Expected Results</a><div id='expected'><ul id='followed'></ul><ul id='ignored'></ul></div>");

  var expected = $("#expected");

  expected.hide();

  $("a.hide_results").hide();

  $("a.results").click(function() {
    $("a.show_results").toggle();
    $("a.hide_results").toggle();

    expected.fadeToggle("slow");
  });

  return expected;
}

function getSectionResults(name)
{
  $.getJSON(sections[name]['results_url'],function(results) {
    var ignored = $("#ignored");
    var followed = $("#followed");

    $.each(results.followed,function(link,example) {
      $("<li></li>").appendTo(followed).text(example);
    });

    $.each(results.ignored,function(link,example) {
      $("<li></li>").appendTo(ignored).text(example);
    });
  });
}

function addSectionResults(name)
{
  addResults();
  getSectionResults(name);
}

function addAllResults()
{
  addResults();

  $.each(sections,function(name,settings) {
    getSectionResults(name);
  });
}
