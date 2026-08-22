use std::cell::RefCell;
use std::collections::HashMap;
use std::fmt;
use std::fs::File;
use std::io::BufReader;
use std::path::PathBuf;
use std::rc::Rc;

/* TODO: shrink font in main calendar so it's a sensible size
 *  format of DTSTART/DTEND seems to be 20190427T130000Z */
use chrono::{Datelike, NaiveDate, NaiveTime};
use gtk::gdk::Display;
use gtk::glib;
use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, CssProvider};

const APP_ID: &str = "uk.co.oletalk.cal-widget";
const CALENDAR_DIR: &str = ".calendars/all";
const CONFIG_SUBDIR: &str = "cal-widget";
const STYLE_CSS_FILENAME: &str = "style.css";

/// One parsed event, reduced to just what the widget needs.
#[derive(Clone, Debug)]
struct EventEntry {
    date_start: NaiveDate,
    date_end: Option<NaiveDate>,
    time_start: Option<NaiveTime>,
    time_end: Option<NaiveTime>,
    summary: String,
    location: Option<String>,
    all_day: bool,
}

struct ParsedEntry {
    date_part: Option<NaiveDate>,
    time_part: Option<NaiveTime>,
    all_day: bool,
}

impl fmt::Display for EventEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // deal with optional bits
        // let ds = self.date_start.to_string();
        let disp_time = if self.all_day {
            String::from("(all day)")
        } else {
            if let (Some(start_time), Some(end_time)) = (self.time_start, self.time_end) {
                format!(
                    "{}-{}",
                    start_time.format("%H:%M"),
                    end_time.format("%H:%M")
                )
            } else {
                String::from("")
            }
        };
        let disp_location = if let Some(loc) = &self.location {
            format!(" ({})", loc)
        } else {
            String::from("")
        };
        write!(f, "{} {}\n{}", self.summary, disp_time, disp_location)
    }
}

/// Resolves the stylesheet path as `<config_dir>/cal-widget/style.css`
/// (e.g. `~/.config/cal-widget/style.css` on Linux). Returns None if the
/// platform has no config dir.
fn style_css_path() -> Option<PathBuf> {
    dirs::config_dir().map(|c| c.join(CONFIG_SUBDIR).join(STYLE_CSS_FILENAME))
}

fn load_css() {
    let Some(path) = style_css_path() else {
        eprintln!("cal-widget: couldn't resolve a config dir (continuing without custom styles)");
        return;
    };

    let provider = CssProvider::new();
    provider.connect_parsing_error(|_, section, error| {
        eprintln!(
            "cal-widget: CSS parse error: {} (line {})",
            error,
            section.start_location().lines()
        );
    });
    match std::fs::read_to_string(&path) {
        Ok(css) => provider.load_from_data(&css),
        Err(err) => {
            eprintln!(
                "cal-widget: couldn't read {}: {} (continuing without custom styles)",
                path.display(),
                err
            );
            return;
        }
    }

    gtk::style_context_add_provider_for_display(
        &Display::default().expect("no display available"),
        &provider,
        // gtk::STYLE_PROVIDER_PRIORITY_APPLICATION,
        gtk::STYLE_PROVIDER_PRIORITY_USER,
    );
}

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();
    app.connect_startup(|_| load_css());
    app.connect_activate(build_ui);
    app.run()
}

