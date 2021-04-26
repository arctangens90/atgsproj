

///МОДУЛЬ В РАЗРАБОТКЕ, РАЗДЕЛЕНИЕ НА ФАЙЛЫ И ПОДРОБНЫЕ КОММЕНТАРИИ ПОЯВЯТСЯ ПОЗДНЕЕ



let DefaultTableStyles={
    Header:{
        HeaderClass : ["table", "table-striped", "table-hover", "table-condensed", "table-bordered"],
        CaptionStyle : "text-align:center;background: gray;color: white;"
    },
    Body:{
        BodyClass : ["table", "table-striped", "table-hover", "table-condensed", "table-bordered"]
    },
    Footer:{
        FooterClass : ["table", "table-striped", "table-hover", "table-condensed", "table-bordered"]
    },
    SaveButton:{
        ButtonDiv: ["form-group", "mt-6"],
        ButtonClass: ["btn", "btn-warning"],
        ButtonIcon: ["glyphicon", "glyphicon-send"]
    }
}


//Декодер-- объект для чтения json-a из БД, с пониманием, какое поле за что отвечает
//По умолчанию декодер настроен на числовые данные

let DefaultDecoder={
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
        columnPrevValue: "prev_value", //Предыдущее значение
        columnService: {          //Служебные значения для ячейки
            cellPlaceholder: "prev_value", //Значения по умолчанию (и источник)
            cellStates: "op_states",     //Откуда брать состояния
            cellControl: "op_control"    //Откуда брать границы
        }
    }
}

//Энкодер нужен для сохранения данных
let DefaultEncoder ={
    rowIndexes: ["go_index"],
    columnIndexes: ["gp_index", "val_value"],
    metaValues: [{
        int_name: "val_time",
        ext_name: "HistTime"
    }]
}


////КЛАССЫ ДЛЯ СОЗДАНИЯ СТОЛБЦОВ. ОБЩЕЕ ОПИСАНИЕ

class TableColumn{
    constructor({header, cellStyle=()=>{}}) {
        this.header = header;
        this.cellStyle = cellStyle;
    }
    createCell(){
        let cell = document.createElement('td');
        this.cellStyle(cell);
        return cell;
    }
}




class TreeTableColumn extends TableColumn {
    constructor({header, cellStyle=()=>{}, sourceFunc ,childFunc, treeFunc=()=>false, decoder = DefaultDecoder}) {
        super({header, cellStyle})
        this.sourceFunc = sourceFunc;
        this.childFunc = childFunc;
        this.treeFunc = treeFunc;
        this.decoder = decoder;
    }

    createCell(node, tree) {
        let cell = super.createCell();
        cell.appendChild(this.childFunc(this.sourceFunc(node), this.treeFunc(node, tree)));
        return cell;
    }
}


class NotedTreeTableColumn extends TreeTableColumn {
    constructor({header, cellStyle, note=header, decoder=treeDecoder}) {
        super({header, cellStyle, sourceFunc:  obj => findSourceByNote(obj, this.decoder, note),
            childFunc:
                (valObj, isCalculated) => {
                    let cellinput = createInputCell(valObj, "number", this.decoder);
                    setDefaultInputNumberCellSettings(cellinput, valObj, this.decoder);
                    if (isCalculated) cellinput.readOnly=true;
                    return cellinput;
                },
            treeFunc:
                (node, tree)=> {
                    let {parentIndex, childIndex, sourceIndex} =this.decoder.treeData
                    return tree.map(x=>x[parentIndex]).includes(node[childIndex]) ||
                        tree.map(x=>x[childIndex]).includes(node[sourceIndex])
                }
            , decoder
        })
        this.note = note;
    }

}

class NotedTreeFreeTableColumn extends NotedTreeTableColumn{
    constructor(header, cellStyle, note, decoder) {
        super({header, cellStyle, note, decoder})
        this.treeFunc = ()=>false;
    }

}




class DataTableColumn extends TableColumn{
    constructor({header, cellStyle=()=>{}, sourceFunc=obj=>obj, childFunc, nodataFunc=()=>{},decoder=DefaultDecoder}) {
        super({header, cellStyle});
        this.decoder = decoder;
        this.sourceFunc= sourceFunc;
        this.childFunc = childFunc;
        this.nodataFunc = nodataFunc;

    }

