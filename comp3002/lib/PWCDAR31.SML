3.1.0.106
   
objectFromRecord16
        "Private - Update object from the memory pointed to
        by flat address pmAddress.  pmAddress will be
        allocated for the life of the CStructure Part."
    | selfAllocated |

    "If PARTS allocated the storage pointed by self, pmAddress
    will be nonNil.  Otherwise, the dll allocated the memory,
    so PARTS is not responsible for deallocating it."
    selfAllocated := pmAddress notNil.

    "Assume if object is set, then the user wants the object
    updated, instead of being given the address itself.  Otherwise,
    the user wants the address.  "
    selfAllocated
        ifTrue: [
            object := object setFromReference16: pmAddress ]
        ifFalse: [
            pmAddress := (self buffer copyFrom: dataOffset to: dataOffset + 3) asByteArray.
            pmAddress := ExternalSegmentedAddress fromBytes: pmAddress.
            object := pmAddress.
            "Restore to nil for next selfAllocated check."
            pmAddress := nil ].! 
free
		 "Private - Free nonSmalltalk memory associated with this item."
    pmAddress notNil
        ifTrue: [ pmAddress free.  pmAddress := nil ]!
new

    ^super new object: 0; yourself!
validReturnType: aSymbol
        " Answer whether aSymbol is a valid DLL
        return types. "
    ^self class returnTypes includes: aSymbol!
