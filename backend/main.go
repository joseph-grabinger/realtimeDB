package main

import (
	"log"
	"os"

	"realtime_database/database"
	"realtime_database/server"
	"realtime_database/websockets"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	dbUser := os.Getenv("DB_USER")
	dbPwd := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbName := os.Getenv("DB_NAME")

	db, err := database.NewPostgres(
		dbUser,
		dbPwd,
		dbHost,
		dbName,
	)
	if err != nil {
		log.Fatalln(err)
	}

	dispatcher := websockets.NewDispatcher()
	go dispatcher.Run()

	httpHandler := server.NewHandlers(db, dispatcher)

	wsHandler := websockets.NewHandlers(dispatcher)

	router := gin.Default()

	server.SetRoutes(router, httpHandler)

	websockets.SetRoutes(router, wsHandler)

	router.Run(":5001")
}
