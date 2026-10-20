<%
' ==========================================================================
'  includes/helpers.asp
'  Funciones utilitarias compartidas por todas las paginas de PolyMusic
'  Requiere que la pagina defina previamente la variable strPrefix
'  ("" en la raiz, "../" en subcarpetas) para resolver rutas de recursos.
' ==========================================================================

' ---- Variables de maqueta compartidas -----------------------------------
' Se declaran aqui (y no en cada pagina) para evitar redeclaraciones.
Dim strPrefix       ' "" en la raiz del sitio, "../" en subcarpetas
Dim strPageTitle    ' titulo de la pestana
Dim strActive       ' clave del enlace de navegacion activo
Dim strCrumb        ' HTML del breadcrumb (opcional)

strPrefix = ""
strPageTitle = ""
strActive = ""
strCrumb = ""

' ---- Constantes globales ------------------------------------------------
Const APP_NAME      = "PolyMusic"
Const RES_SONGS     = "SongFilesAndImages_resources/SongFiles/"
Const RES_PLAYLISTS = "SongFilesAndImages_resources/PlaylistImages/"
Const RES_USERS     = "SongFilesAndImages_resources/UserImages/"
Const RES_ALBUMS    = "SongFilesAndImages_resources/AlbumImages/"
Const RES_ARTISTS   = "SongFilesAndImages_resources/ArtistImages/"
Const FALLBACK_SONG = "bensound-adventure.mp3"
Const IMG_EXTS      = "|jpg|jpeg|png|gif|webp|bmp|"
Const SONG_EXTS     = "|mp3|wav|ogg|m4a|"

' Cache en memoria de la peticion para no consultar el disco dos veces
Dim g_dicFiles
Set g_dicFiles = Server.CreateObject("Scripting.Dictionary")


' ==========================================================================
'  1. Entrada de datos y saneamiento
' ==========================================================================

' Escapa el HTML para evitar XSS antes de mostrar datos en pantalla
Function H(value)
    If IsNull(value) Or IsEmpty(value) Then
        H = ""
    Else
        H = Server.HTMLEncode(CStr(value))
    End If
End Function

' Escapa comillas simples para evitar inyeccion SQL
Function SqlS(value)
    Dim s
    If IsNull(value) Or IsEmpty(value) Then
        s = ""
    Else
        s = CStr(value)
    End If
    SqlS = Replace(s, "'", "''")
End Function

' Convierte cualquier valor en texto recortado
Function TrimStr(value)
    If IsNull(value) Or IsEmpty(value) Then
        TrimStr = ""
    Else
        TrimStr = Trim(CStr(value))
    End If
End Function

' Convierte a entero con valor por defecto
Function IntOr(value, fallback)
    If IsNumeric(value) Then
        On Error Resume Next
        IntOr = CLng(value)
        If Err.Number <> 0 Then
            Err.Clear
            IntOr = fallback
        End If
        On Error GoTo 0
    Else
        IntOr = fallback
    End If
End Function

