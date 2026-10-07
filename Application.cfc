component output = false {

	// Define application settings
	this.name = "jsignature";
	this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0, 1, 0, 0);
	this.scriptProtect = "all";

	// onApplicationStart
	public void function onApplicationStart() output = false {

		// Define local variables
		var tmp = "";

		// Define base folder structure
		application.folders = {
			root = getApplicationRootPath(),
			temp = getTempDirectory()
		};

		// Define url variables
		application.urls = {
			normal = "https://www.trinthlo.com/sites/jsignature",
			secure = "https://www.trinthlo.com/sites/jsignature"
		};

		// Make sure that all application.folders variables do not end with a "/" and all "\" characters are converted to "/"
		for (tmp in application.folders) {
			structUpdate(application.folders, tmp, replace(structFind(application.folders, tmp), "\", "/", "all"));
			if (right(structFind(application.folders, tmp), 1) eq "/") structUpdate(application.folders, tmp, left(structFind(application.folders, tmp), len(structFind(application.folders, tmp)) - 1));
		}

		// Make sure that all application.urls variables do not end with a "/"
		for (tmp in application.urls) {
			if (right(structFind(application.urls, tmp), 1) eq "/") structUpdate(application.urls, tmp, left(structFind(application.urls, tmp), len(structFind(application.urls, tmp)) - 1));
		}

	}

	// onRequestStart
	public void function onRequestStart() output = false {

		// Define local variables
		var tmp = "";

		// Reset application
		if (isDefined("url.reinit")) {
			tmp = application.urls.normal;
			applicationStop();
			location(tmp, false);
			cfabort();
		}

		// Load local config file
		try { include "config/#cgi.http_host#.cfc"; } catch (Any e) { }

		// Determine the host name used to serve the request
		request.urlBase = iif(cgi.https eq "on", "application.urls.secure", "application.urls.normal");
		request.sslBase = application.urls.secure;

		// Force ssl, keeping the requested page and query string
		if (cgi.https neq "on") {
			tmp = replaceNoCase(replace(getBaseTemplatePath(), "\", "/", "all"), application.folders.root, "");
			if (len(cgi.query_string)) tmp = tmp & "?" & cgi.query_string;
			location(application.urls.secure & tmp, false);
		}

	}

	// onRequest
	public void function onRequest(string targetPage = "") output = true {
		var tmp = "";
		getPageContext().getOut().clearBuffer();
		savecontent variable="request.pageContent" { include "#arguments.targetPage#"; }
		include "layout.cfm";
	}

	// getApplicationRootPath
	private string function getApplicationRootPath() output = false {
		var i = getMetaData(this);
		while (i.extends.name != "WEB-INF.cftags.component") i = getComponentMetaData(i.extends.name);
		return getDirectoryFromPath(i.path);
	}

}