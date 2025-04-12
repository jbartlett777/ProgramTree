<cftry>

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
<script src="scripts.js"></script>
<style type="text/css">
ul.fancytree-container {border: none;} /* Override Fancytree border */
</style>
</CFOUTPUT>
</CFSAVECONTENT>
<CFSET HTML=Replace(HTML,"</head>",Head & "</head>")>

<!--- Display page --->
<CFOUTPUT>#HTML#</CFOUTPUT>


<cfcatch type="any"><cfdump var=#cfcatch#></cfcatch></cftry>