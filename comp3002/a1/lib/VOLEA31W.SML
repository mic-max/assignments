3.1.0.106
   
isPropertyPut

	^self invkind = DISPATCH_PROPERTYPUT!   
cElements: anInteger
		" Set the number of elements in this array dimension. "

	self uLongAtOffset: 0 put: anInteger.!
asArray
	"Answer an Array containing the data in the receiver."

	| array |
	array := Array new: self size.
	1 to: array size do:
		[:index |
		array at: index put: (self at: index)].
	^array!  
isPropertyGet

	^self invkind = DISPATCH_PROPERTYGET!   
invoke: dispidMember
	localeID: lcid
	flags: dispatchFlags
	parameters: dispatchParameters
	result: resultReference
		" Invoke the method or property get/set function of the object 
		identified by the DISPID <dispidMember> .
		If a result value is expected, return it sending #value: to <resultReference>.
		Answer the result value (nil if none).  Raise an exception if an error occurs. "

	| exceptionInfoReference argErrorReference hresult |
	exceptionInfoReference := nil asValueReference.
	argErrorReference := nil asValueReference.
	hresult := interface Invoke: dispidMember
		_: IID_NULL
		_: lcid
		_: dispatchFlags
		_: dispatchParameters
		_: resultReference
		_: exceptionInfoReference
		_: argErrorReference.
	( HRESULT succeeded: hresult )
		ifFalse: [
			self signalDispatchError: hresult 
				exceptionInfo: exceptionInfoReference value
				argError: argErrorReference value.
			].
	^resultReference == nil
		ifTrue: [ nil ]  " no result value " 
		ifFalse: [ resultReference value ]!  
exceptionDescription
		" Answer the IDispatch exception description. "

	^exceptionDescription!
exceptionDescription: aString
		" Set the IDispatch exception description. "

	exceptionDescription := aString.!   
exceptionInfo: info
		" Set the IDispatch exception information. "

	exceptionInfo := info.!   
exceptionInfo
		" Answer the IDispatch exception information. "

	^exceptionInfo!  
size
	"Answer the number of elements the receiver can hold."

	^self upperBound - self lowerBound + 1! 
returnValueDescription
	"Answer the type and IDL descriptions of the return value."

	^self elemdescFunc!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #EXCEPINFO.! 
lptdesc

    ^self addressAtOffset: 0!  
xBSTR
	"Private"
	"Translate the value to a string."

	^( BSTR atAddress:
		( BSTRMemoryAddress fromInteger:
			( self uLongAtOffset: self valueOffset ) ) )
				asString! 
asDate
		" Answer a Date representing the date described by the receiver. "

	"midnight Jan1, 1900 = 2.0, 1900 was not a leap year."

	^Date fromDays: self value truncated - 367!   
invocationStyle
	"Answer the code that describes how the function is invoked."

	^self invkind!
cDims
		" Answer the number of dimensions in the array. "

	^self uShortAtOffset: 0!   
bstrAtAddress: anAddress
        " Private - answer the BSTR at <anAddress>. "

    | bstrAddress |
    anAddress isNil
        ifTrue: [ ^nil ].
    "self ASSERT: anAddress contents isByteArray."
    bstrAddress := BSTRMemoryAddress usingBytes: anAddress contents.
    ^BSTR atAddress: bstrAddress!   
cbSizeVft

    ^self uShortAtOffset: 50!
invokeGetClassInfo: ppTI
		" Private - invoke the IProvideClassInfo::GetClassInfo function. "

	" HRESULT GetClassInfo(
            /* [out] */ LPTYPEINFO * ppTI); "

    <ole: 3 structOut hresult>
    ^self vtableDispatchFailed!  
GetClassInfo: resultReference
		" Invoke the IProvideClassInfo::GetClassInfo function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeInfoPointer forReturnValue.
	hresult := self invokeGetClassInfo: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
wFuncFlags

    ^self uShortAtOffset: 48!   
at: anIndex put: aValue
	"Set the value at <anIndex> to <Value>. The receiver is interpreted as having 1-based indices."

	self accessor value: aValue.
	OLEAutomationDLL current SafeArrayPutElement: self 
		_: ( Array with: ( anIndex - 1 + self lowerBound ) ) 
		_: self accessor contents.!  
cParams

    ^self shortAtOffset: 24!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #ARRAYDESC.! 
wLibFlags
        " Answer the library flags. "

    ^self uShortAtOffset: 28! 
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
supportsIID: aGUID
		" Answer whether the receiver represents the interface identified
		by the IID <aGUID>. "

	^( super supportsIID: aGUID )
		or: [ IDispatch supportsDispatchIID: aGUID ]!   
invokeGetTypeInfo: itinfo _: lcid _: pptinfo
		" Private - invoke the IDispatch::GetTypeInfo function. "

	" HRESULT GetTypeInfo(
            /* [in] */ UINT itinfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **pptinfo); "

	<ole: 4 ulong ulong structOut hresult>
    ^self vtableDispatchFailed! 
invokeGetIDsOfNames: riid _: rgszNames _: cNames _: lcid _: rgdispid
		" Private - invoke the IDispatch::GetIDsOfNames function. "

	" HRESULT GetIDsOfNames(
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out][in] */ DISPID *rgdispid); "

	<ole: 5 structIn structIn ulong ulong struct hresult>
	self ISSUE.  " Allow DISP_E_UNKNOWNNAME through here? [DL 18-Oct-95] " 

    ^self vtableDispatchFailed! 
Invoke: dispidMember
    _: riid
    _: lcid
    _: wFlags
    _: pdispparams
    _: resultReference
    _: exceptionInfoReference
    _: argErrorReference
        "Invoke the IDispatch::Invoke function.
        Raise an exception if an error occurs.  Answer the result code."

    | resultValue exceptionInfoValue argErrorValue hresult |

    self ifOLETraceEnabled: [
        self logFunctionHeader.
        self oleTRACE: self logIndent, 'DISPID: ', dispidMember printString.
        ].

    resultReference == nil
        "ifTrue: [ resultValue := nil ]"
        ifFalse: [ resultValue := OLEStructure forReturnValue: #VARIANT ].
    exceptionInfoValue := OLEStructure forReturnValue: #EXCEPINFO.
    argErrorValue := ExternalLong new.
    hresult := self invokeInvoke: dispidMember
        _: riid
        _: lcid
        _: wFlags
        _: pdispparams asParameter
        _: resultValue asParameter
        _: exceptionInfoValue asParameter
        _: argErrorValue asParameter.
    self ifOLETraceEnabled: [ self logFunctionExit: hresult ].
    ( HRESULT succeeded: hresult )
        ifTrue: [
            resultReference notNil
                ifTrue: [ resultReference value: resultValue value ].
            exceptionInfoValue release ]
        ifFalse: [
            exceptionInfoReference value: exceptionInfoValue.  " set for DISP_E_EXCEPTION "
            argErrorReference value: argErrorValue asUnsignedInteger.  " set for DISP_E_TYPEMISMATCH "
            ].
    ^hresult!  
oleVariantType
		" Answer the type code which should be used
		to represent the receiver as an OLE VARIANT value. "

	^VT_DISPATCH!   
invokeInvoke: dispidMember _: riid _: lcid _: wFlags _: pdispparams _: pvarResult _: pexcepinfo _: puArgErr
		" Private - invoke the IDispatch::Invoke function. "

	" HRESULT Invoke(
            /* [in] */ DISPID dispidMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [unique][in] */ DISPPARAMS *pdispparams,
            /* [unique][out][in] */ VARIANT *pvarResult,
            /* [out] */ EXCEPINFO *pexcepinfo,
            /* [out] */ UINT *puArgErr); "

	| hresult |
	<ole: 6 long structIn ulong ushort structIn struct structOut structOut hresult>
	hresult := self dispatchFailureReason.
	( hresult = DISP_E_EXCEPTION or: [ hresult = DISP_E_TYPEMISMATCH ] )
		ifTrue: [ ^hresult ].  " special exception generation required "
    ^self vtableDispatchFailed! 
invokeGetTypeInfoCount: pctinfo
		" Private - invoke the IDispatch::GetTypeInfoCount function. "

	" HRESULT GetTypeInfoCount(
            /* [out] */ UINT *pctinfo); "

	<ole: 3 structOut hresult>
    ^self vtableDispatchFailed!  
GetTypeInfo: itinfo _: lcid _: resultReference
		" Invoke the IDispatch::GetTypeInfo function.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult resultValue |
	resultValue := ITypeInfoPointer forReturnValue.
	hresult := self invokeGetTypeInfo: itinfo 
		_: lcid 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
GetIDsOfNames: riid _: rgszNames _: cNames _: lcid _: resultReference
		" Invoke the IDispatch::GetIDsOfNames function.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult unicodeStrings namesBuffer elementSize offset nIDs 
	  dispidBuffer dispidList |

	self ISSUE.  " Need to test this to verify string arguments passed correctly. [DL 18-Oct-95] "
 
	unicodeStrings := rgszNames collect: [ :aString |
		UnicodeStringBuffer newExternalBufferFromString: aString ].
	namesBuffer := self asArrayOfStringsParameter: unicodeStrings.

	nIDs := cNames.
	riid = IID_NULL
		ifFalse: [ nIDs := nIDs + 1 ].
	elementSize := ExternalLong sizeInBytes.   " DISPID is a  LONG value "
	dispidBuffer := ExternalBuffer new: nIDs * elementSize.
	[ hresult := self invokeGetIDsOfNames: riid
		_: namesBuffer
 		_: cNames
		_: lcid 
		_: dispidBuffer.
		] ensure: [ unicodeStrings do: [ :aString | aString release ] ].
	dispidList := Array new: nIDs.
	offset := 0.
	1 to: nIDs do: [ :i |
		dispidList at: i put: ( dispidBuffer longAtOffset: offset ).
		offset := offset + elementSize ].
	resultReference value: dispidList.
	^hresult!
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

	self propertyAt: #iid put: anIID.!  
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^self propertyAt: #iid ifAbsent: [ IID_IDispatch ]!
GetTypeInfoCount: resultReference
		" Invoke the IDispatch::GetTypeInfoCount function.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult resultValue |
	resultValue := ExternalLong new.
	hresult := self invokeGetTypeInfoCount: resultValue asParameter.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!
rgsabound
        " Answer the address of the array data. "

	^self structureAtOffset: 16 type: #SAFEARRAYBOUND!   
typeCodeUsing: iTypeInfo
	"Answer the integer that defines the type of the variable."

	^self returnValueDescription typeCodeUsing: iTypeInfo! 
asGUID
		" Answer the GUID specified by the receiver if it is
		a syntactically legal string representation of a GUID. "

    ^self asString asGUID!  
doubleFloatValue: aFloat
	"Private"
	"Set the value to <aFloat>."

	^self contents
		replaceFrom: self valueOffset + 1
		to: self valueOffset + 8
		with: aFloat
		startingAt: 1! 
hi

	^self longAtOffset: 4! 
rgvarg: anAddress
		" Set the address of the argument array. "

	self oleAddressAtOffset: 0 put: anAddress.!   
typeCode
	"Answer the type code of the receiver."

	^typeCode! 
xERROR
	"Private"
	"Translate the value to an SCODE."

	^self longAtOffset: self valueOffset! 
asInteger

	^(self largeIntegerAtOffset: 0) // 10000!   
cbSize
		" Answer the size in bytes of the data. "

	^self uLongAtOffset: 0!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #BLOB for: self.!  
invkind

    ^self longAtOffset: 16!
forIID: anIID binding: anInterfaceBinding
        "Private - answer a new instance of the receiver with IID <anIID>
        which uses the callin/callout binding <anInterfaceBinding>. "

    ^self new
        iid: anIID;
        interfaceBinding: anInterfaceBinding;
        yourself!   
helpFile
		" Answer the fully qualified path name of a Help file
		which contains information about the error. "

	^self stringFromBSTR: self bstrHelpFile!   
xDATE: aValue
	"Private"
    "Store <aValue> as a DATE."

    | aDate |
    aValue isDate
        ifTrue: [ aDate := OLEDate fromDate: aValue ]
        ifFalse: [ aValue isTimeStamp
            ifTrue: [ aDate := OLEDate fromDate: aValue date ]
            ifFalse: [ aValue isNumber
                ifTrue: [ aDate := OLEDate fromDATEValue: aValue asFloat ] ] ].
    aDate class == OLEDate
        ifFalse: [ self error: 'explicit conversion to DATE required' ].
    self doubleFloatValue: aDate value.! 
pUnk: anIUnknown
		" Set the IUnknown. "

	self interfaceAtOffset: 0 put: anIUnknown!  
safeArrayStructure
	"Private"

    ^( OLEStructure classForStructureNamed: #SAFEARRAY )
        at: ( self addressAtOffset: self valueOffset )
        using: self safeArrayAccessor!
elemdescFunc

	^self structureAtOffset: 32 type: #ELEMDESC! 
invokeEnumConnectionPoints: ppEnum
		" Private - invoke the IConnectionPointContainer::EnumConnectionPoints function. "

	" HRESULT EnumConnectionPoints(
            /* [out] */ LPENUMCONNECTIONPOINTS *ppEnum); "

    <ole: 3 structOut hresult>
    ^self vtableDispatchFailed!   
invokeFindConnectionPoint: iid _: ppCP
		" Private - invoke the IConnectionPointContainer::FindConnectionPoint function. "

	" HRESULT FindConnectionPoint(
            /* [in] */ REFIID iid,
            /* [out] */ LPCONNECTIONPOINT *ppCP); "

    <ole: 4 structIn structOut hresult>
    ^self vtableDispatchFailed!   
EnumConnectionPoints: resultReference
		" Invoke the IConnectionPointContainer::EnumConnectionPoints function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumConnectionPoints.
    hresult := self invokeEnumConnectionPoints: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!
FindConnectionPoint: iid _: resultReference
		" Invoke the IConnectionPointContainer::FindConnectionPoint function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IConnectionPointPointer forReturnValue.
	hresult := self invokeFindConnectionPoint: iid asParameter
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #TLIBATTR.!  
wMinorVerNum: anInteger
        " Set the minor version number of the type library. "

    self uShortAtOffset: 26 put: anInteger.!
typeCode: aTypeCode
		" Set the type of the variant value to <aTypeCode>. "

	typeCode := aTypeCode.!  
printValueOn: aStream
		" Private - append a text description of the receiver's value to <aStream> "

	super printValueOn: aStream.
	typeCode notNil
		ifTrue: [
			aStream nextPutAll: ' (', ( OLEVariant typeCodeNameOf: typeCode ), ')' ].!  
typeCode
		" Answer the type of the variant value. "

	^typeCode!  
asVariant
        " Answer a VARIANT which represents the receiver's value. "

    | aVariant |
    aVariant := OLEStructure createStructureNamed: #VARIANT.
    self value notNil
        ifTrue: [
            aVariant
                typeCode: ( self typeCode notNil
                    ifTrue: [ self typeCode ]
                    ifFalse: [ self value oleVariantType ] );
                value: self value ].
    ^aVariant!
xI2: aValue
	"Private"
	"Store <aValue> as a short."

	self shortAtOffset: self valueOffset put: ( self asInteger: aValue ).! 
fromCollection: aCollection using: variantAccessor
	"Create a new instance of the receiver that contains the data in <aCollection> typed according to <variantAccessor>."

	| array index |
	array := self new: aCollection size using: variantAccessor.
	index := 0.
	aCollection do:
		[:each |
		array at: (index := index + 1) put: each].
	^array!  
typeDescription
	"Answer the type description member of the structure."

	^self tdesc! 
printOn: aStream
		" Append a text description of the receiver to <aStream> "

	super printOn: aStream.
	( self contents isNil 
	or: [ self isValid not ] )
		ifTrue: [ ^self ].  " uninitialized instance "
	aStream 
		nextPutAll: ' (';
		nextPutAll: self typeCodeDescription;
		nextPutAll: ', ';
		nextPutAll: self valueDescription;
		nextPutAll: ')'.!   
release

    | nArgs variantArgSize variantArgAddress named |
    ( nArgs := self cArgs ) = 0
        ifTrue: [ ^self ].
    variantArgSize := OLEStructure sizeOfStructureNamed: #VARIANTARG.
    variantArgAddress := self rgvarg.
    1 to: nArgs do:
        [ :index |
        ( OLEStructure createStructureNamed: #VARIANTARG atAddress: variantArgAddress )
            release.
        variantArgAddress := variantArgAddress + variantArgSize ].
    self rgvarg free.
    ( named := self rgdispidNamedArgs ) == nil
        ifFalse: [ named free ]!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #BLOB.!  
cbElements
		" Answer the size of an array element. "

	^self uLongAtOffset: 4!
Unadvise: dwCookie
		" Invoke the IConnectionPoint::Unadvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Unadvise(
            /* [in] */ DWORD dwCookie); "

    <ole: 6 ulong hresult>
    ^self vtableDispatchFailed!
GetConnectionInterface: resultReference
		" Invoke the IConnectionPoint::GetConnectionInterface function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeGetConnectionInterface: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
invokeGetConnectionInterface: pIID
		" Private - invoke the IConnectionPoint::GetConnectionInterface function. "

	" HRESULT GetConnectionInterface(
            /* [out] */ IID *pIID); "

    <ole: 3 structOut hresult>
    ^self vtableDispatchFailed! 
invokeEnumConnections: ppEnum
		" Private - invoke the IConnectionPoint::EnumConnections function. "

	" HRESULT EnumConnections(
            /* [out] */ LPENUMCONNECTIONS *ppEnum); "

    <ole: 7 structOut hresult>
    ^self vtableDispatchFailed!
GetConnectionPointContainer: resultReference
		" Invoke the IConnectionPoint::GetConnectionPointContainer function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IConnectionPointContainerPointer forReturnValue.
	hresult := self invokeGetConnectionPointContainer: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
invokeAdvise: pUnkSink _: pdwCookie
		" Private - invoke the IConnectionPoint::Advise function. "

	" HRESULT Advise(
            /* [in] */ LPUNKNOWN pUnkSink
            /* [out] */ DWORD *pdwCookie); "

    <ole: 5 handle structOut hresult>
    ^self vtableDispatchFailed!   
EnumConnections: resultReference
		" Invoke the IConnectionPoint::EnumConnections function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumConnections.
	hresult := self invokeEnumConnections: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
Advise: anIUnknownSink _: resultReference
		" Invoke the IConnectionPoint::Advise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeAdvise: anIUnknownSink asParameter 
		_: resultValue asParameter.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!   
invokeGetConnectionPointContainer: ppCPC
		" Private - invoke the IConnectionPoint::GetConnectionPointContainer function. "

	" HRESULT GetConnectionPointContainer(
            /* [out] */ IConnectionPointContainer **ppCPC); "

    <ole: 4 structOut hresult>
    ^self vtableDispatchFailed! 
fromAddress: anAddress
	"Answer an instance of the receiver with appropriate byte size and fill its contents from data at <anAddress>."

	| aVariant |
	aVariant := super new: self sizeInBytes.
	aVariant fillFromAddress: anAddress.
	^aVariant!  
cLocks
		" Answer the number of times the array has been locked without corresponding unlock. "

	^self uLongAtOffset: 8!  
errorInBounds: anInteger
        "Private - Report an error to the effect that
         <anInteger> is an invalid index for the receiver."

    ^self
        error: 'index: ',
            anInteger printString,
            ' is outside of string bounds'! 
vt

    ^self shortAtOffset: 4! 
optionalParameterCount
	"Answer the number of optional parameters."

	^self cParamsOpt!
forIID: anIID
		" Answer a new instance of the receiver for the interface specified by <anIID>. "

	^self forIID: anIID binding: nil
!
funckind

    ^self longAtOffset: 12!   
accessor: aVariantValue
	"Set the receiver's accessor to be <aVariantValue>."

	accessor := aVariantValue! 
fromBytes: aByteObject
	"Answer a new instance of the receiver with contents copied from <aByteObject>."

	| aVariant |
	aVariant := super new: aByteObject size.
	aVariant contents
		replaceFrom: 1
		to: aByteObject size
		with: aByteObject
		startingAt: 1.
	^aVariant!   
xUI1
	"Private"
	"Translate the value to an unsigned byte."

	^self byteAtOffset: self valueOffset!   
rgdispidNamedArgs
		" Answer the address of the array of DISPID's of named arguments. "

	^self oleAddressAtOffset: 4! 
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #DISPPARAMS.!
invokeMethod: dispidMember with: dispatchParameters localeID: lcid result: resultReference
		" Invoke the method identified by the DISPID <dispidMember>.
		Answer the result value (nil if none). "

	^self invoke: dispidMember
		localeID: lcid
		flags: DISPATCH_METHOD
		parameters: dispatchParameters
		result: resultReference!   
enumeratorIID
		" Private - answer the IID of the interface which enumerates
		collections containing instances of the receiver. "

	^IID_IEnumVARIANT!   
xEMPTY
	"Private"
	"No value was specified."

	^nil!  
xI2
	"Private"
	"Translate the value to a 2-byte signed integer."

	^self shortAtOffset: self valueOffset!
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

	^16! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^30!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #VARIANT.!   
lcid: anInteger
		" Set the language/locale of the type library. "

    self uLongAtOffset: 16 put: anInteger.!
fileName
        "Answer the receiver's file name."

     ^'oleaut32.dll'! 
open: fileName
        "Answer an instance of the receiver which refers
         to the Dynamic Link Library named aString."

    OLEDLL current.  " ensure the OLE is loaded "
    ^super open: fileName
! 
VarR4FromR8: dblIn _: resultReference
		" Convert the 8-byte floating point value <dblin> which corresponds to 
		the C type #double to a 4-byte array which represents the value as the C type #float.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult singleFloat |
	singleFloat := ByteArray new: 4.
	hresult := self invokeVarR4FromR8: dblIn asParameter 
		_: singleFloat.
	resultReference value: singleFloat.
	^hresult!
VarR8FromR4: fltIn _: resultReference
		" Convert the the 4-byte value <fltIn>, which represents the value as the C type #float,
		to a Float which represents the C type #double.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult doubleFloat |
	doubleFloat := Float new.
	hresult := self invokeVarR8FromR4: fltIn asParameter 
		_: doubleFloat.
	resultReference value: doubleFloat.
	^hresult!
SafeArrayGetElement: safeArray _: indices _: elementBuffer
		" Retrieve an element from the SAFEARRAY <safeArray>. 
		The indices (one per dimension) that specify the desired element 
		are in the packed array <indices>.  The result becomes the contents 
		of <elementBuffer>, which must be an ExternalBuffer of the appropriate size 
		(see #safeArrayGetElemsize:).
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSafeArrayGetElement: safeArray 
		_: ( self safeArrayIndicesAsParameter: indices ) 
		_: elementBuffer! 
SafeArrayPutElement: safeArray _: indices _: elementBuffer
		" Store the element <element> into the SAFEARRAY <safeArray>. 
		The indices (one per dimension) that specify the desired element are 
		in the packed array <indices>.   <elementBuffer> must be an ExternalBuffer 
		of the appropriate size (see #safeArrayGetElemsize:).
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSafeArrayPutElement: safeArray 
		_: ( self safeArrayIndicesAsParameter: indices ) 
		_: elementBuffer!  
VariantCopy: pvargDest _: argSrc
		" Copy the contents of  the VARIANT <argSrc> to the
		destination VARIANT <pvargDest>, which is first cleared.
		Raise an exception if an error occurs.  Answer the result code. "

"WINOLEAUTAPI VariantCopy(
    VARIANTARG FAR* pvargDest,
    VARIANTARG FAR* pvargSrc);"

    <api: VariantCopy struct structIn hresult>
    ^self apiCallFailed!   
SafeArrayUnaccessData: safeArray
		" Decrement the lock count of the SAFEARRAY <safeArray> 
		and invalidate the pointer returned by SafeArrayAccessData.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayUnaccessData(SAFEARRAY FAR* psa);"

	<api: SafeArrayUnaccessData structIn hresult>
	^self apiCallFailed!   
safeArrayIndicesAsParameter: indices
		" Private - answer the array of integer <indices> as a buffer
		of LONG values. "

	| indexSize offset indexBuffer |
	indexSize := ExternalLong sizeInBytes.
	indexBuffer := ExternalBuffer new: ( indices size * indexSize ).
	offset := 0.
	indices do: [ :anIndex |
		indexBuffer longAtOffset: offset put: anIndex.
		offset := offset + indexSize ].
	^indexBuffer!
invokeSafeArrayCreate: vt _: cDims _: rgsabound
		" Private "

	"WINOLEAUTAPI_(SAFEARRAY FAR*) SafeArrayCreate(
	    VARTYPE vt,
	    unsigned int cDims,
	    SAFEARRAYBOUND FAR* rgsabound);"

	<api: SafeArrayCreate ushort ulong structIn ulongReturn>
	^self apiCallFailed! 
