package filestorage

import (
	"log"
	"mime/multipart"
	"os"
	"path"
	"path/filepath"
	"strings"
)

type FileStorage struct {
	storagePath string
}

func NewFileStorage(path string) (*FileStorage, error) {
	return &FileStorage{
		storagePath: path,
	}, nil
}

func (fs *FileStorage) GetAllProjects() ([]byte, error) {
	// TODO: implement
	return nil, nil
}

func (fs *FileStorage) CreateProject(projectName string) error {
	// TODO: implement
	return nil
}

func (fs *FileStorage) UpdateProject(projectName string, newName string) error {
	// TODO: implement
	return nil
}

func (fs *FileStorage) DeleteProject(projectName string) error {
	// TODO: implement
	return nil
}

func (fs *FileStorage) Add(addPath string, file *multipart.FileHeader) (string, error) {
	storagePath := path.Join(fs.storagePath, addPath)

	// check if path doesn´t exists and create directory
	if _, err := os.Stat(filepath.FromSlash(storagePath)); os.IsNotExist(err) {
		if err := os.MkdirAll(filepath.FromSlash(storagePath), os.ModePerm); err != nil {
			log.Println("Error on create directory:", err)
			return "", err
		}
	}

	filename := file.Filename

	// check if filename contians illegal charters
	if strings.Contains(filename, "/") {
		filename = strings.ReplaceAll(filename, "/", "_")
	}
	if strings.Contains(filename, "\\") {
		filename = strings.ReplaceAll(filename, "\\", "_")
	}
	if strings.Contains(filename, "+") {
		filename = strings.ReplaceAll(filename, "+", "_")
	}

	return filename, nil
}

func (fs *FileStorage) AddFolder(addPath, name string) error {
	path := path.Join(fs.storagePath, addPath)

	// check if path exists
	if _, err := os.Stat(filepath.FromSlash(path)); os.IsNotExist(err) {
		log.Println("path doesnt exist")
		return err
	}

	// create directory
	if err := os.Mkdir(filepath.Join(path, name), os.ModePerm); err != nil {
		log.Println("Error on make Dir: ", err)
		return err
	}

	return nil
}

func (fs *FileStorage) Rename(filePath, newName string) error {
	filePath = path.Join(fs.storagePath, filePath)

	// check if file exists
	if _, err := os.Stat(filepath.FromSlash(filePath)); os.IsNotExist(err) {
		return err
	}

	var newPath string

	// check if file is a directory
	if info, err := os.Stat(filepath.FromSlash(filePath)); err == nil {
		last := path.Base(filePath)
		if info.IsDir() {
			newPath = strings.TrimSuffix(filePath, last+"/")
		} else {
			newPath = strings.TrimSuffix(filePath, last)
		}
		newPath = path.Join(newPath, newName)
	} else {
		log.Println("Error on get file info:", err)
		return err
	}

	// rename file
	if err := os.Rename(filepath.FromSlash(filePath), filepath.FromSlash(newPath)); err != nil {
		log.Println("Error on Rename:", err)
		return err
	}

	return nil
}

func (fs *FileStorage) Move(filename, source, destination string) error {
	src := path.Join(fs.storagePath, source)
	dst := path.Join(fs.storagePath, destination)

	// check if destination path doesn´t exists and create directory
	if _, err := os.Stat(filepath.FromSlash(dst)); os.IsNotExist(err) {
		log.Println("Path non existent... had to create")
		if err := os.MkdirAll(filepath.FromSlash(dst), os.ModePerm); err != nil {
			log.Println("Error on create directory:", err)
			return err
		}
	}

	src = path.Join(src, filename)
	dst = path.Join(dst, filename)

	if err := os.Rename(filepath.FromSlash(src), filepath.FromSlash(dst)); err != nil {
		log.Println("Error on move file:", err)
		return err
	}

	return nil
}

func (fs *FileStorage) Copy(source, destination string) error {
	src := path.Join(fs.storagePath, source)
	dst := path.Join(fs.storagePath, destination)

	// check if source path exists
	if _, err := os.Stat(filepath.FromSlash(src)); os.IsNotExist(err) {
		return err
	}
	// check if source path is a file or directory
	info, err := os.Stat(filepath.FromSlash(src))
	if err != nil {
		return err
	}

	last := path.Base(src)

	if info.IsDir() {
		// check if destination path already exists
		if _, err := os.Stat(filepath.FromSlash(path.Join(dst, last))); !os.IsNotExist(err) {
			dst = renameDuplicate(dst, last, false)
		} else {
			dst = path.Join(dst, last)
		}

		// copy directory and its contents
		if err := copyDir(src, dst); err != nil {
			return err
		}
	} else {
		// check if destination path already exists
		if _, err := os.Stat(filepath.FromSlash(path.Join(dst, last))); !os.IsNotExist(err) {
			dst = renameDuplicate(dst, last, true)
		} else {
			if err := checkAndCreateDir(dst); err != nil {
				log.Println("error creating directory: ", err)
			}

			dst = path.Join(dst, last)
		}

		// copy file
		if err := copyFile(src, dst); err != nil {
			return err
		}
	}

	return nil
}

func (fs *FileStorage) Delete(filePath string) error {
	storagePath := path.Join(fs.storagePath, filePath)

	// check if file exists
	if _, err := os.Stat(filepath.FromSlash(storagePath)); os.IsNotExist(err) {
		return err
	}

	// delete file or directory
	if err := os.RemoveAll(filepath.FromSlash(storagePath)); err != nil {
		log.Println("Server Error on RemoveAll: ", err.Error())
		return err
	}

	return nil
}

func (fs *FileStorage) GetFile(filePath string) (string, error) {
	storagePath := filepath.FromSlash(path.Join(fs.storagePath, filePath))

	// check if file exists
	if _, err := os.Stat(storagePath); os.IsNotExist(err) {
		return "", err
	}

	return storagePath, nil
}

func (fs *FileStorage) GetStructure(dirPath string) (*Folder, error) {

	dirPath = path.Clean(path.Join(fs.storagePath, dirPath))

	// check if path exists
	if _, err := os.Stat(filepath.FromSlash(dirPath)); os.IsNotExist(err) {
		return &Folder{}, err
	}

	var tree *Folder

	tree, err := walk(dirPath)
	if err != nil {
		log.Println("Error on walk:", err)
		return &Folder{}, err
	}

	return tree, nil
}
