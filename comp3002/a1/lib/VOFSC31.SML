3.1.0.106
   
availableListHeight
        " Private - answer the height in screen points that
        is available for use by the variable lists and their
        titles in order to ensure that the Ok/Cancel buttons
        are visible.  Estimate size of caption, borders, and
        description text at 7 lines. "
    ^Display height - (7 * SysFont height)!   
installComponent
       " Initialize the classes installed in the ObjectFiler shape change component. "

    ListConnectionPane initialize.!   
forClassName: aClassName destinationClassName: destinationClassName
        " Answer a default change map for the class named
        aClassName which will load its filed instances into destinationClassName.  
        Source instance variables will be mapped
        into the destination class shape by matching names. "

    ^self new
        sourceClassName: aClassName;
        destinationClassName: destinationClassName;
        yourself!   
forClassName: aClassName
        " Answer a default change map for the class named
        aClassName.  Source instance variables will be mapped
        into the current class shape by matching names. "

    ^self new
        sourceClassName: aClassName;
        destinationClassName: aClassName;
        yourself!
forClass: aClass
        " Answer a default change map for aClass.
        Source instance variables will be mapped into the
        current class shape by matching names. "

    ^self forClassName: aClass name!  
forClass: aClass destinationClass: destinationClass
        " Answer a default change map for aClass
        which will load its filed instances into destinationClass.
        Source instance variables will be mapped into the
        destination class shape by matching names. "

    ^self forClassName: aClass name destinationClassName: destinationClass name!
computeSlotIndexArray
        " Private - compute the slot index array.  By default,
        load instance variables of the same name into the
        current slot for that name.  Apply any mapping
        specifications which have been requested. "
    sourceVariables isNil
        ifTrue: [self error: 'object change source names not defined'].
    destinationSlotArray := Array new: self destinationSize.
    self sourceVariables do: [ :anInstVarName |
        self setSlotEntryFor: anInstVarName from: anInstVarName].
    variableMappings notNil
        ifTrue: [
            variableMappings do: [ :assoc |
                self setSlotEntryFor: assoc key from: assoc value] ].!  
destinationSize
        " Answer the size of the destination object. "
    ^self destinationVariables size! 
slotIndexArray: anArray
        " Specify the change map as an array corresponding
        to the destination variable names.  The index-th
        element in the slot array is the index of the
        source variable to be mapped into the index-th
        destination name.  The element is nil if
        no source variable is to be mapped to the
        new instance variable. "
    destinationSlotArray := anArray.!
printOn: aStream
        " Append a text representation of the receiver to aStream. "

    super printOn: aStream.
    sourceClassName notNil
        ifTrue: [
            aStream nextPutAll: ' (', sourceClassName.
            ( destinationClassName notNil
            and: [ destinationClassName ~= sourceClassName ] )
                ifTrue: [ aStream nextPutAll: ' -> ', destinationClassName ].
            aStream nextPutAll: ')' ].!   
sourceVariables
        " Answer the names of the source instance variables. "
    ^sourceVariables!
sourceVariables: variableNames
        " Set the names of the source instance variables. "
    sourceVariables := ( variableNames isString
        ifTrue: [variableNames asArrayOfSubstrings]
        ifFalse: [variableNames] ).!   
set: aDestinationVariable from: aSourceVariable
        " When an instance is changed, put the value
        that was originally in the instance variable
        named aSourceVariable into the instance
        variable named aDestinationVariable.
        Set the destination to nil if sourceVariable is nil. "
    variableMappings isNil
        ifTrue: [variableMappings := OrderedCollection new].
    variableMappings add: (Association
        key: aDestinationVariable
        value: aSourceVariable).!
destinationClassName
        " Answer the name of the destination class. "
    ^destinationClassName!   
destinationVariables
        " Answer the names of the destination instance variables. "
    destinationVariables isNil
        ifTrue: [
            destinationVariables := (Smalltalk at: destinationClassName asSymbol)
                allInstVarNames ].
    ^destinationVariables!   
slotIndexArray
        " Answer the change map as an array corresponding
        to the destination variable names.  The index-th
        element in the slot array is the index of the
        source variable to be mapped into the index-th
        destination name.  The element is nil if
        no source variable is to be mapped to the
        new instance variable. "
    destinationSlotArray isNil
        ifTrue: [self computeSlotIndexArray].
    ^destinationSlotArray!  
put: aSourceVariable into: aDestinationVariable
        " When an instance is changed, put the value
        that was originally in the instance variable
        named aSourceVariable into the instance
        variable named aDestinationVariable.
        Set the destination to nil if sourceVariable is nil.
        Answer whether the mapping registration succeeded. "
    ^self set: aDestinationVariable from: aSourceVariable!
sourceClassName
        " Answer the name of the source class. "
    ^sourceClassName!  
sourceClassName: aString
        " Set the name of the source class. "
    sourceClassName := aString asString.!
slotNameArray
        " Answer the change map as an array corresponding
        to the destination variable names.  The index-th
        element in the slot array is the name of the
        source variable to be mapped into the index-th
        destination variable.  The element is nil if
        no source variable is to be mapped to the
        destination variable. "
    ^self slotIndexArray collect: [ :index |
        index isNil ifTrue: [nil] ifFalse: [sourceVariables at: index] ]!   
layoutIsChanging
        " Answer whether there are any changes between
       the source and the destination. "
    (self sourceSize ~= self destinationSize)
        ifTrue: [^true].   " adding or dropping values "
    1 to: self destinationSize do: [ :i |
        ( (self slotIndexArray at: i) ~= i )
            ifTrue: [^true] ].  " inst var shuffled or dropped "
    ^false!   
