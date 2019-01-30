3.1.0.106
   
unbound
        "Private - unhook the receiver from the event notification system
        upon unbind."
    self hostEvents keysDo: [ :key |
        OperatingSystemEvents at: key put: nil ]!
ddePoke: sender format: format data: data item: item release: release handle: hData
        "Private - default handling for ddePoke."
    | accept |
    accept := false.
    ( ( receiverObj respondsTo: #ddePokeItem:object: )
            and: [ format = CfText ] )
        ifTrue: [ accept := receiverObj ddePokeItem: item object: data ].
    accept
        ifFalse: [ dde ackNotAcceptTo: sender item: item ]
        ifTrue: [
            dde ackAcceptTo: sender item: item.
            release ifTrue: [
                ( KernelLibrary globalFree: hData ) = 0
                    ifFalse: [ ^self osError ] ] ]!  
singleExecute: application topic: topic commandString: aCommandString
        "Make a single Dynamic Data Exchange request and answer the
         result as a String.  This initiates a conversation, sends
         the request, waits for the response, and terminates the
         conversation.  Answer true if successful, otherwise false."
    | dde result |
    ( dde := self newClient: nil application: application topic: topic ) isNil
        ifTrue: [ ^false ].
    result := dde executeCommand: aCommandString.
    dde terminate.
    ^result!  
singlePoke: application topic: topic item: item data: data
        "Send a single DDE execute.  This initiates a
         conversation, sends the command, and terminates
         the conversation.  Answer true if successful, otherwise false"
    | dde result |
    ( dde := self newClient: nil application: application topic: topic ) isNil
        ifTrue: [ ^false ].
    result := dde pokeItem: item object: data.
    dde terminate.
    ^result!   
singleRequest: application topic: topic item: item
        "Make a single Dynamic Data Exchange request and answer the
         result as a String.  This initiates a conversation, sends
         the request, waits for the response, and terminates the
         conversation."
    | dde answer |
    ( dde := self newClient: nil application: application topic: topic ) isNil
        ifTrue: [ ^nil ].
    answer := dde requestItem: item class: String.
    dde terminate.
    ^answer!   
newClient: aClientObj application: application topic: topic
        "Answer an new instance of DDEClient that is involved in a
        DDE conversation with a DDE server of application and topic
        name.  Answers nil if no such conversation could be initiated."
    | dde client |
    dde := self new.
    ( client := DDEAuxClient new open ) isNil ifTrue: [ ^nil ].
    client
        receiverObj: aClientObj;
        dde: dde.
    dde
        client: client;
        isClient: true.
    ( dde initiate: application topic: topic ) ifFalse: [ client close. ^nil ].
    ^dde!  
getDDEObject: anObject
        "Private - Given a Smalltalk object, return
         a transferable DDE object."
    | anObjectClass |
    anObjectClass := anObject class.
    ( ( anObjectClass == String ) or: [ anObjectClass = DoubleByteString ] )
       ifTrue: [ ^anObject ]
       ifFalse: [
          "Update this later as other Smalltalk objects are supported"
          ^anObject printString ]! 
hostEvents
        "Private - answer a Dictionary mapping between host event
        identifiers & their corresponding event handler symbols."
    ^Dictionary new
        at: WmDdeAck put: #wmDdeAck:with: ;
        at: WmDdeAdvise put: #wmDdeAdvise:with: ;
        at: WmDdeData put: #wmDdeData:with: ;
        at: WmDdeExecute put: #wmDdeExecute:with: ;
        at: WmDdeInitiate put: #wmDdeInitiate:with: ;
        at: WmDdePoke put: #wmDdePoke:with: ;
        at: WmDdeRequest put: #wmDdeRequest:with: ;
        at: WmDdeTerminate put: #wmDdeTerminate:with: ;
        at: WmDdeUnadvise put: #wmDdeUnadvise:with: ;
        yourself!   
getDDEFormat: class
        "Private - Given a Smalltalk class this method returns an
         equivalent DDE format."
    class == String ifTrue: [ ^CfText ].
    "insert support for other classes here"
    ^CfText! 
terminate
    "Terminate DDE session."
    self terminateTo: server.
    3000 timesRepeat: [ ].
    client notNil ifTrue: [ client close ].
    client := nil.
    server := nil!   
requestItem: itemName class: aClass
        "Answer the request data from the server about item in a
         format of aClass.  Answers nil if the requested data cannot
         be provided by the server."
    | answer |
    self requestItem: itemName class: aClass selector: #nil.
    answer := client waitForData.
    ^answer!  
server
        "Private - Answer the server window.
         For DDEServer, this is the DDEServer's DDEAuxServer.
         For DDEClient, this is the server's window handle."
    ^server!   
client: aWindow
        "Private - Set client."
    client := aWindow!  
terminateTo: to
        "Private - Terminate the exchange."
    ^self
        postTo: to
        msg: WmDdeTerminate
        lParam: 0!  
initiate: applicationName topic: topicName
        "Private - Initiate a Dynamic Data Exchange conversation
         for the client window in the receiver
         with applicationName about topicName."
    | anApp aTopic |
    self
        application: applicationName;
        topic: topicName.
    anApp := ExternalHandle stringToAtom: application.
    aTopic := ExternalHandle stringToAtom: topic.
    pendingAck:=  #WmDdeInitiate.
    server := nil.

    UserLibrary
        sendMessage: 65535
        msg: WmDdeInitiate
        wparam: client asParameter
        lparam: anApp | ( aTopic bitShift: 16 ).
    ExternalHandle deleteAtom: anApp.
    ExternalHandle deleteAtom: aTopic.
    ^server notNil!
requestItem: item format: format
        "Private - Request data from the server
         about item string  in a desired format.
         format is of clipboard format from
         OperatingSystemConstants pool Dictionary."
    ^self requestTo: server item: item format: format! 
window: aWindow
        "Private - Set window to aWindow for doing
         synchronous DDE exchanges.
         See class message singleRequest:topic:item:."
    aWindow class == DDEAuxWindow
        ifFalse: [ self error: 'wrong kind of window' ].
    window := aWindow.
    window dde: self!  
isClient: aBoolean
        "Private - Set isClient to aBoolean."
    isClient := aBoolean!  
pendingAck
        "Private - returns pendingAck."
    ^pendingAck! 
pendingAck: newPendingAck
        "Private - sets pendingAck with a new value."
    pendingAck := newPendingAck!
application
        "Answer the application name for the receiver."
    ^application!   
application: aString
        "Private - Set application to aString."
    application := aString!
topic
        "Answer the topic name for the receiver."
    ^topic! 
topic: aString
        "Private - Set the topic to aString."
    topic := aString!  
client
        "Private - answer the client window handle.
         For DDEServer, this is a Set of client window handles.
         For DDEClient, this is the DDEClient's DDEAuxClient."
    ^client!
server: aWindow
        "Private - Set the server to aWindow."
    server := aWindow!   
ddeExecute: sender command: command hCommand: hCommand
        "Private - default handling for ddeExecute."
    | ack |
    ack := true.
    ( receiverObj respondsTo: #ddeExecuteCommand: )
        ifTrue: [ ack := receiverObj ddeExecuteCommand: command ].
    dde
        ackExecuteTo: sender
        ack: ack
        busy: false
        appReturnCode: 0
        hCommand: hCommand! 
sendTo: to msg: aDdeMessage lParamLo: lParamLo lParamHi: lParamHi
        "Private - Send aDdeMessage."
    | from answer |
    from := isClient ifTrue: [ client ] ifFalse: [ server ].
    to notNil ifTrue: [
        answer := UserLibrary
            sendMessage: to
            msg: aDdeMessage
            wparam: from asParameter
            lparam: lParamLo | ( lParamHi bitShift: 16 ) ].
   ^answer!
dataRequestedTo: to
    data: data
    format: format
    item: item
        "Private - Send a data that was advised by the client."
    ^self
        dataTo: to
        ackReq: false
        release: true
        requested: true
        format: format
        data: data
        item: item!   
ddeAdviseWarmLink: sender
    ackReq: ackReq
    format: format
    item: item
    hOption: hOption
        "Private - default handling for ddeAdvise."
    | object ddeFormat |
    ( object := dde exportedItemAt: item ) isNil ifTrue: [
        "Give the receiver object the chance to export the item"
        ( ( receiverObj respondsTo: #ddeExportItem: ) and: [ receiverObj ddeExportItem: item ] )
            ifTrue: [ object := dde exportedItemAt: item ] ].

    ddeFormat := DynamicDataExchange getDDEFormat: object class.
    ( object notNil and: [ ddeFormat = format ] )
        ifTrue: [
            self addWarmLinkedItem: item client: sender format: format ackReq: ackReq.
            dde ackAcceptTo: sender item: item.
            ( KernelLibrary globalFree: hOption ) = 0
                ifFalse: [ ^self osError ] ]
        ifFalse: [ dde ackNotAcceptTo: sender item: item ]!
wmDdeExecute: wparam with: lparam
        "Private - ignore DDE message."
    ^nil! 
wmDdeTerminate: wparam with: lparam
        "Private - ignore DDE message."
    ^ nil!  
executeCommand: commandString
        "Request to execute commandString on the server.
         Answers true if the commandString  was executed by the server,
         answers false if it was not."
    |answer|
    self executeTo: server command: commandString.
    answer := client waitForData.
    ^answer!   
wmDdeData: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil! 
wmDdePoke: wparam with: lparam
        "Private - Pass along a Dde message."
    | hData lpData data lParams size item release format value paramArray formattedData |
    ( lParams := self unPackDdeData: lparam asUnsigned msg: WmDdePoke )
        isNil ifTrue: [ ^nil ].

    ( hData := lParams at: 1 ) = 0
        ifTrue: [ ^nil ].
    item := ExternalHandle atomToString: ( lParams at: 2 ).

    ( lpData := KernelLibrary globalLock: hData ) = 0
        ifTrue: [ ^self osError ].
    lpData := ExternalAddress fromInteger: lpData.
    ( size := KernelLibrary globalSize: hData ) = 0
        ifTrue: [ ^self osError ].
    data := ( ExternalBuffer new: size ) fillFromAddress: lpData.
    KernelLibrary globalUnlock: hData.
    release := ( ( data uShortAtOffset: 0 ) bitAnd: 16r2000 ) = 16r2000.
    format := data uShortAtOffset: 2.
    value := data bytesAtOffset: 4 count: size - 4.
    formattedData = value.
    format = CfText
        ifTrue: [
            formattedData := String new: value size.
            formattedData replaceFrom: 1 to: value size
                with: value startingAt: 1.
            formattedData := formattedData asNormalizedString trimNullTerminator ].

    ( paramArray := Array new: 6 )
        at: 1 put: wparam;
        at: 2 put: format;
        at: 3 put: formattedData;
        at: 4 put: item;
        at: 5 put: release;
        at: 6 put: hData.
    ExternalHandle deleteAtom: ( lParams at: 2 ).
    self
        sendInputEvent: #ddePoke:format:data:item:release:handle:
        withArgs: paramArray.

    ^nil!
ddeAckExecute: sender
    ack: ack
    busy: busy
    appReturnCode: appReturnCode
    command: command
        "Private - default handling for ddeAckExecute"
        "Note. Not receiving command string"

    "If waiting for an answer then clear semaphore"
    sem notNil ifTrue: [
        sem signal.
        sem := nil.
        Processor suspendActive]!   
ddeAdviseHotLink: sender
    ackReq: ackReq
    format: format
    item: item
    hOption: hOption
        "Private - default handling for ddeAdvise."
    | object ddeFormat |
    ( object := dde exportedItemAt: item ) isNil ifTrue: [
        "Give the receiver object the chance to export the item"
        ( ( receiverObj respondsTo: #ddeExportItem: ) and: [ receiverObj ddeExportItem: item ] )
            ifTrue: [ object := dde exportedItemAt: item ] ].

    ddeFormat := DynamicDataExchange getDDEFormat: object class.
    ( object notNil and: [ ddeFormat = format ] )
        ifTrue: [
            self addHotLinkedItem: item client: sender format: format ackReq: ackReq.
            dde ackAcceptTo: sender item: item.
            ( KernelLibrary globalFree: hOption ) = 0
                ifFalse: [ ^self osError ].
            dde
                dataAdvisedTo: sender
                data: ( DynamicDataExchange getDDEObject: object )
                format: format
                item: item
                ackReq: ackReq ]
        ifFalse: [ dde ackNotAcceptTo: sender item: item ]! 
removeHotLinkedItem: item client: client format: format
        "Private - Remove item from hotLinkedItem dictionary."
    | set result |
    set := hotLinkedItems at: item ifAbsent: [ Set new ].
    result := set
        remove: ( Array with: client with: format with: true )
        ifAbsent: [ set remove: ( Array with: client with: format with: false ) ifAbsent: [ nil ] ].
    hotLinkedItems at: item put: set.
    ^result notNil!   
addHotLinkedItem: item client: client format: format ackReq: ackReq
        "Private - add a item to hotLinkedItem dictionary."
    | set |
    set := hotLinkedItems at: item ifAbsent: [ Set new ].
    set add: ( Array with: client with: format with: ackReq ).
    hotLinkedItems at: item put: set!   
initialize
        "Private - Initialize the receiver."
    self label: 'DDEServer'.
    super initialize! 
addWarmLinkedItem: item client: client format: format ackReq: ackReq
        "Private - Add an item to the warmLinkedItem dictionary."
    | set |
    set := warmLinkedItems at: item ifAbsent: [ Set new ].
    set add: ( Array with: client with: format with: ackReq ).
    warmLinkedItems at: item put: set!  
ddeTerminate: sender
        "Private - default handling for ddeTerminate."
    self removeClientFromList: sender.
    dde notNil ifTrue: [
        dde removeClientFromList: sender.
        dde terminateTo: sender ]! 
removeClientFromList: aClient
        "Private - Remove client from hotLinkedItems
         and warmLinkedItem dictionary."
    hotLinkedItems := hotLinkedItems select: [ :clients |
        ( clients reject: [ :clientFormat |
            ( clientFormat at: 1 ) = aClient ] ) notEmpty ].
    warmLinkedItems := warmLinkedItems select: [ :clients |
        ( clients reject: [ :clientFormat |
            ( clientFormat at: 1 ) =  aClient ] ) notEmpty ]!  
removeWarmLinkedItem: item client: client format: format
        "Private - Remove item from warmLinkedItem dictionary."
    | set result |
    set := warmLinkedItems at: item ifAbsent: [ Set new ].
    result := set
        remove: ( Array with: client with: format with: true )
        ifAbsent: [ set remove: ( Array with: client with: format with: false ) ifAbsent: [ nil ] ].
    warmLinkedItems at: item put: set.
    ^result notNil!   
open
        "Private - Open DDEAuxServer window.  Used to listen
         for DDE messages from clients."
    hotLinkedItems := Dictionary new.
    warmLinkedItems := Dictionary new.
    ^super open! 
waitForData
        "Private - Wait for the dde data."
    [ CurrentProcess makeUserIF. Notifier run ] fork.
    sem wait.
    CurrentProcess makeUserIF.
    ^answer!   
dde: aDDE
        "Private - Set the dde for the receiver to aDDE."
    dde := aDDE!
receiverObj
        "Private - returns the Smalltalk object that needs
         to receive DDE requests and submissions"
    ^receiverObj! 
receiverObj: object
        "Private - sets the Smalltalk object that needs to
         receive DDE requests and submissions."
    receiverObj := object!  
initialize
        "Private - Initialize the receiver."
    self label: 'DDEAuxWindow'.
    super initialize!  
close
        "Private - close the DDE aux window"
    self isHandleOk ifTrue: [
        super close.
        self initialize ]!  
makeActive
        "Private - Do not activate this window."! 
validate
        "Private - Build, but don't show the window."
    self buildWindow isNil ifTrue: [ ^nil ]! 
wmDdeAdvise: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil!   
ddeDataUpdated: sender item: item
        "Private - default handling for ddeDataUpdated.
        data has been updated.  The client should request the data."
    | selector |
    ( ( selector := warmLinkedItems
        at: item
        ifAbsent: [
            ^MessageBox
                titled: 'warning'
                withText: 'Warm linked data received but none was expected.'
                style: MbOk | MbIconexclamation ] ) notNil
            and: [ receiverObj respondsTo: selector ] )
                ifTrue: [ receiverObj perform: selector with: item ]!  
warmLinkItem: itemName class: aClass selector: aSelector
        "Establish warm link with an item of itemName on the server.
         When a item's value changes at the server, a notification
         will be sent to aSelector in the client object.  aSelector must
         be a one argument selector.  The argument is the item name.
         Answers true if the warm link was established with the server,
         answers false if it was not."
    | answer |
    client addWarmLinkedItem: itemName selector: aSelector.
    self
        adviseTo: server
        ackReq: false
        deferUpd: true
        format: ( DynamicDataExchange getDDEFormat: aClass )
        item: itemName.
    answer := client waitForData.
    ^answer!   
getSmalltalkObject: aString class: class
        "Private - Given aString, return a Smalltalk
         object of a given class."
    ( class == Integer or:
        [ class =  LargeNegativeInteger or:
        [ class = LargePositiveInteger or:
        [ class = SmallInteger ] ] ] ) ifTrue: [ ^aString asInteger ].

    "Update this later as other Smalltalk objects are supported"
    ^aString!
ackInitiateTo: to application: anApplication topic: aTopic
        "Private - Send an acknowledgment of DDE initiation."
    ^self
        sendTo: to
        msg: WmDdeAck
        lParamLo: ( ExternalHandle stringToAtom: anApplication )
        lParamHi: ( ExternalHandle stringToAtom: aTopic )! 
wmDdeInitiate: wparam with: lparam
        "Private - Pass along a Dde message."
    | anApplication aTopic param |
    dde notNil ifTrue: [
        param := lparam asUnsigned.
        anApplication := param \\ 16r10000.
        aTopic := param // 16r10000.
        self
            ddeInitiate: wparam
            application: ( ExternalHandle atomToString: anApplication )
            topic: ( ExternalHandle atomToString: aTopic ) ].
    ^nil! 
ddeAck: sender
    msg: msg
    ack: ack
    busy: busy
    appReturnCode: appReturnCode
    item: item
       "Private - default handling for ddeAck."
    ^nil!  
wmDdeRequest: wparam with: lparam
        "Private - Pass along a Dde message."
    | item format param |
    dde notNil ifTrue:
        [
        param := lparam asUnsigned.
        format := param lowWord.
        item := ExternalHandle atomToString:  param highWord.
        self
            sendInputEvent: #ddeRequest:format:item:
            withArgs: ( Array with: wparam with: format with: item ).
        item notNil   " work around..."
             ifTrue: [ ExternalHandle deleteAtom: param highWord ]
        ].
    ^nil!   
unPackDdeData: lparam msg: msg
        "Private - unpacks an lparam packed with
        PackDDElParam.  Answers an array with:
        1) low order word 2) high order word."
    | ptrLo ptrHi lParamLo lParamHi |
    ptrLo := ExternalAddress copyToNonSmalltalkMemory: ExternalLong new asParameter.
    ptrHi := ExternalAddress copyToNonSmalltalkMemory: ExternalLong new asParameter.

    ( UserLibrary
        unpackDDElParam: msg
        lParam: lparam
        low:  ptrLo asParameter
        high: ptrHi asParameter )
            ifFalse: [ ^self osError ].
    lParamLo := ( ExternalLong fromAddress: ptrLo ) asInteger.
    lParamHi := ( ExternalLong fromAddress: ptrHi ) asInteger.
    ptrLo free.
    ptrHi free.
    ( UserLibrary freeDDElParam: WmDdeAck lParam: lparam )
        ifFalse: [ ^self osError ].
    ^Array with: lParamLo with: lParamHi! 
wmTimer: wordInteger with: longInteger
        "Private - Process the timer message."
    wordInteger = 1 ifTrue: [ Time stopTimer: 1 forWindow: self ].
    ^self sendInputEvent: #timedOut: with: wordInteger!   
ddeDataAdvised: sender format: format data: data item: item
        "Private - default handling for ddeDataAdvised.
         The server has sent a advised Data."
    | object selector array class |
    array := hotLinkedItems
        at: ( Array with: item with: format )
        ifAbsent: [
            ^MessageBox
                titled: 'warning'
                withText: 'Hot linked data recieved but none was expected.'
                style: MbOk | MbIconexclamation ].
    array notNil ifTrue: [
        class := array at: 1.
        selector := array at: 2.
        ( selector notNil and: [ receiverObj respondsTo: selector ] ) ifTrue: [
            object := DynamicDataExchange getSmalltalkObject: data class: class.
            receiverObj perform: selector with: item with: object ] ]!
wmDdeAdvise: wparam with: lparam
        "Private - Pass along a Dde message."
    | lpOption option hOption structArray item ackReq deferUpd format paramArray |
    ( structArray := self unPackDdeData: lparam asUnsigned msg: WmDdeAdvise )
        isNil ifTrue: [ ^nil ].

    hOption := structArray at: 1.
    item := ExternalHandle atomToString: ( structArray at: 2 ).
    ( lpOption := KernelLibrary globalLock: hOption ) = 0
        ifTrue: [ ^self osError ].
    lpOption := ExternalAddress fromInteger: lpOption.
    option := ( ExternalBuffer new: 4 ) fillFromAddress: lpOption.

    ackReq := ( ( option uShortAtOffset: 0 ) bitAnd: 16r8000 ) = 16r8000.
    deferUpd := ( ( option uShortAtOffset: 0 ) bitAnd: 16r4000 ) = 16r4000.
    format := ( option uShortAtOffset: 2 ) bitAnd: 16r00FF.

    ( paramArray := Array new: 5 )
        at:1 put: wparam;
        at:2 put: ackReq;
        at:3 put: format;
        at:4 put: item;
        at:5 put: hOption.

    deferUpd
        ifTrue: [
            self
                sendInputEvent: #ddeAdviseWarmLink:ackReq:format:item:hOption:
                withArgs: paramArray ]
        ifFalse: [
            self
                sendInputEvent: #ddeAdviseHotLink:ackReq:format:item:hOption:
                withArgs: paramArray ].
    ^nil! 
wmDdePoke: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil! 
ackTo: to
    ack: ack
    busy: busy
    appReturnCode: appReturnCode
    item: item
        "Private - Send an acknowledgment back."
    | status anItem answer lparam |
    status := appReturnCode bitAnd: 16r00FF.
    ack ifTrue: [ status := status bitOr:  16r8000 ].
    busy ifTrue: [ status := status bitOr: 16r4000 ].
    anItem := ExternalHandle stringToAtom: item.

    ( lparam := UserLibrary
        packDDElParam: WmDdeAck
        low: status
        high: anItem ) = 0
            ifTrue: [ ^self osError ].
    answer := self
        postTo: to
        msg: WmDdeAck
        lParam: lparam.

    answer ifFalse: [
        ExternalHandle deleteAtom: anItem.
        ( UserLibrary freeDDElParam: WmDdeAck lParam: lparam )
            ifFalse: [ ^self osError ] ].
    ^answer! 
terminateWarmLinkItem: itemName class: aClass
        "Terminate a warm link identified by itemName and aClass."
    client removeWarmLinkedItem: itemName.
    ^self
        unAdviseTo: server
        item: itemName
        format: ( DynamicDataExchange getDDEFormat: aClass )!   
wmDdeExecute: wparam with: lparam
        "Private - Pass along a Dde message."
    | hCommand command address |
    dde isNil ifTrue: [ ^nil ].
    ( hCommand := lparam ) = 0 ifTrue: [ ^nil ].
    ( address := KernelLibrary globalLock: hCommand ) = 0
        ifTrue: [ ^self osError ].
    address := ExternalAddress fromInteger: address.
    command := ( String fromAddress: address ) trimNullTerminator.
    KernelLibrary globalUnlock: hCommand.
    self
        sendInputEvent: #ddeExecute:command:hCommand:
        withArgs: ( Array with: wparam with: command with: hCommand ).
    ^nil! 
wmDdeAck: wparam with: lparam
        "Private - Pass along a Dde message."
    | param lParams itemName appName ack busy appReturnCode paramArray status |
    param := lparam asUnsigned.
    dde notNil
        ifTrue: [
            dde pendingAck = #WmDdeInitiate
                ifTrue: [
                    appName := param lowWord.
                    itemName := param highWord.
                    dde server: wparam.
                    self
                        ddeAckInitiate: wparam
                        application: ( ExternalHandle atomToString: appName )
                        topic: ( ExternalHandle atomToString: itemName ).
                    ExternalHandle deleteAtom: appName.
                    ExternalHandle deleteAtom: itemName ]
                ifFalse: [
                    lParams := ( self unPackDdeData: param msg: WmDdeAck ).
                    status :=  lParams at: 1.
                    dde pendingAck = #WmDdeExecute
                        ifTrue: [
                            "Not sending command string to this method."
                            ack := ( status bitAnd: 16r8000 ) = 16r8000.
                            busy := ( status bitAnd: 16r4000 ) = 16r4000.
                            appReturnCode := status bitAnd: 16r00FF.
                            answer := ack.
                            dde deleteData.
                            ( paramArray := Array new: 5 )
                                at: 1 put: wparam;
                                at: 2 put: ack;
                                at: 3 put: busy;
                                at: 4 put: appReturnCode;
                                at: 5 put: String new.
                            self
                                sendInputEvent: #ddeAckExecute:ack:busy:appReturnCode:command:
                                withArgs: paramArray ]
                        ifFalse: [
                            itemName := lParams at: 2.
                            ack := ( status bitAnd: 16r8000 ) = 16r8000.
                            busy :=  ( status bitAnd: 16r4000 ) = 16r4000.
                            appReturnCode := status bitAnd: 16r00FF.
                            ack ifFalse: [ dde deleteData ].
                            answer := ack.

                            ( dde pendingAck = #WmDdeRequest and: [ ack not ] )
                                ifTrue: [ answer := nil  ].

                            ( paramArray := Array new: 6 )
                                at: 1 put: wparam;
                                at: 2 put: dde pendingAck;
                                at: 3 put: ack;
                                at: 4 put: busy;
                                at: 5 put: appReturnCode;
                                at: 6 put: ( ExternalHandle atomToString: itemName ).

                            self
                                sendInputEvent: #ddeAck:msg:ack:busy:appReturnCode:item:
                                withArgs: paramArray.
                            ExternalHandle deleteAtom: itemName ] ] ].

    dde pendingAck: nil.
    ^nil!  
ackExecuteTo: to
    ack: ack
    busy: busy
    appReturnCode: appReturnCode
    hCommand: hCommand
        "Private - Send an acknowledgment of DDE execute
         command."
    | status answer handle |
    status := appReturnCode bitAnd: 16r00FF.
    ack ifTrue: [ status := status bitOr:  16r8000 ].
    busy ifTrue: [ status := status bitOr: 16r4000 ].

    ( handle := UserLibrary
        packDDElParam: WmDdeAck
        low: status
        high: hCommand ) = 0
            ifTrue: [ ^self osError ].
    ( answer := self postTo: to msg: WmDdeAck lParam: handle ) ifFalse: [
        ( UserLibrary freeDDElParam: WmDdeAck lParam: handle )
            ifFalse: [ ^self osError ] ].
    ^answer!   
wmDdeUnadvise: wparam with: lparam
        "Private - Pass along a Dde message."
    | item format param |
    dde notNil ifTrue: [
        param := lparam asUnsigned.
        format := param lowWord.
        item := ExternalHandle atomToString: param highWord.
        item notNil ifTrue: [
        "workaround -- sometimes we get the unAdvise when the item has
        already been freed"
            self sendInputEvent: #ddeTerminateLink:format:item:
                withArgs: ( Array with: wparam with: format with: item ).
            ExternalHandle deleteAtom: param highWord ] ].
    ^nil!
wmDdeInitiate: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil! 
requestItem: itemName class: aClass selector: aSelector
        "Request data from the server about item in a format of
         aClass.  Requested item will be sent to a aSelector in
         the client object.  aSelector must be a two argument selector.
         First argument is the item name and the second argument is
         the object sent by the server."
    client addRequestedItem: itemName class: aClass selector: aSelector.
    ^self
        requestTo: server
        item: itemName
        format: ( DynamicDataExchange getDDEFormat: aClass )!  
wmDdeData: wparam with: lparam
        "Private - Pass along a Dde message."
    | hData lpData data structArray size item ackReq release requested format value paramArray formattedData |
    ( structArray := self unPackDdeData: lparam asUnsigned msg: WmDdeData )
        isNil ifTrue: [ ^nil ].

    hData := structArray at: 1.
    item := ExternalHandle atomToString: ( structArray at: 2 ).

     hData ~= 0
         ifTrue: [
            lpData := ExternalAddress fromInteger: ( KernelLibrary globalLock: hData ).
            ( size := KernelLibrary globalSize: hData ) = 0
                ifTrue: [ ^self osError ].
            data := ( ExternalBuffer new: size ) fillFromAddress: lpData.
            KernelLibrary globalUnlock: hData.
            ackReq := ( ( data uShortAtOffset: 0 ) bitAnd: 16r8000 ) = 16r8000.
            release := ( ( data uShortAtOffset: 0 ) bitAnd: 16r2000 ) = 16r2000.
            requested := ( ( data uShortAtOffset: 0 ) bitAnd: 16r1000 ) = 16r1000.
            format := data uShortAtOffset: 2.
            value := data bytesAtOffset: 4 count: size - 4.
            formattedData := value.

            format = CfText ifTrue: [
                formattedData := String new: value size.
                    formattedData replaceFrom: 1 to: value size with: value startingAt: 1.
                    formattedData := formattedData asNormalizedString trimNullTerminator ].

            ackReq ifTrue: [ dde ackAcceptTo: dde server item: item ].
            ( release or: [ ackReq not ] ) ifTrue: [
                ( KernelLibrary globalFree: hData ) = 0
                    ifFalse: [ ^self osError ] ].

            ( paramArray := Array new: 4 )
                at: 1 put: wparam;
                at: 2 put: format;
                at: 3 put: formattedData;
                at: 4 put: item.

            requested
                ifTrue: [
                    self
                        sendInputEvent: #ddeDataRequested:format:data:item:
                        withArgs: paramArray ]
                ifFalse: [
                    self
                        sendInputEvent: #ddeDataAdvised:format:data:item:
                        withArgs: paramArray ] ]
        ifFalse: [
            self
                sendInputEvent: #ddeDataUpdated:item:
                withArgs: ( Array with: wparam with: item ) ].

    ExternalHandle deleteAtom: ( structArray at: 2 ).
    ^nil! 
wmDdeTerminate: wparam with: lparam
        "Private - Pass along a Dde message."
    dde notNil ifTrue: [
        self sendInputEvent: #ddeTerminate: withArgs: ( Array with: wparam ) ]! 
postTo: to msg: aDdeMessage lParam: lParam
        "Private - Post aDdeMessage."
    | from answer tries |
    answer := false.
    from := isClient ifTrue: [ client ] ifFalse: [ server ].

    to notNil ifTrue: [
        ( UserLibrary isWindow: to ) ifTrue: [
            tries := 0.
                [ answer = false and: [ tries < 5 ] ] whileTrue: [
                    answer := UserLibrary
                        postMessage: to
                        msg: aDdeMessage
                        wparam: from asParameter
                        lparam: lParam.
                    tries := tries + 1.
                    answer ifFalse: [ Notifier yield ] ] ] ].
    ^answer!   
ackAcceptTo: to item: item
        "Private - Send an acknowledgment for item indicating
         acceptance."
    self
        ackTo: to
        ack: true
        busy: false
        appReturnCode: 0
        item: item!  
setData: handle
        "Private - Set data handle."
    dataHandle := handle!  
requestTo: to item: item format: format
        "Private - Request data from the server
         about item string  in a desired format.
         format is of clipboard format from
         OperatingSystemConstants pool Dictionary."
    | anItem answer |
    anItem := ExternalHandle stringToAtom: item.
    answer := self
        postTo: to
        msg: WmDdeRequest
        lParamLo: format
        lParamHi: anItem.
    answer
        ifTrue: [ pendingAck:= #WmDdeRequest ]
        ifFalse: [ ExternalHandle deleteAtom: anItem ].
    ^answer!  
ddeTerminateLink: sender format: format item: item
        "Private - default handling for ddeUnadvise."
    ( ( self removeHotLinkedItem: item client: sender format: format )
     or: [ ( self removeWarmLinkedItem: item client: sender format: format ) ] )
        ifTrue: [ dde ackAcceptTo: sender item: item ]
        ifFalse: [ dde ackNotAcceptTo: sender item: item ]!  
wmDdeUnadvise: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil! 
adviseTo: to
    ackReq: ackReq
    deferUpd: deferUpd
    format: format
    item: item
        "Private - Request the server to advise the client
         about itemName in a requested format."
    | anItemName anOption hOption answer handle |
    self clearData.
    anItemName := ExternalHandle stringToAtom: item.
    anOption := ExternalBuffer new: 4.
    anOption uShortAtOffset: 0 put: 0.

    ackReq
        ifTrue: [ anOption uShortAtOffset: 0 put: ( anOption uShortAtOffset: 0 ) | 16r8000 ].
    deferUpd
        ifTrue: [ anOption uShortAtOffset: 0 put: ( anOption uShortAtOffset: 0 ) | 16r4000 ].
    anOption uShortAtOffset: 2 put: format.

    hOption := ExternalAddress memoryHandleFrom: anOption contents
          withAllocFlag: GmemDdeshare | GmemMoveable.
    self setOption: hOption.
    ( handle := UserLibrary
        packDDElParam: WmDdeAdvise
        low: hOption
        high: anItemName ) = 0
            ifTrue: [ ^self osError ].

    answer := self
        postTo: to
        msg: WmDdeAdvise
        lParam: handle.

    answer
        ifTrue: [ pendingAck:= #WmDdeAdvise ]
        ifFalse: [
            ( UserLibrary freeDDElParam: WmDdeAdvise lParam: handle )
                ifFalse: [ ^self osError ].
            self deleteData ].
    ^answer!  
ddeAckInitiate: sender application: application topic: topic
        "Private - default handling for ddeAckInitiate."
    ^nil! 
bound
        "Private - hook the receiver into event notification system
        upon bind."
    self hostEvents associationsDo: [ :event |
        OperatingSystemEvents at: event key put: event value ]!  
pokeTo: to release: release format: format data: value item: item
        "Private - Send data value in specified format to the server.
        The release flag is always set."
    | anItemName data hData answer formattedData handle |
    self clearData.
    anItemName := ExternalHandle stringToAtom: item.
    formattedData := ( format = CfText and: [ value isString ] )
        ifTrue: [ value asAsciiZ ]
        ifFalse: [ value ].
    data := ExternalBuffer new: 4 + formattedData size + 1.
    data uShortAtOffset: 0 put: 0.
    data uShortAtOffset: 0 put: ( data uShortAtOffset: 0 ) | 16r2000.   "release flag"
    data uShortAtOffset: 2 put: format.
    data bytesAtOffset: 4 put: formattedData.

    self setData: ( hData := ExternalAddress
        memoryHandleFrom: data contents
        withAllocFlag: GmemDdeshare | GmemMoveable ).
    ( handle := UserLibrary
        packDDElParam: WmDdePoke
        low: hData
        high: anItemName ) = 0
            ifTrue: [ ^self osError ].

    answer := self
        postTo: to
        msg: WmDdePoke
        lParam: handle.
    answer
        ifTrue: [ pendingAck:= #WmDdePoke ]
        ifFalse: [
            "PostMessage failed destroy atom and memory"
            ExternalHandle deleteAtom: anItemName.
            ( UserLibrary freeDDElParam: WmDdePoke lParam: handle )
                ifFalse: [ ^self osError ].
            self deleteData ].
    ^answer! 
waitForData
        "Private - Wait for the dde data."
    sem := Semaphore new.
        "Set the length of time to wait for server before timing out."
    self setTimeOut.
    [ CurrentProcess makeUserIF. Notifier run ] fork.
    sem notNil ifTrue: [ sem wait ].  "may be closed before getting here"
    CurrentProcess makeUserIF.
    Time stopTimer: 1 forWindow: self.
    ^answer!  
ddeDataRequested: sender format: format data: data item: item
        "Private - default handling for ddeDataRequested.
        The server has sent a requested data."
    | object selector array class |
    array := requestedItems
        at: ( Array with: item with: format )
        ifAbsent: [
            ^MessageBox
                titled: 'warning'
                withText: 'Requested data received but none was expected.'
                style: MbOk | MbIconexclamation ].
    array notNil ifTrue: [
        class := array at: 1.
        selector := array at: 2.
        object := DynamicDataExchange getSmalltalkObject: data class: class.
        ( selector notNil and: [ receiverObj respondsTo: selector ] ) ifTrue: [
            receiverObj perform: selector with: item with: object ].
        answer := object.
        requestedItems removeKey: ( Array with: item with: format ) ].

   sem notNil ifTrue: [
        sem signal.
        sem := nil.
        Processor suspendActive ]!  
ddeAck: sender
    msg: msg
    ack: ack
    busy: busy
    appReturnCode: appReturnCode
    item: item
        "Private - default handling for ddeAck."
    "ack ifFalse: [ answer := nil ]." "If negative ack then set answer to nil"

    "If waiting for an answer then clear semaphore"
    sem notNil ifTrue: [
        sem signal.
        sem := nil.
        Processor suspendActive]!  
dataAdvisedTo: to
    data: data
    format: format
    item: item
    ackReq: ackReq
        "Private - Send a data that was advised by the client."
    ^self
        dataTo: to
        ackReq: ackReq
        release: true
        requested: false
        format: format
        data: data
        item: item!   
clearData
        "Private - indicate that there is no saved data, because
          it should have been freed someplace else."
    dataHandle := nil.
    option := nil.!
dataUpdatedTo: to format: format item: item
        "Private - Send a null data message to indicate that
         a warm linked item has been changed."
    ^self
        dataTo: to
        ackReq: false
        release: false
        requested: false
        format: format
        data: nil
        item: item! 
wmDdeRequest: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil!  
ddeInitiate:sender application: application topic: topic
        "Private - default handling for ddeInitiate."
    ( application = dde application and: [ topic = dde topic ] ) ifTrue: [
        dde addClient: sender.
        dde ackInitiateTo: sender application: application topic: topic ]!   
newServer: aServerObj application: application topic: topic
        "Answer a new instance of DDEServer that can be
         involved in a DDE conversation with DDE clients
         about application and topic name.  Answers nil if a
         DDE server can not be created."
    | dde server |
    dde := self new.
    ( server := DDEAuxServer new open ) notNil
       ifTrue: [
           dde
                server: server;
                isClient: false.
           ( dde server )
                receiverObj: aServerObj;
                dde: dde.
           dde
                application: application;
                topic: topic;
                initExportedItems;
                initClient ]
        ifFalse: [ dde := nil ].
    ^dde!
terminateHotLinkItem: itemName class: aClass
        "Terminate a hot link identified by itemName and aClass."
    client removeHotLinkedItem: itemName class: aClass.
    ^self
        unAdviseTo: server
        item: itemName
        format: ( DynamicDataExchange getDDEFormat: aClass )!
setOption: newOption
        "Private - Set option."
    option := newOption!   
timedOut: timerID
        "Private - Timed out waiting for server."
    timerID = 1 ifFalse: [ ^nil ].
    "Timed out waiting for Server.  Clear semaphore?"
    ( MessageBox confirm: 'DDE Timed out.  Continue waiting?' )
        ifTrue: [ ^self setTimeOut ]
        ifFalse: [
            answer := false.
            sem notNil ifTrue: [
                sem signal.
                sem := nil.
                Processor suspendActive ] ]!
ddeRequest: sender format: format item: item
        "Private - default handling for ddeRequest."
    | object ddeFormat |
    ( object := dde exportedItemAt: item ) isNil ifTrue: [
        "Give the receiver object the chance to export the item"
        ( ( receiverObj respondsTo: #ddeExportItem: ) and: [ receiverObj ddeExportItem: item ] )
            ifTrue: [ object := dde exportedItemAt: item ] ].

    ddeFormat := DynamicDataExchange getDDEFormat: object class.
    ( object notNil and: [ ddeFormat = format ] )
        ifTrue: [
            dde
                dataRequestedTo: sender
                data: ( DynamicDataExchange getDDEObject: object )
                format: format
                item: item ]
        ifFalse: [ dde ackNotAcceptTo: sender item: item ]!
ackNotAcceptTo: to item: item
        "Private - Send a negative acknowledgment for an item."
    self
        ackTo: to
        ack: false
        busy: false
        appReturnCode: 0
        item: item.!  
dataTo: to
    ackReq: ackReq
    release: release
    requested: requested
    format: format
    data: value
    item: item
        "Private - Send data to the client in response
         to a request or an advise.  The release flag is always set."
    | anItemName data hData answer handle formattedData |
    self clearData.
    anItemName := ExternalHandle stringToAtom: item.
    hData := 0.
    formattedData := ( format = CfText and: [ value isString ] )
        ifTrue: [ value asAsciiZ ]
        ifFalse: [ value ].
    formattedData notNil ifTrue: [
        data := ExternalBuffer new: 4 + formattedData size + 1.

        ackReq
            ifTrue: [ data uShortAtOffset: 0 put:  ( data uShortAtOffset: 0 ) | 16r8000 ].
        requested
            ifTrue: [ data uShortAtOffset: 0 put: ( data uShortAtOffset: 0 ) | 16r1000 ].
        data uShortAtOffset: 0 put: ( data uShortAtOffset: 0 ) | 16r2000.        "set release flag"

        data uShortAtOffset: 2 put: format.
        data bytesAtOffset: 4 put: formattedData.
        hData := ExternalAddress
            memoryHandleFrom: data contents
            withAllocFlag: GmemDdeshare | GmemMoveable.
        self setData: hData ].

    ( handle := UserLibrary
        packDDElParam: WmDdeData
        low: hData
        high: anItemName ) = 0
            ifTrue: [ ^self osError ].
    answer := self
        postTo: to
        msg: WmDdeData
        lParam: handle.
     answer
        ifTrue: [ pendingAck:= #WmDdeData ]
        ifFalse: [
            ExternalHandle deleteAtom: anItemName.
            self deleteData.
            ( UserLibrary freeDDElParam: WmDdeData lParam: handle )
                ifFalse: [ ^self osError ] ].
    ^answer!  
wmDdeAck: wparam with: lparam
        "Private - Pass along a Dde message."
    | lParamLo lParamHi structArray ack busy appReturnCode item |

    dde notNil
        ifTrue:
            [
            ( structArray := self unPackDdeData: lparam asUnsigned msg: WmDdeData )
                isNil ifTrue: [ ^nil ].
            lParamLo := structArray at: 1.
            lParamHi := structArray at: 2.
            ack := ( lParamLo bitAnd: 16r8000 ) = 16r8000.
            busy :=  (lParamLo bitAnd: 16r4000 ) = 16r4000.
            appReturnCode := lParamLo bitAnd: 16r00FF.

           self
                ddeAck: wparam
                msg: dde pendingAck
                ack: ack
                busy: busy
                appReturnCode: appReturnCode
                item: ( item := ExternalHandle atomToString: lParamHi ).
            item notNil     "work around ...."
                ifTrue: [ ExternalHandle deleteAtom: lParamHi ].
            ].

    dde pendingAck: nil.
    ^nil!   
postTo: to msg: aDdeMessage lParamLo: lParamLo lParamHi: lParamHi
        "Private - Post aDdeMessage."
    ^self postTo: to msg: aDdeMessage lParam: ( lParamLo | ( lParamHi bitShift: 16 ) )! 
wmDdeAck: wparam with: lparam 
        "Private - ignore DDE message." 
    ^ nil!  
wmDdeTerminate: wparam with: lparam
        "Private - Pass along a Dde message."
    dde notNil ifTrue:
        [ self sendInputEvent: #ddeTerminate: withArgs: ( Array with: wparam ) ]! 
executeTo: to command: command
        "Private - Send aString to the server to be executed."
    | hCommand answer |
    self clearData.
    hCommand := ExternalAddress
        memoryHandleFrom: command asAsciiZ
        withAllocFlag: GmemDdeshare | GmemMoveable.
    answer := self
        postTo: to
        msg: WmDdeExecute
        lParam: hCommand.
    answer
        ifTrue: [ pendingAck:= #WmDdeExecute. self setData: hCommand. ]
        ifFalse:
            [ ( KernelLibrary globalFree: hCommand ) = 0
                ifFalse: [ ^self osError ]
            ].
    ^answer!   
setTimeOut
        "Private - Wait 10 seconds for Server's response,
        then time out."
    Time startTimer: 1 period: 10000 forWindow: self! 
removeWarmLinkedItem: item
        "Private - remove a item from warmLinkedItem dictionary."
    warmLinkedItems removeKey: item!   
addWarmLinkedItem: item selector: selector
        "Private - Add a warm linked item to warmLinkedItems
         dictionary."
    warmLinkedItems at: item put: selector!  
initialize
        "Private - Initialize the receiver."
    self label: 'DDEClient'.
    super initialize! 
removeHotLinkedItem: item class: class
        "Private - remove a item from hotLinkedItem dictionary."
    | ddeFormat |
    ddeFormat := DynamicDataExchange getDDEFormat: class.
    hotLinkedItems removeKey: ( Array with: item with:  ddeFormat )!  
addHotLinkedItem: item class: class selector: selector
        "Private - Add a hot linked item to hotLinkedItems
         dictionary."
    | ddeFormat |
    ddeFormat := DynamicDataExchange getDDEFormat: class.
    hotLinkedItems
        at: ( Array with: item with: ddeFormat )
        put: ( Array with: class with: selector )! 
addRequestedItem: item class: class selector: selector
        "Private - Add a requested item to requestedItems
         dictionary."
    | ddeFormat |
    ddeFormat := DynamicDataExchange getDDEFormat: class.
    requestedItems
        at: ( Array with: item with: ddeFormat )
        put: ( Array with: class with: selector )!  
ddeTerminate: sender
        "Private - default handling for ddeTerminate."
    dde notNil ifTrue: [
        dde terminateTo: sender.
        dde server: nil.
        dde client: nil ].
    self close!   
open
        "Private - Open a DDEAuxClient window.  Needed to listen for
         DDE messages from server."
    hotLinkedItems := Dictionary new.
    warmLinkedItems := Dictionary new.
    requestedItems := Dictionary new.
    ^super open!   
updateClientsWithItem: item
        "Private - Update clients that had warm or hot links
         with item.  WM_DDEDATA message is sent out
         to the clients."
    | client format ackReq |
    ( hotLinkedItems at: item ifAbsent: [ Set new ] ) do: [ :array |
        client := array at: 1.
        format := array at: 2.
        ackReq := array at: 3.
        ( dde isValidClient: client ) ifTrue: [
            dde
                dataAdvisedTo: client
                data: ( DynamicDataExchange getDDEObject: ( dde exportedItemAt: item ) )
                format: format
                item: item
                ackReq: ackReq ] ].

    ( warmLinkedItems at: item ifAbsent: [ Set new ] ) do: [ :array |
        client := array at: 1.
        format := array at: 2.
        ( dde isValidClient: client ) ifTrue: [
            dde
                dataUpdatedTo: client
                format: format
                item: item ] ]!  
unAdviseTo: to item: item format: format
        "Private - Cancel a previous advise for itemName."
    | anItem answer |
    self clearData.
    anItem := ExternalHandle stringToAtom: item.
    answer := self
        postTo: to
        msg: WmDdeUnadvise
        lParamLo: format
        lParamHi: anItem.
    answer
        ifTrue:    [ pendingAck := #WmDdeUnadvise ]
        ifFalse:  [ ExternalHandle deleteAtom: anItem ].

    ^answer!
initExportedItems
        "Private - initialize a collector that keeps track of data items
         that has been exported by the server."
    exportedItems := Dictionary new!
addExportedItem: itemName object: anObject
        "Add anObject identified by itemName to the list of
         server exports that may be hot linked, warm linked
         or requested by the client."
    exportedItems at: itemName put: anObject!
terminate
        "Terminate DDE session."
    client isNil ifTrue: [ ^self ].
    client do: [ :aClient | self terminateTo: aClient ].
    server close.
    server := nil.
    client := nil! 
updateExportedItem: itemName object: anObject
        "Update anObject identified by itemName
         in the list of server exports."
    exportedItems at: itemName put: anObject.
    server updateClientsWithItem: itemName!  
removeClientFromList: aClient
        "Private - Remove client from client Set."
    client remove: aClient ifAbsent: [ nil ]!  
removeExportedItem: itemName
        "Remove an item identified by itemName in the
         list of server exports (exportedItems dictionary)."
    exportedItems removeKey: itemName! 
addClient: aClient
        "Private - Add a new client to the list of known clients."
    client add: aClient!  
exportedItemAt: item
        "Private - Add item to exportedItems dictionary."
    ^exportedItems at: item ifAbsent: [ nil ]!   
initClient
        "Private - initialize a collector that keeps track of data items
         that has been exported by the server."
    client := Set new! 
isValidClient: aClient
        "Private - Check to see if aClient is a valid client.
         A valid client is a client that initiated with the server."
    ^client includes: aClient!   
deleteData
        "Private - free up any saved data."
    dataHandle notNil ifTrue: [
        ( KernelLibrary globalFree: dataHandle ) = 0
            ifFalse: [ ^self osError ].
        dataHandle := nil ].
    option notNil ifTrue: [
        ( KernelLibrary globalFree: option ) = 0
            ifFalse: [ ^self osError ].
        option := nil ].!  
hotLinkItem: itemName class: aClass selector: aSelector
        "Establish hot link with an item of itemName on the server.
         When the item's value changes at the server, the
         requested item will be sent as aClass object to
         aSelector in the client object.
         aSelector must be a two argument selector.  First argument
         is the item name and the second argument is the
         object sent by the server.
         Answers true if the hot link was established with the server,
         answers false if it was not."
    |answer|
    client addHotLinkedItem: itemName class: aClass selector: aSelector.
    self
        adviseTo: server
        ackReq: false
        deferUpd: false
        format: ( DynamicDataExchange getDDEFormat: aClass )
        item: itemName.
    answer := client waitForData.
    ^answer!   
pokeItem: itemName object: anObject
        "Sends an unsolicited anObject identified by itemName to
         the server.  Answers true if the object was accepted by
         the server, otherwise false."
    |answer|
    self
        pokeTo: server
        release: true
        format: ( DynamicDataExchange getDDEFormat: anObject class )
        data: ( DynamicDataExchange getDDEObject: anObject )
        item: itemName.
    answer := client waitForData.
    ^answer!