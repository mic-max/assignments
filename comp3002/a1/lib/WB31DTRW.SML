"3.0.0.16"
! 

Object subclass: #WBTranslator
  instanceVariableNames: 
    ' classToTranslate prototype codeGenerator '
  classVariableNames: ''
  poolDictionaries: ''!  

WBTranslator subclass: #WBEventTranslator
  instanceVariableNames: 
    ' eventMap '
  classVariableNames: 
    ' DefaultEventMap '
  poolDictionaries: ''!

ViewManager subclass: #WBEventTranslationEditor
  instanceVariableNames: 
    ' newEventListBox eventMapListBox classListBox owner selectedClass eventMapKeys eventMap newEvents selectedOldEvent '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '! 

Object subclass: #WBEventMap
  instanceVariableNames: 
    ' map '
  classVariableNames: ''
  poolDictionaries: ''! 

ViewManager subclass: #WBTranslationChooser
  instanceVariableNames: 
    ' owner classNameListBox filters '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '!

WBTranslator subclass: #WBNLSTranslator
  instanceVariableNames: 
    ' poolManager pools category menuAcceleratorCount '
  classVariableNames: ''
  poolDictionaries: 
    ' CharacterConstants '!

WBNLSTranslator subclass: #WBNLSReplacementTranslator
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!   

WBNLSTranslator subclass: #WBNLSExtractionTranslator
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

!WBEventMap methods !   
storeMapOn: aStream
	"Store the receiver's definition on aStream."
	
	aStream
		nextPutAll: self class name;
		space;
		nextPutAll: #new;
		indentBy: 1.
	
	self map keys asSortedCollection
		do: [ :eachClass |
			self
				store: (self map at: eachClass)
				forClass: eachClass
				on: aStream ].
		
	aStream
		cr; 
		cr;
		nextPutAll: #yourself;
		indentBy: -1;
		endExpression.
! !

!WBEventTranslationEditor methods !  
eventMappingFor: anOldEvent in: aClass
	"Answer a string representing the event mapping."
	
	| newEvent auto answer |
	newEvent := eventMap map: anOldEvent forClass: aClass.
	newEvent isNil ifTrue: [ ^anOldEvent ].
	answer := anOldEvent.
	newEvent value notNil ifTrue: [
		answer := answer, ' ==> ', newEvent value ].
	auto := eventMap autoMap: anOldEvent forClass: aClass.
	(auto notNil and: [ newEvent value = auto value ]) ifFalse: [
		answer := answer, ' [', newEvent key printString, ']' ].
	^answer
! !

!WBEventTranslationEditor methods !  
openOn: anObject class: aClass

	owner := anObject.
	eventMap := owner defaultEventMap copy.
	self
		open;
		updateClasses: aClass.! !

!WBTranslator methods !   
with: aCollection do: aBlock
	"Evaluate aBlock with each of the panes."

	aCollection do: [ :each |
		aBlock evaluateFor: each.
		self with: each childrenInBuildOrder do: aBlock ].! !

!WBNLSTranslator methods !
translateMenu: aMenu string: aString in: aPane
	"Extract the specified string."

	^self implementedBySubclass! !

!WBEventTranslationEditor methods !
updateEventMap
	"Update the event map."

	eventMapKeys := selectedClass supportedEvents asSortedCollection asArray.
	(eventMapKeys includes: selectedOldEvent) ifFalse: [ selectedOldEvent := nil ].
	eventMapListBox contents: (
		eventMapKeys collect: [ :each |
			self eventMappingFor: each in: selectedClass ] ).
	selectedOldEvent notNil
		ifTrue: [
			eventMapListBox selectIndex: (
				eventMapKeys indexOf: selectedOldEvent ) ]
		ifFalse: [
			eventMapListBox selection: nil ].! !

!WBEventTranslationEditor class methods ! 
wbBasicVersion

	"Private - Answer the WindowBuilder Pro version.
		Generated in: Visual Smalltalk Enterprise 3.1.0 Win32"

	^3.1! !

!WBNLSReplacementTranslator methods !
translateButtonLabel
	"Answer the label to be used in the translate button."

	^'Replace'! !

!WBTranslator methods !
windowBuilder

	^self prototype owner! !

!WBEventTranslator class methods !  
compileDefaultEventMap
	"Compile the default event map."
	"
	WBEventTranslator compileDefaultEventMap.
	"

	| stream result source |
	stream := WBCodeStream new.
	
	stream
		nextPutAll: #constructDefaultEventMap;
		indentBy: 1;
		cr;
		nextPutComment: self defaultEventMapComment;
		cr;
		cr;
		nextPutAll: '^'.

	self defaultEventMap storeMapOn: stream.

	source := stream contents.
	result := self class compile: source.
	result notNil ifTrue: [
		result value sourceString: source ]! !

!WBEventMap methods !  
store: aDictionary forClass: aClass on: aStream
	"Private - store the definitions for aClass."
	
	| auto dict |
	dict := Dictionary new.
	aDictionary associationsDo: [ :each |
		auto := self autoMap: each key forClass: aClass.
		(auto notNil and: [ auto value = each value ]) ifFalse: [
			dict add: each ] ].
	dict isEmpty ifTrue: [ ^self ].
	
	aStream
		cr;
		cr;
		nextPutAll: #mapForClass:;
		space;
		nextPutAll: '#', aClass;
		space;
		nextPutAll: #putAll:;
		space;
		nextPutAll: '(';
		indentBy: 1.
		
	aStream
		cr;
		nextPutAll: #Dictionary;
		space;
		nextPutAll: #new;
		indentBy: 1.
		
	dict associationsDo: [ :each |
		aStream
			cr;
			nextPutAll: #at:;
			space;
			nextPutAll: each key storeString;
			space;
			nextPutAll: #put:;
			space;
			nextPutAll: each value storeString;
			endMessage ].
	
	aStream
		cr;
		nextPutAll: #yourself;
		nextPutAll: ')';
		indentBy: -2;
		endMessage.
