3.1.0.106
   
buildMenuBar
        "Private - Create the menus that make up the menu bar.
        Do nothing for a dialog window. "!  
disableControls
        "Necessary for child topPane"
    self partsVosOnly.  " Only used on VOS"!  
partCanBeNestedChild: aNestedPart
    "Private -  Answer whether the receiver could be a child
    of the nested part <aNestedPart>.  If the receiver is
    shrunk, it can never be a nested part child.  If <aNestedPart>
    is a nested part that is directly, or indirectly through several
    nested levels, a child of the editor pane, allow the receiver
    to be a (desktop) child.
        Otherwise, on OS/2 check the desktop child property.
    On Windows, the receiver can never be a child of another
    window."

    ( self partIsEditing and: [ self partIsShrunk ])
        ifTrue: [ ^false ].

    ( self partNonNestedPartParent: aNestedPart ) isPARTSEditorPane
        ifTrue: [ ^true ].

    ^self
        partsIfOS2Do: [ self partIsDesktopChild not ]
        partsIfWindowsDo: [ false ].
!  
initializePropertyOptions
        " Private - class initialization. "

    VirtualKeysMap := Dictionary new.
    VirtualKeysMap
        at: 'BckSp' put: BackspaceKey;
        at: 'BckSpace' put: BackspaceKey;
        at: 'PgUp' put: PageUpKey;
        at: 'PgDn' put: PageDownKey;
        at: 'End' put: EndKey ;
        at: 'Home' put: HomeKey;
        at: 'Left' put: LeftKey;
        at: 'Right' put: RightKey;
        at: 'Down' put: DownKey;
        at: 'Ins' put: InsertKey;
        at: 'Del' put: DeleteKey;
        at: 'F2' put: F2Key;
        at: 'F3' put: F3Key;
        at: 'F4' put: F4Key;
        at: 'F5' put: F5Key;
        at: 'F6' put: F6Key;
        at: 'F7' put: F7Key;
        at: 'F8' put: F8Key;
        at: 'F9' put: F9Key;
        at: 'F10' put: F10Key;
        at: 'F11' put: F11Key;
        at: 'F12' put: F12Key;
        yourself!  
labelBrowseClasses
        " Answer the label of the Browse Classes item. "
    ^self mnemonic, 'Browse Classes'!   
labelSamples
        " Answer the label of the Samples item. "
    ^LabelSamples!   
enableControls
        "Necessary for child topPane"
    self partsVosOnly.  " Only used on VOS"!   
initialize
        " Private - class initialization "

    self
        initializeEventsTriggered;
        initializeFrameWindowClass.!  
appendItem: item accel: accel to: aMenu selector: itemPartName
        "Append the item and the accel (both passed
         as strings) to the menu in their translated form.
		set the selector to be the itemPartName.  In PARTS, the selector
		is not used for invokation of the menu.  However, the base Smalltalk
		is using the selector for identifying the help panel which goes with each
		item at execution time."
    | array |
    accel isNil
        ifTrue: [
            aMenu appendItem: item selector: itemPartName]
        ifFalse: [
            array := self acceleratorOf: accel.
            aMenu
                appendItem: (item, (String with: 9 asCharacter), accel)
                selector: itemPartName
                accelKey: (array at: 1)
                accelBits: (array at: 2)]! 
waitForAnswer
        " Answer whether the client of a modal
        dialog is suspended until the dialog
        is closed. "

    ^self suspendClient! 
defaultForeColor
        "Answer the default background color for the receiver class."
    ^Color menuText! 
labelPrint
        " Answer the label of the Print item. "
    ^self mnemonic, 'Print...'!  
standardSmalltalkMenuFor: aHelpManager
        " Answer a standard Smalltalk Help menu for anOwner. "
    ^self standardRuntimeMenuFor: aHelpManager!   
buildWindow: parentWindow
		"Private - ." 
    self partsIfOS2Do: [
		parent isFrameWindow
			ifFalse: [self initializeFrameWindow].
        parent parent: parentWindow].
    ^self buildWindow!   
isPARTSMenuComponent
        "Answer whether the receiver is a PARTS
         MenuLabel, Menu, or menu item."
    ^true!   
isPARTSMenuSeparatorPart
    "Answer whether the receiver is an instance
    of PARTSMenuSeparatorPart"
    ^true! 
buildWindowWindows
        "Private - Create the host window for the receiver."
        " Platform dependent implementation "
    | oldStyle result oldId |

    self partsVwOnly.  " Only used on VW"

    self superWindow isPARTSWindow
        ifTrue: [
            MessageBox message: 'Sorry, nested main window is not allowed.'.
            self superWindow removeSubpane: self.   "so that user can continue and repair it"
            ^self].

    oldStyle :=
        style isNil
            ifTrue: [self getStyle ]
            ifFalse: [ style ].
    style := self buildWindowStyle: oldStyle.
    oldId := self id.
    self id: nil.  "The menu handle for window creation.  Refer to 'id' method."
    result := super buildWindow.
    self id: oldId.
    style := oldStyle.

    result notNil
        ifTrue: [ self receiveMessages ]
        ifFalse: [ ^nil ].!  
appendSamplesItem: aSelector
        " Append a Samples command item. "
    self appendItem: self class labelSamples
        selector: aSelector.! 
appendNewItem: aSelector
        " Append a New command item. "
    self appendItem:
            self class labelNew,
            self class tabString, 'Alt+N'
        selector: aSelector
        accelKey: $n
        accelBits: self class altCharAccelerator.!
contents: aLabel

    ^self labelWithoutPrefix: aLabel! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        labelWithoutPrefix: label copy;
        framingBlock: (framingBlock partMirrorCopy: aMirrorCopyDictionary);
        rectangleAttribute: (rectangle partMirrorCopy: aMirrorCopyDictionary);
        menuWindow: (menuWindow partMirrorCopy: aMirrorCopyDictionary);
        handlersAttribute: ( self handlersAttribute partMirrorCopy: aMirrorCopyDictionary).

    ^copy!   
