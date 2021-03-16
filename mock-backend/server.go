package main

import (
	"github.com/gorilla/mux"
	"log"
	"net/http"
)


type server struct {

}

func (s *server) handleTurnOn(w http.ResponseWriter, r *http.Request)  {
	auth := r.Header.Get("Authorization")
	if auth != "test auth token" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	return
}


func (s *server) handleTurnOff(w http.ResponseWriter, r *http.Request)  {
	auth := r.Header.Get("Authorization")
	if auth != "test auth token" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	return
}



func main() {
	r := mux.NewRouter()
	var s server
	api := r.PathPrefix("/api/v1/udo").Subrouter()
	api.HandleFunc("/turn-on", s.handleTurnOn).Methods(http.MethodPost)
	api.HandleFunc("/turn-off", s.handleTurnOff).Methods(http.MethodPost)
	log.Printf("Starting Rest Server\n")
	log.Fatal(http.ListenAndServe(":8000", r))
}
