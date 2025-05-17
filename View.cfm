<CFPARAM name="URL.ID" default="0">
<CFPARAM name="URL.SearchKey" default="">

<!--- All SQL Server functions and field types for color formatting --->
<CFSET FieldTypes="BIGINT|BINARY|BIT|CHAR|DATETIME2|DATETIMEOFFSET|DATETIME|DATE|DECIMAL|FLOAT|GEOGRAPHY|GEOMETRY|HIERARCHYID|IMAGE|" &
				  "INTEGER|INT|JSON|MONEY|NCHAR|NTEXT|NUMERIC|NVARCHAR|REAL|ROWVERSION|SMALLDATETIME|SMALLINT|SMALLMONEY|SQL_VARIANT|TABLE|" &
				  "TEXT|TIME|TINYINT|UNIQUEIDENTIFIER|VARBINARY|VARCHAR|VECTOR|XML">
<CFSET FieldTypesNoParan="BIGINT|SMALLINT|TINYINT|INT|BIT|REAL|SMALLMONEY|MONEY|GEOGRAPHY::|GEOGRAPHY|IDENTITY">

<CFSET SQLFunctions="ABS|ACOS|APPLOCK_MODE|APPLOCK_TEST|APPROX_COUNT_DISTINCT|APPROX_PERCENTILE_CONT|APPROX_PERCENTILE_DISC|APP_NAME|ASCII|" &
                    "ASIN|ASSEMBLYPROPERTY|ASYMKEYPROPERTY|ASYMKEY_ID|ATAN|ATN2|AVG|BINARY_CHECKSUM|BIT_COUNT|CAST|CEILING|CERTENCODED|" &
                    "CERTPRIVATEKEY|CERTPROPERTY|CERT_ID|CHAR|CHARINDEX|CHECKSUM|CHECKSUM_AGG|CHOOSE|COALESCE|COLLATIONPROPERTY|" &
                    "COLUMNPROPERTY|COLUMNS_UPDATED|COL_LENGTH|COL_NAME|COMPRESS|CONCAT|CONCAT_WS|CONNECTIONPROPERTY|CONTEXT_INFO|CONVERT|" &
                    "COS|COT|COUNT|COUNT_BIG|CRYPT_GEN_RANDOM|CUME_DIST|CURRENT_REQUEST_ID|CURRENT_TIMESTAMP|CURRENT_TIMEZONE|" &
                    "CURRENT_TIMEZONE_ID|CURRENT_TRANSACTION_ID|CURRENT_USER|CURSOR_STATUS|DATABASEPROPERTYEX|DATABASE_PRINCIPAL_ID|" &
                    "DATALENGTH|DATEADD|DATEDIFF|DATEDIFF_BIG|DATEFROMPARTS|DATENAME|DATEPART|DATETIME2FROMPARTS|DATETIMEFROMPARTS|" &
                    "DATETIMEOFFSETFROMPARTS|DATETRUNC|DATE_BUCKET|DAY|DB_ID|DB_NAME|DECOMPRESS|DECRYPTBYASYMKEY|DECRYPTBYCERT|" &
                    "DECRYPTBYKEY|DECRYPTBYKEYAUTOASYMKEY|DECRYPTBYKEYAUTOCERT|DECRYPTBYPASSPHRASE|DEGREES|DENSE_RANK|DIFFERENCE|" &
                    "EDGE_ID_FROM_PARTS|ENCRYPTBYASYMKEY|ENCRYPTBYCERT|ENCRYPTBYKEY|ENCRYPTBYPASSPHRASE|EOMONTH|ERROR_LINE|ERROR_MESSAGE|" &
                    "ERROR_NUMBER|ERROR_PROCEDURE|ERROR_SEVERITY|ERROR_STATE|EVENTDATA|EXP|FILEGROUPPROPERTY|FILEGROUP_ID|FILEGROUP_NAME|" &
                    "FILEPROPERTY|FILEPROPERTYEX|FILE_ID|FILE_IDEX|FILE_NAME|FIRST_VALUE|FLOOR|FORMAT|FORMATMESSAGE|" &
                    "FULLTEXTCATALOGPROPERTY|FULLTEXTSERVICEPROPERTY|GETANSINULL|GETDATE|GETUTCDATE|GET_BIT|" &
                    "GET_FILESTREAM_TRANSACTION_CONTEXT|GRAPH_ID_FROM_EDGE_ID|GRAPH_ID_FROM_NODE_ID|GREATEST|GROUPING|GROUPING_ID|" &
                    "HASHBYTES|HAS_DBACCESS|HAS_PERMS_BY_NAME|HOST_ID|HOST_NAME|IDENT_CURRENT|IDENT_INCR|IDENT_SEED|IIF|INDEXKEY_PROPERTY|" &
                    "INDEXPROPERTY|INDEX_COL|ISDATE|ISJSON|ISNULL|ISNUMERIC|IS_MEMBER|IS_OBJECTSIGNED|IS_ROLEMEMBER|IS_SRVROLEMEMBER|JSON|" &
                    "JSON_ARRAY|JSON_MODIFY|JSON_OBJECT|JSON_PATH_EXISTS|JSON_QUERY|JSON_VALUE|KEY_GUID|KEY_ID|KEY_NAME|LAG|LAST_VALUE|" &
                    "LEAD|LEAST|LEFT|LEFT_SHIFT|LEN|LOG|LOG10|LOGINPROPERTY|LOWER|LTRIM|MAX|MIN|MIN_ACTIVE_ROWVERSION|MONTH|NCHAR|NEWID|" &
                    "NEWSEQUENTIALID|NEXT VALUE FOR|NODE_ID_FROM_PARTS|NTILE|NULLIF|OBJECTPROPERTY|OBJECTPROPERTYEX|OBJECT_DEFINITION|" &
                    "OBJECT_ID|OBJECT_ID_FROM_EDGE_ID|OBJECT_ID_FROM_NODE_ID|OBJECT_NAME|OBJECT_SCHEMA_NAME|ORIGINAL_DB_NAME|" &
                    "ORIGINAL_LOGIN|PARSE|PARSENAME|PATINDEX|PERCENTILE_CONT|PERCENTILE_DISC|PERCENT_RANK|PERMISSIONS|PI|POWER|" &
                    "PUBLISHINGSERVERNAME|PWDCOMPARE|PWDENCRYPT|QUOTENAME|RADIANS|RAND|RANK|REPLACE|REPLICATE|REVERSE|RIGHT|RIGHT_SHIFT|" &
                    "ROUND|ROWCOUNT|ROWCOUNT_BIG|ROW_NUMBER|RTRIM|SCHEMA_ID|SCHEMA_NAME|SCOPE_IDENTITY|SERVERPROPERTY|SESSIONPROPERTY|" &
                    "SESSION_CONTEXT|SESSION_ID|SESSION_USER|SET_BIT|SIGN|SIGNBYASYMKEY|SIGNBYCERT|SIN|SMALLDATETIMEFROMPARTS|SOUNDEX|" &
                    "SPACE|SQL_VARIANT_PROPERTY|SQRT|SQUARE|STATS_DATE|STDEV|STDEVP|STR|STRING_AGG|STRING_ESCAPE|STRING_SPLIT|STUFF|" &
                    "SUBSTRING|SUM|SUSER_ID|SUSER_NAME|SUSER_SID|SUSER_SNAME|SWITCHOFFSET|SYMKEYPROPERTY|SYSDATETIME|SYSDATETIMEOFFSET|" &
                    "SYSTEM_USER|SYSUTCDATETIME|TAN|TERTIARY_WEIGHTS|TEXTPTR|TEXTVALID|TIMEFROMPARTS|TODATETIMEOFFSET|TRANSLATE|" &
                    "TRIGGER_NESTLEVEL|TRIM|TRY_CAST|TRY_CONVERT|TRY_PARSE|TYPEPROPERTY|TYPE_ID|TYPE_NAME|Trigger|UNICODE|UPPER|USER|" &
                    "USER_ID|USER_NAME|VAR|VARP|VERIFYSIGNEDBYASYMKEY|VERIFYSIGNEDBYCERT|XACT_STATE|YEAR|IDENTITY|POLYGON">

