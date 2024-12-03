use std::{cmp::Ordering, io};
use rand::Rng;

fn main() {
    println!("Guess the number!");
    let secret_number = rand::thread_rng().gen_range(1..=100);

    let mut num_guess = 1;

    loop {
        println!("Please input your guess.");

        let mut guess = String::new();

        io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");
    
        let guess: u32 = guess.trim().parse().expect("Please type a number!");
        println!("You guessed: {guess}");
    
        match guess.cmp(&secret_number) {
            Ordering::Less => println!("too small..."),
            Ordering::Greater => println!("too big!"),
            Ordering::Equal => {
                println!("You win!!");
                let str = if num_guess == 1 { "guess" } else { "guesses" };
                println!("You got the number in {num_guess} {str} ");
                break;
            }
        }
        num_guess += 1;
    }
}
