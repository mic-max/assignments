3.1.0.106
   
partsApplicationCoordinator
    ^self classNamed: #PARTSApplicationCoordinator!  
pixelsPerVerticalDialogUnit
    "Private - Answer the number of pixels
    per vertical dialog unit. Answer can be a fraction."

    ^self verticalDialogBaseUnit / self verticalDialogUnitsPerCharacter! 
editorsOnPathName: aFileReference
        " Answer any editors open on <aFileReference>. "

    | appPathName |
    appPathName := aFileReference asString.
    ^self activeEditors select: [ :anEditor |
        anEditor appPathName notNil
        and: [ anEditor appPathName asString equalsIgnoreCase: appPathName ] ]!  
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."
    self partsVosOnly.  " Only used on VOS"

    ^self class noScrollbarsFrameStyle!
getTargetAt: aScreenPoint editorPane: anEditorPane

    ^anEditorPane windowUnderPointNoGroupBox:
		( aScreenPoint mapToWindow: anEditorPane )!
icons: aCollection
    self deselectAllIcons.
    icons := OrderedCollection new.
    icons addAll: aCollection!   
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "

   ^super constructEventsTriggered
        addAll: #(
            #button1DownAlt
            #doubleClicked:
            #iconMoved:
            );
        yourself! 
iconWithConnection: anObject
    icons isNil ifTrue: [^nil].
    ^icons detect: [:icon | icon connection == anObject]
        ifNone: [nil]!   
optionAt: aSymbol
        " Private - answer the value of the option named aSymbol. "

    options isNil ifTrue: [ ^nil ].
    ^options at: aSymbol ifAbsent: [ nil ]!
fileSaveAs

    | aPathName |
    aPathName := PARTSHostInterface saveFilePathNameFromUser:
        ( fileName isNil
            ifTrue: [ '*.', self defaultFileExtension ]
            ifFalse: [ fileName ] ).
    aPathName isNil ifTrue: [ ^self ].
    fileName := aPathName.
    CursorManager execute 
		changeFor: [ self accept ].!   
forFont: aFont
        " Answer a new PARTS Workbench link settings instance
        with <aFont> for the link label setting. "

    ^super new
        labelFont: aFont;
        yourself! 
