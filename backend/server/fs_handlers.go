package server

import (
	"encoding/json"
	"mime/multipart"
	"net/http"
	"net/url"
	"realtime_database/filestorage"
	"strings"

	"github.com/gin-gonic/gin"
)

type FileStorage interface {
	Add(path string, file *multipart.FileHeader) (string, error)
	AddFolder(path, name string) error
	Rename(filepath, newName string) error
	Move(filename, source, destination string) error
	Copy(source, destination string) error
	Delete(filepath string) error
	GetFile(filepath string) (string, error)
	GetStructure(path string) (*filestorage.Folder, error)
}

// FsHandlers contains all handler functions
type FsHandlers struct {
	storage FileStorage
}

func NewFsHandlers(storage FileStorage) *FsHandlers {
	return &FsHandlers{
		storage: storage,
	}
}

func (h *FsHandlers) Add(c *gin.Context) {
	path := c.PostForm("path")
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, err.Error())
		return
	}

	savePath, err := h.storage.Add(path, file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	err = c.SaveUploadedFile(file, savePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusCreated, "File added successfully")
}

func (h *FsHandlers) AddFolder(c *gin.Context) {
	path := c.PostForm("path")
	name := c.PostForm("name")

	if err := h.storage.AddFolder(path, name); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusCreated, "Folder added successfully")
}

func (h *FsHandlers) Rename(c *gin.Context) {
	filepath := c.PostForm("filepath")
	newName := c.PostForm("new_name")

	if err := h.storage.Rename(filepath, newName); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, "File renamed successfully")
}

func (h *FsHandlers) Move(c *gin.Context) {
	filename := c.PostForm("filename")
	source := c.PostForm("source")
	destination := c.PostForm("destination")

	if err := h.storage.Move(filename, source, destination); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, "File moved successfully")
}

func (h *FsHandlers) Copy(c *gin.Context) {
	source := c.PostForm("source")
	destination := c.PostForm("destination")

	if err := h.storage.Copy(source, destination); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, "File copied successfully")
}

func (h *FsHandlers) Delete(c *gin.Context) {
	filepath := c.PostForm("filepath")

	if err := h.storage.Delete(filepath); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, "File deleted successfully")
}

func (h *FsHandlers) GetFile(c *gin.Context) {
	filePath := c.Request.URL.Query().Get("filepath")

	path, err := h.storage.GetFile(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	c.File(path)
}

func (h *FsHandlers) GetStructure(c *gin.Context) {
	path := strings.SplitAfter(c.Request.URL.RawQuery, "=")[1]
	if path == "" {
		c.JSON(400, gin.H{"error": "bad_request"})
		return
	}

	encodedPath, err := url.PathUnescape(path)
	if err != nil {
		c.JSON(400, gin.H{"error": "bad_request"})
		return
	}

	tree, err := h.storage.GetStructure(encodedPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	var obj interface{}
	if err := json.Unmarshal(tree.Bytes(), &obj); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}
}
