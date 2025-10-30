package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	// Get port from environment or use default
	port := os.Getenv("WEB_PORT")
	if port == "" {
		port = "8080"
	}

	// Serve static files from web directory
	fs := http.FileServer(http.Dir("./web"))
	http.Handle("/", fs)

	log.Printf("🌐 Web Server starting on http://localhost:%s", port)
	log.Printf("📂 Serving files from ./web directory")
	log.Printf("🚀 Access the interface at: http://localhost:%s", port)
	
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}