    createCell(obj){
        let cell;

        if (this.sourceFunc(obj) != null){
            cell = super.createCell();
            cell.appendChild(this.childFunc(this.sourceFunc(obj)));

        }else{
            cell = document.createElement('td');
            this.nodataFunc(cell);
        }
        return cell;
    }

}







////КЛАССЫ ЖДЯ СОЗДАНИЯ СТОЛБЦОВ. РЕАЛИЗПЦИЯ

//Текствовое поле, заданнное по умолчанию
class SimpleTextCell extends DataTableColumn {
    constructor({header, cellStyle=()=>{}, itext, decoder = DefaultDecoder}) {
        super({header, cellStyle, childFunc:
                ()=> {
                    return document.createTextNode(itext);
                }, decoder})
    }
}




//Текствовое поле, заданнное по умолчанию. Источник внутри строки.
class RowMetaTextCell extends DataTableColumn {
    constructor({header, cellStyle=()=>{}, sourcefield, decoder = DefaultDecoder}) {
        super({header, cellStyle, childFunc:
                valObj => {
                    return document.createTextNode(valObj[sourcefield]);
                }, decoder})
    }
}

//Текстовое поле, привязанное к мета-данным заданного столбца.
class ColumnMetaTextCell extends DataTableColumn{
    constructor ({header, cellStyle=()=>{}, sourcefield, note, decoder=DefaultDecoder}) {
        super({header, cellStyle, sourceFunc: obj => findSourceByNote(obj, this.decoder, note),
            childFunc: valObj => {
                return document.createTextNode(valObj[sourcefield]);
            }, decoder})
    }
}


//Текстовое поле, привязанное к изменяемым данным заданного столбца.
class ColumnValueTextCell extends DataTableColumn {
    constructor({header, cellStyle=()=>{}, sourcefield, note, decoder = DefaultDecoder}) {
        super({header, cellStyle, sourceFunc: obj => findSourceByNote(obj, this.decoder, note),
            childFunc: valObj => {
                let textRow = document.createTextNode(valObj[sourcefield]);
                associateObj2Cell(textRow, valObj, () => {
                    textRow.nodeValue = valObj[sourcefield]
                });
                return textRow;
            }, decoder})
    }
}

class NotedValueColumn extends DataTableColumn{
    constructor({header, cellStyle=()=>{}, sourceFunc=obj=>obj, childFunc, nodataFunc=()=>{} , note=header,
                    decoder=DefaultDecoder}){
        super({header, cellStyle, sourceFunc, childFunc, nodataFunc , decoder})
        this.columnNote = note
    }
}

class DefaultNumberInputCell extends NotedValueColumn {
    constructor({header, note=header, decoder = DefaultDecoder}) {
        super({header,
            sourceFunc: obj  => findSourceByNote(obj, this.decoder, note),
            childFunc: valObj=> {
                let cellinput = createInputCell(valObj, "number", this.decoder);
                setDefaultNumberPlaceholder(cellinput, valObj, this.decoder)
                setDefaultInputNumberCellSettings(cellinput, valObj, this.decoder);
                return cellinput;
            }, note, decoder});
    }
}

function DictNumberInputCell(header, cellStyle, sourcepath,  decoder=DefaultDecoder){
    return new DataTableColumn(header, cellStyle,
        (obj, decoder)=> findSourceByNote(obj, decoder, sourcepath.note),
        (valObj, decoder)=>{
            let cellinput
        },
        ()=>{},  decoder)
}

