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
  highlight: {
    options: [
        {
            model: 'yellowMarker',
            class: 'pen-yellow',
            title: 'Yellow marker',
            color: 'yellow',
            type: 'marker'
        },
        {
          model: 'greenMarker',
          class: 'pen-green',
          title: 'Green marker',
          color: '#39ff14',
          type: 'marker'
        },
        {
          model: 'bluePen',
          class: 'pen-blue',
          title: 'Blue marker',
          color: '#83EEFF',
          type: 'pen'
        },
        {
            model: 'pinkPen',
            class: 'pen-pink',
            title: 'Pink marker',
            color: '#fe019a',
            type: 'pen'
        }
      ]
  },
  placeholder: "Start writing here...",
  toolbar: [
    "heading",
    "|",
    "bold",
    "italic",
    "underline",
    "highlight",
    "link",
    "bulletedList",
    "numberedList",
    "alignment",
    "|",
    "blockQuote",
    "uploadImage",
    "sourceEditing",
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
  },
  removePlugins: [
    "ImageToolbar",
    "ImageInsert",
    "AutoImage",
    "MediaEmbed",
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
      $("#unsaved-changes").removeClass("hide");
    });
  })
  .catch((error) => {
    console.error(error);
  });

$(":input").change(function () {
  unsaved = true;
  $("#unsaved-changes").removeClass("hide");
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
      onChange: (change) => {
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