! !

!WBNLSTranslator methods !
pools

	^pools ifNil: [self poolManager pools]! !

!WBEventTranslationEditor methods !
argumentMissMatchWarning

	MessageBox warning:
		'Old event arguments do not match new event arguments.'.! !

!WBEventTranslationEditor methods !
createViews

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."

	| cancelButton mainView okButton xDU yDU |
	
	#generated.
	xDU := (SysFont width + 1 roundTo: 2) / 4.
	yDU := SysFont height / 8.
	mainView := self topPaneClass new.
	
		"Instance Variables"
	classListBox := ListBox new.
	eventMapListBox := ListBox new.
	newEventListBox := ListBox new.
	
		"Temporary Variables"
	cancelButton := Button new.
	okButton := Button new.
	
	mainView
		owner: self;
		setName: 'mainView';
		labelWithoutPrefix: 'Event Translation Editor';
		noSmalltalkMenuBar;
		backColor: Color gray;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1/2; leftInset: -124 * xDU;
				topRatio: 1/2; topInset: -90 * yDU;
				rightRatio: 1/2; rightInset: -124 * xDU;
				bottomRatio: 1/2; bottomInset: -81 * yDU).
	self addView: mainView.
	
	cancelButton "Button"
		owner: self;
		setName: 'cancelButton';
		when: #clicked send: #close to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1; leftInset: -38 * xDU;
				topRatio: 1; topInset: -35/2 * yDU;
				rightRatio: 1; rightInset: 3 * xDU;
				bottomRatio: 1; bottomInset: 7/2 * yDU);
		cancelPushButton;
		contents: 'Cancel';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: cancelButton.
	
	okButton "Button"
		owner: self;
		setName: 'okButton';
		when: #clicked send: #save to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1; leftInset: -80 * xDU;
				topRatio: 1; topInset: -35/2 * yDU;
				rightRatio: 1; rightInset: 44 * xDU;
				bottomRatio: 1; bottomInset: 7/2 * yDU);
		defaultPushButton;
		contents: 'Ok';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: okButton.
	
	newEventListBox "ListBox"
		owner: self;
		setName: 'newEventListBox';
		when: #changed: send: #selectNewEvent: to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1/2; leftInset: 40 * xDU;
				topRatio: 0; topInset: 2 * yDU;
				rightRatio: 1; rightInset: 2 * xDU;
				bottomRatio: 1; bottomInset: 43/2 * yDU);
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: newEventListBox.
	
	eventMapListBox "ListBox"
		owner: self;
		setName: 'eventMapListBox';
		when: #changed: send: #selectOldEvent: to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 2 * xDU;
				topRatio: 1/2; topInset: 7/2 * yDU;
				rightRatio: 1/2; rightInset: -38 * xDU;
				bottomRatio: 1; bottomInset: 3/2 * yDU);
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: eventMapListBox.
	
	classListBox "ListBox"
		owner: self;
		setName: 'classListBox';
		when: #changed: send: #selectClass: to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 2 * xDU;
				topRatio: 0; topInset: 2 * yDU;
				rightRatio: 1/2; rightInset: -38 * xDU;
				bottomRatio: 1/2; bottomInset: -3/2 * yDU);
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: classListBox! !

!WBTranslator methods !
message: aString
	"Append a message to the current output medium."

	Transcript cr; nextPutAll: aString.! !

!WBTranslationChooser methods ! 
addFlatFilter: filterBlock named: filterName withAllSubclassesOf: aClass
	"Append a new filter."

	| newFilterList |
	newFilterList := SortedCollection new: 100.
	aClass withAllSubclasses do: [:each |
		(filterBlock value: each) ifTrue: [
			newFilterList add: each symbol => each]].
	self filters add: filterName => newFilterList.! !

!WBNLSExtractionTranslator methods !
translateButtonLabel
	"Answer the label to be used in the translate button."

	^'Extract'! !

!WBNLSTranslator methods ! 
category: aCategory

	category := aCategory.! !

!WBEventTranslationEditor class methods !
isWBInternalClass

	^true! !

!WBNLSTranslator methods !  
poolManager

	^poolManager! !

!WBEventTranslationEditor methods !
updateClasses: aClass
	"Update the classes list box."
	
	classListBox contents: (
		self classNamesFor: aClass indent: 1 ).! !

!WBTranslationChooser methods ! 
openOn: aClass owner: anObject

	Notifier isAltKeyDown ifTrue: [self showInternal: true].
	owner := anObject.
	self
		addFiltersForClass: aClass;
		open.! !

!WBNLSReplacementTranslator methods !   
save
	"Private - Recreate the #createViews method."

	self pools collect: [:each |
		self classDefinition addPoolNamed: each poolName].
	super save.! !

!WBEventTranslationEditor methods !   
classNamesFor: aClass indent: anInteger
	"Answer a collection of class and subclass names."

	| answer |
	(answer := OrderedCollection new)
		add: (
			((String new: anInteger) atAllPut: $ ; yourself),
			aClass name ).
	((aClass subclasses
		select: [ :each | each symbol first ~= $  ])
		asSortedCollection: [ :a :b | a symbol < b symbol ])
		do: [ :each |
			answer addAll: (
				self
					classNamesFor: each
					indent: anInteger + 2 ) ].
	^answer! !

!WBEventTranslator methods !  
loadMessage
	"Answer a progress message."

	^'Translating ', self classToTranslate printString, '...'! !

