3.1.0.106
   
partMirrorCopyProperties: aMirrorCopyDictionary to: copy
        " Private - mirror copy relevant properties "

    | excludedProperties copiedProperties |
    properties isNil ifTrue: [ ^self ].
    excludedProperties := self partMirrorCopyPropertiesToExclude.
    copiedProperties := properties species new.
    properties associationsDo: [ :assoc |
        ( excludedProperties includes: assoc key )
            ifFalse: [   " optimized for IdentityDictionary with Symbol keys "
                copiedProperties
                    "add: ( assoc partMirrorCopy: aMirrorCopyDictionary )"
                    at: assoc key
                    put: ( assoc value partMirrorCopy: aMirrorCopyDictionary ) ].
        ].
    copy properties: copiedProperties.!   
partShrunkenIcon
        "Private - Answer the icon used for a shrunken
        window."
    | icon origin |

    ( icon := self partShrunkenIconAttribute ) isNil
        ifTrue: [ "Initialize shrunken icon"
            icon := PARTSFile iconFromFile: self partShrunkenIconFile
                ifNone: [ PARTSApplication defaultIcon ].
            origin := self frameRelativeRectangle leftTop.
            self partsIfOS2Do: [
                origin := origin down: Icon iconSize y ].
            icon
                connection: self;
                showLabel: true;
                origin: origin;   "align with the visual part"
                label: self partName.
            self partShrunkenIcon: icon ]
        ifFalse: [
            icon label ~= self partName
                ifTrue: [   "Icon created through a w.b. duplication of a shrunken part."
                    icon label: self partName.
                   "icon origin: ( icon origin rightAndDown: 10 @ 10 )" ]].
    ^icon!
partFontOrSysFont
    "Private - Always answer a Font."

    | myFont |
    ^(( myFont := self font ) notNil ifTrue: [myFont] ifFalse: [SysFont])!
drawText: hDC text: aString length: length rectangle: winRect flags: flags
    <api: DrawTextA ulong struct short struct ulong ushort>
    ^self invalidArgument!   
partFinalize
        "Finalize the receiver by releasing any system resources.
        Default behavior is to do nothing."! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #addTime: #asSeconds #hours #minutes
               #seconds #seconds: #subtractTime:)
                asSortedCollection)
        defaultItem: standardMessages defaultItem! 
insureWithin: aWindow
    "Private - Insure the receiver is within <aRectangle>"
    | iconRect xShift yShift origin containingRectangle |

    iconRect := rectangle.
    origin := rectangle origin.
       "freeClientArea only represents the virtual screen"
    containingRectangle := aWindow entireClientArea.
    window isNil ifTrue: [ window := aWindow ].

    xShift :=
        ( iconRect right isRightOf: containingRectangle right )
            ifTrue: [ ( containingRectangle right - iconRect right ) abs ]
            ifFalse: [ 0 ].
    yShift :=
        ( iconRect bottom isBelow: containingRectangle bottom )
            ifTrue: [ ( containingRectangle bottom - iconRect bottom ) abs ]
            ifFalse: [ 0 ].
    origin := origin leftAndUp: ( xShift @ yShift ).
    rectangle := origin extent: rectangle extent.

    iconRect := rectangle.
        origin := rectangle origin.
    xShift :=
        ( iconRect left isLeftOf: containingRectangle left )
            ifTrue: [ ( containingRectangle left - iconRect left ) abs ]
            ifFalse: [ 0 ].
    yShift :=
        ( iconRect top isAbove: containingRectangle top )
            ifTrue: [ ( containingRectangle top - iconRect top ) abs ]
            ifFalse: [ 0 ].
    origin := origin rightAndDown: ( xShift @ yShift ).
    rectangle := origin extent: rectangle extent.

    ( connection notNil and: [
        connection isPARTSCatalogIconConnection not and: [
        connection partIsWindow not ]])
        ifTrue: [
            connection partWrapper rectangle:
                ( PARTSFramer
                    forRectangle: ( origin extent: rectangle extent )
                    in: containingRectangle )]
! 
codeValue
        "Answer the number corresponding to the code point
         value of the receiver."
    ^asciiInteger!   
isPARTSStoreContext
        " Answer whether the receiver is the clientContext of a PARTS application
        store operation. "

    ^false! 
invalidateRegion: aWindowHandle hrgn: hrgn erase: aBoolean
    <api: InvalidateRgn ulong ulong boolean boolean>
    ^self invalidArgument!  
updateFromExternalAddress: anExternalAddress
        "Private -The call is finished, and it may have changed the
        contents of the struct, so copy it back to the buffer and update
        the UI parts."
    self setFromReference16: anExternalAddress.! 
partRelativeToParent: aParent
    "Private - Answer whether the receiver's rectangle is
    relative to its parent on the workbench.  The receiver
    is always relative to its parent, unless its in a nested
    part and is a desktop child."

    ^true!   
printFraction
        "Answer a string, the ASCII representation of the receiver"

    | scale number |
     denominator = 1
        ifTrue: [^self asInteger printString].
    ( denominator rem: 10 ) > 0
        ifTrue: [ ^self printString ].
    scale := 0.
    number := denominator.
    [ number >= 10.0 ]
        whileTrue: [
            number := number / 10.0.
            scale := scale + 1 ].
 ^self printFraction: scale!   
partPositionShrunkenIcon
         "Private - the receiver has just been opened in a workbench.
        If the receiver is shrinked, set the position of the receiver's
        shrunken icon as per the receiver's framer."
    | myWrapper workbenchPane icon |
    self partIsShrunk
        ifTrue: [
            icon := self partShrunkenIcon.
            myWrapper := self partWrapper.
            workbenchPane := myWrapper workbenchPane.
                icon origin: ( myWrapper rectangle isPARTSRectangle
                    ifTrue: [
                            "Since framer is relative to top left, changing workbench
                            rectangle size shouldn't have an effect (esp. on OS/2)."
                        ( myWrapper rectangle scaleFrom:
                            ( 0 @ 0 extent: workbenchPane extent )) origin ]
                    ifFalse: [ myWrapper rectangle origin ] ) ]!  
keysAsArray
        "Answer a collection containing all the keys
         in the receiver."

    | answer |
    answer := OrderedCollection new: self size.
    self associationsDo: [ :assoc |
        answer add: assoc key].
    ^answer!  
partDragTargetDrop: aDragDropSession
        "Private - aDragSession has just been dropped on the receiver. "
    | editorPane |

    editorPane := self superWindow.

    "Below is from dragTargetDrop:"
    aDragDropSession targetSelection: editorPane.
    editorPane dragTargetStopScrollTimer.
    aDragDropSession target: editorPane.
    aDragDropSession targetEraseEmphasis.
    aDragDropSession target: self.

    aDragDropSession isReplaceOperation
        ifTrue: [ self connection partDragTargetReplace: aDragDropSession in: editorPane ]!   
initializeParts
        " Private - initialize the parts in an application
        which has just been loaded (register event handlers,
        initialize the state of parts in the application).
        Default is to do nothing. "

    self
        initializeEventHandlers;
        initializePartValues.!  
maxLengthForDE
    "Private - Answer the maximum number of chars. for the receiver"
    ^30!
mapViewOfFile: hMapObject access: accessMode offsetHigh: anInt1 offsetLow: anInt2 map: anInt3
    <api: MapViewOfFile ulong ulong ulong ulong ulong ulongReturn >
    ^self invalidArgument!
isPARTSMenuPane
        "Answer whether the receiver is a kind of PARTSMenuPane."
    self partsVwOnly.  " Only used on VW" 

    ^false! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #asLowerCase #asUpperCase #codeValue
               #isAlphaNumeric #isDigit #isLetter #isLowerCase
            #isSeparator #isUpperCase #isVowel)
                asSortedCollection)
        defaultItem: standardMessages defaultItem!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (self partMessagesStandard items,
            #(
            #asParameter #height
            #outputToFile: #pen #release
            #width
            )) asSortedCollection asArray
        defaultItem: #height!
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."

    ^( 0@0 extent: self frameRectangle extent )
        mapFromWindow: self
        to: self partEditor workbenchPane.!
setFromReference32: anExternalAddress
        "Private - Copy the bytes from anExternalAddress back to self,
        dropping the zero termination."
    self replaceFrom: 1
        to: self size
        withAddress: anExternalAddress
        startingAt: 1.
    ^self!
partMessages
        " Answer the PARTS message interface of the receiver. "

        ^PARTSSessionManager isWorkbenchSession
            ifTrue: [ self partMessagesDefault ]
            ifFalse: [ PARTSInterfaceList emptyList ]!
partDoesResizeToContents
        "Answer whether the receiver should be resized
         to accomodate changed text entered
         through direct-editing."
    ^false! 
partDirectEditErrorMessage
    "Private - answer the error message to be displayed for an invalid direct edit."
    ^'Invalid direct edit'! 
partCanTriggerEvent: aSymbol
        " Answer whether the receiver can trigger the event <aSymbol> "

    ^(self partEvents items includes: aSymbol)
		or: [self canTriggerEvent: aSymbol]!   
partDoesResizeToContents
        "Answer whether the receiver should be resized
         to accomodate changed text entered
         through direct-editing."
    ^true!  
partDirectEditTextIsRightJustified
        "Answer whether the receiver's text should be
        right-justified during direct-editing."
    ^false!   
displayAt: aPoint with: aPen
        "Display the icon with aPen."
    | oldOrigin |
    isEditing notNil ifTrue: [^self].
    oldOrigin := self origin.
    self origin: aPoint.
    (self getEditor pen: aPen) displayStatic.
    self origin: oldOrigin!
partDirectEditErrorMessage
    "Answer the error message to be displayed for an invalid direct edit."
    ^'Too many mnemonic characters in the label'! 
connectionValueChanged
    "Private - Update the receiver to display the new value"
    | oldRect |
    oldRect := rectangle copy.
    self updateRectangle.
    window isNil ifTrue: [^self].
    ((oldRect left isLeftOf: rectangle left) or: [
        oldRect right isRightOf: rectangle right]) ifTrue: [
            self getEditor
                rectangle: rectangle;
                revealFrom: (oldRect expandBy: 2)].
    connection partIsEditing
        ifTrue: [
            self display.
            connection partWrapper partLinkEditor
                refreshAfterResizeOf: self
                from: oldRect
                to: rectangle].! 
isPARTSNestedPart
        "Answer whether the receiver is a PARTS NestedPart."
    ^false!  
