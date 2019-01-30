3.1.0.106
   
= anObject
        "This is the default equality test.  Answer true
         if the receiver and anObject are the same object,
         else answer false."
    <primitive: 110>! 
== anObject
        "Answer true if the receiver and anObject
         are the same object, else answer false."
    <primitive: 110>!  
isNil
        "Answer true if the receiver is
         the object nil, else answer false."
    ^false! 
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream.  This is the default implementation which
         prints 'a' ('an') followed by the receiver class name."
    | aString |
    aString := self class name.
    (aString at: 1) isVowel
        ifTrue: [aStream nextPutAll: 'an ']
        ifFalse: [aStream nextPutAll: 'a '].
    aStream nextPutAll: aString!  
isClass
		"Answer true if receiver is a kind of Class."
	^false 
! 
vmInterrupt: aSymbol
        "Private - Process virtual machine interrupt.  This method is called
        by the virtual machine.  It is entered with interrupts disabled.  The
        interrupt handler should enable interrupts at the appropriate time."
    Process perform: aSymbol.
    ^self!
printString
        "Answer a String that is an ASCII representation
         of the receiver."
    | aStream aString |
    aString := String new: 20.
    self printOn: (aStream := WriteStream on: aString).
    ^aStream contents!   
notNil
        "Answer true if the receiver is not
         the object nil, else answer false."
    ^true! 
new
	"Reimplemented to not send initialize"
	^self basicNew !   
class
        "Answer the class of the receiver."
    <primitive: 111>
    ^self primitiveFailed!  
isBehavior
        "Answer true if receiver is a kind of Behavior."
    ^false! 
doesNotUnderstand: aMessage
        "Sent to the receiver by the virtual machine when the <message>
        sent to the receiver was not implemented by the receiver."
	self implementedBySubclass
 ! 
aboutToSaveImage
		" Do nothing. "

!  
isMetaClass
        "Answer true if receiver is a kind of MetaClass."
    ^false!   
sleep: milliSeconds
	<api: Sleep ulong none>
	^self invalidArgument!
cachedAddress
		"Private - Answer cached address for receiver."
	| value | 

	^( self isAPIMethod )
		ifTrue: [
			value := ( ( self at: 2 ) copyFrom: 1 to: 4 ) asExternalAddress.
			( value = ( ExternalAddress fromInteger: -1 ) )
				ifTrue: [ nil ]
				ifFalse: [ value ] ]
		ifFalse: [ nil ]
	!  
argumentTypeSymbolForNumber: typeNumber ifAbsent: aBlock
		"Answer the type symbol (e.g., #ushort) for the type of the given integer number"
	^Types keyAtValue: typeNumber ifAbsent: aBlock!   
waitForSingleObject: eventSemHandle duration: int
    <api: WaitForSingleObject ulong ulong ulongReturn>
    ^self invalidArgument! 
nonBlockingInterface 
		" Set the blockingInterface to false so Smalltalk will not block 
		  during execution of the apiCall. "
	^( DLLInterface for: self )
		apiBlocking: false!   
resetEvent: aHandle
	<api: ResetEvent ulong boolean>
	^self invalidArgument!
startup
        "Private - Smalltalk has been launched."
    OperatingSystem isWin32s ifTrue: [ ^self ].
    APICallLibrary := APICallDLL open.
    ActiveCalls := Dictionary new.
    EarlyCompletionQueue := Dictionary new.

    self createAPISemaphore.

    OperatingSystemEventsExtra removeKey: WmThreadcomplete ifAbsent: [ ].
    WmThreadcomplete := nil.
    WmThreadcomplete := self wmThreadcomplete.  "register the message, and reassign WmThreadcomplete"
    OperatingSystemEventsExtra at: WmThreadcomplete put: #wmThreadcomplete:with: .!
for: aDLL
		"Answer an instance of the receiver which can be used to generate APICalls to the given DLL. Don't forget to set apiBlocking: in the new instance to a boolean based on the desired behavior."
	^self basicNew veryPrivateSetLibrary: aDLL! 
veryPrivateSetLibrary: aDLL
		"Private - Set the receiver's instance variables."
	library := aDLL.
	blocking := false! 
