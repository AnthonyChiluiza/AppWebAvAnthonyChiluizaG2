<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<%
' ==========================================================================
'  admin/users.asp  -  CRUD de usuarios (solo ADMIN)
'  No permite eliminar ni quitarse el rol al usuario logueado
' ==========================================================================
strPrefix = "../"
strPageTitle = "Usuarios"
strActive = "users"
strCrumb = "<a href=""../home.asp"">Inicio</a> <span class=""sep"">/</span> " & _
           "<a href=""users.asp"">Usuarios</a>"

RequireAdmin

Dim strAct, intId, blnShowForm, strFormMode, blnLoaded
Dim fUser, fPass, fEmail, fBirthday, fPhoto, fType, strFormErr, strBdaySql
Dim rsUsers, intRow, strImg, strTypeLbl, strTypeCls, intTotal

strAct = LCase(Req("action"))
intId = IntOr(Req("id"), 0)

blnShowForm = False
blnLoaded = False
strFormMode = "new"
strFormErr = ""
fUser = ""
fPass = ""
fEmail = ""
fBirthday = ""
fPhoto = ""
fType = 0

' --------------------------------------------------------------------------
'  Acciones
' --------------------------------------------------------------------------
If IsPost() And strAct = "save" Then
    fUser = FS("username")
    fPass = FS("password")
    fEmail = FS("email")
    fBirthday = FS("birthday")
    fPhoto = FS("user_photo")
    fType = IntOr(FS("user_type"), 0)

    If fUser = "" Then
        strFormErr = "El nombre de usuario es obligatorio."
    ElseIf Len(fUser) > 50 Then
        strFormErr = "El usuario no puede superar los 50 caracteres."
    ElseIf fEmail = "" Then
        strFormErr = "El correo electronico es obligatorio."
    ElseIf InStr(fEmail, "@") = 0 Or InStr(fEmail, ".") = 0 Then
        strFormErr = "El correo electronico no tiene un formato valido."
    ElseIf Len(fEmail) > 50 Then
        strFormErr = "El correo no puede superar los 50 caracteres."
    ElseIf intId = 0 And fPass = "" Then
        strFormErr = "La contrasena es obligatoria para un usuario nuevo."
    ElseIf fPass <> "" And Len(fPass) < 4 Then
        strFormErr = "La contrasena debe tener al menos 4 caracteres."
    ElseIf fBirthday <> "" And Not IsDate(fBirthday) Then
        strFormErr = "La fecha de nacimiento no es valida."
    ElseIf intId = CurrentUserId() And fType <> 1 Then
        strFormErr = "No puedes quitarte a ti mismo el rol de Administrador."
    End If

    ' Usuario duplicado
    If strFormErr = "" Then
        If intId > 0 Then
            intTotal = GetCount("SELECT COUNT(*) FROM TBL_USER WHERE USERNAME = '" & SqlS(fUser) & "' AND ID_USER <> " & intId)
        Else
            intTotal = GetCount("SELECT COUNT(*) FROM TBL_USER WHERE USERNAME = '" & SqlS(fUser) & "'")
        End If
        If intTotal > 0 Then
            strFormErr = "Ya existe un usuario registrado con ese nombre."
        End If
    End If

    If strFormErr = "" Then
        If fBirthday = "" Then
            strBdaySql = "NULL"
        Else
            ' Formato ISO basico (yyyymmdd) para evitar ambiguedades de idioma
            strBdaySql = "'" & Replace(fBirthday, "-", "") & "'"
        End If

        If intId > 0 Then
            oCnx.Execute "UPDATE TBL_USER SET USERNAME = '" & SqlS(fUser) & "', " & _
                         "EMAIL = '" & SqlS(fEmail) & "', BIRTHDAY = " & strBdaySql & ", " & _
                         "USER_PHOTO = '" & SqlS(fPhoto) & "', USER_TYPE = " & fType & " " & _
                         "WHERE ID_USER = " & intId
            If fPass <> "" Then
                oCnx.Execute "UPDATE TBL_USER SET PASSWORD = '" & SqlS(fPass) & "' WHERE ID_USER = " & intId
            End If
            SetFlash "ok", "El usuario <strong>" & H(fUser) & "</strong> se actualizo correctamente."
        Else
            oCnx.Execute "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) " & _
                         "VALUES ('" & SqlS(fUser) & "', '" & SqlS(fPass) & "', '" & SqlS(fEmail) & "', " & _
                         strBdaySql & ", '" & SqlS(fPhoto) & "', " & fType & ")"
            SetFlash "ok", "El usuario <strong>" & H(fUser) & "</strong> se creo correctamente."
        End If

        Response.Redirect "users.asp"
    Else
        blnShowForm = True
        blnLoaded = True
        If intId > 0 Then strFormMode = "edit" Else strFormMode = "new"
    End If
