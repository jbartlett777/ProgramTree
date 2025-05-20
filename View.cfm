<CFPARAM name="URL.ID" default="0">
<CFPARAM name="URL.SearchKey" default="">

<!--- Load in the object data --->
<CFPARAM NAME="URL.id" default="">
<CFSET FN=ExpandPath(".") & "/Obj.json">
<CFIF FileExists(FN) EQ "NO">
	<CFOUTPUT>Object data was lost, please refresh the page to restore</CFOUTPUT>
	<CFABORT>
</CFIF>

<CFFILE action="Read" file="#FN#" variable="JSON">
<CFSET ObjData=DeserializeJSON(JSON,false)>

<!--- Fetch object --->
<CFQUERY name="ObjInfo" dbtype="Query">
	SELECT Database, SchemaName, ObjectName
	FROM ObjData
	WHERE ID=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#URL.ID#">
</CFQUERY>
<CFIF ObjInfo.RecordCount EQ 0>
	<CFOUTPUT>Unable to locate object</CFOUTPUT>
	<CFABORT>
</CFIF>
<CFQUERY name="Obj" datasource="#DSN#">
	SELECT o.object_id, o.modify_date, m.definition,
			CASE o.type WHEN 'P' THEN 'Procedure'
						WHEN 'FN' THEN 'Function'
						WHEN 'IF' THEN 'Inline Table Function'
						WHEN 'TF' THEN 'Table Function'
						WHEN 'RF' THEN 'Replication Filter Procedure'
						WHEN 'V' THEN 'View'
						WHEN 'TR' THEN 'Trigger'
						WHEN 'R' THEN 'Rule'
			END as ObjType
	FROM [#ObjInfo.Database#].sys.objects o
	JOIN [#ObjInfo.Database#].sys.schemas s ON s.schema_id=o.schema_id
	JOIN [#ObjInfo.Database#].sys.sql_modules m ON m.object_id=o.object_id
	WHERE s.name=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ObjInfo.SchemaName#">
	AND o.name=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ObjInfo.ObjectName#">
</CFQUERY>
<CFIF Obj.RecordCount EQ 0>
	<CFOUTPUT>Object not found</CFOUTPUT>
	<CFABORT>
</CFIF>

<CFSET SQLCode=Obj.definition>
<!--- Trim off any leading line feeds --->
<CFLOOP condition="Left(SQLCode,1) EQ Chr(10)">
	<CFSET SQLCode=Mid(SQLCode,2,Len(SQLCode))>
</CFLOOP>

<CFOUTPUT>
<!DOCTYPE HTML>
<head>
<style type="text/css">
body, h2 {font-family:Arial, Helvetica, sans-serif;}
.Title {font-family:Arial, Helvetica, sans-serif;border-bottom: 1px solid;}
.Code {overflow-y:scroll;max-height:94vh;white-space:pre;font-family:Courier New;font-size:13px;}
</style>
<link href="includes/prism.css" rel="stylesheet">
</head>
<body>
<script src="includes/prism.js"></script>
<CFSET Title="#Obj.ObjType# #ObjInfo.Database#.#ObjInfo.SchemaName#.#ObjInfo.ObjectName#">
<span class="Title">#EncodeForHTML(Title)#</span><br>
Last Updated: #DateTimeFormat(Obj.Modify_Date,"mmmm d, yyyy h:nn:ss tt")#<br>
<br>
<div class="Code"><pre style="background:white; !important"><code class="language-sql line-numbers">#EncodeForHTML(SQLCode)#</code></pre></div>
</body>
</html>
</CFOUTPUT>

<cfscript>
function EncodeForHTML2(txt) {
	var out=Arguments.txt;
	out=Replace(Out,"<","&lt;","All");
	out=Replace(Out,">","&gt;","All");
	return out;
}
</cfscript>

