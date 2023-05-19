package server

import (
	"github.com/gin-gonic/gin"
)

// Handler is an interface to the HTTP handler functions.
type Handler interface {
	GetAllProjects(c *gin.Context)
	CreateProject(c *gin.Context)
	ReadProject(c *gin.Context)
	DeleteProject(c *gin.Context)
	ReadProjectKey(c *gin.Context)
	CreateProjectKey(c *gin.Context)
	UpdateProjectKey(c *gin.Context)
	DeleteProjectKey(c *gin.Context)
}

func SetRoutes(engine *gin.Engine, h Handler) {
	api := engine.Group("/api")

	api.GET("/", h.GetAllProjects)

	api.GET("/:project", h.ReadProject)
	api.POST("/:project", h.CreateProject)
	api.DELETE("/:project", h.DeleteProject)

	api.GET("/:project/*keys", h.ReadProjectKey)
	api.POST("/:project/*keys", h.CreateProjectKey)
	api.PUT("/:project/*keys", h.UpdateProjectKey)
	api.DELETE("/:project/*keys", h.DeleteProjectKey)
}