class NumberInputCellWithButton extends NotedValueColumn{
    constructor({header, cellStyle=()=>{},  note,  decoder=DefaultDecoder}) {
        super({header, cellStyle,
            sourceFunc: obj => findSourceByNote(obj, this.decoder, note),
            childFunc: valObj =>{
                let div = document.createElement('div');
                div.className="input-group";

                let cellinput = createInputCell(valObj, "number", this.decoder);
                setDefaultInputNumberCellSettings(cellinput, valObj, this.decoder);
                div.appendChild(cellinput);

                let placeholder = decoder.columnData.columnService.cellPlaceholder
                if (valObj[placeholder]){
                    div.appendChild(createPrevValueButton(cellinput, valObj, this.decoder));
                }
                associateObj2Cell(div, valObj,()=>{
                    if ((valObj[placeholder]) && (!div.lastChild.onclick)) {
                        div.appendChild(createPrevValueButton(cellinput, valObj, this.decoder));
                    }else if (((!valObj[placeholder]) && (div.lastChild.onclick)) ){
                        div.removeChild(div.lastChild);
                    }
                } )
                return div;
            },
            nodataFunc: c=>{let blockedInput = createDefaultBlockedInput();
                c.appendChild(blockedInput)}, note, decoder})
    }
}

class DefaultSelectCell extends NotedValueColumn{
    constructor({header, note, decoder=DefaultDecoder}) {
        super({header,
            sourceFunc: obj=> findSourceByNote(obj, this.decoder, note),
            childFunc: valObj=>{
                let cellinput = createSelectCell(valObj, this.decoder);
                setDefaultSelectCellSettings(cellinput,valObj, this.decoder);
                return cellinput;
            },
            nodataFunc: c=>{let blockedInput = createDefaultBlockedInput();
                c.appendChild(blockedInput)}}, note, decoder);
    }

}


class CalculatedTableCell extends DataTableColumn {
    constructor({header, cellStyle=()=>{},  calcFunc, decoder=DefaultDecoder}){
        super({header, cellStyle,
            childFunc: obj=>{
                let cellinput = createDefaultBlockedInput();
                cellinput.type = "number";
                associateObj2Cell(cellinput, obj, ()=>{cellinput.value = calcFunc(obj, this.decoder)})
                return cellinput;
            },  decoder})
    }
}


class CalculatedCellFromColumns extends CalculatedTableCell{
    constructor({header, cellStyle=()=>{}, funcObj, decoder=DefaultDecoder}){
        super({header, cellStyle, calcFunc: obj =>{
                return funcObj.f(...funcObj.noteObj.map(x=>(findSourceByNote(obj, this.decoder, x.noteValue))[x.noteField]))
            }, decoder})
    }
}


class CalculatedCellFromColumnsValues extends CalculatedCellFromColumns{
    constructor({header, cellStyle=()=>{}, calcFunc, noteArr, decoder=DefaultDecoder}){
        super({header, cellStyle,  funcObj: {f:calcFunc, noteObj: noteArr.map(x=>{return {
                    noteValue: x,
                    noteField: decoder.columnData.columnValue
                }})
            }, decoder})
    }
}




class SumCellFromColumns extends CalculatedCellFromColumnsValues {
    constructor({header, cellStyle=()=>{}, noteArr, decoder=DefaultDecoder}){
        super({header, cellStyle, calcFunc: (...objArr)=>{
                return objArr.reduce((sum,x)=>sum+x??0,0);
            } , noteArr, decoder})
    }
}


class MinCellFromColumns extends CalculatedCellFromColumnsValues {
    constructor({header, cellStyle=()=>{}, noteArr, decoder=DefaultDecoder}){
        super({header, cellStyle, calcFunc: (...objArr)=>{
                return objArr.reduce((min,x)=>min > (x??Infinity)? x:min, Infinity);
            } , noteArr, decoder})
    }
}


//ВСПОМОГАТЕЛЬНЫЕ КОМПОНЕНТЫ ДЛЯ ЯЧЕЕК

function createPrevValueButton(cellinput, valObj, decoder){
    let placeholder = decoder.columnData.columnService.cellPlaceholder
    let btn = document.createElement("span");
    btn.className="input-group-addon";

    let btext =document.createTextNode(valObj[placeholder]);
    associateObj2Cell(btext, valObj, ()=>{
        btext.value = valObj[placeholder] }
    );
    btn.appendChild(btext);
    btn.onclick = ()=>{cellinput.value = valObj[placeholder];
        cellinput.onchange();
    };
    return btn;
}



//ФУНКЦИИ ДЛЯ КАСТОМИЗАЦИИ ЯЧЕЕК

