3.1.0.106
   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for object filing. "

    ^self copy
        fileId: nil;
        yourself!   
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

    self open.  " check if directory and file still exist?? "
    ^self! 
fileOutSurrogateObject
        " Private - answer the fileOut surrogate to use for the receiver.
        Clear the code cache.  Remove the source, since it will
        not be available in the same location in the loading environment. "

    ^self deepCopy
        primitive: nil;
        hideSource;
        yourself!
installComponent
       " Initialize the classes installed in the ObjectFiler load/dump support component. "

    self initialize.!
isObjectReference
        " Answer whether the receiver is an object reference. "

    ^false! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == nil
        ifFalse: [
            self recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.' ].
    ^nil!
fileOutSurrogate: anObjectFiler
        " Answer surrogate for object filing.
         Clear system resource handles to nil. "
    | surrogate instVarNames |
    surrogate := self copy.
    instVarNames := surrogate class allInstVarNames.
    surrogate
        handle: nil;
        instVarAt: (instVarNames indexOf: 'hLibrary') put: nil.
    ^surrogate!
fileOutSurrogate: anObjectFiler
        " Answer surrogate for object filing after performing any
        dump preprocessing.  Default is to do nothing.
        To notify user of non-fatal problem send:
                anObjectFiler recordInfoMessage: 'info message'
                anObjectFiler recordWarningMessage: 'warning message'
        "
    ^self!  
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the environment. "

    self == self class residue
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered.'.
            ^self ].
    ^ObjectReference forAction: ( Message
        receiver: self class
        selector: #residue )!   
fileInActivate: anObjectFiler
        "Activate instance which has just been filed in.
        Answer the activated version of the receiver.
        Bind the external references in the literal
        frame to the loading environment."

    1 to: self size do: [ :index |
        self fileInResolveLiteralAt: index for: anObjectFiler ].
    ^self!   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == Processor
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.'.
            ^nil ].
    ^ObjectReference forGlobalNamed: #Processor!   
fileOutSurrogate: anObjectFiler
        " Answer surrogate to store in an object file.
        Only special predefined handles which are the
        the same in all systems can be filed out; live
        handles are unique to this image and are unsafe
        to externalize. "

    self = self class nullValue
        ifFalse: [
                anObjectFiler recordWarningMessage:
                    'a ', self class name,
                    ' dumped as null handle, won''t be restored when loaded.'.
            ^self class nullValue ].
    ^self!  
fileOutSurrogateForLiteral: anAssoc pools: anArrayOfDictionaries for: anObjectFiler
        " Private - answer an external reference
        for the literal <anAssoc> in the receiver. "

    | aReference |

    " class or pool variable "
    ( self isLiteral: anAssoc inPools: anArrayOfDictionaries )
        ifTrue: [
            "^ComponentExternal classVar: anAssoc in: class ]."
            aReference := ObjectReference forSharedVariableNamed: anAssoc key
                referencedIn: class.
            aReference resolveWhenLoaded: false.
            ^aReference ].

    " global "
    ( anAssoc = (Smalltalk associationAt: anAssoc key ifAbsent: [nil] ) )
        ifFalse: [  " mangled method, apparently "
            anObjectFiler recordWarningMessage:
                'Unresolved variable, ', anAssoc key,
                ' in method ', self printString, '.'.
            "?? ^anAssoc? ^(Association key: anAssoc key value: nil) ??"
            ].
    aReference := ObjectReference forGlobalAssociationNamed: anAssoc key.
    aReference resolveWhenLoaded: false.
    ^aReference!   
isLiteral: anAssoc inPools: anArrayOfDictionaries
        " Private - answer whether any of the pool dictionaries
        in anArrayOfDictionaries contains anAssoc. "
    anArrayOfDictionaries do: [ :dict |
        ( anAssoc = ( dict associationAt: anAssoc key ifAbsent: [nil] ) )
            ifTrue: [ ^true ] ].
    ^false!   
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

    deviceContext notNil ifTrue: [ ^self ].  " already activated "
    self deviceContext: OldMemoryContext.
    ^self! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.  Clear absolute addresses. "

    | surrogate |
    surrogate := self copy.
    surrogate frameOffset: nil.
    ^surrogate!  
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded.
         Default is to do nothing.
        To notify user of non-fatal problem send:
                anObjectFiler recordInfoMessage: 'info message'
                anObjectFiler recordWarningMessage: 'warning message'
        "
    ^self!  
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded. "

    anObjectFiler recordWarningMessage:
        'a ', self class name,
        ' cannot be loaded properly, won''t  be bound.'.
    ^self! 