Function IsPost()
    IsPost = (UCase(TrimStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST")
End Function

' Acceso corto y saneado a Request (QueryString + Form)
Function Req(name)
    Req = TrimStr(Request(name))
End Function

Function QS(name)
    QS = TrimStr(Request.QueryString(name))
End Function

Function FS(name)
    FS = TrimStr(Request.Form(name))
End Function


' ==========================================================================
'  2. Rutas de recursos (canciones, imagenes)
' ==========================================================================

' Devuelve solo el nombre de archivo de una ruta dada
Function FileBaseName(rawPath)
    Dim p, i
    p = Replace(Replace(TrimStr(rawPath), "\", "/"), "//", "/")
    i = InStrRev(p, "/")
    If i > 0 Then
        FileBaseName = Mid(p, i + 1)
    Else
        FileBaseName = p
    End If
End Function

' Comprueba si un archivo relativo al sitio existe (con cache)
Function FileExistsRel(relPath)
    Dim fso, absPath, bln
    If g_dicFiles.Exists(relPath) Then
        FileExistsRel = g_dicFiles.Item(relPath)
        Exit Function
    End If

    bln = False
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    absPath = Server.MapPath(strPrefix & relPath)
    If Err.Number = 0 Then
        bln = fso.FileExists(absPath)
    End If
    Err.Clear
    On Error GoTo 0

    g_dicFiles.Add relPath, bln
    FileExistsRel = bln
End Function

' Resuelve la ruta de una cancion. Si el archivo no existe en el servidor
' devuelve la pista de demostracion para que el reproductor siga funcionando.
Function SongUrl(rawPath)
    Dim nm, rel
    nm = FileBaseName(rawPath)

    If nm <> "" Then
        rel = RES_SONGS & nm
        If FileExistsRel(rel) Then
            SongUrl = rel
            Exit Function
        End If
    End If

    SongUrl = RES_SONGS & FALLBACK_SONG
End Function

' Resuelve la ruta de una imagen. Devuelve "" cuando no hay imagen
' disponible, de modo que la pagina dibuja un placeholder con degradado.
Function ImageUrl(rawPath, kind)
    Dim nm, folder, fallbackImg, rel

    Select Case LCase(kind)
        Case "user"
            folder = RES_USERS
            fallbackImg = "default.jpg"
        Case "playlist"
            folder = RES_PLAYLISTS
            fallbackImg = "default.jpg"
        Case "album"
            folder = RES_ALBUMS
            fallbackImg = ""
        Case "artist"
            folder = RES_ARTISTS
            fallbackImg = ""
        Case Else
            folder = ""
            fallbackImg = ""
    End Select

    If folder = "" Then
        ImageUrl = ""
        Exit Function
    End If

    nm = FileBaseName(rawPath)
    If nm <> "" Then
        rel = folder & nm
        If FileExistsRel(rel) Then
            ImageUrl = rel
            Exit Function
        End If
    End If

    If fallbackImg <> "" Then
        rel = folder & fallbackImg
        If FileExistsRel(rel) Then
            ImageUrl = rel
            Exit Function
        End If
    End If

    ImageUrl = ""
End Function

' Letra inicial para los placeholders visuales
Function Initial(value)
    Dim s
    s = TrimStr(value)
    If Len(s) = 0 Then
        Initial = ChrW(9835)
    Else
        Initial = UCase(Left(s, 1))
    End If
End Function


' ==========================================================================
'  3. Fragmentos HTML reutilizables
' ==========================================================================

' Icono SVG (los simbolos se declaran una sola vez en includes/header.asp)
Function SvgIcon(iconName, extraClass)
    SvgIcon = "<svg class=""ic " & extraClass & """ aria-hidden=""true"" focusable=""false"">" & _
              "<use href=""#i-" & iconName & """></use></svg>"
End Function

' Caratula con imagen o placeholder morado con la letra inicial
Sub ArtBox(url, displayName, extraClass)
    Response.Write "<div class=""art " & extraClass & """>"
    Response.Write "<span class=""art-ph"">" & H(Initial(displayName)) & "</span>"
    If url <> "" Then
        Response.Write "<img src=""" & strPrefix & url & """ alt=""" & H(displayName) & """ loading=""lazy"" onerror=""this.remove()"">"
    End If
    Response.Write "</div>"
End Sub

' Marca el enlace de navegacion activo
Function NavClass(key)
    If LCase(TrimStr(strActive)) = LCase(key) Then
        NavClass = " is-active"
    Else
        NavClass = ""
    End If
End Function

' Genera las <option> de un catalogo (TBL_CATALOG)
Sub CatalogOptions(codParent, selectedValue)
    Dim rsCat, cod
    Set rsCat = OpenRS("SELECT COD_CATALOG, VALUE FROM TBL_CATALOG " & _
                             "WHERE COD_CATALOG_PARENT = '" & SqlS(codParent) & "' " & _
                             "ORDER BY COD_CATALOG")
    Do While Not rsCat.EOF
        cod = TrimStr(rsCat("COD_CATALOG"))
        Response.Write "<option value=""" & H(cod) & """"
        If cod = TrimStr(selectedValue) Then
            Response.Write " selected"
        End If
        Response.Write ">" & H(rsCat("VALUE")) & "</option>"
        rsCat.MoveNext
    Loop
    rsCat.Close
    Set rsCat = Nothing
End Sub

' Nombre legible de un item de catalogo
Function CatalogName(codParent, cod, defaultValue)
    Dim rsCat, s
    s = defaultValue
    Set rsCat = OpenRS("SELECT VALUE FROM TBL_CATALOG WHERE COD_CATALOG_PARENT = '" & SqlS(codParent) & "' " & _
                             "AND COD_CATALOG = '" & SqlS(cod) & "'")
    If Not rsCat.EOF Then
        s = TrimStr(rsCat("VALUE"))
    End If
    rsCat.Close
    Set rsCat = Nothing
    CatalogName = s
End Function

' Datalist con los archivos disponibles en una carpeta de recursos.
' Permite al administrador elegir un archivo existente sin escribir la ruta.
Sub FileDatalist(listId, folder, exts)
    Dim fso, fld, f, ext, wrote
    Response.Write "<datalist id=""" & listId & """>"
    wrote = 0

    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Set fld = fso.GetFolder(Server.MapPath(strPrefix & folder))
    If Err.Number = 0 Then
        For Each f In fld.Files
            ext = LCase(fso.GetExtensionName(f.Name))
            If InStr(exts, "|" & ext & "|") > 0 Then
                Response.Write "<option value=""" & H(folder & f.Name) & """>"
                wrote = wrote + 1
            End If
        Next
    End If
    Err.Clear
    On Error GoTo 0

    If wrote = 0 Then
        Response.Write "<option value="""">"
    End If
    Response.Write "</datalist>"
End Sub


' ==========================================================================
'  4. Sesion, roles y mensajes
' ==========================================================================

Function IsLoggedIn()
    IsLoggedIn = (TrimStr(Session("ID_USER")) <> "")
End Function

Function IsAdmin()
    IsAdmin = (TrimStr(Session("USER_TYPE")) = "1")
End Function

Function CurrentUserId()
    CurrentUserId = IntOr(Session("ID_USER"), 0)
End Function

Sub RequireLogin()
    If Not IsLoggedIn() Then
        Response.Redirect strPrefix & "login.asp?e=session"
        Response.End
    End If
End Sub

Sub DenyAccess(msgText)
    Response.Write "<!DOCTYPE html><html lang=""es""><head><meta charset=""utf-8"">"
    Response.Write "<meta name=""viewport"" content=""width=device-width, initial-scale=1"">"
    Response.Write "<title>Acceso restringido - " & APP_NAME & "</title>"
    Response.Write "<link rel=""stylesheet"" href=""" & strPrefix & "css/style.css"">"
    Response.Write "</head><body><div class=""page"" style=""max-width:640px;padding-top:11vh"">"
    Response.Write "<div class=""card"" style=""text-align:center;padding:42px 32px"">"
    Response.Write "<div class=""stat-ico"" style=""margin:0 auto 16px;width:58px;height:58px;border-radius:16px"">"
    Response.Write "<svg viewBox=""0 0 24 24"" style=""width:26px;height:26px;fill:#8e24aa"" aria-hidden=""true"">"
    Response.Write "<path d=""M12 2 1 21h22L12 2zm1 14h-2v2h2v-2zm0-7h-2v5h2V9z""/></svg></div>"
    Response.Write "<h1 style=""font-size:1.4rem"">Acceso restringido</h1>"
    Response.Write "<p style=""color:#7a6b8a;font-size:.94rem;max-width:420px;margin:0 auto 22px"">" & H(msgText) & "</p>"
    Response.Write "<div class=""flex"" style=""justify-content:center"">"
    Response.Write "<a class=""btn btn-primary"" href=""" & strPrefix & "home.asp"">Volver al inicio</a>"
    Response.Write "<a class=""btn btn-ghost"" href=""" & strPrefix & "logout.asp"">Cambiar de usuario</a>"
    Response.Write "</div></div></div></body></html>"
End Sub

Sub RequireAdmin()
    RequireLogin
    If Not IsAdmin() Then
        DenyAccess "Esta seccion esta reservada para usuarios con rol de Administrador. " & _
                   "Tu cuenta es de tipo Usuario, por lo que solo puedes gestionar tus propias playlists."
        Response.End
    End If
End Sub

Sub SetFlash(kind, msgText)
    Session("flash_type") = kind
    Session("flash_msg") = msgText
End Sub

Sub RenderFlash()
    Dim fType, fMsg
    fType = TrimStr(Session("flash_type"))
    fMsg = TrimStr(Session("flash_msg"))
    If fMsg = "" Then
        Exit Sub
    End If

    Session("flash_type") = ""
    Session("flash_msg") = ""

    If fType = "" Then
        fType = "info"
    End If

    Response.Write "<div class=""flash flash-" & fType & """ role=""status"">"
    Select Case fType
        Case "ok"
            Response.Write SvgIcon("check", "")
        Case "err"
            Response.Write SvgIcon("alert", "")
        Case "warn"
            Response.Write SvgIcon("alert", "")
        Case Else
            Response.Write SvgIcon("info", "")
    End Select
    Response.Write "<div>" & fMsg & "</div>"
    Response.Write "</div>"
End Sub


' ==========================================================================
'  5. Utilidades de base de datos
' ==========================================================================

' Abre un recordset en el CLIENTE (adUseClient / estatico / solo lectura).
' Asi la conexion queda libre y se pueden tener varios recordsets abiertos
' a la vez sin necesidad de MARS en el proveedor SQLOLEDB.
Function OpenRS(sqlText)
    Dim rsQ
    Set rsQ = Server.CreateObject("ADODB.Recordset")
    rsQ.CursorLocation = 3          ' adUseClient
    rsQ.Open sqlText, oCnx, 3, 1    ' adOpenStatic, adLockReadOnly
    Set OpenRS = rsQ
End Function

' Ejecuta una sentencia ignorando errores (usada en borrados en cascada)
Sub RunSQL(sqlText)
    On Error Resume Next
    oCnx.Execute sqlText
    Err.Clear
    On Error GoTo 0
End Sub

' Cuenta filas de una consulta COUNT(*)
Function GetCount(sqlText)
    Dim rsC
    GetCount = 0
    Set rsC = OpenRS(sqlText)
    If Not rsC.EOF Then
        If Not IsNull(rsC(0)) Then
            GetCount = CLng(rsC(0))
        End If
    End If
    rsC.Close
    Set rsC = Nothing
End Function

' Ultimo ID generado en una tabla (para recuperar el IDENTITY tras un INSERT)
Function NewID(tableName, pkColumn)
    Dim rsN
    NewID = 0
    Set rsN = OpenRS("SELECT ISNULL(MAX(" & pkColumn & "), 0) AS MX FROM " & tableName)
    If Not rsN.EOF Then
        NewID = CLng(rsN("MX"))
    End If
    rsN.Close
    Set rsN = Nothing
End Function

' IDs de artistas de una cancion en formato ",1,2," (para preseleccionar)
Function SongArtistIds(songId)
    Dim rsP, s
    s = ","
    Set rsP = OpenRS("SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = " & IntOr(songId, 0))
    Do While Not rsP.EOF
        s = s & rsP("ID_ARTIST") & ","
        rsP.MoveNext
    Loop
    rsP.Close
    Set rsP = Nothing
    SongArtistIds = s
End Function

' Album de una cancion (0 si no tiene)
Function SongAlbumId(songId)
    Dim rsT, n
    n = 0
    Set rsT = OpenRS("SELECT TOP 1 ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = " & IntOr(songId, 0))
    If Not rsT.EOF Then
        n = CLng(rsT("ID_ALBUM"))
    End If
    rsT.Close
    Set rsT = Nothing
    SongAlbumId = n
End Function

' Propietario de una playlist
Function PlaylistOwner(playlistId)
    Dim rsO, n
    n = 0
    Set rsO = OpenRS("SELECT ID_USER FROM TBL_PLAYLIST WHERE ID_PLAYLIST = " & IntOr(playlistId, 0))
    If Not rsO.EOF Then
        n = CLng(rsO("ID_USER"))
    End If
    rsO.Close
    Set rsO = Nothing
    PlaylistOwner = n
End Function


' ==========================================================================
'  6. Formato
' ==========================================================================

Function FormatDateEs(d)
    If IsNull(d) Or IsEmpty(d) Then
        FormatDateEs = "&mdash;"
    ElseIf Not IsDate(d) Then
        FormatDateEs = "&mdash;"
    Else
        FormatDateEs = Right("0" & Day(d), 2) & "/" & Right("0" & Month(d), 2) & "/" & Year(d)
    End If
End Function

Function IsoDate(d)
    If IsNull(d) Or IsEmpty(d) Then
        IsoDate = ""
    ElseIf Not IsDate(d) Then
        IsoDate = ""
    Else
        IsoDate = Year(d) & "-" & Right("0" & Month(d), 2) & "-" & Right("0" & Day(d), 2)
    End If
End Function

Function Trunc(value, maxLen)
    Dim s
    s = TrimStr(value)
    If Len(s) > maxLen Then
        Trunc = Left(s, maxLen - 3) & "..."
    Else
        Trunc = s
    End If
End Function

Function Plural(count, singular, pluralForm)
    If IntOr(count, 0) = 1 Then
        Plural = singular
    Else
        Plural = pluralForm
    End If
End Function
%>
