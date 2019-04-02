3.1.0.106
   
pattern: aString
        " Set the pattern string "
    pattern := ( aString isNil
        ifTrue: ['']
        ifFalse: [aString] ).!
alarm
        " Make an alarm sound. "
    self
        beep: 1800 for: 100;
        beep: 1 for: 1;
        beep: 1800 for: 100;
        beep: 1 for: 1;
        beep: 1800 for: 100;
        beep: 1 for: 1;
        beep: 1800 for: 100;
        beep: 1 for: 1;
        beep: 1800 for: 120;
        beep: 1 for: 1;
        beep: 1800 for: 150;
        beep: 1 for: 1;
        beep: 1800 for: 200.!
beep: integerFrequency for: integerDuration
        " Private - make some noise "

    | speakerLibrary |
    speakerLibrary := self speakerLibrary.
    speakerLibrary isValid 
        ifTrue: [ speakerLibrary beep: integerFrequency for: integerDuration ].!   
valueWith: aDictionary
        "Answer a String containing the elements
        of the receiver with parameter markers replaced by the
        elements of aDictionary. The nil elements are skipped."
    | pValue currentStart stream t sms ems |
    (self parameterPoints isNil or: [ self template trimBlanks isEmpty ])
        ifTrue: [ ^nil ].
    sms := self startMarker size.
    ems := self endMarker size.
    t := self template.
    currentStart := 1.
    stream := String new asStream.
    self parameterPoints do: [ : parm |
        " parm key = aPoint "
        " parm value = a parameter name "
        pValue := aDictionary at: parm value ifAbsent: [ '' ].
        stream nextPutAll: (t copyFrom: currentStart to: parm key x - sms).
        pValue notNil ifTrue: [
            stream nextPutAll: pValue asString ].
        currentStart := parm key y + ems].
    stream nextPutAll: (t copyFrom: currentStart to: t size).
    ^stream contents!  
