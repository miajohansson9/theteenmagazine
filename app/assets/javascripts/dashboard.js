function animateValue(id, start, end, duration) {
    // assumes integer values for start and end
    var obj = document.getElementById(id);
    var range = end - start;
    // no timer shorter than 50ms (not really visible any way)
    var minTimer = 50;
    // calc step time to show all interediate values
    var stepTime = Math.abs(Math.floor(duration / range));

    // never go below minTimer
    stepTime = Math.max(stepTime, minTimer);

    // get current time and calculate desired end time
    var startTime = new Date().getTime();
    var endTime = startTime + duration;
    var timer;

    function run() {
        var now = new Date().getTime();
        var remaining = Math.max((endTime - now) / duration, 0);
        var value = Math.round(end - (remaining * range));
        obj.innerHTML = value;
        if (value == end) {
            clearInterval(timer);
        }
    }

    timer = setInterval(run, stepTime);
    run();
};

function reply(id) {
  $(".reply_form_wrapper").stop().slideUp(400);
  $(id).stop().slideToggle(400);
}

function isDisabled(id) {
  var input = $('.comment_field_' + id).val();
  if (input != "") {
    $('.submit_' + id).removeClass("disabled");
  } else {
    $('.submit_' + id).addClass("disabled");
  }
}
