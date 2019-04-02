3.1.0.106
   
fileDescriptorFor: aFileOrPathName
    "Answer a file descriptor for <aFileOrPathName>."
    | directory |

    ^( aFileOrPathName includes: $\ )
        ifTrue: [    "Full path name"
            PARTSFileDescriptor pathName: aFileOrPathName ]
        ifFalse: [ "File name"
            directory :=
                PARTSFile
                    directoryContaining: aFileOrPathName
                    raiseError: false.
            directory notNil
                ifTrue: [
                    PARTSFileDescriptor
                        pathName: aFileOrPathName
                        in: directory ]
                ifFalse: [ nil ]].!   
openOn: anApplicationOrStringOrComponent

    root := anApplicationOrStringOrComponent.
    self openApplication.! 
fileName
        " Private - Answer the name of the part file
        containing the application window. "

    ^'REFERVWR.par'!  
fileName
        " Private - Answer the name of the part file
        containing the application window. "

    ^'PwBrwsr.par'
! 
references: searchList
    "Private - Given the search list, compile the references within
        that list."
    | reference referencesCollection pattern |

    CursorManager execute change.

    pattern := PARTSFileDescriptor fileTypeForPart pattern.
    referencesCollection := OrderedCollection new.
    searchList do: [ :aDirectory |
        ( aDirectory filesNamed: pattern ) asOrderedCollection do: [ :aFileName |
            reference := PARTSFileDescriptor fileName: aFileName in: aDirectory.
            ( self partNamed: 'Searching' ) setValue: reference displayName.
            ( self searchForReference: reference )
                ifTrue: [
                    referencesCollection add: reference ]]].
    CursorManager normal change.

    PARTSPartBrowser new openOn: referencesCollection title: 'References for ',fileReference asString.
!   
initializeEventHandlers
    "Private"
    application
         when: #openFile:revision:
            send: #openFile:revision: to: self;
        when: #references: evaluate: [ :fileDescriptor |
            fileDescriptor notNil
                ifTrue: [
                    PARTSReferenceBrowser new openOn: fileDescriptor ]]
!  
addFileToList: fileDescriptor copyMode: aCopyMode tab: tabString
    "Add application name and those of its nested parts to the list.
        If <revision> is nil, don't look one up.  Don't want to force a
        revision number on the root."
    | properties copyMode |

    fileDescriptor isNil
        ifTrue: [ ^nil ].

    aCopyMode = #embed
        ifFalse: [
            aCopyMode = #reference
                ifTrue: [ fileDescriptor insureCurrent ]].

    [ ( properties := PARTSFile propertiesFromPathName: fileDescriptor fullPathName ) isNil
        ifTrue: [ ^self ]]
        on: PARTSApplicationLoadError
        do: [ :e | e postMessageBox: 'File Property Load Error'.  ^nil ].

    copyMode := ( aCopyMode notNil )
        ifTrue: [ aCopyMode ]
        ifFalse: [ PARTSFile reuseModePropertyFrom: properties ].

    self buildList: fileDescriptor
        copyMode: copyMode
        tab: tabString.

    self addNestedPartsFromFile: fileDescriptor
        properties: properties
        application: nil
        tab: tabString.! 
openFile: aFileDescriptor revision: aRevisionNumber
    "Open the given file."
    "Code from LAFEditor>>fileOpen"
    | app fileDescriptor |

    aFileDescriptor isNil
        ifTrue: [ ^nil ].

    ( fileDescriptor := aFileDescriptor copy ) isPARTSTeamVFileDescriptor
        ifTrue: [ fileDescriptor revisionNumber: aRevisionNumber ].

    [ app := fileDescriptor loadForEdit ]
        on: PARTSApplicationLoadError
        do: [ :e |
            e postMessageBox: 'Browse Implementors Load Error'.
            ^nil ].
    app isNil
        ifTrue: [ ^nil ].  "Backstop: should raise an error"
    PARTSEditor editorClass new openOn: app!   
initializePartValues
    "Private"
    ( self partNamed: 'ReferencesDirectory' )
        setList: PARTSFile currentSearchPath.
    ( self partNamed: 'ReferencesSearchPath' )
        allowWorkbenchToBeDisabled: true.

    "Set the method that the directory list box will use to
        display its files."
    ( self partNamed: 'ReferencesDirectory' ) printSelector: #displayName.! 
