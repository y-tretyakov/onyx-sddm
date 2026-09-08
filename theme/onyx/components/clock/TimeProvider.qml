import QtQuick

QtObject {
    id: provider

    property string curH: "00"
    property string curM: "00"
    property string curS: "00"
    readonly property string curTime: curH + ":" + curM

    function _pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    function update() {
        var d = new Date();
        curH = _pad(d.getHours());
        curM = _pad(d.getMinutes());
        curS = _pad(d.getSeconds());
    }

    Component.onCompleted: update()
}