invokeSafeArrayGetElement: psa _: rgIndices _: pv
		" Private "

	"WINOLEAUTAPI
	SafeArrayGetElement(
	    SAFEARRAY FAR* psa,
	    long FAR* rgIndices,
	    void FAR* pv);"

	<api: SafeArrayGetElement structIn structIn structOut hresult>
	^self apiCallFailed!
invokeSafeArrayPutElement: psa _: rgIndices _: pv
		" Private "

	"WINOLEAUTAPI
	SafeArrayPutElement(
	    SAFEARRAY FAR* psa,
	    long FAR* rgIndices,
	    void FAR* pv);"

	<api: SafeArrayPutElement structIn structIn structIn hresult>
	^self apiCallFailed! 
VariantInit: variant
		" Initialize a new VARIANT by setting its type to VT_EMPTY
		and clearing its wReserved field to 0. "

    "WINOLEAUTAPI_(void) VariantInit(VARIANTARG FAR* pvarg);"

    <api: VariantInit struct none>
    ^self apiCallFailed!   
SafeArrayCreate: vt _: cDims _: bounds
		" Answer a new SAFEARRAY whose type is <vt> with the 
		number of dimensions <cDims>.  <bounds> is a packed array 
		of SAFEARRAYBOUNDS that specifies the number of elements 
		for each dimension.  Answer <nil> if the SAFEARRAY could not be allocated."

    | addr safeArray |
    addr := self invokeSafeArrayCreate: vt _: cDims _: bounds.
    addr = 0
        ifTrue: [ ^nil ].
    addr := OLEMemoryAddress fromInteger: addr.
    safeArray := OLEStructure createStructureNamed: #SAFEARRAY 
		atAddress: addr.
    safeArray needsFinalization.
    ^safeArray! 
invokeSysStringLen: bstr
		" Private - WINOLEAUTAPI_(unsigned int) SysStringLen(BSTR)"

    <api: SysFreeString structIn ulongReturn>
	^self invalidArgument! 
SysFreeString: aBstr
		" Free a BSTR string previously allocated by a BSTR API service. "

	^self invokeSysFreeString: aBstr asParameter!  
invokeSafeArrayCopy: psa _: ppsaOut
		" Private "

	"WINOLEAUTAPI
	SafeArrayCopy(
	    SAFEARRAY FAR* psa,
	    SAFEARRAY FAR* FAR* ppsaOut);"

	<api: SafeArrayCopy structIn structOut hresult>
	^self apiCallFailed!   
GetActiveObject: clsid _: reserved _: resultReference
		" Get the active object of the class specified by the GUID <clsid>.
		Obtain its IUnknown interface and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IUnknownPointer forReturnValue.
	hresult := self invokeGetActiveObject: clsid 
		_: reserved 
		_: resultValue asParameter.
	( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!   
SysAllocString: aString
        " Allocate a BSTR in external memory and copy the characters 
		of <aString> into it.  Answer the address of the BSTR copy 
		in external memory. "

    | result |
    result := self invokeSysAllocString: ( self asUnicodeParameter: aString ).
    result = 0 ifTrue: [ ^self error: 'allocation failed' ].
    ^( BSTRMemoryAddress fromInteger: result )
        needsFinalization;
        yourself! 
SafeArrayAllocDescriptor: cDims _: resultReference
		" Allocate the memory for a new SAFEARRAY descriptor. 
		The number of dimensions is given by <cDims>. 
		Store the newly created SAFEARRAY into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

    | ppsaOut hresult |
    ppsaOut := OLEMemoryAddress forReturnValue.
    hresult := self invokeSafeArrayAllocDescriptor: cDims _: ppsaOut.
	resultReference value:
		 ( OLEStructure createStructureNamed: #SAFEARRAY atAddress: ppsaOut ).
    ^hresult! 
RegisterActiveObject: anIUnknown _: clsid _: dwFlags _: resultReference
		" Register the object <anIUnknown> with OLE as an active
		object of the class specified by the GUID <clsid>.
		Store the registration token into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeRegisterActiveObject: anIUnknown asParameter 
		_: clsid 
		_: dwFlags 
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!
SafeArrayDestroyData: safeArray
		" Free the memory used by the data in the SAFEARRAY <safeArray>. 
		Release() is called for each object (if any) in the data.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayDestroyData(SAFEARRAY FAR* psa);"

	<api: SafeArrayDestroyData structIn hresult>
	^self apiCallFailed!   
SafeArrayGetElemsize: safeArray
		" Answer the size (in bytes) of an element in the SAFEARRAY <safeArray>. "

	"WINOLEAUTAPI_(unsigned int) SafeArrayGetElemsize(SAFEARRAY FAR* psa);"

	<api: SafeArrayGetElemsize structIn ulongReturn>
	^self apiCallFailed! 
SafeArrayUnlock: safeArray
		" Decrement the lock count of the SAFEARRAY <safeArray> 
		so that it can be freed or redimensioned.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayUnlock(SAFEARRAY FAR* psa);"

	<api: SafeArrayUnlock structIn hresult>
	^self apiCallFailed!   
invokeRevokeActiveObject: dwRegister _: pvReserved
		" Private - invoke the RevokeActiveObject function. "

	"WINOLEAUTAPI RevokeActiveObject(
		DWORD dwRegister,
		void FAR* pvReserved);"

	<api: RevokeActiveObject ulong structIn hresult>
	^self apiCallFailed! 
VariantChangeTypeEx: pvargDest _: pvargSrc _: lcid _: wFlags _: vt
		" Coerce the type of the source variant <pvargSrc> to the
		new type specified by the VARTYPE code <vt> and store
		the result into <pvargDest>.  The flags which control the type coercion
		are specified by <wFlags>, which may be 0 or VARIANT_NOVALUEPROP. 
		Source and destination may be identical for in-place type conversion.
		<lcid> is the local identifier that is used to control conversion to 
		locale-specific types such as strings.
		Raise an exception if an error occurs.  Answer the result code. "

"WINOLEAUTAPI VariantChangeTypeEx(
    VARIANTARG FAR* pvargDest,
    VARIANTARG FAR* pvarSrc,
    LCID lcid,
    unsigned short wFlags,
    VARTYPE vt);"

	<api: VariantChangeTypeEx struct structIn ulong short short hresult>
	^self apiCallFailed! 
SysStringLen: aBstr
		" Answer the length in characters of a BSTR string 
		previously allocated by a BSTR API service. "

	^self invokeSysStringLen: aBstr asParameter!  
invokeVarR4FromR8: dblIn _: pfltOut
	"Private - WINOLEAUTAPI VarR4FromR8(double dblIn, float FAR* pfltOut);"

	<api: VarR4FromR8 structValue structOut hresult>
	^self apiCallFailed! 
invokeVarR8FromR4: fltIn _: pdblOut
	"Private - WINOLEAUTAPI VarR8FromR4(float fltIn, double FAR* pdblOut);"

	<api: VarR8FromR4 structValue structOut hresult>
	^self apiCallFailed! 
SafeArrayGetDim: safeArray
		" Answer the number of dimensions in the SAFEARRAY <safeArray>. "

	"WINOLEAUTAPI_(unsigned int) SafeArrayGetDim(SAFEARRAY FAR* psa);"

	<api: SafeArrayGetDim structIn ulongReturn>
	^self apiCallFailed! 
VariantCopyInd: pvarDest _: pvargSrc
		" Copy the contents of the source VARIANT <pvargSrc> into 
		the destination VARIANT <pvarDest>, which is first cleared.
		If the source variant is VT_BYREF then dereference the contents 
		to guarantee that the result is not VT_BYREF.
		Raise an exception if an error occurs.  Answer the result code. "

"WINOLEAUTAPI VariantCopyInd(
    VARIANT FAR* pvarDest,
    VARIANTARG FAR* pvargSrc);"

    <api: VariantCopyInd struct structIn hresult>
    ^self apiCallFailed!  
invokeSafeArrayAllocDescriptor: cDims _: ppsaOut
		" Private "

	"WINOLEAUTAPI
	SafeArrayAllocDescriptor(unsigned int cDims, SAFEARRAY FAR* FAR* ppsaOut);"

	<api: SafeArrayAllocDescriptor ulong structOut hresult>
	^self apiCallFailed!
invokeSysAllocString: aString
		" Private - WINOLEAUTAPI_(BSTR) SysAllocString(const OLECHAR FAR*);"

    <api: SysAllocString structIn ulongReturn>
	^self invalidArgument!  
SafeArrayDestroyDescriptor: safeArray
		" Free the memory used by the descriptor in the SAFEARRAY <safeArray>. 
		This function does not operate on the data.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayDestroyDescriptor(SAFEARRAY FAR* psa);"

	<api: SafeArrayDestroyDescriptor structIn hresult>
	^self apiCallFailed! 
SafeArrayGetLBound: safeArray _: nDim _: resultReference
		" Retrieve the lower bound of the <nDim> dimension of the SAFEARRAY 
		<safeArray> and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| plLbound hresult |
	plLbound := ExternalLong new.
	hresult := self invokeSafeArrayGetLBound: safeArray 
		_: nDim 
		_: plLbound.
	resultReference value: plLbound asInteger.
	^hresult!
SafeArrayGetUBound: safeArray _: nDim _: resultReference
		" Retrieve the upper bound of the <nDim> dimension of the SAFEARRAY 
		<safeArray> and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| plUbound hresult |
	plUbound := ExternalLong new.
	hresult := self invokeSafeArrayGetUBound: safeArray _: nDim _: plUbound.
	resultReference value: plUbound asInteger.
	^hresult!
VariantClear: variant
		" Clear the contents of <variant> before its memory is released. 
		Raise an exception if an error occurs.  Answer the result code. "

    "WINOLEAUTAPI VariantClear(VARIANTARG FAR* pvarg);"

    <api: VariantClear struct hresult>
    ^self apiCallFailed!
SafeArrayCopy: safeArray _: resultReference
		" Create a new SAFEARRAY by copying the existing <safeArray>
		and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

    | hresult ppsaOut |
    ppsaOut := OLEMemoryAddress forReturnValue.
    hresult := self invokeSafeArrayCopy: safeArray _: ppsaOut.
	resultReference value:
		( OLEStructure createStructureNamed: #SAFEARRAY atAddress: ppsaOut ).
    ^hresult! 
RevokeActiveObject: registrationToken _: reserved
		" Revoke the registration of an active object, using
		the <registrationToken> obtained from RegisterActiveObject.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeRevokeActiveObject: registrationToken 
		_: reserved asParameter!  
SafeArrayLock: safeArray
		" Increment the lock count of the SAFEARRAY <safeArray> 
		and ensure that the data pointer is valid.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayLock(SAFEARRAY FAR* psa);"

	<api: SafeArrayLock structIn hresult>
	^self apiCallFailed!
SafeArrayAccessData: safeArray _: resultReference
		" Increment the lock count of the SAFEARRAY <safeArray> 
		store the ExternalAddress of its data into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| ppvData hresult |
	ppvData := ExternalAddress new.
	hresult := self invokeSafeArrayAccessData: safeArray _: ppvData.
	resultReference value: ppvData.
	^hresult!
SafeArrayDestroy: safeArray
		" Free all memory used by the SAFEARRAY <safeArray>. T
		The data is also freed.  Release() is called for each object (if any) in the data.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayDestroy(SAFEARRAY FAR* psa);"

	<api: SafeArrayDestroy structIn hresult>
	^self apiCallFailed! 
SafeArrayRedim: safeArray _: bounds
		" Change the least-significant dimension of the SAFEARRAY <safeArray>. 
		The packed array <bounds> specifies the new dimensions. 
		Only the final element of <bounds> may be different that the existing bounds.
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayRedim(SAFEARRAY FAR* psa, SAFEARRAYBOUND FAR* psaboundNew);"

	<api: SafeArrayRedim structIn structIn hresult>
	^self apiCallFailed!   
invokeRegisterActiveObject: punk _: rclsid _: dwFlags _: pdwRegister
		" Private - invoke the RegisterActiveObject function. "

	"WINOLEAUTAPI RegisterActiveObject(
		IUnknown FAR* punk,
		REFCLSID rclsid,
		DWORD dwFlags,
		DWORD FAR* pdwRegister);"

	<api: RegisterActiveObject handle structIn ulong structOut hresult>
	^self apiCallFailed!  
invokeSafeArrayAccessData: psa _: ppvData
		" Private "

	" WINOLEAUTAPI SafeArrayAccessData(SAFEARRAY FAR* psa, void HUGEP* FAR* ppvData);"

	<api: SafeArrayAccessData structIn structOut hresult>
	^self apiCallFailed!  
VariantChangeType: pvargDest _: pvargSrc _: wFlags _: vt
		" Coerce the type of the source variant <pvargSrc> to the
		new type specified by the VARTYPE code <vt> and store
		the result into <pvargDest>.  The flags which control the type coercion
		are specified by <wFlags>, which may be 0 or VARIANT_NOVALUEPROP. 
		Source and destination may be identical for in-place type conversion.
		Raise an exception if an error occurs.  Answer the result code. "

"WINOLEAUTAPI VariantChangeType(
    VARIANTARG FAR* pvargDest,
    VARIANTARG FAR* pvarSrc,
    unsigned short wFlags,
    VARTYPE vt);"

	<api: VariantChangeType struct structIn short short hresult>
	^self apiCallFailed!
invokeLoadTypeLib: szFileName _: lplptlib
    "Private - WINOLEAUTAPI LoadTypeLib(
		const OLECHAR FAR *szFile, ITypeLib FAR* FAR* pptlib);"

    <api: LoadTypeLib structIn structOut hresult>
    ^self apiCallFailed! 
invokeSafeArrayGetLBound: psa _: nDim _: plLbound
		" Private "

	"WINOLEAUTAPI
	SafeArrayGetLBound(SAFEARRAY FAR* psa, unsigned int nDim, long FAR* plLbound);"

	<api: SafeArrayGetLBound structIn ulong structOut hresult>
	^self apiCallFailed!
invokeSafeArrayGetUBound: psa _: nDim _: plUbound
		" Private "

	"WINOLEAUTAPI
	SafeArrayGetUBound(SAFEARRAY FAR* psa, unsigned int nDim, long FAR* plUbound);"

	<api: SafeArrayGetUBound structIn ulong structOut hresult>
	^self apiCallFailed!
invokeSysFreeString: bstr
		" Private - WINOLEAUTAPI_(void) SysFreeString(BSTR)"

    <api: SysFreeString structIn none>
	^self invalidArgument!  
SafeArrayAllocData: safeArray
		"Allocate memory to store the data of the SAFEARRAY <safeArray>. 
		<safeArray> must have been created by SafeArrayAllocDescriptor().
		Raise an exception if an error occurs.  Answer the result code. "

	"WINOLEAUTAPI SafeArrayAllocData(SAFEARRAY FAR* psa);"

	<api: SafeArrayAllocData structIn hresult>
	^self apiCallFailed! 
LoadTypeLib: aString _: resultReference
		" Load and register the type library in the file named <aString>.
		Obtain its ITypeLib interface and store it into <resultReference>.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeLibPointer forReturnValue.
	hresult := self invokeLoadTypeLib: ( self asUnicodeParameter: aString )
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult.!  
invokeGetActiveObject: rclsid _: pvReserved _: ppunk
		" Private - invoke the GetActiveObject function. "

	"WINOLEAUTAPI GetActiveObject(
		REFCLSID rclsid,
		void FAR* pvReserved,
		IUnknown FAR* FAR* ppunk);"

	| hresult |
	<api: GetActiveObject structIn structIn structOut hresult>
	hresult := self apiFailureReason.
	hresult = MK_E_UNAVAILABLE
		ifTrue: [ ^hresult ].
	^self apiCallFailed!   
typeCodeFor: aTypeCode
		" Private - answer the variant type code to use for <aTypeCode. "

	self ISSUE.  " Steve's original implemenation carried the following remark.
		What to do?? [DL 24-Oct-95] " 
	"TEMPORARY: need to determine how to handle user-defined interface types."

	self ISSUE.  " Maybe don't need false option anymore, GUID's were 
		handled back in #refTypeCode: [Deb/Steve [DL 09-Nov-95] " 
	^aTypeCode isInteger
		ifTrue: [ aTypeCode ]
		ifFalse: [ VT_UNKNOWN ]!   
argumentsForMethod: aDispatchSpecification parameters: dispParams localeID: lcid
		" Answer the argument values corresponding to the dispatch parameters
		in <dispParams> which have been used to invoke the dispatch method
		described by <aDispatchSpecification>. "

	self ISSUE.  " TO DO: Check supplied types against expected types 
		-> answer mismatch index for DISP_E_TYPEMISMATCH if problem found.
		Allow null specification for OLEFontObject.  [DL 30-Oct-95]  "
	^dispParams argumentValues!  
parametersForMethod: aDispatchSpecification arguments: valueArray
		" Answer the dispatch parameters corresponding to the argument values
		in <valueArray> which can be used to invoke the dispatch method
		described by <aDispatchSpecification>. "

    | dispParams |
    dispParams := self createDispParams.
    self ASSERT: aDispatchSpecification parameterTypes size = valueArray size.    "not handling opt args"
    dispParams arguments: ( self 
		constructVariantsForTypes: aDispatchSpecification parameterTypes
		values: valueArray ).
    ^dispParams!
argumentsForPropertySet: aDispatchSpecification parameters: dispParams localeID: lcid
		" Answer the argument values corresponding to the dispatch parameters
		in <dispParams> which have been used to set the value of the property
		described by <aDispatchSpecification>. "

	self ISSUE.  " TO DO: Check supplied types against expected types 
		-> answer mismatch index for DISP_E_TYPEMISMATCH if problem found.
		Allow null specification for OLEFontObject.  [DL 30-Oct-95]  "
	^dispParams argumentValues!  
argumentsForPropertyGet: aDispatchSpecification parameters: dispParams localeID: lcid
		" Answer the argument values corresponding to the dispatch parameters
		in <dispParams> which have been used to get the value of the property
		described by <aDispatchSpecification>. "

	self ISSUE.  " TO DO: Check supplied types against expected types 
		-> answer mismatch index for DISP_E_TYPEMISMATCH if problem found.
		Allow null specification for OLEFontObject.  [DL 30-Oct-95]  "
	^dispParams argumentValues!  