nestedPartDisplayString: aFileDescriptor

    ^nestedPartDict
        at: ( aFileDescriptor notNil ifTrue: [ aFileDescriptor ] ifFalse: [ #newAppPlaceHolder ])
        ifAbsent: [ '' ]
!   
openOn: files title: aTitle fileDisplayAttribute: aMessageOrSelectorOrBlock
    "Open the receiver on file descriptors <files> with <aTitle> for the window.
    <aMessageOrSelectorOrBlock> is a suitable value for sending printSelector:
    to a ListPanePart"

    fileDisplayAttribute := aMessageOrSelectorOrBlock.
    title := aTitle.
    self openApplicationOn: files
!   
buildList: aFileDescriptor copyMode: aCopyMode tab: aTabString
    "Build the display string for the nested part in the nested part browser window."
    | label listItem |

    label := aTabString, ( self fileLabel: aFileDescriptor copyMode: aCopyMode ).

    listItem := aFileDescriptor notNil
        ifTrue: [ aFileDescriptor ]
        ifFalse: [ #newAppPlaceHolder ].

    application addFile: aFileDescriptor.

    nestedPartDict
        at: listItem
        put: label.
!  
fileLabel: aFileDescriptor copyMode: aCopyMode
    "Answer the label to be displayed for the file."
    | versionString aRevisionString label |

    label := super fileLabel: aFileDescriptor copyMode: aCopyMode.

    aFileDescriptor isNil ifTrue: [ ^label ].  "App in the workbench"

    label := label copyFrom: 1 to: label size - 1.
    ( aRevisionString := aFileDescriptor revisionNumber ) notNil
        ifTrue: [
            versionString :=
                ( aCopyMode = #reference
                    ifTrue: [ ': currently v',aRevisionString,')' ]
                    ifFalse: [
                        aCopyMode = #embed
                            ifTrue: [ ': v',aRevisionString,')' ]])].
    versionString isNil
        ifTrue: [ versionString := ')' ].
    ^label := label, versionString.
!   
openOn: aFileReference
    "Open a reference viewer on <aFileReference>.
        For now, a match is based only on file names and
        not revision number."

    aFileReference isNil
        ifTrue: [ ^nil ].

    fileReference :=
        ( aFileReference isString
            ifTrue: [ aFileReference ]
            ifFalse: [ aFileReference fileName ]).
    self openApplicationOn: fileReference.! 
searchForReference: aFileReference
    "Given a candidate file path, see if it contains a reference
        to the part in <fileReference>.
        Answer whether the candidate refers to the nested part.
        Note: Only a test for equal file names is performed."
    | app nestedParts searchName referencedParts embeddedParts |

    [ nestedParts :=
            PARTSFile nestedPartsPropertyFromPathName: aFileReference ]
        on: PARTSApplicationLoadError
        do: [ :e |
            e postMessageBox: 'File Property Load Error'.
            ^false ].
    ( referencedParts := nestedParts first ) isNil
        ifTrue: [ "Old property set.  Search nested parts manually."
            [ app :=  (PARTSFileDescriptor pathName: aFileReference) loadForEdit ]
                on: PARTSApplicationLoadError
                do: [ :e | ^false ].
            referencedParts := app referencedPartsProperty.
            embeddedParts := app embeddedPartsProperty ]
        ifFalse: [ "New property set.  Nested part info in the properties"
            embeddedParts := nestedParts last ].

    nestedParts := ( referencedParts,' ',embeddedParts ) asArrayOfSubstrings.
    nestedParts := nestedParts collect: [ :each | each upTo: $; ].

    searchName := fileReference copy.
    nestedParts do: [ :aFileName |
        ( aFileName equalsIgnoreCase: searchName )
            ifTrue: [ ^true ]].
    ^false
!   
initializePartValues
        " Private - the application has just been loaded or is
        is being recycled from the cache after previous use.
        Initialize the state of parts in the application."

    "Set the method that the directory list box will use to
        display its files."
    ( self partNamed: 'FileList' ) printSelector: fileDisplayAttribute.
    ( self partNamed: 'BrowserWindow') setLabel: title
!
addComponentsToList: aComponent tab: aTabString
    "Private - Add aComponent or any nested part children
        of <aComponent> to the list."
    | nestedParts fileDescriptor |

    nestedParts := aComponent isPARTSNestedPart
        ifTrue: [ OrderedCollection with: aComponent ]
        ifFalse: [
            aComponent orderedChildren asOrderedCollection
                select: [ :aPart | aPart isPARTSNestedPart ]].
    nestedParts do: [ :aNestedPart |
        ( fileDescriptor := aNestedPart fileDescriptor copy ) notNil
            ifTrue: [
                aNestedPart isLinked
                    ifTrue: [ fileDescriptor insureCurrent ].

                self addFileToList: fileDescriptor
                    copyMode: aNestedPart copyMode
                    tab: aTabString ]]
! 
openOn: files title: aTitle
    "Open the receiver on file descriptors <files> with <aTitle> for the window."
    self
        openOn: files
        title: aTitle
        fileDisplayAttribute: #displayName  "For fileDescriptor"
!   
addApplicationToList: anApplication copyMode: aCopyMode tab: tabString
    "Private - Add application and those of its nested parts to the list."
    | fileName fileDescriptor |

    ( anApplication isNil or: [ anApplication isPARTSApplication not ])
        ifTrue: [ ^nil ].

    fileDescriptor := anApplication fileDescriptor copy.
    fileName := ( fileDescriptor notNil )
        ifTrue: [ fileDescriptor fileName "asUpperCase" ]
        ifFalse: [ 'Workbench' ].

    self buildList: fileDescriptor
        copyMode: aCopyMode
        tab: tabString.

    self
        addNestedPartsFromFile: fileDescriptor
        properties:
            ([ fileDescriptor notNil
                ifTrue: [
                    ( PARTSFile propertiesFromPathName: fileDescriptor fullPathName )]
                ifFalse: [ nil ]]
                on: PARTSApplicationLoadError
                do: [ :e | e postMessageBox: 'File Property Load Error'. nil ])
        application: anApplication
        tab: tabString!  
fileDescriptorFromProperty: aProperty
    "Private - Answer a file descriptor from the items in <aProperty>."
    | name revisionNumber aFileDescriptor |

    name := aProperty upTo: $;.
    revisionNumber := aProperty upTo: $;.    "End"
    ( aFileDescriptor := self fileDescriptorFor: name ) notNil
        ifTrue: [
            aFileDescriptor isPARTSTeamVFileDescriptor
                ifTrue: [ aFileDescriptor revisionNumber: revisionNumber ]].
    ^aFileDescriptor!
fileDescriptorFromProperty: aProperty
    "Private - Answer a file descriptor from the items in <aProperty>."
    | name aFileDescriptor |

    name := aProperty upTo: $;.
    aFileDescriptor := self fileDescriptorFor: name.
    ^aFileDescriptor!  
initializeEventHandlers
    "Private"
    application
        when: #references:
            send: #references: to: self
!   
addNestedPartsFromFile: fileDescriptor properties: properties application: anApplication tab: tabString
    "Given application properties, an application, and a file descriptor check each in succession
        for nested parts.  If the properties don't have the nested part properties, check the application
        for nested parts, and if still can't access the nested parts, use the file descriptor to load the
        application."
    | nestedParts referencedParts embeddedParts app |

    [ nestedParts := PARTSFile nestedPartsPropertyFrom: properties ]
        on: PARTSApplicationLoadError
        do: [ :e | e postMessageBox: 'File Property Load Error'. ^nil ].

    referencedParts := nestedParts first.
    embeddedParts := nestedParts last.
    referencedParts isNil
        ifTrue: [
            [ app := anApplication notNil
                ifTrue: [ anApplication ]
                ifFalse: [ fileDescriptor loadForEdit ]]
                    on: PARTSApplicationLoadError
                    do: [ :e | ^nil ].
            referencedParts := app referencedPartsProperty.
            embeddedParts := app embeddedPartsProperty ].

    referencedParts asArrayOfSubstrings do: [ :each |
        self addFileToList: (self fileDescriptorFromProperty: each asStream )
            copyMode: #reference
            tab: tabString, '     ' ].

    embeddedParts asArrayOfSubstrings do: [ :each |
        self addFileToList: (self fileDescriptorFromProperty: each asStream )
            copyMode: #embed
            tab: tabString, '     ' ].!  
initialize
    "Private"

    title := 'Browse Nested Part Explosion'.
    fileDisplayAttribute :=
        Message new
            receiver: self;
            selector: #nestedPartDisplayString:;
            yourself.


!  
fileLabel: aFileDescriptor copyMode: aCopyMode
    "Answer the label to be displayed for the file."
    | fileName modeString label |

    fileName := aFileDescriptor notNil
        ifTrue: [ aFileDescriptor fileName  ]
        ifFalse: [ 'Workbench' ].

    modeString :=
        ( aCopyMode = #reference
            ifTrue: [ ' - (Linked' ]
            ifFalse: [
                aCopyMode = #embed
                    ifTrue: [ ' - (Embeded' ]
                    ifFalse: [ '' ]]).

    ^label := fileName, modeString, ')'.!  
initializePartValues

    super initializePartValues.

    CursorManager execute change.
    nestedPartDict := IdentityDictionary new.

    root isPARTSApplication
        ifTrue: [
            self addApplicationToList: root
                copyMode: root reuseMode
                tab: '' ]
        ifFalse: [
            root isString
                ifTrue: [
                    self addFileToList: (self fileDescriptorFor: root)
                        copyMode: nil
                        tab: '' ]
                ifFalse: [
                    self addComponentsToList: root
                        tab: '' ]].

    CursorManager normal change.
!