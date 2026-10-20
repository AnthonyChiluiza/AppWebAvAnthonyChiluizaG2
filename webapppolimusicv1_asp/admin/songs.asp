<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<%
' ==========================================================================
'  admin/songs.asp  -  CRUD de canciones (solo ADMIN)
'  Asocia artistas (TBL_PLAYER) y album (TBL_TRACKLIST)
' ==========================================================================
strPrefix = "../"
strPageTitle = "Canciones"
strActive = "songs"
strCrumb = "<a href=""../home.asp"">Inicio</a> <span class=""sep"">/</span> " & _
           "<a href=""songs.asp"">Canciones</a>"

RequireAdmin

Dim strAct, intId, blnShowForm, strFormMode, blnLoaded
Dim fName, fPath, fPlays, fAlbum, fArtists, strFormErr
Dim rsSongs, rsArtistList, rsAlbumList, strSql
Dim intRow, arrA, i, strArtistId, strArtistsTxt, strAlbumTxt, strSongUrl

strAct = LCase(Req("action"))
intId = IntOr(Req("id"), 0)

blnShowForm = False
blnLoaded = False
strFormMode = "new"
strFormErr = ""
fName = ""
fPath = ""
fPlays = 0
fAlbum = 0
fArtists = ","

' --------------------------------------------------------------------------
'  Procesamiento de acciones (siempre antes de escribir HTML)
' --------------------------------------------------------------------------
If IsPost() And strAct = "save" Then
    fName = FS("song_name")
    fPath = FS("song_path")
    fPlays = IntOr(FS("plays"), 0)
    fAlbum = IntOr(FS("album_id"), 0)
    fArtists = "," & Replace(FS("artists"), " ", "") & ","

    If fName = "" Then
        strFormErr = "El nombre de la cancion es obligatorio."
    ElseIf Len(fName) > 50 Then
        strFormErr = "El nombre no puede superar los 50 caracteres."
    ElseIf fPath = "" Then
        strFormErr = "Debes indicar la ruta del archivo de audio."
    ElseIf Len(fPath) > 255 Then
        strFormErr = "La ruta del archivo es demasiado larga (maximo 255 caracteres)."
    ElseIf fPlays < 0 Then
        strFormErr = "El numero de reproducciones no puede ser negativo."
    End If

    If strFormErr = "" Then
        If intId > 0 Then
            oCnx.Execute "UPDATE TBL_SONG SET SONG_NAME = '" & SqlS(fName) & "', " & _
                         "SONG_PATH = '" & SqlS(fPath) & "', PLAYS = " & fPlays & " " & _
                         "WHERE ID_SONG = " & intId
            SetFlash "ok", "La cancion <strong>" & H(fName) & "</strong> se actualizo correctamente."
        Else
            oCnx.Execute "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) " & _
                         "VALUES ('" & SqlS(fName) & "', '" & SqlS(fPath) & "', " & fPlays & ")"
            intId = NewID("TBL_SONG", "ID_SONG")
            SetFlash "ok", "La cancion <strong>" & H(fName) & "</strong> se creo correctamente."
        End If

        ' Sincroniza artistas (TBL_PLAYER)
        RunSQL "DELETE FROM TBL_PLAYER WHERE ID_SONG = " & intId
        arrA = Split(FS("artists"), ",")
        For i = 0 To UBound(arrA)
            strArtistId = Trim(arrA(i))
            If strArtistId <> "" And IsNumeric(strArtistId) Then
                RunSQL "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (" & intId & ", " & CLng(strArtistId) & ")"
            End If
        Next

        ' Sincroniza album (TBL_TRACKLIST)
        RunSQL "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = " & intId
        If fAlbum > 0 Then
            RunSQL "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (" & fAlbum & ", " & intId & ")"
        End If

        Response.Redirect "songs.asp"
    Else
        blnShowForm = True
        blnLoaded = True
        If intId > 0 Then strFormMode = "edit" Else strFormMode = "new"
    End If
End If

If IsPost() And strAct = "delete" Then
    If intId > 0 Then
        RunSQL "DELETE FROM TBL_PLAYER WHERE ID_SONG = " & intId
        RunSQL "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = " & intId
        RunSQL "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = " & intId
        RunSQL "DELETE FROM TBL_SONG WHERE ID_SONG = " & intId
        SetFlash "ok", "La cancion se elimino del catalogo junto con sus asociaciones."
    End If
    Response.Redirect "songs.asp"
End If

