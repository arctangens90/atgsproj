package main

import (
	"TurkeyGoNewDesign/cmd/log"
	"database/sql"
	"encoding/json"
	"io/ioutil"
	"net/http"
)
var HeadersTmpl = []string{"./ui/html/tmpl/header.layout.tmpl",
	"./ui/html/tmpl/leftpanel.html", "./ui/html/tmpl/footer.html", "./ui/html/tmpl/Bootstrapscripts.tmpl",
	"./ui/html/tmpl/changepassword.tmpl", "./ui/html/tmpl//modalinfo.tmpl", "./ui/html/tmpl/basicscripts.tmpl",
	"./ui/html/tmpl/PreLoader.tmpl", "./ui/html/tmpl/toppanel.tmpl", "./ui/html/tmpl/pageheader.tmpl"}



func routes(r *RouteData) *http.ServeMux {
	mux := http.NewServeMux()
	db := r.DBPool["admin"]
	sakha_db := r.DBPool["sakha"]
	SessionData := r.SessionData


	var DefaultHtmlHandler = HtmlHandler{
		DenyHandler:    DenyHandler,
		SourceHtml:     "",
		PathSourceHtml: HeadersTmpl,
		HtmlData: HtmlObjects{
			SessionData:     &SessionData,
			AcceptedObjects: make(AccessMap),
		},
		Db: db,
	}


	fileServer := http.FileServer(NeuteredFileSystem{http.Dir("./ui/static/"), SessionData, db})
	mux.Handle("/static", http.NotFoundHandler())
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))

	//обработчики для разных http:
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { IndexHandler(w, r, SessionData) })
	mux.HandleFunc("/index", func(w http.ResponseWriter, r *http.Request) { IndexHandler(w, r, SessionData) })
	mux.HandleFunc("/auth", func(w http.ResponseWriter, r *http.Request) { AuthHandler(w, r, SessionData) })
	//Обработчики вида "Дай мне json с данными". Обычно нужны для javascript
	mux.HandleFunc("/getroles", func(w http.ResponseWriter, r *http.Request) {
		GetRolesHandler(w, r, db)
	})
	mux.HandleFunc("/getdeplist", func(w http.ResponseWriter, r *http.Request) {
		GetDepHandler(w, r, db)
	})
	mux.HandleFunc("/getuserlist", func(w http.ResponseWriter, r *http.Request) {
		GetUsersHandler(w, r, db)
	})
	mux.HandleFunc("/getallroles", func(w http.ResponseWriter, r *http.Request) {
		GetAllRolesHandler(w, r, db)
	})

	mux.HandleFunc("/getavailableroles", func(w http.ResponseWriter, r *http.Request) {
		GetNoRolesHandler(w, r, db)
	})

	mux.HandleFunc("/getrrsdata", func(w http.ResponseWriter, r *http.Request) {
		GetRRSTableHandler(w, r, sakha_db)
	})

	mux.HandleFunc("/getrodata", func(w http.ResponseWriter, r *http.Request) {
		GetRoTableHandler(w, r, sakha_db)
	})

	mux.HandleFunc("/getcrossrrsdata", func(w http.ResponseWriter, r *http.Request) {
		GetCrossRRSTableHandler(w, r, sakha_db)
	})

	mux.HandleFunc("/getshabdata", func(w http.ResponseWriter, r *http.Request) {
		GetShabHandler(w, r, sakha_db)
	})
	//Обработчики для сохранения данных в БД
	mux.HandleFunc("/edit/accept", func(w http.ResponseWriter, r *http.Request) {
		EditAcceptHandler(w, r, db, &SessionData)
	})
	mux.HandleFunc("/createuser/accept", func(w http.ResponseWriter, r *http.Request) {
		CreateAcceptHandler(w, r, db)
	})
	mux.HandleFunc("/updateuserrole", func(w http.ResponseWriter, r *http.Request) {
		UpdateUserRolesHandler(w, r, db)
	})
	mux.HandleFunc("/deleteuser/accept", func(w http.ResponseWriter, r *http.Request) {
		DeleteUserHandler(w, r, db)
	})
	mux.HandleFunc("/edit/changepass", func(w http.ResponseWriter, r *http.Request) {
		ChangePasswordByUserHandler(w, r, db)
	})

	mux.HandleFunc("/rrssave", func(w http.ResponseWriter, r *http.Request) {
		SaveInputForm2Table(w, r, sakha_db)
	})

	mux.HandleFunc("/rosave", func(w http.ResponseWriter, r *http.Request) {
		SaveDayInputForm2Table(w, r, sakha_db)
	})

	//Обработчики логин/логаут
	mux.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
		LoginHandler(w, r, db, &SessionData)
	})
	mux.HandleFunc("/logout", func(w http.ResponseWriter, r *http.Request) {
		LogoutHandler(w, r, &SessionData, db)
	})

	//Обработчики вида "проверь права на html---сгенерируй страницу


	//Для страницы редактирования нам надо получить информацию о спсообе входа.
	//Ее возьмем непосредственно из строки запроса

	mux.HandleFunc("/edit", func(w http.ResponseWriter, r *http.Request) {
		var ThisPageMeta *PageMeta
		IsAdmin:= r.URL.Query().Get("IsAdmin")=="true"
		if(IsAdmin){
			ThisPageMeta=&PageMeta{"Редактирование пользователя","/edit?IsAdmin=true",
				"Редактирование данных пользователя", "icofont icofont-edit bg-c-pink" }
		}else{
			ThisPageMeta=&PageMeta{"Профиль","/edit",
				"Личные данные пользователя", "icofont icofont-edit bg-c-pink" }
		}
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("edituser.html", "./ui/html/edituser.html" , *ThisPageMeta,
		Edithtml{r.URL.Query().Get("IsAdmin") == "true"})
		h.HtmlHandle(w,r)
	})


	//Для создания пользовтаелья дополнительно подгрузим дерево департаментов и список ролей из БД

	mux.HandleFunc("/createuser", func(w http.ResponseWriter, r *http.Request) {
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("createuser.html", "./ui/html/createuser.html" ,
			PageMeta{PageHttp: "/createuser", PageName: "Создание пользователя", PageDescribe: "Создание нового пользователя",
				PageLogoClass: "icofont-edit bg-c-pink"},
			Createhtml{
				func(db *sql.DB) *DepTree {
					tree, err := GetDepTree(db, -1)
					if err != nil {
						log.ErrLog.Println("Error loading departments tree")
					}
					return tree
				}(db),
				func(*sql.DB) []Role {
					var RoleArr []Role
					hc := http.Client{}
					resp, _ := hc.Get("http://localhost:8182/getallroles")
					x, _ := ioutil.ReadAll(resp.Body)
					json.Unmarshal(x, &RoleArr)
					return RoleArr
				}(db)})
		h.HtmlHandle(w,r)
	})


	//Для создания пользовтаелья дополнительно подгрузим дерево департаментов и список ролей из БД
	mux.HandleFunc("/yakuttest", func(w http.ResponseWriter, r *http.Request) {
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("yakuttest.html", "./ui/html/yakuttest.html" ,
			PageMeta{PageHttp: "/yakuttest", PageName: "Тест ррс",
				PageDescribe: "Тестовая таблица. Параметры ррс и окр.среды",
				PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"}, nil)
		h.HtmlHandle(w,r)
	})

	mux.HandleFunc("/yakuttestro", func(w http.ResponseWriter, r *http.Request) {
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("yakuttestro.html", "./ui/html/yakuttestro.html" ,
			PageMeta{PageHttp: "/yakuttestro", PageName: "Тест качество газа",
				PageDescribe: "Tестовая таблица: Паспорт качества газа",
				PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"}, nil)
		h.HtmlHandle(w,r)
	})

	mux.HandleFunc("/yakuttestcross", func(w http.ResponseWriter, r *http.Request) {
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("yakuttestcross.html", "./ui/html/yakuttestcross.html" ,
			PageMeta{PageHttp: "/yakuttestcross", PageName: "Tест кросс-таблица",
				PageDescribe: "Тестовая таблица ррс с выборкой параметра за промежуток",
				PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"}, nil)
		h.HtmlHandle(w,r)
	})

	mux.HandleFunc("/yakuttesttree", func(w http.ResponseWriter, r *http.Request) {
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("yakuttesttree.html", "./ui/html/yakuttesttree.html" ,
			PageMeta{PageHttp: "/yakuttestree", PageName: "Тестовые деревья", PageDescribe: "Набор тестовых деревьев",
				PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"}, nil)
		h.HtmlHandle(w,r)
	})

	mux.HandleFunc("/yakuttestshab", func(w http.ResponseWriter, r *http.Request) {
		h:= DefaultHtmlHandler
		h.ConfigDefaultHandler("yakuttestshab.html", "./ui/html/yakuttestshab.html" ,
			PageMeta{PageHttp: "/yakuttestshab", PageName: "Тестовый шаблон", PageDescribe: "Тестовый шаблон",
				PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"}, nil)
		h.HtmlHandle(w,r)
	})

	return mux
}
