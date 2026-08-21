# Omarchy Vibez

`omarchy-vibez` adds a vibez controller to the Omarchy bar.

It talks to vibez through MPRIS, so vibez must be running for now-playing data
and transport controls to appear. Recent vibez builds export the
`org.mpris.MediaPlayer2.vibez` D-Bus player on Linux.

## Features

- Bar icon with optional current track and artist.
- Popup with album art, title, artist, album, progress, and transport controls.
- Middle/right click play-pause from the bar.
- Launch button for opening `vibez` in a terminal.
- Theme-aware colors through Omarchy's existing Quickshell components.

## Requirements

- Omarchy 4.
- vibez installed and available on `PATH`.
- A terminal available through `ghostty`, `alacritty`, `kitty`,
  `xdg-terminal-exec`, or `vibez` launched from an existing terminal.

## Install

From this local folder:

```bash
omarchy plugin add /home/elyefris/Documents/Codex/2026-08-20/loco-ahora-que-est-de-moda/outputs/omarchy-vibez
omarchy plugin enable io.github.local.omarchy-vibez
omarchy bar plugin add io.github.local.omarchy-vibez
```

From a Git repo after publishing:

```bash
omarchy plugin add https://github.com/YOUR_USER/omarchy-vibez.git --enable
omarchy bar plugin add io.github.local.omarchy-vibez
```

## Usage

- Left click opens the popup by default.
- Middle click or right click toggles play-pause.
- Inside the popup, `Space` toggles play-pause, `n` skips next, `p` goes
  previous, `o` opens vibez, and `Esc` closes the popup.

## Notes

The launch command tries `uwsm app -- ghostty -e vibez`, then Alacritty, Kitty,
`xdg-terminal-exec`, and finally `vibez`. If your terminal is different, edit
the `launchVibez.command` value in `Panel.qml`.

This plugin is intentionally small. Vibe mode, search, queue editing, and auth
remain inside the vibez TUI.
