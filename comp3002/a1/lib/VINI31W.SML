3.1.0.106
   
section: sectionName
        "Private - answer an instance for the given section."
    ^self new section: sectionName!  
initializationFile: anInitializationFile section: sectionName ifAbsent: ignoredForNow
        "Private - answer an instance for the given file and section; evaluate the
        ignoredForNow block if the section does not exist."
    ^self new
        initializationFile: anInitializationFile;
        section: sectionName!   
section: sectionName ifAbsent: ignoredForNow
        "Private - answer an instance for the given section; evaluate the
        ignoredForNow block if the section does not exist."
    ^self new section: sectionName! 
at: keyName put: aString
        "Associate the value aString with the key keyName."
    self
        setValue: ( aString isNil ifTrue: [ String new ] ifFalse: [ aString ] ) "because nil will delete"
        forKey: keyName.
    ^aString!   
section
        "Private - answer the name of the section which the receiver corresponds to."
    ^section! 
section: sectionName
        "Private - set the name of the section which the receiver corresponds to to sectionName."
    section := sectionName!  
associations
		"Answer a collection of Associations for the receiver."
	^self keys collect: [ :key |
		Association key: key value: ( self getValue: key ) ]!   
at: keyName ifAbsent: aBlock
        "Answer the value (a String) associated with the key.
        If the key is not contained in the receiver, answer the result of
        evaluating the exceptionBlock."
    | value |
    ^( value := self getValue: keyName ) isNil
        ifTrue: [ aBlock value ]
        ifFalse: [ value ]! 
includesKey: key
        "Answer true if the receiver contains aKey, else answer false."
    ^self keys includes: key!  
