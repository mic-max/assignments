3.1.0.106
   
setProperty: propertyName withArguments: argValuesArray
		" Set the value of the control's property named <propertyName> 
		to the last element of <argValuesArray>.  <argValuesArray> is an
		Array of values for an indexed property.  It may contain only one element, 
		the new value, for unindexed properties."

	self propertyDispatcher isNil
		ifTrue: [ ^nil ].
	self propertyDispatcher setProperty: propertyName withArguments: argValuesArray!  
dispatchIsEqual: iFont
		" Private - dispatch the IFont::IsEqual function. "

	^(functionHandlers at: 22) evaluateWithArguments: (Array
		with: iFont)!   
SetRatio: cyLogical _: cyHimetric
        " Invoke the IFont::SetRatio function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchSetRatio: cyLogical _: cyHimetric)!
put_Strikethrough: strikethrough
        " Invoke the IFont::put_Strikethrough function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Strikethrough: strikethrough)! 
invokeIsEqual: lpFontOther
        " Private - invoke the  IFont::IsEqual function for an external caller. "

    "STDMETHOD(IsEqual)(THIS_ IFont FAR * lpFontOther) PURE"

    | hresult anIFont |

    self ifOLETraceEnabled: [self logCallbackEntry].

    lpFontOther = 0
        ifFalse: [ ^E_INVALIDARG ].
    anIFont := self interfaceAtAddress: lpFontOther
        type: IFont.
    hresult := self dispatchIsEqual: anIFont.

    self ifOLETraceEnabled: [self logCallbackExit: hresult].
    ^hresult! 
disableControlWindow: windowHandle with: ignored
		" Private - disable the control window <windowHandle>. "

	( WindowHandle fromInteger: windowHandle ) disable.! 
get_Weight: resultReference
        " Invoke the IFont::get_Weight function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Weight: resultReference)!  
AddRefHfont: hfont
        " Invoke the IFont::AddRefHfont function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchAddRefHfont: hfont)!   
updateBackingStore
        " Private - Update the backing store of the control with its current state. "

	| aPersistenceInterface |
	self storage isStorage
		ifTrue: [
			self oleObject saveToStorage: self storage sameAsLoad: true.
			self storage commit ]
	ifFalse: [ 
			self storage
				setSize: 0;
				reset.
			aPersistenceInterface := self getPersistenceInterface.
			aPersistenceInterface save: self storage.
			aPersistenceInterface release.
			self storage commit ].!  
OnUIActivate
        "Private-The control's UI is being activated. Inform the container so it can remove its own UI components."

    self setInPlaceObjectRectangle.
    ^S_OK!  
invokeClone: lplpfont
        " Private - invoke the IFont::Clone function for an external caller. "

    "STDMETHOD(Clone)(THIS_ IFont FAR* FAR* lplpfont) PURE"

    | hresult resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    lplpfont isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: lplpfont.
    resultReference := nil asValueReference.
    hresult := self dispatchClone: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: lplpfont put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
dispatchPut_Weight: weight
		" Private - dispatch the IFont::put_Weight function. "

	^(functionHandlers at: 17) evaluateWithArguments: (Array
		with: weight)!   
get_Charset: resultReference
		" Private - implement the IFont::get_Charset function. "

	resultReference value: self localFont charSet.
	^S_OK!  
dispatchSetRatio: logical _: himetric
        " Private - dispatch the IFont::SetRatio function. "

	^(functionHandlers at: 23) evaluateWithArguments: (Array
		with: logical
		with: himetric)! 
acceleratorTable

	^self hAccel!
LockInPlaceActive: aBoolean
        " Private - implement the IOleControlSite::LockInPlaceActive function.
		The control needs to lock or unlock it's state to in-place active.
		Inform the container. <aBoolean> is <true> to lock, <false> to unlock. "

	^self unimplementedFunction!
clearIsValid
		" Private - the receiver is not valid. "

	self sitePane isValidFlag: false.!   
hAccel
		" Private - Answer the control mnemonics. "

    ^self uLongAtOffset: 4!  
ShowPropertyFrame
        " Private - implement the IOleControlSite::ShowPropertyFrame function.
		Show the property frame of the control. "

	^self unimplementedFunction!   
" OLE Control Support - library installation "

    " install interface classes "
    IFontPointer registerIID.
    IOleControlPointer registerIID.
    IOleControlSitePointer registerIID.
    IPropertyNotifySinkPointer registerIID.
    IFont registerIID.
    IOleControl registerIID.
    IOleControlSite registerIID.
    IPropertyNotifySink registerIID.
    IFontImplementation registerIID.
    IOleControlSiteImplementation registerIID.
    IPropertyNotifySinkImplementation registerIID.

    " register host structures "
    OLE_CONTROLINFO registerStructureName.
    OLE_POINTF registerStructureName.
    OLE_PROPPAGEINFO registerStructureName.

    " install development environment support "
    OLESessionManager bindDevelopmentLibrary: 'VOLDX31W.sll'
        for: 'OLE Control Support library VOLEX31W.sll'.
!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the Guid <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = IID_IFontDisp
		ifTrue: [ ^self dispatchInterface ].
	iid = IID_IFont
		ifTrue: [ 
			iFont isNil
				ifTrue: [ iFont := IFont on: self ].
			^iFont ].
	^super getInterfaceForIID: iid.! 
dispatchGet_Weight: resultReference
		" Private - dispatch the IFont::get_Weight function. "

	^(functionHandlers at: 16) evaluateWithArguments: (Array
		with: resultReference)! 
isInEditMode
		"Answer true if the receiver is in edit mode."

	^self sitePane isInEditMode!   
createStreamBackingStore
        " Private - Answer a new stream backing store for the receiver. "

    ^self usesMemoryBackingStore
        ifTrue: [ OLEGlobalMemoryStream createTemporaryStream ]
        ifFalse: [ self docFileStorage newStream: self name ].! 
displayObject: dwAspect site: aPane
        "Render the object's view or presentation at <aPane>.
        The DVASPECT value in <dwAspect> specifies the aspect or view of the object."

    " check for first reference to a demand-loaded site "
    self sitePane loadOnReference
        ifTrue: [
            "self ASSERT: self isEmpty."
            self sitePane loadOnReference: false.
            self constructControl ].

    self isValid not  " empty or not properly connected "
        ifTrue: [ ^aPane erase ].

    "If object is in-place activated, let the server render the object."
    inPlaceObject notNil
        ifTrue: [ ^aPane erase ].

    ^self oleObject display: dwAspect
        on: aPane
        in: self displayRectangle.
!   
cb
		" Private - Answer the structure size in bytes. "

	^self uLongAtOffset: 0!   
openStorageBackingStore
        " Private - Open the storage backing store for the receiver. "

    ^self usesMemoryBackingStore
        ifTrue: [  " someone must provide the saved state in this case "
            "OLEGlobalMemoryStorage on: self savedStateBytes...."
            self implementedBySubclass ]
        ifFalse: [ self docFileStorage openStorage: self name ].! 
registerControlFromOCXFile
		" Open a file dialog to allow the user to select an OCX file
		to execute the control's self-registration logic.
		Answer whether the registration succeeded. "

	" OLEControlChoiceDialog registerControlFromOCXFile "

    | aPathName |
    aPathName := ( FileDialog new
        title: 'Register OLE Control from OCX File';
        addFilter: '*.ocx' description: 'OLE Control Files (*.OCX)';
        defFilter: '*.ocx';
        open )
            file.
    aPathName isNil
        ifTrue: [ ^false ].
	^self registerControlFromOCXFile: aPathName!
getControlFromUser
		" Open a dialog which allows the user to select an OLE control.
		Answer the selected CLSID or nil. "

	" OLEControlChoiceDialog getControlFromUser "

	^self new open!
registerControlFromOCXFile: aPathName
		" Execute the self-registration logic of the OLE control
		in the OCX file specified by <aPathName>.
		Answer whether the registration succeeded. "

    " attempt to register a self-defining control "
    ( File exists: aPathName )
        ifFalse: [
            MessageBox warning: 'No such file: ', aPathName, '.'.
            ^false ].
    [ CursorManager execute changeFor: [
		OLEControlLibrary registerServer: aPathName ] ]
        on: Error
        do: [ :ex |
            MessageBox warning: ex description.
            ^false ].
	^true! 
getControlFromUser: aGuid
        " Open a dialog which allows the user to select an OLE control,
		with the CLSID specified by the Guid <aGuid> selected in the list.
        Answer the selected CLSID or nil. "

	^self new 
		initialSelection: aGuid
		open!  
dispatchClone: resultReference
		" Private - dispatch the IFont::Clone function. "

	^(functionHandlers at: 21) evaluateWithArguments: ( Array
		with: resultReference)!  
QueryTextMetrics: resultReference
        " Invoke the IFont::QueryTextMetrics function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchQueryTextMetrics: resultReference)!
setReadOnly: aBoolean
		" Specify whether the font which the receiver represents is read-only. "

	readOnly := aBoolean.!  
ambInvoke: dispidMember
	_: iid
	_: lcid
	_: wFlags
	_: dispparams
	_: resultReference
	_: exceptionInfoReference
	_: argErrorReference
		" Private - Implement the IDispatch:Invoke function for the site's ambient properties.
		Invoke a method or property get/set function of the object.
		Answer the result code."

    ( wFlags = DISPATCH_METHOD or: [ wFlags = DISPATCH_PROPERTYGET ] )
        ifFalse: [ ^E_INVALIDARG ].    "ambient properties are read-only"
    ( dispidMember between: DISPID_AMBIENT_AUTOCLIP and: DISPID_AMBIENT_BACKCOLOR )
        ifFalse: [ ^DISP_E_MEMBERNOTFOUND ].
    ^self
        perform: ( AmbientDispatchTable at: (self ambientPropertyIDToIndex: dispidMember ) )
        with: resultReference!  
saveObject
        " Private - Save the object attached to this client site. "

	self 
		saveCLSID;
		updateBackingStore.!   
TranslateAccelerator: wmsg _: modifiers
        " Private - implement the IOleControlSite::TranslateAccelerator function.
		Translate the keystroke accelerator for the control. "

	^( Notifier translateAccelerator: wmsg )
		ifTrue: [ S_OK ]
		ifFalse: [ S_FALSE ]!
initializeDispatchBindings
	"Private"
	"Establish dispatch connections to the properties and methods managed by the control."

	| anIDispatch anITypeInfo aTypeAttr aDispatchSpecificationTable |

	anIDispatch := self oleObject queryInterface: IID_IDispatch.
	anIDispatch hasTypeInfo
		ifFalse: [ ^self ].

	[
	anITypeInfo := anIDispatch getTypeInfo.
	aTypeAttr := anITypeInfo getTypeAttr.

	aDispatchSpecificationTable := OLEDispatchMemberSpecification 
		constructPropertySpecificationTable: aTypeAttr 
		typeInfo: anITypeInfo.
	self  propertyDispatcher: ( OLEDispatchDriver on: anIDispatch
		specificationTable: aDispatchSpecificationTable ).

	aDispatchSpecificationTable := OLEDispatchMemberSpecification 
		constructMethodSpecificationTable: aTypeAttr 
		typeInfo: anITypeInfo.
	self methodDispatcher: ( OLEDispatchDriver on: anIDispatch separateReference
		specificationTable: aDispatchSpecificationTable ).

	] ensure: [
		aTypeAttr release.
		anITypeInfo release ].! 
OnChanged: dispid
        " Private - implement the IPropertyNotifySink::OnChanged function.
		A property value, identified by <dispid>, has changed. Notify event handlers. 
		<dispid> may be -1 to indicate that an unspecified set of properties has changed."

	^( self sitePane changedProperty: ( self propertyNameFromDISPID: dispid ) )
		ifTrue: [ S_OK ]
		ifFalse: [ S_FALSE ]!
localFont
	"Answer the local font of the receiver."

	^localFont!  
constructEventsTriggered
	"Private - answer the set of events that instances of the receiver can trigger."

	^super constructEventsTriggered
		add: #aboutToChangeProperty: ;
		add: #changedProperty: ;
		add: #changed: ;
		yourself!
setProperty: propertyName withArguments: argValuesArray
		" Set the value of the control's property named <propertyName> 
		to the last element of <argValuesArray>.  <argValuesArray> is an
		Array of values for an indexed property.  It may contain only one element, 
		the new value, for unindexed properties."

	self siteObject setProperty: propertyName withArguments: argValuesArray!   
propertyAt: aPropertyName ifAbsent: aBlock
		"Answer the value of the receiver's property identified by <aPropertyName> 
		or the result of evaluating <aBlock> if none."

	^aPropertyName isSymbol
		ifTrue: [ super propertyAt: aPropertyName ifAbsent: aBlock ]
		ifFalse: [ self siteObject getProperty: aPropertyName ifAbsent: aBlock ]!  
controlEvents
		"Answer the names of the events that can be triggered by the OCX control."

	^self siteObject controlEvents!   
controlIsPushButton: aBoolean
		" Private - notify the receiver whether the control to which it is connected acts like a push button.
		Note that this means that it also needs to process mnemonics. "

	self propertyAt: #pushButton 
		put: ( aBoolean ifTrue: [ true ] ifFalse: [ nil ] ).!  
centered
	"Set text alignment to centered."

	self propertyAt: #textAlignment put: #centered.
	self siteObject ambientPropertyChanged: 'TextAlign'!   
