3.1.0.106
   
messageStream
        " Private - answer the stream on which messages are logged.
		Create if necessary. "
	
    feedback isNil ifTrue: [ self windowFeedback ].
	^feedback! 
client
	"Private"
	^client! 
standardLoadMapsFor: aVersion
        " Private - answer the standard load maps for loading
        an object filed out from aVersion into the current
        version. "

    ^self standardLoadMapsDictionary at: aVersion ifAbsent: [ #() ]!  
warningLoadCancelled
        " Answer the warning message prefix used
        in all warning messages about a load
        operation being cancelled by the user."
    ^'Object loading cancelled'!   
versionCanBeLoaded: aVersion
        " Answer whether a filed object from aVersion
        can be loaded by this ObjectFiler. "

    ^self supportedVersions includes: aVersion!  
loadAllFromPathName: aPathName loadMaps: loadMaps
        "  Answer a collection containing all the objects
        stored in the file specified by aPathName. The
        loadMaps collection defines mappings for loading
        classes whose shape has changed. "

    | fileStream objects |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        fileStream := File pathNameReadOnly: aPathName.
        objects := OrderedCollection new.
        [ fileStream atEnd ] whileFalse: [
            objects add:
                (self new loadFrom: fileStream loadMaps: loadMaps).
            fileStream nextULong ].
        fileStream close ].
    ^objects!   
loadFromPathName: aPathName
        " Answer the first object stored in the file
        specified by aPathName. "
    ^self loadFromPathName: aPathName loadMaps: #()!
clientContext
        " Answer the client context associated with
        the current dump or load operation.
        Can be accessed in fileInSurrogate: and
         fileOutActivate: methods to provide
         context-dependent behavior. "
    ^clientContext!   
feedback: aString
    "Private - Provide feedback."

    " For compatibility with old library builder:." aString isString ifFalse: [ ^feedback := aString ].

    self feedback: aString cr: true.!  
resolveMethodDictionaryArrayPrompt
        "Private - Resolve the receiver."

    | classToLoad |
    value = 'HomeContext'  "signal there is a HomeContext"
        ifTrue: [ self class resolveClient remappedObjects: IdentityDictionary new ].
    classToLoad := self validateClassAndShape: value.
    ^ classToLoad isBehavior
        ifTrue: [ classToLoad methodDictionaries ]
        ifFalse: [ self ]!  
promptForClass: className
    "Private - prompt the user for a missing class."

    | changeMaps aClass newClassName aLibraryName userCancelled |

   changeMaps := self class resolveClient actualChangeMaps.
    aClass := changeMaps at: className ifAbsent: [ nil ].
    aClass notNil
        ifTrue: [ ^ aClass ].   "the same class already prompted"

    newClassName := className.
    [ aClass isClass ]
        whileFalse: [
            SessionModel current isRunTime
                ifTrue: [
                    aLibraryName := Prompter
                        title: 'Missing class ', className
                        prompt: 'Enter library name to bind:  (Cancel to abort)'
                        default: 'unknown', SmalltalkLibrary fileExtension asLowerCase.
                    userCancelled := aLibraryName isNil.
                    aLibraryName size > 0
                        ifTrue: [
                            self bindLibrary: aLibraryName
                                toFind: newClassName ].
                        ]
                ifFalse: [
                    newClassName := Prompter
                        title: 'Missing class ', className
                        prompt: 'Enter new class name:   (Cancel to abort)'
                        default: newClassName.
                    userCancelled := newClassName isNil ].
            userCancelled
                ifTrue: [
                    self recordAbortMessage:
                        self class resolveClient warningLoadCancelled,   "[10/9/95 MT]"
                        ' - class ', className, ' not found in this system.'.
                    ^nil ].
            aClass := self class getClass: newClassName asSymbol ifAbsent: [ ^ nil ]. "[10/9/95 MT]"
            ].
    changeMaps at: className put: aClass.
    ^aClass!  
getMeta
    "Private - Read the meta info from the stream."

    | metaMeta meta |

    metaMeta := self getMetaMeta.
    meta := self readSpace.
    meta := self addObjects: meta externals: metaMeta.
    meta associationsDo: [:a | objectStore metaInfo add: a ].
    "self triggerEvent: #metaInfoAvailable."
    ^objectStore metaInfo!  
describeClassesFromPathName: srcPathName newFile: dstPathName
        " Describe the classes in the filed object in the
        file specified by srcPathName on file dstPathName. "

    | srcFileStream dstFileStream |
    ( File exists: srcPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        srcFileStream := File pathNameReadOnly: srcPathName.
        dstFileStream := File newFile: dstPathName.
        self new describeClassesFrom: srcFileStream to: dstFileStream.
        srcFileStream close.
        dstFileStream close ].!  
recordAbortMessage: message
	"Private - Ask the client to record an abort message."
	self class resolveClient recordAbortMessage: message!  
clientContext: anObject
        " Store anObject on behalf of the client.
        The client context can be accessed in
        fileOutSurrogate: and fileInActivate: methods
        to allow context-dependent behavior. "
    clientContext := anObject!  
currentVersion: aFileVersion
        " Private - set the current version of the object file format "

    Version := aFileVersion.!
upgradeFromPreviousVersion: objectArray
        " Private - an object is being loaded which was
        stored by a previous version of the system.
        Allow objects to upgrade themselves into the
        form expected by the current system. "

    | lastObjectId transformations loadedObject upgradedObject |


        "    Moved this here to synch with where ObjectFiler
        does rehashing, at the start of an upgrade cycle."
    self restoreLoadedHashStructures: objectArray.

    lastObjectId := objectArray size.
    transformations := IdentityDictionary new.

    1 to: lastObjectId do: [ :objectId |
        loadedObject := objectArray at: objectId.
        upgradedObject := loadedObject fileInUpgrade: self.
        upgradedObject ~~ loadedObject
            ifTrue: [
                transformations at: loadedObject put: upgradedObject.
                objectArray at: objectId put: upgradedObject ].
        ].

    operationAborted ifTrue: [ ^nil ].

    self triggerEvent: #upgraded.

    self resetObjectsAfterMutationCycle: transformations
        objectArray: objectArray.!  
resolveWithPrompt
        "Private - Resolve the receiver. Prompt for
        undefined globals."
    | resolvedValue |
    type = 0 ifTrue: [ ^value ].  "Already done."
    resolvedValue := self perform: ( #(
        #resolveSymbol
        #resolveAssoc
        #resolveGlobalPrompt
        #resolveMetaClassPrompt
        #resolveMethodDictionary
        #resolveMetaMethodDictionary
        #resolveExpression
        #resolveClassVariable
        #resolveMethodDictionaryArrayPrompt
        #resolveMetaMethodDictionaryArray
        #resolveCreateIt
        #resolvePoolVariable
        #resolveCommonByteArray
        #resolveNil
        #resolveTrue
        #resolveFalse
        #resolveMarkedFrame
        #resolveCharacter
        #resolveMethod )
            at: type).
    ( resolvedValue == self ) ifTrue: [ ^self ].
    type := 0.
    value := resolvedValue.
    ^value!  
