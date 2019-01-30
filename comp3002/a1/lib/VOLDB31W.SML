3.1.0.106
   
initialize
		" Private - initialize class state. "

	self elementTypeMap isNil
		ifTrue: [ self initializeElementTypeMap ].
	super initialize.
!
constructVTableDescription
		" Private - construct a description of the receiver's VTable.
		Answer an array of entry point descriptions, in VTable order,
		of the receiver's VTable functions. "

	| vtableMethods vtableEntryPoints cm anEntryPointSelector anEntryPoint |
	vtableMethods := self vtableMethods.
	vtableEntryPoints := Array new: vtableMethods size.
	1 to: vtableEntryPoints size do: [ :i |
		cm := vtableMethods at: i.
		anEntryPointSelector := self entryPointSelectorFromPrimitiveSelector: cm selector.
		anEntryPoint := OLEEntryPointDescription
			name: ( self entryPointNameFromSelector: anEntryPointSelector )
			selector: anEntryPointSelector
			vtableIndex: ( cm at: 1 )
			argumentTypes: ( DynamicLinkLibrary argumentTypesOfMethod: cm )
			resultType: ( DynamicLinkLibrary resultTypeOfMethod: cm ).
		vtableEntryPoints at: i put: anEntryPoint ].
	^vtableEntryPoints!   
traceCallin: aBoolean
		" Specify whether interface function invocations from external
		callers are traced when OLE tracing is enabled. "

	TraceCallin := aBoolean.!
initializeTraceLog
        " Private - initialize the trace logging facility to a default state. "

    self
        logToFile: self defaultLogFile;
        disableLogging.!
traceCallin
		" Answer whether interface function invocations from external
		callers are traced when OLE tracing is enabled. "

	^TraceCallin!   
enableLogging
        " Enable trace logging. "

	" OLETraceManager enableLogging "

    self traceEnabled: true.!   
traceLog: aPaneOrFileName
        " Specify the current trace log (a pane or a file name). "

    TraceLog := aPaneOrFileName.!
traceEnabled: aBoolean
        " Specify whether trace logging is enabled. "

    TraceEnabled := aBoolean.!   
initialize
        " Private - initialize class state. "

    self 
		traceCallout: true;
		traceCallin: true;
		initializeTraceLog;
		registerSessionTraceManager.!   
registerSessionTraceManager
		" Private - register the receiver as the OLE session trace manager "

	OLESessionManager traceManager: self.!
createLogWindow
        " Create a window for logging trace reports.  Answer the log pane. "

	" OLETraceManager createLogWindow "

    | logWindow logPane |
    logWindow := TextWindow new
        label: 'Debug Trace Log';
        open;
        yourself.
    logPane := logWindow pane.
    logWindow mainView
        when: #closed
        send: #closeLogWindow: to: self with: logPane.
    ^logPane!
traceLog
        " Answer the current trace log (a pane or a file name). "

    ^TraceLog! 
logToTranscript
        " Enable trace logging to the Transcript. "

	" OLETraceManager logToTranscript "

    self
        traceLog: Transcript;
        enableLogging.!  
reportTRACE: aString
        " Log the trace message <aString> if the trace log is enabled. "

    | aStream |
    self traceEnabled
        ifFalse: [ ^self ].
    self traceLog isString
        ifTrue: [
            aStream := File pathName: self traceLog.
            aStream
                setToEnd;
                nextPutAll: aString; cr.
            aStream close.
            ^self ].
    self traceLog nextPutAll: aString; cr.!   
traceCallout
		" Answer whether interface function invocations through external
		interface pointers are traced when OLE tracing is enabled. "

	^TraceCallout!   
defaultLogFile
        " Answer the name of the default trace log file. "

    ^'trace.log'!   
logToFile
        " Enable trace logging to the default log file. "

	" OLETraceManager logToFile "

    self logToFile: self defaultLogFile.!   
disableLogging
        " Disable trace logging. "

	" OLETraceManager disableLogging "

    self traceEnabled: false.!   
logToWindow
        " Enable trace logging to a log window. "

	" OLETraceManager logToWindow "

    self
        traceLog: self createLogWindow;
        enableLogging.!  
logToFile: aFileName
        " Enable trace logging to the file named <aFileName>. "

	" OLETraceManager logToFile: 'trace.log' "

    self
        traceLog: aFileName;
        enableLogging.!   
logCallStack: nLevels
		" Log <nLevels> of the call stack to the trace log. "

	| callStack walkbackDescription |
    self traceEnabled
        ifFalse: [ ^self ].
	callStack := Process copyStack.
	walkbackDescription := ReadWriteStream on: ( String new: 100 ).
	callStack walkbackOn: walkbackDescription maxLevels: nLevels.
	self oleTRACE: walkbackDescription contents.
!
traceEnabled
        " Answer whether trace logging is enabled. "

    ^TraceEnabled!  
traceCallout: aBoolean
		" Specify whether interface function invocations through external
		interface pointers are traced when OLE tracing is enabled. "

	TraceCallout := aBoolean.!
closeLogWindow: logPane
        " Private - a log window for logging debug trace has been closed. "

    self traceLog == logPane
        ifTrue: [ self initializeTraceLog ].!   
recompilePoolReferences: poolNames
        " Recompile all methods in the system which include any
		of the pools contained in the list of symbols <poolNames>
		in their compilation scope. "

	| scopeIncludesPools |
	Smalltalk rootClasses do: [ :aRootClass |
		aRootClass withAllSubclasses do: [ :aClass |
			scopeIncludesPools := ( aClass sharedPools 
				detect: [ :aPoolName | poolNames includes: aPoolName ]
				ifNone: [ nil ] )
					notNil.
			scopeIncludesPools
				ifTrue: [ self recompileClass: aClass ] ] ].!   
initialize
		" Private - initialize the class. "

	self nullValue: self newNullValue.! 
" OLE COM Development - library removal "

    " remove pool dictionaries as constant pools "
    OLESessionManager removeConstantPoolNames: 
        #( #OLEConstants #OLEStatusCodeConstants ).

    HRESULT statusCodesDictionary: nil.
    OLESessionManager traceManager == OLETraceManager
        ifTrue: [ OLESessionManager traceManager: nil ].
!  
initializeNullValue
		" Private - initialize the null interface pointer. "

	NullInterfacePointer := self newTemporaryInterfacePointer.
! 
removeConstantPoolNames: poolNames
		" Remove the pool dictionaries whose names are contained
		in the list of symbols <poolNames> from the list of constant pools 
		in the Smalltalk development environment. "

	ConstantPoolNames := ConstantPoolNames reject: [ :aPoolName |
		poolNames includes: aPoolName ].!   
