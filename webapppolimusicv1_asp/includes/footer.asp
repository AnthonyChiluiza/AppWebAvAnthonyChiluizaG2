</main>

<audio id="pmAudio" preload="metadata" style="display:none"></audio>

<footer class="player player-empty" id="pmPlayer" aria-label="Reproductor de audio">
    <div class="player-track">
        <div class="player-art" id="pmArt" aria-hidden="true">&#9835;</div>
        <div class="player-meta">
            <strong id="pmTitle">Ninguna cancion seleccionada</strong>
            <span id="pmArtist">Elige una cancion de la lista para empezar</span>
        </div>
    </div>

    <div class="player-center">
        <div class="player-controls">
            <button type="button" class="pc-btn prev" id="pmPrev" title="Cancion anterior" aria-label="Cancion anterior">
                <%=SvgIcon("prev", "")%>
            </button>
            <button type="button" class="pc-btn pc-play" id="pmPlay" title="Reproducir / Pausar" aria-label="Reproducir">
                <%=SvgIcon("play", "")%>
            </button>
            <button type="button" class="pc-btn next" id="pmNext" title="Cancion siguiente" aria-label="Cancion siguiente">
                <%=SvgIcon("next", "")%>
            </button>
        </div>
        <div class="player-progress">
            <span id="pmCur">0:00</span>
            <div class="seek" id="pmSeek" role="slider" tabindex="0" aria-label="Progreso de la cancion" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
                <div class="seek-fill" id="pmFill"></div>
            </div>
            <span id="pmDur">0:00</span>
        </div>
    </div>

    <div class="player-right">
        <span class="player-plays" title="Reproducciones de la cancion actual">
            <%=SvgIcon("play", "")%><span id="pmPlays">0</span>
        </span>
        <div class="vol">
            <%=SvgIcon("volume", "")%>
            <input type="range" id="pmVol" min="0" max="1" step="0.01" value="1" aria-label="Volumen">
        </div>
    </div>
</footer>

<script>
    window.POLY_BASE = "<%=strPrefix%>";
</script>
<script src="<%=strPrefix%>js/player.js"></script>
</body>
</html>
<%
' Libera la conexion y la memoria al terminar la pagina
On Error Resume Next
If IsObject(oCnx) Then
    oCnx.Close
End If
Set oCnx = Nothing
Set g_dicFiles = Nothing
Err.Clear
On Error GoTo 0
%>