useBindingInformation
        " Answer whether component binding information
        for resolving missing classes should be used
        during loading. "

    ^useBindingInformation! 
remapLoadedObjects: objectArray
    " Private - remap objects due to class or class shape changes. "

    | firstObjectId lastObjectId loadedObject changeMap
      newObject class subObject |

    (actualChangeMaps size = 0) ifTrue: [^self].  "no remaps"
    firstObjectId := 1.
    lastObjectId := objectArray size.

    " fix references to any objects which changed their class or class shapes "

	firstObjectId to: lastObjectId do: [ :objectId |
		loadedObject := objectArray at: objectId.
		class := loadedObject class.
		(class isPointers) ifTrue: [
			1 to: (class instSize + loadedObject basicSize) do: [ :i |
				subObject := loadedObject instVarAt: i.
				subObject isBehavior ifFalse: [  "Behavior guys are alread resolved"
					changeMap := actualChangeMaps at: subObject class ifAbsent: [nil].
					changeMap notNil ifTrue: [
						newObject := self mutate: subObject with: changeMap.
						subObject become: newObject.
                			remappedObjects notNil ifTrue: [ "there is home context"
                    			remappedObjects at: newObject put: changeMap ].
					 ] ].

			 "changeMap := 
					subObject isMetaClass 
						ifTrue: [actualChangeMaps at: subObject instanceClass ifAbsent: [nil] ]
						ifFalse: [ subObject isClass
							ifTrue: [ actualChangeMaps at: subObject ifAbsent: [nil] ]
							ifFalse: [ actualChangeMaps at: subObject class ifAbsent: [nil] ]].
                changeMap notNil ifTrue: [
                    newObject := self mutate: subObject with: changeMap.
					subObject isClass
						ifTrue: [ loadedObject instVarAt: i put: newObject ]
						ifFalse: [ subObject become: newObject ]."

				]]].!  
validateGlobal: globalName classOnly: classOnlyBoolean
    "Private - Check if requested global or class is present.
    Remaps will be consulted."

    | client newGlobal remap |

    client := self class resolveClient.
    newGlobal := self class getClass: globalName asSymbol ifAbsent: [ nil ].
    newGlobal notNil
        ifTrue: [
            client objectChangeMaps size = 0
                ifTrue: [ ^newGlobal ]
                ifFalse: [ remap := client objectChangeMaps at: globalName ifAbsent: [ ^newGlobal ]]
            ]
        ifFalse: [ remap := client objectChangeMaps at: globalName ifAbsent: [ nil ] ].

    "NOTE: class instance variables change is not currently tested.  A block in
    a class method can potentially reference a class inst var which can break
    due to changes in these variables."

    remap notNil ifTrue: [ "The class (can't be global var) is remapped"
            "no need to check class shape"
            ^ self class
                getClass: remap destinationClassName asSymbol
                ifAbsent: [
                    self recordAbortMessage:
                        self warningLoadCancelled,
                        ' - class ', remap destinationClassName, ' not found in this system',
                        ' (specified by load map as new class of filed ',
                        globalName, ' instances).'.
                    ^nil ].
            ].
    "class or global var missing in the new image"
    ^classOnlyBoolean
            ifTrue: [ self promptForClass: globalName ]
            ifFalse: [ self promptForGlobal: globalName ].! 
promptForGlobal: globalName
    "Private - Prompt the user for a missing global or class."

    | changeMaps aGlobal newGlobalName aLibraryName userCancelled |

    changeMaps := self class resolveClient actualChangeMaps.
    aGlobal := changeMaps at: globalName ifAbsent: [ nil ].
    aGlobal notNil
        ifTrue: [ ^ aGlobal ].   "the same global already prompted (e.g. class & meta class)"

    newGlobalName := globalName.
    [ aGlobal isNil ]
        whileTrue: [
            SessionModel current isRunTime
                ifTrue: [
                    aLibraryName := Prompter
                        title: 'Missing class or global - ', globalName
                        prompt: 'Enter library name to bind:  (Cancel to abort)'
                        default: 'unknown', SmalltalkLibrary fileExtension asLowerCase.
                    userCancelled := aLibraryName isNil.
                    aLibraryName size > 0
                        ifTrue: [
                            self bindLibrary: aLibraryName
                                toFind: globalName ].
                        ]
                ifFalse: [
                    newGlobalName := Prompter
                        title: 'Missing class or global - ', globalName
                        prompt: 'Enter new name:   (Cancel to abort)'
                        default: newGlobalName.
                    userCancelled := newGlobalName isNil ].
            userCancelled
                ifTrue: [
                    self recordAbortMessage:
                        self warningLoadCancelled,
                        ' - class or global named ', globalName, ' not found in this system.'.
                    ^nil ].
            aGlobal := self class getClass: newGlobalName asSymbol ifAbsent: [ nil ].
            ].
    changeMaps at: globalName put: aGlobal.
    ^aGlobal!   
getObjects
    "Private - Read the objects from the stream."

    | space numberOfObjects objectArray |

    numberOfObjects :=  objectStore metaInfo at: 'objectCount'.
    numberOfObjects = 0 ifTrue: [ ^nil ].
    space := self readSpace.

    objectArray := Array new: numberOfObjects.
    self addObjects: space
        externals: ( objectStore metaInfo at: 'imports' )
        objects: objectArray.

    self remapLoadedObjects: objectArray.

    self isLoadingCurrentVersion
        ifFalse: [ self upgradeFromPreviousVersion: objectArray ].
    self restoreLoadedObjects: objectArray.
    operationAborted ifTrue: [ ^nil ].

    objectStore objects: objectArray.
    objectStore root: ( objectArray at: 1 ).

    self triggerEvent: #loaded.
    ^objectStore root!
version
        " Answer current version stamp for the object file format.
        Obsolete - retained for compatibility. "

    ^self currentVersion!
currentVersion
        " Answer the current version of the object file format "

	^ Version!   
removeAllChangeMapsForClass: aClassName
        " Remove any ObjectChangeMap registered for loading
        instances of <aClassName> from any version. "

    self supportedVersions do: [ :aFiledObjectVersion |
        self
            removeChangeMapForClass: aClassName
            forVersion: aFiledObjectVersion ].!
check
    "Private - Check for duplicates, class shapes, etc."

    "self checkDuplicates; checkShapes."!  
resolveExternals
    "Private - Find external references."

    | externals import external |
    remappedObjects := nil.    "this guy is used by HomeContext to decide
        whether its container's class shape change is acceptable.  It will be
        set to an IdentityDictionary if externals includes a HomeContext"

    externals := objectStore metaInfo at: 'imports'.
    1 to: externals size do: [:i |
        external := externals at: i.
        external == nil ifFalse: [
			( external class == ObjectStoreFileExternal )
				ifTrue: [ import := external resolveWithPrompt ] "remap is done here"
				ifFalse: [ import := external resolve ].  
            import == external ifTrue: [
                "UnresolvedExternal binder: self external: import"
            	self recordAbortMessage: external printString, ' is not resolved'.
            	^nil ].
            self uses: import library.
			externals at: i put: import ] ].
    actualChangeMaps size = 0
        ifTrue: [ remappedObjects := nil ].   "no remapping, therefore
            homeContext is not a problem"
    self triggerEvent: #externalsResolved.! 
dummyClassName: newName
    subclassOf: superclass
    instanceVariableNames: instVarNames
    structure: aStructure

    "Private - Create a dummy class so that its instances can
    be loaded.  They will be transformed to real class
    instances later on."

    | meta answer aSymbol |
    meta := MetaClass subclassOf: Object.
    answer := meta new.
    answer superclass: superclass.
    meta superclass: superclass class.
    answer initializeClass.
    aSymbol := newName asSymbol.
    meta newNameSymbol: aSymbol.
    answer newNameSymbol: aSymbol;
        structure: aStructure;
        setInstVarNames: instVarNames.
    meta instanceClass: answer.
    ^answer! 
restoreLoadedHashStructures: objectArray
        " Private - restore hashed objects when there
        is a platform/version difference between the
        dumping system and this loading image. "

        "ObjectLoader has been built for the specific use by
        the Workbench.  However, it almost has all the
        general functionality of the ObjectFiler.

        ObjectFiler logic has been reworked, needs
        to be installed here in appropriate form.
        Note additional event triggering of #rehashed
        which needs to be supported. "

    ^self!  
remappedObjects: aDict
	"Private - Set the remap dictionary."
    remappedObjects := aDict! 
standardLoadMapsDictionary: aDictionary
        " Private - set the dictionary with the standard
        load maps list, keyed by filed object version. "

    StandardLoadMaps := aDictionary.!  
describeClassesFrom: srcStream to: dstStream
        " Describe the classes in the filed object on
        srcStream in a text report on dstStream. "

	[ self describeMetaFrom: srcStream to: dstStream.
	] ifCurtailed: [
		self recordAbortMessage: 'non-recoverable error occurred'.
		self recordSummaryMessage: 'component classes description'.
		].
	self recordSummaryMessage: 'component classes description'.!
getFileNameToOpen
        " Private - answer the name of the file to open. "
    ^(FileDialog new openFile) file!   
describeAllFromPathName: srcPathName newFile: dstPathName
        " Describe the contents of all filed objects in the
        file specified by srcPathName on file dstPathName;
        answer the number of filed objects. "

    | srcFileStream dstFileStream numFiledObjects |
    ( File exists: srcPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        srcFileStream := File pathNameReadOnly: srcPathName.
        dstFileStream := File newFile: dstPathName.
        numFiledObjects := 0.
        [ srcFileStream atEnd ] whileFalse: [
            numFiledObjects := numFiledObjects + 1.
            (numFiledObjects > 1) ifTrue: [
                dstFileStream nextPutAll: '------------------------------'; cr; nextPut: Ff].
            self new describeFrom: srcFileStream to: dstFileStream.
            srcFileStream nextULong ].  "skip end of object mark"
        srcFileStream close.
        dstFileStream close ].
    ^numFiledObjects!  
validateClassAndShape: className
    "Private - Check if requested class is present and if its shape is the same.
    If not, update remappedObjects and answer a temp class so that
    the object can be loaded.  If yes, answer the class."

    | client shapeDict newClass loadedClass remap |

    client := self class resolveClient.
    shapeDict := ( client metaShapes ) at: className ifAbsent: [ ^nil ].
    newClass := self class getClass: className asSymbol ifAbsent: [ nil ].
    ( client objectChangeMaps size > 0 )
        ifTrue: [ remap := client objectChangeMaps at: className ifAbsent: [ nil ] ].

    ( newClass notNil
    and: [ remap isNil
    and: [ self isShapeOk: shapeDict with: newClass ] ] )
        ifTrue: [ ^newClass ].   "normal case"

    remap isNil
        ifTrue: [
            newClass isNil ifTrue: [ "class missing in the new image"
                ( newClass := self promptForClass: className ) isNil
                    ifTrue: [ ^nil ]].  "aborted"
            ]
        ifFalse: [    "check if remap class is ok"
            newClass := self class
                getClass: remap destinationClassName asSymbol
                ifAbsent: [
                    self recordAbortMessage:
                        self warningLoadCancelled,
                        ' - class ', remap destinationClassName, ' not found in this system',
                        ' (specified by load map as new class of filed ',
                        className, ' instances).'.
                    ^nil ].
            "check variables"
            ( self
                loadMapIsValid: remap
                sourceVariables: ( shapeDict at: 'allInstVarNames' )
                destinationVariables: newClass allInstVarNames )
                    ifFalse: [  " invalid mapping "
                        self recordAbortMessage:
                        self warningLoadCancelled,
                             ' - load map supplied for class ',
                             className, ' does not conform to real class shape.'.
                        ^nil ].
			"check if change map actually causes a real change"
			remap layoutIsChanging
				ifFalse: [ ^newClass ]. "no change"
            ].

    loadedClass := self makeTempClass: className shape: shapeDict.

    " check for class type mismatch "
    ( self isClass: loadedClass compatibleWith: newClass )
        ifFalse: [ ^nil ].

    remap isNil ifTrue: [
        remap := self remap: className shape: shapeDict to: newClass ].
    client actualChangeMaps at: loadedClass put: remap.
    ^loadedClass!   
remap: oldClassName shape: shapeDict to: newClass
    "Private - Remap the <oldClassName> with <shapeDict> to
    the shape of <newClass>."

    | startMap loadDescription aChangeMap |
    startMap := ObjectChangeMap new
        sourceClassName: oldClassName;
        destinationClassName: newClass name;
        sourceVariables: ( shapeDict at: 'allInstVarNames' );
        destinationVariables: ( newClass allInstVarNames );
        yourself.
    loadDescription := 'Loading class ', oldClassName.
    newClass name ~= oldClassName
        ifTrue: [ loadDescription := loadDescription, ' into ', newClass name ].
    aChangeMap := ObjectLoadDialog new
        openOn: startMap
        sourceTitle: 'Filed:'
        destinationTitle: 'Loading:'
        description: loadDescription.
    aChangeMap isNil
        ifTrue: [  " user cancelled "
              self recordAbortMessage:
                  'Instance variable remapping for loaded class (',
                     oldClassName, ') cancelled.'.
              ^ startMap ].   "not abort"
    ^ aChangeMap! 
recordWarningMessage: message
	"Private - Ask the client to record a warning message."
	self class resolveClient recordWarningMessage: message! 
loadMapIsValid: aChangeMap
    sourceVariables: sourceVariables
    destinationVariables: destinationVariables
        " Private - answer whether aChangeMap is valid. "

    aChangeMap destinationVariables isNil
        ifTrue: [
            aChangeMap destinationVariables: destinationVariables ]
        ifFalse: [
            aChangeMap destinationVariables = destinationVariables
                ifFalse: [^false] ].
    aChangeMap sourceVariables isNil
        ifTrue: [
            aChangeMap sourceVariables: sourceVariables.
            ^true ]
        ifFalse: [
            ( (aChangeMap sourceVariables ~= sourceVariables)
            and: [sourceVariables = destinationVariables] )
                ifTrue: [  " source matches destination, load quietly "
                    aChangeMap sourceVariables: sourceVariables.
                    ^true].
            ^(aChangeMap sourceVariables = sourceVariables) ].!   
supportedVersions
        " Private - answer the versions which can be loaded. "

    ^SupportedVersions!  
loadMapsDictFrom: loadMaps
        " Private - answer the loadMaps as a dictionary
        indexed by the source class name.   For compatibility,
        convert old map representation which used a
        dictionary whose key is the filed class name and value
        is an assoc whose key is the name of the class into
        which to load the filed instances and whose
        value is a collection of assoc's defining the instance
        variable mappings.  The key of an inst var map assoc
        is the name of the instance variable to be loaded
        and the value is the name of the filed inst var to
        load into its slot in the restored object.  An inst var
        is loaded with nil if there is no mapping for it. "
    | allLoadMaps loadMapsDict |

    allLoadMaps := OrderedCollection new.
    allLoadMaps
        addAll: (self class standardLoadMapsFor: objectVersion);
    	addAll: loadMaps.

    loadMapsDict := Dictionary new.
    allLoadMaps do: [ :aChangeMap |
        loadMapsDict
            at: aChangeMap sourceClassName
            put: aChangeMap deepCopy].
    ^loadMapsDict! 
describe
        " Describe the contents of a filed object.
        Prompt the user for the file name containing the filed object. "

    | aPathName |
    ( aPathName := self getFileNameToOpen ) isNil
        ifTrue: [ ^nil ].
	^self describeObjectInPathName: aPathName!
describeClasses
        " Describe the classes of a filed object.
        Prompt the user for the file name containing the filed object. "

    | aPathName |
    ( aPathName := self getFileNameToOpen ) isNil
        ifTrue: [ ^nil ].
    ^ self describeClassesInPathName: aPathName! 
initializePlatformVersion
        " Private - set the platform identification
        and the current version. "

    Platform := nil.
    OperatingSystem isOS2
        ifTrue: [
            Platform := #PM.
            ].
    OperatingSystem isWin32
        ifTrue: [
            Platform := #WIN.
            ].
    "product = 'Smalltalk/V for Macintosh'
        ifTrue: [
            Platform := #MAC.
            ]."
    Platform isNil
        ifTrue: [ self error: 'Unknown Smalltalk/V system' ].

    self currentVersion: 'CFO0300', (String with: ObjectStore platformLetter).
    self supportedVersions: self constructSupportedVersions.!  
loadAllFromPathName: aPathName
        "  Answer a collection containing all the objects stored
        in the file specified by aPathName. "
    ^self loadAllFromPathName: aPathName loadMaps: #()!  
formatVersion: aString
	"Private - Set the formatVersion of the receiver."

	client objectVersion: aString.
	^super formatVersion: aString!   
isShapeOk: shapeDict with: aClass
	"Private - answer true if the shape from <shapeDict>
	is the same as the one for aClass."
    ^ ( ( shapeDict at: 'structure' ) = aClass structure )
        and: [ ( shapeDict at: 'allInstVarNames' ) = aClass allInstVarNames ]!
bind: aLibraryFileName toFindClass: anObject
        " Private - attempt to bind the library named
        <aLibraryFileName> to find the class
        <aClassName>.  Answer whether the bind succeeded.
        (Which doesn't necessarily mean it contained the
        the desired class). "

    self recordInfoMessage:
        'Attempting to bind component ', aLibraryFileName,
        ' to locate ', anObject printString .
    [ SmalltalkLibraryBinder bindTo: aLibraryFileName ]
        on: FileError, BindError
        do: [ :e |
            self recordInfoMessage:
                '   ...bind failed (unable to open or wrong version)'.
            ^false ].
    self recordInfoMessage: '    ...done'.
    ^true!
recordAbortMessage: aString
        " Abort the operation in progress and notify the
        user that a fatal error has occurred. "
    self recordMessage: aString
        type: 'abort'
        prefix: '*****FATAL ERROR: '.
    operationAborted := true.! 
doPrerequisites
    "Private - Bind any prerequisite libraries."

    | external try uses |
    self useBindingInformation
        ifFalse: [ ^self ].  " skip prerequisites if we're not going to use it anyway "
    ( objectStore metaInfo at: 'prereqs' ) associationsDo: [:prereq |
        external := prereq key.
        try := prereq value.
        [ external resolve == external and: [ try notEmpty ] ]
            whileTrue: [
				( self
					bind: ( uses := try removeFirst )
					toFindClass: external value ) ifTrue: [
						uses := SmalltalkLibrary named: uses.
						uses decrementReferenceCount.
						self uses: uses ] ] ].!
feedback: aString cr: aBoolean
    "Private - Provide feedback."

    feedback isNil ifTrue: [ self windowFeedback ].
    feedback nextPutAll: aString.
    aBoolean ifTrue: [ feedback cr ].!   
loadFrom: aStream loadMaps: loadMaps
        " Answer the filed object stored at the current
        position on aStream.  The loadMaps collection
        defines mappings for loading classes
        whose shape has changed. "

    | anObject |
    CursorManager execute changeFor: [
        anObject := self new
            loadFrom: aStream
            loadMaps: loadMaps ].
    ^anObject!
describeFromPathName: srcPathName newFile: dstPathName
        " Describe the contents of the filed object in the
        file specified by srcPathName on file dstPathName. "

    | srcFileStream dstFileStream |
    ( File exists: srcPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        srcFileStream := File pathNameReadOnly: srcPathName.
        dstFileStream := File newFile: dstPathName.
        self new describeFrom: srcFileStream to: dstFileStream.
        srcFileStream close.
        dstFileStream close ].!   
constructStandardLoadMaps
         " Private - answer the standard load maps for
        the current version.  The standardLoadMaps
        is a dictionary indexed by the version number
        of a filed version which can be loaded by the
        current version. "

    ^Dictionary new!   
recordWarningMessage: aString
        " Notify the user that a non-fatal error has occurred.
        Usually indicates the loading of
        an object that should be bound but won't be."
    self recordMessage: aString type: 'warning' prefix: 'Warning: '.! 
makeTempClass: className shape: shapeDict

    "Private - The class to be loaded is either missing or changed shape.
    Answer a dummy class so that the object can be loaded
    and also make an entry in the objectChangeMaps so
    that the loaded object can be migrated to the correct one."

    | classToLoad |

    classToLoad := self
        dummyClassName: className
        subclassOf: Object
        instanceVariableNames: ( shapeDict at: 'allInstVarNames' )
        structure: ( shapeDict at: 'structure' ).
    ^classToLoad!  
describeShapes: shapeAssoc on: dstStream
	"Private - Describe class shapes."
	| structure instIndexedBit instPointerBit instZeroTerminatedBit |
	dstStream
		nextPutAll: shapeAssoc key;
		nextPutAll: ' ( '.
	( shapeAssoc value at: 'allInstVarNames' ) do: [ :each |
		dstStream nextPutAll: each; 
			nextPut: $  ].
	dstStream nextPut: $);
		nextPutAll: ' -- '.
	structure := shapeAssoc value at: 'structure'.
	instIndexedBit := 16r2000.
	instPointerBit := 16r4000 .
	instZeroTerminatedBit := 16r1000.
	dstStream 
		nextPutAll:
			( ( structure bitAnd: instIndexedBit ) = 0 
				ifTrue: [ 'fixed' ]
				ifFalse: [ 'variable' ] );
		nextPutAll:
			( ( structure bitAnd: instPointerBit ) = 0
				ifTrue: [ ', byte' ]
				ifFalse: [ ', pointer' ] ).
	( structure bitAnd: instZeroTerminatedBit ) ~= 0
		ifTrue: [ dstStream nextPutAll: ', zero terminated' ].!  
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
mutate: anObject with: aChangeMap
    "Private - Answer a new object transformed from anObject
    according to aChangeMap"

    | class filedSize instVarLoadMap filedIndex skeletonObject |

    class := globalNames at: aChangeMap destinationClassName asSymbol
        ifAbsent: [ ^self recordAbortMessage: 'Remap destination class ',
            aChangeMap destinationClassName, ' does not exist.' ].
	anObject isMetaClass ifTrue: [ ^class class ].
	anObject isClass ifTrue: [ ^class ].
	anObject basicSize > 0
		ifTrue: [ 
			skeletonObject := class basicNew: anObject basicSize.
			1 to: anObject basicSize do: [ :i |
				skeletonObject basicAt: i put: ( anObject basicAt: i ) ] 
			]
		ifFalse: [ skeletonObject := class basicNew ].
	skeletonObject basicHash: anObject basicHash.
    filedSize := aChangeMap sourceSize.
    instVarLoadMap := aChangeMap slotIndexArray.
    " load slots in skeleton, using filed values per user mapping "
    1 to: "filedSize" skeletonObject class instSize do: [ :i |
        filedIndex := instVarLoadMap at: i.
        skeletonObject instVarAt: i put:
                    ((filedIndex isNil)
                        ifTrue: [ nil ]
                        ifFalse: [ anObject instVarAt: filedIndex ] ) ].
    ^skeletonObject!
