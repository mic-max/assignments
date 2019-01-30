3.1.0.106
   
openOn: aList separators: aSeparatorList selection: initialSelection
        " Open a list dialog displaying aList with
        separator at  the positions in aSeparatorList.
        Default is to select none of the entries."
    separators := aSeparatorList.
    ^super
         openOn: aList
        selection: initialSelection! 
separatorString: aString
        "Private - set the string the receiver uses to indicate a separator."
    separatorString := aString
!
listHeightDlg: aList in: aListPane
        " Private - answer the height in dialog units "

    | nLines |
    nLines := ( aList size max: minEntriesToShow )
        min: maxEntriesToShow.
    self font = SysFont
        ifTrue: [
            ^( nLines * WindowDialog charHeight ) + 1 ]
        ifFalse: [
            ^self class heightInDialogUnits: ( nLines * self font height ) ].!
indexOf: aString
        "Answer the index of the item aString."
    

    ^self controlToItemIndex: ( super indexOf: aString ).! 
title: aString
        " Specify the title of the window "
    title := aString!
contents: anItemCollection separators: separatorCollection
    "Set the receiver's contents to <anItemCollection> and
    its separator list to separatorCollection "
    | mergedList |

    mergedList := OrderedCollection new.
    1 to: anItemCollection size do: [ :anItemIndex |
        mergedList add: ( anItemCollection at: anItemIndex ).
        ( separatorCollection includes: anItemIndex )
            ifTrue: [ mergedList add: separatorString ]].
    ( mergedList isEmpty not and: [ mergedList last = separatorString ])
        ifTrue: [ mergedList removeLast ].

    super contents: mergedList!   
newListPane
        " Private - answer the initialized list pane. "
    ^self listPaneClass new
        font: self font;
        contents: list separators: separators;
        yourself!
dragStart: aPoint
    "Set the point where the a drag session
    started on the receiver."

	^self propertyAt: #dragStart put: aPoint!   
dragTargetDropDefault: dragSession
        "Private - provide default handling of drop if no handler
        is provided by inserting the item into the list.
        Code from ListBox but need to access real indices."
    | dragObject item string dragFormats format position top |
    dragObject := dragSession objects first.
    ( dragFormats := self dragTargetFormats ) isNil
        ifTrue: [ ^self error: 'dragTargetFormats: must be specified' ].
    format := dragFormats detect: [ :s | dragObject hasFormat: s ] ifNone: [ ^nil ].
    ( self dragTargetOperations includes: dragSession operation ) ifFalse: [ ^nil ].

    item := dragObject format: format.
    string := self stringForItem: item.
    top := self getTopIndex.
    position := self itemIndexFromPoint: dragSession targetLocation.
    ( dragSession source == self and: [ position < self dragSourceSelection ] )
        ifTrue: [ self dragSourceSelection: self dragSourceSelection + 1 ].

    self  realInsertItem: item at: position.
    self setTopIndex: top.
    self  "Keep selection on dragged item"
        sendDeferredEvent: #selectItem:
        with: item!  
maxEntriesToShow: anInteger
    maxEntriesToShow := anInteger!   
dragTargetNoScrollRectangle
        "Private - answer the inset rectangle within the receiver window
        outside of which drag scrolling will commence.
        Code from ListBox.  Need to use the rectangle extent"
    ^( 0 @ 0 extent: self rectangle extent ) insetBy: self class dragTargetScrollInset! 
defaultDrawHighlight: aDrawStruct
        "Private - Highlight the item to be drawn."
    | itemId pen rect isWindows highlightInfo |

    ( self isSeparatorAt:  aDrawStruct itemId + 1 )
        ifTrue: [ ^self defaultDrawSeparator: aDrawStruct ].

    pen := self ownerDrawPen.
    itemId := aDrawStruct itemId + 1.
    rect := aDrawStruct boundingBox.

    ( isWindows := OperatingSystem isWin32 )
        ifTrue: [
            highlightInfo :=
                self
                    highlightInfoWindows: itemId
                    drawBox: rect.
            itemId := highlightInfo at: 1.
            rect := highlightInfo at: 2 ].

    "Check if item is outside the control.  Happens during
    drag scrolling, or a drag move when the item is inserted
    before it is cut causing a temporary incorrect list size."
    ( itemId notNil and: [ itemId <= list size ])
        ifTrue: [
            pen
                setTextAlign: 
                    ( isWindows
                        ifTrue: [ 24 "TaBaseline" ]
                        ifFalse: [ 1024 "TaBase" ]);
                lineDisplayHighlighted: ( self stringForItem: ( list at: itemId  ))
                    at: ( rect bottomLeft up: pen font descender ) ]!
openOn: aList separators: aSeparatorList
        " Open a list dialog displaying aList with
        separator at  the positions in aSeparatorList.
        Default is to select the first entry. "
    ^self
        openOn: aList
        separators: aSeparatorList
        selection: 1!