forGlobalAssociationNamed: aGlobalName
        " Answer a new instance of the receiver
        which represents the global association for
        the object named <aGlobalName> ."

    ^self new
        type: 'globalAssociation'
        value: aGlobalName asString! 
registerStandardTypes
        " Register the resolve actions for the standard types. "

    self
        registerType: 'global' resolveAction: #resolveGlobal;
        registerType: 'globalAssociation' resolveAction: #resolveGlobalAssocation;
        registerType: 'sharedVariable' resolveAction: #resolveSharedVariable;
        registerType: 'action' resolveAction: #resolveAction;
        yourself.!  
resolveActions
        " Private - answer the dictionary of resolve actions. "

    ^ResolveActions!   
forGlobalNamed: aGlobalName
        " Answer a new instance of the receiver
        which represents the global object named
        <aGlobalName> ."

    ^self new
        type: 'global'
        value: aGlobalName asString!   
standardTypes
        " Answer the names of the standard types
        supported as references. "

    ^#( 'global' 'globalAssociation' 'sharedVariable' 'evaluableAction' )! 
initialize
        " Initialize the standard types "

    self resolveActions: Dictionary new.
    self registerStandardTypes.!   
forAction: anEvaluableAction
        " Answer a new instance of the receiver
        which represents the action <anEvaluableAction>.
        The action should return the referenced object when evaluated."

    ^self new
        type: 'action'
        value: anEvaluableAction!  
new
		" Answer a new instance of the receiver. "

	^super new initialize!  
resolveActions: aDictionary
        " Private - set the dictionary of resolve actions. "

    ResolveActions := aDictionary.!  
registerType: aString resolveAction: anActionOrSymbol
        " Register <aString> as an object reference type.
        <anActionOrSymbol> specifies how instances of this
        type are resolved, with can either be a one-argument
        block which is evaluated with an ObjectReference of
        that type as its block argument or a Symbol which is
        the message to send to the instance. "

    self resolveActions at: aString put: anActionOrSymbol.!  
forSharedVariableNamed: aVariableName referencedIn: aClass
        " Answer a new instance of the receiver
        which represents a reference to a class or pool
        variable named <aVariableName> in the
        name scope of <aClass>.  A shared variable reference
        resolves to the association in the containing pool. "

    ^self new
        type: 'sharedVariable'
        value: ( Array
            with: aVariableName asString
            with: aClass name )! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the environment. "

    self == self class current
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered.'.
            ^self ].
    ^ObjectReference forAction: ( Message
        receiver: self class
        selector: #current )!   
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded.
        Verify that the receiver's class has not changed too much. "

    | aLoadMap filedSize loadSize slotArray |
    aLoadMap := anObjectFiler loadMapUsedFor: receiver.
    aLoadMap isNil
        ifTrue: [ ^self ].
    " check whether code will still work in spite of shape change "
    filedSize := aLoadMap sourceSize.
    loadSize := aLoadMap destinationSize.
    ( Smalltalk isRunTime and: [ filedSize > loadSize ] )
        ifTrue: [
            ^anObjectFiler recordAbortMessage:
                'Cannot load block from class ',
                receiver class name,
                ' (object shape has changed).' ].
    " check for inst vars being moved to different slots "
    slotArray := aLoadMap slotIndexArray.
    1 to: ( filedSize min: loadSize ) do: [ :index |
        ( slotArray at: index ) ~= index
            ifTrue: [  " an instance variable is being relocated "
                Smalltalk isRunTime
                    ifTrue: [  " runtime can't check for references, so give up "
                        ^anObjectFiler recordAbortMessage:
                            'Cannot load block from class ',
                            receiver class name,
                            ' (object shape has changed).' ]
                    ifFalse: [  " only complain if actually referenced in dev env "
                        ( ( method includesUseFor: index )
                        or: [ method includesSetFor: index] )
                            ifTrue: [
                                ^anObjectFiler recordAbortMessage:
                                    'Cannot load block from class ',
                                    receiver class name,
                                    ' (contains reference to a remapped instance variable).' ]].
                        ].
            ].
    " check references to dropped inst vars (dev env only) "
    ( loadSize + 1 ) to: filedSize do: [ :index |
        ( ( method includesUseFor: index )
        or: [ method includesSetFor: index] )
            ifTrue: [
                ^anObjectFiler recordAbortMessage:
                    'Cannot load block from class ',
                    receiver class name,
                    ' (contains reference to a deleted instance variable).' ].
            ].
    ^self!   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == OperatingSystem
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.'.
            ^nil ].
    ^ObjectReference forGlobalNamed: #OperatingSystem!   
