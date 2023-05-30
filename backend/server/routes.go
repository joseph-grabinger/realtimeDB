package server

import (
	"github.com/gin-gonic/gin"
)

// RdbHandler is an interface to the realtimeDB HTTP handler functions.
type RdbHandler interface {
	GetAllProjects(c *gin.Context)
	CreateProject(c *gin.Context)
	UpdateProject(c *gin.Context)
	ReadProject(c *gin.Context)
	DeleteProject(c *gin.Context)
	ReadProjectKey(c *gin.Context)
	CreateProjectKey(c *gin.Context)
	UpdateProjectKey(c *gin.Context)
	DeleteProjectKey(c *gin.Context)
}

// FsHandler is an interface to the filestorage HTTP handler functions.
type FsHandler interface {
	Add(c *gin.Context)
	AddFolder(c *gin.Context)
	Rename(c *gin.Context)
	Move(c *gin.Context)
	Copy(c *gin.Context)
	Delete(c *gin.Context)
	GetFile(c *gin.Context)
	GetStructure(c *gin.Context)
}

func SetRoutes(engine *gin.Engine, rdbH RdbHandler, fsH FsHandler) {
	api := engine.Group("/api")

	api.GET("/", rdbH.GetAllProjects)

	api.GET("/:project", rdbH.ReadProject)
	api.POST("/:project", rdbH.CreateProject)
	api.PUT("/:project", rdbH.UpdateProject)
	api.DELETE("/:project", rdbH.DeleteProject)

	api.GET("/:project/*keys", rdbH.ReadProjectKey)
	api.POST("/:project/*keys", rdbH.CreateProjectKey)
	api.PUT("/:project/*keys", rdbH.UpdateProjectKey)
	api.DELETE("/:project/*keys", rdbH.DeleteProjectKey)

	fs := api.Group("/filestorage")

	fs.POST("/add", fsH.Add)
	fs.POST("/add_folder", fsH.AddFolder)
	fs.PUT("/rename", fsH.Rename)
	fs.PUT("/move", fsH.Move)
	fs.PUT("/copy", fsH.Copy)
	fs.DELETE("/delete", fsH.Delete)
	fs.GET("/get_file/*filepath", fsH.GetFile)
	fs.GET("/get_structure/*path", fsH.GetStructure)
}
