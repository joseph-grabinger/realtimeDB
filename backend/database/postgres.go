package database

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"strings"

	"github.com/lib/pq"
)

type Postgres struct {
	db *sql.DB
}

func NewPostgres(user, password, host, database string) (*Postgres, error) {
	connStr := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", user, password, host, database)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	return &Postgres{
		db: db,
	}, nil
}

func (p *Postgres) TranslateError(err error) *TranslatedError {
	originalError := err.Error()

	if err, ok := err.(*pq.Error); ok {
		//postgres specific errors
		switch err.Code {
		case "2305":
			return NewTranslatedError(http.StatusBadRequest, errors.New("key already exists"))
		case "22023":
			return NewTranslatedError(http.StatusBadRequest, errors.New("key already exists"))
		default:
			fmt.Println(err)
			fmt.Println(err.Code)
			return NewTranslatedError(http.StatusInternalServerError, errors.New(strings.TrimPrefix(err.Error(), "pq: ")))
		}
	} else {
		// generic sql package errors
		switch originalError {
		case sql.ErrConnDone.Error():
			return NewTranslatedError(http.StatusInternalServerError, errors.New("internal server error"))
		case sql.ErrNoRows.Error():
			return NewTranslatedError(http.StatusNotFound, errors.New("not found"))
		case sql.ErrTxDone.Error():
			return NewTranslatedError(http.StatusInternalServerError, errors.New("internal server error"))
		}
	}

	fmt.Println(err)
	return NewTranslatedError(http.StatusInternalServerError, errors.New("internal server error"))
}

func (p *Postgres) GetAllProjects() ([]byte, error) {
	byt := []byte{}
	err := p.db.QueryRow("SELECT json_build_array(project) FROM trees").Scan(&byt)
	return byt, err
}

func (p *Postgres) CreateProject(projectName string, data []byte) error {
	_, err := p.db.Exec("INSERT INTO trees (project, data) VALUES ($1, $2)", projectName, data)
	return err
}

func (p *Postgres) DeleteProject(projectName string) error {
	_, err := p.db.Exec("DELETE FROM trees where project=$1", projectName)
	return err
}

func (p *Postgres) GetProjectKey(projectName string, keys ...string) ([]byte, error) {
	byt := []byte{}

	keysFomat := strings.Join(keys, ",")
	err := p.db.QueryRow(
		fmt.Sprintf("SELECT data#>'{%s}' as data FROM trees WHERE project=$1 ORDER BY id DESC LIMIT 1", keysFomat),
		projectName).Scan(&byt)

	return byt, err
}

func (p *Postgres) CreateProjectKey(projectName string, data []byte, keys ...string) error {
	keysFormat := strings.Join(keys, ",")
	_, err := p.db.Exec(fmt.Sprintf("UPDATE trees set data=jsonb_insert(data, '{%s}', $1) WHERE project=$2", keysFormat), data, projectName)
	return err
}

func (p *Postgres) UpdateProjectKey(projectName string, data []byte, keys ...string) error {
	keysFormat := strings.Join(keys, ",")
	_, err := p.db.Exec(fmt.Sprintf("UPDATE trees set data=jsonb_set(data, '{%s}', $1) WHERE project=$2", keysFormat), data, projectName)
	return err
}

func (p *Postgres) DeleteProjectKey(projectName string, keys ...string) error {
	keysFormat := strings.Join(keys, ",")
	_, err := p.db.Exec(fmt.Sprintf("UPDATE trees SET data=data #- '{%s}' where project=$1", keysFormat), projectName)
	return err
}
