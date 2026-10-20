<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' ==========================================================================
'  logout.asp  -  Destruye la sesion y vuelve al login
' ==========================================================================
Session.Contents.RemoveAll
Session.Abandon
Response.Redirect "login.asp?bye=1"
%>
