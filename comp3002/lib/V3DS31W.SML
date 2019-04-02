3.1.0.106
   
enable
        "Enable 3D support."
    Enabled ifTrue: [ ^self ].
    [
        Enabled := true.
        self startUp ] evaluateWithoutInterrupts.
    Display redraw! 
fileName
        "Answer the receiver's file name."
    ^'CTL3D32'! 
enabled
        "Answer whether 3D 3D support is enabled."
	Enabled == nil
		ifTrue: [^false].
	^Enabled! 
initialize
        "Private - initialize the Enabled class variable."
    Enabled := true!  
unbound
        "Private - when uninstalled, unregister for interest in #startup and #shutdown events."
    self disable.
    SessionModel current
        removeActionsWithReceiver: self forEvent: #startup;
        removeActionsWithReceiver: self forEvent: #shutdown!  
exit
        "Private - handle the system exit notification."
    OperatingSystem isWindows95 ifFalse: [
        self enabled ifTrue: [
            self current
                unAutoSubclass;
                unregister: OperatingSystem hInstance ].
        self currentOrNil notNil ifTrue: [ self current close ] ]
! 
bound
        "Private - when installed, register for interest in #startup and #shutdown events."
    SessionModel current
        when: #startup send: #startUp to: self;
        when: #shutdown send: #exit to: self.
    self startUp!   
disable
        "Disable 3D support."
    Enabled ifFalse: [ ^self ].
    [
        self exit.
        Enabled := false ] evaluateWithoutInterrupts.
    Display redraw!
startUp
        "Private - handle the system startup notification."
    ( OperatingSystem isWindows95 not and: [ self enabled ] ) ifTrue: [
        self current
            register: OperatingSystem hInstance;
            autoSubclass: OperatingSystem hInstance ]! 
dlgFramePaint: hwnd msg: msg wparam: wparam lparam: lparam
    <api: Ctl3dDlgFramePaint handle ulong ulong long long>
    ^self invalidArgument!
subclassCtlEx: hwnd ct: controlType
    <api: Ctl3dSubclassCtl handle long boolean>
    ^self invalidArgument!  
ctlColorEx: msg wparam: wparam lparam: lparam
    <api: Ctl3dCtlColorEx ulong ulong long ulongReturn>
    ^self invalidArgument!
subclassDlg: hwnd grbit: grbit
    <api: Ctl3dSubclassDlg handle ushort boolean>
    ^self invalidArgument! 
isAutoSubclass
    <api: Ctl3dIsAutoSubclass boolean>
    ^self invalidArgument!
subclassDlgEx: hwnd grbit: grbit
    <api: Ctl3dSubclassDlgEx handle ulong boolean>
    ^self invalidArgument!  
getVer
    <api: Ctl3dGetVer ushort>
    ^self invalidArgument! 
unsubclassCtl: hwnd
    <api: Ctl3dUnsubclassCtl handle boolean>
    ^self invalidArgument! 
autoSubclass: hInstance
    <api: Ctl3dAutoSubclass handle boolean>
    ^self invalidArgument!  
winIniChange
    <api: Ctl3dWinIniChange none>
    ^self invalidArgument!   
enabled
    <api: Ctl3dEnabled boolean>
    ^self invalidArgument!  
unAutoSubclass
    <api: Ctl3dUnAutoSubclass boolean>
    ^self invalidArgument!
subclassCtl: hwnd
    <api: Ctl3dSubclassCtl handle boolean>
    ^self invalidArgument! 
unregister: hInstance
    <api: Ctl3dUnregister handle boolean>
    ^self invalidArgument!  
register: hInstance
    <api: Ctl3dRegister handle boolean>
    ^self invalidArgument!  
colorChange
    <api: Ctl3dColorChange boolean>
    ^self invalidArgument!