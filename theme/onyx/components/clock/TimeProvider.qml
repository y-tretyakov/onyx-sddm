import QtQml

QtObject {
    id: provider

    property string curH: "00"
    property string curM: "00"
    property string curS: "00"
    readonly property int curMinute: Number(curM)
    readonly property string curTime: curH + ":" + curM
    property real curSecondFloat: 0

    property Timer tickTimer: Timer {
        repeat: false
        onTriggered: provider.update()
    }

    property Timer smoothTimer: Timer {
        interval: 16
        repeat: true
        running: true
        onTriggered: provider.tickSmooth()
    }

    function _pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    function update() {
        var d = new Date();
        curH = _pad(d.getHours());
        curM = _pad(d.getMinutes());
        curS = _pad(d.getSeconds());
    }

    function tickSmooth() {
        var d = new Date();
        curSecondFloat = d.getSeconds() + d.getMilliseconds() / 1000;
    }

    // Перепланирование тика ровно на начало следующей целой секунды.
    function syncTick() {
        tickTimer.interval = 1000 - new Date().getMilliseconds();
        tickTimer.start();
    }

    Component.onCompleted: {
        update();
        syncTick();
    }
}