createVariant: aTypeCode value: aValue
		" Private - answer a newly created VARIANTARG structure. "

	^( OLEStructure classForStructureNamed: #VARIANTARG )
		type: ( self typeCodeFor: aTypeCode )
		value: aValue! 
parametersForPropertyGet: aDispatchSpecification arguments: valueArray
		" Answer the dispatch parameters corresponding to the argument values
		in <valueArray> which can be used to get the value
		of the property described by <aDispatchSpecification>. "

    | dispParams |

    dispParams := self createDispParams.
	aDispatchSpecification hasParameters
		ifFalse: [  " simple property get "
			dispParams arguments: #( ).
			^dispParams ].

	" parameterized property "
    self ASSERT: ( aDispatchSpecification isReadOnly
        ifTrue: [ aDispatchSpecification parameterTypes size = valueArray size ] "not handling opt args"
        ifFalse: [ aDispatchSpecification parameterTypes size - 1 = valueArray size ] ).
    dispParams arguments: ( self
		constructVariantsForTypes: aDispatchSpecification parameterTypes
		values: valueArray ).
    ^dispParams!
updateReferenceArguments: argValuesArray fromParameters: dispParams
		" Update any reference values provided the caller in <argValuesArray> 
		from the returned values of the dispatch parameters <dispParams>. "

	dispParams arguments with: argValuesArray do:
		[ :aVariant :anArgValue |
		aVariant isReference
			ifTrue: [ anArgValue value: aVariant value value ] ]! 
parametersForPropertySet: aDispatchSpecification arguments: valueArray
        " Answer the dispatch parameters corresponding to the argument values
        in <valueArray> which can be used to set the value
        of the property described by <aDispatchSpecification>. "

    | dispParams |

    dispParams := self createDispParams.
    dispParams argumentIDs: ( Array with: DISPID_PROPERTYPUT ).

    aDispatchSpecification hasParameters
        ifFalse: [  " simple property get "
            dispParams arguments: ( Array
                with: ( self createVariant: aDispatchSpecification typeCode
                    value: ( valueArray at: 1 ) ) ).
            ^dispParams ].

    " parameterized property "
    self ASSERT: aDispatchSpecification parameterTypes size = valueArray size.    "not handling opt args"
    dispParams arguments: ( self
        constructVariantsForTypes: aDispatchSpecification parameterTypes
        values: valueArray ).
    ^dispParams!   
createDispParams
		" Private - create a new instance of a DISPPARAMS structure. "

	^OLEStructure createStructureNamed: #DISPPARAMS!   
constructVariantsForTypes: parameterTypes values: valueArray
		" Private - answer an array of VARIANTARG's constructed according
		to the type codes in <parameterTypes> for the values <valueArray>. "

	| i |
	i := 0.
	^valueArray collect: [ :aValue |
		self createVariant: ( parameterTypes at: ( i := i + 1 ) ) 
			value: aValue ] !  
iid: anIID specificationTable: aSpecificationTable
		" Answer a new instance of the receiver which will receive event
		notifications from the connection point specified by <anIID>.
		The incoming event notifications are described by the
		specifications in <aSpecificationTable>.  "

	^self new
		connectionPointIID: anIID;
		specificationTable: aSpecificationTable;
		yourself!  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."

	^super constructEventsTriggered
		add: #eventNotification:arguments: ;
		yourself!  
registerActiveObject: anIUnknown clsid: clsid
		" Register the object which supports <anIUnknown> with OLE
		as the active automation object of the class identified
		by the GUID <clsid>.  Answer the registration token. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEAutomationDLL current RegisterActiveObject: anIUnknown
		_: clsid 
		_: 0 
		_: resultReference.
	^resultReference value!
revokeActiveObject: registration
		" Revoke the registration of an active automation object,
		using the registration token obtained from RegisterActiveObject. "

	OLEAutomationDLL current RevokeActiveObject: registration _: nil.!
getActiveObject: clsid
		" Answer the IUnknown interface of the active object 
		of the class specified by the GUID <clsid> which has been
		registered by a running OLE automation server application. "

	| resultReference |
	resultReference := IUnknown new asValueReference.
	OLEAutomationDLL current GetActiveObject: clsid 
		_: nil
		_: resultReference.
	^resultReference value!
baseTypeCode
	"Answer the type code of the basic value, i.e. without refs, arrays, etc."

	^OLEVariant baseTypeCodeOf: self typeCode!  
forIID: anIID
		"Answer a new instance of the receiver which enumerates
		the homogeneous collection of interfaces or data structures 
		specified by <anIID>. "

	anIID ~= IID_IEnumVARIANT
		ifTrue: [ self error: 'invalid enumerator IID' ].
	^self on: #( )!  
new
		"Answer a new instance of the receiver which enumerates
		a collection of values as VARIANT structures. "

	^self on: #( )! 
on: anOrderedCollection
		"Answer a new instance of the receiver which enumerates
		the values in <anOrderedCollection> as VARIANT structures. "

	^super new
		enumeratorIID: IID_IEnumVARIANT;
		elementClass: ( OLEStructure classForStructureNamed: #VARIANT );
		elements: anOrderedCollection;
		yourself!  
getElementAt: index
		" Private - answer the element at <index> in the receiver's collection. "

	^( self elements at: index ) asOLEVariant!   
bstrDescription
		" Answer a textual, human-readable description of the error. "

	^self bstrAtAddress: ( self addressAtOffset: 8 )!   
xBSTR: aValue
	"Private"
	"Store <aValue> as a BSTR."

	| aBSTRAddress |
	aValue isString
		ifTrue: [
			aBSTRAddress := BSTRMemoryAddress allocateString: aValue.
			aBSTRAddress doesNotNeedFinalization ]
		ifFalse: [ aBSTRAddress := aValue ].
	aBSTRAddress isExternalAddress
		ifFalse: [ self error: 'explicit conversion to String or BSTR address required' ].
	self addressAtOffset: self valueOffset put: aBSTRAddress.!  
new: size using: variantAccessor
    "Create a new instance of the receiver that contains<size> elements typed according to <variantAccessor>."

    | aSafeArray |
    aSafeArray := OLEAutomationDLL current SafeArrayCreate: variantAccessor typeCode
        _: 1
        _: ( self boundsForSize: size ).
    aSafeArray accessor: variantAccessor.
    ^aSafeArray! 
oleVariantType
		" Answer the type code which should be used
		to represent the receiver as an OLE VARIANT value. "

	^13  "VT_UNKNOWN"!  
tdesc

	^self structureAtOffset: 0 type: #TYPEDESC! 
oInst
    "This is the offset of the variable within the instance, if varkind = VAR_PERINSTANCE."

    ^self uLongAtOffset: 8! 
cNamedArgs: anInteger
		" Set the number of named arguments. "

	self uLongAtOffset: 12 put: anInteger.!   
xR4: aValue
	"Private"
	"Store <aValue> as a float."

	self singleFloatAtOffset: self valueOffset 
		put: ( self asFloat: aValue ).! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^8!   
pUnk
		" Answer the IUnknown. "

	^self interfaceAtOffset: 0 type: IUnknown.!  
xUI4
	"Private"
	"Translate the value to a 4-byte unsigned integer."

	^self uLongAtOffset: self valueOffset! 
wMajorVerNum

    ^self uShortAtOffset: 56! 
name: aString 
	memberID: anInteger 
	typeCode: aTypeCode 
		" Answer a new instance of the receiver for the method named <aString>
		which is identified by the DISPID <anInteger> in its dispatch interface.
		The type code <aTypeCode> specifies the type of the method return value. "

	^self new
		name: aString;
		memberID: anInteger;
		typeCode: aTypeCode;
		parameterNames: #( );
		parameterTypes: #( );
		yourself!   
forDescription: aFuncDesc typeInfo: anITypeInfo
		" Answer a new instance of the receiver initialized for the method 
		described by the FUNCDESC <descr>.  Additional type information
		is proved by the ITypeInfo interface <anITypeInfo>. "

	| names |
	names := anITypeInfo getNames: aFuncDesc memberID 
		count: aFuncDesc parameterCount + 1.
	^self name: ( names at: 1 )
		memberID: aFuncDesc memberID
		typeCode: ( aFuncDesc typeCodeUsing: anITypeInfo )
		parameterNames: ( names copyFrom: 2 to: names size )
		parameterTypes: ( aFuncDesc parameterTypeCodesUsing: anITypeInfo )!  
name: aString 
	memberID: anInteger 
	typeCode: aTypeCode 
	parameterNames: anArrayOfStrings
	parameterTypes: anArrayOfTypeCodes
		" Answer a new instance of the receiver for the method named <aString>
		which is identified by the DISPID <anInteger> in its dispatch interface.
		The type code <aTypeCode> specifies the type of the method return value. "

	^self new
		name: aString;
		memberID: anInteger;
		typeCode: aTypeCode;
		parameterNames: anArrayOfStrings;
		parameterTypes: anArrayOfTypeCodes;
		yourself! 
name: aString 
	memberID: anInteger 
	typeCode: aTypeCode 
	parameters: parameterDescriptionPairs
		" Answer a new instance of the receiver for the method named <aString>
		which is identified by the DISPID <anInteger> in its dispatch interface.
		The parameters are described by an array of name/type pairs.
		The type code <aTypeCode> specifies the type of the method return value. "

	^self new
		name: aString;
		memberID: anInteger;
		typeCode: aTypeCode;
		parameterNames: ( parameterDescriptionPairs 
			collect: [ :arr | arr at: 1 ] );
		parameterTypes: ( parameterDescriptionPairs 
			collect: [ :arr | arr at: 2 ] );
		yourself!   
constructIncomingPropertySpecificationTable: aTypeAttr typeInfo: anITypeInfo
		" Answer a dispatch specification table which contains
		the specifications for the property member functions
		described by <aTypeAttr> and <aITypeInfo>.  
		The specification table is indexed by the DISPID of the 
		property member by which clients invoke its get/set operation.
		Each property specification defines the message selectors
		which are sent to get or set the value of the property. "

	^self constructPropertySpecificationTable: aTypeAttr 
		typeInfo: anITypeInfo
		direction: 'incoming'!   
constructMethodSpecificationTable: aTypeAttr typeInfo: anITypeInfo
		" Answer a dispatch specification table which contains
		the specifications for the method member functions
		described by <aTypeAttr> and <aITypeInfo>.  
		The specification table is indexed by the function selector 
		by which the method is invoked. "

	^self constructMethodSpecificationTable: aTypeAttr 
		typeInfo: anITypeInfo
		direction: 'outgoing'!
constructPropertySpecificationTable: aTypeAttr
	typeInfo: anITypeInfo
	direction: incomingOrOutgoing
		" Answer a dispatch specification table which contains
		the specifications for the property member functions
		described by <aTypeAttr> and <anITypeInfo>.  
		For an outgoing dispatch interface, the specification table
		is indexed by the property name, while for an incoming
		dispatch interface it is indexed by the DISPID of the
		property member.  Each property specification defines
		the message selectors which are sent to get or set the
		value of the property. "

	| nVariables nFunctions aDispatchSpecificationTable
	  aDispatchSpecification aVarDesc aFuncDesc names
	  aPropertyName keyValue |

	nVariables := aTypeAttr variableCount.
	nFunctions := aTypeAttr functionCount.
	aDispatchSpecificationTable := Dictionary new: nVariables.

	" construct the simple get/set property specifications "
	1 to: nVariables do:
		[ :index |
		aVarDesc := anITypeInfo getVarDesc: index - 1.
		aVarDesc isDispatch
			ifTrue: [
				aDispatchSpecification := OLEDispatchPropertySpecification 
					forDescription: aVarDesc 
					typeInfo: anITypeInfo.
				aDispatchSpecificationTable 
					at: ( incomingOrOutgoing = 'incoming'
						ifTrue: [ aDispatchSpecification memberID ]
						ifFalse: [ aDispatchSpecification name ] )
					put: aDispatchSpecification ] .
		aVarDesc release ].

	" construct the property specifications for parameterized get/set functions "
	1 to: nFunctions do:
		[ :index |
		aFuncDesc := anITypeInfo getFuncDesc: index - 1.
		aFuncDesc isRestricted 
			ifFalse: [
				( aFuncDesc isPropertyGet
				or: [ aFuncDesc isPropertyPut
				or: [ aFuncDesc isPropertyPutRef ] ] )
					ifTrue: [
						names := anITypeInfo getNames: aFuncDesc memberID 
							count: 1.
						aPropertyName := names at: 1.
						keyValue := ( incomingOrOutgoing = 'incoming'
							ifTrue: [ aFuncDesc memberID ]
							ifFalse: [ aPropertyName ] ).
						aDispatchSpecification := aDispatchSpecificationTable at: keyValue
							ifAbsent: [ nil ].
						aDispatchSpecification isNil
							ifTrue: [
								aDispatchSpecification := OLEDispatchParameterizedPropertySpecification 
									forDescription: aFuncDesc 
									typeInfo: anITypeInfo.
								aDispatchSpecificationTable at: keyValue
									put: aDispatchSpecification ]
							ifFalse: [  " merge the get/set info with the previously processed set/get info "
								aDispatchSpecification mergeOperationDescription: aFuncDesc 
									typeInfo: anITypeInfo ].
						"incomingOrOutgoing = 'outgoing'
							ifTrue: [ self ASSERT: aDispatchSpecification name = aPropertyName ]."
						].
				].
		aFuncDesc release ].
	^aDispatchSpecificationTable!
constructEventSinkSpecificationTable: aTypeAttr typeInfo: anITypeInfo
		" Answer a dispatch specification table for an event sink
		to which event notifications are being dispatched.
		The event sink dispatch specification table is indexed by 
		the DISPID of the event member for which a notification
		is being received. "

	| nEvents aDispatchSpecificationTable 
	  aFuncDesc aDispatchSpecification |

	nEvents := aTypeAttr functionCount.
	aDispatchSpecificationTable := Dictionary new: nEvents.

	1 to: nEvents do:
		[ :index |
		aFuncDesc := anITypeInfo getFuncDesc: index - 1.
		aFuncDesc == nil
			ifTrue: [  " should not be... "
				OLEDevelopmentWarning signal: 
					'Problem constructing event specifications (no FUNCDESC for index ',
					index printString, ').' ]
			ifFalse: [ 
				aDispatchSpecification := OLEDispatchMethodSpecification 
					forDescription: aFuncDesc 
					typeInfo: anITypeInfo.
				aDispatchSpecificationTable 
					at: aDispatchSpecification memberID 
					put: aDispatchSpecification.
				aFuncDesc release ].
		].
	^aDispatchSpecificationTable
!   
constructIncomingMethodSpecificationTable: aTypeAttr typeInfo: anITypeInfo
		" Answer a dispatch specification table which contains
		the specifications for the method member functions
		described by <aTypeAttr> and <aITypeInfo>.  
		The specification table is indexed by the DISPID of the 
		function member by which method is invoked. "

	^self constructMethodSpecificationTable: aTypeAttr 
		typeInfo: anITypeInfo
		direction: 'incoming'!
forDescription: aMemberDesc typeInfo: anITypeInfo
		" Answer a new instance of the receiver initialized for the member 
		described by the type library member description structure <aMemberDesc>.  
		Additional type information is proved by the ITypeInfo interface <anITypeInfo>. "

	self implementedBySubclass!  
constructPropertySpecificationTable: aTypeAttr typeInfo: anITypeInfo
		" Answer a dispatch specification table which contains
		the specifications for the property member functions
		described by <aTypeAttr> and <aITypeInfo>.  
		The specification table is indexed by the property name.
		Each property specification defines the message selectors
		which are sent to get or set the value of the property. "

	^self constructPropertySpecificationTable: aTypeAttr 
		typeInfo: anITypeInfo
		direction: 'outgoing'! 
constructMethodSpecificationTable: aTypeAttr 
	typeInfo: anITypeInfo
	direction: incomingOrOutgoing
		" Answer a dispatch specification table which contains
		the specifications for the method member functions
		described by <aTypeAttr> and <anITypeInfo>.  
		For an outgoing dispatch interface, the specification table
		is indexed by the function selector, while for an incoming
		dispatch interface it is indexed by the DISPID of the
		method member. "

	| nFunctions aDispatchSpecificationTable 
	  aFuncDesc aDispatchSpecification |

	nFunctions := aTypeAttr functionCount.
	aDispatchSpecificationTable := ( incomingOrOutgoing = 'incoming'
		ifTrue: [ Dictionary ]
		ifFalse: [ IdentityDictionary ] )
			new: nFunctions.

	" construct the method specifications "
	1 to: nFunctions do:
		[ :index |
		aFuncDesc := anITypeInfo getFuncDesc: index - 1.
		aFuncDesc isRestricted 
			ifFalse: [
				aFuncDesc isDispatch
					ifTrue: [
						aDispatchSpecification := OLEDispatchMethodSpecification		
							forDescription: aFuncDesc 
							typeInfo: anITypeInfo.
						aDispatchSpecificationTable 
							at: ( incomingOrOutgoing = 'incoming'
								ifTrue: [ aDispatchSpecification memberID ]
								ifFalse: [ aDispatchSpecification selector ] )
							put: aDispatchSpecification ].
				].
		aFuncDesc release ].
	^aDispatchSpecificationTable!
selector: aSymbol
		"Set the selector of the receiver to <aSymbol>."

	selector := aSymbol.!   
name: aString
		"Set the receiver's name to be <aString>."

	super name: aString.
	self createSelector.!  
parameterTypes: anArray
		"Set the receiver's parameter types to be <anArray>."

	parameterTypes := anArray.!  
parameterNames: anArray
		"Set the receiver's parameter names to be <anArray>."

	parameterNames := anArray.
	self createSelector.!   
parameterNames
		"Answer the parameter names of the receiver."

	^parameterNames!  
parameterTypes
		"Answer the parameter types of the receiver."

	^parameterTypes!  
selector
		"Answer the selector of the receiver."

	^selector! 
isMethodSpecification
		" Answer whether the receiver is a method member specification. "

	^true! 
createSelector
		" Private - create the selector used to invoke the
		method described by the receiver. "

	| str n |
	( self name == nil or: [ self parameterNames == nil ] )
		ifTrue: [^self].
	str := WriteStream on: ( String new: self name size * 2 ).
	str nextPutAll: self name.
	n := self parameterNames size.
	n > 0
		ifTrue: [
			str nextPut: $:.
			n - 1 timesRepeat: [str nextPutAll: 'with:' ] ].
	self selector: str contents asSymbol.!
typeCode: anInteger
		"Set the receiver's type code to be <anInteger>."

	typeCode := anInteger!   
memberID: anInteger
		"Set the receiver's member ID to the DISPID <anInteger>."

	memberID := anInteger!   
name
		"Answer the name of the receiver."

	^name! 
name: aString
		"Set the receiver's name to be <aString>."

	name := aString.! 
memberID
		"Answer the DISPID member ID of the receiver."

	^memberID! 
typeCode
		"Answer the type code of the receiver."

	^typeCode!
printOn: aStream
		" Append a text representation of the receiver to <aStream>. "

	super printOn: aStream.
	self name notNil
		ifTrue: [
			aStream
				nextPutAll: ' ( ';
				nextPutAll: self name;
				nextPutAll: ', DISPID ';
				nextPutAll: self memberID printString;
				nextPutAll: ' )' ].!
isPropertySpecification
		" Answer whether the receiver is a property member specification. "

	^false!
isMethodSpecification
		" Answer whether the receiver is a method member specification. "

	^false!
printOn: aStream
		"Append the receiver as a quoted string
         to aStream doubling all internal single
         quote characters."

    aStream nextPut: $<.
    self isValid
        ifTrue: [ 
            self do: [ :character |
                aStream nextPut: character.
                character = $'
                    ifTrue: [ aStream nextPut: character ] ] ]
        ifFalse: [ aStream nextPutAll: 'invalid BSTR' ].
    aStream nextPut: $>!
hi: anInteger

	^self longAtOffset: 4 put: anInteger!   
typeCode: anInteger
	"Set the type code to <anInteger>."

	self vt: anInteger! 
isReference
	"Answer <true> if the receiver's value is passed by reference."

	^false! 
setAccessor: aVariantValue

	aVariantValue contents: (ByteArray new: self elementSize).
	self accessor: aVariantValue! 
connectionsEnumerator
		" Answer an enumerator on the currently connected event advise sinks
		registered on this connection point. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumConnections ) asValueReference.
	interface EnumConnections: resultReference.
	^resultReference value! 
connections
		" Answer the currently connected event advise sinks
		registered on this connection point. "

	| anEnumerator contents |
	anEnumerator := self connectionsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!
syskind: anInteger
        " Set the target hardware platform of the type library. "

    self longAtOffset: 20 put: anInteger.!   
isVARIANT
	"Answer <true> if the receiver supports the VARIANT protocol."

	^true! 
invokeMethod: dispidMember with: dispatchParameters
		" Invoke the method identified by the DISPID <dispidMember>.
		Answer the result value (nil if none). "

	^self invokeMethod: dispidMember 
		with: dispatchParameters 
		localeID: STDOLE_LCID 
		result: OLEDispatchValueReference new!
lo

	^self uLongAtOffset: 0!
idldescType

	^self structureAtOffset: 68 type: #IDLDESC!   
description
		" Answer a textual, human-readable description of the error. "

	^self stringFromBSTR: self bstrDescription! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^8!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #TYPEDESC for: self.!  
systemIdentifier
	"Answer the code that identifies the operating system this library was built for."

	^self syskind!  
typeCount
	"Answer the number of types contained in this interface."

	^self cImplTypes!   
typeInterface
		" Answer the type library interface from which the receiver was obtained. "

	^typeInterface!  
typeInterface: anInterface
		" Set the type library interface from which the receiver was obtained. 
		This is not a separate reference counted copy of the interface.
		The client of the type library interfaces and these structures must
		ensure that the interface from which this structure was obtained
		is not released until the structures obtained from it are all released. "

	typeInterface := anInterface.
	typeInterface isNil
		ifTrue: [ self doesNotNeedFinalization ]
		ifFalse: [ self needsFinalization ].! 
releaseResources
	" Private - release resources owned by the receiver. "

	typeInterface == nil
		ifTrue: [ ^self ].
	[ typeInterface isValid
		ifTrue: [self releaseStructure]
		ifFalse: [
			OLEDevelopmentWarning signal:
				'Unable to release ' , self class name , ' (interface already released)' ]
		] ensure:
			[ typeInterface := nil ].
	self contents invalidate.
	super releaseResources!
releaseStructure
		" Private - release the receiver back to the interface from whence it came. "

	self implementedBySubclass.!
value: aValue
    "Set the variant value to the external representation of <aValue>.  The type of the UNION field is specified by the VARTYPE value in the vt field."

    | safeArrayClass |
    ( aValue isOLEStructure and: [ aValue isVARIANT ] )
        ifTrue: [ ^aValue convertTo: self ].
	( OLEVariant isArrayType: self typeCode )
        ifTrue: [
            safeArrayClass := OLEStructure classForStructureNamed: #SAFEARRAY.
            aValue isCollection
                ifTrue: [ ^self safeArrayStructure:
                    ( safeArrayClass fromCollection: aValue using: self safeArrayAccessor ) ].
            ( aValue isOLEStructure and: [ aValue isKindOf: safeArrayClass ] )
                ifTrue: [ ^self safeArrayStructure: aValue ].
            ^self error: 'Collection required for variant type ARRAY.' ].
    self setBasicValue: aValue.!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #IDLDESC.!   
cScodes

    ^self shortAtOffset: 30!   
bstrSource: aBstrAddress
		" Private - set a textual, human-readable name of the source of the exception
		(typically the application name). "

	self addressAtOffset: 4 put: aBstrAddress.!  
xUI2
	"Private"
	"Translate the value to a 2-byte unsigned integer."

	^self uShortAtOffset: self valueOffset!
isReferenceType: aTypeCode
		" Answer whether <aTypeCode> is a reference type. "

	^( aTypeCode bitAnd: VT_BYREF ) = VT_BYREF! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^16!  
removeEnumeratorIID
		" Private - remove the registration of the IID of the interface which 
		enumerates collections containing instances of the receiver. "

	IEnum removeEnumeratorIID: self enumeratorIID.!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #CURRENCY.!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #TYPEDESC.!  
dwCookie: anInteger
		" Set the magic cookie connection token. "

	self uLongAtOffset: 4 put: anInteger.!  
removeEnumeratorIID
		" Private - remove the registration of the IID of the interface which 
		enumerates collections containing instances of the receiver. "

	IEnum removeEnumeratorIID: self enumeratorIID.!   
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^16!  
xVARIANT
	"Private"
	"This is illegal since VARIANTs may only be passed by reference."

	^self xIllegal!  
fromNumber: aNumber
	"Answer an instance of the receiver that represents the unscaled numeric value <aNumber> in type CURRENCY."

	^self new value: aNumber!   
syskind
        " Answer the target hardware platform of the type library. "

    ^self longAtOffset: 20!  
arguments: anArray
    "Set the arguments to the VARIANTARGS in <anArray>."

    | nArgs variantArgSize variantArgAddress variantArgs variant |
    (nArgs := anArray size) = 0
        ifTrue: [^self].
    variantArgSize := OLEStructure sizeOfStructureNamed: #VARIANTARG.
    variantArgAddress := OLEMemoryAddress allocateMemory: nArgs * variantArgSize.
    variantArgAddress doesNotNeedFinalization.
    self ISSUE. "What's the right way to get a block of memory that won't be reclaimed?"
    variantArgs := ExternalBuffer atAddress: variantArgAddress.
    "The arguments are packed from last to first."
    1 to: nArgs do:
        [:index |
        variant := anArray at:     nArgs - index + 1.
        variantArgs bytesAtOffset: (index - 1) * variantArgSize put: variant contents].
    self
        cArgs: nArgs;
        rgvarg: variantArgAddress!   
bstrSource
		" Answer a textual, human-readable name of the source of the exception
		(typically the application name). "

	^self bstrAtAddress: ( self addressAtOffset: 4 )! 
fromDATEValue: aFloat
		" Answer a new instance of the receiver for the double-precision VT_DATE value <aFloat>. "

	^self new value: aFloat!  
xNULL: aValue
	"Private"
	"Store 0 to represent NULL."

	self uLongAtOffset: self valueOffset put: 0.!
do: aBlock
        "Answer the receiver.  For each character in the receiver,
         evaluate <aBlock> with that character as the argument."

    1 to: self size do: [ :i |
        aBlock value: (self at: i) ].!
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #TLIBATTR for: self.!  
variableValueDescription
	"Answer the type and IDL descriptions of the variable's value."

	^self elemdescVar! 
sizeInBytes
		" Private - answer the size in bytes of the receiver. "

    ^4 + ( self uLongAtOffset: 0 )
!   
bstrHelpFile
		" Answer the fully qualified path name of a Help file
		which contains information about the error. "

	^self bstrAtAddress: ( self addressAtOffset: 12 )! 
valueDescription
		" Answer a string describing the value of the receiver. "

	^[ self value printString ]
		on: Error
		do: [ ^'(illegal value type)' ]!
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #VARIANT for: self.!   
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
                , aCharacter class name ].!
xBOOL
	"Private"
	"Translate the value to a boolean."

	" VARIANT_BOOL: 0 == FALSE, -1 == TRUE "
	^( VARIANT_FALSE = ( self shortAtOffset: self valueOffset ) ) not! 
wMajorVerNum: anInteger
        " Set the major version number of the type library. "

    self uShortAtOffset: 24 put: anInteger.!
invokePropertyGet: dispidMember with: dispatchParameters localeID: lcid
		" Answer the value of the property identified by the DISPID <dispidMember>. "

	^self invoke: dispidMember
		localeID: lcid
		flags: DISPATCH_PROPERTYGET
		parameters: dispatchParameters
		result: OLEDispatchValueReference new!  
stringFromBSTR: aBSTR
		" Private - answer the string value of <aBSTR>. "

	^aBSTR isNil
		ifTrue: [ nil ]
		ifFalse: [ aBSTR asString ]!
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^6!   
typeCode: anInteger
	"Set the receiver's type code to be <anInteger>."

	typeCode := anInteger!
valueOffset
	" Private - answer the offset of the value UNION field. "

	^0!   
xBSTR: anObject
	"Private"
	"Store <anObject> as a BSTR."

	| value |
	anObject isString
		ifTrue: [
			value := BSTRMemoryAddress allocateString: anObject.
			value doesNotNeedFinalization ]
		ifFalse: [ value := anObject ].
	self contents: ( ExternalAddress usingBytes: value contents )!   
typeCode
	"Answer the type code of the receiver."

	^typeCode! 
byteIndexOfCharAt: anInteger
        "Private - answer the index of the first byte of
          the character at <anInteger> in the receiver. "

	^anInteger + anInteger + 2
!   
forDescription: aFuncDesc typeInfo: anITypeInfo
		" Answer a new instance of the receiver initialized for the property 
		described by the FUNCDESC <aFuncDesc>.  Additional type information
		is proved by the ITypeInfo interface <anITypeInfo>. "

	| names aDispatchSpecification |
	names := self getNamesFromDescription: aFuncDesc 
		typeInfo: anITypeInfo.
	aDispatchSpecification := self new
		name: ( names at: 1);
		memberID: aFuncDesc memberID;
		yourself.
	aDispatchSpecification mergeParameterDescription: aFuncDesc
		typeInfo: anITypeInfo
		names: ( names copyFrom: 2 to: names size ).
	^aDispatchSpecification

! 
nameFromDescription: aFuncDesc typeInfo: anITypeInfo
		" Answer the name of the property described by
		the FUNCDESC <aFuncDesc>.  Additional type information
		is proved by the ITypeInfo interface <anITypeInfo>. "

	^( self getNamesFromDescription: aFuncDesc typeInfo: anITypeInfo )
		at: 1!
getNamesFromDescription: aFuncDesc typeInfo: anITypeInfo
		" Private - answer the names of the property and its arguments described by
		the FUNCDESC <aFuncDesc>.  Additional type information
		is proved by the ITypeInfo interface <anITypeInfo>. "

	| names |
	names := anITypeInfo getNames: aFuncDesc memberID 
		count: aFuncDesc parameterCount + 1.
	^names!   
name: aString memberID: anInteger typeCode: aTypeCode
		" Answer a new instance of the receiver for the property named <aString>
		which is identified by the DISPID <anInteger> in its dispatch interface.
		The type code <aTypeCode> specifies the type of the property value. "

	^self new
		name: aString;
		memberID: anInteger;
		typeCode: aTypeCode;
		yourself!   
forDescription: aVarDesc typeInfo: anITypeInfo
		" Answer a new instance of the receiver initialized for the property 
		described by the VARDESC <aVarDesc>.  Additional type information
		is proved by the ITypeInfo interface <anITypeInfo>. "

	| propertyName |
	propertyName := self nameFromDescription: aVarDesc 
		typeInfo: anITypeInfo.
	^self name: propertyName
		memberID: aVarDesc memberID
		typeCode: ( aVarDesc typeCodeUsing: anITypeInfo )!
nameFromDescription: aVarDesc typeInfo: anITypeInfo
		" Answer the name of the property described by
		the VARDESC <aVarDesc>.  Additional type information
		is proved by the ITypeInfo interface <anITypeInfo>. "

	| names |
	names := anITypeInfo getNames: aVarDesc memberID 
		count: 1.
	^names at: 1! 
