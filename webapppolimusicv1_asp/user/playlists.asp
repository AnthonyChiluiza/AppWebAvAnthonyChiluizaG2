<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="../includes/cnx.asp"-->
<!--#include file="../includes/helpers.asp"-->
<!--#include file="../includes/playlist_lib.asp"-->
<%
' ==========================================================================
'  user/playlists.asp  -  CRUD de playlists del USUARIO NORMAL
'  Solo muestra y permite modificar las playlists propias (ID_USER = sesion)
' ==========================================================================
strPrefix = "../"
strPageTitle = "Mis playlists"
strActive = "playlists"
strCrumb = "<a href=""../home.asp"">Inicio</a> <span class=""sep"">/</span> " & _
           "<a href=""playlists.asp"">Mis playlists</a>"

RequireLogin

' Un administrador tambien puede usar esta vista: vera unicamente sus propias playlists
PlaylistHandlePost False
%>
<!--#include file="../includes/header.asp"-->

<div class="section-head">
    <div>
        <h2><%=SvgIcon("list", "")%>Mis playlists</h2>
        <p class="section-sub">
            Aqui puedes crear, editar y eliminar tus propias playlists y elegir que canciones las componen.
            Ningun otro usuario puede ver ni modificar estas listas.
        </p>
    </div>
    <a class="btn btn-primary btn-sm" href="playlists.asp?action=new"><%=SvgIcon("plus", "")%>Nueva playlist</a>
</div>

<% RenderPlaylistManager False %>

<!--#include file="../includes/footer.asp"-->