!WBNLSExtractionTranslator methods !   
newKeyForMenu: aMenu for: aString in: aPane
	"Answer a new key for the specified string."

	| answer index |
	answer := aMenu title.
	answer := 'Menu', answer, 'Label'.
	answer := self poolManager class validKey: answer.
	(self poolManager at: answer ifAbsent: [nil]) isNil ifTrue: [^answer].
	index := 2.
	[(self poolManager at: answer, index printString ifAbsent: [nil]) isNil]
		whileFalse: [index := index + 1].
	^answer, index printString! !

!WBNLSTranslator methods !   
pool

	^self pools first! !

!WBEventTranslator methods ! 
warning: aString
	"Append a message to the user."
	
	self message: '        WARNING!! ', aString.! !

!WBTranslator methods !
prototype
	"Answer the receiver's prototype."

	^prototype ifNil: [
		prototype := self defaultPrototype].! !

!WBNLSTranslator class methods ! 
translateFor: aPoolManager category: aCategory

	| translator |
	(translator := self new)
		poolManager: aPoolManager;
		category: aCategory.
	WBTranslationChooser new
		owner: translator;
		open.
	^translator! !

!WBEventTranslationEditor methods !  
selectOldEvent: selectedItem

	"Callback for the #changed: event triggered in the ListBox named 'eventMapListBox'.
	 (Generated by WindowBuilder)"

	self selectOldEvent: selectedItem pane: eventMapListBox.! !

!WBEventTranslator methods ! 
translateEventsFor: aPane
	"Translate the events for aPane."

	| newEvent eventHandler |
	aPane wbRealWidget handlers keys do: [ :oldEvent |
		newEvent := self newEventFor: oldEvent class: aPane realClass.
		newEvent notNil
			ifTrue: [
				self
					message: oldEvent, ' ==> ', newEvent
					pane: aPane.
				eventHandler := aPane wbRealWidget handlers at: oldEvent.
				eventHandler isMessage ifTrue: [eventHandler := eventHandler selector].
				self
					compareArgsFor: oldEvent
					with: newEvent
					pane: aPane
					handler: eventHandler.
				aPane wbRealWidget
					when: newEvent
					send: eventHandler
					to: self prototype targetObject.
				aPane wbRealWidget handlers
					removeKey: oldEvent ]
			ifFalse: [
				self
					message: 'Ignored old event #', oldEvent
					pane: aPane ] ].! !

!WBEventMap methods ! 
autoMap: anOldEvent forClass: aClass
	"Look for a new event with the same name
		or with the same name followed by a colon."

	| cls |
	cls := aClass isSymbol
		ifTrue: [ Smalltalk at: aClass ifAbsent: [ ^nil ] ]
		ifFalse: [ aClass ].
	(Array
		with: anOldEvent
		with: (anOldEvent, ':') asSymbol
	) do: [ :each |
		(cls eventsTriggered includes: each) ifTrue: [
			^Association key: cls value: each ] ].
	^nil! !

!WBEventTranslationEditor methods !   
updateNewEventList
	"Update the new event list."

	newEvents :=
		(Array with: self noEventString),
		selectedClass eventsTriggered asSortedCollection asArray.
	newEventListBox contents: newEvents.
	self updateNewEventListSelection.! !

!WBTranslationChooser methods ! 
owner: anObject

	owner := anObject.! !

!WBTranslator methods !  
classToTranslate
	"Answer the class to translate."

	^classToTranslate! !

!WBNLSReplacementTranslator methods ! 
windowLabel
	"Answer the label to be used in the chooser window."

	^'Replace strings in...'! !

!WBEventTranslator methods !
compareArgsFor: oldEvent with: newEvent pane: aPane handler: eventHandler

	| newArgNames first |
	newEvent last = $: ifFalse: [ ^self ].
	newArgNames := ''.
	first := true.
	(aPane wbPropertyManager wbEventNamed: newEvent) arguments do: [ :each |
		first 
			ifTrue: [ first := false ] 
			ifFalse: [ newArgNames := newArgNames, ', ' ].
		newArgNames := newArgNames, each ].
	self
		warning: 'Old event and new event argument(s) do not match.';
		message: '        old event argument = aPane';
		message: '        new event argument(s) = ', newArgNames;
		message: '        You will need to rewrite the ',
			self classToTranslate printString,
			'>>', eventHandler, ' method'.
		! !

!WBEventTranslationEditor methods ! 
selectOldEvent: selectedItem pane: aPane

	"Callback for the #changed: event triggered in the ListBox named 'eventMapListBox'.
	 (Generated by WindowBuilder)"

	selectedOldEvent := eventMapKeys at: aPane selectedIndex.
	self updateNewEventListSelection.! !

!WBEventMap methods !   
map: anOldEvent forClass: aClass put: aNewEvent

	| superEvent classMap |
	superEvent := self
		map: anOldEvent
		forClass: aClass superclass.
	superEvent notNil ifTrue: [
		superEvent := superEvent value ].
	superEvent = aNewEvent
		ifTrue: [
			classMap := self mapForClass: aClass ifAbsent: [ ^self ].
			classMap removeKey: anOldEvent ifAbsent: [ ].
			classMap isEmpty ifTrue: [ 
				self map removeKey: (self keyForClass: aClass) ] ]
		ifFalse: [
			(self mapForClass: aClass)
				at: anOldEvent put: aNewEvent ].! !

!WBTranslator methods ! 
defaultPrototype
	"Answer the default prototype."

	| answer |
	answer := WBPrototype
		on: self classToTranslate
		owner: WindowBuilder basicNew.

	"Force dialogs to be aligned to the screen."
	[answer shell wbRealWidget alignRelativeToScreen] on: Error do: [ ].

	^answer! !

!WBNLSTranslator methods ! 
translate
	"Private - Perform the translation."

	self views do: [:eachView |
		self translateStringsIn: eachView wbRealWidget.
		eachView children do: [:eachChild |
			self translateStringsIn: eachChild wbRealWidget]].! !

