#NoEnv
SendMode, Input
SetWorkingDir %A_ScriptDir%

#Include, AHKHID.ahk

; S-Pen info constants
; You can get it through the GUI
global SPEN_NOT_HOVERING := 0x0
global SPEN_HOVERING := 0x20
global SPEN_TOUCHING := 0x21
global SPEN_BTN_HOVERING := 0x28
global SPEN_BTN_TOUCHING := 0x2C

WM_INPUT := 0xFF
USAGE_PAGE := 13
USAGE := 2

AHKHID_UseConstants()
AHKHID_AddRegister(1)
AHKHID_AddRegister(USAGE_PAGE, USAGE, A_ScriptHwnd, RIDEV_INPUTSINK)
AHKHID_Register()

OnMessage(WM_INPUT, "InputMsg")
InputMsg(wParam, lParam) {
    Local rType, info, rawData
    Critical

    If (CheckRun() == 0)
        Return

    rType := AHKHID_GetInputInfo(lParam, II_DEVTYPE)

    If (rType = RIM_TYPEHID) {
        info := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
        data := AHKHID_GetInputData(lParam, uData)

        rawData := NumGet(uData, 0, "UInt")
        state := (rawData >> 8) & 0x3F
        xPointer := NumGet(uData, 2, "UShort")
        yPointer := NumGet(uData, 4, "UShort")
        pressure := NumGet(uData, 6, "UShort")
        
        CheckPenCallBack({"X": xPointer, "Y": yPointer, "pressure": pressure, "state": state})
    }
}

CheckPenCallBack(object) {
    static lastObject = {"X": 0, "Y": 0, "pressure": 0, "state": SPEN_NOT_HOVERING}

    If (lastObject.state != object.state) {
        PenCallBack(lastObject.state, object.state)
        lastObject := object
    }
}


FromTo(pre, now, from, to) {
    Return (pre = from and now = to)
}

; do something you want
PenCallBack(lastState, state) {
    FromTo_ := Func("FromTo").Bind(lastState, state)
    CLICK := %FromTo_%(SPEN_HOVERING, SPEN_TOUCHING) or %FromTo_%(SPEN_NOT_HOVERING, SPEN_TOUCHING)

    if (CLICK)
        clickCounter()

}

;; Every action has its handler.
;; You can override the implementations to define event.
;; Below is definition of Timer and Constants.
global Timers := {"Click": 0}
global ClickPeriod := 300   ; ms, interval of Spen's click

clickCounter() {
    If (Timers.Click = 0) 
        SetTimer, clickTimer, %ClickPeriod%
    Timers.Click += 1
}

clickTimer() {
    SetTimer, clickTimer, Off

    If (Timers.Click = 1) {
        SingleClick()
    } Else If (Timers.Click = 2) {
        DoubleClick()
    } Else {
        MultiClick(Timers.Click)
    }

    Timers.Click := 0

}


;; Check If the Environment can run this script
CheckRun() {
    WinGetTitle, title, A   ; Get Active Window's Title
    If (RegExMatch(title, titleRegex, sub) = 0)
        Return 0
}
