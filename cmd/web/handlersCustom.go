package main

import (
	"TurkeyGo/cmd/log"
	"database/sql"
	"fmt"
	"html/template"
	"net/http"
	"strconv"
)



//обработчики для запросов
//обработчик отказа в доступе
func DenyHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "ERROR")
	http.NotFoundHandler()
}

//Страница авторизации
func IndexHandler(w http.ResponseWriter, r *http.Request, sd SessionData) {
	tmpl, _ := template.ParseFiles(append([]string{"./ui/html/index.html",
		"./ui/html/tmpl/logform.html",
		"./ui/html/tmpl/modalinfo.tmpl"},
		HeadersTmpl...)...)
	err := tmpl.Execute(w, sd)
	if err != nil {
		log.ErrLog.Printf("Error loading main page. Detail:%s", err)
	}

}

func AuthHandler(w http.ResponseWriter, r *http.Request, sd SessionData) {
	tmpl, _ := template.ParseFiles(append([]string{"./ui/html/auth.html", "./ui/html/tmpl/AuthScripts.layout.tmpl",
		"./ui/html/tmpl/logform.html",
		"./ui/html/tmpl/modalinfo.tmpl"},
		HeadersTmpl...)...)
	err := tmpl.Execute(w, sd)
	if err != nil {
		log.ErrLog.Printf("Error loading main page. Detail:%s", err)
	}

}

//Обработчик для входа в систему
func LoginHandler(w http.ResponseWriter, r *http.Request, db *sql.DB, SessionData *SessionData) {
	var IsAccess bool
	role_index, _ := strconv.Atoi(r.FormValue("Rolelist"))
	//Проверяем логин/пароль
	row := db.QueryRow("select * from admin.check_password($1,$2)", r.FormValue("Login"), r.FormValue("Password"))
	err := row.Scan(&IsAccess)
	if err != nil {
		log.ErrLog.Printf("DB Error when user %s tried to logon", r.FormValue("Login"))
	}
	if IsAccess {
		SessionData.BasicAcceptedObjects.Truncate()
		//При успешной авторизации создаем струкутру с пользовательскими данными, а так же сессию. И пишем в куку.
		err := GetBasicAccesMap(&SessionData.BasicAcceptedObjects, db, role_index)
		if err != nil {
			log.ErrLog.Printf("Error writing access map. Details %s", err)
			return
		}
		SessionData.UserData = GetUserData(r.FormValue("Login"), r.FormValue("Rolelist"), db)
		Session, err := CreateSession(SessionData.UserData.User.UserIndex, SessionData.UserData.Role.RoleIndex,
			r.RemoteAddr, db)
		CreateSessionCookie(&Session, &w)

		if err != nil {
			log.ErrLog.Printf("Error creating session. Details %s", err)
		} else {
			log.InfoLog.Printf("User %s logon", SessionData.UserData.User.Login)
		}
	} else {
		log.InfoLog.Printf("User %s login denied. Wrong password or login not exist", SessionData.UserData.User.Login)
	}
	defer http.Redirect(w, r, "/index", 302)
}

func LogoutHandler(w http.ResponseWriter, r *http.Request, s *SessionData, db *sql.DB) {
	//удаляем куки
	err := CloseSession(&w, r, db)
	if err != nil {
		log.ErrLog.Printf("Error closing session. Details: %s", err)
	} else {
		log.InfoLog.Printf("User %s logout succesfully", s.UserData.User.Login)
	}
	//чистим данные сессии
	s.UserData = UserFullData{}
	s.BasicAcceptedObjects.Truncate()
	defer IndexHandler(w, r, *s)
}
