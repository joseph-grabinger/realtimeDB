package server

import (
	"encoding/json"
	"net/http"
	"strings"

	"realtime_database/database"
	"realtime_database/websockets"

	"github.com/gin-gonic/gin"
)

type Database interface {
	TranslateError(err error) *database.TranslatedError

	GetAllProjects() ([]byte, error)

	CreateProject(projectName string, data []byte) error
	UpdateProject(projectName string, newName string) error
	DeleteProject(projectName string) error

	GetProjectKey(projectName string, keys ...string) ([]byte, error)
	CreateProjectKey(projectName string, data []byte, keys ...string) error
	UpdateProjectKey(projectName string, data []byte, keys ...string) error
	DeleteProjectKey(projectName string, keys ...string) error
}

// Dispatcher provides an interface to dispatch events to clients connect over websockets
type Dispatcher interface {
	Broadcast() chan *websockets.Message
}

// Action is the payload dispatched to any clients connected over websocket
type Action struct {
	Type    string      `json:"type"`
	Project string      `json:"project"`
	Path    string      `json:"path"`
	Data    interface{} `json:"data"`
}

// Handlers contains all handler functions
type Handlers struct {
	db         Database
	dispatcher Dispatcher
}

func NewHandlers(datastore Database, dispatcher Dispatcher) *Handlers {
	return &Handlers{
		db:         datastore,
		dispatcher: dispatcher,
	}
}

func (h *Handlers) GetAllProjects(c *gin.Context) {
	byt, err := h.db.GetAllProjects()
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	var obj interface{}
	json.Unmarshal(byt, &obj)
	c.IndentedJSON(http.StatusOK, obj)
}

func (h *Handlers) CreateProject(c *gin.Context) {
	project := c.Param("project")
	b, _ := c.GetRawData()

	err := h.db.CreateProject(project, b)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	c.JSON(http.StatusCreated, gin.H{})
}

func (h *Handlers) UpdateProject(c *gin.Context) {
	project := c.Param("project")
	b, _ := c.GetRawData()

	err := h.db.UpdateProject(project, string(b))
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	c.JSON(http.StatusCreated, gin.H{})
}

func (h *Handlers) ReadProject(c *gin.Context) {
	project := c.Param("project")

	byt, err := h.db.GetProjectKey(project)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	var obj interface{}
	json.Unmarshal(byt, &obj)
	c.IndentedJSON(http.StatusOK, obj)
}

func (h *Handlers) DeleteProject(c *gin.Context) {
	project := c.Param("project")

	err := h.db.DeleteProject(project)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	c.JSON(http.StatusNoContent, gin.H{})
}

func (h *Handlers) ReadProjectKey(c *gin.Context) {
	project := c.Param("project")
	keys := c.Param("keys")

	keys = strings.TrimRight(strings.TrimLeft(keys, "/"), "/")
	byt, err := h.db.GetProjectKey(project, strings.Split(keys, "/")...)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	var obj interface{}
	json.Unmarshal(byt, &obj)
	c.IndentedJSON(http.StatusOK, obj)
}

func (h *Handlers) CreateProjectKey(c *gin.Context) {
	project := c.Param("project")
	keys := c.Param("keys")

	b, _ := c.GetRawData()

	keys = strings.TrimRight(strings.TrimLeft(keys, "/"), "/")
	if keys == "" {
		c.JSON(http.StatusBadRequest, "no keys provided")
		return
	}

	err := h.db.CreateProjectKey(project, b, strings.Split(keys, "/")...)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	// dispatch action
	h.broadcast("POST", keys, project, b)

	c.JSON(http.StatusCreated, gin.H{})
}

func (h *Handlers) UpdateProjectKey(c *gin.Context) {
	project := c.Param("project")
	keys := c.Param("keys")

	b, _ := c.GetRawData()

	keys = strings.TrimRight(strings.TrimLeft(keys, "/"), "/")
	if keys == "" {
		c.JSON(http.StatusBadRequest, "no keys provided")
		return
	}

	err := h.db.UpdateProjectKey(project, b, strings.Split(keys, "/")...)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	// dispatch action
	h.broadcast("PUT", keys, project, b)

	c.JSON(http.StatusCreated, gin.H{})
}

func (h *Handlers) DeleteProjectKey(c *gin.Context) {
	project := c.Param("project")
	keys := c.Param("keys")
	keys = strings.TrimRight(strings.TrimLeft(keys, "/"), "/")
	if keys == "" {
		c.JSON(http.StatusBadRequest, "no keys provided")
		return
	}

	err := h.db.DeleteProjectKey(project, strings.Split(keys, "/")...)
	if err != nil {
		tErr := h.db.TranslateError(err)
		c.JSON(tErr.Code, tErr.Error())
		return
	}

	// dispatch action
	h.broadcast("DELETE", keys, project, nil)

	c.JSON(http.StatusCreated, gin.H{})
}

func (h *Handlers) broadcast(typ, path, project string, b []byte) {
	//dispatch action
	var rawData interface{}
	json.Unmarshal(b, &rawData)
	action := Action{
		Type:    typ,
		Path:    path,
		Project: project,
		Data:    rawData,
	}
	h.dispatcher.Broadcast() <- &websockets.Message{Channel: project, Data: action}
}
