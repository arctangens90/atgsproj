package main

import (
	"TurkeyGoNewDesign/cmd/log"
	"database/sql"
	"errors"
	"net/http"
)

//карта вида объект--доступ. Можно обойтись слайсом, но там могут быть дубли
type AccessMap map[string]bool

//интерфейс, есть ли доступ к какой-то строке

type HtmlPermission interface {
	HasPermission(s string) bool
}

func (am AccessMap) HasPermission(s string) bool {
	return am[s]
}

//Очистка прав доступа
func (am AccessMap) Truncate() {
	for k := range am {
		delete(am, k)
	}
}

//Данные пользователя в сессии и набор его прав
type SessionData struct {
	UserData             UserFullData
	BasicAcceptedObjects AccessMap
}

//Прокидываем интерфейс
func (sd SessionData) HasPermission(s string) bool {
	return sd.BasicAcceptedObjects[s]
}

type RouteData struct {
	SessionData
	DBPool map[string]*sql.DB
}

//Защищенный обработчик файлов
type NeuteredFileSystem struct {
	Fs    http.FileSystem
	SData SessionData
	Db    *sql.DB
}

func (nfs NeuteredFileSystem) Open(path string) (http.File, error) {
	f, err := nfs.Fs.Open(path)
	if err != nil {
		log.ErrLog.Printf("Error opening file: %s", err)
		return nil, err
	}
	s, _ := f.Stat()
	if s.IsDir() {
		var iflag bool
		//Это заглушка, а так ищем значения в базе (меняем index.html на имя папки). Или вообще убить папку
		rows := nfs.Db.QueryRow("select * from admin.get_resource_access($1, $2)",
			nfs.SData.UserData.Role.RoleIndex, "index.html")
		rows.Scan(&iflag)
		if iflag {
			if err != nil {
				return nil, err
			}
			log.ErrLog.Printf("Error opening file: %s", err)
			return f, err
		}
		err := errors.New("Acces Denied")
		return nil, err
	}
	//Пока настроено все файлы разрешить, а то отлаживать замучаться можно..
	return f, err

}

func Write2AccesMap(am *AccessMap, db *sql.DB, sql_query string, queryargs ...interface{}) (err error) {
	var refname string
	var resname string
	tx, _ := db.Begin()
	row := tx.QueryRow(sql_query, queryargs...)
	err = row.Scan(&refname)
	if err != nil {
		return err
	}
	rows, _ := tx.Query("fetch all in \"" + refname + "\"")
	for rows.Next() {
		err = rows.Scan(&resname)
		if err != nil {
			return err
		}
		(*am)[resname] = true
	}
	tx.Commit()
	return nil
}

//Записываем "базовые" права, т.е. на корневые объекты (html, оюъекты главного меню...)
func GetBasicAccesMap(am *AccessMap, db *sql.DB, RoleIndex int) error {
	return Write2AccesMap(am, db, "select * from admin.get_basic_resources($1)", RoleIndex)
}
