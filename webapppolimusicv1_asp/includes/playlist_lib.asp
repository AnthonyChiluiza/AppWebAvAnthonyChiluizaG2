<%
' ==========================================================================
'  includes/playlist_lib.asp
'  Logica compartida del CRUD de playlists.
'  Se usa desde admin/playlists.asp (todas) y user/playlists.asp (propias).
' ==========================================================================

' --------------------------------------------------------------------------
'  Procesa las acciones POST del modulo (llamar antes de escribir HTML)
' --------------------------------------------------------------------------
Sub PlaylistHandlePost(blnAdmin)
    Dim strAct, intId, strTitle, intType, strPhoto, strErr
    Dim intOwner, intSong

    strAct = LCase(Req("action"))
    intId = IntOr(Req("id"), 0)

    ' ---------------- Guardar (crear o editar) ----------------
    If strAct = "save" And IsPost() Then
        strTitle = FS("title")
        intType = IntOr(FS("ptype"), 0)
        strPhoto = FS("photo")
        strErr = ""

        If strTitle = "" Then
            strErr = "El titulo de la playlist es obligatorio."
        ElseIf Len(strTitle) > 50 Then
            strErr = "El titulo no puede superar los 50 caracteres."
        End If

        If intId > 0 And strErr = "" Then
            If Not blnAdmin Then
                If PlaylistOwner(intId) <> CurrentUserId() Then
                    strErr = "No tienes permiso para modificar esta playlist."
                End If
            End If
        End If

        If strErr <> "" Then
            SetFlash "err", strErr
            If intId > 0 Then
                Response.Redirect "playlists.asp?action=edit&id=" & intId
            Else
                Response.Redirect "playlists.asp?action=new"
            End If
        End If

        If intId > 0 Then
            oCnx.Execute "UPDATE TBL_PLAYLIST SET TITLE = '" & SqlS(strTitle) & "', " & _
                         "TYPE = " & intType & ", PHOTO = '" & SqlS(strPhoto) & "' " & _
                         "WHERE ID_PLAYLIST = " & intId
            SetFlash "ok", "La playlist <strong>" & H(strTitle) & "</strong> se actualizo correctamente."
        Else
            intOwner = CurrentUserId()
            oCnx.Execute "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) " & _
                         "VALUES (" & intOwner & ", '" & SqlS(strTitle) & "', GETDATE(), " & intType & ", '" & SqlS(strPhoto) & "')"
            intId = NewID("TBL_PLAYLIST", "ID_PLAYLIST")
            SetFlash "ok", "Playlist <strong>" & H(strTitle) & "</strong> creada. Ahora puedes agregarle canciones."
        End If

        Response.Redirect "playlists.asp?action=edit&id=" & intId
    End If

    ' ---------------- Eliminar ----------------
    If strAct = "delete" And IsPost() Then
        If intId > 0 Then
            If blnAdmin Or PlaylistOwner(intId) = CurrentUserId() Then
                RunSQL "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = " & intId
                RunSQL "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = " & intId
                SetFlash "ok", "La playlist se elimino correctamente."
            Else
                SetFlash "err", "No tienes permiso para eliminar esta playlist."
            End If
        End If
        Response.Redirect "playlists.asp"
    End If

    ' ---------------- Agregar cancion ----------------
    If strAct = "addsong" And IsPost() Then
        intSong = IntOr(FS("song_id"), 0)
        If intId > 0 And intSong > 0 Then
            If blnAdmin Or PlaylistOwner(intId) = CurrentUserId() Then
                If GetCount("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = " & intId & _
                            " AND ID_SONG = " & intSong) > 0 Then
                    SetFlash "warn", "Esa cancion ya forma parte de la playlist."
                Else
                    RunSQL "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (" & intId & ", " & intSong & ")"
                    SetFlash "ok", "Cancion agregada a la playlist."
                End If
            Else
                SetFlash "err", "No tienes permiso para modificar esta playlist."
            End If
        End If
        Response.Redirect "playlists.asp?action=edit&id=" & intId
    End If

    ' ---------------- Quitar cancion ----------------
    If strAct = "removesong" And IsPost() Then
        intSong = IntOr(FS("song_id"), 0)
        If intId > 0 And intSong > 0 Then
            If blnAdmin Or PlaylistOwner(intId) = CurrentUserId() Then
                RunSQL "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = " & intId & " AND ID_SONG = " & intSong
                SetFlash "ok", "Cancion quitada de la playlist."
            Else
                SetFlash "err", "No tienes permiso para modificar esta playlist."
            End If
        End If
        Response.Redirect "playlists.asp?action=edit&id=" & intId
    End If