isWriteOnly
		" Answer whether the property described by the receiver is write-only. "

	^self typeCode == nil!
mergeParameterDescription: aFuncDesc typeInfo: anITypeInfo names: names
		" Private - merge the parameter and type information for the property get/set function
		described by the FUNCDESC <aFuncDesc> into the receiver.
		<anITypeInfo> is the ITypeInfo interface that provides additional type information. "

	| typeCodes |

	self parameterNames isNil
		ifTrue: [ self parameterNames: names ]
		"ifFalse: [ self ASSERT: self parameterNames = names ]".

	typeCodes := aFuncDesc parameterTypeCodesUsing: anITypeInfo.
	self parameterTypes isNil
		ifTrue: [ self parameterTypes: typeCodes ]
		ifFalse: [ 
			aFuncDesc isPropertyGet
				ifTrue: [  " we already saw the put specification for this property "
					"self ASSERT: ( parameterTypes copyFrom: 1 to: parameterTypes size - 1 ) = typeCodes."
					].
			( aFuncDesc isPropertyPut
			or: [ aFuncDesc isPropertyPutRef ] )
				ifTrue: [   " we already saw the get specification for this property "
					"self ASSERT: parameterTypes = ( typeCodes copyFrom: 1 to: typeCodes size - 1 )."
					self parameterTypes: typeCodes ].
			].

	aFuncDesc isPropertyGet
		ifTrue: [
			self typeCode: ( aFuncDesc typeCodeUsing: anITypeInfo ).
			self createGetSelector ].
	( aFuncDesc isPropertyPut
	or: [ aFuncDesc isPropertyPutRef ] )
		ifTrue: [
			self putResultTypeCode: ( aFuncDesc typeCodeUsing: anITypeInfo ).
			self createSetSelector ].
!  
parameterNames
		"Answer the parameter names of the receiver."

	^parameterNames!  
parameterTypes
		"Answer the parameter types of the receiver."

	^parameterTypes!  
putResultTypeCode
		"Answer the put result type code of the receiver."

	^putResultTypeCode!   
createSetSelector
		" Private - create the selector used to set the value
		of the property described by the receiver. "

	| str n |
	str := WriteStream on: ( String new: self name size * 2 ).
	str nextPutAll: 'set'.
	str nextPutAll: self name.
	n := self parameterTypes size.
	n > 0
		ifTrue: [
			str nextPut: $:.
			n - 1 timesRepeat: [ str nextPutAll: 'with:' ] ].
	self setSelector: str contents asSymbol.!  
createGetSelector
		" Private - create the selector used to get the value
		of the property described by the receiver. "

	| str n |
	str := WriteStream on: (String new: self name size * 2).
	str nextPutAll: 'get'.
	str nextPutAll: self name.
	self putResultTypeCode == nil
		ifTrue: [n := self parameterTypes size]
		ifFalse: [n := self parameterTypes size - 1].
	n > 0
		ifTrue:
			[str nextPut: $:.
			n - 1 timesRepeat: [str nextPutAll: 'with:']].
	self getSelector: str contents asSymbol.! 
putResultTypeCode: anInteger
		"Set the receiver's put result type code to be <anInteger>."

	putResultTypeCode := anInteger.! 
mergeOperationDescription: aFuncDesc typeInfo: anITypeInfo
		" Merge the parameter and type information for the property get/set function
		described by the FUNCDESC <aFuncDesc> into the receiver.
		<anITypeInfo> is the ITypeInfo interface that provides additional type information. 
		This service is used to merge the propert set specifications when the 
		receiver was constructed from the property specification or vice versa. "

	| names |
	names := self class getNamesFromDescription: aFuncDesc 
		typeInfo: anITypeInfo.
	( self name = ( names at: 1 )
	and: [ self memberID = aFuncDesc memberID ] )
		ifFalse: [ self error: 'merge must be the same property' ].
	self mergeParameterDescription: aFuncDesc
		typeInfo: anITypeInfo
		names: ( names copyFrom: 2 to: names size ).!  
hasParameters
		" Answer whether the receiver has parameters. "

	^true!   
parameterNames: anArray
		"Set the receiver's parameter names to be <anArray>."

	parameterNames := anArray.!  
parameterTypes: anArray
		"Set the receiver's parameter types to be <anArray>."

	parameterTypes := anArray.
	self createSelectors.!  
createSelectors
		" Private - create the selectors used to get and set the value
		of the property described by the receiver.
		Do nothing for the receiver, since selectors are created 
		when get/put method is analyzed. "!   
isReadOnly
		" Answer whether the property described by the receiver is read-only. "

	^self putResultTypeCode == nil! 
name: aString
		"Set the receiver's name to be <aString>."

	super name: aString.
	self createSelectors.! 
setSelector: aSymbol
		" Set the selector which is sent to set the value of the property. "

	setSelector := aSymbol.! 
setSelector
		" Answer the selector which is sent to set the value of the property. "

	^setSelector!  
isWriteOnly
		" Answer whether the property described by the receiver is write-only. "

	^self getSelector isNil!  
isPropertySpecification
		" Answer whether the receiver is a property member specification. "

	^true! 
createSetSelector
		" Private - create the selector used to set the value
		of the property described by the receiver. "

	self setSelector: ( 'set', self name, ':' ) asSymbol.! 
createGetSelector
		" Private - create the selector used to get the value
		of the property described by the receiver. "

	self getSelector: ( 'get', self name ) asSymbol.!  
hasParameters
		" Answer whether the receiver has parameters. "

	^false!  
createSelectors
		" Private - create the selectors used to get and set the value
		of the property described by the receiver. "

	self name == nil
		ifTrue: [ ^self ].
	self createGetSelector.
	self createSetSelector!  
isReadOnly
		" Answer whether the property described by the receiver is read-only. "

	^self setSelector isNil!
getSelector: aSymbol
		" Set the selector which is sent to get the value of the property. "

	getSelector := aSymbol.! 
getSelector
		" Answer the selector which is sent to get the value of the property. "

	^getSelector!  
cArgs
		" Answer the number of arguments. "

	^self uLongAtOffset: 8!  
cParamsOpt

    ^self shortAtOffset: 26!
xCY
	"Private"
    "Translate the value to a CURRENCY."

	^self structureAtOffset: self valueOffset type: #CURRENCY!  
safeArrayAccessor
	"Private"

	| accessor |
	accessor := SafeArrayAccessor new.
	accessor typeCode: self baseTypeCode.
	accessor contents: ( ByteArray new: 8 ).
	^accessor!   
at: address using: variantAccessor
    "Create a new instance of the receiver on the external structure at <address> typed according to <variantAccessor>."

    | aSafeArray |
    aSafeArray := self atAddress: address.
    aSafeArray accessor: variantAccessor.
    ^aSafeArray!   
description: aString
		" Specify a textual, human-readable description of the error. "

	self bstrDescription: ( BSTRMemoryAddress allocateString: aString ).! 
isArrayType: aTypeCode
		" Answer whether <aTypeCode> is an array type. "

	^( aTypeCode bitAnd: VT_ARRAY ) = VT_ARRAY!
accessor
	"Answer the accessor of the receiver."

	^accessor!  
supportsDispatchIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^self supportedIIDs includes: anIID! 
allocateString: aString
        " Allocate a BSTR in external memory and copy the characters 
		of <aString> into it.  Answer a new instance of the receiver 
		with the address of the BSTR copy in external memory. "

	^self atAddress: ( BSTRMemoryAddress allocateString: aString )!
isDispatch

	^self varkind = VAR_DISPATCH!  
typeCodeNameMap: aDictionary
		" Private - set the mapping dictionary from type code values to names. "

	TypeCodeNameMap := aDictionary.! 
xDISPATCH: aValue
	"Private"
	"Store <aValue> as an IDispatch."

	( aValue isOLEInterface not
	or: [ ( IDispatch supportsIID: aValue iid ) not ] )
		ifTrue: [ self error: 'IDispatch required' ].
	self interfaceAtOffset: self valueOffset put: aValue asParameter.! 
supportsIID: aGUID
		" Answer whether the receiver represents the interface identified
		by the IID <aGUID>. "

	^( super supportsIID: aGUID )
		or: [ IDispatch supportsDispatchIID: aGUID ]!   
typeCodeUsing: iTypeInfo
	"Answer the integer that identifies the type of the element."

	^self typeDescription typeCodeUsing: iTypeInfo!  
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	iDispatch notNil
		ifTrue: [ aOneArgBlock value: iDispatch ].!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the Guid <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = IID_IDispatch
		ifTrue: [ ^iDispatch ].
	^nil! 
initializeInterfaces
		" Private - Allocate any interfaces which are expected to be required 
		during the object's lifetime. "

	super initializeInterfaces.
	iDispatch := self createIDispatch.!   
Invoke: dispidMember
	_: iid
	_: lcid
	_: wFlags
	_: dispParams
	_: resultReference
	_: exceptionInfoReference
	_: argErrorReference
		" Private - implement the IDispatch::Invoke function. 
		Must be reimplemented by subclasses. "

	^self unimplementedFunction!  
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iDispatch := nil.!  
dispatchInterface
		" Answer the dispatch interface supported by the receiver.
		Note that this is not a separately reference counted copy of the interface. "

	^iDispatch!  
dispatchInterface: anInterface
		"Private - set the dispatch interface supported by the receiver."

	iDispatch := anInterface.!
GetTypeInfo: itinfo _: lcid _: resultReference
		" Private - Implement the IDispatch::GetTypeInfo function.
		May be reimplemented by subclasses which can provide
		type information about their members. "

	^self unimplementedFunction!  
GetTypeInfoCount: resultReference
		" Private - implement the IDispatch::GetTypeInfoCount function. 
		May be reimplemented by subclasses which can provide
		type information about their members. "

	resultReference value: 0.
	^S_OK!   
valueAdaptor: aValueAdaptor
		" Specify the adaptor which manages transformations between
		Smalltalk values and OLE dispatch parameters for the receiver. "

	valueAdaptor := aValueAdaptor.!
valueAdaptor
		" Answer the adaptor which manages transformations between
		Smalltalk values and OLE dispatch parameters for the receiver. "

	^valueAdaptor! 
GetIDsOfNames: iid _: nameList _: cNames _: lcid _: resultReference
		" Private - Implement the IDispatch::GetIDsOfNames function.
		May be reimplemented by subclasses which can map
		dispatch member names to the correspoding DISPID value. "

	^self unimplementedFunction! 
initialize
		" Private - initialize a new instance. "

	super initialize.
	self valueAdaptor: OLEDispatchValueAdaptor new.!   
createIDispatch
		" Private - create an IDispatch interface on the receiver. "

	^IDispatch on: self!  
xR4
	"Private"
	"Translate the value to a Float."

	^self singleFloatAtOffset: self valueOffset!  
value: aNumber

	self largeIntegerAtOffset: 0 put: (aNumber * 10000) rounded!   
size
        " Answer the number of characters in the receiver string. "

    ^( self uLongAtOffset:  0 ) / 2
!   
wCode
		" Answer the error code identifying the error. "

	^self shortAtOffset: 0! 
invokePropertyGet: dispidMember with: dispatchParameters
		" Answer the value of the property identified by the DISPID <dispidMember>. "

	^self invokePropertyGet: dispidMember 
		with: dispatchParameters 
		localeID: STDOLE_LCID!   
fromUnicode: aUnicodeString
		" Answer a BSTR containing the characters of <aUnicodeString>. "

	| aBstr |
	aBstr := self new: aUnicodeString size.
	1 to: aUnicodeString size do: [ :i |
		aBstr at: i put: ( aUnicodeString at: i ) ].
	^aBstr!  
unlock
		" Decrement the receiver's lock count so it can be freed or resized. "

	OLEAutomationDLL current SafeArrayUnlock: self.! 
typeCode
	"Answer the type code of the receiver."

	^self implementedBySubclass!   
arrayOfDimensions: dimArray
	"Answer a ExternalBuffer that represents an array of SAFEARRAYBOUND whose size is the size of <dimArray> and whose contents represent the dimensions specified in <dimArray>."

	| size array |
	size := self sizeInBytes.
	array := ExternalBuffer new: size * dimArray size.
	1 to: dimArray size do:
		[:index |
		array uLongAtOffset: index - 1 * size put: (dimArray at: index)].
	^array!
new: anInteger
	"Answer a new instance of the receiver with size <anInteger> bytes."

	^( self basicNew initialSize: anInteger ) initialize!   
tdescAlias

	^self structureAtOffset: 60 type: #TYPEDESC!   
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "
    ^50!
variantTypeMap
		" Private - answer the mapping dictionary from classes to the VARIANT
		type code which is used to encode instances.  Only classes for
		which a well-defined mapping applies to all instances are registered. "

	^VariantTypeMap! 
asOLEVariant
        " Answer the receiver as an OLE VARIANT.
        Answer nil if the receiver cannot be represented
        by a known VARIANT type. "

	^self!   
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."

	^self value! 
elementCount: anInteger

	self cElements: anInteger!
asString
        "Answer the receiver converted to a String.  
		An invalid BSTR is mapped to nil."

    ^self asUnicode asString!
memid

    ^self longAtOffset: 0!   
asFloat

	^(self largeIntegerAtOffset: 0) asFloat / 10000.0!
externalFloatFromInternalFloat: aFloat
		" Answer a 4-byte array that represents <aFloat> as a C type #float,
		where <aFloat> corresponds to the C type #double.  An OLEError will be 
		signaled if <aFloat> cannot be represented as a #float."

	| resultReference |
	resultReference := nil asValueReference.
	OLEAutomationDLL current VarR4FromR8: aFloat _: resultReference.
	^resultReference value! 
releaseResources
	"Private - release resources owned by the receiver.
	The OLE function VariantClear() knows how to interpret type codes and will send release to any values that need it."

	OLEAutomationDLL current VariantClear: self!
releaseStructure
		" Private - release the receiver back to the interface from whence it came. "


	typeInterface releaseVarDesc: self.!  
functionCount
	"Answer the number of functions contained in this interface."

	^self cFuncs!   
initialize
	"Private - Call the C function that knows how to initialize the data of a VARIANT."

	OLEAutomationDLL current VariantInit: self!  
unadvise: connectionToken
		" Revoke an advise connection previously established with IConnectionPoint::Advise.
		Raise an exception if an error occurs.  Answer the result code. "

	^interface Unadvise: connectionToken!   
typeCodeNameOf: aTypeCode
		" Answer the name of the VT type <aTypeCode>. "

	^self typeCodeNameMap at: aTypeCode
		ifAbsent: [  " undefined, probably an initialization problem in the name map "
			aTypeCode <= 8
				ifTrue: [ aTypeCode printString ]
				ifFalse: [ aTypeCode printStringRadix: 16 ] ]!  
enumeratorIID
		" Private - answer the IID of the interface which enumerates
		collections containing instances of the receiver. "

	^IID_IEnumConnections!   
getArrayOfStrings: count fromBSTRArray: bstrArray
		"Private - answer an Array of size <count> filled with Strings 
		extracted from the BSTR array <bstrArray>.  Each BSTR will be released. "

	| bstrSize nameList bstr |
	bstrSize := BSTRMemoryAddress sizeInBytes.
	nameList := Array new: count.
	1 to: count do:
		[ :index |
		bstr := BSTR atAddress:
			( BSTRMemoryAddress fromInteger:
					( bstrArray uLongAtOffset: index - 1 * bstrSize ) ).
		nameList at: index put: bstr asString.
		bstr release].
	^nameList! 
xI4
	"Private"
	"Translate the value to a 4-byte integer."

	^self longAtOffset: self valueOffset!
lpvarValue
    "This is a pointer to a VARIANT, if varkind = VAR_CONST."

    ^self uLongAtOffset: 8!  
memidDestructor

    ^self longAtOffset: 28!
tdesc

	^self structureAtOffset: 0 type: #TYPEDESC! 
vt
	" Answer the VARTYPE of this VARIANT. "

	^self uShortAtOffset: 0! 
cbSizeInstance

    ^self uLongAtOffset: 36!
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #ELEMDESC.!  
printOn: aStream

	| int x y pos |
	int := self largeIntegerAtOffset: 0.
	x := int // 10000.
	y := int \\ 10000.
	x printOn: aStream.
	aStream nextPut: $..
	pos := aStream position.
	y printOn: aStream.
	pos + 4 - aStream position timesRepeat: [aStream nextPut: $0]!  
invokeMethod: dispidMember with: dispatchParameters localeID: lcid
		" Invoke the method identified by the DISPID <dispidMember>.
		Answer the result value (nil if none). "

	^self invokeMethod: dispidMember 
		with: dispatchParameters 
		localeID: lcid 
		result: OLEDispatchValueReference new!
