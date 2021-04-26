//получение данных с сервера
async function getJSONFromServer(url){
    try{
        let resp = await fetch(url);
        let ans =  await resp.json();
        return ans
    }catch{
        return {"err_message":"Wrong response from server"}
    }
}

//отправка данных на сервер
async function postJSON2Server(url, f){
    let response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: JSON.stringify(f())
    });
    try{
        return await response.json()
    }catch(err){
        return {"err_message":"bad response from server"}
    }
}

async function postJSON2ServerCallback(url, jsonGetter, successfunc, errfunc ){
    let ans = await postJSON2Server(url, jsonGetter);
        ans.err_message.length == 0 ? successfunc(ans) : errfunc(ans);
}

function postJSON2ServerModalCallback(url, jsonGetter, successMess, errMess){
    postJSON2ServerCallback(url, jsonGetter, ans=>setSuccessInfoModal(successMess),
        ans=>setFailureInfoModal(errMess +": " +ans.err_message));
    $('#modalinfo').modal('show');
}


function defaultDataSaver(url, jsonGetter){
    postJSON2ServerModalCallback(url, jsonGetter, "Успешно сохранено", "Ошибка при сохранении данных")
}