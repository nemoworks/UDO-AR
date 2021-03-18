package main

import (
	"github.com/gorilla/mux"
	"log"
	"net/http"
	"fmt"
)


type server struct {

}

func (s *server) handleTurnOn(w http.ResponseWriter, r *http.Request)  {
	auth := r.Header.Get("Authorization")
	if auth[:4] != "Bear" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Println("Turn on ok.")
}


func (s *server) handleTurnOff(w http.ResponseWriter, r *http.Request)  {
	auth := r.Header.Get("Authorization")
	if auth[:4] != "Bear" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Println("Turn off ok.")
}



func main() {
	r := mux.NewRouter()
	var s server
	api := r.PathPrefix("/api/services/fan").Subrouter()
	api.HandleFunc("/turn_on", s.handleTurnOn).Methods(http.MethodPost)
	api.HandleFunc("/turn_off", s.handleTurnOff).Methods(http.MethodPost)
	log.Printf("Starting Rest Server\n")
	log.Fatal(http.ListenAndServe(":8000", r))
}