!WBEventMap methods ! 
localMap: anOldEvent forClass: aClass

	^(self
		mapForClass: aClass ifAbsent: [ ^nil ])
		at: anOldEvent ifAbsent: [ ^nil ]! !

!WBNLSTranslator class methods !   
translateFor: aPoolManager pool: aPool category: aCategory

	| translator |
	(translator := self new)
		poolManager: aPoolManager;
		pool: aPool;
		category: aCategory.
	WBTranslationChooser new
		owner: translator;
		open.
	^translator! !

!WBTranslator methods !  
classDefinition

	^self codeGenerator classDefinitionFor: self classToTranslate! !

!WBTranslationChooser methods !   
hierarchicalFilter: filterBlock indent: indent withAllSubclassesOf: aClass
	"Answer a collection of new filter elements."

	| answer |
	answer := OrderedCollection new.
	answer add: ((String new: indent) atAllPut: $ ; yourself), aClass name => aClass.
	(aClass subclasses asSortedCollection: Class sortBlock) do: [:eachSubclass |
		answer addAll: (self hierarchicalFilter: filterBlock indent: indent + 2 withAllSubclassesOf: eachSubclass)].
	answer size = 1 ifTrue: [
		(filterBlock value: answer first value) ifFalse: [
			answer removeFirst]].
	^answer! !

!WBTranslator methods !   
loadMessage
	"Answer a progress message."

	^'Updating ', self classToTranslate printString, '...'! !

!WBTranslationChooser methods !   
filters
	"Answer the collection of filters."

	^filters ifNil: [filters := OrderedCollection new].! !

!WBEventTranslator class methods !
editEvents
	"Open an editor on the receiver's events."
	"
	WBEventTranslator editEvents.
	"
	
	SubPane supportedEvents isEmpty ifTrue: [
		(MessageBox confirm:
			'Obsoletes not loaded... Continue?'
		) ifFalse: [ ^self ] ].
		
	WBEventTranslationEditor new
		openOn: self
		class: Window.! !

!WBNLSReplacementTranslator methods !
loadMessage
	"Answer a progress message."

	^'Replacing strings in ', self classToTranslate printString, '...'! !

!WBEventTranslationEditor methods !   
noEventString

	^'< None >'! !

!WBEventTranslator methods !  
message: aString pane: aPane
	"Append a message to the user."

	| paneName |
	paneName := aPane paneName ifNil: [ '' ].
	paneName := paneName printString, ' ', aPane realClass printString.
	self message: '    [', paneName, '] ', aString.! !

!WBEventTranslator methods !
windowLabel
	"Answer the label to be used in the chooser window."

	^'OSI Event Translator'! !

!WBEventMap methods !
copy

	| answer |
	answer := self class new.
	self map associationsDo: [ :eachAssoc |
		answer
			mapForClass: eachAssoc key
			putAll: eachAssoc value copy ].
	^answer! !

!WBEventTranslationEditor methods !
selectClass: selectedItem

	"Callback for the #changed: event triggered in the ListBox named 'classListBox'.
	 (Generated by WindowBuilder)"

	selectedClass := Smalltalk at: selectedItem trimBlanks asSymbol.
	self
		updateEventMap;
		updateNewEventList.! !

!WBTranslator methods !   
codeGenerator

	^codeGenerator ifNil: [
		codeGenerator := self defaultCodeGenerator]! !

!WBTranslationChooser class methods !  
isWBInternalClass

	^true! !

!WBNLSExtractionTranslator methods !
translate: anAccessor string: aString in: aPane
	"Extract the specified string."

	aString isString | aString isDoubleByteString ifFalse: [^self].
	(self poolKeyFor: aString) notNil ifTrue: [^self].
	self pool
		at: (self newKey: anAccessor for: aString in: aPane)
		in: self category
		put: aString.! !