End Sub


' --------------------------------------------------------------------------
'  Dibuja la pantalla completa del gestor de playlists
' --------------------------------------------------------------------------
Sub RenderPlaylistManager(blnAdmin)
    Dim rsList, strSql, intEdit, strMode, blnNew, blnCanEdit
    Dim strImg, strTypeLbl, strTypeCls, intTotal
    Dim fTitle, fType, fPhoto, rsSongs, rsPick, intSongCount

    intEdit = IntOr(Req("id"), 0)
    strMode = LCase(Req("action"))
    If strMode <> "edit" And strMode <> "new" Then
        strMode = "list"
    End If
    If strMode = "new" Then
        intEdit = 0
    End If

    ' ======================= Listado de playlists =======================
    strSql = "SELECT p.ID_PLAYLIST, p.TITLE, p.CREATION_DATE, p.TYPE, p.PHOTO, p.ID_USER, u.USERNAME, " & _
             "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS TOTAL " & _
             "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER "
    If Not blnAdmin Then
        strSql = strSql & "WHERE p.ID_USER = " & CurrentUserId() & " "
    End If
    strSql = strSql & "ORDER BY p.TITLE"

    Set rsList = OpenRS(strSql)

    If rsList.EOF Then
        Response.Write "<div class=""empty"">" & SvgIcon("list", "") & _
                       "<h3>Aun no hay playlists</h3>" & _
                       "<p>Crea tu primera playlist y empieza a reunir tus canciones favoritas.</p>" & _
                       "<a class=""btn btn-primary"" href=""playlists.asp?action=new"">" & SvgIcon("plus", "") & "Crear playlist</a>" & _
                       "</div>"
    Else
        Response.Write "<div class=""grid-cards"">"
        Do While Not rsList.EOF
            strImg = ImageUrl(rsList("PHOTO"), "playlist")
            intTotal = IntOr(rsList("TOTAL"), 0)
            If IntOr(rsList("TYPE"), 0) = 1 Then
                strTypeCls = "badge-private"
            Else
                strTypeCls = "badge-public"
            End If
            strTypeLbl = CatalogName("2", IntOr(rsList("TYPE"), 0), "Public")

            Response.Write "<article class=""media-card"">"
            Response.Write "<div class=""cover"">"
            ArtBox strImg, rsList("TITLE"), "art-lg"
            Response.Write "</div>"
            Response.Write "<div style=""min-width:0"">"
            Response.Write "<h3 title=""" & H(rsList("TITLE")) & """>" & H(rsList("TITLE")) & "</h3>"
            Response.Write "<p class=""meta"" style=""margin-bottom:8px"">" & intTotal & " " & _
                           Plural(intTotal, "cancion", "canciones")
            If blnAdmin Then
                Response.Write " &middot; " & H(rsList("USERNAME"))
            End If
            Response.Write "</p>"
            Response.Write "<span class=""badge " & strTypeCls & """>" & H(strTypeLbl) & "</span>"
            Response.Write "</div>"

            Response.Write "<div class=""row-actions"" style=""justify-content:flex-start;margin-top:auto;padding-top:4px"">"
            Response.Write "<a class=""icon-btn"" href=""playlists.asp?action=edit&amp;id=" & rsList("ID_PLAYLIST") & _
                           """ title=""Editar playlist"">" & SvgIcon("edit", "") & "</a>"
            Response.Write "<form class=""inline-form"" method=""post"" action=""playlists.asp"" " & _
                           "onsubmit=""return confirm('Se eliminara la playlist y sus canciones asociadas. ¿Continuar?');"">" & _
                           "<input type=""hidden"" name=""action"" value=""delete"">" & _
                           "<input type=""hidden"" name=""id"" value=""" & rsList("ID_PLAYLIST") & """>" & _
                           "<button type=""submit"" class=""icon-btn danger"" title=""Eliminar playlist"">" & _
                           SvgIcon("trash", "") & "</button></form>"
            Response.Write "</div>"
            Response.Write "</article>"

            rsList.MoveNext
        Loop
        Response.Write "</div>"
    End If
    rsList.Close
    Set rsList = Nothing

    ' ======================= Editor =======================
    If strMode = "list" Then
        Exit Sub
    End If

    blnNew = (strMode = "new")
    blnCanEdit = True
    fTitle = ""
    fType = 0
    fPhoto = ""

    If Not blnNew Then
        Set rsList = OpenRS("SELECT p.ID_PLAYLIST, p.TITLE, p.TYPE, p.PHOTO, p.ID_USER, u.USERNAME " & _
                                  "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
                                  "WHERE p.ID_PLAYLIST = " & intEdit)
        If rsList.EOF Then
            rsList.Close
            Set rsList = Nothing
            Response.Write "<div class=""flash flash-err"">" & SvgIcon("alert", "") & _
                           "<div>La playlist solicitada no existe.</div></div>"
            Exit Sub
        End If

        blnCanEdit = blnAdmin Or (IntOr(rsList("ID_USER"), 0) = CurrentUserId())
        fTitle = TrimStr(rsList("TITLE"))
        fType = IntOr(rsList("TYPE"), 0)
        fPhoto = TrimStr(rsList("PHOTO"))
        rsList.Close
        Set rsList = Nothing
    End If

    Response.Write "<div class=""section-head"" style=""margin-top:34px"">"
    If blnNew Then
        Response.Write "<div><h2>" & SvgIcon("plus", "") & "Nueva playlist</h2>"
        Response.Write "<p class=""section-sub"">Ponle un titulo, define su visibilidad y elige una portada.</p></div>"
    Else
        Response.Write "<div><h2>" & SvgIcon("edit", "") & "Editar playlist</h2>"
        Response.Write "<p class=""section-sub"">Cambia el titulo, la visibilidad y las canciones de la playlist.</p></div>"
    End If
    Response.Write "<a class=""btn btn-ghost btn-sm"" href=""playlists.asp"">" & SvgIcon("back", "") & "Volver al listado</a>"
    Response.Write "</div>"

    If Not blnCanEdit Then
        Response.Write "<div class=""flash flash-err"">" & SvgIcon("alert", "") & _
                       "<div>No tienes permiso para editar esta playlist.</div></div>"
        Exit Sub
    End If

    Response.Write "<div class=""crud-layout"">"

    ' ---- Formulario ----
    Response.Write "<div class=""col-form""><div class=""card"">"
    Response.Write "<div class=""card-title"">" & SvgIcon("list", "") & "Datos de la playlist</div>"
    Response.Write "<form method=""post"" action=""playlists.asp"">"
    Response.Write "<input type=""hidden"" name=""action"" value=""save"">"
    Response.Write "<input type=""hidden"" name=""id"" value=""" & intEdit & """>"
    Response.Write "<div class=""form-grid"">"

    Response.Write "<div class=""field full""><label for=""title"">Titulo <span class=""req"">*</span></label>"
    Response.Write "<input type=""text"" id=""title"" name=""title"" value=""" & H(fTitle) & """ maxlength=""50"" required></div>"

    Response.Write "<div class=""field full""><label for=""ptype"">Visibilidad</label>"
    Response.Write "<select id=""ptype"" name=""ptype"">"
    CatalogOptions "2", fType
    Response.Write "</select>"
    Response.Write "<span class=""help"">Public: visible para todos. Private: solo para ti.</span></div>"

    Response.Write "<div class=""field full""><label for=""photo"">Portada</label>"
    Response.Write "<input type=""text"" id=""photo"" name=""photo"" value=""" & H(fPhoto) & """ maxlength=""255"" list=""dlPlaylists"">"
    FileDatalist "dlPlaylists", RES_PLAYLISTS, IMG_EXTS
    Response.Write "<span class=""help"">Si no eliges portada se usara un degradado con la inicial del titulo.</span></div>"

    Response.Write "</div>"
    Response.Write "<div class=""form-actions"">"
    If blnNew Then
        Response.Write "<button type=""submit"" class=""btn btn-primary"">" & SvgIcon("check", "") & "Crear playlist</button>"
    Else
        Response.Write "<button type=""submit"" class=""btn btn-primary"">" & SvgIcon("check", "") & "Guardar cambios</button>"
    End If
    Response.Write "<a class=""btn btn-ghost"" href=""playlists.asp"">Cancelar</a>"
    Response.Write "</div></form></div></div>"

    ' ---- Canciones (solo en playlists existentes) ----
    If blnNew Then
        Response.Write "<div class=""card""><div class=""card-title"">" & SvgIcon("info", "") & "Siguiente paso</div>"
        Response.Write "<p class=""small muted"" style=""margin:0"">Guarda la playlist para poder agregarle canciones del catalogo.</p>"
        Response.Write "</div></div>"
        Exit Sub
    End If

    Set rsSongs = OpenRS("SELECT s.ID_SONG, s.SONG_NAME, ISNULL(s.PLAYS, 0) AS PLAYS " & _
                               "FROM TBL_PLAYLIST_SONG ps INNER JOIN TBL_SONG s ON s.ID_SONG = ps.ID_SONG " & _
                               "WHERE ps.ID_PLAYLIST = " & intEdit & " ORDER BY s.SONG_NAME")
    intSongCount = 0

    Response.Write "<div><div class=""card"">"
    Response.Write "<div class=""card-title"">" & SvgIcon("music", "") & "Canciones de la playlist</div>"

    If rsSongs.EOF Then
        Response.Write "<div class=""empty"" style=""padding:30px 18px"">" & SvgIcon("music", "") & _
                       "<h3>Playlist vacia</h3><p>Agrega canciones usando el selector de abajo.</p></div>"
    Else
        Response.Write "<div class=""table-scroll""><table class=""table"">"
        Response.Write "<thead><tr><th style=""width:44px"">#</th><th>Cancion</th>" & _
                       "<th style=""width:80px"">Plays</th><th style=""width:64px"" class=""text-right"">Quitar</th></tr></thead><tbody>"
        Do While Not rsSongs.EOF
            intSongCount = intSongCount + 1
            Response.Write "<tr>"
            Response.Write "<td class=""cell-index"">" & Right("0" & intSongCount, 2) & "</td>"
            Response.Write "<td><div class=""cell-song"">"
            ArtBox "", rsSongs("SONG_NAME"), ""
            Response.Write "<div><strong>" & H(rsSongs("SONG_NAME")) & "</strong></div></div></td>"
            Response.Write "<td class=""cell-num"">" & IntOr(rsSongs("PLAYS"), 0) & "</td>"
            Response.Write "<td><div class=""row-actions"">"
            Response.Write "<form class=""inline-form"" method=""post"" action=""playlists.asp"" " & _
                           "onsubmit=""return confirm('¿Quitar esta cancion de la playlist?');"">" & _
                           "<input type=""hidden"" name=""action"" value=""removesong"">" & _
                           "<input type=""hidden"" name=""id"" value=""" & intEdit & """>" & _
                           "<input type=""hidden"" name=""song_id"" value=""" & rsSongs("ID_SONG") & """>" & _
                           "<button type=""submit"" class=""icon-btn danger"" title=""Quitar de la playlist"">" & _
                           SvgIcon("trash", "") & "</button></form>"
            Response.Write "</div></td></tr>"
            rsSongs.MoveNext
        Loop
        Response.Write "</tbody></table></div>"
    End If
    rsSongs.Close
    Set rsSongs = Nothing

    ' Selector para agregar canciones
    Set rsPick = OpenRS("SELECT ID_SONG, SONG_NAME FROM TBL_SONG WHERE ID_SONG NOT IN " & _
                              "(SELECT ID_SONG FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = " & intEdit & ") " & _
                              "ORDER BY SONG_NAME")
    Response.Write "<div class=""divider""></div>"
    If rsPick.EOF Then
        Response.Write "<div class=""hint"">" & SvgIcon("check", "") & _
                       "<span>Todas las canciones del catalogo ya estan en esta playlist.</span></div>"
    Else
        Response.Write "<form method=""post"" action=""playlists.asp"" class=""flex"" style=""align-items:flex-end"">"
        Response.Write "<input type=""hidden"" name=""action"" value=""addsong"">"
        Response.Write "<input type=""hidden"" name=""id"" value=""" & intEdit & """>"
        Response.Write "<div class=""field"" style=""flex:1 1 240px"">"
        Response.Write "<label for=""song_id"">Agregar cancion</label>"
        Response.Write "<select id=""song_id"" name=""song_id"" required>"
        Response.Write "<option value="""">Selecciona una cancion...</option>"
        Do While Not rsPick.EOF
            Response.Write "<option value=""" & rsPick("ID_SONG") & """>" & H(rsPick("SONG_NAME")) & "</option>"
            rsPick.MoveNext
        Loop
        Response.Write "</select></div>"
        Response.Write "<button type=""submit"" class=""btn btn-primary"">" & SvgIcon("plus", "") & "Agregar</button>"
        Response.Write "</form>"
    End If
    rsPick.Close
    Set rsPick = Nothing

    Response.Write "</div></div>"

    Response.Write "</div>"
End Sub
%>
