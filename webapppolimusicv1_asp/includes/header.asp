<%
' ==========================================================================
'  includes/header.asp
'  Cabecera comun: doctype, <head>, barra de navegacion y apertura del main
'  La pagina debe definir: strPageTitle, strActive, strPrefix
' ==========================================================================

Dim strRoleLabel, strRoleClass, strAvatarUrl, strUName

If TrimStr(Session("USER_TYPE")) = "1" Then
    strRoleLabel = "Administrador"
    strRoleClass = "badge-admin"
Else
    strRoleLabel = "Usuario"
    strRoleClass = "badge-user"
End If

strUName = TrimStr(Session("USERNAME"))
strAvatarUrl = ImageUrl(Session("USER_PHOTO"), "user")

If TrimStr(strPageTitle) = "" Then
    strPageTitle = "Inicio"
End If
%><!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="PolyMusic - Tu biblioteca musical: canciones, albumes, artistas y playlists.">
    <title><%=H(strPageTitle)%> &middot; PolyMusic</title>
    <link rel="stylesheet" href="<%=strPrefix%>css/style.css">
</head>
<body>

<!-- Simbolos SVG reutilizables -->
<svg class="svg-defs" aria-hidden="true" focusable="false">
    <symbol id="i-play" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></symbol>
    <symbol id="i-pause" viewBox="0 0 24 24"><path d="M6 5h4v14H6zM14 5h4v14h-4z"/></symbol>
    <symbol id="i-prev" viewBox="0 0 24 24"><path d="M6 6h2v12H6zM20 6l-10 6 10 6z"/></symbol>
    <symbol id="i-next" viewBox="0 0 24 24"><path d="M16 6h2v12h-2zM4 6l10 6-10 6z"/></symbol>
    <symbol id="i-trash" viewBox="0 0 24 24"><path d="M9 3h6l1 2h4v2H4V5h4l1-2zM6 9h12l-1 12H7L6 9z"/></symbol>
    <symbol id="i-edit" viewBox="0 0 24 24"><path d="M4 17.2V20h2.8L18 8.8 15.2 6 4 17.2zM20.7 6.6a1 1 0 0 0 0-1.4l-1.9-1.9a1 1 0 0 0-1.4 0l-1.3 1.3L18.9 7l1.8-.4z"/></symbol>
    <symbol id="i-plus" viewBox="0 0 24 24"><path d="M11 5h2v6h6v2h-6v6h-2v-6H5v-2h6z"/></symbol>
    <symbol id="i-music" viewBox="0 0 24 24"><path d="M9 18a3 3 0 1 1-2-2.83V4l12-2v13.2A3 3 0 1 1 17 12V6.3L9 8v10z"/></symbol>
    <symbol id="i-disc" viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm0 13a3 3 0 1 1 0-6 3 3 0 0 1 0 6z"/></symbol>
    <symbol id="i-mic" viewBox="0 0 24 24"><path d="M12 14a3 3 0 0 0 3-3V5a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.9V21h2v-3.1A7 7 0 0 0 19 11h-2z"/></symbol>
    <symbol id="i-user" viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0 2c-4.4 0-8 2.2-8 5v1h16v-1c0-2.8-3.6-5-8-5z"/></symbol>
    <symbol id="i-list" viewBox="0 0 24 24"><path d="M4 6h16v2H4zM4 11h16v2H4zM4 16h16v2H4z"/></symbol>
    <symbol id="i-logout" viewBox="0 0 24 24"><path d="M10 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h5v-2H5V5h5V3zm6.2 4.6L14.8 9 17 11H9v2h8l-2.2 2 1.4 1.4L21 12l-4.8-4.4z"/></symbol>
    <symbol id="i-search" viewBox="0 0 24 24"><path d="M10 4a6 6 0 1 0 3.7 10.7l4.8 4.8 1.4-1.4-4.8-4.8A6 6 0 0 0 10 4zm0 2a4 4 0 1 1 0 8 4 4 0 0 1 0-8z"/></symbol>
    <symbol id="i-volume" viewBox="0 0 24 24"><path d="M4 9v6h4l5 4V5L8 9H4zm12.5 3a4.5 4.5 0 0 0-2.5-4v8a4.5 4.5 0 0 0 2.5-4z"/></symbol>
    <symbol id="i-check" viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></symbol>
    <symbol id="i-alert" viewBox="0 0 24 24"><path d="M12 2 1 21h22L12 2zm1 14h-2v2h2v-2zm0-7h-2v5h2V9z"/></symbol>
    <symbol id="i-info" viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></symbol>
    <symbol id="i-back" viewBox="0 0 24 24"><path d="M20 11H7.8l5.6-5.6L12 4l-8 8 8 8 1.4-1.4L7.8 13H20z"/></symbol>
    <symbol id="i-home" viewBox="0 0 24 24"><path d="M12 3 2 12h3v9h6v-6h2v6h6v-9h3z"/></symbol>
    <symbol id="i-shield" viewBox="0 0 24 24"><path d="M12 2 4 5v6c0 5 3.4 9.4 8 11 4.6-1.6 8-6 8-11V5l-8-3zm-1 14-4-4 1.4-1.4L11 13.2l4.6-4.6L17 10l-6 6z"/></symbol>
    <symbol id="i-clock" viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 10.6V6h-2v7.4l5 3 1-1.7-4-2.1z"/></symbol>
