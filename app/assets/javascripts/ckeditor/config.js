CKEDITOR.editorConfig = function (config) {
  config.toolbarGroups = [
    { name: "document", groups: ["mode", "document", "doctools"] },
    { name: "styles", groups: ["styles"] },
    { name: "clipboard", groups: ["clipboard", "undo"] },
    { name: "forms", groups: ["forms"] },
    { name: "basicstyles", groups: ["basicstyles", "cleanup"] },
    { name: "links", groups: ["links"] },
    { name: "insert", groups: ["insert"] },
    {
      name: "paragraph",
      groups: ["list", "blocks", "indent", "bidi", "align", "paragraph"],
    },
    { name: "colors", groups: ["colors"] },
    { name: "others", groups: ["others"] },
    { name: "about", groups: ["about"] },
    {
      name: "editing",
      groups: ["find", "selection", "spellchecker", "editing"],
    },
    { name: "tools", groups: ["tools"] },
  ];

  config.removeButtons =
    "Save,NewPage,ExportPdf,Preview,Print,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,SelectAll,Scayt,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,Form,Subscript,Superscript,CopyFormatting,Outdent,Indent,CreateDiv,BidiLtr,BidiRtl,Language,Anchor,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Styles,Font,FontSize,TextColor,BGColor,ShowBlocks,About,Iframe,JustifyRight,JustifyBlock";
  config.disableNativeSpellChecker = false;
  config.removePlugins = "scayt,wsc";
  config.extraPlugins = "justify,link";
  config.filebrowserImageBrowseUrl = "/ckeditor/pictures";
  config.filebrowserImageUploadUrl =
    "/ckeditor/pictures?CKEditor=post_content&CKEditorFuncNum=0&langCode=en";
  config.pasteFilter = "p; a[!href];";
  config.language = "en";
  config.defaultLanguage = "en";
  config.filebrowserUploadMethod = "form";
};

CKEDITOR.config.allowedContent = true;
