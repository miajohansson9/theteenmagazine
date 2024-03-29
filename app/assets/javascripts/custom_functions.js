function toggleNav() {
  if ($("#site-wrapper").hasClass("show-nav")) {
    // Do things on Nav Close
    $("#site-wrapper").removeClass("show-nav");
  } else {
    // Do things on Nav Open
    $("#site-wrapper").addClass("show-nav");
  }
}

function copyUrlToClipboard(copyId) {
  let copyText = document.querySelectorAll(".copy-text");
  navigator.clipboard.writeText(window.location.href).then(
    () => {
      console.log("Copied to clipboard");
      /* Resolved - text copied to clipboard successfully */
      for (var i = 0; i < copyText.length; ++i) {
        copyText[i].classList.add("active");
      }
      window.getSelection().removeAllRanges();
      setTimeout(function () {
        for (var i = 0; i < copyText.length; ++i) {
          copyText[i].classList.remove("active");
        }
      }, 2500);
    },
    () => {
      console.error("Failed to copy");
      /* Rejected - text failed to copy to the clipboard */
    }
  );
}

function clickedLoadMoreButton(id) {
  $(id).addClass("disabled");
  $(".spinner-button").removeClass("hide");
}

function animateEditorStats(decimal) {
  var s = Snap("#animated");
  var progress = s.select("#progress");

  progress.attr({ strokeDasharray: "0, 251.2" });
  Snap.animate(
    0,
    decimal * 251.2,
    function (value) {
      progress.attr({ "stroke-dasharray": value + ",251.2" });
    },
    1000
  );
}

function select_article_status() {
  var selected = document.getElementById(
    "post_reviews_attributes_0_status"
  ).value;
  if (selected == "Approved for Publishing" || selected === "Recommend for Publishing") {
    $(".rejected-reason").addClass("hide");
    $(".accepted-descr").removeClass("hide");
  } else if (selected == "Rejected") {
    $(".rejected-reason").removeClass("hide");
    $(".accepted-descr").addClass("hide");
  } else {
    $(".rejected-reason").addClass("hide");
    $(".accepted-descr").addClass("hide");
  }
  if (selected === "In Review") {
    $(".editor-review").addClass("hide")
  } else {
    $(".editor-review").removeClass("hide")
  }
  if (selected === "Request Re-Review") {
    $(".re-request-review").removeClass("hide")
  } else {
    $(".re-request-review").addClass("hide")
  }
  re-request-review
}

function showPopup() {
  $("#TTM-Modal").modal("show");
  $(document).off("focusin.modal");
}

function submitModal() {
  $(".spinner-button").removeClass("hide");
  $("#claim-pitch-modal-button").addClass("disabled");
}

function select_status() {
  var selected = document.getElementById("pitch_status").value;
  if (selected == "Approved") {
    $(".rejected-reason").addClass("hide");
    $(".accepted-descr").removeClass("hide");
  } else {
    $(".rejected-reason").removeClass("hide");
    $(".accepted-descr").addClass("hide");
  }
}

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
    var value = Math.round(end - remaining * range);
    obj.innerHTML = value;
    if (value == end) {
      clearInterval(timer);
    }
  }

  timer = setInterval(run, stepTime);
  run();
}

function scrollToResponseText(text) {
  $("#response_to_text_0").removeAttr("id");
  $(`#selectable_content:contains(` + `${text}` + `)`).each(function () {
    var paragraph = $(this).html();
    var escaped = text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
    var re = new RegExp(escaped, "g");
    $(this).html(
      paragraph.replace(re, `<span id="response_to_text_0">${text}</span>`)
    );
  });
  if ($("#response_to_text_0").length == 0) {
    alert(
      "This text was unable to be located and has either been altered or deleted."
    );
  } else {
    $("#response_to_text_0").get(0).scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
}

function reply(id) {
  $(".reply_form_wrapper").stop().slideUp(400);
  $(id).stop().slideToggle(400);
}

function isDisabled(id) {
  var input = $(".comment_field_" + id).val();
  var input_name = "jane";
  var is_thirteen = true;
  // name should have valid letters
  var regExp = /[a-zA-Z]/g;
  // if no user signed in must fill out full name
  if ($(".full_name_" + id)[0]) {
    input_name = $(".full_name_" + id).val();
  }
  // must be 13 to post
  if ($(".is_thirteen_" + id)[0]) {
    is_thirteen = $(".is_thirteen_" + id).is(":checked");
  }
  if (input != "" && regExp.test(input_name) && is_thirteen) {
    $(".submit_" + id).removeClass("disabled");
  } else {
    $(".submit_" + id).addClass("disabled");
  }
}

function isFormButtonDisabled(input) {
  var input = $(input).val();
  $("#result-text").text("");
  if (input.includes("@")) {
    $("#submit-comment-modal-button").removeClass("disabled");
  } else {
    $("#submit-comment-modal-button").addClass("disabled");
  }
}
