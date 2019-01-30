3.1.0.106
   
setObject: anObject format: aFormat
        "Private - Set the contents of the clipboard to anObject
         using format aFormat."

    | filedObject size description |
    filedObject := WriteStream on: String new.
    filedObject nextULongPut: 0.  " size placeholder "
    ObjectFiler dump: anObject on: filedObject.
    size := filedObject position.
    filedObject
        reset;
        nextULongPut: ( size - 4 ).  " size of filed object itself "
    filedObject := filedObject copyFrom: 1 to: size.
    self open ifFalse: [^nil].
    self empty.
    UserLibrary setClipboardData: aFormat
        hMem: (ExternalGlobalAddress memoryHandleFrom: filedObject asParameter).
    description :=
        (UserFormats keyAtValue: aFormat),
        ' (', anObject printString, ')'.
    UserLibrary setClipboardData: CfDsptext
        hMem: (ExternalGlobalAddress memoryHandleFrom: description asParameter).
   self close.!   
getObject: aFormat
        "Private - Answer the contents of the clipboard as an object,
        or nil if the clipboard is empty or cannot render an object
         in aFormat."

    | hText lpText addr size filedObject |
    self open ifFalse: [self close. ^nil].
    ( self containsFormat: aFormat )
        ifFalse: [self close. ^nil].
    ( hText := UserLibrary getClipboardData: aFormat ) = 0
        ifTrue: [self close. ^nil].
    lpText := KernelLibrary globalLock: hText.
    addr := ExternalGlobalAddress fromInteger: lpText.
    size := ( String fromAddress: addr length: 4 )
        asStream nextULong.
    addr := ExternalGlobalAddress fromInteger: lpText + 4.
    "This is binary data that must not be changed to normalized string."
    filedObject := String fromAddressUnchanged: addr length: size.
    KernelLibrary globalUnlock: hText.
    self close.
    ^ObjectFiler loadFrom: (ReadWriteStream on: filedObject)!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system."

    | parentWindow |

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " upgrade pane stored from pre-3.0 system "

    " SubPane 'id' inst var is new in 3.0 (migrate up from VOS 2.0 ControlPane
            or move from properties in VWin32 2.0) "
    id isNil
        ifTrue: [
            ( parentWindow := self superWindow ) notNil
                ifTrue: [ id := parentWindow children keyAtValue: self ].
            ].
    self propertyAt: #id put: nil.

    " all panes have WsVisible style in 3.0 (unless hidden) "
    ( self propertyAt: #hidden ) isNil
        ifTrue: [
            style notNil ifTrue: [ self addStyle: WsVisible ] ]
        ifFalse: [
            self removeStyle: WsVisible.
            self propertyAt: #hidden put: nil ].

    self fileInUpgradeHandlers: anObjectFiler.
   ^super fileInUpgrade: anObjectFiler! 
containsObject
        " Answer whether the clipboard contains an object. "
    ^self containsFormat: self formatObject!
setObject: anObject
        "Set the contents of the clipboard to anObject."
    self setObject: anObject format: self formatObject.!   
fileInUpgradeExternal: anExternal
        " Private - answer an ObjectReference corresponding
        to <anExternal> for the receiver's literal frame.
        All global, class, and pool variable references were
        represented by an ObjectLibraryExternal in R2.0.
        The representation and semantics of shared variable
        externals changed in the R3.0 ComponentExternal, so the
        old resolve semantics are provided by ObjectReference. "

    | variableName aReference |

    anExternal type = 'AssocExternal'
        ifTrue: [
            variableName := anExternal value.
            aReference := ObjectReference forGlobalAssociationNamed: variableName.
            aReference resolveWhenLoaded: false.
            ^aReference ].

     anExternal type = 'ClassVariableExternal'
        ifTrue: [  " also used for pool variables here "
            "self ASSERT: ( (anExternal value at: 2) asSymbol = class symbol."
            variableName := ( anExternal value isArray
                ifTrue: [ anExternal value at: 1 ]   " VOS 3.0 pre-beta2 "
                ifFalse: [ anExternal value asArrayOfSubstrings first ] ).
            aReference := ObjectReference
                forSharedVariableNamed: variableName
                referencedIn: class.
            aReference resolveWhenLoaded: false.
            ^aReference ].
    ^anExternal!  
fileInUpgrade: anObjectFiler
		" Upgrade the receiver into the form expected in
		the current system.  Answer the upgraded object
		Font class had internal state redesign in 3.0. "

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " upgrade font stored from pre-3.0 system "
    " put the receiver into the normal externalized state, per #fileOutSurrogate: "
	self
		fontHandle: nil;
		 physicalFontAttribute: nil.
	" normal state for a Font in 3.0 is to be connected to the screen "
	graphicsMedium isNil
		ifTrue: [ graphicsMedium := Display ].!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

	| fontProperty |

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " upgrade pane stored from pre-3.0 system "
	" font property redundant, curFont inst var holds the truth in 3.0 "
	( fontProperty := self propertyAt: #font ) notNil
		ifTrue: [
			curFont ~= fontProperty
				ifTrue: [ curFont := fontProperty ].
			self propertyAt: #font put: nil ].
	^super fileInUpgrade: anObjectFiler!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Method literals referencing
        globals and shared variables were stored as
        ObjectLibraryExternals in VOS/VW 2.0.  These
        are mapped into ComponentExternals during 3.0
        loading so they can be converted here into the
        equivalent ObjectReference values used in 3.0. "

    | aLiteral newLiteral |

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " upgrade method stored from pre-3.0 system "
    1 to: self size do: [ :index |
        ( aLiteral := self at: index ) class == ObjectStoreExternal
            ifTrue: [
                newLiteral := self fileInUpgradeExternal: aLiteral.
                newLiteral class == ObjectStoreExternal
                    ifTrue: [
                        anObjectFiler recordWarningMessage:
                            'Upgrade problem with method literal in ',
                            self printString,
                            ' (', aLiteral printString, ').' ]
                    ifFalse: [
                        self at: index put: newLiteral.
                        anObjectFiler registerUpgradeMutationFrom: aLiteral
                            to: newLiteral.
                        ].
            ] ].!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    | isReadOnly |

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " upgrade entry field stored from pre-3.0 system "

    handle isBoolean
        ifTrue: [  " obsolete 2.0 readonly inst var value stashed here during loading "
            isReadOnly := handle.
            handle := WindowHandle nullValue ].

    " readonly value maintained only in style setting in 3.0 "
    isReadOnly == true
        ifTrue: [ self readOnly: true ].
    ^super fileInUpgrade: anObjectFiler! 
fileInRehash: anObjectFiler
        " Private - rehash the contents of the receiver if necessary
        when loading a hashed collection stored from an earlier version.
        Answer a collection of Association's mapping the original
        values to new values if any of the receiver's instance variables
        were changed to different objects. "

    | oldContents aKey |

    " hashed collections were redesigned in R3.0, so everything from
        earlier versions needs to be drastically upgraded "
    "self ASSERT: anObjectFiler isLoadingCurrentVersion not "
    ( anObjectFiler objectVersion < 9  " pre-3.0 object "
    and: [ anObjectFiler currentVersion >= 9 ] )  " 3.0 or later loader "
        ifTrue: [
            oldContents := contents.
            self initialSize: ( self class allocationForSize: elementCount ).
            1 to: oldContents size by: 2 do: [ :aKeyIndex |
                ( aKey := oldContents at: aKeyIndex ) notNil
                    ifTrue: [ self at: aKey put: ( oldContents at: aKeyIndex + 1 ) ] ].
            anObjectFiler registerUpgradeMutationFrom: oldContents to: contents.
            ^self ].

    " IdentityDictionary instances dumped from VPM 1.2 (version 3)
        need to be rehashed - that version of the ObjectFiler
        didn't correctly dump the basicHash value, so
        hashed objects based on that value won't work
        until rehashed on the current platform. "
    " class basicHash changed in 32-bit VWin32 2.0 image, so
        IdentityDictionary's from 16-bit VW 2.0 need to be fixed "
    ( #( 3 4 ) includes: anObjectFiler objectVersion )
        ifTrue: [
            self rehash.
            ^self ].!  
formatObject
        " Answer the clipboard format for Smalltalk objects "
    ^self formatNamed: 'Smalltalk/V Object'! 
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

    anObjectFiler recordWarningMessage:
        'Upgrade problem: ', self printString,
        'should not exist anymore (encountered in #fileInActivate:).'!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object.
        Map a pre-R3.0 Directory into the current representation.
        Note that the VW 2.0 inst vars 'searchHandle' and 'searchAttribute'
        are dropped by this upgrade; don't believe they're significant.
        Similarly, the 'volumeLabel' inst var is simply dropped. "

    ^self asDirectory!   
asDirectory
        " Answer the receiver as a Directory "

    | directoryPath |
    directoryPath := pathName trimBlanks.  "Get rid of zero-terminator."
    directoryPath first ~= $:
        ifTrue: [ directoryPath := ':', directoryPath ].  " drive letter separator for absolute path name "
    ^Directory fromPath: ( String with: drive ), directoryPath!   
fileInUpgradeHandlers: anObjectFiler
        " Private - upgrade the receiver's event handlers.
        The new event system introduced in dual-mode in VWin32 2.0
        is the preferred mechanism in 3.0 "

    | handlersAttribute oldEventHandlers newEventTable |

    handlersAttribute := self handlersAttribute.
    handlersAttribute isArray
        ifTrue: [
            oldEventHandlers := handlersAttribute at: 1.
            newEventTable := handlersAttribute at: 2 ]
        ifFalse: [
            oldEventHandlers := handlersAttribute ].
    oldEventHandlers size > 0
        ifTrue: [  " shift old handlers to property during load wrapup "
            anObjectFiler
                when: #loaded
                send: #propertyAt:put:
                to: self
                with: #oldHandlers with: oldEventHandlers ].
    self handlersAttribute: ( newEventTable size = 0
		ifTrue: [ nil ]
        ifFalse: [ newEventTable ] ).!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object.
        This message is sent to each object being loaded,
        prior to normal load activation, when the filed object
        was stored from a system with a different version stamp.
        Default is to do nothing. "

    ^self!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    ( anObjectFiler objectVersion between: 3 and: 7 )
        ifTrue: [
            " modified is new for VOS in 3.0; migrated up from VWin32 2.0 TextPaneControl in 3.0 "
            modified isNil ifTrue: [ modified := false ].
            " maxSize/readLimit value moved to property in 3.0 "
            topCorner isInteger
                ifTrue: [
                    self textLimit: topCorner.
                    topCorner := self initialTopCorner ].
            ].
    ^super fileInUpgrade: anObjectFiler!   
getObject
        "Answer the contents of the clipboard as an object,
        or nil if the clipboard is empty or cannot render an object."
    ^self getObject: self formatObject!
fileInRehash: anObjectFiler
        " Private - rehash the contents of the receiver if necessary
        when loading a hashed collection stored from an earlier version.
        Answer a collection of Association's mapping the original
        values to new values if any of the receiver's instance variables
        were changed to different objects. "

    | oldContents |

    " hashed collections were redesigned in R3.0, so everything from
        earlier versions needs to be drastically upgraded "
    "self ASSERT: anObjectFiler isLoadingCurrentVersion not "
    ( anObjectFiler objectVersion < 9  " pre-3.0 object "
    and: [ anObjectFiler currentVersion >= 9 ] )  " 3.0 or later loader "
        ifTrue: [
            oldContents := contents.
            self initialSize: ( self class allocationForSize: elementCount ).
            oldContents do: [ :anEntry |
                anEntry notNil ifTrue: [ self add: anEntry ] ].
            anObjectFiler registerUpgradeMutationFrom: oldContents to: contents.
            ^self ].!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    anObjectFiler objectVersion > 8
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " upgrade window stored from pre-3.0 system "

    " all windows have WsVisible style in 3.0 (unless hidden) "
    ( self propertyAt: #hidden ) isNil
        ifTrue: [
            style notNil ifTrue: [ self addStyle: WsVisible ] ]
        ifFalse: [
            self removeStyle: WsVisible.
            self propertyAt: #hidden put: nil ].

    self fileInUpgradeHandlers: anObjectFiler.
   ^super fileInUpgrade: anObjectFiler! 
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

    anObjectFiler recordWarningMessage:
        'Upgrade problem: ', self printString,
        'should not exist anymore (encountered in #fileInActivate:).'!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object.
        Map a pre-R3.0 File into the current representation.
        The old 'fileId' inst var isn't brought in because it was
        always bashed to nil when filed out anyway. "

    ^File fromPath: name
        in: ( directory isDirectory
            ifTrue: [ directory ]  " already activated "
            ifFalse: [ directory asDirectory ] )!
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