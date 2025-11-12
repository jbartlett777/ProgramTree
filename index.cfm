<cftry>

<!--- Init Cookie --->
<CFCOOKIE name="BACKID" value="">

<!--- Load in teleporthq template --->
<CFFILE action="read" file="#ExpandPath('.')#\template\index.html" variable="HTML">

<!--- Update inline URL paths & variables--->
<CFSET HTML=Replace(HTML,'href="./','href="template/','All')>

<!--- Add version to CSS for cache updates --->
<CFSET FI=GetFileInfo("#RootDir#/index.cfm")>
<CFSET Ver=DateFormat(FI.LastModified,"yyyymmddHHmmss")>
<CFSET HTML=Replace(HTML,'href="./style.css"','href="./style.css?ver=#Ver#"')>
<CFSET HTML=Replace(HTML,'href="./index.css"','href="./index.css?ver=#ver#"')>

<!--- Check for proper access to viewable databases --->
<CFQUERY name="DBs" datasource="#DSN#" cachedwithin="#CreateTimeSpan(0,0,1,0)#">
	SELECT name
	FROM sys.databases
	WHERE database_id > 4
	AND state_desc='ONLINE'
	<CFIF ShowOnlyDatabases NEQ "">
	AND name IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ShowOnlyDatabases#" list="true">)
	<CFELSEIF ExcludeDatabases NEQ "">
	AND name NOT IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ExcludeDatabases#" list="true">)
	</CFIF>
	ORDER BY UPPER(name)
</CFQUERY>
<CFSET PermsNeeded="">
<CFLOOP index="CR" from="1" to="#DBs.RecordCount#">
	<CFTRY>
		<CFQUERY name="CheckObj" datasource="#DSN#">
			SELECT TOP 1 object_id
			FROM [#DBs.name[CR]#].sys.objects
		</CFQUERY>
		<CFCATCH type="Database">
			<!--- User does not have access to DB, skip to next one --->
			<CFCONTINUE>
		</CFCATCH>
	</CFTRY>
	<CFTRY>
		<!--- Check to see if the user can view sys.sql_expression_dependencies --->
		<CFIF CheckObj.RecordCount GT 0>
			<CFQUERY name="Chk" datasource="#DSN#">
				SELECT referencing_id
				FROM [#DBs.name[CR]#].sys.sql_expression_dependencies
				WHERE referencing_id=0
			</CFQUERY>
		</CFIF>
		<CFCATCH Type="Database">
			<CFSET PermsNeeded=PermsNeeded & "USE [#DBS.name[CR]#]<br>" &
											 "GO<br>" &
											 "GRANT VIEW DEFINITION TO [UserName]<br>" &
											 "GRANT SELECT ON sys.sql_expression_dependencies TO [UserName]<br>" &
											 "GO<br><br>">
		</CFCATCH>
	</CFTRY>
</CFLOOP>
<CFIF PermsNeeded NEQ "">
	<CFSET HTML=Replace(HTML,"Click on an object to view its Code","The following permissions need to be granted in order to view the procedure dependencies with other procedures and navigate between them.<br>" &
	"<div class=""Code""><pre style=""background:white; !important""><code class=""language-sql"">#PermsNeeded#</code></pre></div>Replace ""UserName"" with the user on the datasource.")>
</CFIF>

<CFSET HTML=Replace(HTML,'href="public/','href="template/public/','All')>

<!--- Add includes for libries to the head block --->
<CFSAVECONTENT variable="Head">
<CFOUTPUT>
<script src="includes/jquery-3.6.0.min.js"></script>
<script src="includes/jquery-ui.min.js?Ver=#Ver#"></script>
<link href="includes/fancytree/skin-xp/ui.fancytree.min.css?Ver=#Ver#" rel="stylesheet">
<script src="includes/fancytree/jquery.fancytree.min.js?Ver=#Ver#"></script>
<script src="includes/fancytree/modules/jquery.fancytree.filter.js?Ver=#Ver#"></script>
<script src="includes/slide-out-panel.min.js"></script> <!--- https://github.com/webdevnerdstuff/jquery-SlideOutPanel --->
<link href="includes/slide-out-panel.css" rel="stylesheet">
<script src="GetDBObjects.js.cfm"></script>
<link href="includes/prism.css?Ver=#Ver#" rel="stylesheet">
<script src="includes/prism.js?Ver=#Ver#"></script>
<script src="scripts.js?Ver=#Ver#"></script>
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
.HighlightLine {
	background-color: yellow;
}
.Red {
	color: red;
}

body, h2 {font-family:Arial, Helvetica, sans-serif;}
.Title {font-family:Arial, Helvetica, sans-serif;border-bottom: 1px solid;}
.Code {overflow-y:scroll;max-height:94vh;white-space:pre;font-family:Courier New;font-size:13px;}
</style>
<CFIF PermsNeeded NEQ "">
	<script language="JavaScript">
	RunPrism();
	</script>
</CFIF>
<div id="slideoutpanel" class="slide-out-panel">
<header id="PanelHeader"></header>
	<section id="PanelSection">
	</section>
<footer id="PanelFooter"></footer>
</div>
<script src="scripts_panel.js?Ver=#Ver#"></script>
</CFOUTPUT>
</CFSAVECONTENT>
<CFSET HTML=Replace(HTML,"</head>",Head & "</head>")>

<!--- Display page --->
<CFOUTPUT>#HTML#</CFOUTPUT>


<cfcatch type="any2"><cfdump var=#cfcatch#></cfcatch></cftry>