' --------------------------------------------------------------------------
'  Carga del formulario (nuevo / editar)
' --------------------------------------------------------------------------
If Not blnLoaded Then
    If strAct = "new" Then
        blnShowForm = True
        strFormMode = "new"
    ElseIf strAct = "edit" And intId > 0 Then
        Set rsSongs = OpenRS("SELECT ID_SONG, SONG_NAME, SONG_PATH, ISNULL(PLAYS, 0) AS PLAYS " & _
                                   "FROM TBL_SONG WHERE ID_SONG = " & intId)
        If Not rsSongs.EOF Then
            blnShowForm = True
            strFormMode = "edit"
            fName = TrimStr(rsSongs("SONG_NAME"))
            fPath = TrimStr(rsSongs("SONG_PATH"))
            fPlays = IntOr(rsSongs("PLAYS"), 0)
            fAlbum = SongAlbumId(intId)
            fArtists = SongArtistIds(intId)
        End If
        rsSongs.Close
        Set rsSongs = Nothing
    End If
End If

' Listas auxiliares para el formulario
Set rsArtistList = OpenRS("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME")
Set rsAlbumList = OpenRS("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR FROM TBL_ALBUM ORDER BY TITLE_ALBUM")
%>
<!--#include file="../includes/header.asp"-->

<div class="section-head">
    <div>
        <h2><%=SvgIcon("music", "")%>Canciones</h2>
        <p class="section-sub">Crea, edita y elimina las canciones del catalogo. Asigna sus artistas y su album.</p>
    </div>
    <a class="btn btn-primary btn-sm" href="songs.asp?action=new"><%=SvgIcon("plus", "")%>Nueva cancion</a>
</div>