partFrameCenter
        "Private - Answer the Rectangle with its origin
        at the center of the shrunken icon and extent of zero."
    | iconFrame |
    iconFrame := self partShrunkenIcon partFrame.
    ^(iconFrame leftBottom rightAndUp: (iconFrame extent // 2))
        extentFromLeftBottom: 0 @ 0!
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^self class supportsRecycling! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := self partMessagesStandard.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items:
            #(#< #<= #> #>= #max: #min: #between:and:)
                asSortedCollection)
        defaultItem: standardMessages defaultItem!  
initialize
        " Private - initialize the class. "

    self emptyRecyclingBin.!   
COMMENT
"
PARTSApplicationHolder is the superclass for implementing
wrapper classes for objects which are wholly or partially
implemented as PARTS application.

PARTSApplicationHolder supports a caching mechanism
for optimizing load vs. use patterens of applications.
"!
partDragTargetOperationsDefault
    "Private - answer the default drag operations for the receiver."

    ^#(#move #copy).!
rectangle
    "Answer the rectangle relative to the parent"

    ^rectangle!   
openFileMapping: access inheritFlag: flag name: aString
    <api: OpenFileMappingA ulong boolean struct ulongReturn >
    ^self invalidArgument!
asPARTSDirectory
    "Private - Answer the directory referenced by the receiver."

    ^PARTSDosDirectory fromLocator: self!   
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not need to copy or add to aMirrorCopyDictionary
        because numbers are usually unique objects
        and we don't care about their identity
        in the cases when they're not. "

    ^self!   
openOn: anObject
        " Launch the PARTS application by triggering
        the openOn: event. "

    self openApplicationOn: anObject.!
partHasVisualParts
        " Answer whether the receiver contains any visible parts. "
    ^false!  
partsExceptionIfNil
        "Answer a PARTSException if the receiver is nil."
    ^PARTSException new!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #* #+ #- #/ #// #\\ #@ #abs #arcCos #arcSin #arcTan
            #asFloat #ceiling #cos #degreesToRadians
            #denominator #down: #exp #even #floor
            #higherOf: #isAbove: #isAboveEqual:
            #isBelow: #isBelowEqual: #isLeftEqualOf: #isLeftOf:
            #isRightEqualOf: #isRightOf: #left: #leftMost:
            #lowerOf: #ln #log:
            #negated #negative #numerator #odd #positive #quo:
            #radiansToDegrees #raisedTo: #raisedToInteger:
            #rem: #right: #rightMost: #rounded #roundTo:
            #sign #sin #sqrt #tan #truncated #truncateTo: #up: )
            asSortedCollection)
        defaultItem: standardMessages defaultItem! 
partFinalize
        "Finalize the receiver by releasing any system resources."

    self saveBitmap!  
isNormalized
        " Answer whether the receiver is normalized. "
    ^leftTop isLeftAndAboveOrEqual: rightBottom!
isPARTSWindow
        " Answer whether the receiver is a PARTS top-level window. "
    ^false!  
partWrapper: aWrapper
        " Private - set the PARTS wrapper of the receiver. "
    self propertyAt: #partsWrapper put: aWrapper.!   
partDirectEditTextIsCentered
        "Answer whether the receiver's text should be
        centered during direct-editing."
    ^true! 
partOpen
        "Display the receiver when it is being edited
         in a PARTS Workbench, or being built by a nested
         part for run time."
    super partOpen.
    "Parts are added to the end of the ordered children,
     make workbench z-order reflects this."
    self partIsEditing ifTrue: [ self partBringSubPaneToBottom ].
!
partIsShrunk: aBoolean
        "Private - Specify whether the receiver is shrunk
         in the PARTS Workbench."
    self propertyAt: #PARTSShrunk put: aBoolean.!   
frameWithLabel: aPen
        "Answer the frame including label."
    ^self partFrame!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := self partMessagesStandard.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            "Done in apropriate subclasses: add: addAll: "
            #asArray #asOrderedCollection #asSet #asSortedCollection
            "exclude messages in script language which use block:
            asSortedCollection: collect: detect: detect:ifNone:
            do: reject: select:
             "
            #includes: #isEmpty #occurrencesOf: #size)
                asSortedCollection)
        defaultItem: standardMessages defaultItem!
partIsEditing
        "Answer whether the receiver is being
        edited in a PARTS Workbench. "

    ^owner partIsWindow
        ifTrue: [ false ]  "o.w. looping"
        ifFalse: [ owner partIsEditing ]! 
partCanHaveChildren: aCollection
        "Answer whether the receiver can contain every
        object in aCollection.  This is used when dragging
        a collection of parts."
    self error: 'obsolete, should no longer be used'.
    aCollection do: [ :object |
        ( self partCanHaveChild: object )
            ifFalse: [ ^false ] ].
    ^true!  
partNeedsResizeToContents
        " Private - answer whether the receiver needs to
        be resized to install a property edit change. "
    ^self labelAttribute isNil
        ifTrue: [ false ]
        ifFalse: [
            ( (self font stringWidth: self labelAttribute) + 4  )
                > self rectangle width ]! 
on: aFileName
        " Answer a PARTSApplicationHolder for the
        PARTS application in aFileName. "

    | anApplicationHolder |
    anApplicationHolder := self new.
    ( anApplicationHolder loadApplication: aFileName ) isNil
        ifTrue: [ ^nil ].
    ^anApplicationHolder!  
partAddedTo: anApplication
        " The receiver has just been added to anApplication.
        Create any links or register event handlers if desired. "!  
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."
    | y |
    y := self extent y - self font height // 2.
    ^(( 0@y ) extent: self extent x @ self font height )
        mapFromWindow: self
        to: self partEditor workbenchPane.! 
