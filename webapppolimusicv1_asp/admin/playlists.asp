<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<!--#include file="../includes/playlist_lib.asp"-->
<%
' ==========================================================================
'  admin/playlists.asp  -  CRUD de playlists (ADMIN: todas las del sistema)
' ==========================================================================
strPrefix = "../"
strPageTitle = "Playlists"
strActive = "playlists"
strCrumb = "<a href=""../home.asp"">Inicio</a> <span class=""sep"">/</span> " & _
           "<a href=""playlists.asp"">Playlists</a>"

RequireAdmin

' Las acciones (guardar, eliminar, agregar/quitar canciones) se procesan
' antes de imprimir cualquier HTML porque terminan en una redireccion.
PlaylistHandlePost True
%>
<!--#include file="../includes/header.asp"-->

<div class="section-head">
    <div>
        <h2><%=SvgIcon("list", "")%>Playlists del sistema</h2>
        <p class="section-sub">
            Como administrador puedes ver, editar y eliminar las playlists de todos los usuarios,
            ademas de gestionar sus canciones.
        </p>
    </div>
    <a class="btn btn-primary btn-sm" href="playlists.asp?action=new"><%=SvgIcon("plus", "")%>Nueva playlist</a>
</div>

<% RenderPlaylistManager True %>

<!--#include file="../includes/footer.asp"-->