<div class="crud-layout">
    <div class="col-form">
        <% If blnShowForm Then %>
        <div class="card">
            <div class="card-title">
                <%=SvgIcon("edit", "")%>
                <% If strFormMode = "edit" Then %>Editar cancion #<%=intId%><% Else %>Nueva cancion<% End If %>
            </div>

            <% If strFormErr <> "" Then %>
            <div class="flash flash-err" role="alert">
                <%=SvgIcon("alert", "")%>
                <div><strong>Revisa el formulario.</strong> <%=H(strFormErr)%></div>
            </div>
            <% End If %>

            <form method="post" action="songs.asp">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="<%=intId%>">

                <div class="form-grid">
                    <div class="field full">
                        <label for="song_name">Nombre de la cancion <span class="req">*</span></label>
                        <input type="text" id="song_name" name="song_name" value="<%=H(fName)%>"
                               maxlength="50" required placeholder="Ej. Adventure">
                    </div>

                    <div class="field full">
                        <label for="song_path">Ruta del archivo de audio <span class="req">*</span></label>
                        <input type="text" id="song_path" name="song_path" value="<%=H(fPath)%>"
                               maxlength="255" list="dlSongs" required
                               placeholder="SongFilesAndImages_resources/SongFiles/archivo.mp3">
                        <span class="help">Elige un archivo existente de la lista o escribe la ruta relativa al sitio.</span>
                        <% FileDatalist "dlSongs", RES_SONGS, SONG_EXTS %>
                    </div>

                    <div class="field">
                        <label for="plays">Reproducciones</label>
                        <input type="number" id="plays" name="plays" value="<%=fPlays%>" min="0" step="1">
                    </div>

                    <div class="field">
                        <label for="album_id">Album</label>
                        <select id="album_id" name="album_id">
                            <option value="0">Sin album</option>
                            <%
                            Do While Not rsAlbumList.EOF
                            %>
                            <option value="<%=rsAlbumList("ID_ALBUM")%>"<% If IntOr(rsAlbumList("ID_ALBUM"), 0) = fAlbum Then Response.Write " selected" %>>
                                <%=H(rsAlbumList("TITLE_ALBUM"))%><% If Not IsNull(rsAlbumList("RELEASE_YEAR")) Then %> (<%=rsAlbumList("RELEASE_YEAR")%>)<% End If %>
                            </option>
                            <%
                                rsAlbumList.MoveNext
                            Loop
                            %>
                        </select>
                    </div>

                    <div class="field full">
                        <label>Artistas</label>
                        <% If rsArtistList.EOF Then %>
                        <div class="hint">
                            <%=SvgIcon("info", "")%>
                            <span>No hay artistas registrados. Crea artistas primero para poder asociarlos a la cancion.</span>
                        </div>
                        <% Else %>
                        <div class="checks">
                            <%
                            Do While Not rsArtistList.EOF
                                strArtistId = "," & rsArtistList("ID_ARTIST") & ","
                            %>
                            <label class="check">
                                <input type="checkbox" name="artists" value="<%=rsArtistList("ID_ARTIST")%>"
                                       <% If InStr(fArtists, strArtistId) > 0 Then Response.Write " checked" %>>
                                <span><%=H(TrimStr(rsArtistList("ARTIST_NAME")) & " " & TrimStr(rsArtistList("ARTIST_LASTNAME")))%></span>
                            </label>
                            <%
                                rsArtistList.MoveNext
                            Loop
                            %>
                        </div>
                        <span class="help">Una cancion puede tener varios artistas (relacion N:M en TBL_PLAYER).</span>
                        <% End If %>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%=SvgIcon("check", "")%><% If strFormMode = "edit" Then %>Guardar cambios<% Else %>Crear cancion<% End If %>
                    </button>
                    <a class="btn btn-ghost" href="songs.asp">Cancelar</a>
                </div>
            </form>
        </div>
        <% Else %>
        <div class="card">
            <div class="card-title"><%=SvgIcon("info", "")%>Selecciona una cancion</div>
            <p class="small muted" style="margin:0">
                Elige <strong>Editar</strong> en la tabla para modificar una cancion existente o pulsa
                <strong>Nueva cancion</strong> para agregar una al catalogo.
            </p>
        </div>
        <% End If %>
    </div>

    <div>
        <%
        Set rsSongs = OpenRS("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
            "STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + NULLIF(a.ARTIST_LASTNAME, ''), '') " & _
            "FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
            "WHERE p.ID_SONG = s.ID_SONG ORDER BY a.ARTIST_NAME FOR XML PATH('')), 1, 2, '') AS ARTISTS, " & _
            "STUFF((SELECT ', ' + al.TITLE_ALBUM FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
            "WHERE t.ID_SONG = s.ID_SONG FOR XML PATH('')), 1, 2, '') AS ALBUMS " & _
            "FROM TBL_SONG s ORDER BY s.SONG_NAME")

        If rsSongs.EOF Then
        %>
        <div class="empty">
            <%=SvgIcon("music", "")%>
            <h3>El catalogo esta vacio</h3>
            <p>Usa el formulario para registrar la primera cancion.</p>
        </div>
        <% Else %>
        <div class="table-wrap">
            <div class="table-scroll">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width:44px">#</th>
                            <th>Cancion</th>
                            <th class="hide-sm">Artistas</th>
                            <th class="hide-sm">Album</th>
                            <th style="width:80px">Plays</th>
                            <th style="width:96px" class="text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        intRow = 0
                        Do While Not rsSongs.EOF
                            intRow = intRow + 1
                            strArtistsTxt = TrimStr(rsSongs("ARTISTS"))
                            strAlbumTxt = TrimStr(rsSongs("ALBUMS"))
                            strSongUrl = SongUrl(rsSongs("SONG_PATH"))
                            If strArtistsTxt = "" Then strArtistsTxt = "Sin artista"
                            If strAlbumTxt = "" Then strAlbumTxt = "Sin album"
                        %>
                        <tr>
                            <td class="cell-index"><%=Right("0" & intRow, 2)%></td>
                            <td>
                                <div class="cell-song">
                                    <% ArtBox "", rsSongs("SONG_NAME"), "" %>
                                    <div>
                                        <strong><%=H(rsSongs("SONG_NAME"))%></strong>
                                        <small><%=H(Trunc(FileBaseName(rsSongs("SONG_PATH")), 30))%></small>
                                    </div>
                                </div>
                            </td>
                            <td class="hide-sm cell-muted"><%=H(strArtistsTxt)%></td>
                            <td class="hide-sm cell-muted"><%=H(strAlbumTxt)%></td>
                            <td class="cell-num"><%=IntOr(rsSongs("PLAYS"), 0)%></td>
                            <td>
                                <div class="row-actions">
                                    <a class="icon-btn" href="songs.asp?action=edit&amp;id=<%=rsSongs("ID_SONG")%>"
                                       title="Editar <%=H(rsSongs("SONG_NAME"))%>"><%=SvgIcon("edit", "")%></a>
                                    <form class="inline-form" method="post" action="songs.asp"
                                          onsubmit="return confirm('Se eliminara la cancion <%=Replace(Replace(rsSongs("SONG_NAME"), "'", ""), """", "")%> y sus asociaciones con artistas, albumes y playlists. ¿Continuar?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%=rsSongs("ID_SONG")%>">
                                        <button type="submit" class="icon-btn danger" title="Eliminar">
                                            <%=SvgIcon("trash", "")%>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                            rsSongs.MoveNext
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
rsArtistList.Close
Set rsArtistList = Nothing
rsAlbumList.Close
Set rsAlbumList = Nothing
rsSongs.Close
Set rsSongs = Nothing
%>
<!--#include file="../includes/footer.asp"-->
