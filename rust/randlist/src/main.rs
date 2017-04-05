extern crate rand;
extern crate clap;
use std::fs::File;
use std::io::Read;
use std::collections::HashMap;
use clap::App;
use rand::{thread_rng, Rng};

fn filecontents(filename: &str) -> Result<String,std::io::Error> {
    let mut data = String::new();
    let mut f = try!(File::open(filename));
    try!(f.read_to_string(&mut data));
    Ok(data)
}

fn main() {
    // get arguments
    let matches = App::new("Random songlist generator")
                    .version("0.9")
                    .author("Colin M. <oletalk@gmail.com>")
                    .about("Shuffles a playlist")
                    .args_from_usage(
                        "-s, --source=[SOURCEFILE] 'Sets the source file containing song file paths'
                         -o, --omitfile=[OMITFILE] 'List of songs to omit from the generated list'")
                    .get_matches();
    let source_arg = matches.value_of("source").unwrap();
    let omitfile_arg = matches.value_of("omitfile").unwrap_or("");

    // read songfile - unwrap to a panic! is fine...
    let songfile = filecontents(source_arg).unwrap();
    let mut lines: Vec<&str> = songfile.lines().collect();
    println!("I got {} lines from your source file.", lines.len());

    // read omitfile TODO: it's ok if there's none, don't make it panic!
    let omitfile = match filecontents(omitfile_arg) {
        Ok(data) => data,
        Err(_) => "".to_string()
    };
    let omitcheck = omitfile.lines().map(|line| (line, 1)).collect::<HashMap<_, _>>();
    // spit out randomised lines
    thread_rng().shuffle(lines.as_mut_slice());
    for line in lines {
        match omitcheck.get(line) {
            Some(_) => println!("  (file in omitlist, skipped)"),
            None => println!("line -> {}", line),
        }
    }
}