!WBTranslationChooser methods !
translate

	"Callback for the #clicked event triggered in the Button named 'translateButton'.
	 (Generated by WindowBuilder)"

	owner startTranslation.
	classNameListBox selectedItems do: [ :each |
		owner translate: (
			Smalltalk at: each key trimBlanks asSymbol)].
	owner endTranslation.
	(self paneNamed: 'keepOpenCheckBox') selection
		ifTrue: [classNameListBox selection: #( )]
		ifFalse: [self close].! !

!WBEventTranslator methods !   
translate
	"Private - Perform the translation."

	self do: [ :each | self translateEventsFor: each ].! !

!WBNLSTranslator methods ! 
startTranslation
	"Translation starts..."

	menuAcceleratorCount := 0.! !

!WBTranslator methods !   
do: aBlock
	"Evaluate aBlock with each of the panes."

	self with: self views do: aBlock.! !

!WBNLSTranslator methods ! 
category

	^category! !

!WBEventMap methods !
mapForClass: aClass

	^self map
		at: (self keyForClass: aClass)
		ifAbsentPut: [ Dictionary new ]! !

!WBEventMap methods !
map

	^map ifNil: [ map := Dictionary new ]! !

!WBTranslationChooser methods !   
addFiltersForClass: aClass
	"Add filters for the specified class."

	| wbBlock wbInternalBlock wbOtherBlock |
	wbBlock := [:eachClass | eachClass wbCreated and: [eachClass isWBInternalClass not]].
	wbInternalBlock := [:eachClass | eachClass wbCreated and: [eachClass isWBInternalClass]].
	wbOtherBlock := [:eachClass | eachClass wbCreated not].
	self
		addHierarchicalFilter: wbBlock named: aClass name withAllSubclassesOf: aClass;
		addFlatFilter: wbBlock named: aClass name, ' (flat)' withAllSubclassesOf: aClass.
	self showInternal ifTrue: [self
		addHierarchicalFilter: wbInternalBlock named: aClass name, ' (internal)' withAllSubclassesOf: aClass;
		addFlatFilter: wbInternalBlock named: aClass name, ' (internal flat)' withAllSubclassesOf: aClass].
	self
		addHierarchicalFilter: wbOtherBlock named: aClass name, ' (non WB)' withAllSubclassesOf: aClass;
		addFlatFilter: wbOtherBlock named: aClass name, ' (non WB flat)' withAllSubclassesOf: aClass.! !

!WBTranslator methods !  
translate: aClass
	"Translate the #createViews method in aClass."

	aClass wbCreated | Notifier isAltKeyDown
		ifTrue: [
			self
				classToTranslate: aClass;
				load;
				translate;
				save].! !

!WBNLSTranslator methods !  
translateStringsIn: aPane menu: aMenu
	"Extract all NLS strings from aPane's menu."

	aMenu isRoot ifFalse: [
		(aMenu title includes: Tab)
			ifTrue: [self menuAcceleratorFound]
			ifFalse: [self translateMenu: aMenu string: aMenu title in: aPane]].
	aMenu children do: [:eachItem |
		eachItem isSeparator ifFalse: [
			self translateStringsIn: aPane menu: eachItem]].! !

!WBEventTranslationEditor methods !  
updateNewEventListSelection
	"Update the new event list."
	
	| newEvent |
	selectedClass isNil | selectedOldEvent isNil ifTrue: [
		^newEventListBox selection: nil ].
	newEvent := eventMap
		map: selectedOldEvent
		forClass: selectedClass.
	newEvent notNil ifTrue: [
		newEvent := newEvent value ].
	newEventListBox selection: (
		newEvent notNil
			ifTrue: [ newEvent ]
			ifFalse: [ self noEventString ] ).! !

!WBEventTranslator methods ! 
newEventFor: anOldEvent class: aClass
	"Answer a new event for the specified class."
	
	| answer |
	answer := self eventMap map: anOldEvent forClass: aClass.
	answer isNil ifTrue: [ ^nil ].
	^answer value! !

!WBTranslator class methods !
translate: aViewManagerSubclass

	| translator |
	translator := self new.
	WBTranslationChooser new
		openOn: aViewManagerSubclass
		owner: translator.
	^translator! !

!WBTranslationChooser methods ! 
selectFilter: selectedItem pane: aPane

	"Callback for the #changed: event in classNameFilter [WBComboBox]
		(Generated by WindowBuilder Pro)"

	classNameListBox contents: selectedItem value.! !

!WBEventMap methods !  
keyForClass: aClassOrSymbol
	"Answer the key into the map."
	
	^aClassOrSymbol isSymbol
		ifTrue: [ aClassOrSymbol ]
		ifFalse: [ aClassOrSymbol symbol ]! !

!WBEventTranslationEditor methods !  
selectNewEvent: selectedItem

	"Callback for the #changed: event triggered in the ListBox named 'newEventListBox'.
	 (Generated by WindowBuilder)"

	| newEvent |
	selectedClass isNil | selectedOldEvent isNil ifTrue: [ ^self ].
	(newEvent := selectedItem) = self noEventString
		ifTrue: [ newEvent := nil ].
	newEvent notNil ifTrue: [
		newEvent last = $: ifTrue: [
			self argumentMissMatchWarning ] ].
	eventMap
		map: selectedOldEvent
		forClass: selectedClass
		put: newEvent.
	self updateEventMapSelection.! !

!WBNLSTranslator methods !   
pools: aCollection

	^pools := aCollection! !

!WBTranslationChooser methods !
addDefaultFilters

	self
		addFiltersForClass: ViewManager;
		addFiltersForClass: ApplicationCoordinator;
		addFiltersForClass: CompositePane.! !

!WBNLSTranslator methods !  
poolKeyFor: aString
	"Scan the pool for a key with a value matching aString."

	| key |
	self pools do: [:each |
		(key := each keyAtValue: aString in: self category)
			notNil ifTrue: [^key]].
	^nil! !

!WBTranslator class methods !
translate

	| translator |
	translator := self new.
	WBTranslationChooser new
		owner: translator;
		open.
	^translator! !

!WBNLSReplacementTranslator methods !
translate: anAccessor string: aString in: aPane
	"Replace the specified string."

	| key value |
	aString isString | aString isDoubleByteString ifFalse: [^self].
	(key := self poolKeyFor: aString) isNil ifTrue: [^self].
	value := self poolValueFor: key.
	anAccessor setValue: value for: aPane.
	aPane wbWrapper notNil ifTrue: [aPane wbWrapper text: value].! !

!WBTranslator methods !
endTranslation
	"Translation ends..."! !

!WBNLSTranslator methods !   
poolManager: aPoolManager

	poolManager := aPoolManager.! !

!WBEventTranslator methods ! 
eventMap
	"Answer the event translation dictionary."

	^eventMap ifNil: [ eventMap := self class defaultEventMap ].! !

!WBNLSExtractionTranslator methods ! 
windowLabel
	"Answer the label to be used in the chooser window."

	^'Extract strings from...'! !

!WBTranslator methods !   
windowLabel
	"Answer the label to be used in the chooser window."

	^self class printString.! !

!WBNLSExtractionTranslator methods !
loadMessage
	"Answer a progress message."

	^'Extracting strings from ', self classToTranslate printString, '...'! !

!WBEventTranslationEditor methods !
save

	"Callback for the #clicked event triggered in the Button named 'okButton'.
	 (Generated by WindowBuilder)"

	owner defaultEventMap: eventMap.
	
	Notifier isShiftKeyDown
	| Notifier isControlKeyDown
	| Notifier isAltKeyDown
		ifTrue: [ owner compileDefaultEventMap ].
	
	self close.! !

!WBTranslator methods !
startTranslation
	"Translation starts..."! !

!WBNLSTranslator class methods ! 
translateFor: aPoolManager pools: aCollectionOfPools category: aCategory

	| translator |
	(translator := self new)
		poolManager: aPoolManager;
		pools: aCollectionOfPools;
		category: aCategory.
	WBTranslationChooser new
		owner: translator;
		open.
	^translator! !

!WBTranslator methods !  
translate
	"Private - Perform the translation."! !

!WBTranslationChooser methods !
selectWithSubclasses: selectedItem pane: aPane
	"Callback for the #doubleClicked: event in classNameListBox [MultipleSelectListBox]
		(Generated by WindowBuilder Pro)"

	| withAllSubclasses newSelection |
	newSelection := aPane selectedItems asSet.
	withAllSubclasses := selectedItem value withAllSubclasses.
	aPane contents do: [:each |
		(withAllSubclasses includes: each value) ifTrue: [
			newSelection add: each]].
	aPane selection: newSelection asArray.! !

!WBEventTranslator class methods !
translate

	| wbFilter translator |
	translator := self new.
	wbFilter := [:eachClass |
		eachClass wbCreated and: [
			eachClass isWBInternalClass not and: [
				eachClass wbVersion < 2.0]]].
	WBTranslationChooser new
		addHierarchicalFilter: wbFilter named: 'Old ViewManagers' withAllSubclassesOf: ViewManager;
		addFlatFilter: wbFilter named: 'Old ViewManagers (flat)' withAllSubclassesOf: ViewManager;
		addDefaultFilters;
		owner: translator;
		open.
	^translator! !

!WBEventTranslator class methods !   
defaultEventMap: anEventMap
	"
	WBEventTranslator defaultEventMap: nil.
	"

	DefaultEventMap := anEventMap.! !

!WBTranslator methods !
codeModules

	^self windowBuilder codeModulesFor: self prototype! !

!WBTranslationChooser methods !  
addHierarchicalFilter: filterBlock named: filterName withAllSubclassesOf: aClass
	"Append a new filter."

	self filters add: filterName => (
		self
			hierarchicalFilter: filterBlock
			indent: 0
			withAllSubclassesOf: aClass).! !

!WBNLSTranslator methods !  
menuAcceleratorFound

	menuAcceleratorCount := menuAcceleratorCount + 1.! !

!WBTranslationChooser methods !  
showInternal: aBoolean

	self propertyAt: #showInternal put: aBoolean = true! !

!WBTranslator methods !  
translateWithSubclasses: aClass
	"Translate the #createViews method in aClass."

	self translate: aClass.
	aClass subclasses do: [ :each |
		self translateWithSubclasses: each ].
	! !

!WBTranslationChooser methods !  
createViews

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."

	| cancelButton classNameFilter doubleClickLabel1 
	keepOpenCheckBox mainView staticText1 translateButton xDU 
	yDU |
	
	#generated.
	xDU := (SysFont width + 1 roundTo: 2) / 4.
	yDU := SysFont height / 8.
	mainView := self topPaneClass new.
	
		"Instance Variables"
	classNameListBox := MultipleSelectListBox new.
	
		"Temporary Variables"
	cancelButton := Button new.
	classNameFilter := WBComboBox new.
	doubleClickLabel1 := StaticText new.
	keepOpenCheckBox := CheckBox new.
	staticText1 := StaticText new.
	translateButton := Button new.
	
	mainView
		owner: self;
		setName: 'mainView';
		labelWithoutPrefix: 'Translator';
		noSmalltalkMenuBar;
		backColor: Color gray;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1/2; leftInset: -100 * xDU;
				topRatio: 1/2; topInset: -179/2 * yDU;
				rightRatio: 1/2; rightInset: -100 * xDU;
				bottomRatio: 1/2; bottomInset: -161/2 * yDU).
	self addView: mainView.
	
	doubleClickLabel1 "StaticText"
		owner: self;
		setName: 'double click label';
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 4 * xDU;
				topRatio: 1; topInset: -33 * yDU;
				rightRatio: 1; rightInset: 4 * xDU;
				bottomRatio: 1; bottomInset: 25 * yDU);
		contents: 'Double click to select all subclasses';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: doubleClickLabel1.
	
	cancelButton "Button"
		owner: self;
		setName: 'cancelButton';
		when: #clicked send: #close to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1; leftInset: -48 * xDU;
				topRatio: 1; topInset: -41/2 * yDU;
				rightRatio: 1; rightInset: 4 * xDU;
				bottomRatio: 1; bottomInset: 9/2 * yDU);
		cancelPushButton;
		contents: 'Cancel';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: cancelButton.
	
	translateButton "Button"
		owner: self;
		setName: 'translateButton';
		when: #clicked send: #translate to: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 1; leftInset: -96 * xDU;
				topRatio: 1; topInset: -41/2 * yDU;
				rightRatio: 1; rightInset: 52 * xDU;
				bottomRatio: 1; bottomInset: 9/2 * yDU);
		contents: 'Translate';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: translateButton.
	
	classNameListBox "MultipleSelectListBox"
		owner: self;
		setName: 'classNameListBox';
		when: #doubleClicked: send: #selectWithSubclasses:pane: to: self withArgument: classNameListBox;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 2 * xDU;
				topRatio: 0; topInset: 16 * yDU;
				rightRatio: 1; rightInset: 2 * xDU;
				bottomRatio: 1; bottomInset: 39 * yDU);
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: classNameListBox.
	
	staticText1
		owner: self;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 4 * xDU;
				topRatio: 0; topInset: 9/2 * yDU;
				rightRatio: 0; rightInset: -26 * xDU;
				bottomRatio: 0; bottomInset: -25/2 * yDU);
		rightJustified;
		contents: 'Filter';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: staticText1.
	
	classNameFilter "WBComboBox"
		owner: self;
		setName: 'classNameFilter';
		addClipsiblingsStyle;
		when: #changed: send: #selectFilter:pane: to: self withArgument: classNameFilter;
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 30 * xDU;
				topRatio: 0; topInset: 5/2 * yDU;
				rightRatio: 1; rightInset: 5/2 * xDU;
				bottomRatio: 0; bottomInset: -125/2 * yDU);
		dropDownList;
		addDynamicListSizeStyle;
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: classNameFilter.
	
	keepOpenCheckBox "CheckBox"
		owner: self;
		setName: 'keepOpenCheckBox';
		framingBlock: 
			(LayoutFrame new
				leftRatio: 0; leftInset: 8 * xDU;
				topRatio: 0; topInset: 140 * yDU;
				rightRatio: 0; rightInset: -52 * xDU;
				bottomRatio: 0; bottomInset: -150 * yDU);
		contents: 'Keep open';
		startGroup;
		noTabStop;
		font: SysFont.
	mainView addSubpane: keepOpenCheckBox! !