constructEventsTriggered
        "Private - answer all the events which can be triggered
         by instances of the receiver. "
    ^super constructEventsTriggered
        add: #rehashed ;
        add: #upgraded ;
        add: #loaded ;
        yourself!   
describeFrom: srcStream to: dstStream
        " Describe the classes in the filed object on
        srcStream in a text report on dstStream. "

	| operationDescription checkAbort messageRecorded |
	operationDescription := 'objectStore description'.
	messageRecorded := false.
	checkAbort := [ operationAborted ifTrue: [ 
		messageRecorded := true.
		^nil ] ].
	[
    self describeMetaFrom: srcStream to: dstStream.
    checkAbort value.
    ObjectStoreFileExternal globalNameSpace: globalNames.
    ObjectStoreFileExternal resolveClient: self.
    self
        doPrerequisites ;
        resolveExternals.
    ObjectStoreFileExternal globalNameSpace: nil.
    ObjectStoreFileExternal resolveClient: nil.
    checkAbort value.
    self getObjects.
    checkAbort value
	] ifCurtailed: [
		messageRecorded ifFalse: [
			self recordAbortMessage: 'non-recoverable error occurred' ].
		self recordSummaryMessage: operationDescription.		
		^nil ].

    dstStream cr; nextPutAll: '  Objects:'; cr.
    self describeObject: objectStore root
        level: '      '
        on: dstStream
        history: ( IdentityDictionary new: objectStore objects size )
		caption: 'root'.
    dstStream 
		cr; 
		nextPutAll: '      TOTOL: ', 
			( objectStore metaInfo at: 'objectCount' ) asString,
			' non-shared objects';
		cr.
	self recordSummaryMessage: operationDescription.!  
