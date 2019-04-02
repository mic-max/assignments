3.1.0.106
   
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^Set new
		add: #selected;
		add: #deselected;
		add: #apply:;
		add: #help:;
		add: #next: ;
		add: #back:;
		yourself!  
defaultBackColor
        "Answer the default background color for windows of
         this class."
    ^ Color buttonFace! 
inputCommands
	"Private - Answer system commands as a result of user input."

	InputCommands isNil
		ifTrue:
			[InputCommands := Set
				new add: BnClicked;
				add: CbnEditchange;
				add: CbnSelchange;
				add: CbnDblclk;
				add: EnChange;
				add: LbnSelchange;
				add: LbnDblclk;
				yourself].
	^InputCommands!  
constructEventsTriggered
	"Private - answer the set of events that instances of the
        receiver can trigger."

	^super
		constructEventsTriggered add: #aboutToChange;
		add: #changedPageNumber:;
		add: #changed:;
		add: #inputOccurred;
		add: #drawItem:;
		yourself! 
wizard
	"Make TabControl work like a wizard (no tabs on pages)."
    "Note: This is done completely with Smalltalk code since there
    is no way to ask TabControl not display the tabs."

	self propertyAt: #wizard put: true! 
windowClass
	"Private - Answer the window class constant."

	^WcTabcontrol!
isFirstPage
	"Answer true if the current item is the first one."

	^(self pageNumber) = 1! 
firstPage
	"Set the current page to the first page."

	self selectPage: self queryFirstPage!   
queryFirstPage
    "Answer the first item."

	self pages size > 0
		ifTrue: [ ^ self pages first ]
		ifFalse: [ ^ nil ]! 
backColor: aColor
        "Set the background color of the receiver."
    self propertyAt: #backColor put: aColor.
    self isHandleOk ifFalse: [ ^self ].
    UserLibrary
            sendMessage: self handle
            msg: TcmSetbkcolor
            wparam: 0
            lparam: aColor asRGBColor asInteger.
!  
wmNotify: wordInteger with: longInteger
	"Private - Process the WM_NOTIFY message."

    self notify: longInteger.
    ^nil!  
appendPage: aTabControlItem
    "Add an item at the end."

    self addPage: aTabControlItem ! 
demandLoad: aBoolean
    "Set the demand load flag. When this flag is set (on),
    the notebook page contents is not recreated until it is
    page is selected."

    self propertyAt: #demandLoad put: aBoolean!  
isCached: aPage
    "Private - Answer true if the contents of <aPage> is cached.
	Note - this method is here to prepare for future cache with
	a max number of pages."

    ^ self demandLoad not!   