!WBNLSReplacementTranslator methods !
translateMenu: aMenu string: aString in: aPane
	"Extract the specified string."

	| key value |
	aString isString | aString isDoubleByteString ifFalse: [^self].
	(key := self poolKeyFor: aString) isNil ifTrue: [^self].
	value := self poolValueFor: key.
	aMenu title: value.! !

!WBNLSTranslator methods ! 
translateStringsIn: aPane
	"Extract all NLS strings from aPane."

	aPane wbPropertyManager wbNLSAccessorsDo: [:each |
		self translate: each string: (each getValueFor: aPane) in: aPane].
	aPane wbWrapper menu notNil ifTrue: [
		self translateStringsIn: aPane menu: aPane wbWrapper menu].! !

!WBEventTranslationEditor methods !   
updateEventMapSelection
	"Update the event map."
	
	self updateEventMap.! !

!WBTranslator methods ! 
translateButtonLabel
	"Answer the label to be used in the translate button."

	^'Translate'! !

!WBTranslator methods !  
defaultCodeGenerator

	^self windowBuilder codeGenerator! !

!WBTranslationChooser class methods !
wbBasicVersion

	"Private - Answer the WindowBuilder Pro version.
		Generated in: Visual Smalltalk Enterprise 3.1.0 Win32"

	^3.1! !