isDefaultPushButton
		"Answer true if the receiver is the default push button."

	^( self propertyAt: #defaultPushButton ) == true!
validateEventTable
		" Private - validate the registered handlers in the receiver's event table.
		Display a warning message if a handler has been registered for an
		event which is not supported by the control. "

	| supportedEvents registeredEvents unsupportedEvents |
	supportedEvents := self eventsTriggered.
	registeredEvents := self eventsHandled.
	unsupportedEvents := registeredEvents reject: [ :anEvent |
		supportedEvents includes: anEvent ].
	unsupportedEvents notEmpty
		ifTrue: [ 
			self warningUnsupportedEventsRegistered: 
				unsupportedEvents asSortedCollection asArray printString ].!  
setProperty: propertyName value: newValue
	"Set the value of the property named <propertyName> to the <newValue>."

	self siteObject setProperty: propertyName withArguments: ( Array with: newValue )!
backColor: aColor
		"Set the background color of the receiver."

	self propertyAt: #backColor put: aColor.
	self siteObject ambientPropertyChanged: 'BackColor'.
	self isHandleOk
		ifTrue: [ self invalidateRect: nil ].!  
getValue
        "Answer the value of the Value property of the control."

	^self siteObject getProperty: 'Value'
		ifAbsent: [ self error: 'Value property not supported by ', self controlClassUserName ]!  
foreColor: aColor
	"Set the foreground color of the receiver."

	self propertyAt: #foreColor put: aColor.
	self siteObject ambientPropertyChanged: 'ForeColor'.
	self isHandleOk
		ifTrue: [ self invalidateRect: nil ].!   
setDefaultPushButton: aBooleanOrNil
		" Private - set or clear the default push button state of the receiver. "

	"self ASSERT: self isPushButton."
	( self propertyAt: #defaultPushButton ) ~~ aBooleanOrNil
		ifTrue: [
			self propertyAt: #defaultPushButton put: aBooleanOrNil.
			self siteObject ambientPropertyChanged: 'DisplayAsDefaultButton' ].!   
sizeChanged: extent
        "Private - The size of the receiver has been changed
         to extent."

	super sizeChanged: extent.
	self siteObject sizeChanged! 
setValue: aValue
        "Set the Value property of the control to <aValue>.  
		Trigger the changed event if the value is changed.
        Answer aValue."

	| currentValue |
	currentValue := self getValue.
	aValue ~= currentValue
		ifTrue: [
			self value: aValue.
			self triggerEvent: #changed: with: aValue ].
	^aValue!
defaultPushButton
		"Make the receiver behave like a default push button."

	self setDefaultPushButton: true.! 
propertyAt: aPropertyName
		"Answer the value of the receiver's property identified by <aPropertyName> or nil if none."

	^aPropertyName isSymbol
		ifTrue: [ super propertyAt: aPropertyName ]
		ifFalse: [ self siteObject getProperty: aPropertyName ifAbsent: [ nil ] ]! 
textAlignment
	"Answer the token that identifies text alignment. It may be one of #(general left center right fill)."

	^self propertyAt: #textAlignment ifAbsent: [ #general ]!   
controlProperties
		"Answer the names of the properties supported by the OCX control."

	^self siteObject controlProperties!   
doesNotUnderstand: aMessage
		" Private - sent to the receiver by the virtual machine when the message <aMessage>
		sent to the receiver was not implemented by the receiver.  Forward the message
		to the control if this is dynamic protocol for a control message or property. "

	| aPropertyName |
	self siteObject notEmpty
		ifTrue: [
			( self siteObject hasControlMethodSelector: aMessage selector )
				ifTrue: [
					^self siteObject invokeMethod: aMessage selector
						withArguments: aMessage arguments ].
			( aPropertyName := self siteObject propertyNameFromGetSelector: aMessage selector ) notNil
				ifTrue: [
					^self siteObject getProperty: aPropertyName 
						withArguments: aMessage arguments ].
			( aPropertyName := self siteObject propertyNameFromSetSelector: aMessage selector ) notNil
				ifTrue: [
					^self siteObject setProperty: aPropertyName 
						withArguments: aMessage arguments ].
		].
	super doesNotUnderstand: aMessage.! 
controlMethodSelectors
		"Answer the names of the messages that can be sent to the OCX control
		to invoke methods."

	^self siteObject controlMethodSelectors!   
controlPropertyGetSelectors
		"Answer the names of the messages that can be sent to the OCX control
		to get the value of a supported property."

	^self siteObject controlPropertyGetSelectors!  
controlPropertySetSelectors
		"Answer the names of the messages that can be sent to the OCX control
		to set the value of a supported property."

	^self siteObject controlPropertySetSelectors!  
invokeMethod: aSelector withArguments: argValuesArray
		" Invoke the control method named <aMethodName> with the arguments 
		in <argValuesArray>.  Answer the result value (nil if none). "

	^self siteObject invokeMethod: aSelector withArguments: argValuesArray!
warningUnsupportedEventsRegistered: unsupportedEvents
		" Private - display a warning to the user that handlers
		have been registered for events which are not supported
		by the control which is contained in the receiver.. "

	OLEDevelopmentWarning signal: 
		'Unsupported events registered for pane containing control ',
		self controlClassUserName, 
		' ', unsupportedEvents printString, '.'.!  
pushButton
		"Make the receiver behave like a standard (non-default) push button."

	self setDefaultPushButton: nil.!  
aboutToChangeProperty: propertyName
		" Private - the control is about the change the value of the property named <propertyName>.
		Trigger an event which clients can veto to prevent the change from occurring
		by sending the message #abortChange to the receiver.
		Answer whether the control can proceed to change the property. "

	| okToChange |
	okToChange := true.
	[self triggerEvent: #aboutToChangeProperty: with: propertyName]
		on: VetoAction
		do: [:ex | okToChange := false. ex resume].
	^okToChange! 
isButton
        " Answer whether the receiver is a button. "

	^self isPushButton
!  
eventsTriggered
		"Answer the names of the events that can be triggered by the receiver."

	^self class eventsTriggered
		addAll: self siteObject controlEvents;
		yourself! 
clsid
		" Answer the CLSID of the control contained in the receiver site. "

	^self siteObject controlCLSID!   
clsid: aCLSID
		" Set the CLSID of the control contained in the receiver site to the GUID <aCLSID>. "

	self siteObject controlCLSID: aCLSID.! 
editProperties
		"Open the property sheet for the control."

	self siteObject editProperties.! 
getProperty: propertyName withArguments: argValuesArray
        "Answer the value of the control's property named <propertyName>.
        <argValuesArray> is the Array of argument values for a parameterized property. 
		It may be zero length for unindexed properties. "

	^self siteObject getProperty: propertyName withArguments: argValuesArray!
propertyAt: propertyName put: aValue
	"Set the value of the property named <propertyName> to <aValue>."

	propertyName isSymbol
		ifTrue: [ super propertyAt: propertyName put: aValue ]
		ifFalse: [ self siteObject setProperty: propertyName value: aValue ]! 
getProperty: propertyName
		"Answer the value of the property named <propertyName>."

	^self siteObject getProperty: propertyName! 
value: aValue
        "Set the Value property of the control to <aValue>.  
        Answer <aValue>."

	( self siteObject hasControlProperty: 'Value' )
		ifFalse: [ self error: 'Value property not supported by ', self controlClassUserName ].
	self setProperty: 'Value' value: aValue.
	^aValue!  
controlClassUserName
        " Answer the registered name of the control class in the receiver.
        Answer nil if the receiver does not contain a control. "

	^self siteObject controlClassUserName! 
siteObjectClass
    "Private - answer the class which is used for the receiver's site. "

    ^OLEControlSiteObject!   
isInEditMode
	"Answer true if the receiver is in edit mode."

	^false! 
isPushButton
        "Answer whether the receiver is a push button"

	^( self propertyAt: #pushButton ) == true!   
changedProperty: propertyName
		" Private - the control has changed the value of the property named <propertyName>. 
		<propertyName> may be nil indicating that some unspecified set of properties has changed. 
		Trigger an event to notify interested parties. "

	self triggerEvent: #changedProperty: with: propertyName.! 
textAlignmentIndex
	"Answer the zero-based index into the text alignment list for use by the control."

	| align |
	align := #( #general #left #center #right #fill ) indexOf: self textAlignment.
	align = 0
		ifFalse: [ align := align - 1 ].
	^align!  
triggerControlEvent: eventName withArguments: arguments
		" Private - the control has triggered the event <eventName> with
		argument values <arguments>.  Trigger the event from the receiver. "

	self triggerEvent: eventName withArguments: arguments!
font: aFont
	"Set the foreground color of the receiver."

	self fontAttribute: aFont.
	self siteObject ambientPropertyChanged: 'Font'.
	self isHandleOk
		ifTrue: [ self invalidateRect: nil ].!
canTriggerEvent: eventName
        "Answer <true> if the receiver can trigger an event
        named <eventName>."

	^( self siteObject isEmpty  " have to allow any registration before control is connected "
			or: [ self siteObject hasControlEvent: eventName ] )
		or: [ super canTriggerEvent: eventName ]! 
createInterfaceForIID: iid
		" Private - answer a new instance of the interface identified by the GUID <iid>>
        on the receiver.  Answer nil if the interface is not supported. "

    | anInterface |
    ( anInterface := super createInterfaceForIID: iid ) notNil
        ifTrue: [ ^anInterface ].
    iid = IID_IOleControlSite
        ifTrue: [ ^IOleControlSite on: self ].
    iid = IID_IPropertyNotifySink
        ifTrue: [ ^IPropertyNotifySink on: self ].
    iid = IID_IDispatch
        ifTrue: [ ^self createAmbientPropertyDispatchInterface ].
    ^nil!  
getAmbShowHatching: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: self isInEditMode.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient show hatching returned: ', variant value printString ].
    ^S_OK!  
get_Name: resultReference
        " Invoke the IFont::get_Name function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Name: resultReference)!
getPersistenceInterface
		" Private - answer the persistence interface of the receiver's control. "

	self storage isStream
		ifTrue: [ ^self oleObject queryInterface: IID_IPersistStreamInit ].
	self storage isStorage
		ifTrue: [ ^self oleObject queryInterface: IID_IPersistStorage ].
	^nil!
GetWindowContext: frameRef
	_: windowRef
	_: positionRef
	_: clipRef 
	_: frameInfoRef
        " Private - implement the IOleInPlaceSite::GetWindowContext function.
		The control needs its window context. Fill the parameters with required data.
		<frameRef> a value holder that get set to a IOleInPlaceFrame interface
		<windowRef> a value holder that gets set to a IOleInPlaceUIWindow interface
		<positionRect> a value holder that gets set to the control's position
		<clipRect> a value holder that gets set to the clipping rectangle
		<frameInfoRef> a value holder for an OLE_OLEINPLACEFRAMEINFO that needs to be filled. "

    frameRef value: (self container queryInterface: IID_IOleInPlaceFrame ).
    positionRef value: self sitePane rectangle.
    clipRef value: self sitePane rectangle.
    frameInfoRef value: ( ( OLEStructure createStructureNamed: #OLEINPLACEFRAMEINFO )
        fMDIApp: (Smalltalk includesKey: #MDISystem);
        hwndFrame: self container window handle;
        haccel: nil;
        cAccelEntries: 0;
        yourself ).
    ^S_OK!   
printOn: aStream
	"Append a textual representation of the receiver to aStream."

	aStream
		nextPutAll: self class name;
		nextPutAll: ' { ';
		nextPutAll: self asPoint printString;
		nextPutAll: ' } '! 
TranslateAccelerator: msgPointer _: modifiers
		" Invoke the IControlSite::TranslateAccelerator function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchTranslateAccelerator: msgPointer _: modifiers )!   
invokeOnControlInfoChanged
        " Private - invoke the IOleControlSite::OnControlInfoChanged function for an external caller. "

	"STDMETHOD(OnControlInfoChanged)(THIS) PURE"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnControlInfoChanged.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
invokeShowPropertyFrame
        " Private - invoke the IOleControlSite::ShowPropertyFrame function for an external caller. "

    "STDMETHOD(ShowPropertyFrame)(THIS) PURE;"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchShowPropertyFrame.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
OnControlInfoChanged
		"Invoke the IControlSite::OnControlInfoChanged function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchOnControlInfoChanged )!  
dispatchOnControlInfoChanged
		" Private - dispatch the IControlSite::OnControlInfoChanged function. "

	^( functionHandlers at: 4 ) evaluate! 
TransformCoords: pointL _: pointF _: flags
		"	Invoke the IControlSite::TransformCoords function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchTransformCoords: pointL _: pointF _: flags )!  
dispatchTranslateAccelerator: msgPointer _: modifiers
	"Private - dispatch the IControlSite::TranslateAccelerator function."

	^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
		with: msgPointer
		with: modifiers)! 
invokeOnFocus: fGotFocus
        " Private - invoke the IOleControlSite::OnFocus function for an external caller. "

	"STDMETHOD(OnFocus)(THIS_ BOOL fGotFocus) PURE"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnFocus: fGotFocus.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!  
dispatchGetExtendedControl: resultReference
		" Private - dispatch the IControlSite::GetExtendedControl function. "

	^( functionHandlers at: 6 ) evaluateWithArguments: ( Array
		with: resultReference )!   
invokeTransformCoords: pointLPointer _: pointFPointer _: flags
        " Private - invoke the IOleControlSite::TransformCoords function for an external caller. "

    "STDMETHOD(TransformCoords)(THIS_ POINTL FAR* lpptlHimetric,
        POINTF FAR* lpptfContainer, DWORD flags) PURE"

    | pointL pointF hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    ( pointLPointer isValid and: [ pointFPointer isValid ] )
        ifFalse: [ ^E_INVALIDARG ].
	" This is an unusual function in that either point can be input or output,
		depending on the transformation being invoked.  "
	pointL := WinPoint atAddress: pointLPointer.
    pointF := self structureAtAddress: pointFPointer
        type: #POINTF.
    hresult := self dispatchTransformCoords: pointL 
		_: pointF 
		_: flags.
	" handler in this case will have set the output buffer directly with the result value "
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
dispatchLockInPlaceActive: bool
		"Private - dispatch the IControlSite::LockInPlaceActive function."

	^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
		with: bool )! 
invokeTranslateAccelerator: msgPointer _: modifiers
        " Private - invoke the IOleControlSite::TransformAccelerator function for an external caller. "

    "STDMETHOD(TranslateAccelerator)(THIS_ LPMSG lpMsg, DWORD grfModifiers)
        PURE"

    | msg hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    msgPointer isValid
        ifFalse: [ ^E_INVALIDARG ].
    msg := self structureAtAddress: msgPointer
        type: WinMessage.
    hresult := self dispatchTranslateAccelerator: msg _: modifiers.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult! 
invokeGetExtendedControl: ppDisp
        " Private - invoke the IOleControlSite::GetExtendedControl function for an external caller. "

    "STDMETHOD(GetExtendedControl)(THIS_ LPDISPATCH FAR* ppDisp) PURE"

    | resultReference hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    ppDisp isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: ppDisp.
    resultReference := nil asValueReference.
    hresult := self dispatchGetExtendedControl: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppDisp put: resultReference value ].
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
LockInPlaceActive: fLock
		" Invoke the IControlSite::LockInPlaceActive function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchLockInPlaceActive: fLock )!
dispatchTransformCoords: pointLPointer _: pointFPointer _: flags
		" Private - dispatch the IControlSite::TransformCoords function. "

	^( functionHandlers at: 7 ) evaluateWithArguments: ( Array
			with: pointLPointer
			with: pointFPointer
			with: flags )!  
invokeLockInPlaceActive: fLock
        " Private - invoke the IOleControlSite::LockInPlaceActive function for an external caller. "

	"STDMETHOD(LockInPlaceActive)(THIS_ BOOL fLock) PURE"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchLockInPlaceActive: fLock.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!  
dispatchShowPropertyFrame
		" Private - dispatch the IControlSite::ShowPropertyFrame function. "

	^(functionHandlers at: 10) evaluate!
dispatchOnFocus: bool
		" Private - dispatch the IControlSite::OnFocus function. "

	^( functionHandlers at: 9 ) evaluateWithArguments: ( Array 
		with: bool )!  
ShowPropertyFrame
		" Invoke the IControlSite::ShowPropertyFrame function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchShowPropertyFrame )!  
OnFocus: fGotFocus
		" Invoke the IControlSite::OnFocus function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		( self dispatchOnFocus: fGotFocus )!  
GetExtendedControl: resultReference
		" Invoke the IControlSite::GetExtendedControl function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		(self dispatchGetExtendedControl: resultReference)!   
dispatchGet_hFont: resultReference
		" Private - dispatch the IFont::get_hFont function. "

	^(functionHandlers at: 20) evaluateWithArguments: (Array
		with: resultReference)!   
hasControlEvent: eventName
		"Answer true if the control can trigger the event <eventName>."

	^self eventSink isNil
		ifTrue: [ false ]
		ifFalse: [ self eventSink hasEvent: eventName ]!  
insertEmbeddedObject: objectClsid hMetaPict: hMetaPict
        " Insert the object specified by <objectClsid> into the pane associated with
        the receiver. If <hMetaPict> contains a valid handle then display as an icon. "

    self deleteContent.  " moved to #createObject to avoid smashing the control's CLSID "

    self controlCLSID: objectClsid.
    self 
		createObject;
		connectObjectToSite: nil.
    self saveObject.
    self activateObjectVerbShow. !  
setProperty: propertyName value: aValue
		"Set the value of the control's property named <propertyName> to <aValue>. "

	self propertyDispatcher isNil
		ifTrue: [ ^nil ].
	self propertyDispatcher setProperty: propertyName value: aValue! 
fromPoint: aPoint
	"Answer a new instance of the receiver created from <aPoint>."

	| new |
	new := self new.
	new x: aPoint x asFloat.
	new y: aPoint y asFloat.
	^new!   
invokePut_Size: lo _: hi
        " Private - invoke the IFont::PutSize function for an external caller. "

    "STDMETHOD(put_Size)(THIS_ CY size) PURE"

    | hresult size |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    size := OLEStructure createStructureNamed: #CURRENCY.
    size lo: lo; hi: hi.
    hresult := self dispatchPut_Size: size.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
createAmbientPropertyDispatchInterface
	"Private - Answer an IDispatch on an IDispatchImplementation that forwards its callbacks to the receiver for providing the control access to ambient properties."

	^IDispatch on: self
		selectors: self standardIUnknownSelectors, #(
			#ambGetTypeInfoCount:
			#ambGetTypeInfo:_:_:
			#ambGetIDsOfNames:_:_:_:_:
			#ambInvoke:_:_:_:_:_:_:_: ) !   
pasteStaticObject: anIDataObject
        " Paste the static object specified by <anIDataObject>
        into the pane associated with the receiver."

	self error: 'not supportedt for an OLE control site'!  
invokeGet_Name: pname
        " Private - invoke the  IFont::get_Name function for an external caller. "

	"STDMETHOD(get_Name)(THIS_ BSTR FAR* pname) PURE"

    | resultReference hresult bstrAddress |

    self ifOLETraceEnabled: [self logCallbackEntry].

    pname isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: pname.
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Name: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [
            bstrAddress := BSTRMemoryAddress allocateString: resultReference value.
            bstrAddress doesNotNeedFinalization.
            self addressResultAtAddress: pname put: bstrAddress ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult! 
dispatchPut_Underline: underline
		" Private - dispatch the IFont::put_Underline function. "

	^(functionHandlers at: 13) evaluateWithArguments: (Array
		with: underline)!   
clsidUserName: aCLSID
        " Answer the registered name of the control class identified by the GUID <aCLSID>. "

	| userName |
	OLESessionManager isOLEAvailable
		ifFalse: [
			^'(unknown CLSID ', aCLSID asHexDescriptionString, ')' ].
    [ userName := OLERegistryInterface getUserTypeFull: aCLSID ]
        on: Error
        do: [ ^'(unknown CLSID ', aCLSID asString, ')' ].
	^userName isNil
		ifTrue: [ '(unknown CLSID ', aCLSID asString, ')' ]
		ifFalse: [ userName ]

!
saveCLSID
		" Private - save the CLSID of the control in its backing. "

	| clsidStream |
	self usesMemoryBackingStore
		ifTrue: [ ^nil ].  " do nothing... "
	clsidStream := self docFileStorage newStream: 'CLSID-', self name.
	clsidStream writeCLSID: self controlCLSID.
	clsidStream
		commit;
		release.
	! 
controlPropertySetSelectors
		"Answer the names of the messages that can be sent to the OCX control
		to set the value of a supported property."

	| names aSelector |
	self propertyDispatcher isNil
		ifTrue: [ ^#( ) ].
	names := OrderedCollection new.
	self propertyDispatcher specificationsDo:
		[ :aDispatchSpec |
		( aSelector := aDispatchSpec setSelector ) ~~ nil
			ifTrue: [ names add: aSelector ] ].
	^names!   
invokePut_Underline: boolean
        " Private - invoke the  IFont::put_Underline function for an external caller. "

	"STDMETHOD(put_Underline)(THIS_ BOOL underline) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchPut_Underline: boolean.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!   
ambGetTypeInfo: itinfo _: lcid _: resultReference
	" Private - Implement the IDispatch::GetTypeInfo function for the site's ambient properties.
     Retrieve the type information for the automation object for locale <lcid>. 
	Answer the result code. "

	^self unimplementedFunction!   
get_Name: resultReference
		" Private - implement the IFont::get_Name function. "

	resultReference value: self localFont faceName.
	^S_OK!   
pasteEmbeddedObject: anIDataObject
        " Paste the object specified by <anIDataObject> into the pane
        associated with the receiver."

	self error: 'not supportedt for an OLE control site'!   
methodDispatcher
	"Private"
	"Answer the method dispatcher of the receiver."

	^methodDispatcher! 
queryTextMetrics
		" Answer the text metrics of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface QueryTextMetrics: resultReference.
	^resultReference value!
getSize
		" Answer the size of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Size: resultReference.
	^resultReference value! 
getStrikethrough
		" Answer the strikethrough attribute of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Strikethrough: resultReference.
	^resultReference value!
putWeight: anInteger
		" Set the weight attribute of  the receiver font to <anInteger>. "

	^interface put_Weight: anInteger!  
putSize: anInteger
		" Set the size attribute of  the receiver font to <anInteger>. "

	^interface put_Size: anInteger!
putCharset: anInteger
		" Set the charset attribute of  the receiver font to <anInteger>. "

	^interface put_Charset: anInteger!   
getUnderline
		" Answer the underline attribute of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Underline: resultReference.
	^resultReference value!
getCharset
		" Answer the charset attribute of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Charset: resultReference.
	^resultReference value!  
putUnderline: aBoolean
		" Set the underline attribute of  the receiver font to <aBoolean>. "

	^interface put_Underline: aBoolean!
putStrikethrough: aBoolean
		" Set the strikethrough attribute of  the receiver font to <aBoolean>. "

	^interface put_Strikethrough: aBoolean!
releaseHfont: hfont
		" Release the <hfont> from  the receiver font. "

	^interface ReleaseHfont: hfont!   
getHfont
		" Answer the handle of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_hFont: resultReference.
	^resultReference value! 
getItalic
		" Answer the italic attribute of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Italic: resultReference.
	^resultReference value! 
isEqual: anotherIFont
		"Answer whether ther receiver font is equal to <anotherIFont>. "

	^( interface IsEqual: anotherIFont ) = S_OK!
clone
		" Answer a clone of the receiver font. "

	| resultReference |
	resultReference := self class new asValueReference.
	interface Clone: resultReference.
	^resultReference value! 
getBold
		" Answer the bold attribute of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Bold: resultReference.
	^resultReference value!   
putItalic: aBoolean
		" Set the italic attribute of  the receiver font to <aBoolean>. "

	^interface put_Italic: aBoolean! 
getName
		" Answer the name of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Name: resultReference.
	^resultReference value! 
setRatio: cyLogical cyHimetric: cyHimetric
		" Set the logical to himetric ration of the receiver font. "

	^interface SetRatio: cyLogical _: cyHimetric!  
putBold: aBoolean
		" Set the bold attribute of  the receiver font to <aBoolean>. "

	^interface put_Bold: aBoolean!   
addRefHfont: hfont
		" Add the font <hfont> to the receiver font. "

	^interface AddRefHfont: hfont!   
putName: aString
		" Set the name attribute of  the receiver font to <aString>. "

	^interface put_Name: aString!  
getWeight
		" Answer the weight attribute of  the receiver font. "

	| resultReference |
	resultReference := nil asValueReference.
	interface get_Weight: resultReference.
	^resultReference value! 
put_Weight: weight
		" Private - implement the IFont::put_Weight function. "

	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	^self unimplementedFunction!   
invokeMethod: aSelector withArguments: argValuesArray result: resultReference
		" Invoke the control method named <aMethodName> with the arguments 
		in <argValuesArray>.  Store the result value into the <resultReference>. 
		Answer the result value (nil if none). "

	self methodDispatcher isNil
		ifTrue: [ ^nil ].
	^self methodDispatcher invokeMethod: aSelector 
		withArguments: argValuesArray 
		result: resultReference!
localFont: aFont
	"Set the receiver's local font to be <aFont>."

	localFont := aFont! 
canInPlaceActivate
        " Answer whether the object in the receiver can be in-place activated. "

    ^true!
ShowObject
        " Private - implement the IOleClientSite::ShowObject function.
		Request the receiver to position the object so it is visible to the user.
		Answer the result code. "

"-----
    self container window bringToFront.
    self sitePane setFocus.
-----"
    ^S_OK!  
extentForList: aList in: aListPane
        " Private - answer the size in dialog box units
        for aList. "

	| anExtent |
	anExtent := super extentForList: aList in: aListPane.
	^list size > 0
		ifTrue: [ anExtent ]
		ifFalse: [   " make empty list at least as wide as the browse button "
			( self extentForButton: self browseButtonLabel ) x @ anExtent y ] 
!   
browseButtonLabel
		" Private - answer the label of the button for browsing OCX files. "

	^'Register new control...'! 
createView
        " Private - create the window.
        Window sizing is done in dialog box units. "

    | charWidthDlg marginDlg topPane
      deltaLeftTop deltaTopLeft2 deltaLeftMarginX
      internalWidthDlg anExtent
      browseControlsLabel |

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

    " Browse button to locate self-registering OCX's "
    browseControlsLabel := self browseButtonLabel.
    anExtent := self extentForButton: browseControlsLabel.
    topPane addSubpane:
        (Button new
            defaultPushButton;
            font: self font;
            contents: browseControlsLabel;
            when: #clicked send: #browseOtherControls to: self ;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: anExtent)).
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
openOn: aList selection: initialSelection
        " Private - disable inherited opening protocol which does not apply to the receiver. "

	self error: 'inappropriate message'!
setControlList
		" Private - set the list of registered controls. "

	CursorManager execute changeFor: [
		controlClassIDMap := OLERegistryInterface controlClassIDMap.
		].
	list := controlClassIDMap values asSortedCollection asArray.! 
browseOtherControls
        " Private - browse files for other unregistered controls "

    | listPane selectedItem originalEntries newEntries |

	self class registerControlFromOCXFile
		ifFalse: [ ^nil ].

    " refresh the list of registered controls "
    listPane := self paneAt: self listPaneName.
    selectedItem := listPane selectedItem.
    originalEntries := list.
    self setControlList.
    newEntries := list reject: [ :aControlName | originalEntries includes: aControlName ].
    newEntries notEmpty
        ifTrue: [ selectedItem := newEntries asSortedCollection first ].
    listPane
        list: list;
        selection: selectedItem.

!  
openOn: aList
        " Private - disable inherited opening protocol which does not apply to the receiver. "

	self error: 'inappropriate message'!
computeMinListHeight
		" Private - ensure a minimum height for the list. "

	list size = 0
		ifTrue: [ ^self minEntriesToShow: 2 ].
	list size < 5
		ifTrue: [ ^self minEntriesToShow: list size + 1 ].!
initialize
        " Private "

	super initialize.
	title := 'Choose OLE Control'.
	self textLines: #(
		'Registered OLE Controls:'
		).!  
initialSelection: aCLSID
		" Make the Guid <aCLSID> the initial selection when the dialog is opened. "

	selection := aCLSID.! 
open
		" Open a dialog which allows the user to select an OLE control.
		Answer the CLSID Guid of the selected OLE object class.
		Answer nil if no selection has been made. "

	| topPane |
	self 
		setControlList;
		computeMinListHeight.
	selection notNil
		ifTrue: [ selection := controlClassIDMap at: selection
			ifAbsent: [ nil ] ].
	topPane := self createView.
	selection := nil.
	topPane openModal: pmOwner.
    ^selection isNil
		ifTrue: [ nil ]
		ifFalse: [ controlClassIDMap keyAtValue: selection ]! 
createEventSink
        " Private - collect the information needed to establish
        connections to the events triggered by the control
        and create a contained event sink object. "

    | anITypeInfo aTypeAttr anEventSink |

    anITypeInfo := self class getEventTypeInfoOf: self oleObject.
    ( anITypeInfo == nil
    or: [ ( aTypeAttr := anITypeInfo getTypeAttr ) == nil ] )
        ifTrue: [
            anITypeInfo notNil
                ifTrue: [ anITypeInfo release ].
            OLEWarning signal: 'Unable to obtain event connection information.'.
            ^nil ].

    [
    anEventSink := OLEEventSink iid: aTypeAttr guid  " connection point IID "
        specificationTable: ( OLEDispatchMemberSpecification
            constructEventSinkSpecificationTable: aTypeAttr
            typeInfo: anITypeInfo ).
    ] ensure: [
        aTypeAttr release.
        anITypeInfo release ].
    ^anEventSink! 
put_Name: name
        " Invoke the IFont::put_Name function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Name: name)!  
size

	^WinPoint usingBytes: (self bytesAtOffset: 8 count: 8)!  
invokeGet_hFont: phfont
        " Private - invoke the IFont::get_hFont function for an external caller. "

    "STDMETHOD(get_hFont)(THIS_ HFONT FAR* phfont) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    phfont isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_hFont: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: phfont put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
reflectsMessagesToControl
		"Answer true if the receiver's container reflects windows messages back to the control."

	^false! 
hasControlPropertySetSelector: aSelector
		" Answer whether the the message <aSelector> can be dispatched
		to the receiver's control to set the value of a property. "

	self propertyDispatcher isNil
		ifTrue: [ ^false ].
	self propertyDispatcher specificationsDo:
		[ :aDispatchSpec |
		aDispatchSpec setSelector = aSelector
			ifTrue: [ ^true ] ].
	^false!  
sizeInBytes
	"Answer the structure size in bytes."

	^8!   
put_Italic: italic
        " Invoke the IFont::put_Italic function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Italic: italic)!
propertyNameFromDISPID: dispid
	"Private"
	"Answer the name of the property whose DISPID is <dispid>."

	dispid < 0
		ifTrue: [ ^self ambientPropertyNameFromDISPID: dispid ].
	self propertyDispatcher specificationsDo:
		[ :aDispatchSpecification |
		aDispatchSpecification memberID = dispid
			ifTrue: [ ^aDispatchSpecification name ] ].
	^nil!
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #CONTROLINFO for: self.!   
editProperties
		"Open the property sheet for the control."

	self doVerb: OLEIVERB_PROPERTIES!
IsEqual: otherFont
        " Private - implement the IFont::IsEqual function. "

	| h1 h2 |
	( self interfaceForIID: IID_IFont ) get_hFont: ( h1 := nil asValueReference ).
	otherFont get_hFont: ( h2 := nil asValueReference ).
	^h1 value = h2 value
		ifTrue: [ S_OK ]
		ifFalse: [ S_FALSE ]!
loadObject
        " Private - load the receiver's object from its persistent backing store."

    | anIOleObject aPersistenceInterface setClientSiteFirst |

    self controlCLSID isNil
        ifTrue: [ self loadCLSID ].
    self controlCLSID isNil
        ifTrue: [ ^nil ].

    self clearIsValid.  " disable rendering during construction "

    anIOleObject := IClassFactory createInstance: self controlCLSID
        iid: IID_IOleObject
        controllingUnknown: nil
        context: CLSCTX_INPROC_SERVER.

	self persistentStateIsStream
		ifTrue: [ aPersistenceInterface := anIOleObject queryInterface: IID_IPersistStreamInit ].
	self persistentStateIsStorage
		ifTrue: [ aPersistenceInterface := anIOleObject queryInterface: IID_IPersistStorage ].
    aPersistenceInterface isNil
        ifTrue: [
            anIOleObject release.
            ^nil ].

    [

    setClientSiteFirst := self setClientSiteFirst.
    setClientSiteFirst
        ifTrue: [ anIOleObject setClientSite: self myOleClientSite ].

    aPersistenceInterface usesStream
        ifTrue: [  " preferred backing is the lighter-weight stream "
            self storage: self openStreamBackingStore.
            aPersistenceInterface load: self storage ]
        ifFalse: [  " storage backing "
            self storage: self openStorageBackingStore.
            aPersistenceInterface load: self storage ].
    aPersistenceInterface release.

    setClientSiteFirst
        ifFalse: [ anIOleObject setClientSite: self myOleClientSite ].

    ] on: OLEError
        do: [ :ex |
            anIOleObject release.
            aPersistenceInterface release.
            self releaseStorage.
            ex pass ].

    self oleObject: anIOleObject.
    ^anIOleObject!  
getAmbBackColor: variant
    "Private"

    | color |
    ( color := self sitePane backColor ) == nil
        ifTrue: [ color := self sitePane defaultBackColor ].
    color == nil
        ifTrue: [ ^DISP_E_MEMBERNOTFOUND ].
    variant
        typeCode: VT_COLOR;
        value: color asInteger.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient back color returned: ', color printString ].
    ^S_OK!
getAmbUIDead: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: self isUIDead.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient UI dead returned: ', variant value printString ].
    ^S_OK!  
dispatchGet_Italic: resultReference
		" Private - dispatch the IFont::get_Italic function. "

	^(functionHandlers at: 10) evaluateWithArguments: (Array
		with: resultReference)! 
getAmbSupportsMnemonics: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: true.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient supports mnemonics returned: ', variant value printString ].
    ^S_OK! 
controlCLSID
		"Answer the CLSID that identifies the class iid of the receiver's OCX."

	^controlCLSID!
get_Strikethrough: resultReference
		" Private - implement the IFont::get_Strikethrough function. " 

	resultReference value: self localFont strikeOut.
	^S_OK!   
singleFloatAtOffset: offset put: doubleFloat
	"Convert <doubleFloat>, an instance of Float, to a single-precision float representation and store that four-byte value at offset <offset>."

	self bytesAtOffset: offset
		put: ( self class externalFloatFromInternalFloat: doubleFloat )!
storage
        " Private - Answer the backing storage of the receiver. 
		Unlike the client site, a control does not create a backing store on demand. "

    ^storage!  
ambGetTypeInfoCount: resultReference
	" Private - Implement the IDispatch::GetTypeInfoCount function for the site's ambient properties.
     Retrieve the number of type information interfaces that an
	object provides.  (This will be either 0 or 1).
	Answer the result code. "

	resultReference value: 0.
	^S_OK!
invokePut_Strikethrough: boolean
        " Private - invoke the  IFont::put_Strikethrough function for an external caller. "

	"STDMETHOD(put_Strikethrough)(THIS_ BOOL strikethrough) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchPut_Strikethrough: boolean.
	self ifOLETraceEnabled:	[self logCallbackExit: hresult].
	^hresult!   
dispatchGet_Strikethrough: resultReference
		" Private - dispatch the IFont::get_Strikethrough function. "

	^(functionHandlers at: 14) evaluateWithArguments: (Array
		with: resultReference)!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #PROPPAGEINFO for: self.!  
setClientSiteFirst
        " Private - answer whether the control wants its client site to be set before loading. "

    ^( ( OLERegistryInterface getMiscStatus: self controlCLSID )
        bitAnd: OLEMISC_SETCLIENTSITEFIRST ) ~= 0!  
hasControlMethodSelector: aSelector
		" Answer whether the the message <aSelector> can be dispatched
		to the receiver's control to invoke a method. "

	^self methodDispatcher notNil
		and: [ self methodDispatcher hasSpecificationNamed: aSelector ]!
inspectorFields
    "Answer the names of the fields contained in the receiver definition; reimplemented by subclasses."

    ^self inspectorClass
        fields: #( #cb #pszTitle #size #pszDocString #pszHelpFile #dwHelpContext )! 
" OLE Control Support - library removal "

    " remove interface classes "
    IFontPointer removeIID.
    IOleControlPointer removeIID.
    IOleControlSitePointer removeIID.
    IPropertyNotifySinkPointer removeIID.
    IFont removeIID.
    IOleControl removeIID.
    IOleControlSite removeIID.
    IPropertyNotifySink removeIID.
    IFontImplementation removeIID.
    IOleControlSiteImplementation removeIID.
    IPropertyNotifySinkImplementation removeIID.

    " remove host structures "
    OLE_CONTROLINFO removeStructureName.
    OLE_POINTF removeStructureName.
    OLE_PROPPAGEINFO removeStructureName.

    " remove development environment support "
    OLESessionManager unbindDevelopmentLibrary: 'VOLDX31W.sll'.
!   
invokeGet_Bold: pbold
        " Private - invoke the IFont::get_Bold function for an external caller. "

    "STDMETHOD(get_Bold)(THIS_ BOOL FAR* pbold) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pbold isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Bold: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self booleanResultAtAddress: pbold put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
createObject
        " Private - create an embedded object for the control
        Allocate its backing store and initialize the control. "

    | anIOleObject aPersistenceInterface setClientSiteFirst |

    "self deleteContent."  " moved to insertObject to avoid smashing the CLSID "
	self ASSERT: self isEmpty.

    anIOleObject := IClassFactory createInstance: self controlCLSID
        iid: IID_IOleObject
        controllingUnknown: nil
        context: CLSCTX_INPROC_SERVER.

	aPersistenceInterface := anIOleObject queryInterface: IID_IPersistStreamInit.
	aPersistenceInterface isNil
		ifTrue: [ aPersistenceInterface := anIOleObject queryInterface: IID_IPersistStorage ].
    aPersistenceInterface isNil
        ifTrue: [
            anIOleObject release.
            ^nil ].

    [
    setClientSiteFirst := self setClientSiteFirst.
    setClientSiteFirst
        ifTrue: [ anIOleObject setClientSite: self myOleClientSite ].

    aPersistenceInterface usesStream
        ifTrue: [  " preferred backing is the lighter-weight stream "
            self storage: self createStreamBackingStore.
            aPersistenceInterface initNew ]
        ifFalse: [  " storage backing "
            self storage: self createStorageBackingStore.
            aPersistenceInterface initNew: self storage ].
    aPersistenceInterface release.

    setClientSiteFirst
        ifFalse: [ anIOleObject setClientSite: self myOleClientSite ].

    ] on: OLEError
        do: [ :ex |
            anIOleObject release.
            aPersistenceInterface release.
            self deletePersistentState.
            ex pass ].

	self
		clearIsValid;
		oleObject: anIOleObject.
    ^anIOleObject!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #PROPPAGEINFO.!  
constructControl
        " Create or load the receiver's control if persistent state or control identity is known. "

    self hasPersistentState
        ifTrue: [
            self loadObjectFromStorage.
            self sitePane validateEventTable.
            ^self ].
    self controlCLSID notNil
        ifTrue: [
            self insertEmbeddedObject: self controlCLSID.
            self sitePane validateEventTable.
            ^self ].
        ! 
invokePut_Name: name
        " Private - invoke the IFont::PutName function for an external caller. "

    "STDMETHOD(put_Name)(THIS_ BSTR name) PURE"

    | hresult bstrName |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    name isValid
        ifFalse: [ ^E_INVALIDARG ].
    bstrName := BSTR atAddress: 
        ( BSTRMemoryAddress fromInteger: ( name uLongAtOffset: 0 ) ).
    hresult := self dispatchPut_Name: bstrName asString.
    bstrName release.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
propertyNameFromSetSelector: aSelector
		" Answer the name of the control property which is set when the
		message <aSelector> is dispatched to the receiver's control.
		Answer nil if the selector is not a property set selector. "

	self propertyDispatcher specificationsDo:
		[ :aDispatchSpec |
		aDispatchSpec setSelector = aSelector
			ifTrue: [ ^aDispatchSpec name ] ].
	^nil! 
invokePut_Bold: boolean
        " Private - invoke the  IFont::put_Bold function for an external caller. "

	"STDMETHOD(put_Bold)(THIS_ BOOL bold) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchPut_Bold: boolean.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!
dispatchGet_Underline: resultReference
		" Private - dispatch the IFont::get_Underline function. "

	^(functionHandlers at: 12) evaluateWithArguments: (Array
		with: resultReference)!   
propertyNameFromGetSelector: aSelector
		" Answer the name of the control property which is obtained when the
		message <aSelector> is dispatched to the receiver's control.
		Answer nil if the selector is not a property get selector. "

	self propertyDispatcher specificationsDo:
		[ :aDispatchSpec |
		aDispatchSpec getSelector = aSelector
			ifTrue: [ ^aDispatchSpec name ] ].
	^nil!
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #POINTF.!
getEventTypeInfoFromClassTypeInfo: typeInfoControlClass
		" Get the ITypeInfo of the event interface
		of the control class whose type information is
		provided by <typeInfoControlClass>. "

	| typeAttrControlClass typeCount index implTypeFlags refType 
	  typeInfoEvents |

	typeAttrControlClass := typeInfoControlClass getTypeAttr.
	( typeAttrControlClass == nil
	or: [ typeAttrControlClass typekind ~= TKIND_COCLASS ] )
		ifTrue: [ ^nil ].
	
	[
	typeCount := typeAttrControlClass typeCount.
	index := 0.
	[ index < typeCount ] 
		whileTrue: [   " enumerate the control's types to find the primary event set "
			implTypeFlags := typeInfoControlClass getImplTypeFlags: index.
			( ( implTypeFlags & IMPLTYPEFLAG_FSOURCE ) = IMPLTYPEFLAG_FSOURCE
			and: [ ( refType := typeInfoControlClass getRefTypeOfImplType: index ) ~~ nil ] )
				ifTrue: [
					( implTypeFlags bitAnd: IMPLTYPEFLAG_FDEFAULT ) = IMPLTYPEFLAG_FDEFAULT
						ifTrue: [  " explicitly identified default event set "
							typeInfoEvents notNil
								ifTrue: [ typeInfoEvents release ].
							typeInfoEvents := typeInfoControlClass getRefTypeInfo: refType.
							typeAttrControlClass release.
							^typeInfoEvents ].
					" by default, the first outgoing interface is assumed to be the primary event set "
					typeInfoEvents isNil
						ifTrue: [ typeInfoEvents := typeInfoControlClass getRefTypeInfo: refType ].
					].
			index := index + 1 ] 
	]
	ensure: [
		typeAttrControlClass release ].
	^typeInfoEvents!   
QueryTextMetrics: resultReference
        " Private - implement the IFont::QueryTextMetrics function. "

	resultReference value: self localFont physicalFont.
	^S_OK! 
insertLinkedFileObject: aFileName hMetaPict: hMetaPict
        " Insert the object specified by <aFileName> into the pane associated with
        the receiver. If <hMetaPict> contains a valid handle then display as an icon. "

	self error: 'not supportedt for an OLE control site'! 
defaultLocaleID
		" Private - answer the default locale ID. "

	self ISSUE.  " This doesn't work on Win32S 1.3 or NT 3.5.1; what about Win95? [DL 21-Oct-95] "
	^[  OLENLSDLL current GetUserDefaultLCID ]
		on: Error
		do: [ ^STDOLE_LCID ]!  
controlPropertyGetSelectors
		"Answer the names of the messages that can be sent to the OCX control
		to get the value of a supported property."

	| names aSelector |
	self propertyDispatcher isNil
		ifTrue: [ ^#( ) ].
	names := OrderedCollection new.
	self propertyDispatcher specificationsDo:
		[ :aDispatchSpec |
		( aSelector := aDispatchSpec getSelector ) ~~ nil
			ifTrue: [ names add: aSelector ] ].
	^names!   
invokeGet_Weight: pweight
        " Private - invoke the IFont::get_Weight function for an external caller. "

    "STDMETHOD(get_Weight)(THIS_ short FAR* pweight) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pweight isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Weight: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self shortResultAtAddress: pweight put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
get_Bold: resultReference
        " Invoke the IFont::get_Bold function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Bold: resultReference)!
ambientPropertyChanged: propertyName
		" Notify the control that the ambient property named <propertyName> has changed.
		The property name may be nil, indicating that some unspecified set of properties
		has changed. "

	| anIOleControl |
	self oleObject == nil
		ifTrue: [ ^self ].
	anIOleControl := self oleObject queryInterface: IID_IOleControl.
	anIOleControl onAmbientPropertyChange:
		( self ambientPropertyDISPIDFromName: propertyName ).
	anIOleControl release.! 
TransformCoords: pointL _: pointF _: flags
        " Private - implement the IOleControlSite::TransfromCoordsl function.
		Transform coordinates. <pointL> is a POINTL struct (implemented as WinPoint).
		<pointF> is a POINTF struct. <flags> controls the transformation. "

    | transformedPoint |
	" This is an unusual function in that either point can be input or output,
		depending on the transformation being invoked. "
    ( flags bitAnd: XFORMCOORDS_CONTAINERTOHIMETRIC ) = XFORMCOORDS_CONTAINERTOHIMETRIC
        ifTrue: [
            transformedPoint := self class pointInHimetricToPixels: pointF.
            pointL 
				x: transformedPoint x rounded;
            	y: transformedPoint y rounded.
            ^S_OK ].
    ( flags bitAnd: XFORMCOORDS_HIMETRICTOCONTAINER ) = XFORMCOORDS_HIMETRICTOCONTAINER
        ifTrue: [
            transformedPoint := self class pointInPixelsToHimetric: pointL.
            pointF 
				x: transformedPoint x asFloat;
            	y: transformedPoint y asFloat.
            ^S_OK ].
    ^E_NOTIMPL  " position and size transformations not supported "!
isUIDead
		"Answer true if the UI is dead or locked, false if in normal mode."

	^false!   
createIDispatch
		" Private - create an IDispatch interface on the receiver. "

	^super createIDispatch
		iid: IID_IFontDisp;
		yourself!
insertControlIntoClientSite: aControlSite
        " Private - allow the user to invoke the Choose control dialog
        to insert an OLE control into <aControlSite>. "

	| clsid |

    clsid := OLEControlChoiceDialog new
        title: 'Insert OLE Control';
        open.
    clsid isNil
        ifTrue: [ ^self ].  " user cancelled "

	[
	CursorManager execute
		changeFor: [ aControlSite insertEmbeddedObject: clsid ].
    ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Insert Control Problem' ].!
pszDocString

	^self addressAtOffset: 16!   
establishControlConnections
		" Private - Establish the connections for invoking the control's interface
        members (methods and properties) and receiving its event notifications. "

	self 
		establishEventSink;
		initializeDispatchBindings.! 
ambientPropertyNameFromDISPID: dispid
	"Private"
	"Answer the name of the ambient property whose DISPID is <dispid>."

	AmbientPropertyNames
		keysAndValuesDo:
			[ :key :value |
			value = dispid
				ifTrue: [ ^key ] ].
	^DISPID_UNKNOWN!   
get_hFont: resultReference
        " Invoke the IFont::get_hFont function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_hFont: resultReference)! 
doubleClickedControlSite: aControlSitePane
        " Private - the control site <aControlSitePane> has been doulble-clicked by the user.
        Set the input focus and open the control's property dialog. 
        Note that double-click is received by the container only if it
        puts the control into edit mode and disables the control. "

    self selectedClientSite: aControlSitePane.
    aControlSitePane siteObject isValid
        ifTrue: [
            self activateClientSite: aControlSitePane siteObject
                objectVerb: OLEIVERB_PROPERTIES ].
!   
createStorageBackingStore
        " Private - Answer a new stream backing store for the receiver. "

    ^self usesMemoryBackingStore
        ifTrue: [ OLEGlobalMemoryStorage createTemporaryStorage ]
        ifFalse: [ self docFileStorage newStorage: self name ].! 
getAmbFont: variant
    "Private"

    | font |

	self supportsAmbientFont
		ifFalse: [ ^E_NOTIMPL ].

    ( font := self sitePane font ) == nil
        ifTrue: [ font := self sitePane defaultFont ].
    font == nil
        ifTrue: [ ^DISP_E_MEMBERNOTFOUND ].
    "create an IFontDisp for the font"
    self ambientFont localFont: font.
    variant
        typeCode: VT_DISPATCH;
        value: self ambientFont dispatchInterface separateReference.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient font returned: ', font printString ].
    ^S_OK!
pszTitle

	^self addressAtOffset: 4!
put_Strikethrough: strikethrough
	" Private - implement the IFont::put_Strikethrough function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font strikeOut: strikethrough.
	self localFont: font.
	^S_OK!
OnFocus: aBoolean
        " Private - implement the IOleControlSite::OnFocus function.
		Notify the container that the control is taking focus if <aBoolean> is <true>,
		or that it is relenquishing focus if <false>. "

	aBoolean
		ifTrue: [ self sitePane gettingFocus ]
		ifFalse: [ self sitePane losingFocus ].
	^S_OK!   
name: aString
		"Set the receiver's name to <aString>."

	super name: aString.
	self ambientPropertyChanged: 'DisplayName'.!  
get_Size: resultReference
		" Private - implement the IFont::get_Size function. "

	resultReference value: self localFont pointSize.
	^S_OK!  
usesMemoryBackingStore
		" Private - answer whether the receiver should use a memory-based 
		backing store rather than a document file. "

	usesMemoryBackingStore isNil
		ifTrue: [ usesMemoryBackingStore := self docFileStorage isNil ].
	^usesMemoryBackingStore

!  
createAmbientFont
		" Private - create an ambient font for the control site. "

	self supportsAmbientFont
		ifFalse: [ ^self ].
	ambientFont := OLEFontObject new.
	"ambientFont setReadOnly: true."
	ambientFont addRef.! 
localeID: anInteger
		" Private - set the receiver's locale ID to <anInteger>. "

	localeID := anInteger.! 
flags

	^self dwFlags!  
propertyDispatcher
	"Private"
	"Answer the property dispatcher of the receiver."

	^propertyDispatcher!   
invokeGet_Strikethrough: pstrikethrough
        " Private - invoke the IFont::get_Strikethrough function for an external caller. "

    "STDMETHOD(get_Strikethrough)(THIS_ BOOL FAR* pstrikethrough) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pstrikethrough isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Strikethrough: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self booleanResultAtAddress: pstrikethrough put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
eventSink: anIDispatch
    "Private"
    "Set the receiver's event sink to be <anIDispatch>."

    eventSink := anIDispatch!  
getProperty: propertyName
		" Answer the value of the control property named <propertyName>."

	self propertyDispatcher isNil
		ifTrue: [ ^nil ].
	^self propertyDispatcher getProperty: propertyName!   
cb

	^self uLongAtOffset: 0!
put_Italic: italic
	" Private - implement the IFont::put_Italic function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font italic: italic.
	self localFont: font.
	^S_OK!   
ambientPropertyIndexToID: index
	"Private"
	"Translate <index> to a DISPID of an ambient property."

	^(index + 700) negated! 
copyFont
		" Private - answer a copy of the receiver's font. "

	| font newFont |
	font := self localFont.
	newFont := font class new.
	newFont
		faceName: font faceName;
		pointSize: font pointSize;
		fixedWidth: font fixedWidth;
		bold: font bold;
		italic: font italic;
		strikeOut: font strikeOut;
		underscore: font underscore.
	^newFont! 
get_Underline: resultReference
        " Invoke the IFont::get_Underline function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Underline: resultReference)! 
pszHelpFile

	^self addressAtOffset: 20!
sizeInBytes
		"Answer the size in bytes of instances of the receiver."

	^14!  
validateHandler: aHandler for: eptDescription
        " Private - validate the function handler <aHandler> which
        has been registered for the interface function described
        by <eptDescription>. "

    ( #( 'put_Size' ) includes: eptDescription name )
        ifFalse: [ ^super validateHandler: aHandler for: eptDescription ].

    " special guys with #structValue arg splitup for POINTL "
    ( aHandler isMessage
    and: [ ( Message numberOfArgumentsFor: aHandler selector ) ~= ( eptDescription argumentTypes size - 1 ) ] )
        ifTrue: [
            MessageBox warning:
                self name,
                ' VTable handlers problems: argument count mismatch for ',
                eptDescription name ].! 
asPoint
	"Answer the receiver as a Point."

	^self x @ self y! 
ambientPropertyIDToIndex: dispid
	"Private"
	"Translate <dispid> to an index into the ambient property lists."

	^dispid negated - 700!   
invokeGet_Charset: pcharset
        " Private - invoke the IFont::get_Charset function for an external caller. "

    "STDMETHOD(get_Charset)(THIS_ short FAR* pcharset) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pcharset isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Charset: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self shortResultAtAddress: pcharset put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
hasControlPropertyGetSelector: aSelector
		" Answer whether the the message <aSelector> can be dispatched
		to the receiver's control to get the value of a property. "

	self propertyDispatcher isNil
		ifTrue: [ ^false ].
	self propertyDispatcher specificationsDo:
		[ :aDispatchSpec |
		aDispatchSpec getSelector = aSelector
			ifTrue: [ ^true ] ].
	^false!  
invokePut_Weight: value
        " Private - invoke the  IFont::put_Weight function for an external caller. "

	"STDMETHOD(put_Weight)(THIS_ short weight) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchPut_Weight: value.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult! 
get_Bold: resultReference
        " Private - implement the IFont::get_Bold function. "

	resultReference value: self localFont bold.
	^S_OK! 
dwHelpContext

	^self uLongAtOffset: 24!
IsEqual: otherFont
        " Invoke the IFont::IsEqual function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchIsEqual: otherFont)!   
dispatchGet_Name: resultReference
		" Private - dispatch the IFont::get_Name function. "

	^(functionHandlers at: 4) evaluateWithArguments: (Array
		with: resultReference)!  
dwFlags
		" Private - Answer the CONTROLINFO flags. "

	^self uLongAtOffset: 10
! 
get_Underline: resultReference
		" Private - implement the IFont::get_Underline function. "

	resultReference value: self localFont underscore.
	^S_OK!   
dispatchQueryTextMetrics: resultReference
        " Private - dispatch the IFont::QueryTextMetrics function. "

	^(functionHandlers at: 24) evaluateWithArguments: (Array
		with: resultReference)!   
initialize
	"Private - initialize the receiver."

	super initialize.
	self setReadOnly: false.!   
get_Italic: resultReference
		" Private - implement the IFont::get_Italic function. "

	resultReference value: self localFont italic.
	^S_OK! 
getAmbUserMode: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: self isInEditMode not.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient user mode returned: ', variant value printString ].
    ^S_OK!  
editControlProperties: aControlSite
		" Private - edit the control properties of <aControlSite>. "

	aControlSite editProperties.! 
openBackingStore
        " Private - Open the backing store for the receiver. "

	self error: 'demand-open of backing store not supported for a control site'! 
releaseResources
        " Private - release resources associated with the receiver. "

	self
		releasePropertyDispatcher;
		releaseMethodDispatcher.
    super releaseResources.
!
get_Strikethrough: resultReference
        " Invoke the IFont::get_Strikethrough function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Strikethrough: resultReference)! 
releaseEventSink
        " Private - release the event notification connections. "

	self eventSink notNil
		ifTrue: [
			self eventSink 
				releaseConnection;
				release.  " decrement the artifical ref count "
			"self ASSERT: eventSink referenceCount = 0."
			self eventSink: nil ].!  
localeID
		" Answer the receiver's locale ID. "

	^localeID!   
Clone: resultReference
        " Invoke the IFont::Clone function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchClone: resultReference)! 
initialize
	"Private - initialize the receiver."

	super initialize.
	self
		localeID: self defaultLocaleID;
		createAmbientFont.!  
deactivateInPlaceObject
	"Deactive the in place object."

	inPlaceObject == nil
		ifTrue: [^self].
	inPlaceObject uiDeactivate.! 
eventSink
    "Private"
    "Answer the event sink of the receiver."

    ^eventSink! 
x
	"Answer the x coordinate of the point."

	^self singleFloatAtOffset: 0! 
ambientPropertyChanged
		" Notify the control that some ambient property has changed. "

	self ambientPropertyChanged: nil!
put_Charset: charset
	" Private - implement the IFont::put_Charset function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font charSet: charset.
	self localFont: font.
	^S_OK!  
singleFloatAtOffset: offset
	"Answer a Float that represents the single-precision float value at offset <offset>."

	^self class internalFloatFromExternalFloat: ( self bytesAtOffset: offset count: 4 )!  
getAmbMessageReflect: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: self reflectsMessagesToControl.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient message reflect returned: ', variant value printString ].
    ^S_OK! 
dispatchPut_Name: name
		" Private - dispatch the IFont::put_Name function. "

	^(functionHandlers at: 5) evaluateWithArguments: (Array
		with: name)!
connectObjectToSite: hMetaPict
		" Private - connect the OLE control to its containing site. "

	| specialControlBehavior |

    self registerForViewNotification.
    self oleObject isStaticObject
        ifFalse: [
            self registerForOLENotification.
            self setObjectName ].
    self oleObject setContainedObject. 

    self establishControlConnections.
    specialControlBehavior := self specialControlBehavior.
    self sitePane controlIsPushButton: ( specialControlBehavior == #button ).

    self ISSUE.  " What is to be done here? [DL 21-Oct-95] "
    "self installControlAccelerators."

    self isInEditMode
        ifTrue: [ self disableControlWindows ].
	self setIsValid.!
invokeGet_Size: psize
        " Private - invoke the IFont::get_Size function for an external caller. "

    "STDMETHOD(get_Size)(THIS_ CY FAR* psize) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    psize isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Size: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [
            ( self structureAtAddress: psize type: 'CURRENCY' )
                value: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
releaseAmbientFont
		" Private - release the ambient font associated with the site. "

	ambientFont notNil
		ifTrue: [
			ambientFont release.
			ambientFont := nil ]. !   
openStreamBackingStore
        " Private - Open the stream backing store for the receiver. "

    ^self usesMemoryBackingStore
        ifTrue: [  " someone must provide the saved state in this case "
            "OLEGlobalMemoryStream on: self savedStateBytes...."
            self implementedBySubclass ]
        ifFalse: [ self docFileStorage openStream: self name ].! 
invokeQueryTextMetrics: lptm
        " Private - invoke the IFont::QueryTextMetrics function for an external caller. "

    "STDMETHOD(QueryTextMetrics)(THIS_ LPTEXTMETRICOLE lptm) PURE"

    | hresult resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    lptm isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultStructureAtAddress: lptm
        type: WinTextMetrics.
    resultReference := nil asValueReference.
    hresult := self dispatchQueryTextMetrics: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self structureResultAtAddress: lptm put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
getAmbForeColor: variant
    "Private"

    | color |
    ( color := self sitePane foreColor ) == nil
        ifTrue: [ color := self sitePane defaultForeColor ].
    color == nil
        ifTrue: [ ^DISP_E_MEMBERNOTFOUND ].
    variant
        typeCode: VT_COLOR;
        value: color asInteger.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient fore color returned: ', color printString ].
    ^S_OK!
releaseInnerObjects
		" Private - release any inner objects owned by the receiver. "

	self 
		releaseAmbientFont;
		releaseEventSink.!  
onMnemonic: msgPtr
		" A mnemonic, identified by <msgPtr>, was typed. Inform the control. "

    ^interface OnMnemonic: msgPtr!
getControlInfo
		" Answer the CONTROLINFO struct from the control. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetControlInfo: resultReference.
    ^resultReference value!   
freezeEvents: aBoolean
		" Suspend event processing if <aBoolean> is <true>. Resume if <false>. "

    ^interface FreezeEvents: aBoolean!  
onAmbientPropertyChange: dispid
		" Some ambient property, identified by <dispid>, of the container has changed.
		Inform the control.  <dispid> may be -1 to signify that an unspecified set of properties has changed. "

    ^interface OnAmbientPropertyChange: dispid!   
selectedControlSite: aControlSitePane
        " Private - the control site <aControlSitePane> has been selected by the user.
        Set the input focus and provide selection feedback. "

    self activeSite: aControlSitePane siteObject.!
canPasteFrom: anIDataObject
        " Answer whether <anIDataObject> can be pasted into the pane associated with the receiver. 
		Pasting is not supported in a control site. "

    ^false!  
releaseMethodDispatcher
        " Private - release the MethodDispatcher used by the receiver. "

    | aDispatcher |
    methodDispatcher notNil
        ifTrue: [
            aDispatcher := methodDispatcher.
            methodDispatcher := nil.
            aDispatcher release ].
!   
dispatchGet_Bold: resultReference
		" Private - dispatch the IFont::get_Bold function. "

	^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
		with: resultReference )!  
insertEmbeddedFileObject: aFileName hMetaPict: hMetaPict
        " Insert the object specified by <aFileName> into the pane associated with
        the receiver. If <hMetaPict> contains a valid handle then display as an icon. "

	self error: 'not supportedt for an OLE control site'!   
getProperty: propertyName ifAbsent: aBlock
		" Answer the value of the control property named <propertyName>.
		Answer the result of evalaution <aBlock> if the property is not supported. "

	^( self hasControlProperty: propertyName)
		ifTrue: [ self propertyDispatcher getProperty: propertyName ]
		ifFalse: [ aBlock value ]!   
get_Charset: resultReference
        " Invoke the IFont::get_Charset function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Charset: resultReference)!   
OnMnemonic: msgPtr
        " Invoke the IOleControl::OnMnemonic function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeOnMnemonic: msgPtr asParameter!  
invokeGetControlInfo: pCI
        " Private - invoke the IOleControl::GetControlInfo function."

	"STDMETHOD(GetControlInfo)(THIS_ LPCONTROLINFO pCI) PURE;"

	<ole: 3 structOut hresult>
	^self vtableDispatchFailed!  
invokeOnAmbientPropertyChange: dispid
        " Private - invoke the IOleControl::OnAmbientPropertyChange function."

	"STDMETHOD(OnAmbientPropertyChange)(THIS_ DISPID dispid) PURE;"

	<ole: 5 long hresult>
	^self vtableDispatchFailed! 
FreezeEvents: aBoolean
        " Invoke the IOleControl::FreezeEvents function.
        Raise an exception if an error occurs.  Answer the result code. "

    "STDMETHOD(FreezeEvents)(THIS_ BOOL bFreeze) PURE;"

    <ole: 6 boolean hresult>
    ^self vtableDispatchFailed!   
OnAmbientPropertyChange: dispid
        " Invoke the IOleControl::OnAmbientPropertyChange function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeOnAmbientPropertyChange: dispid asParameter!   
invokeOnMnemonic: pMsg
        " Private - invoke the IOleControl::OnMnemonic function."

	"STDMETHOD(OnMnemonic)(THIS_ LPMSG pMsg) PURE;"

	<ole: 4 structOut hresult>
	^self vtableDispatchFailed!
GetControlInfo: resultReference
        " Invoke the IOleControl::GetControlInfo function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEStructure forReturnValue: #CONTROLINFO.
    hresult := self invokeGetControlInfo: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!  
getProperty: propertyName withArguments: argValuesArray
        "Answer the value of the control's property named <propertyName>.
        <argValuesArray> is the Array of argument values for a parameterized property. "

	self propertyDispatcher isNil
		ifTrue: [ ^nil ].
	^self propertyDispatcher getProperty: propertyName withArguments: argValuesArray!   
methodDispatcher: anOLEDispatcher
	"Private"
	"Set the receiver's method dispatcher to be <anOLEDispatcher>."

	methodDispatcher := anOLEDispatcher!  
releasePropertyDispatcher
        " Private - release the PropertyDispatcher used by the receiver. "

    | aDispatcher |
    propertyDispatcher notNil
        ifTrue: [
            aDispatcher := propertyDispatcher.
            propertyDispatcher := nil.
            aDispatcher release ].!   
invokeReleaseHfont: hfont
        " Private - invoke the  IFont::ReleaseHfont function for an external caller. "

	"STDMETHOD(ReleaseHfont)(THIS_ HFONT hfont) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchReleaseHfont: hfont.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!  
sizeInBytes
		"Answer the size in bytes of instances of the receiver."

	^28!  
GetExtendedControl: resultReference
        " Private - implement the IOleControlSite::GetExtendedControl function.
		Retrieve the extended control IDispatch interface from the container.
		Place it into <resultReference>. "

	^self unimplementedFunction!  
getAmbAutoClip: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: false.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient auto clip returned: ', variant value printString ].
    ^S_OK!  
put_Weight: weight
        " Invoke the IFont::put_Weight function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Weight: weight)!
ambientFont
	"Private"
	"Answer the ambient font of the receiver."

	^ambientFont!
SetRatio: chLogical _: cyHimetric
        " Private - implement the IFont::SetRatio function. "

	^S_OK!   
invokePut_Italic: boolean
        " Private - invoke the  IFont::put_Italic function for an external caller. "

	"STDMETHOD(put_Italic)(THIS_ BOOL italic) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchPut_Italic: boolean.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!  
invokeGet_Italic: pitalic
        " Private - invoke the IFont::get_Italic function for an external caller. "

    "STDMETHOD(get_Italic)(THIS_ BOOL FAR* pitalic) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pitalic isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Italic: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self booleanResultAtAddress: pitalic put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
put_Bold: bold
        " Invoke the IFont::put_Bold function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Bold: bold)!  
sizeChanged
		" Private - notify the receiver that its size has changed. "

	inPlaceObject == nil
		ifTrue: [ ^self ].
	self setInPlaceObjectRectangle.! 
controlCLSID: aCLSID
		"Set the CLSID that identifies the class iid of the receiver's OCX to <aCLSID>."

	controlCLSID := aCLSID.! 
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass fields: #( #x #y ) conversions: #( #asPoint )!  
forFont: aFont
		" Answer a new instance of the receiver for <aFont>. "

	^self new localFont: aFont!  
dispatchGet_Size: resultReference
		" Private - dispatch the IFont::get_Size function. "

	^(functionHandlers at: 6) evaluateWithArguments: (Array
		with: resultReference)!  
get_Size: resultReference
        " Invoke the IFont::get_Size function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Size: resultReference)!
controlMethodSelectors
		"Answer the names of the messages that can be sent to the OCX control
		to invoke methods."

	^self methodDispatcher isNil
		ifTrue: [ #( ) ]
		ifFalse: [ self methodDispatcher specificationNames ]! 
cAccel
		" Private - Answer the number of entries in mnemonics table. "

	^self uShortAtOffset: 8
!   
Invoke: dispidMember
	_: iid
	_: lcid
	_: wFlags
	_: dispParams
	_: resultReference
	_: exceptionInfoReference
	_: argErrorReference
		" Private - implement the IFontDisp::Invoke function. "

	| id index |
	id := ( dispidMember = 0 
		ifTrue: [ 1 ] 
		ifFalse: [ dispidMember ] ).
	wFlags = DISPATCH_PROPERTYGET
		ifTrue: [
			index := id * 2 - 1.
			resultReference typeCode: ( FontDispatchTypes at: id ).
			self perform: ( FontDispatchTable at: index ) with: resultReference.
			^S_OK ].
	wFlags = DISPATCH_PROPERTYPUT
		ifTrue: [
			index := id * 2.
			self perform: ( FontDispatchTable at: index ) 
				with: ( self valueAdaptor argumentsForMethod: nil 
					parameters: dispParams
					localeID: lcid ).
			^S_OK ].
	^self unimplementedFunction!   
specialControlBehavior
		" Private - answer the name of the special behavior supported
		by the control, if any. "

    | statusBits |
    statusBits := OLERegistryInterface getMiscStatus: self controlCLSID.
    0 ~= ( statusBits bitAnd: OLEMISC_ACTSLIKEBUTTON )
        ifTrue: [ ^#button ].
    0 ~= ( statusBits bitAnd: OLEMISC_ACTSLIKELABEL )
        ifTrue: [ ^#label ].
    ^nil!   
booleanResultAtAddress: anExternalAddress put: aBoolean
		" Private - store the BOOLEAN output argument value <aBoolean> 
		into the caller-provided memory location addressed at <anExternalAddress>. "

	aBoolean isNil ifTrue: [ ^self ].
	self ISSUE. "windef.h has this typedef
			typedef int BOOL;
		Unless they have some radical compiler options that are always on,
		BOOL is 32 bits. Test case: open the font setting dialog from the
		property page of the threed checkbox. I get all boolean values set
		to true without this method. With it, only bold is true (which is correct).
		[Steve 10-Nov-95] "
	( ExternalBuffer atAddress: anExternalAddress ) 
		longAtOffset: 0 
		put: aBoolean asParameter!   
OnRequestEdit: dispid
        " Private - implement the IPropertyNotifySink::OnRequestEdit function.
		The property identified by <dispid> is about to change. Inform event handlers.
		<dispid> may be -1 to indicate an unspecified set of properties is about the change. 
		Return S_FALSE to veto the change."

	^( self sitePane aboutToChangeProperty: ( self propertyNameFromDISPID: dispid ) )
		ifTrue: [ S_OK ]
		ifFalse: [ S_FALSE ]!
dispatchPut_Bold: bold
		" Private - dispatch the IFont::put_Bold function. "

	^(functionHandlers at: 9) evaluateWithArguments: (Array
		with: bold)!
invokePut_Charset: value
        " Private - invoke the  IFont::put_Charset function for an external caller. "

	"STDMETHOD(put_Charset)(THIS_ short charset) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchPut_Charset: value.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!
TranslateAccelerator: msgPointer _: modifiers
        " Invoke the IOleControlSite::translateAccelerator function.
        Raise an exception if an error occurs.  Answer the result code. "

	^self invokeTranslateAccelerator: msgPointer asParameter
		_: modifiers!  
TransformCoords: pointL _: pointF _: flags
        " Invoke the IOleControlSite::TransformCoords function.
        Raise an exception if an error occurs.  Answer the result code. "

	" This is an unusual function in that either point can be input or output,
		depending on the transformation being invoked.  The responsibility
		is therefore on the caller in this case to provide suitable arguments. "
	| pointLArg pointFArg hresult |
	pointLArg := WinPoint fromPoint: pointL.
	pointFArg := ( OLEStructure classForStructureNamed: #POINTF ) fromPoint: pointF.
	hresult := self invokeTransformCoords: pointLArg
		_: pointFArg
		_: flags.
	pointL
		x: pointLArg x;
		y: pointLArg y.
	pointF
		x: pointFArg x;
		y: pointFArg y.
	^hresult! 
LockInPlaceActive: fLock
        " Invoke the IOleControlSite::LockInPlaceActive function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(LockInPlaceActive)(THIS_ BOOL fLock) PURE"

	<ole: 4 boolean hresult>
	^self vtableDispatchFailed!   
OnControlInfoChanged
        " Invoke the IOleControlSite::OnControlInfoChanged function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(OnControlInfoChanged)(THIS) PURE"

	<ole: 3 hresult>
	^self vtableDispatchFailed! 
invokeTransformCoords: pointLPointer _: pointFPointer _: flags
        " Private - invoke the IOleControlSite::TransformCoords function."

	"STDMETHOD(TransformCoords)(THIS_ POINTL FAR* lpptlHimetric,
		POINTF FAR* lpptfContainer, DWORD flags) PURE"

	<ole: 6 struct struct ulong hresult>
	^self vtableDispatchFailed!  
ShowPropertyFrame
        " Invoke the IOleControlSite::ShowPropertyFrame function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(ShowPropertyFrame)(THIS) PURE"

	<ole: 9 hresult>
	^self vtableDispatchFailed!  
GetExtendedControl: resultReference
        " Invoke the IOleControlSite::GetExtendedControl function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IDispatchPointer forReturnValue.
	hresult := self invokeGetExtendedControl: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
OnFocus: fGotFocus
        " Invoke the IOleControlSite::OnFocus function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(OnFocus)(THIS_ BOOL fGotFocus) PURE"

	<ole: 8 boolean hresult>
	^self vtableDispatchFailed! 
invokeGetExtendedControl: ppDisp
        " Private - invoke the IOleControlSite::GetExtendedControl function."

	"STDMETHOD(GetExtendedControl)(THIS_ LPDISPATCH FAR* ppDisp) PURE"

	<ole: 5 structOut hresult>
	^self vtableDispatchFailed!   
invokeTranslateAccelerator: msgPointer _: modifiers
        " Private - invoke the IOleControlSite::TranslateAccelerator function."

	"STDMETHOD(TranslateAccelerator)(THIS_ LPMSG lpMsg, 
		DWORD grfModifiers) PURE"

	<ole: 7 structIn ulong hresult>
	^self vtableDispatchFailed!  
usesMemoryBackingStore: aBoolean
		" Private - specify whether the receiver should use a memory-based 
		backing store rather than a document file. "

	usesMemoryBackingStore := aBoolean.

!  
Clone: resultReference
        " Private - implement the IFont::Clone function. "

	resultReference value: ( self queryInterface: IID_IFont ).
	^S_OK!
clearContent
        " Private - clear the content of the site associated with the receiver. "

    self isEmpty
        ifTrue: [^self].
    super clearContent.
    self releaseControlConnections.!  
hasControlProperty: aPropertyName
		" Answer whether the property identified by <aPropertyName>
		is supported by the control. "

	^self propertyDispatcher notNil
		and: [ self propertyDispatcher hasSpecificationNamed: aPropertyName ]!  
get_Italic: resultReference
        " Invoke the IFont::get_Italic function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchGet_Italic: resultReference)!  
tableSize

	^self cAccel!   
isReadOnly
		" Answer whether the font which the receiver represents is read-only. "

	^readOnly!  
put_Bold: bold
	" Private - implement the IFont::put_Bold function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font bold: bold.
	self localFont: font.
	^S_OK! 
getAmbTextAlign: variant
    "Private"

    variant
        typeCode: VT_I2;
        value: self sitePane textAlignmentIndex.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient text align returned: ', variant value printString ].
    ^S_OK!   
pasteLinkedObject: anIDataObject
        " Paste the link to the object specified by <anIDataObject> into the pane
         associated with the receiver."

	self error: 'not supportedt for an OLE control site'!
dispatchOnChanged: dispid
		" Private - dispatch the IPropertyNotifySink::OnChanged function. "

	^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
		with: dispid )!
invokeOnChanged: dispid
        " Private - invoke the IPropertyNotifySink:OnChanged function for an external caller. "

	"STDMETHOD(OnChanged)(THIS_ DISPID dispid) PURE"

    | hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnChanged: dispid.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!   
OnChanged: dispid
		" Invoke the IPropertyNotifySink::OnChanged function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		(self dispatchOnChanged: dispid)! 
OnRequestEdit: dispid
		" Invoke the IPropertyNotifySink::OnRequestEdit function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self checkHresult: 
		(self dispatchOnRequestEdit: dispid)! 
dispatchOnRequestEdit: dispid
		" Private - dispatch the IPropertyNotifySink::OnRequestEdit function. "

	^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
		with: dispid )!
invokeOnRequestEdit: dispid
        " Private - invoke the IPropertyNotifySink:OnRequestEdit function for an external caller. "

	"STDMETHOD(OnRequestEdit)(THIS_ DISPID dispid) PURE"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnRequestEdit: dispid.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!  
put_Charset: charset
        " Invoke the IFont::put_CharSet function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Charset: charset)!   
getAmbDisplayName: variant
    "Private"

    | displayName |
    displayName := self name.
    displayName == nil
        ifTrue: [ ^DISP_E_MEMBERNOTFOUND ].
    variant
        typeCode: VT_BSTR;
        value: displayName asString.
    self ifOLETraceEnabled: [
        self oleTRACE: '    Get ambient display name returned: ', variant value printString ].
    ^S_OK!
establishEventSink
		" Private - establish the event sink connection to the control 
		to receive its event notifications. "

	| anEventSink |
	anEventSink := self createEventSink.
	anEventSink isNil
		ifTrue: [ ^self ].  " no events "
	anEventSink when: #eventNotification:arguments:
		send: #triggerControlEvent:withArguments:
		to: self sitePane.
	anEventSink addRef.  " artificially ref count the contained object "
	"self ASSERT: anEventSink referenceCount = 1."
	anEventSink establishConnectionTo: self oleObject.
	self eventSink: anEventSink.
!
x: aFloat
	"Set the x coordinate of the point."

	self singleFloatAtOffset: 0 put: aFloat! 
unregisterServer: aPathName
		" Unregister the OLE control(s) in the DLL <aPathName>. "

	| dllHandle |
	( self isSelfRegisteringServer: aPathName )
		ifFalse: [ ^self error: 'not a self-registering OLE control' ].
	[ dllHandle := self open: aPathName ]
		on: Error do: [ ^self error: 'Unable to open ', aPathName ].
	[ dllHandle dllUnregisterServer ]
		ensure: [ dllHandle close ].!  
registerServer: aPathName
		" Register the OLE control(s) in the DLL <aPathName>. "

	| dllHandle |
	( self isSelfRegisteringServer: aPathName )
		ifFalse: [ ^self error: 'not a self-registering OLE control' ].
	[ dllHandle := self open: aPathName ]
		on: Error do: [ ^self error: 'Unable to open ', aPathName ].
	[ dllHandle dllRegisterServer ]
		ensure: [ dllHandle close ].!
isSelfRegisteringServer: aPathName
		" Answer whether the DLL specified by <aPathName>
		is a self-registering OLE control library. "

	"Implementation note:  We simply assume that all OLE controls
		conform to the CDK specification and are self-registering.
		If not, we find out when we attempt to load and register an OCX
		and discover that the self-registration entry point is not
		defined.  An alternate implementation would be to
		look for 'OLESelfRegister'  in the 'StringFileInfo' section 
		without actually loading the library. "
	^true! 
getAmbScaleUnits: variant
    "Private"

    variant
        typeCode: VT_BSTR;
        value: 'pixels'.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient scale units returned: ', variant value printString ].
    ^S_OK!   
ambGetIDsOfNames: riid _: nameList _: cNames _: lcid _: resultReference
	" Private - Implement the IDispatch::GetIDsOfNames function for the site's ambient properties.
	Get IDs of names for the ambient properties.
	Map a single member and an optional set of argument names into
	a corresponding set of DISPID's which can be used with IDispatch::Invoke.
	The first element is the DISPID of the member name; subsequent 
	elements represent each of the member's parameters.
	Answer the result code."

	| aName dispid result |
	aName := ( nameList at: 1 ) asLowercase.
	dispid := self ambientPropertyDISPIDFromName: aName.
	cNames = 1
		ifTrue: [result := Array with: dispid]
		ifFalse: [
			result := Array new: cNames.
			result atAllPut: DISPID_UNKNOWN.
			result at: 1 put: dispid.
			dispid := DISPID_UNKNOWN ].
	resultReference value: result.
	^dispid = DISPID_UNKNOWN
		ifTrue: [ DISP_E_UNKNOWNNAME ]
		ifFalse: [ S_OK ]!
dispatchPut_Size: size
		" Private - dispatch the IFont::put_Size function. "

	^(functionHandlers at: 7) evaluateWithArguments: (Array
		with: size)!
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	iFont notNil
		ifTrue: [ aOneArgBlock value: iFont ].!   
invokeAddRefHfont: hfont
        " Private - invoke the  IFont::AddRefHfont function for an external caller. "

	"STDMETHOD(AddRefHfont)(THIS_ HFONT hfont) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	self ISSUE.  " This needs to be wrapped into a handle or a Font. [DL 21-Oct-95] " 
	hresult := self dispatchAddRefHfont: hfont.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult! 
installControlAccelerators
		" Private - install the control's accelerator table "

	| iOleControl controlInfo |
	iOleControl := self oleObject queryInterface: IID_IOleControl.
	iOleControl == nil
		ifTrue: [ ^self ].
	[
	controlInfo := iOleControl getControlInfo.
	controlInfo hasAccelerators
		ifTrue: [
			self ISSUE.  " #controlAccelerators: is unimplemented - what should it be?? [DL 21-Sep-95] " 
			self sitePane controlAccelerators: controlInfo acceleratorTable ].
	] 
		ensure: [ iOleControl release ].!
ambientPropertyDISPIDFromName: propertyName
	"Private"
	"Answer the DISPID of the ambient property named <propertyName>."

	^AmbientPropertyNames at: propertyName ifAbsent: [ DISPID_UNKNOWN ]!  
controlEvents
		"Answer the names of the events that can be triggered by the OCX control."

	^self eventSink isNil
		ifTrue: [ #( ) ]
		ifFalse: [ self eventSink supportedEvents ]! 
transformCoords: aPoint flags: flags
		" Transform coordinates specified by <aPoint>.  <flags> controls the transformation. 
		Answer the transformed coordinates. "

	| transformedPoint |
	" This is an unusual function in that either point can be input or output,
		depending on the transformation being invoked.  The responsibility
		is therefore on the caller in this case to provide suitable arguments. "
	transformedPoint := Point new.
	flags = XFORMCOORDS_CONTAINERTOHIMETRIC
		ifTrue: [
			interface TransformCoords: transformedPoint
				_: aPoint
				_: flags ]
		ifFalse: [
			interface TransformCoords: aPoint
				_: transformedPoint
				_: flags ].
	^transformedPoint!  
lockInPlaceActive: aBoolean
		" The control needs to lock or unlock it's state to in-place active.
		Inform the container. <aBoolean> is <true> to lock, <false> to unlock. "

	^interface LockInPlaceActive: aBoolean!   
onControlInfoChanged
		" Something in the control's CONTROLINFO struct changed.
		Inform the container. "

	^interface OnControlInfoChanged!  
translateAccelerator: msgPointer flags: modifiers
		" Translate the keystroke accelerator for the control. "

	^interface TranslateAccelerator: msgPointer _: modifiers!   
showPropertyFrame
		" Show the property frame of the control. "

	^interface ShowPropertyFrame!
getExtendedControl
		" Retrieve the extended control IDispatch interface from the container.
		Place it into <resultReference>. "

	| resultReference |
	resultReference := IDispatch new asValueReference.
	interface GetExtendedControl: resultReference.
	^resultReference value!   
onFocus: aBoolean
		" Notify the container that the control is taking focus if <bool> is <true>,
		or that it is relenquishing focus if <false>. "

	^interface OnFocus: aBoolean!
supportsAmbientFont
		" Private - answer whether the ambient font property is supported. "

	" Disable due to unresolved interaction between the container's
		ambient font and apparent usage thereof by contained
		controls to maintain the state of their own font property.
		These are not the same thing, but attempting to enforce
		the distinction by making the ambient font readOnly
		does not seem to be sufficient. "
	^false!
createControlSitePaneIn: aWindow
    for: aContainerCoordinator
    name: aSiteName
    framing: aSizeSpecification
        " Private - create a new OLE control site pane in <aWindow>.
        Set the site pane's owner to <aContainerCoordinator> and its
        framing specification <aSizeSpecification>.
        Answer the control site pane. "

    | aSitePane |

    aSitePane := OLEControlSitePane new.
    self
        installSitePane: aSitePane
        in: aWindow
        for: aContainerCoordinator
        name: aSiteName
        framing: aSizeSpecification.

    aSitePane
        when: #clicked:
            send: #selectedControlSite: to: aContainerCoordinator with: aSitePane;
         when: #doubleClicked
            send: #doubleClickedControlSite: to: aContainerCoordinator with: aSitePane;
        yourself.
    ^aSitePane! 
deletePersistentState
        " Private - delete the persistent state of the receiver object from the backing storage. "

    self hasPersistentState ifFalse: [ ^self ].
    self releaseStorage.
    self docFileStorage
        destroyElement: self name;
        destroyElement: 'CLSID-', self name.
    self setContainerModified.!
getAmbDisplayAsDefaultButton: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: self sitePane isDefaultPushButton.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient display as default button returned: ', variant value printString ].
    ^S_OK!
dispatchReleaseHfont: fontHandle
        " Private - dispatch the IFont::ReleaseHfont function. "

	^(functionHandlers at: 26) evaluateWithArguments: (Array
		with: fontHandle)! 
put_Size: size
	" Private - implement the IFont::put_Size function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font pointSize: size asInteger.
	self localFont: font.
	^S_OK!  
saveStateChanges
        " Private - save the state of the control if its properties have been modified.
        Answer whether there were changes. "

    self isStateModified
        ifFalse: [ ^false ].

    self saveObject.
	^true!
createBackingStore
        " Private - Answer a new backing store for the receiver. "

	self error: 'demand-create of backing store not supported for a control site'! 
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iFont := nil.!  
OnChanged: dispid
        " Invoke the IPropertyNotifySink:OnChanged function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(OnChanged)(THIS_ DISPID dispid) PURE"

	<ole: 3 ulong hresult>
	^self vtableDispatchFailed!  
OnRequestEdit: dispid
        " Invoke the IPropertyNotifySink:OnRequestEdit function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(OnRequestEdit)(THIS_ DISPID dispid) PURE"

	<ole: 4 ulong hresult>
	^self vtableDispatchFailed!  
controlClassUserName
        " Answer the registered name of the control class.
        Answer nil if the site is not connected. "

    ^self controlCLSID isNil
		ifTrue: [ nil ]
		ifFalse: [ self class clsidUserName: self controlCLSID ]


!
dispatchPut_Italic: italic
		" Private - dispatch the IFont::put_Italic function. "

	^(functionHandlers at: 11) evaluateWithArguments: (Array with: italic)!  
hasAccelerators

	^self cAccel ~= 0!
AddRefHfont: hfont
        " Private - implement the IFont::AddRefHfont function. "

	self addRef.
	^S_OK!
loadObjectFromStorage
        " Load the receiver's object from its persistent storage."

    self hasPersistentState
        ifFalse: [ ^self ].

    self loadObject isNil
        ifTrue: [ ^self ].
    "self ASSERT: self controlCLSID notNil."

    self connectObjectToSite: nil.
    self activateObjectVerbShow.
!   
controlProperties
		"Answer the names of the properties supported by the OCX control."

	^self propertyDispatcher isNil
		ifTrue: [ #( ) ]
		ifFalse: [ self propertyDispatcher specificationNames ]!
put_Underline: underline
        " Invoke the IFont::put_Underline function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Underline: underline)! 
invokeMethod: aSelector withArguments: argValuesArray
		" Invoke the control method named <aMethodName> with the arguments 
		in <argValuesArray>.  Answer the result value (nil if none). "

	^self invokeMethod: aSelector 
		withArguments: argValuesArray 
		result: OLEDispatchValueReference new! 
y: aFloat
	"Set the y coordinate of the point."

	self singleFloatAtOffset: 4 put: aFloat! 
persistentStateIsStorage
		" Private - answer whether the persistent state of the receiver is an IStorage. "

	^self docFileStorage hasStorageNamed: self name!
onRequestEdit: dispid
		" The property identified by <dispid> is about to change.
		Inform event handlers. <dispid> may be -1 to indicate an unspecified
		set of properties is about the change. Return S_FALSE to veto the change."

	^interface OnRequestEdit: dispid!
onChanged: dispid
		" A property value, identified by <dispid>, has changed.
		Notify event handlers. <dispid> may be -1 to indicate that an
		unspecified set of properties has changed."

	^interface OnChanged: dispid!   
put_Size: size
        " Invoke the IFont::put_Size function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchPut_Size: size)!  
getClassTypeInfoOf: anInterface
		" Answer the control class ITypeInfo of the control supporting <anInterface>. "

	| anIProvideClassInfo anITypeInfo |
	anIProvideClassInfo := anInterface queryInterface: IID_IProvideClassInfo.
	anIProvideClassInfo isNil
		ifTrue: [ ^false ].
	anITypeInfo := anIProvideClassInfo getClassInfo.
	anIProvideClassInfo release.
	^anITypeInfo!   
ReleaseHfont: hfont
        " Private - implement the IFont::ReleaseHfonts function. "

	self release.
	^S_OK!
releaseControlConnections
        " Private - release all the connections with the control
		which were established to invoke its methods and receive
		event notifications. "

	self
		releaseEventSink;
		releasePropertyDispatcher;
		releaseMethodDispatcher.
	self controlCLSID: nil.!  
inspectorFields
    "Answer the names of the fields contained in the receiver definition; reimplemented by subclasses."

    ^self inspectorClass
        fields: #( #cb #cAccel #hAccel #dwFlags )!  
OnControlInfoChanged
        " Private - implement the IOleControlSite::OnControlInfoChanged function.
		Something in the control's CONTROLINFO struct changed. 
		Inform the container. "

	^self unimplementedFunction!
persistentStateIsStream
		" Private - answer whether the persistent state of the receiver is an IStream. "

	^self docFileStorage hasStreamNamed: self name!   
propertyDispatcher: anOLEDispatcher
	"Private"
	"Set the receiver's property dispatcher to be <anOLEDispatcher>."

	propertyDispatcher := anOLEDispatcher!
invokeSetRatio: cyLogical _: cyHimetric
        " Private - invoke the  IFont::SetRatio function for an external caller. "

	"STDMETHOD(SetRatio)(THIS_ long cyLogical, long cyHimetric) PURE"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchSetRatio: cyLogical _: cyHimetric.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!  
get_Weight: resultReference
		" Private - implement the IFont::get_Weight function. "

	resultReference value: self localFont physicalFont tmWeight.
	^S_OK!  
put_Underline: underline
	" Private - implement the put_Underline function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font underscore: underline.
	self localFont: font.
	^S_OK!  
y
	"Answer the y coordinate of the point."

	^self singleFloatAtOffset: 4! 
dllUnregisterServer
		" Unregister the OLE control(s) in the receiver in the system registry. "

	<api: DllUnregisterServer hresult>
    ^self apiCallFailed! 
dllRegisterServer
		" Register the OLE control(s) in the receiver in the system registry. "

	<api: DllRegisterServer hresult>
    ^self apiCallFailed!   
dispatchPut_Charset: charset
		" Private - dispatch the IFont::put_Charset function. "

	^(functionHandlers at: 19) evaluateWithArguments: (Array
		with: charset)!   
get_hFont: resultReference
		" Private - implement the IFont::get_hFont function. "

	resultReference value: self localFont fontHandle.
	^S_OK!   
getConnectionPointIIDFromEventTypeInfo: anITypeInfo
		" Answer the IID of the event connection point interface described by <anITypeInfo>. "

	| aTypeAttr connectionPointIID |
	aTypeAttr := anITypeInfo getTypeAttr.
	aTypeAttr notNil
		ifTrue: [
			connectionPointIID := aTypeAttr guid.
			aTypeAttr release ].
	^connectionPointIID!  
dispatchPut_Strikethrough: strikethrough
		" Private - dispatch the IFont::put_Strikethrough function. "

	^(functionHandlers at: 15) evaluateWithArguments: (Array
		with: strikethrough)!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #CONTROLINFO.!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #POINTF for: self.!
getAmbLocaleID: variant
    "Private"

    variant
        typeCode: VT_I4;
        value: self localeID.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient locale ID returned: ', variant value printString ].
    ^S_OK!
loadCLSID
		" Private - load the CLSID of the saved control from its backing. "

	| clsidStream |
	clsidStream := self docFileStorage openStream: 'CLSID-', self name.
	self controlCLSID: clsidStream readCLSID.
	clsidStream release.
	! 
getAmbShowGrabHandles: variant
    "Private"

    variant
        typeCode: VT_BOOL;
        value: self isInEditMode.
    self ifOLETraceEnabled: [
        self oleTRACE: 'Get ambient show grab handles returned: ', variant value printString ].
    ^S_OK!   
fileName
        "Answer the receiver's file name."

     ^'Ole2nls'!  
GetUserDefaultLCID
	"LCID GetUserDefaultLCID(void)"

	<api: GetUserDefaultLCID ulongReturn>
	^self apiCallFailed! 
getEventTypeInfoOf: anInterface
		" Get the ITypeInfo of the event interface
		of the control supporting <anInterface>. "

	| typeInfoControlClass typeInfoEvents |

	typeInfoControlClass := self getClassTypeInfoOf: anInterface.
	typeInfoControlClass isNil
		ifTrue: [ ^nil ].

	[
	typeInfoEvents := self getEventTypeInfoFromClassTypeInfo: typeInfoControlClass.
	]
	ensure: [
		typeInfoControlClass release ].
	^typeInfoEvents! 
dispatchGet_Charset: resultReference
		" Private - dispatch the IFont::get_Charset function. "

	^(functionHandlers at: 18) evaluateWithArguments: (Array
		with: resultReference)!   
dispatchAddRefHfont: fontHandle
		"Private - dispatch the IFont::AddRefHfont function. "

	^(functionHandlers at: 25) evaluateWithArguments: (Array with: fontHandle)! 
put_Name: name
	" Private - implement the IFont::put_Name: function. "

	| font |
	self isReadOnly
		ifTrue: [ ^E_NOTIMPL ].
	font := self copyFont.
	font faceName: name.
	self localFont: font.
	^S_OK!
QueryTextMetrics: resultReference
        " Invoke the IFont::QueryTextMetrics function.
        Raise an exception if an error occurs.  Answer the result code. "

    | hresult address |
    address := ExternalAddress new.
    hresult := self invokeClone: address.
    resultReference value: ( WinTextMetrics atAddress: address ).
    ^hresult! 
SetRatio: cyLogical _: cyHimetric
        " Invoke the IFont::SetRatio function.
        Raise an exception if an error occurs.  Answer the result code. "

    "STDMETHOD(SetRatio)(THIS_ long cyLogical, long cyHimetric) PURE"

    <ole: 22 long long hresult>
    ^self vtableDispatchFailed! 
ReleaseHfont: hfont
        " Invoke the IFont::ReleaseHfont function.
        Raise an exception if an error occurs.  Answer the result code. "

	^self invokeReleaseHfont: hfont asParameter!   
get_hFont: resultReference
        " Invoke the IFont::get_hFont function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 4.
	hresult := self invokeGet_hFont: resultValue.
	self ISSUE.  " How should this be turned into a Handle? 
		Or is this the right point to wrap an entire Font instance
		around this? [DL 21-Oct-95] " 
	resultReference value: ( resultValue uLongAtOffset: 0 ).
	^hresult!  
put_Name: name
        " Invoke the IFont::put_Name function.
        Raise an exception if an error occurs.  Answer the result code. "

	^self invokePut_Name: ( BSTR fromString: name )!
get_Charset: resultReference
        " Invoke the IFont::get_Charset function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeGet_Charset: resultValue.
	resultReference value: ( resultValue shortAtOffset: 0 ).
	^hresult!   
get_Underline: resultReference
        " Invoke the IFont::get_Underline function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeGet_Underline: resultValue.
	resultReference value: ( resultValue booleanAtOffset: 0 ).
	^hresult!   
invokeIsEqual: lpFontOther
		" Private - invoke the IFont::IsEqual function. "

	"STDMETHOD(IsEqual)(THIS_ IFont FAR * lpFontOther) PURE"

	<ole: 21 handle hresult>
	^self vtableDispatchFailed!   
invokeClone: lplpfont
		" Private - invoke the IFont::Clone function. "

	"STDMETHOD(Clone)(THIS_ IFont FAR* FAR* lplpfont) PURE"

	<ole: 20 structOut hresult>
	^self vtableDispatchFailed!
get_Bold: resultReference
		" Invoke the IFont::get_Bold function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeGet_Bold: resultValue.
	resultReference value: ( resultValue booleanAtOffset: 0 ).
	^hresult!  
Clone: resultReference
        " Invoke the IFont::Clone function.
        Raise an exception if an error occurs.  Answer the result code. "

    | interface hresult |
    interface := IFontPointer forReturnValue.
    hresult := self invokeClone: interface asParameter.
	resultReference value: interface.
    ^hresult!
put_Charset: charset
        " Invoke the IFont::put_CharSet function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(put_Charset)(THIS_ short charset) PURE"

	<ole: 18 short hresult>
	^self vtableDispatchFailed!   
put_Underline: underline
        " Invoke the IFont::put_Underline function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(put_Underline)(THIS_ BOOL underline) PURE"

	<ole: 12 boolean hresult>
	^self vtableDispatchFailed!
get_Size: resultReference
        " Invoke the IFont::get_Size function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	self ISSUE.  " Why the odd use of CURRENCY structure here?
		Why not simply use WinLargeInteger?  [DL 21-Oct-95] " 
    resultValue := OLEStructure forReturnValue: #CURRENCY.
    hresult := self invokeGet_Size: resultValue.
    self ISSUE. "Change to FixedDecimal when it is available"
    resultReference value: resultValue asFloat.
    ^hresult!   
get_Strikethrough: resultReference
        " Invoke the IFont::get_Strikethrough function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeGet_Strikethrough: resultValue.
	resultReference value: ( resultValue booleanAtOffset: 0 ).
	^hresult!   
IsEqual: otherFont
        " Invoke the IFont::IsEqual function.
        Raise an exception if an error occurs.  Answer the result code. "

	^self invokeIsEqual: otherFont asParameter!  
get_Italic: resultReference
        " Invoke the IFont::get_Italic function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeGet_Italic: resultValue.
	resultReference value: ( resultValue booleanAtOffset: 0 ).
	^hresult!
put_Bold: bold
        " Invoke the IFont::put_Bold function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(put_Bold)(THIS_ BOOL bold) PURE"

	<ole: 8 boolean hresult>
	^self vtableDispatchFailed!  
invokeQueryTextMetrics: lptm
		" Private - invoke the IFont::QueryTextMetrics function. "

	"STDMETHOD(QueryTextMetrics)(THIS_ LPTEXTMETRICOLE lptm) PURE"

	<ole: 23 structOut hresult>
	^self vtableDispatchFailed!   
invokeGet_Italic: pitalic
		" Private - invoke the IFont::get_Italic function. "

	"STDMETHOD(get_Italic)(THIS_ BOOL FAR* pitalic) PURE"

	<ole: 9 structOut hresult>
	^self vtableDispatchFailed!  
invokeGet_Weight: pweight
		" Private - invoke the IFont::get_Weight function. "

	"STDMETHOD(get_Weight)(THIS_ short FAR* pweight) PURE"

	<ole: 15 structOut hresult>
	^self vtableDispatchFailed!
put_Size: size
        " Invoke the IFont::put_Size function.
        Raise an exception if an error occurs.  Answer the result code. "

	self ISSUE.  " What is a CY value and how do we need to pass it here? 
		It's a 64-bit integer... [DL 21-Oct-95] " 
	^self invokePut_Size: ( WinLargeInteger fromInteger: size )! 
invokePut_Size: size
		" Private "

	"STDMETHOD(put_Size)(THIS_ CY size) PURE"

	<ole: 6 structValue hresult>
	^self vtableDispatchFailed!  
invokePut_Name: name
		" Private "

	"STDMETHOD(put_Name)(THIS_ BSTR name) PURE"

	<ole: 4 structIn hresult>
	^self vtableDispatchFailed!   
invokeReleaseHfont: hfont
		" Private "

    "STDMETHOD(ReleaseHfont)(THIS_ HFONT hfont) PURE"

    <ole: 25 ulong hresult>
    ^self vtableDispatchFailed! 
invokeGet_Bold: pbold
		" Private - invoke the IFont::get_Bold function. "

	"STDMETHOD(get_Bold)(THIS_ BOOL FAR* pbold) PURE"

	<ole: 7 structOut hresult>
	^self vtableDispatchFailed!
invokeGet_Name: pname
		" Private - invoke the IFont::get_Name function. "

	"STDMETHOD(get_Name)(THIS_ BSTR FAR* pname) PURE"

	<ole: 3 structOut hresult>
	^self vtableDispatchFailed!
invokeGet_Size: psize
		" Private - invoke the IFont::get_Size function. "

	"STDMETHOD(get_Size)(THIS_ CY FAR* psize) PURE"

	<ole: 5 structOut hresult>
	^self vtableDispatchFailed!  
get_Weight: resultReference
        " Invoke the IFont::get_Weight function.
        Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeGet_Weight: resultValue.
	resultReference value: ( resultValue shortAtOffset: 0 ).
	^hresult!  
put_Weight: weight
        " Invoke the IFont::put_Weight function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(put_Weight)(THIS_ short weight) PURE"

	<ole: 16 short hresult>
	^self vtableDispatchFailed!
put_Italic: italic
        " Invoke the IFont::put_Italic function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(put_Italic)(THIS_ BOOL italic) PURE"

	<ole: 10 boolean hresult>
	^self vtableDispatchFailed!   
AddRefHfont: hfont
        " Invoke the IFont::AddRefHfont function.
        Raise an exception if an error occurs.  Answer the result code. "

    "STDMETHOD(AddRefHfont)(THIS_ HFONT hfont) PURE"

    <ole: 24 ulong hresult>
    ^self vtableDispatchFailed!  
put_Strikethrough: strikethrough
        " Invoke the IFont::put_Strikethrough function.
        Raise an exception if an error occurs.  Answer the result code. "

	"STDMETHOD(put_Strikethrough)(THIS_ BOOL strikethrough) PURE"

	<ole: 14 boolean hresult>
	^self vtableDispatchFailed!
invokeGet_Underline: punderline
		" Private - invoke the IFont::get_Underline function. "

	"STDMETHOD(get_Underline)(THIS_ BOOL FAR* punderline) PURE"

	<ole: 11 structOut hresult>
	^self vtableDispatchFailed!  
invokeGet_Charset: pcharset
		" Private - invoke the IFont::get_Charset function. "

	"STDMETHOD(get_Charset)(THIS_ short FAR* pcharset) PURE"

	<ole: 17 structOut hresult>
	^self vtableDispatchFailed!   
invokeGet_Strikethrough: pstrikethrough
		" Private - invoke the IFont::get_Strikethrough function. "

	"STDMETHOD(get_Strikethrough)(THIS_ BOOL FAR* pstrikethrough) PURE"

	<ole: 13 structOut hresult>
	^self vtableDispatchFailed!  
invokeGet_hFont: phfont
		" Private - invoke the IFont::get_hFont function. "

	"STDMETHOD(get_hFont)(THIS_ HFONT FAR* phfont) PURE"

	<ole: 19 structOut hresult>
	^self vtableDispatchFailed! 
get_Name: resultReference
        " Invoke the IFont::get_Name function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := BSTRMemoryAddress new.
	hresult := self invokeGet_Name: resultValue asParameter.
	resultReference value: ( BSTR atAddress: resultValue ) asString.
	resultValue release.
	^hresult!  
invokeGet_Underline: punderline
        " Private - invoke the IFont::get_Underline function for an external caller. "

    "STDMETHOD(get_Underline)(THIS_ BOOL FAR* punderline) PURE"

    | resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    punderline isValid
        ifFalse: [ ^E_INVALIDARG ].
    resultReference := nil asValueReference.
    hresult := self dispatchGet_Underline: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self booleanResultAtAddress: punderline put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
ReleaseHfont: hfont
        " Invoke the IFont::ReleaseHfont function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        (self dispatchReleaseHfont: hfont)!
disableControlWindows
		" Private "

	| message callback |
	message := Message receiver: self selector: #disableControlWindow:with:.
	[
	callback := CallBack
		registerMessage: message
		parameterTypes: #( #ulong #long )
		returnType: #boolean
		callingConvention: #api.
	UserLibrary
		enumChildWindows: self sitePane asParameter
		callback: callback asParameter
		lparam: 0
	]
		ensure: [ callback release ].!