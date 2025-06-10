<cftry>

<!--- Init Cookie --->
<CFCOOKIE name="BACKID" value="">

<!--- Load in teleporthq template --->
<CFFILE action="read" file="#ExpandPath('.')#\template\index.html" variable="HTML">

<!--- Update inline URL paths & variables--->
<CFSET HTML=Replace(HTML,'href="./','href="template/','All')>
<CFSET HTML=Replace(HTML,'href="public/','href="template/public/','All')>

<!--- Add includes for libries to the head block --->
<CFSAVECONTENT variable="Head">
<CFOUTPUT>
<script src="includes/jquery-3.6.0.min.js"></script>
<script src="includes/jquery-ui.min.js"></script>
<link href="includes/fancytree/skin-xp/ui.fancytree.min.css" rel="stylesheet">
<script src="includes/fancytree/jquery.fancytree.min.js"></script>
<script src="includes/fancytree/modules/jquery.fancytree.filter.js"></script>
<script src="GetDBObjects.js.cfm"></script>
<link href="includes/prism.css" rel="stylesheet">
<script src="includes/prism.js"></script>
<script src="scripts.js"></script>
<style type="text/css">
 /* Override Fancytree border */
ul.fancytree-container {
	border: none;
}
.token {
	line-height: 1.2 !important;
}
.NoUnderline {
	text-decoration: none;
}
.Highlight {
	color: black;
	background-color: ##ff90ff;
}
body, h2 {font-family:Arial, Helvetica, sans-serif;}
.Title {font-family:Arial, Helvetica, sans-serif;border-bottom: 1px solid;}
.Code {overflow-y:scroll;max-height:94vh;white-space:pre;font-family:Courier New;font-size:13px;}
</style>
</CFOUTPUT>
</CFSAVECONTENT>
<CFSET HTML=Replace(HTML,"</head>",Head & "</head>")>

<!--- Display page --->
<CFOUTPUT>#HTML#</CFOUTPUT>


<cfcatch type="any"><cfdump var=#cfcatch#></cfcatch></cftry>