realSelection
    "Answer the selection in the control.  Don't set the value
    variable as a side effect"
    | oldValue selection |

    oldValue := value.
    selection := super getSelection.
    value := oldValue.
    ^selection!
realInsertItem: item at: controlIndex
        "Insert the given item into the list (and the host control)
        at the given position.  Code from ListBox"
    list := list isNil
        ifTrue: [ Array with: item ]
        ifFalse: [
            controlIndex > list size
                ifTrue: [ list copyWith: item ]
                ifFalse: [ ( list copyFrom: 1 to: controlIndex - 1 ), ( Array with: item ), ( list copyFrom: controlIndex to: list size ) ] ].
    self isHandleOk
        ifTrue: [ self insertItemInControl: item at: ( ( controlIndex > list size ) ifTrue: [ self class listEnd ] ifFalse: [ controlIndex - 1 ] ) ]!   
setGraphicsFont: aFont

    self graphicsTool font: aFont!  
separatorHeight
        "Answer the height of a separator in pixels."
    ^self itemHeight
    "^10"!  
defaultDragButton
        " Private - answer the default drag button for the current system. "

    | defaultDragButton |
    OperatingSystem isWin32
        ifTrue: [ defaultDragButton := #button1 ].
    OperatingSystem isOS2
        ifTrue: [ defaultDragButton := #button2 ].
    ^defaultDragButton! 
ok
        " Private - user pressed OK button. "
    self
        saveSelection;
        close.!  
new

    ^super new ownerDrawFixed; yourself!   
ownerDrawFixed
    "Private - Answer the style for an OwnerDrawListBox.
    Empty space appears at the bottom of an owner-drawn
    list box on lower resolutions.  Show only entire items."

    | allowPartialItemStyle |

    super ownerDrawFixed.
    OperatingSystem isWin32
        ifTrue: [ allowPartialItemStyle := 256 "LbsNointegralheight" ].
    OperatingSystem isOS2
        ifTrue: [ allowPartialItemStyle := 4 "LsNoadjustpos" ].
    ^self removeStyle: allowPartialItemStyle!
listPaneClass
        " Private "
    ^ListBox! 
dragSourceNeedsObjectDefault: dragSession
        "Private - provide default for requested drag items if no handler
        is provided by supplying the currently selected item.
        Code from ListBox, but need to access real selection."
    | dragDropObject aSelection |
	( aSelection := self realSelection ) isNil
		ifTrue: [ ^nil ].
    dragDropObject := dragSession objectClass new
        object: self selectedItem;
        string: ( self stringForItem: ( self lineAt: aSelection ));
        yourself.
    dragSession objects: ( Array with: dragDropObject )! 
font
        " Answer the font to use for the dialog items. "

    ^font notNil ifTrue: [ font ] ifFalse: [ SysFont ]! 
itemIndexFromPoint: aPoint
        "Answer the index of the element under aPoint
        (where aPoint is relative to the receiver window).
        Code from ListBox.  Need to use rectangle extent."
    | top index offsetFromTop |

    offsetFromTop := ( (0 @ 0 extent: (self rectangle extent)) top - aPoint y ) abs.
    top := self getTopIndex.
    index := top + ( offsetFromTop // self itemHeight ).
    ^index!   
buildDialogItem: parentHandle
        "Private - Build the dialog item window for the receiver.
        Note - The dialog item was created using
        WINCREATEDLG API call."

    super buildDialogItem: parentHandle.
    graphicsTool isNil
       ifTrue: [ graphicsTool := self getGraphicsTool ]! 
saveSelection
        " Private "
    1 to: list size do: [ :i |
        (radioButtons at: i) value
            ifTrue: [
                selection := ( returnItems
                    ifTrue: [ list at: i ]
                    ifFalse: [ i ] ).
                ^self ] ].! 
openOn: aList selection: initialSelection
        " Open a list dialog displaying aList with
        no separators. "
    ^self
        openOn: aList
        separators: #()
        selection: initialSelection!  
insertItem: item at: index
        "Insert the given item into the list (and the host control)
        at the given position."

    super insertItem: item at: ( self realIndexAt: index )!   
getSelection
        "Private - Answer the selection."

    ^value := ( self controlToItemIndex: super getSelection ).!
widthInDialogUnits: widthInPoints
        " Private - answer widthInPoints as a width in
        in dialog box units, rounded up to the next
        character box boundary. "

    | charWidthPts nChars |
    charWidthPts := WindowDialog dialogUnit x.
    nChars := widthInPoints // charWidthPts.
    ( widthInPoints \\ charWidthPts ) > 0
        ifTrue: [ nChars := nChars + 1 ].
    ^nChars * WindowDialog charWidth!   
initialize
        "Private - Initialize the receiver's instance variables "
    super initialize.
    self dragButton: self class defaultDragButton.
    userCanReorder := false.
    separatorString := '$#@!!'.!  
defaultDrawItem: aDrawStruct
         "Private - Draw the requested control item."

    ( self isSeparatorAt: ( aDrawStruct itemId + 1 ) )
        ifTrue: [ ^self defaultDrawSeparator: aDrawStruct ].

    self graphicsTool
        blank: aDrawStruct boundingBox;
        setTextAlign: 
            ( OperatingSystem isWin32
                ifTrue: [ 24 "TaBaseline" ]
                ifFalse: [ 1024 "TaBase" ]);
        place: ( aDrawStruct boundingBox bottomLeft up: self graphicsTool font descender );
        displayText: ( self stringForItem: ( list at: self drawIndex ))!
isIndexSelected: itemIndex
        "Private - answer whether itemIndex is selected."

    ^(( self isSeparatorAt:  self realSelection ) not and: [
        super isIndexSelected: itemIndex ])!   
saveSelection
        " Private "
    | listPane |
    listPane := self paneAt: self listPaneName.
    selection := (returnItems
        ifTrue: [listPane selectedItem]
        ifFalse: [listPane selectedIndex]).!   
openOn: aList selection: initialSelection
        " Open a list dialog displaying aList, with initialSelection
        as the initial selection. "
    | topPane |
    aList size = 0
        ifTrue: [ ^nil ].
    list := aList.
    selection := initialSelection.
    topPane := self createView.
    selection := nil.
    topPane openModal: pmOwner.
    ^selection!
validate
        " Private - Create or recreate the control "
    | myFont |

    self updateRectangle.

    userCanReorder == true ifTrue: [
        self
            dragSource;
            dragTarget.
        self dragTargetFormats isNil
            ifTrue: [ self dragTargetFormats: #( 'string' ) ].
        self dragTargetOperations isNil
            ifTrue: [ self dragTargetOperations: #( #move )].
        ].

    OperatingSystem name = 'OS/2'
        ifTrue: [
        "Since colors are now set by presParam on OS/2, need to sync with pen"
        self pen backColor:
            (self backColor isNil
                ifTrue: [ self defaultBackColor ]
                ifFalse: [ self backColor ] ).
        self pen backColor:
            (self backColor isNil
                ifTrue: [ self defaultBackColor ]
                ifFalse: [ self backColor ] ).
        ].

    super validate isNil ifTrue: [^nil].

    self userItemHeight isNil
        ifTrue: [
            ( myFont := self font ) isNil
                ifTrue: [ myFont := self defaultFont ].
            self itemHeight: myFont height ]
        ifFalse: [
            self itemHeight: self userItemHeight ]!
initialize
        " Private - initialize the class "

    self 
		initializeEventsTriggered;
		initializeNotifications.!
controlToItemIndex: controlIndex
    " Private -
    <controlIndex> is a position in the control including separators.
    Answer the position of the item at <controlIndex> in the receiver's
    list excluding separators.  If <controlIndex> is a separator,
    answer the next index."
    | queryControlIndex precedingSeparators |

    controlIndex isNil ifTrue: [ ^nil ].
    queryControlIndex :=
        ( self isSeparatorAt: controlIndex )
            ifTrue: [ controlIndex + 1 ]
            ifFalse: [ controlIndex ].

    precedingSeparators := 0.
    1 to: queryControlIndex - 1 do: [ :aControlIndex |
        ( self isSeparatorAt: aControlIndex )
            ifTrue: [ precedingSeparators := precedingSeparators + 1 ]].

    ^queryControlIndex - precedingSeparators! 
setSelection
        "Private - set the selection in the listbox control
        to correspond to value.  Assumes 'handle = NullHandle'
        is false."
    | oldValue |

    oldValue := value.
    value notNil
        ifTrue: [  value := self realIndexAt: value ].
    super setSelection.
    value := oldValue!  
userItemHeight
    "Answer the height specified by the user for
    user specified owner drawn items."

    ^self propertyAt: #userItemHeight!
extentForButton: aButtonLabel
        " Private - measure button and add white space around label "

    | charWidthDlg x y |
    charWidthDlg := WindowDialog charWidth.  " dialog units "
    self font = SysFont
        ifTrue: [
            x := aButtonLabel size * charWidthDlg.
            y := WindowDialog charHeight ]
        ifFalse: [
            x := self class widthInDialogUnits:
                ( self font stringWidth: aButtonLabel ).
            y := self class heightInDialogUnits: self font height ].
    ^( x + ( 2 * charWidthDlg ) )
    @ ( y + charWidthDlg )!  
button2Move: aPoint
    " Private - Right-button drag. "
    | start |

	userCanReorder
		ifFalse: [ ^self ].
    self dragButton = #button2
        ifFalse: [ ^self ].
    ( start := self dragStart ) isNil
        ifTrue:[ ^self ].
    ((aPoint - start ) abs < self class dragSourceSensitivity)
        ifTrue: [^self].

    self doDragDropAt: start.! 
cleanUpSeparators
        "Remove adjacent separators move the currentSelection forward
    if delete item before it."
    | currentListIndex |

    currentListIndex := 0.
    [ currentListIndex < list size ]
        whileTrue: [
            ( self isSeparatorAt: currentListIndex )
                ifTrue: [
                    currentListIndex := currentListIndex + 1.
                    ( self isSeparatorAt: currentListIndex )
                        ifTrue: [
                            super deleteIndex: currentListIndex ]]
                ifFalse: [
                    currentListIndex := currentListIndex + 1 ]].
    "Clean up separators at the ends"
    ( self isSeparatorAt: 1 )
        ifTrue: [ super deleteIndex: 1 ].
    ( self isSeparatorAt: list size )
        ifTrue: [ super deleteIndex: list size ].!   
openOn: aList
        " Open a list dialog displaying aList.
        Default is to select the first entry. "
    ^self openOn: aList selection: 1! 
createListItemsIn: aTopPane startingAt: initialDeltaLeftTop
        " Private - create the visual items representing
        the list.  Answer the extent. "

    | lineHeight totalExtent itemExtent deltaLeftTop
      aRadioButton selectedIndex |

    lineHeight := WindowDialog charHeight + 1.
    totalExtent :=
        ( self listWidthDlg: list )
        @ (list size  * lineHeight).
    itemExtent := totalExtent x @ lineHeight.

    deltaLeftTop := initialDeltaLeftTop.
    radioButtons := Array new: list size.
    1 to: list size do: [ :i |
        aTopPane addSubpane:
            ( (aRadioButton := RadioButton auto)
                font: self font;
                label: (list at: i);
                framingBlock:
                    (self framingBlock: deltaLeftTop extent: itemExtent) ).
        radioButtons at: i put: aRadioButton.
        deltaLeftTop :=
            deltaLeftTop x
            @ (deltaLeftTop y + itemExtent y).
        ].
    selectedIndex := ( selection isInteger
        ifTrue: [ selection ]
        ifFalse: [ list indexOf: selection ifAbsent: [ 1 ] ] ).
    (radioButtons at: selectedIndex) value: true.
    ^totalExtent!   
openOn: aList
        " Open a multi-select list dialog displaying aList.
        Default is to select none of the entries."
    ^self openOn: aList selection: Array new! 
textLines: oneOrMoreStrings
        " Specify one or more strings to be displayed
        at the top of the window. "
    textLines := (oneOrMoreStrings isString
        ifTrue: [Array with: oneOrMoreStrings]
        ifFalse: [oneOrMoreStrings]).!  
dragButton: aSymbol
        " Specify whether drag is supported with #button1 or #button2 "

    dragButton := aSymbol.!   
contents: anItemCollection
    "Set the receiver's contents to <anItemCollection>.
    Retain the separators from any previous list."
    | separatorCollection currentItemIndex |

    "Separators already specified in the collection"
    ( anItemCollection isNil or: [
        ( anItemCollection detect: [ :each | each = separatorString ]
        ifNone: [ nil ])]) notNil
        ifTrue: [ ^super contents: anItemCollection ].

    separatorCollection := OrderedCollection new.
    currentItemIndex := 0.
    1 to: list size - 1 do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifFalse: [ "Found an item"
                currentItemIndex := currentItemIndex + 1.
                ( self isSeparatorAt: aListIndex + 1 )
                    ifTrue: [ separatorCollection add: currentItemIndex ]]].

    separatorCollection notEmpty
        ifTrue: [
            self contents: anItemCollection separators: separatorCollection ]
        ifFalse: [
            super contents: anItemCollection ].!
itemAt: queryItemIndex
    "<queryItemIndex> is an index into a list without separators.
    Answer the item at this index."
    | itemIndex |

    itemIndex := 0.
    1 to: list size do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifFalse: [
                itemIndex := itemIndex + 1.
                itemIndex = queryItemIndex
                    ifTrue: [ ^list at: aListIndex ]]].
    ^nil!
button2Down: aPoint
	"Private - Remember where the possible drag started."

	self dragButton = #button2
		ifTrue: [ self dragStart: aPoint ].

    ^super button2Down: aPoint!  
dragSourceCutDefault: dragSession
        "Private - provide default source cut if no handler is provided
        by removing the selected element from contents."
    | c selectedIndex cutIndex topIndex |
    topIndex := self getTopIndex.

    cutIndex := self dragSourceSelection.
    c := list asOrderedCollection.
    c removeIndex: cutIndex.
    self contents: c asArray.
    dragSession target == self
        ifTrue: [
            selectedIndex := "self selectedIndex" value.
            cutIndex < selectedIndex ifTrue: [ selectedIndex := selectedIndex - 1 ].
            self selectIndex: selectedIndex ]
        ifFalse: [ self deselect ].
    self cleanUpSeparators.
    self setTopIndex: topIndex! 
dragButton
        " Private "

    ^dragButton!   
realSelectIndex: controlIndex
    "Select the item at controlIndex. Index starts at 1.
    Don't change value as a side effect."
    | oldIndex |
    oldIndex := value.
    value := self controlToItemIndex: controlIndex.
    self isHandleOk
        ifTrue: [
            self setSelection.
            value := oldIndex ].!  
computeMaxEntriesToShowFor: aList in: aListPane
        " Private - adjust maxEntriesToShow if necessary,
        to ensure that this guy fits on the screen. "

    | availableLines |
    maxEntriesToShow := maxEntriesToShow isNil
        ifTrue: [ self defaultMaxEntriesToShow ]
        ifFalse: [ self numListEntries min: maxEntriesToShow ].
    availableLines :=
        ( Display height // self font height )
        - 7 " borders, title bar, buttons, internal margins"
        - textLines size.  " description text "
    maxEntriesToShow := maxEntriesToShow min: availableLines.!  
pmOwner: aWindow
        " Set the owner of a modal dialog.  Should not
        generally be needed. "
    pmOwner := aWindow.!
selection
    "Answer the index of the item selected.
    The index is into a list without separators."

    self isHandleOk "Virtual control special case."
        ifTrue: [ ^super selection ].
    ^self controlToItemIndex: super selection!   
buildWindow: aParentWindow
        "Private - In Windows, we need to set the item
        height before the control is created."
    | currentFont |
    OperatingSystem isWin32
        ifTrue: [
            ( currentFont := self font ) isNil
                ifTrue: [ currentFont := self defaultFont ] .
            self itemHeight: currentFont height].
    ^super buildWindow: aParentWindow! 
font: aFont
    "Set the font for the receiver to aFont.  Set the
    receiver's item height based on the font."

    super font: aFont.
    self isHandleOk
        ifTrue: [ self setGraphicsFont: aFont ]
        ifFalse: [ self whenValid: #setGraphicsFont: with: aFont ].
    self itemHeight: ( self userItemHeight notNil
        ifTrue: [ self userItemHeight ]
        ifFalse: [ aFont height ]).! 
defaultMaxEntriesToShow
        " Private "
    ^10!
font: aFont
        " Specify the font to use for the dialog items. "

    font := aFont.! 
separators
    "Answer the separators, an OrderedCollection of
    increasing integers.  A separator index is represents
    the item index which the separator appears after.  Separators
    are not included in the item indices."
    | separatorCollection separatorCount |

    separatorCollection := OrderedCollection new.
    separatorCount := 0.

    1 to: (list size - 1) do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifTrue: [
                separatorCollection add: aListIndex - 1 - separatorCount.
                separatorCount := separatorCount + 1 ]].

    ^separatorCollection!
dragSourceSensitivity
        "Private - answer a Point which tunes drag-drop sensitivity:
        moving more than the x or y component of this point while
        the drag button is down initiates a drag-drop."
    ^3@3!
initialize
        " Private "
    super initialize.
    minEntriesToShow := 1.
    returnItems := true.! 
listPaneName
        " Private "
    ^'listPane'!   
isSeparatorAt: queryControlIndex
    " Private - Answer whether there is a separator in
    the control's list at <queryControlIndex>
        The list cannot start or end with a separator and separators
    must have at least one list item between them."

    ( queryControlIndex isNil or: [
        queryControlIndex < 1 or: [
        queryControlIndex > list size ]])
        ifTrue: [ ^false ].

    ^( list at: queryControlIndex ) = separatorString!  
numListEntries
        " Private "
    ^list size!  
dragSourceNeedsObject: dragSession
        "Private - retrieve the object to be dragged."
    | result |
    result := super dragSourceNeedsObject: dragSession.
    self dragSourceSelection: self realSelection.
    ^result!  
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
    width := width + ( 4 * charWidth ).  " radio button special value "
    ^width! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    separatorString isNil ifTrue: [ separatorString := '$#@!!' ].
    ^super fileInUpgrade: anObjectFiler! 
dragStart
    "Answer the point where the a drag session
    started on the receiver."

	^self propertyAt: #dragStart!
isDragButton: anInteger
        "Answer whether the mouse button index identified by anInteger
        is a button that initiates a drag transfer on this host."

	^true! 
initWindowSize
        " Answer the initial window extent of the client
        area in dialog box units. "
    ^clientExtentDlg!  
deleteItem: anItem
        "Delete anItem from the receiver's list."

    super deleteItem: anItem.
    self cleanUpSeparators.!  
createListItemsIn: aTopPane startingAt: deltaLeftTop
        " Private - create the visual items representing
        the list.  Answer the extent. "
    | aListPane anExtent |
    aListPane := self newListPane.  " sets contents "
    anExtent := self extentForList: list in: aListPane.
    aTopPane addSubpane:
        (aListPane
            setName: self listPaneName;
            selection: selection;
            when: #doubleClicked:
                send: #doubleClickedList to: self;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: anExtent)).
    ^anExtent! 
minEntriesToShow: anInteger
    minEntriesToShow := anInteger!   
heightInDialogUnits: heightInPoints
        " Private - answer heightInPoints as a height in
        in dialog box units, rounded up to the next
        character box boundary. "

    | charHeightPts nLines |
    charHeightPts := WindowDialog dialogUnit y.
    nLines := heightInPoints // charHeightPts.
    ( heightInPoints \\ charHeightPts ) > 0
        ifTrue: [ nLines := nLines + 1 ].
    ^nLines * WindowDialog charHeight!
addSeparator: aSeparatorIndex
    "Add <aSeparatorIndex> to the separators. <aSeparatorIndex>
    is an index into a list of items, excluding separators."
    | currentItemIndex |

    currentItemIndex := 0.
    1 to: list size - 1 do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifFalse: [
                currentItemIndex := currentItemIndex + 1.
                currentItemIndex = aSeparatorIndex
                    ifTrue: [
                        ( self isSeparatorAt: currentItemIndex + 1 )
                            ifTrue: [ ^self "Already exists" ]
                            ifFalse: [
                                ^self realInsertItem: separatorString at: aListIndex + 1 ]]]]! 
defaultDrawSeparator: aDrawStruct
         "Private - Draw the requested control item."

    graphicsTool
        blank: aDrawStruct boundingBox;
        place: ( aDrawStruct boundingBox leftTop
            down: ( aDrawStruct boundingBox height // 2 ) );
        direction: 0;
        go: aDrawStruct boundingBox width.! 
doubleClickedList
        " Private - double click on list item is equivalent to OK "
    self ok!  
isIndexInList: itemIndex
        "Private - answer whether itemIndex is a valid index."

    ^super isIndexInList: ( self realIndexAt: itemIndex )!
installLibrary
        " Install the list-choice dialogs library "

    ExtendedListBox initialize.!   
doubleClickedList
        " Private - double click on list item is ignored in multi-select guy "!
deleteControlIndex: index
    "Delete index from the control list."

    super deleteIndex: index.
    self cleanUpSeparators.!   
button1Down: aPoint
	"Private - Remember where the possible drag started."

	self dragButton = #button1
		ifTrue: [ self dragStart: aPoint ].

    ^super button1Down: aPoint!  
listPaneClass
        " Private " 
    ^ExtendedListBox!
extentForLabel: aLabel
        " Private - measure aLabel "

    self font = SysFont
        ifTrue: [
            ^(aLabel size * WindowDialog charWidth)
            @ WindowDialog charHeight ]
        ifFalse: [
            ^( self class widthInDialogUnits: ( self font stringWidth: aLabel ) )
            @ ( self class heightInDialogUnits: self font height ) ].!   
userItemHeight: anInteger
    "Set the height specified by the user for
    user specified owner drawn items."

    self itemHeight: anInteger.
    self propertyAt: #userItemHeight put: anInteger! 
list: aPane
        " Nop - contents are set at pane creation time. "
    "DEBUG"!  
saveSelection
        " Private - user selected zero or more entries "
    | listPane |
    listPane := self paneAt: self listPaneName.
    selection := (returnItems
        ifTrue: [listPane selectedItems]
        ifFalse: [listPane selections]).!
deleteIndex: index
        "Delete item number index from the list."

    super deleteIndex: ( self realIndexAt: index ).
    self cleanUpSeparators.!
button1Move: aPoint
    " Private - Left-button drag. "
    | start |

	userCanReorder
		ifFalse: [ ^self ].
    self dragButton = #button1
        ifFalse: [ ^self ].
    ( start := self dragStart ) isNil
        ifTrue:[ ^self ].
    ((aPoint - start ) abs < self class dragSourceSensitivity)
        ifTrue: [^self].

    self doDragDropAt: start!   
drawBox
        "Answer the bounding box of the item to be drawn."

    OperatingSystem name = 'OS/2'
        ifTrue: [ ^super drawBox moveBy: (( 0 @ 0 ) up: self graphicsTool font descender ) ].
    ^super drawBox!  
selectedItem
        "Answer the item selected in the listbox."

    ^self itemAt:  self selection.!   
setPresParams
        "Private - set the font and colors for the receiver."
    self
        font: self font;
        initColors! 
extentForList: aList in: aListPane
        " Private - answer the size in dialog box units
        for aList. "

    self computeMaxEntriesToShowFor: aList in: aListPane.
    ^( self listWidthDlg: aList )
    @ ( self listHeightDlg: aList in: aListPane )! 
createView
        " Private - create the window.
        Window sizing is done in dialog box units. "
    | charWidthDlg marginDlg topPane
      deltaLeftTop deltaTopLeft2 deltaLeftMarginX
      internalWidthDlg anExtent |

    charWidthDlg := WindowDialog charWidth.
    "lineHeightDlg := WindowDialog charHeight."
    marginDlg := charWidthDlg.

    self addView:
        (topPane := self topPaneClass new
            owner: self;
            labelWithoutPrefix: title;
            "when: #cancelled send: #cancelled to: self;"
            yourself ).
    deltaLeftMarginX := marginDlg.
    deltaLeftTop := deltaLeftMarginX @ marginDlg.
    internalWidthDlg := self titleBarWidth: title.

    " create static text items for any text lines "
    textLines notNil ifTrue: [
        textLines do: [ :text |
            anExtent := self extentForLabel: text.
            topPane addSubpane:
                (StaticText new
                    font: self font;
                    contents: text;
                    framingBlock:
                        (self framingBlock: deltaLeftTop
                            extent: anExtent)).
            internalWidthDlg := internalWidthDlg max: anExtent x.
            deltaLeftTop :=
                deltaLeftMarginX
                @ (deltaLeftTop y + anExtent y)].
        deltaLeftTop :=   " vertical white space below text lines "
            deltaLeftMarginX
            @ (deltaLeftTop y + marginDlg).
        ].

    " the list "
    anExtent := self
        createListItemsIn: topPane
        startingAt: deltaLeftTop.
    internalWidthDlg := internalWidthDlg max: anExtent x.
    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + anExtent y + marginDlg).

    " OK and Cancel buttons "
    anExtent := self extentForButton: 'Cancel'.
    deltaTopLeft2 :=
        (deltaLeftMarginX + anExtent x + marginDlg)
        @ deltaLeftTop y.
    topPane addSubpane:
        (Button new
            defaultPushButton;
            font: self font;
            contents: 'OK';
            when: #clicked send: #ok to: self ;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: anExtent)).
    topPane addSubpane:
        (Button new
            pushButton;
            font: self font;
            contents: 'Cancel';
            when: #clicked send: #cancel to: self ;
            framingBlock:
                (self framingBlock: deltaTopLeft2 extent: anExtent)).
    internalWidthDlg := internalWidthDlg max:
        ((2 * anExtent x) + marginDlg).

    clientExtentDlg :=
        (internalWidthDlg + (2 * marginDlg))
        @ (deltaLeftTop y + anExtent y + marginDlg).
    ^topPane!   
numListEntries
        " Private - rough estimate: separator consumes an entry "
    ^list size + separators size!  
returnItems: aBoolean
        " Specify whether to return selection as item or index. "
    returnItems := aBoolean.!   
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
doDragDropAt: aPoint
        "Private - start a drag drop transfer with the receiver as the source.
    Override the default drag button settings for this drag.  Use an
    impossible button for extended drag to disable it.  (nil only means
    use default)"
    | index oldExtIndex oldDragIndex button |

    index := self itemIndexFromPoint: aPoint.
    ( self isSeparatorAt: index )
        ifTrue: [ ^self ].
    self realSelectIndex: index.
    button := self dragButton = #button1 ifTrue: [ 1 ] ifFalse: [ 2 ].
    [   oldDragIndex := DragDropSession dragButtonIndex.
        oldExtIndex := DragDropSession extendedDragButtonIndex.
        DragDropSession
            dragButtonIndex: button;
            extendedDragButtonIndex: 4.
        self
            doDragDropAt: self dragStart
            button: button ]
        ensure: [
            self dragSourceSelection: nil.  "Used during drag scroll selection highlight"
            DragDropSession
                dragButtonIndex: oldDragIndex;
                extendedDragButtonIndex: oldExtIndex ].! 
userCanReorder: aBoolean
        "Set userCanReorder to aBoolean.  If true, the user
        can drag the items and change the
        order of the items."

    userCanReorder := aBoolean.!
listPaneClass
        " Private "
    ^MultipleSelectListBox!   
removeSeparator: separatorIndex
    "Delete the separator position from the control."
    | currentItemIndex |

    currentItemIndex := 0.
    1 to: list size - 1 do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifFalse: [ "An item"
                currentItemIndex := currentItemIndex + 1.
                currentItemIndex = separatorIndex
                    ifTrue: [ "Found the item whose following item is a separator"
                        ( self isSeparatorAt: aListIndex + 1 )
                            ifTrue: [ ^self deleteControlIndex: aListIndex + 1 ]
                            ifFalse: [ ^nil "Separator not found at <separatorIndex>" ]]]]!
listHeightDlg: aList in: aListPane
        " Private - answer the height in dialog units "

    | numEntries visibleSeparators numSeparators height |

    separators size = 0
        ifTrue: [ ^super listHeightDlg: aList in: aListPane  ].

    numEntries := aList size min: maxEntriesToShow.
    visibleSeparators := separators collect: [ :index |
        index < numEntries ].
    numSeparators := visibleSeparators size.
    ( ( numEntries < aList size ) and: [ numSeparators > 0 ] )
        ifTrue: [ numEntries := numEntries - numSeparators ].
    height :=    " calc in points to minimize roundoff problems "
        ( numEntries * self font height )
        + ( numSeparators * aListPane separatorHeight ).
    ^self heightInDialogUnits: height!  
realIndexAt: queryItemIndex
    " Private - Answer the index in the control listbox.
    <queryItemIndex> is the index in a list excluding
    separators "
    | itemCount |

    itemCount := 0.
    1 to: list size do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifFalse: [
                itemCount := itemCount + 1.
                itemCount = queryItemIndex
                    ifTrue: [ ^aListIndex ]]].
    ^0!   
titleBarWidth: aString
        " Private - answer the width of a titleBar containing
        a system menu and aString (dialog box units). "
    ^(aString size + 4) * WindowDialog charWidth    " approximate sysMenu width "!
cancel
        " Private - user pressed Cancel button "

    self close.!  
contents
        "Answer the list contents of the receiver.
    This does not include separators."

    ^list isNil
        ifTrue: [ nil ]
        ifFalse: [ list reject: [ :each | each = separatorString ]]!
itemHeight: anInteger
        " Private - Save the receiver's item height "

    anInteger notNil
        ifTrue: [ super itemHeight: anInteger ].!   
highlightInfoWindows: itemId drawBox: rect
    "Private - Windows selection logic tries to select item
    under mouse.  Answer an adjusted item index and
    draw rect for highlighting the orginal drag selection.
    Answer nil items if the selection is outside the control."
    | newRect newIndex dragSourceIndex |

    (( dragSourceIndex := self dragSourceSelection ) notNil
        and: [ self dragButton = #button1 ])
        ifTrue: [ "Dragging"
            self getTopIndex > dragSourceIndex  "Scrolled off the control"
                ifTrue: [
                    newRect := nil.
                    newIndex := nil ]
                ifFalse: [
                    itemId ~= dragSourceIndex
                        ifTrue: [  "Scrolling - Parameters specify a select drag.  Recalculate"
                            newRect :=
                                rect moveBy:
                                    0 @ ( rect height * ( dragSourceIndex - itemId  )).
                            newIndex := dragSourceIndex ]
                        ifFalse: [  "Not scrolling, everything ok"
                            newRect := rect.
                            newIndex := itemId ]]]
        ifFalse: [  "Not dragging"
            newRect := rect.
            newIndex := itemId ].

    ^Array with: newIndex with: newRect! 
newListPane
        " Private - answer an initialized list pane. "
    ^self listPaneClass new
        font: self font;
        contents: list;
        yourself!
heightInDialogUnits: heightInPoints
        " Private - answer heightInPoints as a height in
        in dialog box units, rounded up to the next
        character box boundary. "
    | charHeightPts nLines |
    charHeightPts := WindowDialog dialogUnit y.
    nLines := heightInPoints // charHeightPts.
    (heightInPoints \\ charHeightPts) > 0
        ifTrue: [nLines := nLines + 1].
    ^nLines * WindowDialog charHeight!  
framingBlock: deltaLeftTop extent: extent
        " Private - answer the framing block for
        a window whose leftTop corner is deltaLeftTop
        from the upper left of the dialog window
        with extent. "
    ^[ :box |
        (box leftTop rightAndDown: deltaLeftTop)
        extentFromLeftTop: extent]!
separators: anOrderedCollection
        "Set the separators of the reciever.  anOrderedCollection is an
        anOrderedCollection of integers specifying indicies of items which
        are to have a separator line below them."
    | separatorCollection listCollection |

    separatorCollection :=
        ( anOrderedCollection class == OrderedCollection
            ifTrue: [ anOrderedCollection ]
            ifFalse: [
                OrderedCollection new    addAllFirst: anOrderedCollection; yourself ] )
        reversed.

    listCollection := list asOrderedCollection.
    self isHandleOk ifTrue: [ self disableRedraw ].
        "Delete old separators"
    list size to: 1 do: [ :aListIndex |
        ( self isSeparatorAt: aListIndex )
            ifTrue: [ listCollection removeIndex: aListIndex ]].
        "Insert new separators"
    separatorCollection do: [ :aSeparatorIndex |
        listCollection add: separatorString afterIndex: aSeparatorIndex ].
    listCollection last = separatorString
        ifTrue: [ listCollection removeLast ].

    list := listCollection asArray.

    self isHandleOk ifTrue: [ self invalidateRect: nil; enableRedraw ].!