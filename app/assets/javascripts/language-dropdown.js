$(function() {
  $(".selected").on("click", function() {
    $("#language-dropdown-menu").toggleClass("hidden-menu");
  });

  $(".selected").on("blur", function() {
    $("#language-dropdown-menu").addClass("hidden-menu");
  });
});