openOnFile: aFileName directory: aDirectory
        " Private "

    | catalogs editors anEditorWindow |
    editors := PARTSEditor activeEditors.
    anEditorWindow := ( editors isEmpty
        ifTrue: [
            ( PARTSEditor editorClass new openOn: PARTSApplication new withCatalogs: #() )
                mainView ]
        ifFalse: [
            (catalogs := PARTSCatalog activeCatalogWindows) isEmpty
                ifTrue: [ editors first mainView ]
                ifFalse: [ catalogs first ownerWindow ] ] ).
    ^self catalogClass new
        paletteDirectory: aDirectory;
        paletteFile: aFileName "asUpperCase";
        openFor: anEditorWindow! 
inputPathName: aFilePathName
            "Set the input file path name."
    partApplication := PARTSFile applicationFromPathName: aFilePathName!   
initCursors
    "Set the cursors for the receiver's feedback."
    | icon hotSpot |

    icon := objects first wrapper icon copy asPARTSIcon.
    hotSpot := 0 @ 0.
    validCursor := icon asPointerWithHotSpotAndMark: hotSpot.
    invalidCursor := icon asPointerWithStopSign: hotSpot.!   
selectedItem
        "Answer a single selected icon, if any."
    ^selectedIcons size > 0
            ifTrue: [ selectedIcons first ]
            ifFalse: [ nil ]!   
offset
    "Answer the offset of the object from the object origin to the
    source location."
    ^offset!   
startRect
    "Answer the initial rectangle of the receiver during
    the drag session."

    ^startRect!
backupDelete: aPathName
        "Delete a backup file with extension .BAK for aPathName."
        "Do not allow backup of EXE yet."!
setInputDirectoryForStream: aStream
		"Private - set the input directory to be the
		directory containing aStream, assumming
		aStream is a file based stream."
	| file filePathName |
	( aStream isKindOf: FileStream ) ifFalse: [ ^self ].
	file := aStream file.
	filePathName := file pathName.
	self inputDirectoryName: filePathName fileNamePath!  
source: anObject
        "Create a new instance with anObject as the drag source."
    | session |

    session := super source: anObject.
    anObject currentDragSession: session.
    ^session!  
fileName: aString
        " Private "

    fileName := aString.!   
changesHandled
        " Private - answer whether changes have been handled.
        Allow user to save or discard. "
    | saveChanges |
    changeFlag ifFalse: [^true].   " no changes "
    saveChanges := MessageBox
        threeStateNotify: 'Please confirm'
        withText: 'Save changes?'.
    saveChanges isNil ifTrue: [^false].  " cancelled "
    saveChanges ifTrue: [self accept].
    ^true!
mouseButtonLink
        " Answer the mouse button used for creating links. "

    ^mouseButtonLink!
createMasks: anIcon
        "Private - Create the AND and XOR masks for anIcon."
    | extent |
    self partsVwOnly.  " Only used on VW"

    extent := ( anIcon bitmap isNil
        ifTrue: [ PARTSIcon iconSize ]
        ifFalse: [ anIcon xorMask extent ] ).
    andMask := Bitmap extent: extent.
    icon xorMask isColorBitmap
        ifTrue: [xorMask := Bitmap width: extent x height: extent y planes: 1 bitCount: 4]
        ifFalse: [xorMask := Bitmap extent: extent].

    copy := Bitmap screenExtent: extent.
    copy pen fill: Color cyan.
    (anIcon andMask notNil and: [anIcon andMask isValid])
        ifTrue: [
            andMask pen copyBitmap: anIcon andMask
                from: andMask boundingBox
                at: 0 @ 0.
            xorMask pen copyBitmap: anIcon xorMask
                from: xorMask boundingBox
                at: 0 @ 0.
            copy pen
                foreColor: Color white;
                backColor: Color black.
            copy pen copyBitmap: andMask
                from: andMask boundingBox
                at: 0 @ 0
                rule: CopyRuleSourceAnd.
            copy pen copyBitmap: xorMask
                from: xorMask boundingBox
                at: 0 @ 0
                rule: CopyRuleSourceInvert.
            copy pen
                foreColor: PARTSHostInterface colorDefault;
                backColor: PARTSHostInterface colorBackground]
        ifFalse: [
            xorMask pen fill: xorMask boundingBox rule: CopyRuleBlack.
            andMask pen fill: andMask boundingBox rule: CopyRuleWhite ]!   
canTriggerEvent: eventName
        "Answer whether a PARTS Workbench editor
        can trigger an event named <eventName>. "

    ^self eventsTriggered includes: eventName asSymbol!
resourceFileClass
		"Answer the class of PARTS code generator resource files."
	self bindCodeGeneratorLibrary.
	^self classNamed: #PARTSResourceFile!  
displayBits: aPane
    bitPen := aPane pen.
    bitPen
        copyBitmap: copy
        from: copy boundingBox
        to: (0 @ 0 extent: copy extent * scale).
    self grid: scale!   
windowTitle
        " Private "
    ^fileName isNil
        ifTrue: ['Bit Editor']
        ifFalse: ['Bit Editor - ', fileName]!  
openOnPathName: aPathName
        "Open a catalog on the specified catalog file;
         if no workbench is open, open one first"

    | aFileName aDirectoryName |
    aFileName := aPathName fileNameLessPath.
    aDirectoryName := ( aFileName size = aPathName size
        ifTrue: [ Disk drivePathName ]
        ifFalse: [ aPathName copyFrom: 1 to: (aPathName size - aFileName size) ] ).
    ^self openOnFile: aFileName
        directory: ( Directory pathName: aDirectoryName )! 
write: anApplication on: aStream fileDescriptor: aFileDescriptor
        "Private - write anApplication on aStream.  aFileDescriptor
        is a kind of FileDescriptor."
    self partSetExecutionContextFor: [
        PARTSCodeGeneratorInterface codeGeneratorClass
            write: anApplication
            on: aStream
            fileDescriptor: aFileDescriptor ]!   
inputStream: aStream
            "Set the input stream that contains a PARTS application."
    [ partApplication := PARTSFile applicationFrom: aStream ]
        on: PARTSApplicationLoadError
        do: [ :e |
            e postMessageBox.
            partApplication := nil ].!  
createDragObjects: wrappers
    "<objectCollection> is a collection of raw objects
    that need to be stored in drag objects."
    | objectClass |

    objectClass := self objectClass.
    self objects:
        ( wrappers collect: [ :aWrapper |
            objectClass new
                object: aWrapper object;
                wrapper: aWrapper;
                session: self;
                yourself ]).!
COMMENT
    "Instances of PARTSExecutionRetriever are used to retrieve
    the the object set up as the execution context."!
addColorGroup: aGroupPane
        "Private - Add the pen and fill color window to aGroupPane. "
    | gap gapX height colorPaneHeight  valueSet |
    gap := SysFont height + 4.
    gapX := SysFont width.
    height := SysFont height + 8.
    colorPaneHeight  := 24 .
    self partsIfOS2Do: [
            aGroupPane addSubpane: (valueSet := (Smalltalk at: #ValueSet) new
                owner: self;
                setName: 'colors';
                rows: 4 columns: 4;
                when: #changedCoordinate:
                send: #colorSelected: to: self;
            framingBlock: [: box | ( box leftBottom rightAndUp: gapX @ 4 )
                extentFromLeftBottom: box width - ( 2 * gapX ) @ ( height * 3 ) ] ).
            self class colorDictionary associationsDo: [: assoc |
                valueSet
                colorItem: assoc value
                row: assoc key x
                column: assoc key y] ]
        partsIfWindowsDo: [
            aGroupPane addSubpane: (StaticText centered
                contents: 'Pen/Fill color';
                framingBlock: [: box |
                    (box leftBottom up: ( colorPaneHeight + 4 ))
                    extentFromLeftBottom: ( box width @ gap )]).
            aGroupPane addSubpane: (GroupPane new
                owner: self;
                setName: 'penColor';
                backColor: bitColor;
                framingBlock: [: box |
                    (box leftBottom rightAndUp: (gap @ 4))
                        extentFromLeftBottom: ( box width - ( 2 * gap) // 2 @ colorPaneHeight )]).
            aGroupPane addSubpane: (GroupPane new
                owner: self;
                setName: 'fillColor';
                backColor: fillColor;
                framingBlock: [: box |
                    (box leftBottom rightAndUp: ( box width // 2 + 2 @ 4 ))
                        extentFromLeftBottom: ( box width - ( 2 * gap) // 2 @ colorPaneHeight )]).
            ].!
startRect: aRect
    "Set the initial rectangle of the receiver during
    the drag session."

    startRect := aRect!
framingBlock: deltaLeftTop extent: extent
        " Private - answer the framing block for
        a window whose leftTop corner is deltaLeftTop
        from the upper left of the dialog window
        with extent. "

    ^[ :box |
        ( box leftTop rightAndDown: deltaLeftTop )
        extentFromLeftTop: extent ]!   
logMessage: aString
    self logStream nextPutAll: aString; cr!  
extendedDragButtonIndex
    "Private - answer the extended drag button index
    nil is used to symbolize a drag without button down.
    Answer an impossible button number"

    ^( self userDragButtonIndex = 1
        ifTrue: [ 2 ]
        ifFalse: [ 1 ])!  
mouseButtonPopupMenu: aSymbol
        " Specify the mouse button used for displaying a popup menu. "

    mouseButtonPopupMenu := aSymbol asSymbol.!   
objectClass
        "Answer the class of drag drop objects an
        instance of the receiver will contain."

    ^PARTSAddPartObject!   
editCopy
        "Private - Copy the bitmap to the clipboard."
    | bitmap |
    selection isNil ifTrue: [^self].
    self editMenu
        disableItem: #editCut;
        disableItem: #editCopy.
    "self hideSelection."
    bitmap := Bitmap screenExtent: selection extent.
    bitmap pen copyBitmap: copy
        from: selection
        at: 0 @ 0.
    Clipboard setBitmap: bitmap.!   
applyChanges
        "Private - Apply changes to the bitmap. Do not update
         file if one exist. File is updated by Save or Save as.."
    changeFlag := false.
    original extent = copy extent
        ifFalse: [
            original changeSize: copy extent.
            original pen blank: original boundingBox].
    original pen
        copyBitmap: copy
        from: copy boundingBox
        at: 0 @ 0.
    saveBlock notNil
        ifTrue: [saveBlock value].! 
openOn: aBitmap saveBlock: aBlock
        "Open a BitEditor on aBitmap."
    saveBlock := aBlock.
    self openOn: aBitmap!
fileInUpgradeLoaded: anObjectFiler
       " Private - finish loading an upgraded PW 2.0 application.
       Install application-wide changes here.  This is done
       at the end of the loading cycle so that any of the
       application's component parts which need to mutate
       during their own upgrade have finished fixing themselves. "

    self components do: [ :aPart |
        ( aPart isKindOf: Window )  " isWindow is tricky for shrunken parts "
            ifTrue: [

                " visual parts maintain wrapper linkage in properties
                      since PWW 2.0; fix PWO 2.0 app accordingly "
				self partsIfOS2Do: [
               		aPart partWrapper: ( self findWrapper: aPart ).
					].

				aPart partFileInUpgradeLoaded: anObjectFiler.

				].
		].
	self partsIfOS2Do: [ self partUpgradeTabInfoOS2: anObjectFiler ].!  
optionsMenu
        " Private - answer the current Options menu. "
    ^self menuTitled: self optionsMenuTitle! 
mouseButtonPopupMenu
        " Answer the mouse button used for displaying a popup menu. "

    ^mouseButtonPopupMenu! 
changeBitAt: aPoint
        "Private - Change the bit at aPoint."
        " Platform dependent "
    | scaledPoint imagePoint penWidth |
    (self isInGrid: aPoint) ifFalse: [^self].
    changeFlag := true.
    imagePoint := aPoint // scale.
    scaledPoint := imagePoint * scale.
    penWidth := 1.  " VW"   "VOS: bitPen lineWidth"
    grid
        ifTrue: [
            bitPen fill: ((scaledPoint + 1) extent: (scale @ scale * penWidth) - 1)
               color: bitColor.
            "penWidth > 1 ifTrue: [
                bitPen execute: [self grid: scale] clipRect: (scaledPoint extent:
                    (scale @ scale * penWidth))]"]
        ifFalse: [
            bitPen fill: (scaledPoint extent: (scale @ scale * penWidth))
                color: bitColor].

    imagePen
        fill: (imagePoint extent: penWidth @ penWidth)
        color: bitColor.
    copy pen
        fill: (imagePoint extent: penWidth @ penWidth)
        color: bitColor!   
colorCatalog
        " Answer the background color for the PARTS catalog. "

    ^colorCatalog!
write: aPARTSApplication on: aStream
        "Write the source code for aPARTSApplication on aStream."
    self new write: aPARTSApplication on: aStream!   
colorLinkLabel
        " Answer the background color for link labels. "

    ^colorLinkLabel!  
defaultFileExtension
        " Private "
    ^'bmp'!
writeDirectory
            "Read all the files .PAR files in the input directory.
            Store the resulting source code files in the output directory.
            Both an input and an output directory must
            have been previously specified."
    | filenames |
    self inputDirectory valid ifFalse: [
        self logMessage: 'ERROR:  Input directory is not valid.'.
        ^self ].
    self outputDirectory valid ifFalse: [
        self logMessage: 'ERROR:  Output directory is not valid.'.
        ^self ].
    filenames := SortedCollection new.
    ( self inputDirectory formatted: '*.par' ) do: [ :a | filenames add: a first ].
    self writeDirectoryFiles: filenames!
outputStream: aStream
            "Set the output stream to receive the source
            code representation."
    outputStream := aStream!  
restoreOriginal
        "Private - Restore the original image."
    copy release.
    copy := Bitmap screenExtent: copy extent.
    copy pen
        copyBitmap: original
        from: original boundingBox
        at: 0 @ 0.
    self displayBits: bitPen graphicsMedium.
    self displayImage: imagePen graphicsMedium! 
initImagePen: aPane

    imagePen := aPane pen.
    imagePen foreColor: bitColor.
    imagePen execute: [ self displayImage: aPane ] clipRect:  (0 @ 0 extent: copy extent).! 
targetEnter
        "Private - the mouse entered the bounds of the
        current target during a drag drop transfer."

    super targetEnter.
    cursor isNil
        ifTrue: [
            "Special case. targetEnter for the first time sets
        a nil operation which results in an invalid cursor.  Set an
        operation so that the move starts with a valid cursor."
            self operation: #initialize ]!
offset
    ^0 @ 0!   
sourceHandle
    "Answer the handle of the window that initiated the
    drag drop session."

    ^source handle! 
topPaneClass
        "Private - Answer the default top pane class."

    ^PARTSDialogTopPane!  
fileOpen
        "Open the File Dialog to let the user open a file."
    | aPathName |
    self changesHandled ifFalse: [^nil].
    aPathName := (FileDialog new
        openFile: '*.', self defaultFileExtension)
            file.
    aPathName isNil ifTrue: [^self].
    fileName := aPathName.
    changeFlag := false.
    self
        fromFile: fileName;
        setWindowTitle.!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object. 
        PWO 2.0 ScaledRectangle becomes a framer in 3.0 "

    | loadContext newRect leftStretched bottomStretched 
      widthStretched heightStretched |

    ( ( loadContext := anObjectFiler clientContext ) isPARTSLoadContext
    and: [ loadContext fileVersion = 'LAF/VPM 2.0a'] )
        ifFalse: [ ^self ].

    leftStretched := (mask at: 1) = 0.
    bottomStretched := (mask at: 2) = 0.
    widthStretched := (mask at: 3) = 0.
    heightStretched := (mask at: 4) = 0.

    newRect := Rectangle new
		leftTop: self scaledRectangleLeftTop;
		rightBottom: self scaledRectangleRightBottom;
		yourself.
    self
		setDefaultAttributes;
        left: 
				(leftStretched 
					ifTrue: [newRect left] 
					ifFalse: [ self pixelToScaleUnitHorizontal: newRect left ])
					stretched: leftStretched
        width: 
				(widthStretched 
					ifTrue: [newRect width] 
					ifFalse: [self pixelToScaleUnitHorizontal: newRect width]) 
					stretched: widthStretched;
        bottom: 
				(bottomStretched 
					ifTrue: [newRect bottom] 
					ifFalse: [self pixelToScaleUnitVertical: newRect bottom]) 
					stretched: bottomStretched
		height: 
			(heightStretched 
				ifTrue: [newRect height] 
				ifFalse: [self pixelToScaleUnitVertical: newRect height]) 
				stretched: heightStretched.!  
optionsPenSizeMenuTitle
        "Private - answer the title of pen size menu."
    ^PARTSStandardMenu mnemonic, 'Pen size'! 
partWrapper: aWrapper
        " Identify the part which owns the bits being edited. "
    partWrapper := aWrapper.! 
fileType
    "Answer the file type processed by the instance
    of the receiver."

    ^ Array with: PARTSFileDescriptor fileTypeForSource!  
validCursor
    "Answer the valid drop target cursor."

    validCursor isNil
        ifTrue: [ self initCursors ].
    ^validCursor!
extentForEntryField: nChars
        " Private - answer dimensions to contain nChars "

    | charWidth x y |
    self font = SysFont
        ifTrue: [
            ^( nChars * WindowDialog charWidth )
            @ WindowDialog entryHeight ]
        ifFalse: [
            charWidth := self font width.  " points "
            x := ( nChars + 1 ) * charWidth.
            y := self font height // 2.
            ^( self class widthInDialogUnits: x )
            @ ( self class heightInDialogUnits: y )
            ].!
contents: anObject
        "Set the contents of the receiver."
    contents := anObject!
cancel
        " Private - the Cancel button has been pressed. "

    self close.! 
optionsChangeSize
    | newExt |
    newExt := PARTSExtentEditor new
        openOn: copy extent
         title: 'New Bitmap Size'.
    (newExt notNil and: [newExt ~= copy extent])
        ifTrue: [
            copy changeSize: newExt.
            scale := ((260 // copy extent x) min: (274 // copy extent y)) max: 4.
            bitPen erase.
            self initBitPen: bitPen graphicsMedium.
            imagePen erase.
            self initImagePen: imagePen graphicsMedium.
            changeFlag := true].!
current: aSettings
        " Private - set the current settings to an instance of the receiver. "

    CurrentSettings := aSettings.!  
inputDirectory
        "Answer the receiver's input directory."
    ^Directory pathName: inputDirectoryName!
open
        "Open a PARTSIconEditor on a new Icon."

    self openOn: PARTSIcon transparent.! 
labelFont
        " Answer the link label font. "

    ^labelFont! 
update
    "Private - Redisplay the receiver window.
    Override GraphPane implementation."

    self triggerEvent: #needsContents
		ifNotHandled: [ self refresh ]!
sourceNeedsObject
        "Private - retrieve the drag drop object from the
        drag source.  In most cases, objects will be assigned
        during the instantiation of the receiver."

	^self objects isNil
		ifTrue: [ super sourceNeedsObject ]
		ifFalse: [ self ]!  
evaluateContents
        "Compile and evaluate the contents of the receiver
        in the context of nil class."
    ^self evaluateIn: nil class! 
editorClass: aClass
        " Private - set the private editor class. "

	EditorClass := aClass.!  
referenceClass
		"Answer the class of PARTS code generator references."

	^self classNamed: #PARTSCodeGeneratorReference!  
objectClass
        "Answer the class of drag drop objects an
        instance of the receiver will contain."

    ^PARTSLocalDragDropObject! 
surfaceWarningsForPathName: aPathName
        " Private - bring the warning message log to the top. "

    self warningWindows do: [ :w |
        ( Directory pathName: ( w propertyAt: #partsWarningLog ) )
                = ( Directory pathName: aPathName )
            ifTrue: [ w bringToTop ] ].!   
updateBackgroundColors: settings
        " Reset the receiver's background color properties to the
        values in <settings>. "

    ( self equalBackgroundColors: settings )
        ifTrue: [ ^self ].
    CursorManager execute changeFor: [
        self
            colorWorkbench: settings colorWorkbench;
            colorCatalog: settings colorCatalog;
            colorLinkLabel: settings colorLinkLabel;
            writeSettingsFile ].!   
operationDescriptions
        "Private - answer a map between known operation names
        ('move', 'copy', 'link') and their names as they should appear in
        a UI."

    ^super operationDescriptions
        at: #move put: 'Move';
        at: #copy put: 'Copy';
        yourself.!   
editMenuFillItem: editMenu
        " Private - append the Fill command item to editMenu. "
    editMenu
        appendItem: editMenu class mnemonic, 'Fill    Ctrl+F'
        selector: #fill
        accelKey: $f
        accelBits: editMenu class controlCharAccelerator.!   
okToClose
        " Answer whether it is ok to close this editor.
        Allow user to saved or discard any changes. "
    ^self changesHandled!  
resetCopy
        " Private "
    self resetCopy: ( Bitmap screenExtent: copy extent )! 
surfaceWarningsForFile: aFileName
        " Private - bring the warning message log to the top. "

    self warningWindows do: [ :w |
        ( w propertyAt: #partsWarningLog ) fileNameLessPath = aFileName
            ifTrue: [ w bringToTop ] ].!   
COMMENT
"
PARTSLinkSettings is a private class belonging
to the link rendering subsystem.
"!  
initialize
    selectedIcons := OrderedCollection new.
    ^super initialize!   
mightReplace
    "Private - Answer whether the receiver could replace the
    target with the drag object."

    ^self objects size = 1!  
showHints
        " Answer the default hints setting for the PARTS workbench. "

    ^showHints!   
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it.  Do nothing,
        answer self."!   
editorPane
    "Answer the editor pane where the receiver was
    initiated."
    ^nil!
grid: anInteger
        "Draw grid lines with anInteger spacing
         on the receiver medium."
    | i width height penWidth |
    grid ifFalse: [^self].
    width := copy width * scale.
    height := copy height * scale.
    penWidth := bitPen lineWidth.
    bitPen foreColor: PARTSHostInterface colorBackground;
        setLineWidth: 1;
        foreColor: PARTSHostInterface colorDefault.
    i := 0.
    [i < width]
        whileTrue: [
            bitPen place: i @ 0;
                goto: i @ height.
            i := i + anInteger].
    i := 0.
    [i < height]
        whileTrue: [
            bitPen place: 0 @ i;
                goto: width @ i.
            i := i + anInteger].
    bitPen setLineWidth: penWidth;
        foreColor: bitColor!   
supportsExtendedOperations
    "Private - Answer whether the user can
    invoke extended opeartions for the receiver"
    ^false! 
dragRect
    "Answer the rectangle of the object described by the
    receiver as it is dragged across the workbench."

    ^dragRect!
colorUndefinedBaseLink: aColor
        " Specify the color for a base link which isn't fully defined. "

    colorUndefinedBaseLink := aColor! 
openOn: aPoint title: aString
        " Open the dialog on the given x @ y values.  Answer the new value. "
    title := aString.
    ^super openOn: aPoint!   
dragStart: anEditorPanePoint
    "Set the editor pane coordinate where the receiver
    was initiated."

    dragStart := anEditorPanePoint!  
write: aPARTSApplication on: aStream
        "Write aPARTSApplication as source code
        on aStream."
    self partSetExecutionContextFor: [
        PARTSCodeGeneratorInterface codeGeneratorClass
            write: aPARTSApplication
            on: aStream ]! 
supportsExtendedOperations
    "Private - Answer whether the user can
    invoke extended opeartions for the receiver"

    ^true!
visibleParent
	"Answer the parent of the visible object of the receiver"

	^object isPARTSIcon
		ifTrue: [ object parent ]
		ifFalse: [ object superWindow ]!
messageExpressionModel
    ^self classNamed: #CodeGenerationMessageExpression!   
button1DoubleClick: aPoint
        "Private - "

    self openItemAt: aPoint.! 
targetDrop
        "Private - the dragged object was dropped over the current
        target at the current location."
    self target partDragTargetDrop: self!   
defaultFontDialogs
        " Answer the default font to use in a PARTS dialog. "
	^PARTSHostInterface defaultPartFont.
  ! 
initializeMouseButtons
        " Set the button use to the platform default. "

    self 
        partsIfOS2Do: [ ^self initializeMouseButtonsOS2 ]
        partsIfWindowsDo: [ ^self initializeMouseButtonsWindows ].
    self error: 'unknown platform'!  
icon: anIcon
    "Set the icon to be used as the cursor of the receiver"
    icon := anIcon!
mainObject
        "Answer the object associated with the receiver."

    | obj |

    ( obj := object isPARTSIcon
        ifTrue: [ object mainObject ]
        ifFalse: [ object ]) isNil
            ifTrue: [
                "If the mainObject is nil, answer 'object'.   This will
                cause a catalog icon connection to load its application"
                obj := self object ].
    ^obj!
displaySelection
        "Private - Display the selected rectangle."
    selection isNil ifTrue: [^self].
    bitPen place: selection leftTop * scale;
        box: selection rightBottom * scale!
initWindowSize
        "Private - Answer the initial window extent."
    | size |
    size := (Display boundingBox leftTop rightAndDown: 10 @ 10).
    size :=  size extentFromLeftTop: windowSize .
    ^size!  
initCursors
    "Set the cursors for the receiver's feedback."

    validCursor := CursorManager normal.
    invalidCursor := CursorManager dragDropNone.!
referenceFor: anObject
        "Answer a PARTS code generator reference for anObject."
    | referenceClass |
    referenceClass := self referenceClass.
    ^referenceClass for: anObject!   
inputPathName: inPathName outputPathName: outPathName
        "Read the part contained in the file specified by inPathName
        and write the source code representation of it to a file
        named outPathName."
    ^self new
        inputPathName: inPathName;
        outputPathName: outPathName;
        writeSourceCode! 
isReplaceOperation
    "Answer whether the receiver should
     replace the target with the drag object"
    ^self operation = #replace!   
resetCopy
        " Private "!   
createViewFor: aBitmap clipRect: aRect
        " Private - create an bitmap editor window for aBitmap.
        Answer the window. "
        " Platform dependent - ValueSet is only available on VOS "
    | imageSize gap topPane aGraphPane aGroupPane |

    imageSize := 260 @ 274.
    scale := ((imageSize x // aBitmap width) min: (imageSize y //
        aBitmap height)) max: 4.
    gap := SysFont width.

    copy := aBitmap clone.

    self addView:
        ((topPane := self topPaneClass new)
            owner: self;
            labelWithoutPrefix: self windowTitle;
            icon: PARTSEditor editorClass workbenchIcon;
            windowPolicy: NoMenusWindowPolicy new;
            when: #menuBarBuilt send: #createMenuBarMenus: to: self with: topPane;
            when: #activated send: #activated to: self;
            when: #aboutToClose send: #aboutToClose: to: self with: topPane ;
            when: #closed send: #releaseCopy to: self ).
    partWrapper notNil
        ifTrue: [
            topPane
                controller: partWrapper partEditor
                controllee: self].

    self addSubpane: (
        (aGraphPane := GraphPane new)
            owner: self;
            removeHorizontalScrollbarStyle;
            removeVerticalScrollbarStyle;
            when: #display
                send: #displayImage: to: self with: aGraphPane;
            framingBlock: [: box |
                box leftBottom extentFromLeftBottom: (
                    box width * 2 // 7 @ (box height // 3))] ).

    self addSubpane:
        (aGroupPane := GroupPane new
            framingBlock: [: box |
                box leftTop extentFromLeftTop: (
                    box width * 2 // 7 @ (box height * 2 // 3))] ).

    self addButtonGroup: aGroupPane.
    self addColorGroup: aGroupPane.

    self addSubpane:
        ((aGraphPane := GraphPane new)
            owner: self;
            removeHorizontalScrollbarStyle;
            removeVerticalScrollbarStyle;
            when: #display
                send: #displayBits: to: self with: aGraphPane;
            when: #button1Down
                send: #changeBit: to: self with: aGraphPane;
            when: #button1Moved
                send: #changeBit: to: self with: aGraphPane;
            framingBlock: [: box |
                (box leftTop rightAndDown: (box width * 2 // 7 @ 0))
                    rightBottom: box rightBottom] ).

    windowSize := 130 + imageSize x + 2 @
        (( 320 max: imageSize y) + SysFont height + 6).
    ^topPane !
ok
        " Private - the OK button has been pressed. "

    self close.! 
catalogConnectionClass: aClass
        " Private "

    CatalogConnectionClass := aClass.! 
convertRectFromDeviceToWorld: aRect
        " Private - platform dependent.  This method needs to convert aRect
         from device to world coordinates. Since the receiver is not scrollable
         just answer aRect."
    "VOS:
    ^self convertRect: aRect from: CvtcDevice to: CvtcWorld
    "
    ^aRect   " VW "!  
isDragButton: anInteger
    ^true!   
fileSave
        "The user selected save from the file menu. If the bitmap
         was opened from a file, save the changes to the file."

    fileName isNil 
		ifTrue: [ ^self fileSaveAs ].
    CursorManager execute 
		changeFor: [ self accept ].!  
yItemLabel
        " Private "
    self implementedBySubclass!  
initializeCurrentClass
		" Private - set the current platform class "

    self currentClass:
        ( Smalltalk at: ( self
            partsIfOS2Do: [ #PARTSIconEditorOS2 ]
            partsIfWindowsDo: [ #PARTSIconEditorWindows ] ) ).!  
loadFrom: readStream context: loadContext
        "Private - compile and evaluate the source code
        in readStream to produce a PARTSApplication.
        Answer the PARTSApplication."

    | application |
    [ CursorManager execute
        changeFor: [
            application := PARTSCodeGeneratorReaderInterface
            applicationFrom: readStream
            fileDescriptor: self fileDescriptor ]]
        ensure: [ readStream close ].
    application isNil
        ifTrue: [
            PARTSInvalidApplication
                signal: 'Invalid source file format'
                file: self fileDescriptor ].
    ^application! 
openOnFile: aFileName
        "Open a catalog on the specified catalog file;
         if no workbench is open, open one first"

    | aDirectory |
    ( aDirectory := PARTSFile directoryContaining: aFileName ) isNil
        ifTrue: [ ^nil ].
    ^self openOnFile: aFileName directory: aDirectory!   
logWindowLabel
        "Private - answer the label for the receiver's log window."
    ^'PARTS Code Generator Reader Messages  ', PARTSTimeStamp current printString!   
colorWorkbench
        " Answer the background color for the PARTS editor. "

    ^colorWorkbench! 
resourceFile
        "Private - answer a special resource file if the receiver's
        file descriptor is repository based."

    | resourceFileClass resourceFileDescriptor |
    ^( fileDescriptor notNil and: [
        fileDescriptor isPARTSTeamVFileDescriptor ] )
            ifTrue: [
                resourceFileClass := self class resourceFileClass.
                resourceFileDescriptor := fileDescriptor getCopyWithExtension: resourceFileClass fileExtension.
                resourceFileClass new stream: ( resourceFileDescriptor asReadStream ) ]
            ifFalse: [ nil ]!  
titleBarWidth: aString
        " Private - answer the width of a titleBar containing
        a system menu and aString (dialog box units). "

    | charWidth width |
    charWidth := WindowDialog charWidth.  " dialog units "
    width := ( self font = SysFont
        ifTrue: [
            aString size * charWidth ]
        ifFalse: [
            self class widthInDialogUnits:
                ( self font stringWidth: aString ) ] ).
    ^width + ( 4 * WindowDialog charWidth )   " approximate sysMenu width "!   
activeEditors
        " Answer all the active PARTS editors "

    ^self activeEditorWindows
            collect: [ :window | window owner ]! 
defaultFileExtension
        " Private "
    ^'ico'!
mouseButtonDrag
        " Private - answer the mouse button to use for dragging. "

    ^self
        partsIfOS2Do: [ PARTSHostInterface dragButtonOS2 ]
        partsIfWindowsDo: [ PARTSSettings current mouseButtonDrag ]!
fontDialogs: aFont
        " Specify the font to use for workbench dialogs. "

    fontDialogs := aFont.!  
editPaste
        "Private - Paste a bitmap from the clipboard."
    | bitmap newRect |
    "selection isNil ifTrue: [^self]."
    changeFlag := true.
    bitmap := Clipboard getBitmap.
    bitmap isNil ifTrue: [^self].
    newRect := self trackRect: bitmap boundingBox.
    copy pen copyBitmap: bitmap
        from: bitmap boundingBox
        to: newRect.
    self displayBits: bitPen graphicsMedium;
        displayImage: imagePen graphicsMedium!  
targetDrop
        "Private - the dragged object was dropped over the current
        target at the current location."
    | icon  |

    self isReplaceOperation
        ifTrue: [
            "If dropping on the editor pane, check if target is actually a non-visual part"
            ( self target isPARTSEditorPane
                and: [ ( icon := self target iconAt: self targetLocation ) notNil ])
                ifTrue: [ self target: icon ].
            self screenLocation:
                ( self target frameRectangle topLeft rightAndDown: self hotSpotOffset )].

    super targetDrop!   
classModel
    ^self classNamed: #CodeGenerationClass!   
createMenuBarMenus: topPane
        " Private - build the menu bar "
    topPane menuWindow
        addMenu: self fileMenuCreate;
        addMenu: self editMenuCreate;
        addMenu: self optionsMenuCreate.!
startUp
        " Session startUp event handler "

    self current 
        initializeFonts;
        loadSettings.! 
fileNew
    self changesHandled ifFalse: [^nil].
    self
        resetCopy;
        clear.
    fileName := nil.
    changeFlag := false.
    self setWindowTitle.!
icon
    "Answer the PARTSIcon associated with the receiver"

    ^object isPARTSIcon
        ifTrue: [ object ]
        ifFalse: [ nil ]!   
windowTitle
        " Private "
    ^fileName isNil
        ifTrue: ['Icon Editor']
        ifFalse: ['Icon Editor - ', fileName]!
isPARTSEditorMoveSession
    "Answer whether the drag drop session
    is an instance of the receiver"

    ^true!
partMessages
        " Private - answer the PARTS message interface of the receiver. "

    ^PARTSInterfaceList new items: #(
        #colorDictionary
        #colorUndefinedArgLink #colorUndefinedArgLink:
        #colorUndefinedBaseLink #colorUndefinedBaseLink:
        #colorWellDefinedArgLink #colorWellDefinedArgLink:
        #colorWellDefinedBaseLink #colorWellDefinedBaseLink:
        #colorWorkbench #colorWorkbench:
        #colorCatalog #colorCatalog:
        #colorLinkLabel #colorLinkLabel:
        #mouseButtonDrag #mouseButtonDrag:
        #mouseButtonLink #mouseButtonLink:
        #mouseButtonSelect #mouseButtonSelect:
        #mouseButtonPopupMenu #mouseButtonPopupMenu:
        #button1Drag #button1Select
        #setButton1Drag #setButton1Select
        #setButton1Link #setButton1PopupMenu
        #updateBackgroundColors: #updateLinkColors: #updateMouseButtons:
        #userName #userName:)!
componentReferenceClass
        "Answer the class of PARTS code generator references to
        component parts."

    ^self classNamed: #PARTSCodeGeneratorComponentReference!   
setButton1PopupMenu
        " Private - make button1 be the menu popup button. "

    self
        mouseButtonPopupMenu: #button1;
        mouseButtonSelect: #button2.! 
editCut
        "Private - Cut a portion of the bitmap to the clipboard.
         Fill the cut portion with the bitmap background color."
    | bitmap |
    selection isNil ifTrue: [^self].
    self editMenu
        disableItem: #editCut;
        disableItem: #editCopy.
    "self hideSelection."
    bitmap := Bitmap screenExtent: selection extent.
    bitmap pen copyBitmap: copy
        from: selection
        at: 0 @ 0.
    Clipboard setBitmap: bitmap.
    copy pen fill: selection
        color: copy pen backColor.
    self displayBits: bitPen graphicsMedium;
        displayImage: imagePen graphicsMedium!
optionsTest
        "Private - Test icon as cursor."
    | pointer |
    ( pointer := icon asPointer ) changeFor: [
        Notifier consumeInputUntil: [: event |
            event selector = #button1Up: ] ].
    CursorManager normal change.
    pointer release! 
writeDirectoryFiles: aCollectionOfFileNames
            "Read all the files specified by the input
            directory and aCollectionOfFileNames.  Store
            the resulting .CLS files in the output directory.
            Both an input and an output directory must
            have been previously specified."
    | indir outdir app outStream errorMessage outFilename |
    indir := self inputDirectory.
    outdir := self outputDirectory.
    self logMessage: 'Generating code for directory - ', TimeStamp current printString.
    self logMessage: '    Input (.PAR) directory: ', inputDirectoryName asUpperCase.
    self logMessage: '    Output (.CLS & .CRS) directory: ', outputDirectoryName asUpperCase.
    aCollectionOfFileNames do: [ :inFilename |
        [ app := PARTSFile applicationFromFile: inFilename in: indir ]
            on: Error
            do: [ :e |
                errorMessage := e messageText.
                app := nil ].
        app isNil
            ifTrue: [
                self logMessage: errorMessage ]
            ifFalse: [
                self logMessage: '        ', inFilename, ' -> ', app name, ' -> ', inFilename fileName, '.CLS'.
                [ outFilename := inFilename fileName, '.cls'.
                    outStream := File newFile: outFilename in: outdir.
                    PARTSCodeGeneratorInterface codeGeneratorClass
                        write: app
                        on: outStream.
                    outStream close ]
                            on: Error
                                do: [ :e |
                                    errorMessage := e class == MessageNotUnderstood
                                        ifTrue: [ e message receiver class name, ' does not understand #',
                                            e message selector ]
                                        ifFalse: [ e description ].
                                    self logMessage: '                ', inFilename, ' failed: ', errorMessage.
                                    [ outStream close ] on: Error do: [ "nothing" ]]]].
    self logMessage: ' - done - ', PARTSTimeStamp current printString!
operationDescriptions
        "Private - answer a map between known operation names
        ('move', 'copy', 'link') and their names as they should appear in
        a UI."

    ^IdentityDictionary new
        at:  ( #repeat, self mainOperation first ) asSymbol
            put: ( 'Repeat ', self mainOperation last );
        at: #replace put: 'Replace';
        at: self mainOperation first put: self mainOperation last;
        yourself.!   
minBox: aRectangle
        "Private - Set the minimum bounding box of the drag objects."
    minBox := aRectangle!  
codeGeneratorReaderClass
        "Private - answer the code generator reader class."

    ^self classNamed: #PARTSCodeGeneratorReader! 
applicationFrom: aStream
            "Compile the code in aStream.  Answer a PARTS application.
            Remove the resulting class after the application has been
            built."
    ^self readStream: aStream!  
upgradeSelectorFrom: oldSelector to: newSelector
        " Private - install a protocol upgrade. "

    oldSelector = selector
        ifTrue: [ selector := newSelector ]
        ifFalse: [ realSelector := newSelector ].!
colorDictionary
        " Private - answer the dictionary of colors supported
        for PARTS settings.  Key is name, value
        is the color constant. "

    ^PARTSIniFile colorDictionary!   
evaluateIn: aClass
        "Compile and evaluate the contents of the receiver
        in the context of aClass.  Answer nil if compilation fails."
    ^CompilerInterface
        evaluate: self contents "trimBlanks"
        in: aClass
        to: nil
        notifying: self
        ifFail: [^PARTSException new]!  
releaseCopy
        " Private - the window has closed. "
    andMask release.
    xorMask release.
    copy release.! 
readStream: aStream
            "Compile the code in aStream.  Answer a PARTS application.
            Remove the resulting class after the application has been
            built."
    ^self readStream: aStream removeClass: true! 
getMoveTargetAt: aScreenPoint editorPane: anEditorPane
        "When moving a part we need to look for group box also."

    ^anEditorPane windowUnderPoint:
        ( aScreenPoint mapToWindow: anEditorPane )!  
defaultScaleUnit
    "Private - Answer the default scale unit used by icons
    and links on the workbench"

    ^PARTSFramer defaultScaleUnit!   
setButton1Drag
        " Set button1 to move/resize and button2 for create link. "

    self
        mouseButtonDrag: #button1;
        mouseButtonLink: #button2.!  
extendedDragButtonIndex
	"Private - answer the extended drag button index
	nil is used to symbolize a drag without button down.
	Answer an impossible button number"

	^4!   
COMMENT
	"This class has class methods to refer to all the public code generation
	classes.  The main reason for this is to enable add on libraries to
	refer to these classes so they can be code generator aware without
	directly referencing the class.  If they directly referenced the class,
	the add on libraries could not bind unless the code generator classes
	were bound.  This class (PARTSCodeGeneratorInterface) will be in a
	base PARTS Workbench library, always available to be referenced.

	There are methods to refer to code generator expression classes and 
	code generator reference classes:

	Expression classes:
		expressionClass
		creationExpressionClass
		resourceExpressionClass
	Reference classes:
		referenceClass
		entryPointReferenceClass
		poolVariableReferenceClass

	- end - "! 
dragButtonIndex
        "Private - answer the drag button index,
        or nil if not supported."

    ^nil! 
COMMENT
"
PARTSCatalog provides the public protocol for opening
a PARTS Workbench window.
"!  
currentClass: aSubclass
        " Private "

    CurrentClass := aSubclass.!   
showLinksWithSelection
        " Answer the default showLinksWithSelection setting
        for the PARTS workbench. "

    ^showLinksWithSelection!   
dragButtonIndex
        "Private - answer the drag button index,
        or nil if not supported."

    ^self userDragButtonIndex!
optionsMenuCreate
        "Private - Answer a new Options menu"
    | mnemonic tabString controlCharAccelerator optionsMenu |
    mnemonic := PARTSStandardMenu mnemonic.
    tabString := PARTSStandardMenu tabString.
    controlCharAccelerator := PARTSStandardMenu controlCharAccelerator.
    optionsMenu := (PARTSStandardMenu for: self titled: self optionsMenuTitle)
        appendItem: mnemonic, 'Grid', tabString, 'Ctrl+G'
            selector: #optionsGrid
            accelKey: $g
            accelBits: controlCharAccelerator;
        appendItem: mnemonic, 'Test', tabString, 'Ctrl+T'
            selector: #optionsTest
            accelKey: $t
            accelBits: controlCharAccelerator;
           yourself.
    self partsIfWindowsDo: [optionsMenu
        appendItem: 'Change ', mnemonic, 'color..', tabString, 'Ctrl+L'
            selector: #optionsChangeColor
            accelKey: $l
            accelBits: controlCharAccelerator ].
    optionsMenu checkItem: #optionsGrid.
    ^optionsMenu!
defaultCatalogs
        " Answer the default list of catalogs to open for a workbench. "

    ^#( 'PARTS.CAT' )!   
isFromLocalImage
        "Answer whether the receiver originated from a window
        in this Smalltalk image."
    ^true!
equalBackgroundColors: settings
        " Answer whether the receiver has the same
        background color settings as <settings>. "

    ^( colorWorkbench = settings colorWorkbench
    and: [ colorCatalog = settings colorCatalog
    and: [ colorLinkLabel = settings colorLinkLabel ] ] )!   
currentDragHandler
        " Private - answer the current drag handler. "

    ^CurrentDragHandler!
colorUndefinedArgLink: aColor
        " Specify the color for an argument link which isn't fully defined. "

    colorUndefinedArgLink := aColor!  
readPathName: aPathName removeClass: aBoolean
            "Compile the code in the file specified by aPathName.
            Answer a PARTS application.  Remove the resulting class
            if aBoolean is true."
    | stream answer |
    stream := ( File fromPath: aPathName ) readStream.
    answer := self readStream: stream removeClass: aBoolean.
    stream close.
    ^answer!
isAvailable
        "Private - answer whether the receiver can be used in the current
        environment.  The receiver can only be used if Smalltalk development
        tools are available."
    ^PARTSSessionManager isWorkbenchStandaloneSession not!   
activeEditorWindows
        " Answer all the active main windows of PARTS editors. "
    | editorClass |
    editorClass := self editorClass.
    ^Notifier mainWindowsSelect: [ :window |
        window owner class == editorClass ]!  
penSize: anInteger
        "Private - Set the receiver's pen size to anInteger."
    self optionsPenSizeMenu
        uncheckItem: bitPen lineWidth;
        checkItem: anInteger.
    bitPen setLineWidth: anInteger.
    imagePen setLineWidth: anInteger.
    copy pen setLineWidth: anInteger!  
visibleObject
	"Answer the object visible on the workbench"

	^object! 
editorPane
    ^editorPane!  
destinationWindow
    ^destinationWindow!
isResumable
        "Answer whether the receiver is resumable."
    ^isResumable isNil
        ifTrue: [ true ]
        ifFalse: [ isResumable ]! 
registerClass: aClassName inLibrary: aLibraryName
        "Register a class named aClassName as being in the Smalltalk library
        named aLibraryName.  If this class is referenced (by the expression
        'CodeGenerationPrivateServices classNamed: aSymbol') and the
        class is not currently in the image then the Smalltalk library named
        aLibraryName will be bound."
    libraryMap isNil ifTrue: [ libraryMap := Dictionary new ].
    libraryMap at: aClassName put: aLibraryName!  
COMMENT
"
PARTSSettings contains the workbench environment
user settings.  The current settings can be obtained
by sending the message:

    PARTSSettings current

To force settings to be reloaded after image startup:
    PARTSSettings current loadSettings

To update the PARTS.INI file:
    PARTSSettings current writeSettingsFile
"!   
createDragObjects: objectCollection
    "<objectCollection> is a collection of raw objects
    that need to be stored in drag objects."
    | editor frameRect objectClass visibleObject parent |

    editor := self editorPane partEditor.
    objectClass := self objectClass.
    self objects:
        ( objectCollection collect: [ :each |
            visibleObject := editor getVisibleObjectOf: each.

            "Detect for an illegal drag selection"
            parent isNil
                ifTrue: [ parent := visibleObject superWindow ]
                ifFalse: [
                    parent ~~ visibleObject superWindow
                        ifTrue: [
                            MessageBox notify: 'Illegal Drag Operation'
                                withText: 'Selections must have the same parent'.
                        ^self objects: nil ]].

            frameRect := visibleObject frameRectangle.
            objectClass new
                object: visibleObject;
                session: self;
                dragRect: frameRect;
                startRect: ( frameRect mapToWindow: self editorPane );
                yourself ]).! 
fromFile: aFileName
        "Private - Answer an icon from aFileName icon file."
    | newIcon |
    newIcon := PARTSIcon fromFile: aFileName.
    newIcon isIcon ifFalse: [^nil].
    self releaseCopy.
    self createMasks: newIcon.
    self displayImage: imagePen graphicsMedium.
    self displayBits: bitPen graphicsMedium.
    newIcon release!
mightReplace
    "Answer whether the receiver could
     replace the target with the drag object"
    ^false!  
generatedClassSuperclass
        "Private - answer the super class of classes produced from
        generated code."

    ^self classNamed:  #PARTSApplicationGenerator!  
readPathName: aPathName
            "Compile the code in the file specified by aPathName.
            Answer a PARTS application.  Remove the resulting class
            after the application has been built."
    ^self readPathName: aPathName removeClass: true! 
title
        " Private "
    ^title!   
fontIconLabels: aFont
        " Specify the font to use for icon labels in a workbench. "

    fontIconLabels := aFont.!   
initializeColorDictionary: colors
        "Private - Initialize the color dictionary. Used to get color
         from selected item in value set."

    | index colorDict |
    index := 0.
	colorDict := Dictionary new.
    1 to: 4 do: [: row |
        1 to: 4 do: [: col |
            index := index + 1.
            colorDict at: (row @ col) put: (colors at: index)]].
	self colorDictionary: colorDict.!
activeCatalogs
        " Answer all the active PARTS catalogs. "

    ^self activeCatalogWindows
            collect: [ :each | each owner ]! 
interactive
        "Private - answer whether the receiver is interactive.
        If it is interactive is may prompt the user for input."
    ^interactive isNil
        ifTrue: [ false ]
        ifFalse: [ interactive ]!
isPARTSPasteSession
    "Answer whether the drag drop session
    is an instance of the receiver"

    ^true! 
simpleOutput
    ^self classNamed: #CodeGeneratorSimpleOutput!   
selfPrimaryModel
    ^self classNamed: #CodeGenerationSelfPrimary!   
defaultScaleUnit: aScaleUnit
    "Private - Set the default scale unit used by icons
    and links on the workbench. "

    PARTSFramer defaultScaleUnit: aScaleUnit
!   
openOn: aPoint
        " Open the dialog on the given x @ y values.  Answer the new value. "
    point := aPoint.
    self createView.
    point := nil.
    self openWindow.
    ^point!   
createDragObjects: objectCollection
    "<objectCollection> is a collection of raw objects
    that need to be stored in drag objects.  Answer nil
    if could not create the objects.  For performance
    start the feedback before loading the objects.
    Since a drag failure here will cause the drag to
    terminate even before going into the drag loop,
    need to restore the cursor if fail."
    | previousCursor |

    self initCursors: objectCollection first.

    self dropLocation isNil  "Haven't dropped yet, start quick feedback"
        ifTrue: [
            previousCursor := Cursor.
            validCursor change ].

    ( super createDragObjects: objectCollection ) isNil
        ifTrue: [  "Load failed"
            previousCursor change.
            ^nil ]!  
extentForList: aList
    in: aListPane
    title: titleString
    maxEntriesToShow: maxEntriesToShow
        " Private - answer the size in dialog box units
        for a list box containing aList. "

    | titleWidth |
    titleWidth := ( self extentForEntryField: titleString size + 1) x.
        " approximate calculation for system menu "
    ^( titleWidth max: (self listWidthDlg: aList) )
    @ (self listHeightDlg: aList in: aListPane maxEntries: maxEntriesToShow)!   
getTarget
    "Private - answer the part under the mouse."
    | basicTarget newTarget editor |

    "Get the editor pane, or other window if not over
        the workbench."
    basicTarget := self getTargetBasic.

    ( basicTarget isNil
        or: [ basicTarget owner isPARTSApplication
        or: [ basicTarget owner isPARTSCatalog
        or: [ basicTarget isPARTSEditorPane ]]])
        ifFalse: [
            "Cursor leaving editor pane."
            ^nil ].

    ( basicTarget isPARTSEditorPane not
        and: [ ( editor := basicTarget partEditor ) notNil ])
        ifTrue: [ basicTarget := editor workbenchPane ].

    basicTarget isPARTSEditorPane
        ifTrue: [
            newTarget :=
                self
                    getTargetAt: (self screenLocation leftAndUp: self hotSpotOffset)
                    editorPane: basicTarget ].

    newTarget partIsWindow ifFalse: [ newTarget := basicTarget ].
    ^newTarget! 
editorClass
        " Private - answer the private editor class. "

    ^EditorClass!  
openOn: aBitmap
        "Open a BitEditor on aBitmap."
   self openOn: aBitmap clipRect: (0 @ 0 extent: aBitmap extent)!
sourceQueryContinue
        "Private - the keyboard or mouse state changed;
        determine how to continue the drag drop transfer.
        Drop the drag object as a side-effect.  Continue the
        dragdrop session."

    ( self lastEvent == #dragButtonUp and: [ self operation notNil ])
        ifTrue: [
            self targetDrop.
            self continue: #continue ]
        ifFalse: [ super sourceQueryContinue ].! 
createMasks
        "Private - Create the AND and XOR masks for Icon."
    self createMasks: icon!  
extentForButton: aButtonLabel
        " Private - measure button and add white space around label "

    | charWidthDlg x y |
    charWidthDlg := WindowDialog charWidth.  " dialog units "

    self font = SysFont
        ifTrue: [
            x := aButtonLabel size * charWidthDlg.
            y := WindowDialog charHeight ]
        ifFalse: [
            x := self class horizontalDialogUnitsFromPixels:
                ( self font stringWidth: aButtonLabel ).
            y := self class verticalDialogUnitsFromPixels: self font height ].

    ^( x + ( 2 * charWidthDlg ) )
    @ ( y + charWidthDlg )!   
editMenuCreate
        " Private - answer a new Edit menu. "
    | editMenu |
    editMenu := (PARTSEditMenu for: self)
        appendClearItem: #clear ;
        yourself.
    self editMenuFillItem: editMenu.
    ^editMenu!
initCursors
    "Private - Set the cursors for the receiver's feedback.
    Use the first drag object icon for the cursor."

    self initCursors: objects first icon asPARTSIcon.!   
pixelsPerHorizontalDialogUnit
    "Private - Answer the number of pixels
    per horizontal dialog unit. Answer can be a fraction."

    ^self horizontalDialogBaseUnit / self horizontalDialogUnitsPerCharacter! 
userName: aString
        " Set the current user name. "

    "Don't allow user name to change.  User name determined by
        Team/V"
    self class isRepositoryComponentInstalled
        ifTrue: [ ^self ].

    userName := aString!   
inputDirectoryName: aString
        "Set the name of the input directory, the directory
        containing the local .par files for which to produce
        .prs files."
    inputDirectoryName := aString!  
literalModel
    ^self classNamed: #CodeGenerationLiteral!   
listHeightDlg: aList in: aListPane maxEntries: maxEntriesToShow
        " Private - answer the height in dialog units "
    | nLines height |
    nLines := aList size min: maxEntriesToShow.
    self font = SysFont
        ifTrue: [
            ^( nLines * WindowDialog charHeight ) + 1 ]
        ifFalse: [
            height :=
                self class heightInDialogUnits: ( nLines * self font height ).
            "Add one so that the style that shows whole items in list box will
                recognize that there's at least one item."
            nLines = 1
                ifTrue: [ height := height + 1 ].
            ^height ]
! 
colorWellDefinedBaseLink
        " Answer the color for a base link which is fully defined. "

    ^colorWellDefinedBaseLink!  
dragging: aBoolean
	"Private - Set whether the receiver is processing
	a drag drop session."

	self propertyAt: #dragging
		put: ( aBoolean ifTrue: [ true ] ifFalse: [ nil ])!  
isPARTSReplaceSession
    "Answer whether the receive is an instance of PARTSReplaceSession"
    ^false!
suppressLoadMessages: aBoolean
        " Specify whether to suppress object load info
        messages during part file loading. "

    self isDeveloper ifFalse: [ ^self ].  " only developer can choose "
    self optionAt: #suppressLoadMessages put: aBoolean!  
sourceFeedback
        "Private - provide visual feedback for the current
        operation code ('move', 'copy', 'link', or nil), which
        indicates what would happen if a drop occurred
        over the current location (target) right now."

    self operation isNil
        ifTrue: [ cursor := self invalidCursor ]
        ifFalse: [ cursor := self validCursor ].
    cursor = Cursor ifFalse: [ cursor change ]!   
dropImmediate
    "Process actions appropriate for synchronous drop processing.
    If done asynchronously, may have to wait for the receiver's objects
    to load."

    cursor isNil
        ifTrue: [
            "Still loading the objects. Display the execute icon while loading"
            Cursor ~= CursorManager execute
                ifTrue: [ CursorManager execute change ]]! 
colorSelected: coordinates
        "Private - the user clicked in the color value set. Change
         the pen color. coordinates is a Point whose x and y are
         the row and column of the selected cell in the value set."
    bitColor := self class colorDictionary at: coordinates
        ifAbsent: [ Color black ].
    bitPen foreColor: bitColor.
    imagePen foreColor: bitColor.
    copy pen foreColor: bitColor!  
dragStart: aSourcePoint
    "Set the source coordinate where the receiver
    was initiated."

	super dragStart:
		( aSourcePoint mapFromWindow: source to: self editorPane )!   
readStream: aStream removeClass: aBoolean fileDescriptor: aFileDescriptor
            "Private - compile the code in aStream.  Answer a PARTS application.
            Remove the resulting class if aBoolean is true."
    ^self new readStream: aStream removeClass: aBoolean fileDescriptor: aFileDescriptor!   
targetNeedsOperations
        "Private - retrieve the list of drag-drop (extended) operations
        from the target."
    self target partDragTargetNeedsOperations: self!   
expressionClass
		"Answer the class of PARTS code generator expressions."

	^self classNamed: #PARTSCodeGeneratorExpression!   
linkReferenceClass
        "Answer the class of PARTS code generator link references."

    ^self classNamed: #PARTSCodeGeneratorLinkEntryPointReference!  
outputToImageAnd
    ^self classNamed: #CodeGeneratorOutputToImageAnd!   
findIconUnderCursor
        "Answer the icon object under the cursor."
    ^self iconAt: self cursorWindowPosition! 
targetNeedsOperations
        "Private - retrieve the list of drag-drop (extended) operations
        from the target."
    | opsCollection icon actualTarget
      mainOperation repeatMainOperation |

    mainOperation := self class mainOperation first.
    repeatMainOperation := ( #repeat, mainOperation ) asSymbol.

    opsCollection :=
        OrderedCollection
            with: repeatMainOperation
            with: #replace
            with: mainOperation.
    ( self objects detect: [ :aDragDropObject |
        self target
            partCanWindow: self target
            haveChild: aDragDropObject mainObject ]
        ifNone: [ nil ]) isNil
        ifTrue: [
            opsCollection
                remove: mainOperation;
                remove: repeatMainOperation ].

    actualTarget :=
        self target isPARTSEditorPane
            ifTrue: [  "Target may be an icon"
                ( icon := self target iconAt: self targetLocation ) notNil
                    ifTrue: [ icon connection ]
                    ifFalse: [ self target ]]
            ifFalse: [ self target ].

    ( self objects detect: [ :aDragDropObject |
        actualTarget partCanBeReplacedBy: aDragDropObject mainObject ]
        ifNone: [ nil ]) isNil
        ifTrue: [ opsCollection remove: #replace ].

    self supportsRepeatOperation
        ifFalse: [
            opsCollection remove: repeatMainOperation ifAbsent: [ nil ]].

    self operations: opsCollection.! 
keepInExecutable
    "Answer whether wrappers should be included in
    executable applications"

    ^PARTSWrapper keepInExecutable
!   
isAvailable
        "Private - answer whether the receiver can be used in the current
        environment.  The current version does not support
        Smalltalk library generation from the Workbnehc."
    ^false!
deselectAllIcons
    | oldSelected |
    oldSelected := selectedIcons.
    selectedIcons := OrderedCollection new.
    oldSelected do: [ :icon |
        self updateIcon: icon ]!
loadFrom: readStream context: loadContext
        "Private - load the application from readStream."
    | application |
    self classInStream: readStream into: [ :class |
        application := class application ].
    ^application!
writeLibraryFile: anApplication on: aStream fileDescriptor: aFileDescriptor libraryMappings: libraryMappings
        "Private - store anApplication in Smalltalk library format on aStream."
    CodeGenerationPrivateServices codeGenerator new
        writeLibraryFile: anApplication
        stream: aStream
        fileDescriptor: aFileDescriptor
        libraryMappings: libraryMappings!  
current
        " Answer the current PARTSLinkSettings object. "

    CurrentSettings isNil
        ifTrue: [ self current: self new ].
    ^CurrentSettings!
standardEntryHeight
        "Private - Answer the standard entry field height in dialog units"

   ^self verticalDialogUnitsPerCharacter +
        (NationalLanguage isDoubleByteCp
            ifTrue: [ 4 ]
               ifFalse: [ 2 ] )!  
button1Drag
        " Answer whether part move/resize is done with button 1. "

    ^mouseButtonDrag == #button1!  
initCursors
    "Set the cursors for the receiver's feedback."
    | hotSpot |

	hotSpot := "top left corner"
		self partsIfOS2Do: [ 0 @ icon visibleExtent y ]
		partsIfWindowsDo: [ 0 @ 0 ].
	validCursor := icon asPointerWithHotSpotAndMark: hotSpot.
    invalidCursor := CursorManager dragDropNone.!   
session
    "Answer the session with which the receiver
    is associated."

    ^session!
dropLocation
    "Answer the drop location which is determined
    synchronously, instead of waiting for asynchronous
    button event to get processed through consume input
    loop.  Needed when drag object loading is slow."

    ^self source dropLocation!  
fromFile: aFileName
        "Private - read a bitmap from aFileName and restore the receiver's
         contents with the bitmap."
    | newBitmap |
    newBitmap := Bitmap fromFile: aFileName.
    newBitmap isBitmap ifFalse: [^nil].
    self resetCopy: newBitmap.
    newBitmap release.
    scale := ((260 // copy extent x) min: (274 // copy extent y)) max: 4.
    bitPen erase.
    self initBitPen: bitPen graphicsMedium.
    imagePen erase.
    self initImagePen: imagePen graphicsMedium !  
store: anApplication into: aStream libraryMappings: libraryMappings
    " Store <anApplication> to a new file on <aStream>. "
    | fileName exeFileDescriptor anIcon exeIcon
      basicSmalltalkExe exePath
      mapFile mapPath timeStamp |

    fileName := fileDescriptor fileName fileName.
    exeFileDescriptor := fileDescriptor copy.
    exeFileDescriptor fileName:
        ( fileName, '.', PARTSFileDescriptor fileTypeForExe type ).

    basicSmalltalkExe := self basicSmalltalkExecutable.
    ( File exists: basicSmalltalkExe )
        ifFalse: [
            ^MessageBox
                warning: basicSmalltalkExe,
                    ' could not be found.  Application was not saved.' ].
    mapFile := self mapFileName.
    ( File exists: mapFile )
        ifFalse: [
            ^MessageBox
                warning: mapFile,
                    ' could not be found.  Application was not saved.' ].

    exePath := fileDescriptor fullPathName.
    File
        copy: self basicSmalltalkExecutable
        to: exePath.
    " add application's icon to exe "
    ( anIcon := anApplication icon ) notNil
        ifTrue: [
            exeIcon := anIcon cloneAsExe.
            self
                partsIfOS2Do: [ exeIcon outputToExe: exePath ]
                partsIfWindowsDo: [ exeIcon outputToExe: exePath id: 1 ].
            exeIcon release ].

    mapPath :=
        ( PARTSFileDescriptor
            fileName: (fileName,'.map')
            in: fileDescriptor directory ) fullPathName.
    File
        copy: self mapFileName
        to: mapPath.

    ( File newFile: ( fileName,'.bnd' ) in: exeFileDescriptor directory )
        nextPutAll: self workbenchRuntimeLibrary;cr;
        nextPutAll: self paxStarterLibrary;cr;
        close.

    super
        store: anApplication
        into: aStream libraryMappings:
        libraryMappings.

    timeStamp := TimeStamp current.
    ( File fromPath: exePath ) lastModificationTime: timeStamp.
    ( File fromPath: mapPath ) lastModificationTime: timeStamp.
    ( File fromPath: ( fileName,'.bnd' ) in: exeFileDescriptor directory )
        lastModificationTime: timeStamp.
    ( File fromPath: fileDescriptor fullPathName )
        lastModificationTime: timeStamp.
!   
outputDirectory
        "Answer the receiver's output directory."
    ^Directory pathName: outputDirectoryName! 
changeBit: aPane
        "Private - Change the bit at the current mouse location."
    |  aPoint  |
    aPoint := aPane mouseLocation.
    self changeBitAt: aPoint!  
isCodeGeneratorLibraryBound
        "Private - answer true if the PARTS code generator library is bound."
    ^Smalltalk includesKey: #CodeGenerator!   
verticalDialogUnitsFromLines: anInteger
    "Answer the number of vertical
    dialog units for anInteger lines."

    ^anInteger * self verticalDialogUnitsPerCharacter! 
upgradeSelectorInfo: nameChangeDict
        " Private - to support protocol upgrades. "

    | newSelector |
    newSelector := nameChangeDict at: selector ifAbsent: [ nil ].
    newSelector notNil
        ifTrue: [ ^Association key: selector value: newSelector ].
    newSelector := nameChangeDict at: realSelector ifAbsent: [ nil ].
    newSelector notNil
        ifTrue: [ ^Association key: realSelector value: newSelector ].
    ^nil!  
currentClass
        " Private - answer the current platform-dependent class "

   ^CurrentClass!  
copyClipboard
        "Private - Copy a bitmap from the clipboard."
    | bitmap |
    bitmap := Clipboard getBitmap.
    bitmap isNil ifTrue: [^nil].
    original release.
    copy release.
    original := bitmap.
    copy := Bitmap new
        width: original width
        height: original height
        planes: original planes
        bitCount: original bitCount.
    copy pen copyBitmap: bitmap
        from: bitmap boundingBox
        at: 0 @ 0.
    self displayBits: bitPen.
    self displayImage: imagePen!  
rightButtonScroll: point
        "Private - Do right button scrolling."! 
icons
	"Answer the icons in the receiver"

	^icons!
initialize
        " Private - initialize the receiver.
            PARTSLinkSettings initialize
        "

    self current: self basicNew.  " placeholder to PARTSSettings notification "
    self current: self new.!
catalogConnectionClass
        " Private "

    ^CatalogConnectionClass!   
mightReplace
    "Answer whether the receiver could
     replace the target with the drag object"

    ^Notifier isButton1Down
        ifTrue: [ self class extendedDragButtonIndex = 1 ]
        ifFalse: [ self class extendedDragButtonIndex = 2 ]!  
operation

    ^action! 
dragging
	"Private - Answer whether the receiver is processing
	a drag drop session."

	^( self propertyAt: #dragging ifAbsent: [ nil ]) notNil!  
getGraphicsTool
        "Private - Answer a graphics tool for the receiver."
     ^(self graphicsToolClass for: nil medium: self) font: self font!  
clearCachedPartsFrom: aComponentName
        " Clear the catalog cache of all parts which depend on
        classes in <aComponentName>. "

    self activeCatalogs do: [ :aCatalog |
        aCatalog clearCachedPartsFrom: aComponentName ].!  
from: aCatalogSession
    | aRepeatDropSession |

    aRepeatDropSession :=
        (self source: aCatalogSession source )
            objects: aCatalogSession objects;
            yourself.
    aRepeatDropSession objects
        do: [ :aDragObject | aDragObject session: aRepeatDropSession ].
    ^aRepeatDropSession!   
showIconSelected: anIcon
    anIcon reverseWith: graphicsTool!   
mainOperation
    "Private"

    ^( PARTSEditor editorClass developerAddingObject ) notNil
        ifTrue: [ Array with: #add with: 'Add' ]
        ifFalse: [ Array with: #import with: 'Import' ].!
computeLayoutParameters
        " Private - recompute font-dependent values. "

    " interior height and baseline of label text "
    labelLineHeight := labelFont height.
    labelLineHeight odd
        ifTrue: [labelLineHeight := labelLineHeight + 1].
    labelAscender :=
        labelLineHeight - labelFont descender
            - 12 + PARTSDialog standardEntryHeight.

    " overall dimensions of the label "
    labelHeight :=   " no interior border (interfers with message plugs) "
        labelLineHeight
         - 10 + PARTSDialog standardEntryHeight
        + (2 * self labelLineWidth).
    messageLabelSideWidth :=
        (labelHeight // 2) - self labelLineWidth.

    " data slot dimensions "
    dataSlotWidth := labelLineHeight - 2.
    dataSlotRadius :=
        ((dataSlotWidth // 2) - 4)
        max: 3.! 
initBitPen: aPane
    bitPen := aPane pen.
    bitPen execute: [ self displayBits: aPane ] clipRect:  (0 @ 0 extent: copy extent * scale).! 
userName
        " Answer the current user name. "

    ^self class isRepositoryComponentInstalled
        ifTrue: [
            (Smalltalk at: #PARTSTeamVInterface ifAbsent: [^userName ])
                userName ]
        ifFalse: [ userName ]! 
fileExit
        "Private - close the window and release all resources."
    self changesHandled ifFalse: [^nil].
    self releaseCopy.
    self close!   
initWindowSize
        "Private - Answer the window size."
    ^(23 @ 7) * WindowDialog unitMultiplier! 
xItemLabel
        " Private "
    self implementedBySubclass!  
scrollTopCorner: aPoint
        "Private - Scrolling not supported in the PARTSIconPane yet."
    ^nil! 
store: anApplication into: aStream libraryMappings: libraryMappings
    " Store <anApplication> to a new file on <aStream>. "
    CursorManager execute
        changeFor: [
            CodeGenerationPrivateServices codeGenerator new
                    writeSourceFile: anApplication
                   stream: aStream
                    libraryMappings: libraryMappings ]! 
targetDrop
        "Private - the dragged object was dropped over the current
        target at the current location.
            Erase the feedback befow the object is moved."

    self drawFrames: 0.
    super targetDrop! 
inputPathName
        "Answer the name of the input stream, assumming
        the input stream is file based."
    ( inputStream isKindOf: FileStream )
        ifFalse: [ ^nil ].
    ^inputStream file pathName!   
targetLeave
        "Private - the mouse left the bounds of the
        current target during a drag drop transfer.
        If receiver was cancelled, erase feedback."

    super targetLeave.
    self continue = #cancel
        ifTrue: [ self drawFrames: 0 ].!   
open
    self openOn: (Bitmap screenExtent: 32 @ 32)!
colorWellDefinedArgLink: aColor
        " Specify the color for an argument link which is fully defined. "

    colorWellDefinedArgLink := aColor! 
fileInUpgrade: anObjectFiler
        " Private - upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object. "

    | loadContext |

    loadContext := anObjectFiler clientContext.
    loadContext isPARTSLoadContext not
        ifTrue: [ ^self ].
	( loadContext fileVersion = 'PARTS/Win32 2.0' or: [
		loadContext fileVersion = 'LAF/VPM 2.0a' ] )
		ifFalse: [ ^self ].

    " PW 2.0 application upgrades "
	anObjectFiler
		 when: #upgraded
			send: #fileInUpgraded: to: self with: anObjectFiler;
		when: #loaded
			send: #fileInUpgradeLoaded: to: self with: anObjectFiler.!   
defaultExtendedStyle
        "Private - answer the default extended style flags for the
        receiver.  Do not want the 3d border style."
    ^0!   
sourceNeedsObject
    "Private - retrieve the drag drop object from the
    drag source.  Set a dummy object."

    ^self objects: (OrderedCollection with:
        ( self objectClass new
            session: self;
            yourself ))! 
store: anApplication into: aStream libraryMappings: libraryMappings
    PARTSCodeGeneratorWriterInterface
        writeLibraryFile: anApplication
        on: aStream
        fileDescriptor: self fileDescriptor
        libraryMappings: libraryMappings!  
startUp
        " Private - image startup "

    self editorClass startUp! 
new
        " Answer a new PARTS Workbench link settings instance. "

    ^self forFont: self defaultFont! 
mouseButtonSelect: aSymbol
        " Specify the mouse button used for selection. "

    mouseButtonSelect := aSymbol asSymbol.!   
targetEnter
        "Private - the mouse entered the bounds of the
        current target during a drag drop transfer."
    self target partDragTargetEnter: self! 
mouseButtonDrag
        " Answer the mouse button used for dragging parts. "

    ^mouseButtonDrag!
resetCopy: aBitmap
        " Private "
    copy release.
    copy := aBitmap clone !   
partSetExecutionContextFor: aBlock
        "Set the receiver to be the execution context for aBlock."
    aBlock
        on: PARTSGetExecutionContext
        do: [ :e | e contents: self ]!  
mightReplace
    "Private - Answer whether the receiver could replace the
    target with the drag object."

    ^true!   
setButton1Link
        " Set button2 to move/resize and button1 for create link. "

    self
        mouseButtonLink: #button1;
        mouseButtonDrag: #button2.!  
fileName
        " Private "

    ^fileName!   
initialize
        "Private - install default control settings."

    " link colors "
    colorWellDefinedBaseLink := Color darkGreen.
    colorUndefinedBaseLink := Color red.
    colorWellDefinedArgLink := Color blue.
    colorUndefinedArgLink := Color pink.

    " background colors "
    colorWorkbench := Color gray.
    colorCatalog := Color gray.
    colorLinkLabel := Color gray.

     " mouse button semantics "
    self initializeMouseButtons.

    " application author "
    userName := 'Anonymous'.

    " Workbench preference defaults "
    isDeveloper := SessionModel current isRunTime not.
    gridExtent := self defaultGridExtent.
    showHints := true.
    showLinkLabels := false.
    showLinksWithSelection := false.

    " fonts "
    self initializeFonts.
    " init file "
    fileName := PARTSIniFile defaultFileName.

    " catalog list "
    catalogs := self defaultCatalogs.

    " orthogonal link creation "
    orthogonalLinks := true.

    " default scale unit for links and icons "
    self defaultScaleUnit: #twip.!  
dialogTitle: partName modifier: modifier
        " Private - answer the dialog title string. "

    ^partName, ' Properties - ', modifier! 
colorUndefinedBaseLink
        " Answer the color for a base link which isn't fully defined. "

    ^colorUndefinedBaseLink!   
classNamed: aSymbol
        "Answer a class named aSymbol."
    | answer |
    answer := Smalltalk at: aSymbol ifAbsent: [ nil ].
    answer notNil ifTrue: [ ^answer ].
    self bindLibraryFor: aSymbol.
    ^Smalltalk at: aSymbol ifAbsent: [ self error: 'Cannot find class named ', aSymbol ]!
writeSourceCode
        "Write the source code.  Some form out input and
        output should already be set."
    self write: partApplication on: outputStream!  
writerInterface
    ^self classNamed: #PARTSCodeGeneratorWriterInterface!
readStream: aStream removeClass: aBoolean fileDescriptor: aFileDescriptor
        "Private - compile the code in aStream.  Answer a PARTS application.
        Remove the resulting class if aBoolean is true."
    fileDescriptor := aFileDescriptor.
    ^self readStream: aStream removeClass: aBoolean!   
destroyLibraryMap
        "Private - set libraryMap to nil.  The library map will be
        rebuilt by the #registerClasses method whenever
        #bindLibraryFor: method is invoked, so this method
        method should be executed whenever the method
        #registerClasses is modified.

            CodeGenerationPrivateServices destroyLibraryMap

    "

    libraryMap := nil!
targetNeedsOperations
        "Private - retrieve the list of drag-drop (extended) operations
        from the target."

    self target == self source "CatalogPane"
        ifTrue: [ self operations: #( #move ) ]
        ifFalse: [
            self target isPARTSCatalogPane
                ifTrue: [ self operations: #( #move #copy ) ]
                ifFalse: [ super targetNeedsOperations ]].!
currentDragHandler: aSymbol
        " Set the current drag handler.  aSymbol can be
           #includeGroupBox, #excludeGroupBox, or nil. If
           aSymbol is nil then use the system default hit test."

    CurrentDragHandler := aSymbol.!  
targetLeave
        "Private - the mouse left the bounds of the
    current target during a drag drop transfer.  Need to
    clear the target.  If going into non-Smalltalk area,
    targetLeave's will continue to be sent to the target
    without any targetEnter's, causing feedback flicker."

    self target notNil
        ifTrue: [
            self target partDragTargetLeave: self.
            self target: nil ].!  
dataSlotWidth
        " Answer the width of a data slot in a link label. "

    ^labelLineHeight - 2!  
partCreatorClass
		"Answer the class which creates parts during application loading
		from a source description. "

	^self classNamed: #PARTSCreator! 
logStream
    logStream isNil ifTrue: [
        logStream := self getLogStream ].
    ^logStream!  
doDragDropAt: aPoint button: anInteger
        "Private - begin a drag drop transfer.  The index of the mouse button
        that was used to initiate the drag is indicated by anInteger."
    | targetPoint extent editor |

    super doDragDropAt: aPoint button: anInteger.

    ( editor := self target partEditor ) isNil
        ifTrue: [ ^nil ].
    targetPoint :=
        self targetLocation mapFromWindow: self target
            to: editor workbenchPane.
    extent := icon visibleExtent.
    self partsIfOS2Do: [ targetPoint := targetPoint down: extent y ].
    ^PARTSDragResult new
        operation: self operation
        destinationRectangle: ( targetPoint extent: extent )
        destinationWindow: target!
dragStart
    "Answer the coordinate where the receiver
    was initiated.  The coordinate is relative to
	the editor or catalog pane"

    ^dragStart!  
colorWorkbench: aColor
        " Set the background color for the PARTS editor. "

    aColor = colorWorkbench
        ifTrue: [ ^self ].
    colorWorkbench := aColor.
    PARTSEditor activeEditors do: [ :editor |
        editor updateBackgroundColor: colorWorkbench ].! 
canMirrorCopy
    "Answer whether the receiver should mirror copy
    its objects when dropping them.  Don't mirror copy
    executable applications because infinite recursion
    will occur."

    ^self objects first icon connection isExecutable not! 
offset: anOffset
    "Set the offset of the object from the object origin to the
    source location."

    offset := anOffset!   
backupCreate: aFileReference
        "Create a backup file with extension .BAK for <aFileReference>.
         Answer the file or nil if there was not a file."
        "Do not allow backup of EXE yet."!  
addButtonGroup: aGroupPane
        "Private - "
    | gap height |
    gap := SysFont width.
    height := SysFont height + 8.
    super addButtonGroup: aGroupPane.
    aGroupPane addSubpane: (GroupBox new
        contents: 'Mode';
        framingBlock: [: box |
            (box leftTop rightAndDown: gap  @ ( height * 2 + 8 ))
                extentFromLeftTop: (box width - (2 * gap) @ ( height * 4 ))]).
    aGroupPane addSubpane:
        (RadioButton new
            owner: self;
            setName: 'colorButton';
            contents: 'Color';
            selection: true;
            when: #clicked:
                send: #colorButtonSelected to: self;
            framingBlock: [: box |
                (box leftTop rightAndDown: gap + 4  @ ( height * 3 ))
                    extentFromLeftTop: ( box width - ( 3 * gap ) @  height )]).
   aGroupPane addSubpane:
        (RadioButton new
            owner: self;
            setName: 'screenButton';
            contents: 'Screen';
            when: #clicked:
                send: #screenButtonSelected to: self;
            framingBlock: [: box |
                (box leftTop rightAndDown: gap + 4 @ ( height * 4 ))
                    extentFromLeftTop: ( box width - ( 3 * gap ) @ height )]).
    aGroupPane addSubpane:
        (RadioButton new
            owner: self;
            setName: 'inverseButton';
            contents: 'Inverse';
            when: #clicked:
                send: #inverseButtonSelected to: self;
            framingBlock: [: box |
                (box leftTop rightAndDown: gap + 4 @ ( height * 5 ))
                    extentFromLeftTop: (box width - (3 * gap) @ height )]).! 
classNamed: aSymbol
		"Private - answer the class named aSymbol."

    self bindCodeGeneratorLibrary.
	^Smalltalk at: aSymbol ifAbsent: [
		self error: 'Code Generator class named ', aSymbol, ' missing.' ]!   
orthogonalLinks: aBoolean
    "Set whether user created lines should be draw
    with orthogonal links."

    orthogonalLinks := aBoolean!
logWindowLabel
        "Private - answer the label for the receiver's log window."
    ^'PARTS Code Generator Writer Messages  ', TimeStamp current printString!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Upgrade directory
        representation in PWW 2.0 applications. "

    PARTSHostInterface isWindows
        ifTrue: [
            ( directory class name = 'UpgraderForDirectory'
            or: [ directory class name = 'Directory' ] )
                ifTrue: [
                    anObjectFiler
                        when: #upgraded
                        send: #fileInUpgradeCompletion: to: self with: anObjectFiler.
                    ].
        ].!
optionsPenSizeMenu
        "Private - answer the current pen size menu."
    ^self menuTitled: self optionsPenSizeMenuTitle!
deriveNameFrom: aSymbol
        "Private - aSymbol is already used as a global name.  Find and answer
        a name derived from aSymbol that is not a global name. "
    | answer |
    answer := aSymbol.
    [ Smalltalk includesKey: answer ]
        whileTrue: [ answer := ( answer, 'X' ) asSymbol ].
    ^answer! 
extentForLabel: aLabel
        " Private - measure aLabel "

    self font = SysFont
        ifTrue: [
            ^(aLabel size * WindowDialog charWidth)
            @ WindowDialog charHeight ]
        ifFalse: [
            ^( self class horizontalDialogUnitsFromPixels: ( self font stringWidth: aLabel ) )
            @ ( self class verticalDialogUnitsFromPixels: self font height ) ].!
refresh
    self
        displayBackground;
        displayContents;
        displaySelection!
defaultFontIconLabels
        " Answer the default font to use for an icon label in
        a PARTS Workbench window. "

   NationalLanguage isDoubleByteCp ifTrue: [ ^SysFont ].

    self
        partsIfOS2Do: [
            ^Font
                face: 'Helv'
                size: 5@13
                fixedWidth: false ]
        partsIfWindowsDo: [
            ^Font new
                faceName: 'Arial';
                pointSize: 8 graphicsMedium: Display;
                fixedWidth: false;
                bold: false;
                "GONE in VW 3.0: hollow: false;"
                italic: false;
                "GONE in VW 3.0: negative: false;"
                strikeOut: false;
                underscore: false;
                makeFont;
                yourself ].
    self error: 'unknown platform'!   
addIconToSelection: icon
    ( selectedIcons includes: icon )
        ifTrue: [ ^self ].
    selectedIcons add: icon.
    self updateIcon: icon!  
dragButton
    "Answer the drag button index as the symbol
    #button1 or #button2"

    ^self dragButtonIndex = 1
        ifTrue: [ #button1 ]
        ifFalse: [ #button2 ]! 
poolVariableReferenceClass
		"Answer the class of PARTS code generator pool variable references,
		those references to objects existing in pool dictionaries."

	^self classNamed: #PARTSCodeGeneratorPoolReference!  
fileInUpgradedOS2: anObjectFiler
       " Private - finish upgrading a PWO 2.0 application.
       Install application-wide changes here.  This is done
       at the end of the upgrade cycle so that any of the
       application's component parts which need to mutate
       during their own upgrade have finished fixing themselves. "

    | aPartWrapper colorProperties propertiesDictionary oldColor newColor |
    self partsVosOnly.  " Only used on VOS"
    self components do: [ :aPart |
        ( aPart isKindOf: Window )  " isWindow is tricky for shrunken parts "
            ifTrue: [
                aPartWrapper := self findWrapper: aPart.
                colorProperties := OrderedCollection new.
                ( propertiesDictionary  := aPart properties ) notNil
                    ifTrue: [
                        propertiesDictionary associationsDo: [ :assoc |
                            assoc value class symbol = #PARTSUpgradeRGB
                            ifTrue: [ colorProperties add: assoc key ] ].
                            ].
                colorProperties do: [ :aPropertyName |
                    oldColor := aPart propertyAt: aPropertyName.
                    newColor := oldColor asRGBColor.
                    aPart propertyAt: aPropertyName put: newColor.
                    anObjectFiler registerUpgradeMutationFrom: oldColor
                        to: newColor.
                    ].
                ]
            ifFalse: [
                aPartWrapper := aPart partWrapper ].
        aPartWrapper isNil
            ifTrue: [
                anObjectFiler recordWarningMessage:
                    'Orphan part encountered: ',
                    ( componentDictionary keyAtValue: aPart ), ' - ', aPart printString.
                ]
            ifFalse: [  " PWO 2.0 scripts need to be mutated for 3.0 "
                aPartWrapper fileInUpgradeScriptsOS2: anObjectFiler ].
        ].
!   
mightReplace
    "Answer whether the receiver could
     replace the target with the drag object"
    ^false!  
objectClass
        "Answer the class of drag drop objects an
        instance of the receiver will contain."
    ^PARTSAddPartObject! 
readStream: aStream fileDescriptor: aFileDescriptor
            "Private - compile the code in aStream.  Answer a PARTS application.
            Remove the resulting class after the application has been
            built."
    ^self readStream: aStream removeClass: true fileDescriptor: aFileDescriptor!   
inputStream: inStream outputStream: outStream
        "Read the part from inStream and write source code
        representation to outStream."
    ^self new
        inputStream: inStream;
        outputStream: outStream;
        writeSourceCode!   
colorDictionary
		" Private "
	^ColorDictionary!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    | loadContext |

    loadContext := anObjectFiler clientContext.
    ( loadContext isPARTSLoadContext not  " paste parts has no context "
    or: [ loadContext isCurrentVersion ] )
        ifTrue: [ ^self ].
    " author property renamed to manufacturer in PW 3.0 "
    userProperties do: [ :assoc |
        assoc key = 'author' ifTrue: [ assoc key: 'manufacturer' ] ].!   
new
        " Answer an instance of the current platform class "

    ^self currentClass new!  
logWindowLabel
        "Private - answer the label for the receiver's log window."
    ^'PARTS Code Generator Messages  ', TimeStamp current printString!   
setWindowTitle
        " Private - set window title to bitmap file name. "
    self mainView labelWithoutPrefix: self windowTitle.! 
isInGrid: aPoint
    "Private - Answer true if aPoint is in the grid."

    | gridRectangle |

    gridRectangle := (0 @ 0 extent: (copy extent * scale)).
    ^(gridRectangle leftTop x isLeftEqualOf: aPoint x) and:
        [(gridRectangle leftTop y isAbove: aPoint y) and:
            [(aPoint x isLeftOf: gridRectangle rightBottom x) and:
                [aPoint y isAbove: gridRectangle rightBottom y]]]!   
colorWellDefinedBaseLink: aColor
        " Specify the color for a base link which is fully defined. "

    colorWellDefinedBaseLink := aColor!
isResumable: aBoolean
        "Set whether or not the receiver can be resumed."
    isResumable := aBoolean!
editSelect
        "Select a portion to cut/copy/paste."
    | w origin corner newLoc bitPoint imagePoint penWidth |
    self editMenu
        enableItem: #editCut;
        enableItem: #editCopy;
        enableItem: #editPaste.
    w := bitPen graphicsMedium.
    w captureMouseInput.
    penWidth := bitPen lineWidth.
    bitPen setLineWidth: 1;
        foreColor: Color white;
        setForegroundMode: MixRuleXor.
    Notifier consumeInputUntil: [: event |
        (event selector = #button1Down:)
            ifTrue: [
                imagePoint := w cursorWindowPosition // scale.
                bitPoint := imagePoint * scale.
                origin := corner := bitPoint.
                bitPen place: origin; box: (corner rightAndUp: 1 @ 1)].
        (event selector = #button1Move:)
            ifTrue: [
                imagePoint := w cursorWindowPosition // scale.
                bitPoint := imagePoint * scale.
                newLoc := bitPoint.
                ( ( self isInGrid: newLoc ) and: [
                    corner ~= newLoc ] )
                    ifTrue: [
                        bitPen place: origin;
                            box: (corner rightAndUp: 1 @ 1);
                            place: origin;
                            box: (newLoc rightAndUp: 1 @ 1).
                            corner := newLoc]].
        event selector = #button1Up:
            ifTrue: [
                bitPen place: origin;
                    box: (corner rightAndUp: 1 @ 1).
                w clearMouseCapture].
        event selector = #button1Up:].
    bitPen foreColor: bitColor;
        setLineWidth: penWidth;
        setForegroundMode: MixRuleDefault.
    selection := (origin // scale corner: (corner // scale))
        asNormalizedRectangle.! 
wrapper: aWrapper

    wrapper := aWrapper! 
compilerError: errorMessage at: anInteger in: codeString for: aClass

    "self ASSERT: codeString = self contents."
    self
        value:
            (codeString copyFrom: 1 to: anInteger - 1),
            errorMessage,
            (codeString copyFrom: anInteger to: codeString size);
        selectFrom: anInteger to: anInteger + errorMessage size;
        setFocus!  
font
        " Answer the font to use for the dialog items. "

    ^PARTSSettings current fontDialogs! 
openOn: anIcon saveBlock: aBlock
        "Open a PARTSIconEditor on anIcon.
        Evaluate aBlock when the user selects save."
    saveBlock := aBlock.
    self openOn: anIcon.!   
labelAscender
        " Answer the font ascender height in a link label. "

    ^labelAscender!
dragButtonIndex
        "Private - answer the drag button index,
        or nil if not supported."

    ^self userDragButtonIndex!
rectangleWithoutMargin: aRect
        "Answer a rectangle based on aRect without
        extra margin."
    self partsVosOnly.
    ^self hasBorderStyle
        ifTrue: [
            self superWindow isDialogTopPane
                ifTrue: [ aRect ]
                ifFalse: [ aRect insetBy: 3 @ 3 ]]
        ifFalse: [ aRect ]!  
resourceExpressionClass
		"Answer the class of PARTS code generator resource expressions.
		Resource expressions are those that refer to binary objects in a
		code generator resource file."

	^self classNamed: #PARTSCodeGeneratorResourceExpression! 
canMirrorCopy
    "Answer whether the receiver should mirror copy
    its objects when dropping them"

    ^( self operation asString asLowerCase indexOfString: 'repeat' ) > 0!  
object
        "Answer the object associated with the receiver.
    If the object is a PARTSIcon, answer its main object"

    ^object isPARTSIcon
        ifTrue: [
            object connection isPARTSApplication
                ifTrue: [ object connection ]
                ifFalse: [ object mainObject ]]
        ifFalse: [ object ]! 
optionsChangeColor
        "Private - Bring up the color dialog to let the user change
         the color of the pen."
        " Platform dependent (only needed when ValueSet not available) "
    | color |
    self partsVwOnly.  " Only used on VW"
    color := ColorDialog new
        openOn: copy pen foreColor;
        chosen.
    color isColor ifTrue: [
        fillColor := color.
        bitColor := bitPen partsGetNearestColor: color.
        bitPen foreColor: bitColor.
        imagePen foreColor: bitColor.
        copy pen foreColor: bitColor.
        self setColorBoxes]!  
openOnPathName: aFileName
        "Open a BitEditor on a bitmap in aFileName."
       | bitmap |
    fileName := aFileName.
    bitmap := Bitmap fromFile: aFileName.
    bitmap notNil ifTrue: [self openOn: bitmap]!   
renamedWrapper: aWrapper
        " The part owned by aWrapper has been renamed. "!   
displayImage: graphPane
        "Private - Display icon image in image graphics pane"
    
    imagePen := graphPane pen.
    imagePen erase.
    imagePen copyBitmap: copy
        from: copy boundingBox
        at: 0 @ 0!  
outputPathName
        "Answer the path name of the output stream
        assumming the output stream is file based."
    ( outputStream isKindOf: FileStream )
        ifFalse: [ ^nil ].
    ^outputStream file pathName!  
doDragDropAt: anEditorPanePoint button: anInteger
        "Private - begin a drag drop transfer.  Start a repeat
        drop operation if requested."

    super doDragDropAt: anEditorPanePoint button: anInteger.

    ( self operation asString asLowerCase indexOfString: 'repeat' ) > 0
        ifTrue: [
            ( PARTSRepeatDropSession from: self )
                doDragDropAt: anEditorPanePoint button: nil ]
!   
optionAt: aSymbol ifAbsent: aBlock
        " Private - answer the value of the option named aSymbol. "

    options isNil ifTrue: [ ^aBlock value ].
    ^options at: aSymbol ifAbsent: aBlock!   
getLogStream
        "Private - create a text window to log messages to."
    ^PARTSTextWindow new
        label: self logWindowLabel;
        openOn: String new!
mainOperation
    "Private"

    ^Array with: #drop with: 'Copy'!  
openOnPathName: aPathName
        " Open an edit window on the PARTS file
        named aPathName."

    | app |
    [ app := PARTSFile applicationFromPathName: aPathName ]  " get editable app "
        on: PARTSApplicationLoadError
        do: [ :e |
            e postMessageBox.
            ^nil ].
    app isNil
        ifTrue: [ ^nil ]. "Backstop: should raise error"

    self editorClass new openOn: app.
    ( Message
        receiver: self
        selector: #surfaceWarningsForPathName:
        arguments: ( Array with: aPathName ) )
            performDeferred.!
doDragDropAt: anEditorPanePoint button: anInteger
        "Private - begin a drag drop transfer.  The index of the mouse button
        that was used to initiate the drag is indicated by anInteger."

    self dragStart isNil
        ifTrue: [ self dragStart: anEditorPanePoint ].

    self editorPane notNil
        ifTrue: [ self editorPane setFocus ]. "To receive ESC key"

    super doDragDropAt: anEditorPanePoint button: anInteger.

    ( target notNil and: [
        target dragTargetSelection notNil ])  "Clean up emphasis"
        ifTrue: [ target dragTargetEraseEmphasisDefault: self ]! 
xItemLabel
        " Private "
    ^'Width:'!   
horizontalDialogUnitsPerCharacter
    "Private - Answer the number of horizontal 
    dialog units per character."

    ^4    "an OS constant"!   
targetEraseEmphasis
        "Private - the target should erase emphasis."
    self target partDragTargetEraseEmphasis: self!
initialize
	"Private"
    SessionModel current
        when: #aboutToSaveImage
        send: #aboutToSaveImage
        to: CodeGenerationPrivateServices!
fontLinkLabels: aFont
        " Specify the font to use for link labels in a workbench. "

    fontLinkLabels := aFont.
    self linkRenderingSettings labelFont: fontLinkLabels.!
current: aLinkSettings
        " Private - set the current settings to an instance of the receiver. "

    CurrentSettings := aLinkSettings.!  
button1Select
        " Answer whether selection is done by clicking button 1. "

    ^mouseButtonSelect == #button1!  
objectAttribute

    ^object!   
linkExpressionClass
        "Answer the class of PARTS code generator parts link expressions."

    ^self classNamed: #PARTSCodeGeneratorLinkExpression!   
displayImage: aPane
    imagePen := aPane pen.
    copy displayAt: 0 @ 0
        with: imagePen!   
restoreOriginal
        "Private - Restore the original image."
    copy release.
    self createMasks.
    self displayBits: bitPen graphicsMedium.
    self displayImage: imagePen graphicsMedium! 
editorsOnFile: aFileReference
        " Answer any editors open on <aFileReference>
        on the PARTS search path."

    | fullPathName |
    aFileReference isString
        ifTrue: [
            [ fullPathName := PARTSFile fullPathName: aFileReference ]
                on: PARTSNotOnSearchPath
                do: [ :e | ^#() ].
            ^self editorsOnPathName: fullPathName ].

    ^self activeEditors select: [ :anEditor |
        anEditor appFileDescriptor notNil
        and: [ anEditor appFileDescriptor = aFileReference ] ]! 
title
        " Private "
    self implementedBySubclass!   
optionsMenuTitle
        " Private "
    ^PARTSStandardMenu mnemonic, 'Options'!
editMenu
        " Private - answer the current Edit menu. "
    ^self menuTitled: PARTSEditMenu title! 
isPARTSRepeatDropSession
    "Answer whether the receiver is an instance
    of PARTSRepeatDropSession"

    ^true!   
orthogonalLinks
    "Answer whether user created lines should be draw
    with orthogonal links."

    ^orthogonalLinks!  
catalogs
        "Answer a list of the catalog files to open for a workbench. "

    ^catalogs!
updateSliders!
applicationInStream: aStream
        "Compile the code in aStream.  Build and answer a
        PARTSApplication from the resultant class."
    | class answer |
    self partSetExecutionContextFor: [
        class := self classInStream: aStream.
        class isClass ifTrue: [
            answer := class application ]].
    ^answer! 
addButtonGroup: aGroupPane
        "Private - Add the 'Apply' and 'Reset' buttons to aGroupPane."
    | gap height |
    gap := SysFont width.
    height := SysFont height + 8.
    aGroupPane addSubpane: (Button new
        owner: self;
        setName: 'Apply';
        contents: 'Apply';
        when: #clicked
            send: #applyChanges to: self;
        framingBlock: [: box |
            (box leftTop rightAndDown: gap @ 4)
                extentFromLeftTop: ( box width - ( 2 * gap ) @ height )]).
    aGroupPane addSubpane: (Button new
        owner: self;
        setName: 'Reset';
        contents: 'Reset';
        when: #clicked
            send: #restoreOriginal to: self;
        framingBlock: [: box |
            (box leftTop rightAndDown: gap @ ( height + 8 ))
                extentFromLeftTop: ( box width - ( 2 * gap ) @ height )]).!   
optionsMenuCreate
        " Private - answer a new options menu. "
    | mnemonic tabString controlCharAccelerator optionsMenu |
    mnemonic := PARTSStandardMenu mnemonic.
    tabString := PARTSStandardMenu tabString.
    controlCharAccelerator := PARTSStandardMenu controlCharAccelerator.
    optionsMenu := (PARTSStandardMenu for: self titled: self optionsMenuTitle)
        appendItem: mnemonic, 'Grid', tabString, 'Ctrl+G'
            selector: #optionsGrid
            accelKey: $g
            accelBits: controlCharAccelerator;
        appendItem: 'Change ', mnemonic, 'size..', tabString, 'Ctrl+S'
            selector: #optionsChangeSize
            accelKey: $s
            accelBits: controlCharAccelerator;
            yourself.
        self partsIfWindowsDo: [ optionsMenu
            appendItem: 'Change ', mnemonic, 'color..', tabString, 'Ctrl+L'
                selector: #optionsChangeColor
                accelKey: $l
                accelBits: controlCharAccelerator ].
    optionsMenu checkItem: #optionsGrid.
    ^optionsMenu!
dragRect: aRect
    "Set the rectangle of the object described by the
    receiver as it is dragged across the workbench."

    dragRect := aRect!
topPaneClass
        "Private - Answer the default top pane class."
    ^PARTSTopPane!  
targetDrawFrame
        "Private - draw the receiver's frame."
    self drawFrames: 0!  
inputPARTSApplication: aPARTSApplication
            "Set the input PARTS application."
    partApplication := aPARTSApplication!   
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
compileFiles: anArrayOfFileNames inDirectory: aDirectoryName log: aStream
        "Compile the source (.CLS) files specified by anArrayOfFileNames
        in aDirectoryName.  Log any messages to aStream.  Do not remove
        the resulting classes."
    | dir fileStream reader class |
    dir := Directory pathName: aDirectoryName.
    aStream cr; nextPutAll: 'Compiling files in ', aDirectoryName.
    anArrayOfFileNames do: [ :fileName |
        fileStream := dir file: fileName.
        reader := self new.
        reader logStream: aStream.
        class := reader classInStream: fileStream.
        aStream cr; nextPutAll: '    ', fileName, ' -> ', class printString.
        fileStream close ]!   
operation: operationName
        "Set the operationName which specifies what would happen if the
        drag object were dropped right now at the current location
        and over the current target.  Operation for receiver is determined
        at when the drag session is initiated and remains in effect for the
        duration of the session."

    super operation:
        ( operationName isNil
            ifTrue: [ nil ]
            ifFalse: [
                initialOperation isNil
                    ifTrue: [
                        initialOperation :=
                            Notifier isControlKeyDown
                                ifTrue: [ #copy ]
                                ifFalse: [
                                    ( Notifier isShiftKeyDown
                                        or: [ self source partFencesMoveSession not ])
                                        ifTrue: [ #moveGlobal ]
                                        ifFalse: [ #moveLocal ]]].
                    initialOperation ]).!
writeSettingsFile
        " Store the current settings in the PARTS init file. "

    PARTSIniFile writeSettingsFileFor: self newFile: fileName.!  
contents: anArray
        "Set iconArray to anArray of
         rectangles denoting the spot
         of each icon."
	| temp |
	temp := icons.
    icons := anArray.
    selectedIcons := OrderedCollection new.
	"**** icons must be set before releasing the old ones. otherwise
		call back can occur in the middle of release which
		causes released icon to be restored (especially in
		'File\Replace' operations)"
    temp notNil ifTrue: [  "release any previous icons"
        temp do: [:each | each release]].
    self refresh.! 
userDragButtonIndex
        "Private - answer the button for a drag button move."
    | button |

    ^self
        partsIfOS2Do: [
            self hostDragButtonIndex ]
        partsIfWindowsDo: [
            ( button := PARTSSettings current mouseButtonDrag ) = #button1
                ifTrue: [ 1 ]
                ifFalse: [ 2 ]].!   
open
        " Open an editor on a new application. "

    self editorClass new openOn: PARTSApplication new.! 
hotSpotOffset
    "Answer the offset for the cursor"

    ^0 @ 0!  
editorPane: anEditorPane
    editorPane := anEditorPane! 
targetDrawEmphasis
        "Private - the target should draw emphasis.
    Override the super class.  Parts implements its
    own drawing through partDragTargetEnter/Over/Leave/Drop"!   
editorPane
    "Answer the editor pane where the receiver was
    initiated."

    ^self source!  
codeGenerator
    ^self classNamed: #CodeGenerator!  
current
        " Answer the current PARTSSettings object. "

    CurrentSettings isNil
        ifTrue: [ self current: self new ].
    ^CurrentSettings!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    ( frameRectangle isNil or: [ frameRectangle isPARTSRectangle ])
        ifFalse: [
            self frameRectangle:
                ( anObjectFiler clientContext scaleRectangle: frameRectangle ) ].

    self virtualScreenExtent isNil
        ifTrue: [  self virtualScreenExtent: Display extent ].

    ^super fileInUpgrade: anObjectFiler
! 
operation: aSymbol destinationRectangle: aRectangle destinationWindow: aWindow
    action := aSymbol.
    destinationRectangle := aRectangle.
    destinationWindow := aWindow.!   
sourceFeedback
        "Private - provide visual feedback for the current
    operation code.
        Do a special check for the first feedback.  When
    dragging a part from the catalog for the first time,
    there is a slight delay as the drag object is retrieved,
    causing a timing problem detecting the actual target
    and drop operation.  Reaccess the correct target and
    operation in this situation."

    self dropLocation notNil  "Dropped before feedback can start"
        ifTrue: [ ^self ].

    ( cursor isNil and: [ operation isNil ])
        ifTrue: [  "First feedback"
            self setLocation.
            self target: self getTarget.
            self targetOver ].
    super sourceFeedback.!   
textWindowOutput
    ^self classNamed: #CodeGeneratorTextWindowOutput!   
messageLabelSideWidth
        " Answer the width of the message link label
        side shape beyond its core rectangle. "

    ^messageLabelSideWidth!   
lastEvent: aMessage upSelector: upSelector
        "Private - set the symbol which represents the last keyboard / mouse state
        change that occurred during a drag drop transfer to aSymbol."
    (( aMessage selector == #button1Up:
        and: [ self class dragButtonIndex = 2 ])
    or: [ aMessage selector == #button2Up:
        and: [ self class dragButtonIndex = 1 ]])
          ifTrue: [ self operation: nil. self lastEvent: #escapeKey ]
          ifFalse: [ ^super lastEvent: aMessage upSelector: upSelector ].!
bindCodeGeneratorLibrary
        "Private - bind the PARTS code generator library if it is not already bound."

    self isCodeGeneratorLibraryBound ifTrue: [ ^self ].
    ( PARTSSessionManager
        bindLibrary: 'PWCCGN31'
        errorTitle: 'Code Generator Bind Problem'
        neededFor: 'loading and storing applications in source form' )
            ifFalse: [ self error: 'Cannot bind code generator library.' ]!
openOn: anIcon
        "Open a PARTSIconEditor on anIcon."
    
    changeFlag := false.
    icon := anIcon.
    self
        createMasks;
        createView;
        openWindow.!   
initialize
        " Class initialization "

    | colors |
    colors := ( self
        partsIfOS2Do: [
            #( -1 -2 1 2 3 4 5 6 8 9 10 11 12 13 14 15 ) ]
        partsIfWindowsDo: [
            #(
                16r1000000 16r1000013 16r1000010 16r100000D
                16r100000E 16r1000011 16r1000012 16r100000F
                16r100000C 16r1000004 16r1000001 16r1000005
                16r1000002 16r1000006  16r1000003  16r1000007 ) ] ).
    self initializeColorDictionary: colors.! 
yItemLabel
        " Private "
    ^'Height:'!  
classInStream: readStream into: aBlock
        "Private - bind the library that is in readStream. Evaluate
        aBlock with the class contained in the library as the argument.
        Unbind the library."
    | fileName lib binder class newName prevNameSpace nameSpace toRename global |
    fileName := readStream file name.
    lib := SmalltalkLibraryBinder named: fileName.
    lib notNil ifTrue: [
        class := lib classes first.
        aBlock value: class.
        ^self ].
    CodeGenerationPrivateServices codeGenerator. "insures CG lib bound."
    binder := SmalltalkLibraryBinder new.
    prevNameSpace := binder globalNameSpace.
    toRename := Set new.
      [ binder stream: readStream.
        [ binder bind ] on: BindDuplicate do: [ :e |
            nameSpace := SystemDictionary new.
            nameSpace addAll: binder globalNameSpace.
            nameSpace privateRemoveKey: e name asSymbol ifAbsent: [].
            toRename add: e name asSymbol.
            binder globalNameSpace: nameSpace.
            e resume: e name ].
        toRename do: [ :symbol |
            newName := self deriveNameFrom: symbol.
            global := nameSpace at: symbol.
            global isClass
                ifTrue: [
                    global privateRename: newName in: nameSpace ]
                ifFalse: [
                    "a pool dictionary.  what to do?" ].
            Smalltalk at: newName put: global ].
        class := binder objectStore classes first.
        aBlock value: class ]
            ensure: [
                binder globalNameSpace: prevNameSpace.
                binder objectStore unBind ]!   
activeCatalogWindows
        " Answer all the active main windows of PARTS catalogs. "
    | catalogClass |
    catalogClass := self catalogClass.
    ^Notifier mainWindowsSelect: [ :window |
        window owner class == catalogClass ]!
supportsRepeatOperation
    "Private"
    ^false!   
globalVariableModel
    ^self classNamed: #CodeGenerationGlobalVariable! 
outputToSmalltalkLibrary
    ^self classNamed: #CodeGeneratorOutputToSmalltalkLIbrary!   
minBox
        "Private - Answer the minimum bounding box of the drag objects."
    ^minBox!
widthInDialogUnits: widthInPoints
		"Obsolete, should use horizontalDialogUnitsFromPixels:"
        " Private - answer widthInPoints as a width in
        in dialog box units, rounded up to the next
        character box boundary. "

    | charWidthPts nChars |
    charWidthPts := WindowDialog dialogUnit x.
    nChars := widthInPoints // charWidthPts.
    ( widthInPoints \\ charWidthPts ) > 0
        ifTrue: [ nChars := nChars + 1 ].
    ^nChars * WindowDialog charWidth!
aboutToSaveImage
        "Private - the image is about to be saved.
        Destroy the library map so it will be rebuilt
        when the image is started again."
    self destroyLibraryMap!   
hotSpotOffset
    "Private -Answer the offset from cursor's hot spot
	to the top left corner of the cursor."
    | hotSpot |

    hotSpot := 0 @ 0.
    cursor notNil
        ifTrue: [
			hotSpot := cursor hotSpot.
			self partsIfOS2Do: [
				hotSpot := hotSpot x @ ( PARTSIcon pointerSize y - hotSpot y )]].

    ^hotSpot!
logStream: aStream
		"Set the receiver's log stream."
	logStream := aStream!
setButton1Select
        " Private - make button1 be the select button. "

    self
        mouseButtonSelect: #button1;
        mouseButtonPopupMenu: #button2.!
listWidthDlg: aList
        " Private - answer the height in dialog units "

    | charWidth width |
    charWidth := WindowDialog charWidth.  " dialog units "
    width := 0.
    self font = SysFont
        ifTrue: [
            aList do: [ :el |
                width := width max: el size ].
            width := width * charWidth ]
        ifFalse: [
            aList do: [ :el |
                width := width max: (self font stringWidth: el ) ].
            width := self class widthInDialogUnits: width ].
    width := width + ( 5 * charWidth ).  " scroll bar special value "  " old: 4 "
    ^width!   
fill
        "Private - Fill aPoint and points adjacent to aPoint with
         fillColor. The adjacent points' color must be the same as
         aPoint's color."

    | aPoint |
    Notifier consumeInputUntil: [: event |
        event selector = #button1Up: ].
    CursorManager execute 
		changeFor: [
    		aPoint := Cursor sense mapToWindow: bitPen graphicsMedium.
    		( ( 0 @ 0 extent: bitPen graphicsMedium rectangle extent )
        		containsPoint: aPoint )
           			ifTrue: [ self fillAt: aPoint ].
			].!  
clearDropLocation
    "Private - Clear synchronous drop location"

    ^self source dropLocation: nil! 
sourceNeedsObject
        "Private - retrieve the drag drop object from the
        drag source."
        "Private - set aDragSession's collection of drag objects.
    Only the move session should needs its objects.  Other
    programaticaly initiated sessions should get their objects
    when initiated."
    | dragObjects aPart editor |

    editor := self editorPane partEditor.
    aPart := self editorPane windowContaining: self dragStart.
    ( aPart isPARTSApplication or:
        [ aPart == self or:
        [ aPart isNil ]])
            ifTrue: [ ^nil ].
    ( aPart partIsWindow and: [ aPart partIsDragable not ])
        ifTrue: [ ^nil ].
    dragObjects :=
        (( editor getVisibleObjectOf: aPart ) partIsSelected
            ifTrue: [ editor selectedComponents ]
            ifFalse: [ Array with: aPart ]).
    self createDragObjects: dragObjects.
    self objects isNil
        ifTrue: [ ^nil ].
    self editorPane stopEdit.  "Do this after verify that drag drop is taking place"! 
applicationFrom: aStream fileDescriptor: aFileDescriptor
            "Private - compile the code in aStream.  Answer a PARTS application.
            Remove the resulting class after the application has been
            built."
    ^self readStream: aStream fileDescriptor: aFileDescriptor!
iconAt: aPoint
        "Find the icon at aPoint.  Note if aPoint is on the label
        of an icon, answer the icon."
    icons isNil ifTrue: [ ^nil ].
    ^icons reversed
        detect: [:each | each containsPoint: aPoint ]
        ifNone: [ nil ]! 
deselectIcon: anIcon
    selectedIcons remove: anIcon.
    self updateIcon: anIcon! 
installBasicWorkbenchLibrary
        " Private - the basic workbench support library has just been installed.
        Initialize its contents to install into this image. "

    PARTSBitEditor initialize.!  
displayWindow
    self
        triggerEvent: #display
        ifNotHandled: [
            self refresh ]! 
suppressLoadMessages
        " Answer whether to suppress object load info
        messages during part file loading. "

    self isDeveloper
        ifFalse: [ ^true ].  " always suppress in workbench "
    ^self optionAt: #suppressLoadMessages ifAbsent: [ false ]!  
codeGeneratorClass
        "Private - answer the code generator class."

    ^self classNamed: #PARTSCodeGenerator!
setIcon: anIcon from: aFileStream fileName: fileName
        "Private - set the contents of anIcon from aFileStream."
    | icon |
    icon := self iconFrom: aFileStream.
    anIcon fromFileStream: ( ReadWriteStream on: icon stringRepresentation ).
    anIcon connection: icon connectionPrivate.
    anIcon connectionPrivate fileReference: fileName

!   
verticalDialogUnitsPerCharacter
    "Private - Answer the number of vertical 
    dialog units per character."

    ^8    "an OS constant"!   
button2Down: aPoint
    "Private - The right mouse button has been pressed at <aPoint>.
      Don't invoke	super.  Handle drag drop locally."

    self captureMouseInput.
    button2DownLoc := aPoint.!
outputToImage
    ^self classNamed: #CodeGeneratorOutputToImage! 
addAdjacentCells: cell to: queue with: cellMatrix
        "Private - Add adjacent cells to queue and record
         filled cell to cellMatrix."
    | adjacent extent |
    cell = (0 @ 0) ifTrue:[ ^ self].
    (cellMatrix at: cell x + 1) at: (cell y + 1) put: cell.
    adjacent := cell + (0 @ 1).
    extent := copy extent.
    (adjacent < extent and: [
        ((cellMatrix at: adjacent x + 1) at: adjacent y + 1) isNil])
            ifTrue: [queue add: adjacent].
    adjacent := cell - (1 @ 0).
    ((adjacent >= (0 @ 0) and: [adjacent < extent]) and: [
        ((cellMatrix at: adjacent x + 1) at: adjacent y + 1) isNil])
            ifTrue: [queue add: adjacent].
    adjacent := cell - (0 @ 1).
    ((adjacent >= (0 @ 0) and: [adjacent < extent]) and: [
        ((cellMatrix at: adjacent x + 1) at: adjacent y + 1) isNil])
            ifTrue: [queue add: adjacent].
    adjacent := cell + (1 @ 0).
    (adjacent < extent and: [
        ((cellMatrix at: adjacent x + 1) at: adjacent y + 1) isNil])
            ifTrue: [queue add: adjacent]!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system.  Upgrade application file
        reference representation from PWO 2.0. "

    fileDescriptor isString
        ifTrue: [ fileDescriptor := PARTSFileDescriptor pathName: fileDescriptor ].!  
showLinkLabels: aBoolean
        " Set the default showLinkLabels setting
        for the PARTS workbench. "

    showLinkLabels := aBoolean.
    PARTSEditor activeEditors do: [ :editor |
        editor updateShowLinkLabels: aBoolean ].!   
fileDescriptor: aFileDescriptor
        "Private - set the descriptor of the file that is being read or written."
    fileDescriptor := aFileDescriptor!
activated
        "Private - the receiver window has just been activated, update the
         edit menu."
    | editMenu |
    ( editMenu := self editMenu ) isNil
        ifTrue: [ ^self ].
    Clipboard containsBitmap
        ifTrue: [ editMenu enableItem: #editPaste ]
        ifFalse: [ editMenu disableItem: #editPaste ].
!  
showLinksWithSelection: aBoolean
        " Set the default showLinksWithSelection setting
        for the PARTS workbench. "

    showLinksWithSelection := aBoolean.
    PARTSEditor activeEditors do: [ :editor |
        editor updateShowLinksWithSelection: aBoolean ].!   
createOkCancelButtons: topPane deltaLeftTop: deltaLeftTop
        " Private - create a row of OK and Cancel buttons.
        Answer the extent consumed (dialog box units). "

    | buttonExtent marginDlg |
    buttonExtent := self extentForButton: 'Cancel'.
    marginDlg := WindowDialog charWidth.
    topPane addSubpane:
        (Button new
            defaultPushButton;
            setName: 'okButton';
            font: self font;
            contents: 'OK';
            when: #clicked send: #ok to: self ;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: buttonExtent)).
    topPane addSubpane:
        (Button new
            pushButton;
            setName: 'cancelButton';
            font: self font;
            contents: 'Cancel';
            when: #clicked send: #cancel to: self ;
            framingBlock: (self framingBlock:
                ((deltaLeftTop x + buttonExtent x + marginDlg)
                    @ deltaLeftTop y)
                extent: buttonExtent)).
    ^((2 * buttonExtent x) + marginDlg) @ buttonExtent y!  
fontDialogs
        " Answer the font to use for workbench dialogs. "

    ^fontDialogs!   
defaultFont
        " Private "

    ^PARTSSettings new fontLinkLabels!
operation: operationName
        "Set the operationName which specifies what would happen if the
        drag object were dropped right now at the current location
        and over the current target.  Operation for receiver is determined
        at when the drag session is initiated and remains in effect for the
        duration of the session."

    ( self target == self source  "Catalog move"
        or: [
            ( self target isPARTSCatalogPane
                and: [ Notifier isControlKeyDown not
                and: [ self continue ~= #drop ]])])  "If terminating drag loop, honor extended drag selection"
        ifTrue: [ ^super operation: #move ].

   ^super operation: operationName! 
dragButtonIndex
        "Private - answer the drag button index,
        or nil if not supported."

    ^nil! 
compoundOutput
    ^self classNamed: #CodeGeneratorCompoundOutput!   
catalogClass: aClass
        " Private "

    CatalogClass := aClass.! 
releaseCopy
        " Private - the window has closed. "
    copy release.! 
doDragDropAt: anEditorPanePoint button: anInteger
        "Private - begin a drag drop transfer.  The index of the mouse button
        that was used to initiate the drag is indicated by anInteger."
    | oldForeColor sourcePoint |

    sourcePoint :=
        anEditorPanePoint
            mapFromWindow: self editorPane
            to: source.
    prevScreenLocation :=
        anEditorPanePoint mapToScreen: self editorPane.

    pen := Display pen.
    oldForeColor := pen foreColor.
    pen
        foreColor: Color white;
        setClipRect: nil;   "ensures an empty clipping region for dragging"
        setLineWidth: 1;
        setForegroundMode: MixRuleXor;
        setLineType: LineTypeDot.  " originally used LinetypeAlternate on VOS"

    super doDragDropAt: sourcePoint button: anInteger.

    pen foreColor: oldForeColor!
readStream: aStream removeClass: aBoolean
            "Compile the code in aStream.  Answer a PARTS application.
            Remove the resulting class if aBoolean is true."
    ^self new readStream: aStream removeClass: aBoolean! 
ok
        "Private - record the new values and close the window. "
    | x y |
    x := xItem value.
    x isNil ifTrue: [ x := 0 ].
    y := yItem value.
    y isNil ifTrue: [ y := 0 ].
    ( self areValuesValidForX: x andY: y )
        ifFalse: [ ^self ].
    point := x @ y.
    self mainView close.!
icon: anIcon
    "Set the PARTSIcon associated with the receiver"

    self object: anIcon!
heightInDialogUnits: heightInPoints
		"Obsolete, should use verticalDialogUnitsFromPixels:"
        " Private - answer heightInPoints as a height in
        in dialog box units, rounded up to the next
        character box boundary. "

    | charHeightPts nLines |
    charHeightPts := WindowDialog dialogUnit y.
    nLines := heightInPoints // charHeightPts.
    ( heightInPoints \\ charHeightPts ) > 0
        ifTrue: [ nLines := nLines + 1 ].
    ^nLines * WindowDialog charHeight!   
targetLocation
        "Answer aPoint which is the current location of the cursor
        relative to the current target."

	^super targetLocation leftAndUp: self hotSpotOffset.!
partUpgradeTabInfoOS2: anObjectFiler
        " Private - upgrade the tab ordering and group leader info
        of a PW/OS2 2.0 application into the PW 3.0 representation.
        In PW/OS2 2.0, the tabstops and group leaders were
        kept in two OrderedCollection's.  In PW 3.0, each visual part
        itself knows if it is a tabstop or group leader. "

    | children |
    self partsVosOnly.  " Only used on VOS"

    " collect the subpanes which are at the top level of the app "
    children := self partChildren select: [ :child | child isSubPane ].
    children do: [ :child |
        child
            noTabStop;
            noGroupLeader ].

   " transfer tab stop/group info from property to the panes "
    ( property propertyAt: #PARTSTabStop ifAbsent: [ #() ] )
        do: [ :aPane | aPane tabStop ].
    property propertyAt: #PARTSTabStop put: nil.
    ( property propertyAt: #PARTSGroupLeaders ifAbsent: [ #() ] )
        do: [ :groupLeader | groupLeader startGroup ].
    property propertyAt: #PARTSGroupLeaders put: nil.

    "Long time ago, there was a case where a deleted child
    could remain in the orderedChildren dictionary.  Clean any
        remaining cases."
    self orderedChildren: ( self orderedChildren select: [ :child |
        children includes: child ] ).! 
selectSingleIcon: anIcon
        "Private - "
    | oldSelected |
    oldSelected := selectedIcons.
    selectedIcons := OrderedCollection with: anIcon.
    oldSelected do: [ :icon |
        self updateIcon: icon ].
    ( oldSelected includes: anIcon )
        ifFalse: [ self updateIcon: anIcon ]!
convertPointFromDeviceToWorld: aPoint
        " Private - platform dependent.  This method needs to convert aPoint
         from device to world coordinates. Since the receiver is not scrollable
         just answer aPoint."
    "VOS:
    ^graphicsTool convert: aPoint from: CvtcDevice to: CvtcWorld
    "
    ^aPoint   " VW "!
mouseButtonSelect
        " Answer the mouse button used for selection. "

    ^mouseButtonSelect! 
outputDirectoryName: aString
        "Set the name of the output directory, the directory
        to contain the .prs and .psx files."
    outputDirectoryName := aString! 
partGetExecutionContext
        "Answer the object which represents the execution context
        of the current process at this point.  Answer nil if this exception
        is not handled"
    ^PARTSGetExecutionContext signal contents!  
isDeveloper
        " Answer whether PARTS developer options are available. "

    ^SessionModel current isRunTime
        ifTrue: [ false ]
        ifFalse: [ isDeveloper ]!   
initializeMouseButtonsWindows
        " Set the mouse buttons to default Windows usage. "

    self
        mouseButtonLink: #button2;
        mouseButtonDrag: #button1;
        mouseButtonSelect: #button1;
        mouseButtonPopupMenu: #button2.!
aboutToClose: aTopPane
        " Private - the editor is about to be closed. "
    self changesHandled
        ifFalse: [aTopPane abortClose].!
creationExpressionClass
		"Answer the class of PARTS code generator creation expressions,
		those expressions whose generated source will create objects."

	^self classNamed: #PARTSCodeGeneratorCreationExpression! 
updateMouseButtons: settings
        " Reset the receiver's link color properties to the
        values in <settings>. "

    ( self equalMouseButtons: settings )
        ifTrue: [ ^self ].
    CursorManager execute changeFor: [
        self
            mouseButtonDrag: settings mouseButtonDrag;
            mouseButtonLink: settings mouseButtonLink;
            mouseButtonSelect: settings mouseButtonSelect;
            mouseButtonPopupMenu: settings mouseButtonPopupMenu;
            writeSettingsFile ].! 
write: anApplication on: aStream fileDescriptor: aFileDescriptor
        "Private - write anApplication on aStream.  aFileDescriptor
        is a kind of FileDescriptor."
    self new write: anApplication on: aStream fileDescriptor: aFileDescriptor!  
bindLibraryFor: aClassName
        "Private - bind the Smalltalk library that has been registered
        as containing the class named aClassName."
    | libraryName |
    libraryMap isNil ifTrue: [ self registerClasses ].
    libraryName := libraryMap
        at: aClassName
        ifAbsent: [ self error: aClassName, ' is not registered' ].
    SmalltalkLibraryBinder bindTo: libraryName!  
contents
        "Answer the contents of the receiver."
    ^contents!  
catalogClass
        " Private "

    ^CatalogClass!   
addIcon: anIcon
    "Private"
    | last origin |

    anIcon origin = (0 @ 0) ifTrue: [
        icons size < 1
            ifTrue: [
                origin := 10 @ ( self rectangle top down: 10 ).
                self partsIfOS2Do: [
                    origin := origin down: PARTSIcon iconSize y ].
                anIcon origin: origin ]
            ifFalse: [
                last := icons last.
                anIcon origin: (last origin down:
                    ("curFont height" 1 +
                    (last frameWithLabel: graphicsTool) height))]].
    self addIcon: anIcon at: anIcon origin!  
labelLineWidth
        " Answer the line width of a link label border. "

    ^1!  
CodeScraps
        " write a whole directory "
    (Smalltalk at: #PARTSCodeGeneratorWriterInterface) new
        inputDirectoryName: 'e:\p3o\oparout6';
        outputDirectoryName: 'e:\cg\oprsout1';
        writeDirectory!  
colorDictionary: aDictionary
		" Private "
	ColorDictionary := aDictionary.!
supportsRepeatOperation
    "Private"
    ^true!
invalidCursor
    "Answer the invalid drop target cursor."
    

    invalidCursor isNil
        ifTrue: [ self initCursors ].
    ^invalidCursor!  
doDragDropAt: anEditorPanePoint button: anInteger
        "Private - begin a drag drop transfer.  The index of the mouse button
        that was used to initiate the drag is indicated by anInteger.
        Don't cache executable applications,  because don't want to
        mirror copy them."
    | dragIcon |

    [ super doDragDropAt: anEditorPanePoint button: anInteger ]
        ensure: [
            ( self objects notNil
                and: [ ( dragIcon := self objects first icon ) connection notNil
                and: [ dragIcon connection isExecutable ]])
                ifTrue: [ dragIcon connectionPrivate clearObject ]]!  
warningWindows
        " Private - answer all windows containing application warning logs "

    ^Notifier mainWindowsSelect: [ :w |
        w owner class == PARTSTextWindow
        and: [ ( w propertyAt: #partsWarningLog ) notNil ] ]!  
eventsTriggered
        " Answer all the events which can be triggered
        by a PARTS Workbench editor. "

    ^self editorClass eventsTriggered! 
fileType
    "Answer the file type processed by the instance of the receiver."
    ^Array with: PARTSFileDescriptor fileTypeForSmalltalkLibraryFile!
propertiesFrom: aFileStream
        " Answer the properties stored on aFileStream. "
    | answer |
    self classInStream: aFileStream into: [ :class |
        answer := class application properties ].
    ^answer
!
catalogs: anArray
        " Set the list of catalogs to open with a workbench. "

    catalogs := anArray.!
optionAt: aSymbol put: aValue
        " Private - set the value of the option named aSymbol. "

    options isNil 
        ifTrue: [ options := IdentityDictionary new ].
    aValue isNil 
        ifTrue: [
            options removeKey: aSymbol ifAbsent: [].
            options isEmpty ifTrue: [ options := nil ].
            ^nil ].
    ^options at: aSymbol put: aValue!
wrapper
    "Answer the wrapper of the receiver's object"

    ^wrapper!   
colorCatalog: aColor
        " Set the background color for the PARTS catalog. "

    aColor = colorCatalog
        ifTrue: [ ^self ].
    colorCatalog := aColor.
    PARTSCatalog activeCatalogs do: [ :catalog |
        catalog updateBackgroundColor: colorCatalog ].!
targetDrawFrame
        "Private - draw the receiver's frame."!  
pixelsPerDialogUnit
    "Private - Answer a Point which is the number 
    of pixels per dialog unit."

    ^self pixelsPerHorizontalDialogUnit @ self pixelsPerVerticalDialogUnit!   
isDeveloper: aBoolean
        " Set whether PARTS developer options are available. "

    isDeveloper := aBoolean! 
hotSpotOffset
    "Answer the offset for the cursor"

    ^0 @ 0!  
lastEvent: aMessage upSelector: upSelector
        "Private - set the symbol which represents the last keyboard / mouse state
        change that occurred during a drag drop transfer to aSymbol."

    aMessage selector = #button1Up:
        ifTrue: [
            extended := self class extendedDragButtonIndex = 1.
            self lastEvent: #dragButtonUp.
            ^self ].

    aMessage selector = #button2Up:
        ifTrue: [
            extended := self class extendedDragButtonIndex = 2.
            self lastEvent: #dragButtonUp.
            ^self ].

    super lastEvent: aMessage upSelector: upSelector.! 
fileMenuCreate
        "Private - Answer the File menu."
    ^(PARTSFileMenu for: self)
        appendNewItem: #fileNew ;
        appendSeparator;
        appendOpenItem: #fileOpen ;
        appendSaveItem: #fileSave ;
        appendSaveAsItem: #fileSaveAs ;
        appendSeparator;
        appendExitItem: #fileExit ;
        yourself!   
iconFrom: aFileStream
        "Answer the icon stored on aFileStream.   The client must set the
        file name of the icon connection. "
    | icon connection appProperties |
    self classInStream: aFileStream into: [ :class |
        icon := class applicationIcon.
        appProperties := class application properties ].
    connection := PARTSCatalog catalogConnectionClass new.
    connection
        fileReference: nil
        helpFile: ( appProperties at: 'helpFile' ifAbsent: [ nil ] )
        helpTopic: ( appProperties at: 'helpTopic' ifAbsent: [ nil ] )
        hint: ( appProperties at: 'hint' ifAbsent: [ nil ] )
        mainObjectClass: ( appProperties at: 'mainObjectClass' ifAbsent: [ nil ] ).
    icon connection: connection.
    ^icon


! 
gridExtent: aPoint
        " Set the default grid setting for the PARTS workbench. "

    gridExtent := aPoint.
    PARTSEditor activeEditors do: [ :editor |
        editor updateGridExtent: gridExtent ].!
fontLinkLabels
        " Answer the font to use for link labels in a workbench. "

    ^fontLinkLabels!
sourceFeedback
        "Private - provide visual feedback for the current
        operation code ('move', 'copy', 'link', or nil), which
        indicates what would happen if a drop occurred
        over the current location (target) right now."
    | gridLoc cursorOffset parentLeftTop grid
        firstDragRect offset targetWindow |
    self editorPane scrolling ifTrue: [ ^self ].  "don't draw feedback if scrolling"
    grid := self editorPane partEditor gridExtent.
    firstDragRect := objects first dragRect.
    targetWindow := self target.
    cursor isNil  "Way of determining the start of the session"
        ifTrue: [
                "The initial window under point is the drag object.
                It is not the target."
            ( objects detect: [ :aDragObject | aDragObject object == targetWindow ]
                    ifNone: [ nil ]) notNil
                ifTrue: [ targetWindow := targetWindow superWindow ].
            prevObjectLocation := firstDragRect leftTop.
            self drawFrames: 0 ].
    super sourceFeedback.  "Set the cursor"

    targetWindow = prevTargetWindow
        ifFalse: [ "Determine the fence for the new target"
            parentRect := targetWindow freeClientArea mapToScreen: targetWindow.
            fence :=  targetWindow isPARTSEditorPane
                ifTrue: [ parentRect ]
                ifFalse: [
                    (( parentRect leftTop extentFromLeftTop:
                        (parentRect extent // grid * grid)) insetBy:  "align to grid"
                            (grid max: ( 8 @ 8 ) )) "leave at least a little bit"
                                expandBy: firstDragRect extent ].
            prevTargetWindow := targetWindow ].

    parentLeftTop := parentRect leftTop.

      "Offset between grid lines"
    cursorOffset := self screenLocation - prevScreenLocation.

      "Location of drag object on the grid"
    gridLoc :=
        ( prevObjectLocation + cursorOffset  - parentLeftTop / grid ) rounded * grid
            + parentLeftTop.

    "Fence the drag is the control and shift keys aren't down,
    or the target is the editor pane"
    ( initialOperation = #moveLocal or: [ targetWindow isPARTSEditorPane ])
        ifTrue: [ "fence the drag"
            gridLoc :=
                ( gridLoc rightMostAndLowest: fence leftTop ) leftMostAndHighest:
                    ( fence rightBottom leftAndUp: firstDragRect extent ) ].
    gridLoc = prevObjectLocation
        ifFalse: [ "Moved to another grid line"
            offset := gridLoc - prevObjectLocation.
            self drawFrames: 0.  "erase"
            self drawFrames: offset.  "draw"
            prevScreenLocation := prevScreenLocation + offset.
            prevObjectLocation := gridLoc ]!  
objectClass
        "Answer the class of drag drop objects an
        instance of the receiver will contain."
    ^PARTSEditorMoveObject!  
session: aDragSession
    "Set the session with which the receiver
    is associated."

    session := aDragSession!  
convertRect: aRectangle
        " Private - platform dependent.  Implemented
        only on VW to provide VOS compatibility. "
    ^aRectangle!   
outputPathName: aString
            "Set the output stream to receive the source
            code representation to be the file named
            by aString."
    self outputStream: ( File newFile: aString )!  
destinationRectangle: aRectangle
    destinationRectangle := aRectangle! 
refreshNoErase
    self refresh! 
fillAt: aPoint
        "Private - fill the icon with the selected color."
    | cells originalColor adjColor cell imagePoint cellMatrix |
    imagePoint := aPoint // scale.
    originalColor := copy pen getPixelColor: imagePoint.
    cells := OrderedCollection new: (copy width max: copy height) * 100.
    cells add: imagePoint.
    cellMatrix := Array new: copy width.
    1 to: cellMatrix size do: [: index |
        cellMatrix at: index put: (Array new: copy height)].
    [cells notEmpty] whileTrue: [
        cell := cells removeFirst.
        adjColor := copy pen getPixelColor: cell.
        adjColor = originalColor
            ifTrue: [
                self addAdjacentCells: cell to: cells with: cellMatrix.
                self changeBitAt: cell * scale]]!  
messageModel
    ^self classNamed: #CodeGenerationMessage!   
labelHeight
        " Answer the height of a link label. "

    ^labelHeight!  
initializeMouseButtonsOS2
        " Set the mouse buttons to default OS/2 usage. "

    self
        mouseButtonLink: #button1;
        mouseButtonDrag: #button2;
        mouseButtonSelect: #button1;
        mouseButtonPopupMenu: #button2.!   
drawFrames: offset
    "Draw the drag rectangles on the editor pane.  This has
    the side effect of offsetting the rectangles."
    | rect |

    objects do: [ :aDragObject |
        rect := aDragObject dragRect.
        rect moveBy: offset.
        pen
            place: rect leftBottom;
            goto: rect leftTop;
            goto: rect rightTop;
            goto: rect rightBottom;
            goto: rect leftBottom]! 
fileExit
    self changesHandled ifFalse: [^nil].
    self releaseCopy.
    self close!
output
    ^self classNamed: #CodeGeneratorOutput!   
initialize
        " Initialize class variables "

    self initializeCurrentClass.!   
isRepositoryComponentInstalled
        " Answer whether the Team/V repository component is installed "

    ^( ServiceRegistry globalRegistry
        serviceNamed: #RepositoryServices
        ifNone: [ nil ] )
            notNil!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system. "

    | loadContext |
    super fileInUpgrade: anObjectFiler.

    loadContext := anObjectFiler clientContext.
    loadContext isPARTSLoadContext not  " paste parts has no context "
        ifTrue: [ ^self ].

    loadContext fileVersion = 'LAF/VPM 2.0a'
        ifTrue: [  " PARTS Workbench for OS/2 2.0 app upgrade "
            " external event triggering from within a nested application changed in 3.0 "
            ( receiver isPARTSApplication
            and: [ realSelector = #relayLink:arguments: ] )
                ifTrue: [ realSelector := #triggerEvent:withArguments: ].
            ].

    loadContext fileVersion = 'LAF/VW 1.0a'
        ifTrue: [  " PARTS Workbench for Win32 beta 1 app upgrade "
            receiver isPARTSApplication
                ifTrue: [   " relay triggering changed late in PWW 2.0 "
                    realSelector = #triggerEvent:withArguments:
                        ifTrue: [ realSelector := #triggerInternalEvent:withArguments: ].
                    ( #( #relayLink:arguments: 
                            #triggerExternalEvent:withArguments:   
                            )
                            includes: realSelector )
                        ifTrue: [ realSelector := #triggerEvent:withArguments: ].
                    ].
            ].! 
initialize
    "Private - Initialize PARTSIconEditor"
    super initialize.
    scale := 8.
    mode := #color!   
targetDrop
        "Private - the dragged object was dropped over the current
        target at the current location. "
    | dropLocation |

    ( dropLocation := self dropLocation ) notNil "Get synchronous drop location"
        ifTrue: [
            self screenLocation: dropLocation.
            self target: self getTarget.
            self clearDropLocation. "For repeat drop" ].

    super targetDrop!   
createView
        " Private - create an icon editor window for icon.
        Answer the window. "
    | extent imageSize size gap topPane aGraphPane aGroupPane |
    extent := icon bitmap isNil
        ifTrue: [ PARTSIcon iconSize ]
        ifFalse: [ icon extent ].
    imageSize := extent min: (Display width - 80 // scale @
        (Display height - 20 // scale)).
    imageSize := imageSize * scale + ( 5 @ 5).
    size := 76 @ (300 max: imageSize y).
    gap := SysFont width.

    self addView:
        ((topPane := self topPaneClass new)
            owner: self;
            labelWithoutPrefix: self windowTitle;
            icon: PARTSEditor editorClass workbenchIcon;
            windowPolicy: NoMenusWindowPolicy new;
            when: #menuBarBuilt
                send: #createMenuBarMenus: to: self with: topPane;
            "when: #opened perform: #initPens:;   "
            when: #aboutToClose
                send: #aboutToClose: to: self with: topPane;
            when: #closed
                send: #releaseCopy to: self ).
    partWrapper notNil
        ifTrue: [
            topPane
                controller: partWrapper partEditor
                controllee: self].

    self addSubpane:
        ((aGraphPane := GraphPane new)
            owner: self;
            removeHorizontalScrollbarStyle;
            removeVerticalScrollbarStyle;
            when: #needsContents
                send: #initImagePen: to: self with: aGraphPane;
            when: #display
                send: #displayImage: to: self with: aGraphPane;
            framingBlock: [: box |
                box leftBottom extentFromLeftBottom:  (
                    box width * 2 // 7 @ (box height // 6 ))] ).

    self addSubpane:
        (aGroupPane := GroupPane new
            framingBlock: [: box |
                box leftTop extentFromLeftTop: (box width * 2 // 7 @
                    (box height * 5 // 6 ))] ).

    self addButtonGroup: aGroupPane.
    self addColorGroup: aGroupPane.

    self addSubpane:
         ((aGraphPane := GraphPane new)
            owner: self;
            removeHorizontalScrollbarStyle;
            removeVerticalScrollbarStyle;
            when: #needsContents
                send: #initBitPen: to: self with: aGraphPane;
            when: #display
                send: #displayBits: to: self with: aGraphPane;
            when: #button1Down
                send: #changeBit: to: self with: aGraphPane;
            when: #button1Moved
                send: #changeBit: to: self with: aGraphPane;
            framingBlock: [: box |
                (box leftTop rightAndDown: (box width * 2 // 7 @ 0))
                    rightBottom: box rightBottom] ).

    windowSize := 130 + imageSize x + 2 @
        (( 350 max: imageSize y) + SysFont height + 6).
    ^topPane!   
areValuesValidForX: x andY: y
        " Private - answer whether x and y are valid. "
    x <= 0
        ifTrue: [
            xItem selectAll; setFocus.
            MessageBox warning:
                'You must specify a positive integer value for ',
                self xItemLabel, '.'.
            ^false ].
    y <= 0
        ifTrue: [
            yItem selectAll; setFocus.
            MessageBox warning:
                'You must specify a positive integer value for ',
                self yItemLabel, '.'.
            ^false ].
    ^true!  
showHints: aBoolean
        " Set the default hints setting for the PARTS workbench. "

    showHints := aBoolean.
    PARTSEditor activeEditors do: [ :editor |
        editor updateShowHints: aBoolean ].!
mainOperation
    "Private"

    ^Array with: #paste with: 'Paste'!
registerClasses
        "Private - register all code generation classes as to in which
        Smalltalk library they are contained."
    | cgLibraryName |
    cgLibraryName := 'PWCCGN31'.
    #( #CodeGenerationLiteral
        #PARTSCodeGeneratorWriterInterface
        #CodeGenerationClass
        #CodeGenerationMessageExpression
        #CodeGenerationGlobalVariable
        #CodeGeneratorOutputToImageAnd
        #CodeGeneratorOutput
        #CodeGeneratorOutputToImage
        #CodeGeneratorChunkFileOutput
        #CodeGeneratorTextWindowOutput
        #CodeGeneratorSimpleOutput
        #CodeGenerationArgument
        #CodeGenerationMessage
        #PARTSSmalltalkLibraryFileProcessor
        #CodeGeneratorLibraryBuildingOutput
        #CodeGeneratorCompoundOutput
        #PARTSApplicationCoordinator
        #PARTSCodeGeneratorStream
        #CodeGenerationSelfPrimary
        #CodeGenerationSuperPrimary
        #CodeGenerator
        #CodeGeneratorOutputToSmalltalkLIbrary ) do: [ :className |
            self registerClass: className inLibrary: cgLibraryName ]!   
canMirrorCopy
    "Answer whether the receiver should mirror copy
    its objects when dropping them"

    ^true! 
removeIcon: anIcon
        "Remove anIcon from the receiver and update the display."
    icons := icons copyWithout: anIcon.
    selectedIcons := selectedIcons copyWithout: anIcon.
    self updateIcon: anIcon. "invalidate anIcon's rect even though it's not in the collection"
    anIcon release!  
smalltalkLibraryFileProcessor
    ^self classNamed: #PARTSSmalltalkLibraryFileProcessor! 
clearFonts
        " Private - clear the font settings "

    self fontDialogs: nil.
    self fontLinkLabels: nil.
    self fontIconLabels: nil.!

fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system.  Link edit state representation
        changed after PWO 2.0. "

    | oldEditStateArray pathPoints delta numCP app |

    editState isNil
        ifTrue: [  " not sure this is possible, but just in case... "
            editState := PARTSLinkEditState new.
            ^self ].

    editState isArray
        ifTrue: [
            oldEditStateArray := editState.
            editState := PARTSLinkEditState new
                launchSide: ( oldEditStateArray at: 2 );
                landingSide: ( oldEditStateArray at: 3 );
                leftTopEventLabel: ( oldEditStateArray at: 4 );
                leftTopMessageLabel: ( oldEditStateArray at: 5 );
                yourself.
            editState
                pathPoints: ( oldEditStateArray at: 1 )
                scaleUnit:
                    (( app := self partApplication ) notNil
                        ifTrue: [ app defaultScaleUnit ]
                        ifFalse: [ PARTSFramer defaultScaleUnit ])]
        ifFalse: [
            anObjectFiler objectVersion <= 10 "3.0 and before"
                ifTrue: [
                    "Make controlPoints relative to the first point, not the
                    preceding point.  Allows for less total rounding off
                    errors when converting scale units."
                    pathPoints := editState pathPointsAttribute.
                    ( numCP := self numberOfControlPoints ) > 0
                        ifTrue: [
                            delta := 0 @ 0.
                            self firstControlPointIndex to: pathPoints size - 1 do: [ :anIndex |
                                delta := delta + ( pathPoints at: anIndex ).
                                pathPoints at: anIndex put: delta ]].
                    "Convert from pixel storage to application scale unit storage"
                    self pathPoints: pathPoints ]].!  
changeIconLabel: anIcon to: newLabel
        " Change the name of anIcon to newLabel and display it.
        Answer the changed rectangle. "

    | iconOnlyRect totalRect oldLabelRect newLabelRect |

    handle isValid 
        ifFalse: [
            anIcon label: newLabel.
            ^self ].
    self doGraphics: [
        iconOnlyRect := anIcon visibleFrame.
        " erase the old icon label "
        anIcon showLabel
            ifTrue: [
                totalRect := anIcon frameWithLabel: graphicsTool.
                oldLabelRect := Rectangle
                    leftTop: (totalRect left @ iconOnlyRect bottom)
                    rightBottom: totalRect rightBottom.
                graphicsTool fill: oldLabelRect color: self backColor].
        " display the new icon label "
        anIcon label: newLabel.
        totalRect := anIcon frameWithLabel: graphicsTool.
        newLabelRect := Rectangle
            leftTop: (totalRect left @ iconOnlyRect bottom)
            rightBottom: totalRect rightBottom.
        anIcon displayLabel: graphicsTool.
        ].
    ^oldLabelRect isNil
        ifTrue: [ newLabelRect ]
        ifFalse: [ oldLabelRect merge: newLabelRect ]!
selectedItems
    ^selectedIcons!
verticalDialogUnitsFromPixels: anInteger
    "Answer the number of vertical
    dialog units for anInteger, rounded up."

    ^( anInteger / self pixelsPerVerticalDialogUnit ) rounded!  
labelFont: aFont
        " Set the label font and compute font-dependent
        layout values. "

    labelFont := aFont.
    labelFont notNil
        ifTrue: [ self computeLayoutParameters ].!  
COMMENT
"
PARTSCatalog provides the public protocol for opening
a PARTS catalog window.
"!
mouseButtonDrag: aSymbol
        " Specify the mouse button used for dragging parts. "

    mouseButtonDrag := aSymbol asSymbol.!  
mouseButtonLink: aSymbol
        " Specify the mouse button used for creating links. "

    mouseButtonLink := aSymbol asSymbol.!  
displayBackground
    graphicsTool 
        backColor: self backColor; 
        blank: ( 
			self partsIfOS2Do: [
				( 0 @ 0 extent: self extent ) deviceToLogical: graphicsTool ]
				partsIfWindowsDo: [ graphicsTool boundingBox ] )!   
setDragHandler: aSymbol execute: aBlock
        " Set the current drag handler to <aSymbol> for the duration
        of executing <aBlock>. "

    self currentDragHandler: aSymbol.
    aBlock ensure: [
        self currentDragHandler: nil ].!  
createDragObjects: objectCollection
    "<objectCollection> is a collection of raw objects
    that need to be stored in drag objects.
    Answer nil if could not create the objects"
    | dragObject |

    self objects:
        ( objectCollection collect: [ :each |
            ( dragObject := each asDragObjectFrom: self ) isNil
                ifTrue: [ ^nil ].
            dragObject ]).

    "Special check for dialogs that came up during object retrieval.
    If dialog required mouse capture to process button clicks, need
    to terminate the drag session"
    WindowHandle queryCapture = self source handle
        ifFalse: [^nil].! 
clear
        "Private - clear the bitmap."
    changeFlag := true.
    imagePen erase.
    bitPen erase.
    copy pen blank: copy boundingBox.
    self grid: scale!   
destinationRectangle
    ^destinationRectangle!  
operation
    ^#continue!
displaySelection
    selectedIcons notNil ifTrue: [
        selectedIcons do: [ :icon |
            self showIconSelected: icon ]]!
displayContents
    icons notNil ifTrue: [
        icons do: [ :icon | icon displayWith: graphicsTool ]]!   
COMMENT
"
A PARTSExpressionEntryField is used in the workbench
environment for single-line text items containing
an evaluatable PARTSTalk expression.
"! 
initializeFonts
        " Private - initialize the font settings "

    self fontDialogs: self defaultFontDialogs.
    self fontLinkLabels: self defaultFontLinkLabels.
    self fontIconLabels: self defaultFontIconLabels.!
clearAllCachedParts
        " Clear the catalog cache of all parts. "

    self activeCatalogs do: [ :aCatalog |
        aCatalog clearAllCachedParts ].! 
setColorBoxes
        "Private - Set the Pen/Fill color boxes with new colors."
    (self paneAt: 'penColor')
        backColor: bitColor;
        invalidateRect: nil.
    (self paneAt: 'fillColor')
        backColor: fillColor;
        invalidateRect: nil!  
editMenuCreate
        " Private - answer a new Edit menu. "
    | editMenu |
    editMenu := (PARTSEditMenu for: self)
        appendItem: '~Select'
            selector: #editSelect ;
        appendSeparator;
        appendCutItem: #editCut ;
        appendCopyItem: #editCopy ;
        appendPasteItem: #editPaste ;
        appendSeparator;
        appendClearItem: #clear ;
        appendSeparator;
        yourself.
    self editMenuFillItem: editMenu.
    editMenu
        disableItem: #editCut;
        disableItem: #editCopy;
        disableItem: #editPaste.
    ^editMenu!  
initialize
        "Private - Initialize the receiver."
    bitColor := fillColor := Color black.
    changeFlag := false.
    grid := true.
    scale := 8.
    super initialize!  
addIcon: anIcon at: destRect
        "Add anIcon at destRect which can be either
         a rectangle or a point."
    | origin |
    icons isNil
        ifTrue: [ icons := OrderedCollection new ].
    anIcon validate.
    destRect isRectangle
        ifTrue: [ origin := destRect origin ]
        ifFalse: [ origin := destRect ].
    anIcon
        origin: origin;
        parent: self.
    icons add: anIcon.
    self
        updateIcon: anIcon!
dataSlotRadius
        " Answer the radius of a data value shape in a link label. "

    ^dataSlotRadius!  
equalLinkColors: settings
        " Answer whether the receiver has the same
        link color settings as <settings>. "

    ^( colorWellDefinedBaseLink = settings colorWellDefinedBaseLink
    and: [ colorWellDefinedArgLink = settings colorWellDefinedArgLink
    and: [ colorUndefinedBaseLink = settings colorUndefinedBaseLink
    and: [ colorUndefinedArgLink = settings colorUndefinedArgLink ] ] ] )!
horizontalDialogBaseUnit
    "Private - Answer the host dialog base unit."

    self 
        partsIfOS2Do: [ ^SysFont width ] 
        partsIfWindowsDo: [ ^PARTSHostInterface hostWindowLibrary getDialogBaseUnits \\ 16r10000 ]!  
defaultGridExtent
        " Answer the default grid extent setting "

    ^1 @ 1!  
object: anObject
        "Set the object associated with the receiver.
    It is either a window or an icon."

    object := anObject!
gridExtent
        " Answer the default grid setting for the PARTS workbench. "

    ^gridExtent!  
displayBits: graphPane
        "Private - Display icon image in bits graphics pane"
    bitPen := graphPane pen.
    bitPen erase.
    bitPen copyBitmap: copy
        from: copy boundingBox
        to: (copy boundingBox scaleBy: scale).
    self grid: scale! 
colorUndefinedArgLink
        " Answer the color for an argument link which isn't fully defined. "

    ^colorUndefinedArgLink!
labelInteriorIndent
        " Answer the interior indent within a link label. "

    ^1!   
loadSettings
        " Load the workbench settings from the INI file. "

    PARTSIniFile loadSettingsFrom: fileName into: self.!  
fileInUpgradeCompletion: anObjectFiler
        " Private - finish upgrading a PWW 2.0 file descriptor. "

    | upgradeDirectory |
    "self ASSERT: directory class = Directory."
    upgradeDirectory := directory.
    directory := directory asPARTSDirectory.
    anObjectFiler registerUpgradeMutationFrom: upgradeDirectory to: directory.! 
defaultFontLinkLabels
        " Answer font to use for container labels and link icons and such. "

   NationalLanguage isDoubleByteCp ifTrue: [ ^SysFont ].

    self
        partsIfOS2Do: [
            ^Font
                face: 'Helv'
                size: 5@13
                fixedWidth: false ]
        partsIfWindowsDo: [
            ^self defaultFontIconLabels ].
    self error: 'unknown platform'!  
source: anEditorPane
        "Private - Create an instance of the receiver.
    The source is the move object(s)'s containing
    window."
    | session screenPoint source nestedPart |

    screenPoint := anEditorPane dragStart mapToScreen: anEditorPane.
    session :=
        self new
            editorPane: anEditorPane;
            screenLocation: screenPoint;
            yourself.
    ( source :=
        session
            getMoveTargetAt: screenPoint
            editorPane: anEditorPane ) isNil
        ifTrue: [ ^nil ].  "Started in a crack between windows"

    self partsIfOS2Do: [
        source isFrameWindow
            ifTrue: [  "Check grabbed title bar of window in a nested part"
                source := source child.
                ( nestedPart := source partContainingNestedPart ) notNil
                    ifTrue: [ source := nestedPart ]]].

    source isPARTSEditorPane
        ifFalse: [
            [ source partIsSelectable ]
                whileFalse: [ source := source superWindow ].
            source := source superWindow ].

    session source: source.
    ^session!   
targetOver
        "Private - the mouse moved within the bounds of the
    current target during a drag drop transfer.  If the target is
    nil, just came from non-Smalltalk area and the receiver
    didn't realize the cursor had left.  Force a target enter."

    self target isNil
        ifTrue: [
            self target: self getTarget.
            self target isNil
                ifTrue: [ ^self ].
            self targetEnter ].

    self target partDragTargetOver: self!   
classInStream: aStream
         "Compile the code in aStream.  Answer the resultant class.
        This method is the focal point for CG source file reading."
    | class |
    inputStream := aStream.
    PARTSCodeGeneratorInterface partCreatorClass buildRootNamingDictionary.
    self setInputDirectoryForStream: inputStream.
    self partSetExecutionContextFor: [
        class := PARTSCodeGeneratorInterface codeGeneratorReaderClass
            classInStream: inputStream ].
    class isClass ifTrue: [
        class pathName: self inputPathName ].
    PARTSCodeGeneratorInterface partCreatorClass clearNamingDictionary.
         "don't carry the naming dictionary in image."
    ^class!  
updateLinkColors: settings
        " Reset the receiver's link color properties to the
        values in <settings>. "

    ( self equalLinkColors: settings )
        ifTrue: [ ^self] .
    CursorManager execute changeFor: [
        self
            colorWellDefinedBaseLink: settings colorWellDefinedBaseLink;
            colorWellDefinedArgLink: settings colorWellDefinedArgLink;
            colorUndefinedBaseLink: settings colorUndefinedBaseLink;
            colorUndefinedArgLink: settings colorUndefinedArgLink;
            writeSettingsFile.
        PARTSEditor activeEditors do: [ :editor |
            editor refreshLinks ].
        ].!  
getTarget
        "Private - answer the window under the mouse.
    If the cursor leaves the editor pane, still answer the
    previous target."
    | oldTarget newTarget |

    oldTarget := self target.

    ( initialOperation = #copy or: [ initialOperation = #moveGlobal ])
        ifTrue: [ "Can change parents.  Move objects can't be targets"
            ( newTarget := super getTarget ) isNil
                ifTrue: [
                    "Cursor leaving editor pane.  Answer the last valid target."
                    ^self target ].
            ( self objects detect: [ :aDragObject |
                aDragObject object == newTarget ] ifNone: [ nil ]) notNil
                    ifTrue: [ "Same parent"
                        newTarget := oldTarget ]]
        ifFalse: [ "Stay in same window"
            newTarget := oldTarget ].

    ^newTarget! 
createView
        " Private - build the window. "
    | charSize entryHeight font topPane |

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.
    font := self font.

    self addView: ((topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: self title;
        yourself ).

    topPane addSubpane:
        (StaticText new
            font: font;
            contents: self xItemLabel;
            framingBlock: [:box |
                (box leftTop rightAndDown: ((2 @ 1) * charSize))
                    extentFromLeftTop: ((12 @ 1) * charSize)] ).
    topPane addSubpane:
        (xItem := PARTSIntegerEntryFieldPart new
            value: point x;
            framingBlock: [: box |
                (box leftTop rightAndDown: ((15 @ 1) * charSize))
                    extentFromLeftTop: (5 * charSize x @ entryHeight)]).

    topPane addSubpane:
        (StaticText new
            font: font;
            contents: self yItemLabel;
            framingBlock: [:box |
                (box leftTop rightAndDown: ((2 @ 3) * charSize))
                    extentFromLeftTop: ((10 @ 1) * charSize)]).

    topPane addSubpane:
        (yItem := PARTSIntegerEntryFieldPart new
            value: point y;
            framingBlock: [: box |
                (box leftTop rightAndDown: ((15 @ 3) * charSize))
                    extentFromLeftTop: (5 * charSize x @ entryHeight)]).

    topPane addSubpane:
        (Button new defaultPushButton;
            font: font;
            contents: 'OK';
            when: #clicked send: #ok to: self;
            framingBlock: [:box |
                (box leftTop rightAndDown: ((2 @ 5) * charSize))
                    extentFromLeftTop: 35 @ entryHeight]).

    topPane addSubpane:
        (Button new
            font: font;
            contents: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [:box |
                (box leftTop rightAndDown: ((11 @ 5) * charSize))
                    extentFromLeftTop: 35 @ entryHeight]).!   
accept
        "Private - Save the changes to the original icon and its
         associated file."
    self applyChanges.
    fileName notNil ifTrue: [
        icon outputToFile: fileName]!
lastEvent: aMessage upSelector: upSelector
        "Private - set the symbol which represents the last keyboard / mouse state
        change that occurred during a drag drop transfer to aSymbol."

    aMessage selector == upSelector
        ifTrue: [
            self lastEvent: #dragButtonUp.
            ^self ].

    super lastEvent: aMessage upSelector: upSelector.!   
fontIconLabels
        " Answer the font to use for icon labels in a workbench. "

    ^fontIconLabels!
objectClass
        "Answer the class of drag drop objects an
        instance of the receiver will contain."

    ^PARTSPasteObject! 
openOnFile: aFileName
        " Open an edit window on the PARTS file
        named aFileName on the PARTS search path."

    | app |
    [ app := PARTSFile applicationFromFile: aFileName ]  " get editable app "
        on: PARTSApplicationLoadError
        do: [ :e | e postMessageBox. ^nil ].
    app isNil
        ifTrue: [ ^nil ]. "Backstop: should raise error"
    self editorClass new openOn: app.
    ( Message
        receiver: self
        selector: #surfaceWarningsForFile:
        arguments: ( Array with: aFileName ) )
            performDeferred.!   
chunkFileOutput
    ^self classNamed: #CodeGeneratorChunkFileOutput! 
fileInUpgraded: anObjectFiler
       " Private - finish upgrading a PW 2.0 application.
       Install application-wide changes here.  This is done
       at the end of the upgrade cycle so that any of the
       application's component parts which need to mutate
       during their own upgrade have finished fixing themselves. "

	self partsIfOS2Do: [ self fileInUpgradedOS2: anObjectFiler ].!
getTargetBasic
        "Private - answer the window under the mouse."
    ^Window partWindowUnderPointNoGroupBox: 
		( self screenLocation leftAndUp: self hotSpotOffset ).!   
button1Down: aPoint
        "Private - left button was pressed.  Don't invoke
	super.  Handle drag drop locally."

    button1DownLoc := aPoint.
    self captureMouseInput.!
colorLinkLabel: aColor
        " Set the background color for link labels. "

    colorLinkLabel := aColor!
entryPointReferenceClass
		"Answer the class of PARTS code generator entry point references,
		those references that refer to expressions whose generated
		source will be placed in it's own separate method."

	^self classNamed: #PARTSCodeGeneratorEntryPointReference!  
open
        "Private - Open the subpane."
    self font isNil ifTrue: [ self font: self defaultFont ].
    children size ~= 0
        ifTrue: 
            [
            children do: 
                [ :each | each open ]
            ]!  
superPrimaryModel
    ^self classNamed: #CodeGenerationSuperPrimary! 
targetDrop
        "Private - the dragged object was dropped over the current
        target at the current location."! 
deletedWrappers: aCollection
       " Notification from controlling editor that
        parts have been deleted. "
    (aCollection includes: partWrapper)
        ifTrue: [self close].! 
openOn: aNestedApplication update: aNestedPart
        " Open an editor on the packaged PARTS application
        in a nested part. "

    self editorClass new
        openOn: aNestedApplication
        update: aNestedPart! 
accept
        "Private - Save the changes to the original bitmap and its
         associated file."
    self applyChanges.
    fileName notNil ifTrue: [
        copy outputToFile: fileName]!  
openOn: aBitmap clipRect: aRect
        "Open a BitEditor on aBitmap.
          PARTSBitEditor new open"
    original := aBitmap.
    self
        createViewFor: aBitmap clipRect: aRect;
        openWindow.! 
keepInExecutable: aBoolean
    "Set whether wrappers should be included in
    executable applications"

    ^PARTSWrapper keepInExecutable: aBoolean
!  
verticalDialogBaseUnit
    "Private - Answer the host dialog base unit."

    self 
        partsIfOS2Do: [ ^SysFont height ] 
        partsIfWindowsDo: [ ^PARTSHostInterface hostWindowLibrary getDialogBaseUnits // 16r10000 ]!   
equalMouseButtons: settings
        " Answer whether the receiver has the same
        mouse button settings as <settings>. "

    ^( mouseButtonDrag = settings mouseButtonDrag
    and: [ mouseButtonLink = settings mouseButtonLink
    and: [ mouseButtonSelect = settings mouseButtonSelect
    and: [ mouseButtonPopupMenu = settings mouseButtonPopupMenu ] ] ] )!  
dragButtonIndex
        "Private - answer the drag button index,
        or nil if not supported."

    ^self userDragButtonIndex!
labelLineHeight
        " Answer the height of a text label within a link label. "

    ^labelLineHeight!  
libraryBuildingOutput
    ^self classNamed: #CodeGeneratorLibraryBuildingOutput! 
hideSelection
        "Private - Hide the selected rectangle."
    selection isNil ifTrue: [^self].
    bitPen 
        foreColor: Color white;
        setForegroundMode: MixRuleXor;
        place: selection leftTop * scale;
        box: ((selection rightBottom * scale) rightAndUp: 1 @ 1);
        foreColor: bitColor;
        setForegroundMode: MixRuleDefault.!  
readStream: aStream removeClass: aBoolean
        "Compile the code in aStream.  Answer a PARTS application.
        Remove the resulting class if aBoolean is true."
    | class app |
    inputStream := aStream.
    PARTSCodeGeneratorInterface partCreatorClass buildRootNamingDictionary.
    self setInputDirectoryForStream: aStream.
    self partSetExecutionContextFor: [
        class := self classInStream: aStream.
        class isNil ifTrue: [ ^nil ].
        app := class application.
        aBoolean ifTrue: [ class removeFromSystem: false ]].
    PARTSCodeGeneratorInterface partCreatorClass clearNamingDictionary. "Remove it, don't carry in image."
    ^app! 
initCursors: anIcon
    "Private - Set the cursors for the receiver's feedback.
    Set the hot spot as the cursor position relative to the
    icon's hot spot."
    | hotSpot |

    hotSpot := self dragStart - anIcon origin.
    validCursor := anIcon asPointerWithHotSpotAndMark: hotSpot.
    invalidCursor := anIcon asPointerWithStopSign: hotSpot.!
targetLocation
        "Answer the receiver's location in target coordinates."
    | location |

    location := self session targetLocation.
    self partsIfOS2Do: [ location := location down: PARTSIcon pointerSize y ].
    ^location! 
close
        "Private - Close the receiver and destroy the device context."
    icons size > 0 ifTrue: [
        icons do: [:icon | icon release ]].   "[11/3/94 MT] otherwise parts app won't be garbage collected"
    ^super close!   
trackRect: aRectangle
        "Private - Let the user drag aRectangle to a
         selected location. Answer the new rectangle."
    | center box  offset lastCursor lastLoc newLoc
      oldCorner newCorner w oldRect newRect penWidth |

    box := aRectangle.
    center := bitPen boundingBox center // scale.
    oldRect := Rectangle leftTop: (center leftAndUp: (box extent  // 2))
        rightBottom: (center rightAndDown: (box extent  // 2)).
    penWidth := bitPen lineWidth.
    bitPen
        setLineWidth: 1;
        foreColor: Color white;
        setForegroundMode: MixRuleXor;
        place: oldRect leftTop * scale;
        box: ((oldRect rightBottom * scale) rightAndUp: 1 @ 1).

    w := bitPen graphicsMedium.
    w captureMouseInput.
    Notifier consumeInputUntil: [: event |
        event selector = #button1Down:
            ifTrue: [
                lastLoc := oldRect leftTop.
                lastCursor := w cursorWindowPosition // scale.
                offset := lastCursor - lastLoc].
        event selector = #button1Move:
            ifTrue: [
                newLoc := w cursorWindowPosition // scale - offset.
                oldCorner := lastLoc rightAndDown: oldRect extent.
                newCorner := newLoc rightAndDown: oldRect extent.
                newLoc = lastLoc ifFalse: [
                    bitPen place: lastLoc * scale;
                        box: (oldCorner * scale rightAndUp: 1 @ 1);
                        place: newLoc * scale;
                        box: (newCorner * scale rightAndUp: 1 @ 1).
                    lastLoc := newLoc]].
        event selector = #button1Up:
            ifTrue: [
                newLoc isNil
                    ifTrue: [   " no mouse move between button-down and button-up events "
                        newLoc := lastLoc.
                        newCorner := newLoc rightAndDown: oldRect extent ].
                bitPen place: newLoc * scale; box: (newCorner * scale rightAndUp: 1 @ 1).
                w clearMouseCapture].
        event selector = #button1Up:].
    bitPen
        setForegroundMode: MixRuleDefault;
        setLineWidth: penWidth;
        foreColor: bitColor.
     newRect := Rectangle leftTop: newLoc
        rightBottom: newCorner.
    ^newRect!
showLinkLabels
        " Answer the default showLinkLabels setting
        for the PARTS workbench. "

    ^showLinkLabels!   
colorWellDefinedArgLink
        " Answer the color for an argument link which is fully defined. "

    ^colorWellDefinedArgLink!   
initialize
        " Private - initialize the receiver.
            PARTSSettings initialize
        "

    self current: self new!  
isPARTSDragDropSession
    "Answer whether the drag drop session
    is an instance of the receiver"

    ^true!  
horizontalDialogUnitsFromCharacters: anInteger
    "Answer the number of horizontal
    dialog units for anInteger characters."

    ^anInteger * self horizontalDialogUnitsPerCharacter! 
fillAt: aPoint
        " Private - fill the bitmap with the selected color
          starting at aPoint. "
    |  originalColor imagePoint oldBackColor |
    imagePoint := aPoint // scale.
    originalColor := copy pen getPixelColor: imagePoint.
    oldBackColor := copy pen backColor.
    copy pen backColor: fillColor.
    copy pen floodFill: imagePoint color: originalColor fillType: FloodFillSurface.
    copy pen backColor: oldBackColor.
    self displayImage: imagePen graphicsMedium.
    self displayBits: bitPen graphicsMedium.
    changeFlag := true!   
updateIcon: anIcon
    self realInvalidateRect: anIcon boundingBox!  
sourceFeedback
        "Private - provide visual feedback for the current
        operation code ('move', 'copy', 'link', or nil), which
        indicates what would happen if a drop occurred
        over the current location (target) right now."

    self target partEditor notNil
        ifTrue: [ cursor := self validCursor]
        ifFalse: [ cursor := self invalidCursor].
    cursor = Cursor ifFalse: [ cursor change ]!
isDragTarget
    ^true!  
optionsGrid
        "Toggle the grid mode."
    grid := grid not.
    grid
        ifTrue: [
            self grid: scale.
            self optionsMenu checkItem: #optionsGrid]
        ifFalse: [
            bitPen erase.
            self displayBits: bitPen graphicsMedium.
            self optionsMenu uncheckItem: #optionsGrid]! 
graphicsToolClass
        "Private - Answer the graphics tool class used by the receiver."
    ^Pen!
codeGeneratorStream
    ^self classNamed: #PARTSCodeGeneratorStream! 
dialogUnitsFromPixels: aDimension
    "Answer the number of dialog units
    for aDimension, which can be a point or a rectangle."

    | divisor |
    divisor := self pixelsPerDialogUnit. 
    ^aDimension isRectangle
        ifFalse: [ ( aDimension / divisor ) rounded ] 
        ifTrue: [
            aDimension class
                leftTop: ( aDimension leftTop / divisor ) rounded 
                rightBottom: ( aDimension rightBottom / divisor ) rounded ].!   
optionsPenSizeMenuCreate
        "Private - answer a new pen size menu."
    | menu |
    menu := PARTSStandardMenu
        labels: '1 x 1\2 x 2\3 x 3\4 x 4\5 x 5\6 x 6\7 x 7\8 x 8' withCrs
        selectors: #(1 2 3 4 5 6 7 8).
    menu
        owner: self;
        title: self optionsPenSizeMenuTitle;
        selector: #penSize: ;
        checkItem: '1 x 1';
        yourself.
    ^menu!
dragButton
    "Private - answer the button used to drag."

	^self
		partsIfOS2Do: [ PARTSHostInterface dragButtonOS2 ]
		partsIfWindowsDo: [ 
			PARTSSessionManager isWorkbenchSession
				ifTrue: [ (Smalltalk at: #PARTSSettings) current mouseButtonDrag ]
				ifFalse: [ #button1 ] ]!  
isDragSource
    ^true!  
horizontalDialogUnitsFromPixels: anInteger
    "Answer the number of horizontal
    dialog units for anInteger, rounded up."

    ^( anInteger / self pixelsPerHorizontalDialogUnit ) rounded!
getExtendedOperation
        "Private - an extended drag-drop just completed, so popUp a context menu
        containing available operations to determine the drop operation."
    "Editor recaptures mouse, interferring with
        extended operation popup menu."
    self partsIfOS2Do: [ self source clearMouseCapture ].

    ^super getExtendedOperation!
sourceLocation
        "Answer aPoint which is the current location of the cursor
        relative to the screen."
    ^self screenLocation mapToWindow: source!   
argumentModel
    ^self classNamed: #CodeGenerationArgument!