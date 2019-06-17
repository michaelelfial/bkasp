<%
    ' Package:  UserAPI 
    ' Version:  2011-04-10
    ' File:     userapi-indexer.asp
    ' Description:
    '   Provides full text indexing and searching routines
    
    
    ' INDEXING Related ==========================
    
    Const KeywordSplitPattern = "[^\;\,\.\:\!\~\`\$\#\%\^\&\*\(\)\[\]\{\}\?\/\\\+\-\=\|\""\'\<\>\s]{2,20}"
    
    ' Adds the keywords found and links to the sid in the link table
    Function AddKeywords(textIn,sid)
        Dim m, re, matches, w, text
        AddKeywords = False
        text = ConvertTo(vbString, textIn)
        If Len(text) < 2 Then Exit Function
        If Database.BeginTransaction Then
        On Error Resume Next
        Err.Clear
            Set re = New RegExp
            re.Pattern = KeywordSplitPattern
            re.Global = True
            Set matches = re.Execute(text)
            For Each m In matches
                w = UCase(m.Value)
                ' Database.DB.VExecute("SELECT ID FROM KEYWORD WHERE WORD=$WORD
                Database.DB.VExecute "INSERT INTO KEYWORD (WORD) VALUES ($WORD)", 1, 0, w
                Database.DB.VExecute "INSERT INTO OBJECT_KEYWORD (OBJECT_SID,KEYWORD_ID) SELECT $SID, ID FROM KEYWORD WHERE WORD=$WORD;", 1, 0, NullConvertTo(vbLong, sid), w
            Next
            If Database.CompleteTransaction Then
                AddKeywords = True
            End If
        End If
    End Function
    Function AddNomenclatureKeywords(nom, nomSid, fieldName, sid)
        Dim r, I
        Set r = Database.DB.VExecute("SELECT * FROM [" & nom & "] WHERE SID=$sid", 1, 0 , NullConvertTo(vbLong,nomSid))
        For I = 1 To r.Count
            AddKeyWords r(I)(fieldName), sid
        Next
    End Function
    
    ' Search related ============================
    
    ' Internal use
    ' coll - keywords as keys, the values must be Boolean - True the keyword must be present, False the keyword must not be present
    ' bPos - include in the output the must present keywords
    ' bNeg - include in the output the must not present keywords
    Function WordsCollectionToDBList(coll,bPos,bNeg)
        Dim I, s
        s = ""
        For I = 1 To coll.Count
            If bPos And coll(I) Then
                If Len(s) > 0 Then s = s & ","
                s = s & "'" & UCase(Replace(coll.Key(I),"'","''")) & "'"
            ElseIf bNeg And Not coll(I) Then
                If Len(s) > 0 Then s = s & ","
                s = s & "'" & UCase(Replace(coll.Key(I),"'","''")) & "'"
            End If
        Next
        WordsCollectionToDBList = s
    End Function
    
    ' text - the keywords
    ' bPos - include the must present keywords
    ' bNeg - include the must not present keywrods
    Function KeywordIDListEx(text, bPos, bNeg, ByRef nCount)
        Dim coll, I, w, l, r, s, nPositive
        nPositive = 0
        Set coll = CreateCollection
        arr = Split(text," ")
        If IsArray(arr) Then
            For I = LBound(arr) To UBound(arr)
                w = UCase(arr(I))
                l = Len(w)
                If l > 0 Then
                    If Left(w,1) = "-" Then
                        If l > 1 Then coll(Mid(w,2)) = False
                    ElseIf Left(w,1) = "+" Then
                        If l > 1 Then 
                            coll(Mid(w,2)) = True
                            nPositive = nPositive + 1
                        End If
                    Else
                        coll(w) = True
                        nPositive = nPositive + 1
                    End If
                End If
            Next
        End If
        nCount = nPositive
        
        s = "0"
        If coll.Count > 0 Then
            If bPos Then
                l = WordsCollectionToDBList(coll, True, False)
                Set r = Database.DB.Execute("SELECT ID FROM KEYWORD WHERE WORD IN (" & l & ")")
                'If r.Count < nPositive Then
                '    s = s & ",-1" ' One or more positive keywords is not even present in the database
                'Else
                    For I = 1 To r.Count
                        s = s & "," & ConvertTo(vbLong, r(I)("ID"))
                    Next                                   
                'End If
            End If
            If bNeg Then
                l = WordsCollectionToDBList(coll, False, True)
                Set r = Database.DB.Execute("SELECT DISTINCT ID FROM KEYWORD WHERE WORD IN (" & l & ")")
                For I = 1 To r.Count
                    s = s & "," & ConvertTo(vbLong, r(I)("ID"))
                Next                                   
            End If
        End If
        
        KeywordIDListEx = s
    End Function
    Function KeywordIDList(text, bPos, bNeg)
        Dim nCount
        KeywordIDList = KeywordIDListEx(text,bPos,bNeg,nCount)
    End Function
    
    
    Function SQLSearchAny(text, fld) ' A simpler search option where any positive keyword matched qualifies the result
        Dim pos, neg, sql
        pos = KeywordIDList(text, True, False)
        neg = KeywordIDList(text, False, True)
        sql = ""
        If pos <> "0" Then sql = sql & "(" & fld & " IN (SELECT OBJECT_SID FROM OBJECT_KEYWORD WHERE KEYWORD_ID IN (" & pos & ")))"
        If neg <> "0" Then
            If Len(sql) <> 0 Then sql = sql & " AND "
            sql = sql & "(" & fld & " NOT IN (SELECT OBJECT_SID FROM OBJECT_KEYWORD WHERE KEYWORD_ID IN (" & neg & ")))"
        End If
        If Len(sql) <> 0 Then
            SQLSearchAny = "(" & sql & ")"
        Else
            SQLSearchAny = "1=1"
        End If
    End Function
    
    Function SQLSearchExact(text,fld)
        Dim pos, neg, sql, posCount
        posCount = 0
        pos = KeywordIDListEx(text, True, False, posCount)
        neg = KeywordIDList(text, False, True)
        sql = ""
        If pos <> "0" Then 
            sql = sql & "(" & fld & " IN (SELECT OBJECT_SID FROM OBJECT_KEYWORD WHERE KEYWORD_ID IN (" & pos & ") GROUP BY OBJECT_SID HAVING COUNT(KEYWORD_ID)=" & posCount & "))"
        ElseIf posCount > 0 Then
            sql = sql & "0"
        End If
        If neg <> "0" Then
            If Len(sql) <> 0 Then sql = sql & " AND "
            sql = sql & "(" & fld & " NOT IN (SELECT OBJECT_SID FROM OBJECT_KEYWORD WHERE KEYWORD_ID IN (" & neg & ")))"
        End If
        If Len(sql) <> 0 Then
            SQLSearchExact = " (" & sql & ") "
        Else
            SQLSearchExact = " 1=1 "
        End If
    End Function
    
    
    ' Indexers for specific datatabase entries ===================

    Function IndexPerson(sid)
        Dim r, I, code, arr
        IndexPerson = False
        If Database.BeginTransaction Then
            On Error Resume Next
            Err.Clear
            Database.DB.VExecute "DELETE FROM OBJECT_KEYWORD WHERE OBJECT_SID=$sid", 1, 0, sid
            Set r = Database.DB.VExecute("SELECT * FROM PERSON WHERE SID=$sid", 1, 0 , sid)
            For I = 1 To r.Count
                AddKeywords r(I)("NAME1"), sid
                AddKeywords r(I)("NAME2"), sid
                AddKeywords r(I)("NAME3"), sid
                AddKeywords r(I)("TITLE"), sid
                AddKeywords r(I)("EGN"), sid
                AddKeywords r(I)("COMMENT"), sid
                AddKeywords r(I)("KEYWORDS"), sid
            Next
            IndexPerson = Database.CompleteTransaction
            On Error Goto 0
        End If
    End Function
    Function IndexEntity(sid)
        IndexEntity = IndexPerson(sid)
    End Function
    Function IndexImage(sid)
        Dim r, I, code, arr
        IndexImage = False
        If Database.BeginTransaction Then
            On Error Resume Next
            Err.Clear
            Database.DB.VExecute "DELETE FROM OBJECT_KEYWORD WHERE OBJECT_SID=$sid", 1, 0, sid
            Set r = Database.DB.VExecute("SELECT * FROM IMAGE WHERE SID=$sid", 1, 0 , sid)
            For I = 1 To r.Count
                AddKeywords r(I)("NAME"), sid
            Next
            IndexImage = Database.CompleteTransaction
            On Error Goto 0
        End If
    End Function
    Function IndexFile(sid)
        Dim r, I, code, arr
        IndexFile = False
        If Database.BeginTransaction Then
            On Error Resume Next
            Err.Clear
            Database.DB.VExecute "DELETE FROM OBJECT_KEYWORD WHERE OBJECT_SID=$sid", 1, 0, sid
            Set r = Database.DB.VExecute("SELECT * FROM FILE WHERE SID=$sid", 1, 0 , sid)
            For I = 1 To r.Count
                AddKeywords r(I)("FILE_NAME"), sid
                AddKeywords r(I)("CAPTION"), sid
            Next
            IndexFile = Database.CompleteTransaction
            On Error Goto 0
        End If
    End Function
    Function IndexArticle(sid)
        Dim r, I, code, arr
        IndexArticle = False
        If Database.BeginTransaction Then
            On Error Resume Next
            Err.Clear
            Database.DB.VExecute "DELETE FROM OBJECT_KEYWORD WHERE OBJECT_SID=$sid", 1, 0, sid
            Set r = Database.DB.VExecute("SELECT * FROM ARTICLE WHERE SID=$sid", 1, 0 , sid)
            For I = 1 To r.Count
                AddKeywords r(I)("CAPTION"), sid
                AddKeywords r(I)("KEYWORDS"), sid
                AddKeywords BBCodeClean(r(I)("BODY")), sid
            Next
            IndexArticle = Database.CompleteTransaction
            On Error Goto 0
        End If
    End Function
    Function IndexEvent(sid)
        Dim r, I, code, arr
        IndexEvent = False
        If Database.BeginTransaction Then
            On Error Resume Next
            Err.Clear
            Database.DB.VExecute "DELETE FROM OBJECT_KEYWORD WHERE OBJECT_SID=$sid", 1, 0, sid
            Set r = Database.DB.VExecute("SELECT * FROM EVENT WHERE SID=$sid", 1, 0 , sid)
            For I = 1 To r.Count
                AddKeywords r(I)("CAPTION"), sid
                AddKeywords r(I)("KEYWORDS"), sid
                AddKeywords BBCodeClean(r(I)("BODY")), sid
                AddKeywords BBCodeClean(r(I)("LOCATION_BODY")), sid
            Next
            IndexEvent = Database.CompleteTransaction
            On Error Goto 0
        End If
    End Function
    Function IndexItem(sid)
        Dim r, I, code, arr
        IndexItem = False
        If Database.BeginTransaction Then
            On Error Resume Next
            Err.Clear
            Database.DB.VExecute "DELETE FROM OBJECT_KEYWORD WHERE OBJECT_SID=$sid", 1, 0, sid
            Set r = Database.DB.VExecute("SELECT * FROM ITEM WHERE SID=$sid", 1, 0 , sid)
            For I = 1 To r.Count
                AddKeywords r(I)("CAPTION"), sid
                AddKeywords r(I)("KEYWORDS"), sid
                AddKeywords BBCodeClean(r(I)("BODY")), sid
            Next
            IndexItem = Database.CompleteTransaction
            On Error Goto 0
        End If
    End Function
    
    ' Multiplexer
    Function IndexRecord(Table, sid)
        IndexRecord = False
        Select Case Table
            Case "EVENT"
                IndexRecord = IndexEvent(sid)
            Case "ARTICLE"
                IndexRecord = IndexArticle(sid)
            Case "ITEM"
                IndexRecord = IndexItem(sid)
            Case "FILE"
                IndexRecord = IndexFile(sid)
            Case "IMAGE"
                IndexRecord = IndexImage(sid)
            Case "PERSON"
                IndexRecord = IndexPerson(sid)
        End Select
    End Function
    
%>