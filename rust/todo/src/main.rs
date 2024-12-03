mod model;
// use model::model::Todo; /* FIXME: try to get rid of 2nd 'model' */
mod ioutil;
use clap::Parser;

use crate::model::model::TodoList;

// make sure the 'clap' dependency line in Cargo.toml looks like
// clap = { version = "X.X.X", features = ["derive"]}
#[derive(Parser)]
struct Task {
    #[arg(value_enum)]
    action: String, // do what?
    item: String,   // to what?
}

/* to do :-)

X 1. display only tasks in the future
X 2. add overdue tasks to this
X 3. allow completing of tasks
4. allow postponing of tasks
*/

fn main() {
    let data = ioutil::filecontents("mylist.txt").unwrap_or("[]".to_string());
    let todo_list = TodoList::from(data);

    let args = Task::parse();
    println!("Action requested: {}", args.action);
    match args.action.as_str() {
        "list" => {
            todo_list.list(args.item.as_str())
        },
        "complete" => {
            todo_list.complete(args.item.as_str())
        },
        "postpone" => {
            // postpone 1 day
            todo_list.postpone(args.item.as_str())
        },
    _ => {
        println!("unsupported action");
        }
    }

}