<!--- Sort functions by length --->
<CFSET SQLFunctions2=ArrayNew(1)>
<CFLOOP index="CurrFunction" list="#SQLFunctions#" delimiters="|">
	<CFSET ArrayAppend(SQLFunctions2,Replace(RJustify(CurrFunction,100)," ",".","All"))>
</CFLOOP>
<CFSET ArraySort(SQLFunctions2,"textnocase","desc")>
<CFSET SQLFunctions=ArrayToList(SQLFunctions2,"|")>
<CFSET SQLFunctions=Replace(SQLFunctions,".","","All")>

<!--- Variable used to hold placeholder strings that were matched and colorized --->
<CFSET Placeholder=ArrayNew(1)>

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

<CFSET SQLCode=Obj.Definition>
<CFSET OrgSQLCode=SQLCode>

<!--- Escape HTML in the code --->
<CFSET SQLCode=Replace(SQLCode,"<","&lt;","All")>
<CFSET SQLCode=Replace(SQLCode,">","&gt;","All")>

<!--- Fix line endings --->
<CFIF Find(Chr(13) & Chr(10),SQLCode)>
	<CFSET SQLCode=StripCR(SQLCode)>	<!--- Replace CRLF with LF --->
<CFELSE>
	<CFIF Find(Chr(13),SQLCode)>
		<CFSET SQLCode=Replace(SQLCode,Chr(13),Chr(10),"All")>	<!--- Replace just CR with LF --->
	</CFIF>
