Sub Usage
    WScript.Echo "ASP-CTL database patch tool ver. 1.0"
    WScript.Echo "  Applies patches generated with patchgen.vbs to a database"
    WScript.Echo "Usage: cscript patch.vbs <patch> <database> [all]"
    WScript.Echo "  <patchdir>  - The directory containing patches generated"
    WScript.Echo "                with patchgen.vbs."
    WScript.Echo "  <database>  - The name of the database file"
    WScript.Echo "  all         - optional. Apply all patches sequentially."
    WScript.Echo "  Example:"
    WScript.Echo "  cscript patch.vbs c:\myapppatches c:\inetpub\sitex\appx\db\appdb.db"
    WScript.Echo "  "
    WScript.Echo "  Remarks: At a single step the tools will apply only the "
    WScript.Echo "  patch for the current version of the schema in the database"
    WScript.Echo "  specified. The schema version is determined from the VER"
    WScript.Echo "  field of the DBVERSION table."
    WScript.Echo "  The patch file for that version is named #.sql whrere #"
    WScript.Echo "  is the version number. The tool searches the specified"
    WScript.Echo "  patch directory for that file and if found applies it."
    WScript.Echo "  If the all option is specified the process continues"
    WScript.Echo "  recursively until no more patches can be found."
    WScript.Echo "  "
    WScript.Echo "  Note that non-consecutive schema version patches cannot"
    WScript.Echo "  be applied with this tool."
End Sub

Set sf = CreateObject("newObjects.utilctls.SFMain")
Set db = CreateObject("newObjects.sqlite3.dbutf8")

If WScript.Arguments.length < 2 Then
    Usage
    WScript.Quit(10000)
End If

Dim AllOption
AllOption = False

If WScript.Arguments.length > 2 Then
    If UCase(WScript.Arguments(2)) = "ALL" Then
        WScript.Echo "+ all option found."
        AllOption = True
    End If
End If

If sf.Exists(WScript.Arguments(1)) <> 1 Then
    WScript.Echo "Error: Database file not found."
    WScript.Quit(3)
    WScript.Quit
End If

Function GetVersion(db)
    Dim r
    Set r = db.Execute("SELECT [VER] FROM DBVERSION LIMIT 1")
    If r.Count > 0 Then
        GetVersion = CLng(r(1)(1))
    Else
        GetVersion = 0
    End If
End Function

Function GetPatchForVer(v)
    Dim dir, files, f
    GetPathchForVer = Empty
    Set dir = sf.OpenDirectory( WScript.Arguments(0), &H40)
    Set files = dir.contents
    For Each f in files
        If f.Type = 2 And UCase(f.name) = UCase(v & ".sql") Then
            Set f = dir.OpenStream(f.name, &H40)
            GetPatchForVer = f.ReadText(-2)
            Exit Function
        End If
    Next
End Function

WScript.Echo "+ opening the database"
If Not db.Open(WScript.Arguments(1)) Then
    WScript.Echo "Error: Cannot open the database"
    WScript.Echo "  SQLite last error: " & db.LastError
    WScript.Quit(1)
End If
db.BusyTimeout = 30000

Dim GlobalErrorState
GlobalErrorState = 0


Function SinglePatch
    Dim PatchSQL, ver
    SinglePatch = False
    ver = GetVersion(db)
    WScript.Echo "+ Database schema version is: " & ver
    WScript.Echo "  + Looking for a patch"
    On Error Resume Next
    PatchSQL = GetPatchForVer(ver)
    If Err.Number <> 0 Then
        WScript.Echo "Error: Cannot find/load patch"
        WScript.Echo "  Error reported: " & Err.Description
        GlobalErrorState = 2
        Exit Function
    ElseIf Len(PatchSQL) = 0 Then
        WScript.Echo "  + No patch is found for the current schema version"
        Exit Function
    End If
    
    WScript.Echo "  + patch found"
    WScript.Echo "  + starting trasnaction"
    db.Execute "BEGIN TRANSACTION"
    WScript.Echo "  + executing the patch over the database"
    db.Execute PatchSQL
    If Err.Number <> 0 Then
        WScript.Echo "Error: Patch SQL failed."
        WScript.Echo "  Error reported: " & Err.Description
        WScript.Echo "  SQLite last error: " & db.LastError
        WScript.Echo "- rolling back"
        db.Execute "ROLLBACK TRANSACTION"
        GlobalErrorState = 10
    Else
        WScript.Echo "  + commiting the changes. Please wait."
        db.Execute "COMMIT TRANSACTION"
        WScript.Echo "  + done"
        ver = GetVersion(db)
        WScript.Echo "  + schema version is now: " & ver
        SinglePatch = True
    End If
End Function


While SinglePatch And AllOption And GlobalErrorState = 0
    WScript.Echo "+ Attmpting the next patch ---------"
Wend
If GlobalErrorState <> 0 Then 
    WScript.Echo "- some errors have occured."
Else
    WScript.Echo "Done!"
End If

WScript.Quit(GlobalErrorState)
