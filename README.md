# Online Signature with jSignature

A small ColdFusion site that lets you draw a handwritten signature in the browser with a mouse, stylus or finger, then sends it to the server and shows it back as an image.

## What it does

- Shows a signing area using the [jSignature](https://github.com/brinley/jSignature) jQuery plugin. It works with a mouse, a stylus or a touchscreen.
- **Clear** empties the signing area. **Restart** reloads the page. **Save Signature** sends the signature to the server.
- Won't send an empty signature. You'll see a message asking you to draw one first.
- On the server, the signature arrives as a PNG data URL (`data:image/png;base64,...`). It's decoded and shown back to you with `cfimage`.

The signature is never saved to disk. Each visitor only sees their own signature, and nothing is kept after the page is shown. To store signatures in your own application, save `signatureImage` with `imageWrite()` in `index.cfm`, or save the original `form.signaturedata` string to a database.

## Limits and safety

The server doesn't trust the posted data. Before decoding the image, it checks that:

- the data is a PNG data URL no longer than 1,000,000 characters
- the decoded bytes start with the PNG signature
- the width and height in the PNG header are between 1 and 3,000 pixels

The size check runs before the full image is decoded. That stops a small file that claims to be a huge image from using up the server's memory. Anything that fails a check shows a "could not be read" message.

## Requirements

- Adobe ColdFusion 2016 or later. It may also run on Lucee, but that hasn't been tested.
- HTTPS. The site redirects every http request to `application.urls.secure`.

## Setup

1. Put the folder in your web root, for example `https://localhost/jsignature`.
2. In `Application.cfc`, inside `onApplicationStart`, change `application.urls.normal` and `application.urls.secure` to the address where the site will run (for example `https://localhost/jsignature`). If you skip this step, the https redirect and the page's CSS, JavaScript and images still point to the Trinthlo site.
3. Open `index.cfm` in a browser. If you opened the site before changing the URLs, restart ColdFusion first so the new values are loaded.

## Project structure

```
Application.cfc   App settings and SSL redirect
index.cfm         Signature checks and conversion, the signing area and its buttons
layout.cfm        Page layout and footer
assets/           Bootstrap, jQuery, jSignature, site CSS and images
```

## License

MIT, see [LICENSE](LICENSE). jSignature (`assets/js/jSignature.min.noconflict.js`) is also MIT licensed. Its copyright and license notice is at the top of the file.
