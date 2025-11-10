package main

// you can use an alias, like here i use 'f'
import f "fmt"

func sum(nums ...int) {
	// some practice with fmt...
	logLine := f.Sprintf("Number of args = %d! they are ", len(nums))
	f.Print(logLine)
	f.Print(nums, " ")
	total := 0

	for _, num := range nums {
		total += num
	}
	f.Println(total)
}

func stuff() {
	var foo string
	f.Print("Today in one word: ")
	f.Scan(&foo)
	f.Printf("OK, mood - %v", foo)
}

func main() {
	sum(1, 2)
	sum(1, 2, 3)

	nums := []int{1, 2, 3, 4}
	sum(nums...)

	stuff()
}
