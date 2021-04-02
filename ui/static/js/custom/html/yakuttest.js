let iTab
let val_time


function existedMax(...arr){
    return arr.reduce((cmax, el)=>cmax<(el ?? -Infinity)?Number(el):cmax, -Infinity)
}

function existedMin(...arr){
    return arr.reduce((cmin, el)=>{return cmin>(el ?? Infinity)?Number(el):cmin}, Infinity);

}

async function initTable(){
    let rrsData = await getJSONFromServer("/getrrsdata?val_time="+val_time)

    let columnResFuncs=[()=>"Минимальные параметры",
            arr=>Math.min(...arr),
       // arr=>Math.min(...arr),
        arr=>existedMin(...arr),
        null, null ]


    iTab = new TabCreator({TableMeta: {TableName: "RRS", HistTime: val_time} , TableData: rrsData, Columns: [
        new RowMetaTextCell({header: "Объект", sourcefield: "go_fullname"}),
        new NumberInputCellWithButton({header:"Температура воздуха \u00B0"+ "C", note: "Tv"}),
        new NumberInputCellWithButton({header: "Влажность, %", note: "phi"}),
        new DefaultNumberInputCell({header: "Скорость ветра", note: "v_wind"}),
        new DefaultSelectCell({header:"Направление ветра", note: "wind_dir"} ),
        new SumCellFromColumns({header:"Сумма", noteArr: ["Tv", "phi"]})],

        SaveFunc: f=>postJSON2ServerModalCallback("/rrssave", f, "Successfully saved",
                "Error in saving data")}

        );

    iTab.GroupRows.footRow = function(tbody){
        createResultRow.call(iTab,row=>row.style="border: 2px solid orange",columnResFuncs, tbody)
    }


    iTab.setColumnWidthFromArray([7, 3,3,3,3,3])

    iTab.renderTable("containertab")
}

async function refreshTable(){
    let rrsData = await getJSONFromServer("/getrrsdata?val_time="+val_time)
    iTab.TableMeta.HistTime=val_time;
    iTab.FillByJSON(rrsData);
}

function renderTable(){

    iTab? refreshTable(): initTable()
}