doesNotUnderstand: aMessage
		"Private - Answer result value of api call. First, the api call must be initialized and
		 setup with the proper selector and arguments."
	| api |

	api := APICall to: library blocking: blocking call: aMessage copy.
	api start.
	^api
! 
apiBlocking: aBoolean
		"Private - Set the receiver's instance variable to aBoolean."
	blocking := aBoolean!
messageText
        "Answer the message text associated with this exception."
    ^'Thread failed to start. Reason unknown.'!   
createEvent: aSecAttr manualReset: aBool1 initState: aBool2 eventName: aString
	<api: CreateEventA struct boolean boolean struct ulongReturn>
	^self invalidArgument!   
expected: expect got: got
		"Private - Set the receiver's instance variables."
	^self new setExpectedNumber: expect actualNumber: got

		!
doesNotUnderstand: aMessage
		" Answer a new copy of aMessage. "
	^aMessage copy receiver: nil! 
resultTypeSymbolForNumber: typeNumber ifAbsent: aBlock
		"Answer the type symbol (e.g., #ushort) for the type of the given integer number"
	^Types keyAtValue: typeNumber ifAbsent: aBlock! 
processThreadCompletionFor: anAPICall withResult: result
        "Private - Process the completed thread from anAPICall."
    [ anAPICall recordResultFromExternalLong: result.
      anAPICall state: APICallStateDone
    ] ensure: [ self recordAPIShutdown: anAPICall.
                anAPICall apiEndSemaphore setEvent]!  
in: aDLL selector: aSelector
		"Private - Set the receiver's instance variables."
	^self new setDLL: aDLL selector: aSelector!  
messageText
		"Answer the message text associated with this exception."
	^'Message ', selector printString, ' is not an API entry point in ', dll printString!  
setDLL: aDLL selector: aSelector
		"Private - Set the receiver's instance variables."
	dll := aDLL.
	selector := aSelector!
was: state1 shouldHaveBeen: state2
		"Private - Set the receiver's instance variables."
	^self new setWas: state1 shouldHaveBeen: state2!   
messageText
		"Answer the message text associated with this exception."
	^'API call had unexpected state #', was printString, '. Expected #', shouldHaveBeen printString!   
setWas: state1 shouldHaveBeen: state2
		"Private - Set the receiver's instance variables."
	was := state1.
	shouldHaveBeen := state2.! 
messageText
		"Answer the message text associated with this exception."
	^'API call had wrong number of arguments: ', actualNumber printString, ' instead of desired ', expectedNumber printString! 
setExpectedNumber: expect actualNumber: actual
		"Private - Set the receiver's instance variables."
	expectedNumber := expect.
	actualNumber := actual!
createAPISemaphore
		"Private - Create an event semaphore for api call."
	| addr eventHandle |
	addr := VirtualMachineLibrary queryProcAddr: 'apiSem'.
	eventHandle := KernelLibrary
		createEvent: nil
		manualReset: false
		initState: false
		eventName: nil.
	eventHandle isNil ifTrue: [ ^self osError ].
	addr replaceBytes: 4 with: ( ExternalLong fromInteger: eventHandle) contents.
	APISemaphore := WindowsEventSemaphore new
		hev: ( ExternalLong atAddress: addr ) asInteger
	
! 
forResultType: aSymbol
		"Private - Set the receiver's instance variable."
	^self new type: aSymbol!
messageText
		"Answer the message text associated with this exception."
	^'Non-blocking API call had unsupported return type: #', type
!   
type: aSymbol
		"Private - Set the receiver's instance variable."
	type := aSymbol! 
fileName
		"Private - Answer the file name of the dll."
	^'vnbap', SmalltalkLibrary versionAndPlatformExtension!
blockingInterface 
		" Set the blockingInterface to true so Smalltalk will block 
		  during execution of the apiCall. "
	^( DLLInterface for: self )
		apiBlocking: true!
template
		" Answer a new instance of a MessageTemplate. "
	^MessageTemplate basicNew!  
