<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/cnx.asp"-->
<!--#include file="includes/helpers.asp"-->
<%
' ==========================================================================
'  home.asp  -  Dashboard principal de PolyMusic
'  Muestra bienvenida, rol, metricas, "Song List", albumes, artistas y playlists
' ==========================================================================
strPrefix = ""
strPageTitle = "Inicio"
strActive = "home"

RequireLogin

Dim rsSongs, rsAlbums, rsArtists, rsPl
Dim strSql, strPlWhere
Dim intSongCount, intArtistCount, intAlbumCount, intPlaylistCount
Dim intRow, strSongUrl, strArtistsTxt, strAlbumTxt, strFileTxt
Dim strImg, strTypeLbl, strTypeCls, strOwner

intSongCount = GetCount("SELECT COUNT(*) FROM TBL_SONG")
intArtistCount = GetCount("SELECT COUNT(*) FROM TBL_ARTIST")
intAlbumCount = GetCount("SELECT COUNT(*) FROM TBL_ALBUM")

If IsAdmin() Then
    intPlaylistCount = GetCount("SELECT COUNT(*) FROM TBL_PLAYLIST")
    strPlWhere = ""
Else
    intPlaylistCount = GetCount("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE ID_USER = " & CurrentUserId())
    strPlWhere = " WHERE p.ID_USER = " & CurrentUserId()
End If

' Canciones con sus artistas y albumes agregados
strSql = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
         "STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + NULLIF(a.ARTIST_LASTNAME, ''), '') " & _
         "       FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
         "       WHERE p.ID_SONG = s.ID_SONG ORDER BY a.ARTIST_NAME FOR XML PATH('')), 1, 2, '') AS ARTISTS, " & _
         "STUFF((SELECT ', ' + al.TITLE_ALBUM " & _
         "       FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
         "       WHERE t.ID_SONG = s.ID_SONG ORDER BY al.TITLE_ALBUM FOR XML PATH('')), 1, 2, '') AS ALBUMS " & _
         "FROM TBL_SONG s ORDER BY s.SONG_NAME"
Set rsSongs = OpenRS(strSql)

' Albumes con numero de canciones
Set rsAlbums = OpenRS("SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
                            "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TOTAL " & _
                            "FROM TBL_ALBUM al ORDER BY al.TITLE_ALBUM")

' Artistas con numero de canciones
Set rsArtists = OpenRS("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
                             "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS TOTAL " & _
                             "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME")

' Playlists visibles segun el rol
Set rsPl = OpenRS("SELECT p.ID_PLAYLIST, p.TITLE, p.CREATION_DATE, p.TYPE, p.PHOTO, u.USERNAME, " & _
                        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS TOTAL " & _
                        "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER" & strPlWhere & _
                        " ORDER BY p.TITLE")
%>
<!--#include file="includes/header.asp"-->

<section class="hero">
    <div class="hero-content">
        <span class="hero-badge">
            <% If IsAdmin() Then %><%=SvgIcon("shield", "")%> Administrador<% Else %><%=SvgIcon("user", "")%> Usuario<% End If %>
        </span>
        <h1>Bienvenido/a, <%=H(Session("USERNAME"))%></h1>
        <p>
            <% If IsAdmin() Then %>
            Tienes acceso completo al catalogo: puedes administrar canciones, artistas, albumes,
            usuarios y todas las playlists del sistema.
            <% Else %>
            Esta es tu biblioteca musical. Escucha el catalogo y organiza tus canciones favoritas
            en tus propias playlists.
            <% End If %>
        </p>
    </div>
    <div class="hero-actions">
        <a class="btn btn-ghost-light" href="#songs"><%=SvgIcon("music", "")%>Ir al Song List</a>
        <% If IsAdmin() Then %>
        <a class="btn btn-ghost-light" href="admin/songs.asp?action=new"><%=SvgIcon("plus", "")%>Nueva cancion</a>
        <a class="btn btn-ghost-light" href="admin/playlists.asp"><%=SvgIcon("list", "")%>Gestionar playlists</a>
        <% Else %>
        <a class="btn btn-ghost-light" href="user/playlists.asp"><%=SvgIcon("list", "")%>Mis playlists</a>
        <% End If %>
    </div>
