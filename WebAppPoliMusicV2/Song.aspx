<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" ResponseEncoding="utf-8" %>

<!DOCTYPE html>

<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic · Canciones</title>
    <style type="text/css">
        /* =====================================================================
           PoliMusic - Song.aspx
           Paleta: crema + blanco con degradados calidos (estilo Spotify claro)
           ===================================================================== */

        *,
        *::before,
        *::after { box-sizing: border-box; }

        :root {
            --cream-25: #FFFDF9;
            --cream-50: #FDF8F0;
            --cream-100: #F9F1E3;
            --cream-200: #F3E7D3;
            --line: #EFE5D6;
            --white: #FFFFFF;
            --ink: #2B241F;
            --ink-2: #5D5148;
            --ink-3: #8C7C6E;
            --accent: #C1763F;
            --accent-soft: #E4A96B;
            --accent-deep: #96552C;
            --shadow-sm: 0 1px 2px rgba(72, 52, 32, .05), 0 2px 8px rgba(72, 52, 32, .05);
            --shadow: 0 12px 32px -18px rgba(90, 62, 36, .45);
            --radius: 18px;
            --player-h: 92px;
        }

        html, body { height: 100%; }

        body {
            margin: 0;
            overflow: hidden;
            font-family: "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            font-size: 15px;
            line-height: 1.5;
            color: var(--ink);
            background-color: var(--cream-25);
            background-image:
                radial-gradient(900px 520px at 10% -12%, rgba(228, 169, 107, .30), transparent 62%),
                radial-gradient(760px 440px at 94% -6%, rgba(243, 231, 211, .95), transparent 60%),
                linear-gradient(180deg, #FFFDF9 0%, #FDF8F0 42%, #F9F1E3 100%);
            background-attachment: fixed;
            -webkit-font-smoothing: antialiased;
        }

        a { color: inherit; }

        .app {
            display: grid;
            grid-template-columns: 248px minmax(0, 1fr) 312px;
            gap: 14px;
            height: 100vh;
            padding: 14px 14px calc(var(--player-h) + 14px);
        }

        .panel {
            background: rgba(255, 255, 255, .86);
            border: 1px solid rgba(255, 255, 255, .95);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            backdrop-filter: blur(8px);
        }

        /* ------------------------------ Sidebar ------------------------------ */
        .sidebar {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 0;
            padding: 18px 14px;
            overflow: hidden;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 11px;
            padding: 4px 6px 18px;
        }

        .brand-mark {
            width: 38px;
            height: 38px;
            flex: 0 0 38px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            background: linear-gradient(135deg, #E9B87E 0%, #C1763F 60%, #96552C 100%);
            box-shadow: 0 8px 18px -6px rgba(193, 118, 63, .75);
        }

        .brand-mark svg { width: 19px; height: 19px; }

        .brand strong {
            display: block;
            font-size: 15.5px;
            letter-spacing: -.01em;
        }

        .brand small {
            display: block;
            font-size: 10px;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--ink-3);
            font-weight: 700;
        }

        .nav {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 11px;
            padding: 9px 12px;
            border-radius: 11px;
            font-size: 13.5px;
            font-weight: 600;
            color: var(--ink-2);
            text-decoration: none;
            transition: background .18s ease, color .18s ease;
        }

        .nav-item svg {
            width: 18px;
            height: 18px;
            opacity: .7;
            flex: 0 0 18px;
        }

        .nav-item:hover { background: var(--cream-50); color: var(--ink); }

        .nav-item.is-active {
            color: var(--accent-deep);
            background: linear-gradient(135deg, #F7E7D0 0%, #FBEFDE 100%);
            box-shadow: inset 0 0 0 1px #EFD9BE;
        }

        .nav-item.is-active svg { opacity: 1; }

        .lib-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 12px 8px;
            font-size: 10.5px;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--ink-3);
            font-weight: 800;
        }

        .lib-list {
            list-style: none;
            margin: 0;
            padding: 0 4px;
            display: flex;
            flex-direction: column;
            gap: 2px;
            overflow-y: auto;
            min-height: 0;
            flex: 1 1 auto;
        }

        .lib-list li {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 7px 8px;
            border-radius: 10px;
            font-size: 13px;
            color: var(--ink-2);
            transition: background .18s ease;
        }

        .lib-list li:hover { background: var(--cream-50); }

        .lib-art {
            width: 30px;
            height: 30px;
            flex: 0 0 30px;
            border-radius: 8px;
            box-shadow: inset 0 0 0 1px rgba(0, 0, 0, .04);
        }

        .lib-meta { min-width: 0; }
        .lib-meta span { display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .lib-meta small { display: block; font-size: 10.5px; color: var(--ink-3); }

        .g1 { background: linear-gradient(135deg, #F6C89A, #C1763F); }
        .g2 { background: linear-gradient(135deg, #EBD9BC, #A9825A); }
        .g3 { background: linear-gradient(135deg, #F2D9C4, #B98862); }
        .g4 { background: linear-gradient(135deg, #D8C3A5, #8C6647); }

        .sidebar-foot {
            margin-top: auto;
            padding-top: 14px;
        }

        .user-card {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px;
            border-radius: 14px;
            background: linear-gradient(135deg, #FFFDF9 0%, #F9F1E3 100%);
            border: 1px solid var(--line);
        }

        .avatar-photo {
            width: 34px;
            height: 34px;
            flex: 0 0 34px;
            border-radius: 50%;
            object-fit: cover;
            display: block;
            box-shadow: 0 0 0 2px #fff, 0 0 0 3px #EFDCC1;
        }

        .avatar-initial {
            width: 34px;
            height: 34px;
            flex: 0 0 34px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 800;
            color: #fff;
            background: linear-gradient(135deg, #E4A96B, #C1763F);
            box-shadow: 0 0 0 2px #fff, 0 0 0 3px #EFDCC1;
        }

        .user-meta {
            flex: 1 1 auto;
            min-width: 0;
        }

        .user-meta strong {
            display: block;
            font-size: 13px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-meta small {
            display: block;
            font-size: 10.5px;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: var(--ink-3);
            font-weight: 700;
        }

        .logout-icon {
            width: 30px;
            height: 30px;
            flex: 0 0 30px;
            border-radius: 9px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--ink-3);
            text-decoration: none;
            transition: .18s ease;
        }

        .logout-icon:hover { color: #9B3B2A; background: #FDECE6; }
        .logout-icon svg { width: 16px; height: 16px; }

        /* -------------------------------- Main ------------------------------- */
        .main {
            height: 100%;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 2px 6px 4px 2px;
        }

        .main::-webkit-scrollbar { width: 10px; }
        .main::-webkit-scrollbar-thumb {
            background: #EADCC6;
            border-radius: 8px;
            border: 3px solid transparent;
            background-clip: content-box;
        }
        .main::-webkit-scrollbar-track { background: transparent; }

        .topbar {
            position: sticky;
            top: 0;
            z-index: 6;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            padding: 4px 2px 16px;
            background: linear-gradient(180deg, rgba(253, 248, 240, .97) 0%, rgba(253, 248, 240, .80) 62%, rgba(253, 248, 240, 0) 100%);
            backdrop-filter: blur(8px);
        }

        .search {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            height: 46px;
            padding: 0 6px 0 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, .92);
            border: 1px solid #F0E3CE;
            box-shadow: var(--shadow-sm);
            transition: border-color .2s ease, box-shadow .2s ease;
        }

        .topbar #search {
            flex: 1 1 auto;
            max-width: 460px;
            min-width: 0;
        }

        .search:focus-within {
            border-color: #E7C9A4;
            box-shadow: 0 0 0 4px rgba(228, 169, 107, .16), var(--shadow-sm);
        }

        .search-ico {
            width: 18px;
            height: 18px;
            flex: 0 0 18px;
            color: var(--ink-3);
        }

        .search-input {
            flex: 1 1 auto;
            min-width: 0;
            height: 100%;
            border: 0;
            outline: 0;
            background: transparent;
            font-family: inherit;
            font-size: 14px;
            color: var(--ink);
        }

        .search-input::placeholder { color: #B4A493; }

        .search-btn {
            width: 34px;
            height: 34px;
            flex: 0 0 34px;
            border: 0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            text-decoration: none;
            cursor: pointer;
            background: linear-gradient(135deg, #E4A96B 0%, #C1763F 100%);
            box-shadow: 0 6px 14px -6px rgba(193, 118, 63, .9);
            transition: transform .18s ease, filter .18s ease;
        }

        .search-btn:hover { transform: scale(1.05); filter: brightness(1.04); }
        .search-btn svg { width: 16px; height: 16px; }

        .btn-logout {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            height: 44px;
            padding: 0 18px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
            color: #7A4526;
            text-decoration: none;
            background: #fff;
            border: 1px solid #EFDFC9;
            box-shadow: var(--shadow-sm);
            transition: .2s ease;
            white-space: nowrap;
        }

        .btn-logout:hover {
            background: linear-gradient(135deg, #FFF6EA, #F9EBD8);
            border-color: #E7C9A4;
            transform: translateY(-1px);
        }

        .btn-logout svg { width: 16px; height: 16px; }

        /* -------------------------------- Hero ------------------------------- */
        .hero {
            position: relative;
            overflow: hidden;
            border-radius: 26px;
            padding: 34px 38px;
            margin-bottom: 20px;
            background:
                radial-gradient(620px 320px at 88% 8%, rgba(228, 169, 107, .38), transparent 62%),
                linear-gradient(135deg, #FDF4E6 0%, #FFFDFA 46%, #FFFFFF 100%);
            border: 1px solid #F4E7D4;
            box-shadow: 0 22px 44px -30px rgba(122, 86, 50, .55);
        }

        .hero-text { position: relative; z-index: 2; max-width: 58%; }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 10.5px;
            font-weight: 800;
            letter-spacing: .16em;
            text-transform: uppercase;
            color: #A9723F;
            background: rgba(255, 255, 255, .8);
            border: 1px solid #F2DFC5;
        }

        .eyebrow svg { width: 12px; height: 12px; }

        .hero h1 {
            margin: 16px 0 10px;
            font-size: clamp(26px, 3vw, 38px);
            line-height: 1.12;
            letter-spacing: -.025em;
            color: var(--ink);
        }

        .hero-name {
            display: inline-block;
            background: linear-gradient(100deg, #C1763F 0%, #96552C 52%, #C98A4B 100%);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero p {
            margin: 0;
            max-width: 480px;
            font-size: 14px;
            color: var(--ink-2);
        }

        .hero-stats {
            display: flex;
            align-items: center;
            gap: 24px;
            margin-top: 24px;
        }

        .stat strong {
            display: block;
            font-size: 23px;
            letter-spacing: -.02em;
            font-variant-numeric: tabular-nums;
        }

        .stat span {
            display: block;
            font-size: 10.5px;
            font-weight: 800;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--ink-3);
        }

        .stat-div {
            width: 1px;
            height: 34px;
            background: linear-gradient(180deg, transparent, #E6D3B6, transparent);
        }

        .hero-art {
            position: absolute;
            right: 34px;
            top: 50%;
            transform: translateY(-50%);
            z-index: 1;
            pointer-events: none;
        }

        .vinyl {
            width: 188px;
            height: 188px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background:
                repeating-radial-gradient(circle at 50% 50%, rgba(255, 255, 255, .09) 0 2px, rgba(0, 0, 0, .05) 2px 4px),
                linear-gradient(135deg, #3A2B20 0%, #6B4A33 58%, #2B211A 100%);
            box-shadow: 0 34px 60px -26px rgba(74, 48, 28, .75), inset 0 0 0 1px rgba(255, 255, 255, .08);
            animation: spin 22s linear infinite;
        }

        .vinyl i {
            width: 54px;
            height: 54px;
            border-radius: 50%;
            background: linear-gradient(135deg, #F3D3A8, #C1763F);
            box-shadow: inset 0 0 0 6px rgba(255, 255, 255, .55);
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        /* ------------------------------ Song list ---------------------------- */
        .list {
            background: rgba(255, 255, 255, .82);
            border: 1px solid rgba(255, 255, 255, .95);
            border-radius: 22px;
            padding: 22px 22px 12px;
            box-shadow: var(--shadow-sm);
            backdrop-filter: blur(8px);
        }

        .list-head {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 12px;
        }

        .list-head h2 {
            margin: 0;
            font-size: 19px;
            letter-spacing: -.015em;
        }

        .list-head p {
            margin: 4px 0 0;
            font-size: 12.5px;
            color: var(--ink-3);
        }

        .alert {
            display: block;
            font-size: 12.5px;
            font-weight: 600;
            color: #9B2C2C;
            text-align: right;
        }

        .table-wrap { overflow-x: auto; }

        table.songs {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        .songs thead th {
            padding: 8px 12px;
            text-align: left;
            font-size: 10.5px;
            font-weight: 800;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--ink-3);
            border-bottom: 1px solid var(--line);
        }

        .songs tbody td {
            padding: 9px 12px;
            border-bottom: 1px solid #F7EFE3;
            vertical-align: middle;
        }

        .songs tbody tr:last-child td { border-bottom: 0; }

        .song-row {
            cursor: pointer;
            transition: background .18s ease;
        }

        .song-row:hover { background: linear-gradient(90deg, #FFFBF4, #FFF6E9); }

        .song-row.is-active { background: linear-gradient(90deg, #FBEFDD, #FFF8ED); }
        .song-row.is-active .song-txt strong { color: var(--accent-deep); }

        .c-idx {
            width: 52px;
            color: var(--ink-3);
            font-size: 12.5px;
            font-variant-numeric: tabular-nums;
        }

        .c-plays { width: 156px; }
        .c-act { width: 64px; text-align: right; }

        .song-cell {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .cover {
            width: 42px;
            height: 42px;
            flex: 0 0 42px;
            border-radius: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: 800;
            color: #fff;
            background: linear-gradient(135deg, #E9B87E 0%, #C1763F 62%, #96552C 100%);
            box-shadow: 0 8px 16px -10px rgba(150, 85, 44, .95);
        }

        .song-txt { min-width: 0; }

        .song-txt strong {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--ink);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .song-txt small {
            display: block;
            font-size: 11px;
            color: #A99784;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .plays {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            color: var(--ink-2);
            background: #FFFDF9;
            border: 1px solid #F2E4D0;
            font-variant-numeric: tabular-nums;
        }

        .plays svg { width: 12px; height: 12px; color: #C08A55; }

        .row-play {
            width: 36px;
            height: 36px;
            margin-left: auto;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid #EFDFC9;
            background: #fff;
            color: var(--accent-deep);
            cursor: pointer;
            box-shadow: 0 4px 10px -6px rgba(122, 86, 50, .7);
            transition: .2s ease;
        }

        .row-play svg { width: 14px; height: 14px; margin-left: 2px; }

        .row-play:hover {
            color: #fff;
            border-color: transparent;
            transform: scale(1.07);
            background: linear-gradient(135deg, #E4A96B, #C1763F);
        }

        .song-row.is-active .row-play {
            color: #fff;
            border-color: transparent;
            background: linear-gradient(135deg, #E4A96B, #C1763F);
        }

        .empty {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            padding: 48px 20px;
            text-align: center;
        }

        .empty svg {
            width: 34px;
            height: 34px;
            color: #CDB79A;
            margin-bottom: 4px;
        }

        .empty h3 { margin: 0; font-size: 16px; }
        .empty p { margin: 0; max-width: 380px; font-size: 13px; color: var(--ink-3); }

        /* ----------------------------- Now playing --------------------------- */
        .right {
            display: flex;
            flex-direction: column;
            gap: 14px;
            height: 100%;
            min-height: 0;
            padding: 20px;
            overflow: hidden;
        }

        .right-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 10.5px;
            font-weight: 800;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--ink-3);
        }

        .live-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--accent);
            box-shadow: 0 0 0 4px rgba(193, 118, 63, .14);
        }

        .np-cover {
            aspect-ratio: 1 / 1;
            width: 100%;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 62px;
            font-weight: 800;
            color: #fff;
            background: radial-gradient(circle at 30% 22%, #F0C79A 0%, #C1763F 55%, #8A4E2B 100%);
            box-shadow: 0 26px 44px -26px rgba(122, 86, 50, .85);
            text-shadow: 0 4px 18px rgba(90, 50, 25, .35);
            transition: transform .4s ease;
        }

        body.is-playing .np-cover { transform: scale(.985); }

        .np-title {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -.015em;
            word-break: break-word;
        }

        .np-sub {
            margin-top: -8px;
            font-size: 12px;
            color: var(--ink-3);
        }

        .np-eq {
            display: flex;
            align-items: flex-end;
            gap: 3px;
            height: 20px;
            opacity: .3;
        }

        .np-eq i {
            width: 4px;
            height: 35%;
            border-radius: 2px;
            background: linear-gradient(180deg, #E4A96B, #C1763F);
        }

        .np-eq.is-live { opacity: 1; }
        .np-eq.is-live i { animation: eq .9s ease-in-out infinite; }
        .np-eq.is-live i:nth-child(2) { animation-delay: .15s; }
        .np-eq.is-live i:nth-child(3) { animation-delay: .3s; }
        .np-eq.is-live i:nth-child(4) { animation-delay: .45s; }

        @keyframes eq {
            0%, 100% { height: 25%; }
            50% { height: 100%; }
        }

        .np-meta {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            padding: 12px 14px;
            border-radius: 14px;
            background: linear-gradient(135deg, #FFFDF9, #F9F1E3);
            border: 1px solid var(--line);
        }

        .np-meta span {
            display: block;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--ink-3);
        }

        .np-meta strong {
            display: block;
            font-size: 16px;
            font-variant-numeric: tabular-nums;
        }

        .np-queue-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 10.5px;
            font-weight: 800;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--ink-3);
        }

        .np-queue {
            list-style: none;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: 2px;
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
        }

        .np-queue li {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 6px 8px;
            border-radius: 10px;
            font-size: 12.5px;
            color: var(--ink-2);
            cursor: pointer;
            transition: background .18s ease, color .18s ease;
        }

        .np-queue li:hover { background: var(--cream-50); }

        .np-queue li.is-active {
            color: var(--accent-deep);
            font-weight: 600;
            background: linear-gradient(135deg, #FBEFDD, #FFF8ED);
        }

        .np-qidx {
            width: 14px;
            flex: 0 0 14px;
            font-size: 11px;
            color: var(--ink-3);
            font-variant-numeric: tabular-nums;
        }

        .np-qname {
            min-width: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* -------------------------------- Player ----------------------------- */
        .player {
            position: fixed;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 20;
            height: var(--player-h);
            display: grid;
            grid-template-columns: minmax(180px, 1fr) minmax(320px, 520px) minmax(180px, 1fr);
            align-items: center;
            gap: 20px;
            padding: 0 22px;
            background: linear-gradient(180deg, rgba(255, 253, 249, .98) 0%, #FBF3E7 100%);
            border-top: 1px solid #F0E1CB;
            box-shadow: 0 -16px 34px -26px rgba(90, 62, 36, .8);
            backdrop-filter: blur(14px);
        }

        .pl-left {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .pl-cover {
            width: 52px;
            height: 52px;
            flex: 0 0 52px;
            border-radius: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 19px;
            font-weight: 800;
            color: #fff;
            background: linear-gradient(135deg, #E9B87E 0%, #C1763F 62%, #96552C 100%);
            box-shadow: 0 12px 20px -14px rgba(150, 85, 44, 1);
        }

        .pl-meta { min-width: 0; }

        .pl-meta strong {
            display: block;
            max-width: 240px;
            font-size: 13px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .pl-meta small {
            display: block;
            font-size: 11px;
            color: var(--ink-3);
            letter-spacing: .04em;
        }

        .pl-center { min-width: 0; }

        .pl-controls {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 14px;
        }

        .ctl {
            width: 34px;
            height: 34px;
            border: 0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            color: var(--ink-2);
            cursor: pointer;
            transition: .18s ease;
        }

        .ctl svg { width: 17px; height: 17px; }

        .ctl:hover { color: var(--accent-deep); background: #FFF3E3; }

        .ctl-main {
            width: 46px;
            height: 46px;
            color: #fff;
            background: linear-gradient(135deg, #E4A96B 0%, #C1763F 58%, #96552C 100%);
            box-shadow: 0 12px 22px -12px rgba(150, 85, 44, 1);
        }

        .ctl-main svg { width: 19px; height: 19px; }

        .ctl-main:hover {
            color: #fff;
            transform: scale(1.05);
            background: linear-gradient(135deg, #EDBB86 0%, #C97F49 100%);
        }

        .ico-pause { display: none; }
        body.is-playing .ico-play { display: none; }
        body.is-playing .ico-pause { display: block; }

        .pl-progress {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 6px;
            font-size: 10.5px;
            color: var(--ink-3);
            font-variant-numeric: tabular-nums;
        }

        .bar {
            position: relative;
            flex: 1 1 auto;
            height: 4px;
            border-radius: 999px;
            background: #EFE2CE;
            cursor: pointer;
        }

        .bar-fill {
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 0;
            border-radius: 999px;
            background: linear-gradient(90deg, #E4A96B, #C1763F);
        }

        .bar-knob {
            position: absolute;
            top: 50%;
            left: 0;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #fff;
            border: 2px solid #C1763F;
            transform: translate(-50%, -50%);
            opacity: 0;
            transition: opacity .18s ease;
        }

        .bar:hover .bar-knob { opacity: 1; }

        .pl-right {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            color: var(--ink-3);
            min-width: 0;
        }

        .pl-right > svg { width: 16px; height: 16px; flex: 0 0 16px; }

        .pl-status {
            font-size: 11px;
            font-weight: 600;
            color: #9B2C2C;
            text-align: right;
            max-width: 210px;
        }

        input[type="range"] {
            -webkit-appearance: none;
            appearance: none;
            width: 92px;
            height: 4px;
            border-radius: 999px;
            background: #EFE2CE;
            outline: none;
            cursor: pointer;
        }

        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #C1763F;
            border: 2px solid #fff;
            box-shadow: 0 1px 4px rgba(0, 0, 0, .2);
        }

        input[type="range"]::-moz-range-thumb {
            width: 12px;
            height: 12px;
            border: 2px solid #fff;
            border-radius: 50%;
            background: #C1763F;
        }

        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        /* ------------------------------ Responsive --------------------------- */
        @media (max-width: 1180px) {
            .app { grid-template-columns: 232px minmax(0, 1fr); }
            .right { display: none; }
        }

        @media (max-width: 820px) {
            body { overflow: auto; }
            .app {
                grid-template-columns: minmax(0, 1fr);
                height: auto;
                min-height: 100vh;
                padding: 10px 10px calc(var(--player-h) + 10px);
            }
            .sidebar { display: none; }
            .main { height: auto; overflow: visible; padding: 0; }
            .hero { padding: 26px 24px; }
            .hero-text { max-width: 100%; }
            .hero-art { display: none; }
            .topbar { flex-wrap: wrap; }
            .topbar #search { max-width: none; }
            .btn-logout { height: 42px; padding: 0 14px; }
            .player { grid-template-columns: minmax(0, 1fr) auto; gap: 12px; padding: 0 14px; }
            .pl-progress, .pl-right { display: none; }
        }

        @media (max-width: 560px) {
            .topbar #search { flex: 1 1 100%; }
            .btn-logout { margin-left: auto; }
            .hero h1 { font-size: 24px; }
            .c-plays { width: 108px; }
        }

        @media (prefers-reduced-motion: reduce) {
            .vinyl { animation: none; }
            .np-eq.is-live i { animation: none; height: 60%; }
        }
    </style>
</head>
<body>
    <form id="formSong" runat="server">
        <asp:HiddenField ID="hfSong" runat="server" />

        <div class="app">

            <!-- ============================ SIDEBAR ============================ -->
            <aside class="sidebar panel">
                <div class="brand">
                    <span class="brand-mark" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 18V5l11-2v13" />
                            <circle cx="6" cy="18" r="3" />
                            <circle cx="17" cy="16" r="3" />
                        </svg>
                    </span>
                    <div>
                        <strong>PoliMusic</strong>
                        <small>Web Avanzada · G2</small>
                    </div>
                </div>

                <nav class="nav">
                    <a class="nav-item" href="Default.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M3 10.5 12 3l9 7.5" />
                            <path d="M5 9.5V21h14V9.5" />
                        </svg>
                        Inicio
                    </a>
                    <a class="nav-item is-active" href="Song.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 18V5l11-2v13" />
                            <circle cx="6" cy="18" r="3" />
                            <circle cx="17" cy="16" r="3" />
                        </svg>
                        Canciones
                    </a>
                    <a class="nav-item" href="#search">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="7" />
                            <path d="m20 20-3.2-3.2" />
                        </svg>
                        Buscar
                    </a>
                    <a class="nav-item" href="#lista">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="4" width="6" height="6" rx="1.5" />
                            <rect x="15" y="4" width="6" height="6" rx="1.5" />
                            <rect x="3" y="14" width="6" height="6" rx="1.5" />
                            <rect x="15" y="14" width="6" height="6" rx="1.5" />
                        </svg>
                        Tu biblioteca
                    </a>
                </nav>

                <div class="lib-head"><span>Playlists</span><span>4</span></div>
                <ul class="lib-list">
                    <li><span class="lib-art g1"></span><span class="lib-meta"><span>Favoritas</span><small>Playlist</small></span></li>
                    <li><span class="lib-art g2"></span><span class="lib-meta"><span>Chill &amp; Focus</span><small>Playlist</small></span></li>
                    <li><span class="lib-art g3"></span><span class="lib-meta"><span>Road Trip</span><small>Playlist</small></span></li>
                    <li><span class="lib-art g4"></span><span class="lib-meta"><span>Descubrimientos</span><small>Playlist</small></span></li>
                </ul>

                <div class="sidebar-foot">
                    <div class="user-card">
                        <asp:Literal ID="litAvatar" runat="server" />
                        <div class="user-meta">
                            <strong><asp:Literal ID="litUserName" runat="server" /></strong>
                            <small><asp:Literal ID="litUserType" runat="server" /></small>
                        </div>
                        <a class="logout-icon" href="Logout.aspx" title="Cerrar sesión" aria-label="Cerrar sesión">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3" />
                                <path d="M10 8l-4 4 4 4" />
                                <path d="M6 12h9" />
                            </svg>
                        </a>
                    </div>
                </div>
            </aside>

            <!-- ============================== MAIN ============================= -->
            <main class="main">

                <header class="topbar">
                    <div id="search">
                        <asp:Panel ID="pnlSearch" runat="server" CssClass="search" DefaultButton="btnSearch">
                            <svg class="search-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
                                <circle cx="11" cy="11" r="7" />
                                <path d="m20 20-3.2-3.2" />
                            </svg>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Buscar por nombre de canción..." />
                            <asp:LinkButton ID="btnSearch" runat="server" CssClass="search-btn" OnClick="btnSearch_Click" ToolTip="Buscar">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
                                    <circle cx="11" cy="11" r="6.5" />
                                    <path d="m19.5 19.5-3.6-3.6" />
                                </svg>
                            </asp:LinkButton>
                        </asp:Panel>
                    </div>

                    <a class="btn-logout" href="Logout.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3" />
                            <path d="M10 8l-4 4 4 4" />
                            <path d="M6 12h9" />
                        </svg>
                        Cerrar sesión
                    </a>
                </header>

                <section class="hero">
                    <div class="hero-text">
                        <span class="eyebrow">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
                                <path d="M4 14a8 8 0 0 1 16 0" />
                                <path d="M4 14v4a2 2 0 0 0 2 2h1v-6H6a2 2 0 0 0-2 2Z" />
                                <path d="M20 14v4a2 2 0 0 1-2 2h-1v-6h1a2 2 0 0 1 2 2Z" />
                            </svg>
                            Tu biblioteca
                        </span>
                        <h1>Bienvenido de nuevo,<br /><span class="hero-name"><asp:Literal ID="litGreetingName" runat="server" /></span></h1>
                        <p>Este es el catálogo de PoliMusic. Elige una canción de la lista y dale play para escucharla.</p>
                        <div class="hero-stats">
                            <div class="stat">
                                <strong><asp:Literal ID="litTotalSongs" runat="server" /></strong>
                                <span>Canciones</span>
                            </div>
                            <div class="stat-div"></div>
                            <div class="stat">
                                <strong><asp:Literal ID="litTotalPlays" runat="server" /></strong>
                                <span>Reproducciones</span>
                            </div>
                        </div>
                    </div>
                    <div class="hero-art" aria-hidden="true">
                        <div class="vinyl"><i></i></div>
                    </div>
                </section>

                <section class="list" id="lista">
                    <div class="list-head">
                        <div>
                            <h2>Song List</h2>
                            <p><asp:Literal ID="litResultCount" runat="server" /> en el catálogo</p>
                        </div>
                        <asp:Label ID="lblMessage" runat="server" CssClass="alert" />
                    </div>

                    <asp:Panel ID="pnlList" runat="server" CssClass="table-wrap">
                        <table class="songs">
                            <thead>
                                <tr>
                                    <th class="c-idx">#</th>
                                    <th>Canción</th>
                                    <th class="c-plays">Reproducciones</th>
                                    <th class="c-act"><span class="sr-only">Acciones</span></th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptSongs" runat="server">
                                    <ItemTemplate>
                                        <tr class="song-row">
                                            <td class="c-idx"><%# (Container.ItemIndex + 1).ToString("00") %></td>
                                            <td>
                                                <div class="song-cell">
                                                    <span class="cover" aria-hidden="true"><%# Initial(Eval("SONG_NAME")) %></span>
                                                    <div class="song-txt">
                                                        <strong><%# H(Eval("SONG_NAME")) %></strong>
                                                        <small><%# FileName(Eval("SONG_PATH")) %></small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="c-plays">
                                                <span class="plays">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                        <path d="M8 5v14l11-7z" />
                                                    </svg>
                                                    <%# N(Eval("PLAYS")) %>
                                                </span>
                                            </td>
                                            <td class="c-act">
                                                <button type="button" class="row-play" aria-label='<%# H("Reproducir " + Eval("SONG_NAME")) %>'
                                                    data-src='<%# SongUrl(Eval("SONG_PATH")) %>'
                                                    data-title='<%# H(Eval("SONG_NAME")) %>'
                                                    data-plays="<%# N(Eval("PLAYS")) %>">
                                                    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                                                        <path d="M8 5v14l11-7z" />
                                                    </svg>
                                                </button>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </asp:Panel>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 18V5l11-2v13" />
                            <circle cx="6" cy="18" r="3" />
                            <circle cx="17" cy="16" r="3" />
                        </svg>
                        <h3>No encontramos canciones</h3>
                        <p>Prueba con otro nombre o limpia la búsqueda para ver todo el catálogo.</p>
                    </asp:Panel>
                </section>

            </main>

            <!-- =========================== NOW PLAYING ========================= -->
            <aside class="right panel">
                <div class="right-head">
                    <span>Ahora suena</span>
                    <span class="live-dot" aria-hidden="true"></span>
                </div>

                <div class="np-cover"><span id="npLetter">♪</span></div>

                <div class="np-title" id="npTitle">Selecciona una canción</div>
                <div class="np-sub" id="npSub">PoliMusic · Catálogo</div>

                <div class="np-eq" id="npEq" aria-hidden="true"><i></i><i></i><i></i><i></i></div>

                <div class="np-meta">
                    <div>
                        <span>Reproducciones</span>
                        <strong id="npPlays">—</strong>
                    </div>
                    <div>
                        <span>Formato</span>
                        <strong>MP3</strong>
                    </div>
                </div>

                <div class="np-queue-head"><span>Cola</span><span id="npQueueCount"></span></div>
                <ul class="np-queue" id="npQueue"></ul>
            </aside>
        </div>

        <!-- ============================= PLAYER ============================= -->
        <footer class="player">
            <audio id="audioPlayer" preload="none"></audio>

            <div class="pl-left">
                <div class="pl-cover" id="plCover">♪</div>
                <div class="pl-meta">
                    <strong id="plTitle">Sin reproducción</strong>
                    <small>PoliMusic · Catálogo</small>
                </div>
            </div>

            <div class="pl-center">
                <div class="pl-controls">
                    <button type="button" class="ctl" id="btnPrev" title="Anterior" aria-label="Canción anterior">
                        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                            <path d="M6 5h2v14H6zM19 5v14L9 12z" />
                        </svg>
                    </button>
                    <button type="button" class="ctl ctl-main" id="btnPlay" title="Reproducir" aria-label="Reproducir o pausar">
                        <svg class="ico-play" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                            <path d="M8 5v14l11-7z" />
                        </svg>
                        <svg class="ico-pause" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                            <rect x="7" y="5" width="3.6" height="14" rx="1" />
                            <rect x="13.4" y="5" width="3.6" height="14" rx="1" />
                        </svg>
                    </button>
                    <button type="button" class="ctl" id="btnNext" title="Siguiente" aria-label="Canción siguiente">
                        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                            <path d="M16 5h2v14h-2zM5 5v14l10-7z" />
                        </svg>
                    </button>
                </div>
                <div class="pl-progress">
                    <span id="curTime">0:00</span>
                    <div class="bar" id="seekBar" role="slider" aria-label="Progreso de la canción"
                        aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
                        <div class="bar-fill" id="seekFill"></div>
                        <div class="bar-knob" id="seekKnob"></div>
                    </div>
                    <span id="durTime">0:00</span>
                </div>
            </div>

            <div class="pl-right">
                <span class="pl-status" id="plStatus"></span>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M11 5 6 9H3v6h3l5 4z" />
                    <path d="M16 9a4 4 0 0 1 0 6" />
                </svg>
                <input type="range" id="volume" min="0" max="1" step="0.01" value="0.85" aria-label="Volumen" />
            </div>
        </footer>
    </form>

    <script type="text/javascript">
        (function () {
            var audio = document.getElementById('audioPlayer');
            var btnPlay = document.getElementById('btnPlay');
            var btnPrev = document.getElementById('btnPrev');
            var btnNext = document.getElementById('btnNext');
            var seekBar = document.getElementById('seekBar');
            var seekFill = document.getElementById('seekFill');
            var seekKnob = document.getElementById('seekKnob');
            var curTime = document.getElementById('curTime');
            var durTime = document.getElementById('durTime');
            var volume = document.getElementById('volume');
            var npTitle = document.getElementById('npTitle');
            var npPlays = document.getElementById('npPlays');
            var npLetter = document.getElementById('npLetter');
            var npEq = document.getElementById('npEq');
            var npQueue = document.getElementById('npQueue');
            var npQueueCount = document.getElementById('npQueueCount');
            var plTitle = document.getElementById('plTitle');
            var plCover = document.getElementById('plCover');
            var plStatus = document.getElementById('plStatus');
            var hidden = document.getElementById('<%= hfSong.ClientID %>');
            var searchInput = document.getElementById('<%= txtSearch.ClientID %>');
            var rows = Array.prototype.slice.call(document.querySelectorAll('.song-row'));
            var currentIndex = -1;

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { seconds = 0; }
                var m = Math.floor(seconds / 60);
                var s = Math.floor(seconds % 60);
                return m + ':' + (s < 10 ? '0' : '') + s;
            }

            function setStatus(message) {
                if (plStatus) { plStatus.textContent = message || ''; }
            }

            function paint(name, plays) {
                var letter = name ? name.charAt(0).toUpperCase() : '♪';
                npTitle.textContent = name || 'Selecciona una canción';
                plTitle.textContent = name || 'Sin reproducción';
                npPlays.textContent = (plays === null || plays === undefined || plays === '') ? '—' : plays;
                npLetter.textContent = letter;
                plCover.textContent = letter;
            }

            function highlight(index) {
                for (var i = 0; i < rows.length; i++) {
                    if (i === index) { rows[i].classList.add('is-active'); }
                    else { rows[i].classList.remove('is-active'); }
                }
                if (npQueue) {
                    var items = npQueue.children;
                    for (var j = 0; j < items.length; j++) {
                        if (j === index) { items[j].classList.add('is-active'); }
                        else { items[j].classList.remove('is-active'); }
                    }
                }
                currentIndex = index;
            }

            function loadTrack(index, autoplay) {
                if (index < 0 || index >= rows.length) { return; }
                var button = rows[index].querySelector('.row-play');
                if (!button) { return; }

                var src = button.getAttribute('data-src');
                var name = button.getAttribute('data-title');
                var plays = button.getAttribute('data-plays');
                if (!src) {
                    setStatus('Esta canción no tiene archivo asociado.');
                    return;
                }

                highlight(index);
                paint(name, plays);
                setStatus('');
                audio.src = src;
                hidden.value = src + '|' + name + '|' + plays;

                if (autoplay) { safePlay(); }
            }

            function safePlay() {
                var promise = audio.play();
                if (promise && typeof promise.catch === 'function') {
                    promise.catch(function () {
                        setStatus('Pulsa ▶ para iniciar la reproducción.');
                    });
                }
            }

            function togglePlay() {
                if (!audio.getAttribute('src')) {
                    if (rows.length > 0) { loadTrack(currentIndex >= 0 ? currentIndex : 0, true); }
                    else { setStatus('El catálogo está vacío.'); }
                    return;
                }
                if (audio.paused) { safePlay(); } else { audio.pause(); }
            }

            btnPlay.addEventListener('click', togglePlay);
            btnPrev.addEventListener('click', function () {
                if (rows.length === 0) { return; }
                var index = currentIndex <= 0 ? rows.length - 1 : currentIndex - 1;
                loadTrack(index, true);
            });
            btnNext.addEventListener('click', function () {
                if (rows.length === 0) { return; }
                var index = (currentIndex + 1) % rows.length;
                loadTrack(index, true);
            });

            rows.forEach(function (row, index) {
                row.addEventListener('click', function () { loadTrack(index, true); });
            });

            // Cola de reproduccion construida con las canciones visibles.
            if (npQueue) {
                rows.forEach(function (row, index) {
                    var button = row.querySelector('.row-play');
                    var item = document.createElement('li');
                    var order = document.createElement('span');
                    var name = document.createElement('span');
                    order.className = 'np-qidx';
                    order.textContent = (index + 1 < 10 ? '0' : '') + (index + 1);
                    name.className = 'np-qname';
                    name.textContent = button ? button.getAttribute('data-title') : '';
                    item.appendChild(order);
                    item.appendChild(name);
                    item.addEventListener('click', function () { loadTrack(index, true); });
                    npQueue.appendChild(item);
                });
                if (npQueueCount) { npQueueCount.textContent = rows.length; }
            }

            audio.addEventListener('play', function () {
                document.body.classList.add('is-playing');
                npEq.classList.add('is-live');
                btnPlay.setAttribute('title', 'Pausar');
            });

            audio.addEventListener('pause', function () {
                document.body.classList.remove('is-playing');
                npEq.classList.remove('is-live');
                btnPlay.setAttribute('title', 'Reproducir');
            });

            audio.addEventListener('ended', function () {
                if (rows.length > 1) { btnNext.click(); }
            });

            audio.addEventListener('timeupdate', function () {
                var duration = audio.duration || 0;
                var current = audio.currentTime || 0;
                var percent = duration > 0 ? (current / duration) * 100 : 0;
                seekFill.style.width = percent + '%';
                seekKnob.style.left = percent + '%';
                seekBar.setAttribute('aria-valuenow', Math.round(percent));
                curTime.textContent = formatTime(current);
                durTime.textContent = formatTime(duration);
            });

            audio.addEventListener('loadedmetadata', function () {
                durTime.textContent = formatTime(audio.duration);
            });

            audio.addEventListener('error', function () {
                setStatus('No se encontró el archivo de audio en el servidor.');
                document.body.classList.remove('is-playing');
                npEq.classList.remove('is-live');
            });

            seekBar.addEventListener('click', function (event) {
                var rect = seekBar.getBoundingClientRect();
                var ratio = (event.clientX - rect.left) / rect.width;
                if (ratio < 0) { ratio = 0; }
                if (ratio > 1) { ratio = 1; }
                if (audio.duration) { audio.currentTime = ratio * audio.duration; }
            });

            volume.addEventListener('input', function () {
                audio.volume = parseFloat(volume.value);
            });
            audio.volume = parseFloat(volume.value);

            // Restaura la cancion seleccionada despues de una busqueda (postback).
            if (hidden.value) {
                var parts = hidden.value.split('|');
                paint(parts[1], parts[2]);
                audio.src = parts[0];
                for (var i = 0; i < rows.length; i++) {
                    var playButton = rows[i].querySelector('.row-play');
                    if (playButton && playButton.getAttribute('data-src') === parts[0]) {
                        highlight(i);
                        break;
                    }
                }
            }

            document.addEventListener('keydown', function (event) {
                var tag = (event.target.tagName || '').toLowerCase();
                if (tag === 'input' || tag === 'textarea' || tag === 'select' || tag === 'button' || tag === 'a') { return; }
                if (event.code === 'Space' || event.keyCode === 32) {
                    event.preventDefault();
                    togglePlay();
                }
                if (event.key === '/' && searchInput) {
                    event.preventDefault();
                    searchInput.focus();
                }
            });
        })();
    </script>
</body>
</html>
