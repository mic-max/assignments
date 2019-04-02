3.1.0.106
   
initialize
        " Private - initialize the class state. "

    self registerStructureName.
    self registerEnumeratorIID.!
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #tdesc #idldesc )!
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #hi #lo )
		conversions: #( #asInteger #asFloat )!   
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #memid #lprgscode #lprgelemdescParam #funckind #invkind #callconv #cParams
            #cParamsOpt #oVft #cScodes #elemdescFunc #wFuncFlags )!   
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
    "Private - initialize the class state."

    super initialize.
    self registerStructureName.
    self registerEnumeratorIID!
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #guid #lcid #memidConstructor #memidDestructor #lpstrSchema #cbSizeInstance
            #typekind #cFuncs #cVars #cImplTypes #cbSizeVft #cbAlignment #wTypeFlags
            #wMajorVerNum #wMinorVerNum #tdescAlias #idldescType )!
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #wCode #bstrSource #bstrDescription #bstrHelpFile #dwHelpContext #scode )
		conversions: #( #description #sourceName #helpFile )!
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #memid #lpstrSchema #oInst #lpvarValue #elemdescVar #wVarFlags #varkind )!
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #cElements #lLbound )!
inspectorFields
        "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass fields: #( #asByteArray )!
" OLE Automation Development - library installation "

    " install pool dictionaries as constant pools "
    OLESessionManager registerConstantPoolNames: 
        #( #OLEAutomationConstants ).
! 
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #cbElements #cDims #cLocks #fFeatures #pvData #rgsabound )
		conversions: #( #asArray )! 
initialize
		" Private - initialize the class state. "

	self initializeSupportedIIDs.
	super initialize.!
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #tdescElem #cDims )!  
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #bstrIDLInfo #wIDLFlags )!
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #value )! 
initialize
	"Private - initialize the class state."

	self initializeTranslationMaps.! 
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #vt )
		conversions: #( #typeCodeDescription #valueDescription #value )! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #rgvarg #rgdispidNamedArgs #cArgs #cNamedArgs )
		conversions: #( #arguments #argumentIDs )! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
constructSupportedIIDs
		" Private - answer the dispatch interface id's which can be represented
		by instances of the receiver. "

	^Set
		with: IID_IDispatch
		with: IID_IFontDisp
		with: IID_IPictureDisp
!  
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initializeTranslationMaps
		" Private - initialize the type translation mapping specifications
		for encoding and decoding variant values.   To support a new
		variant type code, implement an encoding and decoding method
		and register them in the translating maps defined here, indexed
		by the variant type code for translation lookup. "

	DecoderSelectors := #(
		#xEMPTY #xNULL #xI2 #xI4 #xR4 #xR8 #xCY #xDATE #xBSTR
		#xDISPATCH #xERROR #xBOOL #xVARIANT #xUNKNOWN
		#xIllegal #xIllegal #xIllegal #xUI1 #xUI2 #xUI4 ).

	EncoderSelectors := #(
		#xEMPTY: #xNULL: #xI2: #xI4: #xR4: #xR8: #xCY: #xDATE: #xBSTR:
		#xDISPATCH: #xERROR: #xBOOL: #xVARIANT: #xUNKNOWN:
		#xIllegal: #xIllegal: #xIllegal: #xUI1: #xUI2: #xUI4: ).!   
initialize
		" Private - initialize the class state of the receiver. "

	super initialize.
	self registerEnumeratorIID.!  
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #lptdesc #lpadesc #hreftype #vt )!
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #cbSize #data )!  
initializeSupportedIIDs
		" Private - initialize the list of interfaces which are supported by the receiver. "

	self supportedIIDs: self constructSupportedIIDs.! 
initialize
	"Private - initialize the class state."

	self 
		initializeTypeCodeNameMap;
		initializeVariantTypeMap.!
inspectorFields
	"Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #( #value )
		conversions: #( #asDate )!
initializeTypeCodeNameMap
		" Private - initialize the type name mapping specifications. "

	| aMap |
	aMap := Dictionary new.
	OLEAutomationConstants associationsDo: [ :assoc |
		( assoc key size > 3
		and: [ ( assoc key copyFrom: 1 to: 3 ) = 'VT_' ] )
			ifTrue: [ aMap at: assoc value put: assoc key ] ].
	self typeCodeNameMap: aMap.

!
" OLE Automation Development - library removal "

    " remove pool dictionaries as constant pools "
    OLESessionManager removeConstantPoolNames: 
        #( #OLEAutomationConstants ).
! 
inspectorFields
    "Answer the names of the fields contained in this kind of definition."

    ^self inspectorClass
        fields: #( #guid #lcid #syskind #wMajorVerNum #wMinorVerNum #wLibFlags )!
initializeVariantTypeMap
		" Private - initialize the mapping registry from classes
		to VARIANT types, where the type mapping of a value
		is well-understood for all instances of the class. "

	| wellDefinedMappings |
	wellDefinedMappings := IdentityDictionary new
		at: UndefinedObject put: VT_NULL;
		at: True put: VT_BOOL;
		at: False put: VT_BOOL;
		at: String put: VT_BSTR;  " VT_LPSTR or VT_LPWSTR are also possible encodings "
		at: SmallInteger put: VT_I4;  " need to decentralize this... "
		at: LargePositiveInteger put: VT_CY;
		at: Float put: VT_R8;
		at: Date put: VT_DATE;
		"at: ( OLEStructure classForStructureNamed: #FILETIME ) put: VT_FILETIME;"
		yourself.
	self variantTypeMap: wellDefinedMappings.!