</section>

<div class="stats">
    <div class="stat">
        <span class="stat-ico"><%=SvgIcon("music", "")%></span>
        <div>
            <div class="stat-val"><%=intSongCount%></div>
            <div class="stat-lbl">Canciones</div>
        </div>
    </div>
    <div class="stat">
        <span class="stat-ico"><%=SvgIcon("mic", "")%></span>
        <div>
            <div class="stat-val"><%=intArtistCount%></div>
            <div class="stat-lbl">Artistas</div>
        </div>
    </div>
    <div class="stat">
        <span class="stat-ico"><%=SvgIcon("disc", "")%></span>
        <div>
            <div class="stat-val"><%=intAlbumCount%></div>
            <div class="stat-lbl">Albumes</div>
        </div>
    </div>
    <div class="stat">
        <span class="stat-ico"><%=SvgIcon("list", "")%></span>
        <div>
            <div class="stat-val"><%=intPlaylistCount%></div>
            <div class="stat-lbl"><% If IsAdmin() Then %>Playlists totales<% Else %>Mis playlists<% End If %></div>
        </div>
    </div>
</div>

<!-- ===================== SONG LIST ===================== -->
<section class="section" id="songs">
    <div class="section-head">
        <div>
            <h2><%=SvgIcon("music", "")%>Song List</h2>
            <p class="section-sub">
                <%=intSongCount%> <%=Plural(intSongCount, "cancion disponible", "canciones disponibles")%>.
                Pulsa el boton de reproduccion para escucharla en el reproductor inferior.
            </p>
        </div>
        <div class="search">
            <%=SvgIcon("search", "")%>
            <input type="search" id="pmSearch" placeholder="Buscar cancion, artista o album..."
                   aria-label="Buscar en la lista de canciones" autocomplete="off">
            <span class="search-hint" aria-hidden="true">/</span>
        </div>
    </div>

    <% If rsSongs.EOF Then %>
    <div class="empty">
        <%=SvgIcon("music", "")%>
        <h3>Todavia no hay canciones</h3>
        <p>El catalogo esta vacio. Ejecuta el script de la base de datos o agrega canciones desde el panel.</p>
        <% If IsAdmin() Then %>
        <a class="btn btn-primary" href="admin/songs.asp?action=new"><%=SvgIcon("plus", "")%>Agregar la primera cancion</a>
        <% End If %>
    </div>
    <% Else %>
    <div class="table-wrap">
        <div class="table-scroll">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width:52px">#</th>
                        <th>Cancion</th>
                        <th class="hide-sm">Artistas</th>
                        <th class="hide-sm">Album</th>
                        <th style="width:130px">Reproducciones</th>
                        <th style="width:70px" class="text-right">Play</th>
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
                        strFileTxt = FileBaseName(rsSongs("SONG_PATH"))
                        If strArtistsTxt = "" Then strArtistsTxt = "Sin artista asignado"
                        If strAlbumTxt = "" Then strAlbumTxt = "Sin album"
                    %>
                    <tr class="song-row"
                        data-id="<%=rsSongs("ID_SONG")%>"
                        data-name="<%=H(rsSongs("SONG_NAME"))%>"
                        data-artist="<%=H(strArtistsTxt)%>"
                        data-album="<%=H(strAlbumTxt)%>"
                        data-url="<%=H(strSongUrl)%>"
                        data-plays="<%=IntOr(rsSongs("PLAYS"), 0)%>">
                        <td class="cell-index"><%=Right("0" & intRow, 2)%></td>
                        <td>
                            <div class="cell-song">
                                <% ArtBox "", rsSongs("SONG_NAME"), "" %>
                                <div>
                                    <strong><%=H(rsSongs("SONG_NAME"))%></strong>
                                    <small><%=H(Trunc(strFileTxt, 34))%></small>
                                </div>
                            </div>
                        </td>
                        <td class="hide-sm"><%=H(strArtistsTxt)%></td>
                        <td class="hide-sm"><span class="tag"><%=SvgIcon("disc", "")%><%=H(strAlbumTxt)%></span></td>
                        <td class="cell-num plays-cell" data-id="<%=rsSongs("ID_SONG")%>"><%=IntOr(rsSongs("PLAYS"), 0)%></td>
                        <td class="text-right">
                            <button type="button" class="btn-play" title="Reproducir <%=H(rsSongs("SONG_NAME"))%>"
                                    aria-label="Reproducir <%=H(rsSongs("SONG_NAME"))%>">
                                <%=SvgIcon("play", "")%>
                            </button>
                        </td>
                    </tr>
                    <%
                        rsSongs.MoveNext
                    Loop
                    %>
                    <tr id="pmSearchEmpty" style="display:none">
                        <td colspan="6" class="cell-muted" style="text-align:center;padding:26px">
                            No se encontraron canciones con ese criterio. Prueba con otra palabra.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <% End If %>
