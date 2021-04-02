package main

import (
	"encoding/json"
	"io/ioutil"
	"os"
)

type Config struct {
	ServerConfig  `json:"server"`
	AdminDBConfig DBConfig  `json:"admin_database"`
	OtherDB       []OtherDB `json:"db_map,omitempty"`
}

type ServerConfig struct {
	Host string `json:"host"`
	Port string `json:"port"`
}

type DBConfig struct {
	Host     string `json:"host"`
	Port     string `json:"port"`
	User     string `json:"user"`
	Password string `json:"password"`
	DBName   string `json:"dbname"`
	Ssl      string `json:"sslmode"`
}

type OtherDB struct {
	DBname   string `json:"extdb_name,omitempty"`
	DBConfig `json:"extdb_config,omitempty"`
}

func LoadConfig() (Config, error) {
	var cfg Config
	cfile, err := os.Open("./cmd/web/config.json")
	if err != nil {
		return Config{}, err
	}
	cdata, err := ioutil.ReadAll(cfile)
	if err != nil {
		return Config{}, err
	}
	err = json.Unmarshal(cdata, &cfg)
	if err != nil {
		return Config{}, err
	}
	return cfg, nil
}

func ApplyConfig(cfg Config) (serverstring string, dbstring string, dbmap map[string]string) {
	dbmap = make(map[string]string)
	for _, odb := range cfg.OtherDB {
		dbmap[odb.DBname] = "host=" + odb.Host + " port=" + odb.Port + " user=" + odb.User + " password=" +
			odb.Password + " dbname=" + odb.DBName + " sslmode=" + odb.Ssl
	}
	return cfg.ServerConfig.Host + ":" + cfg.ServerConfig.Port,
		"host=" + cfg.AdminDBConfig.Host + " port=" + cfg.AdminDBConfig.Port + " user=" + cfg.AdminDBConfig.User + " password=" +
			cfg.AdminDBConfig.Password + " dbname=" + cfg.AdminDBConfig.DBName + " sslmode=" + cfg.AdminDBConfig.Ssl,
		dbmap

}