function setDefaultInputNumberCellSettings(cellinput, valObj, decoder){
    cellinput.className = "form-control";
    associateObj2Cell(cellinput, valObj, ()=>{setCellValueFromObj(cellinput, valObj, decoder);
        setDefaultNumberPlaceholder(cellinput, valObj, decoder )});
    associateCell2Obj(cellinput, valObj,()=>{
        defaultNumberEvents(cellinput, valObj, decoder);
        setObjValueFromCell(cellinput, valObj, decoder);
    } )
}

function setDefaultSelectCellSettings(cellinput, valObj, decoder){
    cellinput.className = "form-control";
    associateCell2Obj(cellinput, valObj, ()=>setObjValueFromCell(cellinput, valObj, decoder) );
    associateObj2Cell(cellinput, valObj, ()=>setCellValueFromObj(cellinput, valObj, decoder));
}

function setDefaultNumberPlaceholder(cellinput, valObj, decoder){
    let placeholder = decoder.columnData.columnService.cellPlaceholder
    cellinput.placeholder = (valObj[placeholder] )? valObj[placeholder]: "";
}

function setObjValueFromCell(cellinput, sourceObj, decoder){
    sourceObj[decoder.columnData.columnValue] = Number(cellinput.value)
}

function setCellValueFromObj(cellinput, sourceObj, decoder){
    cellinput.value = sourceObj[decoder.columnData.columnValue];
}

function associateObj2Cell (cellinput, obj, associateFunc){
    if (!obj.associateMap){
        obj.associateMap=[];
    }
    obj.associateMap.push(new Association( cellinput, associateFunc, "cell"))
}

function associateObj2Header(headercell, obj, associateFunc){
    if (!obj.associateMap){
        obj.associateMap=[];
    }
    obj.associateMap.push(new Association( headercell, associateFunc, "header"))
}

function associateCell2Obj(cellinput, obj, associateFunc){
    cellinput.onchange = function(){
        obj.isChanged = true;
        associateFunc(cellinput, obj);
        recalcParent(obj)
    }
}


function defaultNumberEvents(cellinput, sourceObj, decoder){
    checkBorders(cellinput, sourceObj[decoder.columnData.columnService.cellControl])
}

function checkBorders(obj, borders) {
    try {
        obj.style.background = (obj.value < (Number(borders?.min_value ?? -Infinity))) ||
        (obj.value > (Number(borders?.max_value ?? Infinity))) ? 'red' : null
    }catch{}
}

function setBlockedCellinput(cellinput){
    cellinput.style.background="#a9a9a9";
    cellinput.readonly = true
}

//АССОЦИАЦИЯ
function Association(sourceObj, sourceFunc, associateType){
    this.sourceObj = sourceObj;
    this.sourceFunc = sourceFunc;
    this.associateType = associateType;
}

function recalcAssociationByType(obj, associateType){
    if(obj.associateMap)
        obj.associateMap.filter(f=>f.associateType == associateType).forEach(f=>f.sourceFunc());
}

function recalcParent(obj){
    recalcAssociationByType(obj, "parent")
}

function recalc(obj){
    recalcAssociationByType(obj, "cell")
}

function showSource(obj){
    recalcAssociationByType(obj, "source")
}

function associate(obj){
    if(obj.associateMap)
        obj.associateMap.forEach(f=>f.sourceFunc());
}




//СОЗДАНИЕ ЭЛЕМЕНТОВ

function createStyledElement(tagName, StyleFunc){
    let el = document.createElement(tagName);
    StyleFunc(el);
    return el;
}

function createClassedElement(tagName, cssClassList){
    return createStyledElement(tagName, el=>el.className=cssClassList.join(" "));
}

function createDefaultBlockedInput() {
    let cellinput = document.createElement('input');
    cellinput.className = "form-control";
    cellinput.readOnly = true
    return cellinput;
}


function createInputCell(sourceObj, inputType, decoder){
    let cellinput = document.createElement('input');
    cellinput.type= inputType;
    cellinput.value = sourceObj[decoder.columnData.columnValue];
    return cellinput;
}



