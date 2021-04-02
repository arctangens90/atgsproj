let iTab
let val_time
let iDecoder ={
    rowData:{
        rowIndexes: ["go_index", "type_index"], //строковые индексы (т.е., обекты, определяющие строку)
        rowMeta: [], //строковые мета-данные
    },
    columnData:{
        columnDataName: "hist_values", //название для вложенного json с данными о столбцах
        columnMeta:[], //мета-данные столбца
        columnNote: "gp_note" ,//Код для нахождения столбца
        columnIndexes:["gp_index"], //индексы, определяющие столбец
        columnRefreshable: ["val_value", "prev_value", "val_time"],   //обновляемые поля
        columnValue: "val_value", //Значения для ячейки
        columnService: {          //Служебные значения для ячейки
            cellPlaceholder: "prev_value", //Значения по умолчанию (и источник)
            cellStates: "op_states",     //Откуда брать состояния
            cellControl: "op_control"    //Откуда брать границы
        }
    }
}



async function initTable(){
    let roData = await getJSONFromServer("/getrodata?val_time="+val_time)

    iTab = new TabCreator({TableMeta: {TableName: "Gas quality", HistTime: val_time} , TableData: roData, Columns:[
            new SimpleTextCell({header: "Точка определения качества",itext: "", decoder:iDecoder}),
            new ColumnMetaTextCell({header:"Параметр", sourcefield: "gp_fullname", note:"m", decoder:iDecoder}),
            new ColumnMetaTextCell({header:"Размерность", sourcefield: "gp_dim", note:"m", decoder:iDecoder}),
            new DefaultNumberInputCell({header:"Значение", note:"m", decoder:iDecoder}),
            new ColumnValueTextCell({header:"Метка времени", sourcefield: "val_time", note:"m", decoder:iDecoder}),
            new ColumnMetaTextCell({header:"Размерность", sourcefield: "gp_dim", note:"v", decoder:iDecoder}),
            new DefaultNumberInputCell({header:"Значение", note: "v", decoder:iDecoder}),
            new ColumnValueTextCell({header:"Метка времени", sourcefield: "val_time", note: "v", decoder:iDecoder}),
],

        SaveFunc: f=>postJSON2ServerModalCallback("/rosave", f, "Successfully saved",
            "Error in saving data"), DataCoder:
        {Decoder:iDecoder, Encoder: DefaultEncoder}}


    );

    iTab.setColumnWidthFromArray([9, 8,4,5,4, 4,5,4])

    iTab.GroupRows.contentRow=function(tbody, rowObj, j, arr){
        if (j==0 || rowObj[this.DataCoder.Decoder.rowData.rowIndexes[0]]!=
            arr[j-1][this.DataCoder.Decoder.rowData.rowIndexes[0]]){
            let row = createStyledElement('tr', r=>r.style="border: solid 2px orange;")
            this.Columns.forEach( (h,i)=> {
                let cell = document.createElement('td');
                if (i == 0) {
                    cell.appendChild(document.createTextNode(rowObj["go_name"]));
                } else {

                }
                row.appendChild(cell)
            })
            tbody.appendChild(row);
        }
    }.bind(iTab)

    iTab.renderTable("containertab")
}

async function refreshTable(){
    let roData = await getJSONFromServer("/getrodata?val_time="+val_time)
    iTab.TableMeta.HistTime=val_time;
    iTab.FillByJSON(roData);
}

function renderTable(){
    iTab? refreshTable(): initTable()
}