fn build_ui(app: &Application) {
    let window = ApplicationWindow::builder()
        .application(app)
        .title("Calendar")
        .default_width(420)
        .default_height(420)
        .build();

    // Root layout: header (nav) + grid, swapped out whenever month changes.
    let root = gtk::Box::new(gtk::Orientation::Vertical, 0);
    root.set_margin_top(8);
    root.set_margin_bottom(8);
    root.set_margin_start(8);
    root.set_margin_end(8);

    let header = gtk::Box::new(gtk::Orientation::Horizontal, 6);
    let prev_btn = gtk::Button::from_icon_name("go-previous-symbolic");
    let next_btn = gtk::Button::from_icon_name("go-next-symbolic");
    let month_label = gtk::Label::new(None);
    month_label.set_hexpand(true);
    month_label.add_css_class("title-2");

    header.append(&prev_btn);
    header.append(&month_label);
    header.append(&next_btn);

    let grid_container = gtk::Box::new(gtk::Orientation::Vertical, 0);

    root.append(&header);
    root.append(&gtk::Separator::new(gtk::Orientation::Horizontal));
    root.append(&grid_container);
    let quit_row = gtk::Button::new();
    quit_row.add_css_class("quit-button");
    let quit_label = gtk::Label::new(Some("Quit"));
    quit_label.set_halign(gtk::Align::Fill);
    quit_row.set_child(Some(&quit_label));
    let app_clone = app.clone();
    quit_row.connect_clicked(move |_| {
        app_clone.quit();
    });
    root.append(&quit_row);

    window.set_child(Some(&root));

    // Currently displayed month, as the 1st-of-month date.
    let today = chrono::Local::now().date_naive();
    let shown_month = Rc::new(RefCell::new(
        NaiveDate::from_ymd_opt(today.year(), today.month(), 1).unwrap(),
    ));

    let redraw = {
        let month_label = month_label.clone();
        let grid_container = grid_container.clone();
        let shown_month = shown_month.clone();
        move || {
            let month_start = *shown_month.borrow();
            month_label.set_label(&month_start.format("%B %Y").to_string());

            // Drop the old grid and build a fresh one.
            while let Some(child) = grid_container.first_child() {
                grid_container.remove(&child);
            }

            let events = load_events_for_month(month_start);
            let calendar_grid = build_month_grid(month_start, today, &events);
            grid_container.append(&calendar_grid);
        }
    };
    redraw();

    let redraw_rc = Rc::new(redraw);

    {
        let shown_month = shown_month.clone();
        let redraw_rc = redraw_rc.clone();
        prev_btn.connect_clicked(move |_| {
            let mut m = shown_month.borrow_mut();
            *m = shift_month(*m, -1);
            drop(m);
            redraw_rc();
        });
    }
    {
        let shown_month = shown_month.clone();
        let redraw_rc = redraw_rc.clone();
        next_btn.connect_clicked(move |_| {
            let mut m = shown_month.borrow_mut();
            *m = shift_month(*m, 1);
            drop(m);
            redraw_rc();
        });
    }

    window.present();
}

fn shift_month(d: NaiveDate, delta: i32) -> NaiveDate {
    let mut year = d.year();
    let mut month = d.month() as i32 + delta;
    while month < 1 {
        month += 12;
        year -= 1;
    }
    while month > 12 {
        month -= 12;
        year += 1;
    }
    NaiveDate::from_ymd_opt(year, month as u32, 1).unwrap()
}

/// Build the 7xN grid of day cells for the given month.
fn build_month_grid(
    month_start: NaiveDate,
    today: NaiveDate,
    events: &HashMap<NaiveDate, Vec<EventEntry>>,
) -> gtk::Grid {
    let grid = gtk::Grid::new();
    grid.set_row_spacing(4);
    grid.set_column_spacing(4);
    grid.set_row_homogeneous(true);
    grid.set_column_homogeneous(true);

    let weekday_names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    for (col, name) in weekday_names.iter().enumerate() {
        let lbl = gtk::Label::new(Some(name));
        lbl.add_css_class("dim-label");
        grid.attach(&lbl, col as i32, 0, 1, 1);
    }

    // ISO weekday: Monday = 1 ... Sunday = 7. Column 0 = Monday.
    let leading_blanks = month_start.weekday().num_days_from_monday();
    let days_in_month = days_in_month(month_start);

    let mut row = 1;
    let mut col = leading_blanks as i32;

    for day in 1..=days_in_month {
        let date = month_start.with_day(day).unwrap();
        let cell = build_day_cell(date, date == today, events.get(&date));
        grid.attach(&cell, col, row, 1, 1);

        col += 1;
        if col > 6 {
            col = 0;
            row += 1;
        }
    }

    grid
}

fn build_day_cell(
    date: NaiveDate,
    is_today: bool,
    day_events: Option<&Vec<EventEntry>>,
) -> gtk::Widget {
    let cell = gtk::Box::new(gtk::Orientation::Vertical, 2);
    cell.set_valign(gtk::Align::Fill);
    cell.set_halign(gtk::Align::Fill);

    let day_label = gtk::Label::new(Some(&date.day().to_string()));
    day_label.set_halign(gtk::Align::Start);
    if is_today {
        day_label.add_css_class("calendar-today");
        day_label.add_css_class("heading");
        cell.add_css_class("day-today");
    }
    cell.append(&day_label);

    if let Some(evts) = day_events {
        // Small marker dot to indicate "has events".
        let tooltip = evts
            .iter()
            // .map(|e| e.summary.clone() + &e.date_start.clone().to_string())
            .map(|e| format!("{e}"))
            .collect::<Vec<_>>()
            .join("\n");
        cell.set_tooltip_text(Some(&tooltip));

        // let marker = gtk::Label::new(Some("•"));
        let marker = gtk::Label::new(Some(&events_tooltip(&tooltip)));
        marker.set_wrap(true);
        marker.set_width_chars(20);
        marker.set_max_width_chars(20);
        marker.add_css_class("accent");
        marker.add_css_class("calendar-entry");
        marker.set_halign(gtk::Align::Start);
        cell.append(&marker);
    }

    // let celltext = gtk::Label::new(Some("hh"));
    // TODO: css
    // celltext.set_halign(gtk::Align::End);
    // cell.append(&celltext);
    cell.add_css_class("card");
    cell.set_margin_top(2);
    cell.set_margin_bottom(2);
    cell.upcast()
}

