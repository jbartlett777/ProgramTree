<CFPARAM name="URL.search" default="">

<CFSET ResultKeys=ArrayNew(1)>

<!--- No searches for less than 3 characters --->
<CFIF Len(Trim(URL.search)) GTE 3>
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

	<CFLOOP index="CR" from="1" to="#DBs.RecordCount#">

		<!--- Find objects --->
		<CFTRY>
			<CFQUERY name="Progs" datasource="#DSN#" cachedwithin="#CreateTimeSpan(0,0,5,0)#">
				SELECT 'P' + CONVERT(char(32),HASHBYTES('SHA2_256','#DBs.name[CR]#.'+s.name+'.'+o.name),2) as HashStr
				FROM [#DBs.name[CR]#].sys.sql_modules m
				JOIN [#DBs.name[CR]#].sys.objects o ON m.object_id = o.object_id
				JOIN [#DBs.name[CR]#].sys.schemas s ON s.schema_id = o.schema_id
				WHERE o.type IN ('P','RF','V','TR','FN','IF','TF','R')
					AND m.definition LIKE <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="%#Trim(URL.search)#%">
				ORDER BY o.type_desc, s.name, o.name
			</CFQUERY>

			<!--- Append founds keys to results --->
			<CFSET ArrayAppend(ResultKeys,ValueArray(Progs,"HashStr"),true)>
			<CFCATCH Type="Database">
				<!--- Eat any errros from the user not having access to the db --->
			</CFCATCH>
		</CFTRY>
	</CFLOOP>
</CFIF>

<!--- Return the resulting keys as a JSON array --->
<CFCONTENT type="text/json" reset="true">
<CFOUTPUT>#SerializeJSON(ResultKeys)#</CFOUTPUT>
