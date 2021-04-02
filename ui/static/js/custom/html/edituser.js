//Переменные для удобного обращения к DOM-объектам

let DepList = document.getElementById("deplist")
let UserList = document.getElementById("userlist")
let AvailableRoleList = document.getElementById("availablerolelist")
let AcceptedRoleList = document.getElementById("acceptedrolelist")
let UserJsonList
let IsAdmin


//Заполнение формы для редактирвоания
function fillform (ijson){
    let prop = ijson.user_properties
    if (prop!=null){
        definefield("uname",prop.user_name);
        definefield("usurname",prop.user_surname);
        definefield("umiddlename",prop.user_middlename);
        definefield("uemail",prop.user_email);
        definefield("uphone",prop.user_phone);

    }else{
        definefield("uname",null);
        definefield("usurname",null);
        definefield("umiddlename",null);
        definefield("uemail",null);
        definefield("uphone",null);
    }

}

function definefield(element, value){
    document.getElementById(element).value =value==undefined ?null:value
}

function emptyStr2null(str){
    return str===""? null: str;
}

//Асинхронные функции, заполняющие список из джсона, полученного с сервера.
//Кастомизировано!
async  function GetDepJson(dep_index){
    let EditPageDepOptions= {
        url: "/getdeplist?dep_index=" + dep_index,
        defText: "Department",
        decoder: {
            dectext: "dep_name",
            decvalue: "dep_index",
        }
    }
    await fillListFromServer(DepList,EditPageDepOptions)
}

async  function GetUserJson() {
   let EditPageUserOptions={
       url: "/getuserlist",
       defText: "Login",
       decoder:{
           dectext: "user_login",
           decvalue: "user_index"
       }
   }
    await fillListFromServer(UserList,EditPageUserOptions, ()=>{} , (ans)=>{UserJsonList=ans})

}

async function GetAvailableRoleList(ilogin){
    let EditPageAvailableRolesOptions={
        url: "/getavailableroles?Login=" +ilogin,
        decoder:{
            dectext: "role_name",
            decvalue: "role_index",
            dectitle: "role_fullname"
        },
        liclass : "list-group-item"
    }
    await fillUiListFromServer(AvailableRoleList,EditPageAvailableRolesOptions);

}

///В ПРОЦЕССЕ РАЗРАБОТКИ!!!
async function GetAcceptedRolesList(ilogin) {
    let EditPageAcceptedRolesOptions={
        url: "/getroles?Login=" + ilogin,
        decoder:{
            dectext: "role_name",
            decvalue: "role_index",
            dectitle: "role_fullname"
        },
        liclass : "list-group-item"
    }
    await fillUiListFromServer(AcceptedRoleList,EditPageAcceptedRolesOptions);


}

//аналогично функциям в createuser. обобщить и кастомизировать.
async function UpdateUserRoles() {


    let response = await fetch('/updateuserrole', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: JSON.stringify(SendRoleJSON())
    });
    try{
        let ans = await response.json();
        (ans.insrows+ans.delrows)>0 ?
            setSuccessInfoModal("Inserted " + ans.insrows.toString() + "rows; deleted " + ans.delrows.toString() + "rows"):
            setFailureInfoModal("No roles were updated or deleted");
    }catch{
        setFailureInfoModal("Database error");
    }
    finally {
        $('#modalinfo').modal('show')
    }


}

async function UpdateUserProperties() {
    let response = await fetch('/edit/accept?IsAdmin='+IsAdmin, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: JSON.stringify(SendPropertiesJSON())
    });
    let ans = await response.json()
    if (ans.err_message.length === 0) {
            setSuccessInfoModal("User was succesfully changed!");
            await GetUserJson();
            UserList.onchange();
        }else{
        setFailureInfoModal("Error in updating user: "+ans.err_message);
    }
    $('#modalinfo').modal('show')
}


//Перенос из списка в список. Если заставим работать бутсраповые списки, можно сносить
function AddRole(){
    let SelectedRoles = Array.from(AllRoleList.options).filter(option=>option.selected)
    let AcceptedRoles = Array.from(AcceptedRoleList.options).map(option=>option.value)
    for (sr of SelectedRoles){
        if (AcceptedRoles.includes(sr.value)){
            setFailureInfoModal("Role "+sr.text+" already existed");
            $('#modalinfo').modal('show')
        }
        else{
            addOption(AcceptedRoleList, sr.text,sr.value);
        }
    }
}


function DeleteRoles(){
    for (let sr of Array.from(AcceptedRoleList.options).filter(option=>option.selected))
    AcceptedRoleList.removeChild(sr)
}
//Собираем карту ролей для редактирования
function SendRoleJSON(){
    return {user_index: UserList.value, role_list: GetUserRoleList()}
}
//Собираем данные пользователя для редактирвоания
function SendPropertiesJSON(){
    let obj =  { dep_index: Number(DepList.value)===-1?null:Number(DepList.value), user_properties: {
        user_name: emptyStr2null(document.getElementById("uname").value),
        user_surname: emptyStr2null(document.getElementById("usurname").value),
        user_middlename: emptyStr2null(document.getElementById("umiddlename").value),
        email: emptyStr2null(document.getElementById("uemail").value),
        phone: emptyStr2null(document.getElementById("uphone").value),
        }}
        if(IsAdmin) obj.user_index = Number(UserList.value)
    return obj
}

//Получения данных вида "пользователь-роль"
function GetUserRoleList(){
    //Array.from(AcceptedRoleList.children).forEach(li=>alert(li["data-value"]))
    return Array.from(AcceptedRoleList.children).map(li=>li.getAttribute("data-value"))
}


//Генерация страницы (запускаем при смене логина в выпадающем списке
async function  GeneratePage(id){
    let el = UserJsonList[id]
    fillform(el);
    await GetDepJson(el.dep_index)


  //  await GetAcceptedRolesList(el.user_login)
  //  await GetAvailableRoleList(el.user_login)
 //   Array.from(AcceptedRoleList.children).forEach(li=>alert(li["data-value"]))
}



function InProcess(){
    setInfoModal(new Modal("Information", "This functional now in process", "OK"))
    $('#modalinfo').modal('show')
}













