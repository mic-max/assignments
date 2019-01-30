3.1.0.106
   
cloneAsExe
        "Create an icon for saving in the exe. The icon
         must be 32x32, 4 bits/pixel."
    | exeIcon exeColorBitmap exeBitmap |

    self partsIfWindowsDo: [ ^self clone ].
    exeColorBitmap := Bitmap new.
    exeColorBitmap width: 32
        height: 32
        planes: 1
        bitCount: 4.
    exeColorBitmap pen
        copyBitmap: self colorBitmap
        from: self colorBitmap boundingBox
        to: exeColorBitmap boundingBox.
    exeBitmap := Bitmap extent: 32 @ 64.
    exeBitmap pen
        copyBitmap: self bitmap
        from: self bitmap boundingBox
        to: exeBitmap boundingBox.
    exeIcon := PARTSIcon new.
    exeIcon
        colorBitmap: exeColorBitmap;
        bitmap: exeBitmap.
    ^exeIcon!   
openFile: defaultFileName
        "Private - Open an Open File dialog with the defaultFileName "
    | aPathName |
    aPathName := (super openFile: defaultFileName) file.
    closedAction evaluateWithArguments: (Array with: aPathName).
    ^aPathName! 
label: aString
        "Specify the label of the icon."

    label := aString.!
pointerSize
        "Answer system pointer size."

    ^( OperatingSystem getSystemValue: SystemValueCursorWidth )
        @ ( OperatingSystem getSystemValue: SystemValueCursorHeight )! 
buttonValues: anArray
        " Specify the result value to be assigned, according
        to which button is used to close the dialog.  The answer
        is a PARTSException if the dialog is cancelled. "
    buttonValues := anArray.!   
transparent
        " Private - Initialize a transparent icon "
    self
        partsIfOS2Do: [
            self
                bitmap: ( Bitmap width: 32 height: 64 );
                colorBitmap: ( Bitmap screenWidth: 32 height: 32 ) .
            self bitmap pen
                fill: ( 0 @ 0 extent: 32 @ 32 ) rule: CopyRuleBlack;     "XOR mask"
                fill: ( 0 @ 32 extent: 32 @ 32 ) rule: CopyRuleWhite.   "AND mask"
            self colorBitmap pen
                fill: ( 0 @ 0 extent: 32 @ 32 ) rule: CopyRuleBlack ]
        partsIfWindowsDo: [
            self
                xorMask: ( Bitmap width: 32 height: 32 planes: 1 bitCount: 4 );
                andMask: ( Bitmap width: 32 height: 32 ).
            self xorMask pen
                fill: self xorMask boundingBox
                rule: CopyRuleBlack.
            self andMask pen
               fill: self andMask boundingBox
               rule:  CopyRuleWhite ]!  
superWindow
        "Answer the receiver's non-frame parent window."

    ^parent! 
asPointerWithHotSpot: aPoint
        "Answer a host pointer with the same image
         as the receiver and aPoint as its hot spot."

    ^self asPointerWithHotSpot: aPoint
        using: ( self pointerHandle: aPoint )! 
fromStringRepresentation: aString
        "Private - Answer an instance of the receiver represented in aString."
    ^self fromFileStream: ( ReadWriteStream on: aString )! 