function createSelectCell(sourceObj, decoder){
    let cellselect = document.createElement('select');
    let statelist = sourceObj[decoder.columnData.columnService.cellStates]
    addOption(cellselect, "", -1)
    for (let state in statelist ){
        addOption(cellselect, statelist[state], state, null, null,
            sourceObj[decoder.columnData.columnValue]==state )
    }
    return cellselect;
}





//ПРОЧИЕ СЛУЖЕБНЫЕ ФУНКЦИИ

function findSourceByNote(obj, decoder, note){
    return obj[decoder.columnData.columnDataName].find(v => v?.[decoder.columnData.columnNote] === note);
}


function part2Percents(partArr){
    let sum = partArr.reduce((sum,x)=>sum+x,0);
    return partArr.map(x=>x*100/sum);
}






//Возможно, переделать в класс

class TabCreator {
    constructor({   TableMeta,
                    TableData,
                    Columns,
                    SaveFunc,
                    TableStyle = DefaultTableStyles,
                    DataCoder = {
                        Decoder: DefaultDecoder,
                        Encoder: DefaultEncoder},
                    GroupRows = {
                        initRow: () => {
                        },
                        contentRow: () => {
                        },
                        footRow: () => {
                        }
                    }
                }) {
        this.TableMeta = TableMeta;
        this.TableData = TableData;
        this.Columns = Columns;
        this.SaveFunc = SaveFunc;
        this.TableStyle = TableStyle;
        this.DataCoder = DataCoder;
        this.GroupRows = GroupRows;
        let{columnData:{columnDataName, columnNote, columnValue, columnIndexes, columnRefreshable, columnPrevValue},
            rowData:{rowIndexes}} = this.DataCoder.Decoder

        this.setColumnWidthFromArray = function (arr) {
            this.Columns.forEach((col, i) => col.columnWidth = arr[i] ?? 1)
        }

        this.createTableHeader = function () {
            let containerHead = createClassedElement("div", ["table-container-header"]);
            let theadTable = createClassedElement("table", this.TableStyle.Header.HeaderClass);
            let caption = createStyledElement("caption", c => c.style = this.TableStyle.Header.CaptionStyle);
            //caption.style = this.TableStyle.Header.CaptionStyle;
            let theader = document.createElement("thead");

            theader.appendChild(this.createHeaderRow());
            caption.appendChild(document.createTextNode(this.TableMeta.TableName))
            theadTable.appendChild(caption);
            theadTable.appendChild(theader);
            containerHead.appendChild(theadTable);
            this.outerContainer.appendChild(containerHead);
        };

        this.createHeaderRow = function () {
            let headerrow = document.createElement('tr');
            this.Columns.map(h => h.header).forEach((h) => {
                let th = document.createElement('th')
                th.appendChild(document.createTextNode(h));
                headerrow.appendChild(th)
            })
            return headerrow;
        };


        this.createTableBody = function () {
            let containerBody = createClassedElement("div", ["table-container-body"]);
            let tbodyTable = createClassedElement("table", this.TableStyle.Body.BodyClass);
            let tbody = document.createElement('tbody');

            tbodyTable.appendChild(this.createColgroup());
            this.createTableBodyRows(tbody);
            tbodyTable.appendChild(tbody);
            containerBody.appendChild(tbodyTable);
            this.outerContainer.appendChild(containerBody);
        }


        this.createColgroup = function () {
            let cg = document.createElement("colgroup");
            (part2Percents(this.Columns.map(c => c?.columnWidth ?? 1))).forEach(w => {
                let col = createStyledElement("col", c => c.style = "width: " + Math.round(w).toString() + "%;");
                cg.appendChild(col);
            })
            return cg
        }


        this.createTableBodyRows = function (tbody) {
            this.GroupRows.initRow(tbody);
            this.TableData.forEach((rowObj, j, arr) => {
                this.GroupRows.contentRow(tbody, rowObj, j, arr);
                let row = document.createElement('tr')
                this.Columns.forEach(h => {
                    let cell = h.createCell(rowObj, arr);
                    row.appendChild(cell);
                });
                tbody.appendChild(row);
            })
            this.GroupRows.footRow(tbody);
        }

        this.createTableFooter = function () {
            let containerFooter = createClassedElement("div", ["table-container-footer"]);
            let tfooterTable = createClassedElement("table", this.TableStyle.Footer.FooterClass);
            let tfooter = document.createElement('tfoot');

            tfooter.appendChild(this.createHeaderRow());
            tfooterTable.appendChild(tfooter);
            containerFooter.appendChild(tfooterTable);
            this.outerContainer.appendChild(containerFooter);
        }


        this.createTable = function () {
            this.createAssociationMap();
            this.outerContainer = createClassedElement("div", ["table-container"]);
            this.createTableHeader();
            this.createTableBody();
            this.createTableFooter();
        }

        this.createSaveButton = function () {
            let buttonDiv = createClassedElement("div", this.TableStyle.SaveButton.ButtonDiv);
            let saveButton = createClassedElement("button", this.TableStyle.SaveButton.ButtonClass);
            let saveSpan = createClassedElement("span", this.TableStyle.SaveButton.ButtonIcon);
            saveButton.onclick = () => this.SaveFunc(this.unrollTableData.bind(this));

            saveButton.appendChild(document.createTextNode("Send"));
            saveButton.appendChild(saveSpan);
            buttonDiv.appendChild(saveButton);
            return buttonDiv;
        }

        this.renderTable = function (containername) {
            this.createTable();
            this.Refresh();
            document.getElementById(containername).appendChild(this.outerContainer);
            document.getElementById(containername).appendChild(this.createSaveButton());
            correctTableStyle();
        }

        this.unrollTableData = function () {
            return this.TableData.reduce((conc, i) => conc.concat(
                i[columnDataName].filter(s => s.isChanged).map(m => {
                    let obj = {};
                    this.DataCoder.Encoder.rowIndexes.forEach(r => obj[r] = i[r]);
                    this.DataCoder.Encoder.columnIndexes.forEach(r => obj[r] = m[r]);
                    this.DataCoder.Encoder.metaValues.forEach(r => obj[r.int_name] = this.TableMeta[r.ext_name]);
                    return obj;
                })
            ), []);

        }

        this.Refresh = function () {
            this.TableData.forEach(obj => {
                obj[columnDataName].forEach(obj => {
                    recalc(obj);
                    obj.isChanged = false
                });
                recalc(obj);
            });
            recalc(this.TableData);
        }


        this.FillByPrevious = function () {
            this.TableData.forEach(obj => obj[columnDataName].forEach(h => {
                h[columnValue] = h[columnPrevValue]
            }));
            this.Refresh()
        }

        this.FillByJSON = function (extObj) {
            this.TableData.forEach(obj => {
                let extRow = extObj.find(t => rowIndexes.reduce((cond, x) => cond && t[x] === obj[x], true));
                obj[columnDataName].forEach(h => {
                    let extColumn = extRow[columnDataName].find(t => columnIndexes
                        .reduce((cond, x) => cond && t[x] === h[x], true))
                    columnRefreshable.forEach(x => h[x] = extColumn[x]);
                })
            });
            this.Refresh()
        }

        this.createBasicAssociationMap = function () {
            this.TableData.forEach(r => {
                r.associateMap = [new Association(this.TableData, () => associate(this.TableData), "parent")]
                r[columnDataName].forEach(c => {
                    c.associateMap = [new Association(r, () => associate(r), "parent")];
                })
            })
        }

        this.createAssociationMap=this.createBasicAssociationMap;
    }
}