inspect
        "Open a DictionaryInspector on the receiver, since this class
         implements the basic Dictionary protocol"
    ( Smalltalk at: #DictionaryInspector ) new openOn: self!  
getSection
        "Private - answer a buffer (String) containing the receiver's section
        (in host format)."
    self implementedBySubclass!
getValue: keyName
        "Private - answer the string value of the entry identified
        by keyName, or nil if none."
	^self initializationFile getDataForSection: self section key: keyName!  
errorWritingKey: key value: value
        "Private - Report an error to the effect that the specified value
        could not be written for the specified key."
    self error: 'Error writing value ', value printString, ' for key ', key printString!  
initializationFile: anInitializationFile
        "Private - set the initialization file the receiver belongs to to anInitializationFile."
    initializationFile := anInitializationFile!   
keys
        "Answer a collection of the keys in the receiver."
    | buffer |
	buffer := self initializationFile getDataForSection: self section key: nil.
	buffer := buffer asArrayOfSubstringsSeparatedBy: 0 asCharacter.
    ^buffer asSet!  
at: keyName
        "Answer the value (a String) of the key/value pair whose
        key equals keyName from the receiver.  If not found, report an error."
    ^self at: keyName ifAbsent: [ ^self errorAbsentKey: keyName ]
!   
errorAbsentKey: key
        "Private - Report an error to the effect that the desired key
        was not found in the receiver."
    self error: 'Key ', key printString, ' is missing'!  
initializationFile
        "Private - answer the initialization file the receiver belongs to."
    ^initializationFile! 
values
        "Answer a collection containing all the values of the
        key/value pairs in the receiver."
    ^self associations values!  
keysDo: aOneArgumentBlock
        "Answer the receiver.  For each key in the receiver, evaluate
        aBlock with the key as the argument."
    self keys do: aOneArgumentBlock! 
removeKey: keyName
        "Answer the receiver with the key/value pair whose
        key equals keyName removed.  If such a pair is not found,
        report an error."
    self setValue: nil forKey: keyName! 
setValue: aString forKey: keyName
        "Private - write the value aString to the receiver under the key keyName."
    | result |
    result := self initializationFile file isFile
        ifTrue: [
            KernelLibrary
                writePrivateProfileString: self section
                keyName: keyName
                string: aString
                file: self initializationFile file asFileSystemPath asString ]
        ifFalse: [
            KernelLibrary
                writeProfileString: self section
                keyName: keyName
                string: aString ].
    result ifFalse: [
        ^aString isNil
            ifTrue: [ self errorAbsentKey: keyName ]
            ifFalse: [ self errorWritingKey: keyName value: aString ] ].
    ^aString!   
close
		"Private - close the receiver. Ignored under Win32."!
isOpen
		"Private - answer whether the receiver is already opened.
		Always answer true under Win32."
	^true!  
system
        "Answer the instance of the receiver, which is associated with
        the system initialization file.  For OS/2, this is OS2.INI, for
        Win32, this is WIN.INI (mapped via the Registration Database)."
    ^self new!  
getSectionNames
        "Private - workaround to Win32s bug: if both section name and key name are NULL,
        no data retrieved (contrary to API specification, and Windows NT, Windows 95)."
    | aFile aFileStream names nextLine |
    aFile := self file isNil
        ifTrue: [ File fromPath: self class systemFileName ]
        ifFalse: [ file ].
    names := OrderedCollection new.
    aFileStream := aFile readStream.
    [ aFileStream atEnd ] whileFalse: [
        nextLine := aFileStream nextLine.
        ( nextLine notEmpty and: [ nextLine first = $[ ] )
            ifTrue: [ names add: ( nextLine copyFrom: 2 to: ( ( nextLine indexOf: $] ) - 1 ) ) ] ].
    aFileStream close.
    ^String fromArrayOfSubstrings: names separatedBy: 0 asCharacter!
getProfileSection: appName buffer: buffer size: bufferSize
    <api: GetProfileSectionA struct struct ulong ulongReturn>
    ^self invalidArgument! 
file: aFile
        "Answer a private initialization file for the specified file."
    ^self new file: aFile!   
systemFileName
        "Answer the full path name of the system initialization file."
    | systemDir length |
    systemDir := String new: 80.
    ( length := KernelLibrary getWindowsDirectory: systemDir length: systemDir size ) = 0
        ifTrue: [ ^self osError ].
    systemDir := systemDir copyFrom: 1 to: length.
    ^systemDir, '\win.ini'!
writeProfileString: appName keyName: keyName string: aString
    <api: WriteProfileStringA struct struct struct boolean>
    ^self invalidArgument! 
open
		"Private - open the receiver.  Ignored under Win32."! 
getDataForSection: sectionName key: keyName
        "Private - retrieve a buffer of data in host-specific format, for the
        given section and key.  If nil is passed for keyName, a buffer containing
        all key names (separated by nulls) in the given section is returned; if nil
        is passed for both keyName and sectionName, a buffer containing
        all section names (separated by nulls) is returned."
    | default bufferSize buffer result |
    "workaround to Win32s bug"
    ( sectionName isNil and: [ keyName isNil and: [ OperatingSystem isWin32s ] ] )
        ifTrue: [ ^self getSectionNames ].
    default := ''.
    bufferSize := 255.
    [ result isNil or: [ result = ( buffer size - 2 ) ] ] whileTrue: [
        buffer := String new: bufferSize.
        result := self file isFile
            ifFalse: [
                KernelLibrary
                    getProfileString: sectionName
                    keyName: keyName
                    default: default
                    returnedString: buffer
                    size: buffer size ]
            ifTrue: [
                KernelLibrary
                    getPrivateProfileString: sectionName
                    keyName: keyName
                    default: default
                    returnedString: buffer
                    size: buffer size
                    iniFileName: self file pathName ].
        bufferSize := bufferSize * 2 ].
    buffer := buffer copyFrom: 1 to: result.
    ^buffer! 
writePrivateProfileString: appName keyName: keyName string: aString file: fileName
    <api: WritePrivateProfileStringA struct struct struct struct boolean>
    ^self invalidArgument! 
getPrivateProfileSection: appName buffer: buffer size: bufferSize file: fileName
    <api: GetPrivateProfileSectionA struct struct ulong struct ulongReturn>
    ^self invalidArgument! 
handle
		"Private - answer the OS handle for the receiver."
	^handle!   
at: keyName put: ignored
        "the only way to create a section is to create an entry within a section,
        so create a dummy entry & then remove it from the new empty section."
    ( self at: keyName )
        at: 'dummy' put: 'dummy';
        removeKey: 'dummy'!  
at: sectionName ifAbsent: aBlock
        "Answer the value (a file section object) associated with the key.
        If the key is not contained in the receiver, answer the result of
        evaluating the exceptionBlock."
    ^self getSection: sectionName ifAbsent: aBlock! 
includesKey: key
        "Answer true if the receiver contains aKey, else answer false."
    ^self keys includes: key!  
file
        "Private - answer the file of the receiver."
    ^file!
inspect
        "Open a DictionaryInspector on the receiver, since this class
         implements the basic Dictionary protocol"
    ( Smalltalk at: #DictionaryInspector ) new openOn: self!  
keys
        "Answer a collection of the keys (section names) in the receiver."
    | buffer |
    buffer := self getDataForSection: nil key: nil.
    buffer := buffer asArrayOfSubstringsSeparatedBy: 0 asCharacter.
    ^buffer asSet!
at: sectionName
        "Answer the value (a file section object) of the key/value pair whose
        key equals keyName from the receiver.  If not found, report an error."
    ^self at: sectionName ifAbsent: [ self errorAbsentKey: sectionName ]! 
errorAbsentKey: key
        "Private - Report an error to the effect that the desired key (section)
        was not found in the receiver."
    self error: 'Section ', key printString, ' is missing'!
file: aFile
        "Private - set the file of the receiver to aFile; verify that the
        file exists before proceeding, signalling an error if not."
    ( aFile isFile and: [ aFile exists not ] ) ifTrue: [ ^aFile doesNotExist ].
    file := aFile!  
keysDo: aOneArgumentBlock
        "Answer the receiver.  For each key in the receiver, evaluate
        aBlock with the key as the argument."
    self keys do: aOneArgumentBlock! 
handle: aHandle
		"Private - set the OS handle for the receiver to aHandle."
	handle := aHandle!
removeKey: sectionName
        "Answer the receiver with the key/value pair whose
        key equals aKey removed.  If such a pair is not found,
        report an error."
    ( self at: sectionName ) at: nil put: nil! 
getSection: sectionName ifAbsent: aBlock
        "Private - create and answer a section object for the section
        named sectionName, evaluating aBlock if there is no such
        entry."
    ^InitializationFileSection initializationFile: self section: sectionName ifAbsent: aBlock!