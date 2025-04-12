<CFTRY>

<!--- All SQL Server functions for color formatting --->
<CFSET SQLFunctions=
"ABS
ACOS
APP_NAME
ASCII
ASIN
ATAN
ATN2
AVG
CEILING
CHAR
CHARINDEX
CHECKSUM_AGG
CHOOSE
COALESCE
COL_LENGTH
COL_NAME
CONCAT
CONCAT_WS
CONVERT
COS
COT
COUNT
CURRENT_TIMESTAMP
DATALENGTH
DATEADD
DATEDIFF
DATEDIFF_BIG
DATEFROMPARTS
DATENAME
DATEPART
DAY
DEGREES
DIFFERENCE
EOMONTH
ERROR_MESSAGE
ERROR_NUMBER
ERROR_SEVERITY
ERROR_STATE
EXP
FLOOR
FORMAT
FORMATMESSAGE
GETANSINULL
GETDATE
GETUTCDATE
HOST_ID
HOST_NAME
IIF
ISDATE
ISNULL
ISNUMERIC
LEFT
LEN
LOG
LOG10
LOWER
LTRIM
MAX
MIN
MONTH
NEWID
NEWSEQUENTIALID
NCHAR
NULLIF
PARSE
PARSENAME
PATINDEX
PI
POWER
QUOTENAME
RADIANS
RAND
REPLACE
REPLICATE
REVERSE
RIGHT
ROUND
ROWCOUNT
RTRIM
SESSION_USER
SESSIONPROPERTY
SIGN
SIN
SOUNDEX
SPACE
SQRT
SQUARE
STDEV
STDEVP
STR
STRING_AGG
STRING_ESCAPE
STRING_SPLIT
STUFF
SUBSTRING
SUM
SUSER_ID
SUSER_NAME
SUSER_SNAME
SYSDATETIME
SYSDATETIMEOFFSET
SYSUTCDATETIME
SYSTEM_USER
TAN
TIMEFROMPARTS
TODATETIMEOFFSET
TRANSLATE
TRIM
TRY_CAST
TRY_CONVERT
UNICODE
UPPER
USER_NAME
VAR
VARP
YEAR">
<CFSET SQLFunctions=Replace(StripCR(SQLFunctions),Chr(10),"|","All")>


<!--- Variable used to hold placeholder strings that were matched and colorized --->
<CFSET Placeholder=ArrayNew(1)>

<CFPARAM NAME="URL.id" default="">
<cflock scope="Application" type="readonly" timeout="5">
	<CFSET ObjData=Duplicate(Application.Obj)>
</cflock>

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
<!--- Fix line endings --->
<CFIF Find(Chr(13) & Chr(10),SQLCode)>
	<CFSET SQLCode=StripCR(SQLCode)>	<!--- Replace CRLF with LF --->
<CFELSE>
	<CFIF Find(Chr(13),SQLCode)>
		<CFSET SQLCode=Replace(SQLCode,Chr(13),Chr(10),"All")>	<!--- Replace just CR with LF --->
	</CFIF>
</CFIF>
<!--- Trim off leading white space --->
<CFSET Loc=REFind("\S",SQLCode)>
<CFIF Loc GT 1>
	<CFSET SQLCode=Mid(SQLCode,Loc,Len(SQLCode))>
</CFIF>

<!--- Mark out single line comments --->
<CFSET NewCode="">
<CFLOOP index="i" from="1" to="#ListLen(SQLCode,Chr(10),"YES")#">
	<CFSET Line=ListGetAt(SQLCode,i,Chr(10),"YES")>
	<CFSET Loc=Find("--",Line)>
	<CFIF Loc GT 0>
		<CFSET P=ArrayLen(Placeholder) + 1>
		<CFIF Loc EQ 1>
			<CFSET Placeholder[P]="<span class=""Comment"">" & Line & "</span>">
			<CFSET Line="[[[[ Placeholder #P# ]]]]">
		<CFELSE>
			<CFSET Placeholder[P]="<span class=""Comment"">" & Mid(Line,Loc,Len(Line)) & "</span>">
			<CFSET Line=Left(Line,Loc - 1) & "[[[[ Placeholder #P# ]]]]">
		</CFIF>
	</CFIF>
	<CFSET NewCode=NewCode & Line & Chr(10)>
</CFLOOP>
<CFSET SQLCode=NewCode>

