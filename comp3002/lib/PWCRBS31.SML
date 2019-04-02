3.1.0.106
   
partDebugger
        " Answer the PARTS link debugger which is
        operating on the receiver.  Answer nil if the
        application is not currently being debugged. "

    ^editor isPARTSEditor
        ifTrue: [ nil ]
        ifFalse: [ editor ]!
moveTo: aPoint in: aControl
    | parentRect aRect |
    parentRect := aControl freeClientArea.
    aRect := self scaleFrom: parentRect.
    aRect moveTo: aPoint.
    self changeRectangle: aRect relativeTo: parentRect!   
initialize
        " Private - intialize platform settings
                PARTSSessionManager initialize
        "

    | versionNumbers |
    self
        partsIfOS2Do: [
            PlatformFilePrefix := 'PWO'.
            PlatformProductName := 'OS/2'.
            ]
        partsIfWindowsDo: [
            PlatformFilePrefix := 'PWW'.
            PlatformProductName := 'Win32'.
            ].
    versionNumbers := Array with: 3 with: 1 with: 0.
    self versionNumbers: versionNumbers.
    PlatformProductVersion := ( versionNumbers at: 1 ) printString, ( versionNumbers at: 2 ) printString.
    self initializeWorkbenchSupportLibraries.
    self reportObsoleteMessageUse: false.!
reuseMode: aSymbol
        " Specify the application's reuse mode. "

    reuseMode := aSymbol!
compilerInterfaceClass
        " Private - answer the compiler interface class for scripts. "

    ^Smalltalk at: #PARTSScriptCompilerInterface
        ifAbsent: [
            MessageBox
                notify: 'PARTS Installation Problem'
                withText: 'You need to install the PARTS script compiler component.'.
            nil ]!  
maskForDefault
    ^2r10001000  "fixed inset at top left and fixed size"!
versionInLibraryName
        "Answer the substring used in the library names to indicate the
		version of the library."

    ^'31'!   
versionPropertyName
        " Private "

    ^'version'!   
forExecute
        " Answer whether the copy is going to be
        executed or debugged.  If true, information
        needed only to support editing an object
        in a  PARTS Workbench can be omitted
        from the copy. "

    ^#( #copyExecutable #copyDebuggable #saveExecutable )
        includes: self operation!   
descriptionOfRight
        "Answer a String describing the calculation of the right."
    | stream |
    stream := WriteStream on: String new.
    stream
        nextPutAll: 'right: ';
        nextPutAll:
            (self isRightInset
                ifTrue: [ 'left of parent''s right by ']
                ifFalse: [ 'right of window left by '] );
        nextPutAll: right printString;
        nextPutAll:
            (self isRightStretched
                ifTrue: [ ' of parent''s width']
                ifFalse: [ ' ', self scaleUnitPlural ] ).
    ^stream contents!  
userPropertyNamed: propertyNameString put: aStringOrNil
        " Set the value of the user property named <propertyNameString>
        to be <aStringOrNil> which must be either a String or nil. "

    | aString propertyAssoc |
    aStringOrNil isNil
        ifTrue: [
            self removeUserProperty: propertyNameString.
            ^nil ].
	aString := aStringOrNil asString.
    propertyAssoc := userProperties
        detect: [ :assoc | assoc key = propertyNameString ]
        ifNone: [ nil ].
    propertyAssoc isNil
        ifTrue: [ 
            self
                addProperty: propertyNameString
                value: aStringOrNil]
        ifFalse: [ propertyAssoc value: aStringOrNil ].
    ^aStringOrNil!  
leftTopMessageLabelOriginLeftBottom: aPoint
        " Specify the offset of the top left corner of the link's message label
        from the path's landing point.  The delta value aPoint is specified
        in terms of a coordinate system with its origin at the leftBottom. "
    aPoint notNil
        ifTrue: [ leftTopMessageLabel := aPoint x @ aPoint y negated ]!   
center: centerInset stretched: centerStretch width: width stretched: widthStretch
    "Use centerInset and width for the horizontal measurement.  centerStretch
     and widthStretch are booleans indicating whether it's stretchable."

    left := centerInset.
    right := width.
    self useCenterWidth;
        useLeftStretched: centerStretch;
        useRightStretched: widthStretch! 
propertyAt: key put: aValue
        "Private - Set the value associated with key
        in the properties dictionary."
    ^property propertyAt: key put: aValue! 
defaultDescriptionString
        "Private - Return a textual description of the
        exception if an explicit description has not been provided.
        Subclass will frequently override this method."
    | fileName |
    nestedPart notNil
        ifTrue: [
            fileName := nestedPart fileName ].
    fileName size = 0
        ifTrue: [
            fileName := '<unknown file>' ].
    ^'Cannot load file ', fileName!
isEmpty
        "Answer whether the receiver contains any items. "

    ^self items size = 0!  
standaloneWorkbenchLibraries
        " Private - answer the names of the libraries which must
        be bound to complete the standalone workbench environment. "

    | versionSuffix |
    versionSuffix := "self class platformProductVersion" '31'.
    ^Array
        with: 'PWCWCS', versionSuffix
        with: 'PW', OperatingSystem name first asString, 'WDS',versionSuffix
        with: 'PWCSCR', versionSuffix!
useBottomHeight
    "Private - For the bottom side, use height measurement."

    mask := mask bitAnd: 2r11111101! 
userPropertyNamed: propertyNameString
        " Answer the value of the user-defined property named <propertyNameString>. 
        The property value is a String (or nil if not defined). "

    ^property userPropertyNamed: propertyNameString asString!   
versionDescriptionOf: aFileVersionString
		" Answer a description of the PW file version <aFileVersionString>. "

	^self fileAccessorClass versionDescriptionOf: aFileVersionString!   
forDebug
        " Answer whether the copy is going to be
        debugged.  If true, information
        needed only to support editing an object
        in a  PARTS Workbench can be omitted
        from the copy. "

    ^self operation = #copyDebuggable!   
isPARTSLoadContext
        " Answer whether the receiver is the clientContext of a PARTS application
        load operation. "

    ^true!
scaleFrom: aRect
    "Answer a Rectangle as a result of applying the
     receiver framer to aRect."

    ^self scaleFrom: aRect rounded: true!   
isCurrentVersion
        " Answer whether the PARTS application file being loaded is the current version. "

    ^isCurrentVersion!
externalMessages: anArray
        " Private - set the external message list. "

    externalMessages := anArray.!  
append: anInterfaceList defaultItem: newDefaultItem
        " Obsolete - retained in PW 3.0 for compatibility with PW/OS2 2.0 "

    PARTSSessionManager obsoleteMessage.
    ^self concatenate: anInterfaceList defaultItem: newDefaultItem! 
printHorizontalPropertiesOn: aStream margin: aString
        "Print a description the horizontal properties of the reciever
        on aStream."
    aStream
        nextPutAll: aString;
        nextPutAll: self descriptionOfLeft; cr;
        nextPutAll: aString;
        nextPutAll: self descriptionOfRight; cr!
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^false!  
COMMENT
"
A PARTSLoadContext or PARTSStoreContext is the ObjectFiler clientContext
object when a PARTS application file is read or written, respectively.

User-defined properties can be attached to a PARTS file operation
context if add-on parts need to keep track of their own state
during the loading or storing of a PARTS application.
"!   
isPARTSStoreContext
        " Answer whether the receiver is the clientContext of a PARTS application
        store operation. "

    ^true!  
registerWorkbenchSupportLibrary: aLibraryName for: partDescription isBound: isBound
        " Register the workbench support library named <aLibraryName>. "

	| nextIndex |
	nextIndex := self workbenchSupportLibraryIndex + 1.
    self workbenchSupportLibraries
        at: aLibraryName
        put: ( Array with: partDescription with: isBound with: nextIndex ).
	self workbenchSupportLibraryIndex: nextIndex.! 
items: itemList
        " Specify the items in the receiver. "

     items := itemList.!   
close
        "Private - Close the Timer aux window"
    self
        partsIfOS2Do: [
            super close.
            Notifier remove: self.
            PARTSHostInterface hostWindowLibrary destroyWindow: parent handle.
            "self initialize" ]
        partsIfWindowsDo: [
            self isHandleOk ifTrue: [
                self stopReceivingMessages.
                self destroy.
                self initialize ]
        ].!   
initialize
    self defaultScaleUnit: #twip! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    | events interface |
    events :=
        self staticEvents , self dynamicEvents.
    interface := PARTSInterfaceList new
        items: events;
        separators: (self dynamicEvents size > 0
            ifTrue: [Array with: self staticEvents size]
            ifFalse: [#()]).
    (events size > 0)
        ifTrue: [interface defaultItem: events first].
    ^interface!
defaultText
    "Private"
    ^self filePathName asString,' is empty.'! 
debugger
         " Private - answer the PARTS debugger associated with the current load operation. "

    ^debugger!  
concatenateListsSeparated: anArrayOfLists defaultItem: anItem
        " Answer the concatenation of anArrayOfLists. "

    | newList |
    newList := self emptyList.
    anArrayOfLists do: [ :anInterfaceList |
        newList := newList
            concatenateSeparated: anInterfaceList
            defaultItem: anItem ].
    ^newList!  
supportedOperations
        " Answer the allowable mirrorCopy operation types. "
    ^#(
        #copy  " make an editable copy "
        #copyExecutable  " make an executable copy "
        #copyDebuggable  " make a debuggable copy "
        #save  " make an editable copy for a .par file "
        #saveExecutable  " make an executable copy for a .exe file "
        )!   
commandLine
        " Answer the command line which initiated execution of this session. "

    | commandLine |
    commandLine := SessionModel current getCommandLine.
    ( self isWorkbenchSession not and: [ commandLine size >= 2  ] )
        ifTrue: [ commandLine := commandLine copyFrom: 2 to: commandLine size ].
    ^commandLine! 
debugger: aPartDebugger
        " Private - specify the PARTS debugger
        which will be debugging the copy. "

    debugger := aPartDebugger.!   
userPropertyNamed: propertyNameString ifAbsent: aBlock
        " Answer the value of the user property named <propertyNameString>.
        Evaluate <aBlock> if there is no such property. "

    ^ ( userProperties
        detect: [ :assoc | assoc key = propertyNameString ]
        ifNone: [ ^aBlock value ] )
            value!
left: leftInset stretched: leftStretch right: rightInset stretched: rightStretch
    "Use leftInset and rightInset for the horizontal measurement.  leftStretch
     and rightStretch are booleans indicating whether it's stretchable."

    left := leftInset.
    right := rightInset.
    self useLeftInset;
        useRightInset;
        useLeftStretched: leftStretch;
        useRightStretched: rightStretch!  
defaultItem
        " Answer the default item of the receiver. "

    ^defaultItem!
directoryContaining: aFileReference ifNone: aBlock
        " Answer the first directory on the PARTS search path
        containing aFileReference.  Evaluate aBlock if not found.
		Assume aFileReference is a file name already if it is a
		string, for performance. "

    | fileName |
    fileName := ( aFileReference isString
        ifTrue: [ aFileReference ]
        ifFalse: [ aFileReference fileName ] ).  "file descriptor"
    self currentSearchPath do: [ :aDirectory |
        ( PARTSFile exists: fileName in: aDirectory )
            ifTrue: [ ^aDirectory ] ].
    ^aBlock value!   
canReadProperties: aBoolean
		" Specify whether the header properties can be loaded
		from the part file by the current system. "

	canReadProperties := aBoolean.!   
fileType
    "Answer the file type processed by the instance
    of the receiver."

    ^Array with: PARTSFileDescriptor fileTypeForExe!  
fileTypeForAll

    ^ PARTSFileType type: 'ALL' pattern: '*.*' description: 'All Files (*.*)'!  
fileOutSurrogateObject
        " Private - answer the fileOut surrogate to use for the receiver.
        Clear the code cache.  Retain the script source. "

    | surrogate |
    surrogate := self deepCopy.
    surrogate
        primitive: nil;
        yourself.
    "self ASSERT: sourceObject class == PARTSScriptSource."
    sourceObject class ~~ PARTSScriptSource  " backstop "
        ifTrue: [ surrogate hideSource ].
    ^surrogate!
isCurrentVersion: aBoolean
        " Private - specify whether the PARTS application file being loaded is the current version. "

    isCurrentVersion := aBoolean.!   
printVerticalPropertiesOn: aStream margin: aString
        "Print a description the vertical properties of the reciever
        on aStream."
    aStream
        nextPutAll: aString;
        nextPutAll: self descriptionOfTop; cr;
        nextPutAll: aString;
        nextPutAll: self descriptionOfBottom; cr!
type: aType pattern: aPattern description: aString
    ^ self new
        type: aType;
        pattern: aPattern;
        description: aString!   
fileTypeForSmalltalkLibraryFile
        "Private - answer a PARTSFileType for a Smalltalk library file
        storage of a PARTSApplication."
    ^PARTSFileType type: 'SLL' pattern: '*.SLL' description: 'Smalltalk library (*.SLL)'!   
manufacturer
        " Answer the application's manufacturer property. "

    ^self userPropertyNamed: self manufacturerPropertyName!  
isApplicationMessage: aSelector
        " Private - answer whether <aSelector> is a message
        that should be relayed to the application. "

    ^( self respondsTo: aSelector ) not!
launchSide: aSide
        " Specify the side of the link's source object to which
        the launch point of its path is attached. "
    launchSide := aSide.!
revisionNumber
        "Answer the current revision number."

    ^self versionNumbers at: 3!  
setDefaultSearchPath
        " Set the PARTS search path to a default value
        for the current environment. "

    self setSearchPath:
        ( PARTSSessionManager isWorkbenchSession
            ifTrue: [ self defaultSearchPath: Disk ]
            ifFalse: [ ( Array with: Disk ) ] ).!
version
        " Answer the application version "

    ^property version! 
isRunning: aTimerPart
        "Answer whether aTimerPart is currently running."
    items keyAtValue: aTimerPart ifAbsent: [^false].
    ^true!
scaleUnit: scaleUnit toPixelVertical: units
    "Answer the conversion of vertical <units> in the
    <scaleUnit> measurement to pixels"

    scaleUnit = #twip
        ifTrue: [
            ^ units * Display verticalPixelsPerInch / 1440 ].
    scaleUnit = #inch
        ifTrue: [
            ^ units * Display verticalPixelsPerInch ].
    scaleUnit = #centimeter
        ifTrue: [
            ^ units * Display verticalPixelsPerMeter / 100 ].
    ^units
! 
menuClickedActionOf: anExternalMessageSelector
    "Private "
    | actionOrLink |

    actionOrLink :=
        self application isEditable
            ifTrue: [
                self application partWrapper
                    linksTriggeredBy: anExternalMessageSelector ]
            ifFalse: [
                self application eventTableInternal
                    at: anExternalMessageSelector
                    ifAbsent: [ nil ]].

   ^actionOrLink isNil
        ifTrue: [ nil ]
        ifFalse: [ actionOrLink isCollection
            ifTrue: [ actionOrLink first ]
            ifFalse: [ actionOrLink ] ]!  
leftTopMessageLabel
        " Answer the offset of the top left corner of the link's message label
        from the path's landing point. "
    ^leftTopMessageLabel!  
fullPathName: aFileReference
        "Answer the full path name for the first occurrence
        of the file described by aFileReference in the
        PARTS Workbench search path.
        Raise an exception if <aFileReference> is not on the
        search path."
    | dir |
    ( dir := PARTSFile directoryContaining: aFileReference ) isNil
        ifTrue: [ ^nil ].

    ^PARTSFileDescriptor
        stringFrom: aFileReference asString fileNameLessPath
        in: dir!  
pathPoints: anArray scaleUnit: aScaleUnit
        "Private - Set the position points of the link's path.  The
    first point is the offset of the launch base point relative
    to the origin of the source object rectangle, in respect
    to the launchSide.  The first control point is relative to the
    launchPlugTip.  The control points a relative to the
    previous point.  The last point is the offset of the landing
    tip point relative to the target object rectangle, in respect
    to the landingSide.
        <anArray> is in pixels and will be converted to the
    scale unit of the application <aScaleUnit>."

    pathPoints :=
        anArray collect: [ :aPoint |
            ( PARTSFramer pixelHorizontal: aPoint x toScaleUnit: aScaleUnit ) @
                ( PARTSFramer pixelVertical: aPoint y toScaleUnit: aScaleUnit )]!   
eventTable
        "Private - answer the table of event handlers for the receiver."

    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable at: 1 ]!  
applicationForExecute
        "Answer the PARTSApplication that the receiver knows how to build
        configured to be executable."
    | application block |
    application := self applicationCore.
    application eventTableAttribute
		at: 2 
		put: ( application eventTableAttribute at: 1 ).
	block := [:w |
		w object partEnableExecution.
		w components size > 0 ifTrue: [
			w components do: block]].
	block value: application wrapper. 
    ^application
!   
operation
        " Private - answer the current operation "
    ^operation!
componentScripts
        "Private - Answer the application components' script
        dictionaries.  This information is only valid for
        executable applications (because the wrappers are
        stripped.)"

    ^self propertyAt: #componentScripts ifAbsent: [ IdentityDictionary new ]
!  
fileDescriptor
        "Answer the descriptor of the file containing the application."

    ^fileDescriptor isString
        ifTrue: [
                "Filed out as string for executable files to avoid references
                 to revision support classes."
            PARTSFileDescriptor pathName: fileDescriptor ]
        ifFalse: [ fileDescriptor ]!   
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."

    | partName |
    partName := self scriptPart partName.
    partName isNil
        ifTrue: [ ^super printOn: aStream ].
    aStream nextPutAll: partName.
    aStream nextPutAll: '>>'.
    selector printOn: aStream.! 
versionString: aString
		" Set the version string which is stored in
		a PARTS file. "

	versionString := aString.!   
forFile: aFile
        " Answer a timestamp with the date and time
        that aFile was last written. "
    | timeStamp |
    timeStamp := aFile lastModificationTime.
    ^self date: timeStamp date time: timeStamp time!
writeNewFile: aPathName
    name: aNameString
    solePart: anObject
    icon: anIcon
    partIcon: partIcon
    hint: aHintString
    helpFile: aHelpFileName
    helpTopic: aHelpTopicName
    nestingMode: nestingMode
    libraryMappings: libraryMappings
        " Write the file aPathName with a new application
        containing the single part anObject.  "

    | application |
    application := self
        name: aNameString
        solePart: anObject
        icon: anIcon
        partIcon: partIcon
        hint: aHintString
        helpFile: aHelpFileName
        helpTopic: aHelpTopicName
        nestingMode: nestingMode.
    application
        storeOnPathName: aPathName
        libraryMappings: libraryMappings.!   
parent: aNestedPart
        " Set the application's parent property.
    For an editable application this information
    is located in the wrapper."

    self propertyAt: #parent put: aNestedPart!
getLabelFor: aSymbol
        " Answer the label string representing the 
        event or message named <aSymbol>. "

    | numDataSlots aLabel dataSlotCharacter |
    numDataSlots := Message numberOfArgumentsFor: aSymbol.
    aLabel := ReadWriteStream on: 
        ( String new: ( aSymbol size + numDataSlots ) ).
    dataSlotCharacter := self dataSlotCharacter.
    aSymbol do: [ :c |
        aLabel nextPut: c.
        ( c = $: ) ifTrue: [ aLabel nextPut: dataSlotCharacter ] ].
    aLabel := aLabel contents.
    numDataSlots = 1  " binary selector backstop "
        ifTrue: [ aLabel at: aLabel size put: dataSlotCharacter ].
    ^aLabel!
linkArgument: argumentIndex toEventValue: eventValueIndex
        " Create and install an argument link in the receiver
        which collects the <argumentIndex>-th argument for 
        the message sent by the receiver from the
        <eventValueIndex>-th value of the triggering event.
        Answer the new argument link. "

    | aLink |
    aLink := PARTSLink
        internalArgumentLinkFor: self
        inputArgument: eventValueIndex
        messageArgument: argumentIndex.
    messageArgLinks at: argumentIndex put: aLink.
    ^aLink!   
bitmapFileTypes

    ^Array
        with: self fileTypeForBitmap
        with: self fileTypeForAll!   
searchPathName: aPathName
    "Answer an instance of a subclass of PARTSFileDescriptor."
    | dir |

    aPathName isString ifFalse: [
        ^aPathName ].  "already a descriptor"
    (aPathName fileNameLessPath ~= aPathName)
        ifTrue: [
                dir := Disk ]
        ifFalse: [ "<aPathName> is a file name"
                ( dir := PARTSFile directoryContaining: aPathName
					ifNone: [nil]) isNil
						ifTrue: [ ^nil ]].
    ^self pathName: aPathName in: dir!  
removeChangeMapForClass: aClassName forVersion: aFileVersion
        " Remove any ObjectChangeMap registered for loading
        <aClassName> in applications stored from aFileVersion. "

    self
        removeChangeMapsSatisfying: [ :aChangeMap |
            aChangeMap sourceClassName = aClassName asString ]
        forVersion: aFileVersion!   
timeStamp
    "Answer the time stamp of the receiver."

    ^PARTSTimeStamp forFile: ( File fromPath: self fullPathName ).!
asPARTSLinkFor: anObject event: anEvent
        "Private - answer a PARTSLink having the semantics of the receiver."
    | answer |
    answer := super asPARTSLinkFor: anObject event: anEvent.
    resultAction notNil ifTrue: [
        answer resultAction:
            ( resultAction
                asPARTSLinkFor: answer
                event: answer class resultLinkTrigger ) ].
    ^answer
!  
upgradeMapsForLoadingPWW301
        " Private - answer the upgrade load maps for
        structure changes in the current version. "
	"There were no shape changes between 3.0.1 and 3.0"
	^self upgradeMapsForLoadingPWW30!  
sourceString
        "Answer the uncompressed source
         code for the receiver."

    ^sourceObject source!  
fileAccessorClass
        " Private "

    ^FileAccessorClass! 
helpAndHintFromFile: aFileReference
        " Answer the help and hint strings stored in
        the file named aFileReference on the PARTS search path
        as an array of strings (help file name, help topic, hint). "

    ^[ self
        helpAndHintFromFile: aFileReference
        in: ( self directoryContaining: aFileReference )]
            on: PARTSApplicationLoadError
            do: [ :e |
                e postMessageBox: 'Help and Hint File Load Error'.
                ^nil ]!
loadFrom: file context: loadContext
    "Load a PARTSApplication for execute from the external storage
    described by <file>.  <loadContext> is a PARTSLoadContext
    indicating the environment the load was initiated.
    <file> can be either a PARTSFileDescriptor or a
    String of path name.
    NOTE: This loads an executable part and does not have
    all the workbench information."

    | fileDescriptor |

    ( file isKindOf: PARTSFileDescriptor )
        ifTrue: [ fileDescriptor := file ]
        ifFalse: [
            file isString
                ifTrue: [ fileDescriptor := PARTSDosFileDescriptor for: file ]
                ifFalse: [
                    MessageBox message: 'Illegal file spec: ', file printString.
                    ^nil ] ].
    ^fileDescriptor loadForExecuteWithContext: loadContext!
isPathNameInPath: pathName
        " Answer whether the fully-qualified file
        pathName is the one which will be found
        on the search path. "

    | fileName directory |
    fileName := pathName asString fileNameLessPath.
    ( directory := self directoryContaining: fileName ) isNil
        ifTrue: [ ^false ].   " not on search path "
    ^self
        isPathName: pathName
        sameAsDirectory: directory!   
partIcon
        " Answer the receiver's icon. "
    | answer |
    answer := self partWrapper iconAttribute.
    answer isNil ifTrue: [
        answer := PARTSApplication defaultIcon ].
    ^answer! 
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream. "

    aStream nextPutAll: ( wrapper notNil
        ifTrue: [ self name ]
        ifFalse: [ 'a' ] ).
    aStream nextPutAll: ' PARTSApplication'!  
description
    ^description!
exists: aPathNameOrDescriptor in: aDirectory
    "Answer true if the file specified
    by aFileName exists, else return false."
    | fileName |

    aDirectory isNil
        ifTrue: [ ^false ].

    fileName := aPathNameOrDescriptor isString
        ifTrue: [ aPathNameOrDescriptor ]
        ifFalse: [ aPathNameOrDescriptor fileName ].

    ^aDirectory asPARTSDirectory hasEntityNamed: fileName!
iconFromICOFile: aFileReference
        " Answer the icon stored in aFileReference,
        where aFileReference is a standard (.ICO) icon file
        on the PARTS search path. "

    ^self iconFromICOFile: aFileReference
        ifNone: [
            PARTSNotOnSearchPath signalForFile: aFileReference.
            ^nil ]!  
addEditStateMessagesTo: aMessageExpressionModel
        "Private - add messages to aMessageExpressionModel to set the
        edit state of a rebuilt version of the receiver.  The receiver object
        of aMessageExpressionModel is a parts application."
    aMessageExpressionModel
        addSelector: #linkReferencedBy:editState:
        with: self linkReference
        with: editState.
    self dependentLinks do: [ :link |
        link addEditStateMessagesTo: aMessageExpressionModel ]
!  
canTriggerEvent: eventName
    "Answer <true> if the receiver can trigger an event
     named <eventName>. "

    ^self partEvents items includes: eventName asSymbol!
horizontalInsetFrom: number1 to: number2
    "Private - Answer inset between number1 and
     number2 horizontally independent of platforms."

    ^ ( 2 isRightOf: 1 )
        ifTrue: [ number2 - number1 ]
        ifFalse: [ number1 - number2 ]!   
versionCanBeLoaded: aVersionString
        " Answer whether file version aVersionString
        can be read. "

    ^self  fileAccessorClass versionCanBeLoaded: aVersionString!  
isWorkbenchSession
        " Answer whether this is a PARTS Workbench session. "

    ^( Smalltalk at: #PARTSEditor ifAbsent: [ nil ] ) notNil!
settingsFileSearchPathTag
        " Private "
    ^'searchPath'!
describeApplicationInPathName: aPathName newFile: reportFileName
        " Write a report to the file named <reportFileName>
        describing the objects stored in the PARTS application in
        the .PAR file named <aPathName>. "

    | partFileStream reportFileStream |
    CursorManager execute 
		changeFor: [
    		partFileStream := File pathNameReadOnly: aPathName.
    		reportFileStream := File newFile: reportFileName.
    		self fileAccessorClass new
        		describeApplicationIn: partFileStream
        		on: reportFileStream
        		includeDetails: true.
    		partFileStream close.
    		reportFileStream close.
			].!   
asPARTSLinkFor: anObject event: anEvent
        "Private - answer a PARTSLink having the semantics of the receiver."
    ^PARTSLink
        source: anObject
        trigger: anEvent
        receiver: anObject
        selector: elementName! 
title: aString
        " Set the application title "

    property title: aString.!
replaceWith: aLink
        " Replace the receiver with <aLink>.  Insure the
    source references <aLink>. "
    | eventHandlers index |

    self isEventLink
        ifTrue: [
            ( index :=
                ( eventHandlers := source eventHandlersAttribute at: trigger )
                    indexOf: self ) > 0
                ifTrue: [ eventHandlers at: index put: aLink ] ].
    self isResultLink
        ifTrue: [ source resultLink: aLink ].
    ( self isEventLink or: [ self isResultLink ])
        ifTrue: [
            self messageArgLinks size > 0
                ifTrue: [
                    self messageArgLinks do: [ :anArgLink |
                        anArgLink source: aLink ]].
            ^self ].

    source messageArgLinks at: trigger put: aLink!
applicationForEdit
        "Answer the PARTSApplication that the receiver knows how to build
        configured to be editable."
    | application |
    application := self applicationCore.
    self attachEditInformationIn: application.
    ^application
!
open
        "Private - Open Timer aux window. "

    | result |
    self 
        partsIfOS2Do: [
            ^super open ]
        partsIfWindowsDo: [ 
            result := self createWindow.
            result notNil
                ifTrue: [ Notifier add: self ].
            ^result ].!   
keepInExecutable
    "Answer whether wrappers should be included in
    executable applications"

    ^KeepInExecutable notNil and: [ KeepInExecutable ]
!   
fromExePathName: aPathNameOrDescriptor
        "Answer the application stored in the .exe format file
        named aPathName. "
    | fileDescriptor fileName paxType |

    aPathNameOrDescriptor isNil
        ifTrue: [
            ^PARTSFileNotFound signalForFile: aPathNameOrDescriptor ].

    fileDescriptor := PARTSFileDescriptor pathName: aPathNameOrDescriptor.
    paxType := PARTSFileDescriptor fileTypeForExecutablePart type.

    fileDescriptor
        fileName: ( fileDescriptor fileName fileName, '.', paxType );
        fileType: paxType.

    ^self fromPathName: fileDescriptor!   
currentSearchPathNames
        " Answer the display names of the directories
        on the PARTS search path. "

    ^self currentSearchPath collect: [ :aDirectory |
         aDirectory displayName ]   "directory descriptors"!  
addScriptRepresentationsTo: aClassModel
        "Private - add code to manage all the scripts of the receiver
        and its components to aClassModel."
    | scripts partWrapper |
    componentDictionary do: [ :part |
        partWrapper := part partWrapper.
        scripts := partWrapper scripts.
        scripts do: [ :script |
            self addScriptRepresentation: script to: aClassModel for: part ]]

!   
initialize
        " Private - initialize class state at installation time. "

	self fileAccessorClass initializeVersionInfo.
    self
        setDefaultSearchPath;
        initializeVersionInfo;
        initializeUpgradeChangeMaps.!  
partHint: aString
        "Specify a string which gives a brief description
        of the receiver part. "

    property hint: aString!  
leftTopEventLabel: aPoint
        " Specify the offset of the top left corner of the link's event label
        from the path's launch point. "
    leftTopEventLabel := aPoint.!  
settings: settingsValue
        " Set the saved editor preference settings. "
    settings := settingsValue!
partApplication
        " Answer the PARTS application which contains the receiver. "
    ^receiver partApplication!
editorVirtualScreenExtent
        "Private -  Answer the editor's virtual screen extent. "

    ^editorState virtualScreenExtent!  
fromExeFile: aFileName in: aDirectory
        "Answer the application stored in the .exe format file
        named aFileName in aDirectory.  Retained for backward
        compatibility.    The executable parts application is located
        in the .pax file."
    | fileName |

    aFileName isNil ifTrue: [ ^nil ].

    fileName := aFileName fileExtension asLowerCase = 'exe'
        ifTrue: [
            aFileName fileName, '.',
                PARTSFileDescriptor fileTypeForExecutablePart type ]
        ifFalse: [ aFileName ].

    ^self fromFile: fileName in: aDirectory! 
platformProductName
        " Answer the PARTS Workbench product platform name. "

    ^PlatformProductName!   
applicationFromFile: aFileReference
        " Answer the PARTS application stored in aFileReference,
        where aFileReference is a file on the PARTS search path.
        The application is in editable form and has not yet
        been enabled for execution. "

    ^self applicationFromFile: aFileReference
        ifNone: [
            PARTSNotOnSearchPath signalForFile: aFileReference.
            ^nil ]! 
fromStream: aFileStream debugger: aDebugger
        " Private - guts of getting app from file.  Closes the stream. "

    | anApplication |

    aFileStream size = 0
        ifTrue: [
            aFileStream close.
            PARTSEmptyFile signalForFile: aFileStream file name.
            ^nil ].
    CursorManager execute
        changeFor: [
            anApplication := PARTSFile fileAccessorClass new
                   objectFrom: aFileStream
                debugger: aDebugger.
            aFileStream close ].
    ^anApplication isPARTSApplication
        ifTrue: [ anApplication ]
        ifFalse: [ nil ]!  
launchSide
        " Answer the side of the link's source object to which
        the launch point of its path is attached. "
    ^launchSide! 
useMode
	"Private - #merge, #embed, or #reference. 
	Used to propagate the useMode of a top level nested part
	to one of its lower level nested parts, so that a top
	level part can override the useMode of the lower parts."

    ^useMode!   
instantiatePartsIn: anApplication
        "Private - instantiate the component parts of anApplication
        and store them in anApplication's component dictinary."
    self implementedBySubclass!  
useMode: aSymbol
        " Private "
    useMode := aSymbol!
descriptionSource: application
        " Private - answer a description of the source end of
        the receiver. "

    | component triggerLabel |
    self isResultLink
        ifTrue: [
            component := source destinationObject.
            triggerLabel := self class getLabelFor: source selector.
            ^( application componentNameOf: component ifAbsent: [ '*Invalid component*' ]),
                    ' [', triggerLabel, '] result'
            ].
    self isArgumentLink
        ifTrue: [
            component := source destinationObject.
            triggerLabel := self class getLabelFor:
                ( source messageArgumentName: trigger ).
            ^( application componentNameOf: component ifAbsent: [ '*Invalid component*' ]),
                ' <', triggerLabel, ' argument>'
            ].
    ^( component := self sourceObject ) isPARTSApplication
        ifTrue: [
            'External [', ( self class getLabelFor: trigger ), ']' ]
        ifFalse: [
            ( application componentNameOf: component ifAbsent: [ '*Invalid component*' ]),
                 ' <', ( self class getLabelFor: trigger ), '>']!   
attachScriptsIn: anApplication
        "Private - attach all the scripts in anApplication."
    | array partName methodSelector scriptSelector method part script methodSource scriptSource |
    self methodDictionary associationsDo: [ :assoc |
        methodSelector := assoc key.
        array := self extractPartAndScriptNameFrom: methodSelector.
        partName := array first.
        scriptSelector := array at: 2.
        part := anApplication componentNamed: partName.
        method := assoc value.
        script := method partAsScript.
        methodSource := method sourceString.
        scriptSource := methodSource
            copyFrom: ( methodSelector size - scriptSelector size + 1 )
            to: methodSource size.
        script selector: scriptSelector.
        script
            setSource: scriptSource
            componentNameDictionary: anApplication componentDictionary
            part: part.
        script fixReferencesIn: anApplication componentDictionary.
        part partAddScript: script ]!   
extent: size
        "Set the extent of the factory pane in LAFEditor (including non-visible area)."
        "This method kept only to support existing generated code, will be removed
        in a subsequent release."
    self virtualScreenExtent: size
!   
menuClickedActionOf: anExternalEvent
        " Answer the action on the receiving end of a link from
        the clicked event of a menu label part or a menu item part
        in a containing application.  This is a special service for
        building the menu bar or a submenu for application
        execution to handle the case where the menu part linked
        to a menu label / menu item  #clicked event is contained
        outside the application. "
    | actionOrLink nestedPart |

    ^( actionOrLink := self isEditable
        ifTrue: [  "Event info not yet migrated from enclosing nested part"
            ( self parent notNil
                  and: [ nestedPart := self parent ]) isPARTSNestedPart
                ifTrue: [ nestedPart actionForEvent: anExternalEvent ]
                ifFalse: [ nil ]]
        ifFalse: [ self actionForEvent: anExternalEvent ]) isNil
            ifTrue: [ nil ]
            ifFalse: [ actionOrLink isCollection
                ifTrue: [
                    actionOrLink notEmpty
                        ifTrue: [ actionOrLink first ]
                        ifFalse: [ nil ]]
                ifFalse: [ actionOrLink ] ]!   
orderedChildren
        "Answer an OrderedCollection which is the
        ordering of the children for tab and arrow keys."

    | orderedChildren|
    orderedChildren := self propertyAt: #PARTSOrderedChildren.
    orderedChildren isNil
        ifTrue: [
            orderedChildren := OrderedCollection new.
            self orderedChildren: orderedChildren].
    ^ orderedChildren! 
userPropertyNamed: propertyNameString
        " Answer the value of the user property named <propertyNameString>. "

    ^self userPropertyNamed: propertyNameString ifAbsent: [ nil ]!
partMessages
        " Answer the PARTS message interface of the receiver. "
    | messages interface |
    messages :=
        self staticMessages , self dynamicMessages.
    interface := PARTSInterfaceList new
        items: messages;
        separators: (self dynamicMessages size > 0
            ifTrue: [Array with: self staticMessages size]
            ifFalse: [#()]).
    (messages size > 0)
        ifTrue: [interface defaultItem: messages first].
    ^interface!  
partDefineScript: scriptSourceString
        " Compile the text in scriptSourceString as a
        PARTS script.  Answer the message selector
        of the script (nil if it did not compile). "

    self error: 'application cannot have scripts'!   
load
        "Load the application to be used at runtime."
    self loadApplication!
landingSide
        " Answer the side of the link's destination object to which
        the landing point of its path is attached. "
    ^landingSide! 
name
        " Answer the application name. "

    ^self partName! 
printOn: aStream

    super printOn: aStream.
    self directory notNil
        ifTrue: [ aStream nextPutAll: ' on: ', self fullPathName ].!  
items: itemList defaultItem: anItem
        " Specify the items and the default item in the receiver. "

    items := itemList.
    "self ASSERT: anItem notNil."  " fix client!!!! "
    defaultItem := anItem.!
propertiesFromFile: aFileReference
        " Answer the properties stored in the file
        named aFileReference on the PARTS search path
        as a dictionary of name/value string pairs. "
    | dir |

    ( aFileReference isNil
        or: [( dir := self directoryContaining: aFileReference ) isNil ])
        ifTrue: [ ^nil ].
    ^self propertiesFromFile: aFileReference in: dir!  
isPARTSScript
        "Answer whether the receiver is a PARTS script."
    ^true!   
description
        " Answer the application description. "

    ^property description!
now
        " Answer a timestamp for right now. "
    ^self  date: Date today time: Time now!   
defaultIcon: anIcon
        " Private - initialize the default application icon. "

    DefaultIcon := anIcon.!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy :=
        aMirrorCopyDictionary forDebug
            ifTrue: [ self debugLinkClass basicNew debugger: aMirrorCopyDictionary debugger ]
            ifFalse: [
                aMirrorCopyDictionary forExecute
                    ifTrue: [
                        self isInternalArgumentLink
                            ifTrue: [ CollectionAccessor for: selector ]
                            ifFalse: [ self executionMessageClass basicNew ] ]
                    ifFalse: [ self class basicNew ] ] ).
    copy class = CollectionAccessor
        ifTrue: [ ^copy ].
    copy
        receiver: (receiver partMirrorCopy: aMirrorCopyDictionary);
        selector: selector;
        arguments: (self arguments partMirrorCopy: aMirrorCopyDictionary);
        resultAction: (resultLink partMirrorCopy: aMirrorCopyDictionary);
        yourself.
    copy isPARTSLink
        ifTrue: [
            copy
                source: (source partMirrorCopy: aMirrorCopyDictionary);
                trigger: trigger;
                traceFire: traceFire;
                yourself.
            aMirrorCopyDictionary forExecute
                ifFalse: [
                    copy editState: (editState partMirrorCopy: aMirrorCopyDictionary) ].
            ].
    ^copy! 
initializeWorkbenchSupportLibraries
        " Private - initialize the part workbench support libraries information. "

    self
        workbenchSupportLibraries: Dictionary new;
        workbenchSupportLibraryIndex: 0.!
fromEditableFileForExecute: aFileName
    "Load the editable application on <aPathName>
    convert it to executable form (.pax) and answer the
    executable application."
    | anApplication |

    [ anApplication := PARTSFile applicationFromFile: aFileName ]
        on: PARTSApplicationLoadError
        do: [ :e | e postMessageBox ].

    ^anApplication notNil
        ifTrue: [
            ( anApplication
                partMirrorCopyReal: ( PARTSMirrorCopyDictionary for: #saveExecutable ))
                enableExecution: false;
                yourself ]
        ifFalse: [ nil ]
!
arguments
        "Answer the arguments array for the message.
        Supported for polymorphism with Message. "

    ^messageArgLinks isNil
        ifTrue: [ #() ]
        ifFalse: [ messageArgLinks ]! 
helpAndHintFromFile: aFileReference in: aDirectory
        " Answer the help and hint strings stored in
        the file named aFileReference in aDirectory
        as an array of strings (help file name, help topic, hint). "

    | aFileStream hhArray |
    aFileStream := ( PARTSFileDescriptor fileName: aFileReference in: aDirectory )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ hhArray := self helpAndHintFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^hhArray!  
initialize
    demandLoad := true.!  
enableExecution
        " Prepare the receiver to be executed. "

    self enableExecution: false.!
relativeTo: aRect
        "Private - Make receiver relative to aRect. scaleMask indicates
         which coordinates will be subject to relativity. The
         receiver coordinates must be fixed (non-relative)."

    | extent width height |
    extent := aRect extent.
    width := self pixelToScaleUnitHorizontal: extent x.
    height := self pixelToScaleUnitVertical: extent y.

    ^self class new
        scaleUnit: scaleUnit;
        left:
            ( self isLeftStretched
                ifTrue: [(left / width) ]
                ifFalse: [left])
        bottom:
            ( self isBottomStretched
                ifTrue: [(bottom / height) ]
                ifFalse: [bottom])
        right:
            ( self isRightStretched
                ifTrue: [(right / width) ]
                ifFalse: [right])
        top:
            ( self isTopStretched
                ifTrue: [(top / height) ]
                ifFalse: [top]);

        scaleMask: mask! 
forExecutableFile
        " Answer whether the copy is going to be
        saved in an executable .EXE file. "

    ^self operation = #saveExecutable!
propertiesCreate
        " Private - allocate the dictionary if necessary. "

    properties isNil
        ifTrue: [ properties := Dictionary new ].
    ^properties!
propertyAt: key put: aValue
        "Private - Set the value associated with key
        in the properties dictionary."

    properties isNil ifTrue: [properties := IdentityDictionary new].
    aValue isNil ifTrue: [
        properties removeKey: key ifAbsent: [].
        (properties size = 0) ifTrue: [properties := nil].
        ^key].
    properties at: key put: aValue.!  
debugger: aDebugger
         " Private - specify the PARTS debugger associated with the current load operation. "

    debugger := aDebugger.! 
canBeLoaded: aBoolean
		" Specify whether this version can be loaded
		by the current system. "

	canBeLoaded := aBoolean.!   
getLabelsFor: symbolList
        " Answer the label strings representing the event 
        or message names in <symbolList>. "

    ^symbolList collect: [ :aSymbol |
        self getLabelFor: aSymbol ]!  
initializeFileRegistry
    " Private - initialize the file processor registry of
    the current file processors.  Additional file processors
    must send registerClass: when bound."

    self fileTypeRegistry:
        ( self allSubclasses collect: [ :aClass | aClass asString ] ).! 
partHint
        "Answer a string which gives a brief description
        of the receiver. "

    | containingApplication  |
    containingApplication := self application.
    ^'Link ',
        ( self lafExplainSourceIn: containingApplication ),
        ' to ',
        ( self lafExplainDestinationIn: containingApplication )!   
scaledRectangleLeftTop
		"Private - Before the receiver is upgrade to a valid PARTSFramer
		it contains the state of a ScaledRectangle.  Instance variable mappings:
		PARTSFramer	ScaledRectangle
		mask 				styleMask 
		left					leftTop
		right					rightBottom
		"
	^left!   
messageArgLinks: anArrayOfLinks
        " Private - set the list of links which are fired to collect
        the argument values when the receiver is fired. "

    messageArgLinks := anArrayOfLinks!
contents
        "Answer the label of the reciever."
    ^self propertyAt: #topLabel!   
fromFileOrEditor: aFileReference debugger: aDebugger
        " Answer the most current version of the
        application in aFileName. "
    | dir |
    ( dir := PARTSFile directoryContaining: aFileReference ) isNil
        ifTrue: [ ^nil ].

    ^self
        fromFileOrEditor: aFileReference
        in: dir
        debugger: aDebugger! 
activeTimers
        " Answer all the currently running timers "
    ^items values! 
componentNamesHierarchy: wrappers
    names: names
    indent: indent
        " Private - build heirarchical names list "

    | childWrappers |
    childWrappers := SortedCollection sortBlock:
        [ :w1 :w2 | w1 name <= w2 name].
    wrappers do: [ :aWrapper |
        names add:
            ( ( String new: indent ) atAllPut: Space; yourself ),
            aWrapper name.
        childWrappers
            removeAll;
            addAll: ( aWrapper components
                reject: [ :w | w object isPARTSTransientPart ] ).
        ( aWrapper components select: [ :w | w object isPARTSTransientPart ] )
            do: [ :aTransientWrapper |
                childWrappers addAll: aTransientWrapper components ].
        self
            componentNamesHierarchy: childWrappers
            names: names
            indent: indent + 2.
        ].!
source
        "Private - answer the wrapper or link which triggers the receiver."

    ^source!   
referencedParts
        " Answer the names of all part files referenced
        by the receiver.  Append any revision number
        to the name with a semicolon separator. "

    | referencedParts aFileName revisionString |
    referencedParts := SortedCollection new.
    self components do: [ :aPart |
        ( aPart isPARTSNestedPart
        and: [ aPart isLinked
        and: [ ( aFileName := aPart fileName ) size > 0 ] ] )
            ifTrue: [
                revisionString := aPart fileDescriptor revisionNumber.
                revisionString notNil
                    ifTrue: [ aFileName := aFileName, ';', revisionString ].
                referencedParts add: aFileName ].
        ].
    ^referencedParts asArray!
COMMENT
"PARTSDosDirectory

. "!   
fileTypesForEditing
        "Answer an indexed collection of the file types that are editable."
    | processors editableProcessors fileTypes |
    processors := PARTSFileProcessor getProcessors.
    editableProcessors := processors select: [ :processor |
        processor isAvailable and: [ processor canEdit ]].
    fileTypes := editableProcessors collect: [ :processor | processor fileType first ].
    ^fileTypes asOrderedCollection! 
fileTypeForExecutablePart

    "^self fileTypeFor: 'PAX'"
    ^PARTSFileType type: 'PAX' pattern: '*.PAX' description: 'Executable part (*.PAX)'!  
describeClassesInPathName: aPathName
        " Display a report describing the classes stored in the
        PARTS application in the .PAR file named <aPathName>. "

    | partFileStream reportStream |
    CursorManager execute 
		changeFor: [
    		partFileStream := File pathNameReadOnly: aPathName.
    		reportStream := ReadWriteStream on: String new.
    		self fileAccessorClass new
        		describeApplicationIn: partFileStream
        		on: reportStream
        		includeDetails: false.
    		partFileStream close.
    		].
    TextWindow new openOn: reportStream contents.!   
iconFromFile: aFileReference
        " Answer the icon stored in the file
        named aFileReference on the PARTS search path. "

    ^self iconFromFile: aFileReference
        ifNone: [
            PARTSNotOnSearchPath signalForFile: aFileReference.
            ^nil ]!   
fullPathName
    "Answer the full path name of the receiver."

    ^self class
        stringFrom: self fileName
        in: self directory! 
eventTable
        "Private - answer the table of event handlers for the receiver."
    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]!  
embeddedParts
        " Answer the names of the original part files of
        embedded nested parts in the receiver.  Append any
        revision number to the name with a semicolon separator. "

    | embeddedParts aFileName revisionString |
    embeddedParts := SortedCollection new.
    self components do: [ :aPart |
        ( aPart isPARTSNestedPart
        and: [ aPart isLinked not
        and: [ ( aFileName := aPart fileName ) size > 0 ] ] )
            ifTrue: [
                revisionString := aPart fileDescriptor revisionNumber.
                revisionString notNil
                    ifTrue: [ aFileName := aFileName, ';', revisionString ].
                embeddedParts add: aFileName ].
        ].
    ^embeddedParts asArray!   
isOkToSaveContents: aFileDescriptor
        " Private - Answer a Boolean if it is ok to save the contents of
        the workbench which was opened due to edit contents of the receiver
        to a FileDescriptor.  Part accessor does not mind any of this saving. "
    ^true!   
COMMENT
"
A PARTSScriptDictionary contains the scripts (instance methods)
of a part in a PARTS application.

This class is private to the PARTS Workbench implementation.
It is maintained by the workbench and script editors and should
not be manipulated directly by clients.

To programmatically create and delete scripts, use the public
protocol supported by all parts:
    partDefineScript: scriptSourceString
    partScriptSourceOf: scriptMessageSelector
    partRemoveScript: scriptMessageSelector

Script manipulations are only supported in the workbench environment.

"!  
isVerticallyCentered
    ^( self isTopInset or: [ self isBottomInset ] ) not!
initializeVersionInfo
        " Private - inititalize platform-dependent version information. "

    self currentVersion: self constructCurrentVersion.!   
defaultScaleUnit: aScaleUnit
        "Private- Set the application's default scale
    unit used for icons and links on the workbench."

    ^self
        propertyAt: #defaultScaleUnit
        put: aScaleUnit!   
pathName: aPathName in: aDirectory
    "Answer an instance of a subclass of PARTSFileDescriptor."
    | fileSystemPath dir file |

    ( aPathName isString )
        ifFalse: [ ^aPathName ].

    fileSystemPath :=
        ( self stringFrom: aPathName in: aDirectory ) asFileSystemPath.
    file := fileSystemPath entityName.
    dir := fileSystemPath parentPath asDirectory.

    ^self fileName: file in: dir.!
realSelector: aSymbol
        " Private - specify the 2-argument message selector to 
        really send to the destination object when the receiver is fired. "

    realSelector := aSymbol.!  
at: aKey
        " Answer the value for the user-defined property named <aKey>. "

    properties isNil ifTrue: [ ^self error: 'Key is missing '].
    ^properties at: aKey!  
fileOutSurrogateForLiteral: anAssoc pools: anArrayOfDictionaries for: anObjectFiler
        " Private - answer an external reference
        for the literal <anAssoc> in the receiver.
        References to components in the application
        containing the receiver's part are filed out as
        the original assoc (which is stored in the
        application's componentDictionary).   Other
        references are handled in the usual fashion. "

	^self componentNameDictionary
        associationAt: anAssoc key
        ifAbsent: [
            super fileOutSurrogateForLiteral: anAssoc
                pools: anArrayOfDictionaries
                for: anObjectFiler
            ]!  
unbind
        "Private - maintainance."
    | library |
    library := self library.
    library notNil ifTrue: [ library unBind ]!  
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  When aSelector is an external event
        of the application, map it to the relay method which
        triggers the external event in a containing application. "

    ( self hasExternalEvent: aSelector )
        ifTrue: [ ^#triggerEvent:withArguments: ].
    ( self hasExternalMessage: aSelector )
        ifTrue: [ ^#triggerInternalEvent:withArguments: ].
    ^aSelector! 
partAboutToAddTo: anApplication
        "The receiver is about to be added as a part to
        anApplication.  Wrap a nested part
        around the receiver when it is dragged into
        a PARTS workbench. "
    

    self isEditable
        ifTrue: [
            ^PARTSNestedPart new
                fileDescriptor: self fileDescriptor;
                copyMode:
                    ( self fileDescriptor isNil
                        ifTrue: [ #embed ]
                        ifFalse: [ self reuseMode ]);
                application: self;
                maintainRectangle: false;
                yourself ].
    self isExecutable
        ifTrue: [
             ^PARTSPartAccessorPart new
                fileDescriptor: self fileDescriptor;
                application: self;
                yourself ].
    MessageBox warning: 'Cannot edit debuggable application.'.
    ^nil!   
eventTable
        "Private - answer the table of event handlers for the receiver.
        These events actually belong to the application's editor. "
    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]!  
fromPathNameOrEditor: aPathName
        " Answer the most current version of the
        application in aPathName. "

    ^self fromPathNameOrEditor: aPathName debugger: nil!
directoryContaining: aFileReference
        " Answer the first directory on the PARTS search path
        containing aFileReference.
        An exception will be raised if <aFileReference could not
        be found on the search path."

    ^self directoryContaining: aFileReference raiseError: true!
icon: anIcon
        " Set the application's icon property. "

    icon := anIcon! 
partEditDirect
        "Edit the directly visible part properties of the receiver."

    self partEditor workbenchPane lafEditNone: self.! 
initialize
        " Private - initialize a new link. "

    super initialize.
    realSelector := receiver partRealSelectorFor: selector.
    "self ASSERT: realSelector ~= selector."
    ( ( Message numberOfArgumentsFor: realSelector ) = 2 )
        ifFalse: [ self error: 'alias link requires 2-argument selector' ].!
filePathName
    "Private - Answer the full path name of the receiver"

    ^file asString!
findWrapper: aPart
        " Answer the PARTS wrapper of <aPart>
        in the receiver. "

    ^wrapper findWrapper: aPart! 
reuseMode: aSymbol
        " Specify the application's reuseMode. "

    ( self class supportedReuseModes includes: aSymbol )
        ifFalse: [ self error: 'unsupported reuse mode' ].
    property reuseMode: aSymbol.!   
loadFrom: file
    "Load a PARTSApplication for execute whose external storage is described
    by <file>.

    <file> can be either a PARTSFileDescriptor or a
    String of path name."

    ^self loadFrom: file
        context: ( PARTSLoadContext new
            fileDescriptor: self;
            yourself ).!  
application
        " Answer the nested application "
    application isNil ifTrue: [
        self loadApplication].
    ^application!
items: itemList separatorMarker: marker defaultItem: anItem
        " Specify the items and separators and default item
        in the receiver.  separators are specified as markers embeded inside
        the itemList."
    | interface symbol |
    separators := OrderedCollection new.
    interface := OrderedCollection new.
    1 to: itemList size do: [ :i |
        symbol := itemList at: i.
        symbol = marker
            ifTrue: [ separators add: ( i - 1 - separators size ) ]
            ifFalse: [ interface add: symbol ] ].
    separators := separators asArray.
    ^self
        items: interface asArray
        defaultItem: anItem! 
editState
        " Private - answer the edit state information of the receiver. "

    ^editState!
loadForExecuteWithContext: aLoadContext
    "Load the part described by the receiver to be executed.
    <loadContext> can specify a debugger."
    | aStream application processor |

    self fileType =
        PARTSFileDescriptor fileTypeForExe type
     ifTrue: [ "Do not allow loading EXE"
        ^nil ].

    ( processor := self fileProcessor )
        isNil ifTrue: [ ^ nil ].
    ( aStream := self asReadStream ) isNil
        ifTrue: [ ^nil ].
    [ application := processor
        loadFrom: aStream
        context: aLoadContext ]
            ensure: [ aStream close ].
    application notNil ifTrue: [
            application enableExecution: aLoadContext debugger notNil ].
    ^ application!  
referencesArgumentLink
        "Private - answer true if the link the receiver refers to is an argument link."
    ^self referencesArgumentLink not
!  
loadSearchPath: searchPathString
        " Private - validate and install the search path "

    | directoryList rs aDirName aDir |
    searchPathString isNil
        ifTrue: [
            PARTSFile setDefaultSearchPath.
            ^self ].
    directoryList := OrderedCollection new.
    rs := ReadStream on: searchPathString.
    [ rs atEnd ] whileFalse: [
        aDirName := ( rs upTo: $; ) trimBlanks.
        aDirName = '.'
            ifTrue: [ directoryList add: ( PARTSDosDirectory fromPath: Disk drivePathName ) ]
            ifFalse: [
                aDir := PARTSDosDirectory fromPath: aDirName.
                aDir valid ifTrue: [ directoryList add: aDir ] ].
        ].
    directoryList isEmpty
        ifTrue: [
            PARTSFile setDefaultSearchPath.
            ^self ].
    PARTSFile setSearchPath: directoryList.!
checkList
    PARTSFile setSearchPath: PARTSFile currentSearchPath!  
partIcon: anIcon
        " Set the receiver's icon to anIcon. "

    self partWrapper icon: anIcon.
    anIcon
        connection: self;
        label: self partName;
        showLabel: true.!   
warningPathConflict: pathName withDirectory: directory
        " Private - display a warning about a search path conflict. "

    MessageBox warning:
        'Cannot use ', pathName,
        ' (search path conflict with ',
        directory drivePathName, '\',
        pathName fileNameLessPath, ').'.! 
scalingNeeded
        " Private - answer whether scaling of rectangles is needed. "

    ^scaleFactor ~= (1 @ 1)!  
version: aString
        " Set the application version "

    property version: aString!   
messageArgLinks
        " Private - answer the list of links which are fired to collect
        the argument values when the receiver is fired. "

    ^messageArgLinks!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelector: #partName:event:index:
        with: partName
        with: event
        with: index
!  
isNewerThan: aTimestamp
        "Answer whether the receiver is newer
         than aTimestamp."

    aTimestamp isNil ifTrue: [^true].
    ^self > aTimestamp!  
description: aString
    " All (*.*), Part (*.PAR) "

    description := aString!  
openFileReadOnly: aFileName ifNone: aBlock
    " Answer a ReadOnly filestream on aFileName
    in the first directory on the PARTS search path
    containing it. "
    | aDirectory |

    aDirectory := self directoryContaining: aFileName
        ifNone: [ ^aBlock value ].
    ^aDirectory fileReadOnly: aFileName! 
addScriptRepresentation: aScript to: aClassModel for: aComponent
        "Private - add a representation of aScript to aClassModel."
    | componentName source newSource newSelector methodModel |
    source := aScript sourceString trimBlanks.
    componentName := WriteStream on: String new.
    aComponent partName do: [ :c |
        componentName nextPut: c.
        c = $_ ifTrue: [
                "Need to double '_'s to indicate NOT a part name/script name division."
            componentName nextPut: c ]].
    componentName := componentName contents.
    newSource := componentName, '_', source.
    newSelector := ( componentName, '_', aScript selector ) asSymbol.
    methodModel := aClassModel newInstanceMethodNamed: newSelector.
    methodModel setSourceCode: newSource!
dynamicMessages
        "Private - Answer a collection of selectors for the messages supported
        by the contained application."

    self validateApplication.
    ^self application notNil
        ifTrue: [ self application externalMessages asSortedCollection asArray ]
        ifFalse: [ #() ]!   
storeOnPathName: aPathName
        " Store the application to a new file named
        aPathName.  Answer the file name.  "

    ^self storeOnPathName: aPathName libraryMappings: nil!   
linkArgument: argumentIndex to: aPart message: messageName
        " Create and install an argument link in the receiver
        which collects the <argumentIndex>-th argument for 
        the message sent by the receiver by sending the
        message named <messageName> to <aPart>.
        Answer the new argument link. "

    | messageSelector aLink |
    messageSelector := messageName asSymbol.
    aLink := ( aPart partLinkClassFor: messageSelector )
        source: self
        trigger: argumentIndex
         receiver: aPart
        selector: messageSelector.
    messageArgLinks at: argumentIndex put: aLink.
    ^aLink!
wmTimer: mp1 with: mp2
        "Private - The timer identified by mp1 has gone off.
         Send a notification message to the timer widget 
         associated with the identifier mp1."
    self sendInputEvent: #tickDelayed:
        with: (items at: mp1 asInteger ifAbsent: [^nil]).
    ^nil!  
saveableFileTypes
        "Private - answer an OrderedCollection of saveable file types."
    | answer |
    answer := OrderedCollection with: self fileTypeForPart.
    PARTSSessionManager isWorkbenchStandaloneSession
        ifFalse: [ answer add: self fileTypeForSource ].
    answer
        add: self fileTypeForExecutablePart;
        add: self fileTypeForExe.
    ^answer!
pixelHorizontal: pixels toScaleUnit: scaleUnit
    "Answer the conversion of horizontal <pixels>
    to the number of units in <scaleUnit> measurement."

    scaleUnit = #twip
        ifTrue: [
            ^ pixels * 1440 / Display horizontalPixelsPerInch ].
    scaleUnit = #inch
        ifTrue: [
            ^ pixels / Display horizontalPixelsPerInch ].
    scaleUnit = #centimeter
        ifTrue: [
            ^ pixels * 100 / ( Display horizontalPixelsPerMeter ) ].
    ^pixels
!   
canSave
	"Answer whether the receiver can be saved from
	the workbench"

    ^true!   
updateSliders
        "Private - Reimplemented here because GroupPanes
         have no scrollbars."!   
loadSettingsFrom: aPathName into: aPARTSSettings
        " Private - load the PARTS Workbench settings from aPathName. "

    | settingsDict tag accessor settingAssoc parmAssoc
        searchPathString defaultScaleUnitString wrapperString |

    settingsDict := Dictionary new.
    normalizedTagDict := Dictionary new.
    ( Array
        with: self settingsFileSearchPathTag
        with: self settingsFileDefaultScaleUnitTag
        with: self settingsFileWrapperTag ) do: [ :aTag |
            normalizedTagDict
                at: aTag asUpperCase
                put: aTag ].

    partsSettings := aPARTSSettings.
    partsSettings notNil
        ifTrue: [
            self settingsFileParameters do: [ :array |
                tag := array at: 1.
                accessor := array at: 3.  " inst var slot or accessor "
                accessor := ( accessor isInteger
                    ifTrue: [ ( LinkMessage receiver: partsSettings selector: #instVarAt:put: )
                        argumentAt: 1 put: accessor;
                        argumentAt: 2 putInput: 1;
                        yourself ]
                    ifFalse: [ Message receiver: partsSettings selector: ( accessor, ':' ) asSymbol ] ).
                settingsDict at: tag put: (Association
                    key: (array at: 2)  " type "
                    value: accessor).
                normalizedTagDict at: tag asUpperCase put: tag].
            colorValueDict := self class colorDictionary.
            ].

    [ "Error handling block"
    " load settings values "
    stream := File pathNameReadOnly: aPathName.
    [stream atEnd] whileFalse: [
        settingAssoc := self nextSetting.
        settingAssoc notNil
            ifTrue: [
                (settingAssoc key = self settingsFileSearchPathTag)
                    ifTrue: [ searchPathString := settingAssoc value ]
                    ifFalse: [ settingAssoc key = self settingsFileDefaultScaleUnitTag
                        ifTrue: [ defaultScaleUnitString := settingAssoc value ]
                        ifFalse: [ settingAssoc key = self settingsFileWrapperTag
                            ifTrue: [ wrapperString := settingAssoc value ]
                            ifFalse: [
                                parmAssoc := settingsDict at: settingAssoc key.
                                self
                                    loadValue: settingAssoc value
                                    type: parmAssoc key
                                    using: parmAssoc value]]].
                ]].
    stream close ]
        on: Error
        do: [ :e |
            MessageBox warning: 'Error loading settings file.  Current settings may not be entirely initialized.'.
            stream close ].

    self loadSearchPath: searchPathString.
    partsSettings notNil
        ifTrue: [
            defaultScaleUnitString notNil
                ifTrue: [ partsSettings defaultScaleUnit: defaultScaleUnitString asSymbol ].
            wrapperString notNil
                ifTrue: [ partsSettings keepInExecutable: (wrapperString = 'true') ]].

!  
owner: anObject
        " Private - specify the owner of this PARTS application file processing operation. "

    owner := anObject.!  
fileDescriptor: aFileDescriptor
        "Answer the descriptor of the file containing the application."

    fileDescriptor :=
        aFileDescriptor isString
            ifTrue: [
                    "Filed out as string for executable files to avoid references
                        to revision support classes."
                PARTSFileDescriptor pathName: aFileDescriptor ]
            ifFalse: [ aFileDescriptor ].! 
items: itemList separators: separatorList defaultItem: anItem
        " Specify the items and separators and default item
        in the receiver. "

    items := itemList.
    "self ASSERT:
        (separatorList isNil or: [separatorList isIndexedCollection])."
    separators := separatorList.
    "self ASSERT: anItem notNil."  " fix client!!!! "
    defaultItem := anItem.!
upgradeMapsForLoadingPWW20
        " Private - answer the upgrade load maps for
        name and structure changes needed to load
        PW/Win32 2.0 applications into the current system. "

    | visualPartClasses changeMaps aChangeMap |

    " inst vars of all Window classes were reordered in VW 3.0 "
    visualPartClasses := #(
        " -- TopPane -- "
            #PARTSWindowPart
                #PARTSDialogWindowPart
        " -- MenuWindow -- "
            #PARTSMenuBar
        " -- SubPane -- "
            " -- ControlPane -- "
                " -- Button -- "
                    #PARTSPushButtonPart
                    #PARTSDrawnButtonPart
                    #PARTSCheckBoxPart
                    #PARTSRadioButtonPart
                " -- EntryField -- "
                    #PARTSEntryFieldPart
                    #PARTSFormattedEntryField
                        #PARTSAlphabeticEntryFieldPart
                        #PARTSDateEntryFieldPart
                        #PARTSFixedDecimalEntryFieldPart
                        #PARTSCurrencyEntryFieldPart
                        #PARTSFloatEntryFieldPart
                        #PARTSIntegerEntryFieldPart
                        #PARTSPhoneNumberEntryFieldPart
                        #PARTSPictureFieldPart
                    #PARTSTextPanePart
                " -- ListBox -- "
                    #ExtendedListBox
                    #PARTSComboBoxPart
                    #PARTSDropDownListPart
                    #PARTSMultipleChoiceListPart
                    #PARTSListPanePart
                " -- ScrollBar -- "
                    #PARTSHorizontalScrollBarPart
                    #PARTSVerticalScrollBarPart
                " -- StaticPane -- "
                    #PARTSGroupPanePart  " moved down from ControlPane in 3.0 "
                    #PARTSStaticGraphicPart
                    #PARTSStaticTextPart
            " -- GraphPane -- "
                #PARTSGraphPanePart
                    #PARTSDialPanePart
            " -- GroupPane -- "
                #PARTSNotebook    " shouldn't be filed, but framing block references class "
                    #PARTSNotebookPart
                #PARTSNotebookClientAreaPane
                #PARTSNotebookPagePart
            " -- PARTSGroupPane -- "
                #PARTSMenuPart
                #PARTSNestedPart
            " -- PARTSMenuItemPane -- "
                #PARTSMenuBitmapItemPart
                #PARTSMenuSeparatorPart
                #PARTSMenuTextItemPart
            #PARTSMenuLabelPart
        ).

    changeMaps := OrderedCollection new.
    visualPartClasses do: [ :classSymbol |
        changeMaps add: ( ObjectChangeMap forClassName: classSymbol ).
        ].

    " DrawnButton: 'drawBlock' renamed to 'drawSelector' "
    aChangeMap := changeMaps detect: [ :ocm |
            ocm sourceClassName = 'PARTSDrawnButtonPart' ].
    aChangeMap put: 'drawBlock' into: 'drawSelector'.

    " EntryField 'textLimit' -> #textLimit property "
    aChangeMap := changeMaps detect: [ :ocm |
            ocm sourceClassName = 'PARTSEntryFieldPart' ].
    aChangeMap put: 'textLimit' into: 'topCorner'.  " upgrader must fix "

    " TextEdit 'readonly' -> style bits "
    aChangeMap := changeMaps detect: [ :ocm |
            ocm sourceClassName = 'PARTSTextPanePart' ].
    aChangeMap   " upgrader must fix "
        put: 'textLimit' into: 'topCorner';
        put: 'readonly' into: 'handle'.

    " PARTSTablePane redesigned in PW 3.0 "
    changeMaps add: ( ObjectChangeMap
        forClassName: 'PARTSTablePanePart'
        destinationClassName: 'PARTSUpgradeTablePane' ).

    " PARTSIcon: drop PWW 2.0 'iconCore', 'iconFile' inst vars; name -> label "
   changeMaps add: ( ( ObjectChangeMap forClassName: #PARTSIcon )
        put: 'name' into: 'label';
        yourself ).

    " Base Directory class was completely redone in 3.0 "
    changeMaps add: ( ObjectChangeMap
        forClassName: 'PARTSDosDirectory'
        destinationClassName: 'UpgraderForDirectory' ).

    " PWW 2.0 could store MenuItem's, even though not needed; shape changed in 3.0 "
    changeMaps add: ( ObjectChangeMap forClassName: #MenuItem ).

    " PARTSNotebookPart has inst vars renamed in PW 3.0 "
    aChangeMap := changeMaps detect: [ :ocm |
            ocm sourceClassName = 'PARTSNotebookPart' ].
    aChangeMap
        put: 'notebookPage' into: 'pagePaneGroup';
        put: 'pages' into: 'orderedPages'.

    " PARTSNotebookPageAttributes: added 'notebook' inst var in 3.0 "
    changeMaps add: ( ObjectChangeMap forClassName: #PARTSNotebookPageAttributes ).

    " renamed workbench class (should not be filed, but possibly got stored
        via embedded nested part) [DJL 17-Nov-94] "
    changeMaps add: ( ObjectChangeMap
        forClassName: #PARTSMenuPane
        destinationClassName: #PARTSMenuPaneWindows ).

    "Renamed client area pane.  Only need this for those in 2.0 that
    accidentally got filed out due to error."
    changeMaps add: ( ObjectChangeMap
        forClassName: 'PARTSClientAreaPane'
        destinationClassName: 'PARTSClientAreaPaneWindows' ).

    changeMaps addAll: self upgradeMapsForLoadingPW20.
    ^changeMaps!   
fileType
    "Answer an array of files type processed by the instance
    of the receiver.  The types should be defined in
    PARTSFileDescriptor."

    " ^Array with: PARTSFileDescriptor fileTypeForXXX "!   
description
        " Answer the application's description property. "

    ^description!  
findWrapperForEvents: aPart
        " Answer the wrapper which triggers
        events from <aPart>. "
    | containingWrapper dummyNestedPart |

    aPart == self
        ifFalse: [ ^self findWrapper: aPart ].
    ( containingWrapper := self partWrapper parent ) notNil
        ifTrue: [ ^containingWrapper ].  " nested part or relay wrapper "
    " create special relay wrapper for Smalltalk event handlers "
    containingWrapper := PARTSWrapper new.
    dummyNestedPart := (Smalltalk at:#PARTSNestedPart) basicNew.
    dummyNestedPart
        application: self;
        partWrapper: containingWrapper.
    containingWrapper object: dummyNestedPart.
    dummyNestedPart partWrapper: containingWrapper.
    self partWrapper parent: containingWrapper.
    ^containingWrapper!
workbenchContaining: aPathName
        " Private - answer the workbench window containing
       the PARTS application from the file named aPathName. "

    | partsEditorClass editors |
    partsEditorClass := Smalltalk at: #PARTSEditor
        ifAbsent: [ ^nil ].
    editors := partsEditorClass editorsOnPathName: aPathName.
    ^editors notEmpty
        ifTrue: [ editors first ]
        ifFalse: [ nil ]!
installBasicRuntimeLibrary
        " Private - the basic runtime support library has just been installed.
        Initialize its contents to install into this image. "

    PARTSFile initializeVersionInfo.
    PARTSSessionManager initialize.
    PARTSGroupPane initialize.!   
addWindowComponent: aWindowPart name: aString helpInfo: aHelpInfo parent: aParentWindow
       "Private - add aWindowPart to the receiver in parent
        window aParentWindow."
    | newWrapper parentWrapper |
    parentWrapper := ( aParentWindow isNil
        ifTrue: [ self partWrapper ]
        ifFalse: [ self findWrapper: aParentWindow ] ).
    self addComponent: aWindowPart name: aString.
    newWrapper := PARTSWrapper new
        object: aWindowPart;
        name: aString;
        rectangle: aWindowPart framingBlock;
        helpInfo: aHelpInfo;
        yourself.
    parentWrapper addComponent: newWrapper.
    newWrapper parent: parentWrapper.
    aWindowPart partWrapper: newWrapper!   
contents: aLabel
        "Set the label of the reciever."
    self propertyAt: #topLabel put: aLabel!   
settingsFileParameters
        " Private - answer settings file parameter info
        (tag, type, inst var slot), in default file order. "
    | instVarNames parameters |
    instVarNames := partsSettings class allInstVarNames.
    parameters := OrderedCollection new.
    parameters
        add: (Array
            with: 'userName'
            with: 'string'
            with: (instVarNames indexOf: 'userName'));
        add: ( Array
            with: 'catalogs'
            with: 'stringList'
            with: #catalogs );
        " link colors "
        add: (Array
            with: 'completeEventLinkColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorWellDefinedBaseLink'));
        add: (Array
            with: 'completeArgumentLinkColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorWellDefinedArgLink'));
        add: (Array
            with: 'incompleteEventLinkColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorUndefinedBaseLink'));
        add: (Array
            with: 'incompleteArgumentLinkColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorUndefinedArgLink'));
        " background color settings "
        add: (Array
            with: 'workbenchBackgroundColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorWorkbench'));
        add: (Array
            with: 'catalogBackgroundColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorCatalog'));
        add: (Array
            with: 'linkLabelBackgroundColor'
            with: 'color'
            with: (instVarNames indexOf: 'colorLinkLabel'));
        "mouse buttons settings"
        add: (Array
            with: 'dragButton'
            with: 'symbol'
            with: (instVarNames indexOf: 'mouseButtonDrag'));
        add: (Array
            with: 'linkButton'
            with: 'symbol'
            with: (instVarNames indexOf: 'mouseButtonLink'));
        add: (Array
            with: 'selectButton'
            with: 'symbol'
            with: (instVarNames indexOf: 'mouseButtonSelect'));
        add: (Array
            with: 'popupMenuButton'
            with: 'symbol'
            with: (instVarNames indexOf: 'mouseButtonPopupMenu'));
        " workbench preference settings "
        add: (Array
            with: 'gridExtent'
            with: 'point'
            with: (instVarNames indexOf: 'gridExtent'));
        add: (Array
            with: 'showHints'
            with: 'boolean'
            with: (instVarNames indexOf: 'showHints'));
        add: (Array
            with: 'showLinkLabels'
            with: 'boolean'
            with: (instVarNames indexOf: 'showLinkLabels'));
        add: (Array
            with: 'showLinksWithSelection'
            with: 'boolean'
            with: (instVarNames indexOf: 'showLinksWithSelection'));
        "orthogonal lines"
        add: (Array
            with: 'orthogonalLinks'
            with: 'boolean'
            with: (instVarNames indexOf: 'orthogonalLinks'));
        " developer options "
         add: (Array
            with: 'isDeveloper'
            with: 'boolean'
            with: (instVarNames indexOf: 'isDeveloper'));
        yourself.
    ^parameters
!   
nextTokenFrom: aStream
        " Private - answer a string containing the next
        token in aStream.  A token is a sequence
        of non-white-space characters. "
    | first  ch|
    [aStream atEnd ifTrue: [^nil].
     aStream next isSeparator]
        whileTrue: [].  "skip separators"
    first := aStream position.
    [aStream atEnd
        ifTrue: [^aStream copyFrom: first to: aStream position].
    ch := aStream next.
     ch isSeparator]
        whileFalse: [].
    aStream position: aStream position - 1.
    ^aStream copyFrom: first to: aStream position!   
nextSetting
        " Private - answer an assoc with the next
        tag/value pair from fileStream.
        Answer nil if comment or blank line or syntax error. "
    | line rs token tag |
    line := stream nextLine trimBlanks.
    (line size = 0) ifTrue: [^nil].   " white space "
    rs := ReadStream on: line.
    token := (self nextTokenFrom: rs) asUpperCase.
    ((token = 'REM') or: [token first = $"])
        ifTrue: [^nil].  " comment "
    tag := normalizedTagDict at: token
        ifAbsent: [^nil].
    ((self nextTokenFrom: rs) = '=')
        ifFalse: [^nil].
    token := rs upTo: $".
    ^Association key: tag value: token trimBlanks!  
initialize
        " Private "

    userProperties := self defaultUserProperties.! 
useRightInset
    "Private - For the right side, use
      inset measurement."

    mask := mask bitOr: 2r00100000!   
registerClass: aFileProcessorClassName
	"Dynamically register a file processor with the receiver"

    self fileTypeRegistry add: aFileProcessorClassName asString!
application
        "Answer the PARTSApplication that the receiver knows how to build."
    ^self applicationForEdit!   
partHasOtherMessages
        " Answer whether the receiver can be asked
        for messages other than what it has already
        provided in its partMessages. "

    ^false! 
isPARTSTeamVDirectory
        "Answer whether the receiver is an instance of class
         PARTSTeamVDirectory or one of its subclasses."
    ^false! 
isPARTSLink
        "Answer whether the receiver is a PARTS link."

    ^true! 
descriptionIn: application
        " Private - answer a description of this link. 
        The receiver's application is provided as a
        performance optimization. "

    ^( self descriptionSource: application ),
        ( self isArgumentLink
            ifTrue: [ ' gets ' ]
            ifFalse: [ ' executes ' ] ),
        ( self descriptionDestination: application )!  
relativeDisplayName
    "Answer the receiver's relative path suitable for displaying."

    ^self relativePathName "asLowerCase"!  
editorVirtualScreenExtent: newScreenExtent
        "Private -  Set the editor's virtual screen extent. "
    | oldScreenExtent oldRectangle newRectangle partWrapper
       nonVisualParts links framer calculatedExtent actualExtent delta |

    ( oldScreenExtent :=
        editorState virtualScreenExtent ) = newScreenExtent
        ifTrue: [ ^self ].

    editorState virtualScreenExtent: newScreenExtent.

    self partIsEditing ifFalse: [ ^self ].

    nonVisualParts := OrderedCollection new.
    oldRectangle :=
        self partsIfOS2Do: [  "10000 = Large number encompassing any screen size"
            0 @ 10000 extentFromLeftTop: oldScreenExtent ]
        partsIfWindowsDo: [
            0 @ 0 extent: oldScreenExtent ].
    newRectangle :=
        self partsIfOS2Do: [
            0 @ 10000 extentFromLeftTop: newScreenExtent ]
        partsIfWindowsDo: [
            0 @ 0 extent: newScreenExtent ].
    self children do: [ :aComponent |  "Top level components"
        aComponent isApplicationWindow not ifTrue: [
            partWrapper := aComponent partWrapper.
            ( aComponent respondsTo: #framingBlock: )
                ifTrue: [
                    aComponent framingBlock:
                        ( aComponent framingBlock
                            changeContainingRect: oldRectangle
                            to: newRectangle ).
                    aComponent partIsShrunk not
                        ifTrue: [ "Wrapper rectangle mirrors framing block"
                            aComponent partWrapper
                                rectangle: aComponent framingBlock ]
                        ifFalse: [ "Shrunk - Wrapper rectangle is icon position"
                            partWrapper rectangle:
                                ( partWrapper rectangle
                                    changeContainingRect: oldRectangle
                                    to: newRectangle )]]
                ifFalse: [ "Non-visual part (icon)"
                    partWrapper rectangle:
                        ( partWrapper rectangle
                            changeContainingRect: oldRectangle
                            to: newRectangle ).
                    nonVisualParts add: aComponent ]]].

    "If changing resolution and icons' framers are in twips,
    the framers will adjust, but icons remain in fixed pixels.
    Re-sync the framers with the actual icon size, and adjust
    incoming and outgoing links, since they are based on
    offsets of the icon size."
    self defaultScaleUnit ~= #pixel
        ifTrue: [
            nonVisualParts do: [ :aNonVisualPart |
                framer := aNonVisualPart partWrapper rectangle.
                calculatedExtent :=
                    ( framer scaleUnitToPixelHorizontal: framer right ) @
                    ( framer scaleUnitToPixelVertical: framer bottom ).
                actualExtent := PARTSIcon iconSize.
                calculatedExtent ~= actualExtent
                    ifTrue: [
                        framer
                            right: ( framer pixelToScaleUnitHorizontal: actualExtent x );
                            bottom: ( framer pixelToScaleUnitVertical: actualExtent y ).
                        links := Set new.
                        wrapper
                            addEventLinksAffecting: aNonVisualPart
                            to: links.
                        delta := calculatedExtent - actualExtent.
                        links do: [ :aLink |
                            aLink adjustPathPointsOn: aNonVisualPart by: delta ]]]].! 
icon
		"Private - Retained for backward compatibility.  
		Use partIcon instead."
	^self partIcon! 
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent.
        Nothing needs to be done for the application itself."!  
left
    ^left!  
iconFromICOFile: aFileReference ifNone: aBlock
        " Answer the icon stored in aFileReference,
        where aFileName is a standard (.ICO) icon file
        on the PARTS search path.
        Answer the value of aBlock if not found. "

    | aDirectory aFileStream anIcon |
    aDirectory := self directoryContaining: aFileReference
        ifNone: [ ^aBlock value ].
    aFileStream := ( PARTSFileDescriptor fileName: aFileReference in: aDirectory )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    anIcon := PARTSIcon fromFileStream: aFileStream.
    aFileStream close.
    ^anIcon!  
defaultCompiler
        "Answer a compiler that can recompile the receiver."

    | compilerInterfaceClass |
    compilerInterfaceClass := self class compilerInterfaceClass.
    compilerInterfaceClass isNil
       ifTrue: [ ^nil ].
    ^compilerInterfaceClass forClass: self classField! 
selector: selectorSymbol
        "Private - set the message selector which is sent when
        the receiver is fired."

    selector := selectorSymbol.! 
loadSearchPath
        " Load the PARTS Workbench search path from the standard ini file. "
    self loadSearchPathFrom: self defaultFileName.! 
pathCalculated
    "Private - Answer whether the path has been calculated.
    Use this instead of 'pathPoints isNil' because 'pathPoints'
    does lots of calculations."

    ^pathPoints size ~= 0!   
isVisualPropertyFromPathName: aPathNameOrFileDescriptor
        " Answer the property for the application in the given
    file that indicates whether it has any visual parts. "
    | aFileStream isVisual |

    ( aPathNameOrFileDescriptor isNil
        or: [ ( PARTSFile exists: aPathNameOrFileDescriptor ) not ] )
        ifTrue: [
            ^PARTSFileNotFound signalForFile: aPathNameOrFileDescriptor ].
    aFileStream := ( PARTSFileDescriptor pathName: aPathNameOrFileDescriptor )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ isVisual := self isVisualPropertyFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^isVisual! 
partPrintString
        " Answer a string containing a description of the
        receiver and all its component parts. "

    | aStream |
    aStream := WriteStream on: (String new: 16).
    self partPrintOn: aStream.
    ^aStream contents!  
propertiesFrom: aFileStream
        " Answer the properties stored on aFileStream. "
    ^PARTSFile propertiesFromPARStream: aFileStream
! 
new: anInteger
        " Answer a MirrorCopy dictionary for making
        an editable copy with initial size <anInteger>. "

    ^self for: #copy initialSize: anInteger!
refreshApplication
        " Private "
    application := nil.
    self loadApplication!   
hasExternalMessage: aSelector
        " Answer whether <aSelector> is an external message of this application. "

    ^self externalMessages includes: aSelector!  
isWellDefined
        " Answer whether all the arguments needed to fire this link
        have a collection mechanism fully defined. "

    messageArgLinks isNil 
        ifTrue: [ ^true ].  " no arguments needed to fire this link "
    messageArgLinks do: [ :anArgLink |
        ( anArgLink isNil or: [ anArgLink isWellDefined not ] )
            ifTrue: [ ^false ] ].
    ^true! 
isAttachedTo: aPart
        " Answer whether the receiver is directly attached to <aPart>. "

    ^( self attachedSourceObject == aPart )
    or: [ self destinationObject == aPart ]!
collectArguments: inputArguments
        " Private - collect the argument values needed
        to fire this link. "

    messageArgLinks isNil 
        ifTrue: [ ^nil ].
    ^messageArgLinks collect: [ :anArgLink |
        anArgLink evaluateWithArguments: inputArguments]!  
isPARTSNonvisualPart
        "Answer whether the receiver is a PARTSNonvisualPart."
    ^true!  
eventTableInternal
        "Private - answer the table of event handlers for the receiver.
        The internal event table represents the implementations
        of the external messages of the application. "

    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable at: 2 ]!  
children
        " Answer the application's children property.
    The children are the top level components of
    an application.  For an editable application this
    information is located in the wrapper."

    ^self propertyAt: #children ifAbsent: [ nil ]!   
renameExternalEvent: originalName to: newName
        " Rename the external event selector <originalName>
        to <newName>."

    externalEvents
        at: ( externalEvents indexOf: originalName )
        put: newName.!
rescale: newRect for: aPane
    "Rescale aPane's framing block to span the newRect."

    aPane framingBlock
        changeRectangle: newRect
        in: aPane.!
defaultSearchPath: aDirectory
        " Answer the default search path for aDirectory. "

    | dirPathName subDirNames searchDirs |
    dirPathName := aDirectory drivePathName.
    subDirNames := aDirectory subdirectories
        collect: [ :anArray | (anArray at: 2) asUpperCase ].
    searchDirs := OrderedCollection new.
    ( subDirNames includes: 'USER' )
        ifTrue: [
            searchDirs add:
                ( Directory pathName: dirPathName, '\USER' ) ].
    searchDirs add: aDirectory.
    ( subDirNames includes: 'SYSTEM' )
        ifTrue: [
            searchDirs add:
                (Directory pathName: dirPathName, '\SYSTEM' ) ].
    ^searchDirs asArray!   
upgradeMapsFor: aFileVersion
        " Private - answer the change maps for upgrading objects
        stored from aFileVersion. "

    ^self upgradeMapsDictionary at: aFileVersion ifAbsent: [ #() ]!
pathPointsAttribute
    "Private"

    ^pathPoints!
precursiveError: anError
        "Private - set the error that caused this error to occur."
    precursiveError := anError! 
isVisual
        " Private - answer whether the receiver has any
        visual parts."

    ^( self partWrapper components
        detect: [ :each | each object partHasVisualParts ]
        ifNone: [ nil ]) notNil! 
forPartFile
        " Answer whether the copy is going to be
        saved in an editable .PAR file. "

    ^self operation = #save!  
fromMethod: aCompiledMethod
    source: sourceString
    componentDictionary: aComponentDictionary
    part: aPart
		" Private - answer a script with the contents of 
		<aCompiledMethod> defining its behavior and
		the source/owner information. "

    | numLiterals aScript |
    numLiterals := aCompiledMethod size.
    aScript := self new: numLiterals.
    1 to: ( self instSize + numLiterals ) do: [ :i |
        aScript instVarAt: i put: ( aCompiledMethod instVarAt: i ) ].
    aScript
        classField: self scriptClassField;
        setSource: sourceString
            componentNameDictionary: aComponentDictionary
            part: aPart.
    ^aScript!   
forRectangle: aRect in: aControlOrRectangle scaleUnit: scaleSymbol
    "### replaces the old 'fromRect:' ###"
    "Answer a PARTSFramer for creating aRect in aControlOrRectangle
     with default attributes using scaleSymbol as its scale unit.
     aRect and parentRect are regular Rectangle in pixel unit.
    Note: the receiver is based on the state of <aControl> at this
    time.  If <aControl> supports children that affect the free client
    area, the receiver may become obsolete if those children
    change."

    | answer parentRect |

    parentRect :=
        aControlOrRectangle isNil
           ifTrue: [  Display boundingBox ]
           ifFalse: [
               aControlOrRectangle isRectangle
                   ifTrue: [ aControlOrRectangle ]
                   ifFalse: [ aControlOrRectangle freeClientArea ]].

    answer := self new.
    answer
        scaleUnit: scaleSymbol;
        left: ( answer pixelToScaleUnitHorizontal:
                ( answer horizontalInsetFrom: parentRect left to: aRect left ))
            stretched: false
            width: ( answer pixelToScaleUnitHorizontal: aRect width )
            stretched: false;
        top: ( answer pixelToScaleUnitVertical:
                ( answer verticalInsetFrom: parentRect top to: aRect top ))
            stretched: false
            height: ( answer pixelToScaleUnitVertical: aRect height )
            stretched: false.
    ^answer!
stopTimer: aTimer
        " Stop the specified timer. "
    | id |
    ( PARTSTimer notNil
    and: [ PARTSTimer isValid ] )
        ifTrue: [
            id := PARTSTimer getId: aTimer.
            Time
                stopTimer: id
                forWindow: PARTSTimer.
            PARTSTimer removeId: id ].!
fireSelfWith: arguments
        " Private - fire the receiver with the collected arguments.
        Answer the result. "

    ^receiver perform: selector withArguments: arguments!   
concatenateLists: anArrayOfLists defaultItem: anItem
        " Answer the concatenation of anArrayOfLists. "

    | newList |
    newList := self emptyList.
    anArrayOfLists do: [ :anInterfaceList |
        newList := newList
            concatenate: anInterfaceList
            defaultItem: anItem ].
    ^newList!
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it.
        For backward compatibility, avoid a walkback.  Any
        load failure will cause nil to be returned."

    ^nil! 
eventTableAttribute
        "Private - answer the table of event handlers for the receiver.
        These events actually belong to the application's editor. "
    ^eventTable!   
manufacturer: string
        " Set the application's manufacturer property. "

    self userPropertyNamed: self manufacturerPropertyName put: string!  
titlePropertyName
        " Private "

    ^'title'!   
COMMENT
"
PARTSPane is an abstract superclass for PARTS panes
outside the control pane hierarchy.
"!  
partEnableExecution
        " The application containing the receiver
        is going to be executed.  Dive into the application
        nested in the receiver and activate its components. "

    application isNil ifTrue: [^nil]. "Skip this at startup time."

    self partWrapper notNil  " backstop in case of multiple enablements "
        ifTrue: [
            self application enableExecution:
                ( self partWrapper notNil
                    ifTrue: [ self partWrapper partIsDebugging ]
                    ifFalse: [ false ]).

            " transfer outgoing links to the application so they can be triggered "
            self applicationEvents do: [ :anEvent |
                self application
                    when: anEvent
                    evaluate: ( self actionForEvent: anEvent ) ].
            self application partWrapper: nil.
            super partEnableExecution ].! 
solePart
        "Answer the only part in the application.
        Answer nil if none or more than one."

    ^self partWrapper components size = 1
        ifTrue: [ self partWrapper components first object ]
        ifFalse: [ nil ]!  
pathPoints: anArray
        "Private - Set the position points of the link's path.  The
    first point is the offset of the launch base point relative
    to the origin of the source object rectangle, in respect
    to the launchSide.  The first control point is relative to the
    launchPlugTip.  The control points a relative to the
    previous point.  The last point is the offset of the landing
    tip point relative to the target object rectangle, in respect
    to the landingSide.
        <anArray> is in pixels and will be converted to the
    appropriate scale unit.

    This method is now only needed to support reading 3.0
    generated .CLS files."

    anArray isNil ifTrue: [ ^self ].
    pathPoints :=
        anArray collect: [ :aPoint |
            ( PARTSFramer pixelHorizontal: aPoint x toScaleUnit: PARTSFramer defaultScaleUnit ) @
                ( PARTSFramer pixelVertical: aPoint y toScaleUnit: PARTSFramer defaultScaleUnit )]
! 
hash
        "Answer the integer hash value of the receiver. "

    ^self fullPathName hash!   
partParent
        " Answer the parent part of the receiver. "

    ^nil!  
storeOnPath: aPathNameOrDescriptor
    "Load the editable application represented by the receiver and
    store on <aPathNameOrDescriptor>, in a format specified by the
    extension of the file name of <aPathNameOrDescriptor>.
    If <aPathNameOrDescriptor> is relative, it will be relative to Disk."
    | application |

    [ application := self loadForEdit ]
        on: PARTSApplicationLoadError
        do: [ :e | e postMessageBox. ^nil ].

    application storeOnPathName: aPathNameOrDescriptor.
!  
separators: separatorList
        " Specify the separators in the receiver. "

    "self ASSERT:
        (separatorList isNil or: [separatorList isIndexedCollection])."
    separators := separatorList.!   
partIsEditing
        "Answer whether the receiver is being
        edited in a PARTS Workbench. "

    ^editor isPARTSEditor!
addExternalEvent: aSymbol
        " Private - add the event <aSymbol> to the external interface
        of this application. "

    "self ASSERT: aSymbol isSymbol."
    externalEvents := ( externalEvents isNil
        ifTrue: [ Array with: aSymbol ]
        ifFalse: [
            "self ASSERT: ( externalEvents includes: aSymbol ) not."
            externalEvents, ( Array with: aSymbol ) ] ).!  
iconFromFile: aFileReference ifNone: aBlock
        " Answer the icon stored in the file
        named aFileReference on the PARTS search path.
        Answer the value of aBlock if not found. "

    ^[ self
        iconFromFile: aFileReference
        in: ( self directoryContaining: aFileReference )]
            on: PARTSNotOnSearchPath
            do: [ :e | ^aBlock value ]!  
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream."

    aStream
        nextPutAll: self class name;
        nextPut: $(.
    self date printOn: aStream.
    aStream nextPut: Space.
    self time printOn: aStream.
    aStream nextPut: $).!
fromFileOrEditor: aFileReference in: aDirectory debugger: aDebugger
        " Answer the most current version of the application
        with the file name in <aFileReference> and in <aDirectory>.
        The file is assumed to exist (client is responsible for
        ensuring this precondition). "

    | fileDescriptor appPathName anEditor |
    fileDescriptor := PARTSFileDescriptor
        fileName: aFileReference
        in: aDirectory.
    appPathName := fileDescriptor fullPathName.
    "self ASSERT: appPathName notNil."
    ( anEditor := self workbenchContaining: appPathName ) notNil
        ifTrue: [
            ^aDebugger isNil
                ifTrue: [ anEditor getAppCopyToExecute ]
                ifFalse: [ anEditor getAppCopyForDebugger: aDebugger enableExecution: true ]
                ].
    ^fileDescriptor loadForExecuteWithDebugger: aDebugger!  
reuseMode
        " Answer the application's reuseMode. "

    ^property reuseMode!
fromPathName: aPathName debugger: aDebugger
        "Answer the application stored in aPathName. "

    ( aPathName isNil
    or: [ ( PARTSFile exists: aPathName ) not ] )
        ifTrue: [ ^PARTSFileNotFound signalForFile: aPathName ].

    ^( PARTSFileDescriptor pathName: aPathName )
        loadForExecuteWithDebugger: aDebugger! 
resultLink
        " Answer the link which is triggered with the result
        of evaluating the receiver (nil if not defined). "

    ^resultLink!  
exists: aPathNameOrDescriptor
    " Answer whether the file referenced by aPathNameOrDescriptor
    exists. "

    ^PARTSFileDescriptor exists: aPathNameOrDescriptor!
currentVersionDescription
        " Answer a description of the current PARTS Workbench
		version. "
    ^self fileAccessorClass versionDescriptionOf: self currentVersion!
executionMessageClass
        " Private - answer the message class to use for
        the receiver in an executable application. "

    ^LinkMessage! 
versionNumbers
        "Answer the product version, as an Array of 3 Integers (major, minor, revision)."

    ^VersionNumbers! 
extent
		"Answer a Point which is the width and height of the receiver
		if both the width and the heigh are fixed, nil if either is proportional."
    | width height |

    width :=
        self isRightInset not
            ifTrue: [ self right ]
            ifFalse: [
                self isLeftInset not
                    ifTrue: [ self left ]
                    ifFalse: [ nil ]].
    height :=
        self isBottomInset not
            ifTrue: [ self bottom ]
            ifFalse: [
                self isTopInset not
                    ifTrue: [ self top ]
                    ifFalse: [ nil ]].

    ( width isNil or: [ height isNil ])
        ifTrue: [ ^nil ].

    ^( self scaleUnitToPixelHorizontal: width ) @
        ( self scaleUnitToPixelVertical: height )! 
messageText
    "Private - Answer the error message to be displayed by the receiver"
    ^messageText notNil
        ifTrue: [ messageText ]
        ifFalse: [ self defaultText ]!   
application
        " Answer the PARTS application which contains the receiver. "

    ^self eventLink source application! 
new: components editor: aPARTSEditor
    "Private - Answer an instance of the receiver
    containing <components> being edited on
    <aPARTSEditor>"
   | newApp appWrapper workbenchPane |

    newApp := self new.
    appWrapper := newApp partWrapper.
    workbenchPane := aPARTSEditor workbenchPane.
    newApp editorState
        frameRectangle: aPARTSEditor mainView frameRectangle.
    components do: [ :aComponent |
        ( newApp includesPart: aComponent )
            ifFalse: [
                newApp
                    addComponent: aComponent
                    name: aComponent partName.
                ( aComponent partWrapper notNil
                    and: [ aComponent partWrapper parent isNil ])
                    ifTrue: [  "Top level component"
                        appWrapper addComponent: aComponent partWrapper ]].
        aComponent partIsWindow
            ifTrue: [ aComponent owner: newApp ]].

    ^newApp
! 
destinationObject
        "Answer the object to which a message is sent when
        the receiver is fired."

    ^receiver isPARTSWrapper
        ifTrue: [ receiver object ]
        ifFalse: [ receiver ]!   
lastUpdateTime
    ^lastUpdateTime isNil
        ifTrue: [PARTSTimeStamp
            date: Date today
            time: (Time fromSeconds: 0)]  "beginning of the day"
        ifFalse: [lastUpdateTime]!
canReadProperties
		" Answer whether the header properties can be loaded
		from the part file by the current system. "

	^canReadProperties!  
initialize
       " Private - initialize a new instance.  Default is to do nothing. "!   
children
    "Private - Answer the top level components of the receiver.
    The location of the children, during editing time, should
    be in the wrapper.  They should be backed up to the
    application properties when the receiver is in executable
    format."

    ^self isEditable
        ifTrue: [
            self partWrapper components
                collect: [ :each | each object ]]
        ifFalse: [ property children ]!
editorExtent: anExtent
        " Specify the editor's factoryPane extent (including non-visible area). "
    self obsoleteMethod. "needed for code generator output prior to 3.1 beta1"
    editorState virtualScreenExtent: anExtent
!   
isValidExternalEvent: aSymbol
        " Answer whether <aSymbol> can be defined as an
        external event of the application. "

    ^wrapper isValidEvent: aSymbol!   
isExecutable
        " Answer whether the receiver can be executed. "

    ^property executionState = 'executable'!
changeDestinationProperties: newLink
        " Private - change the destination object or message of the
        receiver.  Reset any argument links affected by a message
        change.  The client is responsible for updating the
        link layout (editState). "

    super changeDestinationProperties: newLink.
    realSelector := receiver partRealSelectorFor: selector.!
applicationCore
        "Build and answer the core application."
    | application |
    [[ application := self newApplication.
        self
            instantiatePartsFor: application;
            buildApplication: application;
            attachScriptsIn: application.
        application partCodeGenerated: self ]
            on: UnregisteredEvent do: [
                "Nothing.  Allow unregisted events to be handled." ]]
                    on: PARTSNestedPartLoadError do: [
                        "Nothing.  We don't care if the nested app can't be loaded at this point." ].

    ^application
!   
includesKey: aKey
        " Answer whether there is a user-defined property named <aKey>. "

    properties isNil ifTrue: [ ^false ].
    ^properties at: aKey!   
releaseEventTable
        "Private - break all connections to event handlers."

    eventTable := nil.!
titlePropertyFrom: aFileStreamOrProperties
        " Answer the title property of the application."

    ( aFileStreamOrProperties isStream and: [ aFileStreamOrProperties size = 0 ])
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStreamOrProperties file pathName.
            ^nil ].
    ^self fileAccessorClass new titlePropertyFrom: aFileStreamOrProperties!  
isValidComponentName: aString
        " Answer whether <aString> is a valid name for
        a component in this application.  The name
        must be a valid Smalltalk pool variable name
		which is unique within the application and
		global name spaces. "

	^( self class isValidGlobalName: aString )
    	and: [ ( componentDictionary includesKey: aString ) not
    	and: [ ( Smalltalk includesKey: aString asSymbol ) not ] ]! 
isPARTSPartAccessorPart
	"Answer whether the receiver is an instance
	of PARTSPartAccessorPart"

	^true!  
partCopyLiterals
        "Private - code generation - set the receiver's literals to be copies
        of the original literals.  This is done because objects built by a
        method often contain literals from that method, and that makes
        the object dependent on the library that the method lives in.
        Setting a method's literals to copies before the object is built
        will remove the dependency between the object and the library."
    | literal copy |
    1 to: self size do: [ :i |
        literal := self at: i.
        copy := self partCopyLiteral: literal.
        self at: i put: copy ]
!
demandLoad: aBoolean
        "Private - Set to true if the part should automatically
        load the part when it receives a message and the
        application is nil."
    demandLoad := aBoolean isBoolean
        ifTrue: [demandLoad]
        ifFalse: [aBoolean == #true]!  
initialize
        " Private - class initialization. "

    self initializeEventsTriggered.!   
getId: timer
        "Answer the id of the timer if one exist else
         create a new one."
    | id |
    id := items keyAtValue: timer ifAbsent: [nil].
    id isNil
        ifTrue: [  " allocate id for new timer "
            1 to: items size + 1 do: [ :i |
                items at: i ifAbsent: [ id := i ] ].
            items at: id put: timer.
            ].
    ^id!   
defaultScaleUnit
        "Private- Answer the application's default scale
    unit used for icons and links on the workbench."

    ^self
        propertyAt: #defaultScaleUnit
        ifAbsent: [
            self defaultScaleUnit: PARTSFramer defaultScaleUnit.
            PARTSFramer defaultScaleUnit ]
!
scaleFactor
        " Private - answer the scaling factor for a part size specification. "

    ^scaleFactor!  
new
    true ifTrue: [ ^super new ].
    self error: 'inappropriate message'  " must specify connections to create a link "!
fileTypeRegistry
    "Answer a collection of class name strings of
    existing file processors."
    self initializeFileRegistry.
    ^ FileTypeRegistry!
partNameUnchecked: aString
		"Private - set the name of the receiver to be aString without doing
		any name collision checks."
	wrapper changeNameToUnchecked: aString!
pathPoints
    "Private - Answer the pathPoints of the receiver's
    editState in pixels. ONLY A COPY IS ANSWERED.
    ANY MODIFICATIONS NEED TO BE SAVED BACK
    via pathPoints:"

    ^editState pathPointsFrom: self partApplication defaultScaleUnit.!
validFile: aFileReference
    " Answer whether the file described by <aFileReference>
    exists in the receiver. "

    ^super validFile: ( aFileReference isString
        ifTrue: [ aFileReference ]
        ifFalse: [ aFileReference fileName ]  "assume
            <aFileReference> is a PARTSFileDescriptor" )!
fileTypesForCatalog
        "Answer an indexed collection of the file types that can be placed on a catalog."
    | answer |
    answer := OrderedCollection new.
    answer
        add: self fileTypeForPart;
        add: self fileTypeForExecutablePart.
    PARTSSessionManager isWorkbenchStandaloneSession
        ifFalse: [ answer add: self fileTypeForSource ].
    ^answer!  
isInternalArgumentLink
        " Answer whether the receiver is an argument link which
        collects its argument value from an input argument of the 
        triggering event.  (The selector-th input argument provides
        the value for the trigger-th message argument of the 
        triggering link.) "

    ^self isArgumentLink and: [ selector isInteger ]! 
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
directory
        " Answer the directory in which this application is filed. "

    | pathName |
    ( pathName := self filePathName ) isNil
        ifTrue: [ ^nil ].
    ^PARTSFile directoryOf: pathName default: PARTSFile currentDirectory!
includesPart: anObject
        " Answer whether <anObject> is a part in the receiver. "

    ^componentDictionary includes: anObject!  
index: anInteger
        "Private - set the receiver's index."
    index := anInteger
!
pixelVertical: pixels toScaleUnit: scaleUnit
    "Answer the conversion of vertical <pixels>
    to the number of units in <scaleUnit> measurement."

    scaleUnit = #twip
        ifTrue: [
            ^ pixels * 1440 / Display verticalPixelsPerInch ].
    scaleUnit = #inch
        ifTrue: [
            ^ pixels / Display verticalPixelsPerInch ].
    scaleUnit = #centimeter
        ifTrue: [
            ^ pixels * 100 / ( Display verticalPixelsPerMeter ) ].
    ^pixels
! 
versionFromFile: aFileReference
        " Answer the PW file version of the file
        named <aFileReference> on the PARTS search path. "
    | dir |

    ( dir := self directoryContaining: aFileReference ) isNil
        ifTrue:[ ^nil ].

    ^self
        versionFromFile: aFileReference
        in: dir! 
workbenchSource: originalApplication
        " Private - specify the original application in a workbench
        window from which the receiver was cloned for execution.
        Only set when testing an application from a workbench. "

    property propertyAt: #workbenchSource put: originalApplication.! 
libraryDependencies
        " Private - answer the libraries which were bound
        when the receiver was loaded. "

    ^property propertyAt: #libraryDependencies ifAbsent: [ #( ) ]! 
directoryContaining: aFileReference before: searchDelimeter ifNone: aBlock
    " Answer the first directory on the PARTS search path
    before <searchDelimeter> directory containing <aFileReference>.
    Evaluate <aBlock> if not found.  Assume <aFileReference>
    is a file name already if it is a string, for performance. "

    | fileName |
    fileName := ( aFileReference isString
        ifTrue: [ aFileReference ]
        ifFalse: [ aFileReference fileName ] ).  "file descriptor"
    self currentSearchPath do: [ :aDirectory |
        aDirectory = searchDelimeter
            ifTrue: [ ^aBlock value ].
        ( PARTSFile exists: fileName in: aDirectory )
            ifTrue: [ ^aDirectory ] ].
    ^aBlock value!
= aPARTSFileDescriptor
    "Use method 'equalPaths:' to compare only path names."

    self class = aPARTSFileDescriptor class
        ifFalse: [ ^false ].

    ^ self fullPathName equalsIgnoreCase:
         aPARTSFileDescriptor fullPathName! 
upgradeSelectorFrom: oldSelector to: newSelector
        " Private - install a protocol upgrade. "

    selector := newSelector.!  
upgradeMapsForLoadingPWO30
        " Private - answer the upgrade load maps for
        structure changes in the current version. "

    | changeMaps |
 
    changeMaps := OrderedCollection new.

	"Plug in the default change maps"
    #(
		#PARTSContainerPart "dropped inst vars."
        ) do: [ :classSymbol |
            changeMaps add: ( ObjectChangeMap forClassName: classSymbol ) ].


    ^changeMaps!
bindLibrary: libraryName
    errorTitle: titleString
    neededFor: descriptionString
        " Attempt to bind the library named <libraryName>.  Use the
        description in <descriptionString> explaining why the library is needed
        if the bind fails and an error message needs to be constructed to
        inform the user what's wrong.  Answer whether successful. "

    [ SmalltalkLibraryBinder bindTo: libraryName ]
        on: FileError, BindError
        do: [ :anException |
            MessageBox
                notify: titleString
                withText:
                    'Cannot bind the ''',
                    libraryName asUpperCase, "SmalltalkLibrary fileExtension asUpperCase,"
                    ''' library needed for ', descriptionString, '.  ',
                    'This file needs to be in a directory on your system PATH.'.
            ^false ].
    ^true!  
setAttributesInSearchPath
        "Set the extended file attributes of all the files in the
        search path.  This method is intended to be run when
        PARTS Workbench first starts up, but it can be used
        subsequently if needed."

    self currentSearchPath do: [ :dir |
        (dir filesNamed: '*.par') do: [ :fileName |
            self fileAccessorClass setAttributesOfFile: fileName in: dir ] ].! 
writeToStream: aWriteBlock
    "Evaluate the <aWriteBlock> with a writeStream.
    Depending on the subclass, may not be able to
    write to the stream again once the block is finished,
    or may overwrite the existing file associated with
    the receiver."

    "Implemented by subclass"!   
exists: aPathNameOrDescriptor
    " Answer whether the file referenced by aPathNameOrDescriptor
    exists. "
    | path dir fileName |

	aPathNameOrDescriptor isString
        ifTrue: [
			path := aPathNameOrDescriptor asFileSystemPath.
			path := ( path isRelative
		        ifTrue: [ self stringFrom: path in: Disk ]
		        ifFalse: [ path ]) asFileSystemPath.
			fileName := path entityName. 
			dir := PARTSDosDirectory fromPath: path parentPath ]
        ifFalse: [
			fileName := aPathNameOrDescriptor fileName.
			( dir := aPathNameOrDescriptor directory ) isNil
				ifTrue: [ dir := Disk ]  "Bullet-proof, but shouldn't be nil anyway" ].

    ^self exists: fileName in: dir.! 
part
        " Private - answer the part to which the receiver's script belongs. "

    ^part! 
addApplicationPropertiesMethodTo: aClassModel
        "Private - code generation - add a method model to aClassModel
        that will answer the application properties of the receiver."
    | methodModel expression |
    methodModel := aClassModel newClassMethodNamed: #applicationProperties.
    methodModel comment: 'Private - answer the properties of the application the receiver can rebuild.'.
    expression := methodModel newMessageExpression.
    expression receiverObject: Dictionary new.
    self propertiesForFile do: [ :assoc |
        expression addSelector: #at:put: with: assoc key with: assoc value ].
    expression addSelector: #yourself!
upgradeMapsDictionary
        " Private "

    ^UpgradeChangeMapsDictionary!   
mainUnshrunkObject
        "Answer the first unshrunk visual component in the application."

    | parts |
    self partWrapper components size >= 1
        ifTrue: [
            parts := self partWrapper components.
            ^(parts detect: [:each |
                ( each object partIsShrunk not
                    and: [ each object partHasVisualParts ])]
                ifNone: [parts first])
                    object]
        ifFalse: [^nil]!
description: aString
        " Set the application's description property. "

    description := aString!  
fileType
    "Answer the file type processed by the instance
    of the receiver."

    ^Array with: PARTSFileDescriptor fileTypeForPart! 
initializeWithName: aName
        " Private - initialize a new instance. "

    | appName |
    appName := aName trimBlanks.
    property := PARTSApplicationProperty new.
    property
        hint: 'A PARTS application';
        reuseMode: #reference;
        icon: self class defaultIcon;
        defaultScaleUnit: PARTSFramer defaultScaleUnit.
    wrapper := PARTSWrapper new
        object: self;
        name: appName;
        helpInfo: ( Array
            with: 'YourFile.hlp'
            with: 'YourTopic' ).
    componentDictionary := Dictionary new.
    "self ASSERT: (self isValidComponentName: wrapper name)."
    componentDictionary at: wrapper name put: self.
    editorState := PARTSEditorState new.
    self addExternalMessage: #open.  " needed to launch app "!  
defaultScaleUnit: unitSymbol
    "Private -  Currently supported unitSymbols are
        #twip, #inch, #centimeter and #pixel."

    ( self scaleUnitsSupported includes: unitSymbol )
        ifFalse: [
            MessageBox message:
                'Unit ', unitSymbol asString,
                ' is not supported.  Default scale unit will remain ',
                '''',DefaultScaleUnit asString,''''.
            ^nil ].

    DefaultScaleUnit := unitSymbol
!
stringFrom: aFileName in: aPathOrDirectory
    "Answer the absolute path with the parameters"

    ^( aFileName asFileSystemPath absoluteWithin:
            aPathOrDirectory asFileSystemPath ) asString "asLowerCase"!  
adjustPathPointsOn: aNonVisualPart by: anExtentDelta
    "Private"
    "Icons' SIZE are always in pixels.  If framer is in twips, inches, etc..., it is because
    the POSITION is in twips.  If an endPoint is connected to an icon and is relative
    to the right bottom, it is out of sync because the framer has been adjusted as
    if the icon could match the adjustment, but the icon size is fixed in pixels.
    <anExtentDelta> represents how much the icon is out of sync.  Adjust the
    pathPoints accordingly."
    | pathPoints endPoint numCP firstCP pointsModified |

    ( pathPoints := self pathPoints ) size = 0
        ifTrue: [ ^self ].  "Internal arg link"

    pointsModified := false.

    ( self receiver == aNonVisualPart
        and: [ ( editState landingSide = SideRight
            or: [ editState landingSide = SideBottom ])])
        ifTrue: [ "Adjust the endPoint along the landingSide"
            pointsModified := true.
            endPoint := pathPoints at: pathPoints size.
            editState landingSide = SideRight
                ifTrue: [ endPoint y: ( endPoint y down: anExtentDelta y )].
            editState landingSide = SideBottom
                ifTrue: [ endPoint x: ( endPoint x right: anExtentDelta x )]].
    ( self sourceObject == aNonVisualPart
        and: [ ( editState launchSide = SideRight
            or: [ editState launchSide = SideBottom ]) ])
        ifTrue: [
            pointsModified := true.
            ( numCP := self numberOfControlPoints ) > 0
                ifTrue: [ firstCP := self firstControlPointIndex ].
            "Adjust the endPoint along the launchSide.  Adjust the controlPoints
            to maintain their absolute position as the right or bottom side is
            adjusted inward or outward."
            endPoint := pathPoints at: 1.
            editState launchSide = SideRight
                ifTrue: [
                    endPoint y: ( endPoint y down: anExtentDelta y ).
                    firstCP notNil
                        ifTrue: [
                            firstCP to: pathPoints size - 1 do: [ :aPathPointIndex |
                                ( pathPoints at: aPathPointIndex )
                                    x: (( pathPoints at: aPathPointIndex ) x right: anExtentDelta x )]]].
            editState launchSide = SideBottom
                ifTrue: [
                    endPoint x: ( endPoint x right: anExtentDelta x ).
                    firstCP notNil
                        ifTrue: [
                            firstCP to: pathPoints size - 1 do: [ :aPathPointIndex |
                                ( pathPoints at: aPathPointIndex )
                                    y: (( pathPoints at: aPathPointIndex ) y down: anExtentDelta y )]]]].

    pointsModified ifTrue: [ self pathPoints: pathPoints ].!
launchWorkbench: applicationPathName
        " Private - open a PARTS Workbench window. "

    | partFileName |

    "self standaloneWorkbenchLibraries do: [ :aLibraryName |
        ( self
                bindLibrary: aLibraryName
                errorTitle: 'Unable to start PARTS Workbench'
                neededFor: 'workbench script support' )
            ifFalse: [ ^Smalltalk exit ] ]."

    applicationPathName notEmpty
        ifTrue: [
            partFileName := applicationPathName asArrayOfSubstrings first.
				SessionModel current
					when: #startUpApplication
					send: #openWorkbenchOnPathName:
					to: PARTSFile
					with: partFileName.
            ]
        ifFalse: [	SessionModel current
		when: #startUpApplication
		send: #open
		to:  ( Smalltalk at: #PARTSEditor ) ]!
fileName: aFileReference in: aDirectory
    "Answer a PARTSFileDescriptor using the file name
    in <aFileReference> and directory in <aDirectory>.
    <aDirectory> it will be assumed to be the correct
    representation for its path. (e.g. if the path maps
    to a repository, <aDirectory> must already be a
    PARTSTeamVDirectory."
    | fileName teamClassDescriptor fileDescriptor dir |

    ( aFileReference isString not  "File descriptor"
        and: [ aFileReference directory = aDirectory ])
        ifTrue: [ ^aFileReference ].  "Already correct"

    fileName := aFileReference isString
        ifTrue: [ aFileReference ]
        ifFalse: [ aFileReference fileName ].
    dir := aDirectory asPARTSDirectory.

     teamClassDescriptor := Smalltalk at: #PARTSTeamVFileDescriptor
        ifAbsent: [ nil ].
    ( teamClassDescriptor isNil
        or: [ dir isPARTSTeamVDirectory not
        or: [
             ( fileDescriptor := teamClassDescriptor
                forRepository: dir
                entity: fileName ) isNil ]])
        ifTrue: [
            fileDescriptor :=
                PARTSDosFileDescriptor
                    forDirectory: dir fileName: fileName ].

    ^fileDescriptor
! 
sourceString: aString
        "Record aString as the current source code for the receiver.
        Do not record it in the change log for a PARTS script."

    sourceObject source: aString.!
helpTopic: aString
        " Specify the topic name for the receiver's context-sensitive
        help in its workbench/catalog help file. "

    wrapper helpTopic: aString!  
version
        " Answer the application's version property. "

    ^self userPropertyNamed: self versionPropertyName! 
generatePartNameFor: anObject
        " Answer a valid part name for <anObject> in the context
        of the receiver.  A part name must be a syntactically valid 
        name which is unique across all parts in the application. "

    ^self generatePartNameFor: anObject preference: anObject class name, '1'!   
addExternalMessage: aSymbol
        " Private - add the message selector <aSymbol> to the 
        external interface of this application. "

    "self ASSERT: aSymbol isSymbol."
    externalMessages := ( externalMessages isNil
        ifTrue: [ Array with: aSymbol ]
        ifFalse: [
            "self ASSERT: ( externalMessages includes: aSymbol ) not."
            externalMessages, ( Array with: aSymbol ) ] ).!
fromFile: aFileReference
        " Answer the application stored in aFileReference
        on the PARTS search path."
    | dir |

    ( dir := PARTSFile directoryContaining: aFileReference ) isNil
        ifTrue: [ ^nil ].

    ^self
        fromFile: aFileReference
        in: dir!
defaultScaleUnit
    "Private - Answer the default scale unit used for icons
    and links on the workbench for the receiver."

    ^property defaultScaleUnit!   
linkReferencedBy: aLinkReference
        "Private - answer the link referenced by aLinkReference."
    ^aLinkReference linkReferencedIn: self
!
loadSettingsFrom: aPathName
        " Load the PARTS Workbench settings from aPathName. "
    self
        loadSettingsFrom: aPathName
        into: self currentSettings.!   
version: aString
        " Set the application's version property. "

    self userPropertyNamed: self versionPropertyName put: aString!   
extractPartAndScriptNameFrom: aMethodSelector
        "Private - aMethodSelector is a selector which is a composed
        of the name of a part followed by a '_' followed by the original
        script selector.  When aMethodSelector was constructed, any
        underscores in the part name were doubled, so the first occurance
        of a single underscore indicates the division.  Any doubled underscores
        prior to the first single one must be undoubled. Answer an Array of two
        elements, the part name and the original script selector."
    | inStream outStream partName scriptSelector c |
    inStream := ReadStream on: aMethodSelector.
    outStream := WriteStream on: String new.
    [ partName isNil ] whileTrue: [
        c := inStream next.
        c = $_
            ifTrue: [
                c := inStream next.
                c = $_
                    ifTrue: [ outStream nextPut: c ]
                    ifFalse: [ partName := outStream contents ]]
            ifFalse: [ outStream nextPut: c ]].
    scriptSelector := inStream copyFrom: inStream position to: inStream size.
    ^Array with: partName with: scriptSelector asSymbol

!  
children: aCollection
    "Private - Backup the top level components of the receiver.
    The location of the children, during editing time, should
    be in the wrapper."

    property children:
        ( aCollection collect: [ :each |
            each isPARTSWrapper
                ifTrue: [ each object ]
                ifFalse: [ each ]]) asArray!
removeAllChangeMapsForClass: aClassName
        " Remove any ObjectChangeMap registered for loading
        instances of <aClassName> from any version. "

    self fileAccessorClass supportedVersions do: [ :aFileVersion |
        self
            removeChangeMapForClass: aClassName
            forVersion: aFileVersion ].!
fileDescriptor: aFileDescriptor
        "Specify the application part file."

    fileDescriptor := ( aFileDescriptor isNil
        ifTrue: [ nil ]
        ifFalse: [ aFileDescriptor isString
            ifTrue: [ PARTSFileDescriptor pathName: aFileDescriptor ]
            ifFalse: [ aFileDescriptor ] ] ).!   
COMMENT
"
PARTSScriptSource is a private class which belongs
to PARTSScript.
"!   
postMessageBox
    "Post a message box for the receiver with a default mesage title."

    self postMessageBox: nil!   
forEdit
        " Answer whether the copy must include
        information needed only for editing an object
        in a  PARTS Workbench.  "

    ^#( #copy #save ) includes: self operation!  
left: value
    left := value!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy parentWrapper libraryNameList componentScripts
        componentWrapper |

    "  Must be careful with the parent of an application's wrapper,
        because it crosses the boundary between a referenced
        application and the client application containing it.  Don't
        want to drag this linkage along when we mirrorCopy a
        referenced application within a containing application, which
        happens when opening a workbench or saving updated app
        or launching the app containing this referenced application.
        Client app must take care of making it so that the linkage
        is available at execution time, which is the only time it is
        ever needed.  Since this is never set in a root application
        or the referenced application itself, it should always be ok
        to zap the source. "
    wrapper notNil
        ifTrue: [  " don't want mirrorCopy of wrapper to pick this up "
            parentWrapper := wrapper parent.
            wrapper parent: nil ].

    libraryNameList := self libraryDependencies.
    self libraryDependencies: nil.

    aMirrorCopyDictionary at: self put: (copy := self class basicNew).  "OLD: copy"
    copy
        partWrapper: ( wrapper partMirrorCopy: aMirrorCopyDictionary );
        eventTable: ( eventTable partMirrorCopy: aMirrorCopyDictionary );
        property: ( property partMirrorCopy: aMirrorCopyDictionary );
        componentDictionary: ( componentDictionary partMirrorCopy: aMirrorCopyDictionary );
        partEditor: aMirrorCopyDictionary debugger;  " debugger or nil "
        editorState: ( editorState partMirrorCopy: aMirrorCopyDictionary );
        externalEvents: externalEvents copy;
        externalMessages: externalMessages copy.
    wrapper notNil
        ifTrue: [  "This link is important for the NestedPart"
            wrapper parent: parentWrapper].
    libraryNameList notEmpty
        ifTrue: [ self libraryDependencies: libraryNameList ].

    "Must backup components scripts here, because object filer
    doesn't file out the method dictionaries, and the wrapper
    (which also contains a reference to the dictionary) is removed
    during execution.  The draw back is that the user cannot load
    an app, enable it for execution, and store it programmatically
    because crucial logic is contained in mirror copy.  The alternative
    would require individual components to backup their scripts into
    properties, then reinstall during fileInActive.  The problem with
    that is during enable execution, don't know if storing to file, so
    must backup script every time, even if only for a test launch
    (which might break the debugger)."
    aMirrorCopyDictionary forExecute
        ifTrue: [
            componentScripts := copy componentScripts.
            copy componentDictionary do: [ :aComponent |
                ( componentWrapper := aComponent partWrapper ) hasScripts
                    ifTrue: [
                        componentScripts
                            at: aComponent
                            put: componentWrapper scriptDictionary ]].
            componentScripts notEmpty
                ifTrue: [
                    copy componentScripts: componentScripts ]].

    ^copy!
loadSettingsFrom: aPathName into: aPARTSSettings
        " Load the PARTS Workbench settings from aPathName
        into aPARTSSettings. "

    ( File exists: aPathName )
        ifFalse: [
            aPARTSSettings notNil
                ifTrue: [ aPARTSSettings initialize ].
            ^self new loadSearchPath: nil ].
    self new
        loadSettingsFrom: aPathName
        into: aPARTSSettings.!
scaleUnitPlural
        "Answer a String which is the plural
        version of the receiver's scale unit."
    scaleUnit == #twip ifTrue: [ ^'twips' ].
    scaleUnit == #inch ifTrue: [ ^'inches' ].
    scaleUnit == #centimeter ifTrue: [ ^'centimeters' ].
    scaleUnit == #pixel ifTrue: [ ^'pixels' ].
    ^'< undefined scale unit >'!
fileVersion
        " Answer the PARTS version of the application file being processed. 
        This is a version string defined by PARTSFile (not the same as the 
        ObjectFiler's version stamp). "

    ^fileVersion!  
signal: messageText
file: aFileReference
    "Signal that the exception represented by the receiver has occurred;
    create an instance to represent this specific occurrence.
    Associate the <messageText> and <aFileReference> with the occurrence."

    | exception |
    ( exception := self new )
        messageText: messageText;
        file: aFileReference.
    ^exception signal!  
source: sourceObject
    trigger: triggerSymbol
    receiver: destinationObject
    selector: selectorSymbol
        "Answer a new link, fired by <sourceObject> when the
        event <triggerSymbol> occurs, which sends the message
        <selectorSymbol> to <destinationObject>.  A default mapping
        of event arguments to message arguments is defined."

    ^self basicNew
        source: sourceObject;  " source object's wrapper "
        trigger: triggerSymbol;
        receiver: destinationObject;  " receiver (*or* its wrapper if script) "
        selector: selectorSymbol;
        initialize!   
concatenate: anInterfaceList defaultItem: newDefaultItem
        " Answer anInterfaceList appended to the receiver. "

    | nItems |
    nItems := items size.
    ^self class new
        items: self items, anInterfaceList items
        separators: (
            self separators,
            ( anInterfaceList separators
                collect: [ :indexEl | indexEl + nItems ] ) )
        defaultItem: newDefaultItem! 
isShrunk
        "Answer a boolean indicating whether the
         boundingBox of first level windows are
         shrunk from factoryPane to their min
         boundingBox."
    isShrunk isNil
        ifTrue: [^false]
        ifFalse: [^isShrunk]!   
description
        " Answer a string describing the receiver. "

    ^self descriptionIn: self application!   
partEditorTitle: aFileDescriptor
        "Private - Answer a String which will be used as the prefix in the title bar
        of the parts editor created through direct edit of the receiver."

    ^(demandLoad
        ifTrue: ['Demand Load --']
        ifFalse: ['Explicitly Load --']) ,
        	( aFileDescriptor isNil
				ifTrue: [ '' ]
				ifFalse: [aFileDescriptor displayName] )!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | myApplication copy |
    myApplication := application.
    application := nil.  " drop this out of the mirrorCopy, it gets refreshed "
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    application := myApplication.
    ^copy!  
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer  |
    answer := aCodeGenerator messageExpressionToReference: self.
    answer receiverObject: parentReference.
    self referencesResultLink
        ifTrue: [
            answer addSelector: #resultLink ]
        ifFalse: [
            answer addSelector: #argumentLinkNumber: with: index ].
    ^answer

!   
isFileInPath: aFileReference
        "Answer whether aFileReference is in the directory search path."

    ^( self directoryContaining: aFileReference ) notNil!   
loadValue: aString type: type using: anAction
        " Private "

    | value rs |
    type = 'string'
        ifTrue: [
            ^anAction evaluateWithArguments: ( Array with: aString ) ].
    type = 'boolean'
        ifTrue: [
            value := aString asUpperCase.
            value := ( value = 'TRUE'
                ifTrue: [ true ]
                ifFalse: [ value = 'FALSE'
                    ifTrue: [ false ]
                    ifFalse: [ ^self ] ] ).
            ^anAction evaluateWithArguments: ( Array with: value ) ].
    type = 'point'
        ifTrue: [
            value := Point fromString: aString.
            value isPoint ifFalse: [ ^self ].
            ^anAction evaluateWithArguments: ( Array with: value ) ].
    type = 'color'
        ifTrue: [
            value := colorValueDict at: aString asLowerCase
                ifAbsent: [ ^self ].
            ^anAction evaluateWithArguments: ( Array with: value ) ].
    type = 'symbol'
        ifTrue: [
            ^anAction evaluateWithArguments: ( Array with: aString asSymbol  ) ].
    type = 'stringList'
        ifTrue: [
            value := OrderedCollection new.
            rs := ReadStream on: aString.
            [ rs atEnd ] whileFalse: [
                value add: ( rs upTo: $; ) trimBlanks ].
            ^anAction evaluateWithArguments: ( Array with: value ) ].
    type = 'integer'
        ifTrue: [
            value := ( Number fromString: aString ) asInteger.
            ^anAction evaluateWithArguments: ( Array with: value ) ].
    ^self   " unknown type "! 
asReadStream
    ( directory validFile: fileName )
        ifFalse: [ ^PARTSFileNotFound signalForFile: self ].
    ^ (directory fileReadOnly: fileName) asByteFileStream! 
partAddScript: aScript
        "Private - add aScript as an instance specific script (or method)
        of the reciever."
    self partWrapper addScript: aScript selector method: aScript!   
currentDirectory
        " Answer the first directory on the PARTS search path. "

    ^self currentSearchPath first!  
file: aFileReference
    "Private - Set the file that caused the receiver to be raised.
    It is either a file name, file path name, or a file descriptor."

    file := aFileReference! 
getSymbolForLabel: aLabel
        " Answer the event or message name corresponding
        to the link label string <aLabel>. "

    | dataSlotCharacter |
    aLabel isNil ifTrue: [ ^nil ].
    dataSlotCharacter := self dataSlotCharacter.
    ( aLabel size = 2
    and: [ aLabel first = dataSlotCharacter ] )
        ifTrue: [ ^( String with: dataSlotCharacter ) asSymbol ].  "Needed for Windows "
    ^( aLabel reject: [ :c | c = dataSlotCharacter ] ) asSymbol!  
traceFire: aBoolean
        "Enable/disable tracing when the receiver is fired."

    traceFire := aBoolean.!  
exists: aPathNameOrDescriptor in: aDirectory
    "Answer whether the file specified by
    <aPathNameOrDescriptor> exists in <aDirectory>"

    ^PARTSFileDescriptor
        exists: aPathNameOrDescriptor
        in: aDirectory!  
label: aLabel
        "Set the label of the reciever."
    self propertyAt: #topLabel put: aLabel!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy.
        For executable files, file out a string for the file
        descriptor to avoid references to revision support
        classes. "

    ( fileDescriptor notNil and: [ aMirrorCopyDictionary forExecutableFile ])
        ifTrue: [
            aMirrorCopyDictionary
                at: fileDescriptor
                put: fileDescriptor fullPathName ].

    ^super partMirrorCopyReal: aMirrorCopyDictionary.!   
isVisualPropertyFrom: aFileStream
        " Answer the property for the application in the given
    stream that indicates whether it has any visual parts. "

    aFileStream size = 0
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStream file pathName.
            ^nil ].
    ^self fileAccessorClass new isVisualPropertyFrom: aFileStream! 
type: aType
    "A file extension"

    type := aType asUpperCase! 
fileTypeForBitmap

    "^self fileTypeFor: 'BMP'"
     ^PARTSFileType type: 'BMP' pattern: '*.BMP' description: 'Bitmap (*.BMP)'!  
partIcon
        " If the receiver can load the application, answer the
        application icon, otherwise, answer the icon for an
        empty part accessor."
    | appIcon |

"MEA 05/25/95 - application might be nil, if so don't send message #icon."
    ^( application isNil ifTrue: [ nil ] ifFalse: [ appIcon := application icon ] ) notNil
        ifTrue: [ appIcon ]
        ifFalse: [ super partIcon ]
!  
updateApplication: editors
    "Search <editors> for one that is editing the receiver's
    contents.  Update the receiver's contents with the
    editor's application.  Answer whether an update was
    performed.  For a part accessor, this will update the
    interface."
    | matchedEditor aFileDescriptor |

    matchedEditor := editors detect: [ :anEditor |
        ( aFileDescriptor := anEditor application fileDescriptor ) notNil and: [
           self fileDescriptor = aFileDescriptor ]]
      ifNone: [nil].

    matchedEditor notNil
        ifTrue: [
            matchedEditor exportApplication: self.
            ^true ]
        ifFalse: [ ^false ].!
icon: anIcon
		"Private - Retained for backward compatibility.  
		Use partIcon: instead."
	^self partIcon: anIcon!
upgradeMapsForLoadingPWW30
        " Private - answer the upgrade load maps for
        structure changes in the current version. "

    | changeMaps |
 
    changeMaps := OrderedCollection new.

	"Plug in the default change maps"
    #(
		#PARTSNotebookPart "dropped selection inst var."
        ) do: [ :classSymbol |
            changeMaps add: ( ObjectChangeMap forClassName: classSymbol ) ].


    ^changeMaps!
colorDictionary
        " Answer the dictionary of colors supported
        for PARTS settings.  Key is name, value
        is the color constant. "

    ^self constructColorDictionary!
fileDescriptor
        "Answer the descriptor of the file containing the application."

    ^property fileDescriptor!  
libraryDependencies: libraryNameList
        " Private - specify the libraries which were bound
        when the receiver was loaded. "

    property propertyAt: #libraryDependencies
        put: ( libraryNameList size = 0
            ifTrue: [ nil ]
            ifFalse: [ libraryNameList
                collect: [ :aLibrary | aLibrary isString
					ifTrue: [ aLibrary ]
					ifFalse: [ aLibrary name ] ] ] )! 
firstControlPointIndex
    "Private"
    ^self isEventLink
        ifTrue: [ 2 ]
        ifFalse: [ 1 ]!  
fileDescriptor: aFileDescriptor
        " Private - specify the PARTS file descriptor of the application file being processed. "

    fileDescriptor := aFileDescriptor.!  
createWindow
        " Private "
    self 
        partsIfOS2Do: [
            ^self create: PARTSHostInterface desktopWindowHandle
                 title: self label
                 frameStyle: 0
                 frameCreateFlags: 0
                 clientStyle: 0 ]
        partsIfWindowsDo: [ 
            ^self create: self windowClass
                 title: self label
                 style: WsPopUp
                 extendedStyle: self defaultExtendedStyle
                 rectangle: ( 0 @ 0 extent: 0 @ 0 )
                 parent: self parent ].! 
fromPathName: sourcePath
    destinationPathName: destinationPath
    "Load the application from <sourcePath> and
    store it on <destinationPath>, converting the
    file type as necessary."

    ( PARTSFileDescriptor pathName: sourcePath )
        storeOnPath: destinationPath!   
useTopStretched: boolean
    "Private - If boolean is true then make the
     top stretchable to the containing frame."

    mask :=
        ( boolean
            ifTrue: [ mask bitOr: 2r00000100]
            ifFalse: [ mask bitAnd: 2r11111011 ] )!   
pathName: aPathName
    "Answer an instance of a subclass of PARTSFileDescriptor."
    

    aPathName isString ifFalse: [
        ^aPathName ].  "already a descriptor"
    ^self pathName: aPathName in: Disk!
upgradeSelectorInfo: nameChangeDict
        " Private - to support protocol upgrades. "

    | newSelector |
    newSelector := nameChangeDict at: selector ifAbsent: [ nil ].
    newSelector notNil
        ifTrue: [ ^Association key: selector value: newSelector ].
    ^nil! 
fileName
    "Private - Answer the file name of the receiver"

    ^file isString
        ifTrue: [ file  fileNameLessPath ]
        ifFalse: [ file fileName ].!
description: aString
		" Specify a description of the file version. "

	description := aString.!   
changeFile: newFileDescriptor
        "Set the application file."
    | oldFileDescriptor oldApp |

    ( newFileDescriptor isNil
    or: [ self fileDescriptor = newFileDescriptor ])
        ifTrue: [ ^self ].

    oldFileDescriptor := self fileDescriptor.
    oldApp := application.
    self fileDescriptor: newFileDescriptor.
    application := nil.
    self loadApplication isNil
        ifTrue: [
            self fileDescriptor: oldFileDescriptor.
            application := oldApp.
            ^nil ].!  
icon
        " Answer the application icon. "

    ^property icon! 
resolveExtensionWith: fileTypes
    "If the receiver has no extension, resolve it
    by searching for files that match the given
    descriptor extentsions and answer a new
    instance.  Answer nil if a file could not be found."
    | name dir type |

    self fileType trimBlanks isEmpty
        ifFalse: [ ^self ].

    fileTypes do: [ :aFileType |
        type := aFileType type.
        name := ( self fileName fileName, '.', type ) "asLowerCase".
        ( dir :=
            PARTSFile directoryContaining: name
                ifNone: [ nil ]) notNil
            ifTrue: [
                ^self class fileName: name in: dir ]].

    ^nil! 
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it."
    ( nestedPart isNil or: [ precursiveError isNil ] )
        ifTrue: [
            MessageBox message: 'Unknown nested part file cannot load application.' ]
        ifFalse: [
            nestedPart fileNotFoundError: precursiveError ].
    ^nil!
obsoleteMessage
        " Sent by messages which exist only to provide protocol
        compatibility for PWO 2.0 code. "
    | process obsoleteMethod sendingMethod |
    ( self reportObsoleteMessageUse
    and: [ SessionModel current isRunTime not ] )
        ifTrue: [
            Terminal bell.
            process := Process copyStack.
            obsoleteMethod := process methodAt: 1.
            sendingMethod := process methodAt: 2.
            Transcript show:
                'Obsolete Workbench message ', obsoleteMethod printString,
            ' sent from ', sendingMethod printString; cr.
            ].!  
scaleUnit: aUnit
    "need to convert units"

    | newUnit |
    newUnit :=  ( aUnit isSymbol
        ifTrue: [ aUnit ]
        ifFalse: [ aUnit asSymbol ] ).
    ( self class scaleUnitsSupported includes: newUnit )
        ifFalse: [ ^MessageBox message: 'Unit ', newUnit, ' is not supported' ].
    scaleUnit = newUnit ifTrue: [^self].
    scaleUnit isNil ifTrue: [
        scaleUnit := newUnit.
        ^self].

    (self isLeftStretched not and: [left notNil]) ifTrue: [ left := self scaleUnitToPixelHorizontal: left ].
    (self isRightStretched not and: [right notNil]) ifTrue: [ right := self scaleUnitToPixelHorizontal: right ].
    (self isTopStretched not and: [top notNil]) ifTrue: [ top := self scaleUnitToPixelVertical: top ].
    (self isBottomStretched not and: [bottom notNil]) ifTrue: [ bottom := self scaleUnitToPixelVertical: bottom ].

    scaleUnit := newUnit.

    (self isLeftStretched not and: [left notNil]) ifTrue: [ left := self pixelToScaleUnitHorizontal: left ].
    (self isRightStretched not and: [right notNil]) ifTrue: [ right := self pixelToScaleUnitHorizontal: right ].
    (self isTopStretched not and: [top notNil]) ifTrue: [ top := self pixelToScaleUnitVertical: top ].
    (self isBottomStretched not and: [bottom notNil]) ifTrue: [ bottom := self pixelToScaleUnitVertical: bottom ].!  
forRectangle: aRect in: aControlOrRectangle
    "### replaces the old 'fromRect:' ###"
    "Answer a PARTSFramer for creating aRect in aControlOrRectangle
     with default attributes using default scale unit.
     aRect and aControlOrRectangle are regular Rectangle in pixel unit."

    ^self forRectangle: aRect in: aControlOrRectangle scaleUnit: DefaultScaleUnit!  
setDefaultAttributes

    "self fixedLeftInset;
        fixedWidth;
        fixedTopInset;
        fixedHeight"

    scaleUnit := DefaultScaleUnit.
    mask := self maskForDefault!  
isEventLink
        " Answer whether the receiver is triggered by an event. "

    ^self isResultLink not and: [ self isArgumentLink not ]!
partOpen
        " Display the receiver when it is being edited
        in a PARTS Workbench. Do nothing for the application."! 
defaultName
        " Private - answer the default part name of an application. "

    ^'PARTSApplication1'!   
fileTypeRegistry: aCollection
    "Set a collection of class name strings of
    existing file processors."

    FileTypeRegistry := aCollection.!
for: filePathName
    "Answer an instance of the receiver whose file
    is specified by <filePathName>.  Note that this
    method does not check if the file exists or not."
    | fileSystemPath fileEntity |

    fileSystemPath := filePathName asFileSystemPath.
    fileEntity := fileSystemPath entityName.
    ^( self new
        directory: fileSystemPath parentPath asPARTSDirectory;
        fileName: fileEntity;
        fileType: fileEntity fileExtension;
        yourself )!  
supportedReuseModes
        " Answer the supported nested part reuse modes. "

    ^#(
        #reference   " linked to part file "
        #embed       " embedded part file "
        #merge        " ensemble of parts "
        )! 
useBottomInset
    "Private - For the bottom side, use
      inset measurement."

    mask := mask bitOr: 2r10!   
removeLinksInSelfTo: components deletedLinks: deletedLinks
        " Remove all argument-collecting links or result links
        to any of the given <components>.  Add any links
        that are removed to <deletedLinks>. "

    | anArgumentLink |

    messageArgLinks notNil ifTrue: [
        1 to: messageArgLinks size do: [ :i |
            anArgumentLink := messageArgLinks at: i.
            ( anArgumentLink notNil
            and: [ anArgumentLink isInternalArgumentLink not ] ) 
                ifTrue: [
                    ( components includes: anArgumentLink destinationObject )
                        ifTrue: [  " delete it "
                            deletedLinks add: anArgumentLink.
                            messageArgLinks at: i put: nil ]
                        ifFalse: [   " enumerate its dependent links "
                            anArgumentLink
                               removeLinksInSelfTo: components
                                deletedLinks: deletedLinks ] ] ] ].

    resultLink notNil 
        ifTrue: [
            ( components includes: resultLink destinationObject )
                ifTrue: [   " delete it "
                    deletedLinks add: resultLink.
                    resultLink := nil ]
                ifFalse: [   " enumerate its dependent links "
                    resultLink
                        removeLinksInSelfTo: components
                        deletedLinks: deletedLinks ].
            ].!  
getDefaultProcessorFor: aFileDescriptor
    "Answer the first file processor which is used after none of the
    processors were found to process a certain type of file.."
    

    ^PARTSPartFileProcessor new

"    self fileTypeRegistry do: [:className |
        aClass := Smalltalk at: className asSymbol ifAbsent: [nil].
        aClass notNil ifTrue: [ ^aClass new fileDescriptor: aFileDescriptor; yourself ] ].
    ^ self error: 'You have no file processors available!!'"!
propertiesFrom: aFileStream
        " Answer the properties stored in aFileStream
        as a dictionary of name/value string pairs. "

    aFileStream size = 0
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStream file pathName.
        ^nil ].
    ^self fileAccessorClass new propertiesFrom: aFileStream! 
reportObsoleteMessageUse: aBoolean
        " Specify whether use of obsolete PW 2.0 messages
        will generate a warning. "

    ReportObsoleteMessageUse := aBoolean.!   
COMMENT
"
PARTSEditor is a private class whose only client is
PARTSApplication.
"!
manufacturer: aString
        " Set the application's manufacturer. "

    property manufacturer: aString! 
helpFile
        " Answer the name of the help file which provides
        help for the receiver in a workbench or catalog. "

    ^wrapper notNil ifTrue: [ wrapper helpFile ] ifFalse: [ '' ]!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
removeUserProperty: userPropertyName
        " Private - remove the value of the user property. "

    userProperties := (userProperties asOrderedCollection
        reject: [ :assoc | assoc key = userPropertyName])
            asArray!  
COMMENT
"
PARTSFileProcessor and its subclasses are private classes
which belong to the PARTS file access subsystem.
The public protocol for accessing PARTS files and their
contents is provided by PARTSApplication and PARTSFile.
"! 
writeValue: value type: type
        " Private "
    (type = 'string')
        ifTrue: [ ^stream nextPutAll: value ].
    ( (type = 'point')
        or: [( type = 'boolean' )
        or: [ type = 'symbol'
        or: [ type = 'integer' ]]])
        ifTrue: [ ^stream nextPutAll: value printString ].
    (type = 'color')
        ifTrue: [ ^stream nextPutAll: ( colorValueDict keyAtValue: value )].
    type = 'stringList'
        ifTrue: [
            ^value
                do: [ :string | stream nextPutAll: string asString ]
                andBetweenDo: [ stream nextPutAll: ';' ] ].
    self error: 'unknown type'!   
fromDisplayName: aDisplayName
	"Answer an instance of the receiver if <aDisplayName>
	corresponds to the display format answered by the
	method displayName"
    | dir |

    self subclasses do: [ :aDirSubClass |
        ( dir := aDirSubClass fromDisplayName: aDisplayName ) notNil
            ifTrue: [ ^dir ]].

    ^self fromPath: aDisplayName!  
usesSelectorIn: aCollectionOfSelectors
        " Private - to support protocol upgrades. "

    ^( aCollectionOfSelectors includes: selector )
        or: [ aCollectionOfSelectors includes: realSelector ]! 
directoryOf: fileName default: defaultDir
    "Answer a Directory for fileName using defaultDir. "
    | path dir |

    fileName isNil ifTrue: [ ^defaultDir ].

    ( dir := fileName fileNamePath ) size = 0
        ifTrue: [ dir := defaultDir ].
    ( path :=
        PARTSFileDescriptor stringFrom: fileName in: dir ) isNil
        ifTrue: [ ^nil ].

    ^PARTSDosDirectory fromPath: path!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #fileName: with: self fileName!  
changeContainingRect: srcRect to: destRect
        "Change receiver's containing rect from
          srcRect to destRect."

    | aFramer |
    aFramer := self unrelativeTo: srcRect extent.

    aFramer
        left:
            (( self isLeftInset or: [self isHorizontallyCentered] )
                ifTrue: [ aFramer left - ( self pixelToScaleUnitHorizontal:
                    ( self horizontalInsetFrom: srcRect left to: destRect left )) ]
                ifFalse: [ aFramer left ] )
        bottom:
            ( self isBottomInset
                ifTrue: [ aFramer bottom - ( self pixelToScaleUnitVertical:
                    ( self verticalInsetFrom: destRect bottom to: srcRect bottom )) ]
                ifFalse: [ aFramer bottom ] )
        right:
            ( self isRightInset
                ifTrue: [ aFramer right - ( self pixelToScaleUnitHorizontal:
                    ( self horizontalInsetFrom: destRect right to: srcRect right )) ]
                ifFalse: [ aFramer right ] )
        top:
            (( self isTopInset or: [self isVerticallyCentered] )
                ifTrue: [ aFramer top - ( self pixelToScaleUnitVertical:
                    ( self verticalInsetFrom: srcRect top to: destRect top )) ]
                ifFalse: [ aFramer top ] ).

    ^aFramer relativeTo: (0@0 extent: destRect extent)! 
manufacturerPropertyName
        " Private "

    ^'manufacturer'! 
description: aString
        " Set the application description. "

    ^property description: aString! 
defaultItem: anItem
        " Specify the default item of the receiver. "

    "self ASSERT: anItem notNil."  " fix client!!!! "
    defaultItem := anItem.!  
userProperties: anArray
        " Private "

    userProperties := anArray.!   
settingsFileWrapperTag
    "Private"
    ^'keepInExecutable'
! 
triggerInternalEvent: eventName withArguments: argumentList
        " Private - trigger the internal event <eventName >
        representing the invocation of an external message using
        the elements of the <argumentList> as the arguments.
        Answer the value returned by the most recently
        defined event handler action."

    | answer |
    "At runtime, the eventTableInternal holds the event handlers,
    and at edit time, partWrapper eventHandlers holds the event handlers."
    ^ ( self eventTableInternal                 "runtime"
        at: eventName asSymbol
        ifAbsent: [                                 "edit time"
            ( self partWrapper isNil
                or: [ self partWrapper eventHandlersAttribute isNil ])
                ifTrue: [ ^nil ].
            ( self partWrapper eventHandlersAttribute
                at: eventName asSymbol
                ifAbsent: [ ^nil ] )
                    do: [:each | answer := each evaluateWithArguments: argumentList ].
                    ^ answer ] )
            evaluateWithArguments: argumentList!   
workbenchSupportLibraryIndex
        " Private - answer the next available registration index. "

    ^WorkbenchSupportLibraryIndex!   
childrenInBuildOrder
        " Private - On OS/2, for purposes of
        determining tab order and groups, the children are
        traversed in the z-order among siblings.  When a child is
        built, its default z-order position is the top.  Therefore,
        the last child built is the first in the z-order."
    | buildOrder |

    buildOrder := self orderedChildren , self unorderedChildren.
    self partsIfOS2Do: [ buildOrder := buildOrder reversed ].

    ^buildOrder! 
useAllInset
    "Private - Make all sides with inset (not stretched)."

    mask := mask bitOr: 2r10101010!
workbenchSupportLibraries
        " Private - answer the dictionary of workbench support library
        information for the currently installed part runtime libraries. "

    ^WorkbenchSupportLibraries!   
defaultStyle
        "Private - Answer an Integer with appropriate styles in it.
        Exclude the scroll bars."
    ^self partsIfOS2Do: [
        super defaultStyle ]
     partsIfWindowsDo: [
        self partsVwOnly.  " Only used on VW"
        WsPaneBorder ]!   
relayLink: aSelector arguments: arguments
        " Private - relay a link to my application. "
    self applicationAtRuntime isNil
        ifTrue: [^nil].  " not bound "
    ( self application hasExternalMessage: aSelector )
        ifFalse: [ ^ MessageNotUnderstood message:
            ( Message receiver: self selector: aSelector arguments: arguments ) ].
    ^self application
        triggerInternalEvent: aSelector
        withArguments: arguments!  
COMMENT
"
PARTSScriptContext masquerades as the class to which
part scripts belong.  In actuality, scripts are purely instance
methods which belong to their part.  This class simply
provides a compilation context in which no state is
directly available for the reciever (scripts can only send
messages, they cannot violate encapsulation by directly
accessing the instance variables of the part to which
they belong).
"! 
runtimeCloneSkeleton
        " Private "

    ^self class basicNew!
maskForAllFixedInset
    "Private - Mask for all sides with fixed inset measurements."

    ^2r10101010!   
settingsFileDefaultScaleUnitTag
    "Private"
    ^'defaultScaleUnit'
!
executionStatePropertyName
        " Private "

    ^'executionState'! 
scrollVertical: anInt
        "Private - Reimplemented here because GroupPanes do
         not scroll."!
COMMENT
"
PARTSApplicationProperty is a private class whose only client is
PARTSApplication.

To get and set properties of a PARTS application, use the
public protocol provided by PARTSApplication.

"! 
asString
        " Answer the receiver's script source. "

    ^source!
eventTableAllocate
        " Private - allocate the internal and external event tables. "

    eventTable := Array
        with: self eventTableCreate    " external events "
        with: self eventTableCreate.   " internal events "!
bottom
    ^bottom!  
setMinimalRectangle: parent
    "Set the application wrapper's rectangle to the minimal
    bounding box of all first level visual parts.  The box is
    relative to the application's editor extent.
        <parent> is needed to determine whether a nested
    part without visual parts should include its framer in the
    minimum bounding box.  When the parent is a non-nested part
    window, the nested part is expanded.  If a nested part has no
    visual parts and is within another nested part, don't include its
    rectangle in the parent nested part's rectangle.
        If a component can't be a child, don't include it in the min box."
    | minBox containingRect box includeNestedRect canInclude |

    containingRect := 0@0 extent: self editorVirtualScreenExtent.
    minBox := nil.
    includeNestedRect :=
        ( parent isPARTSEditorPane not and: [
            parent isPARTSNestedPart not ]).
    self children do: [:obj |
        canInclude :=
            (( obj partRelativeToParent: parent )
                and: [
                    ( obj isPARTSNestedPart and: [ includeNestedRect ])
                    or: [ obj partHasVisualParts ]]).  "<=If nested part, this is slowest to perform"
        canInclude
            ifTrue: [
                box := obj framingBlock scaleFrom: containingRect.
                minBox := minBox isNil
                    ifTrue: [ box ]
                    ifFalse: [ minBox merge: box ]]].

    minBox isNil
        ifTrue: [ minBox := 0 @ 0 extent: 0 @ 0 ].
    wrapper notNil
        ifTrue: [ wrapper rectangle: minBox ].
    self parent notNil
        ifTrue: [ self parent runtimeRectangle: minBox ]!   
useBottomStretched: boolean
    "Private - If boolean is true then make the
     bottom stretchable to the containing frame."

    mask :=
        ( boolean
            ifTrue: [ mask bitOr: 1]
            ifFalse: [ mask bitAnd: 2r11111110 ] )!  
realSelector: aSymbol
        " Private "
    realSelector := aSymbol!  
COMMENT
    "This exception is signalled when a nested part cannot load its application."!   
addLinkMessageModelTo: aMessageExpressionModel
        "Private - add a message model to aMessageExpressionModel."
    ( self numberOfMessageArguments = 0 and: [ resultLink isNil ] )
        ifTrue: [
            aMessageExpressionModel
                addSelector: #when:send:to:
                with: trigger
                with: selector
                with: receiver ]
        ifFalse: [
            aMessageExpressionModel
                addSelector: #when:evaluate:
                with: trigger
                with: self partAsExecutableAction ]
!  
refersTo: anObject
        " Answer whether the receiver or any links that
        it triggers sends a message to <anObject>. "

    self destinationObject == anObject 
        ifTrue: [ ^true ].
    self dependentLinks do: [ :aLink |
        ( aLink refersTo: anObject ) ifTrue: [ ^true ] ].
    ^false!  
sourceObject: sourceObject
        "Private - set the source object which triggers the receiver."

    self source: sourceObject partWrapper.! 
hint
        " Answer the application's hint string. "

    ^hint! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
orderChildrenAndDisplay: aCollection
    "Private - Set the orderedChildren and update
    the display to reflect the new order"

    self orderedChildren: aCollection.
    aCollection reversed do: [ :aSibling |
        aSibling partBringSubPaneToTop ].

    self partEditor workbenchPane invalidateRect: nil.!
getCopyWithExtension: anExtension
        "Private - answer a copy of the receiver with
        a stream with an extension of aString."
    | fileDescriptor |

    fileDescriptor := self deepCopy.
    fileDescriptor fileName:
        fileDescriptor fileName fileName,
            ( anExtension size > 0
                ifTrue: [ '.', anExtension ]
                ifFalse: [ '' ]).
    fileDescriptor fileType: anExtension.
    ^fileDescriptor!  
scaleUnit
    ^scaleUnit!
anchorLink
        " Private - answer the event or result link which anchors
        the net of argument link paths containing the receiver. "

    | aLink |
    aLink := self.
    [ aLink isArgumentLink ]
        whileTrue: [ aLink := aLink source ].
    ^aLink!   
referencedWhileNotLoaded
        "Private - Trigger the event or post a message."
    self triggerEvent: #referencedWhileNotLoaded
        ifNotHandled: [
            (Message new
                receiver: MessageBox
                selector: #warning:
                arguments: (Array with:
                    'Referencing ', self fileName, ' while it is not loaded.')
                )   performDeferred.].!  
store: aPart libraryMappings: libraryMappings
    "Save <aPart> into the external storage described
    by the receiver.  <libraryMappings> is a dictionary
    mapping classes to their library names."
    | application |

    application := super store: aPart libraryMappings: libraryMappings.

   true ifTrue: [ ^application ].
    "Set the extended attributes."
    self partsIfOS2Do: [
    application notNil ifTrue: [
        PARTSFile fileAccessorClass
            setAttributesOfFile: self fileName
            in: self directory
            icon: aPart icon
            properties: aPart propertiesForFile ]].

    ^application! 
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded.
        Mutate when loading for debug. "

    | loadContext debugger debugLink |

    loadContext := anObjectFiler clientContext.
    loadContext isPARTSLoadContext not  " paste parts has no context "
        ifTrue: [ ^self ].

    " mutate into a debuggable link if debugging "
    ( debugger := loadContext debugger ) notNil
        ifTrue: [
            debugLink := self debugLinkClass basicNew.
            1 to: self class instSize do: [ :i |
                debugLink instVarAt: i put: ( self instVarAt: i ) ].
            debugLink debugger: debugger.
            ^debugLink ].!
from: aLink
    "Private - Answer an instance of the receiver from <aLink>.
    <aLink> is a link class, but not necessarily the same class
   as the receiver."

    ^self basicNew
        setFrom: aLink;
        yourself.!
versionFromFile: aFileReference in: aDirectory
        " Answer the PW file version of the file
        named <aFileReference> in <aDirectory>. "

    | aFileStream fileVersion |
    aFileStream := ( PARTSFileDescriptor fileName: aFileReference in: aDirectory )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ fileVersion := self versionFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^fileVersion!  
loadAction
		" Answer a 2-argument action to evaluate when an application
		has been loaded from a part file with the receiver's file version string. "

	^loadAction!
applicationFromFile: aFileReference in: aDirectory
        " Answer the PARTS application stored in <aFileReference>
        in <aDirectory>.  The application is in editable form
        and has not yet been enabled for execution.
        If <aFileReference> already exists in <aDirectory>,
        use <aFileReference> in case there is revision information."

    | aFileDescriptor |
    aFileDescriptor :=
        ( aFileReference isString not
        and: [ aFileReference directory = aDirectory ] )
            ifTrue: [ aFileReference ]
            ifFalse: [ PARTSFileDescriptor fileName: aFileReference in: aDirectory ].
    ^aFileDescriptor isNil
        ifTrue: [ nil ]
        ifFalse: [ aFileDescriptor loadForEdit ]!   
orderedChildren: anOrderedCollection
        "Private - Set the OrderedCollection which is the
        ordering of the children for tab and arrow keys."

    property orderedChildren: anOrderedCollection!  
partWrapper: aWrapper
        " Private - set the PARTS wrapper of the receiver. "
    wrapper := aWrapper! 
fileDescriptor
        "Answer the application part file reference."

    ^fileDescriptor! 
defaultText
    "Private - Answer the default error message"

    "Implemented by subclass"!   
rectangle: aRectangle
        " Set the size of the receiver.  This is the background
        area in a workbench. "

    wrapper rectangle: aRectangle!  
directoryContaining: aFileReference raiseError: raiseError
        " Answer the first directory on the PARTS search path
        containing aFileReference. "

    ^self directoryContaining: aFileReference
        ifNone: [
            raiseError
                ifTrue: [
                    PARTSNotOnSearchPath signalForFile: aFileReference ]
                ifFalse: [
                    MessageBox warning:
                        'Cannot locate ', aFileReference asString, ' in the PARTS Workbench search path.'.
                    ^nil ]]!   
resultLink: aLink
        "Private - set the receiver's state to reference aLink."
    parentReference := self class for: aLink source.
    index := 0!
verticalInsetFrom: number1 to: number2
    "Private - Answer inset between number1 and
     number2 vertically independent of platforms."

    ^ ( 2 isBelow: 1 )
        ifTrue: [ number2 - number1 ]
        ifFalse: [ number1 - number2 ]! 
traceFire
        "Answer whether tracing is enabled when the receiver is fired."

    ^traceFire! 
linkReferencedBy: aLinkReference editState: anEditState
        "Private - set the edit state of the link referenced by aLinkReference."
    | link |
    link := self linkReferencedBy: aLinkReference.
    link notNil ifTrue: [
        link editState: anEditState ]
!  
upgradeMapsForLoadingPWO20
        " Private - answer the upgrade load maps for
        name and structure changes needed to load
        PW/OS2 2.0 applications into the current system. "

    | changeMaps aChangeMap |
    changeMaps := OrderedCollection new.

    self upgradeClassRenamingFromPWO20 associationsDo: [ :assoc |
        changeMaps add: ( ObjectChangeMap
            forClassName: assoc key
            destinationClassName: assoc value ).
        ].

    " PARTSIcon - iconCore -> bitmap, colorBitmap; name -> label; drop 'iconFile' "
    changeMaps add: ( ( ObjectChangeMap forClassName: #PARTSIcon )
        put: 'iconCore' into: 'bitmap';  " fileInActivate must fix this up "
        put: 'name' into: 'label';
        yourself ).

    " EntryField inst vars reordered, 'maxSize' -> #textLimit property "
    aChangeMap := changeMaps detect: [ :ocm |
        ocm sourceClassName = 'EntryField' ].
    aChangeMap put: 'maxSize' into: 'topCorner'.  " upgrader must fix "

    " TextPane moved under EntryField: reordered, 'maxSize' -> #textLimit property,
        'readonly' -> style bits "
    aChangeMap := changeMaps detect: [ :ocm |
        ocm sourceClassName = 'TextPane' ].
    aChangeMap    " upgrader must fix both of these "
        put: 'maxSize' into: 'topCorner';
        put: 'readonly' into: 'handle'.

    " notebook part keeps page rebuild order in properties in 3.0; this was in
        the sortedPages inst var in PWO 2.0, which is no longer around "
    aChangeMap := changeMaps detect: [ :ocm |
        ocm sourceClassName = 'LAFNotebook' ].
    aChangeMap put: 'pagesSorted' into: 'orderedPages'.  " fileInActivate must fix this up "

    " PWO 2.0 NestedPart 'file' -> 'fileDescriptor' in 2.0 "
    aChangeMap := changeMaps detect: [ :ocm |
        ocm sourceClassName = 'NestedPart' ].
    aChangeMap put: 'file' into: 'fileDescriptor'.

    changeMaps addAll: self upgradeMapsForLoadingPW20.
    ^changeMaps!   
isShrunk: aBoolean
    isShrunk := aBoolean! 
constructColorDictionary
        " Private - answer the color dictionary. "

    ^Dictionary new
        at: 'black' put: Color black;
        at: 'blue' put: Color blue;
        at: 'dark blue' put: Color darkBlue;
        at: 'brown' put: Color brown;
        at: 'cyan' put: Color cyan;
        at: 'dark cyan' put: Color darkCyan;
        at: 'green' put: Color green;
        at: 'dark green' put: Color darkGreen;
        at: 'light gray' put: Color gray;
        "at: 'pale gray' put: Color gray;"
        at: 'dark gray' put: Color darkGray;
        at: 'pink' put: Color pink;
        at: 'dark pink' put: Color darkPink;
        at: 'red' put: Color red;
        at: 'dark red' put: Color darkRed;
        at: 'white' put: Color white;
        at: 'yellow' put: Color yellow;
        yourself!  
leftTopEventLabel
        " Answer the offset of the top left corner of the link's event label
        from the path's launch point. "
    ^leftTopEventLabel! 
currentSettings
        " Answer the current Workbench settings object. "

    ^( Smalltalk at: #PARTSSettings ifAbsent: [ ^nil ] ) current!   
addComponent: anObject
    preferredName: preferredName
    parent: parentPart
    rectangle: aRectangle
    helpInfo: helpInfo
    icon: anIcon
        " Private - add <anObject> to the receiver.  Create its
        wrapper and install it under the specified parent part.
        The rectangle should be specified in the parent's coordinates.
        Nonvisual part must provide icon. "

    | name newWrapper parentWrapper |
    name := self generatePartNameFor: anObject
        preference: preferredName.
    self addComponent: anObject name: name.
    newWrapper := PARTSWrapper new
        name: name;
        object: anObject;
        helpInfo: helpInfo;
        yourself.
    parentWrapper := parentPart partWrapper.
    parentWrapper addComponent: newWrapper.
    newWrapper parent: parentWrapper.
    anObject partWrapper: newWrapper!   
components
        " Answer a collection of all components in the application. "
    ^componentDictionary values!   
loadPartFile: aPathNameOrDescriptor
        " Load the PARTS application in aPathNameOrDescriptor.
        If no file extension is given and the file does not exist,
        attempt to load the .par file named fileName from
        the PARTS search path.  If not found, attempt to load
        the .exe file named fileName.  Answer the application "

    | aFileName extension directoryPathSpecified
      parFileExtension paxFileExtension
      parFileName paxFileName |

    aFileName := aPathNameOrDescriptor asString.
    extension := aFileName fileExtension trimBlanks asUpperCase.
    directoryPathSpecified :=
        ( aFileName fileNameLessPath ~= aFileName ).

    parFileExtension := PARTSFileDescriptor fileTypeForPart type asUpperCase.
    paxFileExtension := PARTSFileDescriptor fileTypeForExecutablePart type asUpperCase.

    " simply find the file when extension is specified "
    extension size > 0
        ifTrue: [
            " .par or .pax format file "
            ^directoryPathSpecified
                ifTrue: [ self fromPathNameOrEditor: aFileName ]
                ifFalse: [ self fromFileOrEditor: aFileName ] ].

    " find the first .par or .exe in the search path when
        no file extension specified "
    parFileName := aFileName, '.', parFileExtension.
    paxFileName := aFileName, '.', paxFileExtension.
    directoryPathSpecified
        ifTrue: [
            ( PARTSFile exists: parFileName )
                ifTrue: [ ^self fromPathNameOrEditor: parFileName ].
            ( PARTSFile exists: paxFileName )
                ifTrue: [ ^self fromPathNameOrEditor: paxFileName ].
            ]
        ifFalse: [
            PARTSFile currentSearchPath do: [ :aDirectory |
                ( PARTSFile exists: parFileName in: aDirectory )
                    ifTrue: [ ^self fromFileOrEditor: parFileName in: aDirectory ].
                ( PARTSFile exists: paxFileName in: aDirectory )
                    ifTrue: [ ^self fromFileOrEditor: paxFileName in: aDirectory ].
                ].
            ].
    ^PARTSFileNotFound signalForFile: aPathNameOrDescriptor!  
store: anApplication into: aStream libraryMappings: libraryMappings
    " Store <anApplication> to a new file on <aStream>. "

    self implementedBySubclass.!
openFileReadOnly: aFileName
        " Answer a ReadOnly filestream on aFileName
        in the first directory on the PARTS search path
        containing it. "

    ^self openFileReadOnly: aFileName
        ifNone: [
            PARTSNotOnSearchPath signalForFile: aFileName.
            ^nil ]!  
addScript: aSymbol method: aCompiledMethod to: aComponent
        "Private - Add a script definition to <aComponent>.
        Answer the scriptDictionary."
    | scriptDictionary |

    Symbol mustBeSymbol: aSymbol.
    scriptDictionary := self partIsEditing
        ifTrue: [ aComponent partWrapper scriptDictionary ]
        ifFalse: [ self componentScripts at: aComponent ifAbsent: [ nil ]].
    scriptDictionary isNil
        ifTrue: [
            scriptDictionary := PARTSScriptDictionary new.
            aComponent addBehavior: scriptDictionary.
            self partIsEditing
                ifTrue: [
                    aComponent partWrapper scriptDictionary: scriptDictionary ]
                ifFalse: [
                    self componentScripts:
                        ( self componentScripts
                                at: aComponent
                                    put: scriptDictionary;
                        yourself )]].
    scriptDictionary at: aSymbol put: aCompiledMethod.
    ^scriptDictionary!  
partIsPart
        "Answer whether the receiver is a component
        part of a PARTSApplication."

    ^false  "Not a component of itself"! 
for: anOwner
        " Answer a load context for <anOwner>. "

    ^self new owner: anOwner; yourself! 
link: aLink
        "Private - set the receiver's state to reference aLink."
    | siblingLinks |
    partName := aLink source partName.
    event := aLink trigger.
    siblingLinks := aLink source linksTriggeredBy: event.
    index := siblingLinks indexOf: aLink.!   
sequenceIndex
    "Answer the position of the receiver in
    the link sequence of the receiver's source"

    ^( self source linksTriggeredBy: trigger )
        indexOf: self! 
type
    ^type!  
displayName
        " Answer the standard representation of the receiver's
        fully-qualified path name. "

    ^self drivePathName "asLowerCase"!   
exitIfLastWindow
        " Exit runtime PARTS image if there are no top-level
        windows left. "

    SessionModel current isRunTime
        ifTrue: [
            Notifier windows
                detect: [ :w | w isApplicationWindow or: [ w isDialogWindow ] ]
                ifNone: [ ^Smalltalk exit ] ].
    ^nil!
store: anApplication into: aStream libraryMappings: libraryMappings
    " Store <anApplication> to a new file on <aStream>. "

    self prepareToStoreApplication: anApplication.
    PARTSFile fileAccessorClass
        store: anApplication
        on: aStream
        icon: self applicationIcon
        hint: anApplication partHint
        helpFile: anApplication helpFile
        helpTopic: anApplication helpTopic
        properties: anApplication propertiesForFile
        libraryMappings: libraryMappings.
    self finishStoringApplication: anApplication.!  
registerChangeMap: aChangeMap forVersion: aFileVersion
        " Register an ObjectChangeMap to use for loading
        part files written in version aFileVersion.  The change
        map allows a class whose name or shape has changed
        to be quietly upgraded.  For a shape change, new
        instance variables which require initialization should be
        handled by a #fileInActivate: method in the changed class. "

    | changeMaps |
    changeMaps := ( self upgradeMapsDictionary at: aFileVersion
        ifAbsentPut: [ #() ] )
            asOrderedCollection.
    changeMaps := changeMaps reject: [ :aRegisteredMap |
        aRegisteredMap sourceClassName = aChangeMap sourceClassName ].
    changeMaps add: aChangeMap.
    self upgradeMapsDictionary
        at: aFileVersion
        put: changeMaps asArray.! 
partHint
    ^super partHint,
            (self fileDescriptor notNil
                ifTrue: [
                    ' - a part accessor associated with ', self fileName]
                ifFalse: [' - a part accessor not associated with any part'])! 
fileDescriptor: aFileDescriptor
	"Set the file descriptor on which the receiver was initiated."

    fileDescriptor := aFileDescriptor.!   
componentPoolNameForClassModel
        "Private - answer the name of the pool that will be part of the class
        that the receiver would generate  for code generation.  This pool
        will hold all the names of the receiver's components, enabling
        all the scripts within the receiver to be stored (and recompiled)
        as methods.  This pool is needed for scripts that might reference
        another part."
    ^( 'ComponentPoolFor', self builderClassName ) asSymbol

!  
fileInRecordLibraryDependencies: anObjectLoader
        " Private - the receiver has just been loaded.
        Record the libraries which were bound as a result
        of loading the receiver. "

    self libraryDependencies: anObjectLoader libraryDependencies.!  
defaultPartNameFor: anObject
        " Private - answer the default part name to use for <anObject>. "

    | specialNameMap className |
    specialNameMap := Dictionary new
        at: 'PARTSNestedPart' put: 'NestedPart';
        at: 'PARTSPartAccessorPart' put: 'PartAccessor';
        yourself.
    className := anObject class name.
    ^specialNameMap at: className ifAbsent: [ className ]!   
generatePartNameFor: anObject preference: preferredName
        " Answer a valid part name for <anObject> in the context
        of the receiver, with <preferredName> if possible.
        A part name must be a syntactically valid name
        which is unique across all parts in the application. "

    | componentName rootName count |

    anObject isNil ifTrue: [ ^nil ].
    ( self isValidComponentName: preferredName )
        ifTrue: [ ^preferredName ].

    " generate a default componentName "
    rootName := ( preferredName isNil
        ifTrue: [ self defaultPartNameFor: anObject ]
        ifFalse: [ preferredName select: [ :c | c isAlphaNumeric ] ] ).
    [ rootName notEmpty and: [ rootName first isLetter not ] ]
        whileTrue: [
            rootName := rootName copyFrom: 2 to: rootName size ].
    [ rootName notEmpty and: [ rootName last isLetter not ] ]
        whileTrue: [
            rootName := rootName copyFrom: 1 to: rootName size - 1 ].
    rootName := ( rootName size = 0
        ifTrue: [ anObject class name ]
        ifFalse: [
            rootName at: 1 put: rootName first asUpperCase.
            rootName ] ).

    count := 1.
    [ self isValidComponentName:
        ( componentName := rootName, count printString ) ]
            whileFalse: [ count := count + 1 ].
    ^componentName! 
numberOfControlPoints
    "Private"
    | pathPoints |
    ^( pathPoints := editState pathPointsAttribute ) size = 0
        ifTrue: [ 0 ]
        ifFalse: [
            pathPoints size
                - ( self isArgumentLink
                    ifTrue: [ self isInternalArgumentLink ifTrue: [ 0 ] ifFalse: [ 1 ] ]
                    ifFalse: [ self isResultLink ifTrue: [ 1 ] ifFalse: [ 2 ]] ) ].  " event or result "! 
uniqueEventForSource
    "Answer a unique event for the receiver.
    For event links, concatenate the receiver name to the event.
    For argument links, concatenate the argument number to
        the unique name for the source link.
    For result links, concatenate an 'r' to the unique name for
        the source link. "
    | aTrigger result |

    self isEventLink
        ifTrue: [
            aTrigger := trigger asString.
            ^( source partName, aTrigger ) asSymbol ].

    aTrigger := '-',source uniqueEventForSource asString.

    source isEventLink
        ifTrue: [ "Uniquely identify the event link for the receiver"
            aTrigger := '-',source sequenceIndex asString, aTrigger ].

    self isArgumentLink
        ifTrue: [
            ^( trigger asString, aTrigger ) asSymbol ].

    "Result link"
    result := 'r', aTrigger.
    result := result
        replaceCharacter: $:
        from: 1
        to: result size
        withString: ''.
    result := result, ':'.
    ^result asSymbol!  
destinationName
        " Answer the name of the receiver's destination object. "

    | anObject |
    "self ASSERT: self isInternalArgumentLink not."
    anObject := self destinationObject.
    ^( anObject isPARTSApplication
    and: [ anObject hasExternalEvent: selector ] )
        ifTrue: [ 'internal message' ]
        ifFalse: [ self application componentNameOf: anObject ]!
partCopyLiteral: anObject
        "Private - code generation - "
    | array |
    anObject isArray ifFalse: [ ^anObject copy ].
    array := anObject class new: anObject size.
    1 to: array size do: [ :i |
        array at: i put: ( self partCopyLiteral: ( anObject at: i )) ].
    ^array  ! 
aboutToSaveImage
        " Image save event handler "

    PARTSTimer notNil
        ifTrue: [
            PARTSTimer 
                aboutToSaveImage;
                close.
            PARTSTimer := nil ].! 
asInteger: aValue
        " Private - answer aValue as an integer. "
    ^(aValue isNumber or: [aValue isString])
        ifTrue: [aValue asInteger]
        ifFalse: [0]!
mainObjectPrivate
        "Private - Try answering the first component in the application
    that can be added to something other than the workbench
    desktop itself.  Answer any object if possible.
        The logic behind only looking at the main object is that either
    all top level components can be either placed under the same
    given parent or are a desktop child."
    | topLevelComponents |

    "Executables can only be added as non-visual part accessors"
    self isExecutable
        ifTrue: [ ^nil ].

    "Don't look at nested parts, since it forces an app load, causing
        team/v file descriptors to be calculated, which is a problem
        when filing out because repository instances are filed out too."
    ^( topLevelComponents :=
            self partWrapper components reject: [ :topLevelComponent |
                topLevelComponent object isPARTSNestedPart ]) size > 0
        ifTrue: [
            ( topLevelComponents
                detect: [ :aWrapper | aWrapper object partIsDesktopChild not ]
                ifNone: [
                    topLevelComponents
                        detect: [ :bWrapper | bWrapper object partHasVisualParts ]
                        ifNone: [ topLevelComponents first ]]) object ]
        ifFalse: [ nil ]
! 
prepareToStoreInApplication: anApplication
    "Private - Doing final cleanup before saving to <anApplication>.
    Remove anything that shouldn't be filed out."

    anApplication isEditable
        ifTrue: [
            application := nil.
            ( fileDescriptor notNil
                and: [ fileDescriptor isString not
                and: [ fileDescriptor isPARTSTeamVFileDescriptor ]])
                ifTrue: [
                    fileDescriptor clearReferences.
                    fileDescriptor revisionNumber: nil ]]
!  
readerClass
		" Answer the name of the class which
		can read the application in this file version. "

	^readerClass! 
display
    graphicsTool 
        backColor: self backColor;  "The color set from beginPaint
            is always a proximate, so reset to exact color."
        blank: ((0@0) extent: self extent).!
componentScripts: aDictionary
        "Private - Set the application components' script
        dictionaries.  This information is only valid for
        executable applications (because the wrappers are
        stripped.)"

    ^self propertyAt: #componentScripts put: aDictionary!  
applicationClass
        "Private - answer the class of application that the receiver creates."
    ^PARTSApplication!  
helpAndHintFrom: aFileStream
        " Answer the help and hint info store in aFileStream
        as an array of strings (help file name, help topic, hint). "

    aFileStream size = 0
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStream file pathName.
            ^nil ].
    ^self fileAccessorClass new helpAndHintFrom: aFileStream! 
isBottomInset
    "Private - Answer true if the bottom measurement is inset
     and false if it is height."

    ^(mask bitAnd: 2r10) > 0!   
pathPointsOriginLeftTop: anArrayOfPoints
        " Specify the position points of the link's path, specified
        as relative offsets from the launch point.  The offset points
        in anArrayOfPoints are defined in a coordinate system whose
        origin is at the leftTop corner. "
    anArrayOfPoints isNil ifTrue: [ ^self ].
    pathPoints := ( PARTSHostInterface hostCoordinateSystemOrigin = #leftTop
        ifTrue: [ anArrayOfPoints ]
        ifFalse: [ anArrayOfPoints collect: [ :aPoint | aPoint x @ aPoint y negated ] ] )!
isTopInset
    "Private - Answer true if the top measurement is inset
     and false if it is height."

    ^(mask bitAnd: 2r00001000) > 0!   
triggerInternalEvent: eventName
        " Private - trigger the internal event <eventName >
        representing the invocation of an external message.
        Answer the value returned by the most recently
        defined event handler action."

    | answer |
    "At runtime, the eventTableInternal holds the event handlers,
    and at edit time, partWrapper eventHandlers holds the event handlers."
    ^ ( self eventTableInternal             "runtime"
        at: eventName asSymbol
        ifAbsent: [                                     "edit time"
            ( self partWrapper isNil
                or: [ self partWrapper eventHandlersAttribute isNil ])
                ifTrue: [ ^nil ].
            ( self partWrapper eventHandlersAttribute
                at: eventName asSymbol
                ifAbsent: [ ^nil ] )
                    do: [:each | answer := each evaluate ].
                    ^ answer ] )
            evaluate
!  
currentSearchPath
        " Answer a list of the directories on the PARTS search path. "

    ^DirectorySearchPath!
forFileStream: aFileStream
        " Answer a timestamp with the date and time
        that aFileStream was last written. "
    ^self forFile: aFileStream file!   
nestedPart: aNestedPart
        "Private - set the nested part that cannot load its nested application."
    nestedPart := aNestedPart! 
setMinimalRectangleMerge: parent
    "Set the application wrapper's rectangle to the minimal
    bounding box of all first level visual parts.  The box is
    relative to the application's editor extent.
        If a component can't be a child, don't include it in the min box."
    | minBox containingRect obj box canInclude
         icon iconRect windowRect isVisual |

    containingRect := 0@0 extent: self editorVirtualScreenExtent.
    minBox := nil.
    wrapper components do: [:wrap |
        obj := wrap object.
        isVisual := obj respondsTo: #framingBlock.
        canInclude := obj partRelativeToParent: parent.
            "Want visual guys always dropping at cursor if in a window"
        ( parent isPARTSEditorPane not and: [ isVisual not ])
            ifTrue: [ canInclude := false ].
        canInclude
            ifTrue: [
                isVisual
                    ifTrue: [
                        windowRect := obj framingBlock scaleFrom: containingRect.
                        icon := obj partShrunkenIconAttribute ]
                    ifFalse: [ icon := wrap icon ].
                icon notNil
                    ifTrue: [ iconRect := icon visibleFrame ].
                box := windowRect.
                iconRect notNil
                    ifTrue: [
                        box := ( box isNil
                            ifTrue: [ iconRect ]
                            ifFalse: [ box merge: iconRect ])].  "Include both if a shrunken part"
                minBox := minBox isNil
                            ifTrue: [ box ]
                            ifFalse: [ minBox merge: box ]]].

    minBox isNil
        ifTrue: [ minBox := 0 @ 0 extent: 0 @ 0 ].
    wrapper rectangle: minBox.!   
launchWorkbench: applicationPathName
        " Private - open a PARTS Workbench window. "

    | partFileName |

    self standaloneWorkbenchLibraries do: [ :aLibraryName |
        ( self class
                bindLibrary: aLibraryName
                errorTitle: 'Unable to start PARTS Workbench'
                neededFor: 'workbench script support' )
            ifFalse: [ ^Smalltalk exit ] ].

    applicationPathName notEmpty
        ifTrue: [
            partFileName := applicationPathName asArrayOfSubstrings first.
            PARTSFile openWorkbenchOnPathName: partFileName.
            ]
        ifFalse: [ ( Smalltalk at: #PARTSEditor ) open ].!   
editorState: state
        " Private - set the application editor state. "

    editorState := state.! 
describeApplicationInPathName: aPathName
        " Display a report describing the objects stored in the
        PARTS application in the .PAR file named <aPathName>. "

    | partFileStream reportStream |
    CursorManager execute 
		changeFor: [
    		partFileStream := File pathNameReadOnly: aPathName.
    		reportStream := ReadWriteStream on: String new.
    		self fileAccessorClass new 
       				describeApplicationIn: partFileStream
        		on: reportStream
        		includeDetails: true.
   			partFileStream close.
			].
    TextWindow new openOn: reportStream contents.! 
landingSide: aSide
        " Specify the side of the link's destination object to which
        the landing point of its path is attached. "
    landingSide := aSide.!
COMMENT
"
A PARTSScript is the executable representation of a script
attached to a part in a PARTS application.

This class is private to the PARTS Workbench implementation.
It is maintained by the workbench and script editors and should
not be manipulated directly by clients.

To programmatically create and delete scripts, use the public
protocol supported by all parts:
    partDefineScript: scriptSourceString
    partScriptSourceOf: scriptMessageSelector
    partRemoveScript: scriptMessageSelector

Script manipulations are only supported in the workbench environment.

"!  
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."
    self partsVosOnly.  " Only used on VOS"

    ^self class noScrollbarsFrameStyle!
nestedPartFromFileOrEditor: requestedFileDescriptor
    debugger: aDebugger
    useSearchPath: useSearchPath
        "Depending on <useSearchPath>, answer either the first copy of the
        application on the search path with the file name in <requestedFileDescriptor>
        which is to be used as a nested part, or the exact file requested.  The file
        is assumed to exist (client is responsible for ensuring this precondition.).
        If the first file found is not the requested file, return a new
        descriptor for this file."
    | aFileDescriptor anEditor tempDescriptor dir |

    ( dir := PARTSFile directoryContaining: requestedFileDescriptor ) isNil
        ifTrue: [ ^nil ].

    aFileDescriptor := ( useSearchPath
        ifTrue: [    "Find the first file on the search path"
            tempDescriptor := PARTSFileDescriptor
                fileName: requestedFileDescriptor fileName
                in: dir.
            tempDescriptor directory = requestedFileDescriptor directory
                ifTrue: [ requestedFileDescriptor ]
                ifFalse: [ tempDescriptor ]]
        ifFalse: [ requestedFileDescriptor ] ).

    ( anEditor := PARTSApplication workbenchContainingFile: aFileDescriptor ) notNil
        ifTrue: [    "An existing w.b. is editing this file."
            ^aDebugger isNil
                ifTrue: [ anEditor getAppCopyToEdit ]
                ifFalse: [ anEditor getAppCopyForDebugger: aDebugger enableExecution: false ]
                ].
    ^aFileDescriptor loadForEditWithContext:
        ( PARTSLoadContext new
            fileDescriptor: aFileDescriptor;
            debugger: aDebugger;
            yourself )!  
aboutToSaveImage
        " Private - stop timers when image is saved. "
    items size > 0
        ifTrue: [
            self stopAllTimers.
            MessageBox warning: 'All PARTS timers have been stopped.' ].!   
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
scaleFactor: aPoint
        " Private - specify the scaling factor for a part size specification. "

    scaleFactor := aPoint.!   
forDebugger: aPartDebugger
        " Private - answer a MirrorCopy dictionary for
        making a copy which will be debugged by
        <aPartDebugger>. "

    ^( self for: #copyDebuggable )
        debugger: aPartDebugger;
        yourself!
COMMENT
"
A PARTSInterfaceList defines the content and representation
(order and section divisions) of the event or message
interface of a part.
"!  
concatenateSeparated: anInterfaceList defaultItem: newDefaultItem
        " Answer anInterfaceList appended to the receiver
        with a separator line between the two lists. "

    | nItems |
    nItems := items size.
    ^self class new
        items: self items, anInterfaceList items
        separators: (
            self separators,
            ( ( nItems = 0
            or: [ anInterfaceList items size = 0 ] )
                ifTrue: [ #() ]
                ifFalse: [ Array with: nItems ] ),
            ( anInterfaceList separators
                collect: [ :indexEl | indexEl + nItems ] ) )
        defaultItem: newDefaultItem!
fileTypeForPart

    "^self fileTypeFor: 'PAR'"
   ^PARTSFileType type: 'PAR' pattern: '*.PAR' description: 'Part (*.PAR)'!
setSource: sourceString componentNameDictionary: aComponentDictionary part: aPart
        " Private - set the source information of the receiver. "

    sourceObject := PARTSScriptSource new
        source: sourceString;
        componentDictionary: aComponentDictionary;
        part: aPart;
        yourself.!
top: topInset stretched: topStretch height: height stretched: heightStretch
    "Use topInset and height for the horizontal measurement.  topStretch
     and heightStretch are booleans indicating whether it's stretchable."

    top := topInset.
    bottom := height.
    self useTopInset;
        useBottomHeight;
        useTopStretched: topStretch;
        useBottomStretched: heightStretch!
workbenchSupportLibraries: aDictionary
        " Private - set the dictionary of workbench support library
        information for the currently installed part runtime libraries. "

    WorkbenchSupportLibraries := aDictionary.!  
right
    ^right!
fileInActivate: anObjectFiler
        "Activate instance which has just been filed in.
        Answer the activated version of the receiver.
        Bind the external references in the literal
        frame to the loading environment."

    | hasProblems loadContext |

    hasProblems := false.
    1 to: self size do: [ :index |
        ( self fileInResolveLiteralAt: index for: anObjectFiler )
            ifFalse: [ hasProblems := true ].
        ].

    hasProblems
        ifTrue: [
            loadContext := anObjectFiler clientContext.
            loadContext isPARTSLoadContext
                ifTrue: [ " loading from PARTS file "
                    loadContext owner
                        recordBrokenScript: self
                        from: anObjectFiler ]
                ifFalse: [  " pasting from clipboard "
                    "(fixScripts: reports this problem):
                    anObjectFiler recordWarningMessage:
                        'Unable to bind variables referenced in script ',
                        self selector, ' - you must edit it to fix the problem.'
                    " ].
            ].!
argumentLinkNumber: anInteger
        "Private - answer a sub link reference for the anInteger'th
        argument link."
    ^PARTSSublinkReference new
        parentReference: self;
        index: anInteger
!  
isResumable
	"Return <true> if this is a resumable exception."

    ^true! 
embeddedPartsProperty
        " Private - answer the string value of the embeddedParts
        property of the receiver. "

    | propertyString |
    propertyString := WriteStream on: String new.
    self embeddedParts
        do: [ :aFileName | propertyString nextPutAll: aFileName ]
        andBetweenDo: [ propertyString nextPutAll: ' ' ].
    ^propertyString contents!
isPARTSRectangle
        "Answer whether the receiver is a PARTS sizing rectangle. "
    ^true! 
fileName
        "Answer the name of the file containing the application."

    ^self fileDescriptor isNil
        ifTrue: [ nil ]
        ifFalse: [ self fileDescriptor fullPathName fileNameLessPath ]!   
extent
        "Answer the extent of the factory pane in LAFEditor (including non-visible area)."

    ^extent
!  
helpFile: aString
        " Specify the name of the help file which provides
        help for the receiver in a workbench or catalog. "

    wrapper helpFile: aString.!  
operation: operationName
        " Private - set the current operation "

    ( self class supportedOperations includes: operationName )
        ifFalse: [ ^self error: 'unknown mirror copy operation' ].
    operation := operationName.! 
allowBackUp
    "Answer true if backup is allowed during store time.  Default is true.
    Only repositories does not allow backup."

    ^true!  
title
        " Answer the application's title property. "

    ^self userPropertyNamed: self titlePropertyName!   
filePathName
        " Answer the full path name of the application file being processed
        (e.g., 'c:\partswb\user\myapp.par'). "

    ^filePathName!   
validate
        "Private - Build, but don't show the window."
    self buildWindow isNil ifTrue: [^nil].!  
orthogonalRange
    "Private -
        Answer an adjustment value to accomodate upgrading
        resolutions while maintiaining orthogonal appearance."
    ^( PARTSFramer basicUnit  + (199/100)) asInteger.  "Add one and round up"!   
changeSourceProperties: newLink
        " Private - change the source object or trigger of the receiver.
        Reset any argument links affected a trigger change.
        The client is responsible for updating layout (editState). "

    | oldNumEventArgs newNumEventArgs numMsgArgs
        anOldArgLink |

    source := newLink source.
    oldNumEventArgs := self numberOfEventArguments.
    trigger := newLink trigger.
    newNumEventArgs := self numberOfEventArguments.
    numMsgArgs := messageArgLinks size.

    " remove any internal arg links to dropped event arguments "
    newNumEventArgs < oldNumEventArgs
        ifTrue: [
            1 to: numMsgArgs do: [ :i |
                anOldArgLink := messageArgLinks at: i.
                ( anOldArgLink notNil
                and: [ anOldArgLink isInternalArgumentLink
                and: [ anOldArgLink selector > newNumEventArgs ] ] )
                    ifTrue: [ messageArgLinks at: i put: nil ] ] ].

    " add default wiring of new event args to empty msg arg slots "
    ( newNumEventArgs > oldNumEventArgs
    and: [ numMsgArgs > oldNumEventArgs ] )
        ifTrue: [
            ( oldNumEventArgs + 1 )
            to: ( newNumEventArgs min: numMsgArgs )
            do: [ :i |
                ( messageArgLinks at: i ) isNil
                    ifTrue: [ 
                        messageArgLinks at: i
                            put: ( PARTSLink
                                internalArgumentLinkFor: self
                               inputArgument: i 
                                messageArgument: i ) ] ].
            ].!   
addProperty: userPropertyName value: aValue
        " Private - add new user property. "

    userProperties := userProperties, (Array with:
        (Association key: userPropertyName value: aValue))!  
editState: aLinkEditState
        " Private - set the edit state information of the receiver. "

    editState := aLinkEditState.! 
fileTypeForCatalog

    "^self fileTypeFor: 'CAT'"
    ^PARTSFileType type: 'CAT' pattern: '*.CAT' description: 'Catalog (*.CAT)'! 
addComponentPoolVariablesTo: aClassModel
        "Private - add a pool variable for every component of the receiver.
        The pool being added to is necessary for scripts to be compiled
        as methods of the generated class.  It is necessary so references
        to other component parts in the scripts will compile."
    componentDictionary keysDo: [ :key |
        aClassModel
            addPoolVariableNamed: key
            inPoolNamed: self componentPoolNameForClassModel ]

!  
contents
        "Private - a no-op.  Needed for the edit contents from the
        property dialog works."!
at: aKey ifAbsentPut: aBlock
        " Answer the value for the user-defined property named <aKey>.
        If not found, set <aValue> as the value for <aKey>.  Answer the value. "

    ^self propertiesCreate at: aKey ifAbsentPut: [ aBlock value ]!  
parent: aNestedPart
    "Private - Backup the parent of the receiver.
    The location of the parent, during editing time,
    should be in the wrapper."

    self partWrapper notNil
        ifTrue: [ self partWrapper parent: aNestedPart partWrapper ].

    property parent:
        ( aNestedPart isPARTSWrapper
            ifTrue: [ aNestedPart object ]
            ifFalse: [ aNestedPart ])!  
useLeftWidth
    "Private - For the left side, use width measurement."

    mask := mask bitAnd: 2r01111111!   
insureCurrent
    "Insure that the descriptor is current with the file."!
externalEvents
        " Answer the set of events that this application can trigger "

    ^externalEvents isNil
        ifTrue: [ #() ]
        ifFalse: [ externalEvents ]!
withAllDependents
        "Answer a collection containing the receiver
        and all argument and result links that it triggers. "

    | myLinkNetwork |
    myLinkNetwork := OrderedCollection new.
    self withAllDependents: myLinkNetwork.
    ^myLinkNetwork! 
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "

    wrapper := myWrapper.
    ^super partAddUnder: parentWindow wrapper: myWrapper.!   
removePartRuntimeLibrary
        " Private - remove the basic application parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).! 
maskForStretchableCenter
    "Private - Mask for stretchable center and fixed size."

    ^2r01000100! 
open
        " Open the application by triggering its #open event. "

"    self isLaunchable
        ifFalse: [
            MessageBox
                notify: 'Cannot Launch Application'
                withText: 'You must create a link from the open event to launch this application.'.
            ^nil ]."
    ^self triggerInternalEvent: #open.!  
sharedObjects: aCollection
    "Private - set the set of shared objects.  Shared objects are
    collapsed into one object after copy to save space.
    The sharedObjects are the copies. "

    sharedObjects := aCollection.! 
< aTimestamp
        "Answer true if the receiver is less
         than aTimestamp, else answer false."

    aTimestamp isNil ifTrue: [^false].
    ^super < aTimestamp! 
attachEditInformationIn: anApplication
        "Private - attach editing information to anApplication"
    anApplication partWrapper convertLinkMessagesToPARTSLinks!   
upgradeClassRenamingFromPWO20
        " Private - answer a dictionary which provides a mapping
        of renamed classes from their PW/OS2 2.0 names into
        their PW/OS2 3.0 class name.  Classes which require
        special load mappings for nontrivial shape changes or
        for which the mapping is ambiguous are not included
        in this mapping.  Only runtime classes which are
        stored in PWO 2.0 applications are included. "

    | changedClassNames nameChangeDict |

    " mapping list of renamed classes
        Each entry is a 2-element array:
            1. class name in PW/OS2 2.0
            2. class name in PW/OS2 3.0
    "
    changedClassNames := #(

        " an application and its components "
        #( #LAFApplication #PARTSApplication )   " merged classes "
        #(# LAFEditorState #PARTSEditorState )
        #( #LAFProperty #PARTSApplicationProperty )
        #( #LAFWrapper #PARTSWrapper )
        #( #NestedPart #PARTSNestedPart )

        #( #ScaledRectangle #PARTSScaledRectangle )
            "NOTE:  PARTSScaledRectangle is used in PW 3.0 solely
             as a transient upgrade state - mutated into a PARTSFramer
            during loading "

        #( #TextIcon #PARTSTextIcon )
        #( #IconCore #PARTSUpgradeIconCore )

        #( #RGB #PARTSUpgradeRGB )

        " links "
        #( #LAFLink #PARTSLink )
        #( #LAFAliasLink #PARTSAliasLink )

        " scripts "
        " Note: The script itself was filed as a CompiledMethod by
            PWO 2.0;  it is converted to a PWO 3.0 PARTSScript
            during application upgrading.  Cannot not do blanket
            mapping of all methods by inclusion in this list,
            since that would incorrectly convert the backing
            methods used by a filed block. "
        #( #LAFScriptContext #PARTSScriptContext )
        #( #LAFScriptSource #PARTSScriptSource )
        #( #LAFScriptDictionary #PARTSScriptDictionary )

        " nonvisual parts "
        #( #PARTSPrimitive #PARTSNonvisualPart )
        #( #BtrieveAccessor #PARTSBtrieveAccessorPart )
        #( #ClipboardAccessor #PARTSClipboardAccessorPart )
        #( #ComparisonWidget #PARTSComparisonPart )
        #( #ComputationWidget #PARTSComputationPart )
        #( #ConversionWidget #PARTSConversionPart )
        #( #DDEWidget #PARTSDDE )
        #( #DDEClientWidget #PARTSDDEClientPart )
        #( #DDEServerWidget #PARTSDDEServerPart )
        #( #DiskAccessor #PARTSDiskAccessorPart )
        #( #DLLAccessor #PARTSDLLAccessorPart )
        #( #ExternalRecord #PARTSExternalRecord )
        #( #CStruct #PARTSCStructurePart )
        #( #FileAccessor #PARTSFileAccessorPart )
        #( #LaunchPad #PARTSLaunchPadPart )
        #( #LinkJunction #PARTSLinkJunctionPart )
        #( #PremadeDiag #PARTSPrebuiltDialog )
            " PWO 2.0 prebuilt dialogs are loaded
            via the abstract superclass, whose upgrader
            converts them into the correct subclass for PW 3.0 "
        #( #PrinterWidget #PARTSPrinterPart )
        #( #SpeakerWidget #PARTSSpeakerPart )
        #( #StringTemplatePart #PARTSStringTemplatePart )
        #( #TimerWidget #PARTSTimerPart )
        #( #ValueHolder #PARTSValueHolderPart )
        #( #ClassedValueHolder #PARTSTypedValueHolder )
        #( #CollectionHolder #PARTSCollectionHolder )
        #( #ArrayHolder #PARTSArrayHolderPart )
        #( #DictionaryHolder #PARTSDictionaryHolderPart )
        "New: PARTSOrderedCollectionHolderPart
            => PWO 3.0 mutates ClassedHolder on an OrderedCollection
        "
        #( #NumberHolder #PARTSNumberHolderPart )
        #( #StringHolder #PARTSStringHolderPart )

        " support classes for nonvisual parts "
        #( #StringTemplate #PARTSStringTemplate )
        #( #DLLEntryPoint #PARTSDLLEntryPoint )
        "Following two classes shouldn't be filed; listed for completeness "
        #( #DLLAccessorLibrary #PARTSDLLAccessorLibrary )
        #( #TimerAuxWindow #PARTSTimerWindow )
            " global variable TimerWindow migrated
            to PARTSTimerWindow class variable PARTSTimer "

        " Btrieve implementation classes (should not be filed; listed for completeness) "
        #( #BtrieveDLL #PARTSBtrieveDLL )
        #( #BtrieveFileSpec #PARTSBtrieveFileSpec  )
        #( #BtrieveKeySpec #PARTSBtrieveKeySpec )

        " record structures "
        #( #BtrieveKey #PARTSBtrieveKey )
        #( #ExternalDataItem #PARTSExternalDataItem )
        #( #BtrieveBoolean #PARTSBtrieveBoolean )
        #( #BtrieveDate #PARTSBtrieveDate )
        #( #BtrieveObject #PARTSBtrieveObject )
        #( #BtrieveTime #PARTSBtrieveTime )
        #( #Comp5 #PARTSComp5 )
        #( #Long #PARTSLong )
        #( #Short #PARTSShort )
        #( #CPointer #PARTSCPointer )
        #( #DoubleFloat #PARTSDoubleFloat )
        #( #PicX #PARTSFixedLengthString )
        #( #UnsignedBinary #PARTSUnsignedBinary )
        #( #ULong #PARTSULong )
        #( #UShort #PARTSUShort )
        #( #ZString #PARTSZString )

        " notebook for catalog and parts "
        #( #PARTSPage #PARTSNotebookPageAttributes )
        #( #LAFNotebook #PARTSNotebookPart )
        #( #NotebookPagePane #PARTSNotebookPagePart )

        " frame window for PWO visual parts in the workbench "
        #( #FrameWindowSubclass #PARTSFrameWindow)  " non-control subpanes "
        #( #FrameWindowForTopPane #PARTSFrameWindow)  " window parts "

        " PARTS-only visual parts "
        #( #DialPane #PARTSDialPanePart )
        "( IconPane PARTSIconPane )"  " PWO 2.0 prototype "
        #( #TablePane #PARTSUpgradeTablePane )

        " formatted entry fields "
        " Note: PWO 2.0 formatted entry fields are loaded
            via a special upgrader class to handle the drastic
            shape change encountered in PW 3.0.  The upgrader
            converts them into the correct class for PW 3.0 "
        #( #FormattedEntryField #PARTSUpgradeFormattedEntryField )
            " -> PARTSFormattedEntryField "
        #( #AlphanumericField #PARTSUpgradeFormattedEntryField )
             " -> PARTSAlphabeticEntryFieldPart or PARTSPhoneNumberEntryFieldPart "
        #( #DateField #PARTSUpgradeFormattedEntryField )
            " -> PARTSDateEntryFieldPart  (SHAPE CHANGED) "
        #( #NumericField #PARTSUpgradeFormattedEntryField )
            " -> PARTSNumericField "
        #( #CurrencyField #PARTSUpgradeFormattedEntryField )
            " -> PARTSCurrencyEntryFieldPart (SHAPE CHANGED) "
        #( #FloatField #PARTSUpgradeFormattedEntryField )
            " -> PARTSFloatEntryFieldPart "
        #( #IntegerField #PARTSUpgradeFormattedEntryField )
            " -> PARTSIntegerEntryFieldPart "
        #( #PictureField #PARTSUpgradeFormattedEntryField )
            " -> PARTSPictureFieldPart "
        "( TimeField PARTSTimeEntryFieldPart )"  " unimplemented, dropped in PARTS/Win32 2.0 "

        " PW visual part classes for base system windows.
        Responsibilities of a visual part
        PARTS<visualPartName>Part class:
            o instantiate visual part in desired state via class #new
            o define the PW workbench interface (partEvents/Messages)
            o support PW workbench property editing [direct edit]
            o support any special workbench interaction
            o implement special protocols which are incompatible
               with the base class; these should be very few
               (at least for Digitalk parts wrappering base windows)
        "
        #( #TopPane #PARTSWindowPart )
        #( #DialogTopPane #PARTSDialogWindowPart )
        #( #Button #PARTSPushButtonPart )
        #( #DrawnButton #PARTSDrawnButtonPart )
        #( #CheckBox #PARTSCheckBoxPart )
        #( #RadioButton #PARTSRadioButtonPart )
        #( #EntryField #PARTSEntryFieldPart )
        #( #TextPane #PARTSTextPanePart )
        #( #GroupBox #PARTSGroupPanePart )
        #( #ListBox #PARTSListPanePart )
       " drop-down list: ( ComboBox PARTSDropDownListPart ) "
        #( #ComboBox #PARTSComboBoxPart )
            " Note: PWO 2.0 DropDownList parts were actually
            ComboBox instances.  The base class architecture
            has been improved in 3.0 to differentiate ComboBox
            and DropDownList, which are philosophically entirely
            different, so the PWO 3.0 upgrader is responsible
            for converting DropDownList parts into the
            PWO 3.0 PARTSDropDownListPart class. "
        #( #MultipleSelectListBox #PARTSMultipleChoiceListPart )
        " PW/Win32 2.0 introduced scroll bar parts (slider substitute)
            PARTSHorizontalScrollBarPart,
            PARTSVerticalScrollBarPart
        "
        " PWO CUA control parts "
        #( #Slider #PARTSSlider )
            " Note: Upgrader in abstract superclass converts
            to correct subclass, either PARTSHorizontalSliderPart
            or PARTSVerticalSliderPart "
        #( #SpinButton #PARTSSpinButton )
            " Note: Upgrader in abstract superclass converts
            to correct subclass, either PARTSSpinButtonPart
            or PARTSSlaveSpinButtonPart "
        #( #ValueSet #PARTSValueSetPart )
        " PWO 2.0 preview part is not yet supported in PWO 3.0:
        ( #Container #PARTSContainerPart )
        "
        #( #StaticGraphic #PARTSStaticGraphicPart )
        #( #StaticText #PARTSStaticTextPart )
        #( #GraphPane #PARTSGraphPanePart )

        " menu stuff "
        #( #MenuBar #PARTSMenuBar )
        #( #MenuItemPane #PARTSMenuItemPane )
        #( #MenuItemBitmap #PARTSMenuBitmapItemPart )
        #( #MenuItemSeparator #PARTSMenuSeparatorPart )
        #( #MenuItemText #PARTSMenuTextItemPart )
        #( #MenuLabel #PARTSMenuLabelPart )
        #( #MenuListPane #PARTSMenuPart )

        " miscellaneous support classes for visual parts "
        #( #Dial #PARTSDial )

        " PremadeDiag parts redone drastically; need to extract values from old dialogs "
        #( #FileDialog #PARTSUpgradeFileDialog )
        #( #OneButtonMessageBox #PARTSUpgradeInfoDialog )
        #( #TwoButtonMessageBox #PARTSUpgradeConfirmerDialog )
        #( #ThreeButtonMessageBox #PARTSUpgradeConfirmerWithCancelDialog )
        #( #PARTSPrompter #PARTSUpgradePrompter )

        " TablePane support classes (editing classes should not
        be filed; listed for completeness "
        #( #TableCellEditor #PARTSTableCellEditor )
        #( #CellEntryField #PARTSCellEntryField )
        #( #CellNumberField #PARTSCellNumberField )
        #( #TableLabelEditor #PARTSTableLabelEditor )
        #( #CellIconHolder #PARTSCellIconHolder )
        #( #TableSelection #PARTSTableSelection )
        #( #EncompassingSelection #PARTSEncompassingSelection )
        #( #RectangleSelection #PARTSRectangleSelection )
        #( #RowsOrColumnsSelection #PARTSRowsOrColumnsSelection )
        #( #ColumnsSelection #PARTSColumnsSelection )
        #( #RowsSelection #PARTSRowsSelection )

        " miscellaneous facilities (listed for completeness) "
        #( #PlainTextWindow #PARTSTextWindow )
        #( #SeparatedListPane #ExtendedListBox )

        ).

    nameChangeDict := Dictionary new.
    changedClassNames do: [ :array |
        nameChangeDict
            at: ( array at: 1 )    " old name "
            put: ( array at: 2 ) ].   " new name "
    ^nameChangeDict!   
openBinaryFileReadOnly: aFileName ifNone: aBlock
    "Private - Answer a ReadOnly filestream on aFileName
    in the first directory on the PARTS search path
    containing it. "
    | aDirectory |

    aDirectory := self directoryContaining: aFileName
        ifNone: [ ^aBlock value ].
    ^( File fromPath: aFileName in: aDirectory ) binaryReadStream
"    ^aDirectory fileReadOnly: aFileName"! 
asString
    ^self fullPathName! 
loadForExecuteWithDebugger: aDebugger
    "Load the part described by the receiver to be executed.
    <loadContext> can specify a debugger."

    ^self loadForExecuteWithContext:
        ( PARTSLoadContext new
            fileDescriptor: self;
            debugger: aDebugger;
            yourself )! 
dataSlotCharacter
        " Private - answer the placeholder character used
        to render an argument value position in a link
        label string for an event or message. "

    ^self
        partsIfOS2Do: [ 7 asCharacter ]
        partsIfWindowsDo: [ $* ]!
eventTable: anEventTable
        "Private - set the table of event handlers for the receiver.
        These events actually belong to the application's editor. "
    eventTable := ( anEventTable size = 0
        ifTrue: [ nil ]
        ifFalse: [ anEventTable ] ).!
parent
    "Private - Answer the parent of the receiver.  It is
    either a nested part or nil."
    | parent |

    ^( self isEditable and: [ self partWrapper notNil ])
        ifTrue: [
            ( parent := self partWrapper parent ) notNil
                ifTrue: [ parent object ]
                ifFalse: [ nil ]]
        ifFalse: [ property parent ]! 
addLinksAttachedTo: aPart to: aSet
        " Add the receiver or any dependent links that it
        triggers to <aSet> if the link is triggered by or 
        sends a message to <aPart>. "

    ( self isAttachedTo: aPart )
        ifTrue: [ aSet add: self ].
    self dependentLinks do: [ :aLink |
        aLink addLinksAttachedTo: aPart to: aSet ].!   
newWithName: aName
        " Answer a new PARTS application named aName. "

    ^super new initializeWithName: aName.! 
constructCurrentVersion
        " Private - answer the version string used for editable
        part files with the current system object file format "

    ^self
        partsIfOS2Do:  [ 'PARTS/OS2 3.1 (editable)' ]
        partsIfWindowsDo: [ 'PARTS/Win32 3.1 (editable)' ]!
fromFileOrEditor: aFileReference in: aDirectory
        " Answer the most current version of the
        application in aFileName in aDirectory. "

    ( PARTSFile exists: aFileReference in: aDirectory )
        ifFalse: [ ^nil ].
    ^self
        fromFileOrEditor: aFileReference
        in: aDirectory
        debugger: nil!  
refersTo: anObject ignoreMessages: messagesToIgnore
        " Answer whether the receiver or any links that
        it triggers sends a message to <anObject>
        other than those in <messagesToIgnore>. "

    ( self destinationObject == anObject
    and: [ ( messagesToIgnore includes: selector ) not ] )
        ifTrue: [ ^true ].
    self dependentLinks do: [ :aLink |
        ( aLink refersTo: anObject ignoreMessages: messagesToIgnore )
            ifTrue: [ ^true ].
        ].
    ^false!
constructUpgradeChangeMaps
        " Private - construct the upgrade change maps
        for loading name and structure changes.
        The upgradeChangeMaps is a dictionary indexed by
        the version number of a filed version which can be
        loaded by the current version. "

    | changeMapsDictionary upgradeMappings |
    changeMapsDictionary := Dictionary new.
    self
        partsIfOS2Do: [
            changeMapsDictionary
                at: 'LAF/VPM 2.0a'    " PARTS 2.0 for OS/2 "
                put: self upgradeMapsForLoadingPWO20.
            " include support for internal 3.0 pre-beta3 app upgrading "
            upgradeMappings := self upgradeMapsForLoadingPWO30preBeta3.
            #(
                'PARTS/OS2 3.0 (preliminary #3)'  " ObjectLoader/Dumper .EXE, .PAX "
                'PARTS/OS2 3.0 (preliminary #2)'  " ObjectFiler .PAR "
                ) do: [ :versionString |
                    changeMapsDictionary at: versionString put: upgradeMappings ].
            upgradeMappings := self upgradeMapsForLoadingPWO30.
            #(
                'PARTS/OS2 3.0.1 (editable)'  "PARTS Workbench 3.0.1  for Win32 "
                'PARTS/OS2 3.0 (editable)'   "PARTS Workbench 3.0  for Win32 "
                ) do: [ :versionString |
                    changeMapsDictionary at: versionString put: upgradeMappings ].
            ]
        partsIfWindowsDo: [
            upgradeMappings := self upgradeMapsForLoadingPWW30.
            #(
                'PARTS/Win32 3.0.1 (editable)'  "PARTS Workbench 3.0.1  for Win32 "
                'PARTS/Win32 3.0 (editable)'   "PARTS Workbench 3.0  for Win32 "
                ) do: [ :versionString |
                    changeMapsDictionary at: versionString put: upgradeMappings ].
            upgradeMappings := self upgradeMapsForLoadingPWW20.
            changeMapsDictionary
                at: 'PARTS/Win32 2.0'   "PARTS Workbench 2.0 for Win32 "
                put: upgradeMappings.
            " include support to upgrade PWW 2.0 beta apps (PWW 2.0 partdemo apps) "
            changeMapsDictionary
                at: 'LAF/VW 1.0a'    "PARTS Workbench 2.0 for Win32 beta 1 "
                put: upgradeMappings.
            " include support for  internal 3.0 pre-beta3 app upgrading "
            upgradeMappings := self upgradeMapsForLoadingPWW30preBeta3.
            #(
                'PARTS/Win32 3.0 (preliminary #2)'  " ObjectLoader/Dumper .EXE, .PAX "
                'PARTS/Win32 3.0 (preliminary #1)'  " ObjectFiler .PAR "
                ) do: [ :versionString |
                    changeMapsDictionary at: versionString put: upgradeMappings ].
            ].
    ^changeMapsDictionary! 
removeExternalEvent: aSymbol
        " Remove the event named <aSymbol> from the external interface
        of this application. "

    externalEvents := externalEvents asOrderedCollection
        remove: aSymbol;
        yourself.
    externalEvents := ( externalEvents isEmpty
        ifTrue: [ nil ]
        ifFalse: [ externalEvents asArray ] ).!   
initialize
        " Private - initialize a new link. "

    | numMsgArgs |

    traceFire := false.
    editState := PARTSLinkEditState new.

    " set up message argument collection links "
    ( self isInternalArgumentLink 
    or: [ ( numMsgArgs := Message numberOfArgumentsFor: selector ) = 0 ] )
        ifTrue: [ ^self ].
    messageArgLinks := Array new: numMsgArgs.
    " install default wiring to pass through any input args "
    1 to: ( self numberOfEventArguments min: numMsgArgs ) do: [ :i |
        messageArgLinks 
            at: i
            put: ( PARTSLink
                internalArgumentLinkFor: self
                inputArgument: i messageArgument: i ) ].!  
partHasOtherEvents
        " Answer whether the receiver can be asked
        for events other than what it has already
        provided in its partEvents. "

    ^false!   
evaluateWithArguments: evaluationArguments
        "Answer the result of firing the receiver with
        the given evaluation arguments."

    | result |
    self isInternalArgumentLink
        ifTrue: [ ^evaluationArguments at: selector ].
    result := self fireSelfWith:
        ( self collectArguments: evaluationArguments ).
    resultLink notNil
        ifTrue: [ result := resultLink evaluateWithArguments: ( Array with: result ) ].
    ^result!  
helpAndHintFromPathName: aPathName
        " Answer the help and hint info stored in aPathName
        as an array of strings (help file name, help topic, hint). "

    | aFileStream hhArray |
    ( aPathName isNil or: [ ( PARTSFile exists: aPathName ) not ] )
        ifTrue: [ ^PARTSFileNotFound signalForFile: aPathName ].
    aFileStream := ( PARTSFileDescriptor pathName: aPathName )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ hhArray := self helpAndHintFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^hhArray! 
isEditable
        " Answer whether the receiver can be edited
        in a workbench (has edit information available). "

    ^property executionState = 'editable'! 
bottom: bottomInset stretched: bottomStretch height: height stretched: heightStretch
    "Use bottomInset and height for the horizontal measurement.  bottomStretch
     and heightStretch are booleans indicating whether it's stretchable."

    top := height.
    bottom := bottomInset.
    self useTopHeight;
        useBottomInset;
        useTopStretched: heightStretch;
        useBottomStretched: bottomStretch!   
debugger
        " Private - specify the PARTS debugger
        which will be debugging the copy. "

    ^debugger!   
useTopHeight
    "Private - For the top side, use height measurement."

    mask := mask bitAnd: 2r11110111!   
trigger: triggerSymbolOrIndex
        "Private - set the trigger event for the receiver.  May be
        either a symbol identifying a component event or the
        integer index of a message argument which fires this
        argument collection link to obtain its value."

    trigger := triggerSymbolOrIndex.!
defaultText
    "Private"

    ^self filePathName, ' does not contain an editable PARTS application.'! 
unrelativeTo: extent
        "Private - Answer a new self by turning
         proportional ratios to non-ratios."
    | width height |
    width := self pixelToScaleUnitHorizontal: extent x.
    height := self pixelToScaleUnitVertical: extent y.
    ^self class new
        scaleUnit: scaleUnit;
        left:
            ( self isLeftStretched
                ifTrue: [(left * width) "+ aRect left"]
                ifFalse: [left])
        bottom:
            ( self isBottomStretched
                ifTrue: [(bottom * height) "rounded + aRect origin y"]
                ifFalse: [bottom])
        right:
            ( self isRightStretched
                ifTrue: [(right * width) "rounded"]
                ifFalse: [right])
        top:
            ( self isTopStretched
                ifTrue: [(top * height) "rounded"]
                ifFalse: [top]);

        scaleMask: mask!   
partSetGraphics: anIcon
        " Private - update the receiver's icon. "
    | oldIcon parent  |

    oldIcon := self partIcon.
    parent := oldIcon parent.
    anIcon
        parent: parent;
        origin: oldIcon origin copy;
        connection: oldIcon connection;
        showLabel: oldIcon showLabel;
        label: oldIcon label.
    parent notNil ifTrue: [
        parent removeIcon: oldIcon; addIcon: anIcon].
    oldIcon release.
    self partIcon: anIcon.
    anIcon parent invalidateRect: anIcon partFrame!  
fromExeFile: aFileName
        "Answer the application stored in the .exe format file
        named aFileName on the PARTS search path.  Retained
        for backward compatibility.  The real parts application is
        contained in the .pax file."
    | dir fileName |

    fileName := aFileName fileExtension asLowerCase = 'exe'
        ifTrue: [
            aFileName fileName, '.',
                PARTSFileDescriptor fileTypeForExecutablePart type ]
        ifFalse: [ aFileName ].
    ( dir := PARTSFile directoryContaining: fileName ) isNil
        ifTrue: [ ^nil ].

    ^self
        fromFile: fileName
        in: dir!
externalEvents: anArray
        " Private - set the external events list. "

    externalEvents := anArray.!   
fromLocator: aFileSystemLocator
    "Private - private instance creation method used primarily by FileSystemLocators to
        create instances of the appropriate FileSystemEntity subclass."
    | dir absoluteLocator |

	absoluteLocator :=  aFileSystemLocator absolutePath.
    self subclasses do: [ :aDirSubClass |
        ( dir := aDirSubClass fromLocator: absoluteLocator ) notNil
            ifTrue: [ ^dir ]].

    ^self basicFromLocator: absoluteLocator!   
defaultFileName
        " Answer the default PARTS initialization file name. "
    ^'parts.ini'!
new
        " Answer a new PARTS application. "

    ^self newWithName: self defaultName!  
pixelToScaleUnitVertical: pixels
    ^self class pixelVertical: pixels toScaleUnit: scaleUnit
! 
title
        " Answer the application title. "

    ^property title!  
canBeLoaded
		" Answer whether this version can be loaded
		by the current system. "

	^canBeLoaded!  
descriptionOfLeft
        "Answer a String describing the calculation of the left."
    | stream |
    stream := WriteStream on: String new.
    stream
        nextPutAll: 'left: ';
        nextPutAll:
            (self isLeftInset
                ifTrue: [ 'right of parent''s left by ']
                ifFalse: [ 'left of window right by '] );
        nextPutAll: left printString;
        nextPutAll:
            (self isLeftStretched
                ifTrue: [ ' of parent''s width']
                ifFalse: [ ' ', self scaleUnitPlural ] ).
    ^stream contents!
isDirectoryInPath: aDirectory
        "Answer whether aDirectory is in the PARTS
        directory search path. "

    | drivePathName |
    drivePathName := aDirectory drivePathName.
    ^( self currentSearchPath detect: [ :aDir |
        aDir drivePathName equalsIgnoreCase: drivePathName ]
        ifNone: [ nil ] )
            notNil!   
partEvents
        " Answer the PARTS event interface of the receiver. "

    | items interfaceList |
    items := self externalMessages asSortedCollection asArray.
    interfaceList := PARTSInterfaceList new
        items: items.
    items notEmpty
        ifTrue: [
            interfaceList defaultItem: ( ( items includes: #open )
                ifTrue: [ #open ]
                ifFalse: [ items first ] ) ].
    ^interfaceList!
unbindAll
        "Private - maintainance."
    self allSubclasses do: [ :subclass | subclass unbind ]! 
defaultFileName
        " Answer the default file name of an application. "

    ^'Untitled.par'!  
virtualScreenExtent
        "Private - Answer the virtual screen extent of the editor pane in LAFEditor."

    ^extent!
removeExternalMessage: aSymbol
        " Remove the external message selector <aSymbol> from 
        the external interface of this application. "

    externalMessages := externalMessages asOrderedCollection
        remove: aSymbol;
        yourself.
    externalMessages := ( externalMessages isEmpty
        ifTrue: [ nil ]
        ifFalse: [ externalMessages asArray ] ).!
runtimeCloneSkeleton
        " Private "

    ^self class basicNew
        realSelector: realSelector;
        yourself! 
isWorkbenchStandaloneSession
        " Answer whether this is a standalone PARTS Workbench session. "

    ^self isWorkbenchSession and: [ SessionModel current isRunTime ]!   
loadApplication
        "Private - Load the application if not loaded yet."
    | resolvedFileDescriptor |
    resolvedFileDescriptor := self resolvedFileDescriptor: self fileDescriptor.
    application isNil ifTrue: [
        resolvedFileDescriptor isNil
            ifTrue: [^nil]  " not connected to anything "
            ifFalse: [
                [ application := PARTSFileDescriptor
                        nestedPartFromFileOrEditor: resolvedFileDescriptor
                        debugger:
                            ( self partApplication notNil
                                ifTrue: [ self partApplication partDebugger ]
                                ifFalse: [ nil ])
                     useSearchPath: true ]
                    on: PARTSApplicationLoadError
                    do: [ :e |
                        e postMessageBox: 'Part Accessor Load Error'.
                        ^nil ].
                application isNil
                    ifTrue: [ ^nil ]  "Backstop: should raise error"
                    ifFalse: [
                        "self fileDescriptor: application fileDescriptor."
                        self triggerEvent: #loaded]]].
    "application partWrapper parent: wrapper."
    self partIsEditing
        ifFalse: [self partEnableExecution].
    ^application!
partWrapper
        " Answer the PARTS wrapper of the receiver. "
    ^wrapper! 
fromPathName: aPathName
        "Answer the application stored in aPathName. "

    ^self fromPathName: aPathName debugger: nil!   
linkReference
        "Private - answer a reference to the receiver."
    ^PARTSLinkReference for: self!
filePathName
        "Answer the full path name of the application part file."
    ^self fileDescriptor isNil
        ifTrue: [ '' ]
        ifFalse: [ self fileDescriptor fullPathName ]!   
> aTimestamp
        "Answer true if the receiver is greater
         than aTimestamp, else answer false."

    aTimestamp isNil ifTrue: [^false].
    ^super > aTimestamp!  
usesSelectorIn: aCollectionOfSelectors
        " Private - to support protocol upgrades. "

    ^( aCollectionOfSelectors includes: selector )!
writerClass: aSymbol
		" Specify the name of the class which
		can write the application in this file version. "

	writerClass := aSymbol.!   
resolvedFileDescriptor: aFileDescriptor
        "Private - Answer a file descriptor.  
		If aFileDescriptor contains no type and the file name does
		not have an extension, first look for a .PAR type with no 
		extension, then look for a .PAR type with extension .PAR.
		At last, look for a .PAX type with .PAX extension.
		Answer nil if no actual file is matched."
	aFileDescriptor isNil ifTrue: [^nil].
    ^aFileDescriptor fileType trimBlanks isEmpty
        ifTrue: [
			aFileDescriptor resolveExtensionWith:
				( Array 
					with: PARTSFileDescriptor fileTypeForPart  
					with: PARTSFileDescriptor fileTypeForExecutablePart )]
		ifFalse: [aFileDescriptor]!
isLinked
    "Private - Treat the receiver as linked, since it
    is always in sync with the file."
	^true!   
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  When aSelector is an external
        message of the nested application, map it to the
        relay method which triggers an internal event
        in the nested guy. "

    ^( self isApplicationMessage: aSelector )
        ifTrue: [ #relayLink:arguments: ]
        ifFalse: [ aSelector ]!  
executionState
        " Answer the application's execution state property.
        Execution states are 'editable', 'executable', and 'debuggable'. "

    ^self userPropertyNamed: self executionStatePropertyName
       ifAbsent: [ 'editable' ]!
children: aCollection
        " Set the application's children property.
    The children are the top level components of
    an application.  For an editable application this
    information is located in the wrapper."

    self propertyAt: #children put: aCollection!   
tickDelayed: aPart
        " Private - notify aPart that its tick has occured. "
    aPart tick.!   
fileTypeDescriptionFor: aFileType
        " Answer the descriptive name of <aFileType>. "

    | fileTypeDescriptions |
    fileTypeDescriptions := Dictionary new
        " part file types "
        at: 'PAR' put: 'Part (*.PAR)';
        at: 'PAX' put: 'Executable part (*.PAX)';
        at: 'CLS' put: 'Part source (*.CLS)';
        at: 'EXE' put: 'Executable (*.EXE)';
        " other file types "
        at: 'BMP' put: 'Bitmap (*.BMP)';
        at: 'CAT' put: 'Catalog (*.CAT)';
        yourself.
    ^fileTypeDescriptions at: aFileType asUpperCase
        ifAbsent: [ '(unknown file type)' ]!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    ( copy respondsTo: #realSelector: )
        ifTrue: [ copy realSelector: realSelector ].
    ^copy!
setSearchPath: aCollectionOfDirectories
        " Specify the PARTS search path. "

    DirectorySearchPath := ( aCollectionOfDirectories isNil
        ifTrue: [ nil ]
        ifFalse: [ aCollectionOfDirectories collect: [ :d | d asPARTSDirectory ] ] ).!   
properties: aDict
        "Private - Set the properties."

    properties := aDict!
notEmpty
        "Answer whether the receiver contains any items. "

    ^self items size > 0! 
componentDictionary
        " Private - answer the component dictionary. "

    ^componentDictionary!  
removeClass: aClassName
	"Dynamically unregister a file processor with the receiver"

    self fileTypeRegistry remove: aClassName asString!   
partAsExecutableAction
        " Private - answer the receiver as an action for an executable
        PARTS application. "

    | aMessage |
    aMessage := super partAsExecutableAction.
    selector = realSelector
        ifFalse: [ aMessage realSelector: realSelector ].
    ^aMessage!   
useAllFixed
    "Private - Make all sides fixed."

    mask := mask bitAnd: 2r10101010!
printOn: aStream
        "Append a text representation of the receiver to <aStream>. "

    | containingApplication |
    ( source isNil
    or: [ ( containingApplication := self application ) isNil ] )
        ifTrue: [ ^super printOn: aStream ].
    aStream nextPutAll: self class name,
        ' ( ', ( self descriptionIn: containingApplication ), ' )'!  
cleanUp
	"The receiver is being removed from
	the Workbench environment"!   
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self hasExternalEvent: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [ super partLinkClassFor: aSelector ]!   
isPARTSApplication
        "Answer whether the receiver is a PARTS application. "

    ^true!  
catalogFileTypes

    ^Array
        with: self fileTypeForCatalog
        with: self fileTypeForAll! 
versionPropertyFrom: aFileStreamOrProperties
        " Answer the version info stored in aFileStream
        as an array of strings. "

    ( aFileStreamOrProperties isStream and: [ aFileStreamOrProperties size = 0 ])
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStreamOrProperties file pathName.
            ^nil ].
    ^self fileAccessorClass new versionPropertyFrom: aFileStreamOrProperties!
addArgumentLink: aLink
        "Private - add aLink as an argument link of the receiver."
    messageArgLinks at: aLink trigger put: aLink.
    aLink source: self!
useTopInset
    "Private - For the top side, use
      inset measurement."

    mask := mask bitOr: 2r00001000!   
unbindWorkbenchSupportLibrary: aLibraryName
        " Private - unbind the workbench support library named <aLibraryName>
        if it has been installed in the system. "

    | info aLibrary |
    aLibraryName isNil
        ifTrue: [ ^self ].
     info := self workbenchSupportLibraries at: aLibraryName ifAbsent: [ nil ].
    ( info notNil
    and: [ ( info at: 2 )  "isBound"
    and: [ (  aLibrary := SmalltalkLibrary named: aLibraryName ) notNil ] ] )
        ifTrue: [
            aLibrary unBind.
            info at: 2 put: false ].!   
printOn: aStream
        " Private - append a description of the receiver to <aStream>. "

    super printOn: aStream.
    versionString notNil
        ifTrue: [ aStream nextPutAll: ' (', versionString printString, ')' ].!   
propertiesFromPARStream: aFileStream
        "Private - Answer the properties stored on aFileStream. "
    ^self fileAccessorClass new propertiesFromPARStream: aFileStream
!  
upgradeMapsForLoadingPWW30preBeta3
        " Private - answer the upgrade load maps for
        structure changes in the current version. "

    | changeMaps |

    changeMaps := OrderedCollection new.

    " EntryField 'maxSize' -> #textLimit property "
    ( Smalltalk at: #PARTSEntryFieldPart ) withAllSubclasses do: [ :aClass |
        changeMaps add: ( ( ObjectChangeMap forClassName: aClass name )
            put: 'maxSize' into: 'topCorner';  " upgrader must fix "
            yourself ) ].

    " TextEdit 'readonly' -> style bits "
    changeMaps add: ( ( ObjectChangeMap forClassName: #PARTSTextPanePart )
        put: 'maxSize' into: 'topCorner';  " upgrader must fix "
        put: 'readonly' into: 'handle';  " upgrader must fix "
        yourself ).

    #(
        " ListBox dropped bmaps, itemBeingDrawn in 10/19 beta 3 "
        #PARTSListPanePart
        #PARTSDropDownListPart
        #PARTSComboBoxPart
        #PARTSMultipleChoiceListPart
        " VW Printer added 'name' in 10/19 beta 3 "
        #Printer
        ) do: [ :classSymbol |
            changeMaps add: ( ObjectChangeMap forClassName: classSymbol ) ].

    " renamed workbench class (should not be filed, but possibly got stored
        via embedded nested part) [DJL 17-Nov-94] "
    changeMaps add: ( ObjectChangeMap
        forClassName: #PARTSMenuPane
        destinationClassName: #PARTSMenuPaneWindows ).

    #(
		#PARTSTableCellEditor
		#PARTSTableCellTextEditor
		#PARTSTableCellExtendedTextEditor
		#PARTSTableLabelEditor
		#PARTSTableColumnLabelEditor
		#PARTSTableCornerLabelEditor
		#PARTSTableRowLabelEditor ) do: [ :classSymbol |
            changeMaps add: ( ObjectChangeMap forClassName: classSymbol ) ].

    ^changeMaps!  
new
        " Answer a MirrorCopy dictionary for making
        an editable copy. "

    ^self for: #copy!
bindWorkbenchSupportLibrary: aLibraryName for: partDescription
        " Private - bind the library named <aLibraryName> to install the
        workbench support for the part or part set described by
        the string <partDescription>. "

    ^self
        bindLibrary: aLibraryName
        errorTitle: partDescription, ' Installation Problem'
        neededFor: 'the ', partDescription, ' workbench support'!   
eventTable: anEventTable
        " Private - for mirrorCopy only "
    eventTable := anEventTable.! 
partEditor: anEditor
        " Private - specify the PARTS editor operating on the receiver. "

    editor := anEditor.!   
iconFromPARStream: aFileStream
        "Private - Answer the icon stored on aFileStream.   The client must set the
        file name of the icon connection. "
    ^self fileAccessorClass new iconFromPARStream: aFileStream
!   
isRightInset
    "Private - Answer true if the right measurement is inset
     and false if it is height."

    ^(mask bitAnd: 2r00100000) > 0!   
defaultUserProperties
        " Private - these are infrequently used, so
        prefer compact representation over fast access. "

    | partsSettings |
    partsSettings := Smalltalk at: #PARTSSettings ifAbsent: [ nil ].
    ^Array
        with: ( Association
            key: self manufacturerPropertyName
            value: ( partsSettings isNil
                ifTrue: [ 'Anonymous' ]
                ifFalse: [ partsSettings current userName ] ) )
        with: ( Association
            key: self titlePropertyName
            value: 'Untitled' )
        with: ( Association
            key: self versionPropertyName
            value: '1.0' )! 
referencesResultLink
        "Private - answer true if the link the receiver refers to is a result link."
    ^index = 0
! 
fileType
    ^fileType!  
emptyList
        " Answer an empty interface list "

    ^self new items: #()!
parentReference: aLinkReference
        "Private - set the receiver's parent reference."
    parentReference := aLinkReference
!   
componentScriptsFor: aComponent
    "Private - Answer the scripts for <aComponent>"

    ^self partIsEditing
        ifTrue: [
            aComponent partWrapper scriptDictionary ]
        ifFalse: [
            self componentScripts
                at: aComponent
                ifAbsent: [ PARTSScriptDictionary new ]]!   
releaseLibraries
		" Private - release any libraries which were bound
		when the receiver was loaded. "

	self libraryDependencies do: [ :aLibraryName |
		SmalltalkLibraryBinder unBind: aLibraryName ].
	self libraryDependencies: nil.!  
iconFromFile: aFileReference in: aDirectory
        " Answer the icon stored in aFileReference in aDirectory. "

    | aFileStream anIcon fileDescriptor |
    fileDescriptor :=
        ( aFileReference isString not
        and: [ aFileReference directory = aDirectory ] )
            ifTrue: [ aFileReference ]
            ifFalse: [ PARTSFileDescriptor fileName: aFileReference in: aDirectory ].
    aFileStream := fileDescriptor asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [[ anIcon := self iconFrom: aFileStream ]
        ensure: [ aFileStream close ]]
            on: PARTSNotOnSearchPath
            do: [ :e | anIcon := nil ].
    anIcon isNil ifTrue: [ "if nil possibly .CLS file, make sure we always answer an icon."
        anIcon := PARTSApplication defaultIcon ].
    anIcon connectionPrivate notNil
        ifTrue: [
            "If repository entity, the stream's file is a temp file.
                Use the repository entity name instead."
            anIcon connectionPrivate fileReference: fileDescriptor ].
    ^anIcon!
debugger
        " Private - answer the PARTS link debugger
        operating on the receiver's application. "

    ^nil! 
for: aLink
        "Private - answer a reference for aLink."
    ^aLink isEventLink
        ifTrue: [ PARTSLinkReference new link: aLink ]
        ifFalse: [ PARTSSublinkReference new link: aLink ]!
equalPaths: aFileReference
        " Answer whether the aFileReference has the same absolute pathname
        as the receiver. "

    | path |

    path := aFileReference isString
        ifTrue: [ aFileReference ]
        ifFalse: [ aFileReference fullPathName ].
    ^self fullPathName equalsIgnoreCase: path.! 
isArgumentLink
        " Answer whether the receiver is an argument link
        which is fired by another link to collect the value 
        for the triggering link's trigger-th message argument. "

    ^trigger isInteger!  
upgradeMapsDictionary: aDictionary
        " Private "

    UpgradeChangeMapsDictionary := aDictionary.!   
resultAction: anAction
        "Specify the action which is evaluated with the
        result of the receiver when it has been evaluated.
        For polymorphism with Message."

    self resultLink: anAction.!   
readerClass: aSymbol
		" Specify the name of the class which
		can read the application in this file version. "

	readerClass := aSymbol.!
isPARTSRuntimeSession
        " Answer whether this is a PARTS application runtime session. 
        A PARTS runtime session is a PARTS application executing 
        without the PARTS Workbench being present."

    ^self isWorkbenchSession not!
applicationFromPathName: aPathName
        " Answer the PARTS application stored in the file
        named aPathName.  The application is in editable form
        and has not yet been enabled for execution."

    ^( PARTSFileDescriptor pathName: aPathName )
        loadForEdit!  
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
orderedChildren: anOrderedCollection
        "Set the OrderedCollection which is the
        ordering of the children for tab and arrow keys."

    self propertyAt: #PARTSOrderedChildren put: anOrderedCollection asOrderedCollection.! 
fileDescriptor: aFileDescriptor
        "Private - specify the descriptor of the file containing the application."

    property fileDescriptor: aFileDescriptor.! 
keywordsIn: aSelector
        " Private - answer aSelector as an array of keywords. "

    | keywords stream start aKeyword |
    keywords := OrderedCollection new.
    stream := ReadStream on: aSelector.
    [ stream atEnd ] whileFalse: [
        start := stream position + 1.
        stream skipTo: $:.
        aKeyword := stream copyFrom: start to: stream position.
        keywords add: aKeyword ].
    ^keywords asArray!  
realSelector
    "Private - Answer the 2-argument message selector to
        really send to the destination object when the receiver is fired. "
    ^realSelector!   
setGraphics: anIcon
		"Private - Retained for backward compatibility.  
		Use partSetGraphics instead."
	^self partSetGraphics: anIcon!
manufacturerPropertyFrom: aFileStreamOrProperties
        " Answer the manufacturer property of the application."

    ( aFileStreamOrProperties isStream and: [ aFileStreamOrProperties size = 0 ])
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStreamOrProperties file pathName.
            ^nil ].
    ^self fileAccessorClass new manufacturerPropertyFrom: aFileStreamOrProperties! 
propertyAt: key
        "Private - Answer the value associated with key
        in the properties dictionary."

    ^property propertyAt: key!
partEditorEventManager
        " Answer the receiver's event manager with
        which workbench events are registered. "

    ^self partIsEditing
        ifTrue: [ self partEditor ]
        ifFalse: [ self editorState ]!  
unorderedChildren
        "Private - Answer an OrderedCollection which contain
        the children missing in orderedChildren."

    | unorderedChildren orderedChildren  child |
    unorderedChildren := OrderedCollection new.
    orderedChildren := self orderedChildren.
    self children do: [ :aChild |
        child := aChild isPARTSWrapper
            ifTrue: [ aChild object ]
            ifFalse: [ aChild ].
        ( orderedChildren includes: child )
            ifFalse: [ unorderedChildren add: child ] ].
    ^unorderedChildren! 
frameRectangle
        " Answer the PARTSFramer for the editor top pane "

    ^frameRectangle!
prepareToStoreApplication: anApplication
        " Private - put <anApplication> into the appropriate state
        to be stored in a file. "

    anApplication isPARTSApplication
        ifTrue: [
            anApplication components do: [ :aComponent |
                ( aComponent isPARTSNestedPart
                    or: [ aComponent isPARTSPartAccessorPart ])
                    ifTrue: [
                        aComponent prepareToStoreInApplication: anApplication ]]].
    ^super prepareToStoreApplication: anApplication!
icon: anIcon
        " Specify the application icon. "

    property icon: anIcon! 
canExecute
	"Answer whether the application represented by the
	receiver can exist in executable form"

    ^true!
userPropertyNamed: propertyNameString value: propertyValueString
        " Set the value of the user-defined property named <propertyNameString>
        to the value <propertyValueString>.  A property value must be 
        a String (or nil). "

    ^property userPropertyNamed: propertyNameString asString put: propertyValueString! 
message: message
        "Private - If message is dynamic message, find the real selector and
        and perform it.  If it is indeed a message which is not understood, signal
        MessageNotUnderstood."
    | selector realSelector receiver |
    " alias link message backstop (sent from script) "
    selector := message selector.
    receiver := message receiver.
    realSelector := receiver partRealSelectorFor: selector.
    realSelector ~= selector
        ifTrue: [ " alias message "
            ^receiver
                perform: realSelector
                withArguments: ( Array
                    with: selector
                    with: message arguments ) ].
    ^MessageNotUnderstood message: message! 
basicUnit
    "Private - Answer a basic unit in pixels.  Determined
    by the size of one pixel in twips on a VGA 640x480 mapped to
    the current display."

    ^self scaleUnit: #twip toPixelHorizontal: 15!
fileProcessor
    "Answer a file processor for the receiver's file type."

    ^PARTSFileProcessor getProcessorFor: self!  
resultLink: aLink
        " Private - set the result link of the receiver to <aLink>. "

    "self ASSERT: ( aLink isResultLink and: [ aLink source == self ])."
    resultLink notNil ifTrue: [ resultLink source: self ].
    resultLink := aLink! 
workbenchLibrariesOrdered
		" Private - answer the names of the workbench support libraries
		in the order in which they were registered. "

	| orderedNames |
	orderedNames := Array new: self workbenchSupportLibraryIndex.
	self workbenchSupportLibraries associationsDo: [ :assoc |
		orderedNames
			at: ( assoc value at: 3 )  " registration order index "
			put: assoc key ].
	^orderedNames! 
COMMENT
"PARTSFileDescriptor

This class provides consistent protocol for accessing external file systems like DOS file system, or Team/V repositories.
A separate subclass should be implemented for each file system. "!
openOn: anObject
        " Open the application by triggering its #openOn: event. "

"    self isLaunchable
        ifFalse: [
            MessageBox
                notify: 'Cannot Launch Application'
                withText: 'You must create a link from the open event to launch this application.'.
            ^nil ]."

    ^self triggerInternalEvent: #openOn:
        withArguments: ( Array with: anObject )!  
scriptPart: aPart
       " Private - set the part to which this script belongs. "

    sourceObject part: aPart.!  
canBeDescribed
		" Answer whether this version can be described
		by the current system. "

	^canBeDescribed! 
scaleUnitsSupported
    "Private"
    ^ #( #twip #inch #centimeter #pixel )
!  
installWorkbenchSupportLibrary: aLibraryName for: partDescription
        " Bind the library named <aLibraryName> to install the
        workbench support for the part or part set described by
        the string <partDescription>. "

   | isBound |
    aLibraryName isNil
        ifTrue: [ ^nil ].  " filing in or loading package, not installing library "
    isBound := ( self isWorkbenchSession
        ifTrue: [
           self bindWorkbenchSupportLibrary: aLibraryName
			for: partDescription ]
        ifFalse: [ false ] ).
    self
		registerWorkbenchSupportLibrary: aLibraryName
		for: partDescription
		isBound: isBound.! 
icon
        " Answer the application's icon property. "

    ^icon!   
helpFile: helpFileName helpTopic: helpTopicName
        " Specify the file name and topic name for the receiver's 
		context-sensitive help in its workbench/catalog help file. "

    wrapper helpFile: helpFileName helpTopic: helpTopicName.!  
wrap: anObject parentObject: parentObject
        "Private - wrap anObject.  parentObject must already be wrapped."
    | aWrapper parentWrapper |
    parentWrapper := parentObject partWrapper.
    parentWrapper isNil
        ifTrue: [ self error: 'Parent object must be wrapped first.' ].
    aWrapper := PARTSWrapper new.
    aWrapper
        object: anObject;
        parent: parentWrapper.
    anObject partWrapper: aWrapper.
    parentWrapper addComponent: aWrapper!
fileName: aName
    fileName := aName!   
iconFromPathName: aPathName
        " Answer the icon stored in the file
        named aPathName. "
    | aFileStream anIcon fileDescriptor |

    ( aPathName isNil or: [ ( PARTSFile exists: aPathName ) not ] )
        ifTrue: [ ^PARTSFileNotFound signalForFile: aPathName ].
    fileDescriptor := PARTSFileDescriptor pathName: aPathName.
    aFileStream := fileDescriptor asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ anIcon := self iconFrom: aFileStream ]
        ensure: [ aFileStream close ].
    anIcon connectionPrivate notNil
        ifTrue: [
            "If repository entity, the stream's file is a temp file.
                Use the repository entity name instead."
            anIcon connectionPrivate fileReference: fileDescriptor ].
    ^anIcon!   
nestedPartsPropertyFrom: aFileStreamOrProperties
        " Answer an array with the nested parts of the application
    in the given stream.  The first element contains the referenced
    parts found in the respective application property.  The
    second element contains the embedded parts."

    ( aFileStreamOrProperties isStream and: [ aFileStreamOrProperties size = 0 ])
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStreamOrProperties file pathName.
            ^nil ].
    ^self fileAccessorClass new nestedPartsPropertyFrom: aFileStreamOrProperties!   
writeSettingsFileFor: aPARTSSettings newFile: aPathName
        " Store the given settings in a PARTS init file. "
    self new
        writeSettingsFileFor: aPARTSSettings
        newFile: aPathName.! 
storeOnPathName: aPathName
        "Construct the receiver's parts application and store it on aPathName.  The type of
        file produced is deteremined by aPathName's file name extension."
    self application storeOnPathName: aPathName
!
partMessages
        " Answer the PARTS message interface of the receiver. "

    | items interfaceList |
    items := self externalEvents asSortedCollection asArray.
    interfaceList := PARTSInterfaceList new
        items: items.
    items notEmpty
        ifTrue: [ interfaceList defaultItem: items first ].
    ^interfaceList!  
loadSettings
        " Load the PARTS Workbench settings from the standard ini file. "
    self loadSettingsFrom: self defaultFileName.!
isTopStretched
    "Private - Answer true if the top is stretchable."

    ^(mask bitAnd: 2r00000100) > 0! 
fileName
        " Answer the file name of the application file being processed
        (e.g., 'myapp.par'). "

    ^fileName!
defaultText
    "Private"
    ^self filePathName,' has an incorrect file version or platform.'! 
partSetGraphics: anIcon
        " Private - update the receiver's icon. "

    self icon: anIcon.! 
eventTableForEdit
        "Private - Answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."
    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable!   
resultLinkTrigger
        " Private - answer the name of the event which
        triggers a result link. "

    ^#lafLinkResult:! 
pathPoints: anArray
    "Private - Set the path points in the scale unit of the
    receiver's application."

    anArray isNil ifTrue: [ ^nil ].

    editState
        pathPoints: anArray
        scaleUnit: self partApplication defaultScaleUnit!
applicationEvents
        "Private - Answer a collection of symbols for the
       application events (vs. events belonging to the
        part accessor itself."
    | staticEvents |
    staticEvents := self staticEvents.
    ^self eventTable keys reject: [ :anEvent |
        staticEvents includes: anEvent]!  
describeClassesInPathName: aPathName newFile: reportFileName
        " Write a report to the file named <reportFileName>
        describing the classes stored in the PARTS application in
        the .PAR file named <aPathName>. "

    | partFileStream reportFileStream |
    CursorManager execute 
		changeFor: [
    		partFileStream := File pathNameReadOnly: aPathName.
    		reportFileStream := File newFile: reportFileName.
    		self fileAccessorClass new
        		describeApplicationIn: partFileStream
        		on: reportFileStream
        		includeDetails: false.
    		partFileStream close.
    		reportFileStream close.
			].!  
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."
    | rect tall |
    rect := self rectangle.
    tall := SysFont height + 6.
    ^( rect leftTop extentFromLeftTop: rect width @ tall )
        mapFromWindow: self
        to: self partEditor workbenchPane.!  
center: centerInset stretched: centerStretch height: height stretched: heightStretch
    "Use centerInset and height for the horizontal measurement.  centerStretch
     and heightStretch are booleans indicating whether it's stretchable."

    top := centerInset.
    bottom := height.
    self useCenterHeight;
        useTopStretched: centerStretch;
        useBottomStretched: heightStretch! 
componentDictionary
        " Private - answer the part name scope dictionary. "

    ^componentDictionary!
title: aString
        " Set the application's title property. "

    self userPropertyNamed: self titlePropertyName put: aString! 
postMessageBox: aTitle
    "Post a message box for the receiver with the title <aTitle>"
    | title |
    title := aTitle isNil
        ifTrue: [ 'Application Load Error' ]
        ifFalse: [ aTitle ].

    MessageBox notify: title
        withText: self messageText.! 
partHint
        "Answer a string which gives a brief description
        of the receiver part. "

    ^property hint!
writeSettingsFile
        " Store the current settings in the PARTS init file. "
    self
        writeSettingsFileFor: self currentSettings
        newFile: self defaultFileName.!  
right: rightInset stretched: rightStretch width: width stretched: widthStretch
    "Use rightInset and width for the horizontal measurement.  rightStretch
     and widthStretch are booleans indicating whether it's stretchable."

    left := width.
    right := rightInset.
    self useLeftWidth;
        useRightInset;
        useLeftStretched: widthStretch;
        useRightStretched: rightStretch!  
descriptionDestination: application
        " Private - answer a description of the destination end
        of the receiver. "

    | component anchorLink |
    self isInternalArgumentLink
        ifTrue: [
            anchorLink := self anchorLink.
            ^anchorLink isResultLink
                ifTrue: [ anchorLink descriptionSource: application ]
                ifFalse: [
                    ( application componentNameOf: anchorLink sourceObject ifAbsent: [ '*Invalid component*' ] ),
                        ' <', ( self class getLabelFor:
                                ( ( self keywordsIn: anchorLink trigger ) at: selector ) ),
                        ' value>' ]
            ].
    component := self destinationObject.
    ^( component isPARTSApplication
    and: [ component hasExternalEvent: selector ] )
        ifTrue: [
            'External <', ( self class getLabelFor: selector ), '>']
        ifFalse: [
            ( application componentNameOf: component ifAbsent: [ '*Invalid component*' ]),
                ' [', ( self class getLabelFor: selector ), ']'
            ]! 
at: aKey put: aValue
        " Set the value for the user-defined property named <aKey> to <aValue>. "

    ^self propertiesCreate at: aKey put: aValue!   
platformFilePrefix
        " Private  - platform and version dependent "

    ^PlatformFilePrefix! 
source
        " Private - answer the script source. "

    ^source!   
removeChangeMapsSatisfying: aOneArgBlock forVersion: aFileVersion
        " Remove any ObjectChangeMap's registered for loading
         applications stored from aFileVersion which cause
        aOneArgBlock to evaluate to true. "

    | changeMaps |
    changeMaps := ( self upgradeMapsDictionary at: aFileVersion
        ifAbsentPut: [ ^self ] )
            asOrderedCollection.
    changeMaps := changeMaps reject: [ :aRegisteredMap |
        aOneArgBlock value: aRegisteredMap ].
    changeMaps isEmpty
		ifTrue: [
        self upgradeMapsDictionary removeKey: aFileVersion ]
		ifFalse: [
        self upgradeMapsDictionary
            at: aFileVersion
            put: changeMaps asArray ].! 
signalForFile: aFileReference
    "Signal that the exception represented by the receiver has occurred;
    create an instance to represent this specific occurrence.
    Associate <aFileReference> with the occurrence."

    | exception |
    ( exception := self new )
        file: aFileReference.
    ^exception signal!   
fileName
        "Answer the name of the application part file."
    ^self fileDescriptor isNil
        ifTrue: [ '' ]
        ifFalse: [ self fileDescriptor fileName ]! 
loadForEdit
    "Load the part described by the receiver to be edited.
    <loadContext> can specify a debugger."
    | app |

    app := self loadForEditWithContext:
        ( PARTSLoadContext new
            fileDescriptor: self;
            yourself ).
    app notNil
        ifTrue: [ app fileDescriptor: self ].
    ^app! 
removeWorkbenchSupportLibrary: aLibraryName
        " Remove the workbench support library named <aLibraryName>.
        Unbind the library if it has been installed in the system. "

	self unbindWorkbenchSupportLibrary: aLibraryName.
    self workbenchSupportLibraries removeKey: aLibraryName.!   
source: aWrapperOrLink
        "Private - set the source object which triggers the receiver
        to <aWrapperOrLink>."

    source := aWrapperOrLink.! 
signalForFile: parentFile cycle: childFile
    "Signal that the exception represented by the receiver has occurred;
    create an instance to represent this specific occurrence.
    Associate <aFileReference> with the occurrence."

    | exception |
    ( exception := self new )
        file: parentFile;
        cycleFile: childFile.
    ^exception signal!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "

    ^SysFont width * 12 @ (SysFont height * 5)!  
fromFile: aFileReference in: aDirectory
        " Answer the application stored in aFileReference
        in aDirectory. "

    ( aFileReference isNil
    or: [ ( PARTSFile exists: aFileReference in: aDirectory ) not ] )
        ifTrue: [ ^nil ].
    ^( PARTSFileDescriptor pathName: aFileReference in: aDirectory  )
        loadForExecute!  
numberOfEventArguments
        " Answer the number of arguments provided by the
        triggering event of the receiver. "

    ^self isArgumentLink
        ifTrue: [ source numberOfEventArguments ]
        ifFalse: [ Message numberOfArgumentsFor: trigger ]! 
scaleMask: aMask
    "Private - Set the attribute mask to aMask."

    mask := aMask!  
getProcessors
	"Answer the processors that exist in the image"

    | answer aClass |
    answer := OrderedCollection new.
    self fileTypeRegistry do: [:className |
        ( aClass := Smalltalk at: className asSymbol ifAbsent: [nil] )
            notNil ifTrue: [ answer add: aClass ]
        ].
    ^answer!  
componentScripts: aDictionary
        "Private - Set the application components' script
        dictionaries.  This information is only valid for
        executable applications (because the wrappers are
        stripped.)"

    property componentScripts: aDictionary!
workbenchSource
        " Private - answer the original application in a workbench
        window from which the receiver was cloned for execution.
        Only set when testing an application from a workbench. "

    ^property propertyAt: #workbenchSource!
fromPath: path
    "Answer an instance of a subclass of the receiver representing an entity with the given path."

	^( path = '.'
		ifTrue: [ Disk ]
		ifFalse: [ path ]) asFileSystemLocator asPARTSDirectory!  
executionMessageClass
        " Private - answer the message class to use for
        the receiver in an executable application. "

    ^selector = realSelector
        ifTrue: [ super executionMessageClass ]
        ifFalse: [ PARTSAliasMessage ]!
propertiesForFile
        "Private - answer an array of properties to describe
        a stored copy of the receiver in a file. "

    | sysFontSize oc |
    sysFontSize :=
        SysFont width asString,
        ' ', SysFont height asString.
    oc :=
        OrderedCollection new
            add: ( Association key: 'hint' value: self partHint );
            add: ( Association key: 'sysFontSize' value: sysFontSize );
            add: ( Association key: 'reuseMode' value: self reuseMode );
            add: ( Association key: 'referencedParts' value: self referencedPartsProperty );
            add: ( Association key: 'embeddedParts' value: self embeddedPartsProperty );
            yourself.
    self isEditable
        ifTrue: [
            oc
                add: ( Association key: 'partName' value: self name );
                add: ( Association key: 'mainObjectClass' value: self mainObjectPrivate class name );
                add: ( Association key: 'helpFile' value: self helpFile );
                add: ( Association key: 'helpTopic' value: self helpTopic );
                add: ( Association key: 'isVisual' value: ( self isVisual ifTrue: ['t'] ifFalse: ['f'] ));
                yourself ].

    ^oc asArray, property userProperties!  
forDirectory: aDirectory fileName: aFileName
	"Answer an instance of the receiver on <aDirectory>
	and <aFileName>"
	^self new
		directory: aDirectory;
		fileName: aFileName;
		fileType: aFileName fileExtension;
		yourself!
scaleUnitToPixelVertical: units
    ^self class scaleUnit: scaleUnit  toPixelVertical: units

!
numberOfMessageArguments
        " Answer the number of argument values which must
        be supplied to fire the receiver properly. "

    ^messageArgLinks size!   
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self isApplicationMessage: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [  super partLinkClassFor: aSelector ]!  
canTab
        "Private - Answer whether the receiver can
        be tabbed into and out of."
    ^false!  
useCenterWidth
    "Private - Use horizontal center measurement."

    self useLeftWidth;
        useRightWidth!  
printPropertiesOn: aStream margin: aString
        "Print a description of the receiver on aStream."
    | margin |
    aStream nextPutAll: aString; nextPutAll: 'Framing properties:'; cr.
    margin := aString, '    '.
    self
        printHorizontalPropertiesOn: aStream margin: margin;
        printVerticalPropertiesOn: aStream margin: margin!
componentDictionary: aDictionary
        " Private - specify the part name scope dictionary. "

    componentDictionary := aDictionary.!   
useRightStretched: boolean
    "Private - If boolean is true then make the
     right stretchable to the containing frame."

    mask :=
        ( boolean
            ifTrue: [ mask bitOr: 2r00010000]
            ifFalse: [ mask bitAnd: 2r11101111 ] )!   
isLeftStretched
    "Private - Answer true if the left is stretchable."

    ^(mask bitAnd: 2r01000000) > 0!   
addComponent: anObject name: nameString
        " Private - add <anObject> to the application's 
        componentDictionary with the name <nameString>.
        The part name must already have been validated. "

    componentDictionary at: nameString put: anObject.
    ^anObject!
writeToStream: aWriteBlock
    "Evaluate the <aWriteBlock> with a writeStream.
    Will overwrite the receiver if it already exists."
    | aStream |

    ( aStream := self asWriteStream ) notNil
        ifTrue: [
            [ aWriteBlock value: aStream ]
                ensure: [ aStream close ]].! 
signal: aNestedPart with: precursiveError
        "aNestedPart cannot load its nested application.  precursiveError
        is the error that first indicated this  Signal an instance of the receiver."
    self new
        nestedPart: aNestedPart;
        precursiveError: precursiveError;
        signal!
displayName
        " Answer a string suitable for displaying the receiver. "

    ^self asString! 
new
        " Answer a new PARTS editor state. "

    ^super new initialize!   
object
        " Private - support polymorphism with PARTS wrapper.
        A link acts as a wrapper in that it is the triggering object
        for argument and result links. "

    ^self!
left: leftInset stretched: leftStretch width: width stretched: widthStretch
    "Use leftInset and width for the horizontal measurement.  leftStretch
     and widthStretch are booleans indicating whether it's stretchable."

    left := leftInset.
    right := width.
    self useLeftInset;
        useRightWidth;
        useLeftStretched: leftStretch;
        useRightStretched: widthStretch! 
userProperties
        " Answer a collection of assocs with the
        user-defined propertes (name/value strings). "

    ^userProperties!  
receiver
        " Private - answer the receiver of this link. "

    ^receiver!   
refersToAnyOf: aCollection
        " Answer whether the receiver or any links that
        it triggers sends a message to any of the objects
        in <aCollection>. "

    ( aCollection includes: self destinationObject )
        ifTrue: [ ^true ].
    self dependentLinks do: [ :aLink |
        ( aLink refersToAnyOf: aCollection )
            ifTrue: [ ^true ] ].
    ^false!  
nestedPartsPropertyFromPathName: aPathNameOrFileDescriptor
        " Answer the property for the application in the given
    file that enumerates the nested parts of the application. "
    | aFileStream nestedParts |

    ( aPathNameOrFileDescriptor isNil
        or: [ ( PARTSFile exists: aPathNameOrFileDescriptor ) not ] )
        ifTrue: [
            ^PARTSFileNotFound signalForFile: aPathNameOrFileDescriptor ].
    aFileStream := ( PARTSFileDescriptor pathName: aPathNameOrFileDescriptor )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ nestedParts := self nestedPartsPropertyFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^nestedParts! 
initialize
        " Private - initialize a new instance of the receiver. "

    canBeLoaded := false.
    canBeDescribed := canReadIcon := canReadProperties := true.!   
trigger
        "Answer the event which triggers the receiver."

    ^trigger! 
mainObject
        "Answer the first component in the application."

    | parts |
    self partWrapper components size >= 1
        ifTrue: [
            parts := self partWrapper components.
            ^(parts detect: [:each | each object partHasVisualParts]
                ifNone: [parts first])
                    object]
        ifFalse: [^nil]!   
iconFrom: aFileStream
        " Answer the icon stored in aFileStream. "

    aFileStream size = 0
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStream file pathName.
            ^nil ].
    ^self fileAccessorClass new iconFrom: aFileStream!   
partCanTriggerEvent: aSymbol
        " Answer whether the receiver can trigger the event <aSymbol> "

    ^self partIsEditing
        ifTrue: [ super partCanTriggerEvent: aSymbol ]
        ifFalse: [ true ]   " don't make assumptions about contained app if not editing "!  
propertiesFromFile: aFileReference in: aDirectory
        " Answer the properties stored in the file
        named aFileReference in aDirectory
        as a dictionary of name/value string pairs. "

    | aFileStream properties |
    aFileStream := ( PARTSFileDescriptor fileName: aFileReference in: aDirectory )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ properties := self propertiesFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^properties! 
runtimeCloneWith: newObject replacing: oldObject
        " Private - answer a clone of the receiver which
        will be triggered at PARTS execution time.
        Any references to the <oldObject> needed to
        fire the link are replaced by the <newObject>. "

    | clone cloneArgLinks anArgumentLink |
    clone := self runtimeCloneSkeleton.
    clone  " clone the runtime info needed to fire the link "
        trigger: trigger;
        receiver: ( receiver == oldObject
            ifTrue: [ newObject ]
            ifFalse: [ receiver ] );
        selector: selector;
        traceFire: traceFire.
    messageArgLinks notNil
        ifTrue: [
            cloneArgLinks := Array new: messageArgLinks size.
            1 to: messageArgLinks size do: [ :i |
                anArgumentLink := messageArgLinks at: i.
                cloneArgLinks at: i put:
                    ( anArgumentLink runtimeCloneWith: newObject replacing: oldObject ) ] ].
    resultLink notNil
        ifTrue: [
            clone resultLink: ( resultLink runtimeCloneWith: newObject replacing: oldObject ) ].
    ^clone!
eventTableInternal: wrapperEventTable
        "Private - install the table of internal event handlers for the
        receiver.  Used by the wrapper to install the application's
        links representing its external message implementations
        to enable execution. "

    | realInternalEventTable |
    wrapperEventTable isNil
        ifTrue: [ ^self ].
    eventTable isNil
        ifTrue: [ self eventTableAllocate ].
    realInternalEventTable := eventTable at: 2.
    wrapperEventTable associationsDo: [ :anAssoc |
        realInternalEventTable
            at: anAssoc key
            put: ( ActionSequence fromCollection: anAssoc value )
                asMinimalRepresentation.
        ].!   
initializeUpgradeChangeMaps
         " Private - initialize the upgrade load maps for
        the current version.  The upgradeChangeMapsDictionary
        is a dictionary indexed by the version number
        of a filed version which can be loaded by the
        current version.   This needs to be run whenever
        the change map specifications are updated:
            PARTSFile initializeUpgradeChangeMaps
        "

    self upgradeMapsDictionary: self constructUpgradeChangeMaps.!  
defaultIcon
        " Answer a new default icon for an application "

    ^DefaultIcon partMirrorCopy: PARTSMirrorCopyDictionary new!  
applicationIcon
        " Private - answer the icon of the application being stored. "

    ^properties at: #icon! 
loadSearchPathFrom: aPathName
        " Set the PARTS search path from the .ini file aPathName. "
    (File exists: aPathName)
        ifFalse: [^self new loadSearchPath: nil].
    self new
        loadSettingsFrom: aPathName
        into: nil.   " search path only "!
executionState: aString
        " Set the application's execution state property.
        Execution states are 'editable', 'executable', and 'debuggable'. "

    ^self userPropertyNamed: self executionStatePropertyName
       put: aString!  
printString
        "Answer a String that is an ASCII representation
         of the receiver."
    ^self type isString
        ifTrue: [ super printString, ' for: ', self type ]
        ifFalse: [ super printString ]
! 
setIcon: anIcon from: aFileStream fileName: fileName
        "Private - set the contents of anIcon from aFileStream."
    PARTSFile fileAccessorClass new
        setIcon: anIcon
        fromPARStream: aFileStream
        fileName: fileName
!   
isAvailable
        "Private - answer whether the receiver can be used in the current
        environment.  Default answer is true."
    ^true!
property: anApplicationProperty
        " Private "

    property := anApplicationProperty.!   
fileInActivate: anObjectFiler
        " Private - activate instance which has just been loaded.
        Set the file reference and reload the icon. "

    | loadContext anIcon fileDescriptor |

    loadContext := anObjectFiler clientContext.
    loadContext isPARTSLoadContext not  " paste parts has no context "
        ifTrue: [ ^self ].

    fileDescriptor := ( PARTSFileDescriptor pathName: loadContext filePathName ).
    self fileDescriptor: fileDescriptor.
    self isNestedApplication
        ifFalse: [  " don't want do this for embedded nested parts, just the main guy "
            anObjectFiler
                when: #loaded
                send: #fileInRecordLibraryDependencies: to: self with: anObjectFiler.
            ].

    self isExecutable
        ifTrue: [
            "Reinstall any backed up scripts (because there are no wrappers)"
            property componentScripts size > 0
                ifTrue: [
                    property componentScripts
                        keysAndValuesDo: [ :aComponent :aScriptDictionary |
                            aComponent addBehavior: aScriptDictionary ]].
            property componentScripts: nil ]
		ifFalse: [
				"no icon in exe"
            [ anIcon := PARTSFile iconFromPathName: fileDescriptor.
            anIcon connection: nil.  " don't need catalog connection info " ]
            on: PARTSApplicationLoadError
            do: [ :e |
                e postMessageBox: 'Icon Load Error'.
                anIcon := nil ].
            self icon: anIcon]
!   
validateApplication
    "Update the receiver's application if it has changed.
    For performance, only check other workbenches.  Don't
    check the files themselves."
	| editor |
    (editor := self partEditor) isNil
		ifFalse: [editor updateFromEditors: self]! 
eventTableForEdit
    "Private"
    "Answer the table of event handlers for the receiver.
    These events actually belong to the application's editor.
    Allocate if necessary so that updates can be stored."

    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable! 
manufacturer
        " Answer the application's manufacturer. "

    ^property manufacturer!   
canBeDescribed: aBoolean
		" Specify whether this version can be described
		by the current system. "

	canBeDescribed := aBoolean.!  
releaseNumberString
        "Answer the current major release number as a string."

    | numbers |
    numbers := self versionNumbers.
    ^( numbers at: 1 ) printString, '.', ( numbers at: 2 ) printString!  
scrollHorizontal: anInt
        "Private - Reimplemented here because GroupPanes do
         not scroll."!  
forLaunch
	" Answer whether the copy is going to be used for a
	runtime application in the development environment.
	The application will be executing, but it is not meant
	to be saved to a file.  Potentially, some of the contained
	nested part applications will not be included "

	^( self forExecute and: [ self forExecutableFile not ])!
propertyAt: key ifAbsent: aBlock
        "Private - Answer the value associated with key
        in the properties dictionary."

    properties isNil ifTrue: [^aBlock value].
    ^properties at: key ifAbsent: aBlock! 
defaultInitialSize
        " Answer the default initial size for instances of the receiver. "

    ^4093!  
finishStoringApplication: anApplication
        " Private - restore <anApplication> to its original state
        after it has been stored in a file. "

    anApplication
        icon: ( properties at: #icon );
        fileDescriptor: ( properties at: #fileDescriptor );
        libraryDependencies: ( properties at: #libraryDependencies );
        yourself.!   
fromPathNameOrEditor: aPathName debugger: aDebugger
        " Answer the most current version of the
        application in aPathName. "

    | anEditor |
    ( anEditor := self workbenchContaining: aPathName asString ) notNil
        ifTrue: [
            ^aDebugger isNil
                ifTrue: [ anEditor getAppCopyToExecute ]
                ifFalse: [ anEditor getAppCopyForDebugger: aDebugger enableExecution: true ]
                ].
    ^self fromPathName: aPathName debugger: aDebugger!  
fileTypeForNone

     ^ PARTSFileType type: '   ' pattern: '*' description: 'No extension (*)'! 
scalePoint: aPoint
        " Private - answer <aPoint> scaled by the current scaleFactor. "

    ^( aPoint * scaleFactor ) rounded!
defaultText
    "Private"
    ^'A cycle was found.  ', self fileName,' and ',cycleFile asString,' reference each other.',
    (String with: Cr), self fileName,' was not loaded.'! 
scaleUnitToPixelHorizontal: units
    ^self class scaleUnit: scaleUnit  toPixelHorizontal: units
!  
removeLiteralsFromLibrary
        "Private - when the receiver builds an application, it's likely that the application
        will contain objects that are literals of compiled methods of the receiver.  In this
        case the application will have dependencies on the library that contains the receiver.
        Do surgery on the compiled methods of the receiver to replace their literals with copies,
        thus removing dependencies on the library.  This must be done before the
        application is built."
    self methodDictionary do: [ :cm | cm partCopyLiterals ].
    self class methodDictionary do: [ :cm | cm partCopyLiterals ]
!
scriptPart
       " Private - answer the part to which this script belongs. "

    ^sourceObject part! 
directory
    ^directory!
argumentLink: anInteger
        "Private - answer a sub link reference for the anInteger'th
        argument link."
    ^PARTSSublinkReference new
        parentReference: self;
        index: anInteger
!
storeOnPathName: aPathName libraryMappings: libraryMappings
        " Store the application to a new file named
        aPathName.  Answer the file name. "
       | targetDescriptor app operation editableTarget |

    targetDescriptor := PARTSFileDescriptor pathName: aPathName.

    self isEditable
        ifTrue: [
            "Need to go through mirror copy logic to catch all logic for generating a file to save."
            editableTarget := ( PARTSFileProcessor getProcessorFor: targetDescriptor ) class canEdit.
            operation := editableTarget
                ifTrue: [ #save ]
                ifFalse: [ #saveExecutable ].
            app :=
                self partMirrorCopyReal: ( PARTSMirrorCopyDictionary for: operation ).
            editableTarget
                ifFalse: [ app enableExecution: false ]]
        ifFalse: [ app := self ].

    ^targetDescriptor
        store: app
        libraryMappings: libraryMappings.
! 
removeComponentsOwnedBy: aWrapper
        " Private - remove the component owned by
        <aWrapper> and any child components
        that it contains from the receiver. "

    aWrapper parent removeComponent: aWrapper.
    aWrapper withAllChildren do: [ :aComponentWrapper |
        componentDictionary removeKey: aComponentWrapper name 
            ifAbsent: [] ].! 
left: leftNumber bottom: bottomNumber right: rightNumber top: topNumber

    left := leftNumber.
    bottom := bottomNumber.
    right := rightNumber.
    top := topNumber! 
releaseEventTable
        "Private - break all connections to event handlers."

    eventTable := nil.!
store: aPart libraryMappings: libraryMappings
    "Save <aPart> into the external storage described
    by the receiver.  <libraryMappings> is a dictionary
    mapping classes to their library names."

    | application processor |

    ( processor := self fileProcessor ) isNil
        ifTrue: [ ^nil ].

    application := nil.
    self writeToStream: [ :aWriteStream |
        application := self fileProcessor
            store: aPart
            into: aWriteStream
            libraryMappings: libraryMappings ].

    ^ application!
renameExternalMessage: originalName to: newName
        " Rename the external message selector <originalName>
        to <newName>."

    externalMessages
        at: ( externalMessages indexOf: originalName )
        put: newName.!
sharedObjects
    "Answer the set of shared objects.  Shared objects are
    collapsed into one object after copy to save space.
    The sharedObjects are the copies. "

    ^sharedObjects!
partName: aString event: aSymbol index: anInteger
        "Private - set the state of the receiver."
    partName := aString.
    event := aSymbol.
    index := anInteger
! 
fileName: fileNameOnlyString
        " Private - specify the file name of the application file being processed. "

    fileName := fileNameOnlyString.!
isTimerRunning: aTimer
        " Answer whether aTimer is currently running. "
    ^PARTSTimer notNil
        and: [ PARTSTimer isRunning: aTimer ]!   

workbenchLibraryNameFor: aRuntimeLibraryName
       " Answer the name of the workbench support library which
        corresponds to the part runtime library named
        <aRuntimeLibraryName>.  To use this service, the library
        names for the part runtime library and its workbench support
        library must conform to the naming convention:
            <manufacturer prefix> <library identification> {R | W} <library version number>
        where the first two sections contain only letters,
        "

    | workbenchLibraryName platformLetterIndex |
    aRuntimeLibraryName isNil
        ifTrue: [ ^nil ].  " filing in, not installing library "
    workbenchLibraryName := aRuntimeLibraryName fileNameLessPath fileName.
    1 to: workbenchLibraryName size do: [ :i |
        ( platformLetterIndex isNil
        and: [ ( workbenchLibraryName at: i ) isDigit ] )
            ifTrue: [ platformLetterIndex := i - 1 ].
        ].
    ^workbenchLibraryName
        copyReplaceFrom: platformLetterIndex to: platformLetterIndex with: 'W'
!  
propertiesFromPathName: aPathName
        " Answer the properties stored in aPathName
        as a dictionary of name/value string pairs. "

    | aFileStream properties |
    ( aPathName isNil or: [ ( PARTSFile exists: aPathName ) not ] )
        ifTrue: [ ^PARTSFileNotFound signalForFile: aPathName ].
    aFileStream := ( PARTSFileDescriptor pathName: aPathName )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ properties := self propertiesFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^properties! 
fileDescriptor
        " Answer the PARTS file descriptor of the application file being processed. "

    ^fileDescriptor! 
timerEvent: anInteger
        "Private - The timer identified by anInteger has gone off.
         Send a notification message to the timer part 
        associated with the identifier anInteger."
    (items at: anInteger ifAbsent: [^self]) tick! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
fromFileOrEditor: aFileReference
        " Answer the most current version of the
        application in aFileReference."
    | dir |
    ( dir := PARTSFile directoryContaining: aFileReference ) isNil
        ifTrue: [ ^nil ].

    ^self
        fromFileOrEditor: aFileReference
        in: dir
        debugger: nil!   
isBottomStretched
    "Private - Answer true if the bottom is stretchable."

    ^(mask bitAnd: 1) > 0!
fileTypeForSource
        "Private - answer a PARTSFileType for a Smalltalk source code
        representation of a PARTSApplication."

    ^PARTSFileType type: 'CLS' pattern: '*.CLS' description: 'Smalltalk code (*.CLS)'!
scaledRectangleRightBottom
		"Private - Before the receiver is upgrade to a valid PARTSFramer
		it contains the state of a ScaledRectangle.  Instance variable mappings:
		PARTSFramer	ScaledRectangle
		mask 				styleMask 
		left					leftTop
		right					rightBottom
		"
	^right!  
removeAllSubclasses
        "Private - maintainance."
    self subclasses copy do: [ :sub | sub removeFromSystem: false ]!  
reuseModePropertyFrom: aFileStreamOrProperties
        " Answer the reuseMode property of the application."

    ( aFileStreamOrProperties isStream and: [ aFileStreamOrProperties size = 0 ])
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStreamOrProperties file pathName.
            ^nil ].
    ^self fileAccessorClass new reuseModePropertyFrom: aFileStreamOrProperties!  
versionFromPathName: aPathName
        " Answer the PW file version of the file
        named <aPathName>. "

    | aFileStream fileVersion |
    ( aPathName isNil or: [ ( PARTSFile exists: aPathName ) not ] )
        ifTrue: [ ^PARTSFileNotFound signalForFile: aPathName ].
    aFileStream := ( PARTSFileDescriptor pathName: aPathName )
        asReadStream.
    aFileStream isNil
        ifTrue: [ ^nil ].
    [ fileVersion := self versionFrom: aFileStream ]
        ensure: [ aFileStream close ].
    ^fileVersion!
addComponentPoolTo: aClassModel
!
messageSelector
        " Answer the message selector sent by the receiver. "

    ^self isInternalArgumentLink
        ifTrue: [ nil ]
        ifFalse: [ selector ]!   
editorState
        " Private - answer the application editor state. "

    ^editorState!  
lafExplainDestinationIn: containingApplication
        " Private "

    | anchorLink anObject |
    self isInternalArgumentLink
        ifTrue: [
            anchorLink := self anchorLink.
            ^anchorLink isResultLink
                ifTrue: [ anchorLink lafExplainSourceIn: containingApplication ]
                ifFalse: [
                    ( ( self keywordsIn: anchorLink trigger ) at: selector ),
                    ' value' ] ].

    anObject := self destinationObject.
    ( anObject isPARTSApplication
    and: [ anObject hasExternalEvent: selector ] )
        ifTrue: [
            ^'internal "', selector, '" message' ].
    ^( containingApplication componentNameOf: anObject ifAbsent: [ '*Invalid component*' ] ),
        ' "', selector, '" message '!  
useCenterHeight
    "Private - For vertical center measurement."

    self useTopHeight;
        useBottomHeight! 
triggerExternalEvent: eventName withArguments: argumentList
        " Private - trigger the external event <eventName. 
        Obsolete - retained temporarily for compatibility. "

    ^self triggerEvent: eventName withArguments: argumentList!  
versionNumberString
        "Answer the current version number (release + revision level) as a string."

    | numbers |
    numbers := self versionNumbers.
    ^( numbers at: 1 ) printString, '.', ( numbers at: 2 ) printString, '.', ( numbers at: 3 ) printString! 
pixelToScaleUnitHorizontal: pixels
    ^self class pixelHorizontal: pixels toScaleUnit: scaleUnit
! 
installPartRuntimeLibrary
        " Private - install the basic application parts runtime library.
        Load the workbench support library if appropriate. "

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Basic Visual Parts'.! 
changeNameOf: anObject from: oldNameString to: newNameString
        " Private - change the name of the component <anObject>
        which is currently named <oldNameString> to <newNameString>. "

    "self ASSERT: ( self componentNameOf: anObject ) = oldNameString."
    componentDictionary
        removeKey: oldNameString;
        at: newNameString put: anObject.!
useRightWidth
    "Private - For the right side, use width measurement."

    mask := mask bitAnd: 2r11011111! 
versionFrom: aFileStream
        " Answer the PW file version of <aFileStream>. "

    aFileStream size = 0
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStream file pathName.
        ^nil ].
    ^self fileAccessorClass new versionFrom: aFileStream!   
selector
        "Answer the message selector which is sent when
        the receiver is fired."

    ^selector!  
fireSelfWith: arguments
        " Private - fire the receiver with the collected arguments.
        Answer the result. "

    selector = realSelector  " left by change message "
        ifTrue: [ ^super fireSelfWith: arguments ].
    ^receiver
        perform: realSelector
        withArguments: ( Array with: selector with: arguments ).!   
workbenchSupportLibraryIndex: anInteger
        " Private - set the next available registration index. "

    WorkbenchSupportLibraryIndex := anInteger.!  
staticEvents
        "Private - Answer a collection of selectors for events which
        belong to the part accessor itself instead of the part being
        accessed."
        ^#( #referencedWhileNotLoaded
        #loaded
        #aboutToUnload
        #unloaded)! 
canEdit
	"Answer whether the application represented by the
	receiver can be edited on a workbench"

    ^true!   
sourceObject
        "Answer the source object which triggers the receiver."

    ^source object!  
fileName
    ^fileName!  
addDependentLink: aLink
        " Private - install a dependent link which is
        fired by the receiver to collect an argument value
        or propagate a result value. "

    aLink isArgumentLink
        ifTrue: [ messageArgLinks at: aLink trigger put: aLink ]
        ifFalse: [ self resultLink: aLink ].
    aLink source isNil
        ifTrue: [ aLink source: self ].
        "ifFalse: [ self ASSERT: aLink source == self ]."!   
relativePathName
        " Answer the relative directory path name of the receiver. "
    | fullPath installDirName prefixSize |

    fullPath := self fullDirName.
    installDirName := Disk fullDirName.
    prefixSize := installDirName size.
    ^( ( fullPath size > prefixSize
    and: [ ( fullPath copyFrom: 1 to: prefixSize ) equalsIgnoreCase: installDirName ] )
            ifTrue: [
                fullPath copyFrom: ( prefixSize + 1 )
                    to: ( fullPath size - 1 ) ]
            ifFalse: [
                ( fullPath equalsIgnoreCase: installDirName )
                    ifTrue: ['.']
                    ifFalse: [
                        fullPath copyFrom: 1 to: ( fullPath size - 1 ) ] ] )!
application: anApplication
        " Set the nested application "
    application := anApplication! 
>= aTimestamp
        "Answer true if the receiver is greater than
         or equal to aTimestamp, else answer false."

    aTimestamp isNil ifTrue: [^false].
    ^super >= aTimestamp!
linkReferencedIn: aPARTSApplication
        "Private - answer the link that the receiver references."
    | parentLink |
    parentLink := parentReference linkReferencedIn: aPARTSApplication.
    parentLink isNil ifTrue: [ ^nil ].
    ^index = 0
        ifTrue: [
            parentLink resultLink ]
        ifFalse: [
            parentLink arguments at: index ]! 
parent
        " Abswer the application's parent property.
    For an editable application this information
    is located in the wrapper."

    ^self propertyAt: #parent ifAbsent: [ nil ]!
propertyAt: key
        "Private - Answer the value associated with key
        in the properties dictionary."

    properties isNil ifTrue: [^nil].
    ^properties at: key ifAbsent: [^nil]!   
componentNamesHierarchy
        " Answer a collection containing a hierarchical
        ordering of the component names, indented
        according to nesting depth. "

    | names |
    names := OrderedCollection new.
    self
        componentNamesHierarchy: ( Array with: self partWrapper )
        names: names
        indent: 0.
    ^names asArray!  
top: topInset stretched: topStretch bottom: bottomInset stretched: bottomStretch
    "Use topInset and bottomInset for the horizontal measurement.  topStretch
     and bottomStretch are booleans indicating whether it's stretchable."

    top := topInset.
    bottom := bottomInset.
    self useTopInset;
        useBottomInset;
        useTopStretched: topStretch;
        useBottomStretched: bottomStretch!  
setFrom: aLink
    "Private - Set the receiver's instance variables
    from <aLink>"

    super setFrom: aLink.
    realSelector :=
        ( aLink respondsTo: #realSelector )
            ifTrue: [ aLink realSelector ]
            ifFalse: [ aLink selector ]!  
applicationFrom: aFileStream
        " Answer the PARTS application stored in aFileStream.
        The application is in editable form and has not yet
        been enabled for execution. "

    aFileStream size = 0
        ifTrue: [
            aFileStream close.
            PARTSEmptyFile signalForFile: aFileStream file pathName.
            ^nil ].
    ^self fileAccessorClass new objectFrom: aFileStream!   
closestSourceObject
        " Private - answer the non-link object which most 
        immediately triggers the receiver. "

    ^self isArgumentLink
        ifTrue: [ source closestSourceObject ]
        ifFalse: [ self attachedSourceObject ]!
revisionNumber: anInteger
        "Private - register an new revision number."

    anInteger < self revisionNumber 
		ifTrue: [ self error: 'newer PW revision already installed' ].
    ^self versionNumbers at: 3 put: anInteger! 
initialize
        " Private - initialize a newly created instance. "

    self virtualScreenExtent: Display extent.!  
upgradeMapsForLoadingPW20
        " Private - answer change maps needed to load
        applications from either PW/Win32 2.0 or PW/OS2 2.0
        into PW 3.0 "

    | changeMaps |
    changeMaps := OrderedCollection new.

    " PartAccessor: PWO 2.0 file name -> PW 3.0 fileDescriptor "
    changeMaps add: ( ( ObjectChangeMap forClassName: #PARTSPartAccessorPart )
        put: 'file' into: 'fileDescriptor';  " fileInActivate must fix this up "
        yourself ).

    " script source added 'part' inst var in PW 3.0 "
    changeMaps add: ( ObjectChangeMap forClassName: #PARTSScriptSource ).

    ^changeMaps!   
COMMENT
"
PARTSSessionManager manages the startup and shutdown
of a PARTS workbench or delivery execution session.
Operations involved in component binding and unbinding
within a PARTS session are all handled here as well.
"!   
enableControls
        "Private - Enable the receiver."
    self enable!
bottom: value
    bottom := value!   
initialize
    "
    Evaluate me to register all processors which are present in the image.
    PARTSFileProcessor initialize
    "
    self initializeFileRegistry.!
argumentLink: aLink
        "Private - set the receiver's state to reference aLink."
    parentReference := self class for: aLink source.
    index := aLink trigger!  
appendSeparated: anInterfaceList defaultItem: newDefaultItem
        " Obsolete - retained in PW 3.0 for compatibility with PW/OS2 2.0 "

    PARTSSessionManager obsoleteMessage.
    ^self concatenateSeparated: anInterfaceList defaultItem: newDefaultItem!   
eventLink
        " Private - answer the event link which triggers
        the link network containing the receiver.  An event
        link can anchor a network of result and argument
        link chains. "

    | aLink |
    aLink := self.
    [ aLink isEventLink ]
        whileFalse: [ aLink := aLink source ].
    ^aLink!   
pattern: aPattern
    " *.PAR, *.PRS, etc... "

    pattern := aPattern asUpperCase!   
store: aPart
    "Save <aPart> into the external storage described
    by the receiver."

    ^self store: aPart libraryMappings: nil!
leftTopMessageLabel: aPoint
        " Specify the offset of the top left corner of the link's message label
        from the path's landing point. "
    leftTopMessageLabel := aPoint.!   
asPARTSDirectory
        " Answer the receiver as a PARTS directory object "

    ^self!   
isLeftInset
    "Private - Answer true if the left measurement is inset
     and false if it is height."

    ^(mask bitAnd: 2r10000000) > 0! 
shrink
    "Private - Make first level components relative to
    minimum bounding box.  The effect of doing this is
    that all the framers are not dependent on the editor
    extent any more.
        Don't shrink top level windows in nested parts so
    that they aren't affected by nested part sizing."
    | oldRect newRect parentIsNestedPart canInclude
        myParent |

    editorState isShrunk ifTrue: [^self].

    oldRect := 0@0 extent: self editorVirtualScreenExtent.
    newRect := self rectangle.  "Min box"
    myParent := self parent.
    parentIsNestedPart :=
        myParent notNil and: [ myParent isPARTSNestedPart ].
    self children do: [:obj |
        canInclude :=
            ((( parentIsNestedPart and: [
                ( obj partRelativeToParent: myParent ) not ]) not )
            and: [ obj partHasVisualParts ]). "<=If nested part, this is slowest op."
        canInclude
            ifTrue: [
                obj framingBlock:
                    (obj framingBlock
                        changeContainingRect: oldRect
                        to: newRect )]].
    editorState isShrunk: true.!   
settings
        " Answer the saved editor preference settings. "
    ^settings!
for: anOperation initialSize: anInteger
        " Answer a MirrorCopy dictionary for an
        <operation> with initial size <anInteger>. "

    ^( super new: anInteger )
        operation: anOperation;
        useMode: #reference;
        sharedObjects: Set new;
        yourself!
partDefineEvent: eventName
        " Define the instance event named eventName.  
        Answer the event name (nil if not legal). "

    | eventNameSymbol |
    eventName isString
        ifFalse: [ ^nil ].
    eventNameSymbol := eventName asSymbol.    
    ( self isValidExternalEvent: eventNameSymbol )
        ifFalse: [ ^nil ].
    ( self hasExternalEvent: eventNameSymbol )
        ifFalse: [ self addExternalEvent: eventNameSymbol ].
    ^eventNameSymbol!   
attachedSourceObject
        " Private - answer the directly attached source object
        which triggers the receiver. "

    ^self isResultLink
        ifTrue: [ source destinationObject ]
        ifFalse: [ self sourceObject ]! 
revisionNumber
    "Answer the file version represented by this file
        descriptor. If the fileDescriptor class does not
        support multiple versions, answer nil."

    ^nil! 
componentNameOf: anObject ifAbsent: aBlock
        " Answer the component name of <anObject>. "

    ^componentDictionary keyAtValue: anObject ifAbsent: [ aBlock value ]! 
loadAction: aTwoArgumentAction
		" Specify a 2-argument action to evaluate when an application
		has been loaded from a part file with the receiver's file version string. "

	loadAction := aTwoArgumentAction.! 
asString: aValue
        " Private - answer aValue as a string. "
    aValue isString
        ifTrue: [^aValue].
    aValue isNil
        ifTrue: [^''].
    ^aValue asString!  
versionNumbers: anArray
        " Private - set the version numbers (release number, minor version,
        revision number) "

    VersionNumbers := anArray.!   
at: aKey ifAbsent: aBlock
        " Answer the value for the user-defined property named <aKey>.
        If not found, evaluate <aBlock>. "

    properties isNil ifTrue: [ ^aBlock value ].
    ^properties at: aKey ifAbsent: aBlock!  
getProcessorFor: aFileDescriptor
    "Answer an instance of the file processor who can
    process the file type associated with <aFileDescriptor>."

    | aClass |
    self fileTypeRegistry do: [ :className |
        aClass := Smalltalk at: className asSymbol ifAbsent: [nil].  "If the
            processor class is unbound, this will still work"
        aClass notNil ifTrue: [
            (aClass handlesFileType: aFileDescriptor fileType)
                ifTrue: [ ^aClass new fileDescriptor: aFileDescriptor; yourself ] ] ].
    ^ self getDefaultProcessorFor: aFileDescriptor! 
defaultScaleUnit: aScaleUnit
    "Private - Set the default scale unit used for icons
    and links on the workbench for the receiver."
    | allLinks |

    allLinks := Set new.
    wrapper withAllChildren do: [ :aWrapper |
        allLinks addAll: aWrapper links ].
    allLinks do: [ :aLink |
        aLink editState
            pathPoints: aLink pathPoints
            scaleUnit: aScaleUnit ].

    self children do: [ :aComponent |
        aComponent partIsWindow
            ifFalse: [
                aComponent partWrapper rectangle scaleUnit: aScaleUnit ]].

    property defaultScaleUnit: aScaleUnit!  
partManufacturer
        "Answer the manufacturer name component of the receiver's full part name. "
	^property isNil
		ifTrue: [ super partManufacturer ]
		ifFalse: [ self manufacturer ]!  
initialize
        " Private - initialize a new instance. "

    self setDefaultAttributes.!   
orderedChildren
        "Private - Answer an OrderedCollection which is the
        ordering of the children for tab and arrow keys."

    ^property orderedChildren! 
reportObsoleteMessageUse
        " Answer whether use of obsolete PW 2.0 messages
        will generate a warning. "

    ^ReportObsoleteMessageUse!  
label
        "Answer the label of the reciever."
    ^self propertyAt: #topLabel!  
unload
        "Unload the application, so it does not use resources."
    application notNil
        ifTrue: [
            self triggerEvent: #aboutToUnload.
            application releaseLibraries.
            application := nil. "cut the cord, and let it fall into the abyss"
            self triggerEvent: #unloaded ]!
hintPropertyFrom: aFileStreamOrProperties
        " Answer the hint info stored in aFileStream"

    ( aFileStreamOrProperties isStream and: [ aFileStreamOrProperties size = 0 ])
        ifTrue: [
            PARTSEmptyFile signalForFile: aFileStreamOrProperties file pathName.
            ^nil ].
    ^self fileAccessorClass new hintPropertyFrom: aFileStreamOrProperties!   
hint: aString
        " Specify the application's hint string. "

    hint := aString.!
COMMENT
"
PARTSLinkEditState is a private class belonging to PARTSLink.
It contains the editing state describing where to render the
link when it is displayed in a workbench.
"!
staticMessages
        "Private - Answer a collection of selectors for messages which
        belong to the part accessor itself instead of the part being
        accessed."
    ^#(#load #unload)!  
pools
        "Private - Answer an OrderedCollection of pool dictionaries
         for the receiver, including only the shared pool dictionaries.
         Class variables are excluded from the name scope of a script.
         The host platform OS constants has lowest precedence;
         if there are duplicate names in any of the other pools,
         they are preferred. "

    | pools aPool hostConstantsPool |
    pools := OrderedCollection new.
    self sharedPools asSortedCollection do: [ :aPoolName |
        aPool := Smalltalk at: aPoolName
           ifAbsent: [ ^self error: 'Pool Dictionary ', aPoolName, ' is undefined.' ].
        aPoolName = #OperatingSystemConstants
            ifTrue: [ hostConstantsPool := aPool ]
            ifFalse: [ pools add: aPool ] ].
    pools add: hostConstantsPool.
    ^pools!
removeLink: aLink
        " Remove the argument or result link <aLink>
        triggered by the receiver. "

    "self ASSERT: aLink source == self."
    aLink == resultLink
        ifTrue: [ resultLink := nil ]
        ifFalse: [ messageArgLinks at: aLink trigger put: nil ].!  
isLaunchable
        " Answer whether this application can be launched. "

    ^self partIsEditing
        ifTrue: [ self partWrapper hasLinksForEvent:  #open ]
        ifFalse: [ self eventTableInternal includesKey: #open ]!
useLeftInset
    "Private - For the left side, use
      inset measurement."

    mask := mask bitOr: 2r10000000! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList emptyList! 
frameCanBeRescaled
    "Answer true if a framing block can be rescaled dynamically."

    ^true!   
basicFromLocator: aFileSystemLocator
    "Private - Since receiver and subclasses reimplement 'fromLocator:'
    need a way to create a basic instance of the receiver."

    ^super fromLocator: aFileSystemLocator! 
initialize
        " Private - initialize a new instance. "

    self label: 'PARTSTimerWindow'.
    super initialize.
    items := IdentityDictionary new.! 
open
        "Build the application and open it."
    self applicationForExecute open
!
fileTypeFor: aFileExtension
        " Private - answer the PARTSFileType for <aFileExtension>. "

    | normalizedExtension |
    normalizedExtension := aFileExtension asUpperCase.
    ^ PARTSFileType
        type: normalizedExtension
        pattern: '*.', normalizedExtension
        description: ( self fileTypeDescriptionFor: normalizedExtension )!  
source: aString
        " Private - set the script source. "

    source := aString.!  
upgradeMapsForLoadingPWO30preBeta3
        " Private - answer the upgrade load maps for
        structure changes in the current version. "

    | changeMaps |

    changeMaps := OrderedCollection new.

    " script source added 'part' inst var in PW 3.0 just prior to beta 1.
         Support this temporarily, but drop as soon as pre-beta1 apps
         upgraded [DJL 26-Jul-94] "
    changeMaps add: ( ObjectChangeMap forClassName: #PARTSScriptSource ).

    " PARTSIcon: renamed 'name' -> 'label' after PWO 3.0 beta 1; dropped 'iconFile' "
   changeMaps add: ( ( ObjectChangeMap forClassName: #PARTSIcon )
        put: 'name' into: 'label';
        yourself ).

    " Font 'changed' inst var dropped in base beta 3 build of 27-Sep-94 "
    changeMaps add: ( ObjectChangeMap forClassName: #Font ).

    " EntryField 'maxSize' -> #textLimit property "
    ( Smalltalk at: #PARTSEntryFieldPart ) withAllSubclasses do: [ :aClass |
        changeMaps add: ( ( ObjectChangeMap forClassName: aClass name )
            put: 'maxSize' into: 'topCorner';  " upgrader must fix "
            yourself ) ].

    " TextEdit 'readonly' -> style bits "
    changeMaps add: ( ( ObjectChangeMap forClassName: #PARTSTextPanePart )
        put: 'maxSize' into: 'topCorner';  " upgrader must fix "
        put: 'readonly' into: 'handle';  " upgrader must fix "
        yourself ).

    #(
        " ListBox dropped bmaps, itemBeingDrawn in 10/19 beta 3 "
        #PARTSListPanePart
        #PARTSDropDownListPart
        #PARTSComboBoxPart
        #PARTSMultipleChoiceListPart
        ) do: [ :classSymbol |
            changeMaps add: ( ObjectChangeMap forClassName: classSymbol ) ].

    #(
		#PARTSTableCellEditor
		#PARTSTableCellTextEditor
		#PARTSTableCellExtendedTextEditor
		#PARTSTableLabelEditor
		#PARTSTableColumnLabelEditor
		#PARTSTableCornerLabelEditor
		#PARTSTableRowLabelEditor ) do: [ :classSymbol |
            changeMaps add: ( ObjectChangeMap forClassName: classSymbol ) ].

    ^changeMaps!  
asActionSequence
        "Answer the receiver as an element of an ActionSequence."

    ^ActionSequence with: self!
applicationAtRuntime
        "Private - At runtime, load the application if
        the property is set for that, or trigger event."
    application isNil
        ifTrue: [demandLoad
            ifTrue: [self loadApplication]
            ifFalse: [self referencedWhileNotLoaded]].
    ^application! 
platformProductVersion
        " Private  - platform and version dependent "

    ^PlatformProductVersion! 
stopAllTimers
        " Stop all currently running timers. "
    items do: [:each | each stopTimer]!
top: value
    top := value! 
canForwardResult
        " Answer whether a result link can be defined for the receiver. "

    ^self isInternalArgumentLink not!  
handlesFileType: aType
	"Private- 
		Answer whether the receiver processes a file of <aType> type."

    self fileType detect: [:fileType | fileType handlesType: aType ]
        ifNone: [ ^ false ].
    ^ true!  
helpInfo
        " Private - answer the encoded help file/topic strings. "

    ^wrapper helpInfo! 
isValidExternalMessage: aSymbol
        " Answer whether <aSymbol> can be defined as an
        external message selector of the application. "

    | dummyHolder |
    ( #( #open #openOn: ) includes: aSymbol )
        ifTrue: [ ^true ].
    ( self respondsTo: aSymbol )
        ifTrue: [ ^false ].
    " don't allow collisions with holder's protocol "
    dummyHolder := (Smalltalk at: #PARTSNestedPart) basicNew.
    ( dummyHolder partRelayedMessages includes: aSymbol )
    "or: [ holder has a script... ] - cannot detect this "
        ifTrue: [ ^true ].
    ^( dummyHolder respondsTo: aSymbol ) not!
scaleFrom: aRect rounded: roundBoolean
    "Answer a Rectangle as a result of applying the
     receiver framer to aRect."

    | fixedRect newLeft newBottom newRight newTop horizontalNegate verticalNegate
        fixedLeft fixedRight fixedTop fixedBottom |

    " coordinate modifier to be platform independent"
    horizontalNegate := (1 isLeftOf: 2) ifTrue: [1] ifFalse: [-1].
    verticalNegate := (2 isBelow: 1) ifTrue: [1] ifFalse: [-1].

    fixedRect := self unrelativeTo: aRect extent.
    fixedLeft := (self scaleUnitToPixelHorizontal: fixedRect left).
    fixedRight := (self scaleUnitToPixelHorizontal: fixedRect right) .
    fixedTop := (self scaleUnitToPixelVertical: fixedRect top).
    fixedBottom := (self scaleUnitToPixelVertical: fixedRect bottom).
    roundBoolean ifTrue: [
        fixedLeft := fixedLeft rounded.
        fixedRight := fixedRight rounded.
        fixedTop := fixedTop rounded.
        fixedBottom := fixedBottom rounded].

    self isLeftInset
        ifTrue: [ "Inset from left"
            newLeft := aRect left + ( fixedLeft * horizontalNegate ).
            self isRightInset
                ifTrue: [ "Inset from left, inset from right"
                    newRight := horizontalNegate > 0
                        ifTrue: [ aRect right - fixedRight max: newLeft + 1 ]
                        ifFalse: [ aRect right + fixedRight min: newLeft - 1 ]
                    ]
                ifFalse: [ "Inset from left, right = width"
                    newRight := newLeft + ( fixedRight * horizontalNegate )]
            ]
        ifFalse: [
            self isRightInset
                ifTrue: [ "inset from right, left = width"
                    newRight := aRect right - ( fixedRight * horizontalNegate ).
                    newLeft := newRight - ( fixedLeft * horizontalNegate )]
                ifFalse: [ "left = horizontal center to left, right = width"
                    newLeft :=
                        aRect left + ( fixedLeft * horizontalNegate )
                          - (( fixedRight // 2 ) * horizontalNegate ). "center to left adjustment"
                    newRight := newLeft + ( fixedRight * horizontalNegate )]
            ].
    self isTopInset
        ifTrue: [  "Inset from the top"
            newTop := aRect top + ( fixedTop * verticalNegate ).
            self isBottomInset
                ifTrue: [  "Inset from the top, inset from the bottom"
                    newBottom := verticalNegate > 0
                        ifTrue: [ aRect bottom - fixedBottom max: newTop + 1]
                        ifFalse: [ aRect bottom + fixedBottom min: newTop - 1]
                    ]   "top, bottom"
                ifFalse: [ "Inset from the top, bottom = height"
                    newBottom := newTop + ( fixedBottom * verticalNegate )]
            ]
        ifFalse: [
            self isBottomInset
                ifTrue: [ "Inset from bottom, top = height"
                    newBottom := aRect bottom - ( fixedBottom * verticalNegate ).
                    newTop := newBottom - ( fixedTop * verticalNegate )]
                ifFalse: [ "top = vertical center to top, bottom = height"
                    newTop :=
                        aRect top + ( fixedTop * verticalNegate )
                         - (( fixedBottom // 2 ) * verticalNegate ). "center to top adjustment"
                    newBottom := newTop + ( fixedBottom * verticalNegate )]
            ].
    ^Rectangle leftTop: newLeft @ newTop rightBottom: newRight @ newBottom
!
addSubpane: aPane
        "Add subpane aPane to the receiver."
    aPane owner isNil ifTrue: [
        aPane owner: self ].
    super addSubpane: aPane.! 
releaseEventTable
        "Private - break all connections to event handlers.
        These events actually belong to the application's editor. "

    eventTable := nil.!
filePathName
        "Answer the pathName of the file containing the application."

    ^self fileDescriptor isNil
        ifTrue: [ nil ]
        ifFalse: [ self fileDescriptor fullPathName ]!
top
    ^top!
isPARTSTeamVFileDescriptor
        "Answer whether the receiver is an instance of class
         isPARTSTeamVFileDescriptor or one of its subclasses."
    ^false! 
partWrapper
        " Answer the PARTS wrapper of the receiver. "

    ^wrapper!   
evaluateWithArguments: evaluationArguments
        "Answer the result of evaluating the receiver with
        the given evaluationArguments."
    | result |
    result := receiver
        perform: realSelector
        withArguments: ( Array
            with: selector
            with: ( self collectArguments: evaluationArguments ) ).
    resultAction notNil
        ifTrue: [ result := resultAction evaluateWithArguments: ( Array with: result ) ].
    ^result! 
defaultText
    "Private"
    ^self fileName,' could not be found on the PARTS search path.'!   
keepInExecutable: aBoolean
    "Set whether wrappers should be included in
    executable applications"

    KeepInExecutable := aBoolean!
evaluate
        "Answer the result of firing the receiver with no evaluation arguments."

    ^self evaluateWithArguments: #()!   
withAllDependents: aCollection
        " Private - add the receiver and all its
        dependent links to aCollection. "

    aCollection add: self.
    messageArgLinks isNil
        ifFalse: [
            messageArgLinks do: [ :anArgumentLink |
                ( anArgumentLink notNil
                and: [ anArgumentLink isInternalArgumentLink not ] )
                    ifTrue: [ anArgumentLink withAllDependents: aCollection ] ] ].
    resultLink notNil
        ifTrue: [ resultLink withAllDependents: aCollection ].!  
uniqueMessageForReceiver
    "Answer a unique message for the receiver by
    concatenating the receiver name to the selector"
    | aSelector |

    selector isInteger
        ifTrue: [ ^selector ].  "Argument"

    aSelector := selector asString.
    aSelector at: 1 put: aSelector first asUpperCase.
    ^( receiver partName, aSelector ) asSymbol!  
componentNames
        " Answer the names of all components in the application. "

    | names |
    names := componentDictionary keysAsArray.
    ^names reject: [ :aName |  " filter internal implementation parts "
        ( componentDictionary at: aName ) isPARTSTransientPart ].!   
setFrom: aLink
    "Private - Set the receiver's instance variables
    from <aLink>"

    editState := aLink editState.
    receiver := aLink receiver.
    resultLink := aLink resultLink.
    selector := aLink selector.
    source := aLink source.
    traceFire := aLink traceFire.
    trigger := aLink trigger.

    ( messageArgLinks := aLink messageArgLinks ) size > 0
        ifTrue: [
            messageArgLinks do: [ :anArgLink |
                anArgLink source: self ]]!
fileDescriptor
	"Answer the file descriptor on which the receiver was initiated."

    ^fileDescriptor!
COMMENT
"
PARTSIniFile reads and writes the PARTS.INI
settings file.  In the delivery environment, only
the search path setting is used.  In the workbench
environment, all settings values are used.

PARTSIniFile is a private class.  Public protocol
for accessing settings values is provided by the
workbench PARTSSettings class.  Public protocol
to locate files in the PARTS search path is provided
in both the workbench and delivery environments
by PARTSFile.

"!
eventTable: anEventTable
        " Private - for mirrorCopy only "

    eventTable := anEventTable.!   
part: anObject
        " Private - specify the part to which the receiver's script belongs. "

    part := anObject.!  
isPathName: aFileReference sameAsDirectory: directory
    " Answer whether the fully-qualified file name
    of aFileReference is the same as that file in directory. "
    | fileReferenceDirPath |

    fileReferenceDirPath :=
        aFileReference asString asFileSystemPath parentPath.
    ( directory absolutePath asString asUpperCase =
        fileReferenceDirPath asString asUpperCase )
        ifFalse: [
            self
                warningPathConflict: aFileReference asString
                withDirectory: directory.
            ^false ].
    ^true!  
writerClass
		" Answer the name of the class which
		can write the application in this file version. "

	^writerClass!
reuseMode
        " Answer the application's reuse mode. "

    ^reuseMode!
lafExplainSourceIn: containingApplication
        " Private "

    | obj triggerLink |
    self isResultLink
        ifTrue: [
            triggerLink := source.
            obj := triggerLink destinationObject.
            ^'result of ',
            ( containingApplication componentNameOf: obj ifAbsent: [ '*Invalid component*' ]) ,
                ' "', triggerLink selector, '" message' ].

    self isArgumentLink
        ifTrue: [
            ^( containingApplication componentNameOf: source destinationObject ifAbsent: [ '*Invalid component*' ] ),
            ' ', ( source messageArgumentName: trigger ), ' argument' ].

    obj := self sourceObject.
    obj isPARTSApplication
        ifTrue: [ ^'internal "', trigger, '" event' ].

    ^( containingApplication componentNameOf: obj ifAbsent: [ '*Invalid component*' ]),
        ' "', trigger,  '" event'!
pathPointsOriginLeftBottom: anArrayOfPoints
        " Specify the position points of the link's path, specified
        as relative offsets from the launch point.  The offset points
        in anArrayOfPoints are defined in a coordinate system whose
        origin is at the leftBottom corner. "
    anArrayOfPoints isNil ifTrue: [ ^self ].
    pathPoints := ( PARTSHostInterface hostCoordinateSystemOrigin = #leftBottom
        ifTrue: [ anArrayOfPoints ]
        ifFalse: [ anArrayOfPoints collect: [ :aPoint | aPoint x @ aPoint y negated ] ] ).!  
loadFrom: readStream context: loadContext
        "Private - load the application from readStream."
    self implementedBySubclass! 
scaleRectangle: aRectangle
        " Private - answer <aRectangle> scaled by the current scaleFactor. "

    ^(aRectangle origin * scaleFactor) rounded
        extent: (aRectangle extent * scaleFactor) rounded!
componentScripts
        "Private - Answer the application components' script
        dictionaries.  This information is only valid for
        executable applications (because the wrappers are
        stripped.)"

    ^property componentScripts!  
cycleFile: aFileReference
    "Private - Set the file that exists twice in the application tree"
    cycleFile := aFileReference!   
useLeftStretched: boolean
    "Private - If boolean is true then make the
     left stretchable to the containing frame."

    mask :=
        ( boolean
            ifTrue: [ mask bitOr: 2r01000000]
            ifFalse: [ mask bitAnd: 2r10111111 ] )! 
changeRectangle: aRect in: aControl
        "Change receiver's rectangle to aRect (in pixel units).
         aControl is the control containing the receiver.
         The receiver's mask stays the same."

    self changeRectangle: aRect
        relativeTo: ( aControl superWindow isNil
            ifTrue: [ Display boundingBox ]
            ifFalse: [ aControl superWindow freeClientArea ] )! 
exists
    "Answer whethe the receiver has a physical representation."

    ^self class exists: self fileName in: self directory!  
canTriggerEvent: eventName
    "Answer <true> if the receiver can trigger an event
     named <eventName>.  Allow everything to be
     registered because we don't want to load application
     at this time just to do the checking. "
    ^true! 
referencedPartsProperty
        " Private - answer the string value of the referencedParts
        property of the receiver. "

    | propertyString |
    propertyString := WriteStream on: String new.
    self referencedParts
        do: [ :aFileName | propertyString nextPutAll: aFileName ]
        andBetweenDo: [ propertyString nextPutAll: ' ' ].
    ^propertyString contents!  
changeRectangle: aRect relativeTo: parentRect
        "Change receiver's rectangle to aRect (in pixel units).
         parentRect is the Rectangle containing the receiver.
         The receiver's mask stays the same."
"Transcript cr; show: 'CHANGE ', aRect printString, ' PA ', parentRect printString."
    ( parentRect width = 0 or: [parentRect height = 0] )
        ifTrue: [^self].
    left := self isLeftInset
        ifTrue: [ self horizontalInsetFrom: parentRect left to: aRect left ]
        ifFalse: [
            self isRightInset
                ifTrue: [ aRect width ]
                ifFalse: [ self horizontalInsetFrom: parentRect left to: aRect center x ]    "center"
            ].
    left := self isLeftStretched
        ifTrue: [ left / parentRect width ]
        ifFalse: [ self pixelToScaleUnitHorizontal: left ].

    right := self isRightInset
        ifTrue: [ self horizontalInsetFrom: aRect right to: parentRect right ]
        ifFalse: [ aRect width ].
    right := self isRightStretched
        ifTrue: [ right / parentRect width ]
        ifFalse: [ self pixelToScaleUnitHorizontal: right ].

    top := self isTopInset
        ifTrue: [ self verticalInsetFrom: parentRect top to: aRect top ]
        ifFalse: [
            self isBottomInset
                ifTrue: [ aRect height ]
                ifFalse: [ self verticalInsetFrom: parentRect top to: aRect center y ]    "center"
            ].
    top := self isTopStretched
        ifTrue: [ top / parentRect height ]
        ifFalse: [ self pixelToScaleUnitVertical: top ].

    bottom := self isBottomInset
        ifTrue: [ self verticalInsetFrom: aRect bottom to: parentRect bottom ]
        ifFalse: [ aRect height ].
    bottom := self isBottomStretched
        ifTrue: [ bottom / parentRect height ]
        ifFalse: [ self pixelToScaleUnitVertical: bottom ].!   
fileVersion: aVersion
        " Private - specify the PARTS version of the application file being processed. "

    fileVersion := aVersion.!  
linkReferencedIn: aPARTSApplication
        "Private - answer the link that the receiver references."
    | part links |
    part := aPARTSApplication componentNamed: partName.
    links := part partLinksForEvent: event.
    ^links at: index ifAbsent: [ nil ]! 
startTimer: aTimer interval: anInteger
        " Start aTimer with the specified interval (msec).
        Answer the timer's id. "
    | id |

    ( PARTSTimer isNil
    or: [ PARTSTimer isValid not ] )
        ifTrue: [ PARTSTimer := self new open ].

    id := PARTSTimer getId: aTimer.
    Time
        startTimer: id
        period: anInteger
        forWindow: PARTSTimer.
    ^id!  
shrinkMerge
    "Private - Make first level components relative to
    minimum bounding box.  The effect of doing this is
    that all the framers are not dependent on the editor
    extent any more.
        Don't shrink top level windows in nested parts so
    that they aren't affected by nested part sizing."
    | obj oldRect newRect parentIsNestedPart canInclude wrapperParent icon iconOffset tempOffset |

    editorState isShrunk ifTrue: [^self].

    oldRect := 0@0 extent: self editorVirtualScreenExtent.
    newRect := wrapper rectangle.
    wrapperParent := wrapper parent.
    parentIsNestedPart :=
        ( wrapperParent notNil and: [
            wrapperParent object isPARTSNestedPart ]).
    iconOffset := newRect topLeft negated.
    wrapper components do: [:wrap |
        obj := wrap object.
        canInclude :=
            ( parentIsNestedPart and: [
                ( obj partRelativeToParent: wrapperParent object ) not ]) not.
        canInclude
            ifTrue: [
                ( obj partIsWindow or: [ obj partIsShrunk ])
                    ifTrue: [
                        obj framingBlock:
                            (obj framingBlock
                                changeContainingRect: oldRect
                                to: newRect ).
                        icon := obj partShrunkenIconAttribute ]
                    ifFalse: [ icon := wrap icon ].
                icon notNil
                    ifTrue: [
                        tempOffset :=
                            self partsIfOS2Do: [
                                iconOffset up:
                                    ( icon isPARTSTextIcon
                                        ifTrue: [ icon class height ]
                                        ifFalse: [ PARTSIcon iconSize y ])]
                            partsIfWindowsDo: [ iconOffset ].
                        icon origin: ( icon origin moveBy: tempOffset ).  "TextIcon requires origin:"
                        ( obj partIsShrunk or: [ obj partIsWindow not ])
                            ifTrue: [
                                wrap rectangle isPARTSRectangle
                                    ifTrue: [ wrap rectangle moveBy: tempOffset in: newRect ]
                                    ifFalse: [ wrap rectangle moveBy: tempOffset ]]]]].
    editorState isShrunk: true.
! 
runtimeCloneFor: newSource
        " Private - answer a clone of the receiver which will
        be triggered by <newSource> at application execution
        time.  Any references to the original source
        object in the link net anchored by this event
        link should be replaced by a reference to
        the <newSource>. "

    ^self runtimeCloneWith: newSource object replacing: source object! 
helpTopic
        " Answer the topic name for the receiver's context-sensitive
        help in its workbench/catalog help file. "

    ^wrapper notNil ifTrue: [ wrapper helpTopic ] ifFalse: [ '' ]! 
asNumber: aValue
        " Private - answer aValue as a number. "
    aValue isNumber
        ifTrue: [ ^aValue ].
    aValue isString
        ifTrue: [ ^aValue trimBlanks asNumber ].
    aValue isNil
        ifTrue: [ ^'' asNumber ].
    ^aValue     " probably an error, let it surface "! 
descriptionOfBottom
        "Answer a String describing the calculation of the bottom."
    | stream |
    stream := WriteStream on: String new.
    stream
        nextPutAll: 'bottom: ';
        nextPutAll:
            (self isBottomInset
                ifTrue: [ 'up from parent''s bottom by ']
                ifFalse: [ 'down from window top by '] );
        nextPutAll: bottom printString;
        nextPutAll:
            (self isBottomStretched
                ifTrue: [ ' of parent''s height']
                ifFalse: [ ' ', self scaleUnitPlural ] ).
    ^stream contents!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy componentDict aLiteral componentAssoc |

    copy := self class new: self size.
    aMirrorCopyDictionary at: self put: copy.
    copy
        byteCodeArray: byteCodeArray;
        classField: class;
        selector: selector;
        primitive: nil;
        info: info;
        type: self type.


    ( aMirrorCopyDictionary forExecutableFile
    or: [ aMirrorCopyDictionary forExecute
            and: [ aMirrorCopyDictionary forDebug not
            and: [ SessionModel current isRunTime ] ] ] )
        ifTrue: [  " drop source and part values; keep component dict for load binding "
            copy
                setSource: nil
                componentNameDictionary: ( self componentNameDictionary partMirrorCopy: aMirrorCopyDictionary)
                part: nil ]
        ifFalse: [
            copy
                setSource: ( self sourceString partMirrorCopy: aMirrorCopyDictionary )
                componentNameDictionary: ( self componentNameDictionary partMirrorCopy: aMirrorCopyDictionary)
                part: ( self scriptPart partMirrorCopy: aMirrorCopyDictionary ) ].

    " mirrorCopy the component assoc's; leave other literals alone "
    componentDict := self componentNameDictionary.
    1 to: self size do: [ :i |
        aLiteral := self at: i.
        ( aLiteral isAssociation
        and: [ ( componentAssoc := componentDict associationAt: aLiteral key ifAbsent: [ nil ] ) notNil ] )
            ifTrue: [
                "self ASSERT: aLiteral == componentAssoc."
                aLiteral := componentAssoc partMirrorCopy: aMirrorCopyDictionary ].
        copy at: i put: aLiteral ].
    ^copy!   
componentNamed: nameString
        " Answer the component named <nameString>. "

    ^componentDictionary at: nameString!  
internalArgumentLinkFor: aLink
    inputArgument: inputArgumentIndex
    messageArgument: messageArgumentIndex
        " Answer an internal argument link which gets
        the value for the <messageArgumentIndex>-th
        message argument of <aLink> from its 
        <inputArgumentIndex>-th event argument
        when <aLink> is fired. "

    ^self basicNew
        source: aLink;
        trigger: messageArgumentIndex;
        receiver: aLink;
        selector: inputArgumentIndex;
        initialize! 
partPrintOn: aStream
        " Append a string containing a description of the
        receiver and all its component parts to aStream. "

    | indent workbenchVersion |

    indent := '  '.
    workbenchVersion :=  PARTSFile currentVersionDescription.

    aStream
        nextPutAll: 'PARTS Application Description'; cr;
        nextPutAll: indent, 'Part file name: ',
            ( self fileDescriptor isNil
                ifTrue: [ '(none)' ]
                ifFalse: [ self fileDescriptor displayName ] ); cr;
        nextPutAll: indent, 'Workbench version: ',workbenchVersion; cr;
        cr.

    wrapper
        partPrintOn: aStream margin: indent;
        partPrintScriptsOn: aStream.

    self scenarioEditor notNil
        ifTrue: [ self scenarioEditor partPrintOn: aStream margin: indent ]!   
propertyManager

    "Answer the property handler for the application
    by triggering the #getPropertyHandler event."

    ^ self triggerInternalEvent: #propertyManager!  
asPARTSLinkFor: aWrapper event: anEvent
        "Private - answer a PARTSLink having the semantics of the receiver."
    | answer argument linkClass |
    linkClass := receiver partLinkClassFor: selector.
    answer := linkClass
        source: aWrapper
        trigger: anEvent
        receiver: receiver
        selector: selector.
    1 to: arguments size do: [ :i |
        argument := arguments at: i.
        argument notNil ifTrue: [
                "it is legal to save an app with incomplete links "
                answer addArgumentLink: ( argument asPARTSLinkFor: answer event: i ) ]].
    ^answer
!
allLinksInChain
        " Answer a collection containing any external argument
        and result links directly triggered by the receiver, in their
        firing order.  Traverse link chains to their ends.  Exclude
        internal argument links "

    | dependents |
    dependents := OrderedCollection new.
    messageArgLinks notNil ifTrue: [
        messageArgLinks do: [ :anArgLink |
            ( anArgLink notNil and: [
                anArgLink isInternalArgumentLink not ])
                ifTrue: [ dependents addAll: anArgLink allLinksInChain ] ] ].
    resultLink notNil
        ifTrue: [ dependents addAll: resultLink allLinksInChain ].
    ^dependents!  
scriptClassField
		" Answer the class which is installed in a script. "

	^PARTSScriptContext! 
partOpen: validate
        " Display the receiver when it is being edited
        in a PARTS Workbench. Do nothing for the application."!   
addNonvisualComponent: aNonvisualPart name: aString helpInfo: aHelpInfo icon: anIcon offset: anOffset
        "Private - add aNonvisualPart to the receiver at anOffset.
        anOffset is the offset from the upper left corner of the
        editing rectangle."
    | newWrapper iconOrigin editorVirtualScreenExtent |

    self addComponent: aNonvisualPart name: aString.
    iconOrigin := PARTSHostInterface hostCoordinateSystemOrigin = #leftBottom
        ifTrue: [
            editorVirtualScreenExtent := self editorVirtualScreenExtent.
            editorVirtualScreenExtent isNil ifTrue: [ editorVirtualScreenExtent := Display extent * 2 // 3 ].
            anOffset x @ (( editorVirtualScreenExtent y down: anOffset y ) down: anIcon extent y ) ]
        ifFalse: [ anOffset ].
    anIcon
        origin: iconOrigin;
        connection: aNonvisualPart.

    newWrapper := PARTSWrapper new
        object: aNonvisualPart;
        name: aString;
        rectangle: anIcon visibleFrame;
        helpInfo: aHelpInfo;
        yourself.
    self partWrapper addComponent: newWrapper.
    newWrapper
        parent: self partWrapper;
        icon: anIcon.
    aNonvisualPart partWrapper: newWrapper
!
<= aTimestamp
        "Answer true if the receiver is less than
         or equal to aTimestamp, else answer false."

    aTimestamp isNil ifTrue: [^false].
    ^super <= aTimestamp!   
recompileWith: aCompiler
        "Private- Recompile the receiver using aCompiler. Answer the result or nil
        if unable to recompile.  Not supported for scripts."

    ^nil!   
items
        " Answer the items in the receiver. "

    ^items isNil ifTrue: [ #() ] ifFalse: [ items ]!  
undoDelete: undoParm
        " Private - undo a delete operation on
    the receiver.  Only implemented for event
    links.  <undoParm> is the index of the link
    in the source's link sequence for the
    triggering event."
    | eventHandlers |

    self isEventLink
        ifFalse: [ ^nil ].

    (( eventHandlers := source eventHandlersAttribute at: trigger ) isEmpty
        or: [ eventHandlers size < undoParm ])
        ifTrue: [ ^nil ].

    eventHandlers at: undoParm put: self.!
changeDestinationProperties: newLink
        " Private - change the destination object or message of the 
        receiver.  Reset any argument links affected by a message 
        change.  The client is responsible for updating the
        link layout (editState). "

    | oldNumMsgArgs newNumMsgArgs oldArgLinks
      numEventArgs |

    receiver := newLink receiver.
    selector := newLink selector.

    oldNumMsgArgs := messageArgLinks size.
    newNumMsgArgs := newLink messageArgLinks size.
    newNumMsgArgs = oldNumMsgArgs
        ifTrue: [ ^self ].

    " preserve all existing argument links "
    oldArgLinks := messageArgLinks.
    messageArgLinks := newLink messageArgLinks.
    1 to: ( oldNumMsgArgs min: newNumMsgArgs ) do: [ :i |
        messageArgLinks at: i put: ( oldArgLinks at: i ) ].

    " add default wiring for new msg args to event args "
    numEventArgs := self numberOfEventArguments.
    ( newNumMsgArgs > oldNumMsgArgs
    and: [ numEventArgs > oldNumMsgArgs ] )
        ifTrue: [
            ( oldNumMsgArgs + 1 )
            to: ( newNumMsgArgs min: numEventArgs )
            do: [ :i | 
                messageArgLinks at: i 
                    put: ( PARTSLink 
                        internalArgumentLinkFor: self
                        inputArgument: i 
                        messageArgument: i ) ].
            ].! 
pattern
    ^ pattern!   
frameRectangle: aPARTSFramer
        " Specify the rectangle of the LAFEditor window "

    frameRectangle := aPARTSFramer isPARTSRectangle
        ifTrue: [ aPARTSFramer ]
        ifFalse: [ PARTSFramer forRectangle: aPARTSFramer in: nil ].
! 
COMMENT
"
A PARTSMirrorCopyDictionary is an identity dictionary
which is used to mirrorCopy a part.  It augments
dictionary behavior by adding additional attributes
which describe the desired outcome of the mirrorCopy
(an editable part, an executable part, a debuggable part).

"!  
currentVersion: aVersionString
        " Private - set the current version of the PARTS file format "

    ( self fileAccessorClass notNil
    and: [ ( self fileAccessorClass supportedVersions includes: aVersionString ) not ] )
        ifTrue: [ self error: 'unknown version' ].
    Version := aVersionString.
	self fileAccessorClass notNil
    	ifTrue: [ self fileAccessorClass initializeAccessorForCurrentVersion ].!
directory: aDirectory
    directory := aDirectory!   
asWriteStream
    | aFileName |

    "When storing an .exe, the actual workbench executable is a .pax"
    aFileName :=
        ( self fileType equalsIgnoreCase: self class fileTypeForExe type )
            ifTrue: [ fileName fileName, '.', self class fileTypeForExecutablePart type ]
            ifFalse: [ fileName ].

    ^[ (directory newFile: aFileName) asByteFileStream ]
        on: FileError
        do: [ :e | MessageBox warning: e description. nil ].!  
description
		" Answer a description of the file version
		(identifies the PARTS Workbench system which 
		created this file version. "

	^description!  
loadFrom: readStream context: loadContext
    "Answer an application from <readStream>"
    | application |
    application := PARTSFile applicationFrom:  readStream.
    application isNil
        ifTrue: [
            PARTSInvalidApplication signalForFile: readStream file pathName ].
    ^application!
link: aLink
        "Private - set the receiver's state to reference aLink."
   aLink isResultLink
        ifTrue: [ self resultLink: aLink ]
        ifFalse: [ self argumentLink: aLink ]!  
filePathName: pathNameString
        " Private - specify the full path name of the application file being processed. "

    filePathName := pathNameString.!   
scaleUnit: scaleUnit toPixelHorizontal: units
    "Answer the conversion of horizontal <units> in the
    <scaleUnit> measurement to pixels"

    scaleUnit = #twip
        ifTrue: [
            ^ units * Display horizontalPixelsPerInch / 1440 ].
    scaleUnit = #inch
        ifTrue: [
            ^ units * Display horizontalPixelsPerInch ].
    scaleUnit = #centimeter
        ifTrue: [
            ^ units * Display horizontalPixelsPerMeter / 100 ].
    ^units
!   
setAttributesOfPathName: aPathName
        " Set the extended attributes of the part file
        named aPathName.  Answer whether successful. "

    ^self fileAccessorClass setAttributesOfPathName: aPathName! 
fileAccessorClass: aClass
        " Private "

	FileAccessorClass := aClass.!  
applicationFromFile: aFileReference ifNone: aBlock
        " Answer the PARTS application stored in aFileReference,
        where aFileReference is a file on the PARTS search path.
        The application is in editable form and has not yet
        been enabled for execution.  Evaluate aBlock if not found. "

    ^self
        applicationFromFile: aFileReference
        in: ( self directoryContaining: aFileReference
            ifNone: [ ^aBlock value ] )! 
value: aRect
        "Answer a rectangle by scaling aRect to the receiver.
         This message is implemented so that the ScaledRectangle
         can be used in place of a framingBlock."
    ^self scaleFrom: aRect! 
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
arguments: anArray
        "Set the arguments array for the message.
        Supported for polymorphism with Message. "

    messageArgLinks := ( anArray size = 0
        ifTrue: [ nil ]
        ifFalse: [ anArray ] ).! 
removeId: timerId
        "Remove timerId and its associated timer part from items."
    items removeKey: timerId ifAbsent: []! 
partAsExecutableAction
        " Private - answer the receiver as an action for an executable
        PARTS application. "

    | aMessage |
    self isInternalArgumentLink
        ifTrue: [ ^CollectionAccessor for: selector ].
    aMessage := self executionMessageClass basicNew
        receiver: receiver;
        selector: selector;
        yourself.
    messageArgLinks notNil
        ifTrue: [
            aMessage arguments: (messageArgLinks
                collect: [ :anArgLink |
                    anArgLink notNil
                        ifTrue: [ anArgLink partAsExecutableAction ]
                        ifFalse: [ nil ] "Incomplete link" ] ) ].
    resultLink notNil
        ifTrue: [ aMessage resultAction:  resultLink partAsExecutableAction ].
    ^aMessage!   
dynamicEvents
        "Private - Answer a collection of selectors for the events supported
        by the contained application."

    self validateApplication.
    ^self application notNil
        ifTrue: [ self application externalEvents asSortedCollection asArray ]
        ifFalse: [ #() ]! 
canReadIcon
		" Answer whether the icon can be loaded
		from the part file by the current system. "

	^canReadIcon!   
virtualScreenExtent: anExtent
        "Private - Set the virtual screen extent of the editor pane in LAFEditor."

    extent := anExtent!  
fileType: aFileType
    fileType := aFileType asUpperCase!   
scaleMask
    "Private - Answer the attribute mask where
        bit 7 -- 0 left width, 1 left inset
        bit 6 -- 0 left fixed, 1 left proportional
        bit 5 -- 0 right width, 1 right inset
        bit 4 -- 0 right fixed, 1 right proportional
        bit 3 -- 0 top height, 1 top inset
        bit 2 -- 0 top fixed, 1 top proportional
        bit 1 -- 0 bottom height, 1 bottom inset
        bit 0 -- 0 bottom fixed, 1 bottom proportional
    When left width and right width then it's centered horizontally.
    When top height and bottom height then it's centered vertically.
    "

    ^mask!  
storeAsType: anExtension path: aPathName
    "Load the editable application represented by the receiver and
    save as a type denoted by <anExtension>, on <aPathName>.
    If <aPathName> is relative, it will be relative to Disk."
    | targetDescriptor extension |

    extension := anExtension trimBlanks.
    extension first = $.
        ifTrue: [ extension := extension copyFrom: 2 to: extension size ].

    targetDescriptor :=
        PARTSFileDescriptor
            pathName: self fileName
            in: ( Directory fromPath: aPathName ).
    targetDescriptor fileType: extension.
    targetDescriptor fileName: self fileName fileName,'.',extension.

    self storeOnPath: targetDescriptor.

! 
partEditor
        " Answer the PARTS Workbench in which the receiver is being edited. "

    ^editor! 
workbenchContainingFile: aFileReference
        " Private - answer the workbench window containing
       the PARTS application from the file named by aFileReference. "

    | fullPathName partsEditorClass editors |

    aFileReference isString
        ifTrue: [
            ( fullPathName := PARTSFile fullPathName: aFileReference ) isNil
                ifTrue: [ ^nil ].
            ^self workbenchContaining: fullPathName ].

    partsEditorClass := Smalltalk at: #PARTSEditor
        ifAbsent: [ ^nil ].
    editors := partsEditorClass editorsOnFile: aFileReference.
    ^editors notEmpty
        ifTrue: [ editors first ]
        ifFalse: [ nil ]!
isResultLink
        " Answer whether the receiver is a result link which
        is triggered with the result value of another link. "

    ^trigger = self class resultLinkTrigger! 
isHorizontallyCentered
    ^( self isLeftInset or: [ self isRightInset ] ) not!  
writeSettingsFileFor: aPARTSSettings newFile: aPathName
        " Store the current settings in the PARTS init file. "

    | searchPath installDirName prefixSize date
      accessor aValue |

    partsSettings := aPARTSSettings.
    colorValueDict := self class colorDictionary.

    " compute the install-dir-relative search path "
    searchPath := PARTSFile currentSearchPath collect: [ :aDir |
        aDir fullDirName].
    installDirName := Disk fullDirName.
    prefixSize := installDirName size.
    searchPath := searchPath collect: [ :dirName |
        ((dirName size > prefixSize)
        and: [(dirName copyFrom: 1 to: prefixSize) equalsIgnoreCase: installDirName])
            ifTrue: [
                dirName copyFrom: (prefixSize + 1)
                    to: (dirName size - 1)]
            ifFalse: [
                (dirName equalsIgnoreCase: installDirName)
                    ifTrue: ['.']
                    ifFalse: [
                        dirName copyFrom: 1 to: (dirName size - 1)]]].

    [ "Error handling block"
    stream := File newFile: aPathName.
    date := Date today.
    stream
        nextPutAll: 'REM ', aPathName; cr;
        nextPutAll: 'REM Last updated on ',
                date dayOfMonth printString,
                '-', (date monthName asString copyFrom: 1 to: 3),
                '-', (date year printString copyFrom: 3 to: 4),
                ' ', Time now printString; cr;
        cr.
    stream
        nextPutAll: self settingsFileSearchPathTag, ' = '.
    1 to: searchPath size do: [ :i |
        stream nextPutAll: (searchPath at: i).
        (i < searchPath size)
            ifTrue: [stream nextPutAll: ';']].
    stream cr; cr.

    self settingsFileParameters do: [ :array |
        accessor := array at: 3.   " inst var slot or accessor "
        aValue := ( accessor isInteger
            ifTrue: [ aPARTSSettings instVarAt: accessor ]
            ifFalse: [ aPARTSSettings perform: accessor ] ).
        stream nextPutAll: (array at: 1), ' = '.
        self
            writeValue: aValue
            type: (array at: 2).
        stream cr].

    stream
        cr;
        nextPutAll:
            self settingsFileDefaultScaleUnitTag,
            ' = ',
            aPARTSSettings defaultScaleUnit asString;
        cr.

    stream
        cr;
        nextPutAll:
            self settingsFileWrapperTag,
            ' = ',
            aPARTSSettings keepInExecutable asString;
        cr.

    stream close ] "Error handling block"
        on: Error
        do: [ :e |
            MessageBox warning: 'Error writing settings file.  File may be corrupted.'.
            stream close ].
!
versionString
		" Answer the version string which is stored in
		a PARTS file. "

	^versionString!
eventTableAttribute
        "Private - answer the eventTable instance variable.."

    ^eventTable !   
useAllStretched
    "Private - Make all sides stretched."

    mask := self maskForAllStretched!   
stopAllTimers
        " Stop all active timers "
    PARTSTimer notNil
        ifTrue: [ PARTSTimer stopAllTimers ].!  
isDebuggable
        " Answer whether the receiver can be debugged. "

    ^property executionState = 'debuggable'!
fileTypeForExe

    "^self fileTypeFor: 'EXE'"
    ^PARTSFileType type: 'EXE' pattern: '*.EXE' description: 'Executable (*.EXE)'!  
addApplicationAttributeMessagesTo: anExpression
        "Private - code generation - add message models to anExpression
        to set the properties of a rebuilt version of the receiver."
    anExpression
        addSelector: #partNameUnchecked: with: self partName;
        addSelector: #description: with: self description;
        addSelector: #partHint: with: self partHint;
        addSelector: #reuseMode: with: self reuseMode;
        addSelector: #title: with: self title;
        addSelector: #version: with: self version;
        addSelector: #fileDescriptor: with: self fileDescriptor;
        addSelector: #manufacturer: with: self manufacturer;

        addSelector: #editorState: with: self editorState;

        yourself
!
componentNameDictionary
        " Answer a dictionary which defines the part name
        name scope of the receiver's application. "

    ^sourceObject componentDictionary! 
componentNameOf: anObject
        " Answer the component name of <anObject>. "

    ^componentDictionary keyAtValue: anObject! 
canTriggerEvent: eventName
    "Answer <true> if the receiver can trigger an event
     named <eventName>. "

    ^( self externalEvents includes: eventName asSymbol )!  
linkResultTo: aPart message: messageName
        " Create and install a result link from the receiver
        which sends the message named <messageName> to <aPart>.
        Answer the new result link. "

    | messageSelector aLink |
    messageSelector := messageName asSymbol.
    aLink := ( aPart partLinkClassFor: messageSelector )
        source: self
        trigger: self class resultLinkTrigger
        receiver: aPart
        selector: messageSelector.
    resultLink := aLink.
    ^aLink!  
resultLink
        "Private - answer the sub link reference for the receiver's
        argument link."
    ^PARTSSublinkReference new
        parentReference: self;
        index: 0
! 
receiver: receiverObject
        "Private - set the receiver of this link."

    receiver := receiverObject!   
hash
        " Answer whether hash of the receiver. "

    ^self date hash + self time hash!   
convertLinkMessagesToPARTSLinks
        "Private - convert all the link messages in the receiver's object's
        event table to PARTSLinks."
    | actions partsLink |
    object eventsHandled copy do: [ :event |
        actions := object actionListForEvent: event.
        actions copy do: [ :action |
            action "isLinkMessage" isMessage ifTrue: [  "CG produces only LinkMessages."
                partsLink := action asPARTSLinkFor: self event: event.
                self addLink: partsLink.
                object removeAction: action forEvent: event ]]].
    self components do: [ :subwrapper | subwrapper convertLinkMessagesToPARTSLinks ]
! 
separators
        " Answer the separators in the receiver. "

    ^separators isNil ifTrue: [ #() ] ifFalse: [ separators ]!  
messageArgumentName: index
        " Answer the name of the <index>-th message argument. "

    ^( self keywordsIn: selector ) at: index!  
handlesType: aType

    ^ type equalsIgnoreCase: aType! 
descriptionOfTop
        "Answer a String describing the calculation of the top."
    | stream |
    stream := WriteStream on: String new.
    stream
        nextPutAll: 'top: ';
        nextPutAll:
            (self isTopInset
                ifTrue: [ 'down from parent''s top by ']
                ifFalse: [ 'up from window bottom by '] );
        nextPutAll: top printString;
        nextPutAll:
            (self isTopStretched
                ifTrue: [ ' of parent''s height']
                ifFalse: [ ' ', self scaleUnitPlural ] ).
    ^stream contents!
for: anOperation
        " Answer a MirrorCopy dictionary for <anOperation>. "

    ^self for: anOperation initialSize: self defaultInitialSize!   
loadForEditWithContext: aContext
    "Load the part described by the receiver to be edited.
    <loadContext> can specify a debugger."
    | aStream application processor |

    ( processor := self fileProcessor )
        isNil ifTrue: [ ^ nil ].
    ( aStream := self asReadStream ) isNil
        ifTrue: [ ^nil ].
    [ application := processor
        loadFrom: aStream
        context: aContext ]
            ensure: [ aStream close ].
    ^ application!   
owner
        " Private - answer the owner of this PARTS application file processing operation. "

    ^owner! 
iconFrom: aFileStream
        "Answer the icon stored on aFileStream.   The client must set the
        file name of the icon connection. "
    ^PARTSFile iconFromPARStream: aFileStream

! 
defaultScaleUnit
    " Currently supported unitSymbols are
        #twip, #inch, and #pixel."

    ^DefaultScaleUnit! 
isFile: aFileReference inAnyOf: directoryList
        "Answer whether aFileReference's directory is in directoryList.
         Note that we do not check whether the file exists."

    | fileDirectory |
    fileDirectory := self
        directoryOf: aFileReference asString
        default: Disk.
    directoryList detect: [ :aDir | aDir = fileDirectory ]
        ifNone: [ ^false ].
    ^true!   
leftTopEventLabelOriginLeftBottom: aPoint
        " Specify the offset of the top left corner of the link's event label
        from the path's launch point.   The delta value aPoint is specified
        in terms of a coordinate system with its origin at the leftBottom. "
    aPoint notNil
        ifTrue: [ leftTopEventLabel := aPoint x @ aPoint y negated ]! 
prepareToStoreApplication: anApplication
        " Private - put <anApplication> into the appropriate state
        to be stored in a file. "

    properties := IdentityDictionary new.
    properties
        at: #icon put: anApplication icon;
        at: #fileDescriptor put: anApplication fileDescriptor;
        at: #libraryDependencies put: anApplication libraryDependencies;
        yourself.
    anApplication
        icon: nil;  " store once in header; reset when loaded "
        fileDescriptor: nil;  " bash local dependency (reset when loaded) "
        libraryDependencies: nil.  " set when loaded "!   
isNestedApplication
        " Answer whether the receiver is currently contained
        within a nested part in another application. "

    ^self parent notNil! 
externalMessages
        " Answer the set of messages that may be sent to this application. "

    ^externalMessages isNil
        ifTrue: [ #() ]
        ifFalse: [ externalMessages ]!
partHasOtherEvents
        " Answer whether the receiver can be asked
        for events other than what it has already
        provided in its partEvents. "

    ^false!   
loadForExecute
    "Load the part described by the receiver to be executed.
    <loadContext> can specify a debugger."

    ^self loadForExecuteWithContext:
        ( PARTSLoadContext new
            fileDescriptor: self;
            yourself )!  
unshrink
    "Private - Change first level components from being
    relative to the application minimum box to being relative
    to the receiver's editor."

    | oldRect newRect canInclude topLevel |
    editorState isShrunk ifFalse: [^self].

    newRect := 0@0 extent: self editorVirtualScreenExtent.
    oldRect := self rectangle.
    self children do: [:obj |
        canInclude := obj isPARTSWindow
            ifTrue: [
                "Include if the window is a direct child of the desktop or a child
                    of another window.  Don't include if w.b. location is in a window
                    but a desktop child during runtime."
                "Depending of timing of mirror copy, top level's parent is nil or editor pane."
                topLevel := obj partNonNestedPartParent: self parent.
                ( topLevel isPARTSEditorPane
                    or: [ topLevel isNil
                    or: [ obj partIsDesktopChild not ]])]
            ifFalse: [ obj partHasVisualParts ].
        canInclude
            ifTrue: [
                obj framingBlock:
                    (obj framingBlock
                        changeContainingRect: oldRect
                        to: newRect )]].
    editorState isShrunk: false.!   
buildApplication: anApplication
        "Private - build anApplication."
    self implementedBySubclass!
dependentLinks
        " Answer a collection containing any argument and result
        links directly triggered by the receiver, in their firing order. "

    | dependents |
    dependents := OrderedCollection new.
    messageArgLinks notNil ifTrue: [
        messageArgLinks do: [ :anArgLink |
            anArgLink notNil
                ifTrue: [ dependents add: anArgLink ] ] ].
    resultLink notNil
        ifTrue: [ dependents add: resultLink ].
    ^dependents!
partAsScript
        "Private - answer a PARTSScript which has the same attributes as the receiver."
    | answer |
    answer := self copy.
    answer
        methodDictionaryArray: PARTSScript methodDictionaries;
        classField: answer class scriptClassField.
    ^answer! 
activeTimers
        " Answer all the currently running timers "
    ^PARTSTimer isNil
        ifTrue: [ #() ]
        ifFalse: [ PARTSTimer activeTimers ]!  
partWrapper: aWrapper
        " Private - set the PARTS wrapper of the receiver. "

    wrapper := aWrapper!   
hasExternalEvent: aSymbol
        " Answer whether <aSymbol> is an external event of this application "

    ^self externalEvents includes: aSymbol!   
right: value
    right := value! 
componentDictionary: aDictionary
        " Private - set the componentDictionary. "

    componentDictionary := aDictionary.!  
enableExecution: makeDebuggable
        " Prepare the receiver to be executed or debugged. "

    makeDebuggable
        ifTrue: [ self isDebuggable ifTrue: [ ^self ] ]  " already debuggable "
        ifFalse: [ self isExecutable ifTrue: [ ^self ] ].  " already executable "
    self isEditable
        ifFalse: [ self error: 'Application must be editable to enable execution' ].
    self partWrapper enableExecution: makeDebuggable.
    property executionState: ( makeDebuggable
        ifTrue: [ 'debuggable' ]
        ifFalse: [ 'executable' ] ).! 
fileType
    "Answer the file type processed by the instance
    of the receiver."

    ^Array with: ( PARTSFileDescriptor fileTypeForExecutablePart )!   
currentVersion
        " Answer the current version of the PARTS file format "

    ^Version!  
canReadIcon: aBoolean
		" Specify whether the icon can be loaded
		from the part file by the current system. "

	canReadIcon := aBoolean.!
disableControls
        "Private - Disable the receiver."
    self disable! 
newApplication
        "Private - answer a newly created application."
    ^self applicationClass new!  
setAttributesInDirectory: aDirectoryName
        " Set the extended attributes of all part files
        in the directory named aDirectoryName.
        Answer a string describing the outcome. "

    | aDirectory partFileNames nUpgraded |
    aDirectory := Directory pathName: aDirectoryName.
    aDirectory valid
        ifFalse: [ ^aDirectoryName, ' is not a known directory.' ].
    partFileNames := aDirectory filesNamed: '*.par'.
    nUpgraded := 0.
    partFileNames do: [ :aFileName |
        ( self fileAccessorClass setAttributesOfFile: aFileName in: aDirectory )
            ifTrue: [ nUpgraded := nUpgraded + 1 ].
        ].
    ^'Successfully set the extended attributes on ',
        nUpgraded printString, ' of the ',
        partFileNames size printString,
        ' part files in ', aDirectoryName!   
isRightStretched
    "Private - Answer true if the right is stretchable."

    ^(mask bitAnd: 2r00010000) > 0! 
canEdit
	"Answer whether the application represented by the
	receiver can be edited on a workbench"

    ^false!  
eventTableForEdit
        "Private - Answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."

    eventTable isNil
        ifTrue: [ self eventTableAllocate ].
    ^eventTable at: 1!   
COMMENT
"
PARTSFile provides the public protocol for reading
PARTS application files.  Services are provided
for loading the application or its icon and for
reading the properties information (pairs of
name/value strings) of the application.

Applications loaded directly from the file through
PARTSFile are in their editable form.  To load
an application when it is being used as a part,
use the public services in PARTSApplication to
load the application in its executable form.

PARTSFile manages the PARTS search path
and provides services for locating files
in the search path directories.

PARTSFile provides the facilities for registering
change map specifications for loading
applications containing objects whose
class or shape has changed since the application
was created.
"! 
pathPointsFrom: aScaleUnit
        "Private - Answer the position points of the link's path.  The
    first point is the offset of the launch base point relative
    to the origin of the source object rectangle, in respect
    to the launchSide.  The control points a relative to the
    previous point.  The first control point is relative to the
    launchPlugTip.  The last point is the offset of the landing
    tip point relative to the target object rectangle, in respect
    to the landingSide.
        Since all links are in the same scale unit, use the scale
    unit of the application, stored externally from the receiver.
    Therefore, this information must be provided by <aScaleUnit>.
    The answer is always in pixels."

    pathPoints isNil ifTrue: [ ^Array new ].

    ^pathPoints collect: [ :aPoint |
        ( PARTSFramer scaleUnit: aScaleUnit toPixelHorizontal: aPoint x ) rounded @
            ( PARTSFramer scaleUnit: aScaleUnit toPixelVertical: aPoint y ) rounded ]! 
maskForAllStretched
    "Private - Mask for all sides stretched."

    ^2r11111111!
defaultText
    "Private"

    ^'File ',self filePathName,' does not exist.'!  
moveBy: aPoint in: parentRect
    "Private- Increment the receiver origin
     and corner by aPoint."
    

    self
        changeRectangle: (( self scaleFrom: parentRect ) moveBy: aPoint )
        relativeTo: parentRect
!   
anchorPointOn: aRect side: aSide
        " Private - answer the anchor point on aSide of aRect
        for computing delta location of path start. "
    ((aSide = SideLeft) or: [aSide = SideTop])
        ifTrue: [^aRect leftTop]
        ifFalse: [^aRect rightBottom]!