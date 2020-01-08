#NoEnv
SendMode, Input
SetWorkingDir %A_ScriptDir%

#include AHKHID.ahk

Gui, +Resize
Gui, Add, Text, vinfo, Spen Info
Gui, Add, Text, vmsg, Please use your Spen to trigger info
Gui, Add, Text, r1 w300 vproc, proc: 
Gui, Add, Text, r1 w300 vxptr, X: 
Gui, Add, Text, r1 w300 vyptr, Y: 
Gui, Add, Text, r1 w300 vpress, Pressure: 
Gui, Show, w300 h300


; S-Pen info constants
; You can get it through the GUI
global SPEN_NOT_HOVERING := 0x0
global SPEN_HOVERING := 0x0
global SPEN_TOUCHING := 0x1
global SPEN_BTN_HOVERING := 0x8
global SPEN_BTN_TOUCHING := 0xC

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
        proc := (rawData >> 8) & 0x1F
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
    If (lastProc = SPEN_HOVERING and proc = SPEN_BTN_HOVERING) {
        GuiControl,, msg, You Clicked the S-Pen Button.
    } Else If (lastProc = SPEN_HOVERING and proc = SPEN_TOUCHING) {
        GuiControl,, msg, You touch the Screen.
    } Else If (lastProc = SPEN_TOUCHING and proc = SPEN_HOVERING) {
        GuiControl,, msg, You leave the Screen.
    } Else {
        GuiControl,, msg, You do something undefined.
    }
}

Esc::ExitApp
F12::reload