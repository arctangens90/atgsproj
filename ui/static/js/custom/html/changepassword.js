
async function ChangePassword(iuser_index, old_pass, new_pass, confirm_pass){
    if (new_pass!==confirm_pass){
        setFailureInfoModal("Incorrect password confirmation!");
    }else {
        let response = await fetch('/edit/changepass', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json;charset=utf-8'
            },
            body: JSON.stringify({
                user_index: iuser_index,
                old_password: old_pass,
                new_password: new_pass
            })
        });
        let ans = await response.json()
        ans.err_message.length === 0?
            setSuccessInfoModal("Password was succesfully changed!"):
            setFailureInfoModal("Error in changing password: "+ans.err_message);

    }
    $('#modalinfo').modal('show')
    RefreshCheckPasswordForm()
}

function CheckErrorProperty(obj, errCheckFunc){
    obj.style.background=errCheckFunc()? null: 'red'
}

function RefreshCheckPasswordForm(){
    document.getElementById('oldpass').value=""
    document.getElementById('newpass').value=""
    document.getElementById('newpassconfirm').value=""
}
