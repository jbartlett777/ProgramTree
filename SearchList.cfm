<!--- Fetch all online databases --->
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
	ORDER BY name
</CFQUERY>

<CFSET Report='<table border="0" cellpadding="0" cellspacing="0">'>

<CFLOOP index="CR" from="1" to="#DBs.RecordCount#">

	<!--- Find objects --->
	<CFTRY>
		<CFQUERY name="Progs" datasource="#DSN#" cachedwithin="#CreateTimeSpan(0,0,5,0)#">
			SELECT s.name as SchemaName, o.name as ObjectName, m.definition
			FROM [#DBs.name[CR]#].sys.sql_modules m
			JOIN [#DBs.name[CR]#].sys.objects o ON m.object_id = o.object_id
			JOIN [#DBs.name[CR]#].sys.schemas s ON s.schema_id = o.schema_id
			WHERE o.type IN ('P','RF','V','TR','FN','IF','TF','R')
				AND m.definition LIKE <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="%#Trim(URL.search)#%">
			ORDER BY o.type_desc, s.name, o.name
		</CFQUERY>

		<!--- Search for the line with the keyword --->
		<CFLOOP index="p" from="1" to="#Progs.RecordCount#">
			<CFSET Code=ListToArray(StripCR(Progs.definition[p]),Chr(10),true)>
			<CFSET Report=Report & "<tr><td colspan=""2""><br>" & Progs.SchemaName[p] & "." & Progs.ObjectName[p] & "</td></tr>" & Chr(10)>
			<CFLOOP index="i" from="1" to="#ArrayLen(Code)#">
				<CFIF FindNoCase(URL.search,Code[i])>
					<CFSET Report=Report & "<tr><td class=""Code Right"" valign=""top"">#i#</td><td><pre><code>" & REReplace(Code[i],"^\s+","") & "</code></pre></td></tr>" & Chr(10)>
				</CFIF>
			</CFLOOP>
		</CFLOOP>

		<CFCATCH Type="Database2">
			<!--- Eat any errros from the user not having access to the db --->
		</CFCATCH>
	</CFTRY>
</CFLOOP>

<CFSET Report=Report & "</table>">

<CFOUTPUT>#Report#</CFOUTPUT>
