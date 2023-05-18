module realtime_database

go 1.16

require (
	github.com/gin-gonic/contrib v0.0.0-20201101042839-6a891bf89f19
	github.com/gin-gonic/gin v1.7.4
	github.com/gorilla/websocket v1.4.2 // indirect
	github.com/joho/godotenv v1.5.1 // indirect
	github.com/lib/pq v1.10.3
)

replace realtime_database/database => ../database
