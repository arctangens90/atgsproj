package log

import (
	fmtdate "TurkeyGoNewDesign/pkg/fmtdate-master"
	"io/ioutil"
	"log"
	"os"
	"sort"
	"strings"
	"time"
)

var InfoLog = SetFileLogger("./cmd/log/info", "INFO\t")
var ErrLog = SetFileLogger("./cmd/log/error", "ERROR\t")

const MAXLOGFILES int = 6

func SetFileLogger(filename string, prefix string) *log.Logger {
	CheckCountLogs(prefix)
	f, err := os.OpenFile(filename+fmtdate.Format("DDMMYYYY_hhmm", time.Now())+".txt",
		os.O_RDWR|os.O_CREATE, 0666)
	if err != nil {
		log.Fatal(err)
	}
	//defer f.Close()
	return log.New(f, prefix, log.Ldate|log.Ltime)
}

func CheckCountLogs(prefix string) {
	loglist, _ := ioutil.ReadDir("./cmd/log")

	i := 1
	sort.Slice(loglist, func(i, j int) bool {
		return loglist[i].ModTime().After(loglist[j].ModTime())
	})
	for _, file := range loglist {
		if strings.Contains(strings.ToUpper(file.Name()), strings.TrimRight(prefix, "\t")) &&
			i >= MAXLOGFILES && strings.HasSuffix(file.Name(), "txt") {
			os.Remove("./cmd/log/" + file.Name())
		}
		i++
	}

}
