// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require ckeditor/init
//= require dashboard
//= require mdb.min
//= require plugins/snap.svg-min
//= require plugins/onboarding.min
//= require index_bundle

/*========================================
=            CUSTOM FUNCTIONS            =
========================================*/

function toggleNav() {
  if ($('#site-wrapper').hasClass('show-nav')) {
      // Do things on Nav Close
      $('#site-wrapper').removeClass('show-nav');
  } else {
      // Do things on Nav Open
      $('#site-wrapper').addClass('show-nav');
  }
}

$(window).on('scroll',function(){
  if ($('.header-navigation').isOnScreen()) {
    $(".header-mobile").removeClass("header-mobile-show");
  } else {
    $(".header-mobile").addClass("header-mobile-show");
  }
});