End If

If IsPost() And strAct = "delete" Then
    If intId > 0 Then
        If intId = CurrentUserId() Then
            SetFlash "err", "No puedes eliminar tu propia cuenta mientras tienes la sesion iniciada."
        Else
            ' Elimina primero las playlists del usuario y su contenido
            RunSQL "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST IN (SELECT ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_USER = " & intId & ")"
            RunSQL "DELETE FROM TBL_PLAYLIST WHERE ID_USER = " & intId
            RunSQL "DELETE FROM TBL_USER WHERE ID_USER = " & intId
            SetFlash "ok", "El usuario y sus playlists se eliminaron correctamente."
        End If
    End If
    Response.Redirect "users.asp"
End If

If Not blnLoaded Then
    If strAct = "new" Then
        blnShowForm = True
        strFormMode = "new"
    ElseIf strAct = "edit" And intId > 0 Then
        Set rsUsers = OpenRS("SELECT ID_USER, USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE " & _
                                   "FROM TBL_USER WHERE ID_USER = " & intId)
        If Not rsUsers.EOF Then
            blnShowForm = True
            strFormMode = "edit"
            fUser = TrimStr(rsUsers("USERNAME"))
            fEmail = TrimStr(rsUsers("EMAIL"))
            fBirthday = IsoDate(rsUsers("BIRTHDAY"))
            fPhoto = TrimStr(rsUsers("USER_PHOTO"))
            fType = IntOr(rsUsers("USER_TYPE"), 0)
        End If
        rsUsers.Close
        Set rsUsers = Nothing
    End If
End If
%>
<!--#include file="../includes/header.asp"-->

<div class="section-head">
    <div>
        <h2><%=SvgIcon("user", "")%>Usuarios</h2>
        <p class="section-sub">Administra las cuentas del sistema y su rol (Administrador o Usuario).</p>
    </div>
    <a class="btn btn-primary btn-sm" href="users.asp?action=new"><%=SvgIcon("plus", "")%>Nuevo usuario</a>
</div>

