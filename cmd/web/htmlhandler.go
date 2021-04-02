package main

import (
	"TurkeyGo/cmd/log"
	"database/sql"
	"html/template"
	"net/http"
)

type HtmlObjects struct {
	CommonObjects   interface{}  //набор индивидуальных данных для страницы
	SessionData     *SessionData //данные сессии
	AcceptedObjects AccessMap    //матрица прав для страницы
	PageMeta        PageMeta     //мета-данные для страницы
}

type PageMeta struct {
	PageName      string
	PageHttp      string
	PageDescribe  string
	PageLogoClass string
}

func (h *HtmlObjects) HasPermission(s string) bool {
	return (h.AcceptedObjects)[s] || (h.SessionData.BasicAcceptedObjects)[s]
}

type HtmlHandler struct {
	DenyHandler    func(w http.ResponseWriter, r *http.Request) //обработчик для отказа
	SourceHtml     string                                       //название страницы в бд
	PathSourceHtml []string                                     //полный путь к страницам
	HtmlData       HtmlObjects                                  //структура для заполнения
	Db             *sql.DB                                      //подключение к бд
}

func (h HtmlHandler) HtmlHandle(w http.ResponseWriter, r *http.Request) {
	var IsAccepted bool
	//смотрим на доступ
	row := h.Db.QueryRow("select * from admin.get_resource_access($1, $2)",
		h.HtmlData.SessionData.UserData.Role.RoleIndex, h.SourceHtml)
	err := row.Scan(&IsAccepted)
	if err != nil {
		log.ErrLog.Printf("Can not load permission to %s. Details: ", h.SourceHtml, err)
		http.NotFoundHandler()
	}
	if IsAccepted {
		log.InfoLog.Printf("Access to user %s to %s", h.HtmlData.SessionData.UserData.User.Login, h.SourceHtml)
		h.AccessHandler(w, r) //если достп есть
	} else {
		log.InfoLog.Printf("Reject to user %s to %s", h.HtmlData.SessionData.UserData.User.Login, h.SourceHtml)
		h.DenyHandler(w, r) //если нет
	}

}

//если доступ к странице есть, то
func (h HtmlHandler) AccessHandler(w http.ResponseWriter, r *http.Request) {
	err := Write2AccesMap(&h.HtmlData.AcceptedObjects, h.Db,
		" select * from admin.get_resource_access_childlist($1,$2)",
		h.HtmlData.SessionData.UserData.Role.RoleIndex, h.SourceHtml)
	if err != nil {
		log.ErrLog.Printf("Bad acces map to %s on %s",
			h.HtmlData.SessionData.UserData.User.Login, h.SourceHtml)
	}
	//запоелняем шаблон
	tmpl, err := template.ParseFiles(h.PathSourceHtml...)
	if err != nil {
		log.ErrLog.Printf("Can not load files from server. Details: %s", err)
	}
	err = tmpl.Execute(w, h.HtmlData)
	if err != nil {
		log.ErrLog.Printf("Error in generate %s. Details: %s", h.SourceHtml, err)
	}

}
