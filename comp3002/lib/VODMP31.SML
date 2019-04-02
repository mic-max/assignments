3.1.0.106
   
currentVersionDescription
        " Answer the currrent version of the object file format. "
    ^self class currentVersionDescription! 
getFileNameToCreate
        " Private - answer the name of the file to create. "
    ^(FileDialog new saveFile: 'FiledObj.par') file!   
recordWarningMessage: aMessage
        " Notify the user that a non-fatal error has occurred."

    clientMessageHandler notNil
        ifTrue: [
            clientMessageHandler evaluateWithArguments: (Array
                with: self
                with: (Association key: 'warning' value: aMessage) ) ]
			ifFalse: [
    			feedback isNil ifTrue: [ self windowFeedback ].
    			self feedback: aMessage ]!   
dump: anObject on: aStream objectCountEstimate: anInteger

    objectStore root:
        (ObjectStoreRoot new root: anObject).
    clientAllocateDictionaryAction isNil
        ifTrue: [
            anInteger notNil ifTrue: [
                objectStore objects objectCountEstimate: anInteger ] ]
        ifFalse: [  "client supplied object dictionary for compatibility"
            objectStore objects objectsDictionary: clientAllocateDictionaryAction value ].

    self

        name: '';        "ComponentFile<<fileName: tries to get file extension"

        stream: aStream;
        go! 
dump: anObject on: aStream objectCountEstimate: anInteger
        " Store anObject on aStream, starting at the current position.
        Answer anObject (nil if the dump failed). "

    | answer |
    CursorManager execute changeFor: [
        answer := self new
            dump: anObject
            on: aStream
            objectCountEstimate: anInteger ].
    ^answer!
privateAdd: anObject
    "Private - Add anObject."

    | object |
    ( self includes: anObject ) ifTrue: [ ^self ].
    object := anObject.
    objects at: object put: ObjectStoreObject new.
    self maybeAdd: object "methodDictionaryArray" class methodDictionaries from: object.  "try
        to add object's method dict array as an import to the meta info which is used to
        identify the class of the object during load time.  Do not use
        methodDictionaryArray because it may be appended with instance method dictionary
        that has different class field."
    self traverse: object.
    self triggerEvent: #addedObject: with: object.! 
privateAddPrereq: anExternal for: anObject from: fromObject
    "Private - Add a prerequisite for anExternal."

    | froms libraryName |
    anObject isSymbol ifTrue: [ ^self ].
    libraryName := objectStore client libraryNameOf: anObject.
    libraryName isNil ifTrue: [ ^self ].
    prereqs == nil ifTrue: [ prereqs := Dictionary new ].
    froms := prereqs at: anExternal ifAbsent: [ nil ].
    froms == nil ifTrue: [
        prereqs at: anExternal put: ( froms := OrderedCollection new ).
        froms add: libraryName ].
    froms add: fromObject.!  
addImport: anObject from: fromObject
    "Private - Add anObject to the receiver's imports, if possible.
    Answer false if an import can not be created for anObject,
    true otherwise."

    | external original |
    anObject isObjectReference
        ifTrue: [
            anObject type =  'global'
                ifTrue: [   "Singular globals"
                    original := ObjectStoreExternal globalNameSpace at: anObject value asSymbol.
                    external := ObjectStoreExternal globalNamed: anObject value ]
                ifFalse: [ ^false ] ]  "other types are dumped as is which is
                                    currently resolved by the 'fileInActivate' in CompiledMethod.
                                    This can be optimized to use imports in the future."
        ifFalse: [
            original := anObject.
            external := self externalFor: anObject from: fromObject ].
    external == nil ifTrue: [ ^false ].
    self privateAddImport: external for: original.
    self privateAddPrereq: external for: original from: fromObject.
    ^true!  
createLogWindowLabelled: aString
        " Private - create a window with <aString> as its label.
        Answer the text pane to which information can be written. "

    ^( TextWindow new
        label: aString;
        openOn: '' )
            pane!