</CFIF>

<!--- Trim off leading & trailing white space --->
<CFLOOP condition="ListFind('10,13,9',Asc(Left(SQLCode,1)))">
	<CFSET SQLCode=Mid(SQLCode,2,Len(SQLCode))>
</CFLOOP>
<CFLOOP condition="ListFind('10,13,9',Asc(Right(SQLCode,1)))">
	<CFSET SQLCode=Left(SQLCode,Len(SQLCode) - 1)>
</CFLOOP>

<CFSET BracketStart="|">
<CFSET BracketEnd="|">

<!--- Highlight any search filter --->
<CFIF URL.SearchKey NEQ "">
	<CFSET P=ArrayLen(Placeholder) + 1>
	<CFSET Placeholder[P]="<span class=""Highlight"">" & URL.SearchKey & "</span>">
	<CFSET SQLCode=ReplaceNoCase(SQLCode,URL.SearchKey,"#BracketStart# Placeholder #P# #BracketEnd#","All")>
</CFIF>

<!--- Handle blank lines --->
<CFIF REFindNoCase("\n[\s\t]*\n",SQLCode)>
	<CFSET P=ArrayLen(Placeholder) + 1>
	<CFSET Placeholder[P]="<span class=""Commentt"">" & Chr(10) & Chr(10) & "</span>">
	<CFSET SQLCode=REReplace(SQLCode,"\n[\s\t]*\n","#BracketStart# Placeholder #P# #BracketEnd#","All")>
</CFIF>

<!--- Mark out comment blocks, regex can't fully handle nested blocks so let's do it the hard way --->
<CFSET OK=0>
<CFLOOP condition="NOT OK">
	<CFSET Loc1=Find("/*",SQLCode)>
	<CFSET Start=Loc1>
	<CFSET BlockCnt=Min(1,Loc1)>
	<CFLOOP Condition="BlockCnt GT 0">
		<CFSET Loc2=Find("/*",SQLCode,Loc1+2)>
		<CFSET Loc3=Find("*/",SQLCode,Loc1+2)>
		<CFIF Loc2 LT Loc3 AND Loc2 GT 0>
			<CFSET Loc1=Loc2>
			<CFSET BlockCnt=BlockCnt + 1>
		<CFELSEIF Loc3 LT Loc2 OR (Loc2 EQ 0 AND Loc3 GT 0)>
			<CFSET Loc1=Loc3>
			<CFSET End=Loc3>
			<CFSET BlockCnt=BlockCnt - 1>
		</CFIF>
	</CFLOOP>
	<CFIF Start GT 0 AND End GT Start>
		<!--- Got a comment block, mark it --->
		<CFSET CommentBlock=Mid(SQLCode,Start,End - Start + 2)>
		<CFSET CommentBlock2=CommentBlock>
		<CFLOOP index="i" from="1" to="#ListLen(CommentBlock2,Chr(10),'Yes')#">
			<CFSET Line=ListGetAt(CommentBlock2,i,Chr(10),"Yes")>
			<CFSET P=ArrayLen(Placeholder) + 1>
			<CFSET Placeholder[P]="<span class=""Comment"">" & Line & "</span>">
			<CFSET CommentBlock2=Replace(CommentBlock2,Line,"#BracketStart# Placeholder #P# #BracketEnd#")>
		</CFLOOP>
		<CFSET SQLCode=Replace(SQLCode,CommentBlock,CommentBlock2)>
	<CFELSE>
		<CFSET OK=1>
	</CFIF>
</CFLOOP>