class TreeTableCreator extends TabCreator{
    constructor({   TableMeta,
                    TableData,
                    Columns,
                    SaveFunc,
                    TableStyle = DefaultTableStyles,
                    DataCoder = {
                        Decoder: treeDecoder,
                        Encoder: DefaultEncoder},
                    GroupRows = {
                        initRow: () => {
                        },
                        contentRow: () => {
                        },
                        footRow: () => {
                        }
                    }
                }) {
        super({
            TableMeta,TableData, Columns, SaveFunc, TableStyle, DataCoder , GroupRows}
        );

        let{columnData:{columnDataName, columnNote, columnValue, columnIndexes, columnRefreshable, columnPrevValue},
            rowData:{rowIndexes}, treeData:{childIndex, parentIndex, sourceIndex, calcIndex} } = this.DataCoder.Decoder

        this.createTreeAssociationMap = function (calcTreeFunc) {

            let treeColumns = this.Columns.filter(x => x instanceof NotedTreeTableColumn).map(z => z.note)

            this.TableData.forEach((r, i, arr) => {
                arr.filter(x => x[parentIndex] === r[childIndex]).forEach((y, j, filtArr) => {
                    y.associateMap.push(new Association(y, () => {
                        r[columnDataName].filter(v => treeColumns.includes(v[columnNote])).forEach(t => {
                            t[columnValue] = calcTreeFunc(filtArr, t[columnNote])
                        });
                        r[columnDataName].forEach(x => associate(x))
                        associate(r)
                    }, "parent"))
                })
            })
        }

        this.createAssociationMap = function () {
            this.createBasicAssociationMap();
            this.createTreeAssociationMap((arr, note) => {
                let res = arr.map(a => {
                    return {
                        flagsum: a[calcIndex] ?? 1,
                        hist: a[columnDataName].find(x => x[columnNote] === note)
                    }
                })
                    .reduce((sum, i) => sum = sum + i.flagsum * (i.hist)[columnValue], 0);
                return res;
            })
        }

        this.recalcTree = function () {
            this.TableData.filter((x, i, arr) => !(arr.map(m => m[parentIndex]).includes(x[childIndex]))).forEach(x => recalcParent(x))
        }


    }

}


