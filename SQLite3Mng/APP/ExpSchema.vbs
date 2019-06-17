Context("Complete") = False


Dim db
Set db = Context("db")

Dim sf
Set sf = Creator.CreateObject("SFMain")
Dim file
Set file = sf.CreateFile(Context("File"))

file.WriteText "-- Export pf SQLite3 COM database schema", 1
file.WriteText "-- To import it you can paste the contents of this file into the SQL console", 1
file.WriteText "-- or pass it programmatically to the Execute method", 1
file.WriteText "", 1
file.WriteText "-- Export created on: " & Now, 1
file.WriteText "", 1

Set rt = db.Execute("SELECT * FROM sqlite_master ORDER BY ((type='table') + (type='view') * 2 + (type='index') * 3 + (type='trigger') * 4)")
For T = 1 To rt.Count
    If UCase(Left(rt(T)("name"),9)) <> "SYSDBMAN_" Then
        file.WriteText "-- " & rt(T)("type") & ":" & rt(T)("name"), 1
        file.WriteText rt(T)("sql") & ";", 1
        file.WriteText "", 1    
    End If
Next

file.Close

Context("Complete") = True