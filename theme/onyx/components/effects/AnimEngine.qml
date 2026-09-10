import QtQml

QtObject {
    id: engine

    property bool animationEnabled: true
    property bool clockAwake: true

    property real windupOffset: 0
    readonly property real windupProgress: windupOffset / 150000
    property real boomScale: 1.0
    property real boomOpacity: 0.0
    property real uiOpacity: 0.0
    property bool isWindup: false

    readonly property real windupDegMin: windupOffset * 5
    readonly property real windupDegSec: windupOffset * 10

    readonly property int windupDuration: 1600
    readonly property int boomDuration: 150
    readonly property int fadeInDuration: 350

    property int _phase: 0
    property double _t0: 0

    function _easeInQuint(t) { return t * t * t * t * t }
    function _easeInQuad(t)   { return t * t }
    function _easeOutCubic(t) { var u = 1 - t; return 1 - u * u * u }
    function _eased(from, to, t, fn) { return from + (to - from) * fn(t) }

    property Timer tickTimer: Timer {
        id: _tick
        interval: 16
        repeat: true
        running: engine.isWindup && engine.clockAwake
        onTriggered: engine._tick()
    }

    function startReveal() {
        if (isWindup)
            return
        if (!animationEnabled) {
            uiOpacity = 1
            return
        }
        isWindup = true
        windupOffset = 0
        boomScale = 1.0
        boomOpacity = 0.0
        _phase = 0
        _t0 = Date.now()
        _tick.start()
    }

    function abort() {
        _tick.stop()
        isWindup = false
        windupOffset = 0
        boomScale = 1.0
        boomOpacity = 0.0
        _phase = 0
    }

    function _tick() {
        if (!clockAwake)
            return
        var now = Date.now()
        if (_phase === 0) {
            var wdt = now - _t0
            var wt = Math.min(1, wdt / windupDuration)
            windupOffset = _eased(0, 150000, wt, _easeInQuint)
            if (wdt >= windupDuration) {
                windupOffset = 150000
                _phase = 1
                _t0 = now
            }
        } else if (_phase === 1) {
            var bdt = now - _t0
            var bScale = Math.min(1, bdt / boomDuration)
            var bOpacity = Math.min(1, bdt / 120)
            boomScale = _eased(1, 35, bScale, _easeInQuad)
            boomOpacity = _eased(0, 1, bOpacity, _easeInQuad)
            if (bdt >= boomDuration) {
                boomScale = 35
                _phase = 2
                _t0 = now
            }
        } else if (_phase === 2) {
            var fdt = now - _t0
            var ft = Math.min(1, fdt / fadeInDuration)
            uiOpacity = _eased(0, 1, ft, _easeOutCubic)
            if (fdt >= fadeInDuration) {
                uiOpacity = 1
                isWindup = false
                _phase = 3
                _tick.stop()
            }
        }
    }

    onAnimationEnabledChanged: {
        if (!animationEnabled) {
            abort()
            uiOpacity = 1
        }
    }
}