3.1.0.106
   
localMachine
        "Answer a new instance of the receiver
         corresponding to the HKEY_LOCAL_MACHINE
         predefined key."
    ^super new
        keyName: RegKeyHandle localMachineId!  
oleServers
        "Answer a collection of keys of OLE servers"
    | regdb servers |
    regdb := self classesRoot.
    servers := OrderedCollection new.
    regdb keysDo: [:key |
        ( regdb includesKey: key, '\protocol\StdFileEditing\server' )
            ifTrue: [ servers add: key ] ].
    ^servers!  
performanceData
        "Answer a new instance of the receiver
         corresponding to the HKEY_PERFORMANCE_DATA
         predefined key."
    ^super new
        keyName: RegKeyHandle performanceDataId! 
new
        "Answer a new instance of the receiver
         corresponding to the HKEY_CLASSES_ROOT
         predefined key."
    ^self classesRoot!   
new: aString
        "Answer a new instance of the receiver which spans out from
         the hierarchy node named aString, in the CLASSES_ROOT
         subtree; aString can be a full hierarchical specification,
         such as:
            ( RegistrationDatabase new: 'Package\protocol\StdFileEditing\verb\0' ) value "
    ^self new
        at: aString!
oleServerAssocs
        "Answer a collection of associations between OLE server keys and
         their descriptive names; if the value field is empty, use the key name
         as the value also"
    | regdb |
    regdb := self classesRoot.
    ^regdb associationsSelect: [:a |
        regdb includesKey: a key, '\protocol\StdFileEditing\server']!   
printHierarchy
        "Answer a String containing a hierarchical representation of
         the complete RegDB hierarchy"
    | stream |
    stream := String new asStream.
    self printHierarchyOn: stream.
    ^stream contents!   
new: aString in: aRootKey
        "Answer a new instance of the receiver which spans out from
         the hierarchy node named aString, from the specified root
         key; aString can be a full hierarchical specification."
    ^self new
        rootHandle: aRootKey;
        keyName: aString! 
classesRoot
        "Answer a new instance of the receiver
         corresponding to the HKEY_CLASSES_ROOT
         predefined key."
    ^super new
        keyName: RegKeyHandle classesRootId! 
oleServerNames
        "Answer a collection of keys of OLE server descriptive names;
         if the value field is empty, use the key name instead"
    | servers names value |
    servers := self oleServers.
    names := servers species new: servers size.
    servers do: [:key |
        ( value := ( self new: key ) value ) isNil
            ifTrue: [ value := key ].
        names add: value ].
    ^names!   
printHierarchyOn: aStream
        "Append a hierarchical representation of the complete
         RegDB hierarchy to aStream"
    self new printHierarchyOn: aStream!   
users
        "Answer a new instance of the receiver
         corresponding to the HKEY_USERS
         predefined key."
    ^super new
        keyName: RegKeyHandle usersId!
currentUser
        "Answer a new instance of the receiver
         corresponding to the HKEY_CURRENT_USER
         predefined key."
    ^super new
        keyName: RegKeyHandle currentUserId! 
fileName
        "Answer the receiver's file name."
     ^'advapi32.dll'!   
regEnumValue: hKey
    index: iValue
    value: lpszValue
    cbValue: lpcbValue
    reserved: lpdwReserved
    type: lpdwType
    data: lpbData
    cbData: lpcbData
        "Enumerate the values of the specified key."
    <api: RegEnumValueA ulong ulong struct ulong ulong ulong struct ulong long>
    ^self invalidArgument!   
regQueryValue: hKey name: nameString value: valueString cbValue: cbValue
        "Copy the value of the subkey of hKey named nameString in the RegDB
         into valueString; copy the length of the string (including NULL terminator)
         into cbValue"
    <api: RegQueryValueA ulong struct struct ulong long>
     ^self invalidArgument!
regQueryValueEx: hKey
    name: nameString
    reserved: mustBeZero
    type: type
    value: valueString
    cbValue: cbValue
        "Query the value of the specified key, and copy the value to
         the buffer."
    <api: RegQueryValueExA ulong struct ulong ulong struct ulong long>
     ^self invalidArgument! 
regOpenKey: hParentKey name: aString handle: hKey
        "Open the subkey named aString of hParentKey in the RegDB,
         and answer the key handle in hKey"
    <api: RegOpenKeyA ulong ulong struct long>
     ^self invalidArgument!   
regSetValue: hKey name: nameString type: typeInteger value: valueString cbValue: cbValue
        "Set the value of the subkey of hKey named nameString in the RegDB
         to valueString; typeInteger is ignored, since the type is always a String"
    <api: RegSetValueA ulong struct ulong struct ulong long>
     ^self invalidArgument!  
