import QtQml

QtObject {
    id: provider

    property string curH: "00"
    property string curM: "00"
    property string curS: "00"
    property real curSecondFloat: 0
    property real curMinuteFloat: 0
    readonly property int curSecond: Number(curS)
    readonly property int curMinute: Number(curM)

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
        syncTick();
    }

    function tickSmooth() {
        var d = new Date();
        curSecondFloat = d.getSeconds() + d.getMilliseconds() / 1000;
        curMinuteFloat = d.getMinutes() + curSecondFloat / 60;
    }

    // Re-plan the hard tick exactly at the next whole second.
    function syncTick() {
        tickTimer.interval = 1000 - new Date().getMilliseconds();
        tickTimer.start();
    }

    Component.onCompleted: {
        update();
        syncTick();
    }
}