initialize
        "Private - ObjectFiler class initialization "

    self
        initializePlatformVersion;
        initializeStandardLoadMaps.!   
objectChangeMaps
	"Private - Answer a dictionary of change maps."
    ^objectChangeMaps!
loadFrom: aStream
        " Answer the object encoded on aStream at
        aStream's current position. "
   ^self loadFrom: aStream loadMaps: #()!
removeChangeMapForClass: aClassName forVersion: aFiledObjectVersion
        " Remove any ObjectChangeMap registered for loading
        instances of <aClassName> in filed objects stored
        from <aFiledObjectVersion>. "

    self
        removeChangeMapsSatisfying: [ :aChangeMap |
            aChangeMap sourceClassName = aClassName asString ]
        forVersion: aFiledObjectVersion! 
checkVersion
	"Private - Check if version can be loaded."

    | stream formatVersion |

    (stream := self stream) size < 12 ifTrue: [
        self recordAbortMessage: 'Empty or bad objectStore file: ',
            self stream file pathName.
        ^nil ].

    formatVersion := stream next: 8.
	( self class supportedVersions includes: formatVersion )
        ifFalse: [ ^self recordAbortMessage: 'Invalid objectStore file or version not supported: ',
					 self stream file pathName ].
    stream nextULong.    "Skip the object space offset."
    objectStore formatVersion: formatVersion.
    objectStore version: ( stream next: ( stream nextULong ) ).
    objectStore description: ( stream next: ( stream nextULong ) ).!   