<!--- Identify the regex patterns and the CSS name to use --->
<CFSET Highlights=ArrayNew(2)>
<CFSET Highlights[1][1]="Comment">
<CFSET Highlights[1][2]="/\*[\s\S]*?\*/">
<CFSET Highlights[2][1]="EXEC">
<CFSET Highlights[2][2]="\bEXEC(?:UTE)?\s+([\w\[\].]+)">
<CFSET Highlights[3][1]="Vars">
<CFSET Highlights[3][2]="@[\w##]+">
<CFSET Highlights[4][1]="TableJoins">
<CFSET Highlights[4][2]="\b(JOIN|INNER JOIN|LEFT JOIN|RIGHT JOIN|FULL JOIN|CROSS JOIN|OUTER JOIN)\s">

<CFLOOP index="h" from="1" to="#ArrayLen(Highlights)#">
	<CFSET Matches=REMatchNoCase(Highlights[h][2],SQLCode)>
	<CFLOOP index="i" from="1" to="#ArrayLen(Matches)#">
		<CFSET P=ArrayLen(Placeholder) + 1>
		<CFSET Placeholder[P]="<span class=""#Highlights[h][1]#"">" & Matches[i] & "</span>">
		<CFSET SQLCode=Replace(SQLCode,Matches[i],"[[[[ Placeholder #P# ]]]]")>
	</CFLOOP>
</CFLOOP>

<!--- Fetch all table references in SQL --->
<CFSET SQLTables=REMatchNoCase("\bFROM\s+([\w\[\].]+)|\bJOIN\s+([\w\[\].]+)|\bINTO\s+([\w\[\].]+)|@[\w]+(?=\s*TABLE)|\bEXEC\s+([\w\[\].]+)|\bUPDATE\s+([\w\[\].]+)",SQLCode)>
<CFLOOP index="i" from="1" to="#ArrayLen(SQLTables)#">
	<!--- Remove first word from string --->
	<CFSET Loc=ReFind("\s",SQLTables[i])>
	<CFSET P=ArrayLen(Placeholder) + 1>
	<CFSET Placeholder[P]=Left(SQLTables[i],Loc - 1) & "<span class=""Table"">" & Mid(SQLTables[i],Loc,Len(SQLTables[i])) & "</span>">
	<CFSET SQLCode=Replace(SQLCode,SQLTables[i],"[[[[ Placeholder #P# ]]]]","All")>
</CFLOOP>


<!--- Fech all functions and highlight --->
<CFSET Matches=REMatchNoCase("\b(#SQLFunctions#)\s*\(\s*([^)]*)\s*\)",SQLCode)>
<CFLOOP index="i" from="1" to="#ArrayLen(Matches)#">
	<!--- Find first paren --->
	<CFSET Loc=Find("(",Matches[i])>
	<CFSET P=ArrayLen(Placeholder) + 1>
	<CFSET Placeholder[P]="<span class=""Function"">" & Left(Matches[i],Loc) & "</span>" & Mid(Matches[i],Loc,Len(Matches[i]) - Loc) & "<span class=""Function"">)</span>">
	<CFSET SQLCode=Replace(SQLCode,Matches[i],"[[[[ Placeholder #P# ]]]]")>
</CFLOOP>

<!--- Replace placeholders with the code --->
<CFLOOP condition="Find('[[[[ Placeholder ',SQLCode)">
	<CFLOOP index="i" from="1" to="#ArrayLen(Placeholder)#">
		<CFSET SQLCode=Replace(SQLCode,"[[[[ Placeholder #i# ]]]]",Placeholder[i],"All")>
	</CFLOOP>
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

<!--- Output SQL --->
<CFSET TotalLines=ListLen(SQLCode,Chr(10),true)>
<CFLOOP index="i" from="1" to="#TotalLines#">
	<!--- Get current line and perform some pre-formmatting for display --->
	<CFSET Line=ListGetAt(SQLCode,i,Chr(10),true)>
	<CFSET Line=Replace(Line,Chr(9),"&nbsp;&nbsp;&nbsp;&nbsp;","All")>
	<CFOUTPUT><span class="LineNo">#Replace(RJustify(i,Len(TotalLines))," ","&nbsp;","All")#&nbsp;</span><span class="Code">#Line#</span><br></CFOUTPUT>
</CFLOOP>
<CFOUTPUT>
</div>
</body>
</html>
</CFOUTPUT>


<cfcatch type="any"><cfdump var=#cfcatch#></cfcatch></cftry>