<!--- Mark out single line comments --->
<CFSET NewCode="">
<CFLOOP index="i" from="1" to="#ListLen(SQLCode,Chr(10),"YES")#">
	<CFSET Line=ListGetAt(SQLCode,i,Chr(10),"YES")>
	<CFSET Loc=Find("--",Line)>
	<CFIF Loc GT 0>
		<CFSET P=ArrayLen(Placeholder) + 1>
		<CFIF Loc EQ 1>
			<CFSET Placeholder[P]="<span class=""Comment"">" & Line & "</span>">
			<CFSET Line="#BracketStart# Placeholder #P# #BracketEnd#">
		<CFELSE>
			<CFSET Placeholder[P]="<span class=""Comment"">" & Mid(Line,Loc,Len(Line)) & "</span>">
			<CFSET Line=Left(Line,Loc - 1) & "#BracketStart# Placeholder #P# #BracketEnd#">
		</CFIF>
	</CFIF>
	<CFSET NewCode=NewCode & Line & Chr(10)>
</CFLOOP>
<CFSET SQLCode=NewCode>

<!--- Identify the regex patterns and the CSS name to use --->
<CFSET Highlights=ArrayNew(2)>
<CFSET Highlights[1][1]="EXEC">
<CFSET Highlights[1][2]="\bEXEC(?:UTE)?\s+([\w\[\].]+)">
<CFSET Highlights[2][1]="SystemVars">
<CFSET Highlights[2][2]="@@[\w##]+">
<CFSET Highlights[3][1]="Vars">
<CFSET Highlights[3][2]="@[\w##]+">
<CFSET Highlights[4][1]="TableJoins">
<CFSET Highlights[4][2]="\b(JOIN|INNER JOIN|LEFT JOIN|RIGHT JOIN|FULL JOIN|CROSS JOIN|OUTER JOIN)\s">

<CFLOOP index="h" from="1" to="#ArrayLen(Highlights)#">
	<CFSET Matches=REMatchNoCase(Highlights[h][2],SQLCode)>
	<CFLOOP index="i" from="1" to="#ArrayLen(Matches)#">
		<CFSET P=ArrayLen(Placeholder) + 1>
		<CFSET Placeholder[P]="<span class=""#Highlights[h][1]#"">" & Matches[i] & "</span>">
		<CFSET SQLCode=Replace(SQLCode,Matches[i],"#BracketStart# Placeholder #P# #BracketEnd#")>
	</CFLOOP>
</CFLOOP>

<!--- Fetch all table references in SQL --->
<CFSET SQLTables=REMatchNoCase("\bFROM\s+([\w\[\].]+)|\bJOIN\s+([\w\[\].]+)|\bINTO\s+([\w\[\].]+)|@[\w]+(?=\s*TABLE)|\bEXEC\s+([\w\[\].]+)|\bUPDATE\s+([\w\[\].]+)",SQLCode)>
<CFSET SQLTables2=REMatchNoCase("\b(?:FROM|JOIN|INTO|EXEC|UPDATE)\s+(?:\[[^\]]+\]|""[^""]+""|\b\w+\b)(?:\.(?:\[[^\]]+\]|""[^""]+""|\b\w+\b)){0,2}",SQLCode)>
<CFLOOP index="i" from="1" to="#ArrayLen(SQLTables2)#">
	<CFSET ArrayAppend(SQLTables,SQLTables2[i])>
</CFLOOP>

<!--- Remove duplicates between the two matches --->
<CFSET Dedupe=ArrayToList(SQLTables,"|")>
<CFSET Dedump=ListRemoveDuplicates(Dedupe,"|")>
<CFSET SQLTables=ListToArray(Dedump,"|")>
<CFLOOP index="i" from="1" to="#ArrayLen(SQLTables)#">
	<!--- Remove first word from string --->
	<CFSET Loc=ReFind("\s",SQLTables[i])>
	<CFIF Loc GT 1>
		<CFSET P=ArrayLen(Placeholder) + 1>
		<CFSET Placeholder[P]=Left(SQLTables[i],Loc - 1) & "<span class=""Table"">" & Mid(SQLTables[i],Loc,Len(SQLTables[i])) & "</span>">
		<CFSET SQLCode=Replace(SQLCode,SQLTables[i],"#BracketStart# Placeholder #P# #BracketEnd#","All")>
	</CFIF>
</CFLOOP>

<!--- Fech all functions parans and highlight --->
<CFSET Matches=REMatchNoCase("\b(#SQLFunctions#)\s*\(",SQLCode)>
<CFLOOP index="i" from="1" to="#ArrayLen(Matches)#">
	<!--- Find first paren --->
	<CFSET P=ArrayLen(Placeholder) + 1>
	<CFSET Placeholder[P]="<span class=""Function"">" & Left(Matches[i],Len(Matches[i]) - 1) & "</span>(">
	<CFSET SQLCode=Replace(SQLCode,Matches[i],"#BracketStart# Placeholder #P# #BracketEnd#")>
