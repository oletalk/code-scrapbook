pub mod model {
  use std::error::Error;
  use serde::{Deserialize, Serialize};
  use chrono::{Utc, NaiveDate, Days};  
  use std::convert::From;

  #[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq)]
  pub enum TaskStatus {
    ToDo, InProgress, Blocked, Done
}

/* TODO-STRUCTURE */
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Todo {
    name: String,
    due_date: String,
    status: TaskStatus
}

impl Todo {
  pub fn get_name(&self) -> &String {
    &self.name
  }

  pub fn postpone(&mut self, number_of_days: u64) {
    let duedate = &self.duedate();
    duedate.checked_add_days(Days::new(number_of_days)).unwrap();
    self.due_date = duedate.to_string();
  }
  pub fn complete(&mut self) {
    self.status = TaskStatus::Done
  }

   pub fn is_open(&self) -> bool {
        self.status == TaskStatus::ToDo && self.duedate() > Utc::now().date_naive()
   }
   
   pub fn is_overdue(&self) -> bool {
       self.status == TaskStatus::ToDo && self.duedate() < Utc::now().date_naive()
   }

   fn duedate(&self) -> NaiveDate {
    let dt = NaiveDate::parse_from_str(&self.due_date.to_owned(), "%Y-%m-%d");
    dt.unwrap() // TODO: ok to die if one of the dates isn't parseable?
}
   
}


/* TODOLIST-STRUCTURE */
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct TodoList {
  list: Vec<Todo>,
  base_file: String
}

impl From<String> for TodoList {
  fn from(item: String) -> Self {
      TodoList {
        list: serde_json::from_str(&item).unwrap(),
        base_file: item 
      }
  }
}

  impl TodoList {
    pub fn list(&self, list_type: &str) {
      match list_type { /* TODO: list overdue, list open */
        "all" => {
          println!("{:?}", self.list);
        },
        "open" => {
          let newlist: Vec<Todo> = self.list.clone().into_iter()
                .filter(|t|{t.is_open()}).collect();
          println!("{:?}", newlist);
        },
        "overdue" => {
          let newlist: Vec<Todo> = self.list.clone().into_iter()
                .filter(|t|{t.is_overdue()}).collect();
          println!("{:?}", newlist);
        },
        _ => {
          println!("not supported")
        }
      }
    }

    pub fn complete(&self, name: &str) {
      let newlist = self.change_item(name, "complete").unwrap();
      println!("updated list is now {:#?}", newlist);
      // TODO (1) recover gracefully from error condition
      // TODO (2) save it out
    }

    pub fn postpone(&self, name: &str) {
      let newlist = self.change_item(name, "postpone").unwrap();
      println!("updated list is now {:?}", newlist)

      // TODO save it out
    }


    fn change_item(&self, name: &str, change_type: &str) -> Result<Vec<Todo>, Box<dyn Error>> {
      // note that we borrow the iterated-through item as mutable to allow changes
      let mut found = false;
      let changed_list: Vec<Todo> = self.list.clone()
            .into_iter().map(|mut t| {
          if t.get_name() == name {
            found = true;
            match change_type {
              "complete" => t.complete(),
              "postpone" => t.postpone(1),
              _ => println!("not supported")
            }
          }
          t
        }
      ).collect();
      if found {
        Ok(changed_list)
      } else {
        Err(Box::<dyn Error>::from("item not found"))
      }
    }
  }
}

