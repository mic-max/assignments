3.1.0.106
   
invokeCLSIDFromString: lpsz _: pclsid
        "Private - WINOLEAPI CLSIDFromString(LPOLESTR lpsz, LPCLSID pclsid);"

	| hresult |
	<api: CLSIDFromString structIn structOut hresult>
	hresult := self apiFailureReason.
	hresult = CO_E_CLASSSTRING
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!  
invokeStgIsStorageFile: pwcsName
		"Private - WINOLEAPI StgIsStorageFile(const OLECHAR FAR* pwcsName);"

    <api: StgIsStorageFile structIn hresult>
    ^self apiCallFailed!
newHolder
		" Create a new data advise holder.  Answer a new instance of the receiver. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current CreateDataAdviseHolder: resultReference.
	"self ASSERT: resultReference value class == self."
	^resultReference value!   
dataAdviseConnections
		" Answer a collection of STATDATA structures which describe
		the data advise connections currently established on the data object. "

	| anEnumerator contents |
	anEnumerator := self dataAdviseConnectionsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!   
dataAdviseConnectionsEnumerator
		" Answer an enumerator on the collection of STATDATA structures which 
		describe the data advise connections currently established on the data object. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumSTATDATA ) asValueReference.
	interface EnumAdvise: resultReference.
	^resultReference value!   
sendOnDataChange: aDataObject flags: advfFlags
		"Invoke IAdviseSink::OnDataChange for all advisory sinks currently
		registered with the holder whenever changes of interest to the object
		represented by <aDataObject> occur.  The <advfFlags> flags specify
		information about the notification to be sent. "

	interface SendOnDataChange: aDataObject  _: 0 _: advfFlags.

!  
removeAdviseConnection: connectionToken
		"Delete the advisory connection identified by <connectionToken>,
		which previously established using IDataAdviseHolder::Advise. "

	interface Unadvise: connectionToken. ! 
createAdviseConnectionFrom: aDataObject
	to: anAdviseSink
	format: aFormatEtc
	flags: advfFlags
		" Create an advise connection between the data object <aDataObject> 
		and the advise sink <anAdviseSink> though which the sink can
		be informed when the object's data changes.  The format
		specified by <aFormatEtc> will be used when reporting changes.
		The ADVF flags in <advfFlags> control the connection.
		Answer a connection token which can later be used to delete
		this advise connection. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Advise: aDataObject 
		_: aFormatEtc
		_: advfFlags
		_: anAdviseSink 
		_: resultReference.
	^resultReference value!
OleIsCurrentClipboard: anIDataObject
		" Determine whether <anIDataObject> is still on the clipboard.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeOleIsCurrentClipboard: anIDataObject asParameter
!   
onIconViewChange
		" Notifier the receiver that the icon view of the calling object has changed. "

	self onViewChange: DVASPECT_ICON.!
onRename: aMoniker
		" Notify the receiver that the name of the calling object has changed to <aMoniker>.
		The notification is asynchronous and the arguments belong to the caller. "

	interface OnRename: aMoniker!
onContentViewChange
		" Notifier the receiver that the content view of the calling object has changed. "

	self onViewChange: DVASPECT_CONTENT.!   
onSave
		" Notify the receiver that the calling object has been saved to persistent storage.
		The notification is asynchronous. "

	interface OnSave.!   
onDataChange: aFormatEtc storageMedium: aStgMedium
		" Notify the receiver that the data in the calling object has changed.
		The FORMATETC format information that the receiver provided
		when this data advise was established via IDataObject::DAdvise is
		provided in <aFormatEtc>. The changed data in the specified format
		is provided in <aStgMedium>.  The notification is asynchronous.
		The arguments belong to the caller and are valid only for the duration of this call. "

	interface OnDataChange: aFormatEtc _: aStgMedium.!
onViewChange: dwAspect
		" Notify the receiver that the view of the calling object described by 
		the DVASPECT value in <dwAspect> has changed.
		The notification is asynchronous and the arguments belong to the caller. "

	" In OLE 2.0.1, <dwAspect> must be a single value and <lindex> must be -1. "
	interface OnViewChange: dwAspect _: -1.!  
onClose
		" Notify the receiver that the calling object has closed (transitioned from
		the running to the loaded state) and is shutting down.  
		The notification is asynchronous. "

	interface OnClose!  
validateDispatchHandlers: handlers
		" Private - validate the interface function dispatch handlers in the <handlers> array.
		Ensure that a complete set is provided and that as far as can be determined
		that the handlers are consistent with the function for which they are registered.
		The handlers is an Array in VTable order. "

	| eptDescriptions aHandler eptDescription |

	handlers size = self vtable size
		ifFalse: [ 
			MessageBox warning: 
				self name, ' VTable handlers problems: size mismatch' ].

	eptDescriptions := self vtableDescription.
	1 to: ( handlers size min: eptDescriptions size ) do: [ :i |
		aHandler := handlers at: i.
		eptDescription := eptDescriptions at: i.
		aHandler isNil
			ifTrue: [
				MessageBox warning: 
					self name, 
					' VTable handlers problems: no handler for ', 
					eptDescription name ]
			ifFalse: [
				self validateHandler: aHandler for: eptDescription ].
		].
	!  
subclassForIID: anIID
		" Private - answer the OLEInterface class which supports the
		interface identified by the GUID <anIID>. "

	^OLEInterfacePointer allSubclasses
		detect: [ :aClass | aClass supportsIID: anIID ]
		ifNone: [ nil ]!
createStructureNamed: structureName fromAddress: anAddress
		" Answer a new data structure instance for the host structure named <structureName>
		The structure is allocated in Smalltalk memory and filled with
		the data at <anAddress>. "

	^( self classForStructureNamed: structureName ) fromAddress: anAddress! 
on: anObject
		"Answer a new instance of the receiver which supports its interface on <anObject>. "

	^self forBinding: ( self interfaceImplementationClass for: anObject )!   
invalidateExternalVTable
		" Invalidate the address of the universal VTable in external memory. "

	self externalVTableAddress: nil.!  
forEntryPoints: entryPointDescriptions callbackSelectors: callbackSelectors
		"Answer a new instance of the receiver which defines the
		callin descriptor for an interface, according to the function
		type information in the entry point descriptions <entryPointDescriptions>
		and the callback dispatch selectors in the list <callbackSelectors>. "

	entryPointDescriptions size > self externalVTableSize
		ifTrue: [ self error: 'VTable callin table size exceeded' ].
	 entryPointDescriptions size = callbackSelectors size
		ifFalse: [ self error: 'entry point/selector size mismatch' ].
	^self new 
		entryPoints: entryPointDescriptions
		callbackSelectors: callbackSelectors!  
allocateExternalVTable
		" Private - allocate the universal VTable in external memory
		that is shared by all OLE interfaces implemented in Smalltalk.
		The VTable is a table of 4-type function pointers.
		Answer its address. "

	| nFunctions vtableAddress vtableReference 
	  functionPointerOffset aFunctionPointer |
	nFunctions := self externalVTableSize.
	vtableAddress := OLEMemoryAddress allocateMemory: nFunctions *  4.
	vtableAddress doesNotNeedFinalization.  " released at image exit "
	vtableReference := ExternalBuffer atAddress: vtableAddress.
	functionPointerOffset := 0.
	1 to: nFunctions do: [ :i |
		aFunctionPointer := ExternalObjectTable stubTableAddress + ( 10 * ( i - 1 ) ).
		vtableReference 
			bytesAtOffset: functionPointerOffset
			put: aFunctionPointer asParameter.
		functionPointerOffset := functionPointerOffset + 4 ].
	^vtableAddress!
releaseExternalVTable
		" Release the universal VTable in external memory. "

	externalVTableAddress notNil
		ifTrue: [
			externalVTableAddress free.
			self externalVTableAddress: nil ].!   
externalVTableAddress: anAddressOrNil
		" Set the address of the universal VTable in external memory to <anAddressOrNil>. "

	externalVTableAddress := anAddressOrNil.!
externalVTableAddress
		" Answer the address of the universal VTable in external memory. "

	externalVTableAddress isNil
		ifTrue: [ self externalVTableAddress: self allocateExternalVTable ].
	^externalVTableAddress! 
externalVTableSize
		" Private - answer the number of function entries in
		the universal external VTable.  Maximum allowed is
		determined by VM allocation. "

	^40!   
argumentTypeNumberFor: aSymbol
		" Private - answer the encoded index of the argument type <aSymbol>. "

	aSymbol = #address
		ifTrue: [ ^13 ].
	^DynamicLinkLibrary argumentTypeNumber: aSymbol
		ifAbsent: [ self error: 'unknown argument type' ]!   
vtableDescription
		" Answer the VTable description in the form of a list
		of OLE entry point descriptions, ordered by VTable slot index. "

	^vtableDescription!
callinEntryPointDescriptionFrom: eptDescription
		" Private - answer the entry point description needed
		to process a callin from an external caller to the interface 
		function described by <eptDescription>.  Map the argument
		and result types from the callout entry point description into
		the equivalent values which descrive the value to be constructed
		by the virtual machine callin mechanism when a callback
		to the entry point is invoked by an external caller. "

	^OLEEntryPointDescription
		name: eptDescription name 
		selector: eptDescription selector
		vtableIndex: eptDescription vtableIndex 
		argumentTypes: ( eptDescription argumentTypes
			collect: [ :anArgType | self callinArgumentTypeFor: anArgType ] )
		resultType: ( self callinResultTypeFor: eptDescription resultType )! 
entryPoints: entryPointDescriptions callbackSelectors: callbackSelectors
		" Private - encode the <entryPointDescriptions> and
		callback dispatch selectors in <callbackSelectors> in the
		descriptor list format used by the VTable callin mechanism. 
		Each entry point has a pair of entries in the list:
		the encoded argument/result types and the dispatch selector. "

	| nFunctions descriptorIndex ept encodedTypes |
	vtableDescription := entryPointDescriptions
		collect: [ :eptDescription | self callinEntryPointDescriptionFrom: eptDescription ].
	nFunctions := vtableDescription size.
	vtableCallinDescriptor := Array new: nFunctions * 2.
	descriptorIndex := 1.
	1 to: nFunctions do: [ :i |
		ept := vtableDescription at: i.
		encodedTypes := ByteArray new: ept argumentTypes size + 1.
		1 to: encodedTypes size - 1 do: [ :argIndex | 
			encodedTypes 
				at: argIndex
				put: ( self argumentTypeNumberFor: ( ept argumentTypes at: argIndex ) ) ].
		encodedTypes 
			at: encodedTypes size 
			put: ( self resultTypeNumberFor: ept resultType ).
		vtableCallinDescriptor
			at: descriptorIndex put: encodedTypes;
			at: descriptorIndex + 1 put: ( callbackSelectors at: i ).
		descriptorIndex := descriptorIndex + 2 ].!   
externalAddress
		" Answer the external address of the receiver's function table. "

	^self class externalVTableAddress!   
callinArgumentTypeFor: aSymbol
        " Private - answer the argument type symbol for processing
        a callin argument whose callout type is <aSymbol>. "

    ( #( #struct #structIn #structOut ) includes: aSymbol )
        ifTrue: [ ^#address ].  " callin mechanism constructs ExternalAddress "
    ( #( #boolean #ulong #long #ushort #short ) includes: aSymbol )
        ifTrue: [ ^aSymbol ].
    aSymbol = #handle
        ifTrue: [ ^#ulong ].
    MessageBox warning: 'unsupported callin argument type conversion: #', aSymbol.
    ^aSymbol!  
size
		" Answer the size of the VTable. "

	^self vtableDescription size!  
resultTypeNumberFor: aSymbol
		" Private - answer the encoded index of the result type <aSymbol>. "

	aSymbol = #hresult
		ifTrue: [ ^self resultTypeNumberFor: #ulongReturn ].
	^DynamicLinkLibrary resultTypeNumber: aSymbol
		ifAbsent: [ self error: 'unknown result type' ]!   
callinResultTypeFor: aSymbol
		" Private - answer the result type symbol for returning
		a callin result value whose callout type is <aSymbol>. "

	aSymbol = #hresult
		ifTrue: [ ^#ulongReturn ].
	( #( #ulongReturn #boolean #none ) includes: aSymbol )
		ifTrue: [ ^aSymbol ].
	MessageBox warning: 'unsupported callin result type conversion: #', aSymbol.
	^aSymbol! 
vtableCallinDescriptor
		" Answer the VTable callin descriptor that is registered in the
		external object table (along with the interface implementation itself)
		to define the type handling and dispatch selector for an OLE 
		function table.  Each function in the VTable has a pair of entries
		in the callin descriptor: an encoded list of the argument/return types
		and the dispatch selector. "

	^vtableCallinDescriptor! 
callbackSelectors
		" Answer the dispatch selectors for processing callins to this VTable,
		ordered by VTable slot index. "

	^vtableCallinDescriptor select: [ :entry | entry isSymbol ]!   
invokeOleRun: pUnknown
        "Private - WINOLEAPI OleRun(
                LPUNKNOWN pUnknown);"

    <api: OleRun handle hresult>
    ^self apiCallFailed! 
name: aString 
	selector: aSymbol 
	vtableIndex: vtableIndex 
	argumentTypes: argumentTypesArray 
	resultType: resultType
		"Create an instance of the receiver describing the entry point as specified"

	^self new
		name: aString;
		selector: aSymbol;
		vtableIndex: vtableIndex;
		argumentTypes: argumentTypesArray;  
		resultType: resultType
! 
callingConvention
        " Answer the default calling convention used by OLE interface functions. "

    ^#stdcall  " standard API calling convention "!  
Load: anIStorage
		" Invoke the IPersistStorage::Load function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeLoad: anIStorage asParameter!   
HandsOffStorage
		" Invoke the IPersistStorage::HandsOffStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT HandsOffStorage( void); "

	<ole: 9 hresult>
	^self vtableDispatchFailed!
invokeLoad: pStg
		" Private - invoke the IPersistStorage::Load function. "

	"  HRESULT Load(
            /* [unique][in] */ IStorage *pStg); "

    <ole: 6 handle hresult>
    ^self vtableDispatchFailed!  
invokeSave: pStgSave _: fSameAsLoad
		" Private - invoke the IPersistStorage::Save function. "

	" HRESULT Save(
            /* [unique][in] */ IStorage *pStgSave,
            /* [in] */ BOOL fSameAsLoad); "

    <ole: 7 handle boolean hresult>
    ^self vtableDispatchFailed!  
SaveCompleted: anIStorage
		" Invoke the IPersistStorage::SaveCompleted function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSaveCompleted: anIStorage asParameter!
Save: anIStorage _: fSameAsLoad
		" Invoke the IPersistStorage::Save function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self 
		invokeLoad: anIStorage asParameter
		_:  fSameAsLoad! 
InitNew: anIStorage
		" Invoke the IPersistStorage::InitNew function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeInitNew: anIStorage asParameter!  
invokeInitNew: pStg
		" Private - invoke the IPersistStorage::InitNew function. "

	" HRESULT InitNew(
            /* [unique][in] */ IStorage *pStg); "

    <ole: 5 handle hresult>
    ^self vtableDispatchFailed!  
invokeSaveCompleted: pStgNew
		" Private - invoke the IPersistStorage::SaveCompleted function. "

	" HRESULT SaveCompleted(
            /* [unique][in] */ IStorage *pStgNew); "

    <ole: 8 handle hresult>
    ^self vtableDispatchFailed!  
IsDirty
	    " Invoke the IPersistStorage::IsDirty function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT IsDirty( void);"

	<ole: 4 hresult>
	^self vtableDispatchFailed!  
invokeGetClassID: resultReference
		" Private - invoke the IPersist::GetClassID function. "

	" HRESULT GetClassID(
            /* [out] */ CLSID *pClassID); "

	<ole: 3 structOut hresult>
	^self vtableDispatchFailed!  
GetClassID: resultReference
		" Invoke the IPersist::GetClassID function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeGetClassID: resultValue.
	resultReference value: resultValue.
	^hresult!  
registerByteArrayClass: aClass
        " Private - register the ByteArray class for constructing callbacks. "

    <primitive: 171>!   
stubTableAddress: anExternalAddress
		" Private - set the address of the callback stub table. "

	StubTableAddress := anExternalAddress.!  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."

	^super constructEventsTriggered
		add: #aboutToInvalidate;
		add: #invalidating;
		yourself!   
allocateExternalObjectTable
		" Private - allocate the current EOT.  This is only done
		when the code is loaded for the first time or during
		the library building/cloning process. "

	self current: self new.!   
removeSessionEventHandlers
    " Remove the image startup and shutdown event handlers.
		ExternalObjectTable removeSessionEventHandlers "

	#( #startup ) do: [ :anEvent |
         SessionModel current 
             removeActionsWithReceiver: self 
             forEvent: anEvent ].
!   
current
		" Answer the current External Object Table.  There is one global instance in the system. "

	^current!   
current: anExternalObjectTable
		" Private - set the current External Object Table.  There is one global instance in the system. "

	"?? What if any error checking to do??  [DJL 07-Feb-95]
    ( anExternalObjectTable notNil and: [ current notNil ] )
		ifTrue: [ self error: 'already allocated' ].
	"
	current := anExternalObjectTable.!
initializeStubTableAddress
		" Private - answer the stub table address in the VM (if any). "

	| anAddress |
	anAddress := ExternalAddress fromBytes:
        ( KernelLibrary getProcAddress: VirtualMachineExe current procName: 'stubTable').
	self stubTableAddress: ( anAddress isValid
		ifTrue: [ anAddress ]
		ifFalse: [ nil ] ).!
registerSessionEventHandlers
	" Register the image startup and shutdown event handlers.
		ExternalObjectTable registerSessionEventHandlers "

	SessionModel current
		when: #startup 
		send: #startUp to: self.!   
removeComponent
		" Private - remove the ExternalObjectTable component. "

	self removeSessionEventHandlers.!  
new
		"Answer an initialized and empty instance of the receiver."

	^super new initialize! 
stubTableAddress
		" Private - answer the address of the callback stub table. "

	^StubTableAddress!   
installComponent
		" Private - install the ExternalObjectTable component. "

	self 
		registerExternalObjectTable;
		registerSessionEventHandlers.!  
registerExternalAddressClass: aClass
		" Private - register the external address class for constructing callbacks. "

    <primitive: 169>!
registerExternalInterfaceObjects: interfaceObjects
		" Private - register the EOT storage for the VM. "

	"Note to Brad: This can be removed when the image is cloned
		to install the ExternalObjectTable as a fixed pointer.
		[Deb/Roger 17-Apr-94] " 
    <primitive: 168>! 
newBlockOfEntries
		"Private - Answer a new block of empty entries into which more object-to-indices mappings can be stored."

	^Array new: 100!   
startUp
		" Private - the session is being started.  Reset the external object table. "

	self current invalidate.
	self registerExternalObjectTable.!
registerExternalObjectTable
		" Private - register the ExternalObjectTable with the VM. "

	self initializeStubTableAddress.
	self stubTableAddress isNil
		ifTrue: [  " VM does not support enhanced callback mechanism "
			MessageBox warning: 'Unable to register ExternalObjectTable callback mechanism (no VM support).'.
			^nil ].

	self
		registerExternalAddressClass: ExternalAddress;
		registerByteArrayClass: ByteArray;
		registerExternalInterfaceObjects: self current.!
notEmpty
		" Answer whether there are any objects registered in the receiver. "

	^( objects select: [ :anObject | anObject notNil and: [ anObject isInteger not ] ] ) notEmpty!   
allocateIndexFor: anObject
	"Private - Atomically answer the next available index and mark it in use by <anObject>.  
	Answer nil if none are available."

	| anIndex |
	[ ( anIndex := nextIndex ) == nil
			ifFalse: [
				nextIndex := objects at: anIndex.
				objects at: anIndex put: anObject ] ] 
		evaluateWithoutInterrupts.
	^anIndex!   
indexFor: anObject
	"Register <anObject> in the receiver and answer the index (anInteger) under which it is registered."

	| anIndex |
	[ ( anIndex := self allocateIndexFor: anObject ) == nil ]
		whileTrue: [ self grow ].
	^anIndex!
isEmpty
		" Answer whether there are any objects registered in the receiver. "

	^self notEmpty not!   
initialize
		" Private - initialize a newly created instance. "

	objects := self class newBlockOfEntries.
	1 to: objects size - 1 do: [ :i | objects at: i put: i + 1 ].	
	nextIndex := 1.! 
registeredObjects
		" Answer the objects which are registered in the receiver. "

	^objects select: [ :anObject | 
		anObject notNil and: [ anObject isInteger not ] ]!   
invalidate
		" Invalidate the contents of the receiver.  All registered objects will be lost. "

	[ self triggerEvent: #aboutToInvalidate ]
		on: VetoAction
		do: [ ^self ].
	self triggerEvent: #invalidating.
	self initialize.!
removeObjectAt: anIndex
	"Remove the object registered at <anIndex> from the receiver."

	[ objects at: anIndex put: nextIndex.
	nextIndex := anIndex ] 
		evaluateWithoutInterrupts.!   
objectAt: anIndex
	"Answer the object registered at <anIndex>."

	^objects at: anIndex!
grow
	"Private - Atomically grow the receiver by adding another block of entries.  
	Note this operation must be atomic in the face of multiple processes and interrupts"

	| old new newBlock listhead |

		"Atomically take a snapshot of the current internal state and set nextIndex to nil.
		Setting it nil does two things, first it forces all future efforts to allocate indices to fail
		and hence come thru this code, and second it serves as a flag to make sure that only 
       one of the attempts to grow that may be in process simultaneously will succeed"
	[old := objects.
		listhead := nextIndex.
		nextIndex := nil] evaluateWithoutInterrupts.

		"construct the proposed new internal state."
	newBlock := self class newBlockOfEntries.
	new := old , newBlock.
	1 to: newBlock size - 1 do: [:index |
			new at: old size + index put: old size + index + 1].
	new at: new size put: listhead.
	listhead := old size + 1.

		"Atomically test nextIndex and update the internal state to the proposed
		state as follows:  If nextIndex is now non-nil, it means that somebody else has succeeeded in
		growing or indices have been freed so we should do nothing. If it is still nil, then we are the
		one that is supposed to succeed so update the internal state with the proposed state." 
	[nextIndex == nil     
		ifTrue:
			[nextIndex := listhead.
			objects := new]] evaluateWithoutInterrupts! 
registerIID
        " Private - register the receiver as the interface class for its IID. "

    self registerIID: self iid forClass: self.!   
interfaceAtAddress: ulongAddress type: anInterfaceSpecification
        " Private - answer the interface argument at address <ulongAddress>.
        An interface pointer which is passed as an argument is temporarily owned
        (i.e., because it is not separately reference counted and should not be
        released by the callee, the interface pointer is created here without finalization).
        The callee must make a copy and independently reference count the copy
        if it holds on to the interface beyond the duration of the function invocation. "

	| anInterfaceClass |
	ulongAddress = 0
		ifTrue: [ ^nil ].
	anInterfaceClass := ( anInterfaceSpecification isClass
		ifTrue: [ anInterfaceSpecification ]
		ifFalse: [ OLEInterface classForIID: anInterfaceSpecification ] ).
    ^anInterfaceClass forTemporaryInterfacePointerAtAddress:
        ( ExternalAddress fromInteger: ulongAddress )!   
AddRef
		" Invoke the IUnknown::AddRef function. "

    | newReferenceCount |
    self ifOLETraceEnabled: [ self logFunctionEntry ].
    newReferenceCount := self invokeAddRef.
    self ifOLETraceEnabled: [
        self logReturnValue: 'Ref count: ', newReferenceCount printString ].
    ^newReferenceCount
! 
copy
		" Answer a copy of the receiver.  The copy is not separately
		reference counted and should not be released unless the
		it is explicitly reference counted. "

	^self class forIID: self iid
		binding: self copyInterfaceBinding
		elementClass: elementClass!
copyInterfaceBinding
        " Private - answer a copy of the receiver's interface binding. "

    ^interface isOLEInterfacePointer
        ifTrue: [   " pointer to VTable in external memory "
            interface isValid
                ifFalse: [
                    OLEDevelopmentWarning signal: 
					'Invalid interface pointer not copied: ', interface printString.
                    ^nil ].
            interface class newTemporaryInterfacePointer
                setBytes: interface;
                yourself
            ]
    ifFalse: [ interface ]   " interface implementation or nil "!   
vtableDescription
		" Answer an array of entry point descriptions, in VTable order,
		of the receiver's callin VTable functions. "

	^self class vtableDescription
! 
invokeStgIsStorageILockBytes: plkbyt
		"Private - WINOLEAPI StgIsStorageILockBytes(ILockBytes FAR* plkbyt);"

    <api: StgIsStorageILockBytes structIn hresult>
    ^self apiCallFailed! 
driverName: driverNameString 
	deviceName: deviceNameString 
	portName: portNameString
	extDevMode: extDevMode
		" Answer a new instance of the receiver with the specified values. "

	self error: 'not yet implemented'!  
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^12!  
registrationToken: anInteger
		" Private - set the receiver's registration token from its OLE registration. "

	registrationToken := anInteger.!   
fileName
        "Answer the receiver's file name."

     ^'ole32.dll'!
CreateBindCtx: reserved _: resultReference
		" Create and initialize a new bind context.
		Store the interface pointer into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IBindCtxPointer forReturnValue.
	hresult := self invokeCreateBindCtx: reserved
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
! 
invokeSave: pszFileName _: fRemember
		" Private - invoke the IPersistFile::Save function. "

	" HRESULT Save(
            /* [unique][in] */ LPCOLESTR pszFileName,
            /* [in] */ BOOL fRemember); "

    <ole: 6 structIn boolean hresult>
    ^self vtableDispatchFailed! 
SaveCompleted: aPathName
		" Invoke the IPersistFile::SaveCompleted function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSaveCompleted: ( self asUnicodeParameter: aPathName )!
Save: aPathName _: fRemember
		" Invoke the IPersistFile::Save function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSave: ( self asUnicodeParameter: aPathName )
		_: fRemember!  
invokeGetCurFile: ppszFileName
		" Private - invoke the IPersistFile::GetCurFile function. "

	" HRESULT GetCurFile(
            /* [out] */ LPOLESTR *ppszFileName); "

    <ole: 8 structOut hresult>
    ^self vtableDispatchFailed!
invokeLoad: pszFileName _: dwMode
		" Private - invoke the IPersistFile::Load function. "

	" HRESULT Load(
            /* [in] */ LPCOLESTR pszFileName,
            /* [in] */ DWORD dwMode); "

    <ole: 5 structIn ulong hresult>
    ^self vtableDispatchFailed!
Load: aPathName _: accessModeFlags
		" Invoke the IPersistFile::Load function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeLoad: ( self asUnicodeParameter: aPathName )
		_: accessModeFlags!  
invokeSaveCompleted: pszFileName
		" Private - invoke the IPersistFile::SaveCompleted function. "

	" HRESULT SaveCompleted(
            /* [unique][in] */ LPCOLESTR pszFileName); "

    <ole: 7 structIn hresult>
    ^self vtableDispatchFailed!   
IsDirty
		" Invoke the IPersistFile::IsDirty function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT IsDirty( void); "

    <ole: 4 hresult>
	^self vtableDispatchFailed!
GetCurFile: resultReference
		" Invoke the IPersistFile::GetCurFile function.
		Raise an exception if an error occurs.  Answer the result code. "
		
	| resultValue hresult |
    resultValue := self createStringResultValue.
	hresult := self invokeGetCurFile: resultValue.
	resultReference value: ( self stringFromResultValue: resultValue ).
	^hresult!
CreateDataAdviseHolder: resultReference
		"Create a new data advise holder and store its IDataAdviseHolder
		interface into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IDataAdviseHolderPointer forReturnValue.
	hresult := self invokeCreateDataAdviseHolder: resultValue asParameter.
	resultReference value: resultValue.
	^hresult

!
on: anObject selectors: selectors
		"Answer a new instance of the receiver which supports its interface on <anObject>
		using <selectors> as the interface function handlers to delegate processing
		responsibility to the implementing object.  The <selectors> list must be exact match
		in size, order, and argument count to the interface VTable function layout. "

	^self forBinding: 
		( self interfaceImplementationClass for: anObject selectors: selectors )!
nullValue
        "Answer an instance of the receiver class which represents
        an invalid (uninitialized) value."

    ^NullInterfacePointer!   
vtable
		"Private - answer the VTable that is shared by all instances of the receiver's class.  
		This message is added solely as an aid in using inspectors."

	^self class vtable! 
allocateElementBuffer: cElements
		" Private - allocate a buffer which can contain up the <cElements>
		instances of the receiver's data type. "

	^ExternalBuffer new: ( self elementSize * cElements )! 
on: anObject
		"Answer a new instance of the receiver which supports its interface on <anObject>. "

	^self forBinding: 
		( ( self interfaceImplementationClass for: anObject )
			iid: anObject enumeratorIID;
			yourself )! 
fromIDataObject: iDataObject
        "Answer a new instance of the receiver from the specified <iDataObject>."

    ^self new fromIDataObject: iDataObject
!  
objectClass
        "Answer the class to use for DragDropObjects which are
        added to objects of the receiver class."

    ^WinDragDropObject!  
isLocalDragDropSession
        "Private - Answer whether or not an instance of the receiver is a
        a global drag drop session."
    ^false!  
isGlobalDragDropSession
        "Private - Answer whether or not an instance of the receiver is a
        a global drag drop session."
    ^true!  
printOn: aStream
		"Write the string representation of the receiver on aStream."

    aStream nextPutAll: self asString.
    !
supportsAggregration
        " Answer whether instances of the receiver will participate
        as non-control objects in an aggregate by cooperating with
        the controlling unknown of the aggregate. "

    ^true!  
classFactoryClass
		" Answer the class factory object class which creates
		instances of the receiver. "

	^OLEClassFactoryObject!
newClassFactory
		" Answer a new class factory which creates instances of the receiver. "

    ^self classFactoryClass forClass: self! 
clsid
		" Answer the CLSID of the OLE object class of instances of the receiver.
		Must be reimplemented by subclasses which implement a specific CLSID. "

	^nil!
classForCLSID: aGUID ifNone: aBlock
		" Answer the OLEObject subclass which represents the class
		specified by the CLSID <aGUID>.  Answer the result of 
		evaluating <aBlock> if the CLSID is not known. "

	^OLEObject allSubclasses 
		detect: [ :anOLEObjectClass | anOLEObjectClass clsid = aGUID ]
		ifNone: aBlock!
new
		" Answer a new instance of the receiver. "

	^super new initialize!  
forControllingUnknown: aControllingUnknown
		" Answer a new instance of the receiver for the aggregate object
		controlled by the IUnknown <aControllingUnknown>. 
		Answer nil if instances of the receiver do not support aggregation. "

    self supportsAggregration
        ifFalse: [ ^nil ].  " not a cooperative kind of guy "
	aControllingUnknown iid = IID_IUnknown
		ifFalse: [   " somewhat zealous check to detect programming errors "
			OLEDevelopmentWarning signal: 'Controlling unknown of aggregate is not an IUknown: ',
				aControllingUnknown printString ].
    ^self new
        controllingUnknown: aControllingUnknown;
        yourself!  
classForCLSID: aGUID
		" Answer the OLEObject subclass which represents the class
		specified by the CLSID <aGUID>.  Answer nil if the
		CLSID is not supported. "

	^self classForCLSID: aGUID ifNone: [ nil ]! 
session: aDragDropSession
        "Private - set the receiver's drag drop session."

    session := aDragDropSession!  
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iDropSource := nil.!
QueryContinueDrag: escKeyPressed _: keyState
		" Private - implement the IDropSource::QueryContinueDrag function.
		Determine whether a drag operation should continue. escKeyPressed
         specifies TRUE if the ESC key has been pressed by the user since
         the previous call to QueryContiueDrag. keyState identifies the present
         state of the modifier keys on the keyboard e.g. Shift, Alt, Ctrl, etc..
         Answer the result code. "

    escKeyPressed 
		ifTrue: [ ^DRAGDROP_S_CANCEL ].
    ( keyState bitAnd: MkLbutton ) = 0 
        ifTrue: [ 
            ( keyState bitAnd: MkControl ) = 0
                ifTrue: [ session operation = #move ifTrue: [ session sourceCut ] ].
         ^DRAGDROP_S_DROP ].
    ^S_OK
! 
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	iDropSource notNil
		ifTrue: [ aOneArgBlock value: iDropSource ].!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the GUID <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = IID_IDropSource
		ifTrue: [ ^iDropSource ].
	^nil! 
GiveFeedback: dwEffect
		" Private - implement the IDropSource::GiveFeedback function.
		Set the cursor for the current drop effect.
		Answer the result code. "

        "Enable a source application to provide feed during a drag
         drop session.  dwEffect specifies the DROPEFFECT value
         returned by the most recent call to IDropTarget::DragEnter or
         IDropTarget::DragOver."

    self session setOperationScroll: dwEffect.
    self session sourceFeedback notNil
        ifTrue: [ ^S_OK ]
        ifFalse: [ ^DRAGDROP_S_USEDEFAULTCURSORS ]!
initializeInterfaces
        " Private - Allocate any interfaces which are expected to be required
        during the object's lifetime. "

    super initializeInterfaces.
    iDropSource := IDropSource on: self.!
session
        "Private - answer the receiver's drag drop session."

    ^session
!  
incrementReferenceCount
		" Private - increment the receiver's reference count.
		This is the sum of the outstanding reference counts on all
		of its interfaces. "

	^referenceCount := referenceCount + 1! 
innerUnknown: anIUnknown
        " Private - set the non-delegating inner IUnknown of the receiver to <anIUnknown>.
        This is different from the controlling unknown when the receiver is part of an aggregation. "

    innerUnknown := anIUnknown.!   
addRef
		" Increment the reference count of the interface referenced by the receiver.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

    ^self AddRef!
QueryInterface: iid _: resultReference
        " Private - implement the IUnknown::QueryInterface function.
        Query the receiver for the interface identified by the GUID <iid>.
        If the requested interface is supported by the receiver, store
        a new reference counted copy of the interface into <resultReference>.
        Answer the result code. "

	self isControllingObject
		ifTrue: [ ^self innerQueryInterface: iid _: resultReference ].
    ^[ self controllingUnknown QueryInterface: iid _: resultReference ]
        on: OLEError
        do: [ :ex | ^ex hresult ]!  
releaseAllocatedInterfaces
		" Private - release the interfaces supported by the receiver
		which have been allocated during its lifetime. "

	self allocatedInterfacesDo: [ :anInterface | 
		anInterface interfaceBinding releaseResources ].
	self resetAllocatedInterfaces.!
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each.
		Should be reimplemented by each subclass.
		The subclass implementation should invoke 
		the superclass method before enumerating the 
		allocated interfaces managed by in subclass storage. "

	aOneArgBlock value: self innerUnknown.!
referenceCount
		" Private - answer the receiver's reference count.
		This is the sum of the outstanding reference counts on all
		of its interfaces. "

	^referenceCount!   
notifyClassFactoryOfRelease
		" Private - notify the creating class factory that the receiver
		has been released and is terminating itself.  Only objects
		which have published a CLSID have class factory support. "

	self clsid notNil
		ifTrue: [ self classFactoryClass objectReleased: self ].! 
releaseResources
		" Private - release resources associated with the receiver. 
		Should be reimplemented by subclasses if resources other than
		allocated interfaces or contained objects are owned by the receiver. "

	self 
		releaseInnerObjects;
		releaseAllocatedInterfaces;
		notifyClassFactoryOfRelease.
	self controllingUnknown: nil.
!   
initializeInterfaces
		" Private - Allocate any interfaces which are expected to be required 
		during the object's lifetime.  The inner IUnknown is always allocated.
		May be reimplemented by subclasses.  Subclass implementations
		must invoke the superclass method. "

    self innerUnknown: self createInnerUnknown.
!   
innerAddRef
        " Private - implement the non-delegating IUnknown::AddRef function.
        Increment the reference count of the interface referenced by the receiver.
        Answer the value of the reference count (for diagnostic use only; may not be stable). "

    ^self incrementReferenceCount!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the GUID <iid>.
		Answer nil if the requested interface is not supported by the receiver.
		This method should be reimplemented by subclasses. "

	^nil!
createInnerUnknown
        " Private - answer a new non-delegating IUnknown for the receiver. "

    ^IUnknown on: self
        selectors: #( #innerQueryInterface:_: #innerAddRef  #innerRelease )!  
interfaceForIID: iid ifNone: aBlock
        " Private - answer the interface supported by the receiver
        which is identified by the GUID <iid>.  Answer the result of
        evaluating a block if the requested interface is not supported. "

	| anInterface |
	iid = IID_IUnknown
		ifTrue: [ ^self innerUnknown ].
	^( anInterface := self getInterfaceForIID: iid ) isNil
		ifTrue: [ aBlock value ]
		ifFalse: [ anInterface ]!
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. 
		May be reimplemented by subclasses.  Subclass implementations should
		invoke the superclass method. "

	"self ASSERT: self innerUnknown interfaceBinding hasExternalResources not."
	self innerUnknown: nil.!  
release
		" Decrement the reference count of the interface referenced by the receiver.
		Release any resources associated with the receiver.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

    ^self Release!   
isControllingObject
		" Answer whether the receiver is a controlling object which 
		handles its own IUnknown operations. "

	^self controllingUnknown == self innerUnknown!  
releaseInnerObjects
		" Private - release any inner objects owned by the receiver.
		Should be reimplemented by subclasses which are controlling objects
		of an aggregate or which use containment to implement their services. "!
standardIUnknownSelectors
        " Private - answer the selectors for the standard implementations
		of the IUnknown operations. "

    ^#( #QueryInterface:_: #AddRef  #Release )!  
innerRelease
        " Private - implement the non-delegating IUnknown::Release function.
        Decrement the reference count of the interface referenced by the receiver
        and destroy the reference to it.  Release any resources associated with the receiver.
        Answer the value of the reference count (for diagnostic use only; may not be stable). "

    ^self decrementReferenceCount
! 
AddRef
		" Private - perform the IUnknown::AddRef function.
		Delegate to the controlling unknown to allow reuse if the receiver
		is a contained object.  The controlling unknown is the receiver's
		own inner unknown if it is not aggregrated or is the controlling object. "

	^self isControllingObject
		ifTrue: [ self innerAddRef ]
		ifFalse: [ self controllingUnknown AddRef ]  " not an HRESULT, can't cause OLEError "! 
queryInterface: iid
        "Query the receiver for the interface specified by the GUID <iid>.
        Answer the interface if it is supported, else answer nil. "

    ^self controllingUnknown queryInterface: iid! 
classFactoryClass
		" Answer the class factory object class which would have created
		the receiver. "

	^self class classFactoryClass!   
isContainedObject
		" Answer whether the receiver is a contained object which
		delegates its IUnknown operations to a controlling object. "

	^self controllingUnknown ~~ self innerUnknown! 
unimplementedFunction
		" Private - default handler for an unimplemented interface function. "

	^E_NOTIMPL!   
initialize
        " Private - initialize the receiver. "

    referenceCount := 0.
    self initializeInterfaces.
    self controllingUnknown: self innerUnknown.
!
innerUnknown
        " Answer the non-delegating inner IUnknown of the receiver.
		If the receiver is contained within a controlling object, 
		this is different than  the controlling unknown of the outer object. "

    ^innerUnknown!   
clsid
		" Answer the CLSID of the OLE object class of the receiver. "

	^self class clsid! 
allocatedInterfaces
		" Private - answer the interfaces supported by the receiver
		which have been allocated during its lifetime. "

	| allocatedInterfaces |
	allocatedInterfaces := Set new.
	self allocatedInterfacesDo: [ :anInterface |
		allocatedInterfaces add: anInterface ].
	^allocatedInterfaces!
Release
		" Private - perform the IUnknown::Release function.
		Delegate to the controlling unknown to allow reuse if the receiver
		is a contained object.  The controlling unknown is the receiver's
		own inner unknown if it is not aggregrated or is the controlling object. "

	^self isControllingObject
		ifTrue: [ self innerRelease ]
		ifFalse: [ self controllingUnknown Release  ] " not an HRESULT, can't cause OLEError "! 
controllingUnknown
        " Answer the controlling IUnknown of the receiver.
        If the receiver is not a contained object, this will 
        be its inner IUnknown. "

    ^controllingUnknown!   
interfaceForIID: iid
		" Private - answer the interface supported by the receiver
		which is identified by the GUID <iid>.  Answer nil if the requested
		interface is not supported by the receiver. "

	^self interfaceForIID: iid ifNone: [ nil ]!
ifOLETraceEnabled: aBlock
        " Private - evaluate the trace logic in <aBlock> if OLE tracing
        is currently enabled for the receiver. "

    ( OLESessionManager traceEnabled
    and: [ OLESessionManager traceManager traceCallin ] )
        ifTrue: [ aBlock value ].
! 
controllingUnknown: anIUnknown
        " Private - set the controlling unknown of the receiver to <anIUnknown>.
        This is different from the local unknown when the receiver is part of an aggregation. "

    controllingUnknown := anIUnknown.!   
decrementReferenceCount
		" Private - decrement the receiver's reference count.
		This is the sum of the outstanding reference counts on all
		of its interfaces.  Release resources owned by the receiver
		if its reference count goes to 0. "

	referenceCount := referenceCount - 1.
    referenceCount = 0
        ifTrue: [ self releaseResources ].
    referenceCount < 0
        ifTrue: [
            OLEDevelopmentWarning signal:
                'Too many releases of ', self printString, ' (', referenceCount printString, ')' ].
    ^referenceCount!   
innerQueryInterface: iid _: resultReference
        " Private - implement the non-delegating IUnknown::QueryInterface function.
        Query the receiver for the interface identified by the Guid <iid>.
        If the requested interface is supported by the receiver, store
        a new reference counted copy of the interface into <resultReference>.
        Answer the result code. "

    | anInterfaceImplementation aSeparateReference |
    anInterfaceImplementation := self interfaceForIID: iid
        ifNone: [ ^E_NOINTERFACE ].
    aSeparateReference := anInterfaceImplementation separateReference.
	OLESessionManager forceCallout
		ifTrue: [ aSeparateReference coerceToPointer ].
    resultReference value: aSeparateReference.
    ^S_OK!   
byteStreamOn: anIStream
        "Answer a new instance of the receiver on <anIStream>
        which treats its contents as a byte stream."

    ^self new
        asByteStream;
        stream: anIStream;
        setLimits!  
characterStreamOn: anIStream
        "Answer a new instance of the receiver on <anIStream>
        which treats its contents as a character stream."

    ^self new
        asCharacterStream;
        stream: anIStream;
        setLimits!   
on: anIStream
        "Answer a new instance of the receiver on <anIStream>."

    ^self byteStreamOn: anIStream!  
asCharacterStream
        "Answer the receiver as a Stream which treats its contents as characters."

    self bufferClass: String.!   
next
        "Answer the next object accessible by the receiver
         and advance the stream position. "

    | elements |
    elements := self next: 1.
    ^elements isNil
        ifTrue: [ nil ]
        ifFalse: [ elements at: 1 ]!  
position
        "Answer the current receiver stream position."

    ^self stream position!
asByteStream
        "Answer the receiver as a Stream which treats its contents as bytes."

    self bufferClass: ByteArray.!  
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."

    ^self stream asParameter! 
setLimits
        "Private - Initialize the stream size and position."

    position := 0.
	self updateLimits.!   
updateLimits
		" Update the state information after the stream has been modified. "

	readLimit := self stream size.!  
stream
		" Answer the OLE stream element on which the receiver is operating. "

	^stream!  
putBytesFrom: aByteObject from: start to: stop
        "Write the contents of aByteObject to the receiver.
        aByteObject can be a ByteArray or a String.
        start and stop are byte indices into aByteObject. "

	| count buffer nBytesWritten |
	count := stop - start + 1.
	buffer := ( count = aByteObject basicSize
		ifTrue: [ aByteObject ]
		ifFalse: [ aByteObject class new replaceBytesFrom: 1 to: count with: aByteObject startingAt: start ] ).
	nBytesWritten := self stream
		write: buffer 
		count: count.
	nBytesWritten = count
		ifFalse: [ self error: 'write not completed' ].
	self updateLimits.!
getBytesFor: aByteObject from: start to: stop
        "Directly copy from the stream to <aByteObject>.
        <start> and <stop> are indices into <aByteObject>. "

	| count buffer nBytesRead |
	count := stop - start + 1.
	buffer := aByteObject class new: count.
    nBytesRead := self stream read: buffer count: count.
	nBytesRead ~= count
		ifTrue: [ self error: 'read beyond end of stream' ].
    aByteObject
        replaceBytesFrom: start
        to: stop
        with: buffer
        startingAt: 1.
	^aByteObject!
release
		" Release the OLE stream. "

	self stream isNil
		ifTrue: [ ^self ].
	self stream release.
	self stream: nil.
	position := readLimit := writeLimit := 0.
	! 
bufferClass: anIndexedByteClass
        " Private - specify the class to use for allocating a read buffer. "

    bufferClass := anIndexedByteClass.!  
copyFrom: firstIndex to: lastIndex
        "Answer the subcollection of the collection over
         which the receiver is streaming, from firstIndex
         to lastIndex."

    | initialPosition nBytes buffer nBytesRead |
    initialPosition := self position.
    self position: firstIndex - 1.
    nBytes := lastIndex - firstIndex + 1.
    buffer := self bufferClass new: nBytes.
    nBytesRead := self stream read: buffer count: nBytes.
    self position: initialPosition.
    nBytesRead = 0
        ifTrue: [ ^nil ].
    nBytesRead = nBytes
        ifTrue: [ ^buffer ].
    ^buffer copyFrom: 1 to: nBytesRead!
bufferClass
        " Private - answer the class to use for allocating a read buffer. "

    ^bufferClass! 
position: anInteger
        "Set the receiver stream position to <anInteger>. "

	self stream position: anInteger.!
nextPutAll: aCollection
        "Write each of the objects in <aCollection> to the
         receiver stream.  Answer <aCollection>."

	| nBytesWritten |
    aCollection class isBytes
		ifFalse: [ self error: 'collection must be bytes' ].
	nBytesWritten := self stream 
		write: aCollection
		count: aCollection basicSize.
	nBytesWritten ~= aCollection basicSize
		ifTrue: [ self error: 'write not completed' ].
	self updateLimits.
	^aCollection!
setToEnd
        "Set the position of the receiver stream to
         the end."

	self stream setToEnd.!  
stream: anOLEStream
		" Set the OLE stream element on which the receiver is operating
		to the OLE structure storage stream element <anOLEStream>. "

	stream := anOLEStream.!
commit
		" Commit any changes to the contents of the storage element 
		since it was last opened or committed to persistent storage. "

	self stream commit.! 
revert
        " Discard any changes made to the contents of the storage element
        since it was last opened or committed to persistent storage. "

    self stream revert.! 
next: anInteger
		" Answer the next <anInteger> bytes from the receiver. "

	| buffer nBytesRead |
	buffer := self bufferClass new: anInteger.
    nBytesRead := self stream read: buffer count: anInteger.
	nBytesRead = 0
		ifTrue: [ ^nil ].
	nBytesRead = anInteger
		ifTrue: [ ^buffer ].
	^buffer copyFrom: 1 to: nBytesRead! 
contents
        "Answer the contents of the OLE stream over which
         the receiver is streaming."

    | originalPosition contents |
    originalPosition := self position.
    self reset.
    contents := self next: self size.
    self position: originalPosition.
    ^contents!  
atEnd
        "Answer true if the receiver is
         positioned at the end (beyond
         the last object), else answer
         false."

	^self position = self size!  
skip: anInteger
        "Increment the position of the
         receiver by <anInteger>."

	self stream skip: anInteger.! 
flush
        "Force all data written to the receiver to be
         recorded on disk."

	self commit.
	!
nextPut: anObject
        "Write <anObject> to the receiver stream.
         Answer <anObject>."

	| buffer nBytesWritten |
	buffer := self bufferClass with: anObject.
	nBytesWritten := self stream write: buffer count: 1.
	nBytesWritten ~= 1
		ifTrue: [ self error: 'write not completed' ].
	self updateLimits.
	^anObject!  
reset
        "Position the receiver stream to the beginning."

	self stream reset.!   
invokeOleIsCurrentClipboard: pDataObj
        "Private - WWINOLEAPI  OleIsCurrentClipboard(LPDATAOBJECT pDataObj);"

    <api: OleIsCurrentClipboard handle hresult>
    ^self apiCallFailed! 
CreateStreamOnHGlobal: aGlobalAddress _: fDeleteOnRelease _: resultReference
		" Create an IStream whose data is stored inside the global memory
		handle <aGlobalAddress> and store it into the <resultReference>.
		The memory must be movable and nondiscardable.
		If <fDeleteOnRelease> is set, the memory is automatically
		freed when the stream is released.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IStreamPointer forReturnValue.
	hresult := self invokeCreateStreamOnHGlobal: aGlobalAddress asParameter
		_: fDeleteOnRelease 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!
asValueReference
		" Answer a value reference for obtaining an interface binding for the receiver. "

	^OLEInterfaceValueReference for: self!  
checkHresult: hresult
        " Private - signal an error if <hresult> is an error code. "

    ( HRESULT failed: hresult )
        ifTrue: [ OLEError hresult: hresult ].
    ^hresult! 
forReturnValue
		" Answer a new instance of the receiver which is to be used
		to obtain an OUT parameter return value.  The contents are uninitialized (NULL). "

	^self newNullValue!   
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^52!  
fromOleObject: anIOleObject srcOfCopy: anOffset drawAspect: drawAspect pointl: aPoint1 sizel: aPoint2
        "Answer an instance of the receiver."

    | classID userTypeName status |
    classID := anIOleObject getUserClassID.
    userTypeName := anIOleObject getUserFullClassName.
    status := anIOleObject getMiscStatus: drawAspect.
    ^self new
        cbSize: self sizeInBytes;
        clsID: classID;
        drawAspect: drawAspect;
        sizel: aPoint1;
        pointl: aPoint2;
        status: status;
        fullUserTypeName: 0;
        srcOfCopy: 0


!
dragDropGlobal: aBoolean
        "Enable/disable the receiver as an OLE drag source and target."

    self dragSource: aBoolean.
    self dragTarget: aBoolean.
    aBoolean ifTrue: [ self dragSessionClass: WinDragDropSession ]

!  
closeCurrent
		" Close the current instance of the DLL if it has been opened. "

	current notNil
		ifTrue: [
			current close.
			self current: nil ].! 
open: aString
        "Answer an instance of the receiver which refers
         to the Dynamic Link Library named <aString>.
		Validate and initialize the OLE library. "

    | dllHandle dllVersionNumbers |
   	dllHandle := super open: aString.
	dllVersionNumbers :=  ( self supportAllOLE
		ifTrue: [ dllHandle OleBuildVersion ]
		ifFalse: [ dllHandle CoBuildVersion ] ).
	( self isSupportedLibraryVersion: dllVersionNumbers )
		ifFalse: [ 
			dllHandle privateClose.
			self error: 'not a supported version of OLE' ].
	self supportAllOLE
		ifTrue: [ dllHandle OleInitialize: nil ]
		ifFalse: [ dllHandle CoInitialize: nil ].
	^dllHandle!   
invokeReadFmtUserTypeStg: pStg _: cf _: lpszUserType
		"Private - WINOLEAPI ReadFmtUserTypeStg (
                LPSTORAGE pstg, CLIPFORMAT FAR* pcf, LPOLESTR FAR* lplpszUserType); "

    <api: ReadFmtUserTypeStg handle structOut structOut hresult>
    ^self apiCallFailed!
invokeOleCreateFromFile: rclsid _: pszFileName _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreateFromFile(
            REFCLSID rclsid, LPCOLESTR lpszFileName, REFIID riid,
            DWORD renderopt, LPFORMATETC lpFormatEtc,
            LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID FAR* ppvObj);"

    <api: OleCreateFromFile structIn structIn structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed!
guidAtOffset: anInteger
        " Answer the 16-byte GUID at offset <anInteger> in the receiver. "

	| guidBytes |
	guidBytes := self bytesAtOffset: anInteger count: GUID sizeInBytes.
	guidBytes detect: [ :aByte | aByte ~= 0 ]
		ifNone: [ ^nil ].
    ^GUID fromBytes: guidBytes! 
iid: anIID
		" Private - set the the interface ID which uniquely identifies instances 
		of the receiver the GUID <anIID>. "

 	( iid notNil and: [ anIID notNil and: [ iid ~= anIID ] ] )
		ifTrue: [   " maybe initialization bug that developer should know about "
			OLEDevelopmentWarning signal: 'Changing the IID of ', self name,
				' from ', iid printString, ' to ', anIID printString, '.' ].
	iid := anIID.!   
installStandardDispatchHandlers
		" Configure the receiver's interface function dispatch bindings
		with the standard set of VTable function handlers which
		dispatch the functions to the implementing object. "

	self functionHandlers: ( self vtableDescription
		collect: [ :eptDescription |
			Message 
				receiver: self implementor
				selector: eptDescription selector ] ).
! 
CreateInstance: aControllingUnknown _: iid _: resultReference
        " Private - perform the IClassFactory::CreateInstance function.
        Answer the result code. "

	| anOleObject anInterface |

	" create a new object and obtain the requested interface "
	aControllingUnknown isNil
		ifTrue: [
			anOleObject := self objectClass new.
			anInterface := anOleObject queryInterface: iid.
			anInterface isNil
				ifTrue: [ ^E_NOINTERFACE ].
			]
		ifFalse: [   " create a non-control object for use within an aggregate "
			" insist that the control object ask for the local IUnknown of the non-control object "
			iid ~= IID_IUnknown
				ifTrue: [ ^E_NOINTERFACE ].
			anOleObject := self objectClass forControllingUnknown: aControllingUnknown.
			anOleObject isNil
				ifTrue: [ ^CLASS_E_NOAGGREGATION ].  " doesn't support aggregation "
			anInterface := anOleObject innerUnknown separateReference.
			].

	" record the new object in the active objects registry "
	self class registerObject: anOleObject 
		classFactory: self.
	"self ASSERT: anOleObject referenceCount = 1."
	resultReference value: anInterface.
	^S_OK!  
invokeMonikerRelativePathTo: pmkSrc _: pmkDest _: ppmkRelPath _: dwReserved
        "Private - WINOLEAPI  MonikerRelativePathTo(
                LPMONIKER pmkSrc, LPMONIKER pmkDest, 
                LPMONIKER FAR* ppmkRelPath, BOOL dwReserved); "

    <api: MonikerRelativePathTo handle handle structOut boolean hresult>
    ^self apiCallFailed!   
interfaceEqual: anInterface
		" Private - answer whether receiver and <anInterface> are the same interface. 
		The IID's are assumed to be equal. "

	"self ASSERT: anInterface isOLEInterfaceReference not."

	" compare carefully to avoid unnecessary external resource allocation by an impl "
	^anInterface isOLEInterfacePointer
		ifTrue: [
			self hasExternalResources 
			and: [ self asInterfacePointer interfaceEqual: anInterface ] ]
		ifFalse: [   " there is only one impl binding per object per IID "
			self  == anInterface ]!
forBinding: anInterfaceBinding
		" Answer a new instance of the receiver with callin/callout binding <anInterfaceBinding>. "

	| anIID aClass |
	anIID := anInterfaceBinding iid.
	aClass := self elementTypeOfIID: anIID.
	aClass isNil  " element type not registered "
		ifTrue: [ self error: 'unsupported enumeration interface' ].
	^self forIID: anIID 
		binding: anInterfaceBinding
		elementClass: aClass!
for: anInterface
		" Answer a new instance of the receiver which will be used
		to obtain the interface binding for the interface reference <anInterface>. "

	^self new 
		interfaceReference: anInterface; 
		yourself!   
forReturnValueWithIID: anIID
        " Answer a new instance of the receiver which will be used obtain an instance
        of the OLE interface identified by the GUID <anIID> as an OUT parameter value. "

    ^self for: ( ( OLEInterface classForIID: anIID ifNone: [ IAnonymous ] ) new
        iid: anIID;
        yourself )!
on: anObject
		"Answer a new instance of the receiver whose value is <anObject>."

    ^self new value: anObject!  
forReturnValue
		" Answer a new instance of the receiver which is to be used
		to obtain an OUT parameter return value.  Since in general the
		ownership responsibility of an OUT parameter is transferred
		to the caller, mark the interface as needing finalization
		to ensure that it is released by the caller. "

	^self new!  
registerIID
        " Private - register the receiver as the interface class for its IID.
		Do nothing for the receiver - its superclass IStorage is correctly
		registered as the class for the (shared) IID. "!  
on: aVariableByteObject
		" Answer a new instance of the receiver which is an IStorage 
		on a newly allocated block of global memory whose contents
		are initialized with the data in <aVariableByteObject>.
		The memory will be released when the stream is released. "

	| nBytes aGlobalMemoryAddress anIStorage |
	aVariableByteObject isByteArray
		ifFalse: [   " strings not yet supported (trailing null philosophy not yet specified) "
			self error: 'must be ByteArray' ].
	nBytes := aVariableByteObject size.
	aGlobalMemoryAddress := ExternalGlobalAddress allocateMemory: nBytes
		flags: GmemShare | GmemMoveable | GmemDiscardable. 
	aGlobalMemoryAddress replace: nBytes 
		with: aVariableByteObject.
	anIStorage := self openOnAddress: aGlobalMemoryAddress deleteOnRelease: true.
	"self ASSERT: anIStorage lockBytes isStorageBytes."
	"self ASSERT: anIStorage lockBytes size = nBytes."
	^anIStorage!
removeIID
        " Private - remove the registration of the receiver as the interface class for its IID.
		Do nothing for the receiver - its superclass IStorage manages the registration
		for the (shared) IID. "!  
createTemporaryStorage
		" Create a temporary structured storage in global memory
		Answer a new instance of the receiver on the storage object.
		The memory will be released when the stream is released. "

	^self createOnAddress: nil deleteOnRelease: true!
openOnAddress: aGlobalMemoryAddress deleteOnRelease: deleteOnRelease
		" Answer a new instance of the receiver which is an IStorage 
		on <aGlobalMemoryAddress>.  If <deleteOnRelease> is set
		the memory will be released by OLE when the stream is released. "

	| anILockBytes resultReference |
	anILockBytes := ILockBytes createOnAddress: aGlobalMemoryAddress 
		deleteOnRelease: deleteOnRelease.
	resultReference := self new asValueReference.
	OLEDLL current StgOpenStorageOnILockBytes: anILockBytes
		_: nil 
		_: STGM_TRANSACTED | STGM_READWRITE | STGM_SHARE_DENY_WRITE 
		_: nil 
		_: 0 
		_: resultReference.
	resultReference value lockBytes: anILockBytes.
	^resultReference value!
createOnAddress: aGlobalMemoryAddress deleteOnRelease: deleteOnRelease
		" Answer a new instance of the receiver which is an IStorage 
		on <aGlobalMemoryAddress>.  If <deleteOnRelease> is set
		the memory will be released by OLE when the stream is released. "

	| anILockBytes resultReference |
	[
	anILockBytes := ILockBytes createOnAddress: aGlobalMemoryAddress 
		deleteOnRelease: deleteOnRelease.
	resultReference := self new asValueReference.
	OLEDLL current StgCreateDocfileOnILockBytes: anILockBytes
		_: STGM_CREATE
				| STGM_READWRITE | STGM_SHARE_EXCLUSIVE
		_: 0 
		_: resultReference.
	]
		on: OLEError
		do: [ :ex |
			anILockBytes notNil
				ifTrue: [ anILockBytes release ].
			ex pass ].
	resultReference value lockBytes: anILockBytes.
	^resultReference value!  
accessModeReadOnly
		" Answer the access mode flags for readOnly access. "

	^STGM_READ | STGM_SHARE_EXCLUSIVE!
accessModeReadWrite
		" Answer the access mode flags for read/write access. "

	^STGM_READWRITE | STGM_SHARE_EXCLUSIVE!
removeIID: anIID
        " Private - remove the interface class registration of
        the interface whose IID is the interface ID GUID <anIID>. "

	OLEInterfacePointer removeInterfaceReferenceClassForIID: anIID.!
aboutToSaveImage
		" Private - the image is about to be saved.  Nuke dangerous stuff. "

	| containerWindows |

	" force garbage collect to ensure finalization invoked "
	self ISSUE.  " Shouldn't have to do this here - verify that
		the base does this suitably and remove.  [DL 14-Aug-95] " 
	Smalltalk unusedMemory.

	containerWindows := self containerWindows.
	containerWindows notEmpty
		ifTrue: [  " image restart is unable to support reconnecting container applications "
			( MessageBox confirm: 
				'Cannot proceed with image save unless the open OLE container windows are forcibly closed (they cannot be reconnected properly at image restart).  Do you want them closed in order to attempt to proceed with image save?' )
				ifFalse: [ 
					Terminal bell.
					^SessionModel current abortSaveImage ].
			containerWindows do: [ :w | w close ].
			self containerWindows notEmpty
				ifTrue: [ 
					MessageBox
						notify: 'Image Save Aborted'
						withText: 'Unable to close all the open OLE container windows - cannot proceed with image save in this state.'.
					^SessionModel current abortSaveImage ].
			].

	OLEClassFactoryObject isInUse
		ifTrue: [  " rather draconian policy here, but safe "
			MessageBox
				notify: 'Image Save Aborted'
				withText: 'Cannot save image while session is supporting other applications as an OLE object server.  Active objects must be released and the class factories revoked before image save can proceed.'.
			^SessionModel current abortSaveImage ].

	self sessionOwnsResources
		ifTrue: [
			( MessageBox confirm: 'OLE interfaces and memory are still owned by this session.  They will be released at image exit and cannot be restored when this saved image is restarted.  Do you want to proceed with saving the image anyway?' )
				ifFalse: [ ^SessionModel current abortSaveImage ].
			].

	self sessionExportsResources
		ifTrue: [
			( MessageBox confirm: 'OLE interfaces are still exported by this session and may still be in use by other applications.  They will be released at image exit and cannot be restored when this saved image is restarted.  Do you want to proceed with saving the image anyway?' )
				ifFalse: [ ^SessionModel current abortSaveImage ].
			].
!   
finalizationRegistry
		"Private - Answer the WeakRegistry to be used for finalizing instances of the receiver."

    ^OLESessionManager ownedMemoryRegistry!   
elementClass: aClass
		" Private - specify the class of the elements
		on which the receiver operates. "

	elementClass := aClass.
	self elementSize: ( ( aClass isKindOf: OLEInterface class )
		ifTrue: [ aClass interfacePointerClass ]
		ifFalse: [ aClass ] )  " host data structure "
			sizeInBytes.
	"self ASSERT: self iid notNil."!
Release
		" Invoke the IUnknown::Release function. "

	| remainingReferenceCount |
    self ifOLETraceEnabled: [ self logFunctionEntry ].
	remainingReferenceCount := ( self isValid
		ifTrue: [ self invokeRelease ]
		ifFalse: [ 0 ] ).
	super release.
    self ifOLETraceEnabled: [
        self logReturnValue: 'Ref count: ', remainingReferenceCount printString ].
	^remainingReferenceCount
!
invokeOleGetClipboard: ppDataObj
        "Private - WINOLEAPI  OleGetClipboard(LPDATAOBJECT FAR* ppDataObj);"

	| hresult |
    <api: OleGetClipboard structOut hresult>
	hresult := self apiFailureReason.
	hresult = CLIPBRD_E_BAD_DATA
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!
asByteArray
        "Answer a ByteArray whose contents are the
         bytes of the receiver."

    ^( ByteArray new: self size )
		replace: self size with: self;
		yourself! 
bindDevelopmentLibrary: devLibraryName for: runtimeLibraryDescription
		" Bind the development environment support library <devLibraryName>
		which is associated with the runtime library <runtimeLibraryDescription>. "

    SessionModel current isRunTime
        ifTrue: [ ^self ].  " do nothing in runtime execution environment "
	[ SmalltalkLibraryBinder bindTo: devLibraryName ]
		on: BindError, FileError
		do: [ 
			MessageBox
				notify: 'Installation Configuration Problem'
				withText: 
					'Unable to bind library ', devLibraryName, 
					' (development support for ', runtimeLibraryDescription, ').'.
			^self ].

!
shortResultAtAddress: anExternalAddress put: anInteger
		" Private - store the output argument value <anInteger> 
		into the caller-provided memory location addressed at <anExternalAddress>. "

	anInteger isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress ) 
		shortAtOffset: 0 
		put: anInteger.! 
QueryGetData: aFormatEtc
		" Private - implement the IDataObject::QueryGetData function.
		Determine whether a call to IDataObject::GetData would succeed
		if it were passed <aFormatEtc> as the requested data format.
		Answer the result code. "

	^( self renderingForFormat: aFormatEtc ) isNil
		ifTrue: [ DATA_E_FORMATETC ]
		ifFalse: [ S_OK ]! 
DAdvise: aFormatEtc _: advf _: anAdviseSink _: resultReference
		" Private - implement the IDataObject::DAdvise function.
		Create a connection between the data transfer object and an
         advisory sink through which the sink can be informed when the
         object's data changes.
		Answer the result code. "

	^OLE_E_ADVISENOTSUPPORTED!
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	iDataObject notNil
		ifTrue: [ aOneArgBlock value: iDataObject ].!   
releaseResources
        " Private - release resources associated with the receiver. "

    formats do: [ :aRendering | aRendering release ].
    super releaseResources.!
getInterfaceForIID: iid
        " Private - answer the interface identified by the Guid <iid>.
        Answer nil if the requested interface is not supported by the receiver. "

    iid = IID_IDataObject
        ifTrue: [ ^iDataObject ].
    ^nil! 
initializeInterfaces
        " Private - Allocate any interfaces which are expected to be required
        during the object's lifetime. "

    super initializeInterfaces.
    iDataObject := self constructIDataObject.!   
createFormatEtcs
        "Private - create a collection of FORMATETCs from the supported formats."

    ^formats collect: [ :rendering | rendering formatEtc deepCopy ]!   
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iDataObject := nil.!
copyToClipboard
        " Copy the receiver to the system clipboard. "

    | anIDataObject |
    anIDataObject := self queryInterface: IID_IDataObject.
    anIDataObject copyToClipboard.
    anIDataObject release.
!   
setObject: anObject format: formatString
        "Set data on anObject. formatString specify the clipboard format
         for the object."

	| aFormatEtc aRendering |
	aFormatEtc := ( OLEStructure classForStructureNamed: #FORMATETC )
        formatNamed: formatString.
	aRendering := OLERendering formatEtc: aFormatEtc object: anObject.
	formats add: aRendering.

 ! 
EnumFormatEtc: dwDirection _: resultReference
        " Private - implement the IDataObject::EnumFormatEtc function.
        Create an enumerator to enumerate the formats supported by the receiver.
        Answer the result code. "

    | anEnumerator |

    dwDirection = DATADIR_SET
        ifTrue: [ ^E_NOTIMPL ].

    anEnumerator := OLEEnumeratorObject on: self createFormatEtcs.
    resultReference value:
        ( anEnumerator queryInterface: anEnumerator enumeratorIID ).
    ^S_OK!  
renderingForFormat: aFormatEtc
		" Private - answer the rendering corresponding to <aFormatEtc>.
		Answer nil if the format is not supported. "

	formats do: [ :aRendering |
		( aRendering sameFormatEtc: aFormatEtc ) 
			ifTrue: [ ^aRendering ] ].
	^nil! 
initialize
        "Private - initialize the receiver."

    super initialize.
    formats := OrderedCollection new.! 
constructIDataObject
        " Private - Answer a newly created IDataObject interface for the receiver. "

    | anIDataObject |
    anIDataObject := IDataObject on: self.
    anIDataObject interfaceBinding
        installMinimumDispatchHandlers;
        when: #GetData
            send: #GetData:_: to: self;
        when: #GetDataHere
            send: #GetDataHere:_: to: self;
        when: #QueryGetData
            send: #QueryGetData: to: self;
        when: #EnumFormatEtc
            send: #EnumFormatEtc:_: to: self;
        when: #DAdvise
            send: #DAdvise:_:_:_: to: self;
        yourself.
    ^anIDataObject! 
GetDataHere: aFormatEtc _: aStgMedium
        " Private - implement the IDataObject::GetDataHere function.
        Retrieve data in specified format using a specified storage medium.
        The caller provides the storage medium <aStgMedium>.
        Answer the result code. "

    | aRendering |
    aFormatEtc tymed = TYMED_ISTORAGE
        ifFalse: [ ^DATA_E_FORMATETC ].
    aRendering := self renderingForFormat: aFormatEtc.
    aRendering isNil ifTrue: [ ^DATA_E_FORMATETC ].
    " store the data into the caller's storage medium "
     aRendering renderObject: aStgMedium.
    ^S_OK
!
GetData: aFormatEtc _: resultReference
        " Private - implement the IDataObject::GetData function.
        Retrieve data in specified format using a specified storage medium.
        The data object allocates the storage medium and stores it into <resultReference>.
        The caller is responsible for releasing the storage.
        Answer the result code. "

    | aRendering stgMedium |
    aRendering := self renderingForFormat: aFormatEtc.
    aRendering isNil ifTrue: [ ^DATA_E_FORMATETC ].
    stgMedium := OLEStructure createStructureNamed: #STGMEDIUM.
    aRendering renderObject: stgMedium.
    resultReference value: stgMedium.
    ^S_OK
!
asIIDString
		" Answer the string representation of the receiver IID. "

    | resultReference |
	resultReference := nil asValueReference.
	OLEDLL current StringFromIID: self _: resultReference.
	^resultReference value! 
isValid
        "Answer whether the receiver has a valid (non-NULL) interface. "

	^interface notNil and: [ interface isValid ]!   
isOLEStructure
	"Answer <true> if the receiver supports the OLEStructure protocol."

	^true!   
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^self class iid!   
supportAllOLE: aBoolean
		" Private - specify whether all OLE services are supported.
		Set to false if only basic COM services are supported. "

    ( current notNil and: [ aBoolean ~= supportAllOLE ] )
		ifTrue: [ self error: 'cannot change while DLL open' ].
	supportAllOLE := aBoolean.!  
allocateMemory: sizeInBytes
        "Allocate a block of <sizeInBytes> bytes using the OLE task allocator.
         Answer an ExternalOLEAddress for the allocated memory."

	^self memoryAllocator allocate: sizeInBytes addressType: self!  
structureAtAddress: anExternalAddress type: aStructureSpecification
		" Private - answer the structure argument value at <anExternalAddress>. "

	anExternalAddress isValid
		ifFalse: [ ^nil ].
	^aStructureSpecification isClass
		ifTrue: [ aStructureSpecification atAddress: anExternalAddress ]
		ifFalse: [ OLEStructure createStructureNamed: aStructureSpecification atAddress: anExternalAddress ]!  
reallocateMemory: newSizeInBytes
        "Reallocate the receiver to be of size <newSizeInBytes>.  
		Copy the contents as necessary.  Free any memory no longer used.  
		Note that this may cause the block of memory to be allocated in a 
		new location."

    self memoryAllocator 
		reallocate: self 
		newSize: newSizeInBytes.
	^self! 
longResultAtAddress: anExternalAddress put: anInteger
		" Private - store the LONG output argument value <anInteger> 
		into the caller-provided memory location addressed at <anExternalAddress>. "

	anInteger isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress ) 
		longAtOffset: 0 
		put: anInteger.!  
resetMemoryAllocators
		" Private - reset the remembered references to the OLE memory allocators. "

	self
		resetTaskMemoryAllocator;
		resetSharedMemoryAllocator.!
releaseMemoryAllocators
		" Release the remembered references to the OLE memory allocators. "

	self
		releaseTaskMemoryAllocator;
		releaseSharedMemoryAllocator.!  
getSharedMemoryAllocator
		" Private - obtain an IMalloc interface on the OLE shared-memory allocator. "

	| resultReference anIMalloc |
	resultReference := self new asValueReference.
	OLEDLL current CoGetMalloc: MEMCTX_SHARED 
		_: resultReference.
	anIMalloc := resultReference value.
	anIMalloc notNil
		ifTrue: [ 
			OLESessionManager registerSpecialSessionResource: anIMalloc 
				description: 'OLE shared memory allocator'.
			].
	self sharedMemoryAllocator: anIMalloc.! 
getTaskMemoryAllocator
		" Private - obtain an IMalloc interface on the OLE task memory allocator. "

	| resultReference anIMalloc |
	resultReference := self new asValueReference.
	OLEDLL current CoGetMalloc: MEMCTX_TASK 
		_: resultReference.
	anIMalloc := resultReference value.
	anIMalloc notNil
		ifTrue: [ 
			OLESessionManager registerSpecialSessionResource: anIMalloc 
				description: 'OLE task memory allocator'.
			].
	self taskMemoryAllocator: anIMalloc.!   
resetTaskMemoryAllocator
		" Private - reset the remembered reference to the OLE task memory allocator. "

	taskMemoryAllocator notNil
		ifTrue: [
			taskMemoryAllocator invalidate.  " don't want to release/finalize any more "
			self taskMemoryAllocator: nil ].! 
releaseSharedMemoryAllocator
		" Release the remembered reference to the OLE shared memory allocator. "

	sharedMemoryAllocator notNil
		ifTrue: [
			OLESessionManager removeSpecialSessionResource: sharedMemoryAllocator.
			sharedMemoryAllocator release.
			self sharedMemoryAllocator: nil ].!  
taskMemoryAllocator: anIMalloc
        "Private - set the reference to the OLE task memory allocator."

    taskMemoryAllocator := anIMalloc.! 
taskMemoryAllocator
		" Answer the IMalloc interface of the OLE task memory allocator. "

	taskMemoryAllocator isNil
		ifTrue: [ self getTaskMemoryAllocator ].
	^taskMemoryAllocator!   
releaseTaskMemoryAllocator
		" Release the remembered reference to the OLE task memory allocator. "

	taskMemoryAllocator notNil
		ifTrue: [
			OLESessionManager removeSpecialSessionResource: taskMemoryAllocator.
			taskMemoryAllocator release.
			self taskMemoryAllocator: nil ].!  
sharedMemoryAllocator
        " Answer the IMalloc interface of the OLE-provided shared memory allocator. 
		Answer nil if the shared memory allocator is not supported by this version of OLE. "

    sharedMemoryAllocator isNil
        ifTrue: [ self getSharedMemoryAllocator ].
    ^sharedMemoryAllocator!   
resetSharedMemoryAllocator
		" Private - reset the remembered reference to the OLE shared memory allocator. "

	sharedMemoryAllocator notNil
		ifTrue: [
			sharedMemoryAllocator invalidate.  " don't want to release/finalize any more "
			self sharedMemoryAllocator: nil ].!   
sharedMemoryAllocator: anIMalloc
        "Private - set the reference to the OLE shared memory allocator."

    sharedMemoryAllocator := anIMalloc.!   
invokeOleRegEnumVerbs: clsid _: ppenum
        "Private - WINOLEAPI OleRegEnumVerbs (
                                REFCLSID clsid, LPENUMOLEVERB FAR* ppenum); "

	| hresult |
	<api: OleRegEnumVerbs structIn structOut hresult>
	hresult := self apiFailureReason.
	( hresult = REGDB_E_CLASSNOTREG 
	or: [ hresult = REGDB_E_KEYMISSING
	or: [ hresult = OLEOBJ_E_NOVERBS ] ] )
		ifTrue: [ ^hresult ].
    ^self apiCallFailed! 
OleRegEnumFormatEtc: clsid _: dwDirection _: resultReference
		" Obtain an enumerator of the supported data formats defined in
		the registration database for the CLSID <clsid>
		and store it into the <resultReference>.
		The set of formats to be enumerated is specified by the DATADIR value <dwDirection>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumFORMATETC.
	hresult := self invokeOleRegEnumFormatEtc: clsid
		_: dwDirection
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult! 
load: aStream
		" Initialize an object previously stored with the Save operation
		from the stream <aStream>.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Load: aStream!
usesStream
		" Answer whether the receiver operates on an IStream. "

	^true!  
maximumSize
		" Answer the maximum size of the stream needed to save the object. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetSizeMax: resultReference.
	^resultReference value! 
saveAndLeaveDirty: aStream
		" Save a copy of the object to the stream <aStream>.  Do not clear its dirty flag. "

	interface Save: aStream _: false.! 
save: aStream
		" Save a copy of the object to the stream <aStream> and clear its dirty flag. "

	interface Save: aStream _: true.!
isDirty
		" Answer whether the object has been changed since it was last saved. "

	^( interface IsDirty ) = S_OK! 
saveToStream: anIStream
        " Save the the receiver to the stream object <anIStream>. 
        The CLSID and the object's persistent state are stored. "

	OLEDLL current OleSaveToStream: self _: anIStream.!
usesStream
		" Answer whether the receiver operates on an IStream. "

	^false! 
usesStorage
		" Answer whether the receiver operates on an IStorage. "

	^false!   
getClassID
		" Answer the CLSID of the document object. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetClassID: resultReference.
	^resultReference value!  
installMinimumDispatchHandlers
		" Configure the receiver's interface function dispatch bindings
		to dispatch the IUnknown functions to the implementing object
		and provide unimplemented-function semantics for all other operations. "

	| unknownSelectors unknownHandlers unimplementedHandlers |
	unknownSelectors := self standardIUnknownSelectors.
	unknownHandlers := unknownSelectors collect: [ :aSelector |
		Message 
			receiver: self implementor 
			selector: aSelector ].
	unimplementedHandlers := ( ( Array new: self vtableSize - unknownSelectors size )
		atAllPut: self unimplementedFunctionDispatchHandler ).
	self functionHandlers: unknownHandlers, unimplementedHandlers.

!  
finalize
		" Private - The receiver is no longer referenced by any object 
		in the system and is about to be destroyed.  Release any resources. "

	self hasExternalResources 
		ifTrue: [ OLEDevelopmentWarning signal: 'OLE interface released by finalization: ', self printString ]
		"ifFalse: [ OLEDevelopmentWarning signal: 'Unnecessary finalization on OLE interface: ', self printString ]".
	self releaseResources.!  
forIID: anIID
		"Answer a new instance of the receiver which enumerates
		the homogeneous collection of interfaces or data structures 
		specified by <anIID>. "

	| elementClass |
	elementClass := IEnum elementTypeOfIID: anIID.
	elementClass isNil
		ifTrue: [ self error: 'unknown enumerator interface' ].
	^self forIID: anIID 
		elementClass: elementClass 
		elements: #( )!
forIID: anIID elementClass: aClass elements: anOrderedCollection
		"Answer a new instance of the receiver which enumerates
		the homogeneous collection <anOrderedCollection> of elements
		which are interfaces or data structures of type <aClass>.
		The enumerator interface IID is specified by <anIID>. "

	^self new
		enumeratorIID: anIID;
		elementClass: aClass;
		elements: anOrderedCollection;
		yourself!
on: anOrderedCollection
		"Answer a new instance of the receiver which enumerates
		the homogeneous collection of interfaces or data structures 
		in <anOrderedCollection>. "

	| elementClass anIID |
	elementClass := anOrderedCollection first class.
	anIID := IEnum enumeratorIIDFor: elementClass.
	anIID isNil
		ifTrue: [ self error: 'unknown enumerator interface' ].
	^self forIID: anIID 
		elementClass: elementClass 
		elements: anOrderedCollection! 
initializePosition
		" Private - set the enumerator's position to the start of the collection. "

	self position: 1.!  
position
		" Private - answer the current position of the receiver in its element collection. "

	^currentIndex!   
createIEnum
		" Private - create an IEnum interface on the receiver. "

	| anIEnum |
	anIEnum := IEnum on: self.
	anIEnum 
		iid: self enumeratorIID;
		elementClass: self elementClass.
	^anIEnum!   
allocatedInterfacesDo: aOneArgBlock
        " Private - enumerate the interfaces supported by the receiver
        which have been allocated during its lifetime and
        evaluate <aOneArgBlock> with each. "

    super allocatedInterfacesDo: aOneArgBlock.
    iEnum notNil
        ifTrue: [ aOneArgBlock value: iEnum ].! 
getInterfaceForIID: iid
        " Private - answer the interface identified by the GUID <iid>.
        Answer nil if the requested interface is not supported by the receiver. "

    iid = self enumeratorIID
        ifTrue: [ ^self enumeratorInterface ].
    ^nil! 
elementClass
		" Private - answer the class of the elements
		on which the receiver operates. "

	^elementClass!  
Clone: resultReference
		" Private - implement the IEnum::Clone function.
		Create another enumerator that contains the same enumeration state
         as the current one.
		Answer the result code. "

    | anEnumerator |
    anEnumerator := self class on: self elementClass.
	anEnumerator 
		elements: self elements;
		position: self position.
    "self ASSERT: anEnumerator enumeratorIID = self enumeratorIID."
    resultReference value: 
		( anEnumerator queryInterface: self enumeratorIID ).
    ^S_OK!  
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iEnum := nil.!  
elementClass: aClass
		" Private - specify the class of the elements
		on which the receiver operates. "

	"self ASSERT: ( self enumeratorIID = ( IEnum enumeratorIIDFor: aClass ) )."
	elementClass := aClass.! 
Next: elementCount _: elementBuffer _: countReference
        " Private - implement the IEnum::Next function.
        Retrieve the next <elementCount items> in the enumeration sequence.
         Store the retrieved elements into the <elementBuffer> array.
        Store the number of elements actually retrieved into <countReference>.
        Note the <countReference> can be nil if <elementCount> is 1.
        Answer the result code. "

    | nElementsRequested nElementsReturned offset 
	  anElement elementBytes  |

    elementBuffer isNil
        ifTrue: [ ^E_UNEXPECTED ].
    currentIndex > elements size
        ifTrue: [
            countReference notNil
                ifTrue: [ countReference value: 0 ].
            ^S_FALSE ].

    nElementsRequested := elementCount.
    offset := nElementsReturned := 0.
    [ ( currentIndex <= elements size ) 
	and: [ nElementsRequested > 0 ] ] 
		whileTrue: [
			anElement := self getElementAt: currentIndex.
			anElement isNil
				ifTrue: [ ^self hresultValueFailed ].
			elementBytes := anElement contents.
			elementBuffer bytesAtOffset: offset 
				put: elementBytes.
			offset := offset + elementBytes size.
			currentIndex := currentIndex + 1.
			nElementsReturned := nElementsReturned + 1.
			nElementsRequested := nElementsRequested - 1 ].
    countReference notNil
        ifTrue: [ countReference value: nElementsReturned ].
    ^nElementsReturned = elementCount
        ifTrue: [ S_OK ]
        ifFalse: [ S_FALSE ]! 
Skip: elementCount
		" Private - implement the IEnum::Reset function.
		Skip over the next specified number of elements in the enumeration sequence.
		Answer the result code. "

    currentIndex := currentIndex + elementCount.
    ^currentIndex > elements size
		ifTrue: [ S_FALSE ]  " skipped fewer than <elementCount> "
		ifFalse: [ S_OK ]!
elements: aCollection
        " Set the collection of elements being enumerated to <aCollection>. "

    elements := aCollection.
    self initializePosition.!   
elements
        " Answer the collection of elements being enumerated. "

    ^elements!   
Reset
        " Private - implement the IEnum::Reset function.
        Reset the enumeration sequence to the beginning.
        Answer the result code. "

    self initializePosition.
    ^S_OK!  
position: anInteger
		" Private - set the current position of the receiver in its element collection to <anInteger>. "

	currentIndex := anInteger.!   
enumeratorIID
		" Answer the IID of the enumerator interface for the receiver's element class. "

	^enumeratorIID! 
enumeratorIID: iid
		" Private - set the IID of the enumerator interface for the receiver's element class. "

	enumeratorIID := iid.!  
getElementAt: index
		" Private - answer the element at <index> in the receiver's collection. "

	^self elements at: index!
hresultValueFailed
		" Private - answer the result code to return when
		the IEnum::Next operation is unable for some reason
		to obtain the next value in the collection. "

	^E_UNEXPECTED!
enumeratorInterface
		" Answer the enumeration interface supported by the receiver.
		Note that this is not a separately reference counted copy of the interface. "

	iEnum isNil
		ifTrue: [ iEnum := self createIEnum ].
	^iEnum! 
asUnicode
        "Answer a Unicode copy of the receiver"

	^UnicodeStringBuffer fromString: self! 
getHash
		" Answer the hash of this moniker. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Hash: resultReference.
	^resultReference value!   
CreatePointerMoniker: anIUnknown _: resultReference
		" Create a pointer moniker from the interface <anIUnknown>.
		Obtain a new IMoniker interface and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeCreatePointerMoniker: anIUnknown asParameter
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
!  
constructClassFactoryRegistry
		" Private - construct the class factory registry. "

	^Set new!
resetResources
		" Private - reset all OLE interfaces and memory addresses owned or allocated by this session. "

	self allResourceRegistries do: [ :aRegistry |
		( self elementsInRegistry: aRegistry ) do: [:object | object startingSession ] ].
	self sessionHasResources
		ifTrue: [ OLEDevelopmentWarning signal: 'OLE resource registries were not emptied by reset logic.' ].

	OLEExternalVTable invalidateExternalVTable.! 
dragDropGlobal
        "Enable the receiver as an OLE drag source and target."

    self dragSource.
    self dragTarget.
    self dragSessionClass: WinDragDropSession
!   
OleRun: anIUnknown
        " Place the object <anIUnknown> into running state if it is not already running.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeOleRun: anIUnknown asParameter!
CoRegisterClassObject: clsid _: anIUnknown _: clsContext _: flags _: resultReference
		" Register the class object <anIUnknown> of an EXE object server application
		for the class whose CLSID is the GUID <clsid>.  
		The CLSCTX value <clsContext> specifies the context in which
		the executable code is to be run.  The REGCLS value <flags> 
		controls how connections are made to the class object.
		Store the class registration token into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeCoRegisterClassObject: clsid
		_: anIUnknown asParameter
		_: clsContext 
		_: flags 
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!  
hash
        "Answer the integer hash
         value for the receiver."
    <primitive: 107>!  
OleInitialize: anIMalloc
		"Initialize the OLE implementation library using the memory allocator <anIMalloc>.
		If no memory allocator is specified, the default OLE task allocator is used.
		This function is unnecessary if the CoInitialize function is used.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeOleInitialize: anIMalloc asParameter!   
forIID: anIID
		" Answer a new instance of the receiver for the interface specified by <anIID>. "

	^self new
		iid: anIID;
		yourself!  
supportsIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^false!  
interfacePointerClass
		" Private - answer the interface pointer class which is referenced
		by instances of the receiver. "

	^IAnonymousPointer!
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

	iid := anIID.
	interface iid: anIID.!  
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^iid!  
invokeCreateDataAdviseHolder: ppDAHolder
		"Private - WINOLEAPI CreateDataAdviseHolder(
			LPDATAADVISEHOLDER FAR* ppDAHolder);"

    <api: CreateDataAdviseHolder structOut hresult>
    ^self apiCallFailed!   
activeObjectsRegistry
		" Private - answer the registry of objects which have been created
		during the current session. "

	ActiveObjectsRegistry isNil
		ifTrue: [ ActiveObjectsRegistry := self constructActiveObjectsRegistry ].
	^ActiveObjectsRegistry!   
CoHasStrongExternalConnections: anIUnknown
		"Answer whether the object <anIUnknown> has strong external connections. "

	^self invokeCoHasStrongExternalConnections: anIUnknown asParameter
!
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."

	aStream
		nextPutAll: '( ';
		nextPutAll: self class name;
		nextPutAll: ' fromBytes: '.
	self hexByteStringOn: aStream.
	aStream nextPutAll: ' )'.!   
sizeOfStructureNamed: structureName
		" Answer the size in bytes of the host structure named <structureName>. "

	^( self classForStructureNamed: structureName ) sizeInBytes! 
invokeGetHGlobalFromILockBytes: plkbyt _: phglobal
		"Private - WINOLEAPI GetHGlobalFromILockBytes (
			LPLOCKBYTES plkbyt, HGLOBAL FAR* phglobal);"

    <api: GetHGlobalFromILockBytes handle structOut hresult>
    ^self apiCallFailed!  
initialInterfaceAllocationSize
		" Private - answer the initial size of the interface storage dictionary.
		The value should be the number of interfaces expected to
		be supported by an instance of the receiver during its lifetime.
		May be reimplemented by subclasses to optimize instance size. "

	^3! 
interfaceReferenceClass
		" Private - answer the OLE interface reference class for the receiver. "

	^IAnonymous!  
forIID: anIID
		" Answer a new instance of the receiver for the interface specified by <anIID>. "

	^self new
		iid: anIID;
		yourself!  
supportsIID: aGUID
		" Answer whether the receiver represents the interface identified
		by the IID <aGUID>. "

	^false!  
forReturnValue
		" Answer a new instance of the receiver which is to be used
		to obtain an OUT parameter return value.  Since in general the
		ownership responsibility of an OUT parameter is transferred
		to the caller, mark the address as needing finalization
		to ensure that it is released by the caller. "

	^self new needsFinalization!  
new
		" Answer a new instance of the receiver. "

    ^super new initialize!   
hresult: anInteger
        "Signal a newly created instance of the receiver with the result code set to <anInteger>."

    ^( self new hresult: anInteger ) signal!
createStructureNamed: structureName
		" Answer a new data structure instance for the host structure named <structureName>.
		The structure is allocated in Smalltalk memory. "

	^( self classForStructureNamed: structureName ) new! 
lockCount: anInteger
		" Private - set the number of locks on the object server.  Answer the new count. "

	^LockCount := anInteger!   
CoLoadLibrary: aString _: bAutoFree
		" Load the library named <aString>.  If the <bAutoFree> flag is set,
		the library will be freed when it is no longer needed. "

	| hLibrary |
	hLibrary := self invokeCoLoadLibrary: ( self asUnicodeParameter: aString ) 
		_: bAutoFree.
	^hLibrary = 0
		ifTrue: [ self osError ]
		ifFalse: [ DynamicLinkLibrary fromInteger: hLibrary ]! 
structureResultAtAddress: anExternalAddress put: aStructure
        " Private - store the structure output argument value <aStructure>
        into the caller-provided memory location at <anExternalAddress>. "

    | structureBytes |
    aStructure isNil ifTrue: [ ^self ].
    " this operation only works correctly for structures allocated in Smalltalk memory
        (size is not known for structures which reference external memory) "
    structureBytes := aStructure asParameter.
    structureBytes isByteArray
        ifFalse: [ self error: 'unknown structure size' ].
    ( ExternalBuffer atAddress: anExternalAddress )
        bytesAtOffset: 0
        put: structureBytes.! 
isOle1Class
		" Answer whether the receiver is the CLSID of an OLE1 object. "

	^( OLEDLL current CoIsOle1Class: self ) = S_OK!
invokeOleDoAutoConvert: pStg _: pClsidNew
        "Private - WINOLEAPI OleDoAutoConvert(
            LPSTORAGE pStg, LPCLSID pClsidNew);"

    | hresult |
    <api: OleDoAutoConvert handle structOut hresult>
    hresult := self apiFailureReason.
    hresult = REGDB_E_KEYMISSING
        ifTrue: [ ^hresult ].
    ^self apiCallFailed!
windowHandleResultAtAddress: anExternalAddress put: aWindow
		" Private - store the window handle output argument value <aWindow> 
		into the caller-provided memory location at <anExternalAddress>.  "

	aWindow isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress )
		bytesAtOffset: 0 
		put: aWindow asParameter.!  
activeObjectDropped: anEphemeron
		" Private - the OLE object described by <anEphemeron> which was created by
		a class factory was dropped from the active objects registry
		because it is no longer referenced by anything in the system. "

	| anOleObject aClassFactory |

	" This should not be necessary, given the explicit
		notification obtained from OLEObject>>releaseResources.
		Retain as a backstop. "

	anOleObject := anEphemeron key.
	aClassFactory := anEphemeron value.

	"self ASSERT: anOleObject referenceCount = 0."
	self compressActiveObjectsRegistry.
	self checkInUse: aClassFactory.!
interfaceEqual: anInterface
		" Private - answer whether receiver and <anInterface> are the same interface. 
		The IID's are assumed to be equal. "

	"self ASSERT: anInterface isOLEInterfaceReference not."
	"self ASSERT: anInterface isOLEInterfacePointer."

	^self asInteger = anInterface asInterfacePointer asInteger! 
invokeOleCreate: rclsid _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreate(
				REFCLSID rclsid, REFIID riid, DWORD renderopt,
				LPFORMATETC pFormatEtc, LPOLECLIENTSITE pClientSite,
				LPSTORAGE pStg, LPVOID FAR* ppvObj);"

    <api: OleCreate structIn structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed
!   
registerStructureName: structureName for: aClass
		" Register <structureName> as the host structure name
		of the data structure definition class <aClass>. "

	| registeredClass |

	structureName isSymbol
		ifFalse: [
			OLEDevelopmentWarning signal:
				'OLEStructure name must be registered as a symbol - ignoring registration of ',
				structureName printString, ' for class ', aClass name,
				'.  You need to fix the registration logic.'.
			Terminal bell.
			^nil ].
 
	self structureNameMap isNil
		ifTrue: [ self initializeStructureNameMap ].
	registeredClass := self structureNameMap at: structureName ifAbsent: [ nil ].
	" structure registrations should be unique;  changing may be a programmer error "
	( registeredClass notNil and: [ registeredClass ~~ aClass ] )
		ifTrue: [
			( MessageBox confirm: 
				'You are about to replace the registration for structure ', 
				structureName, ' of ', registeredClass name, 
				' with ', aClass name, ' - this may be an error.  Do you wish to proceed?' )
				ifFalse: [ Terminal bell. ^nil ] ].
	self structureNameMap at: structureName "asSymbol" put: aClass.
!   
CoFreeUnusedLibraries
		" Notify the OLE implementation layer that it can free any DLL's 
		previously loaded by CoLoadLibrary which are no longer used. "
 
	" WINOLEAPI_(void) CoFreeUnusedLibraries(void); "

    <api: CoFreeUnusedLibraries none >
    ^self apiCallFailed!   
initializeSpecialSessionResources
		" Private - initialize the special session resources map. "

	self specialSessionResources: IdentityDictionary new.!   
OleLoadFromStream: anIStream _: iid _: resultReference
		" Load an embedded or linked object into memory from the stream <anIStream>.
		Obtain the interface specified by the GUID <iid> on the new object
		and store the interface pointer into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeOleLoadFromStream: anIStream asParameter
		_: iid
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
objectClass: anOLEObjectClass
		" Private - set the class whose instance are created by the receiver. "

	objectClass := anOLEObjectClass.!
invokeOleBuildVersion
        "Private - WINOLEAPI_(DWORD) OleBuildVersion( VOID );"

    <api: OleBuildVersion ulongReturn>
    ^self apiCallFailed! 
incrementReferenceCount
		" Increment the reference count of the interface referenced by the receiver.
		This service may be used when artificial reference counting on an interface is desired;
		it is a synonym for addRef which provides naming symmettry with the special-purpose
		decrementReferenceCount operation. "

	^self addRef!   
getDisplayName: aBindContext monikerToLeft: monikerToLeft
		" Answer the display name of this moniker. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetDisplayName: aBindContext _: monikerToLeft _: resultReference.
	^resultReference value!  
asCLSIDString
		" Answer the string representation of the receiver CLSID. "

    | resultReference |
	resultReference := nil asValueReference.
	OLEDLL current StringFromCLSID: self _: resultReference.
	^resultReference value!   
releaseResources
		" Private - release resources owned by the receiver.
		Default is to do nothing.  Should be reimplemented by 
		subclasses whose fields reference external resources 
		which must be released, such as memory or
		interface pointers obtained from another object. "!   
OleDraw: anIUnknown _: dwAspect _: hdcDraw _: rcBounds
        " OleDraw is a helper function that can be used to draw objects.
        The interface <anIUnknown> is an interface of the object to be drawn.
        The value <dwAspect> is from the enumeration DVASPECT.
        The handle <hdcDraw> is the device context onto which the drawing should
        actually be done (In OLE 2.01 this cannot be a metafile device context ).
        The rectangle <rcBounds> indicates the rectangle on which the object should
        be drawn. This parameter controls the positioning and stretching of the object.
        Raise an exception if an error occurs.  Answer the result code. "

	^self invokeOleDraw: anIUnknown asParameter
        _: dwAspect
        _: hdcDraw asParameter
        _: rcBounds asParameter!  
entryPointIndex: anEntryPointName
		" Private - answer the index in the VTable of the 
		entry point named <anEntryPointName>. "

	 ^(self vtableDescription collect: [ :eptDescr | eptDescr name ] )
		indexOf: anEntryPointName asString ifAbsent: [ nil ]!
invokeStgOpenStorageOnILockBytes: plkbyt _: pstgPriority _: grfMode _: snbExclude _: reserved _: ppstgOpen
		"Private - WINOLEAPI StgOpenStorageOnILockBytes(ILockBytes FAR *plkbyt,
                  IStorage FAR *pstgPriority,
                  DWORD grfMode,
                  SNB snbExclude,
                  DWORD reserved,
                  IStorage FAR * FAR *ppstgOpen);"

    <api: StgOpenStorageOnILockBytes structIn handle ulong structIn ulong structOut hresult>
    ^self apiCallFailed!
allocatedInterfacesRegistry: aRegistry
		" Private - set the registry containing OLE interfaces for which an interface
		invocation structure has been allocated in external memory in the current session. "

	| resources |
	( AllocatedInterfacesRegistry notNil
	and: [ ( resources := self allAllocatedInterfaces ) notEmpty ] )
		ifTrue: [ 
			self transferResources: resources 
				to: aRegistry 
				type: 'allocated interfaces'.
			AllocatedInterfacesRegistry action: nil.  " ignore the old collection "
			].
	AllocatedInterfacesRegistry := aRegistry.!   
removeIID
        " Private - remove the registration of the receiver as the interface class for its IID. "

    self removeIID: self iid.!
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."

    ^self
!  
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	aOneArgBlock value: iClassFactory.!   
dispatchSelectors
		" Answer the message selectors of the receiver's 
		interface function dispatch bindings "

	^self functionHandlers collect: [ :anAction |
		anAction isMessage
			ifTrue: [ anAction selector ]
			ifFalse: [ nil ] ]!
specialSessionResources
		" Private - answer a map of OLE resources owned or allocated
		by the current session which are handled specially at session startup/shutdown. "

	^SpecialSessionResources!
constructActiveObjectsRegistry
		" Private - construct the active objects registry. "

	^WeakKeyedRegistry new
		action: ( Message receiver: self selector: #activeObjectDropped: );
		yourself! 
OleRegGetUserType: clsid _: dwFormOfType _: resultReference
		" Obtain the user type of the CLSID <clsid> from the registration 
		database and store it into the <resultReference>.  The form of the 
		user-presentable string is indicated by the USERCLASSTYPE value <dwFormOfType>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := self createStringResultValue.
	hresult := self invokeOleRegGetUserType: clsid
		_: dwFormOfType
		_: resultValue.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: ( self stringFromResultValue: resultValue ) ].
	^hresult!
invokeCoIsHandlerConnected: pUnk
		"Private - WINOLEAPI_(BOOL) CoIsHandlerConnected(LPUNKNOWN pUnk);"

    <api: CoIsHandlerConnected handle boolean>
    ^self apiCallFailed!
functionHandlers: anArray
		" Private - set the interface function handlers. "

	functionHandlers := anArray.! 
dispatchQueryInterface:  iid _: resultReference
		"Private - dispatch the IUnknown::QueryInterface function. "

	^( functionHandlers at: 1 ) evaluateWithArguments: ( Array
		with: iid
		with: resultReference )!   
copyToNonSmalltalkMemory: aVariableByteObject
        " Copy <aVariableByteObject> to allocated OLE memory
        and answer the OLEMemoryAddress of that memory. "

    | aByteObject bytes address |
    aByteObject := aVariableByteObject asParameter.
    bytes := aByteObject size.
    aByteObject isNil ifTrue:  [ ^self new ].
    address := self allocateMemory: bytes + 2.
    address
        replaceBytes: bytes with: aByteObject;
        at: bytes + 1 put: 0;
        at: bytes + 2 put: 0.
    ^address! 
isOLEInterfaceImplementation
		" Answer whether the receiver is an OLE interface implemented
		in this Smalltalk image. "

	^interface isOLEInterfaceImplementation!  
release
		" Release any system resources associated with the receiver. "

	self releaseResources.
	self class usesFinalization
		ifTrue: [ self doesNotNeedFinalization ].
	super release.! 
classForIID: anIID ifNone: aBlock
		" Answer the OLEInterface subclass which represents the interface
		specified by the interface ID GUID <anIID>.  
		Answer the result of evaluating <aBlock> if no class is available. "

	| aClass |
	( anIID isNil or: [ anIID = IID_NULL ] )
		ifTrue: [ ^aBlock value ].
	aClass := OLEInterfacePointer interfaceReferenceClassForIID: anIID.
	aClass notNil
		ifTrue: [ ^aClass ].
	aClass := self subclassForIID: anIID.
	aClass notNil
		ifTrue: [  " self-registration backstop "
			self registerIID: anIID forClass: aClass.
			^aClass ].
	^aBlock value!  
isSupportedLibraryVersion: dllVersionNumbers
		" Answer whether the major/minor OLE library version numbers in 
		<dllVersionNumbers> is a supported version of the OLE library, 
		per OLE2VER.H. "

	^( dllVersionNumbers at: 1 ) = Rmm   " major build number must match "
		and: [ ( dllVersionNumbers at: 2 ) >= Rup ]  " minor build number must be this or newer "
!
StringFromCLSID: clsid _: resultReference
		" Convert the CLSID specified by the GUID <clsid> into a display string.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := self createStringResultValue.
	hresult := self invokeStringFromCLSID: clsid
		_: resultValue.
	resultReference value: ( self stringFromResultValue: resultValue ).
	^hresult! 
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver the GUID <anIID>.
		The default is to do nothing - the IID is known by the class.
		This method is reimplemented by subclasses whose instances can represent
		more than one interface. "!  
invokeCreateItemMoniker: delimiterString _: itemName _: ppmk
        "Private -WINOLEAPI  CreateItemMoniker(
			LPCOLESTR lpszDelim, LPCOLESTR lpszItem,
			LPMONIKER FAR* ppmk);"

    <api: CreateItemMoniker structIn structIn structOut hresult>
    ^self apiCallFailed!   
vtableSize
		" Answer the number of interface function entry points
		defined in the receiver's callin VTable functions. "

	^self class vtable size
!   
dispatchDragEnter: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Private - dispatch the IDropTarget::DragEnter function. "

    ^( functionHandlers at: 4 ) evaluateWithArguments: ( Array 
		with: anIDataObject 
		with: grfKeyState 
		with: aPoint 
		with: resultReference )

! 
fromDisplayName: displayName
		" Answer a new instance of the receiver for the object referenced by <displayName>. "

	^self fromDisplayName: displayName 
		bindContext: nil
		charsConsumed: nil asValueReference! 
CoIsOle1Class: clsid
		" Determine whether the CLSID specified by the GUID <clsid> 
		represents an OLE 1 object. "

	" WINOLEAPI_(BOOL) CoIsOle1Class(REFCLSID rclsid); "

    <api: CoIsOle1Class structIn boolean>
    ^self apiCallFailed! 
isOLEExternalAddress
        " Answer whether the receiver is an external memory address
        which was allocated by an OLE memory allocator. "

    ^true!
standardIUnknownSelectors
        " Private - answer the selectors for the standard implementations
		of the IUnknown operations. "

    ^#( #QueryInterface:_: #AddRef  #Release )!  
asValueReference
		" Answer a reference to the receiver which allows it to be manipulated as a value. "

	^OLEValueReference on: self! 
stringAtAddress: anExternalAddress
		" Private - answer a String containing the characters at address <anExternalAddress>. 
		The string pointer references the Unicode byte encoding of the string. "

	anExternalAddress isValid
		ifFalse: [ ^nil ].
	^( UnicodeStringBuffer atAddress: anExternalAddress ) asString!
traceEnabled
        " Answer whether trace logging is enabled. "

	^self traceManager notNil and: [ self traceManager traceEnabled ]! 
invokeReadClassStm: pStm _: pclsid
		"Private - WINOLEAPI ReadClassStm(LPSTREAM pStm, CLSID FAR* pclsid); "

    <api: ReadClassStm handle structOut hresult>
    ^self apiCallFailed!
supportsIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^( super supportsIID: anIID )
		or: [ self supportsEnumeratorIID: anIID ]!  
invokeIIDFromString: lpsz _: pclsid
        "Private - WINOLEAPI IIDFromString(LPOLESTR lpsz, LPIID lpiid);"

	| hresult |
	<api: IIDFromString structIn structOut hresult>
	hresult := self apiFailureReason.
	hresult = CO_E_IIDSTRING
		ifTrue: [ ^hresult ].
	^self apiCallFailed!
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iClassFactory := nil.!  
unimplementedFunctionDispatchHandler
		" Answer an interface function dispatch handler
		for an unimplemented function. "

	^Message receiver: self selector: #unimplementedFunction
!   
addRef
		" Increment the reference count of the interface referenced by the receiver.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

	^interface AddRef!  
DragLeave
		" Private - implement the IDropTarget::DragLeave function.
		The mouse has left the target window during a drag operation.
		Answer the result code. "

    window dragTargetLeave: self session.
    self releaseSessionResources.
    ^S_OK! 
releaseSessionResources
		" Private - release the copy of the data object being dragged. "

	self dataObject release.
	self 
		dataObject: nil;
		session: nil.!
DragEnter: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Private - implement the IDropTarget::DragEnter function.
		Determine whether the target window can accept the dragged object <anIDataObject>.
		The current state of the keyboard modifier keys is indicated by the <grfKeyState> flags.
		The current mouse/cursor position is given in <aPoint>.
		Store the desired drop effect code into <resultReference>.
		Answer the result code. "

    self allocateSessionResources: anIDataObject.
    self session
        screenLocation: aPoint;
        keyState: grfKeyState.
    window dragTargetEnter: self session.
    resultReference value: ( self session operationAsDropEffect ).
    ^S_OK! 
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	iDropTarget notNil
		ifTrue: [ aOneArgBlock value: iDropTarget ].!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the GUID <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = IID_IDropTarget
		ifTrue: [ ^iDropTarget ].
	^nil! 
dataObject: aDataObject
        "Private - set the IDataObject being dragged to <aDataObject>."

    iDataObject := aDataObject.
!
initializeInterfaces
        " Private - Allocate any interfaces which are expected to be required
        during the object's lifetime. "

    super initializeInterfaces.
    iDropTarget := IDropTarget on: self.
!  
dataObject
        "Private - answer the IDataObject being dragged."

    ^iDataObject
!  
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iDropTarget := nil.!
session: aDragDropSession
        "Private - set the receiver's drag drop session."

    session := aDragDropSession!  
Drop: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Private - implement the IDropTarget::Drop function.
		The dragged object <anIDataObject> has been dropped on the target.
		The current state of the keyboard modifier keys is indicated by the <grfKeyState> flags.
		The current mouse/cursor position is given in <aPoint>.
		The desired drop effect code is stored into <resultReference>.
		Answer the result code. "

    "self ASSERT: anIDataObject = self dataObject."  " Should be same guy we started with "
    self session
        screenLocation: aPoint;
        keyState: grfKeyState.
    window dragTargetDrop: self session.
    resultReference value: ( self session operationAsDropEffect ).
    self releaseSessionResources.
    ^S_OK!   
session
        "Private - answer the receiver's drag drop session."

    ^session
!  
allocateSessionResources: anIDataObject
        " Private - make the copy of the data object being dragged
        and begin a new drag session. "

    self
        dataObject: anIDataObject separateReference;
        session: ( self dragDropSessionClass fromIDataObject: self dataObject ).! 
window: aWindow
        "Set the window associated with the receiver."

    window := aWindow
!   
dragDropSessionClass
        "Private - answer the default drag drop session class."

    ^WinDragDropSession
!   
DragOver: grfKeyState _: aPoint _: resultReference
		" Private - implement the IDropTarget::DragOver function.
		Provide feedback to the user and to DoDragDrop about the
		state of the drop operation withing a drop target application.
		Answer the result code. "

        " The mouse has moved over the target window during a drag operation.
        The current state of the keyboard modifier keys is indicated by the <grfKeyState> flags.
        The current mouse/cursor position is given in <aPoint>.
        The desired drop effect code is stored into <pdwEffect>.
        Answer the result code. "

    self session
        screenLocation: aPoint;
        keyState: grfKeyState.
    window dragTargetOver: self session.
    resultReference value: ( self session operationAsDropEffect ).
    ^S_OK!
decrementReferenceCount
		" Decrement the reference count of the interface referenced by the receiver.
		Do not destroy the reference, allowing the client to continue using the interface.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

	| remainingReferenceCount |
    self ifOLETraceEnabled: [ self logFunctionEntry ].
	remainingReferenceCount := ( self isValid
		ifTrue: [ self invokeRelease ]
		ifFalse: [ 0 ] ).
    self ifOLETraceEnabled: [
        self logReturnValue: 'Ref count: ', remainingReferenceCount printString ].
	^remainingReferenceCount
!  
sessionStartedToServiceAutomation
        " Answer whether the current session was started by OLE
        as an automation server. "

    | commandLineArguments |
	commandLineArguments := self sessionCommandLineArguments.
    ^( commandLineArguments
        detect: [ :anArgument |
            anArgument equalsIgnoreCase: '/Automation' ]
        ifNone: [ nil ] )
            notNil!
asGUID
		" Answer the GUID specified by the receiver if it is
		a syntactically legal string representation of a GUID.
		E.g. '{12345678-1234-1234-1234-123456789012}'  "

    ^GUID fromString: self!   
interfaceAtOffset: anInteger type: anInterfaceClass
		" Answer the interface pointer of type <interfaceClass> at <anInteger>.
		The interface is a temporary copy and is not separately reference counted.
		The caller should copy the interface if they want to retain an independent copy.
		Answer the interface or nil if not valid. "

	| anAddress |
	anAddress := self addressAtOffset: anInteger.
	^anAddress isNil
		ifTrue: [ nil ]
		ifFalse: [ anInterfaceClass forTemporaryInterfacePointerAtAddress: anAddress ]!
asFileTimeParameter: aFileTimeOrTimeStamp
		" Private - answer <aFileTimeOrTimeStamp> as a FILETIME parameter. "

	^( aFileTimeOrTimeStamp isTimeStamp
		ifTrue: [
			( OLEStructure classForStructureNamed: #FILETIME ) fromTimeStamp: aFileTimeOrTimeStamp ]
		ifFalse: [ aFileTimeOrTimeStamp ] )  " already a FILETIME "
			asParameter!   
bindToObject: aBindContext monikerToLeft: monikerToLeft iid: iid
		" Locate and load the object referenced by this moniker.
		Answer the interface identified by <iid> on the referenced object. "

	| resultReference |
	resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
	interface BindToObject: aBindContext _: monikerToLeft _: iid _: resultReference.
	^resultReference value! 
invokeOleCreateLinkFromData: pSrcDataObj _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreateLinkFromData(
             LPDATAOBJECT pSrcDataObj, REFIID riid,
             DWORD renderopt, LPFORMATETC pFormatEtc,
             LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID FAR* ppvObj);"

    <api: OleCreateLinkFromData handle structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed!  
drawAspect: anInteger
        "Set the receiver's drawAspect field."

    self uLongAtOffset: 20 put: anInteger
! 
status: anInteger
        "Set the receiver's status field."

    self uLongAtOffset: 40 put: anInteger!   
fullUserTypeName: anOffset
        "Set the full user type name field."

    self uLongAtOffset: 44 put: anOffset! 
cbSize: anInteger
        "Set the receiver's size field."

    self uLongAtOffset: 0 put: anInteger!  
pointl: aPoint
        "Set the receiver's pointl field."

    self
        uLongAtOffset: 32 put: aPoint x;
        uLongAtOffset: 36 put: aPoint y!
sizel: aPoint
        "Set the receiver's sizel field."

    self
        uLongAtOffset: 24 put: aPoint x;
        uLongAtOffset: 28 put: aPoint y!  
srcOfCopy: anOffset
        "Set the source of copy field to anOffset."

    self uLongAtOffset: 48 put: anOffset! 
clsID: anIID
        "Set the receiver's class id field."

    self guidAtOffset: 4 put: anIID!
iid
		"Answer the interface ID GUID which uniquely identifies instances of the receiver. "

	^iid! 
unbindDevelopmentLibrary: devLibraryName
		" Unbind the development environment support library <devLibraryName>. "

	| aLibrary |
	( aLibrary := SmalltalkLibrary named: devLibraryName ) notNil
		ifTrue: [ aLibrary unBind ].!
separateReference
        " Answer a new interface reference on the same interface. 
		The copy is reference counted and must be released by the caller. "

	| copy |
	copy := self copy.
	copy isValid
		ifTrue: [ 
			copy addRef.
			copy isOLEInterfacePointer 
				ifTrue: [ copy interfaceBinding needsFinalization ].
			].
	^copy!
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^72!  
CoRevokeClassObject: classRegistrationToken
		" Notify OLE that a class object previously registered with 
		CoRegisterClassObject is no longer available.
		Raise an exception if an error occurs.  Answer the result code. "

	" WINOLEAPI  CoRevokeClassObject(DWORD dwRegister); "

	<api: CoRevokeClassObject ulong hresult>
	^self apiCallFailed!   
registerInterfaceReferenceClass: aClass forIID: anIID
        " Private - register <aClass> as the interface class representing
        the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	( anIID isNil or: [ anIID = IID_NULL ] )
		ifTrue: [ ^nil ].  " ignore null IID's of abstract interface classes "
	self iidMap isNil
		ifTrue: [ self initializeIIDMap ].
	iidEntry := self iidMap at: anIID 
		ifAbsentPut: [ Array new: 3 ].  " ptr, reference, impl "
	iidEntry at: 2 put: aClass.
	^aClass!   
supportAllOLE
		" Private - answer whether all OLE services are supported.
		Answer false if only basic COM services are supported. "

	^supportAllOLE!   
OleQueryCreateFromData: anIDataObject
		" Determine whether a container application can create an
		embedded object from the data transfer object <anIDataObject>t.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeOleQueryCreateFromData: anIDataObject asParameter!  
logIID: anIID
        " Private - log an IID value to the OLE trace log. "

    | interfaceClass |
    interfaceClass := OLEInterface classForIID: anIID
        ifNone: [ nil ].
    self oleTRACE: '    IID: ',
        ( interfaceClass isNil
            ifTrue: [ '' ]
            ifFalse: [ 'IID_', interfaceClass name, ' ' ] ),
        anIID printString.!
OleIsRunning: anIOleObject
        " Determine whether the object <anIOleObject > is running.
        Answer TRUE if it is therewise answer FALSE.
        Raise an exception if an error occurs. "

    ^self invokeOleIsRunning: anIOleObject asParameter! 
logFunctionExit: hresult
        " Private - log function exit to debug trace log. "

    self oleTRACE: '    hresult: ', ( HRESULT nameOrHexString: hresult ).
! 
resetResources
		" Private - reset the external resources associated with the receiver to an initial state. "

	self externalMemoryAddress: nil.!  
lockObject
		" Lock the receiver's object so that its reference count
		cannot decrement to zero. "

	OLEDLL current CoLockObjectExternal: self _: true _: false.!
GetConvertStg: anIStorage
        " Answer the current value of the conversion bit in the object's storage,
        <anIStorage> which was previously set with SetConvertStg. "

    ^self invokeGetConvertStg: anIStorage asParameter!   
registerClassFactory: aClassFactory classContext: classContext flags: flags
		" Register the class factory <aClassFactory> with OLE. 
		Answer the registration token. "

	| anIUnknown registrationToken |
	aClassFactory isRegistered
		ifTrue: [ OLEError hresult: CO_E_OBJISREG ].
	anIUnknown := aClassFactory queryInterface: IID_IUnknown.
		" Note that this increments the reference count of the class factory.
		Since we own this interface reference, we must release it when the
		class factory is revoked. "
	registrationToken := IClassFactory registerClassObject: aClassFactory objectCLSID  
		unknown: anIUnknown 
		classContext: classContext 
		flags: flags.
	aClassFactory 
		registeredUnknown: anIUnknown;
		registrationToken: registrationToken.
	self classFactoryRegistry add: aClassFactory.
	^registrationToken!
invalidate
		"Set the receiver to be invalid."

	self contents: self class nullValue contents.
	self doesNotNeedFinalization.!
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^4!   
replaceBytes: count with: aCollection
        "Private - replace count bytes of the receiver
         with bytes of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    <primitive: 81>
    ^self primitiveFailed!  
onLinkSourceChange: aMoniker
		" Notify the receiver that the moniker of the calling link object 
		has changed to <aMoniker>.  Used by an OLE link object to
		notify its container of a moniker change when the link object
		has received an OnRename notification from its link source object. 
		The notification is asynchronous and the arguments belong to the caller."

	interface OnLinkSrcChange: aMoniker.!
implementor
		"Answer the OLE object that finally implements the interface."

	^implementor!   
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

	iid := anIID.
	interface notNil 
		ifTrue: [ interface iid isNil
			ifTrue: [ interface iid: anIID ]
			ifFalse: [ 
				interface iid ~= anIID
					ifTrue: [ OLEDevelopmentWarning signal: 'IEnum iid mismatch with interface binding' ].
				].
			].
!  
OleBuildVersion
		"Answer an array containing the major and minor version numbers of the OLE library. "

	| dw |
	dw := ExternalLong fromString: self invokeOleBuildVersion.
	^Array with: dw highHalf with: dw lowHalf! 
createPointerMoniker: anIUnknown
        " Create a new pointer moniker for the object <anIUnknown>.
        Answer a new instance of the receiver for the new moniker. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current CreatePointerMoniker: anIUnknown 
		_: resultReference.
    ^resultReference value!   
createExternalStructureNamed: structureName
		" Answer a new data structure instance for the host structure named <structureName>.
		The structure is allocated in external OLE memory. "

	^( self classForStructureNamed: structureName ) newExternalStructure! 
forCLSID: aGUID
		" Answer a new instance of the receiver which creates instances
		of the OLE objects implemented by the OLE object class
		which supports the CLSID specified by the CLSID <aGUID>. 
		Answer nil if the CLSID is not supported. "

	^self new
		objectClass: ( OLEObject classForCLSID: aGUID 
			ifNone: [ ^nil ] );
		yourself! 
SetConvertStg: anIStorage _: fConvert
        " Set the conversion bit in the object's storage <anIStorage> so that the setting
        is retrievable with GetConvertStg.  The boolean <fConvert> if TRUE tags the
        object for conversion to another class of object; FALSE clears the conversion bit. "

    ^self invokeSetConvertStg: anIStorage asParameter _: fConvert! 
compressActiveObjectsRegistry
		" Private - minimize the storage requirements of the active objects registry. "

	self activeObjectCount = 0
		ifTrue: [ self resetActiveObjectsRegistry ].!  
activeObjectCount
		" Answer the number of objects created by the receiver
		which are still in service. "

    ^ActiveObjectsRegistry isNil
        ifTrue: [ 0 ]
        ifFalse: [ self activeObjectsRegistry size ]!
invalidate
		"Invalidate the receiver and remove from finalization (if not already done).  
		Subclass will typically augment this method (via super) to release or free 
		any associated system or OLE resources or references."

	self uLongAtOffset: 0 put: 0.
	self doesNotNeedFinalization.!  
= anObject
		" Answer whether the receiver and <anObject> represent the same interface. "

	^anObject isOLEInterface 
		and: [ self iid = anObject iid
		and: [ self interfaceEqual: anObject interfaceBinding ] ]!  
dispatchQueryContinueDrag: escKeyPressed _: keyState
		" Private - dispatch the IDropSource::QueryContinueDrag function. "

    ^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
		with: escKeyPressed 
		with: keyState )
!  
invokeQueryContinueDrag: escKeyPressed _: keyState
        "Private - invoke the IDropSource::QueryContinueDrag function for an external caller. "

	" HRESULT QueryContinueDrag(
            /* [in] */ BOOL fEscapePressed,
            /* [in] */ DWORD grfKeyState); "

	^self dispatchQueryContinueDrag: escKeyPressed _: keyState
! 
QueryContinueDrag: escKeyPressed _: keyState
		" Invoke the IDropSource::QueryContinueDrag function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchQueryContinueDrag: escKeyPressed _: keyState )
! 
GiveFeedback: dwEffect
		" Invoke the IDropSource::GiveFeedback function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchGiveFeedback: dwEffect )
!  
dispatchGiveFeedback: dwEffect
		" Private - dispatch the IDropSource::GiveFeedback function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array with: dwEffect )
!
invokeGiveFeedback: dwEffect
        "Private - invoke the IDropSource::GiveFeedback function for an external caller. "

	" HRESULT GiveFeedback(
            /* [in] */ DWORD dwEffect); "

	^self dispatchGiveFeedback: dwEffect! 
name
		"Answer the name of the entry point described by the receiver."

	^name!
name: aString
		"Set the name of the entry point described by the receiver to <aString>."

	name := aString.!  
printOn: aStream
		"Append a string representation of the receiver to <aStream>."

	aStream 
		"nextPutAll: self class name; "
		nextPutAll: name; space;
		nextPutAll: '('; space;
		"nextPutAll: name; space;"
		nextPutAll: vtableIndex printString; space;
		nextPutAll: '#', argumentTypes printString; space;
		nextPutAll: '#', resultType; space;
		nextPutAll: ')'.!  
argumentTypes: aSymbolArray
        "Set the argument types of the receiver to the types specified by <aSymbolArray>."

    argumentTypes := aSymbolArray.!
argumentTypes
        "Answer an Array of symbol describing the argument types used to invoke the receiver.."

    ^argumentTypes! 
vtableIndex: anInteger
		" Set the VTable index of the entry point described by the receiver to <anInteger>. "

	vtableIndex := anInteger.!
vtableIndex
		" Answer the VTable index of the entry point described by the receiver. "

	^vtableIndex!
selector: aSymbol
		"Specify the message selector which is sent to invoke 
		the entry point described by the receiver."

	selector := aSymbol.!  
resultType: aSymbol
        "Set the result type of the entry point described by the receiver to <aSymbol>."

    resultType := aSymbol.!  
resultType
        "Answer the result type of the entry point described by the receiver."

    ^resultType!
selector
		"Answer the message selector which is sent to invoke 
		the entry point described by the receiver."

	^selector!   
callingConvention
		" Answer the calling convention supported by the receiver. "

	^self class callingConvention!  
revokeDragDrop
        "Private - revoke the receiver for drag/drop operations."

    | anIDropTarget |
    anIDropTarget := self iDropTarget.
    ( anIDropTarget isNil
    or: [ anIDropTarget isValid not ] )
		ifTrue: [ ^self ].  " already revoked "
	self iDropTarget: nil.
	anIDropTarget 
		revokeDragDrop: self;
		release.
!   
finalize
		" Private - The receiver is no longer referenced by any object 
		in the system and is about to be destroyed.  Release the interface. "

	self isValid
		ifTrue: [ OLEDevelopmentWarning signal: 'OLE interface released by finalization: ', self printString ]
		"ifFalse: [ OLEDevelopmentWarning signal: 'Unnecessary finalization on OLE interface ', self printString ]".
	^self release!  
invokeGetConvertStg: pStg
        "Private - WINOLEAPI GetConvertStg(
            LPSTORAGE pStg);"

    <api: GetConvertStg handle hresult>
    ^self apiCallFailed!
elementsEnumerator
		" Answer an enumerator on the elements of a composite moniker
		which will operate in the forward direction.
		Answer nil if there is nothing to enumerate. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumMoniker ) asValueReference.
	interface Enum: true _: resultReference.
	^resultReference value!  
dragTargetDoGlobalScroll: dragSession
        "Private - scroll the receiver in response to item being
        dragged in the drag scrolling hot zone."
    | direction |
    direction := self dragTargetScrollDirection.
    self dragTargetScrollElapsed: nil.
    self dragTargetScrollDirection: nil.
    direction notNil
        ifTrue: [ dragSession targetEraseEmphasis ].
    direction = #up ifTrue: [ self scrollVerticalCharacters: 1; updateVerticalSlider ].
    direction = #down ifTrue: [ self scrollVerticalCharacters: -1; updateVerticalSlider ].
    direction = #right ifTrue: [ self scrollHorizontalCharacters: -1; updateHorizontalSlider ].
    direction = #left ifTrue: [ self scrollHorizontalCharacters: 1; updateHorizontalSlider ].
    direction notNil ifTrue: [ dragSession targetDrawEmphasis ].
    !
createStructureNamed: structureName atAddress: anAddress
		" Answer a new data structure instance for the host structure named <structureName>
		whose bytes are in external memory at <anAddress>. "

	^( self classForStructureNamed: structureName ) atAddress: anAddress! 
Drop: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Invoke the IDropTarget::DragEnter function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeDrop: anIDataObject asParameter 
		_: grfKeyState 
		_: aPoint asParameter
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!  
DragLeave
		" Invoke the IDropTarget::DragLeave function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT DragLeave( void);"

	<ole: 5 hresult>
	^self vtableDispatchFailed!   
invokeDrop: pDataObj _: grfKeyState _: pt _: pdwEffect
		" Private - invoke the IDropTarget::DragEnter function. "

	"  HRESULT Drop(
            /* [unique][in] */ IDataObject *pDataObj,
            /* [in] */ DWORD grfKeyState,
            /* [in] */ POINTL pt,
            /* [out][in] */ DWORD *pdwEffect); "

	<ole: 6 handle ulong structValue struct hresult>
	^self vtableDispatchFailed!
invokeDragOver: grfKeyState _: pt _: pdwEffect
		" Private - invoke the IDropTarget::DragOver function. "

	" HRESULT DragOver(
            /* [in] */ DWORD grfKeyState,
            /* [in] */ POINTL pt,
            /* [out][in] */ DWORD *pdwEffect); "

	<ole: 4 ulong structValue struct hresult>
	^self vtableDispatchFailed!
DragEnter: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Invoke the IDropTarget::DragEnter function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeDragEnter: anIDataObject asParameter
		_: grfKeyState 
		_: aPoint asParameter
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult! 
DragOver: grfKeyState _: aPoint _: resultReference
		" Invoke the IDropTarget::DragOver function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeDragOver: grfKeyState 
		_: aPoint asParameter 
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!
invokeDragEnter: pDataObj _: grfKeyState _: pt _: pdwEffect
		" Private - invoke the IDropTarget::DragEnter function. "

	" HRESULT DragEnter(
            /* [unique][in] */ IDataObject *pDataObj,
            /* [in] */ DWORD grfKeyState,
            /* [in] */ POINTL pt,
            /* [out][in] */ DWORD *pdwEffect); "

	<ole: 3 handle ulong structValue struct hresult>
	^self vtableDispatchFailed!   
sessionHasResources
		" Private - answer whether the session owns or exports resources.
		Ignore resources which are handled specially. "

	^self sessionOwnsResources or: [ self sessionExportsResources ]!  
invokeGetClassFile: szFilename _: pclsid
		"Private - WINOLEAPI  GetClassFile (LPCOLESTR szFilename, CLSID FAR* pclsid);"

    <api: GetClassFile structIn structOut hresult>
    ^self apiCallFailed!
removeInterfaceImplementationClassForIID: anIID
        " Private - unregister <aClass> as the interface callin binding class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	iidEntry := self iidMap at: anIID  " ptr, reference, impl "
		 ifAbsent: [ ^nil ].
	iidEntry at: 3 put: nil.
	iidEntry = #( nil nil nil )
		ifTrue: [ self iidMap removeKey: anIID ].! 
dispatchDrop: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Private - dispatch the IDropTarget::DragEnter function. "

    ^( functionHandlers at: 7 ) evaluateWithArguments: ( Array
		with: anIDataObject 
		with: grfKeyState 
		with: aPoint 
		with: resultReference )

!   
OleSave: anIPersistStorage _: anIStorage _: fSameAsLoad
		" Save an object <anIPersistStorage> which was opened in 
		transacted mode to the storage object <anIStorage>. 
		The boolean <fSameAsLoad> is TRUE if <anIStorage> 
		is the same storage object from which the object was loaded or created;
		it is FALSE if <anIStorage> is a different storage object.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeOleSave: anIPersistStorage asParameter
        _: anIStorage asParameter
        _: fSameAsLoad!   
OleCreateLinkFromData: aDataObject _: iid _: renderopt _: aFormatEtc _: aClientSite _: aStorage _: resultReference
        " Create a linked object from the specified data object <aDataObject>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreateLinkFromData: aDataObject asParameter
        _: iid
        _: renderopt
        _: aFormatEtc
        _: aClientSite asParameter
        _: aStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!  
initialize
		" Private - initialize a new instance of the receiver. "

	super initialize.
	self 
		lockCount: 0;
		releaseIfNotInUse: false.  " perform lazy deallocation at server exit "! 
invokeProgIDFromCLSID: clsid _: lplpszProgID
        "Private - WINOLEAPI ProgIDFromCLSID (REFCLSID clsid, LPOLESTR FAR* lplpszProgID);"

	<api: ProgIDFromCLSID structIn structOut hresult>
	^self apiCallFailed!
defaultDelimiterString
		" Answer the default delimiter string for an item moniker. "

	^'!!'! 
registerIID: anIID forClass: aClass
        " Private - register <aClass> as the interface pointer binding class representing
        the interface whose IID is the interface ID GUID <anIID>. "

	OLEInterfacePointer registerInterfacePointerClass: aClass forIID: anIID.! 
IIDFromString: aString _: resultReference
		" Obtain the IID associated whose display name is <aString>
		and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeIIDFromString: ( self asUnicodeParameter: aString )
		_: resultValue.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!
isRunning: aBindContext 
	monikerToLeft:  monikerToLeft 
	monikerNewlyRunning: monikerNewlyRunning
		" Answer whether this moniker is running. "

	^( interface IsRunning: aBindContext _:  monikerToLeft _: monikerNewlyRunning ) = S_OK!   
RevokeDragDrop: aWindow
        " Revoke the window <aWindow> as being able to accept dropped objects.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeRevokeDragDrop: aWindow asParameter!  
allExportedObjects
		" Private - answer a collection containing the OLE objects which have been exported
		from this session. "

	^( self allExportedInterfaces collect: [ :anInterface | anInterface implementor ] )
		asSet
! 
needsFinalization
    "The receiver needs to be sent the message #finalize when it is no longer referenced."

	OLESessionManager trackResources
		ifTrue: [ super needsFinalization ].!   
queryInterface: iid
        "Query the receiver for the interface specified by the GUID <iid>.
		Answer the interface if it is supported, else answer nil. "

    | resultReference |
	resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
	self QueryInterface: iid _: resultReference.
    ^resultReference value! 
registrationToken
		" Private - answer the receiver's registration token.
		Answer nil if the receiver is not registered with OLE. "

	^registrationToken!
invokeReadClassStg: pStg _: pclsid
		"Private - WINOLEAPI ReadClassStg(LPSTORAGE pStg, CLSID FAR* pclsid); "

    <api: ReadClassStg handle structOut hresult>
    ^self apiCallFailed!   
invokeGetRunningObjectTable: reserved _: pprot
        "Private - WINOLEAPI  GetRunningObjectTable( 
              DWORD reserved, LPRUNNINGOBJECTTABLE FAR* pprot); "

    <api: GetRunningObjectTable ulong structOut hresult>
    ^self apiCallFailed!
isOLEInterfacePointer
		" Answer whether the receiver is an OLE interface referencing
		a VTable in external memory. "

	^true!   
new: anInteger
		"Invalid message - instances of the receiver are of fixed size."

	^self invalidMessage!  
DragLeave
		" Invoke the IDropTarget::DragLeave function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: self dispatchDragLeave
!  
dragSourceGlobal: aBoolean
        "Enable the receiver as an OLE drag source."

    self dragSource: aBoolean.
    aBoolean ifTrue: [ self dragSessionClass: WinDragDropSession ]



!   
isOLEInterfaceImplementation
		" Answer whether the receiver is an OLE interface implemented
		in this Smalltalk image. "

	^false!   
elementClass
		" Private - answer the class of the elements
		on which the receiver operates. "

	^elementClass!  
clsidFromProgID: aString
		"Answer a new instance of the receiver that is the CLSID 
		associated with the ProgID <aString> in the registration database."

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current CLSIDFromProgID: aString
		_: resultReference.
	^resultReference value!
replaceBytesFrom: byteStart
    to: byteStop
    with: aByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aByteObject beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 80>
    aByteObject class isBytes
        ifFalse: [self error: 'source must be a byte object'].
    (self == aByteObject and: [byteRepStart < byteStart])
        ifTrue: [ "do backward move for same object"
            index2 := byteRepStart + byteStop - byteStart.
            index1 := byteStop.
            [byteStart <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aByteObject basicAt: index2) asInteger.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := byteRepStart.
    index1 := byteStart.
    [index1 <= byteStop]
        whileTrue: [
            self
                at: index1
                put: (aByteObject basicAt: index2) asInteger.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
sessionOwnsResources
		" Private - answer whether the session owns resources.
		Ignore resources which are handled specially. "

	^self allOwnedMemoryAddresses notEmpty
		or: [ self allOwnedInterfaces notEmpty ]! 
ifOLETraceEnabled: aBlock
		" Private - evaluate the trace logic in <aBlock> if OLE tracing
		is currently enabled for the receiver. "

	( OLESessionManager traceEnabled
	and: [ OLESessionManager traceManager traceCallin ] )
		ifTrue: [ aBlock value ].
! 
StgSetTimes: aFileName _: cTime _: aTime _: mTime
		" Set the creation, access, and modification times of the storage
		named <aFileName> in the file system.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeStgSetTimes: ( self asUnicodeParameter: aFileName )
		_: ( self asFileTimeParameter: cTime )
		_: ( self asFileTimeParameter: aTime )
		_: ( self asFileTimeParameter: mTime )!   
objectClassNameMap
		" Answer a dictionary describing the names of all the registered object
		classes on the system, with the PROGID as the key and the main
		user type name as the value. "

	| classNameMap classesRegistry |
	classNameMap := Dictionary new.
	classesRegistry := self classesRegistry.
	classesRegistry associationsDo: [ :assoc |
		" pick out <ProgID> entries with associated <Progid>\CLSD subkey "
		( classesRegistry includesKey: assoc key, '\CLSID' )
			ifTrue: [ classNameMap add: assoc ] ].
	classesRegistry close.
	^classNameMap!   
getMiscStatus: clsid
		" Answer the miscellaneous status information from the system registry 
		for the DVASPECT_CONTENT aspect of the CLSID <clsid>. "

	^self getMiscStatus: clsid aspect: DVASPECT_CONTENT!   
setDataFormatsEnumerator: clsid
		" Answer an enumerator that can be used to enumerate the formats
		registered in the registration database as the supported formats
		which can be used to set the state of instances of the CLSID <clsid>. "

	| resultReference hresult |
	resultReference := ( IEnum forIID: IID_IEnumFORMATETC ) asValueReference.
	hresult := OLEDLL current OleRegEnumFormatEtc: clsid 
		_: DATADIR_SET 
		_: resultReference.
	hresult = S_OK  " class or key not registered "
		ifFalse: [ OLEResultNotification signal: hresult ].
	^resultReference value!   
registeredControls
        " Answer the names of all the OLE controls in the system registry. "

	^self controlClassIDMap values asArray!  
getUserTypeAppName: clsid
		" Answer the name of the application servicing the class 
		specified by the CLSID <clsid> in a user-presentable string. 
		Used in the result text in dialogs."

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current OleRegGetUserType: clsid 
		_: USERCLASSTYPE_APPNAME
		_: resultReference.
	^resultReference value!
verbsEnumerator: clsid
		" Answer an enumerator that can be used to enumerate the object verbs
		registered in the registration database for the CLSID <clsid>. "

	| resultReference hresult |
	resultReference := ( IEnum forIID: IID_IEnumOLEVERB ) asValueReference.
	hresult := OLEDLL current OleRegEnumVerbs: clsid 
		_: resultReference.
	hresult = S_OK  " class or key not registered or no verbs "
		ifFalse: [ OLEResultNotification signal: hresult ].
	^resultReference value!   
serverNameOf: aCLSID
		" Answer the name of the object server application registered for <aCLSID>. "

    | classesRegistry clsidSection clsid clsidEntries 
	  serverKeys serverName |
    classesRegistry := self classesRegistry.
    clsidSection := classesRegistry at: 'CLSID'.
	serverKeys := #( 'InprocServer' 'InprocServer32' 'LocalServer' 'LocalServer32' ).
    clsidSection keysDo: [ :aKey |
        ( ( clsid := GUID clsidFromString: aKey ) notNil
        and: [ clsid = aCLSID ] )
            ifTrue: [
                clsidEntries := clsidSection at: aKey.
                clsidEntries associationsDo: [ :assoc |
                    ( serverKeys includes: assoc key )
                        ifTrue: [
                            serverName := assoc value.
                            classesRegistry close.
                            ^serverName ] ].
                ] ].
    classesRegistry close.
    ^nil!
getUserTypeShort: clsid
		" Answer the short type name of the class specified by the CLSID <clsid>
		in a user-presentable string.  Used in popup menus and the Links dialog. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current OleRegGetUserType: clsid 
		_: USERCLASSTYPE_SHORT
		_: resultReference.
	^resultReference value!
objectClassProgIDNames
        " Answer a list of the ProgID names of the OLE object classes
		registered in the system registration database. "

	^self objectClassNameMap keys asSortedCollection asArray
!
registeredControlNames
        " Answer the names of all the OLE controls in the system registry. "

	^self controlClassIDMap values asArray!  
objectClassIDMap
		" Answer a dictionary describing all the registered object classes
		on the system, with the CLSID as the key and the PROGID name
		as the value. "

	| classIDMap classesRegistry clsidEntry |
	classIDMap := Dictionary new.
	classesRegistry := self classesRegistry.
	classesRegistry associationsDo: [ :assoc |
		" pick out <ProgID> entries with associated <Progid>\CLSD subkey "
		( clsidEntry := classesRegistry at: assoc key, '\CLSID' ifAbsent: [ nil ]) notNil
			ifTrue: [ classIDMap at: clsidEntry value asGUID put: assoc key ] ].
	classesRegistry close.
	^classIDMap!   
verbs: clsid
		" Answer the object verbs registered in the registration database 
		for the CLSID <clsid>. "

	| anEnumerator contents |
	anEnumerator := self verbsEnumerator: clsid.
	anEnumerator isNil
		ifTrue: [ ^#( ) ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!  
setDataFormats: clsid
		" Answer the formats registered in the registration database as the supported formats
		which can be used to set the state of instances of the CLSID <clsid>. "

	| anEnumerator contents |
	anEnumerator := self setDataFormatsEnumerator: clsid.
	anEnumerator isNil
		ifTrue: [ ^#( ) ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!  
objectClassUserTypeNames
        " Answer a list of the descriptive names of the OLE object classes
		registered in the system registration database.
		Use the PROGID if no user descriptive name is available. "

    | classNameMap names |
    classNameMap := self objectClassNameMap.
    names := OrderedCollection new: classNameMap size.
    classNameMap associationsDo: [ :assoc |
        assoc value == nil
			ifTrue: [ names add: assoc key ]
			ifFalse: [ names add: assoc value ] ].
    ^names asSortedCollection asArray!
controlClassIDMap
        " Answer a dictionary describing all the registered OLE controls,
		with the CLSID as the key and the control name as the value. "

    | classIDMap classesRegistry clsidSection clsid clsidEntries clsidEntryNames |
    classIDMap := Dictionary new.
    classesRegistry := self classesRegistry.
    clsidSection := classesRegistry at: 'CLSID'.
    clsidSection associationsDo: [ :assoc |
        ( clsid := GUID clsidFromString: assoc key ) notNil
            ifTrue: [
                clsidEntries := clsidSection at: assoc key.
                clsidEntryNames := clsidEntries keys.
                ( clsidEntryNames includes: 'Control' )
                    ifTrue: [ classIDMap at: clsid put: assoc value ].
                        ] ].
    classesRegistry close.
    ^classIDMap! 
getMiscStatus: clsid aspect: dvAspect
		" Answer the miscellaneous status information from the system registry 
		for the DVASPECT value <dvAspect> of the CLSID <clsid>. "

    | resultReference hresult |
    resultReference := nil asValueReference.
    hresult := OLEDLL current OleRegGetMiscStatus: clsid 
		_: dvAspect 
		_: resultReference.
	hresult = S_OK  " class or key not registered "
		ifFalse: [ OLEResultNotification signal: hresult ].
	^resultReference value!   
getUserTypeFull: clsid
		" Answer the full type name of the class specified by the CLSID <clsid>
		in a user-presentable string. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current OleRegGetUserType: clsid 
		_: USERCLASSTYPE_FULL
		_: resultReference.
	^resultReference value!  
getDataFormatsEnumerator: clsid
		" Answer an enumerator that can be used to enumerate the formats
		registered in the registration database as the supported formats
		which can be used to obtain the state of instances of the CLSID <clsid>. "

	| resultReference hresult |
	resultReference := ( IEnum forIID: IID_IEnumFORMATETC ) asValueReference.
	hresult := OLEDLL current OleRegEnumFormatEtc: clsid 
		_: DATADIR_GET 
		_: resultReference.
	hresult = S_OK  " class or key not registered "
		ifFalse: [ OLEResultNotification signal: hresult ].
	^resultReference value!
classesRegistry
		" Answer the CLASSES branch of the system registry. 
		The client must close the registry when they are done. "

	^RegistrationDatabase classesRoot!
isClassRegistered: aCLSID
        " Answer whether the class identified by <aCLSID>
        is registered in the system registry. "

    | classesRegistry clsidDefinitionKey isRegistered |
    classesRegistry := self classesRegistry.
    clsidDefinitionKey := 'CLSID\', aCLSID asString.
    isRegistered := classesRegistry includesKey: clsidDefinitionKey.
    classesRegistry close.
    ^isRegistered!
getDataFormats: clsid
		" Answer the formats registered in the registration database as the supported formats
		which can be used to obtain the state of instances of the CLSID <clsid>. "

	| anEnumerator contents |
	anEnumerator := self getDataFormatsEnumerator: clsid.
	anEnumerator isNil
		ifTrue: [ ^#( ) ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!   
commonPrefixOf: aMoniker with: anotherMoniker
		" Answer a new moniker specifying the longest common prefix
		between <aMoniker> and <anotherMoniker>. "

	" Used in the implementation of a moniker class. "

	| resultReference hresult |
	resultReference := self new asValueReference.
	hresult := OLEDLL current MonikerCommonPrefixWith: aMoniker 
		_: anotherMoniker 
		_: resultReference.
	hresult = S_OK  " MK_E_NOPREFIX, MK_S_ME, MK_S_HIM, MK_S_US "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value!   
registerAsMultipleUseLocalServer
		" Register the receiver with OLE as a multiple-use local
		object server application. "

	self registerClassContext: CLSCTX_LOCAL_SERVER 
		flags: REGCLS_MULTIPLEUSE.!   
checkIsOLEAvailable
        " Private - determine whether the basic OLE support is available. "

	( File findFileName: OLEDLL fileName ) isNil
		ifTrue: [ ^false ].
    [ OLEDLL current ]
        on: Error
        do: [ ^false ].  " unable to open or wrong version "
	^true.!   
description
		" Answer a description of the receiver. "

	| type |
	type := self type.
	type isNil
		ifTrue: [ type := 'unknown moniker type' ].
	^type, ': ', self name!  
isSystemMoniker
		" Answer whether the receiver is a type of moniker whose
		implementation semantics are conceptually important to the binding process. "

	^( interface IsSystemMoniker: nil asValueReference ) = S_OK! 
isOLEInterfaceImplementation
		" Answer whether the receiver is an OLE interface implemented
		in this Smalltalk image. "

	^true!
invokeOleDraw: pUnknown _: dwAspect _: hdcDraw _: lprcBounds
        "Private - WINOLEAPI          OleDraw (
			LPUNKNOWN pUnknown, DWORD dwAspect, HDC hdcDraw,
			LPCRECT lprcBounds);"

    <api: OleDraw handle ulong ulong structIn hresult>
    ^self apiCallFailed!  
StgOpenStorage: aFileName _:pstgPriority _: grfMode _: snbExclude _: reserved _: resultReference
		" Open the compound file in the file system named <aFileName>
		with the access mode specified by the STGM flags <grfMode>.
		Obtain an IStorage interface on the new storage and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := IStoragePointer forReturnValue.
    hresult := self invokeStgOpenStorage: ( self asUnicodeParameter: aFileName )
         _: pstgPriority asParameter
        _: grfMode
        _: ( self asSNBParameter: snbExclude )
        _: reserved
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!
OleCreateFromFile: clsid _: aFileName _: iid _: renderopt _: aFormatEtc _: aClientSite _: aStorage _: resultReference
        " Create an embedded object from the specified file <fileName>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreateFromFile: clsid
        _: ( self asUnicodeParameter: aFileName )
        _: iid
        _: renderopt
        _: aFormatEtc
        _: aClientSite asParameter
        _: aStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult! 
decrementLockCount
		" Decrement the number of locks on the object server application.
		Answer the lock count. "

	^self lockCount: ( self lockCount - 1 )!  
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^self class iid!   
Release
		" Invoke the IUnknown::Release function. "

	^( functionHandlers at: 3 ) evaluate
! 
activeObjects
        " Answer a collection containing all the active objects which have been
        created during the current session. "

    ^ActiveObjectsRegistry isNil
        ifTrue: [ #( ) ]
        ifFalse: [ self activeObjectsRegistry ephemerons keys ]! 
fromAddress: anAddress
        "Answer an instance of the receiver with appropriate
         byte size and fill its contents from data at anAddress."

    | aGuid |
    aGuid := self newNullValue .
	aGuid replaceBytesFrom: 1
        to: aGuid size
        with: anAddress
        startingAt: 1.
    ^aGuid!  
interfacePointerClassForIID: anIID
		" Private - answer the interface pointer binding class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	iidEntry := self iidMap at: anIID " ptr, reference, impl "
		ifAbsent: [ ^nil ].
	^iidEntry at: 1! 
copy
		" Answer a copy of the receiver.  The copy is not separately
		reference counted and should not be released unless the
		it is explicitly reference counted. "

	^self class forBinding: self copyInterfaceBinding!   
finalizationRegistry
		"Private - Answer the WeakRegistry to be used for finalizing instances of the receiver."

    ^OLESessionManager allocatedInterfacesRegistry!   
isValid
		"Answer whether the receiver is a valid interface."

	^true! 
ProgIDFromCLSID: clsid _: resultReference
		" Obtain the ProgID string associated with the CLSID <clsid> 
		in the system registry and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := self createStringResultValue.
    hresult := self invokeProgIDFromCLSID: clsid _: resultValue.
    resultReference value: ( self stringFromResultValue: resultValue ).
	^hresult
!
registeredUnknown: anIUnknown
		" Private - set the separately reference counted
		IUnknown which was used to register the receiver with OLE. "

	registeredUnknown := anIUnknown.!   
allOwnedInterfaces
		" Private - answer a collection containing the reference-counted OLE interface pointers
		which are owned by this session. "

	^( self elementsInRegistry: self ownedInterfacesRegistry )
		"select: [ :aResource | aResource isOLEInterfacePointer ]"
!   
addressResultAtAddress: anExternalAddress put: anAddress
		" Private - store the address output argument value <anAddress> 
		into the caller-provided memory location at <anExternalAddress>. "

	anAddress isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress )
		bytesAtOffset: 0 
		put: anAddress asParameter.
	anAddress destroyReference.  " ownership of this memory transfers to the caller "!  
stringFromResultValue: anExternalAddress
		" Private - answer the string at address <anExternalAddress>. 
		The string pointer references the Unicode byte encoding of the string. 
		The memory containing the Unicode string is released.. "

	| aString |
	aString := ( UnicodeStringBuffer atAddress: anExternalAddress ) asString.
	anExternalAddress free.
	^aString !  
memoryAllocator
		" Private - answer the OLE memory allocator which is used to allocate 
		memory referenced by instances of the receiver. "

	^IMalloc sharedMemoryAllocator!
createOnAddress: aGlobalMemoryAddress deleteOnRelease: deleteOnRelease
		" Create a new ILockBytes on <aGlobalMemoryAddress>.  
		If <deleteOnRelease> is set the memory will be released by OLE 
		when the lock bytes is released. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current CreateILockBytesOnHGlobal: aGlobalMemoryAddress 
		_: deleteOnRelease 
		_: resultReference.
	( deleteOnRelease 
	and: [ aGlobalMemoryAddress isExternalAddress ] )
		ifTrue: [ aGlobalMemoryAddress doesNotNeedFinalization ].
	^resultReference value! 
classForIID: anIID
		" Answer the interface pointer which represents the interface
		specified by the interface ID GUID <anIID>.  Answer nil if the
		interface is not supported. "

	^self classForIID: anIID ifNone: [ nil ]!  
Drop: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Invoke the IDropTarget::DragEnter function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchDrop: anIDataObject _: grfKeyState _: aPoint _: resultReference )
!   
unpackElementBuffer: elementBuffer count: cElementsRetrieved
		" Private - unpack the <cElementsRetrieved> retrieved by Next into the <elementBuffer>, 
		which was created by #allocateElementBuffer. "

	| elements |
	elements := Array new: cElementsRetrieved.
	1 to: cElementsRetrieved do: [ :i |
		elements at: i 
			put: ( self unpackElement: i fromBuffer: elementBuffer ) ].
	^elements!
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
new
		" Answer a new instance of the receiver. "

	^super new needsFinalization!   
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^32!  
isOLEExternalAddress
        " Answer whether the receiver is an external memory address
        which was allocated by an OLE memory allocator. "

    ^false!   
createAntiMoniker
        " Answer a new instance of the receiver for a new anti moniker. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current CreateAntiMoniker: resultReference.
    ^resultReference value!   
setAddress: anExternalAddress
		" Private - set the receiver's VTable address to <anExternalAddress>. 
		Answer the receiver. "

	anExternalAddress isExternalAddress
		ifFalse: [ self error: 'interface pointer must be an external address' ].
	self setBytes: anExternalAddress contents.!  
invalidate
		"Set the receiver to be invalid."

	self resetResources.! 
destroyReference
		" Destroy this memory reference (without releasing it).
		This service is used to relinquish ownership of the memory. "

	self invalidate.!
classFactoryForCLSID: aGUID
		" Answer the class factory which has been registered with OLE
		for the CLSID <aGUID>.  Answer nil if not registered. "

	self registeredClassFactories do: [ :aClassFactory |
		aClassFactory objectCLSID = aGUID
			ifTrue: [ ^aClassFactory ] ].
	^nil!   
dispatchParseDisplayName: aBindContext 
	_: aDisplayName 
	_: nCharsConsumedReference 
	_: resultReference
		" Private - dispatch the IParseDisplayName::ParseDisplayName function. "

    ^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
        with: aBindContext
        with: aDisplayName
        with: nCharsConsumedReference
        with: resultReference )!  
ParseDisplayName: aBindContext 
	_: aDisplayName 
	_: nCharsConsumedReference 
	_: resultReference
		" Invoke the IParseDisplayName::ParseDisplayName function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: 
		( self dispatchParseDisplayName: aBindContext 
			_: aDisplayName 
			_: nCharsConsumedReference 
			_: resultReference )! 
invokeParseDisplayName: pbc _: pszDisplayName _: pchEaten _: ppmkOut
        "Private - invoke the IParseDisplayName::ParseDisplayName function for an external caller. "

	" HRESULT ParseDisplayName(
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ LPOLESTR pszDisplayName,
            /* [out] */ ULONG *pchEaten,
            /* [out] */ IMoniker **ppmkOut); "

    | hresult anIBindContext aDisplayName resultReference
      charsConsumedReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pbc = 0  " NULL interface pointer "
        ifTrue: [ ^E_INVALIDARG ].
    ( pszDisplayName isValid
    and: [ pchEaten isValid
    and: [ ppmkOut isValid ] ] )
        ifFalse: [ ^E_INVALIDARG ].
    anIBindContext := self interfaceAtAddress: pbc
        type: IBindCtx.
    aDisplayName := self stringAtAddress: pszDisplayName.
    self clearResultValueAtAddress: pchEaten.
    self clearResultValueAtAddress: ppmkOut.

    resultReference := nil asValueReference.
    charsConsumedReference := nil asValueReference.
    hresult := self dispatchParseDisplayName: anIBindContext
        _: aDisplayName
        _: charsConsumedReference
        _: resultReference.
    self ifOLETraceEnabled: [
		resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [
            self uLongResultAtAddress: pchEaten put: charsConsumedReference value.
            self interfaceResultAtAddress: ppmkOut put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'Moniker: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult!   
inverse
		" Answer the inverse of this moniker. "

	| resultReference hresult |
	resultReference := self class new asValueReference.
	hresult := interface Inverse: resultReference.
	hresult = S_OK   " MK_E_NOINVERSE "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value! 
callinDescriptorIndex
		" Private - answer the index in the external object table of the
		VTable descriptor array of the receiver.   This value is stored
		in the receiver's object state in external memory to allow the
		virtual machine callin processing to send a function callin
		invocation message to the receiver. "

	self hasExternalResources 
		ifFalse: [ ^nil ].
	^self externalObjectBody uLongAtOffset: 8
!
enumeratorIIDFor: aClass
		" Answer the IID of the enumerator interface which operates
		on elements of type <aClass>. "

	^self elementTypeMap keyAtValue: aClass ifAbsent: [ nil ]! 
invokeCoGetMalloc: dwMemContext _: ppMalloc
		"Private - WINOLEAPI  CoGetMalloc(DWORD dwMemContext, LPMALLOC FAR* ppMalloc);"

	| hresult |
	<api: CoGetMalloc ulong structOut hresult>
	hresult := self apiFailureReason.
	hresult = E_INVALIDARG
		ifTrue: [ ^hresult ].
	^self apiCallFailed!  
startingSession
		"Private - The session is being started.  Invalidate any interface pointers
		in the saved memory image, since they are no longer valid. "

	self resetResources.!  
ParseDisplayName: aBindContext 
	_: aDisplayName 
	_: nCharsConsumedReference 
	_: resultReference
		" Invoke the IParseDisplayName::ParseDisplayName function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue nCharsConsumedValue hresult |
    resultValue := IMonikerPointer forReturnValue.
	nCharsConsumedValue := ExternalLong new.
    hresult := self invokeParseDisplayName: aBindContext asParameter
        _: ( self asUnicodeParameter: aDisplayName )
        _: nCharsConsumedValue
        _: resultValue asParameter.
    resultReference value: resultValue.
	nCharsConsumedReference value: nCharsConsumedValue asUnsignedInteger.
    ^hresult!   
invokeParseDisplayName: pbc _: pszDisplayName _: pchEaten _: ppmkOut
		" Private - invoke the IParseDisplayName::ParseDisplayName function. "

	" HRESULT ParseDisplayName(
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ LPOLESTR pszDisplayName,
            /* [out] */ ULONG *pchEaten,
            /* [out] */ IMoniker **ppmkOut); "

    <ole: 3 handle structIn structOut structOut hresult>
    ^self vtableDispatchFailed! 
forReturnValueWithIID: anIID
		" Answer a new instance of the OLE interface identified by the GUID <anIID> 
		which is to be used to obtain an OUT parameter return value.  
		Since in general the ownership responsibility of an OUT parameter 
		is transferred to the caller, mark the interface as needing finalization
		to ensure that it is released by the caller. "

	^( self classForIID: anIID ifNone: [ IAnonymousPointer ] ) new
		iid: anIID;
		yourself! 
interfaceBinding
		" Answer the interface binding which provides function invocation services 
		for the receiver. "

	^self! 
OleRegEnumVerbs: clsid _: resultReference
		" Obtain an enumerator of the supported object verbs defined in
		the registration database for the CLSID <clsid>
		and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumOLEVERB.
	hresult := self invokeOleRegEnumVerbs: clsid
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!
isOLEInterfacePointer
		" Answer whether the receiver is an OLE interface referencing
		a VTable in external memory. "

	^false!  
asHexDescriptionString
		" Answer a String representation of the hex bytes of the receiver. "

	^self class name, ' ', self hexByteString

! 
constructElementTypeMap
		" Private - answer the map from an enumeration element type
		to the OLE interface IID which enumerates elements of that type. "

	^Dictionary new
		" interface enumerators "
		at: IID_IEnumMoniker put: IMoniker;
		at: IID_IEnumUnknown put: IUnknown;
		" structure enumerators "
		at: IID_IEnumFORMATETC put: OLE_FORMATETC;
		at: IID_IEnumString put: OLE_LPOLESTR;
		at: IID_IEnumSTATDATA put: OLE_STATDATA;
		at: IID_IEnumSTATSTG put: OLE_STATSTG;
		at: IID_IEnumOLEVERB put: OLE_OLEVERB;
		yourself! 
registerClassContext: classContext flags: flags
		" Register the receiver with OLE with the specified execution context <classContext>
		and connection flags <flags>. "

	" The class execution context specifies how the object server application executes:
		CLSCTX_INPROC_SERVER, CLSCTX_INPROC_HANDLER, or
		CLSCTX_LOCAL_SERVER
	The flags specify whether the factory supports single or multiple use:
		REGCLS_SINGLEUSE, REGCLS_MULTIPLEUSE, REGCLS_MULTI_SEPARATE
	"

	self class registerClassFactory: self
		classContext: classContext
		flags: flags.!
printValueOn: aStream
		" Private - append a text description of the receiver's value to <aStream> "

	aStream nextPutAll: ' on: '.
	value printOn: aStream.
!   
value
		" Answer the value. "

	^value!
value: aValue
		" Set the value of the receiver to <aValue>. "

	value := aValue.! 
printOn: aStream
		" Append a text description of the receiver to <aStream> "

	super printOn: aStream.
	self printValueOn: aStream.
!   
clipboardContainsObject
		" Answer whether the system clipboard contains an OLE data object. "

	| anIDataObject |
	anIDataObject := self getClipboardObject.
	anIDataObject isNil
		ifTrue: [ ^false ].
	anIDataObject release.
	^true!  
getClipboardObject
		" Answer a new instance of the receiver referencing
		the OLE data object contained in the system clipboard.
		Answer nil if the clipboard does not contain an OLE data object. "

    | resultReference hresult |
    resultReference := self new asValueReference.
    [ hresult := OLEDLL current OleGetClipboard: resultReference ]
		on: OLEError
		do: [ ^nil ].
	hresult = S_OK
		ifFalse: [ OLEResultNotification hresult: hresult ].
    ^resultReference value!
flushClipboard
		" Empty the clipboard. "

	OLEDLL current OleFlushClipboard.! 
fromDisplayName: displayName
	bindContext: aBindContext
	charsConsumed: nCharsConsumedReference
		" Answer a new instance of the receiver for the object referenced by <displayName>. 
		Set the value of the caller's reference object <nCharsConsumedReference>
		to the number of characters consumed from the display name. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current MkParseDisplayName: aBindContext
        _: displayName
        _: nCharsConsumedReference
        _: resultReference.
    ^resultReference value!   
aboutToExitSession
		"Private - Exiting the session.  All allocated interfaces should have already been released
		at this point; cannot release now because memory allocators and OLEDLL are closed. "

	self hasExternalResources
		ifTrue: [ OLEDevelopmentWarning signal: 'Unreleased OLE interface impl found at image exit: ', self printString ].!
exit
		" Private - the session is being exited.  Release OLE resources owned or allocated
		during the current session. "

	" forcibly close any container windows, bypassing any save prompting "
	self containerWindows do: [ :aView |
		" must be done before window closes to handle IPA site properly "
		aView container close.
		" unpleasant but necessary clone of private TopPane implementation logic "
		aView closeView.
		aView triggerEvent: #closed ].

	self releaseResources.

	IMalloc releaseMemoryAllocators.  " release references to the task memory allocators "
	IRunningObjectTable releaseCurrent.  " release the reference to the running object table. "
	OLEDLL closeCurrent.
!
initializeResourceRegistries
		" Private - initialize the finalization registries for tracking OLE resources. "

	self 
		allocatedInterfacesRegistry: self constructFinalizationRegistry;
		ownedInterfacesRegistry: self constructFinalizationRegistry;
		ownedMemoryRegistry: self constructFinalizationRegistry.!   
addressAtOffset: anInteger put: anExternalAddress
        "Set the bytes starting at anInteger (0 based offset)
        from the contents of ,anExternalAddress.."

	super addressAtOffset: anInteger
		put: ( anExternalAddress isNil
			ifTrue: [ ExternalAddress nullValue ]
			ifFalse: [ anExternalAddress ] ).
!
WriteFmtUserTypeStg: anIStorage _: cf _: userType
		" Write the specified clipboard format and current user type to the storage <anIStorage>.
		Raise an exception if an error occurs.  Answer the result code. "

	" WriteClassStg must be called before WriteFmUserTypeStg, which is
	called in an object's implementation of IPersistStorage::Save and by
	document-level objects that use structured storage for their persistent
	representation in their save sequence. "

	^self invokeWriteFmtUserTypeStg: anIStorage asParameter 
		_: cf
		_: ( self asUnicodeParameter: userType )
!   
isOLEInterfaceBinding
		" Answer whether the receiver is an OLE interface binding
		which provides direct access to the raw interface functions
		of an OLE interface. "

	^false!   
supportsEnumeratorIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^self elementTypeMap keys includes: anIID! 
asUnicode
        "Answer a Unicode copy of the receiver"

	^self! 
installUnimplementedDispatchHandlers
		" Configure the receiver's interface function dispatch bindings
		with a default set of VTable function handlers which
		provide unimplemented-function semantics. "

	self functionHandlers: (
		( Array new: self vtableSize )
			atAllPut: self unimplementedFunctionDispatchHandler )
!
isContainerSupportAvailable
        " Answer whether the OLE container support is available. "

	^Smalltalk platformIsWin32
		and: [ OperatingSystem isWin32s not ]!  
name
		" Answer the display name of this moniker. "

	| resultReference aBindContext |
	resultReference := nil asValueReference.
	aBindContext := IBindCtx newBindContext.
	interface GetDisplayName: aBindContext _: nil _: resultReference.
	aBindContext release.
	^resultReference value! 
CoCreateGuid: resultReference
		"Generate a new GUID and store it into <resultReference>.  
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeCoCreateGuid: resultValue.
	resultReference value: resultValue.
	^hresult
	!   
load: aStorage
		" Load the object from the storage <aStorage> into memory or the running state.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Load: aStorage! 
handsOffStorage
		" Release the object's storage and enter the hands-off storage state.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface HandsOffStorage! 
usesStorage
		" Answer whether the receiver operates on an IStorage. "

	^true!
saveCompleted: aStorage
		" The object save to <aStorage> has been completed.  Terminate both the
		no-scribble and hands-off mode, returning the object to normal storage mode.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface SaveCompleted: aStorage!   
saveCompleted
        " The object has been saved to its backing storage.
        Terminate both the no-scribble and hands-off mode,
        returning the object to normal storage mode.
        Raise an exception if an error occurs.  Answer the result code. "

    ^interface SaveCompleted: nil! 
initNew: aStorage
		" Initialize the storage object <aStorage>.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface InitNew: aStorage!   
saveTo: anIStorage sameAsLoad: fSameAsLoad
		" Save the transacted-mode receiver to the storage object <anIStorage>.
		The boolean <fSameAsLoad> is TRUE if <anIStorage> 
		is the same storage object from which the object was loaded or created;
		it is FALSE if <anIStorage> is a different storage object. "

	OLEDLL current OleSave: self
        _: anIStorage
        _: fSameAsLoad.
    self saveCompleted.! 
save: aStorage
		" Save the object to the storage <anIStorage>, including any nested objects,
		and clear its dirty flag.  The storage is the one from which the object
		was loaded or created. "

	interface Save: aStorage _: true.!  
saveToAlternateStorage: aStorage
		" Save the object to the storage <anIStorage>, including any nested objects,
		and clear its dirty flag.  The storage is not the one from which the object
		was loaded or created. "

	interface Save: aStorage _: false.!   
isDirty
		" Answer whether the object has been changed since it was last saved. "

	^( interface IsDirty ) = S_OK! 
resetServerState
		" Private - reset the object server state. "

	self 
		lockCount: 0;
		resetActiveObjectsRegistry;
		resetClassFactoryRegistry.! 
newTemporaryInterfacePointerAtAddress: anExternalAddress
		" Answer a new instance of the receiver from <anExternalAddress>
		which is not separately reference counted and should not be released
		by the caller.  The interface pointer is does not use finalization. "

	^self newTemporaryInterfacePointer
		setAddress: anExternalAddress;
		yourself!   
asString
        " Answer the string referenced by the receiver. "

    ^self string!  
getString
		" Private - get the string value of the Unicode string
		referenced by the receiver. "

	^( UnicodeStringBuffer atAddress: self contents ) asString!  
string: aString
		" Private - set the string referenced by the receiver. "

	string := aString.!   
contents: aValue
        "Set the contents of the receiver to <aValue>."

	aValue isExternalAddress
		ifFalse: [ self error: 'LPOLESTR must reference an external address' ].
	super contents: aValue.!  
releaseResources
		" Private - release resources owned by the receiver. "

	self releaseContents.
	super releaseResources.!   
string
		" Answer the string referenced by the receiver. "

	string isNil
		ifTrue: [ self string: self getString ].
	^string!   
asInterfacePointer
        " Answer an interface pointer for the receiver's VTable in external memory.
        Note that this is a non-ref-counted copy of an interface pointer and as
        such must be used with some care. "

	^self class interfacePointerClass
        newTemporaryInterfacePointerAtAddress: self externalAddress! 
supportsIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^self iid = anIID!   
Stat: resultReference _: grfStatFlag
		" Invoke the ILockBytes::Stat function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEStructure forReturnValue: #STATSTG.
	hresult :=  self invokeStat: resultValue 
		_: grfStatFlag.
	resultReference value: resultValue.
	^hresult! 
invokeSetSize: cb
		" Private - invoke the ILockBytes::SetSize function. "

	" HRESULT SetSize(
            /* [in] */ ULARGE_INTEGER cb);  "

	<ole: 6 structValue hresult>
	^self vtableDispatchFailed!  
LockRegion: offset _: count _: lockType
		" Invoke the ILockBytes::LockRegion function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeLockRegion: ( WinLargeInteger fromUnsignedInteger: offset ) asParameter
		_: ( WinLargeInteger fromUnsignedInteger: count ) asParameter
		_: lockType!
invokeLockRegion: libOffset _: cb _: dwLockType
		" Private - invoke the ILockBytes::LockRegion function. "

	" HRESULT LockRegion(
            /* [in] */ ULARGE_INTEGER libOffset,
            /* [in] */ ULARGE_INTEGER cb,
            /* [in] */ DWORD dwLockType); "

	<ole: 7 structValue structValue ulong hresult>
	^self vtableDispatchFailed! 
UnlockRegion: offset _: count _: lockType
		" Invoke the ILockBytes::UnlockRegion function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self  invokeUnlockRegion: ( WinLargeInteger fromUnsignedInteger: offset ) asParameter 
		_: ( WinLargeInteger fromUnsignedInteger: count ) asParameter 
		_: lockType!   
invokeStat: pstatstg _: grfStatFlag
		" Private - invoke the ILockBytes::Stat function. "

	" HRESULT Stat(
            /* [out] */ STATSTG *pstatstg,
            /* [in] */ DWORD grfStatFlag); "

	<ole: 9 structOut ulong hresult>
	^self vtableDispatchFailed!   
WriteAt: offset _: buffer _: count _: resultReference
		" Invoke the ILockBytes::WriteAt function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultReference notNil 
		ifTrue: [ resultValue := ExternalLong new ].
	hresult := self invokeWriteAt: ( WinLargeInteger fromUnsignedInteger: offset ) asParameter
		_: buffer 
		_: count
		_: resultValue.
	resultReference notNil
		ifTrue: [ resultReference value: resultValue asInteger ].
	^hresult!
invokeReadAt: ulOffset _: pv _: cb _: pcbRead
		" Private - invoke the ILockBytes::ReadAt function. "

	" HRESULT ReadAt(
            /* [in] */ ULARGE_INTEGER ulOffset,
            /* [in] */ void *pv,
            /* [in] */ ULONG cb,
            /* [out] */ ULONG *pcbRead); "

	<ole: 3 structValue structOut ulong structOut hresult>
	^self vtableDispatchFailed!
Flush
		" Invoke the ILockBytes::Flush function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Flush( void); "

	<ole: 5 hresult>
	^self vtableDispatchFailed!   
ReadAt: offset _: buffer _: count _: resultReference
		" Invoke the ILockBytes:ReadAt function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultReference notNil 
		ifTrue: [ resultValue := ExternalLong new ].
	hresult := self invokeReadAt: ( WinLargeInteger fromUnsignedInteger: offset ) asParameter
		_: buffer 
		_: count
		_: resultValue.
	resultReference notNil
		ifTrue: [ resultReference value: resultValue asInteger ].
	^hresult!
invokeWriteAt: ulOffset _: pv _: cb _: pcbWritten
		" Private - invoke the ILockBytes::WriteAt function. "

	" HRESULT WriteAt(
            /* [in] */ ULARGE_INTEGER ulOffset,
            /* [in] */ const void *pv,
            /* [in] */ ULONG cb,
            /* [out] */ ULONG *pcbWritten); "

	<ole: 4 structValue structIn ulong structOut hresult>
	^self vtableDispatchFailed!  
SetSize: newSize
		" Invoke the ILockBytes::SetSize function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSetSize: ( WinLargeInteger fromUnsignedInteger: newSize ) asParameter!
invokeUnlockRegion: libOffset _: cb _: dwLockType
		" Private - invoke the ILockBytes::UnlockRegion function. "

	" HRESULT UnlockRegion(
            /* [in] */ ULARGE_INTEGER libOffset,
            /* [in] */ ULARGE_INTEGER cb,
            /* [in] */ DWORD dwLockType); "

	<ole: 8 structValue structValue ulong hresult>
	^self vtableDispatchFailed!   
GetHGlobalFromStream: anIStream _: resultReference
		" Obtain the global memory handle from a stream created by CreateStreamOnHGlobal.
		Raise an exception if an error occurs.  Answer the result code. "

	| ulongHGlobal hresult |
	ulongHGlobal := ExternalLong new.
	hresult := self invokeGetHGlobalFromStream: anIStream asParameter 
		_: ulongHGlobal.
	resultReference value: 
		( self globalMemoryAddressFromHandleResult: ulongHGlobal asUnsignedInteger ).
	^hresult! 
iid: anIID
		" Private - set the the interface ID which uniquely identifies instances 
		of the receiver to the GUID <anIID>. "

 	( iid notNil and: [ anIID notNil and: [ iid ~= anIID ] ] )
		ifTrue: [   " maybe initialization bug that developer should know about "
			OLEDevelopmentWarning signal: 'Changing the IID of ', self name,
				' from ', iid printString, ' to ', anIID printString, '.' ].
	iid := anIID.!
invokeCoHasStrongExternalConnections: pUnk
        "Private - WINOLEAPI_(BOOL) CoHasStrongExternalConnections(LPUNKNOWN pUnk);"

    <api: CoHasStrongExternalConnections handle boolean>
    ^self apiCallFailed!
printOn: aStream
		" Append a text description of the receiver to <aStream> "

	super printOn: aStream.
	interface notNil
		ifTrue: [ aStream nextPutAll: ' on: ', interface printString ].! 
elementTypeMap
		" Private - answer the dictionary which maps element types to
		the IID of the interface which enumerates elements of that type. "

	^ElementTypeMap!
composeWith: monikerToRight
		" Answer a new composite moniker formed from the receiver and <monikerToRight>. "

	| resultReference |
	resultReference := self class new asValueReference.
	interface ComposeWith: monikerToRight _: false _: resultReference.
	^resultReference value! 
exceptionForMethod: method arguments: arguments
    "Private - Answer an exception for the given method and arguments"

    | failureReason |

    failureReason := self dispatchFailureReason.

	failureReason = 1
		ifTrue: [ ^Error new messageText: 'null interface pointer' ].
	failureReason = 2
		ifTrue: [ ^Error new messageText: 'null VTable pointer' ].

    failureReason = 8 
        ifTrue: [ 
            ^DynamicLinkLibrary 
                exceptionForArgumentErrorIn: method 
                arguments: arguments
                ifNone: [ Error new messageText: 'API argument error' ] ].

	( DynamicLinkLibrary resultTypeOfMethod: method ) = #hresult
        ifTrue: [   " HRESULT error code returned "
	        ( HRESULT succeeded: failureReason )
		        ifTrue: [    " VM problem, should not be here "
                     ^Error new messageText: 
                         'Unexpected HRESULT primitive failure ( ',
                         ( failureReason radix: 16 ), ' )' ].
            ^OLEError new hresult: failureReason ].
	^Error new messageText: 'unknown interface function error'!   
load: aStream
		" Initialize an object previously stored with the Save operation
		from the stream <aStream>.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Load: aStream!
usesStream
		" Answer whether the receiver operates on an IStream. "

	^true!  
maximumSize
		" Answer the maximum size of the stream needed to save the object. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetSizeMax: resultReference.
	^resultReference value! 
saveAndLeaveDirty: aStream
		" Save a copy of the object to the stream <aStream>.  Do not clear its dirty flag. "

	interface Save: aStream _: false.! 
initNew
		" Notify the object that it is being newly created.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface InitNew!   
save: aStream
		" Save a copy of the object to the stream <aStream> and clear its dirty flag. "

	interface Save: aStream _: true.!
isDirty
		" Answer whether the object has been changed since it was last saved. "

	^( interface IsDirty ) = S_OK! 
saveToStream: anIStream
        " Save the the receiver to the stream object <anIStream>. 
        The CLSID and the object's persistent state are stored. "

	OLEDLL current OleSaveToStream: self _: anIStream.!
isOLEInterfacePointer
		" Answer whether the receiver is an OLE interface referencing
		a VTable in external memory. "

	^interface isOLEInterfacePointer!
invokeOleGetAutoConvert: clsidOld _: pClsidNew
        "Private - WINOLEAPI OleGetAutoConvert(
            REFCLSID clsidOld, LPCLSID pClsidNew);"

    <api: OleGetAutoConvert structIn structOut hresult>
    ^self apiCallFailed! 
CreateAntiMoniker: resultReference
		" Create a new anti-moniker and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeCreateAntiMoniker: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
!  
windowHandleFromHandle: ulongHandle
		" Private - answer the WindowHandle for the callin argument value <ulongHandle>. "

    ulongHandle = 0
		ifTrue: [ ^nil ].
	^WindowHandle fromInteger: ulongHandle!   
isInUse
		" Answer whether the object server application is still in use
		(i.e., there is an outstanding lock count on the object server application
		or objects created by a class factory during this session are still in use). "

	^self lockCount > 0 or: [ self activeObjectCount > 0 ]! 
name: anInteger
		" Answer the name of the HRESULT value <anInteger>.  
		Answer nil if the name is not known. "

	^self name: anInteger ifAbsent: [ nil ]!   
getFacility: hresult
        " Answer the facility code field of <hresult>. "

	" #define HRESULT_FACILITY(hr)  (((hr) >> 16) & 0x1fff) "
	" #define SCODE_FACILITY(sc)    (((sc) >> 16) & 0x1fff) "
	^( hresult bitShift: -16 ) bitAnd: 16r1FFF!
osErrorMessage: hresult
		" Answer the operating system error message for the HRESULT value <hresult>. "

	^[ OperatingSystem getErrorMessage: hresult ]
		on: Error
		do: [ ^'(unknown error)' ]!   
getCode: hresult
        " Answer the status code field of <hresult>. "

	" #define HRESULT_CODE(hr)    ((hr) & 0xFFFF) "
	" #define SCODE_CODE(sc)      ((sc) & 0xFFFF) "
	^hresult bitAnd: 16rFFFF!
name: anInteger ifAbsent: aBlock
		" Answer the name of the HRESULT value <anInteger>.  
		Answer the result of evaluating <aBlock> if the name is not known. "

	| preferredNames |
	self statusCodesDictionary isNil
		ifTrue: [ ^aBlock value ].  " pool only available in development environment "
	preferredNames := Dictionary new.  " establish preferred names for duplicate codes "
	#( 'DATA_E_FORMATETC' 'E_DRAW' 'S_OK' )
		do: [ :aName |
			preferredNames 
				at: ( self statusCodesDictionary at: aName ) 
				put: aName ].
	^preferredNames at: anInteger
		ifAbsent: [ self statusCodesDictionary keyAtValue: anInteger
			ifAbsent: aBlock ]!
succeeded: hresult
        " Answer whether <hresult> is a success return code. "

	" #define SUCCEEDED(Status) ((HRESULT)(Status) >= 0) "
    ^hresult < 16r80000000!
description: hresult
		" Answer a textual description of the HRESULT value <hresult>. "

	^( self osErrorMessage: hresult ), 
		' ( HRESULT ', ( self nameOrHexString: hresult ), ' )'.!  
statusCodesDictionary: aDictionary
		" Private - set the status code definition dictionary. "

	StatusCodesDictionary := aDictionary.! 
getSeverity: hresult
        " Answer the severity code field of <hresult>. "

	" #define HRESULT_SEVERITY(hr)  (((hr) >> 31) & 0x1) "
	" #define SCODE_SEVERITY(sc)    (((sc) >> 31) & 0x1) "
	^( hresult bitShift: -31 ) bitAnd: 16r1! 
isError: hresult
        " Answer whether <hresult> is an error return code. "

	" #define IS_ERROR(Status) ((unsigned long)(Status) >> 31 == SEVERITY_ERROR) "
    ^hresult >= 16r80000000!  
nameOrHexString: anInteger
		" Answer the name of the HRESULT value <anInteger>.  
		Answer the hex representation of the result code if the name is not known. "

	^self name: anInteger ifAbsent: [ anInteger radix: 16 ]!  
new
        " Disallow the instantiation of HRESULT instances.
		This is an abstract class which provides general services.
		An HRESULT value is represented as a 32-bit integer. "

    ^self invalidMessage
!
statusCodesDictionary
		" Private - answer the status code definition dictionary. "

	^StatusCodesDictionary!  
failed: hresult
        " Answer whether <hresult> is an error return code. "

	" #define FAILED(Status) ((HRESULT)(Status)<0) "
    ^hresult >= 16r80000000! 
severity: severity facility: facility code: code
		" Answer the HRESULT value with the specified values in each field. "

	" #define MAKE_HRESULT(sev,fac,code) \
		((HRESULT) (((unsigned long)(sev)<<31) | ((unsigned long)(fac)<<16) | ((unsigned long)(code))) ) "
	^( severity bitShift: 31 ) + (facility bitShift: 16 ) + code


!  
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^16!  
setBytes: aByteObject
		" Private - set the receiver's VTable address to <aByteObject>. 
		Answer the receiver. "

	self isValid
		ifTrue: [ self error: 'cannot reset existing interface pointer' ].
	aByteObject size = self size
		ifFalse: [ self error: 'incorrect size' ].
	self 
        replaceFrom: 1
        to: aByteObject size
        with: aByteObject
        startingAt: 1.! 
startingSession
		"Private - The session is being started.  Invalidate interface pointers
		in the saved memory image, since they are no longer valid. "

	self invalidate.!  
fromBytes: aByteArray
		"Answer a new instance of the receiver whose bits are set to <aByteArray> (16 bytes)."

	aByteArray size ~= self sizeInBytes
		ifTrue: [ self error: 'incorrect size for GUID' ].
	^self newNullValue
		replaceBytes: self sizeInBytes with: aByteArray;
		yourself!   
invokeCoFileTimeToDosDateTime: lpFileTime _: lpDosDate _: lpDosTime
        "Private - WINOLEAPI_(BOOL) CoFileTimeToDosDateTime(
                 FILETIME FAR* lpFileTime, LPWORD lpDosDate, LPWORD lpDosTime); "

    <api: CoFileTimeToDosDateTime structIn structOut structOut boolean>
    ^self apiCallFailed! 
validateDispatchHandlers
		" Validate the registered interface function dispatch handlers.
		Ensure as far as can be determined that the handlers are consistent
		with the function for which they are registered. 
		Display a warning message for any problems that are found. "

	| eptDescriptions aHandler eptDescription|
	eptDescriptions := self vtableDescription.
	1 to: self functionHandlers size do: [ :i |
		aHandler := self functionHandlers at: i.
		aHandler isNil
			ifTrue: [
				MessageBox warning:
					self class name, ' has no handler registered for ',
					eptDescription name, '.' ]
			ifFalse: [ aHandler isMessage
				ifTrue: [
					eptDescription := eptDescriptions at: i.
					( aHandler receiver respondsTo: aHandler selector )
						ifFalse: [
							MessageBox warning:
								self class name, ' interface dispatch problem for ',
								eptDescription name, ': ',
								aHandler receiver printString,
								' does not implement #', aHandler selector, '.' ].
					self class validateHandler: aHandler
						for: eptDescription ] ].
				].!   
invokeGetHGlobalFromStream: pstm _: phglobal
		"Private - WINOLEAPI GetHGlobalFromStream (
			LPSTREAM pstm, HGLOBAL FAR* phglobal);"

    <api: GetHGlobalFromStream handle structOut hresult>
    ^self apiCallFailed! 
fromString: aString
		"Answer a new instance of the receiver which corresponds to the
		platform string format representation of a GUID in <aString>.
		E.g. '{12345678-1234-1234-1234-123456789012}' "

	^self fromUnicode: aString asUnicode
!
interfaceAtOffset: anInteger put: anInterface
        " Set the interface pointer at offset <anInteger> in the receiver to <anInterface>. "

    anInterface isNil
        ifTrue: [ self bytesAtOffset: anInteger put: ( ByteArray new: 4 ) ]
        ifFalse: [ self bytesAtOffset: anInteger put: anInterface asInterfacePointer ].!  
interfacePointerClass
		" Private - answer the interface pointer class which is referenced
		by instances of the receiver. "

	^OLEInterfacePointer classForIID: self iid!
release
        "Free and release all resources."

    self isValid
        ifTrue: [ self memoryAllocator free: self ].
    super release.
!   
OleSaveToStream: anIPersistStream _: anIStream
        " Save an object in <anIPersistStream> to the stream object <anIStream>.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeOleSaveToStream: anIPersistStream asParameter
        _: anIStream asParameter!
vtableSize
		" Answer the number of interface function entry points
		defined in the receiver's callin VTable functions. "

	^self vtable size!   
newTemporaryInterfacePointer
        "Answer a new OLE interface pointer which the client asserts
		is a temporary copy and does not need to be reference counted. "

      ^super new!   
dragTargetGlobal
        "Enable the receiver as an OLE drag source."

    self dragTarget.
    self dragSessionClass: WinDragDropSession




!  
createTemporaryStream
		" Create a temporary stream in global memory
		Answer a new instance of the receiver on the storage object.
		The memory will be released when the stream is released. "

	^self createOnAddress: nil deleteOnRelease: true! 
registerIID
        " Private - register the receiver as the interface class for its IID.
		Do nothing for the receiver - its superclass IStream is correctly
		registered as the class for the (shared) IID. "!   
removeIID
        " Private - remove the registration of the receiver as the interface class for its IID.
		Do nothing for the receiver - its superclass IStream manages the registration
		for the (shared) IID. "!   
createOnAddress: aGlobalMemoryAddress deleteOnRelease: deleteOnRelease
		" Answer a new instance of the receiver which is an IStream 
		on <aGlobalMemoryAddress>.  If <deleteOnRelease> is set
		the memory will be released by OLE when the stream is released. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current CreateStreamOnHGlobal: aGlobalMemoryAddress 
		_: deleteOnRelease 
		_: resultReference.
	( deleteOnRelease 
	and: [ aGlobalMemoryAddress isExternalAddress ] )
		ifTrue: [ aGlobalMemoryAddress doesNotNeedFinalization ].
	^resultReference value!
on: aVariableByteObject
        " Answer a new instance of the receiver which is an IStream
        on a newly allocated block of global memory whose contents
        are initialized with the data in <aVariableByteObject>.
        The memory will be released when the stream is released. "

    | nBytes anIStream |
    aVariableByteObject isByteArray
        ifFalse: [   " strings not yet supported (trailing null philosophy not yet specified) "
            self error: 'must be ByteArray' ].
    nBytes := aVariableByteObject size.
    anIStream := self createTemporaryStream.
    "self ASSERT: anIStream size = 0."
    anIStream asByteStream
        putBytesFrom: aVariableByteObject
            from: 1 to: nBytes;
        reset.
	"self ASSERT: ( anIStream position = 0 and: [ anIStream size = nBytes ] )."
    ^anIStream
!   
sessionExportsResources
		" Private - answer whether the session exports resources.
		Ignore resources which are handled specially. "

	^self allAllocatedInterfaces notEmpty!
createItemMoniker: itemName delimiterString: delimiterString
        " Create a new moniker for the item named <itemName> using the given <delimiterString>.
        Answer a new instance of the receiver on the item moniker. "

    | resultReference |
    resultReference := self new asValueReference .
    OLEDLL current CreateItemMoniker: delimiterString
		_: itemName
        _: resultReference.
    ^resultReference value!
memoryAllocator
		" Private - answer the OLE memory allocator which owns the receiver. "

	^self class memoryAllocator!
CoGetMalloc: dwMemContext _: resultReference
		"Obtain an IMalloc interface for the OLE memory allocator specified
		by the integer <dwMemContext> and store it into <resultReference>.  
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMallocPointer forReturnValue.
	hresult := self invokeCoGetMalloc: dwMemContext 
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!
OleSetClipboard: anIDataObject
		" Put <anIDataObject> on the clipboard.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeOleSetClipboard: anIDataObject asParameter
!  
interfaceReferenceClass
		" Private - answer the OLE interface reference class for the receiver. "

	^self class interfaceReferenceClass!  
hexByteStringOn: aStream
		" Append a string describing the bytes of the receiver in hexadecimal notation
		to <aStream>. "

	| aByte |
	aStream nextPutAll: '#[ '.
	1 to: self size do: [ :i |
		aByte := self at: i.
		aStream nextPutAll: ( aByte <= 8
			ifTrue: [ aByte printString ]
			ifFalse: [ aByte printStringRadix: 16 ] ).
		aStream space ].
	aStream nextPut: $].
!  
dispatchDragLeave
		" Private - dispatch the IDropTarget::DragLeave function. "

    ^( functionHandlers at: 6 ) evaluate
!   
logReturnValue: returnValueDescription
        " Private - log callback exit to debug trace log. "

    self oleTRACE: '    ', ( returnValueDescription isString
        ifTrue: [ returnValueDescription ]
        ifFalse: [ returnValueDescription printString ] ).
!
on: anObject selectors: selectors
		"Answer a new instance of the receiver which supports its interface on <anObject>
		using <selectors> as the interface function handlers to delegate processing
		responsibility to the implementing object.  The <selectors> list must be exact match
		in size, order, and argument count to the interface VTable function layout. "

	^self forBinding: 
		( ( self interfaceImplementationClass for: anObject selectors: selectors )
			iid: anObject enumeratorIID;
			yourself )!  
invokeAddRef
		"Private - invoke the IUnknown::AddRef function for an external caller. "

	" ULONG AddRef( void); "

	| newReferenceCount |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	newReferenceCount := self AddRef .
	self ifOLETraceEnabled: [
		self logReturnValue: 'Ref count: ', newReferenceCount printString ].
	^newReferenceCount!  
interfaceBinding
		" Answer the interface binding which provides function invocation services 
		for the receiver. "

	^interface!
isOLEInterface
		" Answer whether the receiver is an OLE interface. "

	^true! 
forIID: anIID binding: anInterfaceBinding elementClass: aClass
		"Private - answer a new instance of the receiver with IID <anIID>
		which uses the callin/callout binding <anInterfaceBinding> to 
		enumerate interface pointer or data structure elements of type <aClass>. "

	^self new
		iid: anIID;
		interfaceBinding: anInterfaceBinding;
		elementClass: aClass;
		yourself!   
elementNames
		" Answer the display names of the elements of a composite moniker. "

	| elements names |
	elements := self elements.
	names := elements collect: [ :aMoniker |
		aMoniker name ].
	elements do: [ :aMoniker | aMoniker release ].
	^names!
name
        " Answer the name of the storage element. "

	^self stringAtAddress: self pwcsName!   
createTime
		" Answer the create-time timestamp. "

	^self cTime!  
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream. "

    | elementName |
    super printOn: aStream.
    aStream nextPutAll: ' (', self typeDescription.
    ( elementName := self name ) notNil
        ifTrue: [ aStream space; nextPutAll: elementName printString ].
    aStream nextPutAll: ') '.! 
isDirectStorage
		" Answer whether the element is direct storage "

	^self hasMode: STGM_DIRECT!   
isStream
		" Answer whether this is a stream element. "

	^self type = STGTY_STREAM!   
releaseResources
		" Private - release resources owned by the receiver. "

	self releaseStorageName.
	super releaseResources.!
isTransactedStorage
		" Answer whether the element is transacted storage "

	^self hasMode: STGM_TRANSACTED!   
isLockedExclusive
		" Answer whether the element has an exclusive access lock. "

	^self hasMode: STGM_SHARE_EXCLUSIVE!
isEditable
		" Answer whether the element is editable "

	^self hasMode: STGM_READWRITE!   
cbSize
        " Answer the size in bytes of a stream or byte element. "

    ^self uLargeIntegerAtOffset: 8!  
lastAccessedTime
		" Answer the last-accessed timestamp. "

	^self aTime!  
pwcsName
        " Private - answer the address of the storage element name. "

    ^self oleAddressAtOffset: 0!   
isWriteOnly
		" Answer whether the element is writeOnly. "

	^( ( self hasMode: STGM_WRITE ) and: [ ( self hasMode: STGM_READWRITE ) not ] )!  
pwcsName: anAddress
        " Private - set the address of the storage element name. "

    self oleAddressAtOffset: 0 put: anAddress.!
releaseStorageName
		" Private - release the storage name in the receiver. "

	| anAddress |
	( anAddress := self pwcsName ) notNil
		ifTrue: [
			anAddress free.
			self pwcsName: nil.
			].
	!   
aTime
        " Private - Answer the last-access time of the storage element. "

	^self fileTimeAtOffset: 32!  
reserved
		" Answer the reserved field. "

    ^self longAtOffset: 68! 
cTime
        " Private - Answer the creation time of the storage element. "

	^self fileTimeAtOffset: 24! 
type
        " Answer the storage type (STGTY). "

    ^self longAtOffset: 4!  
typeDescription
		" Answer a string description of the storage element type. "

	self isStorage ifTrue: [ ^'storage' ].
	self isStream ifTrue: [ ^'stream' ].
	self isProperty ifTrue: [ ^'property' ].
	( self type = STGTY_LOCKBYTES ) ifTrue: [ ^'lockBytes' ].
	^'(unknown type)'! 
mTime
        " Private - Answer the modification time of the storage element. "

	^self fileTimeAtOffset: 16! 
lastModifiedTime
		" Answer the last-modified timestamp. "

	^self mTime!  
isProperty
		" Answer whether this is a property element. "

	^self type = STGTY_PROPERTY! 
grfMode
        " Answer the mode in which the element was opened (Stat calls only). "

    ^self longAtOffset: 40!
hasMode: aStorageModeFlag
		" Answer whether the STGM storage mode flag <aStorageModeFlag> is set. "

	^( self grfMode bitAnd: aStorageModeFlag ) ~= 0!
isReadOnly
		" Answer whether the element is readOnly. "

	^( ( self hasMode: STGM_READ ) and: [ ( self hasMode: STGM_READWRITE ) not ] )! 
grfStateBits
        " Answer the state bits of a storage element. "

    ^self longAtOffset: 64!  
clsid
        " Answer the CLSID of the storage (if any). "

    ^self guidAtOffset: 48!   
hasName
		" Answer whether the receiver includes a reference to a name string. "

	^( self addressAtOffset: 0 ) notNil!
grfLocksSupported
        " Answer the LOCKTYPE flags of a stream or byte element. "

    ^self longAtOffset: 44!  
isLocked
		" Answer whether the element has any access locks. "

	^( self hasMode: STGM_SHARE_DENY_NONE ) not! 
isStorage
		" Answer whether this is a storage element. "

	^self type = STGTY_STORAGE!
isWriteLocked
		" Answer whether the element has a no-writers access lock. "

	^self hasMode: STGM_SHARE_DENY_WRITE!   
compressClassFactoryRegistry
		" Private - minimize the storage requirements of the class factory registry. "

	self registeredClassFactories size = 0
		ifTrue: [ self resetClassFactoryRegistry ].! 
printOn: aStream
		" Append a text description of the receiver to <aStream> "

    aStream 
		nextPutAll: self class name, ' {';
		nextPutAll: ( self isValid
			ifTrue: [ 
				self asInteger
					printPaddedWith: $0 to: 8 base: 16 ]
			ifFalse: [ 'invalid' ] );
		nextPut: $}.
! 
ReadClassStm: anIStream _: resultReference
		" Get the CLSID associated with the stream <anIStream>
		and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeReadClassStm: anIStream asParameter
		_: resultValue.
	resultReference value: resultValue.
	^hresult!  
invokeDrop: pIDataObject _:grfKeyState _: x _: y _: pdwEffect
        "Private - invoke the IDropTarget::Drop function for an external caller. "

    "  HRESULT Drop(
            /* [unique][in] */ IDataObject *pDataObj,
            /* [in] */ DWORD grfKeyState,
            /* [in] */ POINTL pt,
            /* [out][in] */ DWORD *pdwEffect); "

    | hresult anIDataObject resultReference |

    pIDataObject = 0  " NULL interface pointer "
        ifTrue: [ ^E_INVALIDARG ].
    pdwEffect isValid
        ifFalse: [ ^E_INVALIDARG ].
    anIDataObject := self interfaceAtAddress: pIDataObject
        type: IDataObject.

    resultReference := nil asValueReference.
    hresult := self dispatchDrop: anIDataObject
        _: grfKeyState
        _: x @ y
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: pdwEffect put: resultReference value ].
    ^hresult!
invokeOnLinkSrcChange: pmk
		" Private - invoke the IAdviseSink2::OnLinkSrcChange function. "

	" void OnLinkSrcChange(
            /* [unique][in] */ IMoniker *pmk); "

	<ole: 8 handle none>
	^self vtableDispatchFailed!   
OnLinkSrcChange: anIMoniker
		" Invoke the IAdviseSink2::OnLinkSrcChange function. "

	self invokeOnLinkSrcChange: anIMoniker asParameter.!
OnViewChange: dwAspect _: lindex
		" Invoke the IAdviseSink::OnViewChange function. "

	" void OnViewChange(
            /* [in] */ DWORD dwAspect,
            /* [in] */ LONG lindex);"

	<ole: 4 ulong long none>
	^self vtableDispatchFailed! 
invokeOnRename: pmk
		" Private - invoke the IAdviseSink::OnRename function. "

	" void OnRename(
            /* [in] */ IMoniker *pmk); "

	<ole: 5 handle none>
	^self vtableDispatchFailed! 
OnClose
		" Invoke the IAdviseSink::OnClose function. "

	" void OnClose( void); "

	<ole: 7 none>
	^self vtableDispatchFailed! 
OnRename: anIMoniker
		" Invoke the IAdviseSink::OnRename function. "

	self invokeOnRename: anIMoniker asParameter!   
OnSave
		" Invoke the IAdviseSink::OnSave function. "

	" void OnSave( void); "

	<ole: 6 none>
	^self vtableDispatchFailed!
OnDataChange: aFormatEtc _: aStgMedium
		" Invoke the IAdviseSink::OnDataChange function. "

	" void OnDataChange(
            /* [unique][in] */ FORMATETC *pFormatetc,
            /* [unique][in] */ STGMEDIUM *pStgmed); "

	<ole: 3 structIn structIn none>
	^self vtableDispatchFailed! 
forReturnValue: structureName
		" Answer a new instance of the data structure named <structureName> 
		which is to be used to obtain an OUT parameter return value.  
		Since in general the ownership responsibility of an OUT parameter is
		transferred to the caller, mark the structure as needing finalization
		to ensure cleanup (if relevant). "

	^( self classForStructureNamed: structureName ) forReturnValue!
hasStrongExternalConnections
		"Answer whether the receiver's object has strong external connections. "

	^OLEDLL current CoHasStrongExternalConnections: self!
forClass: anOLEObjectClass
		" Answer a new instance of the receiver which creates instances
		of the OLE objects implemented by <anOLEObjectClass>. "

	anOLEObjectClass clsid isNil
		ifTrue: [ self error: 'must define CLSID to manufacture objects' ].
	^self new
		objectClass: anOLEObjectClass;
		yourself!   
invokeCoCreateInstance: rclsid
	_: pUnkOuter
	_: dwClsContext
	_: riid
	_: ppv
		"Private - WINOLEAPI CoCreateInstance(REFCLSID rclsid, LPUNKNOWN pUnkOuter,
                    DWORD dwClsContext, REFIID riid, LPVOID FAR* ppv);"

    <api: CoCreateInstance structIn handle ulong structIn structOut hresult>
    ^self apiCallFailed!  
CoFileTimeNow: resultReference
		" Obtain the current time as a FILETIME and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEStructure forReturnValue: #FILETIME.
	hresult := self invokeCoFileTimeNow: resultValue.
	resultReference value: resultValue asTimeStamp.
	^hresult
	! 
BindMoniker: anIMoniker _: grfOpt _: iid _: resultReference
		" Bind the moniker <anIMoniker>.  Obtain the interface specified by <iid>
		and store the interface pointer into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeBindMoniker: anIMoniker asParameter
		_: grfOpt 
		_: iid 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
! 
functionHandlers
		" Private - answer the interface function handlers. "

	^functionHandlers!  
forceCallout
		" Answer whether interface function invocation should
		always be forced to call out through an external VTable. "

	^ForceCallout!
hresult: anInteger
        "Signal a newly created instance of the receiver with the result code set to <anInteger>."

    ^( self new hresult: anInteger ) signal!
registerClassObject: aCLSID unknown: anIUnknown classContext: classContext flags: flags
		" Register the object identified by <anIUnknown> as the
		class factory for the CLSID specified by the GUID <aCLSID>.
		The CLSCTX value <classContext> specifies the context in which
		the executable code is to be run.  The REGCLS value <flags> 
		controls how connections are made to the class object.
		Answer the registration token for the registered class factory. "

    | resultReference |
    resultReference := nil asValueReference.
	OLEDLL current CoRegisterClassObject: aCLSID 
		_: anIUnknown 
		_: classContext 
		_: flags 
		_: resultReference.
    ^resultReference value!
createInstance: aCLSID iid: anIID controllingUnknown: controllingUnknown
		" Create a new instance of the OLE class specified by the GUID <aCLSID>
		The object is created as a non-control object within an aggregate
		if the IUnknown of a controlling object is specified in <controllingUnknown>.
		Answer the interface specified by the GUID <anIID> of the new object. "

	^self createInstance: aCLSID 
		iid: anIID 
		controllingUnknown: controllingUnknown 
		context: CLSCTX_ALL!  
createInstance: aCLSID iid: anIID
        " Create a new instance of the OLE class specified by the GUID <aCLSID>.
		Answer the interface specified by the GUID <anIID> of the new object. "

	^self createInstance: aCLSID 
		iid: anIID 
		controllingUnknown: nil 
		context: CLSCTX_ALL!   
createInstance: aCLSID iid: anIID controllingUnknown: controllingUnknown context: classExecutionContext
		" Create a new instance of the OLE class specified by the GUID <aCLSID>
		The object is created as a non-control object within an aggregate
		if the IUnknown of a controlling object is specified in <controllingUnknown>.
		Answer the interface specified by the GUID <anIID> of the new object. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: anIID.
    OLEDLL current CoCreateInstance: aCLSID
        _: controllingUnknown
        _: classExecutionContext
        _: anIID
        _: resultReference.
    ^resultReference value! 
forCLSID: aCLSID
        "Answer a new instance of the receiver for the class object
        of the class specified by the GUID <aCLSID>."

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current CoGetClassObject: aCLSID
        _: CLSCTX_ALL
        _: nil
        _: self iid
        _: resultReference.
    ^resultReference value! 
revokeClassObject: registrationToken
		" Notify OLE that a class object previously registered with 
		CoRegisterClassObject is no longer available. "

	OLEDLL current CoRevokeClassObject: registrationToken.
! 
createInstance: aCLSID
        " Create a new instance of the OLE class specified by the GUID <aCLSID>.
		Answer the IUnknown interface of the new object. "

	^self createInstance: aCLSID 
		iid: IID_IUnknown 
		controllingUnknown: nil 
		context: CLSCTX_ALL!
checkInUse: aClassFactory
		" Private - the in-use status of <aClassFactory> may have changed.
		Determine whether the object server application itself can be terminated
		or whether this class factory alone should be released at this time. "

	( self isInUse not and: [ self exitIfNotInUse ] )
		ifTrue: [  " the entire object server application can be shut down "
			( Message receiver: self selector: #terminateServerApplication )
				performDeferred.
			^self ].

	( aClassFactory isInUse not 
	and: [ aClassFactory isRegistered
	and: [ aClassFactory releaseIfNotInUse ] ] )
		ifTrue: [  " release this class factory but keep the object server running "
			( Message
				receiver: self
				selector: #revokeClassFactory:
				arguments: ( Array with: aClassFactory ) )
					performDeferred ].!   
name: aString
		" Set the name of the receiver to <aString>. "

	name := aString.! 
name
		" Answer the name of the receiver. "

	name isNil
		ifTrue: [ name := self getName ].
	^name! 
container
		" Answer the structured storage entity which contains the receiver. "

	^container!
container: anOleStorageEntity
		" Set the structured storage entity which contains the receiver to <anOleStorageEntity>. "

	container := anOleStorageEntity.! 
isTransactedStorage
		" Answer whether the element is transacted storage "

	^self statisticsWithoutName isTransactedStorage!  
isDirectStorage
		" Answer whether the element is direct storage "

	^self statisticsWithoutName isDirectStorage!  
isStream
		" Answer whether the receiver is an IStream. "

	^false!
statistics
		" Answer the storage statistics about this storage element.
		Include the storage name (which must be deallocated). "

	| resultReference |
	resultReference := nil asValueReference.
	interface Stat: resultReference _: STATFLAG_DEFAULT.
	"self ASSERT: resultReference value hasFinalization."
	^resultReference value!  
isEditable
		" Answer whether the element is editable "

	^self statisticsWithoutName isEditable!  
isLockedExclusive
		" Answer whether the element has an exclusive access lock. "

	^self statisticsWithoutName isLockedExclusive!  
printOn: aStream
        "Append the ASCII representation
         of the receiver to <aStream>."

    super printOn: aStream.
    ( self isValid and: [ self name notNil ] )
        ifTrue: [
            aStream nextPutAll: ' on: '; nextPutAll: self name ].! 
statisticsWithoutName
		" Snswer the storage statistics about this storage element.
		Omit the storage name so that deallocation is not necessary. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Stat: resultReference _: STATFLAG_NONAME.
	"self ASSERT: ( resultReference value hasName not )."
	resultReference value doesNotNeedFinalization.
	^resultReference value!
commit
		" Commit any changes to the contents of the storage since it was last opened
		or committed to persistent storage, but only if no one else has made
		changes to the storage since the receiver was last opened or committed.
		This prevents overwriting changes made by another user of the storage.
		Answer whether the commit succeeded. "

	[ interface Commit: STGC_ONLYIFCURRENT ]
		on: OLEError
		do: [ :ex |
			ex hresult = STG_E_NOTCURRENT
				ifTrue: [ ^false ].
			ex pass ].
	^true!  
revert
		" Discard any changes made to the contents of the storage element
		since it was last opened or committed to persistent storage. 
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Revert!  
isReadOnly
		" Answer whether the element is readOnly. "

	^self statisticsWithoutName isReadOnly! 
close
		" Close the storage element.  Commit any changes. "

	interface isNil
		ifTrue: [ ^self ].
	self isEditable
		ifTrue: [ self commit ].
	self release.
!   
getName
		" Private - get the receiver's name from its interface statistics. "

	| stat elementName |
	stat := self statistics.
	elementName := stat name.
	stat release.
	^elementName!   
isStorage
		" Answer whether the receiver is an IStorage. "

	^false!  
isLocked
		" Answer whether the element has any access locks. "

	^self statisticsWithoutName isLocked!
commit: grfCommitFlags
		" Commit any changes to the contents of the storage element 
		since it was last opened or committed to persistent storage, 
		according to the STGC flags in <grfCommitFlags>.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Commit: grfCommitFlags!   
flush
        "Force all data written to the receiver to be
         recorded on disk."

	self commit.!   
interfaceReference: anInterface
		" Private - set the interface reference "

	value := anInterface.!   
printValueOn: aStream
		" Private - append a text description of the receiver's value to <aStream> "

	value isNil
		ifTrue: [ ^super printValueOn: aStream ].
	aStream nextPutAll: ' on: '.
	value isValid
		ifTrue: [ self value printOn: aStream ]
		ifFalse: [
			nil printOn: aStream.
			aStream nextPutAll: ' (for ', value class printString, ')' ].!   
value
		" Answer the value. "

	^value isValid
		ifTrue: [ value ]
		ifFalse: [ nil ]!   
value: anInterfaceBinding
		" Set the value of the receiver to <anInterfaceBinding>. "

	anInterfaceBinding isNil
		ifTrue: [ ^nil ].
	anInterfaceBinding isValid
		ifFalse: [
			OLEDevelopmentWarning signal: 
				self class name, 
				' warning: should not be returning an invalid interface binding to the caller ( ',
				anInterfaceBinding printString, ' ).'.
			^nil ].
	anInterfaceBinding iid = value iid
		ifFalse: [ self error: 'IID mismatch' ].
	value interfaceBinding:  ( anInterfaceBinding isOLEInterfaceBinding
		ifTrue: [ anInterfaceBinding ]
		ifFalse: [ 
			anInterfaceBinding isOLEInterfaceImplementation
				ifTrue: [ anInterfaceBinding interfaceBinding ]  " from object impl "
				ifFalse: [ self error: 'not a pointer' ] ] ).
	^anInterfaceBinding!   
interfaceReference
		" Private - answer the interface reference "

	^value!
StgOpenStorageOnILockBytes: anILockBytes _:pstgPriority _: grfMode _: snbExclude _: reserved _: resultReference
		" Open a compound file on the existing backing store provided by <anILockBytes>
		with the access mode specified by the STGM flags <grfMode>.
		Obtain an IStorage interface on the new storage and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := IStoragePointer forReturnValue.
    hresult := self invokeStgOpenStorageOnILockBytes: anILockBytes asParameter
         _: pstgPriority asParameter
        _: grfMode
        _: ( self asSNBParameter: snbExclude )
        _: reserved
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult! 
exitIfNotInUse: aBoolean
		" Specify whether the process should be terminated when there
		are no locked class factories and all objects created by class factories
		in the current session have been released. "

	ExitIfNotInUse := aBoolean.!
initializeInterfaces
		" Private - Allocate any interfaces which are expected to be required 
		during the object's lifetime. "

	super initializeInterfaces.
	iClassFactory := IClassFactory on: self.! 
supportsIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^self iid = anIID!   
removeIID: anIID
        " Private - remove the interface implementation binding class registration of
        the interface whose IID is the interface ID GUID <anIID>. "

	OLEInterfacePointer removeInterfaceImplementationClassForIID: anIID.!
forceCallout: aBoolean
		" Specify whether interface function invocation should
		always be forced to call out through an external VTable. "

	ForceCallout := aBoolean.! 
finalizationRegistry
		"Private - Answer the WeakRegistry to be used for finalizing instances of the receiver."

    ^OLESessionManager ownedInterfacesRegistry!   
CreateGenericComposite: firstMoniker _: nextMoniker _: resultReference
		" Create a composite moniker by concatenating <pmkFirst> and <pmkRest>.
		Store the interface pointer into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeCreateGenericComposite: firstMoniker asParameter 
		_: nextMoniker asParameter 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
!
invokeDragOver: grfKeyState _: x _: y _: pdwEffect
        "Private - invoke the IDropTarget::DragOver function for an external caller. "

    " HRESULT DragOver(
            /* [in] */ DWORD grfKeyState,
            /* [in] */ POINTL pt,
            /* [out][in] */ DWORD *pdwEffect); "

    | hresult resultReference |

    pdwEffect isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchDragOver: grfKeyState
        _: x @ y
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: pdwEffect put: resultReference value ].
    ^hresult
! 
formatEtc: aFormatEtc object: anObject
        "Create a new instance of OLERendering with the specified
         FormatEtc and Object. <aFormatEtc> describe the clipboard
        format of the rendering object <anObject>."

    ^self new
        formatEtc: aFormatEtc;
        object: anObject;
        yourself
!   
invokeDoDragDrop: pDataObj _: pDropSource _: dwOKEffects _: pdwEffect
        "Private - WINOLEAPI  DoDragDrop(
			LPDATAOBJECT pDataObj, LPDROPSOURCE pDropSource,
			DWORD dwOKEffects, LPDWORD pdwEffect);"

    <api: DoDragDrop handle handle ulong structOut hresult>
    ^self apiCallFailed!
elementsInRegistry: aRegistry
		" Private - answer a collection containing the elements <aRegistry>. "

	^aRegistry ephemerons keys!   
QueryContinueDrag: fEscapePressed _: grfKeyState
		" Invoke the IDropSource::QueryContinueDrag function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT QueryContinueDrag(
            /* [in] */ BOOL fEscapePressed,
            /* [in] */ DWORD grfKeyState); "

	<ole: 3 boolean ulong hresult>
	^self vtableDispatchFailed!   
GiveFeedback: dwEffect
		" Invoke the IDropSource::GiveFeedback function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT GiveFeedback(
            /* [in] */ DWORD dwEffect); "

	<ole: 4 ulong hresult>
	^self vtableDispatchFailed!   
dispatchDUnadvise: dwConnection
		"Private - dispatch the IDataObject::DUnadvise function. "

	^( functionHandlers at: 11 ) evaluateWithArguments: ( Array
		with: dwConnection )!
QueryGetData: aFormatEtc
		" Invoke the IDataObject::QueryGetData function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchQueryGetData: aFormatEtc )!  
dispatchEnumFormatEtc: aDataDirection _: resultReference
		"Private - dispatch the IDataObject::EnumFormatEtc function. "

    ^( functionHandlers at: 9 ) evaluateWithArguments: ( Array
		with: aDataDirection 
		with: resultReference )! 
DAdvise: aFormatEtc _: advf _: anAdviseSink _: resultReference
		" Invoke the IDataObject::DAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchDAdvise: aFormatEtc _:advf _: anAdviseSink _: resultReference )!
dispatchGetCanonicalFormatEtc: aFormatEtc _: resultReference
		"Private - dispatch the IDataObject::GetCanonicalFormatEtc function. "

	^( functionHandlers at: 7 ) evaluateWithArguments: ( Array
		with: aFormatEtc
		with: resultReference )! 
invokeEnumDAdvise: ppenumAdvise
        "Private - invoke the IDataObject::EnumDAdvise function for an external caller. "

    " HRESULT EnumDAdvise(
            /* [out] */ IEnumSTATDATA **ppenumAdvise); "

    | hresult resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ppenumAdvise isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: ppenumAdvise.

    resultReference := nil asValueReference.
    hresult := self dispatchEnumDAdvise: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppenumAdvise put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'IEnumSTATDATA: ',resultDescription.
        self logCallbackExit: hresult ].
    ^hresult!   
invokeDUnadvise: dwConnection
		"Private - invoke the IDataObject::DUnadvise function for an external caller. "

	" HRESULT DUnadvise(
            /* [in] */ DWORD dwConnection); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchDUnadvise: dwConnection.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
invokeQueryGetData: pFormatEtc
        "Private - invoke the IDataObject::QueryGetData function for an external caller. "

    " HRESULT QueryGetData(
            /* [unique][in] */ FORMATETC *pformatetc); "

    | hresult aFormatEtc |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pFormatEtc isValid
        ifFalse: [ ^E_INVALIDARG ] .
    aFormatEtc := self structureAtAddress: pFormatEtc
        type: #FORMATETC.

    hresult := self dispatchQueryGetData: aFormatEtc.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
SetData: aFormatEtc _: aStgMedium _: fRelease
		" Invoke the IDataObject::SetData function. 
		Raise an exception if an error occurs.  Answer the result code. "

   ^self checkHresult:
		( self dispatchSetData: aFormatEtc _: aStgMedium _: fRelease )!   
dispatchQueryGetData: aFormatEtc
		" Private - dispatch the IDataObject::QueryGetData function. "

    ^( functionHandlers at: 6 ) evaluateWithArguments: ( Array
		with: aFormatEtc )!   
EnumDAdvise: resultReference
		" Invoke the IDataObject::EnumDAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchEnumDAdvise: resultReference )!   
dispatchDAdvise: aFormatEtc _: advf _: anAdviseSink _: resultReference
		"Private - dispatch the IDataObject::DAdvise function. "

	^( functionHandlers at: 10 ) evaluateWithArguments: ( Array
		with: aFormatEtc 
		with: advf
		with: anAdviseSink
		with: resultReference )!   
DUnadvise: dwConnection
		" Invoke the IDataObject::DUnadvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchDUnadvise: dwConnection )!   
dispatchGetDataHere: aFormatEtc _: aStgMedium
		" Private - dispatch the IDataObject::GetDataHere function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
		with: aFormatEtc 
		with: aStgMedium )!  
GetCanonicalFormatEtc: aFormatEtc _: resultReference
		" Invoke the IDataObject::GetCanonicalFormatEtc function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchGetCanonicalFormatEtc: aFormatEtc _: resultReference )! 
dispatchSetData: aFormatEtc _: aStgMedium _: fRelease
		" Private - dispatch the IDataObject::SetData function. "

    ^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
		with: aFormatEtc 
		with: aStgMedium
		with: fRelease )!
EnumFormatEtc: aDataDirection _: resultReference
		" Invoke the IDataObject::EnumFormatEtc function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchEnumFormatEtc:  aDataDirection _: resultReference )!
invokeGetDataHere: pFormatEtc _: pStgMedium
        "Private - invoke the IDataObject::GetData function for an external caller. "

    " HRESULT GetDataHere(
            /* [unique][in] */ FORMATETC *pformatetc,
            /* [out][in] */ STGMEDIUM *pmedium); "

    | hresult aFormatEtc aStgMedium |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ( pFormatEtc isValid
    and: [ pStgMedium isValid ] )
        ifFalse: [ ^E_INVALIDARG ].
    aFormatEtc := self structureAtAddress: pFormatEtc
        type: #FORMATETC.
    aStgMedium := self structureAtAddress: pStgMedium
        type: #STGMEDIUM.

    hresult := self dispatchGetDataHere: aFormatEtc _: aStgMedium.

    self ifOLETraceEnabled: [
        self logReturnValue: 'STGMEDIUM ', ( ( HRESULT succeeded: hresult )
            ifTrue: [ aStgMedium printString ]
            ifFalse: [ 'nil' ] ).
        self logCallbackExit: hresult ].
    ^hresult!
invokeSetData: pFormatEtc _: pStgMedium _: fRelease
        "Private - invoke the IDataObject::SetData function for an external caller. "

    " HRESULT SetData(
            /* [unique][in] */ FORMATETC *pformatetc,
            /* [unique][in] */ STGMEDIUM *pmedium,
            /* [in] */ BOOL fRelease); "

    | hresult aFormatEtc aStgMedium |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ( pFormatEtc isValid
    and: [ pStgMedium isValid ] )
        ifFalse: [ ^E_INVALIDARG ].
    aFormatEtc := self structureAtAddress: pFormatEtc
        type: #FORMATETC.
    aStgMedium := self structureAtAddress: pStgMedium
        type: #STGMEDIUM.

    hresult := self dispatchSetData: aFormatEtc _: aStgMedium _: fRelease.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
dispatchEnumDAdvise: resultReference
		"Private - dispatch the IDataObject::EnumDAdvise function. "

	^( functionHandlers at: 12 ) evaluateWithArguments: ( Array
		with: resultReference )!  
invokeGetData: pFormatEtc _: pStgMedium
        "Private - invoke the IDataObject::GetData function for an external caller. "

    " HRESULT GetData(
            /* [unique][in] */ FORMATETC *pformatetcIn,
            /* [out] */ STGMEDIUM *pmedium); "

    | hresult aFormatEtc resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ( pFormatEtc isValid
    and: [ pStgMedium isValid ] )
        ifFalse: [ ^E_INVALIDARG ].
    aFormatEtc := self structureAtAddress: pFormatEtc
        type: #FORMATETC.
    self clearResultStructureAtAddress: pStgMedium
        type: #STGMEDIUM.

    resultReference := nil asValueReference.
    hresult := self dispatchGetData: aFormatEtc
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self structureResultAtAddress: pStgMedium put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'STGMEDIUM ', ( ( HRESULT succeeded: hresult )
            ifTrue: [ resultReference value printString ]
            ifFalse: [ 'nil' ] ).
        self logCallbackExit: hresult ].
    ^hresult
!
dispatchGetData: aFormatEtc _: resultReference
		" Private - dispatch the IDataObject::GetData function. "

    ^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
		with: aFormatEtc 
		with: resultReference )!
invokeDAdvise: pFormatEtc _: advf _: pAdvSink _: pdwConnection
        "Private - invoke the IDataObject::DAdvise function for an external caller. "

    " HRESULT DAdvise(
            /* [in] */ FORMATETC *pformatetc,
            /* [in] */ DWORD advf,
            /* [unique][in] */ IAdviseSink *pAdvSink,
            /* [out] */ DWORD *pdwConnection); "

    | hresult aFormatEtc anAdviseSink resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pAdvSink = 0  " NULL interface pointer "
        ifTrue: [ ^E_INVALIDARG ].
    (  pFormatEtc isValid
    and: [ pdwConnection isValid ] )
        ifFalse: [ ^E_INVALIDARG ].
    aFormatEtc := self structureAtAddress: pFormatEtc
        type: #FORMATETC.
    anAdviseSink := self interfaceAtAddress: pAdvSink
        type: IAdviseSink.
    self clearResultValueAtAddress: pdwConnection.

    resultReference := nil asValueReference.
    hresult := self dispatchDAdvise: aFormatEtc
        _: advf
        _: anAdviseSink
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: pdwConnection put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'Connection token: ', resultReference value printString.
        self logCallbackExit: hresult ].
    ^hresult!
invokeEnumFormatEtc: dwDirection _: pEnumFormatEtc
        "Private - invoke the IDataObject::EnumFormatEtc function for an external caller. "

    " HRESULT EnumFormatEtc(
            /* [in] */ DWORD dwDirection,
            /* [out] */ IEnumFORMATETC **ppenumFormatEtc); "

    | hresult resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pEnumFormatEtc isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: pEnumFormatEtc.

    resultReference := nil asValueReference.
    hresult := self dispatchEnumFormatEtc: dwDirection _: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: pEnumFormatEtc put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'IEnumFORMATETC: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult!
GetDataHere: aFormatEtc _: aStgMedium
		" Invoke the IDataObject::GetDataHere function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchGetDataHere: aFormatEtc _: aStgMedium )! 
GetData: aFormatEtc _: resultReference
		" Invoke the IDataObject::GetData function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchGetData: aFormatEtc _: resultReference )!   
invokeGetCanonicalFormatEtc: pFormatEtc _: pFormatEtcOut
        "Private - invoke the IDataObject::GetCanonicalFormatEtc function for an external caller. "

    " HRESULT GetCanonicalFormatEtc(
            /* [unique][in] */ FORMATETC *pformatectIn,
            /* [out] */ FORMATETC *pformatetcOut); "

    | hresult aFormatEtc resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ( pFormatEtc isValid
    and: [ pFormatEtcOut isValid ] )
        ifFalse: [ ^E_INVALIDARG ].
    aFormatEtc := self structureAtAddress: pFormatEtc
        type: #FORMATETC.
    self clearResultValueAtAddress: pFormatEtcOut.

    hresult := self dispatchGetCanonicalFormatEtc: aFormatEtc
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self addressResultAtAddress: pFormatEtcOut put: resultReference value ].

    self ifOLETraceEnabled: [
        "??self logReturnValue: ??"
        self logCallbackExit: hresult ].
    ^hresult!
registerSpecialSessionResource: aResource description: aString
		" Private - register a description of a special resource of the current session. "

	aResource isNil
		ifTrue: [ ^nil ].
	aResource isOLEInterfacePointer
		ifTrue: [  " don't finalize interfaces with special session startup/shutdown handling "
			aResource interfaceBinding doesNotNeedFinalization ].
	self specialSessionResources at: aResource put: aString.!  
OleDuplicateData: hSrc _: cfFormat _: uiFlags
		" Duplicate a metafile, bitmap, or global memory resource.
		Return a handle of the same type as the source data. "

	| hSource hCopy |
	hSource := hSrc asParameter.
	hCopy := self invokeOleDuplicateData: hSource
		_: cfFormat
		_: uiFlags.
	^hCopy = 0
		ifTrue: [ self osError ]
		ifFalse: [ hSource class fromInteger: hCopy ]!   
CoCreateInstance: clsid
    _: controllingUnknown
    _: dwClsContext
    _: iid
    _: resultReference
        " Create a new instance of the OLE class specified by the GUID <clsid>.
        If a <controllingUnknown> is specified, the object is
        being instantiated for use as a non-control object within an aggregate.
        Obtain the interface specified by the GUID <iid> on the new object
        and store it into the <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeCoCreateInstance: clsid
		_: controllingUnknown asParameter
		_: dwClsContext
		 _: iid
		 _: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
hresult: anInteger
        "Set the OLE result code which caused the notification to <anInteger>
        and generate a text message describing it."

	hresult := anInteger.
	self messageText: ( HRESULT description: anInteger ).! 
hresult
        "Answer the OLE result code which caused the notification. "

    ^hresult!
" OLE COM Support - library installation "

    ExternalObjectTable installComponent.
    OLESessionManager registerSessionEventHandlers.

    " install development environment support "
    OLESessionManager bindDevelopmentLibrary: 'VOLDB31W.sll'
        for: 'OLE COM Support library VOLEB31W.sll'.
!
OleSetContainedObject: anIUnknown _: fContained
        " Indicate that the object <anIUnknown> is contained as an embedding.
        Raise an exception if an error occurs.  Answer the result code. "

        "OleSetContainedObject facilitates linking to embedded objects.
        Normally containers call OleSetContainedObject with fContained set to TRUE one time,
        either after creating the object initially or after loading it, and never call it again, even
        before they close. Consequently, the use of OleSetContainedObject with fContained
        set to FALSE is rare."

    ^self invokeOleSetContainedObject: anIUnknown asParameter
        _: fContained! 
interfaceImplementationClassForIID: anIID
		" Private - answer the interface callin binding class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	iidEntry := self iidMap at: anIID " ptr, reference, impl "
		ifAbsent: [ ^nil ].
	^iidEntry at: 3!   
registerInterfacePointerClass: aClass forIID: anIID
        " Private - register <aClass> as the interface pointer binding class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry registeredClass |
	( anIID isNil or: [ anIID = IID_NULL ] )
		ifTrue: [ ^nil ].  " ignore null IID's of abstract interface classes "
	self iidMap isNil
		ifTrue: [ self initializeIIDMap ].
	iidEntry := self iidMap at: anIID 
		ifAbsentPut: [ Array new: 3 ].  " ptr, reference, impl "
	registeredClass := iidEntry at: 1.
	" pointer registrations must be unique; changing may be a programmer error "
	( registeredClass notNil and: [ registeredClass ~~ aClass ] )
		ifTrue: [
			( MessageBox confirm: 
				'You are about to replace the interface pointer registration for IID ', 
				anIID printString, ' of ', registeredClass name, 
				' with ', aClass name, ' - this may be an error.  Do you wish to proceed?' )
				ifFalse: [ Terminal bell. ^nil ] ].
	iidEntry at: 1 put: aClass.
	^aClass!  
initializeStructureNameMap
		" Private - initialize the map from a host data structure name
		to the OLE structure definition class which represents that type. "

	self structureNameMap: self constructStructureNameMap.!   
classForStructureNamed: structureName
		" Answer the OLE structure definition class which represents the 
		host data structure named <structureName>.  Answer nil if the
		structure is not supported. "

	^self classForStructureNamed: structureName ifNone: [ nil ]! 
forReturnValue
		" Answer a new instance of the receiver which is to be used
		to obtain an OUT parameter return value.  Since in general the
		ownership responsibility of an OUT parameter is transferred
		to the caller, mark the structure as needing finalization
		to ensure cleanup (if relevant). "

	| aStructure |
	aStructure := self new.
	self usesFinalization 
		ifTrue: [ aStructure needsFinalization ].
	^aStructure!   
queryInterface: iid
        "Query the receiver for the interface specified by the GUID <iid>.
		Answer the interface if it is supported, else answer nil. "

    | resultReference |
	interface isNil
		ifTrue: [
			OLEDevelopmentWarning signal: 'No interface to query in ', self printString.
			^nil ].
	resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
	interface QueryInterface: iid _: resultReference.
    ^resultReference value!
invokeCreateAntiMoniker: ppmk
        "Private - WINOLEAPI  CreateAntiMoniker(LPMONIKER FAR* ppmk); "

    <api: CreateAntiMoniker structOut hresult>
    ^self apiCallFailed!
QueryGetData: aFormatEtc
		" Invoke the IDataObject::QueryGetData function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT QueryGetData(
            /* [unique][in] */ FORMATETC *pformatetc); "

    | hresult |
    <ole: 5 structIn hresult>
    hresult := self dispatchFailureReason.
    hresult = DATA_E_FORMATETC
        ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed! 
DAdvise: aFormatEtc _: advf _: anAdviseSink _: resultReference
		" Invoke the IDataObject::DAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeDAdvise: aFormatEtc 
		_: advf 
		_: anAdviseSink asParameter 
		_: resultValue.
	resultValue := resultValue asInteger.
	resultValue = 0
		ifFalse: [ resultReference value: resultValue ].
	^hresult!   
invokeEnumDAdvise: ppenumAdvise
		" Private - invoke the IDataObject::EnumDAdvise function. "

	" HRESULT EnumDAdvise(
            /* [out] */ IEnumSTATDATA **ppenumAdvise); "

	<ole: 11 structOut hresult>
	^self vtableDispatchFailed! 
SetData: aFormatEtc _: aStgMedium _: fRelease
		" Invoke the IDataObject::SetData function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT SetData(
            /* [unique][in] */ FORMATETC *pformatetc,
            /* [unique][in] */ STGMEDIUM *pmedium,
            /* [in] */ BOOL fRelease); "

	<ole: 7 structIn structIn boolean hresult>
	^self vtableDispatchFailed!
EnumDAdvise: resultReference
		" Invoke the IDataObject::EnumDAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumSTATDATA.
	hresult := self invokeEnumDAdvise: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
DUnadvise: dwConnection
		" Invoke the IDataObject::DUnadvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT DUnadvise(
            /* [in] */ DWORD dwConnection); "

	<ole: 10 ulong hresult>
	^self vtableDispatchFailed!   
GetCanonicalFormatEtc: aFormatEtc _: resultReference
        " Invoke the IDataObject::GetCanonicalFormatEtc function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEStructure forReturnValue: #FORMATETC.
    hresult := self invokeGetCanonicalFormatEtc: aFormatEtc
        _: resultValue.
    resultReference value: ( hresult = DATA_S_SAMEFORMATETC
        ifTrue: [ aFormatEtc ]
        ifFalse: [ resultValue ] ).
    ^hresult
!   
EnumFormatEtc: aDataDirection _: resultReference
		" Invoke the IDataObject::EnumFormatEtc function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumFORMATETC.
	hresult := self invokeEnumFormatEtc: aDataDirection
		 _: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
invokeGetData: pformatetcIn _: pmedium
		" Private - invoke the IDataObject::GetData function. "

	" HRESULT GetData(
            /* [unique][in] */ FORMATETC *pformatetcIn,
            /* [out] */ STGMEDIUM *pmedium); "

	<ole: 3 structIn structOut hresult>
	^self vtableDispatchFailed!   
invokeDAdvise: pformatetc _: advf _: pAdvSink _: pdwConnection
		" Private - invoke the IDataObject::DAdvise function. "

	" HRESULT DAdvise(
            /* [in] */ FORMATETC *pformatetc,
            /* [in] */ DWORD advf,
            /* [unique][in] */ IAdviseSink *pAdvSink,
            /* [out] */ DWORD *pdwConnection); "

	<ole: 9 structIn ulong handle structOut hresult>
	^self vtableDispatchFailed!   
invokeEnumFormatEtc: dwDirection _: ppenumFormatEtc
		" Private - invoke the IDataObject::EnumFormatEtc function. "

	" HRESULT EnumFormatEtc(
            /* [in] */ DWORD dwDirection,
            /* [out] */ IEnumFORMATETC **ppenumFormatEtc); "

	<ole: 8 ulong structOut hresult>
	^self vtableDispatchFailed! 
GetDataHere: aFormatEtc _: aStgMedium
		" Invoke the IDataObject::GetDataHere function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT GetDataHere(
            /* [unique][in] */ FORMATETC *pformatetc,
            /* [out][in] */ STGMEDIUM *pmedium); "

	<ole: 4 structIn struct hresult>
	^self vtableDispatchFailed!
GetData: aFormatEtc _: resultReference
        " Invoke the IDataObject::GetData function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEStructure forReturnValue: #STGMEDIUM.
    hresult := self invokeGetData: aFormatEtc
        _: resultValue.
    resultReference value: resultValue.
    ^hresult
!  
invokeGetCanonicalFormatEtc: pformatectIn _: pformatetcOut
		" Private - invoke the IDataObject::GetCanonicalFormatEtc function. "

	" HRESULT GetCanonicalFormatEtc(
            /* [unique][in] */ FORMATETC *pformatectIn,
            /* [out] */ FORMATETC *pformatetcOut); "

	<ole: 6 structIn structOut hresult>
	^self vtableDispatchFailed! 
externalMemoryAddress: anAddress
		" Private - set the address in external memory
		of the receiver's interface data structures (ptr-ptr-VTable). "

	externalMemoryAddress := anAddress.
	externalMemoryAddress isNil
		ifTrue: [ self doesNotNeedFinalization ]
		ifFalse: [ self needsFinalization ].!  
registerObject: anOleObject classFactory: aClassFactory
		" Register the OLE object <anOleObject> which was created by
		the class factory object <aClassFactory> in the active objects registry. "

	self activeObjectsRegistry at: anOleObject put: aClassFactory.! 
StgCreateDocfile: aFileName _: grfMode _: reserved _: resultReference
		" Create a new compound file in the file system named <aFileName>
		and open in with the access mode specified by the STGM flags <grfMode>.
		Obtain an IStorage interface on the new storage and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := IStoragePointer forReturnValue.
    hresult := self invokeStgCreateDocfile: ( self asUnicodeParameter: aFileName )
        _: grfMode
        _: reserved
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!   
invokeOleIsRunning: pObject
        "Private - WINOLEAPI_(BOOL)  OleIsRunning(
            LPOLEOBJECT pObject);"

    <api: OleIsRunning handle boolean>
    ^self apiCallFailed!   
registerInterfaceImplementationClass: aClass forIID: anIID
        " Private - register <aClass> as the interface callin binding class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	( anIID isNil or: [ anIID = IID_NULL ] )
		ifTrue: [ ^nil ].  " ignore null IID's of abstract interface classes "
	self iidMap isNil
		ifTrue: [ self initializeIIDMap ].
	iidEntry := self iidMap at: anIID 
		ifAbsentPut: [ Array new: 3 ].  " ptr, reference, impl "
	iidEntry at: 3 put: aClass.
	^aClass!
invokeCoCreateGuid: aByteArray
        "Private - WINOLEAPI CoCreateGuid(GUID FAR *pguid);"

    <api: CoCreateGuid structOut hresult>
    ^self apiCallFailed!   
invokeStgCreateDocfile: pwcsName _: grfMode _: reserved _: ppstgOpen
		"Private - WINOLEAPI StgCreateDocfile(
			const OLECHAR FAR* pwcsName,
			DWORD grfMode,
			DWORD reserved,
			IStorage FAR * FAR *ppstgOpen);"

    <api: StgCreateDocfile structIn ulong ulong structOut hresult>
    ^self apiCallFailed!   
structureAtOffset: offset type: structureName
		" Private - answer a structure of type <structureName>
		from the bytes at offst <offset> in the receiver. "

    ^( OLEStructure classForStructureNamed: structureName ) usingBytes: ( self
        bytesAtOffset: offset
        count: ( OLEStructure sizeOfStructureNamed: structureName ) )!   
vtableDispatchFailed
		" Private - Initiate a walkback indicating an VTable function primitive call failure."

    ^self exception signal! 
invokeOleCreateFromData: pSrcDataObj _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreateFromData(
                LPDATAOBJECT pSrcDataObj, REFIID riid,
                DWORD renderopt, LPFORMATETC pFormatEtc,
                LPOLECLIENTSITE pClientSite, LPSTORAGE pStg,
                LPVOID FAR* ppvObj);"

    <api: OleCreateFromData handle structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed!
stringAtAddress: anExternalAddress
		" Private - answer a String containing the characters at address <anExternalAddress>. 
		The string pointer references the Unicode byte encoding of the string. "

	^anExternalAddress isNil
		ifTrue: [ nil ]
		ifFalse: [ ( UnicodeStringBuffer atAddress: anExternalAddress ) asString ]!   
next: cElements
		" Retrieve the next <cElements> elements in the enumeration sequence. "

	| elementBuffer resultReference hresult cElementsRetrieved |
	elementBuffer := self allocateElementBuffer: cElements.
	resultReference := nil asValueReference.
	hresult := interface Next: cElements _: elementBuffer _: resultReference.
	cElementsRetrieved := resultReference value.
	"self ASSERT: (
		( hresult = S_OK and: [ cElementsRetrieved = cElements ] )
		or: [ hresult = S_FALSE and: [ cElementsRetrieved < cElements ] ] )."
	^cElementsRetrieved = 0
		ifTrue: [ nil ]
		ifFalse: [ self unpackElementBuffer: elementBuffer count: cElementsRetrieved ]!  
getTimeOfLastChange: aBindContext monikerToLeft:  monikerToLeft
		" Answer the timestamp of when the object referenced by this moniker
		was last changed. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetTimeOfLastChange: aBindContext _:  monikerToLeft _: resultReference.
	^resultReference value!   
setDefaultReturnValue: anInteger
		" Private - set the default return value to <anInteger>.
		This is the value that will be returned if an unhandled exception
		occurs in the image while processing a callback. "

    <primitive: 170>
    ^self primitiveFailed!   
asInterfaceReference
		" Answer a civilized interface reference on the receiver. "

	^( OLEInterface classForIID: self iid ) forBinding: self! 
dispatchDragOver: grfKeyState _: aPoint _: resultReference
		" Private - dispatch the IDropTarget::DragOver function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
        with: grfKeyState
        with: aPoint
        with: resultReference )! 
releaseResources
		" Private - release all OLE interfaces and memory addresses owned or allocated by this session. "

	" revoke drop targets - must do before interface pointers are released.
		Cannot leave for normal window shutdown processing, since that
		will also attempt to reopen the OLE DLL, which is shut down by
		the OLE processing here and generates errors if reopened. "
	Notifier windows do: [ :w |
		w isGlobalDragTarget  
			ifTrue: [ [ w revokeDragDrop ]
				on: Error
				do: [ :ex | OLEWarning signal: 'OLE drag/drop revoke error: ', ex description ] ].
		].

    self allOwnedInterfaces do: [ :anInterface |
        [ anInterface release ]
			on: Error
			do: [ :ex | OLEWarning signal: 'OLE interface release error: ', ex description ] ].
	"self ASSERT: self allOwnedInterfaces isEmpty."

    self allAllocatedInterfaces do: [ :anInterface |
        [ anInterface releaseResources ]
			on: Error
			do: [ :ex | OLEWarning signal: 'OLE interface impl release error: ', ex description ] ].
	"self ASSERT: self allAllocatedInterfaces isEmpty."

	" release the external VTable shared by all exported interfaces "
	[ OLEExternalVTable releaseExternalVTable ]
		on: Error
		do: [ :ex | OLEWarning signal: 'OLE callin VTable release error: ', ex description ].

	" release memory before the memory allocators themselves are released "
    self allOwnedMemoryAddresses do: [ :anAddress |
        [ anAddress release ]
			on: Error
			do: [ :ex | OLEWarning signal: 'OLE memory release error: ', ex description ] ].
	"self ASSERT: self ownedMemoryAddresses isEmpty."

	self sessionHasResources
		ifTrue: [ OLEWarning signal: 'OLE resource registries were not emptied by release logic (what to do?!!)' ].
	self allResourceRegistries do: [ :aRegistry |
		( self elementsInRegistry: aRegistry ) do: [:object | object aboutToExitSession ] ].

!
registerDragDrop
        "Private - register the receiver as an OLE drag target."

    | object iDropTarget |
    object := OLEDropTargetObject new.
    object window: self.
    iDropTarget := object queryInterface: IDropTarget iid.
    self iDropTarget: iDropTarget.
	iDropTarget registerDragDrop: self.! 
nullValue
		" Answer a NULL GUID. "

	^nullValue!  
initializeElementTypeMap
		" Private - initialize the map from an enumeration element type
		to the OLE interface IID which enumerates elements of that type. "

	self elementTypeMap: self constructElementTypeMap.! 
invokeOleSaveToStream: pPStm _: pStm
        "Private - WINOLEAPI  OleSaveToStream( LPPERSISTSTREAM pPStm, LPSTREAM pStm );"

    <api: OleSaveToStream handle handle hresult>
    ^self apiCallFailed!   
forTemporaryInterfacePointer
		"Answer a new instance of the receiver for an external interface pointer
		which the client asserts is a temporary copy and does not need 
		to be reference counted. "

	^self forBinding: self interfacePointerClass newTemporaryInterfacePointer!  
validateHandler: aHandler for: eptDescription
		" Private - validate the function handler <aHandler> which
		has been registered for the interface function described
		by <eptDescription>. "

	( aHandler isMessage
	and: [ ( Message numberOfArgumentsFor: aHandler selector ) ~= eptDescription argumentTypes size ] )
		ifTrue: [
			MessageBox warning: 
				self name, 
				' VTable handlers problems: argument count mismatch for ', 
				eptDescription name ].! 
memoryAddress
		" Answer the global memory address of the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current GetHGlobalFromStream: self 
		_: resultReference.
	^resultReference value!   
asCharacterStream
        "Answer the receiver as a Stream which treats its contents as characters."

    ^OLEReadWriteStream characterStreamOn: self! 
asStream
        "Answer the receiver as a Stream."

    ^self asCharacterStream!  
position
        " Answer the current position in the stream. "

    | resultReference |
    resultReference := nil asValueReference.
    interface Seek: 0 _: STREAM_SEEK_CUR _: resultReference.
    ^resultReference value!  
asByteStream
        "Answer the receiver as a Stream which treats its contents as bytes."

    ^OLEReadWriteStream byteStreamOn: self!
isStream
		" Answer whether the receiver is an IStream. "

	^true! 
setSize: newSize
		" Change the size of the stream to <newSize>. "

	^interface SetSize: newSize!  
read: buffer count: count
		" Read <count> bytes from the stream starting at the current seek pointer
		into the <buffer> provided by the caller.
		Update the seek pointer to the new position after the read is complete.
		Answer the number of bytes actually read. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Read: buffer 
		_: count 
		_: resultReference.
	^resultReference value!  
write: buffer count: count
		" Write <count> bytes from the client's <buffer> into the stream
		starting at the current seek pointer.  Update the seek pointer to the 
		new position after the write is complete.  Answer the number of bytes 
		actually written. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Write: buffer _: count _: resultReference.
	^resultReference value! 
position: anInteger
        " Set the position of the stream to offset <anInteger>. "

	interface Seek: anInteger _: STREAM_SEEK_SET _: nil.!  
setToEnd
        " Set the position of the stream to the end. "

	interface Seek: 0 _: STREAM_SEEK_END _: nil.!
lockRegion: offset count: count mode: lockType
		" Lock the <count> bytes in the stream starting at position <offset> 
		using locking mode <lockType>. "

	^interface LockRegion: offset _: count _: lockType!   
writeCLSID: clsid
		" Set the CLSID associated with the receiver to the GUID <clsid>. "

	^OLEDLL current WriteClassStm: self _: clsid!
copyTo: destStream
		" Copy the contents of the stream to <destStream>, 
		starting at the current seek pointer in each stream. "

	interface CopyTo: destStream _: nil _: nil _: nil.!   
clone
		" Answer a clone of the receiver whose seek pointer is initialized
		to the current position. "

	| resultReference |
	resultReference := IStream new asValueReference.
	interface Clone: resultReference.
	^resultReference value!
size
        "Answer the size of the receiver stream element. "

    ^self statisticsWithoutName cbSize!   
skip: anInteger
        " Increment the position of the stream by <anInteger>. "

	interface Seek: anInteger _: STREAM_SEEK_CUR _: nil.!   
unlockRegion: offset count: count mode: lockType
		" Unlock the <count> bytes in the stream starting at position <offset> 
		that was previously locked in locking mode <lockType>. "

	^interface UnlockRegion: offset _: count _: lockType! 
readCLSID
		" Answer the CLSID associated with the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current ReadClassStm: self 
		_: resultReference.
	^resultReference value!  
reset
        " Set the position of the stream to the beginning. "

	interface Seek: 0 _: STREAM_SEEK_SET _: nil!  
finalize
		" Private - The receiver is no longer referenced by any object 
		in the system and is about to be destroyed.  Free the memory
		referenced by the receiver."

	self isValid
		ifTrue: [ OLEDevelopmentWarning signal: 'OLE address released by finalization: ', self printString ]
		"ifFalse: [ OLEDevelopmentWarning signal: 'Unnecessary finalization on OLE address: ', self printString ]".
	^self release!  
isItemMoniker
		" Answer whether the receiver is an item moniker "

	^self systemMonikerType = MKSYS_ITEMMONIKER!  
relativePathTo: sourceMoniker from: destMoniker
		" Answer a new moniker specifying the relative path from
		the <sourceMoniker> to <destMoniker>. "

	" Used in the implementation of a moniker class. "

	| resultReference hresult |
	resultReference := self new asValueReference.
	hresult := OLEDLL current MonikerRelativePathTo: sourceMoniker 
		_: destMoniker 
		_: resultReference 
		_: false.
	hresult = S_OK   " MK_S_HIM "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value!  
removeIID: anIID
        " Private - remove the interface pointer binding class registration of
        the interface whose IID is the interface ID GUID <anIID>. "

	OLEInterfacePointer removeInterfacePointerClassForIID: anIID.!  
CoDosDateTimeToFileTime: nDosDate _: nDosTime _: resultReference
		" Convert the DOS date/time values into a FILETIME
		and store the result into the <resultReference>.
		Answer whether the conversion succeeded. "

	| resultValue hresult |
	resultValue := OLEStructure forReturnValue: #FILETIME.
	hresult := self invokeCoDosDateTimeToFileTime: nDosDate 
		_: nDosTime 
		_: resultValue.
	resultReference value: resultValue asTimeStamp.
	^hresult
	!  
CoFileTimeToDosDateTime: aFILETIME _: resultReferenceDosDate _: resultReferenceDosTime
		" Convert the FILETIME value <aFILETIME> to an MSDOS date and time.
		Answer whether the conversion was successful. "

	| resultValueDosDate resultValueDosTime succeeded |
	resultValueDosDate := ExternalBuffer new: 2.
	resultValueDosTime := ExternalBuffer new: 2.
	succeeded := self invokeCoFileTimeToDosDateTime: aFILETIME
		_: resultValueDosDate
		_: resultValueDosTime.
	succeeded
		ifTrue: [
			resultReferenceDosDate value: ( resultValueDosDate uShortAtOffset: 0 ).
			resultReferenceDosTime value: ( resultValueDosTime uShortAtOffset: 0 ) ].
	^succeeded
	!
for: anOLEObject
		" Answer an initialized instance of the receiver that is an interface for <anOLEObject>.
		Install the standard function dispatch handler for each interface function. "

	^self new
		implementor: anOLEObject;
		installStandardDispatchHandlers;
		yourself! 
localImplementorOf: anInterfacePointer
		" Answer the interface implementation binding supported by an OLE object 
		in the current session which corresponds to the interface pointer <anInterfacePointer>.
		Answer nil if the interface was not exported by this session. "

	| pointerAddress |
	anInterfacePointer isOLEInterfacePointer
		ifFalse: [ self error: 'must be an interface pointer' ].
	pointerAddress := anInterfacePointer asInterfacePointer asInteger.
	^OLESessionManager allExportedInterfaces 
		detect: [ :anInterfaceImpl |   " first test here is fast heuristic which hints at equality "
			anInterfaceImpl asInterfacePointer asInteger = pointerAddress
			and: [ anInterfaceImpl = anInterfacePointer ] ]
		ifNone: [ nil ].!   
clearResultValueAtAddress: anExternalAddress
		" Private - store zero (NULL) into the 32-bit output argument
		at <anExternalAddress>. "

	anExternalAddress isValid
		ifFalse: [ ^self ].   " NOP if client didn't provide result buffer "
	( ExternalBuffer atAddress: anExternalAddress )
		uLongAtOffset: 0 put: 0.
! 
transferResources: resources to: aRegistry type: resourceDescription
		" Private - add <resources> to <aRegistry>.  Notify the user
		that something unusual is going on. "

	resources do: [ :aResource | aRegistry add: aResource ].
	MessageBox
		notify: 'OLESessionManager Initialization Warning'
		withText: resources size printString, ' ', resourceDescription, 
			' have been transferred to a new finalization registry.'.
	!   
StgIsStorageILockBytes: anILockBytes
		" Determine whether <anILockBytes> contains an IStorage object.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeStgIsStorageILockBytes: anILockBytes asParameter!
AddRef
		" Invoke the IUnknown::AddRef function. "

	^( functionHandlers at: 2 ) evaluate! 
elementDescriptions
		" Answer the descriptions of the elements of a composite moniker. "

	| elements descriptions |
	elements := self elements.
	descriptions := elements collect: [ :aMoniker |
		aMoniker description ].
	elements do: [ :aMoniker | aMoniker release ].
	^descriptions!  
Stat: resultReference _: grfStatFlag
		" Invoke the IStorage::Stat function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEStructure forReturnValue: #STATSTG.
	hresult := self invokeStat: resultValue 
		_: grfStatFlag.
	resultReference value: resultValue.
	^hresult!
SetStateBits: grfStateBits _: grfMask
		" Invoke the IStorage::SetStateBits function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT SetStateBits(
            /* [in] */ DWORD grfStateBits,
            /* [in] */ DWORD grfMask); "

	<ole: 16 ulong ulong hresult>
	^self vtableDispatchFailed! 
asSNBParameter: stringList
		" Private - answer the list of strings in <stringList> as an SNB 
		string name block parameter (NULL-terminated list of string pointers). "

	| elementSize snbBuffer offset aStringBuffer |
	stringList size = 0
		ifTrue: [ ^nil ].
	elementSize := ExternalAddress sizeInBytes.
	snbBuffer := ExternalBuffer new: ( stringList size + 1 ) * elementSize.
	offset := 0.
    self ISSUE. self notYetImplemented.  " NEEDS WORK " 
	stringList do: [ :aString |
		self ISSUE.  " This is not correct.  We need to copy the string bodies
			to external memory? [DL 24-Jun-95] "
		aStringBuffer := aString asUnicode. 
		snbBuffer addressAtOffset: offset put: aStringBuffer asParameter.
		offset := offset + elementSize ].
	^snbBuffer!   
Revert
		" Invoke the IStorage::Revert function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Revert( void); "

	<ole: 10 hresult>
	^self vtableDispatchFailed! 
CopyTo: ciidExclude _: rgiidExclude _: snbExclude _: destStorage
		" Invoke the IStorage::CopyTo function.
		Raise an exception if an error occurs.  Answer the result code. "

	| snb hresult |
	"rgiidExclude size > 0 ifTrue: [ self ASSERT: ciidExclude = rgiidExclude size ]."
	snb := self asSNBParameter: snbExclude.
    hresult := self invokeCopyTo: ciidExclude
        _: ( self asIIDArrayParameter: rgiidExclude )
        _: snb
        _: destStorage asParameter.
	snb notNil ifTrue: [ snb free ].
	^hresult!  
invokeRenameElement: pwcsOldName _: pwcsNewName
		" Private - invoke the IStorage::RenameElement function. "

	" HRESULT RenameElement(
            /* [string][in] */ const OLECHAR *pwcsOldName,
            /* [string][in] */ const OLECHAR *pwcsNewName); "

	<ole: 13 structIn structIn hresult>
	^self vtableDispatchFailed!   
invokeOpenStream: pwcsName _: reserved1 _: grfMode  _: reserved2 _: ppstm
		" Private - invoke the IStorage::OpenStream function. "

	" HRESULT OpenStream(
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ void *reserved1,
            /* [in] */ DWORD grfMode,
            /* [in] */ DWORD reserved2,
            /* [out] */ IStream **ppstm); "

	<ole: 4 structIn structIn long long structOut hresult>
	^self vtableDispatchFailed!
invokeDestroyElement: pwcsName
		" Private - invoke the IStorage::DestroyElement function. "

	" HRESULT DestroyElement(
            /* [string][in] */ const OLECHAR *pwcsName); "

	<ole: 12 structIn hresult>
	^self vtableDispatchFailed!  
SetElementTimes: elementName _: cTime _: aTime _: mTime
		"Invoke the IStorage::SetElementTimes function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSetElementTimes: ( self asUnicodeParameter: elementName )
		_: ( self asFileTimeParameter: cTime )
		_: ( self asFileTimeParameter: aTime )
		_: ( self asFileTimeParameter: mTime )!  
OpenStorage: storageName _: pstgPriority _: grfMode _: snbExclude _: reserved _: resultReference
        " Invoke the IStorage::OpenStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

    | snb resultValue hresult |
    snb := self asSNBParameter: snbExclude.
    resultValue := IStoragePointer forReturnValue.
    hresult := self invokeOpenStorage: ( self asUnicodeParameter: storageName )
        _: pstgPriority asParameter
        _: grfMode
        _: snb
        _: reserved
        _: resultValue asParameter.
    snb notNil ifTrue: [ snb free ].
    resultReference value: resultValue.
    ^hresult! 
invokeStat: pstatstg _: grfStatFlag
		" Private - invoke the IStorage::Stat function. "

	" HRESULT Stat(
            /* [out] */ STATSTG *pstatstg,
            /* [in] */ DWORD grfStatFlag); "

	<ole: 17 structOut ulong hresult>
	^self vtableDispatchFailed!
Commit: grfCommitFlags
		" Invoke the IStorage::Commit function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Commit(
            /* [in] */ DWORD grfCommitFlags); "

	<ole: 9 long hresult>
	^self vtableDispatchFailed! 
invokeCreateStream: pwcsName _: grfMode _: reserved1 _: reserved2 _: ppstm
		" Private - invoke the IStorage::CreateStream function. "

	" HRESULT CreateStream(
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [in] */ DWORD grfMode,
            /* [in] */ DWORD reserved1,
            /* [in] */ DWORD reserved2,
            /* [out] */ IStream **ppstm); "

	<ole: 3 structIn long long long structOut hresult>
	^self vtableDispatchFailed!   
invokeEnumElements: reserved1 _: reserved2 _: reserved3 _: ppenum
		" Private - invoke the IStorage::EnumElements function. "

	" HRESULT EnumElements(
            /* [in] */ DWORD reserved1,
            /* [size_is][unique][in] */ void *reserved2,
            /* [in] */ DWORD reserved3,
            /* [out] */ IEnumSTATSTG **ppenum); "

	<ole: 11 ulong structIn ulong structOut hresult>
	^self vtableDispatchFailed!  
EnumElements: reserved1 _: reserved2 _: reserved3 _: resultReference
		" Invoke the IStorage::EnumElements function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumSTATSTG.
	hresult := self invokeEnumElements: reserved1 
		_: reserved2 
		_: reserved3
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
invokeOpenStorage: pwcsName _: pstgPriority _: grfMode _: snbExclude _: reserved _: ppstg
		" Private - invoke the IStorage::OpenStorage function. "

	" HRESULT OpenStorage(
            /* [string][unique][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ IStorage *pstgPriority,
            /* [in] */ DWORD grfMode,
            /* [unique][in] */ SNB snbExclude,
            /* [in] */ DWORD reserved,
            /* [out] */ IStorage **ppstg); "

	<ole: 6 structIn handle long structIn long structOut hresult>
	^self vtableDispatchFailed!
SetClass: clsid
		" Invoke the IStorage::SetClass function.
		Raise an exception if an error occurs.  Answer the result code. "

	"HRESULT SetClass(
            /* [in] */ REFCLSID clsid); "

	<ole: 15 structIn hresult>
	^self vtableDispatchFailed!  
OpenStream: streamName  _: reserved1 _: grfMode _: reserved2 _: resultReference
		" Invoke the IStorage::OpenStream function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IStreamPointer forReturnValue.
    hresult := self invokeOpenStream: ( self asUnicodeParameter: streamName )
		_: reserved1
		_: grfMode 
		_: reserved2
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!
asIIDArrayParameter: iidList
		" Private - pack the IID's in <iidList> into an IID FAR * array buffer. "

	| elementSize iidArrayBuffer offset |
	iidList size = 0
		ifTrue: [ ^nil ].
	elementSize := GUID sizeInBytes.
	iidArrayBuffer := ExternalBuffer new: iidList size * elementSize.
	offset := 0.
	iidList do: [ :iid |
		iidArrayBuffer bytesAtOffset: offset put: iid.
		offset := offset + elementSize ].
	^iidArrayBuffer!
CreateStream: streamName _: grfMode _: reserved1 _: reserved2 _: resultReference
		" Invoke the IStorage::CreateStream function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IStreamPointer forReturnValue.
	hresult := self invokeCreateStream: ( self asUnicodeParameter: streamName )
		_: grfMode 
		_: reserved1 
		_: reserved2
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
invokeCreateStorage: pwcsName _: grfMode _: dwStgFmt _: reserved2 _: ppstg
		" Private - invoke the IStorage::CreateStorage function. "

	" HRESULT CreateStorage(
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [in] */ DWORD grfMode,
            /* [in] */ DWORD dwStgFmt,
            /* [in] */ DWORD reserved2,
            /* [out] */ IStorage **ppstg); "

	<ole: 5 structIn long long long structOut hresult>
	^self vtableDispatchFailed! 
invokeSetElementTimes: pwcsName _: pctime _: patime _: pmtime
		" Private - invoke the IStorage::SetElementTimes function. "

	" HRESULT SetElementTimes(
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [in] */ const FILETIME *pctime,
            /* [in] */ const FILETIME *patime,
            /* [in] */ const FILETIME *pmtime); "

	<ole: 14 structIn structIn structIn structIn hresult>
	^self vtableDispatchFailed!  
invokeCopyTo: ciidExclude _: rgiidExclude _: snbExclude _: pstgDest
		" Private - invoke the IStorage::CopyTo function. "

	" HRESULT CopyTo(
            /* [in] */ DWORD ciidExclude,
            /* [size_is][unique][in] */ const IID *rgiidExclude,
            /* [unique][in] */ SNB snbExclude,
            /* [unique][in] */ IStorage *pstgDest); "

    <ole: 7 long structIn structIn handle hresult>
    ^self vtableDispatchFailed!   
invokeMoveElementTo: pwcsName _: pstgDest _: pwcsNewName _: grfFlags
		" Private - invoke the IStorage::MoveElementTo function. "

	" HRESULT MoveElementTo(
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ IStorage *pstgDest,
            /* [string][in] */ const OLECHAR *pwcsNewName,
            /* [in] */ DWORD grfFlags); "

	<ole: 8 structIn handle structIn long hresult>
	^self vtableDispatchFailed!  
RenameElement: elementName _: newElementName
		" Invoke the IStorage::RenameElement function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeRenameElement: ( self asUnicodeParameter: elementName )
		_: ( self asUnicodeParameter: newElementName )!
MoveElementTo: elementName _: destStorage _: newElementName _: grfFlags
		" Invoke the IStorage::MoveElementTo function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeMoveElementTo: ( self asUnicodeParameter: elementName )
		_: destStorage asParameter
		_: ( self asUnicodeParameter: newElementName )
		_: grfFlags!
CreateStorage: storageName _: grfMode _: dwStgFmt _: reserved2 _: resultReference
		" Invoke the IStorage::CreateStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IStoragePointer forReturnValue.
	hresult := self invokeCreateStorage: ( self asUnicodeParameter: storageName )
		_: grfMode 
		_: dwStgFmt 
		_: reserved2
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
DestroyElement: elementName
		"Invoke the IStorage::DestroyElement function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeDestroyElement: ( self asUnicodeParameter: elementName )!  
parseDisplayName: aDisplayName
        " Parse the object display name <aDisplayName> into a moniker to the object.
        Answer the moniker. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface ParseDisplayName: nil
        _: aDisplayName
        _: nil asValueReference
        _: resultReference.
    ^resultReference value!
parseDisplayName: aDisplayName
	bindContext: aBindContext 
	charsConsumedReference: charsConsumedReference
        " Parse the object display name <aDisplayName> into a moniker to the object.
        <aBindContext> points to the bind context to be used to accumulate bound objects.
        <charsConsumedReference> points to the number of characters parsed 
        from the display name.  Answer the moniker. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface ParseDisplayName: aBindContext
        _: aDisplayName
        _: charsConsumedReference
        _: resultReference.
    ^resultReference value!   
parseDisplayName: aDisplayName bindContext: aBindContext
        " Parse the object display name <aDisplayName> into a moniker to the object.
        <aBindContext> is the bind context to be used to accumulate bound objects.
        Answer the moniker. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface ParseDisplayName: aBindContext
        _: aDisplayName
        _: nil asValueReference
        _: resultReference.
    ^resultReference value! 
CoBuildVersion
		"Answer an array containing the major and minor version numbers of the COM library. "

	| dw |
	dw := ExternalLong fromString: self invokeCoBuildVersion.
	^Array with: dw highHalf with: dw lowHalf!   
logHeader: stack
        " Private - log function invocation header information to the OLE trace log. "

    | method receiver message |
    method := stack methodAt: 1.
    receiver := stack receiverAt: 1.
    message := receiver class name.
    receiver class ~~ method classField
        ifTrue: [ message := message, '(', method classField name, ')' ].
    message := message, '>>', method selector printString.
    self oleTRACE: 'Invoking ', message.
    self oleTRACE: '    ', receiver printString.

! 
coerceToPointer
        " Private - force the receiver to invoke its functions through an external VTable. "

    interface notNil
        ifTrue: [ interface := interface asInterfacePointer ].!
objectCLSID
		" Answer the CLSID of objects which are instantiated by the receiver. "

	^self objectClass clsid!   
OleCreateFromData: aDataObject _: iid _: renderopt _: aFormatEtc _: aClientSite _: aStorage _: resultReference
        " Create an embedded object from the specified data object <aDataObject>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreateFromData: aDataObject asParameter
        _: iid
        _: renderopt
        _: aFormatEtc
        _: aClientSite asParameter
        _: aStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!   
invokeOleLoadFromStream: pStm _: iidInterface _: ppvObj
        "Private - WWINOLEAPI  OleLoadFromStream( 
			LPSTREAM pStm, REFIID iidInterface, LPVOID FAR* ppvObj);"

    <api: OleLoadFromStream handle structIn structOut hresult>
    ^self apiCallFailed! 
removeInterfacePointerClassForIID: anIID
        " Private - unregister <aClass> as the interface pointer binding class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	iidEntry := self iidMap at: anIID  " ptr, reference, impl "
		ifAbsent: [ ^nil ].
	iidEntry at: 1 put: nil.
	iidEntry = #( nil nil nil )
		ifTrue: [ self iidMap removeKey: anIID ].!
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^false!
elements
		" Answer the elements of a composite moniker. "

	| anEnumerator contents |
	anEnumerator := self elementsEnumerator.
	anEnumerator isNil
		ifTrue: [ ^ #() ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents! 
registerIID: anIID forClass: aClass
        " Private - register <aClass> as the interface implementation binding class representing
        the interface whose IID is the interface ID GUID <anIID>. "

	OLEInterfacePointer registerInterfaceImplementationClass: aClass forIID: anIID.!   
ownedMemoryRegistry
		" Private - answer the registry containing OLE memory addresses owned
		by clients in the current session. "

	^OwnedMemoryRegistry!
CreateDataCache: controllingIUnknown _: clsid _: iid _: resultReference
		"Create a data cache object, optionally as part of an aggregate
		controlled by the object <controllingIUnknown>.
		Optionally specify the GUID <clsid> which is to be used to generate
		default icon labels (usually NULL).
		Obtain the interface specified by the GUID <iid> and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeCreateDataCache: controllingIUnknown asParameter
		_: clsid 
		_: iid 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult

!  
iDropTarget: anIDropTarget
        "Private - set the receiver's IDropTarget interface to anIDropTarget."

     self propertyAt: #iDropTarget put: anIDropTarget!  
queryInterface: iid
        "Query the receiver for the interface specified by the GUID <iid>.
		Answer the interface if it is supported, else answer nil. "

    | resultReference |
	resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
	self QueryInterface: iid _: resultReference.
    ^resultReference value! 
unpackElement: index fromBuffer: elementBuffer
        " Private - unpack the <index>-th element in the <elementBuffer>,
        which was created by #allocateElementBuffer. "

	^self elementClass forReturnValue
		setBytes: ( elementBuffer 
			bytesAtOffset: ( self elementSize * ( index - 1 ) ) 
			count: self elementSize );
		yourself!
hash
        "Answer the integer hash value of the receiver."

	^interface hash!   
asGUID
		"Answer the GUID specified by the bytes of the receiver."

    ^self asArray asByteArray asGUID!  
validateHandler: aHandler for: eptDescription
        " Private - validate the function handler <aHandler> which
        has been registered for the interface function described
        by <eptDescription>. "

    ( #( 'DragEnter' 'DragOver' 'Drop' ) includes: eptDescription name )
        ifFalse: [ ^super validateHandler: aHandler for: eptDescription ].

    " special guys with #structValue arg splitup for POINTL "
    ( aHandler isMessage
    and: [ ( Message numberOfArgumentsFor: aHandler selector ) ~= ( eptDescription argumentTypes size - 1 ) ] )
        ifTrue: [
            MessageBox warning:
                self name,
                ' VTable handlers problems: argument count mismatch for ',
                eptDescription name ].!  
forReturnValue: anIID
		" Answer a new instance of the receiver with IID <anIID>.
		to be used to obtain an OUT parameter return value which 
		enumerates interface or data structure elements.
		Since in general the ownership responsibility of an OUT parameter 
		is transferred to the caller, mark the interface as needing finalization
		to ensure that it is released by the caller. "

	| aClass |
	aClass := self elementTypeOfIID: anIID.
	aClass isNil  " element type not registered "
		ifTrue: [ self error: 'unsupported enumeration interface' ].
	^self forIID: anIID 
		binding: self interfacePointerClass new 
		elementClass: aClass!  
asGUID
		" Answer the GUID represented by the receiver. "

	^self! 
isOLEStructure
	"Answer <true> if the receiver supports the OLEStructure protocol."

	^false!  
privateClose
		"Private - free the DLL referenced by the receiver and invalidate the receiver. "

	super close.
	self uLongAtOffset:0 put: 0.
	! 
close
        " Free the DLL referenced by the receiver and invalidate the handle. "

	[ self class supportAllOLE
		ifTrue: [ self OleUninitialize ]
		ifFalse: [ self CoUninitialize ]
		] on: Error
			do: [ :ex | OLEDevelopmentWarning signal: 
				'Error uninitializing OLEDLL: ', ex description ].
	self privateClose.
	!   
iidFromString: aString
		" Answer a new instance of the receiver that is the IID
		corresponding to the display string <aString>. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current IIDFromString: aString
		_: resultReference.
	^resultReference value
!   
commonPrefixWith: aMoniker
		" Answer the longest common prefix shared by the receiver and <aMoniker>. "

	| resultReference hresult |
	resultReference := self class new asValueReference.
	hresult := interface CommonPrefixWith: aMoniker _: resultReference.
	hresult = S_OK  " MK_E_NOPREFIX, MK_S_ME, MK_S_HIM, MK_S_US "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value!   
dragSourceGlobal
        "Enable the receiver as an OLE drag source."

    self dragSource.
    self dragSessionClass: WinDragDropSession


!  
invokeStgCreateDocfileOnILockBytes: plkbyt _: grfMode _: reserved _: ppstgOpen
		"Private - WINOLEAPI StgCreateDocfileOnILockBytes(
						ILockBytes FAR *plkbyt,
                    DWORD grfMode,
                    DWORD reserved,
                    IStorage FAR * FAR *ppstgOpen);"

    <api: StgCreateDocfileOnILockBytes handle ulong ulong structOut hresult>
    ^self apiCallFailed!  
decrementLockCount
		" Private - decrement the number of locks on the receiver.
		Answer the lock count. "

	self class decrementLockCount.
	^self lockCount: ( self lockCount - 1 )!
apiCallFailed
	"Private - Initiate a walkback indicating an API primitive call failure."

    ^self exception signal!  
asUnicodeParameter: aStringOrNil
		" Private - answer aStringOrNil as a UNICODE string parameter. "

	^aStringOrNil isNil
		ifTrue: [ nil ]
		ifFalse: [ aStringOrNil asUnicode asParameter ]!   
asFileTimeParameter: aFileTimeOrTimeStamp
		" Private - answer <aFileTimeOrTimeStamp> as a FILETIME parameter. "

	^( aFileTimeOrTimeStamp isTimeStamp
		ifTrue: [
			( OLEStructure classForStructureNamed: #FILETIME ) fromTimeStamp: aFileTimeOrTimeStamp ]
		ifFalse: [ aFileTimeOrTimeStamp ] )  " already a FILETIME "
			asParameter!   
asSNBParameter: stringList
		" Private - answer the list of strings in <stringList> as an SNB 
		string name block parameter (NULL-terminated list of string pointers). "

	| elementSize snbBuffer offset aStringBuffer |
	stringList size = 0
		ifTrue: [ ^nil ].
	elementSize := ExternalAddress sizeInBytes.
	snbBuffer := ExternalBuffer new: ( stringList size + 1 ) * elementSize.
	offset := 0.
    self ISSUE. self notYetImplemented.  " NEEDS WORK " 
	stringList do: [ :aString |
		self ISSUE.  " This is not correct.  We need to copy the string bodies
			to external memory? [DL 24-Jun-95] "
		aStringBuffer := aString asUnicode. 
		snbBuffer addressAtOffset: offset put: aStringBuffer asParameter.
		offset := offset + elementSize ].
	^snbBuffer!   
stringFromResultValue: anExternalAddress
		" Private - answer the string at address <anExternalAddress>. 
		The string pointer references the Unicode byte encoding of the string. 
		The memory containing the Unicode string is released.. "

	| aString |
	aString := ( UnicodeStringBuffer atAddress: anExternalAddress ) asString.
	anExternalAddress free.
	^aString !  
exceptionForHresult: hresult
		" Private - answer an exception for the HRESULT error code <hresult>. "

	( HRESULT succeeded: hresult )
		ifTrue: [    " VM problem, should not be here "
			^Error new messageText: 
				'Unexpected HRESULT primitive failure ( ',
				( hresult radix: 16 ), ' )' ].
	^OLEError new hresult: hresult!  
createStringResultValue
		" Private - answer a value to pass for an output parameter which
		returns a string. "

	^OLEMemoryAddress forReturnValue!  
invokeCoLoadLibrary: lpszLibName _: bAutoFree
        "Private - WINOLEAPI_(HINSTANCE) CoLoadLibrary(
			LPOLESTR lpszLibName, BOOL bAutoFree);"

    <api: CoLoadLibrary structIn boolean ulongReturn>
    ^self apiCallFailed! 
invokeMkParseDisplayName: pbc _: szUserName _: pchEaten _: ppmk
        "Private - WINOLEAPI  MkParseDisplayName(
				LPBC pbc, LPCOLESTR szUserName,
				ULONG FAR * pchEaten, LPMONIKER FAR * ppmk);"

    <api: MkParseDisplayName handle structIn structOut structOut hresult>
    ^self apiCallFailed! 
allocatedInterfacesRegistry
		" Private - answer the registry containing OLE interfaces for which an interface
		invocation structure has been allocated in external memory in the current session. "

	^AllocatedInterfacesRegistry! 
GetRunningObjectTable: reserved _: resultReference
		" Obtain a pointer to the running object table for the caller's context
		and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IRunningObjectTablePointer forReturnValue.
	hresult := self invokeGetRunningObjectTable: reserved 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
!
optimizeBinding
		" Private - force the receiver to invoke its functions through an interface implementation
		connected directly to a local implementing object, if possible. "

	| anInterfaceImpl |
	self isOLEInterfacePointer
		ifTrue: [
			anInterfaceImpl := OLEInterfaceImplementation localImplementorOf: interface.
			anInterfaceImpl notNil
				ifTrue: [ 
					interface doesNotNeedFinalization.  " throw away this pointer instance "
					interface := anInterfaceImpl ].
			].
!   
createStringResultValue
		" Private - answer a value to pass for an output parameter which
		returns a string. "

	^OLEMemoryAddress forReturnValue!  
memoryAllocator
		" Private - answer the OLE memory allocator which is used to allocate 
		memory referenced by instances of the receiver. "

	^IMalloc taskMemoryAllocator!  
newBindContext
		" Answer a newly allocated bind context. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current CreateBindCtx: 0 _: resultReference.
	^resultReference value!  
invokeStringFromCLSID: rclsid _: lplpsz
        "Private - WINOLEAPI StringFromCLSID(REFCLSID rclsid, LPOLESTR FAR* lplpsz);"

	<api: StringFromCLSID structIn structOut hresult>
	^self apiCallFailed

!   
guidAtAddress: anExternalAddress
		" Private - answer the GUID at address <anExternalAddress>. "

	anExternalAddress isValid
		ifFalse: [ ^nil ].
	^GUID fromAddress: anExternalAddress! 
interfaces
        " Private - answer the receiver's interface storage dictionary.
        The key is the IID of a supported interface and the value is the
        instance of that interface supported with the receiver. "

	^interfaces! 
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	interfaces := nil.! 
allocatedInterfaces
		" Private - answer the interfaces supported by the receiver
		which have been allocated during its lifetime. "

	^Set new
		add: self innerUnknown;
		addAll: self interfaces values;
		yourself!
registerAllocatedInterface: anInterface iid: iid
		" Private - the interface <anInterface> has been allocated for the receiver.
		Register the supported interface in the receiver's table of allocated interfaces. "

	self interfaces at: iid put: anInterface.!
initialInterfaceAllocationSize
		" Private - answer the initial size of the interface storage dictionary.
		The value should be the number of interfaces expected to
		be supported by the receiver during its lifetime.
		May be reimplemented by subclasses to optimize instance size. "

	^self class initialInterfaceAllocationSize!
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	self interfaces do: [ :anInterface |
		aOneArgBlock value: anInterface ].!   
createInterfaceForIID: iid
		" Private - answer a new instance of the interface identified by the GUID <iid>
		on the receiver.  Answer nil if the interface is not supported. 
		This method should be reimplemented by subclasses. "

	^nil!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the GUID <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	| anInterface |
	anInterface := self interfaces at: iid ifAbsent: [ nil ].
	anInterface isNil
		ifTrue: [
			anInterface := self createInterfaceForIID: iid.
			anInterface notNil
				ifTrue: [ self registerAllocatedInterface: anInterface iid: iid ] ].
	^anInterface!  
initializeInterfaces
		" Private - Allocate any interfaces which are expected to be required 
		during the object's lifetime.  The inner IUnknown is always allocated.
		Allocate the interface storage dictionary.
		May be reimplemented by subclasses.  Subclass implementations
		should invoke the superclass method first, then use the
		#registerAllocatedInterface:iid: to register any interfaces that are created. "

	super initializeInterfaces.
	interfaces := Dictionary new.!
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^self class iid!   
advf
		" Answer the ADVF advise flags "

	^self uLongAtOffset: 20! 
releaseAdviseSink
		" Private - release the advise sink pointer, if any. "

	self adviseSink notNil
		ifTrue: [
			adviseSink release.
			adviseSink := nil ].! 
pAdvSink
		" Private - answer the pointer to the IAdviseSink interface "

	^self addressAtOffset: 24!  
formatEtc
		" Answer the FORMATETC structure. "

	^self structureAtOffset: 0 type: #FORMATETC! 
releaseResources
		" Private - release resources owned by the receiver. "

	self releaseAdviseSink.
	super releaseResources.! 
dwConnection
		" Answer the advise connection token. "

	^self uLongAtOffset: 28!  
adviseSink
		" Answer the IAdviseSink interface. "

	adviseSink isNil
		ifTrue: [
			adviseSink := self interfaceAtOffset: 24 type: IAdviseSink.
			adviseSink isNil
				ifTrue: [ self doesNotNeedFinalization ]
				ifFalse: [ adviseSink := adviseSink separateReference ].
			].
	^adviseSink!  
setBytes: aByteObject
		" Private - set the contents of the receiver to <aByteObject>. "

	self isOLEInterfacePointer
		ifFalse: [ self error: 'only pointer references can have bytes set' ].
	interface setBytes: aByteObject.!
fromDisplayName: displayName bindContext: aBindContext
		" Answer a new instance of the receiver for the object referenced by <displayName>. "

	^self fromDisplayName: displayName 
		bindContext: aBindContext
		charsConsumed: nil asValueReference!  
incrementLockCount
		" Increment the number of locks on the object server application.
		Answer the lock count. "

	^self lockCount: ( self lockCount + 1 )!  
LockServer: aBoolean
        " Private - perform the IClassFactory::LockServer function.
        Answer the result code. "

	self ISSUE.  " The external object lock tactic comes for the OLE
		Programmer's Reference discussion of this operation.
		However, it is not done by KB's sample.  Consider whether
		this heavy-handedness is really necessary.  [DL 16-Oct-95] " 
	" create a strong lock on the class factory; artifically reference count
		the receiver's IUnknown interface to ensure that the object
		remains stable during this call " 
	self registeredUnknown incrementReferenceCount.
	[
	aBoolean
		ifTrue: [ 
			self incrementLockCount.
			self registeredUnknown lockObject ]
		ifFalse: [ 
			self decrementLockCount.
			self registeredUnknown unlockObject ].
	] on: OLEError
		do: [ :ex |
			self registeredUnknown decrementReferenceCount.
			^ex hresult ].
	self registeredUnknown decrementReferenceCount.
	aBoolean
		ifFalse: [ self class checkInUse: self ].
	^S_OK!  
specialSessionResources: aDictionary
		" Private - set the map of OLE resources owned or allocated
		by the current session which are handled specially at session startup/shutdown. "

	SpecialSessionResources := aDictionary.! 
removeDragDrop
		" Remove OLE drag/drop as the default system drag/drop type. "

	DragDropSession defaultClass: nil.!  
newExternalStructure
		" Answer a new instance of the receiver whose structure bytes
		are allocated in external memory using the OLE task allocator. "

	^self atAddress: ( OLEMemoryAddress allocateMemory: self sizeInBytes )! 
createGenericCompositeMoniker: firstMoniker with: nextMoniker
        " Create a new generic composite moniker which is formed by 
		concatentating <firstMoniker> with <nextMoniker>.
		Answer a new instance of the receiver for the new composite moniker. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current CreateGenericComposite: firstMoniker
		_: nextMoniker
        _: resultReference.
    ^resultReference value! 
uLongResultAtAddress: anExternalAddress put: anInteger
		" Private - store the ULONG output argument value <anInteger> 
		into the caller-provided memory location addressed at <anExternalAddress>. "

	anInteger isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress ) 
		uLongAtOffset: 0 
		put: anInteger.!   
resetClassFactoryRegistry
		" Private - reset the registry of class factories which have been registered
		with OLE during the current session. "

	self classFactoryRegistry: nil.!  
lockCount
		" Answer the number of locks on the object server application. "

	^LockCount! 
invokeOleRegGetMiscStatus: clsid _: dwAspect _: pdwStatus
        "Private - WINOLEAPI OleRegGetMiscStatus (
                               REFCLSID clsid, DWORD dwAspect,
                               DWORD FAR* pdwStatus); "

	| hresult |
	<api: OleRegGetMiscStatus structIn ulong structOut hresult>
	hresult := self apiFailureReason.
	( hresult = REGDB_E_CLASSNOTREG 
	or: [ hresult = REGDB_E_KEYMISSING ] )
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!   
invokeCoRegisterClassObject: rclsid _: pUnk _: dwClsContext _: flags _: lpdwRegister
        "Private - WINOLEAPI  CoRegisterClassObject(
                    REFCLSID rclsid, LPUNKNOWN pUnk,
                    DWORD dwClsContext, DWORD flags, LPDWORD lpdwRegister); "

    <api: CoRegisterClassObject structIn handle ulong ulong structOut hresult>
    ^self apiCallFailed!   
printOn: aStream
        " Append a text description of the receiver to <aStream>. "

	super printOn: aStream.
	aStream 
		nextPutAll: ' {';
		nextPutAll: ( self hasExternalResources
			ifTrue: [
				self externalMemoryAddress asInteger 
					printPaddedWith: $0 to: 8 base: 16 ]
			ifFalse: [ 'unallocated' ] );
		nextPutAll: '}'.!   
objectClass
		" Private - answer the class whose instance are created by the receiver. "

	^objectClass!   
invokeSetConvertStg: pStg _: fConvert
        "Private - WINOLEAPI SetConvertStg(
            LPSTORAGE pStg, BOOL fConvert);"

    <api: SetConvertStg handle boolean hresult>
    ^self apiCallFailed! 
getDisplayName
        " Answer the display name of this moniker. "

	| resultReference aBindContext |
	resultReference := nil asValueReference.
	aBindContext := IBindCtx newBindContext.
    interface GetDisplayName: aBindContext _: nil _: resultReference.
	aBindContext release.
    ^resultReference value
! 
finalize
		" Private - the receiver is no longer referenced by any object in the system 
		and is about to be destroyed.  Release any resources whose ownership
		is controlled by the receiver. "

	self releaseResources.! 
displayWarningMessages
		" Private - answer whether to display warning messages.
		Suppress these in the product build; enable in internal dev system. "

	self ISSUE.  " Figure out what to do about this. [DL 18-Oct-95] " 
	true ifTrue: [ ^true ].
	^self isInLibrary not!  
defaultAction
        "Display a notifier and then continue."

	SessionModel current isRunTime
		ifTrue: [ ^self ].
	MessageBox notify: 'OLE Development Warning' withText: self description.!   
defaultAction
        "Display a notifier and then continue."

	self class displayWarningMessages
		ifFalse: [ ^self ].
	^MessageBox notify: 'OLE Warning' withText: self description!   
iid: anIID
		" Private - set the the interface ID which uniquely identifies instances 
		of the receiver to the GUID <anIID>. "

 	( iid notNil and: [ anIID notNil and: [ iid ~= anIID ] ] )
		ifTrue: [   " maybe initialization bug that developer should know about "
			OLEDevelopmentWarning signal: 'Changing the IID of ', self name,
				' from ', iid printString, ' to ', anIID printString, '.' ].
	iid := anIID.!
activeObjectCount
		" Answer the number of objects created by the receiver
		which are still in use by clients. "

	^self activeObjects size! 
removeSessionEventHandlers
    " Private - remove the image startup and shutdown event handlers.
		OLESessionManager removeSessionEventHandlers "

	#( #startup #aboutToSaveImage #shutdown ) do: [ :anEvent |
         SessionModel current 
             removeActionsWithReceiver: self 
             forEvent: anEvent ].

	( ExternalObjectTable isInLibrary
	and: [ ExternalObjectTable libraryName ~= OLESessionManager libraryName ] )
		ifTrue: [   " restore original handlers "
			ExternalObjectTable registerSessionEventHandlers ].
!  
GetHGlobalFromILockBytes: anILockBytes _: resultReference
		" Obtain the global memory handle from an ILockBytes created by CreateILockBytesOnHGlobal.
		Raise an exception if an error occurs.  Answer the result code. "

	| ulongHGlobal hresult |
	ulongHGlobal := ExternalLong new.
	hresult := self invokeGetHGlobalFromILockBytes: anILockBytes asParameter 
		_: ulongHGlobal.
	resultReference value: 
		( self globalMemoryAddressFromHandleResult: ulongHGlobal asUnsignedInteger ).
	^hresult!  
unimplementedFunction
		" Answer the HRESULT value for an unimplemented function. "

	^E_NOTIMPL!  
decrementReferenceCount
		" Decrement the reference count of the interface referenced by the receiver.
		Do not destroy the reference, allowing the client to continue using the interface.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

	^self Release!   
registerIID
        " Private - register the receiver as the interface class for its IID.
		Do nothing for the receiver - its superclass IStorage is correctly
		registered as the class for the (shared) IID. "!  
pathName: aFileName
		" Open the storage in the file system named <aFileName>.
		Answer a new instance of the receiver on the storage object. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current StgOpenStorage: aFileName
		_: nil 
		_: STGM_TRANSACTED | STGM_READWRITE | STGM_SHARE_DENY_WRITE 
		_: nil 
		_: 0 
		_: resultReference.
	^resultReference value!  
removeIID
        " Private - remove the registration of the receiver as the interface class for its IID.
		Do nothing for the receiver - its superclass IStorage manages the registration
		for the (shared) IID. "!  
createTemporaryFile
		" Create a temporary structured storage in the file system.
		Answer a new instance of the receiver on the storage object. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current StgCreateDocfile: nil
		_: STGM_CREATE | STGM_DELETEONRELEASE 
				| STGM_READWRITE | STGM_SHARE_EXCLUSIVE
		_: 0 
		_: resultReference.
	^resultReference value!  
getClassFile: aFileName
		" Answer the CLSID associated with the storage object 
		in the file named <aFileName>. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current GetClassFile: aFileName 
		_: resultReference.
	resultReference value!
newFile: aFileName
		" Create a new structured storage in the file system named <aFileName>.
		Answer a new instance of the receiver on the storage object. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current StgCreateDocfile: aFileName
		_: STGM_CREATE "| STGM_TRANSACTED" 
				| STGM_READWRITE | STGM_SHARE_EXCLUSIVE
		_: 0 
		_: resultReference.
	^resultReference value!
setTimes: aFileName created: cTime lastAccessed: aTime lastModified: mTime
		" Set the creation, access, and modification times of the storage
		named <aFileName> in the file system to the specified TimeStamp values. "

    OLEDLL current StgSetTimes: aFileName
		_: cTime
		_: aTime
		_: mTime!
pathNameReadOnly: aFileName
		" Open the storage in the file system named <aFileName> in readOnly access mode.
		Answer a new instance of the receiver on the storage object. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEDLL current StgOpenStorage: aFileName
		_: nil 
		_: STGM_READ | STGM_SHARE_DENY_WRITE 
		_: nil 
		_: 0 
		_: resultReference.
	^resultReference value! 
isStorageFile: aPathName
		" Answer whether the file named <aPathName> is a storage object. "

	^[ ( OLEDLL current StgIsStorageFile: aPathName ) = S_OK ]
		on: OLEError
		do: [ :ex | 
			ex hresult = STG_E_FILENOTFOUND
				ifTrue: [ ^false ].
			ex pass ].!
registeredUnknown
		" Private - answer the separately reference counted
		IUnknown which was used to register the receiver with OLE.
		Answer nil if the receiver is not registered with OLE. "

	^registeredUnknown!
OleSetAutoConvert: clsidOld _: clsidNew
        " Tag an object of class <clsidOld> for automatic conversion to a
        different class <clsidNew> on being loaded."

    "WINOLEAPI OleSetAutoConvert(REFCLSID clsidOld, REFCLSID clsidNew);"

    <api: OleSetAutoConvert structIn structIn hresult>
    ^self apiCallFailed!  
trackResources
		" Private - answer whether OLE resources owned by clients in the current session
		should be recorded in finalization registries. "

	^TrackResources!   
allExportedInterfaces
		" Private - answer a collection containing the OLE interface implementations 
		which have been exported from this session. "

	^ExternalObjectTable current registeredObjects
        select: [ :anExternalObject | anExternalObject isOLEInterfaceImplementation ]

!
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host system procedure call."

    ^self asInterfacePointer!  
invokeAddRef
		"Private - invoke the IUnknown::AddRef function. "

	" ULONG AddRef( void); "

	<ole: 1 ulongReturn>
	^self vtableDispatchFailed!
OleUninitialize
		" Close the OLE implementation library.  "

	" WINOLEAPI_(void) OleUninitialize(void); "

    <api: OleUninitialize none>
    ^self apiCallFailed!
hash
        "Answer the integer hash of the receiver."

	^self iid hash bitXor: self asInteger hash!  
interfacePointerClass
		" Private - answer the interface pointer class which represents the
		same OLE interface as the receiver. "

	^OLEInterfacePointer classForIID: self iid! 
ifOLETraceEnabled: aBlock
		" Evaluate the trace logic in <aBlock> if OLE tracing
		is currently enabled for the receiver. "

	OLESessionManager traceEnabled
		ifTrue: [ aBlock value ].
! 
interfaceReferenceClass
		" Private - answer the OLE interface reference class for the receiver. "

	^OLEInterface classForIID: self iid!  
isOLEInterfaceBinding
		" Answer whether the receiver is an OLE interface binding
		which provides direct access to the raw interface functions
		of an OLE interface. "

	^true!
decrementReferenceCount
		" Decrement the reference count of the interface referenced by the receiver.
		Do not destroy the reference, allowing the client to continue using the interface.
		This service must be used when artificial reference counting on an interface is desired.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

	interface isNil
		ifTrue: [
			OLEDevelopmentWarning signal: 'Too many releases of ', self printString.
			^nil ].
	^interface decrementReferenceCount!  
next
		" Retrieve the next element in the enumeration sequence. "

    | elements |
    elements := self next: 1.
    ^elements isNil
        ifTrue: [ nil ]
        ifFalse: [ elements at: 1 ]! 
ReadClassStg: anIStorage _: resultReference
		" Get the CLSID associated with the storage <anIStorage>
		and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeReadClassStg: anIStorage asParameter
		_: resultValue.
	resultReference value: resultValue.
	^hresult!  
release
		" Decrement the reference count of the interface referenced by the receiver 
		and destroy the reference to it.  Release any resources associated with the receiver.
		Answer the value of the reference count (for diagnostic use only; may not be stable). "

	| referencedInterface refCount |
	interface isNil
		ifTrue: [
			OLEDevelopmentWarning signal: 'Too many releases of ', self printString.
			^nil ].
	" release carefully to ensure that we can never get this far twice "
	referencedInterface := interface.
	interface := nil.
	refCount := referencedInterface Release.
	super release.
	^refCount!  
createFileMoniker: aPathName
        " Create a new moniker for the file named <aPathName>.
		The file name can be either an absolute or relative path name. 
		Answer a new instance of the receiver for the new file moniker. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current CreateFileMoniker: aPathName 
		_: resultReference.
    ^resultReference value!  
classFactoryRegistry: aRegistry
		" Private - set the registry of class factories which have been registered
		with OLE during the current session. "

	ClassFactoryRegistry := aRegistry.!   
supportsIID: aGUID
		" Answer whether the receiver represents the interface identified
		by the IID <aGUID>. "

	^( super supportsIID: aGUID )
		or: [ IEnum supportsEnumeratorIID: aGUID ]! 
dispatchClone: resultReference
		" Private - dispatch the IEnum::Clone function. "

    ^( functionHandlers at: 7 ) evaluateWithArguments: ( Array
		with: resultReference )! 
invokeClone: ppenum
		"Private - invoke the IEnum::Clone function for an external caller. "

	" HRESULT Clone(
            /* [out] */ IEnum **ppenum); "

	| hresult resultReference resultDescription |

	self ifOLETraceEnabled: [ self logCallbackEntry ].

	ppenum isValid 
		ifFalse: [ ^E_INVALIDARG ].
	self clearResultValueAtAddress: ppenum.

	resultReference := nil asValueReference.
	hresult := self dispatchClone: resultReference.
	self ifOLETraceEnabled: [ 
		resultDescription := self interfaceResultDescription: resultReference ].
	( HRESULT succeeded: hresult )
		ifTrue: [ self interfaceResultAtAddress: ppenum put: resultReference value ].

	self ifOLETraceEnabled: [ 
		self logReturnValue: 'IEnum: ', resultDescription.
		self logCallbackExit: hresult ].
	^hresult!
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^iid!  
Clone: resultReference
		" Invoke the IEnum::Clone function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchClone: resultReference )! 
dispatchSkip: cElements
		" Private - dispatch the IEnum::Skip function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array 
		with: cElements )!  
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

    "self ASSERT: ( self iid isNil or: [ self iid = anIID ] )."
    iid := anIID.!  
Next: cElements _: elementBuffer _: resultReference
		" Invoke the IEnum::Next function.
		Raise an exception if an error occurs.  Answer the result code. "

   ^self checkHresult: 
		( self dispatchNext: cElements _: elementBuffer _: resultReference )!
Skip: cElements
		" Invoke the IEnum::Skip function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchSkip: cElements )!
invokeNext: celt _: rgelt _: pceltFetched
		"Private - invoke the IEnum::Next function for an external caller. "

	" HRESULT Next(
            /* [in] */ ULONG celt,
            /* [out] */ void *rgelt,
            /* [out] */ ULONG *pceltFetched); "

	| hresult elementBuffer resultReference |

	self ifOLETraceEnabled: [ self logCallbackEntry ].

	rgelt isValid 
		ifFalse: [ ^E_INVALIDARG ].
	elementBuffer := ExternalBuffer atAddress: rgelt.
	" Note that pceltFetched may be NULL if celt is one. "
	pceltFetched isValid
		ifTrue: [ self clearResultValueAtAddress: pceltFetched ]
		ifFalse: [ celt > 1 ifTrue: [ ^E_INVALIDARG ] ].

	resultReference := nil asValueReference.
	hresult := self dispatchNext: celt 
		_: elementBuffer 
		_: resultReference.
	( ( HRESULT succeeded: hresult ) 
	and: [ pceltFetched isValid ] ) 
		ifTrue: [ self uLongResultAtAddress: pceltFetched put: resultReference value ].

	self ifOLETraceEnabled: [ 
		self logReturnValue: 'Count fetched: ', resultReference value printString.
		self logCallbackExit: hresult ].
	^hresult! 
Reset
		" Invoke the IEnum::Reset function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: self dispatchReset!  
invokeSkip: celt
		"Private - invoke the IEnum::Skip function for an external caller. "

	" HRESULT Skip(
            /* [in] */ ULONG celt);"

	self ifOLETraceEnabled: [ self logCallbackEntry ].
	^self dispatchSkip: celt! 
dispatchReset
		" Private - dispatch the IEnum::Reset function. "

    ^( functionHandlers at: 6 ) evaluate!   
dispatchNext: cElements _: elementBuffer _: resultReference
		" Private - dispatch the IEnum::Next function. "

   ^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
        with: cElements
        with: elementBuffer
        with: resultReference )!  
invokeReset
		"Private - invoke the IEnum::Reset function for an external caller. "

	" HRESULT Reset( void); "

	self ifOLETraceEnabled: [ self logCallbackEntry ].
	^self dispatchReset!  
printOn: aStream
        "Append the ASCII representation
         of the receiver to <aStream>."

    super printOn: aStream.
    self isValid
        ifTrue: [ aStream nextPutAll: ' (''', self name, ''')' ].
!
isEqual: aMoniker
		" Answer whether the receiver is equal to <aMoniker>. "

	^( interface IsEqual: aMoniker ) = S_OK! 
forReturnValue
		" Answer a new instance of the receiver which is to be used
		to obtain an OUT parameter return value.  Since in general the
		ownership responsibility of an OUT parameter is transferred
		to the caller, mark the interface as needing finalization
		to ensure that it is released by the caller. "

	self error: 'inappropriate message (must specify enumerator IID)'!  
supportsIID: aGUID
		" Answer whether the receiver represents the interface identified
		by the IID <aGUID>. "

	^( super supportsIID: aGUID )
		or: [ IEnum supportsEnumeratorIID: aGUID ]! 
forReturnValue: anIID
		" Answer a new instance of the receiver with IID <anIID>.
		to be used to obtain an OUT parameter return value which 
		enumerates interface or data structure elements.
		Since in general the ownership responsibility of an OUT parameter 
		is transferred to the caller, mark the interface as needing finalization
		to ensure that it is released by the caller. "

	^self new
		iid: anIID;
		yourself! 
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

    "self ASSERT: ( self iid isNil or: [ self iid = anIID ] )."
	self propertyAt: #iid put: anIID.! 
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^self propertyAt: #iid!
Reset
		" Invoke the IEnum::Reset function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Reset( void);"

	<ole: 5 hresult>
	^self vtableDispatchFailed! 
Next: cElements _: elementBuffer _: resultReference
		" Invoke the IEnum::Next function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultReference notNil
		ifTrue: [ resultValue := ExternalLong new ].
	hresult := self 
		invokeNext: cElements 
		_: elementBuffer 
		_: resultValue.
	resultReference notNil
		ifTrue: [ resultReference value: resultValue asUnsignedInteger ].
	^hresult!
Skip: cElements
		" Invoke the IEnum::Skip function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Skip(
            /* [in] */ ULONG celt);"

	<ole: 4 ulong hresult>
	^self vtableDispatchFailed! 
invokeNext: celt _: rgelt _: pceltFetched
		" Private - invoke the IEnum::Next function. "

	" HRESULT Next(
            /* [in] */ ULONG celt,
            /* [out] */ void *rgelt,
            /* [out] */ ULONG *pceltFetched); "

	<ole: 3 ulong structOut structOut hresult>
	^self vtableDispatchFailed
! 
invokeClone: ppenum
		" Private - invoke the IEnum::Clone function. "

	" HRESULT Clone(
            /* [out] */ IEnum **ppenum); "

	<ole: 6 structOut hresult>
	^self vtableDispatchFailed!  
Clone: resultReference
		" Invoke the IEnum::Clone function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue result |
	resultValue := IEnumPointer forReturnValue: self iid.
	result := self invokeClone: resultValue asParameter.
	resultReference value: resultValue.
	^result! 
" OLE COM Support - library removal "

    OLESessionManager removeSessionEventHandlers.
    ExternalObjectTable removeComponent.

    " remove development environment support "
    OLESessionManager unbindDevelopmentLibrary: 'VOLDB31W.sll'.
!
removeInterfaceReferenceClassForIID: anIID
        " Private - unregister <aClass> as the interface reference class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	iidEntry := self iidMap at: anIID  " ptr, reference, impl "
		 ifAbsent: [ ^nil ].
	iidEntry at: 2 put: nil.
	iidEntry = #( nil nil nil )
		ifTrue: [ self iidMap removeKey: anIID ].!   
aboutToExitSession
		"Private - Exiting the session.  All owned memory addresses should have already been released
		at this point; cannot release now because memory allocators and OLEDLL are closed. "

	self isValid
		ifTrue: [ OLEDevelopmentWarning signal: 'Unreleased OLE address found at image exit: ', self printString ].!  
createItemMoniker: itemName
        " Create a new moniker for the item named <itemName> using the default delimiter.
        Answer a new instance of the receiver for the new item moniker. "

	^self createItemMoniker: itemName delimiterString: self defaultDelimiterString! 
DragOver: grfKeyState _: aPoint _: resultReference
		" Invoke the IDropTarget::DragOver function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchDragOver: grfKeyState _: aPoint _: resultReference )
!  
invokeOleSetClipboard: pDataObj
        "Private - WINOLEAPI  OleSetClipboard(LPDATAOBJECT pDataObj);"

    <api: OleSetClipboard handle hresult>
    ^self apiCallFailed!
Load: anIStream
		" Invoke the IPersistStreamInit::Load function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeLoad: anIStream asParameter!  
invokeSave: pStm _: fClearDirty
		" Private - invoke the IPersistStreamInit::Save function. "

	" HRESULT Save(
            /* [unique][in] */ IStream *pStm,
            /* [in] */ BOOL fClearDirty); "

	<ole: 6 handle boolean hresult>
	^self vtableDispatchFailed!  
Save: anIStream _: fClearDirty
		" Invoke the IPersistStreamInit::Save function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSave: anIStream asParameter 
		_: fClearDirty!
InitNew
		" Invoke the IPersistStreamInit::InitNew function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT InitNew( void);"

	<ole: 8 hresult>
	^self vtableDispatchFailed!  
invokeGetSizeMax: pcbSize
		" Private - invoke the IPersistStreamInit::GetSizeMax function. "

	" HRESULT GetSizeMax(
            /* [out] */ ULARGE_INTEGER *pcbSize); "

	<ole: 7 structOut hresult>
	^self vtableDispatchFailed!
IsDirty
		" Invoke the IPersistStreamInit::IsDirty function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT IsDirty( void);"

	<ole: 4 hresult>
	^self vtableDispatchFailed!  
invokeLoad: pStm
		" Private - invoke the IPersistStreamInit::Load function. "

	" HRESULT Load(
            /* [unique][in] */ IStream *pStm); "

	<ole: 5 handle hresult>
	^self vtableDispatchFailed!   
GetSizeMax: resultReference
		" Invoke the IPersistStreamInit::GetSizeMax function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := WinLargeInteger new.
	hresult := self invokeGetSizeMax: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult
	!   
classForIID: anIID ifNone: aBlock
		" Answer the interface pointer which represents the interface
		specified by the interface ID GUID <anIID>.
  		Answer the result of evaluating <aBlock> if no class is available. "

	| aClass |
	( anIID isNil or: [ anIID = IID_NULL ] )
		ifTrue: [ ^aBlock value ].
	aClass := OLEInterfacePointer interfacePointerClassForIID: anIID.
	aClass notNil
		ifTrue: [ ^aClass ].
	aClass := self subclassForIID: anIID.
	aClass notNil
		ifTrue: [  " self-registration backstop "
			self registerIID: anIID forClass: aClass.
			^aClass ].
	^aBlock value!
bytes
		" Private - answer the receiver's raw bytes. "

	^self!
RegisterDragDrop: aWindow _: anIDropTarget
		" Register the window <aWindow> as being able to accept dropped objects.
		Drag/drop interface with the window will be done by OLE using <anIDropTarget>.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeRegisterDragDrop: aWindow asParameter
        _: anIDropTarget asParameter! 
logReturnValue: returnValueDescription
        " Private - log function return to debug trace log. "

    self oleTRACE: '    ', ( returnValueDescription isString
        ifTrue: [ returnValueDescription ]
        ifFalse: [ returnValueDescription printString ] ).!
QueryInterface: iid _: resultReference
		" Invoke the IUnknown::QueryInterface function.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult |
	hresult := self dispatchQueryInterface:  iid _: resultReference.
	hresult = E_NOINTERFACE
		ifTrue: [ ^hresult ].
	^self checkHresult: hresult!   
logArguments: stack
        " Private - log the function invocation arguments to the OLE trace log. "

    | method frameIndex nArgs anArg |
    method := stack methodAt: 1.
    method selector = #ifOLETraceEnabled:
        ifTrue: [ method := stack methodAt: 2 ].
    nArgs := method selector occurrencesOf: $:.
    frameIndex := stack findFrameIndexOf: method.
    1 to: nArgs do: [ :i |
        anArg := stack argAt: frameIndex number: i.
        self oleTRACE: '    ', "'arg', i printString, ': '," anArg printString ].!   
invokeOleSetContainedObject: pUnknown _: fContained
        "Private - WINOLEAPI  OleSetContainedObject(
            LPUNKNOWN pUnknown, BOOL fContained);"

    <api: OleSetContainedObject handle boolean hresult>
    ^self apiCallFailed!
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^20!  
formatNamed: formatTypeString
        " Answer a default FORMATETC with the format described by <formatTypeString> "

    | cfFormat tymed |
    ( formatTypeString equalsIgnoreCase: 'String' ) ifTrue: [
        cfFormat := CfText.
        tymed := TYMED_HGLOBAL ].
    ( formatTypeString equalsIgnoreCase: 'Bitmap' ) ifTrue: [
        cfFormat := CfBitmap.
        tymed := TYMED_GDI ].
    ( formatTypeString equalsIgnoreCase: 'DIB' ) ifTrue: [
        cfFormat := CfDib.
        tymed := TYMED_HGLOBAL ].
    ( formatTypeString equalsIgnoreCase: 'Metafile' ) ifTrue: [
        cfFormat := CfMetafilepict.
        tymed := TYMED_MFPICT ].
    ( formatTypeString equalsIgnoreCase: 'Embed Source' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_ISTORAGE ].
    ( formatTypeString equalsIgnoreCase: 'Embedded Object' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_ISTORAGE ].
    ( formatTypeString equalsIgnoreCase: 'Link Source' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_ISTREAM ].
    ( formatTypeString equalsIgnoreCase: 'Custom Link Source' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_ISTREAM ].
    ( formatTypeString equalsIgnoreCase: 'Object Descriptor' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_HGLOBAL ].
    ( formatTypeString equalsIgnoreCase: 'Link Source Descriptor' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_HGLOBAL ].
    ( formatTypeString equalsIgnoreCase: 'FileName' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_HGLOBAL ].
	"Possibly add:
    ( formatTypeString equalsIgnoreCase: 'OwnerLink' ) ifTrue: [
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_HGLOBAL ].
	"

    cfFormat isNil ifTrue: [  "Smalltalk object format"
        cfFormat := Clipboard registerFormat: formatTypeString.
        tymed := TYMED_HGLOBAL ].
    ^self format: cfFormat medium: tymed
! 
format: cfFormat medium: tymed
        " Answer a default FORMATETC with the specified clipboard format and medium. "

    ^self new
        cfFormat: cfFormat;
        tymed: tymed;
        dwAspect: DVASPECT_CONTENT;
        lindex: -1;
        yourself!  
invokeRegisterDragDrop: hwnd _: pDropTarget
        "Private - WINOLEAPI  RegisterDragDrop(HWND hwnd, LPDROPTARGET pDropTarget);"

    <api: RegisterDragDrop handle handle hresult>
    ^self apiCallFailed! 
initializeIIDMap
		" Private - initialize the IID-to-class map. "

	self iidMap: Dictionary new.!  
isRegistered
		" Answer whether the receiver is registered with OLE. "

	^self registrationToken notNil!   
doDragDrop: anIDataObject sourceEffects: sourceEffects
		" Initiate a drag/drop operation on the data object <anIDataObject>.  
		The DROPEFFECT effects allowed by the source are specified in <sourceEffects>.  
		Answer the DROPEFFECT value indicating how the drag operation outcome 
		affects the source object. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current DoDragDrop: anIDataObject
            _: self
            _: sourceEffects
            _: resultReference.
	^resultReference value!
queryContinueDrag: escapePressed keyState: keyState
		" Answer whether the drag operation should continue.
		The <escapePressed> flag indicates whether the ESC key has
		been pressed since the previous call.  The present state
		of the keyboard modifier flags is given by the combination
		of MK flags in <keyState>. "

	^( interface
		QueryContinueDrag: escapePressed 
		_: keyState ) = S_OK!
giveFeedback: dropEffect
		" Give user feedback for a drag operation based on the DROPEFFECT value in <dropEffect>. 
		Raise an exception if an error occurs.  Answer the result code. "

	^interface GiveFeedback: dropEffect!   
fromTimeStamp: aTimeStamp
		" Answer a new instance of the receiver with <aTimeStamp> as its value. "

	aTimeStamp isNil
		ifTrue: [ ^nil ].
	^self fromBytes: 
		( WinFileTime fromDate: aTimeStamp date time: aTimeStamp time )
			contents! 
now
		" Answer a new instance of the receiver with the current time. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current CoFileTimeNow: resultReference.
	^resultReference value! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^8!   
fromDosDate: dosDate time: dosTime
		" Answer a new instance of the receiver corresponding to the given DOS date/time. "

	| resultReference |
	resultReference := nil asValueReference.
	( OLEDLL current CoDosDateTimeToFileTime: dosDate _: dosTime _: resultReference )
		ifFalse: [ ^nil ].
	^resultReference value!  
hasExternalResources
		"Answer whether the receiver has valid external memory associated with it."

	^self externalMemoryAddress ~~ nil and: [ self externalMemoryAddress isValid ]!   
CoLockObjectExternal: anIUnknown _: fLock _: fLastUnlockReleases
		"Lock or unlock the object <anIUnknown> in memory, 
		according to the <fLock> boolean.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeCoLockObjectExternal: anIUnknown asParameter
		_: fLock
		_: fLastUnlockReleases! 
StringFromIID: iid _: resultReference
		" Convert the IID specified by the GUID <iid> into a display string.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := self createStringResultValue.
	hresult := self invokeStringFromIID: iid
		_: resultValue.
	resultReference value: ( self stringFromResultValue: resultValue ).
	^hresult! 
renderObjectDescriptor: aStgMedium
        "Private - create an OBJECTDESCRIPTOR structure from the
         embedded object in object. Store the resulting handle in <aStgMedium>. "

    | objectDescriptor |
    objectDescriptor := ( OLEStructure classForStructureNamed: #OBJECTDESCRIPTOR )
        fromOleObject: object 
        srcOfCopy: 0
        drawAspect: formatEtc dwAspect
        pointl: 0 @ 0
        sizel: 0 @ 0.
    aStgMedium
        tymed: TYMED_HGLOBAL;
        hGlobal: ( ExternalGlobalAddress memoryHandleFrom: objectDescriptor contents ).
    ^aStgMedium
!   
renderOleObject: aStgMedium
        " Private - render the embedded object in object on aStgMedium. This is used
          by GetData: and GetDataHere: to copy an embedded object into aStgMedium.
          If aStgMedium->tymed field is nil, allocate a temporary storage and copy the
          embedded object to the allocated storage. If aStgMedium->tymed field is
         TYMED_ISTORAGE, then data is copied into the passed IStorage. The object
          in question has to be an instance of IOleObject that supports IPersisStorage."

    | iPersistStorage tempDocFile |
    aStgMedium tymed isNil
        ifTrue: [
            " alloc temp storage that will delete on last release "
            tempDocFile := OLECompoundFile createTemporaryFile.
            tempDocFile isNil ifTrue: [ ^self error: 'unable to allocate temp storage' ].
            tempDocFile doesNotNeedFinalization.
            tempDocFile interfaceBinding doesNotNeedFinalization.
            aStgMedium
                tymed: TYMED_ISTORAGE;
                pstg: tempDocFile;
                pUnkForRelease: nil ].

    iPersistStorage := object queryInterface: IID_IPersistStorage.
    iPersistStorage isNil ifTrue: [ ^self error: 'object must support IPersistStorage' ].
    iPersistStorage saveTo: aStgMedium pstg sameAsLoad: false.
    iPersistStorage release
!
object: anObject
        "Set the rendering object to <anObject>."

    object := anObject
!  
release
		"Release any resources associated with the receiver."

	object isOLEInterface ifTrue: [ object release ]!
object
        "Answer the rendering object."

    ^object
!  
formatEtc: anOLEFormatEtc
		" Set the format of the rendering. "

    formatEtc := anOLEFormatEtc! 
formatEtc
		" Answer the format of the rendering. "

    ^formatEtc!   
sameFormatEtc: aFormatEtc
        "Answer true if the receiver's FormatEtc has the same cfFormat,
         tymed, and dwAspect as aFormatEtc."

    ^( formatEtc cfFormat = aFormatEtc cfFormat and: [
        formatEtc tymed = aFormatEtc tymed and: [
            formatEtc dwAspect = aFormatEtc dwAspect ] ] )!
renderObject: aStgMedium
        " Render the object onto <aStgMedium>. This is used by GetData:
          and GetDataHere: to render data in object onto the specified 
		 storage medium. "

    | cfFormat address stream size objectFiler hGlobal |
    cfFormat := formatEtc cfFormat.
    ( ( cfFormat = ( Clipboard formatNamed: 'Embedded Object' ) ) or: [
        formatEtc cfFormat = ( Clipboard formatNamed: 'Embed Source' ) ] )
            ifTrue: [ ^self renderOleObject: aStgMedium ].
     ( cfFormat = (Clipboard formatNamed: 'Object Descriptor' ) )
        ifTrue: [ ^self renderObjectDescriptor: aStgMedium ].

    aStgMedium tymed: formatEtc tymed.

    ( cfFormat = CfText or: [ cfFormat = ( Clipboard formatNamed: 'FileName' ) ] )
        ifTrue: [
                object class isBytes ifFalse: [ ^self error: 'object must be variable bytes' ].
                aStgMedium hGlobal: ( ExternalAddress memoryHandleFrom: object ).
                ^aStgMedium ].

    ( ( ( cfFormat = CfBitmap ) or: [ cfFormat = CfMetafilepict ] ) or: [
        cfFormat = CfEnhmetafile ] ) ifTrue: [    "anObject must be a Bitmap or StoredPicture"
            aStgMedium dwHandleType: object handle.
            ^aStgMedium ].

    "Smalltalk object format"
    objectFiler := ServiceRegistry globalRegistry serviceNamed: #ObjectFiler
        ifNone: [ self error: 'ObjectFiler not installed' ].
    address := ExternalGlobalAddress allocateMemory: 1024.
    address doesNotNeedFinalization.
    hGlobal := address memoryHandle.
    stream := MemoryReadWriteStream characterStreamOn: address.
    stream nextULongPut: 0.    " size place holder "
    objectFiler dump: object on: stream.
    size := stream position.
    stream reset; nextULongPut: ( size - 4 ).
    KernelLibrary globalUnlock: hGlobal.
    aStgMedium hGlobal: hGlobal.
    ^aStgMedium
!  
elementsReversed
		" Answer the elements of a composite moniker in reverse order. "

	| anEnumerator contents |
	anEnumerator := self elementsReversedEnumerator.
	anEnumerator isNil
		ifTrue: [ ^ #() ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!
getArrayOfStrings: count fromUnicodeArray: strArray
		" Private - answer an Array of size <count> filled with Strings 
		extracted from the Unicode string array <strArray>. "

	| strSize nameList strPointer |
	strSize := ExternalAddress sizeInBytes.
	nameList := Array new: count.
	1 to: count do:
		[:index |
		strPointer := (ExternalAddress fromInteger: (strArray uLongAtOffset: index - 1 * strSize)).
		nameList at: index put: (self stringAtAddress: strPointer)].
	^nameList

"----------  the following code will work for non-unicode strings
		length := 0.
		[(strPointer byteAtOffset: length) = 0]
			whileFalse: [length := length + 1].
		length := length - 1.
		nameList at: index put:
			((String new: length)
				replaceFrom: 1
				to: length
				with: strPointer
				startingAt: 1)].
	^nameList
----------"!  
externalMemoryAddress
		" Private - answer the address in external memory
		of the receiver's interface data structures (ptr-ptr-VTable). "

	^externalMemoryAddress! 
supportsIID: aGUID
		" Answer whether the receiver represents the interface identified
		by the IID <aGUID>. "

	^self iid = aGUID!   
logIID: anIID
        " Private - log an IID value to the OLE trace log. "

    | interfaceClass |
    interfaceClass := OLEInterface classForIID: anIID
        ifNone: [ nil ].
    self oleTRACE: '    IID: ',
        ( interfaceClass isNil
            ifTrue: [ '' ]
            ifFalse: [ 'IID_', interfaceClass name, ' ' ] ),
        anIID printString.!
sessionCommandArgumentsInclude: aString
        " Answer whether the current session was started with
		<aString> specified as an argument on the command line. "

	| commandLineArguments |
	commandLineArguments := self sessionCommandLineArguments.
    ^( commandLineArguments
        detect: [ :anArgument | anArgument equalsIgnoreCase: aString ]
        ifNone: [ nil ] )
            notNil! 
oleAddressAtOffset: anInteger
        " Answer the bytes starting at anInteger (0 based offset)
        as an OLEMemoryAddress.  No assumption of memory
        ownershiop is mad here (i.e., the address does not have finalization).
        Answer nil if there is no address. "

    | anAddress |
	anAddress := OLEMemoryAddress usingBytes:
		( self bytesAtOffset: anInteger count: ExternalAddress sizeInBytes ).
	^anAddress isValid
		ifTrue: [ anAddress ]
		ifFalse: [ nil ]! 
WriteClassStg: anIStorage _: clsid
		" Write the CLSID specified by the GUID <clsid> to the storage <anIStorage>.
		Raise an exception if an error occurs.  Answer the result code. "

	" Containers typically call WriteClassStg before calling IPersistStorage::Save. "

	^self invokeWriteClassStg: anIStorage asParameter 
		_: clsid
!   
isOLEInterface
		" Answer whether the receiver is an OLE interface. "

	^false!
logIndent
		" Private - answer the standard indent for log subitems. "

	^'    '!  
isPointerMoniker
		" Answer whether the receiver is a pointer moniker "

	^self systemMonikerType = MKSYS_POINTERMONIKER!  
asGUID
		"Answer the GUID specified by the bytes of the receiver."

    ^GUID fromBytes: self copy!
invokeBindMoniker: pmk _: grfOpt _:iidResult _: ppvResult
        "Private - WINOLEAPI  BindMoniker(
			LPMONIKER pmk, DWORD grfOpt, REFIID iidResult, LPVOID FAR* ppvResult);"

    <api: BindMoniker handle ulong structIn structOut hresult>
    ^self apiCallFailed! 
hexByteString
		" Answer a string describing the bytes of the receiver in hexadecimal notation. "

	| aStream |
	aStream := ReadWriteStream on: String new.
	self hexByteStringOn: aStream.
	^aStream contents! 
needsFinalization
    "The receiver needs to be sent the message #finalize when it is no longer referenced."

	OLESessionManager trackResources
		ifTrue: [ super needsFinalization ].!   
OleDoAutoConvert: anIStorage _: resultReference
        " Automatically convert an object in storage <anIStorage> and
        store the CLSID to which the object was converted in <resultReference> .
        The object must have been previously tagged for automatic conversion,
        typically at setup time for the object application.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := GUID forReturnValue.
    hresult := self invokeOleDoAutoConvert: anIStorage asParameter
         _: resultValue.
    ( HRESULT succeeded: hresult )
        ifTrue: [ resultReference value: resultValue ].
    ^hresult! 
traceManager
		" Answer the OLE trace manager. "

	^traceManager!  
oleAddressAtOffset: anInteger put: anExternalAddress
        "Set the bytes starting at anInteger (0 based offset)
        from the contents of anExternalAddress."

	super addressAtOffset: anInteger 
		put: ( anExternalAddress isNil
			ifTrue: [ OLEMemoryAddress nullValue ]
			ifFalse: [ anExternalAddress ] )!
reduce: aBindContext howFar: dwReduceHowFar monikerToLeft: monikerToLeft
		" Reduce this moniker to a more or equally efficient moniker
		referring to the same object, according the the MKREDUCE flags.
		Answer the resulting reduced moniker. "

	| resultReference hresult |
	resultReference := self class new asValueReference.
	hresult := interface Reduce: aBindContext 
		_: dwReduceHowFar 
		_: monikerToLeft 
		_: resultReference.
	hresult = S_OK   " MK_S_REDUCED_TO_SELF "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value! 
relativePathTo: aMoniker
		" Answer the relative path which when composed to the end of the receiver 
		will yield <aMoniker>. "

	| resultReference hresult |
	resultReference := nil asValueReference.
	hresult := interface RelativePathTo: aMoniker _: resultReference.
	hresult = S_OK   " MK_S_HIM "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value!   
containerWindows
		" Private - answer all the open container windows in the image. "

	^Notifier windows select: [ :w |
		w isTopPane and: [ w container notNil ] ]!  
GetClassFile: aFileName _: resultReference
		" Get the CLSID associated with the storage named <aFileName>
		and store it into the <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeGetClassFile: ( self asUnicodeParameter: aFileName )
		_: resultValue.
	resultReference value: resultValue.
	^hresult!  
activeObjectsRegistry: aRegistry
		" Private - set the registry of objects which have been created
		during the current session. "

	ActiveObjectsRegistry := aRegistry.! 
registerSessionEventHandlers
	" Private - register the image startup and shutdown event handlers.
		OLESessionManager registerSessionEventHandlers "

	ExternalObjectTable removeSessionEventHandlers.
		" Override the standalone handlers to ensure timing control "

	SessionModel current
		when: #startup send: #startUp to: self;
		when: #aboutToSaveImage send: #aboutToSaveImage to: self;
		when: #shutdown send: #exit to: self.!
logHeader: stack
        " Private - log callback invocation header information to the OLE trace log. "

    | method receiver methodDescription |
    method := stack methodAt: 1.
    receiver := stack receiverAt: 1.
    methodDescription := receiver class name.
    receiver class ~~ method classField
        ifTrue: [ methodDescription := methodDescription, '(', method classField name, ')' ].
    methodDescription := methodDescription, '>>', method selector printString.
    self
        oleTRACE: methodDescription;
        oleTRACE: '    Receiver: ', receiver printString;
        oleTRACE: '       On object: ', self implementor printString!
CoIsHandlerConnected: anIUnknown
		"Answer whether the in-process server or handler 
		is connected for the object <anIUnknown>. "

	^self invokeCoIsHandlerConnected: anIUnknown asParameter
!  
OleCreateLink: aMoniker _: iid _: renderopt _: aFormatEtc _: aClientSite _: aStorage _: resultReference
        " Create a linked object from the specified moniker <aMoniker>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreateLink: aMoniker asParameter
        _: iid
        _: renderopt
        _: aFormatEtc
        _: aClientSite asParameter
        _: aStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!   
registerEnumeratorIID: anIID for: aClass
		" Register the GUID <anIID> as the IID of the enumerator interface
		which operates on elements of type <aClass>. "

    ( anIID isNil or: [ anIID = IID_NULL ] )
        ifTrue: [ ^nil ].  " ignore null IID's of abstract interface classes "
	self elementTypeMap isNil
		ifTrue: [ self initializeElementTypeMap ].
	self elementTypeMap at: anIID put: aClass.
	self registerIID: anIID forClass: self
!   
invokeStringFromIID: riid _: lplpsz
        "Private - WINOLEAPI StringFromIID(REFIID rclsid, LPOLESTR FAR* lplpsz);"

	<api: StringFromIID structIn structOut hresult>
	^self apiCallFailed

! 
invokeOleSave: pPS _: pStg _: fSameAsLoad
        "Private - WWINOLEAPI  OleSave(
			LPPERSISTSTORAGE pPS, LPSTORAGE pStg, BOOL fSameAsLoad);"

    <api: OleSave handle handle boolean hresult>
    ^self apiCallFailed!
invokeCreateILockBytesOnHGlobal: hGlobal _: fDeleteOnRelease _: pplkbyt
		"Private - WINOLEAPI CreateILockBytesOnHGlobal (
					HGLOBAL hGlobal, BOOL fDeleteOnRelease,
					LPLOCKBYTES FAR* pplkbyt);"

    <api: CreateILockBytesOnHGlobal handle boolean structOut hresult>
    ^self apiCallFailed!
invokeWriteFmtUserTypeStg: pStg _: cf _: lpszUserType
		"Private - WINOLEAPI WriteFmtUserTypeStg (
                  LPSTORAGE pstg, CLIPFORMAT cf, LPOLESTR lpszUserType); "

    <api: WriteFmtUserTypeStg handle ushort structIn hresult>
    ^self apiCallFailed!
saveCopyAs: aPathName
		" Save a copy of the object to the file specified by the absolute
		pathname <aPathName>.  Do not change the current working file. "

	interface Save: aPathName _: false.!   
load: aPathName
		" Load the document object contained in the file specified
		by the absolute pathname <aPathName> with read/write access. "

	interface Load: aPathName _: STGM_READWRITE.! 
loadReadOnly: aPathName
		" Load the document object contained in the file specified
		by the absolute pathname <aPathName> with readOnly access. "

	interface Load: aPathName _: STGM_READ.!
load: aPathName storageMode: storageModeFlags
		" Load the document object contained in the file specified
		by the absolute pathname <aPathName> with the access
		modes specified by <storageModeFlags>. "

	interface Load: aPathName _: storageModeFlags.!   
save
		" Save a copy of the object to the current working file. "

	interface Save: nil _: true.!  
isDirty
		" Answer whether the object has been changed since it was last saved. "

	^( interface IsDirty ) = S_OK! 
saveCompleted: aPathName
		" The object has been saved to the file specified
		by the absolute pathname <aPathName> 
		and the caller is finished working with it. 
		Answer the result code, which is always S_OK. "

	^interface SaveCompleted: aPathName!
saveCompleted
		" The object has been saved to its backing storage 
		and the caller is finished working with it. "

	^interface SaveCompleted: nil!  
saveAs: aPathName
		" Save a copy of the object to the file specified by the absolute
		pathname <aPathName> and make it the current working file. "

	interface Save: aPathName _: true.!
getCurrentFile
		" Answer the absolute path name of the document's currently associated file.
		Answer the default filename prompt if there is no currently associated file. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetCurFile: resultReference.
	^resultReference value!
currentPathName
		" Answer the absolute path name of the document's file.
		Answer nil if there is no file currently associated with the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	^( interface GetCurFile: resultReference ) = S_OK
		ifTrue: [ resultReference value ]
		ifFalse: [ nil ]!   
save: aPathName makeFileCurrent: fRemember
		" Save a copy of the object to the file specified
		by the absolute pathname <aPathName>.
		Make the specified file the current working copy of the
		document if <fRemember> is true.
		Save the object to the current file if the path name is null.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Save: aPathName _: fRemember!
type
		" Answer the type of the receiver if it is a type of moniker whose
		implementation semantics are conceptually important to the binding process. "

	^self class typeNameOf: self systemMonikerType
! 
invokeCreatePointerMoniker: punk _: ppmk
        "Private - WINOLEAPI  CreatePointerMoniker(
                LPUNKNOWN punk, LPMONIKER FAR* ppmk); "

    <api: CreatePointerMoniker handle structOut hresult>
    ^self apiCallFailed!  
ptd
		" Private - answer the address of the DVTARGETDEVICE. "

	^self addressAtOffset: 4!  
dwAspect: dvAspectFlags
		" Specify the data aspect "

	self uLongAtOffset: 8 put: dvAspectFlags!  
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream. "

    super printOn: aStream.
	aStream 
		nextPutAll: ' ('; 
		nextPutAll: self formatDescription;
		nextPutAll: ', medium: ';
		nextPutAll: self mediumDescription;
		nextPutAll: ') '.!   
cfFormat: cfFormat
		" Specify the clipboard format. "

	self uShortAtOffset: 0 put: cfFormat! 
formatDescription
        " Answer a string description of the transfer format. "

    | descriptions format |
    descriptions := Dictionary new
        at: CfBitmap put: 'bitmap';
        at: CfDib put: 'DIB';
    "Maybe add additional descriptions someday:
        at: CfDif put: 'XXX';
        at: CfDspbitmap put: 'XXX';
        at: CfDspmetafilepict put: 'XXX';
        at: CfDsptext put: 'XXX';
        at: CfGdiobjfirst put: 'XXX';
        at: CfGdiobjlast put: 'XXX';
    "
        at: CfMetafilepict put: 'metafile';
        at: CfOemtext put: 'OEM text';
        at: CfOwnerdisplay put: 'ownerDisplay';
    "Maybe add additional descriptions someday:
        at: CfPalette put: 'XXX';
        at: CfSylk put: 'XXX';
    "
        at: CfText put: 'string';
        at: CfTiff put: 'TIFF';
        yourself.
    format := self cfFormat.
    ^descriptions at: format 
        ifAbsent: [ Clipboard getFormatName: format ]! 
mediumDescription
        " Answer a string description of the transfer medium. "

    | descriptions |
    descriptions := Dictionary new
        at: TYMED_GDI put: 'bitmap';
        at: TYMED_ISTORAGE put: 'IStorage';
        at: TYMED_HGLOBAL put: 'global memory';
        at: TYMED_FILE put: 'file';
        at: TYMED_ISTREAM put: 'IStream';
        at: TYMED_ENHMF put: 'enhanced metafile';
        at: TYMED_MFPICT put: 'metafile';
        at: TYMED_NULL put: '(no data)';
        yourself.
    ^descriptions at: self tymed ifAbsent: [ '(unknown medium)' ]! 
lindex: dvAspectFlags
		" Specify the part of the data aspect which is of interest. "

	self longAtOffset: 12 put: dvAspectFlags!  
dwAspect
		" Answer the data aspect "

	^self uLongAtOffset: 8!
tymed: aMediumType
		" Specify the type of the medium on which the data is transfered. "

	self uLongAtOffset: 16 put: aMediumType!
dvTargetDevice
		" Answer the DVTARGETDEVICE. "

	| anAddress |
	anAddress := self ptd.
	anAddress isNil
		ifTrue: [ ^nil ].
	^OLEStructure createStructureNamed: #DVTARGETDEVICE
		fromAddress: anAddress!   
tymed
		" Answer the type of the medium on which the data is transfered. "

	^self uLongAtOffset: 16!  
cfFormat
		" Answer the clipboard format. "

	^self uShortAtOffset: 0! 
lindex
		" Answer the part of the data aspect which is of interest. "

	^self longAtOffset: 12!
StgCreateDocfileOnILockBytes: anILockBytes _: grfMode _: reserved _: resultReference
		" Create and open a new compound file on the storage provided by <anILockBytes>
		and open in with the access mode specified by the STGM flags <grfMode>.
		Obtain an IStorage interface on the new storage and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := IStoragePointer forReturnValue.
    hresult := self invokeStgCreateDocfileOnILockBytes: anILockBytes asParameter
        _: grfMode
        _: reserved
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!
switchToFile: aPathName
		" Make a copy of the file underlying the IStorage in the file named <aPathName>.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface SwitchToFile: aPathName!  
logCallbackExit: hresult
        " Private - log callback exit to debug trace log. "

    self oleTRACE: '    hresult: ', ( HRESULT nameOrHexString: hresult ).
! 
current
		" Answer the running object table for the caller's context. "

	current isNil
		ifTrue: [ self current: self getCurrent ].
	^current!  
current: anIRunningObjectTable
		" Private - set the running object table for the caller's context. "

	current := anIRunningObjectTable.! 
getCurrent
		" Private - answer a new instance of the receiver for the running object table
		for the caller's context. "

	| resultReference anIRunningObjectTable |
	resultReference := self new asValueReference.
	OLEDLL current GetRunningObjectTable: 0 
		_: resultReference.
	anIRunningObjectTable := resultReference value.
	anIRunningObjectTable notNil
		ifTrue: [ 
			OLESessionManager registerSpecialSessionResource: anIRunningObjectTable 
				description: 'OLE running object table'.
			].
	^anIRunningObjectTable!
releaseCurrent
		" Release the remembered reference to the current running object table."

	current notNil
		ifTrue: [
			OLESessionManager removeSpecialSessionResource: current.
			current release.
			self current: nil ].!
resetCurrent
		" Private - reset the remembered reference to the current running object table."

	current notNil
		ifTrue: [
			current invalidate.  " don't want to release/finalize any more "
			self current: nil ].!   
forTemporaryInterfacePointerAtAddress: anExternalAddress
		"Answer a new instance of the receiver for an external interface pointer
		whose pointer is stored in <anExternalAddress>. 
		This creation service is used to instantiate interfaces which
		are temporarily owned; the interface instance is not separately
		reference counted and should not be released by the caller.
		E.g., this is always used by the callee during interface function invocation 
		to access an interface argument provided by an external caller.
		The caller must explicitly make a copy of the interface and
		increment its reference count if it holds on to this interface reference. "

	^self forBinding: 
		( self interfacePointerClass newTemporaryInterfacePointerAtAddress: anExternalAddress )!  
invokeCreateFileMoniker: aPathName _: ppmk
        "Private - WINOLEAPI  CreateFileMoniker(
			LPCOLESTR lpszPathName, LPMONIKER FAR* ppmk);"

    <api: CreateFileMoniker structIn structOut hresult>
    ^self apiCallFailed!  
OleGetAutoConvert: clsidOld _: resultReference
        " Retrieve the existing auto-convert class for object of class <clsidOld> and
        store it into <resultReference>. If there is no such class, CLSID_NULL is returned.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := GUID forReturnValue.
    hresult := self invokeOleGetAutoConvert: clsidOld
         _: resultValue.
	resultReference value: resultValue.
    ^hresult!   
for: anOLEObject selectors: selectors
		"Answer an initialized instance of the receiver that is an interface for <anOLEObject>
		using <selectors> as the interface function handlers to delegate processing
		responsibility to the implementing object.  The <selectors> list must be exact match
		in size, order, and argument count to the interface VTable function layout. "

	| handlers |
	selectors size ~= self vtableSize
		ifTrue: [ self error: 'incorrect number of selectors' ].
	handlers := selectors
		collect: [ :aSelector | Message receiver: anOLEObject selector: aSelector ].
	self validateDispatchHandlers: handlers.
	^self new
		implementor: anOLEObject;
		functionHandlers: handlers
! 
aboutToExitSession
		"Private - Exiting the session.  All owned interfaces should have already been released
		at this point; cannot release now because memory allocators and OLEDLL are closed. "

	self isValid
		ifTrue: [ OLEDevelopmentWarning signal: 'Unreleased OLE interface found at image exit: ', self printString ].!  
OleCreateLinkToFile: aFileName _: iid _: renderopt _: aFormatEtc _: aClientSite _: aStorage _: resultReference
        " Create a linked object to the specified file <fileName>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreateLinkToFile: ( self asUnicodeParameter: aFileName )
        _: iid
        _: renderopt
        _: aFormatEtc
        _: aClientSite asParameter
        _: aStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult! 
CLSIDFromString: aString _: resultReference
		" Obtain the CLSID associated whose display name is <aString>
		and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeCLSIDFromString: ( self asUnicodeParameter: aString )
		_: resultValue.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!  
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."

    ^self asInterfacePointer! 
registerIID
        " Private - register the receiver as the interface class for its IID.
		IEnum actually registers a family of interface ID's.  The IEnum
		class doesn't have an IID of its own, since it represents a
		family of enumerator interfaces, each with its own IID,
		differentiated only by the type of element being enumerated. "

	super registerIID.
	self elementTypeMap keysDo: [ :anIID |
		self registerIID: anIID forClass: self ].
! 
interfaceBinding
		" Answer the interface binding which provides function invocation services 
		for the receiver. "

	^self! 
elementTypeMap: aDictionary
		" Private - set the dictionary which maps element types to
		the IID of the interface which enumerates elements of that type. "

	ElementTypeMap := aDictionary.!   
composeGenericCompositeWith: monikerToRight
		" Answer a new composite moniker formed from the receiver and <monikerToRight>. 
		The receiver must be a generic composite moniker. "

	| resultReference |
	resultReference := self class new asValueReference.
	interface ComposeWith: monikerToRight _: true _: resultReference.
	^resultReference value!
objectReleased: anOleObject
		" The OLE object <anOleObject> has been released
		by all its clients and is being terminated.   Remove it
		from the active objects registry if it was created by 
		a class factory object. "

	| aClassFactory |
	ActiveObjectsRegistry isNil
		ifTrue: [ ^self ].
	aClassFactory := self activeObjectsRegistry at: anOleObject
		ifAbsent: [ ^nil ].   " wasn't created by a class factory "
	self activeObjectsRegistry removeKey: anOleObject ifAbsent: [].
	self compressActiveObjectsRegistry.
	self checkInUse: aClassFactory.
	!
CoFreeLibrary: hInst
		" Free the DLL <hInst> which was previously loaded by CoLoadLibrary. "
 
	" WINOLEAPI_(void) CoFreeLibrary(HINSTANCE hInst); "

    <api: CoFreeLibrary handle none >
    ^self apiCallFailed!   
moveElement: elementName to: destStorage
		" Move the element named <elementName> in the the storage object
		to the destination storage <destStorage>. "

	interface MoveElementTo: elementName 
		_: destStorage 
		_: elementName
		 _: STGMOVE_MOVE.!  
openStorage: storageName accessMode: accessModeFlags emptyElements: emptyElementList
		" Open an existing storage object named <storageName> in this storage.
		with STGM access mode flags <accessModeFlags>.  
		The elements whose names are in the <emptyElementList> are
		emptied when the storage is opened (streams are set to 0 length, storages
		have their elements removed).
		Answer the storage. "

	^self openStorage: storageName 
		accessMode: accessModeFlags 
		storagePriority: nil
		emptyElements: emptyElementList!   
openStreamReadOnly: streamName
		" Open an existing stream object named <streamName> in this storage
        in readOnly mode.  Answer the stream. "

    ^self openStream: streamName 
		accessMode: self class accessModeReadOnly! 
setClass: clsid
		" Set the CLSID of the storage to the GUID <clsid>. 
		Raise an exception if an error occurs.  Answer the result code. "

	^interface SetClass: clsid!  
newStorage: storageName
		" Create and open a new storage object named <storageName> in this storage
		in read/write mode.  Remove the existing storage object of that name, if any.
		Answer the new storage. "

	^self createStorage: storageName 
		accessMode: STGM_CREATE | self class accessModeReadWrite!
clearConvertStg
		" Clear the conversion bit on the receiver object storage 
		which tags the object it contains for conversion to another class. "

    ^OLEDLL current SetConvertStg: self _: false!
hasStreamNamed: elementName
		"Answer whether the receiver contains a stream named <elementName>. "

	| hasElement |
	hasElement := false.
	self elements do: [ :aStatStg |
		( aStatStg isStream
		and: [ aStatStg name = elementName ] )
			ifTrue: [ hasElement := true ].
		aStatStg release ].
	^hasElement!   
newStream: streamName
        " Create and open a new stream object named <streamName> in this storage.
		Remove the existing stream object with that name, if any.
		Answer the new stream. "

    ^self createStream: streamName 
		accessMode: STGM_CREATE | self class accessModeReadWrite! 
openStorage: storageName
        " Open an existing storage object named <storageName> in this storage
        in read/write mode.  Answer the storage. "

    ^self openStorage: storageName 
		accessMode: self class accessModeReadWrite
		storagePriority: nil
		emptyElements: nil!   
copyTo: destStorage excludeIIDs: iidExclusionList excludeElements: elementExclusionList
		" Copy the contents of the storage object to <destStorage>.
		Any interface identifiers in the list <iidExclusionList> are left to the
		responsibility of the caller to copy.  Storage elements whose names
		are in <elementExclusionList> are not copied to the destination.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface CopyTo: iidExclusionList size 
		_: iidExclusionList 
		_: elementExclusionList 
		_: destStorage!   
createStream: streamName
		" Create and open a new stream object named <streamName> in this storage.
		Answer the new stream. "

    ^self createStream: streamName 
		accessMode: self class accessModeReadWrite!   
setElementTimes: elementName 
	createdTime: cTime 
	accessedTime: aTime 
	modifiedTime: mTime
		" Set the modification, access, and create times of the element
		named <elementName> in the storage object.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface SetElementTimes: elementName _: cTime _: aTime _: mTime!
streamNames
		"Answer a collection of the names of the streams 
		directly contained within the receiver."

    | names |
    names := OrderedCollection new.
    self elements do: [ :aStatStg |
		aStatStg isStream
			ifTrue: [ names add: aStatStg name ].
		aStatStg release ].
    ^names!
elements
		" Answer the storage elements which are directly contained in the receiver. "

	| anEnumerator contents |
	anEnumerator := self elementsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!  
openStorage: storageName 
	accessMode: accessModeFlags 
	storagePriority: storagePriority
	emptyElements: emptyElementList
		" Open an existing storage object named <storageName> in this storage.
		with STGM access mode flags <accessModeFlags>.  
		The <storagePriority> is a previously opened root IStorage.
		The elements whose names are in the <emptyElementList> are
		emptied when the storage is opened (streams are set to 0 length, storages
		have their elements removed).
		Answer the storage. "

	| resultReference anIStorage |
	resultReference := IStorage new asValueReference.
	interface OpenStorage: storageName 
		_: storagePriority 
		_: accessModeFlags 
		_: emptyElementList 
		_: 0 
		_: resultReference.
	anIStorage := resultReference value.
	^anIStorage
		container: self;
		yourself!  
openStorageReadOnly: storageName
        " Open an existing storage object named <storageName> in this storage.
        in readOnly mode.  Answer the storage. "

    ^self openStorage: storageName 
		accessMode: self class accessModeReadOnly
		storagePriority: nil
		emptyElements: nil! 
createStorage: storageName accessMode: accessModeFlags
        " Create and open a new storage object named <storageName> in this storage.
        with STGM access mode flags <accessModeFlags>.  Answer the new storage. "

	| resultReference hresult anIStorage |
	resultReference := IStorage new asValueReference.
	hresult := interface CreateStorage: storageName 
		_: accessModeFlags 
		_: 0 
		_: 0 
		_: resultReference.
    hresult = S_OK   " STG_S_CONVERTED "
        ifFalse: [ OLEResultNotification hresult: hresult ].
	anIStorage := resultReference value.
	^anIStorage
		container: self;
		yourself!
destroyElement: elementName
		" Destroy the element named <elementName> in the storage object. "

	interface DestroyElement: elementName.! 
copyTo: destStorage excludeElements: elementExclusionList
		" Copy the contents of the storage object to <destStorage>.
		Storage elements whose names are in <elementExclusionList> 
		are not copied to the destination.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface CopyTo: 0 
		_: nil
		_: elementExclusionList 
		_: destStorage! 
storageNames
		"Answer a collection of the names of the storages 
		directly contained within the receiver."

    | names |
    names := OrderedCollection new.
    self elements do: [ :aStatStg |
		aStatStg isStorage
			ifTrue: [ names add: aStatStg name ].
		aStatStg release ].
    ^names! 
writeClipboardFormat: aClipboardFormat userType: userTypeString
		" Set the clipboard format and current user type of the receiver. "

	^OLEDLL current WriteFmtUserTypeStg: self 
		_: aClipboardFormat 
		_: userTypeString!   
openStream: streamName
		" Open an existing stream object named <streamName> in this storage
        in read/write mode.  Answer the stream. "

    ^self openStream: streamName 
		accessMode: self class accessModeReadWrite!  
writeCLSID: clsid
		" Set the CLSID associated with the receiver to the GUID <clsid>. "

	^OLEDLL current WriteClassStg: self _: clsid!
renameElement: elementName to: newElementName
		" Rename the element named <elementName> in the storage
		to have <newElementName>. "

	interface RenameElement: elementName _:  newElementName!  
createStream: streamName accessMode: accessModeFlags
		" Create and open a new stream object named <streamName> in this storage
		with STGM access mode flags <accessModeFlags>.  Answer the new stream. "

	| resultReference anIStream |
	resultReference := IStream new asValueReference.
	interface CreateStream: streamName 
		_: accessModeFlags 
		_: 0 
		_: 0 
		_: resultReference.
	anIStream := resultReference value.
	^anIStream
		container: self;
		yourself
! 
openStream: streamName accessMode: accessModeFlags
		" Open an existing stream object named <streamName> in this storage
		with STGM access mode flags <accessModeFlags>.  Answer the stream. "

	| resultReference anIStream |
	resultReference := IStream new asValueReference.
	interface OpenStream: streamName 
		_: nil 
		_: accessModeFlags 
		_: 0 
		_: resultReference.
	anIStream := resultReference value.
	^anIStream
		container: self;
		yourself!  
elementsEnumerator
		" Answer an enumerator that can be used to enumerate the
		storage elements which are directly contained in the receiver. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumSTATSTG ) asValueReference.
	interface EnumElements: 0 _: nil _: 0 _: resultReference.
	^resultReference value!
copyTo: destStorage
		" Copy the contents of the storage to <destStorage>. "

	interface CopyTo: 0 _: nil _: nil _: destStorage.!  
setStateBits: stateBits mask: mask
		" Set the state bits of the storage object from the 32-bit value <stateBits>.
		The binary <mask> indicates which state bits are significant in this call.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface SetStateBits: stateBits _: mask!
hasStorageNamed: elementName
		"Answer whether the receiver contains a storage named <elementName>. "

	| hasElement |
	hasElement := false.
	self elements do: [ :aStatStg |
		( aStatStg isStorage
		and: [ aStatStg name = elementName ] )
			ifTrue: [ hasElement := true ].
		aStatStg release ].
	^hasElement!
readClipboardFormatAndUserType
        " Answer an Array containing the clipboard format and current user type of the receiver.
        Either may be nil, indicating that the value is no longer of interest to the caller. "

    | resultReferenceClipboardFormat resultReferenceUserType |
    resultReferenceClipboardFormat := nil asValueReference.
    resultReferenceUserType := nil asValueReference.
    OLEDLL current ReadFmtUserTypeStg: self
        _: resultReferenceClipboardFormat
        _: resultReferenceUserType.
    ^Array
        with: resultReferenceClipboardFormat value
        with: resultReferenceUserType value!  
getConvertStg
        " Answer whether the conversion bit is set on the receiver object storage. "

    ^( OLEDLL current GetConvertStg: self ) = S_OK!
doAutoConvert
        " Automatically convert an object in the receiver storage and
        answer the CLSID to which the object was converted. "

    | resultReference |
    resultReference := nil asValueReference.
    OLEDLL current OleDoAutoConvert: self _: resultReference.
    ^resultReference value!  
moveElement: elementName to: destStorage newName: newElementName
		" Move the element named <elementName> in the the storage object
		to the destination storage <destStorage> as <newElementName>. "

	interface MoveElementTo: elementName 
		_: destStorage 
		_: newElementName
		 _: STGMOVE_MOVE.!   
isStorage
		" Answer whether the receiver is an IStorage. "

	^true!   
openStorage: storageName accessMode: accessModeFlags
		" Open an existing storage object named <storageName> in this storage.
        with STGM access mode flags <accessModeFlags>.  Answer the storage. "

	^self openStorage: storageName 
		accessMode: accessModeFlags 
		storagePriority: nil
		emptyElements: nil!  
setConvertStg: convertFlag
        " Set the conversion bit as specified by <convertFlag> in the receiver object storage.
        The boolean <convertFlag> if TRUE tags the object for conversion to another class
        of object; FALSE clears the conversion bit.  "

    ^OLEDLL current SetConvertStg: self _: convertFlag!  
hasElementNamed: elementName
		"Answer whether the receiver contains a storage element named <elementName>. "

	| hasElement |
	hasElement := false.
	self elements do: [ :aStatStg |
		aStatStg name = elementName
			ifTrue: [ hasElement := true ].
		aStatStg release ].
	^hasElement!   
setConvertStg
		" Set the conversion bit on the receiver object storage 
		to tag the object it contains for conversion to another class. "

    ^OLEDLL current SetConvertStg: self _: true! 
readCLSID
        " Answer the CLSID associated with the receiver. "

    | resultReference |
    resultReference := nil asValueReference.
    OLEDLL current ReadClassStg: self
        _: resultReference.
    ^resultReference value!   
createStorage: storageName
        " Create and open a new storage object named <storageName> in this storage
        in read/write mode.  Answer the new storage. "

	^self createStorage: storageName 
		accessMode: self class accessModeReadWrite!   
localImplementor
		" Answer the OLE object in the current process which supports the receiver.
		Answer nil if the interface is not supported by a local Smalltalk OLE object. "

	| anInterfaceImpl |
	self isOLEInterfaceImplementation
		ifTrue: [ ^interface implementor ].
	self isOLEInterfacePointer
		ifTrue: [
			anInterfaceImpl := OLEInterfaceImplementation localImplementorOf: interface.
			anInterfaceImpl notNil
				ifTrue: [ ^anInterfaceImpl implementor ] ].
	^nil
	

	!  
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^12!  
format: anOleFormatEtc data: anObject
        "Answer an OLE_STGMEDIUM for the specified format
         <anOleFormatEtc> and data transfer object access
         from <anObject>."

    | stgMedium cfFormat address stream size objectFiler hGlobal |
    stgMedium := self new.
    stgMedium tymed: anOleFormatEtc tymed.
    cfFormat := anOleFormatEtc cfFormat.

    cfFormat = CfText ifTrue: [
       anObject class isBytes ifFalse: [ ^self error: 'object must be variable bytes' ].
        stgMedium hGlobal: ( ExternalAddress memoryHandleFrom: anObject ) ].

    cfFormat = ( Clipboard formatNamed: 'object' ) ifTrue: [
        objectFiler := ServiceRegistry globalRegistry serviceNamed: #ObjectFiler
            ifNone: [ self error: 'ObjectFiler not installed' ].
        address := ExternalGlobalAddress allocateMemory: 1024.
        address doesNotNeedFinalization.
        hGlobal := address memoryHandle.
        stream := address asStream.
        stream nextULongPut: 0.    " size place holder "
        objectFiler dump: anObject on: stream.
        size := stream position.
        stream reset; nextULongPut: ( size - 4 ).
        KernelLibrary globalUnlock: hGlobal.
        stgMedium hGlobal: hGlobal ].

    ( ( ( cfFormat = CfBitmap ) or: [ cfFormat = CfMetafilepict ] ) or: [
        cfFormat = CfEnhmetafile ] ) ifTrue: [    "anObject must be a Bitmap or StoredPicture"
            stgMedium dwHandleType: anObject handle ].

    cfFormat = ( Clipboard formatNamed: 'FileName' ) ifTrue: [
        stgMedium lpFileName: anObject ].

    ^stgMedium
!
pData
		" Private - answer the medium handle. "

	^self uLongAtOffset: 8!  
pData: aHandle
		" Private - specify the medium handle. "

	self uLongAtOffset: 8 put: aHandle.!   
releaseResources
		" Private - release resources owned by the receiver. "

	self releaseInterfaces.
	super releaseResources.! 
release
        " Release any system resources associated with the receiver. "

    "Original version using finalization:
    self releaseInterfaces.
    self doesNotNeedFinalization.
    super release.
    "
    OLEDLL current ReleaseStgMedium: self.
    super release!   
pUnkForRelease: anInterfacePointer
        " Private - specify the IUnknown interface point to use to release the medium. "

    ( anInterfacePointer notNil and: [ iUnknown notNil ] )
        ifTrue: [ self error: 'previous contents not released' ].
    self interfaceAtOffset: 8 put: anInterfacePointer.
    iUnknown := anInterfacePointer.!   
releaseInterfaces
        " Private - release the interace pointers."

    backingStoreInterface notNil 
		ifTrue: [ 
			" ReleaseStgMedium released the storage, we need invalidate the interface "
			backingStoreInterface invalidate.	
			backingStoreInterface := nil ].
    iUnknown notNil 
		ifTrue: [ 
			iUnknown release.
			iUnknown := nil ]! 
pstg: anIStorage
        "Set the storage field to <anIStorage>."

    ( anIStorage notNil and: [ backingStoreInterface notNil ] )
        ifTrue: [ self error: 'previous contents not released' ].
    self interfaceAtOffset: 4 put: anIStorage.
    backingStoreInterface := anIStorage.!   
pstm: anIStream
        "Set the storage field to <anIStream>."

    ( anIStream notNil and: [ backingStoreInterface notNil ] )
        ifTrue: [ self error: 'previous contents not released' ].
    self interfaceAtOffset: 4 put: anIStream.
    backingStoreInterface := anIStream.!
lpFileName: aFilePathName
        "Set the receiver's file path name field to <aFilePathName>."

    self addressAtOffset: 4 put: ( ExternalAddress copyToNonSmalltalkMemory: aFilePathName )

! 
hGlobal
        "Answer the receiver's global handle."

    ^self uLongAtOffset: 4!
hGlobal: anAddress
        "Set the receiver's global handle."

    self uLongAtOffset: 4 put: anAddress.! 
tymed: aMediumType
		" Specify the type of the medium on which the data is transfered. "

	self uLongAtOffset: 0 put: aMediumType! 
pUnkForRelease
        " Private - answer the IUnknown interface point to use to release the medium. "

	iUnknown isNil
		ifTrue: [ iUnknown := self interfaceAtOffset: 8 type: IUnknown ].
	^iUnknown!  
tymed
		" Answer the type of the medium on which the data is transfered. "

	^self uLongAtOffset: 0!   
lpFileName
        "Answer the file path name field."

    ^String fromAddress: ( self addressAtOffset: 4 )
! 
dwHandleType: mediumTag
		" Private - specify the type of the medium handle. "

	self uLongAtOffset: 4 put: mediumTag! 
dwHandleType
		" Private - answer the type of the medium handle. "

	^self uLongAtOffset: 4!   
pstg
        "Answer the IStorage in the storage field."

	backingStoreInterface isNil
		ifTrue: [
    			backingStoreInterface := self interfaceAtOffset: 4 type: IStorage ].
	^backingStoreInterface! 
pstm
        "Answer the IStream in the storage field."

	backingStoreInterface isNil
		ifTrue: [ backingStoreInterface := self interfaceAtOffset: 4 type: IStream ].
	^backingStoreInterface!   
vtableAddress
		"Private - Answer the address in external memory at which the 
		function dispatch VTable referenced by the receiver is stored."

	self hasExternalResources 
		ifFalse: [ ^nil ].
	^self externalObjectBody addressAtOffset: 0!
unlockObject
		" Unlock the receiver's object.  This lock is the last reference to the object
		that is supposed to keep it alive. "

	self unlockObject: true.!  
lockCount
		" Answer the number of locks currently held on the receiver. "

	^lockCount!   
allAllocatedInterfaces
		" Private - answer a collection containing the OLE interface pointers on Smalltalk OLE objects 
		which have been allocated in external memory during the current session. "

	^( self elementsInRegistry: self allocatedInterfacesRegistry )
		"select: [ :aResource | aResource isOLEInterfaceImplementation ]"
!
ownedInterfacesRegistry
		" Private - answer the registry containing OLE interfaces owned
		by clients in the current session. "

	^OwnedInterfacesRegistry!  
CoTreatAsClass: clsidOld _: clsidNew
        " Establishes or removes an emulation from one object class to another.
        The <clsidNew> specifies the CLSID of the object class that should emulate
        <clsidOld> replacing any existing emulation. It can be CLSID_NULL, in which
        case any existing emulation for <clsidOld> is removed. "

    "WINOLEAPI CoTreatAsClass(REFCLSID clsidOld, REFCLSID clsidNew);"

    | hresult |
    <api: CoTreatAsClass structIn structIn hresult>
    hresult := self apiFailureReason.
    ( hresult = REGDB_E_CLASSNOTREG
        or: [ hresult = REGDB_E_WRITEREGDB
        or: [ hresult = REGDB_E_READREGDB    ] ] )
        ifTrue: [ ^hresult ].
    ^self apiCallFailed!
structureNameMap
		" Private - answer the dictionary which maps host structure names 
		to data structure definition classes. "

	^StructureNameMap!  
invalidate
		"Invalidate the receiver. "

	interface isOLEInterfacePointer
		ifTrue: [ interface invalidate ].
	interface := nil.!   
removeIID
        " Private - remove the registration of the receiver as the 
		interface implementation binding class for its IID. "

    self removeIID: self iid.! 
ifOLETraceEnabled: aBlock
		" Private - evaluate the trace logic in <aBlock> if OLE tracing
		is currently enabled for the receiver. "

	( OLESessionManager traceEnabled
	and: [ OLESessionManager traceManager traceCallout ] )
		ifTrue: [ aBlock value ].
!
fromUnicode: aUnicodeString
		"Answer a new instance of the receiver which corresponds to the
		platform string format Unicode representation of a GUID in <aUnicodeString>.
		E.g. '{12345678-1234-1234-1234-123456789012}' "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current 
		CLSIDFromString: aUnicodeString
		_: resultReference.
	^resultReference value
!  
isValid
        "Answer whether the receiver is a valid (non-NULL)
         handle."

	^self asInteger ~= 0!  
interfaceReferenceClassForIID: anIID
		" Private - answer the interface reference class
        for the interface whose IID is the interface ID GUID <anIID>. "

	| iidEntry |
	iidEntry := self iidMap at: anIID " ptr, reference, impl "
		ifAbsent: [ ^nil ].
	^iidEntry at: 2! 
sizeInBytes
		"Answer the size of instances of the receiver.  128 bits = 16 bytes."

	^16! 
OleCreate: clsid _: iid _: renderopt _: aFormatEtc _: anIOleClientSite _: anIStorage _: resultReference
        " Create an embedded object of the class specified by the GUID <clsid>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

	" OLECreate is typically used in implementing the Insert New Object scenario. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreate: clsid
        _: iid
        _: renderopt
        _: aFormatEtc
        _: anIOleClientSite asParameter
        _: anIStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!   
OleQueryLinkFromData: anIDataObject
		" Determine whether a container application can create an
		linked object from the data transfer object <anIDataObject>.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeOleQueryLinkFromData: anIDataObject asParameter! 
allOwnedMemoryAddresses
		" Private - answer a collection containing the OLE memory addresses 
		which are owned by this session. "

    ^( self elementsInRegistry: self ownedMemoryRegistry )
        "select: [ :aResource | aResource isOLEExternalAddress ]"
! 
removeEnumeratorIID: anIID
		" Remove the registration of the GUID <anIID> as the IID of an enumerator interface. "

	self elementTypeMap removeKey: anIID ifAbsent: [ ].
	self removeIID: anIID.!
sizeInBytes
        "Answer the size in bytes of instances of the receiver."

	^self byteSize! 
structureNameMap: aDictionary
		" Private - set the dictionary which maps host structure names 
		to data structure definition classes. "

	StructureNameMap := aDictionary.! 
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

	"self ASSERT: ( self iid isNil or: [ self iid = anIID ] )."
	self propertyAt: #iid put: anIID.!
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^self propertyAt: #iid!
invokeOleQueryLinkFromData: pDataObject
        "Private - WINOLEAPI  OleQueryLinkFromData(LPDATAOBJECT pSrcDataObject);"

    <api: OleQueryLinkFromData handle hresult>
	^self apiCallFailed!   
skip: cElements
		" Skip the next <cElements> elements in the enumeration sequence.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Skip: cElements! 
isOLEInterface
		" Answer whether the receiver is an OLE interface. "

	^true! 
invokeOleRegEnumFormatEtc: clsid _: dwDirection _: ppenum
        "Private - WINOLEAPI OleRegEnumFormatEtc (
                                REFCLSID clsid, DWORD dwDirection,
                                LPENUMFORMATETC FAR* ppenum); "

	| hresult |
	<api: OleRegEnumFormatEtc structIn ulong structOut hresult>
	hresult := self apiFailureReason.
	( hresult = REGDB_E_CLASSNOTREG 
	or: [ hresult = REGDB_E_KEYMISSING ] )
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!   
invokeCoGetClassObject: rclsid
    _: dwClsContext
    _: pszServer
    _: riid
    _: ppv
        "Private - WINOLEAPI  CoGetClassObject(
                  REFCLSID rclsid, DWORD dwClsContext, LPVOID pvReserved,
                    REFIID riid, LPVOID FAR* ppv); "

    | hresult |
    <api: CoGetClassObject structIn ulong structIn structIn structOut hresult>
    hresult := self apiFailureReason.
    hresult = E_NOINTERFACE
        ifTrue: [ ^hresult ].
    ^self apiCallFailed!  
revokeClassFactory: aClassFactory
		" Revoke the registration of the class factory object <aClassFactory>. "

	aClassFactory isRegistered not
		ifTrue: [ ^OLEError hresult: CO_E_OBJNOTREG ].
	self revokeRegistration: aClassFactory.
	self classFactoryRegistry remove: aClassFactory ifAbsent: [].
	self compressClassFactoryRegistry.

	" backup check for server application termination "
	( self isInUse not and: [ self exitIfNotInUse ] )
		ifTrue: [  " the entire object server application can be shut down "
			( Message receiver: self selector: #terminateServerApplication )
				performDeferred.
			^self ].!
setBytes: aByteObject
		" Private - set the contents of the receiver to <aByteObject>. "

	aByteObject size = self class sizeInBytes
		ifFalse: [ self error: 'incorrect size' ].
	self bytesAtOffset: 0 put: aByteObject.!  
clone
		" Answer a new enumerator with the same enumeration sequence as the receiver. "

	| resultReference |
	resultReference := ( IEnum forIID: self iid ) asValueReference.
	interface Clone: resultReference.
	"^self class 
		on: resultReference value 
		elementClass: self elementClass"
	^resultReference value!
elementsReversedEnumerator
		" Answer an enumerator on the elements of a composite moniker
		which will operate in the reverse direction.
		Answer nil if there is nothing to enumerate. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumMoniker ) asValueReference.
	interface Enum: false _: resultReference.
	^resultReference value! 
isOLEAvailable: aBooleanOrNil
		" Private - set the flag recording whether OLE support
		has been sucessfully located during this session. "

	IsOLEAvailable := aBooleanOrNil.!  
iid
		"Answer the interface ID GUID which uniquely identifies instances of the receiver. "

	^iid! 
OnViewChange: dwAspect _: lindex
		" Invoke the IAdviseSink::OnViewChange function. "

	( functionHandlers at: 5 ) evaluateWithArguments: ( Array
		with: dwAspect
		with: lindex ).!
invokeOnRename: pmk
        " Private - invoke the IAdviseSink::OnRename function for an external caller. "

	" void OnRename(
            /* [in] */ IMoniker *pmk); "

    | aMoniker |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pmk = 0  " NULL interface pointer "
        ifTrue: [ ^nil ].  " not an HRESULT, so cannot return the usual E_INVALIDARG "
    aMoniker := self interfaceAtAddress: pmk
        type: IMoniker.

    self OnRename: aMoniker.
	^nil!   
OnClose
		" Invoke the IAdviseSink::OnClose function. "

    ( functionHandlers at: 8 ) evaluate.
!   
invokeOnClose
		" Private - invoke the IAdviseSink::OnClose function for an external caller. "

	" void OnClose( void); "

	self ifOLETraceEnabled: [ self logCallbackEntry ].
	self OnClose.
	^nil!   
OnRename: anIMoniker
		" Invoke the IAdviseSink::OnRename function. "

    ( functionHandlers at: 6 ) evaluateWithArguments: ( Array
		with: anIMoniker ).!   
invokeOnDataChange: pFormatetc _: pStgmed
        " Private - invoke the IAdviseSink::OnDataChange function for an external caller. "

    " void OnDataChange(
            /* [unique][in] */ FORMATETC *pFormatetc,
            /* [unique][in] */ STGMEDIUM *pStgmed); "

    | aFormatEtc aStgMedium |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ( pFormatetc isValid
    and: [ pStgmed isValid ] )
        ifFalse: [ ^nil ].  " not an HRESULT, so cannot return the usual E_INVALIDARG "
    aFormatEtc := self structureAtAddress: pFormatetc
        type: #FORMATETC.
    aStgMedium := self structureAtAddress: pStgmed
        type: #STGMEDIUM.
    self OnDataChange: aFormatEtc _: aStgMedium.
	^nil!   
OnSave
		" Invoke the IAdviseSink::OnSave function. "

    ( functionHandlers at: 7 ) evaluate.!   
invokeOnViewChange: dwAspect _: lindex
		" Private - invoke the IAdviseSink::OnViewChange function for an external caller. "

	" void OnViewChange(
            /* [in] */ DWORD dwAspect,
            /* [in] */ LONG lindex);"

	self ifOLETraceEnabled: [ self logCallbackEntry ].
	self OnViewChange: dwAspect _: lindex.
	^nil! 
invokeOnSave
		" Private - invoke the IAdviseSink::OnSave function for an external caller. "

	" void OnSave( void); "

	self ifOLETraceEnabled: [ self logCallbackEntry ].
	self OnSave.
	^nil
! 
OnDataChange: aFormatEtc _: aStgMedium
		" Invoke the IAdviseSink::OnDataChange function. "

    ( functionHandlers at: 4 ) evaluateWithArguments: ( Array
		with: aFormatEtc
		with: aStgMedium ).! 
memorySize
        "Answer the size of the data associated with the receiver"

    self isValid ifFalse: [ ^0 ].
    ^self memoryAllocator getSize: self! 
alloc: anInteger addressType: anOLEAddressClass
		" Invoke the IMalloc::Alloc function. "

	| ulongAddress |
	( ulongAddress := self invokeAlloc: anInteger ) = 0
		ifTrue: [ OLEError signal: 'insufficient memory' ].
	^( anOLEAddressClass fromInteger: ulongAddress )
		needsFinalization! 
HeapMinimize
		" Invoke the IMalloc::HeapMinimize function. "

	" void HeapMinimize( void)"

	<ole: 8 none>
	^self vtableDispatchFailed	!   
DidAlloc: anOLEMemoryAddress
		" Invoke the IMalloc::DidAlloc function. "

	^self invokeDidAlloc: anOLEMemoryAddress asParameter!  
invokeGetSize: pv
		" Private - invoke the IMalloc::GetSize function. "

	" ULONG GetSize(
            /* [in] */ void *pv); "

	<ole: 6 handle ulongReturn>
	^self vtableDispatchFailed!  
invokeFree: pv
		" Private - invoke the IMalloc::Free function. "

	" void Free(
            /* [in] */ void *pv); "

	<ole: 5 handle none>
	^self vtableDispatchFailed	!  
addressClass
		" Private - answer the OLE address class used for memory allocated from the receiver. "

	self == IMalloc taskMemoryAllocator interfaceBinding
		ifTrue: [ ^OLEMemoryAddress ].
	self == IMalloc sharedMemoryAllocator interfaceBinding
		ifTrue: [ ^OLESharedMemoryAddress ].
	OLEError signal: 'unknown OLE memory allocator'!
Alloc: anInteger
		" Invoke the IMalloc::Alloc function. "

	^self alloc: anInteger addressType: self addressClass!
GetSize: anOLEMemoryAddress
		" Invoke the IMalloc::GetSize function. "

	| sizeInBytes |
	( sizeInBytes := self invokeGetSize: anOLEMemoryAddress asParameter ) < 0
		ifTrue: [ OLEError signal: 'invalid address' ].
	^sizeInBytes!   
invokeDidAlloc: pv
		" Private - invoke the IMalloc::DidAlloc function. "

	" int DidAlloc(
            void *pv); "

	<ole: 7 handle short>
	^self vtableDispatchFailed!  
invokeRealloc: pv _: cb
		" Private - invoke the IMalloc::Realloc function. "

	" void *Realloc(
            /* [in] */ void *pv,
            /* [in] */ ULONG cb); "

	<ole: 4 handle ulong ulongReturn>
	^self vtableDispatchFailed	!   
invokeAlloc: cb
		" Private - invoke the IMalloc::Alloc function. "

	" void *Alloc(
            /* [in] */ ULONG cb); "

	<ole: 3 ulong ulongReturn>
	^self vtableDispatchFailed! 
Realloc: anOLEMemoryAddress _: anInteger
		" Invoke the IMalloc:Realloc function. "

	| ulongNewAddress |
	ulongNewAddress := self invokeRealloc: anOLEMemoryAddress asParameter 
		_: anInteger.
	( ulongNewAddress = 0 and: [ anInteger ~= 0 ] )
		ifTrue: [ OLEError signal: 'unable to reallocate memory' ].
	anOLEMemoryAddress uLongAtOffset: 0 put: ulongNewAddress.
	^anOLEMemoryAddress!
Free: anOLEMemoryAddress
		" Invoke the IMalloc::Free function. "

	self invokeFree: anOLEMemoryAddress asParameter.
	anOLEMemoryAddress doesNotNeedFinalization.
!  
invokeOleRegGetUserType: clsid _: dwFormOfType _: pszUserType
        "Private - WINOLEAPI OleRegGetUserType (
                             REFCLSID clsid, DWORD dwFormOfType,
                             LPOLESTR * pszUserType);"

	| hresult |
	<api: OleRegGetUserType structIn ulong structOut hresult>
	hresult := self apiFailureReason.
	( hresult = REGDB_E_CLASSNOTREG 
	"??or: [ hresult = REGDB_E_REGDB_KEY ] ??" )
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^iid!  
removeIID
        " Private - remove the registration of the receiver as the 
		interface pointer binding class for its IID. "

	self removeInterfacePointerClassForIID: self iid.!   
release
		"Invalidate the receiver and remove from finalization (if not already done).  
		Subclass will typically augment this method (via super) to release or free 
		any associated system or OLE resources or references."

	self invalidate.
	super release.! 
invokeWriteClassStg: pStg _: rclsid
		"Private - WINOLEAPI WriteClassStg(LPSTORAGE pStg, REFCLSID rclsid); "

    <api: WriteClassStg handle structIn hresult>
    ^self apiCallFailed!   
new
        "Answer a new OLE interface.  Finalization is used to ensure that the OLE
		interface reference counting rules are followed, in the event that the
		explicit reference counting implemented programmatically is erroneous.. "

      ^super new needsFinalization!  
free
        "Free the memory referenced by the receiver."

	self release.
	self doesNotNeedFinalization.!
vtableDescription
		" Answer an array of entry point descriptions, in VTable order,
		of the receiver's callin VTable functions. "

	^self vtable vtableDescription
!
doDragDropAt: aPoint button: anInteger
        "Private - begin a drag drop session using OLE2's
        drag drop services."

    | dropSourceObject iDropSource dataTransferObject iDataObject |
    self screenLocation: ( aPoint mapClientToScreen: source ).
    self sourceNeedsObject isNil ifTrue: [ ^false ].
    self sourceNeedsCursors.
    ( self objects isNil or: [ self objects isEmpty ] ) ifTrue: [ ^false ].

    dropSourceObject := OLEDropSourceObject new.
    dropSourceObject session: self.
    iDropSource := dropSourceObject queryInterface: IID_IDropSource.

	dataTransferObject := self createTransferObject.
	iDataObject := dataTransferObject queryInterface: IID_IDataObject.

	self class current: self.
	iDropSource doDragDrop: iDataObject
		sourceEffects: DROPEFFECT_COPY | DROPEFFECT_MOVE.
    self class current: nil.

    iDataObject release.
    iDropSource release.
    ^true
!   
impliedOperation
        "Answer the drag-drop operation implied by the current state of the
        shift keys (Alt, Control, Shift). If no shift keys are toggled, answer
        nil (which means that the target application's default operation
        is implied)."

    ( keyState bitAnd: MkControl ) > 0
        ifTrue: [
            ( keyState bitAnd: MkShift ) > 0
                ifTrue: [ ^#move ]
                ifFalse: [ ^#copy ] ]
        ifFalse: [
            ( keyState bitAnd: MkShift ) > 0
               ifTrue: [ ^#move ] ].
    ^nil!   
doDragDropAt: aPoint
        "Private - initiate a drag drop transfer using OLE2's drag
          drop services starting at the given location."

    ^self doDragDropAt: aPoint button: self class dragButtonIndex
!
setOperationScroll: dropEffect
        "Private - set the current operation and scroll flag based
         on the dropEffect which is supplied by IDropSource::giveFeedback."

    scroll := ( dropEffect bitAnd: DROPEFFECT_SCROLL ) > 0.
    ( dropEffect bitAnd: DROPEFFECT_MOVE ) > 0
        ifTrue: [ operation := #move ].
    ( dropEffect bitAnd: DROPEFFECT_COPY ) > 0
        ifTrue: [ operation := #copy ].
    ( dropEffect bitAnd: DROPEFFECT_LINK ) > 0
        ifTrue: [ operation := #link ].
    dropEffect = DROPEFFECT_NONE
        ifTrue: [ operation := nil ].!   
fromIDataObject: iDataObject
        "Private - initialize the receiver's objects with data obtained from <iDataObject>."

    |  object formatEtcs |
    objects := OrderedCollection new.
    formatEtcs := iDataObject getDataFormats.
    object := WinDragDropObject new.
    formatEtcs do: [: formatEtc |
        object format: formatEtc formatDescription data: iDataObject.
        object session: self ].
    objects add: object
!   
sourceFeedback
        "Private - provide visual feedback for the current
        operation code ('move', 'copy', 'link', or nil), which
        indicates what would happen if a drop occurred
        over the current location (target) right now."

    | cursor |
    ( cursor := self cursorForOperation ) isNil ifTrue: [ ^nil ].
    cursor change.
    ^cursor! 
keyState: keyStateCode
        "Set the current state of the shift keys (Alt, Control, Shift)."

    keyState := keyStateCode.!
createTransferObject
        "Private - create a data transfer object and set its data
         with the receiver's objects."

    | dataTransferObject object str |
    dataTransferObject := OLEDataTransferObject new.
    objects size = 1
        ifTrue: [
            object := objects first.
            object session: self.
            object formats keysDo: [: s |
                dataTransferObject setObject: ( object format: s ) format: s ] ]
        ifFalse: [    "multiple objects"
           str := String new.
           objects do: [: each |
               each hasString ifTrue: [
                  str := str, ( each string, ( String with: 13 asCharacter with: 10 asCharacter ) ) ] ].
           str size > 0 ifTrue: [ dataTransferObject setObject: str format: 'string' ].
           dataTransferObject setObject: objects format: 'object' ].
    ^dataTransferObject
!
operationAsDropEffect
        "Answer a DROPEFFECT from the operation string"

    | scrollEffect |
    scrollEffect := 0.
    scroll notNil ifTrue: [
        scrollEffect := scroll ifTrue: [ DROPEFFECT_SCROLL ] ifFalse: [ 0 ] ].
    operation = #move ifTrue: [ ^DROPEFFECT_MOVE | scrollEffect ].
    operation = #copy ifTrue: [ ^DROPEFFECT_COPY | scrollEffect ].
    operation = #link ifTrue: [ ^DROPEFFECT_LINK | scrollEffect].
    ^DROPEFFECT_NONE! 
supportsScrolling
        "Private - Answer whether the receiver supports
        target window scrolling."

    ^true!   
OleGetClipboard: resultReference
		" Retrieve the IDataObject from the clipboard and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IDataObjectPointer forReturnValue.
	hresult := self invokeOleGetClipboard: resultValue asParameter.
	hresult = S_OK
		ifTrue: [ resultReference value: resultValue ].
	^hresult

! 
= aGUID
		" Answer whether the receiver and <aGUID> are equal. "

	^aGUID class = self class and: [ aGUID asByteArray = self asByteArray ]!
traceManager: aTraceManager
		" Set the OLE trace manager. "

	traceManager := aTraceManager.! 
invokeQueryInterface: riid _: ppvObject
		" Private - invoke the IUnknown::QueryInterface function for an external caller. "

	" HRESULT QueryInterface(
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObject); "

    | hresult iid resultReference resultDescription |

	self ifOLETraceEnabled: [ self logCallbackHeader ].

	( riid isValid
	and: [ ppvObject isValid ] )
		ifFalse: [ ^E_INVALIDARG ].
	iid := self guidAtAddress: riid.
	self clearResultValueAtAddress: ppvObject.

	self ifOLETraceEnabled: [ self logIID: iid ].

	resultReference := nil asValueReference.
	hresult := self dispatchQueryInterface: iid 
		_: resultReference.
	self ifOLETraceEnabled: [
		resultReference value notNil
			ifTrue: [ resultDescription := self interfaceResultDescription: resultReference ] ].
	( HRESULT succeeded: hresult )
		ifTrue: [ self interfaceResultAtAddress: ppvObject put: resultReference value ].

	self ifOLETraceEnabled: [
		resultDescription notNil
			ifTrue: [ self logReturnValue: 'Interface: ', resultDescription ].
		self logCallbackExit: hresult ].
	^hresult!  
dragTargetDoGlobalScroll: aDragDropSession
        "Private - implement drag scrolling."

    self implementedBySubclass.! 
Stat: resultReference _: grfStatFlag
		" Invoke the IStream::Stat function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEStructure forReturnValue: #STATSTG.
	hresult :=  self invokeStat: resultValue 
		_: grfStatFlag.
	resultReference value: resultValue.
	^hresult!
invokeSetSize: libNewSize
		" Private - invoke the IStream::SetSize function. "

	" HRESULT SetSize(
            /* [in] */ ULARGE_INTEGER libNewSize); "

	<ole: 6 structValue hresult>
	^self vtableDispatchFailed!  
Revert
		" Invoke the IStream::Revert function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Revert( void); "

	<ole: 9 hresult>
	^self vtableDispatchFailed!   
CopyTo: destStream _: cb _: cbReadReference _: cbWrittenReference
		" Invoke the IStream::CopyTo function.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult cbReadValue cbWrittenValue |
	cbReadReference notNil
		ifTrue: [ cbReadValue := WinLargeInteger new ].
	cbWrittenReference notNil
		ifTrue: [ cbWrittenValue := WinLargeInteger new ].
	hresult := self invokeCopyTo: destStream asParameter
		_: ( cb isNil
			ifTrue: [ WinLargeInteger maxValueUnsigned ]
			ifFalse: [ WinLargeInteger fromUnsignedInteger: cb ] ) 
				asParameter
		_: cbReadValue
		_: cbWrittenValue.
	cbReadReference notNil
		ifTrue: [ cbReadReference value: cbReadValue asUnsignedInteger ].
	cbWrittenReference notNil
		ifTrue: [ cbWrittenReference value: cbWrittenValue asUnsignedInteger ].
	^hresult!  
invokeClone: ppstm
		" Private - invoke the IStream::Clone function. "

	" HRESULT Clone(
            /* [out] */ IStream **ppstm); "

	<ole: 13 structOut hresult>
	^self vtableDispatchFailed!   
Clone: resultReference
		" Invoke the IStream::Clone function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IStreamPointer forReturnValue.
	hresult := self invokeClone: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!
LockRegion: offset _: count _: lockType
		" Invoke the IStream::LockRegion function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeLockRegion: ( WinLargeInteger fromUnsignedInteger: offset ) asParameter
		_: ( WinLargeInteger fromUnsignedInteger: count ) asParameter
		_: lockType!   
invokeLockRegion: libOffset _: cb _: dwLockType
		" Private - invoke the IStream::LockRegion function. "

	" HRESULT LockRegion(
            /* [in] */ ULARGE_INTEGER libOffset,
            /* [in] */ ULARGE_INTEGER cb,
            /* [in] */ DWORD dwLockType); "

	<ole: 10 structValue structValue ulong hresult>
	^self vtableDispatchFailed!   
UnlockRegion: offset _: count _: lockType
		" Invoke the IStream::UnlockRegion function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self  invokeUnlockRegion: ( WinLargeInteger fromUnsignedInteger: offset ) asParameter 
		_: ( WinLargeInteger fromUnsignedInteger: count ) asParameter 
		_: lockType!  
invokeStat: pstatstg _: grfStatFlag
		" Private - invoke the IStream::Stat function. "

	" HRESULT Stat(
            /* [out] */ STATSTG *pstatstg,
            /* [in] */ DWORD grfStatFlag); "

	<ole: 12 structOut ulong hresult>
	^self vtableDispatchFailed! 
Commit: grfCommitFlags
		" Invoke the IStream::Commit function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Commit(
            /* [in] */ DWORD grfCommitFlags); "

	<ole: 8 ulong hresult>
	^self vtableDispatchFailed! 
Read: buffer _: count _: resultReference
		" Invoke the IStream::Read function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultReference notNil 
		ifTrue: [ resultValue := ExternalLong new ].
	hresult := self invokeRead: buffer 
		_: count
		_: resultValue.
	resultReference notNil
		ifTrue: [ resultReference value: resultValue asInteger ].
	^hresult!
Seek: displacement _: dwOrigin _: resultReference
		" Invoke the IStream::Seek function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultReference notNil 
		ifTrue: [ resultValue := WinLargeInteger new ].
	hresult := self invokeSeek: ( WinLargeInteger fromInteger: displacement ) asParameter
		_: dwOrigin
		_: resultValue.
	resultReference notNil
		ifTrue: [ resultReference value: resultValue asUnsignedInteger ].
	^hresult!   
Write: buffer _: count _: resultReference
		" Invoke the IStream::Write function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultReference notNil 
		ifTrue: [ resultValue := ExternalLong new ].
	hresult := self invokeWrite: buffer 
		_: count
		_: resultValue.
	resultReference notNil
		ifTrue: [ resultReference value: resultValue asInteger ].
	^hresult! 
invokeSeek: dlibMove _: dwOrigin _: plibNewPosition
		" Private - invoke the IStream::Seek function. "

	" HRESULT Seek(
            /* [in] */ LARGE_INTEGER dlibMove,
            /* [in] */ DWORD dwOrigin,
            /* [out] */ ULARGE_INTEGER *plibNewPosition); "

	<ole: 5 structValue ulong structOut hresult>
	^self vtableDispatchFailed!   
invokeRead: pv _: cb _: pcbRead
		" Private - invoke the IStream::Read function. "

	" HRESULT Read(
            /* [out] */ void *pv,
            /* [in] */ ULONG cb,
            /* [out] */ ULONG *pcbRead); "

	<ole: 3 structOut ulong structOut hresult>
	^self vtableDispatchFailed! 
invokeWrite: pv _: cb _: pcbWritten
		" Private - invoke the IStream::Write function. "

	" HRESULT Write(
            /* [size_is][in] */ const void *pv,
            /* [in] */ ULONG cb,
            /* [out] */ ULONG *pcbWritten); "

	<ole: 4 structIn ulong structOut hresult>
	^self vtableDispatchFailed!   
invokeCopyTo: pstm _: cb _: pcbRead _: pcbWritten
		" Private - invoke the IStream::CopyTo function. "

	" HRESULT CopyTo(
            /* [unique][in] */ IStream *pstm,
            /* [in] */ ULARGE_INTEGER cb,
            /* [out] */ ULARGE_INTEGER *pcbRead,
            /* [out] */ ULARGE_INTEGER *pcbWritten); "

	<ole: 7 handle structValue structOut structOut hresult>
	^self vtableDispatchFailed!   
SetSize: newSize
		" Invoke the IStream::SetSize function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSetSize: ( WinLargeInteger fromUnsignedInteger: newSize ) asParameter!   
invokeUnlockRegion: libOffset _: cb _: dwLockType
		" Private - invoke the IStream::UnlockRegion function. "

	" HRESULT UnlockRegion(
            /* [in] */ ULARGE_INTEGER libOffset,
            /* [in] */ ULARGE_INTEGER cb,
            /* [in] */ DWORD dwLockType); "

	<ole: 11 structValue structValue ulong hresult>
	^self vtableDispatchFailed! 
invokeCreateGenericComposite: pmkFirst _: pmkRest _: ppmkComposite
        "Private - WINOLEAPI  CreateGenericComposite(
			LPMONIKER pmkFirst, LPMONIKER pmkRest,
			LPMONIKER FAR* ppmkComposite);"

    <api: CreateGenericComposite handle handle structOut hresult>
    ^self apiCallFailed!   
CreateILockBytesOnHGlobal: aGlobalAddress _: fDeleteOnRelease _: resultReference
		" Create an ILockBytes whose data is stored inside the global memory
		handle <aGlobalAddress> and store it into the <resultReference>.
		The memory must be movable and nondiscardable.
		If <fDeleteOnRelease> is set, the memory is automatically
		freed when the stream is released.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ILockBytesPointer forReturnValue.
	hresult := self invokeCreateILockBytesOnHGlobal: aGlobalAddress asParameter
		_: fDeleteOnRelease 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
typeNames: aDictionary
		" Private - set the mapping from system moniker types to descriptive names. "

	TypeNames := aDictionary.!
classForIID: anIID ifNone: aBlock
		" Answer the interface pointer which represents the interface
		specified by the interface ID GUID <anIID>.
  		Answer the result of evaluating <aBlock> if no class is available. "

	| aClass |
	( anIID isNil or: [ anIID = IID_NULL ] )
		ifTrue: [ ^aBlock value ].
	aClass := OLEInterfacePointer interfaceImplementationClassForIID: anIID.
	aClass notNil
		ifTrue: [ ^aClass ].
	aClass := self subclassForIID: anIID.
	aClass notNil
		ifTrue: [  " self-registration backstop "
			self registerIID: anIID forClass: aClass.
			^aClass ].
	^aBlock value
!   
classForIID: anIID
		" Answer the OLEInterface subclass which represents the interface
		specified by the interface ID GUID <anIID>.  Answer nil if the
		interface is not supported. "

	^self classForIID: anIID ifNone: [ nil ]!  
CoUninitialize
		" Close the COM implementation library. This function is unnecessary if the
		OleUninitialize function is used. "

	" WINOLEAPI_(void)  CoUninitialize(void); "

    <api: CoUninitialize none>
    ^self apiCallFailed!  
QueryInterface: iid _: resultReference
		" Invoke the IUnknown::QueryInterface function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |

	self ifOLETraceEnabled: [
		self logFunctionHeader.
		self logIID: iid ].

	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeQueryInterface: iid
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].

	self ifOLETraceEnabled: [
		resultReference value notNil
			ifTrue: [ self logReturnValue: 'Interface: ', resultReference value asParameter printString ].
		self logFunctionExit: hresult ].
	^hresult! 
ReadFmtUserTypeStg: anIStorage 
	_: resultReferenceClipboardFormat 
	_: resultReferenceUserType
		" Read the clipboard format and current user type from the storage <anIStorage>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValueClipboardFormat resultValueUserType hresult |
	resultValueClipboardFormat := ExternalBuffer new: 2.
	resultValueUserType := self createStringResultValue.
	hresult := self invokeReadFmtUserTypeStg: anIStorage asParameter 
		_: resultValueClipboardFormat
		_: resultValueUserType.
	resultValueClipboardFormat isValid  " NULL If the format is no longer of interest to the caller "
		ifTrue: [ resultReferenceClipboardFormat value: ( resultValueClipboardFormat uShortAtOffset: 0 ) ].
	resultValueUserType isValid  " NULL If the user type is no longer of interest to the caller "
		ifTrue: [ resultReferenceUserType value: ( self stringFromResultValue: resultValueUserType ) ].
	^hresult
!   
elementSize
		" Private - answer the size in bytes of an element of the receiver's data type. "

	^elementSize!
invokeDragLeave
        "Private - invoke the IDropTarget::DragLeave function for an external caller. "

	" HRESULT DragLeave( void); "

	^self dispatchDragLeave
! 
invokeCreateDataCache: pUnkOuter _: rclsid _: iid _: ppv
		"Private - WINOLEAPI CreateDataCache(
			LPUNKNOWN pUnkOuter, REFCLSID rclsid,
			REFIID iid, LPVOID FAR* ppv);"

    <api: CreateDataCache handle structIn structIn structOut hresult>
    ^self apiCallFailed! 
asString
        "Answer the platform String representation of the receiver.
        E.g, '{12345678-1234-1234-1234-123456789012}'  "

    | unicodeBuffer count |
    unicodeBuffer := UnicodeStringBuffer new: 40.
    count := OLEDLL current StringFromGUID2: self
        _: unicodeBuffer
        _: unicodeBuffer sizeInBytes.
    count = 0
        ifTrue: [ OLEError signal: 'buffer too small to hold result' ].
    ^UnicodeStringBuffer stringFromUnicode: unicodeBuffer length: count - 1!   
byteStreamOn: anExternalAddress
        "Answer a new instance of the receiver on <anExternalAddress>
        which treats its contents as a byte stream."
 
    ^self new
        asByteStream;
        address: anExternalAddress;
        setLimits!
characterStreamOn: anExternalAddress
        "Answer a new instance of the receiver on <anExternalAddress>
        which treats its contents as a character stream."
 
    ^self new
        asCharacterStream;
        address: anExternalAddress;
        setLimits! 
on: anExternalAddress
        "Answer a new instance of the receiver on <anExternalAddress>."

    ^self byteStreamOn: anExternalAddress!  
asCharacterStream
        "Answer the receiver as a Stream which treats its contents as characters."
 
    self bufferClass: String.!  
next
        "Answer the next object accessible by the receiver
         and advance the stream position.  Report an error
         if the receiver stream is positioned at end."

    | elements |
    self atEnd
        ifTrue: [
            ^self error: 'read beyond end of stream']
        ifFalse: [
            elements := self next: 1.
            ^elements isNil
                ifTrue: [ nil ]
                ifFalse: [ elements at: 1 ] ]!   
asByteStream
        "Answer the receiver as a Stream which treats its contents as bytes."
 
    self bufferClass: ByteArray.! 
setLimits
        "Private - Initialize the stream size and position."

    position := 0.
    readLimit := writeLimit := address memorySize
!   
putBytesFrom: aByteObject from: start to: stop
        "Write the contents of aByteObject to the receiver.
        aByteObject can be a ByteArray or a String.
        start and stop are byte indices into aByteObject. "

    | stopIndex |
    aByteObject isNil ifTrue: [ ^nil ].
    stopIndex := position + (stop - start + 1).
    [stopIndex > writeLimit] whileTrue: [
        self grow ].
    address
        replaceBytesFrom: position + 1
        to: stopIndex
        with: aByteObject
        startingAt: start.
    position := stopIndex.
    readLimit < position
        ifTrue: [readLimit := position].
    ^aByteObject
! 
getBytesFor: aByteObject from: start to: stop
        "Directly copy from the stream to aByteObject.
        start and stop are indices into aByteObject. "
    | stopIndex |
    stopIndex := position + (stop - start + 1).
    (stopIndex > readLimit)
        ifTrue: [^self error: 'read beyond end of stream'].
    aByteObject
        replaceBytesFrom: start
        to: stop
        with: self address
        startingAt: position + 1.
    self position: stopIndex.
    ^aByteObject!  
release
        " Release the associated memory. "

    self address isNil
        ifTrue: [ ^self ].
    self address release.
    self address: nil.
    position := readLimit := writeLimit := 0.
!
address: anExternalAddress
        "Private - set the external address on which the receiver is operating on. "

    address := anExternalAddress! 
bufferClass: anIndexedByteClass
        " Private - specify the class to use for allocating a read buffer. "
 
    bufferClass := anIndexedByteClass.! 
copyFrom: firstIndex to: lastIndex
        "Answer the subcollection of the collection over
         which the receiver is streaming, from firstIndex
         to lastIndex."
    | buffer |
    buffer := self bufferClass new: ( lastIndex - firstIndex + 1 ).
    buffer
        replaceFrom: 1
        to: buffer size
        with: address
        startingAt: firstIndex.
    ^buffer!  
bufferClass
        " Private - answer the class to use for allocating a read buffer. "
 
    ^bufferClass!
address
        "Private - answer the external address on which the receiver is operating on. "

    ^address! 
grow
        "Private - Answer the receiver expanded
         to accommodate more elements."

    | newSize |
    newSize := address memorySize * 2 + 10.
    address reallocateMemory: newSize.
    writeLimit := readLimit := newSize.!  
nextPutAll: aCollection
        "Write each of the objects in <aCollection> to the
         receiver stream.  Answer <aCollection>."

    | stopIndex |
    aCollection class isBytes
        ifFalse: [ self error: 'collection must be bytes' ].
    stopIndex := position + aCollection size.
    stopIndex > writeLimit
        ifTrue: [ self grow ].
    address
        replaceFrom: position + 1
        to: stopIndex
        with: aCollection
        startingAt: 1.
    position := stopIndex.
    ^aCollection!  
nextPut: anObject
        "Write anObject to the receiver stream.
         Answer anObject."

    | index byte |
    index := position + 1.
    index > writeLimit
        ifTrue: [ self grow ].
    position := index.
    byte := anObject asInteger.
    address at: index put: byte.
    ^anObject
! 
typeNameOf: aMonikerType ifAbsent: aBlock
		" Answer the name of the moniker type <aMonikerType>. 
		Answer the result of evaluating <aBlock> if the moniker type
		is not known (e.g., is not a system moniker). "

	^self typeNames at: aMonikerType ifAbsent: [ aBlock value ]!   
oleTRACE: aString
        " Log the debugging message <aString> to the OLE debug trace log. "

	OLESessionManager traceEnabled
		ifTrue: [ OLESessionManager traceManager reportTRACE: aString ].!
dragTargetGlobal: aBoolean
        "Enable/disable the receiver as an OLE drag source."

    self dragTarget: aBoolean.
    aBoolean ifTrue: [  self dragSessionClass: WinDragDropSession ]



!  
incrementLockCount
		" Private - increment the number of locks on the receiver.
		Answer the lock count. "

	self class incrementLockCount.
	^self lockCount: ( self lockCount + 1 )!
stringResultAtAddress: anExternalAddress put: aString
		" Private - store the String output argument value <aString>
		into the caller-provided memory location at <anExternalAddress>
		in Unicode byte encoding. "

    aString isNil ifTrue: [ ^self ].
    ( ExternalBuffer atAddress: anExternalAddress )
        bytesAtOffset: 0
        put: aString asUnicode asParameter.!  
invokeStgOpenStorage: pwcsName _: pstgPriority _: grfMode _: snbExclude _: reserved _: ppstgOpen
		"Private - WINOLEAPI StgOpenStorage(
              const OLECHAR FAR* pwcsName,
              IStorage FAR *pstgPriority,
              DWORD grfMode,
              SNB snbExclude,
              DWORD reserved,
              IStorage FAR * FAR *ppstgOpen);"

    <api: StgOpenStorage structIn handle ulong structIn ulong structOut hresult>
    ^self apiCallFailed! 
asInterfacePointer
        " Answer an interface pointer for the receiver's VTable in external memory. "

    ^interface asInterfacePointer!   
registerIID: anIID forClass: aClass
        " Private - register <aClass> as the interface class representing
        the interface whose IID is the interface ID GUID <anIID>. "

	| pointerBindingClass callinBindingClass |
	"self ASSERT: aClass == IEnum."
	super registerIID: anIID forClass: aClass.
	( pointerBindingClass := aClass interfacePointerClass )
		registerIID: anIID 
		forClass: pointerBindingClass.
	( callinBindingClass := aClass interfaceImplementationClass )
		registerIID: anIID 
		forClass: callinBindingClass.
!   
unlockServer
		"Unlock the object application represented by the receiver."

	interface LockServer: false.!
createInstance
		" Create an uninitialized instance of the receiver's class
		and answer its IUnknown interface. "

    ^self createInstance: IID_IUnknown controllingUnknown: nil!   
lockServer
		"Lock the object application represented by the receiver."

	interface LockServer: true.! 
createInstance: anIID
        " Create an uninitialized instance of the receiver's class
        and answer the interface specified by the GUID <anIID>
        of the new object. "

    ^self createInstance: anIID controllingUnknown: nil!   
createInstance: anIID controllingUnknown: controllingUnknown
		" Create an uninitialized instance of the receiver's class.
		The object is created as a non-control object within an aggregate
		if the IUnknown of a controlling object is specified in <controllingUnknown>.
        Answer the interface specified by the GUID <anIID> of the new object. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: anIID.
    interface CreateInstance: controllingUnknown
        _: anIID
        _: resultReference.
    ^resultReference value!  
LockServer: aBoolean
		" Invoke the IClassFactory::LockServer function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT LockServer(
            /* [in] */ BOOL fLock); "

	<ole: 4 boolean hresult>
	^self vtableDispatchFailed! 
CreateInstance: controllingUnknown _: iid _: resultReference
        " Invoke the IClassFactory::CreateInstance function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |

	self ifOLETraceEnabled: [ 
		self logFunctionHeader.
		self oleTRACE: self logIndent, 'Controlling unknown: ', controllingUnknown printString.
		self logIID: iid ].

    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeCreateInstance: controllingUnknown asParameter
        _: iid
        _: resultValue asParameter.
    resultReference value: resultValue.

	self ifOLETraceEnabled: [ 
		self logReturnValue: self logIndent, 'Interface: ', resultValue printString.
		self logFunctionExit: hresult ].
    ^hresult!  
invokeCreateInstance: pUnkOuter _: riid _: ppvObject
		" Private - invoke the IClassFactory::CreateInstance function. "

	" HRESULT CreateInstance(
            /* [unique][in] */ IUnknown *pUnkOuter,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObject); "

	<ole: 3 handle structIn structOut hresult>
	^self vtableDispatchFailed!   
when: eventName evaluate: anAction
		" Register <anAction> as the interface function dispatch handler 
		if <eventName> is the name of an interface function in the receiver.
		Unlike application events, only one handler is supported for a function.
		Otherwise register <anAction> as an event handler
		in the usual fashion. "

	| anEntryPointName dispatchIndex |
	anEntryPointName := eventName asSymbol.
	dispatchIndex := self entryPointIndex: anEntryPointName.
	dispatchIndex isNil
		ifTrue: [ ^super when: eventName evaluate: anAction ].
	self functionHandlers
		at: dispatchIndex
		put: anAction.!   
iidMap: aDictionary
		" Private - set the dictionary which maps IID's to interface classes. "

	IIDMap := aDictionary.!
DoDragDrop: anIDataObject _: anIDropSource _: dwOKEffects _: resultReference
		" Initiate a drag/drop operation on the data object represented by the
		interfaces <anIDataObject> and <anIDropSource>.  The effects allowed
		by the source are specified in <dwOKEffects>.  The DROPEFFECT value
		indicating how the drag operation outcome affects the source object
		is stored into <resultReference>. 
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeDoDragDrop: anIDataObject asParameter
		_: anIDropSource asParameter
		_: dwOKEffects 
		_: resultValue.
	resultReference value: resultValue asInteger.
	^hresult!
invokeRelease
		"Private - invoke the IUnknown::Release function. "

	" ULONG Release( void); "

	<ole: 2 ulongReturn>
	^self vtableDispatchFailed! 
isOLEInterface
		" Answer whether the receiver is an OLE interface. "

	^true! 
isOLEInterfaceReference
		" Answer whether the receiver is an OLE interface reference
		which provides civilized protocol to invoke the interface functions
		of an OLE interface. "

	^true!
removeStructureName: structureName
		" Remove the registration of <structureName> as the host structure name
		of the data structure definition class <aClass>. "

	self structureNameMap removeKey: structureName asSymbol ifAbsent: [ ].
! 
externalAddress
		" Private - answer the address in external memory
		of the receiver's interface data structures (ptr-ptr-VTable). 
		Allocate the interface structures if not already created. "

	self externalMemoryAddress == nil 
		ifTrue: [ self allocateExternalResources ].
	^self externalMemoryAddress!
resetActiveObjectsRegistry
		" Private - reset the registry of objects which have been created
		during the current session. "

	self activeObjectsRegistry: nil.!
exitIfNotInUse
		" Answer whether the process should be terminated when there
		are no locked class factories and all objects created by class factories
		in the current session have been released. "

	^ExitIfNotInUse!   
registeredClassFactories
        " Answer the class factories which have been registered
        with OLE during the current session. "

    ^ClassFactoryRegistry isNil
        ifTrue: [ #( ) ]
        ifFalse: [ self classFactoryRegistry ]!   
isInUse
		" Answer whether the receiver is in use (is locked or has active objects). "

	^self lockCount > 0 or: [ self activeObjectCount > 0 ]!   
bind: iid
		" Bind the receiver to the object which it references.
		Answer the interface specified by the GUID <iid> on the object. "
		
	| resultReference |
	resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
	OLEDLL current BindMoniker: self 
		_: 0 
		_: iid 
		_: resultReference.
	^resultReference value!   
fileTimeAtOffset: anInteger
		" Answer the FILETIME timestamp at offset <anInteger> in the receiver. "

	| aFileTime |
	aFileTime := self structureAtOffset: anInteger type: #FILETIME.
	aFileTime contents detect: [ :aByte | aByte ~= 0 ]
		ifNone: [ ^nil ].
	^aFileTime asTimeStamp!   
classFactoryForClass: aClass
		" Answer the class factory which has been registered with OLE
		for the OLE object class <aClass>.  Answer nil if not registered. "

	self registeredClassFactories do: [ :aClassFactory |
		aClassFactory objectClass = aClass
			ifTrue: [ ^aClassFactory ] ].
	^nil! 
callinInterfaceIndex
		" Private - answer the index in the external object table of the receiver
		(the interface implementation itself).  This value is stored
		in the receiver's object state in external memory to allow the
		virtual machine callin processing to send a function callin
		invocation message to the receiver. "

	self hasExternalResources 
		ifFalse: [ ^nil ].
	^self externalObjectBody uLongAtOffset: 4
!   
forInterfacePointer
		"Answer a new instance of the receiver for an external interface pointer. "

	^self forBinding: self interfacePointerClass new!  
ownedMemoryRegistry: aRegistry
		" Private - set the registry containing OLE memory addresses owned
		by clients in the current session. "

	| resources |
	( OwnedMemoryRegistry notNil
	and: [ ( resources := self allOwnedMemoryAddresses ) notEmpty ] )
		ifTrue: [ 
			self transferResources: resources 
				to: aRegistry 
				type: 'owned memory addresses'.
			OwnedMemoryRegistry action: nil.  " ignore the old collection "
			].
	OwnedMemoryRegistry := aRegistry.!   
isOLEInterfaceReference
		" Answer whether the receiver is an OLE interface reference
		which provides civilized protocol to invoke the interface functions
		of an OLE interface. "

	^false!   
typeNames
		" Private - answer the mapping from system moniker types to descriptive names. "

	^TypeNames! 
DragEnter: anIDataObject _: grfKeyState _: aPoint _: resultReference
		" Invoke the IDropTarget::DragEnter function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchDragEnter: anIDataObject _: grfKeyState _: aPoint _: resultReference )

!   
CoFreeAllLibraries
		" Free all DLL's previously loaded by CoLoadLibrary , whether or
		not they are currently in use. "
 
	" WINOLEAPI_(void) CoFreeAllLibraries(void); "

    <api: CoFreeAllLibraries none >
    ^self apiCallFailed!   
booleanResultAtAddress: anExternalAddress put: aBoolean
		" Private - store the BOOLEAN output argument value <aBoolean> 
		into the caller-provided memory location addressed at <anExternalAddress>. "

	aBoolean isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress ) 
		booleanAtOffset: 0 
		put: aBoolean.! 
asArrayOfStringsParameter: externalUnicodeStrings
		" Private - answer a buffer for an OLECHAR ** argument.
		The strings must already be unicode strings in external memory. "

	| elementSize stringBuffer offset |
	elementSize := ExternalAddress sizeInBytes.
	stringBuffer := ExternalBuffer new: externalUnicodeStrings size * elementSize.
	offset := 0.
	externalUnicodeStrings do: [ :aString |
		stringBuffer addressAtOffset: offset put: aString contents.
		offset := offset + elementSize ].
	^stringBuffer


!  
invokeDragEnter: pIDataObject _: grfKeyState _: x _: y _: pdwEffect
        "Private - invoke the IDropTarget::DragEnter function for an external caller. "

    " HRESULT DragEnter(
            /* [unique][in] */ IDataObject *pDataObj,
            /* [in] */ DWORD grfKeyState,
            /* [in] */ POINTL pt,
            /* [out][in] */ DWORD *pdwEffect); "

    | hresult anIDataObject resultReference |

    pIDataObject = 0  " NULL interface pointer "
        ifTrue: [ ^E_INVALIDARG ].
    pdwEffect isValid
        ifFalse: [ ^E_INVALIDARG ].
    anIDataObject := self interfaceAtAddress: pIDataObject
        type: IDataObject.
    resultReference := nil asValueReference.
    hresult := self dispatchDragEnter: anIDataObject
        _: grfKeyState
        _: x @ y
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: pdwEffect put: resultReference value ].
    ^hresult!  
revokeRegistration: aClassFactoryObject
		" Private - revoke the registration of a registered class factory. "

	IClassFactory revokeClassObject: aClassFactoryObject registrationToken.
	aClassFactoryObject registeredUnknown release.
	aClassFactoryObject 
		registeredUnknown: nil;
		registrationToken: nil.
	aClassFactoryObject referenceCount > 0
		ifTrue: [ 
			OLEDevelopmentWarning signal: 
				'Revoked class factory for CLSID ', aClassFactoryObject objectCLSID printString,
				' still has outstanding references (ref count = ', 
				aClassFactoryObject referenceCount printString,
				').' ].! 
isHandlerConnected
		" Answer whether the in-process server or handler 
		is connected to the receiver's object. "

    self isValid
        ifFalse: [ OLEError hresult: E_INVALIDARG ].
	^OLEDLL current CoIsHandlerConnected: self!  
typeNameOf: aMonikerType
		" Answer the name of the moniker type <aMonikerType>. 
		Answer the result of evaluating <aBlock> if the moniker type
		is not known (e.g., is not a system moniker). "

	^self typeNameOf: aMonikerType ifAbsent: [ nil ]!   
allocateExternalResources
		"Private - Allocate and initialize the external memory for the receiver.
		An interface in external memory is a pointer to a pointer to a VTable.
		Appended to the middle pointer is private data of the receiver which
		is used by the callin mechanism to process and dispatch the function call.
		(This structure corresponds to the memory layout of a C++ object,
		which has a VTable pointer followed by the object private state.) "

	| callinDescriptorIndex callinInterfaceIndex anAddress |

	" register types descriptor and interface object in the callin processing table "
	callinDescriptorIndex := ExternalObjectTable current 
		indexFor: self vtable vtableCallinDescriptor.
	callinInterfaceIndex :=  ExternalObjectTable current 
		indexFor: self.

	anAddress := OLEMemoryAddress allocateMemory: self class sizeInBytes.
	anAddress doesNotNeedFinalization.  " already tracking myself "
	self externalMemoryAddress: anAddress.
	self externalObjectBody
		addressAtOffset: 0 
			put: self class vtable externalAddress;
		uLongAtOffset: 4 
			put: callinInterfaceIndex;
		uLongAtOffset: 8 
			put: callinDescriptorIndex.

!  
Load: anIStream
		" Invoke the IPersistStream::Load function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeLoad: anIStream asParameter!  
invokeSave: pStm _: fClearDirty
		" Private - invoke the IPersistStream::Save function. "

	" HRESULT Save(
            /* [unique][in] */ IStream *pStm,
            /* [in] */ BOOL fClearDirty); "

	<ole: 6 handle boolean hresult>
	^self vtableDispatchFailed!  
Save: anIStream _: fClearDirty
		" Invoke the IPersistStream::Save function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSave: anIStream asParameter 
		_: fClearDirty!
invokeGetSizeMax: pcbSize
		" Private - invoke the IPersistStream::GetSizeMax function. "

	" HRESULT GetSizeMax(
            /* [out] */ ULARGE_INTEGER *pcbSize); "

	<ole: 7 structOut hresult>
	^self vtableDispatchFailed!
IsDirty
		" Invoke the IPersistStream::IsDirty function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT IsDirty( void);"

	<ole: 4 hresult>
	^self vtableDispatchFailed!  
invokeLoad: pStm
		" Private - invoke the IPersistStream::Load function. "

	" HRESULT Load(
            /* [unique][in] */ IStream *pStm); "

	<ole: 5 handle hresult>
	^self vtableDispatchFailed!   
GetSizeMax: resultReference
		" Invoke the IPersistStream::GetSizeMax function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := WinLargeInteger new.
	hresult := self invokeGetSizeMax: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult
	!   
StgIsStorageFile: aFileName
		" Determine whether the file named <aFileName> is an IStorage object.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeStgIsStorageFile: ( self asUnicodeParameter: aFileName )!   
terminateServerApplication
		" Terminate an object server application by releasing all
		registered class factories and exiting the session. "

	SessionModel current isRunTime
		ifFalse: [ 
			( MessageBox confirm: 'The OLE object server application is no longer in use.  Release all registered class factories and exit the application?' )
				ifFalse: [ ^self ] ].
	self revokeAllClassFactories.
	SessionModel current exitSession.
!   
invokeCoInitialize: pMalloc
        "Private - WINOLEAPI  CoInitialize(LPVOID pvReserved);"

    <api: CoInitialize handle hresult>
    ^self apiCallFailed!  
OleCreateStaticFromData: aDataObject _: iid _: renderopt _: aFormatEtc _: aClientSite _: aStorage _: resultReference
        " Create a static object from the specified data object <aDataObject>.
        Obtain the interface specified by the GUID <iid> and store it into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeOleCreateStaticFromData: aDataObject asParameter
        _: iid
        _: renderopt
        _: aFormatEtc
        _: aClientSite asParameter
        _: aStorage asParameter
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!  
implementor: anObject
		"Private - Set the implementor of the interface to <anObject>."

	implementor == self 
		ifTrue: [ OLEError signal: 'cannot delegate to self' ].
	implementor := anObject.!  
asProgID
		" Answer the PROGID associated with the receiver CLSID
		in the system registry.  Answer nil if the receiver is not a CLSID 
		or is not registered. "

	| resultReference |
	resultReference := nil asValueReference.
	[ OLEDLL current ProgIDFromCLSID: self _: resultReference ]
		on: OLEError
		do: [ ^nil ].
	^resultReference value

!  
getInterfaceForIID: iid
		" Private - answer the interface identified by the GUID <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = IID_IClassFactory
		ifTrue: [ ^iClassFactory ].
	^nil! 
invokeOleCreateStaticFromData: pSrcDataObj _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreateStaticFromData(
            LPDATAOBJECT pSrcDataObj, REFIID iid,
            DWORD renderopt, LPFORMATETC pFormatEtc,
            LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID FAR* ppvObj);"

    <api: OleCreateStaticFromData handle structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed!
asUnicodeParameter: aStringOrNil
		" Private - answer aStringOrNil as a UNICODE string parameter. "

	^aStringOrNil isNil
		ifTrue: [ nil ]
		ifFalse: [ aStringOrNil asUnicode ]!   
trackResources: aBoolean
		" Private - specify whether OLE interfaces owned by clients in the current session
		or exported from the current session should be recorded in finalization registries. "

	" disabling resource tracking should only be allowed the finalization
		registries for OLE resources are empty "
	( aBoolean not
	and: [ self sessionHasResources ] )
		ifTrue: [ self error: 'must release allocated OLE resources' ].
	( aBoolean not and: [ SessionModel current isRunTime not ] )
		ifTrue: [ self error: 'cannot disable resource tracking in dev image' ].  " needed to protect image save "
	TrackResources := aBoolean.!   
lpszVerbName
		" Private - answer the address of the name of the verb. "

	^self addressAtOffset: 4!   
lpszVerbName: anAddressOrNil
		" Private - set the address of the name of the verb. "

	self addressAtOffset: 4 put: anAddressOrNil.!  
fuFlags: flags
		" Set the MF flags for building the object's verb menu. "

	self uLongAtOffset: 8 put: flags! 
grfAttribs
		" Answer the OLEVERBATTRIB flags for this verb. "

	^self uLongAtOffset: 12!  
fuFlags
		" Answer the MF flags for building the object's verb menu. "

	^self uLongAtOffset: 8!   
grfAttribs: grfAttribs
		" Answer the OLEVERBATTRIB flags for this verb. "

	self uLongAtOffset: 12 put: grfAttribs.!  
releaseResources
		" Private - release resources owned by the receiver. "

	self releaseVerbName.
	super releaseResources.!   
releaseVerbName
		" Private - release the verb name in the receiver. "

	| anAddress |
	( anAddress := self lpszVerbName ) notNil
		ifTrue: [
			anAddress free.
			self lpszVerbName: nil.
			].!
iVerb: anInteger
		" Set the verb number to <anInteger>. "

	self longAtOffset: 0 put: anInteger.! 
iVerb
		" Answer the verb number. "

	^self longAtOffset: 0!   
verbName
		" Answer the name of the verb. "

	^self stringAtAddress: self lpszVerbName!
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>.
		The default is to do nothing - the IID is known by the class.
		This method is reimplemented by subclasses whose instances can represent
		more than one interface. "!   
invokeOleDuplicateData: hSrc _: cfFormat _: uiFlags
		"Private - WINOLEAPI_(HANDLE) OleDuplicateData (
                        HANDLE hSrc, CLIPFORMAT cfFormat,
                        UINT uiFlags); "

    <api: OleDuplicateData handle ushort ulong ulongReturn>
    ^self apiCallFailed! 
MonikerRelativePathTo: sourceMoniker _: destMoniker _: resultReference _: dwReserved
		" Create a moniker specifying the relative path from <sourceMoniker>
		to <destMoniker> and store its IMoniker into the <resultReference>.
		Used in the implementation of a moniker class.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self
		invokeMonikerRelativePathTo: sourceMoniker asParameter
		_: destMoniker asParameter
		_: resultValue asParameter
		_: dwReserved.
	resultReference value: resultValue.
	^hresult
! 
OleRegGetMiscStatus: clsid _: dwAspect _: resultReference
		" Obtain the miscellaneous status information for the CLSID <clsid> 
		from the registration database and store it into the <resultReference>.  
		The desired aspect is specified by the DVASPECT value <dwAspect>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeOleRegGetMiscStatus: clsid
		_: dwAspect
		_: resultValue.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue asUnsignedInteger ].
	^hresult!
sizeInBytes
        "Private - Answer the size in bytes of the external memory allocated
		by instances of the receiver. "

	"Instances of the receiver have a 12 byte external memory area as follows:
			offset 0 - 4 byte address of the vtable for the instance.
			offset 4 - 4 byte external object index of the instance. 
			offset 8 - 4 byte external object index of the entry point descriptor array."

    ^12! 
doesNotNeedFinalization
	"The receiver no longer needs to be sent the #finalize message when it is not referenced anymore."

	" this may not be necesssary any more, although it's certainly safe "
	OLESessionManager trackResources
		ifTrue: [ super doesNotNeedFinalization ].!  
guidAtOffset: anInteger put: aGuid
        " Set the 16-byte GUID at offset <anInteger> in the receiver. "

    aGuid size = GUID sizeInBytes
       ifFalse: [ OLEError signal: 'incorrect size for GUID' ].
    self bytesAtOffset: anInteger put: aGuid bytes.!   
registerIID: anIID forClass: aClass
        " Private - register <aClass> as the interface class representing
        the interface whose IID is the interface ID GUID <anIID>. "

	OLEInterfacePointer registerInterfaceReferenceClass: aClass forIID: anIID.!   
isCompositeMoniker
		" Answer whether the receiver is a composite moniker "

	^self systemMonikerType = MKSYS_GENERICCOMPOSITE!
invokeRevokeDragDrop: hwnd
        "Private - WINOLEAPI  RevokeDragDrop(HWND hwnd);"

    <api: RevokeDragDrop handle hresult>
    ^self apiCallFailed!   
revokeAllClassFactories
        " Revoke the registration of all registered class factory objects. "

	self registeredClassFactories do: [ :aClassFactory |
		self revokeRegistration: aClassFactory ].
    self resetClassFactoryRegistry.! 
getObject: anIMoniker
		" Answer the running object designated by <anIMoniker>.
		Answer nil if the object is not registered in the running object table. "

	| resultReference hresult |
	resultReference := IMoniker new asValueReference.
	hresult := interface GetObject: anIMoniker _: resultReference.
	hresult = S_OK  " MK_E_UNAVAILABLE "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value!   
isRunning: anIMoniker
		" Answer whether an object with the moniker <anIMoniker>
		is already registered as running. "

	" This function should generally only be called by implementations of IMoniker::IsRunning.
	Moniker clients should invoke IMoniker::IsRunning on their moniker, rather
	than asking the running object table directly. "

	^( interface IsRunning: anIMoniker ) = S_OK!  
noteChangeTime: registrationToken timeStamp: aTimeStamp
		" Note the time that the object identified by the <registrationToken> changed.
		Raise an exception if an error occurs.  Answer the result code. "

	"The time-changed notification is used by IMoniker::GetTimeOfLastChange. "

	^interface NoteChangeTime: registrationToken _: aTimeStamp! 
weakRegisterObject: anIUnknown moniker: anIMoniker
		" Register the running object <anIUnknown> in the running object table.
		The moniker which is to bind to the newly running object is given by <anIMoniker>.
		The registration is weak, enabling the object to be connected to and released only once.
		Answer a token which identifies the registration. "

	^self registerObject: anIUnknown 
		moniker: anIMoniker 
		flags: 0! 
runningMonikers
		" Answer the monikers of the running objects registered in the running object table. "

	| anEnumerator contents |
	anEnumerator := self runningMonikersEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!   
getTimeOfLastChange: anIMoniker
		" Answer the time of last-change of the running object designated by <anIMoniker>
		Answer nil if the object is not registered in the running object table. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetTimeOfLastChange: anIMoniker _: resultReference.
	^resultReference value!
runningMonikersEnumerator
		" Answer an enumerator that can be used to enumerate the
		monikers of the running objects registered in the running object table. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumMoniker ) asValueReference.
	interface EnumRunning: resultReference.
	^resultReference value!  
registerObject: anIUnknown moniker: anIMoniker flags: grfFlags
		" Register the running object <anIUnknown> in the running object table.
		The moniker which is to bind to the newly running object is given by <anIMoniker>.
		The strength or weakness of the registration is specfied by <grfFlags>.
		Answer a token which identifies the registration. "

	| resultReference hresult |
	resultReference := nil asValueReference.
	hresult := interface Register: grfFlags 
		_: anIUnknown 
		_: anIMoniker 
		_: resultReference.
    hresult = S_OK    " MK_S_MONIKERALREADYREGISTERED "
        ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference value!   
revoke: registrationToken
		" Revoke an object's registration from the running object table. "

	^interface Revoke: registrationToken! 
strongRegisterObject: anIUnknown moniker: anIMoniker
		" Register the running object <anIUnknown> in the running object table.
		The moniker which is to bind to the newly running object is given by <anIMoniker>.
		The registration is strong, enabling multiple clients to connect to and release
		the active object multiple times.
		Answer a token which identifies the registration. "

	^self registerObject: anIUnknown 
		moniker: anIMoniker 
		flags: ROTFLAGS_REGISTRATIONKEEPSALIVE! 
StringFromGUID2: aGUID _: stringBuffer _: cbMax
		" Convert the GUID <aGUID> into a display string, storing the 
		string of up to <cbMax> bytes into the buffer <stringBuffer>.
		Answer the number of characters stored (including the null at the end)."

	" WINOLEAPI_(int) StringFromGUID2(REFGUID rguid, LPOLESTR lpsz, int cbMax); "

	<api: StringFromGUID2 structIn structOut long ulongReturn>
	^self apiCallFailed
!  
lockCount: anInteger
		" Private - set the number of locks currently held on the receiver. "

	lockCount := anInteger.!
MkParseDisplayName: aBindContext 
	_: displayName 
	_: nCharsConsumedReference 
	_: resultReference
		" Parse the display name <displayName> into a moniker for the referenced object.
		Store the moniker interface into <resultReference>.
		Store the number of characters consumed in <displayName> 
		into <nCharsConsumedReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue nCharsConsumed hresult |
	resultValue := IMonikerPointer forReturnValue.
	nCharsConsumed := ExternalLong new.
	hresult := self invokeMkParseDisplayName: aBindContext asParameter
		_: ( self asUnicodeParameter: displayName )
		_: nCharsConsumed
		_: resultValue asParameter.
	resultReference value: resultValue.
	nCharsConsumedReference value: nCharsConsumed asInteger.
	^hresult
!   
logFunctionHeader
        " Private - log function invocation header information to the OLE trace log. "

    self logHeader: Process copyStack.!  
interfaceReferenceClass
		" Private - answer the OLE interface reference class for the receiver. "

	^OLEInterface classForIID: self iid!  
invokeOleCreateLinkToFile: pszFileName _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreateLinkToFile(
            LPCOLESTR lpszFileName, REFIID riid, DWORD renderopt,
            LPFORMATETC lpFormatEtc, LPOLECLIENTSITE pClientSite,
            LPSTORAGE pStg, LPVOID FAR* ppvObj);"

    <api: OleCreateLinkToFile structIn structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed!  
directory
		"Answer the Directory in which the receiver is contained."

	| aDirectory |
	aDirectory := Directory pathName: self pathName fileNamePath.
	^aDirectory valid
		ifTrue: [ aDirectory ]
		ifFalse: [ nil ]! 
pathName
		" Answer the path name of the file containing the receiver. "

	^self name! 
flush
        "Force all data written to the receiver to be
         recorded on disk."

	self commit.!   
fileName
		" Answer the name of the compound document file. "

	^self name fileNameLessPath!   
memorySizeForSize: nChars
		" Answer the number of bytes of memory needed
		for a Unicode buffer which can contain <nChars> characters.
		A trailing NULL character is expected in the buffer. "

	^( nChars * 2 ) + 2!  
newExternalBuffer: anInteger
        "Answer a new instance of the receiver with a buffer in
         external memory of size <anInteger> characters."

	^( self atAddress: ( ExternalAddress allocateMemory: ( self memorySizeForSize: anInteger ) ) )
		size: anInteger;
		setTrailingNull;
		yourself!  
fromAddress: anExternalAddress
        "Answer a Unicode string buffer whose bytes are copied
        from memory at <anExternalAddress>."

    ^self fromAddress: anExternalAddress 
		length: ( self lengthAtAddress: anExternalAddress )! 
lengthAtAddress: anExternalAddress
		" Answer the length in characters of the Unicode string at <anExternalAddress>. "

    | nullChar aWideChar nChars byteIndex |
    nullChar := ByteArray new: 2.
    aWideChar := ByteArray new: 2.
    nChars := 0.
    byteIndex := 1.
    [ aWideChar 
          replaceBytesFrom: 1
          to: 2
          with: anExternalAddress
          startingAt: byteIndex.
    aWideChar = nullChar ] 
        whileFalse: [
            nChars := nChars + 1.
            byteIndex := byteIndex + 2 ].
	^nChars!  
atAddress: anExternalAddress length: anInteger
        " Answer a new instance of the receiver whose
         bytes are stored in memory at <anExternalAddress>.
		The allocated memory must be able to contain
		<anInteger> characters."

	anExternalAddress memorySize >= ( self memorySizeForSize: anInteger )
		ifFalse: [ self error: 'not enough memory in buffer' ].
	^( self atAddress: anExternalAddress )
		size: anInteger;
		yourself! 
new: anInteger
        "Answer a new instance of the receiver with
         size <anInteger> characters."

	^super new: ( anInteger * 2 )!
fromAddress: anExternalAddress length: anInteger
        "Answer a Unicode string buffer of size <anInteger> characters
         whose bytes are copied from memory at <anExternalAddress>."

    | unicodeBuffer |
    unicodeBuffer := self new: anInteger.
    unicodeBuffer contents
        replaceFrom: 1
        to: anInteger * 2
        withAddress: anExternalAddress
        startingAt: 1.
   ^unicodeBuffer! 
newExternalBufferFromString: aString
        "Answer a new instance of the receiver with a buffer in
         external memory containing the characters of <aString>."

	^( self newExternalBuffer: aString size )
		bytesAtOffset: 0 put: aString asUnicode asByteArray;
		yourself!   
stringFromUnicode: aUnicodeBuffer length: nChars
        "Answer a String containing the first <nChars> characters 
		of the Unicode string in <aUnicodeBuffer>."

    | aString result |
    aString := String new: nChars.
    result := KernelLibrary
        wideCharToMultiByteCp: "CP_ACP" 0  " ANSI code page "
        flags: 0
        lpwstr: aUnicodeBuffer
        cchwstr: nChars * 2
        lpstr: aString
        cchlpstr: aString size
        default: nil
        defaultUsed: nil.
    ^aString!  
fromString: aString
        "Answer an instance of the receiver containing
		a Unicode string with the characters of <aString>.
		A NULL terminator is always appended to the buffer. "

    | unicodeBuffer nChars |
    unicodeBuffer := self new: aString size.
    nChars := KernelLibrary
        multiByteToWideCharCp: "CP_ACP" 0  " ANSI code page "
        flags: 0
        lpstr: aString
        cchstr: aString size
        lpwstr: unicodeBuffer
        cchwstr: unicodeBuffer sizeInBytes.
	nChars < aString size
		ifTrue: [ self error: 'unicode translation failed' ].
    ^unicodeBuffer
!  
do: aBlock
        "Answer the receiver.  For each character in the receiver,
         evaluate <aBlock> with that character as the argument."

    | byteIndex lastCharByteIndex |
    byteIndex := 1.
    lastCharByteIndex := self sizeInBytes.
    [ byteIndex > lastCharByteIndex ]
        whileFalse: [
            aBlock value: ( Character value: 
                ( self contents at: byteIndex )
                + ( (self contents at: byteIndex + 1 ) bitShift: 8 ) ).
            byteIndex := byteIndex + 2 ]!
at: anInteger put: aCharacter
        " Store <aCharacter> (or a legal integer character code value)
        in the <anInteger>-th index position in the receiver.
        Answer aCharacter. "

    | byteIndex cv |
    self checkIndex: anInteger.
    self checkCharacter: aCharacter.
    byteIndex := self byteIndexOfCharAt: anInteger.
    cv := ( aCharacter isInteger
		ifTrue: [ aCharacter ]
		ifFalse: [ aCharacter asInteger ] ).
    self contents
        at: byteIndex put: ( cv bitAnd: 16rFF );
        at: ( byteIndex + 1 ) put: ( ( cv bitAnd: 16rFF00 ) bitShift: -8 ).
    ^aCharacter!
byteIndexOfCharAt: anInteger
        "Private - answer the index of the first byte of
          the character at <anInteger> in the receiver. "

    ^( anInteger * 2 ) - 1!  
computeSize
        " Private - answer the number of characters in the receiver string. 
		Exclude the trailing NULL character. "

    ^self isInExternalMemory
		ifTrue: [ self class lengthAtAddress: self contents ]
		ifFalse: [ self contents size // 2 - 1 ]! 
asByteArray
        "Answer a ByteArray whose contents are the
         bytes of the receiver."

    ^self bytesAtOffset: 0 count: self sizeInBytes!  
checkCharacter: aCharacter
        "Private - Report an error if the argument
         aCharacter is not an instance of class Character."

    aCharacter isInteger
		ifTrue: [
			( aCharacter between: 0 and: 16rFFFF )
				ifFalse: [ 
            			^self error: self class name, ' can''t hold ', aCharacter printString ].
			^self ].
    aCharacter isCharacter
        ifFalse: [
            ^self error: self class name, ' can''t hold '
                , aCharacter class name ].
!  
printOn: aStream
        "Append the receiver as a quoted string
         to aStream doubling all internal single
         quote characters."

    self isValid
        ifFalse: [
            super printOn: aStream.
            aStream nextPutAll: ' on: '.
            self contents printOn: aStream.
            ^self ].
    aStream nextPutAll: '(Unicode) '.
    aStream nextPut: $'.
    self do: [ :character |
        aStream nextPut: character.
        character = $'
            ifTrue: [ aStream nextPut: character ] ].
    aStream nextPut: $'.!   
clearCharacterAt: anInteger
		" Private - clear the character at position <anInteger> in the receiver. "

	| byteIndex |
	byteIndex := self byteIndexOfCharAt: anInteger.
	self contents
		at: byteIndex put: 0;
		at: byteIndex + 1 put: 0.!  
errorInBounds: anInteger
        "Private - Report an error to the effect that
         <anInteger> is an invalid index for the receiver."

    ^self
        error: 'index: ',
            anInteger printString,
            ' is outside of string bounds'! 
asGUID
		" Answer the GUID specified by the receiver if it is
		a syntactically legal string representation of a GUID. "

    ^GUID fromUnicode: self!
at: anInteger
        "Answer the character at position
         <anInteger> in the receiver string."

    | byteIndex |
    self checkIndex: anInteger.
    byteIndex := self byteIndexOfCharAt: anInteger.
	^Character value: (
		( self contents at: byteIndex )
		+ ( (self contents at: byteIndex + 1 ) bitShift: 8 ) )!
asString
        "Answer a String containing the characters of
         the receiver."

	^self class stringFromUnicode: self length: self size!   
asUnicode
        "Answer a Unicode copy of the receiver"

	^self! 
memorySize
		" Private - answer the size in bytes of the buffer.
		Include the trailing two bytes of the NULL terminator. "

    ^self isInExternalMemory
		ifTrue: [ self class memorySizeForSize: self size ]
		ifFalse: [ self contents size ]!  
clear
		" Clear the contents of the receiver to a string of NULL characters. "

	self isInExternalMemory
		ifTrue: [ 1 to: self size do: [ :i | self clearCharacterAt: i ] ]
		ifFalse: [ self contents atAllPut: 0 ].!  
copyToExternalMemory
        "Copy the receiver to external (non-Smalltalk) memory,
        and answer an instance of ExternalAddress."

    ^ExternalAddress copyToNonSmalltalkMemory: self asParameter! 
release
		" Free the resources associated with the receiver. "

	self releaseContents.
	super release.!   
contents: aByteArray
        "Set the contents of the receiver to aByteArray."

	super contents: aByteArray.
	self size: nil.!
sizeInBytes
		" Private - answer the size in bytes of the string.
		Exclude the trailing two bytes of the NULL terminator. "

    ^self size * 2! 
setTrailingNull
		" Set the trailing NULL character in the receiver. "

	self clearCharacterAt: self size + 1.!
checkIndex: anInteger
        "Private - Check that the argument <anInteger>
         is a valid character position index for the receiver.
         If it is found to be invalid, report the error."

    anInteger isInteger
        ifFalse: [
            ^self error:
                'strings are indexed by integers'].
    ( anInteger between: 1 and: self size )
        ifFalse: [ ^self errorInBounds: anInteger ]! 
size
        " Answer the number of characters in the receiver string. 
		Exclude the trailing NULL character. "

	size isNil
		ifTrue: [ self size: self computeSize ].
	^size!
size: anInteger
		" Private - record the size in characters of the receiver. "

	size := anInteger.!   
initialSize: anInteger
        "Private - initialize the contents instance variable to
        an appropriately sized ByteArray.  Always include
        room for a trailing NULL character. "

    ^super initialSize: anInteger + 2.!  
unlockObject: lastLockReleases
		" Unlock the receiver's object.  The <lastLockReleases> flag
		 specifies whether the lock is the last reference to the object
		that is supposed to keep it alive. "

	OLEDLL current CoLockObjectExternal: self _: false _: lastLockReleases.!
sessionStartedToServiceObjects
        " Answer whether the current session was started by OLE
        to service objects. "

    | commandLineArguments |
	commandLineArguments := self sessionCommandLineArguments.
    ^( commandLineArguments
        detect: [ :anArgument |
            ( anArgument equalsIgnoreCase: '-Embedding' )
            or: [ anArgument equalsIgnoreCase: '/Embedding' ] ]
        ifNone: [ nil ] )
            notNil!  
invokeCreateStreamOnHGlobal: hGlobal _: fDeleteOnRelease _: ppstm
		"Private - WINOLEAPI CreateStreamOnHGlobal (
							HGLOBAL hGlobal, BOOL fDeleteOnRelease,
                                LPSTREAM FAR* ppstm);"

    <api: CreateStreamOnHGlobal handle boolean structOut hresult>
    ^self apiCallFailed!  
registerIID
        " Private - register the receiver as the interface implementation binding class for its IID. "

    self registerIID: self iid forClass: self.!
new
		"Answer a newly generated GUID guaranteed to be unique across all machines."

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current CoCreateGuid: resultReference.
	^resultReference value!  
dragEnter: aDataObject keyState: keyStateFlags at: aPoint 
		" Determine whether the drag target can accept <aDataObject>.
		The mouse is entering the window at <aPoint>.
		Answer the desired drop effect. "

	| resultReference |
	resultReference := nil asValueReference.
	interface DragEnter: aDataObject
		_: keyStateFlags 
		_: aPoint
		_: resultReference.
	^resultReference value!
drop: aDataObject keyState: keyStateFlags at: aPoint
		" The dragged object <aDataObject> has been dropped on the target.
		The current state of the keyboard modifier keys is indicated by the <grfKeyState> flags.
		The current mouse/cursor position is given in <aPoint>.
		Answer the desired drop effect code. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Drop: aDataObject _: keyStateFlags _: aPoint _: resultReference.
	^resultReference value! 
registerDragDrop: aWindow
		" Register the receiver as the drop target for <aWindow>. "

	self lockObject.
	OLEDLL current RegisterDragDrop: aWindow _: self.!
dragLeave
		" The mouse has left the target window during a drag operation. 
		Raise an exception if an error occurs.  Answer the result code. "

	^interface DragLeave!  
revokeDragDrop: aWindow
		" Revoke the receiver as the drop target for <aWindow>. "

	OLEDLL current RevokeDragDrop: aWindow.
	self unlockObject.!
dragOver: keyStateFlags at: aPoint
		" The mouse has moved over the target window during a drag operation.
		The current state of the keyboard modifier keys is indicated by the <keyStateFlags>.
		The current mouse/cursor position is given in <aPoint>.
		Answer desired drop effect code. "

	| resultReference |
	resultReference := nil asValueReference.
	interface DragOver: keyStateFlags _: aPoint _: resultReference.
	^resultReference value!   
WriteClassStm: anIStream _: clsid
		" Write the CLSID specified by the GUID <clsid> to the stream <anIStream>.
		Raise an exception if an error occurs.  Answer the result code. "

	" Most applications do not call WriteClassStm; it is called by OLE
	before making a call to an application's IPersistStream::Save function. "

	^self invokeWriteClassStm: anIStream asParameter 
		_: clsid
!  
elementTypeOfIID: anIID
		" Answer the type of elements enumerated by an interface
		whose IID is <anIID>. "

	^self elementTypeMap at: anIID ifAbsent: [ nil ]!  
invokeWriteClassStm: pStm _: rclsid
		"Private - WINOLEAPI WriteClassStm(LPSTREAM pStm, REFCLSID rclsid); "

    <api: WriteClassStm handle structIn hresult>
    ^self apiCallFailed!
OleLoad: anIStorage _: iid _: anIOleClientSite _: resultReference
		" Load an embedded or linked object into memory from the
		storage <anIStorage> and set its client site to <anIOleClientSite>.
		Obtain the interface specified by GUID <iid> on the object
		and store the interface pointer into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeOleLoad: anIStorage asParameter
		_: iid
		_: anIOleClientSite asParameter
		 _: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!
invokeCreateBindCtx: reserved _: ppbc
        "Private - WINOLEAPI  CreateBindCtx(DWORD reserved, LPBC FAR* ppbc);"

    <api: CreateBindCtx ulong structOut hresult>
    ^self apiCallFailed!
startUp
		" Private - the session is being started.  Reset OLE resources owned or allocated
		during the previous session. "

	self resetResources.
	ExternalObjectTable startUp.
	OLEClassFactoryObject resetServerState.

	self isOLEAvailable: nil.
	self initializeSpecialSessionResources.
	IMalloc resetMemoryAllocators.  " reset references to the task memory allocators "
	IRunningObjectTable resetCurrent.  " release the reference to the running object table. "
	"OLE2DLL current handle is reset by DynamicLinkLibrary startup processing"
! 
elementSize: anInteger
		" Private - specify the size in bytes of an element of the receiver's data type. "

	elementSize := anInteger.!   
logCallbackHeader
        " Private - log callback invocation header information to the OLE trace log. "

	self logHeader: Process copyStack.
!   
interfaceBinding: anInterfaceBinding
		" Private - set the interface binding which provides function invocation services 
		for the receiver to <anInterfaceBinding>. "

	| newBinding |

	( anInterfaceBinding notNil 
	and: [ anInterfaceBinding iid notNil
	and: [ anInterfaceBinding iid ~= self iid ] ] )
		ifTrue: [ self error: 'IID mismatch' ].

	newBinding := ( ( anInterfaceBinding isNil or: [ anInterfaceBinding isValid not ] )
		ifTrue: [ nil ]
		ifFalse: [ anInterfaceBinding ] ).
	"self ASSERT: 
		( newBinding isNil 
		or: [ newBinding isOLEInterfacePointer
		or: [ newBinding isOLEInterfaceImplementation ] ] )."

	interface notNil
		ifTrue: [
			newBinding notNil
				ifTrue: [ self error: 'cannot swap interface pointers' ].
			interface release ].
	interface := newBinding.! 
dispatchLockServer: aBoolean
		"Private - dispatch the IClassFactory::LockServer function. "

	^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
		with: aBoolean )! 
LockServer: aBoolean
		" Invoke the IClassFactory::LockServer function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: ( self dispatchLockServer: aBoolean )!  
CreateInstance: controllingUnknown _: iid _: resultReference
        " Invoke the IClassFactory::CreateInstance function.
        Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: ( self dispatchCreateInstance: controllingUnknown _: iid _: resultReference )!  
invokeLockServer: aBoolean
        " Private - invoke the IClassFactory::LockServer function for an external caller. "

	" HRESULT LockServer(
            /* [in] */ BOOL fLock); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchLockServer: aBoolean.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
dispatchCreateInstance: controllingUnknown _: iid _: resultReference
		"Private - dispatch the IClassFactory::LockServer function. "

	^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
		with: controllingUnknown
		with: iid
		with: resultReference )! 
invokeCreateInstance: pUnkOuter _: riid _: ppvObject
        " Private - invoke the IClassFactory::CreateInstance function for an external caller. "

	" HRESULT CreateInstance(
            /* [unique][in] */ IUnknown *pUnkOuter,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObject); "

	| hresult controllingUnknown iid resultReference resultDescription |

	self ifOLETraceEnabled: [ self logCallbackHeader ].

	( riid isValid
	and: [ ppvObject isValid ] )
		ifFalse: [ ^E_INVALIDARG ].
	controllingUnknown := self interfaceAtAddress: pUnkOuter
		type: IUnknown.
	iid := self guidAtAddress: riid.
	self clearResultValueAtAddress: ppvObject.

	self ifOLETraceEnabled: [ 
		self oleTRACE: self logIndent, 'Controlling unknown: ', controllingUnknown printString.
		self logIID: iid ].

	resultReference := nil asValueReference.
	hresult := self dispatchCreateInstance: controllingUnknown 
		_: iid 
		_: resultReference.
	self ifOLETraceEnabled: [ 
		resultDescription := self interfaceResultDescription: resultReference ].
	( HRESULT succeeded: hresult )
		ifTrue: [ self interfaceResultAtAddress: ppvObject put: resultReference value ].

	self ifOLETraceEnabled: [ 
		self logReturnValue: resultDescription.
		self logCallbackExit: hresult ].
	^hresult! 
reset
        " Reset the enumeration sequence back to the beginning.
        Answer the result code. "

    ^interface Reset!
validateResourceTracking
		" Private - verify that all OLE resources being tracked are in the expected places
		and in expected states.
			OLESessionManager validateResourceTracking.
		"

	| misplacedResources allocatedInterfaces exportedInterfaces |

	misplacedResources := ( SystemWeakRegistries externalResources ephemerons keys
		select: [ :aResource | 
			aResource isOLEInterface
			or: [ aResource isOLEExternalAddress ] ] )
		asArray.
	misplacedResources notEmpty
		ifTrue: [ 
			misplacedResources inspect.
			OLEDevelopmentWarning signal: 'OLE resources found in system host resources registry.  This is bad!!'. ].

	allocatedInterfaces := self allAllocatedInterfaces.
	exportedInterfaces := self allExportedInterfaces.
	( allocatedInterfaces elementsEqual: exportedInterfaces )
		ifFalse: [
			OLEDevelopmentWarning signal: 'Allocated/exported interface tracking mismatch found.'.
			].! 
hresult: anInteger
        "Set the OLE result code which caused the notification to <anInteger>
        and generate a text message describing it."

	hresult := anInteger.
	self messageText: ( HRESULT description: anInteger ).! 
hresult
        "Answer the OLE result code which caused the notification. "

    ^hresult!
initialize
        "Private - initialize the receiver to be an unexpected OLE error."

    self hresult: E_UNEXPECTED.!
CreateItemMoniker: delimiterString _: itemName _: resultReference
		" Create an item moniker from <itemName>, prefixed by the given <delimiterString>.
		Store the interface pointer into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeCreateItemMoniker: ( self asUnicodeParameter: delimiterString )
		_: ( self asUnicodeParameter: itemName )
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
!   
hash
        "Answer the integer hash value of the receiver."

	^self iid hash bitXor: implementor hash!   
ReleaseStgMedium: aStgMedium
		" Release the storage medium <aStgMedium>. "

	" WINOLEAPI_(void)   ReleaseStgMedium(LPSTGMEDIUM); "

	< api: ReleaseStgMedium struct none>
	^self apiCallFailed!
forBinding: anInterfaceBinding
		" Answer a new instance of the receiver with callin/callout binding <anInterfaceBinding>. "

	^self new
		interfaceBinding: anInterfaceBinding;	
		yourself!
CoInitialize: anIMalloc
		"Initialize the COM implementation library using the memory allocator <anIMalloc>.
		If no memory allocator is specified, the default OLE task allocator is used.
		This function is unnecessary if the OleInitialize function is used.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeCoInitialize: anIMalloc asParameter!
asStream
		" Answer a read/write stream on the receiver. "

	^MemoryReadWriteStream on: self!  
invokeOleInitialize: pMalloc
        "Private - WINOLEAPI OleInitialize(LPVOID pvReserved);"

    <api: OleInitialize handle hresult>
    ^self apiCallFailed!
interfaceResultDescription: resultReference
		" Private - answer a description of an interface result value. "

	^resultReference value asParameter printString!   
clearResultStructureAtAddress: anExternalAddress type: aStructureSpecification
		" Private - clear the contents of the host structure identified by <aStructureSpecification>
		at <anExternalAddress>. "

	| nBytes |

	anExternalAddress isValid
		ifFalse: [ ^self ].   " NOP if client didn't provide result buffer "

	nBytes := ( aStructureSpecification isClass
		ifTrue: [ aStructureSpecification sizeInBytes ]
		ifFalse: [ OLEStructure sizeOfStructureNamed: aStructureSpecification ] ).
	( ExternalBuffer atAddress: anExternalAddress )
		bytesAtOffset: 0 
		put: ( ByteArray new: nBytes ).
!
iid
		"Answer the interface ID GUID which uniquely identifies instances of the receiver. "

	^iid! 
isOLEAvailable
        " Answer whether the basic OLE support is available. "

	IsOLEAvailable isNil
		ifTrue: [ self isOLEAvailable: self checkIsOLEAvailable ].
	^IsOLEAvailable!  
invokeSendOnDataChange: pDataObject _: dwReserved _: advf
		" Private - invoke the IDataAdviseHolder::Advise function. "

	" HRESULT SendOnDataChange(
            /* [unique][in] */ IDataObject *pDataObject,
            /* [in] */ DWORD dwReserved,
            /* [in] */ DWORD advf); "

	<ole: 6 handle ulong ulong hresult>
	^self vtableDispatchFailed!
Unadvise: dwConnection
		" Invoke the IDataAdviseHolder::Unadvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Unadvise(
            /* [in] */ DWORD dwConnection);"

	<ole: 4 ulong hresult>
	^self vtableDispatchFailed!  
invokeAdvise: pDataObject _: pFetc _: advf _: pAdvise _: pdwConnection
		" Private - invoke the IDataAdviseHolder::Advise function. "

	" HRESULT Advise(
            /* [unique][in] */ IDataObject *pDataObject,
            /* [unique][in] */ FORMATETC *pFetc,
            /* [in] */ DWORD advf,
            /* [unique][in] */ IAdviseSink *pAdvise,
            /* [out] */ DWORD *pdwConnection); "

	<ole: 3 handle structIn ulong handle structOut hresult>
	^self vtableDispatchFailed!
EnumAdvise: resultReference
		" Invoke the IDataAdviseHolder::EnumAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumSTATDATA.
	hresult := self invokeEnumAdvise: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
Advise: aDataObject _: aFormatEtc _: advfFlags _: anAdviseSink _: resultReference
		" Invoke the IDataAdviseHolder::Advise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self
		invokeAdvise: aDataObject asParameter
		_: aFormatEtc
		_: advfFlags
		_: anAdviseSink asParameter 
		_: resultValue.
	resultReference value: resultValue asInteger.
	^hresult
!
invokeEnumAdvise: ppenumAdvise
		" Private - invoke the IDataAdviseHolder::EnumAdvise function. "

	" HRESULT EnumAdvise(
            /* [out] */ IEnumSTATDATA **ppenumAdvise); "

	<ole: 5 structOut hresult>
	^self vtableDispatchFailed!   
SendOnDataChange: anIDataObject  _: dwReserved _: advfFlags
		" Invoke the IDataAdviseHolder::Advise function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self 
		invokeSendOnDataChange: anIDataObject asParameter 
		_: dwReserved
		_: advfFlags!   
invokeCoLockObjectExternal: pUnk _: fLock _: fLastUnlockReleases
        "Private - WINOLEAPI CoLockObjectExternal(
			LPUNKNOWN pUnk, BOOL fLock, BOOL fLastUnlockReleases);"

    <api: CoLockObjectExternal handle boolean boolean hresult>
    ^self apiCallFailed!  
constructStructureNameMap
		" Private - answer the map from a host data structure name
		to the OLE structure definition class which represents that type. "

	^Dictionary new
		at: #DVTARGETDEVICE put: OLE_DVTARGETDEVICE;
		at: #FILETIME put: OLE_FILETIME;
		at: #FORMATETC put: OLE_FORMATETC;
		at: #LPOLESTR put: OLE_LPOLESTR;
		at: #OBJECTDESCRIPTOR put: OLE_OBJECTDESCRIPTOR;
		at: #OLEVERB put: OLE_OLEVERB;
		at: #STATDATA put: OLE_STATDATA;
		at: #STATSTG put: OLE_STATSTG;
		at: #STGMEDIUM put: OLE_STGMEDIUM;
		yourself!   
isAntiMoniker
		" Answer whether the receiver is an anti-moniker "

	^self systemMonikerType = MKSYS_ANTIMONIKER!  
deviceName
		" Answer the device name. "

	^self stringAtOffset: self tdDeviceNameOffset!  
driverName
		" Answer the driver name. "

	^self stringAtOffset: self tdDriverNameOffset!  
tdPortNameOffset: anInteger
		" Private - specify the offset from the start of this structure to the port name. "

	self uShortAtOffset: 8 put: anInteger.!
tdPortNameOffset
		" Private - answer the offset from the start of this structure to the port name. "

	^self uShortAtOffset: 8!   
tdExtDevmodeOffset: anInteger
		" Private - specify the offset from the start of this structure to the DEVMODE. "

	self uShortAtOffset: 10 put: anInteger.!   
portName
		" Answer the port name. "

	^self stringAtOffset: self tdPortNameOffset!
tdDeviceNameOffset: anInteger
		" Private - specify the offset from the start of this structure to the device name. "

	self uShortAtOffset: 6 put: anInteger.!
tdDriverNameOffset: anInteger
		" Private - specify the offset from the start of this structure to the driver name. "

	self uShortAtOffset: 4 put: anInteger.!
tdSize
		" Private - answer the size of this DVTARGETDEVICE in bytes, including all bytes following the header. "

	^self uLongAtOffset: 0!
stringAtOffset: anInteger
		" Private - answer the null-terminated string at offset <anInteger> 
		from the start of the receiver. "

	anInteger = 0 ifTrue: [ ^'' ].
	self error: 'not yet implemented'!
tdExtDevmodeOffset
		" Private - answer the offset from the start of this structure to the DEVMODE. "

	^self uShortAtOffset: 10!  
extDevMode
		" Answer the DEVMODE. "

	^self stringAtOffset: self tdExtDevmodeOffset!  
tdSize: anInteger
		" Private - answer the size of this DVTARGETDEVICE in bytes, including all bytes following the header. "

	self uLongAtOffset: 0 put: anInteger.!  
tdDeviceNameOffset
		" Private - answer the offset from the start of this structure to the device name. "

	^self uShortAtOffset: 6!   
tdDriverNameOffset
		" Private - answer the offset from the start of this structure to the driver name. "

	^self uShortAtOffset: 4!   
interfaceImplementationClass
		" Private - answer the interface implementation class which is referenced
		by instances of the receiver. "

	^OLEInterfaceImplementation classForIID: self iid
	!
releaseResources
        " Release all external resources owned by the receiver.  
		Remove the receiver from the current ExternalObjectTable. "

	self hasExternalResources 
		ifTrue: [
			ExternalObjectTable current 
				removeObjectAt: self callinInterfaceIndex;
				removeObjectAt: self callinDescriptorIndex. 
			self externalMemoryAddress free ].
	self resetResources.!  
OleFlushClipboard
		" Empty the clipboard, removing the IDataObject instance.
		Raise an exception if an error occurs.  Answer the result code. "

	" WINOLEAPI  OleFlushClipboard(void); "

    <api: OleFlushClipboard hresult>
    ^self apiCallFailed! 
vtable: aVTable
		" Private - set the VTable shared by all instances of the receiver to <aVTable>. "

	vtable notNil
		ifTrue: [ vtable release ].
	vtable := aVTable.!  
forIID: anIID
		" Answer a new instance of the receiver for the interface specified by <anIID>. "

	| aClass |
	aClass := self elementTypeOfIID: anIID.
	aClass isNil  " element type not registered "
		ifTrue: [ self error: 'unsupported enumeration interface' ].
	^self forIID: anIID 
		binding: nil
		elementClass: aClass!   
parseDisplayName: aBindContext 
	monikerToLeft: monikerToLeft 
	displayName: displayName
		" Parse the display name <displayName> into a moniker 
		for the object that it refers to.  Answer the interface pointer. "

	| resultReference nCharsConsumedReference |
	resultReference := self class new asValueReference.
	nCharsConsumedReference := nil asValueReference.
	interface ParseDisplayName: aBindContext 
		_: monikerToLeft 
		_: displayName 
		_: nCharsConsumedReference 
		_: resultReference.
	^resultReference value!   
logFunctionEntry
        " Private - log function invocation to debug trace log. "

    | stack |
    stack := Process copyStack.
    self
        logHeader: stack;
        logArguments: stack.! 
MonikerCommonPrefixWith: aMoniker _: anotherMoniker _: resultReference
		" Create a moniker specifying common prefix between <aMoniker>
		and <anotherMoniker> and store its IMoniker into the <resultReference>.
		Used in the implementation of a moniker class.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeMonikerCommonPrefixWith: aMoniker asParameter
		_: anotherMoniker asParameter
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult
!   
logIndent
		" Private - answer the standard indent for log subitems. "

	^'    '!  
invokeRelease
		"Private - invoke the IUnknown::Release function for an external caller. "

	" ULONG Release( void); "

	| remainingReferenceCount |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	remainingReferenceCount := self Release.
	self ifOLETraceEnabled: [
		self logReturnValue: 'Ref count: ', remainingReferenceCount printString ].
	^remainingReferenceCount 

!  
classFactoryRegistry
		" Private - answer the registry of class factories which have been registered
		with OLE during the current session. "

	ClassFactoryRegistry isNil
		ifTrue: [ ClassFactoryRegistry := self constructClassFactoryRegistry ].
	^ClassFactoryRegistry!
invokeStgSetTimes: lpszName _: pctime _: patime _: pmtime
		"Private - WINOLEAPI StgSetTimes(
                   OLECHAR const FAR* lpszName,
                   FILETIME const FAR* pctime,
                   FILETIME const FAR* patime,
                   FILETIME const FAR* pmtime);"

    <api: StgSetTimes structIn structIn structIn structIn hresult>
    ^self apiCallFailed! 
activeObjects
		" Answer all the objects created by the receiver
		which are still in use by clients. "

	^self class activeObjects select: [ :anOleObject |
		anOleObject class = self objectClass ]!   
CLSIDFromProgID: aString _: resultReference
		" Obtain the CLSID associated with the ProgId in <aString>
		and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeCLSIDFromProgID: ( self asUnicodeParameter: aString )
		_: resultValue.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult

! 
invokeOleQueryCreateFromData: pDataObject
        "Private - WINOLEAPI  OleQueryCreateFromData(LPDATAOBJECT pSrcDataObject);"

    <api: OleQueryCreateFromData handle hresult>
	^self apiCallFailed! 
subclassForIID: anIID
		" Private - answer the OLEInterfaceImplementation class which supports the
		interface identified by the GUID <anIID>. "

	^OLEInterfaceImplementation allSubclasses
		detect: [ :aClass | aClass supportsIID: anIID ]
		ifNone: [ nil ]
! 
addressAtOffset: anInteger
        "Answer the bytes starting at anInteger (0 based offset)
        as anExternalAddress.  Answer nil if there is no address. "

    | anAddress |
	anAddress := super addressAtOffset: anInteger.
	^anAddress isValid
		ifTrue: [ anAddress ]
		ifFalse: [ nil ]!
globalMemoryAddressFromHandleResult: ulongHGlobal 
		" Private - transform an HGLOBAL FAR* return value into a global memory address. "

	| addressPtr aGlobalMemoryAddress |
    ( addressPtr :=  KernelLibrary globalLock: ulongHGlobal ) = 0
        ifTrue: [ ^OLEError signal: 'unable to recreate memory address' ].
    aGlobalMemoryAddress := ExternalGlobalAddress fromInteger: addressPtr.
    aGlobalMemoryAddress 
		memoryHandleObject: ( ExternalGlobalHandle fromInteger: ulongHGlobal );
		memorySize: ( KernelLibrary globalSize: ulongHGlobal ).
    aGlobalMemoryAddress doesNotNeedFinalization.
    KernelLibrary globalUnlock: ulongHGlobal.
	^aGlobalMemoryAddress!   
bindToStorage: aBindContext monikerToLeft: monikerToLeft iid: iid
		" Obtain access to the persistent storage of the object referenced by this moniker.
		Answer the interface identified by <iid> on the referenced object's storage. "

	| resultReference |
	resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
	interface BindToStorage: aBindContext _: monikerToLeft _: iid _: resultReference.
	^resultReference value!  
invokeMonikerCommonPrefixWith: pmkThis _: pmkDest _: ppmkCommon
        "Private - WINOLEAPI  MonikerCommonPrefixWith(
                LPMONIKER pmkThis, LPMONIKER pmkOther,
                LPMONIKER FAR* ppmkCommon) "

	| hresult |
    <api: MonikerCommonPrefixWith handle handle structOut hresult>
	hresult := self apiFailureReason.
	hresult = MK_E_NOPREFIX 
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!   
invokeCoFileTimeNow: lpFileTime
        "Private - WINOLEAPI  CoFileTimeNow( FILETIME FAR* lpFileTime ); "

    <api: CoFileTimeNow structOut hresult>
    ^self apiCallFailed!   
invokeQueryInterface: riid _: ppvObject
		" Private - invoke the IUnknown::QueryInterface function. "

	" HRESULT QueryInterface(
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObject); "

	| hresult |
	<ole: 0 structIn structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = E_NOINTERFACE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!
revokeRegistration
		" Revoke the registration of the receiver with OLE as a class factory object. "

	self class revokeClassFactory: self.!   
closeAllContainerWindows
		" Private - close all open container windows in the image.
		Answer whether successful; answer false if any 
		container windows were unable or unwilling to close. "

	| containerWindows |
	containerWindows := self containerWindows.
	containerWindows isEmpty
		ifTrue: [ ^true ].
	containerWindows do: [ :w | w close ].
	^self containerWindows isEmpty! 
asInterfacePointer
        " Answer an interface pointer for the receiver's VTable in external memory. "

    ^self!   
vtable
		"Private - answer the VTable shared by all instances of the receiver."

	^vtable
!   
newNullValue
		"Private - answer a new instance of the receiver with uninitialized contents. "

	^super new: self sizeInBytes! 
invokeCoDosDateTimeToFileTime: nDosDate _: nDosTime _: lpFileTime
        "Private - WINOLEAPI_(BOOL) CoDosDateTimeToFileTime(
                       WORD nDosDate, WORD nDosTime, FILETIME FAR* lpFileTime); "

    <api: CoDosDateTimeToFileTime ushort ushort structOut boolean>
    ^self apiCallFailed!
registerIID
        " Private - register the receiver as the interface pointer binding class for its IID. "

    self registerIID: self iid forClass: self.!   
= anObject
		" Answer whether the receiver and <anObject> represent the same interface. "

	^anObject isOLEInterface 
		and: [ self iid = anObject iid
		and: [ anObject interfaceBinding interfaceEqual: self ] ]!  
invokeCLSIDFromProgID: aUnicodeString _: guidByteArray
        "Private - WINOLEAPI CLSIDFromProgID (LPCOLESTR lpszProgID, LPCLSID lpclsid);"

	| hresult |
	<api: CLSIDFromProgID structIn structOut hresult>
	hresult := self apiFailureReason.
	hresult = CO_E_CLASSSTRING
		ifTrue: [ ^hresult ].
    ^self apiCallFailed!
memoryAddress
		" Answer the global memory address of the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current GetHGlobalFromILockBytes: self lockBytes
		_: resultReference.
	^resultReference value!  
releaseLockBytes
		" Private - release the receiver's byte array. "

	| interfaceToRelease |
	interfaceToRelease := self lockBytes.
	interfaceToRelease notNil
		ifTrue: [
			self lockBytes: nil.
			interfaceToRelease release ].!  
lockBytes
		" Private - answer the ILockBytes on which the receiver is defined. "

	^iLockBytes!   
lockBytes: anILockBytes
		" Private - specify the ILockBytes on which the receiver is defined. "

	iLockBytes := anILockBytes.!
release
		" Release the receiver. "

	super release.
	self releaseLockBytes.! 
nullValue: aGuid
		" Private - set the NULL Guid. "

	nullValue := aGuid.! 
session
        "Answer the receiver's drag drop session."
    ^session
!  
availableFormats
        "Answer an ordered collection of strings identifying
        the formats available in the receiver."
    ^self formats keys!  
hasFormat: typeNameString
        "Answer whether the receiver can provide data
        in the given format."
    ^self formats includesKey: typeNameString

!   
format: formatTypeString data: formatData
        "Set the data for the given format to formatData."
    self formats at: formatTypeString put: formatData
!   
format: formatTypeString ifAbsent: aBlock
        "Answer data of the given format, or answer
        the result of evaluating aBlock if no such format
        is available."
    | data |
    data := self formats at: formatTypeString ifAbsent: aBlock.
    data isNil ifTrue: [ ^nil ].
    ^data class == IDataObject 
        ifTrue: [ data renderFormat: formatTypeString ]
        ifFalse: [ data ]!  
format: formatTypeString
        "Answer data in the specified format, or signal
        an error if no such format is available."
    | data |
    data := self formats at: formatTypeString.
    data isNil ifTrue: [^ nil ].
    ^data class == IDataObject 
        ifTrue: [ data renderFormat: formatTypeString ]
        ifFalse: [ data ]
!  
formats: aDictionary
        "Private - set the Dictionary of formats and data to aDictionary."
    formats := aDictionary
!   
initialize
        "Private - initialize the receiver."
    self formats: Dictionary new.

!  
formats
        "Private - answer the Dictionary of formats & data."
    ^formats!  
session: aDragDropSession
        "Private - set the receiver's containing
        drag drop session."
    session := aDragDropSession

!
removeIID
        " Private - remove the registration of the receiver as the interface class for its IID.
		IEnum actually registers a family of interface ID's.  The IEnum
		class doesn't have an IID of its own, since it represents a
		family of enumerator interfaces, each with its own IID,
		differentiated only by the type of element being enumerated. "

	super removeIID.
	self elementTypeMap keysDo: [ :anIID |
		self removeIID: anIID ].
!
menuHandleFromHandle: ulongHandle
		" Private - answer a menu handle for the #handle callin argument <ulongHandle>. "

    ulongHandle = 0
		ifTrue: [ ^nil ].
	^WindowHandle fromInteger: ulongHandle!  
invokeCoBuildVersion
        "Private - WINOLEAPI_(DWORD) CoBuildVersion( VOID );"

    <api: CoBuildVersion ulongReturn>
    ^self apiCallFailed!
contents
		" Answer the elements in the enumeration. "

	| elements anElement |
	"??self reset??"
	elements := OrderedCollection new.
	[ ( anElement := self next ) notNil ]
		whileTrue: [ elements add: anElement ].
	^elements!
CreateFileMoniker: aPathName _: resultReference
		" Create a file moniker from <aPathName>, which can be relative or absolute.
		Obtain a new IMoniker interface and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeCreateFileMoniker: ( self asUnicodeParameter: aPathName )
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult
!
subclassForIID: anIID
		" Private - answer the OLEInterface class which supports the
		interface identified by the GUID <anIID>. "

	^OLEInterface allSubclasses
		detect: [ :aClass | aClass supportsIID: anIID ]
		ifNone: [ nil ]!   
invokeOleCreateLink: pmkLinkSrc _: riid _: renderopt _: pFormatEtc _: pClientSite _: pStg _: ppvObj
        "Private - WINOLEAPI  OleCreateLink(
            LPMONIKER pmkLinkSrc, REFIID riid,
            DWORD renderopt, LPFORMATETC lpFormatEtc,
            LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID FAR* ppvObj);"

    <api: OleCreateLink handle structIn ulong structIn handle handle structOut hresult>
    ^self apiCallFailed! 
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream."

    | address |
    aStream nextPutAll: self class name, '{'.
	address := ( self isValid
		ifTrue: [ self asInteger printPaddedWith: $0 to: 8 base: 16 ]
		ifFalse: [ 'invalid' ] ).
    aStream nextPutAll: address.
    aStream nextPut: $}! 
ownedInterfacesRegistry: aRegistry
		" Private - set the registry containing OLE interfaces owned
		by clients in the current session. "

	| resources |
	( OwnedInterfacesRegistry notNil
	and: [ ( resources := self allOwnedInterfaces ) notEmpty ] )
		ifTrue: [ 
			self transferResources: resources 
				to: aRegistry 
				type: 'owned interfaces'.
			OwnedInterfacesRegistry action: nil.  " ignore the old collection "
			].
	OwnedInterfacesRegistry := aRegistry.!
isFileMoniker
		" Answer whether the receiver is a file moniker "

	^self systemMonikerType = MKSYS_FILEMONIKER!   
asDosDateTime
		" Answer the receiver as a DOS date/time pair. "

	| resultReferenceDosDate resultReferenceDosTime |
	resultReferenceDosDate := nil asValueReference.
	resultReferenceDosTime := nil asValueReference.
	( OLEDLL current CoFileTimeToDosDateTime: self 
		_: resultReferenceDosDate 
		_: resultReferenceDosTime )
			ifFalse: [ ^nil ].
	^Array with: resultReferenceDosDate value with: resultReferenceDosTime value! 
asTimeStamp
		" Answer the receiver as a TimeStamp. "

	^( WinFileTime fromBytes: self contents ) asTimeStamp! 
releaseIfNotInUse: aBoolean
		" Specifiy whether the receiver should be released as soon as it is
		no longer in use (is not locked and all objects which it has created
		terminated).  Setting this true causes multi-factory applications
		to release class factory resources as soon as possible, rather
		than releasing all registered class factories only when the object
		server application exits. "

	releaseIfNotInUse := aBoolean.!
getDataHere: aFormatEtc storageMedium: aStgMedium
		" Retrieve data in the format specified by <aFormatEtc>.
		The caller allocates the storage medium <aStgMedium>. "

	interface GetDataHere: aFormatEtc _: aStgMedium.!
canCreateLinkedObject
		" Answer whether a linked object can be created from the receiver. "

	^( OLEDLL current OleQueryLinkFromData: self ) = S_OK!  
getData: aFormatEtc
        " Retrieve data in the format specified by <aFormatEtc>.
        Answer the storage medium which the data object allocated
        and filled in.  The caller is responsible for releasing the storage. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetData: aFormatEtc _: resultReference.
    ^resultReference value! 
registerAdviseSink: anAdviseSink format: aFormatEtc adviseFlags: advFlags
		" Register a data advise sink on the data object.
		Answer the token which identifies the connection (nil if not established). "

	| resultReference |
	resultReference := nil asValueReference.
	interface DAdvise: aFormatEtc _: advFlags _: anAdviseSink _: resultReference.
	^resultReference value!   
dataAdviseConnectionsEnumerator
		" Answer an enumerator on the collection of STATDATA structures which describe
		the data advise connections currently established on the data object. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumSTATDATA ) asValueReference.
	interface EnumDAdvise: resultReference.
	^resultReference value!   
copyToClipboard
		" Copy the receiver to the system clipboard. "

    OLEDLL current OleSetClipboard: self.!   
setData: aFormatEtc storageMedium: aStgMedium release: fRelease
        " Set the receiver's data in the format specified by <aFormatEtc>.
        from the storage medium <aStgMedium>.
        The receiver must release the storage if <fRelease> is true;
        otherwise the caller retains ownership of the storage. "

    ^interface SetData: aFormatEtc _: aStgMedium _: fRelease!   
hasGetDataFormat: aFormatEtc
		" Answer whether a call to IDataObject::GetData would succeed
		if it were passed <aFormatEtc> as the requested data format. "

	^( interface QueryGetData: aFormatEtc ) = S_OK!   
unregisterAdviseSink: connectionToken
		" Delete a data advise connection between the data transfer object
		and an advisory sink, identified by the <connectionToken> returned
		when the connection was established through IDataObject::DAdvise. "

	interface DUnadvise: connectionToken.!   
getCanonicalFormatEtc: aFormatEtc
		" Answer the canonical FORMATETC which will be supplied for <aFormatEtc>. "

	| resultReference hresult |
	resultReference := nil asValueReference.
	hresult := interface GetCanonicalFormatEtc: aFormatEtc
		_: resultReference.
	hresult = S_OK   " DATA_S_SAMEFORMATETC "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^resultReference!   
getDataFormatsEnumerator
        " Answer an enumerator that can be used to enumerate the formats 
		that can be used to obtain data with IDataObject::GetData. "

    | resultReference |
    resultReference := ( IEnum forIID: IID_IEnumFORMATETC ) asValueReference.
    interface EnumFormatEtc: DATADIR_GET _: resultReference.
    ^resultReference value!  
dataAdviseConnections
		" Answer a collection of STATDATA structures which describe
		the data advise connections currently established on the data object. "

	| anEnumerator contents |
	anEnumerator := self dataAdviseConnectionsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!   
embeddedObjectType
		" Answer a description of the type of embedded object
		which can be created from the receiver ('static' or 'embedded').
		Answer nil if an embedded object cannot be created. "

	| hresult |
	hresult := OLEDLL current OleQueryCreateFromData: self.
	hresult = S_OK
		ifTrue: [ ^'embedded' ].
	hresult = OLE_S_STATIC
		ifTrue: [ 'static' ].
	^nil   " S_FALSE "!   
setDataFormatsEnumerator
        " Answer an enumerator that can be used to enumerate the formats 
		that can be used to store data with IDataObject::SetData. "

    | resultReference |
    resultReference := ( IEnum forIID: IID_IEnumFORMATETC ) asValueReference.
    interface EnumFormatEtc: DATADIR_SET _: resultReference.
    ^resultReference value!   
renderFormat: formatTypeString
        "Render the data obtained from the receiver for the specfied format."

    | formatEtc stgMedium data address hGlobal metafilePict header
      objectFiler stream size localImpl |

    ( ( formatTypeString equalsIgnoreCase: 'Embedded Object' )
        or: [ formatTypeString equalsIgnoreCase: 'Embed Source' ] )
            ifTrue: [ ^self ].    "can't render an embedded object, just answer IDataObject"

    formatEtc := ( OLEStructure classForStructureNamed: #FORMATETC )
        formatNamed: formatTypeString.
    [ self hasGetDataFormat: formatEtc ] on: OLEError do: [ ^nil ].
    ( localImpl := self localImplementor ) notNil
        ifTrue: [   " render a Smalltalk object for local interfaces "
            ^( localImpl renderingForFormat: formatEtc ) object ].

    stgMedium := self getData: formatEtc.
    stgMedium isNil ifTrue: [ ^nil ].
    ( ( formatTypeString equalsIgnoreCase: 'String' ) or: [
        formatTypeString equalsIgnoreCase: 'FileName' ] )
            ifTrue: [
                hGlobal := ExternalHandle fromInteger: stgMedium hGlobal.
                    ( address := KernelLibrary globalLock: hGlobal ) = 0 ifTrue: [ ^self osError ].
                    address := ExternalGlobalAddress fromInteger: address.
                    data := String fromAddress: address.
                    KernelLibrary globalUnlock: hGlobal.
                    address release ].

    ( formatTypeString equalsIgnoreCase: 'Bitmap') ifTrue: [
        data := Bitmap fromHandle: stgMedium hGlobal ].

    ( formatTypeString equalsIgnoreCase: 'Metafile' ) ifTrue: [
        "hGlobal contains a pointer to METAFILEPICT struct which
         has the metafile handle."
        hGlobal := ExternalHandle fromInteger: stgMedium hGlobal.
        ( address := KernelLibrary globalLock: hGlobal ) = 0
            ifTrue: [ ^self osError ].
        address := ExternalGlobalAddress fromInteger: address.
        metafilePict := WinMetafilepict fromAddress: address .
        data := StoredPicture new.
        data handle: metafilePict hMF.
        header := WinMetafileheader new.
        ( metafilePict xExt = 0 or: [ metafilePict yExt = 0 ] )
            ifTrue: [ header bbox: ( 0@0 extent: Display boundingBox extent * 1000 ) ]
            ifFalse: [ header bbox: ( 0@0 extent: metafilePict xExt @ metafilePict yExt ) ].
        header inch: 1000.
        data apmHeader: header.
        KernelLibrary globalUnlock: hGlobal.
        address release ].

    data isNil ifTrue: [    "Smalltalk object format" 
        objectFiler := ServiceRegistry globalRegistry serviceNamed: #ObjectFiler
            ifNone: [ self error: 'ObjectFiler not installed' ].
        hGlobal := ExternalHandle fromInteger: stgMedium hGlobal.
        ( address := KernelLibrary globalLock: hGlobal ) = 0 ifTrue: [ ^self osError ].
        address := ExternalGlobalAddress fromInteger: address.
        address doesNotNeedFinalization.
        address memoryHandleObject: hGlobal.
        address memorySize: ( size := KernelLibrary globalSize: hGlobal ).
        size = 0 ifTrue: [ ^self error: 'invalid global memory' ].
        stream := MemoryReadWriteStream characterStreamOn: address.
        stream nextULong.    "skip size field"
        data := objectFiler loadFrom: stream.
        KernelLibrary globalUnlock: hGlobal.
        stream release.
        stream := nil ].

    stgMedium release.
    ^data
!  
canCreateEmbeddedObject
		" Answer whether an embedded (possibly static) object 
		can be created from the receiver. "

	| hresult |
	hresult := OLEDLL current OleQueryCreateFromData: self.
	^hresult = S_OK or: [ hresult = OLE_S_STATIC ]!  
getDataFormats
		" Answer the data formats which can be obtained from the receiver. "

	| anEnumerator contents |
	anEnumerator := self getDataFormatsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!   
isClipboardObject
		" Answer whether the receiver is the on the system clipboard. "

	^( OLEDLL current OleIsCurrentClipboard: self ) = S_OK!  
setDataFormats
		" Answer the data formats which can be sent to the receiver. "

	| anEnumerator contents |
	anEnumerator := self setDataFormatsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents! 
allResourceRegistries
		" Private - answer a collection containing all the OLE resource registries. "

	^Array 
		with: self ownedInterfacesRegistry
		with: self allocatedInterfacesRegistry 
		with: self ownedMemoryRegistry!
asInterfaceReference
		" Answer a civilized interface reference on the receiver. "

	^( OLEInterface classForIID: self iid ) forBinding: self! 
iidMap
		" Private - answer the dictionary which maps IID's to interface classes. "

	^IIDMap! 
classForIID: anIID
		" Answer the interface pointer which represents the interface
		specified by the interface ID GUID <anIID>.  Answer nil if the
		interface is not supported. "

	^self classForIID: anIID ifNone: [ nil ]!  
clsidFromString: aString
		"Answer a new instance of the receiver that is the CLSID 
		corresponding to the display string <aString>. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEDLL current CLSIDFromString: aString
		_: resultReference.
	^resultReference value
! 
exception
	"Private - Answer an exception describing the api error."

	| method process arguments |
	process := Process copyStack.
	method := process methodAt: 2.
	arguments := (1 to: method apiArgumentCount) collect: [ :index |
        process argAt: 2 number: index].
	^self exceptionForMethod: method arguments: arguments! 
dispatchFailureReason
		" Private - answer a value indicating why the last API call 
		made from the receiver process failed. "

	^CurrentProcess apiFailureReason!   
GetTimeOfLastChange: aBindContext _:  monikerToLeft _: resultReference
		" Invoke the IMoniker::GetTimeOfLastChange function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := OLEStructure forReturnValue: #FILETIME.
    hresult := self invokeGetTimeOfLastChange: aBindContext asParameter
		_:  monikerToLeft asParameter
		_: resultValue.
	resultReference value: resultValue asTimeStamp.
	^hresult!
invokeBindToObject: pbc _: pmkToLeft _: riidResult _: ppvResult
		" Private - invoke the IMoniker::BindToObject function. "

	" HRESULT BindToObject(
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [in] */ REFIID riidResult,
            /* [out] */ void **ppvResult); "

    <ole: 8 handle handle structIn structOut hresult>
    ^self vtableDispatchFailed!   
invokeGetDisplayName: pbc _: pmkToLeft _: ppszDisplayName
		" Private - invoke the IMoniker::GetDisplayName function. "

	" HRESULT GetDisplayName(
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [out] */ LPOLESTR *ppszDisplayName); "

    <ole: 20 handle handle structOut hresult>
    ^self vtableDispatchFailed!   
invokeCommonPrefixWith: pmkOther _: ppmkPrefix
		" Private - invoke the IMoniker::CommonPrefixWith function. "

	" HRESULT CommonPrefixWith(
            /* [unique][in] */ IMoniker *pmkOther,
            /* [out] */ IMoniker **ppmkPrefix); "

	| hresult |
    <ole: 18 handle structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = MK_E_NOPREFIX 
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!  
GetDisplayName: aBindContext _: monikerToLeft _: resultReference
		" Invoke the IMoniker::GetDisplayName function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := self createStringResultValue.
    hresult := self invokeGetDisplayName: aBindContext asParameter
		_: monikerToLeft asParameter
		_: resultValue.
    resultReference value: ( self stringFromResultValue: resultValue ).
    ^hresult!  
IsEqual: aMoniker
		" Invoke the IMoniker::RelativePathTo function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeIsEqual: aMoniker asParameter!  
invokeIsEqual: pmkOtherMoniker
		" Private - invoke the IMoniker::IsEqual function. "

	" HRESULT IsEqual(
            /* [unique][in] */ IMoniker *pmkOtherMoniker); "

    <ole: 13 handle hresult>
    ^self vtableDispatchFailed!  
ComposeWith: monikerToRight _: fOnlyIfNotGeneric _: resultReference
		" Invoke the IMoniker::ComposeWith function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := self class new forReturnValue.
    hresult := self invokeComposeWith: monikerToRight asParameter
		_: fOnlyIfNotGeneric 
		_: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult! 
invokeIsSystemMoniker: pdwMksys
		" Private - invoke the IMoniker::IsSystemMoniker function. "

	" HRESULT IsSystemMoniker(
            /* [out] */ DWORD *pdwMksys); "

    <ole: 22 structOut hresult>
    ^self vtableDispatchFailed!   
invokeComposeWith: pmkRight _: fOnlyIfNotGeneric _: ppmkComposite
		" Private - invoke the IMoniker::ComposeWith function. "

	" HRESULT ComposeWith(
            /* [unique][in] */ IMoniker *pmkRight,
            /* [in] */ BOOL fOnlyIfNotGeneric,
            /* [out] */ IMoniker **ppmkComposite); "

    <ole: 11 handle boolean structOut hresult>
    ^self vtableDispatchFailed! 
Enum: fForward _: resultReference
		" Invoke the IMoniker::Enum function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumMoniker.
	hresult := self invokeEnum: fForward
		_: resultValue asParameter.
	resultValue isValid   " can be NULL if there is nothing to enumerate "
		ifTrue: [ resultReference value: resultValue ].
    ^hresult!   
Reduce: aBindContext _: dwReduceHowFar _: monikerToLeft _: resultReference
		" Invoke the IMoniker::Reduce function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := self class new forReturnValue.
    hresult := self invokeReduce: aBindContext asParameter
		_: dwReduceHowFar
		_: monikerToLeft asParameter
		_: resultValue asParameter.
	resultValue isValid  " returns NULL if reduced to nothing "
		ifTrue: [ resultReference value: resultValue ].
    ^hresult!  
invokeInverse: ppmk
		" Private - invoke the IMoniker::Inverse function. "

	" HRESULT Inverse(
            /* [out] */ IMoniker **ppmk); "

	| hresult |
    <ole: 17 structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = MK_E_NOINVERSE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!
IsSystemMoniker: resultReference
		" Invoke the IMoniker::IsSystemMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeIsSystemMoniker: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult! 
invokeEnum: fForward _: ppenumMoniker
		" Private - invoke the IMoniker::Enum function. "

	" HRESULT Enum(
            /* [in] */ BOOL fForward,
            /* [out] */ IEnumMoniker **ppenumMoniker); "

    <ole: 12 boolean structOut hresult>
    ^self vtableDispatchFailed!   
IsRunning: aBindContext _:  monikerToLeft _: monikerNewlyRunning
		" Invoke the IMoniker::IsRunning function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeIsRunning: aBindContext asParameter
		_:  monikerToLeft asParameter
		_: monikerNewlyRunning asParameter!   
invokeReduce: pbc _: dwReduceHowFar _: ppmkToLeft _: ppmkReduced
    "Private - invoke the IMoniker::Reduce function
        HRESULT Reduce(
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ DWORD dwReduceHowFar,
            /* [unique][out][in] */ IMoniker **ppmkToLeft,
            /* [out] */ IMoniker **ppmkReduced);"

    <ole: 10 handle ulong struct structOut hresult>
	^self vtableDispatchFailed!   
invokeHash: pdwHash
		" Private - invoke the IMoniker::Hash function. "

	" HRESULT Hash(
            /* [out] */ DWORD *pdwHash); "

    <ole: 14 structOut hresult>
    ^self vtableDispatchFailed!  
invokeBindToStorage: pbc _: pmkToLeft _: riid _: ppvObj
		" Private - invoke the IMoniker::BindToStorage function. "

	" HRESULT BindToStorage(
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObj); "

    <ole: 9 handle handle structIn structOut hresult>
    ^self vtableDispatchFailed!  
ParseDisplayName: aBindContext 
	_: monikerToLeft 
	_: displayName 
	_: nCharsConsumedReference 
	_: resultReference
		" Invoke the IMoniker::ParseDisplayName function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue nCharsConsumedValue hresult |
	resultValue := self class new forReturnValue.
	nCharsConsumedValue := ExternalLong new.
	hresult := self invokeParseDisplayName: aBindContext asParameter
		_: monikerToLeft asParameter
		_: ( self asUnicodeParameter: displayName )
		_: nCharsConsumedValue
		_: resultValue asParameter.
	resultReference value: resultValue.
	nCharsConsumedReference value: nCharsConsumedValue asUnsignedInteger.
	^hresult!
invokeRelativePathTo: pmkOther _: ppmkRelPath
		" Private - invoke the IMoniker::RelativePathTo function. "

	" HRESULT RelativePathTo(
            /* [unique][in] */ IMoniker *pmkOther,
            /* [out] */ IMoniker **ppmkRelPath); "

    <ole: 19 handle structOut hresult>
    ^self vtableDispatchFailed! 
Inverse: resultReference
		" Invoke the IMoniker::Inverse function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := self class new forReturnValue.
	hresult := self invokeInverse: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
    ^hresult! 
invokeIsRunning: pbc _:  pmkToLeft _: pmkNewlyRunning
		" Private - invoke the IMoniker::IsRunning function. "

	" HRESULT IsRunning(
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [unique][in] */ IMoniker *pmkNewlyRunning); "

    <ole: 15 handle handle handle hresult>
    ^self vtableDispatchFailed! 
invokeGetTimeOfLastChange: pbc _:  pmkToLeft _: pFileTime
		" Private - invoke the IMoniker::GetTimeOfLastChange function. "

	" HRESULT GetTimeOfLastChange(
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [out] */ FILETIME *pFileTime); "

    <ole: 16 handle handle structOut hresult>
    ^self vtableDispatchFailed!   
RelativePathTo: aMoniker _: resultReference
		" Invoke the IMoniker::RelativePathTo function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := self class new forReturnValue.
	hresult := self invokeRelativePathTo: aMoniker asParameter
		_: resultValue asParameter.
	resultReference value: resultValue.
    ^hresult!   
Hash: resultReference
		" Invoke the IMoniker::Hash function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeHash: resultValue.
	resultReference value: resultValue asUnsignedInteger.
    ^hresult!   
BindToObject: aBindContext _: monikerToLeft _: iid _: resultReference
		" Invoke the IMoniker::BindToObject function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeBindToObject: aBindContext asParameter
        _: monikerToLeft asParameter
        _: iid
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!   
invokeParseDisplayName: pbc _: pmkToLeft _: pszDisplayName _: pchEaten _: ppmkOut
		" Private - invoke the IMoniker::ParseDisplayName function. "

	" HRESULT ParseDisplayName(
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [in] */ LPOLESTR pszDisplayName,
            /* [out] */ ULONG *pchEaten,
            /* [out] */ IMoniker **ppmkOut); "

    <ole: 21 handle handle structIn structOut structOut hresult>
    ^self vtableDispatchFailed!
BindToStorage: aBindContext _: monikerToLeft _: iid _: resultReference
		" Invoke the IMoniker::BindToStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
    hresult := self invokeBindToStorage: aBindContext asParameter
        _: monikerToLeft asParameter
        _: iid
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!
CommonPrefixWith: aMoniker _: resultReference
		" Invoke the IMoniker::BindToStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := self class new forReturnValue.
    hresult := self invokeCommonPrefixWith: aMoniker asParameter
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
    ^hresult!   
= anObject
		" Answer whether the receiver and <anObject> represent the same interface. "

	^anObject isOLEInterface 
		and: [ self iid = anObject iid
		and: [   " let impl control comparison (allows optimization) "
			self isOLEInterfaceImplementation
				ifTrue: [ interface interfaceEqual: anObject interfaceBinding ]
				ifFalse: [ anObject interfaceBinding interfaceEqual: interface ]  ] ]!   
invokeOleLoad: pStg _: riid _: pClientSite _: ppvObj
        "Private - WINOLEAPI  OleLoad(
			LPSTORAGE pStg, REFIID riid, LPOLECLIENTSITE pClientSite,
			LPVOID FAR* ppvObj);"

    <api: OleLoad handle structIn handle structOut hresult>
    ^self apiCallFailed! 
logCallbackEntry
		" Private - log callback invocation to debug trace log. "

	| stack |
	stack := Process copyStack.
	self 
		logHeader: stack;
		logArguments: stack.
! 
constructFinalizationRegistry
		" Private - answer a new instance of a finalization registry. "

	^WeakRegistry new action: [ :object | object finalize ]! 
classForStructureNamed: structureName ifNone: aBlock
		" Answer the OLE structure definition class which represents the 
		host data structure named <structureName>.  
		Answer the result of evaluating <aBlock> if no class is available. "

	structureName isNil
		ifTrue: [ ^aBlock value ].
	^self structureNameMap at: structureName asSymbol ifAbsent: aBlock! 
destroyReference
		" Destroy this interface reference (without releasing it).
		This service is used to relinquish ownership of the interface. "

	interface isOLEInterfacePointer
		ifTrue: [ interface invalidate ].
	interface := nil.!  
systemMonikerType
		" Answer the type of the receiver if it is a type of moniker whose
		implementation semantics are conceptually important to the binding process. "

	| resultReference |
	resultReference := nil asValueReference.
	^( interface IsSystemMoniker: resultReference ) = S_OK
		ifTrue: [ resultReference value ]
		ifFalse: [ nil ]!
interfaceResultAtAddress: anExternalAddress put: anInterface
		" Private - store the interface output argument value <anInterface> 
		into the caller-provided memory location at <anExternalAddress>. 
		The callee is responsible for providing an interface which has
		been reference counted for return to a caller. "

	anInterface isNil ifTrue: [ ^self ].
	( ExternalBuffer atAddress: anExternalAddress ) 
		bytesAtOffset: 0 
		put: anInterface asParameter.
	anInterface destroyReference.  " ownership of this interface transfers to the caller "!   
removeSpecialSessionResource: aResource
		" Private - remove the registration of a special resource of the current session. "

	self specialSessionResources removeKey: aResource ifAbsent: [].!   
invokeSwitchToFile: pszFile
		" Private - invoke the IRootStorage::SwitchToFile function. "

	" HRESULT SwitchToFile(
            /* [string][in] */ LPOLESTR pszFile); "

    <ole: 3 structIn hresult>
    ^self vtableDispatchFailed!   
SwitchToFile: aPathName
		" Invoke the IRootStorage::SwitchToFile function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSwitchToFile: ( self asUnicodeParameter: aPathName )!   
CoGetClassObject: aCLSID
    _: dwClsContext
    _: pvReserved
    _: anIID
    _: resultReference
        "Obtain the interface specified by the GUID <anIID>
        for the class object specified by the GUID <aCLSID>.
        Store the interface reference into <resultReference>.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: anIID.
	hresult := self invokeCoGetClassObject: aCLSID
		_: dwClsContext
		_: pvReserved  "( self asUnicodeParameter: pszServer )"
		_: anIID
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!  
asInterfaceReference
		" Answer a civilized interface reference on the receiver. "

	^self!
writeAt: offset buffer: buffer count: count
		" Write <count> bytes from the client's <buffer> into the byte array
		starting at position <offset>.   Answer the number of bytes 
		actually written. "

	| resultReference |
	resultReference := nil asValueReference.
	interface WriteAt: offset 
		_: buffer 
		_: count 
		_: resultReference.
	^resultReference value!
statisticsWithoutName
		" Snswer the storage statistics about this storage element.
		Omit the storage name so that deallocation is not necessary. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Stat: resultReference _: STATFLAG_NONAME.
	"self ASSERT: ( resultReference value hasName not )."
	resultReference value doesNotNeedFinalization.
	^resultReference value!
lockRegion: offset count: count mode: lockType
		" Lock the <count> bytes in the byte array starting at position <offset> 
		using locking mode <lockType>. "

	^interface LockRegion: offset _: count _: lockType!   
statistics
		" Answer the storage statistics about this storage element.
		Include the storage name (which must be deallocated), if known. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Stat: resultReference _: STATFLAG_DEFAULT.
    resultReference value hasName
        "ifTrue: [ self ASSERT: resultReference value hasFinalization ]"
        ifFalse: [ resultReference value doesNotNeedFinalization ].
	^resultReference value!  
size
        "Answer the size of the receiver's byte array. "

    ^self statisticsWithoutName cbSize! 
flush
		" Ensure that any internal buffers maintained by the implementor
		are written out to the backing store. "

	interface Flush.!
readAt: offset buffer: buffer count: count
		" Read the <count> bytes from the byte array starting at position <offset>
		into the <buffer> provided by the caller.
		Answer the number of bytes actually read into the <resultReference>. "

	| resultReference |
	resultReference := nil asValueReference.
	interface ReadAt: offset
        _:  buffer 
		_: count 
		_: resultReference.
	^resultReference value!  
isStorageBytes
		" Answer whether the receiver's byte array contains an IStorage. "

	^( OLEDLL current StgIsStorageILockBytes: self ) = S_OK! 
unlockRegion: offset count: count mode: lockType
		" Unlock the <count> bytes in the byte array starting at position <offset> 
		that was previously locked in locking mode <lockType>. "

	^interface UnlockRegion: offset _: count _: lockType! 
setSize: newSize
		" Change the size of the byte array to <newSize>. "

	^interface SetSize: newSize!  
implementedFunctions
		" Answer the message selectors of the interface functions 
		for which the receiver's object has registered a handler. "

	^self dispatchSelectors reject: [ :selector | selector = #unimplementedFunction ]!  
logArguments: stack
        " Private - log the callback invocation arguments to the OLE trace log. "

    | method frameIndex nArgs anArg |
    method := stack methodAt: 1.
    method selector = #ifOLETraceEnabled:
        ifTrue: [ method := stack methodAt: 2 ].
    nArgs := method selector occurrencesOf: $:.
    frameIndex := stack findFrameIndexOf: method.
    1 to: nArgs do: [ :i |
        anArg := stack argAt: frameIndex number: i.
        self oleTRACE: '    ', "'arg', i printString, ': '," anArg printString ].!   
registerDragDrop
		" Register OLE drag/drop as the default system drag/drop type. "

	DragDropSession defaultClass: WinDragDropSession.
	( ( ServiceRegistry globalRegistry hasServiceNamed: #ObjectFiler ) not
	and: [ SessionModel current isRunTime not ] )
		ifTrue: [   " warn developer that they may have an incomplete configuration "
			MessageBox notify: 'Installation Note'
				withText: 'You must install the ObjectFiler if you want to use the object drag/drop format.' ].! 
iDropTarget
        "Private - answer the receiver's IDropTarget interface."

    ^self propertyAt: #iDropTarget ifAbsent: [ nil ]!
EnumRunning: resultReference
		" Invoke the IRunningObjectTable::EnumRunning function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumMoniker.
	hresult := self invokeEnumRunning: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
NoteChangeTime: registrationToken _: aTimeStamp
		" Invoke the IRunningObjectTable::NoteChangeTime function. 
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeGetObject: registrationToken
		_: ( self asFileTimeParameter: aTimeStamp )
!
invokeGetTimeOfLastChange: pmkObjectName _: pfiletime
		" Private - invoke the IRunningObjectTable::GetTimeOfLastChange function. "

	" HRESULT GetTimeOfLastChange(
            /* [unique][in] */ IMoniker *pmkObjectName,
            /* [out] */ FILETIME *pfiletime); "

	| hresult |
	<ole: 8 ulong structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = MK_E_UNAVAILABLE  " object is not registered as running "
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed! 
invokeRegister: grfFlags _: punkObject _: pmkObjectName _: pdwRegister
		" Private - invoke the IRunningObjectTable::Register function. "

	" HRESULT Register(
            /* [in] */ DWORD grfFlags,
            /* [unique][in] */ IUnknown *punkObject,
            /* [unique][in] */ IMoniker *pmkObjectName,
            /* [out] */ DWORD *pdwRegister); "

    <ole: 3 ulong handle handle structOut hresult>
    ^self vtableDispatchFailed!  
GetObject: anIMoniker _: resultReference
		" Invoke the IRunningObjectTable::GetObject function. 
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self invokeGetObject: anIMoniker asParameter
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult! 
invokeIsRunning: pmkObjectName
		" Private - invoke the IRunningObjectTable::IsRunning function. "

	" HRESULT IsRunning(
            /* [unique][in] */ IMoniker *pmkObjectName); "

    <ole: 5 handle hresult>
    ^self vtableDispatchFailed!  
invokeGetObject: pmkObjectName _: ppunkObject
		" Private - invoke the IRunningObjectTable::GetObject function. "

	" HRESULT GetObject(
            /* [unique][in] */ IMoniker *pmkObjectName,
            /* [out] */ IUnknown **ppunkObject); "

	| hresult |
    <ole: 6 handle structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = MK_E_UNAVAILABLE  " object is not registered as running "
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!  
invokeNoteChangeTime: dwRegister _: pfiletime
		" Private - invoke the IRunningObjectTable::NoteChangeTime function. "

	" HRESULT NoteChangeTime(
            /* [in] */ DWORD dwRegister,
            /* [in] */ FILETIME *pfiletime); "

    <ole: 7 ulong structIn hresult>
    ^self vtableDispatchFailed!   
invokeEnumRunning: ppenumMoniker
		" Private - invoke the IRunningObjectTable::EnumRunning function. "

	" HRESULT EnumRunning(
            /* [out] */ IEnumMoniker **ppenumMoniker); "

	<ole: 9 structOut hresult>
    ^self vtableDispatchFailed!  
Revoke: dwRegister
		" Invoke the IRunningObjectTable::Revoke function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Revoke(
            /* [in] */ DWORD dwRegister); "

    <ole: 4 ulong hresult>
    ^self vtableDispatchFailed!   
IsRunning: anIMoniker
		" Invoke the IRunningObjectTable::IsRunning function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeIsRunning: anIMoniker asParameter!
Register: grfFlags _: anIUnknown _: anIMoniker _: resultReference
		" Invoke the IRunningObjectTable::Register function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self 
		invokeRegister: grfFlags 
		_: anIUnknown asParameter 
		_: anIMoniker asParameter 
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!  
GetTimeOfLastChange: anIMoniker _: resultReference
		" Invoke the IRunningObjectTable::GetTimeOfLastChange function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEStructure forReturnValue: #FILETIME.
	hresult := self invokeGetTimeOfLastChange: anIMoniker asParameter
		_: resultValue.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue asTimeStamp ].
	^hresult!
allocate: anInteger addressType: anOLEAddressClass
		"Allocate from the receiver a block of memory of size <anInteger> bytes.  
		Answer the address of the allocated memory. 
		Raise an exception if the memory could not be allocated. "

	^interface alloc: anInteger addressType: anOLEAddressClass!
getSize: anOLEMemoryAddress
		"Answer the size in bytes of the memory block referenced 
		by <anOLEMemoryAddress>.  Raise an exception if an error occurs."

	^interface GetSize: anOLEMemoryAddress! 
didAlloc: anOLEMemoryAddress
		"Answer whether the receiver allocated the block of memory 
		pointed to by <anOLEMemoryAddress>."

	^( interface DidAlloc: anOLEMemoryAddress ) = 1!  
reallocate: anOLEMemoryAddress newSize: anInteger
		" Reallocate the block of memory referenced by <anOLEMemoryAddress> 
		to be of size <anInteger> bytes.   
		Move the block if necessary.  Free memory no longer used.  
		Answer the address of the allocated memory. 
		Raise an exception if the memory could not be reallocated. "

	^interface Realloc: anOLEMemoryAddress _: anInteger!  
free: anOLEMemoryAddress
		" Free the block of memory referenced by <anOLEMemoryAddress>. "

	interface Free: anOLEMemoryAddress.
	anOLEMemoryAddress invalidate.!
heapMinimize
		" Request the receiver to minimize/reorganize itself by releasing unused memory. "

	interface HeapMinimize.!   
addressClass
		" Private - answer the OLE address class used for memory allocated from the receiver. "

	self == self class taskMemoryAllocator
		ifTrue: [ ^OLEMemoryAddress ].
	self == self class sharedMemoryAllocator
		ifTrue: [ ^OLESharedMemoryAddress ].
	OLEError signal: 'unknown OLE memory allocator'!
allocate: anInteger
		"Allocate from the receiver a block of memory of size <anInteger> bytes.  
		Answer the address of the allocated memory. 
		Raise an exception if the memory could not be allocated. "

	^interface alloc: anInteger addressType: self addressClass!   
isOLEInterfaceBinding
		" Answer whether the receiver is an OLE interface binding
		which provides direct access to the raw interface functions
		of an OLE interface. "

	^true!
externalObjectBody
		" Private - answer a structure which references the receiver's
		interface data structures (ptr-ptr-VTable) in external memory. "

	^ExternalBuffer atAddress: self externalMemoryAddress!   
doesNotNeedFinalization
	"The receiver no longer needs to be sent the #finalize message when it is not referenced anymore."

	" this may not be necesssary, although it's certainly safe "
	OLESessionManager trackResources
		ifTrue: [ super doesNotNeedFinalization ].!   
sessionCommandLineArguments
		" Answer a collection containing the arguments from the
		command line which initiated the current session. "

	| commandLine |
	commandLine := SessionModel current getCommandLine.
	^commandLine copyFrom: 2 to: commandLine size  " strip the EXE name "!  
releaseIfNotInUse
		" Answer whether the receiver should be released as soon as it is
		no longer in use (is not locked and all objects which it has created
		terminated).  Setting this true causes multi-factory applications
		to release class factory resources as soon as possible, rather
		than releasing all registered class factories only when the object
		server application exits. "

	^releaseIfNotInUse!