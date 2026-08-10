# Unix timestamp

Live unix epoch clock for the Omarchy bar, backed by the `waybar-unixtime`
Rust binary in `~/.cargo/bin`.

## How it works

The binary was written for Waybar, where it is polled with `once` on an
interval and nudged with `pkill -RTMIN+8`. Quickshell has no such signal
plumbing, so this widget uses the binary's `run` mode instead: one long-lived
process streaming a JSON line per tick, read through a `SplitParser`.

Display format is state owned by the binary, not the widget. A click that
runs `toggle` or `cycle` mutates that state, and the already-running stream
emits the new format on its next tick — which is why nothing here has to
poke the stream after an action.

`~/.cargo/bin` is not on the shell process's `PATH`, so `binPath` is resolved
through `bash` to expand `$HOME`.

## Controls

| Input        | Action                                    |
|--------------|-------------------------------------------|
| Left click   | Copy current timestamp to clipboard       |
| Middle click | Toggle seconds / milliseconds             |
| Right click  | Step to next format                       |
| Scroll       | Walk formats forward / back               |
| Hover        | Panel with every format, live             |

The binary's `picker` subcommand is deliberately unused — it needs
walker/fuzzel/wofi/rofi, none of which are installed here, so it would fail
silently.

## Why the hover panel is a PopupCard, not a tooltip

The bar's built-in tooltip is a single `Text` with `horizontalAlignment:
Text.AlignHCenter` (`plugins/bar/Bar.qml`), so it centres every line
independently — which pulls any column table out of alignment. The panel is a
`PopupCard` in its passive `triggerMode: "hover"` mode instead: the same card
chrome the click panels use, left-aligned, with the label column pinned to a
constant-measured width so all values share one x.

That width is measured off the constant `"European (short)"` rather than off
the live values, so the column does not reflow every second as digits tick.

## Card width: an API asymmetry

`PopupCard.fittedContentHeight()` folds the card's vertical padding and border
into its result, but `fittedContentWidth()` has **no** horizontal counterpart —
it takes an already-finished card width. Passing raw content width therefore
loses `padding * 2 + borders` to the chrome and clips the longest rows
(`RFC 2822`, `Unix readable`). The inset is added explicitly here via
`horizontalInset`. Media's widget hides this by passing a fixed
`Style.space(320)` rather than a content-derived width.

The binary's own tooltip string is unused too — it is Pango markup, which Qt's
rich text does not render. The plain `formats` table is parsed instead, and
only polled while the panel is open.

## Font size

`fontSize` is `Style.font.body`, matching the clock beside it. This is not
cosmetic-only: both labels are centre-anchored in the same slot height, so a
smaller font would sit visibly higher than the clock. At equal size the digits
land on the same pixel row (verified: both `top=16 bot=33`). `baselineNudge`
is there if a future font ever needs a manual offset; 0 is correct today.

## Reloading after an edit

`omarchy-shell shell rescanPlugins` does **not** reliably pick up changes to
this file — Qt serves the cached compiled QML for the same URL, so the widget
keeps running the old code while reporting success. Use `omarchy restart shell`
after editing. The giveaway is a newly added IPC method answering
"Function not found".

The shell's stdout and stderr both go to `/dev/null`, so QML errors are not
logged anywhere; a widget that vanishes from the bar is the error signal.

## Installing on another Omarchy machine

This directory is the whole widget; the pieces that are *not* in it are the
binary and the one-line bar entry.

```bash
# 1. the binary this widget is a front-end for (crates.io, v0.5.0 here)
cargo install waybar-unixtime

# 2. the plugin itself — from the dotfiles stow package
cd ~/dotfiles && stow -t ~ omarchy
#    or, without stow:
#    cp -r ~/dotfiles/omarchy/.config/omarchy/plugins/unixtime ~/.config/omarchy/plugins/

# 3. put it in the bar: add {"id": "unixtime"} to bar.layout in
#    ~/.config/omarchy/shell.json — this file is deliberately NOT stowed,
#    because the bar layout is per-machine.

# 4. load it
omarchy restart shell
```

Requires `wl-copy` (wl-clipboard) for the copy action and `notify-send`
(libnotify) for the copy notification; set `notifyOnCopy: false` to drop the
second dependency. Both ship with Omarchy by default.

Verify it took: `omarchy-shell unixtime showPanel` should open the panel
rather than answer "Function not found".

## Settings

Set these on the widget's entry in `~/.config/omarchy/shell.json`:

| Key            | Default                              | Meaning                     |
|----------------|--------------------------------------|-----------------------------|
| `intervalMs`   | `1000`                               | Stream tick, in ms          |
| `notifyOnCopy` | `true`                               | Notify on clipboard copy    |
| `binPath`      | `$HOME/.cargo/bin/waybar-unixtime`   | Path to the binary          |

## IPC

```bash
omarchy-shell unixtime copy
omarchy-shell unixtime toggle
omarchy-shell unixtime cycle
omarchy-shell unixtime cycleBack
omarchy-shell unixtime restart
omarchy-shell unixtime showPanel
omarchy-shell unixtime hidePanel
```

`showPanel`/`hidePanel` exist because the panel is hover-driven and therefore
otherwise untestable without warping the pointer; they also let a keybind
summon it.
