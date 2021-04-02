
let RoleList = document.getElementById("rlist");

async function GetRolesJSON(){
    let RolePageOptions={
        url : "/getroles?Login="+document.getElementById("uname").value,
        defText: "Role",
        decoder:{
            dectext: "role_name",
            decvalue: "role_index",
            dectirile: "role_fullname"
        }
    }
    await fillListFromServerModal(RoleList, RolePageOptions, "Error loading role list")

}

