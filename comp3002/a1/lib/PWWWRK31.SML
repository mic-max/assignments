3.1.0.106
   
scrollTopCornerTo: aNewCorner
        "Private - Scroll topCorner to aNewCorner"
    self scrollTopCorner: self topCorner - aNewCorner! 
visibleExtent
        "Private - answer the extent of the receiver's visible region."

    ^self extent
     " | scrollRanges extent |
     scrollRanges := self getScrollRanges.
    extent := self extent.
    scrollRanges x = 0 ifFalse: [ extent y: extent y - 16 ].    scroll bar width
    scrollRanges y = 0 ifFalse: [ extent x: extent x - 16 ].    scroll bar height

     ^extent  - 2 border"
!   
scrollVertical: anInteger
        "Private - Scroll the pane up by anInteger
         number of pixels (if positive) or down by
         the absolute value of anInteger (if negative)."
    self scrollTopCorner: 0 @ anInteger! 
addSubpane: aPane
        "Add aPane as the child of the receiver."
    child := aPane.
    super addSubpane: aPane!   
workbenchSessionStartUp
        " Private - Perform the session startUp processing
        for the PARTS workbench component. "
    | commandLine applicationPathName |

    PARTSSettings startUp.
    PARTSEditor startUp.

    SessionModel current  isRunTime
        ifTrue: [ "Stand alone workbench"
            commandLine := SessionModel current getCommandLine.
            applicationPathName := ( commandLine size >= 2
                ifTrue: [ commandLine at: 2 ]
                ifFalse: [ '' ] ).
             self launchWorkbench: applicationPathName ]!   
removeWorkbenchPlatformEvents
        " Private - register host events which are needed
        by the PARTS workbench component. "

    | hostEventsList |

    hostEventsList := Smalltalk at: #OperatingSystemEvents.

    self
        partsIfOS2Do: [

            "hit test for GroupBox"
            PARTSHostInterface
                removeHostEvent:  WmHitTest
                in: hostEventsList.

            "events for capturing mouse inside workbench"
            PARTSHostInterface
                redefineHostEvent: WmButton1Down
                in: hostEventsList
                selector: #wmButton1down:with: .
            PARTSHostInterface
                redefineHostEvent: WmButton2Down
                in: hostEventsList
                selector: #wmButton2down:with: .
            PARTSHostInterface
                redefineHostEvent: WmMouseMove
                in: hostEventsList
                selector: #wmMouseMove:with: .
            ]

        partsIfWindowsDo: [

            " non-client area hit test "
            PARTSHostInterface
                removeHostEvent:  WmNcHitTest
                in: hostEventsList.
            PARTSHostInterface
                removeHostEvent: WmNcLButtonDown
                in: hostEventsList.

            "Activate workbench from TaskManager"
            PARTSHostInterface
                removeHostEvent:  WmActivateApp 
                in: hostEventsList.

            "events for capturing mouse inside workbench"
            PARTSHostInterface
                redefineHostEvent: WmButton1Down
                in: hostEventsList
                selector: #wmLbuttondown:with: .
           PARTSHostInterface
                redefineHostEvent: WmButton2Down
                in: hostEventsList
                selector: #wmRbuttondown:with: .
            PARTSHostInterface
                redefineHostEvent: WmMouseMove
                in: hostEventsList
                selector: #wmMousemove:with: .

            ].! 
resultLinkCodeGeneratorExpression
    | answer |
    answer := PARTSCodeGeneratorInterface linkExpressionClass for: self.
    answer receiver: ( PARTSCodeGeneratorInterface creationExpressionClass new
        receiver: (  PARTSCodeGeneratorInterface referenceFor: self sourceObject )
        selector: #linkResultTo:message:
        arguments: (Array
            with: (  PARTSCodeGeneratorInterface referenceFor: receiver )
            with: (  PARTSCodeGeneratorInterface referenceFor: selector ))).
    answer
        addSelector: #traceFire:
            arguments: ( Array with: (  PARTSCodeGeneratorInterface referenceFor: traceFire ));
        addSelector: #editState:
            arguments: ( Array with: (  PARTSCodeGeneratorInterface referenceFor: editState )).
    ^answer! 
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        receiverObject: self class;
        addSelector: #for: with: elementName.
    ^answer!   
partCanBeReplacedBy: aPart
    "Answer whether the receiver can be replaced
    by <aPart> on the workbench.  All links will be
    reattached to <aPart>."

    ^aPart isWindow not!
