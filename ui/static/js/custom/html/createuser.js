const COLOR_RED = "#F00";


//Собираем форму для отправки джсоном
function  SendJSON(){
    return {user_login: GetProperty("login"), user_password: GetProperty("password"),
        dep_index: GetProperty("deplist")>0?Number(GetProperty("deplist")):null, user_properties:{user_name:GetProperty("uname"),
        user_surname:GetProperty("usurname"), user_middlename:GetProperty("umiddlename"),
        email:GetProperty("email"), phone:GetProperty("phone")}, role_list:GetRoleList()}
};
//Вспомогателная функция
function GetProperty(obj_name){
    return document.getElementById(obj_name).value.length!==0? document.getElementById(obj_name).value:null;
}
//Загрузка ролей из мультиселекта в джсон. Можно переписать через функции массивов, будет быстрее
function GetRoleList(){
    let arr = [];
    let rl = document.getElementById("rolelist");
    for (let irole of rl){
        if (irole.selected) {
            arr.push(Number(irole.value))
        }
    }
    return arr
}
//Сохраняем юзера, вообще говоря нужно обобщать
async function CreateUser(){

    //Вот это надо выделить в отдельную функцию, параметры-- джсон который отправляем, да адрес запроса
    let response = await fetch('/createuser/accept', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: JSON.stringify(SendJSON())
    });
    let ans = await response.json()
    //То же стандартный обработчик: пришел ответ с ошибкой вызываем одно окно, без--другое
   ans.err_message.length===0?
       setSuccessInfoModal("User was succesfully created!"):
       setFailureInfoModal("Error in creating user: "+ans.err_message);
    $('#modalinfo').modal('show')


}
 //Проверка логина на наличие в БД. По идее, нужно обобщать на просто проверку вида Check(func),
//Собственно говоря obj в аргументе это и есть первый шаг к этому)
async  function CheckLogin(obj) {
    let URL = "/getuserlist";
    let resp = await fetch(URL);
    let ulist =await resp.json();
    obj.style.background=Array.from(ulist).map(x=>x.user_login).includes(obj.value)? COLOR_RED: null
}
