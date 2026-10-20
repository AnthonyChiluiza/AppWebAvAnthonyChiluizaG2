<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<%
' ==========================================================================
'  admin/artists.asp  -  CRUD de artistas (solo ADMIN)
' ==========================================================================
strPrefix = "../"
strPageTitle = "Artistas"
strActive = "artists"
strCrumb = "<a href=""../home.asp"">Inicio</a> <span class=""sep"">/</span> " & _
           "<a href=""artists.asp"">Artistas</a>"

RequireAdmin

Dim strAct, intId, blnShowForm, strFormMode, blnLoaded
Dim fName, fLastName, fImage, strFormErr
Dim rsArtists, intRow, strImg, strFullName, intSongs

strAct = LCase(Req("action"))
intId = IntOr(Req("id"), 0)

blnShowForm = False
blnLoaded = False
strFormMode = "new"
strFormErr = ""
fName = ""
fLastName = ""
fImage = ""

' --------------------------------------------------------------------------
'  Acciones
' --------------------------------------------------------------------------
If IsPost() And strAct = "save" Then
    fName = FS("artist_name")
    fLastName = FS("artist_lastname")
    fImage = FS("artist_image")

    If fName = "" Then
        strFormErr = "El nombre del artista es obligatorio."
    ElseIf Len(fName) > 100 Then
        strFormErr = "El nombre no puede superar los 100 caracteres."
    ElseIf Len(fLastName) > 100 Then
        strFormErr = "El apellido no puede superar los 100 caracteres."
    ElseIf Len(fImage) > 255 Then
        strFormErr = "La ruta de la imagen es demasiado larga (maximo 255 caracteres)."
    End If

    If strFormErr = "" Then
        If intId > 0 Then
            oCnx.Execute "UPDATE TBL_ARTIST SET ARTIST_NAME = '" & SqlS(fName) & "', " & _
                         "ARTIST_LASTNAME = '" & SqlS(fLastName) & "', " & _
                         "ARTIST_IMAGE = '" & SqlS(fImage) & "' WHERE ID_ARTIST = " & intId
            SetFlash "ok", "El artista <strong>" & H(fName & " " & fLastName) & "</strong> se actualizo correctamente."
        Else
            oCnx.Execute "INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) " & _
                         "VALUES ('" & SqlS(fName) & "', '" & SqlS(fLastName) & "', '" & SqlS(fImage) & "')"
            SetFlash "ok", "El artista <strong>" & H(fName & " " & fLastName) & "</strong> se creo correctamente."
        End If
        Response.Redirect "artists.asp"
    Else
        blnShowForm = True
        blnLoaded = True
        If intId > 0 Then strFormMode = "edit" Else strFormMode = "new"
    End If
End If

If IsPost() And strAct = "delete" Then
    If intId > 0 Then
        ' Primero se eliminan las participaciones del artista en canciones
        RunSQL "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = " & intId
        RunSQL "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = " & intId
        SetFlash "ok", "El artista se elimino y se quito de todas sus canciones."
    End If
    Response.Redirect "artists.asp"
End If

If Not blnLoaded Then
    If strAct = "new" Then
        blnShowForm = True
        strFormMode = "new"
    ElseIf strAct = "edit" And intId > 0 Then
        Set rsArtists = OpenRS("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE " & _
                                     "FROM TBL_ARTIST WHERE ID_ARTIST = " & intId)
        If Not rsArtists.EOF Then
            blnShowForm = True
            strFormMode = "edit"
            fName = TrimStr(rsArtists("ARTIST_NAME"))
            fLastName = TrimStr(rsArtists("ARTIST_LASTNAME"))
            fImage = TrimStr(rsArtists("ARTIST_IMAGE"))
        End If
        rsArtists.Close
        Set rsArtists = Nothing
    End If
End If
%>
<!--#include file="../includes/header.asp"-->

<div class="section-head">
    <div>
        <h2><%=SvgIcon("mic", "")%>Artistas</h2>
        <p class="section-sub">Administra los interpretes que participan en las canciones del catalogo.</p>
    </div>
    <a class="btn btn-primary btn-sm" href="artists.asp?action=new"><%=SvgIcon("plus", "")%>Nuevo artista</a>
</div>

