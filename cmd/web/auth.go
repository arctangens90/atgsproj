package main

import (
	"TurkeyGo/cmd/log"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"
)

//получение всех данных по сесии (юзер/роли)
func GetUserData(UserLogin string, RoleIndex string, db *sql.DB) (UserData UserFullData) {
	var x []byte
	row := db.QueryRow("select * from admin.get_json_fulldata($1, $2::integer)", UserLogin, RoleIndex)
	err := row.Scan(&x)
	if err != nil {
		log.ErrLog.Printf("Error in loading data of user %s", UserLogin)
	}
	err = json.Unmarshal(x, &UserData)
	if err != nil {
		log.ErrLog.Printf("Error in reading data of user %s", UserLogin)
	}
	log.InfoLog.Printf("Loaded data to user %s", UserLogin)
	return
}

//установка и удаление кук из сессии
func SetSessionCookies(SessionIndex string, UserIndex string, RoleIndex string, w *http.ResponseWriter) {
	sc := new(http.Cookie)
	sc.Name = "SessionIndex"
	sc.Value = SessionIndex
	su := new(http.Cookie)
	su.Name = "UserIndex"
	su.Value = UserIndex
	sr := new(http.Cookie)
	sr.Name = "RoleIndex"
	sr.Value = RoleIndex
	http.SetCookie(*w, sc)
	http.SetCookie(*w, su)
	http.SetCookie(*w, sr)
	log.InfoLog.Printf("Cookies to session %s were written", SessionIndex)
}

func CreateSessionCookie(s *Session, w *http.ResponseWriter) {
	SetSessionCookies(strconv.Itoa(s.SessionIndex), strconv.Itoa(s.UserIndex), strconv.Itoa(s.RoleIndex), w)

}

func DeleteSessionCookies(w *http.ResponseWriter) {
	SetSessionCookies("", "", "", w)
}

//Получение дерева департаментов с учетом юзера (чтоб сортировка была красивой)
func GetDepTree(db *sql.DB, idep_index int) (tree *DepTree, err error) {
	tree = new(DepTree)
	*tree = make(DepTree)
	var idx int
	var dn, refname string
	//Читаем куроср, поэтому все через транзакции
	tx, _ := db.Begin()
	row := tx.QueryRow("select * from admin.get_department_tree($1)", idep_index)
	err = row.Scan(&refname)
	if err != nil {
		return
	}
	rows, err := tx.Query("fetch all in \"" + refname + "\"")
	if err != nil {
		return
	}
	i := 0
	for rows.Next() {
		err = rows.Scan(&idx, &dn)
		if err != nil {
			return
		}
		(*tree)[i] = DepList{dn, idx}
		i++
	}
	err = tx.Commit()
	return
}

func CloseSession(w *http.ResponseWriter, r *http.Request, db *sql.DB) error {
	sind, err := GetSessionIndex(r)
	if err != nil {
		return err
	}
	_, err = db.Exec("select admin.close_session($1)", sind)
	DeleteSessionCookies(w)
	return err
}

func Cookie2Int(r *http.Request, CookieName string) (int, error) {
	ri, err := r.Cookie(CookieName)
	if err == nil {
		res, err := strconv.Atoi(ri.Value)
		return res, err
	} else {
		return -1, err
	}
}

func GetSessionIndex(r *http.Request) (int, error) {
	return Cookie2Int(r, "SessionIndex")
}

//создание сессии
func CreateSession(UserIndex int, RoleIndex int, RemoteAddr string, db *sql.DB) (CurrentSession Session, err error) {
	var sidx int
	var err_msg sql.NullString
	row := db.QueryRow("select * from admin.create_session($1, $2, $3)", UserIndex, RoleIndex,
		(strings.Split(RemoteAddr, ":"))[0])
	err = row.Scan(&sidx, &err_msg)
	if err != nil {
		return Session{}, err
	}
	if err_msg.Valid {
		err = errors.New(err_msg.String)
	}
	CurrentSession = Session{sidx, UserIndex, RoleIndex}
	return

}