setSlotEntryFor: aDestinationVariable from: aSourceVariable
        " Private - put the value that was originally
        in the instance variable named aSourceVariable
        into the instance variable aDestinationVariable.
        Set the destination to nil if sourceVariable is nil.
        Answer whether the mapping registration succeeded."
    | sourceSlotIndex destinationSlotIndex |
    sourceSlotIndex := ( aSourceVariable isNil
        ifTrue: [nil]
        ifFalse: [self sourceVariables
            indexOf: aSourceVariable
            ifAbsent: [ ^ false ] ] ).
    destinationSlotIndex := self destinationVariables
        indexOf: aDestinationVariable
        ifAbsent: [ ^ false ].
    self slotIndexArray
        at: destinationSlotIndex
        put: sourceSlotIndex.
    ^true!
destinationClassName: aString
        " Set the name of the destination class. "
    destinationClassName := aString asString.! 
destinationVariables: variableNames
        " Set the names of the destination instance variables. "
    destinationVariables := ( variableNames isString
        ifTrue: [variableNames asArrayOfSubstrings]
        ifFalse: [variableNames] ).!
sourceSize
        " Answer the size of the source object. "
    ^sourceVariables size! 
extentForButton: aButtonLabel
        " Private - measure button and add white space around label "
    | charWidthDlg |
    charWidthDlg := WindowDialog charWidth.
    ^((aButtonLabel size * charWidthDlg) + (charWidthDlg * 2))
        @ (WindowDialog charHeight + charWidthDlg).! 
extentForLabel: aLabel
        " Private - measure aLabel "
    ^(aLabel size * WindowDialog charWidth)
        @ WindowDialog charHeight! 
createView
        " Private - compute client area layout and create windows.
        Answer whether successful (need enough screen space).
        The graph pane layout for the instance variable load map
        is computed in screen points.  However, all the window
        sizing has to be done in dialog box units.  So
        normalize everything into character box units and do
        lots of ugly conversions from points to dialog box units. "
    | marginDlg windowTitle topPane
      deltaLeftMarginX deltaLeftTop deltaLeftTop2 internalWidthDlg
      anExtent |

    marginDlg := WindowDialog charWidth.
    windowTitle := 'Object Load Map'.

    " set up the list connection pane for size computation "
    changeMapPane := ListConnectionPane new
        leftTitle: sourceTitle;
        leftList: sourceList;
        rightTitle: destTitle;
        rightList: destList;
        maximumHeight: self maximumListHeight;
        characterExtent: WindowDialog dialogUnit;
        yourself.

    self addView:
        ((topPane := self topPaneClass new)
            owner: self;
            labelWithoutPrefix: windowTitle
            ).
    deltaLeftMarginX := marginDlg.
    deltaLeftTop := deltaLeftMarginX @ marginDlg.
    internalWidthDlg := self titleBarWidth: windowTitle.

    " description text "
    description notNil
        ifTrue: [
            anExtent := self extentForLabel: description.
            topPane addSubpane:
                (StaticText new
                    contents: description;
                    framingBlock:
                        (self framingBlock: deltaLeftTop
                            extent: anExtent) ).
            internalWidthDlg := internalWidthDlg max: anExtent x.
            deltaLeftTop :=
                deltaLeftMarginX
                @ (deltaLeftTop y + anExtent y + marginDlg).
        ].

    " list titles "
    anExtent := self extentForLabel: sourceTitle.
    deltaLeftTop2 := deltaLeftTop
        right: (self widthInDialogUnits:
            changeMapPane leftListRectangle left).
    topPane addSubpane:
        (StaticText new
            contents: sourceTitle;
            "?? foreColor: ClrBlack; ??"   " MikeA liked this "
            framingBlock:
                (self framingBlock: deltaLeftTop2
                    extent: anExtent) ).
    deltaLeftTop2 := deltaLeftTop
        right: (self widthInDialogUnits:
            changeMapPane rightListRectangle left).
    anExtent := self extentForLabel: destTitle.
    topPane addSubpane:
        (StaticText new
            contents: destTitle;
            "?? foreColor: ClrBlack; ??"   " MikeA liked this "
            framingBlock:
                (self framingBlock: deltaLeftTop2
                    extent: anExtent) ).
    internalWidthDlg := internalWidthDlg max:
        (deltaLeftTop2 x + anExtent x).
    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + anExtent y "+ marginDlg").

    " the actual mapping lists "
    anExtent := changeMapPane visibleExtent.
    anExtent :=
        (self widthInDialogUnits: anExtent x)
        @ (self heightInDialogUnits: anExtent y).
    topPane addSubpane:
        (changeMapPane
            framingBlock:
                (self framingBlock: deltaLeftTop
                    extent: anExtent) ).
    internalWidthDlg := internalWidthDlg max: anExtent x.
    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + anExtent y + marginDlg).

    " OK and Cancel buttons "
    anExtent := self
        createOkCancelButtons: topPane
        deltaLeftTop: deltaLeftTop.
    internalWidthDlg := internalWidthDlg max: anExtent x.

    clientExtentDlg :=
        (internalWidthDlg + (2 * marginDlg))
        @ (deltaLeftTop y + anExtent y + marginDlg).
    ^topPane!  
framingBlock: deltaLeftTop extent: extent
        " Private - answer the framing block for
        a window whose leftTop corner is deltaLeftTop
        from the upper left of the dialog window
        with extent. "
    ^[ :box |
        (box leftTop rightAndDown: deltaLeftTop)
        extentFromLeftTop: extent]!
initWindowSize
        " Answer the initial window extent of the client
        area in dialog box units. "
    ^clientExtentDlg!  
cancel
        " Private - user pressed Cancel button "
    self close.!