class SourcedTreeTableCreator extends TreeTableCreator{
    constructor({   TableMeta,
                    TableData,
                    Columns,
                    SaveFunc,
                    TableStyle = DefaultTableStyles,
                    DataCoder = {
                        Decoder: treeDecoder,
                        Encoder: DefaultEncoder},
                    GroupRows = {
                        initRow: () => {
                        },
                        contentRow: () => {
                        },
                        footRow: () => {
                        }
                    }
                }) {
        super({
            TableMeta, TableData, Columns, SaveFunc, TableStyle, DataCoder, GroupRows}
        );

        let{columnData:{columnDataName, columnNote, columnValue, columnIndexes, columnRefreshable, columnPrevValue},
            rowData:{rowIndexes}, treeData:{childIndex, parentIndex, sourceIndex, calcIndex} } = this.DataCoder.Decoder

        this.recalcTree = function () {
            this.TableData.filter((x, i, arr) => !(arr.map(m => m[parentIndex]).includes(x[childIndex])) &&
                !(arr.map(m => m[childIndex]).includes(x[sourceIndex]))).forEach(x => recalcParent(x))
        }

        this.createSourcedTreeAssociationMap = function (calcTreeFunc) {
            let treeColumns = this.Columns.filter(x => x instanceof NotedTreeTableColumn).map(z => z.note)

            let associateParent = function (childObj, parentObj, calcFunc) {
                childObj.associateMap.push(new Association(parentObj, () => {
                    parentObj[columnDataName].filter(v => treeColumns.includes(v[columnNote])).forEach(t => {
                        t[columnValue] = calcFunc(t[columnNote])
                    });
                    parentObj[columnDataName].forEach(x => associate(x))
                    associate(parentObj)
                }, "parent"));
            }.bind(this)

            this.TableData.forEach((r, i, arr) => {
                let sourceObj = arr.find(x => x[childIndex] == r[sourceIndex]);
                if (sourceObj) {
                    associateParent(sourceObj, r, t => sourceObj[columnDataName]
                        .find(x => x[columnNote] == t)[columnValue])
                } else {
                    arr.filter(x => x[parentIndex] === r[childIndex]).forEach((y, j, filtArr) =>
                        associateParent(y, r, t => calcTreeFunc(
                            filtArr.map(a => {
                                return {
                                    flagsum : a[calcIndex] ?? 1,
                                    hist: a[columnDataName].find(x => x[columnNote] === t)
                                }

                            })))
                    )
                }
            })
        }

        this.createAssociationMap = function () {
            this.createBasicAssociationMap();
            this.createSourcedTreeAssociationMap(arr => {
                return arr.reduce((sum, i) => sum = sum + i.flagsum*(i.hist)[columnValue], 0);
            })
        }

    }
}


