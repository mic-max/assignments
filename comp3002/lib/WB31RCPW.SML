"3.0.0.14"
! 

GroupPane subclass: #CompositePane
  instanceVariableNames: 
    ' initialSize '
  classVariableNames: ''
  poolDictionaries: 
    ' CharacterConstants OperatingSystemConstants VirtualKeyConstants '!

CompositePane subclass: #EntryFieldGroup
  instanceVariableNames: 
    ' label dictionary '
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!

CompositePane subclass: #RadioButtonGroup
  instanceVariableNames: 
    ' label list numColumns selection '
  classVariableNames: ''
  poolDictionaries: ''!

CompositePane subclass: #SexPane
  instanceVariableNames: 
    ' sex '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '!  

EntryField subclass: #WBEntryField
  instanceVariableNames: 
    ' justSet '
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!   

RadioButtonGroup subclass: #CheckBoxGroup
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

!CompositePane class methods ! 
isScratchWindow

    ^false! !

!CompositePane methods !  
mdiToolBarBordered
        "Private"
    self addBorderStyle.
    self framingBlock: nil.
    self framingBlock: [ :box |
        Rectangle leftTopUnit rightBottom: (box width @ initialSize y) ].
    self propertyAt: #cpStyle put: #mdiToolBarBordered.! !

