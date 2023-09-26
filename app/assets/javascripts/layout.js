$(document).ready(function () {
  $('[data-toggle="tooltip"]').tooltip();

  setTimeout(function () {
    $(".notice").slideUp();
  }, 1500);

  $("#content img").each(function () {
    // Add the loading="lazy" attribute to each image
    $(this).attr("loading", "lazy");
  });
  $("#content").removeClass("javascript-disabled");
  // hide images where image policy hasn't been agreed to
  $(".image-policy-not-agreed-to").each(function () {
    // Find and replace the src attribute content with an empty string
    $(this).html(function (_, html) {
      return html.replace(/<img[^>]*src="([^"]*)"[^>]*>/g, '<img alt src="">');
    });
  });

  $.fn.isOnScreen = function () {
    var win = $(window);
    var viewport = {
      top: win.scrollTop(),
      left: win.scrollLeft(),
    };
    viewport.right = viewport.left + win.width();
    viewport.bottom = viewport.top + win.height();
    var bounds = this.offset();
    bounds.right = bounds.left + this.outerWidth();
    bounds.bottom = bounds.top + this.outerHeight();
    return !(
      viewport.right < bounds.left ||
      viewport.left > bounds.right ||
      viewport.bottom < bounds.top ||
      viewport.top > bounds.bottom
    );
  };
  $("#submit-comment-modal-button").click(function () {
    $("#submit-comment-modal-button").addClass("disabled");
    $(".spinner-button").removeClass("hide");
  });
  $('a[href^="https://"]')
    .not("a[href*=theteenmagazine]")
    .attr("target", "_blank");
  $.fn.triggerCheck = function () {
    if ($(".checkmark").isOnScreen()) {
      $(".checkmark").addClass("checkmark");
      $(".checkmark path").addClass("checkmark__check");
      $(".checkmark circle").addClass("checkmark__circle");
    }
  };
});

$(window).on("scroll", function () {
  if ($(".header-navigation")?.isOnScreen()) {
    $(".header-mobile").removeClass("header-mobile-show");
  } else {
    $(".header-mobile").addClass("header-mobile-show");
  }
});