= aReference
        "Answer whether the receiver and <aReference>
        refer to the same object."

    aReference isObjectReference
        ifFalse: [ ^false ].
    ^aReference type = self type
        and: [ aReference value = self value ]!  
asExternalReference
        " Private - answer an external reference
        which is equivalent to the receiver.  Answer nil if
        not supported. "

    type = 'global'
        ifTrue: [ ^ObjectStoreExternal globalNamed: value ].
    type = 'globalAssociation'
        ifTrue: [ ^ObjectStoreExternal assoc: (Association key: value asSymbol value: value) ].
    ^nil! 
isObjectReference
        " Answer whether the receiver is an object reference. "

    ^true!  
resolveAction
        "Private - Resolve the receiver."

    ^value evaluate!  
resolveGlobal
        "Private - Resolve the receiver."

    ^self resolveFromExternal!
description
        "Answer a string describing the receiver."

    ^value asString, ' (', type, ' reference)'!
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream."

    super printOn: aStream.
    type notNil
        ifTrue: [
            aStream nextPutAll: ' ( ', type, ': ', value printString, ' )' ].!  
resolveSharedVariable
        " Private - answer the assoc of the class or pool
        variable referenced by the receiver.  The variable
        reference is resolved in the context of
        of the name scope of the class from which
        it is referenced. "

    | variableName className aClass |
    variableName := value at: 1.
    className := value at: 2.
    aClass := self getClass: className
        ifAbsent: [ ^self ].
    aClass pools do: [ :aPoolDictionary |  " search pools in same order as compiler "
        ( aPoolDictionary includesKey: variableName )
            ifTrue: [ ^aPoolDictionary associationAt: variableName ] ].
    ^self!  
type: anInteger value: aValue
        "Private - Set the type and value of the receiver."

    type := anInteger.
    value := aValue.!   
initialize
        " Private - initialize a new instance "

    self resolveWhenLoaded: true.! 
resolveFromExternal
        "Private - Resolve the receiver from the equivalent
        external reference."

    | anExternal resolvedValue |
    anExternal := self asExternalReference.
    resolvedValue := anExternal resolve.
    ^resolvedValue == anExternal 
        ifTrue: [ self ] 
        ifFalse: [ resolvedValue ]!  
getClass: aClassName ifAbsent: aBlock
        " Private - answer the class named <aClassName>.
        Answer the value of aBlock if there is no such class. "

    ^ObjectStoreExternal getClass: aClassName asSymbol
        ifAbsent: aBlock! 