!CompositePane methods !  
framingBlock: aBlock

    ((self framingBlock isNil or: [self framingBlock isContext | self framingBlock isBlockClosure]) and: [
    (self cpStyle == #mdiToolBar or: [self cpStyle == #mdiToolBarBordered]) not])
        ifTrue: [super framingBlock: aBlock].
    aBlock isNil
        ifTrue: [super framingBlock: aBlock]
        ifFalse: [initialSize := (aBlock value: Display boundingBox) extent].! !

!CompositePane methods !
setPopupMenu: aMenu
    super setPopupMenu: aMenu.
    self children do: [ :child |
        child getPopupMenu isNil ifTrue: [
            child setPopupMenu: aMenu
        ].
    ].! !

!CompositePane methods !   
mdiToolBar
        "Private"
    self framingBlock: nil.
    self framingBlock: [ :box |
        Rectangle leftTopUnit rightBottom: (box width @ initialSize y) ].
    self propertyAt: #cpStyle put: #mdiToolBar.! !

!CompositePane methods !
amountToPageLeft
        "Private - Answer the number of pixels for
         horizontal page scrolling."
    ^64! !

!CompositePane methods !
pStyle
		"Obsolete - Answer the receiver's p-widget style."
    ^#(#composite)! !

!CompositePane methods !   
cpStyle
		"Obsolete - Answer the receiver's style."
    ^self propertyAt: #cpStyle! !

!CompositePane methods !   
addSubpanes
    "Does nothing - overriden by subclasses"! !

!CompositePane methods !  
totalLength
        "Private - Answer the height of the receiver's graphics medium."
    ^rectangle height! !

!CompositePane methods !   
updateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollBar."
    self updateHorizontalSliderTo: self topCorner x.! !

!RadioButtonGroup methods !
font: aFont
	"Set the font for the reciever AND all its children."

	super font: aFont.
	self groupBoxFont: aFont.
	self buttonFont: aFont.! !

!CompositePane methods !   
verticalScrollBar
        "Obsolete - Add the vertical scroll bar style to the receiver.
            Use addVerticalScrollbarStyle instead."
    self
        addBorderStyle;
        addVerticalScrollbarStyle.! !

!SexPane methods !
contents: aSymbol
		"Set the sex of the widget. Allowable values are #male and #female."
    self sex: aSymbol! !

!CompositePane methods !   
charsInRow
        "Private - Answer the receiver frame width."
    ^rectangle width! !

!CompositePane methods ! 
setFocus
		"Set focus to one of the receiver's children."
    self children isEmpty ifFalse: [
        self nextTabStop setFocus
    ].! !

!CompositePane methods !
contents
	"Answer the value of the receiver.
	 This should be overriden in subclasses"
	^nil! !

!CompositePane methods !
initGraphics
        "Private - Initialize the graphics tool for the receiver"
    | backColor |
    ( backColor := self backColor ) isNil ifTrue: [
        ( backColor := self superWindow backColor ) isNil ifTrue: [
            backColor := self class defaultBackColor ] ].
    self backColor: backColor.
    ^super initGraphics
! !

!RadioButtonGroup methods !  
indexOf: aString

    "Answer the index of the item aString."

    list isNil ifTrue: [ ^nil ].
    ^list indexOf: aString! !

!EntryFieldGroup methods !  
noGroupBox
		"Sets the style of the widget to not include a surrounding GroupBox."
    self propertyAt: #cpStyle put: #noGroupBox! !

!CompositePane methods !
value: anObject
	"Set the value of the receiver.
	 This should be overriden in subclasses"
	self contents: anObject! !

!CheckBoxGroup methods ! 
buttonClass
		"Returns the Button subclass to be used within the widget.
			CheckBoxGroup can easily be subclassed to use a different button
			class (such as the CP3DCheckBox provided in Subpanes/V)."
    ^CheckBox! !

!CompositePane methods !
scrollTopCornerTo: aNewCorner
        "Private - Scroll topCorner to aNewCorner"
    self scrollTopCorner: self topCorner - aNewCorner! !

!RadioButtonGroup methods !
list: aCollection
		"Set the labels of the buttons within the group. The number of
			buttons is determined by the size of aCollectionOfStrings.
			Note: This method may only be used before the window is opened."
    ^self contents: aCollection! !

!EntryFieldGroup methods ! 
setLabelFont: aFont
		"Sets the font of the StaticText labels to aFont."
    (self children select: [:pane | pane class == StaticText ]) do: [:field | field font: aFont].
    self update! !

!SexPane methods !
setMale: ignore
        "Private"
    self sex: #male.
    self event: #setToMale. "Obsolete"
    self triggerEvent: #setToMale.
! !

!EntryFieldGroup class methods ! 
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #textChanged:pane:;
        yourself! !

!EntryFieldGroup methods ! 
addVerticalScrollbarStyle
        "Add the vertical scroll bar style to the receiver."
    super addVerticalScrollbarStyle.
    self propertyAt: #cpStyle put: #verticalScrollBar! !

!CompositePane methods !   
scrollTopCornerUnlimited: aPoint
	"Private - Scroll the top corner by aPoint."

	topCorner - aPoint = topCorner ifFalse: [
	   topCorner := topCorner - aPoint.
		( UserLibrary scrollWindow: handle
			xAmount: aPoint x
			yAmount: aPoint y
			lpRect: nil
			clipRect: nil )
				ifFalse: [ ^self osError ].
		self updateSliders ].! !

!CompositePane methods !
display
		"Private - Display the receiver."
    self doGraphics: [
        self pen fill: self rectangle color: self backColor
    ].
    super display.! !

!CompositePane methods !  
amountToPageUp
        "Private - Answer the number of pixels for
         vertical page scrolling."
    ^64! !

!EntryFieldGroup methods !  
label
		"Answer the text label of the GroupBox surrounding the widget."
    ^label ifNil: [ label := '' ]! !

!RadioButtonGroup methods ! 
foreColor: aColor
		"Set the foreground color of the receiver and all buttons."
    super foreColor: aColor.
    self children do: [ :child | child foreColor: aColor ].! !

!CompositePane methods !
setScrollRanges
        "Private - Set the ranges for the horizontal and vertical
          scroll bars."
    | rangeRect minHorz maxHorz minVert maxVert |
    rangeRect := self scrollingRectangle.
    minHorz := rangeRect left.
    maxHorz := rangeRect right.
    minVert := rangeRect top.
    maxVert := rangeRect bottom.
    (self style bitAnd: WsHscroll) = 0
        ifTrue: [minHorz := maxHorz := 0].
    (self style bitAnd: WsVscroll) = 0
        ifTrue: [minVert := maxVert := 0].
    ( UserLibrary
        setScrollRange: self asParameter
        bar: SbHorz
        min: minHorz
        max: maxHorz
        redraw: false )
            ifFalse: [ ^self osError ].
    ( UserLibrary
        setScrollRange: self asParameter
        bar: SbVert
        min: minVert
        max: maxVert
        redraw: false )
            ifFalse: [ ^self osError ]! !

!RadioButtonGroup methods !  
numColumns
		"Answer the number of columns in the group."
    ^numColumns ifNil: [ numColumns := 1 ].! !

!CompositePane methods !
initialTopCorner
        "Private - answer the initial value of topCorner."
    ^0@0! !

!CompositePane class methods !   
supportedEvents

    ^Set with: #getContents.! !

!CompositePane methods !
update
		"Private - Refresh the contents from the
		 owner and display it."
	((self handlesEvent: #getContents)
	or: [( self hasActionForEvent: #needsContents)])
		ifTrue: [ super update ]
		ifFalse: [
			self children do: [ :child | child update ]].! !

!SexPane methods !
contents
		"Return the sex of the widget. Allowable values are #male and #female."
    ^self sex! !

!WBEntryField methods !  
notifyTextChanged: aParameter
        "Private - Prevent the textChanged message from
         happening when the contents is set."
	#osiHack.
	"Need to test this..."
    justSet notNil ifTrue: [
		justSet = self contents ifTrue: [
			justSet := nil.
			^self ].
		justSet := nil ].
	^super notifyTextChanged: aParameter! !

!CompositePane methods ! 
borders
		"Obsolete - Add borders to the receiver.
			Use addBorderStyle instead."
    self addBorderStyle.! !

!CheckBoxGroup methods ! 
unSelectIndex: index
		"Unselect the button at the specified index."
    (self children detect: [ :child | index = (child propertyAt: #index)]) selection: false! !

!CheckBoxGroup methods ! 
setRadio: aBoolean pane: aPane
        "Private"
    selection := aPane propertyAt: #index.
    self event: #select. "Obsolete"
    self triggerEvent: #clicked: with: (self contents at: selection).
    self triggerEvent: #changedIndex: with: selection.
    self triggerEvent: #changedIndex:set: with: selection with: aBoolean.
! !

!CompositePane methods ! 
scrollHorizontal: anInteger
        "Private - Scroll the pane right by anInteger
         number of pixels (if positive) or left by
         the absolute value of anInteger (if negative)."
    self scrollTopCorner: anInteger  @ 0! !

!CompositePane methods ! 
wmHScroll: wordInteger with: longInteger
        "Private - Process a WM_HSCROLL message."
    | type pos w ctrlId |

	"If this is for a child, then pass it along..."
    longInteger = 0 ifFalse: [
        ctrlId := UserLibrary getWindowLong: longInteger index: GwlId.
        ( w := self childAtId: ctrlId ) isNil ifTrue: [ ^nil ].
        w syncControlEvent: wordInteger lowWord with: wordInteger highWord.
        ^nil ].

    type := wordInteger lowWord.

    type = SbLineup ifTrue: [
            (self horizontalScrollPos > self horizontalScrollMinRange) ifTrue:[
                 self scrollHorizontal: self amountToScrollLeft]].
    type = SbLinedown ifTrue: [
            (self horizontalScrollPos < self horizontalScrollMaxRange) ifTrue:[
                self scrollHorizontal: self amountToScrollLeft negated]].
    type = SbPageup ifTrue: [
            self scrollHorizontal: (self amountToPageLeft
                min: (self horizontalScrollPos - self horizontalScrollMinRange)) ].
    type = SbPagedown ifTrue: [
            self scrollHorizontal: (self amountToPageLeft
                min: (self horizontalScrollMaxRange - self horizontalScrollPos)) negated].
    type = SbThumbposition
        ifTrue: ["end of tracking"
            pos := wordInteger highWord.
            self updateHorizontalSliderTo: pos.
            self scrollHorizontal: self topCorner x - pos.
            ^nil].
    type = SbThumbtrack
        ifTrue: [^nil]
        ifFalse: [self updateHorizontalSlider].
    ^nil! !

!SexPane class methods ! 
supportedEvents
        "Private - Answer the events supported by this subpane."
    ^super supportedEvents
        add: #sexChanged;
        add: #setToMale;
        add: #setToFemale;
        yourself! !

!CompositePane methods !   
label
    ^''! !

!EntryFieldGroup methods !   
verticalScrollBar
        "Obsolete - Add the vertical scroll bar style to the receiver.
            Use addVerticalScrollbarStyle instead."
    self obsoleteMethod.
    super verticalScrollBar.
    self propertyAt: #cpStyle put: #verticalScrollBar! !

!RadioButtonGroup methods !   
noGroupBox
		"Set the no group box style."
    self propertyAt: #cpStyle put: #noGroupBox! !

!CompositePane class methods !  
defaultBackColor
        "Answer the default background color for the receiver class."
    ^Color windowBackground
! !

!CompositePane methods ! 
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsChild | WsVisible        "| WsClipsiblings"! !

!CheckBoxGroup methods ! 
selections
		"Answer the indices of the selected items."
    ^(self children asOrderedCollection select: [ :child |
        child class == self buttonClass and: [ child selection ]]) collect: [ :child |
            child propertyAt: #index ]! !

!RadioButtonGroup methods !   
buttonFont: aFont
	"Set the font of all of the reciever's buttons."

	self children do: [:each |
		each isGroupBox ifFalse: [
			each font: aFont]].! !

!RadioButtonGroup methods !   
addSubpanes
        "Private - Add the buttons to the receiver."
    | extent numRows index rb fontHeight inset inner |

    fontHeight := SysFont height + 6.

    self cpStyle isNil ifTrue: [
        self addSubpane: (
            self groupBoxClass new
                owner: self;
                framingBlock: (
                    LayoutFrame new
                        leftRatio: 0; leftInset: 0;
                        topRatio: 0; topInset: 0;
                        rightRatio: 1; rightInset: 0;
                        bottomRatio: 1; bottomInset: 0);
                paneName: 'group';
                startGroup;
                font: self font;
                contents: self label;
                yourself).
        inset := 8 @ fontHeight.
    ] ifFalse: [
        inset := 0 @ 0
    ].
    inner := initialSize - inset.
    numRows := ((self contents size +  self numColumns - 1) // self numColumns) max: 1.
    extent := (inner x // numColumns) @ fontHeight.
    1 to: self numColumns do: [:column |
        1 to: numRows do: [:row |
            index := (column - 1) * numRows + row.
            index > self contents size ifFalse: [
                self addSubpane: (
                   (rb := self buttonClass new)
                        owner: self;
                        propertyAt: #index put: index;
                        framingBlock: (
                            LayoutFrame new
                                leftRatio: ((column - 1) / self numColumns) * 0.9 + (((self numColumns - column + 1) / self numColumns) * 0.1); leftInset: 0;
                                topRatio: 0; topInset: (inset y + ((row - 1) * extent y));
                                rightRatio: (column / self numColumns) * 0.9 + (((self numColumns - column) / self numColumns) * 0.1); rightInset: 0;
                                bottomRatio: 0; bottomInset: (inset y + (row * extent y)) negated);
                        when: #clicked: send: #setRadio:pane: to: self withArgument: rb;
                        font: self font;
                        contents: (self contents at: index);
                        paneName: (self contents at: index);
                        tabStop;
                        yourself).
                index == 1 ifTrue: [rb startGroup].
          ].
        ].
    ].! !

!CompositePane methods !
changed: aFacet
		"Private - One aspect of the receiver has changed."
    | handler |
    (self children select: [ :child |
        handler := child handlers at: #getContents ifAbsent: [ nil ].
        handler notNil and: [ handler selector == aFacet ]]) do: [ :child |
        child update ].! !

!EntryFieldGroup methods !  
fieldClass
		"Returns the EntryField subclass to be used within the widget.
			EntryFieldGroup can easily be subclassed to use a different text entry
			class (such as the EnhancedEntryField)."
    ^WBEntryField! !

!SexPane class methods !
wbPartEventItems

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your wb-parts definition."

	#generated.
	^#(#rightClicked #setToFemale #setToMale #sexChanged: #tabbed)! !

!CompositePane methods !  
value
	"Answer the value of the receiver.
	 This should be overriden in subclasses"
	^self contents! !

!CompositePane methods ! 
open

	self children isEmpty ifTrue: [ self addSubpanesForWBParts ].
    self wbOldVersionSupport.
	self wbLinkPartEvents.
    self preInitWindow.
    graphicsTool notNil
        ifTrue: [graphicsTool release].
    super open.! !

!EntryFieldGroup methods !   
contents
		"Returns a dictionary that represents the contents of the widget.
			The keys of the dictionary are the StaticText labels.
			The value are the contents of the corresponding EntryFields."
    ^dictionary ifNil: [ dictionary := Dictionary new ].! !

!CompositePane methods !
buildWindow: parentWindow
    "Private - Create the window."

	self addSubpanesOnce.
    ^super buildWindow: parentWindow! !

!CompositePane methods !  
cpForeColor: aColor
		"Obsolete - Set the receiver's foreground color.
			Use foreColor: instead."
    self foreColor isNil ifTrue: [
        self foreColor: aColor
    ]! !

!SexPane class methods !
wbBasicVersion

	"Private - Answer the WindowBuilder Pro version.
		Generated in: Visual Smalltalk Enterprise 3.1.0 Win32"

	^3.1! !

!EntryFieldGroup methods !   
label: aString
		"Sets the text label of the GroupBox surrounding the widget."
    | gb |
    label := aString.
    ((gb := self paneNamed: 'group') notNil and: [ gb handle isValid ]) ifTrue: [ gb contents: aString ].! !

!CompositePane methods !  
wmVScroll: wordInteger with: longInteger
        "Private - Process a WM_VSCROLL message."
    | type pos w ctrlId |

	"If this is for a child, then pass it along..."
    longInteger = 0 ifFalse: [
        ctrlId := UserLibrary getWindowLong: longInteger index: GwlId.
        ( w := self childAtId: ctrlId ) isNil ifTrue: [ ^nil ].
        w syncControlEvent: wordInteger lowWord with: wordInteger highWord.
        ^nil ].

    type := wordInteger lowWord.
    type = SbLineup ifTrue: [
            (self verticalScrollPos > self verticalScrollMinRange) ifTrue:[
                 self scrollVertical: self amountToScrollUp]].
    type = SbLinedown ifTrue: [
            (self verticalScrollPos < self verticalScrollMaxRange) ifTrue:[
                self scrollVertical: self amountToScrollUp negated]].
    type = SbPageup ifTrue: [
            self scrollVertical: (self amountToPageUp
                min: (self verticalScrollPos - self verticalScrollMinRange)) ].
    type = SbPagedown ifTrue: [
            self scrollVertical: (self amountToPageUp
                min: (self verticalScrollMaxRange - self verticalScrollPos)) negated].
    type = SbThumbposition
        ifTrue: ["end of tracking"
            pos := wordInteger highWord.
            self scrollVertical: self topCorner y - pos.
            self updateVerticalSliderTo: pos.
            ^nil].
    type = SbThumbtrack
        ifTrue: [^nil]
        ifFalse: [self updateVerticalSlider].
   ^nil! !

!CompositePane methods !  
topPaneClass
		"Private - Answer the class used as the top pane."
    ^self class! !

!RadioButtonGroup methods ! 
contents: aCollection
		"Set the labels of the buttons within the group. The number of
			buttons is determined by the size of aCollectionOfStrings.
			Note: This method may only be used before the window is opened."
    handle = NullHandle ifFalse: [^self].
    list := aCollection.
    children := nil.
    self addSubpanes.! !

!CompositePane methods !  
addSubpanesOnce
	"Add subpanes only if not added before."

    (children isNil or: [children isEmpty]) ifTrue: [self addSubpanes].! !

!CompositePane methods !  
amountToScrollUp
        "Private - Answer the number of pixels
         for vertical scrolling."
    ^8! !

!CompositePane methods !
scrollVertical: scrollAmount
    "Private - Scroll the pane down by anInteger
      number of pixels (if positive) or up by
      the absolute value of anInteger (if negative)."

    self scrollTopCorner: 0 @ scrollAmount.! !

!EntryFieldGroup methods !  
backColor: aColor

    super backColor: aColor.
    self children do: [ :child | child backColor: aColor ].! !

!WBEntryField methods !  
wmKillfocus: wParam with: lParam
        "Private - Validate Input before loosing focus"
    |newValue|

    #osiHack.
    "Is this needed?"
    "Move EnhEntField>>selectFirst/Last up into EntryField?"

    newValue := self windowText.
    self losingFocus.
    value := newValue.
    self selectFrom: 0 to: 0.

    ^nil! !

!CompositePane methods !  
isMDISupportPane
        "Answer true if receiver is a support pane for MDI."
    | cpStyle |
    ^(cpStyle := self cpStyle) == #mdiToolBar or: [
        cpStyle == #mdiToolBarBordered]! !

!CompositePane methods !  
setFocus: aPane
		"Set focus to one of the receiver's children."
    self propertyAt: #focus put: aPane.! !

!SexPane methods !   
addSubpanes

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."

	| female male sexGroup xDU yDU |
	#generated.
	xDU := (SysFont width + 1 roundTo: 2) / 4.
	yDU := SysFont height / 8.
	
		"Temporary Variables"
	female := RadioButton new.
	male := RadioButton new.
	sexGroup := GroupBox new.
	
	self
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1/2; leftInset: -23 * xDU;
				topRatio: 1/2; topInset: -17 * yDU;
				rightRatio: 1/2; rightInset: -23 * xDU;
				bottomRatio: 1/2; bottomInset: -17 * yDU);
		backColor: Color gray.
	
	male "RadioButton"
		owner: self;
		setName: 'male';
		when: #clicked: send: #setMale: to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 6 * xDU;
				topRatio: 0; topInset: 8 * yDU;
				rightRatio: 0; rightInset: -32 * xDU;
				bottomRatio: 0; bottomInset: -18 * yDU);
		contents: 'Male';
		startGroup;
		font: SysFont.
	self addSubpane: male.
	
	female "RadioButton"
		owner: self;
		setName: 'female';
		when: #clicked: send: #setFemale: to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 6 * xDU;
				topRatio: 0; topInset: 18 * yDU;
				rightRatio: 0; rightInset: -40 * xDU;
				bottomRatio: 0; bottomInset: -28 * yDU);
		contents: 'Female';
		noTabStop;
		font: SysFont.
	self addSubpane: female.
	
	sexGroup "GroupBox"
		owner: self;
		setName: 'sexGroup';
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 0 * xDU;
				topRatio: 0; topInset: 0 * yDU;
				rightRatio: 1; rightInset: 1 * xDU;
				bottomRatio: 1; bottomInset: 1 * yDU);
		contents: 'Sex';
		startGroup;
		noTabStop;
		font: SysFont.
	self addSubpane: sexGroup! !

!EntryFieldGroup methods ! 
list: aCollection
		"Private"
    self propertyAt: #list put: aCollection! !

!SexPane methods !  
sex
		"Return the sex of the widget. Allowable values are #male and #female."
    ^sex! !

!CompositePane methods !   
scrollingRectangle
		"Private"
    (initialSize isNil or: [initialSize <= rectangle extent]) ifTrue: [
        ^0@0 extent: 0@0
    ] ifFalse: [
        ^0@0 extent: ((initialSize x - rectangle width) @ (initialSize y - rectangle height))
    ].! !

!CompositePane class methods !  
open

    self openWithParent: nil! !

!CompositePane methods !   
resize: aRectangle deferInfo: winPosInfo
    | posInfo |
    posInfo := super resize: aRectangle deferInfo: winPosInfo.
    self setScrollRanges.
    self scrollTopCornerTo: 0@0.
    self updateSliders.
    ^posInfo! !

!CompositePane methods !  
contents: anObject
	"Set the value of the receiver.
	 This should be overriden in subclasses"! !

!CompositePane methods !
views
		"Private"
    ^Array with: self.! !

!CheckBoxGroup methods ! 
selection
    "Answer the index of the first item selected. Index starts at 1."
    | values |
    values := self selections.
    values size = 0 ifTrue: [^nil].
    ^values first! !

!SexPane class methods !   
importantEvents

    ^#(#sexChanged: #setToMale #setToFemale)! !

!RadioButtonGroup methods ! 
selection
		"Answer the index of the button currently selected."
    ^selection! !

!CompositePane methods !  
menuWindow
        "Private - Needed to support translateAccelerator in Notification Manager."
    ^MenuWindow new! !

!EntryFieldGroup methods ! 
contents: aDictionaryOfStrings
		"The dictionary's keys set the labels of the StaticText labels within the group.
			The dictionary's values provide the contents of the EntryFields.
			If aDictionaryOfStrings is some other type of collection than a dictionary,
			the items of the collection will be used as the StaticText labels
			and the EntryFields will be initialized to empty strings. The number
			of EntryFields is determined by the size of aDictionaryOfStrings.
			Note: This method may only be used before the window is opened."
    handle = NullHandle ifFalse: [^self].
    aDictionaryOfStrings isDictionary ifTrue: [
        self list: aDictionaryOfStrings keys asArray.
        dictionary := aDictionaryOfStrings
    ] ifFalse: [ aDictionaryOfStrings size > 0 ifTrue: [
        self list: aDictionaryOfStrings.
        dictionary := Dictionary new.
        aDictionaryOfStrings do: [ :item | dictionary at: item put: '' ].
    ] ifFalse: [
        self list: #().
        dictionary := Dictionary new
    ]].
    children := nil.
    self addSubpanes.! !

!CompositePane methods !  
scrollbars
        "Obsolete - Add the scroll bar styles to the receiver.
            Use addHorizontalScrollbarStyle and addVerticalScrollbarStyle instead."
	self obsoleteMethod.
    self
        addBorderStyle;
        addHorizontalScrollbarStyle;
        addVerticalScrollbarStyle.! !

!CompositePane methods !
childSize
		"Private - Answer the size of the receiver's children."
    initialSize isNil ifTrue: [
        ^0@0
    ] ifFalse: [
        ^initialSize
    ]! !

!RadioButtonGroup methods !  
selectedItem
        "Answer the item selected in the RadioButtonGroup."
    ( self selection ) isNil
        ifTrue: [ ^nil ]
        ifFalse: [ ^list at: ( self selection ) ]! !

!CheckBoxGroup methods !   
selectedItems
    "Answer a collection of the selected items."
    | sel |
    (sel := self selections) isNil
        ifTrue: [^nil]
        ifFalse: [^self selections collect: [:each | list at: each]]! !

!EntryFieldGroup class methods ! 
supportedEvents
        "Private - Answer the events supported by this subpane."
    ^super supportedEvents
        add: #textChanged;
        yourself! !

!RadioButtonGroup class methods !   
supportedEvents
        "Private - Answer the events supported by this subpane."
    ^super supportedEvents
        add: #select;
        yourself! !

!WBEntryField methods !  
modified

    "Added to avoid the isTextModified message from returning
     true in WindowBuilder.  Believe it or not, this is checked for
     EntryFields..."

    ^false! !

!CompositePane methods ! 
setValue: anObject

	self value: anObject! !

!GroupPane methods !
addSubpanesForWBParts
		"Add the subpanes for parts."
		"For PARTS Support."
	#addedByOSI.
	self addSubpanes.! !

!CompositePane methods !  
updateVerticalSlider
        "Update the slider box in the vertical scrollBar."
    self updateVerticalSliderTo: self topCorner y.! !

!RadioButtonGroup methods !
selectedIndex
        "Private - Answer the currently selected item index."
    ^self selection! !

!RadioButtonGroup methods !   
contents
		"Return the collection of labels of the buttons within the group."
    ^list ifNil: [ list := #() ].! !

!RadioButtonGroup methods !   
selectItem: aString
        "Private - Select the item aString"
    self selectIndex: (self indexOf: aString)! !

!RadioButtonGroup methods ! 
verticalScrollBar
		"Obsolete - Add the vertical scroll bar style to the receiver.
			Use addVerticalScrollbarStyle instead."
    self obsoleteMethod.
    super verticalScrollBar.
    self propertyAt: #cpStyle put: #verticalScrollBar! !

!RadioButtonGroup methods !  
backColor: aColor
		"Set the background color of the receiver and all buttons."
    super backColor: aColor.
    self children do: [ :child | child backColor: aColor ].! !

!SexPane class methods !
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #sexChanged:;
        add: #setToMale;
        add: #setToFemale;
        yourself! !

!EntryFieldGroup methods ! 
addSubpanes
		"Private"
	| numRows contents labelWidth fieldHeight scrollWidth vertOffset lowest field |

	contents := self list.
	self font isNil ifTrue: [self font: self defaultFont].
	labelWidth := (contents inject: 0 into: [:max :item | max max: (self font wbStringWidth: item)]) + 8.
	fieldHeight := self font height + 8.
	scrollWidth := 0.
	self cpStyle isNil ifTrue: [
		vertOffset := self font height + 2.
		self addSubpane: (
			GroupBox new
				owner: self;
				framingBlock: (
					LayoutFrame new
						leftRatio: 0; leftInset: 0;
						topRatio: 0; topInset: 0;
						rightRatio: 1; rightInset: 0;
						bottomRatio: 1; bottomInset: 0);
				paneName: 'group';
				startGroup;
				contents: self label;
				yourself).
	] ifFalse: [
		vertOffset := 0.
	].
	numRows := contents size max: 1.
	1 to: numRows do: [:row |
			row > self contents size ifFalse: [
				self addSubpane: (
				   StaticText new
						owner: self;
						propertyAt: #index put: row;
						framingBlock: (
							LayoutFrame new
								leftRatio: 0; leftInset: 2;
								topRatio: 0; topInset: 10 + vertOffset + ((fieldHeight + 4) * (row - 1));
								rightRatio: 0; rightInset: (2 + labelWidth) negated;
								bottomRatio: 0; bottomInset: (2 + vertOffset + ((fieldHeight + 4) * row)) negated);
						rightJustified;
						contents: (contents at: row),':';
						yourself).
				self addSubpane: (
				   (field := self fieldClass new)
						owner: self;
						propertyAt: #index put: row;
						framingBlock: (
							LayoutFrame new
								leftRatio: 0; leftInset: 6 + labelWidth;
								topRatio: 0; topInset: 6 + vertOffset + ((fieldHeight + 4) * (row - 1));
								rightRatio: 1; rightInset: 4 + scrollWidth;
								bottomRatio: 0; bottomInset: (lowest := 2 + vertOffset + ((fieldHeight + 4) * row)) negated);
						when: #textChanged: send: #textChanged:pane: to: self withArgument: field;
						contents: (self contents at: (contents at: row));
						paneName: (contents at: row);
						startGroup;
						tabStop;
						yourself).
		  ].
	].! !

!CompositePane methods ! 
disable
        "Disable the receiver and all its children."
    super disable.
    self children do: [ :child | child disable ]! !

!CompositePane methods !
isCompositePane
		"Answer true if the receiver is a composite pane."
    ^true! !

!CompositePane methods !   
charsInColumn
        "Private - Answer the receiver frame height."
    ^rectangle height! !

!RadioButtonGroup methods ! 
groupBoxClass
		"Returns the GroupBox subclass to be used within the widget.
			RadioButtonGroup can easily be subclassed to use a different group box
			class (such as the CP3DFrame provided in Subpanes/V)."
    ^GroupBox! !

!CompositePane methods ! 
freeClientArea: box
    "Private - Set the client area left over."
    | cpStyle |
    cpStyle := self cpStyle.
    (cpStyle == #mdiToolBar or: [cpStyle == #mdiToolBarBordered])  ifFalse: [ ^self ].
    self visible ifFalse: [ ^self ].
    cpStyle == #mdiToolBar ifTrue: [
        box leftTop: (box leftTop rightAndDown: (0 @ self height))
    ] ifFalse: [
        box leftTop: (box leftTop rightAndDown: (-2 @ self height + 2))
    ].! !

!CompositePane methods !  
amountToScrollLeft
        "Private - Answer the number of pixels
         for horizontal scrolling."
    ^8! !

!EntryFieldGroup methods !  
list
		"Private"
    ^self propertyAt: #list! !

!EntryFieldGroup methods !   
setValueFont: aFont
		"Sets the font of the EntryFields to aFont."
    (self children select: [:pane | pane class == self fieldClass ]) do: [:field | field font: aFont].
    self update! !

!EntryFieldGroup methods ! 
textChanged: aString pane: aPane
        "Private"
    self contents at: aPane paneName put: aString.
    self event: #textChanged. "Obsolete"
    self triggerEvent: #textChanged:pane: with: aString with: aPane.! !

!RadioButtonGroup methods ! 
label: aString
		"Sets the text label of the GroupBox surrounding the widget."
    | gb |
    label := aString.
    ((gb := self paneNamed: 'group') notNil and: [ gb handle isValid ]) ifTrue: [ gb contents: aString ].! !

!EntryFieldGroup methods !
foreColor: aColor

    super foreColor: aColor.
    self children do: [ :child | child foreColor: aColor ].! !

!CheckBoxGroup class methods !   
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #changedIndex:set:;
        yourself! !

!RadioButtonGroup methods !
list
		"Return the collection of labels of the buttons within the group."
    ^self contents! !

!WBEntryField methods !  
setContents: aString
		"Set the receiver's contents without triggering a textChanged event."
    self
		contents: aString;
		removeTextChangedEvent.! !

!RadioButtonGroup methods !
numColumns: anInteger
		"Set the number of columns in the group."
    numColumns := anInteger! !

!CompositePane methods !
resize: aRectangle
    | answer |
    self disableRedraw.
    self scrollTopCornerTo: 0@0.
    self enableRedraw.
    answer := super resize: aRectangle.
    self setScrollRanges.
    self updateSliders.
    ^answer! !

!RadioButtonGroup methods ! 
label
		"Answer the text label of the GroupBox surrounding the widget."
    ^label ifNil: [ label := '' ]! !

!CompositePane methods !
validate

    self children do: [:child |
        child resize: self rectangle.
        child isButton ifTrue: [child receiveAllWindowMessages]].
    self setScrollRanges.
    super validate.
    self sendInputEvent: #updateRectangle.
    self initWindow.! !

!RadioButtonGroup methods ! 
buttonClass
		"Returns the Button subclass to be used within the widget.
			RadioButtonGroup can easily be subclassed to use a different button
			class (such as the CP3DRadioButton provided in Subpanes/V)."
    ^RadioButton! !

!CheckBoxGroup methods !   
lastSelection
		"Private - Answer the last selection."
    ^selection! !

!CompositePane methods !
enable
        "Enable the receiver and all its children."
    super enable.
    self children do: [ :child | child enable ]! !

!CompositePane methods !
updateSliders
        "Private - Update the slider boxes in the scrollbars."
    self isHandleOk ifFalse: [ ^self ].
    self doGraphics: [
        self updateVerticalSlider.
        self updateHorizontalSlider ]! !

!CheckBoxGroup methods !  
selectIndex: index
		"Select the button at the specified index."
    (self children detect: [ :child | index = (child propertyAt: #index)]) selection: true.
    selection := index.! !

!CompositePane methods !
visibleExtent
		"Private"
    ^self extent - 2! !

!RadioButtonGroup methods !
selectIndex: itemIndex
		"Select the button at itemIndex in the receiver."
    | radioButton |
    radioButton := self children detect: [ :child | child isRadioButton and: [(child propertyAt: #index) == itemIndex ]].
    self children do: [ :child |
        child isRadioButton ifTrue: [
            child == radioButton ifTrue: [
                child selection: true.
            ] ifFalse: [
                child selection: false
            ].
        ].
    ].
    selection := itemIndex.! !

!WBEntryField methods ! 
gettingFocus
        "Select all when getting focus."
    self selectAll.
	super gettingFocus.! !

!CompositePane methods !  
scrollTopCorner: aPoint
	"Scroll the top corner by aPoint."
	"self sendInputEvent: #scrollTopCornerLimited: with: aPoint."
	self scrollTopCornerLimited: aPoint.! !

!RadioButtonGroup methods ! 
selection: anObject
		"If anObj is a collection then select items whose indices
			are in anObj. If anObj is an Integer then select the item
			indexed by anObj. Otherwise, select anObj in the list."
    ( anObject isInteger )
        ifTrue: [ self selectIndex: anObject ]
        ifFalse: [ self selectItem: anObject ]! !

!CompositePane methods ! 
scrollTopCornerLimited: aPoint
    "Private - Scroll the top corner by aPoint."

    | newTopCorner |

    aPoint = (0 @ 0) ifTrue: [^self].

    newTopCorner :=
        ((topCorner x - aPoint x
            min: self horizontalScrollMaxRange)
            max: self horizontalScrollMinRange)
        @ ((topCorner y - aPoint y
            min: self verticalScrollMaxRange)
            max: self verticalScrollMinRange).

    self scrollTopCornerUnlimited: topCorner - newTopCorner.! !

!SexPane methods !  
setFemale: ignore
        "Private"
    self sex: #female.
    self event: #setToFemale. "Obsolete"
    self triggerEvent: #setToFemale.! !

!RadioButtonGroup methods !
groupBoxFont: aFont
	"Set the font for the reciever's group box."

	self children do: [:each |
		each isGroupBox ifTrue: [
			each font: aFont]].! !

!CheckBoxGroup methods ! 
selection: anObj
        "If anObj is a collection then select items whose indices
         are in anObj.
         If anObj is Integer then select the item indexed by anObj.
         Otherwise, select anObj in the list."
    anObj size > 0
        ifTrue: [ anObj do: [ :i | super selection: i ]]
        ifFalse: [super selection: anObj]! !

!RadioButtonGroup methods !   
setRadio: aString pane: aPane
        "Private"
    selection := aPane propertyAt: #index.
    self selectIndex: selection.
    self event: #select. "Obsolete"
    self triggerEvent: #clicked: with: (self contents at: selection).
    self triggerEvent: #changedIndex: with: selection.
! !

!SexPane methods ! 
sex: aSymbol
        "Set the sex of the widget. Allowable values are #male and #female."
    | list newSex |
    newSex := aSymbol isSymbol | aSymbol isNil
        ifTrue: [ aSymbol ]
        ifFalse: [ aSymbol asString asLowerCase asSymbol ].
    list := #(#male #female).
    newSex isSymbol ifTrue: [
        (list includes: newSex) ifFalse: [
            ^self error: 'Unknown sex (', newSex asString, ')' ] ].
    sex == newSex ifFalse: [
        sex := newSex.
        list do: [ :each |
            (self paneNamed: each) selection: each == sex ].
        self event: #sexChanged. "Obsolete"
        self triggerEvent: #sexChanged: with: sex ].! !

!CompositePane methods !
cpBackColor: aColor
		"Obsolete - Set the receiver's background color.
			Use backColor: instead."
    self backColor isNil ifTrue: [
        self backColor: aColor
    ]! !

!RadioButtonGroup class methods !   
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #clicked:;
        add: #changedIndex:;
        yourself! !

!CompositePane methods !  
clearFocus
		"Private - Clear the receiver's focus."
    self setFocus: nil.! !

!CompositePane methods ! 
totalWidth
        "Private - Answer the width of the receiver's graphics medium."
    ^rectangle width! !

UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!