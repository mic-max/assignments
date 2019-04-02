3.1.0.106
   
describeClassesInPathName: aPathName
        " Describe the classes in the filed object in the
        file specified by <aPathName>. "

    | aFileStream reportStream |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        aFileStream := File pathNameReadOnly: aPathName.
        reportStream := ReadWriteStream on: String new.
        self new describeClassesFrom: aFileStream to: reportStream.
        aFileStream close ].
    ( self createLogWindowLabelled: self name, ' Summary Report' )
        contents: reportStream contents.! 
constructSupportedVersions
        " Private - answer the list of versions
        which can be loaded by this version
        of the ObjectFiler. "

    self currentPlatform = 'VOS'
        ifTrue: [
            ^#(
                    11     " VS/OS2 3.1 "
                    9     " VS/OS2 3.0 "
                    6     " VOS 2.x "
                    3 5   " VPM 1.2, 1.3 "
                    ) ].
    self currentPlatform = 'VWin'
         ifTrue: [
            ^#(
                    12     " VS/Win32 3.0 "
                    10     " VS/Win32 3.0 "
                    7    " VWin32 2.0 "
                    4    " VW 2.0 "
                     ) ].
    self currentPlatform = 'VMac'
        ifTrue: [ ^#( 8 ) ].    " VMac 2.0 "
    self error: ['Unknown ObjectFiler version'].!  
dump: anObject on: aStream
        " Store anObject on aStream, starting at the current position.
        Answer anObject (nil if the dump failed). "

    | answer |
    CursorManager execute changeFor: [
        answer := self new dump: anObject on: aStream ].
    ^answer! 
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
changeMapsForR20
        " Answer a list of the shape change mappings
        of system objects which changed shape in R2.0 "

    ^( #( 'VOS' 'VWin' ) includes: self currentPlatform )
        ifTrue: [   " Association swapped slots in V32 image "
            Array
                with: ( ObjectChangeMap forClass: Association )
            ]
        ifFalse: [ #() ]  " no changes in VMac 2.0 "!
registerService
		" Register the ObjectFiler as a service. "

	ServiceRegistry globalRegistry
		register: self
		withName: self serviceName
		version: Smalltalk versionNumberString.
!
createLogWindow
        " Private - create a window for logging messages.
        Answer the text pane to which information can be written. "

    ^self createLogWindowLabelled: self name, ' Messages'! 
describe
        " Describe a filed object. Prompt the user for the file name
        containing the filed object. "

    | aPathName |
    ( aPathName := self getFileNameToOpen ) isNil
        ifTrue: [ ^nil ].
    ^self describeObjectInPathName: aPathName! 
describeObjectInPathName: aPathName
        " Describe the contents of the filed object in the
        file specified by <aPathName>. "

    | aFileStream reportStream |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        aFileStream := File pathNameReadOnly: aPathName.
        reportStream := ReadWriteStream on: String new.
        self new describeFrom: aFileStream to: reportStream.
        aFileStream close ].
    ( self createLogWindowLabelled: self name, ' Detailed Report' )
        contents: reportStream contents.!   
changeMapsForR30
        " Answer a list of the shape change mappings
        of system objects which changed shape in R3.0 "

    self currentPlatform = 'VOS'
        ifTrue: [ ^self changeMapsForVOS30 ].
    self currentPlatform = 'VWin'
        ifTrue: [ ^self changeMapsForVW30 ].
    ^#()!
changeMapsForR31
        " Answer a list of the shape change mappings
        of system objects which changed shape in R3.1 "

    self currentPlatform = 'VOS'
        ifTrue: [
            ^self changeMapsForR31Common,
            self changeMapsForR31OS2 ].
    self currentPlatform = 'VWin'
        ifTrue: [ ^self changeMapsForR31Common ].
    ^#()!   
dump: anObject newFile: aPathName
        " Store anObject in the file specified by aPathName.
        Answer anObject (nil if the dump failed). "

    | file fileStream result |
    CursorManager execute changeFor: [
        file := File fromPath: aPathName.
        file exists ifTrue: [ file remove ].
        file create.
        fileStream := file binaryWriteStream.
        self setFileType: fileStream file.
        result := self new dump: anObject on: fileStream.
        fileStream close ].
    ^result!
standardLoadMapsDictionary: aDictionary
        " Private - set the dictionary with the standard
        load maps list, keyed by filed object version. "

    standardLoadMaps := aDictionary.!  
dumpAll: aCollection newFile: aPathName
        " Store each object in aCollection on the file
        specified by aPathName.
        Answer aCollection (nil if the dump failed). "

    | file fileStream aDumper result |
    CursorManager execute changeFor: [
        file := File fromPath: aPathName.
        file exists ifTrue: [ file remove ].
        file create.
        fileStream := file binaryWriteStream.
        aDumper := self new.
        aCollection do: [ :anObject |
            result := aDumper dump: anObject on: fileStream.
            result isNil
                ifTrue: [ fileStream close. ^nil ].
            ].
        fileStream close ].
    ^aCollection!
idMetaClass
        " Private - answer the reserved dump id of MetaClass "

    ^4!
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
            self standardLoadMapsDictionary removeKey: aFiledObjectVersion ]
        ifFalse: [
            self standardLoadMapsDictionary
                at: aFiledObjectVersion
                put: changeMaps asArray ].!   
changeMapsForVW30
        " Answer a list of the shape change mappings
        of system objects which changed shape in VWin32 3.0.
        Many classes were reorganized for cross-platform
        commonality. "

    | loadMaps aChangeMap |

    loadMaps := OrderedCollection new.
    loadMaps addAll: self changeMapsForR30Common.

    " Font drastically restructured in 3.0 "
    loadMaps add: ( ( ObjectChangeMap forClassName: #Font )
        " faceName, pointSize, changed are preserved from VWin32 2.0;
            dropped isImage, textMetrics "
        " new in 3.0: physicalFont, graphicsMedium"
        put: 'logFont' into: 'logicalFont';
        "put: 'hFont' into: 'handle';"  " renamed; ignore, gets reset anyway "
        yourself ).

    " everything in Window hierarchy reordered to match VOS shapes "
    Window withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [ loadMaps add: ( ObjectChangeMap forClass: aClass ) ].
        ].

    " DrawnButton: 'drawBlock' renamed to 'drawSelector' "
    aChangeMap := loadMaps detect: [ :ocm |
            ocm sourceClassName = 'DrawnButton' ].
    aChangeMap put: 'drawBlock' into: 'drawSelector'.
    "####ISSUE: What if anything can upgrader do?? ###"

    " EntryField 'textLimit' -> #textLimit property "
    EntryField withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [
                aChangeMap := loadMaps detect: [ :ocm |
                    ocm sourceClassName = aClass name ].
                aChangeMap put: 'textLimit' into: 'topCorner' ].  " upgrader must fix "
        ].

    " TextEdit 'readonly' -> style bits "
    TextEdit withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [
                aChangeMap := loadMaps detect: [ :ocm |
                    ocm sourceClassName = aClass name ].
                aChangeMap put: 'readonly' into: 'handle' ].  " upgrader must fix "
        ].

    " VW 2.0 ListPane class was a dummy subclass of ListBox;
        VW 3.0 ListPane is an entirely different guy. "
    aChangeMap := loadMaps detect: [ :ocm |
            ocm sourceClassName = 'ListPane' ].
    aChangeMap destinationClassName: 'ListBox'.

    ^loadMaps!   
currentVersion
        " Answer the current version of the object file format "

    ^Version! 
