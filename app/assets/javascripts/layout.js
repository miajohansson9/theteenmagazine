$(document).ready(function () {
  setTimeout(function () {
    $(".notice").slideUp();
  }, 1500);

  $("#content").removeClass('javascript-disabled');
  // hide images where image policy hasn't been agreed to
  $('.image-policy-not-agreed-to').each(function() {
    // Find and replace the src attribute content with an empty string
    $(this).html(function(_, html) {
        return html.replace(/<img[^>]*src="([^"]*)"[^>]*>/g, '<img alt src="">');
    });
  });

  (function (i, s, o, g, r, a, m) {
    i["GoogleAnalyticsObject"] = r;
    (i[r] =
      i[r] ||
      function () {
        (i[r].q = i[r].q || []).push(arguments);
      }),
      (i[r].l = 1 * new Date());
    (a = s.createElement(o)), (m = s.getElementsByTagName(o)[0]);
    a.async = 1;
    a.src = g;
    m.parentNode.insertBefore(a, m);
  })(
    window,
    document,
    "script",
    "https://www.google-analytics.com/analytics.js",
    "ga"
  );
  ga("create", "UA-89987071-1", "auto");
  ga("send", "pageview");
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
  if ($(".header-navigation").isOnScreen()) {
    $(".header-mobile").removeClass("header-mobile-show");
  } else {
    $(".header-mobile").addClass("header-mobile-show");
  }
});
