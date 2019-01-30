Copyright 1990-1994 Digitalk Inc.  All rights reserved

! DelegationObject class methods !  
aboutToSaveImage
    "Private - Default code.  Redefined by subclasses.
    Required by the system to save the image."! !

! DelegationObject methods !   
class
    "Answer the class of the receiver."

    <primitive: 111>
    ^Object primitiveFailed!  
doesNotUnderstand: aMessage
    "The receiver has received a message which it does not
    understand. Subclasses should override this method to get
    the desired delegation behavior."

    ^MessageNotUnderstood message: aMessage! 
implementedBySubclass
    "Initiate a walkback because a subclass doesn't implement a message that it should."

    ^Object error: 'My subclass should have implemented this message...'!  
isDelegationObject
    "Return true if the receiver is a delegation object."

    ^true!   
printOn: aStream

    aStream nextPutAll: self class name!  
vmInterrupt: aSymbol
    "Private - Process virtual machine interrupt. Required to
    allow handling of control-break while the current process
    is evaluating a message sent to the receiver."

    Process perform: aSymbol.
    ^self! !

! ContainerObject class methods !
defaultSize

    ^10!   
new

    ^self new: self defaultSize!   
new: anInteger

    ^super new
        privateContainerObjectInitializeTo: anInteger!  
organizerFrom: aString
    "Update my selected class's method organizer according to aString"

    | anOrganizer storeString |

    self selectedClass isNil | (self selectedClasses size > 1)
        ifTrue: [^self].
    storeString := '(MethodBasedOrganizer fromArray: #(', aString, '))'.
    anOrganizer := Compiler evaluate: storeString.
    anOrganizer isNil
        ifTrue: [^self].
    anOrganizer
        owner: self selectedSmalltalkClassOrMetaclass;
        update;
        updateDefaultCategory.
    CodeFiler setOrganizerFor: self selectedClassOrMetaclass to: anOrganizer.
    SourceManager current logEvaluate:
        '(CodeFiler setOrganizerFor: ', self selectedClassOrMetaclass, ' to: ''', storeString, '''.'.
    self privateValidateSelection.! 
OrganizerFrom: aString
    "Update my selected class's method organizer according to aString"

    | anOrganizer storeString |

    self selectedClass isNil | (self selectedClasses size > 1)
        ifTrue: [^self].
    storeString := '(MethodBasedOrganizer fromArray: #(', aString, '))'.
    anOrganizer := Compiler evaluate: storeString.
    anOrganizer isNil
        ifTrue: [^self].
    anOrganizer
        owner: self selectedSmalltalkClassOrMetaclass;
        update;
        updateDefaultCategory.
    CodeFiler setOrganizerFor: self selectedClassOrMetaclass to: anOrganizer.
    SourceManager current logEvaluate:
        '(CodeFiler setOrganizer: ', storeString, ' for: ''', self selectedClassOrMetaclass, '''.'.
    self privateValidateSelection.! !

! ContainerObject methods !  
doesNotUnderstand: aMessage
    "The receiver has received a message which it does not
    understand. See if we have a key in the contents dictionary
    that matches the selector of the message."

    | selector arguments |
    selector := aMessage selector.
    arguments := aMessage arguments.
    ^selector last == $:
        ifTrue: [
            selector := (selector copyFrom: 1 to: selector size - 1) asSymbol.
            arguments size = 1
                ifFalse: [self privateContainerObjectErrorBadSetSelector: selector].
            self
                privateContainerObjectSet: selector
                to: arguments first]
        ifFalse: [
            arguments notEmpty
                ifTrue: [self privateContainerObjectErrorBadGetSelector: selector].
            self
                privateContainerObjectGet: selector
                ifAbsent: [self privateContainerObjectErrorMissingKey: selector]]!  
inspect
    ^contents inspect!   
privateContainerObjectError: errorString
    "Private - Open a walkback window to signal an error condition."

    ^Error signal: errorString! 
privateContainerObjectErrorBadGetSelector: aSymbol
    "Private - A message has been sent to get a value from the receiver.
    The selector passed in is not a valid get selector (unary message).
    Signal an error."

    ^self privateContainerObjectError: 'Bad get selector: ', aSymbol! 
privateContainerObjectErrorBadSetSelector: aSymbol
    "Private - A message has been sent to set a key-value pair in the receiver.
    The selector passed in is not a valid set selector (one-keyword message).
    Signal an error."

    ^self privateContainerObjectError: 'Bad set selector: ', aSymbol!
privateContainerObjectErrorMissingKey: aSymbol
    "Private - A message has been sent to get a value from the receiver.
    The selector passed in is not an existing key in the receiver.
    Signal an error."

    ^self privateContainerObjectError: 'Missing key: ', aSymbol!   
privateContainerObjectGet: key ifAbsent: errorBlock
    "Private - Return the value stored in association with key. If the key is missing,
    evaluate the error block."

    ^contents
        at: key
        ifAbsent: errorBlock!  
privateContainerObjectInitializeTo: initializeSize

    contents := Dictionary new: initializeSize! 
privateContainerObjectSet: key to: value
    "Private - Store the given object in association with key."

    ^contents
        at: key
        put: value! !

! Object class methods !
example1
    "Object example1 veryDeepCopy"
    | object1 object2 |
    object1 := OrderedCollection new. object2 := Array with: object1.
    object1 add: object2.
    ^object1!
example2
    "Object example2 veryDeepCopy"
    | object1 object2 |
    object1 := OrderedCollection new. object2 := Array with: 'hello'.
    object1 add: object2; add: object2.
    ^object1!  
example3
    "Object example3"
    | object1 object2 |
    object1 := Array new: 2. object2 := Array new: 2.
    object1 at: 1 put: object2.
    object1 at: 2 put: object1.
    object2 at: 1 put: object1.
    object2 at: 2 put: object2.
    ^object1 equal: object2! !

! Object methods ! 
clone
    ^self veryDeepCopy!
color8: a with: b

    ^self

!   
equal: anObject
    ^self veryDeepEqualTo: anObject withoutRecomparing: IdentityDictionary new!  
isPrimitiveComparisonObject
    ^false!  
releaseCopyDependents
    ^self releaseEventTable!   
veryDeepCopy
    ^self veryDeepCopyWithoutRecopying: IdentityDictionary new! 
veryDeepCopyWithoutRecopying: existingCopies
    "Answer a deep copy of the receiver."
    | copy newPart namedVariables unnamedVariables class |
   ^existingCopies at: self ifAbsent: [
        copy := self shallowCopy.
        copy == self ifTrue: [^self]. "Can't be copied."
        existingCopies at: self put: copy.
        class := self class.
        "Objects containing bytes (byte arrays, strings) don't need further copying."
        class isPointers ifFalse: [^copy].
        self releaseCopyDependents.
        namedVariables := class instSize.
        unnamedVariables := class isVariable
            ifTrue: [self basicSize]
            ifFalse: [0].
        1 to: namedVariables do: [:index |
            newPart := (copy instVarAt: index)
                veryDeepCopyWithoutRecopying: existingCopies.
            copy instVarAt: index put: newPart].
        1 to: unnamedVariables do: [:index |
            newPart := (copy basicAt: index)
                veryDeepCopyWithoutRecopying: existingCopies.
            copy basicAt: index put: newPart].
        ^copy]!
veryDeepEqualTo: anObject withoutRecomparing: existingPairs
    "Answer a deep comparison of the receiver with anObject."
    | candidates namedVariables unnamedVariables class |
    self isPrimitiveComparisonObject ifTrue: [^self = anObject].
    self species == anObject species ifFalse: [^false].
    self size = anObject size ifFalse: [^false].
    (class := self class) isPointers ifFalse: [^self = anObject].
    candidates := existingPairs at: self ifAbsent: [existingPairs at: self put: IdentityDictionary new].
    ^candidates at: anObject ifAbsent: [
        candidates at: anObject put: true.
        namedVariables := class instSize.
        unnamedVariables := self basicSize.
        1 to: namedVariables do: [:index |
            ((self instVarAt: index) veryDeepEqualTo: (anObject instVarAt: index)
                withoutRecomparing: existingPairs) ifFalse: [^false]].
        1 to: unnamedVariables do: [:index |
            ((self basicAt: index) veryDeepEqualTo: (anObject basicAt: index)
                withoutRecomparing: existingPairs) ifFalse: [^false]].
        ^true]! !

! Behavior methods !   
classImplementorsOf: aSymbol
        "Answer a collection of methods of the receiver that implement aSymbol."

    | methods  |

    methods := OrderedCollection new: 30.
    (self includesSelector: aSymbol)
        ifTrue: [methods add: (self compiledMethodAt: aSymbol)].
    (self class includesSelector: aSymbol)
        ifTrue: [methods add: (self class compiledMethodAt: aSymbol)].
    ^methods!
classSendersOf: aSymbol
        "Answer a collection of methods of myself that send aSymbol."

    | methods special |

    methods := OrderedCollection new: 30.
    special := CompiledMethod specialSelectors includesKey: aSymbol.
    self methodDictionary do: [:method |
        special
            ifTrue: [
                ( method referencesSpecial: aSymbol )
                    ifTrue: [ methods add: method ] ]
            ifFalse: [
                ( ( method references: aSymbol ) and: [ method selector ~= #Doit ] )
                    ifTrue: [ methods add: method ] ] ].
    self class methodDictionary do: [:method |
        special
            ifTrue: [
                ( method referencesSpecial: aSymbol )
                    ifTrue: [ methods add: method ] ]
            ifFalse: [
                ( method references: aSymbol )
                    ifTrue: [ methods add: method ] ] ] .
    ^methods!  
comment: anything!
methods
        "Answer an instance of ClassReader
         initialized for the receiver."

    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [((Smalltalk at: #CodeFiler) organizerFor: self) makeDirty].

    ^ClassReader forClass: self
!   
methodsFor: protocol

    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [((Smalltalk at: #CodeFiler) organizerFor: self) makeDirty].

    ^(Smalltalk at: #ParcPlaceClassReader) for: self protocol: protocol
! !

! Class methods !
subclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    categories: categories
        "Create or modify the class classSymbol to be
         a subclass of the receiver with the specifed
         instance variables, class variables, and pool
         dictionaries."

    | result |
    result := self
        subclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames.
    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [
            (Smalltalk at: #CodeFiler) systemOrganizer
                removeElement: classSymbol;
                addElement: classSymbol toCategories: categories].
    ^result!   
subclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    category: category
        "Create or modify the class classSymbol to be
         a subclass of the receiver with the specifed
         instance variables, class variables, and pool
         dictionaries."

    ^self
        subclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames
        categories: (Array with: category)!   
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
	isVariable: variableBoolean
	isPointers: pointersBoolean
        "Private - Create or modify the class named <className> to be a
        subclass of the receiver with the specifed instance variables,
        class variables, pool dictionaries, and indexable state"

	^DefinitionInstaller current
        defineClassNamed: className
        subclassOf: self
        instanceVariableNames: instanceVariables
        variable: variableBoolean
        pointers: pointersBoolean
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries! 
variableByteSubclass: classSymbol
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    categories: categories
        "Create or modify the class classSymbol to be
         a variable byte subclass of the receiver with the
         specified class variables and pool dictionaries."

    | result |
    result := self
        variableByteSubclass: classSymbol
        classVariableNames: classVariables
        poolDictionaries: poolDictNames.
    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [
            (Smalltalk at: #CodeFiler) systemOrganizer
                removeElement: classSymbol;
                addElement: classSymbol toCategories: categories].
    ^result!   
variableByteSubclass: classSymbol
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    category: category
        "Create or modify the class classSymbol to be
         a variable byte subclass of the receiver with the
         specified class variables and pool dictionaries."

    ^self
        variableByteSubclass: classSymbol
        classVariableNames: classVariables
        poolDictionaries: poolDictNames
        categories: (Array with: category)!   
variableByteSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a variable
        byte subclass of the receiver with the specified class variables
        and pool dictionaries."
    | installer |
    installer := ClassInstaller
        name: className
        environment: ClassInstaller defaultGlobalDictionary
        subclassOf: self
        instanceVariableNames: instanceVariables
        variable: true
        pointers: false
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries.
    ^installer install! 
variableSubclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    categories: categories
        "Create or modify the class classSymbol to be a
         variable subclass of the receiver with the specifed
         instance variables, class variables, and pool dictionaries."

    | result |
    result := self
        variableSubclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames.
    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [
            (Smalltalk at: #CodeFiler) systemOrganizer
                removeElement: classSymbol;
                addElement: classSymbol toCategories: categories].
    ^result!
variableSubclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    category: category
        "Create or modify the class classSymbol to be a
         variable subclass of the receiver with the specifed
         instance variables, class variables, and pool dictionaries."

    ^self
        variableSubclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames
        categories: (Array with: category)! !

! MetaClass methods ! 
Doit
    ^Vehicle example1! !

! ChangeSetItem class methods ! 
initializeTypeSortOrder
    " (ChangeSetItem initializeTypeSortOrder) "

    TypeSortOrder := OrderedCollection new
        add: ChangeSetClassDefinitionItem;
        add: ChangeSetRemoveClassItem;
        add: ChangeSetClassCommentItem;
        add: ChangeSetClassReorganizationItem;
        add: ChangeSetMethodItem;
        add: ChangeSetRemoveMethodItem;
        add: ChangeSetMethodReorganizationItem;
        add: ChangeSetAddProtocolItem;
        add: ChangeSetRenameProtocolItem;
        add: ChangeSetRemoveProtocolItem;
        add: ChangeSetEvaluateItem;
        yourself
!  
new

    ^super new initialize! 
sortBlock

    ^[:a :b |
        a date = b date
            ifTrue: [a time <= b time]
            ifFalse: [a date < b date]]! 
typeSortOrder
    "Return a constant that gives the receiver's order when sorted by type."

    ^self typeSortOrderCollection indexOf: self
! 
typeSortOrderCollection

    TypeSortOrder isNil
        ifTrue: [self initializeTypeSortOrder].

    ^TypeSortOrder
! !

! ChangeSetItem methods !   
= aChangeSetItem

    ^self class == aChangeSetItem class
!
annotationLabel

    ^self title
! 
date

    ^date!
date: aDate

    date := aDate! 
exportEpilogueOn: aStream
    "Private - Export my epilogue on aStream"

    aStream nextPutAll: '                   yourself)'
! 
exportInformationOn: aStream
    "Private - Export my information on aStream"
! 
exportOn: aStream
    "Export myself on a stream in such a way that I will be reconstructed correctly when filed in"

    self
        exportPrologueOn: aStream;
        exportInformationOn: aStream;
        exportEpilogueOn: aStream
!
exportPrologueOn: aStream
    "Export myself on a stream in such a way that I will be reconstructed correctly when filed in"

    aStream
        nextPutAll: '(', self class name, ' new';cr;
        nextPutAll: '                   date: (Date fromString: ', self date printString printString, ');' ;cr;
        nextPutAll: '                   time: (Time fromString: ', self time printString printString, ');'  ;cr.

!
fileOutItemOn: aStream with: aCodeFilerClass

    ^self!
fileOutOn: aStream with: aCodeFilerClass

    self
        fileOutSourceOn: aStream with: aCodeFilerClass;
        fileOutItemOn: aStream with: aCodeFilerClass!  
fileOutSourceOn: aStream with: aCodeFilerClass

    self implementedBySubclass! 
hash
    ^self class name hash
!
includesCategory: aString
    ^false
!  
initialize

    self
        time: Time now;
        date: Date today!
isClassBased

    ^false
! 
isClassDefinitionItem

    ^false
!
isMethodItem

    ^false!   
isRemoveMethod

    ^false! 
label

    ^date printString, ' ', time printString asLowerCase!
owner

    ^owner!  
owner: aChangeSet

    owner := aChangeSet! 
time

    ^time!
time: aTime

    time := aTime! 
timeDateStamp

    ^self date printString, ' ', self time printString!  
title

    ^self implementedBySubclass! !

! ChangeSetEvaluateItem methods !  
= aChangeSetItem

    ^super = aChangeSetItem and: [source = aChangeSetItem source]!
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream nextPutAll: '                   source: ', source printString, ';';cr.
!
fileOutSourceOn: aStream with: aCodeFilerClass

    aStream nextChunkPut: source
! 
hash

    ^source hash! 
printOn: aStream

    | string |
    string := source size > 10
        ifTrue: [(source copyFrom: 1 to: 10), '...']
        ifFalse: [source].

    aStream
        print: self class;
        nextPutAll: ' (';
        nextPutAll: string;
        nextPut: $)! 
source

    ^source!
source: aString

    source := aString! 
title

    | answer |

    answer := source size > 30
        ifTrue: [(source copyFrom: 1 to: 30), '...']
        ifFalse: [source].


    ^'Evaluate: ', answer

! !

! ClassBasedChangeSetItem class methods !
fromClass: aClass

    ^self new
        className: aClass name;
        yourself
! !

! ClassBasedChangeSetItem methods ! 
= aChangeSetItem

    ^super = aChangeSetItem and: [className = aChangeSetItem className]
!
canFileOutSource
    "   ^   true | false
    If my class exists, then answer true; otherwise answer false"

    ^(Smalltalk includesKey: self smalltalkClassName asSymbol)
!
className

    ^className!  
className: aString

    className := aString!   
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream nextPutAll: '                   className: ', className printString, ';'    ;cr
!   
fileOutErrorOn: aStream with: aCodeFilerClass
    "If my class exists, then procede normally; if not, then file out a comment to that effect"

    aStream nextChunkPut: '"', self annotationLabel, ' with no source code"'
! 
fileOutSourceOn: aStream with: aCodeFilerClass
    "If I can file out my source code, then do so; otherwise file out an error comment"

    self canFileOutSource
        ifTrue: [self fileOutValidSourceOn: aStream with: aCodeFilerClass]
        ifFalse: [self fileOutErrorOn: aStream with: aCodeFilerClass]

!  
hash

    ^className hash!  
includesCategory: aString

    ^(CodeFiler systemOrganizer categoriesOfElement: self className asSymbol) includes: aString
!   
isClassBased

    ^true
!  
printOn: aStream

    aStream
        print: self class;
        nextPutAll: ' (';
        nextPutAll: className;
        nextPut: $)!  
smalltalkClass

    ^Smalltalk at: className firstWord asSymbol!
smalltalkClassName

    ^className firstWord!   
smalltalkClassOrMeta

    | meta smalltalkClass |
    meta := (className asLowerCase indexOfCollection: ' class') ~= 0.
    smalltalkClass := Smalltalk at: className firstWord asSymbol.

    ^meta
        ifTrue: [smalltalkClass class]
        ifFalse: [smalltalkClass]!
smalltalkClassOrMetaName

    ^self className! !

! ChangeSetClassCommentItem methods !   
fileOutValidSourceOn: aStream with: aCodeFilerClass

    (aCodeFilerClass forClass: self smalltalkClassOrMeta)
        fileOutCommentOn: aStream
! !

! ChangeSetClassDefinitionItem methods !  
fileOutValidSourceOn: aStream with: aCodeFilerClass

    (aCodeFilerClass forClass: self smalltalkClassOrMeta) fileOutDefinitionOn: aStream
!  
isClassDefinitionItem
    ^true
!   
title

    ^'Define Class ', className
! !

! ChangeSetClassReorganizationItem methods ! 
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream
        nextPutAll: '                   newCategories: #';
        nextPutAll: self newCategories asArray printString;
        nextPutAll: ';' ;
        cr

! 
fileOutValidSourceOn: aStream with: aCodeFilerClass
    "File out source to reorganize my class into newCategories"

    aCodeFilerClass logReorganizeClass: self smalltalkClassName intoCategories: newCategories on: aStream
!  
initialize

    super initialize.
    self newCategories: #()
!   
isClassDefinitionItem
    ^false
!  
newCategories
    ^newCategories
!  
newCategories: aCollection
    newCategories := aCollection
!   
title
    newCategories size = 0
        ifTrue: [^className, ' uncategorized'].

    ^'Move ', className, ' to ', (newCategories size > 1
            ifTrue: [newCategories first, ' ...']
            ifFalse: [newCategories first])
! !

! ChangeSetMethodItem methods !
= aChangeSetItem

    ^super = aChangeSetItem and: [selector = aChangeSetItem selector]!
canFileOutSource
    "   ^   true | false
    Answer true if I have source code for my selector"

    ^super canFileOutSource and: [self smalltalkClassOrMeta includesSelector: selector]
!  
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream
        nextPutAll: '                   protocol: ', self protocol printString, ';'  ;cr;
        nextPutAll: '                   selector: #', self selector printString, ';'  ;cr
! 
fileOutValidSourceOn: aStream with: aCodeFilerClass

    (aCodeFilerClass forClass: self smalltalkClassOrMeta) fileOutMethod: selector on: aStream
!   
hash

    ^selector hash!   
isMethodItem

    ^true!
printOn: aStream

    aStream
        print: self class;
        nextPutAll: ' (';
        nextPutAll: className;
        nextPutAll: '>>';
        nextPutAll: selector;
        nextPut: $)!
protocol

    ^protocol!
protocol: aString

    protocol := aString! 
selector

    ^selector!
selector: aSymbol

    selector := aSymbol! 
title

    ^'Add ', className, '>>', selector
! !

! ChangeSetProtocolItem methods ! 
= aChangeSetItem

   ^super = aChangeSetItem and: [protocol = aChangeSetItem protocol]


!   
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream nextPutAll:'                   protocol: ', self protocol printString, ';' ;cr
!
hash
    ^protocol hash
!   
protocol
    ^protocol
!
protocol: aString
    protocol := aString
! !

! ChangeSetAddProtocolItem methods !   
beforeProtocol
    ^beforeProtocol
!
beforeProtocol: aStringOrNil
    beforeProtocol := aStringOrNil
!   
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream nextPutAll: '                   beforeProtocol: ', self beforeProtocol printString, ';'; cr
!   
fileOutValidSourceOn: aStream with: aCodeFilerClass
    "File out source to add my protocol before my beforeProtocol"

    aCodeFilerClass logAddProtocol: protocol before: beforeProtocol inClass: self smalltalkClassOrMetaName on: aStream
!   
title

    ^'Add ', self smalltalkClassOrMetaName, '>', protocol


! !

! ChangeSetRemoveProtocolItem methods !
fileOutValidSourceOn: aStream with: aCodeFilerClass
    "File out source to remove my protocol"

    aCodeFilerClass logRemoveProtocol: protocol inClass: self smalltalkClassOrMetaName on: aStream
! 
title
    ^'Remove ', self smalltalkClassOrMetaName, '>', self protocol
! !

! ChangeSetRenameProtocolItem methods !  
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream nextPutAll: '                   oldProtocol: ', self oldProtocol printString, ';';cr.
! 
fileOutValidSourceOn: aStream with: aCodeFilerClass
    "File out source to rename my old protocol to my protocol"

    aCodeFilerClass logRenameProtocol: oldProtocol to: protocol inClass: self smalltalkClassOrMetaName on: aStream
!  
oldProtocol
    ^oldProtocol
!  
oldProtocol: aString

    oldProtocol := aString
! 
title
    ^'Rename ', oldProtocol, ' to ', protocol
! !

! ChangeSetRemoveClassItem methods ! 
fileOutValidSourceOn: aStream with: aCodeFilerClass

    aCodeFilerClass logRemoveClass: self className on: aStream
!  
title

    ^'Remove class ', className
! !

! ChangeSetRemoveMethodItem methods !
= aChangeSetItem

    ^super = aChangeSetItem and: [selector = aChangeSetItem selector]!
exportInformationOn: aStream

    super exportInformationOn: aStream.
    aStream nextPutAll: '                   selector: #', self selector printString, ';' ;cr.
! 
fileOutValidSourceOn: aStream with: aCodeFilerClass

    aCodeFilerClass logRemoveSelector: selector inClass: self smalltalkClassOrMetaName on: aStream
!  
hash

    ^selector hash!   
isMethodItem

    ^true!
isRemoveMethod

    ^true!  
printOn: aStream

    aStream
        print: self class;
        nextPutAll: ' (';
        nextPutAll: className;
        nextPutAll: '>>';
        nextPutAll: selector;
        nextPut: $)!
selector

    ^selector!
selector: aSymbol

    selector := aSymbol! 
title

    ^'Remove ', className, '>>', selector
! !

! ChangeSetManager class methods ! 
new

    ^super new initialize! !

! ChangeSetManager methods !   
add: aChangeSet

    ^(changeSets includes: aChangeSet)
        ifTrue: [aChangeSet]
        ifFalse: [changeSets add: aChangeSet]
! 
buildDate

    ^buildDate!  
buildDate: aDate

    buildDate := aDate!   
buildTime

    ^buildTime!  
buildTime: aTime

    buildTime := aTime!   
changeSets

    ^changeSets!
initialize

    self
        buildTime: Time now;
        buildDate: Date today.

    changeSets := OrderedCollection new.
    self add: NonRecordingChangeSet new
!  
nonRecordingChangeSet

    ^self changeSets
        detect: [:first | first isNonRecordingChangeSet]
        ifNone: [self add: NonRecordingChangeSet new]
! 
remove: aChangeSet

    changeSets remove: aChangeSet ifAbsent: []
! !

! CodeBrowserSelection class methods !   
new
    ^super new initialize! !

! CodeBrowserSelection methods ! 
categories
    "Answer my categories selection"

    ^self contents at: #categories!   
categories: categories
    "categories:        <IndexedCollection of <Symbols>>
    Set my categories selection"

    self contents at: #categories put: categories!  
classes
    "Answer my classes selection"

    ^self contents at: #classes!
classes: classes
    "classes:        <IndexedCollection of <Symbols>>
    Set my classes selection"

    self contents at: #classes put: classes!
contents
    "   ^       <Dictionary>
    Private - Answer my selections as a dictionary"

    ^contents! 
contents: aDictionary
    "Private - Set my contents"

    contents := aDictionary!
deepCopy

    ^self species new
        contents: self contents deepCopy!  
initialize
    contents := Dictionary new
        at: #categories put: Array new;
        at: #classes put: Array new;
        at: #protocols put: Array new;
        at: #methods put: Array new;
        yourself!
methods
    "Answer my methods selection"

    ^self contents at: #methods!
methods: methods
    "methods        <IndexedCollection of <Symbols>>
    Set my methods selection"

    self contents at: #methods put: methods! 
protocols
    "Answer my protocols selection"

    ^self contents at: #protocols!  
protocols: protocols
    "protocols        <IndexedCollection of <Symbols>>
    Set my protocols selection"

    self contents at: #protocols put: protocols! !

! CodeFiler class methods !
changeSetManager
    " (CodeFiler changeSetManager) "

    ChangeSetManagerInstance isNil
        ifTrue: [self initializeChangeSetManager].

    ^ChangeSetManagerInstance!
classComments
    "^ <dictionary>
    Answer my dictionary of class comments"

    ClassComments isNil
        ifTrue: [self initializeClassComments].
    ^ClassComments!  
classOrganizers
    "Answer my dictionary of class organizers"

    ClassOrganizers isNil
        ifTrue: [self initializeClassOrganizers].
    ^ClassOrganizers!
codeWriterMenuWith: aBlock
    "aBlock     <OneArugmentBlock value: <CodeFilerClass>>
           ^            <Menu>
    Answer a menu with all of the code filers in the system.
    When an item is chosen, the menu will evaluate aBlock with the code filer class
    that was chosen"

    | theMenu codeWritersByDescription codeWriterClass |

    theMenu := Menu new
        title: 'Code Writer';
        owner: self;
        yourself.

    codeWritersByDescription := Dictionary new.
    CodeFiler withAllSubclasses do: [:each |
        codeWritersByDescription at: each description put: each].

    codeWritersByDescription keys asSortedCollection do: [:description |
        codeWriterClass := codeWritersByDescription at: description.
        theMenu
            appendItem: description
            action: (self privateMenuBlockForCodeWriter: codeWriterClass andBlock: aBlock)].

    ^theMenu


!   
commentFor: nameOfClass
    "nameOfClass: <symbol>
    ^ <string>
    Answer the comment for the named class"

    ^self classComments at: nameOfClass ifAbsent:[String new]!
definitionTemplate

    ^'
SuperClass subclass: #NameOfNewClass
  instanceVariableNames: ''''
  classVariableNames: ''''
  poolDictionaries: ''''
  categories: '
!   
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'CodeFiler'

!  
forClass: aClass
    "aClass:        <Class or Metaclass>
        ^   <CodeFiler on: <Class or Meta>>"

    ^self forClasses: (Array with: aClass)!   
forClasses: classes
    "classes:        <Collection withAll: <Class or Meta>
        ^   <CodeFiler on: classes>"

    ^self new
        classes: classes;
        forClass: classes first!
initializeChangeSetManager
    " (CodeFiler initializeChangeSetManager) "

    ChangeSetManagerInstance := ChangeSetManager new.!  
initializeClassComments
    "(self initializeClassComments)
    Initialize my dictionary of class comments"

    ClassComments := Dictionary new.!
initializeClassOrganizers
    "Initialize my dictionary of class organizers.
    (CodeFiler initializeClassOrganizers)"

    ClassOrganizers := Dictionary new.!  
initializeSystemOrganizer
    "(CodeFiler initializeSystemOrganizer)"

    SystemOrganizer := ClassBasedOrganizer new owner: Smalltalk.
    Smalltalk rootClasses do: [:rootClass |
        rootClass withAllSubclasses do: [:each |
            SystemOrganizer addElement: each name asSymbol toCategory: SystemOrganizer defaultCategory]]!  
logAddProtocol: protocol before: beforeProtocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler organizerFor: ';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') addCategory: ';
        nextPut: $' ;
        nextPutAll: protocol;
        nextPut: $' ;
        nextPutAll: ' before: ';
        nextPut: $' ;
        nextPutAll: beforeProtocol;
        nextPut: $'.

    aStream nextChunkPut: source contents

!
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream"

    aStream nextChunkPut: className, ' removeFromSystem'

!   
logRemoveProtocol: protocol inClass: className on: aStream

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler organizerFor: ';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') removeCategory: ';
        nextPut: $' ;
        nextPutAll: protocol;
        nextPut: $'.

    aStream nextChunkPut: source contents
!  
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className"

    aStream nextChunkPut: className, ' removeSelector: #', selector

!
logRenameProtocol: oldProtocol to: protocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler organizerFor: ';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') rename: ';
        nextPut: $' ;
        nextPutAll: oldProtocol;
        nextPut: $' ;
        nextPutAll: ' to: ';
        nextPut: $' ;
        nextPutAll: protocol;
        nextPut: $'.

    aStream nextChunkPut: source contents

!
logReorganizeClass: className intoCategories: newCategories on: aStream
    "File out source to reorganize my class into newCategories"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler systemOrganizer reorganize: #(';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') into: #('.

    newCategories do: [:each |
        source store: each].

    source nextPutAll: '))'.
    aStream nextChunkPut: source contents
!  
organizerFor: nameOfClassOrMeta
    "   nameOfClassOrMeta:  <Symbol> | <the class or meta itself>
        ^   <methodBasedOrganizer>
    Answer the method based organizer associated with the named class or meta"

    | theName |

    theName := nameOfClassOrMeta isBehavior
        ifTrue: [nameOfClassOrMeta name asSymbol]
        ifFalse: [nameOfClassOrMeta asSymbol].

    ^self classOrganizers
        at: theName
        ifAbsent: [self privateBuildOrganizerFor: theName]!
privateBuildOrganizerFor: nameOfClassOrMetaclass
    "Private - Build an organizer for the named class or metaclass,
    and add it to my dictionary of organizers"

    ^self classOrganizers
        at: nameOfClassOrMetaclass
        put: (MethodBasedOrganizer for:  (Smalltalk at: nameOfClassOrMetaclass
                ifAbsent: [(Smalltalk at: nameOfClassOrMetaclass firstWord asSymbol) class]))!
privateMenuBlockForCodeWriter: codeWriterClass andBlock: aOneArgumentBlock
    "Private - Answer a zero argument block block which will evaluate
    aOneArgumentBlock with codeWriterClass as argument"

    ^[aOneArgumentBlock value: codeWriterClass]
!  
removeOrganizerFor: nameOfClassOrMeta
    "Remove the organizer for nameOfClassOrMeta which has its method categorizations"

    ^self classOrganizers
        removeKey: nameOfClassOrMeta asSymbol
            ifAbsent: [nil]!
setCommentFor: nameOfClass to: newComment
    "nameOfClass: <symbol>
      newComment: <string>
    Set the comment for the named class.  Log this on the change log."

    | changeLog theName |

    theName := nameOfClass isBehavior
        ifTrue: [nameOfClass name asSymbol]
        ifFalse: [nameOfClass asSymbol].

    (changeLog := Sources at: 2) setToEnd.
    self classComments at: theName put: newComment.
    (CodeFiler forClass: (Smalltalk at: theName)) fileOutCommentOn: changeLog.
    changeLog flush.!  
setOrganizerFor: nameOfClassOrMeta to: aMethodBasedOrganizer
    "set  aMethodBasedOrganizer to be the organizer for the class called nameOfClassOrMeta"

    self classOrganizers at: nameOfClassOrMeta asSymbol put: aMethodBasedOrganizer!  
systemOrganizer
    "Answer the system organizer"

    SystemOrganizer isNil
        ifTrue: [self initializeSystemOrganizer].
    ^SystemOrganizer! 
systemOrganizer: aClassBasedOrganizer
    "Set the system organizer to aClassBasedOrganizer"

    SystemOrganizer := aClassBasedOrganizer! !

! CodeFiler methods !  
classes
    "^    <Collection withAll: <Class or Meta>
    Answer my classes"

    ^classes!  
classes: collection
    "collection:    <Collection withAll: <Class or Meta>
    Set my classes"

    classes := collection!  
compilerError: anError at: index in: anObject for: aClass
    "a compiler error has occurred while loading the timestamp information for a version of a method.
    Do nothing"

    ^nil
!  
definitionString
    "   ^   <String>
    Return a string which is the definition of the class I represent."

    | stream categories |

    stream := WriteStream on: (String new: 64).
    categories := CodeFiler systemOrganizer
        categoriesOfElement: self forClass name asSymbol.
    self forClass fileOutOn: stream.
    stream
        cr ;space; space;
        nextPutAll: 'categories: #( '.
    categories do: [:each |
        stream store: each; space].
    stream nextPut: $).
    ^stream contents.!
fileInFrom: stream
    "   stream  <ReadStream>
        ^       self
    Read chunks from aStream until an empty chunk (a single '!!') is found.
    Compile each chunk as a method for the class I describe.
    Log the source code of the method to the change log."

    | chunk result changeLog selectors |

    selectors := OrderedCollection new.

    changeLog := (Sources at: 2)
        setToEnd;cr;
        yourself.

    self fileOutPreambleOn: changeLog.
    [(chunk := stream nextChunk) isEmpty] whileFalse: [
        result := self forClass compile: chunk.
        result notNil ifTrue: [
            result value sourceString: chunk.
            selectors add: result key.]].
    changeLog
        nextPutAll: ' !!';
        flush.!   
fileOutCommentOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes' comment to stream."

    stream
            nextPutAll: 'CodeFiler setCommentFor: ', self forClass name; nextPutAll: ' to: ';
            nextPutAll: (CodeFiler commentFor: self forClass name asSymbol) storeString;
            nextPutAll: '!!';
            cr!
fileOutDefinitionOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes to stream."

    stream nextPutAll: self definitionString; nextPutAll: '!!';cr.!  
fileOutMethod: method on: stream
    "   method  <Symbol>
        stream  <WriteStream>
        ^       self
    Put a textual version of my method to stream."

    ^self fileOutMethods: (Array with: method) on: stream! 
fileOutMethods: methods on: stream
    "   method  <Collection withAll: <Symbol>>
        stream  <WriteStream>
        ^       self
    Put a textual version of my methods to stream."

    | organizer |

    methods isEmpty
        ifTrue: [^self].

    CursorManager execute changeFor: [
        self fileOutPreambleOn: stream.
        methods do: [:each |
            self privateFileOutMethod: each on: stream].
    stream nextPutAll: ' !!';cr.
    self fileOutOrganizationFor: methods on: stream]!
fileOutOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class to stream."

    CursorManager execute changeFor: [
        self classes do: [:aClass |
            self
                forClass: aClass;
                fileOutDefinitionOn: stream.
            stream cr;cr].
        self classes do: [:aClass |
            self
                forClass: aClass class;
                fileOutProtocolsOn: stream.
            self
                forClass: aClass;
                fileOutProtocolsOn: stream;
                fileOutCommentOn: stream]]!   
fileOutOrganizationFor: methods on: stream
    "methods:   <Collection withAll: <Symbol>>
    File out a chunk capable of reorganizing methods in the class I'm for"

    stream
        cr; nextPutAll: '(CodeFiler organizerFor: ', self forClass name;
        nextPutAll: ') reorganizeFrom: #('.
    ((CodeFiler organizerFor: self forClass name) organizationFor: methods) do: [:each |
        stream cr; nextPut: $(.
        each do: [:item |
            item printOn: stream.
            stream space].
        stream nextPut: $) ].

    stream nextPutAll: ') !!';cr

!  
fileOutPreambleOn: aStream
    "File out the preamble which, when filed in, will create
    a codeFiler to accept the next chunks"

     aStream
        cr; nextPutAll: '!!CodeFiler forClass: '.
    self forClass name asSymbol printOn: aStream.
    aStream nextPutAll: ' !!'!
fileOutProtocol: protocol on: stream
    "   protocol    <String>
        stream      <WriteStream>
        ^           self
    Put a textual version of my classes protocol to stream."

    self fileOutMethods: (self methodOrganizer elementsOfCategory: protocol) on: stream.!
fileOutProtocolsOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes protocols to stream."

    self fileOutMethods: self forClass selectors on: stream!
forClass
    "   ^   <Class | Meta>
    Answer the class I am for"

    ^forClass!
