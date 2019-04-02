"3.0.0.4"
!

Smalltalk at: #WBConstants ifAbsentPut: [ nil ]!  

WBBitmapManager subclass: #CPBitmapDict
  instanceVariableNames: ''
  classVariableNames: 
    ' CurrentDictMap SystemDictMap '
  poolDictionaries: ''! 

WBStaticGraphic subclass: #CPStaticGraphic
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

!TextEdit methods !   
scrollBars
        "Obsolete - Set the style to include any scroll bars.
			Use addHorizontalScrollbarStyle and addVerticalScrollbarStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        addStyle: WsBorder | WsHscroll | WsVscroll;
        sendInputEvent: #disableWordWrap.! !

!SubPane methods !  
setDragDropObjects: aCollectionOfStrings
    "Obsolete - Retained for old drag/drop model support.
        Set the drag & drop objects."

    | dragSession |
    #addedByOSI.
    #obsoleteMethod.
    (dragSession := self propertyAt: #dragSession)
        defaultOperation: 'copy';
        objects: (
            aCollectionOfStrings asArray collect: [ :obj |
                dragSession objectClass new
                    string: obj asString;
                    yourself ] ).! !

!SubPane methods !  
setDragDropObjects
    "Obsolete - Retained for old drag/drop model support.
        Set the drag & drop objects.
        This is the default handler for the #needsDragDropObjects event."

    | objects |
    #addedByOSI.
    #obsoleteMethod.
    (objects := self defaultDragDropObjects) notNil
        ifTrue: [ self setDragDropObjects: objects ]
        ifFalse: [ self dragSourceNeedsObjectDefault: (self propertyAt: #dragSession) ].! !

!CPBitmapDict class methods !
fromPath: aString
		"Private - Answer a new initialized instance loaded from the specified file.
			Answer nil if there is no such file."
    | stream answer |
	#obsoleteMethod.
	(File exists: aString) ifFalse: [ ^nil ].
    stream := File pathName: aString.
    stream nextLine = 'BITMAPS' ifFalse: [
        stream close.
        MessageBox message: 'The file named "', aString fileNameLessPath, '" is not a valid bitmap dictionary file.'.
        ^nil ].
    answer := Dictionary new.
	[ [ stream atEnd ] whileFalse: [
       answer
			at: stream nextLine
			put: (Bitmap fromStream: stream) ].
	] ensure: [ stream close ].
    ^answer! !

!SubPane methods !  
dragDropReceiver
    "Obsolete - Retained for old drag/drop model support.
        Convert the old drag/drop model events to work with the new..."
    | formats operations |
    #addedByOSI.
    self obsoleteMethod.
    self
        when: #dragTargetDrop: send: #dragDropReceiverDroppedOn: to: self;
        dragTargetForFormats: (
            (formats := self dragTargetFormatsDefault)
                ifNil: [ #( 'string' ) ] )
        operations: (
            (operations := self dragTargetOperationsDefault)
                ifNil: [ #( 'move' 'copy' ) ] );
        dragTarget: true.! !

!CPBitmapDict class methods ! 
at: aString ifAbsent: aBlock
		"Obsolete - Answer the bitmap named aString.
			Answer aBlock evaluated if no bitmap is found."
	#obsoleteMethod.
	^self current
		at: (
			self currentDictMap
				at: aString
				ifAbsent: [ self current validBitmapName: aString ] )
		ifAbsent: aBlock! !

!DragDropSession methods ! 
location
    "Obsolete - Retained for old drag/drop compatability."

    #addedByOSI.
    self obsoleteMethod.
    ^self targetLocation! !

!DrawnButton methods ! 
setDefault
    	"Obsolete - Set the receiver as the default button.
			Use defaultPushButton or setDefault: instead."
    #addedByOSI.
    self obsoleteMethod.
    label isNil ifFalse: [ super setDefault ].! !

!SubPane methods !  
isGroupable
		"Obsolete - Answer true if the receiver is groupable."
    #addedByOSI.
    #obsoleteMethod.
    ^false! !

!EntryField methods ! 
readonly
		"Obsolete - Use readOnly instead."
    #addedByOSI.
    self obsoleteMethod.
    self readOnly.! !

!Window methods !
wbFixDialogFraming
	    "Private - Shrink the dialog extent by a percentage."
    | block fraction offset |
	#addedByOSI.
    (block := self framingBlock) class == FramingParameters ifTrue: [
		Smalltalk platformIsWin32 ifTrue: [
			fraction := 1.
			offset := 18 @ 56.
			block iDUE: (block iDUE * fraction - offset) rounded.
			block cRDU: (
				block cRDU leftTop extentFromLeftTop: (
					(block cRDU extent * fraction - offset) rounded ) ) ] ].
	Smalltalk platformIsOS2 ifTrue: [
	    self children do: [ :each | each wbFixDialogFraming ] ].! !

!DrawnButton methods !  
cpSize
		"ObsoleteMethod - Answer the extent of the receiver's rectangle.
			Use extent instead."
    | rect |
    #addedByOSI.
    self obsoleteMethod.
    rectangle isNil
        ifTrue: [
            ^(framingBlock value: self parent rectangle) extent ]
        ifFalse: [ ^self extent ]! !

!Window class methods ! 
constructEventsTriggered
		"Private - answer the set of events that instances of the
		receiver can trigger."
		"Modified by OSI to add support for old drag/drop model conversion."
	#modifiedByOSI.
	#obsoleteMethod.	"Obsolete modifications by OSI."
	^super constructEventsTriggered
		add: #dragSourceNeedsObject: ;
		add: #dragSourceCut: ;
        add: #dragSourceNeedsCursors: ;

		add: #dragTargetNeedsOperations: ;
		add: #dragTargetEnter: ;
		add: #dragTargetLeave: ;
		add: #dragTargetOver: ;
		add: #dragTargetDrawEmphasis: ;
		add: #dragTargetEraseEmphasis: ;
		add: #dragTargetDrop: ;

		"old drag drop events..."
		add: #dragDropped: ;
		add: #needsDragDropObjects ;
		add: #needsDragDropCursor ;

		yourself! !

!DrawnButton methods !
fileExists: fileName
    "Obsolete - Only valid .BMP files should be allowed.
		Use File exists: instead."
    | array file exists extension |
    #addedByOSI.
    self obsoleteMethod.
    (fileName includes: $*) ifTrue: [ ^false ].
    array := File splitPath: fileName in: Disk.
    ((file := array at: 3) includes: $.) ifFalse: [ ^false ].
    exists := ((file ~= '.') and: [ (file ~= '..') and: [ File exists: fileName ]]).
    exists ifTrue: [
        file := file asStream.
        extension := (file skipTo: $.; upTo: $.) asUpperCase.
        extension = 'BMP' ifTrue: [ ^true ]].
    ^false! !

!TextPane methods !
noScrollBars
        "Obsolete - Set the style not to include any scroll bars.
			Use removeHorizontalScrollbarStyle and removeVerticalScrollbarStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        removeHorizontalScrollbarStyle;
        removeVerticalScrollbarStyle.! !

!Window methods !   
createdBy
    "Added by OSI - reports creation information"
    #addedByOSI.
	self obsoleteMethod.
    ^self propertyAt: #createdBy! !

!ApplicationWindow methods !
setBackColor: c

    "Added by OSI for PM portability"

    #addedByOSI.
    self obsoleteMethod.
    self backColor: c! !

!CPBitmapDict class methods ! 
sysAt: aString put: aBitmap
        "Obsolete - Set the bitmap named aString."
	| newName |
    #obsoleteMethod.
	newName := self system validBitmapName: aString.
	self system at: newName put: aBitmap.
	newName = aString ifFalse: [
		self systemDictMap
			at: aString put: newName ].! !

!SubPane methods !  
dragDropSender
    "Obsolete - Retained for old drag/drop model support.
        Convert the old drag/drop model events to work with the new..."

    #addedByOSI.
    self obsoleteMethod.
    self
        when: #dragSourceNeedsObject: send: #dragDropSenderNeedsObject: to: self;
        dragSource: true.! !

!CPBitmapDict class methods !  
systemDictMap
		"Obsolete - Answer a dictionary mapping old bitmap names
			to new bitmap names."
	^SystemDictMap ifNil: [ SystemDictMap := Dictionary new ].! !

!Toggle methods !  
unsetDefault
    	"Obsolete - Set the receiver as the default button.
			Use pushButton or setDefault: instead."
    #addedByOSI.
    self obsoleteMethod.! !

!Window methods !
modifiedBy: aString
    "Added by OSI - records modification information"
    #addedByOSI.
	self obsoleteMethod.
    self propertyAt: #modifiedBy put: aString.! !

!DrawnButton methods !  
fixedSize
        "If the receiver has a bitmap for its
         label (contents), draw the bitmap
         at its fixed size."
    #modifiedByOSI.		"Modified by OSI to record style information"
    self obsoleteMethod.		"Obsolete modification by OSI."
    self drawIsotropic.
    self propertyAt: #cpStyle put: #fixedSize.! !

!DialogTopPane methods ! 
close
        "Private - Close the dialog box."

    "Support the old event mechanism..."
    #modifiedByOSI.
    #obsoleteMethod.    "Obsolete modification by OSI."
    (self event: #close) notNil ifTrue: [ ^self ].

    self isOkToClose ifFalse: [ ^self ].

    parent notNil ifTrue: [ parent enable ].
    handle hideWindow.
    children size > 0 ifTrue: [
        children do: [ :subpane | subpane close ] ].
    self stopReceivingMessages.

    PoppedModelessWindows remove: handle ifAbsent: [ ].
    self destroy.
    self subPaneWithFocus: nil.
    self triggerEvent: #closed.

    Processor currentProcessIsRecursive ifTrue: [ ^self ].   "no semaphore wait"

    sem notNil ifTrue: [
        sem signal.
        sem := nil.
        Processor suspendActive ]! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!GraphPane methods !   
noBorders
		"Obsolete - Set the style to not include a border.
			Use removeBorderStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        noScrollBars;
        removeBorderStyle.! !

!FramingParameters class methods ! 
new
		"Answer a new instance of the receiver."
	#obsoleteMethod.
	"Old code support..."
	InitializationSelector isNil ifTrue: [ ^super new ].
	^self basicNew perform: InitializationSelector! !

!CPBitmapDict class methods !
at: aString put: aBitmap
        "Obsolete - Set the bitmap named aString."
	| newName |
    #obsoleteMethod.
	newName := self current validBitmapName: aString.
	self current at: newName put: aBitmap.
	newName = aString ifFalse: [
		self currentDictMap
			at: aString put: newName ].! !

!CPBitmapDict class methods !   
sysAt: aString
        "Obsolete - Answer the system bitmap named aString.
            Report an error if no bitmap is found."
    #obsoleteMethod.
    ^self sysAt: aString ifAbsent: [
        self system errorBitmapNotFound: aString ]! !

!Window methods !  
wbFixFraming
    "Private - Flip top and bottom in FramingParameters."

    | block fraction |
	#addedByOSI.
    (block := self framingBlock) class == FramingParameters ifTrue: [
        (fraction := block top) isFraction ifTrue: [
            block tP: (fraction denominator - fraction numerator) / fraction denominator
        ].
        (fraction := block bottom) isFraction ifTrue: [
            block bP: (fraction denominator - fraction numerator) / fraction denominator
        ].
    ].
    self children do: [ :each | each wbFixFraming ].! !

!Window methods !  
createdBy: aString
    "Added by OSI - records creation information"
    #addedByOSI.
	self obsoleteMethod.
    self propertyAt: #createdBy put: aString.! !

!EntryField methods ! 
maxSize
    "Obsolete - Return the maximum number of characters allowed in the receiver.
		Use textLimit instead."
    #addedByOSI.
    self obsoleteMethod.
    ^self textLimit! !

!CPBitmapDict class methods ! 
addCurrentMap: aDictionary
		"Add a mapping of bitmap names."
	#obsoleteMethod.

	aDictionary associationsDo: [ :assoc |
		self currentDictMap
			at: assoc key
			put: assoc value ].! !

!FramingParameters methods !  
initializeOld
	    "Private - Initialize the receiver with old dialog units."
	#obsoleteMethod.
	"Old code support."
    centerX := false.
    centerY := false.
    indent := 0@0.
    initialExtent := 0@0.
	duWidth := self class oldDialogUnitWidth.
	duHeight := self class oldDialogUnitHeight.! !

!TextEdit methods !  
noBorders
		"Obsolete - Set the style to not include a border.
			Use removeBorderStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        removeStyle: WsBorder | WsHscroll | WsVscroll;
        sendInputEvent: #disableWordWrap.! !

!ViewManager methods ! 
closeWindow

    "Obsolete - Added by OSI for backward compatibility with
     WB Windows 1.x"
    #addedByOSI.
    #obsoleteMethod.
    ^self close! !

!CompositePane methods ! 
wbPreOldVersionSupport
        "Private - Support old versions of WB."
    | version |
    #addedByOSI.
    self isWBWindow ifTrue: [
        version := self class wbVersion.
		version >= 2.0
			ifTrue: [ FramingParameters setInitializationNew ]
			ifFalse: [ FramingParameters setInitializationOld ] ].! !

!SubPane methods !  
dragDropSenderNeedsObject: dragSession
    "Obsolete - Retained for old drag/drop model support."

    #addedByOSI.
    self obsoleteMethod.
    self propertyAt: #dragSession put: dragSession.
    [ self
        triggerEvent: #needsDragDropObjects
        ifNotHandled: [ self setDragDropObjects ]
    ] ensure: [
        self propertyAt: #dragSession put: nil ].
    dragSession defaultOperation: 'copy'.! !

!SubPane methods ! 
defaultDragDropObjects
    "Obsolete - Retained for old drag/drop model support.
        Answer the default drag/drop objects, or nil if none."

    #addedByOSI.
    self obsoleteMethod.
    ^nil! !

!Button methods ! 
isGroupable
		"Obsolete - Answer true if the receiver is groupable."
    #addedByOSI.
    self obsoleteMethod.
    ^true! !

!CPBitmapDict class methods !  
currentDictMap
		"Obsolete - Answer a dictionary mapping old bitmap names
			to new bitmap names."
	^CurrentDictMap ifNil: [ CurrentDictMap := Dictionary new ].! !

!FramingParameters class methods !  
setInitializationOld
		"Obsolete - For old code support."
	#obsolete.
	InitializationSelector := #initializeOld.! !

!CPBitmapDict class methods !   
addSystemBitmaps: aFileName
		"Obsolete - Add the bitmaps in aFileName to the system bitmap manager."
	| dict |
	#obsoleteMethod.
	(dict := self fromPath: aFileName) notNil ifTrue: [
		dict keysAndValuesDo: [ :eachBitmapName :eachBitmap |
			self sysAt: eachBitmapName put: eachBitmap ] ].! !

!ViewManager methods !  
wbPreOldVersionSupport
        "Private - Support old versions of WB."
    | version |
    #addedByOSI.
    self isWBWindow ifTrue: [
        version := self class wbVersion.
		version >= 2.0
			ifTrue: [ FramingParameters setInitializationNew ]
			ifFalse: [ FramingParameters setInitializationOld ] ].! !

!CPBitmapDict class methods !   
sysAt: aString ifAbsent: aBlock
		"Obsolete - Answer the system bitmap named aString.
			Answer aBlock evaluated if no bitmap is found."
	#obsoleteMethod.
	^self system
		at: (
			self systemDictMap
				at: aString
				ifAbsent: [ self system validBitmapName: aString ] )
		ifAbsent: aBlock! !

!DragDropSession methods !  
items
    "Obsolete - Retained for old drag/drop compatability.
        Answer an array of strings."

    | answer item |
    #addedByOSI.
    self obsoleteMethod.
    answer := OrderedCollection new.
    self objects do: [ :ddObj |
        (item := ddObj string) isString ifTrue: [
            answer add: item ] ].
    ^answer asArray! !

!DrawnButton methods !  
cpStyle
		"Obsolete - Answer the button's style."
    #addedByOSI.
    self obsoleteMethod.
    ^self propertyAt: #cpStyle! !

!Toggle methods !
setDefault
    	"Obsolete - Set the receiver as the default button.
			Use defaultPushButton or setDefault: instead."
    #addedByOSI.
    self obsoleteMethod.! !

!FramingParameters class methods !  
setInitializationNew
		"Obsolete - For old code support."
	#obsolete.
	InitializationSelector := nil.! !

!SubPane methods ! 
setDragDropCursor: ignore
    "Obsolete - Retained for old drag/drop model support.
        Ignored."

    #addedByOSI.
    #obsoleteMethod.! !

!TextEdit methods !   
noScrollBars
        "Obsolete - Set the style not to include any scroll bars.
			Use removeHorizontalScrollbarStyle and removeVerticalScrollbarStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        removeStyle: WsHscroll | WsVscroll;
        addStyle: WsBorder;
        sendInputEvent: #disableWordWrap.! !

!CPBitmapDict class methods !  
at: aString
        "Obsolete - Answer the bitmap named aString.
            Report an error if no bitmap is found."
    #obsoleteMethod.
    ^self at: aString ifAbsent: [
        self current errorBitmapNotFound: aString ]! !

!Window methods !  
add: aWindow interestIn: name
    "Defer processing..."
    #addedByOSI.
    self obsoleteMethod.
    self mainWindow
        sendInputEvent: #add:interestIn:
        withArgs: ( Array
            with: aWindow
            with: name ).! !

!TopPane methods ! 
close: aPane
    #addedByOSI.
    self obsoleteMethod.
    ^nil! !

!GraphPane methods ! 
noScrollBars
        "Obsolete - Set the style not to include any scroll bars.
			Use removeHorizontalScrollbarStyle and removeVerticalScrollbarStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        removeHorizontalScrollbarStyle;
        removeVerticalScrollbarStyle.! !

!NotificationManager methods !  
isAltDown
        "Added by OSI - Answer true if a alt key is down."
    #addedByOSI.
    self obsoleteMethod.
    ^self isKeyDown: AltKey! !

!CPBitmapDict class methods !
keyAtValue: anObject ifAbsent: aBlock
		"Answer the key for anObject.
			If not found then answer aBlock evaluated."
	^self current
		keyAtValue: anObject
		ifAbsent: aBlock! !

!Window class methods !  
wbInitializeObsoleteRuntime
		"Initialize the obsolete runtime."

	Smalltalk
		at: #WBConstants
		put: (
			Smalltalk
				at: #OperatingSystemConstants
				ifAbsent: [Dictionary new]).

	"Refresh all window subclass event triggered class instance variables..."
	Window withAllSubclasses do: [ :cl | cl eventsTriggered: nil ].! !

!CompositePane methods !   
wbOldVersionSupport
        "Private - Support old versions of WB."
    | version |
    #addedByOSI.
    self isWBWindow ifTrue: [
        version := self class wbVersion.
        self views do: [ :each |
            each wbOldVersionSupport: version ] ].! !

!SubPane methods !   
getContentsHandler
    "Added by OSI"
    #addedByOSI.
    self obsoleteMethod.
    ^(self handlers at: #getContents ifAbsent: [^nil]) selector! !

!CPBitmapDict class methods !   
addSystemMap: aDictionary
		"Add a mapping of bitmap names."
	#obsoleteMethod.
	aDictionary associationsDo: [ :assoc |
		self systemDictMap
			at: assoc key
			put: assoc value ].! !

!ViewManager methods !
wbOldVersionSupport
        "Private - Support old versions of WB."
    | version |
    #addedByOSI.
    self isWBWindow ifTrue: [
        version := self class wbVersion.
        self views do: [ :each |
            each wbOldVersionSupport: version ] ].! !

!DrawnButton methods !   
stretchToFit
		"If the button has a bitmap as its label,
			stretch or shrink the bitmap to fill the button."
    #modifiedByOSI.		"Modified by OSI to record style information"
    #obsoleteMethod.		"Obsolete modification by OSI."
    self drawAnisotropic.
    self propertyAt: #cpStyle put: #stretchToFit.! !

!Window methods !  
wbOldVersionSupport: versionNumber
    "Private - Support old versions of WB."

    | oldOrder |

    versionNumber >= 1.90 ifTrue: [ ^self ].
    #addedByOSI.

    "For versions older than 1.90,
        move the Groupbox & StaticBox instances
        to the back."

    oldOrder := self orderedChildren.
    self orderedChildren: (
        ( oldOrder reject: [ :child | child wbAddToBack ] ),
        ( oldOrder select: [ :child | child wbAddToBack ] ) reversed ).

    "FramingParameters are leftTop relative on both Win32 and OS/2 now,
        so convert the old framing parameters."

    Rectangle leftTopUnit y = 0 ifFalse: [ self wbFixFraming ].! !

!Object methods !   
isRadio
    "Obsolete - Added by OSI.  Use isRadioButton instead."
    #addedByOSI.
    self obsoleteMethod.
    ^self isRadioButton! !

!ControlPane methods ! 
wkDrag

    "Private: Added by Objectshare.
     Start a drag-drop operation, with the receiver
     as the drag sender.  Answer the window handle of the
     selected target (receiver) window, or nil if not a valid receiver."

    | point winPoint handleAtPoint styleFlag valid pane |
    #addedByOSI.
    #osiHack.
    self captureMouseInput.
    Notifier
        consumeInputUntil:
            [:event |
            point := Cursor sense.
            winPoint := WinPoint fromPoint: point.
            handleAtPoint := WindowHandle fromInteger: (UserLibrary windowFromPoint: winPoint asParameter).
            handleAtPoint isValid
                ifTrue:
                    [styleFlag := (WinLong fromString: (UserLibrary getWindowLong: handleAtPoint asParameter index: GwlExstyle)) asInteger.
                    (valid := (styleFlag & WsExAcceptfiles ~= 0))
                        ifTrue: [self dragDropCursor change].
                    valid
                        ifFalse:
                            [(pane := Notifier findWindow: handleAtPoint asInteger) notNil
                                ifTrue:
                                    [pane isDragDropReceiver
                                        ifTrue:
                                            [self dragDropCursor change.
                                            valid := true]]].
                    valid
                        ifFalse: [CursorManager dragDropNone change].
                    ]
                ifFalse:
                    [CursorManager dragDropNone change].
            (event selector = #button1Up: or: [event selector = #button2Up:])].
    self clearMouseCapture.
    CursorManager normal change.
    ^valid
        ifTrue: [handleAtPoint]
        ifFalse: [nil]! !

!NotificationManager methods !  
isCtrlDown
        "Added by OSI - Answer true if a control key is down."
    #addedByOSI.
    self obsoleteMethod.
    ^self isKeyDown: ControlKey! !

!TextEdit methods ! 
wordWrap
		"Obsolete - Set the style to include a vertical scrollbar and automatically word wrap.
			Use enableWordWrapFlags instead."
    #addedByOSI.
    self obsoleteMethod.
    self
        removeStyle: WsHscroll;
        addStyle: WsBorder | WsVscroll;
        sendInputEvent: #enableWordWrap.! !

!Window methods !
modifiedBy
    "Added by OSI - reports modification information"
    #addedByOSI.
	self obsoleteMethod.
    ^self propertyAt: #modifiedBy! !

!CPBitmapDict class methods ! 
addBitmaps: aFileName
		"Obsolete - Add the bitmaps in aFileName to the current bitmap manager."
	| dict |
	#obsoleteMethod.
	(dict := self fromPath: aFileName) notNil ifTrue: [
		dict keysAndValuesDo: [ :eachBitmapName :eachBitmap |
			self at: eachBitmapName put: eachBitmap ] ].! !

!SubPane methods !  
defaultDroppedOn: dragSession
    "Obsolete - Retained for old drag/drop model support."

    #addedByOSI.
    self obsoleteMethod.
    self dragTargetDropDefault: dragSession.! !

!CPBitmapDict class methods ! 
renameBitmaps: aDictionary in: aWBBitmapManager
		"Obsolete - Rename the specified bitmaps."
	#obsoleteMethod.
	aDictionary associationsDo: [ :eachMap |
		aWBBitmapManager
			rename: eachMap key
			to: eachMap value ].! !

!StringModel methods ! 
fileInFrom: aStream
        "Replace receiver's contents
         with the contents of aStream."
    | line |
	#modifiedByOSI.
	"Don't convert tabs to spaces... for menu definitions."
    lines := OrderedCollection new.
    [aStream atEnd] whileFalse: [
        line := aStream nextLine.
        lines add: line "( line replaceCharacter: Tab from: 1 to: line size withString: '    ' )" ].
    extent := self extent! !

!FramingParameters class methods ! 
oldDialogUnit
		"Answer a point representing the old dialog unit."
	#obsoleteMethod.
	"Old code support."
    ^self oldDialogUnitWidth @ self oldDialogUnitHeight! !

!TextPane methods !   
noBorders
		"Obsolete - Set the style to not include a border.
			Use removeBorderStyle instead."
    #addedByOSI.
    self obsoleteMethod.
    self removeBorderStyle.! !

!DrawnButton methods ! 
unsetDefault
    	"Obsolete - Set the receiver as the default button.
			Use pushButton or setDefault: instead."
    #addedByOSI.
    self obsoleteMethod.
    label isNil ifFalse: [ super unsetDefault ].! !

!SubPane methods ! 
dragDropReceiverDroppedOn: dragSession
    "Obsolete - Retained for old drag/drop model support."

    #addedByOSI.
    self obsoleteMethod.
    self
        triggerEvent: #dragDropped:
        withArguments: (Array with: dragSession)
        ifNotHandled: [
            self defaultDroppedOn: dragSession ].! !

!Button methods ! 
setDefault
    	"Obsolete - Set the receiver as the default button.
			Use defaultPushButton or setDefault: instead."
    #addedByOSI.
    self obsoleteMethod.
    self setDefault: true! !

!DialogTopPane methods ! 
wbOldVersionSupport: versionNumber
        "Private - Support old versions of WB."
    #addedByOSI.
    super wbOldVersionSupport: versionNumber.
    versionNumber >= 1.90 ifTrue: [ ^self ].
    self wbFixDialogFraming.! !

!TextEdit methods !
noWordWrap
		"Obsolete - Set the style to exclude a vertical scrollbar and automatically word wrap.
			Use disableWordWrapFlags instead."
    #addedByOSI.
    self obsoleteMethod.! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!

"bindAction:
	Message
		receiver: Window
		selector: #wbInitializeObsoleteRuntime"

	Window wbInitializeObsoleteRuntime.!