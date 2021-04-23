CKEDITOR.editorConfig = function( config ) {
	config.toolbarGroups = [
		{ name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
		{ name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
		{ name: 'styles', groups: [ 'styles' ] },
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'links', groups: [ 'links' ] },
		{ name: 'insert', groups: [ 'insert' ] },
		{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi', 'paragraph' ] },
		{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker', 'editing' ] },
		{ name: 'forms', groups: [ 'forms' ] },
		{ name: 'colors', groups: [ 'colors' ] },
		{ name: 'tools', groups: [ 'tools' ] },
		{ name: 'others', groups: [ 'others' ] },
		{ name: 'about', groups: [ 'about' ] }
	];

	config.removeButtons = 'Save,NewPage,ExportPdf,Preview,Print,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,SelectAll,Scayt,Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,Subscript,Superscript,CopyFormatting,Outdent,Indent,CreateDiv,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Anchor,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Font,FontSize,ShowBlocks,About,TextColor,BGColor';
  config.disableNativeSpellChecker = false;
  config.removePlugins = 'scayt,wsc';
  config.extraPlugins = 'justify,link,dialog,find';
  config.filebrowserImageBrowseUrl = '/ckeditor/pictures';
  config.filebrowserImageUploadUrl = "/ckeditor/pictures?CKEditor=post_content&CKEditorFuncNum=0&langCode=en";
  config.pasteFilter = 'p; a[!href];';
  config.language = 'en'
  config.defaultLanguage = 'en'
  config.filebrowserUploadMethod = 'form';
}

CKEDITOR.config.allowedContent = true;