cachedAddress: anExternalAddress
		"Private - Set receiver's cached address to anExternalAddress."
	( self isAPIMethod )
		ifTrue: [
			( self at: 2 ) replaceBytesFrom: 1
				to: 4
				with: anExternalAddress contents
				startingAt: 1 ]! 
startNonBlocking
        "Private - Execute the actual non-blocking api call."
    | failure createThreadFailureCode |

    self assertState: APICallStateInitial.
    method := self constructCompiledMethod.
    failure := ExternalLong new.
    createThreadFailureCode := ExternalLong new.
    APISemaphore reset.
    vmEntryPoint := VirtualMachineLibrary queryProcAddr: 'apiSysNB'.

    tid := APICallLibrary
        dispatchThread: address asInteger
        compiledMethod: method
        arguments: arguments
        postHandle: SystemWindow current handle asInteger
        hev: APISemaphore hev
        immediateFailure: failure asParameter
        stackSize: self stackSize
        vmDispatchAddress: vmEntryPoint asInteger
        createThreadFailureCode: createThreadFailureCode asParameter
        hevEnd: apiEndSemaphore hev.

    ( tid = 0 )
        ifTrue: [
            "thread creation failed"
            self state: APICallStateFail.
            ^self osError: createThreadFailureCode asInteger ].

    APISemaphore waitForSingleObject: 5000 onTimeout: [
        "Thread failed to get off the ground"
        self state: APICallStateFail.
        ^APICallThreadDidNotStart signal ].

    "Check if we had trouble executing the API"
    ( failure asInteger = 0 )
        ifFalse: [ ^self state: APICallStateFail ].

    "Record the startup"
    self state: APICallStateRunning.
    self class recordAPIStartup: self!
setEvent: aHandle
	<api: SetEvent ulong boolean>
	^self invalidArgument!
recordThreadCompletion: tid withResult: result
		"Private - If we already know about this thread, process its completion now.  If not, we assume a race is going on and we will soon be told about the startup.  In this case we just queue up the completion information and process the completion automatically when we process the startup."

	( ActiveCalls includesKey: tid )
		ifTrue: [ self processThreadCompletionFor: ( ActiveCalls at: tid ) withResult: result ]
		ifFalse: [ EarlyCompletionQueue at: tid put: result ]


! 
wmThreadcomplete: anInteger
        "Private - set the WmThreadcomplete class variable to anInteger."
    WmThreadcomplete := anInteger!
activeCalls
		"Answer a Bag of active instances of the receiver"
	^ActiveCalls values!  
initialize
		" Initialize the APICall class. "
	SessionModel current
		when: #startup send: #startup to: self;
		when: #shutdown send: #shutdown to: self.
	self startup!
eventsTriggered
        "Answer all the events which can be triggered
         by instances of the receiver. "
    ^Set new
        add: #fail ;
        add: #done;
        yourself!  
unbound
		" Cleanup APICall related objects. "
	SessionModel current
        removeActionsWithReceiver: self forEvent: #startup;
        removeActionsWithReceiver: self forEvent: #shutdown.
	self shutdown.
	OperatingSystemEventsExtra removeKey: self wmThreadcomplete ifAbsent: [ nil ]!   
new
	"Answer a new instance of the receiver."

	^super new initialize! 
shutdown
		"Private - Perform the api call #shutdown processing."
	self destroyAPISemaphore!
bound
        "Private - the receiver's component was bound."
    self initialize
!
recordAPIShutdown: anAPICall
		" Cleanup Smalltalk objects for anAPICall. "
	ActiveCalls removeKey: anAPICall tid ifAbsent: [].
	self triggerEvent: #threadShutdown: with: anAPICall

!  
destroyAPISemaphore 
		"Private - Close and free the api semaphore handle."
	( APISemaphore notNil )
		ifTrue: [
			APISemaphore close.
			APISemaphore := nil ]


	
	!  
recordAPIStartup: anAPICall
		"Private"
    ActiveCalls at: anAPICall tid put: anAPICall.
	self triggerEvent: #threadStartup: with: anAPICall.

	"Check first to see if we already have the completion information for this thread queued up."
	( EarlyCompletionQueue includesKey: anAPICall tid )
		ifTrue: [
			self recordThreadCompletion: anAPICall tid withResult: ( EarlyCompletionQueue at: anAPICall tid ).
			EarlyCompletionQueue removeKey: anAPICall tid ]

