/* ==========================================================================
   PolyMusic - player.js
   Reproductor fijo tipo Spotify + busqueda en la lista de canciones.
   JavaScript puro, sin dependencias.
   ========================================================================== */
(function () {
    "use strict";

    var audio = document.getElementById("pmAudio");
    if (!audio) {
        return;
    }

    var BASE = window.POLY_BASE || "";

    function $(id) {
        return document.getElementById(id);
    }

    var ui = {
        bar: $("pmPlayer"),
        art: $("pmArt"),
        title: $("pmTitle"),
        artist: $("pmArtist"),
        btnPlay: $("pmPlay"),
        btnPrev: $("pmPrev"),
        btnNext: $("pmNext"),
        cur: $("pmCur"),
        dur: $("pmDur"),
        seek: $("pmSeek"),
        fill: $("pmFill"),
        plays: $("pmPlays"),
        vol: $("pmVol")
    };

    var queue = [];
    var index = -1;
    var current = null;

    /* ----------------------------------------------------------------------
       Utilidades
       ---------------------------------------------------------------------- */
    function fmtTime(sec) {
        if (!isFinite(sec) || sec < 0) {
            sec = 0;
        }
        var m = Math.floor(sec / 60);
        var s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" + s : s);
    }

    function firstLetter(text) {
        var t = (text || "").replace(/^\s+/, "");
        return t ? t.charAt(0).toUpperCase() : "\u266A";
    }

    function setPlayIcon(playing) {
        var use = ui.btnPlay ? ui.btnPlay.querySelector("use") : null;
        if (use) {
            use.setAttribute("href", playing ? "#i-pause" : "#i-play");
        }
        if (ui.btnPlay) {
            ui.btnPlay.setAttribute("aria-label", playing ? "Pausar" : "Reproducir");
        }
    }

    function readQueue() {
        var rows = document.querySelectorAll("tr.song-row");
        queue = [];
        Array.prototype.forEach.call(rows, function (tr) {
            queue.push({
                id: tr.getAttribute("data-id"),
                name: tr.getAttribute("data-name"),
                artist: tr.getAttribute("data-artist"),
                url: tr.getAttribute("data-url"),
                plays: parseInt(tr.getAttribute("data-plays"), 10) || 0
            });
        });
    }

    function highlight(id) {
        var rows = document.querySelectorAll("tr.song-row");
        Array.prototype.forEach.call(rows, function (tr) {
            var isCurrent = tr.getAttribute("data-id") === String(id);
            tr.classList.toggle("is-current", isCurrent);
            var btn = tr.querySelector(".btn-play");
            if (btn) {
                btn.classList.toggle("is-playing", isCurrent && !audio.paused);
            }
        });
    }

    function paintMeta(track) {
        if (!ui.bar) {
            return;
        }
        ui.bar.classList.remove("player-empty");
        ui.title.textContent = track.name || "Sin titulo";
        ui.artist.textContent = track.artist || "Artista desconocido";
        ui.art.textContent = firstLetter(track.name);
        if (ui.plays) {
            ui.plays.textContent = track.plays || 0;
        }
    }

    function saveLast(track) {
        try {
            sessionStorage.setItem("polymusic_last", JSON.stringify(track));
        } catch (e) {
            /* sessionStorage puede estar deshabilitado */
        }
    }

    /* ----------------------------------------------------------------------
       Reproduccion
       ---------------------------------------------------------------------- */
    function bumpPlays(id) {
        if (!id) {
            return;
        }
        fetch(BASE + "ajax/play.asp?id=" + encodeURIComponent(id), { cache: "no-store" })
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (!data || !data.ok) {
                    return;
                }
                var total = parseInt(data.plays, 10) || 0;
                var cell = document.querySelector('td.plays-cell[data-id="' + id + '"]');
                if (cell) {
                    cell.textContent = total;
                    cell.setAttribute("data-plays", total);
                }
                var row = document.querySelector('tr.song-row[data-id="' + id + '"]');
                if (row) {
                    row.setAttribute("data-plays", total);
                }
                for (var i = 0; i < queue.length; i += 1) {
                    if (queue[i].id === String(id)) {
                        queue[i].plays = total;
                    }
                }
                if (current && String(current.id) === String(id)) {
                    current.plays = total;
                    if (ui.plays) {
                        ui.plays.textContent = total;
                    }
                }
            })
            .catch(function () {
                /* el contador no es critico: se ignora cualquier fallo */
            });
    }

    function playTrack(i, autoplay) {
        if (i < 0 || i >= queue.length) {
            return;
        }
        index = i;
        current = queue[i];
        paintMeta(current);
        audio.src = BASE + current.url;
        saveLast(current);
        highlight(current.id);

        if (autoplay !== false) {
            var p = audio.play();
            if (p && typeof p.catch === "function") {
                p.catch(function () { /* autoplay bloqueado o archivo no disponible */ });
            }
            bumpPlays(current.id);
        }
    }

    function togglePlay() {
        if (!audio.src) {
            readQueue();
            if (queue.length) {
                playTrack(0, true);
            }
            return;
        }
        if (audio.paused) {
            var p = audio.play();
            if (p && typeof p.catch === "function") {
                p.catch(function () { });
            }
        } else {
            audio.pause();
        }
    }

    function step(delta) {
        if (!queue.length) {
            readQueue();
        }
        if (!queue.length) {
            return;
        }
        var next = index + delta;
        if (next < 0) {
            next = queue.length - 1;
        }
        if (next >= queue.length) {
            next = 0;
        }
        playTrack(next, true);
    }

    /* ----------------------------------------------------------------------
       Progreso y volumen
       ---------------------------------------------------------------------- */
    function paintProgress() {
        var d = audio.duration;
        var c = audio.currentTime;
        var pct = (isFinite(d) && d > 0) ? (c / d) * 100 : 0;
        if (ui.fill) {
            ui.fill.style.width = pct + "%";
        }
        if (ui.cur) {
            ui.cur.textContent = fmtTime(c);
        }
        if (ui.seek) {
            ui.seek.setAttribute("aria-valuenow", Math.round(pct));
        }
    }

    function seekTo(clientX) {
        if (!isFinite(audio.duration) || audio.duration <= 0) {
            return;
        }
        var rect = ui.seek.getBoundingClientRect();
        var ratio = (clientX - rect.left) / rect.width;
        ratio = Math.max(0, Math.min(1, ratio));
        audio.currentTime = ratio * audio.duration;
        paintProgress();
    }

    /* ----------------------------------------------------------------------
       Eventos del reproductor
       ---------------------------------------------------------------------- */
    audio.addEventListener("play", function () {
        setPlayIcon(true);
        if (ui.bar) {
            ui.bar.classList.add("is-playing");
        }
        highlight(current ? current.id : "");
    });

    audio.addEventListener("pause", function () {
        setPlayIcon(false);
        if (ui.bar) {
            ui.bar.classList.remove("is-playing");
        }
        highlight(current ? current.id : "");
    });

    audio.addEventListener("timeupdate", paintProgress);

    audio.addEventListener("loadedmetadata", function () {
        if (ui.dur) {
            ui.dur.textContent = fmtTime(audio.duration);
        }
        paintProgress();
    });

    audio.addEventListener("ended", function () {
        if (index >= 0 && index < queue.length - 1) {
            playTrack(index + 1, true);
        } else {
            setPlayIcon(false);
            if (ui.bar) {
                ui.bar.classList.remove("is-playing");
            }
        }
    });

    audio.addEventListener("error", function () {
        if (ui.artist && audio.getAttribute("src")) {
            ui.artist.textContent = "No se pudo cargar el archivo de audio";
        }
    });

    if (ui.btnPlay) {
        ui.btnPlay.addEventListener("click", togglePlay);
    }
    if (ui.btnPrev) {
        ui.btnPrev.addEventListener("click", function () { step(-1); });
    }
    if (ui.btnNext) {
        ui.btnNext.addEventListener("click", function () { step(1); });
    }

    if (ui.seek) {
        var dragging = false;

        ui.seek.addEventListener("mousedown", function (ev) {
            dragging = true;
            seekTo(ev.clientX);
            ev.preventDefault();
        });

        document.addEventListener("mousemove", function (ev) {
            if (dragging) {
                seekTo(ev.clientX);
            }
        });

        document.addEventListener("mouseup", function () {
            dragging = false;
        });

        ui.seek.addEventListener("keydown", function (ev) {
            if (ev.key === "ArrowRight") {
                audio.currentTime = Math.min(audio.duration || 0, audio.currentTime + 5);
                ev.preventDefault();
            } else if (ev.key === "ArrowLeft") {
                audio.currentTime = Math.max(0, audio.currentTime - 5);
                ev.preventDefault();
            }
        });
    }

    if (ui.vol) {
        ui.vol.addEventListener("input", function () {
            audio.volume = parseFloat(ui.vol.value);
        });
        audio.volume = parseFloat(ui.vol.value);
    }

    /* ----------------------------------------------------------------------
       Clic en el boton "Play" de cada fila de la tabla
       ---------------------------------------------------------------------- */
    document.addEventListener("click", function (ev) {
        var btn = ev.target.closest ? ev.target.closest(".btn-play") : null;
        if (!btn) {
            return;
        }
        ev.preventDefault();

        var row = btn.closest("tr");
        if (!row) {
            return;
        }

        var id = row.getAttribute("data-id");
        readQueue();

        if (current && String(current.id) === String(id)) {
            togglePlay();
            return;
        }

        for (var i = 0; i < queue.length; i += 1) {
            if (queue[i].id === String(id)) {
                playTrack(i, true);
                return;
            }
        }
    });

    /* ----------------------------------------------------------------------
       Buscador de la lista de canciones
       ---------------------------------------------------------------------- */
    var search = document.getElementById("pmSearch");
    if (search) {
        var applyFilter = function () {
            var term = search.value.toLowerCase().trim();
            var rows = document.querySelectorAll("tr.song-row");
            var visible = 0;

            Array.prototype.forEach.call(rows, function (tr) {
                var haystack = (tr.getAttribute("data-name") + " " +
                    tr.getAttribute("data-artist") + " " +
                    tr.getAttribute("data-album")).toLowerCase();
                var match = haystack.indexOf(term) !== -1;
                tr.style.display = match ? "" : "none";
                if (match) {
                    visible += 1;
                }
            });

            var emptyRow = document.getElementById("pmSearchEmpty");
            if (emptyRow) {
                emptyRow.style.display = visible === 0 ? "" : "none";
            }
        };

        search.addEventListener("input", applyFilter);
        search.addEventListener("keydown", function (ev) {
            if (ev.key === "Escape") {
                search.value = "";
                applyFilter();
            }
        });
    }

    /* ----------------------------------------------------------------------
       Atajos de teclado (usuarios avanzados)
       ---------------------------------------------------------------------- */
    document.addEventListener("keydown", function (ev) {
        var tag = (ev.target.tagName || "").toLowerCase();
        if (tag === "input" || tag === "textarea" || tag === "select") {
            return;
        }
        if (ev.code === "Space" || ev.key === " ") {
            ev.preventDefault();
            togglePlay();
        } else if (ev.key === "/" && search) {
            ev.preventDefault();
            search.focus();
        }
    });

    /* ----------------------------------------------------------------------
       Restaurar la ultima cancion escuchada (sin autoplay)
       ---------------------------------------------------------------------- */
    (function restoreLast() {
        var raw = null;
        try {
            raw = sessionStorage.getItem("polymusic_last");
        } catch (e) {
            return;
        }
        if (!raw) {
            return;
        }
        try {
            var track = JSON.parse(raw);
            if (!track || !track.url) {
                return;
            }
            current = track;
            paintMeta(track);
            audio.src = BASE + track.url;
            if (ui.dur) {
                ui.dur.textContent = "0:00";
            }
        } catch (e) {
            /* datos corruptos: se ignora */
        }
    }());
}());