describeClassesFrom: srcStream to: dstStream
        " Describe the classes in the filed object at the current
        position in the srcStream on dstStream. "

    CursorManager execute changeFor: [
        self new describeClassesFrom: srcStream to: dstStream ]!
resolveGlobalPrompt
        "Private - Resolve the receiver."

    | globalToUse |
    globalToUse := self validateGlobal: value classOnly: false.
    globalToUse isNil
        ifTrue: [ ^self ].

    "meta class is also transformed by its class, therefore
    the following code is not needed"
    "maps := self class resolveClient actualChangeMaps.
    changeMap := maps at: globalToUse ifAbsent: [ nil ].
    changeMap notNil ifTrue: [
        maps at: globalToUse class
            put: changeMap ]."

    ^ globalToUse!  
recordInfoMessage: message
    "Private - Ask the client to record an information message."
    self class resolveClient recordInfoMessage: message!
resolveClient
    ^resolveClient!
versionCanBeDescribed: aVersion
        " Answer whether a filed object from aVersion
        can be described by this ObjectFiler. "

    ^self supportedVersions includes: aVersion!
benchmark: partFilePathName
	"Private"

| object objFile compFile objLoad objDump compLoad compDump feedback compStream |
object := (Smalltalk at: #PARTSApplication) fromPathName: partFilePathName.
objFile := partFilePathName fileName, '.obj'.
compFile := partFilePathName fileName, '.cmp'.

Smalltalk unusedMemory.
objDump := Time millisecondsToRun: [
    (Smalltalk at: #ObjectFiler) dump: object newFile: objFile
    ].
Smalltalk unusedMemory.
compDump := Time millisecondsToRun: [
    compStream := File newFile: compFile.
    (Smalltalk at: #ObjectDumper) dump: object on: compStream "objectCountEstimate: 3600".
    compStream close.
    ].
Smalltalk unusedMemory.
objLoad := Time millisecondsToRun: [
    (Smalltalk at: #ObjectFiler) loadFromPathName: objFile
    ].
Smalltalk unusedMemory.
compLoad := Time millisecondsToRun: [
    compStream := File pathNameReadOnly: compFile.
    (Smalltalk at: #ObjectLoader) loadFromPathName: compFile.
    compStream close.
    ].

feedback := ( (Smalltalk at: #Browser) defaultTextWindowClass new
        label: 'Object: ', objFile, ' vs. Component: ', compFile;
        openOn: '' ) pane.
feedback
    nextPutAll: 'Object file ', objFile, ' size: ', (objFile := File pathNameReadOnly: objFile)
        size printString; cr;
    nextPutAll: '    dump time: ', objDump printString,
        ' load time: ', objLoad printString; cr;
    nextPutAll: 'Component ', compFile, ' size: ', (compFile := File pathNameReadOnly: compFile)
        size printString; cr;
    nextPutAll: '    dump time: ', compDump printString,
        ' load time: ', compLoad printString; cr.
    objFile close.
    compFile close.! 
operationAborted: aBoolean
	"Private - Set the abort condition."
    operationAborted := aBoolean!  
recordInfoMessage: aString
        " Notify the user that something interesting has occurred. "
    self recordMessage: aString type: 'info' prefix: ''.!   
load
        " Answer the first object stored a file. "
    | aPathName |
    (aPathName := self getFileNameToOpen) isNil
        ifTrue: [^nil].
    ^self loadFromPathName: aPathName! 
loadFromPathName: aPathName loadMaps: loadMaps
        " Answer the first object stored in the file
        specified by aPathName.  The loadMaps collection
        defines mappings for loading classes
        whose shape has changed. "

    | fileStream anObject |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        fileStream := File pathNameReadOnly: aPathName.
        anObject := self new
            loadFrom: fileStream
            loadMaps: loadMaps.
        fileStream close ].
    ^anObject! 
constructSupportedVersions
        " Private - answer the list of versions
        which can be loaded by this version
        of the ObjectFiler. "

	| answer |
	answer := OrderedCollection with: self currentVersion.
	^answer

    "self currentPlatform = 'VOS'
        ifTrue: [
             ^answer add: 'xxxxxxx';
				yourself
				 ].
    self currentPlatform = 'VWin'
         ifTrue: [
            ^#(

                     ) ].
	"


    "self currentPlatform = 'VMac'
        ifTrue: [ ^Array with: 8 ]."    " VMac 2.0 "
    "self error: ['Unknown platform for supported versions']."!
client: aClient
	"Private"
	client := aClient!  
describeFrom: srcStream to: dstStream
        " Describe the contents of the filed object at the current
        position in the srcStream on dstStream. "

    CursorManager execute changeFor: [
    		self new describeFrom: srcStream to: dstStream ]!   
objectVersionDescription
        " Answer the filed version description of the object
        currently being loaded. "
	^ objectStore version!
windowFeedback
    "Provide feedback in a text window."

    feedback := self class createLogWindowLabelled: 'Object Load Messages'.!  
isLoadingCurrentVersion
        " Answer whether the object being loaded
        is from a file written by the currrent version
        of the ObjectFiler. "

    ^self objectVersion = self currentVersion!
recordMessage: message type: type prefix: prefix
        " Private - record message about the current operation. "

   " update the message counts "
    messageCounts isNil
        ifTrue: [
            messageCounts := Dictionary new.
            #( 'summary' 'info' 'warning' 'abort') do: [ :aType |
                    messageCounts at: aType put: 0]].
    messageCounts
        at: type put: ((messageCounts at: type) + 1);
        at: 'summary' put: ((messageCounts at: 'summary') + 1).

    " record the message "
    clientMessageHandler notNil
        ifTrue: [
            clientMessageHandler evaluateWithArguments: (Array
                with: self
                with: (Association key: type value: message) ) ]
        ifFalse: [
            self feedback: prefix, message
            ].!   
bindLibrary: aLibraryName toFind: aGlobalName
        " Private - attempt to bind the library named
        <aLibraryName> to find the class or global named
        <aGlobalName>.  Answer whether the bind succeeded.
        (Which doesn't necessarily mean it contained the
        the desired class). "

    self recordInfoMessage:
        'Attempting to bind ', aLibraryName,
        ' to locate ', aGlobalName.
    [ SmalltalkLibraryBinder bindTo: aLibraryName ]
        on: FileError, BindError
        do: [ :e |
            self recordInfoMessage:
                '   ...bind failed (unable to open or wrong version)'.
            ^false ].
    self recordInfoMessage: '    ...done'.
    ^true!  
recordSummaryMessage: operationDescription
        " Private - summarize messages
        were encountered during the dump or
        load operation that has just completed. " 
    | numWarnings |
    messageCounts isNil
        ifTrue: [^self].  " no messages reported "
    clientMessageHandler notNil
        ifTrue: [
            clientMessageHandler evaluateWithArguments: (Array
                with: self
                with: (Association key: 'summary' value: messageCounts) ) ]
        ifFalse: [
            ((numWarnings := messageCounts at: 'warning') > 0)
                ifTrue: [
                    self messageStream
                        cr; nextPutAll: '***** ';
                        nextPutAll: numWarnings printString;
                        nextPutAll: ' warnings encountered during ';
                        nextPutAll: operationDescription;
                        nextPutAll: ' *****'; cr ].
            ((messageCounts at: 'abort') > 0)
                ifTrue: [
                    self messageStream
                        cr; nextPutAll: '***** ';
                        nextPutAll: operationDescription;
                        nextPutAll: ' aborted *****';
						cr ].
            messageCounts := "messageStream :=" nil.
            ].!   
createLogWindow
        " Private - create a window for logging messages.
        Answer the text pane to which information can be written. "

    ^self createLogWindowLabelled: self name, ' Messages'! 
describeObject: anObject level: spaces on: dstStream history: dict caption: caption
	"Private - Describe objects recursively."
    | subObject nextLevel |
    dstStream nextPutAll: spaces;
		nextPutAll: caption;
		nextPutAll: ': ';
        nextPutAll: anObject printString.

    ( (self describeIsAtom: anObject)
    or: [ ( anObject isAssociation and: [ globalNames includesKey: anObject key ] )
    ] ) ifTrue: [
        dstStream cr.  ^self ].
    ( dict at: anObject ifAbsent: [ dict at: anObject put: 1. nil ] ) notNil
        ifTrue: [ dstStream nextPut: $*; cr.  ^self ].
    dstStream cr.

	" These objects already displaying contents, stop traversing"
	( anObject isRectangle 
		or: [ anObject isPoint ] )
			ifTrue: [ ^ self ].

    nextLevel := spaces, '  '.
    anObject class isPointers ifTrue: [
        1 to: anObject class instSize do: [ :i |
            subObject := anObject instVarAt: i.
            self describeObject: subObject
                level: nextLevel
                on: dstStream
                history: dict
				caption: (anObject class allInstVarNames at: i)  ].
		1 to: anObject basicSize do: [ :i |   "atom is already shown"
			subObject := anObject basicAt: i.
			( subObject notNil ) ifTrue: [
            	self describeObject: subObject
                	level: nextLevel
                	on: dstStream
                	history: dict
					caption: i asString  ]
			]
        ]!  
currentPlatform
        " Answer the Smalltalk/V platform of this system. "

    ^#( 'VOS' 'VWin' 'VMac' )
        at: ( #( #PM #WIN #MAC ) indexOf: Platform )!  
objectVersion: version
        "Private - Set the filed version of the object
        currently being loaded. "

    objectVersion := version!
describeObjectInPathName: aPathName
        " Describe the contents of a filed object. "

    | aFileStream logWindow |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        aFileStream := File pathNameReadOnly: aPathName.
        logWindow := self createLogWindowLabelled: 'Component Description'.
        self new describeFrom: aFileStream to: logWindow.
        aFileStream close ].!
actualChangeMaps
    "Private - An IdentityDictionary whose key is the class in
    the load file and value is the change map."

    ^actualChangeMaps!   
registerUpgradeMutationFrom: originalInstVarValue to: newInstVarValue
        " This message needs to be sent by certain kinds of upgraders
        when to notify the ObjectFiler of instance variable mutations. "!   
initializeForOperationOn: aStream
        " Private - initialize state for an operation on aStream. "
    ^ ( (aStream respondsTo: #asByteFileStream)
        ifTrue: [aStream asByteFileStream]
        ifFalse: [aStream] ).!   
isClass: loadedClass compatibleWith: newClass
	"Private - check if <loadedClass> type is compatible with
	<newClass> type."

	loadedClass isPointers
		ifTrue: [
			newClass isPointers
				ifTrue: [
					loadedClass isVariable
						ifTrue: [
							newClass isVariable ifFalse: [
            					self recordWarningMessage: 
									'Variable size class (', loadedClass name,
									') is being loaded into fixed size class (', newClass name, ')' ] ]
						ifFalse: [
							newClass isVariable ifTrue: [
            					self recordWarningMessage: 
									'Fixed size class (', loadedClass name,
									') is being loaded into variable size class (', newClass name, ')' ] ]
 					]
				ifFalse: [
            		self recordAbortMessage: 
                		self warningLoadCancelled,
                		' -  cannot load filed pointer class ', loadedClass name,
						' into byte class (', newClass name, ')'.
					^false ]
			]
		ifFalse: [
			newClass isPointers
				ifTrue: [
            		self recordAbortMessage: 
                		self warningLoadCancelled,
                		' -  cannot load filed byte class (', loadedClass name,
						' into pointer class (', newClass name, ')'.
					^false ]
			].
	^true!  
initializeStandardLoadMaps
         " Private - initialize the standard load maps for
        the current version.  The standardLoadMaps
        is a dictionary indexed by the version number
        of a filed version which can be loaded by the
        current version. "

    self standardLoadMapsDictionary: self constructStandardLoadMaps.! 
describeMetaFrom: srcStream to: dstStream
        "Private - Describe the classes in the filed object on
        srcStream in a text report on dstStream. "

    | meta shapes count |
	feedback := dstStream.
    objectChangeMaps := self loadMapsDictFrom: #().
    self stream: ( self initializeForOperationOn: srcStream ).
    self
        checkVersion.
    operationAborted ifTrue: [ ^nil ].
    self getMeta.
    operationAborted ifTrue: [ ^nil ].

    meta := objectStore metaInfo.
    dstStream
		nextPutAll: 'Component Description'; cr;
		nextPutAll: '--------------------------------------'; cr; cr;
        nextPutAll: '  File name: ', objectStore file file pathName; cr;
        nextPutAll: '  Version: ', self objectVersionDescription; cr;
        nextPutAll: '  Description: ', (meta at: 'description'); cr; cr;
        nextPutAll: '  Prerequisites: '; cr.
    ( meta at: 'prereqs' ) associationsDo: [ :assoc |
        dstStream nextPutAll: '      ',  assoc printString.
        dstStream cr ].
    dstStream cr; nextPutAll: '  Imports: '; cr.
    ( meta at: 'imports' ) do: [ :each |
        ( each notNil and: [ ( each type =  'MethodDictionaryArrayExternal' ) not ] ) ifTrue: [
            dstStream nextPutAll: '      '.
            each printOn: dstStream.
            dstStream cr ] ].
    dstStream cr; nextPutAll: '  Object classes (inst vars): '; cr.
    shapes := meta at: 'shapes'.
	count := 0.
    ( meta at: 'imports' ) do: [ :each |
        ( each notNil and:
        [ each type =  'MethodDictionaryArrayExternal' ] ) ifTrue: [
            dstStream nextPutAll: '      '.
            self describeShapes: ( shapes associationAt: each value )
                on: dstStream.
            dstStream cr.
			count := count + 1 ] ].
	dstStream 
		cr; 
		nextPutAll: '      TOTOL: ', count asString, ' classes for non-shared objects';
		cr.!
loadFrom: aStream loadMaps: loadMaps
        " Answer the object encoded on aStream at
        aStream's current position.  The loadMaps
        define mappings for loading classes whose
        shape has changed.  The loadMaps is a
        collection containing ObjectChangeMap
        elements.  Each object change map describes
        the mapping from a source filed class to
        a destination class in the loading image, which
        can have a different name or instance variable
        layout than the filed object.  A destination instance
        variable is loaded with nil if there no mapping from
        a source variable defined for it in the change map.
        (For compatibility, loadMaps can also be a dictionary
        of associations defining the destination class name
        and the slot array map of the destination variables.) "

    | operationDescription checkAbort messageRecorded |

    operationDescription := 'objectStore loading'.
    messageRecorded := false.
    checkAbort := [ operationAborted ifTrue: [
        messageRecorded := true.
        ^nil ] ].
    objectChangeMaps := self loadMapsDictFrom: loadMaps.
    self stream: ( self initializeForOperationOn: aStream ).

    [ self
        checkVersion.
    checkAbort value.
    self
        getMeta.

    ObjectStoreFileExternal globalNameSpace: globalNames.
    ObjectStoreFileExternal resolveClient: self.
    actualChangeMaps := IdentityDictionary new.
    self
        doPrerequisites ;
        check ;
        resolveExternals.
    ObjectStoreFileExternal globalNameSpace: nil.
    ObjectStoreFileExternal resolveClient: nil.

    checkAbort value.
    self getObjects.
    checkAbort value.
    ] ifCurtailed: [
        messageRecorded ifFalse: [ "self error: called"
            self recordAbortMessage: 'non-recoverable error occurred' ].
        self recordSummaryMessage: operationDescription.
        ^nil ].

    self incrementUsesCounts.

    self triggerEvent: #done.
    self recordSummaryMessage: operationDescription.
    ^objectStore root
            root!  
createLogWindowLabelled: aString
        " Private - create a window with <aString> as its label.
        Answer the text pane to which information can be written. "

    ^( TextWindow new
        label: aString;
        openOn: '' )
            pane!
objectVersion
        " Answer the filed version of the object
        currently being loaded. "

    ^objectVersion! 
currentVersion
        " Answer the currrent version of the object file format. "

    ^self class currentVersion! 
resetObjectsAfterMutationCycle: transformations objectArray: objectArray
         " Private - fix things up "

    | loadedObject transformedObject class |

    transformations isEmpty
        ifTrue: [ ^self ].

"###Mike - this is the original tail end of #restoreLoadedObjects:,
        factored out so that the separate upgrade cycle can get
        at it.  Needs to be reviewed against equivalent method
        in ObjectFiler  [Deb 10-Nov-94] ###"

    Terminal bell.  "signal the slow become process"
    " fix references to any objects which changed their identity when activated "
    1 to: objectArray size do: [ :objectId |
        loadedObject := objectArray at: objectId.
        class := loadedObject class.
        (class isPointers) ifTrue: [
            1 to: (class instSize + loadedObject basicSize) do: [ :i |
                transformedObject :=
                    transformations at: (loadedObject instVarAt: i) ifAbsent: [nil].
                transformedObject notNil
                    ifTrue: [loadedObject instVarAt: i put: transformedObject]]]].  " become: "!   
metaShapes
	"Private - Answer class shapes."
    ^ objectStore shapes!  
getClass: aSymbol ifAbsent: aBlock
    "Private -  Try to find a class named aSymbol"

    ^self globalNameSpace at: aSymbol ifAbsent: [ ^aBlock value ]
        "( self globalNameSpace at: #HiddenNames
            ifAbsent: [ Dictionary new ] ) at: aSymbol ifAbsent: [
        ( MetaClass allInstancesPrim
            detect: [:meta | meta instanceClass symbol = aSymbol ]
            ifNone: [ ^aBlock value ] ) instanceClass ] ]. "
        "**** object filer should not cater HiddenNames *****"!
registerChangeMap: aChangeMap forVersion: aFiledObjectVersion
        " Register an ObjectChangeMap to use for loading
        objects stored from <aFiledObjectVersion>.  The change
        map allows a class whose name or shape has changed
        to be quietly upgraded.  For a shape change, new
        instance variables which require initialization should be
        handled by a #fileInActivate: method in the changed class. "

    | changeMaps |
    changeMaps := ( self standardLoadMapsDictionary at: aFiledObjectVersion
        ifAbsentPut: [ #() ] )
            asOrderedCollection.
    changeMaps := changeMaps reject: [ :aRegisteredMap |
        aRegisteredMap sourceClassName = aChangeMap sourceClassName ].
    changeMaps add: aChangeMap.
    self standardLoadMapsDictionary
        at: aFiledObjectVersion
        put: changeMaps asArray.!   
describeIsAtom: anObject
	"Private - Answer true if anObject is an atom
	during description so that its contents won't
	be described."

	^ anObject isNil
		or: [ anObject isBehavior
		or: [ anObject isNumber
		or: [ anObject isString
		or: [ anObject isCharacter
		or: [ anObject isBoolean
		] ] ] ] ]! 
useBindingInformation: aBoolean
        " Specify whether component binding information
        for resolving missing classes should be used
        during loading. "

    useBindingInformation := aBoolean.!  
restoreLoadedObjects: objectArray
        " Private - restore objects which need special initialization.
        Allow activation to transform the identity of the restored object. "

    | lastObjectId transformations loadedObject activatedObject |

    lastObjectId := objectArray size.
    transformations := IdentityDictionary new.

    " do file-in activates "
    1 to: lastObjectId do: [ :objectId |
        loadedObject := objectArray at: objectId.
        activatedObject := loadedObject fileInActivate: self.
        activatedObject ~~ loadedObject
            ifTrue: [
                transformations at: loadedObject put: activatedObject.
                objectArray at: objectId put: activatedObject ].
        ].
    operationAborted ifTrue: [^nil].

    " merge upgrades into transformation "

    self resetObjectsAfterMutationCycle: transformations
        objectArray: objectArray.

    (transformations size = 0) ifTrue: [^self].!
resolveMetaClassPrompt
        "Private - Resolve the receiver."

    | classToLoad |
    classToLoad := self validateGlobal: value classOnly: true.
    ^ classToLoad isClass
        ifTrue: [ classToLoad class ]
        ifFalse: [ self ]!
loadMapUsedFor: anObject
        " Answer the change map used to load anObject
        if the positions of any instance variables changed.
        Only valid during fileInActivate: processing. "
	^remappedObjects isNil
		ifTrue: [ nil ]
		ifFalse: [ remappedObjects at: anObject ifAbsent: [ nil ] ]! 
resolveClient: aClient
    resolveClient := aClient! 
installComponent
       "Private - Initialize the classes installed in the ObjectFiler component. "

    | aClass |
    #( "ListConnectionPane ObjectLoadDialog" #ObjectLoader )
        do: [ :classSymbol |
            aClass := Smalltalk at: classSymbol ifAbsent: [nil].
            ( aClass notNil
            and: [ aClass class includesSelector: #initialize ] )
                ifTrue: [ aClass initialize ] ].

    "( self componentName notNil
    and: [ ( aComponent := ComponentBinder named: self componentName ) notNil ] )
        ifTrue: [
            aComponent
                when: #unbind
                send: #removeComponent to: self ]."! 
removeChangeMapsSatisfying: aOneArgBlock forVersion: aFiledObjectVersion
        " Remove any ObjectChangeMap's registered for loading
        objects stored from <aFiledObjectVersion> which cause
        aOneArgBlock to evaluate to true. "

    | changeMaps |
    changeMaps := ( self standardLoadMapsDictionary at: aFiledObjectVersion
        ifAbsentPut: [ ^self ] )
            asOrderedCollection.
    changeMaps := changeMaps reject: [ :aRegisteredMap |
        aOneArgBlock value: aRegisteredMap ].
    changeMaps isEmpty
        ifTrue: [
        self upgradeMapsDictionary removeKey: aFiledObjectVersion ]
        ifFalse: [
        self standardLoadMapsDictionary
            at: aFiledObjectVersion
            put: changeMaps asArray ].!
initialize
	"Private"
	super initialize.
    objectStore := ObjectStoreWithClient new client: self.
    globalNames := Smalltalk.
    operationAborted := false.
    self useBindingInformation: true.! 
supportedVersions: aCollection
        " Private - set the versions which can be loaded. "

    SupportedVersions := aCollection.! 
standardLoadMapsDictionary
        " Private - answer the dictionary with the standard
        load maps list, keyed by filed object version. "

    ^StandardLoadMaps!   
addObjects: objectSpace externals: externalsArray objects: objectArray
    "Private - Add the objects from aByteArray.
    Answer the root object."

    ^VirtualMachineLibrary
        addObjects: objectSpace
        externals: externalsArray
        objects: objectArray!
describeClassesInPathName: aPathName
        " Describe the classes of a filed object. "

    | aFileStream logWindow |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        aFileStream := File pathNameReadOnly: aPathName.
        logWindow := self createLogWindowLabelled: 'Component Summary Description'.
        self new describeClassesFrom: aFileStream to: logWindow.
        aFileStream close ].!