getBasicValue
		" Private - answer the basic value of the variant.
		The type of the UNION field is specified by the VARTYPE value in the vt field. "

	^self perform:
		( DecoderSelectors
			at: self baseTypeCode + 1
			ifAbsent: [ #xIllegal ] )! 
on: anObject
		" Answer a new instance of the receiver which publishes <anObject>
		as an OLE automation object which supports IDispatch. "

	^self new
		publishedObject: anObject;
		yourself!
on: anObject  
	methods: aMethodSpecificationTable 
	properties: aPropertySpecificationTable
		" Answer a new instance of the receiver which publishes <anObject>
		as an OLE automation object which supports a dispatch interface
		with the methods and properties described by 
		<aMethodSpecificationTable> and <aPropertySpecificationTable>. " 

	^self new
		publishedObject: anObject;
		methodSpecificationTable: aMethodSpecificationTable;
		propertySpecificationTable: aPropertySpecificationTable;
		yourself!
on: anObject  properties: aPropertySpecificationTable
		" Answer a new instance of the receiver which publishes <anObject>
		as an OLE automation object which supports a dispatch interface
		with the properties described by <aPropertySpecificationTable>. " 

	^self new
		publishedObject: anObject;
		propertySpecificationTable: aPropertySpecificationTable;
		yourself! 
on: anObject specificationTable: aSpecificationTable
		" Answer a new instance of the receiver which publishes <anObject>
		as an OLE automation object which supports a dispatch interface
		with the methods and properties described by <aSpecificationTable>. "

	^self new
		publishedObject: anObject;
		specificationTable: aSpecificationTable
		yourself!
on: anObject  methods: aMethodSpecificationTable
		" Answer a new instance of the receiver which publishes <anObject>
		as an OLE automation object which supports a dispatch interface
		with the methods described by <aMethodSpecificationTable>. "

	^self new
		publishedObject: anObject;
		methodSpecificationTable: aMethodSpecificationTable;
		yourself!
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #CONNECTDATA.!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #VARDESC for: self.!   
value: aFloat
		" Private - set the value of the receiver to the VT_DATE double-precision value <aFloat> . "

	value := aFloat!
wMajorVerNum
        " Answer the major version number of the type library. "

    ^self uShortAtOffset: 24!   
pathName: aPathName
		" Answer a new instance of the receiver for the type library
		in the file named <aPathName>. "

	| resultReference |
	resultReference := self new asValueReference.
	OLEAutomationDLL current LoadTypeLib: aPathName _: resultReference.
	^resultReference value!   
releaseTLibAttr: aTLibAttr
		" Release a TLIBATTR previously obtained from ITypeLib::GetLibAttr. "

	interface ReleaseTLibAttr: aTLibAttr.!
getTypeInfo: index
		" Answer the <index>-th type description in the type library. "

	| resultReference |
	resultReference := ITypeInfo new asValueReference.
	interface GetTypeInfo: index _: resultReference.
	^resultReference value!   
typeDescriptionCount
		" Answer the number of type descriptions in the type library. "

	^self getTypeInfoCount!   
getTypeInfoCount
		" Answer the number of type descriptions in the type library. "

	^interface GetTypeInfoCount!  
getLibAttr 
		" Answer the library attribute description of the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetLibAttr: resultReference.
	resultReference value typeInterface: self.  " to support releasing "
	^resultReference value! 
isName: aString hash: lHashVal
		" Answer whether <aString> is the name of a type or
		a member in the type library. "

	| resultReference |
	resultReference := nil asValueReference.
	interface IsName: aString _: lHashVal _: resultReference.
	^resultReference value! 
getTypeInfoType: index
		" Answer the type of the <index>-th type description in the type library. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetTypeInfoType: index _: resultReference.
	^resultReference value! 
getTypeInfoOfGuid: aGUID 
		" Answer the type description corresponding to <aGUID> in the type library. "

	| resultReference |
	resultReference := ITypeInfo new asValueReference.
	interface GetTypeInfoOfGuid: aGUID _: resultReference.
	^resultReference value!
getDocumentation: elementId
		" Answer the documentation information about the element 
		specified by <elementId> in the receiver.  The element id
		is an index for a type library or a memberID for a type description. "

	| nameReference docStringReference helpContextIDReference helpFileReference |
	nameReference := nil asValueReference.
	docStringReference := nil asValueReference.
	helpContextIDReference := nil asValueReference.
	helpFileReference := nil asValueReference.
	interface GetDocumentation: elementId 
		_: nameReference 
		_: docStringReference 
		_: helpContextIDReference 
		_: helpFileReference.
	^Dictionary new
		at: 'name' put: nameReference value;
		at: 'documentation' put: docStringReference value;
		at: 'helpContextID' put: helpContextIDReference value;
		at: 'helpFile' put: helpFileReference value;
		yourself! 
getTypeComp
		" Answer a type compiler that can be used to bind to the receiver. "

	| resultReference |
	resultReference := ITypeComp new asValueReference.
	interface GetTypeComp: resultReference.
	^resultReference value!  
valueOffset
	" Private - answer the offset of the value UNION field. "

	^0!   
lpstrSchema

    ^self uLongAtOffset: 4!
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #TYPEATTR.!  
cElements
		" Answer the number of elements in this array dimension. "

	^self uLongAtOffset: 0!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #EXCEPINFO for: self.! 
enumeratorIID
		" Private - answer the IID of the interface which enumerates
		collections containing instances of the receiver. "

	^IID_IEnumConnectionPoints!  
typeCode
	"Answer the type code."

	^self vt!  
isDispatch

	^self invkind = DISPATCH_METHOD!   
new
		" Answer a new instance of the receiver. "

	^super new initialize!  
on: anIDispatch specificationTable: aSpecificationTable
		" Answer a new instance of the receiver which uses 
		the dispatch interface <anIDispatch> to invoke
		dispatch member functions.  The supported functions
		are described by the invocation specifications in
		<aSpecificationTable>. "

	^self new
		dispatchInterface: anIDispatch;
		specificationTable: aSpecificationTable;
		yourself!
on: anIDispatch
		" Answer a new instance of the receiver which uses 
		the dispatch interface <anIDispatch> to invoke
		dispatch member functions. "

	^self new
		dispatchInterface: anIDispatch;
		yourself!
localeID
		" Answer the receiver's locale ID. "

    ^localeID!
specificationNames
		" Answer the dispatch member names defined in the receiver's 
		dispatch specification table. "

	^self specificationTable keys! 
invokeMethod: aMethodName withArguments: argValuesArray result: resultReference
		" Invoke the method named <aMethodName> with the arguments 
		in <argValuesArray>.  Store the result value into the <resultReference>. 
		Answer the result value (nil if none).  Raise an exception if the method is not defined. "

	| aDispatchSpec dispParams resultValue |
	aDispatchSpec := self specificationNamed: aMethodName.
	[
	dispParams := self valueAdaptor parametersForMethod: aDispatchSpec 
		arguments: argValuesArray.
	resultValue := self dispatchInterface invokeMethod: aDispatchSpec memberID
		with: dispParams
		localeID: self localeID
		result: ( aDispatchSpec typeCode = VT_VOID
			ifTrue: [ nil ]
			ifFalse: [ resultReference ] ).
	self valueAdaptor updateReferenceArguments: argValuesArray 
		fromParameters: dispParams.
	] ensure: [
		dispParams release ].
	^resultValue! 
setProperty: propertyName value: aValue
		"Set the value of the control's property named <propertyName> to <aValue>. "

	^self setProperty: propertyName withArguments: ( Array with: aValue )!
release
		" Release the receiver. "

	| anInterface |
	anInterface := dispatchInterface.
	dispatchInterface := nil.
	anInterface release.!  
specificationsDo: aOneArgBlock
		" Enumerate the dispatch specifications defined in the
		receiver's specification table, evaluating <aOneArgBlock> for each. "

	^self specificationTable do: aOneArgBlock!  
dispatchInterface
		"Answer the dispatch interface used by the receiver."

	^dispatchInterface!
dispatchInterface: anIDispatch
		"Set the dispatch interface used by the receiver to <anIDispatch>."

	dispatchInterface := anIDispatch.!  
specificationNamed: aKey
		" Answer the specification identified by the name <aKey>
		in the receiver's dispatch specification table.
		Raise an exception if the member is not supported. "

	^self specificationNamed: aKey
		ifNone: [ OLEError hresult: DISP_E_MEMBERNOTFOUND ]!
specificationTable: aDictionary
		"Set the dispatch specification table of the receiver to <aDictionary>.. "

	^specificationTable := aDictionary! 
invokeMethod: aSelector withArguments: argValuesArray
		" Invoke the control method named <aMethodName> with the arguments 
		in <argValuesArray>.  Answer the result value (nil if none). "

	^self invokeMethod: aSelector 
		withArguments: argValuesArray 
		result: OLEDispatchValueReference new! 
valueAdaptor: aValueAdaptor
		" Specify the adaptor which manages transformations between
		Smalltalk values and OLE dispatch parameters for the receiver. "

	valueAdaptor := aValueAdaptor.!
valueAdaptor
		" Answer the adaptor which manages transformations between
		Smalltalk values and OLE dispatch parameters for the receiver. "

	^valueAdaptor! 
initialize
		" Private - answer a new instance of the receiver. "

	self 
		localeID: STDOLE_LCID;
		valueAdaptor: OLEDispatchValueAdaptor new.! 
getProperty: propertyName withArguments: argValuesArray
        "Answer the value of the control's property named <propertyName>.
        <argValuesArray> is the Array of argument values for a parameterized property.
        Raise an exception if the property is not supported. "

    | aDispatchSpec dispParams propertyValue |
    aDispatchSpec := self specificationNamed: propertyName.
    [
    dispParams := self valueAdaptor parametersForPropertyGet: aDispatchSpec
		arguments: argValuesArray.
    propertyValue := self dispatchInterface invokePropertyGet: aDispatchSpec memberID
        with: dispParams
        localeID: self localeID.
	self valueAdaptor updateReferenceArguments: argValuesArray 
		fromParameters: dispParams.
    ] ensure: [
        dispParams release ].
    ^propertyValue!  
hasSpecificationNamed: aKey
		" Answer whether the receiver has a specification 
		for the dispatch member identified by <aKey> "

	^self specificationTable includesKey: aKey!   
getProperty: propertyName
		"Answer the value of the control's property named <propertyName>."

	^self getProperty: propertyName withArguments: #( )!  
specificationTable
		" Answer the dispatch specification table of the receiver. "

	^specificationTable!   
specificationNamed: aKey ifNone: aBlock
		" Answer the specification identified by the name <aKey>
		in the receiver's dispatch specification table.
		Answer the result of evaluating <aBlock> if the member is not supported. "

	^self specificationTable at: aKey ifAbsent: aBlock!  
localeID: lcid
		" Set the receiver's locale ID. "

	localeID := lcid.!
invokeMethod: aMethodName
		" Invoke the control method named <aMethodName>.  Answer the result value (nil if none). "

	^self invokeMethod: aMethodName 
		withArguments: #( ) 
		result: OLEDispatchValueReference new!
setProperty: propertyName withArguments: argValuesArray
		" Set the value of the control's property named <propertyName> 
		to the last element of <argValuesArray>.  <argValuesArray> is an
		Array of values for an indexed property.  It may contain only one element, 
		the new value, for unindexed properties.
       Raise an exception if the property is not supported. "

	| aDispatchSpec dispParams |
    aDispatchSpec := self specificationNamed: propertyName.
	[
	dispParams := self valueAdaptor parametersForPropertySet: aDispatchSpec 
		arguments: argValuesArray.
	self dispatchInterface invokePropertyPut: aDispatchSpec memberID
		with: dispParams
		localeID: self localeID.
	self valueAdaptor updateReferenceArguments: argValuesArray 
		fromParameters: dispParams.
	] ensure: [
		dispParams release ].!   
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^6!   
supportedIIDs: aCollectionOfIIDs
		" Private - specify the set of dispatch interface IID's that can
		be represented by instances of the receiver. "

	SupportedIIDs := aCollectionOfIIDs.!   
lprgelemdescParam

    ^self uLongAtOffset: 8!  
elementCount

	^self cElements! 
allocateString: aString
        " Allocate a BSTR in external memory and copy the characters 
		of <aString> into it.  Answer a new instance of the receiver 
		with the address of the BSTR copy in external memory. "

	^OLEAutomationDLL current SysAllocString: aString! 
atAddr: anInteger
        "Private - answer the byte at the zero relative offset <anInteger>
        from the receiver. We want an index of zero to correspond to the
        beginning of the actually allocated data, which lies four bytes
        before the pointer value that we actually are at."

    ^super atAddr: anInteger - 4! 
release
    "Release the resources associated with the receiver."

	self ISSUE.  " Review these comments [DL 17-Oct-95] "
 
    "Question: Is the behaviour of sysFreeString well-known? That is, does it just adjust to the
    beginning of the string and free the data using the task allocator? If this were the case, we
    could legally choose to use the task allocator here, though there isn't a lot of point, really,
    in doing that. [Bob 3/95] "

    "NB: It is legit to free a NULL pointer using SysFreeString."
    self isValid
        ifTrue: [
            OLEAutomationDLL current SysFreeString: self.
                    "NB: It is legit to free a NULL pointer using SysFreeString."
            self 
				invalidate; 
				doesNotNeedFinalization ].

    super release.
!  
invalidate
		"Set the receiver to be invalid."

	self contents: self class nullValue contents.
	self doesNotNeedFinalization.!
atAddr: anInteger put: aByte
        "Private - set the byte at the zero relative offset <anInteger>
        in the receiver to <aByte>."

     ^super atAddr: anInteger - 4 put: aByte!  
copyFrom: start to: stop
        "Answer a new collection containing the elements 
		of the receiver indexed from start through stop.  "

	"Note: As with >>atAddr:, we need to offset the indices 
		to the left by four bytes. And we need to be careful 
		of things like shortcut replaceFrom:to:withStartingAt:
		implementations that don't actually go through our at: method."

    | nBytes bytes |
    self isValid 
		ifFalse: [ self error: 'invalid pointer' ].
    nBytes := stop - start + 1.
    bytes := ByteArray new: nBytes.
    1 to: nBytes do: [:i | bytes at: i put: ( self at:  i) ].
    ^bytes! 
destroyReference
		" Destroy this memory reference (without releasing it).
		This service is used to relinquish ownership of the memory. "

	self invalidate.!
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^32!  
upperBound
	"Answer the upper bound of the Nth dimension of the receiver."
	"N is always one for the current implementation."

	| resultReference |
	resultReference := nil asValueReference.
	OLEAutomationDLL current SafeArrayGetUBound: self 
		_: 1 
		_: resultReference.
	^resultReference value! 
dimensions
	"Answer the number of dimensions in the receiver."

	"This should always be one for the current implementation."

	^OLEAutomationDLL current SafeArrayGetDim: self!  
at: anInteger
        "Answer the character at position
         <anInteger> in the receiver string."

    self checkIndex: anInteger.
    ^Character value: ( self uShortAtOffset: ( self byteIndexOfCharAt: anInteger ) )! 
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #DISPPARAMS for: self.!
xDATE
	"Private"
    "Translate the value to a DATE."

    ^OLEDate fromDATEValue: self doubleFloatValue! 
registerEnumeratorIID
		" Private - register the IID of the interface which enumerates
		collections containing instances of the receiver. "

	IEnum
		registerEnumeratorIID: self enumeratorIID
		for: OLE_VARIANT.  " hardwire name so subclass is benign "!  
typeCodeDescriptionOf: aTypeCode
		" Answer a string describing the type code <aTypeCode>. "

	| baseTypeCode baseTypeCodeName description |

	baseTypeCode := self baseTypeCodeOf: aTypeCode.
	baseTypeCodeName := self typeCodeNameOf: baseTypeCode.
	baseTypeCode = aTypeCode
		ifTrue: [ ^baseTypeCodeName ].

	" decode type modifiers "
	description := baseTypeCodeName.
	( self isArrayType: aTypeCode )
		ifTrue: [ description := 'VT_ARRAY | ', description ].
	( self isReferenceType: aTypeCode )
		ifTrue: [ description := description, ' | VT_BYREF' ].
	^description!
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #CURRENCY for: self.!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #SAFEARRAY.! 
xNULL
	"Private"
	"Translate the value to a NULL value."

	^nil!  
releaseResources
		" Private - release resources associated with the receiver. "

	self 
		releaseConnection;
		releaseConnectionInterface.
	super releaseResources.!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the Guid <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = self connectionPointIID
		ifTrue: [ ^self dispatchInterface ]. 
	^super getInterfaceForIID: iid!   
releaseConnection
		" Release the event connection. "

	self registrationToken notNil
		ifTrue: [
			self connectionPointInterface unadvise: self registrationToken.
			self registrationToken: nil ].! 
connectionPointInterface
		" Private - answer the connection point of the object which is generating the events. "

	^connectionPointInterface!
Invoke: dispidMember
    _: iid
    _: lcid
    _: wFlags
    _: dispParams
    _: resultReference
    _: exceptionInfoReference
    _: argErrorReference
        " Private - implement the IDispatch::Invoke function.
        Reflect the received event notification into the image
        as an application event. "

    | eventSpec eventName arguments exceptionInfo |

    wFlags = DISPATCH_METHOD
        ifFalse: [ ^E_INVALIDARG ].
    eventSpec := self specificationTable at: dispidMember
        ifAbsent: [ ^DISP_E_MEMBERNOTFOUND ].

    [
    eventName := eventSpec selector.
    arguments := self valueAdaptor argumentsForMethod: eventSpec
        parameters: dispParams
        localeID: lcid.
    arguments isInteger
        ifTrue: [
            argErrorReference value: arguments.
            ^DISP_E_TYPEMISMATCH ].
    self ifOLETraceEnabled: [
        self oleTRACE: 'OCX Event ', eventSpec name, arguments printString ].
    self triggerEvent: #eventNotification:arguments:
        withArguments: ( Array with: eventName with: arguments ).
    self triggerIndividualEvents
        ifTrue: [ self triggerEvent: eventName withArguments: arguments ].
    ] on: Error
        do: [ :ex |
            exceptionInfo := OLEStructure createStructureNamed: #EXCEPINFO.
            exceptionInfo
                sourceName: 'Smalltalk';
                description: ex description.
            exceptionInfoReference value: exceptionInfo.
            ^DISP_E_EXCEPTION ].
    ^S_OK!  
establishConnectionTo: anInterface
		" Establish an event connection to the event source object 
		which supports <anInterface>. "

	| anIConnectionPointContainer anIConnectionPoint aRegistrationToken |

	" obtain the outgoing dispatch interface of the connection point
		from the event source object "
	anIConnectionPointContainer := anInterface 
		queryInterface: IID_IConnectionPointContainer.
	anIConnectionPointContainer == nil
		ifTrue: [ OLEError hresult: E_NOINTERFACE ].
	anIConnectionPoint := anIConnectionPointContainer 
		findConnectionPoint: self connectionPointIID.
	anIConnectionPointContainer release.
	anIConnectionPoint == nil
		ifTrue: [ OLEError hresult: E_NOINTERFACE ].

	" connect our incoming dispatch interface for the event set to the source "
	aRegistrationToken := anIConnectionPoint advise: self dispatchInterface.
	self 
		connectionPointInterface: anIConnectionPoint;
		registrationToken: aRegistrationToken.!
eventTableForEdit
        "Private - Answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."

    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable! 
releaseEventTable
        "Private - break all connections to event handlers."

    eventTable := nil.!
hasEvent: eventName
		"Answer whether the receiver receives notifications
		for an event named <eventName>."

	self specificationTable isNil
		ifTrue: [ ^false ]. 
	^( self specificationTable detect: [ :each | each selector = eventName ] ifNone: [ nil ] ) ~~ nil! 
registrationToken
		" Private - answer the receiver's registration token.
		Answer nil if the receiver is not registered with OLE. "

	^registrationToken!
registrationToken: anInteger
		" Private - set the receiver's registration token from its OLE registration. "

	registrationToken := anInteger.!   
specificationTable: aDictionary
		"Set the dispatch specification table of the receiver to <aDictionary>.. "

	^specificationTable := aDictionary! 
connectionPointInterface: anIConnectionPoint
		" Private - set the connection point of the object which is generating the events. "

	connectionPointInterface := anIConnectionPoint.! 
GetIDsOfNames: iid _: nameList _: cNames _: lcid _: resultReference
		" Private - Implement the IDispatch::GetIDsOfNames function. "

	"Get IDs of names for the event notifications.
    Map a single member and an optional set of argument names into
    a corresponding set of DISPID's which can be used with IDispatch::Invoke.
    The first element is the DISPID of the member name; subsequent
    elements represent each of the member's parameters.
	Answer the result code."

    | eventName aDispatchSpecification dispidEvent dispidList |
	self ISSUE.  " ^DISP_EUNKNOWNLCID if not supported locale [DL 30-Oct-95] " 
	self ISSUE.  " Steve's original implementation lowercased
		the event name here and did straight equal.  Doesn't
		seem like a good assumption unless lowercase
		was enforced when the event specifications
		were constructed. [DL 30-Oct-95] " 
    eventName := nameList at: 1.
    aDispatchSpecification := self specificationTable 
		detect: [ :each | each name equalsIgnoreCase: eventName ] 
        ifNone: [ nil ].
    dispidEvent := ( aDispatchSpecification == nil
        ifTrue: [ DISPID_UNKNOWN ]
        ifFalse: [ aDispatchSpecification memberID ] ).
	cNames = 1
        ifTrue: [ dispidList := Array with: dispidEvent ]
        ifFalse: [
            dispidList := Array new: cNames.
            dispidList atAllPut: DISPID_UNKNOWN.  " parameter name mappings not supported "
            dispidList at: 1 put: dispidEvent ].
    resultReference value: dispidList.
    ^( dispidEvent = DISPID_UNKNOWN
	or: [ cNames > 1 ] )
        ifTrue: [ DISP_E_UNKNOWNNAME ]
        ifFalse: [ S_OK ]! 
initialize
		" Private - initialize a new instance. "

	super initialize.
	self triggerIndividualEvents: false.!  
releaseConnectionInterface
		" Private - release the connection point. "

	| anInterface |
	self connectionPointInterface notNil
		ifTrue: [
			anInterface := self connectionPointInterface.
			self connectionPointInterface: nil.
			anInterface release ].!   
connectionPointIID
		" Answer the IID of the connection point which is dispatching
		event notifications to the receiver. "

	^connectionPointIID!
createIDispatch
		" Private - create an IDispatch interface on the receiver. "

	^super createIDispatch
		iid: self connectionPointIID;
		yourself!  
eventTable
        "Private - answer the table of event handlers for the receiver."

    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]!
supportedEvents
		"Answer the names of the events for which notifications are receiver. "

	^self specificationTable values collect: [:each | each selector ]! 
specificationTable
		" Answer the dispatch specification table of the receiver. "

	^specificationTable!   
connectionPointIID: anIID
		" Set the IID of the connection point which is dispatching
		event notifications to the receiver to <anIID. "

	connectionPointIID := anIID.! 
triggerIndividualEvents
		" Answer whether the receiver will trigger the individual event when an
		event notification is received.  If false, only the general notification event
		will be triggered. "

	^triggerIndividualEvents!
triggerIndividualEvents: aBoolean
		" Specify whether the receiver will trigger the individual event when an
		event notification is received.  If false, only the general notification event
		will be triggered. "

	triggerIndividualEvents := aBoolean.! 
canTriggerEvent: eventName
        "Answer <true> if the receiver can trigger an event
        named <eventName>."

	^( self triggerIndividualEvents and: [ self hasEvent: eventName ] ) 
		or: [ super canTriggerEvent: eventName ]!
getIDsOfNames: names localeID: lcid
		" Map a set of argument names into the corresponding set of
		DISPID's which can be used with IDispatch::Invoke.
		a corresponding set of DISPID's which can be used with IDispatch::Invoke.
		Raise an exception if an error occurs.  Answer the DISPID's."

	| resultReference |
	resultReference := nil asValueReference
	interface GetIDsOfNames: IID_NULL 
		_: names 
		_: names size 
		_: lcid 
		_: resultReference.
	^resultReference value! 
type: aTypeCode value: aValue
	"Answer a new instance of the receiver that represents <aValue> as type <aTypeCode>."

	^self new
		typeCode: aTypeCode;
		value: aValue;
		yourself!
findConnectionPoint: iid
		" Answer the connection point associated with the IID given by the Guid <iid>. "

	| resultReference |
	resultReference := IConnectionPoint new asValueReference.
	interface FindConnectionPoint: iid _: resultReference.
	^resultReference value!   
connectionPoints
		" Answer the connection points contained in the connectable object. "

	| anEnumerator contents |
	anEnumerator := self connectionPointsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!  
connectionPointsEnumerator
		" Answer an enumerator on the connection points contained in the connectable object. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumConnectionPoints ) asValueReference.
	interface EnumConnectionPoints: resultReference.
	^resultReference value!  
getConnectionInterface
		" Answer the IID Guid of the interface for which this
		connection point is able to call implementations (the 'name'
		of the connection point). "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetConnectionInterface: resultReference.
	^resultReference value!  
cbAlignment

    ^self uShortAtOffset: 52!  
safeArrayStructure: aSafeArray
	"Private"

	aSafeArray isInExternalMemory
		ifFalse: [ ^self error: 'Variant ARRAY data must be in external memory.' ].
	aSafeArray doesNotNeedFinalization.
	self addressAtOffset: self valueOffset put: aSafeArray contents!  
arguments
    "Answer the argument VARIANTARGS."

    | nArgs arguments variantArgSize variantArgAddress |
    nArgs := self cArgs.
    arguments := Array new: nArgs.
    variantArgSize := OLEStructure sizeOfStructureNamed: #VARIANTARG.
    variantArgAddress := self rgvarg.
    " the arguments are packed from last to first "
    1 to: nArgs do:
        [ :index |
        arguments
            at: ( nArgs - index + 1 )
            put: ( OLEStructure createStructureNamed: #VARIANTARG
                fromAddress: variantArgAddress ). "?? atAddress: ??"
        variantArgAddress := variantArgAddress + variantArgSize ].
    ^arguments!   
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

	iid := anIID.
	interface notNil 
		ifTrue: [ interface iid: anIID ].! 
removeEnumeratorIID
		" Private - remove the registration of the IID of the interface which 
		enumerates collections containing instances of the receiver. "

	IEnum removeEnumeratorIID: self enumeratorIID.!   
typeCode
	"Answer the type code."

	^self vt!  
advise: anIUnknownSink
		" Register an event notification sink <anIUnknownSink> for this connection point.
		The connection point will call QueryInterface to obtain the interface it expects on the sink.
		Answer a token which identifies the advise connection. "

	| resultReference |
	resultReference := nil asValueReference.
	interface Advise: anIUnknownSink _: resultReference.
	^resultReference value!  
value
	"Answer the variant value.  The type of the UNION field is specified by the VARTYPE value in the vt field."

	( OLEVariant isArrayType: self typeCode )
		ifTrue: [ ^self safeArrayStructure ].
	^self getBasicValue! 
asOLEVariant
		" Answer the receiver as an OLE VARIANT.
		Answer nil if the receiver cannot be represented
		by a known VARIANT type. "

	| aTypeCode |
	( aTypeCode := self oleVariantType ) isNil
		ifTrue: [ ^nil ].
	^( OLEStructure classForStructureNamed: #VARIANT )
		type: aTypeCode
		value: self!
asBoolean: aValue
		" Private - answer <aValue> as a Boolean. "

	aValue isBoolean
		ifTrue: [ ^aValue ].
	aValue isString
		ifTrue: [
			( aValue equalsIgnoreCase: 'true' )
				ifTrue: [ ^true ].
			( aValue equalsIgnoreCase: 'false' )
				ifTrue: [ ^false ].
			].
	^aValue asInteger ~= 0!   
typeCodeUsing: iTypeInfo
	"Answer the integer that defines the type of the variable."

	^self variableValueDescription typeCodeUsing: iTypeInfo!   
dwHelpContext
		" Answer the help context of the topic in the Help file.
		This field is filled in iff a help file name is provided. "

	^self uLongAtOffset: 16! 
release
		"Free up resources associated with this object."

	self ISSUE.  " Review this comment for correctness.  [DL 17-Oct-95] " 
    "NB: We assume that we exclusively own our 'contents'. 
		Free up resources associated with it, if any. If an 
		BSTRMemoryAddress, this will, nicely, NULL the pointer 
		reference to ensure that we don't indirect through dangling 
		pointers. We, indeed, rely elsewhere on being able
		to re-release an already-released object, so this functionality 
		has to be provided somehow."
    self contents release.

    super release.!   
forReturnValue: anIID
		" Answer a new instance of the receiver for the dispatch interface
		identified by <anIID> to obtain an OUT parameter return value.
		Since in general the ownership responsibility of an OUT parameter 
		is transferred to the caller, mark the interface as needing finalization
		to ensure that it is released by the caller. "

	^self forIID: anIID 
		binding: self interfacePointerClass new !   
releaseStructure
		" Private - release the receiver back to the interface from whence it came. "

	typeInterface releaseFuncDesc: self.!   
xBOOL: aValue
	"Private"
	"Store <aValue> as a BOOL."

	" VARIANT_BOOL: 0 == FALSE, -1 == TRUE "
	self shortAtOffset: self valueOffset 
		put: ( ( self asBoolean: aValue ) 
			ifTrue: [ VARIANT_TRUE ] 
			ifFalse: [ VARIANT_FALSE ])! 
at: anIndex
	"Answer the value at <anIndex>. The receiver is interpreted as having 1-based indices."

	OLEAutomationDLL current SafeArrayGetElement: self 
		_: ( Array with: ( anIndex - 1 + self lowerBound ) )
		_: self accessor contents.
	^self accessor value!   
copy
		" Answer a new SAFEARRAY which is a copy of the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEAutomationDLL current SafeArrayCopy: self _: resultReference.
	^resultReference copy!
xR8: aValue
	"Private"
	"Store <aValue> as a double."

	self doubleFloatValue: ( self asFloat: aValue ).! 
guid: aGuid
		" Set the unique ID of the type library. "

	self guidAtOffset: 0 put: aGuid.!   
valueOffset
	" Private - answer the offset of the value UNION field. "

	^8!   
invokePropertyPut: dispidMember with: dispatchParameters localeID: lcid
		" Set the value of the property identified by the DISPID <dispidMember>. "

	^self invoke: dispidMember
		localeID: lcid
		flags: DISPATCH_PROPERTYPUT
		parameters: dispatchParameters
		result: nil   " no return value "! 
lcid
    "Answer the language/locale of the type library."

    ^self uLongAtOffset: 16!   
releaseStructure
		" Private - release the receiver back to the interface from whence it came. "

	typeInterface releaseTLibAttr: self.
! 
" OLE Automation Support - library installation "

    " install interface classes "
    IConnectionPointContainerPointer registerIID.
    IConnectionPointPointer registerIID.
    IDispatchPointer registerIID.
    IProvideClassInfoPointer registerIID.
    ITypeCompPointer registerIID.
    ITypeInfoPointer registerIID.
    ITypeLibPointer registerIID.
    IConnectionPoint registerIID.
    IConnectionPointContainer registerIID.
    IDispatch registerIID.
    IProvideClassInfo registerIID.
    ITypeComp registerIID.
    OLETypeLibraryInterface registerIID.
    ITypeInfo registerIID.
    ITypeLib registerIID.
    IDispatchImplementation registerIID.

    " register enumerator interfaces "
    IConnectionPoint registerEnumeratorIID.
    OLE_CONNECTDATA registerEnumeratorIID.
    OLE_VARIANT registerEnumeratorIID.

    " register host structures "
    OLE_ARRAYDESC registerStructureName.
    OLE_BLOB registerStructureName.
    OLE_CONNECTDATA registerStructureName.
    OLE_CURRENCY registerStructureName.
    OLE_DISPPARAMS registerStructureName.
    OLE_ELEMDESC registerStructureName.
    OLE_EXCEPINFO registerStructureName.
    OLE_IDLDESC registerStructureName.
    OLE_SAFEARRAY registerStructureName.
    OLE_SAFEARRAYBOUND registerStructureName.
    OLE_TYPEDESC registerStructureName.
    OLE_FUNCDESC registerStructureName.
    OLE_TLIBATTR registerStructureName.
    OLE_TYPEATTR registerStructureName.
    OLE_VARDESC registerStructureName.
    OLE_VARIANT registerStructureName.
    OLE_VARIANTARG registerStructureName.

    " install development environment support "
    OLESessionManager bindDevelopmentLibrary: 'VOLDA31W.sll'
        for: 'OLE Automation Support library VOLEA31W.sll'.
! 
parameterTypeCodesUsing: iTypeInfo
	"Answer an array of descriptors for the parameters."

	^self parameterValueDescriptions collect: [:each | each typeCodeUsing: iTypeInfo]!  
bstrIDLInfo

    ^self uLongAtOffset: 0!
cArgs: anInteger
		" Set the number of arguments. "

	self uLongAtOffset: 8 put: anInteger.!   
removeEnumeratorIID
		" Private - remove the registration of the IID of the interface which 
		enumerates collections containing instances of the receiver.
		Do nothing for the receiver (registration belongs to superclass). "! 
enumeratorIID
		" Private - answer the IID of the interface which enumerates
		collections containing instances of the receiver. 
		Override to ensure no unexpected inheritance effects
		from superclass. "

	^nil!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #VARIANTARG for: self.!
type: aTypeCode value: aValue
	"Answer a new instance of the receiver that represents <aValue> as type <aTypeCode>."

	| aVariant |
	aVariant := self new.
	aVariant typeCode: aTypeCode.
	aVariant isReference
		ifTrue: [ aVariant allocateMemory ].
	aVariant value: aValue.
	^aVariant!  
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #VARIANTARG.!
forReference: aValue
		" Answer a new instance of the receiver which passes <aValue>
		by reference. "

    self ISSUE. self notYetImplemented.
	" TO DO: implement a generic constructer of variants
		which handles the typing automatically. 
	E.g.,
	^self new
		vt: ( ( self typeFor: aValue ) | VT_BYREF );
		value: aValue
	" ! 
allocateMemory
		" Private - allocate memory for a reference value. "

	| variantArgAddress |
	variantArgAddress := OLEMemoryAddress allocateMemory: self elementSize.
	variantArgAddress doesNotNeedFinalization.
	self addressAtOffset: self valueOffset put: variantArgAddress!  
refAddress
    "Private"
    "Answer the address of the VT_BYREF value."

    ^self addressAtOffset: self valueOffset!
value: anObject
	"Set the variant value to the external representation of <anObject>.  The type of the UNION field is specified by the VARTYPE value in the vt field."

	( OLEVariant isReferenceType: self vt )
		ifTrue: [ ^self setRefValue: anObject ].
	super value: anObject!  
value
	"Answer the variant value.  The type of the UNION field is specified by the VARTYPE value in the vt field."

	( OLEVariant isReferenceType: self vt )
		ifTrue: [^self getRefValue].
	^super value!   
setRefValue: aSharedValue
	"Set the variant value to the external representation of the object held by <aSharedValue>."

	self getRefValue value: aSharedValue value!  
xVARIANT: aValue
	"Private -"

	| aVariant |
	aVariant := aValue asOLEVariant.
	aVariant isNil
		ifTrue: [ self error: 'explicit conversion to VARIANT required' ].
	self contents
		replaceFrom: 1
		to: self class sizeInBytes
		with: aVariant contents
		startingAt: 1.!   
elementSize
		"Private - answer the size in bytes of an element."

	^8!
isReference
	"Answer <true> if the receiver's value is passed by reference."

	^OLEVariant isReferenceType: self vt!   
getRefValue
	"Answer the variant value.  The type of the UNION field is specified by the VARTYPE value in the vt field."

	| val |
	val := OLEVariantValue atAddress: self refAddress.
	val typeCode: self typeCode.
	^val! 
scode
		" Answer the SCODE describing the error. "

	^self uLongAtOffset: 28!  
new
		" Answer a new instance of the receiver. "

	self invalidMessage.!   
xCY: aValue
	"Private"
    "Store <aValue> as a CURRENCY."

    | cy |
    cy := ( aValue isNumber
        ifTrue: [ ( OLEStructure classForStructureNamed: #CURRENCY ) fromNumber: aValue ]
        ifFalse: [ aValue ] ).
    self
        bytesAtOffset: self valueOffset
        put: ( cy bytesAtOffset: 0 count: ( OLEStructure sizeOfStructureNamed: #CURRENCY ) )!  
pvData
		" Answer the address of the array data. "

	^self addressAtOffset: 12!
hreftype

    ^self uLongAtOffset: 0!   
guid

    ^self guidAtOffset: 0!
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

	^8!  
oVft

    ^self shortAtOffset: 28!  
fromDate: aDate
		"Answer a new instance of the receiver that represents 
		the same date as <aDate>."

	^self new value: aDate day + 367
!  
sourceName: aString
		" Specify a textual, human-readable name of the source of the exception
		(typically the application name). "

	self bstrSource: ( BSTRMemoryAddress allocateString: aString ).!
at: anInteger put: aCharacter
        " Store <aCharacter> (or a legal integer character code value)
        in the <anInteger>-th index position in the receiver.
        Answer aCharacter. "

	| cv |
    self checkIndex: anInteger.
    self checkCharacter: aCharacter.
    cv := ( aCharacter isInteger
		ifTrue: [ aCharacter ]
		ifFalse: [ aCharacter asInteger ] ).
    self uShortAtOffset: ( self byteIndexOfCharAt: anInteger ) put: cv.
    ^aCharacter!   
wVarFlags

    ^self uShortAtOffset: 28!
xIllegal
	"Private"
	"This is a catch-all for vt values that cannot appear in VARIANTs."

	self error: 'Illegal VT'!  
wLibFlags: anInteger
        " Set the library flags. "

    self uShortAtOffset: 28 put: anInteger.!  
getTypeInfo
		" Retrieve the ITypeInfo type information for the current locale. "

	^self getTypeInfoForLocale: STDOLE_LCID!   
rgdispidNamedArgs: anAddress
		" Set the address of the array of DISPID's of named arguments. "

	self oleAddressAtOffset: 4 put: anAddress!   
registerEnumeratorIID
		" Private - register the IID of the interface which enumerates
		collections containing instances of the receiver. "

	IEnum
		registerEnumeratorIID: self enumeratorIID
		for: self.!  
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #ELEMDESC for: self.!  
fromString: aString
		" Answer a BSTR containing the characters of <aString>. "

	^self fromUnicode: aString asUnicode!
supportsIID: anIID
		" Answer whether the receiver represents the interface identified
		by the IID <anIID>. "

	^( super supportsIID: anIID )
		or: [ self supportsDispatchIID: anIID ]!
boundsForSize: nElements
		" Answer a SAFEARRAYBOUNDS structure with an element count <nElements>. "

	^(  OLEStructure createStructureNamed: #SAFEARRAYBOUND )
		elementCount: nElements;
		lowerBound: 0;
		yourself! 
xUNKNOWN: aValue
	"Private"
	"Store <aValue> as an IUnknown."

	aValue isOLEInterface not
		ifTrue: [ self error: 'IUnknown interface required' ].
	self interfaceAtOffset: self valueOffset put: aValue asParameter.!  
xUNKNOWN
	"Private"
	"Translate the value to an IUnknown object."

	^self interfaceAtOffset: self valueOffset type: IUnknown! 
pBlobData
		" Private - Answer the address of the data. "

	^self addressAtOffset: 4!  
typeForValue: aValue
		" Answer whether there is a well-defined VARIANT
		type code which should be used to represent <aValue>. "

	^self variantTypeMap at: aValue class
		ifAbsent: [ nil ]!   
idlDescription
	"Answer the IDL description member of the structure."

	^self idldesc! 
value

	^self asInteger!
supportedIIDs
		" Private - answer the dispatch interface id's which can be represented
		by instances of the receiver. "

	^SupportedIIDs
! 
releaseResources
	"Private - release resources owned by the receiver."

	self bstrDescription release.
	self bstrHelpFile release.
	self bstrSource release.
	super releaseResources!   
usingBytes: aByteObject
	"Answer a new instance of the receiver using <aByteObject> as its contents."

	| aVariant |
	aVariant := super new: self sizeInBytes.
	aVariant contents: aByteObject.
	^aVariant! 
new: anInteger
        "Answer a new instance of the receiver that can contain <anInteger> Unicode characters."

    ^super new: anInteger + anInteger + 4. " 4 for the byte cnt "
!  
lock
		" Increment the receiver's lock count and place a pointer to the 
		array data in its pvData field. "

	OLEAutomationDLL current SafeArrayLock: self.! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^8!   
lowerBound: anInteger

	self lLbound: anInteger!
asUnicode
        "Answer a Unicode copy of the receiver.
		An invalid BSTR is mapped to nil. "

    | unicodeString |
    self isValid ifFalse: [ ^nil ].
    unicodeString := UnicodeStringBuffer new: self size.
    1 to: self size do: [:i | unicodeString at: i put: ( self at: i ) ].
    ^unicodeString
!
varkind

    ^self longAtOffset: 32!
cImplTypes

    ^self uShortAtOffset: 48!   
typeCodeNameMap
		" Private - answer the mapping dictionary from type code values to names. "

	^TypeCodeNameMap!  
xDISPATCH
	"Private"
	"Translate the value to an IDispatch object."

	^self interfaceAtOffset: self valueOffset type: IDispatch!  
asByteArray
        "Answer a ByteArray whose contents are the
         bytes of the receiver."

    ^self bytesAtOffset: 0 count: self sizeInBytes!  
invokeMethod: aDispatchSpecification
    arguments: arguments
    resultReference: resultReference
        " Private - invoke the method described by <aDispatchSpecification>
        of the published object. "

    | resultValue |
	resultValue := ( Message
		receiver: self publishedObject
		selector: aDispatchSpecification selector )
			evaluateWithArguments: arguments.
	resultReference notNil
		ifTrue: [
			resultReference
				typeCode: aDispatchSpecification typeCode;
				value: resultValue ].
	^S_OK!  
publishedObject
		" Answer the object being published as an OLE automation object
		by supporting IDispatch on it. "

	^publishedObject!  
publishedObject: anObject
		" Set the object being published as an OLE automation object
		by supporting IDispatch on it. "

	publishedObject := anObject.!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the Guid <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = self dispatchInterfaceIID
		ifTrue: [ ^self dispatchInterface ]. 
	^super getInterfaceForIID: iid! 
invokePropertyGet: aDispatchSpecification
    arguments: arguments
    resultReference: resultReference
        " Private - get the value of the property member described by <aDispatchSpecification>
        of the published object. "

    | resultValue |
	resultValue := ( Message
		receiver: self publishedObject
		selector: aDispatchSpecification getSelector )
			evaluateWithArguments: arguments.
	resultReference notNil
		ifTrue: [
			resultReference
				typeCode: aDispatchSpecification typeCode;
				value: resultValue ].
	^S_OK
! 
invokePropertySet: aDispatchSpecification
    arguments: arguments
    resultReference: resultReference
        " Private - set the value of the property member described by <aDispatchSpecification>
        of the published object. "

    | resultValue |
	resultValue := ( Message
		receiver: self publishedObject
		selector: aDispatchSpecification setSelector )
			evaluateWithArguments: arguments.
	( resultReference notNil
	and: [ aDispatchSpecification isReadOnly not ] )
		ifTrue: [
			resultReference
				typeCode: aDispatchSpecification putResultTypeCode;
				value: resultValue ].
	^S_OK 
!  
Invoke: dispidMember
    _: iid
    _: lcid
    _: wFlags
    _: dispParams
    _: resultReference
    _: exceptionInfoReference
    _: argErrorReference
        " Private - implement the IDispatch::Invoke function. "

    | aDispatchSpecification arguments exceptionInfo |

    aDispatchSpecification := self specificationTable at: dispidMember
        ifAbsent: [ nil ].
    aDispatchSpecification isNil
        ifTrue: [ ^DISP_E_MEMBERNOTFOUND ].

    [
	aDispatchSpecification isMethodSpecification
		ifTrue: [
			( wFlags bitAnd: DISPATCH_METHOD ) = 0
				ifTrue: [ ^E_UNEXPECTED ].
			dispParams cNamedArgs > 0
				ifTrue: [ ^DISP_E_NONAMEDARGS ].  " this implementation does not support named arguments "
			dispParams cArgs ~= aDispatchSpecification parameterTypes size
				ifTrue: [ ^DISP_E_BADPARAMCOUNT ].
			arguments := self valueAdaptor argumentsForMethod: aDispatchSpecification
				parameters: dispParams
				localeID: lcid.
			arguments isInteger
				ifTrue: [
					argErrorReference value: arguments.
					^DISP_E_TYPEMISMATCH ].
            ^self invokeMethod: aDispatchSpecification
                arguments: arguments
                resultReference: resultReference ].
    aDispatchSpecification isPropertySpecification
        ifTrue: [
    		( wFlags bitAnd: DISPATCH_PROPERTYGET ) ~= 0
        		ifTrue: [
					dispParams cNamedArgs > 0
						ifTrue: [ ^DISP_E_NONAMEDARGS ].  " this implementation does not support named arguments "
		    		arguments := self valueAdaptor argumentsForPropertyGet: aDispatchSpecification
		        		parameters: dispParams
						localeID: lcid.
					arguments isInteger
						ifTrue: [
							argErrorReference value: arguments.
							^DISP_E_TYPEMISMATCH ].
					^self invokePropertyGet: aDispatchSpecification
						arguments: arguments
						resultReference: resultReference ].
    		( wFlags bitAnd: DISPATCH_PROPERTYPUT ) ~= 0
        		ifTrue: [
					dispParams cNamedArgs > 0
						ifTrue: [ 
							" allow special case through that is parallel to OCX property setting "
							( dispParams cNamedArgs = 1
							and: [ dispParams argumentIDs = ( Array with: DISPID_PROPERTYPUT ) ] ) 
								ifFalse: [ ^DISP_E_NONAMEDARGS ].  " this implementation does not support named arguments "
							].
		    		arguments := self valueAdaptor argumentsForPropertySet: aDispatchSpecification
		        		parameters: dispParams
						localeID: lcid.
					arguments isInteger
						ifTrue: [
							argErrorReference value: arguments.
							^DISP_E_TYPEMISMATCH ].
					^self invokePropertySet: aDispatchSpecification
						arguments: arguments
						resultReference: resultReference ].
			^E_NOTIMPL ].
	] on: Error
        do: [ :ex |
            exceptionInfo := OLEStructure createStructureNamed: #EXCEPINFO.
            exceptionInfo
                sourceName: 'Smalltalk';
                description: ex description.
            exceptionInfoReference value: exceptionInfo.
            ^DISP_E_EXCEPTION ].
    ^E_UNEXPECTED!
dispatchInterfaceIID: anIID
		" Set the IID of the dispatch interface which is supported
		by the receiver to <anIID>. "

	dispatchInterfaceIID := anIID.
	self dispatchInterface notNil
		ifTrue: [ self dispatchInterface iid: anIID ].!  
specificationTable: aSpecificationTable
		" Private - set the receiver's specification table for dispatching
		method and property member invocations. "

	specificationTable := aSpecificationTable.!
propertySpecificationTable: aSpecificationTable
		" Private - add the elements in <aSpecificationTable> describing 
		the property members supported by the receiver to its
		dispatch specification table. "

	self specificationTable addAll: aSpecificationTable.!
GetIDsOfNames: iid _: names _: cNames _: lcid _: resultReference
		" Private - Implement the IDispatch::GetIDsOfNames function. "

	"Get IDs of names for a dispatch member
    Map a single member and an optional set of argument names into
    a corresponding set of DISPID's which can be used with IDispatch::Invoke.
    The first element is the DISPID of the member name; subsequent
    elements represent each of the member's parameters.
	Answer the result code."

	| memberName dispidMember dispidList aDispatchSpecification |
	self ISSUE.  " ^DISP_EUNKNOWNLCID if not supported locale [DL 30-Oct-95] " 
	memberName := names at: 1.
	aDispatchSpecification := self specificationTable 
		detect: [ :each | each name equalsIgnoreCase: memberName ] 
        ifNone: [ nil ].
    dispidMember := ( aDispatchSpecification == nil
        ifTrue: [ DISPID_UNKNOWN ]
        ifFalse: [ aDispatchSpecification memberID ] ).
	cNames = 1
        ifTrue: [ dispidList := Array with: dispidMember ]
        ifFalse: [
            dispidList := Array new: cNames.
            dispidList atAllPut: DISPID_UNKNOWN.  " parameter name mappings not supported "
            dispidList at: 1 put: dispidMember ].
	resultReference value: dispidList.
    ^( dispidMember = DISPID_UNKNOWN
	or: [ cNames > 1 ] )
        ifTrue: [ DISP_E_UNKNOWNNAME ]
        ifFalse: [ S_OK ]!   
dispatchInterfaceIID
		" Answer the IID of the dispatch interface which is supported
		by the receiver. "

	^dispatchInterfaceIID!
initialize
		" Private - initialize a new instance. "

	self specificationTable: Dictionary new.
	self dispatchInterfaceIID: IID_IDispatch.
	super initialize.
!
methodSpecificationTable: aSpecificationTable
		" Private - add the elements in <aSpecificationTable> describing 
		the method members supported by the receiver to its
		dispatch specification table. "

	self specificationTable addAll: aSpecificationTable.!
createIDispatch
		" Private - create an IDispatch interface on the receiver. "

	^super createIDispatch
		iid: self dispatchInterfaceIID;
		yourself!
specificationTable
		" Private - answer the receiver's specification table for dispatching
		method and property member invocations. "

	^specificationTable! 
oleVariantType
		" Answer the type code which should be used
		to represent the receiver as an OLE VARIANT value. "

	^13  "VT_UNKNOWN"!  
wTypeFlags

    ^self uShortAtOffset: 54!   
typeDescription
	"Answer the type description member of the structure."

	^self tdesc! 
fFeatures
		" Answer the array flags. "

	^self uShortAtOffset: 2! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^36!  
printOn: aStream
		" Append a text description of the receiver to <aStream>. "

	self asDate printOn: aStream! 
invokeInvoke: dispidMember _: riid _: lcid _: wFlags _: pdispparams _: pvarResult _: pexcepinfo _: puArgErr
        " Private - invoke the IDispatch::Invoke function for an external caller. "

    "HRESULT Invoke(
            /* [in] */ DISPID dispidMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [unique][in] */ DISPPARAMS *pdispparams,
            /* [unique][out][in] */ VARIANT *pvarResult,
            /* [out] */ EXCEPINFO *pexcepinfo,
            /* [out] */ UINT *puArgErr)"

    | anIID dispParams exceptionInfoReference argErrorReference
      resultReference hresult |

    self ifOLETraceEnabled: [ self logCallbackHeader ].
    (riid isValid and: [ pdispparams isValid and: [pexcepinfo isValid and: [puArgErr isValid]]])
        ifFalse: [ ^E_INVALIDARG ].
    anIID := self guidAtAddress: riid.  " must be IID_NULL in OLE 2.0 "
    dispParams := self structureAtAddress: pdispparams
        type: #DISPPARAMS.
    self clearResultStructureAtAddress: pexcepinfo
        type: #EXCEPINFO.
    self clearResultValueAtAddress: puArgErr.

    self ifOLETraceEnabled: [
        self oleTRACE: self logIndent, 'DISPID: ', dispidMember printString.
        ].

    pvarResult isValid
        ifTrue: [ resultReference := OLEDispatchValueReference new ].
    exceptionInfoReference := nil asValueReference.
    argErrorReference := nil asValueReference.
    hresult := self dispatchInvoke: dispidMember
        _: anIID
        _: lcid
        _: wFlags
        _: dispParams  " object must marshall values, which is somewhat asymmetric design "
        _: resultReference
        _: exceptionInfoReference
        _: argErrorReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [
            pvarResult isValid
                ifTrue: [
                        self ISSUE.  " Need to handle type coercion failures here [DL 31-Oct-95] "
                        self structureResultAtAddress: pvarResult put: resultReference asVariant ] ]
        ifFalse: [
            hresult = DISP_E_EXCEPTION
                ifTrue: [ self structureResultAtAddress: pvarResult put: exceptionInfoReference value ].
            hresult = DISP_E_TYPEMISMATCH
                ifTrue: [ self uLongResultAtAddress: puArgErr put: argErrorReference value ].
            ].
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
invokeGetTypeInfoCount: pctinfo
        " Private - invoke the IDispatch::GetTypeInfoCount function for an external caller. "

    " HRESULT GetTypeInfoCount(
            /* [out] */ UINT *pctinfo)"

    | hresult resultReference |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    pctinfo isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: pctinfo.
    resultReference := nil asValueReference.
    hresult := self dispatchGetTypeInfoCount: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: pctinfo put: resultReference value ].
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
iid: anIID
		"Set the the interface ID which uniquely identifies the receiver to the GUID <anIID>. "

    iid := anIID.!   
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^iid!  
dispatchGetIDsOfNames: riid _: rgszNames _: cNames _: lcid _: rgdispid
	"Private - dispatch the IDispatch::GetIDsOfNames function."

	| args |
	( args := Array new: 5 )
		at: 1 put: riid;
		at: 2 put: rgszNames;
		at: 3 put: cNames;
		at: 4 put: lcid;
		at: 5 put: rgdispid.
	^( functionHandlers at: 6 ) evaluateWithArguments: args!
Invoke: dispidMember _: riid _: lcid _: wFlags _: pdispparams _: resultReference _: exceptionInfoReference _: argErrorReference
	"Invoke the IDispatch::Invoke function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: ( self dispatchInvoke: dispidMember 
		_: riid
		_: lcid 
		_: wFlags 
		_: pdispparams
		_: resultReference
		_: exceptionInfoReference
		_: argErrorReference )!
oleVariantType
		" Answer the type code which should be used
		to represent the receiver as an OLE VARIANT value. "

	^VT_DISPATCH!   
GetTypeInfo: itinfo _: lcid _: resultReference
	"Invoke the IDispatch::GetTypeInfo function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: ( self dispatchGetTypeInfo: itinfo 
			_: lcid 
			_: resultReference )!   
GetTypeInfoCount: resultReference
	"Invoke the IDispatch::GetTypeInfoCount function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult:
		(self dispatchGetTypeInfoCount: resultReference)! 
dispatchGetTypeInfo: itinfo _: lcid _: resultReference
	"Private - dispatch the IDispatch::GetTypeInfo function."

	^( functionHandlers at: 5 ) evaluateWithArguments: ( Array 
		with: itinfo 
		with: lcid 
		with: resultReference)! 
dispatchGetTypeInfoCount: resultReference
	"Private - dispatch the IDispatch::GetTypeInfoCount function."

	^( functionHandlers at: 4 ) evaluateWithArguments: ( Array with: resultReference )!
GetIDsOfNames: riid _: nameList _: cNames _: lcid _: resultReference
	"Invoke the IDispatch::GetIDsOfNames function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: ( self dispatchGetIDsOfNames: riid
			_: nameList
 			_: cNames
			_: lcid 
			_: resultReference )! 
dispatchInvoke: dispidMember _: riid _: lcid _: wFlags _: pdispparams _: resultReference _: exceptionInfoReference _: argErrorReference
	"Private - dispatch the IDispatch::Invoke function."

	| args |
	( args := Array new: 8 )
		at: 1 put: dispidMember;
		at: 2 put: riid;
		at: 3 put: lcid;
		at: 4 put: wFlags;
		at: 5 put: pdispparams;
		at: 6 put: resultReference;
		at: 7 put: exceptionInfoReference;
		at: 8 put: argErrorReference.
	^( functionHandlers at: 7 ) evaluateWithArguments: args!  
invokeGetIDsOfNames: riid _: rgszNames _: cNames _: lcid _: rgdispid
        " Private - invoke the IDispatch::GetIDsOfNames function for an external caller. "

	"HRESULT GetIDsOfNames(
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out][in] */ DISPID *rgdispid)"

	| hresult names resultReference ids buffer |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	(riid isValid and: [rgszNames isValid and: [rgdispid isValid]])
		ifFalse: [ ^E_INVALIDARG ].
	"anIID := self guidAtAddress: riid."  " reserved, must be NULL in OLE 2.0 "
	names := self getArrayOfStrings: cNames fromUnicodeArray: rgszNames.
	resultReference := nil asValueReference.
	hresult := self dispatchGetIDsOfNames: iid
		_: names
		_: cNames
		_: lcid
		_: resultReference.
	( HRESULT succeeded: hresult )
		ifTrue: [
			ids := resultReference value.
			buffer := ExternalBuffer atAddress: rgdispid.
			1 to: cNames do:
				[ :index |
				buffer longAtOffset: index - 1 * 4 put: (ids at: index) ] ].
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
implementor: anObject
		"Private - Set the implementor of the interface to <anObject>."

	super implementor: anObject.
	" sneaky way to hook up instance initialization "
	self iid isNil
		ifTrue: [ self iid: IID_IDispatch ].!   
