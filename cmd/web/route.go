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
	//Для главной страницы
	/*
	   http.HandleFunc("/index", func(w http.ResponseWriter, r *http.Request) {
	   	func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
	   		handler.HtmlHandle(w, r)
	   	}(w, r, HtmlHandler{
	   		DenyHandler:    DenyHandler,
	   		SourceHtml:     "index.html",
	   		PathSourceHtml: append([]string{"./ui/html/index.html"}, HeadersTmpl...),
	   		HtmlData: HtmlObjects{
	   			CommonObjects:   nil,
	   			SessionData:     &SessionData,
	   			AcceptedObjects: make(AccessMap),
	   		},
	   		Db: db,
	   	})
	   })

	*/

	//Для страницы редактирования нам надо получить информацию о спсообе входа.
	//Ее возьмем непосредственно из строки запроса
	mux.HandleFunc("/edit", func(w http.ResponseWriter, r *http.Request) {
		func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
			handler.HtmlHandle(w, r)
		}(w, r, HtmlHandler{
			DenyHandler:    DenyHandler,
			SourceHtml:     "edituser.html",
			PathSourceHtml: append([]string{"./ui/html/edituser.html"}, HeadersTmpl...),
			HtmlData: HtmlObjects{
				CommonObjects:   Edithtml{r.URL.Query().Get("IsAdmin") == "true"},
				SessionData:     &SessionData,
				AcceptedObjects: make(AccessMap),
			},
			Db: db,
		})
	})

	//Для создания пользовтаелья дополнительно подгрузим дерево департаментов и список ролей из БД
	mux.HandleFunc("/createuser", func(w http.ResponseWriter, r *http.Request) {
		func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
			handler.HtmlHandle(w, r)
		}(w, r, HtmlHandler{
			DenyHandler:    DenyHandler,
			SourceHtml:     "createuser.html",
			PathSourceHtml: append([]string{"./ui/html/createuser.html"}, HeadersTmpl...),
			HtmlData: HtmlObjects{
				CommonObjects: Createhtml{
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
					}(db)},
				SessionData:     &SessionData,
				AcceptedObjects: make(AccessMap),
				PageMeta: PageMeta{PageHttp: "/createuser", PageName: "Create User", PageDescribe: "Include create user",
					PageLogoClass: "icofont-edit bg-c-pink"},
			},
			Db: db,
		})
	})

	//Для создания пользовтаелья дополнительно подгрузим дерево департаментов и список ролей из БД
	mux.HandleFunc("/yakuttest", func(w http.ResponseWriter, r *http.Request) {
		func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
			handler.HtmlHandle(w, r)
		}(w, r, HtmlHandler{
			DenyHandler:    DenyHandler,
			SourceHtml:     "yakuttest.html",
			PathSourceHtml: append([]string{"./ui/html/yakuttest.html"}, HeadersTmpl...),
			HtmlData: HtmlObjects{
				CommonObjects:   nil,
				SessionData:     &SessionData,
				AcceptedObjects: make(AccessMap),
				PageMeta: PageMeta{PageHttp: "/yakuttest", PageName: "Test rrs", PageDescribe: "Test table rrs",
					PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"},
			},
			Db: db,
		})
	})

	mux.HandleFunc("/yakuttestro", func(w http.ResponseWriter, r *http.Request) {
		func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
			handler.HtmlHandle(w, r)
		}(w, r, HtmlHandler{
			DenyHandler:    DenyHandler,
			SourceHtml:     "yakuttestro.html",
			PathSourceHtml: append([]string{"./ui/html/yakuttestro.html"}, HeadersTmpl...),
			HtmlData: HtmlObjects{
				CommonObjects:   nil,
				SessionData:     &SessionData,
				AcceptedObjects: make(AccessMap),
				PageMeta: PageMeta{PageHttp: "/yakuttestro", PageName: "Test rho", PageDescribe: "Test table rho",
					PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"},
			},
			Db: db,
		})
	})

	mux.HandleFunc("/yakuttestcross", func(w http.ResponseWriter, r *http.Request) {
		func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
			handler.HtmlHandle(w, r)
		}(w, r, HtmlHandler{
			DenyHandler:    DenyHandler,
			SourceHtml:     "yakuttestcross.html",
			PathSourceHtml: append([]string{"./ui/html/yakuttestcross.html"}, HeadersTmpl...),
			HtmlData: HtmlObjects{
				CommonObjects:   nil,
				SessionData:     &SessionData,
				AcceptedObjects: make(AccessMap),
				PageMeta: PageMeta{PageHttp: "/yakuttestcross", PageName: "Test cross", PageDescribe: "Test crosstable rrs",
					PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"},
			},
			Db: db,
		})
	})

	mux.HandleFunc("/yakuttesttree", func(w http.ResponseWriter, r *http.Request) {
		func(w http.ResponseWriter, r *http.Request, handler HtmlHandler) {
			handler.HtmlHandle(w, r)
		}(w, r, HtmlHandler{
			DenyHandler:    DenyHandler,
			SourceHtml:     "yakuttesttree.html",
			PathSourceHtml: append([]string{"./ui/html/yakuttesttree.html"}, HeadersTmpl...),
			HtmlData: HtmlObjects{
				CommonObjects:   nil,
				SessionData:     &SessionData,
				AcceptedObjects: make(AccessMap),
				PageMeta: PageMeta{PageHttp: "/yakuttestree", PageName: "Test tree", PageDescribe: "Test table tree",
					PageLogoClass: "icofont-animal-cat-alt-3 bg-c-orenge"},
			},
			Db: db,
		})
	})

	return mux
}
