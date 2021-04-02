package main

import (
	"TurkeyGo/cmd/log"
	"database/sql"
	"net/http"
)

//Обработчики для выгрузки данных. Отличаются запросами.

//Общая функция, возвращаем json из БД
func JsonFromSqlFuncHandler(w http.ResponseWriter, r *http.Request, db *sql.DB, querystr string,
	queryargs ...interface{}) {
	var IArr []byte
	var rows *sql.Rows
	rows, err := db.Query(querystr, queryargs...)
	if err != nil {
		log.ErrLog.Printf("Error loading data, %s %s ", err, querystr)
		return
	}
	for rows.Next() {
		err = rows.Scan(&IArr)
		if err != nil {
			log.ErrLog.Printf("Error processing data, %s", err)
		}
	}
	_, err = w.Write(IArr)

	if err != nil {
		log.ErrLog.Printf("Error writing data, %s", err)
	}

	defer w.Header().Set("Content-type", "application/json")
}

//частные случаи
func GetRolesHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from admin.get_userrolelist($1)",
		r.URL.Query().Get("Login"))
}

func GetNoRolesHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from admin.get_userrolenolist($1)",
		r.URL.Query().Get("Login"))
}

func GetAllRolesHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from admin.get_all_roles_list()")
}

func GetUsersHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from admin.get_userlist_json()")

}

func GetRRSTableHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from test_rrs($1)", r.URL.Query().Get("val_time"))
}

func GetCrossRRSTableHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from test_cross_rrs($1, $2, $3)", r.URL.Query().Get("gp_index"),
		r.URL.Query().Get("date_beg"),
		r.URL.Query().Get("date_end"))
}

func GetRoTableHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	JsonFromSqlFuncHandler(w, r, db, "select * from test_tok($1)", r.URL.Query().Get("val_time"))
}

func GetDepHandler(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	if r.URL.Query().Get("dep_index") != "null" {
		JsonFromSqlFuncHandler(w, r, db, "select * from admin.get_department_tree_json($1)",
			r.URL.Query().Get("dep_index"))
	} else {
		JsonFromSqlFuncHandler(w, r, db, "select * from admin.get_department_tree_json(null)")
	}
}