invokeGetTypeInfo: itinfo _: lcid _: pptinfo
        " Private - invoke the IDispatch::GetTypeInfo function for an external caller. "

    "HRESULT GetTypeInfo(
            /* [in] */ UINT itinfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **pptinfo)"

    |  resultReference hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    pptinfo isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: pptinfo.
    resultReference := nil asValueReference.
    hresult := self dispatchGetTypeInfo: itinfo
        _: lcid
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: pptinfo put: resultReference value ].
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
setValue: aValue
		" Set the value to <aValue>. "

	self value: aValue.!   
fromInteger: anInteger
	"Answer a new Instance of the receiver with value <anInteger>."

	| aVariant |
	aVariant := super new: self sizeInBytes.
	aVariant longAtOffset: 0 put: anInteger.
	^aVariant!  
typeCode
	"Answer the integer that defines the type of the variable."

	^self variableValueDescription typeCode!   
lLbound: anInteger
		" Set the lower bound of this array dimension. "

	self uLongAtOffset: 4 put: anInteger.! 
vt: aVariantType
	" Set the VARTYPE of this VARIANT. "

	self uShortAtOffset: 0 put: aVariantType! 
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^14!  
forType: aTypeCode
    "Answer the class that best represents the type <aTypeCode>."

    ^OLEStructure classForStructureNamed:
		( ( OLEVariant isReferenceType: aTypeCode )
            ifTrue: [ #VARIANTARG ]
            ifFalse: [ #VARIANT ] )!  
dwCookie
		" Answer the magic cookie connection token. "

	^self uLongAtOffset: 4! 
xUI2: aValue
	"Private"
	"Store <aValue> as an unsigned short."

	self uShortAtOffset: self valueOffset put: ( self asInteger: aValue ).! 
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
signalDispatchError: hresult exceptionInfo: exceptionInfo argError: argError
		" Private - signal an OLEDispatchError for a dispatch invoke error. "

	| dispatchException |

	dispatchException := OLEDispatchError new.
	dispatchException hresult: hresult.
	hresult = DISP_E_EXCEPTION
		ifTrue: [
			dispatchException
				exceptionInfo: exceptionInfo;
				exceptionDescription: exceptionInfo description ].
	hresult = DISP_E_TYPEMISMATCH
		ifTrue: [
			dispatchException
				exceptionInfo: argError;
				exceptionDescription: 'Argument type mismatch' ].

	[ dispatchException signal ]
		ensure: [ exceptionInfo release ].!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #ARRAYDESC for: self.! 
getClassInfo
		" Answer a CoClass ITypeInfo describing the connectable object. "

	| resultReference |
	resultReference := ITypeInfo new asValueReference.
	interface GetClassInfo: resultReference.
	^resultReference value!   
callconv

    ^self longAtOffset: 20!   
xERROR: aValue
	"Private"
	"Store <aValue> as an SCODE."

	self longAtOffset: self valueOffset put: ( self asInteger: aValue ).!  
iid
		"Answer the interface ID GUID which uniquely identifies the receiver. "

	^iid!  
getConnectionPointContainer
		" Answer the connection point container object which supports this connection point. "

	| resultReference |
	resultReference := IConnectionPointContainer new asValueReference.
	interface GetConnectionPointContainer: resultReference.
	^resultReference value!
initialSize: anInteger
        "Private - initialize the contents instance variable to
        an appropriately sized ByteArray."

    super initialSize: anInteger.
    self uLongAtOffset: 0 put: ( anInteger - 4 ).!  
asInteger: aValue
		" Private - answer <aValue> as an integer. "

	^aValue isInteger
		ifTrue: [ aValue ]
		ifFalse: [ aValue isNil ifTrue: [ 0 ] ifFalse: [ aValue asInteger ] ]!   
new
		" Answer a new instance of the receiver. "

	^super new initialize!  
xIllegal: anObject
	"Private"
	"This is a catch-all for vt values that cannot appear in VARIANTs."

	self xIllegal!   
" OLE Automation Support - library removal "

    " remove interface classes "
    IConnectionPointContainerPointer removeIID.
    IConnectionPointPointer removeIID.
    IDispatchPointer removeIID.
    IProvideClassInfoPointer removeIID.
    ITypeCompPointer removeIID.
    ITypeInfoPointer removeIID.
    ITypeLibPointer removeIID.
    IConnectionPoint removeIID.
    IConnectionPointContainer removeIID.
    IDispatch removeIID.
    IProvideClassInfo removeIID.
    ITypeComp removeIID.
    OLETypeLibraryInterface removeIID.
    ITypeInfo removeIID.
    ITypeLib removeIID.
    IDispatchImplementation removeIID.

    " remove enumerator interfaces "
    IConnectionPoint removeEnumeratorIID.
    OLE_CONNECTDATA removeEnumeratorIID.
    OLE_VARIANT removeEnumeratorIID.

    " remove host structures "
    OLE_ARRAYDESC removeStructureName.
    OLE_BLOB removeStructureName.
    OLE_CONNECTDATA removeStructureName.
    OLE_CURRENCY removeStructureName.
    OLE_DISPPARAMS removeStructureName.
    OLE_ELEMDESC removeStructureName.
    OLE_EXCEPINFO removeStructureName.
    OLE_IDLDESC removeStructureName.
    OLE_SAFEARRAY removeStructureName.
    OLE_SAFEARRAYBOUND removeStructureName.
    OLE_TYPEDESC removeStructureName.
    OLE_FUNCDESC removeStructureName.
    OLE_TLIBATTR removeStructureName.
    OLE_TYPEATTR removeStructureName.
    OLE_VARDESC removeStructureName.
    OLE_VARIANT removeStructureName.
    OLE_VARIANTARG removeStructureName.

    " remove development environment support "
    OLESessionManager unbindDevelopmentLibrary: 'VOLDA31W.sll'.
!  
lowerBound
	"Answer the lower bound of the Nth dimension of the receiver."
	"N is always one for the current implementation."

	| resultReference |
	resultReference := nil asValueReference.
	OLEAutomationDLL current SafeArrayGetLBound: self 
		_: 1 
		_: resultReference.
	^resultReference value! 
xR8
	"Private"
	"Translate the value to a Float."

	^self doubleFloatValue!   
lpstrSchema

    ^self uLongAtOffset: 32!   
parameterValueDescriptions
    "Answer an array of descriptors for the parameters."

    | address size |
    address := self lprgelemdescParam.
    size := ( OLEStructure sizeOfStructureNamed: #ELEMDESC ) + 3 // 4 * 4.
        "struct alignment to longword boundary"
    ^( 0 to: self cParams - 1 ) collect: [ :index |
        OLEStructure createStructureNamed: #ELEMDESC
            atAddress: ( ExternalAddress fromInteger: address + ( index * size ) ) ]!   
wIDLFlags

    ^self uShortAtOffset: 4! 
memidConstructor

    ^self longAtOffset: 24!   
argumentIDs
	"Answer the DISPIDs of the named arguments."

	| nArgs dispids dispidSize dispidArgs |
	(nArgs := self cNamedArgs) = 0
		ifTrue: [^#()].
	dispids := Array new: nArgs.
	dispidSize := ExternalLong sizeInBytes.
	dispidArgs := ExternalBuffer atAddress: self rgdispidNamedArgs.
	" the arguments are packed from last to first "
	1 to: nArgs do:
		[ :index |
		dispids
			at: (nArgs - index + 1)
			put: (dispidArgs longAtOffset: index - 1 * dispidSize)].
	^dispids!   
ptrType

    ^OLEStructure createStructureNamed: #TYPEDESC atAddress: self lptdesc! 
wMinorVerNum

    ^self uShortAtOffset: 58! 
hasTypeInfo
		" Answer whether the object provides type information. "

	^self getTypeInfoCount = 1!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #FUNCDESC for: self.!  
baseTypeCodeOf: aTypeCode
		"Answer the type code of the basic value specified by <aTypeCode>, 
		i.e. without modifiers such as reference or array."

	self ISSUE.  " Was this FF or FFFF?? [DL 01-Nov-95] " 
	^aTypeCode bitAnd: 16rFF!
getTypeInfoForLocale: lcid
		" Answer the ITypeInfo type information for the locale specified by <lcid>. "

	| resultReference |
	resultReference := ITypeInfo new asValueReference.
	interface GetTypeInfo: 0 
		_: lcid
		_: resultReference.
	^resultReference value!  
data
		" Answer the data. "

	| anAddress |
	anAddress := self pBlobData.
	^anAddress isNil
		ifTrue: [ nil ]
		ifFalse: [ ExternalBuffer atAddress: anAddress ]!  
typeCode
	"Answer the integer that identifies the type of the element."

	^self typeDescription typeCode!  
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

	^8!  
bstrDescription: anAddress
		" Private - specify a textual, human-readable description of the error. "

	self addressAtOffset: 8 put: anAddress.!  
coerceTo: aTypeCode
		" Answer a new VARIANT which is created by coercing
		the receiver's VARTYPE to <aTypeCode>. "

	| destVariant |
	destVariant := ( self class forType: aTypeCode ) new.
	OLEAutomationDLL current VariantChangeType: destVariant
		_: self
		_: 0
		_: aTypeCode.
	^destVariant!  
xI4: aValue
	"Private"
	"Store <aValue> as a long."

	self longAtOffset: self valueOffset put: ( self asInteger: aValue ).!   
lowerBound

	^self lLbound! 
variableCount
	"Answer the number of variables contained in this interface."

	^self cVars!
oleVariantType
		" Answer the type code which should be used
		to represent the receiver as an OLE VARIANT value. 
		Answer nil if the receiver cannot be represented as by
		a known variant type. "

	^OLEVariant typeForValue: self
!   
new
		" Answer a new instance of the receiver. "

	^super new needsFinalization!   
elementSize
	"Answer the size, in bytes, of an element."

	^OLEAutomationDLL current SafeArrayGetElemsize: self!   
elemdescVar

	^self structureAtOffset: 12 type: #ELEMDESC!  
releaseStructure
		" Private - release the receiver back to the interface from whence it came. "

	typeInterface releaseTypeAttr: self.!   
lLbound
		" Answer the lower bound of this array dimension. "

	^self uLongAtOffset: 4!
convertTo: destVariant
		" Convert the value of the receiver to type type of <destVariant>,
		storing the new value in <destVariant>."

	OLEAutomationDLL current VariantChangeType: destVariant
		_: self
		_: 0
		_: destVariant vt.
	^destVariant! 
value
		" Answer the VT_DATE double-precision value of the receiver. "

	^value!   
lcid
		" Answer the language/locale of the type library. "

    ^self uLongAtOffset: 16!   
variantTypeMap: aDictionary
		" Private - set the mapping dictionary from classes to the VARIANT
		type code which is used to encode instances.  Only classes for
		which a well-defined mapping applies to all instances are registered. "

	VariantTypeMap := aDictionary.!
registerEnumeratorIID
		" Private - register the IID of the interface which enumerates
		collections containing instances of the receiver. "

	IEnum
		registerEnumeratorIID: self enumeratorIID
		for: self.!  
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
oleVariantType
		" Answer the type code which should be used
		to represent the receiver as an OLE VARIANT value. "

	^interface oleVariantType!  
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. 
		This is without elements. "

    ^8! 
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #SAFEARRAYBOUND.!
memberID
	"Answer the unique identifier of the member."

	^self memid! 
parameterCount
	"Answer the total number of parameters, including optional parameters."

	^self cParams!   
copy
        " Answer a copy of the receiver.  The copy is not separately
        reference counted and should not be released unless the
        it is explicitly reference counted. "

    ^self class forIID: self iid
        binding: self copyInterfaceBinding!   
GetDllEntry: memberID _:  invkind _: dllNameReference _: entryPointNameReference _: ordinalReference
		" Invoke the ITypeInfo::GetDllEntry function.
		Raise an exception if an error occurs.  Answer the result code. "

	| dllNameValue entryPointNameValue ordinalValue hresult |
	dllNameValue := BSTR new: 32.
	entryPointNameValue := BSTR new: 32. "?? length ??"
	ordinalValue := ExternalBuffer new: 2.
	hresult := self
		invokeGetDllEntry: memberID 
		_:  invkind 
		_: dllNameValue asParameter 
		_: entryPointNameValue asParameter 
		_: ordinalValue asParameter.
	dllNameReference value: dllNameValue asString.
	dllNameValue release.
	entryPointNameReference value: entryPointNameValue value asString.
	entryPointNameValue release.
	ordinalReference value: ( ordinalValue uShortAtOffset: 0 ).
	^hresult!   
invokeGetDocumentation: memid _:  pbstrName _: pbstrDocString _: pdwHelpContext _: ppbstrHelpFile
		" Private - invoke the ITypeInfo::GetDocumentation function. "

	" HRESULT GetDocumentation(
            /* [in] */ MEMBERID memid,
            /* [out] */ BSTR *pbstrName,
            /* [out] */ BSTR *pbstrDocString,
            /* [out] */ DWORD *pdwHelpContext,
            /* [out] */ BSTR *pbstrHelpFile); "

	<ole: 12 long structOut structOut structOut structOut hresult>
	^self vtableDispatchFailed!
ReleaseTypeAttr: aTypeAttr
		" Invoke the ITypeInfo::ReleaseTypeAttr function. "

	" void ReleaseTypeAttr(
            /* [in] */ TYPEATTR *ptypeattr); "

	<ole: 19 structIn none>
	^self vtableDispatchFailed!   
GetFuncDesc: index _: resultReference
        " Invoke the ITypeInfo::GetFuncDesc function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEMemoryAddress new.  " don't track finalization on the address,
		because it can't be released properly independently of the containing FUNCDESC "
    hresult := self invokeGetFuncDesc: index
        _: resultValue asParameter.
    resultReference value: ( OLEStructure createStructureNamed: #FUNCDESC
        atAddress: resultValue ).
    ^hresult!  
invoke: anInterface _:  memberID _: dispatchFlags _: dispatchParams _: resultReference _: exceptionInfoReference _: argErrorReference
		" Invoke the ITypeInfo::Invoke function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue exceptionInfoValue argErrorValue hresult |
    resultReference == nil
        "ifTrue: [ resultValue := nil ]"
        ifFalse: [ resultValue := OLEStructure forReturnValue: #VARIANT ].
    exceptionInfoValue := OLEStructure forReturnValue: #EXCEPINFO.
    argErrorValue := ExternalLong new.
	hresult := self
		invokeInvoke: anInterface asParameter
		_: memberID 
		_: dispatchFlags 
		_: dispatchParams asParameter
		_: resultValue asParameter 
		_: exceptionInfoValue asParameter 
		_: argErrorValue asParameter.
    ( HRESULT succeeded: hresult )
        ifTrue: [
            resultReference notNil
                ifTrue: [ resultReference value: resultValue value ].
            exceptionInfoValue release ]
        ifFalse: [
            exceptionInfoReference value: exceptionInfoValue.  " set for DISP_E_EXCEPTION "
            argErrorReference value: argErrorValue asUnsignedInteger.  " set for DISP_E_TYPEMISMATCH "
            ].
	^hresult!  
GetTypeComp: resultReference
		" Invoke the ITypeInfo::GetTypeComp function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeCompPointer new.
	hresult := self invokeGetTypeComp: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
invokeGetRefTypeOfImplType: index _: hpreftype
		" Private - invoke the ITypeInfo::GetRefTypeOfImplType function. "

	" HRESULT GetRefTypeOfImplType(
            /* [in] */ UINT index,
            /* [out] */ HREFTYPE *hpreftype); "

	<ole: 8 ulong structOut hresult>
	^self vtableDispatchFailed!  
ReleaseVarDesc: aVarDesc
		" Invoke the ITypeInfo::ReleaseVarDesc function. "

	" void ReleaseVarDesc(
            /* [in] */ VARDESC *pvardesc); "

	<ole: 21 structIn none>
	^self vtableDispatchFailed! 
invokeGetNames: memid _: rgbstrNames _: cMaxNames _: pcNames
		" Private - invoke the ITypeInfo::GetNames function. "

	" HRESULT GetNames(
            /* [in] */ MEMBERID memid,
            /* [length_is][size_is][out] */ BSTR *rgbstrNames,
            /* [in] */ UINT cMaxNames,
            /* [out] */ UINT *pcNames); "

	<ole: 7 long structOut ulong structOut hresult>
	^self vtableDispatchFailed!   
invokeGetTypeAttr: pptypeattr
		" Private - invoke the ITypeInfo::GetTypeAttr function. "

	" HRESULT GetTypeAttr(
            /* [out] */ TYPEATTR **pptypeattr); "

	<ole: 3 structOut hresult>
	^self vtableDispatchFailed! 
