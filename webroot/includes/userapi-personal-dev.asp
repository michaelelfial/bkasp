<%
	' This file containes code that enables support of custom databases outside the main code base (in a mapped virtual directory for instance).
	Const customDatabasesPath = "/custom/databases/"
	Const customPatchesPath = "/custom/patches/"
	Const customScriptsPath = "/custom/scripts/"
	Const customViewsPath = "/custom/views/"
	Dim regularAppPaths, modularAppPath
	regularAppPaths = "/apps/scripts/;/examples/scripts/;/test/scripts/;" & customScriptsPath
	modularAppPath = "/apps/modular/"
	
	Dim CustomDatabases
	Set CustomDatabases = CreateDictionary
	' Handlers
	Function CustomDatabaseSelector(db)
		Dim dbname, dbpath
		dbname = db.CustomData("customdbname")
		If dbname <> "" And InStr(dbname,"\") = 0 And InStr(dbname,"/") = 0 Then
			dbpath = db.CustomData("customdbpath")
			If IsNull(dbpath) Or IsEmpty(dbpath) Then
				CustomDatabaseSelector = customDatabasesPath & db.CustomData("customdbname") & ".db"
			Else
				'If Right(dbpath,1) <> "\" Then dbpath = dbpath & "\"
				CustomDatabaseSelector = dbpath & db.CustomData("customdbname") & ".db"
			End If
		Else
			CustomDatabaseSelector = ""
			Err.Raise 11, "CustomDatabaseSelector", "Database name is incorrect"
		End If
	End Function
	Function CustomDatabasePermitter(db)
		CustomDatabasePermitter = True
	End Function
	Sub InitCustomDatabaseConnection(db, cdb)
		Dim dbname, dbverreq, dbpath, dbpatches
		dbname = cdb.CustomData("customdbname")
		dbverreq = cdb.CustomData("customdbver")
		dbpatches = cdb.CustomData("custompatchpath")
		db.Parameters("USER_ID") = CurrentUser.Id
        db.Parameters("GROUP_ID") = CurrentUser.GroupId
        db.Parameters("LANGUAGE") = PageUILanguage
        db.Parameters("USER_LEVEL") = CurrentUser.Level
        If cDatabaseNoTempFiles Then 
            db.Execute "PRAGMA temp_store=2;"
        End If
		Dim updater
		Set updater = New CSQlitePatcher
		Set updater.Db = db
		If IsNull(dbpatches) Or IsEmpty(dbpatches) Then
			updater.PatchesPath = customPatchesPath & dbname		
		Else 
			updater.PatchesPath = dbpatches & dbname		
		End If
		if Not IsNull(dbverreq) And Not IsEmpty(dbverreq) Then
			If dbverreq >= 0 Then
				If Not updater.PatchTo(dbverreq) Then
						Err.Raise 1, "InitCustomDatabaseConnection", "Cannot patch database " & dbname & " to the required schema version " & dbverreq
				End If
				Exit Sub
			End If
		End If
		If Not updater.PatchMax() Then
				Err.Raise 1, "InitCustomDatabaseConnection", "Cannot patch database " & dbname & " to the latest schema version."
		End If
	End Sub
	
	
	
	Function CustomDatabase(dbname, dbpath, patchespath)
		Dim db
		Set db = Nothing
		If Not IsNull(dbName) And Not IsEmpty(dbname) Then
			If CustomDatabases.KeyExists(dbname) Then
				If IsObject(CustomDatabases(dbname)) Then
					Set db = CustomDatabases(dbname)
				End If
			End If
		Else
			Err.Raise 1, "CustomDatabase", "The database name must not be null or empty."
			Exit Function
		End If
		If db Is Nothing Then
			Set db = New CDatabase
			Set db.DatabaseOpener = GetRef("CustomDatabaseSelector")
			Set db.AccessPermitter = GetRef("CustomDatabasePermitter")
			db.SessionInitializer = "InitCustomDatabaseConnection"
			db.CustomData("customdbname") = dbname
			db.CustomData("customdbpath") = dbpath
			db.CustomData("custompatchpath") = patchespath
		End If
		Set CustomDatabase = db
	End Function
	
%>