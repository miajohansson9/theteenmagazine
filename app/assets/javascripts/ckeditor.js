var unsaved = false;

CKEDITOR.ClassicEditor.create(document.querySelector("#editor"), {
  ckbox: {
    tokenUrl: location.protocol + "//" + location.host + "/token/generate",
  },
  heading: {
    options: [
      { model: "paragraph", title: "Paragraph", class: "ck-heading_paragraph" },
      {
        model: "heading2",
        view: "h2",
        title: "Heading 2",
        class: "ck-heading_heading2",
      },
      {
        model: "heading3",
        view: "h3",
        title: "Heading 3",
        class: "ck-heading_heading3",
      },
      {
        model: "heading4",
        view: "h4",
        title: "Heading 4",
        class: "ck-heading_heading4",
      },
      {
        model: "heading5",
        view: "h5",
        title: "Heading 5",
        class: "ck-heading_heading5",
      },
      {
        model: "heading6",
        view: "h6",
        title: "Heading 6",
        class: "ck-heading_heading6",
      },
    ],
  },
  placeholder: "",
  toolbar: [
    "heading",
    "|",
    "bold",
    "underline",
    "link",
    "bulletedList",
    "numberedList",
    "alignment",
    "|",
    "blockQuote",
    "ckbox",
    "htmlEmbed",
    "undo",
    "redo",
    "|",
    "selectAll",
    "findAndReplace",
    "removeFormat",
  ],
  htmlSupport: {
    allow: [
      {
        name: /.*/,
        attributes: true,
        classes: true,
        styles: true,
      },
    ],
    disallow: ["span", "br"],
  },
  htmlEmbed: {
    showPreviews: true,
    sanitizeHtml(inputHtml) {
      var output = inputHtml;
      var urlPattern =
        /(twitter\.com|instagram\.com|tiktok\.com|spotify\.com|youtube-nocookie\.com|youtube\.com)/;
      var matches = output.match(urlPattern);
      if (!matches) {
        // embeddd html is not supported
        output =
          "<span style='color: red'>The entered source is not allowed on The Teen Magazine. Embed html from instagram, twitter, youtube, tiktok, and spotify instead.</span>";
      } else {
        output = hideSocialMediaContent(inputHtml);
      }
      return {
        html: output,
        hasChanged: true,
      };
    },
  },
  removePlugins: [
    "SourceEditing",
    "ImageToolbar",
    "ImageInsert",
    "AutoImage",
    "MediaEmbed",
    "SimpleUploadAdapter",
    "Base64UploadAdapter",
    "ImageResize",
    "CKFinder",
    "EasyImage",
    "RestrictedEditingMode",
    "RealTimeCollaborativeComments",
    "RealTimeCollaborativeTrackChanges",
    "RealTimeCollaborativeRevisionHistory",
    "PresenceList",
    "Comments",
    "TrackChanges",
    "TrackChangesData",
    "RevisionHistory",
    "Pagination",
    "WProofreader",
    "MathType",
    "SlashCommand",
    "Template",
    "DocumentOutline",
    "FormatPainter",
    "TableOfContents",
    "PasteFromOfficeEnhanced",
  ],
})
  .then(function (createdEditor) {
    editor = createdEditor;
    editor.model.document.on("change:data", function () {
      unsaved = true;
    });
  })
  .catch((error) => {
    console.error(error);
  });

$(":input").change(function () {
  unsaved = true;
});
$("#ck-form").on("submit", function () {
  unsaved = false;
});

function unloadPage() {
  if (unsaved) {
    return "You have unsaved changes on this page. Do you want to leave this page and discard your changes or stay on this page?";
  }
}

window.onbeforeunload = unloadPage;

function preventFormSubmission(event) {
  event.preventDefault();
}