class shablonTree extends SourcedTreeTableCreator {
    constructor({
                    TableMeta,
                    TableData,
                    Columns,
                    SaveFunc,
                    TableStyle = DefaultTableStyles,
                    DataCoder = {
                        Decoder: treeDecoder,
                        Encoder: DefaultEncoder
                    },
                    GroupRows = {
                        initRow: () => {
                        },
                        contentRow: () => {
                        },
                        footRow: () => {
                        }
                    }
                }) {
        super({
                TableMeta, TableData, Columns, SaveFunc, TableStyle, DataCoder, GroupRows
            }
        );
        let{columnData:{columnDataName, columnNote, columnValue, columnIndexes, columnRefreshable, columnPrevValue},
            rowData:{rowIndexes}, treeData:{childIndex, parentIndex, sourceIndex, calcIndex, showIndex} } = this.DataCoder.Decoder


        this.createTableBodyRows = function (tbody) {
            this.GroupRows.initRow(tbody);
            //this.TableData.filter(x=>x[showIndex]??1===1).forEach((rowObj, j, arr) => {
            this.TableData.forEach((rowObj, j, arr) => {
                this.GroupRows.contentRow(tbody, rowObj, j, arr);
                let row = document.createElement('tr')
                this.Columns.forEach(h => {
                    let cell = h.createCell(rowObj, arr);
                    row.appendChild(cell);
                });
                tbody.appendChild(row);
            })
            this.GroupRows.footRow(tbody);
        }
    }
}








function createResultRow(rowStyle,  columnResFuncs, container){
    let row = createStyledElement('tr', rowStyle)
    this.Columns.forEach( (h,i)=> {
        let cell = document.createElement('td');
        if (columnResFuncs[i] != null) {
            if (h instanceof NotedValueColumn) {
                cellinput = createCalculatedRowCell.bind(this)(columnResFuncs[i], h.columnNote)
                cell.appendChild(cellinput);
            } else {
                cell.appendChild(document.createTextNode(columnResFuncs[i]()))
            }
        }
        row.appendChild(cell);
    })
    container.appendChild(row)
}

function createCalculatedRowCell(f, note){
    let cellinput = createDefaultBlockedInput();
    associateObj2Cell(cellinput, this.TableData, () => {
        let res = f(this.TableData.map(x =>
            findSourceByNote(x, this.DataCoder.Decoder, note)[this.DataCoder.Decoder.columnData.columnValue]
        ))
        cellinput.value = res;
    })
    return cellinput;
}


function correctTableStyle() {
    var $body = $(".table-container-body"),
        $header = $(".table-container-header"),
        $footer = $(".table-container-footer");

// Get ScrollBar width
    var scrollBarWidth = (function () {
        var inner = $('<p/>').addClass('fixed-table-scroll-inner'),
            outer = $('<div/>').addClass('fixed-table-scroll-outer'),
            w1, w2;
        outer.append(inner);
        $('body').append(outer);
        w1 = inner[0].offsetWidth;
        outer.css('overflow', 'scroll');
        w2 = inner[0].offsetWidth;
        if (w1 === w2) {
            w2 = outer[0].clientWidth;
        }
        outer.remove();
        return w1 - w2;
    })();

// Scroll horizontal
    $body.on('scroll', function () {
        $header.scrollLeft($(this).scrollLeft());
        $footer.scrollLeft($(this).scrollLeft());
    });

// Redraw Header/Footer
    var redraw = function () {
        var tds = $body.find("> table > tbody > tr:first-child > td");
        tds.each(function (i) {
            var width = $(this).innerWidth(),
                lastPadding = (tds.length - 1 == i ? scrollBarWidth : 0);
            lastHeader = $header.find("th:eq(" + i + ")").innerWidth(width + lastPadding);
            lastFooter = $footer.find("th:eq(" + i + ")").innerWidth(width + lastPadding);
        });
    };

// Selection
    $body.find("> table > tbody > tr > td").click(function (e) {
        $body.find("> table > tbody > tr").removeClass("info");
        $(e.target).parent().addClass('info');
    });

// Listen to Resize Window
    $(window).resize(redraw);
    redraw();
}


function showJSON(){
    alert(JSON.stringify(tree2.map(x=>x.associateMap.map(y=>y.associateType))))
}