ReleaseFuncDesc: aFuncDesc
		" Invoke the ITypeInfo::ReleaseFuncDesc function. "

	" void ReleaseFuncDesc(
            /* [in] */ FUNCDESC *pfuncdesc); "

	<ole: 20 structIn none>
	^self vtableDispatchFailed!   
GetContainingTypeLib: typeLibraryReference _: indexReference
		" Invoke the ITypeInfo::GetContainingTypeLib function.
		Raise an exception if an error occurs.  Answer the result code. "

	| typeLibraryValue indexValue hresult |
	typeLibraryValue := ITypeLibPointer forReturnValue.
	indexValue := ExternalLong new.
	hresult := self invokeGetContainingTypeLib: typeLibraryValue asParameter 
		_: indexValue.
	typeLibraryReference value: typeLibraryValue.
	indexReference value: indexValue asUnsignedInteger.
	^hresult!   
invokeGetVarDesc: index _: ppvardesc
		" Private - invoke the ITypeInfo::GetVarDesc function. "

	" HRESULT GetVarDesc(
            /* [in] */ UINT index,
            /* [out] */ VARDESC **ppvardesc); "

	<ole: 6 ulong structOut hresult>
	^self vtableDispatchFailed!
invokeGetRefTypeInfo: hreftype _: pptinfo
		" Private - invoke the ITypeInfo::GetRefTypeInfo function. "

	" HRESULT GetRefTypeInfo(
            /* [in] */ HREFTYPE hreftype,
            /* [out] */ ITypeInfo **pptinfo); "

	<ole: 14 ulong structOut hresult>
	^self vtableDispatchFailed!   
invokeAddressOfMember: memid _: invkind _: ppv
		" Private - invoke the ITypeInfo::AddressOfMember function. "

	" HRESULT AddressOfMember(
            /* [in] */ MEMBERID memid,
            /* [in] */ INVOKEKIND invkind,
            /* [out] */ void **ppv); "

	<ole: 15 long ushort structOut hresult>
	^self vtableDispatchFailed!  
AddressOfMember: memberID _: invkind _: resultReference
		" Invoke the ITypeInfo::AddressOfMember function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalAddress new.
	hresult := self invokeAddressOfMember: memberID 
		_:  invkind 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
GetTypeAttr: resultReference
        " Invoke the ITypeInfo::GetTypeAttr function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEMemoryAddress new.  " don't track finalization on the address,
		because it can't be released properly independently of the containing TYPEATTR "
    hresult := self invokeGetTypeAttr: resultValue asParameter.
    resultReference value: ( OLEStructure createStructureNamed: #TYPEATTR
        atAddress: resultValue ).
    ^hresult! 
GetRefTypeInfo: hreftype _: resultReference
		" Invoke the ITypeInfo::GetRefTypeInfo function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeInfoPointer forReturnValue.
	hresult := self invokeGetRefTypeInfo: hreftype
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
invokeGetIDsOfNames: rglpszNames _: cNames _: rgmemid
		" Private - invoke the ITypeInfo::GetIDsOfNames function. "

	" HRESULT GetIDsOfNames(
            /* [size_is][in] */ OLECHAR **rglpszNames,
            /* [in] */ UINT cNames,
            /* [size_is][out] */ MEMBERID *rgmemid); "

	<ole: 10 structIn ulong structOut hresult>
	^self vtableDispatchFailed!   
GetImplTypeFlags: index _: resultReference
		" Invoke the ITypeInfo::GetImplTypeFlags function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeGetImplTypeFlags: index
		_: resultValue.
	resultReference value: resultValue asInteger.
	^hresult!   
invokeGetContainingTypeLib: pptlib _: pindex
		" Private - invoke the ITypeInfo::GetContainingTypeLib function. "

	" HRESULT GetContainingTypeLib(
            /* [out] */ ITypeLib **pptlib,
            /* [out] */ UINT *pindex); "

	<ole: 18 structOut structOut hresult>
	^self vtableDispatchFailed!  
invokeCreateInstance: puncOuter _: riid _: ppvObj
		" Private - invoke the ITypeInfo::CreateInstance function. "

	" HRESULT CreateInstance(
            /* [in] */ IUnknown *puncOuter,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObj); "

	<ole: 16 handle structIn structOut hresult>
	^self vtableDispatchFailed!
GetIDsOfNames: rglpszNames _: cNames _: resultReference
		" Invoke the ITypeInfo::GetIDsOfNames function.
		Raise an exception if an error occurs.  Answer the result code. "

	| hresult unicodeStrings namesBuffer elementSize offset nIDs 
	  dispidBuffer dispidList |
 
	unicodeStrings := rglpszNames collect: [ :aString |
		UnicodeStringBuffer newExternalBufferFromString: aString ].
	namesBuffer := self asArrayOfStringsParameter: unicodeStrings.

	elementSize := ExternalLong sizeInBytes.   " DISPID is a  LONG value "
	dispidBuffer := ExternalBuffer new: cNames * elementSize.
	[ hresult := self invokeGetIDsOfNames: namesBuffer 
 		_: cNames
		_: dispidBuffer.
		] ensure: [ unicodeStrings do: [ :aString | aString release ] ].

	dispidList := Array new: nIDs.
	offset := 0.
	1 to: cNames do: [ :i |
		dispidList at: i put: ( dispidBuffer longAtOffset: offset ).
		offset := offset + elementSize ].
	resultReference value: dispidList.
	^hresult! 
invokeGetMops: memid _: pbstrMops
		" Private - invoke the ITypeInfo::GetMops function. "

	" HRESULT GetMops(
            /* [in] */ MEMBERID memid,
            /* [out] */ BSTR *pbstrMops); "

	<ole: 17 long structOut hresult>
	^self vtableDispatchFailed! 
invokeGetFuncDesc: index _: pppfuncdesc
		" Private - invoke the ITypeInfo::GetFuncDesc function. "

	" HRESULT GetFuncDesc(
            /* [in] */ UINT index,
            /* [out] */ FUNCDESC **pppfuncdesc); "

	<ole: 5 ulong structOut hresult>
	^self vtableDispatchFailed!
invokeInvoke: pvInstance _:  memid _: wFlags _: pdispparams _: pvarResult _: pexcepinfo _: puArgErr
		" Private - invoke the ITypeInfo::Invoke function. "

	" HRESULT Invoke(
            /* [unique][in] */ void *pvInstance,
            /* [in] */ MEMBERID memid,
            /* [in] */ WORD wFlags,
            /* [in] */ DISPPARAMS *pdispparams,
            /* [out] */ VARIANT *pvarResult,
            /* [out] */ EXCEPINFO *pexcepinfo,
            /* [out] */ UINT *puArgErr); "

	| hresult |
	<ole: 11 structIn long short structIn structOut structOut structOut hresult>
	hresult := self dispatchFailureReason.
	( hresult = DISP_E_EXCEPTION or: [ hresult = DISP_E_TYPEMISMATCH ] )
		ifTrue: [ ^hresult ].  " special exception generation required "
	^self vtableDispatchFailed!  
GetNames: memberId
	_: nameListReference
	_: cMaxNames
	_: countReference
		"Invoke the ITypeInfo::GetNames function.
		Raise an exception if an error occurs.  Answer the result code."

	| bstrPointerSize bstrBuffer countValue hresult count nameList aBstr |
	bstrPointerSize := BSTRMemoryAddress sizeInBytes.
	bstrBuffer := ExternalBuffer new: cMaxNames * bstrPointerSize.
	countValue := ExternalLong new.
	hresult := self invokeGetNames: memberId
		_: bstrBuffer
		_: cMaxNames
		_: countValue.
	count := countValue asUnsignedInteger.
	nameList := Array new: count.
	1 to: count do: [ :i |
		aBstr := BSTR atAddress:
			( BSTRMemoryAddress fromInteger: 
				( bstrBuffer uLongAtOffset: i - 1 * bstrPointerSize ) ).
		"Note: do not release the individual BSTRs."
		nameList at: i put: aBstr asString ].
	nameListReference value: nameList.
	countReference value: count.
	^hresult!  
CreateInstance: controllingUnknown _: iid _: resultReference
		" Invoke the ITypeInfo::CreateInstance function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self invokeCreateInstance: controllingUnknown asParameter
		_:  iid
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
GetMops: memberID _: resultReference
		" Invoke the ITypeInfo::GetMops function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := BSTRMemoryAddress new.
	hresult := self invokeGetMops: memberID 
		_: resultValue asParameter.
	resultReference value: ( BSTR atAddress: resultValue ) asString.
	resultValue release.
	^hresult!
invokeGetDllEntry: memid _:  invkind _: pbstrDllName _: pbstrName _: pwOrdinal
		" Private - invoke the ITypeInfo::GetDllEntry function. "

	" HRESULT GetDllEntry(
            /* [in] */ MEMBERID memid,
            /* [in] */ INVOKEKIND invkind,
            /* [out] */ BSTR *pbstrDllName,
            /* [out] */ BSTR *pbstrName,
            /* [out] */ WORD *pwOrdinal); "

	<ole: 13 long ushort structOut structOut structOut hresult>
	^self vtableDispatchFailed!  