workbenchSessionStartUpMessages
        " Private - Answer the session #startUp handlers
        for the PARTS workbench component. "

    ^OrderedCollection new
        add: ( Message
            receiver: self
            selector: #workbenchSessionStartUp );
        yourself!   
workbenchRuntimeLibrary
		"Private -"
    ^self
        partsIfOS2Do: [ 'PWORUN31' ]
        partsIfWindowsDo: [ 'PWWRUN31' ].!   
gridY
    ^settings gridExtent y!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelector: #seconds: with: seconds!   
anyFile: pathName
        " Private - a file has been selected from the
        Any File subdialog "

    pathName notNil ifTrue: [
        answer := PARTSFileDescriptor pathName: pathName.
        self close ]! 
addInstantiatePartsMethodModelTo: aClassModel
        "Private - code generation - answer a method model to instantiate
        the receiver's components."
    | methodModel expressionModel messageModel |
    methodModel := aClassModel newClassMethodNamed: #instantiatePartsFor:.
    methodModel
        argumentModels: self applicationArgumentModels;
        comment: 'Private - instantiate anApplication''s component parts.'.
    expressionModel := methodModel newMessageExpression.
    expressionModel receiverObject: self.
    self hierarchallySortedComponents do: [ :component |
"self XRef: ' add component to parts application language'."
        messageModel := expressionModel addSelector: #addComponent:named:parent:.
        self
            addComponentInstantiationLanguageFor: component
            to: messageModel newExpressionArgument.
        messageModel
            addArgument: component partName;
            addArgument: component partRealParent ]!  
lastDirectoryUsed: aDirectory
    " Private - Remember the last directory used to
    set the default directory for the dialog."

    LastDirectoryUsed := aDirectory!
partIsDragable
        "Answer true if dragable and resizable."
    ^false! 
findIndex: aPoint in: components
    "Private - Answer the index of the menu label at <aPoint>.
    <aPoint> is relative to the receiver.
        The index is the position where <aPoint> is between the
    midpoints of the two labels beside <loc> in <components>."
    "Copied to menu bar"
    | loc |

    loc := 1.
    ( components size ) > 0
        ifTrue: [
            components do: [:i |
                (( i object frameRelativeRectangle center x ) isRightOf: aPoint x )
                    ifTrue: [ ^loc ]
                    ifFalse: [ loc := loc + 1 ]]].
    ^loc!  
setScrollRanges: redraw
        "Private - set the horizontal and vertical scroll ranges to
          prevent users from scrolling out of bound. Redraw the scroll
          bars to reflect the change if <redraw> is true."

    | oldRanges scrollRanges scrollExtent visibleExtent vScrollBar hScrollBar update newRect thumbSize |
    visibleExtent := self visibleExtent.
    scrollExtent := self childScrollingExtent max: visibleExtent.
    newRect := child frameRelativeRectangle leftTop extentFromLeftTop: ( scrollExtent + topCorner ).
    update := false.
    scrollRanges := ( ( scrollExtent - visibleExtent ) max: 0 @ 0 ) + topCorner.
    self partsIfWindowsDo: [
        oldRanges := self getScrollRanges.
        ( ( oldRanges x > 0 xor: (  scrollRanges x > 0 ) )  or: [
            oldRanges y > 0 xor: ( scrollRanges y > 0) ] ) ifTrue: [ "to prevent flickering when scroll bars are added/removed"
                update := true.
                self mainWindow disableUpdate ] ].
    self resizeChild: newRect.
    self
        partsIfOS2Do: [
        hScrollBar := self horizontalScrollbar.
        scrollRanges x = 0
            ifTrue: [ hScrollBar isHandleOk ifTrue: [ self removeHorzScrollBar ] ]
            ifFalse: [
                hScrollBar isHandleOk ifFalse: [
                    self addHorzScrollBar.
                    hScrollBar := self horizontalScrollbar ]].
        vScrollBar := self verticalScrollbar.
        scrollRanges y = 0
            ifTrue: [ vScrollBar isHandleOk ifTrue: [ self removeVertScrollBar ] ]
            ifFalse: [
                vScrollBar isHandleOk ifFalse: [
                    self addVertScrollBar.
                    vScrollBar := self verticalScrollbar ] ].
            hScrollBar := self horizontalScrollbar.
            scrollRanges x > 0 ifTrue: [
                thumbSize := ( ExternalLong new lowHalf: visibleExtent x; highHalf: ( scrollExtent x + topCorner x ) ).
                self setScrollBar: hScrollBar position: topCorner x range: scrollRanges x thumbSize: thumbSize ].
            scrollRanges y > 0 ifTrue: [
                thumbSize := (ExternalLong new lowHalf: visibleExtent y; highHalf: ( scrollExtent y  + topCorner y )).
                self setScrollBar: vScrollBar position: topCorner y range: scrollRanges y thumbSize: thumbSize ] ]

        partsIfWindowsDo: [
            ( PARTSHostInterface hostWindowLibrary
                setScrollRange: self asParameter
                bar: "SbHorz" 0
                min: 0
                max: scrollRanges x
                redraw: redraw )
                    ifFalse: [ ^self osError ] .
            ( PARTSHostInterface hostWindowLibrary
                setScrollRange: self asParameter
                bar: "SbVert" 1
                min: 0
                max: scrollRanges y
                redraw: redraw )
            ifFalse: [ ^self osError ] ].


    self partsIfWindowsDo: [ update ifTrue: [ self mainWindow enableUpdate ] ]
!  
promptForBitmap
    "Private"

    ^self promptDialog: #open
        initialFile: nil
        fileTypes: self bitmapFileTypes
        defaultPattern: '*.bmp'
        title: 'Select Bitmap File'! 
partHasOtherEvents
        " Answer whether the receiver can be asked
        for events other than what it has already
        provided in its partEvents. "

    ^true!
partDragTargetEraseEmphasis: aDragSession
        "Private - erase drag drop target emphasis."

    ( self propertyAt: #partHasTargetEmphasis ) notNil
        ifTrue: [
            self partDragTargetDrawEmphasis: aDragSession.
            self propertyAt: #partHasTargetEmphasis put: nil ]! 
visibleRectangle
        "Private - answer the receiver's visible region."
    ^0 @ 0 extent: self extent ! 
partStoreResourceOn: aResourceFile
        "Private - output the receiver on aResourceFile."
    | stream |
    self validate.
    stream := aResourceFile stream.
    stream nextPutAll: ' !! Bitmap !! fromFileStream: !! '.
    self outputToFileStream: stream! 
showLinksWithSelection
    ^settings showLinksWithSelection! 
operation
    "Private - Answer the operation of the choose file dialog."

    ^operation! 
partCanBeReplacedBy: aPart
    "Answer whether the receiver can be replaced
    by <aPart> on the workbench.  All links will be
    reattached to <aPart>."

    ^aPart isApplicationWindow
        and: [ super partCanBeReplacedBy: aPart ]!  
partPrintOn: aStream margin: aString
        "Private - Append a description of the receiver
        as a part in a PARTS application to aStream. "

    aStream
        nextPutAll: aString;
        nextPutAll: self partHint;
        cr.
    self isWellDefined
        ifFalse: [ aStream nextPutAll: '        **Missing Argument(s)**'; cr ].
    self dependentLinks do: [ :aDependentLink |
        aDependentLink partPrintOn: aStream margin: aString, '  ' ].!  
childScrollingExtent
        "Private - answer the child's scrolling extent."
    ^child notNil
        ifTrue: [ child scrollExtent - topCorner]  "in case child has been scrolled"
        ifFalse: [ 0 @ 0 ]
!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    self associationsDo: [ :assoc |
        anExpressionModel
            addSelector: #at:put:
            with: assoc key
            with: assoc value ].
    anExpressionModel addSelector: #yourself!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #initClassList #instantiate:className:expression:
            #object #clearObject )
        separators: #(  )
        defaultItem: #object! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^false!  
isRepositoryComponentInstalled
        " Answer whether the Team/V repository component is installed "

    ^( ServiceRegistry globalRegistry
        serviceNamed: #RepositoryServices
        ifNone: [ nil ] )
            notNil!   
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    | application messageModel expressionModel orderedChildren
        orderedChildrenSelector methodModel |
    application := self partApplication.
    self childrenInBuildOrder do: [ :child |
        messageModel := anExpressionModel addSelector: #addSubpane:.
        expressionModel := messageModel newExpressionArgument.
        expressionModel
            setReceiverToSelf;
            addSelector: ( application selectorForComponentBuild: child )
                with: application ].
    orderedChildren := self orderedChildren.
    orderedChildren size > 0
        ifTrue: [
            orderedChildrenSelector := ( 'getOrderedChildrenOf', self partName, 'In:' ) asSymbol.

            messageModel := anExpressionModel addSelector: #orderedChildren:.
            expressionModel := messageModel newExpressionArgument.
            expressionModel
                setReceiverToSelf;
                addSelector: orderedChildrenSelector with: self partApplication.
            methodModel := anExpressionModel classModel newClassMethodNamed: orderedChildrenSelector.
            methodModel
                    argumentModels: self partApplication applicationArgumentModels;
                comment: 'Private - answer the ordered children of ', self partName.
            methodModel newMessageExpression
                receiverObject: orderedChildren ]
!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object.
        Map the part being upgraded into a new class 
        for the current system. "

	| newPart |
	newPart := self createNewPart.
    self transferValuesToNewPart: newPart.
    newPart fileInUpgrade: anObjectFiler.  " run real upgrader on inherited values "
    ^newPart!  
entryBorderLineWidth
        " Private - answer the entry border line width (points). "
    ^1! 
isPARTSMenuPane
        "Answer whether the receiver is a kind of PARTSMenuPane."
    ^true!
getPathName: fileName
    "Private - Answer the full path name of the given file within the
        selected directory."

    ^( selectedDirectory notNil )
        ifTrue: [
                PARTSFileDescriptor
                    stringFrom: fileName
                    in: selectedDirectory ]
            ifFalse: [ '' ]!  
rectangle
        " Answer the size of the receiver.  This is the background
        area in a workbench window. "

    ^self isEditable
        ifTrue: [ wrapper rectangle ]
        ifFalse: [
            self parent notNil
                ifTrue: [ self parent runtimeRectangle ]
                ifFalse: [ nil ]]! 
showLinkLabels
    ^settings showLinkLabels! 
drawInsertion: newLoc erase: oldLoc
    "Private - Draw a mark where the menu label can be
    dropped at <newLoc>.  Erase the old mark at <oldLoc>."
    "Copied to menu bar"
    

    oldLoc = newLoc
        ifTrue: [ ^nil ].

    oldLoc notNil   "Erase"
        ifTrue: [ self basicDrawMark: oldLoc ].

    self basicDrawMark: newLoc!  
isPARTSOrderedGroupPane
    "Answer whether the receiver is an instance of
    PARTSOrderedGroupPane."

    ^true
!  
updateFiles
    "Private - Display the selected directory files in the file list."

    selectedDirectory notNil ifTrue: [
        application setFileList:
            (( self filesInSelectedDir ) collect: [ :each | each "asLowerCase" ])
                asSortedCollection ]! 
getEditor
    "Private - Initialize and answer an editor for the receiver"
    | editor rect |
    rect := self rectangle.
    editor := connection iconEditorClass new.
    window notNil ifTrue: [editor pane: window].
    editor
        contents: self text;
        pen: self pen;
        font: self class font;
        owner: self;
        storeSelector: #updateText:;
        anchorPoint:
            rect center x @
                (rect bottom up: (self class spacing y // 2)); "centerJustified"
        updateRectangle;
        selectAll.
    ^editor! 
addAllSubclasseNamesOf: aClass to: aCollection
        "Private - Add the names of subclasses of aClass to aCollection."
    aCollection add: aClass name.
    aClass subclasses do: [:c |
        self addAllSubclasseNamesOf: c to: aCollection].!  
maxEntries
    "Private - Answer the maximum number of entries
    that can fit on the screen"

    ^15!  
partEditDirect
        "Edit direct by opening a workbench on the part that is being refered."

    self partEditDirect: self fileDescriptor.! 
promptForCatalogSave: aCatalogName

    ^self
        promptForSave: ( self pathName: aCatalogName )
        fileTypes: self catalogFileTypes
        title: 'Save Catalog As'.! 
COMMENT
"
PARTSMenuPaneWindows belongs to the private implementation
of the PARTS Workbench window.  It is used on Windows
in the implementation of the menu bar/client area regions
of a Window part in the workbench.
"!  
userExtendedProperties
        "Private - answer those user properties for which
        there are no specific accessing methods."
    | accessKeys |
    accessKeys := OrderedCollection new.
    accessKeys
        add: self executionStatePropertyName;
        add: self titlePropertyName;
        add: self manufacturerPropertyName;
        add: self versionPropertyName.
    ^userProperties reject: [ :assoc | accessKeys includes: assoc key ]!
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer creation message expression selector bytes |
    creation := aCodeGenerator messageExpressionToReference: self.
    creation receiverObject: self class.
    message := creation addSelector: #fromBytes:.
    expression := message newExpressionArgument.
    bytes := self stringRepresentation.
    selector := aCodeGenerator storeByteArray: bytes.
    expression
        setReceiverToSelf;
        addSelector: selector.

    answer := aCodeGenerator messageExpressionToReference: self.
    answer receiverModel: creation.
    self codeGenerationAddAttributeMessagesTo: answer.
    ^answer!  
partHasOtherMessages
        " Answer whether the receiver can be asked
        for messages other than what it has already
        provided in its partMessages. "
    ^true!
partIsDragable
        "Answer true if the receiver is dragable."
    ^true!
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer message expression selector bytes |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer receiverObject: self class.
    message := answer addSelector: #fromBytes:.
    expression := message newExpressionArgument.
    bytes := self stringRepresentation.
    selector := aCodeGenerator storeByteArray: bytes.
    expression
        setReceiverToSelf;
        addSelector: selector.
    ^answer!  
wmSetfocus: mp1 with: mp2
        "Private - Add a MessageExpression to CurrentEvents
         and return right away."
    | aPane |
    (mp2 lowHalf = 1)
        ifTrue: [  "losing focus"
            aPane := Notifier findWindow: mp1 asWindowHandle.
            ( aPane notNil
                and: [ aPane isPARTSEditorPane ] )
            ifTrue: [ aPane sendInputEvent: #setFocus ]].
    ^super wmSetfocus: mp1 with: mp2!
createMasks: anIcon
        "Private - Create the AND and XOR masks for anIcon."
    | extent |
    extent := ( anIcon bitmap isNil
        ifTrue: [ PARTSIcon iconSize ]
        ifFalse: [ anIcon extent ] ).
    andMask := Bitmap extent: extent.
    icon xorMask isColorBitmap
        ifTrue: [ xorMask := Bitmap width: extent x height: extent y planes: 1 bitCount: 4 ]
        ifFalse: [ xorMask := Bitmap extent: extent ].

    copy := Bitmap screenExtent: extent.
    copy pen fill: Color cyan.
    ( anIcon andMask notNil and: [ anIcon andMask isValid ] )
        ifTrue: [
            andMask pen
                copyBitmap: anIcon andMask
                from: andMask boundingBox
                at: 0 @ 0.
            xorMask pen
                copyBitmap: anIcon xorMask
                from: xorMask boundingBox
                at: 0 @ 0.
            copy pen
                foreColor: Color white;
                backColor: Color black.
            copy pen
                copyBitmap: andMask
                from: andMask boundingBox
                at: 0 @ 0
                rule: CopyRuleSourceAnd.
            copy pen
                copyBitmap: xorMask
                from: xorMask boundingBox
                at: 0 @ 0
                rule: CopyRuleSourceInvert.
            copy pen
                foreColor: PARTSHostInterface colorDefault;
                backColor: PARTSHostInterface colorBackground ]
        ifFalse: [
            xorMask pen fill: xorMask boundingBox rule: CopyRuleBlack.
            andMask pen fill: andMask boundingBox rule: CopyRuleWhite]!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Part Accessor'! 
acceptProperties
        " Validate the proposed changes.  If acceptable,
        update the controlling PARTS editor with its new values
        and trigger the propertiesAccepted event.
        Answer whether the new properties were accepted. "
    | userNameChanged gridChanged
      showHintsChanged showLinkLabelsChanged
      showLinksWithSelectionChanged
      orthogonalLinksChanged
      arbitraryMaxValue somethingChanged  |

    " decide what properties have changed "
    userNameChanged := self
        isNewString: newSettings userName
        differentFrom: settings userName.
    gridChanged :=
        (settings gridExtent ~= newSettings gridExtent).
    showHintsChanged :=
        (settings showHints ~= newSettings showHints).
    showLinkLabelsChanged :=
        (settings showLinkLabels ~= newSettings showLinkLabels).
    showLinksWithSelectionChanged :=
        (settings showLinksWithSelection ~= newSettings showLinksWithSelection).
    orthogonalLinksChanged :=
        ( settings orthogonalLinks ~= newSettings orthogonalLinks ).
    " searchPathChanged is set when edited "

    " determine whether changed properties are valid "
    (searchPathChanged and: [searchPath size = 0])
        ifTrue: [
            MessageBox
                notify: 'Settings Problem'
                withText: 'You cannot empty the PARTS search path completely!!'.
            ^false].

    gridChanged
        ifTrue: [
            arbitraryMaxValue := 100.
            ( newSettings gridExtent x between: 1 and: arbitraryMaxValue )
                ifFalse: [
                    MessageBox
                        notify: 'Settings Problem'
                        withText: 'The grid width is invalid.'.
                    ( self partNamed: 'GridX' ) selectAll; setFocus.
                    ^false ].
            ( newSettings gridExtent y between: 1 and: arbitraryMaxValue )
                ifFalse: [
                    MessageBox
                        notify: 'Settings Problem'
                        withText: 'The grid height is invalid.'.
                    ( self partNamed: 'GridY' ) selectAll; setFocus.
                    ^false ].
            ].

    " accept the validated changes "
    somethingChanged := false.
    userNameChanged
        ifTrue: [
            settings userName: newSettings userName.
            somethingChanged := true].
    searchPathChanged
        ifTrue: [
            PARTSFile setSearchPath: searchPath.
            searchPathChanged := false.
            somethingChanged := true].
    gridChanged
        ifTrue: [
            settings gridExtent: newSettings gridExtent.
            somethingChanged := true].
    showHintsChanged
        ifTrue: [
            settings showHints: newSettings showHints.
            somethingChanged := true].
    showLinkLabelsChanged
        ifTrue: [
            settings showLinkLabels: newSettings showLinkLabels.
            somethingChanged := true].
    showLinksWithSelectionChanged
        ifTrue: [
            settings showLinksWithSelection: newSettings showLinksWithSelection.
            somethingChanged := true].
    orthogonalLinksChanged
        ifTrue: [
            settings orthogonalLinks: newSettings orthogonalLinks.
            somethingChanged := true].
    somethingChanged
        ifTrue: [settings writeSettingsFile].
    self triggerEvent: #propertiesAccepted.
    ^true! 
openDialogWindow
    "Private - Open the dialog window."

    self openModalDialog: 'DialogWindow1'.
    self supportsRecycling
        ifTrue: [ ( Message receiver: self selector: #recycle ) performDeferred ].
    ^answer! 
fileNameField
    "Private"

    ^application fileNameField trimBlanks!
openFile: defaultFileName
    fileTypes: fileTypes
    defaultPattern: aDefaultPattern
        "Private - Open an Open File dialog with the defaultFileName "

    self defFilter: aDefaultPattern.
    self setFiltersFromTypes: fileTypes.

    ^super openFile: defaultFileName!   
partFileInUpgradeLoaded: anObjectFiler
        " Private - finish upgrading a window part from PARTS Workbench 2.0. "

    super partFileInUpgradeLoaded: anObjectFiler.

    children isNil  "ApplicationWindows initialize their children"
        ifTrue: [ self children: self children ].! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."

    anExpressionModel
        addSelectorIfNotNil: #virtualScreenExtent: with: self virtualScreenExtent;
        addSelectorIfNotNil: #settings: with: settings;
        addSelectorIfNotNil: #frameRectangle: with:  frameRectangle;
        addSelectorIfNotNil: #isShrunk: with: isShrunk!  
getButtonPressedUnder: aPoint
        " Private - identify the button being pressed. "
    | aTool |
    aTool := super getButtonPressedUnder: aPoint.
    (aTool notNil and: [aTool isDisabled])
        ifTrue: [   " ignore clicking a disabled tool "
            Terminal bell.  " give audible feedback in absence of visual indicator "
            ^nil ].
    ^aTool!
orthogonalLinks
    ^newSettings orthogonalLinks!
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
displayHelpIndexFromFile: aHelpFile
    "Bring up the Windows Help for the file aHelpFile.
      Answer true, if successful."

    ^self
        winHelp: HelpIdIndex
        helpFile: aHelpFile
        data: nil!   
partDragTargetLeave: dragSession
        "Private - the mouse left the bounds of the
        receiver during a drag drop transfer."

    "Below is from dragTargetLeave:"
    self dragTargetStopScrollTimer.
    dragSession targetEraseEmphasis.
    self dragTargetLeaveDefault: dragSession!   
getScrollRanges
        "Private - answer the current scrolling ranges ( horz & vert )."
    | maxHorz maxVert |
    self
        partsIfOS2Do: [
            maxHorz := ( ExternalLong fromBytes:
            ( PARTSHostInterface hostWindowLibrary
                sendMsg: self horizontalScrollbar handle
                msg: 419 "SbmQueryrange"
                mp1: 0
                mp2: 0  )) highHalf.
            maxVert := (ExternalLong fromBytes:
                ( PARTSHostInterface hostWindowLibrary
                    sendMsg: self verticalScrollbar handle
                    msg: 419"SbmQueryrange"
                    mp1: 0
                    mp2: 0 )) highHalf ]

        partsIfWindowsDo: [
            ( PARTSHostInterface hostWindowLibrary
                getScrollRange: self handle asParameter
                bar: "SbHorz" 0
                lpMinPos: ExternalLong new asParameter
                lpMaxPos: ( maxHorz := ExternalLong new ) asParameter ).
            ( PARTSHostInterface hostWindowLibrary
                getScrollRange: self handle asParameter
                bar: "SbVert" 1
                lpMinPos: ExternalLong new asParameter
                lpMaxPos: ( maxVert := ExternalLong new ) asParameter ).
             maxHorz := maxHorz asInteger = 100 ifTrue: [ 0 ] ifFalse: [ maxHorz asInteger ].
             maxVert := maxVert asInteger = 100 ifTrue: [ 0 ] ifFalse: [ maxVert asInteger ] ].

    ^maxHorz @ maxVert
! 
isPARTSEditorMoveSession
    "Answer whether the receiver is an instance
    of PARTSEditorMoveSession"

    ^false!  
shrinkTo32
    | answer |
    self partsVwOnly.  " Only used on VW"

    answer := self clone.
    answer andMask: (answer andMask changeSize: 32 @ 64).
    answer xorMask: (answer xorMask changeSize: 32 @ 32).
    ^answer!
totalHeight
        "Private - answer total height for the reciever."
   child notNil
        ifTrue: [ ^child totalHeight ]
         ifFalse: [  ^0 ]!   
initialize
        "Private - Initialize the receiver's framing block."

    super initialize.
    self framingBlock:
        (self class partsFramingBlock: "(SysFont height + 4)" self class menuBarHeight)  "[11/3/94 MT]"!   
partDefineScript: scriptSourceString
        " Compile the text in <scriptSourceString> as a
        PARTS script and attach it to the receiver.
        Answer the message selector of the script
        (nil if it did not compile). "

    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^self error: 'not a part' ].
    PARTSScript compilerInterfaceClass isNil
        ifTrue: [ ^nil ].  " posts warning message if not installed correctly "
    ^myWrapper defineScript: scriptSourceString!  
computeIconOffsetFor: aWrapper
        "Private - answer the icon offset (from the left top of the editor
        rectangle) for aWrapper."
    | leftTop editorVirtualScreenExtent wrapperRect |

    wrapperRect := aWrapper rectangle.
    wrapperRect isNil
        ifTrue: [ ^20 @ 20 ].
    editorVirtualScreenExtent := self editorVirtualScreenExtent.
    editorVirtualScreenExtent isNil ifTrue: [
        editorVirtualScreenExtent := Display extent * 2 // 3 ].
    wrapperRect isPARTSRectangle
        ifTrue: [
            wrapperRect := wrapperRect value: ( 0@0 extent: editorVirtualScreenExtent ) ].
    PARTSHostInterface hostCoordinateSystemOrigin = #leftTop
        ifTrue: [ ^wrapperRect leftTop ].
            "For any system with window coords origin left bottom:"
    leftTop := wrapperRect leftTop.
    ^leftTop x @ ( editorVirtualScreenExtent y - leftTop y )
!   
clearObject
        "Set object to nil."
        self triggerEvent: #classNames: with: classNames.
    ^object := nil! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    self partProperties partPrintPropertiesOn: aStream margin: aString!  
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
    PARTSVisualPartPropertyDialog new openOn: self.! 
createNewPart
        " Private - answer a new instance of the part class 
        which will represent the receiver in the current system. "

    self implementedBySubclass!
draggingOver: aDragSession
    "Private - The menu label is passing over the receiver.
      Draw the menu drop mark."
    "Copied to menu bar"
    | oldDropMark |

    oldDropMark := IconDropMark.
    IconDropMark :=
        self findIndex: ( aDragSession screenLocation mapToWindow: self ).
    self drawInsertion: IconDropMark erase: oldDropMark!
updatePositions
    "Private - Update the positions of each item in the receiver."
    "Copied to menu bar"

    self moveFrom: 1 to: self partWrapper components size after: nil.!   
fileName
        " Private - answer the file containing the PARTS
        window definition. "
    ^'LAFLnClr.par'!
initializePartValues
    " Private - the dialog window application is about to be
    opened.  Initialize the items in the dialog based on the
    current values of the part. "

    self reinitializeEventHandlers.
    super initializePartValues!   
wmActivateapp: wordInteger with: longInteger
        "Private - Process the activate message synchronously."
    self partsVwOnly.  " Only used on VW"
    ^nil!   
topLevelVisualParts
        "Private - answer the the receiver's top level visual component parts."
    ^self topLevelParts select: [ :part | part partIsWindow ]!  
defaultFileName
    "Private - Answer the filename that first appears
    when the dialog opens."

    ^startFile isNil
        ifTrue: [ pattern ]
        ifFalse: [ startFile fileName ]!
createBuilderClass
        "Create and answer a class (subclass of PARTSApplicationCoordinator) that can
        build an exact clone of the receiver."
    | cg output class |
    cg := CodeGenerationPrivateServices codeGenerator new.
    output := CodeGenerationPrivateServices outputToImage new.
    output outputIsTransient: false.
    cg write: self output: output.
    class := output classesOutputted first.
    ^class
!  
initializeEventHandlers
    " Private - the application has just been loaded.
        Register event handlers for parts in the application.
        Do nothing.  This method only executes the first time
        the application is opened.  Events need to be reinitialized
        every time the application is opened since this application
        is used for different operations.  Refer to
        reinitializeEventHandlers."! 
searchPath
    ^searchPath!  
partsInvalidateRegion: hrgn
        "Invalidate the region identified by <hrgn>."
    self
        partsIfOS2Do: [
            ( PARTSHostInterface hostWindowLibrary
                invalidateRegion: self asParameter
                hrgn: hrgn asParameter
                includeChildren: true )
                ifFalse: [ ^self osError ] ]
        partsIfWindowsDo: [
            ( PARTSHostInterface hostWindowLibrary
                redrawWindow: self asParameter
                rectangle: nil asParameter
                region: hrgn
                redraw: 385 "RdwInvalidate | RdwAllchildren | RdwUpdatenow")
              ifFalse: [ ^self osError ] ]

!
move: menuLabel to: aPoint
    "Private - Move <menuLabel> from its
    current position to <aPoint>."
    "Copied to menu bar"
    | oldRect editorPane |

    ( editorPane := self partEditor workbenchPane ) notNil
        ifTrue: [ oldRect := editorPane selectionRect: self ].
    self move: menuLabel toIndex: (self findIndex: aPoint).
    oldRect notNil
        ifTrue: [ editorPane realInvalidateRect: oldRect ].
    self partEditor redisplaySelection.
!
affectsFreeClientArea
    "Answer whether the receiver reduces the amount of
    free client area in its parent for its siblings."

    ^true!
saveFile: defaultFileName
    fileTypes: fileTypes
    defaultPattern: aDefaultPattern
        "Private - Open a Save File dialog with the defaultFileName "

    self defFilter: aDefaultPattern.
    self setFiltersFromTypes: fileTypes.

    ^super saveFile: defaultFileName!
promptForOpen: aTitle
    "Private - Prompt for file to open"
    | fileTypes partType index |

    fileTypes := self fileTypesForEditing.
    fileTypes add: self fileTypeForAll.

    partType := PARTSFileDescriptor fileTypeForPart type.
    ( index := (( fileTypes collect: [ :each | each type ]) indexOf: partType )) > 1
        ifTrue: [ "Put part type as first type."
            fileTypes removeIndex: index.
            fileTypes addFirst: PARTSFileDescriptor fileTypeForPart ].

    ^self promptDialog: #open
        initialFile: nil
        fileTypes: fileTypes
        defaultPattern: fileTypes first pattern
        title: aTitle! 
COMMENT
"
A PARTSToolPane is used for the workbench tool bar.
This is a private class of the workbench subsystem.
"!  
computeListExtent
        " Private - answer the list pane extent
        (dialog box units). "
    | width height charWidthDlg |
    self entryHeight.  " ensure inst var is set "
    charWidthDlg := WindowDialog charWidth.
    width := height := 0.
    list do: [ :anEntry |
        width := width max: anEntry size].  " chars "
    width :=
        (width * charWidthDlg)  " chars -> dlg units "
        + (2 * (self class widthInDialogUnits: self entryInteriorBorder))
        + (4 * charWidthDlg).   " side margins "
    height :=
        (self class heightInDialogUnits:
                (( list size min: self maxEntries )* entryHeight))
        + (2 * charWidthDlg).  " top and bottom margins "
    ^width @ height!
transferCellDimensions
        "Private - transfer the row heights and column widths."
    |  columnRights rowBottoms oldColumnRights oldRowBottoms newColumnRights
        newRowBottoms lastOld lastNew delta |
    oldColumnRights := newTablePanePart columnRights.
    oldRowBottoms := newTablePanePart rowBottoms.
    columnRights := columnLefts copyFrom: 2 to: columnLefts size.
    rowBottoms := rowTops copyFrom: 2 to: rowTops size.
    columnRights size > 0 ifTrue: [
        oldColumnRights size > columnRights size
            ifTrue: [
                lastOld := oldColumnRights at: columnRights size.
                lastNew := columnRights last.
                delta := lastOld - lastNew.
                oldColumnRights := oldColumnRights collect: [ :i | i - delta ].
                newColumnRights := columnRights,
                    ( oldColumnRights copyFrom: columnRights size + 1 to: oldColumnRights size ) ]
            ifFalse: [
                newColumnRights := columnRights copyFrom: 1 to: oldColumnRights size ].
        newTablePanePart columnRights: newColumnRights ].

    rowBottoms size > 0 ifTrue: [
        oldRowBottoms size > rowBottoms size
            ifTrue: [
                lastOld := oldRowBottoms at: rowBottoms size.
                lastNew := rowBottoms last.
                delta := lastOld - lastNew.
                oldRowBottoms := oldRowBottoms collect: [ :i | i - delta ].
                newRowBottoms := rowBottoms,
                    ( oldRowBottoms copyFrom: rowBottoms size + 1 to: oldRowBottoms size ) ]
            ifFalse: [
                newRowBottoms := rowBottoms copyFrom: 1 to: oldRowBottoms size ].
        newTablePanePart rowBottoms: newRowBottoms ]!  
initializeEventHandlers
    " Private - the application has just been loaded.
    Register event handlers for parts in the application."

    application
        when: #opened
            send: #opened to: self;
        when: #patternChanged:
            send: #patternChanged: to: self;
        when: #fileNameChanged:
            send: #fileNameChanged: to: self;
        when: #fileNameEntered:
            send: #fileNameEntered: to: self;
        when: #directorySelected:
            send: #directorySelected: to: self;
        when: #updateFiles
            send: #updateFiles to: self;
        when: #anyFile:
            send: #anyFile: to: self;
        when: #anyFileRequested:
            send: #anyFileRequested: to: self

    "  ;

        when: #openAClass send: #openAClass to: self  "!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure partContext
        at: #fileNameChanged put: false.
    aPropertyStructure
        when: #editDone
        send: #partPropertyEditDone: to: self with: aPropertyStructure.
    aPropertyStructure
        at: #fileNameItem putProperty: ( PARTSPropertyStaticText new
            label: self partPropertyFileNamePrefix, self fileName;
            yourself );
        at: #changeFile putProperty: ( PARTSPropertyEditButton new
            label: 'Change file...';
            value: self fileDescriptor;
            clickedSelector: #partPropertyChangeFile: ;
            changeSelector: #changeFile: );
        putProperty: ( PARTSPropertyButtonGroup new
            label: 'Load Option';
            changeSelector: #demandLoad:;
            labelsMap: #(
                 #('Demand ' #true)
                 #('Explicit ' #false));
            initialSelection: ((Array with: true with: false) indexOf: demandLoad));
        putProperty: #( #editContents );
        putProperty: #( #interface ).
    ^aPropertyStructure!  
itemPositionToPoint: position
    "Private - Convert <position> to a Point in the receiver."
    "Copied to menu bar"
    | origin components midPoint |

    midPoint := self spacing / 2.
    components := self partWrapper components.
    (components size = 0 or: [position = 1])
        ifTrue: [ "First position"
            origin := midPoint @ 0 ]
        ifFalse: [
            position > components size
                ifTrue: [ "Draw after last menu label"
                    origin := ((components at: components size)
                        object frameRelativeRectangle right right: midPoint ) @ 0]
                ifFalse: [ "Draw the mark before the menu label at <position>"
                    origin := ((components at: position)
                        object frameRelativeRectangle left left: midPoint) @ 0]].
    ^origin rounded!  
partPrintOn: aStream margin: aString
        "Private - Append a description of the receiver
        and its part properties to aStream.
        Append aString after every new line.
        Should not be reimplemented by part classes - each
        part should ensure that it properly supports the
        method #partPrintPropertiesOn:margin: "

    | firstMargin |
    firstMargin := aString copy.
    firstMargin at: ( ( aString size - 1 ) max: 1 ) put: $-.
    aStream
        cr;
        nextPutAll: firstMargin;
        nextPutAll: 'Part name: ';
        nextPutAll: self partWrapper name printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Manufacturer: ';
        nextPutAll: self partManufacturer printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Part type: ';
        nextPutAll: self partTypeSimpleName printString;
        cr.
    self partPrintPropertiesOn: aStream margin: aString.! 
displayHelp: panelName fromFileOS2: libraryName
        "Private - Show the help panel with id aString.
        Answers true, if successful."

    | libraryFound |
    self partsVosOnly.
    libraryFound := true.
    "Concat libraryName if not already in the list."
    self helpFileName isNil
        ifTrue: [ self helpFileName: String new ].
    ( self helpFileName indexOfString: libraryName ) = 0
        ifTrue: [
            self helpFileName: self helpFileName, ' ', libraryName.
            libraryFound := (PARTSHostInterface hostWindowLibrary
                sendMsg: self helpInstance
                msg: 557 "HmSetHelpLibraryName"
                mp1Struct: self helpFileName asParameter
            mp2: 1 "HmPanelname" )
                asExternalLong asBoolean not ].
    ^libraryFound and: [ self displayHelp: panelName ]!   
setFiltersFromTypes: partFileTypes
        "Private - answers  a string containing all filters and sets up
        the defFilterIndex property"

    ( partFileTypes reject: [ :aPartFileType |
        aPartFileType pattern = '*.*' ])
            do: [ :aPartFileType |
                self
                    addFilter: aPartFileType pattern
                    description: aPartFileType description ].! 
object
        "Answer the object which is created."
    ^object!   
removeHorzScrollBar
        "Private - remove the horizontal scroll bar when the scroll range is zero."
    | frameStyle |
    self partsVosOnly.
    frameStyle := self removeHorizontalScrollbarStyle.
    self partPropertySetStyle: frameStyle
!
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    resultAction isNil
        ifTrue: [ ^super codeGenerationMessageExpressionIn: aCodeGenerator ].
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        addSelector: #receiver: with: receiver;
        addSelector: #selector: with: selector.
    arguments size = 0
        ifFalse: [
            answer addSelector: #arguments: with: arguments ].
    answer addSelector: #forwardResultUsing: with: resultAction.
    ^answer!
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private "
    self
        partPrintForecolorOn: aStream margin: aString;
        partPrintBackcolorOn: aStream margin: aString;
        partPrintFontOn: aStream margin: aString.! 
promptDialog: anOperation initialFile: aFileDescriptor fileTypes: listOfFileTypes defaultPattern: defaultPattern title: aTitle
    "Private - Initialize the instance variables and open the window."

    title := aTitle.
    fileTypes := listOfFileTypes.
    defaultType := fileTypes
        detect: [ : aType | aType pattern equalsIgnoreCase: defaultPattern ]
        ifNone: [ fileTypes first ].
    startFile := aFileDescriptor.
    operation := anOperation.

    ^ self openDialogWindow! 
setColorBoxes
        "Private - Set the Pen/Fill color boxes with new colors."
    | penColor floodFillColor |
    ( self paneAt: 'colorButton') selection ifTrue: [
        penColor := bitColor.
        floodFillColor := fillColor ].
    ( self paneAt: 'screenButton' ) selection ifTrue: [
        penColor := Color cyan.
        floodFillColor := Color cyan].
    ( self paneAt: 'inverseButton' ) selection ifTrue: [
        penColor := Color darkRed.
        floodFillColor := Color darkRed ].

    ( self paneAt: 'penColor' )
        backColor: penColor;
        invalidateRect: nil.
    ( self paneAt: 'fillColor' )
        backColor: floodFillColor;
        invalidateRect: nil!
gridY: anInteger
    newSettings gridExtent:
        ( newSettings gridExtent x
        @ ( anInteger isNil ifTrue: [ 0 ] ifFalse: [ anInteger ] ) ).! 
editLinkColors
        " Edit the link colors. "
    PARTSLinkColorSettingsEditor findOrOpenOn: settings.!  
registerWorkbenchService
        " Register the #PARTSWorbench service "

     ServiceRegistry globalRegistry
        register: PARTSEditor
        withName: #PARTSWorkbench
        version: self releaseNumberString!
partDroppedPart: aPart hotSpot: hotSpot origin: origin
    "Private - <anApplication> has been dragged into the
    receiver.  <aPart> is either an application or a part.
    Add the menu label at the correct position in the
    menu bar. <aPoint> is in editor pane coordinates."
    "Copied to menu bar"
    | components originalComponents currentLocation
        insertionPoint menuLabelWrapper |

    hotSpot isNil ifTrue: [ ^self refreshItems ]. "Duplicated <aPart>"

    menuLabelWrapper :=
        aPart isPARTSApplication
            ifTrue: [ aPart mainObjectPrivate partWrapper ]
            ifFalse: [ aPart partWrapper ].
    components := self partWrapper components asOrderedCollection.
    originalComponents :=
        components select: [ :each | each ~= menuLabelWrapper ].
    insertionPoint :=
        self findIndex:
            ( hotSpot mapFromWindow: self partEditor workbenchPane to: self )
            in: originalComponents.
    ( currentLocation := components indexOf: menuLabelWrapper ) > 0
        ifTrue: [ components removeIndex: currentLocation ].
    components add: menuLabelWrapper beforeIndex: insertionPoint.
    self partWrapper components: components.

    self partEditor selectOff: menuLabelWrapper object.
    self updatePositions.
    self partEditor select: menuLabelWrapper object.
!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#classNames: #newObject: #compilerError:at:in:for: #closeWindow )
        separators: #(  )
        defaultItem: #newObject:!  
filesInSelectedDir
    "Private - Answer the files to display in the selected directory."

    ^selectedDirectory filesNamed: pattern.!
winHelp: anInteger helpFile: aHelpFile data: param
        "Private - call WinHelp with the appropriate parameters."
    self partsVwOnly.  " Only used on VW"
    ^PARTSHostInterface hostWindowLibrary
        winHelp: applicationWindow asParameter
        helpFile: aHelpFile asParameter
        command: anInteger
        dwData: param asParameter!  
COMMENT
"
PARTSUpgradeObject is an abstract class under which
PW upgrade objects are defined whose only purpose in
life is to exist long enough to handle drastic shape
shape changes across version upgrades.
"!   
addComponentInstantiationLanguageFor: anObject to: aMessageExpression

"self XRef: 'CG - component creation code'."

" simple version  <some class> new  : "

     aMessageExpression
        receiverObject: anObject class;
        addSelector: #new

    "via creator (create by name):"

"    aMessageExpression
        receiverObject: PARTSCreator;
        addSelector: #create:
            with: anObject class name   "!   
partPropertyEditDone: aPropertyStructure
        " Private - property changes applied "

    ( aPropertyStructure partContext at: #fileNameChanged )
        ifTrue: [
            (Message new
                receiver: self partEditor
                selector: #validateLinksAttachedTo:
                arguments: (Array with: self))
                    performDeferred ].
    "self partShrunkenIcon: nil."  " clear any cached icon "!   
addSmalltalkFileFilters
        "Private - Add Smalltalk filter and descriptions"!   
partDragTargetPaste: aPasteSession
    "Private"
    | workbenchPane wrappers dragObject |

    aPasteSession objects do: [ :aDragDropObject |
        ( self
            partCanWindow: self
            haveChild: aDragDropObject mainObject )
            ifFalse: [
                ^MessageBox warning: 'Illegal target for the drag object(s)']].

    wrappers :=
        aPasteSession objects collect: [ :aDragObject |
                dragObject := aDragObject.
                dragObject wrapper ].

    self partEditor
        addMergedWrappers: wrappers
        in: self
        box:
            (( aPasteSession objects first targetLocation
                mapFromWindow: self to: self partEditor workbenchPane ) extent:
                    aPasteSession objects first wrapper icon extent )
        minBox: aPasteSession minBox.

    self isPARTSOrderedGroupPane
        ifTrue: [
            workbenchPane := self partEditor workbenchPane.
            wrappers do: [ :aWrapper |
                self
                    partDroppedPart: aWrapper object
                    hotSpot:  ( aPasteSession targetLocation mapFromWindow: self to: workbenchPane )
                    origin:  ( dragObject targetLocation mapFromWindow: self to: workbenchPane )]].

    ^wrappers!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelectorIfNotNil: #drive: with: self drive;
        addSelectorIfNotNil: #pathName: with: self pathName!
resizeWindow
        "Private - Change the frame of the receiver pane
         to aRectangle."
    super resizeWindow
!   
display
        "Private - Display the contents of the receiver."

    super display.
    tools do: [ :aTool |
        aTool isDisabled
            ifTrue: [aTool displayWith: graphicsTool] ].!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self)
        putProperty: ( PARTSPropertyString new
            value: self title;
            label: 'Title:';
            changeSelector: #title: );
        putProperty: ( PARTSPropertyString new
            value: self manufacturer;
            label: 'Manufacturer:';
            changeSelector: #manufacturer: );
        putProperty: ( PARTSPropertyString new
            value: self version;
            label: 'Version:';
            changeSelector: #version: );
        putProperty: ( PARTSPropertyString new
            value: self partHint;
            label: 'Hint:';
            changeSelector: #partHint: );
        putProperty: ( PARTSPropertyString new
            value: self helpFile;
            label: 'Development help file:';
            changeSelector: #helpFile: );
        putProperty: ( PARTSPropertyString new
            value: self helpTopic;
            label: 'Development help topic:';
            changeSelector: #helpTopic: );
        putProperty: ( PARTSPropertyButtonGroup new
                label: 'Part file reuse option' ;
                changeSelector: #reuseMode:;
            labelsMap: #(
                #('Packaged part (linked)' #reference )
                #('Packaged part (embedded)' #embed)
                #('Ensemble of parts' #merge) );
            initialSelection: ( #( #reference #embed #merge) indexOf: self reuseMode) );
        putProperty: ( PARTSPropertyIcon new
            value: self icon );
        putProperty: ( PARTSPropertySequenceChildren new
            makeSameLine );
        putProperty: #( #interface #editDescription )!  
sequenceDirectories
        " Private "
    | newSearchPath selectedDirectory |
    newSearchPath :=
        PARTSPathSequenceEditor new openOn:
            ( searchPath collect: [ :each | each relativeDisplayName ]).
    newSearchPath isNil ifTrue: [^self].
    searchPath :=
        newSearchPath collect: [ :aDisplayName |
            PARTSDosDirectory fromDisplayName: aDisplayName ].
    searchPath := searchPath reject: [ :aDir | aDir isNil ].
    searchPathChanged := true.
    selectedDirectory :=
        (self paneAt: 'SearchPath') selectedItem.
    self triggerEvent: #searchPathChanged: with: searchPath.
    selectedDirectory notNil
        ifTrue: [ self triggerEvent: #selectDirectory: with: selectedDirectory ].!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyString new
            value: self contents;
            label: 'Label:';
            changeSelector: #contents: );
        putProperty: #( #interface #sizeWindow )!   
title
    "Private - Answer the dialog title. "

    ^title!   
displayHelp: anId fromFileWindows: aHelpFile
    "Bring up the Windows Help for the topic
      defined by anId from the help file aHelpFile.
      Answer true, if successful."

   | contextId | 
    self partsVwOnly.  " Only used on VW"
    contextId := anId.
    self helpMode ifTrue:[ self turnOffHelpMode ].
    contextId isString ifTrue: [
        contextId := contextId asString.
        1 to: contextId size do: [:i |
            ( contextId at: i ) = $: ifTrue: [ contextId at: i put: $_ ] ].
        contextId :=  self mapDictionary at: contextId ifAbsent: [
            self displayHelpContext: contextId fromFile: aHelpFile.
            ^true ] ].
    ^self
        winHelp: HelpIdContext
        helpFile: aHelpFile
        data: contextId!   
promptForSave: aFileDescriptor
    "Private"
    | fileTypes |

    fileTypes := self saveableFileTypes.
    fileTypes addLast: self fileTypeForAll.

    ^self
        promptDialog: #save
        initialFile: aFileDescriptor
        fileTypes: fileTypes
        defaultPattern: '*.', aFileDescriptor fileType asString
        title: 'Save Part As'.! 
partPropertyHasFrameCreationFlags
    "Answer whether the property set style should modify
        the frame creation flags instead of the style."

    self partsVosOnly.
    ^true!
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^true!   
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."
    "Copied to menu bar"

    ^false!  
partsFramingBlock: menuHeight
        "Private - Answer the receiver's framing block. This method
         is here because the ObjectFiler is dumping some funny stuff
         for blocks."
    ^[: box |  Rectangle
        leftTop: (box leftTop leftAndUp: 1 @ 1)
        rightBottom: (box right + 1@ (menuHeight + 1))]  "[11/3/94 MT]"!  
fromStringRepresentation: aString
        "Private - Answer an instance of the receiver represented in aString."
    ^self fromFileStream: ( ReadWriteStream on: aString )! 
initializeWorkbenchSessionEventHandlers
        " Private - register the session event handlers for the
        PARTS workbench component
            PARTSSessionManager initializeWorkbenchSessionEventHandlers
        "

    self workbenchSessionStartUpMessages do: [ :msg |
        SessionModel current isRunTime
            ifFalse: [ SessionModel current when: #startup evaluate: msg ].
        msg perform ].
    self workbenchSessionStartedMessages do: [ :msg |
        SessionModel current isRunTime
            ifFalse: [ SessionModel current when: #started evaluate: msg ].
        msg perform ].
    self workbenchSessionShutdownMessages do: [ :msg |
        SessionModel current when: #shutdown evaluate: msg.
        ].!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelectorIfNotNil: #directory: with: self directory;
         addSelectorIfNotNil: #fileType: with: self fileType! 
partPropertySetStyle: newStyle
        "Private - Change the receiver's style."

	self partsIfOS2Do: [
		self invalidateRect: nil.
		self partPropertyHasFrameCreationFlags
			ifTrue: [
				self
					disableUpdate;
					partPropertyUpdateFrame: newStyle;
					realInvalidateRect: nil;
					enableUpdate.
				^self ]].

    self setStyle: newStyle.! 
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^true!   
applicationName
        " Answer the name of the PARTS application which owns
        this settings editor. "
    ^self implementedBySubclass! 
transferValuesToNewPart: newPart
        " Private - transfer interesting values from the receiver to the
        new part which it is becoming.  This should generally include
        everything handled by the parts's mirrorCopy. "

    newPart
        owner: owner;
        parent: parent;
        style: style;
        children: children;
        rectangleAttribute: rectangle;
        yourself.
    self transferPropertiesToNewPart: newPart.! 
partEditInterface
        " Edit the part interface of the receiver. "

    self partEditor openApplicationInterfaceEditorOn: self.!   
startFile
    "Private - Answer the startFile"

    ^startFile!
partObjectMessages: selectorsToIgnore
        " Compute the Object-level PARTS message interface
        of the receiver as a sorted collection of public
        messages to which the receiver can respond.
        The messages in selectorsToIgnore should
        not be included in the answer; this set is
        updated to add the answered selectors.
        Answer an assoc whose key is the selectors
        and whose value says whether selectors can
        be cached. "

    | selectors |
    selectors := Set new.
    self
        partAddPublicSelectorsTo: selectors
        in: Object methodDictionary
        ignore: selectorsToIgnore.
    ^Association
        key: selectors asSortedCollection
        value: true  " ok to cache, this answer never changes "!   
reordered
    "Private - The sequence has been reordered.  Perform
    appropriate behavior."

    changed := true.!  
partDragTargetImport: aDragSession
        "Private - aDragSession has just been dropped on the receiver.
      Answer the part that was placed in the receiver (the copy)."
    "Copied to menu bar: Difference is don't erase here"
    | result |

    result := super partDragTargetImport: aDragSession.
    IconDropMark := nil.
    ^result!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelector: #faceName: with: self faceName;
        addSelector: #pointSize: with: self pointSize;
        addSelectorIfTrue: #bold: with: self bold;
        addSelectorIfTrue: #italic: with: self italic;
        addSelectorIfTrue: #strikeOut: with: self strikeOut;
        addSelectorIfTrue: #underscore: with: self underscore;
        addSelector: #makeFont;
        addSelector: #yourself; "need #yourself becuase sometimes #makeFont answers the handle."

        yourself!
partSetLinks: anOrderedCollection forEvent: eventName
        " Set the links triggered by <eventName> from the receiver
        to <anOrderedCollection>.   The order of links in the list
        is the firing sequence. "

    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^#() ].
    " validate the links "
    anOrderedCollection do: [ :aLink |
        aLink isPARTSLink
            ifFalse: [ self error: 'must be a PARTS link' ].
        ( aLink isEventLink
        and: [ aLink trigger = eventName
        and: [ aLink source == myWrapper ] ] )
            ifFalse: [ self error: 'invalid link for this part' ].
        ].
    ^myWrapper setLinkList: anOrderedCollection forEvent: eventName asSymbol!  
workbenchSessionShutdownMessages
        " Private - answer the session #shutdown handlers
        for the PARTS workbench component. "

    ^OrderedCollection new
        add: ( Message
            receiver: self
            selector: #workbenchSessionShutdown );
        yourself!
instantiate: aBoolean className: aString  expression: aSmalltalkExpression
        "Private - Set object to a Smalltalk object by either sending #new to a class called aString
        or evaluating aSmalltalkExpression."

    aBoolean
        ifTrue: [
            [ aString size >0
                ifTrue: [ object := (Smalltalk at: aString asSymbol) new ].
              self closeWindow ]
            on: Error
            do: [ :e | ^MessageBox notify: 'Error' withText: 'Illegal instance' ]]
        ifFalse: [
            [( self compileExpression: aSmalltalkExpression )
                ifTrue: [ self closeWindow ]]
            on: Error
            do: [ :e | ^MessageBox notify: 'Error' withText: 'Compilation error' ]].

    self clearObject!
addBuildNonvisualPartsMethodTo: aClassModel selector: aSelector
        "Private - code generation - add a method model to aClassModel
        that will rebuild the nonvisual parts of the receiver."
    | methodModel expression nonvisualParts |
    nonvisualParts := self topLevelNonvisualParts.
    methodModel := aClassModel newClassMethodNamed: aSelector.
    methodModel argumentModels: self applicationArgumentModels.
    methodModel comment: 'Private - add  the top level nonvisual parts to anApplication'.
    expression := methodModel newMessageExpression setReceiverToSelf.
    nonvisualParts do: [ :part |
        expression addSelector: ( self selectorForComponentBuild: part ) with: self ]!  
partPropertyEditDescription: aPropertyUnit
        " Private - Edit description property button handler "

    | properties contextDictionary oldDescription description newDescription |

    properties := aPropertyUnit propertyStructure.
    contextDictionary := properties partContext.
    oldDescription := self description.
    description := contextDictionary at: #description
        ifAbsent: [ oldDescription ].

    newDescription := PARTSSimpleTextEditor new
        openOn: description
        label: self name, 'Properties - Description'.
    newDescription isNil ifTrue: [ ^self ].  " cancelled or no change "

    contextDictionary at: #description put: newDescription.
    properties
        addAction: ( Message
            receiver: self
            selector: #description:
            arguments: ( Array with: newDescription ) )
        undo: ( Message
            receiver: self
            selector: #description:
            arguments: ( Array with: oldDescription ) ).!   
enableDisableDirectoryButtons
        " Private - the window has just been opened.
        Initialize the search path stuff. "
    searchPath size > 0
        ifTrue: [
            self triggerEvent: #selectDirectory: with: (searchPath at: 1).
            self triggerEvent: #enableDirectoryButtons ]
        ifFalse: [ self triggerEvent: #disableDirectoryButtons ]! 
isPARTSDragDropSession
    "Answer whether the drag drop session
    is an instance of the receiver"

    ^false! 
topLevelNonvisualParts
        "Private - answer the the receiver's top level nonvisual component parts."
    ^self topLevelParts reject: [ :part | part partIsWindow ]!
codeGenerationAddFramingBlockMessagesTo: anExpressionModel
        "Private - add messages to anExpressionModel to
        reconstruct and set the receiver's framing block."
    anExpressionModel
        addSelector: #framingBlock: with: self framingBlock!  
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^true!   
applicationArgumentModel
        "Private - answer an argument model representing the receiver."
    ^CodeGenerationPrivateServices argumentModel new
        object: self;
            name: 'anApplication'!
addBuildApplicationMethodModelTo: aClassModel
        "Private - code generation - add a method model to aClassModel
        that will rebuild a clone of the receiver."
    | methodModel expressionModel selector messagesToRegister |
    methodModel := aClassModel newClassMethodNamed: #buildApplication:.
    methodModel
        argumentModels: self applicationArgumentModels;
        comment: 'Private - Set the attributes of anApplication.'.
    expressionModel := methodModel newMessageExpression.
    expressionModel setReceiverToSelf.
    externalEvents size > 0 ifTrue: [
        selector := #addExternalEventsTo:.
        expressionModel addSelector: selector with: self.
        self addAddExternalEventsMethodTo: aClassModel selector: selector ].
    externalMessages notNil ifTrue: [
        messagesToRegister := externalMessages reject: [ :e | e = #open ].
            messagesToRegister size > 0 ifTrue: [
                selector := #addExternalMessagesTo:.
                expressionModel addSelector: selector with: self.
                self addAddExternalMessages: messagesToRegister methodTo: aClassModel selector: selector ]].
    self topLevelVisualParts size > 0 ifTrue: [
        selector := #buildVisualPartsFor:.
        expressionModel addSelector: selector with: self.
        self addBuildTopLevelVisualPartsMethodTo: aClassModel selector: selector ].
    self topLevelNonvisualParts size > 0 ifTrue: [
        selector := #buildNonvisualPartsFor:.
        expressionModel addSelector: selector with: self.
        self addBuildNonvisualPartsMethodTo: aClassModel selector: selector ].
    expressionModel := methodModel newMessageExpression.
    expressionModel receiverObject: self.
    self
        addApplicationAttributeMessagesTo: expressionModel;
        codeGenerationAddComponentMessageModelsTo: expressionModel;
        addBuildEditStateMethodsTo: aClassModel;
        addApplicationPropertiesMethodTo: aClassModel!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setValue: with: self value.
    self isWordWrapEnabled
        ifTrue: [
            anExpressionModel addSelector: #wrap: with: true ]
        ifFalse: [
            anExpressionModel addSelector: #wrap: with: false ]
!  
transferValuesToNewPart: newTablePane
        " Private - transfer interesting values from the receiver to the
        new part which it is becoming.  This should generally include
        everything handled by the parts's mirrorCopy. "

    super transferValuesToNewPart: newTablePane.
    newTablePane
        font: curFont;
        defaultCellHeight: cellHeight;
        defaultCellWidth: cellWidth;
        columnLabelsHeight: labelsHeight;
        rowLabelsWidth: labelsWidth.
    ( fixedExtent notNil and: [ fixedExtent x > 0 ] )
        ifTrue: [
            newTablePane newNumberOfColumns: fixedExtent x ]
        ifFalse: [ "formally unlimited number of columns"
            newTablePane newNumberOfColumns: self computeNumberOfColumns ].
    columnLabels notNil ifTrue: [
        newTablePane columnLabels: columnLabels ].
    rowLabels notNil ifTrue: [
        newTablePane rowLabels: rowLabels ].
    columnNames notNil ifTrue: [
        newTablePane columnNames: columnNames ].
    rowNames notNil ifTrue: [
        newTablePane rowNames: rowNames ].
    ( fixedExtent notNil and: [ fixedExtent y > 0 ] )
        ifTrue: [
            newTablePane newNumberOfRows: fixedExtent y ]
        ifFalse: [
            newTablePane newNumberOfRows: self computeNumberOfRows ].
    self
        transferExtStyles;
        transferCellDimensions.
    newTablePane contents: rows.
    newTablePane updateAccess! 
okSave
    " Private - the OK button has been pressed in a
    Save File dialog. "

    | fileName type |

    fileName := self fileNameField.
    ( fileName includes: $* )
        ifTrue: [
            ^application fileNameChanged: fileName ].

    ( answer := self getPathName: fileName ) isNil
        ifTrue: [ ^nil ].

    answer := PARTSFileDescriptor pathName: answer.
    ( type := fileTypes detect: [ :each | each pattern = pattern ] ifNone: [ nil ]) notNil
        ifTrue: [ type := type type ].
    ( type notNil
        and: [ type ~= PARTSFileDescriptor fileTypeForAll type
        and: [ ( answer fileType equalsIgnoreCase: type ) not
        and: [ ( MessageBox confirm:
            'File extension does not conform to the format requested, save as type: ',
            answer fileType, '?' ) not ] ] ] )
        ifTrue: [ ^answer := nil ].

    (( PARTSFile exists: answer fullPathName )
        and: [ ( MessageBox confirm:
            answer fullPathName, ' already exists.  Replace file?' ) not ] )
        ifTrue: [ ^answer := nil ].

    self class lastDirectoryUsed: selectedDirectory.
    application closeWindow!   
open
        " Open the PARTS settings dialog. "

    settings := PARTSSettings current.
    newSettings := settings copy.
    searchPath := PARTSFile currentSearchPath.
    searchPathChanged := false.
    self openApplicationOn: self.!   
partDragTargetAccept: aDragDropSession
        "Private - aDragSession is being dragged over the receiver.
        Tell aDragDropSession if and how it will be accepted."
    | mainObject |

    aDragDropSession objects do: [ :aDragDropObject |
        mainObject := aDragDropObject mainObject.
        (( self partCanWindow: self haveChild: mainObject )
            or: [ aDragDropSession mightReplace
                and: [ self partCanBeReplacedBy: mainObject ]])
            ifFalse: [ ^aDragDropSession operation: nil ]].

    aDragDropSession operation: #copy! 
isValidGlobalName: aString
        " Answer whether <aString> is a syntactically
        legal identifier which can be used in a global
        name space or as a pool dictionary name. "

    | aCompiler |
    aCompiler := CompilerInterface new.
    ( aString size = 0
    or: [ ( aCompiler validAsGlobalHead: ( aString at: 1 ) ) not ] )
        ifTrue: [ ^false ].
    aString do: [ :aCharacter |
        ( aCompiler validInIdentifierBody: aCharacter )
            ifFalse: [ ^false ] ].
    ^true!  
writeNewFile: aPathName
    name: aNameString
    solePart: anObject
    icon: anIcon
    partIcon: partIcon
    hint: aHintString
    helpFile: aHelpFileName
    helpTopic: aHelpTopicName
    nestingMode: nestingMode
    dllNameDict: dllNameDict
        " OBSOLETE - retained for compatibility in PW 3.0 "

    self obsoleteMethod.
    self
        writeNewFile: aPathName
        name: aNameString
        solePart: anObject
        icon: anIcon
        partIcon: partIcon
        hint: aHintString
        helpFile: aHelpFileName
        helpTopic: aHelpTopicName
        nestingMode: nestingMode
        libraryMappings: dllNameDict!  
scaleUnit
    "Private - Answer the scale unit of the receiver"
    | app |

    app :=
        parent notNil
            ifTrue: [ parent partApplication ]
            ifFalse: [
                ( connection notNil and: [
                    connection isPARTSCatalogIconConnection not ])
                    ifTrue: [ connection partApplication ]
                    ifFalse: [ nil ]].
    ^app notNil
        ifTrue: [ app defaultScaleUnit ]
        ifFalse: [ PARTSFramer defaultScaleUnit ].
!  
eraseSelection
    "Private - Erase the insertion mark created when a menu label
    is dragged to the menu bar."
    "Copied to menu bar"

    self basicDrawMark: IconDropMark.!   
scrollingHotZone
        "Private - answer a Point which represents the amount of inset
        from the window rectangle which is the drag scrolling hot zone."
    ^Icon iconSize
! 
openDialogWindow
        "Private - Open the properties editor dialog window."
    | result |
    result := super openDialogWindow.
    application eventTable removeAll.   "events are reset between operations"
    ^result!   
initializeEventHandlersForSave
    "Private - Initialize the events specific to #save"

    application
        when: #ok
            send: #okSave to: self!
new
        " Answer an instance of the receiver "

    ^self basicNew initialize! 
promptForDirectory

    | dirString defaultDir |
    defaultDir := Disk drivePathName "asLowerCase".
    [( PARTSApplication loadPartFile: 'PTSDRDLG' )
        when: #directory: evaluate: [ :dir | dirString := dir ];
        openOn: defaultDir ]
            on: PARTSApplicationLoadError
            do: [ :e |
                e postMessageBox: 'Add Directory Error'.
                ^nil ].
    dirString isNil
        ifTrue: [ ^ nil ]
        ifFalse: [ ^ PARTSDosDirectory pathName: dirString ]!  
reordered
    "Private - The sequence has been reordered.  Perform
    appropriate behavior."

    self implementedBySubclass!
openOn: aDirectoryList
        " Open search path sequence editor on aDirectoryList.
        Answer the resequenced list (nil if not changed). "
    list := aDirectoryList.
    changed := false.
    answer := nil.
    self
        createView;
        openWindow.
    ^answer!  
partOtherEvents
        " Answer the secondary PARTS event interface
        of the receiver as a sorted collection of events. "

    ^( self class eventsTriggered 
        reject: [ :anEvent | anEvent = self class changedEventName ] )
            asSortedCollection! 
newTablePane: aTablePane
        "Private - set the new table pane. "

    newTablePanePart := aTablePane.!
fileNameEntered: fileName
    "Private -
    Update the file list if the new name is a pattern."
    | name oldPattern |

    fileName isNil
        ifTrue: [ ^nil ].

    ( name := fileName trimBlanks ) isEmpty
        ifTrue: [ ^nil ].

    ( name indexOf: $* ) ~= 0
        ifTrue: [
            oldPattern := pattern.
            pattern := name.
            application updateFiles.
                "Don't let OK get default focus"
            ( Message new
                receiver: application;
                selector: #setFilenameFocus;
                yourself ) performDeferred.
            pattern := oldPattern.
            ^nil ].

    application performOK! 
partRemoveScript: scriptMessageSelector
        " Delete the script attached to the receiver named
        <scriptMessageSelector>. "

    | myWrapper |
    (myWrapper := self partWrapper) isNil
        ifTrue: [ ^self error: 'not a part' ].
    myWrapper removeScript: scriptMessageSelector asSymbol.! 
partUpdate: newApp
        "Application has been updated."
    
    self partIsEditing ifFalse: [^self]. "in case editor is closed."
    application := newApp.   " force refresh from file when rebuilt"
    self fileDescriptor: newApp fileDescriptor.  "may have been changed"!  
initClassList
        "Answer a sorted Array of Strings representing the list of classes in the system."
    CursorManager execute changeFor:
        [classNames := OrderedCollection new:4000.
        Smalltalk rootClasses do: [:rootClass |
            self addAllSubclasseNamesOf: rootClass to: classNames].
		classNames := (classNames reject: [:className |
			className  first = $ ] )
				asSortedCollection asArray.
        self triggerEvent: #classNames: with: classNames.
        ^classNames]!  
partFileInUpgradeLoadedWindows: anObjectFiler
        " Private - finish upgrading a visual part from PW/Win32 2.0. "
    | hasTab |

    super partFileInUpgradeLoadedWindows: anObjectFiler.

    hasTab := ( self propertyAt: #noTabStop ) ~= true.
    hasTab
        ifTrue: [ self tabStop ]
        ifFalse: [ self noTabStop ].
    self propertyAt: #noTabStop put: nil!   
partHint
        "Answer a string which gives a brief description
        of the receiver part. "
    ^''! 
button1Down: aPoint
        " The left mouse button has been pressed at <aPoint>. "

    ( self labelContainsPoint: aPoint )
        ifTrue: [ self editLabel ]!  
partDragTargetEraseEmphasis: aDragSession
    "Private - erase drag drop target emphasis.
    The menu label is being dragged away from the
    menu bar or being dropped in the menu bar."
    "Copied to menu bar"

    IconDropMark := nil.
    super partDragTargetEraseEmphasis: aDragSession!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelectorIfNotNil: #day: with: self day!  
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer receiverModel  |

    self printString = PARTSHostInterface defaultPartFont printString ifTrue: [
        answer := aCodeGenerator messageExpressionToReference: self.
        answer
            receiverObject: PARTSHostInterface;
            addSelector: #defaultPartFont.
        ^answer ].

    self printString = PARTSHostInterface defaultPartTextFont printString ifTrue: [
        answer := aCodeGenerator messageExpressionToReference: self.
        answer
            receiverObject: PARTSHostInterface;
            addSelector: #defaultPartTextFont.
        ^answer ].

    self printString = PARTSSettings current defaultFontDialogs printString ifTrue: [
        answer := aCodeGenerator messageExpressionToReference: self.
        receiverModel :=answer newReceiverMessageExpressionModel.
        receiverModel
            receiverObject: PARTSSettings;
            addSelector: #current.
        answer addSelector: #defaultFontDialogs.
        ^answer ].

    ^super codeGenerationMessageExpressionIn: aCodeGenerator!
setScrollBar: scrollBar position: position range: range thumbSize: thumbSize
        "Private - set the scroll bar position, range, and thumb size."

    self partsVosOnly.
    PARTSHostInterface hostWindowLibrary
        sendMsg: scrollBar handle
        msg: "SbmSetscrollbar" 416
        mp1: position
        mp2: ( ExternalLong new lowHalf: 0; highHalf: range ) asParameter.
    PARTSHostInterface hostWindowLibrary
        sendMsg: scrollBar handle
        msg: "SbmSetthumbsize" 422
        mp1:  thumbSize asParameter
        mp2: 0
!  
updateScrollRanges
        "The scrollable area has changed, update the scroll ranges
         to reflect the new scrollable area."
    | oldRanges newRanges |
    oldRanges := self getScrollRanges.
    self setScrollRanges: true.
    newRanges := self getScrollRanges.
    "must scroll back because setScrollRanges: will scroll window
     to origin if scroll bars are added or removed."
    ( ( oldRanges x > 0 xor: ( newRanges x > 0 ) )  or: [
        oldRanges y > 0 xor: ( newRanges y > 0) ] ) ifTrue: [
            "oldCorner := topCorner deepCopy.
            topCorner := 0 @ 0.
            self scrollTopCorner: topCorner - oldCorner continuous: true" ].
    self updateSliders
!   
partDragTargetDrawEmphasis: aDragSession
    "A menu label is being dragged over the menu bar.
    Draw visual feedback for insertion point."
    "Copied to menu bar"

    self draggingOver: aDragSession.

    super partDragTargetDrawEmphasis: aDragSession!  
sequencePaneBackColor
        " Private "

    ^PARTSSettings current colorWorkbench!  
partCanBeReplacedBy: aPart
    "Answer whether the receiver can be replaced
    by <aPart> on the workbench.  All links will be
    reattached to <aPart>."

    ^self superWindow notNil
        ifTrue: [
            self superWindow
                partCanWindow: self superWindow
                haveChild: aPart ]
        ifFalse: [ false ]! 
partDroppedPart: aPart hotSpot: hotSpot origin: origin
        "Private - the receiver is in the workbench
        and aPart has just been dropped on it (the
        receiver).  hotSpot is the location of the drag
        session and origin is the location of the individual
        object.  hotSpot and origin are in receiver's
        coordinates.  Default is do nothing."! 
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."
    self partsVwOnly.  " only used on Win32 "
    ^nil!
partCanBeReplacedBy: aPart
    "Answer whether the receiver can be replaced
    by <aPart> on the workbench.  All links will be
    reattached to <aPart>."

    ^aPart isSubPane
        and: [ super partCanBeReplacedBy: aPart ]!
codeGenerationAddScrollBarMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver's scroll bars to anExpressionModel."
    self codeGenerationCanHaveScrollBars ifFalse: [ ^self ].
    self hasHorizontalScrollBarStyle
        ifTrue: [
            anExpressionModel addSelector: #addHorizontalScrollbarStyle ]
        ifFalse: [
            anExpressionModel addSelector: #removeHorizontalScrollbarStyle ].
    self hasVerticalScrollBarStyle
        ifTrue: [
            anExpressionModel addSelector: #addVerticalScrollbarStyle ]
        ifFalse: [
            anExpressionModel addSelector: #removeVerticalScrollbarStyle ]! 
editMouseButtons
    "Edit the button 1 and button 2 mappings"

    self partsVwOnly.  " Only used on VW"

    (Smalltalk at: #PARTSMouseButtonsSettingsEditor) findOrOpenOn: settings.! 
createNewPart
        " Private - answer a new instance of the part class
        which will represent the receiver in the current system.
        Map a PWO 2.0 TablePane into the PW 2.0 class. "

    | newPart |
    newPart := (Smalltalk at: #PARTSTablePanePart) new.
    self newTablePane: newPart.
    ^newPart!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."

    anExpressionModel
        addSelectorIfNotNil: #label: with: self label;
        addSelector: #showLabel: with: self showLabel!
dragSourceCut: aDragSession
    "Private - The sequence has been reordered.  Perform
    appropriate behavior."

    aDragSession target dragSourceCutDefault: aDragSession.
    self reordered.!
opened
    "Private -These go here instead of 'initializePartValues' because listBox
    won't allow selection when handle is not yet valid."

    selectedDirectory isNil
        ifTrue: [ application directorySelected: application selectedDirectory ].
    ( self partNamed: 'FileList' ) setValue: ( self fileNameField )!   
promptForSave: aFileDescriptor fileTypes: fileTypes title: aTitle
    "Private"

    ^self
        promptDialog: #save
        initialFile: aFileDescriptor
        fileTypes: fileTypes
        defaultPattern: aFileDescriptor fileType
        title: aTitle!  
addVertScrollBar
        "Private - add the vertical scroll bar when the scroll range is greater than zero."
    | frameStyle |
    self partsVosOnly.
    frameStyle := self addVerticalScrollbarStyle.
    self partPropertySetStyle: frameStyle
!
colorButtonSelected
        "Private - The color button has been selected. "
    mode := #color.
    self setColorBoxes!   
entryInteriorBorder
        " Private - answer the interior border (points)
        of a list entry. "

    ^1 + self entryBorderLineWidth!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #showHints #showHints: #showLinkLabels #showLinkLabels:
            #showLinksWithSelection #showLinksWithSelection:
            #gridX #gridX: #gridY #gridY:
            #userName #userName:
            #searchPath
            #addDirectory #removeDirectory: #sequenceDirectories
            #editLinkColors #editBackgroundColors
                #editMouseButtons  " PWW only "
            #enableDisableDirectoryButtons
            #orthogonalLinks #orthogonalLinks:
            #acceptProperties #close )
                asSortedCollection asArray! 
removeDirectory: dir
        " Remove directory dirPathName from the search path.
    If unable to, answer nil"
    | selectedIndex newSelection |

    ( dir cleanUp ) isNil
        ifTrue: [ ^nil ].

    selectedIndex := searchPath indexOf: dir.
    searchPath := searchPath reject: [ :aDir |
        aDir = dir ].

    searchPathChanged := true.
    self triggerEvent: #searchPathChanged: with: searchPath.
    searchPath size > 0
        ifTrue: [
            newSelection := searchPath at: ( ( selectedIndex - 1 ) max: 1 ).
            self triggerEvent: #selectDirectory: with: newSelection ]
        ifFalse: [ self triggerEvent: #disableDirectoryButtons ].!
partDragTargetEnter: aDragSession
        "Private - aDragSession has just entered the receiver.
    Initialize the drop mark."
    "Copied to menu bar"

    IconDropMark := nil.
    super partDragTargetEnter: aDragSession! 
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. "
    self contents: text.!
installWorkbenchSupportLibraries
        " Private - the main PARTS Workbench workbench library has been installed.
        Install the workbench support libraries for any part libraries whose
        runtime library has already been installed. "

    | info isBound |
    self workbenchLibrariesOrdered do: [ :aLibraryName |
        info := self workbenchSupportLibraries at: aLibraryName.
        isBound := self bindWorkbenchSupportLibrary: aLibraryName
            for: ( info at: 1 ).   " library description "
        info at: 2 put: isBound ].! 
wmVLbuttondown: wParam with: longInteger
        "Private - Add a MessageExpression to CurrentEvents
         and return right away."
    | point |
    self partsVwOnly.  " Only used on VW"
    point := Point fromInteger: longInteger.
    self partIsEditing ifTrue: [
        ^self partEditorPane partButton1Down: (
            point mapFromWindow: self to: self partEditorPane ) ].
    ^self wmLbuttondown: wParam with: longInteger!
initExtendedStyleDictionary
        "Private - initialize the extendedStyleDictionary.
        This was the ExtendedStyleDictionary class var
        in 2.0 TablePane.  We don't want a class var
        hanging around and taking up space, so we
        store it in a temporary instance var."

    pwo20ExtendedStyleDictionary := IdentityDictionary new
        at: #editRowLabels put: 1;
        at: #editColumnLabels put: 2;
        at: #editCornerLabel put: 3;
        at: #fixedRowWidth put: 4;
        at: #fixedNumberRows put: 5;
        at: #adjustColumnWidths put: 6;
        at: #adjustRowHeights put: 7;
        at: #adjustRowLabelsWidth put: 8;
        at: #adjustColumnLabelsHeight put: 9;
        at: #noScrollAdjustCells put: 10;
        at: #sculpturedLabels put: 11;
        at: #hasRowLabels put: 12;
        at: #hasColumnLabels put: 13;
        at: #readOnly put: 14;
        at: #horzScroll put: 15;
        at: #vertScroll put: 16;
        at: #indexedColumns put: 17;
        at: #indexedRows put: 18;
        at: #displayColumnLabels put: 19;
        at: #displayRowLabels put: 20;
        yourself!  
addFilter: aFilter description: aDescription
        "Add aFilter and aDescription to the list of File dialog
        filters."

    aFilter asLowerCase ~= '*.txt'  "Illegal type"
        ifTrue: [ ^super addFilter: aFilter description: aDescription ].!
selectorForComponentBuild: aComponent
        "Private - code generation - answer a selector which will
        be the name of the method that rebuilds aComponent
        when the receiver is being rebuilt."
    ^ 'build', aComponent partName, 'For:'!   
partIsShrinkable
        "Private - Can this part shrink in a PARTS Workbench."
    ^false! 
updateTool: aTool
        "Private - aTool has been updated."

    self isHandleOk ifFalse: [^self].
    self doGraphics: [
        aTool displayWith: self graphicsTool ].! 
displayHelp: anId fromFile: aHelpFile
    "Bring up the Windows Help for the topic
      defined by anId from the help file aHelpFile.
      Answer true, if successful."

    ^self
        partsIfOS2Do: [self displayHelp: anId fromFileOS2: aHelpFile]
        partsIfWindowsDo: [self displayHelpContext: anId fromFile:  aHelpFile]! 
anyFileRequested: fileDialog
        " Private - the Any File button has been pressed. "

    self partsIfOS2Do: [ "OS/2 FileDialog doesn't enable setting of fileTypes"
        self operation = #save
            ifTrue: [ fileDialog pathNameForSave: self fileNameField ]
            ifFalse: [ fileDialog pathNameForOpen: self fileNameField ]]
    partsIfWindowsDo: [
        self operation = #save
            ifTrue: [
                fileDialog
                    pathNameForSave: self fileNameField
                    fileTypes: fileTypes
                    defaultPattern: pattern ]
            ifFalse: [
                fileDialog
                    pathNameForOpen: self fileNameField
                    fileTypes: fileTypes
                    defaultPattern: pattern ]]
! 
partPropertyStyle
        "Private - Answer the receiver's style.  For windows with frame
        creation styles, access the frame creation flags.   This
        works as long as all the changable styles either belong
        to the frame styles set, or all styles don't belong to the set."

    self partsIfOS2Do: [
        self partPropertyHasFrameCreationFlags
            ifTrue: [
                ^Dictionary new
                    at: #style put: self frameCreationFlags;
                    yourself ]].

    ^Dictionary new
        at: #style put: self style;
        yourself!
framer
    "Private - Answer a framer for the receiver."
    | framer top left extent scaleUnit |

    scaleUnit := self scaleUnit.
    framer := PARTSFramer new.
    framer scaleMask: framer maskForDefault.
    framer scaleUnit: scaleUnit.
    extent := self class defaultExtent.

    self superWindow notNil
        ifTrue: [
            top :=
                self partsIfOS2Do: [
                    ( self superWindow rectangle top - self origin y ) - self extent y ]
                partsIfWindowsDo: [
                    self origin y ].
            left := self origin x ]
        ifFalse: [ "Default is origin"
            origin notNil
                ifTrue: [
                    top := origin y.
                    left := origin x ]
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
lastDirectoryUsed
    " Private - Answer the last directory used to set the
    default directory in the dialog. "

    ^LastDirectoryUsed!   
partDragTargetDrawEmphasis: aDragSession
        "Private - display drag drop target emphasis."
    self partReverseEmphasis: self partTargetEmphasisRectangle! 
fileNameChanged: fileName
    "Private - Answer the name if it is a valid file name.
    Update the file list if the new name is a pattern."
    | name |

    fileName isNil
        ifTrue: [ ^nil ].

    ( name := fileName trimBlanks ) isEmpty
        ifTrue: [ ^nil ].

    ( name indexOf: $* ) ~= 0
        ifTrue: [
            pattern := name.
            application updateFiles.
            ^nil ].

    ^name!
displayExtendedHelp
        "Private - display the help when there is not
        context sensitive help avialbable. "
    ^self
        partsIfOS2Do: [super extendedHelp]
        partsIfWindowsDo: [self displayHelpIndexFromFile]!   
okOpen
    " Private - the OK button has been pressed in an
    Open File dialog. "
    | fileName fileTypeForAll allTypeExists typeDetected |

    fileName := self fileNameField trimBlanks.
    ( fileName includes: $* )
        ifTrue: [
            ^application fileNameChanged: fileName ].

    answer := PARTSFileDescriptor
        fileName: fileName
        in: selectedDirectory.

    "Detect if answer type isn't in the file type list and can't edit the type"
    fileTypeForAll := PARTSFileDescriptor fileTypeForAll.
    allTypeExists := false.
    typeDetected := ( fileTypes detect: [ :aPartFileType |
        aPartFileType type = fileTypeForAll type
            ifTrue: [ allTypeExists := true ].
        aPartFileType type = answer fileType ] ifNone: [ nil ]) notNil.
    ( typeDetected or: [
        ( allTypeExists
            and: [ ( PARTSFileProcessor getProcessorFor: answer ) class canEdit ])])
        ifFalse: [
            MessageBox warning: 'Loading a file of type ',
                answer fileType,' is not supported.'.
            ^answer := nil ].

    self class lastDirectoryUsed: selectedDirectory.
    application closeWindow!  
partDragTargetDrop: aDragDropSession
        "Private - aDragSession has just been dropped on the receiver. "


    "Below if from dragTargetDrop:"
    aDragDropSession targetSelection: self dragTargetSelection.
    self dragTargetStopScrollTimer.
    aDragDropSession targetEraseEmphasis.

    aDragDropSession isPARTSEditorMoveSession
        ifTrue: [ ^self partDragTargetMove: aDragDropSession ].

    aDragDropSession isReplaceOperation
        ifTrue: [ ^self partDragTargetReplace: aDragDropSession in: self superWindow ].

    aDragDropSession isPARTSPasteSession
        ifTrue: [ ^self partDragTargetPaste: aDragDropSession ].

    self partDragTargetImport: aDragDropSession.! 
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

    anObjectFiler recordWarningMessage:
        'Upgrade-only object ', self printString,
        ' should not exist anymore, but was encountered in #fileInActivate: .'!   
partIsSelected
        " Answer whether the receiver is currently selected
        in a PARTS Workbench. "
    ^self partEditor selectedComponents includes: self! 
openOn: aPARTSEditor
        " Edit the background color settings in aPARTSEditor. "
    self openApplicationOn: aPARTSEditor.! 
partPropertyFileNamePrefix
        " Private "
    ^'File name: '!  
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer  |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        receiverObject: self class;
        addSelector: #index: with: self index.
    ^answer! 
updateHorizontalSlider
        "Private - update the horizontal slider position."
    self updateHorizontalSliderTo: topCorner x
! 
paxStarterLibrary
    "Private - Answer the name of the library which loads and opens
    the main pax file."
    ^'PWCSTR31'.!
partOtherMessages: selectorsToIgnore
        " Compute the secondary PARTS message interface
        of the receiver as a sorted collection of public
        messages to which the receiver can respond.
        The messages in selectorsToIgnore should
        not be included in the answer; this set is
        updated to add the answered selectors.
        Answer an assoc whose key is the selectors
        and whose value says whether selectors can
        be cached. "

    | selectors class |
    selectors := Set new.
    " include useful guys who haven't already appeared "
    self partMessagesStandard items do: [ :aSelector |
        (selectorsToIgnore includes: aSelector)
            ifFalse: [
                selectors add: aSelector.
                selectorsToIgnore add: aSelector]].
    " plus public methods "
    class := self class.
    [class == Object] whileFalse: [
        self
            partAddPublicSelectorsTo: selectors
            in: class methodDictionary
            ignore: selectorsToIgnore.
        class := class superclass].
    ^Association
        key: selectors asSortedCollection
        value: true  " ok to cache, this answer never changes "!  
patternChanged: string
    " Private - a new pattern string has been entered.
    If the old type matches the file name type, then change the file name
    type to match the new type. "
    | name oldPattern |
    string isNil ifTrue: [ ^nil ].
    oldPattern := pattern.
    pattern := ( fileTypes detect: [ :each | each description = string ] ) pattern.
    (( name := self fileNameField ) includes: $* )
        ifTrue: [ application setFileName: pattern trimBlanks ]
        ifFalse: [
            self operation = #save
                ifTrue: [
                    pattern = '*.*' "Special case"
                        ifTrue: [ application setFileName: '*.*' ]
                        ifFalse: [
                            ( name asUpperCase
                                indexOfString: oldPattern fileExtension asUpperCase ) > 0
                            ifTrue: [
                                name :=
                                    ( name fileName, '.', pattern fileExtension ) "asLowerCase".
                                application setFileName: name ]]]].

    application updateFiles.! 
showHints
    ^settings showHints!   
pathNameForSave: defaultFileName
    fileTypes: fileTypes
    defaultPattern: aDefaultPattern
        " Open the Save File dialog with aString
        as the default file name. "

    ^self openDialogMessage: (  Message new
        receiver: self dialogBoxCreate
        selector:  #saveFile:fileTypes:defaultPattern:
        arguments:
            ( Array
                with: defaultFileName
                with: fileTypes
                with: aDefaultPattern ))! 
classModelInContext: aCodeGenerator
        "Private - code generation - answer a class model
        of the reciever in the context of aCodeGenerator."
    | answer className poolName |
    className := self builderClassName.
    [ aCodeGenerator globalNamesUsed includes: className ]
        whileTrue: [ className := ( className, 'X' ) asSymbol ].
    poolName := self componentPoolNameForClassModel.
    [ aCodeGenerator globalNamesUsed includes: poolName ]
        whileTrue: [ poolName := ( poolName, 'X' ) asSymbol ].
    answer := aCodeGenerator newClass
        className: className
        superclassName: PARTSApplicationCoordinator name
        instanceVariableNames: ''
        classVariableNames: ''
        classInstanceVariableNames: ''
        poolNames: ( Array with: poolName ).
    answer object: self.
    ^answer! 
userName: aString
    newSettings userName: aString.!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelectorIfNotNil: #key: with: key;
        addSelectorIfNotNil: #value: with: value!
applyChanges
        "Private - Apply changes to the icon. Do not update
         file if one exist. File is updated by Save or Save as.."
    | extent |
    extent := ( icon bitmap isNil
        ifTrue: [ PARTSIcon iconSize ]
        ifFalse: [ icon extent ] ).
    icon release.
    ( icon andMask isNil or: [ icon andMask isValid not ] )
        ifTrue: [
            icon andMask: ( Bitmap extent: extent ).
            icon xorMask: ( Bitmap screenExtent: extent ) ].
    icon andMask pen
        copyBitmap: andMask
        from: andMask boundingBox
        at: 0 @ 0.
    icon xorMask: xorMask clone.
    icon createIcon.

    changeFlag := false.
    saveBlock notNil
        ifTrue: [ saveBlock value ].!
initializeWorkbenchData
        " Private - initialize classes which have
        to be done at installation time (certain
        class vars which couldn't be put in the component). "

    PARTSSettings current
        initialize;
        suppressLoadMessages: true.

    self partsIfWindowsDo: [
        ( SelfDefinedStructure definitions keys includes: 'IconInfo' ) not
            ifTrue: [  " copy literals so structure can be left defined if the library is unbound "
                SelfDefinedStructure
                    define: 'IconInfo' copy
                    withFields: ( Dictionary new
                        at: #fIcon put: #( 0 #ulong #yourself ) copy;
                        at: #xHotSpot put: #( 4 #ulong #yourself ) copy;
                        at: #yHotSpot put: #( 8 #ulong #yourself ) copy;
                        at: #maskBitmap put: #( 12 #ulong #yourself ) copy;
                        at: #colorBitmap put: #( 16 #ulong #yourself ) copy;
                        yourself )
                ].
        ].!   
promptDialog: anOperation title: aTitle
    "Private- Open the desired choose dialog."

    ^( PARTSChooseFileDialog chooseFileDialogClass: anOperation )
        operation: anOperation
        title: aTitle!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy.
        Set the height explicitly because the font is set
        indirectly through the property mirror copy."

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy dragButton: ( dragButton partMirrorCopy: aMirrorCopyDictionary).
    copy separatorString: ( separatorString partMirrorCopy: aMirrorCopyDictionary  ).
    copy userCanReorder: ( userCanReorder partMirrorCopy: aMirrorCopyDictionary  ).
    ^copy!
setScrollRanges
        "Private - set the horizontal and vertical scroll ranges to
          prevent users from scrolling out of bound."
    self setScrollRanges: true!  
scrollHorizontal: anInteger
        "Private - Scroll the pane left by anInteger
         number of pixels (if positive) or right by
         the absolute value of anInteger (if negative)."
    self scrollTopCorner: anInteger @ 0!
name: aNameString
    solePart: anObject
    icon: anIcon
    partIcon: partIcon
    hint: aHintString
    helpFile: aHelpFileName
    helpTopic: aHelpTopicName
    nestingMode: nestingMode
        " Answer a new application containing the
        single part <anObject>.  "

    | applicationName application |

    ( anObject isPARTSApplication
     or: [ ( self supportedReuseModes includes: nestingMode ) not
    or: [ ( self isValidGlobalName: aNameString ) not ] ] )
        ifTrue: [ self error: 'cannot create application with requested values' ].

    applicationName := aNameString, 'Part'.
    application := self newWithName: applicationName.
    "self ASSERT: application partName = applicationName."
    application
        title: application name;
        icon: anIcon;
        partHint: aHintString;
        reuseMode: nestingMode;
        editorState: PARTSEditorState new.
    application helpFile: aHelpFileName helpTopic: aHelpTopicName.

    PARTSEditor editorClass new
        addObject: anObject
        to: application
        name: aNameString, '1'
        helpInfo: application partWrapper helpInfo
        icon: partIcon.
    ^application! 
moveFrom: begin to: end after: anchor
    "Copied to menu bar"
    | front components |

    front := anchor.
    components := self partWrapper components.
    begin to: end do: [:i |
        self position: (components at: i) object
            after: front.
        front := (components at: i) object]! 
partFileInUpgradeLoadedWindows: anObjectFiler
        " Private - finish upgrading a visual part from PW/Win32 2.0. "

    super partFileInUpgradeLoadedWindows: anObjectFiler.

    "VWin32 2.0 set property as well as style; no longer used in 3.0 "
    ( self propertyAt: #isAGroupLeader ) == true
        ifTrue: [
            self isAGroupLeader ifFalse: [ self startGroup ].  " backstop "
            self propertyAt: #isAGroupLeader put: nil.
            ].

    " backstop to clear PWO 2.0 properties that source code may have transfered to PWW "
    self
        propertyAt: #PARTSOrderedChildren put: nil;
        propertyAt: #PARTSGroupLeaders put: nil;
        propertyAt: #fontParams put: nil.!   
partPropertyWindowStyle: aString constant: anInteger
    " Private - answer a window style property unit
        labelled aString which maps onto style bits anInteger.
        For OS2, all pertinent styles are frame styles and accessed
        via the frameCreationStyle methods."

    ^PARTSPropertyWindowStyle new
        constant: anInteger;
        label: aString;
        value: (
            self partsIfOS2Do: [
                self partPropertyHasFrameCreationFlags
                    ifTrue: [ self hasFrameCreationFlag: anInteger ]
                    ifFalse: [self hasStyle: anInteger ] ]
            partsIfWindowsDo: [
                self hasStyle: anInteger ] )!
stringRepresentation
        "Private - answer a String representation of the receiver."
    | stream |
    stream := WriteStream on: ( self partsIfOS2Do: [ String ] partsIfWindowsDo: [ ByteArray ] ) new.
    self outputToFileStream: stream.
    ^stream contents asString! 
removeWorkbenchComponent
        " Private - prepare to remove the PARTS workbench component.
            PARTSWorkbenchSessionManager removeWorkbenchComponent
        "

    self
        removeWorkbenchData;
        removeWorkbenchService;
        removeWorkbenchSupportLibraries;
        removeWorkbenchPlatformEvents;
        removeWorkbenchSessionEventHandlers.!  
compilerError: aString at: anInteger in: codeString for: aClass
        "Private - pass the error onto the current expression evaluator."
    self triggerEvent: #compilerError:at:in:for:
        withArguments: (Array with: aString with: anInteger with: codeString with: aClass)! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    super partPrintPropertiesOn: aStream margin: aString.
    self partPrintColorAndFontPropertiesOn: aStream margin: aString.
    [ self framingBlock printPropertiesOn: aStream margin: aString ]
        on: MessageNotUnderstood do: [ ].  " punt if not a PARTS framing specification "! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object.
        Map the part being upgraded into a new class 
        for the current system.   We have to be careful
        to ensure that a VOS subpane's id gets set correctly;
        the newPart's fileInUpgrade from SubPane won't
        find the newPart, so we ask again with the guy
        which is still in the children dictionary at this point. 
        (The VW subpane id will get set correctly.) "

	| newPart parentWindow |
    newPart := super fileInUpgrade: anObjectFiler.
    self partsIfOS2Do: [
	    ( parentWindow := newPart superWindow ) notNil
		    ifTrue: [ newPart id: ( parentWindow children keyAtValue: self )].
        ].
    ^newPart!
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
transferPropertiesToNewPart: newPart
        " Private - transfer properties values (add to any existing entries) "

    properties isNil
       ifTrue: [ ^self ].
    properties associationsDo: [ :assoc |
        newPart propertyAt: assoc key put: assoc value ].!
codeGenerationStoreOn: aCodeGeneratorStream
        "Private - store a souce code representation on aCodeGeneratorStream."
   aCodeGeneratorStream nextPutAll: '#[ '.
    self do: [ :n |
        n printOn: aCodeGeneratorStream.
        aCodeGeneratorStream space.
        aCodeGeneratorStream currentColumn > 60
            ifTrue: [
                aCodeGeneratorStream
                    superCr;
                    nextPutAll: aCodeGeneratorStream tabString ]].
    aCodeGeneratorStream nextPutAll: ']'; cr!
refreshItems
    "Refresh all items in the receiver's"
    "Copied to menu bar"

    self invalidateRect: nil.
    self updatePositions! 
canTab
        "Private - Answer whether the receiver can
        be tabbed into and out of."
    "Copied to menu bar"

    ^false!  
close
        "Close the receiver's window."
    application closeWindow!   
partLinkTriggers
        " Answer a list of events which trigger links from the receiver. "

    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^#() ].
    ^myWrapper linkTriggers!   
partSelectorParts
        "Answer an Array of Strings, a representation of the
        receiver as it would be expressed as a selector in
        source code."
    | numberColons answer stream first |
    numberColons := self occurrencesOf: $:.
    numberColons < 2 ifTrue: [^Array with: self].
    answer := Array new: numberColons.
    stream := ReadStream on: self.
    first := 1.
    1 to: answer size do: [ :i |
        stream skipTo: $:.
        answer at: i put:
            (stream copyFrom: first to: stream position).
        first := stream position + 1].
    ^answer!   
menuBarHeight
        "Private - Answer the height of the menubar."
    "Need to get the value out of the SystemValueConstants using
    an #at: so that the resulting code is binary portable."
    ^OperatingSystem getSystemValue:
        (SystemValueConstants at: 'SystemValueMenuHeight')!
partPropertyChangeFile: aButtonProperty
        " Private - Change file property button handler "
    | currentFileDescriptor currentPathName newFileDescriptor newPathName
      newFileName containingAppFileName
      aPropertyStructure dir paxType partType resolvedDescriptor|

    currentFileDescriptor := aButtonProperty newValue.
    currentPathName := ( currentFileDescriptor notNil
        ifTrue: [ currentFileDescriptor fullPathName ]
        ifFalse: [ self filePathName ] ).

    paxType := PARTSFileDescriptor fileTypeForExecutablePart.
    partType := PARTSFileDescriptor fileTypeForPart.
    newFileDescriptor := PARTSFileDescriptor
        promptDialog: #open
        initialFile: nil
        fileTypes:
            (OrderedCollection
                with: paxType
                with: partType
                with: PARTSFileDescriptor fileTypeForNone )
        defaultPattern: paxType pattern
        title: 'Change File for: ', self partName.
    newFileDescriptor isNil
        ifTrue: [ ^self ].

    newFileDescriptor fileType trimBlanks isEmpty
        ifTrue: [
            (
    resolvedDescriptor := self resolvedFileDescriptor: newFileDescriptor) isNil
        ifTrue: [
            MessageBox
                notify: 'Unreachable File'
                withText:
                    'Cannot access nested part in ', newPathName,
                    ' (it is not in the PARTS Workbench directory search path).'.
                ^nil ]
        ifFalse: [ dir := resolvedDescriptor directory ]].
    newPathName := newFileDescriptor fullPathName.

    newFileName := newFileDescriptor fileName.

    dir isNil
        ifTrue: [
             [ dir :=
                PARTSFile directoryContaining: newFileName ]
                    on: PARTSNotOnSearchPath
                    do: [ :e |
                        e postMessageBox: 'Part AccessorChange File Error'.
                        ^nil ]].

    ( PARTSFile isPathName: newPathName sameAsDirectory: dir )
        ifFalse: [ ^self ].  " multiple occurrences on search path "

    " don't allow cyclical nesting relationships "
    containingAppFileName := self partEditor appPathName.
    ( containingAppFileName notNil
    and: [ newFileName equalsIgnoreCase: containingAppFileName asString fileNameLessPath ] )
        ifTrue: [
            MessageBox
                notify: 'Cyclical File Reference'
                withText:
                    'Cannot nest ', newPathName, ' in itself.'.
            ^self ].

    aPropertyStructure := aButtonProperty propertyStructure.
    ( aPropertyStructure propertyAt: #fileNameItem )
        label: self partPropertyFileNamePrefix, newPathName.
    aButtonProperty newValue: newFileDescriptor.
    aPropertyStructure partContext
        at: #fileNameChanged put: true.!
computeListInteriorLayout: pen
        " Private - compute the entryRects of the list
        entries within the list pane (points). "
    | paneRect margin numEntries left top width height |
    paneRect := ( 0 @ 0 extent: pen boundingBox extent ). "entryRects relative to boundingBox"
    margin := pen font charSize x.
    numEntries := list size.
    left := paneRect left right: margin.
    top := paneRect top down: margin.
    width := paneRect width - (4 * margin).
    height := numEntries * entryHeight.
    "self ASSERT: (height < paneRect height)."
    listRect :=
        left @ top
        extentFromLeftTop: width @ height.
    entryRects := Array new: numEntries.
    1 to: numEntries do: [ :i |
        entryRects at: i put:
            (left @ top extentFromLeftTop: width @ entryHeight).
        top := top down: entryHeight].! 
isPARTSPasteSession
    "Answer whether the receiver is an instance
    of PARTSPasteSession"

    ^false!
basicDrawMark: loc
    "Private - Draw the insertion mark
    at index position <loc>. "
    "Copied to menu bar"
    | origin pen |

    loc isNil
        ifTrue: [ ^nil ].

    origin := self itemPositionToPoint: loc.

    self doGraphics: [
    pen := self pen.
    pen
        foreColor: Color white;
        setForegroundMode: MixRuleInvertSurface;
        setLineType: LineTypeSolid;
        place: origin;
        goto: (origin x  @ self extent y);
        setForegroundMode: MixRuleDefault ]!   
createBuilderClassNamed: aString
        "Create and answer a class (subclass of PARTSApplicationCoordinator) that can
        build an exact clone of the receiver."
    | cg output class |
    self userPropertyNamed: 'builderClassName' value: aString.
    cg := CodeGenerationPrivateServices codeGenerator new.
    output := CodeGenerationPrivateServices outputToImage new.
    output outputIsTransient: false.
    cg write: self output: output.
    class := output classesOutputted first.
    self userPropertyNamed: 'builderClassName' value: nil.
    ^class
!
insureWithin: aWindow
    "Private - Insure the receiver is within <aWindow>"
    | iconRect xShift yShift containingRectangle |

    iconRect := self visibleFrame.
       "freeClientArea only represents the virtual screen"
    containingRectangle := aWindow entireClientArea.

    xShift :=
        ( iconRect right isRightOf: containingRectangle right )
            ifTrue: [ ( containingRectangle right - iconRect right ) abs ]
            ifFalse: [ 0 ].
    yShift :=
        ( iconRect bottom isBelow: containingRectangle bottom )
            ifTrue: [ ( containingRectangle bottom - iconRect bottom ) abs ]
            ifFalse: [ 0 ].
    origin := origin leftAndUp: ( xShift @ yShift ).

    iconRect := self visibleFrame.
    xShift :=
        ( iconRect left isLeftOf: containingRectangle left )
            ifTrue: [ ( containingRectangle left - iconRect left ) abs ]
            ifFalse: [ 0 ].
    yShift :=
        ( iconRect top isAbove: containingRectangle top )
            ifTrue: [ ( containingRectangle top - iconRect top ) abs ]
            ifFalse: [ 0 ].
    origin := origin rightAndDown: ( xShift @ yShift ).

    ( connection notNil and: [
        connection isPARTSCatalogIconConnection not and: [
        connection partIsWindow not ]])
        ifTrue: [
            connection partWrapper rectangle:
                ( PARTSFramer
                    forRectangle: ( self leftTop extentFromLeftTop: self visibleExtent )
                    in: containingRectangle )]
! 
openOn: aPARTSEditor
        " Edit the link color settings in aPARTSEditor. "
    self openApplicationOn: aPARTSEditor.!   
addClassModelTo: aCodeGenerator
        "Private - code generation - add a class model that describes how the receiver
        can be reconstructed to aCodeGenerator."
    | classModel |
    classModel := self classModelInContext: aCodeGenerator.
    self
        addComponentPoolVariablesTo: classModel;
        addInstantiatePartsMethodModelTo: classModel;
        addBuildApplicationMethodModelTo: classModel;
        addComponentMethodModelsTo: classModel;
        addScriptRepresentationsTo: classModel;
        addFileNameMethodTo: classModel
!
openWorkbenchOnPathName: aPathName
        "If aFileName is a catalog, open a catalog notebook
         on it; if it is a part, open a workbench on it; if it is nil or
         an empty string, open a new (empty) workbench"

    | extension |
    ( aPathName isNil or: [ aPathName isEmpty ] )
        ifTrue: [ ^PARTSEditor open ].
    ( PARTSFile exists: aPathName )
        ifFalse: [
            PARTSFileNotFound signalForFile: aPathName.
            ^PARTSEditor open ].
    extension := aPathName fileExtension.
    ( extension equalsIgnoreCase: 'PAR' )
        ifTrue: [ ^PARTSEditor openOnPathName: aPathName ].
    ( extension equalsIgnoreCase: 'CAT' )
        ifTrue: [ ^PARTSCatalog openOnPathName: aPathName ].
    " unknown file type, don't know what's supposed to be in this file "
    MessageBox warning: 'Unknown file type - ', aPathName, '.'.
    PARTSEditor open.! 
createView
        " Private - compute layout and create child panes.
        Window sizing is done in dialog box units. "

    | charWidthDlg lineHeightDlg marginDlg listExtentDlg topPane deltaLeftMarginX deltaLeftTop internalWidthDlg aLabel anExtent anExtendedListBox |

    charWidthDlg := WindowDialog charWidth.
    lineHeightDlg := WindowDialog charHeight.
    marginDlg := charWidthDlg.

    " compute extent info for the variable-size lists "
    listExtentDlg := self computeListExtent.

    self addView:
        (topPane := self topPaneClass new
            owner: self;
            labelWithoutPrefix: self title;
            style: self defaultFrameStyle ).
    deltaLeftMarginX := marginDlg.
    deltaLeftTop := deltaLeftMarginX @ marginDlg.
    internalWidthDlg := self titleBarWidth: self title.

    " list pane "
    aLabel := self listDescription.
    anExtent := self extentForLabel: aLabel.
    topPane addSubpane:
        (StaticText new
            font: self font;
            contents: aLabel;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: anExtent)).
    internalWidthDlg := internalWidthDlg max: anExtent x.
    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + anExtent y + (marginDlg//2)).
    topPane addSubpane:
        (( anExtendedListBox := self newSequencePane )
            contents: list;
            framingBlock:
                (self framingBlock: deltaLeftTop
                    extent: listExtentDlg)).
    internalWidthDlg := internalWidthDlg max: listExtentDlg x.
    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + listExtentDlg y + marginDlg).

    " OK and Cancel buttons "
    anExtent := self
        createOkCancelButtons: topPane
        deltaLeftTop: deltaLeftTop.
    internalWidthDlg := internalWidthDlg max: anExtent x.

    clientExtentDlg :=
        (internalWidthDlg + (2 * marginDlg))
        @ (deltaLeftTop y + anExtent y + marginDlg).! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    self do: [ :e | anExpressionModel addSelector: #add: with: e ].
    anExpressionModel addSelector: #yourself! 
isPARTSTransientPart
        "Answer whether the receiver is a part which exists
        only while its containing application is being edited
        in a PARTS Workbench. "

    ^true!   
move: menuLabel toIndex: index
    "Private - Move <menuLabel> from its
    current position to <index>."
    "Copied to menu bar"
    | srcIndex anchorLabel  components wrapper |

    index < 1 ifTrue: [^self].
    components := self partWrapper components.
    wrapper := self partWrapper findWrapper: menuLabel.
    srcIndex := components indexOf: wrapper.
    (srcIndex = index or: [srcIndex = (index - 1)]) ifTrue: [^self].
    index > srcIndex
        ifTrue: [            "move right"
            srcIndex = 1
                ifTrue: [anchorLabel := nil]
                ifFalse: [anchorLabel := (components at: srcIndex - 1) object].
            self moveFrom: srcIndex + 1 to: index - 1 after: anchorLabel.
            self position: menuLabel after: (components at: index - 1) object.
            components replaceFrom: srcIndex
                to: index - 2
                with: components
                startingAt: srcIndex + 1.
            components at: index - 1 put: wrapper]
        ifFalse: [            "move left"
            index = 1
                ifTrue: [anchorLabel := nil]
                ifFalse: [anchorLabel := (components at: index - 1) object].
            self position: menuLabel after: anchorLabel.
            self moveFrom: index to: srcIndex - 1 after: menuLabel.
            components replaceFrom: index + 1
                to: srcIndex
                with: components
                startingAt: index.
            components at: index put: wrapper]!
compileExpression: aString
        "Private - compile the text in the receiver's entry field
        and answer whether the compilation was successful."
    object := CompilerInterface
        evaluate: aString
        in: UndefinedObject
        to: nil
        notifying: self
        ifFail: [ ^false ].

    ( object isSmallInteger
         or: [ object isBoolean
         or: [ object isNil ]])
             ifTrue: [
                MessageBox notify: 'Error' withText: 'Illegal instance'.
                object := nil ].
    ^true!   
directorySelected: dir
    " Private - the directory <dir> has been selected. "

    selectedDirectory := dir.
    application updateFiles.!  
scrollToOrigin
        "Scroll the receiver back to the origin and update the scrolling ranges."

    self scrollTopCornerTo: 0 @ 0.
    self setScrollRanges.
    self updateSliders.
!
addAddExternalEventsMethodTo: aClassModel selector: aSelector
        "Private - code generation - add a method model to aClassModel
        that will add the external events to a rebuilt version of the receiver."
    | methodModel expression |
    methodModel := aClassModel newClassMethodNamed: aSelector.
    methodModel argumentModels: self applicationArgumentModels.
    methodModel comment: 'Private - add  external events to anApplication'.
    expression := methodModel newMessageExpression receiverObject: self.
    externalEvents do: [ :externalEvent |
        expression addSelector: #addExternalEvent: with: externalEvent ]! 
closeWindow
        "The user finished creating a new object; close the window."
    self triggerEvent: #closeWindow!   
initializeParts
        " Private - initialize the parts in an application
        which has just been loaded. "
    ( self partNamed: 'SearchPath' ) printSelector: #relativeDisplayName.
    PARTSWorkbenchSessionManager isRepositoryComponentInstalled
        ifTrue: [
            ( self partNamed: 'UserName') hideWindow.
            ( self partNamed: 'TeamVName') showWindow ]
        ifFalse: [
            ( self partNamed: 'UserName') showWindow.
            ( self partNamed: 'TeamVName') hideWindow ].
    " In OS/2, mouse settings will be set from the mouse system setup.  So,
      hide the mouse settings button in the receiver. "
    self partsIfOS2Do: [
        (self application componentNamed: 'ButtonMouseButtons' ) hideWindow ]!
position: aMenuLabel after: anchorLabel
    "Private - Position aMenuLabel after another menu label, anchorLabel. "
    "Copied to menu bar"
    | rect oldRect newRect partEditorPane |

    oldRect := aMenuLabel frameRectangle mapToWindow: (
        partEditorPane := self partEditorPane ).
    aMenuLabel
        resizeToRectangle: ( rect :=
            self getPosition: aMenuLabel after: anchorLabel ).
    aMenuLabel sizeChanged: rect extent.
    newRect := aMenuLabel frameRectangle  mapToWindow: partEditorPane.

    self partContainingNestedPart isNil
        ifTrue: [ "Not in a nested part (links visible)"
            self partEditor linkEditor
                refreshAfterMoveOf: ( Array with: aMenuLabel )
                from: ( Array with: oldRect )
                to: ( Array with: newRect )].!  
spacing
    "Answer the spacing between menu labels"
    "Copied to menu bar"

    ^SysFont width * 2!
removeWorkbenchData
        " Private - clean up workbench data in the environment. "

    PARTSApplicationHolder emptyRecyclingBin.
    PARTSStarterWindow currentClass removeStarter.

    PARTSEditor editorClass toolBarPictures do: [ :aBitmap |
        aBitmap release ].
    PARTSEditor editorClass workbenchIcon release.!  
addComponent: anObject named: nameString parent: parentObject
        " Private - add <anObject> to the application's
        componentDictionary with the name <nameString>.
        The part name must already have been validated. "
    self wrap: anObject parentObject: parentObject.
    anObject partWrapper name: nameString.
    componentDictionary at: nameString put: anObject.
    ^anObject!
fileName
        " Private - answer the file containing the PARTS
        window definition. "
    ^'Settings.par'!
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        receiverObject: x;
        addSelector: #@ with: y.
    ^answer! 
displayHelpContext: contextString fromFile: aHelpFile
    "Private - Bring up the Windows Help for the topic
      identified by contextString.  Answer true if it fails, false otherwise."

    | fileName |
    self partsVwOnly.  " Only used on VW"
    fileName := aHelpFile fileNameLessPath.
    self
        winHelp: HelpIdIndex
        helpFile: aHelpFile
        data: nil.
    ^(self
        winHelp: HelpIdCommand
        helpFile: aHelpFile
        data: ( 'JumpID(', '"', fileName,'"', ',' ,'"',contextString, '"', ')' ) ) not  .!   
promptDialog: anOperation initialFile: aFileDescriptor fileTypes: fileTypes defaultPattern: defaultPattern title: aTitle
    "Private- Open the desired choose dialog."

    ^( PARTSChooseFileDialog chooseFileDialogClass: anOperation ) new
        promptDialog: anOperation
        initialFile: aFileDescriptor
        fileTypes: fileTypes
        defaultPattern: defaultPattern
        title: aTitle!  
fullHelpPathName: aFileName
        "Answer a String which is the full path name for
        aFileName residing in the standard help directory."

    ^self helpDirectoryName , '\', aFileName!   
partDragTargetEnter: aDragDropSession
        "Private - aDragSession has just entered the receiver.
    Draw the target emphasis and set the target operation. "

    "Below is from dragTargetEnter:"
    aDragDropSession target: self.

    self propertyAt: #partHasTargetEmphasis put: true.

    self partDragTargetDrawEmphasis: aDragDropSession.
    self partDragTargetAccept: aDragDropSession! 
findOrOpenOn: aPARTSEditor
        " Open a PARTS settings secondary editor. "
    | aSettingsWindow |
    aSettingsWindow := Notifier windows
        detect: [ :w |
            w isApplicationWindow
            and: [ w owner isPARTSApplication
            and: [ w owner partIsEditing not
            and: [ w owner name = self applicationName ] ] ] ]
        ifNone: [ nil ].
    aSettingsWindow notNil
        ifTrue: [
            aSettingsWindow bringToTop.
            ^self ].
    self new openOn: aPARTSEditor! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    | descriptionString orderedChildren |

    aStream
        nextPutAll: aString;
        nextPutAll: 'Title:  ';
        nextPutAll: self title printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Version:  ';
        nextPutAll: self version printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Hint:  ';
        nextPutAll: self partHint printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Development help file:  ';
        nextPutAll: self helpFile printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Development help topic:  ';
        nextPutAll: self helpTopic printString;
        cr;
        nextPutAll: aString;
        nextPutAll: 'Part file reuse option:  ';
        nextPutAll: self reuseMode printString;
        cr.


    descriptionString := self description.
    descriptionString isNil
        ifTrue: [ descriptionString := '<none>' ].
    aStream
        nextPutAll: aString;
        nextPutAll: 'Description:  ';
        nextPutAll: descriptionString;
        cr.

   ( orderedChildren := self orderedChildren ) size > 0
        ifTrue: [
            aStream
                nextPutAll: aString, 'Tab Order:   * indicates a tab stop';
                cr.
            orderedChildren do: [ :child |
                child isAGroupLeader
                    ifTrue: [
                        aStream tab; nextPutAll: aString, 'Group Start' ;cr ].
                    aStream tab; tab; nextPutAll: aString.
                    child isATabStop
                    ifTrue: [
                        aStream nextPutAll: '* ' ].
                    aStream nextPutAll: child partWrapper name; cr.
                ] ].!
partDragTransferProperties: newPart
    "Private - Transfer properties from the receiver to <newPart>
    during a replace operation on the receiver by <newPart>."

    newPart
        backColor: self backColor.! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelector: #scaleUnit: with: scaleUnit.

        "vertical"

    self isTopInset
        ifTrue: [
            self isBottomInset
                ifTrue: [
                    anExpressionModel
                        addSelector: #top:stretched:bottom:stretched:
                            with: top with: self isTopStretched with: bottom with: self isBottomStretched ]
                ifFalse: [
                    anExpressionModel
                        addSelector: #top:stretched:height:stretched:
                            with: top with: self isTopStretched with: bottom with: self isBottomStretched ]]
        ifFalse: [
            self isBottomInset
                ifTrue: [
                    anExpressionModel
                        addSelector: #bottom:stretched:height:stretched:
                            with: bottom with: self isBottomStretched with: top with: self isTopStretched ]
                ifFalse: [  "centered vertically"
                    anExpressionModel
                        addSelector: #center:stretched:height:stretched:
                            with: top with: self isTopStretched with: bottom with: self isBottomStretched ]].

        "horizontal"

    self isLeftInset
        ifTrue: [
            self isRightInset
                ifTrue: [
                    anExpressionModel
                        addSelector: #left:stretched:right:stretched:
                            with: left with: self isLeftStretched with: right with: self isRightStretched ]
                ifFalse: [
                    anExpressionModel
                        addSelector: #left:stretched:width:stretched:
                            with: left with: self isLeftStretched with: right with: self isRightStretched ]]
        ifFalse: [
            self isRightInset
                ifTrue: [
                    anExpressionModel
                        addSelector: #right:stretched:width:stretched:
                            with: right with: self isRightStretched with: left with: self isLeftStretched ]
                ifFalse: [
                    anExpressionModel
                        addSelector: #center:stretched:width:stretched:
                            with: left with: self isLeftStretched with: right with: self isRightStretched ]]!  
initializeWorkbenchPlatformEvents
        " Private - register host events which are needed
        by the PARTS workbench component. "

    | hostEventsList |

    hostEventsList := Smalltalk at: #OperatingSystemEvents.

    self
        partsIfOS2Do: [

           "hit test for GroupBox"
            PARTSHostInterface
                registerHostEvent:  WmHitTest  
                in: hostEventsList
                selector: #wmHittest:with: .

            "events for capturing mouse inside workbench"
            PARTSHostInterface
                redefineHostEvent: WmButton1Down
                in: hostEventsList
                selector: #wmVButton1down:with: .
            PARTSHostInterface
                redefineHostEvent: WmButton2Down
                in: hostEventsList
                selector: #wmVButton2down:with: .
            PARTSHostInterface
                redefineHostEvent: WmMouseMove
                in: hostEventsList
                selector: #wmVMouseMove:with: .
            ]

        partsIfWindowsDo: [

            " non-client area hit test for the workbench "
            PARTSHostInterface
                registerHostEvent: WmNcHitTest
                in: hostEventsList
                selector: #wmNchittest:with: .
            PARTSHostInterface
                registerHostEvent: WmNcLButtonDown
                in: hostEventsList
                selector: #wmNclbuttondown:with: .

            "events for capturing mouse inside workbench"
            PARTSHostInterface
                redefineHostEvent: WmButton1Down
                in: hostEventsList
                selector: #wmVLbuttondown:with: .
           PARTSHostInterface
                redefineHostEvent: WmButton2Down
                in: hostEventsList
                selector: #wmVRbuttondown:with: .
            PARTSHostInterface
                redefineHostEvent: WmMouseMove
                in: hostEventsList
                selector: #wmVMousemove:with: .

            "Activate workbench from TaskManager"
            PARTSHostInterface
                registerHostEvent:  WmActivateApp
                in: hostEventsList
                selector: #wmActivateapp:with: .
        ].!
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer  |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        receiverObject: self class;
        addSelector: #red:green:blue:
            with: self red
            with: self green
            with: self blue.
    ^answer!  
canTriggerEvent: eventName
    "Answer <true> if the receiver can trigger an event
     named <eventName>. "

    ^self partEvents items includes: eventName asSymbol!
asByteFileStreamCopy
    "Private - do nothing, answer self."!   
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    super codeGenerationAddAttributeMessagesTo:  anExpressionModel.
    self codeGenerationAddFramingBlockMessagesTo: anExpressionModel.
    ( self canTab and: [ self isATabStop not ] )
        ifTrue: [ anExpressionModel addSelector: #noTabStop ].
    self isAGroupLeader
        ifTrue: [ anExpressionModel addSelector: #startGroup ].
    self hasBorderStyle
        ifFalse: [ anExpressionModel addSelector: #removeBorderStyle ].
    self codeGenerationAddScrollBarMessagesTo: anExpressionModel!
entryHeight
        " Private - answer the height (points)
        of an entry in the list pane. "
    
    entryHeight isNil
        ifTrue: [ entryHeight := self font height ].
    ^entryHeight!
extendedStyleDictionary
        "Private - answer the extendedStyleDictionary.
        This was the ExtendedStyleDictionary class var
        in 2.0 TablePane.  We don't want a class var
        hanging around and taking up space, so we
        store it in a temporary instance var."

    ^pwo20ExtendedStyleDictionary!
addBuildEditStateMethodsTo: aClassModel
        "Private - code generation - add a method model to aClassModel
        that will rebuild edit information of the receiver."
    | methodModel submethod expression |
    methodModel := aClassModel newClassMethodNamed: #attachEditInformationIn:.
    methodModel argumentModels: self applicationArgumentModels.
    methodModel comment: 'Private - attach editing information to anApplication.'.
    expression := methodModel newMessageExpression setReceiverToSuper.
        "invoking super causes LinkMessages to be converted to PARTSLinks."
    expression addSelector: #attachEditInformationIn: with: self.

    expression := methodModel newMessageExpression.
    expression receiverObject: self.
    self addApplicationAttributeMessagesTo: expression.
    ( expression addSelector: #icon: ) newExpressionArgument
        setReceiverToSelf;
        addSelector: #applicationIcon.
    submethod := aClassModel newClassMethodNamed: #applicationIcon.
    submethod comment: 'Private - answer the application icon.'.
    expression := submethod newMessageExpression.
    expression receiverObject: self icon.

    methodModel newMessageExpression
        setReceiverToSelf;
        addSelector: #addLinkEditStateTo: with: self.
    submethod := aClassModel newClassMethodNamed: #addLinkEditStateTo:.
    submethod argumentModels: self applicationArgumentModels.
    submethod comment: 'Private - add link edit state to all the links in anApplication.'.
    expression := submethod newMessageExpression.
    expression receiverObject: self.
    wrapper addLinkEditStateMessagesTo: expression.

    methodModel newMessageExpression
            receiverObject: self;
            addSelectorIfNotNil: #scenarioEditor: with: self scenarioEditor.

    self components do: [ :component |
        component codeGenerationAddEditExpressionTo: methodModel ]
!  
scrollTopCorner: aPoint
        "Private - Move the contents of the receiver by extent aPoint."
    self scrollTopCorner: aPoint continuous: false! 
partDragTransferProperties: newPart
    "Private - Transfer properties from the receiver to <newPart>
    during a replace operation on the receiver by <newPart>."

    newPart
        font: self font;
        foreColor: self foreColor;
        backColor: self backColor.!   
writeNewFile: aPathName
    name: aNameString
    solePart: anObject
    icon: anIcon
    partIcon: partIcon
    hint: aHintString
    helpFile: aHelpFileName
    helpTopic: aHelpTopicName
    nestingMode: nestingMode
        " Write the file aPathName with a new application
        containing the single part anObject.  "

    self
        writeNewFile: aPathName
        name: aNameString
        solePart: anObject
        icon: anIcon
        partIcon: partIcon
        hint: aHintString
        helpFile: aHelpFileName
        helpTopic: aHelpTopicName
        nestingMode: nestingMode
        libraryMappings: nil!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    self isLinked
        ifTrue: [
            anExpressionModel
                addSelectorIfNotNil: #fileDescriptor: with: self fileDescriptor ]
        ifFalse: [
            anExpressionModel
                addSelectorIfNotNil: #application: with: self application;
                addSelectorIfNotNil: #fileDescriptor: with: self fileDescriptor ].
    anExpressionModel
        addSelectorIfNotNil: #copyMode: with: copyMode;
        addSelectorIfNotNil: #showInternals: with: showInternals! 
buildLocalDragObject
        "Build a DragItem representing the receiver.  Cache it in the
        receiver's connection."
    | dragItem |

    dragItem := PARTSAddPartObject new.
    dragItem icon: self.
    connection isPARTSCatalogIconConnection
        ifTrue: [
            connection dragItem: dragItem ].

    ^dragItem!   
freeClientArea: aRectangle
    "Private - Answer the remaining visible area
    after the receiver's rectangle is removed from
    the parent's free client area <aRectangle>."

    ^self isHandleOk
        ifTrue: [
            Rectangle
                leftTop: aRectangle left @ ( aRectangle top down: (self height + 1) )
                rightBottom: aRectangle rightBottom ]
        ifFalse: [
            rectangle notNil
                ifTrue: [ rectangle ]
                ifFalse: [ aRectangle ]].
! 
initializeEventHandlersForOpen
    "Private - Initialize the events specific to #open"

    application
        when: #ok
            send: #okOpen to: self!
transferExtStyles
        "Private - transfer the extStyles data."

	newTablePanePart propertyAdjustRowHeights:
		( self hasExtStyle: #adjustRowHeights ).
	newTablePanePart propertyAdjustColumnWidths:
    	( self hasExtStyle: #adjustColumnWidths ).

	newTablePanePart propertyEditRowLabels:
		( self hasExtStyle: #editRowLabels ).
	newTablePanePart propertyEditColumnLabels:
    	( self hasExtStyle: #editColumnLabels ).

"    ( self hasExtStyle: #editCornerLabel ) ifTrue: [
		newTablePanePart  ]."

	newTablePanePart propertyDisplayRowLabels:
		( self hasExtStyle: #displayRowLabels ).
	newTablePanePart propertyDisplayColumnLabels:
    	( self hasExtStyle: #displayColumnLabels ).

	newTablePanePart propertyHorizontalScrollBar:
    	( self hasExtStyle: #horzScroll ).
	newTablePanePart propertyVerticalScrollBar:
    	( self hasExtStyle: #vertScroll ).

	newTablePanePart propertyIndexedRows:
    	( self hasExtStyle: #indexedRows ).
	newTablePanePart propertyIndexedColumns:
    	( self hasExtStyle: #indexedColumns ).! 
showLinksWithSelection: aBoolean
    newSettings showLinksWithSelection: aBoolean.!  
directoryList
    " Private - answer the file dialog directory list in the form
    of PARTSDirectories "

    ^PARTSFile currentSearchPath!  
sequencePaneName
    "Private"

    ^'sequencePane'!   
partHasObjectMessages
        " Answer whether the receiver can be asked
        for messages it has inherited from Object
        other than what it has already provided
        in its partMessages. "
    ^true! 
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."

    ^true! 
builderClassName
        "Private - Code Generation - answer a name to be used for the class that
        builds the receiver."
    | answer |
    answer := self userPropertyNamed: 'builderClassName'.
    ^( answer isNil
        ifTrue: [ self name ]
        ifFalse: [ answer ] ) asSymbol! 
virtualScreenExtent
    "Private - Answer the default virtual screen extent
    to be used to display the receiver on the workbench"

    ^Display extent!
partEditDirect
        "Edit the directly visible part properties of the receiver."
    self editLabel! 
getPosition: menuLabel after: anchorLabel
    "Private - Answer the new framing rectangle of
    <menuLabel>.  The rectangle should be positioned
    after the framing rectangle of the <anchorLabel>"
    "Copied to menu bar"
    | leftTop |

    leftTop := ( anchorLabel isNil
        ifTrue: [ "First position origin (rectangle is not relative to receiver)"
            self partsIfOS2Do: [ 0 @ self rectangle height down: 2 ]
            partsIfWindowsDo: [ 0 @ 2 ]]
        ifFalse: [
            anchorLabel frameRelativeRectangle rightTop ]).

    ^( leftTop rightAndDown: ( self spacing @ 0))
        extentFromLeftTop: menuLabel partSize!  
newTablePane
        "Private - answer the new table pane. "

    ^newTablePanePart!   
wmErasebkgnd: wordInteger with: longInteger
    "Private - Process the erase background message."

    ^1! 
fileName
        " Private - Answer the name of the part file
        containing the dialog window. "

    ^'PTSFLDLG.par'!   
isOkToDisable: aWindow
        " Private - answer whether aWindow should really be disabled. "

    | windowOwner w |
    aWindow isNil
        ifTrue: [ ^true ].
    w := self
        partsIfOS2Do: [ Window isFrameWindow
            ifTrue: [ aWindow child ]
            ifFalse: [ aWindow ] ]
        partsIfWindowsDo: [ aWindow ].
    windowOwner := w owner.
    ( ( windowOwner isPARTSEditor   " don't disable editor when testing!! "
            or: [ windowOwner isPARTSCatalog ] )  " or dragging from catalog "
    and: [ self allowWorkbenchToBeDisabled not ] )
        ifTrue: [ ^false ].
    windowOwner class == PARTSEditor editorClass debuggerClass
        ifTrue: [ ^false ].
    ^true!   
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        receiverObject: leftTop;
        addSelector: #rightBottom: with: rightBottom.
    ^answer!  
inverseButtonSelected
        "Private - The inverse button has been selected. "
    mode := #inverse.
    self setColorBoxes! 
wmNclbuttondown: wparam with: lparam
    self partsVwOnly.  " only used on Win32 "
    ^nil!
addHorzScrollBar
        "Private - add the horizontal scroll bar when the scroll range is greater than zero."
    | frameStyle |
    self partsVosOnly.
    frameStyle := self addHorizontalScrollbarStyle.
    self partPropertySetStyle: frameStyle
!
partDragTargetReplace: aReplaceSession in: aParent
     "Private - aDragSession has just been dropped on the receiver.
    Delete the receiver, add the drag object in its place and
    transfer the links from the receiver to the drag object.
    Answer the added part."
    | index oc addedPart |

    index := aParent orderedChildren indexOf: self.
    addedPart := super partDragTargetReplace: aReplaceSession in: aParent.
    index > 0
        ifTrue: [
            oc := aParent orderedChildren. "Note: oc may be different instance than before"
            oc remove: addedPart ifAbsent: [ nil ].
            oc add: addedPart beforeIndex: index ].
    ^addedPart!
addDirectory
        " Add a directory to the top of the PARTS search path. "

    | aDirectory newPathName |

    aDirectory := PARTSFileDescriptor promptForDirectory.
    aDirectory isNil
        ifTrue: [ ^self ].  " cancelled "

    " validate the directory "
    newPathName := aDirectory absolutePathString.
    aDirectory valid
        ifFalse: [
            MessageBox
                notify: 'Invalid Directory'
                withText: 'Directory ', newPathName, ' does not exist.'.
            ^self ].
    newPathName := aDirectory relativeDisplayName.

    ( searchPath detect: [ :dir |
            dir = aDirectory ]
            ifNone: [ nil ] ) notNil
        ifTrue: [
            MessageBox
                notify: 'Duplicate Directory'
                withText: 'Directory ', newPathName, ' is already in the search path.'.
            ^self ].

    " add to beginning of search path "
    searchPath := ( Array with: aDirectory ), searchPath.
    searchPathChanged := true.
    self
        triggerEvent: #searchPathChanged: with: searchPath;
        triggerEvent: #selectDirectory: with: aDirectory.
    searchPath size = 1
        ifTrue: [ self triggerEvent: #enableDirectoryButtons ].! 
sequencePane
    "Private - Answer the pane with reorderable items"

    ^self paneAt: self sequencePaneName.! 
promptForCatalog
    "Private"

    ^self promptDialog: #open
        initialFile: nil
        fileTypes: self catalogFileTypes
        defaultPattern: '*.cat'
        title: 'Open Catalog'! 
defaultFrameStyle
        "Private - Answer the default frame style for the receiver."
    ^FrameStyle! 
sequencePaneFont
    ^self font! 
partFileInUpgradeLoaded: anObjectFiler
        " Private - finish upgrading a visual part from PARTS Workbench 2.0. "

    | orderedChildrenList |

    self
        partsIfOS2Do: [ self partFileInUpgradeLoadedOS2: anObjectFiler ]
        partsIfWindowsDo: [ self partFileInUpgradeLoadedWindows: anObjectFiler ].

    " deallocate unused data which gets recreated on demand in 3.0 "
    children size = 0
        ifTrue: [ children := nil ].
    orderedChildrenList := self propertyAt: #orderedChildren.
    ( orderedChildrenList isCollection and: [ orderedChildrenList isEmpty ] )
         ifTrue: [ self propertyAt: #orderedChildren put: nil ].!  
workbenchSessionShutdown
        " Private - perform the session #shutdown processing
        for the PARTS workbench component. "

    PARTSStarterWindow currentClass shutdown.
    PARTSEditor activeEditorWindows do: [ :editorTopPane |
        [ editorTopPane owner cancelCloseAllowed: false.
          editorTopPane close ]
        ensure: [ editorTopPane owner cancelCloseAllowed: true ]].! 
applicationName
        " Answer the name of the PARTS application which owns
        the background color settings editor window. "
    ^'PARTSBackgroundColorSettings'!  
operation: anOperation title: aTitle
    "Private - Answer an instance of the receiver that responds to
        <anOperation> with the title <aTitle>."
        "Implemented by subclass"! 
partDragTargetNeedsOperations: dragSession
        "Private - set the names of supported operations in the dragSession."

    "Below is from dragTargetNeedsOperations:"
    self dragTargetStopScrollTimer.
    dragSession targetEraseEmphasis.
    self dragTargetNeedsOperationsDefault: dragSession.!  
reinitializeEventHandlers
    " Private -
        Reinitialize the event handlers.  Since this class is used for both
        open and save, don't implement initializeEventHandlers, since this
        only initializes once.  Need to initialize the events everytime the
        application is opened because the correct event must be registered
        according to the current operation.  This method will be executed
        everytime the application     is opened."

    super initializeEventHandlers.
    ( operation = #open or: [ operation = #openLatest ])
        ifTrue: [ self initializeEventHandlersForOpen ]
        ifFalse: [ self initializeEventHandlersForSave ].!   
initializePartValues
    " Private - the dialog window application is about to be
    opened.  Initialize the items in the dialog based on the
    current values of the part. "
    | defaultDir directories |

    "Set the method that the directory list box will use to
        display its directory objects."
    ( self partNamed: 'Directories' ) printSelector: #displayName.

    pattern := defaultType pattern.
    directories := self directoryList asOrderedCollection.
    defaultDir :=
        self class defaultDirectoryFor:
            ( startFile isNil    "File last saved."
                ifTrue: [ nil ]
                ifFalse: [ startFile directory ] )
        in: directories.

    application
        setLabel: title;
        setDirectoryName: nil;  "Clear cached value from previous opening"
        setDirectoryList: directories;
        setFileTypes:
            (( fileTypes reject: [ :each | each type isEmpty ]) "Part Accessor allows empty type"
                collect: [ :each | each description ] );
        selectFile: nil;
        setDirectoryName: defaultDir;
        setFileName: self defaultFileName;
        selectFileType: defaultType description;
        updateFiles.   "since the recycled app may not trigger changed:"! 
partUndoDirectEdit: originalValue
        "Undo a direct edit operation on the receiver.
        For most, the direct edit value is simply its contents.
        This method should be reimplemented by subclasses whose
        direct edit is special (eg. Notebook, ValueSet, etc..)."
    self partSetDirectEditValue: originalValue.!   
initialize
        " Private - class initialization. "

    self partsIfWindowsDo: [ self currentClass: self ].!   
partDragTargetMove: aMoveSession
    "Private"
    | sourceEditor originalParent components
      dragObjects sourceEditorPane workbenchPane |

    sourceEditor := aMoveSession source partEditor.
    sourceEditorPane := sourceEditor workbenchPane.

    ( sourceEditor ~~ self partEditor
            and: [  ( aMoveSession operation = #copy ) not ])
        ifTrue: [
            ^MessageBox warning: 'Can''t move to a different workbench.'].

    dragObjects := aMoveSession objects.
    components := dragObjects collect: [ :each | each visibleObject ].

    aMoveSession operation = #copy
        ifTrue: [ "Drag duplicate"
            sourceEditor
                duplicate: components
                offset: dragObjects first dragRect origin
                    - components first frameRectangle origin
                parent: self.
            ^self].

    ( originalParent := dragObjects first visibleParent ) = self
        ifTrue: [ "Move within same window"
            self isPARTSOrderedGroupPane
                ifTrue: [
                    dragObjects do: [ :aDragObject |
                        aDragObject visibleObject superWindow
                            move: aDragObject visibleObject
                            to: aMoveSession targetLocation ]]
                ifFalse: [
                    dragObjects do: [ :aDragObject |
                        sourceEditorPane hideSelection: aDragObject visibleObject.
                        sourceEditor
                            move: aDragObject visibleObject
                            to: ( aDragObject dragRect mapToWindow: self )]]
            ]
        ifFalse: [ "Changing parents"
            sourceEditor
                changeParentOf: components
                from: originalParent
                to: self
                in: ( dragObjects collect: [ :each | each dragRect ]).
            workbenchPane := self partEditor workbenchPane.
            components do: [ :aComponent |
                self
                    partDroppedPart: aComponent
                    hotSpot:
                        ( aMoveSession targetLocation
                            mapFromWindow: self to: workbenchPane )
                    origin:
                        ( dragObjects first targetLocation
                            mapFromWindow: self to: workbenchPane )].
            originalParent isPARTSOrderedGroupPane
                ifTrue: [ originalParent updatePositions ].
            sourceEditor selectFixMenus.    "e.g. changing parents can make shrink invalid"
            ].

    sourceEditor
        movedComponents: components
        oldParent: originalParent
        oldRects: ( dragObjects collect: [ :each | each startRect ])
        target: self!  
applicationName
        " Answer the name of the PARTS application which owns
        the link color settings editor window. "
    ^'PARTSLinkColorSettings'!  
partPropertyEditIcon
        " Private "
    ^PARTSPropertyIcon new
        value: self partIcon!  
addBuildTopLevelVisualPartsMethodTo: aClassModel selector: aSelector
        "Private - code generation - add a method model to aClassModel
        that will rebuild the top level visual parts of the receiver."
    | methodModel expression visualParts |
    visualParts := self topLevelVisualParts.
    methodModel := aClassModel newClassMethodNamed: aSelector.
    methodModel argumentModels: self applicationArgumentModels.
    methodModel comment: 'Private - add  the top level visual parts to anApplication'.
    expression := methodModel newMessageExpression setReceiverToSelf.
    visualParts do: [ :part |
        expression addSelector: ( self selectorForComponentBuild: part ) with: self ]! 
partEditContents: currentContents properties: aPropertyStructure
        " Private - edit the part contents "

    self partEditDirect:
        ( aPropertyStructure  propertyAt: #changeFile ) newValue.

        "so no undo/redo will be recorded"
    ^PARTSException new! 
editBackgroundColors
        " Edit the PARTS background colors. "
    PARTSBackgroundColorSettingsEditor findOrOpenOn: settings.!  
handlesOperation: anOperation
    "Private - Answer whether the receiver handles <anOperation>"
    | revisionDialog |

    "TeamV revision support handled in another class."
    (( revisionDialog := ( Smalltalk at: #PARTSRevisionDialog ifAbsent: [ nil ] )) notNil
        and: [
    ( revisionDialog chooseFileDialogClass: anOperation ) notNil ])
        ifTrue: [ ^false ].
    ^ #(#open #save #openLatest) includes: anOperation!  
resizeChild: aRectangle
        "Resize the receiver's child  to aRectangle, whose coordinates
         are relative to myself."
    | rect |
    rect := aRectangle.
    self
        partsIfOS2Do: [
            child frameWindow handle
                setWindowPos: nil
                rectangle: rect
                fs:  35 "SwpNoredraw | SwpSize | SwpMove".
            child rectangleAttribute: aRectangle ]
        partsIfWindowsDo: [
            child handle setWindowPos: nil
                rectangle: rect
                fs: 12 "SwpNozorder | SwpNoredraw".
            child rectangleAttribute: aRectangle.
            child sizeChanged: aRectangle extent ].



!
isValidSelector: aSymbol
        " Answer whether <aSymbol> is a syntactically
        legal message selector. "

    | binarySelectors aCompiler |
   binarySelectors := #(
         #= #~= #== #~~ #> #>= #< #<=   " comparison operations "
        #+ #- #*  #/ #\\  #//                    " arithmetic operations "
       #& #|                                 " logical operations "
       #@ #,                                " miscellaneous "
        ).
    ( aSymbol size <= 2
    and: [ binarySelectors includes: aSymbol ] )
        ifTrue: [ ^true ].
    aCompiler := CompilerInterface new.
    aSymbol do: [ :c |
        ( c = $: or: [ aCompiler validInIdentifierBody: c ] )
            ifFalse: [ ^false ] ].
    ( aSymbol includes: $: )
        ifTrue: [
            ( aSymbol first ~= $: and: [ aSymbol last = $: ] )
                ifFalse: [ ^false ] ].
    ^true!  
partDragTargetImport: anAddPartSession
        "Private - aDragSession has just been dropped on the receiver.
    <aDragDropSession> is from a local image.  Answer the part
    that was placed in the receiver (the copy)."
    | partEditor workbenchPane icon targetRect objectTargetPoint part hotSpot addedPartWrapper |

    ( partEditor := self partEditor ) isNil
        ifTrue: [ ^self ].  "Timing allowed attempted drop in catalog"

    workbenchPane := partEditor workbenchPane.

    hotSpot := ( anAddPartSession targetLocation mapFromWindow: self to: workbenchPane ).

    anAddPartSession objects do: [ :object |
        icon := object icon.
        objectTargetPoint := ( object targetLocation mapFromWindow: self to: workbenchPane ).
        targetRect := objectTargetPoint extent: icon extent.
        part := icon connection.
        anAddPartSession canMirrorCopy
            ifTrue: [
                part := part partMirrorCopy: PARTSMirrorCopyDictionary new ].
        addedPartWrapper := partEditor
            iconDragged: icon
            destRect: targetRect
            in: self
            object: part.
        self
            partDroppedPart: part
            hotSpot: hotSpot
            origin: objectTargetPoint ].

        ^ addedPartWrapper! 
PARTSWorkbenchSessionManager removeWorkbenchComponent!
totalLength
        "Private - answer total height for the reciever."
   child notNil
        ifTrue: [ ^child totalLength ]
         ifFalse: [  ^0 ]!   
partPropertyDirectEditValueIsValid: aPropertyString
        " Private - validate aPropertyString "

    ( self partDirectEditValueIsValid:  aPropertyString contents )
        ifFalse: [
            MessageBox
                notify: 'Button Label Error'
                withText: self partDirectEditErrorMessage.
            ^false ].
    ^true!
addReferenceLanguageTo: aCodeGenerator
        "Private - code generation - add language models to aCodeGenerator
        that can be used to refer to the receiver and its components."
    | messageExpression message |
    aCodeGenerator
        reference: self
        withMethodArgumentNamed: 'anApplication'.
    componentDictionary associationsDo: [ :assoc |
        assoc value = self ifFalse: [
            messageExpression := aCodeGenerator messageExpressionToReference: assoc value.
            messageExpression receiverObject: self.
            message := messageExpression addSelector: #componentNamed:.
            message addArgument:  assoc key ]]!   
partSelectIn: anEditor
        " The receiver has been selected in a PARTS workbench. "
    ^anEditor workbenchPane lafSelectDefault: self! 
transferValuesToNewPart: newPart
        " Private - transfer interesting values from the receiver to the
        new part which it is becoming.  This should generally include
        everything handled by the parts's mirrorCopy. "

    super transferValuesToNewPart: newPart.
    newPart
        curFont: curFont;
        framingBlock: framingBlock;
        handlersAttribute: handlers;
        yourself!   
buildWindow: parentWindow
        "Private - Create the window for the receiver
         using parentWindow as the parent."
    self owner partIsEditing
        ifTrue: [^super buildWindow: parentWindow]!  
defaultIcon
    "Private - Answer the icon of the receiver on the
    workbench."
    | app |

    [ app := ( PARTSApplication fromFile: 'partaccr.par' ) ]
        on: PARTSApplicationLoadError
        do: [ :e | ^PARTSApplication defaultIcon ].
    ^app icon copy! 
wmVMousemove: wParam with: longInteger
        "Private - Add a MessageExpression to CurrentEvents
         and return right away."
    | point |
    self partsVwOnly.  " Only used on VW"
    point := Point fromInteger: longInteger.
    self partIsEditing ifTrue: [    "grab mouse"
        self partEditorPane
            partMouseMove: ( point mapFromWindow: self to: self partEditorPane )
            with: wParam.
        ^0 ].
    ^self wmMousemove: wParam with: longInteger!
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^false!  
hasExtStyle: aSymbol
    pwo20ExtendedStyleDictionary isNil 
        ifTrue: [ self initExtendedStyleDictionary ].
    ^(extStyle bitAt:
        (pwo20ExtendedStyleDictionary at: aSymbol ifAbsent: [^false]) + 1) = 1!  
partStoreResourceOn: aResourceFile
    | stream |
    stream := aResourceFile stream.
    stream nextPutAll: ' !! PARTSIcon !! fromFileStream: !! '.
    self  outputToFileStream: stream!
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    super codeGenerationAddAttributeMessagesTo:  anExpressionModel.
    self label notNil ifTrue: [
        self label isString
            ifTrue: [
                anExpressionModel addSelectorIfNotNil: #partLabelWithMnemonics: with: self partLabelWithMnemonics ]
            ifFalse: [
                anExpressionModel addSelectorIfNotNil: #partLabelWithMnemonics: with: self label ]].
    self isDefaultPushButton
        ifTrue: [
            anExpressionModel addSelector: #defaultPushButton ]!
initializeParts
        " Private - initialize the parts in an application
        which has just been loaded. "

    self supportsRecycling
        ifTrue: [
            self mainWindow
                when: #closed
                send: #recycle to: self ].!  
applicationName
        " Answer the name of the PARTS application which owns
        the PARTS settings editor window. "
    ^'PARTSSettingsEditorApplication'!   
partFrameRectangleFrom: aRectangle
        "Do nothing."
    "Copied to menu bar"

    ^nil!  
adjustPositionAfterUndoDelete: aMenuLabel
    "Adjust the position of aMenuLabel after an undo delete."
    "Copied to menu bar"

    self move: aMenuLabel
        toIndex: ( self findIndex:
            aMenuLabel frameRelativeRectangle leftTop )! 
newSequencePane
    "Private - Answer an extended list box that can
    have its contents reordered and will perform
    appropriate feedback."
    | anExtendedListBox |

    ^(anExtendedListBox := ExtendedListBox new )
            owner: self;
            font: self sequencePaneFont;
            userItemHeight: self entryHeight;
            userCanReorder: true;
            dragButton: self mouseButtonDrag;
            setName: self sequencePaneName;
            when: #dragSourceCut:
                send: #dragSourceCut: to: self;
            yourself!
findIndex: aPoint
    "Private - Answer the index of the menu label at <aPoint>.
    <aPoint> is relative to the receiver.
        The index is the position where <aPoint> is between the
    midpoints of the two labels beside <loc> in the recevier's
    wrapper components."
    "Copied to menu bar"

    ^self findIndex: aPoint
        in: ( self partWrapper components ).!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfTrue: #readOnly: with: self isReadOnly!  
workbenchSessionStartedMessages
        " Private - answer the session #started handlers
        for the PARTS workbench component. "

    ^OrderedCollection new
        add: ( Message
            receiver: PARTSStarterWindow currentClass
            selector: #started );
        yourself!
partPropertySetAlternateStyles: newStyle
        "Private - Change the receiver's aternate styles.
    e.g. extendedStyle.  Default is to do nothing."! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | item label |
    1 to: items size do: [ :i |
        item := items at: i.
        label := item contents.
        label isNil
            ifTrue: [
                anExpressionModel addSelector: #appendSeparator ]
            ifFalse: [
                anExpressionModel
                addSelector: #appendItem:selector:accelKey:accelBits:
                        with: label
                        with: item selector
                        with: ( accel at: i ) first
                        with: ( accel at: i ) last ]].
    anExpressionModel
        addSelectorIfNotNil: #title: with: title;
        addSelectorIfNotNil: #owner: with: owner!  
showLinkLabels: aBoolean
    newSettings showLinkLabels: aBoolean.!  
openOn: aPARTSEditor
        " Edit the background color settings in aPARTSEditor. "

    self openApplicationOn: aPARTSEditor.!   
helpDirectoryName
        "Answer the path name of the directory that contains
        help files for the development environment."

    ^Disk fullDirName , 'help'!  
partFencesMoveSession
    "Private - Answer whether the receiver automatically
    allows a move session initiated it to have its
    children moved outside without the shift key being pressed."

    ^true

!   
partPropertyAddColorAndFont: aPropertyStructure
    aPropertyStructure putProperty: ( PARTSPropertyColorAndFont new).!   
hierarchallySortedComponents
        "Private - code generation - answer an OrderedCollection of the
        receiver's components sorted hierarchally, that is those
        components at the to of the hierarchy first."
    | answer traverseBlock |
    answer := OrderedCollection new.
    traverseBlock := [ :aWrapper |
        aWrapper components do: [ :subwrapper |
            answer add: subwrapper object ].
        aWrapper components do: [ :subwrapper |
            traverseBlock value: subwrapper ]].
    traverseBlock value: wrapper.
    ^answer!  
close
        " User has pressed OK.  Accept changes and close. "
    self acceptProperties
        ifTrue: [
			self triggerEvent: #okToClose.
			searchPath := nil ].! 
removeWorkbenchSessionEventHandlers
        " Private - remove the session event handlers for the
        PARTS workbench component.
            PARTSSessionManager removeWorkbenchSessionEventHandlers
        "

    SessionModel current isRunTime
        ifFalse: [
            self workbenchSessionStartUpMessages do: [ :msg |
                SessionModel current
                    removeAction: msg
                    forEvent: #startup ].
            self workbenchSessionStartedMessages do: [ :msg |
                SessionModel current
                    removeAction: msg
                    forEvent: #started ].
            ].
    self workbenchSessionShutdownMessages do: [ :msg |
        SessionModel current
            removeAction: msg
            forEvent: #shutdown ].!  
findOrOpenOn: aPARTSEditor
        " Open a PARTS settings secondary editor. "
    self error: 'this is the primary guy'!   
partFileInUpgradeLoaded: anObjectFiler
        " Private - finish upgrading subpanes from PARTS Workbench 2.0.
        Do some cleanup and optimization to get rid of unnecessary stuff. "

    super partFileInUpgradeLoaded: anObjectFiler.

    " drop obsolete properties"
    self
        propertyAt: #foreColorRgb put: nil;
        propertyAt: #backColorRgb put: nil;
        propertyAt: #subclass put: nil.!
partManufacturer
        "Answer the manufacturer name component of the receiver's full part name.
        Part venders other than Digitalk should reimplement this method
        in their parts' classes to avoid naming conflicts."
    ^'Digitalk'!   
gridX: anInteger
    newSettings gridExtent:
        ( ( anInteger isNil ifTrue: [ 0 ] ifFalse: [ anInteger ] )
        @ newSettings gridExtent y ).! 
title
        " Private "
    ^'Sequence Directories'!  
updateVerticalSlider
        "Private - update the horizontal slider position."
    self updateVerticalSliderTo: topCorner y
! 
partWindowUnderPointNoGroupBox: aPoint
        "Answer the  window that is currently under aPoint,
         or nil if not a Smalltalk window.  If a group box contains
         aPoint, ignore it and answer a sibling or parent window
         that contains aPoint. aPoint is relative to the screen."

    | w |
    PARTSEditor setDragHandler: #excludeGroupBox
        execute: [ w := self windowUnderPoint: aPoint ].
    w isNil ifTrue: [ ^ nil ].
    w partOnTopWhenSelected ifTrue: [ ^w ].
    w := w partOverlappedWindow: aPoint.
     ^w!   
computeNumberOfRows
        "Private - the receiver formerly had unlimited rows.
        This is no longer supported.  Compute a finite value."
	| answer |
	answer := rows size.
    answer := answer max: rowLabels size.
	answer := answer max: rowNames size.
	answer := answer max: self newTablePane numberOfRows.
	^answer!
asDragObjectFrom: aDragSession
    "Private - Answer a DragObject version of the receiver.
    Answer nil if could not load the object"
    | dragObject |

    connection isPARTSCatalogIconConnection
        ifTrue: [ dragObject := connection dragItem ].
    dragObject isNil
        ifTrue: [
            ( dragObject := self buildLocalDragObject ) isNil
                ifTrue: [ ^nil ]].
    dragObject offset: origin - aDragSession dragStart.
    aDragSession isPARTSDragDropSession
        ifTrue: [ dragObject session: aDragSession ].
    ^dragObject!   
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    "Copied to menu bar"

    ^anObject isPARTSMenuLabelPart!  
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup."
    | aWrapper |
    componentDictionary do: [ :component |
        component == self ifFalse: [
            component partCodeGenerated: anApplicationBuilder ].
        aWrapper := component partWrapper.
        aWrapper notNil ifTrue: [
            aWrapper partCodeGenerated: anApplicationBuilder ]].
    ^super partCodeGenerated: anApplicationBuilder
!
maxEntries
    "Private - Answer the maximum number of entries
    that can fit on the screen"

    self implementedBySubclass!   
fileName
        " Private - answer the file containing the PARTS
        window definition. "
    ^'LAFMsBtn.par'!
addComponentMethodModelsTo: aClassModel
        "Private - code generation - add method models to aClassModel
        to rebuild each of the receiver's components."
    | component |
    componentDictionary associationsDo: [ :assoc |
        component := assoc value.
        ( component ~~ self " and: [ component shouldHaveBuildComponentMethod ] " )
            ifTrue: [
                component codeGenerationAddBuildComponentMethodModelTo: aClassModel  ]]!
removeVertScrollBar
        "Private - remove the vertical scroll bar when the scroll range is zero."
    | frameStyle |
    self partsVosOnly.
    frameStyle := self removeVerticalScrollbarStyle.
    self partPropertySetStyle: frameStyle
!
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."
    self partsVosOnly.
    ^WsPaneBorder |
        "FcfHorzscroll |
        FcfVertscroll  |"
        WsNoByteAlign!  
wmVRbuttondown: wParam with: longInteger
        "Private - Add a MessageExpression to CurrentEvents
         and return right away."
    | point |
    self partsVwOnly.  " Only used on VW"
    point := Point fromInteger: longInteger.
    self partIsEditing ifTrue: [
        ^self partEditorPane partButton2Down: (
            point mapFromWindow: self to: self partEditorPane ) ].
     ^self wmRbuttondown: wParam with: longInteger!   
changeBitAt: aPoint
        "Private - Change the bit at aPoint."
    | scaledPoint imagePoint color penWidth |
    ( self isInGrid: aPoint ) ifFalse: [ ^self ].
    changeFlag := true.
    imagePoint := aPoint // scale.
    scaledPoint := imagePoint * scale.
    penWidth := 1.  " VW"   "VOS: bitPen lineWidth"
    mode = #color
        ifTrue: [ color := bitColor ]
        ifFalse: [ mode = #screen
            ifTrue: [ color := Color cyan ]
            ifFalse: [ color := Color darkRed ] ].

    grid
        ifTrue: [
            bitPen
                fill: ( ( scaledPoint + 1 ) extent: ( scale @ scale * penWidth ) - 1 )
                color: color]
        ifFalse: [
            bitPen
                fill: ( scaledPoint extent: ( scale @ scale * penWidth ) )
                color: color ].
    imagePen
        fill: ( imagePoint extent: penWidth @ penWidth )
        color: color.
    copy pen fill: ( imagePoint extent: penWidth @ penWidth ) color: color.

    mode = #color ifTrue: [
        andMask pen
            fill: ( imagePoint extent: penWidth @ penWidth )
            rule: CopyRuleBlack.
        xorMask pen
           fill: ( imagePoint extent: penWidth @ penWidth )
           color: color].
    mode = #screen ifTrue: [
            andMask pen
                fill: ( imagePoint extent: penWidth @ penWidth )
                rule: CopyRuleWhite.
            xorMask pen
                fill: ( imagePoint extent: penWidth @ penWidth )
                rule: CopyRuleBlack ].
    mode = #inverse ifTrue: [
        andMask pen
            fill: ( imagePoint extent: penWidth @ penWidth )
            rule: CopyRuleWhite.
        xorMask pen
            fill: ( imagePoint extent: penWidth @ penWidth )
            rule: CopyRuleWhite ]! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setValue: with: self value! 
installRevisionSupportLibrary
    "Private "

    self isRepositoryComponentInstalled
        ifTrue: [ "Team/V installed"
            ( self
                bindLibrary: 'PWCRVS31'
                errorTitle: 'Workbench Revision Support Bind Problem'
                neededFor: 'loading and storing revisioned applications' )
                    ifFalse: [ self error: 'Cannot bind workbench revision support library.' ]]
        ifFalse: [
             SessionModel current
                when: #libraryBound:
                send: #checkForRepositoryComponent: to: self ].!
partPrintFontOn: aStream margin: aString
        " Private "
    
"    ( font := self font ) notNil
        ifTrue: [
            aStream
            nextPutAll: aString;
                nextPutAll: 'Font: ';
                nextPutAll: font faceName, ' ', font pointSize printString.
            font bold ifTrue: [ aStream nextPutAll: ' bold' ].
            font italic ifTrue: [ aStream nextPutAll: ' italic' ].
            aStream cr ]."! 
partLinksForEvent: eventName
        " Answer a list of the links triggered by <eventName> from the
        receiver.  The order of links in the list is the firing sequence. "

    | myWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^#() ].
    ^myWrapper linkListForEvent: eventName asSymbol!  
chooseFileDialogClass: anOperation
    " Private - answer the  Choose File dialog class
    that handles <anOperation>.  Recurse through
    subclasses, finding the lowest one that handles
    <anOperation>. "
    | aClass |

    self subclasses do: [ :aSubClass |
        ( aClass := aSubClass chooseFileDialogClass: anOperation ) notNil
            ifTrue: [ ^aClass ]].

    ^(( self handlesOperation: anOperation )
        ifTrue: [ self ]
        ifFalse: [ nil ])!   
partPropertyEditSize: aPropertyUnit
        " Private - Size property button handler. "
    | partProperties contextDictionary
       aFramer oldFramer newFramer |

    partProperties := aPropertyUnit propertyStructure.
    contextDictionary := partProperties partContext.

    oldFramer := self framingBlock copy.
    aFramer := contextDictionary at: #sizeWindowFramer
        ifAbsent: [oldFramer].

    newFramer := PARTSWindowSizeEditor new
        openOn: aFramer
        parentRectangle: self superWindow freeClientArea.
    newFramer isNil ifTrue: [^self].

    contextDictionary
        at: #sizeWindowFramer put: newFramer.
    partProperties
        addAction: (Message new
            receiver: self;
            selector: #partPropertySetSize: ;
            arguments: (Array with: newFramer))
        undo: (Message new
            receiver: self;
            selector: #partPropertySetSize: ;
            arguments: (Array with: oldFramer copy)).!  
partPropertySetSize: aScaledRect
        "Private - Set the receiver's framing specification
        to aScaledRectangle and resize accordingly.
        If <aScaledRect> has only a mask and scaleUnit,
        adjust only those values."
    | editorPane editor parentRectangle oldRect |

    parentRectangle := self superWindow freeClientArea.
    editor := self partEditor.
    editorPane := editor workbenchPane.
    oldRect := editorPane selectionRect: self.
    self framingBlock: aScaledRect.
    self partWrapper rectangle: aScaledRect.
    self
        resize: parentRectangle;
        bringToTop;
        updateWindow.
    editorPane updateScrollRanges.
    editorPane realInvalidateRect: oldRect.
    editorPane redisplaySelections: ( Array with: self ).
    editorPane partLinkEditor
        refreshAfterMoveOf: ( Array with: self )
        from: ( Array with: oldRect )
        to: ( Array with: ( self frameRectangle mapToWindow: editorPane )).
! 
partDragTargetOver: aDragDropSession
        "Private - aDragSession has is moving over the receiver. "
    "below is from dragTargetOver:"
    self dragTargetOverDefault: aDragDropSession.
    aDragDropSession targetDrawEmphasis.
    self dragTargetSetScrollDefault: aDragDropSession.

    self partDragTargetAccept: aDragDropSession!
entryHeight
        " Private "
    self implementedBySubclass! 
partFileInUpgradeLoadedWindows: anObjectFiler
        " Private - finish upgrading a visual part from PW/Win32 2.0. "!   
operation: anOperation title: aTitle
    "Private"

    ( anOperation = #open or: [ anOperation = #openLatest ])
        ifTrue: [ ^PARTSFileDescriptor promptForOpen: aTitle ]
        ifFalse: [
            anOperation = #save
                ifTrue: [ ^PARTSFileDescriptor promptForSave: nil ]].

    ^nil!  
initialize
        " Private - class initialization. "

    " Dialog top pane style constants "
    self
        partsIfOS2Do: [
            FrameStyle := nil ]  " use default "
        partsIfWindowsDo: [
            FrameStyle :=
                DsModalFrame |
                WsTitleBar |
                WsSystemMenu |
                DsNoIdleMessages |
                WsClipChildren |
                WsInitiallyVisible ].!   
removeWorkbenchSupportLibraries
        " Private - the main PARTS Workbench workbench library is being removed.
        Remove any workbench support libraries which have been installed for
        part libraries whose runtime library is installed. "

    self workbenchLibrariesOrdered do: [ :aLibraryName |
        self unbindWorkbenchSupportLibrary: aLibraryName ].!   
partDragTargetReplace: aReplaceSession in: aParent
     "Private - aDragSession has just been dropped on the receiver.
    Delete the receiver, add the drag object in its place and
    transfer the links from the receiver to the drag object.
    Answer the added part."
    | originalFramer addedPart isVisible |

    self hideWindow.
    originalFramer := self framingBlock.

    addedPart :=
        super partDragTargetReplace: aReplaceSession in: aParent.

    self partDragTransferProperties: addedPart.

    isVisible := addedPart partIsWindow and: [ addedPart isVisible ].

    addedPart partIsSizable
        ifTrue: [
            "Resize the new part to the size of the replaced part.
                Code taken from Window>>partPropretySetSize:
                Do use method itself because don't want to adjust
                links."
            addedPart partEditor selectOff: addedPart.
            addedPart
                hideWindow;
                framingBlock: originalFramer.
            addedPart partWrapper rectangle: originalFramer.
            addedPart resize: addedPart superWindow freeClientArea.
            isVisible ifTrue: [ addedPart showWindow ].

            addedPart partEditor selectAdd: addedPart ].

    ^addedPart!  
totalWidth
        "Private - answer the width for the reciever."
   child notNil
        ifTrue: [ ^child totalWidth ]
         ifFalse: [  ^0 ]!
initWindowSize
        " Answer the initial window extent of the client
        area in dialog box units. "
    ^clientExtentDlg!  
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer selector receiverExpression |
    answer := aCodeGenerator messageExpressionToReference: self.
    self isEmpty ifTrue: [ ^answer ].
    self size <= 4
        ifTrue: [
            self size = 1 ifTrue: [ selector := #with: ].
            self size = 2 ifTrue: [ selector := #with:with: ].
            self size = 3 ifTrue: [ selector := #with:with:with: ].
            self size = 4 ifTrue: [ selector := #with:with:with:with: ].
            answer
                receiverObject: self class;
                addSelector: selector arguments: self.
            ^answer ].
    receiverExpression := answer newReceiverMessageExpressionModel.
    receiverExpression
        receiverObject: self class;
        addSelector: #new: with: self size.
    1 to: self size do: [ :i |
        answer
            addSelector: #at:put: with: i with: ( self at: i ) ].
    answer addSelector: #yourself.
    ^answer!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelector: #landingSide: with: self landingSide;
        addSelector: #launchSide: with: self launchSide;
        addSelector: #leftTopEventLabel: with: self leftTopEventLabel;
        addSelector: #leftTopMessageLabel: with: self leftTopMessageLabel.
    pathPoints notNil ifTrue: [
        self
            partsIfOS2Do: [
                anExpressionModel addSelector: #pathPointsOriginLeftBottom: with: pathPoints ]
            partsIfWindowsDo: [
                anExpressionModel addSelector: #pathPointsOriginLeftTop: with: pathPoints ]]!  
computeNumberOfColumns
        "Private - the receiver formerly had unlimited columns.
        This is no longer supported.  Compute a finite value."
    | answer |
    answer := 0.
    rows do: [ :row | answer := answer max: row size ].
    answer := answer max: columnLabels size.
	answer := answer max: columnNames size.
	answer := answer max: self newTablePane numberOfColumns.
	^answer!  
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^false!  
mainWindow
        " Private "
    ^self partNamed: 'TopPane1'! 
findOrOpen
        " Open the PARTS Settings window. "
    | aSettingsWindow |
    aSettingsWindow := Notifier windows
        detect: [ :w |
            w isApplicationWindow
            and: [ w owner isPARTSApplication
            and: [ w owner partIsEditing not
            and: [ w owner name = self applicationName ] ] ] ]
        ifNone: [ nil ].
    aSettingsWindow notNil
        ifTrue: [
            aSettingsWindow makeActive.
            ^self ].
    self new open.!
partDragTargetOver: aDragSession
        "Private - a menu label is being dragged over
    the receiver.  Draw insertion point as visual feedback."
    "Copied to menu bar"

    self draggingOver: aDragSession.

    super partDragTargetOver: aDragSession!
topLevelParts
        "Private - answer the the receiver's top level component parts."
    ^self partWrapper components collect: [ :subwrapper |
        subwrapper object ]!  
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^false!  
userName
    ^settings userName! 
applicationName
        " Answer the name of the PARTS application which owns
        the link color settings editor window. "
    ^'PARTSMouseButtonsSettings'!   
partScriptSourceOf: scriptMessageSelector
        " Answer the source of the script named
        <scriptMessageSelector> attached to the receiver. "

    | myWrapper |
    (myWrapper := self partWrapper) isNil
        ifTrue: [ ^self error: 'not a part' ].
    myWrapper scriptSourceOf: scriptMessageSelector asSymbol.!   
addFileNameMethodTo: aClassModel
        "Private - code generation - add a method model to aClassModel
        answers the receiver's file name."
    | methodModel expression |
    methodModel := aClassModel newClassMethodNamed: #fileName.
    methodModel comment: 'Private - answer the file name of the file that held the receiver''s application.'.
    expression := methodModel newMessageExpression.
    expression receiverObject: self fileName
! 
initialize
        " Private - initialize the parts in an application
        which has just been loaded (e.g., register event handlers,
        initialize the state of parts in the application).
        Default is to do nothing. "
    super initialize.
    self loadApplication.
    ( self partNamed: 'DialogWindow1' )
        allowWorkbenchToBeDisabled: true.
    self application
        when: #closeWindow send: #recycle to: self.! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #searchPathChanged: #selectDirectory:
            #enableDirectoryButtons #disableDirectoryButtons
            #propertiesAccepted #okToClose )! 
listDescription
        " Private "
    ^'Search path directories:   '! 
partWindowUnderPoint: aPoint
        "Answer the  window that is currently under aPoint,
         or nil if not a Smalltalk window. If a group box contains
         aPoint, answer that group box. aPoint is relative to
         the screen. "

    | w  |
    PARTSEditor setDragHandler: #includeGroupBox
        execute: [ w := self windowUnderPoint: aPoint ].
    w isNil ifTrue: [ ^ nil ].
    w partOnTopWhenSelected ifTrue: [ ^w ].
    w := w partOverlappedWindow: aPoint.
     ^w!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    self do: [ :object |
        anExpressionModel
            addSelector: #add: with: object ].
    anExpressionModel addSelector: #yourself! 
samples
        "Private - Used in PARTS.  Help menu in PARTS Workbench has a sample
        item which gets sent to the help manager.  It then needs to be
        forwarded to the PARTS Workbench."
    (applicationWindow owner respondsTo: #helpSamples)
        ifTrue: [applicationWindow owner helpSamples]! 
partRedoDirectEdit: aValue
        "Redo a direct edit operation on the receiver.
        For most, the direct edit value is simply its contents.
        This method should be reimplemented by subclasses whose
        direct edit is special (eg. Notebook, ValueSet, etc..)."
    self partUndoDirectEdit: aValue!  
contents: aToolCollection
        "Set the receiver's contents.
        aToolCollection is a collection of Tool objects."

    aToolCollection do: [ :aTool | aTool toolPane: self ].
    super contents: aToolCollection.!  
clear
        "Private - clear the icon."
    changeFlag := true.
    copy pen fill: Color cyan.
    xorMask pen fill: xorMask boundingBox rule: CopyRuleBlack.
    andMask pen fill: xorMask boundingBox rule: CopyRuleWhite.
    self perform: #displayImage: with: imagePen graphicsMedium.
    self perform: #displayBits: with: bitPen graphicsMedium.!   
partContainingNestedPart
    "Answer the highest level nested part that contains
    the receiver, or nil if the receiver is not within a
    nested part."
    | w nestedPart |

    w := self.
    [ w partIsWindow and: [ w isPARTSEditorPane not ]]
        whileTrue: [
            w isPARTSNestedPart
                ifTrue: [ nestedPart := w ].
            w := w superWindow ].

    ^nestedPart!
canTriggerEvent: eventName
        "Answer <true> if the receiver can trigger an event
        named <eventName>.  The receiver never actually
        triggers events, it is just acting as a repository
        on behalf of its application's editor. "
    ^PARTSEditor canTriggerEvent: eventName!  
tutorial

    applicationWindow owner tutorial! 
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    ^aCodeGenerator globalVariableModelNamed: self name! 
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer
        receiverObject: numerator;
        addSelector: #/ with: denominator.
    ^answer!   
partPrintBackcolorOn: aStream margin: aString
        " Private "
    | backColor |
    ( backColor := self backColor ) notNil
        ifTrue: [
            aStream
                nextPutAll: aString;
                nextPutAll: 'Back color: ';
                nextPutAll: backColor printString;
                cr ].!  
defaultDirectoryFor: aDirectory in: searchPathDirectories
    " Private - answer the default directory.  If <aDirectory>
    is provided, answer it.  If not, answer the last directory
    used if it is currently on the search path.  If not, answer
    the current directory."
    | defaultDir |

    defaultDir := ( aDirectory notNil
        ifTrue: [ aDirectory ]
        ifFalse: [
            self lastDirectoryUsed notNil
                ifTrue: [ self lastDirectoryUsed ]
                ifFalse: [ nil ] ] ).

    ^( searchPathDirectories includes: defaultDir )
        ifTrue: [ defaultDir ]
        ifFalse: [ PARTSFile currentDirectory ]!   
ok
        " Private - the OK button has been pressed.
        Save any list sequencing changes. "
    changed
        ifTrue: [ answer := self sequencePane contents].
    self close.! 
source: source
    target: target
    application: application
    points: points
    editorPane: editorPane
    "Private - Given a source, target, and points ( in
    editor pane coordinates), answer an instance
    of the receiver.  If no source exists (arg/result link)
    or no target exists (internal arg link), don't set the
    respective sides, nor the respective points in the
    pathPoints."
    | sourceRect targetRect intersectionAssoc
        sourceSide targetSide offsetToTip
        linkEditState newPathPoints anchorPoint aPoint
        landingPlugWidth lastPoint
        adjustedFirstPoint firstPoint secondPoint |

    ( source notNil and: [ source isPARTSLink not ])
        ifTrue: [ sourceRect := editorPane partEditor getVisibleRectOf: source ].
    target notNil
        ifTrue: [ targetRect := editorPane partEditor getVisibleRectOf: target ].

    "Find the launching point by finding the intersection
    of the line with the source"
    sourceRect notNil ifTrue: [
        intersectionAssoc :=
            ( PARTSLine from: points first to: ( points at: 2 ) )
                singleIntersectionTowardStart: sourceRect.
        sourceSide := intersectionAssoc key.
        points at: 1 put: intersectionAssoc value ].

    "Find the landing point by finding the intersection
    point of the line with the target"
    target notNil ifTrue: [
        intersectionAssoc :=
            ( PARTSLine from: ( points at: points size - 1 ) to: points last )
                singleIntersectionTowardEnd: targetRect.
        targetSide := intersectionAssoc key.
        points at: points size put: intersectionAssoc value ].

    "Insure end points aren't the same"
    ( lastPoint := points last ) = points first
        ifTrue: [
            "Shift the landing point away from the launchPoint,
            unless there's no room. In which case, shift the other way"
            landingPlugWidth := PARTSLinkPath landingPlugWidth * 2.
            ((targetSide = SideTop) or: [targetSide = SideBottom])
                ifTrue: [
                    lastPoint x:
                        ((( lastPoint x right: landingPlugWidth ) isLeftEqualOf: targetRect right )
                            ifTrue: [ lastPoint x right: landingPlugWidth ]
                            ifFalse: [ lastPoint x left: landingPlugWidth ])]
                ifFalse: [
                    lastPoint y:
                        ((( lastPoint y down: landingPlugWidth ) isAboveEqual: targetRect bottom )
                            ifTrue: [ lastPoint y down: landingPlugWidth ]
                            ifFalse: [ lastPoint y up: landingPlugWidth ])]].

    linkEditState :=
        PARTSLinkEditState new
            landingSide: targetSide;
            launchSide: sourceSide;
            yourself.

    "Convert the points to edit state's storage format
    of relative path points."
    newPathPoints := Array new: points size.
    sourceRect notNil
        ifTrue: [
            anchorPoint := linkEditState
                anchorPointOn: sourceRect
                side: sourceSide.
            newPathPoints at: 1 put: points first - anchorPoint ]
        ifFalse: [
           newPathPoints at: 1 put: nil ].

    aPoint := points first. " launchPlugBase "
    source isPARTSLink  "Result link"
        ifTrue: [ "Launch plug is inside the launch side"
            offsetToTip := PARTSResultLinkPath launchPlugHeight.
            sourceSide := source editState landingSide.
            adjustedFirstPoint :=
                sourceSide = SideTop
                    ifTrue: [ aPoint down: offsetToTip ]
                    ifFalse: [ sourceSide = SideBottom
                        ifTrue: [ aPoint up: offsetToTip ]
                        ifFalse: [ sourceSide = SideLeft
                            ifTrue: [ aPoint right: offsetToTip ]
                            ifFalse: [ aPoint left: offsetToTip ]]].
            "Insure that next control point, if orthogonal, remains orthogonal"
            ( firstPoint := points at: 1 ) x = ( secondPoint :=  points at: 2 ) x
                ifTrue: [ points at: 2 put: ( adjustedFirstPoint x @ secondPoint y ) ]
                ifFalse: [
                    firstPoint y = secondPoint y
                        ifTrue: [ points at: 2 put: ( secondPoint x @ adjustedFirstPoint y )]]]
        ifFalse: [
            source notNil
                ifTrue: [ "Make point represent the launchPlugTip"
                    offsetToTip := PARTSLinkPath launchPlugHeight.
                    source isPARTSApplication  "Plug is inside"
                        ifTrue: [ offsetToTip := offsetToTip negated ].
                    aPoint :=
                        sourceSide = SideTop
                            ifTrue: [ aPoint up: offsetToTip ]
                            ifFalse: [ sourceSide = SideBottom
                                ifTrue: [ aPoint down: offsetToTip ]
                                ifFalse: [ sourceSide = SideLeft
                                    ifTrue: [ aPoint left: offsetToTip ]
                                    ifFalse: [ aPoint right: offsetToTip ]]]]].

    anchorPoint := aPoint.
    2 to: (points size - 1) do: [ :i |
        newPathPoints
            at: i
            put: (( points at: i ) - anchorPoint )].

    target notNil
        ifTrue: [
            anchorPoint := linkEditState
                anchorPointOn: targetRect
                side: targetSide.
            newPathPoints at: points size
                put: points last - anchorPoint ]
        ifFalse: [
            newPathPoints at: points size put: nil ].

    ( newPathPoints first isNil or: [ newPathPoints last isNil ])
        ifTrue: [
            newPathPoints := newPathPoints select: [ :each | each notNil ]].

    linkEditState
        pathPoints: newPathPoints
        scaleUnit: application defaultScaleUnit.

    ^linkEditState! 
partEditContents: aList properties: aPropertyStructure
        " Private - open a dialog to edit aList.
        Answer the new list. "
    | currentContentsAsText newContentsAsText newList line |
    currentContentsAsText := WriteStream on: String new.
    aList do: [ :item |
        currentContentsAsText nextPutAll: item; cr ].
    newContentsAsText := self partEditTextContents: currentContentsAsText contents.
    newContentsAsText isNil
        ifTrue: [ ^PARTSException new ].
    newContentsAsText := ReadStream on: newContentsAsText.
    newList := OrderedCollection new.
    [ newContentsAsText atEnd ]
        whileFalse: [
            line := newContentsAsText nextLine trimBlanks.
            line notEmpty ifTrue: [newList add: line ] ].
    ^newList! 
addAddExternalMessages: someMessages methodTo: aClassModel selector: aSelector
        "Private - code generation - add a method model to aClassModel
        that will add the external messages to a rebuilt version of the receiver."
    | methodModel expression |
    methodModel := aClassModel newClassMethodNamed: aSelector.
    methodModel argumentModels: self applicationArgumentModels.
    methodModel comment: 'Private - add  external messages to anApplication'.
    expression := methodModel newMessageExpression receiverObject: self.
    someMessages do: [ :externalMessage |
        expression addSelector: #addExternalMessage: with: externalMessage ]!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'PARTS Application'! 
partSetDirectEditValue: text
        " Set the direct-edit property value of the receiver
        to text and update the receiver appropriately.
        Answer nil if the text is invalid for the object."
    | w rect |

    ( self partDirectEditValueIsValid: text )
        ifFalse: [ ^nil ].

    self partSetDirectEditAttribute: text.
    ( self partDoesResizeToContents
    and: [ self partNeedsResizeToContents ] )
        ifFalse: [^text].

    " resize the receiver to its text contents "
    w := (self font stringWidth: text) + 4 +
        self extent x - self partDirectEditFrameRectangle width. "non-text area"
    rect := self frameRelativeRectangle.
    rect := ( self partDirectEditTextIsCentered
        ifTrue: [
            (rect center x left: w // 2) @ rect bottom
                extentFromLeftBottom: w + 6 @ rect height.
                ]
        ifFalse: [
            self partDirectEditTextIsRightJustified
                ifTrue: [
                    Rectangle
                        leftTop: (rect rightBottom leftAndUp:
                            (w + 4 @ rect height))
                        rightBottom: rect rightBottom]
                ifFalse: [
                    rect origin
                        extent: (w + 4 @ rect height) ]
            ] ).
    self
        resizeToRectangle: rect.

    self partsIfOS2Do: [ self sizeChanged: rect extent ].! 
pathNameForOpen: defaultFileName
    fileTypes: fileTypes
    defaultPattern: aDefaultPattern
        "Private - Open the Open File dialog with defaultFileName
        as the default file name. "

    ^self openDialogMessage: (  Message new
        receiver: self dialogBoxCreate
        selector:  #openFile:fileTypes:defaultPattern:
        arguments:
            ( Array
                with: defaultFileName
                with: fileTypes
                with: aDefaultPattern ))!
partPrintForecolorOn: aStream margin: aString
        " Private "
    | foreColor |
    ( foreColor := self foreColor ) notNil
        ifTrue: [
            aStream
                nextPutAll: aString;
                nextPutAll: 'Fore color: ';
                nextPutAll: foreColor printString;
                cr ].!  
checkForRepositoryComponent: aComponent
        " Private - a component has just been installed.
    If it is the Team/V repository component, install
    the revision support component. "

    ( self isRepositoryComponentInstalled
        and: [ ( Smalltalk includesKey: #PARTSTeamVInterface ) not ])
        ifTrue: [
            "Team/V just installed and revision support not installed yet"
            self installRevisionSupportLibrary ]! 
gridX
    ^settings gridExtent x!
fileName
        " Private - answer the file containing the PARTS
        window definition. "
    ^'LAFBkClr.par'!
fileName
        " Private - answer the file containing the PARTS
        application definition.  If no file type extension
        is specified, open the first file with the given name
        in the PARTS search path.  If multiple types found in
        the same directory, open editable .PAR if available,
        else open the executable .PAX file. "
    ^'AddObjct'!   
screenButtonSelected
        "Private - The screen button has been selected. "
    mode := #screen.
    self setColorBoxes!
partEditRectangle: aPARTSFramer
    "Private - Set the PARTSFramer of the receiver on the workbench.
    Used to set the position of nonvisual part icons."

    self partWrapper rectangle: aPARTSFramer
!  
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer receiverObject: self class.
    arguments size = 0
        ifTrue: [
            answer
                addSelector: #receiver:selector:
                with: receiver
                with: selector ]
        ifFalse: [
            answer
                addSelector: #receiver:selector:arguments:
                with: receiver
                with: selector
                with: arguments ].
    ^answer!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #setList: with: self list;
        addSelector: #value: with: self value!   
mapFileName
    "Private - Answer the name of the file that maps logical library names
    to their actual library names."

    ^'v.map'! 
showHints: aBoolean
    newSettings showHints: aBoolean.!
updateScrollBars: scrollRange
        "Private - add/remove the horizontal  and vertical scroll bars as needed.
         A scroll range of zero indicates that a scroll bar is not need and should be removed."
    self partsVosOnly.
!  
partPropertiesIndexOf: anArray
        "Private - Answer the index of the element in anArray
        of style constants which is set in the receiver. "
    | sortedArray |
    sortedArray := anArray asSortedCollection: [ :a :b | a >= b].
    ^anArray indexOf:
        (sortedArray
            detect: [ :aStyle | self hasStyle: aStyle]
            ifNone: [^1])!
dialogBoxCreate
        " Private - answer a dialog box for the receiver. "
    ^PARTSAnyFileDialog new
        closedAction: self dialogClosedAction;
        yourself!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^self class name! 
removeWorkbenchService
        " Remove the #PARTSWorbench service "

     ServiceRegistry globalRegistry unregister: #PARTSWorkbench.!
partIsOkToDelete
    "Is it OK to delete the receiver part
    inside the Workbench?"
    ^true!   
new
        "Answer the instance of the application instead of the self.
        The main role of the class to create instances of the PARTSApplication
        that it is pointing to."
    ^super new application!  
initialize
        "Private - initialize the receiver."
    super initialize.
    topCorner := 0 @ 0.
    !   
partRealParent
        " Answer the real parent part of the receiver. "
    | myWrapper aWrapper |
    ( myWrapper := self partWrapper ) isNil
        ifTrue: [ ^nil ].
    aWrapper := myWrapper parent.
"    [ aWrapper object isPARTSTransientPart ]
        whileTrue: [ aWrapper := aWrapper parent ]."
    ^aWrapper object!   
basicSmalltalkExecutable
    "Private - Answer the file name of the basic image to
    be used to startup a Parts application."

    ^'v.gen'!
orthogonalLinks: aBoolean
    newSettings orthogonalLinks: aBoolean.!
partTargetEmphasisRectangle
        "Private - answer a rectangle to be used for
        drag target emphasis."
    | rect |
    rect := self freeClientArea.
    rect := ( rect leftBottom rightAndUp: 2 @ 1 ) rightTop:
        ( rect rightTop leftAndDown: 2 @ 2 ).
    ^rect! 
isPARTSCatalogPane
    "Answer whether the receiver is a PARTSCatalogPane"

    ^false!
installWorkbenchComponent
        " Install the PARTS Workbench component
            PARTSWorkbenchSessionManager installWorkbenchComponent
        "

    self
        initializeInterfaceClasses;
        initializeWorkbenchData;
        initializeWorkbenchPlatformEvents;
        initializeWorkbenchSessionEventHandlers;
        installWorkbenchSupportLibraries;
        installRevisionSupportLibrary;
        registerWorkbenchService.! 
resize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
    super resize: aRectangle.
    self updateScrollRanges

!   
addLanguageModelsTo: aCodeGenerator
        "Private - code generation - add to aCodeGenerator the language models that
        encode rebuilding the receiver."
    self
        addReferenceLanguageTo: aCodeGenerator;
        addClassModelTo: aCodeGenerator!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelector: #items:separators:defaultItem:
        with: items
        with: separators
        with: defaultItem!
partAddAddComponentExpressionTo: aCodeGeneratorExpression application: aPARTSApplication
		"Private - append code generation expressions for the receiver
		to <aCodeGeneratorExpression>.  Do nothing, the receiver is
		aPARTSApplication and is added to its own component dictionary when
		it is created."!  
scrollTopCorner: aPoint continuous: aBoolean
        "Private - Move the contents of the receiver by extent aPoint.
          aBoolean indicate whether scrolling is restricted by the range."
    | oldCorner scrollRanges newRect |
    oldCorner := topCorner deepCopy.
    scrollRanges := self getScrollRanges.
    aBoolean
        ifTrue: [
            topCorner x: ( ( topCorner x - aPoint x ) max: 0 ).
            topCorner y: ( ( topCorner y - aPoint y ) max: 0 ) ]
        ifFalse: [
            topCorner x: ( ( topCorner x - aPoint x  min: ( scrollRanges x ) ) max: 0 ).
            topCorner y: ( ( topCorner y - aPoint y min: ( scrollRanges y ) ) max: 0) ].
    oldCorner = topCorner ifTrue: [ ^self ].
    aBoolean ifTrue: [  "if we're doing continuous scrolling, make sure child is big enough"
        newRect := child frameRelativeRectangle leftTop
            extentFromLeftTop: ( child frameRelativeRectangle extent + topCorner ).
        self resizeChild: newRect
    ].

    self
        partsIfOS2Do: [
            PARTSHostInterface hostWindowLibrary
                scrollWindow: handle
                dx: ( oldCorner x - topCorner x )
                dy: ( topCorner y - oldCorner y )
                rclScroll: nil
                rclClip: nil
                hrgnUpdate: nil
                rclUpdate: nil
                fs: 3 "SwScrollchildren  | SwInvalidatergn ".]
        partsIfWindowsDo: [
            PARTSHostInterface hostWindowLibrary
                scrollWindow: self handle
                xAmount: ( oldCorner x - topCorner x )
                yAmount: ( oldCorner y - topCorner y )
                lpRect: nil
                clipRect: nil.
            self updateWindow].
    child adjustFraming: child frameRelativeRectangle

!  
partNewPartCodeGeneratorExpression
        " Private - answer a PARTS code generator expression which
        which recreate the receiver. "

    ^PARTSCodeGeneratorInterface expressionClass new receiver:
            ( PARTSCodeGeneratorInterface creationExpressionClass new
                receiver: self class
                selector: #newWithName:
                arguments: ( Array with: (  PARTSCodeGeneratorInterface referenceFor: self partName )))!  
partEditDirect: aFileDescriptor
        "Edit direct by opening a workbench on the part that is being refered."
   | appCopy editors tempDescriptor fileName directory |

    aFileDescriptor isNil
        ifTrue: [
            MessageBox
                notify: 'Part File Not Set'
                withText: 'This part accessor part does not refer to any part.'.
            ^nil].

    ( fileName := aFileDescriptor fileName ) fileExtension trimBlanks size > 0
        ifTrue: [ tempDescriptor := aFileDescriptor ]
        ifFalse: [
            fileName := fileName,'.', PARTSFileDescriptor fileTypeForPart type.
            [ directory := PARTSFile directoryContaining: fileName ]
                on: PARTSNotOnSearchPath
                do: [ :e | e postMessageBox: 'Edit Part Accessor Error'. ^nil ].
            tempDescriptor := PARTSFileDescriptor fileName: fileName in: directory ].

    [ PARTSFile fullPathName: tempDescriptor ]
        on: PARTSNotOnSearchPath
        do: [ :e |
            e postMessageBox: 'Edit Part Accessor Error'.
            ^nil ].
    editors := PARTSEditor editorsOnFile: tempDescriptor.
    editors size > 0
        ifTrue: [
            editors first mainView makeActive.
            ^self ].
    [ appCopy := tempDescriptor loadForEdit.
     ( appCopy notNil and: [ appCopy isEditable not ])
         ifTrue: [ PARTSInvalidApplication signalForFile: tempDescriptor ] ]
            on: PARTSApplicationLoadError
            do: [ :e |
                e postMessageBox: 'Part Accessor Load Error'.
                ^nil ].
    appCopy isNil
        ifTrue: [ ^nil ].  "Backstop: should raise error."

    PARTSEditor openOn: appCopy update: self.!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #fileDescriptor: with: self fileDescriptor;
        addSelectorIfFalse: #demandLoad: with: demandLoad!