<div class="crud-layout">
    <div class="col-form">
        <% If blnShowForm Then %>
        <div class="card">
            <div class="card-title">
                <%=SvgIcon("edit", "")%>
                <% If strFormMode = "edit" Then %>Editar artista #<%=intId%><% Else %>Nuevo artista<% End If %>
            </div>

            <% If strFormErr <> "" Then %>
            <div class="flash flash-err" role="alert">
                <%=SvgIcon("alert", "")%>
                <div><strong>Revisa el formulario.</strong> <%=H(strFormErr)%></div>
            </div>
            <% End If %>

            <form method="post" action="artists.asp">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="<%=intId%>">

                <div class="form-grid">
                    <div class="field full">
                        <label for="artist_name">Nombre <span class="req">*</span></label>
                        <input type="text" id="artist_name" name="artist_name" value="<%=H(fName)%>"
                               maxlength="100" required placeholder="Ej. Juan">
                    </div>

                    <div class="field full">
                        <label for="artist_lastname">Apellido</label>
                        <input type="text" id="artist_lastname" name="artist_lastname" value="<%=H(fLastName)%>"
                               maxlength="100" placeholder="Ej. Gabriel">
                    </div>

                    <div class="field full">
                        <label for="artist_image">Imagen del artista</label>
                        <input type="text" id="artist_image" name="artist_image" value="<%=H(fImage)%>"
                               maxlength="255" list="dlArtists"
                               placeholder="SongFilesAndImages_resources/ArtistImages/artista.jpg">
                        <span class="help">Si no hay imagen disponible se muestra un placeholder con la inicial del artista.</span>
                        <% FileDatalist "dlArtists", RES_ARTISTS, IMG_EXTS %>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%=SvgIcon("check", "")%><% If strFormMode = "edit" Then %>Guardar cambios<% Else %>Crear artista<% End If %>
                    </button>
                    <a class="btn btn-ghost" href="artists.asp">Cancelar</a>
                </div>
            </form>
        </div>
        <% Else %>
        <div class="card">
            <div class="card-title"><%=SvgIcon("info", "")%>Selecciona un artista</div>
            <p class="small muted" style="margin:0">
                Usa <strong>Editar</strong> para modificar un artista existente o <strong>Nuevo artista</strong>
                para registrarlo en el catalogo.
            </p>
        </div>
        <% End If %>
    </div>

    <div>
        <%
        Set rsArtists = OpenRS("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
                                     "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS TOTAL " & _
                                     "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME")
        If rsArtists.EOF Then
        %>
        <div class="empty">
            <%=SvgIcon("mic", "")%>
            <h3>No hay artistas registrados</h3>
            <p>Crea el primer artista para poder asociarlo a las canciones.</p>
        </div>
        <% Else %>
        <div class="table-wrap">
            <div class="table-scroll">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width:44px">#</th>
                            <th>Artista</th>
                            <th class="hide-sm">Canciones</th>
                            <th style="width:96px" class="text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        intRow = 0
                        Do While Not rsArtists.EOF
                            intRow = intRow + 1
                            strImg = ImageUrl(rsArtists("ARTIST_IMAGE"), "artist")
                            strFullName = TrimStr(rsArtists("ARTIST_NAME")) & " " & TrimStr(rsArtists("ARTIST_LASTNAME"))
                            intSongs = IntOr(rsArtists("TOTAL"), 0)
                        %>
                        <tr>
                            <td class="cell-index"><%=Right("0" & intRow, 2)%></td>
                            <td>
                                <div class="cell-song">
                                    <% ArtBox strImg, strFullName, "art-round" %>
                                    <div>
                                        <strong><%=H(TrimStr(rsArtists("ARTIST_NAME")))%></strong>
                                        <small><%=H(TrimStr(rsArtists("ARTIST_LASTNAME")))%></small>
                                    </div>
                                </div>
                            </td>
                            <td class="hide-sm">
                                <span class="tag"><%=SvgIcon("music", "")%><%=intSongs%> <%=Plural(intSongs, "cancion", "canciones")%></span>
                            </td>
                            <td>
                                <div class="row-actions">
                                    <a class="icon-btn" href="artists.asp?action=edit&amp;id=<%=rsArtists("ID_ARTIST")%>"
                                       title="Editar"><%=SvgIcon("edit", "")%></a>
                                    <form class="inline-form" method="post" action="artists.asp"
                                          onsubmit="return confirm('Se eliminara el artista <%=Replace(Replace(strFullName, "'", ""), """", "")%> y su participacion en <%=intSongs%> cancion(es). ¿Continuar?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%=rsArtists("ID_ARTIST")%>">
                                        <button type="submit" class="icon-btn danger" title="Eliminar">
                                            <%=SvgIcon("trash", "")%>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                            rsArtists.MoveNext
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
rsArtists.Close
Set rsArtists = Nothing
%>
<!--#include file="../includes/footer.asp"-->
