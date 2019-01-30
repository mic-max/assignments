3.1.0.106
   
setLabel: aString
	" Set the label of the receiver."

	self label: aString!
removeState: stateBits
	"Private - if style is nil, initialize it appropriately:
         if #noDefaultStyle was previously sent to the receiver,
         set it to 0, otherwise set it to defaultStyle; then remove
         the given style bits from the flag.  Answer the removed
         styleBits."

	| mask |
	state isNil
		ifTrue: [state := self defaultState].
	mask := stateBits bitXor: 16rFFFFFFFF.
	state := state bitAnd: mask.
	^stateBits!
width: pixels
	"Set the width of the receiver to < pixels>"

	bitmap := pixels!
notifyClicked
	"Private - the host signaled a clicked event."

	self triggerClickedEvent ! 
asReference
	" Private - Answer a WinTbButton structure  to be used
      in Toolbar system messages.  Do not add a new bitmap and string
     for the receiver, use its  bitmapIndex and labelIndex instead.  "

	| parameter |
	parameter := WinTbButton
		new iBitmap: -1;
		iString: -1;
		idCommand: id;
		fsState: state;
		fsStyle: style.
	bitmap isNumber "toolbar separator"
		ifTrue:
			[parameter iBitmap: bitmap]
		ifFalse:
			[bitmapIndex isNil
				ifFalse: [parameter iBitmap: bitmapIndex]].
	labelIndex isNil
		ifFalse: [parameter iString: labelIndex].
	^parameter asParameter!   
tools: aToolCollection
	" Private -  set the tools of the receiver"

	tools := aToolCollection.!   
defaultWidth
	" Answer the default tool width of the receiver "

	^ToolbarItem defaultWidth!   
getIndex
	" Answer the current index of the receiver.  If the receiver's parent
      is not valid, answer nil. "

	^ ((self isHandleOk not) or: [parent isNil])
		ifTrue: [nil]
		ifFalse: [self parent indexFromId: id].! 
asParameter
	" Private - Answer a WinTbButton structure to be used
       in Toolbar system messages.  Set the bitmapIndex and labelIndex
       for the receiver. "

	| parameter |
	parameter := WinTbButton
		new iBitmap: -1;
		idCommand: id;
		fsState: state;
		fsStyle: style;
		iString: -1.
	bitmap isInteger " a separator button width"
		ifTrue: [parameter iBitmap: bitmap].
	bitmap isBitmap
		ifTrue:
			[bitmapIndex := (parent addBitmap: bitmap).
			parameter iBitmap: bitmapIndex].
	label isString
		ifTrue:
			[label isEmpty
				ifFalse:
					[labelIndex := (parent addString: label).
					parameter iString: labelIndex]].
	^parameter asParameter!   
state: aState
	" Private - Set the state of the receiver."

	state := aState!  
parent: aToolbar
	" Private- Set the toolbar which contains the receiver. "

	parent := aToolbar!  
addGroupStyle
	" Set the group style  for the receiver.
        Only one button in a group can be selected at a time.  "

	^self group: true.!
notifyEndadjust: address
	" Private - answer true to allow the user the customize the receiver. "

	self triggerEvent: #endAdjust.
	self isCustomizing: false.
	^nil!
detach: aBoolean
	" Set if the receiver is to be detached. "

	aBoolean
		ifTrue: [self detach].
	^detached := aBoolean !
getState
	" Returns the receiver's state information if successful or -1 otherwise. "

	| result |
	self isHandleOk
		ifTrue:
			[result := (UserLibrary
					sendMessage: parent handle
					msg: TbGetstate
					wparam: id
					lparam: 0).
			(result ~= -1)
				ifTrue: [state := result]].
	^state!
initialize
	" Private - initialize the receiver. "

	super initialize.
	style := TbstyleSep.
	state := 0.
	self setWidth: 0. "default width"
	!
isAtTop
	" Answer if the receiver has the style CcsTop set. "

	^((style bitAnd: CcsBottom) = CcsBottom) not!  
click
	"Programatically click the receiver."

	self pressDown.
	1 to: 10000
		do:
			[:i |
			].
	self pressUp.
	self triggerClickedEvent !  
notifyCusthelp: address
	" Private - process the TbnCusthelp message.  "

	^self helpRequest!  
state
	" Return the state of the receiver."

	^state!  
rectangle
	"Answer the bounding rectangle of the receiver."

	| result rectangle |
	rectangle := WinRectangle new.
	result := UserLibrary
			sendMessage: parent handle
			msg: TbGetitemrect
			wparam: self getIndex
			lparamStruct: rectangle asParameter.
	^rectangle asRectangle.!
windowClass
	"Answer the class of windows for the receiver."

	^Toolbarclassname!  
resize: aRectangle
	"Private - Change the frame of the receiver pane
         to aRectangle."

	self isHandleOk
		ifFalse: [^nil].
	super resize: aRectangle.
	self sendInputEvent: #relocateFixedPosition. "This is needed since system puts it at the wrong place"
	self resize.
	rectangle := self rectangle.
	rectangle extent: (rectangle extent max: 0 @ 0).
	!  
defaultWidth
	" Answer  the default tool width of the receiver "

	^5! 
notifyChange: address
	" Private - process the TbnToolbarchange message.   "

	self updateNonToolbarItems.
	self triggerEvent: #changed.
	^nil!  
index
	" Private - answer the index of the receiver when used in a Toolbar.  "

	^self propertyAt: #index! 
open
	"Private - Open the subpane."

	| newContents |
	self font isNil
		ifTrue: [self fontAttribute: self defaultFont].
	children size ~= 0
		ifTrue:
			[children
				do:
					[:each |
					each isApplicationWindow "TopPane open is different"
						ifFalse: [each open]]].
	newContents := self triggerEvent: #needsContents.
	newContents isCollection
		ifTrue: [self setItems: newContents].
	self event: #getContents.!
