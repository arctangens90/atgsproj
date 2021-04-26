//Функции для работы со списками
function addOption (ilist, text, value, title=null , isDefaultSelected=false, isSelected=false)
{
    let oOption = document.createElement("option");
    oOption.appendChild(document.createTextNode(text));
    oOption.setAttribute("value", value);
    oOption.setAttribute("title", title)
    if (isDefaultSelected) oOption.defaultSelected = true;
    else if (isSelected) oOption.selected = true;
    ilist.appendChild(oOption);
}


function addLiOption (ilist, liclass,  text, value, title){
    let li = document.createElement('li');
    li.className = "";
    li.setAttribute("data-value", value)
    li.title = title;
    li.appendChild(document.createTextNode(text));
    li.onclick =()=>{
        //complete автоматом ставит jquery, почему не знаю
        li.className = li.className=="selected complete"? "": "selected"
    }

    ilist.appendChild(li);
}

function addOptionFromObject(ilist, obj, decoder){
    addOption(ilist, obj[decoder.dectext], obj[decoder.decvalue], obj[decoder.dectitle])
}

function addLiOptionFromObject(ilist,  obj,liclass,  decoder){
    addLiOption(ilist,liclass, obj[decoder.dectext], obj[decoder.decvalue], obj[decoder.dectitle])
}


//Обновление списка
function refreshList(ilist){
    ilist.options.length = 0;
}

function refreshLiList(ilist){
    Array.from(ilist.children).forEach((li)=>ilist.removeChild(li));
}

//Заполнение списка
async function fillListFromServer(ilist, optionObj, errfunc= ()=>{}, successfunc= ()=>{} ){
    refreshList(ilist)
    let ans =  await getJSONFromServer(optionObj.url)

    if (ans.err_message == null){
        successfunc(ans)
        for (let opt of ans) {
            addOptionFromObject(ilist, opt, optionObj.decoder)
        }
    }else{
        errfunc(ans)
    }

    checkList(ilist, optionObj.defText)
}

async function fillUiListFromServer(ilist, optionObj, errfunc= ()=>{}, successfunc= ()=>{}){
    refreshLiList(ilist);
    let ans = await getJSONFromServer(optionObj.url);
    if (ans.err_message == null){
        successfunc(ans)
        for (let opt of ans) {
            addLiOptionFromObject(ilist, opt, optionObj.liclass, optionObj.decoder)
        }
    }else{
        errfunc(ans)
    }
}

//Тоже самое, но с выведением окна при ошибке
async function fillListFromServerModal (ilist, optionObj, errtext){
    fillListFromServer(ilist, optionObj, (ans)=>{
        setFailureInfoModal(errtext);
        $('#modalinfo').modal('show')
    })
}

//Создание базового элемента
function setListDefaultItem(ilist, defText){
    refreshList(ilist)
    addOption(ilist, defText, -1, "", true)
    ilist.options[0].disabled=true
    ilist.options[0].selected=true
    ilist.options[0].hidden=true
    ilist.style.color='#a9a9a9'
}

function checkList(ilist, defText){
    ilist.options.length==0 ?
        setListDefaultItem(ilist, defText):
        ilist.style.color="#000000"

}