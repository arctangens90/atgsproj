package main

import (
	"TurkeyGo/cmd/log"
	"database/sql"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
)

//Post-запросы, т.е. изменение БД
//Если подправить базу их можно неплохо унифицировать, потому что много дублекода

//Редактирвоание пользователя

func EditAcceptHandler(w http.ResponseWriter, r *http.Request, db *sql.DB, sData *SessionData) {

	var err_msg sql.NullString
	var editedUser User
	var UserIdx int
	if r.Method == "POST" {
		//считываем json который нам пришел
		js, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.ErrLog.Printf("Bad request: %s", err)
			err_msg.String = err.Error()
			return
		}
		err = json.Unmarshal(js, &editedUser)
		if err != nil {
			log.ErrLog.Printf("Bad data: %s", err)
			err_msg.String = err.Error()
			return
		}
		//Если мы зашли как админ и редактируем как админ, а не в ЛК, то индекс надо брать из json-а, иначе--из
		//данных сессии
		if r.URL.Query().Get("IsAdmin") == "true" {
			UserIdx = editedUser.UserIndex
		} else {
			UserIdx = sData.UserData.User.UserIndex
		}
		row := db.QueryRow("select * from admin.change_user_properties($1, $2, $3)",
			UserIdx, js, sData.UserData.User.Login)
		err = row.Scan(&err_msg)
		if err != nil {
			log.ErrLog.Printf("Can not modify user: %s", err)
			err_msg.String = err.Error()
			return
		}
		//если мы редактировали себя, надо бы обновиться
		if UserIdx == sData.UserData.User.UserIndex {
			sData.UserData = GetUserData(sData.UserData.User.Login,
				strconv.Itoa(sData.UserData.Role.RoleIndex), db)

		}
	}
	defer w.Write([]byte("{\"err_message\":\"" + err_msg.String + "\"}"))
	defer w.Header().Set("Content-type", "application/json")
}

//Создание юзера
func CreateAcceptHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var err_msg string
	if r.Method == "POST" {
		var NewUserData CreateUser
		var idx int
		//Этим трюком убиваем пустые поля
		js, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.ErrLog.Println("Error in creation user: can't load data from server!")
			err_msg = err.Error()
			return
		}
		json.Unmarshal(js, &NewUserData)
		js, _ = json.Marshal(NewUserData)
		row := db.QueryRow("select * from admin.register_user($1)", js)
		row.Scan(&idx, &err_msg)
		if err != nil {
			log.ErrLog.Println("Error in creation user: can't save data in database!")
			err_msg += " " + err.Error()
			return
		}
	}

	defer w.Write([]byte("{\"err_message\":\"" + err_msg + "\"}"))
	defer w.Header().Set("Content-type", "application/json")
}

//Изменение ролей
func UpdateUserRolesHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var insrows, delrows int
	if r.Method == "POST" {
		js, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.ErrLog.Println("Error in update rolemap: can't load data from server!")
			return
		}
		row := db.QueryRow("select * from admin.upd_userrole_json($1)", js)
		err = row.Scan(&insrows, &delrows)
		if err != nil {
			log.ErrLog.Println("Error in saving data: ", err)
			return
		}
	}
	defer w.Write([]byte("{\"insrows\":" + strconv.Itoa(insrows) + ", \"delrows\":" + strconv.Itoa(delrows) + "}"))
	defer w.Header().Set("Content-type", "application/json")

}

func DeleteUserHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var delrows int
	if r.Method == "POST" {
		js, _ := ioutil.ReadAll(r.Body)
		row := db.QueryRow("select * from admin.upd_userrole_json($1)", js)
		row.Scan(&delrows)
	}
	w.Header().Set("Content-type", "application/json")
	w.Write([]byte("{\"delrows\":" + strconv.Itoa(delrows) + "}"))
}

//Сохранение Json в БД. в перспективе все что можно, хочется приводить к этой функции
func SaveJson2DbHandler(w http.ResponseWriter, r *http.Request, db *sql.DB, query string) {
	var err_msg sql.NullString
	if r.Method == "POST" {
		js, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.ErrLog.Printf("Bad request: %s", err)
		}
		row := db.QueryRow(query, js)
		err = row.Scan(&err_msg)
		if err != nil {
			err_msg.String += " " + err.Error()
			log.ErrLog.Printf("Unable to get query %s", err)
			return
		}
		//if !err_msg.Valid{err_msg.String=""}
		defer w.Write([]byte("{\"err_message\":\"" + strings.Replace(err_msg.String, "\"", "\\\"", -1) + "\"}"))
		defer w.Header().Set("Content-type", "application/json")
	}

}

func ChangePasswordByUserHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	SaveJson2DbHandler(w, r, db, "select * from admin.change_password_by_user_json($1)")
}

func SaveInputForm2Table(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	SaveJson2DbHandler(w, r, db, "select * from test_save($1)")
}

func SaveDayInputForm2Table(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	SaveJson2DbHandler(w, r, db, "select * from test_save_day($1)")
}