insertButton: aTool
index: anInteger
    " Private - insert <aTool> into the receiver at index <anInteger>.
      Answer if the operation succeeded. "

    | result |
    aTool id isNil
        ifTrue: [self setId: aTool index: anInteger].
    result := (UserLibrary
            sendMessage: handle
            msg: TbInsertbutton
            wparam: ( anInteger - 1)
            lparamStruct: aTool asParameter) = 1. "successful"
    result
        ifTrue:
            [toolIDs isNil
                ifTrue:
                    [toolIDs := IdentityDictionary new.
                    ].
            toolIDs at: aTool id put: aTool.
            aTool isDetached
                ifTrue: [self detachItem: aTool]].
    ^result!   
resizeNonToolbarItems
	" Private - reszie the childlren of the receiver."

	children size ~= 0
		ifTrue:
			[children
				do:
					[:each |
					each resize: each tool rectangle.
					each tool isHidden
						ifTrue: [each hideWindow]
						ifFalse: [each showWindow]]].
	! 
toolCount
	" Answer the number of tools currently in  the receiver "

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: self handle
					msg: TbButtoncount
					wparam: 0
					lparam: 0)]!
constructEventsTriggered
	"Private -Construct the set of events triggered by instances of the receiver."

	^super
		constructEventsTriggered remove: #changed;
		add: #clicked;
		yourself! 
save
	" Save the current state of the receiver into the Registration Database.  "

	self save: true.
	!   
fromBitmap: aBitmap
	"Answer a new tool. aFileName is a .BMP file name."

	^self new fromBitmap: aBitmap!  
setWidth: pixels
	" Set the width of the receiver to < pixels> "

	bitmap := pixels!   
initialize
	" Private - initialize the receiver "

	super initialize.
	state := self enable.
	style := TbstyleButton!
registrationValueName: aString
	" Set the registration value name  of the receiver in the RegistrationDatabase. "

	registrationValueName := aString.
	self isHandleOk
		ifTrue: [self restore].
	! 
notifyReset: address
	" Private - process the TbnReset message sent when the user clicked
       on the 'Reset' button on the Customization dialog. "

	self validate.
	self triggerEvent: #reset.
	^nil!   
makeIndeterminate
	"Make the receiver indeterminate.  "

	self isHandleOk
		ifTrue:
			[(UserLibrary
					sendMessage: parent handle
					msg: TbIndeterminate
					wparam: id
					lparam: 1)].
	self triggerEvent: #madeIndeterminate.
	^self addState: TbstateIndeterminate!
index
	" Answer the stored index of the receiver. " 
	^index!   
clearIndeterminate
	"Clear the receiver's indeterminate state. "

	^self indeterminate: false! 
group: aBoolean
	" Set the style TbstyleGroup for the receiver.
        Only one button in a group can be selected at a time.  "

	aBoolean
		ifTrue:
			[style := style | TbstyleCheckgroup] "TbstyleGroup - did not work according to Win95 doc."
		ifFalse:
			[style := style bitAnd: (TbstyleCheckgroup bitXor: 16rFFFFFFFF).
			].
	^style!   
isGrouped
	"Answer true if the receiver is grouped."

	^(style bitAnd: TbstyleCheckgroup) = TbstyleCheckgroup! 
constructEventsTriggered
	"Private - answer the set of events that instances of the
        receiver can trigger."

	^super
		constructEventsTriggered add: #disabled;
		add: #enabled;
		add: #hidden;
		add: #shown;
		add: #detached;
		yourself!
tool: aTool
	" Private - set the tool related to the receiver when used in a Toolbar.  "

	self propertyAt: #tool put: aTool!  
removeGroupStyle
	" Remove the group style  from the receiver "

	^self group: false.! 
label: aString
	" Set the label of the receiver."

	label := aString!  
enableWrap
	"Enable wrapping in the receiver."

	self wrap: true!  
buttonFromIndex: index
	" Private - answer the tool with the current index <index> . "

	| result tbButtonStruct |
	tbButtonStruct := WinTbButton new.
	self isHandleOk
		ifTrue:
			[result := UserLibrary
					sendMessage: handle
					msg: TbGetbutton
					wparam: index
					lparamStruct: tbButtonStruct asParameter].
	result = 0
		ifFalse: [^nil].
	id := tbButtonStruct idCommand.
	^self buttonFromId: id! 
style: styleBits
	" Private - Set the style of the receiver."

	style := styleBits!
isCustomizing: aBoolean
	" Private - set if the receiver is being customized"

	^self propertyAt: #isCustomizing put: aBoolean!
addToolbar: aToolbar
    " Private - add <aToolbar> to the collection of Toolbars for the receiver. "

    | toolbars |
    toolbars := self propertyAt: #toolbars ifAbsent: [self propertyAt: #toolbars put: Set new].
    toolbars add: aToolbar.

	!
constructNotifications
	"Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."

	^Dictionary
		new at: TbnBeginadjust put: #notifyBeginadjust:;
		at: TbnCusthelp put: #notifyCusthelp:;
		at: TbnEndadjust put: #notifyEndadjust:;
		at: TbnGetbuttoninfo put: #notifyGetbuttoninfo:;
		at: TbnQuerydelete put: #notifyQuerydelete:;
		at: TbnQueryinsert put: #notifyQueryinsert:;
		at: TbnReset put: #notifyReset:;
		at: TbnToolbarchange put: #notifyChange:;
		at: TtnNeedtext put: #notifyNeedtext:;
		yourself.! 
updateNonToolbarItems
	" Private - update the children of the receiver. "

	self updateNonToolbarItems: children.
	!  
affectsFreeClientArea
	"Private  - Answer whether the receiver reduces the amount of
    free client area in its parent for its siblings."

	^true!   
tool
	" Private - answer the tool related to the receiver when used in a Toolbar.  "

	^self propertyAt: #tool!
placeAtBottom
	"Place the receiver at the bottom of a window."

	self showAtTop: false.!   
insertItems: aToolCollection
	" Insert <aToolCollectiion> into the receiver."

	aToolCollection
		do:
			[:tool |
			self insertItem: tool]!
freeClientArea: box
	"Private - Set the client area left over."

	(self isValid not or: [self isHidden])
		ifTrue: [^box].
	self isAtTop
		ifTrue: [box top: (box top down: self frameRectangle height)]
		ifFalse: [box bottom: (box bottom up: self frameRectangle height)].
	^box! 
