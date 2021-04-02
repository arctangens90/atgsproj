let tree1 = [
    {
        go_index: 1,
        go_name: "root 1",
        hist_values:[
            {val_time: "day_1", val_value: 10},
            {val_time: "day 2", val_value: 15}],
        children:[
            {
                go_index: 3,
                go_name: "child 1",
                flag_sum: 1,
                hist_values: [
                    {val_time: "day_1", val_value: 9},
                    {val_time: "day_2", val_value: 10}
                ]
            },
            {
                go_index: 4,
                go_name: "child 2",
                flag_sum: 1,
                hist_values: [
                    {val_time: "day_1", val_value: 1},
                    {val_time: "day_2", val_value: 5}
                ],
                children:[
                    {
                        go_index: 7,
                        go_name: "vnuk  ",
                        flag_sum: 1,
                        hist_values: [
                            {val_time: "day_1", val_value: 1},
                            {val_time: "day_2", val_value: 5}
                        ]
                    }
                ]
            }

        ]
    },
    {
        go_index: 2,
        go_name: "level 1 ",
        hist_values:[
            {val_time: "day_1", val_value: 10},
            {val_time: "day 2", val_value: 15}],
        children:[
            {
                go_index: 5,
                go_name: "level 2  child 1",
                flag_sum: 1,
                hist_values: [
                    {val_time: "day_1", val_value: 9},
                    {val_time: "day_2", val_value: 10}
                ]
            },
            {
                go_index: 6,
                go_name: "level 2 child 2",
                flag_sum: 1,
                hist_values: [
                    {val_time: "day_1", val_value: 1},
                    {val_time: "day_2", val_value: 5}
                ]
            }

        ]
    }

]


let tree2 = [
    {
        go_index: 1,
        go_name: "root 1",
        hist_values:[
            {val_time: "day_1", val_value: 10},
            {val_time: "day_2", val_value: 15}]
    },
    {
        go_index: 3,
        go_go_index: 1,
        go_name: "child 1",
        hist_values:[
            {val_time: "day_1", val_value: 9},
            {val_time: "day_2", val_value: 11}]
    },
    {
        go_index: 4,
        go_go_index: 1,
        go_name: "child 2",
        hist_values:[
            {val_time: "day_1", val_value: 1},
            {val_time: "day_2", val_value: 4}]
    },
    {
        go_index: 7,
        go_go_index: 4,
        go_name: "grandchild 1",
        hist_values:[
            {val_time: "day_1", val_value: 1},
            {val_time: "day_2", val_value: 4}]
    },

    {
        go_index: 2,
        go_name: "root 2",
        hist_values:[
            {val_time: "day_1", val_value: 20},
            {val_time: "day_2", val_value: 25}]
    },
    {
        go_index: 5,
        go_go_index: 2,
        go_name: "child 3",
        hist_values:[
            {val_time: "day_1", val_value: 9},
            {val_time: "day_2", val_value: 11}]
    },
    {
        go_index: 6,
        go_go_index: 2,
        go_name: "child 4",
        hist_values:[
            {val_time: "day_1", val_value: 11},
            {val_time: "day_2", val_value: 14}]
    },


]




let tree3 =  [
    {
        go_index: 1,
        go_name: "root 1",
        hist_values:[
            {gp_note: "Q", val_value: 1000},
            {gp_note: "T", val_value: 15}]
    },
    {
        go_index: 3,
        go_go_index: 1,
        go_name: "child 1",
        hist_values:[
            {gp_note: "Q", val_value: 900},
            {gp_note: "T", val_value: 15}]
    },
    {
        go_index: 4,
        go_go_index: 1,
        go_name: "child 2",
        hist_values:[
            {gp_note: "Q", val_value: 100},
            {gp_note: "T", val_value: 14}]
    },
    {
        go_index: 7,
        go_go_index: 4,
        go_name: "grandchild 1",
        hist_values:[
            {gp_note: "Q", val_value: 100},
            {gp_note: "T", val_value: 14}]
    },

    {
        go_index: 2,
        go_name: "root 2",
        hist_values:[
            {gp_note: "Q", val_value: 2000},
            {gp_note: "T", val_value: 25}]
    },
    {
        go_index: 5,
        go_go_index: 2,
        go_name: "child 3",
        hist_values:[
            {gp_note: "Q", val_value: 900},
            {gp_note: "T", val_value: 21}]
    },
    {
        go_index: 6,
        go_go_index: 2,
        go_name: "child 4",
        hist_values:[
            {gp_note: "Q", val_value: 1100},
            {gp_note: "T", val_value: 24}]
    }


]

