package main

type ApplicationError struct {
	Message string
}

func (e *ApplicationError) Error() string {
	return e.Message
}
