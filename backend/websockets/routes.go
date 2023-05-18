package websockets

import (
	"github.com/gin-gonic/gin"
)

// Handler is an interface to the HTTP handler functions.
type Handler interface {
	WebsocketHandler(c *gin.Context)
}

// SetRoutes sets all of the appropriate routes to websocket handlers for the application
func SetRoutes(engine *gin.Engine, h Handler) error {
	ws := engine.Group("/ws")
	ws.GET("/:channel", h.WebsocketHandler)

	return nil
}