GetVarDesc: index _: resultReference
        " Invoke the ITypeInfo::GetVarDesc function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEMemoryAddress new.  " don't track finalization on the address,
		because it can't be released properly independently of the containing VARDESC "
    hresult := self invokeGetVarDesc: index
        _: resultValue asParameter.
    resultReference value: ( OLEStructure createStructureNamed: #VARDESC
        atAddress: resultValue ).
    ^hresult!   
GetDocumentation: memberID _: nameReference _: docStringReference _: helpContextIDReference _: helpFileReference
		" Invoke the ITypeInfo::GetDocumentation function.
		Raise an exception if an error occurs.  Answer the result code. "

	| nameValue docStringValue helpContextIDValue helpFileValue hresult |
	nameValue := BSTRMemoryAddress new.
	docStringValue := BSTRMemoryAddress new.
	helpContextIDValue := ExternalLong new.
	helpFileValue := BSTRMemoryAddress new.
	hresult := self invokeGetDocumentation: memberID 
		_: nameValue asParameter 
		_: docStringValue asParameter
		_: helpContextIDValue  asParameter
		_: helpFileValue asParameter.
	nameReference value: ( BSTR atAddress: nameValue ) asString.
	nameValue release.
	docStringReference value: ( BSTR atAddress: docStringValue ) asString.
	docStringValue release.
	helpContextIDReference value: helpContextIDValue asUnsignedInteger.
	helpFileReference value: ( BSTR atAddress: helpFileValue ) asString.
	helpFileValue release.
	^hresult!  
invokeGetImplTypeFlags: index _: pimpltypeflags
		" Private - invoke the ITypeInfo::GetImplTypeFlags function. "

	" HRESULT GetImplTypeFlags(
            /* [in] */ UINT index,
            /* [out] */ INT *pimpltypeflags); "

	<ole: 9 ulong structOut hresult>
	^self vtableDispatchFailed! 
invokeGetTypeComp: pptcomp
		" Private - invoke the ITypeInfo::GetTypeComp function. "

	" HRESULT GetTypeComp(
            /* [out] */ ITypeComp **pptcomp); "

	<ole: 4 structOut hresult>
	^self vtableDispatchFailed!  
GetRefTypeOfImplType: index _: resultReference
		" Invoke the ITypeInfo::GetRefTypeOfImplType function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeGetRefTypeOfImplType: index
		_: resultValue asParameter.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!   
doubleFloatValue
	"Private"
	"Construct a Float from the value."

	^Float new
		replaceFrom: 1
		to: 8
		with: ( self bytesAtOffset: self valueOffset count: 8 )
		startingAt: 1! 
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #SAFEARRAYBOUND for: self.!
asFloat: aValue
		" Private - answer <aValue> as a Float. "

	^aValue isNumber
		ifTrue: [ aValue asFloat ]
		ifFalse: [ aValue isNil ifTrue: [ 0.0 ] ifFalse: [ aValue asFloat ] ]! 
cVars

    ^self uShortAtOffset: 46!
invokePropertyPut: dispidMember with: dispatchParameters
		" Set the value of the property identified by the DISPID <dispidMember>. "

	^self invokePropertyPut: dispidMember 
		with: dispatchParameters 
		localeID: STDOLE_LCID!  
argumentIDs: anArray
	"Set the DISPID of named arguments to the integers in <anArray>."

	| nArgs dispidSize dispidArgAddress dispidArgs dispid |
	(nArgs := anArray size) = 0
		ifTrue: [^self].
	dispidSize := ExternalLong sizeInBytes.
	dispidArgAddress := OLEMemoryAddress allocateMemory: nArgs * dispidSize.
	dispidArgAddress doesNotNeedFinalization.
	self ISSUE. "What's the right way to get a block of memory that won't be reclaimed?"
	dispidArgs := ExternalBuffer atAddress: dispidArgAddress.
	"The arguments are packed from last to first."
	1 to: nArgs do:
		[:index |
		dispid := anArray at: 	nArgs - index + 1.
		dispidArgs longAtOffset: (index - 1) * dispidSize put: dispid].
	self
		cNamedArgs: nArgs;
		rgdispidNamedArgs: dispidArgAddress!   
lpadesc

    ^self addressAtOffset: 0!  
refTypeCode: refType
	"Query <refType> to determine the type code of the receiver."

	| code typeAttr kind |
	"code := 0."
	typeAttr := refType getTypeAttr.
	kind := typeAttr typekind.
	kind = TKIND_ENUM
		ifTrue: [code := VT_INT].
	kind = TKIND_INTERFACE
		ifTrue: [code := typeAttr guid].
	kind = TKIND_DISPATCH
		ifTrue: [code := VT_DISPATCH "typeAttr guid"].
	kind = TKIND_COCLASS
		ifTrue: [ code := VT_UNKNOWN "typeAttr guid" ].
	kind = TKIND_ALIAS
		ifTrue: [code := typeAttr tdescAlias typeCodeUsing: refType].
	code = VT_INT
		ifTrue: [code := VT_I4].
	self ASSERT: code notNil.
	typeAttr release.
	^code!   
getTypeInfoCount
		" Answer the number of type information interfaces that an
		object provides.  (This will be either 0 or 1). "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetTypeInfoCount: resultReference.
	^resultReference value!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #CONNECTDATA for: self.!   
typekind

    ^self shortAtOffset: 40!  
cFuncs

    ^self uShortAtOffset: 44!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #FUNCDESC.!  
idldesc

	^self structureAtOffset: 8 type: #IDLDESC!
sourceName
		" Answer a textual, human-readable name of the source of the exception
		(typically the application name). "

	^self stringFromBSTR: self bstrSource!
cNamedArgs
		" Answer the number of named arguments. "

	^self uLongAtOffset: 12!  
typeCodeDescription
		" Answer a string describing the type code of the receiver. "

	^OLEVariant typeCodeDescriptionOf: self typeCode!
guid
		" Answer the unique ID of the type library. "

	^self guidAtOffset: 0!  
lo: anInteger

	^self uLongAtOffset: 0 put: anInteger!  
internalFloatFromExternalFloat: singleFloatBytes
		" Answer a Float, representin the value as the C type #double, which is 
		created by converting the 4-byte array <singleFloatBytes>, 
		corresponding to the C type #float.  An OLEError will be
        signaled if <singleFloatBytes> cannot be represented as a #double. "

	| resultReference |
	resultReference := nil asValueReference.
	OLEAutomationDLL current VarR8FromR4: singleFloatBytes _: resultReference.
	^resultReference value!   
releaseResources
		" Private - release resources owned by the receiver. "

	OLEAutomationDLL current SafeArrayDestroy: self.!  
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #TYPEATTR for: self.!  
xEMPTY: aValue
	"Private"
	"Store 0 to represent EMPTY."

	self uLongAtOffset: self valueOffset put: 0.!  
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #SAFEARRAY for: self.! 
setBasicValue: aValue
		" Private - set the basic value of the variant to the external representation of <aValue>.
		The type of the UNION field is specified by the VARTYPE value in the vt field. "

	self
		perform:
			( EncoderSelectors
				at: self baseTypeCode + 1
				ifAbsent: [ #xIllegal: ] )
		with: aValue.!  
typeCodeUsing: iTypeInfo
	"Answer the type code using <iTypeInfo>, an ITypeInfo, to retrieve additional type information if needed."

	| code refType |
	code := self vt.
	code = VT_PTR
		ifTrue:
			[code := self ptrType typeCodeUsing: iTypeInfo.
			^code isInteger
				ifTrue: [VT_BYREF | code]
				ifFalse: [code]].
	code = VT_SAFEARRAY
		ifTrue:
			[code := self arrayType typeCodeUsing: iTypeInfo.
			^code isInteger
				ifTrue: [VT_BYREF | code]
				ifFalse: [code]].
	code = VT_CARRAY
		ifTrue: [self halt].
	code = VT_USERDEFINED
		ifTrue:
			[refType := iTypeInfo getRefTypeInfo: self hreftype.
			code := self refTypeCode: refType.
			refType release.
			^code].
	^code!   
initialize
		" Private - initialize a new instance of the receiver. "

	self iid: IID_IDispatch.!  
getRefTypeOfImplType: index
		" Retrieve the type description of the specified interface type
		for a member which is a component object class. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetRefTypeOfImplType: index _: resultReference.
	^resultReference value!  
getContainingTypeLibIndex
        " Answer the index which identifies the receiver in its containing type library. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetContainingTypeLib: nil asValueReference 
		_: resultReference.
	^resultReference value! 
getMethodEntryPointDescription: memberID
		" Answer the DLL entry point description of method <memberID>. "

	^self getDllEntryPointDescription: memberID 
		kind: INVOKE_FUNC!   
getTypeAttr
		" Answer the type attribute description of the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetTypeAttr: resultReference.
	resultReference value typeInterface: self.  " to support releasing "
	^resultReference value!   
getMops: memberID
		" Answer the name of the structure marshalling operation of the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetMops: memberID _: resultReference.
	^resultReference value!   
getFuncDesc: index
		" Answer a function description of the <index>-the function in the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetFuncDesc: index _: resultReference.
	resultReference value typeInterface: self.  " to support releasing "
	^resultReference value!   
getVarDesc: index
		" Answer a variable description of the <index>-the member in the receiver. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetVarDesc: index _: resultReference.
	resultReference value typeInterface: self.  " to support releasing "
	^resultReference value!   
getPropertyGetEntryPointDescription: memberID
		" Answer the DLL entry point description of the property get method <memberID>. "

	^self getDllEntryPointDescription: memberID 
		kind: INVOKE_PROPERTYGET!  
getPropertySetEntryPointDescription: memberID
		" Answer the DLL entry point description of the property set method <memberID>. "

	^self getDllEntryPointDescription: memberID 
		kind: INVOKE_PROPERTYPUT!  
getIDsOfNames: memberNames
		" Answer a list of member id's corresponding to the
		list of member names in <memberNames>. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetIDsOfNames: memberNames
		_: memberNames size 
		_: resultReference.
	^resultReference value!  
getNames: memberID count: numberOfNames
		" Answer a list of the names of the member identified by <memberID>. 
		If there are more than <numberOfNames> names, answer the first <numberOfNames>.
		Variables have one name, functions have one plus the number of parameters. "

    | nameListReference |
    nameListReference := nil asValueReference.
    interface GetNames: memberID
        _: nameListReference
        _: numberOfNames
        _: nil asValueReference.
    ^nameListReference value!   
addressOfMember: memberID kind: invkind
		" Answer the address of a static function or variable identified by <memberID>
		either a method or property function according to the INVOKE type <invkind>.
		Raise an exception if an error occurs. "

	| resultReference |
	resultReference := nil asValueReference.
	interface AddressOfMember: memberID _: invkind _: resultReference.
	^resultReference value!   
invokeMethod: memberID with: dispatchParams interface: anInterface
		" Invoke the method identified by <memberID> of the
		object <anInterface>, passing the arguments <dispatchParams>.
		Return the result value, if any. "

    ^self invoke: anInterface 
		memberId: memberID 
		flags: DISPATCH_METHOD 
		parameters: dispatchParams
		hasReturnValue: true!   
getDllEntryPointDescription: memberID kind: invokeKind
		" Answer the DLL entry point description of <memberID>,
		which is a method or property get/set function per <invokeKind>. "

	| dllNameReference entryPointNameReference ordinalReference |
	dllNameReference := nil asValueReference.
	entryPointNameReference := nil asValueReference.
	ordinalReference := nil asValueReference.
	interface GetDllEntry: memberID 
		_:  invokeKind 
		_: dllNameReference 
		_: entryPointNameReference 
		_: ordinalReference.
	^Dictionary new
		at: 'dllName' put: dllNameReference value;
		at: 'entryPointName' put: entryPointNameReference value;
		at: 'ordinal' put: ordinalReference value;
		yourself!  
invokePropertyGet: memberID with: dispatchParams interface: anInterface
		" Get the property value identified by <memberID> of the
		object <anInterface>, passing the arguments <dispatchParams>.
		Return the value. "

    ^self invoke: anInterface 
		memberId: memberID 
		flags: DISPATCH_PROPERTYGET 
		parameters: dispatchParams
		hasReturnValue: true!   
invokePropertyPut: memberID with: dispatchParams interface: anInterface
		" Set the property value identified by <memberID> of the
		object <anInterface>, passing the arguments <dispatchParams>. "

    ^self invoke: anInterface 
		memberId: memberID 
		flags: DISPATCH_PROPERTYPUT 
		parameters: dispatchParams
		hasReturnValue: false!   
releaseTypeAttr: aTypeAttr
		" Release a TYPEATTR previously obtained from ITypeInfo::GetTypeAttr. "

	interface ReleaseTypeAttr: aTypeAttr.!  
releaseVarDesc: aVarDesc
		" Release a VARDESC previously obtained from ITypeInfo::GetVarDesc. "

	interface ReleaseVarDesc: aVarDesc.!
getImplTypeFlags: index
		" Answer the type flags of a component object class member. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetImplTypeFlags: index _: resultReference.
	^resultReference value! 
getRefTypeInfo: refType
		" Answer an ITypeInfo which accesses the type descriptions of any
		types referenced by this type reference. "

	| resultReference |
	resultReference := ITypeInfo new asValueReference.
	interface GetRefTypeInfo: refType _: resultReference.
	^resultReference value! 
getContainingTypeLib
		" Answer the type library containing the receiver. "

	| resultReference |
	resultReference := ITypeLib new asValueReference.
	interface GetContainingTypeLib: resultReference 
		_: nil asValueReference.
	^resultReference value! 
createInstance
		" Create an uninitialized instance of the receiver's class
		and answer its IUnknown interface. "

    ^self createInstance: IID_IUnknown controllingUnknown: nil!   
releaseFuncDesc: aFuncDesc
		" Release a FUNCDESC previously obtained from ITypeInfo::GetFuncDesc. "

	interface ReleaseFuncDesc: aFuncDesc.!  
invoke: anInterface 
	memberId:  memberID 
	flags: dispatchFlags 
	parameters: dispatchParams
	hasReturnValue: hasReturnValue
		" Invoke the method or property get/set function identified by <memberID>
		of the object of <anInterface>.  Answer the result vaue, if any.  
		Raise an exception if an error occurs. "

	| resultReference exceptionInfoReference argErrorReference hresult |
	hasReturnValue
		ifTrue: [ resultReference := nil asValueReference ].
	exceptionInfoReference := nil asValueReference.
	argErrorReference := nil asValueReference.
	interface invoke: anInterface 
		_:  memberID 
		_: dispatchFlags 
		_: dispatchParams 
		_: resultReference 
		_: exceptionInfoReference 
		_: argErrorReference.
	( HRESULT succeeded: hresult )
		ifFalse: [
			self signalDispatchError: hresult 
				exceptionInfo: exceptionInfoReference value
				argError: argErrorReference value.
			].
	hasReturnValue 
		ifTrue: [ ^resultReference value ]!   
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
typeCode: anInteger
	"Set the receiver's type code to be <anInteger>."

	typeCode := anInteger!
argumentValues
	"Answer the argument values."

	^self arguments collect: [:each | each value]! 
wMinorVerNum
        " Answer the minor version number of the type library. "

    ^self uShortAtOffset: 26!   
xVARIANT: aValue
	"Private"
	"This is illegal since VARIANTs may only be passed by reference."

	self xIllegal: aValue.!  
sizeInBytes
         " Answer the size in bytes of the structure represented by the receiver. "

    ^74!  
registerIID
        " Private - register the receiver as the interface class for its IID.
		IDispatch actually registers a family of interface ID's. "

	| pointerBindingClass callinBindingClass |
	"self ASSERT: ( self supportedIIDs includes: self iid )."
	pointerBindingClass := self interfacePointerClass.
	callinBindingClass := self interfaceImplementationClass.
	self supportedIIDs do: [ :anIID |
		pointerBindingClass registerIID: anIID 
			forClass: pointerBindingClass.
		callinBindingClass registerIID: anIID 
			forClass: callinBindingClass.
		self registerIID: anIID forClass: self ].!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #VARDESC.!   
isPropertyPutRef

	^self invkind = DISPATCH_PROPERTYPUTREF! 
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
arrayType

    ^OLEStructure createStructureNamed: #ARRAYDESC
        atAddress: self lpadesc! 
rgvarg
		" Answer the address of the argument array. "

	^self oleAddressAtOffset: 0!  
isVARIANT
	"Answer <true> if the receiver supports the VARIANT protocol."

	^false!
xUI1: aValue
	"Private"
	"Store <aValue> as an unsigned byte."

	self byteAtOffset: self valueOffset 
		put: ( ( self asInteger: aValue ) bitAnd: 16rFF ).!  
memid

    ^self longAtOffset: 0!   
invokeIsName: szNameBuf _: lHashVal _: pfName
		" Private - invoke the ITypeLib::IsName function. "

	" HRESULT IsName(
            /* [in] */ LPOLESTR szNameBuf,
            /* [in] */ ULONG lHashVal,
            /* [out] */ BOOL *pfName); "

	<ole: 10 structIn ulong structOut hresult>
	^self vtableDispatchFailed

! 
ReleaseTLibAttr: aTLibAttr
		" Invoke the ITypeLib::ReleaseTLibAttr function. "

	" void ReleaseTLibAttr(
            /* [in] */ TLIBATTR *ptlibattr); "

	<ole: 12 structIn none>
	^self vtableDispatchFailed!
invokeGetDocumentation: index _: pbstrName _: pbstrDocString _: pdwHelpContext _: pbstrHelpFile
		" Private - invoke the ITypeLib::GetDocumentation function. "

	" HRESULT GetDocumentation(
            /* [in] */ INT index,
            /* [out] */ BSTR *pbstrName,
            /* [out] */ BSTR *pbstrDocString,
            /* [out] */ DWORD *pdwHelpContext,
            /* [out] */ BSTR *pbstrHelpFile); "

	<ole: 9 long structOut structOut structOut structOut hresult>
	^self vtableDispatchFailed
!   
GetTypeComp: resultReference
		" Invoke the ITypeLib::GetLibAttr function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeCompPointer new.
	hresult := self invokeGetTypeComp: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
GetTypeInfo: index _: resultReference
		" Invoke the ITypeLib::GetTypeInfo function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeInfoPointer forReturnValue.
	hresult := self invokeGetTypeInfo: index 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
GetTypeInfoCount
		" Invoke the ITypeLib::GetTypeInfoCount function."

	" UINT GetTypeInfoCount( void); "

	<ole: 3 ulongReturn>
	^self vtableDispatchFailed
! 
invokeFindName: szNameBuf _: lHashVal _: rgptinfo _: rgmemid _: pcFound
		" Private - invoke the ITypeLib::FindName function. "

	" HRESULT FindName(
            /* [in] */ LPOLESTR szNameBuf,
            /* [in] */ ULONG lHashVal,
            /* [length_is][size_is][out] */ ITypeInfo **rgptinfo,
            /* [length_is][size_is][out] */ MEMBERID *rgmemid,
            /* [out][in] */ USHORT *pcFound); "

	<ole: 11 structIn ulong structOut structOut struct hresult>
	^self vtableDispatchFailed
!  
FindName: aString _: lHashVal _: typeInfoReference _: memberIdReference _: countReference
		" Invoke the ITypeLib::FindName function.
		Raise an exception if an error occurs.  Answer the result code. "

	| typeInfoValue memberIdValue countFound hresult |
	self ISSUE. self notYetImplemented.  " This needs work; also needs a civilized accessor. " 
	typeInfoValue := ITypeInfoPointer forReturnValue. "????"
	memberIdValue := ExternalLong new.   " THIS NEEDS TO BE AN ARRAY "
	countFound := ExternalBuffer new: 2.
	countFound uShortAtOffset: 0 put: countReference value.
	hresult := self invokeFindName: ( self asUnicodeParameter: aString )
		_: lHashVal 
		_: typeInfoValue asParameter 
		_: memberIdValue
		_: countFound.
	typeInfoReference value: typeInfoValue.
	memberIdReference value: ( memberIdValue asUnsignedInteger ).
	countReference value: ( countFound uShortAtOffset: 0 ).
	^hresult!   
GetTypeInfoOfGuid: aGUID _: resultReference
		" Invoke the ITypeLib::GetTypeInfoOfGuid function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ITypeInfoPointer forReturnValue.
	hresult := self invokeGetTypeInfoOfGuid: aGUID
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!
invokeGetTypeInfoType: index _: ptkind
		" Private - invoke the ITypeLib::GetTypeInfoType function. "

	" HRESULT GetTypeInfoType(
            /* [in] */ UINT index,
            /* [out] */ TYPEKIND *ptkind); "

	<ole: 5 ulong structOut hresult>
	^self vtableDispatchFailed
!  
invokeGetLibAttr: pptlibattr
		" Private - invoke the ITypeLib::GetLibAttr function. "

	" HRESULT GetLibAttr(
            /* [out] */ TLIBATTR **pptlibattr); "

	<ole: 7 structOut hresult>
	^self vtableDispatchFailed! 
invokeGetTypeInfo: index _: ppitinfo
		" Private - invoke the ITypeLib::GetTypeInfo function. "

	" HRESULT GetTypeInfo(
            /* [in] */ UINT index,
            /* [out] */ ITypeInfo **ppitinfo); "

	<ole: 4 ulong structOut hresult>
	^self vtableDispatchFailed
!
invokeGetTypeInfoOfGuid: guid _: pptinfo
		" Private - invoke the ITypeLib::GetTypeInfoOfGuid function. "

	" HRESULT GetTypeInfoOfGuid(
            /* [in] */ REFGUID guid,
            /* [out] */ ITypeInfo **pptinfo); "

	<ole: 6 structIn structOut hresult>
	^self vtableDispatchFailed!  
GetLibAttr: resultReference
		" Invoke the ITypeLib::GetLibAttr function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := OLEMemoryAddress new.
    hresult := self invokeGetLibAttr: resultValue asParameter.
    resultReference value: ( OLEStructure createStructureNamed: #TLIBATTR
        atAddress: resultValue ).
    ^hresult! 
GetTypeInfoType: index _: resultReference
		" Invoke the ITypeLib::GetTypeInfoType function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeGetTypeInfoType: index 
		_: resultValue asParameter.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!  
GetDocumentation: index _: nameReference _: docStringReference _: helpContextIDReference _: helpFileReference
		" Invoke the ITypeLib::GetDocumentation function.
		Raise an exception if an error occurs.  Answer the result code. "

	| nameValue docStringValue helpContextIDValue helpFileValue hresult |
	nameValue := BSTRMemoryAddress new.
	docStringValue := BSTRMemoryAddress new.
	helpContextIDValue := ExternalLong new.
	helpFileValue := BSTRMemoryAddress new.
	hresult := self invokeGetDocumentation: index 
		_: nameValue asParameter 
		_: docStringValue asParameter
		_: helpContextIDValue asParameter
		_: helpFileValue asParameter.
	nameReference value: ( BSTR atAddress: nameValue ) asString.
	nameValue release.
	docStringReference value: ( BSTR atAddress: docStringValue ) asString.
	docStringValue release.
	helpContextIDReference value: helpContextIDValue asUnsignedInteger.
	helpFileReference value: ( BSTR atAddress: helpFileValue ) asString.
	helpFileValue release.
	^hresult!  
invokeGetTypeComp: pptcomp
		" Private - invoke the ITypeLib::GetLibAttr function. "

	" HRESULT GetTypeComp(
            /* [out] */ ITypeComp **pptcomp); "

	<ole: 8 structOut hresult>
	^self vtableDispatchFailed

!
IsName: aString _: lHashVal _: resultReference
		" Invoke the ITypeLib::IsName function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalBuffer new: 2.
	hresult := self invokeIsName: ( self asUnicodeParameter: aString )
		_: lHashVal
		_: resultValue asParameter.
	resultReference value: ( resultValue booleanAtOffset: 0 ).
	^hresult!
memberID
	"Answer the unique identifier of the member."

	^self memid! 
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #IDLDESC for: self.!   
xUI4: aValue
	"Private"
	"Store <aValue> as an unsigned long."

	self uLongAtOffset: self valueOffset put: ( self asInteger: aValue )!
getIDsOfNames: names
		" Answer the DISPID's corresponding to a set of argument names. "

	^self getIDsOfNames: names localeID: STDOLE_LCID!   
parameterTypeCodes
	"Answer an array of descriptors for the parameters."

	^self parameterValueDescriptions collect: [:each | each typeCode]!  
isRestricted

	^self wFuncFlags & FUNCFLAG_FRESTRICTED = FUNCFLAG_FRESTRICTED!  
lprgscode

    ^self uLongAtOffset: 4!  
typeCode
	"Answer the integer that defines the type of the variable."

	^self returnValueDescription typeCode!