!
to: aDLL blocking: aBoolean call: aMessage
	"Answer a new instance of the receiver that can be used to perform an API call to the given DLL with the selector and arguments defined in aMessage"

	^self new 
		blocking: aBoolean;
		setCall: aMessage in: aDLL!
assertState: aState
		" Verify that the apiCall is in the correct state. " 
	( state = aState )
		ifFalse: [ ( APICallUnexpectedState was: state shouldHaveBeen: aState ) signal ]!
resultType
		"Answer a symbol (e.g., #ushort) for the type of object that the api returns"
	^DynamicLinkLibrary resultTypeSymbolForNumber: method apiReturnType ifAbsent: [#unknownReturnType]! 
setCall: aMessage in: aDLL
		"Private - Validates aMessage as an api for aDLL. Validates the number of arguments.
		 Validates argument types. Sets up the receiver (instance of APICall) for the actual
		 api call."
	| dllMethod |
	( ( dllMethod := aDLL class compiledMethodAt: aMessage selector ) notNil
		and: [ dllMethod isAPIMethod ] )
		ifFalse: [ ( APICallNotAPIMethod in: aDLL selector: aMessage selector ) signal ].
	( dllMethod apiArgumentCount = aMessage arguments size )
		ifFalse: [ ( APICallIncorrectArgumentCount expected: dllMethod apiArgumentCount got: aMessage arguments size ) signal ].
	( ( address := dllMethod cachedAddress ) isNil )
		ifTrue: [
			( ( address := aDLL queryProcAddr: dllMethod apiName ) isExternalAddress )
				ifFalse: [ ( APICallEntryPointNotFound in: aDLL entryPointName: dllMethod apiName ) signal ].
			dllMethod cachedAddress: address ].
	arguments := aMessage arguments asArray.    "Must be an array for the primitives!!"
	types := dllMethod apiArgumentTypes, ( Array with: dllMethod apiReturnType ). 
	selector := aMessage selector.
	library := aDLL! 
apiEndSemaphore
        "Private - answer the Semaphore which is used to signal API completion."
    ^apiEndSemaphore!  
isBlocking
		"Answer true if api call is a blocking api."
	^blocking!   
state
		"Answer the state of the receiver."
	^state!
state: aNewState
        "Private - Initialize the state instance variable and trigger event if appropriate."
    state := aNewState.
    (state = APICallStateDone)
        ifTrue: [self triggerEvent: #done].
    (state = APICallStateFail)
        ifTrue: [self destroyApiEndSem.
                 self triggerEvent: #fail]!
blocking
		"Answer true if this is a blocking api call."
	^blocking!
blocking: aBoolean
		"Private - Set receiver's instance variable to aBoolean."
	blocking := aBoolean!   
recordResultFromExternalLong: res
		"Return and record the result of the receiver apiCall
        based on the resultType."
 
	(self resultType = #ulong or: [self resultType = #handle])
		ifTrue: [^result := res contents asString].
	(self resultType = #ulongReturn)
		ifTrue: [^result := res uLongAtOffset: 0].
	(self resultType = #ushort)
		ifTrue: [^result := res uShortAtOffset: 0].
	(self resultType = #long)
		ifTrue: [^result := res longAtOffset: 0].
	(self resultType = #short)
		ifTrue: [^result := res shortAtOffset: 0].
	(self resultType = #none)
		ifTrue: [^result := nil].
	(self resultType = #boolean)
		ifTrue: [res asInteger = 0
			ifTrue: [^result := false]
			ifFalse: [^result := true]].
	( APICallUnexpectedResultType forResultType: self resultType ) signal! 
isRunning
		"Answer true if api call is still active."
	^state = APICallStateRunning!   
stackSize
		"Answer the stack size of the thread."
	^stackSize
!   
stackSize: numberOfBytes
		"Set the stack size of the thread to numberOfBytes."
	stackSize := numberOfBytes!
startBlocking
		"Private - Execute the actual blocking api call."
	self assertState: APICallStateInitial.
	self state: APICallStateRunning.
	tid := 1.
	self class recordAPIStartup: self.	
	result := library perform: selector withArguments: arguments.
	self state: APICallStateDone.
	self class recordAPIShutdown: self!
constructCompiledMethod
		"Private - Answer a new compiled method."
	| aMethod stream |
	aMethod := CompiledMethod new: 2.
	stream := WriteStream on: (String new: 5 + types size).
	stream 
		putBytesFrom: address contents;
		nextBytePut: types size.
	types do: [:each| stream nextBytePut: each].	
	aMethod at: 2 put: stream contents asByteArray.
	^aMethod!
destroyApiEndSem
        "Private - close the Semaphore which is used to signal API completion."
    (apiEndSemaphore notNil)
        ifTrue: [
            apiEndSemaphore close.
            apiEndSemaphore := nil
        ]!
start
	"Start the actual call.  This either executes the function directly or starts a thread to execute the function depending on the blocking value."
	^( blocking )	
		ifTrue: [ self startBlocking ]
		ifFalse: [ self startNonBlocking ]!
tid
		"Private - Answer thread id."
	^tid!  
result
	"Answer the value returned by the API call.  Note that this value is not defined while #isRunning; it only makes sense once the call is done"
	^result
	!  
wmThreadcomplete
		"Private - Answer the message number for the WM_THREADCOMPLETE message."
	| id |
	WmThreadcomplete isNil ifTrue: [
		( id := UserLibrary registerWindowMessage: 'WM_THREADCOMPLETE' asParameter ) = 0
			ifTrue: [ ^self osError ].
		WmThreadcomplete := id ].
	^WmThreadcomplete! 
dispatchThread: entryPoint compiledMethod: aCompiledMethod arguments: args postHandle: postHandle hev: hev immediateFailure: immediateFailure stackSize: stackSize vmDispatchAddress: vmAddr createThreadFailureCode: createThreadFailureCode hevEnd: hevEnd
    <api: DispatchThread ulong self self ulong ulong struct ulong ulong struct ulong ulongReturn >
    ^self invalidArgument!  
wmThreadcomplete: wordInteger with: longInteger
        "Private - Process the thread completion message."
    | result |
    result := ExternalLong fromInteger: wordInteger asInteger.    "Make a copy"
    APICall recordThreadCompletion: longInteger asUnsigned withResult: result.
    ^nil!   
setEvent
        "Set the event semaphore of the receiver."
    | apiReturn |
    apiReturn := KernelLibrary setEvent: self hev.
    apiReturn ifTrue: [ ^apiReturn ].
    ^self osError!
close
		"Close event semaphore."
	| apiReturn |
	apiReturn := KernelLibrary closeHandle: self hev.
	apiReturn ifTrue: [ ^self ].
	^self osError
!   
hev
		"Answer the handle of the event semaphore."
	^hev!
hev: anInteger
		"Set the handle for the event semaphore."
	hev := anInteger
! 
reset
		"Reset the receiver."
	| apiReturn |
	apiReturn := KernelLibrary resetEvent: self hev.
	apiReturn ifTrue: [ ^apiReturn ].
	^self osError!
waitForSingleObject: timeOutDuration onTimeout: aBlock
        "Wait for timeOutDuration for a setEvent.
          If no setEvent occurs before timing out, evaluate
          aBlock. Otherwise return the value of the api."
    | apiReturn |
    apiReturn := KernelLibrary waitForSingleObject: self hev
                              duration: timeOutDuration.
    (apiReturn = "WAIT_TIMEOUT" 16r102 )
              ifTrue: [^aBlock value].
    ^apiReturn!   
initialize
		" Initialize the APICall class. "
     | eventHandle |
    self state:  APICallStateInitial.
    stackSize := 30000.
    completionSemaphore := Semaphore new.
    eventHandle := KernelLibrary
        createEvent: nil
        manualReset: false
        initState: false
        eventName: nil.
    (eventHandle = 0) ifTrue: [ ^self osError ].
    apiEndSemaphore := WindowsEventSemaphore new
        hev: eventHandle!