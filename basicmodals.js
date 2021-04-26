function Modal(headerText, bodyText, cancelText, confirmText, confirmFunc){
    this.headerText=headerText;
    this.bodyText = bodyText;
    this.cancelText = cancelText;
    this.confirmText = confirmText;
    this.confirmFunc = confirmFunc;
}

function setInfoModal(m){
    document.getElementById("modalinfo-header").lastChild.nodeValue = m.headerText;
    document.getElementById("modalinfo-body").firstChild.nodeValue = m.bodyText;
    document.getElementById("modalinfo-cancellbutton").firstChild.nodeValue = m.cancelText;
}

function setSuccessInfoModal(bodyText) {
    setInfoModal(new Modal("Успешно", bodyText, "OK"))
    document.getElementById("modalinfo-divheader").style.background='darkseagreen'
}

function setFailureInfoModal(bodyText) {
    setInfoModal(new Modal("Ошибка", bodyText, "OK"))
   document.getElementById("modalinfo-divheader").style.background='red'

}

/*
function setConfirmModal(m){
    document.getElementById("modalinfo-header").firstChild.text = m.headerText;
    document.getElementById("modalinfo-body").firstChild.text = m.bodyText;
    document.getElementById("modalinfo-cancellbuttonr").value = m.cancelText;
}
*/

