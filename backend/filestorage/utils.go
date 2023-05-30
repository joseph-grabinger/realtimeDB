package filestorage

import (
	"io/ioutil"
	"log"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"strings"
)

// add ".Kopie" to lastAppendix until a free filename is found
func renameDuplicate(destination, lastAppendix string, isFile bool) string {
	i := 1
	for {
		var newName string
		if isFile {
			ext := path.Ext(lastAppendix)
			name := strings.TrimSuffix(lastAppendix, ext)
			newName = destination + name + ".Kopie" + strconv.Itoa(i) + ext
		} else {
			newName = destination + lastAppendix + ".Kopie" + strconv.Itoa(i)
		}

		log.Println("new name for duplicate: ", newName)

		if _, err := os.Stat(filepath.FromSlash(newName)); os.IsNotExist(err) {
			return newName
		}
		i++
	}
}

// copy file
func copyFile(source, destination string) error {
	input, err := ioutil.ReadFile(filepath.FromSlash(source))
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(filepath.FromSlash(destination), input, 0644)
	if err != nil {
		return err
	}

	return nil
}

// copy directory and its contents
func copyDir(source, destination string) error {
	// create destination directory
	err := os.MkdirAll(filepath.FromSlash(destination), os.ModePerm)
	if err != nil {
		return err
	}
	// copy files
	err = filepath.Walk(filepath.FromSlash(source), func(thisPath string, info os.FileInfo, err error) error {
		thisPath = strings.ReplaceAll(thisPath, "\\", "/")
		if err != nil {
			return err
		}
		if info.IsDir() {
			log.Println("p: ", thisPath)
			log.Println("info: ", info.Name())
			if thisPath == source {
				return nil
			}
			if err := copyDir(thisPath, path.Join(destination, info.Name())); err != nil {
				log.Println("Error on recursive CopyDir: ", err)
				return err
			}
			return nil
		}
		// copy file
		dest := path.Join(destination, path.Base(thisPath))
		return copyFile(thisPath, dest)
	})
	if err != nil {
		return err
	}
	return nil
}

func walk(dirPath string) (*Folder, error) {
	var tree *Folder
	var nodes = map[string]interface{}{}
	var walkFun filepath.WalkFunc = func(p string, info os.FileInfo, err error) error {
		p = strings.ReplaceAll(p, "\\", "/")
		log.Println("p: ", p)
		if info.IsDir() {
			log.Println("folder: ", path.Base(p))
			nodes[p] = &Folder{path.Base(p), []*File{}, map[string]*Folder{}, info.ModTime()}
		} else {
			if info.Name()[0] != '.' {
				log.Println("stats with.: ", info.Name())
				nodes[p] = &File{path.Base(p), info.ModTime()}
			}
			log.Println("Nothing ", info.Name())
		}
		log.Println("return err: ", err)
		return err
	}

	if err := filepath.Walk(filepath.FromSlash(dirPath), walkFun); err != nil {
		log.Println("walk error: ", err)
		return nil, err
	}
	log.Println("Nodes:", nodes)

	for key, value := range nodes {
		var parentFolder *Folder
		if key == dirPath {
			tree = value.(*Folder)
			continue
		} else {
			log.Println(key)
			optParentFolder := nodes[path.Dir(key)]
			if optParentFolder != nil {
				parentFolder = optParentFolder.(*Folder)
			}
		}

		if parentFolder == nil {
			continue
		}
		switch v := value.(type) {
		case *File:
			parentFolder.Files = append(parentFolder.Files, v)
		case *Folder:
			parentFolder.Folders[v.Name] = v
		}
	}

	return tree, nil
}

// Checks if the provided dirPath exists. If it doesn't, it is created.
func checkAndCreateDir(dirpath string) error {
	if _, err := os.Stat(filepath.FromSlash(dirpath)); os.IsNotExist(err) {
		log.Println("Had to create Dir: ", dirpath)
		os.MkdirAll(filepath.FromSlash(dirpath), os.ModePerm)
		return nil
	} else {
		return err
	}
}
