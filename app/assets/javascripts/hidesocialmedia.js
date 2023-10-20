$(document).ready(function () {
  var instagramBlockquotes = document.querySelectorAll(".instagram-media");
  instagramBlockquotes.forEach(function (instagramBlockquote) {
    // Extract the Instagram link from the data-instgrm-permalink attribute
    var instagramPermalink =
      instagramBlockquote.getAttribute("data-instgrm-permalink") ??
      instagramBlockquote.getAttribute("src");
    // Remove the parameters from the Instagram link
    var indexOfQuestionMark = instagramPermalink?.indexOf("?");
    var instagramLink =
      indexOfQuestionMark !== -1
        ? instagramPermalink.substring(0, indexOfQuestionMark)
        : instagramPermalink;

    var maybeHandles = instagramBlockquote.querySelectorAll("a");
    var handle = "";

    maybeHandles.forEach(function (a) {
      var match = /\((@[^)]*)\)/.exec(a?.textContent); // Extract the handle
      if (match) {
        handle = "<h3>" + match[1] + "</h3>"; // Use the extracted handle
      } else {
        handle = ""; // No valid handle found
      }
    });

    // Create the new div element with Instagram content
    var socialMsgDiv = document.createElement("div");
    socialMsgDiv.innerHTML =
      handle +
      '<div class="hidden-social-media-wrapper"><div class="hidden-social-media-message"><h4 class="title">Instagram content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
      instagramLink +
      '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div></div>';

    // Replace the Instagram blockquote with the Instagram div
    instagramBlockquote.parentNode.replaceChild(
      socialMsgDiv,
      instagramBlockquote
    );
  });

  $(".instagram-media-registered").remove();

  var tiktokBlockquotes = document.querySelectorAll(".tiktok-embed");

  tiktokBlockquotes.forEach(function (tiktokBlockquote) {
    // Extract the TikTok link from the cite attribute
    var tiktokLink = tiktokBlockquote.getAttribute("cite");

    var match = /(?<=@)[^/]+(?=\/)/.exec(tiktokLink);
    var handle = match ? "@" + match[0] : null;

    if (handle) {
      handle = "<h3>" + handle + "</h3>";
    } else {
      handle = "";
    }

    // Create the new div element with TikTok content
    var socialMsgDiv = document.createElement("div");
    socialMsgDiv.innerHTML =
      handle +
      '<div class="hidden-social-media-wrapper"><div class="hidden-social-media-message"><h4 class="title">TikTok content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
      tiktokLink +
      '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div></div>';

    // Replace the TikTok blockquote with the TikTok div
    tiktokBlockquote.parentNode.replaceChild(socialMsgDiv, tiktokBlockquote);
  });

  // Select the YouTube iframe by its attributes or any other suitable selector
  var youtubeIframe =
    document.querySelector('iframe[src*="youtube.com/embed"]') ??
    document.querySelector('iframe[src*="youtube-nocookie.com/embed"]');

  if (youtubeIframe) {
    var youtubeSrc = youtubeIframe.getAttribute("src");
    youtubeSrc = youtubeSrc.replace("youtube.com", "youtube-nocookie.com");

    // Remove the parameters from the Instagram link
    var indexOfQuestionMark = youtubeSrc?.indexOf("?");
    var youtubeSrc =
      indexOfQuestionMark !== -1
        ? youtubeSrc.substring(0, indexOfQuestionMark)
        : youtubeSrc;

    // Create the new div element with YouTube content
    var socialMsgDiv = document.createElement("div");
    socialMsgDiv.innerHTML =
      '<div class="hidden-social-media-wrapper"><div class="hidden-social-media-message"><h4 class="title">Youtube content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
      youtubeSrc +
      '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div></div>';
    // Replace the YouTube iframe with the YouTube div
    youtubeIframe.parentNode.replaceChild(socialMsgDiv, youtubeIframe);
  }

  var spotifyIframe = document.querySelector(
    'iframe[src*="spotify.com/embed"]'
  );

  if (spotifyIframe) {
    var spotifySrc = spotifyIframe.getAttribute("src");

    // Remove the parameters from the Instagram link
    var indexOfQuestionMark = spotifySrc.indexOf("?");
    var spotifySrc =
      indexOfQuestionMark !== -1
        ? spotifySrc.substring(0, indexOfQuestionMark)
        : spotifySrc;

    // Create the new div element with YouTube content
    var socialMsgDiv = document.createElement("div");
    socialMsgDiv.innerHTML =
      '<div class="hidden-social-media-wrapper"><div class="hidden-social-media-message"><h4 class="title">Spotify content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
      spotifySrc +
      '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div></div>';

    // Replace the YouTube iframe with the YouTube div
    spotifyIframe.parentNode.replaceChild(socialMsgDiv, spotifyIframe);
  }

  // Select the element with the id "content"
  var contentElement = document.getElementById("content");

  if (contentElement) {
    // Get all script elements inside the "content" element
    var scriptElements = contentElement.querySelectorAll("script");

    // Loop through and remove each script element
    scriptElements.forEach(function (script) {
      script.parentNode.removeChild(script);
    });
  }

  // Define the URL pattern to match
  var urlPattern =
    /(twitter\.com|instagram\.com|tiktok\.com|youtube-nocookie\.com|youtube\.com)/;

  // Get all iframes and blockquotes on the page
  var mediaElements = document.querySelectorAll("iframe, blockquote");

  // Loop through each media element
  mediaElements.forEach(function (element) {
    if (element.tagName === "IFRAME") {
      // If it's an iframe, extract the src attribute
      var src = element.getAttribute("src");

      // Check if the src matches the URL pattern
      if (!urlPattern.test(src)) {
        // If it doesn't match, replace the iframe with a message and link
        var socialMsgDiv = document.createElement("div");
        socialMsgDiv.className = "hidden-social-media-wrapper";
        socialMsgDiv.innerHTML =
          '<div class="hidden-social-media-message"><h4 class="title">Social Media content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
          src +
          '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div>';

        element.parentNode.replaceChild(socialMsgDiv, element);
      }
    } else if (element.tagName === "BLOCKQUOTE") {
      // If it's a blockquote, check if it has a cite attribute
      var cite = element.getAttribute("cite");

      if (cite && !urlPattern.test(cite)) {
        // If it has a cite attribute and doesn't match the pattern, replace it
        var socialMsgDiv = document.createElement("div");
        socialMsgDiv.className = "hidden-social-media-wrapper";
        socialMsgDiv.innerHTML =
          '<div class="hidden-social-media-message"><h4 class="title">Social Media content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
          cite +
          '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div>';

        element.parentNode.replaceChild(socialMsgDiv, element);
      }
    }
  });
});
