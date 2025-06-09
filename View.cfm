<CFPARAM name="URL.ID" default="">
<CFPARAM name="URL.SearchKey" default="">

<CFSET ViewID=URL.ID>

<CFIF ViewID EQ "">
	<CFOUTPUT>
	<span class="home-text">Click on an object to view its Code</span>
	</CFOUTPUT>
	<CFABORT>
</CFIF>

<!--- Load in the object data --->
<CFPARAM NAME="ViewID" default="">
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
	WHERE ID=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ViewID#">
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
</head>
<body>
<script src="includes/prism.js"></script>
<CFSET Title="#Obj.ObjType# #ObjInfo.Database#.#ObjInfo.SchemaName#.#ObjInfo.ObjectName#">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="16" valign="top">
			<CFIF ListLen(Cookie.BACKID) GT 1>
				<a href="javascript:void(0);" onClick="GoBack()" class="NoUnderline">
					<img src="images/back.svg" alt="Back to previously viewed procedure" title="Back to previously viewed procedure" width="16" height="16">
				</a>
			<CFELSE>
				<img src="images/blank.svg" width="16" height="16">
			</CFIF>
		</td>
		<td>
			&nbsp;
		</td>
		<td>
			<span class="Title">#EncodeForHTML(Title)#</span><br>
			Last Updated: #DateTimeFormat(Obj.Modify_Date,"mmmm d, yyyy h:nn:ss tt")#
		</td>
	</tr>
</table>
<br>
<div class="Code"><pre style="background:white; !important"><code class="language-sql line-numbers">#EncodeForHTML(SQLCode)#</code></pre></div>
</CFOUTPUT>

<cfscript>
function EncodeForHTML2(txt) {
	var out=Arguments.txt;
	out=Replace(Out,"<","&lt;","All");
	out=Replace(Out,">","&gt;","All");
	return out;
}
</cfscript>