menuPart
    "Private - Answer the menu part for the receiver."
    | actions anAction receiver selector |

    ( actions := self actionListForEvent: #clicked ) notEmpty
        ifTrue: [
            anAction := actions first.
            [   anAction notNil
                    ifTrue: [ "Traverse nested part and application boundaries"
                        receiver := anAction receiver.
                        selector := anAction selector.
                        receiver isPARTSNestedPart
                            or: [ receiver isPARTSApplication
                            or: [ receiver isPARTSPartAccessorPart ]]]
                    ifFalse: [ false ]]
                whileTrue: [
                    anAction := receiver menuClickedActionOf: selector ]].

    ^receiver isPARTSMenuPart
        ifTrue: [ receiver ]
        ifFalse: [ nil ]!
appendBrowseDiskItem: aSelector
        " Append a Browse Disk command item. "
    self appendItem:
            self class labelBrowseDisk,
            self class tabString, 'Alt+D'
        selector: aSelector
        accelKey: $d
        accelBits: self class altCharAccelerator.!  
childrenInBuildOrder
        "Private - answer the child panes in the order they should be built."

	^ self partsIfOS2Do: [
		super childrenInBuildOrder ]
	  partsIfWindowsDo: [
		self partsVwOnly.  " Only used on VW" 
		self partIsEditing
			ifTrue: [ self children ]
			ifFalse: [ super childrenInBuildOrder ]]!
appendUsingHelpItem: aSelector
        " Append a Using Help command item. "
    self appendItem: self class labelUsingHelp
        selector: aSelector.!  
label: aString
        " Private "
    label := aString.!   
exitOnLastWindow: aBoolean
    "Set whether the image will exit when the the last
    window in the image is closed"

    ExitOnLastWindow :=
        ( aBoolean ifTrue: [ nil ] ifFalse: [ false ])
!  
initializeRuntimeData
        " Private - initialize values in the runtime library
        which must be set at component installation time
        (can't be specified statically in the library). "

    self partLibraryClassesToInitialize do: [ :aClass | aClass initialize ].! 
menuObject: aMenu
        "Private - "
    menuObject := aMenu! 
defaultFrameCreationFlags
        "Private - Answer the default PM frame creation style for the receiver."
    self partsVosOnly.  " Only used on VOS"

    ^DefaultFrameStyle!   
setWaitForAnswer: aValue
        " Answer whether the client of a modal
        dialog is suspended until the dialog
        is closed. "

    | aBoolean |
    aBoolean := self asBoolean: aValue.
    aBoolean isBoolean
        ifFalse: [ ^self error: 'Must be true or false' ].
    self suspendClient: aBoolean.
    ^aBoolean!  
initialize
        " Private - class initialization. "

    super initialize.
    self initializePropertyOptions.!
wmExternalCall: mp1 with: mp2
    "This event makes modal popup menu being able
     to tell whether inside or outside of the menu had
     been selected.  'mp2' is the menu being terminated."

    self sendInputEvent: #menuEnd: with: mp2 asWindowHandle.
    ^1!  
getLabelFrom: aString
        "Answer the label part of aString menu item."

    | aStream |
    aString isString ifFalse: [ ^aString ].  " bitmap "
    aStream := ReadStream on: aString.
    ^( aStream upTo: Tab )! 
canApplyStyle
        "Private - answer whether the receiver's style can change
        after it has been created."
    ^false!
validate
        "Private - The host window for the receiver was
         just created or recreated."
    super validate.

         "On the w.b., whenValid is only needed to set the initial
    state of the receiver.  Once created, the receiver remembers
    this information via inst var, etc. if it were necessary to
    recreate it (undo delete)."
    self partIsEditing
        ifTrue: [
            self propertyAt: #whenValid put: nil ].!   
labelSelectAll
        " Answer the label of the Select All item. "
    ^'Select ', self mnemonic, 'All'!   
popUpAt: aPoint in: aWindow
        "Private - Pop up the receiver at aPoint in aWindow."
    | realItems |

    "Popup position depends of the number of items.
        Take into account the hidden items"
    realItems := menus first items.
    menus first items: ( Array new:
        ( self owner children select: [ :aMenuItemPane |
            aMenuItemPane hidden not ]) size ).
    super popUpAt: aPoint in: aWindow.
    menus first items: realItems.

    handle subclass.
    Notifier add: self!
labelUsingHelp
        " Answer the label of the Using Help item. "
    ^LabelUsingHelp!
isChecked
    | isChecked |
    theMenu isNil ifTrue: [^nil].
    isChecked := theMenu isChecked: self getMenuItem label.
    isChecked ifTrue: [self triggerEvent: #checkedIsTrue].
    ^isChecked! 
updateSliders
        "Private - Reimplemented here because PARTSMenuItemPanes
         have no scrollbars."!   
openWindow
        "Private - Take over the popup menu."
    | topPane |
    topPane := self mainView.
    topPane
        "Version 1:
        windowPolicy: ( PARTSWindowPolicy new
            whenBuildMenuSend: #createMenuBarMenus: to: self;
            yourself  ).
        "
        windowPolicy: NoMenusWindowPolicy new;
        when: #menuBarBuilt
            send: #createMenuBarMenus: to: self with: topPane;
        yourself.
    self pane
        when: #needsPopupMenu
            send: #buildPopupMenu to: self.
    topPane openWindow.!   
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

	^self partsIfOS2Do: [
		aWindow isPARTSMenuBar ]
	partsIfWindowsDo: [
		aWindow isPARTSMenuPane ]! 
borderHeight
        "Answer the height of a non-sizing window border."
    ^OperatingSystem getSystemValue: SystemValueWindowBorderHeight! 
osOwner
    "Private- Answer the operating system owner handle. "
    | client |
    ^self
        partsIfOS2Do: [
            client := ( self parent isFrameWindow
                ifTrue: [ self frameWindow ]
                ifFalse: [ self ]).
            ( PARTSHostInterface hostWindowLibrary
                queryWindow: client asParameter
                cmd: QwOwner) asWindowHandle ]
        partsIfWindowsDo: [
            WindowHandle fromInteger:
                ( PARTSHostInterface hostWindowLibrary
                    getWindowLong: self handle asParameter
                    index: GwlHwndParent ) ]!  
menuEnd: aMenuWindow
        "Private - do nothing"! 
partMessages
        " Answer the PARTS message interface of the receiver. "

    | operationMessages |
    ^( operationMessages := self partMessagesOperations )
        concatenateSeparated: self partMessagesProperties
        defaultItem: operationMessages defaultItem! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #hiddenIsTrue )
        separators: #( )
        defaultItem: #hiddenIsTrue!  
supportsMenuBar
        " Private - answer whether menu bar is allowed on the receiver. "
    ^false!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    ^ self partFontOrSysFont charSize * (40 @ 17)! 
contents
        "Answer the menu title."
    ^label!   
currentItemIndex
    "Private - Answer the current drag drop target position"

    self implementedBySubclass! 
appendTutorialItem: aSelector
        " Append a Tutorial command item. "
    self appendItem: self class labelTutorial
        selector: aSelector.!  
appendSaveItem: aSelector
        " Append a Save command item. "
    self appendItem:
            self class labelSave,
            self class tabString, 'Alt+S'
        selector: aSelector
        accelKey: $s
        accelBits: self class altCharAccelerator.! 
altCharAccelerator
        " Answer the accelerator bits for Alt+<char>. "
    ^AfAlt | AfChar! 
defaultBackColor
	"Answer the default background color for the receiver class."
	^DialogTopPane defaultBackColor!   
appendSaveAsItem: aSelector
        " Append a Save As command item. "
    self appendItem: self class labelSaveAs
        selector: aSelector.!   
COMMENT
    "This class is separate from PARTSMenuBar because
    PARTSMenuBar represents static instances of the
    drop down list menus.  In OS/2, a dynamic menu must
    be created for a popup menu (you can't share)."!
appendBrowseClassesItem: aSelector
        " Append a Browse Classes command item. "
    self appendItem:
            self class labelBrowseClasses,
            self class tabString, 'Alt+B'
        selector: aSelector
        accelKey: $b
        accelBits: self class altCharAccelerator.! 
asBoolean: aValue
        " Private - answer aValue as a number. "
    | trimmed |
    aValue isBoolean
        ifTrue: [ ^aValue ].
    aValue isString
        ifTrue: [
            trimmed := aValue trimBlanks.
            ( trimmed equalsIgnoreCase: 'true' )
                ifTrue: [ ^true ].
            ( trimmed equalsIgnoreCase: 'false' )
                ifTrue: [ ^false ].
           ].
    ^aValue     " probably an error, let it surface "!  
appendCloseItem: aSelector
        " Append a Close command item. "
    self appendItem:
            self class labelClose,
            self class tabString, 'Alt+F4'
        selector: aSelector
        accelKey: F4Key
        accelBits: self class altSpecialKeyAccelerator.!
openModeless
    "Open a modeless dialog box."

    self modal: false.
    ^super open
! 
getWindowToDisable: aParent
        " Private - answer the window to disable when the receiver is opened. "

    | windowToDisable |
    self partIsEditing  "When the part is being edited, do not disable anything.  [MT 2/9/94]"
        ifTrue: [ ^nil ].
    windowToDisable := ( aParent isNil
        ifTrue: [ Notifier findWindow: WindowHandle queryActive ]
        ifFalse: [ aParent ] ).
    ( PARTSSessionManager isWorkbenchSession
    and: [ ( self isOkToDisable: windowToDisable ) not ] )
        ifTrue: [ windowToDisable := nil ].
    ^windowToDisable!  
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message."
    ^1!   
validate
        "Private - The host window for the receiver was
         just created or recreated."

    super validate.
    (self partIsEditing and: [self partIsShrunk])
        ifTrue: [self partShrink].!
resizeChildren
        "Private - Resize all children."
    | remainingClientArea |
    self partsIfOS2Do: [ ^super resizeChildren ].
    self partsVwOnly.  " Only used on VW"

    children size = 0 ifTrue: [ ^self ].

    "During run-time, nested parts are built during the initial resize."
    remainingClientArea :=
        self isHandleOk
            ifTrue: [ self entireClientArea ]
            ifFalse: [ rectangle copy ].
    self childrenAffectingClientArea
        do: [ :subpane |
            subpane resize: remainingClientArea.
            remainingClientArea := subpane freeClientArea: remainingClientArea ].
    self childrenInBuildOrder do: [ :subpane |
        subpane affectsFreeClientArea
            ifFalse: [ subpane resize: remainingClientArea ]]! 
appendPasteItem: aSelector
        " Append a Paste command item. "
	| accelaratorString |

    self 
		partsIfOS2Do: [accelaratorString := 'Shift+Ins' ]
    	partsIfWindowsDo: [accelaratorString := 'Ctrl+V' ].

    self
        appendItem: self class labelPaste, self class tabString, accelaratorString
            selector: aSelector
            accelKey: $v
            accelBits: self class controlCharAccelerator;
        accelKey: InsertKey
            accelBits: self class shiftSpecialKeyAccelerator
            for: aSelector.!   
shiftSpecialKeyAccelerator
        " Answer the accelerator bits for Shift+<special key>. "
    ^AfShift | SpecialKeyAccelerator!   
partNeedsResizeToContents
        " Private - answer whether the receiver needs to
        be resized to install a property edit change. "
    ^true!  
menuObject
    ^menuObject!  
display
        "Private - Display the receiver as a line."
    self doGraphics: [
        graphicsTool 
			fill: Color menuBackground;
			place: (rectangle left @ rectangle center y);
            line: (rectangle right @ rectangle center y)]! 
isDisabled
        "Answer whether the menu item is disabled."
    | isDisabled |
    theMenu isNil ifTrue: [^nil].
    isDisabled := theMenu isDisabled: self getMenuItem label.
    isDisabled ifTrue: [self triggerEvent: #disabledIsTrue].
    ^isDisabled! 
recreateWindow
        "Private - recreate the host window, because something
         needs to change which cannot be changed dynamically
         by the host operating system."

    self partsIfOS2Do: [ ^super recreateWindow ].

    self partsVwOnly.  " Only used on VW"

    self closeView.
    self partOpen.!   
adjustFraming: rectangleInParent
        "Private - adjust the receiver's framing to its new size,
         rectangleInParent (parent-relative coordinates)."

    self partIsEditing
        ifTrue: [ ^super adjustFraming: rectangleInParent ].!  
processIndex: index
    "Private"
    | item |
    item := self findItemAt: index.
    item notNil ifTrue: [item click]!  
helpWindowLabel
        "Private - "
    ^'Help for ' , self label! 
partHasVisualParts
        " Answer whether the receiver contains any visible parts. "
    ^false!  
validateShow
    "Private - Remove the system menu items that don't apply in a dialog window."

    | systemMenu positions |

    self partIsEditing
        ifTrue: [ ^super validateShow ].

    systemMenu := self systemMenuHandle asParameter.
    positions :=
        self partsIfOS2Do: [ #( 1 2 2 2 2 2 3 3 ) ]
        partsIfWindowsDo: [ #( 1 2 2 2 2 3 3 ) ].
    positions do: [ :aMenuPosition |
        PARTSMenuWindow
            deletePosition: aMenuPosition
            menu: systemMenu ].

    super validateShow!   
addMenuLabel: aMenuLabelPart
        "Add a menu label part to the receiver's menu bar."
    menuWindow addSubpane: aMenuLabelPart! 
display
        "Private - Display the background color."
    | color |
    color:= self backColor.
    graphicsTool fill: self entireClientArea color:
        (color isNil
            ifTrue: [ self defaultBackColor ]
            ifFalse: [ color ]).!   
frameWindowClass: aClass
        " Private - register the OS/2 frame window class "

    frameWindowClass := aClass.!  
labelPrintSetup
        " Answer the label of the Print Setup item. "
    ^'Prin', self mnemonic, 't Setup...'! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
isPARTSMenuBitmapItemPart
    "Answer whether the receiver is an instance
    of PARTSMenuBitmapItemPart"
    ^true!   
appendOpenItem: aSelector
        " Append an Open command item. "
    self appendItem:
            self class labelOpen,
            self class tabString, 'Alt+O'
        selector: aSelector
        accelKey: $o
        accelBits: self class altCharAccelerator.!
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    ^40 @ 32!  
appendSelectAllItem: aSelector
        " Append a Select All command item. "
    self appendItem:
            self class labelSelectAll,
            self class tabString, 'Ctrl+A'
        selector: aSelector
        accelKey: $a
        accelBits: self class controlCharAccelerator.!
partLibraryClassesToInitialize
        " Private - answer the classes in the library which need to be
        initialized when the library is installed "

    ^PARTSMenuItemPane withAllSubclasses, ( #(
        #PARTSStandardMenu
        #PARTSStandardHelpMenu
        #PARTSHelpMenu
        #PARTSTopPane
        #PARTSWindowPart
        #PARTSDialogWindowPart
        #PARTSMenuPart
        #PARTSMenuLabelPart
        ) collect: [ :className | Smalltalk at: className ] )!   
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message."
    ^1!   
getAccelFrom: aString
        "Answer the accelerator part of aString.
         The menu label and accelerator are separated by
         a tab character."

    | tabIndex accel |
    aString isString ifFalse: [ ^nil ].
    tabIndex := aString indexOf: Tab ifAbsent: [ ^nil ].
    accel := aString
        copyFrom: tabIndex + 1
        to: aString size.
    ^accel!  
partIsWindow
        "Private - When the receiver is shrunk inside
        a PARTSWorkbench it is represented by an icon,
        and it is not to behave like a window."
    ^self partIsShrunk not
!   
suspendClient: aBoolean
        " Specify whether the client of a modal
        dialog is suspended until the dialog
        is closed. "
    self propertyAt: #suspendClient put: aBoolean.! 
labelClear
        " Answer the label of the Clear item. "
    ^'C', self mnemonic, 'lear'! 
allMenus: aCollection
        "Private - set allMenus of the receiver"

    allMenus := aCollection.!  
showWindow
        "Show the receiver.
        Note: If sent before the window is opened,
        remember the opening state."
    | initialState |

    self partIsEditing ifTrue: [ ^super showWindow ].

    self isHandleOk
        ifFalse: [
            "Remember the desired initial state. Override the initial property."
            self openHiddenOverride: #show.
            ^self ].

    ( initialState := self initialState ) notNil "validate shown"
        ifTrue: [
            self showWindow: initialState.
            self initialState: nil ].

    self
        partsIfOS2Do: [ super showWindow ]
        partsIfWindowsDo: [ self showWindow: collapsed ].!   
canMinimize
    "Private -
        Answer whether the receiver can be minimized on the desktop"
    ^true! 
mainWindow
        "Answer the receiver's main window.  If the DialogTopPane's
          parent is kind of Window then it returns its parent's main
          window else it returns self.  (Needed for cases where
          DialogTopPane is a subpane of TopPane.)"
    | ancestor |
    ^(ancestor := self superWindow) partIsWindow
        ifTrue: [ancestor mainWindow]
        ifFalse: [self]!   
setLabel: aString
        "Set the label of the receiver to aString.  Answer aString."
    self labelWithoutPrefix: ( aString isString
        ifTrue: [ aString ]
        ifFalse: [ aString isNil ifTrue: [ '' ] ifFalse: [ aString asString ] ] ).
    ^aString!  
appendHelpIndexItem: aSelector
        " Append a Help Index command item. "
    self appendItem: self class labelHelpIndex
        selector: aSelector.!  
hasSmalltalkMenuBar
        "Answer whether the window should have the
        the default Smalltalk menu bar."
    ^false!
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^true!   
visibleIndex
    "Private - Answer the index of the receiver, excluding
    preceding menu items that are hidden.  If the receiver
    itself is hidden, then answer the position where it should
    go."
    | visibleIndex menuItemPanes |

    visibleIndex := index.
    menuItemPanes := self superWindow children.
    menuItemPanes do: [ :aMenuItemPane |
        "Adjust real index if there are other hidden items"
        ( aMenuItemPane indexAttribute < index
            and: [ aMenuItemPane hidden ])
                ifTrue: [ visibleIndex := visibleIndex - 1 ]].
    ^visibleIndex!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #isDisabled
            #check #uncheck #isChecked
            #show #hide #isHidden
            #label #setLabel: )
        separators: #( 3 6 9 )
        defaultItem: #disable!   
initializePropertyOptions
        " Private - class initialization. "

    " top pane style constants "
    self partsIfWindowsDo: [
        borderStyleLabels := Array
            with: (Array with: 'Size border' with: WsSizingBorder)
            with: (Array with: 'Single-line border' with: WsNonSizingBorder).
        borderStyleValues := nil.
        SystemMenuLabel := 'Control menu'.
        "DEBUG - check ported implementation"
        ( (borderStyleLabels =  #( #('Size border' 262144 ) #('Single-line border' 8388608) ) )
        and: [borderStyleValues =  nil ] )
            ifFalse: [self error: 'bug'].
        ].
    self partsIfOS2Do: [
        borderStyleLabels := Array
            with: (Array with: 'Size border' with: WsSizingBorder)
            with: (Array with: 'Single-line border' with: WsNonSizingBorder)
            with: (Array with: 'Dialog border' with: WsDialogBorder).
        borderStyleValues := Array
            with: WsSizingBorder
            with: WsNonSizingBorder
            with: WsDialogBorder.
        SystemMenuLabel := 'System menu'.
        "DEBUG - check ported implementation"
        ( (borderStyleLabels =  #( #('Size border'  8) #('Single-line border' 512) #('Dialog border' 256)) )
        and: [borderStyleValues =  #(8 512 256) ] )
            ifFalse: [self error: 'bug'].
        ].!   
editMenuCreate
        " Private - answer a new Edit menu. "
    ^self editMenuCreateFor: self pane!
disable
    "Disable the menu bar item associated with the receiver"
    | menuPart |

    ( menuPart := self menuPart ) notNil
        ifTrue: [
            self superWindow
                disableMenu: menuPart menuObject ]! 
osOwner: aWindow
    "Private- Set the operating system owner handle to the new owner"
    | hostWindowLibrary client clientOwner |
    hostWindowLibrary := PARTSHostInterface hostWindowLibrary.
    aWindow isNil
        ifTrue: [    " clear the owner "
            self
                partsIfOS2Do: [
                    client := ( self parent isFrameWindow
                        ifTrue: [ self frameWindow  ]
                        ifFalse: [ self ] ).
                    hostWindowLibrary
                        setOwner: client asParameter
                        owner: PARTSHostInterface desktopWindowHandle ]
                partsIfWindowsDo: [hostWindowLibrary
                    setWindowLong: self handle asParameter
                    index: GwlHwndParent
                    long: nil asParameter]
            ]
        ifFalse: [    " set the owner "
            self
                partsIfOS2Do: [
                    self isDialogWindow
                        ifTrue: [ self pmOwner frameWindow disable ].
                    client := ( self parent isFrameWindow
                        ifTrue: [ self frameWindow ]
                        ifFalse: [ self ]).
                    clientOwner := ( aWindow parent isFrameWindow
                        ifTrue: [ aWindow frameWindow ]
                        ifFalse: [ aWindow ]).
                    hostWindowLibrary
                        setOwner: client asParameter
                        owner: clientOwner asParameter]
                partsIfWindowsDo:
                    [self isDialogTopPane
                        ifTrue: [ self parent frameWindow disable ].
                    hostWindowLibrary
                        setWindowLong: self handle asParameter
                        index: GwlHwndParent
                        long: aWindow asParameter]
            ]!   
partIsWindow
        "When the a topPane is shrunk inside a PARTSWorkbench
        it is represented by an icon, and it is not to behave like a window."
    ^self partIsEditing
        ifTrue: [ self partIsShrunk not ]
        ifFalse: [ true ]!
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "

   ^super partMirrorCopyPropertiesToExclude,
        #( #sysMenu #subPaneWithFocus #initialState )!
initSize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
	
	self framingBlock bottom:
		( self framingBlock pixelToScaleUnitVertical: SysFont height + 2 ).
	super initSize: aRectangle!  
cancelAnswer
        "Answer what the receiver should answer
        if the user clicks on the cancel button."
    ^PARTSException new!
mnemonic
        " Answer a string containing the platform-dependent
        character used to mark the mnemonic character. "
    ^MnemonicString! 
updateSliders
        "Private - Reimplemented here because PARTSMenuItemPanes
         have no scrollbars."!   
labelCopy
        " Answer the label of the Copy item. "
    ^self mnemonic, 'Copy'!
enableControls
        "Private - Enable the receiver."! 
labelWordWrap
        " Answer the label of the Word Wrap item. "
    ^self mnemonic, 'Word Wrap'!  
title
        " Answer the menu title. "
    self implementedBySubclass!
initializePropertyOptions
        " Private - class initialization. "

    " Dialog top pane style constants "
    self partsIfWindowsDo: [
        DefaultFrameStyle :=
            WsTitleBar |
            WsSystemMenu |
            WsPopUp
"DsNoidlemsg DsModalFrame".
        borderStyleLabels := Array
            with: (Array with: 'Dialog border' with: WsDialogBorder )
            with: (Array with: 'Single-line border' with: WsNonSizingBorder).
        borderStyleValues := nil.
        ].
    self partsIfOS2Do: [
        DefaultFrameStyle :=
            WsDialogBorder |
            WsSystemMenu |
            WsTitleBar |
            WsNoByteAlign | "So dialog windows can be positioned to the nearest pixel"
            WsDoubleByteEntryAppStat. "DbeAppstat for National Language Support"

        borderStyleLabels := Array
            with: (Array with: 'Dialog border' with: WsDialogBorder)
            with: (Array with: 'Single-line border' with: WsNonSizingBorder).
        borderStyleValues := Array
            with: WsDialogBorder
            with: WsNonSizingBorder.
        ].!  
appendSaveExeItem: aSelector
        " Append a Save Exe command item. "
    self appendItem: self class labelSaveExe
        selector: aSelector.!
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    ^( (SysFont stringWidth: self defaultLabel) + 4 )
        @ ( SysFontHeight + 1 )!
appendKeysHelpItem: aSelector
        " Append a Keys Help command item. "
    self class labelKeysHelp isNil
        ifTrue: [^self].  " not supported on this platform "
    self appendItem: self class labelKeysHelp
        selector: aSelector.!   
lafAddEditPanes
        "Private - Add PARTSMenuPane and PARTSClientAreaPane as
        children of the receiver.  Do nothing for a dialog window. "!   
topPaneClass
        "Private - Answer the default top pane class."
    ^PARTSTopPane!  
appendRestoreItem: aSelector
        " Append a Restore command item. "
    self appendItem:
            self class labelRestore,
            self class tabString, 'Alt+R'
        selector: aSelector
        accelKey: $r
        accelBits: self class altCharAccelerator.!
create: className
    title: nameString
    style: styleInteger
    rectangle: aRectangle
    parent: parentWindow
        "Private - Create a window in the host system whose parent is
         parentWindow with aTitleString and aFrameStyle.
         The receiver's handle is set to the
         resulting client window. "
    | result parentHandle menuHandle |

    self partsVwOnly.  " Only used on VW" 
 
    ((styleInteger bitAnd: WsDialogBorder) = WsDialogBorder)
        ifFalse: [
            ^super create: className
                        title: nameString
                        style: styleInteger
                        rectangle: aRectangle
                        parent: parentWindow ].

    parentWindow notNil
        ifTrue: [ parentHandle := parentWindow handle ].
    ( styleInteger bitAnd: WsChildWindow ) ~= 0
        ifTrue: [ menuHandle := self id ].
    result := PARTSHostInterface hostWindowLibrary
        createWindowStructEx: WsDialogBorder
        class: className asParameter
        nameStruct: nameString asParameter
        style: (styleInteger bitXor: WsDialogBorder)  "WsDialogBorder passed through different param."
        x: aRectangle origin x
        y: aRectangle origin y
        width: aRectangle width
        height: aRectangle height
        parent: parentHandle
        menu: menuHandle
        instance: OperatingSystem hInstanceExe  "Old: self dsHandle"
        param: nil.
    handle := WindowHandle fromInteger: result.
    result = 0 ifTrue: [ self osWarning. ^nil ].!  
labelFindAgain
        " Answer the label of the Find Again item. "
    ^'Find a', self mnemonic, 'gain'!   
validateShow
    " Use the values in the property dictionary openWindowProperties
        to determine the opening position, visibility, and size.
       If showWindow or hideWindow was sent before the window was
         opened, override the opening hidden property.
       Use 'collapsed' variable to hook into the ability to show maximized
         or minimized."
    | realOpen hidden |

    self partIsEditing not
        ifTrue: [
            "Determine if initially visible"
            hidden :=
                ( self openHiddenOverride isNil
                    ifTrue: [   "Use the property setting."
                        self openHidden ]
                    ifFalse: [  "A part message forces the next open state."
                        realOpen := self openHiddenOverride.
                        self openHiddenOverride: nil.
                        realOpen = #hide ] ).
            hidden
                ifTrue: [ self frameWindow removeStyle: WsInitiallyVisible ]
                ifFalse: [ self frameWindow addStyle: WsInitiallyVisible ].

            self initialState:
                ( collapsed notNil
                    ifTrue: [ collapsed ] "Previous image save."
                    ifFalse: [ self openingSize ])]
        ifFalse: [
            self partIsShrunk   "Opening a window that should start out shrunk."
                ifTrue: [ self partShrink ].
            "Nested parts build contents during validate.  Insure they have the
                correct z-order."
            self orderedChildren reversed do: [ :aSibling |
                aSibling partBringSubPaneToTop ]].

    super validateShow.!   
initSize: aRectangle
        "Private - Set the initial size of the receiver
         to aRectangle.  Insure it fits on the screen.
        If the opening position is centered on the cursor
        adjust the receiver's rectangle accordingly."
    | height width newOrigin newBottomExtent newRightExtent
        displayBox oldOrigin |

    super initSize: aRectangle.
    self partIsEditing ifTrue: [ ^self ].

    height := rectangle height.
    width := rectangle width.
    oldOrigin := rectangle leftTop.
    newOrigin := ( self openingPosition == #workbench )
        ifTrue: [ oldOrigin copy ]
        ifFalse: [    "Center on the cursor."
            Cursor sense leftAndUp: (width // 2) @ (height // 2) ].

    displayBox := Display boundingBox.

    "Off the bottom of the screen?"
    (( newBottomExtent := newOrigin y down: height ) isBelow:
        displayBox bottom )
        ifTrue: [
            newOrigin y:
                ( newOrigin y up: ( newBottomExtent - displayBox bottom ) abs ) ].

    "Off the top of the screen?"
    ( newOrigin y isAbove: displayBox top )
        ifTrue: [
            newOrigin y: ( newOrigin y down: (newOrigin y - displayBox top) abs )].

    "Off the right of the screen?"
    ( newRightExtent := newOrigin x + width ) > displayBox right
        ifTrue: [
            newOrigin x:
                ( newOrigin x - ( newRightExtent - displayBox right )) ].

    "Off the left of the screen?"
    (newOrigin x < 0 )
        ifTrue: [ newOrigin x: 0 ].

    newOrigin ~= oldOrigin
        ifTrue: [ rectangle moveTo: newOrigin ].!  
initialFocusPane
    "Private - Answer initial focus of the receiver."
    | orderedChildren |

    ^(( orderedChildren := self orderedChildren ) size > 0
        ifTrue: [ orderedChildren first ]
            ifFalse: [ self ] )!   
close
        "Private - Check the reply and return."

    closedAction evaluateWithArguments: (Array with: reply).
    ^super close! 
appendClearTextItem: aSelector
        " Append a Clear command item.
        Don't set accelerator key for text control. "
    self appendItem:
            self class labelClear,
            self class tabString, 'Del'
        selector: aSelector.!   
openFile
        "Private - User selected Open... from the File menu."

    | aPathName |
    ( aPathName := FileDialog new openFile file ) isNil
        ifTrue: [ ^self ].
    self class new openOnPathName: aPathName.! 
validationMessage
        " Private "
    ^validationMessage!   
controlShiftCharAccelerator
        " Answer the accelerator bits for Ctrl+Shift+<char>. "
    ^AfControl | AfShift | AfChar!   
partMessagesProperties
        " Private - answer the PARTS message interface of the receiver
       for the property accessing sections of the protocol. "

    ^PARTSInterfaceList new
        items: #(
             #waitForAnswer #setWaitForAnswer:
             )!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        index: index;
        yourself.

    self ASSERT:
        ( theMenu isNil
			or: [ self partApplication notNil
				and: [ self partApplication isExecutable ]]).
    self ASSERT: ( copy instVarAt: ( PARTSMenuItemPane allInstVarNames indexOf: 'theMenu') ) isNil.
    ^copy!
altSpecialKeyAccelerator
        " Answer the accelerator bits for Alt+<special key>. "
    ^AfAlt | AfVirtualkey!  
setInitialFocus
    "Private - Set the initial focus of the receiver.
		Don't set the focus to a radio button unless
	its value is on, because set focus turns sets a
	radio button.
   		If the inital focus belongs to a notebook, set
    the focus to the first control on the selected
    page."
    | orderedChildren focusChild page |

    self isHandleOk
        ifFalse: [ ^nil ].

    focusChild :=
        (( orderedChildren := self orderedChildren ) size > 0
            ifTrue: [
				orderedChildren detect: [ :aChild |
					( aChild isRadioButton not
						or: [ aChild valueAttribute == true ])]
					ifNone: [ self ]]
			ifFalse: [ self ] ).

    ( focusChild isPARTSNotebook
        and: [ ( page := focusChild selection ) notNil
        and: [ page window notNil
        and: [ ( orderedChildren := page window orderedChildren ) size > 0 ]]])
            ifTrue: [ focusChild := orderedChildren first ].

    focusChild isHandleOk
        ifTrue: [ focusChild setFocus ].!  
index
    ^0!
bracketsMenu
        "Build the insertBracket menu."
    | ctrlBits ctrlShiftBits |
    ctrlBits := self class controlCharAccelerator.
    ctrlShiftBits := self class controlShiftCharAccelerator.
    self
        appendItem: self class mnemonic, 'Match    Ctrl+M'
            selector: #matchBracketChars
            accelKey: $m accelBits: ctrlBits;
        appendItem: 'Insert [ ]    Ctrl+['
            selector: #addSquareBrackets
            accelKey: $[ accelBits: ctrlBits;
        appendItem: 'Insert ( )    Ctrl+('
            selector: #addParens
            accelKey: $( accelBits: ctrlShiftBits;
        appendItem: 'Insert { }    Ctrl+{'
            selector: #addCurlyBrackets
            accelKey: ${ accelBits: ctrlShiftBits;
        appendItem: 'Insert '' ''    Ctrl+'''
            selector: #addSingleQuotes
            accelKey: $' accelBits: ctrlBits;
        appendItem: 'Insert " "    Ctrl+"'
            selector: #addDoubleQuotes
            accelKey: $" accelBits: ctrlShiftBits;
        yourself.!  
defaultExtendedStyle
        "Private - answer the default extended style flags for the
        receiver."

    ^WsDialogBorder!  
initSize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
    framingBlock notNil
        ifTrue: [
            framingBlock isPARTSRectangle
                ifTrue: [
                    rectangle := framingBlock scaleFrom:
                        ( self superWindow isWindow
                            ifTrue: [ self superWindow freeClientArea ]
                            ifFalse: [ Display boundingBox ] ) ]
                ifFalse: [ rectangle := framingBlock ] ]
        ifFalse: [ super initSize: aRectangle ]!  
bitmap
        "Answer a clone of the receiver's bitmap."
    bitmap isNil
        ifTrue: [ ^nil ]
        ifFalse: [ ^bitmap clone ]!   
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."
    | ext tall leftTop borderSize |

    borderSize := self class borderWidth * 2.
    ext := self frameRectangle extent - borderSize.
    tall := (self font isNil ifTrue: [SysFont] ifFalse: [self font]) height + 14.
    leftTop := self frameRectangle leftTop mapToWindow: self.
    ^(( leftTop extentFromLeftTop: ext x @ tall ) insetBy: borderSize )
        mapFromWindow: self
        to: self partEditor workbenchPane.! 
setLabel: aString
    | menuBar aMenu position |

    menuBar := self superWindow.
    aMenu := menuBar menuTitled: label.
    menuBar isHandleOk
        ifTrue: [
            self
			 partsIfOS2Do: [
                PARTSHostInterface hostWindowLibrary
					sendMsg: menuBar handle
                    msg: MmSetItemText
                    mp1: aMenu menuItem id
                    mp2Struct: aString asParameter ]
             partsIfWindowsDo: [
                   position := menuBar menus indexOf: aMenu ifAbsent: [^nil].
                menuBar removeMenu: aMenu.
                aMenu title: aString.
                menuBar insertMenu: aMenu after: position - 1 ].

             aMenu title: aString  ].  "Gets w.b. if not in the condition"
    label := aString.!
isPARTSOrderedGroupPane
    "Answer whether the receiver is an instance of
    PARTSOrderedGroupPane"

    ^false!
isPARTSDialogWindow
        " Answer whether the receiver is a PARTS Dialog window. "
    ^true!
resizeToRectangle: aRect
    "Private -"
    | oldExtent |
    oldExtent := rectangle extent.
    super resizeToRectangle: aRect.
    (oldExtent = rectangle extent) ifFalse: [
        bitmap notNil ifTrue: [
            bitmap changeSize: aRect extent].
        ( self superWindow isPARTSOrderedGroupPane )
            ifTrue: [self superWindow updatePositions]]!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #opened #aboutToClose #closed
            #rightClicked
            #helpManager:
            )
        separators: #( 3 4)
        defaultItem: #opened! 
printContents
        "Print the receiver's contents as a bitmap."
    | rect |
    self bringToTop.
    rect := Display boundingBox intersect: (
        self freeClientArea mapToScreen: self).
    (Bitmap fromScreen: rect)
        outputToPrinter!   
initialState
    "Private - Answer the initial opening state of the receiver
    during runtime"

    ^self propertyAt: #initialState!
performItemId: anInteger in: menu
        "Private - the menu item at anInteger has been selected."

    menu owner notNil    "Not a dummy menu."
        ifTrue: [ menu owner processIndex: anInteger ].!
appendSearchForHelpOnItem: aSelector
        " Append a Help Search for Help On command item. "
    self partsVwOnly.  " Only used on VW"
    self appendItem: self class labelSearchHelpOn
        selector: aSelector.! 
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a menu item "! 
partMessagesOperations
        " Private - answer the PARTS message interface of the receiver
       for the operations sections of the protocol. "

    ^PARTSInterfaceList new
        items: #(
            #open #close #abortClose
            #label #setLabel:
            #hideWindow #showWindow )
        separators: #( 3 5 )
        defaultItem: #close!   
appendNewWorkspaceItem: aSelector
        " Append a New Workspace command item. "
    self appendItem:
            self class labelNewWorkspace,
            self class tabString, 'Alt+N'
        selector: aSelector
        accelKey: $n
        accelBits: self class altCharAccelerator.!
closeView
        "Close the receiver and all its children."
    super closeView.
    self class exitOnLastWindow
        ifTrue: [ PARTSSessionManager exitIfLastWindow ].!  
isOkToClose
        " Private - answer whether it is OK to close.
        Triggers the veto-able #aboutToClose event. "
    ^self partIsEditing
        ifTrue: [true]
        ifFalse: [super isOkToClose]! 
defaultStyle
    "Private - Answer the default style for the receiver.
    Default frame style on OS/2 should be accessed by
    defaultFrameCreationFlags"

    self
        partsIfOS2Do: [ ^super defaultStyle ]
        partsIfWindowsDo: [ ^DefaultFrameStyle ]!  
title
        " Answer the title of the standard Brackets menu. "
    ^self mnemonic, 'Brackets'!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
   " ^SysFont width * 9 @ (SysFont height + 6)"
    | myFont |

    myFont := self partFontOrSysFont.
    ^(myFont width * 12) @ (myFont lineSpacing + 6)! 
topPaneClass
        "Private - Answer the default top pane class."
    ^PARTSPrebuiltDialogTopPane!
canMinimize
    "Private -
        Answer whether the receiver can be minimized on the desktop"
    ^false!
getMenuItem
        " Private - answer the menu item "

    ^theMenu getMenuItemFromIndex: index!  
setLabel: aString
    | oldLabel |
    oldLabel := self contents.
    self contents: aString.
    theMenu notNil
        ifTrue: [theMenu changeItem: oldLabel label: aString].
    ^aString!   
partPropertySelectBackColor: aPropertyUnit
    " Private - Bring up the ColorDialog and set backColor of the receiver. "

    | oldColor selectedColor partProperties |

    oldColor := self backColor  .
   selectedColor := ColorDialog new
        openOn: oldColor;
		chosen.

	selectedColor notNil
		ifTrue: [ " new color "
    		partProperties := aPropertyUnit propertyStructure.
    		partProperties
        		addAction: (Message new
            		receiver: self;
            		selector: #backColor:;
            		arguments: (Array with: selectedColor))
        		undo: (Message new
            		receiver: self;
            		selector: #backColor: ;
            		arguments: (Array with: oldColor))]
		ifFalse: [ ^self  ]. " Canceled or same color "!  
minimumWindowWidth

    ^self
        partsIfOS2Do: [0]
        partsIfWindowsDo: [PARTSHostInterface hostWindowLibrary getSystemMetrics: "(WinConstants at: 'SmCxmin')" 28]! 
labelUndo
        " Answer the label of the Undo item. "
    ^self mnemonic, 'Undo'!
contents
        "Answer the bitmap of the receiver."
    ^bitmap!  
contents: aString
        " Set the label of the menu item to aString. "
    label := PARTSMenuPart getLabelFrom: aString.
    accelerator := PARTSMenuPart getAccelFrom: aString.
    self isHandleOk
        ifTrue: [self display].!  
openingPosition
    "Answer the opening position specified in the property dialog.
      According to workbench coordinates, or centered on the mouse cursor.
    #workbench, #mouse"
    | position |

    ^(( position := self openWindowProperties ) isNil or: [
            ( position at: #openingPosition ifAbsent: [ nil ]) isNil ])
        ifTrue: [ #workbench ]
        ifFalse: [ position at: #openingPosition ].!  
suspendClient
        " Answer whether the client of a modal
        dialog is suspended until the dialog
        is closed. "
    ^self propertyAt: #suspendClient ifAbsent: [false]!
isPARTSMenuLabelPart
    "Answer whether the receiver is an instance of
    PARTSMenuLabelPart"
    ^true! 
disableControls
        "Private - Disable the receiver."!   
partShrunkenIconFile
        " Private - answer the name of the part file containing
        the icon to display when the receiver is shrunk
        in a PARTS Workbench window. "
    ^'TopPane.par'!   
supportsMenuBar
        " Private - answer whether menu bar is allowed on the receiver. "
    ^true!
labelCut
        " Answer the label of the Cut item. "
    ^'Cu', self mnemonic, 't'!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        bitmap: (bitmap partMirrorCopy: aMirrorCopyDictionary).
    ^copy!
defaultBackColor
        "Answer the default background color for the receiver class."
    ^Color menuBackground!   
allowWorkbenchToBeDisabled
        " Private "
    ^self propertyAt: #allowWorkbenchToBeDisabled ifAbsent: [false]! 
updatePositions
    "Private - Update the position of each item in the receiver."

    self partIsEditing ifFalse: [ ^self ].

    self moveFrom: 1 to: self partWrapper components size after: nil! 
appendRedoItem: aSelector
        " Append a Redo command item. "
    self
        appendItem:
                self class labelRedo,
                self class tabString, self class labelRedoAccelerator
            selector: aSelector
            accelKey: $y
            accelBits: self class controlCharAccelerator;
        accelKey: BackspaceKey
            accelBits: self class altShiftSpecialKeyAccelerator
            for: aSelector.!  
defaultStyle
        "Private - Answer an Integer with appropriate styles in it.
    Exclude the scroll bars."
    ^self partsIfOS2Do: [
        super defaultStyle ]
     partsIfWindowsDo: [
        self partsVwOnly.  " Only used on VW"
        WsPaneBorder ]!   
isTransparent
        "Private - answer whether the receiver's background
        should be painted with the same background color
        as its parent pane. This should really be in class Window."
    ^false!
closeView
        "Close the receiver and all its children."
    | disabledWindow |
    disabledWindow := self disabledOwner.
    disabledWindow notNil
        ifTrue: [
            disabledWindow enable.
            self disabledOwner: nil ].
    self modal: true.  "Reset"
    super closeView.

    ( Processor currentProcessIsRecursive not
    and: [ suspendProcessSemaphore notNil ] )
        ifTrue: [
            suspendProcessSemaphore signal.
            suspendProcessSemaphore := nil.
            Processor suspendActive.]! 
partEnableExecution
        " The application containing the receiver
        is going to be executed.  Build the menu. "

    self menuItems: self partChildren.
    self updateMenu.
    super partEnableExecution!   
appendOpenItem: aSelector
        " Append an Open command item. "
    self appendItem:
            self class labelOpen,
            self class tabString, 'Ctrl+O'
        selector: aSelector
        accelKey: $o
        accelBits: self class controlCharAccelerator.!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#clicked)
        defaultItem: #clicked!
label
    ^label!
partAddUnder: parentWindow wrapper: myWrapper
        "Private - Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "

    super partAddUnder: parentWindow wrapper: myWrapper.
    parentWindow addSubpane: self.
    self label size = 0  "Already has a label if undo deleting"
        ifTrue: [ self labelWithoutPrefix: self defaultWindowTitle ].
    self partsIfOS2Do: [
        ( self supportsMenuBar and: [
            menuWindow isPARTSMenuBar not and: [
            self hasMenuBarStyle ]]) ifTrue: [
            menuWindow := PARTSMenuBar new.
                menuWindow
                    parent: self;
                    owner: owner.
                self partEditor
                    addComponentToApplication:  menuWindow name: nil;
                    createWrapperFor: menuWindow
                        parentWrapper: myWrapper
                        box: (0 @ 0 extent: 1 @ 1)
                        helpInfo: myWrapper helpInfo]].!  
isPARTSOrderedGroupPane
    "Answer whether the receiver is an instance of
    PARTSOrderedGroupPane"

    ^true! 
labelDelete
        " Answer the label of the Delete item. "
    ^self mnemonic, 'Delete'!  
setBitmap: aBitmap
        "Set the bitmap of the receiver."
    | oldBitmap |
    aBitmap isBitmap
        ifTrue: [
            theMenu isNil ifTrue: [^aBitmap].
            oldBitmap :=  bitmap.
            bitmap release.
            bitmap := aBitmap.
            theMenu changeItem: oldBitmap label: bitmap].
    ^aBitmap!
menuPane
    "Private- Answer the receiver's menu pane."
    self partsVwOnly.  " Only used on VW" 

    ^self children detect: [ :child | child isPARTSMenuPane]
        ifNone:[ nil ]!
appendCutItem: aSelector
        " Append a Cut command item. "
	| accelaratorString |

    self 
		partsIfOS2Do: [accelaratorString := 'Shift+Del' ]
    	partsIfWindowsDo: [accelaratorString := 'Ctrl+X' ].

    self
        appendItem: self class labelCut, self class tabString, accelaratorString
            selector: aSelector
            accelKey: $x
            accelBits: self class controlCharAccelerator;
        accelKey: DeleteKey
            accelBits: self class shiftSpecialKeyAccelerator
            for: aSelector.! 
labelBrowseProjects
        " Answer the label of the Browse Projects item. "
    ^'Browse Pro', self mnemonic, 'jects'!
partShrinkWrap
        "Private - Answer the parent window which can be shrunk in
        the parts window."
    ^self!
isPARTSMenuItem
        " Answer whether the receiver is a PARTS
         MenuItemField, BitmapMenuItem, or MenuSeparator."
    ^true! 
controlSpecialKeyAccelerator
        " Answer the accelerator bits for Ctrl+<special key>. "
    ^AfControl | AfChar | AfVirtualkey!
hidden: aBoolean
    "Private - Set whether the receiver is hidden"

    ^self propertyAt: #hidden
        put: (aBoolean ifTrue: [ true ] ifFalse: [ nil ])! 
popUp
        "Popup menuObject at the current mouse location."

    "Don't popup if there are not items visible"
    self children detect: [ :aChild |
        ( aChild hidden not
            and: [ aChild isPARTSMenuSeparatorPart not ])]
                ifNone: [ ^nil ].

    menuObject partPopUpPerform!   
installPartRuntimeLibrary
        " Private - install the basic window parts runtime library.
        Load the workbench support library if appropriate. "

    "self initializeRuntimeData." "handled by package initializer (DKH 5-4-95)"

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Basic Visual Parts'.!   
labelSaveImage
        " Answer the label of the Save Image item. "
    ^'Save Image...'!   
print
        "Private - Send the contents of the textpane to the printer."

    CursorManager execute 
		changeFor: [ self pane print ].!
insertMenu: aMenu after: anInteger
        "Insert aMenu into the receiver after index anInteger.
        anInteger = 0 inserts first, anInteger = 1 after the first
        menu, etc."

    super insertMenu: aMenu after: anInteger.

    self partsIfWindowsDo: [
        "This is needed when #setLabel: is sent to a menu
            label part.  Want to make sure <aMenu> is in the
            correct index of allMenus, so that it can be found
            when a menu item selection provides the id."
         allMenus
             remove: aMenu ifAbsent: [ ^nil ];
             add: aMenu afterIndex: anInteger + 1 ].! 
accel: aChar afBits: theAfBits
        "Private - Allows a window to intercept character input
         before it is processed either by the menu or the child
         window.  Answer true to ignore character input from here
         on, otherwise false."
    | hm |
    self partsVwOnly.  " Only used on VW"
    "In Windows, pressing the F1 key does not generate a help
      event. Therefore, we must intercept it here to generate the
      help event ourselves."
    ( hm := self helpManager ) notNil ifTrue: [
        aChar =  F1Key ifTrue: [
            theAfBits isNil
                ifTrue: [ self helpRequest. ^true ].
            theAfBits = ShiftKey
                ifTrue: [ hm turnOnHelpMode.^true ].
            self helpRequest.
            ^true ].
        aChar = EscapeKey
            ifTrue: [ hm turnOffHelpMode.^true ] ].
    ^false!
initialize
        " Private "
    super initialize.
    evaluating := false.
    withBlank := false.
    reply := self cancelAnswer.!   
partMessagesProperties
        " Private - answer the PARTS message interface of the receiver
       for the property accessing sections of the protocol. "

    ^PARTSInterfaceList emptyList!   
labelSelectAll
        " Answer the label of the Select All item. "
    ^'Select ', self mnemonic, 'all'!   
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."

    ^anObject isPARTSMenuItem! 
initGraphicsTool
		"Private - Do nothing."!  
resizeRectangleFor: aRectangle
        "Private - Answer the rectangle to
        use to resize the receiver to aRectangle."

    self adjustFraming: self frameRelativeRectangle.
    ^self entireClientArea!   
modal
    "Private - Answer whether the receiver should open modal"

    ^( self propertyAt: #modal ) isNil!   
addMenusForPopup
        "Private - Add menus to allMenus instance variable. This method
          is called when a menu object is used as both a popup and drop-down
          menu. The OS drop-down menu window is used as the popup window.
          Therefore, no OS popup window is created. However, we still need
          the allMenus structure in order to perform menu items."

    allMenus := OrderedCollection with: allMenus first.
    menus isEmpty ifTrue: [ ^self ].
    menus do: [ :menu |  self addSubmenu: menu ].
!  
partShrinkWrap
        "Private - Answer the parent window which can be shrunk in
        the parts window."
    ^self!
labelFindAgain
        " Answer the label of the Find Again item. "
    ^'Find A', self mnemonic, 'gain'!   
showWindow: initialState
    "Private -
        For OS2: initialState can either a symbol (#normal,
            #minimized, #maximized) or a PMSwp structure.
        For Windows: initialState can be either a symbol,
            or -1 (minimized), 0 (restored), or a rectangle (maximized)"

    self partsIfOS2Do: [
        initialState isSymbol
            ifTrue: [ initialState = #normal
                ifTrue: [ super showWindow ]
                ifFalse: [ initialState = #minimized
                    ifTrue: [ self showIconicWindow ]
                    ifFalse: [ self showMaximizedWindow ]]]
            ifFalse: [ initialState minimized
                ifTrue: [ self showIconicWindow ]
                ifFalse: [ initialState maximized
                    ifTrue: [ self showMaximizedWindow ]
                    ifFalse: [ super showWindow ]]]]

    partsIfWindowsDo: [
        initialState isSymbol
            ifTrue: [
                initialState = #maximized
                    ifTrue: [ collapsed := rectangle ]
                    ifFalse: [
                        initialState = #minimized
                            ifTrue: [ collapsed := -1 ]
                            ifFalse: [ collapsed := 0 ]]]
            ifFalse: [ collapsed := initialState ].
        collapsed isRectangle
            ifTrue: [ self showMaximizedWindow ]
            ifFalse: [ ( collapsed notNil and: [ collapsed < 0 ])
                ifTrue: [ self showIconicWindow ]
                ifFalse: [ self showRestoredWindow ]]]!   
initialize
        " Private - class initialization. "

    self
        partsIfOS2Do: [
            LabelGeneralHelp := self mnemonic, 'General help'.
            LabelHelpIndex := 'Help ', self mnemonic, 'index'.
            LabelKeysHelp := self mnemonic, 'Keys help'.
            LabelSearchHelp := nil.
            LabelUsingHelp := self mnemonic, 'Using help'.
            ]
        partsIfWindowsDo: [
            LabelGeneralHelp := nil.
            LabelHelpIndex := self mnemonic, 'Contents'.
            LabelKeysHelp := nil.
            LabelSearchHelp := self mnemonic, 'Search for Help on ...'.
            LabelUsingHelp := self mnemonic, 'How to Use Help'.
            ].! 
for: anOwner titled: aString
        " Answer an empty menu with title aString and anOwner. "
    ^super new owner: anOwner; title: aString; yourself!  
openWindowProperties: aDictionary
        " Private "
    self propertyAt: #openWindowProperties put: aDictionary.! 
labelBrowseDisk
        " Answer the label of the Browse Disk item. "
    ^'Browse ', self mnemonic, 'Disk'!
standardSmalltalkMenuFor: anOwner
        " Answer a standard Smalltalk Edit menu for anOwner. "
    ^self new
        owner: anOwner;
        appendUndoItem: #undo ;
        appendCutItem: #cutSelection ;
        appendCopyItem: #copySelection ;
        appendPasteItem: #pasteSelection ;
        appendClearTextItem: #clearSelection ;
        appendSelectAllItem: #selectAll ;
        appendSubMenu: (PARTSStandardBracketsMenu standardSmalltalkMenuFor: anOwner);
        appendSeparator ;
        appendFindReplaceItem: #findReplace ;
        appendFindAgainItem: #again ;
        yourself!
currentItemIndex: anIndex
    "Private - Answer the current drag drop target position"

    self implementedBySubclass!
buildIcon
        "Private - Create the window icon"

    | icon |
    ( icon := self icon ) notNil
        ifTrue: [ self icon: icon ]
        ifFalse: [ self icon: PARTSApplication defaultIcon ].!  
appendUndoItem: aSelector
        " Append an Undo command item. "
    self      " supports both 'Ctrl+Z' and 'Alt+BckSpace' "
        appendItem:
                self class labelUndo,
                self class tabString, self class labelUndoAccelerator
            selector: aSelector
            accelKey: $z
            accelBits: self class controlCharAccelerator;
        accelKey: BackspaceKey
            accelBits: self class altSpecialKeyAccelerator
            for: aSelector.!   
enable
    "Enable the menu bar item associated with the receiver"
    | menuPart |

    ( menuPart := self menuPart ) notNil
        ifTrue: [
            self superWindow
                enableMenu: menuPart menuObject ]!
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^false!  
contents

    ^self label!  
defaultForeColor
        "Answer the default background color for the receiver class."
    ^Color menuText! 
performMenuItem: anInteger
        "Private - Perform the menu item whose id is anInteger."

    [ super performMenuItem: anInteger ]
        on: MessageNotUnderstood do: [ :e |
            self
                performItemId: anInteger \\ 256
                in: ( allMenus at: anInteger // 256 ) ]!
contents
    label isNil
        ifTrue: [^'']
        ifFalse: [
            accelerator isNil
                ifTrue: [ ^label ]
                ifFalse: [ ^label , (String with: Tab) , accelerator ] ]!
standardRuntimeMenuFor: anOwner
        " Answer a standard runtime menu for anOwner. "
    self implementedBySubclass! 
label: aString
        "Set the window label of the receiver to aString."
    self labelWithoutPrefix: aString! 
defaultWindowTitle
        " Private "
    ^self partName!  
openIn: aRectangle
    "Private - Open the receiver in aRectangle."

    self buildIcon.
    self initSize: aRectangle.
    children do: [ :subpane |
        subpane isApplicationWindow ifFalse: [ subpane open ]].
    self openModal: nil.  " open modal to the current active window "!   
appendDeleteTextItem: aSelector
        " Append a Delete command item.
        Don't set accelerator key for text control. "
    self appendItem:
            self class labelDelete,
            self class tabString, 'Del'
        selector: aSelector.!
labelSearchHelpOn
        " Answer the label of the Search Help On item "
    ^LabelSearchHelp! 
appendRestoreItem: aSelector
        " Append a Restore command item. "
    self appendItem:
            self class labelRestore,
            self class tabString, 'Ctrl+R'
        selector: aSelector
        accelKey: $r
        accelBits: self class controlCharAccelerator.!   
removePartRuntimeLibrary
        " Private - remove the basic window parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #label #setLabel:
            #enable #disable )
        separators: #( 2 )
        defaultItem: #setLabel:!
deferredResizeRectangleFor: aRectangle
        "Private - Answer the rectangle to
        use to resize the receiver to aRectangle
        when drawing is being delayed."
    | frame |
    frame := self framingBlock.
    ^frame isContext
        ifTrue: [ super deferredResizeRectangleFor: aRectangle ]
        ifFalse: [
            frame isPARTSRectangle
                ifTrue: [ frame scaleFrom: aRectangle ]
                ifFalse: [ frame ] ]! 
partCanBeNestedChild: aNestedPart
    "Private -  Answer whether the receiver could be a child
    of the nested part <aNestedPart>."

    ^false!
closedAction: anAction
        " Specify the action to be evaluated with the
        result when the dialog is closed.  The answer
        is a PARTSException if the dialog is cancelled. "
    closedAction := anAction.!   
performMenuItem: anInteger
        "Private - Perform the menu item whose id is anInteger.
    For popups, there is only one menu, so put in the range
    of 512.  <anInteger> may be in a different range if the
    popup is shared in a drop down menu bar."

    super performMenuItem:
        ( baseMenuId isNil
            ifTrue: [ anInteger ]
            ifFalse: [ anInteger - baseMenuId + 513 ])
!  
isPARTSMenuComponent
        "Answer whether the receiver is a PARTS
         MenuLabel, Menu, or menu item."
    ^true!   
appendProductInformationItem: aSelector
        " Append a Product Information command item. "
    self appendItem: self class labelProductInformation
        selector: aSelector.!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "

    ^children size = 0
        ifTrue: [ super partDefaultExtent ]
        ifFalse: [ self framingBlock extent ]!  
wmMenuend: mp1 with: mp2
        "Private - Menu went down, clear PopupWindow."
    "When processing help requests, if PopupWindow is not
    nil, we assume a popup menu was up, and help was for
    that menu.  If PopupWindow is nil, then it must have
    been a pull down."

    PARTSHostInterface hostWindowLibrary
        postMsg: self handle
        msg: ( ( Smalltalk at: #OperatingSystemEventsExtra  "PMEventsExtra" )
            keyAtValue: #wmExternalCall:with: )
        mp1: mp1 asParameter
        mp2: mp2 asParameter.
        "Above message is posted so that it'll come in after the
         wmCommand for performMenuItems"
    ^nil! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy label: label copy.
    ^copy!  
label
    ^label!
icon
        "Answer the receiver's icon."
    ^self
        partsIfOS2Do: [ Icon fromModule: nil id: 9 ]
        partsIfWindowsDo: [ super icon ]
! 
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

    ^self partsIfOS2Do: [
         super partCanHaveParent: aWindow ]
     partsIfWindowsDo: [
         ( super partCanHaveParent: aWindow )
             and: [ aWindow isPARTSWindow not ]]! 
appendInstallItem: aSelector
        " Append an Install command item. "
    self appendItem:
            self class labelInstall,
            self class tabString, 'Alt+I'
        selector: aSelector
        accelKey: $i
        accelBits: self class altCharAccelerator.!   
defaultLabel
        " Private "
    ^'aMenu'!  
labelGeneralHelp
        " Answer the label of the General Help item. "
    ^LabelGeneralHelp!  
updateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollBar."!   
partEnableExecution
		"Private - Create an instance of HelpManager if needed."
	| helpFileName |
	(helpFileName := self endUserHelpFileName) notNil
		ifTrue: [
		    self helpManager: (HelpManager
        	for: self
	        title: self helpWindowLabel
    	    file: helpFileName)].
    super partEnableExecution!   
COMMENT
"
PARTSTextWindow is used by PARTS to display text information
to the user (e.g., application print).
"!  
makeActive
    "Make the receiver the active window.  If the receiver
    is within a nested part, don't activate it."

    (self partIsEditing not
    	or: [ self partContainingNestedPart isNil])
        ifTrue: [ ^super makeActive ]! 
initialize
        " Private - initialize a new instance. "

    super initialize.
    self label: self defaultLabel.!
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part. The rectangle
         is relative to the editor pane."
    | ext |
    ext := self extent.
    ^( 0 @ 0 extent: ext x @ (SysFont height + 10 ))
        mapFromWindow: self
        to: self partEditor workbenchPane.!
menuItems
    "Private - Answer the menu items of the receiver
    for execution."

    ^self propertyAt: #menuItems! 
buildWindow: parentWindow
        "Private - Create the window for the receiver
         using parentWindow as the parent."

    self owner partIsEditing
        ifTrue: [ ^super buildWindow: parentWindow]!   
borderStyleLabels
        " Private "
    ^borderStyleLabels!   
validationMessage: anAction
        " Register an action whose first argument
        is the contents of the prompter.  The action
        must evaluate to whether the value is acceptable. "
    validationMessage := anAction.!
isHidden
        "Answer whether the menu item is hidden.  Will answer
    true if the receiver has received the 'hide' message, or is
    in a submenu that received the 'hide' message.
        Trigger #hiddenIsTrue, if the receiver is hidden"

    self partIsEditing
        ifTrue: [ ^super isHidden ].

    ^self hiddenPrivate
        ifTrue: [
            self triggerEvent: #hiddenIsTrue.
            true ]
        ifFalse: [ false ].!
disabledOwner
        " Private - answer the window which was disabled
        when opened modal. "
    ^self propertyAt: #disabledOwner!  
resizeToRectangle: aRect
        "Private - Resize the receiver and its parent."
    | xAmount |
    xAmount := aRect width - self rectangle width.
    super resizeToRectangle: aRect.
    "self superWindow expandBy: (xAmount @ 0)"!  
frameWindowClass
        "Private - Answer the class of the receiver's frame window."

    self partsVosOnly.  " Only used on VOS"
    ^self class frameWindowClass!  
save
        "Private - Save the contents."
    self pane
        modified: true;  " force save "
        accept! 
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a menu label "!
isWindow
        "Private - When the a receiver is shrunk inside
        a PARTSWorkbench it is represented by an icon,
        and it is not to behave like a window.
        Retained for backward compatibility."
    ^self partIsWindow! 
specialKeyAccelerator
        " Answer the accelerator bits for <special key>. "
    ^SpecialKeyAccelerator!
appendReplaceItem: aSelector
        " Append a Replace command item. "
    self appendItem: self class labelReplace
        selector: aSelector.! 
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
     ^super constructEventsTriggered
        remove: #menuBarBuilt ;
        remove: #validated ;
        yourself! 
appendPrintItem: aSelector
        " Append a Print command item. "
    self appendItem:
            self class labelPrint,
            self class tabString, 'Alt+P'
        selector: aSelector
        accelKey: $p
        accelBits: self class altCharAccelerator.!  
addMenuBar: aBoolean
        " Platform-dependent implementation "
    self error: 'not supported for dialog window'!   
validate
        "Private - Create the window or recreate after saving
         image."
	super validate.
	self partsIfOS2Do: [
		(self frameWindow respondsTo: #validate) 
			ifTrue: [self frameWindow validate]]! 
fileMenuCreate
        "Private - Answer a new File menu."
    ^(PARTSFileMenu for: self)
		appendOpenItem: #openFile ;
        appendSaveItem: #save ;
        appendSaveAsItem: #saveAs ;
        appendSeparator;
        "appendPrintItem: #print ;"  " don't want ... in label "
        appendItem: PARTSFileMenu mnemonic, 'Print'
            selector: #print ;
        appendPrintSetupItem: #printSetup ;
        appendSeparator;
        appendCloseItem: #close ;
        yourself!
hasMenuBar
        " Private - answer whether the receiver currently has a menu bar. "
	^self 
		partsIfOS2Do: [menuWindow notNil]
		partsIfWindowsDo: 
			[( self children
        		detect: [: child | child isPARTSMenuPane]
        		ifNone: [nil] ) notNil]! 
addTabInfoFor: aPane
        "Private - Add tabing information for aPane to the receiver."

    self partIsEditing
        ifTrue: [ super addTabInfoFor: aPane ].!   
wmSetcursor: wParam with: lParam
    "Check to see if the receiver has been disabled by a dialog
        window.   If so, check for a button up on this window and
        bring both the receiver and the dialog to the top.  If there
        are subdialogs, clicking on any disabled window in the
        heirarchy brings all windows to front, with the active dialog
        on top.  Note: owners are automatically brought to front
        if ownee is brought to front."

    | dialog lastDialogFound ownerCandidate |

    self partsVwOnly.  " Only used on VW"
    ( lParam highWord = ("WinConstants at: 'WmLbuttonup'" 514)
        and: [ self disabled ] )
        ifTrue: [
            lastDialogFound := false.
            ownerCandidate := self.
            [ lastDialogFound ]     "Bring dialogs and subdialogs to front."
                whileFalse: [
                    dialog := (Notifier mainWindowsSelect:
                        [ :win | (win respondsTo: #disabledOwner)
                            ifTrue: [ win disabledOwner == ownerCandidate ]
                            ifFalse: [ false ]]).
                    dialog notEmpty
                        ifTrue: [
                            dialog first bringToTop.
                            ownerCandidate := dialog first ]  "Look for subdialog to this dialog."
                        ifFalse: [
                            lastDialogFound := true ]]].    "No subdialogs."

    ^super wmSetcursor: wParam with: lParam!
new
        " Answer an empty menu with the standard title. "
    ^super new title: self title! 
appendCopyItem: aSelector
        " Append a Copy command item. "
	| accelaratorString |

    self 
		partsIfOS2Do: [
        	accelaratorString := 'Ctrl+Ins' ]
    	partsIfWindowsDo: [
        	accelaratorString := 'Ctrl+C' ].

    self
        appendItem:
            self class labelCopy, self class tabString, accelaratorString
        selector: aSelector
        accelKey: $c
            accelBits: self class controlCharAccelerator;
        accelKey: InsertKey
            accelBits: self class controlSpecialKeyAccelerator
            for: aSelector.!  
partMessagesOperations
        " Private - answer the PARTS message interface of the receiver
       for the operations sections of the protocol. "

    ^PARTSInterfaceList new
        items: #(
            #open #close #abortClose
            #label #setLabel: )
        separators: #( 3 )
        defaultItem: #close!  
openHiddenOverride: visibility
    "Set the override state.  If nil, use the hidden property is valid.
      If #show or #hide, take precedence over the hidden property."

    self openWindowProperties isNil
        ifTrue: [ self openWindowProperties: Dictionary new ].

    self openWindowProperties at: #openHiddenOverride put: visibility! 
frameWindowClass
        " Private - answer the OS/2 frame window class "

    ^frameWindowClass!  
partRelativeToParent: aParent
    "Private - Answer whether the receiver's rectangle is
    relative to its parent on the workbench.  Answer false
    if the receiver is a desktop child and is in a nested
    part that is not a desktop child."
    | topLevel |

    aParent isPARTSNestedPart
        ifFalse: [ ^true ].

    "Even if several nested levels deep, if a direct descendent
        of the editor pane/desktop, consider it a desktop child"
    (( topLevel := ( self partNonNestedPartParent: aParent )) isNil
        or: [ topLevel isPARTSEditorPane ])
            ifTrue: [ ^true ].

    ^self partIsDesktopChild not!   
openHidden
    "Answer whether the window is hidden when opened"
    | hidden |

    ^( hidden := self openWindowProperties ) isNil
        ifTrue: [ false ]
        ifFalse: [
            ( hidden at: #openHidden ifAbsent: [ nil ]) isNil
                ifTrue: [ false ]
                ifFalse: [ hidden at: #openHidden ] ].! 
findItemAt: index
        "Find the menu item at anIndex."
    | items |

    ( items := self menuItems ) isNil ifTrue: [^nil].

    ^items detect: [: each | each index = index]
        ifNone: [^nil]!  
labelTutorial
        " Answer the label of the Tutorial item. "
    ^self mnemonic, 'Tutorial'!
pmOwner
        "Private - Answer the owner window."
    self partsVosOnly.
    ^Notifier findWindow: self osOwner!
appendWordWrapItem: aSelector
        " Append a WordWrap command item. "
    self appendItem: self class labelWordWrap
        selector: aSelector.!  
partSize
    ^parent isNil
        ifTrue: [ self partDefaultExtent ]
        ifFalse: [ self frameRectangle extent ]! 
altShiftSpecialKeyAccelerator
        " Answer the accelerator bits for Alt+Shift+<special key>. "
    ^AfAlt | AfShift | AfVirtualkey! 
partOnTopWhenSelected
        "Answer true if the receiver can be brought to
         to the top when it is selected in the workbench."
    ^true! 
partShrunkenIconFile
        " Private - answer the name of the part file containing
        the icon to display when the receiver is shrunk
        in a PARTS Workbench window. "
    ^'DilgTppn.par'!  
partSetGraphics: aBitmap
        " Private - update the receiver's bitmap. "

    | rect |
    rect := self frameRectangle.
    aBitmap extent = rect extent ifFalse: [    "size changed"
        (Message new        "disable undo changing size for now."
            receiver: self partEditor;
            selector: #recordUndoPlaceholder)
            performDeferred.
        self resizeToRectangle: (rect origin extent: aBitmap extent)].
    self bitmap: aBitmap.
    self handle isValid ifTrue: [
        self realInvalidateRect: nil]!  
currentItemIndex
    "Answer the current drag drop target position"

    ^currentItemRow!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #isDisabled
            #check #uncheck #isChecked
            #show #hide #isHidden
            #bitmap #setBitmap: )
        separators: #( 3 6 9 )
        defaultItem: #disable! 
PARTSWindowPart removePartRuntimeLibrary! 
initSize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
	
	self framingBlock bottom:
		( self framingBlock pixelToScaleUnitVertical: SysFont height + 1 ).
	super initSize: aRectangle!  
okToClose
        "Private - The user selected ok."

    | validationAction |
    super okToClose ifFalse: [^false].
    ( validationAction := self validationMessage ) notNil
        ifTrue: [
            ( validationAction evaluateWithArguments: ( Array with: reply ) )
                ifFalse: [
                    reply := PARTSException new.
                    ^false ] ].
    ^true!  
labelRedo
        " Answer the label of the Redo item. "
    ^self mnemonic, 'Redo'!
openingSize
    "Answer the opening size specified in the property dialog.
        normal, minimized, or maximized."
    | size |

    ^(( size := self openWindowProperties ) isNil or: [
            (size at: #openingSize ifAbsent: [ nil ]) isNil ])
        ifTrue: [ #normal ]
        ifFalse: [ size at: #openingSize ].!
index
        "Private - Answer the receiver's menu index to anInteger."
    ^index!
endUserHelpFileName: aFileName
        "Private - Answer a string which is the file name of the help
        file to be used at runtime for context sensitive help for all the
        controls and menus inside this part."
    self propertyAt: #endUserHelpFileName put: aFileName!
labelRestore
        " Answer the label of the Restore item. "
    ^self mnemonic, 'Restore'!   
appendGeneralHelpItem: aSelector
        " Append a General Help command item. "
    self class labelGeneralHelp isNil
        ifTrue: [^self].  " not supported on this platform "
    self appendItem: self class labelGeneralHelp
        selector: aSelector.!   
triggerOpenedEvent
        "Private - subclassed to trigger the #helpManager: enent, meaning
        the helpManager is available."
    | helpManager |
    super triggerOpenedEvent.
    (helpManager := self helpManager) notNil
        ifTrue: [self triggerEvent: #helpManager: with: helpManager]!
lafAddMenuBar
    "Private - Dialogs don't have menus"
    self partsVwOnly.  " Only used on VW"!   
appendSaveImageItem: aSelector
        " Append a Save Image command item. "
    self appendItem: self class labelSaveImage
        selector: aSelector.!  
removeBlanks: aBoolean
        " Specify whether leading and trailing blanks
        should be trimmed from the user's response. "
    withBlank := aBoolean not.! 
escapeKeyInput: aKeyboardInputEvent
        "Private - Respond to the esc keystroke."

    self close.!
show
    "Show the receiver in its menu."
    | currentIndex pos |

    self hidden ifFalse: [ ^self ].
    currentIndex := self visibleIndex.
    theMenu items do: [ :aMenuItem |
        (( pos := aMenuItem position ) notNil
            and: [ pos + 1 >= currentIndex ])
                ifTrue: [ aMenuItem position: pos + 1 ]].

    self getMenuItem position: currentIndex - 1. "Set the position to the actual position"
    self hidden: false. "Won't show on OS/2 if don't set before refresh"

    theMenu window notNil
        ifTrue: [ "Nil on OS/2 for unshared popup"
            theMenu
                buildItem: index
                menu: ( theMenu menuItem id - 1 // 256 )
                parent: theMenu window ]!   
labelSave
        " Answer the label of the Save item. "
    ^self mnemonic, 'Save'!
standardSmalltalkMenuFor: anOwner
        " Answer a standard Smalltalk Brackets menu for anOwner. "
    ^self new
        owner: anOwner;
        bracketsMenu!  
labelSettings
        " Answer the label of the Settings item. "
    ^'Se', self mnemonic, 'ttings...'! 
partAddedTo: anApplication
        " The receiver has just been added to anApplication.
        Create any links or register event handlers if desired. "

    anApplication partEditor
        createLinkFrom: anApplication
        event: #open
        to: self
        message: #open.!  
standardRuntimeMenuFor: anOwner
        " Answer a standard runtime File menu for anOwner. "
    ^self new
        owner: anOwner;
        "appendNewItem: #fileNew ;"
        appendOpenItem: #openFile ;
        appendSaveItem: #accept ;
        appendSaveAsItem: #saveAs ;
        appendRestoreItem: #restore ;
        appendSeparator;
        appendPrintItem: #print ;
        appendPrintSetupItem: #printSetup ;
        yourself!   
frameStyle

    ^SubPane noScrollbarsFrameStyle!
noTabStop
        "Make the receiver not be a tabstop.  Do nothing for a Window. "!  
initializeFrameWindowClass
        " Private "

    self frameWindowClass: ( self
        partsIfOS2Do: [ 
			Smalltalk at: #PARTSFrameWindow
				ifAbsent: [ Smalltalk at: #FrameWindow ] ]
        partsIfWindowsDo: [ nil ] ).! 
modified
	"Private -"
	^false!  
endUserHelpFileName
        "Private - Answer a string which is the file name of the help
        file to be used at runtime for context sensitive help for all the
        controls and menus inside this part."
    ^self propertyAt: #endUserHelpFileName! 
exitOnLastWindow
    "Answer whether the image will exit when the the last
    window in the image is closed"

    ^ExitOnLastWindow isNil
! 
labelRedoAccelerator
        " Answer the label of the Redo item accelerator. "
    ^self
            partsIfOS2Do: [ 'Shift+Alt+BckSpace' ]
        partsIfWindowsDo: [ 'Ctrl+Y' ].! 
display
        "Private - Display the receiver's bitmap."
    bitmap notNil
        ifTrue: [
            self doGraphics: [
                bitmap displayAt: 0 @ 0 with: graphicsTool]]!  
partChildren
        " Answer a collection containing the child parts of the receiver. "

    | myWrapper childParts |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^#() ].
    childParts := OrderedCollection new.
    myWrapper components do: [ :aWrapper |
        aWrapper object isPARTSTransientPart
            ifFalse: [ childParts add: aWrapper object ] ].
    ^childParts!  
defaultWindowTitle
        " Private "
    ^owner title!
setFocus
    "Receiver can't get the focus.  buildWindow: tries, though"!
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part. The rectangle
         is relative to the editor pane."

    ^(( 0@0 ) - 2 extent: self extent + 4 )
        mapFromWindow: self
        to: self partEditor workbenchPane.! 
partIsDesktopChild
    "Private - Answer whether the receiver is always a child of the
    workbench desktop."

    ^true!
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

	^aWindow isPARTSMenuPart! 
hideWindow
    "If sent before the window is opened,
    remember the opening state.  This overrides the
    initial property."

    self isHandleOk
        ifFalse: [
            self openHiddenOverride: #hide.
            ^self ].

    ^super hideWindow!
titled: aString
        " Answer an empty menu with title aString. "
    ^super new title: aString! 
standardRuntimeMenuFor: anOwner
        " Answer a standard runtime Brackets menu for anOwner. "
    ^self standardSmalltalkMenuFor: anOwner!   
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message."
    self partsVwOnly.  " Only used on VW"
    ^nil!  
baseMenuId: baseId
    "Private - When creating a popup menu that is shared with a
    drop-down menu, the menu item id's reported by the system
    when an item is selected are identical.  The allMenus instance
    variable used by the drop-down menu's menu bar, and the
    popup menu window are not the same.  The popup only have
    the menus used in the main popup or submenus, while the
    drop down could have many other menus.  Since the id is
    directly related to the position of the receiver in the allMenus
    variable, the id may or may not map correctly in the popup
    allMenus if it was generated for the drop-down allMenus.
    <baseId> should be used to offset the menu item id's to the
    correct menu in the popup's allMenus variable."

    baseMenuId := baseId!
openHiddenOverride
    "Answer the override state.  If nil, use the hidden property is valid.
      If #show or #hide, it takes precedence over the hidden property."

    | hidden |

    ^( hidden := self openWindowProperties ) isNil
        ifTrue: [ nil ]
        ifFalse: [ hidden at: #openHiddenOverride ifAbsent: [ nil ] ]!  
partSetDirectEditValue: text
        " Set the direct-edit property value of the receiver
        to text and update the receiver appropriately.
        Answer nil if the text is invalid for the object."
    | result |

    result := super partSetDirectEditValue: text.
    self partEditor selectOffAll.
    self superWindow updatePositions.
    self partEditor select: self.
    ^result!
labelOpen
        " Answer the label of the Open item. "
    ^self mnemonic, 'Open...'! 
newSubMenuFor: aMenu
        "Private - Create the menu window for aMenu with
        the receiver as parent. Fill in the window in aMenu
        and answer the menu's number.
            If the receiver already has items with id's, must be
        showing the menu item parts after being hidden.
        Don't recalculate the menuNumber, because it does not
        take all the menus into account.  The id must match
        the original id."
    | menuNumber aSubItem |

    menuNumber := super newSubMenuFor: aMenu.
    ( aMenu items size > 0
        and: [ ( aSubItem := aMenu items first ) id notNil
        and: [ aSubItem id > 0 ]])
        ifTrue: [ menuNumber := aSubItem id // 256 ].

    ^menuNumber! 
openWindowProperties
        " Private "
    ^self propertyAt: #openWindowProperties!   
isPARTSWindow
        " Answer whether the receiver is a PARTS top-level window. "
    ^true!   
labelPaste
        " Answer the label of the Paste item. "
    ^self mnemonic, 'Paste'! 
buildWindowStyle
        " Private - platform dependent "
    "For VW, need to add WsChild style in workbench, but not WsPopup.
        Two styles are mutually exclusive.
     Don't use addStyle:/removeStyle: because don't want styles around
        when launched."

   ^self partIsEditing
        ifTrue: [style | WsChildWindow bitAnd: (WsPopUp bitXor: 16rFFFFFFFF)]
            "o.w. window will be outside workbench."
        ifFalse: [style]!  
openingPosition: openingStyle

    self openWindowProperties isNil
        ifTrue: [ self openWindowProperties: Dictionary new ].

    self openWindowProperties at: #openingPosition put:
        (openingStyle = #workbench
            ifTrue: [ nil ]
            ifFalse: [ openingStyle ])! 
close
        "Private - Close the receiver and release the bitmap."
    bitmap notNil ifTrue: [bitmap archiveAndRelease].
    ^super close!   
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
canTab
        "Private - Answer whether the receiver can
        be tabbed into and out of."
    ^false!  
partSetGraphics: anIcon
        " Private - update the receiver's icon. "

    self icon: anIcon.! 
close
    "Reset collapsed.  Only time collapsed should be set
    when a window is opened, is during image startup."

	self isHandleOk  "Already closed?"
		ifFalse: [ ^self ].

    collapsed := nil.
    ^super close! 
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered.!  
isPARTSMenuTextItemPart
        "Answer whether the receiver is a PARTSMenuTextItemPart."
    ^true!
createMenuBarMenus: topPane
        " Private - build the menu bar. "

    topPane menuWindow
        addMenu: self fileMenuCreate;
        addMenu: self editMenuCreate.
    SessionModel current isRunTime
        ifFalse: [
            ( self toolWindowPolicyClass on: topPane )
                addSmalltalkMenu;
                addStandardRightMenus ].!  
labelProductInformation
        " Answer the label of the Product Information item. "
    ^self mnemonic, 'Product information'!
isVisible
    ^true! 
initialize
        "Private - Initialize the receiver."

    super initialize.
    self currentItemIndex: 1!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#popUp)
        defaultItem: #popUp!
accelerator: aString
        " Private "
    accelerator := aString.!   
noGroupLeader
        "Make the receiver not be a group leader.  Do nothing for a Window. "! 
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

	^aWindow isPARTSEditorPane!   
open
    | result |
    self isHandleOk
        ifTrue: [
            self bringToTop.
            self partsIfOS2Do: [ self makeActive ].
            self setInitialFocus.
            self triggerEvent: #opened.
            ^self].
    result := super open.
    self setInitialFocus.
    ^result!  
borderStyleValues
        " Private "
    ^borderStyleValues!   
hidden
        "Private - Answer whether the menu item is hidden.
        Will only answer true if the receiver has received a
        'hide' message.  Will not answer true if the receiver is
    hidden because the menu that contains it is hidden."

    ^self propertyAt: #hidden ifAbsent: [ false ].!   
activeTextPane: aTextPaneWindow
        "Private - Change the active text pane.
        Do nothing for a PARTS window. "!   
hasMenuBarStyle
		"Private -"
    ^( self propertyAt: #noMenuBar ) isNil!   
buildPopupWindow: parentWindow
        "Private - Create the menu bar window and
        all menus in it. Most of this code if from buildWindow.
        The allMenus variable has been preset."
    | mi aString |

    parent := parentWindow.
    menus isEmpty ifTrue: [ ^self ].
    ( aString := PARTSHostInterface hostWindowLibrary createMenu: parent asParameter lpmt: nil ) size = 4
        ifFalse: [ ^nil ].
    handle := WindowHandle fromBytes: aString.
    self isHandleOk ifFalse: [ ^nil ].

    menus do: [ :menu |
        mi := menu buildWindow: self.
        mi isNil ifTrue: [ ^nil ].
        self insertItem: mi label: menu title ].!  
standardMenuFor: anOwner
        " Answer a standard menu for the current
        environment for anOwner. "
    ^SessionModel current isRunTime
        ifTrue: [self standardRuntimeMenuFor: anOwner]
        ifFalse: [self standardSmalltalkMenuFor: anOwner]!   
partAddedTo: anApplication
        " The receiver has just been added to anApplication.
        Create any links or register event handlers if desired. "

    ( anApplication partWrapper hasLinksForEvent:  #open )
        ifFalse: [
            anApplication partEditor
                createLinkFrom: anApplication
                event: #open
                to: self
                message: #open ].!
wmMenuselect: wparam with: lparam
         "Private - A menu item or outside is selected."

    | id flags text receiver context hMenu popupMenu |
    self partsIfOS2Do: [^super wmMenuselect: wparam with: lparam].
    ( self helpManager isNil and: [ self statusPane isNil ] ) ifTrue:[ ^nil ].
    id := wparam lowWord.
    flags := wparam highWord.
    hMenu := lparam.
    lparam = 0 ifTrue: [ "menu closed"
        self statusPane notNil ifTrue: [
            self statusPane showHelp:nil ].
        ^nil ].
    receiver := self menuWindow.
    receiver isNil
        ifTrue: [   "popup menu"
            receiver := self.
            receiver popup isNil ifTrue: [^self] ]
       " ifFalse: [receiver owner notNil ifTrue: [receiver := receiver owner ] ]".
    flags & "MfSysmenu" 8192 > 0 ifTrue: [
        id := id // 256 * 256 + ( id \\ 256 bitShift: -4 ) ].
    popupMenu := true.
    receiver isSubPane ifTrue: [ popupMenu := receiver isHandleForPopupMenu: hMenu ].
    popupMenu ifFalse: [ ^nil ].

    flags & "MfPopup" 16 > 0
        ifTrue: [
            hMenu := PARTSHostInterface hostWindowLibrary getSubMenu: lparam pos: id.
            context := receiver contextForPopup: hMenu ]
        ifFalse: [ context := "receiver"  self menuWindow contextForItem: id ].
    wparam lowWord >= 16rF000 ifTrue: [
        context := Association key: ( HelpManager systemContextStrings at: wparam lowWord ) value: self owner ].
    flags & "MfPopup" 16 > 0 ifTrue: [
        flags & "MfSysmenu" 8192 > 0 ifTrue: [ receiver := self ].
        hMenu = receiver systemMenuHandle ifTrue:[
            receiver isMDIChild
                ifTrue: [ context := Association key: 'MDISysMenu' value: self owner ]
                ifFalse: [ context := Association key: 'SysMenu' value: self owner ] ] ].
    context notNil ifTrue: [
        self mainWindow helpContext: context ].
    self statusPane isNil ifTrue: [ ^nil ].
    context notNil ifTrue: [
        (context value respondsTo: #statusPaneHelp:) ifTrue:[
            text := context value statusPaneHelp: context key ] ].
    text isNil ifTrue: [ text := '' ].
    self statusPane showHelp: text .
     ^nil!   
orderChildrenAndDisplay: aCollection
    "Private - Set the orderedChildren and update
    the display to reflect the new order"

    self orderedChildren: aCollection.
    aCollection reversed do: [ :aSibling |
        aSibling isControlPane ifTrue: [ aSibling partBringSubPaneToTop ] ].

    self invalidateRect: nil.!  
menuItems: items
    "Private - Backup the menu items of the receiver
    for execution."

    self propertyAt: #menuItems put: items.!   
appendNewItem: aSelector
        " Append a New command item. "
    self appendItem: self class labelNew
        selector: aSelector.! 
appendPrintSetupItem: aSelector
        " Append a Print Setup command item. "
    self appendItem:
            self class labelPrintSetup,
            self class tabString, 'Alt+T'
        selector: aSelector
        accelKey: $t
        accelBits: self class altCharAccelerator.!  
modal: aBoolean
    "Private - Set whether the receiver should open modal"

    self
        propertyAt: #modal
        put: ( aBoolean ifTrue: [ nil ] ifFalse: [ false ])
!   
showRestoredWindow
    "Private - Show the receiver window as a normal/restored window."
    self partsIfOS2Do: [
    self partsVosOnly.
        ( self parent isFrameWindow and: [ self isHandleOk ])
            ifTrue: [ self frameWindow handle showRestoredWindow ]
            ifFalse: [ super showRestoredWindow ]]
    partsIfWindowsDo: [ ^super showRestoredWindow ]!  
frameStyle

    ^SubPane noScrollbarsFrameStyle!
partIsDesktopChild: isDesktopChild
    "Private - Set whether the receiver is to be opened as a
    direct child of the desktop.  On Windows, it is always
    true.  On OS/2, the default is false."
    | openProperties |
    self partsVosOnly.  " Only used on VOS"

    ( openProperties := self openWindowProperties ) isNil
        ifTrue: [
            openProperties := Dictionary new.
            self openWindowProperties: openProperties ].

    openProperties at: #desktopChild put:
        (( isDesktopChild isNil or: [ isDesktopChild not ])
            ifTrue: [ nil ]
            ifFalse: [ true ] )!   
partOpen
        " Display the receiver when it is being edited
        in a PARTS Workbench. "

    self partsIfWindowsDo: [  " menu bar is special when editing in PWW workbench "
        self partIsEditing ifTrue: [ self lafAddMenuBar ].
        ].

    ^self openIn: (
        self superWindow isWindow
            ifTrue: [
                self superWindow freeClientArea ]
            ifFalse: [ Display boundingBox ] )! 
suspendProcess
        "Private - Make the receiver modal to its owner window.
         This method doesn't return until close has been
         sent to the receiver.  parent should be disabled before
         calling this method."
    suspendProcessSemaphore := Semaphore new.
    [CurrentProcess makeUserIF. Notifier run] fork.
    suspendProcessSemaphore notNil  "diag may be closed before getting here"
        ifTrue: [suspendProcessSemaphore wait].
    CurrentProcess makeUserIF!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #show #hide #isHidden )
        separators: #( )
        defaultItem: #hide!  
validate
    "Private - Create the window or recreate after saving image."
    super validate.
    self partsIfOS2Do: [
		menuWindow isPARTSMenuBar
			ifTrue: [ menuWindow validate ]]! 
openHidden: hide

    self openWindowProperties isNil
        ifTrue: [ self openWindowProperties: Dictionary new ].

    self openWindowProperties at: #openHidden put:
        (( hide isNil or: [ hide not ])
            ifTrue: [ nil ]
            ifFalse: [ true ] )! 
labelProductInformation
        " Answer the label of the Product Information item. "
    ^LabelProductInformation! 
labelFindReplace
        " Answer the label of the Find/Replace item. "
    ^self mnemonic, 'Find/Replace...'!  
standardRuntimeMenuFor: anOwner
        " Answer a standard runtime Edit menu for anOwner. "
    ^self new
        owner: anOwner;
        appendUndoItem: #undo ;
        appendSeparator ;
        appendCutItem: #cutSelection ;
        appendCopyItem: #copySelection ;
        appendPasteItem: #pasteSelection ;
        appendClearTextItem: #clearSelection ;
        appendSeparator ;
        appendSelectAllItem: #selectAll ;
        appendSeparator ;
        appendFindReplaceItem: #findReplace ;
        appendFindAgainItem: #again ;
        yourself! 
title
        " Answer the title of the standard Edit menu. "
    ^self mnemonic, 'Edit'!   
openingSize: openingStyle

    self openWindowProperties isNil
        ifTrue: [ self openWindowProperties: Dictionary new ].

    self openWindowProperties at: #openingSize put:
        (openingStyle == #normal
            ifTrue: [ nil ]
            ifFalse: [ openingStyle ])!   
bitmap: aBitmap
        "Set the bitmap of the receiver."
    bitmap := aBitmap!
partChildren
        " Answer a collection containing the child parts of the receiver. "

    | childParts aPane |

    childParts := OrderedCollection new.

    ( aPane :=
        self partsIfOS2Do: [ self menuWindow ]
        partsIfWindowsDo: [ self menuPane ]) notNil
            ifTrue: [ childParts addAll: aPane partChildren ].

    childParts addAll: self children.

    ^childParts
!   
index: anInteger
        "Private - Set the receiver's menu index to anInteger."
    index := anInteger!
acceleratorOf: accel
        "Private - Answer an array which contains the
         accelerator key and bits."
    | array answer stream |
    answer := Array with: 0 with: 0.
    array := OrderedCollection new.
    stream := ReadStream on: accel.
    [stream atEnd] whileFalse: [
        array add: (stream upTo: $+) trimBlanks].
    array do: [:word |
        self classify: word in: answer].
    ^answer!
appendDeleteItem: aSelector
        " Append a Delete command item. "
    self appendItem:
            self class labelDelete,
            self class tabString, 'Del'
        selector: aSelector
        accelKey: DeleteKey
        accelBits: self class specialKeyAccelerator.!   
classify: word in: array
    | i |
    i := #( 'Alt' 'Ctrl' 'Shift' ) indexOf:  word.
    i > 0 ifTrue: [
        array at: 2 put: ( array at: 2 ) +
            ( ( Array with: AfAlt with: AfControl with: AfShift ) at: i ).
        ^self].
    word size = 1 ifTrue: [ "char"
        array at: 1 put: ( word at: 1 ).
        array at: 2 put: ( ( array at: 2 ) bitOr: AfChar ).
        ^self].

    "word must be an entry in VirtualKeysMap."
    array at: 1 put: ( VirtualKeysMap at: word ifAbsent: [ 0 ] ).
    array at: 2 put: ( ( array at: 2) bitOr: PARTSStandardMenu specialKeyAccelerator ).!  
labelClose
        " Answer the label of the Close item. "
    ^self mnemonic, 'Close'! 
defaultFrameCreationFlags
        "Private - Answer the default PM frame creation style for the receiver."
    self partsVosOnly.  " Only used on VOS"

	^super defaultFrameCreationFlags |
		WsNoByteAlign  "So windows can be positioned to the nearest pixel"!
disabledOwner: aWindow
        " Private - set the window which was disabled
        when opened modal. "
    self propertyAt: #disabledOwner put: aWindow.!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        evaluating: evaluating;
        withBlank: withBlank;
        closedAction: (closedAction partMirrorCopy: aMirrorCopyDictionary).
    ^copy!
setAccelerator: aString
    "Private - "

    aString size = 0
        ifTrue: [ accelerator := nil ]
        ifFalse: [ accelerator := aString ].
    self isHandleOk ifTrue: [ self display ].!   
standardSmalltalkMenuFor: anOwner
        " Answer a standard Smalltalk menu for anOwner. "
    self implementedBySubclass! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #clicked
            #disabledIsTrue #checkedIsTrue #hiddenIsTrue )
        separators: #( 1 )
        defaultItem: #clicked!   
uncheck
        "Uncheck the menu item."
    theMenu uncheckItem: self getMenuItem label.!  
appendFindReplaceItem: aSelector
        " Append a Find/Replace command item. "
    self appendItem:
            self class labelFindReplace,
            self class tabString, 'Ctrl+F'
        selector: aSelector
        accelKey: $f
        accelBits: self class controlCharAccelerator.!  
labelExit
        " Answer the label of the Exit item. "
    ^'E', self mnemonic, 'xit...'! 
searchForDefaultTextPane
        "Private - Answer the text pane that should be
         active when the window is opened."
    ^nil!  
display
            "Private - Display the text in the receiver."
    | origin |

    origin :=
        self partsIfOS2Do: [ 0 @ self font descender ]
        partsIfWindowsDo: [ 0 @ self font basePoint y ].

    self doGraphics: [
        self pen
        backColor: Color menuBackground;
            foreColor: Color menuText;
            font: SysFont;
            fill: Color menuBackground;
            displayText: label at: origin ]!
indexAttribute
    "Private"

    ^index!  
controlCharAccelerator
        " Answer the accelerator bits for Ctrl+<char>. "
    ^AfControl | AfChar!
labelUndoAccelerator
        " Answer the label of the Undo item accelerator. "

    self 
		partsIfOS2Do: [ ^'Alt+BckSpace' ]
    	partsIfWindowsDo: [ ^'Ctrl+Z' ].!
labelNewWorkspace
        " Answer the label of the New Workspace item. "
    ^self mnemonic, 'New Workspace'!  
frameWindow
        "Answer the frame window of the receiver."

    ^self! 
defaultBackColor
        "Answer the default background color for the receiver class."
    ^Color menuBackground!   
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message."
        " Platform-dependent (VW only) "
    self partsVwOnly.  " Only used on VW"

    ^nil!  
currentItemIndex: anIndex
    "Answer the current drag drop target position"

    currentItemRow := anIndex!   
appendClearItem: aSelector
        " Append a Clear command item. "
    self appendItem:
            self class labelClear,
            self class tabString, 'Del'
        selector: aSelector
        accelKey: DeleteKey
        accelBits: self class specialKeyAccelerator.!  
font
        "At runtime, there is no menu label control, so
        cannot set the font of the individual menu label."
    ^SysFont!  
titleBarHeight
        "Answer the height of a title bar."
    ^OperatingSystem getSystemValue: SystemValueTitleBarHeight!  
initialize

        "Reopned window leaves invalid handle"
    menuWindow notNil
        ifTrue: [ menuWindow initialize ].

    super initialize.
    self icon: PARTSApplication defaultIcon.!   
labelWordWrap
        " Answer the label of the Word Wrap item. "
    ^self mnemonic, 'Word wrap'!  
isPARTSMenuPart
        "Answer whether the receiver is an instance of PARTSMenuPart"
    ^true!
resize: aRectangle
        "Private - The size of the receiver has been changed
         to aRectangle."
    rectangle := self framingRectangleFor: aRectangle.

    "resizeWindow causes a sizeChanged: and registers
    the new rectangle with the operating system."
    self resizeWindow!
tabString
        " Answer a string containing a Tab character.
        Must be used to separate item label from accerator. "
    ^String with: Tab!   
contents: aString
        "Set label to be aString"
    label := aString.
    self isHandleOk
        ifTrue: [self display].!
buildWindow
        "Private - Create the host window for the receiver."
    self
        partsIfOS2Do: [ super buildWindow ]
        partsIfWindowsDo: [self buildWindowWindows]!
allowWorkbenchToBeDisabled: aBoolean
        " Specify whether the workbench can be disabled if it is
        found as the owner window. "
    ^self propertyAt: #allowWorkbenchToBeDisabled put: aBoolean!
appendSaveAsItem: aSelector
        " Append a Save As command item. "
    self appendItem:
            self class labelSaveAs,
            self class tabString, 'Alt+A'
        selector: aSelector
        accelKey: $a
        accelBits: self class altCharAccelerator.!  
wmClose: wordInteger with: longInteger
        "Private - Process the close window message."

    self partIsEditing ifTrue: [^0].  "NOTE: 1 for Windows"
    self sendInputEvent: #close.
    ^1!   
partIsDesktopChild
    "Private - Answer whether the receiver is always a child of the
    workbench desktop."
    | openProperties desktopChild |

    self partsIfWindowsDo: [ ^true ].

    ^( openProperties := self openWindowProperties ) isNil
        ifTrue: [ false ]
        ifFalse: [
            ( desktopChild :=
                openProperties at: #desktopChild ifAbsent: [ nil ]) isNil
                    ifTrue: [ false ]
                    ifFalse: [ desktopChild ] ].!   
wmNclbuttondown: wparam with: lparam
        "Private - Add a MessageExpression to CurrentEvents
         and return right away."
    | point |
    self partsVwOnly.
    point := Point fromInteger: lparam.
    self partIsEditing ifTrue: [
        ^self partEditorPane partButton1Down: (
                point mapToWindow:  self partEditorPane ) ].
    ^nil!
canTab
        "Private - Answer whether the receiver can
        be tabbed into and out of."
    ^false!  
removeSubpane: aWindow
        "Remove aWindow from the tabing info and
         the children pool."
    self orderedChildren remove: aWindow ifAbsent: [].
    super removeSubpane: aWindow.!
enable
        "Enable the menu item."
    theMenu enableItem: self getMenuItem label.! 
initialState: aState
    "Private - Set the initial opening state of the receiver
    during runtime"

    self propertyAt: #initialState put: aState!
labelKeysHelp
        " Answer the label of the Keys Help item. "
    ^LabelKeysHelp!   
editMenuCreateFor: textPane
        " Private - answer a new Edit menu. "

    ^(PARTSStandardEditMenu standardRuntimeMenuFor: textPane) allOwners: textPane!  
openModal: aParent
        "Open the dialog box modal to the
         current active window.  If the parent
         is a window/dialog part, don't disable it."
    | cursor windowToDisable |

    cursor := Cursor.
    CursorManager execute change.
    self isHandleOk
        ifTrue: [
            self bringToTop.
            self setInitialFocus.  "Or else, ESC wouldn't be detected"
            cursor change.
            self triggerEvent: #opened.
            ^self].

    windowToDisable := self getWindowToDisable: aParent.
    " Build window first in order to get a handle to set the owner."
    self validate.

        "Disable parent now to ensure that there are no further
     activities at parent. Set the owner of the dialog to the
    disabled window.  Check for a valid handle in case the
    receiver was closed as a result of the #opened event."
    ( windowToDisable notNil
        and: [ self superWindow isPARTSWindow not
        and: [ self isHandleOk ]])
      ifTrue: [
            self osOwner: windowToDisable.
            windowToDisable disable.
            self disabledOwner: windowToDisable.
            self setInitialFocus ]. "Remove focus from disabled window."

    CursorManager normal change.
    ( Processor currentProcessIsRecursive not
    and: [ self suspendClient
    and: [ self partIsEditing not ] ] )
        ifTrue: [
            self suspendProcess.
            "Previous process never got to trigger closed"
            self triggerEvent: #closed ].
    cursor change.!   
resizeToRectangle: aRectangle
        " Resize the receiver to aRectangle, whose coordinates
        are relative to my parent."
    | oldRect |

    oldRect := self frameRelativeRectangle.
    super resizeToRectangle: aRectangle.
    oldRect extent = aRectangle extent
        ifFalse: [ self updatePositions ]!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        label: label copy;
        accelerator: accelerator copy;
        yourself.
    ^copy!  
partHasVisualParts
        " Answer whether the receiver contains any visible parts. "

    ^false!
title
        " Answer the title of the standard File menu. "
    ^self mnemonic, 'File'!   
standardSmalltalkMenuFor: anOwner
        " Answer a standard Smalltalk File menu for anOwner. "
    ^self new
        owner: anOwner;
        appendNewWorkspaceItem: #openWorkspace ;
        appendOpenItem: #openFile ;
        appendInstallItem: #install ;
        appendSeparator;
        appendSaveItem: #accept ;
        appendSaveAsItem: #saveAs ;
        appendRestoreItem: #restore ;
        appendSeparator;
        appendBrowseClassesItem: #openClassBrowser ;
        appendBrowseDiskItem: #openDiskBrowser ;
        appendSeparator;
        appendPrintItem: #print ;
        appendPrintSetupItem: #printSetup ;
        appendSeparator ;
        appendSaveImageItem: #saveImage ;
        yourself! 
for: anOwner
        " Answer an empty menu with anOwner. "
    ^self new owner: anOwner!   
updateMenu
        "Private - Builds Smalltalk menu objects from parts menu item parts, etc."
    | item accel components links aLink receiver selector isSubMenu index |
    menuObject notNil ifTrue: [ ^self ].  "menu has been updated."
    menuObject := Menu new owner: self.
    components := self partWrapper components.
    components size > 0 ifTrue: [
        components do: [: each |
            ( each object isPARTSMenuSeparatorPart )
                 ifTrue: [ menuObject appendSeparator ].
            ( ( each object isPARTSMenuTextItemPart)
                or: [ each object isPARTSMenuBitmapItemPart ] )
                 ifTrue: [
                    isSubMenu := false.

                    ( links := each linksTriggeredBy: #clicked ).
                    links size > 0 ifTrue: [
                        aLink := links first.
                        [   aLink notNil
                                ifTrue: [
                                    receiver := aLink receiver.
                                    selector := aLink selector.
                                    receiver isPARTSNestedPart or: [ receiver isPARTSApplication ]]
                                ifFalse: [ false ]]
                            whileTrue: [
                                aLink := receiver menuClickedActionOf: selector ].

                        ( ( receiver == self) not and: [
                            receiver isPARTSMenuPart ] ) ifTrue: [
                            isSubMenu := true.
                            receiver updateMenu.
                            receiver menuObject title: each object contents.
                            menuObject appendSubMenu: receiver menuObject ] ].

                    isSubMenu ifFalse: [
                        item := self class getLabelFrom: each object contents.
                        accel := self class getAccelFrom: each object contents.
                        self appendItem: item accel: accel to: menuObject selector: each name asSymbol ] ].

            each object theMenu: menuObject.
            index := components indexOf: each" menuObject getIndex: each object contents".
            each object index: index.
            ( menuObject items at: index ) position: index - 1 ]]!   
appendFindAgainItem: aSelector
        " Append a Find Again command item. "
    self appendItem:
            self class labelFindAgain,
            self class tabString, 'Ctrl+G'
        selector: aSelector
        accelKey: $g
        accelBits: self class controlCharAccelerator.!
isPARTSMenuComponent
        "Answer whether the receiver is a PARTS
         MenuLabel, Menu, or menu item."
    ^true!   
id
    "Answer the id of the receiver.  Override id of ApplicationWindow.
        Normally an ApplicationWindow is not a child window and its id is
    not relevant, since the id is used to identify a child.  Instead, id is
    used to identify a menu handle during window creation.
        On the workbench, a window part IS a child window of the editor pane.
    id should answer the true child id of the receiver.  During creation on the
    workbench, though, make sure that id answers the menu handle
    (per ApplicationWindow>>id)."

    ^self partsIfOS2Do: [
        super id ]
    partsIfWindowsDo: [
    self partsVwOnly.  " Only used on VW"
        self propertyAt: #id  "From Window>>id" ]!  
buildWindowStyle: aStyle
        " Private - platform dependent "
    "For VW, need to add WsChild style in workbench, but not WsPopup.
        Two styles are mutually exclusive.
     Don't use addStyle:/removeStyle: because don't want styles around
        when launched."
    self partsVwOnly.  " Only used on VW"

    ^( self partIsEditing
        ifTrue: [  "o.w. window will be outside workbench."
            aStyle | WsChildWindow bitAnd: (WsPopUp bitXor: 16rFFFFFFFF)]
        ifFalse: [ aStyle] )  | WsInitiallyVisible bitXor: WsInitiallyVisible.!   
hide
    "Hide the receiver in its menu"
    | currentIndex pos |

    self hidden ifTrue: [ ^self ].

    currentIndex := self visibleIndex.
    theMenu items do: [ :aMenuItem |
        (( pos := aMenuItem position ) notNil
            and:  [ pos + 1 > currentIndex ])
                ifTrue: [ aMenuItem position: pos - 1 ]].
    self getMenuItem position: nil.

    PARTSMenuWindow
        deletePosition: self visibleIndex
        menu: theMenu window asParameter.
    self hidden: true.! 
theMenu: aMenu
        "Private - Set theMenu to aMenu."
    theMenu := aMenu!  
check
        "Place a check mark on the menu item."

    theMenu checkItem: self getMenuItem label.!  
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #clicked
            ).! 
appendSettingsItem: aSelector
        " Append a Settings command item. "
    self appendItem: self class labelSettings
        selector: aSelector.!  
insertItem: aMenuItem label: aStringOrBitmap
    "   Private - Insert aMenuItem as a menu item into the receiver
    with label aStringOrBitmap."
    

    self partsIfWindowsDo: [
        ^super insertItem: aMenuItem label: aStringOrBitmap ].
    self partsVosOnly.  " Only used on VOS"

    aMenuItem position isNil ifTrue: [ ^nil ]. "Hidden"
    ^super insertItem: aMenuItem label: aStringOrBitmap!   
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject partIsWindow
        and: [anObject isPARTSWindow not
        and: [anObject isPARTSMenuComponent not
        and: [anObject isPARTSMenuItem not
        and: [anObject isPARTSNotebookPagePane not]]]]]!
display
            "Private - Display the text in the receiver."
    | origin |

    "label size = 0 ifTrue: [^self]."
   origin :=
        self partsIfOS2Do: [ 0 @ self font descender ]
        partsIfWindowsDo: [ 0 @ self font basePoint y ].
    self doGraphics: [
        graphicsTool
        backColor: Color menuBackground;
        foreColor: Color menuText;
        font: SysFont;
        fill: Color menuBackground;
        displayText: self contents at: origin ]!
buildPopupMenu
        " Private - set the text pane popup menu "
    |textPane mnemonic menu |
    textPane := self pane.
    mnemonic := PARTSEditMenu mnemonic.
    menu := (PARTSEditMenu for: textPane titled: mnemonic, 'TextPanePopup')
        appendCopyItem: #copySelection ;
        appendCutItem: #cutSelection ;
        appendPasteItem: #pasteSelection ;
        appendSeparator ;
        appendItem: 'A', mnemonic, 'gain' selector: #again ;
        appendSubMenu: (self editMenuCreateFor: textPane);
        allOwners: textPane;
        yourself.
    textPane setPopupMenu: menu.!
hasMenuBar
        " Private - answer whether the receiver currently has a menu bar. "
    self error: 'not supported for dialog window'!   
initialize
        " Private "

    MnemonicString := '\u' replaceEscapeCharacters.
    SpecialKeyAccelerator := VirtualKeyConstants at: ( self
        partsIfOS2Do: [ 'AfVirtualkey' ]
        partsIfWindowsDo: [ 'AfLonekey' ] ).  " only defined in Windows "! 
characterInput: aCharacter
        "No child has the input focus so can
        translate to a mnemonic without the alt key down.
        Try to match with a mnemonic character in a sibling."
    self
        partsIfOS2Do: [ "Need to determine if a child already
            handled the characterInput: as a mnemonic." ]
        partsIfWindowsDo: [
        ( self altKeyInput: aCharacter from: self )
            ifTrue: [ "character handled"
                ^self ]] .

    ^super characterInput: aCharacter! 
disable
        "Disable the menu item."
    theMenu disableItem: self getMenuItem label.!  
standardRuntimeMenuFor: aHelpManager
        " Answer a standard runtime Help menu for aHelpManager. "
    | menu |
    menu := (self for: aHelpManager)
        appendHelpIndexItem: #displayHelpIndex;
        appendGeneralHelpItem: #displayExtendedHelpPanel;
        appendUsingHelpItem: #displayHelpForHelp;
        appendKeysHelpItem: #displayKeysHelp.
    aHelpManager aboutDlgClass notNil
        ifTrue: [
            menu
                appendSeparator;
                appendProductInformationItem: #about].
    ^menu!   
labelInstall
        " Answer the label of the Install item. "
    ^self mnemonic, 'Install...'!
labelNew
        " Answer the label of the New item. "
    ^self mnemonic, 'New'!   
addSubmenu: aMenu
        "Private - add the submenu <aMenu> to the receiver.
    This is only used when share a menu between a drop-down
    menu and a popup menu. "
    | item |

    allMenus add: aMenu.
    1 to: aMenu numberOfItems do: [: i |
        item := aMenu getMenuItemFromIndex: i.
        item submenu notNil ifTrue: [
            self addSubmenu: item submenu ] ].
!   
label: aString
    label := aString! 
partSize
    ^parent isNil
        ifTrue: [ self partDefaultExtent ]
        ifFalse: [ self frameRectangle extent ]! 
labelSaveAs
        " Answer the label of the Save As item. "
    ^'Save ', self mnemonic, 'As...'! 
hiddenPrivate
        "Private - Answer whether the menu item is hidden.  Will answer
        true if the receiver has received the 'hide' message, or is
    in a submenu that received the 'hide' message."
    | itemId menuHandle |

    menuHandle := theMenu window handle.
    itemId := ( theMenu getMenuItem: self getMenuItem label ) id.
    self partsIfOS2Do: [
        ^( PARTSHostInterface
           sendWindowMessageInt: menuHandle
           msg: MmIsItemValid
           parm1: itemId
           parm2: 0 ) = 0 "Hidden" ]
    partsIfWindowsDo: [
            "Check if item is hidden within menu."
        self hidden ifTrue: [ ^true ].
            "Check if item's entire menu is hidden"
        ^( PARTSHostInterface hostWindowLibrary
            getMenuState: menuHandle
            position: itemId
            flags: SmcByCommand ) = 16rFFFFFFFF  "-1" ] "Has been removed"!   
borderWidth
        "Answer the width of a non-sizing window border."
    ^OperatingSystem getSystemValue: SystemValueWindowBorderWidth!
labelSaveAs
        " Answer the label of the Save As item. "
    ^'Save ', self mnemonic, 'as...'! 
deletePosition: aMenuPosition menu: aMenuHandle
    "Private - Delete an item from the menuHandle at aMenuPosition."
    | id |

    self partsIfOS2Do: [
        id := PARTSHostInterface
           sendWindowMessageInt: aMenuHandle
           msg:  MmItemIdFromPosition
           parm1: aMenuPosition - 1
           parm2: 0.
        PARTSHostInterface
           sendWindowMessageInt: aMenuHandle
           msg:  MmDeleteItem
           parm1: id
           parm2: 0 ]

    partsIfWindowsDo: [
        PARTSHostInterface hostWindowLibrary
            deleteMenu: aMenuHandle
            position: aMenuPosition - 1
            flag: SmcByPosition ].! 
partIsShrinkable
        "Private - Can this part shrink in a PARTS Workbench."
    ^true!  
title
        " Answer the title of the standard Help menu. "
    ^self mnemonic, 'Help'!   
closeInnerWindows
        " Private - close the inner windows in the view. 
        Answer whether successful. "
    ^true!
click
        "Programatically click the receiver."

    ( self isDisabled or: [ self hiddenPrivate ])
        ifFalse: [self triggerEvent: #clicked]!
partDoesResizeToContents
        "Answer whether the receiver should be resized
         to accomodate changed text entered
         through direct-editing."
    ^true!  
standardSmalltalkExtendedMenuFor: anOwner
        " Answer a standard Smalltalk File menu for anOwner.
        Supports ProjectBrowser and ExtendedCHB. "
    ^self new
        owner: anOwner;
        appendNewWorkspaceItem: #openWorkspace ;
        appendOpenItem: #openFile ;
        appendInstallItem: #install ;
        appendSeparator;
        appendSaveItem: #accept ;
        appendSaveAsItem: #saveAs ;
        appendRestoreItem: #restore ;
        appendSeparator;
        appendBrowseProjectsItem: #openProjectBrowser ;
        appendBrowseClassesItem: #openExtendedCHB ;
        appendBrowseDiskItem: #openDiskBrowser ;
        appendSeparator;
        appendPrintItem: #print ;
        appendPrintSetupItem: #printSetup ;
        appendSeparator ;
        appendSaveImageItem: #saveImage ;
        yourself!   
defaultStyle
        "Private - Answer an Integer with appropriate styles in it.
    Exclude the scroll bars."
    ^self partsIfOS2Do: [
        super defaultStyle ]
     partsIfWindowsDo: [
        self partsVwOnly.  " Only used on VW"
        WsPaneBorder ]!   
defaultBackColor
        "Answer the default background color for the receiver class."
    ^Color menuBackground!   
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a menu "!  
appendBrowseProjectsItem: aSelector
        " Append a Browse Projects command item. "
    self appendItem:
            self class labelBrowseProjects,
            self class tabString, 'Alt+J'
        selector: aSelector
        accelKey: $j
        accelBits: self class altCharAccelerator.!  
labelReplace
        " Answer the label of the Replace item. "
    ^self mnemonic, 'Replace...'!
add: anObject interestIn: aFacet
        "Add anObject as a dependent of aFacet in the receiver.
         anObject is usually a subpane and aFacet is usually
         a selector (the name of the subpane).
         The PARTS Editor wants to ignore this."
    self owner isPARTSApplication
        ifFalse: [super add: anObject interestIn: aFacet].! 
labelHelpIndex
        " Answer the label of the Help Index item. "
    ^LabelHelpIndex!
buildWindow: parentWindow
        "Private - Create the window for the receiver
         using parentWindow as the parent."
    
    self owner partIsEditing
        ifTrue: [^super buildWindow: parentWindow]!
curFont
        "Private - Instance var curFont should stay nil.
        #font should always answer the SysFont."
    ^curFont!
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #clicked
            #disabledIsTrue
            #checkedIsTrue
            ).!
labelSaveExe
        " Answer the label of the Save Exe item. "
    ^'Save ', self mnemonic, 'exe...'!  
appendExitItem: aSelector
        " Append an Exit command item. "
    self appendItem:
            self class labelExit,
            self class tabString, 'Alt+F4'
        selector: aSelector
        accelKey: F4Key
        accelBits: self class altSpecialKeyAccelerator.!  
partShrunkenIconFile
        " Private - answer the name of the part file containing
        the icon to display when the receiver is shrunk
        in a PARTS Workbench window. "
    ^'MenuList.par'!  
defaultForeColor
        "Answer the default background color for the receiver class."
    ^Color menuText! 
initialize
        " Private - class initialization. "

    | mnemonic |
    mnemonic := self mnemonic.
    self
        partsIfOS2Do: [
            LabelProductInformation := self mnemonic, 'Product information'.
            LabelSamples := mnemonic, 'Samples'.
            ]
        partsIfWindowsDo: [
            LabelProductInformation := self mnemonic, 'About ', WindowLabelPrefix, ' ...'.
            LabelSamples := 'Sa', mnemonic, 'mples'.
            ].!