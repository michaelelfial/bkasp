<%
For I = 1 To db.Parameters.Count
    %>
    <%= db.Parameters(I) %><BR>
    <%
Next
%>