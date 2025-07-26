use std::fmt;

enum District {
    North, South, East
}
struct MyStruct{
    foo: i32,
    bar: i32,
    baz: District
}

pub trait Foobarish<T> {
    fn foobar(&self) -> T;
}
impl Foobarish<i32> for MyStruct {
    fn foobar(&self) -> i32 {
        self.foo * self.bar
    }
}
impl MyStruct {

    fn new(f: i32, b: i32, bz: District) -> MyStruct {
        MyStruct{ foo: f, bar: b, baz: bz }
    }
}

impl fmt::Display for MyStruct {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let printbaz = match &self.baz {
            District::North => "North",
            District::South => "South",
            District::East => "East",
        };
        write!(f, "MyStruct -> ({}, {}, '{}')", self.foo, self.bar, printbaz)
    }
    
}


fn main() {
    let v =[ 
        MyStruct::new(1, 2, District::East), 
        MyStruct::new(4, 6, District::South), 
        MyStruct::new(3, 4, District::North)
    ];
    for x in v.iter() { /* .enumerate for an extra counter in a tuple e.g. (x, index) */
        println!("{}", x);
        println!("{}", x.foobar())
    }
}