<div class="crud-layout wide-form">
    <div class="col-form">
        <% If blnShowForm Then %>
        <div class="card">
            <div class="card-title">
                <%=SvgIcon("edit", "")%>
                <% If strFormMode = "edit" Then %>Editar usuario #<%=intId%><% Else %>Nuevo usuario<% End If %>
            </div>

            <% If strFormErr <> "" Then %>
            <div class="flash flash-err" role="alert">
                <%=SvgIcon("alert", "")%>
                <div><strong>Revisa el formulario.</strong> <%=H(strFormErr)%></div>
            </div>
            <% End If %>

            <form method="post" action="users.asp" autocomplete="off">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="<%=intId%>">

                <div class="form-grid">
                    <div class="field">
                        <label for="username">Usuario <span class="req">*</span></label>
                        <input type="text" id="username" name="username" value="<%=H(fUser)%>"
                               maxlength="50" required placeholder="Ej. userNormal">
                    </div>

                    <div class="field">
                        <label for="password">Contrasena <% If strFormMode = "new" Then %><span class="req">*</span><% End If %></label>
                        <input type="password" id="password" name="password" value=""
                               maxlength="50" <% If strFormMode = "new" Then %>required<% End If %>
                               placeholder="<% If strFormMode = "edit" Then %>Dejar vacio para conservarla<% Else %>Minimo 4 caracteres<% End If %>">
                        <span class="help">El login acepta contrasenas en texto plano y en hash SHA1.</span>
                    </div>

                    <div class="field full">
                        <label for="email">Correo electronico <span class="req">*</span></label>
                        <input type="email" id="email" name="email" value="<%=H(fEmail)%>"
                               maxlength="50" required placeholder="usuario@epn.edu.ec">
                    </div>

                    <div class="field">
                        <label for="birthday">Fecha de nacimiento</label>
                        <input type="date" id="birthday" name="birthday" value="<%=H(fBirthday)%>">
                    </div>

                    <div class="field">
                        <label for="user_type">Rol del usuario</label>
                        <select id="user_type" name="user_type">
                            <% CatalogOptions "1", fType %>
                        </select>
                        <span class="help">Administrador: acceso total. Usuario: solo sus playlists.</span>
                    </div>

                    <div class="field full">
                        <label for="user_photo">Foto de perfil</label>
                        <input type="text" id="user_photo" name="user_photo" value="<%=H(fPhoto)%>"
                               maxlength="255" list="dlUsers" placeholder=".../UserImages/default.jpg">
                        <% FileDatalist "dlUsers", RES_USERS, IMG_EXTS %>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%=SvgIcon("check", "")%><% If strFormMode = "edit" Then %>Guardar cambios<% Else %>Crear usuario<% End If %>
                    </button>
                    <a class="btn btn-ghost" href="users.asp">Cancelar</a>
                </div>
            </form>
        </div>
        <% Else %>
        <div class="card">
            <div class="card-title"><%=SvgIcon("info", "")%>Selecciona un usuario</div>
            <p class="small muted" style="margin:0">
                Pulsa <strong>Editar</strong> para cambiar los datos o el rol de una cuenta existente.
                No puedes eliminar tu propia cuenta.
            </p>
        </div>
        <% End If %>
    </div>

    <div>
        <%
        Set rsUsers = OpenRS("SELECT ID_USER, USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE " & _
                                   "FROM TBL_USER ORDER BY USERNAME")
        If rsUsers.EOF Then
        %>
        <div class="empty">
            <%=SvgIcon("user", "")%>
            <h3>No hay usuarios registrados</h3>
            <p>Crea la primera cuenta para que pueda iniciar sesion en PolyMusic.</p>
        </div>
        <% Else %>
        <div class="table-wrap">
            <div class="table-scroll">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width:44px">#</th>
                            <th>Usuario</th>
                            <th class="hide-sm">Correo</th>
                            <th class="hide-sm" style="width:110px">Nacimiento</th>
                            <th style="width:110px">Rol</th>
                            <th style="width:96px" class="text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        intRow = 0
                        Do While Not rsUsers.EOF
                            intRow = intRow + 1
                            strImg = ImageUrl(rsUsers("USER_PHOTO"), "user")
                            If IntOr(rsUsers("USER_TYPE"), 0) = 1 Then
                                strTypeCls = "badge-admin"
                            Else
                                strTypeCls = "badge-user"
                            End If
                            strTypeLbl = CatalogName("1", IntOr(rsUsers("USER_TYPE"), 0), "USER")
                        %>
                        <tr>
                            <td class="cell-index"><%=Right("0" & intRow, 2)%></td>
                            <td>
                                <div class="cell-song">
                                    <span class="art art-round">
                                        <span class="art-ph"><%=H(Initial(rsUsers("USERNAME")))%></span>
                                        <% If strImg <> "" Then %>
                                        <img src="<%=strPrefix & strImg%>" alt="" loading="lazy" onerror="this.remove()">
                                        <% End If %>
                                    </span>
                                    <div>
                                        <strong><%=H(rsUsers("USERNAME"))%></strong>
                                        <small><% If IntOr(rsUsers("ID_USER"), 0) = CurrentUserId() Then %>Tu cuenta<% Else %>ID #<%=rsUsers("ID_USER")%><% End If %></small>
                                    </div>
                                </div>
                            </td>
                            <td class="hide-sm cell-muted"><%=H(rsUsers("EMAIL"))%></td>
                            <td class="hide-sm cell-muted"><%=FormatDateEs(rsUsers("BIRTHDAY"))%></td>
                            <td><span class="badge <%=strTypeCls%>"><%=H(strTypeLbl)%></span></td>
                            <td>
                                <div class="row-actions">
                                    <a class="icon-btn" href="users.asp?action=edit&amp;id=<%=rsUsers("ID_USER")%>"
                                       title="Editar"><%=SvgIcon("edit", "")%></a>
                                    <% If IntOr(rsUsers("ID_USER"), 0) <> CurrentUserId() Then %>
                                    <form class="inline-form" method="post" action="users.asp"
                                          onsubmit="return confirm('Se eliminara el usuario <%=Replace(Replace(rsUsers("USERNAME"), "'", ""), """", "")%> junto con sus playlists. ¿Continuar?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%=rsUsers("ID_USER")%>">
                                        <button type="submit" class="icon-btn danger" title="Eliminar">
                                            <%=SvgIcon("trash", "")%>
                                        </button>
                                    </form>
                                    <% Else %>
                                    <span class="icon-btn is-disabled" title="No puedes eliminar tu propia cuenta"
                                          style="opacity:.4;cursor:not-allowed"><%=SvgIcon("trash", "")%></span>
                                    <% End If %>
                                </div>
                            </td>
                        </tr>
                        <%
                            rsUsers.MoveNext
                        Loop
                        %>
                    </tbody>
                </table>
            </div>
        </div>
        <% End If %>
    </div>
</div>

<%
rsUsers.Close
Set rsUsers = Nothing
%>
<!--#include file="../includes/footer.asp"-->