regDeleteKey: hParentKey name: aString
        "Delete the subkey named aString under hParentKey in the RegDB"
    <api: RegDeleteKeyA ulong struct long>
     ^self invalidArgument!  
regCreateKey: hParentKey name: aString handle: hKey
        "Create or open the subkey named aString under hParentKey
         in the RegDB"
    <api: RegCreateKeyA ulong struct struct long>
     ^self invalidArgument!
regEnumKey: hKey index: anInteger buffer: buffer cbBuffer: cbBuffer
        "Copy the name of the (N-1)th subkey of hKey in the RegDB
         into buffer"
    <api: RegEnumKeyA ulong ulong struct ulong long>
     ^self invalidArgument!  
regSetValueEx: hKey
    name: valueName
    reserved: mustBeZero
    type: typeInteger
    value: valueBuffer
    cbValue: cbValue
        "Set the value of the specified key."
    <api: RegSetValueExA ulong struct ulong ulong struct ulong long>
     ^self invalidArgument! 
regCloseKey: hKey
        "Close the RegDB key hKey"
    <api: RegCloseKey ulong long>
     ^self invalidArgument! 
localMachine
        "Private - answer an instance of the receiver class
         which corresponds to the HKEY_LOCAL_MACHINE
         predefined key"
    ^self fromInteger: HkeyLocalMachine!   
localMachineId
        "Private - answer the HKEY_LOCAL_MACHINE
         predefined key"
    ^HkeyLocalMachine!
open: keyName
        "Private - open the specified key name of HKEY_CLASSES_ROOT,
         and answer an instance of the receiver class which corresponds
         to the opened key"
    ^self open: keyName in: HkeyClassesRoot!   
performanceData
        "Private - answer an instance of the receiver class
         which corresponds to the HKEY_PERFORMANCE_DATA
         predefined key"
    ^self fromInteger: HkeyPerformanceData!  
create: keyName
        "Private - create the specified key name of HKEY_CLASSES_ROOT,
         and answer an instance of the receiver class which corresponds
         to the created key"
    ^self create: keyName in: HkeyClassesRoot!
delete: keyName from: hKey
        "Private - delete the specified keyName from its parent."
    | result |
    result := AdvApiDLL current
        regDeleteKey: hKey
        name: keyName.
    result ~= 0 ifTrue: [ ^nil ]! 
open: keyName in: hKey
        "Private - open the specified Registration Database
         key name in the specified open key handle, and
         answer a corresponding instance of RegKeyHandle.
         keyName may be either a String, or an Integer value
         specifying one of the predefined key values."
    | result hSubKey pVarKeyName varKeyName |
    hSubKey := self new.
    varKeyName := keyName isInteger
        ifTrue: [ ( ExternalLong fromInteger: keyName ) contents ]
        ifFalse: [ keyName ].
    pVarKeyName := ExternalAddress copyToNonSmalltalkMemory: varKeyName.

    result := AdvApiDLL current
        regOpenKey: hKey asParameter
        name: pVarKeyName asParameter
        handle: hSubKey asParameter.
    pVarKeyName free.
    result > 0 ifTrue: [ ^nil ].
    ^hSubKey!
performanceDataId
        "Private - answer the HKEY_PERFORMANCE_DATA
         predefined key"
    ^HkeyPerformanceData!   
decodeDword: aByteArray length: anInteger
        "Private - answer a Smalltalk Integer decoded
         from the given arguments"
    ^( ExternalLong usingBytes:
        ( aByteArray copyFrom: 1 to: anInteger ) ) asInteger!  
decodeSz: aByteArray length: anInteger
        "Private - answer a Smalltalk string decoded from the given
         arguments"
    ^( aByteArray copyFrom: 1 to: anInteger - 1 ) asString! 
classesRootId
        "Private - answer the HKEY_CLASSES_ROOT
         predefined key"
    ^HkeyClassesRoot!   
create: keyName in: hKey
        "Private - create the specified Registration Database
         key name in the specified open key handle, and
         answer a corresponding instance of RegKeyHandle."
    | result hSubKey |
    hSubKey := self new.
    result := AdvApiDLL current
        regCreateKey: hKey
        name: keyName
        handle: hSubKey.
    result > 0 ifTrue: [ ^nil ].
    ^hSubKey! 
currentUserId
        "Private - answer the HKEY_CURRENT_USER
         predefined key"
    ^HkeyCurrentUser!   
classesRoot
        "Private - answer an instance of the receiver class
         which corresponds to the HKEY_CLASSES_ROOT
         predefined key"
    ^self fromInteger: HkeyClassesRoot!  
delete: keyName
        "Private - delete the specified keyName from the
         HKEY_CLASSES_ROOT predefined handle."
    ^self delete: keyName from: HkeyClassesRoot!   
