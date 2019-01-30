"3.0.0.2"
!  

MDIChild subclass: #WBMDIChild
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!

!MDIChild methods !   
buildWindow
        "Private - Create the document for the receiver."
        "see Microsoft online Q70080 Creating a Hidden MDI Child Window."

    | mdiCreate answer max anAddress focusPane |
    max := self frame mdiIsMaximized.
    NotificationManager newWindow notNil ifTrue: [ ^nil ].
    self frame isActive ifFalse: [
        self frame makeActive.
        self frame updateWindow ].

	#modifiedByOSI.
	"Modified by OSI to prevent redraw during creation of child
	window so that child window will not flash on screen when
	it is created then hidden."
	self parent noRedraw: true.

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

	#modifiedByOSI.
	"Modified by OSI to prevent redraw during creation of child
	window so that child window will not flash on screen when
	it is created then hidden."
	self frameWindow handle hideWindow.

    self updateClient.! !

!MDIChild methods !   
initMdiWindowSize
        "Private-Answer the default size of a document."
    | rect extent origin answer offset |
    rect := self frame mdiClient rectangle.

    "if framingBlock notNil, use it for initial rectangle."
    framingBlock notNil
        ifTrue: [

            #modifiedByOSI.
            answer := framingBlock value: rect.
            answer leftTop < self autoCascadeTolerance ifTrue: [
                offset := (UserLibrary getSystemMetrics: SmCysize) +
                    (UserLibrary getSystemMetrics: SmCyframe).
                answer moveTo: ((self frame mdiChildren size - 1) * (offset @ offset))].
            ^answer]

        ifFalse: [
            extent := (rect width * 24 // 25) @ (rect height * 24 // 25).
            extent := extent - ((self frame mdiChildren size - 1) * ( 8 @ 8)).
            origin :=(self frame mdiChildren size - 1) * (8 @ 8).
            ^origin extent: extent ].! !

!ViewManager methods ! 
mdiCloseAll
    "Added by OSI. Close all MDI documents
     which are not minimized."
    #addedByOSI.
    self frame mdiCloseAll! !

!StandardWindowPolicy methods !   
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

        #modifiedByOSI.
        "Support for WindowBuilder."
        (Smalltalk includesKey: #WindowBuilder) ifTrue: [self addWindowBuilderMenu].

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
    window menuWindow systemMenu owner: window.! !

!ViewManager methods !  
mdiArrange
    "Added by OSI. Arrange the MDI documents."
    #addedByOSI.
    self frame mdiArrange! !

!WBMDIChild methods !   
wmMouseactivate: wParam with: lParam
        "Private - If mouse has been clicked on an inactive
         window, select it."
    self mainWindow mdiSelected: true.
    ^MaActivate
! !

!ViewManager methods !   
mdiTile
    "Added by OSI. Tile the MDI documents."
    #addedByOSI.
    self frame mdiTile! !

!MDIChild methods !  
destroy
        "Private - destroy the receiver."
    self frame removeMdipane: self.
    self frame mdiDestroy: self.
    self frame avoidDestroyCurrentMenu: self.

    #modifiedByOSI.
    "Check if menuWindow has a valid handle"
    self menuWindow isHandleOk ifTrue: [self menuWindow destroy].

    MDIFrame mdiSelected: true.! !

!ViewManager methods !  
topPaneClass
        "Private - Answer the default top pane class."
    ( Smalltalk includesKey: #MDISystem ) ifTrue: [
        Smalltalk isRunTime ifFalse: [
            ( Smalltalk at: #MDISystem ) isActive
                ifTrue:[ ^Smalltalk at: #MDIChild ] ] ].

    #modifiedByOSI.
    "Support opening any window as an MDI parent or child"
    ^Smalltalk at: (Smalltalk at: #TopPaneClass ifAbsent: [#TopPane])! !

!ViewManager methods ! 
frame
        "Answer the receiver's frame if any."

    #modifiedByOSI.
    "Answer the mainView if it *is* the frame"
    self mainView isMDIFrame ifTrue: [ ^self mainView ].

    self mainView isMDIChild ifFalse:[^nil].
    ^self mainView frame! !

!ViewManager methods !  
mdiCascade
    "Added by OSI. Cascade the MDI documents."
    #addedByOSI.
    self frame mdiCascade! !

!MDIChild methods ! 
autoCascadeTolerance
		#addedByOSI.
    ^1@1! !
   
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!