shapes
    "Private - Answer a description of the class shapes for the objects
    in the receiver and objects imported by the receiver."

    | classes shapes |
    classes := Set new.
    objects keysDo: [:object | object class isMetaClass ifFalse: [ classes add: object class ] ].
    "classes copy do: [:class | classes addAll: class allSuperclasses ]."
    shapes := Dictionary new.
    classes do: [:class |
        shapes at: class symbol asString put: (
            Dictionary new
                at: 'structure' put: class structure;
                at: 'allInstVarNames' put: class allInstVarNames;
                at: 'allClassInstVarNames' put: class class allInstVarNames;
                at: 'allClassVarNames' put: class allClassVarNames asArray;
                at: 'sharedPools' put: ( class sharedPools asArray collect: [:symbol | symbol asString ] );
                at: 'superclass' put: class superclass printString;
                yourself ) ].
    ^shapes!   
libraryNameOf: anObject
        " Private "

    | classToLookup libraryName |
    libraryMappings size > 0
        ifTrue: [
            classToLookup :=
                anObject isClass
                    ifTrue: [ anObject ]
                    ifFalse: [
                        ( anObject isArray
                        and: [ anObject notEmpty
                        and: [ anObject first isMethodDictionary
                        and: [ anObject last isMethodDictionary ] ] ] )
                            ifTrue: [ anObject first classField ]
                            ifFalse: [
                                anObject isMetaClass
                                    ifTrue: [ anObject instanceClass ]
                                    ifFalse: [ nil ] ] ].
            classToLookup notNil ifTrue: [
                libraryName := libraryMappings at: classToLookup ifAbsent: [ nil ] ]
            ].
    libraryName isNil
        ifTrue: [
            anObject libraryOrdinal = 1 ifTrue: [ ^nil ].    "don't bother for base objects."
            libraryName := anObject libraryName.
                " Since Assoc will be bound to the target system, we don't know what its
                    value is gonna be, thus it should not be a prerequisite."
            "( libraryName == nil and: [ anObject isAssociation ] )
                ifTrue: [
                    anObject value libraryOrdiSmalltalknal = 1 ifTrue: [ ^self ].
                    libraryName := SmalltalkLibraryBinder nameOf: anObject value libraryOrdinal ].
                "
            ].
    ^libraryName!  
externalFor: import from: fromObject
    "Private - Answer an external for the object import."

    import == true ifTrue: [ ^ObjectStoreExternal true ].
    import == false ifTrue: [ ^ObjectStoreExternal false ].
    import == FrameMarker ifTrue: [ ^ObjectStoreExternal markedFrame ].
    ( import isCharacter and: [ import isSingleByte ] ) ifTrue: [ ^ObjectStoreExternal character: import ].
    import isSymbol
        ifTrue: [ ^ObjectStoreExternal symbol: import ].
    ( import isArray and: [ import notEmpty and: [ import first isMethodDictionary ] ] )
        ifTrue: [ ^ObjectStoreFileExternal methodDictionaryArray: import ].
    ( import isAssociation and: [ self globalNames includesKey: import key ] )
        ifTrue: [ ^ObjectStoreExternal assoc: import ].
    import isMethodDictionary
        ifTrue: [ ^ObjectStoreExternal methodDictionary: import ].
    import isMetaClass
        ifTrue: [ ^ObjectStoreFileExternal metaClass: import ].
    import isClass
        ifTrue: [ ^ObjectStoreFileExternal class: import ].
    ( import isAssociation and: [ import key class == String and: [ fromObject isCompiledMethod ] ] )
        ifTrue: [ ^self classOrPoolVarExternal: import in: fromObject ].
    import isCompiledMethod
        ifTrue: [ ^ObjectStoreExternal compiledMethod: import ].
    ( self globalNames includes: import )
        ifTrue: [ ^ObjectStoreFileExternal global: import ].
    import isObjectReference
        ifTrue: [ ^import ].
    UnknownImport on: import.
	^ObjectStoreExternal nil!   
objectStore: anObjectStore
	"Private - Set a link to the ObjectStore."
	objectStore := anObjectStore!   
currentVersion
        " Answer the currrent version of the object file format. "

    ^self class currentVersion! 
dump: anObject on: aStream

	^self dump: anObject on: aStream objectCountEstimate: nil! 