isOkToChange
        "Private - answer whether it is OK to change.
        Triggers the veto-able #aboutToChange event."
	( self propertyAt: #validate ) notNil
		ifTrue: [ ^true ].   "during validate, always allow change."
    [ self triggerAboutToChange ] on: VetoAction do: [ ^false ].
    ^true!  
contents: arrayOfPages
	"Set the collection of pages to <arrayOfPages>."

	self deleteAllPages.
	arrayOfPages do: [ :aPage |
        self addPage: aPage ].
	self newPagesCreated!  
deletePage: anItem
	"Delete <aPage> from the receiver."

	self deletePageNumber: (self pageNumberFor: anItem)! 
tabKeyInput: aKeyboardInputEvent
	"Private - Respond to the tab keystroke."

	self hasFocus ifTrue: [
    aKeyboardInputEvent isShiftKeyDown
        ifFalse: [
            self
                triggerEvent: #tabbed
                ifNotHandled: [ ( self nextTabStop: nil ) setFocus ] ]	"first child"
        ifTrue:  [
            self
                triggerEvent: #backTabbed
                ifNotHandled: [ ( self previousTabStop: nil ) setFocus ] ] ]  "last child"! 
previousPage
	"Bring the previous page on top."

	( ( self propertyAt: #backHistory ) size > 0 and: [ self isOkToChange ] )
		ifTrue: [
			value deselect.
			value := nil.  "so that current page won't get pushed to backHistory"
			self selectPage: self backHistoryPop ].!
insertItemNumber: index
    "Private - insert and create the item at <index> position of items."

    | tabText tabImage tcItem address item mask |
    self pages isNil
        ifTrue: [^self].
    self isHandleOk
        ifFalse: [^self].
    item := self pages at: index.
    self isWizard
        ifFalse:
            [ "Do not create tab if wizard"
            tabText := item label asParameter.  "allow double byte"
            tabImage := item image.
            tcItem := WinTcItem new.
            mask := 0.
            address := nil.
            tabText notNil
                ifTrue:
                    [mask := mask + TcifText.
                    address := ExternalAddress copyToNonSmalltalkMemory: tabText.
                    tcItem pszText: address asInteger.
                    tcItem cchTextMax: tabText size].
            tabImage notNil
                ifTrue:
                    [mask := mask + TcifImage.
                    imageList isNil
                        ifTrue: [self createImageListWith: tabImage]
                        ifFalse: [imageList add: tabImage].
                    tcItem iImage: imageList size - 1].
            tcItem mask: mask.
            UserLibrary
                    sendMessage: self handle
                    msg: TcmInsertitem
                    wparam: index - 1
                    lparamStruct: tcItem asParameter.
            address notNil
                ifTrue: [address free].
            ].
!
backHistoryPop
	"Private - Remove the last element (a page) from
	 the backHistory and answer it."

	| history |
	history := self propertyAt: #backHistory ifAbsent: [ ^ nil ].
	history isEmpty ifTrue: [ ^ nil ].
	^ history removeLast! 
deletePageNumber: index
	"Delete the page with the number <index>."

	| oldRect |
	(index > self pages size or: [index < 1])
		ifTrue: [^self].
	oldRect := self rectangle.
	(self pageForNumber: index) close.
	self pages removeIndex: index.
	UserLibrary
			sendMessage: self handle
			msg: TcmDeleteitem
			wparam: index - 1
			lparam: 0.
	self turnToPageNumber: (index min: self pages size).
	oldRect = self rectangle
		ifFalse: [ self resizeChildren ].
	self invalidateRect: nil  "The system does not repaint the page"! 
isLastPage
	"Answer true if the current item is the last one."

	^(self pageNumber) = self pages size! 
freeAddress:  address
    "Private - Free allocated <address>."

    address free! 
ownerDraw
	"Request tabs to be owner draw."

	self addStyle: TcsOwnerdrawfixed.
	self setStyle: self style!   
drawItem: aDrawStruct
	"Private - Draw the seleted tab using the image (icon or bitmap)
        in the page."

	(self hasActionForEvent: #drawItem:)
		ifTrue: [^self triggerEvent: #drawItem: with: self drawIndex].
	(self pages at: self drawIndex) image displayAt: self drawBox origin with: self ownerDrawPen!
releaseDC: aDisplayContext
	"Private - Release aDisplayContext, the display
         context for the receiver."

	(UserLibrary releaseDC: handle with: aDisplayContext) = 0
		ifTrue: [^self "osError"] "0 is OK"!   
demandLoad
    "Answer true if demand load is requested else false."

    ^self propertyAt: #demandLoad ifAbsent: [^false]!
isWizard
	"Private - Answer true if the receiver is a wizard style."

	^(self propertyAt: #wizard) notNil! 
buildWindow: parentWindow
    "Private - Create the window."

    CommonControlsDLL current. "ensure open & initialized"
    children := nil. "don't build children during recreate"
    imageList := nil.
    ^super buildWindow: parentWindow
!  
lastPage
	"Bring the last page of the receiver to the top."

	self selectPage: self queryLastPage! 
nextPage
	"Bring the next item of the receiver to the top."

	self turnToPageNumber: (self pageNumber + 1)!
turnToPageNumber: anInteger
	"Turn to page number <anInteger>.  If <anInteger> is out of range,
       do nothing."

	
	anInteger isNil ifTrue: [ ^ self ].
	(anInteger > 0 and: [anInteger <= self pageCount])
		ifTrue: [self selectPage: (self pageForNumber: anInteger)].
	!  
backHistoryPush: aPage
	"Private - Add <aPage> to the end of the back history."

	| history |
	history := self propertyAt: #backHistory ifAbsent: [
		self propertyAt: #backHistory put: (OrderedCollection new ) ].
	"( self pageNumberFor: aPage ) = 1
		ifTrue: [ history removeAll ]." 
	history add: aPage!  
notify: longInteger
    "Private - Process notify message."

    | notifyStruct address index newItem tip |

    address := ExternalAddress fromInteger: longInteger.
    notifyStruct := WinNmhdr atAddress: address.
    notifyStruct code = TcnSelchanging ifTrue: [
        index := ( UserLibrary sendMessage: self handle msg: TcmGetcursel wparam: 0 lparam: 0 ).
        index < 0 ifTrue: [ ^nil ].  "Sometimes after removing a tab, a -1 index is passed here"
        ( self isOkToChange )
            ifTrue: [ ^nil ]
            ifFalse: [ ^1 ]
        ].
    notifyStruct code = TcnSelchange ifTrue: [
        index := ( UserLibrary sendMessage: self handle msg: TcmGetcursel wparam: 0 lparam: 0 ).
        newItem := self pageForNumber: index + 1.
        self pageSelected: newItem.
        ].
    notifyStruct code = TtnNeedtext ifTrue: [
            notifyStruct := WinTooltiptext atAddress: address.
        newItem := self pageForNumber: notifyStruct idFrom + 1.
        tip := newItem tipText isNil
            ifTrue: [ String new ]
            ifFalse: [ newItem tipText asParameter].
        address := ExternalAddress copyToNonSmalltalkMemoryZ: tip.
        notifyStruct lpszText: address asInteger.
        notifyStruct hinst: 0.   "don't use resource"
         self sendInputEvent: #freeAddress: with: address.
        ^ 0
        ].
    ^nil!  
recreateWindow
	"Private - recreate the host window, because something
         needs to change which cannot be changed dynamically
         by the host operating system - e.g. change tab to button."

	self close. "Note: super's destroy won't work"
	self
		buildWindow: parent;
		resize: parent freeClientArea;
		validate;
		subclassRecursively!   
selectedPage
	"Answer the current page."

	^self selection!
deleteAllPages
	"Delete all pages from the receiver."

	self pages size to: 1 by: -1 do: [ :index |
		self deletePageNumber: index ]
!   
getItemRect
    " Answer tab's bounding rectangle for the first tab.
    This is useful when tabs are fixed size."

    ^ self getItemRect: 1!
getItemRect: tabIndex
    " Answer tab size for <tabIndex>."

    | winRect |
    winRect := WinRectangle new.
    UserLibrary
            sendMessage: self handle
            msg: TcmGetitemrect
            wparam: tabIndex - 1
            lparamStruct: winRect asParameter.
    ^ winRect asRectangle!  
getItemWidth
	"Answer tab width for the first tab."

	^self getItemRect width! 
pageCount
	"Answer the number of items in the receiver."

	^self pages size!   
pages
	"Answer the collection of pages."

	^ items!
pages: tabItems
	"Private - Set all pages."

	items := tabItems!   
pageSelected: newPage
	"Private - Change selection from current page to <newPage>."

	value == newPage 
		ifTrue: [ ^ self ].
	value notNil
		ifTrue: [
			value deselect.
			self backHistoryPush: value ].
	newPage select.
	value := newPage.
	self triggerEvent: #changed.
	self triggerEvent: #changed: with: newPage.
	self triggerEvent: #changedPageNumber: with: (self pageNumberFor: newPage).
	! 
previousTabStop
        "Private - Answer the subpane which is the previous
        tabstop starting from self."
    ^( self isATabStop and: [ self disabled not and: [ self isHidden not ] ] )
        ifTrue: [ self ]
        ifFalse: [ self superWindow tabScope previousTabStop: self ]!   
previousTabStop: aSubPane
        "Private - Answer the first subpane preceding from
        aSubPane which is a tabstop."
    | orderedChildren index |
    ( orderedChildren := self "currentPage" orderedChildren ) size = 0
        ifTrue: [ ^self ].
    index := orderedChildren indexOf: aSubPane.
    ^index > 1
        ifTrue: [(orderedChildren at: index - 1) previousTabStop]
        ifFalse: [self parent tabScope previousTabStop: self]!   
pageNumberFor: anItem
	"Answer the item number for <anItem>."

	^self pages indexOf: anItem!   
queryLastPage
    "Answer the last item."

	self pages size > 0
		ifTrue: [ ^ self pages last ]
		ifFalse: [ ^ nil ]!
raggedRight: aBoolean
	"Request not to align the right ends of tab lines
    if <aBoolean> is true."

	aBoolean
		ifTrue: [self addStyle: TcsRaggedright]
		ifFalse: [self removeStyle: TcsRaggedright].
	self setStyle: self style!   
rectangle
	"Answer the area excluding tabs."

	| winRect |
	winRect := WinRectangle fromRectangle: super rectangle.
	UserLibrary
			sendMessage: self handle
			msg: TcmAdjustrect
			wparam: 0
			lparamStruct: winRect asParameter.
	^rectangle := winRect asRectangle!   
setItemWidth: width
	"Set the width of tabs to <width>."

	| size |
	size := self getItemRect extent.
	size x: width.
	self propertyAt: #itemWidth put: width.
	^self setItemSize: size!   
tabScope
        "Private - Answer the parent window which determines
        the tabbing scope for this control."
    ^self ! 
insertPageAtSelection: anItem
	"Insert <anItem> after current selected page."

	| index selection |
	selection := self selection.
	selection isNil
		ifTrue: [index := self pages size + 1]
		ifFalse: [index := (self pageNumberFor: selection) + 1].
	self insertPage: anItem at: index!
multipleLines: aBoolean
	"Allow tabs to wrap to multiple lines if <aBoolean> is true."

	aBoolean
		ifTrue: [self addStyle: TcsMultiline]
		ifFalse: [self removeStyle: TcsMultiline].
	self setStyle: self style!  
wmCommand: wordInteger with: longInteger
        "Private - Process the command message."

    ( self class inputCommands includes: wordInteger highWord )
		ifTrue: [ self triggerEvent: #inputOccurred ].
    ^ super wmCommand: wordInteger with: longInteger!
sizeChanged: extent
	"Private - The size of the receiver has been changed
         to extent."

	(parent isNil and: [rectangle extent = extent])
		ifTrue: [^self].
	self adjustFraming: self frameRelativeRectangle.
	self sendInputEvent: #updateAndResize. " Needs to be delayed
        so that the control has time to rearrange its tabs with multilines"
	!   
defaultStyle
	"Private - Default style."

	^TcsRaggedright | TcsTabs | TcsTooltips!
setItemSize: aPoint
    "Private - Set tab size to aPoint.  Answer the old size."

    (UserLibrary
            sendMessage: self handle
            msg: TcmSetitemsize
            wparam: 0
            lparam: (ExternalLong lowHalf: aPoint x highHalf: aPoint y) asInteger) asPoint.
    self rectangle.
    self resizeChildren.
!   
pageForNumber: index
	"Answer the item object corresponding to item number <index>."

	(index > 0 and: [index <= self pages size])
		ifTrue: [^self pages at: index]
		ifFalse: [^nil]!  
freeClientArea
    "Answer the remaining visible area after children
    affecting the available free client area have
    their rectangles removed from the receiver's
    rectangle."

    ^self rectangle!   
getItemHeight
    "Answer tab height."

    ^ self getItemRect height! 
orderedChildren
	"Private - Answer current page's orderedChildren
	for tab and arrow key purpose."

	self currentPage isNil ifTrue: [ ^ OrderedCollection new ].
	^ self currentPage orderedChildren!
pageToSelect: anItem
	"Private -
            Verify that the item selection can take place.
        Answer the item selected or nil if the selection
        can not be done.
            If <anItem> is nil, select the first page."

	| validItem |
	validItem := anItem.
	validItem isNil
		ifTrue: [validItem := self queryFirstPage].
	(validItem notNil and: [self isOkToChange])
		ifFalse: [^nil].
	^validItem!  
validate
	"Private - Validate after window is created."

	| aNumber |
	self propertyAt: #validate put: true.
	( aNumber := self propertyAt: #itemHeight ) notNil ifTrue: [ self setItemHeight: aNumber ].
	( aNumber := self propertyAt: #itemWidth ) notNil ifTrue: [ self setItemWidth: aNumber ].
	1 to: self pages size
		do:
			[:index |
			self insertItemNumber: index].
	super validate.
	self newPagesCreated.
	self propertyAt: #backHistory put: nil.
	self propertyAt: #validate put: nil.!
selection
	"Private - Answer the current page."

	^self pageForNumber: self pageNumber!
selection: newItem
	"Private -
    Select aPage by bringing it to the top.
    <newItem> must be existing.
    Does not allow selection to be aborted, nor
            triggers any events. "

	UserLibrary "this does not generate select change notification"
			sendMessage: self handle
			msg: TcmSetcursel
			wparam: (self pageNumberFor: newItem) - 1
			lparam: 0.
	!
buttons: aBoolean
	"Request to display tabs as buttons if <aBoolean> is true."

	aBoolean
		ifTrue: [self addStyle: TcsButtons]
		ifFalse: [self removeStyle: TcsButtons].
	self setStyle: self style!  
fixedWidth: aBoolean
    " Make all tabs the same width if <aBoolean> is true."

    aBoolean
        ifTrue: [ self addStyle: TcsFixedwidth ]
        ifFalse: [ self removeStyle: TcsFixedwidth ].
    self setStyle: self style! 
selectPage: newItem
    "Programatically select a page.  Will verify that the
        page can be selected and will trigger the events."

    | validItem |
	self isValid ifFalse: [
		value := newItem.  "Let validate select the page"
		^ self ].
    (validItem := self pageToSelect: newItem) notNil
        ifTrue: [
            self selection: validItem.
            self pageSelected: validItem ]! 
toolTips: aBoolean
	"Request tool tips to be shown if <aBoolean> is true."

	aBoolean
		ifTrue: [self addStyle: TcsTooltips]
		ifFalse: [self removeStyle: TcsTooltips].
	self setStyle: self style!
updateTab: anItem
	"Update the tab of <anItem> on the screen.
    This is usually used after tab's attributes changed."

	| index oldPage oldRect |
	oldPage := self pageNumber.
	index := self pageNumberFor: anItem.
	index > 0
		ifTrue:
			[oldRect := rectangle.
			self deletePageNumber: index. "next (or previous) page  will be selected"
			value := self currentPage.
			self insertPage: anItem at: index. "does not alter selection"
			self turnToPageNumber: oldPage.
			self rectangle. "recalculate rectangle"
			rectangle = oldRect
				ifFalse: [ self resizeChildren ].  "Tab can change page size"
			]!   
setItemHeight: height
	"Set the height of tabs to <height>."

	| size |
	size := self getItemRect extent.
	size y: height.
	self propertyAt: #itemHeight put: height.
	^self setItemSize: size!
insertPage: anItem at: index
	"Insert <anItem> at <index>.  Note that this does not
	alter the currently selected page."

	index > self pages size
		ifTrue:
			[self appendPage: anItem]
		ifFalse:
			[index = 1
				ifTrue: [self pages: (OrderedCollection with: anItem) , self pages]
				ifFalse: [self pages: ((self pages copyFrom: 1 to: index - 1) , (OrderedCollection with: anItem)) , (self pages copyFrom: index to: self pages size)].
			anItem parent: self.
			self insertItemNumber: index.
			]! 
childrenInBuildOrder
        "Private - answer the child panes in the order they should be built."
	children isNil ifTrue: [ ^ Array new ].
    ^self children valuesAsArray!  
currentPage
	"Answer the currently selected page."

    ^ self pageForNumber: self pageNumber! 
close
	"Close the window."

	super close.
	self pages size > 0
		ifTrue:
			[self pages
				do:
					[:each |
					each image notNil
						ifTrue: [each image release]]].
	imageList := nil. "so that image list will be recreated when reopen"!  
addPage: aTabControlItem
    "Add an item or page at the end."

    aTabControlItem parent: self.
    self pages isNil ifTrue: [ self pages: OrderedCollection new ].
    self pages add: aTabControlItem.
    self insertItemNumber: self pages size!  
nextTabStop
        "Private - Answer the subpane which has the next
        tabstop starting from self."
    ^( self isATabStop and: [ self disabled not and: [ self isHidden not ] ] )
        ifTrue: [ self ]
        ifFalse: [ self superWindow tabScope nextTabStop: self ]!  
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
        "Private - add message models to add child windows to
        a rebuilt clone of the receiver.  Do nothing as the children
        will be added when the page items are added."!   
contents
	"Answer the collection of pages of the receiver."

    ^self pages!  
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process cursor keys."
    | virtualKey | 
    ( virtualKey := aKeyboardInputEvent virtualKey ) notNil ifTrue: [
        ( virtualKey == TabKey or: [ virtualKey == BacktabKey ] )
            ifTrue: [ self tabKeyInput: aKeyboardInputEvent ] ].

    super keyboardInput: aKeyboardInputEvent!  
nextTabStop: aSubPane
        "Private - Answer the first subpane following aSubPane
        which is a tabstop."
    | orderedChildren index |
    ( orderedChildren := self "currentPage" orderedChildren ) size = 0
        ifTrue: [ ^self superWindow tabScope nextTabStop: self ].
    index := orderedChildren indexOf: aSubPane.
    ^index < orderedChildren size
        ifTrue: [(orderedChildren at: index + 1) nextTabStop]
        ifFalse: [self parent tabScope nextTabStop: self]!  
pageNumber
	"Answer the page number for the current page."

    | index |
    ( self isWizard or: [ self isValid not ] )
        ifTrue: [ ^ self pageNumberFor: value ]
        ifFalse: [
		    index := UserLibrary  "this does not generate select change"
				sendMessage: self handle
				msg: TcmGetcursel
				wparam: 0
				lparam: 0.
			^ index + 1 ]!  
newPagesCreated
	"Private - New pages created, perform house keeping."

	| oldValue |
	self pages size > 0
		ifTrue:
			[ ( self demandLoad not or: [ self isBeingEdited ] )  "part needs rect to draw link"
				ifTrue:
					[self pages
						do:
							[:page |
							page created]].
			value isNil
				ifTrue:
					[self selectPage: self pages first]
				ifFalse:
					[oldValue := value.
					value := nil.
					self selectPage: oldValue]]!   
changeParentTitle: text
	"Private - change parent's title to
	<text> which is supplied by selected page."

	self mainWindow labelWithoutPrefix: text! 
updateAndResize
	"Private - Update children sizes."

	rectangle := self freeClientArea.
	self resizeChildren.
	self event: #resize.
	self triggerEvent: #resized.!  
createImageListWith: anImage
	"Private - Create an image list for icons."

	imageList := ImageList fromImages: (Array with: anImage).
	UserLibrary
			sendMessage: self handle
			msg: TcmSetimagelist
			wparam: 0
			lparam: imageList asParameter.
	^imageList!   
parent: aTabControl
	"Private - Set the parent to <aTabControl>."

    parent := aTabControl!  
tipText
	"Answer the tip text of the item."

    ^tip! 
tipText: aString
	"Set the tip text of the item to <aString>."

    tip := aString!
created
    "Private - The page was just created, do nothing."
!
deselect
    "Private - Deselect the item."
    self triggerEvent: #deselected! 
titleForParent
	"Private - Answer title for parent window."

	^ titleForParent!
select
    "Private - Select the item."

    self triggerEvent: #selected! 
label
	"Answer the text label of the item."

    ^label!   
eventTable
        "Private - answer the table of event handlers for the receiver."
    eventTable isNil ifTrue: [ ^eventTable := self eventTableCreate ].
    ^eventTable!
eventTableForEdit
        "Private - answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."
    ^ self eventTable! 
label: aString
	"Set the label of the item to <aString>."

    label := aString!   
orderedChildren
        "Private - Answer an OrderedCollection which is the
        ordering of the children for tab and arrow keys."

	^ nil!
titleForParent: aString
	"Set the title for parent window to <aString>."

	titleForParent := aString!  
image
	"Answer the image of the item."

    ^image!
image: anImage
	"Set the image of the item to <anImage>."

    image := anImage!   
sizeInBytes
    ^28! 
inspectorFields
    ^self inspectorClass fields: #( #mask #lpReserved1 #lpReserved2 #pszText #cchTextMax #iImage #lParam )!  
lParam
	"Private - "

    ^self longAtOffset: 24!  
lpReserved2
	"Private - "

    ^self uLongAtOffset: 8! 
mask
	"Private - "

    ^self uLongAtOffset: 0!
cchTextMax: anInteger
	"Private - "

    self longAtOffset: 16 put: anInteger! 
pszText
	"Private - "

    ^self uLongAtOffset: 12!
pszText: anInteger
	"Private - "

    self uLongAtOffset: 12 put: anInteger!   
cchTextMax
	"Private - "

    ^self longAtOffset: 16!  
iImage
	"Private - "

    ^self longAtOffset: 20!  
iImage: anInteger
	"Private - "

    self longAtOffset: 20 put: anInteger! 
lpReserved1
	"Private - "

    ^self uLongAtOffset: 4! 
mask: anInteger
	"Private - "

    self uLongAtOffset: 0 put: anInteger!   
firstControl
	"Private - Answer the first controsl contained in the receiver"

	^ controls size > 0
		ifTrue: [ controls first ]
		ifFalse: [ nil ]! 
addTabInfoFor: aPane
        "Private - Add tabbing information for aPane to
        the receiver."

    ( aPane canTab and: [ aPane affectsFreeClientArea not ])
        ifTrue: [ self orderedChildren add: aPane ]!   
created
    "Private - The page was just created, create controls if needed."

    ( parent demandLoad not and: [ controls size > 0 and: [ controls first isValid not ] ] )
        ifTrue: [
            controls do:
                [:each |
                    each removeStyle: WsVisible.
                    self createControl: each.
                    each hideWindow ] ]  "safty"
!   
deselect
    "Private - Page was just deselected."

    super deselect.
    controls isNil
        ifTrue: [^self].
    (controls size = 1 and: [controls first respondsTo: #deselected:])
        ifTrue: [controls first deselected: self].
    ( parent demandLoad ) "during editing time, cache won't work when multi line changes"
        ifTrue:
            [self saveState.
            self close.
            ]
        ifFalse:
            [controls
                do:
                    [:each |
                    each hideWindow]]
!  
addSubpane: aPane
	" Add subpane aPane to the receiver."

	controls isNil
		ifTrue: [controls := OrderedCollection new].
	controls add: aPane.
	self addTabInfoFor: aPane!  
mainControl
    "Answer the first control in the page."

    ^ self controls first
!  
controlAt: name
	"Answer the control contained in the receiver
	whose name is <name>."

	^ controls detect: [ :each | each name = name ] ifNone: [ nil ]! 
printOn: aStream
	"Private - Display the item on <aStream>."

	parent isNil
		ifTrue: [ ^ aStream nextPutAll: 'a', self class name, '{',
        		( self label isString
            		ifTrue: [ self label ]
            		ifFalse: [ '' ] ),
			'}' ]
		ifFalse: [ ^ aStream nextPutAll:
			'page ', ( parent pageNumberFor: self ) asString, ' {', self label asString, '}' ]!   
addPagePane: aPane
	"Private -  Add a page pane to the receiver.
	The page pane has the page: method to
	point back to the receiver."

	controls isNil
		ifTrue: [controls := OrderedCollection new].
	controls add: aPane.
	self addTabInfoFor: aPane.
	aPane page: self!   
removeSubpane: aPane
	" Remove subpane <aPane> from the receiver."

	controls isNil
		ifTrue:   [^nil ].
	parent notNil ifTrue: [ parent removeSubpane: aPane ].
	controls remove: aPane ifAbsent: [ ^nil ].
	self orderedChildren remove: aPane ifAbsent: [].!
close
	"Private - close controls."

    controls do: [ :each |
        parent removeSubpane: each ].! 
createControl: aControl
	"Private - Create <aControl> in the page."

	parent addSubpane: aControl.
	aControl
		buildWindow: parent;
		resize: parent rectangle;
		validate;
		subclassRecursively.
	!
saveState
	"Private - Save the current states of controls."

    controls notNil
        ifTrue: [
            cachedState := IdentityDictionary new: controls size + 3.
             self saveStateFor: controls ]!
controls
	"Answer all the controsl contained in the receiver"

	^ controls!
select
	"Private - Select the page."

	super select.
	controls isNil
		ifTrue: [^self].
	(controls size = 1 and: [controls first respondsTo: #selected:])
		ifTrue: [controls first selected: self].
	(self isCached)
		ifTrue:
			[controls
				do:
					[:each |
					each showWindow]]
		ifFalse:
			[controls
				do:
					[:each |
					self createControl: each.
					each showWindow.
					].
			self restoreState]!  
saveStateFor: panes
    "Private -- Saves states for panes and all their children."

    panes do: [ :each |
        ( each respondsTo: #value ) ifTrue: [
            cachedState at: each put: each value ].
        each children size > 0
            ifTrue: [ self saveStateFor: each children ].
         ]!   
restoreState
	"Private - Restore previously saved state."

    cachedState size > 0 ifTrue: [
        cachedState associationsDo: [ :assoc |
            assoc key value: assoc value ] ]!   
orderedChildren
        "Private - Answer an OrderedCollection which is the
        ordering of the children for tab and arrow keys."
    orderedChildren isNil 
		ifTrue: [
			orderedChildren := OrderedCollection new ].
    ^orderedChildren!   
isCached
    "Private - Answer true if the page was cached (controls
    were hidden but not closed)."

    ^ controls first isValid
!