variableName
        " Answer the name of the global or shared variable
         referenced by the receiver.  Not supported after resolution. "

    ( #( 'global' 'globalAssociation' ) includes: self type )
        ifTrue: [ ^self value asSymbol ].
     self type = 'sharedVariable'
        ifTrue: [ ^self value at: 1 ].
    ^nil!   
fileInActivate: anObjectFiler
        "Activate instance which has just been filed in.
        Answer the object referenced by the receiver. "

    | resolvedValue |
    self resolveWhenLoaded
        ifFalse: [ ^self ].  " resolved by the client "
    resolvedValue := self resolve.
    resolvedValue == self
        ifTrue: [  " failed to resolve the reference "
            anObjectFiler recordWarningMessage:
                'Unable to resolve ', self description.
            ].
    ^resolvedValue!  
resolveWhenLoaded
        " Answer whether the receiver will resolve
        itself independently when loaded. "

    ^resolveWhenLoaded! 
resolveWhenLoaded: aBoolean
        " Specify whether the receiver should resolve
        itself independently when loaded.  If not,
        the client which owns this reference is
        is responsible for resolving it during its own
        #fileInActivate: processing. "

    resolveWhenLoaded := aBoolean.!
type: aString
        "Private - Set the type of the receiver."

    type := aString.! 
resolveGlobalAssocation
        "Private - Resolve the receiver."

    ^self resolveFromExternal!  
value
        "Private - Answer the value of the receiver."

    ^value!   
type
        "Answer a string that represents the type of the
         receiver."

    ^type! 
value: aValue
        "Private - Set the value of the receiver.
        The appropriate kind of object to provide
        as the value depends of the type. "

    value := aValue.! 
hash
        "Answer the receiver's hash."

    ^self type hash + self value hash! 
resolve
        "Answer the object referenced by the receiver."

    | resolveAction resolvedValue |
    type = 'resolved'
        ifTrue: [ ^value ].  "Already done."
    resolveAction := self class resolveActions at: type
        ifAbsent: [ "?? self error: 'unknown type' ??" #yourself ].
    resolvedValue := ( resolveAction isSymbol
        ifTrue: [ self perform: resolveAction ]
        ifFalse: [ resolveAction evaluateWithArguments: (Array with: self) ] ).
    ( resolvedValue == self )
        ifTrue: [ ^self ].
    type := 'resolved'.
    value := resolvedValue.
    ^value! 
fileInResolveLiteralAt: anIndex for: anObjectFiler
        "Private - Resolve an external reference in the
        literal frame to the loading environment.
        Answer whether successful. "

    | aLiteral |
    aLiteral := self at: anIndex.
    aLiteral isObjectReference
        ifTrue: [
            aLiteral := aLiteral resolve.
            aLiteral isObjectReference
                ifTrue: [  " failed to resolve the reference "
                    self at: anIndex put: ( Association
                        key: aLiteral variableName
                        value: nil ).
                    anObjectFiler recordWarningMessage:
                        'Unable to resolve ', aLiteral description,
                        ' in method ', self printString, '.'.
                    ^false ]
                ifFalse: [
                    self at: anIndex put: aLiteral.
                    ^true ].
            ].
    ^true!   
fileInActivate: anObjectFiler
        "Activate instance which has just been filed in.
        Recompute the pixel size for the current display, based
        on the point size of the font. "

    self graphicsMedium == Display
        ifTrue: [ self mapPointSizeToMedium ].! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        A process is only relevant in the current
        execution environment and cannot be filed out. "

    anObjectFiler recordWarningMessage:
        'a ', self class name,
        ' cannot be dumped properly, won''t be bound when loaded.'.
    ^self class basicNew
        initialSize: 0;  " empty contents so hash works properly "
        name: self name;
        yourself!   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == true
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to true.' ].
    ^true!
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the environment. "

    self == SymbolTable
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.'.
            ^nil ].
    ^ObjectReference forGlobalNamed: #SymbolTable!
fileOutSurrogate: anObjectFiler
        " Answer surrogate for object filing.  Save bitmap
         bits in archive and clear system handles. "
    | surrogate instVarNames |
    self saveBitmap.
    surrogate := self copy.
    instVarNames := surrogate class allInstVarNames.
    surrogate   " clear system resource handles to nil "
        deviceContext: nil;
        graphicsTool: nil;
        instVarAt: (instVarNames indexOf: 'bitmapHandle') put: nil;
        instVarAt: (instVarNames indexOf: 'palette') put: nil.
    ^surrogate!   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == Notifier
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.'.
            ^nil ].
    ^ObjectReference forGlobalNamed: #Notifier! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.  Literal frame assocs
        referencing globals, class variables, and pool variables
        are stored as external references which are rebound
        during loading. "

    | surrogate poolDictionaries aLiteral |

    surrogate := self fileOutSurrogateObject.

    " return from standalone block fails reasonably when reloaded, so let it go:
    ( Smalltalk isRunTime not and: [self hasReturnFromBlock] )
        ifTrue:
            [ anObjectFiler recordWarningMessage:
                'a block may contain a return statement, which cannot be properly executed.'
            ].
    "

    self size = 0
        ifTrue: [ ^surrogate ].

    " map literal frame assocs (globals, class vars, pool vars)
        into external references which will be rebound
        at load time. "
    poolDictionaries := class pools.  " search pools in same order as compiler "
    1 to: surrogate size do: [ :index |
        ( aLiteral := surrogate at: index ) isAssociation
            ifTrue: [
                surrogate at: index put: ( self
                    fileOutSurrogateForLiteral: aLiteral
                    pools: poolDictionaries
                    for: anObjectFiler ) ].
        ].
    ^surrogate! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for object filing.
         Clear session-dependent values which are reset
        when the font is reloaded and recreated. "

    | surrogate |
    surrogate := self copy.
    surrogate
        fontHandle: nil;
        physicalFontAttribute: nil;
        yourself.
    ^surrogate!   
fileOutSurrogate: anObjectFiler
        " Answer surrogate for object filing.  Zap handle. "
    | surrogate |
    surrogate := self copy.
    surrogate handle: nil.
    ^surrogate!
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the environment. "

    self == Clipboard
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered.'.
            ^self ].
    ^ObjectReference forGlobalNamed: #Clipboard!  
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == false
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to false.' ].
    ^false! 
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the environment. "

    self == Smalltalk
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.'.
            ^nil ].
    ^ObjectReference forGlobalNamed: #Smalltalk!
fileOutSurrogate: anObjectFiler
        " Answer surrogate for filing out.
        Only one instance of the receiver's class
        should exist in the universe. "

    self == Display
        ifFalse: [
            anObjectFiler recordWarningMessage:
                ' duplicate member of singular class ',
                self class printString,
                ' was encountered; mapped to nil.'.
            ^nil ].
    ^ObjectReference forGlobalNamed: #Display!