</svg>

<header class="topbar">
    <div class="topbar-inner">
        <a class="brand" href="<%=strPrefix%>home.asp" title="Ir al inicio de PolyMusic">
            <span class="brand-logo"><%=SvgIcon("music", "")%></span>
            <span class="brand-text">Poly<span>Music</span></span>
        </a>

        <nav class="nav" aria-label="Navegacion principal">
            <a class="nav-link<%=NavClass("home")%>" href="<%=strPrefix%>home.asp">
                <%=SvgIcon("home", "")%>Inicio
            </a>
            <% If IsAdmin() Then %>
            <span class="nav-sep" aria-hidden="true"></span>
            <a class="nav-link<%=NavClass("songs")%>" href="<%=strPrefix%>admin/songs.asp">
                <%=SvgIcon("music", "")%>Canciones
            </a>
            <a class="nav-link<%=NavClass("artists")%>" href="<%=strPrefix%>admin/artists.asp">
                <%=SvgIcon("mic", "")%>Artistas
            </a>
            <a class="nav-link<%=NavClass("albums")%>" href="<%=strPrefix%>admin/albums.asp">
                <%=SvgIcon("disc", "")%>Albumes
            </a>
            <a class="nav-link<%=NavClass("users")%>" href="<%=strPrefix%>admin/users.asp">
                <%=SvgIcon("user", "")%>Usuarios
            </a>
            <a class="nav-link<%=NavClass("playlists")%>" href="<%=strPrefix%>admin/playlists.asp">
                <%=SvgIcon("list", "")%>Playlists
            </a>
            <% Else %>
            <span class="nav-sep" aria-hidden="true"></span>
            <a class="nav-link" href="<%=strPrefix%>home.asp#songs">
                <%=SvgIcon("music", "")%>Song List
            </a>
            <a class="nav-link" href="<%=strPrefix%>home.asp#albums">
                <%=SvgIcon("disc", "")%>Albumes
            </a>
            <a class="nav-link" href="<%=strPrefix%>home.asp#artists">
                <%=SvgIcon("mic", "")%>Artistas
            </a>
            <a class="nav-link<%=NavClass("playlists")%>" href="<%=strPrefix%>user/playlists.asp">
                <%=SvgIcon("list", "")%>Mis Playlists
            </a>
            <% End If %>
        </nav>

        <div class="user-chip">
            <span class="avatar" aria-hidden="true">
                <%=H(Initial(strUName))%>
                <% If strAvatarUrl <> "" Then %>
                <img src="<%=strPrefix & strAvatarUrl%>" alt="" onerror="this.remove()">
                <% End If %>
            </span>
            <span class="user-meta">
                <strong><%=H(strUName)%></strong>
                <span><%=H(strRoleLabel)%></span>
            </span>
            <a class="btn-logout" href="<%=strPrefix%>logout.asp" title="Cerrar sesion">
                <%=SvgIcon("logout", "")%><span>Salir</span>
            </a>
        </div>
    </div>
</header>

<main class="page">
    <% If TrimStr(strCrumb) <> "" Then %>
    <nav class="crumb" aria-label="Ruta de navegacion"><%=strCrumb%></nav>
    <% End If %>
    <% RenderFlash %>