</section>

<!-- ===================== ALBUMES ===================== -->
<section class="section" id="albums">
    <div class="section-head">
        <div>
            <h2><%=SvgIcon("disc", "")%>Albumes</h2>
            <p class="section-sub">Los albumes que forman parte del catalogo.</p>
        </div>
        <% If IsAdmin() Then %>
        <a class="btn btn-ghost btn-sm" href="admin/albums.asp"><%=SvgIcon("edit", "")%>Administrar albumes</a>
        <% End If %>
    </div>

    <% If rsAlbums.EOF Then %>
    <div class="empty">
        <%=SvgIcon("disc", "")%>
        <h3>Sin albumes registrados</h3>
        <p>Cuando agregues albumes apareceran aqui con su caratula y numero de canciones.</p>
    </div>
    <% Else %>
    <div class="grid-cards">
        <%
        Do While Not rsAlbums.EOF
            strImg = ImageUrl(rsAlbums("ALBUM_IMAGE_PATH"), "album")
        %>
        <article class="media-card">
            <div class="cover">
                <% ArtBox strImg, rsAlbums("TITLE_ALBUM"), "art-lg" %>
            </div>
            <div>
                <h3 title="<%=H(rsAlbums("TITLE_ALBUM"))%>"><%=H(rsAlbums("TITLE_ALBUM"))%></h3>
                <p class="meta">
                    <% If Not IsNull(rsAlbums("RELEASE_YEAR")) Then %><%=rsAlbums("RELEASE_YEAR")%> &middot; <% End If %>
                    <%=IntOr(rsAlbums("TOTAL"), 0)%> <%=Plural(IntOr(rsAlbums("TOTAL"), 0), "cancion", "canciones")%>
                </p>
            </div>
        </article>
        <%
            rsAlbums.MoveNext
        Loop
        %>
    </div>
    <% End If %>
</section>

<!-- ===================== ARTISTAS ===================== -->
<section class="section" id="artists">
    <div class="section-head">
        <div>
            <h2><%=SvgIcon("mic", "")%>Artistas</h2>
            <p class="section-sub">Interpretes que participan en las canciones del catalogo.</p>
        </div>
        <% If IsAdmin() Then %>
        <a class="btn btn-ghost btn-sm" href="admin/artists.asp"><%=SvgIcon("edit", "")%>Administrar artistas</a>
        <% End If %>
    </div>

    <% If rsArtists.EOF Then %>
    <div class="empty">
        <%=SvgIcon("mic", "")%>
        <h3>Sin artistas registrados</h3>
        <p>Agrega artistas para poder asociarlos a las canciones del catalogo.</p>
    </div>
    <% Else %>
    <div class="grid-cards-sm">
        <%
        Do While Not rsArtists.EOF
            strImg = ImageUrl(rsArtists("ARTIST_IMAGE"), "artist")
            strArtistsTxt = TrimStr(rsArtists("ARTIST_NAME")) & " " & TrimStr(rsArtists("ARTIST_LASTNAME"))
        %>
        <article class="media-card" style="align-items:center;text-align:center">
            <% ArtBox strImg, strArtistsTxt, "art-md art-round" %>
            <div style="min-width:0;width:100%">
                <h3 title="<%=H(strArtistsTxt)%>"><%=H(TrimStr(rsArtists("ARTIST_NAME")))%></h3>
                <p class="meta">
                    <%=H(TrimStr(rsArtists("ARTIST_LASTNAME")))%><br>
                    <%=IntOr(rsArtists("TOTAL"), 0)%> <%=Plural(IntOr(rsArtists("TOTAL"), 0), "cancion", "canciones")%>
                </p>
            </div>
        </article>
        <%
            rsArtists.MoveNext
        Loop
        %>
    </div>
    <% End If %>