fn days_in_month(month_start: NaiveDate) -> u32 {
    let next = shift_month(month_start, 1);
    (next - month_start).num_days() as u32
}

fn events_tooltip(allevents: &str) -> String {
    let mut lines = allevents.lines();
    let mut tip = lines.next().unwrap_or("").to_string();
    tip.truncate(50);
    let remaining = lines.count();
    if remaining > 0 {
        format!("{} (+ {})", tip, remaining)
    } else {
        tip
    }
}

/// Scan ~/.calendars/all/**/*.ics and return events that fall within
/// `month_start`'s month, keyed by date.
///
/// Note: this reads DTSTART/DTEND/SUMMARY only. Recurring events (RRULE)
/// are not expanded here — only the recorded occurrence's own DTSTART is
/// used. Expanding RRULEs properly would need a dedicated crate (e.g.
/// `rrule`) plus EXDATE/RECURRENCE-ID handling; flagging that as a
/// follow-up rather than faking it.
fn load_events_for_month(month_start: NaiveDate) -> HashMap<NaiveDate, Vec<EventEntry>> {
    let mut out: HashMap<NaiveDate, Vec<EventEntry>> = HashMap::new();

    let Some(dir) = calendar_dir() else {
        return out;
    };
    if !dir.exists() {
        return out;
    }

    let month_end = shift_month(month_start, 1);

    for entry in walkdir::WalkDir::new(&dir)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
        .filter(|e| e.path().extension().map(|x| x == "ics").unwrap_or(false))
    {
        let path = entry.path().to_path_buf();
        for ev in parse_ics_file(&path) {
            if ev.date_start >= month_start && ev.date_start < month_end {
                out.entry(ev.date_start).or_default().push(ev);
            }
        }
    }

    for v in out.values_mut() {
        v.sort_by(|a, b| a.date_start.cmp(&b.date_start));
    }

    out
}

fn calendar_dir() -> Option<PathBuf> {
    dirs::home_dir().map(|h| h.join(CALENDAR_DIR))
}

fn parse_ics_file(path: &PathBuf) -> Vec<EventEntry> {
    let mut results = Vec::new();

    let file = match File::open(path) {
        Ok(f) => f,
        Err(_) => return results,
    };
    let buf = BufReader::new(file);
    let parser = ical::IcalParser::new(buf);

    for cal in parser.filter_map(|c| c.ok()) {
        for vevent in cal.events {
            let mut dtstart_raw: Option<String> = None;
            let mut dtend_raw: Option<String> = None;
            let mut summary = String::from("(untitled)");
            let mut location: Option<String> = None;

            for prop in &vevent.properties {
                match prop.name.as_str() {
                    "DTSTART" => {
                        if let Some(v) = &prop.value {
                            dtstart_raw = Some(v.clone());
                        }
                    }
                    "DTEND" => {
                        if let Some(v) = &prop.value {
                            dtend_raw = Some(v.clone());
                        }
                    }
                    "SUMMARY" => {
                        if let Some(v) = &prop.value {
                            summary = v.clone();
                        }
                    }
                    "LOCATION" => {
                        if let Some(v) = &prop.value {
                            location = Some(v.clone());
                        }
                    }
                    _ => {}
                }
            }

            if let (Some(raw1), Some(raw2)) = (dtstart_raw, dtend_raw) {
                let (parseddate_start, parseddate_end) =
                    (parse_ics_date(&raw1), parse_ics_date(&raw2));

                results.push(EventEntry {
                    date_start: parseddate_start.date_part.unwrap(),
                    time_start: parseddate_start.time_part,
                    date_end: parseddate_end.date_part,
                    time_end: parseddate_end.time_part,
                    location,
                    summary,
                    all_day: parseddate_start.all_day,
                });
            }
        }
    }

    results
}

/// Parses the date portion out of an ICS DTSTART value. Handles both
/// all-day values ("20260817") and date-time values
/// ("20260817T090000" / "20260817T090000Z").
fn parse_ics_date(raw: &str) -> ParsedEntry {
    let mut splitter = raw.split('T');

    let date_part = splitter.next().unwrap_or(raw);
    let all_day = !raw.contains('T');
    let ntime = if all_day {
        None
    } else {
        let mut time_part = String::from(splitter.next().unwrap_or(""));
        time_part.truncate(6);
        // println!("parsing time: {}", time_part);
        NaiveTime::parse_from_str(&time_part, "%H%M%S").ok()
    };
    let ndate = NaiveDate::parse_from_str(date_part, "%Y%m%d").ok();

    // Some((ndate.unwrap(), ntime.unwrap(), all_day))
    ParsedEntry {
        date_part: ndate,
        time_part: ntime,
        all_day,
    }
}