enable: aBoolean
	" Enable or disable the receiver according to <aBoolean>.
	  Answer true if it is successful, else false.
     Trigger the #enabled or #disabled event. "

	| result |
	self isHandleOk
		ifTrue:
			[result := (UserLibrary
					sendMessage: parent handle
					msg: TbEnablebutton
					wparam: id
					lparam:
						(aBoolean
						ifTrue: [1]
						ifFalse: [0])) = 1.
			result
				ifTrue:
					[self
						triggerEvent:
							(aBoolean
							ifTrue: [#enabled]
							ifFalse: [#disabled])].
			^result].
	aBoolean
		ifTrue: [^self addState: TbstateEnabled]
		ifFalse: [^self removeState: TbstateEnabled].
	!   
notifyBegindrag: address
	" Private - answer true to allow the receiver to handle a begin drag operation. "

	^1!  
registrationKeyName: aString
	" Set the registration key name  of the receiver in the RegistrationDatabase. "

	registrationKeyName := aString.
	self isHandleOk
		ifTrue: [self restore]!   
createTool
	" Private - create the tool separator which is added to a Toolbar in place of
          the receiver.  "

	| rect width newTool |
	rect := (self framingBlock value: (0 @ 0 extent: 0 @ 0)).
	width := rect right - rect left.
	newTool := Toolbar
		separator new setWidth: width;
		setLabel: self name;
		detach: self isDetached;
		hide: self isHidden;
		yourself.
	self tool: newTool.
	^newTool!
relocateAndResize
	"Private - Relocate self to the right place and
	resize all the later controls."

	self relocateFixedPosition.
	self resizeLaterSiblings! 
bitmap
	" Return the image of the receiver. "

	^bitmap !  
indexFromId: toolId
	" Answer the index of the tool whose id is <toolId> "

	^UserLibrary
			sendMessage: handle
			msg: TbCommandtoindex
			wparam: toolId
			lparam: 0.! 
notifyBeginadjust: address
	" Private - process the TbnBeginAdjust message.  "

	self triggerEvent: #beginAdjust.
	self isCustomizing: true.
	^nil!  
defaultWidth
	" Answer  the default tool width of the receiver "

	^24!
freeClientAreaBeforeSelf
	"Private - Compute the free client area left for the receiver
    before the receiver space is alllocated."

	| remainingClientArea |
	remainingClientArea := self superWindow rectangle.
	self superWindow isApplicationWindow
		ifTrue:
			[self superWindow childrenAffectingClientArea
				do:
					[:subpane |
					subpane == self
						ifTrue: [^remainingClientArea].
					remainingClientArea := subpane freeClientArea: remainingClientArea]].
	^remainingClientArea!  
setBitmap: aBitmap
	" Set the bitmap of the receiver. "

	self bitmap: aBitmap!
notifyGetbuttoninfo: address
	" Private - proccess the TbnGetbuttoninfo message.  "

	| tbNotify index button |
	tbNotify := WinTbNotify atAddress: address.
	index := tbNotify index + 1.
	index > tools size
		ifTrue: [^0]. "Must return 0 "
	button := tools at: index.
	tbNotify tbButton: button asReference.
	button label isNil
		ifFalse:
			[tbNotify text: button label.
			tbNotify charCount: button label size].
	^1! 
constructEventsTriggered
	"Private - answer the set of events that instances of the
        receiver can trigger."

	^super
		constructEventsTriggered remove: #clicked;
		add: #clicked:;
		add: #turnedOn;
		add: #turnedOff;
		yourself ! 
fromBitmap: aBitmap
	"Set the receiver's bitmap."

	self bitmap: aBitmap.! 
isHidden
	"Answer true if the receiver is enabled, else return false."

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: parent handle
					msg: TbIsbuttonhidden
					wparam: id
					lparam: 0) ~= 0].
	^self hasState: TbstateHidden!  
customize
	" Customize the receiver by displaying the customization dialog box. "

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: self handle
					msg: TbCustomize
					wparam: 0
					lparam: 0) = 1]! 
label
	" Answer the label of the receiver. "

	label isNil
		ifTrue: [^String new].
	^label! 
notifyQueryinsert: address
	" Private - answer true to indicate that items can be inserted into the receiver. "

	^1!  
enableToolTips
	"Enable the tool tip style of the reciever."

	self toolTips: true!
isIndeterminate
	"Answer true if the receiver is indeterminate, else return false."

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: parent handle
					msg: TbIsbuttonindeterminate
					wparam: id
					lparam: 0) ~= 0].
	^self hasState: TbstateIndeterminate!   
id: anInteger
	" Private - Set the id of the receiver. "

	id := anInteger!
defaultState
	"Return the default state of the receiver."

	^TbstateEnabled!   
button1DoubleClick: aPoint
	"Private - button 1 has been double clicked.
        Let the owner process the event."

	self event: #button1DoubleClick.
	self triggerEvent: #doubleClicked!
wrap: aBoolean
	"Enable word wrap in the receiver."

	aBoolean
		ifTrue: [self addStyle: TbstyleWrapable]
		ifFalse: [self removeStyle: TbstyleWrapable]!
eventTable
	"Private - answer the table of event handlers for the receiver."

	^eventTable isNil
		ifTrue: [eventTable := self eventTableCreate]
		ifFalse: [eventTable]!
group: aBoolean
	" Set the style TbstyleGroup for the receiver.
        Only one button in a group can be selected at a time.  "

	aBoolean
		ifTrue:
			[style := style | TbstyleCheckgroup]
		ifFalse:
			[style := style bitAnd: (TbstyleCheckgroup bitXor: 16rFFFFFFFF).
			].
	^style! 
isOn
	"Answer true if the receiver is turned on or checked, else return false."

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: parent handle
					msg: TbIsbuttonchecked
					wparam: id
					lparam: 0) ~= 0].
	^self hasState: TbstateChecked!   
uncheck
	" Private - programatically uncheck the receiver."

	self isHandleOk
		ifTrue:
			[UserLibrary
					sendMessage: parent handle
					msg: TbCheckbutton
					wparam: id
					lparam: 0].
	^self removeState: TbstateChecked!