validateVTable
		" Verify that a complete and consistent set of VTable dispatch
		methods is defined in the receiver.  Notify the user of any problems. "

    | interfaceClasses localVTables mergedVTable emptySlots
      index firstMethod cm |

    self == OLEInterfacePointer
        ifTrue: [ ^#( ) ].

    interfaceClasses := self withAllSuperclasses reversed.
    interfaceClasses := interfaceClasses
        copyFrom: ( interfaceClasses indexOf: OLEInterfacePointer ) + 1
        to: interfaceClasses size.
    localVTables := interfaceClasses collect: [ :aClass | aClass vtableMethodsLocal ].

    mergedVTable := Array new: ( localVTables
        inject: 0 into: [ :maxSize :aVTable | maxSize max: aVTable size ] ).
    emptySlots := Set new.
    localVTables do: [ :aVTable |
        " verify that interface methods compose a complete block of entries "
        firstMethod := aVTable detect: [ :element | element notNil ] ifNone: [ nil ].
        index := ( firstMethod isNil
            ifTrue: [ aVTable size + 1 ]
            ifFalse: [ aVTable indexOf: firstMethod ] ).
        index to: aVTable size do: [ :i |
            ( aVTable at: i ) isNil
                ifTrue: [
                    MessageBox warning: 
					self name, ' VTable problem: ',
					'no local function definition for slot ', ( i - 1 ) printString.
                    emptySlots add: i - 1 ] ].
        " construct the merged VTable "
        1 to: aVTable size do: [ :i |
            ( cm := aVTable at: i ) notNil
                ifTrue: [ mergedVTable at: i put: cm ] ].
        ].
    " verify that the complete VTable is fully defined "
    1 to: mergedVTable size do: [ :i |
        ( ( mergedVTable at: i ) isNil
        and: [ ( emptySlots includes: i - 1 ) not ] )
                ifTrue: [ 
                    MessageBox warning: 
                        self name, ' VTable problem: ',
                        'no function definition for slot ', ( i - 1 ) printString ] ].
    ^mergedVTable
! 
initialize
		" Private - initialize the class state. "

	self 
		exitIfNotInUse: false;
		resetServerState.! 
initialize
		" Private - initialize the class state. "

	super initialize.
	self initializeTypeNames.!
installConstantPools: poolNames
		" Install the pool dictionaries whose names are contained
		in the list of symbols <poolNames> as constant pools
		in the Smalltalk development environment and recompile
		all classes in the system which reference these pools. "

	self
		registerConstantPoolNames: poolNames;
		recompilePoolReferences: poolNames.!  
constructCallbackSelectorsFor: vtableDescription
		" Private - construct the list of callback selectors to 
		send to instances of the receiver when the corresponding
		entry point in the <vtableDescription> is invoked
		by callin from an external client. "

	^vtableDescription collect: [ :eptDescription |
		self callbackSelectorFor: eptDescription ].! 
inspectorFields
        "Private - answer the names of the fields contained in the receiver."

	^self class inspectorFields!   
validateVTable
		" Verify that a complete and consistent set of VTable invocation
		methods is defined in the receiver.  Notify the user of any problems. "

	| eptDescriptions callbackSelectors dummyGuy ept selector |
	eptDescriptions := vtable vtableDescription.
	callbackSelectors := vtable callbackSelectors.
	dummyGuy := self basicNew.
	1 to: vtable size do: [ :i |
		ept := eptDescriptions at: i.
		selector := callbackSelectors at: i.
		ept vtableIndex = ( i - 1 )
			ifFalse: [ 
				MessageBox warning: 
					self name, ' VTable problem: ',
					'slot index problem in ', ept name ].
		ept argumentTypes size = ( selector occurrencesOf: $: )
			ifFalse: [ 
				MessageBox warning: 
					self name, ' VTable problem: ',
					'argument count mismatch in ', ept name ].
		( dummyGuy respondsTo: selector )
			ifFalse: [ 
				MessageBox warning: 
					self name, ' VTable problem: ',
					'unimplemented selector #', selector, ' for ', ept name ].
		].
	^eptDescriptions! 
initialize
		" Private - initialize the class state. "

	self supportAllOLE: true.!
constructVTableDescription
		" Private - construct a description of the receiver's VTable.
		Answer an array of entry point descriptions, in VTable order,
		of the receiver's VTable functions.  The argument types describe
		the value to be constructed by the virtual machine when a
		callback to the entry point is invoked by an external caller. "

	| vtableDescription eptDescription |

	vtableDescription := super constructVTableDescription.

	" install special callback argument handling for POINTL #structValue values "

	eptDescription := vtableDescription detect: [ :ept | ept name = 'DragEnter' ].
	self ASSERT: eptDescription argumentTypes = #( #handle #ulong #structValue #struct ).
	eptDescription argumentTypes: #( #handle #ulong #ulong #ulong #struct ).

	eptDescription := vtableDescription detect: [ :ept | ept name = 'DragOver' ].
	self ASSERT: eptDescription argumentTypes = #( #ulong #structValue #struct ).
	eptDescription argumentTypes: #( #ulong #ulong #ulong #struct ).

	eptDescription := vtableDescription detect: [ :ept | ept name = 'Drop' ].
	self ASSERT: eptDescription argumentTypes = #( #handle #ulong #structValue #struct ).
	eptDescription argumentTypes: #( #handle #ulong #ulong #ulong #struct ).

	^vtableDescription!
initialize
		" Private - initialize the class state.
		NOTE: The IID must be initialized separately before evaluating this initialization. "

    self == OLEInterfacePointer
		ifTrue: [ self initializeNullValue ].
	self registerIID.
! 
registerConstantPoolNames: poolNames
		" Add the pool dictionaries whose names are contained
		in the list of symbols <poolNames> to the list of constant pools 
		in the Smalltalk development environment. "

	| namesToAdd duplicates |
	namesToAdd := poolNames select: [ :aPoolName |
		( ConstantPoolNames includes: aPoolName ) not ].
	namesToAdd size < poolNames size
		ifTrue: [
			duplicates := ( poolNames select: [ :aPoolName |
				( namesToAdd includes: aPoolName ) not ] )
					asSortedCollection asArray.
			MessageBox
				notify: 'Duplicate Constant Pool Registration'
				withText: 'Duplicate constant pool registration ', duplicates printString, '.'.
			].
	ConstantPoolNames := ConstantPoolNames, namesToAdd asArray.! 
validateVTableDescription
		" Private - verify that entry point selectors in the VTable description
		 are consistent with the interface binding provided by the receiver. "

	| dummyInstance |
	dummyInstance := self basicNew.
	self vtableDescription do: [ :eptDescription |
		( dummyInstance respondsTo: eptDescription selector )
			ifFalse: [
				MessageBox
					notify: 'Interface Pointer Entry Point Problem'
					withText: 'The entry point specification for ',  eptDescription name, 
						' in ', self name,
						' specifies undefined selector #', eptDescription selector, '.' ].
		].! 
constructVTableDescription
		" Private - construct a description of the receiver's VTable.
		Answer an array of entry point descriptions, in VTable order,
		of the receiver's VTable functions.  The argument types describe
		the value to be constructed by the virtual machine when a
		callback to the entry point is invoked by an external caller. "

	| anInterfacePointerClass |
	( anInterfacePointerClass := self interfacePointerClass ) isNil
		ifTrue: [ ^nil ].
	^anInterfacePointerClass vtableDescription! 
initialize
		" Private - initialize class state. "

	self structureNameMap isNil
		ifTrue: [ self initializeStructureNameMap ].
!
inspectorFields
        " Private - answer the names of the fields contained in this kind of definition. "

    ^ExternalBuffer inspectorClass 
		fields: #( #vtableAddress #callinInterfaceIndex #callinDescriptorIndex )!   
buildView: aView forModel: aCoordinator
    "Create the structure of the window <aView> for the application <aCoordinator>."

	| aFont topSectionHeight aPanel |

	aView
		label: 'OLE Exported Objects Browser';
		"??owner: aCoordinator; ??"
		when: #opened
			send: #updateResourceLists to: aCoordinator;
		yourself.

	aFont := aView font.
	topSectionHeight := aFont lineSpacing * 3.

	aView addSubpane: ( ( aPanel := GroupPane new )
		removeBorderStyle;
		framingBlock: [ :box |
			( box leftTop
			extentFromLeftTop: ( box width @ topSectionHeight ) )
				insetBy: self borderInset ];
		yourself ).
	self addSpecialItemsTo: aPanel
		for: aCoordinator
		font: aFont.

	aView addSubpane: ( ( aPanel := GroupPane new )
		removeBorderStyle;
		framingBlock: [ :box | ( Rectangle
			leftTop: ( box leftTop down: topSectionHeight )
			rightBottom: box rightBottom )
					insetBy: self borderInset ];
		yourself ).
	self addExportedItemsTo: aPanel
		for: aCoordinator
		font: aFont.!   
addSpecialItemsTo: aPanel for: aCoordinator font: font
		" Private "

	| updateButtonLabel cleanUpListsButtonLabel |

	updateButtonLabel := 'Update lists'.
	aPanel addSubpane: ( Button new
		label: updateButtonLabel;
		when: #clicked
			send: #updateResourceLists to: aCoordinator;
		framingBlock: [ :box | Rectangle
			leftBottom: ( box rightTop
				leftAndDown: ( self extentForButton: updateButtonLabel font: font ) )
			rightTop: box rightTop ];
		yourself ).

	cleanUpListsButtonLabel := 'Clean up lists'.
	aPanel addSubpane: ( Button new
		label: cleanUpListsButtonLabel;
		when: #clicked
			send: #cleanUpResourceLists to: aCoordinator;
		framingBlock: [ :box |
			( box center x @ box top )
			extentFromLeftTop:
				( self extentForButton: cleanUpListsButtonLabel font: font ) ];
		yourself ).!  
heightForButton: font
        " Private - answer the height to use for a button "

	^font lineSpacing * 2! 
addList: aListPane
	to: aPanel 
	for: aCoordinator
	label: aString
	font: font
	section: section
		" Private - add <aListPane> to <aPanel>. "

	aPanel addSubpane: ( StaticText new
		removeBorderStyle;
		value: aString;
		framingBlock: [ :box | 
			self frameRectangleForLabelIn: box section: section font: font ];
		yourself ).
	aPanel addSubpane: ( aListPane
		framingBlock: [ :box | 
			self frameRectangleForListIn: box section: section font: font ];
		yourself ).
	^aListPane!
addMultipleChoiceListTo: aPanel 
	for: aCoordinator
	label: aString
	font: font
	section: section
		" Private - add a multiple-choice list element to <aPanel>. "

	^self addList: MultipleSelectListBox new
		to: aPanel 
		for: aCoordinator
		label: aString
		font: font
		section: section.! 
frameRectangleForListIn: box section: section font: font
		" Private "

	section = #left
		ifTrue: [ ^Rectangle
			leftTop: ( box leftTop down: font lineSpacing )
			rightBottom: ( box center x left: self borderInset )
				@ box bottom ].
	section = #right
		ifTrue: [ ^Rectangle
			leftTop: ( ( box center x @ box top ) down: font lineSpacing )
			rightBottom: box rightBottom ].
	self error: 'unknown section'!  
borderInset
		" Private - answer the border margin inset "

	^4!   
addListTo: aPanel 
	for: aCoordinator
	label: aString
	font: font
	section: section
		" Private - add a list element to <aPanel>. "

	^self addList: ListBox new
		to: aPanel 
		for: aCoordinator
		label: aString
		font: font
		section: section.! 
frameRectangleForLabelIn: box section: section font: font
		" Private "

	section = #left
		ifTrue: [ ^Rectangle
			leftTop: box leftTop
			rightBottom: box center x @ ( box top down: font lineSpacing ) ].
	section = #right
		ifTrue: [ ^Rectangle
			leftTop: box center x @ box top
			rightBottom: box right @ ( box top down: font lineSpacing ) ].
	self error: 'unknown section'!
addExportedItemsTo: aPanel for: aCoordinator font: font
		" Private "

	| aListPane exportedInterfacesList exportedObjectsList |

	aListPane := self addSeparatedListTo: aPanel 
		for: aCoordinator
		label: 'Exported interfaces:'
		font: font
		section: #left.
	aListPane
		when: #doubleClicked:
		send: #inspectValue: to: aCoordinator.
	aCoordinator exportedInterfaces
		when: #changed:
			send: #updateExportedInterfacesView: to: aCoordinator with: aListPane;
		when: #changed:
			send: #clearSelection to: aListPane.
	exportedInterfacesList := aListPane.
	exportedInterfacesList addHorizontalScrollbarStyle.

	aListPane := self addListTo: aPanel 
		for: aCoordinator
		label: 'Exported objects:'
		font: font
		section: #right.
	aListPane
		when: #doubleClicked:
		send: #inspectValue: to: aCoordinator.
	aCoordinator exportedObjects
		when: #changed:
			send: #setList: to: aListPane;
		when: #changed:
			send: #clearSelection to: aListPane.
	exportedObjectsList := aListPane.

	exportedObjectsList
		when: #changed:
		send: #setSelectedObject: to: aCoordinator.
	exportedObjectsList
		when: #changed:
		evaluate: ( Message
			receiver: aCoordinator
			selector: #selectInterfacesOf:in: 
			arguments: ( Array with: nil "selectedItem" with: exportedInterfacesList ) ).
	exportedInterfacesList
		when: #changed:
		evaluate: ( Message
			receiver: aCoordinator
			selector: #selectObjectOf:in: 
			arguments: ( Array with: nil "selectedItem" with: exportedObjectsList ) ).! 
windowPolicyClass
    "Answer the class of window policy for the receiver."

    ^SmalltalkToolInterface current windowPolicyClass!
extentForButton: aButtonLabel font: font
        " Private - measure button and add white space around label "

	^( ( font stringWidth: aButtonLabel ) + font charSize x )
		@ ( self heightForButton: font )!
createViewFor: aCoordinator
        "Create and configure a window for <aCoordinator>. "

    | aWindow |
    aWindow := super createViewFor: aCoordinator.
	aWindow
		when: #menuBarBuilt
		send: #cleanupMenuCreate: to: aCoordinator with: aWindow.
    ^aWindow!  
addSeparatedListTo: aPanel 
	for: aCoordinator
	label: aString
	font: font
	section: section
		" Private - add a list element with section separators to <aPanel>. "

	^self addList: ExtendedListBox new
		to: aPanel 
		for: aCoordinator
		label: aString
		font: font
		section: section.!
buildView: aView forModel: aCoordinator
    "Create the structure of the window <aView> for the application <aCoordinator>."

	| aFont topSectionHeight aPanel |

	aView
		label: 'OLE Resource Browser';
		"??owner: aCoordinator; ??"
		when: #opened
			send: #updateResourceLists to: aCoordinator;
		yourself.

	aFont := aView font.
	topSectionHeight := aFont lineSpacing * 5.

	aView addSubpane: ( ( aPanel := GroupPane new )
		removeBorderStyle;
		framingBlock: [ :box |
			( box leftTop
			extentFromLeftTop: ( box width @ topSectionHeight ) )
				insetBy: self borderInset ];
		yourself ).
	self addSpecialItemsTo: aPanel
		for: aCoordinator
		font: aFont.

	aView addSubpane: ( ( aPanel := GroupPane new )
		removeBorderStyle;
		framingBlock: [ :box |
			( ( box leftTop down: topSectionHeight )
			extentFromLeftTop: ( box width @ ( ( box height - topSectionHeight ) // 2 )) )
				insetBy: self borderInset ];
		yourself ).
	self addOwnedItemsTo: aPanel
		for: aCoordinator
		font: aFont.

	aView addSubpane: ( ( aPanel := GroupPane new )
		removeBorderStyle;
		framingBlock: [ :box | ( Rectangle
			leftTop: ( box leftTop 
				down: ( topSectionHeight + ( ( box height - topSectionHeight ) // 2 ) ) )
			rightBottom: box rightBottom )
				insetBy: self borderInset ];
		yourself ).
	self addExportedItemsTo: aPanel
		for: aCoordinator
		font: aFont.!
createViewFor: aCoordinator
        "Create and configure a window for <aCoordinator>. "

    | aWindow |
    aWindow := super createViewFor: aCoordinator.
	aWindow
		when: #menuBarBuilt
		send: #registryMenuCreate: to: aCoordinator with: aWindow.
    ^aWindow! 
open: aCoordinator
    "Build and open a window for <aCoordinator>."

	OLESessionManager trackResources
		ifFalse: [  " ain't much to look at in this case "
			( MessageBox confirm: 'OLE resources are not being tracked, so there isn''t anything useful to see in the OLE resource browser.  Open it anyway?' )
				ifFalse: [ ^nil ].
			].
	^super open: aCoordinator!  
addSpecialItemsTo: aPanel for: aCoordinator font: font
		" Private "

	| updateButtonLabel cleanUpListsButtonLabel aListPane aStaticText |

	aListPane := self addListTo: aPanel 
		for: aCoordinator
		label: 'Special resources:'
		font: font
		section: #left.
	aListPane
		when: #doubleClicked:
		send: #inspectValue: to: aCoordinator.
	aCoordinator specialResources
		when: #changed:
		send: #setList: to: aListPane.

	aPanel addSubpane: ( ( aStaticText := StaticText new )
		removeBorderStyle;
		value: 'Special resource description:';
		framingBlock: [ :box | 
			( ( box center x @ box bottom ) up: ( font lineSpacing * 2 ) )
			extentFromLeftTop: ( ( box width // 2 ) @ font lineSpacing ) ];
		yourself ).
	aPanel addSubpane: ( ( aStaticText := StaticText new )
		removeBorderStyle;
		framingBlock: [ :box |
			( ( box center x @ box bottom ) up: font lineSpacing )
			extentFromLeftTop: ( ( box width // 2 ) @ font lineSpacing ) ];
		yourself ).
	aListPane
		when: #changed:
		evaluate: ( Message
			receiver: aCoordinator
			selector: #updateSpecialResourceDescriptionOf:in:
			arguments: ( Array with: nil "selectedResource" with: aStaticText ) ).
	aCoordinator specialResources
		when: #changed:
		send: #updateSpecialResourceDescriptionOf:in: 
		to: aCoordinator with: nil with: aStaticText.

	updateButtonLabel := 'Update lists'.
	aPanel addSubpane: ( Button new
		label: updateButtonLabel;
		when: #clicked
			send: #updateResourceLists to: aCoordinator;
		framingBlock: [ :box | Rectangle
			leftBottom: ( box rightTop
				leftAndDown: ( self extentForButton: updateButtonLabel font: font ) )
			rightTop: box rightTop ];
		yourself ).

	cleanUpListsButtonLabel := 'Clean up lists'.
	aPanel addSubpane: ( Button new
		label: cleanUpListsButtonLabel;
		when: #clicked
			send: #cleanUpResourceLists to: aCoordinator;
		framingBlock: [ :box |
			( box center x @ box top )
			extentFromLeftTop:
				( self extentForButton: cleanUpListsButtonLabel font: font ) ];
		yourself ).!  
addOwnedItemsTo: aPanel for: aCoordinator font: font
		" Private "

	| aListPane |

	aListPane := self addListTo: aPanel 
		for: aCoordinator
		label: 'Owned interfaces:'
		font: font
		section: #left.
	aListPane
		when: #doubleClicked:
		send: #inspectValue: to: aCoordinator.
	aCoordinator ownedInterfaces
		when: #changed:
		send: #setList: to: aListPane.

	aListPane := self addListTo: aPanel 
		for: aCoordinator
		label: 'Owned memory:'
		font: font
		section: #right.
	aListPane
		when: #doubleClicked:
		send: #inspectValue: to: aCoordinator.
	aCoordinator ownedMemory
		when: #changed:
		send: #setList: to: aListPane.!   
setOwnedInterfaces: aList
		" Private - set the list of owned interfaces. "

	ownedInterfaces setValue: aList.!
specialResources
		" Private - answer the holder of the list of special resources. "

	^specialResources!  
clearOwnedLists
		" Private - clear the lists of owned resources "

	self 
		setOwnedInterfaces: #();
		setOwnedMemory: #( ).
! 
registryInspectHostResources
		" Private - inspect registry "

	SystemWeakRegistries externalResources inspect.!   
registryInspectOwnedInterfaces
		" Private - inspect registry "

	OLESessionManager ownedInterfacesRegistry inspect.!  
setSpecialResources: aList
		" Private - set the list of special resources. "

	specialResources setValue: aList.! 
updateSpecialResourceDescriptionOf: selectedSpecialResource in: aStaticText
		" Private - display a description of the selected special resource "

	| specialResourcesMap description resourceWrapper |

	selectedSpecialResource isNil
		ifTrue: [ ^aStaticText value: '' ].
	specialResourcesMap := OLESessionManager specialSessionResources.
	description := specialResourcesMap at: selectedSpecialResource
		ifAbsent: [
			resourceWrapper := specialResourcesMap keys
				detect: [ :aResource |
					aResource isOLEInterface 
					and: [ aResource asInterfacePointer = selectedSpecialResource ] ]
				ifNone: [ nil ].
			resourceWrapper isNil
				ifTrue: [ '(description not found)' ] 
				ifFalse: [ specialResourcesMap at: resourceWrapper ] ].
	aStaticText value: '  ', description.!
updateResourceLists
		" Private - update the lists of resources "

	self
		updateOwnedResourceLists;
		updateExportedResourceLists.
	self validateAllocatedInterfaces.! 
setOwnedMemory: aList
		" Private - setf the list of owned memory. "

	ownedMemory setValue: aList.!   
registryInspectOwnedMemory
		" Private - inspect registry "

	OLESessionManager ownedMemoryRegistry inspect.!  
registryMenuCreate
		" Private - create a Registries menu for the receiver. "

	^( ( Menu
        labels: 'Owned interfaces\nOwned memory\nAllocated interfaces\nHost resources' replaceEscapeCharacters
        lines: #( 2 3 )
        selectors: #( #registryInspectOwnedInterfaces #registryInspectOwnedMemory
			#registryInspectAllocatedInterfaces #registryInspectHostResources ) )
            title: '\uRegistries' replaceEscapeCharacters;
            owner: self;
            yourself ).!
registryMenuCreate: aWindow
		" Private - create the Registries menu. "

	aWindow menuWindow addMenu: self registryMenuCreate.!
validateAllocatedInterfaces
		" Private - verify that the allocated and exported interfaces lists
		are consistent.  We display the exported list, so if they are not
		the same then display the allocated list. "

	| exportsList allocatedList problemsFound |

	exportsList := OLESessionManager allExportedInterfaces.
	allocatedList := OLESessionManager allAllocatedInterfaces.
	problemsFound := false.
	( exportsList elementsEqual: allocatedList )
		ifFalse: [
			problemsFound := true.
			OLEExportedObjectsBrowser open.
			MessageBox
				notify: 'OLE Resource Tracking Problem'
				withText: 'The allocated interfaces registry is different than the exported interfaces list obtained from the ExternalObjectTable and displayed in this browser.  This is unexpected and should be reported to the OLE developers.'.
			].

	exportsList := ( exportsList collect: [ :anInterface | anInterface implementor ] )
		asSet.
	allocatedList := ( allocatedList collect: [ :anInterface | anInterface implementor ] )
		asSet.
	( exportsList elementsEqual: allocatedList )
		ifFalse: [
			problemsFound
				ifFalse: [
					OLEExportedObjectsBrowser open.
					problemsFound := true ].
			MessageBox
				notify: 'OLE Resource Tracking Problem'
				withText: 'The allocated interfaces registry has a different list of implementing objects than the exported objects list obtained from the ExternalObjectTable and displayed in this browser.  This is unexpected and should be reported to the OLE developers.'.
			].
	^problemsFound!
clearLists
		" Private - clear the lists of resources "

	self 
		clearOwnedLists;
		clearExportedLists.
!  
initialize
		" Private - initialize a newly created instance. "

	super initialize.
	specialResources := SharedValue new.
	ownedInterfaces := SharedValue new.
	ownedMemory := SharedValue new.!
ownedInterfaces
		" Private - answer the holder of the list of owned interfaces. "

	^ownedInterfaces! 
cleanUpResourceLists
		" Private - clear the system and recompute the resource lists. "

	self clearLists.
	Smalltalk unusedMemory.  " force garbage collect to clean up finalization registries "
	self updateResourceLists.!   
registryInspectAllocatedInterfaces
		" Private - inspect registry "

	OLESessionManager allocatedInterfacesRegistry inspect.!  
ownedMemory
		" Private - answer the holder of the list of owned memory. "

	^ownedMemory! 
getExportedInterfaceList
		" Private - answer the unsorted list of interface implementations
		to display in the exported interfaces list. "

	^OLESessionManager allAllocatedInterfaces! 
updateOwnedResourceLists
		" Private - update the lists of owned resources "

	| specialResourceList |

	specialResourceList := OLESessionManager specialSessionResources keys asArray
		collect: [ :aResource |
			aResource isOLEInterfacePointer 
				ifTrue: [ aResource asInterfacePointer ]
				ifFalse: [ aResource ] ].
	self setSpecialResources: ( self sortObjects: specialResourceList ).

	self setOwnedInterfaces: ( self sortInterfaces: 
		( OLESessionManager allOwnedInterfaces
			"reject: [ :anInterface | specialResourceList includes: anInterface ]" ) ).
	self setOwnedMemory: ( self sortObjects:
		( OLESessionManager allOwnedMemoryAddresses
			"reject: [ :anInterface | specialResourceList includes: anInterface ]" ) ).! 
cleanupReleaseObject
		" Private - release the selected object "

	self 
		releaseObject: self selectedObject value;
		updateResourceLists.! 
setSelectedObject: anExportedObject
		" Private - record the selected object. "

	selectedObject setValue: anExportedObject.!  
releaseObject: anOleObject
		" Private - release the exported object <anOleObject>. "

	anOleObject referenceCount timesRepeat: [ anOleObject release ].!  
cleanupMenuCreate: aWindow
		" Private - create the Cleanup menu. "

	| aMenu |
	aMenu := self cleanupMenuCreate.
	aWindow menuWindow addMenu: aMenu.
	self enableDisableCleanupMenu: aMenu.
	self selectedObject
		when: #changed:
		send: #enableDisableCleanupMenu: to: self with: aMenu.
	self exportedObjects
		when: #changed:
		send: #enableDisableCleanupMenu: to: self with: aMenu.!
cleanupMenuCreate
		" Private - create a Cleanup menu for the receiver. "

	^( ( Menu
        labels: 'Copy to clipboard\nRemove from clipboard\nFlush clipboard\nRelease selected object\nRelease all objects\nRelease all resources' replaceEscapeCharacters
        lines: #( 3 4 )
        selectors: #( 
				#cleanupCopyToClipboard #cleanupRemoveFromClipboard #cleanupFlushClipboard
				#cleanupReleaseObject 
				#cleanupReleaseAllObjects #cleanupReleaseAllResources ) )
            title: '\uCleanup' replaceEscapeCharacters;
            owner: self;
            yourself ).!   
constructInterfaceImplList: unsortedInterfaceImpls
		" Private - answer a list of lists which organizes
		the collection of interfaces into sublists associated
		with an implementing object. "

	| interfacesDict interfacesList |
	interfacesDict := self organizeInterfaceImplementations: unsortedInterfaceImpls.
	interfacesList := OrderedCollection new.
	( self sortObjects: interfacesDict keys ) do: [ :anObject |
		interfacesList add: ( interfacesDict at: anObject ) ].
	^interfacesList asArray!
enableItems: itemList in: aMenu
		" Private - enable the menu items in <itemList> in <aMenu>. "

	itemList do: [ :aMenuItem | aMenu enableItem: aMenuItem ].!  
cleanupRemoveFromClipboard
		" Private - remove the selected data object the clipboard "

	IDataObject flushClipboard.
	self updateResourceLists.!
enableDisableCleanupMenu: aMenu
		" Private - enable/disable items in the cleanup menu. "

	| anOleObject anIDataObject selectedClipboardObject |

	anOleObject := self selectedObject value.
	self enableDisableItems: #( #cleanupReleaseObject ) 
		in: aMenu 
		enableFlag: anOleObject notNil.

	anOleObject notNil
		ifTrue: [ anIDataObject := anOleObject queryInterface: IID_IDataObject ].
	selectedClipboardObject := 
		( anIDataObject notNil 
		and: [ anIDataObject isClipboardObject ] ).
	self enableDisableItems: #( #cleanupRemoveFromClipboard ) 
		in: aMenu 
		enableFlag: ( anIDataObject notNil and: [ selectedClipboardObject ] ).
	self enableDisableItems: #( #cleanupCopyToClipboard ) 
		in: aMenu 
		enableFlag: ( anIDataObject notNil and: [ selectedClipboardObject not ] ).
	anIDataObject notNil
		ifTrue: [ anIDataObject release ].

	self enableDisableItems: #( #cleanupReleaseAllObjects ) 
		in: aMenu 
		enableFlag: self exportedObjects value size > 0.
	self enableDisableItems: #( #cleanupReleaseAllResources ) 
		in: aMenu 
		enableFlag: OLESessionManager sessionHasResources.!
exportedInterfaces
		" Private - answer the holder of the list of exported interfaces. "

	^exportedInterfaces!
selectInterfacesOf: anExportedObject in: exportedInterfacesList
		" Private - an exported object has been selected. "

	| selectedInterface |
	anExportedObject isNil
		ifTrue: [ ^self ].  " selection cleared "
	selectedInterface := exportedInterfacesList value.
	( selectedInterface isNil
	or: [ selectedInterface implementor ~~ anExportedObject ] )
		ifTrue: [ 
			selectedInterface := ( self exportedInterfaces value at: 1 )
				detect: [ :anInterface | anInterface implementor == anExportedObject ].
			exportedInterfacesList selectItem: selectedInterface ].!
inspectValue: anObject
		" Private - open an inspector on <anObject>. "

	anObject inspect.!   
clearExportedLists
		" Private - clear the lists of exported resources "

	self 
		setExportedInterfaces: ( Array with: #( ) with: #( ) );
		setExportedObjects: #( ).
!
updateResourceLists
		" Private - update the lists of resources "

	self implementedBySubclass.!   
organizeInterfaceImplementations: unsortedInterfaceImpls
		" Private - answer a dictionary which organizes the collection
		of interfaces into sublists accessed by the implementing object. "

	| interfacesDict |
	interfacesDict := IdentityDictionary new.
	unsortedInterfaceImpls do: [ :anInterface |
		( interfacesDict at: anInterface implementor 
				ifAbsentPut: [ OrderedCollection new ] )
			add: anInterface ].
	interfacesDict keys do: [ :anObject |
		interfacesDict at: anObject
			put: ( self sortInterfaces: ( interfacesDict at: anObject ) ).
		].
	^interfacesDict!   
exportedObjects
		" Private - answer the holder of the list of exported objects. "

	^exportedObjects! 
setExportedObjects: aList
		" Private - set the list of exported objects. "

	self setSelectedObject: nil.  " clear the selection "
	exportedObjects setValue: aList.!
disableItems: itemList in: aMenu
		" Private - disable the menu items in <itemList> in <aMenu>. "

	itemList do: [ :aMenuItem | aMenu disableItem: aMenuItem ].!   
cleanupReleaseAllObjects
		" Private - release all exported objects "

	self exportedObjects value do: [ :anOleObject |
		self releaseObject: anOleObject ].
	self updateResourceLists.! 
cleanupCopyToClipboard
		" Private - remove the selected data object the clipboard "

	| anIDataObject |
	anIDataObject := self selectedObject value queryInterface: IID_IDataObject.
	anIDataObject copyToClipboard.
	anIDataObject release.
	self setSelectedObject: self selectedObject value.  " kludge to force menu update "!
sortObjects: unsortedObjects
		" Private - answer a sorted list containing the elements of <unsortedObjects>. "

	| sortedCollection |
	sortedCollection := SortedCollection sortBlock: [ :if1 :if2 |
		if1 class name <= if2 class name ].
	sortedCollection addAll: unsortedObjects.
	^sortedCollection asArray! 
sortInterfaces: unsortedInterfaces
		" Private - answer a sorted list containing the elements of <unsortedInterfaces>. "

	| sortedCollection |
	sortedCollection := SortedCollection sortBlock: [ :if1 :if2 |
		if1 printString <= if2 printString ].
	sortedCollection addAll: unsortedInterfaces.
	^sortedCollection asArray!   
initialize
		" Private - initialize a newly created instance. "

	exportedInterfaces := SharedValue new.
	exportedObjects := SharedValue new.
	selectedObject := SharedValue new.!   
cleanupFlushClipboard
		" Private - flush the clipboard "

	IDataObject flushClipboard.
	self updateResourceLists.!   
setExportedInterfaces: aList
		" Private - set the list of exported interfaces. "

	exportedInterfaces setValue: aList.!   
updateExportedResourceLists
		" Private - update the lists of exported resources "

	| exportedObjectsList exportedInterfacesDict exportedInterfacesList 
	  separatorsList nInterfaces anInterfaceList |

	exportedInterfacesDict := self organizeInterfaceImplementations:
		self getExportedInterfaceList.
	exportedObjectsList := self sortObjects:
		exportedInterfacesDict keys.

	exportedInterfacesList := OrderedCollection new.
	separatorsList := OrderedCollection new.
	nInterfaces := 0.
	exportedObjectsList do: [ :anOLEObject |
		anInterfaceList := exportedInterfacesDict at: anOLEObject.
		exportedInterfacesList addAll: anInterfaceList.
		nInterfaces := nInterfaces + anInterfaceList size.
		anOLEObject == exportedObjectsList last
			ifFalse: [ separatorsList add: nInterfaces ].
		].

	self setExportedInterfaces: ( Array
		with: exportedInterfacesList asArray
		with: separatorsList asArray ).
	self setExportedObjects: exportedObjectsList.!  
selectedObject
		" Private - answer the selected object. "

	^selectedObject!  
enableDisableItems: itemList in: aMenu enableFlag: enableFlag
		" Private - enable or disable the menu items in <itemList> in <aMenu>
		based on whether enableFlag is true or false. "

	enableFlag 
		ifTrue: [ self enableItems: itemList in: aMenu ]
		ifFalse: [ self disableItems: itemList in: aMenu ].! 
updateExportedInterfacesView: aListBox
		" Private - update the list of exported interfaces "

	| viewInfo |
	viewInfo := self exportedInterfaces value.
	aListBox contents: ( viewInfo at: 1 ) separators: ( viewInfo at: 2 ).! 
getExportedInterfaceList
		" Private - answer the unsorted list of interface implementations
		to display in the exported interfaces list. "

	^self implementedBySubclass!   
selectObjectOf: anExportedInterface in: exportedObjectsList
		" Private - an exported interface has been selected. "

	| anOleObject |
	anOleObject := anExportedInterface implementor.
	exportedObjectsList selectItem: anOleObject.
	self setSelectedObject: anOleObject.!
cleanupReleaseAllResources
		" Private - release all exported objects "

	OLESessionManager releaseResources.
	self updateResourceLists.! 
" OLE COM Development - library installation "

    " install pool dictionaries as constant pools "
    OLESessionManager registerConstantPoolNames: 
        #( #OLEConstants #OLEStatusCodeConstants ).

    HRESULT statusCodesDictionary: OLEStatusCodeConstants.
    OLESessionManager traceManager: OLETraceManager.
!  
entryPointNameFromSelector: entryPointSelector
        " Private - answer the entry point name corresponding to the 
		interface function method selector <entryPointSelector>. "

	^entryPointSelector upTo: $:! 
setCompilationOptions: aCompilerInterface
	"Private - The message is sent when a compiler interface object is being created
	that will process method definitions within the receiver.  The receiver may
	add or modify any compilation options by sending appropriate message to 
	the argument"

	aCompilerInterface addOption: #ApiFormat with: 'OLE'.!  
constructTypeNames
		" Private - answer a mapping from system moniker types to descriptive names. "

	^Dictionary new
		at: MKSYS_ANTIMONIKER put: 'anti-moniker';
		at: MKSYS_FILEMONIKER put: 'file moniker';
		at: MKSYS_GENERICCOMPOSITE put: 'composite moniker';
		at: MKSYS_ITEMMONIKER put: 'item moniker';
		at: MKSYS_POINTERMONIKER put: 'pointer moniker';
		yourself!   
initialize
		" Private - initialize the class. "

	self 
		forceCallout: false;
		initializeResourceRegistries;
		initializeSpecialSessionResources;
		trackResources: true;
		registerSessionEventHandlers.! 
callbackSelectorPrefix
		" Private - answer the prefix used to construct a callback selector
		from the entry point selector. "

	^'invoke'!  
recompileClass: aClass
		" Recompile all methods in <aClass>. "

    | className isMetaClass |
	( Smalltalk includesKey: #TeamVInterface )
		ifTrue: [
			className := aClass symbol.
			Transcript show: 'recompiling all methods in ', aClass name; cr.
			( Array with: aClass class with: aClass ) do: [ :b |
			isMetaClass := b isMetaClass.
			b selectors do: [ :aSelector |
				( self currentSubsystem
					definitionOfMethod: aSelector
					inClassNamed: className
					meta: isMetaClass)
						recompile ] ].
			]
	ifFalse: [
		aClass class compileAll.
		aClass compileAll ].!  
callbackSelectorFor: eptDescription
		" Private - answer the selector which is sent to instances
		of the receiver when the entry point described by
		<eptDescription> is invoked by an external caller. "

    ( #( 'DragEnter' 'DragOver' 'Drop' ) includes: eptDescription name )
		ifTrue: [   " special callin handling of POINT arg "
			^( self callbackSelectorPrefix, eptDescription selector, '_:' ) asSymbol ].
	^super callbackSelectorFor: eptDescription!  
callbackSelectorFor: eptDescription
		" Private - answer the selector which is sent to instances
		of the receiver when the entry point described by
		<eptDescription> is invoked by an external caller.
		By default, the callin selector is the entry point name
		prefixed by 'invoke' and a suitable number of
		argument keywords, e.g., #invokeQueryInterface:_: "

	| entryPointSelector callBackSelector |
	entryPointSelector := eptDescription selector.
	callBackSelector := self callbackSelectorPrefix, 
		( entryPointSelector first isUpperCase
			ifTrue: [ entryPointSelector ]
			ifFalse: [ 
				entryPointSelector first asUpperCase asString,
				( entryPointSelector copyFrom: 2 to: entryPointSelector size ) ] ).
	^callBackSelector asSymbol!  
vtableMethodsLocal
        " Private - answer the VTable dispatch methods which are implemented by the receiver,
        in an array ordered by VTable slot index. "

    | methods entryPointDict slotIndex maxIndex entry methodList |
    methods := self methodDictionary values
        select: [ :cm | cm isAPIMethod and: [ ( cm at: 1 ) isInteger ] ].
    methods isEmpty
        ifTrue: [ ^#() ].
    entryPointDict := Dictionary new.
    maxIndex := 0.
    methods do: [ :cm |
        slotIndex := cm at: 1.
        ( entry := entryPointDict at: slotIndex ifAbsent: [nil ] ) notNil
            ifTrue: [ MessageBox warning:
                self name, ' VTable problem: ',
                'duplicate function definitions for slot ', slotIndex printString,
                ' ( ', entry selector, ', ', cm selector, ' )' ].
        entryPointDict at: slotIndex put: cm.
        maxIndex := maxIndex max: slotIndex ].
    methodList := Array new: maxIndex + 1.
    entryPointDict associationsDo: [ :assoc |
        methodList at: assoc key + 1 put: assoc value ].
    ^methodList

!  
initialize
		" Private - initialize the class state.
		NOTE: The IID must be initialized separately before evaluating this initialization. "

	self 
		registerIID;
		initializeVTable.!
vtableDescription
		" Answer an array of entry point descriptions, in VTable order,
		of the receiver's VTable functions. "

	^self constructVTableDescription!   
entryPointSelectorFromPrimitiveSelector: primitiveSelector
        " Private - answer the entry point name corresponding to the 
		primitive dispatch method selector <primitiveSelector>. "

	| entryPointProposal interfaceClasses entryPointSelector |
    #( 'invoke' 'primitive' ) do: [ :aPrefix |
        ( primitiveSelector size > aPrefix size
        and: [ ( primitiveSelector copyFrom: 1 to: aPrefix size ) = aPrefix ] )
            ifTrue: [
                entryPointProposal := primitiveSelector copyFrom: aPrefix size + 1 
				to: primitiveSelector size.
                interfaceClasses := self allSuperclasses reversed,
                    ( Array with: self ).
	            interfaceClasses := interfaceClasses 
		            copyFrom: (interfaceClasses indexOf: IUnknownPointer )
		            to: interfaceClasses size.
	            interfaceClasses reverseDo: [ :anInterfaceClass |
                    entryPointSelector := anInterfaceClass selectors 
                        detect: [ :aSelector |
                            aSelector asString equalsIgnoreCase: entryPointProposal ]
                        ifNone: [ nil ].
                    entryPointSelector notNil
                        ifTrue: [ ^entryPointSelector ].
                    ].
                self error: 'unknown entry point' ].
		].
    ^primitiveSelector! 
buildView: aView forModel: aCoordinator
    "Create the structure of the window <aView> for the application <aCoordinator>."

	| lineHeight aCheckBox aTextPane |

	lineHeight := aView font lineSpacing.

	aView 
		owner: aCoordinator;
		label: aCoordinator windowTitle value.
	aCoordinator windowTitle
		when: #changed:
		send: #label: to: aView.

	aCheckBox := self addCheckBoxTo: aView 
		for: aCoordinator 
		lineHeight: lineHeight 
		lineIndex: 1
		label: 'enable tracing'
		clickedSelector: #enableTracing: .
	aCheckBox value: true.
	aCheckBox := self addCheckBoxTo: aView 
		for: aCoordinator 
		lineHeight: lineHeight 
		lineIndex: 2
		label: 'trace callout'
		clickedSelector: #enableCalloutTracing: .
	aCheckBox value: OLETraceManager traceCallout.
	aCheckBox := self addCheckBoxTo: aView 
		for: aCoordinator 
		lineHeight: lineHeight 
		lineIndex: 3
		label: 'trace callin'
		clickedSelector: #enableCallinTracing: .
	aCheckBox value: OLETraceManager traceCallin.

	aView addSubpane: ( ( aTextPane := SmalltalkToolInterface current textPaneClass new )
		when: #needsContents
			send: #resetLogPane to: aCoordinator;
		framingBlock: [ :box | ( Rectangle
			leftTop: ( box leftTop down: lineHeight * 3 )
			rightBottom: box rightBottom )
				insetBy: 4 ];
		yourself ).
	aCoordinator traceLogPane: aTextPane.

	OLETraceManager 
		traceLog: aTextPane;
		traceEnabled: true.
	aView
		when: #aboutToClose
			send: #clearModified to: aTextPane;  " suppress save prompting "
		when: #closed
			send: #closeLogWindow: to: OLETraceManager with: aTextPane;
		yourself.!   
addCheckBoxTo: aView 
	for: aCoordinator 
	lineHeight: lineHeight 
	lineIndex: lineIndex
	label: aString
	clickedSelector: aSymbol
		" Private - add a check box element to <aView> "

	| aCheckBox |
	aView addSubpane: ( ( aCheckBox := CheckBox new )
		label: aString;
		when: #clicked:
			send: aSymbol to: aCoordinator;
		framingBlock: [ :box | Rectangle
			leftTop: ( box leftTop down: ( ( lineIndex - 1 ) * lineHeight ) )
			rightBottom: ( box center x
				@ box top down: ( lineIndex * lineHeight ) ) ];
		yourself ).
	^aCheckBox!   
windowPolicyClass
    "Answer the class of window policy for the receiver."

    ^SmalltalkToolInterface current windowPolicyClass!
enableCalloutTracing: aBoolean
		" Private - set the trace flag to <aBoolean>. "

	OLETraceManager traceCallout: aBoolean.!
resetLogPane
		" Private - initialize the contents of the log pane. "

	fileName isNil
		ifTrue: [ self traceLogPane value: '' ]
		ifFalse: [ self setLogFromFile ].!
traceLogPane
		" Private "

	^traceLogPane!
enableCallinTracing: aBoolean
		" Private - set the trace flag to <aBoolean>. "

	OLETraceManager traceCallin: aBoolean.!  
setLogFromFile
		" Private - set the log pane contents from a file. "

	| fs |
	fs := File pathNameReadOnly: fileName.
	traceLogPane fileInFrom: fs.
	fs close.
	traceLogPane clearModified.!  
setWindowTitle: aString
		" Private - set the window title. "

	windowTitle setValue: aString! 
traceLogPane: aTextPane
		" Private "

	traceLogPane := aTextPane.!
printSetup
		" Private - print the contents of the log pane to a file. "

	traceLogPane mainWindow printSetup.!
print
		" Private - print the contents of the log pane to a file. "

	traceLogPane print.! 
saveImageAs
		" Private "

	traceLogPane mainWindow saveImageAs.!  
saveAs
		" Private - save the contents of the log pane to a file. "

	| aPathName |

    aPathName := ( FileDialog new
		saveFile: ( fileName isNil
			ifTrue: [ 'oletrace.txt' ]
			ifFalse: [ fileName ] ) )
            file.
	aPathName isNil
        ifTrue: [ ^self ].   " user cancelled "

	fileName := aPathName.
	self saveLogToFile.
	self setWindowTitle: self constructWindowTitle.!  
saveLogToFile
		" Private - save the log pane contents to a file. "

	| fs |
	fs := File newFile: fileName.
	traceLogPane fileOutOn: fs.
	fs close.
	traceLogPane clearModified.!  
windowTitle
		" Private - answer the window title value holder. "

	^windowTitle!  
enableTracing: aBoolean
		" Private - set the trace flag to <aBoolean>. "

	OLETraceManager traceEnabled: aBoolean.!   
saveImage
		" Private "

	traceLogPane mainWindow saveImage.!  
openFile
		" Private - set the contents of the log pane to a file. "

	| aPathName |

    aPathName := ( FileDialog new openFile ) file.
	aPathName isNil
        ifTrue: [ ^self ].   " user cancelled "

	fileName := aPathName.
	self setLogFromFile.
	self setWindowTitle: self constructWindowTitle.! 
initialize
		" Private - initialize a new instance. "

	windowTitle := SharedValue new.
	self setWindowTitle: self constructWindowTitle.! 
accept
		" Private - save the contents of the log pane to a file. "

	fileName isNil
		ifTrue: [ ^self saveAs ].
	self saveLogToFile.
! 
install
		" Private "

	traceLogPane mainWindow install.!  
constructWindowTitle
		" Private - answer the window title string. "

	| prefix |
	prefix := 'OLE Trace Log'.
	^fileName isNil
		ifTrue: [ prefix ]
		ifFalse: [ prefix, ' - ', fileName fileNameLessPath ]

	!  
describeInterfaceFunctions
		" Display a description of the functions in this interface. "

	| interfaceClasses inheritedChunks aPointerClass vtableDescription 
	  aStream indent indent2 chunkIndex nextChunk anEntryPoint nArgs |

	" construct list of inherited interface specifications "
    interfaceClasses := self allSuperclasses reversed,
        ( Array with: self ).
	interfaceClasses := interfaceClasses 
		copyFrom: (interfaceClasses indexOf: IUnknown )
		to: interfaceClasses size.
	inheritedChunks := OrderedCollection new.
	interfaceClasses do: [ :aClass |
		( aPointerClass := aClass interfacePointerClass ) notNil
			ifTrue: [
				inheritedChunks add: ( Array with: aClass name
					with: aPointerClass vtableDescription size ) ].
		].
	vtableDescription := self interfacePointerClass vtableDescription.

	aStream := ReadWriteStream on: String new.
	indent := '    '.
	indent2 := indent, indent.
	aStream
		nextPutAll: self name, ' Interface Functions'; cr;
		nextPutAll: indent, 'IID: ', self iid printString; cr.
	chunkIndex := 0.
	nextChunk := 0.
	1 to: vtableDescription size do: [ :i |
		anEntryPoint := vtableDescription at: i.
		nArgs := anEntryPoint argumentTypes size.
		i > nextChunk
			ifTrue: [
				chunkIndex := chunkIndex + 1.
				nextChunk := ( inheritedChunks at: chunkIndex ) at: 2.
				aStream cr; nextPutAll: 
					'== ', ( (inheritedChunks at: chunkIndex ) at: 1 ), ' Functions =='; cr.
				].
		aStream 
			nextPutAll: i printString, '. ', anEntryPoint name;
				nextPutAll: ' ( VTable index ', anEntryPoint vtableIndex printString, ' )'; cr;
			nextPutAll: indent2, '#', anEntryPoint selector, ' ( ', nArgs printString;
				nextPutAll: ( nArgs = 1 ifTrue: [ ' argument' ] ifFalse: [ ' arguments' ] ); 
				nextPutAll: ' )'; cr;
			nextPutAll: indent2, 'Result type: ', anEntryPoint resultType; cr.			
		].
	"aStream nextPutAll: '( ', vtableDescription size printString, ' functions)'; cr."
	TextWindow new
		label: self name, ' Interface Functions';
		openOn: aStream contents.!   
constructVTable
		" Private - construct the VTable which is shared by all instances of the receiver. "

	| vtableDescription |
	vtableDescription := self constructVTableDescription.
	vtableDescription isNil
		ifTrue: [ ^nil ].
	^OLEExternalVTable forEntryPoints: vtableDescription 
		callbackSelectors: ( self constructCallbackSelectorsFor: vtableDescription )! 
vtableMethods
		" Private - answer the VTable dispatch methods of the receiver,
		in an array ordered by VTable slot index. "

	| interfaceClasses localVTables mergedVTable cm |

	self == OLEInterfacePointer
		ifTrue: [ ^#( ) ].

	interfaceClasses := self withAllSuperclasses reversed.
	interfaceClasses := interfaceClasses 
		copyFrom: ( interfaceClasses indexOf: OLEInterfacePointer ) + 1 
		to: interfaceClasses size.
	localVTables := interfaceClasses collect: [ :aClass | aClass vtableMethodsLocal ].

	mergedVTable := Array new: ( localVTables
		inject: 0 into: [ :maxSize :aVTable | maxSize max: aVTable size ] ).
	localVTables do: [ :aVTable |
		1 to: aVTable size do: [ :i | 
			( cm := aVTable at: i ) notNil
				ifTrue: [ mergedVTable at: i put: cm ] ].
		].
	^mergedVTable
	! 
initializeVTable
		" Private - initialize the receiver's VTable with a list of entry point
		descriptions and dispatch selectors for processing callins from
		external clients to the functions implemented by the receiver.
		The entry points must be in the order of the slots in the VTable. "

	self vtable: self constructVTable.!   
initializeTypeNames
		" Private - initialize the mapping from system moniker types to descriptive names. "

	self typeNames: self constructTypeNames.! 
functionNames
		" Answer the names of the functions in this interface,
		in VTable order. "

	^self interfacePointerClass vtableDescription 
		collect: [ :ept | ept name ]! 
uninstallConstantPools: poolNames
		" Remove the pool dictionaries whose names are contained
		in the list of symbols <poolNames> as constant pools
		in the Smalltalk development environment and recompile
		all classes in the system which reference these pools. "

	self
		removeConstantPoolNames: poolNames;
		recompilePoolReferences: poolNames.!   
inspectorFields
        " Private - answer the names of the fields contained in this kind of definition. "

    ^self inspectorClass fields: #( #memorySize #address )!
initialize
		" Private - initialize the class state.
		NOTE: The IID must be initialized separately before evaluating this initialization. "

	self registerIID.
!   
apiPrimitiveFor: aCallingConvention
        "Private - answer the primitive number to be used when
         making an API call using the calling convention
         named by <aCallingConvention> (a String), 
		or nil if the given calling convention
         is not supported by the receiver class."

    ^self apiPrimitiveMap at: aCallingConvention ifAbsent: [ nil ]!
apiPrimitiveMap
        "Private - answer a Dictionary mapping API calling
         conventions to their API call primitive number."

	| dll32PrimitiveMap |
	dll32PrimitiveMap := DynamicLinkLibrary apiPrimitiveMap.
    ^Dictionary new
        at: 'ole:' put: ( dll32PrimitiveMap at: 'ole:' );
        yourself!
updateResourceLists
		" Private - update the lists of resources "

	self updateExportedResourceLists.
	"??self validateAllocatedInterfaces.??"!   
clearLists
		" Private - clear the lists of resources "

	self clearExportedLists.
!  
getExportedInterfaceList
		" Private - answer the unsorted list of interface implementations
		to display in the exported interfaces list. "

	^OLESessionManager allExportedInterfaces!  
cleanUpResourceLists
		" Private - clear the system and recompute the resource lists. "

	self clearLists.
	Smalltalk unusedMemory.  " force garbage collect to clean up finalization registries "
	self updateResourceLists.!