openFor: descriptionString
    sourceTitle: sourceTitleString
    sourceVars: sourceArrayOfStrings
    destTitle: destTitleString
    destVars: destArrayOfStrings
        " Open an ObjectLoadDialog.  The descriptionString
        is an information line at the top of the dialog.
        There are two stacks of zero or more instance variable
        names, source and dest, in a column under a title.
        Answer a load map for the destination variables.
        The load map is an array indexed by a destination
        instance variable index (slot index) containing
        a source instance variable index (slot number) or nil
        to load into that destination instance variable. "
    self
        openOn: (ObjectChangeMap new
            sourceVariables: sourceArrayOfStrings;
            destinationVariables: destArrayOfStrings;
            yourself)
        sourceTitle: sourceTitleString
        destinationTitle: destTitleString
        description: descriptionString.
    ^updatedChangeMap isNil
        ifTrue: [nil]
        ifFalse: [updatedChangeMap slotIndexArray]!  
initialize
        " Private - initialize new instance"
    super initialize.
    showCancel := true.! 
maximumListHeight
        " Private - answer the height in screen points that
        is available for use by the change map list pane
        order to ensure that the Ok/Cancel buttons
        are visible.  Estimate height of caption, borders,
        description, and list titles at 8 lines. "

    ^(Display height * 3 // 4) - (8 * SysFont height)!
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
            contents: 'OK';
            when: #clicked send: #ok to: self ;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: buttonExtent)).
    showCancel
        ifFalse: [^buttonExtent].
    topPane addSubpane:
        (Button new
            pushButton;
            setName: 'cancelButton';
            contents: 'Cancel';
            when: #clicked send: #cancel to: self ;
            framingBlock: (self framingBlock:
                ((deltaLeftTop x + buttonExtent x + marginDlg)
                    @ deltaLeftTop y)
                extent: buttonExtent)).
    ^((2 * buttonExtent x) + marginDlg) @ buttonExtent y! 
openOn: aChangeMap
    sourceTitle: sourceTitleString
    destinationTitle: destTitleString
    description: descriptionString
        " Open an ObjectLoadDialog.  The descriptionString
        is an information line at the top of the dialog.
        There are two stacks of zero or more instance variable
        names, source and destination, in a column under a title.
        Answer the updated change map (nil if cancelled). "
    | dialogWindow |

    changeMap := aChangeMap.
    description := descriptionString.
    sourceTitle := sourceTitleString.
    sourceList := changeMap sourceVariables.
    destTitle := destTitleString.
    destList := changeMap destinationVariables.

    (dialogWindow := self createView) isNil
        ifTrue: [^updatedChangeMap := nil].
    showCancel
        ifTrue: [
            changeMapPane leftToRightConnections:
                changeMap slotIndexArray copy.
            updatedChangeMap := nil]
        ifFalse: [  " workaround for not being able to catch/disable close "
            changeMapPane leftToRightConnections:
                changeMap slotIndexArray.
            updatedChangeMap := changeMap].
    dialogWindow open.
    ^updatedChangeMap!
showCancel: aBoolean
        " Specify whether a Cancel button is displayed "
    showCancel := aBoolean!   
titleBarWidth: aString
        " Private - answer the width of a titleBar containing
        a system menu and aString (dialog box units). "
    ^(aString size + 4) * WindowDialog charWidth    " fudge sysMenu width "!  
ok
        " Private - user pressed OK button. "
    changeMap slotIndexArray: changeMapPane leftToRightConnections.
    updatedChangeMap := changeMap.  " workaround for missing close event "
    self close.!  
heightInDialogUnits: heightInPoints
        " Private - answer heightInPoints as a height in
        in dialog box units, rounded up to the next
        character box boundary. "
    | charHeightPts nLines |
    charHeightPts := SysFont height.
    nLines := heightInPoints // charHeightPts.
    (heightInPoints \\ charHeightPts) > 0
        ifTrue: [nLines := nLines + 1].
    ^nLines * WindowDialog charHeight! 
widthInDialogUnits: widthInPoints
        " Private - answer widthInPoints as a width in
        in dialog box units, rounded up to the next
        character box boundary. "
    | charWidthPts nChars |
    charWidthPts := WindowDialog dialogUnit x.
    nChars := widthInPoints // charWidthPts.
    (widthInPoints \\ charWidthPts) > 0
        ifTrue: [nChars := nChars + 1].
    ^nChars * WindowDialog charWidth! 
initializeClassVariables
        " Private - initialize platform-dependent constants.
        (Portability workaround due to lack to common
        system constants dictionary that maps to platform.
        Objective here is source-code portability.) "

    ( Smalltalk platformIsWin32 or: [ Smalltalk platformIsOS2 ] )
        ifFalse: [ self error: 'unknown Smalltalk platform' ].

    Smalltalk platformIsWin32
        ifTrue: [
            FrameStyle := 16r56800000.
            VerticalScrollBarStyle := 16r200000.
            DefaultDragButton := #button1.
            PlatformWindowLibrary := #UserLibrary.
            ScrollOptions := 2 "SwInvalidate".
            ].
    Smalltalk platformIsOS2
        ifTrue: [
            FrameStyle := 16r1200.
            VerticalScrollBarStyle := 16r40 "64".
            DefaultDragButton := #button2.
            PlatformWindowLibrary := #PMWindowLibrary.
            ScrollOptions := 3.
            ].
     SessionModel current isRunTime
        ifFalse: [ self validateClassVariables ].!  
validateClassVariables
        " Private - validate platform-dependent constants.
        Evaluate this is a development environment to
        validate hardwired platform-dependent values. 
            ListConnectionPane validateClassVariables
        "

    | hostConstants platformValue |

    " instance method childFrameStyle "
    Smalltalk platformIsWin32
        ifTrue: [
            hostConstants := Smalltalk at: #OperatingSystemConstants.  " WinConstants "
            platformValue := 0.
            #( 'WsBorder' 'WsChild' 'WsVisible' 'WsClipsiblings' 'WsClipchildren' )
                do: [ :styleName |
                    platformValue := platformValue |
                        ( hostConstants at: styleName ) ].
            FrameStyle = platformValue 
                ifFalse: [ self error: 'invalid platform constant' ].
            VerticalScrollBarStyle = ( hostConstants at: 'WsVscroll' ) 
                ifFalse: [ self error: 'invalid platform constant' ].
            ScrollOptions := 0.
            "ISSUE: Not in WinConstants yet:
                = 1, SwScrollchildren
                = 2, SwInvalidate
                =3, SwErase
            #( 'SwScrollchildren' 'SwInvalidate' )
                do: [ :styleName |
                    ScrollOptions := ScrollOptions |
                        ( hostConstants at: styleName ) ].
            "
            ScrollOptions := 2 "SwInvalidate".
            ].
    Smalltalk platformIsOS2
        ifTrue: [
            hostConstants := Smalltalk at: #OperatingSystemConstants.  " PMConstants "
            platformValue := 0.
            #( 'FcfBorder' 'FcfNobytealign' )
                do: [ :styleName |
                    platformValue := platformValue |
                        ( hostConstants at: styleName ) ].
            FrameStyle = platformValue ifFalse: [ self error: 'invalid platform constant' ].
            VerticalScrollBarStyle = ( hostConstants at: 'FcfVertscroll' ) 
                ifFalse: [ self error: 'invalid platform constant' ].
            platformValue := 0.
            #( 'SwScrollchildren' 'SwInvalidatergn' )
                do: [ :styleName |
                    platformValue := platformValue |
                        ( hostConstants at: styleName ) ].
            ScrollOptions = platformValue 
                ifFalse: [ self error: 'invalid platform constant' ].
            ].! 
initialize
        " Private - initialize the class. "

    self
        initializeEventsTriggered;
        initializeClassVariables.!   
displayConnections
        " Private - display the connection shapes and
        the wiring connections between the two lists. "
    graphicsTool setLineWidth: 1.
    1 to: leftList size do: [ :i |
        self displayLeftConnector: i].
    1 to: rightList size do: [ :i |
        self displayRightConnector: i].
    self displayLeftToRightConnections.! 
amountToPageUp
        "Private - Answer the number of lines for
         vertical page scrolling."
    ^self visibleLines - 1!
rightConnectorsRectangle
        " Answer the bounding box of the right list
        connector shapes within the receiver. "
    rightConnectorsRectangle isNil ifTrue: [self computeLayout].
    ^rightConnectorsRectangle!  
rightList: anArrayOfStrings
        " Specify the right list. "
    rightList := anArrayOfStrings.! 
leftListRectangle
        " Answer the bounding box of the left list
        within the receiver. "
    leftListRectangle isNil ifTrue: [self computeLayout].
    ^leftListRectangle! 
initializeLeftToRightConnections
        " Private - initialize the left-to-right connection map if not specified.
        Default mapping connect list items with the same name. "
    | rightListSize rightItem |
    leftToRightConnections notNil ifTrue: [^self].
    rightListSize := rightList size.
    leftToRightConnections := Array new: rightListSize.
    1 to: rightListSize do: [ :rightIndex |
        rightItem := rightList at: rightIndex.
        leftToRightConnections
            at: rightIndex
            put: (leftList indexOf: rightItem ifAbsent: [nil]) ].!
rightListRectangle
        " Answer the bounding box of the right list
        within the receiver. "
    rightListRectangle isNil ifTrue: [self computeLayout].
    ^rightListRectangle! 
moveTopCornerBy: extent
        "Private - Move top corner by extent and
        display changes."
    extent y = 0
        ifFalse: [self scrollVertical: extent y].!
leftTitle: aString
        " Specify the left list's title.  The list must be at least as
        wide as its title when it is displayed. "
    leftTitle := aString.! 
lineHeight
        " Private - answer the height of an item in a list "
    | unit |
    lineHeight isNil
        ifTrue: [
            lineHeight := self lineHeightDefault.
            unit := ( characterExtent isNil
                ifTrue: [1]
                ifFalse: [characterExtent y ] ).
            ( lineHeight \\ unit ) = 0
                ifFalse: [  " round up the character box boundary "
                    lineHeight :=
                        (lineHeight // unit) + unit ].
            ].
    ^lineHeight!  
rightConnectorSocketRectangle: anIndex
        " Answer the bounding box of the socket
        connector shape for the anIndex-th left Item. "
    | boundingRect |
    boundingRect := self rightConnectorRectangle: anIndex.
    ^Rectangle
        leftTop: (boundingRect leftTop down: 2)
        rightBottom: (boundingRect rightBottom leftAndUp: 3 @ 2)!
trackDragFrom: aPoint
        " Private - track mouse until a buttonUp occurs and
        answer the point at which buttonUp occurred.
        Answer nil if buttonUp was outside graphPane or user aborted.
        Tracking is done in desktop coordinates. "

    | pen yTop yBottom oldTopIndex jiggleMessage isScrolling
      origin dest nextDest endTrackEvent delta
      scrollingUp scrollingDown aborted |

    self captureMouseInput.
    self doGraphics: [
    pen := graphicsTool.
    pen
        setLineWidth: 1;
        foreColor: Color black;
        setLineType: LineTypeSolid;
        setForegroundMode: MixRuleInvertSurface.
    self trackClipCursor: pen to: self superWindow.

    yTop := rectangle top down: self marginHeight.
    yBottom := rectangle bottom up: self marginHeight.
    oldTopIndex := self topIndex.
    jiggleMessage := Message
        receiver: self
        selector: #yourself.
    isScrolling := self visibleLines < self totalLength.

    origin := aPoint.
    dest := origin.
    pen place: origin; goto: dest.
    endTrackEvent := ( self dragButton, 'Up:' ) asSymbol.
    scrollingUp := scrollingDown := false.
    aborted := false.
    Notifier consumeInputUntil: [ :event |
        nextDest := Cursor sense mapScreenToClient: self.
        isScrolling
            ifTrue: [  " figure out which way we're going when scrolling enabled "
                scrollingUp := (
                    ( nextDest y isAbove: yTop )
                    and: [ self topIndex > 1 ] ).
                scrollingDown := (
                    ( nextDest y isBelow: yBottom )
                    and: [ self topIndex < ( leftList size max: rightList size ) ] ).
                ].
         ( dest ~= nextDest or: [ scrollingUp | scrollingDown ] )
            ifTrue: [
                pen place: origin; goto: dest.
                scrollingDown
                    ifTrue: [
                        pen setForegroundMode: MixRuleDefault.
                        self scrollVertical: -1.
                        oldTopIndex = self topIndex
                            ifFalse: [
                                CurrentEvents addLast: jiggleMessage. "jiggle"
                                self updateSliders.
                                origin := origin up: self lineHeight].
                        oldTopIndex := self topIndex.
                        pen setForegroundMode: MixRuleInvertSurface].
                scrollingUp
                    ifTrue: [
                        pen setForegroundMode: MixRuleDefault.
                        self scrollVertical: 1.
                        oldTopIndex = self topIndex
                            ifFalse: [
                                CurrentEvents addLast: jiggleMessage. "jiggle"
                                self updateSliders.
                                origin := origin down: self lineHeight].
                        oldTopIndex := self topIndex.
                        pen setForegroundMode: MixRuleInvertSurface].
                pen place: origin; goto: nextDest.
                dest := nextDest].
        " loop termination condition "
        ( event selector = endTrackEvent
        or: [ aborted := Notifier isEscapeKeyInput: event ] )
        ].
    pen place: origin; goto: dest.

    pen
        setLineType: LineTypeDefault;
        setForegroundMode: MixRuleDefault.
    self trackClipCursor: pen to: nil.
    ].  " end of doGraphics "
    self clearMouseCapture.
    CurrentEvents := OrderedCollection new.

    ( aborted
    or: [ ( ( 0 @0 extent: self rectangle extent ) containsPoint: dest ) not ] )
        ifTrue: [ ^nil ].
    delta := ( aPoint - dest ) abs.
    ( delta x > 4 or: [ delta y > 4 ] )
        ifFalse: [ ^nil ].  " don't be too sensitive "
    ^dest!
rightConnectorRectangle: anIndex
        " Answer the bounding box of the anIndex-th
        right connector shape. "

    ^( self rightConnectorsRectangle left
        @ ( self listItemTop: anIndex in: self rightConnectorsRectangle ) )
    extentFromLeftTop: self rightConnectorExtent!  
widthVerticalScrollBar
        " Private - answer the width of a vertical scroll bar. "
    ^OperatingSystem getSystemValue: SystemValueVerticalScrollBarWidth! 
dragFromLeftIndex: leftIndex startPoint: startPoint
        " Private - drag from the leftIndex-th left connector
        starting from startPoint. "
    | endPoint |
    endPoint := self trackDragFrom: startPoint.
    endPoint isNil ifTrue: [^self].
    self
        plugLeft: leftIndex
        intoRight: (self rightDragIndexUnder: endPoint).
    self redisplayConnections.! 
bottomIndex
        " Private - answer the list index of the bottom item "
    ^(self topIndex + self visibleLines - 1)
        min: self totalLength! 
leftToRightConnections: anArray
        " Specify the left-to-right connections mapping.
        The element in the index-th array element
        is the index of the left list item which is mapped
        to the the index-th right list item. "
    leftToRightConnections := anArray.! 
dragFrom: aPoint
        " Private - track mouse drag starting from aPoint "
    | anIndex |
    anIndex := self leftDragIndexUnder: aPoint.
    anIndex notNil
        ifTrue: [^self dragFromLeftIndex: anIndex startPoint: aPoint].
    anIndex := self rightDragIndexUnder: aPoint.
    anIndex notNil
        ifTrue: [^self dragFromRightIndex: anIndex startPoint: aPoint].!   
indexOfItemUnder: aPoint in: aRectangle maxIndex: maxIndex
        " Private - answer the index corresponding
        to the item under aPoint.  Items are stacked
        vertically in aRectangle. "

    | index |
    ( aRectangle containsPoint: aPoint )
        ifFalse: [ ^nil ].
	index := ( aPoint y - aRectangle top ) abs // self lineHeight + self topIndex.
    ^index > maxIndex
        ifTrue: [ nil ]    " shouldn't get here, but check just in case... "
        ifFalse: [ index ]!   
leftToRightConnections
        " Answer the left-to-right connections mapping.
        The element in the index-th array element
        is the index of the left list item which is mapped
        to the the index-th right list item. "
    leftToRightConnections isNil
        ifTrue: [self initializeLeftToRightConnections].
    ^leftToRightConnections!  
trackClipCursor: aPen to: aWindow
        " Private - restrict the cursor to aWindow.
         Specifying nil clears clipping.
        This is only supported properly on Windows.
        On VOS, we clip display, but can't restrict the
        actual cursor movement. "

    | clippingRegion |
    Smalltalk platformIsWin32
        ifTrue: [
            clippingRegion := ( aWindow isNil
                ifTrue: [ nil ]
                ifFalse: [
                    ( Smalltalk at: #WinRectangle ) fromRectangle:
                        ( aWindow rectangle mapClientToScreen: aWindow ) ] ).
            platformWindowLibrary clipCursor: clippingRegion asParameter.
            ^self ].
    Smalltalk platformIsOS2
        ifTrue: [
            "Temp disable: clipping isn't working right on VOS 3.0??
            clippingRegion := ( aWindow isNil
                ifTrue: [ nil ]
                ifFalse: [
                    aPen createRegion:
                        ( aWindow rectangle mapClientToScreen: aWindow ) ] ).
            aPen setClipRegion: clippingRegion
            "
            ].!
scrollTopCornerTo: aNewCorner
        "Private - Scroll topCorner to aNewCorner"
    self scrollVertical: self topIndex - aNewCorner y! 
displayRightConnector: rightIndex
        " Private - display the connector for the rightIndex-th right item. "
    (rightIndex between: self topIndex and: (self bottomIndex min: rightList size))
        ifFalse: [^self].
    self
        displaySocketPointingLeftIn:
            (self rightConnectorSocketRectangle: rightIndex)
        color: ( (leftToRightConnections at: rightIndex) isNil
            ifTrue: [self colorUnconnected]
            ifFalse: [self colorConnected] ).!   
marginHeight
        " Private - answer the top/bottom margins "
    ^self visibleLines = self totalLength
        ifTrue: [self marginWidth // 2]
        ifFalse: [0]!  
marginWidth
        " Private - answer the left/right margins "
    ^self characterExtent x!
scrollVertical: nLinesRequested
        "Private - Scroll the receiver anInteger
         list items up (if anInteger is
         positive) or down (if negative)."
    | nLines newTopIndex |
    nLines := self amountToScroll: nLinesRequested.
    newTopIndex := self topIndex - nLines.
    ( newTopIndex <= 0
    or: [newTopIndex > self totalLength] )
        ifTrue: [^self].
    self
        topIndex: newTopIndex;
        scrollWindowBy: nLines.! 
displayPlugPointingRightIn: aRectangle color: color
        " Private - display a triangle with its tip pointing
        to the right in aRectangle in color. "
    | points |
    points := Array
        with: aRectangle leftTop
        with: aRectangle leftBottom
        with: (aRectangle rightTop down: (aRectangle height // 2)).
    self displayPolygon: points color: color.!
totalLength
        "Private - Answer the number of lines in the receiver
         for the vertical scroll bar limit. "
    ^leftList size max: rightList size!
widthBetweenConnectors
        " Private "
    ^self marginWidth * 4!   
initialize
        " Private - initialize new instance"
    super initialize.
    self
        font: self defaultFont;
        dragButton: DefaultDragButton.
    Smalltalk platformIsOS2
        ifTrue: [ self frameCreationFlags: FrameStyle ]  "VOS "
        ifFalse: [ self style: FrameStyle ].  " VW "
    platformWindowLibrary := Smalltalk at: PlatformWindowLibrary.
    topCorner := 1 @ 1.  " vertical unit is list items "!  
updateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollBar.
        Do nothing for a list connection pane."!   
displayList: aList in: aRectangle
        " Private - display list of strings "

    | textOrigin  |

    "Consider installing the following if supported on VW 3.0:
    graphicsTool
        displayLines: aList
        from: self topIndex
        to: ( self bottomIndex min: aList size )
        in: aRectangle.
    "

    textOrigin := aRectangle leftTop
        down: "self marginHeight."
          "VWin32 used the following, which is inconsistent with listItemTop: "
            (self lineHeight // 2) + (self font height // 2)
            - self font descender.
    self topIndex to: (self bottomIndex min: aList size) do: [ :i |
        graphicsTool
            displayText: (aList at: i)
            at: textOrigin.
        textOrigin := textOrigin down: self lineHeight].! 
display
        "Private - Display the receiver's lists and connections. "
    self doGraphics: [
        graphicsTool
            foreColor: Color black;
            fill: rectangle color: self backColor.
        self
            displayList: leftList in: self leftListRectangle;
            displayList: rightList in: self rightListRectangle;
            displayConnections.
        ].!
plugLeft: leftIndex intoRight: rightIndex
        " Private - connect the leftIndex-th left item into
        the rightIndex-th right item. "
    | rightIndexToDisconnect |
    rightIndex isNil
        ifTrue: [  " drop the connection from leftIndex "
            rightIndexToDisconnect := leftToRightConnections indexOf: leftIndex.
            rightIndexToDisconnect ~= 0
                ifTrue: [leftToRightConnections at: rightIndexToDisconnect put: nil]]
        ifFalse: [  " make a new connection "
            leftToRightConnections at: rightIndex put: leftIndex ].!   
characterExtent
        " Answer the extent in points of the standard
        character box."
    ^characterExtent notNil
        ifTrue: [characterExtent]
        ifFalse: [self font charSize]!   
characterExtent: aPoint
        " Specify the extent in points of the standard
        character box.  If specified, the list layout will
        be rounded to align to character box boundaries. "
    characterExtent := aPoint.!  
computeLayout
        " Private - compute the internal layout and overall extent
        of the receiver. "

    | leftListExtent leftConnectorsExtent
      rightListExtent rightConnectorsExtent
      verticalMarginHeight widthBetweenConnectors widthToRightList
      leftTop |

    leftListExtent := self extentRounded:
        (self extentList: leftList title: leftTitle).
    leftConnectorsExtent :=
        self leftConnectorExtent x
        @ leftListExtent y.
    rightListExtent := self extentRounded:
        (self extentList: rightList title: rightTitle).
    rightConnectorsExtent :=
        self rightConnectorExtent x
        @ rightListExtent y.

    visibleLines := self totalLength.
    verticalMarginHeight :=  2 * self marginHeight.
    widthBetweenConnectors := self widthBetweenConnectors.
    widthToRightList := 2.
    totalExtent :=
        ( ( 2 * self marginWidth )
            + leftListExtent x + leftConnectorsExtent x
            + widthBetweenConnectors
            + rightConnectorsExtent x + widthToRightList + rightListExtent x )
        @ ( verticalMarginHeight
            + ( leftListExtent y max: rightListExtent y ) ).

    ( maximumHeight notNil
    and: [totalExtent y > maximumHeight] )
        ifTrue: [
            Smalltalk platformIsOS2
                ifTrue: [ self addFrameCreationFlags: VerticalScrollBarStyle ]  "VOS "
                ifFalse: [ self addStyle: VerticalScrollBarStyle ].  " VW "
            totalExtent :=
                (totalExtent x + self widthVerticalScrollBar)
                @ totalExtent y - verticalMarginHeight.
            visibleExtent := totalExtent x @ maximumHeight.
            visibleLines :=
                ( maximumHeight "- ( 2 * self marginHeight )" )
                // self lineHeight.
            maximumHeight \\ self lineHeight > 0
                ifTrue: [ visibleLines := visibleLines + 1 ].  " round up "
            ]
        ifFalse: [
            visibleExtent := totalExtent.
            "visibleLines := self totalLength."  " moved up for variable margin "
            ].

    leftTop := ( 0 @ 0 extent: visibleExtent ) leftTop.
    "Smalltalk platformIsOS2
        ifTrue: [
            fudgeFactor := Display extent y > 760
                ifTrue: [ 3 ]
                ifFalse: [ 0 ].
            maxItems := leftList size max: rightList size.
            leftTop := leftTop down: ( maxItems * fudgeFactor )]."
    leftListRectangle :=
        ( leftTop rightAndDown: self marginWidth @ self marginHeight )
        extentFromLeftTop: leftListExtent.
    leftConnectorsRectangle :=
        leftListRectangle rightTop
        extentFromLeftTop: leftConnectorsExtent.
    rightConnectorsRectangle :=
        (leftConnectorsRectangle rightTop
            right: widthBetweenConnectors)
        extentFromLeftTop: rightConnectorsExtent.
    rightListRectangle :=
        ( rightConnectorsRectangle rightTop right: widthToRightList )
        extentFromLeftTop: rightListExtent.!
displayLeftToRightConnections
        " Private - display the left-to-right connections. "
    | leftIndex |
    1 to: leftToRightConnections size do: [ :rightIndex |
        leftIndex := leftToRightConnections at: rightIndex.
        leftIndex notNil
            ifTrue: [
                self
                    displayConnectionFromLeft: (self leftConnectorPlugRectangle: leftIndex)
                    toRight: (self rightConnectorSocketRectangle: rightIndex)
                    color: self colorConnected ] ].!   
leftConnectorExtent
        " Private - answer the area within which a left
        list item connector shape is drawn. "
    ^self characterExtent x @ self lineHeight!   
displaySocketPointingLeftIn: aRectangle color: color
        " Private - display a socket connector shape
        with the socket connection pointing left in aRectangle. "
    | points |
    points := Array new: 5.
    points
        at: 1 put: aRectangle leftTop;
        at: 2 put: aRectangle rightTop;
        at: 3 put: aRectangle rightBottom;
        at: 4 put: aRectangle leftBottom;
        at: 5 put: (aRectangle leftTop rightAndDown: (aRectangle height // 2)).
    self displayPolygon: points color: color.!   
amountToScroll: nLines
        " Private - answer the actual number of lines to scroll
        for a scroll request of nLines. "
    | newTopIndex |
    newTopIndex := ( (self topIndex - nLines)
        min: self totalLength )
            max: 1.
    ^self topIndex - newTopIndex!   
leftList: anArrayOfStrings
        " Specify the left list. "
    leftList := anArrayOfStrings.!
colorUnconnected
        " Private - answer the color of an unconnected item "
    ^Color red!  
displayConnectionFromLeft: leftRect toRight: rightRect color: color
        " Private - display a connection between
        a left list plug and a right list socket shape. "
    | halfHeight start mid1 mid2 end
      lineWidthEnd lineWidthMid |

    halfHeight := leftRect height // 2.
    start := leftRect rightTop
        leftAndDown: (1 @ halfHeight).
    mid1 := start right: 4.
    halfHeight := rightRect height // 2.
    mid2 := rightRect leftTop
        leftAndDown: 1 @ halfHeight.
    end := rightRect leftTop
        rightAndDown: ((halfHeight - 2) @ halfHeight).

    lineWidthEnd := 2.
    lineWidthMid := ( mid1 y = mid2 y
        ifTrue: [lineWidthEnd]
        ifFalse: [lineWidthEnd - 1] ).  " diagonal lines look wider "

    graphicsTool
        foreColor: color;
        setLineWidth: lineWidthEnd;
        place: start;
        goto: mid1;
        setLineWidth: lineWidthMid;
        goto: mid2;
        setLineWidth: lineWidthEnd;
        goto: end.!
listItemTop: anIndex in: aRectangle
        " Private - answer the real y coordinate of the top
        of the anIndex-th list element. "

    ^aRectangle top
        down: ( (anIndex - self topIndex) * self lineHeight )!
rightDragIndexUnder: aPoint
        " Private - answer the index corresponding
        to the right list item for a drag operation under aPoint."
    ^self indexOfItemUnder: aPoint
        in: self rightConnectorsRectangle
        maxIndex: rightList size! 
scrollWindowBy: nLines
        " Private - platform-dependent implementation "

    | dy |
    dy := nLines * self lineHeight.
    Smalltalk platformIsOS2
        ifTrue: [ dy := dy negated ].
    self
        scrollBy: 0 @ dy
        scrollRect: nil
        clipRect: nil
        flags: ScrollOptions.
    Smalltalk platformIsOS2
        ifTrue: [
            nLines strictlyPositive ifTrue: [ self display ].
            ].
    self updateWindow.! 
leftDragIndexUnder: aPoint
        " Private - answer the index corresponding
        to the left item for a drag operation under aPoint."
    ^self indexOfItemUnder: aPoint
        in: self leftConnectorsRectangle
        maxIndex: leftList size!  
leftConnectorRectangle: anIndex
        " Answer the bounding box of the anIndex-th
        left connector shape. "

    ^( self leftConnectorsRectangle left
        @ ( self listItemTop: anIndex in: self leftConnectorsRectangle ) )
    extentFromLeftTop: self leftConnectorExtent!   
totalExtent
        " Answer the receiver's total extent. "
    totalExtent isNil ifTrue: [self computeLayout].
    ^totalExtent!  
visibleExtent
        " Answer the receiver's visible extent. "
    visibleExtent isNil ifTrue: [self computeLayout].
    ^visibleExtent!  
leftConnectorPlugRectangle: anIndex
        " Answer the bounding box of the plug
        connector shape for the anIndex-th left Item. "
    | boundingRect |
    boundingRect := self leftConnectorRectangle: anIndex.
    ^Rectangle
        leftTop: (boundingRect leftTop rightAndDown: 2)
        rightBottom: (boundingRect rightBottom up: 2)! 
lineHeightDefault
        " Private - answer the default line height "
    ^self font height!   
topIndex: anInteger
        " Private - set the list index of the top item "
    topCorner := topCorner x @ anInteger.! 
extentList: anArrayOfStrings title: title
        " Private - Answer the extent of the bounding box
        for anArrayOfStrings displayed as a vertical list.
        The box must be at least as wide as the title. "
    | font width |
    font := self font.
    width := ( title isNil
        ifTrue: [0]
        ifFalse: [font stringWidth: title] ).
    anArrayOfStrings do: [ :aString |
        width := width max: (font stringWidth: aString)].
    ^width @ (anArrayOfStrings size * self lineHeight)! 
displayLeftConnector: leftIndex
        " Private - display the connector shape for the leftIndex-th left item. "
    (leftIndex between: self topIndex and: (self bottomIndex min: leftList size))
        ifFalse: [^self].
    self
        displayPlugPointingRightIn: (self leftConnectorPlugRectangle: leftIndex)
        color: ( (leftToRightConnections includes: leftIndex)
            ifTrue: [self colorConnected]
            ifFalse: [self colorUnconnected] ).!  
dragButton: aSymbol
         " Specify the button to be used from making
        connections.  Must be #button1 or #button2. "
    dragButton := aSymbol.! 
dragButton
         " Answer the button to be used from making
        connections."
    ^dragButton!  
defaultBackColor
        " Private - answer the receiver's default background color "
    ^Color gray!  
dragFromRightIndex: rightIndex startPoint: startPoint
        " Private - drag from the rightIndex-th right connector
        starting from startPoint. "
    | endPoint |
    endPoint := self trackDragFrom: startPoint.
    endPoint isNil ifTrue: [^self].
    self
        plugLeft: (self leftDragIndexUnder: endPoint)
        intoRight: rightIndex.
    self redisplayConnections.! 
redisplayConnections
        " Private - refresh the connections "

    self invalidateRect: ( Rectangle
        leftTop: self leftConnectorsRectangle left @ rectangle top
        rightBottom: self rightConnectorsRectangle right @ rectangle bottom ).!  
maximumHeight: anInteger
        " Specify the maximum height in pixels that the
        receiver may use to display its lists. "
    maximumHeight := anInteger.! 
rightTitle: aString
        " Specify the right list's title.  The list must be at least as
        wide as its title when it is displayed. "
    rightTitle := aString.!  
rightConnectorExtent
        " Private - answer the area within which a right
        list item connector shape is drawn. "
    ^(self characterExtent x * 2) @ self lineHeight!   
displayPolygon: points color: color
        " Private - display a filled polygon in the requested color. "
    graphicsTool
        setLineWidth: 1;
        foreColor: color;
        setFillColor: color;
        polygonFilled: points.! 
topIndex
        " Private - answer the list index of the top item "
    ^topCorner y!  
amountToScrollUp
        "Private - Answer the number of
         lines for vertical scrolling."
    ^1!   
extentRounded: extentInPoints
        " Private - answer extentInPoints rounded up to the
        next character boundary. "
    | charBoxPts nCharsWide nLines |
    charBoxPts := self characterExtent.
    nCharsWide := extentInPoints x // charBoxPts x.
    (extentInPoints x \\ charBoxPts x) > 0
        ifTrue: [nCharsWide := nCharsWide + 1].
    nLines := extentInPoints y // charBoxPts y.
    (extentInPoints y \\ charBoxPts y) > 0
        ifTrue: [nLines := nLines + 1].
    ^(nCharsWide @ nLines) * self characterExtent! 
colorConnected
        " Private - answer the color of a connected item "
    ^Color green! 
visibleLines
        " Answer the number of items visible in the receiver. "
    visibleLines isNil ifTrue: [self computeLayout].
    ^visibleLines!   
leftConnectorsRectangle
        " Answer the bounding box of the left list
        connector shapes within the receiver. "
    leftConnectorsRectangle isNil ifTrue: [self computeLayout].
    ^leftConnectorsRectangle!  
button1Down: aPoint
        "Private - Left button is pressed down. "
    self dragButton = #button1
        ifTrue: [^self dragFrom: aPoint].
    ^super button1Down: aPoint!
button2Down: aPoint
        "Private - Right button is pressed down. "
    self dragButton = #button2
        ifTrue: [^self dragFrom: aPoint].
    ^super button2Down: aPoint!