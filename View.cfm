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

<CFSET SQLCode=Replace(SQLCode,"<","&lt;","All")>
<CFSET SQLCode=Replace(SQLCode,">","&gt;","All")>
<CFSET Highlight='<span class="Highlight">' & EncodeForHTML(URL.SearchKey) & '</span>'>
<CFSET SQLCode=ReplaceNoCase(SQLCode,URL.SearchKey,Highlight,"All")>

<!--- Get dependencies --->
<CFQUERY name="Deps" datasource="#DSN#">
	SELECT IsNULL(d.referenced_database_name,'#ObjInfo.Database#') as DatabaseName, d.referenced_schema_name as SchemaName, d.referenced_entity_name as ObjectName
	FROM [#ObjInfo.Database#].sys.objects o
	INNER JOIN [#ObjInfo.Database#].sys.schemas s ON s.schema_id=o.schema_id
	INNER JOIN [#ObjInfo.Database#].sys.sql_expression_dependencies d ON d.referencing_id=o.object_id
	INNER JOIN [#ObjInfo.Database#].sys.objects o2 ON o2.object_id=d.referenced_id
	WHERE s.name=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ObjInfo.SchemaName#">
	AND o.name=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ObjInfo.ObjectName#">
	AND o2.type IN ('P','FN','IF','TF','RF')
</CFQUERY>

<!--- Get all called procs --->
<CFSET RegEx='(exec|execute)\s+(\.?(\[|")?[\w\d\s]+(\]|")?){1,2}\.?(\[|")?[\w\d\s]+(\]|")?'>
<CFSET Execs=REMatchNoCase(RegEx,SQLCode)>

<!--- Loop over found procs and match up against the dependencies --->
<CFLOOP index="i" from="1" to="#ArrayLen(Execs)#">
	<CFSET Proc=Trim(ListRest(Execs[i]," "))>
	<!--- Get DB, Dbo, Proc --->
	<CFSET Parts=REMatchNoCase("[^\.]+",Proc)>
	<!--- Flush out missing --->
	<CFIF ArrayLen(Parts) EQ 2>
		<CFSET ArrayInsertAt(Parts,1,ObjInfo.Database)>
	<CFELSEIF ArrayLen(Parts) EQ 1>
		<CFSET ArrayInsertAt(Parts,1,"dbo")>
		<CFSET ArrayInsertAt(Parts,1,ObjInfo.Database)>
	</CFIF>
	<!--- Identify ID of proc --->
	<CFQUERY name="ProcInfo" dbtype="Query">
		SELECT ID
		FROM ObjData
		WHERE Database=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#Parts[1]#">
		  AND SchemaName=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#Parts[2]#">
		  AND ObjectName=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#Parts[3]#">
	</CFQUERY>
	<CFIF ProcInfo.RecordCount EQ 1>
	<CFSET Execs2=Left(Execs[i],1) & "!~!~!~!~!~!~!~!~!" & Mid(Execs[i],2,Len(Execs[i]))> <!--- prevent against matching dupes --->
		<CFSET Link='<a href="javascript:void(0)" onClick="ViewCode(''#ProcInfo.ID#'')" title="View Procedure">' & Execs2 & '</a>'>
		<CFSET SQLCode=Replace(SQLCode,Execs[i],Link)>
	</CFIF>
</CFLOOP>
<!--- Replace substring holders --->
<CFSET SQLCode=Replace(SQLCode,"!~!~!~!~!~!~!~!~!","","All")>

<CFOUTPUT>
</head>
<body>
<CFSET Title="#Obj.ObjType# #ObjInfo.Database#.#ObjInfo.SchemaName#.#ObjInfo.ObjectName#">
<cfdump var=#cookie#>
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
<div class="Code"><pre style="background:white; !important"><code class="language-sql line-numbers">#SQLCode#</code></pre></div>
</CFOUTPUT>

<cfscript>
function EncodeForHTML2(txt) {
	var out=Arguments.txt;
	out=Replace(Out,"<","&lt;","All");
	out=Replace(Out,">","&gt;","All");
	return out;
}
</cfscript>