users
        "Private - answer an instance of the receiver class
         which corresponds to the HKEY_USERS
         predefined key"
    ^self fromInteger: HkeyUsers! 
conversions
        "Private - answer a Dictionary mapping between
         Registration Database type codes & their
         conversion selectors"
    ^Dictionary new
        at: RegDword put: #decodeDword:length: ;
        at: RegSz put: #decodeSz:length: ;
        yourself!  
currentUser
        "Private - answer an instance of the receiver class
         which corresponds to the HKEY_CURRENT_USER
         predefined key"
    ^self fromInteger: HkeyCurrentUser!  
decodeBytes: aByteArray length: length type: aTypeCode
        "Private - convert the data value specified by the parameters
         into an equivalent Smalltalk object."
    | selector |
    selector := self conversions
        at: aTypeCode
        ifAbsent: [ self error: 'Unsupported data type' ].
    ^self perform: selector with: aByteArray with: length!  
usersId
        "Private - answer the HKEY_USERS
         predefined key"
    ^HkeyUsers!  
open: subKeyName
        "Private - open the specified subkey of the receiver,
         and answer an instance of the receiver class which corresponds
         to the opened subkey"
    ^self class open: subKeyName in: self!  
create: keyName
        "Private - add a new subkey of the receiver
         with the specified name"
    ^self class create: keyName in: self!
enumKeys
        "Private - answer a collection of all the subkeys of the
         receiver."
    | buffer collection index |
    collection := OrderedCollection new.
    index := 0.
    [buffer := String new: 255.
    (AdvApiDLL current
        regEnumKey: self asParameter
        index: index
        buffer: buffer
        cbBuffer: buffer size) = 0]
        whileTrue: [
            collection add: buffer trimNullTerminator asNormalizedString.
            index := index + 1].
    ^collection!
enumValues
        "Private - enumerate the values of the receiver, and
         answer a collection of Smalltalk objects which are
         equivalent to the RegDB values."
    | result index value cbValue pcbValue type pType data cbData pcbData collection object |
    index := 0.
    collection := OrderedCollection new.
    [
        value := String new: 255.
        cbValue := ExternalLong fromInteger: value size.
        pcbValue := ExternalAddress copyToNonSmalltalkMemory: cbValue contents.
        type := ExternalLong new.
        pType := ExternalAddress copyToNonSmalltalkMemory: type contents.
        data := ByteArray new: 255.
        cbData := ExternalLong fromInteger: data size.
        pcbData := ExternalAddress copyToNonSmalltalkMemory: cbData contents.
        result := AdvApiDLL current
            regEnumValue: self
            index: index
            value: value
            cbValue: pcbValue asParameter
            reserved: 0
            type: pType asParameter
            data: data
            cbData: pcbData asParameter.
        result = 0 ] whileTrue: [
            cbValue := ( ExternalLong fromAddress: pcbValue ) asInteger.
            type := ( ExternalLong fromAddress: pType ) asInteger.
            cbData := ( ExternalLong fromAddress: pcbData ) asInteger.
            object := self class decodeBytes: data length: cbData type: type.
            collection add: ( Array with: (value trimNullTerminator asNormalizedString) with: object ).
            index := index + 1 ].
    ^collection!
close
        "Private - close the receiver's key"
    ( AdvApiDLL current regCloseKey: self ) ~= 0
        ifTrue: [ self error: 'error closing key' ]!   
value
        "Private - answer the value of the receiver key."
    | result cb cbAddr value |
    value := String new: 255.
    cb := ExternalLong fromInteger: value size.
    cbAddr := ExternalGlobalAddress copyToNonSmalltalkMemory: cb contents.
    result := AdvApiDLL current
        regQueryValue: self
        name: nil
        value: value
        cbValue: cbAddr asParameter.
    cb := ( ExternalLong atAddress: cbAddr ) asInteger.
    cbAddr free.
    result > 0 ifTrue: [ ^nil ].
    ^( value copyFrom: 1 to: cb - 1 ) asNormalizedString! 
value: anObject
        "Private - answer the value of the receiver key."
    | result |
    result := AdvApiDLL current
        regSetValueEx: self
        name: nil
        reserved: 0
        type: RegSz
        value: anObject
        cbValue: anObject size.
    result > 0 ifTrue: [ ^nil ]! 
delete: subKeyName
        "Private - delete the specified subkey name
         from the receiver"
    ^self class delete: subKeyName from: self!  
printOn: aStream
        "Answer a human readable String which is used to represent
         the receiver"
    aStream nextPutAll: self value printString! 
includesKey: aString
        "Answer true if the receiver contains a subkey named aString,
         otherwise answer false"
    | exists handle |
    self open.
    ( exists := ( handle := self keyHandle open: aString ) notNil )
        ifTrue: [ handle close ].
    self close.
    ^exists!   