let tree4=[
    {
        go_index: 1,
        go_name: "root 1",
        hist_values:[
            {val_time: "day_1", val_value: 10},
            {val_time: "day_2", val_value: 15}]
    },
    {
        go_index: 3,
        go_go_index: 1,
        go_name: "child 1",
        flag_sum : 1,
        hist_values:[
            {val_time: "day_1", val_value: 9},
            {val_time: "day_2", val_value: 11}]
    },
    {
        go_index: 4,
        go_go_index: 1,
        go_name: "child 2",
        flag_sum : -1,
        hist_values:[
            {val_time: "day_1", val_value: 1},
            {val_time: "day_2", val_value: 4}]
    },
    {
        go_index: 7,
        go_go_index: 4,
        go_name: "grandchild 1",
        flag_sum : 1,
        hist_values:[
            {val_time: "day_1", val_value: 1},
            {val_time: "day_2", val_value: 4}]
    },

    {
        go_index: 2,
        go_name: "root 2",
        hist_values:[
            {val_time: "day_1", val_value: 20},
            {val_time: "day_2", val_value: 25}]
    },
    {
        go_index: 5,
        go_go_index: 2,
        go_name: "child 3",
        flag_sum: 0,
        hist_values:[
            {val_time: "day_1", val_value: 9},
            {val_time: "day_2", val_value: 11}]
    },
    {
        go_index: 6,
        go_go_index: 2,
        go_name: "child 4",
        flag_sum: 1,
        hist_values:[
            {val_time: "day_1", val_value: 11},
            {val_time: "day_2", val_value: 14}]
    },


]



let tree5=[
    {
        go_index: 1,
        go_name: "root 1",
        hist_values:[
            {val_time: "day_1", val_value: 10},
            {val_time: "day_2", val_value: 15}]
    },
    {
        go_index: 3,
        go_go_index: 1,
        go_name: "child 1",
        flag_sum : 1,
        hist_values:[
            {val_time: "day_1", val_value: 9},
            {val_time: "day_2", val_value: 11}]
    },
    {
        go_index: 4,
        go_go_index: 1,
        go_name: "child 2",
        flag_sum : -1,
        hist_values:[
            {val_time: "day_1", val_value: 1},
            {val_time: "day_2", val_value: 4}]
    },
    {
        go_index: 7,
        go_go_index: 4,
        go_name: "grandchild 1",
        flag_sum : 1,
        hist_values:[
            {val_time: "day_1", val_value: 1},
            {val_time: "day_2", val_value: 4}]
    },

    {
        go_index: 2,
        go_name: "root 2",
        hist_values:[
            {val_time: "day_1", val_value: 20},
            {val_time: "day_2", val_value: 25}]
    },
    {
        go_index: 5,
        go_go_index: 2,
        go_name: "child 3",
        flag_sum: 0,
        source_index: 7,
        hist_values:[
            {val_time: "day_1", val_value: 9},
            {val_time: "day_2", val_value: 11}]
    },
    {
        go_index: 6,
        go_go_index: 2,
        go_name: "child 4",
        flag_sum: 1,
        hist_values:[
            {val_time: "day_1", val_value: 11},
            {val_time: "day_2", val_value: 14}]
    },


]




let treeDecoder1={
    treeData:{
        childIndex: "go_index",
        parentIndex: "go_go_index"
    },
    rowData:{
        rowIndexes: ["go_index"], //строковые индексы (т.е., обекты, определяющие строку)
        rowMeta: [], //строковые мета-данные
    },
    columnData:{
        columnDataName: "hist_values", //название для вложенного json с данными о столбцах
        columnMeta:[], //мета-данные столбца
        columnNote: "gp_note" ,//Код для нахождения столбца
        columnIndexes:["gp_index"], //индексы, определяющие столбец
        columnRefreshable: ["val_value", "prev_value"],   //обновляемые поля
        columnValue: "val_value", //Значения для ячейки
        columnService: {          //Служебные значения для ячейки
            cellPlaceholder: "prev_value", //Значения по умолчанию (и источник)
            cellStates: "op_states",     //Откуда брать состояния
            cellControl: "op_control"    //Откуда брать границы
        }
    }
}


