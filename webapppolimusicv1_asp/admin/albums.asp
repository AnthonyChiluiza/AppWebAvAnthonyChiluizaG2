<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<%
' ==========================================================================
'  admin/albums.asp  -  CRUD de albumes (solo ADMIN)
'  Incluye la gestion del tracklist (TBL_TRACKLIST)
' ==========================================================================
strPrefix = "../"
strPageTitle = "Albumes"
strActive = "albums"
strCrumb = "<a href=""../home.asp"">Inicio</a> <span class=""sep"">/</span> " & _
           "<a href=""albums.asp"">Albumes</a>"

RequireAdmin

Dim strAct, intId, blnShowForm, strFormMode, blnLoaded
Dim fTitle, fYear, fImage, fSongs, strFormErr, strYearSql
Dim rsAlbums, rsSongList, rsTl, intRow, strImg, intSongs
Dim arrS, i, strSongId

strAct = LCase(Req("action"))
intId = IntOr(Req("id"), 0)

blnShowForm = False
blnLoaded = False
strFormMode = "new"
strFormErr = ""
fTitle = ""
fYear = ""
fImage = ""
fSongs = ","

' --------------------------------------------------------------------------
'  Acciones
' --------------------------------------------------------------------------
If IsPost() And strAct = "save" Then
    fTitle = FS("title_album")
    fYear = FS("release_year")
    fImage = FS("album_image")
    fSongs = "," & Replace(FS("songs"), " ", "") & ","

    If fTitle = "" Then
        strFormErr = "El titulo del album es obligatorio."
    ElseIf Len(fTitle) > 50 Then
        strFormErr = "El titulo no puede superar los 50 caracteres."
    ElseIf fYear <> "" Then
        If Not IsNumeric(fYear) Then
            strFormErr = "El anio de lanzamiento debe ser un numero."
        ElseIf CLng(fYear) < 1900 Or CLng(fYear) > 2100 Then
            strFormErr = "El anio de lanzamiento debe estar entre 1900 y 2100."
        End If
    End If

    If strFormErr = "" Then
        If fYear = "" Then
            strYearSql = "NULL"
        Else
            strYearSql = CStr(CLng(fYear))
        End If

        If intId > 0 Then
            oCnx.Execute "UPDATE TBL_ALBUM SET TITLE_ALBUM = '" & SqlS(fTitle) & "', " & _
                         "RELEASE_YEAR = " & strYearSql & ", " & _
                         "ALBUM_IMAGE_PATH = '" & SqlS(fImage) & "' WHERE ID_ALBUM = " & intId
            SetFlash "ok", "El album <strong>" & H(fTitle) & "</strong> se actualizo correctamente."
        Else
            oCnx.Execute "INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) " & _
                         "VALUES ('" & SqlS(fTitle) & "', " & strYearSql & ", '" & SqlS(fImage) & "')"
            intId = NewID("TBL_ALBUM", "ID_ALBUM")
            SetFlash "ok", "Album creado. Ahora puedes agregar canciones a su tracklist."
        End If

        ' Sincroniza el tracklist del album
        RunSQL "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = " & intId
        arrS = Split(FS("songs"), ",")
        For i = 0 To UBound(arrS)
            strSongId = Trim(arrS(i))
            If strSongId <> "" And IsNumeric(strSongId) Then
                RunSQL "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (" & intId & ", " & CLng(strSongId) & ")"
            End If
        Next

        Response.Redirect "albums.asp?action=edit&id=" & intId
    Else
        blnShowForm = True
        blnLoaded = True
        If intId > 0 Then strFormMode = "edit" Else strFormMode = "new"
    End If
End If

If IsPost() And strAct = "delete" Then
    If intId > 0 Then
        RunSQL "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = " & intId
        RunSQL "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = " & intId
        SetFlash "ok", "El album se elimino junto con su tracklist. Las canciones siguen en el catalogo."
    End If
    Response.Redirect "albums.asp"
End If

