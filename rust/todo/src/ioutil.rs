#[doc(inline)]
use std::fs;
use std::fs::File;
use std::io::Error;
use std::io::Read;

// return file contents in a String
pub fn filecontents(filename: &str) -> Result<String, Error> {
  let mut data = String::new();
  let mut f = File::open(filename)?;
  f.read_to_string(&mut data)?;
  Ok(data)
}

// write the given string to the file
pub fn writefile(filename: &str, data: &str) -> Result<(), Error> {
  fs::write(filename, data)?;
  Ok(())
}