libraryMappings: anIdentityDictionary
        " Register the library mapping dictionary to use
        for object dumping.  Entries map a class
        to a String containing the library name to
        associate with instances of that class stored in the
        filed object.  The library association is used during
        loading to attempt to locate the class if it is missing. "

    libraryMappings := anIdentityDictionary.!   
dumpAll: aCollection newFile: aPathName
        " Store each object in aCollection on the file
        specified by aPathName.
        Answer aCollection (nil if the dump failed). "

    | fileStream result |
    CursorManager execute changeFor: [
        fileStream := File newFile: aPathName.
        aCollection do: [ :anObject |
            result := self new dump: anObject on: fileStream.
            result isNil
                ifTrue: [ fileStream close. ^nil ].
            ].
        fileStream close ].
    ^aCollection!
objectsClass
	"Private - Answer the class that collects objects."

	^ObjectStoreFileObjects!   
include: anObject from: fromObject
    "Private - Answer true if anObject should be included in the receiver."
    anObject isSymbol ifTrue: [ ^false ].
    ( self fixedClassObject: anObject ) ifTrue: [ ^false ].
    anObject class isBytes ifTrue: [ ^true ].
    anObject isBehavior ifTrue: [ ^false ].
    anObject isObjectReference ifTrue: [ ^false ].  "Singular globals"
    "anObject isCompiledMethod ifTrue: [ ^false ]."  "it may be associated with HomeContext"
    ( anObject isArray and: [ anObject notEmpty and: [ anObject first isMethodDictionary and: [ anObject last isMethodDictionary ] ] ] ) ifTrue: [ ^false ].
    ^true!   
windowFeedback
    "Provide feedback in a text window."

    feedback := self class createLogWindowLabelled: 'Object Dump Messages'.!  
objectCountEstimate: anInteger
    "Provide an estimate of the number
    of objects that will be in the receiver,
    so that dictionaries can be initialized
    with an appropriate starting size to
    avoid growing and therefore speed
    up the building time."

    objectStore objects objectCountEstimate: anInteger! 
formatVersion
	"Private - Answer the format version string."

	^objectStore client currentVersion! 
fileClass
	"Private - Answer the class that writes the file."

	^ObjectStoreFileWithVersion!   
source
	"Private - In the future, this should return a ReadStream for
	puting out editing info."

	^nil!  
root
	"Private - Answer the root object."
    ^root!
libraryDependencies
        " Answer a collection containing the names of all non-base
        libraries which contain class definitions used by the
        object which was just dumped. "

    | aSet |
    aSet := Set new.
    ( objectStore metaInfo at: 'prereqs' ) do: [ :array |
        aSet addAll: array ].
    ^aSet!   
clientMessageHandler: aHandler
        " Register a client message handler.
        aHandler is a two-argument block or message
        which is invoked when a problem is
        encountered during object loading or dumping.
        The first argument is this ObjectFiler.
        The second argument is an assoc
        with key => value information:
            'info' => an information message (string)
            'warning' => a warning message (string)
            'abort' => a fatal error message (string)
            'summary' => number of warnings encountered
                (Dictionary of integers indexed by above key strings)
        The 'summary' notification is sent at operation
        completion when warnings were encountered
        (allows client to do sumary or termination processing). "
    clientMessageHandler := aHandler.!  
root: anObject
	"Private - Set the root object."
    root := anObject!  
currentVersionDescription
        " Answer the currrent version description of the object file format. "

   ^Smalltalk product, ' (', Smalltalk platform , ') ', Smalltalk versionNumberString, ' object file'!   
dump: anObject newFile: aPathName
        " Store anObject in the file specified by aPathName.
        Answer anObject (nil if the dump failed). "
    | fileStream result |
    CursorManager execute changeFor: [
        fileStream := File newFile: aPathName.
        " self setFileType: fileStream file."
        result := self dump: anObject on: fileStream.
        fileStream close ].
    ^result!  
