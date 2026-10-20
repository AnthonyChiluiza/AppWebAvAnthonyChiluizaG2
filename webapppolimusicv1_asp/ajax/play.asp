<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<%
' ==========================================================================
'  ajax/play.asp
'  Incrementa el contador PLAYS de una cancion y devuelve el total en JSON.
'  Consumido por js/player.js al iniciar la reproduccion.
' ==========================================================================

Response.ContentType = "application/json"

Dim intId, rsP, intPlays

intId = IntOr(Request.QueryString("id"), 0)
intPlays = 0

If intId > 0 Then
    oCnx.Execute "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = " & intId

    Set rsP = OpenRS("SELECT ISNULL(PLAYS, 0) AS PLAYS FROM TBL_SONG WHERE ID_SONG = " & intId)
    If Not rsP.EOF Then
        intPlays = CLng(rsP("PLAYS"))
    End If
    rsP.Close
    Set rsP = Nothing
End If

Response.Write "{""ok"":" & LCase(CStr(intId > 0)) & ",""id"":" & intId & ",""plays"":" & intPlays & "}"

On Error Resume Next
oCnx.Close
Set oCnx = Nothing
On Error GoTo 0
%>
