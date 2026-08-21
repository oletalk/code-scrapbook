# cal-widget

A small GTK4 window that shows the current month as a grid and marks
days that have events pulled from `.ics` files under
`~/.calendars/all/` (recursively — works with vdirsyncer's
one-file-per-event layout, subfolders and all).

- Click the arrows in the header to move between months (events are
  re-scanned from disk each time).
- Days with events get a small dot; hover a day to see the event
  titles for that day in a tooltip.
- Today's date is highlighted.

## Build

Needs GTK4 dev headers and a recent-ish Rust toolchain (edition 2021,
rustup-installed stable is fine — the version bundled in older distro
package managers may be too old for the current gtk4-rs/glib
dependency tree).

```sh
# Arch:
sudo pacman -S gtk4 base-devel

cargo build --release
./target/release/cal-widget
```

## Known limitation

DTSTART is read directly off each VEVENT, but **RRULE (recurring
events) is not expanded** — a recurring event only shows up on the
date of its first/stored occurrence. Expanding recurrence properly
needs a dedicated crate (e.g. `rrule`) plus EXDATE/RECURRENCE-ID
handling on top of it; wiring that in is the natural next step if you
rely on repeating events.

## Layout

- `src/main.rs` — everything: app setup, month grid rendering,
  `.ics` scanning/parsing.
- Rescans and rebuilds the whole grid on month navigation rather than
  caching — the file set is small enough that this is simpler and
  keeps the widget always in sync with what's on disk.
