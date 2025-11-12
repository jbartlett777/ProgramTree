<CFPARAM name="URL.ID" default="">
<CFPARAM name="URL.SearchKey" default="">

<CFSET ViewID=URL.ID>

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

<!--- Get Ref info --->
<CFSET Skip=0>
<CFTRY>
	<CFQUERY name="Ref" datasource="#DSN#">
		SELECT DISTINCT s.name AS [schema_name], o.name AS referenced_entity_name, o.type, e.referenced_minor_name, e.referenced_id, e.referenced_minor_id, e.is_ambiguous, e.is_selected, e.is_select_all, e.is_updated
		FROM [#ObjInfo.Database#].sys.dm_sql_referenced_entities('[#ObjInfo.SchemaName#].[#ObjInfo.ObjectName#]','OBJECT') e
		JOIN [#ObjInfo.Database#].sys.objects o WITH (NOLOCK) ON o.object_id=e.referenced_id
		JOIN [#ObjInfo.Database#].sys.schemas s WITH (NOLOCK) ON s.schema_id=o.schema_id
		ORDER BY s.name, o.name, e.referenced_minor_name
	</CFQUERY>
	<CFCATCH type="Any">
		<CFOUTPUT>
		Unable to display referenced tables due to one or more references not existing.<br><br>
		This is likely caused by a reference to an object in another database that the user configured for the datasource can't access or the other database/object does not exist.
		</CFOUTPUT>
		<CFSET Skip=1>
		<CFABORT>
	</CFCATCH>
</CFTRY>

<CFIF NOT Skip>
	<CFQUERY name="AllTables" dbtype="Query">
		SELECT DISTINCT schema_name, referenced_entity_name, referenced_id
		FROM Ref
		WHERE referenced_minor_id = 0
		ORDER BY schema_name, referenced_entity_name
	</CFQUERY>

	<CFIF AllTables.RecordCount EQ 0>
		<CFOUTPUT>
		<span class="Arial">There are no columns referenced by WHERE/SET/JOINs</span>
		</CFOUTPUT>
		<CFABORT>
	</CFIF>

	<CFSET UpdatedColumnFound=0>
	<CFSET IndexedColumnFound=0>
	
	<CFOUTPUT>
	<span class="Arial">Referenced Columns in WHERE/SET/JOINs</span><br><br>
	<table border="0" cellspacing="0" cellpadding="2">
		<tr>
			<td><b>Table</b></td>
			<td><b>Column</b></td>
		</tr>
	<CFLOOP index="i" from="1" to="#AllTables.RecordCount#">
		<CFQUERY name="Info" dbtype="Query">
			SELECT DISTINCT referenced_minor_name, is_updated, is_ambiguous
			FROM Ref
			WHERE schema_name='#AllTables.schema_name[i]#'
				AND referenced_entity_name='#AllTables.referenced_entity_name[i]#'
				AND referenced_minor_id > 0
			ORDER BY referenced_minor_id
		</CFQUERY>
		<CFQUERY name="Indexes" datasource="#DSN#" cachedwithin="#CreateTimeSpan(0,0,1,0)#">
			select DISTINCT col.[name]
			from [#ObjInfo.Database#].sys.index_columns ic WITH (NOLOCK)
			inner join [#ObjInfo.Database#].sys.columns col WITH (NOLOCK)
			on ic.object_id = col.object_id
			and ic.column_id = col.column_id
			where ic.object_id = #AllTables.referenced_id[i]#
		</CFQUERY>

		<CFIF Info.RecordCount GT 0>
			<tr class="Arial">
				<td valign="top">#AllTables.schema_name[i]#.#AllTables.referenced_entity_name[i]#</td>
				<td>
			<CFQUERY name="Info2" dbtype="Query">
				SELECT is_select_all
				FROM Ref
				WHERE schema_name='#AllTables.schema_name[i]#'
					AND referenced_entity_name='#AllTables.referenced_entity_name[i]#'
					AND is_select_all=1
			</CFQUERY>
			<CFIF Info2.RecordCount>
				A query performs a SELECT *<br>
			</CFIF>
			<CFLOOP index="q" from="1" to="#Info.RecordCount#">
				<CFQUERY name="IsIndexed" dbtype="Query">
					SELECT * FROM Indexes WHERE Name='#Info.referenced_minor_name[q]#'
				</CFQUERY>
				<CFIF Info.is_updated[q]>
					<CFSET UpdatedColumnFound=1>
					<span class="Red">#Info.referenced_minor_name[q]#</span>
					<CFIF IsIndexed.RecordCount GT 0>
						*
						<CFSET IndexedColumnFound=1>
					</CFIF>
					<CFIF Info.is_ambiguous[q]><span class="Red">(ambiguous)</span></CFIF>
				<CFELSEIF Info2.RecordCount EQ 0>
					#Info.referenced_minor_name[q]#
					<CFIF IsIndexed.RecordCount>
						*
						<CFSET IndexedColumnFound=1>
					</CFIF>
					<CFIF Info.is_ambiguous[q]><span class="Red">(ambiguous)</span></CFIF>
				</CFIF>
				<br>
			</CFLOOP>
				</td>
			</tr>
		</CFIF>
	</CFLOOP>
	</table>
	<br>
	<CFIF UpdatedColumnFound>
		<span class="Red">Red</span> Column Name = MODIFIED<br>
	</CFIF>
	<CFIF IndexedColumnFound>
		<span class="Red">*</span> = Indexed Column<br>
	</CFIF>
	</CFOUTPUT>
</CFIF>