!WBEventTranslator class methods !   
constructDefaultEventMap
    "Construct the default event map. Events defined for a
    particular class are automatically defined for all
    subclasses."

    ^WBEventMap new

        mapForClass: #Container putAll: (
            Dictionary new
                at: #dropRequest put: #dragDropped:;
                yourself);

        mapForClass: #CPHierarchicalListBox putAll: (
            Dictionary new
                at: #commitSelection put: #aboutToChange;
                yourself);

        mapForClass: #CPScrollingPane putAll: (
            Dictionary new
                at: #commitSelection put: #aboutToChange;
                yourself);

        mapForClass: #CPTableEditor putAll: (
            Dictionary new
                at: #textChanged put: #textChanged:cell:;
                yourself);

        mapForClass: #CPValueSet putAll: (
            Dictionary new
                at: #doubleClickSelect put: #doubleClickSelectCell:;
                at: #select put: #selectCell:;
                yourself);

        mapForClass: #DrawnButton putAll: (
            Dictionary new
                at: #highlightItem put: #drawSelection;
                yourself);

        mapForClass: #DropDownList putAll: (
            Dictionary new
                at: #select put: #changed:;
                yourself);

        mapForClass: #EntryFieldGroup putAll: (
            Dictionary new
                at: #textChanged put: #textChanged:pane:;
                yourself);

        mapForClass: #GraphPane putAll: (
            Dictionary new
                at: #button2Up put: #rightClicked;
                at: #button1Up put: #clicked:;
                at: #button1Move put: #button1Moved;
                at: #button1DoubleClick put: #doubleClicked;
                at: #button2DoubleClick put: #button2DoubleClicked;
                at: #button2Move put: #button2Moved;
                yourself);

        mapForClass: #ListBox putAll: (
            Dictionary new
                at: #select put: #clicked:;
                at: #charInput put: #characterTyped:;
                at: #doubleClickSelect put: #doubleClicked:;
                at: #highlightItem put: #drawSelection:;
                yourself);

        mapForClass: #ListPane putAll: (
            Dictionary new
                at: #charInput put: #characterTyped:;
                at: #doubleClickSelect put: #doubleClicked:;
                at: #select put: #clicked:;
                yourself);

        mapForClass: #Notebook putAll: (
            Dictionary new
                at: #select put: #changedPage:;
                yourself);

        mapForClass: #RadioButton putAll: (
            Dictionary new
                at: #clicked put: #turnedOn;
                yourself);

        mapForClass: #RadioButtonGroup putAll: (
            Dictionary new
                at: #select put: #clicked:;
                yourself);

        mapForClass: #ScrollBar putAll: (
            Dictionary new
                at: #sliderPosition put: #changed:;
                at: #sliderTrack put: #changed:;
                at: #prevLine put: #previousLine;
                at: #endScroll put: #changed:;
                at: #pageUp put: #previousPage;
                at: #prevPage put: #previousPage;
                yourself);

        mapForClass: #Slider putAll: (
            Dictionary new
                at: #select put: #changed:;
                yourself);

        mapForClass: #SubPane putAll: (
            Dictionary new
                at: #getMenu put: #needsMenu;
                at: #getContents put: #needsContents;
                at: #getPopupMenu put: #needsPopupMenu;
                at: #resize put: #resized;
                at: #mouseMove put: #mouseMoved:;
                yourself);

        mapForClass: #TextPane putAll: (
            Dictionary new
                at: #save put: #saved;
                yourself);

        mapForClass: #TextPaneControl putAll: (
            Dictionary new
                at: #save put: #saved;
                yourself);

        mapForClass: #TopPane putAll: (
            Dictionary new
                at: #activate put: #activated;
                at: #menuBuilt put: #menuBarBuilt;
                at: #deactivate put: #deactivated;
                at: #close put: #aboutToClose;
                yourself);

        mapForClass: #ValueSet putAll: (
            Dictionary new
                at: #doubleClickSelect put: #doubleClickedCoordinate:;
                at: #select put: #changedCoordinate:;
                yourself);

        mapForClass: #WBToolPalette putAll: (
            Dictionary new
                at: #select put: #clicked:;
                yourself);

        yourself! !

