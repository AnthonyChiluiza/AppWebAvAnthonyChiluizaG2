<%
' ==========================================================================
'  includes/cnx.asp
'  Conexion reutilizable a SQL Server (ADO / SQLOLEDB)
'  Se incluye al inicio de TODAS las paginas del sitio.
' ==========================================================================

Response.Buffer = True
Response.CodePage = 65001
Response.CharSet = "utf-8"

Dim oCnx
Dim strCnxString
Dim strCnxErr

strCnxString = "Provider=SQLOLEDB;Data Source=localhost\SQLEXPRESS;" & _
               "Initial Catalog=BDD_PoliMusic;" & _
               "User ID=usr_polimusic;Password=Politecnica1;"

On Error Resume Next
Set oCnx = Server.CreateObject("ADODB.Connection")
If Err.Number = 0 Then
    oCnx.ConnectionTimeout = 15
    oCnx.CommandTimeout = 30
    oCnx.Open strCnxString
End If

If Err.Number <> 0 Then
    strCnxErr = Err.Description
    Err.Clear
    On Error GoTo 0

    Response.Write "<!DOCTYPE html><html lang=""es""><head><meta charset=""utf-8"">"
    Response.Write "<meta name=""viewport"" content=""width=device-width, initial-scale=1"">"
    Response.Write "<title>Sin conexion - PolyMusic</title><style>"
    Response.Write "body{margin:0;min-height:100vh;display:grid;place-items:center;font-family:'Segoe UI',Roboto,Arial,sans-serif;"
    Response.Write "background:linear-gradient(160deg,#ffffff,#f3e5f5);color:#1a0033;padding:24px}"
    Response.Write ".box{max-width:560px;background:#fff;border:1px solid #eed9f2;border-radius:20px;padding:36px;"
    Response.Write "box-shadow:0 18px 48px rgba(45,10,78,.16)}"
    Response.Write "h1{font-size:1.4rem;margin:0 0 10px;color:#4a148c}"
    Response.Write "p{color:#4a3a5c;line-height:1.6;font-size:.94rem;margin:0 0 12px}"
    Response.Write "code{background:#f3e5f5;padding:2px 7px;border-radius:6px;font-size:.85rem;color:#4a148c}"
    Response.Write ".err{background:#fdecea;border-left:4px solid #c62828;padding:10px 14px;border-radius:8px;"
    Response.Write "font-size:.8rem;color:#8e1f1f;margin-top:16px;word-break:break-word}"
    Response.Write "</style></head><body><div class=""box"">"
    Response.Write "<h1>No se pudo conectar con la base de datos</h1>"
    Response.Write "<p>PolyMusic necesita el motor <strong>SQL Server</strong> activo y la base "
    Response.Write "<code>BDD_PoliMusic</code> creada con el script <code>BDD_PoliMusic.sql</code>.</p>"
    Response.Write "<p>Verifica que el servicio <code>SQL Server (SQLEXPRESS)</code> este iniciado y que el "
    Response.Write "usuario <code>usr_polimusic</code> tenga permisos sobre la base.</p>"
    Response.Write "<div class=""err"">" & Server.HTMLEncode(strCnxErr) & "</div>"
    Response.Write "</div></body></html>"
    Response.End
End If
On Error GoTo 0
%>
