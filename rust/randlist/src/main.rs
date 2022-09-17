extern crate clap;
extern crate rand;
use clap::{App, ArgMatches};
use rand::prelude::SliceRandom;
use rand::thread_rng;
use std::collections::HashMap;
use std::fs::File;
use std::io::Read;

struct RandlistDetails<'a> {
    source: &'a str,
    omitfile: &'a str,
    listsize: i32,
    verbose: bool,
}

fn filecontents(filename: &str) -> Result<String, std::io::Error> {
    let mut data = String::new();
    let mut f = File::open(filename)?;
    f.read_to_string(&mut data)?;
    Ok(data)
}

fn get_args<'a>(matches: &'a ArgMatches) -> RandlistDetails<'a> {
    let source_arg = matches.value_of("source").unwrap();
    let omitfile_arg = matches.value_of("omitfile").unwrap_or("");
    let listsize_arg = matches.value_of("listsize").unwrap_or("");
    let verbose_arg = match matches.occurrences_of("verbose") {
        0 => false,
        _ => true,
    };
    RandlistDetails {
        source: source_arg,
        omitfile: omitfile_arg,
        listsize: match listsize_arg {
            "" => -1,
            _ => match listsize_arg.to_string().parse::<i32>() {
                Ok(data) => data,
                Err(f) => {
                    panic!("Invalid list size provided ({})", f.to_string());
                }
            },
        },
        verbose: verbose_arg,
    }
}

fn main() {
    // get arguments
    let matches = App::new("Random songlist generator")
        .version("0.9")
        .author("Colin M. <oletalk@gmail.com>")
        .about("Shuffles a playlist")
        .args_from_usage(
            "-s, --source=[SOURCEFILE] 'Sets the source file containing song file paths'
                         -o, --omitfile=[OMITFILE] 'List of songs to omit from the generated list'
                         -l, --listsize=[SIZE] 'Number of songs to extract'
                         -v, --verbose 'Sets verbose mode'",
        )
        .get_matches();
    let app_options = get_args(&matches);

    // read songfile - unwrap to a panic! is fine...
    let songfile = filecontents(app_options.source).unwrap();
    let mut lines: Vec<&str> = songfile.lines().collect();
    if app_options.verbose {
        println!("I got {} lines from your source file.", lines.len());
    }

    // read omitfile. it's ok if there's none, don't make it panic!
    let omitfile = match filecontents(app_options.omitfile) {
        Ok(data) => data,
        Err(_) => "".to_string(),
    };
    let omitcheck = omitfile
        .lines()
        .map(|line| (line, 1))
        .collect::<HashMap<_, _>>();
    // spit out randomised lines
    let mut rng = thread_rng();
    lines.as_mut_slice().shuffle(&mut rng);

    let randlist = lines.into_iter().filter(|&x| !omitcheck.contains_key(x));
    let mut count = 0;

    for line in randlist {
        println!("{}", line);
        count = count + 1;
        if count == app_options.listsize {
            break;
        }
    }
    if app_options.verbose {
        println!("Filtered list is of size {}.", count);
    }
}