check
	" Private - programatically check the receiver."

	self isHandleOk
		ifTrue:
			[UserLibrary
					sendMessage: parent handle
					msg: TbCheckbutton
					wparam: id
					lparam: 1].
	^self addState: TbstateChecked.!  
turnOff
	"Set the receiver's state to off (false).
        Trigger changed event. "

	self setValue: false!   
initialize
	" Private - initialize the receiver "

	super initialize.
	style := TbstyleCheck.
	value := false.
	!   
turnOn
	"Set the receiver's state to on (true).
        Trigger changed event. "

	self setValue: true!   
value
	" Return the value of the receiver. "

	^value! 
click
	"Programatically click the receiver."

	self setValue: value not!   
changedEventFor: aBoolean
	"Private - answer the event to trigger for state aBoolean."

	^aBoolean
		ifTrue: [#turnedOn]
		ifFalse: [#turnedOff].!   
setValue: aBoolean
	"Set the state of the receiver to aBoolean.  Trigger the
        changed event if the value has changed.
        Answer aBoolean."

	(aBoolean isBoolean)
		ifTrue:
			[(aBoolean ~= value)
				ifTrue:
					[self value: aBoolean.
					self triggerClickedEvent].
			].
	^aBoolean! 
triggerClickedEvent
	"Private - trigger the clicked event."

	value := self isOn.
	self isHandleOk
		ifTrue:
			[parent triggerEvent: #clicked: with: self.
			self triggerEvent: #clicked: with: value.
			self triggerEvent: (self changedEventFor: value)]!
value: aBoolean
	"Set the  state (on or off)) of the receiver to aBoolean. "

	aBoolean
		ifTrue: [self check]
		ifFalse: [self uncheck].
	value := aBoolean!   
contents
	"Answer the receiver's contents."

	^tools!  
sizeInBytes

	^20!  
inspectorFields

	^#(#iBitmap #idCommand #fsState #fsStyle #dwData #iString)!   
addString: aString
	" Private- add <aString> into the receiver.  Return the string index.   "

	| index |
	index := UserLibrary
			sendMessage: handle
			msg: TbAddstring
			wparam: 0
			lparamStruct: aString asAsciiZ asParameter. "double nul char"
	index < 0
		ifTrue: [^self error: 'add string error.'].
	^index! 
index: anInteger
    " Set the  index of the receiver.  "
    index := anInteger!   
buttonFromId: buttonId
	" Private - answer the tool with id <buttonId> . "

	toolIDs isNil
		ifTrue: [^nil].
	^toolIDs at: buttonId ifAbsent: [^nil].!   
style
	" Return the style of the receiver."

	^style!  
items
	" Answer the tools of the receiver"

	^tools!   
hide
	" Hide the receiver"

	self hideWindow.
	self resizeSiblings.!  
detachItem: tool
	" Remove tool from the view of the user and move it to the
		available tools section of the Customization dialog.
		Answer true if the operation is successful, else answer false.  "

	tool notNil
		ifTrue: [^tool detach]! 
enable
	"Enable the receiver.  Answer true if it is successful, else false.
     Trigger the #enabled event. "

	^self enable: true!  
show
	" Show the receiver"

	self showWindow.
	self resizeSiblings.!  
isCustomizing
	" Answer if the receiver is being customized"

	^self propertyAt: #isCustomizing ifAbsent: [false]! 
toolbars
	" Private - answer the Toolbar of the receiver. "

	^self propertyAt: #toolbars! 
defaultHeight
	" Answer the default tool height of the receiver "

	^ToolbarItem defaultHeight!
constructEventsTriggered
	"Private - answer the set of events that instances of the
        receiver can trigger."

	^super
		constructEventsTriggered add: #changed;
		add: #clicked:;
		add: #doubleClicked;
		add: #beginAdjust;
		add: #endAdjust;
		add: #reset;
		yourself!  
toolHeight
	" Answer the tool height of the receiver. "

	toolHeight isNil
		ifTrue: [^self class defaultHeight].
	^toolHeight!  
contents: aToolCollection
	"Set the receiver's contents."

	tools notNil
		ifTrue:
			[tools
				do:
					[:tool |
					tool release].
			tools := nil.
			self children: IdentityDictionary new].
	aToolCollection
		do:
			[:tool |
			self addItem: tool].
	self isHandleOk
		ifTrue: [self recreateWindow]!   
bitmapHeight
	" Answer the bitmap height of the tools in the  receiver. "

	bitmapHeight isNil
		ifTrue: [^ToolbarItem defaultBitmapHeight].
	^bitmapHeight! 
bitmapHeight: anInteger
	" Set the bitmap height of the tools in the  receiver. "

	bitmapHeight := anInteger.
	self isHandleOk
		ifTrue:
			[self
				setSizes;
				resize;
				relocateFixedPosition]! 
bitmapWidth
	" Answer the bitmap width of the tools in the  receiver. "

	bitmapWidth isNil
		ifTrue: [^ToolbarItem defaultBitmapWidth].
	^bitmapWidth!  
bitmapWidth: anInteger
	" Set the bitmap width of the tools in the  receiver. "

	bitmapWidth := anInteger.
	self isHandleOk
		ifTrue:
			[self
				setSizes;
				resize;
				relocateFixedPosition]!
height: anInteger
	"Set the receiver's height."

	self toolHeight: anInteger!  
toolHeight: anInteger
	" Set the tool height of the receiver. "

	toolHeight := anInteger.
	self isHandleOk
		ifTrue:
			[self
				setSizes;
				resize;
				relocateFixedPosition]! 
initialize
	" Private - initialize the receiver. "

	super initialize.
	self placeAtTop.
	self customizable.
	autoSave := false.!   
createNonToolbarItems
	" Private - create the children of the receiver."

	self createNonToolbarItems: children.
	!   
createNonToolbarItems: aCollection
    " Private - create the subpanes contained in <aCollection>."

    | height |
    aCollection size ~= 0
        ifTrue:
            [aCollection
                do:
                    [:each |
                    height := (each framingBlock value: (0 @ 0 extent: 0 @ 0)) height.
                    each
                        open;
                        framingBlock:
                            [:box |
                            each tool rectangle deepCopy height: height];
                        initSize: (self rectangle);
                        validate]].
    !  
toolWidth
	" Answer the tool width of the receiver. "

	toolWidth isNil
		ifTrue: [^self class defaultWidth].
	^toolWidth!   
toolWidth: anInteger
	" Set the tool width of the receiver. "

	toolWidth := anInteger.
	self isHandleOk
		ifTrue:
			[self
				setSizes;
				resize;
				relocateFixedPosition]!
addItem: aTool
	" Private - Add <aTool> to the receiver's collection of tools.  If <aTool> is a subpane or
      controlPane, add a ToolbarSeparator into the collection  and add <aTool> as a
      child of the receiver.  Set the parent of <aTool> to the receiver.   Answer the new tool. "

	| newTool rect width  |
	newTool := aTool.
	" If <aTool> is not a ToolbarItem object  (i.e. ComboBox, DropDowList ),
       append a ToolbarSeparatorButton to the receiver with the same width as
        the tool.  Add the tool as a subpane of the receiver. "
	aTool isSubPane
		ifTrue:
			[rect := (aTool framingBlock value: (0 @ 0 extent: 0 @ 0)).
			width := rect right - rect left.
			newTool := self
				class separator new setWidth: width;
				detach: aTool isDetached;
				hide: aTool isHidden;
				index: aTool index;
				yourself.
			aTool tool: newTool.
			super addSubpane: aTool].
	newTool parent: self.
	tools isNil
		ifTrue: [tools := OrderedCollection new].
	tools add: newTool.
	^newTool ! 
insertItem: aTool
	" Insert <aTool> into the receiver at its index.  If its index is not defined,
       it is inserted at the end of the receiver. "

	| result index newTool  |
	newTool := self addItem: aTool.
	self isHandleOk
		ifTrue:
			[aTool isSubPane
				ifTrue:
					[self recreateWindow]
				ifFalse:
					[index := newTool index.
					(index isNil or: [index < 0])
						ifTrue: [index := tools size].
					result := self insertButton: newTool index: index.
					result
						ifFalse: [^self osError].
					]]!
validate
	"Private - The window for the receiver was
        just created or recreated."

	| extent |
	super validate.
	extent := self extent.
	self setContents.
	extent ~= self extent
		ifTrue: [self resizeSiblings].
	self resize.
	! 
setContents
	" Private - insert the tools into the receiver "

	| result index toolIndex |
	self setSizes.
	index := 0.
	tools isNil
		ifTrue: [^self].
	tools
		do:
			[:tool |
			toolIndex := tool index.
			(toolIndex isNil or: [toolIndex < 0])
				ifTrue: [toolIndex := index := index + 1].
			result := self insertButton: tool index: toolIndex.
			index := index max: toolIndex.
			result
				ifFalse: [^self osError]].
	self registrationKeyName notNil
		ifTrue: [self restore].
	self createNonToolbarItems.
	self updateNonToolbarItems.
	!  
updateNonToolbarItems: aCollection
	" Private - update the subpanes contained in <aCollection>.
       Resize or hide the subpane if the tool associated to
       it has changed. "

	aCollection size ~= 0
		ifTrue:
			[aCollection
				do:
					[:each |
					each resize: each tool rectangle.
					(each tool isHidden or: [each tool isDetached])
						ifTrue: [each hideWindow]
						ifFalse: [each showWindow]]].
	! 
close
	"Private - release  resources and save the current configuration if the 
	receiver has a configuration name."

	autoSave
		ifTrue: [self save].
	super close.
	tools isNil
		ifFalse:
			[tools
				do:
					[:tool |
					tool release]].
	self tools: nil.
    self removeToolbar: self
	!
wmCommand: wordInteger
with: longInteger
	"Private - Handle a command message
         by performing the selector for the item."

	| toolbars toolbar |
	toolbars := self toolbars.
	toolbars isNil
		ifTrue:
			[^super wmCommand: wordInteger with: longInteger]
		ifFalse:
			[toolbar := toolbars
				detect:
					[:tb |
					tb handle asInteger = longInteger]
				ifNone: [^super wmCommand: wordInteger with: longInteger].
			^toolbar performCommand: wordInteger].
	!
wmNotify: wordInteger
with: longInteger
	"Private - Process the WM_NOTIFY message."

	^self notify: longInteger.! 
defaultBitmapHeight
	" Answer the default  image height of the receiver "

	^15!   
sizeInBytes

	^super sizeInBytes + 12 + WinTbButton sizeInBytes!
tbButton: aTbButtonParam

	self contents
			replaceBytesFrom: 17
			to: 36
			with: aTbButtonParam
			startingAt: 1!
text

	^self uLongAtOffset: 40! 
charCount: anInteger

	self uLongAtOffset: 36 put: anInteger!   
charCount

	^self uLongAtOffset: 36!
text: aString
	" Private - set the LPSZTEXT item of TBNOTIFY."

	| address |
	self charCount = 0
		ifTrue:
			[address := ExternalAddress copyToNonSmalltalkMemoryZ: aString asParameter.
			self uLongAtOffset: 40 put: address asInteger.
			(Message receiver: address selector: #free) performDeferred]
		ifFalse:
			[(ExternalAddress fromInteger: self text)
				replaceFrom: 1
					to: aString size
					with: aString
					startingAt: 1;
				at: aString size + 1 put: 0]!  
index

	^self longAtOffset: 12! 
index: anIndex

	self longAtOffset: 12 put: anIndex!
restore
	" Restore the state of the receiver from the Registration Database. "

	self save: false.
	self resize.
	self invalidateRect: nil!  
toolTips: aBoolean
	" Set the tool tips style of the receiver"

	aBoolean
		ifTrue: [self addStyle: TbstyleTooltips]
		ifFalse: [self removeStyle: TbstyleTooltips].
	! 
save: aBoolean
	" If aBoolean is true, save the current state of the receiver into
      an initialization file.  If aBoolean is false, reset the state of the
      receiver. "

	| regDB str tbSaveParams flag valueNameAddr |
	tools isNil
		ifTrue: [^nil].
	(str := self registrationKeyName) isNil
		ifTrue: [^MessageBox warning: 'Tool state data could not be saved because registration informatiion was not valid.'].
	flag := aBoolean
		ifTrue: [1]
		ifFalse: [0].
	regDB := ((Smalltalk at: #RegistrationDatabase) localMachine)
		at: str
		ifAbsent:
			[((Smalltalk at: #RegistrationDatabase) localMachine)
				at: str put: nil;
				at: str].
	regDB open.
	valueNameAddr := ExternalAddress copyToNonSmalltalkMemoryZ: (self registrationValueName).
	tbSaveParams := WinTbSaveParams
		new regKeyHandle: regDB keyHandle asInteger;
		valueName: valueNameAddr asInteger.
	self isHandleOk
		ifTrue:
			[(UserLibrary
					sendMessage: handle
					msg: TbSaverestore
					wparam: flag
					lparamStruct: tbSaveParams asParameter)].
	regDB close.
	self sendInputEvent: #freeAddress: with: valueNameAddr.
	! 
bitmapClass
	"Private - answer the preferred Bitmap class."

	^Bitmap! 
show
	"Show the receiver. Answer true if it is successful, else false.
          Trigger the #shown event. "

	^self hide: false! 
registrationValueName
	" Answer the registration value name  of the receiver in the RegistrationDatabase. "

	^registrationValueName!  
pressDown
	" Private - programatically press down on  the receiver."

	self isHandleOk
		ifTrue:
			[(UserLibrary
					sendMessage: parent handle
					msg: TbPressbutton
					wparam: id
					lparam: 1)].
	^self addState: TbstatePressed!
sizeInBytes

	^8!   
index: anInteger
	" Private - set the index of the receiver when used in a Toolbar.  "

	self propertyAt: #index put: anInteger!   
dragWithAltKey: aBoolean
	" Set if the user uses the Alt key to drag the buttons on the receiver.  If this style is 
	  not set, the user uses the Shift key.  Note that the receiver has to also be customizable
      to see the effects of this style. "

	aBoolean
		ifTrue: [self addStyle: TbstyleAltdrag]
		ifFalse: [self removeStyle: TbstyleAltdrag]!
isOn
	"Answer true if the receiver is turned on or checked, else return false."

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: parent handle
					msg: TbIsbuttonpressed
					wparam: id
					lparam: 0) ~= 0].
	^self hasState: TbstateChecked!   
detach
	"Detach the receiver.  Answer true if it is successful, else false.
      Trigger the #detached event "

	| result |
	self isHandleOk
		ifFalse:
			[detached := true.
			^true].
	result := (UserLibrary
			sendMessage: parent handle
			msg: TbDeletebutton
			wparam: self getIndex
			lparam: 0) = 1.
	result
		ifTrue:
			[detached := true.
			self triggerEvent: #detached].
	^result!  
hasState: aState
	"Answer whether the receiver has the specified bits set in
        its state ."

	| flags |
	flags := state isNil
		ifTrue: [self defaultState]
		ifFalse: [state].
	^(flags bitAnd: aState) = aState!  
performCommand: wordInteger
	" Private - notify the tool that it has been clicked"

	| button |
	button := (self buttonFromId: wordInteger lowWord).
	button isNil
		ifFalse: [button notifyClicked].
	^nil!   
customizable
	" Set the customizable style of the receiver.
       This style allows the user to  rearrange the tools in the tool bar and
        pops up a customization dialog when the user double-clicks on the tool bar."

	self customizable: true!
disableWrap
	"Disable wrapping in the receiver."

	self wrap: false.!  
removeToolbar: aToolbar
    " Private - remove <aToolbar> from the collection of Toolbars for the receiver. "

    | toolbars |
    toolbars := self parent toolbars.
    ( toolbars notNil and: [ toolbars isEmpty not ] )
        ifTrue: [
            toolbars remove: aToolbar.
            toolbars isEmpty ifTrue: [ self parent properties removeKey: #toolbars]  ]




!
setId: aToolbarButton
index: index
	"Private- set the unique id of the receiver "

	aToolbarButton id: 256 + index.
	!   
addBitmap: aBitmap
	" Private - add <aBitmap> into the receiver.  Return the bitmap index. "

	| index clone |
	aBitmap isBitmap
		ifFalse: [^-1].
	clone := aBitmap clone.
	index := UserLibrary
			sendMessage: handle
			msg: TbAddbitmap
			wparam: 1
			lparamStruct:
				(WinTbAddBitmap
				new hInst: 0;
				nID: clone handle) asParameter.
	clone initHandle.
	index < 0
		ifTrue: [^self error: 'add bitmap error.'].
	^index!   
iString: stringIndex

	self "uLongAtOffset:" longAtOffset: 16 put: stringIndex! 
fsState: constants
	" Combined button states: TbstateChecked, TbstateEnabled,
      TbstateHidden, TbstateIndeterminate, TbstatePressed, TbstateWrap."

	self byteAtOffset: 8 put: constants! 
fsStyle: constants
	" Combined button styles: TbstyleButton, TbstyleCheck,
      TbstyleCheckgroup, TbstyleGroup, TbstyleSep."

	self byteAtOffset: 9 put: constants! 
iBitmap: imageIndex

	self "uLongAtOffset: " longAtOffset: 0 put: imageIndex!   
idCommand: id

	self uLongAtOffset: 4 put: id!  
idCommand

	^self uLongAtOffset: 4! 
indeterminate
	"Make the receiver indeterminate.   "

	^self indeterminate: true.! 
wrap: aBoolean
	"Wrap or unwrap the receiver according to <aBoolean>.
	When the receiver is wrapped a line break immediately follows it.
	 If the receiver's Toolbar has its wrapping enabled, this message 
	will be ignored. "

	aBoolean
		ifTrue: [self addState: TbstateWrap | TbstateEnabled]
		ifFalse: [self removeState: TbstateWrap].
	!   
release
	" Private - Release the bitmap associated with the receiver."

	super release.
	(bitmap notNil and: [bitmap isBitmap])
		ifTrue: [bitmap archiveAndRelease].
	!
wrap
	"Set and answer the state of the receiver to be wrapped meaning 
	 a line break follows the receiver.  If the receiver's Toolbar has its
	 wrapping enabled, this message will be ignored. "

	^self wrap: true.!  
sizeChanged: extent
	"Private - The size of the receiver has been changed
         to extent."

	super sizeChanged: extent.
	self sendInputEvent: #relocateAndResize!
relocateFixedPosition
	"Private - relocate controls with fixed location like toolbar or status bar."

	| freeArea rect |
	freeArea := self freeClientAreaBeforeSelf.
	rect := self frameRelativeRectangle.
	self isAtTop
		ifTrue:
			[rect leftTop = freeArea leftTop
				ifFalse:
					[self resizeToRectangle: (freeArea leftTop extentFromLeftTop: rect extent).
					self superWindow invalidateRect: (rect merge: self frameRelativeRectangle).
					"w/o this, the overlapped normal controls (e.g. TextPane) won't invalidate the overlapped portion"
					]]
		ifFalse:
			[rect leftBottom = freeArea leftBottom
				ifFalse:
					[self resizeToRectangle: (freeArea leftBottom extentFromLeftBottom: rect extent).
					self superWindow invalidateRect: (rect merge: self frameRelativeRectangle).
					"w/o this, the overlapped normal controls (e.g. TextPane) won't invalidate the overlapped portion"
					]].
	!  
notifyNeedtext: address
	" Private - process the TtnNeedtext message to get the receiver's tip text."

	| tool tip addr tipTextStruct |
	tipTextStruct := WinTooltiptext atAddress: address.
	tool := toolIDs at: tipTextStruct idFrom ifAbsent: [nil].
	tool isNil
		ifFalse: [tip := tool tipText].
	tip isNil
		ifTrue: [tip := ''].
	addr := ExternalAddress copyToNonSmalltalkMemoryZ: tip.
	tipTextStruct
		lpszText: (addr uLongAtOffset: 0);
		hinst: 0. "don't use resource"
	self sendInputEvent: #freeAddress: with: addr.
	^0! 
width
	"Answer the width of the receiver."

	bitmap isNil
		ifTrue: [^self class defaultWidth].
	^bitmap!
fromFile: aFileName
	"Set the receiver's bitmap from <aFileName>.
        aFileName should be a .BMP file. "

	self bitmap: (self bitmapClass fromFile: aFileName)!   
defaultHeight
	" Answer the default  height of the receiver "

	^22!   
triggerClickedEvent
	"Private - trigger the clicked event."

	self parent triggerEvent: #clicked: with: self.
	self triggerEvent: #clicked !  
defaultStyle
	"Private - Answer the default style of the receiver. "

	^TbstyleTooltips!   
new
	"Answer a new instance of the receiver."

	^super new initialize! 
freeAddress: address
	"Private - Free allocated <address>."

	address free!
addState: stateBits
	"Private - if state is nil, initialize it appropriately.
          then add the given state bits to the flag.  Answer the new state."

	state isNil
		ifTrue: [state := self defaultState].
	state := state | stateBits.
	^state! 
notCustomizable
	" Remove the customizable style of the receiver.
      The user cannot  rearrange the tools in the tool bar and the customization dialog
       does not open when  the user double-clicks on the tool bar."

	self customizable: false.!   
resizeLaterSiblings
	"Private - Resize siblings who will not affect the freeClientArea."

	| freeArea siblings pick |
	self superWindow isApplicationWindow
		ifFalse: [^self].
	freeArea := self freeClientAreaBeforeSelf.
	freeArea := self freeClientArea: freeArea.
	pick := false.
	siblings := self superWindow childrenAffectingClientArea
		select:
			[:subpane |
			subpane == self
				ifTrue:
					[pick := true.
					false] "don't resize self again"
				ifFalse:
					[pick]]. "resize guys after me"
	siblings
		do:
			[:subpane |
			subpane resize: freeArea.
			freeArea := subpane freeClientArea: freeArea].
	"resize all normal siblings"
	self superWindow children
		do:
			[:subpane |
			subpane affectsFreeClientArea
				ifFalse: [subpane resize: freeArea]]!  
tipText
	"Answer the tip text of the receiver."

	^tipText!
eventTable: aTable
	"Private - answer the table of event handlers for the receiver."

	eventTable := aTable!   
buildWindow: parentWindow
	"Private - create the window for the receiver
         using parentWindow as the parent."

	CommonControlsDLL current. "ensure open & initialized"
	self superWindow isNil
		ifTrue: [parentWindow addToolbar: self]
		ifFalse: [self superWindow addToolbar: self].
	^super buildWindow: parentWindow!
hide: aBoolean
	"Hide or show the receiver according to <aBoolean>.  
	Answer true if it is successful, else false. Trigger the #hidden or #shown event ."

	| result |
	self isHandleOk
		ifTrue:
			[result := (UserLibrary
					sendMessage: parent handle
					msg: TbHidebutton
					wparam: id
					lparam:
						(aBoolean
						ifTrue: [1]
						ifFalse: [0])) = 1.
			result
				ifTrue:
					[self
						triggerEvent:
							(aBoolean
							ifTrue: [#hidden]
							ifFalse: [#shown])].
			^result].
	aBoolean
		ifTrue: [^self addState: TbstateHidden]
		ifFalse: [^self removeState: TbstateHidden].
	! 
tipText: aString
	"Set the tip text of the receiver to aString."

	tipText := aString! 
notifyEnddrag: address
	" Private - answer true to allow the receiver to handle a end drag operation. "

	^1!  
tools
	" Answer the tools of the receiver"

	^tools!   
eventTableForEdit
	"Private - answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."

	^self eventTable!  
isDetached
	" Answer if the receiver is detached. "

	detached isNil
		ifTrue: [^false].
	^detached! 
updateTool
	" Private- Update the tool  the receiver is wrapping. "

	| tool |
	tool := self tool.
	tool hide: tool isHidden.
	tool detach: tool isDetached.
	!
autoSaveOnClose
	" Automatically save  the tool state data of the receiver  when it  is closed. "

	^self autoSaveOnClose: true.!  
indeterminate: aBoolean
	" Set the indeterminate state of the receiver to aBoolean "

	| flag |
	flag := aBoolean
		ifTrue: [1]
		ifFalse: [0].
	self isHandleOk
		ifTrue:
			[(UserLibrary
					sendMessage: parent handle
					msg: TbIndeterminate
					wparam: id
					lparam: flag)].
	aBoolean
		ifTrue: [^self addState: TbstateIndeterminate]
		ifFalse: [^self removeState: TbstateIndeterminate].
	!   
resize
	" Resize the receiver and set its rectangle extent.
       The receiver will dynamically change its height
        and width according to the tools added to it."

	self isHandleOk
		ifTrue:
			[UserLibrary
					sendMessage: self handle
					msg: TbAutosize
					wparam: 0
					lparam: 0.
			].
	self resizeNonToolbarItems!   
sizeInBytes

	^20!  
inspectorFields

	^self inspectorClass fields: #(#regKeyHandle #subKeyName #valueName)! 
regKeyHandle: aHandle

	^self uLongAtOffset: 0 put: aHandle!
regKeyHandle

	^self uLongAtOffset: 0!  
subKeyName: anInteger

	^self uLongAtOffset: 4 put: anInteger!  
subKeyName

	^self uLongAtOffset: 4!
valueName

	^self uLongAtOffset: 8! 
valueName: anInteger

	^self uLongAtOffset: 8 put: anInteger!   
isHandleOk
	"Answer whether the host window exists (has been
         created)."

	parent isNil
		ifTrue: [^false].
	^parent handle notNil and: [parent handle ~= WindowHandle nullValue]!  
hide
	"Hide the receiver.  Answer true if it is successful, else false.
      Trigger the #hidden event ."

	^self hide: true!
customizable: aBoolean
	" Set the customizable style of the receiver.
       This style allows the user to  rearrange the tools in the tool bar and
        pops up a customization dialog when the user double-clicks on the tool bar."

	aBoolean
		ifTrue: [self addStyle: CcsAdjustable]
		ifFalse: [self removeStyle: CcsAdjustable]! 
placeAtTop
	"Place the receiver at the top of a window."

	self showAtTop: true!   
showAtTop: aBoolean
	" Set where the receiver should be placed in a window."

	aBoolean
		ifTrue:
			[self removeStyle: CcsBottom.
			self addStyle: CcsTop]
		ifFalse:
			[self removeStyle: CcsTop.
			self addStyle: CcsBottom].
	self isValid
		ifTrue:
			[self setStyle: style.
			self relocateFixedPosition.
			self resizeLaterSiblings].
	!  
pressUp
	" Private - programatically press up or release the receiver."

	self isHandleOk
		ifTrue:
			[(UserLibrary
					sendMessage: parent handle
					msg: TbPressbutton
					wparam: id
					lparam: 0)].
	^self removeState: TbstatePressed!  
setItems: aToolCollection
	" Set the tools of the receiver to <aToolCollection>. "

	self contents: aToolCollection!   
unWrap
	"Unwrap the receiver. "

	^self wrap: false!   
setTip: aString
	" Set the tip string of the receiver."

	self tipText: aString!   
setSizes
	" Private - set the receiver's tool and bitmap width and height. "

	UserLibrary
			sendMessage: handle
			msg: TbButtonstructsize
			wparam: WinTbButton sizeInBytes
			lparam: 0.
	UserLibrary
			sendMessage: handle
			msg: TbSetbitmapsize
			wparam: 0
			lparam: (ExternalLong lowHalf: self bitmapWidth highHalf: self bitmapHeight) asParameter.
	UserLibrary
			sendMessage: handle
			msg: TbSetbuttonsize
			wparam: 1
			lparam: (ExternalLong lowHalf: self toolWidth highHalf: self toolHeight) asParameter.
	!
notifyQuerydelete: address
	" Prvate - answer true to allow an item in the receiver to be deleted."

	^1!  
fromModule: aFileName
id: bitmapId
	"Set the receiver's bitmap."

	self bitmap: (self bitmapClass fromModule: aFileName id: bitmapId)!
disableToolTips
	"Disable the tool tip style of the reciever."

	self toolTips: false.!
fromModule: aFileName
id: aString
	"Answer a new tool. aFileName is a DLL file name.
        aString is a BITMAP name in this DLL."

	^self new fromModule: aFileName id: aString!   
hInst: handle
	" Handle of the module instance of resource or
      0 if nID is a bitmap handle."

	self uLongAtOffset: 0 put: handle!
nID: id
	" Resource id if hInst is not 0 or the
      bitmap handle if hInst is 0."

	self uLongAtOffset: 4 put: id!  
autoSave
	" Answer if autoSave property is set (true or false). "

	^autoSave! 
bitmap: aBitmap
	" Set the bitmap of the receiver. "

	bitmap := aBitmap!  
id
	" Return the id of the receiver. "

	^id!  
disable
	" Disable the receiver.  Answer true if it is successful, else false.
       Trigger the #disabled event.  "

	^self enable: false!  
fromFile: aFileName
	"Answer a new tool. aFileName is a .BMP file name."

	^self new fromFile: aFileName!  
autoSaveOnClose: aBoolean
	" Set if the tool state data of the receiver should be saved when it  is closed. "

	^autoSave := aBoolean! 
parent
	" Answer the toolbar which contains the receiver. "

	^parent! 
defaultBitmapWidth
	" Answer the default  image width of the receiver "

	^16! 
isDetached
	" Answer if the receiver is detached from the Toolbar "

	^self propertyAt: #detached ifAbsent: [false].!  
isDisabled
	"Answer true if the receiver is disabled, else return false."

	self isHandleOk
		ifTrue:
			[^(UserLibrary
					sendMessage: parent handle
					msg: TbIsbuttonenabled
					wparam: id
					lparam: 0) = 0].
	^(self hasState: TbstateEnabled) not!
isWrapped
	"Answer true if the receiver is word wrapped, else answer false."

	^self hasState: TbstateWrap!
registrationKeyName
	" Return the registration key name  of the receiver in the RegistrationDatabase. "

	^registrationKeyName!
detach: aBoolean
	" Set if the receiver will be detached from the Toolbar "

	self propertyAt: #detached put: aBoolean!
separator
	" Answer the separator class for the receiver. "

	^ToolbarSeparator!