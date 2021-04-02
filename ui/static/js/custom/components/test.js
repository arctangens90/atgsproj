const COLOR_RED = "#F00";
const COLOR_ORANGE = "#FF7F00";
const COLOR_WHITE ="#FFFFFF"
let testbord = {ErrMin: -15, WarnMin: -10, WarnMax: 10, ErrMax:15}
let ijs =  JSON.stringify(testbord)



function  ColorObj(val, Borders){
   if (Borders.ErrMin>Borders.WarnMin |Borders.ErrMax<Borders.WarnMax||Borders.WarnMin>Borders.WarnMax)
      return COLOR_WHITE;
   return val<Borders.ErrMin||val>Borders.ErrMax ? COLOR_RED:
            val<Borders.WarnMin||val>Borders.WarnMax ? COLOR_ORANGE:
                COLOR_WHITE;
}

function DrawColorObj(obj, val, Borders){
   obj.style.background = ColorObj(val, Borders)
}




