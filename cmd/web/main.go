package main

import (
	"TurkeyGo/cmd/log"
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"net/http"
)

func main() {

	cfg, err := LoadConfig()
	if err != nil {
		log.ErrLog.Fatal("Ошибка загрузки конфигурации. Детали:", err)
	}
	addr, connStr, extdb := ApplyConfig(cfg)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.ErrLog.Fatal("Ошибка загрузки базы. Детали:", err)
	}

	sakha_db, err := sql.Open("postgres", extdb["sakha"])

	//Переменная с данными пользователя. Можно заменить на куку, мне кажется так удобнее, чтоб не гонять туда-сюда
	//конвертацию типов данных
	SessionData := SessionData{BasicAcceptedObjects: make(AccessMap)}
	DBPool := map[string]*sql.DB{"admin": db, "sakha": sakha_db}
	RouteData := RouteData{SessionData, DBPool}
	//обработчик для статических файлов

	srv := &http.Server{Addr: addr, ErrorLog: log.ErrLog, Handler: routes(&RouteData)}
	log.InfoLog.Printf("Запуск сервера по адресу %s", addr)
	fmt.Println("Server is listening...")
	//Запускаем веб-сервер
	err = srv.ListenAndServe()
	if err != nil {
		log.ErrLog.Fatal(err)
	}
}