closeView
        "Close the receiver and all its children."
    super closeView.
    ( Smalltalk at: #PARTSSessionManager ifAbsent: [ ^self ] ) exitIfLastWindow.!
partRedoDirectEdit: newLabel
        "Redo a direct edit operation on the receiver."
    self setLabel: newLabel.!  
displayWith: aPen
        "Display the icon with aPen."
    self displayAt: origin with: aPen.! 
getCursorWithStopSign: hotSpot
        "Create a PM pointer. Answer its handle"
    ^self
        partsIfOS2Do: [ self getCursorWithStopSignOS2: hotSpot ]
        partsIfWindowsDo: [ self getCursorWithStopSignWindows: hotSpot ]!  
transparent
        " Answer a transparent icon "
    ^self new transparent!
partFrame
        "Answer the Rectangle containing the icon."
    ^self visibleFrame!   
initialize
        "Private - initialize receiver."

    super initialize.
    origin := 0@0.
    showLabel := false.
    self
        partsIfOS2Do: [ self archive: nil ]
        partsIfWindowsDo: [ self readOnly: false ].!   
isPARTSException
        "Answer whether the receiver is a kind of PARTSException."
    ^true!  
labelFrame
        "Answer the framing rectangle of the receiver's label."

    | aPen iconRectangle labelWidth labelHeight |
    ( label isNil or: [ showLabel not ] )
        ifTrue: [ ^nil ].
    aPen := parent pen.
    iconRectangle := self visibleFrame.
    labelWidth := aPen stringWidthOf: label.
    labelHeight := aPen font height * 3 // 2.
    ^( ( iconRectangle center x left: ( labelWidth // 2 ) )
            @ iconRectangle bottom )
        extentFromLeftTop: labelWidth @ labelHeight!
boundingBox
        "Answer the system rectangle containing the icon."
    ^self visibleFrame!  
leftTop
    "Private - Answer the left top coordinate of the receiver in pixels."
    ^self
        partsIfOS2Do: [ origin x @ ( origin y up: self extent y )]
        partsIfWindowsDo: [ origin ]

!  
closedAction: anAction
        " Specify the action to be evaluated with the
        result when the dialog is closed.  The answer
        is a PARTSException if the dialog is cancelled. "
    closedAction := anAction.!   
connection
        "Answer the connected object.  If the object is a delayed
        load object, load it first."

   ^connection isPARTSCatalogIconConnection
        ifTrue: [ connection loadObject ]
        ifFalse: [ connection ]!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>, leaving bitmaps alone.
        Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
    aMirrorCopyDictionary forExecute
        ifTrue: [ "For runtime optimization don't copy nonvisual part icons"
            connection isPARTSNonvisualPart
                ifTrue: [ ^copy ] ].
    self
        partsIfOS2Do: [
            copy
                bitmap: ( self bitmap partMirrorCopy: aMirrorCopyDictionary );
                colorBitmap: ( self colorBitmap partMirrorCopy: aMirrorCopyDictionary ) ]
        partsIfWindowsDo: [
            copy
                andMask: ( self andMask partMirrorCopy:  aMirrorCopyDictionary );
                xorMask: ( self xorMask partMirrorCopy: aMirrorCopyDictionary ) ].
    copy
        connection: (connection partMirrorCopy: aMirrorCopyDictionary);
        showLabel: showLabel;
        label: label;
        origin: origin copy;
        parent: ( parent partMirrorCopy: aMirrorCopyDictionary ).
    ^copy!
hotSpot: aPoint
        "Set the receiver's hot spot to aPoint."
    hotSpot := aPoint! 
asPointerWithHotSpotAndMark: aPoint
        "Answer a host pointer with the same image
         as the receiver and aPoint as its hot spot."

    ^self asPointerWithHotSpot: aPoint
        using: ( self getCursorWithMark: aPoint )!  
displayAt: aPoint with: aPen
        "Display the icon with aPen."
	super displayAt: aPoint with: aPen.
    showLabel ifTrue: [
        self displayLabel: aPen]! 
asPointer
    ^self asPointerWithHotSpot:
            (0@0 extent: self visibleExtent) leftTop! 
showLabel
        " Answer whether the receiver is displayed with a label. "

    ^showLabel!  
labelContainsPoint: aPoint
        " Answer whether <aPoint> is falls within the
        receiver's icon label. "

    | labelFrame |
    labelFrame := self labelFrame.
    ^labelFrame notNil
        and: [ labelFrame containsPoint: aPoint ]! 
fromString: aString
    | bitmap colorBitmap aPen extent label y |
    self partsVosOnly.
    extent := self iconSize.
    bitmap := Bitmap new extent: extent x @ (extent y * 2).
    bitmap pen fill: bitmap boundingBox
        rule: 0.
    colorBitmap := Bitmap screenExtent: extent.
    aString size = 0
        ifTrue: [label := String new]
        ifFalse: [
            label := String with: (aString at: 1).
            aString size > 1
                ifTrue: [
                    label := label,
                        ((aString copyFrom: 2 to: aString size)
                            select: [:i | i isVowel not])]].
    y := extent y.
    (aPen := colorBitmap pen)
        "color: ClrBlack;"
        setLineWidth: 3;
        place: 0 @ 0;
        boxOfSize:  extent;
        displayText: label at:
                (2 @ (y // 2 - (aPen font height // 2) + aPen font descender) ).
    ^ self new
        bitmap: bitmap;
        colorBitmap: colorBitmap;
        label: aString;
        createIcon! 
allowWorkbenchToBeDisabled: aBoolean
        " Specify whether the workbench can be disabled if it is
        found as the owner window. "
    ^self propertyAt: #allowWorkbenchToBeDisabled put: aBoolean!
asPointerWithHotSpot: aPoint using: cursorInfo
        "Private - answer a host pointer with the same image
         as the receiver and aPoint as its hot spot."

    ^( PARTSCursorManager new hotSpot: aPoint )
        handle: ( self
            partsIfOS2Do: [
                ExternalHandle fromBytes: cursorInfo ]
            partsIfWindowsDo: [
                ExternalHandle fromInteger: cursorInfo ] )! 
getCursorWithStopSignWindows: hotSpot
        "Create a host cursor. Answer its handle"
    | cursor icon pointBitmap mask leftTop radius pen |
    self partsVwOnly.
    ( self andMask isNil or: [ self xorMask isNil ] )
        ifTrue: [ ^nil ].
    icon := self class new.
    pointBitmap := self xorMask clone.
    mask := self andMask clone.
    icon
        andMask: mask;
        xorMask: pointBitmap.
    leftTop := pointBitmap boundingBox leftTop.
    radius := mask width // 4.
    pointBitmap pen
        foreColor: RGBColor red;
        place: (leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4;
        place: (leftTop rightAndDown: mask width // 2 @ (mask width // 4 + 3));
        circleFilled: radius + 2;
        circle: radius;
        circle: radius - 1;
        setLineWidth: 2;
        direction: 45;
        go: radius;
        direction: 225;
        go: radius * 2 - 2.
        leftTop := mask boundingBox leftTop.
    pen := mask pen.
    2 timesRepeat: [
      pen
        foreColor: RGBColor black;
        place: (leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4;
        place: (leftTop rightAndDown: mask width // 2 @ (mask width // 4 + 3));
        backColor: RGBColor black;
        circleFilled: radius + 2.
      leftTop := mask boundingBox leftTop down: self class iconSize y].
    cursor := icon pointerHandle: hotSpot.
    mask release.
    pointBitmap release.
    ^cursor! 
change
        "Change the current Cursor to be the receiver."
    self
        partsIfOS2Do: [
            " hide/show does not work on some drivers.
             Not necessary anyway. [LN 22-Nov-94] "
            "Cursor hide."
            Cursor := self.
            self setCursor.
            "Cursor display" ]
        partsIfWindowsDo: [
            super change ]!   
visibleExtent
         " Private - answer the extent of an icon. "

    ^self class iconSize!  
iconCopy
        "Answer a copy of the receiver.  This copy will share the
        receiver's connection's object."
    | answer |
    answer := self clone.
    answer connection: connection copyForIconCopy.
    ^answer!
parent: aWindow
        " Specify the window containing the receiver. "

    parent := aWindow.!   
isPARTSIcon
        "Answer whether the receiver is a kind of PARTSIcon."

    ^true!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        closedAction: (closedAction partMirrorCopy: aMirrorCopyDictionary).
    ^copy!
containsPoint: aPoint
        "Answer true if the icon or its label
         contains aPoint, else answer false."
    ^((self iconContainsPoint: aPoint)
        or: [self labelContainsPoint: aPoint])!  
parent
        " Answer the window containing the receiver. "

    ^parent!
isShrunk
         " Answer whether the receiver is a shrunken part
         in a PARTS application. "

    ^false!
allowWorkbenchToBeDisabled
        " Private "
    ^self propertyAt: #allowWorkbenchToBeDisabled ifAbsent: [false]! 
initialize
        " Private - class initialization "

    self initializeEventsTriggered.

    ButtonMap := Array
        with: ( Dictionary new
            at: MbidOk put: 1;
            at: MbidCancel put: 0;
            yourself )
        with: ( Dictionary new
            at: MbidYes put: 1;
            at: MbidNo put: 2;
            at: MbidOk put: 1;
            at: MbidCancel put: 2;
            at: MbidRetry put: 1;
            yourself )
        with: ( Dictionary new
            at: MbidYes put: 1;
            at: MbidNo put: 2;
            at: MbidCancel put: 3;
            at: MbidAbort put: 1;
            at: MbidRetry put: 2;
            at: MbidIgnore put: 3;
            yourself ).
    CancelValue := MbidCancel.!  
getCursorWithMarkOS2: hotSpot
        "Create a host pointer. Answer its handle"
    | pointer pointBitmap mask |
    self partsVosOnly.
    ( self bitmap isNil or: [self colorBitmap isNil ] )
        ifTrue: [ ^nil ].
    pointer := self class new.
    pointBitmap := self colorBitmap clone.
    mask := self bitmap clone.
    pointer
        bitmap: mask;
        colorBitmap: pointBitmap.
    pointBitmap pen
        foreColor: Color red;
        place: (pointBitmap boundingBox leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4.
    mask pen
        foreColor: Color black;
        place: (mask boundingBox leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4;
        place: (mask boundingBox leftTop down: 37);
        north;
        go: 4;
        east;
        go: 4.
    pointBitmap deselect.
    mask deselect.
    pointer := pointer pointerHandle: hotSpot.
    pointBitmap release.
    mask release.
    ^pointer! 
partContainingWindow
        "Answer the non-frame visible window containing the receiver."

    ^self superWindow!
label
        "Answer the label of the icon."

    ^label! 
asPointerWithStopSign: aPoint
        "Answer a host pointer with the same image
         as the receiver and aPoint as its hot spot."

    ^self asPointerWithHotSpot: aPoint
        using: ( self getCursorWithStopSign: aPoint )!
frameWithLabel: aPen
        "Answer the frame including label."

    | iconRectangle labelWidth labelHeight labelRectangle |
    iconRectangle := self visibleFrame.
    ( aPen isNil or: [ label isNil or: [ showLabel not ] ] )
        ifTrue: [ ^iconRectangle ].
    labelWidth := ( aPen stringWidthOf: label ) + 2.
    labelHeight := aPen font height + aPen font descender.
    labelRectangle := 
        ( ( iconRectangle center x left: ( labelWidth // 2 ) )
            @ iconRectangle bottom )
        extentFromLeftTop: labelWidth @ labelHeight.
    ^labelRectangle merge: iconRectangle! 
getCursorWithStopSignOS2: hotSpot
        "Create a host pointer. Answer its handle"
    | pointer pointBitmap mask leftTop radius pen |
    self partsVosOnly.
    ( self bitmap isNil or: [ self colorBitmap isNil ] )
        ifTrue: [ ^nil ].
    pointer := self class new.
    pointBitmap := self colorBitmap clone.
    mask := self bitmap clone.
    pointer
        bitmap: mask;
        colorBitmap: pointBitmap.
    leftTop := pointBitmap boundingBox leftTop.
    radius := mask width // 4.
    pointBitmap pen
        foreColor: Color red;
        place: (leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4;
        place: (leftTop rightAndDown: mask width // 2 @ (mask width // 4 + 3));
        "foreColor: Color white;"
        backColor: Color white;
        circleFilled: radius + 2;
        foreColor: Color red;
        circle: radius;
        circle: radius - 1;
        setLineWidth: 2;
        direction: 45;
        go: radius;
        direction: 225;
        go: radius * 2 - 2.

    leftTop := mask boundingBox leftTop.
    pen := mask pen.
    2 timesRepeat: [
      pen
        foreColor: Color black;
        place: (leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4;
        place: (leftTop rightAndDown: mask width // 2 @ (mask width // 4 + 3));
        backColor: Color black;
        circleFilled: radius + 2.
      leftTop := mask boundingBox leftTop down: PARTSIcon iconSize y].
    pointBitmap deselect.
    mask deselect.
    pointer := pointer pointerHandle: hotSpot.
    pointBitmap release.
    mask release.
    ^pointer! 
getCursorWithMarkWindows: hotSpot
        "Create a host pointer. Answer its handle"
    | icon cursor pointBitmap mask |
    self partsVwOnly.
    ( self andMask isNil or: [ self xorMask isNil ] )
        ifTrue: [ ^nil ].
    icon := self class new.
    pointBitmap := self xorMask clone.
    mask := self andMask clone.
    icon
        andMask: mask;
        xorMask: pointBitmap.
    pointBitmap pen
        place: (pointBitmap boundingBox leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4.
    mask pen
        place: (mask boundingBox leftTop down: 5);
        north;
        go: 4;
        east;
        go: 4;
        place: (mask boundingBox leftTop down: 37);
        north;
        go: 4;
        east;
        go: 4.
    cursor  := icon pointerHandle: hotSpot.
    mask release.
    pointBitmap release.
    ^cursor!   
mainObject
        "Private - Answer the main object connected to the icon.
        If the object is a PARTSCatalogIconConnection,
        answer its main object."
    ^( connection isPARTSCatalogIconConnection
    or: [ connection isPARTSApplication ] )
        ifTrue: [ connection mainObjectPrivate ]
        ifFalse: [ self connection ]!  
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
origin
         " Answer the origin of the receiver's rectangle. "

    ^origin!   
initialize
        "Private - Recreate all icons."
    Icon allInstancesPrim do: [: icon |
        icon createIcon]!   
visibleFrame
        "Answer the system rectangle containing the icon."

    ^origin extent: self visibleExtent!   
displayLabel: aPen
        "Display the receiver's label centered underneath
         the icon itself
         using <aPen>. "

    | iconRectangle |
    label isNil ifTrue: [ ^self ].
    iconRectangle := self visibleFrame.
    parent notNil ifTrue: [
            aPen
                font: parent font;
                foreColor: parent foreColor
                "backColor: parent backColor;" ].
    aPen
        setBackgroundMode: BackgroundMixTransparent;
        place:
            iconRectangle center x
            @ (iconRectangle bottom down: ( aPen font height // 2 ) );
        centerText: label at: aPen location.! 
helpInfoPacked
        "Answer help info (packed strings)
        for the connected object.  Only available
        for delayed objects which aren't loaded yet. "
    ^connection isPARTSCatalogIconConnection
        ifTrue: [ connection helpInfoPacked ]
        ifFalse: [ nil ]! 
getCursorWithMark: hotSpot
        "Create a host pointer. Answer its handle"
    ^self
        partsIfOS2Do: [ self getCursorWithMarkOS2: hotSpot ]
        partsIfWindowsDo: [ self getCursorWithMarkWindows: hotSpot ]!
iconContainsPoint: aPoint
        "Answer true if the icon contains
         aPoint, else answer false."
    ^self visibleFrame containsPoint: aPoint! 
outputToExe: aPathName
        "Private - Write the icon as an extended attribute
         on the file for aPathName."
    | bytes fa fad directory fileName |
    self partsVosOnly.

    bytes := ReadWriteStream on: String new.
    self outputToFileStream: bytes.
    bytes := bytes contents asByteArray.
    directory := Directory pathName: aPathName fileNamePath.
    fileName := aPathName fileNameLessPath.
    fad := ( Smalltalk at: #FileAttributeDictionary )
        directory: directory
        fileName: fileName.
    fa := fad at: '.ICON' ifAbsent: [
        ( Smalltalk at: #UndefinedFileAttribute ) partsEatIconFormat ].
    fa value: bytes.
    fad at: '.ICON' put: fa.!
hotSpot
        "Answer the receiver's hot spot."
    ^hotSpot! 
getWindowToDisable: aParent
        " Private - answer the window to disable when the receiver is opened. "

    | windowToDisable |
    windowToDisable := super getWindowToDisable: aParent.
    ( self isWorkbenchSession
    and: [ ( self isOkToDisable: windowToDisable ) not ] )
        ifTrue: [ windowToDisable := nil ].
    ^windowToDisable! 
button1DoubleClick: aPoint
        "The left button has been double-clicked.  Do nothing."!  
connection: anObject
        "Specify the connected object. "

    connection := anObject.!
origin: aPoint
        "Set the origin of the icon to <aPoint>."

    origin := aPoint!
showLabel: aBoolean
        " Specify whether the receiver is displayed with a label. "

    showLabel := aBoolean.!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    | loadContext oldIconCore |
    ( ( loadContext := anObjectFiler clientContext ) isPARTSLoadContext
    and: [ loadContext fileVersion = 'LAF/VPM 2.0a'] )
        ifTrue: [  " PWO 2.0 icon "
            self bitmap class symbol = #PARTSUpgradeIconCore
                ifTrue: [
                    oldIconCore := self bitmap.
                    self bitmap: oldIconCore bitmap.
                    self colorBitmap: oldIconCore colorBitmap.
                    anObjectFiler registerUpgradeMutationFrom: oldIconCore 
                        to: oldIconCore bitmap.
                     ].
            ].!
partIsSelected
        " Answer whether the receiver is currently selected
        in a PARTS Workbench. "
    ^connection partEditor selectedComponents includes: self connection!
setLabel: aString
        " Set the receiver's label to aString. "

    "
    parent invalidateRect: self labelFrame.
    name := aString.
    parent invalidateRect: self labelFrame
    "
    self parent changeIconLabel: self to: aString.!   
wmCommand: wordInteger with: longInteger
        "Private - Process the command message.
        ESC key should always close (cancel) a dialog window. "

    ( (wordInteger = "(OperatingSystemConstants at: 'Idcancel')" 2 )
    and: [ self partIsEditing not ] )
        ifTrue: [
            self sendInputEvent: #close ].
    ^super wmCommand: wordInteger with: longInteger!
reverseWith: aPen
        "reverse the icon on screen."
    self partsIfWindowsDo: [
        self displayAt: origin with: aPen ].
    aPen fill: self visibleFrame rule: CopyRuleDestInvert!  
connectionPrivate
        " Private - answer the connected object (don't load) "

    ^connection! 
bitmap
    ^self
        partsIfOS2Do: [ super bitmap ]
        partsIfWindowsDo: [ self andMask ]!
isWorkbenchSession
        " Private - answer whether this is a workbench session. "

    ^( Smalltalk at: #PARTSSessionManager ifAbsent: [ ^false ] ) isWorkbenchSession! 
frameRectangle
        "Answer the screen rectangle containing the icon
        and its label."
    ^self partFrame
        mapClientToScreen: parent!
saveFile: defaultFileName
        "Private - Open a Save File dialog with the defaultFileName "
    | aPathName |
    aPathName := (super saveFile: defaultFileName) file.
    closedAction evaluateWithArguments: (Array with: aPathName).
    ^aPathName!  
asPARTSIcon
    "Answer the receiver as a PARTSIcon"
    ^self! 
partUndoDirectEdit: originalLabel
        "Undo a direct edit operation on the receiver."
    self setLabel: originalLabel.!
soleObject
        "Answer the sole object connected to the icon.
        If the object is a PARTS application, answer its
        sole component or nil if it has more than one component."

    | anObject |
    anObject := self connection.
    ^anObject isPARTSApplication
        ifTrue: [ anObject solePart ]
        ifFalse: [ anObject ]!
openTitled: titleString withText: textString style: mbConstants
        " Open the message dialog with titleString as the title
        and textString as the text. "

    | hostIdReply buttonIndex reply |
    hostIdReply := self class titled: titleString withText: textString style: mbConstants.
    buttonIndex := (ButtonMap at: buttonValues size)
        at: hostIdReply
        ifAbsent: [0].
    reply := ( buttonIndex = 0
        ifTrue: [PARTSException new]
        ifFalse: [buttonValues at: buttonIndex] ).
    closedAction evaluateWithArguments: (Array with: reply).
    ^reply!  
pointerHandle: hotSpot
    "Private - answer the pointer handle created from the receiver."

    | pointerSize pointer monoXor |

    self
        partsIfOS2Do: [
            pointerSize := self class pointerSize.
            pointerSize = self extent
                ifFalse: [
                    self bitmap changeSize: (pointerSize x @ (pointerSize y * 2)) .
                    self colorBitmap changeSize: pointerSize ].
            ^self createPointerIndirect: hotSpot flag: true ]
        partsIfWindowsDo: [
            "Can only create color pointers in NT."
            OperatingSystem isWindowsNT
                ifTrue: [ ^self colorPointerHandle: hotSpot ].
            monoXor := self xorMask asMonochrome.
            pointer := PARTSHostInterface hostWindowLibrary
                createCursor: OperatingSystem hInstance
                xHotSpot: hotSpot x
                yHotSpot: hotSpot y
                width: self extent x
                height: self extent y
                andBits: self andMask getDDBits
                xorBits: monoXor getDDBits.
                monoXor release.
            ^pointer ].! 
stringRepresentation
        "Private - answer a String representation of the receiver."
    | stream |
    stream := WriteStream on: String new.
    self outputToFileStream: stream.
    ^stream contents asString!
colorPointerHandle: hotSpot
        "Private - Create a color pointer from the receiver.
         Answer the pointer's handle. "
    | bitmask colorMask iconInfo pointer |
    self partsVwOnly.
    bitmask := self andMask clone.
    colorMask := self xorMask clone.
    iconInfo := SelfDefinedStructure named: 'ICONINFO'.
    iconInfo fIcon: 0;
        xHotspot: hotSpot x;
        yHotspot: hotSpot y;
	"the following two selectors have been changed ... hbmColor: and hbmMask: are not implemented on os/2 so this method has become platform dependent...the methods are different and dirty on both platforms..."
        hbmMask: bitmask handle asParameter;
        hbmColor: colorMask handle asParameter.
    pointer := PARTSHostInterface hostWindowLibrary createIconIndirect: iconInfo asParameter.
    bitmask release.
    colorMask release.
    ^pointer!  
frameRelativeRectangle
        "Answer the screen rectangle containing the icon
        and its label."
    ^self partFrame!   
closedAction: anAction
        " Specify the action to be evaluated with the
        result when the dialog is closed.  The answer
        is a PARTSException if the dialog is cancelled. "
    closedAction := anAction.!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        buttonValues: (buttonValues partMirrorCopy: aMirrorCopyDictionary);
        closedAction: (closedAction partMirrorCopy: aMirrorCopyDictionary).
    ^copy!   
partFinalize
        "Finalize the receiver by releasing any system resources."

    self release! 
helpInfo
        "Answer help info (help file name, help topic)
        for the connected object.  Only available
        for delayed objects which aren't loaded yet. "
    | aStream |
    connection isPARTSCatalogIconConnection
        ifFalse: [ ^ #( '' '' ) ].
    aStream := ReadStream on: connection helpInfoPacked.
    ^Array
        with: (aStream upTo: 0 asCharacter)
        with: (aStream upTo: 0 asCharacter)!