forClass: classOrMeta
    "   classOrMeta   <Class | Meta>
    Set the class I am for"

    forClass := classOrMeta!  
keywordSelectorFrom: aString
    "Read a keyword selector from aString"

    | aStream selector identifier done |

    aStream := ReadStream on: aString.
    selector := WriteStream on: String new.
    done := false.

    [done] whileFalse: [
        identifier := self nextIdentifierFrom: aStream.
        (identifier notEmpty and: [identifier last = $:])
            ifTrue: [
                selector nextPutAll: identifier.
                identifier := self nextIdentifierFrom: aStream]
            ifFalse: [done := true]].

    ^selector contents asSymbol

!  
loadedVersionOf: selector
    "   ^   <MethodVersion>
    Answer the version of the method named selector loaded in the image"

    | method changeLog |

    method := self forClass compiledMethodAt: selector.
    changeLog := Sources at: 2.
    method sourceIndex = 2
        ifTrue: [^self versionOf: selector at: method sourcePosition in: changeLog].

    ^MethodVersion
        smalltalkClass: self forClass
        selector: selector
        source: method sourceString
        timeStamp: TimeStamp current









































































































!   
logSource: source forSelector: selector
    "   source      <String>
        selector    <Symbol>
    Log source as the source code for selector for class."

    self logSource: source forSelector: selector withPreviousSourcePosition: nil
!
logSource: source forSelector: selector withPreviousSourcePosition: previousSourcePosition
    "source      <String>
     selector    <Symbol>
     previousSourcePosition  <Integer> | nil
    Log source as the source code for selector for class."

    | changeLog stamp |

    (changeLog := Sources at: 2)
        setToEnd;
    yourself.
    self fileOutPreambleOn: changeLog.

    (self forClass compiledMethodAt: selector) sourceString: source.
    stamp := WriteStream on: (String new: 50).
    stamp
        nextPutAll: '#(';
        print: Date today printString; space;
        print: Time now printString; space;
        print: previousSourcePosition;
        nextPutAll: ')'.

    changeLog
        setToEnd;
        nextChunkPut: stamp contents;
        cr.
    self fileOutOrganizationFor: (Array with: selector) on: changeLog.
    changeLog flush.
!  
methodOrganizer
    "^ <MethodBasedOrganizer>
    Answer the method organizer for my smalltalkClass"

    ^(CodeFiler organizerFor: self forClass name)!  
nextIdentifierFrom: aStream
    "Private - Answer the next identifer from aStream."

    | done identifier character |

    done := false.
    [aStream atEnd not and: [done not]] whileTrue: [
        character := aStream peek.
        character isWhitespace
            ifTrue: [aStream next]
            ifFalse: [done := true]].

    identifier := WriteStream on: (String new: 50).
    done := false.

    [aStream atEnd not and: [done not]] whileTrue: [
        character := aStream peek.
        character isSymbolCharacter
            ifTrue: [
                identifier nextPut: character.
                aStream next]
            ifFalse: [done := true]].

    ^identifier contents
!  
privateFileOutMethod: method on: stream
    "   stream  <WriteStream>
        method  <Symbol: selector>
        ^       self
    Put a textual version of method to stream."

    stream
        cr;
        nextChunkPut: (self forClass sourceCodeAt: method)! 
selectorFor: aString
    "   ^   <Symbol>
    Assuming aString is the source for a method, answer the selector for it"

    | aStream selector |

    aStream := ReadStream on: aString.
    selector := self nextIdentifierFrom: aStream.
    (selector notEmpty and: [selector last = $:])
        ifTrue: [^self keywordSelectorFrom: aString].

    ^selector asSymbol.

