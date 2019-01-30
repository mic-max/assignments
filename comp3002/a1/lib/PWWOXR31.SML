3.1.0.106
   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out. "

	^self copy
		siteObject: nil;
		yourself! 
isControlClassAvailable
		" Private - answer whether the receiver's control class is registered and
		its object server usable on the current system. "

	^self propertyAt: #isControlClassAvailable
		ifAbsentPut: [ 
			OLESessionManager isOLEAvailable
			and: [ OLERegistryInterface isClassRegistered: self clsid ] ].!  
warningNoControl: operationDescription
		" Private - display a warning  message to the user that the control is not available. "

	OLEWarning signal:
		'Unable to ', operationDescription, ' ', self partName,
		' - the  OLE control which it uses is not currently available.',
		'  You may have a problem with your system configuration or you may need to re-install or register the OLE control on your system.'.!  
buildWindow: parentWindow
        "Private - Create the window for the receiver."

	" need to reinitialize the site object when recreating control part after a delete. "
    self siteObject innerUnknown isNil
        ifTrue: [ 
			"self ASSERT: self siteObject referenceCount = 1."  " open does artificial ref count "
			self siteObject initialize.
			" need to redo the ref count in this case because re-initialization reset the ref count "
			self siteObject addRef.
			"self ASSERT: self siteObject referenceCount = 1."
			super clsid: self clsid ].

    self installSiteInContainer.
    ( super buildWindow: parentWindow ) isNil
        ifTrue: [ ^nil ].
    self loadControl.
!   
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ( ( self siteObject hasControlMethodSelector: aSelector )
	or: [ ( self siteObject hasControlPropertyGetSelector: aSelector )
	or: [ ( self siteObject hasControlPropertySetSelector: aSelector ) ] ] )
		ifTrue: [ ^PARTSAliasLink ].   " relay to contained value "
	^super partLinkClassFor: aSelector!   
partEventsOfControl
	" Private - answer the PARTS event interface of the control. "

	clsid isNil
		ifTrue: [ ^nil ].
	^PARTSInterfaceList new
		items: self controlEvents asSortedCollection
		separators: #( )
		defaultItem: nil!  
persistentStateIsStream
		" Private - answer whether the saved state of the control is an IStream. "

	^self controlState first = 'stream'!
partEvents
        " Answer the PARTS event interface of the receiver. "

	| standardInterface |
	standardInterface := PARTSInterfaceList emptyList.
	^self mergeInterfaceStandard: standardInterface
		control: self partEventsOfControl!  
mergeInterfaceStandard: standardInterface control: controlInterface
        " Private - answer the merged interface specification. "

    | nStandardItems defaultItem |
    controlInterface isNil
        ifTrue: [ ^standardInterface ].
    nStandardItems := standardInterface items size.
    defaultItem := standardInterface defaultItem.
    ( defaultItem isNil and: [ controlInterface items size > 0 ] )
        ifTrue: [ defaultItem := controlInterface items first ].
    ^PARTSInterfaceList new
        items: standardInterface items, controlInterface items
        separators: (
            standardInterface separators,
            ( Array with: nStandardItems ),
            ( controlInterface separators
                collect: [ :indexEl | indexEl + nStandardItems ] )
            )
        defaultItem: defaultItem
! 
installSiteInContainer
        " Private - ensure that a container object is attached to the receiver's window
        and register the receiver with it as a client site. "

    | containerWindow container |

    containerWindow := ( self partIsEditing
        ifTrue: [ self partEditor workbenchPane mainWindow ]
        ifFalse: [ self mainWindow ] ).

    ( container := containerWindow container ) isNil
        ifTrue: [   " construct container when first control added to app "
            container := OLEContainerObject new
                name: 'Container';
                yourself.
            containerWindow container: container.
            " artificially ref count the container for IPA while the window is open "
            container addRef.  " released when last site is closed "
            ].

    self siteObject name: container getNextSiteName.  " any old name is fine "
    container registerSite: self siteObject.
