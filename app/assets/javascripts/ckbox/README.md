# CKBox

https://ckbox.io/

CKBox is a file management platform that makes working with your files easier while providing an outstanding user experience.

![](https://github-production-user-asset-6210df.s3.amazonaws.com/12546548/263761910-fd39039c-adad-4e54-a125-20578507c15f.png)

## Quick start

Using a build served from the CDN is the simplest and fastest way of embedding CKBox in your application. Additionally, all the scripts served from the CDN are loaded faster, as they are hosted on multiple servers around the globe, shortening the response time.

To start using CKBox on your website, embed the following `script` element in the HTML code of the page:

```html
<script src="https://cdn.ckbox.io/ckbox/2.1.0/ckbox.js"></script>
```

Quick implementation example:

```html
<!doctype html>
<html>
	<head>
		<meta charset="UTF-8" />
		<script src="https://cdn.ckbox.io/ckbox/2.1.0/ckbox.js"></script>
	</head>
	<body>
		<div id="ckbox"></div>
		<script>
			// You must provide a valid token URL in order to use the application
			// After registering to CKBox, the fastest way to try out CKBox is to use the development token endpoint:
			// https://ckeditor.com/docs/ckbox/latest/guides/configuration/authentication.html#token-endpoint
			CKBox.mount(document.getElementById("ckbox"), {
				tokenUrl: "https://your.token.url",
			});
		</script>
	</body>
</html>
```

### Integration with CKEditor 5

The code snippet below presents the simplest scenario for integration of CKEditor 5 with CKBox. To read more about the integration, please refer to the [CKEditor 5 integration guide](https://ckeditor.com/docs/ckbox/latest/guides/configuration/ckeditor-integration.html).

```html
<!doctype html>
<html>
	<head>
		<meta charset="UTF-8" />
		<script src="https://cdn.ckeditor.com/ckeditor5/39.0.0/classic/ckeditor.js"></script>
		<script src="https://cdn.ckbox.io/ckbox/2.1.0/ckbox.js"></script>
	</head>
	<body>
		<div id="editor"></div>
		<script>
			ClassicEditor.create(document.querySelector("#editor"), {
				ckbox: {
					tokenUrl: "https://your.token.url",
				},
				toolbar: [
					"ckbox",
					"imageUpload",
					"|",
					"heading",
					"|",
					"undo",
					"redo",
					"|",
					"bold",
					"italic",
					"|",
					"blockQuote",
					"indent",
					"link",
					"|",
					"bulletedList",
					"numberedList",
				],
			}).catch((error) => {
				console.error(error);
			});
		</script>
	</body>
</html>
```

For more advanced integration scenarios, please refer to the [CKBox documentation](https://ckeditor.com/docs/ckbox/latest/guides/index.html).

## Documentation

[CKBox documentation](https://ckeditor.com/docs/ckbox/latest/guides/index.html) includes information about:

-   Enabling CKBox in your application.
-   Integrating CKBox with CKEditor 5.
-   Configuring and customizing CKBox.

You will find ready to use code snippets and live examples there.

## License

**CKBox** (https://ckeditor.com/ckbox/)

Copyright (c) 2003-2023, [CKSource Holding sp. z o.o.](https://cksource.com/) All rights reserved.
**CKBox** is licensed under a commercial license and is protected by copyright law. For more details about available licensing options please contact us at [sales@cksource.com](mailto:sales@cksource.com).

Trademarks
**CKBox** is a trademark of [CKSource Holding sp. z o.o.](https://cksource.com/) All other brand and product names are trademarks, registered trademarks or service marks of their respective holders.
