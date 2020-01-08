#NoEnv
SendMode, Input
SetWorkingDir %A_ScriptDir%

#include AHKHID.ahk

Gui, +Resize
Gui, Add, Text, vinfo, Spen Info
Gui, Add, Text, w300 vmsg, Please use your Spen to trigger info
Gui, Add, Text, r1 w300 vproc, proc: 
Gui, Add, Text, r1 w300 vxptr, X: 
Gui, Add, Text, r1 w300 vyptr, Y: 
Gui, Add, Text, r1 w300 vpress, Pressure: 
Gui, Show, w300 h300


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

    rType := AHKHID_GetInputInfo(lParam, II_DEVTYPE)

    If (rType = RIM_TYPEHID) {
        info := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
        data := AHKHID_GetInputData(lParam, uData)

        rawData := NumGet(uData, 0, "UInt")
        proc := (rawData >> 8) & 0x3F
        xPointer := NumGet(uData, 2, "UShort")
        yPointer := NumGet(uData, 4, "UShort")
        pressure := NumGet(uData, 6, "UShort")
        
        GuiControl,, proc, proc: %proc% 
        GuiControl,, xptr, X: %xPointer% 
        GuiControl,, yptr, Y: %yPointer% 
        GuiControl,, press, Pressure: %pressure%

        PenActionCallBack(proc) 
    }
}

PenActionCallBack(proc) {
    static lastProc := PEN_NOT_HOVERING

    If (proc != lastProc) {
        PenCallBack(proc, lastProc)
        lastProc := proc
    }
}

; do something you want
PenCallBack(proc, lastProc) {
    If (proc = SPEN_NOT_HOVERING) {
        GuiControl,, msg, You have left the Screen.
    } Else If (proc = SPEN_HOVERING) {
        GuiControl,, msg, You leave the Screen but still hovering.
    } Else If (proc = SPEN_TOUCHING) {
        GuiControl,, msg, You touch the Screen.
    } Else If (proc = SPEN_BTN_HOVERING) {
        GuiControl,, msg, Click and Hovering.
    } Else If (proc = SPEN_BTN_TOUCHING) {
        GuiControl,, msg, Click and Touching.
    } Else If (lastProc = SPEN_NOT_HOVERING) {
        GuiControl,, msg, You are interacting with the screen.
    } Else {
        GuiControl,, msg, You do something undefined.
    }
}

Esc::ExitApp
F12::reload