! 
loadControl
        " Private - load the control "

	( self clsid isNil or: [ self isControlClassAvailable not ] )
		ifTrue: [ ^self ].

	[ 
	self siteObject constructControl.
	] on: OLEError
		do: [ :ex |
			( self propertyAt: #isControlClassAvailable ) == true
				ifTrue: [
					MessageBox
						notify: 'OLE Control Problem' 
						withText: 'Unable to load the OLE control used by ', self partName,
							': ', self controlClassUserName, 
							' (', ex description, ').' ].
			self isControlClassAvailable: false.
			self siteObject controlCLSID: nil ].
!
close
        "Private - Close the receiver.  Disconnect from the container. "

    | myContainer |
    myContainer := self siteObject container.
    self siteObject clearContent.
	myContainer isNil
		ifTrue: [  " PARTS application closed by image exit shutdown processing "
			"self ASSERT: self partIsEditing not."
			^super close ].
    myContainer removeSite: self siteObject.
    myContainer sites size = 0
        ifTrue: [
            myContainer close.
            myContainer release ].  " decrement the artifical ref count "
    ^super close!   
deletePersistentState
		" Private - delete the persistent state of the control. "

	self controlState: nil.!   
clsid: aCLSID
		" Set the CLSID of the OLE control to which the receiver is connected to the GUID <aCLSID>. "

	clsid := aCLSID.
	super clsid: aCLSID.!   
persistentStateStream
		" Private - answer the saved state of the control for an IStream. "

	self controlState first = 'stream'
		ifFalse: [ self error: 'not a stream backing' ].
	^self controlState at: 2!   
partMessagesOfControl
	" Private - answer the PARTS message interface of the control. "

	| controlMethods nMethods controlGetProperties controlSetProperties |
	clsid isNil
		ifTrue: [ ^nil ].
	controlMethods := self controlMethodSelectors asSortedCollection.
	controlGetProperties := self controlPropertyGetSelectors asSortedCollection.
	controlSetProperties := self controlPropertySetSelectors asSortedCollection.
	nMethods := controlMethods size.
	^PARTSInterfaceList new
		items: (
			#( #editProperties ),
			controlMethods asArray, 
			controlGetProperties asArray, 
			controlSetProperties asArray )
		separators: ( Array with: 1 with: nMethods + 1 with: nMethods + 1 + controlGetProperties size )
		defaultItem: #editProperties! 
persistentStateIsStorage
		" Private - answer whether the saved state of the control is an IStorage. "

	^self controlState first = 'storage'! 
siteObjectClass
    "Private - answer the class which is used for the receiver's site. "

    ^OLEControlPartSiteObject!   
isControlClassAvailable: aBoolean
		" Private - specify whether the receiver's control class is registered and
		its object server usable on the current system. "

	self propertyAt: #isControlClassAvailable put: aBoolean.!
installPartRuntimeLibrary
        " Private - install the basic nonvisual parts runtime library.
        Load the workbench support library if appropriate. "

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'OLE Control Parts'.!
setPersistentStateStream: aByteArray
		" Private - set the saved state of the control to the contents <aByteArray>
		obtained from an IStream backing. "

	self controlState: ( Array with: 'stream' with: aByteArray ).! 
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for <aSelector>.  If <aSelector> isn't part of
        the control pane's own protocol, map it to the
        relay method which forwards it to the control. "

    ( ( self siteObject hasControlMethodSelector: aSelector )
	or: [ ( self siteObject hasControlPropertyGetSelector: aSelector )
	or: [ ( self siteObject hasControlPropertySetSelector: aSelector ) ] ] )
		ifTrue: [ ^#relayMessage:arguments: ].
	^super partRealSelectorFor: aSelector!   
hasPersistentState
		" Private - answer whether the receiver has saved a 
		persistent reprensentation of its state in a backing store. "

	^self controlState notNil!
partMessages
        " Answer the PARTS message interface of the receiver. "

	| standardInterface |
	standardInterface := PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            )
        separators: #( )
        defaultItem: #setFocus.
	^self mergeInterfaceStandard: standardInterface
		control: self partMessagesOfControl
!
controlState
		" Private - answer the saved state of the control. "

	^controlState!   
partMessages
	"Answer the PARTS message interface of the receiver."

	^PARTSInterfaceList new
			items: #( #value #value: )
			separators: #( )
			defaultItem: #value! 
warningNoOLE: operationDescription
		" Private - display a warning  message to the user that OLE is not available. "

	OLEWarning signal: 
		'Unable to ', operationDescription, ' ', self partName,
		' - OLE support is not available on this system.  There may be a problem with your system configuration.'.!   
isInEditMode
	"Answer true if the receiver is in edit mode."

	^self partIsEditing!
removePartRuntimeLibrary
        " Private - remove the basic application parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).! 
clsid
		" Answer the CLSID of the OLE control to which the receiver is connected. "

	^clsid!  
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

	" upgrade representation of saved state in VS 3.1 beta 2 applications "
	( controlState notNil and: [ controlState isByteArray ] )
		ifTrue: [ self setPersistentStateStream: controlState ].

	self createSiteObject.
	super clsid: self clsid.  " install the CLSID of the connected control "

    anObjectFiler clientContext isPARTSLoadContext
        ifTrue: [
            self isControlClassAvailable: nil.
            self clsid notNil
                ifTrue: [
                    OLESessionManager isOLEAvailable
                        ifTrue: [
                            self isControlClassAvailable  " force reinitialization "
                                ifFalse: [
                                    anObjectFiler recordWarningMessage:
                                        self partName, ' problem: ',
                                        'the OLE control is not registered on this system.',
                                        '  ( CLSID ', self controlClassUserName, ' )' ].
                                    ]
                        ifFalse: [
                            self isControlClassAvailable: false.
                            anObjectFiler recordWarningMessage:
                                self partName, ' problem: '
                                ,'OLE support is not available on this system.  There may be a problem with your system configuration.' ].
                    ].
            ].
    ^super fileInActivate: anObjectFiler! 
persistentStateStorage
		" Private - answer the saved state of the control for an IStorage. "

	self controlState first = 'storage'
		ifFalse: [ self error: 'not a storage backing' ].
	^self controlState at: 2!   
openStorageBackingStore
        " Private - Open the storage backing store for the receiver. "

	^OLEGlobalMemoryStorage on: self sitePane persistentStateStorage! 
initialize
	"Private - initialize the receiver."

	super initialize.
	self usesMemoryBackingStore: true.
!   
persistentStateIsStorage
		" Private - answer whether the persistent state of the receiver is an IStorage. "

	^self sitePane persistentStateIsStorage!
persistentStateIsStream
		" Private - answer whether the persistent state of the receiver is an IStream. "

	^self sitePane persistentStateIsStream!   
saveStateChanges
        " Private - save the state of the control if its properties have been modified.
        Answer whether there were changes. "

	| isModified newControlState nBytes nBytesRead |
	isModified := super saveStateChanges.
	"self ASSERT: self isStateModified not."  " state is committed to storage at this point "
	isModified
        ifFalse: [ ^false ].
	self storage isStream
		ifTrue: [ 
			"newControlState := self storage asByteStream contents."
			" following is workaround for problems encountered reading
				large contents directly from the OLE-implemented
				IStream on the global memory.  Seems to work
				properly when we use our own accessing logic. "
			newControlState := ( MemoryReadWriteStream on: self storage memoryAddress )
				contents.
			self sitePane setPersistentStateStream: newControlState ]
		ifFalse: [
			nBytes := self storage lockBytes size.
			newControlState := ByteArray new: nBytes.
			nBytesRead := self storage lockBytes readAt: 0
				buffer: newControlState
				count: nBytes.
			"self ASSERT: nBytesRead = nBytes."
			self sitePane setPersistentStateStorage: newControlState.
			].
    ^true!   
hasPersistentState
		" Private - answer whether the receiver has saved a 
		persistent reprensentation of its state in a backing store. "

    ^self sitePane hasPersistentState! 
openStreamBackingStore
        " Private - Open the stream backing store for the receiver. "

    ^OLEGlobalMemoryStream on: self sitePane persistentStateStream!  
loadCLSID
		" Private - load the CLSID of the saved control from its backing. "

	self controlCLSID: self sitePane clsid.
	!  
deletePersistentState
        " Private - delete the persistent state of the receiver object from the backing storage. "

    self hasPersistentState ifFalse: [ ^self ].
    self releaseStorage.
    self sitePane deletePersistentState.! 
saveCLSID
		" Private - save the CLSID of the control in its backing.
		Do nothing for the receiver (CLSID is managed by the part). "

	"self ASSERT: self controlCLSID = self sitePane clsid."!  
controlState: aValue
		" Private - set the saved state of the control. "

	controlState := aValue.!
setPersistentStateStorage: aByteArray
		" Private - set the saved state of the control to the contents <aByteArray>
		obtained from an IStorage backing. "

	self controlState: ( Array with: 'storage' with: aByteArray ).!  
controlClassUserName
        " Answer the registered name of the control class in the receiver.
        Answer nil if the receiver does not contain a control. "

	^OLESessionManager isOLEAvailable
		ifTrue: [ super controlClassUserName ]
		ifFalse: [ self clsid asHexDescriptionString ]! 
relayMessage: aSelector arguments: arguments
	" Private - relay the message <aSelector> to the control
        with the given arguments (an array of values). "

	| aPropertyName |
	self siteObject isEmpty
		ifTrue: [
			OLEWarning signal: 'OLE control for ', self partName, 
				' not available; cannot evaluate message #', aSelector, '.'.
			^nil ].
	( self siteObject hasControlMethodSelector: aSelector )
		ifTrue: [
			^self siteObject invokeMethod: aSelector
                withArguments: arguments ].
	( aPropertyName := self siteObject propertyNameFromGetSelector: aSelector ) notNil
		ifTrue: [
			^self siteObject getProperty: aPropertyName 
				withArguments: arguments ].
	( aPropertyName := self siteObject propertyNameFromSetSelector: aSelector ) notNil
		ifTrue: [
			^self siteObject setProperty: aPropertyName 
				withArguments: arguments ].
	OLEWarning signal: 'Unable to evaluate message #', aSelector,
		' (not supported by ', self partName, ').'.!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    |  isValidFlag isControlClassAvailableFlag copy |

    isValidFlag := self isValidFlag.
	self isValidFlag: nil.
    isControlClassAvailableFlag := self isControlClassAvailable.
	( aMirrorCopyDictionary forLaunch or: [ aMirrorCopyDictionary forDebug ] )
		ifFalse: [ self isControlClassAvailable: nil ].

    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        clsid: self clsid;  " relatively immutable, ok to share "
        controlState: self controlState copy.  " not shared, straight copy ok "

	self 
		isValidFlag: isValidFlag;
		isControlClassAvailable: isControlClassAvailableFlag.
    ^copy.!  
warningUnsupportedEventsRegistered: unsupportedEvents
		" Private - display a warning to the user that handlers
		have been registered for events which are not supported
		by the control which is contained in the receiver.. "

	OLEDevelopmentWarning signal: 
		'Unsupported events registered for pane containing control ',
		self partName, 
		' ', unsupportedEvents printString, '.'.!  
basicStyle
        "Private - Answer an Integer with appropriate
         constants combination for basic subpane style."

    ^WsChildWindow  "WsChild" 
		| WsInitiallyVisible "WsVisible"
		| WsClipSiblings  
		" but not WsClipChildren "!