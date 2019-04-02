3.1.0.106
   
supportedEvents
        "Answer the Set of events that MDIChilds
        can notify their owners about."
    ^super supportedEvents
        add: #toggleKey;
        yourself!   
startUp
        "Private - Initialize the receiver's class variables."
    DefMDIChildProcAddress := 
        KernelLibrary getProcAddress: UserLibrary procName: 'DefMDIChildProcA'.
    DefMDIChildProcAddress := 
        ( ExternalAddress fromString: DefMDIChildProcAddress ) asInteger.!  
defMDIChildProcAddress
        "Private - Answer the address of the defMDIChildProc API."
    ^DefMDIChildProcAddress!  
constructEventsTriggered
        "Private - answer the set of events that 
         instances of the receiver can trigger. "
     ^super constructEventsTriggered
        addAll: #(
            #keyToggled
        );
        yourself!  
windowClass
        "Private- answer the receiver's window class.
        Same class used for all TopPane."
    | className wndClass address answer |
    className := 'SmalltalkV', self class name.
    wndClass := WinWindowClass new.
    answer := UserLibrary getClassInfo: OperatingSystem hInstanceExe
        className: className asParameter
        wndClass: wndClass asParameter.
    answer ifTrue: [ ^className ].
    UserLibrary getClassInfo: OperatingSystem hInstanceExe
        className: super windowClass asParameter
        wndClass: wndClass asParameter.
    address := ExternalAddress copyToNonSmalltalkMemory: className asAsciiZ.
    wndClass
        style: CsVredraw | CsHredraw;
        hIcon: 0;
        hBrush: ( GDILibrary getStockObject: WhiteBrush );
        className: address asParameter.
    UserLibrary registerClass: wndClass asParameter.
    address free.
    ^className!   