!WBNLSExtractionTranslator methods !
save
	"Private - Ignored because this translator only
		extracts NLS strings."! !

!WBNLSTranslator methods ! 
endTranslation
	"Translation ends..."

	menuAcceleratorCount > 0 ifTrue: [
		MessageBox warning:
			'NLS Translation of menu items with accelerators is not supported.  ',
			menuAcceleratorCount printString, ' menu items were ignored.'].! !

!WBEventMap methods !   
map: anOldEvent forClass: aClass

	| cls answer absent |
	cls := aClass.
	absent := 'absent'.
	[ cls notNil ] whileTrue: [
		(answer := (self
			mapForClass: cls ifAbsent: [ Dictionary new ])
			at: anOldEvent ifAbsent: [ absent ]
		) ~~ absent ifTrue: [
			^Association key: cls value: answer ].
		cls := cls superclass ].
	^self autoMap: anOldEvent forClass: aClass! !

!WBTranslator methods ! 
load
	"Private - Load the #createViews method."

	self message: self loadMessage.
	prototype := nil.
	codeGenerator := nil.! !

!WBTranslationChooser methods !
showInternal

	^(self propertyAt: #showInternal) ifNil: [false]! !

!WBTranslator methods !   
classToTranslate: aClass
	"Set the class to translate."

	classToTranslate := aClass.! !

!WBTranslator methods !
save
	"Private - Recreate the #createViews method."

	self codeGenerator generateCodeUsing: self codeModules.! !

!WBEventTranslator class methods ! 
defaultEventMapComment

	^'Construct the default event map.  Events defined
	for a particular class are automatically defined for
	all subclasses.'! !

!WBNLSTranslator methods !  
pool: aPool

	self pools: (Array with: aPool).! !

!WBNLSTranslator methods ! 
translate: anAccessor string: aString in: aPane
	"Extract the specified string."

	^self implementedBySubclass! !

!WBTranslator methods !   
views
	"Answer the receiver's views."

	^self prototype windows! !

!WBNLSExtractionTranslator methods ! 
translateMenu: aMenu string: aString in: aPane
	"Extract the specified string."

	aString isString | aString isDoubleByteString ifFalse: [^self].
	(self poolKeyFor: aString) notNil ifTrue: [^self].
	self pool
		at: (self newKeyForMenu: aMenu for: aString in: aPane)
		in: self category
		put: aString.! !

!WBTranslationChooser methods !   
preInitWindow

	super preInitWindow.
	Notifier isAltKeyDown ifTrue: [self showInternal: true].
	self filters isEmpty ifTrue: [self addDefaultFilters].
	Smalltalk platformIsWin32 ifTrue: [
		(self paneNamed: 'double click label') leftJustifiedWordWrap].
	self mainView labelWithoutPrefix: owner windowLabel.
	(self paneNamed: 'translateButton') contents: owner translateButtonLabel.
	(self paneNamed: 'classNameFilter')
		printSelector: #key;
		contents: self filters;
		selection: 1.
	classNameListBox
		printSelector: #key;
		contents: self filters first value.! !

!WBEventMap methods ! 
mapForClass: aClass putAll: aDictionary

	| classMap |
	
	(classMap := self map
		at: (self keyForClass: aClass)
		ifAbsentPut: [ aDictionary ]
	) == aDictionary ifFalse: [
		classMap addAll: aDictionary ].
! !

!WBNLSExtractionTranslator methods !   
newKey: anAccessorOrMenu for: aString in: aPane
	"Answer a new key for the specified string."

	| answer index |
	aPane isApplicationWindow ifTrue: [
		aPane owner notNil ifTrue: [
			answer := aPane owner realClass name]].
	answer isNil ifTrue: [
		answer := aPane paneName ifNil: ['']].
	answer isEmpty ifTrue: [
		answer :=
			aString = aPane class name
				ifTrue: [aString]
				ifFalse: [aString, aPane class name]].
	answer := answer, anAccessorOrMenu name.
	answer := self poolManager class validKey: answer.
	(self poolManager at: answer ifAbsent: [nil]) isNil ifTrue: [^answer].
	index := 2.
	[(self poolManager at: answer, index printString ifAbsent: [nil]) isNil]
		whileFalse: [index := index + 1].
	^answer, index printString! !

!WBEventTranslator class methods !   
defaultEventMap

	^DefaultEventMap ifNil: [
		DefaultEventMap := self constructDefaultEventMap ]! !

!WBEventMap methods !   
mapForClass: aClass ifAbsent: aBlock

	^self map
		at: (self keyForClass: aClass)
		ifAbsent: aBlock
! !

!WBNLSTranslator methods !   
poolValueFor: aKey
	"Scan the pool for a value associated with aKey."

	| value |
	self pools do: [:each |
		(value := each at: aKey ifAbsent: [nil])
			notNil ifTrue: [^value]].
	^nil! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!