pathNameOfFile: aFileName in: directoryName
        " Answer the fully qualified path name
        of aFileName relative to directoryName. "

    | pathInfo pathName |
    pathInfo := self resolveDirectoryName: directoryName.
    pathInfo isNil
        ifTrue: [ ^nil ].
    ( self directoryOn: (pathInfo at: 1) directoryPath: (pathInfo at: 2) ) isNil
        ifTrue: [ self triggerDirectoryExceptionEvent: directoryName ].
    pathName :=
        ( self driveNameString: ( pathInfo at: 1 ) ),
        ( pathInfo at: 2 ).
    aFileName = self dirNameSelf
        ifTrue: [ ^pathName ].
    aFileName = self dirNameSuper
        ifTrue: [ ^pathName fileNamePath ].
    pathName last ~= $\
        ifTrue: [ pathName := pathName, '\' ].
    ^pathName, aFileName!   
quotient: magnitude1 and: magnitude2
        " Answer the quotient of magnitude1
        divided by magnitude2. "

    ^[ (self asNumber: magnitude1)
        / (self asNumber: magnitude2) ]
            on: ZeroDivide
            do: [ ^self divideByZeroErrorMessage ]!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^self
        mergeInterfaceHolder: self partEventsOfHolder
        value: self partEventsOfValue!   
startUp
        " Private "
    self speakerLibrary: nil.!  
endJob
        "End the current print job; if none started, raise an error event"
    jobStarted ifFalse: [^self errorEvent: 'Job not started'].
    jobStarted := false.
    self printer endPrintJob.!  
getDrive: aPathName
        " Private - answer the drive letter in aPathName. "
    | driveLetter |
    (aPathName size = 0)
        ifTrue: [^nil].
    driveLetter := aPathName at: 1.
    ((aPathName size > 1)   " must be 'x:...' string "
    and: [(aPathName at: 2) ~= $:])
        ifTrue: [^nil].
    ^driveLetter isLetter
        ifTrue: [driveLetter]
        ifFalse: [nil]!
setDuration: integerDuration
        " Set the duration for the speaker tone. "
    duration := self asInteger: integerDuration.!   
stringTemplate: aST
        " Private - "
    stringTemplate := aST!
generateEvent: boolean
        "Private - generate the event corresponding to boolean."
    self triggerEvent: (boolean ifTrue: [#true] ifFalse: [#false]).
    ^boolean!  
asUpperCase: aValue
        " Answer aValue as a string with all uppercase letters. "
    aValue isString
        ifTrue: [ ^aValue asUpperCase ].
    aValue isNil
        ifTrue: [ ^'' ].
    aValue isCollection
        ifTrue: [ ^aValue collect: [ :each | self asUpperCase: each ] ].
    ^aValue!
style: anIconStyleConstant
        " Private "
    super style: MbOk | anIconStyleConstant! 
subdirectoriesIn: aPathName
        " Answer the unqualified names of the
        subdirectories of aPathName. "

    | pathInfo directory |

    pathInfo := self resolveDirectoryName: aPathName.
    pathInfo isNil
        ifTrue: [ ^#() ].

    directory := self
        directoryOn: (pathInfo at: 1)
        directoryPath: (pathInfo at: 2).
    directory isNil
        ifTrue: [
            self triggerDirectoryExceptionEvent: aPathName.
            ^#() ].

    ^[ ( directory subdirectories
        collect: [ :a | a last ] )
            asSortedCollection asArray ]
                on: Error do: [ :e |
                    self triggerOperationExceptionEvent: e description.
                    #() ]!
difference: magnitude1 and: magnitude2
        " Answer magnitude1 minus magnitude2. "
    ^(self asNumber: magnitude1)
        - (self asNumber: magnitude2)! 
sortedAscending: aCollection
        " Answer the elements of the collection
        sorted in ascending order. "
    | sorted |
    sorted := SortedCollection new ascendingOrder.
    sorted addAll: aCollection.
    aCollection isString
        ifTrue: [^(String new: aCollection size)
            replaceFrom: 1
            to: aCollection size
            with: sorted asArray].
    ^sorted asArray!  
keyExceptionEvent
        " Private "
    ^#indexException:!
valueCopy
    ^self value copy!  
initialize
        " Private - initialize the class "

    | platformDll |
    platformDll := ( self
        partsIfOS2Do: [ #DosLibrary ]
        partsIfWindowsDo: [ #KernelLibrary ] ).
    ( platformDll isNil
    or: [ ( (Smalltalk at: platformDll ) class compiledMethodAt: #beep:for:)  isNil ] )
        ifTrue: [ self error: 'platform problem' ].
    PlatformLibrary := platformDll.! 
exists: aPathName
        " Answer whether the file named aPathName exists.
        Triggers existsTrue: event if it does. "
    | exists |
    exists := [ File exists: aPathName ]
       on: Error do: [ :e |
            self triggerFileExceptionEvent: e description.
            ^false ].
    exists
        ifTrue: [ self triggerEvent: #existsTrue: with: aPathName ].
    ^exists!  
dialogBoxCreate
        " Private - answer a dialog box for the receiver. "
    ^PARTSPrompter new
        removeBlanks: self removeBlanks;
        closedAction: self dialogClosedAction;
        yourself! 
font
        "Answer the receiver's font"
    ^font isNil
        ifTrue: [ SysFont ]
        ifFalse: [ font ]!  
logicalAnd: aBoolean and: anotherBoolean
        " Answer the logical AND of aBoolean and anotherBoolean. "
    ^[ (self asBoolean: aBoolean)
        & (self asBoolean: anotherBoolean) ]
            on: Error
             do: [ ^self nonBooleanParametersErrorMessage ]!
showKeys: aBoolean
    showKeys := aBoolean! 
incrementValue
        " Increment the value by one. "
    value := value + 1.
    self triggerChangedEvent.
    ^value!  
negated: aNumber
        " Answer the numeric negation of aNumber. "
    ^(self asNumber: aNumber) negated! 
asString
    ^self value asString!   
keySetMessageName: aKey
        " Private "
    ^('set', aKey, ':') asSymbol!   
template: aString
    template := aString.
    self
        clearTemplate;
        parseTemplate! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #knownDrives
            #setDirectory: #pathName #subdirectories #files
            #pattern #setPattern:
            #pathNameOfFile: #pathNameOfFile:in:
            #subdirectoriesIn:
                #filesIn: #filesIn:matching: #filesMatching:
            #driveName: #directoryPath: #directoryName:
            #exists: #create: #delete:
            )
        separators: #( 1 5 7 9 13 16 )
        defaultItem: #setDirectory:! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>, dropping the id.  
        Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
    copy
        partWrapper: (wrapper partMirrorCopy: aMirrorCopyDictionary);
        eventTable: (eventTable partMirrorCopy: aMirrorCopyDictionary);
        interval: interval copy.
    ^copy!   
partMessagesProperties
        " Private - answer the PARTS message interface of the receiver
       for the property accessing sections of the protocol. "

    ^( PARTSInterfaceList new
            items: #(
                #promptMessage #setPromptMessage:
                    #defaultMessage #setDefaultMessage:
                    #removeBlanks #setRemoveBlanks:
                ) )
        concatenate: super partMessagesProperties
        defaultItem: #defaultMessage! 
asLowerCase: aValue
        " Answer aValue as a string with all lowercase letters. "
    aValue isString
        ifTrue: [ ^aValue asLowerCase ].
    aValue isNil
        ifTrue: [ ^'' ].
     aValue isCollection
        ifTrue: [ ^aValue collect: [ :each | self asLowerCase: each ] ].
    ^aValue!   
initialize
        " Private "
    super initialize.
    self 
        title: 'title';
        text: 'message';
        style: MbIconInformation.!  
time: aPathName
        " Answer the last-written Time of the
        file named aPathName. "
    | info |

   ( self isValidFile: aPathName )
        ifFalse: [ ^'' ].

    info := [ ( File fromPath: aPathName ) lastModificationTime time ]
        on: Error do: [ :e | ^self triggerFileExceptionEvent: e description ].
    ^info
!
setRemoveBlanks: aValue
        " Specify whether leading and trailing blanks
        should be trimmed from the user's response. "

    | aBoolean |
    aBoolean := self asBoolean: aValue.
    aBoolean isBoolean
        ifFalse: [ ^self error: 'Must be true or false' ].
    self removeBlanks: aBoolean.
    ^aBoolean!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #true #false)
        defaultItem: #true!  
at: index put: obj
    ^self value at: index put: obj!   
abs: aNumber
        " Answer the absolute value of aNumber. "
    ^(self asNumber: aNumber) abs!   
currentDelimiters
        " Private "
    ^stringTemplate startMarker, ' ', stringTemplate endMarker!   
remainder: magnitude1 and: magnitude2
        " Answer the integer remainder of magnitude1
        divided by magnitude2 with truncation towards zero. "
    ^[(self asNumber: magnitude1)
        rem: (self asNumber: magnitude2)]
			on: ZeroDivide
            do: [ ^self divideByZeroErrorMessage ]!  
messagePrefix
        " Private "
    ^'set'!   
propertyClass
        " Answer the class to which a value which
        is put into this holder must belong
        (nil if no type checking is to be done). "
    ^class!
replaceFrom: start to: stop withObject: anObject
        "Replace each of the elements of the receiver
         at index positions start through stop with
         anObject.  Answer anObject."
    value replaceFrom: start to: stop withObject: anObject.
    showKeys ifTrue: [    " trigger element-changed events "
        1 to: value size do: [ :i |
            self triggerEvent: (self keyEventName: i) with: anObject.
            ]].
    ^anObject!   
new: aTemplate
    ^self new template: aTemplate!
itemGetMessage: aName
        " Private "
    ^aName asSymbol!  
value
        "Answer a String containing the elements
        of the receiver with parameter markers replaced by the
        elements set in the parameters dictionary.
        The nil value elements are skipped."
    ^self valueWith: self parameters!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #yes #no #cancel )
        defaultItem: #yes!  
printer: aPrinter
        " Private - set the printer "
    printer := aPrinter!
reportException: aString
    ^self triggerEvent: #exception:
        withArguments: (Array with: aString)
        ifNotHandled: [
            MessageBox
                notify: 'String Template'
                withText: aString ].!
partEventsOfHolder
        " Private "
    | standardInterface keyEvents |
    standardInterface := super partEventsOfHolder.
    standardInterface
        items: (
            standardInterface items,
            (Array with: self keyExceptionEvent)).
    (showKeys not or: [value size = 0])
        ifTrue: [^standardInterface].
    keyEvents := self keyEvents.
    ^PARTSInterfaceList new
        items: (standardInterface items, keyEvents)
        separators: (
            standardInterface separators,
            (Array with: standardInterface items size))
        defaultItem: keyEvents first! 
sessionShutdown
        " Private - perform the session #shutdown processing
        for the basic nonvisual parts runtime library. "

    PARTSSpeakerPart shutdown.!
partEventsOfValue
        " Private "
    | myEvents valueInterface valueEvents |
    self relayEventsFromValue
        ifFalse: [ ^nil ].
    myEvents := Set new
        addAll: Object eventsTriggered;
        addAll: self partEventsOfHolder items;
        yourself.
    valueInterface :=  ( self value isNil
        ifTrue: [ class basicNew ]
         ifFalse: [ self value ] )
            partEvents.
    valueEvents := valueInterface items
        reject: [ :anEvent | myEvents includes: anEvent ].
    valueEvents size = 0
         ifTrue: [ ^PARTSInterfaceList emptyList ].
    ^valueEvents size = valueInterface items size
        ifTrue: [ valueInterface ]  " retain original separators and order "
        ifFalse: [
            PARTSInterfaceList new
                items: valueEvents asSortedCollection asArray ]!
nonBooleanParametersErrorMessage
    " Private -  non-boolean parameters have been passed to a logical operation.
      Bring up a messagebox to warn the user and return nil . "

    MessageBox
        warning: ' Non-boolean parameters have been encountered.  Cannot continue the boolean operation. '.
    ^nil! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #beginJob
            #formFeed
            #print:
            #printScreen
            #printUserRectangle
            #endJob

			#printerSetup
            #selectAFont

			#defaultPrinterName
            #printerName
            #printerNames
            #setPrinterName:
            #selectAPrinter
        )
        separators: #( 6 8 )
        defaultItem: #print:!  
pathNameForSave: aString
        " Open the Save File dialog with aString
        as the default file name. "
    ^self saveFile: (self asString: aString)!
parameters
        " Private "
    ^self stringTemplate parameters! 
relayEventsFromValue
        " Private - answer whether events triggered
        by the contained value can be relayed to
        outgoing links in the receiver's application. "

    ^class notNil and: [ class ~~ Object ]  " class must be specified "!  
divideByZeroErrorMessage
    " Private -  a zero has been passed to an operation which caused a
      divide by zero error.  Bring up a messagebox to warn the user and return nil . "

    MessageBox
        warning: ' Division by zero has been encountered.  Cannot continue the computational operation. '.
    ^nil! 
subdirectories
        " Answer the unqualified names of the
        subdirectories of the current directory. "
    | currentDir subdirectories specialEntries |
    currentDir := self currentDirectory.
    [ subdirectories := ( currentDir subdirectories
        collect: [ :a | a last ] )
            asSortedCollection ]
               on: Error do: [ :e |
                    self triggerOperationExceptionEvent: e description.
                    ^#() ].
    specialEntries := ( directoryPath = self dirNameRoot
        ifTrue: [ Array with: self dirNameSelf ]
        ifFalse: [ Array with: self dirNameSuper with: self dirNameSelf ] ).
    ^specialEntries, subdirectories!   
partRealSelectorFor: aSelector
        " Private - Answer the message to send for an alias link
        to access a field of the current record. "

    ( self itemGetMessages includes: aSelector )
        ifTrue: [ ^#itemGet:arguments: ].
    ( self itemSetMessages includes: aSelector )
        ifTrue: [ ^#itemSet:arguments: ].
    ^aSelector! 
dialogAnswer: anAnswer
        " Private - the prompter has an answer. "
    anAnswer isNil
        ifTrue: [self triggerEvent: #cancel]
        ifFalse: [self triggerEvent: #pathName: with: anAnswer].!
escapeChar
    ^escapeChar!  
logicalOr: aBoolean and: anotherBoolean
        " Answer the logical OR of aBoolean and anotherBoolean. "
    ^[ (self asBoolean: aBoolean)
        | (self asBoolean: anotherBoolean) ]
            on: Error
            do: [ ^self nonBooleanParametersErrorMessage ]!   
startTimer
        " Start the timer.  Answer the current time. "
    interval isNil
        ifTrue: [ interval := self defaultInterval ].
    id := PARTSTimerWindow startTimer: self interval: interval.
    ^self currentTime!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #launchException: )
        defaultItem: #launchException:!
promptDefault: defaultString
        " Open the prompter dialog with the
        current prompt message and the given defaultString. "
    ^self prompt: prompt default: defaultString!
isValidObject: anObject
        " Private - answer whether anObject can be
        held by the receiver. "
    (class notNil
    and: [anObject notNil
            and: [(anObject isKindOf: class) not]])
        ifTrue: [  " type violation "
            self 
                triggerEvent: #valueException:
                withArguments: (Array with: anObject)
                ifNotHandled: [
                    MessageBox
                        notify: 'ValueHolder Problem'
                        withText:
                           'Cannot accept new value (class ',
                            class name, ' is required, but value is ',
                            anObject class name, ').' ].
            ^false].
    ^true!
classAttribute
       " Private - answer the class instance variable of the receiver. "

    ^class!   
trigger: aValue
        " Trigger the link junction, passing along aValue. "
    ^self triggerEvent: #triggered: with: aValue!  
copy: aPathName to: newPathName
        " Copy the contents of the file named aPathName
        to newPathName. "
    |  exception |
    exception:= false.
    ( self isValidFile: aPathName )
        ifFalse: [ exception:= true ].
    ( self isValidPathName: newPathName )
        ifFalse: [ exception:= true ].
    exception ifTrue: [ ^self ].
    [ File copy: aPathName to: newPathName ]
        on: Error do: [ :e | self triggerFileExceptionEvent: e description ]!
forClass: aClass
        " Answer a new instance of the receiver with type <aClass>. "

    ^super new initialize
        classAttribute: aClass;
        yourself!  
is: aValue lessThanOrEqualTo: anotherValue
        " Trigger the true event if aValue
        is less than or equal to anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue <= anotherValue)!  
executeProgram: cmdLine
        " Execute the command line. "
        " Platform dependent implementation "
    "VOS implementation:
    | aStream programName parameters |
    aStream := ReadStream on: cmdLine.
    programName := aStream upTo: Space.
    parameters := ( aStream atEnd
        ifTrue: ['']
        ifFalse: [aStream copyFrom: aStream position to: aStream size] ).
    ^self
        executeProgram: programName
        commandLine: parameters
    "
    " VW implementation "
    [ File execute: cmdLine ]
            on: Error
            do: [ :e | ^self triggerLaunchException: e description ].  "  cmdLine "!   
filesIn: directoryPathName
        " Answer the files in the directory named
        directoryPathName which match the
        current pattern. "
    ^self filesIn: directoryPathName matching: pattern! 
fileExtension: aPathName
        " Answer the file name extension of aPathName. "
    ^aPathName fileExtension trimBlanks!  
sizeThreshold
        " Answer the current size threshold. "
    ^sizeThreshold!
partMessagesTemplate
        " Private - standard template messages "
    ^PARTSInterfaceList new
        items: #(
            #value
            #template #setTemplate: )
        separators: #( 1 )
        defaultItem: #value!   
speakerLibrary
        " Private "
    ^SpeakerLibrary! 
isUpdatableFrom: aCollection
        " Private - answer whether the receiver's
        value can be updated from aCollection. "
    value isNil
        ifTrue: [
            self 
                triggerEvent: #valueException:
                withArguments: (Array with: aCollection)
                ifNotHandled: [
                    MessageBox
                        notify: 'ValueHolder Problem'
                        withText: 'Cannot update - value is nil' ].
            ^false].
    ^true! 
prompt: promptString default: defaultString
        " Open the prompter dialog with the
        given prompt message and default. "

    ^self openDialogMessage: ( Message
        receiver: self dialogBoxCreate
        selector: #prompt:default:
        arguments: ( Array
            with: ( self asString: promptString )
            with: ( self asString: defaultString ) ) )!   
propertyValue
        " for property dialog "
    ^value!   
setPattern: aString
        " Set the pattern string "
    self pattern: ( aString isString
        ifTrue: [ aString ]
        ifFalse: [ aString isNil ifTrue: [ '' ] ifFalse: [ aString asString ] ] ).
    ^aString! 
setDefaultMessage: aString
        " Specify the default string to display. "
    self defaultMessage: aString.
    ^aString!  
partEventsOfHolder
        " Private "
    ^PARTSInterfaceList new
        items: #( #changed: #valueException: )
        separators: #( 1 )
        defaultItem: #changed:! 
descriptionStringSize

	"Private - return the size for a description string"
    ^46!  
valueSample
        "Answer a String containing the elements
        of the receiver with parameter markers replaced by the
        elements set in the parameters type sample dictionary.
        The nil value elements are skipped."
    ^self valueWith: self parameterTypes!
files
        " Answer the unqualified names of the
        files of the current directory which match
        the current pattern string. "
    | currentDir |
    currentDir := self currentDirectory.
    ^[ (currentDir filesNamed: pattern)
        asSortedCollection asArray ]
            on: Error do: [ :e |
                self triggerOperationExceptionEvent: e description.
                #() ]!   
sum: magnitude1 and: magnitude2
        " Answer the sum of magnitude1 and magnitude2. "
    ^(self asNumber: magnitude1)
        + (self asNumber: magnitude2)!   
partMessagesParameters
        " Private - answer the message interface
        for parameter get/set messages "
    | getMessages setMessages |
    ((getMessages := self itemGetMessages) size = 0)
        ifTrue: [ ^PARTSInterfaceList emptyList ].
    setMessages := self itemSetMessages.
    ^PARTSInterfaceList new
        items: (getMessages, setMessages)
        separators: (Array with: getMessages size)
        defaultItem: (getMessages at: 1)!
selectAFont
        "Select a font from the list of known fonts for the current printer"
    | aFontDialog selectedFont |
    self printer.  " get one there isn't one yet "
    aFontDialog := FontDialog new
       sampleFont: self font;
        open.
    (selectedFont := aFontDialog chosen) notNil
        ifTrue: [self font: selectedFont].
    ^selectedFont! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #triggered: #triggerFailed: )
        defaultItem: #triggered:!
supportsNonSuspendedInvocation: aBoolean
        " Private - specify whether the suspendClient
        property can be turned off on instances of
        the reciever. "
    supportsNonSuspendedInvocation := aBoolean.!
atAllPut: anObject
        "Answer the array after each element
         has been replaced with anObject."
    ^self
        replaceFrom: 1
        to: value size
        withObject: anObject!
asFloat: aValue
        " Answer aValue as a float. "
    (aValue isString or: [aValue isNumber])
        ifTrue: [^aValue asFloat].
    aValue isNil
        ifTrue: [ ^'' asFloat ].
    aValue isCollection
        ifTrue: [^aValue collect: [ :each | self asFloat: each]].
    ^aValue! 
iconFileName
    "Private - Answer the file name of the icon used
    to represent the receiver in the catalog."

    ^'STRING.PAR'!  
partMessagesOfHolder
        " Private "
    ^super partMessagesOfHolder
        concatenateSeparated: (PARTSInterfaceList new
            items: #(
                #appendToValue:
                #setFromReference: ) )
        defaultItem: #value!   
defaultWildcardChar
    ^self patternClass wildcardChar! 
removePartRuntimeLibrary
        " Private - remove the basic nonvisual parts runtime library.
        Remove the workbench support library if it was installed. "

    self removeSessionEventHandlers.
    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).! 
size
    ^self value size!   
PARTSLinkJunctionPart removePartRuntimeLibrary!   
style: aButtonLabelConstant
        " Private "
    super style: MbIconQuestion | aButtonLabelConstant! 
newPattern
        " Private - "
    ^self class patternClass new:
        self startMarker, (String with: self wildcardChar), self endMarker! 
keyEvents
        " Private "
    | events |
    events := Array new: self size.
    1 to: self size do: [ :i |
        events at: i put: (self keyEventName: i)].
    ^events! 
isSetMessage: aString
        " Private "
    ^self implementedBySubclass!  
printerName: aString
        "Set the printer name to printerName."
    printerName := aString! 
triggerLaunchException: aString
        " Private "
    self triggerEvent: #launchException:
        withArguments: (Array with: aString)
        ifNotHandled: [MessageBox warning: aString].
    ^nil! 
defaultPrinterName
        "Answer the name of the default printer"
    ^Printer defaultPrinterName!
partMessagesOfHolder
        " Private "
    ^PARTSInterfaceList new
        items: #(
            #value #setValue: #valueCopy
            #valueIsNil #valueNotNil #valueIsEqual: #valueNotEqual:
            )
        separators: #( 3 )
        defaultItem: #value! 
initialize
        " Private - default tone is bell. "

    frequency := 800.
    duration := 200.
    ( SpeakerLibrary notNil and: [ SpeakerLibrary isValid ] )
        ifFalse: [ SpeakerLibrary := nil ].  "so that speaker library can be reopened."!   
forPWO20Dialog: originalDialog
        " Private - answer a new instance of the receiver
        with its properties set according to the values
        in originalDialog from PWO 2.0 PremadeDiag. "

    ^self new
        promptMessage: originalDialog prompt;
        defaultMessage: originalDialog default;
        removeBlanks: originalDialog withBlank not;
        yourself!
initialize
        " Private "

    super initialize.
    class := Dictionary.
    value := Dictionary new.
    showKeys := true.!  
buttonValues
        " Private - answer the values to associate with 
        each button on the dialog. "
    self implementedBySubclass! 
dialogClosedAction
        " Private "
    ^Message
        receiver: self
        selector: #dialogAnswer:
        arguments: (Array new: 1)!   
iconFileName
    "Private - Answer the file name of the icon used
    to represent the receiver in the catalog."

    ^'NUMBER.PAR'!  
partMessagesOfHolder
        " Private "
    | standardInterface keyMessages nKeys nStandard |
    standardInterface := PARTSInterfaceList new
        items: #(
            #value #setValue: #updateValue: #valueCopy
            #valueIsNil #valueNotNil #valueIsEqual: #valueNotEqual:
            )
        separators: #( 4 )
        defaultItem: #value.
    (showKeys not or: [value size = 0])
        ifTrue: [^standardInterface].
    keyMessages := self keyMessages.
    nKeys := keyMessages size.
    nStandard := standardInterface items size.
    ^PARTSInterfaceList new
        items: standardInterface items, keyMessages
        separators: (Array
            with: (standardInterface separators first)
            with: nStandard
            with: (nStandard + (nKeys // 2))
            "with: (nStandard + nKeys)" )
        defaultItem: keyMessages first! 
interval
        " Answer the timer interval (msec) "
    ^interval!
descriptionString: aPathName
        " Answer the a string describing the file
        named aPathName (name, size, date, attributes). "

    | descr aString |

   	( self isValidFile: aPathName )
        ifFalse: [ ^'' ].

    descr := WriteStream on: ( String new: self descriptionStringSize ).
    aString := aPathName fileNameLessPath.
    descr
        nextPutAll: aString;
        next: (12 - aString size) put: Space.
	aString := self size: aPathName.
    descr
        next: (8 - aString size) put: Space;
        nextPutAll: aString.
    descr
        space; space;
		nextPutAll: ( self dateTimeString: aPathName );
        space; space;
        nextPutAll: ( self fileAttributes: aPathName ).
    ^descr contents!
ring
        " Make a ring sound. "
    self
        beep: 900 for: 100;
        beep: 700 for: 100;
        beep: 900 for: 100;
        beep: 700 for: 100;
        beep: 900 for: 100;
        beep: 700 for: 100;
        beep: 900 for: 100;
        beep: 700 for: 100;
        beep: 900 for: 100;
        beep: 700 for: 100;
        beep: 900 for: 100.!
forPWO20Dialog: originalDialog
        " Private - answer a new instance of the receiver
        with its properties set according to the values
        in originalDialog from PWO 2.0 PremadeDiag. "

    ^self new
        pattern: originalDialog file;
        yourself!  
getAPrinter
        "There is no printer set, so get one (default if no name)"
    printerName isNil
        ifTrue: [printerName := self defaultPrinterName].
    self printer: ( Printer named: printerName )!  
filesMatching: patternString
        " Answer the files which match the patternString. "
    | patternStringOnly |
    patternStringOnly := patternString fileNameLessPath.
    ^self
        filesIn: (patternString
            copyFrom: 1
            to: (patternString size - patternStringOnly size))
        matching: patternStringOnly! 
asDate: aValue
        " Answer aValue as a date. "
    aValue isString
        ifTrue: [ ^[ aValue asDate ] on: Error do: [ ^nil ] ].
    aValue isCollection
        ifTrue: [^aValue collect: [ :each | self asDate: each]].
    ^aValue!
parseTemplate
        " Private - "
    | pattern loopIt currentTPos found name stream pType |
    self template trimBlanks isEmpty ifTrue: [
        self clearTemplate.
        ^self ].
    pattern := self newPattern.
    parameterPoints := OrderedCollection new.
    parameterTypes := Dictionary new.
    self parameters: Dictionary new.
    loopIt := true.
    currentTPos := 1.
    [ loopIt ] whileTrue: [
        pattern reset.
        found := pattern match: self template index: currentTPos.
        found isNil
            ifTrue: [ loopIt := false ]
            ifFalse: [
                currentTPos := found y.
                stream := self template copyFrom: (found x + 1) to: (found y - 1).
                stream := stream asStream.
                name := self parseParameterName: stream.
                parameterPoints add: (Association key: found value: name).
                (stream skipTo: self typeMarker) ifTrue: [
                    stream skip: 1.
                    pType := stream
                        copyFrom: stream position
                        to: (stream size "- (self endMarker size)").
                    pType isEmpty ifFalse: [
                        parameterTypes at: name put: pType ] ].
                self parameters at: name put: nil ] ].!  
initializeRuntimeData
		" Private - the library has just been installed.  Initialize state. "

	self partLibraryClassesToInitialize do: [ :aClass | aClass initialize ].!  
initialize
        " Private - initialize the class. "
    self supportsNonSuspendedInvocation:
        ( self partsIfOS2Do: [ true ] partsIfWindowsDo: [ false ] ).!  
printerNames
        "Answer a list of known printer names"
    ^Printer printerNames!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #pathName: #cancel )
        defaultItem: #pathName:!  
is: aValue lessThan: anotherValue
        " Trigger the true event if aValue
        is less than anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue < anotherValue)!
valueSample
        " Answer the template string with sample
        values substituted for all typed parameter references. "
    ^self stringTemplate valueSample!
partRealSelectorFor: aSelector
        " Answer the real message to send to the
        value for aSelector.  When aSelector is a key
        to an element in the collection, map it to
        the lookup or store method. "

    ^( showKeys
    and: [ self keyMessages includes: aSelector ] )
        ifTrue: [
            ( self isSetMessage: aSelector )
                ifTrue: [ #store:arguments: ]
                ifFalse: [ #lookup:arguments: ] ]
        ifFalse: [ super partRealSelectorFor: aSelector ]! 
valueNotNil
    ^value notNil!   
setDirectory: directoryName
        " Change the current position to directoryName,
        which can be either a fully qualified or
        relative path name of a directory. "
    | aDirName pathInfo directory newDriveLetter newDirectoryPath |
    aDirName := directoryName isNil ifTrue: [''] ifFalse: [directoryName trimBlanks].
    aDirName = self dirNameSelf
        ifTrue: [^directoryName].
    (pathInfo := self resolveDirectoryName: aDirName) isNil
        ifTrue: [^nil].
    newDriveLetter := pathInfo at: 1.
    newDirectoryPath := pathInfo at: 2.
    directory := self
        directoryOn: newDriveLetter
        directoryPath: newDirectoryPath.
    directory isNil
        ifTrue: [
            self triggerDirectoryExceptionEvent: directoryName.
            ^nil ].
    newDriveLetter = drive
        ifFalse: [
            drive := newDriveLetter.
            self triggerDriveChangedEvents ].
    directoryPath := newDirectoryPath.
    self triggerDirectoryChangedEvents.
    ^directoryName! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #sum:and: #difference:and: #product:and: #quotient:and:
            #modulo:and: #remainder:and:
            #abs:
            #logicalAnd:and: #logicalOr:and: #not:)
        separators: #( 4 6 7 )
        defaultItem: #sum:and:! 
initialize
        " Private "

    super initialize.
    class := String.
    value := 'a string'.! 
openOn: defaultFileName selector: aSelector

    "Private - bring up dialog"

    ^self openDialogMessage: (  Message new
        receiver: self dialogBoxCreate
        selector: aSelector
        arguments: ( Array with: defaultFileName )
    )!
setFromReference: anExternalAddress
        " Set value to a String from the null terminated string
        pointed to by anExternalAddress. "
     | flatAddr |

     self setValue:
        (String fromAddress:
            (flatAddr := anExternalAddress asFlatAddress)).

    self partsIfWindowsDo: [
        (anExternalAddress isKindOf: ExternalSegmentedAddress)
            ifTrue: [flatAddr releaseFlatAddress]]. "asFlatAddress makes allocations in Win95"

     ^value
!   
wildcardChar
    ^wildcardChar!  
pathNameForSave
        " Open the Save File dialog with default pattern
        as the default file name. "
    ^self saveFile: self pattern! 
removeSessionEventHandlers
        " Private - remove the session event handlers for the
        basic nonvisual parts runtime library
            PARTSLinkJunctionPart removeSessionEventHandlers
        "

    SessionModel current isRunTime
        ifFalse: [
            SessionModel current
                removeActionsWithReceiver: self
                forEvent: #startup ].
    SessionModel current
        removeActionsWithReceiver: self
        forEvent: #shutdown.!   
isSetMessage: aString
        " Private "
    ^((aString copyFrom: 1
            to: ('setElement' size min: aString size))
        = 'setElement')!  
launch: aCommandLineString
        " Launch a program as specified by
        aCommandLineString. "
    
    ( aCommandLineString isString not or:
    [ aCommandLineString isEmpty ] )
        ifTrue: [^self triggerLaunchException:
            'PARTS LaunchPad has an illegal command string.'].
    "DISABLE:   (turn off rocket launch display)
    activeWindow := Notifier activeMainWindow.
    activeWindow captureMouseInput.
    icon := PARTSFile iconFromFile: 'launchpd.par' ifNone: [nil].
    icon notNil
        ifTrue: [
            cursor := icon asPointer.
            DosLibrary sleep: 100.
            cursor changeFor: [
                Cursor goFrom: Cursor sense
                    to: Cursor sense x @ Display boundingBox top].
            ].
    DosLibrary sleep: 100.
    "
    self executeProgram: aCommandLineString.
    "DISABLE:   (turn off rocket launch display)
    cursor notNil ifTrue: [cursor destroy].
    activeWindow clearMouseCapture.
    "!  
initialize
        " Private "

    super initialize.
    class := Number.
    value := 0.!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #ok: #cancel )
        defaultItem: #ok:!  
openFile: defaultFileName
        "Private - Open an Open File dialog with the defaultFileName "
	^self openOn: defaultFileName selector: #openFile:!   
defaultMessage: aString
        " Specify the default string to display. "
    default := aString!  
partMessages
        " Answer the PARTS message interface of the receiver.
        Provide messages to manipulate the contained value
        and any messages that the containee wants
        which are not implemented by the receiver. "
    ^self
        mergeInterfaceHolder: self partMessagesOfHolder
        value: self partMessagesOfValue!
at: anIndex
    | index |
    anIndex isNil ifTrue: [ ^nil ].
    anIndex isString ifTrue: [ index:= anIndex asNumber ].
    anIndex isNumber ifTrue: [ index:= anIndex asInteger ].

    (index between: 1 and: value size)
        ifFalse: [^self triggerKeyException: index].
    ^value at: index!   
removeBlanks: aBoolean
        " Specify whether leading and trailing blanks
        should be trimmed from the user's response. "
    removeBlanks := aBoolean.!  
store: aSelector arguments: arguments
        " Answer the value of the key aSelector. "
    | key |
    key := (aSelector copyFrom: ('set' size + 1)
                    to: (aSelector size - 1)).
    " should only get in here when key does indeed exist "
    key := ((value includesKey: key)
        ifTrue: [key]
        ifFalse: [key asSymbol]).
    "much too clever to ever work right:
    ((value includesKey: key)
    or: [value includesKey: key asSymbol])
        ifFalse: [
            key := (String with: key first asLowerCase),
                        (key copyFrom: 2 to: key size).
            (value includesKey: key)
                ifFalse: [key := key asSymbol].
            ].
    "
    ^self at: key put: (arguments at: 1)! 
partMessagesOperations
        " Private - answer the PARTS message interface of the receiver
       for the operations sections of the protocol. "

    ^PARTSInterfaceList new
        items: #( #prompt #promptDefault: #prompt:default: )
        defaultItem: #prompt! 
delete: aPathName
        " Delete the file named aPathName. "
    ( self isValidFile: aPathName )
        ifFalse: [ ^self ].
    [ File remove: aPathName ]
       on: Error do: [ :e | self triggerFileExceptionEvent: e description ]!   
title
        " Answer the dialog title "
    ^title!   
exists: directoryName
        " Answer whether the directory named
        directoryName exists.  Triggers existsTrue: if so.
        Returns false and triggers directoryException if not."

    | pathInfo exists |
    pathInfo := self resolveDirectoryName: directoryName.
    pathInfo isNil
        ifTrue: [ ^false ].
    exists := ( self
        directoryOn: ( pathInfo at: 1 )
        directoryPath: ( pathInfo at: 2 ) )
            notNil.
    exists
        ifTrue: [ self triggerEvent: #existsTrue: with: directoryName ]
        ifFalse: [ self triggerDirectoryExceptionEvent: directoryName ].
    ^exists!  
launch
        " Launch the program specified by
        the receiver's comand line property. "
    self launch: commandString.!   
copyBitmap: aBitmap
        " Copy aBitmap to the system clipboard. "
    (aBitmap isBitmap not
    or: [ (Clipboard setBitmap: aBitmap) isNil ] )
        ifTrue: [ self triggerEvent: #copyException ].!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #pathName: #drive: #subdirectories: #files:
            #directoryException: #operationException:
            #existsTrue:
            )
        separators: #( 4 6 )
        defaultItem: #subdirectories:!  
replaceFrom: start
    to: stop
    with: aCollection
    startingAt: repStart
        "Replace the elements of the array at index
         positions start through stop with consecutive
         elements of aCollection beginning at index
         position repStart.  Answer the array."
    value replaceFrom: start
        to: stop
        with: aCollection
        startingAt: repStart.
    " trigger element-changed events "
    showKeys ifTrue: [
        start to: stop do: [ :i |
            self
                triggerEvent: (self keyEventName: i)
                with: (value at: i)
            ]].
    ^ value! 
parameterNames
        " Answer the parameter list from the string template.
        The template sorts and answers an array of Strings. "
    ^self stringTemplate parameterNames!
shutdown
        " The session is terminating. "

    ( PARTSHostInterface hostOperatingSystem = 'Windows'
    and: [ SpeakerLibrary notNil
    and: [ SpeakerLibrary isValid ] ] )
        ifTrue: [ SpeakerLibrary close ].!  
triggerChangedEvent
        " Private "
    ^self triggerEvent: #changed: with: value!  
knownDrives
        "Answer an Array of strings with the names
        of the available devices."
    ^[ Directory drives ]
        on: Error do: [ :e |
            self triggerOperationExceptionEvent: e description.
            #() ]! 
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( ( self itemGetMessages includes: aSelector )
    or: [ self itemSetMessages includes: aSelector ] )
        ifTrue: [ PARTSAliasLink]
        ifFalse: [ super partLinkClassFor: aSelector ]!  
propertyClass: aClass
        " Specify the class to which a value which
        is put into this holder must belong
        (nil if no type checking is to be done). "
    class := aClass = String new
        ifTrue: [nil]
        ifFalse: [aClass isString
            ifTrue: [
                Smalltalk at: aClass asSymbol ifAbsent: []]
            ifFalse: [aClass]]!   
setValue: aValue
        " Store a new value in the receiver. "

    ( super setValue:
        ( aValue isNil
            ifTrue: [ Dictionary new ]
            ifFalse: [ aValue] ) ) isNil
        ifTrue: [ ^nil ].
    showKeys
        ifTrue: [
            value associationsDo: [ :assoc |
                 assoc key isString
                    ifTrue: [self
                        triggerEvent: (self keyEventName: assoc key)
                        with: assoc value ]]].
    ^aValue! 
store: aSelector arguments: arguments
        " Answer the argument in the index-th
        element and answer anObject. "
    | index |
    value isNil ifTrue: [^nil].
    index := (aSelector copyFrom: ('setElement' size + 1)
                    to: (aSelector size - 1)) asInteger.
    ^self at: index put: (arguments at: 1)!
initialize
        " Private - initialize a newly created instance. "
    pattern := '*.*'.!
at: anIndex put: aCharacter
    | index char |
 
   (  ( anIndex isNil ) or: [ aCharacter isNil ] ) ifTrue: [ ^nil ].
    anIndex isString ifTrue: [ index:= anIndex asNumber ].
    anIndex isNumber ifTrue: [ index:= anIndex asInteger ].

	char:=  (aCharacter asString ) isEmpty
		ifTrue: [ $   ]
		ifFalse: [ aCharacter asString at: 1 ].

  (index between: 1 and: value size)
		ifTrue: [ ^self value at: index put: char ]!
dialogAnswer: anAnswer
        " Private - the prompter has an answer. "
    anAnswer isPARTSException
        ifTrue: [self triggerEvent: #cancel]
        ifFalse: [self triggerEvent: #ok: with: anAnswer].!   
is: aValue notIdenticalTo: anotherValue
        " Trigger the true event if aValue
        is not the same object as anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue ~~ anotherValue)!
classAttribute: aClass
       " Private - set the class instance variable of the receiver. "

    class := aClass.!
setPattern: aString
        " Set the pattern string for filtering files. "
    pattern := aString trimBlanks.
    drive notNil
        ifTrue: [self triggerFilesEvent].
    ^aString!  
hasStyle: aStyle
        " Answer whether aStyle is set for the receiver. "
    ^(self style bitAnd: aStyle) = aStyle!  
setSizeThreshold: anInteger
        " Set the size threshold.  If the file is larger than
        this, fileText: triggers the sizeException: event
        and only read the first sizeThreshold bytes.
        A zero threshold is infinite. "
    | limit |
    limit := ( anInteger isInteger
        ifTrue: [ anInteger ]
        ifFalse: [ limit:= anInteger asInteger ] ).
    sizeThreshold := limit.! 
speakerLibrary
        " Private - answer the DLL handle for the Speaker library. "
    SpeakerLibrary isNil
        ifTrue: [
            SpeakerLibrary := ( PARTSHostInterface hostOperatingSystem = 'Windows'
                ifTrue: [   " Win32S needs special workaround for unimplemented API "
                    [ PARTSSpeakerDLL open ]
                        on: Error
                        do: [: e | DynamicLinkLibrary new ].
                    ]
                ifFalse: [ Smalltalk at: PlatformLibrary ] ). ].
    ^SpeakerLibrary!
parameterTypes
    ^parameterTypes!  
triggerDirectoryChangedEvents
        " Private - the current drive has changed. "
    self
        triggerEvent: #pathName: with: self pathName;
        triggerSubdirectoriesEvent;
        triggerFilesEvent.!
triggerIfTrue: aBoolean
        " Trigger the link junction if aBoolean is true. "
    ^self trigger: aBoolean condition: aBoolean! 
pattern: aString
        " Private "
    pattern := aString.!   
fileName: aPathName
        " Answer the unqualified file name
        (including the extension). "
    ( self isValidPathName: aPathName )
        ifFalse: [ ^'' ].
    ^aPathName fileNameLessPath!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary at: self put: (copy := self class new).
    copy
        partWrapper: (wrapper partMirrorCopy: aMirrorCopyDictionary);
        eventTable: (eventTable partMirrorCopy: aMirrorCopyDictionary);
        printerName: printerName copy;
        font: (font partMirrorCopy: aMirrorCopyDictionary);
		printer: (printer partMirrorCopy: aMirrorCopyDictionary).
    ^copy!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #copyString: #copyBitmap: #copyBitmapFromScreen
                #getString #getBitmap  )
        separators: #( 3 )
        defaultItem: #getString! 
modulo: magnitude1 and: magnitude2
        " Answer the result of magnitude1 MOD magnitude2 which is
          the integer remainder after dividing the magnitude1 by magnitude2
          with truncation towards negative infinity."
    ^[ (self asNumber: magnitude1)
        \\ (self asNumber: magnitude2) ]
            on: ZeroDivide
            do: [ ^self divideByZeroErrorMessage ]!  
initialize
        " Private - initialize the class. "
    self supportsNonSuspendedInvocation: true.!  
decrementValue
        " Decrement the value by one. "
    value := value - 1.
    self triggerChangedEvent.
    ^value!  
setValue: aValue
        " Store a new value in the receiver. "

    ^super setValue:
        ( aValue isString
            ifTrue: [ aValue ]
            ifFalse: [ aValue isNil ifTrue: [ '' ] ifFalse: [ aValue asString ] ] ).!
setChoicesOkCancel
        "Configure the reciever to display the user's choices as 'Ok' and 'Cancel'."
    self style: MbOkCancel! 
initialize
        " Private "
    super initialize.
    self
        title: 'title';
        text: 'question';
        style: MbYesNoCancel.!  
parameterPoints: anArray
        " Private - "
    parameterPoints := anArray!  
printerName
        "Answer the currently selected printer, or the default name"
    printerName isNil
        ifTrue: [^self defaultPrinterName]
        ifFalse: [^printerName]!
wildcardChar: aChar
    wildcardChar := aChar!   
fakeDialTone: aString
        " Make a dial tone sound "
    | tone |
    aString do: [ :c |
        tone := (c asciiValue - 20 max: 1) * 30.
        self beep: tone for: 140.
        30000 timesRepeat: [].
        ].! 
initialize
        " Private - class initialization. "

    super initialize.

    IconTypeLabels := Array
        with: ( Array with: 'Information' with: MbIconInformation )
        with: ( Array with: 'Warning' with: MbIconWarning )
        with: ( Array with: 'Error' with: MbIconError )
        with: ( Array with: 'No icon' with: MbNoIcon ).
    IconTypeValues := Array
        with: MbIconInformation
        with: MbIconWarning
        with: MbIconError
        with: MbNoIcon.

    self
        partsIfOS2Do: [
            "DEBUG - check ported implementation"
            ( (IconTypeLabels =  #(
                 #('Information' 48 ) #('Warning' 32)
                "not useful: ( 'Question'  16)  "
                #('Error'  64) #('No icon'  0)) )
            and: [IconTypeValues =  #( 48 32 "16" 64 0 ) ] )
                ifFalse: [self error: 'bug'].
        ].!
initialize
        " Private - initialize the class. "
    self supportsNonSuspendedInvocation: false.! 
initialize
        " Private - "
    self
        startMarker: self class defaultStartMarker;
        endMarker: self class defaultEndMarker;
        typeMarker: self class defaultTypeMarker;
        wildcardChar: self class defaultWildcardChar;
        escapeChar: self class defaultEscapeChar;
        parameters: Dictionary new.
    template := ''!  
sessionStartUp
        " Private - perform the session #startUp processing
        for the basic nonvisual parts runtime library. "

    PARTSSpeakerPart startUp.!   
parseParameterName: aStream
        " Private - "
    | nameStream |
    nameStream := String new asStream.
    nameStream nextPutAll: aStream nextWord.
    [ aStream peek = $_  ] whileTrue: [
        nameStream
            nextPut: aStream next;
            nextPutAll: aStream nextWord ].
    ^nameStream contents! 
value
    ^value!
showKeys
    ^showKeys!  
text: aString
        " Specify the message text. "
    text := aString!
formFeed
        "Send a page eject to the printer"
    | oneShot |
    ( oneShot := jobStarted not )
        ifTrue: [ self beginJob ].
    self printer formFeed.
    oneShot ifTrue: [ self endJob ].!   
triggerIfNotNil: aValue
        " Trigger the link junction if aValue is not nil. "
    ^self trigger: aValue condition: aValue notNil! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #startTimer #stopTimer #setInterval:
            #currentDate #currentTime)
        separators: #( 3 )
        defaultItem: #startTimer!
dialogBoxCreate
        " Private - answer a dialog box for the receiver. "
    ^PARTSFileDialog new
        closedAction: self dialogClosedAction;
        yourself! 
partEnableExecution
        " The application containing the receiver
        is going to be executed.  If value events are surfaced,
        relay its events to any outgoing links. "

    self partWrapper notNil   " backstop in case of multiple enablements "
        ifTrue: [
            self setEventActionsOfValue.
            super partEnableExecution ].!  
openDialogMessage: aMessage

    "Private - open the dialog.  If this guy should be modal, then just open it normally.
    If it should appear modeless, stick it at the end of the event queue so that the process
    returns before the dialog is opened"

    self suspendClient
        ifTrue: [ ^aMessage perform ]
        ifFalse: [ CurrentEvents add: aMessage ]!  
asNumber: aValue
        " Answer aValue as a number. "
    ( aValue isString or: [ aValue isNil ] )
        ifTrue: [ ^super asNumber: aValue ].
    aValue isCollection
        ifTrue: [ ^aValue collect: [ :each | self asNumber: each ] ].
    ^aValue!
copyBitmapFromScreen
        " Copy the screen bitmap to the system clipboard. "
    self copyBitmap:
        (Bitmap fromScreen: Display rectangleFromUser).! 
dialogBoxCreate
        " Private - answer a dialog box for the receiver. "
    self implementedBySubclass! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #error: )
        separators: #( )
        defaultItem: #error:!  
open
        " Open the message dialog with the current
        title and text. "
    ^self openTitle: title text: text!   
setCommand: aCommandLineString
        " Set the command to be executed by launch. "
    commandString := aCommandLineString!   
at: aKey
    ^self value at: aKey
        ifAbsent: [^self triggerKeyException: aKey]!  
mergeInterfaceHolder: holderInterface value: valueInterface
        " Answer the PARTS event interface of the receiver. "
    | nHolderItems |
    valueInterface isNil
        ifTrue: [ ^holderInterface ].
    nHolderItems := holderInterface items size.
    ^PARTSInterfaceList new
        items: holderInterface items, valueInterface items
        separators: (
            holderInterface separators,
            ( Array with: nHolderItems ),
            ( valueInterface separators
                collect: [ :indexEl | indexEl + nHolderItems ] )
            )
        defaultItem: holderInterface defaultItem!   
promptMessage: aString
        " Specify the prompt message. "
    prompt := aString!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#copyException
            #gotString: #gotBitmap: #getException )
        separators: #( 1 )
        defaultItem: #gotString:!   
add: anAssociation
        "Answer anAssociation.  Add anAssociation to the
         receiver."
    value add: anAssociation.
    (showKeys and: [anAssociation key isString])
        ifTrue: [self
            triggerEvent: (self keyEventName: anAssociation key)
            with: anAssociation value ].
    ^anAssociation!
setInterval: anInteger
        "Change the timer interval to anInteger of milliseconds."
    anInteger isNil
        ifTrue: [ ^nil ].
    self interval: anInteger asInteger.
    ( PARTSTimerWindow isTimerRunning: self )
        ifTrue: [ self stopTimer; startTimer ].
    ^anInteger!   
directoryOn: aDriveLetter directoryPath: directoryPathName
        " Private - answer directory (nil if not valid). "
    | directory |
    directory := Directory pathName:
        (self driveNameString: aDriveLetter),
        directoryPathName.
    directoryPathName ~= ''
        ifTrue: [ directoryPathName last = $\
                    ifFalse: [ directory pathName: directory pathName, '\' ] ].
    ^directory valid
        ifTrue: [directory]
        ifFalse: [nil]!   
dialogBoxAttribute
        " Private - answer the dialogBox instance variable "
   ^diagBox!
setValue: aValue
        " Store a new value in the receiver. "

    ^super setValue:
        ( aValue isNumber
            ifTrue: [ aValue ]
            ifFalse: [ aValue isNil ifTrue: [ 0 ] ifFalse: [ aValue asNumber ] ] ).! 
keyMessages
        " Private "
    | keys n messages |
    keys := self keyList.
    n := keys size.
    messages := Array new: (2 * n).
    1 to: keys size do: [ :i |
        messages
            at: i put: (self keyMessageName: (keys at: i));
            at: (n + i) put: (self keySetMessageName: (keys at: i))].
    ^messages!  
keyMessages
        " Private "
    | n messages |
    n := self size.
    messages := Array new: (2 * n).
    1 to: self size do: [ :i |
        messages
            at: i put: (self keyMessageName: i);
            at: (n + i) put: (self keySetMessageName: i)].
    ^messages!
keyExceptionEvent
        " Private "
    self implementedBySubclass!   
interval: anInteger
        "Private - Set the time interval to anInteger milliseconds."
    interval := anInteger asInteger max: 500!  
sortedDescending: aCollection
        " Answer the elements of the collection
        sorted in descending order. "
    | sorted |
    sorted := SortedCollection new descendingOrder.
    sorted addAll: aCollection.
    aCollection isString
        ifTrue: [^(String new: aCollection size)
            replaceFrom: 1
            to: aCollection size
            with: sorted asArray].
    ^sorted asArray!   
driveNameString: aCharacter
        " Private - answer drive name string for aCharacter. "
    ^String "with: Space" with: aCharacter with: $:! 
dialogAnswer: anAnswer
        " Private - the dialog has an answer. "
    self implementedBySubclass!  
isValidFile: aPathName
        " Private - answer whether file exists. "
    ((aPathName trimBlanks size = 0)
    or: [(aPathName includes: $*)
    or: [(File exists: aPathName) not]])
        ifTrue: [
            self triggerEvent: #noSuchFileException:
                with: aPathName.
            ^false].
    ^true! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #yes #no )
        defaultItem: #yes!  
pathNameForOpen
        " Open the Open File dialog with the current pattern
        as the default file name. "
    ^self openFile: self pattern! 
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  If aSelector isn't part of
        the container's own protocol, map it to the
        relay method which forwards it to the
        contained value. "

    ^( self respondsTo: aSelector)
        ifTrue: [ aSelector ]
        ifFalse: [ #relayMessage:arguments: ]!
saveFile: defaultFileName 
        "Private - Open a Save File dialog with the defaultFileName "
	^self openOn: defaultFileName selector: #saveFile:!   
date: aPathName
    " Answer the last-written Date of the file named aPathName. "
    | info |
 
    ( self isValidFile: aPathName )
        ifFalse: [ ^'' ].

    info := [ ( File fromPath: aPathName )   lastModificationTime date ]
        on: Error do: [ :e | ^self triggerFileExceptionEvent: e description ].
    ^info!   
is: aValue greaterThanOrEqualTo: anotherValue
        " Trigger the true event if aValue
        is greater than or equal to anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue >= anotherValue)!
buttonValues
        " Private - answer the values to associate with 
        each button on the dialog. "
    ^Array with: true!  
perform: selector withArguments: anArray
        "Answer the result of sending a message to the receiver
         with selector aSymbol and arguments the elements of
         anArray.  Relay the message to the value if it is
         not understood by the holder. "

    ^( self respondsTo: selector )
        ifTrue: [ super perform: selector withArguments: anArray ]
        ifFalse: [ self value perform: selector withArguments: anArray ]!
relayEventsFromValue
        " Private - answer whether events triggered
        by the contained value can be relayed to
        outgoing links in the receiver's application. "

    ^false!   
initialize
        " Private "
    self suspendClient:
        ( self class supportsNonSuspendedInvocation
            ifTrue: [ false ]  " preferred state if we can support it "
            ifFalse: [ true ] ).
    "self diagBox: self dialogBoxCreate."  " let subclasses decide when to create "!
isValidPathName: aPathName
        " Private - answer whether aPathName is a legal
        file name. "
    | anArray dirName fileName destDir |
    ((aPathName trimBlanks size = 0)
    or: [(aPathName includes: $*)])
        ifTrue: [
            self triggerEvent: #fileNameException:
                with: aPathName.
            ^false].
    anArray := File splitPath: aPathName in: Disk.
    dirName :=
        (String with: (anArray at: 1) with: $:),
        (anArray at: 2), '\'.
    (destDir := Directory pathName: dirName) valid
        ifFalse: [
            self triggerEvent: #fileNameException:
                with: aPathName.
            ^false].
    destDir fileSystem = 'FAT' ifTrue: [
        fileName := anArray at: 3.
        ((fileName fileName size <= 8)
            and: [fileName fileExtension trimBlanks size <= 3])
                ifFalse: [
                    self triggerEvent: #fileNameException:
                        with: aPathName.
                    ^false]].
    ^true!
parameters: aDictionary
        " Private - "
    parameters := aDictionary!
setValue: aValue
        " Store a new value in the receiver. "

    super setValue:
        ( ( aValue isKindOf: OrderedCollection )
            ifTrue: [ aValue ]
            ifFalse: [ aValue isNil
                ifTrue: [ OrderedCollection new ]
                ifFalse: [ aValue asOrderedCollection ] ] ).
    ^aValue! 
replaceControlCharsIn: aString
        " Replace any control characters in aString with blanks "
    ^aString replaceControlChars!  
setFrequency: integerFrequency
        " Set the frequence for the speaker tone. "
    frequency := self asInteger: integerFrequency.!  
pathNameOfFile: aFileName
        " Answer the fully qualified path name
        of aFileName in the current directory. "
    | pathName nonNilFileName |
	nonNilFileName := aFileName isNil ifTrue: [''] ifFalse: [aFileName].
    pathName := self pathName.
    nonNilFileName = self dirNameSelf
        ifTrue: [ ^pathName ].
    nonNilFileName = self dirNameSuper
        ifTrue: [ ^pathName fileNamePath ].
    ((pathName size > 0) and: [pathName last ~= $\])
        ifTrue: [pathName := pathName, '\'].
    ^pathName, nonNilFileName!   
value
        " Answer the template string with the current
        value of the parameters substituted for all references. "
    ^self stringTemplate value!  
startMarker: aString
    startMarker := aString! 
defaultInterval
        " Private - answer the default timer interval. "
    ^1000! 
triggerDirectoryExceptionEvent: directoryName
        " Private "
    self triggerEvent: #directoryException: with: directoryName.! 
setPrinterName: aString
        "Set the current printer name, and initialize the printer & receiver"
    
    printerName ~= aString ifTrue: [
        jobStarted := false.
        printerName := aString.
        font := nil.
        self printer: ( Printer named: printerName ).
        "dRes := Display deviceResolution.
        pRes := printer deviceResolution.
        self printer pen
            setDefaultViewScale: (pRes x / dRes x) @ (pRes y / dRes y)
            option: TransformReplace"
    ]!
new
        " Answer a new instance of the receiver. "

    | aTypedValueHolder |
    aTypedValueHolder := super new.
    aTypedValueHolder classAttribute isClass
        ifFalse: [ self error: 'programming error in subclass' ].
    ^aTypedValueHolder!   
setTemplate: aString
        " Set the template string. "
    stringTemplate template: aString.
    ^aString!  
propertyValue: anObject
        " for property dialog "
    | icon |
    super propertyValue: anObject.
    (icon := self partIcon) isPARTSTextIcon
        ifTrue: [ icon connectionValueChanged ]! 
valueWith: aDictionary
        " Answer the template string with the current
        value of the parameters substituted for all references. "
    ^self stringTemplate valueWith: aDictionary!
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self keyMessages includes: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [ super partLinkClassFor: aSelector ]!   
itemSetMessage: aName
        " Private "
    ^(self messagePrefix, aName, ':') asSymbol!   
partMessagesRelayedToValue
        " Private - messages implemented in this class
        which can be surfaced as part of the value's
        own protocol because the implementation
        forwards them. "
    ^super partMessagesRelayedToValue,
        #( #atAll:put: #atAllPut:
            #replaceFrom:to:with: #replaceFrom:to:with:startingAt:
            #replaceFrom:to:withObject:  )!   
partSavePrintSetupInfo: aPrinter
        " Private - Save the new printer information
          from the Print dialog. "
    self printer: aPrinter.!  
triggerIfNotEmpty: aValue
        " Trigger the link junction if aValue is not empty (size > 0). "
    ^self trigger: aValue condition: (aValue size > 0)!  
partMessagesRelayedToValue
        " Private - messages implemented in this class
        which can be surfaced as part of the value's
        own protocol because the implementation
        forwards them. "
    ^#( #at: #at:put: #asString #size )! 
frequency: integerFrequency duration: integerDuration
        " Make a sound at integerFrequency cycles
        for integerDuration msec. "
    self
        beep: (self asInteger: integerFrequency)
        for: (self asInteger: integerDuration).!   
directoryPath: directoryName
        " Answer the directory path name of directoryName. "

    | pathInfo |
    pathInfo := self resolveDirectoryName: directoryName.
    ( self directoryOn: (pathInfo at: 1) directoryPath: (pathInfo at: 2) ) isNil
        ifTrue: [ self triggerDirectoryExceptionEvent: directoryName ].
    pathInfo isNil
        ifTrue: [ ^nil ].
    ^pathInfo at: 2! 
pathNameForOpen: aString
        " Open the Open File dialog with aString
        as the default file name. "
    ^self openFile: (self asString: aString)!
filesIn: directoryPathName matching: patternString
        " Answer the files in the directory named
        directoryPathName which match the patternString. "

    | pathInfo directory |

    pathInfo := self resolveDirectoryName: directoryPathName.
    pathInfo isNil
        ifTrue: [ ^#() ].

    directory := self
        directoryOn: (pathInfo at: 1)
        directoryPath: (pathInfo at: 2).
    directory isNil
        ifTrue: [
            self triggerDirectoryExceptionEvent: directoryPathName.
            ^#() ].

    ^[ (directory filesNamed: patternString)
        asSortedCollection asArray ]
            on: Error do: [ :e |
                self triggerOperationExceptionEvent: e description.
                #() ]!  
fileTextToThresholdBasic: aPathName
        " Answer the contents of the file named
        aPathName.  Signal sizeException: if
        the size threshold is exceeded and
        the partial file contents will be returned
        unless someone handles the condition. "
    | fileStream contents|
    ( self isValidFile: aPathName )
        ifFalse: [ ^'' ].
    [ fileStream := File pathNameReadOnly: aPathName ]
        on: Error do: [ :e |
            ^self triggerFileExceptionEvent: e description ].

    ( sizeThreshold isNil
    or: [ fileStream size <= sizeThreshold ] )
        ifTrue: [
            contents := fileStream contents ]
        ifFalse: [
            contents := fileStream partialContents: sizeThreshold.
            self triggerEvent: #sizeException: with: aPathName ].
    fileStream close.
    ^contents! 
dateTimeString: aPathName
        " Answer the last-written timestamp of the
        file named aPathName. "
	^( self date: aPathName ) asString , ' ', ( self time: aPathName ) asString! 
speakerLibrary: aDllHandleOrNil
        " Private "
    SpeakerLibrary := aDllHandleOrNil.! 
initialize
        " Private - class initialization. "

    super initialize.

    ButtonLabelLabels := Array
        with: (Array with: 'Yes No' with: MbYesNo )
        with: (Array with: 'Ok Cancel' with: MbOkCancel )
        with: (Array with: 'Retry Cancel' with: MbRetryCancel )
        "Disable - doesn't work: with: (Array with: 'Enter Cancel' with: MbEnterCancel )".
    ButtonLabelValues := Array
        with: MbYesNo
        with: MbOkCancel
        with: MbRetryCancel
        "with: MbEnterCancel".

    self
        partsIfOS2Do: [
            "DEBUG - check ported implementation"
            ( (ButtonLabelLabels =  #(
                #('Yes No' 4 )
                #('Ok Cancel' 1)
                #('Retry Cancel' 2)
                "DISABLE (doesn't work): ('Enter Cancel' 8) "
                ) )
            and: [ButtonLabelValues =  #( 4 1 2 "8") ] )
                ifFalse: [self error: 'bug'].
        ].!
supportsNonSuspendedInvocation
        " Private - answer whether the suspendClient
        property can be turned off on instances of
        the reciever. "
    ^supportsNonSuspendedInvocation!   
defaultMessage
        " Answer the default string to display. "
    ^default!  
store: aSelector arguments: arguments
        " Store the argument under the key
        specified by aSelector.  Answer the arg. "
    ^self implementedBySubclass!   
directoryName: directoryName
        " Answer the unqualified directory name
        of directoryName. "

    | pathInfo pathName |
    pathInfo := self resolveDirectoryName: directoryName.
    pathInfo isNil
        ifTrue: [ ^nil ].
    pathName := pathInfo at: 2.
    ( self directoryOn: (pathInfo at: 1) directoryPath: (pathInfo at: 2) ) isNil
        ifTrue: [ self triggerDirectoryExceptionEvent: directoryName ].
    ^pathName = self dirNameRoot
        ifTrue: [ pathName ]
        ifFalse: [ pathName fileNameLessPath ]!
typeMarker: aChar
    typeMarker := aChar!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#trigger #trigger:
            #triggerIfTrue: #triggerIfFalse:
            #triggerIfNil: #triggerIfNotNil:
            #triggerIfEmpty: #triggerIfNotEmpty:)
        separators: #( 2 )
        defaultItem: #trigger!
template
    ^template!  
initializeSessionEventHandlers
        " Private - register the session event handlers for the
        basic nonvisual parts runtime library
            PARTSLinkJunctionPart initializeSessionEventHandlers
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
partMessagesProperties
        " Private - answer the PARTS message interface of the receiver
       for the property accessing sections of the protocol. "

    ^( PARTSInterfaceList new
            items: #(
                #title #setTitle:
                    #text #setText:
                ) )
        concatenate: super partMessagesProperties
        defaultItem: #text!
size: aPathName
        " Answer the size of the file named aPathName. "
 
    | info |

   ( self isValidFile: aPathName )
        ifFalse: [ ^'' ].

    info := [ ( File fromPath: aPathName ) size ]
        on: Error do: [ :e | ^self triggerFileExceptionEvent: e description ].
    ^info!  
errorEvent: anErrorDescription
        "Raise an error event that a user can tap into"
    ^self triggerEvent: #error: with: anErrorDescription!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #launch #launch:
            #launchPartFile:
            #setCommand:)
        separators: #( 2  3)
        defaultItem: #launch! 
setTitle: aString
        " Specify the dialog title "
    self title: aString.
    ^aString!  
partMessagesRelayedToValue
        " Private - messages implemented in this class
        which can be surfaced as part of the value's
        own protocol because the implementation
        forwards them. "
    ^super partMessagesRelayedToValue,
        #( #add: #addAll: )! 
suspendClient
        " Answer whether the client of a modal
        dialog is suspended until the dialog
        is closed. "
    ^suspendClient!
setText: aString
        " Specify the message text. "
    self text: aString.
    ^aString!   
setPromptMessage: aString
        " Specify the prompt message. "
    self promptMessage: aString.
    ^aString!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #fileText: #fileTextToThreshold: #setFileText:to:
            #copy:to: #delete: #rename:to:
            #exists: #size: #date: #time:
                #dateTimeString: #descriptionString:
            #fileName: #fileExtension:
            )
        separators: #( 3 6 12 )
        defaultItem: #fileText:!   
partMessagesProperties
        " Private - answer the PARTS message interface of the receiver
       for the property accessing sections of the protocol. "

    ^( PARTSInterfaceList new
            items: #(
                #pattern #setPattern:
                ) )
        concatenate: super partMessagesProperties
        defaultItem: #pattern!  
partMessages
        " Answer the PARTS event interface of the receiver. "
    | templateInterface |
    templateInterface := self partMessagesTemplate.
    ^templateInterface
        concatenateSeparated: self partMessagesParameters
        defaultItem: templateInterface defaultItem!   
printerSetup
    " Open the Print Dialog and save the printer setup information. "
    | newPrinter  hDC |
    newPrinter := 
		self 
			partsIfOS2Do: [ 
				PrintDialog new 
					openOn: self printer;
                	printer ]
			partsIfWindowsDo: [
				hDC:= PrintDialog new 
							open; 
							hDCPrinter.
				hDC isNil ifTrue: [^nil].
				Printer fromDC: hDC ].	
    newPrinter isNil ifTrue: [^nil].
	self printer: newPrinter.!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #asString:
                #asInteger: #asFloat: #asNumber:
                #asDate: #asArray:
            #sortedAscending: #sortedDescending:
            #asUpperCase: #asLowerCase:
                #replaceControlCharsIn: )
        separators: #( 6 8 )
        defaultItem: #asString:! 
valueIsEqual: aValue
    ^value = aValue!
startMarker
    ^startMarker!
initialize
        " Private - initialize new instance "
    self stringTemplate: PARTSStringTemplate new!  
triggerDriveChangedEvents
        " Private - the current drive has changed. "
    self triggerEvent: #drive: with: (self driveNameString: drive).! 
keyEventName: anInteger
        " Private "
    ^('changedElement', anInteger printString, ':') asSymbol!   
partMessagesOfHolder
        " Private "
    ^super partMessagesOfHolder
        concatenateSeparated: (PARTSInterfaceList new
            items: #(
                #incrementValue #decrementValue
                #changeValueBy: ) )
        defaultItem: #value!  
keyList
        " Private "
    ^(value keysAsArray select: [ :aKey | aKey isString])
        asSortedCollection asArray!  
endMarker
    ^endMarker!
initialize
        " Private "

    super initialize.
    class := Array.
    value := (Array new: 2).
    showKeys := true.!   
promptMessage
        " Answer the prompt message. "
    ^prompt!   
initialize
        " Private "
    super initialize.
    self
        title: 'title';
        text: 'question';
        style: MbYesNo.!
lookup: aSelector arguments: arguments
        " Answer the value of the key aSelector. "
    ^value at: aSelector asString  " keys usually are strings "
        ifAbsent: [value at: aSelector
            ifAbsent: [^self triggerKeyException: aSelector]]!   
asBoolean: aValue
        " Private - answer aValue as a boolean. "
    aValue isBoolean
        ifTrue: [^aValue].
    (aValue trimBlanks = true printString)
        ifTrue: [^true].
    (aValue trimBlanks = false printString)
        ifTrue: [^false].
    ^aValue     " probably an error, let it surface "!  
isGlobalName: aString
        " Answer whether aString is a global variable name. "
    ((aString size = 0)
    or: [aString first isUpperCase not
    or: [(aString detect: [ :c | c isAlphaNumeric not] ifNone: [nil]) notNil]])
        ifTrue: [^false].
    ^true! 
pathName
        " Answer the fully-qualified path name of
        the current directory.  "
    ^drive isNil
        ifTrue: [Disk drivePathName]
        ifFalse: [(self driveNameString: drive), directoryPath]!  
initialize
        " Private - class initialization. "

    super initialize.

    ButtonLabelLabels := Array
        with: (Array with: 'Yes No Cancel' with: MbYesNoCancel )
        with: (Array with: 'Abort Retry Ignore' with: MbAbortRetryIgnore ).
    ButtonLabelValues := Array
        with: MbYesNoCancel
        with: MbAbortRetryIgnore.

    self
        partsIfOS2Do: [
            "DEBUG - check ported implementation"
            ( (ButtonLabelLabels =  #(
                #('Yes No Cancel'  5 )
                #('Abort Retry Ignore' 3) ) )
            and: [ButtonLabelValues =  #( 5 3 ) ] )
                ifFalse: [self error: 'bug'].
        ].! 
at: anIndex
		"Private - Answer ther result of sending #at: to the value."
    ^self value at: anIndex! 
printUserRectangle
        "Print a user selected rectangle from the display; if necessary,
        wrap the printout in a print job"

    | rect aBitmap  |
	rect := Display rectangleFromUser.
	rect isNil ifTrue: [ ^nil ].
    aBitmap := Bitmap fromScreen: rect.
    CursorManager execute 
		changeFor: [
    		self print: aBitmap.
    		aBitmap release ].!  
replaceFrom: start to: stop with: aCollection
        "Answer the array.  Replace the elements of the
         array at index positions start through stop,
         with the elements of aCollection.  The number of
         elements being replaced must be the same as the
         number of elements in aCollection, else report
         an error."
    stop - start + 1 = aCollection size
        ifFalse: [
            self 
                triggerEvent: #valueException:
                withArguments: (Array with: aCollection)
                ifNotHandled: [
                    MessageBox
                        notify: 'ArrayHolder Problem'
                        withText: 'Replacement collection has wrong size.'].
            ^nil ].
    ^self
        replaceFrom: start
        to: stop
        with: aCollection
        startingAt: 1! 
resolveDirectoryName: aString
        " Private - resolve aString to a fully qualified
        directory name, relative to the current position.
        Answer array containing path info pair
        <drive letter, directory path> . "
    | aPathName currentDrive currentDirectoryPath
      driveLetter fullDirectoryPath |

    aPathName := (aString isNil
        ifTrue: ['']
        ifFalse: [aString trimBlanks]).

    drive isNil
        ifTrue: [
            currentDrive := Disk drive.
            currentDirectoryPath := Disk pathName]
        ifFalse: [
            currentDrive := drive.
            currentDirectoryPath := directoryPath].

    " pick off pseudo-names "
    (aPathName = self dirNameSelf)
        ifTrue: [^Array
            with: currentDrive
            with: currentDirectoryPath].
    (aPathName = self dirNameSuper)
        ifTrue: [
            (currentDirectoryPath = self dirNameRoot)
                ifTrue: [
                    self triggerDirectoryExceptionEvent: aString.
                    ^nil].
            fullDirectoryPath := self parentDirectoryPath: currentDirectoryPath.
            ^Array
                with: currentDrive
                with: fullDirectoryPath
            ].

    " pick off any leading drive letter "
    driveLetter := self getDrive: aPathName.
    driveLetter isNil
        ifTrue: [driveLetter := currentDrive]
        ifFalse: [
            "let client do validation checking:
            (self isValidDrive: driveLetter)
                ifFalse: [
                    self triggerDirectoryExceptionEvent: aString.
                    ^nil].
            "
            aPathName := aPathName
                copyFrom: ((aPathName indexOf: $:) + 1)
                to: aPathName size.
            (aPathName size = 0)
                ifTrue: [^Array
                    with: driveLetter
                    with: self dirNameRoot].
            ].

    " verify that this guy really exists "
    fullDirectoryPath := (
        ((aPathName size > 0)
        and: [aPathName first = $\])
            ifTrue: [aPathName]
            ifFalse: [
                currentDirectoryPath,
                ((currentDirectoryPath = self dirNameRoot)
                    ifTrue: ['']
                    ifFalse: ['\']),
                aPathName]).
    ((fullDirectoryPath size > 1)
    and: [fullDirectoryPath last = $\])
        ifTrue: [fullDirectoryPath := fullDirectoryPath
            copyFrom: 1
            to: (fullDirectoryPath size - 1)].
    ^Array with: driveLetter with: fullDirectoryPath!  
updateValue: aDictionary
        " Update the dictionary held by the receiver
        with the elements of aDictionary. "
    ((self isValidObject: aDictionary)
    and: [self isUpdatableFrom: aDictionary])
        ifFalse: [^nil].
    aDictionary associationsDo: [ :assoc |
        self add: assoc].
    ^aDictionary!
prompt
        " Open the prompter dialog with the
        current prompt message and default. "
    ^self prompt: prompt default: default!
atAll: aCollection put: anObject
        "Answer the array after replacing those
         elements, indexed by the indices contained
         in aCollection, with anObject."
    aCollection do: [ :index |
        self at: index put: anObject].
    ^value! 
setChoicesYesNoCancel
        "Configure the reciever to display the user's choices as 'Yes', 'No', and 'Cancel'."
    self style: MbYesNoCancel!   
fileInValidateSuspendClient: anObjectFiler
        " Private - ensure that upgraded instance has valid suspendClient setting. "

    ( self suspendClient = false
    and: [ self class supportsNonSuspendedInvocation not ] )
        ifTrue: [
            self suspendClient: true.
            anObjectFiler recordWarningMessage:
                'The ''Wait for answer'' property of ', self partName,
                ' was turned on (cannot support the off state).'.
            ].! 
defaultTypeMarker
        " Answer the default character for parameter delimiters "
    ^$,!
tone
        " Sound the tone specified by the
        current frequency and duration values. "
    self
        beep: frequency
        for: duration.! 
driveName: directoryName
        " Answer the drive name of directoryName. "

    | pathInfo |
    pathInfo := self resolveDirectoryName: directoryName.
    ( self directoryOn: (pathInfo at: 1) directoryPath: (pathInfo at: 2) ) isNil
        ifTrue: [ self triggerDirectoryExceptionEvent: directoryName ].
    pathInfo isNil
        ifTrue: [ ^nil ].
    ^self driveNameString: (pathInfo at: 1)!  
not: aBoolean
        " Answer the logical negation of aBoolean. "
    ^[ (self asBoolean: aBoolean) not ]
            on: Error
            do: [ ^self nonBooleanParametersErrorMessage ]!  
triggerFileExceptionEvent: errorString
        "A file exception has occured.  Trigger the event."
    self triggerEvent: #fileException: with: errorString.
    ^nil! 
setChoicesYesNo
        "Configure the reciever to display the user's choices as 'Yes' and 'No'."
    self style: MbYesNo!  
parameterPoints
        " Private - "
    ^parameterPoints! 
print: anObject
        "Print anObject ( a String or a Bitmap) to the current printer;
         if anObject is not of a known printable class, raise an error
         event; if no job has been started, run this printout as its own
         job"

    | oneShot |

    ( ( Set with: String with: Bitmap ) includes: anObject class )
        ifFalse: [ ^self errorEvent: 'Unsupported print data class' ].

    ( oneShot := jobStarted not ) ifTrue: [ self beginJob ].
    CursorManager execute 
		changeFor: [
    		anObject isString
        		ifTrue: [
            		self printer
                		print: anObject
                		font: font
               			title: nil
                		collate: false
                		copies: 1
                		wordWrap: true
                		marginsRect: nil ]
        		ifFalse: [
            		anObject outputToPrinter: self printer ] .
			].
   oneShot ifTrue: [ self endJob ].!   
stringTemplate
        " Private - "
    ^stringTemplate!   
triggerOperationExceptionEvent: aString
        " Private "
    self triggerEvent: #operationException: with: aString.! 
trigger: aValue condition: aBoolean
        " Private - conditionally trigger the link junction,
        passing along aValue if aBoolean is true. "
    ^aBoolean
        ifTrue: [self trigger: aValue]
        ifFalse: [self triggerConditionFailed: aValue]!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#ticked #tickedTime:)
        defaultItem: #ticked! 
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self respondsTo: aSelector )
        ifTrue: [ super partLinkClassFor: aSelector ]
        ifFalse: [ PARTSAliasLink ]  " relay to contained value "!   
asArray: aValue
        " Answer aValue as an array. "
    ^(aValue isCollection and: [aValue isString not])
        ifTrue: [aValue asArray]
        ifFalse: [Array with: aValue]!  
suspendClient: aBoolean
        " Specify whether the client of a modal
        dialog is suspended until the dialog
        is closed. "

    ( self class supportsNonSuspendedInvocation not
    and: [ aBoolean ~= true ] )
        ifTrue: [
            MessageBox warning:
                'Cannot turn off suspendClient property for ', self partName, '.'.
            ^self ].
    self suspendClientAttribute: aBoolean.!   
partLibraryClassesToInitialize
		" Private - answer the classes in the library which need to be
		initialized when the library is installed. "

	^PARTSPrebuiltDialog withAllSubclasses,
		( Array with: PARTSSpeakerPart )! 
drivePathName: aString
        " Private - set the drive and directoryPath from aString
        with no validity checking. "
    | stream temp |
    aString isNil ifTrue: [^self].
    stream := aString asStream.
    temp := stream upTo: $:.
    temp size = 1 ifFalse: [
        ^directoryPath := temp].
    drive := temp first.
    directoryPath := stream contents copyFrom: stream position to: stream size! 
waitForAnswer
        " Answer whether the client of a modal
        dialog is suspended until the dialog
        is closed. "
    ^self suspendClient!   
clearTemplate
        " Private - "
    self
        parameters: nil;        
        parameterNames: nil;
        parameterTypes: nil;
        parameterPoints: nil!   
keyEvents
        " Private "
    ^self keyList collect: [ :aKey | self keyEventName: aKey]!
is: aValue identicalTo: anotherValue
        " Trigger the true event if aValue
        is the same object as anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue == anotherValue)!   
keySetMessageName: anInteger
        " Private "
    ^('setElement', anInteger printString, ':') asSymbol!  
textValue: aString
    self setValue: aString!   
is: aValue notEqualTo: anotherValue
        " Trigger the true event if aValue
        is not equal to anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue ~= anotherValue)!  
valueNotEqual: aValue
    ^value ~= aValue!  
initialize
        " Private "

    "self implementedBySubclass"  " MUST set the class in all concrete subclasses "!   
forPWO20Dialog: originalDialog
        " Private - answer a new instance of the receiver
        with its properties set according to the values
        in originalDialog from PWO 2.0 PremadeDiag. "

    self implementedBySubclass!  
initialize
        " Private "

    super initialize.
    class := OrderedCollection.
    value := OrderedCollection new.!   
triggerIfEmpty: aValue
        " Trigger the link junction if aValue is empty (size = 0). "
    ^self trigger: aValue condition: (aValue size = 0)! 
style: anInteger
        " Private - set the style flags "
    style := anInteger.! 
dirNameSelf
        " Private - answer the name of the current
        directory. "
    ^'.'!  
buttonValues
        " Private - answer the values to associate with 
        each button on the dialog. "
    ^Array with: true with: false!  
textValue: aString
    self setValue: aString asNumber!  
setValue: aValue
        " Store a new value in the receiver. "

    ( super setValue:
        ( aValue isArray
            ifTrue: [ aValue ]
            ifFalse: [ aValue isNil ifTrue: [ #() ] ifFalse: [ aValue asArray ] ] ) ) isNil
        ifTrue: [ ^nil ].
    showKeys
        ifTrue: [
            1 to: value size do: [ :i |
                self
                    triggerEvent: ( self keyEventName: i )
                    with: ( value at: i ) ] ].
    ^aValue! 
appendToValue: aString
        " Concatenate aString to the current value. "
    value := value, aString.
    self triggerChangedEvent.
    ^value!   
parentDirectoryPath: dirPathName
        " Private - answer the path name of the parent
        directory of dirPathName. "
    dirPathName size to: 1 by: -1 do: [ :i |
        (dirPathName at: i) = $\
            ifTrue: [
                ^((i = 1)
                    ifTrue: ['\']
                    ifFalse: [dirPathName copyFrom: 1 to: i - 1])
            ]].
    ^'\'! 
currentDirectory
        " Private - answer a Directory for the current position. "
    ^drive isNil
        ifTrue: [Disk]
        ifFalse: [Directory pathName: self pathName]! 
title: titleString text: textString
        " Open the message dialog with titleString as the title
        and textString as the text. "
    ^self openTitle: titleString text: textString!   
suspendClientAttribute: aBoolean
        " Private - set the suspendClient value without checking, "

    suspendClient := aBoolean.!  
asBoolean: aValue
        " Private - answer aValue as a number. "
    | trimmed |
    aValue isBoolean
        ifTrue: [ ^aValue ].
    aValue isString
        ifTrue: [
            trimmed := aValue trimBlanks.
            ( trimmed equalsIgnoreCase: 'true' )
                ifTrue: [ ^true ].
            ( trimmed equalsIgnoreCase: 'false' )
                ifTrue: [ ^false ].
           ].
    ^aValue     " probably an error, let it surface "!  
partHint
        "Answer a string which gives a brief description
        of the receiver part. "
    ^(self value isNil
            ifTrue: [class isNil
                ifTrue: ['contains nothing']
                ifFalse: ['belongs to class ', class name]]
            ifFalse: ['contains ', self value asString])!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #tone #setFrequency: #setDuration:
                #frequency:duration:
            #ring #alarm )
        separators: #( 4 )
        defaultItem: #tone!  
stopTimer
        " Stop the timer.  Answer the current time. "
    PARTSTimerWindow stopTimer: self.
    ^self currentTime!   
parameterNames
    parameterNames notNil ifTrue: [ ^parameterNames ].
    self parameterPoints isNil ifTrue: [ ^#() ].
    ^parameterNames := ( self parameterPoints
        collect: [ : parm |    parm value ] ) asSet asSortedCollection asArray!  
dirNameSuper
        " Private - answer the name of the current
        directory's parent directory. "
    ^'..'! 
fileText: aPathName
        " Answer the contents of the file named aPathName. "
    | fileStream contents|
    ( self isValidFile: aPathName )
        ifFalse: [ ^'' ].
    [ fileStream := File pathNameReadOnly: aPathName.
        contents := fileStream contents.
        fileStream close ]
            on: Error do: [ :e |
                fileStream close.
                ^self triggerFileExceptionEvent: e description ].
    ^contents!
lookup: aSelector arguments: arguments
        " Answer the value at the key specified
        by aSelector. "
    ^self implementedBySubclass!
dirNameRoot
        " Private - answer the name of the root directory. "
    ^'\'!  
trigger
        " Unconditionally trigger the link junction with nil. "
    ^self trigger: nil! 
triggerFilesEvent
        " Private "
    self triggerEvent: #files: with: self files.! 
initialize
        " Private "
    super initialize.
    self
        promptMessage: 'Please enter a string:';
        defaultMessage: '';
        removeBlanks: true.! 
pattern
        " Answer the pattern string "
    ^pattern! 
title: aString
        " Specify the dialog title "
    title := aString!   
setFileText: aPathName to: aString
        " Write aString to the file named aPathName "
    | fileStream exception |
    exception:= false.
   ( self isValidFile: aPathName )
        ifFalse: [ exception:= true  ].
    ( self isValidPathName: aPathName )
        ifFalse: [ exception:= true].
    exception ifTrue: [ ^self].
    [ fileStream := File newFile: aPathName ]
        on: Error
        do: [ :e | self triggerFileExceptionEvent: e description. ^self ].
    [ fileStream nextPutAll: aString ]
        on: Error
        do: [ :e | self triggerFileExceptionEvent: e description. ^self ].
    fileStream close! 
beginJob
        "Start a print job (more than one thing can be printed to a job"
    jobStarted ifTrue: [ ^self errorEvent: 'Job already started' ].
    self printer startPrintJob.
    jobStarted := true.
    self font: ( font notNil
        ifTrue: [ font ]
        ifFalse: [ SysFont ] )!
relayMessage: aSelector arguments: arguments
        " Forward the message aSelector to value
        with the given arguments (an array of values). "
    ^self value perform: aSelector withArguments: arguments!
defaultEscapeChar
    ^$\!   
fileAttributes: aPathName
 
    " Answer the file attributes of the file named aPathName. "

    | info |
    info := [ ( File fromPath: aPathName ) file attributes ]
        on: Error do: [ :e | ^self triggerFileExceptionEvent: e description ].
    ^info!   
itemGet: aSymbol arguments: arguments
        " Private - "
    self parameters size = 0
        ifTrue: [^self reportException: 'No parameters defined'].
    ^self parameters
        at: (aSymbol copyFrom: 1 to: (aSymbol size)) asString!   
getString
        " Answer the system clipboard contents as a string. "
    | value |
    (value := Clipboard getStringOrNil) isNil
        ifTrue: [self triggerEvent: #getException]
        ifFalse: [self triggerEvent: #gotString: with: value].
    ^value!   
is: anValue greaterThan: anotherValue
        " Trigger the true event if aValue
        is greater than anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (anValue > anotherValue)!
asString: aValue
        " Answer aValue as a string. "
    aValue isString
        ifTrue: [^aValue].
    aValue isNil
        ifTrue: [ ^'' ].
     aValue isCollection
        ifTrue: [^aValue collect: [ :each | self asString: each]].
    ^aValue printString! 
product: magnitude1 and: magnitude2
        " Answer the product of magnitude1 and magnitude2. "
    ^(self asNumber: magnitude1)
        * (self asNumber: magnitude2)!   
propertyValue: anObject
        " for property dialog "
    | icon newValue |
    newValue:= ( anObject isString
        ifTrue: [ anObject asNumber ]
        ifFalse: [ anObject ] ).
    super propertyValue: newValue.
    (icon := self partIcon) isPARTSTextIcon
        ifTrue: [ icon connectionValueChanged ]!   
partMessagesOfValue
        " Private "
    | relayedMessages valueInterface valueMessages |
    ( class isNil or: [ class == Object ] )
         ifTrue: [ ^nil ].  " can't relay unless class specified "
    " filter holder methods from value's messages "
    valueInterface := ( self value isNil
        ifTrue: [ class basicNew ]
        ifFalse: [ self value ] )
            partMessages.
    relayedMessages := self partMessagesRelayedToValue.
    valueMessages := valueInterface items
        reject: [ :aSelector |
            ( ( relayedMessages includes: aSelector ) not
            and: [ self respondsTo: aSelector ] ) ].
    valueMessages size = 0  " should never happen, but... "
         ifTrue: [ ^nil ].
    ^valueMessages size = valueInterface items size
        ifTrue: [ valueInterface ]  " retain original separators and order "
        ifFalse: [
            PARTSInterfaceList new
                items: valueMessages asSortedCollection asArray ]! 
at: aKey put: anObject
        "Answer anObject.  If the receiver contains
         the key/value pair whose key equals aKey,
         replace the value of the pair with anObject.
         Else add the aKey/anObject pair."
    self add: (Association key: aKey value: anObject).
    ^anObject!
keyMessageName: aKey
        " Private "
    ^aKey asSymbol!
currentDate
        " Answer the current date. "
    ^Date today!   
lookup: aSelector arguments: arguments
        " Answer the value of the key aSelector. "
    | index |
    index := (aSelector copyFrom: ('element' size + 1)
                    to: aSelector size) asInteger.
    ^self at: index!   
setValue: anObject
        " Store a new value in the receiver. "
" Prevents crash on cyclic changed: --- > setValue: links [MR 24-Oct-94] "
    anObject ~= value
        ifTrue: [
                ( self isValidObject: anObject )
                ifFalse: [ ^nil ].
                    value := anObject.
                    self
                        setEventActionsOfValue;
                        triggerChangedEvent ].
    ^anObject! 
propertyValue: anObject
        " for property dialog "
    value := anObject.! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #closed )
        defaultItem: #closed!
initialize
        " Private "
    super initialize.
    self  pattern: '*.*'.!
buttonValues
        " Private - answer the values to associate with 
        each button on the dialog. "
    ^Array with: true with: false with: nil!
directoryContaining: aPathName
        " Private - answer the Directory containing
        the file named aPathName. "
    | answer |
    answer := Directory pathName: ( aPathName
        copyFrom: 1
        to: ( aPathName size - aPathName fileNameLessPath size ) ).
    ^answer valid
        ifTrue: [ answer ]
        ifFalse: [
            self triggerEvent: #noSuchFileException: with: answer pathName.
            nil ]! 
typeMarker
    ^typeMarker!  
printScreen
        "Print the entire screen to the current printer; if necessary,
        wrap the printout in a print job"

    | aBitmap |
    aBitmap := Bitmap fromScreen: Display boundingBox.
    CursorManager execute 
		changeFor: [
    		self print: aBitmap.
    		aBitmap release ].!  
parameters
    ^parameters!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | operationMessages |
    ^( operationMessages := self partMessagesOperations )
        concatenateSeparated: self partMessagesProperties
        defaultItem: operationMessages defaultItem!   
beep: frequency for: duration
    <api: BEEP ulong ulong none>
    ^self error: 'Unable to access user primitive.'! 
triggerConditionFailed: aValue
        " Private - trigger the link junction trigger-unsatisfied
        event, passing along aValue. "
    ^self triggerEvent: #triggerFailed: with: aValue!  
partOpenPrintDialog: aPropertyButton
    " Private - Open the Print Dialog and save the printer setup information. "
    | newPrinter  |
    newPrinter := PrintDialog new
		openOn: self printer;
		printer.
    newPrinter isNil ifTrue: [^nil].
    aPropertyButton newValue: newPrinter.!  
rename: aPathName to: newPathName
        " Rename the file named aPathName. "
    | exception |
    exception:= false.
    ( self isValidFile: aPathName )
        ifFalse: [ exception:= true ].
    ( self isValidPathName: newPathName )
        ifFalse: [ exception:= true].
    exception ifTrue: [ ^self ].
    [ File rename: aPathName to: newPathName ]
       on: Error do: [ :e | self triggerFileExceptionEvent: e description ]! 
installPartRuntimeLibrary
        " Private - install the basic nonvisual parts runtime library.
        Load the workbench support library if appropriate. "

    "self 
		initializeRuntimeData;
		initializeSessionEventHandlers." "handled by package initializer (DKH, 5-4-95)"
    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Basic Nonvisual Parts'.!   
delete: directoryName
        " Delete the directory named directoryName.
        Answer whether successful. "

    | pathInfo newDriveLetter newDirectoryPath directory |

    pathInfo := self resolveDirectoryName: directoryName.
    pathInfo isNil
        ifTrue: [ ^false ].

    newDriveLetter := pathInfo at: 1.
    newDirectoryPath := pathInfo at: 2.
    directory := self
        directoryOn: newDriveLetter
        directoryPath: newDirectoryPath.
    directory isNil
        ifTrue: [
            self triggerDirectoryExceptionEvent: directoryName.
            ^false ].

    [ directory remove ]
        on: Error do: [ :e |
            self triggerOperationExceptionEvent: e description.
            directory valid ifTrue: [ ^false ] ].
    self triggerSubdirectoriesEvent.
    ^true!  
selectAPrinter
        "Select a printer name from the list of known printers"
    | answer |
    answer := ListDialog new
        title: 'Select a printer';
        openOn: Printer printerNames
            selection: Printer defaultPrinterName.
    answer isNil ifTrue: [^nil].
    self setPrinterName: answer.
    ^answer! 
style
        " Private - answer the style flags "
    ^style!  
escapeChar: aChar
    escapeChar := aChar!   
keyEventName: aKey
        " Private "
    ^('changed', aKey, ':') asSymbol!
valueIsNil
    ^value isNil! 
forPWO20Dialog: originalDialog
        " Private - answer a new instance of the receiver
        with its properties set according to the values
        in originalDialog from PWO 2.0 PremadeDiag. "

    ^self new
        title: originalDialog title;
        text: originalDialog text;
        style: originalDialog style;
        yourself! 
updateValue: anArray
        " Update the array held by the receiver
        with the elements of anArray. "
    ((self isValidObject: anArray)
    and: [self isUpdatableFrom: anArray])
        ifFalse: [^nil].
    1 to: (value size min: anArray size) do: [ :i |
        self at: i put: (anArray at: i)].
    ^anArray!
initialize
        " Private - initialize new instance. "
    jobStarted := false.
    wrap := true.!  
triggerKeyException: keyOrIndex
        " Private "
    self triggerEvent: self keyExceptionEvent with: keyOrIndex.
    ^nil!  
parameterNames: aCollection
    parameterNames := aCollection!   
partMessagesOperations
        " Private - answer the PARTS message interface of the receiver
       for the operations sections of the protocol. "

    ^PARTSInterfaceList new
        items: #(
            #pathNameForOpen #pathNameForOpen:
            #pathNameForSave #pathNameForSave: )
        separators: #( 2 )
        defaultItem: #pathNameForOpen! 
triggerIfFalse: aBoolean
        " Trigger the link junction if aBoolean is false. "
    ^self trigger: aBoolean condition: aBoolean not!   
keyMessages
        " Private "
    ^self implementedBySubclass!
patternClass
    ^Pattern!   
itemSet: aSymbol arguments: arguments
        " Private - "
    | aValue |
    self parameters size = 0
        ifTrue: [^self reportException: 'No parameters defined'].
    aValue := arguments at: 1.
    self parameters
        at: (aSymbol
            copyFrom: (self messagePrefix size + 1)
            to: (aSymbol size - 1)) asString
        put: aValue.
    ^aValue!   
clearSizeThreshold
        " Clear the size threshold (alway read entire file). "
    sizeThreshold := nil.!
isValidTemplate: newTemplate
    startMarker: startMarkerChar
    endMarker: endMarkerChar
        " Private - answer whether newTemplate is valid. "
    | newStringTemplate newParameterNames |
    newStringTemplate := stringTemplate copy.
    newStringTemplate
        startMarker: startMarkerChar;
        endMarker: endMarkerChar;
        template: newTemplate.
    newParameterNames := newStringTemplate parameterNames.
    newParameterNames isNil ifTrue: [^true].
    newParameterNames do: [ :aName |
        ((self respondsTo: (self itemGetMessage: aName))
        or: [self respondsTo: (self itemSetMessage: aName)])
            ifTrue: [
                MessageBox
                    notify: 'Message Conflict'
                    withText:
                        'Cannot use ''', aName,
                        ''' as a parameter name (already used as a message name).'.
                ^false].
        ].
    ^true!   
tick
        " A timer tick event has occurred. "
    | eventHandler |
    self triggerEvent: #ticked.
    ( eventHandler := self actionForEvent: #tickedTime: ) notNil
        ifTrue: [ "check for performance"
            eventHandler evaluateWithArguments:
                (Array with: self currentTime) ].!   
is: aValue equalTo: anotherValue
        " Trigger the true event if aValue
        is equal to anotherValue;
        otherwise trigger the false event. "
    ^self generateEvent: (aValue = anotherValue)!  
setEventActionsOfValue
        " Private - if events from the contained value
        are surfaced in the receiver's application,
        attach the event actions to the actual triggering object.
        This is only done in the executing application,
        where links have already been installed as
        real event table entries. "

    | anAction |
    ( value notNil and: [ self relayEventsFromValue ] )
        ifTrue: [
            self partEventsOfValue items do: [ :anEvent |
                anAction := self actionForEvent: anEvent.
                anAction notNil
                    ifTrue: [ value when: anEvent evaluate: anAction ].
                ].
            ].! 
dialogAnswer: anAnswer
        " Private - the info dialog has been closed. "

    ( anAnswer isPARTSException "Closed via sys menu"
        or: [ anAnswer ])
        ifTrue: [self triggerEvent: #closed].!
endMarker: aString
    endMarker := aString! 
isSetMessage: aString
        " Private "
    ^((aString copyFrom: 1
            to: ('set' size min: aString size))
        = 'set')!
getBitmap
        " Answer the system clipboard contents as a bitmap. "
    | value |
    (value := Clipboard getBitmap) isNil
        ifTrue: [self triggerEvent: #getException]
        ifFalse: [self triggerEvent: #gotBitmap: with: value].
    ^value!
fileName
    "Private - Answer the file name of the dll."

    ^'pwwspk30'!
partMessagesOperations
        " Private - answer the PARTS message interface of the receiver
       for the operations sections of the protocol. "
    ^self implementedBySubclass!   
printer
        " Return the printer "
    printer isNil
        ifTrue: [self getAPrinter].
    ^printer!
launchPartFile: pathName
        "Launch a part file in either EXE or PAR form."
    | app |
    pathName size = 0 ifTrue: [^self].
    CursorManager execute change.
    [ app := PARTSApplication loadPartFile: pathName ]
        on: PARTSApplicationLoadError
        do: [ :anException |
            CursorManager normal change.
            ^self triggerLaunchException: anException messageText ].
    app isLaunchable
        ifFalse: [
            CursorManager normal change.
            ^self triggerLaunchException:
                pathName, ' does not contain a launchable PARTS application (no link defined for open event).'].
    app
        enableExecution;
        open.
    CursorManager normal change.!  
asInteger: aValue
        " Answer aValue as an integer. "
    (aValue isString or: [aValue isNumber])
        ifTrue: [^aValue asInteger].
    aValue isNil
        ifTrue: [ ^'' asInteger ].
    aValue isCollection
        ifTrue: [^aValue collect: [ :each | self asInteger: each]].
    ^aValue!  
addAll: aCollection
        "Answer aCollection.  Add each element of
         aCollection to the elements of the receiver."
    aCollection do: [ :element | self add: element].
    ^aCollection!   
itemGetMessages
        " Private "
    ^self parameterNames collect: [ :aName |
        self itemGetMessage: aName ]! 
partHasOtherEvents
        " Answer whether the receiver can be asked
        for events other than what it has already
        provided in its partEvents. A ValueHolder
        does not yet support Other events because we
        do not have the UI support available to differentiate
        between the protocols of the holder and the value, 
        both of which are potentially of interest. "

    ^false!   
font: aFont
        " Set the receiver's font. "
    aFont isNil ifTrue: [^self].
    font := aFont.!  
template
        " Answer the template string. "
    ^self stringTemplate template! 
copyString: aString
        " Copy aString to the system clipboard. "
    | str |
    str := ( aString isString
        ifTrue: [ aString ]
        ifFalse: [
            aString isNil
                ifTrue: [ '' ]
                ifFalse: [ aString asString ] ] ).
    str isEmpty
        ifTrue: [ Clipboard clear ]
        ifFalse: [
            ( Clipboard setString: str ) isNil
                ifTrue: [ self triggerEvent: #copyException ] ].!   
at: anIndex put: anObject
        "Answer anObject.  Store anObject at
        position anIndex in the array."
    (anIndex between: 1 and: value size)
        ifFalse: [^self triggerKeyException: anIndex].
    value at: anIndex put: anObject.
    showKeys ifTrue: [
        self triggerEvent: (self keyEventName: anIndex)
             with: anObject ].
    ^anObject! 
changeValueBy: aNumber
        " Add aNumber to the value. "
    value := value + aNumber.
    self triggerChangedEvent.
    ^value!  
parameterTypes: anArray
        " Private - "
    parameterTypes := anArray!
create: directoryName
        " Create a directory named directoryName.
        Answer whether successful. "

    | pathInfo newDriveLetter newDirectoryPath directory |

    pathInfo := self resolveDirectoryName: directoryName.
    pathInfo isNil
        ifTrue: [ ^false ].

    newDriveLetter := pathInfo at: 1.
    newDirectoryPath := pathInfo at: 2.
    directory := self
        directoryOn: newDriveLetter
        directoryPath: newDirectoryPath.
    directory notNil
        ifTrue: [   "Already exists"
            self triggerDirectoryExceptionEvent: directoryName.
            ^false ].

    directory := self
        directoryOn: newDriveLetter
        directoryPath: newDirectoryPath fileNamePath.
    directory isNil
        ifTrue: [   "Path doesn't exist"
            self triggerDirectoryExceptionEvent: directoryName.
            ^false ].

    directory := Directory pathName:
        (self driveNameString: newDriveLetter),
        newDirectoryPath.
    [ directory create ]
        on: Error do: [ :e |
            self triggerOperationExceptionEvent: e description.
            directory valid
                ifFalse: [ ^false ] ].
    self triggerSubdirectoriesEvent.
    ^true!
triggerSubdirectoriesEvent
        " Private "
    self triggerEvent: #subdirectories: with: self subdirectories.!  
keyEvents
        " Private "
    ^self implementedBySubclass!  
defaultEndMarker
    ^']'!   
fileTextToThreshold: aPathName
        " Answer the contents of the file named
        aPathName.  Signal sizeException: if
        the size threshold is exceeded and
        the partial file contents will be returned
        unless someone handles the condition. "
    ^[ self fileTextToThresholdBasic: aPathName ]
        on: Error do: [ :e | self triggerFileExceptionEvent: e description ]!  
openText: textString
        " Open the message dialog with the current
        title and textString as the text. "
    ^self openTitle: title text: textString!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #is:equalTo: #is:notEqualTo:
                #is:identicalTo: #is:notIdenticalTo:
            #is:greaterThan: #is:greaterThanOrEqualTo:
            #is:lessThan: #is:lessThanOrEqualTo:)
        separators: #( 4 )
        defaultItem: #is:equalTo:!  
initialize
        "Private - Initialize instance variables."
    interval := self defaultInterval! 
partMessagesProperties
        " Private - answer the PARTS message interface of the receiver
       for the property accessing sections of the protocol. "
    ^self class supportsNonSuspendedInvocation
        ifTrue: [
            PARTSInterfaceList new
                items: #(
                    #waitForAnswer #setWaitForAnswer:
                    ) ]
        ifFalse: [ PARTSInterfaceList emptyList ]!   
itemSetMessages
        " Private "
    ^self parameterNames collect: [ :aName |
        self itemSetMessage: aName ]! 
keyMessageName: anInteger
        " Private "
    ^('element', anInteger printString) asSymbol! 
keyExceptionEvent
        " Private "
    ^#keyException:!  
setWaitForAnswer: aValue
        " Answer whether the client of a modal
        dialog is suspended until the dialog
        is closed. "

    | aBoolean |
    aBoolean := self asBoolean: aValue.
    aBoolean isBoolean
        ifFalse: [ ^self error: 'Must be true or false' ].
    self suspendClient: aBoolean.
    ^aBoolean!  
dialogAnswer: anAnswer
        " Private - the prompter has an answer. "
    anAnswer isNil
        ifTrue: [^self triggerEvent: #cancel].
    anAnswer
        ifTrue: [^self triggerEvent: #yes].
    anAnswer
        ifFalse: [self triggerEvent: #no].!   
triggerIfNil: aValue
        " Trigger the link junction if aValue is nil. "
    ^self trigger: aValue condition: aValue isNil! 
dialogAnswer: anAnswer
        " Private - the prompter has an answer. "
    anAnswer
        ifTrue: [^self triggerEvent: #yes].
    anAnswer
        ifFalse: [self triggerEvent: #no].!   
removeBlanks
        " Answer whether leading and trailing blanks
        should be trimmed from the user's response. "
    ^removeBlanks! 
pattern
        " Answer the pattern string used to filter
        the file name list in a directory. "
    ^pattern!  
updateValue: aCollection
        " Update the value held by the receiver
        with the elements of aCollection. "
    self implementedBySubclass!   
defaultStartMarker
    ^'['! 
partMessagesOperations
        " Private - answer the PARTS message interface of the receiver
       for the operations sections of the protocol. "

    ^PARTSInterfaceList new
        items: #(
            #open #openText: #openTitle:text: )
        defaultItem: #open! 
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "

    diagBox notNil
        ifTrue: [ diagBox partWrapper: myWrapper ].
    ^super partAddUnder: parentWindow wrapper: myWrapper.! 
currentTime
        " Answer the current time. "
    ^Time now! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'OrderedCollection Holder'!  
setChoicesAbortRetryIgnore
        "Configure the reciever to display the user's choices as 'Abort', 'Retry', and 'Ignore'."
    self style: MbAbortRetryIgnore!
setChoicesRetryCancel
        "Configure the reciever to display the user's choices as 'Retry' and 'Cancel'."
    self style: MbRetryCancel!
drivePathName
        " Private - answer the current drive and directoryPath. "
    ^drive isNil
        ifTrue: [ nil ]
        ifFalse: [ (self driveNameString: drive), directoryPath ]!   
text
        " Answer the message text. "
    ^text!
relayMessage: aSelector arguments: arguments
        " Private - OBSOLETE - retained only to support
        alias links transparted from PARTS for OS/2,
        which in early implementations had their behaviors
        provided by a cached diagBox instance and
        had to relay messages.  In this design, the part
        knows how to behave itself. "
    ^self perform: aSelector withArguments: arguments!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            	#fileException:
                #noSuchFileException: 
				#fileNameException:
                #sizeException:
            #existsTrue: )
        separators: #( 4 )
        defaultItem: #noSuchFileException:!
style: aButtonLabelConstant
        " Private "
    super style: MbIconQuestion | aButtonLabelConstant! 
dialogBoxCreate
        " Private - answer a dialog box for the receiver. "
    ^PARTSMessageBox new
        "style: self style;"  " set at open time (no instance on VW) "
        buttonValues: self buttonValues;
        closedAction: self dialogClosedAction;
        yourself!   
openTitle: titleString text: textString
        " Open the message dialog with titleString as the title
        and textString as the text. "

    ^self openDialogMessage: ( Message
        receiver: self dialogBoxCreate
        selector: #openTitled:withText:style:
        arguments: ( Array
            with: ( self asString: titleString )
            with: ( self asString: textString )
            with: self style ) )!