accel: aChar afBits: theAfBits
        "Private - Allows a window to intercept character
         input before it is processed either by the menu
         or the child window.  Returning true will cause the
         character input to be ignored from here on."
    aChar = NumLockKey ifTrue: [
        self frame event: #toggleKey.
        self frame triggerEvent: #keyToggled ].
    aChar = InsertKey ifTrue: [
        self frame event: #toggleKey.
        self frame triggerEvent: #keyToggled ].
    aChar = CapitalKey ifTrue: [
        self frame event:#toggleKey.
        self frame triggerEvent: #keyToggled ].
    (aChar = $Z asciiValue and: [ theAfBits = AfAlt ] ) ifTrue: [
        self zoom.
        ^true ].
    ^super accel: aChar  afBits: theAfBits!
openWorkspace
        "Private - The user selected New Workspace
        from the File menu."
    self class textWindowClass new
        frame: self frame;
        label: 'Workspace';
        openOn: ''! 
showMaximizedWindow
        "Private - Show the receiver window with maximized size."
    self frame mdiMaximize: self.
    "self resize: (self rectangle)"!   
helpManager
        "Private - Answer the receiver's help manager
        If none, answer the receiver's frame help manager."
    | hm |
    hm := self propertyAt: #helpManager.
    hm notNil ifTrue:[ ^hm ].
    ^self frame propertyAt: #helpManager!   
systemMenuItemClose
        "Private - Answer false if the receiver's system 
        menu item close is disabled, else answer true."
    ^self propertyAt: #systemMenuItemClose!  
systemMenuItemClose: aBoolean
        "Private - disable the receiver's system 
        menu item close if aBoolean is false."
    self propertyAt: #systemMenuItemClose put:aBoolean.!
contextForItem: anInteger
        "Private - Handle the system menu 
        when the Child document is maximized."
    ( anInteger between: 100 and: 150 ) 
        ifTrue:[ ^Association key: 'MDIMenu' value: self owner].
    ^super contextForItem: anInteger.! 
showIconicWindow
        "Private - Show the receiver window as an icon."
    self frame mdiIsMaximized ifTrue: [ 
        self showWindow.
        ^self ].
    super showIconicWindow.!
defWindowProc: msg with: wordInteger with: longInteger
        "Private - MDIChild default procedure."

    ^( ExternalLong fromBytes:(
        UserLibrary defMDIChildProc: self handle
            msg: msg
            wparam: wordInteger
            lparam: longInteger ) )! 
buildMenuBar
        "Private - Create the menus that make up the menu bar."
    | windowPolicy |
    windowPolicy := self propertyAt: #windowPolicy
        ifAbsent: [ self frame propertyAt: #windowPolicy
            ifAbsent: [self frame owner windowPolicyClass on: self ] ].
    windowPolicy addMDIChildMenus!
statusPane
        "Answer the receiver's statusPane."
    self frame isNil
        ifTrue:[ ^(Smalltalk at: #MDISystem) frame statusPane ].
    ^self frame statusPane!  
wmSyscommand: wordInteger with: longInteger
        "Private - Reimplemented here to ignore Ctrl+F4
        if the system menu item is disabled"
    ( wordInteger bitAnd: 16rFFF0 ) = ScClose 
        ifTrue: [ self systemMenuItemClose ifFalse:[ ^0 ] ].
    ^super wmSyscommand: wordInteger with: longInteger! 
initialize
        "Private - Initialize the receiver."
    super initialize.
    self systemMenuItemClose: true.! 
buildWindow
        "Private - Create the document for the receiver."
        "see Microsoft online Q70080 Creating a Hidden MDI Child Window."

    | mdiCreate answer max anAddress focusPane |
    max := self frame mdiIsMaximized.
    NotificationManager newWindow notNil ifTrue: [ ^nil ].
    self frame isActive ifFalse: [
        self frame makeActive.
        self frame updateWindow ].

    style isNil ifTrue: [ style := self getStyle ].
    max ifTrue: [ self addStyle:  WsMaximize ].
    mdiCreate := WinMdiCreateStruct new.
    mdiCreate szTitle: self label.
    mdiCreate szClass: self windowClass.
    mdiCreate hOwner: OperatingSystem hInstanceExe.
    mdiCreate x: rectangle origin x asInteger.
    mdiCreate y: rectangle origin y asInteger.
    mdiCreate cx: rectangle width asInteger.
    mdiCreate cy: rectangle height asInteger.
    mdiCreate style: style.
    mdiCreate lParam: NullHandle.
    anAddress := ExternalAddress copyToNonSmalltalkMemory: mdiCreate asParameter.
    NotificationManager newWindow: self.
    answer := UserLibrary sendMessageInt: self parent asParameter
        msg: WmMdicreate
        wparam: 0
        lparam: anAddress asParameter.
    NotificationManager newWindow: nil.
    mdiCreate free.
    anAddress free.
    handle := WindowHandle fromInteger: answer.
    handle = NullHandle ifTrue: [
        self panicWmMdiCreate.
        ^nil ].
    self frame renumber: self.
    "Set the size of the frame window."
    rectangle := self rectangle.

    focusPane := self subPaneWithFocus.
    self activeTextPane: self searchForDefaultTextPane.
    focusPane notNil ifTrue: [ focusPane setFocus ].
    self subPaneWithFocus: focusPane.

    self updateClient.!
basicStyle
        "Private - Answer an Integer with appropriate
         constants combination for basic window style."

    ^WsChild | WsClipsiblings | WsBorder | WsVisible!   
mdiMenuWindow
        "Private - Answer the receiver's mdiMenuWndow."
    ^mdiMenuWindow!   
mdiMenuWindow: aMenuWindow
        "Private - Set the receiver's mdiMenuWndow."
    mdiMenuWindow := aMenuWindow!   
outOfMemory
        "Private - Low resource situation."
    self menuWindow handle = NullHandle ifFalse: [
        self menuWindow close;
        destroy ].
    super outOfMemory.! 
defMDIChildProc
        "Private - Change the default Windows 
         procedure of the receiver to use the DefMDIChildProc."
    handle defMDIChildProc: self.!  
display
        "Private - Draw the icon"
    | hbrNew hbrOld |
    self minimized ifFalse: [ ^self ].

    self frame mdiClient backColor notNil ifTrue: [
		hbrNew := GDILibrary createSolidBrush: self frame mdiClient backColor.
       hbrOld := UserLibrary
			setClassLong: self frame mdiClient asParameter
			index: GclHbrbackground
			value: hbrNew asParameter ].
    self defWindowProc:WmIconerasebkgnd with:self graphicsTool handle with:0.
    self icon displayWith:self graphicsTool.

    self frame mdiClient backColor notNil ifTrue: [
		UserLibrary
			setClassLong: self frame mdiClient asParameter
			index: GclHbrbackground
			value: hbrOld asParameter.
		GDILibrary deleteObject: hbrNew asParameter ].

    ^1!
hideWindow
        "Make the receiver invisible."
    self frame mdiIsMaximized 
        ifTrue: [ self parent noRedraw: true ].
    ^super hideWindow!   
label: aString
        "Set the receiver's label without the prefix."
    ^self labelWithoutPrefix: aString!
frame
        "Answer the receiver's frame."
    ^frame!
frame: aFrame
        "Set the receiver's frame to aFrame."
    frame := aFrame.!   
frameRectangle
        "Answer the receiver's frame area as a rectangle."
    ^super frameRectangle mapToWindow: self parent.!  
superWindow
        "Answer the non-frame parent window of the receiver."
    ^self frame!  
destroy
        "Private - destroy the receiver."
    self frame removeMdipane: self.
    self frame mdiDestroy: self.
    self frame avoidDestroyCurrentMenu: self.
    self menuWindow destroy.
    MDIFrame mdiSelected: true.!  
activate
        "Private - The receiver was activated."
    self isHandleOk ifFalse: [ ^self ]. "already closed"
    super activate.
    self frame childActivate.!  
openIn: aRectangle
        "Private - Open the receiver in aRectangle."
    (self frame isNil and: [ (Smalltalk at: #MDISystem) isActive ] )
        ifTrue: [self frame: (Smalltalk at: #MDISystem) frame].
    self buildIcon.
    self frame addMdipane: self.
    self initSize: (self initSize).
    self buildMenuBar.
    children do: [ :subpane | subpane open ].
    ^self validate!   
disableSystemMenuItemClose
        "Disable the receiver's system menu item close."
    self systemMenuItemClose: false!
wmCreate: wordInteger with: longInteger
        "Private - Process WM_CREATE messsage.
        Create menu and subpanes."

    NotificationManager newWindow: nil.
    self menuWindow buildPopupWindow isNil ifTrue: [ ^-1].
    self defMDIChildProc.
    self receiveMessages.

    "Create the subpanes."
    self childrenInBuildOrder do: [ :subpane |
        (subpane buildWindow: self) isNil
            ifTrue: [ ^-1] ].
    ^nil!   
isMDIChild
        "Answer true if receiver is an instance
        of class MDIChild, else answer false."
    ^true!   
isActive
        "Private - Answer true if the receiver's
         is the currently active document."
    ^self frame mdiGetActive == self!
initSize
        "Private - Answer the initial size of the receiver."
    | size |
    self frame isNil ifTrue:[ ^nil ].
    size := (owner respondsTo: #initMdiWindowSize)
        ifTrue: [ owner initMdiWindowSize ]
        ifFalse: [ self initMdiWindowSize ].
    ^( size isRectangle
        ifTrue: [ size ]
        ifFalse: [
            size isPoint
                ifTrue: [ self boxOfSize: size ]
                ifFalse: [ 0 @ 0 extent: 100@100 ] ] ).!   
validate
    "Private - Create or recreate the window for the receiver."
    | old answer |
    self parent isHandleOk ifFalse:[ ^nil ].

    "Do not want to receive messages in MDIClient while in buildWindow"
    old :=  Process enableInterrupts: false.

    answer := super validate.
    answer notNil ifTrue: [
        self frame mdiActivate:self.
        self updateWindow ].
    Process enableInterrupts: old.
    answer isNil ifTrue: [ ^nil ].

    self systemMenuItemClose
        ifFalse: [ self  disableSysMenu: 6 ].
    MDIFrame mdiSelected: true.!   
initMdiWindowSize
        "Private-Answer the default size of a document."
    | rect extent origin |
    rect := self frame mdiClient rectangle.

    "if framingBlock notNil, use it for initial rectangle."
    framingBlock notNil
        ifTrue: [ ^framingBlock value: rect ]
        ifFalse: [
            extent := (rect width * 24 // 25) @ (rect height * 24 // 25).
            extent := extent - ((self frame mdiChildren size - 1) * ( 8 @ 8)).
            origin :=(self frame mdiChildren size - 1) * (8 @ 8).
            ^origin extent: extent ].! 
mdiSelected
       "Private - Answer if the receiver is already selected."
    ^MDIFrame mdiSelected!   
mdiSelected: aBoolean
        "Private - Set the receiver is already selected."
    MDIFrame mdiSelected: aBoolean! 
panicWmMdiCreate
        "Private - Low resource situation - couldn't create an MDI child."
    self updateClient.
    Terminal bell; bell; bell.
    self frame removeMdipane: self.!
closeView
        "Private - Close the receiver and all its children."
    | answer active |
    self isHandleOk ifFalse: [ ^self ]. "already closed"

    answer := super closeView.
    answer isNil ifTrue: [ ^nil ].

    ( owner notNil and: [ owner ~= self ] )
        ifTrue: [ [ owner removeView: self ] on: MessageNotUnderstood do: [ ] "only applies to a ViewManager" ].
    self frame childClose.
    self frame renumber:self.
    active := self frame mdiGetActive.
    active isNil ifTrue: [ self setInitMenu ].
    self updateClient.
    ^answer!  
openFile
        "Private - User selected Open... from the File menu."
    | dialog file |
    ( dialog := FileDialog new openFile ) isNil 
        ifTrue: [ ^self ].
    ( file := dialog file ) isNil 
        ifTrue: [ ^self ].
    ( File exists: file ) ifFalse: [
        ( MessageBox confirm: 'File does not exist.  Do you want to create it?' )
            ifTrue: [ File createFileNamed: file ]
            ifFalse: [ ^self ] ].
    file := File pathNameReadOnly: file.
    self class textWindowClass new
        frame: self frame;
        openOnFile: file.
    file close!  
setInitMenu
        "Private - set the initMenu as the frame's menubar."
    self frame setInitMenu!
updateClient
        "Private - Update the MDI client."
    self parent noRedraw: false.
    self parent invalidateRect: nil.
    self parent updateWindow.!  
wmMdiactivate: wordInteger with: longInteger
        "Private - Process the mdiactivate window message.
         Triggers the active and deactivate message."
    | deactivated |
    longInteger = self handle asInteger ifTrue: [
        self setDocumentMenu.
        self sendInputEvent:#activate ].
    wordInteger = self handle asInteger ifTrue: [
        self sendInputEvent: #deactivate ].
    wordInteger > 0 ifTrue: [ MDIFrame mdiSelected: false ].
    deactivated := Notifier findWindow: longInteger.
    deactivated isNil ifTrue: [ ^self ].
    deactivated minimized ifTrue:[ MDIFrame mdiSelected:true ].!  
deactivate
        "Private - The receiver was deactivated."
    self isHandleOk ifFalse: [ ^self ]. "already closed"
    super deactivate.
    self frame childDeactivate.!  
setDocumentMenu
        "Private - set the receiver's menu as the frame's menubar."
    self menuWindow menus isEmpty 
        ifTrue:[ ^self setInitMenu ].
    self frame setDocumentMenu: self.!   
isMDISupportPane
        "Answer true if receiver is a support pane for MDI."
    ^false!   
defFrameProc: aWindowHandle
        mdiClient: aClientHandle
        msg: msgInteger
        wparam: wordInteger
        lparam: longInteger
    <api: DefFrameProcA ulong ulong ulong ulong ulong ulong>
    ^self invalidArgument!
destroyMDIMenu: aMenu
        "Private - Destroy an MDI menu from the receiver."
    | h old |
    ( menus includes: aMenu ) ifFalse:[ ^self ].
    handle = NullHandle 
        ifFalse: [ old := Process enableInterrupts: false].
    menus remove: aMenu ifAbsent: [ ^self ].
    handle = NullHandle ifTrue: [ ^self ].
    h := self handle.
    self buildPopupWindow isNil ifTrue:[ ^self ].
    self owner setDocumentMenu.
    UserLibrary destroyMenu: h.
    Process enableInterrupts: old.!  
translateMDISysAccel: winMsgNS
        "Private - Translate MDI accelarator keys."
    | aWindow hWnd answer |
    hWnd := winMsgNS hwnd.

    "Is hWnd a Smalltalk window"

    ( aWindow := Notifier findRealWindow: hWnd ) notNil
        ifTrue: [ aWindow mainWindow isMDIChild
            ifTrue:[ aWindow:=aWindow mainWindow parent ].
            answer := UserLibrary translateMDISysAccel: aWindow asParameter
                msg: winMsgNS asParameter.
            ^answer ].
    ^false!
modifySysMenu: aString  position:aPosition
        "Private - Change the string of the item menu
        at aPosition in the receiver's system menu."

    | m |
    m := UserLibrary
        getSystemMenu: self asParameter
        revert: 0.
    UserLibrary modifyMenu: m
        position: aPosition
        flags: MfByposition
        newId: ( UserLibrary getMenuItemId: m
            position: aPosition)
    newContents: aString asParameter.! 
addMDIMenu: aMenu
        "Private - Add aMenu to the receiver.
        The owner is an MDIChild."
    | tempMenu h old |
    handle = NullHandle
        ifFalse: [ old := Process enableInterrupts: false ].
    menus notEmpty
        ifTrue: [
            tempMenu := self owner mdiMenuWindow menus.
            menus removeAll: tempMenu.
            menus add: aMenu;
            addAll: tempMenu ]
         ifFalse: [ menus add: aMenu ].
    handle = NullHandle 
        ifFalse:[
            h := self handle.
            self buildPopupWindow isNil ifTrue:[ ^self ].
            self owner setDocumentMenu.
            UserLibrary destroyMenu: h.
            Process enableInterrupts: old ].!   
minimized
        "Private - Answer false if the receiver is minimized."
    ^false!
disableSysMenu: aPosition
        "Private - Disable the item menu at aPosition
        in the receiver's system menu."

    | m buffer anAddress menuString|
    m := UserLibrary
        getSystemMenu: self asParameter
        revert: 0.
    buffer := String new: 64.
    anAddress := ExternalAddress copyToNonSmalltalkMemory: buffer.
    UserLibrary getMenuString: m
        position:aPosition
        string: anAddress asParameter
        max: 64
        flags: MfByposition.
    menuString := String fromAddress: anAddress.
    anAddress free.
    UserLibrary modifyMenu: m
        position: aPosition
        flags: MfByposition | MfDisabled | MfGrayed
        newId: (UserLibrary getMenuItemId: m
            position: aPosition)
    newContents: menuString asParameter! 
makeInitMdiMenu
        "Private - Answer receiver's initial menu bar
        when there is no opened document."
    | tempMenu menu eachMenu |
    tempMenu := window menuWindow.
    window menuWindow: MenuWindow new.
    window event: #menuBuilt.      " OBSOLETE "
    window triggerEvent: #menuBarBuilt.
    menu := window menuWindow.
    window menuWindow: tempMenu.
    menu menus do: [ :m |
        eachMenu := window  menuWindow menuTitled:m title.
        eachMenu notNil 
             ifTrue: [ m copyAttributesFrom: eachMenu ] ].
    ^menu!   
constructEventsTriggered
        " Private - answer the set of events that 
        instances of the receiver can trigger. "
     ^super constructEventsTriggered
        addAll: #(
            #childActivated
            #childDeactivated
            #childClosed
            #mdiMenuBarBuilt
            #keyToggled
        );
        yourself!  
unbound
        "Private - Remove global changes from the image when unbound."
    OperatingSystemEvents at: WmMdiactivate put: nil.
    SessionModel current
        removeActionsWithReceiver: self
        forEvent: #startup.
    SessionModel current
        removeActionsWithReceiver: MDIChild
        forEvent: #startup!
supportedEvents
        "Answer the Set of events that MDIFrames
        can notify their owners about."
    ^super supportedEvents
        add: #mdiMenuBuilt;
        add: #toggleKey;
        add: #childActivate;
        add: #childDeactivate;
        add: #childClose;
        yourself! 
startUp
        "Private - Initialize the receiver's class variable."
    | vmLibrary |
    vmLibrary := VirtualMachineExe current.
    MDIFrameWndProcAddress := 
        KernelLibrary getProcAddress: vmLibrary procName: 'VW32MDIFrameProc@16' .
    MDIFrameWndProcAddress :=
        ( ExternalAddress fromString: MDIFrameWndProcAddress ) asInteger.!  
mdiSelected
        "Private - answer true if an MDI document
        is already active, else answer false."
    ^MdiSelected! 
mdiSelected: aBoolean
        "Private - set the receiver's MdiSelected to a boolean."
    MdiSelected := aBoolean! 
aboutToUnbind: library
        "Private - check for instances before unbinding."
    self allInstances isEmpty ifFalse:[
        MessageBox confirm: 'You have instances of MDIFrame in your image. Cannot unbind MDI library'.
        library abortUnbind ].!   
statusText
        "Private - Answer the receiver's statusText property."
    ^self propertyAt: #statusText!
translateMDISysAccel: hWnd  msg:aWinAddr
    <api: TranslateMDISysAccel ulong ulong boolean>
    ^self invalidArgument! 
visible: aBoolean
        "Private - Set the visible state 
         of the reciever to aBoolean."
    aBoolean 
        ifTrue: [ self showWindow ]
        ifFalse: [ self hideWindow ]!   
sizeInBytes
    ^36! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
       #szClass
       #szTitle
       #hOwner
       #x
       #y
		#cx
       #cy
       #style
       #lParam
    )!
cx

    ^self longAtOffset: 20! 
hOwner: anInteger

    ^self handleAtOffset: 8  put: anInteger! 
lParam

    ^self uLongAtOffset: 32!
cx: anInteger

    ^self longAtOffset: 20  put: anInteger!  
cy: anInteger

    ^self longAtOffset: 24  put: anInteger!  
style

    ^self uLongAtOffset: 28! 
style: anInteger

    ^self uLongAtOffset: 28  put: anInteger!  
szTitle
    | winaddress |
    winaddress:= ExternalHeapAddress new.
    winaddress uLongAtOffset: 0 put: ( self uLongAtOffset: 4 ).
    ^String fromAddress: winaddress! 
szTitle: aString
    pszTitle := ExternalAddress copyToNonSmalltalkMemory: aString asAsciiZ.
    self uLongAtOffset: 4 put: pszTitle asInteger! 
y

    ^self longAtOffset: 16!  
y: anInteger

    ^self longAtOffset: 16  put: anInteger!   
szClass
    | winaddress |
    winaddress := ExternalHeapAddress new.
    winaddress uLongAtOffset: 0 put: ( self uLongAtOffset: 0 ).
    ^String fromAddress: winaddress!
hOwner

    ^self handleAtOffset: 8!
lParam: anInteger

    ^self uLongAtOffset: 32 put: anInteger!  
szClass: aString
    pszClass := ExternalAddress copyToNonSmalltalkMemory: aString asAsciiZ.
    self uLongAtOffset: 0 put: pszClass asInteger! 
x

    ^self longAtOffset: 12!  
x: anInteger

    ^self longAtOffset: 12  put: anInteger!   
free

    pszClass free.
    pszTitle free.!   
cy

    ^self longAtOffset: 24! 
defMDIChildProc:anMDIChild
        "Private - Change the default Windows procedure
         of the receiver to use the DefMDIChildProc."
	self
		propertyAt: 'oldProc'
		put: anMDIChild class defMDIChildProcAddress!   
addMDIChildMenus
        "Private - add the menus to the menu bar."
    | eachMenu |
    ( window hasSmalltalkMenuBar and:
      [ window menuWindow menus isEmpty ] )
        ifTrue: [
            window menuWindow: window frame makeInitMdiMenu .
            window menuWindow menus isEmpty
                ifTrue:[ self addFileMenu ] ].

    window hasSmalltalkMenuBar ifTrue: [
        self addEditMenu.
        self addSmalltalkMenu.
        self addApplicationMenus ].

    window event:#menuBuilt.     " OBSOLETE "
    window triggerEvent: #menuBarBuilt.

    window mdiMenuWindow: window frame makeMdiMenu.
    window mdiMenuWindow menus do: [ :m |
        window menuWindow addMenu: m ].
    window mdiMenuWindow menus do: [ :m |
        eachMenu := window frame  menuWindow menuTitled: m title.
        eachMenu notNil
            ifTrue: [ m copyAttributesFrom: eachMenu ] ].

    window menuWindow parent: window frame.
    window menuWindow owner: window.
    window menuWindow systemMenu owner: window.!   
mdiArrange
    "Arrange the MDI documents."
    self frame mdiArrange!  
mdiCloseAll
    "Close all MDI documents which are not minimized."

    self frame mdiCloseAll.!   
mdiTile
    "Tile the MDI documents."

    self frame mdiTile! 
close
    "Close all the views."
    views do: [:v | v isMDIChild ifFalse: [v closeView]]!  
activeTextPane
    "Answer the active textPane of the active MDI document."
    |activeTextPane|
    activeTextPane:=self frame mdiGetActive.
    activeTextPane isNil ifTrue:[^nil].
    activeTextPane:=activeTextPane activeTextPane.
    ^activeTextPane!   
mdiCascade
    "Cascade the MDI documents."
    self frame mdiCascade!  
mdiNewWindow
    "Create a new TextWindow MDI document
    from the active TextPane."

    self frame activeTextPane notNil ifTrue:[
    TextWindow new frame:self frame;  label: 'Workspace';
    openOn:self frame activeTextPane contents].! 
frame
    "Answer the receiver's frame."
    ^mdiFrame! 
frame:aTopPane
    "Set the receiver's frame and answer aTopPane."

    mdiFrame:=aTopPane.
    ^aTopPane!
isMDIMenu
        "Answer true if receiver is an instance of class
         MDIMenu, else answer false."
    ^false!   
toolPane
        "answer the receiver's toolPane"
    ^children detect: [ :c| c isToolPane ] ifNone:[ nil ].!   
isMDISupportPane
        "Answer true if receiver is a support pane for MDI."
    ^true!
bound
        "Private - MDI has been bound, complete its initialization."
    | library |
    OperatingSystemEvents at: WmMdiactivate put:#wmMdiactivate:with: .
    SessionModel current when: #startup send: #startUp to: self.
    SessionModel current when: #startup send: #startUp to: MDIChild.
    self startUp.
    MDIChild startUp.
    MdiSelected := false.
    ( self smalltalkLibraryName notNil
    and: [ ( library := SmalltalkLibraryBinder named: self smalltalkLibraryName ) notNil ] )
        ifTrue: [
            library
                when: #aboutToUnbind
                send: #aboutToUnbind: to: self with: library;
                when: #unbind
                send: #unbound to: self ].!  
frame: aWindow
    "Set the receiver's frame to aWindow."
    views size < 1 ifTrue: [
        self addView: ( MDIChild new owner: self ) ].
    ( views at: 1 ) frame: aWindow!  
windowClass
    "Private - Answer the Windows class for an MDIClient."
    ^'MDICLIENT'!
basicStyle
    "Private - Answer an Integer with appropriate styles in it."
    ^WsHscroll | WsVscroll | WsChild | WsClipsiblings | WsClipchildren | WsVisible! 
wmCommand: wordInteger with: longInteger
    "Private - Process the command message."
    ^nil! 
wmMdiactivate: wordInteger with: longInteger
    "Private - for optimization only."
    |active|

    active:=self parent mdiGetActive.
    active isNil ifTrue:[^nil].
    self sendInputEvent:#selected.
    ^nil!   
create: className
    title: nameString
    style: styleInteger
    extendedStyle: extendedStyleInteger
    rectangle: aRectangle
    parent: parentWindow
        "Private - Create a window in the host system whose parent is
         parentWindow with aTitleString and aFrameStyle.
         The receiver's handle is set to the
         resulting client window."
    | result parentHandle menuHandle clientCreateStruct |
    parentWindow notNil ifTrue: [ parentHandle := parentWindow handle ].
    ( styleInteger bitAnd: WsChild ) ~= 0 ifTrue: [ menuHandle := self id ].
    clientCreateStruct := WinClientCreateStruct new.
    clientCreateStruct hMenu:parentWindow menuWindow asParameter.
    clientCreateStruct idFirstChild:100.
    result := UserLibrary
        createWindow: className asParameter
        name: nameString asParameter
        style: styleInteger
        extendedStyle: extendedStyleInteger
        x: aRectangle origin x
        y: aRectangle origin y
        width: aRectangle width
        height: aRectangle height
        parent: parentHandle
        menu: menuHandle
        instance: OperatingSystem hInstanceExe
        param: clientCreateStruct asParameter.
    handle := WindowHandle fromInteger: result.
    result = 0 ifTrue: [ self osWarning. ^nil ].
    UserLibrary setWindowLong:self parent asParameter index: 0 long: self asParameter.!  
isMDIClient
    "Answer true if receiver is an instance of class
     MDIChild, else answer false."

    ^true!   
selected
        "Private - An MDI document has been selected
        from the menu bar."
    MDIFrame mdiSelected: true.! 
sizeInBytes
     "Private - Answer the default size in bytes."
    ^8!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #hMenu #idFirstChild )!  
idFirstChild: anInteger

    ^self uLongAtOffset: 4  put: anInteger!
hMenu

    ^self handleAtOffset: 0! 
hMenu: anInteger

    ^self handleAtOffset: 0  put: anInteger!  
idFirstChild

    ^self uLongAtOffset: 4!   
removeView: aView
        "Remove aView from the view manager."
    views remove: aView ifAbsent: []!   
makeMdiMenu
        "Private - Make the receiver's  mdi menu bar
        The menubar is created each time a document is created."
    window  mdiMenuWindow: MenuWindow new.
    window event: #mdiMenuBuilt.
    window triggerEvent: #mdiMenuBarBuilt.
    self addStandardRightMenus.
    ^window mdiMenuWindow!
isMDIMenu
    "Answer true if receiver is an instance of class
     MDIMenu, else answer false."
    ^true!
buildItem: i menu: menuNumber menuBar: menuBar
    "Private - Build the i'th item in the menu indexed by
     the menuNumber of the menuBar."
    | a item |
    item := (items at: i).
    item selector notNil ifTrue:[item id: (menuNumber * 256 + i)].
    (item submenu notNil)
    ifTrue:  [item submenu buildWindow: menuBar].
    accel size >= i ifTrue: [
    (accel at: i) notNil ifTrue: [
        a := accel at: i.
        menuBar accelTable at: a put: (menuNumber * 256 + i)]].
    window insertItem: item label: item contents.!  
addMDIFrameMenus
        "Private - add the menus to the menu bar."
    | mw |
    window event: #menuBuilt.
    window triggerEvent: #menuBarBuilt.

    window hasSmalltalkMenuBar ifTrue: [
        window menuWindow menus isEmpty 
            ifTrue:[ self addFileMenu ] ].

    mw := self makeMdiMenu.
    mw menus do: [ :m |
        m isMDIMenu 
            ifFalse: [ window menuWindow addMenu: m ] ].

    window menuWindow systemMenu owner: window.
    window menuWindow owner: window.
    window mdiInitMenu: window menuWindow!   
disableSystemMenuItemClose
        "Disable the receiver's mainView 
         system menu item close."
    views size < 1ifTrue: [
        self addView: ( self topPaneClass new owner: self ) ].
    ^( views at: 1 )  disableSystemMenuItemClose!  
show
        "Private - Toggle visible state of the receiver."
    self visible: self isVisible not.
    self mainWindow 
        rectangleAttribute: ( 0 @ 0 extent: 0 @ 0 );
        sizeChanged: self mainWindow rectangle extent.!   
windowClass
    "private- answer the receiver's window class"
    "Same class used for all TopPane"
    | className wndClass address answer |
    className := 'SmalltalkV',self class name.
    wndClass := WinWindowClass new.
    answer := UserLibrary getClassInfo: OperatingSystem hInstanceExe
        className: className asParameter
        wndClass: wndClass asParameter.
    answer ifTrue: [ ^className ].
    UserLibrary getClassInfo: OperatingSystem hInstanceExe
        className: super windowClass asParameter
        wndClass: wndClass asParameter.
    address := ExternalAddress copyToNonSmalltalkMemory: className asAsciiZ.
    wndClass style: 0.
    wndClass wndExtra:4.
    wndClass windProc: MDIFrameWndProcAddress.
    wndClass hIcon: 0;
        hBrush: ( GDILibrary getStockObject: WhiteBrush );
        className: address asParameter.
    UserLibrary registerClass: wndClass asParameter.
    address free.
    ^className!  
accel: aChar afBits: theAfBits

    "Private - Allows a window to intercept character input
     before it is processed either by the menu or the child window.  Returning
     true will cause the character input to be ignored from here on."
    aChar = NumLockKey ifTrue:[self event:#toggleKey. self triggerEvent: #keyToggled].
    aChar = InsertKey ifTrue:[self event:#toggleKey. self triggerEvent: #keyToggled].
    aChar = CapitalKey ifTrue:[self event:#toggleKey. self triggerEvent: #keyToggled].
    ^super accel: aChar afBits: theAfBits!   
wmSize: wordInteger with: longInteger
    "Private - Process the erase wmSize message."
    "Reimplemented here because the MDIClient is
    resized by Smalltalk."
    rectangle := 0 @ 0 extent: 0 @ 0.
    super  wmSize: wordInteger with: longInteger.
    ^true!  
helpManager
    "Private - Answer the mdi active document's help manager if any
    else answer the receiver's help manager."

    |active hm|
    active := self mdiGetActive.
    active notNil
        ifTrue:[hm := active propertyAt: #helpManager].
    hm notNil ifTrue:[^hm].
    ^self propertyAt: #helpManager.!   
makeInitMdiMenu
    "Private - Answer receiver's initial
    menu bar when there is no opened document."
    | windowPolicy |
    windowPolicy := owner windowPolicyClass on: self.
    ^windowPolicy makeInitMdiMenu!   
mdiActivate:aWindow
    "Private- activate aWindow."
    UserLibrary sendMessage: self mdiClient asParameter
            msg: WmMdiactivate
            wparam: aWindow asParameter
            lparam: 0.!  
mdiTile
    "Tile the mdi documents; if the shift key is down, tile horizontally,
     otherwise vertically"

    UserLibrary
        sendMessage: self mdiClient asParameter
        msg: WmMditile
        wparam: ((Notifier isKeyDown: VkShift) ifTrue: [1] ifFalse: [0])
        lparam: 0!  
activeTextPane
    "Answer the subpane of the active MDIChild that has the typing focus."

    | mdiDocument |
    mdiDocument:=self mdiGetActive.
    mdiDocument isNil ifTrue: [ ^nil ].
    ^mdiDocument activeTextPane! 
avoidDestroyCurrentMenu:anMdiChild

    "Private - see Microsoft online Q67244."
    "do not destroy the menu that is currently in use."
    |menuHandle|

    menuHandle := UserLibrary getMenu: self asParameter.
    menuHandle := ExternalHandle fromInteger:menuHandle.
    menuHandle = anMdiChild menuWindow handle
        ifTrue:[self setInitMenu].
    ^menuHandle = anMdiChild menuWindow handle!   
disableItem:itemName forAllMDIChildMenus:menuName
    "Disable the itemName of the menuName.
    This menu item will be disabled for all the MDI documents."

    | theMenu|
    self  mdiChildren do:[:mdi|
    theMenu := mdi menuWindow menuTitled: menuName.
    theMenu disableItem: itemName].
    theMenu := self mdiInitMenu menuTitled:menuName.
    theMenu notNil ifTrue:[theMenu disableItem:itemName].! 
mdiGetActive
    "Answer the MDI active document if any, else answer nil."

    |mdiActive|

    self mdiClient isHandleOk ifFalse:[^nil].
    mdiActive:= UserLibrary sendMessageInt: self mdiClient asParameter
                            msg: WmMdigetactive
                            wparam:0
                            lparam:0.

    ^Notifier findWindow: mdiActive.!
mdiMaximize:aWindow
        "Private - Maximize the mdi document aWindow."
        UserLibrary sendMessage: self mdiClient asParameter
                msg: WmMdimaximize
                wparam:aWindow asParameter
                lparam:0.!  
subPaneWithFocus
        "Answer the SubPane of the receiver that last had the focus"

    | mdiDocument |
    mdiDocument := self mdiGetActive.
    mdiDocument isNil ifTrue: [ ^nil ].
    ^mdiDocument subPaneWithFocus! 
defWindowProc:msg with:wordInteger with: longInteger
    "Private - MDIFrame default proc.
    If the Mdi client handle is null, this is considered as a call to the normal
    default procedure. See Microsoft documentation for the defFrameProc."

    ^ExternalLong fromBytes:(UserLibrary defFrameProc: self handle
            mdiClient: self mdiClient asParameter
            msg: msg
            wparam: wordInteger
            lparam: longInteger)!   
childClose
    "Private - an MDI document was closed.
    Raise the #childClose event."

    self event: #childClose.          " OBSOLETE "
    self triggerEvent: #childClosed.!
wmErasebkgnd: wordInteger with: longInteger
    "Private - Process the erase background message."
    "Will be erased by the MDIClient"
    ^1!
addMdipane:aWindow
    "Private - An MDI docuement was created
    Add it to the receiver's mdiChildren."

    mdiChildren addLast: aWindow.
    aWindow parent: self mdiClient.!
buildMenuBar
        "Private - Create the menus that make up the menu bar."
    | windowPolicy |
    windowPolicy := self propertyAt: #windowPolicy
        ifAbsent: [ owner windowPolicyClass on: self ].
    windowPolicy addMDIFrameMenus!  
getFreeClientArea: aRectangle
    "Private - Answer the client area available for children of the receiver.
     It may differ from the actual client area when supplemental windows
     such as a Status Bar or a Tool Bar are added transparently."

    self zoomed ifTrue: [^aRectangle].
    (children select: [:each | each isMDISupportPane ]) do:
            [:eachSupp |eachSupp freeClientArea: aRectangle].
    ^aRectangle! 
mdiArrange
    "Arrange the MDI documents."

    UserLibrary sendMessage: self mdiClient asParameter
            msg: WmMdiiconarrange
            wparam:0
            lparam:0.!  
uncheckItem:itemName forAllMDIChildMenus:menuName
    "Uncheck the itemName of the menuName.
    This menu item will be unchecked for all the MDI documents."

    | theMenu|
    self  mdiChildren do:[:mdi|
        theMenu := mdi menuWindow menuTitled: menuName.
        theMenu uncheckItem: itemName].
    theMenu := self mdiInitMenu menuTitled:menuName.
    theMenu notNil ifTrue:[theMenu uncheckItem:itemName].!
zoom
        "Private - Make the active text pane fill the entire
         area of the receiver."

    | mdiDocument |

    mdiDocument := self mdiGetActive.
    mdiDocument isNil ifTrue:[^nil].
    ^mdiDocument zoom! 
setBackgroundColor
        "Private - The user selected Color/Background... from the Options
        menu; bring up a ColorDialog to select a color for the current window."

    | mdiDocument |

    mdiDocument := self mdiGetActive.
    mdiDocument isNil ifTrue:[^nil].
    ^mdiDocument setBackgroundColor!
setForegroundColor
        "Private - The user selected Color/Foreground... from the Options
        menu; bring up a ColorDialog to select a color for the current window."

    | mdiDocument |

    mdiDocument := self mdiGetActive.
    mdiDocument isNil ifTrue:[^nil].
    ^mdiDocument setForegroundColor!
initialize
        "Private - initialize the receiver"

    |mdiClient|
    super  initialize.
    mdiChildren := OrderedCollection new.
    mdiClient := MDIClient new
                    owner: self.
    self addSubpane: mdiClient.
    self mdiClient: mdiClient.! 
basicStyle
        "Private - Answer an Integer with appropriate
         constants combination for basic window style."

    ^WsOverlapped |  WsClipchildren | WsClipsiblings | WsVisible!   
buildWindow
    "Private - Create the host window for the receiver."

    menuWindow := self mdiInitMenu.
    super buildWindow.! 
mdiCascade
    "Cascade the MDI documents."

    UserLibrary sendMessage: self mdiClient asParameter
            msg: WmMdicascade
            wparam:0
            lparam:0.!  
mdiMenuWindow
    "Answer the MDI menu window. It contains the menus
    at the right side of the menubar, after the menus specific
    to the MDI document."

    ^mdiMenu! 
mdiMenuWindow: aMenuWindow
    "Answer the MDI menu window. It contains the menus
    at the right side of the menubar, after the menus specific
    to the MDI document."

    mdiMenu := aMenuWindow!  
enableItem:itemName forAllMDIChildMenus:menuName
    "Enable the itemName of the menuName.
    This menu item will be enabled for all the MDI documents."

    | theMenu|
    self  mdiChildren do:[:mdi|
    theMenu := mdi menuWindow menuTitled: menuName.
    theMenu enableItem: itemName].
    theMenu := self mdiInitMenu menuTitled: menuName.
    theMenu notNil ifTrue:[theMenu enableItem: itemName].!
cancelMode
    "Private - Cancel any internal mode of the receiver, if any."
    |mdiDocument|
    mdiDocument := self mdiGetActive.
    mdiDocument notNil
        ifTrue:[mdiDocument cancelMode].
    ^super cancelMode! 
childDeactivate

    "Private - an mdi document was deactivated
    Raise the  childDeactivate event."

    self event: #childDeactivate.        " OBSOLETE "
    self triggerEvent: #childDeactivated.!
getNextMdiChildId
    "Private - Answer the next available id for the reciever's mdiChildren."

   1 to: mdiChildren size + 1 do:[:i|
    mdiChildren at: i ifAbsent:[ ^ i]].!
mdiClose:aWindow
        "Private - close a Window."
        UserLibrary sendMessage: self mdiClient asParameter
                msg: WmMdirestore
                wparam: aWindow asParameter
                lparam:0.
        aWindow close.!
childActivate
    "Private - an MDI document was created
    Raise the  #childActivate event."

    self event:#childActivate.          " OBSOLETE "
    self triggerEvent: #childActivated.!
mdiIsMaximized

    "Private - Answer a boolean.Indicates if the active mdi document is minimized."
    | mdiChild |
    mdiChild := self mdiGetActive.
    mdiChild isNil ifTrue:[^false].
    ^(UserLibrary
        getWindowLong: mdiChild asParameter
        index: GwlStyle) & WsMaximize = WsMaximize! 
checkItem:itemName forAllMDIChildMenus:menuName
    "Check the menu itemName of the menuName.
    This menu item will be checked for all the MDI documents."

    | theMenu|
    self  mdiChildren do:[:mdi|
        theMenu := mdi menuWindow menuTitled: menuName.
        theMenu checkItem: itemName].
    theMenu := self mdiInitMenu menuTitled:menuName.
    theMenu notNil ifTrue: [theMenu checkItem:itemName].!
activate
    "Private - The receiver was activated."

    self isHandleOk ifFalse:[^self].
    super activate.!   
renumber:aWindow
    "Private - Renumber the documents."

    |documentsToRenumber i|
    documentsToRenumber:=mdiChildren select:[:each |
        each label = aWindow label].
    documentsToRenumber size > 1 ifTrue:[
    i:=0.
    documentsToRenumber do:[:each |
        i:=i + 1.
        each isHandleOk ifTrue:[
        each setWindowText: each label,':',i printString]]].
    documentsToRenumber size = 1 ifTrue:[
    documentsToRenumber first setWindowText:documentsToRenumber first label]!  
openIn: aRectangle
        "Private - Open the receiver in aRectangle."

    self buildIcon.
    self initSize: aRectangle.
    self buildMenuBar.
    children do: [:subpane | subpane open].
    ^self validate! 
setFonts
        "Private - The user selected Font... from the Options menu;
         open a FontDialog to select a font for the current window."

    | mdiDocument |

    mdiDocument := self mdiGetActive.
    mdiDocument isNil ifTrue:[^nil].
    ^mdiDocument setFonts! 
makeMdiMenu
    "Private - Make the receiver's  mdi menu bar
    The menubar is created each time a document
    is created."
    | windowPolicy |
    windowPolicy := owner windowPolicyClass on: self.
    ^windowPolicy makeMdiMenu! 
resizeChildren
        "Private - Resize all children."
    children size = 0 ifTrue: [ ^self ].
    children do: [ :subpane |
		( subpane isMDISupportPane )
			ifTrue: [ subpane resize: fullRectangle ] 
			ifFalse: [ subpane resize: rectangle ] ]!
wmCommand: wordInteger with: longInteger
    "Private - Process the command message.
    need to be reimplemented to send directly
    #performMenuItem to the menuWindow's owner."

    | control|
    (self helpModeCommand: wordInteger) notNil ifTrue:[^0].
    ( longInteger > 0 or: [ self isDialogTopPane ] )
    ifTrue: [                    "= 0 for 'enter' key"
        control :=  self childAtId: wordInteger lowWord.
        control notNil
            ifTrue: [ control syncControlEvent: wordInteger highWord with: longInteger ]]
    ifFalse: [
        self menuWindow owner sendInputEvent: #performMenuItem:     "specify the receiver now !!"
        with: wordInteger lowWord].

    ^nil! 
mdiDestroy:aWindow
    "Private - destroy the mdi document a Window."
        UserLibrary sendMessage: self mdiClient asParameter
                msg: WmMdidestroy
                wparam: aWindow asParameter
                lparam: 0.!  
mdiRestore:aWindow
        "Private - restore the MDI document aWindow."

        UserLibrary sendMessage: self mdiClient asParameter
                msg: WmMdirestore
                wparam: aWindow asParameter
                lparam: 0.! 
updateRectangle
        "Private - Update rectangle to be the same
         as the Windows."
    super updateRectangle.
	fullRectangle := rectangle deepCopy.
    self getFreeClientArea: rectangle.!
validate

    "Private - Reimplemented here to force
    the repainting of the MDIFrame before the
    creation of the MDI documents."

    | answer |
    answer := super validate.
    answer notNil
        ifTrue: [ self updateWindow ].
    mdiChildren size > 0
         ifTrue: [ mdiChildren do: [ :each | each validate ] ].
    ^answer!   
isMDIFrame
    "Answer true if receiver is an instance of class
     MDIFrame, else answer false."

    ^true!
mdiClient
    "Private- Answer the receiver's MDI client subpane."

    ^self propertyAt:#mdiClient!   
mdiClient:aSubpane
    "Private- Set the receiver's MDI client subpane."

    self propertyAt:#mdiClient put:aSubpane! 
mdiInitMenu

    "Private - answer the receiver's initMenu."

    ^initMenu!  
mdiInitMenu:aMenuWindow

    "Private - set the receiver's initMenu."

    ^initMenu := aMenuWindow!  
helpContext
    "Private - Answer the receiver help context."
    |active|

    active := self mdiGetActive.
    active notNil
        ifTrue:[^active helpContext]
        ifFalse:[^super helpContext].! 
helpContext: anAssociation
    "Private - Set the receiver help context."
    |active|

    active := self mdiGetActive.
    active notNil
        ifTrue:[^active helpContext: anAssociation]
        ifFalse:[^super helpContext: anAssociation].!   
mdiNext
    "Private - Activate the next mdi document."

    UserLibrary sendMessage: self mdiClient asParameter
            msg: WmMdinext
            wparam: 0
            lparam: 0.!   
setInitMenu
    "Private - update the frame menu bar when no mdi documents are opened."
    | aMenuWindow |

    menuWindow := self mdiInitMenu.

    aMenuWindow := self mdiMenu window handle.

    UserLibrary sendMessage: self mdiClient asParameter
        msg: WmMdisetmenu
        wparam: menuWindow handle asParameter
        lparam: aMenuWindow asParameter.

    UserLibrary drawMenuBar: self asParameter.!  
mdiCloseAll
     "Close all the MDI documents which are not minimized."
    |childrenToClose|
    childrenToClose := mdiChildren copy.
    childrenToClose do:[:each|
    ((each isHandleOk ifTrue:[each minimized] ifFalse:[false]) not & each systemMenuItemClose)
        ifTrue:[each close]].! 
close
    "The receiver is being closed
    Answer nil if one of the receiver's document has not
    been closed."
    super close.
    mdiChildren size >0 ifTrue:[^nil].!  
mdiChildren
    "Answer a collection of the currently opened MDI documents."

    ^mdiChildren!
mdiMenu
    "Private- answer MDI Window menu."

    ^menuWindow menus detect:[:m|m isMDIMenu] ifNone:[^menuWindow menus last]! 
clearTextModified
    "Private - Clear the modified flag on all the
     receiver's TextPanes."
    mdiChildren do: [:pane |   pane clearTextModified].
    ^super clearTextModified.!
removeMdipane: aWindow
    "Private - An mdi document is being closed."

    mdiChildren remove: aWindow ifAbsent:[].! 
setDocumentMenu: anMdiChild
    "Private- Update frame's menu bar."
    |aMenuWindow|

    self mdiGetActive == anMdiChild
        ifFalse:[^self].

    menuWindow := anMdiChild menuWindow.

    aMenuWindow := self mdiMenu window handle.

    UserLibrary sendMessage: self mdiClient asParameter
        msg:WmMdisetmenu
        wparam: menuWindow handle asParameter
        lparam: aMenuWindow asParameter.

    UserLibrary drawMenuBar: self asParameter.!   
statusText:anObject
        "Private - Set the receiver's statusText property."
    self propertyAt: #statusText put: anObject! 
addSmalltalkMenu
        "Private - add the menus that are to be located
         on the menu bar before any application-specific
         menus (File & Edit)."!  
buildMdiMenuBar
         "Private - Add Help menu to an MDIChild."
    applicationWindow mdiMenuWindow addMenu:  self helpMenu.!
isMDISupportPane
        "Answer true if receiver is a support pane for MDI."
    ^true!
toolPane
        "Answer the receiver toolPane if any, else answer nil."
    parent isNil ifTrue: [ ^nil ].
    ^parent toolPane!  
statusText: aString
        "Set the receiver's statusText to aString."
    views size < 1 ifTrue: [
        self addView: ( self topPaneClass new owner: self ) ].
    ^(views at: 1) statusText: aString!   
toolPane
        "Answer the receiver's toolPane 
         if any, else answe nil."
    | ownerWindow |
    ownerWindow := Notifier findWindow: owner asInteger.
    ownerWindow isNil ifTrue:[ ^nil ].
    ^ownerWindow toolPane!  
frame
        "Answer the receiver's frame if any."
    self mainView isMDIChild ifFalse:[^nil].
    ^self mainView frame! 
defMDIChildProc: aWindowHandle
        msg: msgInteger
        wparam: wordInteger
        lparam: longInteger
    <api: DefMDIChildProcA ulong ulong ulong ulong ulong>
    ^self invalidArgument!  
toolPane
        "Answer the receiver's toolPane 
         if any, else answer nil."
    ^self mainView toolPane!