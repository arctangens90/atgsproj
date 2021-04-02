package main

//вспомогательные типы. Смысл ясен из названия

type DepTree map[int]DepList

type DepList struct {
	DepName  string
	DepIndex int
}

type Session struct {
	SessionIndex int
	UserIndex    int
	RoleIndex    int
}

type Role struct {
	RoleIndex    int    `json:"role_index"`
	RoleName     string `json:"role_name"`
	RoleFullname string `json:"role_fullname"`
}

type User struct {
	UserIndex  int            `json:"user_index,omitempty"`
	Login      string         `json:"user_login,omitempty"`
	DepIndex   int            `json:"dep_index,omitempty"`
	DepName    string         `json:"dep_name,omitempty"`
	Properties UserProperties `json:"user_properties,omitempty"`
}

type UserProperties struct {
	UserName       string `json:"user_name,omitempty"`
	UserSurname    string `json:"user_surname,omitempty"`
	UserMiddlename string `json:"user_middlename,omitempty"`
	Email          string `json:"email,omitempty"`
	Phone          string `json:"phone,omitempty"`
}

type UserFullData struct {
	User User
	Role Role
}

type CreateUser struct {
	Login         string         `json:"user_login"`
	Password      string         `json:"user_password"`
	DepIndex      string         `json:"dep_index,omitempty"`
	Properties    UserProperties `json:"user_properties"`
	AcceptedRoles []int          `json:"role_list"`
}

//Дополнительные данные для страницы редактирования данных
type Edithtml struct {
	IsAdmin bool //если true--зашли как админ редактировать других юзеров, иначе зашли просто в ЛК
}

//Дополнительные данные для страницы создания данных
type Createhtml struct {
	DepTree  *DepTree //дерево департаментов
	RoleList []Role   //список ролей
}