If Not blnLoaded Then
    If strAct = "new" Then
        blnShowForm = True
        strFormMode = "new"
    ElseIf strAct = "edit" And intId > 0 Then
        Set rsAlbums = OpenRS("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH " & _
                                    "FROM TBL_ALBUM WHERE ID_ALBUM = " & intId)
        If Not rsAlbums.EOF Then
            blnShowForm = True
            strFormMode = "edit"
            fTitle = TrimStr(rsAlbums("TITLE_ALBUM"))
            fYear = TrimStr(rsAlbums("RELEASE_YEAR"))
            fImage = TrimStr(rsAlbums("ALBUM_IMAGE_PATH"))

            ' Canciones que ya estan en el tracklist
            fSongs = ","
            Set rsTl = OpenRS("SELECT ID_SONG FROM TBL_TRACKLIST WHERE ID_ALBUM = " & intId)
            Do While Not rsTl.EOF
                fSongs = fSongs & rsTl("ID_SONG") & ","
                rsTl.MoveNext
            Loop
            rsTl.Close
            Set rsTl = Nothing
        End If
        rsAlbums.Close
        Set rsAlbums = Nothing
    End If
End If

Set rsSongList = OpenRS("SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME")
%>
<!--#include file="../includes/header.asp"-->

<div class="section-head">
    <div>
        <h2><%=SvgIcon("disc", "")%>Albumes</h2>
        <p class="section-sub">Gestiona los albumes y su tracklist: que canciones pertenecen a cada uno.</p>
    </div>
    <a class="btn btn-primary btn-sm" href="albums.asp?action=new"><%=SvgIcon("plus", "")%>Nuevo album</a>
</div>

