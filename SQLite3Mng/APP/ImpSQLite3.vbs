Context("Complete") = False
Dim su
Set su = Creator.CreateObject("StringUtilities")
Const dbName = "SysDBMan_Import"

Dim db
Set db = Context("db")
db.Execute su.Sprintf("ATTACH DATABASE %q AS %s",Context("File"),dbName)



Set rt = db.Execute( su.Sprintf("SELECT *, CASE type WHEN 'table' THEN 1 ELSE 0 END AS ordtag FROM %s.sqlite_master ORDER BY ordtag DESC",dbName))
On Error Resume Next
For T = 1 To rt.Count
    If Not IsNull(rt(T)("sql")) Then
        db.Execute rt(T)("sql")
        Context("Progress") = su.Sprintf("Creating %s %s",rt(T)("type"),rt(T)("name"))
        If rt(T)("type") = "table" Then
            Context("Progress") = "Importing data for table " & rt(T)("name")
            db.Execute su.Sprintf("INSERT INTO [%s] SELECT * FROM %s.[%s]",rt(T)("name"),dbName,rt(T)("name"))
        End If
    End If
Next
On Error Goto 0

db.Execute su.Sprintf("DETACH DATABASE %s",dbName)

Context("Complete") = True