</CFLOOP>

<!--- Fech all field types with parans and highlight --->
<CFSET Matches=REMatchNoCase("\b(#FieldTypes#)\s*\(",SQLCode)>
<CFLOOP index="i" from="1" to="#ArrayLen(Matches)#">
	<!--- Find first paren --->
	<CFSET P=ArrayLen(Placeholder) + 1>
	<CFSET Placeholder[P]="<span class=""FieldTypes"">" & Left(Matches[i],Len(Matches[i]) - 1) & "</span>(">
	<CFSET SQLCode=Replace(SQLCode,Matches[i],"#BracketStart# Placeholder #P# #BracketEnd#")>
</CFLOOP>

<!--- Fech all field types with no params and highlight --->
<CFSET Matches=REMatchNoCase("(\b|\s)(#FieldTypesNoParan#)(\b|\W|\s)",SQLCode)>
<CFLOOP index="i" from="1" to="#ArrayLen(Matches)#">
	<!--- Find first paren --->
	<CFSET P=ArrayLen(Placeholder) + 1>
		<CFSET Placeholder[P]="<span class=""FieldTypes"">#Matches[i]#</span>">
	<CFSET SQLCode=Replace(SQLCode,Matches[i],"#BracketStart# Placeholder #P# #BracketEnd#")>
</CFLOOP>

<!--- Replace placeholders with the code --->
<CFSET Loop=0>
<CFLOOP condition="Find('#BracketStart# Placeholder ',SQLCode)">
	<CFSET Loop=Loop + 1>
	<CFIF Loop GT 10>
		<CFBREAK>
	</CFIF>
	<CFLOOP index="i" from="1" to="#ArrayLen(Placeholder)#">
		<CFSET SQLCode=Replace(SQLCode,"#BracketStart# Placeholder #i# #BracketEnd#",Placeholder[i],"All")>
	</CFLOOP>
</CFLOOP>

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
.Table {color:magenta; !important}
.Comment {color:green; !important}
.EXEC {color:red; !important}
.Vars {color:##22f; !important}
.Function {color:brown; !important}
.TableJoins {color:gray; !important}
.FieldTypes {color:blue; !important}
.SystemVars {color:magenta; !important}
.Highlight {background:yellow; !important}
.LineNo {
	background-color:white;
	color:black;
	-webkit-touch-callout: none; /* iOS Safari */
	-webkit-user-select: none; /* Safari */
	-khtml-user-select: none; /* Konqueror HTML */
	-moz-user-select: none; /* Old versions of Firefox */
	-ms-user-select: none; /* Internet Explorer/Edge */
	user-select: none; /* Non-prefixed version, currently supported by Chrome, Edge, Opera and Firefox */
}
</head>
</style>
<body>
<CFSET Title="#Obj.ObjType# #ObjInfo.Database#.#ObjInfo.SchemaName#.#ObjInfo.ObjectName#">
<span class="Title">#EncodeForHTML(Title)#</span><br>
Last Updated: #DateTimeFormat(Obj.Modify_Date,"mmmm d, yyyy h:nn:ss tt")#<br>
<br>
<div class="Code">
</CFOUTPUT>

<CFSET Test1=REReplace(OrgSQLCode,"\s","","All")>
<CFSET Test2=REReplace(SQLCode,"\s","","All")>
<CFSET Test2=Replace(Test2,"&lt;","<","All")>
<CFSET Test2=Replace(Test2,"&gt;",">","All")>
<CFSET Test2=REReplace(Test2,"<spanclass.+?>","","All")>
<CFSET Test2=Replace(Test2,"</span>","","All")>
<CFIF Test1 NEQ Test2>
	<CFOUTPUT>
<pre>#encodeforhtml(Test1)#
<pre>#encodeforhtml(Test2)#</pre>
	</CFOUTPUT>
</CFIF>
<!--- Output SQL --->
<CFSET TotalLines=ListLen(SQLCode,Chr(10),true)>
<CFLOOP index="i" from="1" to="#TotalLines#">
	<!--- Get current line and perform some pre-formmatting for display --->
	<CFSET Line=ListGetAt(SQLCode,i,Chr(10),true)>
	<CFSET Line=Replace(Line,Chr(9),"    ","All")>
	<CFOUTPUT><span class="LineNo">#Replace(RJustify(i,Len(TotalLines))," ","&nbsp;","All")#&nbsp;</span><span class="Code">#Line#</span>#Chr(10)#</CFOUTPUT>
</CFLOOP>

<CFOUTPUT>
</div>
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
