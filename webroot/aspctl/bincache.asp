<%
    ' This class implements caching of binary data (most often images) in a separate database
    ' The cached data chunks are hashed by two values: ID and ASPECT. The ID is usually the id
    ' of the cached object and the ASPECT is the aspect cached, for example small icon aspect, 
    ' normal icon aspect and so on.
    
    Class CBinaryCache
        Private m_db
        Public DatabaseFile ' The virtual path to the database file
        Sub Class_Initialize
            Set m_db = Nothing
        End Sub
        
        Private Sub CheckStructure
            Dim r
            Set r = Database.DB.Execute("SELECT * FROM SQLITE_MASTER WHERE NAME='CACHE'")
            If r.Count = 0 Then
                ' Create the structure
                m_db.Execute "CREATE TABLE IF NOT EXISTS CACHE (ID NOT NULL, ASPECT NOT NULL, DATA, UNIQUE(ID,ASPECT) ON CONFLICT REPLACE);"
            End If
        End Sub
        Private Sub OpenCacheDB
            If m_db Is Nothing Then
                Set m_db = Server.CreateObject("newObjects.sqlite3.dbutf8")
                m_db.Open MapPath(DatabaseFile)
                m_db.BusyTimeout = 30000 ' This should be ok for almost any possible use, even if the db fails 
                                         ' sometimes the only problem is that for the moment the item will not be cached.
                CheckStructure
            End If
        End Sub
        
        Public Function DB
            OpenCacheDB
            Set DB = m_db
        End Function
        
        Public Default Property Get Element(Id,Aspect)
            Dim r
            On Error Resume Next
            Element = Null
            Set r = DB.VExecute("SELECT DATA FROM CACHE WHERE ID=$ID AND ASPECT=$ASPECT",1,1,NullConvertTo(vbString,Id),NullConvertTo(vbString,Aspect))
            If r.Count > 0 Then
                Element = r(1)(1)
            End If
        End Property
        Public Property Let Element(Id,Aspect,v)
            On Error Resume Next
            DB.VExecute "INSERT INTO CACHE (ID,ASPECT,DATA) VALUES ($ID,$ASPECT,$DATA)",1,0,NullConvertTo(vbString,Id),NullConvertTo(vbString,Aspect),v
        End Property
        
        Public Sub ClearCache
            DB.Execute "DELETE FROM CACHE;VACUUM;"
        End Sub
        Public Sub ClearAspect(Aspect)
            DB.VExecute "DELETE FROM CACHE WHERE ASPECT=$ASPECT", 1, 0, NullConvertTo(vbString,Aspect)
        End Sub
        Public Sub Remove(Id)
            On Error Resume Next
            DB.VExecute "DELETE FROM CACHE WHERE ID=$ID",1,0,NullConvertTo(vbString,Id)
        End Sub
        
    End Class

%>