removeRuntimeSessionEventHandlers
        " Private - remove the session event handlers for the
        PARTS runtime component
            PARTSSessionManager removeRuntimeSessionEventHandlers
        "

    SessionModel current isRunTime
        ifFalse: [
            self runtimeSessionStartUpMessages do: [ :msg |
                SessionModel current
                    removeAction: msg
                    forEvent: #startup ].
            ].
    self runtimeSessionShutdownMessages do: [ :msg |
        SessionModel current
            removeAction: msg
            forEvent: #shutdown ].
    SessionModel current isRunTime
        ifFalse: [
            self runtimeSessionSaveImageMessages do: [ :msg |
                SessionModel current
                    removeAction: msg
                    forEvent: #aboutToSaveImage ].
            ].!
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | editor oldValue text partEditor |

    oldValue := connection value.
    self rawText size > self maxLengthForDE
        ifTrue: [
            text := Prompter
                prompt: 'Value of ', connection partName, ':'
                default: self rawText.
            text isNil ifTrue: [^self].
            connection textValue: text]
        ifFalse: [
            isEditing := true.
            editor := self getEditor.
            editor consumeInput.
            isEditing := nil.
            rectangle := editor rectangle.
            (( partEditor := connection partEditor )
                selectedComponents includes: connection )
                    ifTrue: [ partEditor workbenchPane refreshAllSelections ]].
    self connectionValueChanged.
    connection partEditor
        recordUndo: (Message new
               receiver: self
            selector: #changeConnectionValue:
            arguments: (Array with: oldValue))
        undoLabel: 'direct edit'
        redo: (Message new
            receiver: self
            selector: #changeConnectionValue:
            arguments: (Array with: connection value))
        redoLabel: 'direct edit'!  
displayWith: aPen
    self displayAt: self origin with: aPen!
partOverlappedWindowWindows: aPoint
        "Private - Answer the receiver's sibling window that
          contains aPoint. We need to test for siblings that contains
          aPoint because the Windows Z order for child windows is
          opposite the display order, ie. if there are two overlapping
          buttons, the button underneath has higher Z order than the
          one above. When the api WindowFromPoint is called and more
          than one window contains the given point, it returns the first
          window on the list. Thus, inorder to detect the window that is
          on top, we need to start looking at the bottom of the Z order
          and traverse up the  list until a sibling is found that contains
          aPoint, where aPoint is relative to the screen."

    | sibling |
    sibling := Notifier findWindow:
        ( (Smalltalk at: #UserLibrary)
            getWindow: self handle
            relationship: ( PARTSConstants at: 'GwHwndLast' ) ).
     [ sibling notNil and: [ ( sibling frameRectangle containsPoint: aPoint ) not
        or: [ sibling isVisible not ] ] ]
     whileTrue: [
        sibling := Notifier findWindow:
            ( (Smalltalk at: #UserLibrary)
                getWindow: sibling handle
                relationship: ( PARTSConstants at: 'GwHwndPrev' ) ) ] .

    sibling isNil ifTrue: [ ^self ].
    sibling isGroupBox
        ifTrue: [  ^sibling partControlInGroupBoxWindows: aPoint ]
        ifFalse: [ ^sibling ]!  
partCanWindow: aWindow haveChild: anObject
        " Private - answer whether aWindow can contain anObject as a child. "
    | components |

    anObject isPARTSApplication
        ifTrue: [
            anObject isExecutable
                ifTrue: [
                     "Executable applications can only go on the editor pane
                         (in the form of a part accessor)"
                    ^aWindow isPARTSEditorPane ].
            ( components := anObject partWrapper components )
                do: [ :aWrapper |
                    ( self
                        partCanWindow: aWindow
                        haveChild: aWrapper object )
                            ifTrue: [ ^true ]].
            ( components isEmpty and: [ aWindow isPARTSEditorPane ])
                ifTrue: [ ^true ].  "Special case: Empty application can be put on w.b."
            ^false ]
        ifFalse: [
            ^( aWindow partCanHaveChild: anObject )
                and: [ anObject partCanHaveParent: aWindow ]].!   
isPARTSMenuBitmapItemPart
    "Answer whether the receiver is an instance
    of PARTSMenuBitmapItemPart"
    ^false!  
partShrunkenIconAttribute
        "Private - Answer the icon used for a shrunken
        window."
    ^self propertyAt: #PARTSShrunkenIcon!
framer
    "Private - Answer a framer for the receiver"
    | framer top left extent scaleUnit |

    scaleUnit := self scaleUnit.
    framer := PARTSFramer new.
    framer scaleMask: framer maskForDefault.
    framer scaleUnit: scaleUnit.
    extent := self extent.

    self superWindow notNil
        ifTrue: [
            top :=
                self partsIfOS2Do: [
                    ( self superWindow rectangle top - self origin y ) - self extent y ]
                partsIfWindowsDo: [
                    self origin y ].
            left := self origin x ]
        ifFalse: [ "Default is origin"
            self origin notNil
                ifTrue: [
                    top := self origin y.
                    left := self origin x ]
                ifFalse: [
                    top := 0.
                    left := 0 ].
            self partsIfOS2Do: [ top := top up: self extent y ]].

    ^framer
        top: ( PARTSFramer pixelVertical: top toScaleUnit: scaleUnit );
        left: ( PARTSFramer pixelHorizontal: left toScaleUnit: scaleUnit );
        right: ( PARTSFramer pixelHorizontal: extent x toScaleUnit: scaleUnit );
        bottom: ( PARTSFramer pixelHorizontal: extent y toScaleUnit: scaleUnit );
        yourself
!
prepareToBeRecycled
        " Private - the receiver is about to be donated
        to the recycling center.  Clear all instance variables
        of the subclasses (leave application and events). "

    ( PARTSApplicationHolder instSize + 1 )
        to:  self class instSize do: [ :i | self instVarAt: i put: nil ].!  
partIsDesktopChild
    "Private - Answer whether the receiver is always a child of the
    workbench desktop."

    ^false!   
partApplication
        " Answer the PARTS application which contains the receiver. "
    | myWrapper |
    (myWrapper := self partWrapper) isNil
        ifTrue: [ ^nil ].
    ^myWrapper application!  
containsPARTSObject
        " Answer whether the clipboard contains a PARTS object. "
    ^self containsFormat: self formatPARTSObject! 
partFrameRectangleFrom: aRect scaleMask: aMask
        "Answer the framing rectangle computed from aRect and aMask."
    ^PARTSFramer new
        scaleMask: aMask;
        changeRectangle: aRect
            in: self! 
offsetFromLeftTop: aPoint
        "Private -  Set the receiver's position so that its
        left top is aPoint to the right and down from the
        top left of its parent pane. "
    rectangle :=
        (self parent leftTop rightAndDown: aPoint)
        extentFromLeftTop: self computeExtent.!  
removeRuntimeComponent
        " Private - prepare to remove the PARTS runtime component.
            PARTSRuntimeSessionManager removeRuntimeComponent
        "

    self
        removeRuntimeData;
        removeRuntimePlatformEvents;
        removeRuntimeSessionEventHandlers.!   
partIsShrunk
        "Private - Answer whether the receiver is shrunk
         in the PARTS Workbench."
    | answer |
    ^( answer := (self propertyAt: #PARTSShrunk)) notNil
        ifTrue: [ answer ]
        ifFalse: [ false]!   
partsGetNearestColor: aColorValue
        " Answer the nearest solid color to aColorValue. "
    self partsVwOnly.  " Only used on VW"
    ^PARTSHostInterface hostGraphicsLibrary
        getNearestColor: self handle
        color: aColorValue asParameter!  
leftTop
    "Private - Answer the left top coordinate of the receiver in pixels."
    ^self
        partsIfOS2Do: [ self origin x @ ( self origin y up: self extent y )]
        partsIfWindowsDo: [ self origin ]

!   
partPopUpIn: aWindow
        "Popup the receiver menu at the current mouse
    location within aWindow, wait for the user to make
    a selection, and answer the selector of the selected
    item or nil if the user selected nothing.
        This is used for popups built for the workbench."
    ^self
        partsIfOS2Do: [self partPopUpInOS2: aWindow]
        partsIfWindowsDo: [self partPopUpInWindows: aWindow]!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (
            self partMessagesStandard items,
            #( #change #display #hide #offset: #sense ))
                asSortedCollection asArray
        defaultItem: #hide! 
isEditing
        "Obsolete - Answer whether the receiver is being
        edited in a PARTS Workbench. "

    PARTSSessionManager obsoleteMessage.
    ^self partIsEditing! 
partDirectEditTextIsCentered
        "Answer whether the receiver's text should be
        centered during direct-editing."
    ^false!
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "

    ^ self partFontOrSysFont charSize * (15 @ 6) + (0 @ 6)  "add 6
        to height so that there won't be spaces after the bottom line"!  
icon

    ^PARTSApplication defaultIcon!
initialize
        " Private - initialize the receiver when
        newly instantiated or when being recycled.
        Default is to do nothing. "!
isPARTSNonvisualPart
        "Answer whether the receiver is a PARTSNonvisualPart."
    ^false! 
spacing
    "Private - Answer the space around the text"

    ^6 @ 4!  
display
    self displayWith: self pen!  
replaceControlChars
        " Replace any control characters in the receiver with blanks "
    1 to: self size do: [ :i |
        ((self at: i) asInteger < 32)
            ifTrue: [self at: i put: Space]].!
replaceControlChars
        "This operation is not supported by the receiver."
    ^self invalidMessage!
partCanHaveChild: aSubpane
        "Answer whether the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^false!  
controller: controllingObject controllee: controlledObject
        " Set the controller/controllee pair of the receiver. "
    self
        propertyAt: #controller put: controllingObject;
        propertyAt: #controllee put: controlledObject.!   
getPARTSObject
        "Answer the contents of the clipboard as a PARTS object, or nil
         if the clipboard is empty or cannot render an object."
    ^self getObject: self formatPARTSObject!
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^PARTSInterfaceList new
        items: ( standardMessages items asOrderedCollection
            remove: #at:put: ;
            remove: #copyReplaceFrom:to:with: ;
            remove: #replaceControlChars ;
             yourself )
                asSortedCollection asArray
        separators: nil
        defaultItem: standardMessages defaultItem! 
isPARTSEditorPane
    "Answer whether the receiver is a PARTSEditorPane, or
        one of its subclasses."

    ^false!  
getCursor
    <api: GetCursor ulong>
    ^self invalidArgument! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        labelAttribute: (self labelAttribute partMirrorCopy: aMirrorCopyDictionary);
        valueAttribute: (self valueAttribute partMirrorCopy: aMirrorCopyDictionary).
    ^copy! 
isPARTSEditor
        "Answer whether the receiver is a PARTS editor."
    ^false!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary> with mirror copies
        of each of its elements.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
    self do: [ :element |
        copy add: ( element partMirrorCopy: aMirrorCopyDictionary ) ].
    ^copy!   
displayText: aString in: aRectangle options: optionsInteger
        " Display aString in aRectangle.  optionsInteger
        specifies platform-dependent drawing options. "
    self
        partsIfOS2Do: [
            PARTSHostInterface hostWindowLibrary
                drawText: self handle asParameter
                count: aString size
                text: aString asParameter
                rect: aRectangle asParameter
                foreColor: nil
                backColor: nil
                cmd: optionsInteger ]
        partsIfWindowsDo: [
            PARTSHostInterface hostWindowLibrary
                drawText: self handle
                text: ( aString isNil ifTrue: [ '' ] ifFalse: [ aString ] )
                    asExternalString asParameter
                length: -1
                rectangle: aRectangle asParameter
                flags: optionsInteger ]! 
loadWindow: aFileName
        " Obsolete - retained for compatibility "
    ^self loadApplication: aFileName!   
eventTable
        "Private - answer the table of event handlers for the receiver."

    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]!
superWindow
        "Answer the receiver's non-frame parent window."
    ^window!   
partMainWindow
    "Private - Answer the mainWindow of the receiver, stopping
    one level below the editor pane or a window who's parent
    is nil."

    | superWindow |

    superWindow := self superWindow.
    ^( superWindow partIsWindow and: [
        superWindow isPARTSEditorPane not ])
          ifTrue: [ superWindow partMainWindow ]
          ifFalse: [ self ]!   
openWindowOn: anObject
        " Private - Obsolete - retained for PARTS for OS/2 compatibility "

    super openApplicationOn: anObject.! 
text: aString
    "Private - Set the text to be displayed"
    self updateRectangle.
    connection textValue: aString!
partMessages
        " Answer the PARTS message interface of the receiver. "

    | superMessages |
    superMessages := super partMessages.
    ^PARTSInterfaceList new
        items: (
            superMessages items,
            #( #openSegment #closeSegment ) )
                asSortedCollection asArray
        defaultItem: superMessages defaultItem! 
aboutToSaveImage
        " Private - the image is about to be saved.
        Flush the cache. "

    self emptyRecyclingBin.! 
initializeRuntimeSessionEventHandlers
        " Private - register the session event handlers for the
        PARTS runtime component
            PARTSSessionManager initializeRuntimeSessionEventHandlers
        "

    self runtimeSessionStartUpMessages do: [ :msg |
        SessionModel current isRunTime
            ifFalse: [ SessionModel current when: #startup evaluate: msg ].
        msg perform ].
    self runtimeSessionShutdownMessages do: [ :msg |
        SessionModel current when: #shutdown evaluate: msg.
        ].
    SessionModel current isRunTime
        ifFalse: [
            self runtimeSessionSaveImageMessages do: [ :msg |
                SessionModel current when: #aboutToSaveImage evaluate: msg ].
            ].!   
partWrapper
        " Answer the PARTS wrapper of the receiver. "
    ^self propertyAt: #partWrapper!   
partDirectEditValueIsValid: text
    "Answer whether the text is valid for the object's direct edit attribute."

    ^text isNil or: [ ( text occurrencesOf: $& ) <= 1 ]!  
replaceControlChars
        "This operation is not supported by the receiver."
    ^self invalidMessage!
partRealWindowUnderPoint
        " Answer the real window of interest in a PARTS Workbench. "
    ^self!
isPARTSMenuLabelPart
    "Answer whether the receiver is an instance of
    PARTSMenuLabelPart"
    ^false!
emptyRecyclingBin
        " Empty the recycling bin. "

    self recyclingBin: IdentityDictionary new.!
partMirrorCopy: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
           to aMirrorCopyDictionary.  Answer the copy.  If there are
           other fonts with the same attributes, collapse
           them into one."
    | copy |
    ^aMirrorCopyDictionary sharedObjects
            detect: [ :obj |
                obj class == self class
                and: [ obj pointSize = pointSize
                and: [ obj logicalFont asParameter = self logicalFont asParameter
                and: [ obj graphicsMedium == graphicsMedium ] ] ] ]
            ifNone: [
                copy := super partMirrorCopy: aMirrorCopyDictionary.
                aMirrorCopyDictionary sharedObjects add: copy.
                copy].!  
formatPARTSObject
        " Answer the clipboard format for a PARTS application. "
    ^self formatNamed:
        'PARTS Workbench for ',
        ( self partsIfOS2Do: [ 'OS/2' ] partsIfWindowsDo: [ 'Windows' ] ),
        ' Object'!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := self partMessagesStandard.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: (
            #(#< #<= #> #>= #max: #min: #between:and:), " same as Magnitude "
            #(#down: #extentFromLeftBottom: #extentFromLeftTop:
                #isBefore: #isLeftAndAbove: #isLeftAndBelow:
                #isRightAndAbove: #isRightAndBelow:
                #left: #leftAndDown: #leftAndUp:
                #right: #rightAndDown: #rightAndUp:
                #rightBottom: #rightTop: #transpose #up: #x #y ))
                    asSortedCollection)
        defaultItem: standardMessages defaultItem!   
loadWindow
        " Obsolete - retained for compatibility "
    ^super loadApplication!
aboutDlgClass
        "Private - Answer the aboutDlgClass."
    ^aboutDlgClass.!
recycle: anApplicationHolder
        " Private - add anApplicationHolder to the recycling bin. "
    | usedParts |

    usedParts := self recyclingBin at: anApplicationHolder class
        ifAbsentPut: [ OrderedCollection new ].
    usedParts size <= anApplicationHolder class recyclingThreshold
        ifTrue: [ usedParts add: anApplicationHolder ].!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages items |
    standardMessages := super partMessages.
    items := (standardMessages items asOrderedCollection
        remove: #add: ;
        remove: #addAll: ;
        remove: #remove: ;
        remove: #removeAll: ;
        addAll: #(
            #at: #at:put: #includesKey:
            #keyAtValue: #keys #keysSorted #removeKey:
             "exclude messages in script language which use blocks:
            at:ifAbsent: keyAtValue:ifAbsent: keysDo:
            ");
        yourself)
            asSortedCollection asArray.
    ^PARTSInterfaceList new
        items: items
        defaultItem: standardMessages defaultItem! 
runtimeSessionShutdown
        " Private - perform the session #shutdown processing
        for the PARTS runtime component. "! 
computeExtent
    "Answer the extent of the receiver"
    ^(self "class font"pen stringWidthOf: self text) + self class spacing x @
        self class height! 
runtimeSessionStartUp
        " Private - perform session startup processing
        for the PARTS runtime component. "

    | aFont |
    PARTSHostInterface startUp.
    "Common Change"
"    self partsIfWindowsDo: [ PARTSIcon startUp ]."

    " reset the point size for the current display "
    aFont := PARTSHostInterface defaultPartFont.
    aFont
        pointSize: aFont pointSize
        graphicsMedium: Display.
    aFont := PARTSHostInterface defaultPartTextFont.
    aFont
        pointSize: aFont pointSize
        graphicsMedium: Display.

    PARTSIniFile loadSearchPath.

    self partsIfOS2Do: [
        ( Smalltalk at: #OperatingSystemEventsExtra )
            at: 29999 put: #wmExternalCall:with: ].!  
runtimeSessionSaveImage
        " Private - perform the session #aboutToSaveImage processing
        for the PARTS runtime component. "

    PARTSTimerWindow aboutToSaveImage.
    PARTSApplicationHolder aboutToSaveImage.
    self partsIfOS2Do: [ (Smalltalk at: #GlobalDragDropSession) current: nil ].  " backstop cleanup "! 
partFrame
        "Private - Answer the Rectangle containing the
        shrunken icon."

    ^self partShrunkenIcon partFrame!   
partWrapper
        " Answer the PARTS wrapper of the receiver. "

    ^self propertyAt: #partsWrapper
        ifAbsent: [ nil ]! 
excludeClipRect: aRectangle
        "Create a new clipping region that consist of the existing region
         minus the specified rectangle."
    self partsVwOnly.
    ^(Smalltalk at: #GDILibrary) excludeClipRect: self handle
        x1: aRectangle left
        y1: aRectangle top
        x2: aRectangle right
        y2: aRectangle bottom.!
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not need to copy or add to aMirrorCopyDictionary
        because symbols are unique objects. "

    ^self!  
partPopUpPerformWindows
        "Popup the receiver menu at the current mouse
    location, wait for the user to make a selection,
    and perform the menu item.  This is used for
    PARTSMenuPart popups (as opposed to popups built
    for the workbench)."
   | w answer events old |
    self partsVwOnly.  " Only used on VW"

    popup := nil.
    w := Notifier activeMainWindow.
    w isNil ifTrue: [ w := Notifier windows detect: [ :arg | true ] ].
    old := Process enableInterrupts: false.
    self
        partPopUpAt: ( Cursor sense mapScreenToClient: w )
        in: w.
    [ Notifier readWinQueue ] whileTrue: [ ].
    events := CurrentEvents select: [ :msg |
            msg selector = #performMenuItem: ].
    CurrentEvents := OrderedCollection new. "discard queued
                up events like right button click"
    Process enableInterrupts: old.
    events size > 0
        ifTrue: [ answer := events last arguments at: 1 ].
    answer notNil ifTrue: [ popup performMenuItem: answer ].
    popup notNil ifTrue: [
        popup handle isValid ifTrue: [  "popup not associated with drop-down"
            window := nil .                            "zap window created by popup"
            popup destroy ].
        popup := nil ].! 
partIsShrunk
        "Private - Answer whether the receiver is shrunk
         in the PARTS Workbench."

    ^false!  
partPopUpPerform
        "Popup the receiver menu at the current mouse
    location, wait for the user to make a selection,
    and perform the menu item.  This is used for
    PARTSMenuPart popups (as opposed to popups built
    for the workbench)."
    ^self
        partsIfOS2Do: [ self partPopUpPerformOS2 ]
        partsIfWindowsDo: [ self partPopUpPerformWindows ]!   
partFinalize
        "Finalize the receiver by releasing any system resources."

    receiver partFinalize.
    arguments notNil
        ifTrue: [ arguments do: [ :a | a partFinalize ] ]!  
isPARTSMenuComponent
        "Answer whether the receiver is a PARTS
         MenuLabel, Menu, or menu item."
    ^false!  
partMirrorCopyChildren: aDictionary to: copy
        " Private - mirror copy the child windows "
    copy children: (children partMirrorCopy: aDictionary).!
partContainingWindow
        "Answer the non-frame visible window containing the receiver."

    ^self superWindow!
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #asCharacter #factorial #gcd: #lcm: )
                asSortedCollection)
        defaultItem: standardMessages defaultItem!   
partReverseEmphasis: aRectangle
        "Reverse aRectangle with a dotted line.  This is
    used for target emphasis."
    | pen emphasisRect |

    emphasisRect := aRectangle mapToScreen: self.
    pen := Display pen.
    pen isNil    "FrameWindow likely"
        ifFalse: [
            pen
                setLineWidth: 1;
                setLineType: "LineTypeDot" 0;
                setForegroundMode: MixRuleInvertSurface;
                rectangle: emphasisRect;
                setLineType: LineTypeDefault ]!   
setFromReference: anExternalAddress
        "Private - Copy the bytes from anExternalAddress back to self,
        dropping the zero termination."
    | flatAddr |
    (anExternalAddress isKindOf: ExternalSegmentedAddress)
        ifTrue: [self setFromReference16: (flatAddr := anExternalAddress asFlatAddress).
                    flatAddr releaseFlatAddress]
        ifFalse: [self setFromReference32: anExternalAddress]!
displayAt: aPoint
        "Display the icon at aPoint with Display pen."
    self displayAt: aPoint with: Display pen!  
partShrink
        "Private - Shrink the window inside the PARTS Workbench."
    | icon partEditorPane wrapper |
    (icon := self partShrunkenIcon) isNil
        ifTrue: [
            MessageBox warning: 'Cannot find part file on search path.  Will not shrink.'.
            ^nil].
    wrapper := self partWrapper.
    self partIsShrunk
        ifTrue: [ "wrapper has correct framer, us it to compute icon position."
            self partPositionShrunkenIcon ]
        ifFalse: [
                wrapper rectangle: icon framer.
            self partIsShrunk: true ].
    partEditorPane := self partEditorPane.
    partEditorPane selectOff: self.

    self hideWindow.

    self superWindow isPARTSEditorPane
        ifTrue: [
            partEditorPane
                addIcon: icon;
                addIconToSelection: icon ].!  
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "

    ^self contents!  
isPARTSTextIcon
    "Answer whether the receiver is an instance
    of PARTSTextIcon"
    ^false!  
runtimeSessionSaveImageMessages
        " Private - answer the session #aboutToSaveImage handlers
        for the PARTS runtime component. "

    ^OrderedCollection new
        add: ( Message
            receiver: self
            selector: #runtimeSessionSaveImage );
        yourself!
openApplication
        " Private "

    self loadApplication isNil
        ifTrue: [ ^nil ].
    self application open.!
getMenuItemFromIndex: anIndex
        "Private - Answer the MenuItem for anIndex. "
    ^items at: anIndex! 
asMonochrome
        "Answer a new instance of the receiver as a monochrome bitmap."
    | mono bits |
    self partsVwOnly.
    bits := self getDIBits.
    mono := self class new
        width: self width
        height: self height.
    mono setDIBits: bits using: bitmapInfo.
    ^mono!
partEditor
        " Answer the PARTS Workbench in which the receiver is being edited. "
    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^nil ].
    ^myWrapper partEditor!  
controllee
        " Answer the controllee of the receiver. "
    ^self propertyAt: #controllee!
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true! 
partName: aName
        " Set the part name to the requested name or the closest
        legal approximation that is acceptable to the user.
        Answer the new name if successfully changed. "
    | aWrapper requestedName newName icon |
    (aWrapper := self partWrapper) isNil
        ifTrue: [ ^nil ].  " not a part "
    requestedName := aName trimBlanks.
    requestedName = aWrapper name
        ifTrue: [ ^requestedName ].
    newName := aWrapper application
        generatePartNameFor: self
        preference: requestedName.
    newName = requestedName
        ifFalse: [
            (MessageBox confirm:
                    '''', requestedName,
                    ''' is  not a valid name, is ''', newName, ''' ok?')
                ifFalse: [ ^nil ]] .
    aWrapper changeNameTo: newName.
    "self ASSERT: aWrapper name = newName."
    icon := aWrapper icon.
    (icon isPARTSIcon and: [icon parent notNil])
        ifTrue: [
            icon parent
                changeIconLabel: icon
                to: newName ].
    ^newName!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (self partMessagesStandard items,
            #(
            #directory #name #pathName
            "Not sure we ought to surface this:
            close  flush getDate setDate: size
            "
            )) asSortedCollection asArray
        defaultItem: #pathName!  
isPARTSTextIcon
    "Answer whether the receiver is an instance
    of PARTSTextIcon"
    ^true!   
loadApplication: aFileName
        " Private - load the application in aFileName.
        Answer the application (nil if failed). "

    [ CursorManager execute changeFor: [
        application := PARTSApplication loadPartFile: aFileName ]]
        on: PARTSApplicationLoadError
        do: [ :anException |
            anException postMessageBox.
            ^application := nil ].

    application isNil "Backstop: Should have raised an error"
        ifTrue: [ ^nil ].
    application enableExecution.
    self initializeParts.
    ^application!   
childWindowFromPoint: hwnd pointX: xInteger pointY: yInteger
    <api: ChildWindowFromPoint ulong long long ushort>
    ^self invalidArgument!  
openModalDialog: dialogPartName
        " Private - open a PARTS application which
        opens a dialog from which we need an answer. "

    self loadApplication isNil
        ifTrue: [ ^nil ].
    ( self partNamed: dialogPartName )
        setWaitForAnswer: true;
        allowWorkbenchToBeDisabled: true.
    self application open.! 
isPARTSException
        "Answer whether the receiver is a kind of PARTSException."
    ^false! 
removeRuntimePlatformEvents
        " Private - register host events which are needed
        by the PARTS runtime component. "!
runtimeSessionShutdownMessages
        " Private - answer the session #shutdown handlers
        for the PARTS runtime component. "

    ^OrderedCollection new
        add: ( Message
            receiver: self
            selector: #runtimeSessionShutdown );
        yourself!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy aClass size |
    aMirrorCopyDictionary at: self put: (copy := self copy).  "so that variable
        objects will have correct size"
    ( aClass := self class ) isPointers
        ifFalse: [ ^copy ].
    ( size := self basicSize + aClass instSize ) = 0
        ifTrue: [ ^copy ].
    1 to: size do: [ :index |
        copy
            instVarAt: index
            put: ( (self instVarAt: index) partMirrorCopy: aMirrorCopyDictionary ).
        ].
    ^copy!   
asNormalizedRectangle
        " Answer a normalized rectangle whose rightBottom
        is below and to the right of its leftTop."
    ^Rectangle
        leftTop: (leftTop leftMostAndHighest: rightBottom)
        rightBottom: (leftTop rightMostAndLowest: rightBottom)! 
partIsWindow
        "Answer true if the receiver is a window else false."

    ^true! 
partOpen
        " Display the receiver when it is being edited
        in a PARTS Workbench. "
    | myWrapper workbenchPane icon |
    ( (myWrapper := self partWrapper) isNil
    or: [ (workbenchPane := myWrapper workbenchPane) isNil ] )
        ifTrue: [ ^false ].
    icon := myWrapper icon.
    icon origin: ( myWrapper rectangle isPARTSRectangle
        ifTrue: [
            "Since framer is relative to top left, changing workbench
                rectangle size shouldn't have an effect (esp. on OS/2)."
            (myWrapper rectangle scaleFrom:
                ( 0 @ 0 extent: workbenchPane extent ))
                origin ]
        ifFalse: [ myWrapper rectangle origin ] ).
    workbenchPane addIcon: icon at: icon origin.
!  
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "
   ^super partMirrorCopyPropertiesToExclude,
        #( #entryField )!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
extent
    ^rectangle isNil
        ifTrue: [self computeExtent]
        ifFalse: [rectangle extent]!  
releaseBitmaps
        "Do nothing, TextIcons have no system resources."!
partWrapper: aWrapper
        " Private - set the PARTS wrapper of the receiver. "
    self propertyAt: #partWrapper put: aWrapper! 
partHint
        "Answer a string which gives a brief description
        of the receiver part. "
    ^self!   
font
        " Answer the font of text icons "

    ^( Smalltalk at: #PARTSSettings ifAbsent: [ ^SysFont ] ) current
        fontIconLabels!  
connectionPrivate
    "Answer the part associated with the receiver.
    Needed for compatibility with PARTSIcon"

    ^connection!   
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "

    | excludedProperties |
    excludedProperties := OrderedCollection new: 2.
    self backColor = self defaultBackColor
        ifTrue: [ excludedProperties add: #backColor ].
    self foreColor = self defaultForeColor
        ifTrue: [ excludedProperties add: #foreColor ].

   ^excludedProperties asArray!
isPARTSMenuItem
        " Answer whether the receiver is a PARTS
         MenuItemField, BitmapMenuItem, or MenuSeparator."
    ^false!
isPARTSDirectEditor
    "Answer whether the receiver is used as
    a direct editor."
    ^false!  
partBringSubPaneToTop
    "Bring the receiver to the top."

    self
        partsIfOS2Do:
            [self frameWindow handle
            setWindowPos: ( PARTSConstants at: 'SwpHwndTop' )
            rectangle: (0 @ 0 corner: 0 @ 0)
            fs: (PARTSConstants at: 'WindowBringToTopFlags') ]
        partsIfWindowsDo: [self bringToTop]!   
partPopUpAtWindows: aPoint in: aWindow
    "Private - Popup the receiver menu at aPoint in aWindow.
    This is used for PARTSMenuPart popups (as opposed to
    popups built for the workbench)."
    | pt height |

    popup isNil ifTrue: [ "not cached, rebuild"
        popup := PARTSPopupWindowWindows new.
        popup addMenu: self.
        ( window notNil and: [ window isValid ] )
            ifTrue: [   "use drop-down menu as popup window"
                popup
                    baseMenuId: menuItem id;
                    addMenusForPopup ]
            ifFalse: [ popup buildPopupWindow ]].

    height := self numberOfItems + 1 * SysFontHeight.
    pt := aPoint leftAndUp: ( SysFont width * 3 @ ( height // 2 ) ).
    pt y: ( pt y higherOf: ( Display extent - height
        mapScreenToClient: aWindow ) y).
    popup menus first window
        popUpAt: pt
        in: aWindow! 
isPARTSMenuTextItemPart
        "Answer whether the receiver is a PARTSMenuTextItemPart."
    ^false!   
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not need to copy or add to aMirrorCopyDictionary
        because booleans are unique objects. "

    ^self! 
archiveAndRelease
        " Added here to be polymorphic with Bitmap class "

    self release!
partContents
        "Answer the contents of the receiver."
    | partContents |
    partContents := self contents.
    ^partContents isNil ifTrue: [ #() ] ifFalse: [partContents]!  
partsExceptionIfNil
        "Answer a PARTSException if the receiver is nil
        or self if not nil.  Do nothing, answer self."! 
partEnableExecution
        " The application containing the receiver
        is going to be executed.  Do anything necessary
        to make the receiver behave properly during execution. "

    "Strip the wrappers if possible"
    ( PARTSWrapper keepInExecutable
        or: [ self partWrapper partIsDebugging ])
        ifFalse: [
            "#myOwnName is the same symbol used by Window>>setName:"
            self propertyAt: #myOwnName put: self partName.
            self partWrapper: nil.  ] "Remove the wrapper for execution."!  
loadApplication
        " Private - load the application specified by my fileName.
        Answer the application (nil if failed). "

    application notNil
        ifTrue: [  " previously loaded, just reset the application state "
            self resetParts.
            ^application ].
    ^self loadApplication: self fileName!
is: object1 greaterEqual: object2
        "Obsolete - retained for compatibility with PW 2.0."

    ^self is: object1 greaterThanOrEqualTo: object2!   
isPARTSLoadContext
        " Answer whether the receiver is the clientContext of a PARTS application
        load operation. "

    ^false!   
scaleUnit
    "Private - Answer the scale unit of the receiver"
    | app |

    app :=
        self parent notNil
            ifTrue: [ self parent partApplication ]
            ifFalse: [
                ( connection notNil and: [
                    connection isPARTSCatalogIconConnection not ])
                    ifTrue: [ connection partApplication ]
                    ifFalse: [ nil ]].
    ^app notNil
        ifTrue: [ app defaultScaleUnit ]
        ifFalse: [ PARTSFramer defaultScaleUnit ].
!
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  When aSelector is an alias message,
        the answer must be a two-argument message
        selector, whose first argument will be aSelector
        and whose second is the arguments originally
        sent with message aSelector. "

    ^aSelector!  
ownerWindow
        "Answer the owner window of the receiver."

    ^self propertyAt: #ownerWindow ifAbsent: [ nil ]!  
partNewValueEvent
        "Answer the selector of the one-argument event
        which is triggered by the receiver when its value
        has been changed. "
    ^#changed:!
partCanHaveChild: anObject
        "Answer whether the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^false!  
partDeselect
        " Deselect the receiver in the containing PARTS Workbench. "!   
partShrinkableAncestor
    "Answer the ancestor that can be shrunk on the workbench"
    | ancestor |

    ^self partIsShrinkable
        ifTrue: [
            ( ancestor :=self superWindow partShrinkableAncestor ) isNil
                ifTrue: [ self ]
                ifFalse: [ ancestor ] ]
        ifFalse: [ self superWindow partShrinkableAncestor ]!  
visibleExtent
    "Private - Compatibility with PARTIcon.
    Answer the extent."

    ^self extent!  
isPARTSToolbox
	" Answer if the receiver is a PARTSToolboxPart "

	^false! 
partEditorPane
        " Private - answer the PARTS Workbench pane
        in which the receiver is being edited.  Answer nil
        if not a part or not being edited. "
    ^self partIsEditing
        ifTrue: [ self partEditor workbenchPane ]
        ifFalse: [ nil ]!  
partDirectEditValueIsValid: text
    "Answer whether the text is valid for the object's direct edit attribute."

    ^true!
keysAsArray
        "Answer a collection containing all the keys
         in the receiver."

    | answer |
    answer := OrderedCollection new: self size.
    1 to: contents size by: 2 do: [ :index |
        (contents at: index) == nil
            ifFalse: [answer add: (contents at: index)]].
    ^answer!  
PARTSRuntimeSessionManager removeRuntimeComponent!
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not need to copy or add to aMirrorCopyDictionary
        because characters are unique objects. "

    ^self!   
partParent
        " Answer the parent part of the receiver. "
    | myWrapper aWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^nil ].
    ( aWrapper := myWrapper parent ) isNil
        ifTrue: [ ^nil ].
    [ aWrapper object isPARTSTransientPart ]
        whileTrue: [ aWrapper := aWrapper parent ].
    ^aWrapper object!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^PARTSInterfaceList new
        items: (
            standardMessages items,
            #( #add: #addAll: #remove: #removeAll: #removeAll ) )
                asSortedCollection
        defaultItem: standardMessages defaultItem!   
partFrameRectangleFrom: aRectangle
        " Private - answer the framing rectangle
       to use for the receiver part, given aRectangle. "
    ^aRectangle!  
openWindow
        " Private - Obsolete - retained for PARTS for OS/2 compatibility "

    super openApplication.! 
fromBytes: aByteArray
        "Private - Answer an instance of the receiver represented in aString."
    ^self fromFileStream: ( ReadWriteStream on: aByteArray asString )! 
isPARTSNotebookPagePane
        "Answer whether the receiver is a notebook."
    ^false!
isPARTSRectangle
        "Answer whether the receiver is a PARTS sizing rectangle. "
    ^false!
visibleFrame
        "Answer the system rectangle containing the icon."
    ^self partFrame!
name
    "Answer the part name of the part associated with
    the receiver"

    ^connection partName!   
isPARTSNotebookClientAreaPane
        " Answer whether the receiver is a client area
        pane in a notebook. "
    ^false! 
partShrinkWrap
        "Private - Answer the parent window which can be shrunk in
        the parts window."
    ^self parent partShrinkWrap!  
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "

    self partWrapper: myWrapper.
    owner := myWrapper application.!  
isPARTSMenuSeparatorPart
    "Answer whether the receiver is an instance
    of PARTSMenuSeparatorPart"
    ^false!
initializePartValues
        " Private - the application has just been loaded or is
        is being recycled from the cache after previous use.
        Initialize the state of parts in the application.
        Default is to do nothing. "!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := self partMessagesStandard.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #bottom #center #containsPoint: #extent #extent:
            #height #left #leftBottom #leftTop
            #right #rightBottom #rightTop #top #width )
                asSortedCollection)
        defaultItem: standardMessages defaultItem!
mainWindowsSelect: aOneArgBlock
        "For each main window in the receiver, evaluate
         aOneArgBlock with that window as the argument.
         Answer a new collection containing those windows
         for which aOneArgBlock evaluates to true."
    | selectedWindows |
    selectedWindows := OrderedCollection new.
    windows do: [ :aWindow |
        (aWindow isApplicationWindow
        and: [aOneArgBlock value: aWindow])
            ifTrue: [selectedWindows add: aWindow]].
    ^selectedWindows!   
partDefaultExtent
    " Answer the default extent of the receiver
    in a PARTS application. "

    | myFont |

    myFont := self partFontOrSysFont.
    ^(myFont width * 12) @ (myFont lineSpacing + 6)!
new
        " Answer an instance of the receiver.  Recyle
        a used part if possible. "

    | usedParts anApplicationHolder |
    usedParts := self recyclingBin at: self
        ifAbsent: [ #() ].
    usedParts notEmpty
        ifTrue: [
            anApplicationHolder := usedParts removeLast.
            anApplicationHolder initialize.
            ^anApplicationHolder ].
    ^super new initialize!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #addDays:
            #dayName #dayOfMonth
            #daysInMonth #daysInYear
            #monthIndex #monthName
            #subtractDays:
            #year )
                asSortedCollection)
        defaultItem: standardMessages defaultItem!  
validate
        "Do nothing."!  
partExpand
        "Private - Expand the shrunken window inside
        the PARTS Workbench."
    | icon partEditorPane |
    partEditorPane := self partEditorPane.
    icon := self partShrunkenIcon.
    self partIsShrunk: false.  "This must follow the above, otherwise
        icon rectangle will be wrong."

    self partWrapper rectangle: self framingBlock.  "Change from icon rectangle"

    partEditorPane
        deselectIcon: icon;
        basicRemoveIcon: icon.

    self showWindow.!   
partPopUpAt: aPoint in: aWindow
    "Private - Popup the receiver menu at aPoint in aWindow.
    This is used for PARTSMenuPart popups (as opposed to
    popups built for the workbench)."

    self
        partsIfOS2Do: [
				^self partPopUpAtOS2: aPoint in: aWindow ]
        partsIfWindowsDo: [
				self partPopUpAtWindows: aPoint in: aWindow ]!  
openModalDialog: dialogPartName on: anObject
        " Private - open a PARTS application which
        opens a dialog from which we need an answer. "

    self loadApplication isNil
        ifTrue: [ ^nil ].
    ( self partNamed: dialogPartName )
        setWaitForAnswer: true;
        allowWorkbenchToBeDisabled: true.
    self application openOn: anObject.!
partDefaultExtent
        " Answer the default extent of the button which
        is a little taller than most. "

    ^super partDefaultExtent + (0 @ 2)!
asPARTSIcon
        "Answer a real PARTSIcon which can be used in
        place of the receiver."

    ^(
        [ PARTSFile iconFromFile: connection class iconFileName ]
            on: Error
            do: [ : e | PARTSApplication defaultIcon ] )
        origin: self origin!   
application
        " Answer the PARTS application. "

    ^application!   
rawText
    "Answer the recevier's part's value"
    ^connection value asString!
setPARTSObject: anObject
        "Set the contents of the clipboard to anObject from PARTS."
    self setObject: anObject format: self formatPARTSObject!   
name: aString
    "Set the part name of the part associated with
    the receiver"
    connection partWrapper notNil ifTrue: [
        connection partWrapper name: aString]! 
launchExecutablePart
    "Load and launch a PAX file which has the same name as
    the Smalltalk EXE.  Exit Smalltalk if cannot find the file.  "
    | anApplication pathName |

    pathName := SessionModel current exeName,'.pax'.
    [ anApplication := PARTSApplication fromFile: pathName ]
        on: PARTSApplicationLoadError
        do: [ :e |
            MessageBox notify: 'Application Launch Error'
                withText: (
                    ( PARTSInvalidApplication handles: e )
                        ifTrue: [
                            'Unable to start ', pathName,
                            ' (not an executable PARTS application).' ]
                        ifFalse: [ e messageText ]).
                    Smalltalk exit ].
        anApplication open !   
getNearestColor: hdc color: aColor
    <api: GetNearestColor ulong ulong ulongReturn>
    ^self invalidArgument!
button1Down: aPoint
    "Do nothing. Compatibility with PARTSIcon"!  
partDirectEditTextIsCentered
        "Answer whether the receiver's text should be
        centered during direct-editing."
    ^false!
partFrameRectangleFrom: aRectangle
        " Private - answer the framing rectangle
       to use for the receiver part, given aRectangle. "

    aRectangle isPARTSRectangle ifTrue: [ ^aRectangle ].

    ^PARTSFramer
        forRectangle: aRectangle
        in: self superWindow!   
recyclingBin: anIdentityDictionary
        " Private - set the recycling bin. "

    RecyclingBin := anIdentityDictionary.!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    self font ~= self defaultFont
        ifTrue: [  copy curFont: ( curFont partMirrorCopy: aMirrorCopyDictionary ) ].
    copy
        framingBlock: ( framingBlock partMirrorCopy: aMirrorCopyDictionary );
        id: ( id partMirrorCopy: aMirrorCopyDictionary );
        handlersAttribute: ( self handlersAttribute partMirrorCopy: aMirrorCopyDictionary ).

    ^copy! 
partContainingWindow
        "Answer the non-frame visible window containing the receiver."

    ^self superWindow!
setFromReference16: aFlatExternalAddress
        "Private - Copy the bytes from aFlatExternalAddress back to self,
        dropping the zero termination."
    self replaceFrom: 1
        to: self size
        withAddress: aFlatExternalAddress
        startingAt: 1.
    ^self!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | bits copy |
    copy := self class new.
    bits := ( archive isNil
        ifTrue: [ self getDIBits ]
        ifFalse: [ archive ] ).
    copy
        archive: bits;
        bitmapInfo: bitmapInfo deepCopy;
        "deviceContext: Bitmap memoryContext;"
        pen: (Pen for: nil medium: copy).
	self partsIfWindowsDo: 
		[ copy deviceContext: Bitmap memoryContext ].
    "palette will be recreated for new bitmap."
    aMirrorCopyDictionary at: self put: copy.
    ^copy!   
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not need to copy or add to aMirrorCopyDictionary
        because nil is a unique object. "

    ^self!  
partOpen: validate
    " Display the receiver when it is being edited
    in a PARTS Workbench, or being built by a nested
    part for run time.  Validate if <validate> is true."
    | superWindow parentRectangle |

    superWindow := self superWindow.
    parentRectangle := superWindow freeClientArea.
    self
        initSize: parentRectangle;
        open;
        buildWindow: superWindow;
        resize: parentRectangle.

    "Parts are added to the end of the ordered children,
        make workbench z-order reflects this."
    self partIsEditing
        ifTrue: [ self partBringSubPaneToBottom ].

    validate ifTrue: [ self validate ].! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        fontHandle: nil;
        physicalFontAttribute: nil.
    ^copy!
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
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver, adding it
        to <aMirrorCopyDictionary> if not already registered."
    | result |

    "Take mirror copy real out of the block to reduce stack size"
    ( result :=
        aMirrorCopyDictionary
            at: self
            ifAbsent: [ #uniqueMirrorCopyFlag ]) == #uniqueMirrorCopyFlag
        ifTrue: [ result := self partMirrorCopyReal: aMirrorCopyDictionary ].
    ^result
! 
initializeEventHandlers
        " Private - the application has just been loaded.
        Register event handlers for parts in the application.
        Default is to do nothing. "!   
fileName
        " Private - answer the file containing the PARTS
        application definition.  If no file type extension
        is specified, open the first file with the given name
        in the PARTS search path.  If multiple types found in 
        the same directory, open editable .PAR if available, 
        else open the executable .PAX file. "

    ^self implementedBySubclass!   
isLeftAndAboveOrEqual: aPoint
        "Answer true if the x and y coordinates of the
         receiver are above and to the left of the x and y coordinates
         of aPoint, respectively, else answer false."
    ^(x isLeftEqualOf: aPoint x) and: [y isAboveEqual: aPoint y]!   
controller
        " Answer the controller of the receiver. "
    ^self propertyAt: #controller!
resetParts
        " Private - reset the state of parts in an application
        which has been previously executed. "

    self initializePartValues.!  
isNewString: newString differentFrom: oldString
        " Private - answer whether the newString is different
        than the oldString. "

    ( ( oldString size = 0 ) and: [ newString size = 0 ] )
        ifTrue: [ ^false ].    " both nil or empty "
    newString size > 0   " new value"
        ifTrue: [ ^newString ~= oldString ].
    "self ASSERT: ((newString size = 0) and: [oldString size > 0])."
    ^true!  
partShrunkenIconFile
        " Private - answer the name of the part file containing
        the icon to display when the receiver is shrunk
        in a PARTS Workbench window. "
    self implementedBySubclass!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages items |
    standardMessages := super partMessages.
    items := (standardMessages items asOrderedCollection
        remove: #add:after: ;
        remove: #add:afterIndex: ;
        remove: #add:before: ;
        remove: #add:beforeIndex: ;
        remove: #addFirst: ;
        remove: #addLast: ;
        yourself)
            asSortedCollection asArray.
    ^PARTSInterfaceList new
        items: items
        defaultItem: standardMessages defaultItem!
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^false!
label: aString
        " Set the receiver's icon label.  Do nothing for a text icon,
        whose label is its value. "!   
releaseEventTable
        "Private - break all connections to event handlers."

    eventTable := nil.!
paneAt: aString
        " Answer the pane whose name is aString. 
        Provides protocol compatibility with ViewManager. "
    ^self partNamed: aString!
installRuntimeComponent
        " Install the PARTS runtime component
            PARTSRuntimeSessionManager installRuntimeComponent
        "

    self
        initializeBaseSystemClasses;
        initializeFileAccessorClass;
        initializeRuntimeData;
        initializeRuntimePlatformEvents;
        initializeRuntimeSessionEventHandlers.
!
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^PARTSLink!  
updateRectangle
    "Set the rectangle of the receiver"

    rectangle := rectangle origin extent: self computeExtent! 
removeRuntimeData
        " Private - clean up runtime data in the environment. "

    Clipboard containsPARTSObject
        ifTrue: [ Clipboard setString: '' ].
    ClipboardManager userFormats
        removeKey: ( ClipboardManager userFormats keyAtValue: Clipboard formatPARTSObject ).!
text
    "Private - Answer the text to be displayed"
    | string |
    string := self rawText.
    ^string size > self maxLengthForDE
        ifTrue: [(string copyFrom: 1 to: self maxLengthForDE - 3), '...']
        ifFalse: [string]! 
partAsExecutableAction
        " Private - answer the receiver as an action for an executable
        PARTS application. "

    ^self!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary> with mirror copies
        of each of its elements.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self species new).
    self associationsDo: [ :element |
        copy add: ( element partMirrorCopy: aMirrorCopyDictionary ) ].
    ^copy! 
partsDrawFrame: rect
        "Draw the tracking frame rectangle."
    self
        partsIfOS2Do: [
            self
                place: rect origin;
                box: rect corner ]
        partsIfWindowsDo: [
            PARTSHostInterface hostWindowLibrary
                drawFocusRect: self handle
                rectangle: rect asParameter ]!   
isIcon
    ^true!
partDefineEvent: eventName
        " Define the instance event named eventName.
        Answer the event name (nil if not legal). "
    | myWrapper |
    (myWrapper := self partWrapper) isNil
        ifTrue: [self error: 'not a part'].
    ^myWrapper defineEvent: eventName!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standard |
    standard := super partMessages.
    standard items:
        (standard items asOrderedCollection
            remove: #at:put: ;
            remove: #replaceControlChars ;
             yourself)
                asArray.
    ^standard!  
partDroppedControlRectangle
        " Private - Answer the bounding rectangle of the combo box
        including the dropped down listbox "
    | rectStruct |
    self partsVwOnly.
    rectStruct := (Smalltalk at: #WinRectangle) new.
    (Smalltalk at: #UserLibrary)
        sendMessage: self asParameter
        msg: 16r152 "( (Smalltalk at: #WinConstants) at: 'CbGetdroppedcontrolrect' )"
        wparam: 0
        lparamStruct: rectStruct asParameter.
    ^rectStruct asRectangle!
isPARTSCatalogIconConnection
        " Answer whether the receiver is PARTS catalog icon connection. "
    ^false!  
copyToExternalAddress
        "Answer an ExternalAddress pointing to memory
        containing a copy of the receiver with a null byte
        at the end."
    ^ExternalAddress copyToNonSmalltalkMemory: self asParameter!  
fromBytes: aByteArray
        "Private - Answer an instance of the receiver represented in aString."
    ^self fromFileStream: ( ReadWriteStream on: aByteArray asString )! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (self partMessagesStandard items,
            #(
            #atEnd #close #contents #copyFrom:to: #cr
            #file #flush #isEmpty
            #lineDelimiter #lineDelimiter:
            #next #next: #next:put: #nextLine #nextPut: #nextPutAll:
            #nextWord #pathName
            #peek #peekFor: #position #position:
            #reset #setToEnd #size
            #skip: #skipTo: #space #tab #truncate #upTo:
            )) asSortedCollection asArray
        defaultItem: #size! 
initializeRuntimeData
        " Private - initialize values in the runtime component
        which have to be set at installation time (certain class vars
        which couldn't be put in the component file). "

    PARTSFile setDefaultSearchPath.
    PARTSFile fileAccessorClass
        initializeAccessorForCurrentVersion.
    PARTSFile initializeUpgradeChangeMaps.

    PARTSWindowPart initializeRuntimeData.

    (Smalltalk includesKey: #PARTSApplicationDefaultIcon)
        ifTrue:
            [PARTSApplication defaultIcon: ( Smalltalk at: #PARTSApplicationDefaultIcon ).
                "Smalltalk removeKey: #PARTSApplicationDefaultIcon"].

    self partsIfOS2Do: [
        ( SelfDefinedStructure definitions keys includes: 'WNDPARAMS' ) not
            ifTrue: [   " copy literals so structure can be left defined if the library is unbound "
                SelfDefinedStructure
                    define: 'WNDPARAMS' copy
                    withFields: ( Dictionary new
                        at: #fsStatus put: #( 0 #ulong #yourself ) copy;
                        at: #cchText put: #( 4 #ulong #yourself ) copy;
                        at: #pszText put: #( 8 #ulong #yourself ) copy;
                        at: #cbPresParams put: #( 12 #ulong #yourself ) copy;
                        at: #pPresParams put: #( 16 #ulong #yourself ) copy;
                        at: #cbCtlData put: #( 20 #ulong #yourself ) copy;
                        at: #ctlData put: #( 24 #ulong #yourself ) copy;
                        yourself ) ].
        ].!
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #add: #addAll:
            #add:after: #add:afterIndex: #add:before: #add:beforeIndex:
            #addFirst: #addLast:
            "exclude messages in script language using blocks:
            findFirst: findLast: indexOf:ifAbsent:
            remove:IfAbsent: reverseDo: with:do:
            "
            #remove: #removeAll #removeAll: #removeFirst #removeLast )
                asSortedCollection)
        defaultItem: standardMessages defaultItem!  
partIsWindow
        "Answer true if the receiver is a window else false."

    ^false
!  
updateSliders
        " Private- update the slider boxes in the receiver's scroll bars."!
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^false!
valuesAsArray
        "Answer an array containing all the values of the
         key/value pairs in the receiver."

    | answer index |
    answer := Array new: self size.
    index := 1.
    self associationsDo: [ :assoc |
        answer at: index put: assoc value.
        index := index + 1].
    ^answer!   
partMirrorCopy: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to aMirrorCopyDictionary.  Answer the copy.
        Don't mirror copy Display, becuase there is only one instance."
    ^self == Display
        ifTrue: [self]
        ifFalse: [super partMirrorCopy: aMirrorCopyDictionary].!
openApplicationOn: anObject
        " Private "

    self loadApplication isNil
        ifTrue: [ ^nil ].
    self application openOn: anObject! 
partMessagesStandard
        " Answer the standard messages described
        in the LAF script language for all components. "
    ^PARTSInterfaceList new
        items: #(
            #= #~= #== #~~ #isNil #notNil
            #copy #deepCopy
            #printString #yourself)
        separators: #()
        defaultItem: #copy!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy.
        Set the height explicitly because the font is set
        indirectly through the property mirror copy."

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy listAttribute: (list partMirrorCopy: aMirrorCopyDictionary).
    copy itemHeight: ( height partMirrorCopy: aMirrorCopyDictionary  ).
    ^copy!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#enable #disable #setFocus)
        defaultItem: #disable!  
isPARTSMenuPart
            "Answer whether the receiver is an instance of PARTSMenuPart"
    ^false!   
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not copy or add to aMirrorCopyDictionary because
        execution contexts are special objects. "

    ^self
!
showLabel: aBoolean
    "do nothing"!
partShrunkenIcon: anIcon
        " Private - cache the shrunken icon "
    self propertyAt: #PARTSShrunkenIcon put: anIcon.
    anIcon notNil
        ifTrue: [ anIcon connection: self ]!
partDragTargetFormatsDefault
    "Private - answer the default drag formats."

    ^#('string').!  
resizeToRectangle: aRectangle
        " Resize the receiver to aRectangle, whose coordinates
        are relative to my parent."
    rectangle := aRectangle.
    self resizeWindow.! 
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not need to copy or add to aMirrorCopyDictionary
        because symbols are unique objects. "

    ^self!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (self partMessagesStandard items,
            #(
            #drive #drivePathName #pathName
            #makeCurrent #create #remove #subdirectories
            #newFile: ))
                asSortedCollection asArray
        defaultItem: #pathName!
partAboutToAddTo: anApplication
        "The receiver is about to be added as a part to
        anApplication.  Initialize the receiver
        and answer the appropriate object to represent
        it in the containing PARTS application. "
    ^self!  
isPARTSMenuBar
        "Answer whether the receiver is a PARTS MenuBar."

    ^false!  
partEditor
        " Answer the PARTS Workbench in which the receiver is being edited. "
    ^(owner respondsTo: #partEditor)
        ifTrue: [ owner partEditor ]
        ifFalse: [ nil ]!  
pen
    "Answer a pen used to display the receiver"

    ^window isNil ifTrue: [Display pen] ifFalse: [window pen]!
getMenuItem: anInteger
        "Private - Answer the menu item whose id is anInteger."
    | menu |
    menu := allMenus at: (anInteger // 256).
    ^menu selectorOf: anInteger! 
height
    "Private"
    ^self font height + self spacing y!
recyclingBin
        " Private - answer the recycling bin containing used parts. "

    ^RecyclingBin! 
getTopWindow: aWindowHandle
    <api: GetTopWindow ulong  ulongReturn>
    ^self invalidArgument!   
partNeedsResizeToContents
        " Private - answer whether the receiver needs to
        be resized to install a property edit change. "
    ^false! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
containsPoint: aPoint
    "Answer whether <aPoint> is within the receiver"
    ^self rectangle containsPoint: aPoint!   
partPopUpInWindows: aWindow
        "Popup the receiver menu at the current mouse
         location within aWindow, wait for the user to
         make a selection, and answer the selector of
         the selected item or nil if the user selected
         nothing."
    | w events p old oldPopup |
    popup := nil.
    w := aWindow.
    w isNil ifTrue: [ w := Notifier windows detect: [ :arg | true ] ].
    "Temporarily associate the receiver with the instance variable
      'popup' in SubPane so that popup menu help would work. [LN 15-Oct-93]"
    w isSubPane ifTrue: [
        oldPopup := w popup.
        w setPopupMenu: self ].
    old := Process enableInterrupts: false.
    self
        popUpAt: ( Cursor sense mapScreenToClient: w )
        in: w.
    [ Notifier readWinQueue ] whileTrue: [ ].
    events := CurrentEvents select: [ :msg |
            msg selector = #performMenuItem: ].
        "discard queued up events like right button click"
    CurrentEvents := OrderedCollection new.
    Process enableInterrupts: old.
    popup destroy.
    p := popup.
    popup := nil.
    w isSubPane ifTrue: [  w setPopupMenu: oldPopup ].
    ^events size = 0
        ifTrue: [ nil ]
        ifFalse: [ p selectorOf: ( events last arguments at: 1 ) ]!
resetParts
        " Private - reset the state of parts in an application
        which has been previously executed.
        Default is to do nothing. "! 
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "

    | icon |
    myWrapper icon isIcon
        ifTrue: [ icon := myWrapper icon ]
        ifFalse: [
            icon := ( ( self respondsTo: #icon )
                ifTrue: [ self icon ]
                ifFalse: [ PARTSApplication defaultIcon ] ).
            myWrapper icon: icon ].
    icon showLabel: true.
    self partWrapper: myWrapper.
    ^self!
isPARTSCatalog
        "Answer whether the receiver is a PARTS catalog."
    ^false!
partOnTopWhenSelected
        "Answer true if the receiver can be brought to
         to the top when it is selected in the workbench."
    ^false!
parent
    ^window!  
partNeedsResizeToContents
        " Private - answer whether the receiver needs to
        be resized to install a property edit change. "
    ^true!  
runtimeSessionStartUpMessages
        " Private - answer the session #startUp handlers
        for the PARTS runtime component. "

    ^OrderedCollection new
        add: ( Message
            receiver: self
            selector: #runtimeSessionStartUp );
		yourself.!  
partControlInGroupBoxWindows: aPoint
        "Private - Answer the child window inside the group box
          that contains aPoint, where aPoint is relative to the screen."

    | sibling  |
    sibling := self.
    [ sibling := Notifier findWindow:
        ( PARTSHostInterface hostWindowLibrary
            getWindow: sibling handle
            relationship: (PARTSConstants at: 'GwHwndPrev' )).
    sibling notNil ] whileTrue: [
        ( sibling frameRectangle containsPoint: aPoint )
            ifTrue: [
                sibling isGroupBox
                    ifTrue: [
                        ( self frameRectangle contains: sibling frameRectangle )
                            ifTrue: [ ^sibling partControlInGroupBoxWindows: aPoint ] ]
                    ifFalse: [ ^sibling ] ] ]! 
partIsSelected
        " Answer whether the receiver is currently selected
        in a PARTS Workbench. "
    ^window partEditor selectedComponents includes: self connection!
partCopyAttributes: aBitmap
        "Recreate the receiver with attributes copied from aBitmap."
    self release.
    bitmapInfo :=  aBitmap bitmapInfo.
    archive := aBitmap getDIBits.
    self validate !  
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent.
        Insert the receiver as a child of the parentWindow."

    super partAddUnder: parentWindow wrapper: myWrapper.
   " self framingRatio: aWrapper rectangle."
    parentWindow addSubpane: self.! 
isPARTSTransientPart
        "Answer whether the receiver is a part which exists
        only while its containing application is being edited
        in a PARTS Workbench. "

    ^false!  
lafEditor
        " Obsolete - Answer the PARTS Workbench in which the receiver is being edited. "

    PARTSSessionManager obsoleteMessage.
    ^self partEditor!
partNamed: aString
        " Answer the part whose name is aString. "

    ^self application componentNamed: aString!  
displayLabel: aString
    "Do nothing. Compatibility with PARTSIcon"!
connection
    "Answer the part associated with the receiver"

    ^connection!
partName
        " Answer the receiver's part name. "
    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^self propertyAt: #myOwnName ].
    ^myWrapper name!   
partIsDesktopChild
    "Private - Answer whether the receiver is always a child of the
    workbench desktop.  Non-visual parts are always placed on the
    workbench desktop."

    ^true! 
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."

   ^anObject partIsWindow and: [anObject isPARTSWindow not ]!  
updateFromExternalAddress32: anExternalAddress
        "Private -The call is finished, and it may have changed the
        contents of the struct, so copy it back to the buffer and update
        the UI parts."
    self setFromReference32: anExternalAddress.!   
isPARTSNotebook
        "Answer whether the receiver is a notebook."
    ^false!
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver, adding it
        to <aMirrorCopyDictionary> if not already registered. "

    ^self!   
initializeBaseSystemClasses
        "Private - add new pools in base classes
        needed by methods installed in the runtime component"

    "Needed for handling dynamic messages"
    MessageNotUnderstood defaultClass: PARTSMessageNotUnderstood.

    "Base VW image upgraded July 1993:
    (Window sharedPools includes: #GraphicsConstants)
        ifFalse: [
            Window addSharedPool: #GraphicsConstants.
            ].
    "! 
connection: anObject
    "Set the part associated with the receiver"

    connection := anObject!  
partOverlappedWindow: aPoint
        "Private - Answer the receiver's sibling window that
          contains aPoint. We need to test for siblings that contains
          aPoint because the Windows Z order for child windows is
          opposite the display order, ie. if there are two overlapping
          buttons, the button underneath has higher Z order than the
          one above. When the api WindowFromPoint is called and more
          than one window contains the given point, it returns the first
          window on the list. Thus, inorder to detect the window that is
          on top, we need to start looking at the bottom of the Z order
          and traverse up the  list until a sibling is found that contains
          aPoint, where aPoint is relative to the screen."
    ^self
        partsIfOS2Do: [self partOverlappedWindowOS2: aPoint]
        partsIfWindowsDo: [self partOverlappedWindowWindows: aPoint]! 
keysSorted
        "Answer a SortedCollection containing all the keys
         in the receiver."
   ^self keysAsArray asSortedCollection!  
initializeParts
        " Private - initialize the parts in an application
        which has just been loaded (e.g., register event handlers,
        initialize the state of parts in the application).
        Default is to do nothing. "! 
partName: aName
        " Set the part name to the requested name or the closest
        legal approximation that is acceptable to the user.
        Answer whether the name was successfully changed. "
    | newName icon |
    newName := super partName: aName.
    (newName notNil and: [self partIsShrunk])
        ifTrue: [  " update the shrunken icon label "
            icon := self partShrunkenIcon.
            icon parent
                changeIconLabel: icon
                to: newName
            ].
    ^newName!
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

    ^true! 
isPARTSPartAccessorPart
    "Answer whether the receiver is an instance
    of PARTSPartAccessorPart"

    ^false!
changeContainingRect: srcRect to: destRect
        "Change receiver's containing rect from
          srcRect to destRect."
    ^self moveBy: (srcRect origin - destRect origin).!  
partBringSubPaneToBottom
    "Send the receiver to the bottom."

    self
        partsIfOS2Do:
            [self frameWindow handle
            setWindowPos: ( PARTSConstants at: 'SwpHwndBottom' )
            rectangle: (0 @ 0 corner: 0 @ 0)
            fs: (PARTSConstants at: 'WindowBringToTopFlags') ]!
partDeselect
        " Deselect the receiver in the containing PARTS Workbench. "
    self partEditorPane notNil ifTrue: [
            self partEditorPane selectOff: self ]!  
partSetValueMessage
        "Answer the selector of the one-argument message
        which can be sent to the receiver to set its value. "
    ^#setValue:!
recyclingThreshold
        " Private - answer the maximum number of used
        instances of the receiver to keep in the recycling bin. "

    ^1!   
childWindowFromPoint: hwnd point: aByteArray
    | aWinPoint |
    aWinPoint := WinPoint usingBytes: aByteArray.
    ^self childWindowFromPoint: hwnd
        pointX: aWinPoint x
        pointY: aWinPoint y!   
deferredNotify: titleString withText: messageString
        " Post a deferred notifier. "
    (Message new
        receiver: self
        selector: #notify:withText:
        arguments: (Array with: titleString with: messageString))
            performDeferred!
open
        " Launch the PARTS application by triggering
        the open event. "

    self openApplication.!   
getValue
    ^self contents! 
is: object1 lessEqual: object2
        "Obsolete - retained for compatibility with PW 2.0."

    ^self is: object1 lessThanOrEqualTo: object2! 
recycle
        " Private - recycle the receiver after use. "

    self prepareToBeRecycled.
    self class recycle: self.!   
partOpen
    " Display the receiver when it is being edited
    in a PARTS Workbench, or being built by a nested
    part for run time."

    self partOpen: true.!  
partEvents
        " Answer the PARTS event interface of the receiver. "

    | changedEvent eventList |
    changedEvent := self class changedEventName.
    eventList := self class eventsTriggered asSortedCollection asArray
        reject: [ :anEvent | anEvent = changedEvent ].
    ^PARTSInterfaceList new items: eventList!  
isPARTSWrapper
        "Answer whether the receiver is a PARTS wrapper."
    ^false!
partCanBeNestedChild: aNestedPart
    "Private -  Answer whether the receiver could be a child
    of the nested part <aNestedPart>."

    ^true! 
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."
    | y aFont |
    aFont := self font.
    y := self extent y - aFont height - 2 // 2.
    ^(( aFont width * 3 @ y) extent:
        (self extent x - (aFont width * 3)) @ aFont height )
        mapFromWindow: self
        to: self partEditor workbenchPane.!
partSelectIn: anEditor
        " The receiver has been selected in a PARTS workbench.
    Expand the containing window if it is shrunk."
    | ancestor |

    (( ancestor := self partShrinkableAncestor ) notNil
        and: [ ancestor ~~ self
        and: [ ancestor partIsShrunk ]])
            ifTrue: [ ancestor partExpand ].
    ^super partSelectIn: anEditor!  
boundingBox
        "Answer the bounding box of the receiver."
    ^self partFrame! 
parent: aWindow
    window := aWindow!   
updateText: aString
    "Set the text of the receiver"
    self text: aString!  
changeConnectionValue: anObject
    "Private - Set the value of the part associated with the receiver"

    connection setValue: anObject.
    self connectionValueChanged!   
partIsEditing
        "Answer whether the receiver is being
        edited in a PARTS Workbench. "
    | myWrapper |
    (myWrapper := self partWrapper) isNil
        ifTrue: [^false].
    ^myWrapper partIsEditing!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: (
            #(#< #<= #> #>= ),  " same as Magnitude "
            #(#asArrayOfSubstrings
                #asAsciiZ #asDate #asFloat #asInteger
                #asLowerCase #asParameter #asString
                #asSymbol #asUpperCase "concatenate:"
                "exclude script messages which use blocks:
                findFirst: findLast:
                   "
                #replaceControlChars #trimBlanks ) )
                    asSortedCollection)
        defaultItem: standardMessages defaultItem!   
asPARTSDirectory
    "Private -Answer the directory referenced by the receiver.
        Error Conditions:
        -   If the receiver cannot be resolved to a directory, send the message #cannotBeResolved to the receiver. Resolution will fail if the entity referenced by the receiver does not exist, is not accessible, or is not a directory."

    ^self asFileSystemPath asPARTSDirectory!  
reverseWith: aPen
    "Display the receiver reversed"

    self updateRectangle.
    aPen reverse: (
        (rectangle leftTop down: 1)
        rightBottom: (rectangle rightBottom down: 1) )!
partNonNestedPartParent: aParent
    "Private - Answer the closest parent that is
    not a nested part."
    | tempParent |

    tempParent := aParent.
    [ tempParent isPARTSNestedPart ]
        whileTrue: [ tempParent := tempParent superWindow ].
    ^tempParent!   
isPARTSDialogWindow
        " Answer whether the receiver is a PARTS Dialog window. "
    ^false!   
partDefineLinkForEvent: eventName
    to: aPart
    message: messageName
        " Create a link from the receiver, triggered by
        the event named eventName, which sends the
        message named messageName to aPart.
        Answer the new link. "

    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ self error: 'Not a part' ].
    ^myWrapper defineLinkForEvent: eventName to: aPart message: messageName!   
soleObject
        "Answer the sole object connected to the icon."
    ^connection! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #rightClicked #tabbed )
        separators: #()
        defaultItem: #tabbed! 
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
   " ^SysFont width * 12 @ (SysFont height * 5)"
    ^ self partFontOrSysFont charSize * (15 @ 6) + (0 @ 6)!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (
            self partMessagesStandard items,
            #(
                #backColor #backColor: #boundingBox #box: #boxFilled:
                #centerText: #circle: #circleFilled: #copyBitmap:from:to:
                #direction #direction: #displayText:at: #down
                #east #erase #ellipse:minor: #ellipseFilled:minor:
                #fill:color: #font #font: #foreColor #foreColor:
                #go: #goto:
                #height #home
                #lineWidth #location
                #north
                #place: #polygon: #polygon:sides: #polygonFilled:
                #reverse:
                #setClipRect: #setLineType: #setLineWidth: #south
                #turn:
                #up
                #west #width) )
                asSortedCollection asArray
        defaultItem: #pathName!   
initializeRuntimePlatformEvents
        " Private - register host events which are needed
        by the PARTS runtime. "!  
isPARTSApplication
        "Answer whether the receiver is a PARTS application."

    ^false!  
partApplication
        " Answer the PARTS application which contains the receiver. "

    ^self owner!
partDefaultExtent
    " Answer the default extent of the receiver
    in a PARTS application. "

    | aFont |
    aFont := self partFontOrSysFont.
    ^aFont width * 3 @ (aFont height + 4)!  
frameRelativeRectangle
    "Answer the rectangle relative to the parent"

    ^rectangle!  
frameRectangle
    "Private - Answer the rectangle of the receiver
    is screen coordinates"

    ^rectangle mapToScreen: window!
triggerEvent: aSymbol arguments: anArray
        " Obsolete - Trigger the event named <aSymbol> with argument
        values <anArray> "

    PARTSSessionManager obsoleteMessage.
    " Note: can generally be simplified in 3.0 using the standard
        base system #triggerEvent:with: message "
    ^self triggerEvent: aSymbol withArguments: anArray! 
showLabel
        " Answer whether the receiver is displayed with a label. "
    ^false!
partHasVisualParts
        " Answer whether the receiver contains any visible parts. "
    ^true!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := self partMessagesStandard.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #& #|
            #not)
                asSortedCollection)
        defaultItem: standardMessages defaultItem! 
wrapper
        " Obsolete - Answer the PARTS wrapper of the receiver. "

    PARTSSessionManager obsoleteMessage.
    ^self partWrapper! 
scaleFrom: aRectangle
        "Answer a Rectangle whose size is
         proportional to aRectangle with
         ratios specified by the receiver."
    ^aRectangle scaleTo: self!   
asPARTSDirectory
    "Private - Answer the receiver as a PARTS directory object "

    ^PARTSDosDirectory
        fromLocator: self fileSystemLocator!
partMirrorCopy: aMirrorCopyDictionary
        " Answer a mirror copy of the receiver.
        Do not copy or add to aMirrorCopyDictionary because
        execution contexts are special objects. "

    ^self!  
partCanBeNestedChild: aNestedPart
    "Private -  Answer whether the receiver could be a child
    of the nested part <aNestedPart>."

    ^false!
eventTableForEdit
        "Private - Answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."

    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardMessages |
    standardMessages := super partMessages.
    ^standardMessages
        concatenate: (PARTSInterfaceList new items: #(
            #at: #at:put: #concatenate:
            #copyFrom:to: #copyReplaceFrom:to:with:
            #first #last #reversed )
                asSortedCollection)
        defaultItem: standardMessages defaultItem!  
partDefineLink: aLink
        " Register a link to be triggered by the receiver. "

   | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ self error: 'not a part' ].
    aLink source isNil
        ifTrue: [ aLink sourceObject: self ].
    myWrapper addLink: aLink.!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: (
            self partMessagesStandard items,
            #(
            #basePoint #charSize #charWidth: #descender
            #faceName #fixedWidth #height #isImage
            #spaceWidth #stringWidth: #width
            ) )
                asSortedCollection asArray
        defaultItem: #faceName!   
release
        "Do nothing, TextIcons have no system resources."!   
partFrame
        "Private - Answer the Rectangle containing the
         icon."
    ^self rectangle isNil
        ifTrue: [nil]
        ifFalse: [self rectangle expandBy: self class spacing // 2]!
isPARTSIcon
        "Answer whether the receiver is a kind of PARTSIcon."
    ^false!   
origin: aPoint
    rectangle := aPoint extent: self extent.
    self updateRectangle!   
ownerWindow: aWindow
        "Set the owner window of the receiver to aWindow."

    self propertyAt: #ownerWindow put: aWindow!   
partSetContents: aList
        " Set the PARTS contents of the receiver. "
    self setList: aList! 
partRelativeToParent: aParent
    "Private - Answer whether the receiver's rectangle is
    relative to its parent on the workbench.  The receiver
    is always relative to its parent, unless its in a nested
    part and is a desktop child."

    ^aParent isPARTSNestedPart
        ifTrue: [ self partCanBeNestedChild: aParent ]
        ifFalse: [ true ]!   
concatenate: aCollection
        "Answer a new collection containing the elements
         of the receiver followed by the elements of aCollection."
    ^self, aCollection!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
        "This assumes all window subclasses are not variable.
        Note that initialization is performed."
    self ASSERT: copy handle = WindowHandle nullValue.
    copy
        owner: ( owner partMirrorCopy: aMirrorCopyDictionary );
        parent: ( parent partMirrorCopy: aMirrorCopyDictionary );
        style: style copy.
    self
        partMirrorCopyChildren: aMirrorCopyDictionary to: copy;
        partMirrorCopyProperties: aMirrorCopyDictionary to: copy.
    ^copy!  
partDirectEditValue
        "Answer the direct edit value of the receiver.
        For most parts, the direct edit value is simply its contents.
        This method should be reimplemented by subclasses whose
         direct edit are special (eg. Notebook, ValueSet, etc..)."
    ^self contents!  
origin
    ^rectangle isNil
        ifTrue: [ 0@0 ]
        ifFalse: [ rectangle origin ]!