initializeNameSpaceInformation
    " Private - initialize the name space and special objects info.
    The dump id name space of a filed object is a contiguous range
        of integers which fall into 4 distinct regions:
            (1) ids for immutable objects and certain special globals:
                    nil, true, false, MetaClass, Smalltalk,
                    Notifier, Processor, OperatingSystem, Display, Clipboard
            (2) sequentially assigned ids for behavior descriptors
                    (class and metaclass entries)
            (3) sequentially assigned ids for non-behavior objects
            (4) ids for immutable objects of type Character and Integer
                    (single-byte characters only; DBC gets dynamic id)
        Only the dynamically assigned descriptors must be filed. "

    | specialObjects info |

    NumPredefinedIds := 11.
    IdNUL := 0.
    IdNil := 1.

    " initialize the list of special objects which terminate the
        dump enumeration and have specially allocated identifiers.
        These are classes which are expected to only have a
        single instance.  They are assigned standard ids at the
        beginning of the dump id name name space.  These
        objects are bound to their environment at object
        load time. "
    specialObjects := Array new: NumPredefinedIds.
    specialObjects   " construct value/description pairs for reserved ids "
        at: 1 put: ( Array with: nil with: 'nil' );
        at: 2 put: ( Array with: true with: 'true' );
        at: 3 put: ( Array with: false with: 'false' );
        at: 4 put: ( Array
            with: ( ObjectReference forGlobalNamed: #MetaClass )
            with: 'MetaClass' );
        at: 5 put: ( Array
            with: ( ObjectReference forGlobalNamed: #Smalltalk )
            with: 'Smalltalk' );
        " some of the following are system-dependent "
        at: 6 put: ( Array
            with: ( ObjectReference forGlobalNamed: #SymbolTable )
            with: 'SymbolTable' );
       at: 7 put: ( Array
            with: ( ObjectReference forGlobalNamed: #Notifier )
            with: 'Notifier' );
        at: 8 put: ( Array
            with: ( ObjectReference forGlobalNamed: #Processor )
            with: 'Processor' );
        at: 9 put: ( Array
            with: ( ObjectReference forGlobalNamed: #Clipboard )
            with: 'Clipboard' );
        at: 10 put: ( Array
            with: ( ObjectReference forGlobalNamed: #OperatingSystem )
            with: Platform asString );
        at: 11 put: ( Array
            with: ( ObjectReference forGlobalNamed: #Display )
            with: 'Display' ).
    self idMetaClass = 4 ifFalse: [ self error: 'programming error' ].
    ReservedIdMap := Dictionary new.
    ReservedIdDescriptions := Array new: NumPredefinedIds.
    1 to: NumPredefinedIds do: [ :i |
        info := specialObjects at: i.
        ReservedIdMap at: ( info at: 1 ) put: i.  " map object to id "
        ReservedIdDescriptions at: i put: ( info at: 2 ) ].!
loadFrom: aStream
        " Answer the filed object stored at the current
        position on aStream. "

    ^self new loadFrom: aStream!
version
        " Answer current version stamp for the object file format.
        Obsolete - retained for compatibility. "

    self obsoleteMethod.
    ^self currentVersion!  
defaultDictionaryClass: aClass
        " Private - set the default identity dictionary class "

    defaultDictionaryClass := aClass.! 
describeClasses
        " Describe the classes of a filed object.
        Prompt the user for the file name containing the filed object. "

    | aPathName |
    ( aPathName := self getFileNameToOpen ) isNil
        ifTrue: [ ^nil ].
    ^self describeClassesInPathName: aPathName!  
loadAllFromPathName: aPathName loadMaps: loadMaps
        "  Answer a collection containing all the objects
        stored in the file specified by aPathName. The
        loadMaps collection defines mappings for loading
        classes whose shape has changed. "

    | fileStream aLoader objects |
    ( File exists: aPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        fileStream := File pathNameReadOnly: aPathName.
        aLoader := self new.
        objects := OrderedCollection new.
        [ fileStream atEnd ] whileFalse: [
            objects add:
                ( aLoader loadFrom: fileStream loadMaps: loadMaps ) ].
        fileStream close ].
    ^objects!   
initialize
        " ObjectFiler class initialization "

    self
        initializeConstants;
        initializePlatformVersion;
        initializeDefaultDictionaryClass;
        initializeNameSpaceInformation;
        initializeTerminalClasses;
        initializeStandardLoadMaps;
        initializeSoftSlotSelectors;
        registerService.!  
initializeConstants
        " Private - initialize delimiter and type constants "

    Seal := Esc.  " control code byte to mark start of filed object "

    " entry/section delimiter, entry type constants "
    NUL := 0 asCharacter.
    TagClass := 1 asCharacter.
    TagMetaClass := 2 asCharacter.
    RepFixedPointers := 1 asCharacter.
    RepVariablePointers := 2 asCharacter.
    RepVariableBytes := 3 asCharacter.
    ClassIdSymbol := 1.
    ClassIdDBSymbol := 2.!   
supportedVersions
        " Private - answer the versions which can be loaded. "

    ^supportedVersions!  
supportedVersions: aCollection
        " Private - set the versions which can be loaded. "

    supportedVersions := aCollection.! 
dump: anObject
        " Store anObject. "

    | aPathName |
    (aPathName := self getFileNameToCreate) isNil
        ifTrue: [^nil].
    ^self dump: anObject newFile: aPathName!
load
        " Answer the first object stored a file. "

    | aPathName |
    (aPathName := self getFileNameToOpen) isNil
        ifTrue: [^nil].
    ^self loadFromPathName: aPathName!   
versionHasBindingInformation: aVersion
        " Answer whether a filed object from aVersion
        contains DLL or component binding information 
        in its behavior descriptors. "

    ^#( 
            6 7    " VOS 2.0; VWin32 2.0 "
            9 10   " VS/OS2 3.0; VS/Win32 3.0 "
            11 12   " VS/OS2 3.1; VS/Win32 3.1 "
            ) includes: aVersion!   
removeAllChangeMapsForClass: aClassName
        " Remove any ObjectChangeMap registered for loading
        instances of <aClassName> from any version. "

    self supportedVersions do: [ :aFiledObjectVersion |
        self
            removeChangeMapForClass: aClassName
            forVersion: aFiledObjectVersion ].!
versionCanBeDescribed: aVersion
        " Answer whether a filed object from aVersion
        can be described by this ObjectFiler. "

    ^#( 
        3 4 5  " VPM 1.2; VW 2.0; VPM 1.3 "
        6 7 8   " VOS 2.0; VWin32 2.0; VMac 2.0 "
        9 10    " VS/OS2 3.0; VS/Win32 3.0 "
        11 12    " VS/OS2 3.0; VS/Win32 3.0 "
        ) includes: aVersion!   
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
standardLoadMapsDictionary
        " Private - answer the dictionary with the standard
        load maps list, keyed by filed object version. "

    ^standardLoadMaps!   
initializeDefaultDictionaryClass
        " Private - initialize the default dictionary class.
        Must be an identity dictionary (keys are tested using ==). "

    self defaultDictionaryClass: IdentityDictionary.! 
constructStandardLoadMaps
         " Private - answer the standard load maps for
        the current version.  The standardLoadMaps
        is a dictionary indexed by the version number
        of a filed version which can be loaded by the
        current version. "

    | loadMapsDict loadMapList |
    loadMapsDict := Dictionary new.
    self supportedVersions do: [ :aFileVersion |
        ( #( 3 4 5 ) includes: aFileVersion )
            ifTrue: [  " 16-bit VPM 1.x, VW 2.0 "
                loadMapList :=
                    self changeMapsForR20,
                    self changeMapsForR30 ].
        ( #( 6 7 ) includes: aFileVersion )
            ifTrue: [ " 32-bit VOS 2.x, VWin32 2.0 "
                loadMapList := 
                    self changeMapsForR30 ].
        ( #( 9 10 ) includes: aFileVersion )
            ifTrue: [ " VS/OS2 3.0, VS/Win32 3.0 "
                loadMapList := self changeMapsForR31 ].
        aFileVersion = self currentVersion
            ifTrue: [ loadMapList := self changeMapsForCurrentVersion ].
        loadMapList notEmpty
            ifTrue: [ loadMapsDict at: aFileVersion put: loadMapList ].
        ].
    ^loadMapsDict!  
getFileNameToOpen
        " Private - answer the name of the file to open. "

    ^(FileDialog new openFile) file! 
initializePlatformVersion
        " Private - set the platform identification
        and the current version.
        Version stamp allocations:
            = 1, Smalltalk/V Dumper (Goodies #1 package)
            = 2, Smalltalk/V 286 Dumper
            = 3, Smalltalk/V PM 1.2 ObjectFiler
            = 4, Smalltalk/V Win 2.0 ObjectFiler
            = 5, Smalltalk/V PM 1.3 ObjectFiler
            = 6, Smalltalk/V OS/2 2.0 ObjectFiler
            = 7, Smalltalk/V Win32 2.0 ObjectFiler
            = 8, Smalltalk/V Mac 2.0 ObjectFiler
            = 9, Visual Smalltalk for OS/2 3.0 ObjectFiler
            = 10, Visual Smalltalk for Win32 3.0 ObjectFiler
            = 11, Visual Smalltalk for OS/2 3.1 ObjectFiler
            = 12, Visual Smalltalk for Win32 3.1 ObjectFiler
        "

    Platform := nil.
    Smalltalk platformIsOS2
        ifTrue: [
            Platform := #PM.
            self currentVersion: 11.  " VS/OS2 3.1 "
            ].
    Smalltalk platformIsWin32
        ifTrue: [
            Platform := #WIN.
            self currentVersion: 12.  " VS/Win32 3.1 "
            ].
    Smalltalk product = 'Smalltalk/V for Macintosh'
        ifTrue: [
            Platform := #MAC.
            self currentVersion: 8.  " VMac 2.0 "
            ].
    Platform isNil
        ifTrue: [ self error: 'Unknown Smalltalk platform' ].
    self supportedVersions: self constructSupportedVersions.! 
loadFromPathName: aPathName
        " Answer the first object stored in the file
        specified by aPathName. "

    ^self loadFromPathName: aPathName loadMaps: #()!  
changeMapsForCurrentVersion
        " Answer a list of the shape change mappings of system
        objects which changed shape within the current version "

    ^#()!
changeMapsForR31OS2
        " Answer a list of the shape change mappings
        of system objects which changed shape in R3.1
        in both OS/2 and Win32. "

    | changeMaps |
    changeMaps := OrderedCollection new
        add: ( ObjectChangeMap forClassName: #Container );  " dropped inst. vars"
        yourself.
    " ContainerItem and all its subclasses: renamed inst var "
    #( #ContainerItem
            #ContainerDirectory
                #ContainerFile
                #ContainerFolder
            #ContainerObject
                #ContainerIndexed
            ) do: [ :className |
        changeMaps add: ( ( ObjectChangeMap forClassName: className )
            put: 'dragFormats' into: 'dragTargetFormats';
           yourself ) ].
    ^changeMaps asArray
! 
describeClassesFrom: srcStream to: dstStream
        " Describe the classes in the filed object at the current
        position in the srcStream on dstStream. "

    CursorManager execute changeFor: [
        self new describeClassesFrom: srcStream to: dstStream ].!   
serviceName
		" Answer the name of the ObjectFiler service in the service registry. "

	^#ObjectFiler! 
changeMapsForVOS30
        " Answer a list of the shape change mappings
        of system objects which changed shape in VOS 3.0.
        Many classes were reorganized for cross-platform
        commonality. "

    | loadMaps aChangeMap |

    loadMaps := OrderedCollection new.
    loadMaps addAll: self changeMapsForR30Common.

    " Font drastically restructured in 3.0 "
    loadMaps add: ( ( ObjectChangeMap forClassName: #Font )
        " pointSize is preserved; drop charSize, spaceWidth,
            startChar, endChar, fixedWidth, basePoint "
        put: 'metrics' into: 'logicalFont';  " picked up in fileInActivate: "
        yourself ).

    " 'graphicsTools' and 'deviceContext' swapped slots to match VW "
    GraphicsMedium withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [ loadMaps add: ( ObjectChangeMap forClass: aClass ) ].
        ].

    " Icon 'bitmap' and 'colorBitmap' inst vars added in VOS 3.0 "
    loadMaps add: ( ObjectChangeMap forClassName: #Icon ).
        " new inst vars used for icon from file; VOS 2.0 only supported icon from DLL "

    " Menu: VOS 2.0 inst vars 'labels' and 'selectors' dropped (dup info) "
    loadMaps add: ( ObjectChangeMap forClassName: #Menu ).

    " MenuWindow: 'menus' moved to last slot "
    loadMaps add: ( ObjectChangeMap forClassName: #MenuWindow ).

    " SubPane dropped VOS 2.0 margin, added id in 3.0 "
    SubPane withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [ loadMaps add: ( ObjectChangeMap forClass: aClass ) ].
        ].

    " EntryField inst vars reordered, 'maxSize' -> #textLimit property "
    EntryField withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [
                aChangeMap := loadMaps detect: [ :ocm |
                    ocm sourceClassName = aClass name ].
                aChangeMap put: 'maxSize' into: 'topCorner' ].  " upgrader must fix "
        ].

    " TextEdit 'readonly' -> style bits "
    TextEdit withAllSubclasses do: [ :aClass |
        aClass isInBase
            ifTrue: [
                aChangeMap := loadMaps detect: [ :ocm |
                    ocm sourceClassName = aClass name ].
                aChangeMap put: 'readonly' into: 'handle' ].  " upgrader must fix "
        ].

    " VOS 2.0 TextPane renamed to TextPaneControl "
    aChangeMap := loadMaps detect: [ :ocm |
        ocm sourceClassName = 'TextPane' ].
    aChangeMap
        destinationClassName: 'TextPaneControl';
        put: 'maxSize' into: 'topCorner';  " upgrader must fix "
        yourself.
    "Extras: VOS 2.0 TextPaneClassic -> VOS 3.0 TextPane "

    ^loadMaps asArray!   
constructSoftSlotSelectors
         " Private - Answer the soft slot selectors list for
        the current version.  The soft slot selectors list
        contains pairs of get/set selectors for object soft slots. "

    ^( self versionHasSoftSlots: self currentVersion )
        ifTrue: [ #(
            #( #objectEventTable #objectEventTable: )
            #( #objectProperties #objectProperties: )
            ) ]
        ifFalse: [ #( ) ]! 
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
installComponent
       " Initialize the classes installed in the ObjectFiler component. "

    | aClass |
    #( #ObjectFiler )
        do: [ :classSymbol |
            aClass := Smalltalk at: classSymbol ifAbsent: [ nil ].
            ( aClass notNil
            and: [ aClass class includesSelector: #initialize ] )
                ifTrue: [ aClass initialize ] ].
    self registerService.
!
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
standardLoadMapsFor: aVersion
        " Private - answer the standard load maps for loading
        an object filed out from aVersion into the current
        version. "

    ^self standardLoadMapsDictionary at: aVersion ifAbsent: [ #() ]!  
unregisterService
		" Unregister the ObjectFiler as a service. "

	ServiceRegistry globalRegistry unregister: self serviceName.
! 
removeChangeMapForClass: aClassName forVersion: aFiledObjectVersion
        " Remove any ObjectChangeMap registered for loading
        instances of <aClassName> in filed objects stored
        from <aFiledObjectVersion>. "

    self
        removeChangeMapsSatisfying: [ :aChangeMap |
            aChangeMap sourceClassName = aClassName asString ]
        forVersion: aFiledObjectVersion! 
createLogWindowLabelled: aString
        " Private - create a window with <aString> as its label.
        Answer the text pane to which information can be written. "

    | aWindow |
    Platform = #MAC
        ifTrue: [
            ^( Smalltalk at: #TranscriptWindow )
                openOn: String new
                label: aString ]
        ifFalse: [  " VOS, VW "
            aWindow := (Smalltalk at: #TextWindow) new openOn: String new.
            aWindow mainView label: aString.
            ^aWindow pane ]!   
currentVersion: aFileVersion
        " Private - set the current version of the object file format "

    Version := aFileVersion.!
versionCanBeLoaded: aVersion
        " Answer whether a filed object from aVersion
        can be loaded by this ObjectFiler. "

    ^self supportedVersions includes: aVersion!  
initializeTerminalClasses
        " Private - initialize the definition of the classes
        which terminate the traversal of the object graph. "

    " Classes whose objects and behaviors are not logged.
        Either a singular class whose instance ids are
        predefined or immutable objects whose ids are
        computable. "
    TerminalClasses := Set new.
    TerminalClasses
        add: UndefinedObject;
        add: True;
        add: False;
        add: MetaClass class;
        addAll: (Integer withAllSubclasses).
    " only single-byte characters are terminals "
    ( Character compiledMethodAt: #isSingleByte ) isNil
        ifTrue: [ TerminalClasses add: Character ].! 
versionDescription: aVersion
        " Answer a description of the Smalltalk
        filed object version aVersion. "

    ^#(
        " = 1, " 'Smalltalk/V Dumper (Goodies #1 package)'
        " = 2, " 'Smalltalk/V 286 Dumper'
        " = 3, " 'Smalltalk/V PM 1.2 ObjectFiler'
        " = 4, " 'Smalltalk/V Windows 2.0 ObjectFiler'
        " = 5, " 'Smalltalk/V PM 1.3 ObjectFiler'
        " = 6, " 'Smalltalk/V for OS/2 2.0 ObjectFiler'
        " = 7, " 'Smalltalk/V for Win32 2.0 ObjectFiler'
        " = 8, " 'Smalltalk/V for Macintosh 2.0 ObjectFiler'
        " = 9, " 'Visual Smalltalk for OS/2 3.0 ObjectFiler'
        " = 10, "  'Visual Smalltalk for Win32 3.0 ObjectFiler'
        " = 11, " 'Visual Smalltalk for OS/2 3.1 ObjectFiler'
        " = 12, "  'Visual Smalltalk for Win32 3.1 ObjectFiler'
        ) at: aVersion!  
defaultDictionaryClass
        " Private - answer the default identity dictionary class "

    ^defaultDictionaryClass!
describeFrom: srcStream to: dstStream
        " Describe the contents of the filed object at the current
        position in the srcStream on dstStream. "

    CursorManager execute changeFor: [
        self new describeFrom: srcStream to: dstStream ].!
initializeSoftSlotSelectors
         " Private - initialize the soft slot selectors list for
        the current version.  The soft slot selectors list
        contains pairs of get/set selectors for object soft slots. "

    self softSlotSelectors: self constructSoftSlotSelectors.!  
changeMapsForR30Common
        " Answer a list of the shape change mappings
        of system objects which changed shape in R3.0
        in both VOS and VW.  Hashed collections didn't
        change shape, but their contents inst var is
        different, so they are handled in #fileInRehash: "

   ^( OrderedCollection new
        " method literals can be global assoc and class var OLE's "
        add: ( ObjectChangeMap
            forClassName: #ObjectLibraryExternal
            destinationClassName: #ObjectStoreExternal );
        " file system objects were drastically redesigned in R3.0 "
        add: ( ObjectChangeMap
            forClassName: #File
            destinationClassName: #UpgraderForFile );
        add: ( ObjectChangeMap
            forClassName: #Directory
            destinationClassName: #UpgraderForDirectory );
        yourself)
            asArray!
changeMapsForR31Common
        " Answer a list of the shape change mappings
        of system objects which changed shape in R3.1
        in both OS/2 and Win32. "

   ^( OrderedCollection new
        add: ( ObjectChangeMap forClassName: #ScrollBar );  " layout reordered "
        yourself)
            asArray!  
eventsTriggered
        "Answer all the events which can be triggered
        by instances of the receiver."

    ^#(
        #rehashed
        #upgraded
        #loaded
        )!  
getFileNameToCreate
        " Private - answer the name of the file to create. "

    ^(FileDialog new saveFile: 'FiledObj.obj') file! 
initializeStandardLoadMaps
         " Private - initialize the standard load maps for
        the current version.  The standardLoadMaps
        is a dictionary indexed by the version number
        of a filed version which can be loaded by the
        current version. "

    self standardLoadMapsDictionary: self constructStandardLoadMaps.! 
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
removeComponent
       " Prepare to remove the ObjectFiler component. "

	self unregisterService.
!   
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
currentPlatform
        " Answer the Smalltalk/V platform of this system. "

    ^#( 'VOS' 'VWin' 'VMac' )
        at: ( #( #PM #WIN #MAC ) indexOf: Platform )!  
describeAllFromPathName: srcPathName newFile: dstPathName
        " Describe the contents of all filed objects in the
        file specified by srcPathName on file dstPathName;
        answer the number of filed objects. "

    | srcFileStream dstFileStream aLoader numFiledObjects |
    ( File exists: srcPathName ) ifFalse: [ ^nil ].
    CursorManager execute changeFor: [
        srcFileStream := File pathNameReadOnly: srcPathName.
        dstFileStream := File newFile: dstPathName.
        aLoader := self new.
        numFiledObjects := 0.
        [ srcFileStream atEnd ] whileFalse: [
            numFiledObjects := numFiledObjects + 1.
            ( numFiledObjects > 1 ) ifTrue: [
                dstFileStream nextPutAll: '------------------------------'; cr; nextPut: Ff ].
            aLoader describeFrom: srcFileStream to: dstFileStream ].
        srcFileStream close.
        dstFileStream close ].
    ^numFiledObjects!   
setFileType: aFile
       " Set the file type of aFile to mark the file
       as a Smalltalk/V filed object. "

    self currentPlatform = 'VMac'    " set Macintosh file type "
        ifTrue: [ aFile creator: 'STV2' type: 'VOF1' ].!   
softSlotSelectors
        " Private - Answer the list softSlotSelectors which are supported for dumping.
		Each list entry contains the pair of get/set selectors for a soft slot. "

    ^softSlotSelectors! 
softSlotSelectors: selectorPairList
        " Private - Set the list softSlotSelectors which are supported for dumping.
		Each list entry contains the pair of get/set selectors for a soft slot. "

    softSlotSelectors := selectorPairList.!  
loadAllFromPathName: aPathName
        "  Answer a collection containing all the objects stored
        in the file specified by aPathName. "

    ^self loadAllFromPathName: aPathName loadMaps: #()!
versionHasSoftSlots: aVersion
        " Answer whether a filed object from aVersion
        contains soft object slots information. " 

    ^#( 
            11 12   " VS/OS2 3.1; VS/Win32 3.1 "
            ) includes: aVersion! 
resetObjectsAfterMutationCycle: objectsUpdateList rootObjectId: rootObjectId
         " Private - fix things up "

    | upgradedObject |

    objectTransformationMap isEmpty
        ifTrue: [ ^self ].

    self
        resetReferencesToTransformedObjects: objectTransformationMap
        rootObjectId: rootObjectId.

    " fix up the mutations we know about "
    objectsUpdateList do: [ :array |
        upgradedObject := array at: 2.
        objects at: ( array at: 1) put: upgradedObject.
        objectTransformationMap removeKey:
            ( objectTransformationMap keyAtValue: upgradedObject ) ].
    " fix up any mutations that upgraders themselves did (and told us about) "
    objectTransformationMap associationsDo: [ :assoc |
        objects at: ( objects indexOf: assoc key ) put: assoc value ].!   
dump: anObject on: aStream
        " Write a binary representation of anObject
        (along with anObject's referenced structure) onto
        aStream.  Answer anObject (nil if the dump failed). "
    | operationDescription |

    operationDescription := 'object dumping'.
    self initializeForOperationOn: aStream.
    objectVersion := self currentVersion.

    " enumerate the contents of anObject to determine
        all the objects and behaviors to dump "
    self allocateDumpCollections.
    numBehaviors := 0.
    numObjects := 0.
    self log: anObject.
    operationAborted
        ifTrue: [
            self recordSummaryMessage: operationDescription.
            ^nil].

   " write out the binary description of anObject "
    self
        dumpHeader: anObject;        " <header section> "
        dumpBehaviorDescriptors;    " <behavior descriptors section> "
        dumpObjectDescriptors;        " <object descriptors section> "
        dumpSoftSlots.                     " <object soft slots section> "

    self recordSummaryMessage: operationDescription.
    ^anObject
! 
allocateSmallIdentityDictionary
        " Private - answer a new identity dictionary
        which is expected to hold a relatively small
        number of elements. "
    ^self class defaultDictionaryClass new: 127!  
lastObjectId
        " Private - answer the last id in the filed id name
        space which is used by an object in the dump. "
    ^self lastBehaviorId + numObjects!
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
describeBehaviorsSummary
        " Private - Read the <behavior descriptors section>
        to find referenced classes and MetaClasses.
        Dump in class name order (not file order). "

    | numEntries versionHasBindingInformation classInfo
      tag classId name rep
      numNamedInstVars instVarNames aFileName
      reportDict |

    " set up pseudo-classId entries for self-contained object descriptors "
    behaviors
        at: ClassIdSymbol
        put: (Association key: 'Symbol' value: RepVariableBytes).
    behaviors
        at: ClassIdDBSymbol
        put: (Association key: 'DoubleByteSymbol' value: RepVariableBytes).
    objects at: ClassIdSymbol put: (Array new: 0).  " no named inst vars "
    objects at: ClassIdDBSymbol put: (Array new: 0).

    " read unordered entries "
    numEntries := 0.
    versionHasBindingInformation := self class versionHasBindingInformation: objectVersion.
    classInfo := Array new: (behaviors size).
    reportDict := Dictionary new.
    [(tag := objectStream next) ~= NUL] whileTrue: [
        numEntries := numEntries + 1.
        classId := objectStream getInteger.
        name := objectStream upTo: NUL.
        rep := objectStream next.
        numNamedInstVars := objectStream getInteger.
        instVarNames := Array new: numNamedInstVars.
        1 to: numNamedInstVars do: [ :i |
            instVarNames at: i put: (objectStream upTo: NUL)].
        aFileName := ( versionHasBindingInformation
            ifTrue: [ objectStream upTo: NUL ]
            ifFalse: [ nil ] ).
        classInfo at: classId put:
            (Association key: tag value: aFileName).
        behaviors
            at: classId
            put: (Association key: name value: rep).
        objects at: classId put: instVarNames.
        reportDict
            at: ((tag = TagClass)
                ifTrue: [name]
                ifFalse: [name, ' class'])
            put: classId.
        ].

    " report in alphabetical order "
    reportDict keys asSortedCollection do: [ :className |
        classId := reportDict at: className.
        tag := (classInfo at: classId) key.
        rep := (behaviors at: classId) value.
        instVarNames := objects at: classId.
        numNamedInstVars := instVarNames size.
        textStream nextPutAll: className.
        (tag = TagClass)
            ifTrue: [
                textStream nextPutAll:
                    ' (', (self repDescription: rep), ', ',
                    ((numNamedInstVars = 0)
                        ifTrue: ['no']
                        ifFalse: [numNamedInstVars printString]),
                    ' named instance variables)'].
        textStream cr.
        aFileName := (classInfo at: classId) value.
        aFileName size > 0  " not supported or base system DLL "
            ifTrue: [textStream nextPutAll:
                '        (bind ', aFileName,
                ' if not found in loading image)'; cr].
        ((tag = TagClass) and: [numNamedInstVars > 0])
            ifTrue: [
                1 to: numNamedInstVars do: [ :i |
                    textStream nextPutAll:
                        '    ', i printString,
                        ' - ', (instVarNames at: i); cr]].
        ].   " processing behavior entries "! 
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

    | operationDescription initialPosition rootObjectId |

    operationDescription := 'object loading'.
    self initializeForOperationOn: aStream.
    initialPosition := objectStream position.  " for failure backout "

    " read the <header section> "
    rootObjectId := self loadHeader: 'load'
        acceptVersionAction: [ :filedVersion |
            self class versionCanBeLoaded: filedVersion ].
    rootObjectId isNil
        ifTrue: [
            objectStream position: initialPosition.  " back out "
            self recordSummaryMessage: operationDescription.
            ^nil ].
    self allocateLoadCollections.

    " remappedObjects maps slot-shuffled objects to source info
        when loading blocks only valid during the load operation "
    remappedObjects := nil.
    ( self loadBehaviorDescriptors: loadMaps )
        ifFalse: [   " unable to satisify class bindings in load environment "
            objectStream position: initialPosition.  " back out "
            self recordSummaryMessage: operationDescription.
            ^nil ].
    self
        loadObjectDescriptors;
        restoreInstanceVariables.
    self isLoadingCurrentVersion
        ifFalse: [ self upgradeFromPreviousVersion: rootObjectId ].
    self 
        restoreLoadedObjects: rootObjectId;
        loadSoftSlots.
    remappedObjects := nil.

    self recordSummaryMessage: operationDescription.
    ^operationAborted
        ifTrue: [ nil ]
        ifFalse: [ rootObjectId < idCharacterZero
            ifTrue: [ objects at: rootObjectId ]
            ifFalse: [ self computedObjectFromId: rootObjectId ] ]!  
loadInstVarIds: skeletonObject mapping: aChangeMap size: size
        " Private - Read pointer <values> of an <object descriptor>
        and stash the ids in the instance variables of skeletonObject.
        An instVarMap may be supplied to reorder the named instVars;
        it will always be provided when the load class is a different
        size than was the dump class. "
    | class filedSize filedValues instVarLoadMap filedIndex |

    class := skeletonObject class.

    " load named instance variables "
    aChangeMap isNil
        ifTrue: [  " no size change and no reordering of named instance variables "
            1 to: class instSize do: [ :i |
                skeletonObject instVarAt: i put: (objectStream getInteger)]]
        ifFalse: [  " reordering inst vars or changing class size "
            filedSize := aChangeMap sourceSize.
            instVarLoadMap := aChangeMap slotIndexArray.
            "ASSERT [instVarLoadMap size = class instSize]."
            " read all the filed values "
            filedValues := Array new: filedSize.
            1 to: filedSize do: [ :i |
                filedValues at: i put: (objectStream getInteger)].
            " load slots in skeleton, using filed values per user mapping "
            1 to: class instSize do: [ :i |
                filedIndex := instVarLoadMap at: i.
                skeletonObject instVarAt: i put:
                    ((filedIndex isNil)
                        ifTrue: [IdNil]
                        ifFalse: [filedValues at: filedIndex])].
            remappedObjects notNil
                ifTrue: [remappedObjects at: skeletonObject
                                put: aChangeMap].
            ].

    " load indexed instance variables "
    (size > 0) ifTrue: [
        (class isVariable) ifTrue: [
            1 to: size do: [ :i |
                skeletonObject basicAt: i put: (objectStream getInteger)]]
        ifFalse: [  " drop filed indexed values on the floor "
            1 to: size do: [ :i | objectStream getInteger]]].!
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
            self messageStream
                nextPutAll: prefix;
                nextPutAll: message; cr ].!  
describeSize: initialPosition
        " Private - describe the size of the filed object. "
    textStream
        cr;
        nextPutAll:
            'Filed object size = ', (((objectStream position) - initialPosition) printString),
            ' bytes'; cr;
        cr.!
isTerminalObject: anObject
        " Private - answer whether anObject is a terminal
        object with a special id. "

    ^( TerminalClasses includes: anObject class )
        or: [ ( anObject isCharacter and: [ anObject isSingleByte ] )
        or: [ anObject isObjectReference
                and: [ ReservedIdMap keys includes: anObject ] ] ]! 
lastPredefinedId
        " Private - answer the last id in the filed id name
        space which is reserved for a predefined special object. "
    ^NumPredefinedIds! 
isLoadingCurrentVersion
        " Answer whether the object being loaded
        is from a file written by the currrent version
        of the ObjectFiler. "

    ^self objectVersion = self currentVersion!
repOf: class
        " Private - answer representation of class "
    ^(class isPointers)
        ifTrue: [(class isVariable)
            ifTrue: [RepVariablePointers]
            ifFalse: [RepFixedPointers]]
        ifFalse: [RepVariableBytes]!   
allocateDumpIdentityDictionary
        " Private - answer a new identity dictionary
        which is expected to hold a relatively large
        number of elements for an object dump operation. "
    ^clientAllocateDictionaryAction notNil
        ifTrue: [clientAllocateDictionaryAction evaluate]
        ifFalse: [self class defaultDictionaryClass new: 1021]!
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
                        nextPutAll: ' aborted *****' ].
            messageCounts := messageStream := nil.
            ].! 
describeHeader: rootObjectId
        " Private - write header information description
       and a detailed report on the id name space "

    textStream
        nextPutAll:
            'Number of behavior entries = ', numBehaviors printString; cr;
        nextPutAll:
            'Number of object entries = ', numObjects printString; cr;
        nextPutAll: 'Root object id = ', rootObjectId printString.

    " special case: add description of non-filed root object "
    rootObjectId <= self lastPredefinedId
        ifTrue: [
            textStream nextPutAll:
                ' => ', ( ReservedIdDescriptions at: rootObjectId ) ].
    rootObjectId > self lastObjectId
        ifTrue: [
            textStream nextPutAll:
                ' => ',
                ( self computedObjectDescription:
                    ( self computedObjectFromId: rootObjectId ) ) ].
    textStream cr; cr.

    " describe the id ranges  "
    textStream nextPutAll:
            'Dump id name space:'; cr.
    1 to: self lastPredefinedId do: [ :i |
        textStream nextPutAll:
            '    ', i printString, ' = ',
            ( ReservedIdDescriptions at: i ); cr ].
    numBehaviors > 0
        ifTrue: [
            textStream nextPutAll:
                '    ', '[', self firstBehaviorId printString,
                '..', self lastBehaviorId printString,
                '] = behavior ids'; cr ].
   numObjects > 0
        ifTrue: [
            textStream nextPutAll:
                '    ', '[', self firstObjectId printString,
                '..', self lastObjectId printString,
                '] = object ids'; cr ].
    textStream
        nextPutAll:
            '    [', idCharacterZero printString, '..',
            (idCharacterZero + 255) printString,
            '] = Character codes [0..255]'; cr;
        nextPutAll:
            '    ', idIntegerZero printString, '.. = Integer values (0, 1, -1, 2, -2, ...)'; cr.! 
dumpHeader: rootObject
        " Private - write the <header section>. "

    " assign the tail end of the filed id name space "
    self assignComputedIds.

     " <seal> <version> <num behaviors> <num objects> <root object id> <NUL> "
    objectStream
        nextPut: Seal;
        putInteger: objectVersion;
        putInteger: behaviors size;
        putInteger: numObjects;
        putInteger: (self dumpIdOf: rootObject);
        nextPut: NUL.!  
loadClassFor: name
    rep: rep
    filedInstVarNames: filedInstVarNames
    componentName: libraryName
    changeMap: predefinedChangeMap
    isMetaClass: isMetaClass
        " Private - determine the class into which to load
        filed instances of class <name>.  Do shape and
        representation checking.  Attempt to bind
        <libraryName> if provided and class <name>
        is not available.  Answer an array with the load class
        and the change map, if any, if the class can be loaded.
        Answer nil if name can't be loaded. "

    | behavior loadName loadRep loadInstVarNames
      aChangeMap aFileName loadDescription userCancelled |

    aChangeMap := predefinedChangeMap.

    " determine the class to load into "
    aChangeMap notNil
        ifTrue: [    " programmatic specification overrides I/A interface "
            loadName := aChangeMap destinationClassName.
            ( self getClassNamed: loadName ) isClass
                ifFalse: [   " programming error if change map is incorrect "
                    self recordAbortMessage:
                        self warningLoadCancelled,
                        ' - class ', loadName, ' not found in this system',
                        ' (specified by load map as new class of filed ',
                        name, ' instances).'.
                    ^nil ].
            ]
        ifFalse: [  " attempt to resolve missing class "
            loadName := name.
            ( libraryName size > 0
            and: [ self useBindingInformation
            and: [ ( self getClassNamed: loadName ) isClass not ] ] )
                ifTrue: [  " automatically bind component to locate class "
                    self bindLibrary: libraryName
                        toFindClass: loadName.
                    ].
            [ ( self getClassNamed: loadName ) isClass ]
                whileFalse: [
                    self clearMouseCapture.
                    SessionModel current isRunTime
                        ifTrue: [
                            aFileName := Prompter
                                title: 'Missing class ', name
                                prompt: 'Enter library name to bind:'
                                default: 'unknown', SmalltalkLibrary fileExtension asLowerCase.
                            userCancelled := aFileName isNil.
                            aFileName size > 0
                                ifTrue: [
                                    self bindLibrary: aFileName
                                        toFindClass: loadName ].
                            ]
                        ifFalse: [
                            loadName := Prompter
                                title: 'Missing class ', name
                                prompt: 'Enter new class name:'
                                default: loadName.
                            userCancelled := loadName isNil ].
                    userCancelled
                        ifTrue: [
                            self recordWarningMessage:
                                self warningLoadCancelled,
                                ' - class ', name, ' not found in this system.'.
                            ^nil ].
                    ].
            ].

    behavior := self getClassNamed: loadName.
    behavior isClass
        ifFalse: [
            self recordWarningMessage:
                self warningLoadCancelled,
                ' - class ', name, ' is not a class in this system.'.
            ^nil ].
    isMetaClass  " no further checking needed "
        ifTrue: [ ^Array with: behavior class with: nil ].

    " check for representation mismatch "
    loadRep := self repOf: behavior.
    ( self rep: rep canBeLoadedInto: loadRep filedClass: name )
        ifFalse: [
            self recordWarningMessage:
                self warningLoadCancelled,
                ' -  cannot load filed ',
                ( self repDescription: rep ), ' class ', name,
                ' into ', ( self repDescription: loadRep ), ' class ', loadName.
            ^nil ].

    " build load map for shape change or per loadMapsDict "
    loadInstVarNames := behavior allInstVarNames.
    aChangeMap notNil
        ifTrue: [  " validate the prespecified load map "
            ( self
                    loadMapIsValid: aChangeMap
                    sourceVariables: filedInstVarNames
                    destinationVariables: loadInstVarNames )
                ifFalse: [  " invalid mapping "
                    self recordWarningMessage:
                         self warningLoadCancelled,
                         ' - load map supplied for changed class ',
                         name, ' is unusable.'.
                    ^nil ] ]
        ifFalse: [   " check for shape changes "
            ( ( filedInstVarNames size ~= behavior instSize )
            or: [ filedInstVarNames ~= loadInstVarNames ] )
                ifTrue: [
                    " need to get mapping for shape change "
                    loadDescription := 'Loading class ', name.
                    loadName ~= name
                        ifTrue: [ loadDescription := loadDescription, ' into ', loadName ].
                    self clearMouseCapture.
                    aChangeMap := ObjectLoadDialog new
                        openOn: ( ObjectChangeMap new
                            sourceClassName: name;
                            destinationClassName: loadName;
                            sourceVariables: filedInstVarNames;
                            destinationVariables: loadInstVarNames;
                            yourself )
                        sourceTitle: 'Filed:'
                        destinationTitle: 'Loading:'
                        description: loadDescription.
                    aChangeMap isNil
                        ifTrue: [  " user cancelled "
                            self recordWarningMessage:
                                 self warningLoadCancelled,
                                 ' - instance variable remapping for changed class ',
                                 name, ' cancelled.'.
                            ^nil ].
                    ]
                ifFalse: [  " no shape change or mapping override "
                    aChangeMap := nil ].
                ].
    ( aChangeMap notNil
    and: [ aChangeMap layoutIsChanging not ] )
        ifTrue: [ aChangeMap := nil ].  " got what we needed from it "
    ^Array with: behavior with: aChangeMap!
log: anObject
        " Private - Ensure anObject is in one of the two dictionaries,
        (behaviors or objects).  Recurse to log anObject's
        class and instance variables.  Answer the filed object id
        assigned to anObject (nil for terminal objects). "

    | loggedObjectAssoc class surrogate relativeId |

    " behaviors entry maps behavior to its dump id. "
    anObject isBehavior
        ifTrue: [
            ( anObject == MetaClass )
                ifTrue: [ ^nil ].  " in TerminalClasses "
            ( behaviors includesKey: anObject )
                ifFalse: [
                    numBehaviors := numBehaviors + 1.
                    behaviors at: anObject
                        put: ( self lastPredefinedId + numBehaviors ) ].
            ^numBehaviors ].

    " objects entry maps non-terminal object to its
        relative object number [1..n] and surrogate "
    ( self isTerminalObject: anObject )
        ifTrue: [ ^nil ].
    ( loggedObjectAssoc := objects at: anObject ifAbsent: [ nil ] ) notNil
        ifTrue: [ ^loggedObjectAssoc key ].

    " allow object to sanitize its contents or transform itself if desired "
    surrogate := anObject fileOutSurrogate: self.
    operationAborted ifTrue: [ ^nil ].
    class := surrogate class.

    ( self isTerminalObject: surrogate )
        ifTrue: [
            relativeId := nil ]
        ifFalse: [
            " log object's class in behaviors if not a self-describing <object descriptor> "
            surrogate isSymbol
                ifFalse: [ self log: class ].
            numObjects := numObjects + 1.
            relativeId := numObjects ].

    " log the object itself "
    objects
        at: anObject
        put: ( Association key: relativeId value: surrogate ).
    relativeId isNil ifTrue: [ ^relativeId ].

    " log each named instance variable and any indexed inst vars "
    class isPointers
        ifTrue: [
            1 to: ( class instSize + surrogate basicSize ) do: [ :i |
                self log: ( surrogate instVarAt: i ) ] ].
    self logSoftSlots: anObject id: relativeId.
    ^relativeId
!
lastBehaviorId
        " Private - answer the last id in the filed id name
        space which is used by a Behavior. "
    ^self lastPredefinedId + numBehaviors! 
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
    | allLoadMaps changeMap loadMapsDict |

    allLoadMaps := OrderedCollection new.
    allLoadMaps
        addAll: (self class standardLoadMapsFor: objectVersion).
    (loadMaps isKindOf: Dictionary)
        ifTrue: [  " compatibility upgrade from old format "
            loadMaps associationsDo: [ :assoc |
                changeMap := ObjectChangeMap new
                    sourceClassName: assoc key;
                    destinationClassName: assoc value key;
                    yourself.
                assoc value value do: [ :assoc2 |
                    changeMap set: assoc2 key from: assoc2 value].
                allLoadMaps add: changeMap].
            ]
        ifFalse: [allLoadMaps addAll: loadMaps].

    loadMapsDict := Dictionary new.
    allLoadMaps do: [ :aChangeMap |
        loadMapsDict
            at: aChangeMap sourceClassName
            put: aChangeMap deepCopy].
    ^loadMapsDict!   
releaseEventTable
        "Private - break all connections to event handlers."

    eventTable := nil.!
describeObjectDescriptors
        " Private - Read the <object descriptors section> "
    | numEntries objectId classId size basicHash
      classInfo values entryInfo
      numNamedVars instVarNames |

    numEntries := 0.
    [(objectId := objectStream getInteger) ~= IdNUL] whileTrue: [
        numEntries := numEntries + 1.
        classId := objectStream getInteger.
        size := objectStream getInteger.
        basicHash := objectStream getInteger.
        classInfo := behaviors at: classId.
        (classInfo value = RepVariableBytes) ifTrue: [
            values :=
                ((classInfo key = 'DoubleByteString')
                or: [classInfo key = 'DoubleByteSymbol'])
                    ifTrue: [(Smalltalk at: #DoubleByteString) basicNew: size]
                    ifFalse: [String new: size].
                    " leave symbols as strings for report "
            objectStream getBytesFor: values]
        ifFalse: [
            values := Array new: (((objects at: classId) size) + size).
            1 to: values size do: [ :i |
                values at: i put: (objectStream getInteger)]].
        objects at: objectId put:
            (Array with: classId with: size with: basicHash with: values).
        ].  " processing object description entry "

    " dump objects in id order (not filed order) "
    textStream cr; nextPutAll: 'Object descriptors section (id = object entry)'; cr.
    (behaviors size + 1) to: (objects size) do: [ :anObjectId |
        entryInfo := objects at: anObjectId.
        classId := entryInfo at: 1.
        size := entryInfo at: 2.
        basicHash := entryInfo at: 3.
        values := entryInfo at: 4.
        textStream nextPutAll: (anObjectId printString), ' = '.
        ((classId = ClassIdSymbol) or: [classId = ClassIdDBSymbol])
        ifTrue: [   "symbols were read in as strings"
            textStream nextPutAll:
                '#', values, ' (basicHash = ', basicHash printString, ')'; cr]
        ifFalse: [
            textStream nextPutAll:
                ((behaviors at: classId) key),
                ' instance (basicHash = ', basicHash printString, ')'; cr.
            ((behaviors at: classId) value = RepVariableBytes) ifTrue: [
                textStream nextPutAll:
                    '    ', 'bytes(', size printString, '): ',
                    values; cr]
            ifFalse: [
                instVarNames := objects at: classId.
                numNamedVars := instVarNames size.
                " named instance variables "
                1 to: numNamedVars do: [ :i |
                    textStream nextPutAll:
                        '    ', (instVarNames at: i), ': ',
                        (self describeId: (values at: i)); cr].
                " indexed instance variables "
                1 to: size do: [ :i |
                    textStream nextPutAll:
                        '    ', i printString, ': ',
                        (self describeId: (values at: (numNamedVars + i))); cr]]].
        ].
    textStream
        nextPutAll: '(', numEntries printString, ' object descriptor entries)'; cr.
    "ASSERT [numEntries = numObjects]."!
allocateLoadCollections
        " Private - allocate the objects and behaviors
        collections for an object load operation. "

    | aSpecialObject |

    " objects is indexed by the dump ID of a behavior or object entry.
        For a behavior, contains loading system's behavior object.
        For an object, contains the restored object. "
    objects := Array new: self lastObjectId.
    objects at: IdNil put: nil.
    ReservedIdMap associationsDo: [ :anAssociation |
        aSpecialObject := anAssociation key.
        aSpecialObject isObjectReference
            ifTrue: [ aSpecialObject := aSpecialObject copy resolve ].
        objects at: anAssociation value put: aSpecialObject ].

    " behaviors is indexed by the dump ID of a behavior entry.
        For a behavior, contains an instVar mapping for size/shape changes. "
    behaviors := Array new: self lastBehaviorId.

	" record the names of any libraries bound during loading "
    libraryDependencies := OrderedCollection new.!   
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
currentVersion
        " Answer the currrent version of the object file format. "

    ^self class currentVersion! 
dumpObjectDescriptors
        " Private - Write the <object descriptors section> of the object dump "
    | lastBehaviorId relativeId objectId object class classId |

    " Write an <object descriptor> for each (surrogate) object:
        <object id> <class id> <number of indexed instance variables>
            <basicHash> <bytesOrPointers>
      "
    lastBehaviorId := self lastBehaviorId.
    objects do: [ :assoc |  " ignore original object, only need surrogate "
        relativeId := assoc key.
        relativeId notNil ifTrue: [   " ignore terminal surrogates "
        objectId := lastBehaviorId + relativeId.  " last behavior id + relative object id "
        object := assoc value.   " surrogate "
        class := object class.
        classId :=
            object isSymbol
                ifTrue: [(class == DoubleByteSymbol)
                    ifTrue: [ClassIdDBSymbol]
                    ifFalse: [ClassIdSymbol]]
                ifFalse: [self dumpIdOf: class].
            " We can play games with symbol class ids because
                we know class ids start at NumPredefinedIds + 1 "
        objectStream
            putInteger: objectId;
            putInteger: classId;
            putInteger: object basicSize;
            putInteger: object basicHash.
        (class isBytes) ifTrue: [
            objectStream putBytesFrom: object]
        ifFalse: [   " pointers "
            1 to: (class instSize + object basicSize) do: [ :i |
                objectStream
                    putInteger: (self dumpIdOf: (object instVarAt: i))]].
        ]].

    objectStream nextPut: NUL.  " section terminator "!
loadFrom: aStream
        " Answer the object encoded on aStream at
        aStream's current position. "
   ^self loadFrom: aStream loadMaps: #()!
restoreLoadedObjects: rootObjectId
        " Private - restore objects which need special initialization.
        Allow activation to transform the identity of the restored object. "

    | firstObjectId lastObjectId objectsUpdateList
      loadedObject activatedObject |

    firstObjectId := self firstObjectId.
    lastObjectId := objects size.
    objectTransformationMap := self allocateSmallIdentityDictionary.
    objectsUpdateList := OrderedCollection new.

    " restore in bottom-up order (ids were assigned top-down in object graph) "
    lastObjectId to: firstObjectId by: -1 do: [ :objectId |
        loadedObject := objects at: objectId.
        activatedObject := loadedObject fileInActivate: self.
        activatedObject ~~ loadedObject
            ifTrue: [
                objectTransformationMap at: loadedObject put: activatedObject.
                objectsUpdateList add:
                    ( Array with: objectId with: activatedObject ).
                ].
        operationAborted ifTrue: [ ^nil ] ].
    self resetObjectsAfterMutationCycle: objectsUpdateList rootObjectId: rootObjectId.

    objectTransformationMap := self allocateSmallIdentityDictionary.
    self triggerEvent: #loaded.
    self resetObjectsAfterMutationCycle: #() rootObjectId: rootObjectId.!   
clientAllocateDictionaryAction: anAction
        " Register a zero-argument action which when evaluated
        answers an empty identity dictionary to use for an
        object dump operation. "
    clientAllocateDictionaryAction := anAction.!  
describeId: id
        " Private - Answer a description of the object referenced by id."

    | classId className description stringValue |

    " predefined names which aren't actually filed "
    id <= self lastPredefinedId
        ifTrue: [ ^ReservedIdDescriptions at: id ].

    " dynamically assigned behavior and object dump ids "
    id <= self lastBehaviorId
        ifTrue: [
            ^( ( behaviors at: id ) value = NUL  " no rep info for metaclass "
                ifTrue: [ 'MetaClass ' ]
                ifFalse: [ 'Class ' ] ),
            ( behaviors at: id ) key ].
   id < idCharacterZero
        ifTrue: [
            classId := ( objects at: id ) at: 1.
            className := ( behaviors at: classId ) key.
            description := className, ' instance ', id printString.
            ( classId = ClassIdSymbol or: [ classId = ClassIdDBSymbol ] )
                ifTrue: [ ^'#', ( ( objects at: id ) at: 4 ), ' (', description, ')' ].
            ( ( #( 'String' 'DoubleByteString' ) includes: className )
            and: [ ( stringValue := ( ( objects at: id ) at: 4 ) ) size <= 30 ] )
                ifTrue: [ ^stringValue printString, ' (', description, ')' ].
            ^description ].

    " computable objects at the end of the dump name space (Character, Integer) "
    ^self computedObjectDescription: ( self computedObjectFromId: id ).!
dumpIdOf: anObject
        " Private - Answer the dump id of anObject in the objectStream."

    | objectsEntry id relativeId |

    " predefined identifiers at the beginning of the dump id name space "
    anObject isNil ifTrue: [ ^IdNil ].
    id := ReservedIdMap at: anObject ifAbsent: [ nil ].
    id notNil ifTrue: [ ^id ].
    anObject == MetaClass ifTrue: [ ^self class idMetaClass ].

    " dynamically assigned behavior id "
    anObject isBehavior ifTrue: [ ^behaviors at: anObject ].

    " computed ids of immutable objects at the end of the name space "
    anObject isCharacter
        ifTrue: [
            ( ( anObject respondsTo: #isSingleByte ) not
            or: [ anObject isSingleByte ] )
                ifTrue: [ ^idCharacterZero + anObject asciiValue ] ].  "single-byte char"
        "ifFalse: [ double-byte character with dynamic id ]"
    anObject isInteger
        ifTrue: [
            ^idIntegerZero
                + ( anObject positive  " use low-order bit for sign "
                    ifTrue: [ anObject * 2 ]   " even id for positive "
                    ifFalse: [ anObject negated * 2 + 1 ] ) ].  " odd id for negative "

    " objects with dynamically assigned ids "
    objectsEntry := objects at: anObject ifAbsent: [ nil ].
    objectsEntry isNil
        ifTrue: [ ^IdNil ].
    relativeId := objectsEntry key.
    relativeId isNil
        ifTrue: [ ^self dumpIdOf: objectsEntry value ].  " terminal surrogate "
    ^self lastBehaviorId + relativeId!  
objectVersion
        " Answer the filed version of the object
        currently being loaded or dumped. "
    ^objectVersion! 
computedObjectFromId: objectId
        " Private - answer the object described by the given
        computed dump id (Character or Integer at the end of
        the dump name space) "
    | integerId |
    ^(objectId < idIntegerZero)
        ifTrue: [
            (objectId - idCharacterZero) asCharacter]
        ifFalse: [
            (integerId := objectId - idIntegerZero) odd
                ifTrue: [(integerId // 2) negated]  " odd is negative "
                ifFalse: [integerId // 2]].  " even is positive "!
describeObjectsSummary
        " Private - Read the <object descriptors section>.
        Don't describe any of them in the summary report.  "
    | objectId classId size basicHash classInfo
      values summaryDict numInstances total count |

    numInstances := Array new: behaviors size.
    numInstances atAllPut: 0.

    [(objectId := objectStream getInteger) ~= IdNUL] whileTrue: [
        classId := objectStream getInteger.
        size := objectStream getInteger.
        basicHash := objectStream getInteger.
        classInfo := behaviors at: classId.
        (classInfo value = RepVariableBytes) ifTrue: [
            values :=
                ((classInfo key = 'DoubleByteString')
                or: [classInfo key = 'DoubleByteSymbol'])
                    ifTrue: [(Smalltalk at: #DoubleByteString) basicNew: size]
                    ifFalse: [String new: size].
                    " leave symbols as strings for report "
            objectStream getBytesFor: values]
        ifFalse: [
            values := Array new: (((objects at: classId) size) + size).
            1 to: values size do: [ :i |
                values at: i put: (objectStream getInteger)]].
        numInstances at: classId
            put: ((numInstances at: classId) + 1).
        ].  " processing object description entry "

    " report instance counts "
    textStream cr; nextPutAll: 'Object counts by class:'; cr.
    summaryDict := Dictionary new.
    1 to: behaviors size do: [ :i |
        ((classInfo := behaviors at: i) notNil
        and: [(classInfo value ~= NUL)  " skip metaclasses "
        and: [(count := numInstances at: i) > 0]])
            ifTrue: [summaryDict at: classInfo key put: count]].
    total := 0.
    summaryDict keys asSortedCollection do: [ :className |
        count := summaryDict at: className.
        textStream nextPutAll:
            className, ': ', count printString,
            ((count = 1) ifTrue: [' instance'] ifFalse: [' instances']);
            cr.
        total := total + count].
    textStream nextPutAll: total printString, ' objects'; cr.!
dumpSoftSlots
        " Private - write the <object soft slots section> of the object file. "

        " The soft slots section format is:
            <soft slot type count>
            [ <soft slot values list> ]...
            NUL
        where each type of soft slot has an entry containing the set selector
        for that soft slot and a list of the id pairs containing the id of the
        object with the soft slot value and the filed id of its value:
            <set selector>
            [ <object id> <soft slot value id> ]...
            NUL
        "

    | lastBehaviorId idPairList |

    ( self class versionHasSoftSlots: objectVersion )
        ifFalse: [ ^self ].

    lastBehaviorId := self lastBehaviorId.

    objectStream putInteger: softSlotValues size.
    softSlotValues keys asSortedCollection do: [ :setSelector |
        idPairList := softSlotValues at: setSelector.
        objectStream nextPutAll: setSelector; nextPut: NUL.
        idPairList do: [ :arr |
            objectStream
                putInteger: lastBehaviorId + ( arr at: 1 );
                putInteger: lastBehaviorId + ( arr at: 2 ) ].
        objectStream nextPut: NUL.  " list terminator "
        ].
    objectStream nextPut: NUL.  " section terminator "
!  
firstObjectId
        " Private - answer the first id in the filed id name
        space which is used by an object in the dump. "
    ^self lastBehaviorId + 1!   
clientContext
        " Answer the client context associated with
        the current dump or load operation.
        Can be accessed in fileInSurrogate: and
         fileOutActivate: methods to provide
         context-dependent behavior. "
    ^clientContext!   
clientContext: anObject
        " Store anObject on behalf of the client.
        The client context can be accessed in
        fileOutSurrogate: and fileInActivate: methods
        to allow context-dependent behavior. "
    clientContext := anObject!  
initialize
        " Private - initialize a new instance "

    self useBindingInformation: true.! 
libraryNameOf: behavior
        " Private "

    | libraryName |
    ( libraryMappings notNil
    and: [ ( libraryName := libraryMappings at: behavior ifAbsent: [ nil ]) notNil ] )
        ifTrue: [ ^libraryName "fileNameLessPath fileName" ].
    ^( behavior isInLibrary and: [ behavior isInBase not ] )
        ifTrue: [ behavior smalltalkLibraryName "fileNameLessPath fileName" ]
        ifFalse: [ '' ]!   
loadObjectDescriptors
        " Private - Read the <object descriptors section> of the file.
        For each <object descriptor>, put the byte-date object
        or a pointer skeleton whose slots contain dump ids
        in the object list at its dump id. "
    | objectId classId size basicHash class anObject |

    [(objectId := objectStream getInteger) ~= IdNUL] whileTrue: [
        classId := objectStream getInteger.
        size := objectStream getInteger.
        basicHash := objectStream getInteger.
        ((classId = ClassIdSymbol) or: [classId = ClassIdDBSymbol]) ifTrue: [
            anObject := (classId = ClassIdSymbol)
                ifTrue: [String new: size]
                ifFalse: [(Smalltalk at: #DoubleByteString) basicNew: size].
            objectStream getBytesFor: anObject.
            anObject := anObject asSymbol]
        ifFalse: [
            class := objects at: classId.
            anObject := self new: class size: size.
            anObject basicHash: basicHash.
            (class isBytes)
                ifTrue: [objectStream getBytesFor: anObject]
                ifFalse: [self
                    loadInstVarIds: anObject
                    mapping: (behaviors at: classId)
                    size: size]].
        objects at: objectId put: anObject].!  
loadSoftSlots
        " Private - read the <object soft slots section> of the object file
        and restore the object soft slot values. "

    | count setSelector objectId softSlotValueId |

    ( self class versionHasSoftSlots: objectVersion )
        ifFalse: [ ^self ].

    count := objectStream getInteger.
    count timesRepeat: [
        setSelector := ( objectStream upTo: NUL ) asSymbol.
        [ ( objectId := objectStream getInteger) ~= IdNUL ] whileTrue: [
            softSlotValueId := objectStream getInteger.
            ( objects at: objectId ) perform: setSelector
                with: ( objects at: softSlotValueId ).
            ].
        ].
    objectStream next.   " section terminator "
!  
allocateDescribeCollections: lastObjectId
        " Private - allocate the objects and behaviors
        collections for an object description operation. "

    " objects is indexed by the dump ID of a behavior or object entry.
        For a behavior, records instance variable names.
        For an object, records the class id. "
    objects := Array new: lastObjectId.

    " behaviors is indexed by a behavior dump ID and contains the
        class name and representation "
    behaviors := Array new: self lastBehaviorId.!   
recordWarningMessage: aString
        " Notify the user that a non-fatal error has occurred.
        Usually indicates the dumping or loading of
        an object that should be bound but won't be."
    self recordMessage: aString type: 'warning' prefix: 'Warning: '.!  
rep: filedRep canBeLoadedInto: loadRep filedClass: className
        " Private - answer whether filed class can be loaded into
        class with loadRep representation "
    (filedRep = loadRep)
        ifTrue: [^true].
    ((filedRep = RepVariableBytes) | (loadRep = RepVariableBytes))
        ifTrue: [^false].  " can't load into bytes into pointers or vice-versa "
    " pointers can be either indexed or fixed on either side "
    (filedRep = RepVariablePointers) "& (loadRep = RepFixedPointers)"
        ifTrue: [self recordWarningMessage:
                'Indexed instance variables of class ', className,
                ' dropped (loaded into non-indexed class)'].
    ^true!  
describeBehaviorDescriptors
        " Private - Read the <behavior descriptors section>
        to find referenced classes and MetaClasses.
        Dump in id order (not file order). "

    | numEntries versionHasBindingInformation classInfo
      tag classId name rep
      numNamedInstVars instVarNames aFileName |

    " set up pseudo-classId entries for self-contained object descriptors "
    behaviors
        at: ClassIdSymbol
        put: (Association key: 'Symbol' value: RepVariableBytes).
    behaviors
        at: ClassIdDBSymbol
        put: (Association key: 'DoubleByteSymbol' value: RepVariableBytes).
    objects at: ClassIdSymbol put: (Array new: 0).  " no named inst vars "
    objects at: ClassIdDBSymbol put: (Array new: 0).

    " read unordered entries "
    numEntries := 0.
    versionHasBindingInformation := self class versionHasBindingInformation: objectVersion.
    classInfo := Array new: (behaviors size).
    [(tag := objectStream next) ~= NUL] whileTrue: [
        numEntries := numEntries + 1.
        classId := objectStream getInteger.
        name := objectStream upTo: NUL.
        rep := objectStream next.
        numNamedInstVars := objectStream getInteger.
        instVarNames := Array new: numNamedInstVars.
        1 to: numNamedInstVars do: [ :i |
            instVarNames at: i put: (objectStream upTo: NUL)].
        aFileName := ( versionHasBindingInformation
            ifTrue: [ objectStream upTo: NUL]
            ifFalse: [ nil ] ).
        classInfo at: classId put:
            (Association key: tag value: aFileName).
        behaviors
            at: classId
            put: (Association key: name value: rep).
        objects at: classId put: instVarNames].

    " report in id order "
    textStream
        cr; nextPutAll: 'Behavior descriptors section (id = behavior entry)'; cr.
    self firstBehaviorId to: behaviors size do: [ :aClassId |
        name := (behaviors at: aClassId) key.
        rep := (behaviors at: aClassId) value.
        numNamedInstVars := (objects at: aClassId) size.
        textStream nextPutAll:
            (aClassId printString), ' = ',
            (((classInfo at: aClassId) key = TagClass)
                ifTrue: [
                    'Class ', name, ' (',
                    (self repDescription: rep), ', ',
                    ((numNamedInstVars = 0)
                        ifTrue: ['no'] ifFalse: [numNamedInstVars printString]),
                    ' named instance variables)']
                ifFalse: ['MetaClass ', name]);
            cr.
        aFileName := (classInfo at: aClassId) value.
        aFileName size > 0  " not supported or base system component "
            ifTrue: [textStream nextPutAll:
                '        (bind ', aFileName,
                ' if not found in loading image)'; cr].
        ].   " processing behavior entries "
    textStream
        nextPutAll: '(', numEntries printString, ' behavior descriptor entries)'; cr.
    "ASSERT [numEntries = numBehaviors]."!
upgradeFromPreviousVersion: rootObjectId
        " Private - an object is being loaded which was
        stored by a previous version of the system.
        Allow objects to upgrade themselves into the
        form expected by the current system. "

    | firstObjectId lastObjectId objectsUpdateList
      loadedObject upgradedObject |

    " hash changes were so drastic in 3.0 that these guys are all
         broken until rehashed, so fix before real upgraders are invoked "
    self restoreLoadedHashStructures: rootObjectId.

    firstObjectId := self firstObjectId.
    lastObjectId := objects size.
    objectTransformationMap := self allocateSmallIdentityDictionary.
    objectsUpdateList := OrderedCollection new.

    " upgrade in bottom-up order (ids were assigned top-down in object graph) "
    lastObjectId to: firstObjectId by: -1 do: [ :objectId |
        loadedObject := objects at: objectId.
        upgradedObject := loadedObject fileInUpgrade: self.
        upgradedObject ~~ loadedObject
            ifTrue: [
                objectTransformationMap at: loadedObject put: upgradedObject.
                objectsUpdateList add:
                    ( Array with: objectId with: upgradedObject ).
                ].
        operationAborted ifTrue: [ ^nil ] ].
    self resetObjectsAfterMutationCycle: objectsUpdateList rootObjectId: rootObjectId.

    objectTransformationMap := self allocateSmallIdentityDictionary.
    self triggerEvent: #upgraded.
    self resetObjectsAfterMutationCycle: #() rootObjectId: rootObjectId.! 
restoreLoadedHashStructures: rootObjectId
        " Private - restore hashed objects when there
        is a platform/version difference between the
        dumping system and this loading image. "

    | hashedClasses aClass firstObjectId lastObjectId objectsUpdateList
      loadedObject upgradedObject |

    " check classes list to see if any of the hashed classes
        were actually used in this object (faster for a large load) "
    hashedClasses := Set new.
    self firstBehaviorId to: self lastBehaviorId do: [ :i |
        aClass := objects at: i.
        ( aClass basicNew respondsTo: #fileInRehash: )
            ifTrue: [ hashedClasses add: aClass ] ].
    hashedClasses isEmpty
        ifTrue: [ ^self ].

    firstObjectId := self firstObjectId.
    lastObjectId := objects size.
    objectTransformationMap := self allocateSmallIdentityDictionary.
    objectsUpdateList := OrderedCollection new.

    " rehash in bottom-up order (ids were assigned top-down in object graph) "
    lastObjectId to: firstObjectId by: -1 do: [ :objectId |
        loadedObject := objects at: objectId.
        ( hashedClasses includes: loadedObject class )
            ifTrue: [
                upgradedObject := loadedObject fileInRehash: self.
                upgradedObject ~~ loadedObject
                    ifTrue: [
                        objectTransformationMap at: loadedObject put: upgradedObject.
                        objectsUpdateList add:
                            ( Array with: ( objects indexOf: loadedObject ) with: upgradedObject ).
                        ].
                    ].
        ].
    self resetObjectsAfterMutationCycle: objectsUpdateList rootObjectId: rootObjectId.

    objectTransformationMap := self allocateSmallIdentityDictionary.
    self triggerEvent: #rehashed.
    self resetObjectsAfterMutationCycle: #() rootObjectId: rootObjectId.!
assignComputedIds
        " Private - Assign the end of the dump id name space,
        given the last id assigned in the dynamic range
        (behaviors and objects) "
    idCharacterZero := self lastObjectId + 1.
    idIntegerZero := idCharacterZero + 256.! 
firstBehaviorId
        " Private - answer the first id in the filed id name
        space which is used by a Behavior. "
    ^self lastPredefinedId + 1!  
registerUpgradeMutationFrom: originalInstVarValue to: newInstVarValue
        " This message needs to be sent by certain kinds of upgraders
        when to notify the ObjectFiler of instance variable mutations. "

    objectTransformationMap at: originalInstVarValue put: newInstVarValue.! 
restoreInstanceVariables
        " Private - restore instance variables in the skeleton objects "
    | anObject aClass id |
    self firstObjectId to: objects size do: [ :objectId |
        anObject := objects at: objectId.
        aClass := anObject class.
        (aClass isPointers) ifTrue: [
            1 to: (aClass instSize + anObject basicSize) do: [ :i |
                id := anObject instVarAt: i.   " dump id "
                anObject instVarAt: i put:
                    ((id < idCharacterZero)
                        ifTrue: [objects at: id]  " predefined and dynamically assigned ids "
                        ifFalse: [self computedObjectFromId: id])]]]  " computed objects "!  
warningLoadCancelled
        " Answer the warning message prefix used
        in all warning messages about a load
        operation being cancelled by the user."
    ^'Object loading cancelled'!   
loadHeader: operation  acceptVersionAction: acceptVersionAction
        " Private - read the <header section> and set
        instance variables summarizing the contents.
        The acceptVersionAction is a one-argument action
        which answers whether the version is acceptable.
        Answer the rootObjectId (nil if unable). "
    | rootObjectId |

    objectStream atEnd
        ifTrue: [
            self recordWarningMessage: 'Empty stream'.
            ^nil ].

    (objectStream next ~= Seal)
        ifTrue: [
            self recordWarningMessage: 'Incorrect seal for filed object.'.
            ^nil ].

    objectVersion := objectStream getInteger.
    ( acceptVersionAction evaluateWithArguments: (Array with: objectVersion) )
        ifFalse: [
            self recordWarningMessage:
                'This ObjectFiler cannot ', operation,
                ' filed objects of version ', objectVersion printString, '.'.
            ^nil ].

    numBehaviors := objectStream getInteger.
    numObjects := objectStream getInteger.
    rootObjectId := objectStream getInteger.

    (objectStream next ~= NUL)
        ifTrue: [
            self recordWarningMessage:
                'File format error (bad header section).'.
            ^nil ].

    " assign the tail end of the filed id name space "
    self assignComputedIds.
    ^rootObjectId!   
computedObjectDescription: computedObject
        " Private - answer a description of a predefined/computed object "
    ^computedObject isCharacter
        ifTrue: [
            (computedObject printString),
                ' (Character code ', (computedObject asciiValue printString), ')']
        ifFalse: [
            computedObject printString, ' (Integer)']!  
describeClassesFrom: srcStream to: dstStream
        " Describe the classes in the filed object on
        srcStream in a text report on dstStream. "
    | operationDescription initialPosition rootObjectId |

    operationDescription := 'summary object report'.
    self initializeForOperationOn: srcStream.
    initialPosition := objectStream position.  " remember so we can report size"
    textStream := dstStream.

    " read the <header section> "
    rootObjectId := self loadHeader: 'describe'
        acceptVersionAction: [ :filedVersion |
            self class versionCanBeDescribed: filedVersion ].
    rootObjectId isNil
        ifTrue: [
            objectStream position: initialPosition.  " back out "
            self recordSummaryMessage: operationDescription.
            ^nil ].
    self allocateDescribeCollections: self lastBehaviorId.
            " object entries not used for summary report "

    self
        describeObjectVersion;
        describeHeaderSummary;
        describeBehaviorsSummary;
        describeObjectsSummary;
        describeSoftSlotsSummary;
        describeSize: initialPosition.!   
allocateDumpCollections
        " Private - allocate the objects and behaviors
        collections for an object store operation. "

    " The behaviors dictionary maps a class/metaclass object
        to its dump id.  The dump ids of behaviors follow the
        predefined objects in the name space. "
    behaviors := self allocateSmallIdentityDictionary.
    libraryDependencies := Set new.

    " The objects dictionary maps a non-behavior object to an
        association defining its relative object id [1..n] and
        surrogate (if any).  The dump ids of objects follow the
        behaviors in the name space.  Relative object number
        is mapped to dump id after behavior ids known. "
    objects := self allocateDumpIdentityDictionary.

    " The soft slots dictionary contains entries for each soft slot
        encountered in the current dump, indexed by the set selector
        used to restore the value at load time.  Each entry contains
        a list of object id pairs of the object with the soft slot value
        and the dump id of its soft slot value. "
    softSlotValues := Dictionary new.! 
assignComputedIdRanges: lastDynamicId
        " Private - Assign the end of the dump id name space,
        given the last id assigned in the dynamic range
        (behaviors and objects) "
    idCharacterZero := lastDynamicId + 1.
    idIntegerZero := idCharacterZero + 256.! 
initializeForOperationOn: aStream
        " Private - initialize state for an operation on aStream. "

    objectStream := ( aStream respondsTo: #asByteFileStream )
        ifTrue: [ aStream asByteFileStream ]
        ifFalse: [ aStream ].
    messageCounts := messageStream := nil.
    operationAborted := false!  
describeSoftSlotsSummary
        " Private - provide a summary of the soft slot values in the filed object. "

    | count setSelector nValues |

    ( self class versionHasSoftSlots: objectVersion )
        ifFalse: [ ^self ].

    count := objectStream getInteger.
    textStream cr; nextPutAll: 'Object soft slot types:'; cr.
    count timesRepeat: [
        setSelector := objectStream upTo: NUL.
        nValues := 0.
        [ objectStream getInteger ~= IdNUL ] whileTrue: [
            objectStream getInteger.
            nValues := nValues + 1.
            ].
        textStream
            nextPutAll: '    #', setSelector,
               ' (used by ', nValues printString, ' objects)';
            cr.
        ].
    textStream nextPutAll: '    ', count printString, ' soft property types used'; cr.
    objectStream next.   " section terminator "
!  
eventTableForEdit
        "Private - Answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."

    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable! 
libraryMappings: anIdentityDictionary
        " Register the library mapping dictionary to use
        for object dumping.  Entries map a class
        to a String containing the library name to
        associate with instances of that class stored in the
        filed object.  The library association is used during
        loading to attempt to locate the class if it is missing. "

    libraryMappings := anIdentityDictionary.!   
messageStream
        " Private - answer the stream on which messages are logged.
        Create if necessary. "
    | date |
    messageStream isNil
        ifTrue: [ 
            messageStream := self class createLogWindow.
            date := Date today.
            messageStream
                nextPutAll: self class name, ' messages (';
                "nextPutAll: Date today printString; nextPut: Space;"
                nextPutAll: date dayOfMonth printString; nextPut: $-;
                nextPutAll: (date monthName copyFrom: 1 to: 3); nextPut: $-;
                nextPutAll: (date year printString copyFrom: 3 to: 4); nextPut: Space;
                nextPutAll: Time now printString;
                nextPutAll: ')'; cr;
                cr ].
    ^messageStream! 
dllNameDict: anIdentityDictionary
        " OBSOLETE - retained in Smalltalk/V 3.0 for compatibility. "

    self obsoleteMethod.
    self libraryMappings: anIdentityDictionary.!
new: aClass size: numIndexedInstVars
        " Private - Answer a new skeleton instance of aClass. "
    ^(aClass isVariable)
        ifTrue: [aClass basicNew: numIndexedInstVars]
        ifFalse: [aClass basicNew]!   
recordAbortMessage: aString
        " Abort the operation in progress and notify the
        user that a fatal error has occurred. "
    self recordMessage: aString
        type: 'abort'
        prefix: '*****FATAL ERROR: '.
    operationAborted := true.! 
dumpBehaviorDescriptors
        " Private - Write the <behavior descriptors section>. "

    | versionSupportsBinding behavior tag name rep numInstVars 
      libraryName |

    " write a <behavior descriptor> entry for each behavior "
    " <behavior type> <id> <nameString> <NUL>
            <representation>
            <number of named instance vars> [<inst var name>]...
            <DLL name> <NUL>  [version-dependent] "
    " for class, store names of all the inst vars in <name> <NUL> form "
    versionSupportsBinding := self class versionHasBindingInformation: objectVersion.
    behaviors associationsDo: [ :assoc |
        behavior := assoc key.
        name := behavior name.
        (behavior class == MetaClass)
            ifTrue: [
                tag := TagMetaClass.
                rep := NUL.
                numInstVars := 0.
                name := name copyFrom: 1 to: (name size - 6).  " strip trailing ' class' "]
            ifFalse: [
                tag := TagClass.
                rep := self repOf: behavior.
                numInstVars := behavior instSize].
        objectStream
            nextPut: tag;
            putInteger: assoc value;  " id "
            nextPutAll: name; nextPut: NUL;
            nextPut: rep;
            putInteger: numInstVars.
        (numInstVars > 0)
            ifTrue: [(behavior allInstVarNames) do: [ :instVarName |
                objectStream nextPutAll: instVarName; nextPut: NUL]].
        versionSupportsBinding
            ifTrue: [
                libraryName := self libraryNameOf: behavior.
                objectStream nextPutAll: libraryName; nextPut: NUL.
                libraryName size > 0
                    ifTrue: [ libraryDependencies add: libraryName ].
                ].
        ].

    objectStream nextPut: NUL.  " section terminator "!  
libraryDependencies
        " Answer a collection containing the names of all non-base
        library which contain class definitions used by the
        object which was just dumped or the names of all libraries
		which were bound by the object which was just loaded. "

    ^libraryDependencies!  
recordInfoMessage: aString
        " Notify the user that something interesting has occurred. "
    self recordMessage: aString type: 'info' prefix: ''.!   
repDescription: rep
        " Private - answer a string describing rep "
    ^(rep = RepFixedPointers)
        ifTrue: ['fixedPointers']
        ifFalse: [(rep = RepVariablePointers)
            ifTrue: ['variablePointers']
            ifFalse: ['variableBytes']]!
describeSoftSlots
        " Private - describe the soft slot values in the filed object. "

    | describeObjectBlock classId count setSelector objectId softSlotValueId |

    ( self class versionHasSoftSlots: objectVersion )
        ifFalse: [ ^self ].

    describeObjectBlock := [ :id |
        classId := ( objects at: id ) at: 1.
        textStream nextPutAll:
            '( ', ( behaviors at: classId ) key,
            ' instance ', id printString, ' )'.
        ].

    count := objectStream getInteger.
    textStream cr; nextPutAll: 'Object soft slot types:'; cr.
    count timesRepeat: [
        setSelector := objectStream upTo: NUL.
        textStream nextPutAll: '    #', setSelector; cr.
        [ ( objectId := objectStream getInteger ) ~= IdNUL ] whileTrue: [
            softSlotValueId := objectStream getInteger.
            textStream nextPutAll: '        '.
            describeObjectBlock value: objectId.
            textStream nextPutAll: ' ', setSelector, ' '.
            describeObjectBlock value: softSlotValueId.
            textStream cr.
            ].
        ].
    textStream nextPutAll: '    ', count printString, ' soft property types used'; cr.
    objectStream next.   " section terminator "

!
loadMapUsedFor: anObject
        " Answer the change map used to load anObject
        if the positions of any instance variables changed.
        Only valid during fileInActivate: processing. "
    ^remappedObjects at: anObject ifAbsent: [nil]! 
resetReferencesToTransformedObjects: transformationMap rootObjectId: rootObjectId
        " Private - fix up pointers to any objects which are being
        transformed to new identities. The <transformationMap> maps
        the object which was loaded to its mutated value. "

    | aClass newInstVarValue firstObjectId lastObjectId needsRehashing
      anObject |

    " mutated objects may themselves need fixup of their inst vars "
    transformationMap values do: [ :object |
        aClass := object class.
        aClass isPointers
            ifTrue: [
                1 to: ( aClass instSize + object basicSize ) do: [ :i |
                    newInstVarValue := transformationMap at: ( object instVarAt: i )
                        ifAbsent: [ nil ].
                    newInstVarValue notNil
                        ifTrue: [ object instVarAt: i put: newInstVarValue ] ].
                ].
        ].

    firstObjectId := self firstObjectId.
    lastObjectId := objects size.

    " fix references to the mutated objects from the loaded objects "
    needsRehashing := Set new.  "ISSUE: needs IdentitySet!! "
    firstObjectId to: lastObjectId do: [ :objectId |
        anObject := objects at: objectId.
        aClass := anObject class.
        aClass isPointers
            ifTrue: [
                1 to: ( aClass instSize + anObject basicSize ) do: [ :i |
                    newInstVarValue := transformationMap at: ( anObject instVarAt: i )
                        ifAbsent: [ nil ].
                    newInstVarValue notNil
                        ifTrue: [
                            anObject instVarAt: i put: newInstVarValue.  " become: "
                            "Hmm - following was a good idea, but
                                it won't work; rethink this [DJL 18-Jul-94]  "
                            ( anObject respondsTo: #rehash )
                                ifTrue: [ needsRehashing add: anObject ].
                            ] ] ].
        ].
    needsRehashing do: [ :object | object rehash ].

    " special check in case the root object transformed itself "
    rootObjectId < idCharacterZero
        ifTrue: [
            anObject := transformationMap at: ( objects at: rootObjectId )
                ifAbsent: [ nil ].
            anObject notNil
                ifTrue: [ objects at: rootObjectId put: anObject ].
            ].!  
loadBehaviorDescriptors: loadMaps
         " Private - Read the <behavior descriptors section>
        of the objectStream to find referenced classes and
        MetaClasses and put pointers to them in objects list
        at their dump id.  Where there is a size mismatch,
        record an instVar map in the behaviors list.
        Answer whether all classes can be loaded. "

    | versionHasBindingInformation loadMapsDict
      tag classId name rep
      numNamedInstVars filedInstVarNames aComponentName
      loadClassInfo behavior aChangeMap |

    versionHasBindingInformation := self class versionHasBindingInformation: objectVersion.
    loadMapsDict := self loadMapsDictFrom: loadMaps.

    [(tag := objectStream next) ~= NUL] whileTrue: [
        classId := objectStream getInteger.
        name := objectStream upTo: NUL.
        rep := objectStream next.
        numNamedInstVars := objectStream getInteger.
        filedInstVarNames := Array new: numNamedInstVars.
        1 to: numNamedInstVars do: [ :i |
            filedInstVarNames at: i put: (objectStream upTo: NUL)].
       aComponentName := ( versionHasBindingInformation
            ifTrue: [ objectStream upTo: NUL ]
            ifFalse: [ nil ] ).
        aChangeMap := loadMapsDict at: name ifAbsent: [nil].
        loadClassInfo := self
            loadClassFor: name
            rep: rep
            filedInstVarNames: filedInstVarNames
            componentName: aComponentName
            changeMap: aChangeMap
            isMetaClass: (tag = TagMetaClass).
        loadClassInfo isNil
            ifTrue: [^false].
        behavior := loadClassInfo at: 1.
        aChangeMap := loadClassInfo at: 2.
        objects at: classId put: behavior.
        aChangeMap notNil
            ifTrue: [behaviors at: classId put: aChangeMap].
        " track shape changes only if loading blocks "
        (remappedObjects isNil
        and: [behavior == HomeContext])
            ifTrue: [remappedObjects := self allocateSmallIdentityDictionary].
        ].
    ^true!   
describeFrom: srcStream to: dstStream
        " Describe the filed object on srcStream in
        a human-readable report on dstStream. "
    | operationDescription initialPosition rootObjectId |

    operationDescription := 'detailed object report'.
    self initializeForOperationOn: srcStream.
    initialPosition := objectStream position.  " remember so we can report size"
    textStream := dstStream.

    " read the <header section> "
    rootObjectId := self loadHeader: 'describe'
        acceptVersionAction: [ :filedVersion |
            self class versionCanBeDescribed: filedVersion ].
    rootObjectId isNil
        ifTrue: [
            objectStream position: initialPosition.  " back out "
            self recordSummaryMessage: operationDescription.
            ^nil ].
    self allocateDescribeCollections: self lastObjectId.

    self
        describeObjectVersion;
        describeHeader: rootObjectId;
        describeBehaviorDescriptors;
        describeObjectDescriptors;
        describeSoftSlots;
        describeSize: initialPosition.!  
describeObjectVersion
        " Private - emit header describing the objectVersion. "
    textStream
        nextPutAll: '"Smalltalk/V filed object description"'; cr;
        nextPutAll: (
            'Version ', objectVersion printString,
            ' (dumped from ',
            (self class versionDescription: objectVersion),
            ')' );
        cr; cr.!
loadLayoutChanges: anObject
        " Compatibility only. Answer inst var change history for anObject.
        If the positions of anObject's instance values changed
        during loading, an array is answered with entries:
            1 - filed size of anObject
            2 - array indexed by current inst var slot containing
                    filed slot index that was loaded into this slot
                    (nil if no value loaded into this slot)
        May only be called by a fileInActivate: method. "
    | aChangeMap |
    aChangeMap := self loadMapUsedFor: anObject.
    aChangeMap isNil ifTrue: [^nil].
    ^Array
        with: aChangeMap sourceSize
        with: aChangeMap slotIndexArray!
getClassNamed: aClassName
        " Private - answer the class named <aClassName>
        if it exists in the system.  Answer nil if it doesn't. "

    ^Smalltalk at: aClassName asSymbol ifAbsent: [ nil ]! 
eventTable
        "Private - answer a Dictionary mapping event names to actions
        for the receiver."

    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]!   
objectCountEstimate: anInteger
    "Provide an estimate of the number
    of objects that will be in the receiver,
    so that dictionaries can be initialized
    with an appropriate starting size to
    avoid growing and therefore speed
    up the building time."

    self clientAllocateDictionaryAction: [ IdentityDictionary new: anInteger ].!
describeHeaderSummary
        " Private - write summary header information description "
    textStream
        nextPutAll:
            'Number of classes = ', (numBehaviors printString); cr;
        nextPutAll:
            'Number of objects = ', (numObjects printString); cr;
        cr.! 
logSoftSlots: anObject id: objectId
        " Private - log any soft slots of <anObject>. "

     | softSlotValue setSelector slotValuesList |

    ( self class versionHasSoftSlots: objectVersion )
        ifFalse: [ ^self ].

    self class softSlotSelectors do: [ :selectorPair |
        softSlotValue := anObject perform: selectorPair first.  " get selector "
        softSlotValue notNil
            ifTrue: [
                setSelector := selectorPair at: 2.
                slotValuesList := softSlotValues at: setSelector
                    ifAbsentPut: [ OrderedCollection new ].
                slotValuesList add: ( Array
                    with: objectId
                    with: ( self log: softSlotValue ) ).
                ].
        ].
! 
bindLibrary: aLibraryName toFindClass: aClassName
        " Private - attempt to bind the library named
        <aLibraryName> to find the class
        <aClassName>.  Answer whether the bind succeeded.
        (Which doesn't necessarily mean it contained the
        the desired class). "

    self recordInfoMessage:
        'Attempting to bind library ', aLibraryName,
        ' to locate class ', aClassName.
    [ SmalltalkLibraryBinder bindTo: aLibraryName ]
        on: FileError, BindError
        do: [ :e |
            self recordInfoMessage:
                '   ...bind failed (unable to open or wrong version)'.
            ^false ].
    self recordInfoMessage: '    ...done'.
	libraryDependencies add: aLibraryName.
    ^true! 
useBindingInformation
        " Answer whether component binding information
        for resolving missing classes should be used
        during loading. "

    ^useBindingInformation! 
useBindingInformation: aBoolean
        " Specify whether component binding information
        for resolving missing classes should be used
        during loading. "

    useBindingInformation := aBoolean.!  
clearMouseCapture
        " Private - clear mouse capture before doing user interaction during loading. "

    | currentWindow |
    ( currentWindow := Notifier activeMainWindow ) notNil
        ifTrue: [ currentWindow clearMouseCapture ].!