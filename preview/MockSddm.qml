import QtQuick

QtObject {
    property string hostName: "onyx-preview"

    function login(user, password, sessionIndex) { console.log("mock sddm.login", user, sessionIndex) }
    function powerOff() { console.log("mock sddm.powerOff") }
    function reboot() { console.log("mock sddm.reboot") }
}