</section>

<!-- ===================== PLAYLISTS ===================== -->
<section class="section" id="playlists">
    <div class="section-head">
        <div>
            <h2><%=SvgIcon("list", "")%><% If IsAdmin() Then %>Playlists del sistema<% Else %>Mis playlists<% End If %></h2>
            <p class="section-sub">
                <% If IsAdmin() Then %>
                Todas las playlists creadas por los usuarios del sistema.
                <% Else %>
                Solo tu puedes ver y editar estas playlists.
                <% End If %>
            </p>
        </div>
        <% If IsAdmin() Then %>
        <a class="btn btn-ghost btn-sm" href="admin/playlists.asp"><%=SvgIcon("plus", "")%>Gestionar</a>
        <% Else %>
        <a class="btn btn-primary btn-sm" href="user/playlists.asp"><%=SvgIcon("plus", "")%>Nueva playlist</a>
        <% End If %>
    </div>

    <% If rsPl.EOF Then %>
    <div class="empty">
        <%=SvgIcon("list", "")%>
        <h3><% If IsAdmin() Then %>Aun no hay playlists<% Else %>Todavia no tienes playlists<% End If %></h3>
        <p>Crea una playlist y empieza a agrupar tus canciones favoritas.</p>
        <a class="btn btn-primary" href="<% If IsAdmin() Then %>admin<% Else %>user<% End If %>/playlists.asp?action=new">
            <%=SvgIcon("plus", "")%>Crear mi primera playlist
        </a>
    </div>
    <% Else %>
    <div class="grid-cards">
        <%
        Do While Not rsPl.EOF
            strImg = ImageUrl(rsPl("PHOTO"), "playlist")
            If IntOr(rsPl("TYPE"), 0) = 1 Then
                strTypeCls = "badge-private"
            Else
                strTypeCls = "badge-public"
            End If
            strTypeLbl = CatalogName("2", IntOr(rsPl("TYPE"), 0), "Public")
        %>
        <article class="media-card">
            <div class="cover">
                <% ArtBox strImg, rsPl("TITLE"), "art-lg" %>
            </div>
            <div>
                <h3 title="<%=H(rsPl("TITLE"))%>"><%=H(rsPl("TITLE"))%></h3>
                <p class="meta" style="margin-bottom:8px">
                    <%=IntOr(rsPl("TOTAL"), 0)%> <%=Plural(IntOr(rsPl("TOTAL"), 0), "cancion", "canciones")%>
                    <% If IsAdmin() Then %> &middot; <%=H(rsPl("USERNAME"))%><% End If %>
                </p>
                <span class="badge <%=strTypeCls%>"><%=H(strTypeLbl)%></span>
            </div>
        </article>
        <%
            rsPl.MoveNext
        Loop
        %>
    </div>
    <% End If %>
</section>

<%
' Cierre de recordsets antes de liberar la conexion
rsSongs.Close
Set rsSongs = Nothing
rsAlbums.Close
Set rsAlbums = Nothing
rsArtists.Close
Set rsArtists = Nothing
rsPl.Close
Set rsPl = Nothing
%>
<!--#include file="includes/footer.asp"-->
