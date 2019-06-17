Set sf = CreateObject("newObjects.utilctls.SFMain")
Set db = CreateObject("newObjects.sqlite3.dbutf8")
Dim DeleteTarget
DeleteTarget = False

Sub Usage
    WScript.Echo "ASP-CTL database creator ver. 1.0"
    WScript.Echo "  Creates a database from a schema file."
    WScript.Echo "Usage: cscript createdb.vbs <schema> <database> [delete]"
    WScript.Echo "  <schema>    - The schema SQL file"
    WScript.Echo "  <database>  - The name of the database file"
    WScript.Echo "  delete      - optional. If specified the target"
    WScript.Echo "          database file is deleted if exists."
    WScript.Echo "  Example:"
    WScript.Echo "  cscript createdb.vbs c:\myschema.sql c:\inetpub\sitex\appx\db\appdb.db"
    WScript.Echo "  If the database file exists nothing will be done and error is issued."
End Sub

If WScript.Arguments.length < 2 Then
    Usage
    WScript.Quit
End If

If WScript.Arguments.length > 2 Then
    If UCase(WScript.Arguments(2)) = "DELETE" Then
        WScript.Echo "+ delete option specified (target will be deleted if exists)"
        DeleteTarget = True
    End If
End If

Dim SchemaSQL

Function LoadSchema
    Dim f
    WScript.Echo "+ loading the schema SQL"
    On Error Resume Next
    Set f = sf.OpenFile(WScript.Arguments(0),&H40)
    If Err.Number <> 0 Then
        WScript.Echo "Error: Cannot open the schema file."
        WScript.Echo "  Error description: " & Err.Description
        WScript.Quit
    End If
    SchemaSQL = f.ReadText(-2)
    ' Test the schema
    WScript.Echo "+ testing the schema for errors"
    db.Open ""
    db.Execute SchemaSQL
    If Err.Number <> 0 Then
        WScript.Echo "Error: The schema SQL has errors."
        WScript.Echo "  Error reported: " & Err.Description
        WScript.Echo "  SQLite last error: " & db.LastError
        WScript.Quit
    End If
    db.Close
    WScript.Echo "+ schema loaded and checked"
End Function

LoadSchema

If sf.FileExists(WScript.Arguments(1)) Then
    WScript.Echo "+ the target exists"
    If DeleteTarget Then
        sf.DeleteFile WScript.Arguments(1), True
        WScript.Echo "+ the target has been deleted"
    Else
        WScript.Echo "Error: The specified database file already exists."
        WScript.Quit
    End If
End If

Sub InitDatabase
    WScript.Echo "+ opening the new database"
    db.Open WScript.Arguments(1)
    db.BusyTimeout = 30000
    WScript.Echo "+ executing the schema over the database"
    db.Execute SchemaSQL
    db.Close
    WScript.Echo "Done!"
End Sub

InitDatabase


