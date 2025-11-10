package main

import "fmt"

// print user info
func printUserInfo(userMap map[string]string) {
	for k, v := range userMap {
		fmt.Println(k, " -> ", v)
	}

}

func main() {
	userMap := map[string]string{
		"uid":        "fred",
		"custnum":    "2223345",
		"department": "biology",
	}
	printUserInfo(userMap)
	fmt.Println(len(userMap))
}
