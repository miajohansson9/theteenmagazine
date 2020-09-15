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
//= require jquery.min
//= require jquery_ujs
//= require ckeditor/init
//= require umd/popper.min
//= require_tree .

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
  //$('#site-wrapper').toggleClass('show-nav');
}