maybeAdd: anObject from: fromObject
    "Private - Add anObject if it belongs."

    | object newObject |

    object := remaps at: anObject ifAbsent: [
        newObject := anObject fileOutSurrogate: objectStore client.
        anObject == newObject
            ifFalse: [
                "remaps at: newObject ifAbsent: [ newObject ] ]"  "not needed
                    assuming that fileOutSurrogate: does not return another
                    object that needs surrogate again; otherwise it may loop"
                ( newObject isObjectReference ) "singular globals and method's globals"
                    ifFalse: [ remaps at: anObject put: newObject ].
                        ].
            newObject
        ].

    "object := self remapFor: anObject."
    object == nil ifTrue: [ ^nil ].
    object isSmallInteger ifTrue: [ ^nil ].
    ( self include: object from: fromObject )
        ifTrue: [ self privateAdd: object ]
        ifFalse: [ ( self addImport: object from: fromObject )
            ifFalse: [ self privateAdd: object ] ].!
clientContext: anObject
        " Store anObject on behalf of the client.
        The client context can be accessed in
        fileOutSurrogate: and fileInActivate: methods
        to allow context-dependent behavior. "
    clientContext := anObject!  
dump: anObject
        " Prompt for a file and store anObject into it. "
    | aPathName |
    (aPathName := self getFileNameToCreate) isNil
        ifTrue: [^nil].
    ^self dump: anObject newFile: aPathName!
objectVersion
        " Answer the filed version of the object
        currently being dumped. "
    ^self currentVersion! 
initialize
	"Private"

    "self windowFeedback."
     objectStore := ObjectStoreWithClient new.

    objectStore client: self.
     counter := 0.
    objectStore objects: ( self objectsClass new objectStore: objectStore ).!  
stream: aStream
	"Private - Set up <aStream> as the output
	medium."

    | objectStoreFile |
    objectStoreFile :=  self fileClass new: objectStore.
    objectStoreFile setStream: 
		( self initializeForOperationOn: aStream ).
    objectStore file: objectStoreFile.!  
go
    "Private - Build the receiver."

    | file oldNameSpace |
    objectStore version: self currentVersionDescription.
    self add: self known.
    self feedback: 'Walking objects...'.
    oldNameSpace := ObjectStoreExternal globalNameSpace.
    ObjectStoreExternal globalNameSpace: Smalltalk.  "This is needed for fileOutSurrogates
        in Singular globals."
    objectStore objects go.
    ObjectStoreExternal globalNameSpace: oldNameSpace.
    objectStore root:
        ( objectStore objects remapFor: objectStore root ).
    file := objectStore file.
    file == nil ifTrue: [
        objectStore file: ( file := self fileClass new: objectStore ) ].
    file
        when: #objectWritten send: #objectWritten to: self;
        when: #metaSpaceWritten:bytes: send: #metaSpaceWritten:bytes: to: self;
        when: #objectSpaceWritten:bytes: send: #objectSpaceWritten:bytes: to: self.
    self feedback: 'Writing file: ', file directory, file fileName, ' ...'.
    file assignAddresses.
    file writeFile.
    self feedback: '...done' cr: true.!  
initializeForOperationOn: aStream
        " Private - initialize state for an operation on aStream. "
   ^ ( (aStream respondsTo: #asByteFileStream)
        ifTrue: [aStream asByteFileStream]
        ifFalse: [aStream] ).!
currentVersion
        " Answer the current version of the object file format "
	Version isNil
		ifTrue: [ "ObjectStore filer for objects 3.0 OS/2 (must be 8 chars)"
    		^ Version := 'CFO0300', (String with: ObjectStore platformLetter) ]
		ifFalse: [ ^ Version ]!
clientContext
        " Answer the client context associated with
        the current dump or load operation.
        Can be accessed in fileInSurrogate: and
         fileOutActivate: methods to provide
         context-dependent behavior. "
    ^clientContext!   
clientAllocateDictionaryAction: anAction
        " For compatibility - Register a zero-argument action which when evaluated
        answers an empty identity dictionary to use for an
        object dump operation. "
    clientAllocateDictionaryAction := anAction.!  
dump: anObject on: aStream
        " Store anObject on aStream, starting at the current position.
        Answer anObject (nil if the dump failed). "

    ^self dump: anObject on: aStream objectCountEstimate: 10000!