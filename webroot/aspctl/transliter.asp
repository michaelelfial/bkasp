<%
    Class CTransLiteration
        Private Subst
        Sub Class_Initialize
            Set Subst = CreateList
        End Sub
        Sub Add(p, s)
            Subst.Add p, s
        End Sub
        Sub Init(pat,subs,delim)
            Dim arrP, arrS, I
            arrP = Split(pat,delim)
            arrS = Split(subs,delim)
            If UBound(arrP) = UBound(arrS) Then
                For I = LBound(arrP) To UBound(arrP)
                    Add Trim(arrP(I)), Trim(arrS(I))
                Next
            Else
                Err.Raise 1, "CTransLiteration", "The transliteration patterns do not match"
            End If
        End Sub
        Function Trans(s)
            Dim I, x
            x = s
            For I = 1 To Subst.Count
                x = Replace(x,Subst.Key(I),Subst(I))
            Next
            Trans = x
        End Function
    End Class
    Function Create_LatCyrTransliteration
        Dim o
        Set o = New CTransLiteration
        o.Init "SHT,TCH,sht,tch,yu,YU,ya,YA,ZH,zh,SH,CH,sh,ch,4,6,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,4,6,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z",_
               "ู,ื,๙,๗,þ,Þ,ÿ,฿,ฦ,ๆ,ุ,ื,๘,๗,๗,๘,เ,แ,๖,ไ,ๅ,๔,ใ,๕,่,้,๊,๋,์,ํ,๎,๏,ÿ,๐,๑,๒,๓,โ,โ,๊๑,้,็,ื,ุ,ภ,ม,ึ,ฤ,ล,ิ,ร,ี,ศ,ษ,ส,ห,ฬ,อ,ฮ,ฯ,฿,ะ,ั,า,ำ,ย,ย,สั,ษ,ว",_
               ","
        Set Create_LatCyrTransliteration = o
    End Function
    Function Create_CyrLatTransliteration
        Dim o
        Set o = New CTransLiteration
        o.Init "เ,แ,โ,ใ,ไ,ๅ,ๆ,็,่,้,๊,๋,์,ํ,๎,๏,๐,๑,๒,๓,๔,๕,๖,๗,๘,๙,๚,ü,þ,ÿ,ภ,ม,ย,ร,ฤ,ล,ฦ,ว,ศ,ษ,ส,ห,ฬ,อ,ฮ,ฯ,ะ,ั,า,ำ,ิ,ี,ึ,ื,ุ,ู,ฺ,Ü,Þ,฿", _
               "a,b,v,g,d,e,zh,z,i,y,k,l,m,n,o,p,r,s,t,u,f,h,c,ch,sh,sht,a,y,yu,ya,A,B,V,G,D,E,ZH,Z,I,Y,K,L,M,N,O,P,R,S,T,U,F,H,C,CH,SH,SHT,A,Y,YU,YA", _
                ","
        Set Create_CyrLatTransliteration = o
    End Function

%>