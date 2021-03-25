package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"log"
	"mock-backend/types"
	"net/http"
	"os"
)

type server struct {
}

func (s *server) handleTurnOn(w http.ResponseWriter, r *http.Request) {
	auth := r.Header.Get("Authorization")
	if len(auth) < 4 || auth[:4] != "Bear" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Println("Turn on ok.")
}

func (s *server) handleTurnOff(w http.ResponseWriter, r *http.Request) {
	auth := r.Header.Get("Authorization")
	if len(auth) < 4 || auth[:4] != "Bear" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Println("Turn off ok.")
}

// 返回生成的随机state数据
func (s *server) fetchStates(w http.ResponseWriter, r *http.Request) {
	auth := r.Header.Get("Authorization")
	if len(auth) < 4 || auth[:4] != "Bear" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	description := types.GenerateMockDeviceDescription()
	data, err := json.Marshal(description)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "error: %v", err)
		w.WriteHeader(http.StatusNoContent)
		return
	}

	_, _ = fmt.Fprintf(w, "%s", string(data))
	w.WriteHeader(http.StatusOK)
	return
}

func main() {
	r := mux.NewRouter()
	var s server
	api := r.PathPrefix("/api/services/fan").Subrouter()
	api.HandleFunc("/turn_on", s.handleTurnOn).Methods(http.MethodPost)
	api.HandleFunc("/turn_off", s.handleTurnOff).Methods(http.MethodPost)
	api.HandleFunc("/states", s.fetchStates).Methods(http.MethodPost, http.MethodGet)
	log.Printf("Starting Rest Server\n")
	log.Fatal(http.ListenAndServe(":8000", r))
}