keys
        "Answer a collection of keys of the receiver."
    | array |
    self open.
    array := self keyHandle enumKeys.
    self close.
    ^array!  
rootHandle: aRegKeyHandle
        "Private - set the root handle of the receiver to aRegKeyHandle."
    rootHandle := aRegKeyHandle!
publicKeys
        "Answer an Array of the subkeys of the receiver; Windows reserved
         keys are not included - use #keys if you want to include them"
    ^self keys reject: [:s | s first = $.]!   
at: aString ifAbsent: aBlock
        "Answer a new instance of the receiver class which spans
         out from the node named aString; if the key does not exist,
         evaluate aBlock"
    | subKeyName |
    subKeyName := self keyName isInteger
        ifTrue: [ aString ]
        ifFalse: [ self keyName, '\', aString ].
    ( self includesKey: aString ) ifFalse: [ ^aBlock value ].
    ^self class new: subKeyName in: self rootHandle! 
species
        "Answer the class which closely approximates the receiver class,
         for use in select:, reject:, etc."
    ^Dictionary!  
add: anAssociation
        "Add anAssociation to the receiver"
    self at: anAssociation key put: anAssociation value.
    ^anAssociation!
printHierarchyOn: aStream indent: aString
        "Append a hierarchical representation of the receiver to aStream,
         using aString as the initial indentation - each subsequent level will
         indent 3 more spaces"
    | sub value |
    self keysDo: [ :key |
        aStream nextPutAll: aString, key.
        sub := self at: key.
        ( value := sub value ) notNil ifTrue: [ aStream nextPutAll: ' - ', value ].
        aStream cr.
        sub printHierarchyOn: aStream indent: aString, '   ' ].!   
associationsSelect: aBlock
        "For each key/value pair in the receiver, evaluate
         aBlock with the association as the argument.
         Answer a new object containing those key/value pairs
         for which aBlock evaluates to true."
    | answer |
    answer := self species new.
    self associationsDo: [ :each |
        (aBlock value: each)
            ifTrue: [answer add: each]].
    ^answer!
errorAbsentKey
        "Private - Report an error message indicating that the
         key was not found"
    self error: 'Key is missing'!
keyHandle: aRegKeyHandle
        "Private - set the key handle to aHandle."
    keyHandle := aRegKeyHandle! 
keyHandle
        "Private - answer the key handle."
    ^keyHandle!
at: key put: value
        "Set the value of the node named key to value"
    self open.
    ( self keyHandle create: key )
        value: value;
        close.
    self close.
    ^value!   
associationsDo: aBlock
        "Answer the receiver.  For each key/value pair in the receiver,
         evaluate aBlock with that association as an argument"
    self keysDo: [ :key |
        aBlock value: ( Association key: key value: ( self at: key ) value ) ]!   
at: aString
        "Answer a new instance of the receiver class which spans
         out from the node named aString; make sure the key exists
         by trying to open the key"
    ^self at: aString ifAbsent: [ self errorAbsentKey ]!  
rootHandle
        "Private - answer the root handle of the receiver."
    ^rootHandle! 
keysDo: aBlock
        "Evaluate aBlock (a OneArgumentBlock) for each key in the receiver"
    self keys do: [:o | aBlock value: o]!
printHierarchyOn: aStream
        "Append a hierarchical representation of the receiver to aStream"
    self printHierarchyOn: aStream indent: ''!  
removeKey: aString
        "Remove the subkey named aString starting at the
         current node (named keyName)"
    self open.
    self keyHandle delete: aString.
    self close!
inspect
        "Open a DictionaryInspector on the receiver, since this class
         implements the basic Dictionary protocol"
    ( Smalltalk at: #DictionaryInspector ) new openOn: self!  
close
        "Close the receiver's key handle."
    self keyName isInteger ifFalse: [ self keyHandle close ]!  
keyName
        "Answer the hierarchical specification of the receiver"
    ^keyName!   
keyName: aString
        "Set the hierarchical specification of the receiver to aString"
    keyName := aString!
value
        "Answer the value of the current node; in Windows 3.1,
         this value is always a String."
    | value |
    self open.
    value := self keyHandle value.
    self close.
    ^value!  
value: aString
        "Set the value of the receiver node to aString; in
         Windows 3.1, the values are always Strings."
    self open.
    self keyHandle value: aString.
    self close!
values
        "Answer a collection of the values corresponding to all the
         keys of the receiver"
    ^self keys collect: [:k | ( self at: k ) value ]!
open
        "Open the receiver's key handle."
    self keyName isInteger
        ifTrue: [
            self rootHandle: self keyName.
            self keyHandle: ( RegKeyHandle fromInteger: self keyName ) ]
        ifFalse: [ self keyHandle: ( RegKeyHandle open: self keyName in: self rootHandle ) ]!