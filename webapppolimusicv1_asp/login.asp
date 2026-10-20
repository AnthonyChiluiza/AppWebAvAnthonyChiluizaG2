<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/cnx.asp"-->
<!--#include file="includes/helpers.asp"-->
<%
' ==========================================================================
'  login.asp  -  Autenticacion de usuarios
'  Valida USERNAME + PASSWORD contra TBL_USER (texto plano o SHA1)
' ==========================================================================
strPrefix = ""
strPageTitle = "Iniciar sesion"

Dim strUser, strPass, strError, strInfo, strSql, rsUser, blnFound

strUser = ""
strPass = ""
strError = ""
strInfo = ""

' Si ya existe una sesion activa no tiene sentido mostrar el login
If IsLoggedIn() Then
    Response.Redirect "home.asp"
End If

If QS("bye") = "1" Then
    strInfo = "Cerraste sesion correctamente. &iexcl;Hasta pronto!"
ElseIf QS("e") = "session" Then
    strInfo = "Tu sesion expiro o intentaste abrir una pagina sin iniciar sesion. Vuelve a entrar."
End If

If IsPost() Then
    strUser = FS("username")
    strPass = FS("password")

    If strUser = "" Or strPass = "" Then
        strError = "Ingresa tu usuario y tu contrasena para continuar."
    Else
        ' Acepta contrasenas en texto plano y en hash SHA1 (como el usuario username1)
        strSql = "SELECT TOP 1 ID_USER, USERNAME, USER_TYPE, USER_PHOTO FROM TBL_USER " & _
                 "WHERE USERNAME = '" & SqlS(strUser) & "' AND (PASSWORD = '" & SqlS(strPass) & "' " & _
                 "OR PASSWORD = UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', '" & SqlS(strPass) & "'), 2)))"

        Set rsUser = OpenRS(strSql)
        blnFound = Not rsUser.EOF

        If blnFound Then
            Session("ID_USER") = rsUser("ID_USER")
            Session("USERNAME") = TrimStr(rsUser("USERNAME"))
            If IsNull(rsUser("USER_TYPE")) Then
                Session("USER_TYPE") = 0
            Else
                Session("USER_TYPE") = CLng(rsUser("USER_TYPE"))
            End If
            Session("USER_PHOTO") = TrimStr(rsUser("USER_PHOTO"))
            Session("flash_type") = "ok"
            Session("flash_msg") = "&iexcl;Bienvenido/a de nuevo, <strong>" & H(TrimStr(rsUser("USERNAME"))) & "</strong>!"

            rsUser.Close
            Set rsUser = Nothing

            Response.Redirect "home.asp"
        Else
            rsUser.Close
            Set rsUser = Nothing
            strError = "Usuario o contrasena incorrectos. Revisa tus datos e intentalo de nuevo."
        End If
    End If
End If
%><!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesion &middot; PolyMusic</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<svg class="svg-defs" aria-hidden="true" focusable="false">
    <symbol id="i-music" viewBox="0 0 24 24"><path d="M9 18a3 3 0 1 1-2-2.83V4l12-2v13.2A3 3 0 1 1 17 12V6.3L9 8v10z"/></symbol>
    <symbol id="i-alert" viewBox="0 0 24 24"><path d="M12 2 1 21h22L12 2zm1 14h-2v2h2v-2zm0-7h-2v5h2V9z"/></symbol>
    <symbol id="i-info" viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></symbol>
    <symbol id="i-check" viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></symbol>
    <symbol id="i-list" viewBox="0 0 24 24"><path d="M4 6h16v2H4zM4 11h16v2H4zM4 16h16v2H4z"/></symbol>
    <symbol id="i-disc" viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm0 13a3 3 0 1 1 0-6 3 3 0 0 1 0 6z"/></symbol>
    <symbol id="i-shield" viewBox="0 0 24 24"><path d="M12 2 4 5v6c0 5 3.4 9.4 8 11 4.6-1.6 8-6 8-11V5l-8-3zm-1 14-4-4 1.4-1.4L11 13.2l4.6-4.6L17 10l-6 6z"/></symbol>
</svg>

<div class="auth">
    <aside class="auth-visual">
        <div class="auth-brand">
            <span class="brand-logo"><%=SvgIcon("music", "")%></span>
            PolyMusic
        </div>

        <div class="auth-pitch">
            <h1>Toda tu musica,<br>en un solo lugar.</h1>
            <p>Escucha tu catalogo, arma playlists a tu medida y descubre los albumes y artistas que ya forman parte de tu biblioteca.</p>

            <div class="auth-features">
                <div class="auth-feature">
                    <span class="dot"><%=SvgIcon("list", "")%></span>
                    Crea y organiza tus propias playlists
                </div>
                <div class="auth-feature">
                    <span class="dot"><%=SvgIcon("disc", "")%></span>
                    Explora albumes y artistas del catalogo
                </div>
                <div class="auth-feature">
                    <span class="dot"><%=SvgIcon("shield", "")%></span>
                    Roles de Administrador y Usuario
                </div>
            </div>
        </div>

        <p style="position:relative;z-index:1;color:rgba(255,255,255,.55);font-size:.78rem;margin:0">
            Proyecto academico &middot; Web Avanzada G2 &middot; Anthony Chiluiza
        </p>
    </aside>

    <section class="auth-panel">
        <div class="auth-card">
            <h2>Inicia sesion</h2>
            <p class="sub">Accede con tu usuario y contrasena para entrar a tu biblioteca.</p>

            <% If strInfo <> "" Then %>
            <div class="flash flash-info" role="status">
                <%=SvgIcon("info", "")%>
                <div><%=strInfo%></div>
            </div>
            <% End If %>

            <% If strError <> "" Then %>
            <div class="flash flash-err" role="alert">
                <%=SvgIcon("alert", "")%>
                <div><strong>No pudimos iniciar tu sesion.</strong> <%=H(strError)%></div>
            </div>
            <% End If %>

            <form method="post" action="login.asp" autocomplete="on">
                <div class="field">
                    <label for="username">Usuario</label>
                    <input type="text" id="username" name="username" value="<%=H(strUser)%>"
                           placeholder="Ej. userAdmin" maxlength="50" required autofocus
                           aria-describedby="userHelp">
                    <span class="help" id="userHelp">Usa tu nombre de usuario, no tu correo electronico.</span>
                </div>

                <div class="field">
                    <label for="password">Contrasena</label>
                    <input type="password" id="password" name="password" value=""
                           placeholder="Tu contrasena" maxlength="50" required>
                </div>

                <button type="submit" class="btn btn-primary btn-block">
                    Entrar a PolyMusic
                </button>
            </form>

            <div class="demo-box">
                <b>Cuentas de prueba</b><br>
                Administrador: <code>userAdmin</code> / <code>12345678</code><br>
                Usuario normal: <code>userNormal</code> / <code>12345678</code>
            </div>

            <div class="auth-foot">
                Solo el <strong>Administrador</strong> puede crear, editar y eliminar canciones, artistas, albumes y usuarios.
                El <strong>Usuario</strong> puede gestionar unicamente sus propias playlists.
            </div>
        </div>
    </section>
</div>

</body>
</html>
<%
On Error Resume Next
If IsObject(oCnx) Then
    oCnx.Close
End If
Set oCnx = Nothing
Set g_dicFiles = Nothing
Err.Clear
On Error GoTo 0
%>