<div class="crud-layout wide-form">
    <div class="col-form">
        <% If blnShowForm Then %>
        <div class="card">
            <div class="card-title">
                <%=SvgIcon("edit", "")%>
                <% If strFormMode = "edit" Then %>Editar album #<%=intId%><% Else %>Nuevo album<% End If %>
            </div>

            <% If strFormErr <> "" Then %>
            <div class="flash flash-err" role="alert">
                <%=SvgIcon("alert", "")%>
                <div><strong>Revisa el formulario.</strong> <%=H(strFormErr)%></div>
            </div>
            <% End If %>

            <form method="post" action="albums.asp">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="<%=intId%>">

                <div class="form-grid">
                    <div class="field full">
                        <label for="title_album">Titulo del album <span class="req">*</span></label>
                        <input type="text" id="title_album" name="title_album" value="<%=H(fTitle)%>"
                               maxlength="50" required placeholder="Ej. Rock Album">
                    </div>

                    <div class="field">
                        <label for="release_year">Anio de lanzamiento</label>
                        <input type="number" id="release_year" name="release_year" value="<%=H(fYear)%>"
                               min="1900" max="2100" step="1" placeholder="1976">
                    </div>

                    <div class="field">
                        <label for="album_image">Caratula</label>
                        <input type="text" id="album_image" name="album_image" value="<%=H(fImage)%>"
                               maxlength="255" list="dlAlbums" placeholder=".../AlbumImages/album1.png">
                        <% FileDatalist "dlAlbums", RES_ALBUMS, IMG_EXTS %>
                    </div>

                    <% If strFormMode = "edit" Then %>
                    <div class="field full">
                        <label>Tracklist</label>
                        <% If rsSongList.EOF Then %>
                        <div class="hint">
                            <%=SvgIcon("info", "")%>
                            <span>No hay canciones en el catalogo. Crea canciones para poder agregarlas al album.</span>
                        </div>
                        <% Else %>
                        <div class="checks">
                            <%
                            Do While Not rsSongList.EOF
                            %>
                            <label class="check">
                                <input type="checkbox" name="songs" value="<%=rsSongList("ID_SONG")%>"
                                       <% If InStr(fSongs, "," & rsSongList("ID_SONG") & ",") > 0 Then Response.Write " checked" %>>
                                <span><%=H(rsSongList("SONG_NAME"))%></span>
                            </label>
                            <%
                                rsSongList.MoveNext
                            Loop
                            %>
                        </div>
                        <span class="help">Marca las canciones que forman parte de este album (TBL_TRACKLIST).</span>
                        <% End If %>
                    </div>
                    <% Else %>
                    <div class="field full">
                        <div class="hint">
                            <%=SvgIcon("info", "")%>
                            <span>Guarda el album primero. Despues de crearlo podras marcar las canciones de su tracklist.</span>
                        </div>
                    </div>
                    <% End If %>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%=SvgIcon("check", "")%><% If strFormMode = "edit" Then %>Guardar cambios<% Else %>Crear album<% End If %>
                    </button>
                    <a class="btn btn-ghost" href="albums.asp">Cancelar</a>
                </div>
            </form>
        </div>
        <% Else %>
        <div class="card">
            <div class="card-title"><%=SvgIcon("info", "")%>Selecciona un album</div>
            <p class="small muted" style="margin:0">
                Pulsa <strong>Editar</strong> para modificar los datos del album y su tracklist.
            </p>
        </div>
        <% End If %>
    </div>

    <div>
        <%
        Set rsAlbums = OpenRS("SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
                                    "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TOTAL " & _
                                    "FROM TBL_ALBUM al ORDER BY al.TITLE_ALBUM")
        If rsAlbums.EOF Then
        %>
        <div class="empty">
            <%=SvgIcon("disc", "")%>
            <h3>No hay albumes registrados</h3>
            <p>Crea el primer album y asignale sus canciones.</p>
        </div>
        <% Else %>
        <div class="table-wrap">
            <div class="table-scroll">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width:44px">#</th>
                            <th>Album</th>
                            <th class="hide-sm" style="width:90px">Anio</th>
                            <th class="hide-sm">Canciones</th>
                            <th style="width:96px" class="text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        intRow = 0
                        Do While Not rsAlbums.EOF
                            intRow = intRow + 1
                            strImg = ImageUrl(rsAlbums("ALBUM_IMAGE_PATH"), "album")
                            intSongs = IntOr(rsAlbums("TOTAL"), 0)
                        %>
                        <tr>
                            <td class="cell-index"><%=Right("0" & intRow, 2)%></td>
                            <td>
                                <div class="cell-song">
                                    <% ArtBox strImg, rsAlbums("TITLE_ALBUM"), "" %>
                                    <div>
                                        <strong><%=H(rsAlbums("TITLE_ALBUM"))%></strong>
                                        <small>Album</small>
                                    </div>
                                </div>
                            </td>
                            <td class="hide-sm cell-muted"><% If IsNull(rsAlbums("RELEASE_YEAR")) Then %>&mdash;<% Else %><%=rsAlbums("RELEASE_YEAR")%><% End If %></td>
                            <td class="hide-sm">
                                <span class="tag"><%=SvgIcon("music", "")%><%=intSongs%></span>
                            </td>
                            <td>
                                <div class="row-actions">
                                    <a class="icon-btn" href="albums.asp?action=edit&amp;id=<%=rsAlbums("ID_ALBUM")%>"
                                       title="Editar y gestionar tracklist"><%=SvgIcon("edit", "")%></a>
                                    <form class="inline-form" method="post" action="albums.asp"
                                          onsubmit="return confirm('Se eliminara el album <%=Replace(Replace(rsAlbums("TITLE_ALBUM"), "'", ""), """", "")%> y su tracklist. Las canciones no se borran. ¿Continuar?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%=rsAlbums("ID_ALBUM")%>">
                                        <button type="submit" class="icon-btn danger" title="Eliminar">
                                            <%=SvgIcon("trash", "")%>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                            rsAlbums.MoveNext
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
rsSongList.Close
Set rsSongList = Nothing
rsAlbums.Close
Set rsAlbums = Nothing
%>
<!--#include file="../includes/footer.asp"-->
