<cfcomponent displayname="ProgramTree" output="true" hint="Display a hirahierarchy tree">

	<!--- Set up the application. --->
	<CFSET THIS.Name="ProgramTree">
	<CFSET THIS.ApplicationTimeout = CreateTimeSpan( 0, 0, 10, 0 ) />
	<CFSET THIS.SessionManagement=false>
	<CFSET THIS.SetClientCookies=false>
	<CFSET THIS.serialization.preserveCaseForStructKey=true>

	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false" hint="Fires at first part of page processing.">

		<!--- Define arguments. --->
		<cfargument name="TargetPage" type="string" required="true"
			/>

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>


	<cffunction name="OnRequest" access="public" returntype="void" output="true" hint="Calls the page to execute">

		<!--- Define arguments. --->
		<cfargument name="TargetPage" type="string" required="true"/>

		<CFSET DSN="mssql"> <!--- Microsoft Access Datasource name --->

		<!--- If specified, only the following databases will be included for display. Comma delimited, no spaces --->
		<CFSET ShowOnlyDatabases="">

		<!--- If specified, only the following databases will be excluded. This is ignored if ShowOnlyDatabases is populated. Comma delimited, no spaces --->
		<CFSET ExcludeDatabases="">

		<cfsetting enablecfoutputonly=true>

		<!--- Include the requested page. --->
		<cfinclude template="#ARGUMENTS.TargetPage#" />

		<!--- Return out. --->
		<cfreturn />
	</cffunction>

</cfcomponent>
