package filestorage

import (
	"encoding/json"
	"time"
)

type File struct {
	Name    string
	ModTime time.Time
}

type Folder struct {
	Name    string
	Files   []*File
	Folders map[string]*Folder
	ModTime time.Time
}

func (f *Folder) Bytes() []byte {
	j, _ := json.Marshal(f)
	return j
}