function loadCKBoxScript() {
  const thumbnailUrlField = document.querySelector("#thumbnail-field");
  const thumbnailCreditsField = document.querySelector("#thumbnail-credits");
  const showSelectedUrl = document.querySelector("#showSelectedUrl");

  const form = document.querySelector("#ck-form");

  // Append the script element to the document to load CKBox
  CKBox.mount(document.querySelector("#ckbox"), {
    tokenUrl: location.protocol + "//" + location.host + "/token/generate",
    dialog: {
      width: 800,
      height: 600,
      onClose: () => {
        form.removeEventListener("submit", preventFormSubmission);
      },
    },
    assets: {
      // Callback executed after choosing assets
      onChoose: (assets) => {
        assets.forEach(({ data }) => {
          const imageUrl = data.url;
          const imageCredits = data.metadata.description;
          // Update the form field's value with the selected image URL
          thumbnailUrlField.value = imageUrl;
          thumbnailCreditsField.value = imageCredits;
          showSelectedUrl.innerHTML =
            "Image selected: <a target='_blank' class='link_grn' href='" +
            imageUrl +
            "'>" +
            imageUrl +
            "</a>";
        });
      },
    },
    view: {
      openLastView: true,
      onChange: (_) => {
        if (!!form) {
          form.addEventListener("submit", preventFormSubmission);
        }
      },
    },
  });
}

// Add a click event listener to the button
var showDialogButton = document.getElementById("showDialogButton");
if (!!showDialogButton) {
  showDialogButton.addEventListener("click", loadCKBoxScript);
}

function hideSocialMediaContent(input) {
  var tempWrapper = document.createElement("div");
  tempWrapper.innerHTML = input;

  var instagramBlockquotes = tempWrapper.querySelectorAll(".instagram-media");

  instagramBlockquotes.forEach(function (instagramBlockquote) {
    // Extract the Instagram link from the data-instgrm-permalink attribute
    var instagramPermalink = instagramBlockquote.getAttribute(
      "data-instgrm-permalink"
    );

    // Remove the parameters from the Instagram link
    var indexOfQuestionMark = instagramPermalink.indexOf("?");
    var instagramLink =
      indexOfQuestionMark !== -1
        ? instagramPermalink.substring(0, indexOfQuestionMark)
        : instagramPermalink;

    // Create the new div element with Instagram content
    var socialMsgDiv = document.createElement("div");
    socialMsgDiv.className = "hidden-social-media-wrapper";
    socialMsgDiv.innerHTML =
      '<div class="hidden-social-media-message"><h4 class="title">Instagram content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
      instagramLink +
      '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div>';

    // Replace the Instagram blockquote with the Instagram div
    instagramBlockquote.parentNode.replaceChild(
      socialMsgDiv,
      instagramBlockquote
    );
  });

  var tiktokBlockquotes = tempWrapper.querySelectorAll(".tiktok-embed");

  tiktokBlockquotes.forEach(function (tiktokBlockquote) {
    // Extract the TikTok link from the cite attribute
    var tiktokLink = tiktokBlockquote.getAttribute("cite");

    // Create the new div element with TikTok content
    var socialMsgDiv = document.createElement("div");
    socialMsgDiv.className = "hidden-social-media-wrapper";
    socialMsgDiv.innerHTML =
      '<div class="hidden-social-media-message"><h4 class="title">TikTok content</h4><p id="message">To honor your privacy, this content can only be viewed on the site it <a href="' +
      tiktokLink +
      '" target="_blank" rel="nofollow noreferrer" class="link_grn">originates</a> from.</p></div>';

    // Replace the TikTok blockquote with the TikTok div
    tiktokBlockquote.parentNode.replaceChild(socialMsgDiv, tiktokBlockquote);
  });

  // Select the YouTube iframe by its attributes or any other suitable selector
  var youtubeIframe =
    tempWrapper.querySelector('iframe[src*="youtube.com/embed"]') ??
    tempWrapper.querySelector('iframe[src*="youtube-nocookie.com/embed"]');

  if (youtubeIframe) {
    var youtubeSrc = youtubeIframe.getAttribute("src");
    youtubeSrc = youtubeSrc.replace("youtube.com", "youtube-nocookie.com");

    // Remove the parameters from the Instagram link
    var indexOfQuestionMark = youtubeSrc.indexOf("?");
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

  var spotifyIframe = tempWrapper.querySelector(
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
  var contentElement = tempWrapper.querySelector(
    ".raw-html-embed__preview-content"
  );

  if (contentElement) {
    // Get all script elements inside the "content" element
    var scriptElements = contentElement.querySelectorAll("script");

    // Loop through and remove each script element
    scriptElements.forEach(function (script) {
      script.parentNode.removeChild(script);
    });
  }

  return tempWrapper.innerHTML;
}