vmPrimitiveNumber
        " Private - answer the VM primitive number to use
        for the receiver's calling convention. "
   ^DynamicLinkLibrary apiPrimitiveFor:  (
        #( 'c:' 'api:' 'c16:' 'pascal16:' )
            at: ( #( 'c' 'pascal' 'c16' 'pascal16' ) indexOf: self callingConvention ) ).!   
defaultCallingConvention
        " Answer the default calling convention. "
    ^'c'!   
new

    ^super new object: String new; yourself!   
returnType
        " Answer the return type of this entry point. "
    ^returnType! 
setVisualPartAttributes: visualPart
        "Private - set the number of characters allowed to type."
    visualPart setTextLimit: self itemSize.!  
delete
        "Deletes the record at the current position."
    | dataBuffer keyBuf buffer |
    "For some reason, we need to have data and key
    buffer even for a close operation."
    dataBuffer := ByteArray new: 4.
    keyBuf := ByteArray new: 4.
    statusCode:= self
        btrvOperation: BtrDelete
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  keyBuf
        keyLen: 255
        keyNum: 0.
    statusCode = 0 ifTrue: [ "Clear the fields"
        buffer := externalRecord buffer.
        buffer
            replaceFrom: 1
            to: buffer size
            withObject: 0 asCharacter.
        externalRecord updateUI].
    self displayStatusCode.
    ^statusCode!  
initialize
         "Private -"

    accessorWidget := self.!  
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'FRMTTDNM.PAR'!   
resetBufferAddress
        " Private - reset the pointer to nonSmalltalk memory.
        This item has no memory to be freed."

    self subItems isEmpty
        ifFalse: [ "item is group"
            self subItems do: [ :item | item resetBufferAddress ]].!   
new
        " Answer an entry point with no arguments. "
    ^self forMessage: ''!  
accessorPart
		"Private - "
    ^self superItem accessorPart!   
objectToRecord
        "Private - Convert the Smalltalk object to a representation
        of the external format and place it in the buffer."
    | zString |
    zString := object asAsciiZ.
    self buffer
        replaceFrom: dataOffset
            to: dataOffset + zString size - 1   "- 1 for the zero terminator."
            with: zString .!
objectFromRecord
        "Private - Update object from the memory pointed to
        by flat address pmAddress.  pmAddress will be
        allocated for the life of the CStructure Part."
    | selfAllocated |

    "If PARTS allocated the storage pointed by self, pmAddress
    will be nonNil.  Otherwise, the dll allocated the memory,
    so PARTS is not responsible for deallocating it."
    selfAllocated := pmAddress notNil.

    "Assume if object is set, then the user wants the object
    updated, instead of being given the address itself.  Otherwise,
    the user wants the address.  "
    selfAllocated
        ifTrue: [
            object := object setFromReference: pmAddress ]
        ifFalse: [
            pmAddress := (self buffer copyFrom: dataOffset to: dataOffset + 3) asByteArray.
            pmAddress := ExternalAddress fromBytes: pmAddress.
            object := pmAddress.
            "Restore to nil for next selfAllocated check."
            pmAddress := nil ].!  
itemSize: anInteger
        "Answer an instance with itemSize set to anInteger."
    ^self new itemSize: anInteger; yourself!   
objectFromRecord
        "Private - Answer the string in data at dataOffset."
    ^object := (self buffer
        copyFrom: dataOffset
        to: self itemSize - 1 + dataOffset) asNormalizedString!
topItem
        "Private - Answer the topmost ExternalDataItem containing 
		the receiver."
    ^superItem topItem!
argumentNames
    | names aKeyword stream start  |

    ( Message numberOfArgumentsFor: selector ) = 0
        ifTrue: [ ^#() ].   " unary message selector "

    " parse a binary or keyword message selector "
    names := OrderedCollection new.
    stream := ReadStream on: selector.
    [ stream atEnd ] whileFalse: [
        start := stream position + 1.
        stream skipTo: $:.
        aKeyword := stream copyFrom: start to: stream position.
        names add: aKeyword ].
    ^names asArray.!
partAdded: aComponent
        " Private - the part aComponent has just been added
        to the receiver's application. "
    ( ( self isAnchorWindow: aComponent )
    and: [ ( self partEditor findLinksSending: #open to: self ) isEmpty ] )
        ifTrue: [ self createOpenCloseLinksFrom: aComponent ].! 
contents
		 "Private - Answer aString which stores the bytes of
		of the struct."
    buffer isNil ifTrue: [self allocateRecord].
    ^super contents.!   
fromExternalDataItem: aDataItem
        "Private - Answer a BtrieveKey  for the external data item."
    | newBtrieveKey |
    newBtrieveKey := self new
        flags: 0 | BtrDuplicatesAllowed | BtrModifiable;
        externalDataItem: aDataItem.
    ^newBtrieveKey!  
addFixedLengthSubItem: item
        "Private - Add item to the end of the fixed-length items
        section.  All fixed length items are first, variable-legnth
        items last."
    | newSubItems |

"Copy the fixed length items."
    newSubItems := OrderedCollection new.
    self subItems do: [:i | i isVariableLength
        ifFalse: [newSubItems add: i]].

"Put the item in."
    item dataOffset:
        (newSubItems size = 0
            ifTrue: [self dataOffset]
            ifFalse: [newSubItems last dataOffset
                + newSubItems last itemSize]);
        superItem: self.
    newSubItems add: item.

"Copy the variable length items."
    self subItems do: [:i | i isVariableLength
        ifTrue: [i dataOffset: newSubItems last dataOffset +
                newSubItems last itemSize.
            newSubItems add: i]].

    self subItems: newSubItems.!  
recordLenght: length

    self shortAtOffset: 0 put: length!
itemSize
        "Private - Answer number of bytes in item."
    ^2!
initialize
        " Initialize the class "

    | platformDll |
    platformDll := ( self
        partsIfOS2Do: [ #DosLibrary ]
        partsIfWindowsDo: [ #KernelLibrary ] ).
    ( platformDll isNil
    or: [((Smalltalk at: platformDll) class compiledMethodAt: #beep:for:) isNil] )
        ifTrue: [self error: 'platform problem'].
    PlatformLibrary := platformDll.!  
vmArgumentTypeFor: aType
    " Private. Map the following:
    reference to ulong.
    boolean to ushort. "

    ^(aType = #reference)
        ifTrue: [#ulong]
        ifFalse: [
            (aType = #boolean)
                ifTrue: [#ushort]
                ifFalse: [aType]]!  
setCurrentKey: aSelector arguments: ignored
		"Private - use the key indicated by the Symbol aSelector
		for doing get operations."
    | keyName |
    "aSelector is of the form: 'use<fieldName>AsKey'"
    keyName := aSelector asString copyFrom: 4 to: (aSelector size - 5).
    keyFields do: [:key | key name  = keyName  ifTrue: [^currentKey := key]].!
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'FRMTTDNM.PAR'!   
fieldAccessLafEvents
        "Private - Answer an collection of event names
		which are triggered with the new value of each field.."
    
    ^self fieldNames collect: [:name |
        (name, ':') asSymbol].!
fieldNamed: aString
		"Private - Answer an instance of a subclass of PARTSExternalDataItem
		with the name aString."
    | dataItem |
    subItems isNil
        ifTrue: [name = aString ifTrue: [^self]]
        ifFalse: [
            subItems do: [ :item |
                dataItem := item fieldNamed: aString.
                dataItem notNil
                    ifTrue: [ ^dataItem] ] ].
    ^nil!  
btrCallsLibrary
        " Private "
    ^BtrCallsLibrary!   
objectToRecord
        "Private - Place the two bytes which make up the ushort
        into the buffer."
    | shifted buffer |
    shifted := object asInteger.
    buffer := self buffer.
    dataOffset to: (dataOffset + itemSize - 1) do: [:i |
        buffer at: i put: (shifted \\ 256) asCharacter.
        shifted := shifted bitShift: -8.
        ]! 
includes: aSelector
        " Answer whether the procedure named aSelector isDefined. "
    entryPointDict isNil ifTrue: [^false].
    ^(entryPointDict at: aSelector ifAbsent: [nil]) notNil! 
entryPointName
        " Answer the entry point name. "
    ^entryPointName!
partMessagesStatic
        "Answer the message that every instance of the
        reciever supports."
    ^#(#open #openOn: #close #exceptionString:
            #insert #update #write #delete #lock #unlock
            #getFirst #getLast
            #getEqual #getGreaterOrEqual #getLessOrEqual
            #getNext #getPrevious)!  
displayStatusCode
        "Private - Display warnings to the user if
            a) there is any warnings, b) displayWarnings is true."
    | event |
    statusCode == 0 ifTrue: [^nil].
    event := statusCode = 9
        ifTrue: [#endOfFileException]
        ifFalse: [#exception:].
    self triggerEvent: event
        withArguments: (Array with: statusCode)
        ifNotHandled: [self warning].! 
closeBtrCallsLibrary
        " Private "

    self btrCallsLibrary notNil
        ifTrue: [
            self btrCallsLibrary close.
            self btrCallsLibrary: nil ].!   
initialize
		"Private -"
    externalRecord := PARTSExternalRecord new
        accessorPart: self;
        yourself.
    keyFields := OrderedCollection new.!
errorMessageDictionary
        " Private "

    ErrorMessageDictionary isNil
        ifTrue: [ ErrorMessageDictionary := self constructErrorMessageDictionary. ].
    ^ErrorMessageDictionary!   
shutdown
        " The session is terminating.  Release memory resources. 
	Iterate through a copy of the list since free removes items from
	the list."

    CStructurePartList isNil ifTrue: [^self].
    CStructurePartList copy do: [ :aCStructure | aCStructure free].!
isVariableLength
        "Private - BtrieveObject is the most general way to store any
        Smalltalk object in Btrieve, and so it is variable length."
    ^true!  
open
        " Open the DLL. "
    self dllHandle.! 
addKeyField: aKey
		" Private - aKey is an instance of PARTSBtrieveKey.
		The first key that is created is the defualt key."
    keyFields add: aKey.
    keyFields size = 1 ifTrue: [currentKey := aKey].!   
dllAccessorClass
    " Private "
    | names |

    ^( ( names := self procedureNames ) isEmpty
    or: [ ( self entryPointFor: names first ) is16Bit not ] )
        ifTrue: [ PARTSDLLAccessorLibrary ]
        ifFalse: [ PARTSDLLAccessorLibrary16 ]!  
itemSize
        "Private - Answer number of bytes in item."
    ^itemSize isNil ifTrue: [0] ifFalse: [itemSize].!  
copyToNonSmalltalkBuffer16
        "Private - Answer an ExternalAddress pointing to memory
        containing a copy of the receiver.  Use nonSmalltalkBuffer
        to keep a permanent buffer in nonSmalltalk memory for
         the life of the CStructrure Part.  Copy 'buffer' to this
        memory. "
    | oldBufferSize newBufferSize |

    nonSmalltalkBuffer isNil
        ifTrue: [
            self cstructurePartList add: self.
            ^nonSmalltalkBuffer := self copyToExternalAddress16 ]
        ifFalse: [
            oldBufferSize := buffer size.
            self contents16.
            newBufferSize := buffer size.
            oldBufferSize ~= newBufferSize
                ifTrue: [
                    nonSmalltalkBuffer free.
                    ^nonSmalltalkBuffer := self copyToExternalAddress16 ]
                ifFalse: [
                    ^nonSmalltalkBuffer
                        at: newBufferSize + 1 put: 0;        "buffer is a string"
                        replaceBytes: newBufferSize with: buffer ]]! 
length

    ^externalDataItem itemSize! 
dataOffset
        "Private - Answer the items data offset."
    ^ dataOffset!  
dataOffset: anOffset
        "Private - Answer proper dataOffset based on necessary
        alignment of anOffset for the receiver."
    ^dataOffset := anOffset!  
shutdown
        " The session is terminating. "

    self closeBtrCallsLibrary.!  
partRealSelectorFor: aSelector
        " Answer the message to send for an alias link
        to access a field of the current record. "

    ( externalRecord partMessages items includes: aSelector )
        ifTrue: [ ^#access:arguments: ].
    ( self keyMessages includes: aSelector )
        ifTrue: [ ^#setCurrentKey:arguments: ].
    ^aSelector! 
contents16
		 "Private - Answer aString which stores the bytes of
		of the struct to be used in making 16 bit API calls."
    buffer isNil ifTrue: [self allocateRecord].
    ^super contents16.! 
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'CHECKBOX.PAR'!   
visualPartFileName: aPart
		"Private -"
    visualPartFileName := aPart!
cstructurePartList
    "Private - Answer the list that keeps track of cstructures
    that may be still pointing to non-smalltalk memory."

    CStructurePartList isNil
        ifTrue: [ CStructurePartList := OrderedCollection new ].
    ^CStructurePartList!  
new

    ^super new object: 0.0 ; yourself! 
selector: aSymbol
        " Specify the message selector representing
        this entry point. "
    selector := aSymbol! 
write
        "Add the current record to the Btrieve File, updating the
        record, if it is already there.  Use the current key to find
        the existing record."
    | dataBuffer size keyNum |
    currentKey isNil
        ifTrue: [^MessageBox warning: 'Write operation requires a key, but no key exists.'].
    dataBuffer := externalRecord contents.
    keyBuffer := self keyValue: currentKey.
    keyNum := (keyFields indexOf: currentKey) - 1.
    size := ExternalLong fromInteger: externalRecord recordSize.
"First just try to insert"
    statusCode := self
        btrvOperation: BtrInsert
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: size asParameter
        keyBuf:  keyBuffer
        keyLen: 255
        keyNum: keyNum.
"If the record already exists, then try to update."
    statusCode == BtrDuplicateKeyValue
        ifTrue: [
"To update, set the current logical position by doing a getEqual."
        statusCode := self
            btrvOperation: BtrGetEqual
            positionBlock: positionBlock
            dataBuf: dataBuffer
            dataLen: size asParameter
            keyBuf:  keyBuffer
            keyLen: 255
            keyNum: keyNum.
"Finally, do the update."
        statusCode == 0 ifTrue: [self update]].
    self displayStatusCode.
    ^statusCode! 
isVariableLength
		"Private - "
    | answer |
    answer := false.
    self subItems do: [:i| answer := answer | i isVariableLength].
    ^answer.! 
indexCount: count

    self shortAtOffset: 4 put: count!
removePartRuntimeLibrary
        " Private - remove the Data Access parts runtime library.
        Remove the workbench support library if it was installed. "

	self removeSessionEventHandlers.
    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!
unlock
		"Remove the record level lock on the current record."
    | dataBuffer keyBuf|
    dataBuffer := ByteArray new: 1.
    keyBuffer := ByteArray new: keyFields first length.
    statusCode:= self
        btrvOperation: BtrUnlock
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  keyBuf
        keyLen: 255
        keyNum: nil.
    self displayStatusCode.
    ^statusCode!  
itemSize: bytes
        "Private - Set the number of bytes in item."
    super itemSize: bytes.
    itemSize := bytes.!
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  When aSelector is a procedure in this
        DLL, map it to the call method which invokes the
        entry point. "

    ^( self includes: aSelector )
        ifTrue: [ #call:arguments: ]
        ifFalse: [ aSelector ]!
fieldTypeSizes
    "Answer the size in bytes, or a descriptive string."

    ^Dictionary new
        at: PARTSBtrieveBoolean put: PARTSBtrieveBoolean new itemSize;
        at: PARTSUnsignedBinary put: 'Size is required';
        at: PARTSLong put: PARTSLong new itemSize;
        at: PARTSShort put: PARTSShort new itemSize;
        at: PARTSDoubleFloat put: PARTSDoubleFloat new itemSize;
        at: PARTSFixedLengthString put: 'Size is required';
        at: PARTSZString put: 'Not Applicable';
        at: PARTSBtrieveDate put: PARTSBtrieveDate new itemSize;
        at: PARTSBtrieveTime put: PARTSBtrieveTime new itemSize;
        at: PARTSBtrieveObject put: 'Not Applicable';
        yourself.!
validArgumentTypes: anArrayOfSymbols
        " Answer whether all the elements are valid DLL
        argument types. "
    | legalTypes |
    legalTypes := self class argumentTypes.
    anArrayOfSymbols do: [ :argType |
        (legalTypes includes: argType) ifFalse: [^false]].
    ^true!  
isAnchorWindow: anObject
        " Private - answer whether anObject should
        be used to trigger open/close links to the receiver. "
    ^(anObject isKindOf: TopPane)
    and: [(anObject isKindOf: DialogTopPane) not]!   
name

    ^ externalDataItem name!  
externalDataItem

    ^externalDataItem!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: self fieldAccessMessages!  
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'FRMTTDNM.PAR'!   
itemSize
		"Private - Answer the byte size of the receiver."
    ^8!
dllName: aString
        " Specify the name of the DLL file. "
    dllName := aString!  
topItem
        "Private - Answer the topmost CobolDataItem
         for the receiver."

    ^topDataItem!
objectFromRecord
        "Private - Answer the Smalltalk object represented by
        the bytes in the specific external format."
    | itemSize buffer |
    buffer := self buffer .
    itemSize := 0.
    [(buffer at: (itemSize + dataOffset)) ~= 0 asCharacter ]
        whileTrue: [itemSize := itemSize + 1].
    object := buffer copyFrom: dataOffset to: dataOffset + itemSize - 1.
    superItem computeOffsets:  superItem dataOffset.
    ^object asNormalizedString.!
is16Bit
        " Answer whether the receiver represents a 16-bit
         entry point. "
    ^self callingConvention last = $6.!  
constructDataTypesDictionary
        "Private - Answer a dictionary mapping visual parts to data items (by class name).
        This needs to be done only once in an image. "

    | aDictionary |
    aDictionary := IdentityDictionary new.
    aDictionary
        at: #PARTSEntryFieldPart put: #PARTSFixedLengthString;
        at: #PARTSAlphabeticEntryFieldPart put: #PARTSFixedLengthString;
        at: #PARTSAlphabeticEntryFieldPart put: #PARTSFixedLengthString;
        at: #PARTSPhoneNumberEntryFieldPart put: #PARTSFixedLengthString;
        at: #PARTSDateEntryFieldPart put: #PARTSBtrieveDate;
        at: #PARTSIntegerEntryFieldPart put: #PARTSLong;
        at: #PARTSFloatEntryFieldPart put: #PARTSDoubleFloat;
        at: #PARTSCurrencyEntryFieldPart put: #PARTSDoubleFloat;
        at: #PARTSPictureFieldPart put: #PARTSFixedLengthString;
        "at: #PARTSTimeEntryFieldPart put: #PARTSFixedLengthString;"
        at: #PARTSTextPanePart put: #PARTSZString;
        at: #PARTSListPanePart put: #PARTSLong;
        at: #PARTSDropDownListPart put: #PARTSLong;
        at: #PARTSComboBoxPart put: #PARTSFixedLengthString;
        at: #PARTSDialPanePart put: #PARTSLong;
        at: #PARTSCheckBoxPart put: #PARTSBtrieveBoolean;
        at: #PARTSGraphPanePart put: #PARTSBtrieveObject.
    " platform-dependent parts "
    #( 
            #PARTSHorizontalScrollBarPart #PARTSVerticalScrollBarPart 
            #PARTSHorizontalSliderPart #PARTSVerticalSliderPart
            #PARTSValueSetPart
            )
        do: [ :aClassName |
            ( Smalltalk at: aClassName ifAbsent: [ nil ] ) isClass
                ifTrue: [ aDictionary at: aClassName put: #PARTSLong ] ].
    ^aDictionary! 
getNext
		"Get the next record using the current key field asending order.
		If there are not more records, trigger #endOfFileException,
		otherwise trigger all the field event values.
		This message relies on a current location which must be first
		established by sending any of the other #getXXX operations other than
		#getPrevious.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer isNil ifTrue: [^self getFirst].
    ^self getOperation: BtrGetNext.!  
addFieldFromPart: part
        "Private - Add a Btrieve field to the receiver appropriate
        for representing the value held in the part.  Also, create links
        to set and get the value in the part from the receiver."

    | dataItemClass anExternalDataItem fieldSelector links |
    links := OrderedCollection new.
    ( dataItemClass := self class dataItemClassFor: part ) notNil
        ifTrue: [
            anExternalDataItem := dataItemClass new.
            anExternalDataItem name: part partName;
                visualPartExtent:
                    ( part partIsWindow
                        ifTrue: [ part rectangle ]
                        ifFalse: [ ( part partWrapper rectangle scaleFrom: part superWindow freeClientArea ) extent ]).
            anExternalDataItem class == PARTSFixedLengthString
                ifTrue: [anExternalDataItem itemSize: 64].    "initial size, user can change."
            self externalRecord addSubItem: anExternalDataItem.
        "If Accessor and FromPane are both in the same Editor, create links."
            self partEditor == part partEditor ifTrue: [
                fieldSelector := part partName copy,':'.
                fieldSelector := fieldSelector asSymbol.
            "Create link from accessor to the control."
            links add: (self partEditor
                createLinkFrom: self
                event: fieldSelector
                to: part
                message: part partSetValueMessage).
            "Create link from the control to the accessor"
             links add: (self partEditor
               createLinkFrom: part
               event: part partNewValueEvent
               to: self
               message: ('set' , fieldSelector) asSymbol).
            ].
            self allocateRecord.
                ].
    ^links! 
btrCallsLibrary: aDllHandleOrNil
        " Private "

    BtrCallsLibrary := aDllHandleOrNil.! 
initPositionBlock
		"Private - positionBlock is used for the API call. "
    positionBlock := ByteArray new: 128.!  
resetErrorMessageDictionary
    "Private -"

    ErrorMessageDictionary := nil!
setFromReference16: aFlatExternalAddress
        " Private - copy the bytes from aFlatExternalAddress
        back into the receiver. "
    |  size |
    size := topDataItem itemSize.
    buffer := (ByteArray new: size)
        replaceFrom: 1
        to: size
        with: aFlatExternalAddress
        startingAt: 1.
    buffer := buffer asString.
    self updateUI16  "to update the UI  parts."!  
isOpen
        " Answer whether the DLL is open. "
    ^dllHandle notNil!   
openIfError: aOneArgBlock
        " Open the DLL.  Evaluate aOneArgBlock
        with the error code if the DLL cannot be opened.
        Answer the DLL handle (nil if failed). "
    ^self dllHandleIfError: aOneArgBlock!  
copyToExternalAddress
        "Private - Answer an ExternalAddress pointing to memory
        containing a copy of the receiver."
    ^ExternalAddress copyToNonSmalltalkMemory: self contents.!   
new

    ^super new object: (Date fromDays: 0); yourself!   
defineProcedure: aSelector entryPoint: anEntryPoint
        " Define the procedure call named aSelector
        to have anEntryPoint as its definition. "
    entryPointDict isNil
        ifTrue: [entryPointDict := Dictionary new].
    entryPointDict at: aSelector put: anEntryPoint.
    anEntryPoint selector: aSelector.
    ^anEntryPoint!
argumentTypes: anArrayOfSymbols
        " Specify the argument types needed to 
        call this entry point. "
    argumentTypes := anArrayOfSymbols!
currentKey: aKey
		"Private - Set aKey which is a PARTSBtrieveKey and is the key 
		used for getXXX operations."
    currentKey := aKey!   
exceptionString: errorNumber
        "Private - Answer a String explaining the
        Btrieve errorNumber."
    ^self class errorMessageDictionary at: errorNumber
        ifAbsent: [ 'Btrieve status code: ' , statusCode printString ]!   
resetBufferAddress
        " Private - reset the pointer to nonSmalltalk memory. "
    pmAddress := nil.!   
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self includes: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [ super partLinkClassFor: aSelector ]!   
getPrevious
		"Get the previous record using the current key field asending order.
		If there are not more records, trigger #endOfFileException,
		otherwise trigger all the field event values.
		This message relies on a current location which must be first
		established by sending any of the other #getXXX operations other than
		#getNext.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer isNil ifTrue: [^self getFirst].
    ^self getOperation: BtrGetPrevious.!  
objectToRecord
        "Private - Place object padded/truncated to itemSize bytes
         into data at dataOffset."
    | copyIndex fieldSize extString |
    fieldSize := self itemSize.
    extString := object asExternalString. "For DoubleByteStrings"
    copyIndex := dataOffset + (extString size min: fieldSize).
    self buffer
        replaceFrom: dataOffset
            to: copyIndex - 1
            with: extString;
        replaceFrom: copyIndex
            to: dataOffset - 1 + fieldSize
            withObject: Space.! 
itemSize: anInteger
        "Private - Set number of bytes in item to anInteger."
    
    super itemSize: anInteger.
    itemSize := anInteger.! 
occursCount
        "Private - Answer the number of occurrences of
          the data item."
    occurs isNil ifTrue: [^1].
    ^occurs!  
btrCallsLibrary
        " Private - answer the DLL handle for the btrieve accessor library. "
    ^BtrCallsLibrary! 
keyMessages
		"Private - Answer an OrderedCollection of Symbols which are the
		messages which choose which key to use for the getXXX operations. "
    |answer |
    keyFields isNil ifTrue: [^#()].
    answer := OrderedCollection new.
    keyFields do: [:key| answer := answer ,
        (Array with: key messageSelector)].
    ^answer!   
call: dllHandle arguments: arguments
        " Call this entry point in dllHandle with the
        given arguments.  Answer an assoc
        with <callWasMadeFlag, result>. "

    | vmArgumentTypes vmReturnType method result  |

    arguments size = argumentTypes size
        ifFalse: [
            ^Association key: false
                value: 'incorrect number of arguments' ].
    ( self class callingConventions includes: self callingConvention )
        ifFalse: [
            ^Association key: false
                value: 'unsupported calling convention'    ].

    vmArgumentTypes := dllHandle convertArray:
        ( argumentTypes
            collect: [ :aType | self vmArgumentTypeFor: aType ] ).
    vmReturnType := dllHandle convertResult:
        ( self vmReturnTypeFor: returnType ).

    " Here we manufacture an API-call CompiledMethod,
        change its API name, API arg types, etc. to match
        the receiver's call, then we put that method into
        a MethodDictionary and attach it to the dllHandle
        and perform it. "
    method := self prototypeApiCallMethod copy.
    method byteCodeArray: method byteCodeArray copy.
    method byteCodeArray     " Second byte is the primitive number. "
        at: 2 put: self vmPrimitiveNumber.
    method
        classField: self dynamicLinkLibraryClass;
        primitive: nil;
        selector: selector;
        hideSource;
        argumentCount: arguments size.
    method
        at: 1 put: entryPointName asAsciiZ;
        at: 2 put: (    " The argument types info "
            ( ( ByteArray new: 4 ) atAllPut: 16rFF ),   " cached api address. "
            ( ByteArray with: argumentTypes size + 1 ),    " number of types "
            vmArgumentTypes,    " arg types "
            ( ByteArray with: vmReturnType )
            ).

    " evaluate the method we've constructed "
    result := dllHandle partDoit: method withArguments: arguments.
    returnType = #reference
        ifTrue: [
            result := ( self is16Bit
                ifTrue: [ExternalSegmentedAddress]
                ifFalse: [ExternalAddress] )
                    fromBytes: result ].
    ^Association key: true value: result!
itemSizeAttribute: anInteger
        "Private - Set itemSize instance var with no processing."
	itemSize := anInteger.! 
asParameter
        "Private - Answer a Btrieve KeySpec array of
        bytes representing the reciever."
    | keySpec |

    "PARTS 1.0 keys are not ExtendedType, so always remove
    Binary and add ExtendedType. AD"
    flags := (flags bitAnd: (BtrBinary bitXor: 16rFFFFFFFF))
        | BtrExtendedType.
    keySpec := PARTSBtrieveKeySpec new
        keyPos: self position;
        keyLen: self length;
        keyFlag: flags;
        keyType: externalDataItem btrieveKeyType.
    ^keySpec asParameter!  
flags: anInteger

    flags := anInteger!   
messageSelector

    ^('use' , self name , 'AsKey') asSymbol!   
visualPartFileName
		"Private - Answer a part file name for a part which is
		suitable for presenting the data."
    ^visualPartFileName notNil
        ifTrue: [visualPartFileName]
        ifFalse: [self defaultVisualPartName]!  
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'TEXTPANE.PAR'!   
removeSubItem: item
		"Private - remove the item from the structure."
    topDataItem removeSubItem: item.
    topDataItem subItems isEmpty
        ifTrue: [topDataItem := nil].!
buffer
        "Private - Answer the data string for the entire
         record containing the receiver."
    ^superItem buffer!   
prependSubItem: item
        "Private - Add item to the subItems of the reciever."
    "Calculate the dataOffset."

    item dataOffset: self dataOffset.
    "Ripple the offsets of siblings."
    self subItems do: [:i| i dataOffset: i dataOffset + item itemSize].
    self subItems: ((Array with: item), self subItems).
    item superItem: self.!
object: aFloat
        "Private - Set the object and do any necessary conversion."
    "Do asFloat in case it is a String."
    object := ( aFloat isNil
        ifTrue: [ nil ]
        ifFalse: [ aFloat asFloat] ).!  
itemSize: anInteger
        "Private - Reset the sizes of all the siblings affected
        by the size change of this item."
    | offset |
    (superItem isKindOf: PARTSExternalDataItem)
         ifTrue: [
            offset := superItem dataOffset.
            superItem subItems do:
                [:item | item dataOffset: offset.
                    offset := item dataOffset + item itemSize].
            superItem itemSize: superItem itemSize].!  
new

    ^super new object: 0;
        itemSize: 2;
        yourself! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    | messages keyMessages fieldMessages separators |
    messages := self partMessagesStatic.
    separators := self partMessagesStaticSeparators.
    keyMessages := self keyMessages.
    (keyMessages size > 0)
        ifTrue: [
            separators := separators, (Array with: messages size).
            messages := messages, keyMessages].
    fieldMessages := externalRecord fieldAccessMessages.
    (fieldMessages size > 0)
        ifTrue: [
            separators := separators, (Array with: messages size).
            messages := messages, fieldMessages].
    ^PARTSInterfaceList new
        items: messages
        separators: separators
        defaultItem: #open!   
forMessage: aSelector
        " Answer a new entry point with the correct
        number of arguments for aSelector. "
    | argumentTypes |
    argumentTypes := Array new: (aSelector occurrencesOf: $: ).
    argumentTypes atAllPut: #ushort.
    ^super new
        entryPointName: 'UNKNOWN';
        argumentTypes: argumentTypes;
        returnType: #ushort;
        selector: aSelector;
        callingConvention: self defaultCallingConvention;
        yourself.!  
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream. "
    aStream nextPutAll: 'a ', self class name.
    dllName notNil
        ifTrue: [aStream nextPutAll: ' (', dllName, ')'].!
subItems
        "Private - Answer the collection of subitems for the receiver."
    subItems isNil
        ifTrue: [^#()]
        ifFalse: [^subItems]!  
updateFromExternalAddress: anExternalAddress
        "Private -The call is finished, and it may have changed the
        contents of the struct, so copy it back to the buffer and update
        the UI parts."
    self setFromReference16: anExternalAddress.! 
update
		"Update the value of the current record.  Before doing an update
		operation, you need to establish a current record by doing a getXXX
		operation."
    | dataBuffer |
    dataBuffer := externalRecord contents.
    keyBuffer := self keyValue: currentKey.
    statusCode := self
        btrvOperation: BtrUpdate
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: externalRecord topItem itemSize) asParameter
        keyBuf: keyBuffer
        keyLen: 255
        keyNum: 0.
    self displayStatusCode.
    ^statusCode!   
new

    ^super new object: 0; yourself!
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrLogical!   
entryPointDict: aDict
        " Private "
    entryPointDict := aDict!  
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrTime!  
fieldTypes

    ^Dictionary new
        at: 'short'  put: PARTSShort;
        at: 'ushort' put: PARTSUShort;
        at: 'long' put: PARTSLong;
        at: 'ulong' put: PARTSULong;
        at: 'double float' put: PARTSDoubleFloat;
        "at: 'boolean' put: PARTSUShort; use UShort instead."
        at: 'array of char' put: PARTSFixedLengthString;
        at: 'reference' put: PARTSCPointer;
        yourself.!   
objectToRecord
		"Private -"
    self buffer
        replaceFrom: dataOffset
        to: dataOffset + self itemSize - 1
        with: object!
partAddedTo: anApplication
        " The receiver has just been added to anApplication.
        Create any links or register event handlers if desired. "

    | windowParts |
    windowParts := anApplication components
        select: [ :aComponent | self isAnchorWindow: aComponent ].
    "(windowParts size = 1) ifFalse: [ ^self ]."
    windowParts isEmpty
        ifTrue: [ ^self ].
    self createOpenCloseLinksFrom: windowParts asArray first.
    self registerWorkbenchEventHandlers:
        anApplication partEditor.!   
createOpenCloseLinksFrom: aTopPane
        " Private - create open and close links from aTopPane. "
    self partEditor
        createLinkFrom: aTopPane
            event: #opened
            to: self
            message: #open;
        createLinkFrom: aTopPane
            event: #closed
            to: self
            message: #close.! 
removeSubItem: anItem
		"Private -"
    | oldSubItems |
    oldSubItems := subItems.
    self subItems: Array new.
    oldSubItems
        do: [:i | i = anItem
            ifFalse: [self appendSubItem: i]].!
setFromReference: anExternalAddress
        "Copy the bytes from anExternalAddress back
        into the CStructure.  You can get anExternalAddress
        from the return value of a DLL Accessor call which
        has a return type of 'reference'. "
    (anExternalAddress isKindOf: ExternalSegmentedAddress)
        ifTrue: [self setFromReference16: anExternalAddress asFlatAddress]
        ifFalse: [self setFromReference32: anExternalAddress]!
returnType: aSymbol
        " Specify the return type of this entry point. "

    returnType := ( returnType = #ulong
        ifTrue: [ #ulongReturn ]
        ifFalse: [ aSymbol ] ).!  
getLast
		"Find the last record using an asending order of the current key field.  
		Trigger all the field event values.  If the file is empty trigger #endOfFileException.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer := self keyValue: currentKey.
    ^self getOperation: BtrGetLast.!
keyPos: pos

    self shortAtOffset: 0 put: pos!
objectToRecord
        "Private - Convert the Smalltalk objects to the external
        representation.  Note: some subclasses have side-effects
        of recalculating the dataOffsets during objectToRecord."

    self subItems do: [:i| i objectToRecord].!
pageSize: size

    self shortAtOffset: 2 put: size!
object: aSmalltalkObject
        "Private - Set the Smalltalk object which is meant to be
        converted to the external form."

    "Truncate and raise error if object is too large.
        If itemSize not set (nil), object can be any size"
    ( aSmalltalkObject isIndexedCollection
        and: [ itemSize notNil
        and: [ aSmalltalkObject size > itemSize ]])
            ifTrue: [
                object := object copyFrom: 1 to: itemSize.
                PARTSInvalidExternalDataItemSize signal ].
    super object: aSmalltalkObject!
partEvents
        " Answer the PARTS event interface of the receiver. "
    | recordEvents |
    recordEvents := externalRecord partEvents items.
    ^PARTSInterfaceList new
        items: self partEventsStatic, recordEvents
        separators: ((recordEvents size > 0)
            ifTrue: [Array with: self partEventsStatic size]
            ifFalse: [Array new])
        defaultItem: #endOfFileException!  
objectFromRecord
        "Private - Answer the itemSize-byte signed integer in
         the buffer starting at dataOffset."
    | buffer |
    buffer := self buffer.
    object := 0.
    0 to: (itemSize - 1)
        do: [:i | object := object +
            ((buffer at: i + dataOffset) asciiValue * (256 raisedTo: i))].

    object > ((2 raisedTo: (itemSize * 8) - 1) - 1)
        ifTrue: [object := object - (2 raisedTo: itemSize * 8)].

    ^object := object asInteger!  
objectFromRecord
        "Private - Answer an Integer from the data in the buffer."
    super objectFromRecord.
    ^object := ((object at: 1) +
        ((object at: 2) bitShift: 8))!   
free
		 "Private - Free any nonSmalltalk memory associated with the subitems.
		This item has no memory to be freed."
    self subItems isEmpty
        ifFalse: [ "item is group"
            self subItems do: [ :item | item free ]].!
initializeSessionEventHandlers
        " Private - register the session event handlers for the
        Data Access parts runtime library
            PARTSBtrieveAccessorPart initializeSessionEventHandlers
        "

	SessionModel current isRunTime
		ifFalse: [ 
			SessionModel current 
				when: #startup 
				send: #sessionStartUp to: self ].
	self sessionStartUp.
	SessionModel current 
		when: #shutdown 
		send: #sessionShutdown to: self.!
dynamicLinkLibraryClass
        " Private "
    ^self is16Bit ifTrue: [DynamicLinkLibrary16] ifFalse: [DynamicLinkLibrary]! 
fieldNames
		"Private - Answer an array of the field names."
    ^topDataItem notNil
        ifTrue: [topDataItem fieldNames asArray]
        ifFalse: [#()]! 
btrvOperation: op
    positionBlock: pos
    dataBuf: data
    dataLen: dataLen
    keyBuf: key
    keyLen: keyLen
    keyNum: keyNum
        "Private - Check for file being open by looking at the positinBlock,
        if open, make the api call."
    ^positionBlock isNil
        ifTrue: [3]        "File not open"
        ifFalse: [ self btrCallsLibrary btrvOperation: op
            positionBlock: pos
            dataBuf: data
            dataLen: dataLen
            keyBuf: key
            keyLen: keyLen
            keyNum: keyNum]!  
object
		"Private - The Smalltalk object which is either meant to be
		converted to the external form, or is the result of converting
		the external bytes."
    ^object! 
objectFromRecord
        "Private - Answer a Time based on the value in the buffer."
    | buffer |
    buffer := self buffer.
    object := Time
        hours:  (buffer at: dataOffset + 3 ) asInteger
        minutes: (buffer at: dataOffset + 2 ) asInteger
        seconds: (buffer at: dataOffset + 1 ) asInteger.
    ^object!
externalDataItem: anItem

    externalDataItem := anItem!   
argumentTypes
    " Answer the argument types supported for DLL calls "
    " Note: the following maps are performed by vmArgumentTypeFor:
        reference maps to ulong.
        boolean maps to ushort. "

    ^#(#short #ushort #long #ulong #boolean #struct #handle #self
             #reference #double )!
new

    ^super new itemSize: 2; yourself.! 
objectToRecord16
        "Private - Generate a pointer to the object and place in the pointer.
         pmAddress should contain a pointer to this object in nonSmalltalk
        memory until a new object is copied."
    
    object isNil
        ifTrue: [^self error: name , ' pointer has not been initialized.'].
    pmAddress notNil
        ifTrue: [ pmAddress free ].

    pmAddress := ( object respondsTo: #copyToExternalAddress16 )
        ifTrue: [ object copyToExternalAddress16 ]
        ifFalse: [ object copyToExternalAddress ].

    self buffer
        replaceFrom: dataOffset
        to: dataOffset + 3
        with: (pmAddress asSegmentedAddress) asParameter.!
fieldAccessMessages
        "Private - Answer an OrderedCollection of Symbols
		for the message  which set or get the field values."
    | answer |
    answer := OrderedCollection new.
    self fieldNames do: [:name |
        answer add: name asSymbol;
            add: ('set' , name, ':') asSymbol].
    ^answer! 
accessorPart
		" Private -"
    ^accessorWidget!
visualPartExtent
		"Private - Answer an extent which will be suitable for
		a visual part for presenting the data."
    ^visualPartExtent notNil
        ifTrue: [visualPartExtent]
        ifFalse: [self defaultVisualPartExtent]! 
itemSize
        "Private - Answer the number of bytes required
        to represent the object in the specific external format."
    ^itemSize isNil
		ifTrue: [ 0 ]
		ifFalse: [ itemSize ]!   
setFromReference32: anExternalAddress
        "Private - Copy the bytes from anExternalAddress back to self. "
    | size |
    size := topDataItem itemSize.
    buffer := (ByteArray new: size)
        replaceFrom: 1
        to: size
        with: anExternalAddress
        startingAt: 1.
    buffer := buffer asString.
    self modified.    "to update the UI  parts."!   
new

    ^super new itemSize: 4; yourself.! 
externalRecord
		"Private - Answer aRecord which is a String and is used to 
		store the data argument of the Btrieve API call."
    ^externalRecord!  
labelOf: aDataItem
		"Private - Answer the label of aDataItem that should appear
    on the form."

    ^aDataItem name!  
callingConvention: aConventionString
        " Set the calling convention of this entry point. "
    ^callingConvention := aConventionString!   
position

    ^externalDataItem dataOffset! 
call: aSelector arguments: arguments
        "Call the entry point associated with aSelector
        with the given arguments (an array of values). "
    
    self dllHandle isNil ifTrue: [^nil].
    ^self call: aSelector arguments: arguments
        ifError: [ :errorMessage |
            self 
                triggerEvent: #callException:arguments:
                withArguments: (Array 
                    with: aSelector, ' ', errorMessage 
                    with: arguments)
                ifNotHandled: [ MessageBox
                    notify: 'DLL Call Failed'
                    withText: 
                        'Call to ', aSelector asString,
                        ' failed (', errorMessage, ').' ].
            ^nil ]!   
COMMENT
"
A PARTSDLLEntryPoint is an entry point for calling
a procedure in a host .DLL from a DLL Accessor part.
"!  
keyFromName: aString
		"Private - Answer a PARTSBtrieveKey. "
    keyFields do: [:key | key name  = aString  ifTrue: [^key]].
    ^nil!
lock
		"Do a record level locking of the currnet record  The unlock message must be
		set before this field can be modified by another user.  Before placing a lock
		you must establish a current record using a getXXX operation."
    | dataBuffer keyBuf|
    "Btrieve does not have a lock, so we will do a
    locked GetDirect (223) operation to lock the current
    record.   We will NOT update the buffer."
    dataBuffer := ByteArray new: 4.
    keyBuffer := ByteArray new: keyFields first length.
    statusCode:= self
        btrvOperation: 22
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  keyBuf
        keyLen: 255
        keyNum: nil.
    statusCode = 0 ifFalse: [
        self displayStatusCode.
        ^statusCode].
    statusCode:= self
        btrvOperation: 223
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  keyBuffer
        keyLen: 255
        keyNum: 0.
    statusCode = 22 ifTrue: [statusCode := 0].
    self displayStatusCode.
    ^statusCode!
objectFromRecord16
        "Private - Update object from the buffer.  All pointers are
        segmented addresses."
    | offset |
    self subItems isEmpty ifTrue: [ ^self objectFromRecord ].
    offset := dataOffset.
    self subItems do: [:i|
        i dataOffset: offset;
            objectFromRecord16.
        offset := i dataOffset + i itemSize].!  
selector
        " Answer the message selector representing
        this entry point. "
    ^selector! 
getLessOrEqual
		"Find the first record whose current key field is less or equal than
		the current key field of the receiver.  If a match is found,
		trigger all the field event values, otherwise trigger #endOfFileException.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer := self keyValue: currentKey.
    ^self getOperation: BtrGetLessOrEqual.!   
sizeInBytes
        "Private - Answer the size of a BtrieveFileSpec structure."
    ^16!
itemSize
        "Private - Answer the number of bytes required
        to represent the object in the specific external format.
        Must do asExternalString for DoubleByteString objects."
    ^object asExternalString size + 1. "+ 1 for the zero terminator."!   
vmReturnTypeFor: aType
        " Private "
    ^(aType = #reference) ifTrue: [#ulong] ifFalse: [aType]! 
fieldTypeNames

    ^(Array new: 10)
        at: 1 put: 'Two Byte Boolean';
        at: 2 put: 'Fixed Length Byte Array';
        at: 3 put: 'Four Byte Signed Integer';
        at: 4 put: 'Two Byte Signed Integer';
        at: 5 put: 'Double Precision IEEE Float';
        at: 6 put: 'Fixed Length String';
        at: 7 put: 'Variable Length ZString';
        at: 8 put: 'Date';
        at: 9 put: 'Time';
        at: 10 put: 'Any Object';
        yourself.!  
dataOffset: anOffset
        "Private - Answer an odd byte boundry equal or greater than
        anOffset.  anOffset is 1-based."
    ^ dataOffset := anOffset bitOr: 1!   
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ( externalRecord partMessages items includes: aSelector )
        ifTrue: [ ^externalRecord partLinkClassFor: aSelector ].
    ^( self keyMessages includes: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [ super partLinkClassFor: aSelector ]!  
close
        " Close the DLL. "
    dllHandle isNil ifTrue: [^self].
    dllHandle close.
    dllHandle := nil.

    "Not needed because call methods are not cached"
    "DynamicLinkLibrary clearCachedAddresses."! 
name
        "Private - Answer the item's name string."
    ^name!  
recordSize
        "Private - Answer the size in bytes."
    ^topDataItem isNil
        ifTrue: [0]
        ifFalse: [topDataItem itemSize].! 
dllHandleIfError: aOneArgBlock
         "Private - answer a handle for this DLL"

    | errorCode |
    dllHandle isNil
        ifTrue: [
            self
                partsIfOS2Do: [
                    dllHandle := self dllAccessorClass open: dllName.
                    (dllHandle isKindOf: DynamicLinkLibrary)
                        ifFalse: [
                            errorCode := dllHandle.
                            dllHandle := nil ] ]
                partsIfWindowsDo: [
                    [ dllHandle := self dllAccessorClass open: dllName ]
                        on: Error do: [ :e |
                            errorCode := ( Smalltalk at: #KernelLibrary ) getLastError.
                            dllHandle := nil ] ].

            ( errorCode isNil  " if not picked off by error handler already "
                and: [ (dllHandle isKindOf: DynamicLinkLibrary) not ] )
                ifTrue: [
                    errorCode := dllHandle.
                    dllHandle := nil ] ].  " open failed "
    errorCode notNil
        ifTrue: [ aOneArgBlock value: errorCode ].
    ^dllHandle!   
argumentTypes
        " Answer the argument types needed to 
        call this entry point. "
    ^argumentTypes!  
partMessagesStaticSeparators
        " Private "
    ^#( 4 10 )!
initializeRuntimeData
        " Private - initialize values in the runtime library
        which must be set at component installation time
        (can't be specified statically in the library). "

	PARTSDLLEntryPoint initialize.
	PARTSBtrieveDLL initialize.!
initialize
        " Private - class initialization. "

    FileName := ( self 
        partsIfOS2Do: [ 'BTRCALLS' ] 
        partsIfWindowsDo: [ 'WBTRCALL.DLL' ] ).!   
getOperation: operation
        "Private - Make the operation BtrCall."
    | size keyNum |
    size := ExternalLong fromInteger: externalRecord buffer size.
    keyNum := (keyFields indexOf: currentKey) - 1.
    statusCode := self
        btrvOperation: operation
        positionBlock: positionBlock
        dataBuf: externalRecord buffer
        dataLen: size asParameter
        keyBuf:  keyBuffer
        keyLen: 255
        keyNum: keyNum.
    statusCode = 0 ifTrue: [externalRecord updateUI].
    self displayStatusCode.
    ^statusCode!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    | fieldMessages |
    fieldMessages := self fieldAccessMessages.
    ^PARTSInterfaceList new
        items:
            #( #value #setFromReference: #free ),
            fieldMessages
        separators: ( fieldMessages size > 0
            ifTrue: [ #( 2 ) ]
            ifFalse: [ #() ] )
        defaultItem: #value!   
startUp
        " The session is starting.  Reset the instance list (freed at shutdown).
    Iterate through a copy of the list since free removes items from
    the list. "

    CStructurePartList isNil ifTrue: [^self].
    CStructurePartList copy do: [ :aCStructure | aCStructure resetBufferAddress].! 
removeProcedure: aSelector
        " Remove the procedure definition of aSelector. "
    entryPointDict removeKey: aSelector ifAbsent: [].! 
name: aString
        "Private - Set the item's name to aString."
    name := aString!  
keyFields: anOrderedCollection
		"Private - Set an OrderedCollection of PARTSBtrieveKey. "
    keyFields := anOrderedCollection!
objectToRecord
        "Private - Write the object of class Date into the buffer
        in Btrieve Date format: day of month first byte, month of
        year second byte, year in last two bytes."
    | buffer |
    buffer := self buffer.
    object isNil ifTrue: [
        ^buffer replaceFrom: dataOffset to: dataOffset + 3 with: (String new: 4)].
    buffer at: dataOffset put: object dayOfMonth asCharacter.
    buffer at: dataOffset + 1 put: object monthIndex asCharacter.
    buffer at: dataOffset + 2 put: (object year \\ 256) asCharacter.
    buffer at: dataOffset + 3 put: (object year // 256) asCharacter.!   
setDllName: aString
        " Specify the name of the DLL file. "

    self dllName: ( aString isString
        ifTrue: [ aString ]
        ifFalse: [ aString isNil ifTrue: [ '' ] ifFalse: [ aString asString ] ] ).
    ^aString!
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream. "
    aStream nextPutAll: 'a', self class name.
    entryPointName notNil
        ifTrue: [aStream nextPutAll: ' (', entryPointName, ')'].!   
fileName
		"Private - Answer the default file name,
		which will be used with the #open operation.
		The openOn: has its own argument and does not
		touch fileName."
    ^fileName! 
objectFromRecord
        "Private - Answer a ByteArray from data at dataOffset."

    ^object := (self buffer
        copyFrom: dataOffset
        to: self itemSize - 1 + dataOffset) asByteArray!  
objectFromRecord
        "Private - Answer the Smalltalk object represented by
        the bytes in the ObjectFiler format."
    | recordStream |
	"When a record is deleted, all the bytes are set to zero,
	if so, answer nil."
	(self buffer copyFrom: dataOffset to: (dataOffset + 3 min: self buffer size))
		= ((String new: 4) atAllPut: 0 asCharacter) 
		ifTrue: [^object := nil].
    recordStream := ReadWriteStream on: self buffer.
    recordStream position: (self dataOffset - 1).
    object := ObjectFiler loadFrom: recordStream.

		"Since BtrieveObject is variable size, we need to update the
		size and the offsets of all the fields following the receiver."

    self itemSize: (recordStream position - self dataOffset) + 1.
    superItem computeOffsets: superItem dataOffset.
    ^object!  
allocateRecord
		"Private -"
    topDataItem notNil 
        ifTrue: [buffer := String new: topDataItem itemSize].!
free
    "Free the nonSmalltalk memory associated with this CStructure Part.
    Remove it from the CStructurePartList so it can be garbage collected."

    nonSmalltalkBuffer notNil
        ifTrue: [
            nonSmalltalkBuffer free.
            self resetBufferAddress ].
    topDataItem notNil
        ifTrue: [ topDataItem free ].!   
close
		"Close the btrieve file."
    | dataBuffer keyBuf|
    "For some reason, we need to have data and key
    buffer even for a close operation."
    dataBuffer := ByteArray new: 4.
    keyBuf := ByteArray new: 4.
    statusCode:= self
        btrvOperation: BtrClose
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  keyBuf
        keyLen: 255
        keyNum: 0.

    statusCode = 0
        ifTrue: [positionBlock := nil].
    statusCode ~= 3  "3 = File not open."
        ifTrue: [self displayStatusCode].
    ^statusCode! 
objectFromRecord
		"Private -"
    | buffer |
    buffer := self buffer.
    object := Float new.
    1 to: self itemSize
        do: [:i | object
            basicAt: i
            put: (buffer at: dataOffset  + i - 1) asciiValue]!  
fieldNamed: aName
		"Private - answer an instance of a subclass of ExternalDataItem
		which matches aName."
    ^topDataItem isNil
        ifTrue: [nil]
        ifFalse: [topDataItem fieldNamed: aName].!  
objectToRecord
        "Private - Place the four bytes which make up the ulong
        into the buffer."
    | shifted buffer |
    shifted := object asInteger.
    buffer := self buffer.
    dataOffset to: (dataOffset + itemSize - 1) do: [:i |
        buffer at: i put: (shifted \\ 256) asCharacter.
        shifted := shifted bitShift: -8.
        ]! 
procedureNames
        " Answer the message selectors for the
        entry points in this DLL. "
    ^entryPointDict isNil
        ifTrue: [Array new]
        ifFalse: [entryPointDict keys asSortedCollection asArray]!   
addProcedure: aSelector
        " Define a new procedure call for this DLL. "
    ^self
        defineProcedure: aSelector
        entryPoint: (PARTSDLLEntryPoint forMessage: aSelector)!
constructErrorMessageDictionary
        " Private - construct the dictionary mapping
        Btrieve error codes to message strings. "

    | howToIncreaseFilesPrefix howToSetOptionsPrefix
       messageOptionsLocation messageHowToIncreaseFiles
       messageHowToSetOptions messageHowToSetPageSize
       messageRemoveTransactionControlFile |

    " construct platform-dependent phrases "
    howToIncreaseFilesPrefix :=
        'To increase the number of open files allowed, add ''/F: 255'' in '.
    howToSetOptionsPrefix :=
        'The following line must be in '.
    self
        partsIfOS2Do: [
            messageOptionsLocation :=
                'BTRPARMS environment variable'.
            messageHowToIncreaseFiles :=
                howToIncreaseFilesPrefix,
                'the BTRPARMS line of your CONFIG.SYS file.'.
            messageHowToSetOptions :=
                howToSetOptionsPrefix,
                'your CONFIG.SYS file: SET BTRPARMS=/M:64 /P:4096'.
            messageHowToSetPageSize :=
                'In your CONFIG.SYS file, look for errors where specifying the ''/P:'' parameter on the BTRPARMS line .'.
            messageRemoveTransactionControlFile :=
                'Remove the /T: parameter from the BTRPARMS in your CONFIG.SYS file.'.
            ]
        partsIfWindowsDo: [
            messageOptionsLocation :=
                'options line of the [btrieve] section in your WIN.INI file'.
            messageHowToIncreaseFiles :=
                howToIncreaseFilesPrefix,
                'the ', messageOptionsLocation, '.'.
            messageHowToSetOptions :=
                howToSetOptionsPrefix,
                'the [btrieve] section of your WIN.INI file: options=/M:64 /P:4096'.
            messageHowToSetPageSize :=
                'In the [btrieve] section of your WIN.INI file, look for errors where specifying the ''/P:'' parameter on the options line .'.
            messageRemoveTransactionControlFile :=
                'Remove the /T: parameter from the [btrieve] section of your WIN.INI file.'.
            ].

    ^IdentityDictionary new
        at: 3 put: 'File Not Open';
        at: 4 put: 'Key value not found';
        at: 5 put: 'Duplicate key value';
        at: 6 put: 'Key undefined';
        at: 7 put: 'After changing the key, before sending either getNext or getPrevious, you must use another type of a get operation.';
        at: 8 put: 'No current position has been established.';
        at: 9 put: 'No more records';
        at: 11 put: 'Filename does not conform to file-naming conventions.';
        at: 12 put: 'Filename specified does not exist.';
        at: 18 put: 'Disk is full.';
        at: 19 put: 'Unrecoverable Error';
        at: 22 put: 'The record format in the data file is different from the record format in the part file.';
        at: 24 put: 'Invalid page size.  ', messageHowToSetOptions;
        at: 25 put: 'Unable to Create File.';
        at: 28 put: 'Invalid Record Length.  Record length must be less than page size minus 6 or greater than or equal to 4 bytes long.';
        at: 29 put: 'Invalid Key Field Length.  Key field length cannot exceed 255.';
        at: 30 put: 'Not a Btrieve File.';
        at: 80 put: 'Update or delete cannot be performed because the record was changed by another application since your application read the record.';
        at: 84 put: 'Record Locked';
        at: 86 put: 'Too many open Btrieve files.  ', messageHowToIncreaseFiles;
        at: 1003 put: 'The memory size parameter of your Btrieve configuration is too small.  ', messageHowToSetOptions;
        at: 1004 put: 'Incorrect Page Size Parameter.  ', messageHowToSetPageSize;
        at: 1008 put: 'Unknown parameter in the ', messageOptionsLocation, '.';
        at: 1009 put: 'Transaction control files not supported.  ',messageRemoveTransactionControlFile;
        at: 9997 put: 'Object too large for field.  Object will be truncated';
        at: 9998 put: 'Error in field access.';
        at: 9999 put: 'Invalid field format.  Field not set.';
        yourself! 
callingConvention
        " Answer the calling convention of this entry point. "
    ^callingConvention isNil
        ifTrue: [self class defaultCallingConvention]
        ifFalse: [callingConvention]! 
warning
        "Private - Display a Message box with a string
        explaining the Btrieve error number anInteger."

    MessageBox warning: (self exceptionString: statusCode)!   
itemSize: anInteger
        "Private - Set number of bytes in item to anInteger."
    
    super itemSize: anInteger.
    itemSize := anInteger.
    object := String new: itemSize.!
resetBufferAddress
        " Private - reset the pointer to nonSmalltalk memory. "
    nonSmalltalkBuffer := nil.
    topDataItem notNil
        ifTrue: [ topDataItem resetBufferAddress ].
    self cstructurePartList remove: self ifAbsent: [ nil ].!
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrString!
copyToNonSmalltalkBuffer
        "Private - Answer an ExternalAddress pointing to memory
        containing a copy of the receiver.  Use nonSmalltalkBuffer
        to keep a permanent buffer in nonSmalltalk memory for
         the life of the CStructrure Part.  Copy 'buffer' to this
        memory. "

    | oldBufferSize newBufferSize |

    nonSmalltalkBuffer isNil
        ifTrue: [
            self cstructurePartList add: self.
            ^nonSmalltalkBuffer := self copyToExternalAddress. ]
        ifFalse: [
            oldBufferSize := buffer size.
            self contents.
            newBufferSize := buffer size.
            oldBufferSize ~= newBufferSize
                ifTrue: [
                    nonSmalltalkBuffer free.
                    ^nonSmalltalkBuffer := self copyToExternalAddress ]
                ifFalse: [
                    ^nonSmalltalkBuffer
                        at: newBufferSize + 1 put: 0;        "buffer is a string"
                        replaceBytes: newBufferSize with: buffer ]]!  
modified
		"Private - The receiver's buffer contains new value."
    self updateUI! 
dllName
        " Answer the name of the DLL file. "
    ^dllName!  
flags

    ^flags!  
objectToRecord
        "Private - Store aBoolean encoded as $T or $F."
    self buffer at: dataOffset put: (object ifTrue: [$T] ifFalse: [$F] )!
duplicatesAllowed: aBoolean

    | ducplicatesDisllowed |
    ducplicatesDisllowed := (2 raisedTo: 16) rounded - 1
        bitXor: BtrDuplicatesAllowed.
    aBoolean
        ifTrue: [flags := flags | BtrDuplicatesAllowed]
        ifFalse: [flags := flags bitAnd: ducplicatesDisllowed]!  
contents
        "Private - Answer an OrderedCollection of Associations
         of elementary data items and objects
         representing their value."
    | answer |
    answer := OrderedCollection new.
    self subItems isEmpty
        ifTrue: [ "item is leaf"
            answer add:
                (Association key: self name value: self object)]
        ifFalse: [ "item is group"
            self subItems do: [ :item | answer addAll: item contents]].
    ^answer! 
COMMENT
"
PARTSExternalDataItem and its subclasses are private classes
which belong to the implementation of various data structure parts
(CStructure, BTrieveAccessor, etc.).
"!
contents
        "Private - Answer the string containing the record data,
        with information updated from the user."
    topDataItem computeOffsets: 1.
    topDataItem objectToRecord.    
    ^self buffer!  
dataTypesDictionary
        " Private - answer the mapping dictionary from visual part
        part classes to Btrieve data item type classes. "

    DataTypes isNil
        ifTrue: [ DataTypes := self constructDataTypesDictionary ].
    ^DataTypes!   
addSubItem: item
		"Private - "
    item isVariableLength
        ifTrue: [self appendSubItem: item]
        ifFalse: [self prependSubItem: item]!
currentKey
		"Private - Answer aKey which is a PARTSBtrieveKey and is the key 
		used for getXXX operations."
    ^currentKey! 
objectToRecord
        "Private - Place an integer representation of the object in
        in the buffer."
    | bytes buffer |
    buffer := self buffer.

    itemSize == 2 "PARTSShort"
        ifTrue: [
            (bytes := object asInteger truncated) < 0
                ifTrue: [ bytes := bytes + (2 raisedTo: itemSize * 8) asInteger ].
            buffer at: dataOffset put: (bytes bitAnd: 255) asCharacter.
            ^buffer at: dataOffset + 1 put: (bytes bitShift: -8) asCharacter ].
    object class == SmallInteger
        ifTrue: [buffer
            replaceFrom: dataOffset
            to: dataOffset + 3
            with: (ExternalLong fromInteger: object) asParameter]
        ifFalse: [buffer "Large*Integer"
            replaceFrom: dataOffset
            to: dataOffset + object size - 1
            with: object]!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: self fieldAccessLafEvents! 
appendSubItem: item
        "Private - Add item to the subItems of the reciever."
    "Calculate the dataOffset."
    | anOffset |
    anOffset := (self subItems isEmpty
        ifTrue: [self dataOffset]
        ifFalse: [self subItems last dataOffset
                + self subItems last itemSize]).
    item dataOffset: anOffset.
    self subItems: (self subItems, (Array with: item)).
    item superItem: self.!  
itemSize
        "Private - Answer number of bytes in item."
    ^4!
fieldTypeSizes
    "Answer the size in bytes, or a descriptive string."

    ^Dictionary new
        at: PARTSShort  put: PARTSShort new itemSize;
        at: PARTSUShort put: PARTSUShort new itemSize;
        at: PARTSLong put: PARTSLong new itemSize;
        at: PARTSULong put: PARTSULong new itemSize;
        at: PARTSDoubleFloat put: PARTSDoubleFloat new itemSize;
        at: PARTSFixedLengthString put: 'Size is required';
        at: PARTSCPointer put: PARTSCPointer new itemSize;
        yourself.!   
allocateRecord
        "Private - Set data to a String of the correct size.
		For variable sized record choose the largest size so
		we can get all the data for the record in on API . "

    externalRecord topItem notNil 
		ifTrue: [
			externalRecord buffer:
        		(String new: (externalRecord isVariableLength 
					ifTrue: [	"Win32s thunking is valid only up to 32767"
						self partsIfOS2Do: [64000] partsIfWindowsDo: [32767]]
            		ifFalse: [externalRecord topItem itemSize]))].!  
access: aSelector arguments: args
        "Private - If args is empty, reading field, otherwise storing field."
    | value |

    [ value := externalRecord access: aSelector arguments: args ]
        on: Error do: [ :e |
            statusCode :=
                args isEmpty
                    ifTrue: [ 9998 "Error in field access" ]
                    ifFalse: [
                        ( PARTSInvalidExternalDataItemSize handles: e )
                            ifTrue: [ 9997 "Object too large for field" ]
                            ifFalse: [ 9999 "Invalid field format being passed" ]].
            self displayStatusCode.
            ^nil ].
    ^value! 
subItems: aCollection
        "Private - Set the subItems for the receiver to aCollection 
		converted to anArray."
    aCollection isEmpty
        ifTrue: [subItems := nil]
        ifFalse: [subItems := aCollection asArray]!
removeKey: aKey
        "Private - Remove aKey from the collection of keyFields
        and update currentKey as necessary."
    keyFields remove: aKey ifAbsent: [].
    currentKey == aKey
        ifTrue: [
            currentKey := (keyFields size = 0
                ifTrue: [nil]
                ifFalse: [keyFields first])]!  
value
        "Answer the CStruct itself which can be used as the 
		struct argument in a DLLAccessor call."
    ^self!
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrUnsignedBinary!
objectFromRecord
		"Private - Convert the external representation to Smalltlak objects."
    | offset |
    offset := dataOffset.
    self subItems do: [:i| i dataOffset: offset;
        objectFromRecord.
        offset := i dataOffset + i itemSize].! 
occurs: anObject
        "Private - Set the occurs data for receiver to anObject."
    occurs := anObject!  
new

    ^super new object: 0;
        itemSize: 4;
        yourself! 
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'FRMTTDDT.PAR'!   
objectToRecord16
		"Private - Convert the Smalltalk objects to the external
		representation."
    self subItems isEmpty ifTrue: [ ^self objectToRecord ].
    self subItems do: [:i| i objectToRecord16].!   
sizeInBytes
        "Private - Answer the size of a BtrieveKeySpec
           structure."
    ^16! 
new

    ^super new object: (Time fromSeconds: 0); yourself!
returnTypes
        " Answer the return value types supported for DLL calls "
    "^DynamicLinkLibrary returnTypes"
    ^#(#short #ushort #long #ulong #boolean #handle
            #reference " maps to ulong " #double #none)!  
object: aDate
		"Private -"
    object := aDate isString
        ifTrue: [aDate size = 0
            ifTrue: [nil]
            ifFalse: [Date fromString: aDate]]
        ifFalse: [aDate]! 
itemSize: anInteger
        "Private - Set number of bytes in item to anInteger."
    itemSize := anInteger.
    super itemSize: anInteger.!   
updateFromExternalAddress32: anExternalAddress
        "Private -The call is finished, and it may have changed the
        contents of the struct, so copy it back to the buffer and update
        the UI parts."
    self setFromReference32: anExternalAddress.!   
setEntryPointNameOf: aSelector to: aString
        " Set the entry point name of the procedure named aSelector
        to aString. "

    | anEntryPoint |
    entryPointDict isNil
        ifTrue: [ ^nil ].
    anEntryPoint := entryPointDict at: aSelector asSymbol
        ifAbsent: [ ^nil ].
    anEntryPoint entryPointName: aString.
    ^aString! 
registerWorkbenchEventHandlers: aPartEditor
        " Private "

    aPartEditor
        when: #addedPart:
        send: #partAdded: to: self.!  
removeSessionEventHandlers
        " Private - remove the session event handlers for the
        Data Access parts runtime library
            PARTSBtrieveAccessorPart removeSessionEventHandlers
        "

    SessionModel current isRunTime
        ifFalse: [
            SessionModel current
				removeActionsWithReceiver: self
				forEvent: #startup ].
	SessionModel current
		removeActionsWithReceiver: self
		forEvent: #shutdown.!   
startUp
        " Private "

    self btrCallsLibrary: nil.!   
keyFlag: flag

    self shortAtOffset: 4 put: flag! 
create: aFileName
		"Private - Create a btrieve file called aFileName.
		This method will be used when attempting to open
		a non-existing file."
    | fileSpec fileFlags dataBuffer |

    fileFlags := externalRecord isVariableLength
        ifTrue: [BtrVariableLength]
        ifFalse: [0].
    fileSpec := PARTSBtrieveFileSpec new
        recordLenght: externalRecord recordSize;
        pageSize: 4096;
        indexCount: keyFields size;
        fileFlags: fileFlags;
        preAlloc:0.
    dataBuffer := fileSpec asParameter.
    keyFields do: [:key|
        dataBuffer := dataBuffer, key asParameter.].
    statusCode := self
        btrvOperation: BtrCreate
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  aFileName asParameter
        keyLen: 255
        keyNum: BtrOverWrite.
    "create does not display status,
    because it is not sent directly by a link."
    ^statusCode!
dataItemClassFor: aVisualPart
        "Private - Answer the Btrieve data item class appropriate for
        the visual control <aVisualPart>."

    ^Smalltalk at: ( self dataTypesDictionary at: aVisualPart class symbol ifAbsent: [ ^nil ] )!  
isVariableLength
		"Private - "
    ^true!  
fileName
        "Private - Answer the file name of the dll."
    ^FileName!
fieldTypeNames

    ^(Array new: 7)
        at: 1 put: 'short';
        at: 2 put: 'ushort';
        at: 3 put: 'long';
        at: 4 put: 'ulong';
        at: 5 put: 'double float';
        at: 6 put: 'array of char';
        at: 7 put: 'reference';
        yourself.!   
superItem
        "Private - Answer the superItem for the receiver."
    ^superItem!
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrFloat! 
buffer: aString
        "Private - Set the string containing the record data."
    buffer := aString.!  
fileName: aString

    fileName := aString! 
dataItemsDo: aBlock
		"Private - Evaluate the OneArgumentBlock for each field."
    aBlock value: self.
    self subItems do:
        [:each |
        each dataItemsDo: aBlock]!
call: aSelector arguments: arguments ifError: aOneArgBlock
        "Call the entry point associated with aSelector
        with the given arguments (an array of values).
        The DLL must already be open.  Evaluate
        aOneArgBlock with the error message
        if the call fails. "
    | anEntryPoint realArguments result argument realArg needsToBeFreed |

    anEntryPoint := self entryPointFor: aSelector.
    anEntryPoint isNil
        ifTrue: [^aOneArgBlock value:
            'Unknown procedure ', aSelector asString].

    "If object responds to #copyToExternalAddress, it needs
    to be copied to non Smalltalk memory. If the entry point is
    16 bit, it needs to be converted to a segmented address.
    'String' should not be used as an argument if it is returned
    from the DLL because we cannot determine when to free
    the memory.  The memory for a  'String' arg is always
    freed before returning."

    realArguments := ( (arguments size = 0)
        ifTrue: [ #() ]
        ifFalse: [ arguments collect: [ :arg |
            (arg respondsTo: #copyToExternalAddress )
                ifTrue: [   " move structure arg to host memory "
                    arg isString
                        ifTrue: [ needsToBeFreed isNil
                                        ifTrue: [ needsToBeFreed := OrderedCollection new ].
                                     anEntryPoint is16Bit
                                        ifTrue: [ (needsToBeFreed add: arg copyToExternalAddress)
                                                     asSegmentedAddress ]
                                        ifFalse: [ needsToBeFreed add: arg copyToExternalAddress ] ]
                        ifFalse: [ anEntryPoint is16Bit
                                            ifTrue: [
                                                (( arg respondsTo: #copyToNonSmalltalkBuffer16 )
                                                    ifTrue: [ arg copyToNonSmalltalkBuffer16 ]
                                                    ifFalse: [ arg copyToNonSmalltalkBuffer ] ) asSegmentedAddress ]
                                               ifFalse: [ arg copyToNonSmalltalkBuffer  ] ] ]
                ifFalse: [arg] ]
            ] ).

    [ result := anEntryPoint
        call: dllHandle
        arguments: ( realArguments collect: [ :arg | arg asParameter ] ) ]
        on: APICallError
        do: [ :anException |
             ( anException isKindOf: APICallEntryPointNotFound )
                ifTrue: [
                    "exception dll name is Parts specific and entry
                        point is null term.  Correct these."
                    anException
                        setDLL: dllName
                        entryPoint: anEntryPoint entryPointName ].
            aOneArgBlock value: anException messageText ].
    result key
        ifFalse: [^aOneArgBlock value: result value].

    1 to: realArguments size do: [ :i |
        argument := arguments at: i.
        (argument respondsTo: #updateFromExternalAddress:)
            ifTrue: [   " retrieve structure parm from host memory "
                realArg := realArguments at: i.
                anEntryPoint is16Bit
                    ifTrue: [
                        argument updateFromExternalAddress: realArg asFlatAddress ]
                    ifFalse: [
                        argument updateFromExternalAddress32: realArg  ] ].
            ].

    needsToBeFreed notNil
        ifTrue: [ needsToBeFreed do: [ :aString | aString free ] ].

    ^result value!  
fieldNames
        "Private - Answer an OrderedCollection of field names"
    | answer |
    answer := OrderedCollection new.
    self subItems isEmpty
        ifTrue: [ "item is leaf"
            answer add: self name]
        ifFalse: [ "item is group"
            subItems do: [ :item |answer addAll: item fieldNames]].
    ^answer!  
updateUI16
		"Private - After a call is made, trigger all the field events
		to update the user interface."
    | fieldName |
    topDataItem objectFromRecord16.
    self fieldAccessLafEvents do: [ :event |
        fieldName := event copyFrom: 1 to: (event size - 1).
        accessorWidget triggerEvent: event
            with: (self fieldNamed: fieldName) object ].!  
accessorPart: aPart
		"Private - "
    accessorWidget := aPart.!
insert
		"Insert the a record based on the value in the receiver."
    | dataBuffer |
    currentKey isNil
        ifTrue: [^MessageBox warning: 'Insert operation requires a key, but no key exists.'].
    dataBuffer := externalRecord contents.
    keyBuffer := self keyValue: currentKey.
    statusCode := self
        btrvOperation: BtrInsert
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: externalRecord topItem itemSize) asParameter
        keyBuf:  keyBuffer
        keyLen: 255
        keyNum: (keyFields indexOf: currentKey) - 1.
    self displayStatusCode.
    ^statusCode!
keyLen: len

    self shortAtOffset: 2 put: len!
objectFromRecord
        "Private - Answer a Boolean value."
    ^object := (self buffer at: dataOffset) == $T! 
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'FRMTTDFT.PAR'!   
objectFromRecord
        "Private - Answer an Integer from data at dataOffset."
    | total |
    super objectFromRecord.
    total:= 0.
    4 to: 1 by: -1 do: [:i|
        total := (total * 256) + (object at: i)].
    ^object := total!   
objectToRecord
        "Private - Store object into the buffer in object filer format."
    | stream |

    CursorManager execute changeFor:
        [
            stream := ReadWriteStream on: String new.
            ObjectFiler dump: object on: stream.
        self buffer
            replaceFrom: dataOffset
                to: dataOffset + stream size - 1
            with: stream contents.
        self itemSize: stream size.  "Will recalculate dataOffsets"
        ].!
installPartRuntimeLibrary
        " Private - install the Data Access parts runtime library.
        Load the workbench support library if appropriate. "

	self 
		initializeRuntimeData;
		initializeSessionEventHandlers.
    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Data Access Parts'.!   
contents16
        "Private - Answer the string containing the record data,
        with information updated from the user."
    topDataItem computeOffsets: 1.
    topDataItem objectToRecord16.    
    ^self buffer!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
    copy
        partWrapper: (wrapper partMirrorCopy: aMirrorCopyDictionary);
        eventTable: (eventTable partMirrorCopy: aMirrorCopyDictionary);
        accessorPart: (accessorWidget partMirrorCopy: aMirrorCopyDictionary);
        "Do not copy the buffer."
        topItem: (topDataItem partMirrorCopy: aMirrorCopyDictionary).
    ^copy!   
preAlloc: alloc

    self shortAtOffset: 14 put: alloc! 
copyToExternalAddress16
        "Private - Answer a a host ExternalAddress, a pointer,
        to memory containing a copy of self.
        Return a FLAT address."

    ^ExternalAddress copyToNonSmalltalkMemory: self contents16! 
openOn: aFileName
        "Open aFileName.  A btrieve file must be opened
        before it can be used.  If aFileName does not exist,
        create and empty one."
    | dataBuffer |

    BtrCallsLibrary isNil
        ifTrue: [
            ( OperatingSystem isWindows95 or: [ OperatingSystem isWindowsNT ])
                ifTrue: [
                    [ BtrCallsLibrary := PARTSBtrieveDLL open ]
                        on: Error
                        do: [ :e |
                            ^MessageBox warning:
'The Btrieve provided with this product runs on Microsoft Windows 3.x platforms, but does not run on Windows 95 or Windows NT.  We will support these platforms in a maintenance release when that support is available from the vendor.' ]]
                ifFalse: [
                    BtrCallsLibrary := PARTSBtrieveDLL open ].

            BtrCallsLibrary isDynamicLinkLibrary
                ifFalse: [  "= 2 if open fails"
                    BtrCallsLibrary := nil.
                    ^MessageBox warning: 'Cannot open ', PARTSBtrieveDLL fileName, '.DLL' ].
                   ].

    aFileName size = 0
        ifTrue: [^MessageBox warning: 'Filename missing.'].
    positionBlock notNil "positionBlock is notNil only when it is open."
        ifTrue: [^MessageBox warning: 'The Btrieve part already has an opened file.']
        ifFalse: [self initPositionBlock].
    externalRecord buffer isNil ifTrue: [self allocateRecord].
    dataBuffer := externalRecord buffer.

    statusCode := self
        btrvOperation: BtrOpen
        positionBlock: positionBlock
        dataBuf: dataBuffer
        dataLen: (ExternalLong fromInteger: dataBuffer size) asParameter
        keyBuf:  aFileName asParameter
        keyLen: 255
        keyNum: 1.
    "Create the file if it does not exist."
    statusCode == 12 "file not found"
        ifTrue: [
            statusCode := self create: aFileName.
            positionBlock := nil.     "#create: does not leave the file opened."
            statusCode == 0
                ifTrue: [^self openOn: aFileName]].
    statusCode ~= 0 ifTrue: [positionBlock := nil].        "open failed."
    self displayStatusCode.
    ^statusCode
!
keyFields
		"Private - Answer an OrderedCollection of PARTSBtrieveKey. "
    ^keyFields!
close
        "Free the receiver module."
    
    [ super close ]
        on: Error
        do: [ :e |
            self class clearCachedAddresses.
            self == self class currentOrNil ifTrue: [ self class current: nil ]]! 
dllHandle
         "Private - answer a handle for this DLL"
    ^self dllHandleIfError: [ :errorCode |
        self
            triggerEvent: #openException:
            withArguments: (Array with: errorCode)
            ifNotHandled: [MessageBox
                notify: 'DLL Open Failed'
                withText: 'Unable to open DLL file ', dllName, '.'].
        ^nil ]!
object: aSmalltalkObject
		"Private - Set the Smalltalk object which is meant to be
		converted to the external form."
    object := aSmalltalkObject! 
setVisualPartAttributes: visualPart
        "Private - during auto form generation give each item
        a chance to set any desired properties."! 
itemSize
        "Private - Answer number of bytes in item."
    ^itemSize! 
getGreaterOrEqual
		"Find the first record whose current key field is greater or equal than
		the current key field of the receiver.  If a match is found,
		trigger all the field event values, otherwise trigger #endOfFileException.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer := self keyValue: currentKey.
    ^self getOperation: BtrGetGreaterOrEqual.!  
PARTSBtrieveAccessorPart removePartRuntimeLibrary!
object: aTime
		"Private - "
    object := aTime isString
        ifTrue: [Time fromString: aTime]
        ifFalse: [aTime]!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    positionBlock := nil.
    ^super partMirrorCopyReal: aMirrorCopyDictionary! 
removeSubItem: anItem
        "Private -"
    self externalRecord removeSubItem: anItem.
    "In case it is a key, make sure it is taken out."
    anItem notNil
        ifTrue: [
            self removeKey: (self keyFromName: anItem name)].!   
fileFlags: flags

    self shortAtOffset: 10 put: flags!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>, dropping the DLL handle.
        Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
    copy
        partWrapper: (wrapper partMirrorCopy: aMirrorCopyDictionary);
        eventTable: (eventTable partMirrorCopy: aMirrorCopyDictionary);
        dllName: dllName copy.
    entryPointDict notNil
        ifTrue: [
            copy entryPointDict:
                (entryPointDict partMirrorCopy: aMirrorCopyDictionary) ].
    ^copy!
objectToRecord
        "Private - Place object padded/truncated to itemSize bytes
         into data at dataOffset."
    | copyIndex fieldSize |
    fieldSize := self itemSize.
    copyIndex := dataOffset + (object size min: fieldSize).
    self buffer
        replaceFrom: dataOffset
            to: copyIndex - 1
            with: object;
        replaceFrom: copyIndex
            to: dataOffset - 1 + fieldSize
            withObject: 0 asCharacter! 
itemSize
        "Private - Answer the number of bytes required
        to represent the object in the specific external format."
    ^4!  
keyType: type

    self byteAtOffset: 10 put: type! 
superItem: aExternalDataItem
        "Private - Set the superItem for the receiver to aExternalDataItem."
    superItem:= aExternalDataItem!
sessionShutdown
        " Private - perform the session #shutdown processing
        for the Data Access parts runtime library. "

    PARTSCStructurePart shutdown.
    PARTSBtrieveAccessorPart shutdown.! 
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrDate!  
prototypeApiCallMethod
        " Private - answer a prototype api call method. "
    ^(Smalltalk at: PlatformLibrary) class compiledMethodAt: #beep:for:!   
isVariableLength
        "Private - Answer true if there is any isVariableLength
        field in the record, and false otherwise."
    ^topDataItem notNil
        and: [topDataItem isVariableLength]!  
externalRecord: aRecord
		"Private - Set aRecord which is a String and is used to 
		store the data argument of the Btrieve API call."
    externalRecord := aRecord.
    externalRecord accessorPart: self.! 
object: aString
        "Private - Set object to aString and make sure
        it is zero terminated."
    object := aString!  
entryPointName: aString
        " Specify the entry point name. "
    entryPointName := aString!
partMessages
        " Answer the PARTS message interface of the receiver. "
    | standardInterface |
    standardInterface := PARTSInterfaceList new
            items: #( #open #close ).
    ^standardInterface
        concatenateSeparated:
            ( PARTSInterfaceList new items: self procedureNames )
        defaultItem: #open!   
object: aString
        "Private - Set the Smalltalk object representing
        the external data item."
    object := aString isString
        ifTrue: [aString]
        ifFalse: [aString printString].

    "Truncate and raise error if object is too large.
        If itemSize not set (nil), object can be any size"
    ( itemSize notNil and: [ object size > itemSize ])
        ifTrue: [
            object := object copyFrom: 1 to: itemSize.
            PARTSInvalidExternalDataItemSize signal ].!  
partEventsStatic
		"Private - Answer the events which every instance of
		the receiver has."
    ^#(#exception: #endOfFileException)!  
entryPointFor: aSelector
        " Answer the procedure definition of message aSelector. "
    entryPointDict isNil ifTrue: [^nil].
    ^entryPointDict at: aSelector ifAbsent: [nil]! 
new

    ^super new object: true; yourself! 
buffer
        "Private - Answer the string containing the record data."
    buffer isNil ifTrue: [accessorWidget allocateRecord].
    ^buffer!
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self fieldAccessMessages includes: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [ super partLinkClassFor: aSelector ]!   
topItem: anExternalDataItem
        "Private - Set the topmost anExternalDataItem
         of the receiver."
    topDataItem := anExternalDataItem.
    topDataItem isNil
        ifFalse:
            [topDataItem
                superItem: self;    
                dataOffset: 1].! 
sessionStartUp
        " Private - perform the session #startUp processing
        for the Data Access parts runtime library. "

    PARTSCStructurePart startUp.
    PARTSBtrieveAccessorPart startUp.! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #openException: #callException:arguments: )
        defaultItem: #openException:!  
btrvOperation: op
    positionBlock: pos
    dataBuf: data
    dataLen: dataLen
    keyBuf: key
    keyLen: keyLen
    keyNum: keyNum
        " Invoke a Btrieve operation "
    <pascal16: BTRCALL short struct struct struct struct ushort ushort short>
    ^self invalidArgument!
dataItemKnownFor: aVisualPart
        "Private - Answer whether Btrieve data item class appropriate for
        the visual control <aVisualPart>."

    ^self dataTypesDictionary includesKey: aVisualPart class symbol!  
isUniqueKey: aDataItem
		"Private - "
    keyFields do: [ :key |
        ( key externalDataItem == aDataItem  and: [ key duplicatesAllowed ])
            ifTrue: [^true]].
    ^false!  
objectToRecord
        "Private - Write the object of class Time into the buffer
        in Btrieve Time format: hundredths of seconds, seconds
        minutes and hours."
    | buffer |
    buffer := self buffer.
    buffer at: dataOffset + 1 put: object seconds asCharacter.
    buffer at: dataOffset + 2 put: object minutes asCharacter.
    buffer at: dataOffset + 3 put: object hours asCharacter.! 
getEqual
		"Find a record whose current key field has the same
		value as the current key field of the receiver.  If a match is found,
		trigger all the field event values, otherwise trigger #endOfFileException.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer := self keyValue: currentKey.
    ^self getOperation: BtrGetEqual.!   
duplicatesAllowed

    ^(flags bitAnd: BtrDuplicatesAllowed) = BtrDuplicatesAllowed!
copyForReal
        "Private - Make a backup copy to be used for property cancel."
    | dict |
    dict := PARTSMirrorCopyDictionary new: 127.
    dict at: self partWrapper put: nil.
    ^self partMirrorCopyReal: dict.! 
access: aSelector arguments: args
        "Private - Perform the dynamic PARTS message aSelector
        which either gets or set the field value.  The get selector
        is simply the name of the field <name>.  The set message has a
        prefix of 'set' on the field name and a colon at the end
        set<name>:"
    | fieldName |
    fieldName := aSelector asString upTo: $:.
    ^(aSelector asString last == $:)
        ifTrue: [
            fieldName := fieldName copyFrom: 4 to: fieldName size.
            (self fieldNamed: fieldName)
                object: (args at: 1).
            (args at: 1)]
        ifFalse: [^(self fieldNamed: fieldName)
                object]!   
btrieveKeyType
        "Private - Answer the btrieve extended key type."
    ^BtrInteger!   
addSubItem: item
		"Private - Add item which is an instance of a subclass of 
		PARTSExternalDataItem."
    topDataItem isNil
        ifTrue: [self topItem: PARTSExternalDataItem new].
    item isVariableLength
        ifTrue: [topDataItem appendSubItem: item]
        ifFalse: [topDataItem addFixedLengthSubItem: item]!   
itemSize
		"Private - Answer number of bytes in item."
    ^4!  
updateUI
		"Private - After a call is made, trigger all the field events
		to update the user interface."
    | fieldName |
    topDataItem objectFromRecord.
    self fieldAccessLafEvents do: [ :event |
        fieldName := event copyFrom: 1 to: (event size - 1).
        accessorWidget triggerEvent: event
            with: (self fieldNamed: fieldName) object ].!  
partRealSelectorFor: aSelector
        "Answer the message to send for an alias link
        to access a field of the current record. "
    ^( self fieldAccessMessages includes: aSelector )
        ifTrue: [ #access:arguments: ]
        ifFalse: [ aSelector ]! 
externalRecord
		"Private -"
    ^self! 
computeOffsets: newOffset
		"Private - using newOffset for the receiver, recompute
		the offsets for all the following fields taking care of any
		ripple."
    | subItemOffset |
    subItemOffset := self dataOffset: newOffset.
    self subItems do: [:i| i computeOffsets: subItemOffset.
        subItemOffset := i dataOffset + i itemSize]!
keyValue: aKey
		"Private - Answer the current value for aKey."
    aKey externalDataItem objectToRecord.
    ^(externalRecord buffer copyFrom: aKey position
        to: aKey position + aKey length - 1) asParameter!   
getFirst
		"Find the first record using an asending order of the current key field.  
		Trigger all the field event values.  If the file is empty trigger #endOfFileException.
		Answer an Integer which is the status code returned by the Btrieve API call."
    keyBuffer := self keyValue: currentKey.
    ^self getOperation: BtrGetFirst.! 
objectToRecord
        "Private - Generate a pointer to the object and place in the pointer.
         pmAddress should contain a pointer to this object in nonSmalltalk
        memory until a new object is copied."

    
    object isNil
        ifTrue: [^self error: name , ' pointer has not been initialized.'].
    pmAddress notNil
        ifTrue: [ pmAddress free ].

    pmAddress := object copyToExternalAddress.
    self buffer
        replaceFrom: dataOffset
        to: dataOffset + 3
        with: pmAddress asParameter!  
visualPartExtent: anExtent
		"Private -"
    visualPartExtent := anExtent!  
contents: aString
        "Private - Set the data of the record to aString and
        update the user interface components."
    self buffer: aString.
    self updateUI.!   
objectFromRecord
        "Private - Answer a Date based on the value in the buffer."
    | buffer day month year |
    buffer := self buffer.
    day := (buffer at: dataOffset) asInteger.
    month := (buffer at: dataOffset + 1) asInteger.
    year := ((buffer at: dataOffset+ 3) asInteger * 256)
            + (buffer at: dataOffset + 2) asInteger.
    object := (day < 1 or: [month < 1])
        ifTrue: [nil]
        ifFalse: [Date
            newDay: day
            month: (Date nameOfMonth: month)
            year: year].
    ^object!   
itemSize
        "Private - Answer the byteSize of the item"
    ^self subItems isEmpty
        ifTrue: [0]
        ifFalse: [(subItems last dataOffset + subItems last itemSize)
            - dataOffset ]!
fieldTypes

    ^Dictionary new
        at: 'Two Byte Boolean' put: PARTSBtrieveBoolean;
        at: 'Fixed Length Byte Array' put: PARTSUnsignedBinary;
        at: 'Four Byte Signed Integer' put: PARTSLong;
        at: 'Two Byte Signed Integer' put: PARTSShort;
        at: 'Double Precision IEEE Float' put: PARTSDoubleFloat;
        at: 'Fixed Length String' put: PARTSFixedLengthString;
        at: 'Variable Length ZString' put: PARTSZString;
        at: 'Date' put: PARTSBtrieveDate;
        at: 'Time' put: PARTSBtrieveTime;
        at: 'Any Object' put: PARTSBtrieveObject;
        yourself.! 
callingConventions
        " Answer the supported calling conventions. "
    ^#( 'pascal' 'c' 'pascal16' 'c16' )!   
defaultVisualPartName
        "Private - Answer the part file name for the visual part
        to be generated for this data item."
    ^'ENTRYFLD.PAR'!   
isKey: aDataItem
		"Private - "
    keyFields do: [:key| key externalDataItem == aDataItem
        ifTrue: [^true]].
    ^false!  
open
		"Open the default file.  A btrieve file must be opened 
		before it can be used.  If aFileName does not exist,
		create and empty one."
    self openOn: fileName! 
itemSize
        "Private - Answer number of bytes in item to anInteger."
    ^itemSize!