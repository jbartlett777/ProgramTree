
<!--- Fetch all databases --->
<CFQUERY name="DBs" datasource="#DSN#" cachedwithin="#CreateTimeSpan(0,0,1,0)#">
	SELECT database_id, name, state_desc
	FROM sys.databases
	WHERE database_id > 4
	  AND state_desc='ONLINE'
	ORDER BY name
</CFQUERY>

<CFSET S=ArrayNew(1)> <!--- Holds Fancytree data for JSON serialization --->
<CFSET Obj=QueryNew("ID,Database,SchemaName,ObjectName","varchar,varchar,varchar,varchar")> <!--- Object cache for App scope for use in View.cfm --->
<CFSET Key=0>
<CFLOOP index="CR" from="1" to="#DBs.RecordCount#">
	<!--- Build tree at DB level --->
	<CFSET Key=Key + 1>
	<CFSET SIdx=ArrayLen(S) + 1>
	<CFSET S[SIdx]=StructNew("ordered")>
	<CFSET S[SIdx].title=DBs.Name[CR]>
	<CFSET S[SIdx].key="I" & Key>
	<CFSET S[SIdx].folder="true">
	<CFSET S[SIdx].children=ArrayNew(1)>

	<!--- Gather available code types & names --->
	<CFQUERY name="Progs" datasource="#DSN#">
		SELECT 
			o.object_id,
			s.name AS SchemaName,
			o.name AS ObjectName,
			CASE o.type WHEN 'P' THEN 'Procedure'
						WHEN 'FN' THEN 'Function'
						WHEN 'IF' THEN 'Inline Table Function'
						WHEN 'TF' THEN 'Table Function'
						WHEN 'RF' THEN 'Replication Filter Procedure'
						WHEN 'V' THEN 'View'
						WHEN 'TR' THEN 'Trigger'
						WHEN 'R' THEN 'Rule'
			END as Type,
			CONVERT(char(32),HASHBYTES('SHA2_256','#DBs.name[CR]#.'+s.name+'.'+o.name),2) as HashStr
		FROM [#DBS.Name[CR]#].sys.sql_modules m
		JOIN [#DBS.Name[CR]#].sys.objects o ON m.object_id = o.object_id
		JOIN [#DBS.Name[CR]#].sys.schemas s ON s.schema_id = o.schema_id
		WHERE o.type IN ('P','RF','V','TR','FN','IF','TF','R')
		ORDER BY o.type_desc, s.name, o.name
	</CFQUERY>

	<!--- Get code types available --->
	<CFQUERY name="Types" dbtype="Query">
		SELECT DISTINCT type, COUNT(1) as Cnt
		FROM Progs
		GROUP BY type
		ORDER BY type
	</CFQUERY>

	<!--- Add function types to tree --->
	<CFLOOP index="TIdx" from="1" to="#Types.RecordCount#">
		<CFSET Key=Key + 1>
		<CFSET S[SIdx].children[TIdx]=StructNew("ordered")>
		<CFSET S[SIdx].children[TIdx].title=Types.type[TIdx] & " (" & Trim(NumberFormat(Types.Cnt[TIdx],"9,999")) & ")">
		<CFSET S[SIdx].children[TIdx].key="I" & Key>
		<CFSET S[SIdx].children[TIdx].folder="true">
		<CFSET S[SIdx].children[TIdx].children=ArrayNew(1)>


		<!--- Add function types to tree --->
		<CFQUERY name="PNames" dbtype="Query">
			SELECT object_id, SchemaName, ObjectName, HashStr
			FROM Progs
			WHERE Type=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#Types.Type[TIdx]#">
			ORDER BY SchemaName, ObjectName
		</CFQUERY>
		<CFLOOP index="PIdx" from="1" to="#PNames.RecordCount#">
			<!--- Add to JSON array --->
			<CFSET S[SIdx].children[TIdx].children[PIdx]=StructNew("ordered")>
			<CFSET S[SIdx].children[TIdx].children[PIdx].title=PNames.SchemaName[PIdx] & "." & PNames.ObjectName[PIdx]>
			<CFSET S[SIdx].children[TIdx].children[PIdx].key="P" & Pnames.HashStr[PIdx]>
			<!--- Add object to Obj cache --->
			<CFSET QueryAddRow(Obj)>
			<CFSET QuerySetCell(Obj,"ID","P" & PNames.HashStr[PIdx])>
			<CFSET QuerySetCell(Obj,"Database",DBs.Name[CR])>
			<CFSET QuerySetCell(Obj,"SchemaName",PNames.SchemaName[PIdx])>
			<CFSET QuerySetCell(Obj,"ObjectName",PNames.ObjectName[PIdx])>
		</CFLOOP>
	</CFLOOP>
</CFLOOP>

<!--- Save Obj cache data to Application scope for use in View.cfm --->
<cflock scope="Application" type="Exclusive" timeout="5">
	<CFSET Application.Obj=Obj>
</cflock>

<!--- Send the JSON back --->
<CFCONTENT type="text/javascript">
<CFOUTPUT>
var Code=#SerializeJSON(S)#;
</CFOUTPUT>