!   
versionOf: selector at: sourcePosition in: aStream
    "Private - Load the version of the method named selector located at sourcePosition in the change log.
    No checking is done to ensure that this is indeed correct information"

    | sourceString version stampChunk stamp stream previousVersionLocation |

    aStream position: sourcePosition.
    sourceString := aStream nextChunk.

    stampChunk := aStream nextChunk; nextChunk.
    (stampChunk isEmpty or: [(stampChunk first = $# and: [(stampChunk at: 2) = $(]) not]) ifTrue: [
        stamp := (aStream isKindOf: FileStream)
            ifTrue: [aStream file creationTime]
            ifFalse: [TimeStamp current "for lack of anything better"].

        ^MethodVersion
            smalltalkClass: self forClass
            selector: selector
            source: sourceString
            timeStamp: stamp].

    "We're now reasonable sure that the chunk represents a timeStamp and previous version pointer.
    Ask the compiler to turn it into an array for us. It will be #('Date' 'Time' previousSourcePositionOrTheSymbolNil) "
    stamp := CompilerInterface evaluate: stampChunk in: UndefinedObject to: nil notifying: self ifFail: [nil].
    stamp isNil
        ifTrue: [
           stamp := (aStream isKindOf: FileStream)
                ifTrue: [aStream file creationTime]
                ifFalse: [TimeStamp current "for lack of anything better"]]
        ifFalse: [
            previousVersionLocation := (stamp last isKindOf: Integer)
                ifTrue: [stamp last]
                ifFalse: [nil].
            stamp := TimeStamp date: stamp first asDate time: (stamp at: 2) asTime].

    version := MethodVersion
            smalltalkClass: self forClass
            selector: selector
            source: sourceString
            timeStamp: stamp.
    version previousVersion: previousVersionLocation sourceStream: aStream.
    ^version
! !

! CodeWriter class methods !
codeWriterMenuWith: aBlock
    "aBlock     <OneArugmentBlock value: <CodeWriterClass>>
           ^            <Menu>
    Answer a menu with all of the code filers in the system.
    When an item is chosen, the menu will evaluate aBlock with the code filer class
    that was chosen"

    | theMenu validCodeWriters codeWritersByDescription codeWriterClass |

    theMenu := Menu new
        title: 'Code Writer';
        owner: self;
        yourself.

    validCodeWriters := CodeWriter allSubclasses select: [:each |
        each class methodDictionary includesKey: #description].

    codeWritersByDescription := Dictionary new.
    validCodeWriters do: [:each |
        codeWritersByDescription at: each description put: each].

    codeWritersByDescription keys asSortedCollection do: [:description |
        codeWriterClass := codeWritersByDescription at: description.
        theMenu
            appendItem: description
            action: (self privateMenuBlockForCodeWriter: codeWriterClass andBlock: aBlock)].

    ^theMenu


!  
definitionTemplate

    ^'SuperClass subclass: #NameOfNewClass
  instanceVariableNames: ''''
  classVariableNames: ''''
  poolDictionaries: ''''
  categories: '
! 
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    self subclassResponsibility

!   
forClass: aClass
    "aClass:        <Class or Metaclass>
        ^   <CodeWriter on: <Class or Meta>>"

    ^self forClasses: (Array with: aClass)!  
forClasses: classes
    "classes:        <Collection withAll: <Class or Meta>
        ^   <CodeWriter on: classes>"

    ^self new
        classes: classes;
        forClass: classes first!   
logAddProtocol: protocol before: beforeProtocol inClass: className on: aStream
    "Log source code on aStream to add protocol
    Do nothing by default"

!  
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream
    Do nothing by default"
!  
logRemoveProtocol: protocol inClass: className on: aStream
    "Log the removal of protocol in the class named className on aStream.
    Do nothing by default"
!  
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className.
    Do nothing by default"
! 
logRenameProtocol: oldProtocol to: protocol inClass: className on: aStream
    "Log source code on aStream to rename oldProtocol to protocol
    Do nothing by default"
!  
logReorganizeClass: className intoCategories: newCategories on: aStream
    "File out source to reorganize my class into newCategories.
    Do nothing by default"
!   
privateMenuBlockForCodeWriter: codeWriterClass andBlock: aOneArgumentBlock
    "Private - Answer a zero argument block block which will evaluate
    aOneArgumentBlock with codeWriterClass as argument"

    ^[:owner | aOneArgumentBlock value: codeWriterClass]
! !

! CodeWriter methods ! 
classes
    "^    <Collection withAll: <Class or Meta>
    Answer my classes"

    ^classes!  
classes: collection
    "collection:    <Collection withAll: <Class or Meta>
    Set my classes"

    classes := collection!  
definitionString
    "   ^   <String>
    Return a string which is the definition of the class I represent
    in an appropriate format."

    self subclassResponsibility

!  
fileOutCommentOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes' comment to stream.
    Do nothing by default"
! 
fileOutDefinitionOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes to stream."

    stream nextPutAll: self definitionString; nextPutAll: '!!';cr.
!
fileOutDefinitionsOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class definitions"

    self classes do: [:aClass |
        self
            forClass: aClass;
            fileOutDefinitionOn: stream]
!
fileOutEpilogueOn: aStream
    "File out any information on aStream which must be filed in after everything else"

!   
fileOutMethod: method on: stream
    "   method  <Symbol>
        stream  <WriteStream>
        ^       self
    Put a textual version of my method to stream."

    ^self fileOutMethods: (Array with: method) on: stream! 
fileOutMethods: methods on: stream
    "   method  <Collection withAll: <Symbol>>
        stream  <WriteStream>
        ^       self
    Put a textual version of my methods to stream."

    | protocols protocol methodsInProtocol |

    methods isEmpty
        ifTrue: [^self].

    protocols := Dictionary new.
    methods asSortedCollection do: [:method |
        protocol := self methodOrganizer categoryOfElement: method.
        (protocols at: protocol ifAbsent: [protocols at: protocol put: OrderedCollection new])
            add: method].

    protocols keys asSortedCollection do: [:eachProtocol |
        methodsInProtocol := protocols at: eachProtocol.
        self fileOutMethodsPrologueFor: methodsInProtocol on: stream.
        methodsInProtocol asSortedCollection do: [:method |
            self privateFileOutMethod: method on: stream].
        self fileOutMethodsEpilogueFor: methodsInProtocol on: stream].
!   
fileOutMethodsEpilogueFor: methods on: aStream
    "File out any code which succeeds filing out methods"


!  
fileOutMethodsPrologueFor: methods on: aStream
    "File out any code which preceeds filing out methods"
!  
fileOutOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class to stream."

    CursorManager execute changeFor: [
        self fileOutDefinitionsOn: stream.
        self classes do: [:aClass |
            self
                forClass: aClass class;
                fileOutPrologueOn: stream;
                fileOutProtocolsOn: stream;
                fileOutEpilogueOn: stream;

                forClass: aClass;
                fileOutPrologueOn: stream;
                fileOutProtocolsOn: stream;
                fileOutEpilogueOn: stream;

                fileOutCommentOn: stream]]
!   
fileOutPrologueOn: aStream
    "File out any information on aStream which must be filed in before anything else"

!
fileOutProtocol: protocol on: stream
    "   protocol    <String>
        stream      <WriteStream>
        ^           self
    Put a textual version of my classes protocol to stream."

    self fileOutProtocolPrologueFor: protocol on: stream.
    (self methodOrganizer elementsOfCategory: protocol) do: [:method |
        self privateFileOutMethod: method on: stream].
    self fileOutProtocolEpilogueFor: protocol on: stream.
!  
fileOutProtocolEpilogueFor: protocol on: aStream
    "File out any code which succeeds filing out a protocol"
! 
fileOutProtocolPrologueFor: protocol on: aStream
    "File out any code which precedes filing out a protocol"
! 
fileOutProtocolsOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes protocols to stream."

    stream cr.
    self methodOrganizer categories do: [:protocol |
        self fileOutProtocol: protocol on: stream]

!   
forClass
    "   ^   <Class | Meta>
    Answer the class I am for"

    ^forClass!
forClass: classOrMeta
    "   classOrMeta   <Class | Meta>
    Set the class I am for"

    forClass := classOrMeta!  
methodOrganizer
    "^ <MethodBasedOrganizer>
    Answer the method organizer for my smalltalkClass"

    ^(CodeFiler organizerFor: self forClass name)
!
privateFileOutMethod: method on: stream
    "Private - File out the source for method on stream"

    stream cr; nextChunkPut: (self forClass sourceCodeAt: method)

!   
privateFileOutMethod: method replacingSpacesWithTabsOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of method to stream. Replace every occurence of 4 spaces with a tab"

    | source outSource count |
    source := ReadStream on: (self forClass sourceCodeAt: method).
    outSource := WriteStream on: (String new: source size).
    [source atEnd] whileFalse: [
        count := 0.
        [source peek = Space] whileTrue: [
            count := count + 1.
            source next].
        outSource tab: (count // 4).
        (count \\ 4) timesRepeat: [outSource space].
        outSource
            nextPutAll: source nextLine;
            cr].

    stream
        cr;
        nextChunkPut: outSource contents
! !

! CodeFilerClassWriter class methods !  
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'Code Filer'

! 
logAddProtocol: protocol before: beforeProtocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler organizerFor: ';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') addCategory: ';
        nextPut: $' ;
        nextPutAll: protocol;
        nextPut: $' ;
        nextPutAll: ' before: ';
        nextPut: $' ;
        nextPutAll: beforeProtocol;
        nextPut: $'.

    aStream nextChunkPut: source contents

!
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream"

    aStream nextChunkPut: className, ' removeFromSystem'

!   
logRemoveProtocol: protocol inClass: className on: aStream

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler organizerFor: ';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') removeCategory: ';
        nextPut: $' ;
        nextPutAll: protocol;
        nextPut: $'.

    aStream nextChunkPut: source contents
!  
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className"

    aStream nextChunkPut: className, ' removeSelector: #', selector

!
logRenameProtocol: oldProtocol to: protocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler organizerFor: ';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') rename: ';
        nextPut: $' ;
        nextPutAll: oldProtocol;
        nextPut: $' ;
        nextPutAll: ' to: ';
        nextPut: $' ;
        nextPutAll: protocol;
        nextPut: $'.

    aStream nextChunkPut: source contents

!
logReorganizeClass: className intoCategories: newCategories on: aStream
    "File out source to reorganize my class into newCategories"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: '(CodeFiler systemOrganizer reorganize: #(';
        nextPut: $' ;
        nextPutAll: className;
        nextPut: $' ;
        nextPutAll: ') into: #('.

    newCategories do: [:each |
        source store: each].

    source nextPutAll: '))'.
    aStream nextChunkPut: source contents
! !

! CodeFilerClassWriter methods !
definitionString
    "   ^   <String>
    Return a string which is the definition of the class I represent."

    | stream categories |

    stream := WriteStream on: (String new: 64).
    categories := CodeFiler systemOrganizer categoriesOfElement: self forClass name asSymbol.
    self forClass fileOutOn: stream.
    stream
        cr ;space; space;
        nextPutAll: 'categories: #( '.
    categories do: [:each |
        stream store: each; space].
    stream nextPut: $); cr; cr.
    ^stream contents.
!   
fileOutCodeReaderCreatorOn: aStream
    "File out a chunk which, when filed in, will create
    a class reader to accept the next chunks"

     aStream
        cr; nextPutAll: '!!CodeFiler forClass: '.
    self forClass name asSymbol printOn: aStream.
    aStream nextPutAll: ' !!'
!   
fileOutCommentOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes' comment to stream."

    stream
            nextPutAll: 'CodeFiler setCommentFor: ', self forClass name; nextPutAll: ' to: ';
            nextPutAll: (CodeFiler commentFor: self forClass name asSymbol) storeString;
            nextPutAll: '!!';
            cr
!  
fileOutMethodsEpilogueFor: methods on: aStream
    "File out any code which succeeds filing out methods"

    aStream nextPutAll: ' !!';cr.
    self fileOutOrganizationFor: methods on: aStream
!   
fileOutMethodsPrologueFor: methods on: aStream
    "File out any code which preceeds filing out methods"

    self fileOutCodeReaderCreatorOn: aStream
!  
fileOutOrganizationFor: methods on: stream
    "methods:   <Collection withAll: <Symbol>>
    File out a chunk capable of reorganizing methods in the class I'm for"

    stream
        cr; nextPutAll: '(CodeFiler organizerFor: ', self forClass name;
        nextPutAll: ') reorganizeFrom: #('.
    ((CodeFiler organizerFor: self forClass name) organizationFor: methods) do: [:each |
        stream cr; nextPut: $(.
        each do: [:item |
            item printOn: stream.
            stream space].
        stream nextPut: $) ].

    stream nextPutAll: ') !!';cr

!  
fileOutProtocolEpilogueFor: protocol on: aStream
    "File out the organization of protocol on aStream"

    aStream nextPutAll: ' !!';cr.
    self fileOutOrganizationFor: (self methodOrganizer elementsOfCategory: protocol) on: aStream
!
fileOutProtocolPrologueFor: protocol on: aStream
    "File out the preamble which, when filed in, will create
    a CodeFilerClassWriter to accept the next chunks"

    self fileOutCodeReaderCreatorOn: aStream
! !

! CodeFilerOrganizationWriter class methods !   
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'Code Filer Organization'

!
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream.
    Do nothing because this code writer only files out organization changes"

! 
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className.
    Do nothing because this code writer only writes organization changes"
! !

! CodeFilerOrganizationWriter methods ! 
fileOutCommentOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes' comment to stream."

!  
fileOutDefinitionOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my definition organization to stream."

    | className |

    className := self forClass name asSymbol.

    stream
        nextPutAll: 'CodeFiler systemOrganizer reorganize: #(' , className, ') into: #';
        nextPutAll: (CodeFiler systemOrganizer categoriesOfElement: className) asArray printString;
        nextPutAll: ' !!';cr
! 
fileOutMethodsEpilogueFor: methods on: aStream
    "File out any code which succeeds filing out methods"

    self fileOutOrganizationFor: methods on: aStream

!
fileOutMethodsPrologueFor: methods on: aStream
    "File out any code which preceeds filing out methods"

!
fileOutProtocol: protocol on: stream
    "   protocol    <String>
        stream      <WriteStream>
        ^           self
    Put a textual version of my classes protocol to stream."

    self fileOutProtocolEpilogueFor: protocol on: stream.
! 
fileOutProtocolEpilogueFor: protocol on: aStream
    "File out the organization of protocol on aStream"

    self fileOutOrganizationFor: (self methodOrganizer elementsOfCategory: protocol) on: aStream

! 
privateFileOutMethod: method on: stream
    "Private - File out the source for method on stream.
    Do nothing since the method source is not part of the organization"
! !

! DigitalkClassWriter class methods !  
description

    ^'Digitalk'
! 
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream"

    aStream nextChunkPut: className, ' removeFromSystem'

!   
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className"

    aStream nextChunkPut: className, ' removeSelector: #', selector

! !

! DigitalkClassWriter methods !   
definitionString
    "   ^   <String>
    Return a string which is the definition of the class I represent."

    | stream categories |

    stream := WriteStream on: (String new: 64).
    categories := CodeFiler systemOrganizer categoriesOfElement: self forClass name asSymbol.
    self forClass fileOutOn: stream.
    ^stream contents
!  
fileOutDefinitionOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class to stream."

    self forClass fileOutOn: stream.
    stream nextPut: $!!; cr.
!  
fileOutMethodsEpilogueFor: methods on: stream
    "File out any code which succeeds filing out methods"

    stream nextPutAll: ' !!'; cr
!   
fileOutMethodsPrologueFor: methods on: stream
    "File out any code which preceeds filing out methods"

    stream
        cr;
        nextPut: $!!;
        nextPutAll: self forClass name;
        nextPutAll: ' methods ';
        nextPut: $!!

!  
fileOutProtocolEpilogueFor: protocol on: stream
    "File out any code which succeeds filing out a protocol"

    stream nextPutAll: ' !!'; cr
!  
fileOutProtocolPrologueFor: protocol on: stream
    "File out any code which succeeds filing out a protocol"

    stream
        cr;
        nextPut: $!!;
        nextPutAll: self forClass name;
        nextPutAll: ' methods "for ';
        nextPutAll: protocol storeString;
        nextPutAll: '" ';
        nextPut: $!!

! !

! IBMSmalltalkClassWriter class methods !   
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'IBM Smalltalk'

!  
logAddProtocol: protocol before: beforeProtocol inClass: className on: aStream
    "Log source code on aStream to add protocol"


!   
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream"

    aStream nextChunkPut: className, ' removeFromSystem'

!   
logRemoveProtocol: protocol inClass: className on: aStream


! 
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className"

    aStream nextChunkPut: className, ' removeSelector: #', selector

!
logRenameProtocol: oldProtocol to: protocol inClass: className on: aStream
    "Log source code on aStream to add protocol"


!   
logReorganizeClass: className intoCategories: newCategories on: aStream
    "File out source to reorganize my class into newCategories"


! !

! IBMSmalltalkClassWriter methods !  
definitionString
    "   ^   <String>
    Return a string which is the definition of the class I represent."

    | stream |
    stream := WriteStream on: (String new: 64).
    self forClass fileOutOn: stream.
    ^stream contents.!   
fileOutCodeReaderCreatorOn: aStream
    "File out a chunk which, when filed in, will create
    a class reader to accept the next chunks"

     aStream cr; nextPut: $!!.
    self forClass name asSymbol printOn: aStream.
    aStream nextPutAll: ' publicMethods !!'
!  
fileOutCommentOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my classes' comment to stream."

    ^self! 
fileOutMethodsEpilogueFor: methods on: aStream
    "File out the prologue to methods on aStream"

    aStream nextPutAll: ' !!'; cr.
    self fileOutOrganizationFor: methods on: aStream
!  
fileOutMethodsPrologueFor: methods on: aStream
    "File out the prologue to methods on aStream"

    self fileOutCodeReaderCreatorOn: aStream
!  
fileOutOrganizationFor: methods on: stream
    "methods:   <Collection withAll: <Symbol>>
    File out a chunk capable of reorganizing methods in the class I'm for"

    | organizer |
    organizer := CodeFiler organizerFor: self forClass name.
    methods do: [:eachMethod |
        stream
            cr;
            nextPutAll: self forClass name;
            nextPutAll: ' categoriesFor: #';
            nextPutAll: eachMethod;
            nextPutAll: ' are: #(';
            print: (organizer categoryOfElement: eachMethod);
            nextPutAll: ') !!'].

    stream cr!
fileOutProtocolEpilogueFor: protocol on: aStream
    "File out the organization of the methods in protocol"

    aStream nextPutAll: ' !!';cr.
    self fileOutOrganizationFor: (self methodOrganizer elementsOfCategory: protocol) on: aStream
!
fileOutProtocolPrologueFor: protocol on: aStream
    "File out the prologue which, when filed in, will create
    a codeFiler to accept the next chunks"

    self fileOutCodeReaderCreatorOn: aStream
! 
privateFileOutMethod: method on: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of method to stream."

    self privateFileOutMethod: method replacingSpacesWithTabsOn: stream
! !

! RTFClassWriter class methods ! 
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'Rich Text Format'
! !

! RTFClassWriter methods ! 
classDefinitionBlanks

    | blanks categories |

    blanks := OrderedCollection new
        add: forClass superclass printString;
        add: forClass kindOfSubclass;
        add: forClass name asSymbol;
        yourself.

    forClass isBits
        ifFalse: [blanks add: forClass instanceVariableString trimBlanks storeString].

    blanks
        add: forClass classVariableString trimBlanks storeString;
        add: forClass sharedVariableString trimBlanks storeString.

    categories := CodeFiler systemOrganizer categoriesOfElement: forClass name asSymbol.
    blanks add: (categories inject: (WriteStream on: String new) into: [:sum :each |
        sum
            store: each;
            space;
            yourself]) contents trimBlanks.

    blanks add: ''.

    ^blanks
!   
classDefinitionTemplate

    ^#(

        '\f3\fs20\lang1033 '

        '
\par \pard\plain \s3\fi-360\li720 \f3\fs20\lang1033 '

        ' #{\b '

        '}
\par instanceVariableNames: '

        '
\par classVariableNames: '

        '
\par poolDictionaries: '

        '
\par categories: #('

        ' )
')!
fileOutDefinitionOn: aStream
    "File out my class definition on aStream"

    aStream
        nextPutAll: '\par '; cr;
        nextPutAll: '\par '; cr.

    self classDefinitionTemplate with: self classDefinitionBlanks do: [:template :blank |
        aStream
            nextPutAll: template;
            nextPutAll: blank]
!
fileOutEpilogueOn: aStream
    "File out my RTF footer"

    aStream nextPutAll: self footerTemplate.
!   
fileOutNonKeywordSelectorFrom: sourceStream on: stream

    | sourcePosition |
    sourceStream skipSeparators.
    stream
        cr;
        nextPutAll: '\par {\b ';
        nextPutAll: sourceStream nextWord;
        nextPutAll: '}'.
    sourceStream next.
!
fileOutOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class to stream."

    CursorManager execute changeFor: [
        self fileOutPrologueOn: stream.
        self classes do: [:aClass |
             self
                forClass: aClass;
                fileOutDefinitionOn: stream;
                forClass: aClass class;
                fileOutProtocolsOn: stream;
                forClass: aClass;
                fileOutProtocolsOn: stream].
        self fileOutEpilogueOn: stream]
!  
fileOutPrologueOn: aStream
    "File out my RTF header"

    aStream nextPutAll: self headerTemplate.
!   
fileOutProtocol: protocol on: stream
    "   protocol    <String>
        stream      <WriteStream>
        ^           self
    Put a textual version of my classes protocol to stream."

    self fileOutProtocolPrologueFor: protocol on: stream.
    (self methodOrganizer elementsOfCategory: protocol) do: [:method |
        self privateFileOutMethod: method on: stream].
    self fileOutProtocolEpilogueFor: protocol on: stream.
!  
fileOutProtocolPrologueFor: protocol on: aStream

    self protocolTemplate with: (self protocolBlanksFor: protocol) do: [:template :blank |
        aStream
            nextPutAll: template;
            nextPutAll: blank]
! 
footerTemplate

    ^'\par }'!  
headerTemplate

    ^'{\rtf1\ansi \deff0\deflang1024{\fonttbl{\f0\froman Times New Roman;}{\f1\froman Symbol;}{\f2\fswiss Arial;}{\f3\fswiss Helvetica;}}{\colortbl;\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;
\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;\red0\green0\blue127;\red0\green127\blue127;\red0\green127\blue0;\red127\green0\blue127;\red127\green0\blue0;\red127\green127\blue0;
\red127\green127\blue127;\red192\green192\blue192;}{\stylesheet{\fs20\lang1033 \snext0 Normal;}{\s2 \f3\fs18\lang1033 \sbasedon0\snext2 Code;}{\s3\fi-360\li720 \f3\fs20\lang1033 \sbasedon2\snext3 Code-Class Definition;}{\s4 \f3\fs20\lang1033
\sbasedon2\snext4 Code-Superclass;}{\s5 \i\f3\fs20\lang1033 \sbasedon2\snext5 Code-Protocol;}{\s6 \f3\fs18\lang1033 \sbasedon2\snext6 Code-Text;}}{\info{\author Jon Hylands}{\operator Jon Hylands}{\creatim\yr1994\mo1\dy5\hr21\min50}
{\revtim\yr1994\mo1\dy5\hr22\min5}{\version2}{\edmins16}{\nofpages0}{\nofwords0}{\nofchars0}{\vern16417}}\paperw12240\paperh15840\margl1800\margr1800\margt1440\margb1440\gutter0 \deftab180\widowctrl\ftnbj \sectd \linex0\endnhere \pard\plain \s4
'!   
keywordsFrom: selector

    | stream keywords |
    keywords := OrderedCollection new.
    stream := ReadStream on: selector.
    [stream atEnd] whileFalse: [
        keywords add: (stream upTo: $:)].

    ^keywords!  
privateFileOutMethod: method on: stream
    "Private - File out the source for method on stream"

    | sourceStream |

    sourceStream := ReadStream on: (forClass sourceCodeAt: method).
    self
        privateFileOutMethodSelectorFrom: sourceStream on: stream selector: method;
        privateFileOutString: (sourceStream copyFrom: sourceStream position to: sourceStream size) on: stream.

    stream
        cr;
        nextPutAll: '\par '
!
privateFileOutMethodSelectorFrom: sourceStream on: stream selector: selector

    | keywords sourcePosition |
    (selector includes: $:)
        ifFalse: [^self fileOutNonKeywordSelectorFrom: sourceStream on: stream].

    keywords := self keywordsFrom: selector.
    sourceStream skipSeparators.
    stream
        cr;
        nextPutAll: '\par '.
    keywords do: [:each |
        sourceStream upTo: $:.

        stream
            nextPutAll: '{\b ';
            nextPutAll: each;
            nextPutAll: '}: ';
            nextPutAll: sourceStream nextWord;
            space.

        sourcePosition := sourceStream position + 1.
        sourceStream skipSeparators.
        self
            privateFileOutString: (sourceStream copyFrom: sourcePosition to: sourceStream position)
            on: stream].
!
privateFileOutString: string on: stream

    | line tabs sourceStream |
    sourceStream := ReadStream on: string.
    [sourceStream atEnd] whileFalse: [
        line := sourceStream nextLine.
        tabs := self tabsForLine: line.
        stream
            nextPutAll: tabs;
            nextPutAll: line trimBlanks.
        sourceStream atEnd ifFalse: [
            stream
                cr; nextPutAll: '\par ']]
!  
protocolBlanksFor: protocol

    ^Array
        with: forClass name, ' methods for ', (' {\b ', protocol, '}') storeString
        with: ''
!
protocolTemplate

    ^#(

        '\par
\par \pard\plain \s5 \i\f3\fs20\lang1033 '

        '
\par \pard\plain \s6 \f3\fs18\lang1033
')!
tabsForLine: aString

    | tabs tabSize stream |
    stream := ReadStream on: aString.
    stream skipSeparators.
    tabSize := (stream copyFrom: 1 to: stream position) size.

    tabs := WriteStream on: (String new: tabSize * 5 // 4).
    tabSize // 4 timesRepeat: [tabs nextPutAll: '\tab '].

    ^tabs contents! !

! VisualWorksClassWriter class methods !  
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'VisualWorks'
!  
logAddProtocol: protocol before: beforeProtocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: className;
        nextPutAll: ' organization addCategory: ';
        nextPut: $# ;
        print: protocol;
        space;
        nextPutAll: ' before: '.

    beforeProtocol isNil
        ifTrue: [source nextPutAll: 'nil']
        ifFalse: [source nextPut: $#; print: beforeProtocol].

    aStream nextChunkPut: source contents

!   
logRemoveClass: className on: aStream
    "className      <Symbol>
    Log source code to remove the named class from the system on aStream"

    aStream nextChunkPut: className, ' removeFromSystem'

!   
logRemoveProtocol: protocol inClass: className on: aStream

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: className;
        nextPutAll: ' organization removeCategory: #';
        nextPutAll: protocol.

    aStream nextChunkPut: source contents

!
logRemoveSelector: selector inClass: className on: aStream
    "Log source code on aStream to remove selector from className"

    aStream nextChunkPut: className, ' removeSelector: #', selector

!
logRenameProtocol: oldProtocol to: protocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

    | source |

    source := WriteStream on: (String new: 80).

    source
        nextPutAll: className;
        nextPutAll: ' organization rename: #';
        nextPutAll: oldProtocol;
        nextPutAll: ' to: #';
        nextPutAll: protocol.

    aStream nextChunkPut: source contents

! 
logReorganizeClass: className intoCategories: newCategories on: aStream
    "File out source to reorganize my class into newCategories"


! !

! VisualWorksClassWriter methods !   
definitionString
    "   ^   <String>
    Return a string which is the definition of the class I represent."

    | stream categories |

    stream := WriteStream on: (String new: 64).
    categories := CodeFiler systemOrganizer categoriesOfElement: self forClass name asSymbol.
    self forClass fileOutOn: stream.
    stream
        cr ;space; space;
        nextPutAll: 'category: ';
        nextPutAll: categories first printString;
        cr.
    ^stream contents
!
fileOutCommentOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class comment to stream."

    stream nextPutAll: self forClass name; nextPutAll: ' comment: ';
        nextPutAll: (CodeFiler commentFor: self forClass name asSymbol) storeString;
        nextPut: $!!;
        cr
!  
fileOutInitializeOn: stream
    "   stream  <WriteStream>
        ^       self
    If the class I am filing out has an initialize method, then put
    a do it on stream that will evaluate it.
    Otherwise do nothing."

    (self forClass includesSelector: #initialize) ifTrue: [
        stream cr; nextPutAll: self forClass symbol; nextPutAll: ' initialize!!']
!  
fileOutMethodsEpilogueFor: methods on: aStream
    "File out the epilogue for methods on aStream"

    aStream nextPutAll: ' !!'; cr.
!   
fileOutMethodsPrologueFor: methods on: aStream
    "File out the header for methods on aStream"

    | protocol |

    protocol := self methodOrganizer categoryOfElement: methods any.

    aStream
        cr;
        nextPut: $!! ;
        nextPutAll: self forClass name ;
        nextPutAll: ' methodsFor: ' ;
        nextPutAll: protocol storeString ;
        nextPut: $!!
!
fileOutOn: aStream
    "File out all of my classes on aStream"

    super fileOutOn: aStream.
    self classes do: [:aClass |
        self
            forClass: aClass class;
            fileOutInitializeOn: aStream]

!  
fileOutProtocolEpilogueFor: protocol on: stream

    stream nextPutAll: ' !!'; cr
!
fileOutProtocolPrologueFor: protocol on: stream

    stream
        cr;
        nextPut: $!! ;
        nextPutAll: self forClass name ;
        nextPutAll: ' methodsFor: ' ;
        nextPutAll: protocol storeString ;
        nextPut: $!!
! !

! TabbedVisualWorksClassWriter class methods !  
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'VisualWorks-Tabbed'
! !

! TabbedVisualWorksClassWriter methods ! 
privateFileOutMethod: method on: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of method to stream."

    self privateFileOutMethod: method replacingSpacesWithTabsOn: stream
! !

! TeamVClassWriter class methods !   
description
    "   ^   <String>
    Answer a string describing what kind of code filer I am"

    ^'Team/V'
!   
logAddProtocol: protocol before: beforeProtocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

! 
logRemoveProtocol: protocol inClass: className on: aStream


! 
logRenameProtocol: oldProtocol to: protocol inClass: className on: aStream
    "Log source code on aStream to add protocol"

! !

! TeamVClassWriter methods !   
fileOutDefinitionOn: stream
    "   stream  <WriteStream>
        ^       self
    Put a textual version of my class to stream."

    self forClass fileOutOn: stream.
    stream nextPut: $!!; cr.! !

! Collection methods !
add: anObject ifPresent: block
    "If the receiver doesn't include anObject, then add anObject to the receiver.
    Otherwise evaluate block."

    ^(self includes: anObject)
        ifTrue: [self add: anObject]
        ifFalse: block!
any
    "Answer any item in the receiver"

    ^self detect: [:each | true] ifNone: [nil]! 
any: aBlock
    "Answer whether any element in the receiver answers true to aBlock"

    self do: [:x | (aBlock value: x) ifTrue: [^true]].
    ^false! !

! Dictionary methods !   
associationClass
        "Answer the class of associations used by the receiver."
    ^Association
!   
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each element."
    | answer |
    answer := self species new.
    self keysAndValuesDo: [:key :value |
        answer at: key put: value copy].
    ^answer!   
keysAndValuesDo: twoArgumentBlock
    "Evaluate twoArgumentBlock with each of my key->value pairs"

    self associationsDo: [:each |
        twoArgumentBlock value: each key value: each value]!
shallowCopy
    "Answer a shallow copy of the receiver."
    | answer |
    answer := self species new.
    self keysAndValuesDo: [:key :value |
        answer at: key put: value].
    ^answer!   
veryDeepEqualTo: anObject withoutRecomparing: existingPairs
    "Answer a deep comparison of the receiver with anObject."
    | candidates value2 |
    self species == anObject species ifFalse: [^false].
    self size = anObject size ifFalse: [^false].
     candidates := existingPairs at: self
        ifAbsent: [existingPairs at: self put: IdentityDictionary new].
    ^candidates at: anObject ifAbsent: [
        candidates at: anObject put: true.
        self keysAndValuesDo: [:key1 :value1 |
            value2 := anObject at: key1 ifAbsent: [^false].
            (value1 veryDeepEqualTo: value2
                withoutRecomparing: existingPairs) ifFalse: [^false]].
        ^true]! !

! IndexedCollection methods !  
veryDeepEqualTo: anObject withoutRecomparing: existingPairs
    "Answer a deep comparison of the receiver with anObject."
    | candidates namedVariables unnamedVariables class |
    self species == anObject species ifFalse: [^false].
    self size = anObject size ifFalse: [^false].
     candidates := existingPairs at: self ifAbsent: [existingPairs at: self put: IdentityDictionary new].
    ^candidates at: anObject ifAbsent: [
        candidates at: anObject put: true.
        self with: anObject do: [:element1 :element2 |
            (element1 veryDeepEqualTo: element2
                withoutRecomparing: existingPairs) ifFalse: [^false]].
        ^true]! !

! String methods !
firstWord
        "Answer the first word from the
         receiver.  The receiver is divided into
         words at the occurrences of one or
         more space characters."
    | aStream answer index done |
    answer := ''.
    done := false.
    aStream := ReadStream on: self.
    [aStream atEnd or: [answer isEmpty not]]
        whileFalse: [
            [aStream atEnd ifTrue: [^answer].
             aStream peek > Space]
                whileFalse: [aStream next].
            index := aStream position + 1.
            [aStream atEnd not and: [aStream peek > Space]]
                whileTrue: [aStream next].
            answer := (self copyFrom: index to: aStream position)].
    ^answer! !

! Process class methods !
initialize
        "Private - initialize the class variables of the receiver."
    Smalltalk at: #StackOffsets put: ( Dictionary new
        at: 'MethodOffset' put: -2;
        at: 'ArgumentOffset' put: 2;
        at: 'ContextOffset' put: -4;
        at: 'ReceiverOffset' put: -1;
        at: 'ReturnOffset' put: 1;
        at: 'TemporaryOffset' put: -2;
        "at: 'ContextTemp' put: 6;"
        yourself ).
    DropStack := false! 
queueWalkback: aString makeUserIF: isUserIF resumable: resumeLevel
        "Enter a walkback for current process in pending event queue.
        Create new user interface process if ifBoolean is true."
    | process firstTime callBack guiClass |
    [ firstTime ] yourself.  "this method must have a block."
    ( guiClass := Smalltalk at: #CursorManager ifAbsent: [ nil ] ) notNil
        ifTrue: [ guiClass normal change ].
    self enableInterrupts: false.
    CurrentProcess isBeingDebugged
        ifTrue: [^CurrentProcess debugger takeControl: aString ].
    self traceOff.    firstTime := true.
    process := self copyStack.
    firstTime
        ifTrue: [ "before resume"
            firstTime := false.
            CurrentProcess := self new.
            isUserIF
                ifTrue: [ CurrentProcess makeUserIF ].
            CurrentProcess terminationBlock: process terminationBlock.
            ( self debuggerAvailable not or: [ ( guiClass := Smalltalk at: #PendingEvents ifAbsent: [ nil ] ) isNil ] )
                ifTrue: [
                    self enableInterrupts: true.
                    ( process runTimeError: aString resume: resumeLevel )
                        ifTrue: [ process terminate ] ]
                ifFalse: [
                    guiClass add: ( Message new
                        selector: #errorIn:label: ;
                        arguments: ( Array with: process with: aString ) ) ].
            callBack := Processor currentProcessIsRecursive.
            callBack
                ifTrue: [
                    CurrentProcess exceptionEnvironment: process exceptionEnvironment.
                    process runable: 0 ]
                ifFalse: [ process runable: resumeLevel ].
            process isRecursive ifTrue: [ DropStack := true ].
            process := nil.
            callBack ifTrue: [ self unwind ].
            self dropSenderChain.
            ( guiClass := Smalltalk at: #OSEventSemaphore ifAbsent: [ nil ] ) notNil
                ifTrue: [ guiClass signal ].  "force null event"
            self enableInterrupts: true.
            ( Smalltalk isRunTime and: [ ( guiClass := Smalltalk at: #Notifier ifAbsent: [ nil ] ) isNil
            or: [ guiClass windows isEmpty ] ] )
                ifTrue: [ Smalltalk exit ].
            isUserIF
                ifTrue: [ ( Smalltalk at: #Notifier ifAbsent: [ nil ] ) notNil ifTrue: [ SessionModel current runNotifier ] ]
                ifFalse: [
                    self enableInterrupts: false.
                    Processor schedule ] ]
        ifFalse: [ "after resume"
            resumeLevel < 2
                ifTrue: [ self error: 'process not resumable' ] ]! !

! Process methods !  
debugger
        "Answer the debugger associated with the receiver, or nil if none."
    ^debugger
!   
isBeingDebugged
        "Answer whether the receiver is being debugged."
    ^self debugger ~~ nil
! !

! Tree class methods !   
data: anObject
    ^self
        data: anObject
        withAll: #()!  
data: anObject with: aSubtree
    ^self
        data: anObject
        withAll: (Array with: aSubtree)!
data: anObject with: aSubtree with: anotherSubtree
    ^self
        data: anObject
        withAll: (Array with: aSubtree with: anotherSubtree)!  
data: anObject with: firstSubtree with: secondSubtree with: thirdSubtree
    ^self
        data: anObject
        withAll: (Array with: firstSubtree with: secondSubtree with: thirdSubtree)!  
data: anObject with: firstSubtree with: secondSubtree with: thirdSubtree with: fourthSubtree
    ^self
        data: anObject
        withAll: (Array with: firstSubtree with: secondSubtree with: thirdSubtree with: fourthSubtree)!  
data: anObject withAll: aCollectionOfSubtrees
    "Return a new tree with its data set to anObject, and turn aCollectionOfSubtrees into an OrderedCollection and make sure what we use as our collection is a copy (since asOrderedCollection in OrderedCollection simply returns self)."
    | subtrees |
    subtrees := aCollectionOfSubtrees asOrderedCollection.
    ^self new
        data: anObject;
        subtrees: (subtrees == aCollectionOfSubtrees
            ifTrue: [subtrees copy] "Must copy if collection is an OrderedCollection."
            ifFalse: [subtrees]) "asOrderedCollection did copy for us."!  
example1
    "return a sample tree."
    "Tree example1 <1 <2 > <3 > <4 > <5 > > "

    ^(self data: 1)
        addSubtree: (self data: 2);
        addSubtree: (self data: 3);
        addSubtree: (self data: 4);
        addSubtree: (self data: 5);
        yourself!
example2
    "manipulate the tree created in example 1."
    "Tree example2 <1 <2 <10 <20 > <30 > <40 > <50 > > > <3 > <4 > <5 > > "

    | aTree |
    aTree := self example1.
    (aTree subtreeAt: 1) addSubtree: (self example1 collect: [:data | data * 10]).
    ^aTree! 
example3
    "show that the inject:into: works.  This method, inherited from a super class,
     is implemented in terms of do:."
    "Tree example3 165"

    ^self example2 inject: 0 into: [:sum :data | sum + data]! 
example4
    "get a store string of the tree created in example2."
    "Tree example4"

    ^self example2 storeString!   
new
    ^super new initialize!   
with: aSubtree
    ^self
        data: nil
        withAll: (Array with: aSubtree)!
with: aSubtree with: anotherSubtree
    ^self
        data: nil
        withAll: (Array with: aSubtree with: anotherSubtree)!  
with: firstSubtree with: secondSubtree with: thirdSubtree
    ^self
        data: nil
        withAll: (Array with: firstSubtree with: secondSubtree with: thirdSubtree)!  
with: firstSubtree with: secondSubtree with: thirdSubtree with: fourthSubtree
    ^self
        data: nil
        withAll: (Array with: firstSubtree with: secondSubtree with: thirdSubtree with: fourthSubtree)!  
withAll: aCollectionOfSubtrees
    "Return a new tree with no data and aCollectionOfSubtrees as its subtrees."
    ^self
        data: nil
        withAll: aCollectionOfSubtrees! !

! Tree methods !  
= aTree

    ((aTree isKindOf: self class) or: [self isKindOf: aTree class])
        ifFalse: [^false].

    self data = aTree data
        ifFalse: [^false].

    ^self subtrees = aTree subtrees!  
add: newObject
    "Trees cannot implement add:."

    self shouldNotImplement!
addSubtree: aTree
    ^self subtrees add: aTree! 
addSubtree: aTree after: anotherTree
    "Add aTree after anotherTree."

    ^self subtrees add: aTree after: anotherTree! 
addSubtree: aTree afterIndex: index
    "Add aTree after index in the receiver's subtrees."

    ^self addSubtree: aTree after: (self subtreeAt: index)!   
addSubtree: aTree before: anotherTree
    "Add aTree before anotherTree."

    ^self subtrees add: aTree before: anotherTree!  
addSubtree: aTree beforeIndex: index
    "Add aTree before index in the receiver's subtrees."

    ^self addSubtree: aTree before: (self subtreeAt: index)!
collect: aBlock
    "For each element in the receiver, evaluate aBlock with that element as the argument.
    Answer a new collection containing the results as its elements from the aBlock evaluations."

    ^self species
        data: (aBlock value: self data)
        withAll: (self subtrees collect: [:aTree | aTree collect: aBlock])!   
copyEmpty: aSize
    "Answer a copy of the receiver that contains no elements."

    self shouldNotImplement!  
data
    ^data!  
data: anObject
    data := anObject! 
deepCopy
    "Answer a deepCopy of myself"



    ^self species data: self data deepCopy withAll: (self subtrees collect: [:each | each deepCopy])!  
do: aBlock
    self preorderDo: aBlock!  
hash

    ^self size!   
initialize
    self subtrees: OrderedCollection new! 
isLeaf
    "answer true if I have no children"

    ^self size = 1!
postorderDo: aBlock
    "Evaluate aBlock with each element of the reciever.  Start with the subtrees' data, followed by the receiver's data."

    self subtrees do: [:aTree | aTree postorderDo: aBlock].
    aBlock value: self data!   
preorderDo: aBlock
    "Evaluate aBlock with each element of the reciever.  Start with the receiver's data, followed by each of its subtrees' data."

    aBlock value: self data.
    self subtrees do: [:aTree | aTree preorderDo: aBlock]! 
printOn: aStream

    self printOn: aStream atIndent: 0!
printOn: aStream atIndent: indent

    aStream cr.
    indent timesRepeat: [
        aStream nextPutAll: '   '].

    aStream
        nextPut: $<;
        print: self data.
    self subtrees do: [:aTree |
        aTree printOn: aStream atIndent: indent + 1].
    aStream nextPut: $>!
privateValidateSubtreeIndex: anIndex
    "Validate the given index.  If the valid index is outside the acceptable range, then report an error."

    ((anIndex <= 0) or: [anIndex > self subtrees size])
        ifTrue: [^self errorInBounds: anIndex]!  
remove: oldObject ifAbsent: anExceptionBlock
    "Trees cannot implement remove:ifAbsent:."

    self shouldNotImplement!  
select: aBlock
    "Trees cannot implement select:."

    ^self shouldNotImplement!
size
    "Return the number of elements in the receiver."

    ^self subtrees inject: 1 into: [:sum :aTree | sum + aTree size]!
storeOn: aStream
    "Append the ASCII representation of the receiver to aStream from which the receiver can be reinstantiated."

    aStream
        nextPutAll: '(';
        nextPutAll: self class name;
        nextPutAll: ' data: ';
        store: self data;
        nextPutAll: ' withAll: (';
        store: self subtrees;
        nextPutAll: '))'! 
subtreeAt: index
    "Return the subtree found at the provided index."

    self privateValidateSubtreeIndex: index.
    ^self subtrees at: index!
subtreeAt: index put: aTree
    "Set the subtree found at the provided index."

    self privateValidateSubtreeIndex: index.
    ^self subtrees at: index put: aTree! 
subtreeRootedAt: anObject ifNone: errorBlock
    "Answer my subtree which is rooted at anObject.  If I don't have one, then evaluate errorBlock"

    self data = anObject
        ifTrue: [^self].

    ^self subTrees
        detect: [:each | (each subtreeRootedAt: anObject ifNone: [nil]) notNil]
        ifNone: errorBlock!   
subtrees
    ^subtrees!  
subtrees: aCollection
    subtrees := aCollection! !

! Color class methods !  
blue
        "Answer an instance of the receiver representing the color blue."
    ^self defaultColorNamed: #blue!  
brown
        "Answer an instance of the receiver representing the color brown."
    ^self defaultColorNamed: #brown!   
red: redComponent green: greenComponent blue: blueComponent
        "Answer an instance of the receiver whose components equal
        the given <redComponent>, <greenComponent> and
        <blueComponent>."
    ^RGBColor red: redComponent green: greenComponent blue: blueComponent! !

! MessageNotUnderstood methods !  
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it."
    Process
        queueWalkback: self defaultDescriptionString
        makeUserIF: CurrentProcess isUserIF
        resumable: 2.
    ^self message perform
! !

! Bitmap methods !  
veryDeepCopyWithoutRecopying: existingCopies
    "Answer a deep copy of the receiver."
   ^existingCopies at: self ifAbsent: [^existingCopies at: self put: self clone]! !

! Icon methods !  
veryDeepCopyWithoutRecopying: existingCopies
    "Answer a deep copy of the receiver."
   ^existingCopies at: self ifAbsent: [^existingCopies at: self put: self clone]! !

! Magnitude methods ! 
isPrimitiveComparisonObject
    ^true! !

! MethodClassifier class methods !   
classificationMatchForSelector: selector with: strings
    "   ^   true | false
    Answer true if any of the strings in strings is a substring of selector"

    strings do: [:each |
        (selector indexOfString: each) = 1
            ifTrue: [^true]].

    ^false!  
classify: aClass
    "Classify all unclassified selectors in aClass"

    | selectors organizer |
    ((organizer := CodeFiler organizerFor: aClass) isKnownCategory: organizer defaultCategory) ifTrue: [
        selectors := organizer elementsOfCategory: organizer defaultCategory.
        self classifySelectors: selectors in: aClass]! 
classifyAll: classes
    "Classify all of the methods in the system"

    | dialog size classifier organizer index |

    classifier := MethodClassifier default.
    size := classes size * 2.  "account for the metaclasses too"

    dialog := ProgressIndicatorDialog new
        noCancel;
        open: WindowLabelPrefix message: 'Classifying methods...'.

    index := 0.
    classes do: [:aClass |
        (Array with: aClass with: aClass class) do: [:each |
            organizer := CodeFiler organizerFor: each.
            (organizer isKnownCategory: organizer defaultCategory) ifTrue: [
                classifier classifyAll: (organizer elementsOfCategory: organizer defaultCategory) in: each.
                organizer update].
            dialog percent: (index / size * 100) truncated.
            index := index + 1]].

    dialog close.!
classifyByCommentRule
    "   ^   RuleBlock
    See MethodClassifier>>addRule: for a description of a ruleBlock.
    Answer a rule for classifying methods by method comment"

    | source firstComment answer |

    ^[:selector :class |
            answer := nil.
            source := ReadStream on: (class sourceCodeAt: selector).
            source upTo: $".
            firstComment := source upTo: $".
            (firstComment asLowerCase indexOfString: 'private') > 0
                ifTrue: [answer := 'private'].
            answer]!   
classifyBySelectorRule
    "   ^   RuleBlock
    See MethodClassifier>>addRule: for a description of a ruleBlock.
    Answer a rule for classifying methods by selector name"

    | answer pairs pairIndex |

    pairs := #(
        (('=' '<' '>' '~') 'comparing')
        (('do:' 'collect:' 'reject:' 'inject:' 'select:' 'detect:') 'enumerating')
        (('at' 'put' 'basicAt') 'accessing')
        (('add' 'remove') 'modifying')
        (('size' 'includes' 'hash') 'querying')
        (('print' 'store') 'printing')
        (('new') 'instance creation')
        (('open') 'scheduling')
        (('display') 'displaying')
        (('initialize') 'initializing')
        (('update') 'updating')
        (('copy' 'shallowCopy' 'deepCopy') 'copying')
        (('private') 'private')
        (('as') 'converting')
        (('is') 'testing')).


    ^[:selector :class |
            answer := nil.
            pairIndex := 1.
            [answer isNil and: [pairIndex <= pairs size]] whileTrue: [
                (self classificationMatchForSelector: selector with: (pairs at: pairIndex) first)
                    ifTrue: [answer := (pairs at: pairIndex) last]
                    ifFalse: [pairIndex := pairIndex + 1]].
            answer]! 
classifySelectors: selectors in: aClass
    "selectors      <Collection withAll: <Symbol>>
    aClass              <Class or Metaclass>
    Classify selectors in aClass"

    | classifier |

    classifier := self default.
    classifier classifyAll: selectors in: aClass.! 
classifySystem
    "Classify all of the methods in the system"

    | classes |

    classes := Smalltalk rootClasses inject: (OrderedCollection new: 600) into:[ :all :rootClass |
         all addAll: rootClass withAllSubclasses; yourself].
    self classifyAll: classes!
default
    "Answer a method classifier with default classification rules"

    | classifier |

    classifier := self new.
    self defaultRules do: [:each |
        classifier addRule: each].

    ^classifier!  
defaultRules
    "   ^   <Collection withAll: <RuleBlock>>
    See MethodClassifier>>addRule: for a description of a ruleBlock.
    Answer a collection of default classification rules"

    | rules |

    rules := OrderedCollection new: 10.
    rules
        add: self classifyByCommentRule;
        add: self classifyBySelectorRule.

    ^rules!
example1
    "(self example1)"

    self classify: String! 
new
    ^super new initialize! !

! MethodClassifier methods ! 
addRule: ruleBlock
    "ruleBlock      <TwoArgumentBlock value: selector <Symbol> value: class <Behavior>>
    Add ruleBlock to my list of rules. A ruleBlock takes two arguments - a selector and a class,
    and answers the name of a method category appropriate for the selector. If none seems
    appropriate, then answer nil."

    rules add: ruleBlock! 
classificationFor: aSelector in: aClass
    "aSelector      <Symbol>
    aClass              <Class>
        ^                      <String>
    Answer the name of the protocol to which aSelector belongs"

    | ruleBlock |

    ruleBlock := rules
        detect: [:first | (first value: aSelector value: aClass) notNil]
        ifNone: [nil].

    ruleBlock isNil
        ifTrue: [^nil]
        ifFalse: [^ruleBlock value: aSelector value: aClass]!   
classify: aSelector in: aClass
    "Place aSelector in an appropriate method category"

    | protocol |

    protocol := self classificationFor: aSelector in: aClass.
    protocol notNil ifTrue: [
        (CodeFiler organizerFor: aClass) addElement: aSelector toCategory: protocol]!
classifyAll: selectors in: aClass
    "classify the given selectors in aClass"

    selectors do: [:each |
        self classify: each in: aClass]!   
initialize

    rules := OrderedCollection new.! !

! MethodVersion class methods !   
smalltalkClass: aClassOrMeta selector: aSymbol source: aString timeStamp: aTimeStamp
    "Answer a new instance of a method version"

    ^self new
        initializeSmalltalkClass: aClassOrMeta
        selector: aSymbol
        source: aString
        timeStamp: aTimeStamp
! !

! MethodVersion methods !   
hasPreviousVersions
    ^previousVersion notNil
!   
initializeSmalltalkClass: aClassOrMeta selector: aSymbol source: aString timeStamp: aTimeStamp

        smalltalkClass := aClassOrMeta.
        selector := aSymbol.
        source := aString.
        timeStamp := aTimeStamp.
!  
previousVersion
    "   ^   <MethodVersion> | nil
    Answer the version of myself which was saved before me"

    previousVersion isNil
        ifTrue: [^nil].

    (previousVersion isKindOf: MethodVersion)
        ifTrue: [^previousVersion].

    "otherwise it is an integer with the source position of the previous version..."
    previousVersion := (CodeFiler forClass: smalltalkClass) versionOf: selector at: previousVersion in: sourceStream.

    ^previousVersion
! 
previousVersion: index sourceStream: aStream
    "Private - Set the index of my previous version, and the stream on which to find it.
    This way it can be loaded lazily when needed"

    previousVersion := index.
    sourceStream := aStream

!  
printOn: aStream

    aStream
        nextPutAll: smalltalkClass name;
        nextPutAll: '>>';
        nextPutAll: selector;
        space;
        nextPutAll: timeStamp printString
! 
printStampOn: aStream
    "Print my timeStamp info on aStream"

    aStream
        nextPutAll: timeStamp date dayOfMonth printString;
        space;
        nextPutAll: timeStamp date monthName;
        space;
        nextPutAll: timeStamp date year printString;
        nextPut: $,;
        space;
        nextPutAll: timeStamp time printString.
! 
selector
    ^selector

!  
smalltalkClass
    ^smalltalkClass
!
source
    ^source

!  
stampPrintString

    | stream |

    stream := WriteStream on: (String new: 50).
    self printStampOn: stream.
    ^stream contents
!
timeStamp
    ^timeStamp

!
withAllPreviousVersions
    "   ^   <Collection withAll: <MethodVersion>>
    Answer a collection with myself, and all previous versions that I know about"

    | currentVersion allVersions |

    currentVersion := self.
    allVersions := OrderedCollection new.
    [currentVersion notNil] whileTrue: [
        allVersions add: currentVersion.
        currentVersion := currentVersion previousVersion].

    ^allVersions
! !

! NavigatorBrowser class methods !  
new
    ^super new initialize! !

! NavigatorBrowser methods ! 
addCategory: category before: previousCategory
    "category       <string>
     previousCategory <string> | nil
    Add category to my selectedClassOrganizer before previousCategory.  If previousCategory is nil,
    then add category at the end. If category starts with a dash, then add a separator line."

     | categoryName classOrganizer |

    classOrganizer := self selectedClassOrganizer.
    categoryName := category first = $-
        ifTrue: [self privateNewSeparatorForOrganizer: classOrganizer]
        ifFalse: [category].

    (classOrganizer isKnownCategory: categoryName)
        ifTrue: [^self].
    classOrganizer addCategory: categoryName before: previousCategory.
    SourceManager current logEvaluate:
        '(CodeFiler systemOrganizer addCategory: ',
        categoryName storeString, ' before: ', previousCategory storeString, ')'.
    self selectedCategories: (Array with: categoryName).
!  
addProtocol: protocol before: previousProtocol
    "protocol       <string>
     previousProtocol <string> | nil
    Add protocol to my selectedMethodOrganizer before previousProtocol.  If previousProtocol is nil,
    then add protocol at the end"

     | methodOrganizer |

    methodOrganizer := self selectedMethodOrganizer.
    (methodOrganizer isKnownCategory: protocol)
        ifTrue: [^self].
    methodOrganizer addCategory: protocol before: previousProtocol.
    SourceManager current logEvaluate:
        '(CodeFiler organizerFor: ', self selectedClassOrMetaclass storeString,
        ')  addCategory: ',
        protocol storeString, ' before: ', previousProtocol storeString.
    self selectedProtocols: (Array with: protocol)!  
browseClassMethods
        "Set myself to browse class methods and protocols"

    self classOrInstanceMode: #class.
    self privateValidateSelection!   
browseInstanceMethods
        "Set myself to browse instance methods and protocols"

    self classOrInstanceMode: #instance.
    self privateValidateSelection!  
categories
    "^ <collection of strings>
    Answer the categories I am browsing"

    ^self organizer categories!   
classes
    "^ <collection of symbols>
    Answer all of the classes I am browsing"

    | classes |

    classes := Set new.

    self selectedCategories do: [:each |
        classes addAll: (self organizer elementsOfCategory: each)].
    ^classes asOrderedCollection!   
classOrganizerEditString
    "^ <string>
    Answer an edit string representing my organizer"

    ^self organizer editString!
classOrInstanceMode
    "   ^     Symbol with: #class | #instance
    Private - Answer my class or instance mode"

    ^classOrInstanceMode!  
classOrInstanceMode: symbol
    "   symbol:     <#class | #instance>
    Private - Set my class or instance mode"

    classOrInstanceMode := symbol! 
copyMethods: methods from: oldClass to: newClass
    "oldClass: <Class or MetaClass>
    newClass: <Class or MetaClass>
    Private - Copy the given methods from oldClass to newClass"

    | stream methodsByProtocol methodsInProtocol methodOrganizer protocol |

    methodOrganizer := CodeFiler organizerFor: oldClass.
    methodsByProtocol := Dictionary new.
    methods do: [:each |
        protocol := methodOrganizer categoryOfElement: each.
        (methodsByProtocol includesKey: protocol)
            ifFalse: [methodsByProtocol at: protocol put: OrderedCollection new].
        (methodsByProtocol at: protocol) add: each].

    stream := WriteStream on: (String new: 200).
    methodOrganizer categories do: [:eachProtocol |
        methodsInProtocol := methodsByProtocol at: eachProtocol ifAbsent: [#()].
        methodsInProtocol notEmpty ifTrue: [
            stream
                nextPut: $!!;
                nextPutAll: newClass name;
                nextPutAll: ' methodsFor: ';
                nextPutAll: eachProtocol printString;
                nextPutAll: ' !!';
                cr.
            methodsInProtocol
                do: [:selector | stream nextChunkPut: (oldClass compiledMethodAt: selector) sourceString]
                andBetweenDo: [stream cr].

            stream nextChunkPut: ' ';cr]].
    stream contents asStream fileIn
! 
copySelectedClassesTo: newCategories
    "Copy my selected classes from the selected category to newCategories"

    | classOrganizer |

    classOrganizer := self selectedClassOrganizer.
    self selectedClasses do: [:each |
        classOrganizer addElement: each asSymbol toCategories: newCategories].
    classOrganizer updateDefaultCategory.
    self privateValidateSelection!
copySelectedMethodsTo: newClass
    "newClass: <Class or MetaClass>
    Copy all selected methods to newClass"

    self copyMethods: self selectedMethods from: self selectedSmalltalkClassOrMetaclass to: newClass

! 
copySelectedProtocolsTo: newClass
    "newClass: <Class or MetaClass>
    Copy all methods in my selected protocols to newClass"

    | methods methodOrganizer |

    methodOrganizer := CodeFiler organizerFor: self selectedClassOrMetaclass.
    methods := self selectedProtocols inject: OrderedCollection new into: [:sum :each |
        sum
            addAll: (methodOrganizer elementsOfCategory: each);
            yourself].

    self copyMethods: methods from: self selectedSmalltalkClassOrMetaclass to: newClass


!   
deepCopy
    "   ^   <NavigatorBrowser>
    Answer a deep copy of myself"

    | theCopy |

    theCopy := self species new
        organizer: self organizer copy;
        selection: self selection deepCopy;
        yourself.

    self isBrowsingInstanceMethods
        ifTrue: [theCopy browseInstanceMethods]
        ifFalse: [theCopy browseClassMethods].
    ^theCopy!  
definitionString
    "Answer the definition string for the selected class.
    If more than one class is selected, or no class is selected,
    then answer an empty string"

    | smalltalkClass template |

    ((self selectedClasses size > 1| self selectedClass isNil) or: [
    ((Smalltalk includesKey: self selectedClass asSymbol) not)])
        ifTrue: [
            template := WriteStream on: (String new: 60).
            template
                nextPutAll: CodeFiler definitionTemplate;
                nextPutAll: '#( '.
            self selectedCategories do: [:each |
                template print: each; space].
            template nextPut: $).
            ^template contents]
        ifFalse: [^(CodeFiler forClass: self selectedSmalltalkClass) definitionString]! 
fileOutSelectedCategoriesOn: aStream
    "File out the classes in the selected categories in hierarchical order on aStream"

    | classes |

    classes := self hierarchyOfClasses collect: [:each |
        Smalltalk at: each trimBlanks asSymbol].

    (CodeFiler forClasses: classes)
        fileOutOn: aStream;
        release.
!
fileOutSelectedCategoriesOn: aStream with: aCodeFiler
    "File out the classes in the selected categories in hierarchical order on aStream"

    | classes |

    classes := self hierarchyOfClasses collect: [:each |
        Smalltalk at: each trimBlanks asSymbol].

    (aCodeFiler forClasses: classes)
        fileOutOn: aStream;
        release.
!  
fileOutSelectedClassesOn: aStream with: classWriter
    "classWriter    <a classWriter>
    File out the selected classes on aStream"

    (classWriter forClasses: self selectedSmalltalkClasses)
        fileOutOn: aStream;
        release.
!  
fileOutSelectedClassesWithAllSubclassesOn: aStream with: classWriter
    "classWriter    <a classWriter>
    File out the selected classes with all their subclasses on aStream"

    | classes |

    classes := self selectedSmalltalkClasses inject: Set new into: [:sum :each |
        sum addAll: each withAllSubclasses; yourself].

    (classWriter forClasses: classes asArray)
        fileOutOn: aStream;
        release.
!  
fileOutSelectedMethodsOn: aStream
    "File out the selected methods on aStream"

    (CodeFiler forClass: self selectedSmalltalkClassOrMetaclass)
        fileOutMethods: self selectedMethods on: aStream;
        release.
! 
fileOutSelectedMethodsOn: aStream with: classWriter
    "classWriter    <a classWriter>
    File out the selected methods on aStream"

    (classWriter forClass: self selectedSmalltalkClassOrMetaclass)
        fileOutMethods: self selectedMethods on: aStream;
        release.
! 
fileOutSelectedProtocolsOn: aStream
    "File out the selected protocols on aStream"

    | writer |

    writer := CodeFiler forClass: self selectedSmalltalkClassOrMetaclass.
    self selectedProtocols do: [:each |
        writer fileOutProtocol: each on: aStream].
    writer release.
! 
fileOutSelectedProtocolsOn: aStream with: classWriter
    "classWriter    <a classWriter>
    File out the selected protocols on aStream"

    | writer |

    writer := classWriter forClass: self selectedSmalltalkClassOrMetaclass.
    self selectedProtocols do: [:each |
        writer fileOutProtocol: each on: aStream].
    writer release.
! 
findClass: className
    "className  <string>
    Find and select the named class"

    | categories |

    categories := self selectedClassOrganizer categoriesOfElement: className asSymbol.
    categories isEmpty |  categories isNil
        ifTrue: [^self].        "Class could not be found"
    self
        selectedCategories: categories;
        selectedClasses: (Array with: className);
        privateValidateSelection! 
hierarchyOfClasses
    "^ <collection of strings>
    Answer my classes in hierarchical order, with indentation"

    | classes classesSet hierarchy |
    classes := self classes collect: [:each | Smalltalk at: each].
    classes isEmpty
        ifTrue: [^classes].
    classesSet := (Set new: classes size * 2)
        addAll: classes;
        yourself.

    CursorManager execute changeFor: [
        hierarchy := OrderedCollection new: classes size.
        self
            putHierarchyFrom: Smalltalk rootClasses
            with: classesSet
            into: hierarchy
            withIndent: ''].

    ^hierarchy!  
initialize

    organizer := CodeFiler systemOrganizer.
    selection := CodeBrowserSelection new.
    self browseInstanceMethods.!   
isBrowsingClassMethods
        "Answer true if I'm browsing class methods and protocols"

    ^self classOrInstanceMode = #class!  
isBrowsingInstanceMethods
        "Answer true if I'm browsing instance methods and protocols"

    ^self classOrInstanceMode = #instance! 
methodOrganizerEditString
    "^ <string>
    Answer an edit string representing my selected class's organizer."

    self selectedClass isNil | (self selectedClasses size > 1)
        ifTrue: [^String new]
        ifFalse: [^self selectedMethodOrganizer editString]! 
methods
    "^ <collection of strings>
    Answer all of the methods I am browsing; those in all of my selected protocols"

    | methods methodOrganizer |

    self selectedProtocols isEmpty
        ifTrue: [^Array new].

    methodOrganizer := self selectedMethodOrganizer.
    methods := OrderedCollection new.
    self selectedProtocols do: [:each |
        methods addAll: ((methodOrganizer elementsOfCategory: each) collect: [:a| a asString])].
    ^methods! 
moveSelectedClassesTo: newCategories
    "Move my selected classes from the selected category to newCategories"

    self selectedClassOrganizer
        reorganize: (self selectedClasses collect: [:each | each asSymbol]) into: newCategories.
    self privateValidateSelection! 
moveSelectedMethodsTo: newProtocol
    "Move my selected methods from the selected protocols to destinationProtocol"

    | methodOrganizer |

    self selectedMethodOrganizer reorganize: self selectedMethods into: (Array with: newProtocol).
    self privateValidateSelection!
organizer
    "Answer my organizer"

    ^organizer!   
organizer: aClassBasedOrganizer
    "Set my organizer"

    organizer := aClassBasedOrganizer! 
privateNewSeparatorForOrganizer: anOrganizer
    "Private - Answer the name of a valid separator for anOrganizer"

    | separator |

    separator := '-------------------------------------------------' copy.
    [anOrganizer isKnownCategory: separator]
        whileTrue: [separator := separator, '-'].

    ^separator
!   
privateValidateSelectedCategories
    "Private - Make sure that all of my selected categories still exist"

    | categories |

    categories := self organizer categories.

    self selection categories: (self selectedCategories select: [:each |
        categories includes: each]).!  
privateValidateSelectedClasses
    "Private - Make sure that all of my selected classes are in my selected categories.
    If there is more than one selected class, then remove all protocols and methods from
    the selection."

    | classes |

    classes := self selectedCategories inject: Set new into: [:sum :each |
        sum addAll: (self organizer elementsOfCategory: each); yourself].

    self selection classes: (self selectedClasses select: [:each |
        classes includes: each asSymbol]).

    self selectedClasses size > 1 ifTrue: [
        self selection
            protocols: Array new;
            methods: Array new]!  
privateValidateSelectedMethods
    "Private - Make sure that all of my selected methods are in my selected protocols."

    | methods anOrganizer |

    methods := self selectedClassesOrMetaclasses inject: Set new into: [:sum :each |
        anOrganizer := CodeFiler organizerFor: each.
        sum addAll: (self selectedProtocols inject: Set new into: [:methodsForClass :protocol |
            methodsForClass addAll: (anOrganizer elementsOfCategory: protocol); yourself])].

    self selection methods: (self selectedMethods select: [:each |
        methods includes: each asSymbol]).!
privateValidateSelectedProtocols
    "Private - Make sure that all of my selected protocols are in my selected classes.  If there are
    no protocols selected, then remove all my selected methods"

    | protocols |

    protocols := self selectedClassesOrMetaclasses inject: Set new into:  [:sum :each |
        sum addAll: (CodeFiler organizerFor: each) categories; yourself].

    self selection protocols: (self selectedProtocols select: [:each |
        protocols includes: each]).

    self selectedProtocols isEmpty
        ifTrue: [self selection methods: Array new]! 
privateValidateSelection
    "Private - Make sure that all of my selected methods are in my selectedProtocols,
        my selected protocols are in my selected class
        my selected classes are in my selected categories"

    self
        privateValidateSelectedCategories;
        privateValidateSelectedClasses;
        privateValidateSelectedProtocols;
        privateValidateSelectedMethods!  
protocols
    "^ <collection of strings>
    Answer all of the protocols I am browsing.  If there is one class selected, answer its protocols.
    if there is more than one class selected then answer an empty array."

    | classes |

    (classes := self selectedClassesOrMetaclasses) isEmpty | (classes size > 1)
        ifTrue: [^Array new]
        ifFalse: [^self selectedMethodOrganizer update;categories].! 
putHierarchyFrom: rootCollection with: visibleClasses into: hierarchy withIndent: indentString

    rootCollection do: [:each |
        (visibleClasses includes: each)
            ifTrue: [
                hierarchy add: indentString, each symbol.
                self
                    putHierarchyFrom: (each subclasses  asSortedCollection: Class sortBlock)
                    with: visibleClasses
                    into: hierarchy
                    withIndent: indentString, '  ']
            ifFalse: [
                self
                    putHierarchyFrom: (each subclasses  asSortedCollection: Class sortBlock)
                    with: visibleClasses
                    into: hierarchy
                    withIndent: indentString]]
!
removeSelectedCategories
    "Remove my selected categories and all of their classes from Smalltalk"

    self selectedClassOrganizer removeCategories: self selectedCategories.
    self privateValidateSelection.!  
removeSelectedClasses
    "Remove my selected classses from Smalltalk, and from all of the organizers to which they belong"

    | categories |
    self selectedClasses reverseDo: [:each |
        (Smalltalk at: each asSymbol) removeFromSystem.
        SourceManager current logEvaluate: each, ' removeFromSystem'.
        self selectedClassOrganizer removeElement: each asSymbol.
        CodeFiler
            removeOrganizerFor: each asSymbol;
            removeOrganizerFor: (each, ' class') asSymbol].
    self selectedClassOrganizer updateDefaultCategory.
    self privateValidateSelection.!  
removeSelectedMethods
    "Remove the selected methods from Smalltalk"

    self selectedMethods do: [:each |
        self selectedMethodOrganizer removeElement: each].
    self selectedMethodOrganizer updateDefaultCategory.
    self privateValidateSelection! 
removeSelectedProtocols
    "Remove the selected protocols, and all of the methods they contain"

    self selectedProtocols do: [:protocol |
        self selectedMethodOrganizer removeCategory: protocol].
    self privateValidateSelection! 
renameSelectedCategoriesTo: newCategories
    "newCategories <indexed collection of strings>
    Rename the selected categories to corresponding elements in newCategories in the selected class organizer"

    self selectedCategories size ~= newCategories size
        ifTrue: [^self error: 'arguments are different sizes'].
    1 to: self selectedCategories size do: [:index |
        (self selectedClassOrganizer isKnownCategory: (newCategories at: index))
            ifFalse: [
                self selectedClassOrganizer rename: (self selectedCategories at: index) to: (newCategories at: index)]].
    self privateValidateSelection.!   
renameSelectedProtocolsTo: newProtocols
    "newProtocol <indexed collection of strings>
    Rename the selected protocols to corresponding elements in newProtocols in the selected method organizer"

    self selectedProtocols size ~= newProtocols size
        ifTrue: [^self error: 'arguments are the different sizes'].
    1 to: self selectedProtocols size do: [:index |
        (self selectedMethodOrganizer isKnownCategory: (newProtocols at: index))
            ifFalse: [
                self selectedMethodOrganizer rename: (self selectedProtocols at: index) to: (newProtocols at: index)]].
    self privateValidateSelection.!
selectedCategories
    "^ <collection of strings>
    Answer the categories from my selection"

    ^self selection categories!   
selectedCategories: anIndexedCollection
    "anIndexedCollection <collection of strings>
    Set the categories in my selection to anIndexedCollection."

    self selection categories: anIndexedCollection.
    self privateValidateSelection.!
selectedCategory
    "^ <string> | nil
    Answer the first category thats in my selection"

    ^self selectedCategories isEmpty
        ifTrue: [nil]
        ifFalse: [self selectedCategories first]!   
selectedClass
    "^ <string>
    Answer the first class in my selection."

    ^self selectedClasses isEmpty
        ifTrue: [nil]
        ifFalse: [self selectedClasses first]!  
selectedClasses
    "^ <collection of strings>
    Answer the selected classes"

    ^self selection classes! 
selectedClasses: anIndexedCollection
    "anIndexedCollection <collection of strings>
    Set the selected classes."

    self selection classes: anIndexedCollection.
    self privateValidateSelection!
selectedClassesOrMetaclasses
    "^ <collection of strings>
    Answer the selected classes.  If I'm browsing instance methods, then answer the classes.
    If I'm browsing class methods, then answer the metaClasses"

    self isBrowsingInstanceMethods
        ifTrue: [^self selection classes]
        ifFalse: [^( self selection classes) collect: [:each |
            each, ' class']]!   
selectedClassOrganizer
    "Answer the ClassBasedOrganizer that I'm browsing"

    ^self organizer!
selectedClassOrMetaclass
    "^ <string> | nil
    Answer the first class in my selection.  If I'm in instance mode, answer the class.
    If I'm in class mode, answer the metaclass."

    | classes |

    ^(classes := self selectedClassesOrMetaclasses) isEmpty
        ifTrue: [nil]
        ifFalse: [classes first]!
selectedMethod
    "^ <string> | nil
    Answer the first method in my selection"

    ^self selectedMethods isEmpty
        ifTrue: [nil]
        ifFalse: [self selectedMethods first]!   
selectedMethodOrganizer
    "^ <methodBasedOrganizer> | nil
    Answer the methodBasedOrganizer for the selected class,
    or nil if there are no classes, or more than one class selected."

    ^self selectedClasses size >1 | self selectedClasses isEmpty
        ifTrue: [nil]
        ifFalse: [CodeFiler organizerFor: self selectedClassOrMetaclass]!
selectedMethods
    "^ <collection of strings>
    Answer the methods in my selection"

    ^self selection methods!  
selectedMethods: anIndexedCollection
    "anIndexedCollection <collection of strings>
    Set my selected methods to anIndexedCollection"

    self selection methods: (anIndexedCollection collect: [:each | each asSymbol]).
    self privateValidateSelection!
selectedMethodSource
    "^ <string>
    Answer the source code for my selected method.  If no method is selected, or if more than one method is
    selected, then answer an empty string"

    self selectedMethod isNil | (self selectedMethods size > 1)
        ifTrue: [^String new].
    ^self selectedSmalltalkClassOrMetaclass sourceCodeAt: self selectedMethod trimBlanks asSymbol! 
selectedProtocol
    "^ <string> | nil
    Answer the first protocol in my selection"

    ^self selectedProtocols isEmpty
        ifTrue: [nil]
        ifFalse: [self selectedProtocols first]!   
selectedProtocols
    "^ <collection of strings>
    Answer the protocols in my selection"

    ^self selection protocols!
selectedProtocols: anIndexedCollection
    "anIndexedCollection <collection of strings>
    Set the protocols in my selection"

    self selection protocols: anIndexedCollection.
    self privateValidateSelection!
selectedSmalltalkClass
    "^ <Class> | nil
    Answer the selected class in Smalltalk"

    self selectedClass isNil
        ifTrue: [^nil].

    ^Smalltalk at: self selectedClass asSymbol! 
selectedSmalltalkClasses
    "^ <Collection of Classes> | nil
    Answer the selected classes in Smalltalk"

    | answer class |

    self selectedClass isNil
        ifTrue: [^nil].
    answer := OrderedCollection new.
    self selectedClasses do: [:each |
        answer add: (Smalltalk at: each asSymbol)].
    ^answer!
selectedSmalltalkClassesOrMetaclasses
    "^ <Collection of Classes or MetaClasses> | nil
    Answer the selected classes or metaclasses in Smalltalk"

    | answer classOrMeta |

    self selectedClass isNil
        ifTrue: [^nil].
    answer := OrderedCollection new.
    self selectedClassesOrMetaclasses do: [:each |
        classOrMeta := Smalltalk at: each asSymbol.
        self isBrowsingClassMethods
            ifTrue: [classOrMeta := classOrMeta class].
        answer add: classOrMeta].
    ^answer
!   
selectedSmalltalkClassOrMetaclass
    "^ <Class or MetaClass> | nil
    Answer the selected class or metaclass in Smalltalk"

    | classOrMeta |

    self selectedClass isNil
        ifTrue: [^nil].

    classOrMeta := Smalltalk at: self selectedClass asSymbol.
    self isBrowsingClassMethods
        ifTrue: [classOrMeta := classOrMeta class].
    ^classOrMeta!  
selection
    "Private - Answer my selection"

    ^selection! 
selection: aCodeBrowserSelection
    "Private - Set my selection"

    selection := aCodeBrowserSelection! 
smalltalkClasses
    "^ <collection withAll: <Class>>
    Answer all of the classes I am browsing"

    | classes |

    classes := Set new.

    self selectedCategories do: [:each |
        classes addAll: (self organizer elementsOfCategory: each)].
    ^classes asOrderedCollection collect: [:each | Smalltalk at: each asSymbol]! 
update
    "Update my classBasedOrganizer, and validate my selection"

    self organizer
        makeDirty;
        update.
    self privateValidateSelection.!
updateClassOrganizerFrom: aString
    "Update my organizer according to aString"

    | anOrganizer storeString |

    storeString := '(ClassBasedOrganizer fromArray: #(', aString, '))'.
    anOrganizer := Compiler evaluate: storeString.
    anOrganizer isNil
        ifTrue: [^self].
    anOrganizer update.
    (self organizer owner = Smalltalk)
        ifTrue: [
            CodeFiler systemOrganizer: anOrganizer.
            SourceManager current logEvaluate: 'CodeFiler systemOrganizer: ', storeString.].
    self organizer: anOrganizer.
    self privateValidateSelection.!
updateMethodOrganizerFrom: aString
    "Update my selected class's method organizer according to aString"

    | anOrganizer storeString |

    self selectedClass isNil | (self selectedClasses size > 1)
        ifTrue: [^self].
    storeString := '(MethodBasedOrganizer fromArray: #(', aString, '))'.
    anOrganizer := Compiler evaluate: storeString.
    anOrganizer isNil
        ifTrue: [^self].
    anOrganizer
        owner: self selectedSmalltalkClassOrMetaclass;
        update;
        updateDefaultCategory.
    CodeFiler setOrganizerFor: self selectedClassOrMetaclass to: anOrganizer.
    SourceManager current logEvaluate:
        '(CodeFiler setOrganizerFor: ', self selectedClassOrMetaclass, ' to: ''', storeString, '''.'.
    self privateValidateSelection.! !

! NonRecordingChangeSet methods !  
= aChangeSet


    ^aChangeSet isNonRecordingChangeSet
!  
addItem: aChangeSetItem
!
allowChanges
    "Do nothing"
! 
annotationForItems: aCollection

    ^'no change'
!
byClassSortBlock

    ^[:a :b |
        a isClassBased
            ifTrue: [
                b isClassBased
                    ifTrue: [
                        a className = b className
                            ifTrue: [a class typeSortOrder <= b class typeSortOrder]
                            ifFalse: [a className < b className]]
                    ifFalse: [true]]
            ifFalse: [
                b isClassBased
                    ifTrue: [false]
                    ifFalse: [a title <= b title]]]
!
byTypeSortBlock

    ^[:a :b |
        a class typeSortOrder = b class typeSortOrder
            ifTrue: [self byClassSortBlock value: a value: b]
            ifFalse: [a class typeSortOrder < b class typeSortOrder]]
!  
changesAllowed
    "True, but I won't record them"

    ^true
!   
colorsForCategories: aCollection

    ^aCollection collect: [:each |
        (self includesCategory: each)
            ifTrue: [self includedColor]
            ifFalse: [self defaultColor]]!   
colorsForClasses: aCollection

    ^aCollection collect: [:each |
        ((self includesClass: each) or: [self includesClass: each, ' class'])
            ifTrue: [self includedColor]
            ifFalse: [self defaultColor]]

!  
colorsForMethods: methodCollection inClasses: classCollection

    | theItems |
    theItems := self methodItemsForClasses: classCollection.
    ^methodCollection collect: [:eachMethod |
        (theItems
            detect: [:eachItem | eachItem selector asString = eachMethod asString]
            ifNone: [nil]) isNil
                ifTrue: [self defaultColor]
                ifFalse: [self includedColor]]! 
colorsForProtocols: protocolCollection inClasses: classCollection

    | theItems organizer |
    theItems := self methodItemsForClasses: classCollection.
    ^protocolCollection collect: [:eachProtocol |
        (theItems
            detect: [:eachItem |
                organizer := CodeFiler organizerFor: eachItem smalltalkClassOrMeta.
                eachItem isRemoveMethod not and: [(organizer categoryOfElement: eachItem selector) = eachProtocol]]
            ifNone: [nil]) isNil
                ifTrue: [self defaultColor]
                ifFalse: [self includedColor]]
! 
comment
    "Answer my comment"

    ^''
!
comment: aString
    "Set my comment to be aString"
!   
copy
    "A copy of myself get a new timestamp"

    ^self species new
        name: self name;
        classNames: self classNames copy;
        items: self items copy
! 
defaultColor

    ^ClrBlack
!  
disallowChanges
    "Do nothing"
!  
exportOn: aStream
    "Export myself on aStream in such a way that when filed in
    I will be reconstructed"

    "NonRecordingChangeSets don't export themselves as anything"


!
exportOn: aStream with: aCodeFilerClass
    "Export myself on aStream with aCodeFilerClass. Exported change sets
    are recreated in the image they are filed into"

    "NonRecordingChangeSets don't export themselves as anything"


! 
fileOutOn: aStream with: aCodeFilerClass
!   
hash

    ^self class symbol hash
!
hierarchicalOrderOf: items
    "Private - Answer items in hierarchical order"

    ^(items asSortedCollection: [:a :b | b smalltalkClass withAllSuperclasses includes: a smalltalkClass]) asOrderedCollection
!   
includedColor

    ^BrowserView defaultChangeSetItemColor
!
includesCategory: categoryName

    ^false
!   
includesClass: className

    ^false
! 
isNonRecordingChangeSet

    ^true
!   
items
    ^#()
!
itemsForCategories: aCollection

    ^#()
!
itemsForClasses: aCollection

    ^#()
!   
itemsForMethods: methodCollection inClasses: classCollection

    ^#()
!   
itemsForProtocols: protocolCollection inClasses: classCollection

    ^#()
!   
itemsInClassSortOrder
    "   ^   <IndexedCollection withAll: <ChangeSetItem>>
    Answer a collection of change set items in type sort order."

    ^self items asSortedCollection: self byClassSortBlock
! 
itemsInFileOutOrder
    "   ^   <IndexedCollection withAll: <ChangeSetItem>>
    Answer a collection of change set items in file out order.
    File out order is:
        Class definitions first (in hierarchical order)
        Everything else"

    | reorderedItems selectBlock |

    selectBlock := [:each | each isClassDefinitionItem].

    reorderedItems := self hierarchicalOrderOf: (self items select: selectBlock).
    reorderedItems addAll: (self items reject: selectBlock).

    ^reorderedItems

! 
itemsInTypeSortOrder
    "   ^   <IndexedCollection withAll: <ChangeSetItem>>
    Answer a collection of change set items in type sort order."

    ^self items asSortedCollection: self byTypeSortBlock
!   
label

    ^self name
!
logChangeForAddProtocol: protocol before: beforeProtocol inClass: aClass

    self addItem: (ChangeSetAddProtocolItem new
        className: aClass name;
        protocol: protocol;
        beforeProtocol: beforeProtocol)
! 
logChangeForCategoryOrganization: string

    self addItem: (ChangeSetEvaluateItem new
        source:  '(CodeFiler systemOrganizer: (ClassBasedOrganizer fromArray: #(', string, ')))')
!
logChangeForClass: aClass

    self addItem: (ChangeSetClassDefinitionItem new
        className: aClass name)
!  
logChangeForClassComment: aClass

    self addItem: (ChangeSetClassCommentItem new
        className: aClass)
!   
logChangeForProtocolOrganization: string InClass: aClass

    self addItem: (ChangeSetEvaluateItem new
        source:  '(CodeFiler setOrganizerFor: ', aClass name, ' to: (MethodBasedOrganizer fromArray: #(', string, ')))')
! 
logChangeForRemoveClass: aClass

    self addItem: (ChangeSetRemoveClassItem new
        className: aClass name)
!
logChangeForRemoveProtocols: protocols inClass: aClass

    protocols do: [:each |
        self addItem: (ChangeSetRemoveProtocolItem new
            className: aClass name;
            protocol: each)]
!
logChangeForRemoveSelectors: selectors inClass: aClass

    selectors do: [:each |
        self addItem: (ChangeSetRemoveMethodItem new
            className: aClass name;
            selector: each)]
!  
logChangeForRenameProtocol: oldProtocol to: newProtocol inClass: aClass

    self addItem: (ChangeSetRenameProtocolItem new
        className: aClass name;
        protocol: newProtocol;
        oldProtocol: oldProtocol)
!  
logChangeForReorganizingClasses: classes intoCategories: categories

    classes do: [:each |
        self addItem: (ChangeSetClassReorganizationItem new
            className: each name;
            newCategories: categories)]
!   
logChangeForSelector: selector inProtocol: protocol inClass: aClass

    self addItem: (ChangeSetMethodItem new
        className: aClass name;
        protocol: protocol;
        selector: selector)
!   
methodItemsForClasses: aCollection

    ^#()
! 
name

    ^'Not Recording Changes'
!   
name: aString
!  
printOn: aStream

    aStream nextPutAll: self label!   
shallowCopy
    "Since non-recording change sets cannot be modified, just answer myself"

        ^self
! 
species

    ^NonRecordingChangeSet
!  
update
! !

! ChangeSet class methods !
new

    ^super new initialize! !

! ChangeSet methods !  
= aChangeSet

    aChangeSet species = self species
        ifFalse: [^false].

    aChangeSet isNonRecordingChangeSet
        ifTrue: [^false].

    creationDate = aChangeSet creationDate
        ifFalse: [^false].

    creationTime = aChangeSet creationTime
        ifFalse: [^false].

    ^name = aChangeSet name.
! 
addItem: aChangeSetItem
    "Add aChangeSetItem to myself.
    If I am not open for changes, then give the user the chance to do that."

    self changesAllowed ifFalse: [
        (MessageBox confirm: 'The change set "',self name, '" is not open for changes.\nWould you like to open it?' replaceEscapeCharacters)
            ifFalse: [^self].
        self allowChanges].

    (items includes: aChangeSetItem) ifTrue: [
        items remove: aChangeSetItem.
        classNames remove: aChangeSetItem className ifAbsent: []].
    items add: aChangeSetItem.
    aChangeSetItem owner: self.
    aChangeSetItem isClassBased
        ifTrue: [classNames add: aChangeSetItem className]
!   
allowChanges
    "Allow changes to be made to myself"

    changesAllowed := true
!   
annotationForItems: aCollection

    | latestItem |
    latestItem := (aCollection asSortedCollection: ChangeSetItem sortBlock) last.
    ^latestItem annotationLabel

!
changesAllowed
    "   ^   true | false
    Answer true if changes are permitted
    Nil is only possible because of a migration of old change sets to the new class definition"

    ^(changesAllowed isNil  or: [changesAllowed])
!   
classNames
    "Answer all of the classes of my items"

    ^classNames

!   
comment

    comment isNil
        ifTrue: [self comment: 'Comment for: ', self name].

    ^comment
!  
comment: aString
    comment := aString
!   
creationDate

    ^creationDate!
creationDate: aDate

    creationDate := aDate! 
creationTime

    ^creationTime!
creationTime: aTime

    creationTime := aTime! 
deepCopy
    "Answer a deep copy of myself with a new timestamp"

    ^super deepCopy
        initializeTimeStamp;
        yourself
!   
disallowChanges
    "Disallow changes to be added to myself"

    changesAllowed := false
!   
exportEpilogueOn: aStream
    "Private - Export code to complete loading myself in the the image I'm being filed in to"

    aStream nextPutAll:
'
    "If there is a changeSetManager in the image, then reconstruct myself as a changeSet"
    ((Smalltalk includesKey: #CodeFiler) and: [Smalltalk includesKey: #ChangeSetManager])
        ifTrue: [
            TemporaryJunkChangeSet disallowChanges.
            CodeFiler changeSetManager add: TemporaryJunkChangeSet.
            Smalltalk removeKey: #TemporaryJunkChangeSet] !!
'!   
exportInformationOn: aStream
    "Private - Export my vital information (name, timestamp) onto aStream"

    aStream
        nextPutAll: '                name: ', self name printString, ';'   ;cr;
        nextPutAll: '                creationDate: (Date fromString: ', self creationDate printString printString, ');'   ;cr;
        nextPutAll: '                creationTime: (Time fromString: ', self creationTime printString printString, ');'   ;cr;
        nextPutAll: '                comment: ', self comment printString, ';'   ;cr;
        nextPutAll: '                allowChanges] !!' ;cr.! 
exportItemEpilogueOn: aStream
    "Private - Export code to Begin a method full of items"

    aStream nextPutAll:
'                yourself] !!
'!  
exportItemPrologueOn: aStream
    "Private - Export code to Begin a method full of items"

    aStream nextPutAll:
'
    ((Smalltalk includesKey: #CodeFiler) and: [Smalltalk includesKey: #ChangeSetManager])
        ifTrue: [
            TemporaryJunkChangeSet
'!
exportItemsOn: aStream
    "Private - Export code to reconstruct all of my items on aStream. Do them only a few at a time
    because Digitalk won't file in large methods."

    | itemsPerMethod |
    itemsPerMethod := 50.
    1 to: items size by: itemsPerMethod do: [:startIndex |
    self exportItemPrologueOn: aStream.
    startIndex to: (startIndex + itemsPerMethod min: items size) do: [:index |
        aStream nextPutAll: '               addItem: '.
        (items at: index) exportOn: aStream.
        aStream
            nextPut: $;
            ;cr].
    self exportItemEpilogueOn: aStream]!
exportOn: aStream
    "Export myself on aStream in such a way that I will be
    reconstructed when aStream is filed in"

    self
        exportPrologueOn: aStream;
        exportInformationOn: aStream;
        exportItemsOn: aStream;
        exportEpilogueOn: aStream


!  
exportOn: aStream with: aCodeFilerClass
    "Export myself on aStream with aCodeFilerClass. Exported change sets
    are recreated in the image they are filed into"

    self
        fileOutOn: aStream with: aCodeFilerClass;
        exportOn: aStream.
!  
exportPrologueOn: aStream
    "Private - Export code to test whether or not there is a change set manager in the
    image I'm being imported to. If there is none, then the exported change set will be
    ignored"

    aStream
        nextPutAll:
'
    "If there is a changeSetManager in the image, then reconstruct myself as a changeSet"
    ((Smalltalk includesKey: #CodeFiler) and: [Smalltalk includesKey: #ChangeSetManager])
        ifTrue: [
            Smalltalk at: #TemporaryJunkChangeSet put: ChangeSet new.
            (Smalltalk at: #TemporaryJunkChangeSet)
'!  
fileOutOn: aStream with: aCodeFilerClass
    "Separate my items into those which must be filed out first and those which
    must be filed out last, and do them in that order"

    self itemsInFileOutOrder do: [:each |
        aStream cr; cr.
        each fileOutOn: aStream with: aCodeFilerClass]
!
hash

    ^name hash
! 
includesCategory: categoryName
    "   ^   true | false
    Answer true if I include the category named categoryName"

    | systemOrganizer |

    systemOrganizer := CodeFiler systemOrganizer.
    classNames do: [:each |
        (systemOrganizer isElement: each firstWord asSymbol inCategory: categoryName)
            ifTrue: [^true]].
    ^false!   
includesClass: className

    ^classNames includes: className
!
initialize

    self
        name: 'Unnamed';
        initializeTimeStamp.

    items := OrderedCollection new.
    classNames := Set new.
    self allowChanges
!   
initializeTimeStamp

    self
        creationTime: Time now;
        creationDate: Date today.
!
isNonRecordingChangeSet

    ^false
!  
items

    ^items!  
itemsForCategories: aCollection

    ^items select: [:eachItem |
        (aCollection select: [:eachCategory | eachItem includesCategory: eachCategory]) notEmpty]!
itemsForClasses: aCollection

    ^items select: [:eachItem |
        (aCollection select: [:eachClass | eachItem isClassBased and: [eachItem className = eachClass]]) notEmpty]
!
itemsForMethods: methodCollection inClasses: classCollection

    | theItems |
    theItems := self methodItemsForClasses: classCollection.
    ^theItems select: [:eachItem |
        methodCollection includes: eachItem selector asString]!   
itemsForProtocols: protocolCollection inClasses: classCollection

    | theItems organizer |
    theItems := self methodItemsForClasses: classCollection.
    ^theItems select: [:eachItem |
        organizer := CodeFiler organizerFor: eachItem smalltalkClassOrMeta.
        eachItem isRemoveMethod or: [protocolCollection includes: (organizer categoryOfElement: eachItem selector)]]
!
label

    | string |

    string := name, ' ', creationDate printString, ' ', creationTime printString asLowerCase.
    ^self changesAllowed
        ifTrue: ['(', string, ')']
        ifFalse: [string]
!  
methodItemsForClasses: aCollection

    ^items select: [:each |
        each isMethodItem and: [aCollection includes: each className]]

!
name

    ^name!
name: aString

    name := aString! 
printOn: aStream

    aStream nextPutAll: self label

!   
remove: anItem
    "Remove a changeSetItem from myself"

    self remove: anItem ifAbsent: [self error: 'No such change set item']
!  
remove: anItem ifAbsent: aBlock
    "Remove a changeSetItem from myself"

    items remove: anItem ifAbsent: aBlock
! 
shallowCopy
    "Answer a shallow copy of myself with a new timestamp"

    ^super shallowCopy
        initializeTimeStamp;
        yourself
!  
species

    ^ChangeSet
!  
update
    "Update my cached information to be consistent with my changes"

    self updateClassNamesCache
!  
updateClassNamesCache
    "Update my class name cache to be consistent with my changes"

    | newClassNames |

    newClassNames := Set new: classNames size.
    items do: [:each |
        each isClassBased
            ifTrue: [newClassNames add: each className]].

    classNames := newClassNames

! !

! Organizer class methods !
fromArray: array
    "Return an instance of me that has its organization set up like array."

    | result category categoryStream elementStream |

    result := self new.
    categoryStream := ReadStream on: array.
    [categoryStream atEnd] whileFalse: [
        elementStream := ReadStream on: categoryStream next.
        result addCategory: (category := elementStream next).
        [elementStream atEnd] whileFalse: [
            result addElement: elementStream next toCategory: category]].
    ^result!
new
    ^super new initialize! !

! Organizer methods !
addCategory: categoryName
    "Add a category named categoryName to myself"

    (self isKnownCategory: categoryName)
        ifFalse: [
            self categories add: categoryName.
            self makeDirty].
    (self categoryToElement includesKey: categoryName)
        ifFalse: [
            self categoryToElement at: categoryName put: Set new.
            self makeDirty].!  
addCategory: categoryName before: nextCategory
    "Add a category named categoryName to myself before the category named nextCategory"

    (self isKnownCategory: nextCategory)
        ifFalse: [^self addCategory: categoryName].
    self categories add: categoryName before: nextCategory.
    (self categoryToElement includesKey: categoryName)
        ifFalse: [
            self categoryToElement at: categoryName put: Set new.
            self makeDirty].!  
addElement: element toCategories: categoryNames
    "element    <object>
    categoryNames <collection of category names>
    Add element to each of categoryNames.  If I don't have a category, I'll create it."

    categoryNames do: [:eachCategory |
        self addElement: element toCategory: eachCategory]!   
addElement: anObject toCategory: categoryName
    "Add anObject to the category named categoryName.  If I don't have such a category, I'll create it."

    (self isKnownCategory: categoryName)
        ifFalse: [self addCategory: categoryName].
    (self categoryToElement at: categoryName) add: anObject.
    self makeDirty.!   
addElements: elements toCategories: categoryNames
    "elements   <collection of objects>
    categoryNames <collection of category names>
    Add the objects in elements to each of categoryNames.  If I don't have a category, I'll create it."

    categoryNames do: [:eachCategory |
        elements do: [:eachElement |
            self addElement: eachElement toCategory: eachCategory]]!   
categories
    "Answer my categories, in order"

    ^categories!  
categoriesOfElement: anObject
    "Answer a collection with all the categories to which anObject belongs"

    | answer |

    answer := OrderedCollection new.
    self categoryToElement keysAndValuesDo: [:categoryName :categoryContents |
        (categoryContents includes: anObject)
            ifTrue: [answer add: categoryName]].
    ^answer!   
categoryOfElement: anObject
    "^ <aString> | nil
    Answer the first category to which anObject belongs"

    | answer |

    answer := self categoriesOfElement: anObject.
    ^answer notEmpty
        ifTrue: [answer first]
        ifFalse: [nil]!   
categoryToElement
    "Private - Answer the mapping from my categories to my elements"

    ^categoryToElement!
defaultCategory
    ^'uncategorized'!
editString
    "Return a string that has all of my categories one per line
    with brackets around them."

    ^self editStringForCategories: self categories!   
editStringForCategories: selectedCategories
    "selectedCategories        <Collection withAll: <Symbol>>
        ^                           <String>
    Answer a string with the named categories, and their contents listed
    one per line with brackets around each one"

    | stream |
    stream := WriteStream on: (String new: 64).
    self categories do: [:category |
        (selectedCategories includes: category) ifTrue: [
            stream
                nextPut: $(;
                nextPutAll: category storeString.
            (self elementsOfCategory: category) do: [:element |
                stream
                    space;
                    nextPutAll: element].
            stream
                nextPut: $);
                cr]].
    ^stream contents!  
editStringForElements: elements
    "elements        <Collection withAll: <Symbol>>
        ^                           <String>
    Answer a string with the categorization of the named elements"

    | stream selectedCategories |
    stream := WriteStream on: (String new: 64).

    selectedCategories := Set new.
    elements do: [:each |
        selectedCategories add: (self categoriesOfElement: each)].

    self categories do: [:category |
        (selectedCategories includes: category) ifTrue: [
            stream
                nextPut: $(;
                nextPutAll: category storeString.
            ((self elementsOfCategory: category) select: [:each | elements includes: each]) do: [:element |
                stream
                    space;
                    nextPutAll: element].
            stream
                nextPut: $);
                cr]].
    ^stream contents
!   
elements
    "Answer all of my elements in all of my categories"

    | answer |

    answer := OrderedCollection new: (self categoryToElement size * 10).
    self categoryToElement do: [:each |
        answer addAll: each].
    ^answer.!
elementsOfCategory: categoryName
    "Answer the set of elements of the category named categoryName"

    (self isKnownCategory: categoryName)
        ifFalse: [self error: 'unknown category: ', categoryName].
    ^self categoryToElement at: categoryName!  
initialize

    categoryToElement := Dictionary new.
    categories := OrderedCollection new.
    self makeDirty.!
isDirty
    "   ^   true | false
    Answer whether or not I have been changed"

    ^dirty!  
isElement: element inCategory: aCategory
    "   ^   true | false
    Answer true if element is in aCategory"

    ^(categoryToElement at: aCategory ifAbsent: [^false]) includes: element
! 
isKnownCategory: categoryName
    "Answer whether or not I know about a category named categoryName"

    ^categories includes: categoryName!  
makeClean
    "Private - Make myself not dirty anymore"

    dirty := false!   
makeDirty
    "Private - Make myself dirty"

    dirty := true!
notDirty
    "   ^   true | false
    Answer whether or not I have been changed"

    ^self isDirty not!  
organizationFor: elements
    "   ^   <Array withAll: organizationCollection>
            organizationCollection:     <Array with: category withAll: elements>
    Answer an array of arrays which shows the organization of elements.
    Structured like the editString"

    | foundCategories organization answer|

    answer := OrderedCollection new.
    foundCategories := (elements inject: Set new into: [:sum :each |
        sum addAll: (self categoriesOfElement: each); yourself]).
    foundCategories := self categories select: [:each |
        foundCategories includes: each].
    foundCategories do: [:each |
        organization := OrderedCollection new.
        organization
            add: each;
            addAll: ((self elementsOfCategory: each) select: [:element |
                elements includes: element]).
        answer add: organization asArray].
    ^answer asArray!   
owner
    ^owner!
owner: anObject
    owner := anObject.!  
printOn: aStream

    aStream
        print: self class;
        nextPut: $(;
        print: self owner;
        nextPut: $)!   
removeCategories: categoryNames
    "categoryNames: <collection of strings>
    Remove the categories named in categoryNames"

    categoryNames do: [:each |
        self removeCategory: each ifAbsent: [self error: 'No category named ', each]]! 
removeCategory: categoryName
    "Remove the category named categoryName.
    If it isn't there, evaluate an error"

    self removeCategory: categoryName ifAbsent: [self error: 'No category named ', categoryName]!
removeCategory: categoryName ifAbsent: errorBlock
    "Remove the category named categoryName.  If it isn't there, evaluate errorBlock"

    self categories remove: categoryName ifAbsent: errorBlock.
    self categoryToElement removeKey: categoryName.
    self makeDirty.! 
removeElement: anObject
    "Remove anObject from all of my categories"

    ^self removeElement: anObject fromCategories: (self categoriesOfElement: anObject)!   
removeElement: anObject fromCategories: aCollectionOfCategoryNames
    "Remove anObject from the named categories"

    ^aCollectionOfCategoryNames do: [:each |
        self removeElement: anObject fromCategory: each]!
removeElement: anObject fromCategory: categoryName
    "Remove anObject from the category named categoryName."

    (self isKnownCategory: categoryName)
        ifFalse: [self error: 'no category named ', categoryName].
    (self categoryToElement at: categoryName)
        remove: anObject
        ifAbsent: [self error: 'object not in category'].
    self makeDirty.! 
removeElements: objects
    "objects    <collection of objects>
    remove the contents of objects from each of their categories."

  objects do: [:each |
        self removeElement: each fromCategories: (self categoriesOfElement: each)]!   
rename: oldCategoryName to: newCategoryName
    "Assumes that oldCategoryName exists."

    self categories at: (self categories indexOf: oldCategoryName) put: newCategoryName.
    self categoryToElement
        at: newCategoryName
        put: (self categoryToElement at: oldCategoryName);
        removeKey: oldCategoryName.
    self makeDirty.!   
reorganize: elements into: newCategories
    "elements   <collection of objects>
    newCategories <collection of strings>
    Make every object in elements a member of only those categories in newCategories"

    "first step is to primitively remove every element from its categories"
    elements do: [:each |
        (self categoriesOfElement: each) do: [:category |
            (self categoryToElement at: category) remove: each ifAbsent: [nil]]].
    "next, add elements to their new categories"
    self addElements: elements toCategories: newCategories.
    self updateDefaultCategory.
    self makeDirty.! 
reorganizeFrom: collection
    "collection     <Collection withAll: organizationCollection>
                    organizationCollection      <Collection with: category withAll: elementsOfCategory>
    Reorganize myself so that category contains elementsOfCategory
    for each organizationCollection"

    collection do: [:each |
        self addElements: (each copyFrom: 2 to: each size) toCategories: (Array with: each first)]!   
storeOn: stream
    "Put a string onto stream that will, when evaluated, return
    an instance equal to me in structure."

    stream
        nextPutAll: '((';
        nextPutAll: self class name;
        nextPutAll: ' fromArray: #(';
        cr;
        nextPutAll: self editString trimBlanks;
        nextPutAll: '))';
        nextPutAll: 'owner: ';
        store: self owner;
        nextPut: $; ;
        cr;
        nextPutAll: 'name: ';
        store: self name;
        nextPut: $);
        cr.! 
update
    "Update myself.  I don't do anything interesting with this.  My subclasses do"!   
updateDefaultCategory
    "if there are no elements in my default category, then remove it."

    ((self isKnownCategory: self defaultCategory)
        and: [(self elementsOfCategory: self defaultCategory) isEmpty])
            ifTrue: [self removeCategory: self defaultCategory]! !

! ClassBasedOrganizer methods !
defaultCategory
    ^'No Category Classes'!  
initialize

    super initialize.
    self owner: Smalltalk!   
isNameOfValidClass: className
    "Return true if the given symbol is a name for a valid class in Smalltalk."

    | theClass |
    (Smalltalk includesKey: className)
        ifFalse: [^false].

    theClass := Smalltalk at: className.
    theClass isBehavior
        ifFalse: [^false].
    ^theClass name asString = className asString!
reorganize: elements into: newCategories
    "elements   <collection of objects>
    newCategories <collection of strings>
    Make every object in elements a member of only those categories in newCategories.
    Log these changes to the change log."

    | changeLog result |

    (changeLog := Sources at: 2) setToEnd.
    result := super reorganize: elements into: newCategories.
    SourceManager current logEvaluate: 'CodeFiler systemOrganizer reorganize: #',
        elements asArray printString,
        ' into: #', newCategories asArray printString.
    ^result!   
update
    "Make sure that all of the classes in my categories are indeed classes in Smalltalk, and that all
    classes in Smalltalk are categorized."

     | uncategorized allClassNames |

    super update.
    self notDirty
        ifTrue: [^self].

    self elements do: [:each |
        (self isNameOfValidClass: each)
            ifFalse: [self removeElement: each fromCategories: (self categoriesOfElement: each)]].

    allClassNames := (Smalltalk rootClasses inject: OrderedCollection new into: [:sum :each |
            sum, (each withAllSubclasses collect: [:aClass | aClass symbol])]).

    uncategorized := allClassNames copy.
    self elements do: [:each |
        uncategorized remove: each ifAbsent: [nil]].
    uncategorized notEmpty
        ifTrue: [
            uncategorized do: [:each |
                self addElement: each toCategory: self defaultCategory]].
    self
        updateDefaultCategory;
        makeClean.! !

! MethodBasedOrganizer class methods !   
for: aClassOrMeta

    ^self new
        owner: aClassOrMeta;
        privateBuildAllUncategorized! !

! MethodBasedOrganizer methods ! 
addElement: selector toCategory: categoryName
    "Add selector to the protocol named category name.  Since, a method
    may appear in only one protocol, first remove that selector from any
    protocols in which it now appears"

    self
        removeElement: selector
        fromCategories: (self categoriesOfElement: selector).
    ^super addElement: selector toCategory: categoryName!   
defaultCategory
    "Answer the default category to use"

    ^'no category methods'!  
initialize

    super initialize.
    self owner: Object!  
owner: anObject
    "Set my owner, and create a default categorization for his selectors"

    super owner: anObject.! 
privateBuildAllUncategorized
    "Private - make all of my owners methods uncategorized"

    self
        addElement: self owner selectors any
        toCategory: self defaultCategory.
    self categoryToElement
        at: self defaultCategory
        put: (Set new addAll: self owner selectors).
    self makeClean!   
removeCategory: protocol ifAbsent: aBlock
    "Remove all of the methods in protocol, and then remove the protocol"

   (self elementsOfCategory: protocol) do: [:selector |
        self owner removeSelector: selector.
        SourceManager current logEvaluate:
            self owner name, ' removeSelector: #', selector].
    super removeCategory: protocol ifAbsent: aBlock.!   
removeElement: aMethodSelector
    "Remove aMethodSelector from all of my categories, and from my owner"

    self owner removeSelector: aMethodSelector.
    SourceManager current logEvaluate:
        owner name, ' removeSelector: #', aMethodSelector.
    ^super removeElement: aMethodSelector.! 
reorganizeFrom: collection
    "collection     <Collection withAll: organizationCollection>
                    organizationCollection      <Collection with: category withAll: elementsOfCategory>
    Reorganize myself so that category contains elementsOfCategory
    for each organizationCollection.
    Log the reorganization to the change log."

    | methods changeLog |

    (changeLog := Sources at: 2) setToEnd.
    super reorganizeFrom: collection.
    methods := collection inject: OrderedCollection new into: [:sum :each |
        sum addAll: (each copyFrom: 2 to: each size); yourself].
    (CodeFiler forClass: self owner)
        fileOutOrganizationFor: methods on: changeLog.
    changeLog flush.! 
update
    "Make sure that all my owner's methods are categorized, and that
    I don't have any methods which no longer exist in my owner. if there
    are no methods in my default category, then remove it."

    | elements |

    super update.
    self notDirty
        ifTrue: [^self].

    elements := self elements.
    (self owner selectors reject: [:each | elements includes: each]) do: [:each |
        self addElement: each toCategory: self defaultCategory].

    (elements reject: [:each | self owner selectors includes: each]) do: [:each |
        self removeElement: each fromCategories: (self categoriesOfElement: each)].
    self
        updateDefaultCategory;
        makeClean! !

! ParcPlaceClassReader class methods !  
for: class protocol: protocol
    "   class       <Behavior>
        protocol    <String>
        ^       self
    Return an instance hooked to class."

    ^super new forClass: class; protocol: protocol!
new
    "   ^   self
    This is an error, you must use for:."

    self error: 'Use for:protocol:'! !

! ParcPlaceClassReader methods !
fileInFrom: stream
    "   stream  <ReadStream>
        ^       self
    Read chunks from aStream until an empty chunk (a single '!!') is found.
    Compile each chunk as a method for the class I describe.
    Log the source code of the method to the change log."

    | chunk result changeLog selectors codeFiler |

     selectors := OrderedCollection new.

    changeLog := (Sources at: 2)
        setToEnd;cr;
        yourself.

    (codeFiler := CodeFiler forClass: self forClass) fileOutPreambleOn: changeLog.
    [(chunk := stream nextChunk) isEmpty] whileFalse: [
        result := class compile: chunk.
        result notNil ifTrue: [
            result value sourceString: chunk.
            selectors add: result key]].

    changeLog nextPutAll: ' !!'.
    codeFiler methodOrganizer reorganize: selectors into: (Array with: self protocol).
    codeFiler fileOutOrganizationFor: selectors on: changeLog.
    changeLog flush!   
forClass
    "   ^       self
    Return my class field."

    ^class!
forClass: newClass
    "   class   <Behavior>
        ^       self
    Set my class field."

    class := newClass!  
protocol
    "   ^   <String>
    Return my protocol."

    ^protocol!
protocol: newProtocol
    "   newProtocol     <String>
    Set my protocol."

    protocol := newProtocol! !

! Pattern methods !   
matches: aString
    "Return true if the receiver matches to aString.  To match, the pattern must map directly to the string."

    | match |
    match := self match: aString index: 1.
    ^(match notNil and: [(match x = 1) & (match y = aString size)])! !

! Person class methods !  
example1
    "Person example1"
    | john mary |
    john := Person new
        firstName: 'John'; lastName: 'Smith';
        company: 'The Company'; title: 'vice president'.
    mary := Person new
        firstName: 'Mary'; lastName: 'Jones';
        company: 'The Competitor'; title: 'president'.
    john spouse: mary.
    mary spouse: john.
    ^john!
new
    ^super new initialize! !

! Person methods !   
initialize
    self
        firstName: '';
        lastName: '';
        company: '';
        title: '';
        spouse: nil!   
spouse

    ^spouse!
spouse: aPerson

    spouse := aPerson! !

! Point methods !  
translateBy: delta
        "Answer a Point which is the receiver with
         position incremented by delta, where delta is
         either a Number or a Point."
    ^self rightAndDown: delta! !

! Rectangle methods !  
centerIn: aRectangle
    "Return a new rectangle that is the extent of the receiver, centered in aRectangle."
    | new |
    new := 0@0 extent: self extent.
    ^new translateBy:
        (aRectangle center - new center)!
mappingTo: aRectangle
        "Creates a mapping rectangle (leftTop will be the translation
        and extent will be the scale)"
    | scale translation |
    scale := aRectangle extent / self extent.
    translation := aRectangle leftTop - (self leftTop * scale).
    ^Rectangle
        leftTop: translation
        extent: scale! 
mapUsing: mappingRectangle
    | scale translation |
    scale := mappingRectangle extent.
    translation := mappingRectangle leftTop.
    ^Rectangle
        leftTop: self leftTop * scale + translation extent: self extent * scale!  
truncateTo: delta
    ^Rectangle
        leftTop: (self leftTop truncateTo: delta)
        rightBottom: (self rightBottom truncateTo: delta)! !

! SmalltalkToolInterface methods !  
initialize
        "Private - Initialize the receiver."
    self
        textWindowClass: #TextWindow;
        textPaneClass: #TextPane;
        windowPolicyClass: #SmalltalkWindowPolicy;
        resourceFileName: 'vres', SmalltalkLibrary versionAndPlatformExtension
! !

! SourceManager methods !
compressChangeSetsInto: stream
    "Place a doit chunk capable of recreating all the change sets in the image onto aStream."

    ((Smalltalk includesKey: #CodeFiler) and: [Smalltalk includesKey: #ChangeSetManager]) ifTrue: [
        CodeFiler changeSetManager changeSets do: [:each |
            each exportOn: stream]].
! 
compressOrganizationInto: stream
    "Place a doit chunk capable of reorganizing the system organization to look identical to the current
    organization"

    stream
        nextPutAll: 'CodeFiler systemOrganizer: (ClassBasedOrganizer fromArray: #(';
        cr; nextPutAll: CodeFiler systemOrganizer editString;
        cr; nextPutAll: ')) !!'
!  
newCompressChanges
        "Build a new change log file retaining
         only the latest version of changed
         methods in the current change log.
         Save the image to the image file."
    | logDirectory stream tempLogName dialog allClasses class |

    ( SessionModel testDiskSpaceRequiredToCompressChanges: BackupImage )
        ifFalse: [ ^self ].

    BackupImage
        ifTrue: [ self backupChanges
            ifFalse: [ ^self error: 'Error backing up change.log' ]].
    dialog := ProgressIndicatorDialog new
        noCancel;
        open: WindowLabelPrefix message: 'Compressing Changes...'.

    logDirectory := (Sources at: 2) file directory.
    stream := logDirectory newFile: 'ChangLog.tmp'.
    stream lineDelimiter: Cr.
    tempLogName := stream pathName.
    self newCompressClassDefinitionsInto: stream.
    allClasses := self getSourceClasses.
    1 to: allClasses size do: [:index |
        class := allClasses at: index.
        self newCompressChangesOf: class class into: stream.
        self newCompressChangesOf: class into: stream.
    dialog percent: ( index / allClasses size * 100 ) truncated].

    "Now save the system organization and all change sets"
    self
        compressOrganizationInto: stream;
        compressChangeSetsInto: stream.

    stream close.
    (Sources at: 2) close.
    File remove: (Sources at: 2) pathName.
    File
        rename: tempLogName
        to: (Sources at: 2) pathName.
    Sources
        at: 2
        put: (logDirectory file: (Sources at: 2) file name).
    (Sources at: 2) lineDelimiter: Cr.
    dialog message: 'Saving Image File...';
        percent: 0;
        percent: 100;
        close.
    SessionModel current saveSession.
!  
newCompressChangesOf: aClass into: aStream
    "Added by Wayne.
     Private - Write latest version of all methods in aClass that are in the
     change log to aStream.  Be sure to write the protocol header."

    | methods compiledMethod writer |

    methods := OrderedCollection new: 50.
    aClass selectors asSortedCollection do: [:selector |
        compiledMethod := aClass compiledMethodAt: selector.
        compiledMethod sourceIndex = 2
            ifTrue: [methods add: compiledMethod]].

    methods isEmpty
        ifTrue: [^self].

    writer := (Smalltalk at: #CodeFiler) forClass: aClass.
    writer fileOutPreambleOn: aStream.
    methods do: [:method |
        aStream cr.
        self putMethod: method withIndex: 2 to: aStream].

    aStream nextPutAll: ' !!';cr.
    writer fileOutOrganizationFor: aClass selectors on: aStream!  
newCompressClassDefinitionsInto: aStream
    | headerPattern classPattern index classes className chunk changeFile |
    classes := Set new.
    headerPattern := Pattern new: '"define class"'.
    classPattern := Pattern new: 'class: #'.
    changeFile := (Sources at: 2).
    changeFile reset.
    [changeFile atEnd] whileFalse: [
        chunk := changeFile nextChunk trimBlanks.
        chunk isEmpty
            ifFalse: [
                (chunk firstWord = '"define' and: [(headerPattern match: chunk index: 1) notNil])
                    ifTrue: [
                        (index := classPattern match: chunk index: 1) notNil ifTrue: [
                            className := (chunk copyFrom: index y + 1 to: chunk size) firstWord asSymbol.
                            (Smalltalk includesKey: className)
                                ifTrue: [classes add: (Smalltalk at: className)]]]]].

    (classes asSortedCollection: [:a :b | a allSuperclasses size <= b allSuperclasses size])
        do: [:aClass |
            aStream cr; cr; nextPutAll: '"define class"'; cr.
            ((Smalltalk at: #CodeFiler) forClass: aClass) fileOutDefinitionOn: aStream]! 
recoverFromLastNthSave: n
    "   n   <Integer>
    System Extension
    Create a file called 'recovery.st' that contains the changes from the point
    the image was saved n - 1 times before the last save."
    "Smalltalk recoverFromLastNthSave: 2"

    | filename file |
    filename := 'recovery.st'.
    self recoverFromLastNthSave: n intoFilenamed: filename.
    file := Disk file: filename.
    TextWindow new sendInputEvent: #openOnFile: with: file.
    file close!  
recoverFromLastNthSave: n intoFilenamed: filename
    "   n   <Integer>
        filename    <String>
    System Extension
    Create a file called filename that contains the changes from the point
    the image was saved n - 1 times before the last save."
    "Smalltalk recoverFromLastNthSave: 2"

    | file |
    file := Disk newFile: 'recovery.st'.
    self recoverFromLastNthSave: n intoStream: file.
    file close!  
recoverFromLastNthSave: n intoStream: stream
    "   n   <Integer>
        stream  <WriteStream>
    System Extension
    Add the changes from the point the image was saved n - 1 times before the last save."
    "Smalltalk recoverFromLastNthSave: 2"

    | where log searchBack readLimit localWhere |
    log := Sources at: 2.
    log setToEnd.
    searchBack := 5000.  "initial estimate"
    readLimit := log readLimit.
    where := OrderedCollection new.
    [   localWhere := OrderedCollection new.
        log position: (readLimit - searchBack max: 0).
        log position to: readLimit - 20 do: [:pos |
            log next = $* ifTrue: [
                (log next: 18) = '** saved image on:' ifTrue: [
                    localWhere add: pos - 2].   "the open-comment quote"
                log position: pos + 1]].  "remember the 'next'."
        readLimit > 0 and: [(where size + localWhere size) < n]
    ] whileTrue: [
        where addAll: localWhere reversed.
        readLimit := readLimit - searchBack + 20.
        "searchBack := searchBack * 4"].
    where addAll: localWhere reversed.
    where := where size < n
        ifTrue: [0]
        ifFalse: [where at: n].
    log position: where.
    [log atEnd] whileFalse: [
        stream nextPutAll: log nextLine;
        cr]!   
recoverFromLastSave
    "   ^   self
    System Extension
    Create a file called 'recovery.st' that contains the changes made since the last
    save was done."

    self recoverFromLastNthSave: 1! !

! Stream methods ! 
skipSeparators
        "Skip over any separators"
    [ self atEnd not and: [ self next isSeparator ] ]
        whileTrue: [ ].
    self atEnd ifFalse: [ self position: self position - 1 ]! !

! WriteStream methods !
print: anObject
    "Ask anObject to print itself on self"

    ^anObject printOn: self!   
store: anObject
    "Ask anObject to store itself on self"

    ^anObject storeOn: self! !

! UndefinedObject methods !  
subclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    categories: categories
        "Create or modify the class classSymbol to be
         a subclass of the receiver with the specifed
         instance variables, class variables, and pool
         dictionaries."

    | result |
    result := self
        subclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames.
    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [
            (Smalltalk at: #CodeFiler) systemOrganizer
                removeElement: classSymbol;
                addElement: classSymbol toCategories: categories].
    ^result!   
subclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    category: category
        "Create or modify the class classSymbol to be
         a subclass of the receiver with the specifed
         instance variables, class variables, and pool
         dictionaries."

    ^self
        subclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames
        categories: (Array with: category)!   
variableByteSubclass: classSymbol
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    categories: categories
        "Create or modify the class classSymbol to be
         a variable byte subclass of the receiver with the
         specified class variables and pool dictionaries."

    | result |
    result := self
        variableByteSubclass: classSymbol
        classVariableNames: classVariables
        poolDictionaries: poolDictNames.
    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [
            (Smalltalk at: #CodeFiler) systemOrganizer
                removeElement: classSymbol;
                addElement: classSymbol toCategories: categories].
    ^result!   
variableByteSubclass: classSymbol
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    category: category
        "Create or modify the class classSymbol to be
         a variable byte subclass of the receiver with the
         specified class variables and pool dictionaries."

    ^self
        variableByteSubclass: classSymbol
        classVariableNames: classVariables
        poolDictionaries: poolDictNames
        categories: (Array with: category)!   
variableByteSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be
        a variable byte subclass of the receiver with the
        specified class variables, instance variables, and
        pool dictionaries."
    | installer |
    installer := ClassInstaller
        name: className
        environment: ClassInstaller defaultGlobalDictionary
        subclassOf: self
        instanceVariableNames: instanceVariables
        variable: true
        pointers: false
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries.
    ^installer install!   
variableSubclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    categories: categories
        "Create or modify the class classSymbol to be a
         variable subclass of the receiver with the specifed
         instance variables, class variables, and pool dictionaries."

    | result |
    result := self
        variableSubclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames.
    (Smalltalk includesKey: #CodeFiler)
        ifTrue: [
            (Smalltalk at: #CodeFiler) systemOrganizer
                removeElement: classSymbol;
                addElement: classSymbol toCategories: categories].
    ^result!
variableSubclass: classSymbol
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictNames
    category: category
        "Create or modify the class classSymbol to be a
         variable subclass of the receiver with the specifed
         instance variables, class variables, and pool dictionaries."

    ^self
        variableSubclass: classSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictNames
        categories: (Array with: category)! !

! ViewManager methods !   
compressChanges
    "Compress the change log."

    self mainView compressChanges! 
compressSources
    "Compress the changes into the sources file."

    self mainView compressSources

!  
implementorsOfSelection

    self mainView implementorsOfSelection
!   
openNavigatorBrowser
        "The user selected Browse Classes from the Smalltalk
        menu."
    (Smalltalk at: #BrowserView) openOnSystem
!  
referencesOfSelection

    self mainView referencesOfSelection
!   
restore
    "Ask my mainView to restore itself"

    ^self mainView restore!   
sendersOfSelection

    self mainView sendersOfSelection
! !

! BrowserView class methods !  
defaultChangeSetItemColor

    ^self defaults at: #changeSetItemColor ifAbsent: [ClrRed]
! 
defaultProtocols

    ^#(
'accessing'
'comparing'
'copying'
'initializing'
'modifying'
'testing'
'private'
'printing'
'scheduling'
'instance creation'
) copy

!   
defaults
    "   ^       <Dictionary>
    Answer a dictionary with the default values for all browsers"

    Defaults isNil
        ifTrue: [self initializeDefaults].
    ^Defaults!   
iconId
        "Answer the icon id for this window class."
    ^2

!  
initializeDefaults
    "(self initializeDefaults)
    Initialize my defaults dictionary"

    Defaults := Dictionary new

        "This is updated when you select a protocol"
        at: #previousProtocol put: String new;

        "These are a history of the last things you typed into various dialog boxes"
        at: #previousCategories put: OrderedCollection new;
        at: #previousClasses put: OrderedCollection new;
        at: #previousProtocols put: OrderedCollection new;

        "This is how many of previous things to remember"
        at: #numberOfHistoryItems put: 10;

        "This is the color for change set items"
        at: #changeSetItemColor put: ClrBlue;

        yourself
!
merge: aString intoHistory: aCollection withSize: maximum
    "If aString appears in aCollection, then remove it. Place aString at the begining of aCollection.
    If aCollection is now too big, then remove the last item in it."

    (aCollection includes: aString)
        ifTrue: [aCollection remove: aString].

    aCollection addFirst: aString.
    aCollection size > maximum
        ifTrue: [aCollection removeLast].
! 
new: aCodeBrowser
    ^super new initializeWithCodeBrowser: aCodeBrowser
!  
numberOfHistoryItems
    ^self defaults at: #numberOfHistoryItems
! 
openOn: aCodeBrowser
    "Open a BrowserView on a codeBrowser browsing the system classes"

    ^(self new: aCodeBrowser)
        open
! 
openOnSystem
    "Open a BrowserView on a codeBrowser browsing the system classes"

    ^self openOn: (NavigatorBrowser new organizer: CodeFiler systemOrganizer update)
!
paneUpdateMessages
    "Answer the update message names (symbols) to update the panes in the correct order"

    ^#(updateChangeSet updateCategories updateClasses updateProtocols
    updateLabel updateMethods updateAnnotation updateChangeSetAnnotation)! 
paneUpdateOrder
    "Answer the methods to update the panes in the correct order"

    ^#('changeSet' 'categories' 'classes' 'protocols' 'label' 'methods' 'annotation' 'changeSetAnnotation')
!  
previousCategories
    ^self privatePreviousCategories copy
        add: '-----------------------------------';
        yourself
!
previousClass
    "   ^   <String>
    Answer the previously selected class"

    | classes |

    classes := self previousClasses.
    ^classes notEmpty
        ifTrue: [classes first]
        ifFalse: [String new]
!   
previousClasses
    ^self defaults at: #previousClasses
!   
previousProtocol
    "   ^   <String>
    Answer the previously selected protocol"

    ^self defaults at: #previousProtocol
!   
previousProtocol: protocol
    "protocol   <String>
    Set the previously selected protocol"

    ^self defaults at: #previousProtocol put: protocol.
! 
previousProtocols

    | answer |

    answer := self privatePreviousProtocols copy.
    self defaultProtocols do: [:each |
        (answer includes: each)
            ifFalse: [answer addLast: each]].

    ^answer
!
privatePreviousCategories
    ^self defaults at: #previousCategories
!  
privatePreviousProtocols
    ^self defaults at: #previousProtocols
!
rememberCategory: category
    "category       <String>
    Place category in my history of remembered categories.
    If category begins with a dash, then it is a separator line: don't bother remembering it"

    category first = $-
        ifTrue: [^self].

    self merge: category intoHistory: self privatePreviousCategories withSize: self numberOfHistoryItems
!   
rememberClass: className
    "className       <String>
    Place className in my history of remembered classes"

    self merge: className intoHistory: self previousClasses withSize: self numberOfHistoryItems
!   
rememberProtocol: protocol
    "protocol       <String>
    Place protocol in my history of remembered protocols"

    self
        merge: protocol
        intoHistory: self privatePreviousProtocols
        withSize: self numberOfHistoryItems + self defaultProtocols size
! !

! BrowserView methods !
acceptForViewingChangeSetComment: pane
    "Accept a new comment for the currently change set"

    changeSet comment: pane contents.
    pane modified: false.
    self updateText
!   
acceptForViewingClassComment: pane
    "Accept a class comment for the currently selected class"

    CodeFiler setCommentFor: codeBrowser selectedClass to: pane contents.
    changeSet logChangeForClassComment: codeBrowser selectedClass.
    pane modified: false.
    self updateChangeSet

!  
acceptForViewingClassDefinition: pane
    "Accept a class definition for the currently selected class"

    | result |
    CursorManager execute changeFor: [
        result := Compiler
         evaluate: pane contents
            in: nil class
            to: nil
            notifying: pane
           ifFail: [nil]].
    pane modified: (result isKindOf: Class) not.
    result isNil ifTrue: [^self].
    SourceManager current logEvaluate: pane contents.
    codeBrowser selectedClasses: (Array with: result symbol trimBlanks asString).
    changeSet logChangeForClass: result.
    currentItems := changeSet itemsForCategories: codeBrowser selectedCategories.
    changeSet isNonRecordingChangeSet
        ifTrue: [self updatePanesFrom: 'classes']
        ifFalse: [self update]
! 
acceptForViewingClassOrganization: aPane
    "Accept the class organizer organization from aPane, and update all of my panes
    However, if the pane contents look more like a class definition than an organization, then try
    to compile as a class definition instead."

    "Does it look like a class definition?"
    aPane contents trimBlanks first ~= $(
        ifTrue: [^self acceptForViewingClassDefinition: aPane].

    "No, it looks like an organizer"
    codeBrowser updateClassOrganizerFrom: aPane contents.
    aPane modified: false.
    self update
!   
acceptForViewingMethodOrganization: aPane
    "Accept the selected class's method organization from aPane, and update my panes.
    However, if the pane contents look more like a method than an organization, then try
    to compile them as a method instead."

    | contents |

    (contents := aPane contents trimBlanks) isEmpty
        ifTrue: [contents := ' '].
    "Does it look like a method?"
    contents first ~= $(
        ifTrue: [^self acceptForViewingMethodSource: aPane].

    "No, it looks like an organizer"
    codeBrowser updateMethodOrganizerFrom: contents.
    changeSet logChangeForProtocolOrganization: contents InClass: codeBrowser selectedSmalltalkClassOrMetaclass.
    aPane modified: false.

    changeSet isNonRecordingChangeSet
        ifTrue: [self updatePanesFrom: 'protocols']
        ifFalse: [self update]
!  
acceptForViewingMethodSource: aPane
    "Accept source code for the currently selected method"

    | result codeFiler oldMethod theClass protocol previousSourcePosition selector defaultProtocol sourceString |

    CursorManager execute changeFor: [
        theClass := Smalltalk at: codeBrowser selectedClass asSymbol.
        codeBrowser isBrowsingClassMethods
            ifTrue: [theClass := theClass class].

        codeFiler := CodeFiler forClass: theClass.
        selector := codeFiler selectorFor: aPane contents.
        (theClass selectors includes: selector) ifTrue: [
            oldMethod := theClass compiledMethodAt: selector.

            "Old method isn't in the change log? Save it there first..."
            oldMethod sourceIndex = 2 ifFalse: [
                codeFiler
                    logSource: (theClass sourceCodeAt: selector)
                    forSelector: selector
                    withPreviousSourcePosition: nil].
            previousSourcePosition := oldMethod sourcePosition].

        sourceString := aPane contents trimBlanks.
        result := theClass compile: sourceString notifying: aPane].
    result isNil
        ifTrue: [aPane modified: true]
        ifFalse: [
            aPane modified: false.
            codeFiler
                logSource: sourceString
                forSelector: result key
                withPreviousSourcePosition: previousSourcePosition.
            protocol := self protocolForSelector: result key.

            changeSet logChangeForSelector: result key inProtocol: protocol inClass: theClass.
            currentItems := changeSet
                itemsForMethods: (Array with: result key asString)
                inClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
            changeSet isNonRecordingChangeSet
                ifTrue: [self updatePanesFrom: 'methods']
                ifFalse: [self update]].
    ^result
!
acceptForViewingNothing: aPane
    "Accept the text for when I'm viewing nothing.  Do nothing"

    aPane modified: false! 
acceptFromPane: aPane
    "Accept the text in aPane, and save it.  Call the appropriate save method depending upon
    the current textViewState."

    | acceptSelector |

    acceptSelector := 'acceptFor',
        (String with: self textViewState first asUpperCase), (self textViewState copyFrom: 2 to: self textViewState size).
    acceptSelector := acceptSelector asSymbol.

    (self respondsTo: acceptSelector)
        ifTrue: [self perform: acceptSelector with: aPane]
        ifFalse: [self privateUnknownAcceptForPane: aPane]
!  
addBrowserMenu
    "Add a menu with options which apply to the entire browser"

    | theMenu tab |

    tab := String with: Tab.
    (theMenu := Menu new)
        owner: self;
        title: 'Browser';
        appendItem: 'Exchange State', tab, 'Alt+X' selector: #exchangeCurrentState accelKey: $X accelBits: AfAlt;
        appendItem: 'Push State', tab, 'Alt+C' selector: #pushCurrentState accelKey: $C accelBits: AfAlt;
        appendItem: 'Pop State', tab, 'Alt+V' selector: #popLastState accelKey: $V accelBits: AfAlt;
        appendItem: 'Clear States' selector: #clearSavedStates;
        appendSeparator;
        appendItem: 'Update', tab, 'Alt-U' selector: #update accelKey: $U accelBits: AfAlt;
        appendSeparator;
        appendItem: 'Spawn', tab, 'Ctrl+B' selector: #spawn accelKey: $B accelBits: AfControl;
        yourself.
    self mainView menuWindow insertMenu: theMenu after: 3.!  
addCategory
    "Add a category to my codeBrowser's organizer before the first selected category.
    If the user types in a category which starts with a dash, then he means to make a
    separator instead of a category name."

    | category |

    self textModified
        ifTrue: [^self].
    category := PrompterDialog
        title: 'Navigator Browser'
        prompt: 'Name for new category?'
        default: ''
        history: self class previousCategories.
    (category isNil or: [category isEmpty])
        ifTrue: [^self].
   self class rememberCategory: category.
   codeBrowser addCategory: category before: codeBrowser selectedCategory.
   self updatePanesFrom: 'categories'
!  
addChangeSet
    "Add a new change set to the set of change sets"

    | newName new |
    newName := Prompter
        title: 'Navigator Browser'
        prompt: 'Name for new change set?'
        default: 'Unnamed'.
    (newName isNil or: [newName isEmpty])
        ifTrue: [^self].

    CodeFiler changeSetManager add: (new := ChangeSet new name: newName).
    changeSet := new.

    self
        updateChangeSet;
        updatePanesFrom: 'categories'
!  
addProtocol
    "Add a protocol to my selected class, and make it the selectedProtocol in my
    codeBrowser"

    | protocol |

    self textModified
        ifTrue: [^self].
    protocol := PrompterDialog
        title: 'Navigator Browser'
        prompt: 'Name for new protocol?'
        default: self class previousProtocol
        history: self class previousProtocols.
    (protocol isNil or: [protocol isEmpty])
        ifTrue: [^self].
   self class
        rememberProtocol: protocol;
        previousProtocol: protocol.
   changeSet logChangeForAddProtocol: protocol before: codeBrowser selectedProtocol inClass: codeBrowser selectedSmalltalkClassOrMetaclass.
   codeBrowser addProtocol: protocol before: codeBrowser selectedProtocol.
    currentItems := changeSet itemsForClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
   self updatePanesFrom: 'categories'
! 
annotationForPane: aPane
    "aPane  <pane>
    Set the contents of the annotation pane to reflect the current selection"

    codeBrowser selectedMethods size = 1
        ifTrue: [self showMethodSourceAnnotationFor: aPane]
        ifFalse: [aPane contents: '']
!
browseMethodVersions
    "Open a browser on all the versions of the currently selected method"

    | loadedVersion |

    loadedVersion := (CodeFiler forClass: codeBrowser selectedSmalltalkClassOrMetaclass)
        loadedVersionOf: codeBrowser selectedMethod.

    MethodVersionBrowser openOn: loadedVersion withAllPreviousVersions
!   
buildCategoryBrowser
    "private - build the panes for a category browser"

    | midY aRectangle buttonHeight categoryBox classBox protocolBox methodBox |

    midY := 4/9.
    buttonHeight := 1/9.
    categoryBox := 0 @ 0 corner: 1/4 @ midY.
    classBox := (1/4) @ 0 corner: 1/2 @ midY.
    protocolBox := (1/2) @ 0 corner: (3/4) @ midY.
    methodBox := (3/4) @ 0 corner: 1 @ midY.

    self
        createChangeSetListInFrame: [:rect | rect scaleTo: categoryBox];
        createChangeSetAnnotationInFrame: [:rect |
            aRectangle := rect scaleTo: (categoryBox merge: classBox).
            aRectangle origin + (4 @ (aRectangle height - ListFont height - 5)) corner: aRectangle corner - (4@0)];
        createCategoryListInFrame: [:rect |
            (rect scaleTo: categoryBox) insetBy: (0@(ListFont height + 7) corner: 0@(ListFont height + 5))];
        createClassListInFrame: [:rect |
            (rect scaleTo: classBox) insetBy: (0@0 corner: 0@(ListFont height + 5))];
        createProtocolListInFrame: [:rect |
            (rect scaleTo: protocolBox) insetBy: (0 @ 0 corner: 0 @ (ListFont height + 6))];
        createProtocolButtonInFrame: [:rect |
            aRectangle := rect scaleTo: protocolBox.
            aRectangle origin + (0 @ (aRectangle height - ListFont height - 6)) corner: aRectangle corner];
        createMethodListInFrame: [:rect |
            (rect scaleTo: methodBox) insetBy: (0 @ 0 corner: 0 @ (ListFont height + 5))];
        createAnnotationPaneInFrame: [:rect |
            aRectangle := rect scaleTo: methodBox.
            aRectangle origin + (4 @ (aRectangle height - ListFont height - 5)) corner: aRectangle corner - (4@0)];
        createTextInFrame: (0 @ midY corner: 1 @ 1)! 
categoriesForPane: aPane
    "Set the contents of the categories pane"

    | items |
    aPane
        contents: (items := codeBrowser categories)
        colors: (changeSet colorsForCategories: items)

! 
categoryImplementorsOfMethods
    "Open a methodBrowser on all of the implementors of the selected methods
    in all of the classes in my selected categories"

    | methods label |

    methods := self implementorsOf: codeBrowser selectedMethods in: codeBrowser smalltalkClasses.
    methods isEmpty
        ifTrue: [^MessageBox message: 'No implementors']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space; space].
            ^MethodBrowser new
                label: 'Implementors of ' , label contents;
                openOn: methods].
!   
categoryMenuForPane: aPane
    "Answer the menu for the categories pane"

    | menu fileOutMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutCategoriesWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    menu := Menu new
        title: 'Category';
        owner: self;
        appendItem: 'Add...' selector: #addCategory;
        appendSeparator;
        appendSubMenu: fileOutMenu;
        appendItem: 'Rename...' selector: #renameCategories;
        appendItem: 'Find Class...' selector: #findClass;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeCategories;
        yourself.
    aPane notNil
        ifTrue: [aPane setMenu: menu].
    ^menu
!   
categorySendersOfMethods
    "Open a methodBrowser on all of the senders of the selected methods
    in my selected categories"

    | methods label |

    methods := self sendersOf: codeBrowser selectedMethods in: codeBrowser smalltalkClasses.
    methods isEmpty
        ifTrue: [^MessageBox message: 'No senders']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space;space].
            ^MethodBrowser new
                label: 'Senders of ' , label contents;
                openOn: methods].
!   
changeSetAnnotationForPane: aPane
    "aPane  <pane>
    Update the contents of the change set annotation pane"

    aPane contents: ((currentItems isNil or: [currentItems isEmpty])
        ifTrue: ['no change']
        ifFalse: [changeSet annotationForItems: currentItems])

! 
changeSetMenuForPane: aPane
    "Answer the menu for the change set combo box."

    | menu fileOutMenu exportMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutChangeSetWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    exportMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self exportChangeSetWith: aCodeWriterClass].
    exportMenu
        owner: self;
        title: 'Export...'.

    menu := Menu new
        title: 'Changes';
        owner: self;

        appendItem: 'Add...' selector: #addChangeSet;
        appendSeparator;
        appendSubMenu: fileOutMenu;
        appendSubMenu: exportMenu;
        appendSeparator;
        appendItem: 'Browse...' action: [:owner | ChangeSetBrowser openOn: changeSet];
        appendSeparator;
        appendItem: 'Open' action: [:owner | changeSet allowChanges. self updateChangeSet];
        appendItem: 'Close' action: [:owner | changeSet disallowChanges. self updateChangeSet];
        appendItem: 'Comment' selector: #editChangeSetComment;
        appendItem: 'Rename...' selector: #renameChangeSet;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeChangeSet;
        yourself.

    aPane notNil
        ifTrue: [aPane setMenu: menu].
    ^menu

!  
changeSetsForPane: aPane
    "Set the contents of the change set pane"

    aPane
        contents: CodeFiler changeSetManager changeSets;
        selection: changeSet

! 
classesForPane: aPane
    "Set the contents of the classes pane"

    | classNames |
    aPane
        contents: (classNames := codeBrowser hierarchyOfClasses)
        colors: (changeSet colorsForClasses: (classNames collect: [:each | each trimBlanks])).


!   
classMenuForPane: aPane
    "Answer the menu for the classes pane"

    | menu fileOutMenu fileOutAllMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutClassesWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    fileOutAllMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutClassesWithAllSubclassesWith: aCodeWriterClass].
    fileOutAllMenu
        owner: self;
        title: 'File Out All...'.

    menu := Menu new
        title: 'Class';
        owner: self;
        appendItem: 'Add To Changes' action: [:owner | self logChangeForSelectedClasses; update];
        appendSeparator;
        appendSubMenu: fileOutMenu;
        appendSubMenu: fileOutAllMenu;
        appendItem: 'Get and Set...' action: [:owner |
            (Smalltalk at: #GetAndSetBuilder) new openOn: codeBrowser selectedSmalltalkClass.
            self updatePanesFrom: 'protocols'];
        appendItem: 'Classify Methods' action: [:owner |
            MethodClassifier classifyAll: codeBrowser selectedSmalltalkClasses.
            self updatePanesFrom: 'protocols'];
        appendSeparator;
        appendItem: 'Find Class...' selector: #findClass;
        appendItem: 'Move...' selector: #moveClasses;
        appendItem: 'Copy...' selector: #copyClasses;
        appendSeparator;
        appendItem: 'Update' selector: #updateClassOrganizer;
        appendItem: 'Definition' selector: #editClassDefinition;
        appendItem: 'Comment' selector: #editClassComment;
        appendSubMenu: self classReferencesSubMenu;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeClasses;
        yourself.
    aPane notNil
        ifTrue: [aPane setMenu: menu].
    ^menu
! 
classReferencesSubMenu
    "   ^   <Menu>
    Answer a menu with the different types of class reference requests allowed"

    | theMenu |

    theMenu := Menu new
        title: 'References';
        owner: self;
        appendItem: 'Class' selector: #referencesToSelectedClasses;
        appendItem: 'Instance Variable' selector: #referencesToInstanceVariables;
        appendItem: 'Class Variable' selector: #referencesToClassVariables;
        yourself.

    ^theMenu!
classSendersOfMethods
    "Open a methodBrowser on all of the senders of the selected methods
    in my selected classes"

    | methods label |

    methods := self sendersOf: codeBrowser selectedMethods in: codeBrowser selectedSmalltalkClasses.
    methods isEmpty
        ifTrue: [^MessageBox message: 'No senders']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space;space].
            ^MethodBrowser new
                label: 'Senders of ' , label contents;
                openOn: methods].
! 
clearSavedStates
    "Clear my saved states."

    self
        savedStates: OrderedCollection new;
        updateBrowserMenu;
        updateLabel
!   
compilerError: anError at: index in: anObject for: aClass
    "a compiler error has occurred while building the annotation for the annotation pane. Do nothing"

    ^nil
!   
copyClasses
    "Copy the selected classes to a new category"

    | newCategories |

    newCategories := ChooseManyDialog new
        openOn: codeBrowser categories label: 'Copy to which categories?'.
    (newCategories isNil or: [newCategories isEmpty])
        ifTrue: [^self].
    codeBrowser copySelectedClassesTo: newCategories.
    changeSet logChangeForReorganizingClasses: codeBrowser selectedSmalltalkClasses intoCategories: newCategories.
    currentItems := changeSet itemsForCategories: codeBrowser selectedCategories.
    self updatePanesFrom: 'categories'
!
copyMethodsToNewClass
    "Copy all the selected methods to a new class specified by the user"

    | theClass newClass stream methodOrganizer protocol |

    newClass := PrompterDialog
        title: 'Navigator Browser'
        prompt: 'Copy the selected protocols to which class?'
        default: codeBrowser selectedClass
        history: codeBrowser classes.

    (newClass isNil or: [newClass isEmpty])
        ifTrue: [^self].
    newClass := newClass trimBlanks.
    (Smalltalk includesKey: newClass asSymbol)
        ifFalse: [^MessageBox message: 'No such class'].
    self class rememberClass: newClass.
    codeBrowser isBrowsingClassMethods
        ifTrue: [newClass := (Smalltalk at:  newClass asSymbol) class]
        ifFalse: [newClass := Smalltalk at: newClass asSymbol].

    CursorManager execute changeFor: [
        codeBrowser copySelectedMethodsTo: newClass.
        methodOrganizer := CodeFiler organizerFor: newClass name.
        codeBrowser selectedMethods do: [:eachSelector |
            protocol := methodOrganizer categoryOfElement: eachSelector.
            changeSet logChangeForSelector: eachSelector inProtocol: protocol inClass: newClass]].

    self updatePanesFrom: 'categories'
!   
copyProtocolsToNewClass
    "Copy all methods in the given protocols to a class specified by the user."

    | theClass newClass stream |

    newClass := PrompterDialog
        title: 'Navigator Browser'
        prompt: 'Copy the selected protocols to which class?'
        default: codeBrowser selectedClass
        history: codeBrowser classes.
    (newClass isNil or: [newClass isEmpty])
        ifTrue: [^self].
    newClass := newClass trimBlanks.
    (Smalltalk includesKey: newClass asSymbol)
        ifFalse: [^MessageBox message: 'No such class'].
    self class rememberClass: newClass.
    codeBrowser isBrowsingClassMethods
        ifTrue: [newClass := (Smalltalk at:  newClass asSymbol) class]
        ifFalse: [newClass := Smalltalk at: newClass asSymbol].

    CursorManager execute changeFor: [
        codeBrowser copySelectedProtocolsTo: newClass.
        codeBrowser selectedProtocols do: [:eachProtocol |
            (codeBrowser selectedMethodOrganizer elementsOfCategory: eachProtocol) do: [:eachSelector |
                changeSet logChangeForSelector: eachSelector inProtocol: eachProtocol inClass: newClass]]].

    self updatePanesFrom: 'categories'
!
createAnnotationPaneInFrame: frame
    "Add a pane to myself that will show an annotation"

    | thisPane theFont |

    self addSubpane: ((thisPane := StaticText new)
        owner: self;
        paneName: 'annotation';
        when: #needsContents send: #annotationForPane: to: self with: thisPane;
        framingBlock: frame)
!
createCategoryListInFrame: frame
    " Add a pane to myself that will handle the category selection."

    | thisPane theFont |

    self addSubpane: ((thisPane := ColorMultipleSelectListBox new)
        owner: self;
        paneName: 'categories';
        extendedSelect;
        ownerDrawFixed;
        when: #needsContents send: #categoriesForPane: to: self with: thisPane;
        when: #changed: send: #selectCategoriesForPane: to: self with: thisPane;
        when: #needsMenu send:  #categoryMenuForPane: to: self with: thisPane;
        framingBlock: frame).
!
createChangeSetAnnotationInFrame: frame
    "Add a pane to myself that will show annotations for the current change set"

    | thisPane theFont |

    self addSubpane: ((thisPane := StaticText new)
        owner: self;
        paneName: 'changeSetAnnotation';
        when: #needsContents send: #changeSetAnnotationForPane: to: self with: thisPane;
        framingBlock: frame)
!
createChangeSetListInFrame: frame
    " Add a pane to myself that will handle the change set selection."

    | thePane |
    self addSubpane: ((thePane := ComboBox dropDownList)
        owner: self;
        paneName: 'changeSets';
        when: #needsContents send: #changeSetsForPane: to: self with: thePane;
        when: #clicked: send: #selectChangeSetsForPane: to: self with: thePane;
        when: #needsMenu send: #changeSetMenuForPane: to: self with: thePane;
        framingBlock: frame)
!
createClassListInFrame: frame
    "Add a pane to myself that will list classes"

    | thisPane |

    self addSubpane: ((thisPane := ColorMultipleSelectListBox new)
        owner: self;
        paneName: 'classes';
        extendedSelect;
        ownerDrawFixed;
        when: #needsContents send: #classesForPane: to: self with: thisPane;
        when: #changed: send: #selectClassesForPane: to: self with: thisPane;
        when: #needsMenu send: #classMenuForPane: to: self with: thisPane;
        framingBlock: frame).
!   
createMethodListInFrame: frame
    "Add a pane to myself that will list methods"

    | thisPane theFont |

    self addSubpane: ((thisPane := ColorMultipleSelectListBox new)
        owner: self;
        paneName: 'methods';
        extendedSelect;
        ownerDrawFixed;
        when: #needsContents send: #methodsForPane: to: self with: thisPane;
        when: #changed: send: #selectMethodsForPane: to: self with: thisPane;
        when: #needsMenu send: #methodMenuForPane: to: self with: thisPane;
        framingBlock: frame).
! 
createProtocolButtonInFrame: frame
    "Add a pane to myself that will list protocols"

    | thisPane |

    self addSubpane: ((thisPane := Button new)
        owner: self;
        paneName: 'protocolButton';
        when: #clicked send: #instanceOrClassClicked: to: self with: thisPane;
        when: #needsContents send: #labelForProtocolButton: to: self with: thisPane;
        pushButton;
        framingBlock: frame).
! 
createProtocolListInFrame: frame
    "Add a pane to myself that will list protocols"

    | thisPane |

    self addSubpane: ((thisPane := ColorMultipleSelectListBox new)
        owner: self;
        paneName: 'protocols';
        extendedSelect;
        ownerDrawFixed;
        when: #needsContents send: #protocolsForPane: to: self with: thisPane;
        when: #changed: send: #selectProtocolsForPane: to: self with: thisPane;
        when: #needsMenu send: #protocolMenuForPane: to: self with: thisPane;
        framingBlock: frame).
! 
createTextInFrame: frame
    "Add a pane to myself that will display an appropriate piece of text."

    | thisPane |

    self addSubpane: ((thisPane := self toolTextPaneClass new)
        owner: self;
        paneName: 'textPane';
        when: #needsContents send: #textForPane: to: self with: thisPane;
        when: #aboutToSave send: #acceptFromPane: to: self with: thisPane;
        framingRatio: frame).
    "self icon: (Icon fromModule: Icon defaultDLLFileName id:'ClassHierarchyBrowser')."!   
deepestCommonSuperclassOf: classes
    "classes    <OrderedCollection withAll: <Class> | <Metaclass>>
       ^                <Class> | <Metaclass>
    Private - Look at classes and answer their deepest common superclass.
    Do a pairwise compare to find the most common superclass. If they have
    no common superclass, then answer the first class in classes"

    | class supers |

    class := classes first.
    classes do: [:each |
        supers := class withAllSuperclasses.
        class := each withAllSuperclasses
            detect: [:first | supers includes: first]
            ifNone: [^classes first]].

    ^class

!   
disable: items inMenu: menu
    "items      <collection of symbols>
     Disable all of the named items in menu"

    items do: [:each |
        menu disableItem: each]!
doItResult: aTextPane error: aBlock
        "Private - Evaluate the selected text in aTextPane in the context of the inspected
         object.  If error, evaluate aBlock."

    | receiver |
    receiver := codeBrowser selectedSmalltalkClass.
    ^Compiler
        evaluate: aTextPane selectedString
        in: receiver class
        to: receiver
        notifying: aTextPane
        ifFail: aBlock

!   
editChangeSetComment
    "Edit the change set comment"

    self textModified
        ifTrue: [^self].
    self
        viewChangeSetComment;
        updateText
!
editClassComment
    "Edit the class comment"

    self textModified
        ifTrue: [^self].
    codeBrowser selectedProtocols: Array new.
    self
        privateUpdatePanesFrom: 'protocols';
        viewClassComment;
        updateText
!
editClassDefinition
    "Make sure that I am showing a class definition, or a class
    definition template"

    self textModified
        ifTrue: [^self].
    codeBrowser selectedProtocols: Array new.
    self
        privateUpdatePanesFrom: 'protocols';
        viewClassDefinition;
        updateText
! 
enable: items inMenu: menu
    "items      <collection of symbols>
     Enable all of the named items in menu"

    items do: [:each |
        menu enableItem: each]!   
exchangeCurrentState
    "Exchange the current browser state with the top state on the browser stack"

    | topmostState |

    self savedStates isEmpty
        ifTrue: [^self].

    topmostState := self savedStates removeLast.
    self savedStates addLast: self state.
    self
        restoreStateFrom: topmostState;
        updateBrowserMenu
!  
exportChangeSetWith: aCodeWriterClass
    "Export the current change set with the current code writer"

    | fileName file |
    fileName := changeSet name, '.st'.
    fileName := fileName replaceCharacter: Space from: 1 to: fileName size withString: ''.
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].

    file := File newFile: fileName.
    [changeSet exportOn: file with: aCodeWriterClass] ensure: [file close]
!   
fileOutCategoriesWith: aCodeWriterClass
    "file out  the selected categories"

    | fileName file |

    codeBrowser selectedCategories size > 1
        ifTrue: [fileName := 'classes.st']
        ifFalse: [
            fileName := codeBrowser selectedCategory asArrayOfSubstrings
                inject: String new into: [:sum :each | sum, each].
            fileName := (fileName copyFrom: 1 to: (fileName size min: 8)), '.st'].
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.
    [codeBrowser fileOutSelectedCategoriesOn: file with: aCodeWriterClass] ensure: [file close].
! 
fileOutChangeSetWith: aCodeWriterClass
    "File out the current change set with the current code writer"

    | fileName file |
    fileName := changeSet name, '.st'.
    fileName := fileName replaceCharacter: Space from: 1 to: fileName size withString: ''.
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].

    file := File newFile: fileName.
    [changeSet fileOutOn: file with: aCodeWriterClass] ensure: [file close]
!   
fileOutClassesWith: aCodeWriterClass
    "file out  the selected classes"

    | fileName file |

    codeBrowser selectedClasses size > 1
        ifTrue: [fileName := 'classes.st']
        ifFalse: [
            fileName := codeBrowser selectedClass.
            fileName := (fileName copyFrom: 1 to: (fileName size min: 8)), '.st'].
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.
    [codeBrowser fileOutSelectedClassesOn: file with: aCodeWriterClass] ensure: [file close].
!   
fileOutClassesWithAllSubclassesWith: aCodeWriterClass
    "file out  the selected classes"

    | fileName file |

    codeBrowser selectedClasses size > 1
        ifTrue: [fileName := 'classes.st']
        ifFalse: [
            fileName := codeBrowser selectedClass.
            fileName := (fileName copyFrom: 1 to: (fileName size min: 8)), '.st'].
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.
    [codeBrowser
        fileOutSelectedClassesWithAllSubclassesOn: file
        with: aCodeWriterClass] ensure: [file close]
!
fileOutMethodsWith: aCodeWriterClass
    "file out  the selected methods"

    | fileName file |

    codeBrowser selectedMethods size > 1
        ifTrue: [fileName := 'methods.st']
        ifFalse: [
            fileName := codeBrowser selectedMethod.
            fileName := (fileName copyFrom: 1 to: (fileName size min: 8)), '.st'].
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.
    [codeBrowser fileOutSelectedMethodsOn: file with: aCodeWriterClass] ensure: [file close].
!  
fileOutProtocolsWith: aCodeWriterClass
    "file out  the selected protocls"

    | fileName file |

    codeBrowser selectedProtocols size > 1
        ifTrue: [fileName := 'methods.st']
        ifFalse: [
            fileName := codeBrowser selectedProtocol asArrayOfSubstrings
                inject: String new
                    into: [:sum :each | sum, each].
            fileName := (fileName copyFrom: 1 to: (fileName size min: 8)), '.st'].
    fileName := (FileDialog new saveFile: fileName) file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.
    [codeBrowser fileOutSelectedProtocolsOn: file  with: aCodeWriterClass] ensure: [file close].
!
findClass
    "Prompt the user for a class to find, and select it in the browser"

    | className theClass |

    self textModified
        ifTrue: [^self].
    className := PrompterDialog
        title: 'Navigator Browser'
        prompt: 'Find which class (* allowed)'
        default: self class previousClass
        history: self class previousClasses.
    (className isNil or: [className isEmpty])
        ifTrue: [^self].
    (className includes: $*)
        ifTrue: [
            className := self findWildcardName: className.
            (className isNil or: [className isEmpty])
                ifTrue: [^self]].
    theClass := Smalltalk
        at: className trimBlanks asSymbol
        ifAbsent: [^MessageBox message: 'Class does not exist.'].
    self update. "why should I have to do an update after a file in"
    (theClass isKindOf: Behavior) ifFalse: [
        theClass := theClass class].
    self class rememberClass: className.
    codeBrowser findClass: theClass name.
    self updatePanesAndMakeVisibleSelectionFrom: 'categories'! 
findMethod
    "Ask the user which method to find, and select it"

    | theMethod |

    self textModified
        ifTrue: [^self].
    theMethod := (ChooseOneDialog new
        openOn: codeBrowser selectedMethodOrganizer elements asSortedCollection
        label: 'Find which method?').
    theMethod isNil
        ifTrue: [^self].
    codeBrowser
        selectedProtocols: (codeBrowser selectedMethodOrganizer categoriesOfElement: theMethod);
        selectedMethods: (Array with: theMethod).
    self updatePanesFrom: 'protocols'
!  
findWildcardName: className
    "Return the name of the class specified by className, which is '<whatever>*'."
    | classes partialName name names pattern theClass |
    pattern := Pattern new: className.
    classes := Smalltalk select: [:aClass |
        (aClass isKindOf: Behavior)
            ifTrue: [(pattern matches: aClass name)]
            ifFalse: [false]].
    names := classes keys asSortedCollection asArray.
    names size = 0
        ifTrue: [
            MessageBox message: 'Class does not exist.'.
            ^nil].
    names size = 1
        ifTrue: [^names first].
    theClass := (ChooseOneDialog new openOn: names label: 'Choose a Class').
    theClass notNil
        ifTrue: [theClass := theClass asString].
    ^theClass!
hierarchyImplementorsOfMethods
    "Open a methodBrowser on all of the implementors of the selected methods
    in my selected class's hierarchy"

    | hierarchy methods label |

    hierarchy := codeBrowser selectedSmalltalkClass allSuperclasses reversed,
                                codeBrowser selectedSmalltalkClass withAllSubclasses.
    methods := self implementorsOf: codeBrowser selectedMethods in: hierarchy.
    methods isEmpty
        ifTrue: [^MessageBox message: 'No implementors']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space;space].
            ^MethodBrowser new
                label: 'Implementors of ' , label contents;
                openOn: methods].
! 
hierarchySendersOfMethods
    "Open a methodBrowser on all of the senders of the selected methods
    in my selected class's hierarchy"

    | hierarchy methods label |

    hierarchy := codeBrowser selectedSmalltalkClass allSuperclasses reversed,
                                codeBrowser selectedSmalltalkClass withAllSubclasses.
    methods := self sendersOf: codeBrowser selectedMethods in: hierarchy.
    methods isEmpty
        ifTrue: [^MessageBox message: 'No senders']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space;space].
            ^MethodBrowser new
                label: 'Senders of ' , label contents;
                openOn: methods].
!  
implementorsOf: symbols in: classes
    "   ^  <collection of compiledMethods>
    symbols     <collection withAll: <Symbol>>
    classes        <collection of classes>
    Answer all the implementors of the selected methods in classes"

    | methods |
    CursorManager execute changeFor: [
        methods := OrderedCollection new.
        classes do: [:eachClass |
            symbols do: [:eachMethod |
                methods addAll: (eachClass classImplementorsOf: eachMethod)]]].
    ^methods asArray! 
implementorsOfMethods
    "Open a methodBrowser on all of the implementors of the selected methods
    in all Smalltalk classes"

    | methods label |

    methods := self implementorsOf: codeBrowser selectedMethods in:
        (Smalltalk rootClasses inject: OrderedCollection new into: [:sum :each |
            sum, each withAllSubclasses]).
    methods isEmpty
        ifTrue: [^MessageBox message: 'No implementors']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space; space].
            ^MethodBrowser new
                label: 'Implementors of ' , label contents;
                openOn: methods].
!  
implementorsSubMenu
    "   ^   <Menu>
    Answer a menu with the different types of implementors requests allowed"

    | theMenu |

    theMenu := Menu new
        title: 'Implementors';
        owner: self;
        appendItem: 'Hierarchy' selector: #hierarchyImplementorsOfMethods;
        appendItem: 'Category' selector: #categoryImplementorsOfMethods;
        appendItem: 'System' selector: #implementorsOfMethods;
        yourself.

    ^theMenu
! 
initializeWithCodeBrowser: aCodeBrowser

    self initialize.
    updatesInProgress := false.
    codeBrowser := aCodeBrowser.
    changeSet := CodeFiler changeSetManager changeSets first.
    self
        viewNothing;
        savedStates: OrderedCollection new.
! 
initWindowSize
        "Private - Answer default initial window extent."
    ^Display extent * 13 // 16!
instanceOrClassClicked: aButton
    "Switch from instance to class mode, and vs"

    self textModified ifTrue: [^self].
    self viewMethodOrganization.
    codeBrowser isBrowsingInstanceMethods
        ifTrue: [codeBrowser browseClassMethods]
        ifFalse: [codeBrowser browseInstanceMethods].

    currentItems := changeSet itemsForClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
    self
        updateProtocolButton;
        updatePanesFrom: 'protocols'
! 
isViewingChangeSetComment
    ^textViewState = #viewingChangeSetComment:
!  
isViewingClassComment
    ^textViewState = #viewingClassComment:!
isViewingClassDefinition

    ^textViewState = #viewingClassDefinition:!
isViewingClassOrganization

    ^textViewState = #viewingClassOrganization:!
isViewingMethodOrganization

    ^textViewState = #viewingMethodOrganization:!  
isViewingMethodSource

    ^textViewState = #viewingMethodSource:!  
isViewingNothing

    ^textViewState = #viewingNothing:!
labelForProtocolButton: aButton
    "Set the label for the protocol button"

    codeBrowser isBrowsingInstanceMethods
        ifTrue: [aButton contents: 'instance']
        ifFalse: [aButton contents: 'class']
!
logChangeForSelectedClasses
    "Log the selected class definitions as changes in my change set."

    codeBrowser selectedSmalltalkClasses do: [:each |
        changeSet logChangeForClass: each].
    currentItems := changeSet itemsForCategories: codeBrowser selectedCategories.
!
logChangeForSelectedMethods
    "Log the selected methods as changes in my change set."

    | theClass selectedMethods |

    theClass := codeBrowser selectedSmalltalkClassOrMetaclass.
    selectedMethods := codeBrowser selectedMethods.

    codeBrowser selectedProtocols do: [:eachProtocol |
        (codeBrowser selectedMethodOrganizer elementsOfCategory: eachProtocol) do: [:eachSelector |
            (selectedMethods includes: eachSelector)
                ifTrue: [changeSet logChangeForSelector: eachSelector inProtocol: eachProtocol inClass: theClass]]].
    currentItems := changeSet
        itemsForProtocols: codeBrowser selectedProtocols
        inClasses: (self realClassNamesFrom: codeBrowser selectedClasses).

!  
logChangeForSelectedProtocols
    "Log all of the methods in my selected protocols as changes in my change set."

    | theClass |

    theClass := codeBrowser selectedSmalltalkClassOrMetaclass.

    codeBrowser selectedProtocols do: [:eachProtocol |
        (codeBrowser selectedMethodOrganizer elementsOfCategory: eachProtocol) do: [:eachSelector |
            changeSet logChangeForSelector: eachSelector inProtocol: eachProtocol inClass: theClass]].
    currentItems := changeSet
        itemsForProtocols: codeBrowser selectedProtocols
        inClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
!
methodMenuForPane: aPane
    "Answer the menu for the methods pane"

    | menu fileOutMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutMethodsWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    menu := Menu new
        title: 'Method';
        owner: self;
        appendItem: 'Add To Changes' action: [:owner | self logChangeForSelectedMethods; update];
        appendSeparator;
        appendSubMenu: fileOutMenu;
        appendItem: 'Find Method...' selector: #findMethod;
        appendItem: 'Move...' selector: #moveMethods;
        appendItem: 'Copy...' selector: #copyMethodsToNewClass;
        appendSeparator;
        appendSubMenu: self sendersSubMenu;
        appendSubMenu: self implementorsSubMenu;
        appendItem: 'Messages' selector: #methodMessages;
        appendItem: 'Browse Versions' selector: #browseMethodVersions;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeMethods;
        yourself.
    aPane notNil
        ifTrue: [aPane setMenu: menu].
    ^menu
!   
methodMessages
    "Open a messages selector browser for the selected method."

    | method |
    method := codeBrowser selectedMethod.
    CursorManager execute changeFor: [
        SourceManager current messagesIn: (codeBrowser selectedSmalltalkClassOrMetaclass compiledMethodAt: method)]
!  
methodsForPane: aPane
    "Set the contents of the methods pane"

    | methods |
    aPane
        contents: (methods := codeBrowser methods asSortedCollection asArray)
        colors: (changeSet
            colorsForMethods: methods
            inClasses: (self realClassNamesFrom: codeBrowser selectedClasses))

!
moveClasses
    "Move the selected classes to a new category"

    | newCategories |

    self textModified
        ifTrue: [^self].
    newCategories := ChooseManyDialog new
        openOn: codeBrowser categories label: 'Move to which categories?'.
    (newCategories isNil or: [newCategories isEmpty])
        ifTrue: [^self].
    changeSet logChangeForReorganizingClasses: codeBrowser selectedSmalltalkClasses intoCategories: newCategories.
    codeBrowser moveSelectedClassesTo: newCategories.
    currentItems := changeSet itemsForCategories: codeBrowser selectedCategories.
    self updatePanesFrom: 'categories'
!   
moveMethods
    "Move the selected methods from the selected protocol to another one"

    | destinationProtocol |

    self textModified
        ifTrue: [^self].
    destinationProtocol := PrompterDialog
        title: 'Navigator Browser'
        prompt: 'Move selected methods where?'
        default: codeBrowser selectedProtocol
        history: codeBrowser protocols.
    destinationProtocol isNil
        ifTrue: [^self].
    codeBrowser selectedMethods do: [:each |
        changeSet logChangeForSelector: each inProtocol: destinationProtocol inClass: codeBrowser selectedSmalltalkClassOrMetaclass].
        currentItems := changeSet
            itemsForMethods: codeBrowser selectedMethods
            inClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
    codeBrowser moveSelectedMethodsTo: destinationProtocol.
    self updatePanesFrom: 'categories'.
!   
open

    self
        label: 'Navigator Browser';
        buildCategoryBrowser;
        openWindow;
        addBrowserMenu;
        updateMenus

!  
popLastState
    "Pop the state on top of my saved state stack.
    Make that my current state.  If there are no states pushed,
    then sound a warning siren, and do nothing."

    self savedStates notEmpty
        ifTrue: [self restoreStateFrom: self savedStates removeLast]
        ifFalse: [Terminal bell].

    self updateBrowserMenu!  
privateUnknownAcceptForPane: aPane
    "Private - I am viewing text which I don't know how to save.  Report an error message."

    (MessageBox confirm: 'I don''t know how to save text when I''m ', self textViewState, '.  ',
        'Would you like to save the text on the clipboard?')
            ifTrue: [
                Clipboard setString: aPane contents.
                aPane modified: false]!   
privateUnknownTextForPane: aPane
    "I don't knwo what I'm supposed to display, so set the contents of the pane
    to a message to that effect"

    aPane contents: 'I don''t know how to display for state ', textViewState printString!  
privateUpdatePanesAndMakeVisibleSelectionFrom: startPaneName to: endPaneName
    "Update the panes from startPaneName to endPaneName in my pane ordering"

    | paneNames pane message messages selections |

    paneNames := self class paneUpdateOrder.
    messages := self class paneUpdateMessages.
    (paneNames indexOf: startPaneName)  to: (paneNames indexOf: endPaneName) do:  [:index |
        message := messages at: index.
        self perform: message.
        "The following should be part of the update (probably a parameter)."
        (#(updateCategories updateClasses updateProtocols
        updateMethods) includes: message) ifTrue: [
            pane := self paneNamed: (paneNames at: index).
            (selections := pane selections) isEmpty ifFalse: [
                pane setTopIndex: ((selections first - 2) max: 1)]]]!
privateUpdatePanesFrom: paneName
    "Update the panes from paneName onward"

    self privateUpdatePanesFrom: paneName to: self class paneUpdateOrder last!   
privateUpdatePanesFrom: startPaneName to: endPaneName
    "Update the panes from startPaneName to endPaneName in my pane ordering"

    | panes methodName|

    ((panes := self class paneUpdateOrder)
        copyFrom: (panes indexOf: startPaneName)
            to: (panes indexOf: endPaneName)) do:  [:each |
                methodName := ('update',
                    (String with: each first asUpperCase),
                    (each copyFrom: 2 to: each size)) asSymbol.
                self perform: methodName]!
protocolForSelector: selector
    "   selector        <Symbol>
                ^               <String>
    Private - Find the correct protocol for selector, and save it there in the current class' organizer"

    | protocol defaultProtocol |
    protocol := (codeBrowser selectedMethodOrganizer categoryOfElement: selector).
    protocol isNil
        ifTrue: [
            codeBrowser selectedProtocols size > 1
                ifTrue: [
                    defaultProtocol := (codeBrowser selectedMethodOrganizer categoryOfElement: selector).
                    defaultProtocol isNil
                        ifTrue: [defaultProtocol := codeBrowser selectedProtocols first].
                    protocol := PrompterDialog
                        title: 'Navigator Browser'
                        prompt: 'Save method where?'
                        default: defaultProtocol
                        history: codeBrowser selectedProtocols]
                ifFalse: [protocol := codeBrowser selectedProtocol]].
    protocol isNil
        ifTrue: [protocol := codeBrowser selectedMethodOrganizer defaultCategory].
    codeBrowser selectedMethodOrganizer
        addElement: selector toCategory: protocol.
    codeBrowser selectedMethods: (Array with: selector).
    ^protocol
!   
protocolMenuForPane: aPane
    "Answer the menu for the protocols pane"

    | menu  fileOutMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutProtocolsWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    menu := Menu new
        title: 'Protocol';
        owner: self;
        appendItem: 'Add...' selector: #addProtocol;
        appendItem: 'Add To Changes' action: [:owner | self logChangeForSelectedProtocols; update];
        appendSeparator;
        appendSubMenu: fileOutMenu;
        appendItem: 'Find Method...' selector: #findMethod;
        appendItem: 'Copy...' selector: #copyProtocolsToNewClass;
        appendItem: 'Rename...' selector: #renameProtocols;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeProtocols;
        yourself.
    aPane notNil ifTrue: [aPane setMenu: menu].
    ^menu
! 
protocolsForPane: aPane
    "Set the contents of the protocols pane."

    | protocols |
    aPane
        contents: (protocols := codeBrowser protocols)
        colors: (changeSet
            colorsForProtocols: protocols
            inClasses: (self realClassNamesFrom: codeBrowser selectedClasses))

!
pushCurrentState
    "Capture my current state; push it onto the top of my state stack"

    Terminal bell.
    self savedStates addLast: self state.
    (self paneNamed: 'textPane') modified: false.
    self
        updateLabel;
        updateBrowserMenu
!
realClassNamesFrom: aCollection
    "Return a collection of the given class names, with a ' class' suffix if we're viewing metaclasses."

    | classMethods |
    classMethods := codeBrowser isBrowsingClassMethods.
    ^aCollection collect: [:each |
        classMethods
            ifTrue: [each trimBlanks, ' class']
            ifFalse: [each trimBlanks]]
! 
referencesToClassVariables

    | theClass instanceVariables answer selectors |

    theClass := self deepestCommonSuperclassOf: codeBrowser selectedSmalltalkClasses.
    instanceVariables := theClass allClassVarNamesGrouped.
    answer := ChooseManyDialog new
        openOn: instanceVariables
        label: 'Class Variables of ', theClass name.

    answer notNil
        ifTrue: [
            selectors := answer inject: Set new into: [:sum :each |
                codeBrowser selectedSmalltalkClasses do: [:eachClass |
                    sum
                        addAll: (eachClass allMethodsUsingClassVar: each);
                        addAll: (eachClass class allMethodsUsingClassVar: each)].
                sum].
            MethodBrowser new
                label: 'References to ', (answer inject: '' into: [:sum :each | sum, each, ' ']);
                openOn: selectors].
! 
referencesToInstanceVariables

    | theClass instanceVariables answer selectors |

    theClass := self deepestCommonSuperclassOf: codeBrowser selectedSmalltalkClasses.
    instanceVariables := theClass allInstVarNamesGrouped.
    answer := ChooseManyDialog new
        openOn: instanceVariables
        label: 'Instance Variables of ', theClass name.

    answer notNil
        ifTrue: [
            selectors := answer inject: Set new into: [:sum :each |
                codeBrowser selectedSmalltalkClasses do: [:eachClass |
                    sum addAll: (eachClass allMethodsReferencingInstVar: each)].
                sum].
            MethodBrowser new
                label: 'References to ', (answer inject: '' into: [:sum :each | sum, each, ' ']);
                openOn: selectors].
!  
referencesToSelectedClasses
    "open a methodBrowser on all methods in Smalltalk which reference the selected classes"

    | methods allClasses label |

    allClasses := (Smalltalk rootClasses inject: OrderedCollection new into: [:sum :each |
            sum, each withAllSubclasses]).
    methods := codeBrowser selectedClasses inject: OrderedCollection new into: [:sum :each |
        sum, (self sendersOf: (Array with: (Smalltalk associationAt: each asSymbol)) in: allClasses)].

    methods isEmpty
        ifTrue: [MessageBox message: 'No references']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedClasses do: [:each |
                label nextPutAll: each.
                label space; space].
            ^MethodBrowser new
                label: 'References to ' , label contents;
                openOn: methods asSet asArray].
!
removeCategories
    "Prompt the user, then remove the selected categories, and all of the classes that they contain."

   | question classes |

    self textModified
        ifTrue: [^self].
    classes := codeBrowser selectedCategories inject: Set new into: [:sum :each |
        sum
            addAll: (codeBrowser selectedClassOrganizer elementsOfCategory: each);
            yourself].

    codeBrowser selectedCategories size > 1
        ifTrue: [question := 'Remove the selected categories?']
        ifFalse: [question := 'Remove category ', codeBrowser selectedCategory, '?'].

    (classes isEmpty or: [MessageBox confirm: question])
        ifTrue: [
            codeBrowser removeSelectedCategories.
            self updatePanesFrom: 'categories']
!
removeChangeSet

    (MessageBox confirm: 'Are you sure you want to delete the change set ', changeSet name printString, ' ?')
        ifFalse: [^self].

    CodeFiler changeSetManager remove: changeSet.
    changeSet := CodeFiler changeSetManager nonRecordingChangeSet.
    self
        updateChangeSet;
        updatePanesFrom: 'categories'
!
removeClasses
    "Remove the selected classes from Smalltalk. If there are methods in the system referencing
    the classes I'm deleting, then pop up a method browser on those methods"

    | question classes allClasses methods |

    self textModified
        ifTrue: [^self].
    codeBrowser selectedClasses size > 1
        ifTrue: [question := 'Remove the selected classes?']
        ifFalse: [question := 'Remove class ', codeBrowser selectedClass, '?'].
    (MessageBox confirm: question)
        ifFalse: [^self].

    classes := codeBrowser selectedSmalltalkClasses.
    allClasses := (Smalltalk rootClasses inject: OrderedCollection new into: [:sum :each |
            sum, each withAllSubclasses]).
    allClasses removeAll: classes.
    methods := classes inject: OrderedCollection new into: [:sum :each |
        sum, (self sendersOf: (Array with: (Smalltalk associationAt: each symbol)) in: allClasses)].

    methods notEmpty ifTrue: [
        MethodBrowser new
            label: 'References to deleted classes';
            openOn: methods asSet asArray].

    classes do: [:each |
        changeSet logChangeForRemoveClass: each].
    currentItems := changeSet itemsForCategories: codeBrowser selectedCategories.
    codeBrowser removeSelectedClasses.
    self updatePanesFrom: 'categories'



!  
removeMethods
    "remove the selected methods from the system."

    self textModified
        ifTrue: [^self].
    (MessageBox confirm: 'Really remove the selected methods?')
        ifFalse: [^self].

    changeSet
        logChangeForRemoveSelectors: codeBrowser selectedMethods
        inClass: codeBrowser selectedSmalltalkClassOrMetaclass.
    codeBrowser removeSelectedMethods.
    self updatePanesFrom: 'categories'.
!  
removeProtocols
    "Remove the selected protocols"

    | selectors protocols |

    self textModified
        ifTrue: [^self].
    selectors := codeBrowser selectedProtocols inject: Set new into: [:sum :each |
        sum
            addAll: (codeBrowser selectedMethodOrganizer elementsOfCategory: each);
            yourself].

    (selectors isEmpty or:
            [MessageBox confirm: 'Really remove all methods in the selected protocols?'])
        ifTrue: [
            protocols := codeBrowser selectedProtocols.
            codeBrowser removeSelectedProtocols.
            changeSet logChangeForRemoveProtocols: protocols inClass: codeBrowser selectedSmalltalkClassOrMetaclass.
            currentItems := changeSet itemsForClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
            ^self updatePanesFrom: 'categories']
        ifFalse: [^self]
!  
renameCategories
    "Prompt the user to rename each of the selected categories, and then rename them"

    | answer newCategories |

    self textModified
        ifTrue: [^self].

    newCategories := OrderedCollection new.
    codeBrowser selectedCategories do: [:each |
        answer := PrompterDialog
            title: 'Navigator Browser'
            prompt: 'rename ', each, ' as:'
            default: each
            history: self class previousCategories.
        (answer isNil or: [answer isEmpty])
            ifTrue: [^self]
            ifFalse: [
                newCategories add: answer.
                self class rememberCategory: answer]].
    codeBrowser
        renameSelectedCategoriesTo: newCategories;
        selectedCategories: newCategories.
    self updatePanesFrom: 'categories'.
!  
renameChangeSet
    "Prompt the user to rename the current change set"

    | newName |
    newName := Prompter
        title: 'Navigator Browser'
        prompt: 'Enter new change set name:'
        default: changeSet name.

    (newName isNil or: [newName isEmpty | (newName = changeSet name)])
        ifTrue: [^self].

    changeSet name: newName.
    self updateChangeSet
!  
renameProtocols
    "Prompt the user to rename each of the selected protocols, and then rename them"

    | answer newProtocols |

    self textModified
        ifTrue: [^self].
    newProtocols := OrderedCollection new.
    codeBrowser selectedProtocols do: [:each |
        answer := PrompterDialog
            title: 'Navigator Browser'
            prompt: 'rename ', each, ' as:'
            default: each
            history: self class previousProtocols.
        (answer isNil or: [answer isEmpty])
            ifTrue: [^self]
            ifFalse: [
                newProtocols add: answer.
                self class rememberProtocol: answer]].
    codeBrowser selectedProtocols with: newProtocols do: [:old :new |
        changeSet logChangeForRenameProtocol: old to: new inClass: codeBrowser selectedSmalltalkClassOrMetaclass].
    codeBrowser
        renameSelectedProtocolsTo: newProtocols;
        selectedProtocols: newProtocols.
    currentItems := changeSet
        itemsForClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
    self updatePanesFrom: 'protocols'.
!
restoreStateFrom: state
    "   state:  <ContainerObject>
    Restore my state from state"

    | textPane |

    textPane := self paneNamed: 'textPane'.
    codeBrowser
        selection: state selection deepCopy;
        classOrInstanceMode: state classOrInstanceMode.
    self textViewState: state textViewState.
    changeSet := state changeSet.
    textPane modified: false.
    self update.
    textPane
        contents: state text;
        modified: state isModified;
        selectFrom: state selectedTextOrigin to: state selectedTextCorner;
        invalidateRect: nil;
        forceSelectionOntoDisplay;
        setFocus.
!   
savedStates
    "   ^   <OrderedCollection withAll: <BrowserViewState>>
    Private - Answer my saved states"

    ^savedStates!  
savedStates: states
    "states   <OrderedCollection withAll: <BrowserViewState>>
    Private - Set my saved states"

    savedStates := states!  
selectCategoriesForPane: aPane
    "A (multiple) selection was made in the categories pane"

    updatesInProgress ifFalse: [
        codeBrowser selectedCategories: aPane selectedItems.
        currentItems := changeSet itemsForCategories: aPane selectedItems.
        self
            viewClassOrganization;
            updateCategoryMenu;
            updatePanesFrom: 'classes']
! 
selectChangeSetsForPane: aPane
    "The selected change set has changed"

    changeSet := aPane selectedItem.
    self updatePanesFrom: 'categories' to: 'annotation'
! 
selectClassesForPane: aPane
    "A (multiple) selection was made in the classes pane"

    updatesInProgress ifFalse: [
        codeBrowser selectedClasses: (aPane selectedItems collect: [:each | each trimBlanks asString]).
        currentItems := changeSet itemsForClasses: (self realClassNamesFrom: aPane selectedItems).
        self
            viewClassDefinition;
            updateClassMenu;
            updatePanesFrom: 'protocols']
!   
selectMethodsForPane: aPane
    "Some methods were selected from the methods pane"

    updatesInProgress ifFalse: [
        codeBrowser selectedMethods: aPane selectedItems.
        currentItems := changeSet
            itemsForMethods: (aPane selectedItems collect: [:each | each asString])
            inClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
        self
            viewMethodSource;
            updatePanesFrom: 'annotation';
            updateMethodMenu]

!   
selectProtocolsForPane: aPane
    "Some protocols were selected from aPane"

    | previousProtocol |

    updatesInProgress ifFalse: [
        codeBrowser selectedProtocols: aPane selectedItems.
        previousProtocol := codeBrowser selectedProtocol.
        previousProtocol notNil
            ifTrue: [self class previousProtocol: codeBrowser selectedProtocol].
        currentItems := changeSet
            itemsForProtocols: aPane selectedItems
            inClasses: (self realClassNamesFrom: codeBrowser selectedClasses).
        self
            viewMethodOrganization;
            updateProtocolMenu;
            updatePanesFrom: 'methods']
!
sendersOf: symbols in: classes
    "   ^  <collection of compiledMethods>
    symbols     <collection of <Symbol>
    classes        <collection of classes>
    Answer all the senders of the selected methods in classes"

    | methods |
    CursorManager execute changeFor: [
        methods := OrderedCollection new.
        classes do: [:eachClass |
            symbols do: [:eachMethod |
                methods addAll: (eachClass classSendersOf: eachMethod)]]].
    ^methods asArray

!   
sendersOfMethods
    "Open a methodBrowser on all of the senders of the selected methods
    in all Smalltalk classes"

    | methods label browser |

    methods := self sendersOf: codeBrowser selectedMethods in:
        (Smalltalk rootClasses inject: OrderedCollection new into: [:sum :each |
            sum, each withAllSubclasses]).
    methods isEmpty
        ifTrue: [^MessageBox message: 'No senders']
        ifFalse: [
            label := WriteStream on: (String new: 80).
            codeBrowser selectedMethods do: [:each |
                each printOn: label.
                label space;space].
            browser := MethodBrowser new.
            codeBrowser selectedMethods size = 1
                ifTrue: [browser literal: codeBrowser selectedMethod].
            ^browser
                label: 'Senders of ' , label contents;
                openOn: methods].
! 
sendersSubMenu
    "   ^   <Menu>
    Answer a menu with the different types of senders requests allowed"

    | theMenu |

    theMenu := Menu new
        title: 'Senders';
        owner: self;
        appendItem: 'Class' selector: #classSendersOfMethods;
        appendItem: 'Hierarchy' selector: #hierarchySendersOfMethods;
        appendItem: 'Category' selector: #categorySendersOfMethods;
"        appendItem: 'Application' selector: #applicationSendersOfMethods; "
        appendItem: 'System' selector: #sendersOfMethods;
        yourself.

    ^theMenu!
setTextViewState
    "^ <self>
    Private - Set the textViewState to whatever is appropriate for my selection and
    current browser state"

    codeBrowser selectedMethods size = 1
        ifTrue: [^self viewMethodSource].
    codeBrowser selectedMethods size > 1
        ifTrue: [^self viewNothing].

    "There are no methods selected; maybe a protocol?"
    codeBrowser selectedProtocols notEmpty
        ifTrue: [^self viewMethodOrganization].

    "There are no protocols selected; maybe a class or two?"
    codeBrowser selectedClasses size = 1
        ifTrue: [^self viewClassDefinition].
    codeBrowser selectedClasses size > 1
        ifTrue: [^self viewNothing].

    "There are no classes selected.  Maybe a category?"
    codeBrowser selectedCategories notEmpty
        ifTrue: [^self viewClassOrganization].
    codeBrowser selectedCategories isEmpty
        ifTrue: [^self viewNothing].

    "Fallthrough means that I have no idea what I'm displaying.
    I'll make the textViewState unknown."
    textViewState := #unknownViewState
! 
showMethodSourceAnnotationFor: aPane
    "Show the timeStamp for the current method, if I can find it in the change log"

    | method sourceIndex version stream |

    method := codeBrowser selectedSmalltalkClassOrMetaclass compiledMethodAt: codeBrowser selectedMethod.
    sourceIndex := method sourceIndex.

    sourceIndex = 0
        ifTrue: [^aPane contents: 'no source'].
    sourceIndex = 1
        ifTrue: [^aPane contents: 'sources.sml'].
    method sourceLibrary notNil
        ifTrue: [^aPane contents: 'library ', method sourceLibrary name].
    sourceIndex = 3
        ifTrue: [^aPane contents: 'sources sll'].
    sourceIndex = 2
        ifFalse: [^aPane contents: 'library ', sourceIndex printString].

    version := (CodeFiler forClass: codeBrowser selectedSmalltalkClassOrMetaclass)
        loadedVersionOf: codeBrowser selectedMethod.

    stream := WriteStream on: (String new: 50).
    stream
        nextPutAll: version stampPrintString.
    version hasPreviousVersions
        ifTrue: [stream nextPutAll: ' ...'].

    aPane contents: stream contents
! 
spawn
    "Spawn a new browser identical to myself"

    | browserView currentState |

    currentState := self state.
    currentState isModified: false.
    browserView := BrowserView new: codeBrowser deepCopy.
    browserView
        open;
        restoreStateFrom: currentState

!  
state
    "   ^   <ContainerObject>
    Answer a browserViewState which entirely captures my current state"

    | answer stateName textSelection |

    stateName := WriteStream on: (String new).
    codeBrowser selectedClass notNil
        ifTrue: [stateName nextPutAll: codeBrowser selectedClassOrMetaclass].
    codeBrowser selectedMethod notNil
        ifTrue: [stateName nextPutAll: '>>', codeBrowser selectedMethod].

    textSelection := (self paneNamed: 'textPane') selection.
    answer := ContainerObject new.
    answer
        changeSet: changeSet;
        selection: codeBrowser selection deepCopy;
        textViewState: self textViewState;
        text: (self paneNamed: 'textPane') contents;
        isModified: (self paneNamed: 'textPane') modified;
        name: stateName contents;
        classOrInstanceMode: codeBrowser classOrInstanceMode;
        selectedTextOrigin:  textSelection origin;
        selectedTextCorner: textSelection corner.

    ^answer
!  
textForPane: aPane
    "Set the contents of the text pane"

    (self respondsTo: self textViewState)
        ifTrue: [self perform: self textViewState with: aPane]
        ifFalse: [self privateUnknownTextForPane: aPane]
! 
textViewState
    "^ <symbol>
    Private - Answer my textViewState"

    ^textViewState! 
textViewState: state
    "state: <Symbol>
    Private - Set my textViewState"

    textViewState := state!
update
    "Update all aspects of myself"

    codeBrowser update.
    self
        updateProtocolButton;
        updateMenus;
        updatePanesFrom: 'changeSet'
! 
updateAnnotation
    "Update my annotation pane"

        (self paneNamed: 'annotation') update
! 
updateBrowserMenu
    "Update the browser menu"

    | menu statesMenu items |

    (menu := self menuTitled: 'Browser') isNil
        ifTrue: [^self].

    items := #(popLastState exchangeCurrentState clearSavedStates).
    self savedStates isEmpty
         ifTrue: [self disable: items inMenu: menu]
        ifFalse: [self enable: items inMenu: menu]
!
updateCategories
    "Update my categories pane"

    (self paneNamed: 'categories') update: #restoreSelected: with: codeBrowser selectedCategories.
    self updateCategoryMenu
!   
updateCategoryMenu
    "Update the category menu to reflect the current state of the selection"

    | menu items |

    (menu := self menuTitled: 'Category') isNil
        ifTrue: [^self].

    items := #('File Out...' renameCategories removeCategories).
    codeBrowser selectedCategories isEmpty
        ifTrue: [self disable: items inMenu: menu]
        ifFalse: [self enable: items inMenu: menu].
!   
updateChangeSet
    "Update the contents of the change set pane"

    (self paneNamed: 'changeSets') update: #restoreSelected: with: changeSet
!  
updateChangeSetAnnotation
    "Update my change set annotation pane"

        (self paneNamed: 'changeSetAnnotation') update
!
updateClasses
    "Update my classes pane"

    (self paneNamed: 'classes') update: #restoreSelected: with: codeBrowser selectedClasses.
    self updateClassMenu
!  
updateClassMenu
    "Update the class menu to reflect the current state of the selection"

    | menu items |

    (menu := self menuTitled: 'Class') isNil
        ifTrue: [^self].

    items := #(classReferencesSubMenu editClassComment 'File Out...' 'File Out All...' 'References'
        'Classify Methods' 'Get and Set...' moveClasses copyClasses removeClasses updateClassOrganizer).
    codeBrowser selectedClasses isEmpty
         ifTrue: [self disable: items inMenu: menu]
        ifFalse: [self enable: items inMenu: menu].
! 
updateClassOrganizer
    "Update my selected classes' organizers"

    self textModified
        ifTrue: [^self].
    codeBrowser selectedSmalltalkClasses do: [:each |
        (CodeFiler organizerFor: each) makeDirty;update.
         (CodeFiler organizerFor: each class) makeDirty;update].
    self updatePanesFrom: 'classes'.
! 
updateLabel
    "Update my label to say something useful about what I am browsing"

    | label |

    label := WriteStream on: (String new: 80).
    self savedStates notEmpty ifTrue: [
        label nextPut: $(; print: self savedStates size; nextPutAll: ') '].

    codeBrowser selectedClasses notEmpty
        ifTrue: [
            label
                nextPutAll: 'Browsing ';
                nextPutAll: codeBrowser selectedClass.
            codeBrowser selectedClasses size > 1
                ifTrue: [label nextPutAll: ' . . .'].
            ^self labelWithoutPrefix: label contents].
    codeBrowser selectedCategories notEmpty
        ifTrue: [
             label
                nextPutAll: 'Browsing in ';
                nextPutAll: codeBrowser selectedCategory.
            codeBrowser selectedCategories size > 1
                ifTrue: [label nextPutAll: '. . .'].
            ^self labelWithoutPrefix: label contents].
    self labelWithoutPrefix: label contents, 'Navigator Browser'
! 
updateMenus
    "Update all of my menus to reflect my selection"

    self
        updateBrowserMenu;
        updateCategoryMenu;
        updateClassMenu;
        updateProtocolMenu;
        updateMethodMenu!  
updateMethodMenu
    "Update the method menu to reflect the current state of the selection"

    | menu items |

    (menu := self menuTitled: 'Method') isNil
        ifTrue: [^self].

    codeBrowser selectedClasses size = 1
        ifTrue: [self enable: #(findMethod) inMenu: menu]
        ifFalse: [self disable: #(findMethod) inMenu: menu].

    items := #(removeMethods moveMethods copyMethodsToNewClass 'File Out...' 'Senders' 'Implementors').
    codeBrowser selectedMethods isEmpty
         ifTrue: [self disable: items inMenu: menu]
        ifFalse: [self enable: items inMenu: menu].
    codeBrowser selectedMethods size = 1
        ifTrue: [self enable: #(methodMessages browseMethodVersions) inMenu: menu]
        ifFalse: [self disable: #(methodMessages browseMethodVersions) inMenu: menu]
!   
updateMethods
    "Update my list of methods"

    (self paneNamed: 'methods') update: #restoreSelected:
        with: (codeBrowser selectedMethods collect: [:each | each asString]).
    self updateMethodMenu
!  
updatePanesAndMakeVisibleSelectionFrom: paneName
    "Set the textView to display the appropriate thing,
    and update the panes from paneName onward"

    self updatePanesAndMakeVisibleSelectionFrom: paneName to: self class paneUpdateOrder last!   
updatePanesAndMakeVisibleSelectionFrom: startPaneName to: endPaneName
    "Set the textView to display the appropriate thing,
    and update the panes from startPaneName to endPaneName"

    updatesInProgress ifFalse: [
        updatesInProgress := true.
        self privateUpdatePanesAndMakeVisibleSelectionFrom: startPaneName to: endPaneName].
    updatesInProgress := false.
    self
        setTextViewState;
        updateText!   
updatePanesFrom: paneName
    "Set the textView to display the appropriate thing,
    and update the panes from paneName onward"

    self updatePanesFrom: paneName to: self class paneUpdateOrder last! 
updatePanesFrom: startPaneName to: endPaneName
    "Set the textView to display the appropriate thing,
    and update the panes from startPaneName to endPaneName"

    updatesInProgress ifFalse: [
        updatesInProgress := true.
        self privateUpdatePanesFrom: startPaneName to: endPaneName].
    updatesInProgress := false.
    self
        setTextViewState;
        updateText! 
updateProtocolButton
    "Update my protocol button"

    (self paneNamed: 'protocolButton') update!   
updateProtocolMenu
    "Update the protocol menu to reflect the current state of the selection"

    | menu items |

    (menu := self menuTitled: 'Protocol') isNil
        ifTrue: [^self].

    codeBrowser selectedClasses size = 1
        ifTrue: [self enable: #(addProtocol findMethod) inMenu: menu]
        ifFalse: [self disable: #(addProtocol findMethod) inMenu: menu].

    items := #(copyProtocolsToNewClass renameProtocols updateClassOrganizer removeProtocols 'File Out...').
    codeBrowser selectedProtocols isEmpty
         ifTrue: [self disable: items inMenu: menu]
        ifFalse: [self enable: items inMenu: menu].
!   
updateProtocols
    "Update my protocol list"

    (self paneNamed: 'protocols') update: #restoreSelected: with: codeBrowser selectedProtocols.
    self updateProtocolMenu
!
updateStatesSubMenu
    "Update the states menu"

    | browserMenu menu |

    (browserMenu := self menuTitled: 'Browser') isNil
        ifTrue: [^self].

    menu := browserMenu subMenuTitled: 'States'.
"    menu deleteAll."
    self savedStates do: [:each |
        menu appendItem: each name action: []]

!   
updateText
    "Update the contents of the text pane"

    (self paneNamed: 'textPane') update
!  
viewChangeSetComment

    textViewState := #viewingChangeSetComment:
! 
viewClassComment

    textViewState := #viewingClassComment:!   
viewClassDefinition

    textViewState := #viewingClassDefinition:! 
viewClassOrganization

    textViewState := #viewingClassOrganization:! 
viewingChangeSetComment: aPane
    "Set the contents of aPane to be the comment of the selected change set"

    | comment |

    comment := changeSet comment.
    comment isEmpty
        ifTrue: [comment := 'No comment for this change set.'].

    aPane contents: comment.
! 
viewingClassComment: aPane
    "Set the contents of aPane to be the class comment of the selected class"

    | comment |

    comment := CodeFiler commentFor: codeBrowser selectedClass asSymbol.
    comment isEmpty
        ifTrue: [comment := 'No comment for this class.'].

    aPane contents: comment.
!  
viewingClassDefinition: aPane
    "Set the contents of aPane to be the class definition of the selected class"

    aPane contents: codeBrowser definitionString
!
viewingClassOrganization: aPane
    "Set the contents of aPane to be the organization of my codeBrowser's organizer"

    aPane contents: codeBrowser classOrganizerEditString
!  
viewingMethodOrganization: aPane
    "Set the contents of aPane to be the organization of my selected class's organizer"

    aPane contents: codeBrowser methodOrganizerEditString
! 
viewingMethodSource: aPane
    "Set the contents of the textPane to the source code of the selected method"

    aPane contents: codeBrowser selectedMethodSource

! 
viewingNothing: aPane
    "Display nothing in the textPane"

    aPane contents: String new.!  
viewMethodOrganization

    textViewState := #viewingMethodOrganization:!   
viewMethodSource

    textViewState := #viewingMethodSource:!   
viewNothing

    textViewState := #viewingNothing:! !

! CodeBrowser methods !
compile: aString in: aClass
        "Private - Accept aString as an updated
        method and compile it, logging source to
        the change log if successful."
    | answer codeFiler selector previousSourcePosition oldMethod |

    codeFiler := CodeFiler forClass: aClass.
    selector := codeFiler selectorFor: aString.
    (aClass selectors includes: selector) ifTrue: [
        oldMethod := aClass compiledMethodAt: selector.
        oldMethod sourceIndex = 2 ifTrue: [
            previousSourcePosition := oldMethod sourcePosition]].

    CursorManager execute changeFor: [
        answer := aClass compile: aString ].
    answer notNil ifTrue: [
        codeFiler
            logSource: aString
            forSelector: answer key
            withPreviousSourcePosition: previousSourcePosition].
    ^answer
!  
compile: aString notifying: aDispatcher in: aClass
        "Private - Accept aString as an updated
        method and compile it, logging source to
        the change log if successful.  Notify aDispatcher
        if the compiler detects errors."
    | answer codeFiler selector previousSourcePosition oldMethod |

    codeFiler := CodeFiler forClass: aClass.
    selector := codeFiler selectorFor: aString.
    (aClass selectors includes: selector) ifTrue: [
        oldMethod := aClass compiledMethodAt: selector.
        oldMethod sourceIndex = 2 ifTrue: [
            previousSourcePosition := oldMethod sourcePosition]].

    CursorManager execute changeFor: [
        answer := aClass compile: aString notifying: aDispatcher ].
    answer notNil ifTrue: [
        codeFiler
            logSource: aString
            forSelector: answer key
            withPreviousSourcePosition: previousSourcePosition].
    ^answer

! !

! ChangeSetBrowser class methods ! 
new
    ^super new initialize
! 
open
    ^self new open
!   
openOn: aChangeSet
    ^self new
        open;
        selectedChangeSets: (Array with: aChangeSet);
        update
! !

! ChangeSetBrowser methods !  
acceptForViewingComment: aPane
    "Accept for viewing the comment for a change set"

    changeSets first comment: aPane contents.
    aPane modified: false.
    self update
!
acceptForViewingNothing: aPane
    "Accept for viewing nothing in particular"

    aPane
        contents: '';
        modified: false
!
acceptForViewingSource: aPane
    "Accept for viewing a the source to a method item"

    "Do nothing"
    aPane
        cancel;
        modified: false
! 
acceptTextFromPane: aPane
    "Accept the text in aPane, and save it.  Call the appropriate save method depending upon
    the current textViewState."

    | acceptSelector |

    acceptSelector := 'acceptFor',
        (String with: textViewState first asUpperCase), (textViewState copyFrom: 2 to: textViewState size).
    acceptSelector := acceptSelector asSymbol.

    (self respondsTo: acceptSelector)
        ifTrue: [self perform: acceptSelector with: aPane]
        ifFalse: [self privateUnknownAcceptForPane: aPane]
! 
addChangeSet
    "Prompt the user to add a new change set"

    | name newChangeSet |

    name := Prompter
        title: 'Change Set Browser'
        prompt: 'Name of new change set?'
        default: ''.
    (name isNil or: [name isEmpty])
        ifTrue: [^self].

    newChangeSet := ChangeSet new name: name.
    CodeFiler changeSetManager add: newChangeSet.
    self
        selectedChangeSets: (Array with: newChangeSet);
        update
!   
changeSetItemsForPane: aPane
    "Display the items in my selected change set. If more than one change set is selected, then
    display nothing"

    changeSets size = 1 ifFalse: [
        aPane contents: #().
        ^self "update menus?"].

    (self respondsTo: itemSortState)
        ifTrue: [self perform: itemSortState with: aPane]
        ifFalse: [self sortByDefault: aPane]

    "aPane contents: changeSets first items"
!  
changeSetItemsMenuForPane: aPane

    | menu fileOutMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutChangeSetItemsWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    menu := Menu new
        title: 'Item';
        owner: self;
        appendSubMenu: fileOutMenu;
        appendSeparator;
        appendItem: 'Sort by Timestamp...' selector: #sortItemsByDefault;
        appendItem: 'Sort by Class...' selector: #sortItemsByClass;
        appendItem: 'Sort by Type...' selector: #sortItemsByType;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeChangeSetItems;
        yourself.

    aPane setMenu: menu.
    ^menu
!  
changeSetItemStatusForPane: aPane
    "Set the status for my selected items"

    | stream |

    items size = 1
        ifTrue: [aPane contents: items first timeDateStamp]
        ifFalse: [aPane contents: '']

!
changeSetsForPane: aPane
    "Set the change sets for aPane to be all of the change sets in the system"

    aPane contents: CodeFiler changeSetManager changeSets
!  
changeSetsMenuForPane: aPane

    | menu fileOutMenu exportMenu |

    fileOutMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self fileOutChangeSetsWith: aCodeWriterClass].
    fileOutMenu
        owner: self;
        title: 'File Out...'.

    exportMenu := CodeWriter codeWriterMenuWith: [:aCodeWriterClass | self exportChangeSetsWith: aCodeWriterClass].
    exportMenu
        owner: self;
        title: 'Export...'.

    menu := Menu new
        title: 'Change Set';
        owner: self;
        appendItem: 'Add...' selector: #addChangeSet;
        appendSeparator;
        appendSubMenu: fileOutMenu;
        appendSubMenu: exportMenu;
        appendSeparator;
        appendItem: 'Open' action: [:owner | changeSets do: [:each | each allowChanges]. self update];
        appendItem: 'Close' action: [:owner |changeSets do: [:each | each disallowChanges]. self update];
        appendSeparator;
        appendItem: 'Copy...' selector: #copyChangeSets;
        appendItem: 'Update' selector: #update;
        appendItem: 'Rename...' selector: #renameChangeSets;
        appendSeparator;
        appendItem: 'Remove...' selector: #removeChangeSets;
        yourself.

    aPane setMenu: menu.
    ^menu
!   
copyChangeSets
    "Copy the items and comments in the selected changeSets to a new change set"

    | name newChangeSet newComment |

    name := Prompter
        title: 'Change Set Browser'
        prompt: 'Name of new change set?'
        default: changeSets first name.
    (name isNil or: [name isEmpty])
        ifTrue: [^self].

    newChangeSet := ChangeSet new name: name.
    newComment := WriteStream on: (String new: 2000).
    changeSets do: [:each |
        newComment
            nextPutAll: 'Comment from: ';
            nextPutAll: each name; cr;cr;
            nextPutAll: each comment.
        each items do: [:anItem |
            newChangeSet addItem: anItem]].
    newChangeSet comment: newComment contents.

    CodeFiler changeSetManager add: newChangeSet.
    self
        selectedChangeSets: (Array with: newChangeSet);
        update
! 
createViews
    "Private - Create my views"

    | thisPane midY textY changeSetBox changeSetItemsBox statusBox textBox |

    midY := 4/9.
    textY := 9/18.
    changeSetBox := 0@0 rightBottom: (1/3)@midY.
    changeSetItemsBox := (1/3)@0 rightBottom: 1@midY.
    statusBox := 0@midY rightBottom: 1@textY.
    textBox := 0@textY rightBottom: 1@1.

    self
        addSubpane: ((thisPane := MultipleSelectListBox new)
            setName: #changeSets;
            extendedSelect;
            when: #needsContents send: #changeSetsForPane: to: self with: thisPane;
            when: #needsMenu send: #changeSetsMenuForPane: to: self with: thisPane;
            when: #changed: send: #selectChangeSetForPane: to: self with: thisPane;
            framingBlock: [:box | box scaleTo: changeSetBox]);

        addSubpane: ((thisPane := MultipleSelectListBox new)
            setName: #changeSetItems;
            extendedSelect;
            printSelector: #annotationLabel;
            when: #needsContents send: #changeSetItemsForPane: to: self with: thisPane;
            when: #needsMenu send: #changeSetItemsMenuForPane: to: self with: thisPane;
            when: #changed: send: #selectItemsForPane: to: self with: thisPane;
            framingBlock: [:box | box scaleTo: changeSetItemsBox]);

        addSubpane: ((thisPane := StaticText new)
            setName: #status;
            font: TextFont;
            when: #needsContents send: #changeSetItemStatusForPane: to: self with: thisPane;
            framingBlock: [:box | box scaleTo: statusBox]);

        addSubpane: ((thisPane := self toolTextPaneClass new)
            setName: #text;
            when: #needsContents send: #textForPane: to: self with: thisPane;
            when: #aboutToSave send: #acceptTextFromPane: to: self with: thisPane;
            framingBlock: [:box | box scaleTo: textBox])
!   
disable: menuItems inMenu: menu
    "menuItems      <collection withAll: <Symbol>>
     Disable all of the named items in menu"

    menuItems do: [:each |
        menu disableItem: each]
!   
enable: menuItems inMenu: menu
    "menuItems      <collection withAll: <Symbol>>
     Enable all of the named items in menu"

    menuItems do: [:each |
        menu enableItem: each]
!  
exportChangeSetsWith: aCodeWriterClass
    "Export the selected change sets."

    | fileName file |

    fileName := (FileDialog new saveFile: 'changes.st') file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.

    [CursorManager execute changeFor: [
        changeSets do: [:each |
            each exportOn: file with: aCodeWriterClass]]] ensure: [file close]
!
fileOutChangeSetItemsWith: aCodeWriterClass
    "File out the selected items from my change set."

    | fileName file |

    changeSets size = 1
        ifFalse: [^self].

    fileName := (FileDialog new saveFile: 'changes.st') file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.

    [CursorManager execute changeFor: [
        changeSets first itemsInFileOutOrder do: [:each |
            (items includes: each)
                ifTrue: [each fileOutOn: file with: aCodeWriterClass]]]] ensure: [file close].
!
fileOutChangeSetsWith: aCodeWriterClass
    "File out the selected change sets."

    | fileName file |

    fileName := (FileDialog new saveFile: 'changes.st') file.
    fileName isNil
        ifTrue: [^self].
    file := File newFile: fileName.

    [CursorManager execute changeFor: [
        changeSets do: [:each |
            each fileOutOn: file with: aCodeWriterClass]]] ensure: [file close]
!
initialize

    super initialize.
    changeSets := #().
    items := #().
    self
        viewNothing;
        sortByDefault
!  
initWindowSize
        "Private - Answer the initial window extent."
    ^Display extent * 3 // 5

!  
isViewingComment
    "Answer true if I am currently viewing a comment"

    ^textViewState = #viewingComment:
!   
isViewingNothing
    "Answer true if I am currently viewing nothing"

    ^textViewState = #viewingNothing:
! 
isViewingSoruce
    "Answer true if I am currently viewing the source for a change set item"

    ^textViewState = #viewingSource:
!  
open
    "Open myself"

    self
        createViews;
        labelWithoutPrefix: 'Change Set Browser';
        openWindow

! 
privateUnknownAcceptForPane: aPane
    "Private - I am viewing text which I don't know how to save.  Report an error message."

    (MessageBox confirm: 'I don''t know how to save text when I''m ', textViewState, '.  ',
        'Would you like to save the text on the clipboard?')
            ifTrue: [
                Clipboard setString: aPane contents.
                aPane modified: false]
!  
privateUnknownTextForPane: aPane
    "I don't knwo what I'm supposed to display, so set the contents of the pane
    to a message to that effect"

    aPane contents: 'I don''t know how to display for state ', textViewState printString
!
removeChangeSetItems
    "Remove the selected items from my change set."

    changeSets size = 1
        ifFalse: [^self].

    (MessageBox confirm: 'Are you sure you want to remove the selected items?')
        ifFalse: [^self].

    items do: [:each |
        changeSets first remove: each ifAbsent: []].

    changeSets first update.
    self update.

!  
removeChangeSets
    "Remove the selected change sets from the system."

    changeSets isEmpty
        ifTrue:  [^self].

    (MessageBox confirm: 'Are you sure you want to remove the selected change sets?')
        ifFalse: [^self].

    changeSets do: [:each |
        CodeFiler changeSetManager remove: each].

    self
        selectedChangeSets: #();
        update

!
renameChangeSets
    "Rename the selected change sets from the system."

    | newName |

    changeSets do: [:each |
        newName := Prompter
            title: 'Change Set Browser'
            prompt: 'New name for ', each name, '?'
            default: each name.
        (newName notNil and: [newName notEmpty]) ifTrue: [
            each name: newName]].

    self update

! 
selectChangeSetForPane: aPane
    "A (multiple) selection was made in the change set pane"

    self selectedChangeSets: aPane selectedItems.
    self selectedItems: #().
    self
        updateChangeSetMenu;
        updateFromChangeSetItemsPane
!   
selectedChangeSets: aCollection
    "Set my selected change sets to be aCollection"

    changeSets := aCollection.
    self setTextViewState.
! 
selectedItems: aCollection
    "Set my selected change set items to be aCollection"

    items := aCollection.
    self setTextViewState
!   
selectItemsForPane: aPane
    "A (multiple) selection was made in the items pane"

    self selectedItems: aPane selectedItems.
    self
        updateChangeSetItemsMenu;
        updateFromStatusPane
!  
setTextViewState
    "Set the state of my text pane"

    items size = 1
        ifTrue: [^self viewSource].

    items size > 1
        ifTrue: [^self viewNothing].

    changeSets size = 1
        ifTrue: [^self viewComment].

    ^self viewNothing
! 
sortByClass
    "Set my item sort state to be by class."

    itemSortState := #sortByClass:
!
sortByClass: aPane

    aPane contents: changeSets first itemsInClassSortOrder
!   
sortByDefault
    "Set my item sort state to be default."

    itemSortState := #sortByDefault:
! 
sortByDefault: aPane

    aPane contents: changeSets first items
! 
sortByType
    "Set my item sort state to be by type."

    itemSortState := #sortByType:
!   
sortByType: aPane

    aPane contents: changeSets first itemsInTypeSortOrder
! 
sortItemsByClass

    self
        sortByClass;
        updateFromChangeSetItemsPane

! 
sortItemsByDefault

    self
        sortByDefault;
        updateFromChangeSetItemsPane

! 
sortItemsByType

    self
        sortByType;
        updateFromChangeSetItemsPane

!   
textForPane: aPane
    "Set the contents of the text pane"

    (self respondsTo: textViewState)
        ifTrue: [self perform: textViewState with: aPane]
        ifFalse: [self privateUnknownTextForPane: aPane]

! 
update

    self
        setTextViewState;
        updateFromChangeSetPane
! 
updateChangeSetItemsMenu

  | menu menuItems |

    (menu := self menuTitled: 'Item') isNil
        ifTrue: [^self].

    menuItems := #('File Out...' removeChangeSetItems).
    items isEmpty
         ifTrue: [self disable: menuItems inMenu: menu]
        ifFalse: [self enable: menuItems inMenu: menu].

!
updateChangeSetMenu

  | menu menuItems |

    (menu := self menuTitled: 'Change Set') isNil
        ifTrue: [^self].

    menuItems := #('File Out...' 'Export...' copyChangeSets 'Open' 'Close' renameChangeSets removeChangeSets).
    changeSets isEmpty
         ifTrue: [self disable: menuItems inMenu: menu]
        ifFalse: [self enable: menuItems inMenu: menu].

!   
updateFromChangeSetItemsPane

    (self paneAt: #changeSetItems) update: #restoreSelected: with: items.
    self updateFromStatusPane
!   
updateFromChangeSetPane

    (self paneAt: #changeSets) update: #restoreSelected: with: changeSets.
    self updateFromChangeSetItemsPane
!   
updateFromStatusPane

    (self paneAt: #status) update.
    self updateFromTextPane!  
updateFromTextPane

    (self paneAt: #text) update
!  
viewComment
    "Set my text view state to be viewing a comment"

    textViewState := #viewingComment:
! 
viewingComment: aPane
    "Set the text for viewing the comment for a change set"

    aPane contents: changeSets first comment
! 
viewingNothing: aPane
    "Set the text for viewing nothing"

    aPane contents: ''
!
viewingSource: aPane
    "Set the text for viewing the source to a change set item"

    | stream |

    stream := WriteStream on: (String new: 200).
    items first fileOutSourceOn: stream with: CodeFilerClassWriter.
    aPane contents: stream contents.
!  
viewNothing
    "Set my text view state to be viewing nothing"

    textViewState := #viewingNothing:
!   
viewSource
    "Set my text view state to be viewing the source for a change set item"

    textViewState := #viewingSource:
! !

! ClassBrowser methods !  
accept: aPane
        "Private - Accept the contents of aPane as an updated
         method and compile it.  Notify aDispatcher if
         the compiler detects errors."
    | result aString codeFiler selector previousSourcePosition oldMethod |

    aString := aPane contents.
    codeFiler := CodeFiler forClass: selectedDictionary.
    selector := codeFiler selectorFor: aString.
    (selectedDictionary selectors includes: selector) ifTrue: [
        oldMethod := selectedDictionary compiledMethodAt: selector.
        oldMethod sourceIndex = 2 ifTrue: [
            previousSourcePosition := oldMethod sourcePosition]].

    result := selectedDictionary
        compile: aString
        notifying: aPane.
    aPane modified: (result isNil
        ifTrue: [true]
        ifFalse: [
            codeFiler
                logSource: aString
                forSelector: result key
                withPreviousSourcePosition: previousSourcePosition.
            result key == selectedMethod
                ifFalse: [
                    selectedMethod := result key.
                    self
                        changed: #selectors:
                        with: #restoreSelected:
                        with: selectedMethod].
            false])
! !

! ClassHierarchyBrowser methods ! 
initWindowSize
        "Private - Answer the initial
         window extent."
    ^Display extent * 3 // 5
! !

! Debugger methods !
dropMethod: oldExecutable restartingWith: newExecutable
    "Private - trim stack to oldExecutable and replace it with newExecutable."

    | process runLevel |
    process := self debuggedProcess.
    runLevel := process runable.
    runLevel > 1
        ifTrue: [process runable: 1].
    process dropTo: oldExecutable.
    process methodAt: 1 put: newExecutable.
    process returnOffsetAt: 0 put: 1.
    (oldExecutable hasBlock ~= newExecutable hasBlock
            or: [oldExecutable tempCount ~= newExecutable tempCount])
        ifTrue: [process dropFrame].
    self
        walkback;
        walkback: 1.
    self
            changed: #walkbackList:
            with: #restoreWithRefresh:
            with: 1!  
hop
        "Private - resume process for one hop, i.e., to next expression or
        assignment at any method level."
    | process |
    self resumable
        ifFalse: [^self].
    process := self debuggedProcess.
    realFrame == nil
        ifFalse:
            [process topFrame: realFrame.
            realFrame := nil].

    self expandFrame: 2.
    self expandFrame: 3.

    self label: 'hopping'.
    Process enableInterrupts: false.
    process sendFrame: 1.
    process debugger: self.
    process interruptFrame: 0.
    process runable: (process runable bitOr: 1).
    BreakPoints:= breakpointArray.
    UserInterfaceProcess := (process isUserIF
        ifTrue: [process]
        ifFalse: [nil]).
    CurrentProcess := process.
    process resume: 0
.
Transcript cr; show: 'BACK FROM RESUME IN HOP'.
0 to: 7 do: [:i | Transcript cr; show: 'At ', i printString, ' method ',
(self debuggedProcess methodAt: i) printString, ' ic = ', (self debuggedProcess icAt: i) printString].!  
singleStep
        "Private - Process single step interrupt."
    | process index oldWalkback pi |
    self debuggingProcess notNil
        ifTrue: [ self debuggingProcess resume ].
    process := Process copyStack.
    self setDebuggedProcess: process.
    pi := process stackPointerToProcessIndex:  process sendFrame.
    index := 1.
    [ ( process nextFrameAt: index ) = pi ]
        whileFalse: [ index := index + 1 ].
    index - 1 timesRepeat: [ process dropFrameWithoutProtection ].
    realFrame := process topFrame.
    process topFrame: ( process nextFrameAt: 0 ).

    process runable: 4.
    CurrentProcess := Process new.
    CurrentProcess makeUserIF.
    oldWalkback := walkback.
    browseWalkback
        ifFalse: [ self browseWalkback: 1 ].
    ( walkbackIndex = 1 and: [ self walkback = oldWalkback ] )
        ifFalse: [ self changed: #walkbackList: with: #restoreWithRefresh: with: 1 ].
    self expandTopFrame.
    self walkback: 1.
    self changed: #instance:.
    self checkMenus.
    Notifier run! !

! MethodBrowser methods !
accept: textPane
        "Private - Accept the contents of textPane as an updated
         method and compile it.  Notify textPane if
         the compiler detects errors."

    | result class aString codeFiler selector previousSourcePosition oldMethod |

    aString := textPane contents.
    class := selectedMethod classField.
    codeFiler := CodeFiler forClass: class.
    selector := codeFiler selectorFor: aString.
    (class selectors includes: selector) ifTrue: [
        oldMethod := class compiledMethodAt: selector.
        oldMethod sourceIndex = 2 ifTrue: [
            previousSourcePosition := oldMethod sourcePosition]].

    result := class
        compile: aString
        notifying: textPane.
    result isNil
        ifTrue: [^textPane modified: true]
        ifFalse: [
            codeFiler
                logSource: aString
                forSelector: result key
                withPreviousSourcePosition: previousSourcePosition.
            result key == selectedMethod selector
                ifTrue: [
                    methods at: (methods indexOf: selectedMethod)
                        put: (selectedMethod := result value)]
                ifFalse: [
                    selectedMethod := result value.
                    methods add: selectedMethod.
                    self
                        changed: #methodList:
                        with: #restoreSelected:
                        with: selectedMethod printString].
            ^textPane modified: false]
!
initWindowSize
        "Private - Answer the initial window extent."
    ^Display extent * 3 // 5
! !

! SelectorBrowser methods !   
accept: textPane
        "Private - Accept the contents of textPane as an updated
         method and compile it.  Notify textPane if
         the compiler detects errors."
    | result class aString codeFiler selector previousSourcePosition oldMethod |

    selectedMethod = method
        ifFalse: [^super accept: textPane].

    aString := textPane contents.
    class := method classField.
    codeFiler := CodeFiler forClass: class.
    selector := codeFiler selectorFor: aString.
    (class selectors includes: selector) ifTrue: [
        oldMethod := class compiledMethodAt: selector.
        oldMethod sourceIndex = 2 ifTrue: [
            previousSourcePosition := oldMethod sourcePosition]].

    result := class
        compile: aString
        notifying: textPane.
    result isNil
        ifTrue: [^textPane modified: true].
    codeFiler
        logSource: aString
        forSelector: result key
        withPreviousSourcePosition: previousSourcePosition.

    method := selectedMethod := result value.
    selectors := (method messages
        collect: [:m | (m isCompiledMethod)
            ifTrue: [m selector]
            ifFalse: [m]]) asSortedCollection.
    selectedSelector := nil.
    self changed: #selectors: ;
        changed: #methodList: .
    ^textPane modified: false
! 
initWindowSize
        "Private - Answer the initial window extent."
    ^Display extent * 3 // 5
! !

! MethodVersionBrowser class methods !
openOn: methodVersions
    "methodVersions     <IndexedCollection withAll: <MethodVersion>>
    Open a method version browser on methodVersions"

    self new
        openOn: methodVersions
! !

! MethodVersionBrowser methods !   
acceptTextForPane: aPane

    | result oldMethod codeFiler theClass previousSourcePosition selector |

    methodVersions isEmpty
        ifTrue: [^self].

    CursorManager execute changeFor: [
        theClass := methodVersions first smalltalkClass.
        codeFiler := CodeFiler forClass: theClass.
        selector := codeFiler selectorFor: aPane contents.

        (theClass selectors includes: selector) ifTrue: [
            oldMethod := theClass compiledMethodAt: selector.
            oldMethod sourceIndex = 2 ifTrue: [
                previousSourcePosition := oldMethod sourcePosition]].

        result := theClass compile: aPane contents notifying: aPane].
    result isNil
        ifTrue: [^aPane modified: true]
        ifFalse: [
            aPane modified: false.
            codeFiler
                logSource: aPane contents
                forSelector: result key
                withPreviousSourcePosition: previousSourcePosition].

    self update
!
createViews
        "Private - create the panes for the receiver window."
    | ratio thisPane |

    ratio := 2 / 5.

    self
        addSubpane: ((thisPane := ListPane new)
            setName: #list;
            addHorizontalScrollbarStyle;
            printSelector: #stampPrintString;
            when: #needsContents send: #methodVersionsForPane: to: self with: thisPane;
            when: #needsMenu send: #menuForMethodVersionsPane: to: self with: thisPane;
            when: #clicked: send: #selectedMethodVersionForPane: to: self with: thisPane;
            framingRatio: (Rectangle leftTopUnit extentFromLeftTop: 1@ratio));
        addSubpane: ((thisPane := self toolTextPaneClass new)
            setName: #text;
            when: #needsContents send: #textForPane: to: self with: thisPane;
            when: #saved send: #acceptTextForPane: to: self with: thisPane;
            framingRatio: ((Rectangle leftTopUnit rightAndDown: 0@ratio)
                extentFromLeftTop: 1@(1 - ratio))).
!   
initWindowSize
        "Private - Answer the initial window extent."
    ^Display extent * 3 // 5
!
menuForMethodVersionsPane: aPane
    "Set the menu for my method versions pane"

    | menu |

    menu := Menu new
        title: 'methodVersions';
        owner: self;
        appendItem: 'Load' action: [:owner | self acceptTextForPane: (self paneAt: #text)];
        appendSeparator;
        appendItem: 'Update' action: [:owner | self update];
        yourself.
    aPane notNil ifTrue: [aPane setMenu: menu].
    self updateMethodVersionsMenu.
    ^menu

! 
methodVersionsForPane: aPane
    "Set the method version for my method versions pane"

    aPane contents: methodVersions
!   
openOn: aCollection
    "aCollection        <IndexedCollection withAll: <MethodVersion>>"

    methodVersions := aCollection.
    self
        createViews;
        updateLabel;
        openWindow
! 
selectedMethodVersionForPane: aPane
    "a method version was selected"

    selectedVersion := aPane selectedItem.
    self
        updateMethodVersionsMenu;
        updateTextPane
!
textForPane: aPane
    "Set the text for my text pane to be the source of the selected methodVersion"


    selectedVersion isNil
        ifTrue: [aPane contents: String new]
        ifFalse: [aPane contents: selectedVersion source]
! 
update
    "Update myself by reloading all of my method versions"

    self
        updateListPane;
        updateTextPane
!
updateLabel

    | version |

    methodVersions isEmpty
        ifTrue: [^self labelWithoutPrefix: 'Method Version Browser'].

    version := methodVersions first.
    self labelWithoutPrefix: 'Versions of ', version smalltalkClass name, '>>', version selector
!  
updateListPane
    "Reload my list pane with all versions of the selected method"

    | loadedVersion |

    methodVersions isEmpty
        ifTrue: [^self].

    loadedVersion := (CodeFiler forClass: methodVersions first smalltalkClass)
        loadedVersionOf: methodVersions first selector.

    methodVersions := loadedVersion withAllPreviousVersions.
    selectedVersion := nil.
    (self paneAt: #list) update: #restoreSelected: with: selectedVersion
!  
updateMethodVersionsMenu

    | menu |

    (menu := self menuTitled: 'methodVersions') isNil
        ifTrue: [^self].

    selectedVersion isNil
        ifTrue: [menu disableItem: 'Load']
        ifFalse: [menu enableItem: 'Load']
!   
updateTextPane

    (self paneAt: #text) update
! !

! TextWindow methods !  
initWindowSize
        "Private - Answer the initial size of the receiver."
    ^Display extent * 3 // 5
! !

! ChooseOneDialog methods !
addListBox
        "private - Add the listbox to the receiver"

    | charSize lineHeight thisPane |

    charSize := WindowDialog unitMultiplier.
    lineHeight := charSize y.

    self addSubpane: ((thisPane := ListBox new)
        owner: self;
        contents: contents;
        when: #needsContents send: #choices: to: self with: thisPane;
        when: #changed: send: #setSelectedItem: to: self with: thisPane;
        when: #doubleClicked: send: #selectedItem: to: self with: thisPane;
        framingBlock:   [:box | (box leftTop
            rightAndDown: (5@2) * charSize)
            extentFromLeftTop: (25 @ 13) * charSize]).
!  
cancel: aButton
        "private - the cancel button was pressed.  Close the window
         and set the seletion to nil."

    self selection: nil;
          close.!   
choices: aPane
    "private - Set the listBox's choices"

    aPane contents: self contents.!  
contents
    "private - Get the value of contents."

    ^contents!
initWindowSize
        "private - return the default size of a ChooseOneDialog"

    ^35 @ 20 * WindowDialog unitMultiplier.!  
ok: aButton
        "private -- The OK button was pressed; it a selection
        has been made, close the window, otherwise beep in
        frustration"

    self selection isNil ifTrue:    [
        Terminal bell
    ] ifFalse:  [
        self close
    ].!  
openOn: aCollection label: aString

    "open a dialog to let the user choose one string of many.
     aCollection may contain strings or symbols."

    | charSize lineHeight thisPane |

    self labelWithoutPrefix: aString.
    charSize := WindowDialog unitMultiplier.
    lineHeight := charSize y.

    contents := aCollection.

    self addListBox.

    self addSubpane:
        ((thisPane := Button new)
                owner: self;
                defaultPushButton;
                contents: 'Ok';
                when: #clicked send: #ok: to: self with: thisPane;
                framingBlock:   [:box | (box leftTop
                    rightAndDown: (5@16) * charSize)
                    extentFromLeftTop: (7@2) * charSize]).

    self addSubpane:
        ((thisPane := Button new)
                owner: self;
                contents: 'Cancel';
                when: #clicked send: #cancel: to: self with: thisPane;
                framingBlock:   [:box | (box leftTop
                    rightAndDown: (23@16) * charSize)
                    extentFromLeftTop: (7@2) * charSize]).

    self openWindow.
    ^self selection
! 
selectedItem: aListBox
        "private -- set the selection to the selected item,
         and close the window"

    self setSelectedItem: aListBox;
          close.! 
selection
        "private - return the current selection"

    ^selection!
selection: anObject
        "private - set selection to anObject"

    ^selection := anObject.!
setSelectedItem: aListBox
        "private -- set the selection to the selected item"

    self selection: aListBox selectedItem.! !

! ChooseManyDialog methods !   
addListBox
        "private - Add the listbox to the receiver, in this case, a multipleSelectListBox"

    | charSize lineHeight thisPane |

    charSize := WindowDialog unitMultiplier.
    lineHeight := charSize y.

    self addSubpane:
        ((thisPane := MultipleSelectListBox new)
                owner: self;
                extendedSelect;
                contents: contents;
                when: #needsContents send: #choices: to: self with: thisPane;
                when: #changed: send: #select: to: self with: thisPane;
                when: #doubleClicked: send: #returnSelection: to: self with: thisPane;
                framingBlock:   [:box | (box leftTop
                    rightAndDown: (5@2) * charSize)
                    extentFromLeftTop: (25 @ 13) * charSize]).
! 
ok: aButton
        "private -- The OK button was pressed; it a selection
        has been made, close the window, otherwise beep in
        frustration"

    self selection isNil ifTrue:    [
        Terminal bell
    ] ifFalse:  [
        self close
    ].!  
returnSelection: aPane
    "private - Get the pane's selections, and return them to the caller"

    self selection: aPane getSelection.
    self close.! 
select: aPane
        "private - an item was selected in aPane, so freshen the list of selected items."

        self selection: aPane getSelection!   
selection: aCollection
        "private - set the selection to be an array of the selected choices
        from the contents array"

    aCollection isNil ifTrue: [
        ^selection := nil
    ].

    selection := Array new: aCollection size.
    1 to: aCollection size do:   [:anIndex |
        selection at: anIndex put: (contents at: (aCollection at: anIndex))
    ].! !

! GetAndSetBuilder methods !
addGetAndSetFor: aCollection in: aClass on: stream
    "Add get and set methods for the instance variables in aCollection, which is a collection of two-element arrays.
    The first element is the symbol for the instance variable name, the second is a symbol for the type."

    | instVarName instVarType type |
    stream
        nextPut: $!!;
        nextPutAll: aClass name;
        nextPutAll: ' methodsFor: ''accessing'' !!'.

    aCollection do: [:pair |
        instVarName := pair first asString.
        instVarType := pair last asString.
        instVarType at: 1 put: (instVarType first asUpperCase).
        type := (instVarType first isVowel
            ifTrue: ['an']
            ifFalse: ['a']), instVarType.
        (aClass instVarNames includes: instVarName)
            ifFalse: [self error: 'Bad instance variable name.'].
        stream
            cr; cr;
            nextPutAll: instVarName;
            cr; cr;
            nextPutAll: '    ^';
            nextPutAll: instVarName;
            nextPut: $!!;
            cr; cr;
            nextPutAll: instVarName;
            nextPutAll: ': ';
            nextPutAll: type;
            cr; cr;
            nextPutAll: '    ';
            nextPutAll: instVarName;
            nextPutAll: ' := ';
            nextPutAll: type;
            nextPut: $!!].

    stream nextPutAll: ' !!'!  
addGetAndSetFor: aCollection in: aClass withNewInitialize: aBoolean
    "Add get and set methods for the instance variables in aCollection, which is a collection of two-element arrays.
    The first element is the symbol for the instance variable name, the second is a symbol for the type.
    If aBoolean is true, also add a new-initialize pair of methods.
    Example usage:
        self addGetAndSetFor: #((x Integer) (y Integer)) in: Point withNewInitialize: false."

    | stream |
    stream := ReadWriteStream on: (String new: 100).
    aBoolean
        ifTrue: [self addNewInitializeFor: aCollection in: aClass on: stream].
    self addGetAndSetFor: aCollection in: aClass on: stream.
    stream
        position: 0;
        fileIn!
addNewInitializeFor: aCollection in: aClass on: stream
    "Add a new and an initialize method for aClass. aCollection is a collection of two-element arrays.
    The first element is the symbol for the instance variable name, the second is a symbol for the type."

    | instVarName instVarType |
    stream
        nextPut: $!!;
        nextPutAll: aClass name;
        nextPutAll: ' methodsFor: ''initializing'' !!';
        cr; cr;
        nextPutAll: 'initialize';
        cr; cr;
        nextPutAll: '    self';
        cr.
    aCollection do: [:pair |
        instVarName := pair first asString.
        instVarType := pair last asSymbol.
        stream
            nextPutAll: '        ';
            nextPutAll: instVarName;
            nextPutAll: ': '.
        stream nextPutAll: ((Smalltalk includesKey: instVarType)
            ifTrue: [instVarType, ' new']
            ifFalse: ['nil']).
        pair == aCollection last
            ifFalse: [
                stream
                    nextPut: $;;
                    cr]].
    stream
        nextPutAll: '!! !!';
        cr; cr;
        nextPut: $!!;
        nextPutAll: aClass class name;
        nextPutAll: ' methodsFor: ''instance creation'' !!';
        cr; cr;
        nextPutAll: 'new';
        cr; cr;
        nextPutAll: '    ^super new initialize!! !!';
        cr; cr!  
build: aPane

    | collection |
    collection := OrderedCollection new.
    self typeMap associationsDo: [:pair |
        pair value isNil
            ifFalse: [collection add: (Array with: pair key with: pair value)]].
    self
        addGetAndSetFor: collection in: self editedClass withNewInitialize: newInitializeFlag;
        close! 
buildTypeMap

    self editedClass instVarNames do: [:name |
        self typeMap at: name put: nil]!  
clickedNewInitialize: aPane

    newInitializeFlag := aPane selection!  
currentType

    | type |
    ^(type := self typeMap at: self instVar) isNil
            ifTrue: [self dontUseString]
            ifFalse: [type]!   
defaultInstVar: aString

    instVar := aString!
defaultTypeList

    ^#('Object' 'String' 'Integer' 'Number' 'Array' 'Collection' 'Dictionary' 'Stream'
        'Character' 'Date' 'Time' 'Symbol' 'Bitmap' 'Pen' 'Class' 'Boolean' 'Float'
        'Point' 'Rectangle' 'Block') asSet
            add: self dontUseString;
            yourself!   
dontUseString

    ^'** Don''t use **'! 
editedClass

    ^editedClass!  
editedClass: aClass

    editedClass := aClass! 
enteredType: aPane

    | aString |
    aString := aPane contents.
    aString = self dontUseString
        ifTrue: [self typeMap at: self instVar put: nil]
        ifFalse: [
            self typeMap at: self instVar put: aString.
            self types add: aString].
    self updateArgumentTypesPane
!
exit: aPane

    self close!
getClassName: aPane

    aPane contents: self editedClass name! 
getInstVarList: aPane

    aPane
        contents: self editedClass instVarNames;
        selection: self instVar
!  
getInstVarType: aPane

    aPane contents: self currentType!
getInstVarTypeList: aPane

    aPane
        contents: self types asSortedCollection;
        selection: self currentType!
initWindowSize

    ^WindowDialog inDialogUnits: 384@324

!   
instVar

    ^instVar!  
openOn: aClass

    | theClass thisPane  font boldFont |
    theClass := aClass.
    theClass isNil | theClass isBehavior not
        ifTrue: [theClass := self class].
    theClass instVarNames isEmpty
        ifTrue: [^MessageBox message: 'No instance variables for ', theClass name].

    newInitializeFlag := false.
    font := TextFont.
    boldFont := (Font fromFont: TextFont graphicsMedium: Display)
        bold: true;
        makeFont;
        yourself.

    self
        editedClass: theClass;
        defaultInstVar: theClass instVarNames first;
        typeMap: Dictionary new;
        types: self defaultTypeList;
        buildTypeMap;

        label: 'Get & Set Builder';
        owner: self;

        addSubpane: (StaticText new
            font: font;
            contents: 'Class:';
            framingRatio: (1/16 @ (1/16) extent: 3/16 @ (1/16)));

        addSubpane: (StaticText new
            font: boldFont;
            when: #getContents perform: #getClassName:;
            framingRatio: (1/4 @ (1/16) extent: 11/16 @ (1/16)));

        addSubpane: (StaticText new
            font: font;
            contents: 'Instance Variable:';
            framingRatio: (1/16 @ (3/16) extent: 1/2 @ (1/16)));

        addSubpane: (StaticText new
            font: font;
            contents: 'Type:';
            framingRatio: (5/8 @ (3/16) extent: 5/16 @ (1/16)));

        addSubpane: ((thisPane := ListBox new)
            setName: #instanceVariables;
            font: font;
            when: #needsContents send: #getInstVarList: to: self with: thisPane;
            when: #changed: send: #selectInstVar: to: self with: thisPane;
            framingRatio: (1/16 @ (5/16) extent: 1/2 @ (1/2)));

        addSubpane: ((thisPane := EntryField new)
            setName: #argumentType;
            font: font;
            when: #needsContents send: #getInstVarType: to: self with: thisPane;
            when: #changed: send: #enteredType: to: self with: thisPane;
            framingRatio: (5/8 @ (5/16) extent: 5/16 @ (5/64)));

        addSubpane: ((thisPane := ListBox new)
            setName: #argumentTypes;
            font: font;
            when: #needsContents send: #getInstVarTypeList: to: self with: thisPane;
            when: #changed: send: #selectInstVarType: to: self with: thisPane;
            framingRatio: (5/8 @ (7/16) extent: 5/16 @ (3/8)));

        addSubpane: ((thisPane := Button new)
            font: font;
            contents: 'Build';
            when: #clicked send: #build: to: self with: thisPane;
            framingRatio: ((1/16 @ (7/8) extent: 1/4 @ (1/16)) expandBy: 0 @ (1/64)));

        addSubpane: ((thisPane := CheckBox new)
            font: font;
            contents: 'New/Initialize';
            when: #clicked: send: #clickedNewInitialize: to: self with: thisPane;
            framingRatio: ((3/8 @ (7/8) extent: 5/16 @ (1/16)) expandBy: 0 @ (1/64)));

        addSubpane: ((thisPane := Button new)
            font: font;
            contents: 'Exit';
            when: #clicked send: #exit: to: self with: thisPane;
            framingRatio: ((11/16 @ (7/8) extent: 1/4 @ (1/16)) expandBy: 0 @ (1/64)));

        openWindow
!
selectInstVar: aPane

    instVar := aPane selectedItem.
    self
        updateArgumentTypePane;
        updateArgumentTypesPane
! 
selectInstVarType: aPane

    | selection |
    selection := aPane selectedItem.
    selection = self dontUseString
        ifTrue: [self typeMap at: self instVar put: nil]
        ifFalse: [
            self typeMap at: self instVar put: selection.
            self types add: selection].
    self updateArgumentTypePane

!   
typeMap

    ^typeMap!  
typeMap: aDictionary

    typeMap := aDictionary!   
types

    ^types!  
types: aCollection

    types := aCollection!   
updateArgumentTypePane

    (self paneAt: #argumentType) update
!  
updateArgumentTypesPane

    (self paneAt: #argumentTypes) update
! !

! PrompterDialog class methods !  
title: titleString prompt: promptString default: defaultAnswerString history: aCollectionOfStrings
    "   ^   <String>
    Open an instance of the receiver"

    ^self
        title: titleString
        prompt: promptString
        default: defaultAnswerString
        history: aCollectionOfStrings
        onCancelDo: [nil]
! 
title: titleString prompt: promptString default: defaultAnswerString history: aCollectionOfStrings onCancelDo: cancelBlock
    "   ^   <String>
    Open an instance of the receiver"

    ^self new
        title: titleString
        prompt: promptString
        default: defaultAnswerString
        history: aCollectionOfStrings
        onCancelDo: cancelBlock
! !

! PrompterDialog methods !   
cancel
    "Close myself, and evaluate my cancel block"

    answer := nil.
    self close.
!
cancelBlock: aZeroArgumentBlock
    cancelBlock := aZeroArgumentBlock
! 
contentsForText

    | oldAnswers comboBox |

    oldAnswers := previousAnswers reject: [:each | each = defaultAnswer].
    comboBox := (self paneAt: #text).
    comboBox
        contents: (Array with: defaultAnswer), oldAnswers;
        selection: defaultAnswer
! 
createPanes
        "Private - create the panes for the receiver."

    | lineHeight charSize pane font |

    charSize := WindowDialog unitMultiplier.
    lineHeight := charSize y.

    ( pane := self topPaneClass new )
        owner: self;
        labelWithoutPrefix: title;
        font: ButtonFont.
    self addView: pane.

    self addSubpane:
        (StaticText new
            setName: #prompt;
            leftJustified;
            contents: prompt;
            framingBlock: [:box |
                (box leftTop rightAndDown: 1@1 * charSize)
                    extentFromLeftTop: 38@1 * charSize ] ).

    self addSubpane:
        (AutoSelectComboBox dropDown
            setName: #text;
            when: #needsContents send: #contentsForText to: self;
            framingBlock: [:box |  (box leftTop rightAndDown: (1 @ (5/2)) * charSize)
                extentFromLeftTop: ((38 @ (5)) * charSize) rounded ] ).

    self addSubpane:
        ( ( pane := Button new )
            setName: #ok;
            defaultPushButton;
            contents: 'Ok';
            when: #clicked send: #ok to: self;
            framingBlock: [:box | (box leftTop rightAndDown: (1 @ 6) * charSize)
                extentFromLeftTop: 10@2 * charSize ] ).

    self addSubpane:
        ( ( pane := Button new )
            setName: #cancel;
            pushButton;
            contents: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [:box | (box leftTop rightAndDown: (12 @ 6) * charSize)
                extentFromLeftTop: 10@2 * charSize ] )
! 
defaultAnswer: aString
    defaultAnswer := aString
!   
initialize

    super initialize.
    self
        title: 'Prompter';
        prompt: '';
        defaultAnswer: String new;
        previousAnswers: #();
        cancelBlock: [nil].
! 
initWindowSize
        "Private - Answer the window size."
    ^40 @ (33/4) * WindowDialog unitMultiplier


!
ok
    "Close myself, and answer what's in my text pane"

    answer := (self paneAt: #text) text.
    self close
!  
previousAnswers: aCollectionOfStrings
    previousAnswers := aCollectionOfStrings
! 
prompt: aString
    prompt := aString
! 
title: aString
    title := aString
!   
title: titleString prompt: promptString default: defaultAnswerString history: aCollectionOfStrings onCancelDo: aZeroArgumentBlock
    "Schedule and open myself. If the user pressed cancel, then answer my cancel block's value"

    self
        title: titleString;
        prompt: promptString;
        defaultAnswer: defaultAnswerString;
        previousAnswers: aCollectionOfStrings;
        cancelBlock: aZeroArgumentBlock;
        createPanes;
        openWindow.

    answer isNil ifTrue: [
        answer := cancelBlock value].
    ^answer
! !

! ApplicationWindow methods !  
compressChanges
    "Compress the change log."

    (MessageBox confirm: 'Are you sure you want to compress the change log?',
            ' (The image will be saved after compressing...)')
        ifFalse: [^self].

    SourceManager current newCompressChanges!  
compressSources
    "Compress the sources file."

    (MessageBox confirm: 'Are you sure you want to compress the sources?',
            ' (The image will be saved after compressing...)')
        ifFalse: [^self].

    SourceManager current compressSources
!
implementorsOfSelection

    self activeTextPane notNil
        ifTrue: [self activeTextPane implementorsOfSelection]
!   
oldzoom
        "Private - Make the subpane with the focus zoom to fill the entire
        client area; if the subpane with the focus is the child of a GroupPane,
        zoom the whole (topmost) GroupPane."
    | pane bottomPane group mainWindow |
    ( pane := bottomPane := self subPaneWithFocus ) isNil
        ifTrue: [ ^self ].
    mainWindow := self mainWindow.
    [ pane parent == mainWindow ]
        whileFalse: [pane := pane parent].
    pane zoom.
    bottomPane setFocus.
    self updateZoomMenu
!  
referencesOfSelection

    self activeTextPane notNil
        ifTrue: [self activeTextPane referencesOfSelection]
!   
sendersOfSelection

    self activeTextPane notNil
        ifTrue: [self activeTextPane sendersOfSelection]
! 
zoom
        "Private - Make the active text pane zoom to fill the entire
        client area; If there is no active text pane, then zoom the pane with focus."
    | pane bottomPane group mainWindow |
    ( pane := bottomPane := self activeTextPane ) isNil
        ifTrue: [^self oldzoom].

    mainWindow := self mainWindow.
    [ pane parent == mainWindow ]
        whileFalse: [pane := pane parent].
    pane zoom.
    bottomPane setFocus.
    self updateZoomMenu
! !

! DrawnButton methods !
drawItem: aDrawStruct
        "Private - Draw the requested control item."
    bitmap isNil ifTrue: [
        self event: #drawItem.
        self triggerEvent: #drawItem.
        ^true ].
    self perform: drawSelector with: aDrawStruct.
    ^true! !

! AutoSelectComboEntryField class methods !  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #characterTyped: ;
        yourself

! !

! AutoSelectComboEntryField methods !   
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Send the characterTyped: event with the key"

    | virtualKey character |
    virtualKey := aKeyboardInputEvent virtualKey.
    (virtualKey == TabKey or: [ virtualKey == BacktabKey ]) ifFalse: [
        character := aKeyboardInputEvent character.
        character notNil
            ifTrue: [self triggerEvent: #characterTyped: with: character]].

    ^super keyboardInput: aKeyboardInputEvent
! !

! TextPaneControl methods ! 
copySelection
        "Copy current selection to the clipboard."

    super copySelection.
    self selectFrom: self getSelection y + 1 to: self getSelection y + 1
!
implementorsOfSelection

    Smalltalk implementorsOf: self selectedItem trimBlanks asSymbol
! 
referencesOfSelection

    | name |
    name := self selectedItem trimBlanks asSymbol.
    (Smalltalk includesKey: name)
        ifTrue: [Smalltalk sendersOf: (Smalltalk associationAt: name)]
        ifFalse: [MessageBox warning: name, ' is not a global variable.']
!
sendersOfSelection

    Smalltalk sendersOf: self selectedItem trimBlanks asSymbol! !

! ListBox methods !
contents: aCollection
        "Set the receiver's contents to aCollection."
    list := aCollection.
    self isHandleOk ifTrue: [
        self
            deleteAllFromControl;
            insertArray: list;
            updateHorizontalExtent].
     ^list! !

! ComboBox methods !   
enableRedraw
        "Allow the receiver to be redrawn; force the receiver to
        repaint itself."
    self isHandleOk
        ifTrue: [
            handle enableRedraw.
            self invalidateRect: nil ]
        ifFalse: [ self whenValid: #enableRedraw ]

! !

! AutoSelectComboBox methods !   
characterTyped: aCharacter
    "Private - aCharacter was typed in my entry field"

    | typedString matchString oldSelection |

    typedString := self entryField contents.
    oldSelection := self entryField selection.
    (aCharacter = Bs or: [aCharacter = Del]) ifFalse: [
        matchString := self match: typedString.
        self entryField contents: matchString.

        "Determine whether to select, or just place the I-beam in the string"
        (oldSelection y < oldSelection x and: [matchString = typedString])
            ifTrue: [self entryField selectFrom: oldSelection x to: oldSelection y]
            ifFalse: [self entryField selectFrom: (typedString size + 1) to: (matchString size + 1)]]
!  
entryFieldClass
        "Private - answer the class of the entry field part of the receiver."
    ^AutoSelectComboEntryField
! 
match: aString
    "Private - answer the first string from my list who's begining matches aString.
    Answer aString if none match"

    | size |

    size := aString size.
    ^self list
        detect: [:first | aString = (first copyFrom: 1 to: (size min: first size))]
        ifNone: [aString].

! 
selectAnswer
    "Private - Select the contents of my entry field. Do this when I open"

    self entryField isNil
        ifTrue: [
            self
                sendInputEvent: #setEntryField;
                sendDeferredEvent: #selectAnswer]
        ifFalse: [
            self entryField selectFrom: 1 to: self entryField contents size]
!   
selection: aString
    "Set my selection to be aString. Select it as well."

    super selection: aString.
    self sendDeferredEvent: #selectAnswer
!   
setEntryField
        "Private - Set the entry field control in the receiver."

    super setEntryField.
    self entryField
        when: #characterTyped: send: #characterTyped: to: self.
! !

! MultipleSelectListBox methods !   
restoreSelected
    "Refresh the list from the owner. Reselect any items in the old selection which are still in the list"

    ^self restoreSelected: self selectedItems.!
restoreSelected: aCollection
    "Refresh the list from the owner. select the items in aCollection"

    | first stringCollection |
    stringCollection := aCollection collect: [:each | (self stringForItem: each) trimBlanks].
    first := self getTopIndex.
    self
        noRedraw: true;
        triggerEvent: #needsContents;
        setTopIndex: first.
    1 to: self contents size do: [:index |
        (stringCollection indexOf: (self stringForItem: (self contents at: index)) trimBlanks) > 0
            ifTrue: [self selectIndex: index]].
    self
        noRedraw: false;
        invalidateRect: self rectangle.!   
selectIndex: itemIndex
        "Select the item at itemIndex. Index starts at 1.
        Trigger the changed event.
	Fixed to handle image restarting (where itemIndex is a collection of indices)"

	itemIndex isCollection ifTrue: [
		^itemIndex do: [:each | self selectIndex: each]].

    ( ( self isIndexValid: itemIndex ) and: [ ( self valueIndices includes: itemIndex ) not ] ) ifTrue: [
        self
            selectIndexPrivate: itemIndex;
            triggerChanged]! !

! ColorMultipleSelectListBox class methods !   
highlightColorFor: aColor

    ^self highlightColorMap
        at: aColor
        ifAbsent: [aColor]! 
highlightColorMap
    " (ColorMultipleSelectListBox highlightColorMap) "

    HighlightColorMap isNil
        ifTrue: [self initializeHighlightColorMap].

    ^HighlightColorMap!  
initializeHighlightColorMap
    " (ColorMultipleSelectListBox initializeHighlightColorMap) "

    HighlightColorMap := Dictionary new
        at: ClrBlack put: ClrWhite;
        at: ClrBlue put: ClrGreen;
        at: ClrDarkcyan put: ClrCyan;
        at: ClrDarkgreen put: ClrGreen;
        at: ClrDarkred put: ClrRed;
        at: ClrRed put: ClrGreen;
        yourself
! !

! ColorMultipleSelectListBox methods !
colors
    "Answer my array of item colors"

    ^colors!  
colors: anArray
    "Set my array of item colors"

    colors := anArray!  
contents: anIndexedCollection
    "Set my contents.  Set my colors to an array of ClrBlack"

    | colorArray |
    colorArray := Array new: anIndexedCollection size.
    1 to: (colors size min: colorArray size) do: [:index |
        colorArray at: index put: (colors at: index)].
    colorArray size > colors size
        ifTrue: [colors size + 1 to: colorArray size do: [:index | colorArray at: index put: self defaultColor]].

    ^self contents: anIndexedCollection colors: colorArray!   
contents: anIndexedCollection colors: colorArray
    "Set my contents, and their associated colors"

    self colors: colorArray.
    ^super contents: anIndexedCollection!   
defaultColor

    ^ClrBlack!
defaultStyle
        "Private - Answer the default style for multiple selection."

    ^super defaultStyle!
drawHighlight: aDrawStruct
    "Private - Highlight the item to be drawn."

    | box color |
    self ownerDrawPen
        handle: aDrawStruct hDC.

    box := aDrawStruct boundingBox.
    color := colors at: self drawIndex.
    self ownerDrawPen
        fill: box color: self highlightColor;
        foreColor: (self highlightTextColorFor: color);
        setTextAlign: TaTop;
        setBackMode: Transparent;
        displayText: self itemAboutToBeDrawn
        at: (box leftTop right: 2)
!
drawItem: aDrawStruct
    "Private - Draw the requested control item."

    | index color |
    index := self drawIndex.

    (self propertyAt: #debugMode) notNil
        ifTrue: [].

    (self isValidDrawIndex: index)
        ifFalse: [^self].

    color := self colors at: index.
    color isNil
        ifTrue: [color := self defaultColor].
    self pen
        fill: self drawBox color: self backColor;
        foreColor: color;
        setTextAlign: TaTop;
        setBackMode: Transparent;
        displayText: self itemAboutToBeDrawn
        at: (self drawBox leftTop right: 2)!
highlight: aDrawStruct
    "Private - Highlight the item to be drawn."

    | box color |
    self ownerDrawPen
        handle: aDrawStruct hDC.

    box := aDrawStruct boundingBox.
    color := colors at: self drawIndex.
    self ownerDrawPen
        fill: box color: self highlightColor;
        foreColor: (self highlightTextColorFor: color);
        setTextAlign: TaTop;
        setBackMode: Transparent;
        displayText: self itemAboutToBeDrawn
        at: (box leftTop right: 2)!  
highlightColor

    ^ClrDarkcyan!   
highlightTextColorFor: aColor

    ^self class highlightColorFor: aColor!   
isValidDrawIndex: index
    "   ^   true | false
    Answer true if index is in range; false otherwise"

    ^index <= self contents size!
itemAboutToBeDrawn
    "Answer the item about to be drawn"


    ^self stringForItem: (self contents at: self drawIndex)! 
stringForItem: item
    "Private - answer a String to insert in the host control for the given item."

    | printSelector |
    ^(printSelector := self printSelector) isNil
        ifTrue: [
            item isString
                ifTrue: [item]
                ifFalse: [item printString]]
        ifFalse: [item perform: printSelector]! !

! GroupBox methods !  
backColor: aColor
    super backColor: aColor.
    self propagate: #backColor: with: aColor!
buttonFont: aFont
    super buttonFont: aFont.
    self font: aFont.
    self propagate: #buttonFont: with: aFont! 
colorChange
    super colorChange.
    self propagate: #colorChange!
controlColor: aDeviceContext
    super controlColor: aDeviceContext.
    self propagate: #controlColor: with: aDeviceContext!   
font: aFont
    super font: aFont.
    self propagate: #font: with: aFont!  
foreColor: aColor
    super foreColor: aColor.
    self propagate: #foreColor: with: aColor!
initSize: aRectangle
    super initSize: aRectangle.
    self propagate: #initSize: with: rectangle
!  
listFont: aFont
    super listFont: aFont.
    self font: aFont.
    self propagate: #listFont: with: aFont!   
propagate: selector
    self childrenInBuildOrder do: [:subpane |
        subpane perform: selector]!   
propagate: selector with: parameter
    self childrenInBuildOrder do: [ :subpane |
        subpane perform: selector with: parameter]!  
propagate: selector with: parameter1 with: parameter2
    self childrenInBuildOrder do: [ :subpane |
        subpane perform: selector with: parameter1 with: parameter2]!  
resize: aRectangle
    super resize: aRectangle.
    self propagate: #resize: with: rectangle!  
textFont: aFont
    super textFont: aFont.
    self font: aFont.
    self propagate: #textFont: with: aFont!   
update
    self propagate: #update! !

! GroupPane methods !   
buttonFont: aFont
    super buttonFont: aFont.
    self font: aFont.
    self propagate: #buttonFont: with: aFont! 
font: aFont
    super font: aFont.
    self propagate: #font: with: aFont!  
listFont: aFont
    super listFont: aFont.
    self font: aFont.
    self propagate: #listFont: with: aFont!   
propagate: selector
    self childrenInBuildOrder do: [ :subpane |
        subpane perform: selector]!  
propagate: selector with: parameter
    self childrenInBuildOrder do: [ :subpane |
        subpane perform: selector with: parameter]!  
propagate: selector with: parameter1 with: parameter2
    self childrenInBuildOrder do: [ :subpane |
        subpane perform: selector with: parameter1 with: parameter2]!  
textFont: aFont
    super textFont: aFont.
    self font: aFont.
    self propagate: #textFont: with: aFont!   
update
    self propagate: #update! !

! TextPane methods !
copySelection
        "Copy current selection to the clipboard."

    | corner |

    corner := selection corner.

    self
        fillCopyBuffer;
        selectFrom: corner + (1@0) to: corner
! 
findWildcardSelector: wildPattern
    "wildPattern        <String>
    Return the name of the selector specified by wildPattern, which includes the wildcard character.
    If the wildPattern is just *, however, answer * because the user probably means it litterally.
    ** will answer all of the selectors in Smalltalk, and is not used as a selector anywhere (yet) anyways."

    | candidates selector pattern |

    wildPattern = '*'
        ifTrue: [^wildPattern].
    pattern := Pattern new: wildPattern.
    candidates := Set new: 100.
    SourceManager current getSourceClasses do: [:aClass |
        aClass selectors do: [:each |
            (pattern matches: each)
                ifTrue: [candidates add: each]].
        aClass class selectors do: [:each |
            (pattern matches: each)
                ifTrue: [candidates add: each]]].

    candidates isEmpty ifTrue: [
        MessageBox message: 'No matching selectors'.
        ^nil].

    candidates size = 1
        ifTrue: [^candidates any].

    selector := (ChooseOneDialog new openOn: candidates asSortedCollection label: 'Choose a Selector').
    ^selector
!   
implementorsOfSelection

    | selector |

    selector := self selectedItem trimBlanks.
    (selector includes: $*) ifTrue: [
        CursorManager execute changeFor: [selector := self findWildcardSelector: selector]].

    selector notNil ifTrue: [
        Smalltalk implementorsOf: selector asSymbol]

! 
popupMenu
        "Private - Answer the popup Menu for the receiver."
    | m otherMenu editMenu smalltalkMenu editTitle |
    m := super popupMenu.
    m isNil
        ifTrue: [
            m := Menu new
                appendItem: 'Cu\ut' replaceEscapeCharacters selector: #cutSelection ;
                appendItem: '\uCopy' replaceEscapeCharacters selector: #copySelection;
                appendItem: '\uPaste' replaceEscapeCharacters selector: #pasteSelection.
            Smalltalk isRunTime ifFalse: [
                m
                    appendSeparator ;
                    appendItem: '\uDo It' replaceEscapeCharacters selector: #doIt;
                    appendItem: '\uShow It' replaceEscapeCharacters selector: #printIt;
                    appendItem: '\uInspect It' replaceEscapeCharacters selector: #inspectIt;
                    appendSeparator;
                    appendItem: 'Senders' selector: #sendersOfSelection;
                    appendItem: 'Implementors' selector: #implementorsOfSelection;
                    appendItem: 'References' selector: #referencesOfSelection].

            m
                appendSeparator ;
                appendItem: '\uSave' replaceEscapeCharacters selector: #accept ;
                appendItem: 'A\ugain' replaceEscapeCharacters selector: #again.

            "retrieve the Edit/Smalltalk menus from the main window's window policy"
            editMenu := [ self mainWindow windowPolicy class editMenu ]
                on: MessageNotUnderstood do: [ nil ].
            editMenu notNil ifTrue: [ m appendSubMenu: ( editMenu allOwners: self ) ].
            Smalltalk isRunTime ifFalse: [
                smalltalkMenu := [ self mainWindow windowPolicy class smalltalkMenu: true ]
                    on: MessageNotUnderstood do: [ nil ].
                smalltalkMenu notNil ifTrue: [ m appendSubMenu: ( smalltalkMenu allOwners: self mainWindow owner ) ] ].

            m owner: self;
                title: 'TextPanePopup' ]
        ifFalse: [
            " if the popup is not the Edit menu, return it "
            editTitle := '\uEdit' replaceEscapeCharacters.
            ( m title ~= editTitle and: [ ( m isThere: editTitle ) not ] ) ifTrue: [ ^m ].

            editMenu :=
                ( m title = editTitle )
                    ifTrue: [ m ] "The entire popup is the edit menu."
                    ifFalse: [ m subMenuTitled: editTitle ] ]. "popup has a edit subitem."

        " copy popup menu attributes for File menu "
        m getIndex: #accept ifAbsent: [^m]. "Check to be sure the item is there."
        ( otherMenu := self mainWindow menuTitled: '\uFile' replaceEscapeCharacters ) isNil
            ifFalse: [ m copyItemAttributes: #accept from: otherMenu ].

        " copy popup menu attributes for Edit menu "

        ( otherMenu := self mainWindow menuTitled: '\uEdit' replaceEscapeCharacters ) isNil
            ifFalse: [
                otherMenu owner initMenu.
                ( Array with: m with: editMenu ) do: [ :mm |
                    mm copyItemAttributes: #copySelection from: otherMenu;
                        copyItemAttributes: #cutSelection from: otherMenu;
                        copyItemAttributes: #pasteSelection from: otherMenu ].
                editMenu copyItemAttributes: #clearSelection from: otherMenu ].

    ^self popupFromMenu: m
!
referencesOfSelection

    | name |
    name := self selectedItem trimBlanks asSymbol.
    (Smalltalk includesKey: name)
        ifTrue: [Smalltalk sendersOf: (Smalltalk associationAt: name)]
        ifFalse: [MessageBox warning: name, ' is not a global variable.']
!
sendersOfSelection

    | selector |

    selector := self selectedItem trimBlanks.
    (selector includes: $*) ifTrue: [
        CursorManager execute changeFor: [selector := self findWildcardSelector: selector]].

    selector notNil ifTrue: [
        Smalltalk sendersOf: selector asSymbol]
! !

! SmalltalkWindowPolicy class methods !
addSmalltalkEvaluationItemsTo: aMenu
        "Private - add menu items related to expression evaluation to aMenu."
    aMenu
        appendItem: '\uShow It\tCtrl+S' replaceEscapeCharacters selector: #printIt accelKey: $S accelBits: AfControl;
        appendItem: '\uDo It\tCtrl+D' replaceEscapeCharacters selector: #doIt accelKey: $D accelBits: AfControl;
        appendItem: '\uInspect It\tCtrl+I' replaceEscapeCharacters selector: #inspectIt accelKey: $I accelBits: AfControl;
        appendItem: 'File It I\un\tCtrl+N' replaceEscapeCharacters selector: #fileItIn accelKey: $N accelBits: AfControl;
        appendSeparator;
        appendItem: 'Senders' selector: #sendersOfSelection;
        appendItem: 'Implementors' selector: #implementorsOfSelection;
        appendItem: 'References' selector: #referencesOfSelection
!  
addSmalltalkToolItemsTo: aMenu
        "Private - add menu items that launch development tools to aMenu."
    aMenu
        appendItem: 'New \uWorkspace\tCtrl+W' replaceEscapeCharacters selector: #openWorkspace accelKey: $W accelBits: AfControl;
        appendItem: '\uBrowse Classes\tCtrl+B' replaceEscapeCharacters selector: #openNavigatorBrowser accelKey: $B accelBits: AfControl;
        appendItem: '\uBrowse Hierarchy\tCtrl+H' replaceEscapeCharacters selector: #openClassBrowser accelKey: $H accelBits: AfControl;
        appendItem: 'Browse Dis\uk\tCtrl+K' replaceEscapeCharacters selector: #openDiskBrowser accelKey: $K accelBits: AfControl;
        appendItem: 'Browse Se\urvices' replaceEscapeCharacters selector: #openServiceManagerWindow;
        appendSeparator;
        appendItem: 'Compress Changes...' selector: #compressChanges;
        appendItem: 'Compress Sources...' selector: #compressSources.

    self toolItems do: [ :item |
        aMenu appendItem: ( item at: 1 ) action: ( item at: 2 ) commandKey: ( item at: 3 ) ]
! !
Copyright 1990-1994 Digitalk Inc.  All rights reserved