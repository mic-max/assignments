3.1.0.106
   
minimumAttribute: anInteger
        "Private - set the minimum attribute of the receiver to anInteger."
    min := anInteger asInteger! 
maximumAttribute: anInteger
        "Private - set the maximum attribute of the receiver to anInteger."
    max := anInteger asInteger! 
minimum
        "Answer the minimum value if numeric, or 1 if not."
    ^self isNumeric ifTrue: [ min ] ifFalse: [ 1 ]! 
upDown
        "Private - answer the UpDown portion of the receiver."
    ^upDown!  
backColor: aColor
        "Set the background color of the receiver."
    | ef |
    super backColor: aColor.
    ( ef := self entryField ) notNil ifTrue: [ ef backColor: aColor ]!  
addUpDown
		"Private - add an UpDown as a child control of the receiver."
	| ud |
	self addSubpane: ( ( ud := UpDown new )
		wrap: true;
		yourself ).
	self upDown: ud.
	self setUpDownFramingBlock!  
tabScope
        "Private - Answer the parent window which determines
        the tabbing scope for this control."
    ^self parent isWindow
        ifTrue: [ parent tabScope ]
        ifFalse: [ nil ]!   
font: aFont
		"Set the font for the receiver to aFont."
	self entryField font: aFont!   
rightJustifiedText
        "Answer a new instance of the receiver with right justified text style."
    ^self new rightJustified; yourself! 
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #changed: ;
        add: #changedIndex: ;
        add: #changing: ;
        add: #changingIndex: ;
        add: #up;  "maintained for backward compatibility"
        add: #down;  "maintained for backward compatibility"
        add: #nextLine;
        add: #previousLine;
        yourself!   
centeredText
        "Answer a new instance of the receiver with centered text style."
    ^self new centered; yourself!
leftJustifiedText
        "Answer a new instance of the receiver with left justified text style."
    ^self new leftJustified; yourself!
leftJustifiedText: master
        "Answer a new (slave) instance of the receiver with left justified text style and
        the given master."
    ^self new leftJustified; master: master; yourself!  
numeric
        "Answer a new instance of the receiver with numeric style."
    ^self new!  
numeric: master
        "Answer a new (slave) instance of the receiver with numeric style and
        the given master."
    ^self new master: master! 
rightJustifiedText: master
        "Answer a new (slave) instance of the receiver with right justified text style and
        the given master."
    ^self new rightJustified; master: master; yourself!   
centeredText: master
        "Answer a new (slave) instance of the receiver with centered text style and
        the given master."
    ^self new centered; master: master; yourself!  
contents
		"Answer the contents of the receiver, its list of elements."
	^self list!
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    ^Dictionary new
        at: SbEndscroll put: #notifyEndScroll: ;
        at: SbThumbposition put: #notifySliderPosition: ;
        yourself!
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #changing: ;
        yourself!
valueIndex: anInteger
        "Set the index of the current selection."
	anInteger isNil ifTrue: [ ^nil ].
    self selectIndex: anInteger!
listAttribute
        "Private - answer the receiver's list attribute."
    ^list!  
setList: aList
		"Set the contents of the receiver."
	aList isNil ifTrue: [ ^self ].
	self contents: aList.
	^aList!  
setValue: anObject
        "Set the current selection and trigger the changed: event if changed."
	| previousValue |
	previousValue := self value.
	( self value: anObject ) isNil ifTrue: [ ^nil ].
	self value ~= previousValue ifTrue: [ self triggerChanged ]!   
upDown: anUpDown
		"Private - set the UpDown portion of the receiver tro anUpDown."
	upDown := anUpDown!
triggerChanged
        "Private - trigger the changed: event."
    self triggerEvent: #changed: with: self selectedItem.
    self triggerEvent: #changedIndex: with: self selectedIndex!   
selectedItem
        "Answer the value currently displayed in the receiver."
    | index |
    index := self selectedIndex.
	^self isNumeric
		ifTrue: [ index ]
        ifFalse: [ self listAttribute at: index ]! 
entryFieldLosingFocus
        "Private - the child entry field control is losing the input focus;
		disconnect the receiver from the up down."
    self disconnectUpDown.
    self isMaster ifFalse: [ self upDown: nil ]!
