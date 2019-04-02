3.1.0.106
   
requestItem: anItemName
        " Answer the value of anItemName from the
        server in the current conversation. "
    dde notNil
        ifTrue: [
            ^dde
                requestItem: anItemName
                class: String]!  
ddeServerClass
        " Private - answer the DDE server class.
        Bind the DDE library if necessary. "

    ^self ddeClassNamed: #DDEServer!
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self itemsAsMessages includes: aSelector )
        ifTrue: [ PARTSAliasLink ]
        ifFalse: [ super partLinkClassFor: aSelector ]!   
itemsAsMessages
        "Answer a collection of message item names as messages with ':'s appended."
    ^messageItems isNil
        ifTrue: [Array new]
        ifFalse: [messageItems collect: [ :i | (i , ':') asSymbol]]!  
application: aString
        "Set the name of the DDE server application to aString."
    application := aString!   
validateItemName: anItemName
    | newItemName |

    ( anItemName isNil or: [ anItemName size = 0 ])
        ifTrue: [ ^false ].

    newItemName := anItemName asSymbol.

    " determine if valid proc name "
   ( self respondsTo: newItemName )
        ifTrue: [
            MessageBox
                notify: 'Add New Item'
                withText: 'Unable to add ''', newItemName,
                                ''' (already defined as script or message).'.
            ^false].
    newItemName first isLetter not
        ifTrue: [
            MessageBox
                notify: 'Add New Item'
                withText: 'Unable to add ''', newItemName,
                                ''' (first character must be a letter).'.
            ^false].
    ( newItemName indexOfString: '::' ) ~= 0
        ifTrue: [
            MessageBox
                notify: 'Add New Item'
                withText: 'Unable to add ''', newItemName,
                                ''' (missing an argument).'.
            ^false].

    newItemName do: [ :c |
        (c isAlphaNumeric or: [c = $:])
            ifFalse: [
                MessageBox
                    notify: 'Add New Item'
                withText: 'Unable to add ''', newItemName,
                                ''' (cannot use the character ''', (String with: c),
                                ''' in a message name).'.
            ^false]].

    (( newItemName indexOfString: ':' ) ~= 0 and: [
        newItemName last ~= $: ])
        ifTrue: [
            MessageBox
                notify: 'Add New Item'
                withText: 'Unable to add ''', newItemName,
                                ''' (missing a '':'' in the last argument).'.
            ^false].
    ^true!   
removePartRuntimeLibrary
        " Private - remove the DDE parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!   
ddeClientClass
        " Private - answer the DDE client class.
        Bind the DDE library if necessary. "

    ^self ddeClassNamed: #DDEClient!
initialize
    eventItems := OrderedCollection new.
    messageItems := OrderedCollection new!  
ddeClassNamed: aSymbol
        " Private - answer the DDE class named <aSymbol>.
        Bind the DDE library if necessary. "

    | aClass |
    aClass := Smalltalk at: aSymbol ifAbsent: [ nil ].
    aClass isNil
        ifTrue: [
            PARTSSessionManager
                bindLibrary: 'VDDE31', OperatingSystem name first asString
                errorTitle: 'DDE Installation Problem'
                neededFor: 'establishing DDE connections'.
            aClass := Smalltalk at: aSymbol ifAbsent: [ nil ] ].
    ^aClass!   
initiate
        "Initiate a DDE conversation. The default is to
         do nothing. Implemented by subclasses."!  
terminate
        "Terminate the DDE session."
    dde notNil
        ifTrue: [dde terminate]! 
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  When aSelector is an item in this
        DDE session, map it to the call method which
        invokes the entry point. "

    ^( self itemsAsMessages includes: aSelector )
        ifTrue: [ #updateExportedItem:arguments: ]
        ifFalse: [ aSelector ]!  
pokeItem: anItemName value: aValue
        " Poke aValue into anItemName in the 
        current conversation. "
    dde notNil
        ifTrue: [
            ^dde
                pokeItem: anItemName
                object: aValue]!   
initiate
        "Initiate a DDE conversion with the receiver as the server."

    | ddeServerClass |
    ( ddeServerClass := self class ddeServerClass ) isNil
        ifTrue: [ ^nil ].
    dde := ddeServerClass newServer: self
        application: application
        topic: topic.
    messageItems do: [ :item |
        dde addExportedItem: item object: 0 ]!
pokeFailed
        " The event handler for the current
        pokeItem:value: event wants to tell
        us that it failed. "
    requestStatus := false.!  
terminate
        "Terminate the DDE session."
    dde notNil
        ifTrue: [dde terminate]! 
ddeExecuteCommand: aString
        " An executeCommand request has
        been received by this dde server.
        Answer whether execution succeeded. "
    requestStatus := true.
    self 
        triggerEvent: #executeCommand:
        withArguments: (Array with: aString)
        ifNotHandled: [ ^false ].
    ^requestStatus!
executeCommand: aString
        " Execute the DDE command in aString. "
    dde notNil
        ifTrue: [ ^dde executeCommand: aString ]!   
topic: aString
        "Set the topic name of the DDE server to aString."
    topic := aString! 
pokeItem: aSelector valueArray: aValueArray
        " Private - set the value of an item
        in the current conversation. "
    | itemName |
    ^dde notNil ifTrue: [
        itemName := aSelector copyFrom: 1  to: aSelector size - 1.
        dde
            pokeItem: itemName
            object: aValueArray first]!  
initiate
        "Initiate a DDE conversation."

    | ddeClientClass |

    ( application isNil or: [ topic isNil ] )
        ifTrue: [
            ^self
                triggerEvent: #initiateException:topic:
                withArguments: ( Array with: application with: topic )
                ifNotHandled: [
                    MessageBox
                        notify: 'DDE Initiate Failed'
                        withText: ( application isNil
                            ifTrue: [ 'No application defined ']
                            ifFalse: [ 'No topic defined' ] ).
                    ^nil ] ].

    ( ddeClientClass := self class ddeClientClass ) isNil
        ifTrue: [ ^nil ].
    dde := ddeClientClass newClient: self
        application: application
        topic: topic.
    ( dde isNil or: [ dde server isNil ] )
        ifTrue: [
            ^self
                triggerEvent: #initiateException:topic:
                withArguments: ( Array with: application with: topic )
                ifNotHandled: [
                    MessageBox
                        notify: 'DDE Initiate Failed'
                        withText: 'Couldn''t initiate with server'.  " fix this... "
                    ^nil ] ].
    eventItems do: [ :itemName |
        dde
            hotLinkItem: itemName
            class: String
            selector: #item:string: ].!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | itemMessages |
    itemMessages := self itemsAsMessages.
    ^PARTSInterfaceList new
        items: #(#initiate #terminate
            #executionFailed #pokeFailed),
            itemMessages
        separators: ((itemMessages size = 0)
            ifTrue: [#( 2 )]
            ifFalse: [#( 2 4 )])
        defaultItem: #pokeFailed! 
topic
        "Answer the topic name of the DDE server."
    ^topic!
itemsAsEvents
        "Answer a collection of item names as events with ':'s appended."
    ^eventItems isNil
        ifTrue: [Array new]
        ifFalse: [eventItems collect: [ :i | (i , ':') asSymbol]]!  
application
        "Answer the name of the DDE server application."
    ^application!  
updateExportedItem: selector arguments: anArray
        " Alias message handler for DDE items "
    ^dde notNil
        ifTrue: [
            dde
                updateExportedItem: (selector asString upTo: $:)
                object: (anArray at: 1)]!
messageItems: aCollection
    messageItems := aCollection!   
ddePokeItem: aString object: anObject
        " A client has sent a poke request
        to this dde server. "
    | event |
    event := (aString, ':') asSymbol.
    requestStatus := true.
    (self itemsAsEvents includes: event)
        ifTrue: [
            self triggerEvent: event with: anObject]
        ifFalse: [
            self triggerEvent: #pokedItem:value:
                with: aString with: anObject].
    ^requestStatus!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    | staticMessages |
    staticMessages := #(
        #initiate #terminate
        #executeCommand:
        #requestItem: #pokeItem:value:).
    ^PARTSInterfaceList new
        items: staticMessages, self itemsAsMessages
        separators: (messageItems notEmpty
            ifTrue: [Array with: 2 with: 3 with: staticMessages size]
            ifFalse: [#(2 3)])
        defaultItem: #initiate!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    | events |
    events := self itemsAsEvents.
    ^PARTSInterfaceList new
        items: #(#executeCommand: #pokedItem:value: ), events
        separators: ((events size >0)
            ifTrue: [#( 2 )]
            ifFalse: [#()])
        defaultItem: #pokedItem:value:!   
partRealSelectorFor: aSelector
        " Answer the message to send for an alias link
        to access an item of the DDE conversation. "

    ^( self itemsAsMessages includes: aSelector )
        ifTrue: [ #pokeItem:valueArray: ]
        ifFalse: [ aSelector ]! 
executionFailed
        " The event handler for the current
        executeCommand: event wants to tell
        us that it failed. "
    requestStatus := false.! 
eventItems: aCollection
    eventItems := aCollection!   
item: anItemName string: string
        "The server has updated a hot linked item."
    self triggerEvent: (anItemName, ':') asSymbol with: string! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    | itemEvents |
    itemEvents := self itemsAsEvents.
    ^PARTSInterfaceList new
        items:
            #( #initiateException:topic: ),
            itemEvents
        separators: ((itemEvents size >0)
            ifTrue: [#( 1 )]
            ifFalse: [#()])
        defaultItem: #initiateException:topic:! 
PARTSDDE removePartRuntimeLibrary!
installPartRuntimeLibrary
        " Private - install the DDE parts runtime library.
        Load the workbench support library if appropriate. "

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'DDE Parts'.!