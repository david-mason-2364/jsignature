<cfscript>

	// Define variables
	param name = "form.signaturedata" default = "";
	errorMessage = "";
	signatureImage = "";
	maxDataLength = 1000000;
	maxDimension = 3000;

	// Form submitted (the signature is converted on the server and shown back to the visitor only, it is never saved to disk)
	if (len(form.signaturedata)) {
		try {
			// jSignature sends a data url such as "data:image/png;base64,iVBORw0..."
			if (len(form.signaturedata) gt maxDataLength or listFirst(form.signaturedata, ",") neq "data:image/png;base64") throw("Invalid signature data");
			signatureBinary = toBinary(listRest(form.signaturedata, ","));
			// Check the png signature and read the width and height from the header before decoding the full image
			if (arrayLen(signatureBinary) lt 24 or bitAnd(signatureBinary[2], 255) neq 80 or bitAnd(signatureBinary[3], 255) neq 78 or bitAnd(signatureBinary[4], 255) neq 71) throw("Invalid png");
			signatureWidth = bitAnd(signatureBinary[17], 255) * 16777216 + bitAnd(signatureBinary[18], 255) * 65536 + bitAnd(signatureBinary[19], 255) * 256 + bitAnd(signatureBinary[20], 255);
			signatureHeight = bitAnd(signatureBinary[21], 255) * 16777216 + bitAnd(signatureBinary[22], 255) * 65536 + bitAnd(signatureBinary[23], 255) * 256 + bitAnd(signatureBinary[24], 255);
			if (signatureWidth lt 1 or signatureHeight lt 1 or signatureWidth gt maxDimension or signatureHeight gt maxDimension) throw("Invalid png size");
			signatureImage = imageNew(signatureBinary);
		} catch (Any e) {
			errorMessage = "The signature could not be read. Please clear it and try again.";
		}
	}

</cfscript>

<cfoutput>

	<h1>Online Signature with jSignature</h1>

	<p>
		This project enables users to create handwritten digital signatures directly within the browser using a mouse, stylus,
		or touchscreen device. The implementation leverages the jSignature library to capture smooth, vector-based signature data,
		allowing the signature to be rendered cleanly across different screen sizes and exported in multiple formats such as
		image or structured data. The interface provides an intuitive signing area where users can draw, clear, and resubmit
		their signature as needed, making it suitable for forms, agreements, acknowledgments, and other workflows requiring
		electronic confirmation. This project demonstrates how browser-based signature capture can be integrated into a web
		application in a lightweight, user-friendly way without requiring plugins or external software.
	</p>

	<p><br /></p>

	<div id="signature"></div>

	<div class="alert alert-warning d-none" id="signaturemessage">Please draw your signature before saving.</div>

	<button type="button" class="btn btn-primary" onclick="goSignatureRestart();">Restart</button>
	<button type="button" class="btn btn-primary" onclick="goSignatureClear();">Clear</button>
	<button type="button" class="btn btn-primary" onclick="goSignatureSave();">Save Signature</button>

	<form method="post" action="index.cfm" id="thx">

		<input type="hidden" name="signaturedata" id="signaturedata" value="" />

	</form>

	<cfif len(errorMessage)>
		<br /><br />
		<div class="alert alert-danger">#htmlEditFormat(errorMessage)#</div>
	<cfelseif len(form.signaturedata)>
		<br /><br />
		<p>Here is your signature, converted to an image on the server.</p>
		<cfimage action="writeToBrowser" source="#signatureImage#" format="png" class="savedsignature" alt="Your signature" />
	</cfif>

	<script type="text/javascript">

		$(document).ready(function() {

			$("##signature").jSignature({ color: '##f00', lineWidth: 3, 'decor-color': 'transparent' });

		});

		function goSignatureClear() {
			$("##signature").jSignature('clear');
			$('##signaturemessage').addClass('d-none');
		}

		function goSignatureRestart() {
			location.href = 'index.cfm';
		}

		function goSignatureSave() {
			// Don't submit an empty signature (the native format is an array of strokes)
			if ($('##signature').jSignature('getData', 'native').length == 0) {
				$('##signaturemessage').removeClass('d-none');
				return;
			}
			$('##signaturedata').val($('##signature').jSignature('getData'));
			$('##thx').submit();
		}

	</script>

</cfoutput>