setUpDownFramingBlock
		"Private - add an UpDown as a child control of the receiver."
	self upDown framingBlock: [ :box |
		( box rightTop left: box height // 2 ) extentFromLeftTop: ( box height // 2 ) @ box height ]!  
readOnly
        "Set the read only style of the receiver."
    self readOnly: true!
last
        "Answer the receiver's last item."
    self isNumeric ifTrue: [ ^self maximum ].
    ^self listAttribute last
!  
entryFieldGettingFocus
        "Private - the child entry field control is getting the input focus;
		connect the receiver to the up down (which may be the master's up down)."
    self isMaster ifFalse: [ self upDown: self master upDown ].
    self disconnectUpDown.
    self connectToUpDown! 
setText
        "Private - update the text portion of the receiver."
    self entryField contents: self selection asString! 
valueAttribute
        "Private - answer the receiver's value attribute."
    ^value!   
setEntryFieldFramingBlock
		"Private - add an EntryField as a child control of the receiver."
	self entryField framingBlock: [ :box |
		box leftTop extentFromLeftTop: ( box width - ( box height // 2 ) ) @ box height ]! 
disconnectUpDown
        "Private - unlink the receiver's entry field portion from the current upDown."
    self upDown
        removeActionsForEvent: #changed: ;
        removeActionsForEvent: #changing: ;
        removeActionsForEvent: #nextLine;
        removeActionsForEvent: #previousLine!  
centered
        "Make the entry field component of the receiver centered."
    self entryField centered!   
selectedIndex
        "Answer the index of the current selection."
    ^self valueAttribute!
entryField
        "Private - answer the EntryField portion of the receiver."
    ^entryField!  
rightJustified
        "Make the entry field component of the receiver right justified."
    self entryField rightJustified!
spinDown: anInteger
        "Spin the receiver down the amount anInteger."
    self spin: anInteger negated!
minimum: minimumValue maximum: maximumValue
        "Set the minimum and maximum values for the receiver."
    self minimumAttribute: minimumValue.
    self maximumAttribute: maximumValue.
    self upDown notNil ifTrue: [ self upDown minimum: minimumValue maximum: maximumValue ]!  
entryFieldClass
        "Private - answer the class of the entry field part of the receiver."
    ^SpinButtonEntryField!
initialize
		"Private - set the initial state of the receiver."
	self minimumAttribute: 1; maximumAttribute: 10; valueAttribute: 1.
	self addEntryField.
	self rightJustified.  "default is numeric"
	self addUpDown.
	super initialize!
isReadOnly
        "Answer whether the receiver is read only."
    ^self entryField isReadOnly! 
spin: anInteger
        "Spin the receiver by the amount anInteger (up if positive, down if negative)."
    self valueAttribute: self valueAttribute + anInteger.
    self valueAttribute > self maximum ifTrue: [ self valueAttribute: self minimum ].
    self valueAttribute < self minimum ifTrue: [ self valueAttribute: self maximum ].
    self upDown notNil ifTrue: [ self upDown value: self valueAttribute ].
    self setText.
    self triggerEvent: ( anInteger positive ifTrue: [ #up ] ifFalse: [ #down ] ).
    self triggerEvent: ( anInteger positive ifTrue: [ #nextLine ] ifFalse: [ #previousLine ] ).
    self triggerChanging; triggerChanged!   
isMaster
        "Answer whether the receiver is a master control."
    ^self master isNil! 
selectIndex: anInteger
        "Set the index of the current selection to anInteger."
    self valueAttribute: anInteger.
    self upDown notNil ifTrue: [ self upDown value: anInteger ].
    self setText!  
spinUp: anInteger
        "Spin the receiver up by the amount anInteger."
    self spin: anInteger! 
isNumeric
        "Private - Answer true if the receiver is a numeric spin control."
    ^self listAttribute isNil! 
readOnly: aBoolean
        "Set the read only style of the receiver to aBoolean."
    self entryField readOnly: aBoolean!   
defaultStyle
		"Private - Answer the receiver's default style.  Override the
		superclass implementation to remove border style."
    ^0!  
list: aCollection
        "Set the contents of the receiver to the given list."
    self listAttribute: ( ( aCollection isNil or: [ aCollection isEmpty ] ) ifTrue: [ nil ] ifFalse: [ aCollection ] ).
    ( self listAttribute notNil and: [ self upDown notNil ] )
        ifTrue: [ self upDown minimum: 1 maximum: self listAttribute size ].
	( self valueAttribute between: 1 and: self listAttribute size )
		ifFalse: [ self valueAttribute: 1 ].
	self setText!  
validate
		"Private - The host window for the receiver was
		just created or recreated."
	super validate.
	self isMaster ifTrue: [ self connectToUpDown ].
	self setText!
master: aSpinButton
		"Set the master control of the receiver."
	master := aSpinButton.
	self entryField framingBlock: [ :box | box ].
	self upDown notNil ifTrue: [ self removeSubpane: self upDown ].
	self upDown: nil!   
maximum: anInteger
        "Set the maximum value of a numeric control to anInteger."
    self maximumAttribute: anInteger.
    self upDown notNil ifTrue: [ self upDown maximum: anInteger ]! 
minimum: anInteger
        "Set the minimum value of a numeric control to anInteger."
    self minimumAttribute: anInteger.
    self upDown notNil ifTrue: [ self upDown minimum: anInteger ]! 
setTextLimit: anInteger
        "Set the maximum number of characters
         that the receiver can hold to anInteger."
    self entryField setTextLimit: anInteger!  
leftJustified
        "Make the entry field component of the receiver left justified."
    self entryField leftJustified!   
noBorder
        "Private - Set the receiver to have no border."
    self entryField removeStyle: WsBorder! 
selection: integerOrObject
        "Set the current selection to integerOrObject."
	| index |
	index := integerOrObject isInteger
		ifTrue: [ integerOrObject ]
		ifFalse: [ self listAttribute indexOf: integerOrObject ].
	self selectIndex: index!   
value: anObject
		"Set the value of the receiver."
	anObject isNil ifTrue: [ ^nil ].
	self selectItem: ( self isNumeric ifTrue: [ anObject asInteger ] ifFalse: [ anObject ] )!
maximum
        "Answer the maximum value if numeric, or the size of the list if not."
    ^self isNumeric ifTrue: [ max ] ifFalse: [ self listAttribute size ]!
setFocus
        "Set the current input focus to be the receiver.
        For a SpinButton, the entry field part of the control
        receives the input focus."
	self entryField setFocus! 
upDownNextLine
        "Private - the receiver's UpDown selection moved to the next line."
    self triggerEvent: #up.
    self triggerEvent: #nextLine!   
losingFocus
		"Private - the receiver is losing the input focus;
		notify my parent (the SpinButton)."
	self parent entryFieldLosingFocus.
	super losingFocus!
keyboardInput: aKeyboardInputEvent
        "Private - pass on keyboard input to the parent (SpinButton)."
	self parent entryFieldKeyboardInput: aKeyboardInputEvent!
wmCharResultFor: aCharacter
        "Private - Answer the value to return to the host operating system
       character input message when aCharacter is being entered."
    ^( aCharacter = Tab or: [ aCharacter = Cr ] )
        ifTrue: [ 0 ]
        ifFalse: [ nil ]!   
wmKeydown: wordInteger with: longInteger
		"Private - Process the key down message.  Override superclass
		implementation to return 0, so keys like Tab and Delete are ignored."
	super wmKeydown: wordInteger with: longInteger.
	^0!
gettingFocus
		"Private - the receiver is getting the input focus;
		notify my parent (the SpinButton)."
	self parent entryFieldGettingFocus.
	super gettingFocus!
buddy
        "Private - answer the receiver's buddy control."
    ^buddy!  
buddy: aWindow
        "Private - set the receiver's buddy control to aWindow."
    buddy := aWindow.
    self isHandleOk ifTrue: [ self setBuddy ]!   
windowClass
        "Private - Answer the window class for the receiver."
    ^UpdownClass! 
wrap: aBoolean
        "Turn wrapping on or off, according to aBoolean."
    aBoolean
        ifTrue: [ self addStyle: UdsWrap ]
        ifFalse: [ self removeStyle: UdsWrap ].
    self setStyle: self style!  
isHorizontal
        "Answer whether the receiver is horizontal style."
    ^self hasStyle: UdsHorz!
setPosition
        "Private - Set the position of the host control."
    UserLibrary
        sendMessage: self handle
        msg: UdmSetpos
        wparam: 0
        lparam: ( ExternalLong lowHalf: self valueAttribute highHalf: 0 ) asParameter!  
notifySliderPosition: newValue
        "Private - the host signaled that the position changed during scrolling."
    | oldValue wrapped lineEvent |
    ( oldValue := self valueAttribute ) = newValue ifTrue: [ ^self ].
    wrapped := ( newValue = self maximum and: [ oldValue = self minimum ] ) or:
        [ newValue = self minimum and: [ oldValue = self maximum ] ].
    lineEvent := newValue > oldValue
        ifTrue: [ wrapped ifTrue: [ #previousLine ] ifFalse: [ #nextLine ] ]
        ifFalse: [ wrapped ifTrue: [ #nextLine ] ifFalse: [ #previousLine ] ].
    self
        valueAttribute: newValue;
        triggerEvent: lineEvent.
    self triggerChanging!
setRange
        "Private - update the host control's range (minimum and maximum)."
    UserLibrary
        sendMessage: self handle
        msg: UdmSetrange
        wparam: 0
        lparam: ( ExternalLong lowHalf: self maximum highHalf: self minimum ) asParameter!  
initialize
        "Private - Initialize the receiver."
    super initialize.
    self
        valueAttribute: 1;
        minimumAttribute: 1;
        maximumAttribute: 10!
buildWindow: parentWindow
        "Private - Create the window for the receiver, initializing the
        common controls library if necessary."
    CommonControlsDLL current.
    ^super buildWindow: parentWindow! 
lineIncrement: anInteger
        "Private - ignored; the lineIncrement for an UpDown is always 1."!  
setBuddy
        "Private - set the host control's buddy control."
    | buddyHandle |
    buddyHandle := self buddy notNil ifTrue: [ self buddy handle ] ifFalse: [ 0 ].
    UserLibrary
        sendMessage: self handle
        msg: UdmSetbuddy
        wparam: buddyHandle
        lparam: buddyHandle.
    self buddy setWindowText: self valueAttribute printString!  
isVertical
        "Answer whether the receiver is vertical style."
    ^self isHorizontal not! 
setMaximum
        "Private - update the host control's maximum value."
    self setRange!  
wrap
        "Answer whether wrapping is enabled."
    ^self hasStyle: UdsWrap! 
defaultStyle
        "Private - Answer the default style for the receiver."
    ^UdsSetbuddyint | UdsArrowkeys! 
vertical
        "Set the vertical style."
    self removeStyle: UdsHorz.
    self setStyle: self style!   
validate
        "Private - The host window for the receiver was
        just created or recreated."
    super validate.
    self buddy notNil ifTrue: [ self setBuddy ].
    self resize: ( 0@0 extent: parent extent )  "workaround to control strangeness when has a buddy"
!
setFocus
        "Set the current input focus to be the receiver.  If the receiver is part
        of a SpinButton, set the focus to the (entry field part of) the SpinButton."
	self parent class == SpinButton
		ifTrue: [ self parent setFocus ]
		ifFalse: [ super setFocus ]!   
horizontal
        "Set the horizontal style."
    self addStyle: UdsHorz.
    self setStyle: self style!  
notifyEndScroll: aParameter
        "Private - the host signaled that scrolling completed."
    self triggerChanged!
setMinimum
        "Private - update the host control's minimum value."
    self setRange!  
triggerChanging
        "Private - the receiver's position is changing."
    self triggerEvent: #changing: with: self position! 
button1Down: aPoint
        "Private - left button was pressed.  If the receiver is part of a SpinButton,
        set the focus to the (entry field of the) SpinButton."
	self parent class == SpinButton
		ifTrue: [ self parent setFocus ]! 
first
        "Answer the receiver's first item."
    self isNumeric ifTrue: [ ^self minimum ].
    ^self listAttribute first
!   
connectToUpDown
        "Private - link the receiver's entry field portion to the current upDown."
    self upDown
        when: #changing: send: #upDownChanging: to: self;
        when: #changed: send: #upDownChanged: to: self;
        when: #nextLine send: #upDownNextLine to: self;
        when: #previousLine send: #upDownPreviousLine to: self.
    self upDown minimum: self minimum maximum: self maximum position: self valueAttribute!
list
		"Answer the list of elements contained in the receiver."
	^self listAttribute!   
foreColor: aColor
        "Set the foreground color of the receiver."
	self entryField foreColor: aColor!   
setValueIndex: anInteger
        "Set the index of the current selection and trigger the changed: event if changed."
	| previousIndex |
	previousIndex := self valueIndex.
	( self valueIndex: anInteger ) isNil ifTrue: [ ^nil ].
	self valueIndex ~= previousIndex ifTrue: [ self triggerChanged ]!
masterAttribute: aSpinButton
        "Private - set the master attribute to aSpinButton."
    master := aSpinButton!
contents: aCollection
        "Set the receiver's contents to aCollection."
    ( aCollection size >= 2 and: [ aCollection first isNumber and: [ aCollection last isNumber ] ] )
        ifTrue: [ self minimum: aCollection first maximum: aCollection last ]
        ifFalse: [ self list: aCollection ]!   
maxSize: anInteger
        "Obsolete - Set the maximum number of characters
        in the receiver to anInteger.  Maintained for backward
        compatibility, use setTextLimit: instead."
    self setTextLimit: anInteger!   
entryFieldKeyboardInput: aKeyboardInputEvent
        "Private - process tab keys, arrow keys (to spin the control's value),
        and mnemonic match characters."
    | character virtualKey itemIndex |
    ( ( virtualKey := aKeyboardInputEvent virtualKey ) notNil and: [
        ( virtualKey == TabKey or: [ virtualKey == BacktabKey ] ) ] )
            ifTrue: [ self tabKeyInput: aKeyboardInputEvent ].
    virtualKey = ReturnKey ifTrue: [ ^self ].  "ignore, to make act like single line entry field."
    virtualKey = UpKey ifTrue: [ self spinUp: 1. ^self ].
    virtualKey = DownKey ifTrue: [ self spinDown: 1. ^self ].
    self isReadOnly ifFalse: [ ^self ]. "only process as mnemonics if read only"
    ( character := aKeyboardInputEvent character ) notNil ifTrue: [
        ( itemIndex := self indexOfCharacter: character startingAt: self valueAttribute ) ~= 0
            ifTrue: [ self selection: itemIndex ] ]! 
indexOfCharacter: aCharacter startingAt: index
        "Private - answer the index of the first element in the list which begins with the
        given character (case insensitive search), or 0 if none.  Start searching
        at the specified index, and wrap around if necessary."
    ( self listAttribute isNil or: [ self listAttribute size = 1 ] ) ifTrue: [ ^0 ].
    ( index + 1 to: self listAttribute size ), ( 1 to: index - 1 ) do: [ :i |
        ( self listAttribute at: i ) first asLowerCase = aCharacter asLowerCase ifTrue: [ ^i ] ].
    ^0!
valueAttribute: aString
        "Private - set the receiver's value attribute."
    value := aString!   
entryField: anEntryField
        "Private - set the entry field portion of the receiver to anEntryField."
    entryField := anEntryField!   
upDownPreviousLine
        "Private - the receiver's UpDown selection moved to the previous line."
    self triggerEvent: #down.
    self triggerEvent: #previousLine! 
listAttribute: anArray
        "Private - set the list in the receiver without
        attempting to update the pane."
    list := anArray!
master
        "Answer the master control of the receiver."
    ^master!
selection
        "Answer the value currently displayed in the receiver."
    ^self selectedItem!   
addEntryField
		"Private - add an entry field as a child control of the receiver."
	| ef |
	self addSubpane: ( ( ef := self entryFieldClass new )
		removeStyle: WsVscroll;
		removeStyle: WsHscroll;
		yourself ).
	self entryField: ef.
	self setEntryFieldFramingBlock!
triggerChanging
        "Private - the receiver's position is changing."
    self triggerEvent: #changing: with: self value.
    self triggerEvent: #changingIndex: with: self selectedIndex!  
selectItem: anObject
        "Set the selection to anObject."
	self selectIndex: ( self listAttribute indexOf: anObject )!  
value
		"Answer the value of the receiver."
	^self selectedItem!
valueIndex
        "Answer the index of the current selection."
    ^self selectedIndex!
upDownChanged: anInteger
        "Private - the receiver's UpDown has changed its selection."
    self triggerChanged!  
upDownChanging: anInteger
        "Private - the receiver's UpDown is changing its selection."
    self selection: anInteger.
    self triggerChanging!