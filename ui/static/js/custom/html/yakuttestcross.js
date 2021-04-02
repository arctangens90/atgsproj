let iTab;
let date_beg;
let date_end;
let igp_index;

let iDecoder ={
    rowData:{
        rowIndexes: ["go_index"], //строковые индексы (т.е., обекты, определяющие строку)
        rowMeta: [], //строковые мета-данные
    },
    columnData:{
        columnDataName: "hist_values", //название для вложенного json с данными о столбцах
        columnMeta:[], //мета-данные столбца
        columnNote: "gp_note" ,//Код для нахождения столбца
        columnIndexes:["val_time"], //индексы, определяющие столбец
        columnRefreshable: ["val_value", "prev_value", "val_time"],   //обновляемые поля
        columnValue: "val_value", //Значения для ячейки
        columnService: {          //Служебные значения для ячейки
            cellPlaceholder: "prev_value", //Значения по умолчанию (и источник)
            cellStates: "op_states",     //Откуда брать состояния
            cellControl: "op_control"    //Откуда брать границы
        }
    }
}

let iEncoder ={
    rowIndexes: ["go_index"],
    columnIndexes: ["val_time", "val_value"],
    metaValues: [{
        int_name: "gp_index",
        ext_name: "gp_index"
    }]
}


function Date2Str(idate){
    return idate.getDate().toString()+"."+(idate.getMonth()+1).toString()+"."+idate.getFullYear().toString()+
       " "+ (idate.getHours().toString()<10? "0"+idate.getHours().toString():+idate.getHours().toString())+":"
    +(idate.getMinutes().toString()<10? "0"+idate.getMinutes().toString(): idate.getMinutes().toString());

}


async function initTable(){
    let crossData = await getJSONFromServer("/getcrossrrsdata?gp_index="+document.getElementById("isel").value
        +"&date_beg="+date_beg+"&date_end="+date_end);


    let Columns = [new RowMetaTextCell({header:"Объект",  sourcefield:"go_fullname", decoder:iDecoder})]
    let columnResFuncs = [()=>"Минимум"];

    for(let d=new Date(date_beg); new Date(date_end)-d>=0; d.setHours(d.getHours()+1) ){
        Columns.push(new DefaultNumberInputCell({header: Date2Str(d)}))
        columnResFuncs.push( arr=> {
            let res = arr.reduce((cmin, el)=>{return cmin>(el ?? Infinity)?Number(el):cmin}, Infinity) ;
            return res==Infinity?'':res;
        })
    }

    Columns.push(new MinCellFromColumns({header:'Минимум', noteArr:
        Columns.filter(a=>a instanceof DefaultNumberInputCell).map(y=>y.header), decoder:iDecoder}))
    iTab = new TabCreator({TableMeta: {TableName: "Cross tab rrs", gp_index: document.getElementById("isel").value} ,
        TableData: crossData, Columns,
            SaveFunc: f=>defaultDataSaver("/rrssave", f), DataCoder:
        {Decoder:iDecoder, Encoder: iEncoder}});

    iTab.GroupRows.footRow = function(tbody){
        createResultRow.call(iTab,row=>row.style="border: 2px solid orange",columnResFuncs, tbody)
    }



   iTab.FillByJSON = function(extObj) {
       Array.from(document.getElementById("containertab").children).
       forEach((li)=>document.getElementById("containertab").removeChild(li));
       initTable();
    }

    iTab.setColumnWidthFromArray([2,1])


    iTab.renderTable("containertab")
}

async function refreshTable(){
    let crossData = await getJSONFromServer("/getcrossrrsdata?gp_index="+document.getElementById("isel").value
        +"&date_beg="+date_beg+"&date_end="+date_end);
    iTab.TableMeta.gp_index=igp_index;
    iTab.FillByJSON(crossData);
}

function renderTable(){
    iTab? refreshTable(): initTable()
}

