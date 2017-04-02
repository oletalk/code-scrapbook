extern crate rand;
use std::fs::File;
use std::io::Read;
use std::collections::HashMap;
use rand::{thread_rng, Rng};

// TODO: pass these in as parameters
static SOURCE: &'static str = "test.txt";
static OMITFILE: &'static str = "omitfile.txt";


fn filecontents(filename: &str) -> Result<String,std::io::Error> {
    let mut data = String::new();
    let mut f = try!(File::open(filename));
    try!(f.read_to_string(&mut data));
    Ok(data)
}

fn main() {

    // read songfile - unwrap to a panic! is fine...
    let songfile = filecontents(SOURCE).unwrap();
    let mut lines: Vec<&str> = songfile.lines().collect();
    println!("I got {} lines from your source file.", lines.len());

    // read omitfile TODO: it's ok if there's none, don't make it panic!
    let omitfile = match filecontents(OMITFILE) {
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