let treeDecoder={
    treeData:{
        childIndex: "go_index",
        parentIndex: "go_go_index",
        calcIndex: "flag_sum",
        sourceIndex: "source_index"
    },
    rowData:{
        rowIndexes: ["go_index"], //строковые индексы (т.е., обекты, определяющие строку)
        rowMeta: [], //строковые мета-данные
    },
    columnData:{
        columnDataName: "hist_values", //название для вложенного json с данными о столбцах
        columnMeta:[], //мета-данные столбца
        columnNote: "val_time" ,//Код для нахождения столбца
        columnIndexes:["gp_index"], //индексы, определяющие столбец
        columnRefreshable: ["val_value", "prev_value"],   //обновляемые поля
        columnValue: "val_value", //Значения для ячейки
        columnService: {          //Служебные значения для ячейки
            cellPlaceholder: "prev_value", //Значения по умолчанию (и источник)
            cellStates: "op_states",     //Откуда брать состояния
            cellControl: "op_control"    //Откуда брать границы
        }
    }
}



function tst() {

    let Columns =[
        new RowMetaTextCell({header: "name",sourcefield: "go_name", decoder: treeDecoder}),
        new NotedTreeTableColumn({header: "day_1" }),
        new NotedTreeTableColumn({header: "day_2"}),
        new SumCellFromColumns({header: "Сумма",  noteArr: ["day_1", "day_2"], decoder: treeDecoder})

    ]

    let iTab = new TreeTableCreator({TableMeta: {TableName: "test"}, TableData: tree2,Columns, SaveFunc: ()=>alert(6)}
    )
    iTab.setColumnWidthFromArray([4,1,1]);
    // iTab.defaultTreeMap();
    iTab.renderTable("tabcontainer")


    let Columns1 = [
        new RowMetaTextCell({header: "name",  sourcefield: "go_name", decoder: treeDecoder1}),
        new NotedTreeTableColumn({header:"Q", decoder: treeDecoder1}),
        new DefaultNumberInputCell({header: "T", decoder:treeDecoder1}),
        new CalculatedCellFromColumnsValues({header: "T (Кельвины)",
            calcFunc: x=>x[treeDecoder1.columnData.columnValue]+273.15,
            noteArr: ["T"], decoder: treeDecoder1})
    ]

    let iTab1 = new TreeTableCreator({TableMeta: {TableName: "test1"}, TableData: tree3,
        Columns: Columns1, SaveFunc: ()=>alert(6) , DataCoder:{Decoder: treeDecoder1, Encoder: DefaultEncoder}}
    )
    iTab1.setColumnWidthFromArray([4,1,1]);
    iTab1.renderTable("tabcontainer1")


    let Columns2 =[
        new RowMetaTextCell({header: "name",  sourcefield: "go_name", decoder: treeDecoder}),
        new NotedTreeTableColumn({header: "day_1" }),
        new NotedTreeTableColumn({header: "day_2"}),
        new SumCellFromColumns({header: "Сумма",  noteArr: ["day_1", "day_2"], decoder: treeDecoder})

    ]

    iTab2 = new TreeTableCreator({TableMeta: {TableName: "test1"}, TableData: tree4,
        Columns: Columns2, SaveFunc: ()=>alert(6) });


    iTab2.setColumnWidthFromArray([4,1,1]);

    iTab2.renderTable("tabcontainer2")




    let Columns3 =[
        new RowMetaTextCell({header: "name",  sourcefield: "go_name", decoder: treeDecoder}),
        new NotedTreeTableColumn({header: "day_1" }),
        new NotedTreeTableColumn({header: "day_2"}),
        new SumCellFromColumns({header: "Сумма",  noteArr: ["day_1", "day_2"], decoder: treeDecoder})

    ]

    iTab3 = new SourcedTreeTableCreator({TableMeta: {TableName: "test1"}, TableData: tree5,
        Columns: Columns3, SaveFunc: ()=>alert(6) });


    iTab3.setColumnWidthFromArray([4,1,1]);

    iTab3.renderTable("tabcontainer3")

}


function tab3Refresh(){
    iTab3.recalcTree();
}

function tab2Refresh(){
    iTab2.recalcTree();
}







