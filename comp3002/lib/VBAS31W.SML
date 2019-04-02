  
= aSymbol
        "Answer true if the receiver object is the argument
        aSymbol, else answer false."
    <primitive: 110>!   
= aMethod
        "Private - Answer true if the receiver is the same method as aMethod."
    ^self == aMethod!  
asCstring
        "Answer a String whose contents are the
         bytes of the receiver."
    | stringEnd |
    stringEnd := (self copyFrom: 1 to: self size) indexOf: 0.
    stringEnd = 0 ifTrue: [^String new].
    ^(String new: stringEnd - 1)
        copyReplaceFrom: 1
        to: stringEnd - 1
        with: (self copyFrom: 1 to: stringEnd - 1)!
replaceBytesFrom: byteStart
    to: byteStop
    with: aByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aByteObject beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 80>
    aByteObject class isBytes
        ifFalse: [self error: 'source must be a byte object'].
    (self == aByteObject and: [byteRepStart < byteStart])
        ifTrue: [ "do backward move for same object"
            index2 := byteRepStart + byteStop - byteStart.
            index1 := byteStop.
            [byteStart <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aByteObject basicAt: index2) asInteger.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := byteRepStart.
    index1 := byteStart.
    [index1 <= byteStop]
        whileTrue: [
            self
                at: index1
                put: (aByteObject basicAt: index2) asInteger.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
= aString
        "Answer true if the receiver is equal to
         aString, else answer false.  The comparison
         is case sensitive."
    | sbs dbs i |
    <primitive: 55>
    " fails when self class ~= aString class "
    aString isSymbol ifTrue: [^false].
    (aString isString) ifTrue: [  " comparing String and DoubleByteString "
        (self size = aString size) ifFalse: [^false].
        self isDoubleByteString
            ifTrue: [dbs := self. sbs := aString]
            ifFalse: [sbs := self. dbs := aString].
        i := 1.
        dbs do: [ :aChar |
            ((sbs at: i) = aChar) ifFalse: [^false].
            i := i + 1].
        ^true].
    ^false!   
= aBlockClosure
        "Answer true if the elements contained by
         the receiver are equal to the elements
         contained by the argument aBlockClosure."
    | index |
    self == aBlockClosure
        ifTrue: [^true].
    (self class == aBlockClosure class)
        ifFalse: [^false].
    index := self size.
    index ~= aBlockClosure size
        ifTrue: [^false].
    [index <= 0]
        whileFalse: [
            (self at: index) = (aBlockClosure at: index)
                ifFalse: [^false].
            index := index - 1].
    ^true!
methodEnvironment
	"Answer the method environment for the receiver."

	^self size >= 4
		ifTrue: [ self at: 4 ]
		ifFalse: [ nil ]!  
methodEnvironment: anEnvironment
	"Set the method environment for the receiver."

	self at: 4 put: anEnvironment!  
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    | limit each |
    (RecursiveSet includes: self)
        ifTrue: [^self printRecursionOn: aStream].
    RecursiveSet add: self.
    limit := aStream position + 2000.
    self class printOn: aStream.
    aStream nextPut: $(.
    1 to: self size do: [ :i |
        (aStream position > limit)
            ifTrue: [
                '...etc...)' printOn: aStream.
                RecursiveSet remove: self ifAbsent: [].
                ^self].
        each := self at: i.
		each isInteger
			ifTrue: [ each printOn: aStream base: 16 showRadix: false ]
			ifFalse: [ each printOn: aStream ].
        aStream space].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: []!  
evaluateFor: anObject
        "Evaluate the receiver, passing anObject as the evaluation argument."
    ^self evaluateWithArguments: ( Array with: anObject )!  
valueWithArguments: anArray
	"Answer the result of evaluating the block described by the receiver."

	<primitive: 177>
    ^self invalidArgumentCount: anArray size!  
hash
        "Answer the size of the receiver as its hash value."
    ^self size + (self at: 2 ) hash!  
numArgs
	"Answer the number of arguments expected."

	^self argumentCount
!   
numberOfArguments
        "Answer the argument count for the receiver."
    ^self argumentCount!
method
	"Answer the method for the receiver."

	^self size >= 1
		ifTrue: [ self at: 1 ]
		ifFalse: [ nil ]! 
method: aMethod
	"Set the method for the receiver."

	self at: 1 put: aMethod! 
value: arg1 value: arg2
	"Answer the result of evaluating the block described by the receiver."

	<primitive: 176>
    ^self invalidArgumentCount: 2! 
whileFalse: aBlock
        "Repetitively evaluate the receiver block and aBlock,
         until the result of receiver block evaluation is
         true.  Answer nil."
    [ self value ] whileFalse: [ aBlock value ].
    ^nil!   
forkAt: aNumber
        "Create and schedule a new process for the expression
        in the receiver block, at priority aNumber.  Answer the
        forked Process."
    ^Processor fork: self at: aNumber.!
initFromArray: initArray

    "Private - used to initialize a Block closure template from a constant array."

    1 to: self size do: [ : index |
        self at: index put: (initArray at: index).].
    ^self!   
isBlockClosure
	"Answer whether the receiver is a BlockClosure."

	^true!  
receiver: anObject
	"Set the receiver for the receiver."

	self at: 3 put: anObject!   
blockNumber
	"Answer the block number for the receiver."

	^self size >= 2
		ifTrue: [ ( self at: 2 ) bitAnd: 16r7FF ]
		ifFalse: [ nil ]!   
blockNumber: anInteger
	"Private - Set the block number for the receiver.
	Answer false if anInteger is too large to fit, true otherwise."

	| temp |
    ( anInteger >= "2 raisedToInteger: 11" 2048 )
        ifTrue: [ ^false ].
	temp := self at: 2.
	temp isNil ifTrue: [ temp := 0 ].
	self at: 2 put: ( temp bitOr: anInteger ).
    ^true!  
validateNumberOfArguments: anInteger
        "Private - indicate an error if anInteger is an inappropriate
         number of arguments for the receiver."
    anInteger ~= self argumentCount
        ifTrue: [ self invalidArgumentCount: anInteger ].! 
whileFalse
        "Repeatedly evaluate the receiver until the receiver
        evaluates to <true>. Answer <nil>."
    ^[ self value ] whileFalse: [ ]!   
fork
        "Create and schedule a new process for the expression
        in the receiver block, at the current priority.  Answer the
        forked Process."
    ^Processor fork: self.!   
repeat
	"Evaluate the receiver repeatedly, ending only if the block
	forces some stopping condition."

	[true] whileTrue: [self value]
! 
returnTo: aMethodEnvironment with: anObject
	"Private - return from <aMethodEnvironment> with <anObject>
	as the return value. Used to simulate explicit (^) returns from a contained
	block."

    <primitive: 179>
    ^self primitiveFailed! 
on: exception do: handlerBlock
        "During the evaluation of the receiver, establish an
        exception handler that will execute the handlerBlock
        if the argument exception occurs."

    ^ExceptionHandler
        handle: exception
        with: handlerBlock
        during: self! 
= anAssociation
        "Answer true if the receiver key is equal
         to anAssociation key, else answer false."
    ^anAssociation isAssociation and: [ key = anAssociation key ]!
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    key printOn: aStream.
    aStream nextPutAll: ' ==> '.
    value printOn: aStream!   
< anAssociation
        "Answer true if the receiver key is less than
         anAssociation key, else answer false."
    ^key < anAssociation key!
<= anAssociation
        "Answer true if the receiver key is less than or
         equal to anAssociation key, else answer false."
    ^key <= anAssociation key!  
key
        "Answer the key of the receiver."
    ^key! 
key: anObject
        "Set the key of the receiver to
         be anObject.  Answer the receiver."
    key := anObject!
isInBase
        "Private - Answer true if the receiver is in base system."
    ^super isInBase or:
        [ key isInBase and: [ value isInBase ] ]!  
isAssociation
        "Answer true if receiver is a kind of Association."
    ^true!
> anAssociation
        "Answer true if the receiver key is greater
         than anAssociation key, else answer false."
    ^key > anAssociation key! 
>= anAssociation
        "Answer true if the receiver key is greater than or
         equal to anAssociation key, else answer false."
    ^anAssociation key <= key!   
value
        "Answer the value of the receiver."
    ^value!   
value: anObject
        "Set the value of the receiver to
         be anObject.  Answer the receiver."
    value := anObject!  
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    aStream nextPutAll: 'Association key: ('.
    key storeOn: aStream.
    aStream nextPutAll: ') value: ('.
    value storeOn: aStream.
    aStream nextPut: $)! 
hash
        "Answer the integer hash value
         for the key of the receiver."
    ^key hash!  
= aMagnitude
        "Answer true if the receiver is equal
         to aMagnitude, else answer false."
    ^self implementedBySubclass!
< aMagnitude
        "Answer true if the receiver is less
         than aMagnitude, else answer false."
    ^self implementedBySubclass!   
<= aMagnitude
        "Answer true if the receiver is less than
         or equal to aMagnitude, else answer false."
    ^self implementedBySubclass!  
max: aMagnitude
        "Answer the receiver if it is greater
         than aMagnitude, else answer aMagnitude."
    self > aMagnitude
        ifTrue:  [^self]
        ifFalse: [^aMagnitude]!  
min: aMagnitude
        "Answer the receiver if it is less
         than aMagnitude, else answer aMagnitude."
    self < aMagnitude
        ifTrue:  [^self]
        ifFalse: [^aMagnitude]! 
between: min and: max
        "Answer true if the receiver is greater than or
         equal to min and less than or equal to max,
         else answer false."
    ^(min <= self) and: [self <= max]!
> aMagnitude
        "Answer true if the receiver is greater
         than aMagnitude, else answer false."
    ^self implementedBySubclass!
>= aMagnitude
        "Answer true if the receiver is greater than
         or equal to aMagnitude, else answer false."
    ^self implementedBySubclass!   
hash
        "Answer the positive integer hash
         value for the receiver."
    ^self implementedBySubclass!  
instVarAt: anInteger
        "Private - Answer the instance variable in
         the receiver at index position anInteger.
         Both named and indexed instance variables
         are indexed."
    <primitive: 73>
    ^self primitiveFailed! 
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
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    | aClass noneYet |
    (RecursiveSet includes: self)
        ifTrue: [
            RecursiveSet := Set new.
            ^self error:
                'recursive storeOn: not allowed in Object'].
    RecursiveSet add: self.
    aClass := self class.
    aStream
        nextPutAll: '((';
        nextPutAll: aClass name;
        nextPutAll: ' basicNew'.
    aClass isVariable
        ifTrue: [
            aStream nextPut: $:.
            self basicSize printOn: aStream].
    aStream nextPut: $).
    noneYet := true.
    1 to: aClass instSize + self basicSize do: [ :index |
        noneYet
            ifTrue: [noneYet := false].
        aStream nextPutAll: ' instVarAt: '.
        index printOn: aStream.
        aStream nextPutAll: ' put: '.
        (self instVarAt: index) storeOn: aStream.
        aStream nextPutAll: '; ' ].
    noneYet
        ifFalse: [ aStream nextPutAll: 'yourself' ].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: [ nil ]! 
isSelfInitializingObject
        "Answer true if receiver is a kind of SelfInitializingObject."
    ^false! 
methodFor: aSymbol in: aClass
        "Answer the receiver's method for aSymbol in aClass."
    | method searchBlock |
    searchBlock :=
        [ :mda |
        mda do:
            [ :item |
            item isArray ifTrue:  [ searchBlock value: item ].
            ( ( item includesKey: aSymbol )
                and: [ ( ( method := item at: aSymbol ) classField ) = aClass ] )
                ifTrue: [ ^method ].
            ].
        ^nil.
        ].

    searchBlock value: self methodDictionaryArray.!
implementedBySubclass
        "Initiate a walkback because a subclass doesn't
         implement a message that it should."
    ^self error:
        'my subclass should have implemented this message'!  
printString
        "Answer a String that is an ASCII representation
         of the receiver."
    | aStream aString |
    RecursiveSet := Set new.
    aString := String new: 20.
    self printOn: (aStream := WriteStream on: aString).
    ^aStream contents! 
obsoleteMethod
        "A message used to track senders of obsolete messages in the system."!
storeString
        "Answer the receiver represented as a String
         from which it can be reconstructed."
    | aStream |
    aStream := WriteStream on: (String new: 16).
    self storeOn: aStream.
    ^aStream contents!   
~= anObject
        "Answer true if the receiver and anObject do
         not compare equal (using =), else answer false."
    ^(self = anObject) not! 
isContext
        "Answer true if receiver is a kind of Context.."
    ^false!  
basicHash: anInteger
        "Private - Set the basicHash of the
         receiver to anInteger."
    <primitive: 76>! 
instVarAt: anInteger put: anObject
        "Private - Answer anObject.  Replace the instance
         variable in the receiver at index position
         anInteger with anObject.  Both named and indexed
         instance variables are indexed."
    <primitive: 74>
    ^self primitiveFailed! 
sender
        "Answer the sender object that invoked the current method."
    <primitive: 57>
    ^self primitiveFailed!  
primitiveFailed
        "Private - Initiate a walkback with label
         containing primitive failed message."
    ^self error: 'system primitive failed'!   
methodDictionaryArray
        "Private - answer the array containing the behavior of the receiver."
    <primitive: 96>
    ^self primitiveFailed! 
basicAt: anInteger put: anObject
        "Answer anObject.  Replace the object in the receiver
         at index position anInteger with anObject.  If the receiver
         does not have indexed instance variables, or if anInteger
         is greater than the number of indexed instance variables,
         report an error."
    <primitive: 61>
    ^self primitiveFailed!
halt
        "Initiate a walkback with 'halt encountered'
         message for debugging."
    Process
        queueWalkback: 'halt encountered'
        makeUserIF: CurrentProcess isUserIF
        resumable: 2!  
initialize
        "Initialize the state of the receiver after creating a new
        instance; by default, do nothing."!   
frameCanBeRescaled
        "Answer true if a framing block can be rescaled dynamically."
    ^false!
become: anObject
        "The receiver takes on the identity of anObject.
         All the objects that referenced the receiver
         will now point to anObject."
    <primitive: 72>
    ^self primitiveFailed! 
allReferencesPrim
        "Private - Answer an Array of all of
         the references to the receiver."
    <primitive: 69>
    self primitiveFailed!
respondsTo: aSymbol
        "Answer true if the receiver class or one of its
         superclasses implements a method with selector
         equal to aSymbol."
    ^( self methodFor: aSymbol ) ~~ nil.!
cantReturn
        "Private - Initiate a walkback for trying
         to exit a method more than once."
    self error:
        'attempt to exit from the same method more than once'!
notNil
        "Answer true if the receiver is not
         the object nil, else answer false."
    ^true! 
hash: anInteger
        "Private - Set the integer hash value of the receiver."
    self basicHash: anInteger!  
methodNotAvailable
        "Private - A message was sent to a method
         in a dll that is not loaded, e.g. a development
         method in the runtime version."
    self error: 'method not available'!
= anObject
        "This is the default equality test.  Answer true
         if the receiver and anObject are the same object,
         else answer false."
    <primitive: 110>! 
== anObject
        "Answer true if the receiver and anObject
         are the same object, else answer false."
    <primitive: 110>!  
yourself
        "Answer the receiver."
    ^self!  
asString
        "Answer the string representing the receiver."
    ^self printString!  
class
        "Answer the class of the receiver."
    <primitive: 111>
    ^self primitiveFailed!  
hash
        "Answer the integer hash value of the receiver.  This
         is the default implementation which uses the object
         hash value assigned at the creation time."
    <primitive: 75>!  
copy
        "Answer a shallow copy of the receiver."
    ^self shallowCopy!
deepCopy
        "Answer a copy of the receiver with shallow  
         copies of each instance variable."  
   ^self objectDeepCopy!  
allReferences
        "Answer an Array of all of
         the references to the receiver."
    Smalltalk unusedMemory.
    ^self allReferencesPrim!   
species
        "Answer a class which is similar to (or the same
         as) the receiver class which can be used for
         containing derived copies of the receiver."
    ^self class!  
basicSize
        "Answer the number of indexed instance variables in
         the receiver."
    <primitive: 62>
    ^self primitiveFailed!  
basicAt: anInteger
        "Answer the object in the receiver at index position
         anInteger.  If the receiver does not have indexed
         instance variables, or if anInteger is greater
         than the number of indexed instance variables,
         report an error."
    <primitive: 60>
    ^self primitiveFailed!   
methodFor: aSymbol
        "Answer the receiver's method for aSymbol."
    | searchBlock |
    searchBlock :=
        [ :mda |
        mda do:
            [ :item |
            item isArray ifTrue:  [ searchBlock value: item ].
            ( item includesKey: aSymbol )
                ifTrue: [ ^item at: aSymbol ].
            ].
        ^nil.
        ].

    searchBlock value: self methodDictionaryArray.!   
vmInterrupt: aSymbol
        "Private - Process virtual machine interrupt.  This method is called
        by the virtual machine.  It is entered with interrupts disabled.  The
        interrupt handler should enable interrupts at the appropriate time."
    Process perform: aSymbol.
    ^self!
mustBeBoolean
        "Private - Initiate a walkback describing
         that the receiver is not a Boolean."
    ^ControlError signal: 'receiver is not a Boolean'!   
~~ anObject
        "Answer true if the receiver and anObject are
         not the same object, else answer false."
    ^(self == anObject) not!   
isNil
        "Answer true if the receiver is
         the object nil, else answer false."
    ^false! 
invalidMessage
        "Initiate walkback because inappropriate
         message was sent to the receiver."
    ^self error:
        'inappropriate message for this object'! 
basicHash
        "Answer the integer hash value of the receiver.  This
         is the default implementation which uses the object
         hash value assigned at the creation time."
    <primitive: 75>! 
objectDeepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable."
    | copy aClass instanceVars |
    aClass := self class.
    aClass isVariable
        ifTrue: [
            instanceVars := self basicSize.
            copy := aClass basicNew: instanceVars]
        ifFalse: [
            instanceVars := 0.
            copy := aClass basicNew].
    aClass isPointers
        ifTrue: [
            1 to: instanceVars + aClass instSize do: [ :index |
                copy instVarAt: index
                    put: (self instVarAt: index) copy]]
        ifFalse: [
            1 to: instanceVars do: [ :index |
                copy basicAt: index
                    put: (self basicAt: index)]].
    ^copy! 
objectShallowCopy
        "Answer a copy of the receiver which shares
         the receiver instance variables."
    | answer aClass size |
    aClass := self class.
    aClass isVariable
        ifTrue: [
            size := self basicSize.
            answer := aClass basicNew: size]
        ifFalse: [
            size := 0.
            answer := aClass basicNew].
    aClass isPointers
        ifTrue: [
            1 to: size + aClass instSize do: [ :index |
                answer instVarAt: index
                    put: (self instVarAt: index)]]
        ifFalse: [
            1 to: size do: [ :index |
                answer basicAt: index
                    put: (self basicAt: index)]].
    ^answer!
methodDictionaryArray: anArray
        "Private - set the array containing the behavior of the receiver to be <anArray>.
        Warning: Inappropriate use of this method will produce internal
        inconsistencies which will result in potentially fatal, non-obvious
        errors.  Inappropriate uses include, but are not limited to, inappropriate
        argument values and the use of this method when the system is in an
        inappropriate state.  The exact conditions under which this method
        can be safely used are intentionally omitted in order to discourage
        its use.  The public interface to manipulating instance-specific behavior
        is via #addBehavior: , #removeBehavior: , and #revertToClassBehavior."
    <primitive: 97>
    ^self primitiveFailed! 
size
        "Answer the number of indexed instance
         variables in the receiver."
    <primitive: 62>
    ^self primitiveFailed!   
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver instance variables."
    ^self objectShallowCopy!
at: anInteger put: anObject
        "Answer anObject.  Replace the object in the receiver
         at index position anInteger with anObject.  If the
         receiver does not have indexed instance variables, or
         if anInteger is greater than the number of indexed
         instance variables, report an error."
    <primitive: 61>
    ^self primitiveFailed! 
at: anInteger
        "Answer the object in the receiver at index position
         anInteger.  If the receiver does not have indexed
         instance variables, or if anInteger is greater
         than the number of indexed instance variables,
         report an error."
    <primitive: 60>
    ^self primitiveFailed!
printRecursionOn: aStream
        "Private - This is used while printing recursive
         data structures to print the first object
         detected in the cyclic structure."
    aStream
        nextPutAll: ' ...recursive reference to ';
        nextPutAll: self class name;
        nextPutAll: '... '!  
asActionSequence
        "Answer the receiver as an element of an ActionSequence."
    ^ActionSequence with: self!  
evaluateWithoutInterrupts
        "Disable interrupts, evaluate the receiver, enable interrupts, and
        answer the result of the evaluation."
    | int |
    int := Process enableInterrupts: false.
    ^self ensure: [ Process enableInterrupts: int ]!  
evaluate
        "Answer the result of evaluating the receiver."
    ^self value!   
receiver
	"Answer the receiver for the receiver."

	^self size >= 3
		ifTrue: [ self at: 3 ]
		ifFalse: [ nil ]! 
argumentCount
	"Answer the argument count for the receiver."

	^self size >= 2
		ifTrue: [ ( ( self at: 2 ) bitShift: -11 ) bitAnd: 16r7FF ]
		ifFalse: [ nil ]! 
argumentCount: anInteger
	"Private - Set the argument count for the receiver.
	Answer false if anInteger is too large to fit, true otherwise."

	| temp |
    ( anInteger >= "2 raisedToInteger: 6" 64 )
        ifTrue: [ ^false ].
	temp := self at: 2.
	temp isNil ifTrue: [ temp := 0 ].
	self at: 2 put: ( temp bitOr: ( anInteger bitShift: 11 ) ).
    ^true!
ensure: terminationBlock
        "Return the result of evaluating the receiver. Before returning,
        but after evaluating the receiver, evaluate the <terminationBlock>.
        The value of the termination block is ignored. If a block attempts
        to return from a method which (indirectly) invoked the receiver,
        either directly or indirectly, evaluate the termination block before
        returning from the enclosing method.
        Implementation Comments:  The receiver is evaluated by sending
        the receiver the message #value."
    | result |
    result := self
        setUnwind:
            [:aContext :returnValue |
            terminationBlock value.
            aContext return: returnValue ].
    terminationBlock value.
    ^result!  
whileTrue
        "Repeatedly evaluate the receiver until the receiver
        evaluates to <false>. Answer <nil>."
    ^[ self value ] whileTrue: [ ]!
invalidArgumentCount: argCount
        "Private - display an error message indicating that the
         receiver does not support the given number of arguments."
    ^self error: self class printString,
        ' expects ', self argumentCount printString,
        ' arguments, not ', argCount printString.!   
whileTrue: aBlock
        "Repetitively evaluate the receiver block and aBlock,
         until the result of receiver block evaluation is
         false.  Answer nil."
    [ self value ] whileTrue: [ aBlock value ].
    ^nil!
evaluateWithArguments: argumentArray
        "Evaluate the receiver with the elements of the <argumentArray>
        as the argument values.  Error Conditions: If the number of
        arguments required by the receiver is different from the size
        of the argument array, send the message #invalidArgumentCount:
        to the receiver with the number of arguments provided as the
        argument."
    ^self valueWithArguments: argumentArray! 
return: anObject
        "Private - return from the receiver with the given value. Used
        to simulate explicit (^) returns from a contained block."

	^self returnTo: self with: anObject!  
invisibleEnsure: terminationBlock
        "This method's function is identical to #ensure: but is used by
        system code for ensures that need not showup in walkbacks or in
        the debugger. If the definition of ensure: is modified, the corresponding
        changes must also be made to this method.

        Return the result of evaluating the receiver. Before returning,
        but after evaluating the receiver, evaluate the <terminationBlock>.
        The value of the termination block is ignored. If a block attempts
        to return from a method which (indirectly) invoked the receiver,
        either directly or indirectly, evaluate the termination block before
        returning from the enclosing method.
        Implementation Comments:  The receiver is evaluated by sending
        the receiver the message #value."
    | result |
    result := self
        setUnwind:
            [:aContext :returnValue |
            terminationBlock value.
            aContext return: returnValue ].
    terminationBlock value.
    ^result!
valueMarked
        "Private - evaluate the receiver after marking the sending
        method as having created a protected block. Only one method
        may be so marked."
    <primitive: 178>
    ^self primitiveFailed!
setUnwind: twoArgumentBlock
        "Private - evaluate the receiver. If the system attempts to
        return from a method which (indirectly) invoked this one,
        evaluate the <twoArgumentBlock>. The first argument to
        the block is the context for the method being returned from,
        the second is the value being returned from that method.
        Implementation Comments: What will happen if the
        argument block is invoked and does not provide an explicit
        return is intentionally undefined."
    ^self valueMarked!
value
	"Answer the result of evaluating the block described by the receiver."

	<primitive: 174>
    ^self invalidArgumentCount: 0!   
value: anObject
	"Answer the result of evaluating the block described by the receiver."

	<primitive: 175>
    ^self invalidArgumentCount: 1! 
value: arg1 value: arg2 value: arg3
	"Evaluate the block represented by the receiver.  Fail if the block
	expects other than three arguments."

	^self valueWithArguments:
		(Array
			with: arg1
			with: arg2
			with: arg3)!   
ifCurtailed: exceptionBlock
        "Return the result of evaluating the receiver. If a block attempts
        to return from a method which (indirectly) invoked the receiver,
        either directly or indirectly, evaluate the <exceptionBlock>
        before returning from the enclosing method. The exception block
        will not be evaluated if the receiver is allowed to return normally.
        Implementation Comments:  The receiver is evaluated by sending
        the receiver the message #value."
    ^self
        setUnwind:
            [:aContext :returnValue |
            exceptionBlock value.
            aContext return: returnValue ]!   
replaceBytesFrom: byteStart
    to: byteStop
    with: aByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aByteObject beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 80>
    aByteObject class isBytes
        ifFalse: [self error: 'source must be a byte object'].
    (self == aByteObject and: [byteRepStart < byteStart])
        ifTrue: [ "do backward move for same object"
            index2 := byteRepStart + byteStop - byteStart.
            index1 := byteStop.
            [byteStart <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aByteObject basicAt: index2) asCharacter.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := byteRepStart.
    index1 := byteStart.
    [index1 <= byteStop]
        whileTrue: [
            self
                at: index1
                put: (aByteObject basicAt: index2) asCharacter.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
replaceFrom: start to: stop withObject: aCharacter
        "Replace the characters of the receiver
         at index positions start through stop
         with aCharacter.  Mutate the receiver
         into a DoubleByteString if aCharacter
         is a double-byte character.  Answer aCharacter."
    | dbString |
    <primitive: 106>
    self checkCharacter: aCharacter.
    aCharacter isDoubleByte
        ifTrue: [
            dbString := DoubleByteString fromString: self.
            dbString
                replaceFrom: start to: stop
                withObject: aCharacter.
            self become: dbString.
            ^aCharacter].
    ^super
        replaceFrom: start
        to: stop
        withObject: aCharacter!
asByteArray
        "Answer a ByteArray whose contents are the
         bytes of the receiver."
    ^(ByteArray new: self size) replace: self size with: self.!
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host system procedure call."
    ^self!   
checkCharacter: aCharacter
        "Private - Report an error if the argument
         aCharacter is not an instance of class Character."
    (aCharacter isCharacter)
        ifFalse: [
            ^self error: self class name, ' can''t hold '
                , aCharacter class name]
! 
printOn: aStream
        "Append the receiver as a quoted string
         to aStream doubling all internal single
         quote characters."
    aStream nextPut: $'.
    self do: [ :character |
        aStream nextPut: character.
        character = $'
            ifTrue: [aStream nextPut: character]].
    aStream nextPut: $'!
equals: aString
        "Answer true if the receiver is equal to
         the argument aString, else answer false.
         Note that the comparison is case sensitive."
    <primitive: 55>
    ^false! 
containsDBCharacter
        " Answer whether the receiver contains
        any double-byte characters. "
    ^false!   
asString
        "Answer the string representing the
         receiver (the receiver itself)."
    ^self!  
>= aString
        "Answer true if the receiver is after or equal to
         aString in the current sort sequence, else answer false.
         The comparison is not case sensitive."
    aString isString
        ifFalse: [ ^self error: 'invalid string argument' ].
    ^aString <= self!  
> aString
        "Answer true if the receiver is after
         aString, else answer false.  The comparison
         is not case sensitive."
    ^(self <= aString) not! 
fileExtension
        "Answer a three character String that follows the receiver's
        last period character (for FAT file names)."
    | str lastPeriod |
    lastPeriod := self
        findLast: [:c| c == $.]
        ifAbsent: [ ^(self class with: $  with: $  with: $ ) ].
    str := self copyFrom: lastPeriod + 1 to: self size.
    ^ str, '   ' copyFrom: 1 to: 3.!
isString
        "Answer true if receiver is an instance of class
         String, else answer false."
    ^true!  
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    self printOn: aStream! 
, aString
        "Answer a new string containing the characters
         of the receiver followed by the characters of
         aString."
    ((self isDoubleByteString xor: aString isDoubleByteString)
        and: [ aString isString ])
        ifFalse: [ ^super , aString ].
    ^(DoubleByteString fromString: self) , (DoubleByteString fromString: aString)! 
hash
        "Answer the integer hash
         value for the receiver."
    | theHash index |
    <primitive: 107>
    index := self size.
    theHash := 0.
    [index < 1]
        whileFalse: [
            theHash :=
                (theHash * 61 + (self at: index) asciiValue)
                    bitAnd: 16r3FFF.
            index := index - 1].
    ^ theHash bitAnd: 16r3FFF!  
asArrayOfSubstringsSeparatedBy: aCharacter
        "Answer an array of substrings from the receiver. The receiver
        is divided into substrings by one or more occurrences of <aCharacter>."
    | answer startIndex stopIndex size |
    answer := OrderedCollection new.
    startIndex := 1.
    size := self size.
    [ startIndex <= size ] whileTrue: [
        [ startIndex <= size and: [ ( self at: startIndex ) = aCharacter ] ]
            whileTrue: [ startIndex := startIndex + 1 ].
        stopIndex := startIndex.
        [ stopIndex <= size and: [ ( self at: stopIndex ) ~= aCharacter ] ]
            whileTrue: [ stopIndex := stopIndex + 1 ].
        stopIndex > startIndex
            ifTrue: [ answer add: ( self copyFrom: startIndex to: stopIndex - 1 ) ].
        startIndex := stopIndex ].
    ^answer asArray! 
basicAt: anInteger put: aCharacter
        "Answer aCharacter.  At index position
         anInteger in the receiver put the
         character aCharacter."
    <primitive: 64>
    self checkIndex: anInteger.
    self checkCharacter: aCharacter.
    ^self primitiveFailed!   
indexOfString: aString startingAt: startIndex
        "Answer the index position of the first occurrence of aString in the receiver
        after startIndex.  If no such element is found, answer zero."
    | last base limit i |
    last := aString size.
    limit := self size - last.
    ( base := startIndex - 1 ) > limit ifTrue: [ ^0 ].
    i := 1.
    [ i <= last ] whileTrue: [
        ( self at: i + base ) = ( aString at: i )
            ifTrue: [ i := i + 1 ]
            ifFalse: [
                i := 1.
                ( base := base + 1 ) > limit ifTrue: [ ^0 ] ] ].
    ^i > 1
        ifTrue: [ base + 1 ]
        ifFalse: [ 0 ]!   
replace: count with: aCollection
        "Replace count elements of the receiver
         with elements of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Mutate the receiver
         into a DoubleByteString if aCollection is a
         DoubleByteString.  Answer the receiver."
    | dbString |
    <primitive: 79>
    (aCollection isDoubleByteString)
        ifTrue: [
            dbString := DoubleByteString fromString: self.
            dbString replace: count with: aCollection.
            self become: dbString.
            ^dbString].
    ^self primitiveFailed!
fileNamePath
        "Answer the directory path of the receiver path name
        (without the file name and extension)."
    ^self
        copyFrom: 1
        to: ( ( self  findLast: [ :i | i = $\ ] ifAbsent: [^''] ) - 1 )! 
trimBlanks
        "Answer a String containing the receiver string with leading
        and trailing blanks removed."
    | size start end |
    size := self size.
    start := 1.
    [ start <= size and: [ ( self at: start ) isWhitespace ] ]
        whileTrue: [ start := start + 1 ].
    end := size.
    [ end >= 1 and: [ ( self at: end ) isWhitespace ] ]
        whileTrue: [ end := end - 1 ].
    ^self copyFrom: start to: end!   
containsLeadByte: leadByteFlags
        "Answer whether the receiver contains any lead-bytes
         based on the given array of leadByteFlags. "
    <primitive: 131>
    ^self primitiveFailed!
trimNullTerminator
        "Answer a String containing the receiver string
         with anything after the null terminator removed."
    | nullTermIndex |
    (nullTermIndex := self indexOf:0 asCharacter) > 0
        ifTrue: [^ self copyFrom:1 to: nullTermIndex - 1]
        ifFalse: [^ self]!  
asSymbol
        "Answer a symbol whose characters
         are the same as the receiver string."
    ^Symbol intern: self!
fileNameLessPath
        "Answer the unqualified file name of
        the receiver file name (file name and
        extension without drive or directory path)."
    | str last |
    last := self
        findLast: [:c| c == $\ ]
        ifAbsent: [ nil ].
    str := (last == nil)
        ifTrue: [ self ]
        ifFalse: [ self copyFrom: last + 1 to: self size ].
    last := str
        findLast: [:c| c == $: ]
        ifAbsent: [ nil ].
    ^ (last == nil)
        ifTrue: [ str ]
        ifFalse: [ str copyFrom: last + 1 to: str size ].!   
asAsciiZ
        "Answer a new String containing all the
         characters of the receiver followed by
         the character of ASCII value zero."
    ^self, 0 asCharacter asString!  
equalsIgnoreCase: aString
        "Answer true if the receiver is equal to aString, else answer
        false.  The comparison is not case sensitive."
    ^self <= aString and: [(self < aString) not]!   
asStringParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call.
         In this case, answer the receiver with a trailing zero
         byte.  Use this method when the parameter must be
         a string and cannot be nil."
    ^self asAsciiZ!
at: anInteger put: aCharacter
        "Answer aCharacter.  At index position
         anInteger in the receiver put the
         character aCharacter.  Mutate the receiver
         into a DoubleByteString if aCharacter
         is a double-byte character."
    | dbString |
    <primitive: 64>
    self checkIndex: anInteger.
    self checkCharacter: aCharacter.
    aCharacter isDoubleByte
        ifTrue: [
            dbString := DoubleByteString fromString: self.
            dbString at: anInteger put: aCharacter.
            self become: dbString.
            ^aCharacter].
    ^self primitiveFailed!   
sizeOfNormalizedString: leadByteFlags
        "Interpret the receiver as a mixed-string encoding
         based on the given array of leadByteFlags.
         Answer the size of an equivalent DoubleByteString."
    <primitive: 130>
    ^self primitiveFailed!
asLowercase
        "Answer a String containing the
         receiver with alphabetic
         characters in lower-case."
    | answer size |
    size := self size.
    answer := self species new: size.
    1 to: size do: [ :index |
        answer at: index put: ( self at: index ) asLowercase ].
    ^answer!
asLowerCase
        "Answer a String containing the
         receiver with alphabetic
         characters in lower-case."
    ^self asLowercase!  
asUppercase
        "Answer a String containing the
         receiver with alphabetic
         characters in upper-case."
    | answer size |
    size := self size.
    answer := self species new: size.
    1 to: size do: [ :index |
        answer at: index put: ( self at: index ) asUppercase ].
    ^answer!
asUpperCase
        "Answer a String containing the
         receiver with alphabetic
         characters in upper-case."
    ^self asUppercase!  
basicAt: anInteger
        "Answer the character at position
         anInteger in the receiver string."
    <primitive: 63>
    self checkIndex: anInteger.
    ^self primitiveFailed!  
fileName
        "Answer the characters of the receiver string up
         to the last period character."
    | lastPeriod |
    lastPeriod := self
        findLast: [ :c| c == $. ]
        ifAbsent: [ ^self ].
    ^self copyFrom: 1 to: ( lastPeriod - 1 )!   
indexOfPattern: aStringOrPattern
        "Answer the index position of the first occurrence of aStringOrPattern in
        the receiver.  If no such element is found, answer zero."
    ^self indexOfPattern: aStringOrPattern startingAt: 1! 
withCrs
        "Answer the receiver string where each
         occurrence of the character \ has been
         replaced with a line-feed character."
    | answer |
    answer := self copy.
    1 to: answer size do: [ :index |
        ( answer at: index) = $\ ifTrue: [ answer at: index put: Lf ] ].
    ^answer!  
at: anInteger
        "Answer the character at position
         anInteger in the receiver string."
    <primitive: 63>
    self checkIndex: anInteger.
    ^self primitiveFailed!   
replaceFrom: start to: stop withAddress: anAddress startingAt: int
        "Private - Use #replaceFrom:to:with:startingAt: instead."
    ^self replaceFrom: start to: stop with: anAddress startingAt: int! 
zapCrs
        "Answer a copy of the receiver with all the Cr characters
         removed; Lf characters are unchanged."
    ^self reject: [ :c | c == Cr ]!   
asArrayOfSubstrings
        "Answer an array of substrings from the receiver. The receiver
        is divided into substrings by one or more occurrences of space characters."
    | answer startIndex stopIndex size |
    answer := OrderedCollection new.
    startIndex := 1.
    size := self size.
    [ startIndex <= size ] whileTrue: [
        [ startIndex <= size and: [ ( self at: startIndex ) isWhitespace ] ]
            whileTrue: [ startIndex := startIndex + 1 ].
        stopIndex := startIndex.
        [ stopIndex <= size and: [ ( self at: stopIndex ) isWhitespace not ] ]
            whileTrue: [ stopIndex := stopIndex + 1 ].
        stopIndex > startIndex
            ifTrue: [ answer add: ( self copyFrom: startIndex to: stopIndex - 1 ) ].
        startIndex := stopIndex ].
    ^answer asArray! 
asCompactString
        "Answer the most compact string containing the
         characters of the receiver."
    ^self!
asMixedString
        "Answer the mixed-string encoding
        representing the receiver."
    ^self! 
asNormalizedString
        "Interpret the receiver as a mixed string encoding
         using the lead byte flags of the current code page.
         Answer the equivalent DoubleByteString if the receiver
         contains any double-byte characters.  Answer the
         receiver if it only contains single byte characters."
    (NationalLanguage isDoubleByteCp) ifFalse: [^self].
    ^self asNormalizedString: NationalLanguage leadBytes!  
upTo: aCharacter
        "Answer a String which is a copy of the receiver up
         to the first occurrence of aCharacter."
    ^(ReadStream on: self) upTo: aCharacter! 
asNormalizedString: leadByteFlags
        "Interpret the receiver as a mixed string encoding
         based on the given array of leadByteFlags.
         Answer the equivalent DoubleByteString if the receiver
         contains any double-byte characters.  Answer the
         receiver if it only contains single byte characters."
    (self containsLeadByte: leadByteFlags)
        ifFalse: [ ^self ]
        ifTrue: [ ^DoubleByteString fromMixedString: self leadBytes: leadByteFlags].! 
< aString
        "Answer true if the receiver is before
         aString, else answer false.  The comparison
         is not case sensitive."
    ^(aString <= self) not!
<= aString
        "Answer true if the receiver is before or equal to
         aString in the current sort sequence, else answer false.
         The comparison is not case sensitive."
    <primitive: 56>
    (self isSymbol or: [aString isSymbol])
        ifTrue: [
            aString isDoubleByteSymbol
                ifTrue: [
                    self  isDoubleByteSymbol
                        ifFalse: [^(DoubleByteSymbol intern: self) <= aString ]]
                ifFalse: [
                    self isDoubleByteSymbol
                        ifTrue: [^self <= (DoubleByteSymbol intern: aString) ]]]
        ifFalse: [
            aString isDoubleByteString
                ifTrue: [
                    self  isDoubleByteString
                        ifFalse: [^(DoubleByteString fromString: self) <= aString ]]
                ifFalse: [
                    self isDoubleByteString
                        ifTrue: [^self <= (DoubleByteString fromString: aString) ]]].
    ^self primitiveFailed!   
asExistingSymbolOrNil
        "If a symbol already exists that represents the same string as
        the receiver, return the existing symbol.  Otherwise return nil"
	^Symbol existingSymbolFor: self!
replaceFrom: start
    to: stop
    with: aString
    startingAt: repStart
        "Replace the characters of the receiver at index
         positions start through stop with consecutive
         characters of aString beginning at index
         position repStart.  Mutate the receiver into a
         DoubleByteString if aString is a DoubleByteString.
         Answer the receiver."
    | dbString index1 index2 |
    <primitive: 105>
    (aString isDoubleByteString)
        ifTrue: [
            dbString := DoubleByteString fromString: self.
            dbString
                replaceFrom: start to: stop
                with: aString startingAt: repStart.
            self become: dbString.
            ^dbString].
    (aString class isBytes)
        ifFalse: [
            ^super
                replaceFrom: start
                to: stop
                with: aString
                startingAt: repStart].
    " primitive failure on large byte objects "
    (self == aString and: [repStart < start])
        ifTrue: [ "do backward move for same object"
            index2 := repStart + stop - start.
            index1 := stop.
            [start <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aString at: index2) asCharacter.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := repStart.
    index1 := start.
    [index1 <= stop]
        whileTrue: [
            self
                at: index1
                put: (aString at: index2) asCharacter.
            index1 := index1 + 1.
            index2 := index2 + 1]!   
indexOfPattern: aStringOrPattern startingAt: startIndex
        "Answer the index position of the first occurrence of aStringOrPattern in
        the receiver after startIndex.  If no such element is found, answer zero."
    | pattern match |
    pattern := aStringOrPattern isString
        ifTrue: [ Pattern new: aStringOrPattern ]
        ifFalse: [ aStringOrPattern ].
    match := pattern match: self index: startIndex.
    ^match isNil
        ifTrue: [ 0 ]
        ifFalse: [ match x ]!   
indexOfString: aString
        "Answer the index position of the first occurrence
         of aString in the receiver.  If no such element
         is found, answer zero."
    ^self indexOfString: aString startingAt: 1!   
replaceAll: aString with: newString
        "Replace all occurrences of aString with newString
        in a copy of the receiver, and answer that copy."
    | result pattern range |
    aString = newString ifTrue: [ ^self ].
    pattern := Pattern new: aString.
    result := self.
    range := 1@1.
    [ ( range := pattern match: result index: range x ) isNil ]
        whileFalse: [
            result := result
                copyReplaceFrom: range x
                to: range y
                with: newString ].
    ^result! 
asExternalString
        "Answer a new String containing the characters
         of the receiver in host system mixed-string encoding. "
    ^self!
replaceCharacter: aChar from: start to: end withString: aString
        "Answer a new String which is copied from the receiver,
         replacing all occurrences of aChar with aString"
    | copy occurrences destIndex stringSize |
    occurrences := self occurrencesOf: aChar.
    occurrences = 0 ifTrue: [ ^self ].
    stringSize := aString size.
    copy := self species new: ( end - start + 1 + ( stringSize - 1 * occurrences ) ).
    destIndex := 1.
    start to: end do: [:srcIndex |
        ( self at: srcIndex ) == aChar
            ifTrue: [
                1 to: stringSize do: [:i |
                    copy at: destIndex put: ( aString at: i ).
                    destIndex := destIndex + 1 ] ]
            ifFalse: [
                copy at: destIndex put: ( self at: srcIndex ).
                destIndex := destIndex + 1 ] ].
    ^copy!
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each element."
    ^self objectDeepCopy!   
select: aBlock
        "For each element in the receiver, evaluate
         aBlock with that element as the argument.
         Answer a collection containing those elements
         of the receiver for which aBlock evaluates to
         true."
    | answer index size anObject |
    size := self size.
    answer := OrderedCollection new: size.
    index := 1.
    [index > size]
        whileFalse: [
            anObject := self at: index.
            (aBlock value: anObject)
                ifTrue: [answer add: anObject].
            index := index + 1].
    size := answer size.
    ^(self species new: size)
        replaceFrom: 1
        to: size
        with: answer!  
add: anObject
        "Add anObject to the receiver.  This method reports
         an error since fixed size collections cannot grow."
    ^self invalidMessage!   
collect: aBlock
        "For each element in the receiver, evaluate
         aBlock with that element as the argument.
         Answer a collection containing the results
         from the aBlock evaluations as its elements."
    | answer size |
    size := self size.
    answer := self species new: size.
    1 to: size do: [ :index |
        answer at: index put: ( aBlock value: ( self at: index ) ) ].
    ^answer! 
remove: anObject ifAbsent: aBlock
        "Remove anObject from the receiver.  This method
         reports an error since elements cannot be removed
         from fixed size collections, they can only be changed."
    ^self invalidMessage!  
reversed
        "Answer a new object containing the
         elements of the receiver in reverse order."
    | answer i limit |
    answer := self species new: ( ( limit := self size + 1 ) - 1 ).
    i := 0.
    [ ( i := i + 1 ) < limit ] whileTrue: [
        answer at: i put: ( self at: ( limit - i ) ) ].
    ^answer! 
size
        "Answer the number of indexed instance
         variables of the receiver."
    <primitive: 62>
    ^self primitiveFailed!   
copyReplaceFrom: start to: stop with: aCollection
        "Answer a collection containing the elements
         of the receiver with entries indexed from
         start through stop being replaced by the
         elements of aCollection."
    | answer size1 size2 |
    size1 := aCollection size.
    size2 := self size + size1 - (stop - start + 1).
    answer := self species new: size2.
    answer
        replaceFrom: 1
        to: start - 1
        with: self
        startingAt: 1.
    answer
        replaceFrom: start
        to: start + size1 - 1
        with: aCollection.
    ^answer
        replaceFrom: start + size1
        to: size2
        with: self
        startingAt: stop + 1! 
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    | size index firstTime |
    size := self size.
    aStream
        nextPutAll: '((';
        nextPutAll: self class name;
        nextPutAll: ' new: '.
    size printOn: aStream.
    aStream nextPut: $).
    index := 1.
    firstTime := true.
    [index <= size]
        whileTrue: [
            firstTime
                ifFalse: [aStream nextPut: $;].
            firstTime := false.
            aStream nextPutAll: ' at: '.
            index printOn: aStream.
            aStream nextPutAll: ' put: '.
            (self at: index) storeOn: aStream.
            index := index + 1].
    firstTime
        ifFalse: [aStream nextPutAll: '; yourself'].
    aStream nextPut: $)!
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    | answer |
    answer := self class new: self size.
    answer replaceFrom: 1
        to: self size
        with: self
        startingAt: 1.
    ^answer!  
= aCollection
        "Answer true if the elements contained by
         the receiver are equal to the elements
         contained by the argument aCollection."
    | index |
    self == aCollection
        ifTrue: [^true].
    (self class == aCollection class)
        ifFalse: [^false].
    index := self size.
    index ~= aCollection size
        ifTrue: [^false].
    [index <= 0]
        whileFalse: [
            (self at: index) = (aCollection at: index)
                ifFalse: [^false].
            index := index - 1].
    ^true!
replaceFrom: start to: stop withObject: anObject
        "Replace each of the elements of the receiver
         at index positions start through stop with
         anObject.  Answer anObject."
    | index |
    index := start.
    [index <= stop]
        whileTrue: [
            self at: index put: anObject.
            index := index + 1].
    ^anObject!   
indexOfCollection: aCollection
        "Answer the index position of the first occurrence
         of aCollection in the receiver.  If no such element
         is found, answer zero."
    | index1 index2 limit1 limit2 |
    limit2 := aCollection size.
    limit1 := self size - limit2 + 1.
    index1 := 1.
    [index1 <= limit1]
        whileTrue: [
            (self at: index1) = (aCollection at: 1)
                ifTrue: [
                    index2 := 2.
                    [index2 <= limit2
                        and: [ (self at: index1 + index2 - 1) =
                            ( aCollection at: index2 ) ] ]
                        whileTrue: [index2 := index2 + 1].
                    index2 > limit2
                        ifTrue: [ ^index1] ].
            index1 := index1 + 1].
    ^0!
with: aCollection do: aBlock
        "For each pair of elements (the first from the
         receiver and the second from aCollection),
         evaluate aBlock with those elements as the
         arguments.  The receiver and aCollection must contain
         the same number of elements, else report an error."
    | aStream1 aStream2 |
    self size = aCollection size
        ifFalse: [^self error: 'Collections are of differing length'].
    aStream1 := ReadStream on: self.
    aStream2 := ReadStream on: aCollection.
    [aStream1 atEnd]
        whileFalse: [
            aBlock
                value: aStream1 next
                value: aStream2 next]!   
findLast: aBlock ifAbsent: notFoundBlock
        "Answer the index of the last element of the
        receiver that causes aBlock to evaluate to true
        (with that element as the argument).  If no such
        element is found, evaluate notFoundBlock."
    | index |
    index := self size.
    [ index > 0 ] whileTrue: [
        ( aBlock value: ( self at: index ) )
            ifTrue: [ ^index ].
        index := index - 1 ].
    ^notFoundBlock value!
copyFrom: start to: stop
        "Answer a new collection containing the elements
         of the receiver indexed from start through stop."
    | size |
    size := (stop - start + 1 max: 0).
    ^(self species new: size)
        replaceFrom: 1
        to: size
        with: self
        startingAt: start! 
hash
        "Answer the size of the receiver as its hash value."
    ^self size!   
, aCollection
        "Answer a new collection containing the elements
         of the receiver followed by the elements of aCollection."
    | answer size1 size2 |
    aCollection isCollection ifFalse: [ self error: 'Argument must be a Collection' ].
    size1 := self size.
    size2 := size1 + aCollection size.
    answer := self species new: size2.
    answer
        replaceFrom: 1
        to: size1
        with: self
        startingAt: 1.
    answer
        replaceFrom: size1 + 1
        to: size2
        with: aCollection
        startingAt: 1.
    ^answer!   
grow
        "Answer the receiver expanded in
         size to accommodate more elements."
    | size new |
    size := self size.
    new := self species new: size + self growSize.
    new replaceFrom: 1 to: self size with: self.
    self become: new!   
last
        "Answer the last element of the receiver.
         Report an error if the receiver has no elements."
    self isEmpty
        ifTrue: [ ^self accessEmptyCollection].
    ^self at: self size!  
accessEmptyCollection
        "Private - Report an error to the effect
         that the accessed collection was empty."
    ^self error: 'the collection is empty'!   
at: anInteger ifAbsent: aBlock
        "Answer the object in the receiver at index position
         anInteger.  If anInteger is greater than the size
         of the receiver, answer the result of evaluating aBlock. "
    ^anInteger <= self size
        ifTrue: [ super at: anInteger ]
        ifFalse: [ aBlock value ]!   
checkIndex: anInteger
        "Private - Check that the argument anInteger
         is a valid index for the receiver collection.
         If it is found to be invalid, report the error."
    (anInteger isInteger)
        ifFalse: [
            ^self error:
                'Indexed collections are indexed by integers'].
    (anInteger between: 1 and: self size)
        ifFalse: [^self errorInBounds: anInteger]!   
reverseDo: aBlock
        "For each element in the receiver, starting
         with the last element, evaluate aBlock with
         that element as the argument."
    | index |
    index := self size.
    [index > 0]
        whileTrue: [
            aBlock value: (self at: index).
            index := index - 1]!   
indexOf: anObject ifAbsent: aBlock
        "Answer the index position of the element equal
         to anObject in the receiver.  If no such element
         is found, evaluate aBlock (without any arguments)."
    | index size |
    size := self size.
    index := 1.
    [index <= size]
        whileTrue: [
            (self at: index) = anObject
                ifTrue: [^index].
            index := index + 1].
    ^aBlock value!
replaceFrom: start to: stop with: aCollection
        "Answer the receiver.  Replace the elements of the
         receiver at index positions start through stop,
         with the elements of aCollection.  The number of
         elements being replaced must be the same as the
         number of elements in aCollection, else report
         an error."
    stop - start + 1 = aCollection size
        ifFalse: [
            ^self error: 'replacement collection has wrong size'].
    self
        replaceFrom: start
        to: stop
        with: aCollection
        startingAt: 1!
atAllPut: anObject
        "Answer the receiver after each element
         has been replaced with anObject."
    self
        replaceFrom: 1
        to: self size
        withObject: anObject!   
findLast: aBlock
        "Answer the index of the last element of the
         receiver that causes aBlock to evaluate to true
         (with that element as the argument).  If no such
         element is found, report an error."
    ^self findLast: aBlock ifAbsent: [ ^self errorAbsentObject ]!  
replaceFrom: start 
    to: stop
    with: replacement 
    startingWith: replacementStart
        "Replace the elements of the receiver at index positions
        <start> through <stop> with consecutive elements of the
        <replacement> collection beginning at index position
        <replacementStart>. Answer the receiver.
        Error Conditions: if there are not enough elements in the
        replacement collection, send the message #invalidIndex:
        to the replacement collection after partially replacing
        elements in the receiver."
        "Included for compatability with the IBM Common Base." 
    ^self
        replaceFrom: start 
        to: stop
        with: replacement
        startingAt: replacementStart!
size
        "Answer the number of elements of the receiver."
    ^self implementedBySubclass!  
findFirst: aBlock
        "Answer the index of the first element of the
         receiver that causes aBlock to evaluate to true
         (with that element as the argument).  If no such
         element is found, report an error."
    ^self findFirst: aBlock ifAbsent: [ ^self errorAbsentObject ]!   
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    ^self copyFrom: 1 to: self size!  
do: aBlock
        "Answer the receiver.  For each element in the receiver,
         evaluate aBlock with that element as the argument."
    | index size |
    index := 1.
    size := self size.
    [index > size]
        whileFalse: [
            aBlock value: (self at: index).
            index := index + 1]! 
copyWithout: anObject
        "Answer a copy of the receiver excluding
         the first element that equals anObject,
         if any."
    | index |
    index := self
        indexOf: anObject
        ifAbsent: [^self copy].
    ^(self copyFrom: 1 to: index - 1),
        ((self copyFrom: index + 1 to: self size)
            copyWithout: anObject)!
errorInBounds: anInteger
        "Private - Report an error to the effect that
         anInteger is an invalid index for the receiver."
    ^self
        error: 'index: ',
            anInteger printString,
            ' is outside of collection bounds'! 
atAll: aCollection put: anObject
        "Answer the receiver after replacing those
         elements, indexed by the indices contained
         in aCollection, with anObject."
    aCollection do: [ :index |
        self at: index put: anObject]!   
isIndexedCollection
        "Answer whether the receiver is a kind of IndexedCollection."
    ^true!
reverse
        "Answer a new collection containing the elements of
        the receiver in reverse order."  
        "Included for compatability with the IBM Common Base."
    ^self reversed!  
reversed
        "Answer a new object containing the
         elements of the receiver in reverse order."
    ^(ReadStream on: self) reverseContents!  
includes: anObject
        "Answer true if the receiver contains an
         element equal to anObject, else answer false."
    | index |
    index := self size + 1.
    [(index := index - 1) > 0]
        whileTrue: [
            anObject = (self at: index)
                ifTrue: [^true]].
    ^false!  
indexOf: anObject
        "Answer the index position of the element equal
         to anObject in the receiver.  If no such element
         is found, answer zero."
    ^self
        indexOf: anObject
        ifAbsent: [^0]!
copyWith: anObject
        "Answer a copy of the receiver with
         anObject added to it as an element."
    ^ self , (self species with: anObject)!   
growSize
        "Private - Answer the number of elements
         that the receiver is to expand by."
    ^self size + 10!
findFirst: aBlock ifAbsent: errorBlock
        "Answer the index of the first element of the
         receiver that causes aBlock to evaluate to true
         (with that element as the argument).  If no such
         element is found, evaluate the argument block."
    | index size |
    size := self size.
    index := 1.
    [index <= size]
        whileTrue: [
            (aBlock value: (self at: index) )
                ifTrue: [^index].
            index := index + 1].
    ^errorBlock value!  
first
        "Answer the first element of the receiver.
         Report an error if the receiver has no elements."
    self isEmpty
        ifTrue: [^self accessEmptyCollection].
    ^self at: 1! 
replaceFrom: start
    to: stop
    with: aCollection
    startingAt: repStart
        "Replace the elements of the receiver at index
         positions start through stop with consecutive
         elements of aCollection beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |

    (self == aCollection and: [repStart < start])
        ifTrue: [ "do backward move for same object"
            index2 := repStart + stop - start.
            index1 := stop.
            [start <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aCollection at: index2).
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := repStart.
    index1 := start.
    [index1 <= stop]
        whileTrue: [
            self
                at: index1
                put: (aCollection at: index2).
            index1 := index1 + 1.
            index2 := index2 + 1]!   
copyReplaceFrom: start to: stop with: aCollection
        "Answer a new collection containing a copy of the
         receiver with the elements at index positions from
         start through stop replaced with the elements of
         aCollection."
    ^(self copyFrom: 1 to: start - 1)
        , aCollection
        , (self copyFrom: stop + 1 to: self size)!
addAll: aCollection
        "Answer aCollection.  Add each element of
         aCollection to the elements of the receiver."
    aCollection do: [ :element | self add: element].
    ^aCollection!   
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    | limit |
    (RecursiveSet includes: self)
        ifTrue: [^self printRecursionOn: aStream].
    RecursiveSet add: self.
    limit := aStream position + self printLimit.
    self class printOn: aStream.
    aStream nextPut: $(.
    self do: [ :element |
        (aStream position > limit)
            ifTrue: [
                '...etc...)' printOn: aStream.
                RecursiveSet remove: self ifAbsent: [].
                ^self].
        element printOn: aStream.
        aStream space].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: []! 
isCollection
        "Answer true if receiver is an instance of class
         Collection or one of its subclasses, else answer false."
    ^true! 
removeAll
        "Answer aCollection.  Remove all the elements
         contained in the receiver collection."
    self shallowCopy do: [ :element | self remove: element].!  
removeAll: aCollection
        "Answer aCollection.  Remove all the elements
         contained in aCollection from the receiver collection."
    aCollection do: [ :element | self remove: element].
    ^aCollection!   
detect: aBlock
        "Answer the first element of the receiver that
         causes aBlock to evaluate to true (with that
         element as the argument).  If no such element
         is found, report an error."
    ^self
        detect: aBlock
        ifNone: [self errorAbsentObject]! 
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    (RecursiveSet includes: self)
        ifTrue: [
            RecursiveSet := Set new.
            ^self error: 'recursive storeOn: not allowed'].
    RecursiveSet add: self.
    aStream
        nextPutAll: '((';
        nextPutAll: self class name;
        nextPutAll: ' new)'.
    (self inject: true into: [ :firstTime :element |
        firstTime
            ifFalse: [aStream nextPut: $;].
        aStream nextPutAll: ' add: '.
        element storeOn: aStream.
        false])
            ifFalse: [aStream nextPutAll: '; yourself'].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: [ nil ]!
detect: aBlock ifNone: exceptionBlock
        "Answer the first element of the receiver that
         causes aBlock to evaluate to true (with that
         element as the argument).  If no such element is
         found, evaluate exceptionBlock (with no arguments)."
    self do: [ :element |
        (aBlock value: element)
            ifTrue: [^element]].
    ^exceptionBlock value!  
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each element."
    | answer |
    answer := self species new.
    self do: [:element |
        answer add: element copy].
    ^answer! 
reject: aBlock
        "For each element in the receiver, evaluate aBlock
         with that element as the argument.  Answer a new
         collection containing those elements of the receiver
         for which aBlock evaluates to false."
    ^self select: [ :element |
        (aBlock value: element) not]!   
select: aBlock
        "For each element in the receiver, evaluate
         aBlock with that element as the argument.
         Answer a new collection containing those elements
         of the receiver for which aBlock evaluates to true."
    | answer |
    answer := self species new.
    self do: [ :element |
        (aBlock value: element)
            ifTrue: [answer add: element]].
    ^answer!
inject: initialValue into: aBinaryBlock
        "For each element in the receiver collection, evaluate
         aBinaryBlock with that element as the argument.  Starting
         with initialValue, the block is also provided with its own
         value from the previous evaluation.  Answer this value
         at the end of the block evaluations."
    | answer |
    answer := initialValue.
    self do: [ :element |
        answer := aBinaryBlock
            value: answer
            value: element].
    ^answer!  
isEmpty
        "Answer true if the receiver collection
         contains no elements, else answer false."
    ^self size = 0! 
add: anObject
        "Answer anObject.  Add anObject
         to the receiver collection."
    ^self implementedBySubclass!   
asArray
        "Answer an Array containing all
         the elements of the receiver."
    | answer index |
    answer := Array new: self size.
    index := 1.
    self do: [ :element |
        answer at: index put: element.
        index := index + 1].
    ^answer!  
errorAbsentObject
        "Private - Report an error to the effect
         that the element desired was not found
         in the receiver collection."
    ^self error: 'object is not in the collection'!  
asSortedCollection: aBlock
        "Answer a SortedCollection containing
         the elements of the receiver sorted
         according to aBlock."
    ^(SortedCollection new: self size)
        sortBlock: aBlock;
        addAll: self;
        yourself! 
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    ^(self species new)
        addAll: self;
        yourself! 
do: aBlock
        "For each element in the receiver, evaluate aBlock
         with that element as the argument.  This method
         should be implemented in the class of the receiver."
    ^self implementedBySubclass! 
notEmpty
        "Answer true if the receiver collection contains
         one or more elements, else answer false."
    ^self size > 0!   
asOrderedCollection
        "Answer an OrderedCollection containing
         the elements of the receiver."
    ^(OrderedCollection new: self size)
        addAll: self;
        yourself!  
remove: anObject
        "Answer anObject.  Remove the element equal
         to anObject from the receiver collection.  If
         such an element is not found, report an error."
    ^self
        remove: anObject
        ifAbsent: [self errorAbsentObject]! 
printLimit
        "Private - Answer the maximum number of characters
         output to the display screen per each menu show it."
    ^2000! 
collect: aBlock
        "For each element in the receiver, evaluate aBlock with
         that element as the argument.  Answer a new collection
         containing the results as its elements from the aBlock
         evaluations."
    | answer |
    answer := self species new: self size.
    self do: [ :element |
        answer add: (aBlock value: element)].
    ^answer!
remove: anObject ifAbsent: aBlock
        "Answer anObject.  Remove an element equal to
         anObject from the receiver collection.  If such
         an element is not found, evaluate aBlock (with
         no arguments)."
    ^self implementedBySubclass!   
asBag
        "Answer a Bag containing the
         elements of the receiver."
    ^(Bag new)
        addAll: self;
        yourself!
errorNotIndexable
        "Private - Report an error to the effect that
         the receiver collection is not indexable."
    ^self error: self class name,
        's do not respond to indexing messages'!
includes: anObject
        "Answer true if the receiver contains an
         element equal to anObject, else answer false."
    self do: [ :element |
        anObject = element
            ifTrue: [^true]].
    ^false!  
asSortedCollection
        "Answer a SortedCollection containing
         the elements of the receiver sorted
         in ascending order."
    ^(SortedCollection new: self size)
        addAll: self;
        yourself!  
occurrencesOf: anObject
        "Answer the number of elements contained
         in the receiver collection that are equal
         to anObject."
    ^self inject: 0 into: [ :occurrences :element |
        occurrences
            + (element = anObject
                ifTrue: [1]
                ifFalse: [0])]!  
do: aBlock andBetweenDo: separatorBlock
        "For each element in the receiver, evaluate <aBlock>
         with that element as the argument.  Evaluate the <separatorBlock>
         between successive elements of the receiver."
    | first |
    first := true.
    self do: [ :each |
        first
            ifTrue: [ first := false ]
            ifFalse: [ separatorBlock value ].
        aBlock value: each ]!
asSet
        "Answer a Set containing the
         elements of the receiver."
    ^(Set new: self size * 2)
        addAll: self;
        yourself! 
elementsEqual: aCollection
        "Answer true if the receiver has exactly those elements in <aCollection>"

    self size = aCollection size
		ifFalse: [^false].
	aCollection do: [:element |
		(self includes: element)
			ifFalse: [^false]].
	^true!
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."
    ^self
!
replace: count with: aCollection
        "Replace count elements of the receiver
         with elements of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    <primitive: 79>
    aCollection isDoubleByteString
        ifTrue: [
            ^self replaceBytes: count with: aCollection].
    ^self primitiveFailed! 
isByteArray
        "Answer true if receiver is an instance of class
         ByteArray or one of its subclasses, else answer false."
    ^true!   
replaceFrom: start
    to: stop
    with: aCollection
    startingAt: repStart
        "Replace the elements of the receiver at index
         positions start through stop with consecutive
         elements of aCollection beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 105>
    (aCollection isDoubleByteString)
        ifTrue: [
            ^self
                replaceBytesFrom: start to: stop
                with: aCollection
                startingAt: (aCollection byteIndexOfCharAt: repStart)].
    (aCollection class isBytes)
        ifFalse: [
            ^super
                replaceFrom: start
                to: stop
                with: aCollection
                startingAt: repStart].
    " primitive failure on large byte objects "
    (self == aCollection and: [repStart < start])
        ifTrue: [ "do backward move for same object"
            index2 := repStart + stop - start.
            index1 := stop.
            [start <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aCollection at: index2) asInteger.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := repStart.
    index1 := start.
    [index1 <= stop]
        whileTrue: [
            self
                at: index1
                put: (aCollection at: index2) asInteger.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
asString
        "Answer a String whose contents are the
         bytes of the receiver."
    ^(String new: self size) replace: self size with: self.
!   
replaceFrom: start to: stop withAddress: anAddress startingAt: int
        "Private - Use #replaceFrom:to:with:startingAt: instead."
    ^self replaceFrom: start to: stop with: anAddress startingAt: int! 
replaceBytes: count with: aCollection
        "Private - replace count bytes of the receiver
         with bytes of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    <primitive: 81>
    ^self primitiveFailed!  
hash
        "Answer the integer hash
         value for the receiver."
    <primitive: 107>!  
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    class printOn: aStream.
    aStream nextPutAll: '>>'.
    selector printOn: aStream.!
isCompiledMethod
        "Answer true if receiver is a kind of CompiledMethod."
    ^true!  
classField: aClass
        "Private - set the class to which the receiver belongs to aClass."
    class := aClass!  
hash
        "Private - answer the hash value for the receiver."
    ^selector hash!
copy
        "Answer a shallow copy of the receiver."
    | copy |
    copy := super copy.
    copy primitive: nil.
    ^copy!   
hasBlock
        "Private - answer whether the receiver contains any blocks."
    ^self blockCount > 0! 
selector: aSelector
        "Private - set the Symbol used as the receiver's selector to
        aSelector."
    selector := aSelector!
sourceObject
        "Answer the sourceObject."
    ^sourceObject!  
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    ^self objectShallowCopy!  
literals
        "Answer an Array containing all the literals of the receiver."
    ^( Array new: self size ) replaceFrom: 1 to: self size with: self!  
sourceObject: anObject
        "Set the sourceObject to anObject."
    sourceObject := anObject!
bitXor: anInteger
        "Answer an Integer representing the receiver
         bits XORed with the argument anInteger."
    | result size dig2 dig3 carry2 carry3 comp2 comp3 |
    anInteger isInteger
        ifFalse: [ ^anInteger bitAnd: self ].

    size := self byteSize max: anInteger byteSize.

    anInteger positive
        ifTrue:  [
            carry2 := 0.
            comp2 := 0.
            carry3 := 0.
            comp3 := 0.
            result := self class new: size.]
        ifFalse: [
            carry2 :=1.
            comp2 := 16rFF.
            carry3 := 1.
            comp3 := 16rFF.
            result := self class negativeClass new: size.].

    1 to: size do:
        [ :index |
        dig2 := ((anInteger absAt: index) bitXor: comp2) + carry2.
        dig3 := (((self absAt: index ) bitXor: (dig2 bitAnd: 16rFF)) bitXor: comp3) + carry3.
        result at: index put: ( dig3 bitAnd: 16rFF).
        dig2 = 256 ifFalse: [ carry2 := 0.].
        dig3 = 256 ifFalse: [ carry3 := 0.].
        ].
    carry3 ~= 0
        ifTrue: [
            result := (self class negativeClass new: (size + 1))
                 replaceFrom: 1 to: size with: result startingAt: 1.
            result at: size+1 put: carry3].
    ^result reduce.!   
bitAnd: anInteger
        "Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    | result size dig2 carry2 comp2 |
    anInteger isInteger
        ifFalse: [ ^anInteger bitAnd: self ].

    size := self byteSize max: anInteger byteSize.
    result := self class new: size.

    anInteger positive
        ifTrue:  [
            carry2 := 0.
            comp2 := 0.]
        ifFalse: [
            carry2 :=1.
            comp2 := 16rFF.].

    1 to: size do:
        [ :index |
        dig2 := ((anInteger absAt: index) bitXor: comp2) + carry2.
        result at: index put:
            ( ( self absAt: index ) bitAnd: dig2 ).
        dig2 = 256 ifFalse: [ carry2 := 0.]
        ].

    ^result reduce.! 
sign
        "Answer 1 because the receiver is greater than zero"
    ^1!   
printOn: aStream
        "Append the ASCII representation (radix 10)
        of the unsigned receiver to aStream. "
    | quotient digits index array |
    digits := Array new: self byteSize * 3.
    index := 1.
    quotient := self.
    [ quotient isSmallInteger ] whileFalse: [
        array := quotient primitiveDiv: 100 type: self class.
        digits at: index put: ( array at: 2 ).   " remainder"
        index := index + 1.
        quotient := array at: 1 ].

    quotient printOn: aStream.

    index - 1 to: 1 by: -1 do: [ :i |
        aStream nextPut: ( Character value: ( digits at: i ) // 10 + 48 ).
        aStream nextPut: ( Character value: ( digits at: i ) \\ 10 + 48 ) ]!
\\ divisor
        "After dividing the receiver by divisor
        with truncation towards negative infinity,
        answer the integer remainder."
    | answer |

    ( divisor isFloat )       ifTrue:  [ ^ self asFloat \\ divisor ].
    ( divisor isFraction )  ifTrue:  [ ^ super \\ divisor ].
    ( divisor isInteger )    ifFalse: [ ^ self error: 'can''t divide' ].
    divisor = 0 ifTrue: [ ^ self zeroDivisor ].

    divisor positive
    ifTrue:
        [
        self < divisor  ifTrue: [ ^ self ].
        ^ ( self primitiveDiv: divisor type: self class ) at: 2
        ].
    answer := (self primitiveDiv: divisor type: self class negativeClass) at: 2.
    answer = 0
        ifTrue:  [ ^0 ]
        ifFalse: [ ^divisor + answer].!   
< aNumber
        "Answer true if the receiver is less
         than aNumber, else answer false."
    aNumber isInteger
        ifFalse: [ ^( aNumber > self ) ].

    aNumber negative
        ifTrue: [ ^false ].

    ^self absoluteLessThan: aNumber.!   
<= aNumber
        "Answer true if the receiver is less than
         or equal to aNumber, else answer false."
    aNumber isInteger
        ifFalse: [ ^( aNumber >= self ) ].

    aNumber negative
        ifTrue: [ ^false ].

    ^ ( aNumber absoluteLessThan: self ) not.!
bitOr: anInteger
        "Answer an Integer representing the receiver
         bits ORed with the argument anInteger."
    | result size dig2 dig3 carry2 carry3 comp23 |
    anInteger isInteger
        ifFalse: [ ^anInteger bitAnd: self ].

    size := self byteSize max: anInteger byteSize.

    anInteger positive
        ifTrue:  [
            carry2 := 0.
            comp23 := 0.
            carry3 := 0.
            result := self class new: size.]
        ifFalse: [
            carry2 :=1.
            comp23 := 16rFF.
            carry3 :=1.
            result := self class negativeClass new: size.].

    1 to: size do:
        [ :index |
        dig2 := ((anInteger absAt: index) bitXor: comp23) + carry2.
        dig3 := (((self absAt: index ) bitOr: (dig2 bitAnd: 16rFF)) bitXor: comp23) + carry3.
        result at: index put: ( dig3 bitAnd: 16rFF).
        dig2 = 256 ifFalse: [ carry2 := 0.].
        dig3 = 256 ifFalse: [ carry3 := 0.].
        ].
    carry3 ~= 0
        ifTrue: [
            result := (self class negativeClass new: (size + 1))
                 replaceFrom: 1 to: size with: result startingAt: 1.
            result at: size+1 put: carry3].
    ^result reduce.!  
negated
        "Answer the negative value of the receiver."
    | result |
    result := ( LargeNegativeInteger new: self size ).
    self copyInto: result.

    "Check for the special case, < 0 0 0 64 > which
      is Large for positive, but Small for negative."
    ( result at: 4 ) = 64
        ifTrue: [ ^result reduce ]
        ifFalse: [ ^result ].!
negative
        "Answer false because the receiver is greater
         than zero."
    ^false!
positive
        "Answer true because the receiver is 
         greater than zero."
    ^true! 
reduce
        "Answer self, but as a SmallInteger if possible"
    | result smallInt factor |
    result := super reduce.        " trash leading zeros "
    ( ( result size > 4 ) or: [ ( result at: 4 ) > 63 ] )
        ifTrue: [ ^result ].            " cannot be reduced more "

    smallInt := 0.
    factor := 1.
    1 to: result size do:
        [ : index |
        smallInt := smallInt + ( ( result at: index ) * factor ).
        factor := factor * 256.
        ].

    ^smallInt.!
strictlyPositive
        "Answer true if the receiver is
         greater than zero, else answer false."
    ^true!
abs
        "Answer the absolute value of the receiver."
    ^self.!
asUnsigned
        "Answer self as a 32-bit unsigned number; assumes
        the receiver is a 32-bit quantity."
    ^self!
= aNumber
    "Answer true if the receiver is equal
         to aNumber, else answer false."

    | size |
    aNumber isInteger
        ifFalse: [^aNumber = self].
    aNumber isSmallInteger
        ifTrue: [^false].
    self positive = aNumber positive
        ifFalse: [^false].
    ((size := self byteSize) = aNumber byteSize)
        ifFalse: [^false].
    1 to: size do: [:i |
        (self at: i) == (aNumber at: i)
            ifFalse: [^false]].
    ^true.!
addWithCarry: aNumber startingAt: index
        "Private- adds a positive number to self
          at index and follows carry through.
          Assumes: aNumber is positive and self is
           large enough for the result."
    | number idx |

    number := aNumber.
    idx := index.
    [ number > 0 ] whileTrue:
        [
        number := ( self at: idx ) + number.
        self at: idx put: ( number bitAnd: 255) .
        number := number bitShift: -8.
        idx := idx + 1.
        ].

    ^self.!
borrowStartingAt: index
        "Private - Pass the borrow along."
    | value |
    index to: self byteSize do:
        [ :idx |
        ( value := self at: idx ) > 0
            ifTrue: [ ^self at: idx put: value - 1 ]
            ifFalse: [ self at: idx put: 255 ]
        ].!   
+ aNumber
        "Answer the sum of the receiver and aNumber."
    aNumber isInteger
        ifFalse: [ ^aNumber + self ].

    aNumber == 0 ifTrue: [ ^self ].

    aNumber positive = self positive
        ifFalse: [ ^self - aNumber negated ].

    ^( self addBytes: aNumber ).! 
> aNumber
        "Answer true if the receiver is greater
         than aNumber, else answer false."
    ^ ( self <= aNumber ) not!
>= aNumber
        "Answer true if the receiver is greater than
         or equal to aNumber, else answer false."
    ^ ( self < aNumber ) not!
byteSize
        "Answer the number of base-256 digits in the receiver."
    ^self size.!   
hash
        "Answer the integer hash value of the receiver."
    | answer size |
    size := self byteSize.
    answer := ( self at: size ) bitAnd: 16r1F.
    1 to: 3 do: [ :index |
        answer := ( answer bitShift: 8 ) + ( self at: size - index ) ].
    ^answer!
& anInteger
        "Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    ^self bitAnd: anInteger!
bitShift: delta
    "Answer an integer which is the receiver bits shifted
     left delta number of bit positions if delta is
     positive, or bits shifted right for delta negated
     number of bit positions if delta is negative."
    | result count temp carry amount i resultSize |

    delta = 0 ifTrue: [ ^self ].
    count := delta abs.
    resultSize := self byteSize + ( ( delta + 7 ) // 8).
    resultSize <= 0 ifTrue: [ ^0].
    result := self class new: resultSize.
    amount := count // 8.
    carry := 0.
    delta >= 0
    ifTrue:
        [
        i := result byteSize.
        [ i > amount ] whileTrue:
            [
            result at: i put: ( self at: i - amount ).
            i := i - 1
            ].
        ( count := count - ( amount * 8 ) ) > 0
        ifTrue:
            [
            1 to: result byteSize do:
                [ :j |
                temp := ( result at: j ) bitShift: count.
                result at: j put: ( ( temp bitAnd: 255 ) bitOr: carry ).
                carry := temp bitShift: -8.
                ]
            ].
        ^ result reduce
        ]
    ifFalse:
        [
        1 to: result byteSize do:
            [ :j |
            result at: j put: ( self at: j + amount ).
            ].
        ( count := count - ( amount * 8 ) ) > 0
        ifTrue:
            [
            count := count negated.
            i := result byteSize.
            [ i >= 1 ] whileTrue:
                [
                temp := result at: i.
                result at: i put: ( ( temp bitShift: count ) bitOr: carry ).
                carry := ( temp bitShift: 8 + count ) bitAnd: 255.
                i := i - 1
                ]
            ].

        result := result reduce.
        ( self class == LargeNegativeInteger and: [ result = 0 ] )
                ifTrue: [ ^ -1 ].
        ^ result
        ]! 
deepCopy
        "Answer a totally new copy of the receiver"
    ^self copyInto: ( self class new: self size )! 
| anInteger
        "Answer an Integer representing the receiver bits ORed with 
        the argument anInteger."
    ^self bitOr: anInteger!  
- aNumber
        "Answer the difference between
         the receiver and aNumber."
    aNumber isInteger
        ifFalse: [ ^( aNumber - self ) negated ].

    aNumber == 0 ifTrue: [ ^self ].

    aNumber positive == self positive
        ifFalse: [ ^self + aNumber negated ].

    ( self absoluteLessThan: aNumber )
        ifTrue: [ ^ ( ( aNumber subBytes: self ) negated ) ]
        ifFalse: [ ^( self subBytes: aNumber ) ].!   
absoluteLessThan: aNumber
    "Private- LargeInteger arithmetic support.
     Answer true if the absolute value of
      self is less than the absolute value of aNumber."
    aNumber isSmallInteger ifTrue: [ ^false ].
    ^super absoluteLessThan: aNumber.! 
appendDigit: aByte
        "Private - adds a significant digit"
    | result size |
    result := self class new: ( size := self byteSize + 1 ).
    self copyInto: result.
    result at: ( size ) put: aByte.
    ^result.!   
reduce
        "Private - Answer the receiver with all leading zero
         digits removed."
    | last |

    last := self byteSize.
    ( ( self at: last ) ~= 0 ) ifTrue: [ ^self ].

    [ ( last > 2 ) and: [ ( self at: ( last := last - 1 ) ) = 0 ] ]
        whileTrue: [].

    ^self copyInto: ( self class new: last ).!   
quo: divisor
        "Answer the integer quotient of the receiver
         divided by divisor with truncation toward zero."

    ( divisor isFloat )  ifTrue: [ ^ self asFloat quo: divisor ].
    ( divisor isFraction )  ifTrue: [ ^( divisor reciprocal * self ) truncated ].
    ( divisor isInteger )  ifFalse: [ ^ self error: 'can''t divide' ].
    divisor = 0 ifTrue: [ ^ self zeroDivisor ].

    divisor positive == self positive
        ifTrue:     [ ^ ( self primitiveDiv: divisor type: LargePositiveInteger ) at: 1 ]
        ifFalse: [ ^ ( self primitiveDiv: divisor type: LargeNegativeInteger ) at: 1 ].!  
isLargeInteger
        "Answer true if receiver is a kind of LargeInteger."
    ^true!  
at: anInteger
        "Answer the object in the receiver at index position
         anInteger.  If anInteger is greater than the number of 
         indexed instance variables, answer zero."
    <primitive: 60>
    ^0!   
primitiveDiv: divisor type: resultClass
        "Private - Answer an Array with the quotient and
          remainder resulting from dividing the
          receiver by divisor. This assumes that both
          are large integers of any sign. The
          algorithm used is from Knuth vol. 2."
    | u v n m d shift quo qHat r1 r2 r3 j jj t |
    self byteSize - divisor byteSize < 0
        ifTrue: [ ^ Array with: 0 with: self ].

    ( divisor  isSmallInteger
            and: [ ( d := divisor abs ) < 256 ] )
        ifTrue:
            [
            quo := resultClass new: self byteSize.
            u := 0.
            j := self byteSize.
            [ j >= 1 ]
            whileTrue:
                [
                t := u * 256 + ( self at: j ).
                quo at: j put: t // d.
                u := t \\ d.
                j := j - 1
                ].
            self negative ifTrue: [ u := u negated ].
             ^ Array with: quo reduce with: u
             ].

    "make the result "
    d := divisor.

    " Step D1: Normalize
       Shift both of the operands so that the divisor has the
       MSBit set and is thus > 256 / 2. "
    shift := 8 - ( d highDigit highBit ).

    u := self abs bitShift: shift.
    v := d abs bitShift: shift.
    n := v byteSize.
    m := u byteSize - n + 1.
    quo := resultClass new: m.

    "Step D2: Initialize
        Note that v1 in Knuth is the MSDigit whereas here
        it is vn.  Therefore, j should start at the n and
        go down."
    r2 := v highDigit.
    j := m.

    [ j >= 1 ]
    whileTrue:
        [
        "Step D3: Calculate qHat
        Estimate the next digit in the quotient, qHat and
        correct any estimation errors. "
        jj := j + n.

        ( r1 := u at: jj ) = r2
            ifTrue:  [ qHat := 255 ]
            ifFalse:
                [
                t := r1 * 256 + ( u at: jj - 1 ).
                qHat := t // r2.
                "Correct overestimate of qHat.  Max of 2 iterations."
                r3 :=  u at: ( jj - 2 ).
                [ ( qHat * ( v at: n - 1 ) ) > ( ( t - ( qHat * r2 ) ) * 256 + r3 ) ]
                    whileTrue: [ qHat := qHat - 1 ]
                ].

    "Step D4: Multiply and subtract
        Subtract that part of u which has been successfully
        factored."
        t := u - ( v * ( qHat bitShift: j - 1 * 8 ) ).
        t negative
        ifTrue:
            [
            u := u - ( v * ( ( qHat - 1 ) bitShift: j - 1 * 8 ) ).
            quo at: j put: qHat - 1.
            ]
        ifFalse:
            [
            u := t.
            quo at: j put: qHat
            ].
        u = 0 ifTrue: [ ^ ( Array with: quo reduce with: 0 ) ].
        j := j - 1
    ].

        u := u bitShift: shift negated.
    self negative ifTrue: [ u := u negated ].
    ^ ( Array with: quo reduce with: u reduce )!
/ aNumber
        "Answer the result of dividing the receiver by aNumber."
    | numerator denominator gcd |

    aNumber isInteger ifFalse: [ ^( aNumber / self ) reciprocal ].

    numerator := self * aNumber denominator.

    ( denominator := aNumber numerator ) < 0
        ifTrue:
            [
            denominator := 0 - denominator.
            numerator := 0 - numerator
            ].

    ( gcd := numerator gcd: denominator ) = denominator
        ifTrue: [ ^numerator // gcd ]
        ifFalse:
            [ ^Fraction
                numerator: numerator // gcd
                denominator: denominator // gcd
            ].! 
// divisor
        "Answer the quotient of dividing the receiver by aNumber
        with truncation towards negative infinity."
    | answer |

    ( divisor isFloat )  ifTrue: [ ^ self asFloat // divisor ].
    ( divisor isFraction )  ifTrue: [ ^( divisor reciprocal * self ) // 1 ].
    ( divisor isInteger )  ifFalse: [ ^ self error: 'can''t divide' ].

    divisor == 0 ifTrue: [ ^ self zeroDivisor ].

    divisor positive == self positive
    ifTrue:
        [
        ( self absoluteLessThan: divisor ) ifTrue: [ ^ 0 ].
        ^ ( self primitiveDiv: divisor type: LargePositiveInteger ) at: 1
        ].

    ( self absoluteLessThan: divisor )
        ifTrue: [ ^ -1 ].
    answer := self primitiveDiv: divisor type: LargeNegativeInteger.
    ( answer at: 2 ) ~= 0
        ifTrue: [ ^ ( answer at: 1 ) - 1 ].
    ^ answer at: 1.!  
addBytes: anInteger
        "Private- Answer self with anInteger bytes added. Assumes that
         self and anInteger are of the same sign."
    | carry interm result size |
    carry := 0.
    result := self class new: ( size := self byteSize max: anInteger byteSize ).
    self copyInto: result.

    1 to: size do:
        [ : index |
        interm := ( result at: index ) + ( anInteger at: index ) + carry.
        result at: index put: ( interm bitAnd: 255 ).
        carry := interm bitShift: -8.
        ].

    carry > 0 ifTrue: [ result := result appendDigit:  carry ].

    ^result.!  
absAt: index
        "Private - Answer the index'th byte of the absolute value
         of the receiver. Since the numbers are stored sign-magnitude
         we will just get the proper buyte of the magnitude."
    index <= 0
        ifTrue: [ self error: 'byteAt: index must be greater than zero' ].
    ^self at: index.!  
replaceFrom: start to: stop with: aByteObject startingAt: repStart
        "Replace the bytes of the receiver at index positions start
        through stop with consecutive bytes of aByteObject
        beginning at index position repStart."
    <primitive: 105>
    ^self primitiveFailed! 
* aNumber
        "Answer the result of multiplying
         the receiver by aNumber."
    | result size innerSize outerSize digit |
    aNumber isInteger
        ifFalse: [ ^aNumber * self ].

    size := ( outerSize := self byteSize ) + ( innerSize := aNumber byteSize ).
    aNumber positive == self positive
        ifTrue: [ result := LargePositiveInteger new: size ]
        ifFalse: [ result := LargeNegativeInteger new: size ].

    0 to: outerSize - 1 do:
        [ :a |
        digit := self at: a + 1.
        1 to: innerSize  do:
            [ :b |
            result
                addWithCarry: ( digit  * ( aNumber at: b ) )
                startingAt: a + b.
            ]
        ].

    ^result reduce.! 
bitAt: anInteger
        "Answer 0 if the bit at index position anInteger
         in the receiver is 0, else answer 1."
    | digit |
    ( digit := anInteger - 1 // 8 + 1 ) > self byteSize
        ifTrue: [ ^0 ].

    ^( self at: digit ) bitAt: anInteger - 1 \\ 8 + 1.!
subBytes: anInteger
        "Private- Answer a LargeInteger with the bytes subtracted.
          Works for absolute values of self greater than anInteger."
    | result value sub |
    result := self class new: self byteSize.
    self copyInto: result.

    1 to: anInteger byteSize do:
        [ : index |
        ( value := result at: index ) < ( sub := anInteger at: index )
            ifTrue:
                [
                result borrowStartingAt: ( index + 1 ).
                result at: index put: ( value + 256 - sub ).
                ]
            ifFalse: [ result at: index put: ( value - sub ) ]
        ].

    ^result reduce!   
radix: anInteger
        "Answer a string which is the ASCII representation
         of the receiver with radix anInteger."
    | aStream |
    aStream := WriteStream on: (String new: 16).
    self printOn: aStream base: anInteger.
    ^aStream contents!  
ceiling
        "Answer the integer nearest the
         receiver towards positive infinity."
    ^self!   
lowWord
        "Truncate the receiver to a DWORD and answer the LSW; assumes
        the receiver is a 32-bit quantity."
    ^( self bitAnd: 16rFFFF )!   
lowDigit
        "Private- Answer the most significant digit of 
         the receiver."
    ^self at: 1.! 
radix: anInteger showRadix: aBoolean
        "Answer a string which is the ASCII representation
         of the receiver with radix anInteger;
         if aBoolean is true, include the radix prefix."
    | aStream |
    aStream := WriteStream on: (String new: 16).
    self printOn: aStream base: anInteger showRadix: aBoolean.
    ^aStream contents! 
abs
        "Answer the absolute value of the receiver."
    self < 0
        ifTrue: [^0 - self ].
    ^self!
hash
        "Answer the positive integer hash
         value for the receiver."
    ^self abs!
printPaddedWith: aCharacter to: anInteger base: aRadix
        "Answer the string containing the ASCII
         representation of the receiver padded
         on the left with aCharacter to be at least
         anInteger characters."
    | aStream padding digits|
    aStream := WriteStream on: (String new: 10).
    self printOn: aStream base: aRadix showRadix: false.
    digits := aStream contents.
    padding := anInteger - digits size.
    padding > 0
        ifTrue: [
            padding := ((String new: padding)
                atAllPut: aCharacter ;
                yourself)]
        ifFalse:[padding := ''].
    ^padding, digits!
bitShift: anInteger
        "Answer an integer which is the
         receiver shifted left anInteger
         number of bit positions if anInteger
         is positive, or shifted right for
         anInteger negated number of bit
         positions if anInteger is negative."
    anInteger >= 0
        ifTrue:   [ ^self * ( 2 raisedToInteger: anInteger ) ]
        ifFalse: [ ^self // ( 2 raisedToInteger: anInteger negated ) ].!  
printOn: aStream base: anInteger showRadix: aBoolean
        "Append the ASCII representation of
         the receiver with radix b to aStream;
         if aBoolean is true, include the radix
         prefix."
    | aString tempStream n |
    ( n := self ) negative
        ifTrue: [
            aStream nextPut: $-.
            n := self negated ].
    ( anInteger = 10 or: [ aBoolean not ] )
        ifFalse: [ "print radix"
            anInteger printOn: aStream base: 10 showRadix: false.
            aStream nextPut: $r ].
    aString := String new: 16.
    tempStream := WriteStream on: aString.
    [ anInteger <= n ]
        whileTrue: [
            tempStream nextPut: ( Character digitValue: n \\ anInteger ).
            n := n // anInteger ].
    aStream nextPut: ( Character digitValue: n ).
    n := tempStream position.
    aString := tempStream contents.
    [ n = 0 ]
        whileFalse: [
            aStream nextPut: ( aString at: n ).
            n := n - 1 ]!
copyInto: aLargeInteger
        "Private - Answer the receiver copied into the least
        significant digits of aLargeInteger."
    1 to: ( self byteSize min: aLargeInteger size ) do: [ : index |
        aLargeInteger at: index put: ( self at: index ) ].
    ^aLargeInteger!
highWord
        "Truncate the receiver to a DWORD and answer the MSW; assumes
        the receiver is a 32-bit quantity."
    ^( self bitAnd: 16rFFFFFFFF ) bitShift: -16!
absoluteLessThan: aNumber
        "Private - LargeInteger arithmetic support.  Answer
        true if the absolute value of the receiver is less than
        the absolute value of aNumber."
    | index |
    index := self byteSize max: aNumber byteSize.

    [ index > 0 and: [ ( self at: index ) == ( aNumber at: index ) ] ]
        whileTrue: [ index := index - 1 ].

    index == 0
        ifTrue: [ ^false ]              " equal "
        ifFalse: [ ^( self at: index ) < ( aNumber at: index ) ].! 
gcd: anInteger
        "Answer the greatest common divisor
         between the receiver and anInteger."
    | u v r |
    u := self abs.
    v := anInteger abs.
    u < v
        ifTrue: [
            r := u.
            u := v.
            v := r].
    [v = 0]
        whileFalse: [
            r := u \\ v.
            u := v.
            v := r].
    ^u!
printStringRadix: radix
        "Answer a string containing a textual description of the
        receiver with the given <radix>."
    | aStream |
    aStream := WriteStream on: (String new: 16). 
    self printOn: aStream base: radix.
    ^aStream contents!  
strictlyPositive
        "Answer true if the receiver is
         greater than zero, else answer false."
    ^self > 0!
highDigit
        "Private - Answer the most significant digit of
         the receiver."
    ^self at: self byteSize.!
truncated
        "Answer the receiver."
    ^self! 
asRational
	"Answer a Rational number (Fraction or Integer) - representing the receiver."

	^self! 
floor
        "Answer the integer nearest the receiver
         truncating towards negative infinity."
    ^self!  
reciprocal
        "Answer the multiplicative inverse of the receiver: the value
        which, when multiplied by the receiver yields the
        multiplicative identity element."
    ^1 / self!   
lcm: anInteger 
        "Answer the least common multiple 
         between the receiver and anInteger." 
    | gcd |
    (gcd := self gcd: anInteger) = 0 
        ifFalse: [^(self // gcd * anInteger) abs]. 
    ^1! 
asCharacter
        "Answer the character whose ASCII encoding
         matches the value of the receiver."
    ^Character value: self!
printOn: aStream base: anInteger
        "Append the ASCII representation of
         the receiver with radix b to aStream."
    ^self printOn: aStream base: anInteger showRadix: true!   
coerce: aNumber
	"Private - answer aNumber coerced to the same numeric class as the receiver."

	^aNumber asInteger!   
asFloat
        "Answer the floating point
         representation of the receiver."
    ^Float fromInteger: self! 
asInteger
        "Answer the receiver."
    ^self! 
negative
        "Answer true if the receiver is less
         than zero, else answer false."
    ^self < 0!   
rem: aNumber
        "Answer the integer remainder after dividing
         the receiver by aNumber with truncation
         towards zero."
    aNumber = 0 ifTrue: [ ^self zeroDivisor ].
    ^self - ( ( self quo: aNumber ) * aNumber )!   
and: anInteger
        "Private - Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    ^self bitAnd: anInteger!   
bitInvert
        "Answer an integer whose bit values are
         the inverse of the bit values of the receiver."
    ^self negated - 1!  
/ aNumber
        "Answer the result of dividing
         the receiver by aNumber."
    | numerator denominator gcd |
    aNumber isInteger
        ifFalse: [^ ( aNumber reciprocal * self ) ].
    aNumber  negative
        ifTrue: [
            denominator := aNumber negated.
            numerator := self negated ]
        ifFalse: [
            denominator := aNumber.
            numerator := self ].
    (gcd := numerator gcd: denominator) = denominator
        ifTrue: [^numerator // gcd]
        ifFalse: [
            ^Fraction
                numerator: numerator // gcd
                denominator: denominator // gcd]!   
isInteger
        "Answer true if receiver is a kind of Integer."
    ^true!
factorial
        "Answer the factorial of the receiver."
    self > 1
        ifTrue: [^(self - 1) factorial * self].
    self < 0
        ifTrue: [^self error: 'negative factorial'].
    ^1!
printPaddedTo: anInteger
        "Answer the string containing the ASCII
         representation of the receiver padded
         on the left with blanks to be at least
         anInteger characters."
    ^self printPaddedWith: $ to: anInteger base: 10! 
rounded
        "Answer the receiver."
    ^self!   
basicHash
        "Answer the positive integer hash
         value for the receiver."
    ^self abs!   
generality
	"Answer the number representing the ordering of the receiver in the
    generality hierarchy.  When an Integer is operated on with another
    number, the Integer is the number that should be coerced."

	^40! 
positive
        "Answer true if the receiver is greater
         than or equal to zero, else answer false."
    ^self >= 0!   
intSqrt 
        "Answer the integer square root of anInteger" 
    | guess newGuess aBlock | 
    self <= 0 ifTrue: [^0]. 
    guess := self // 2 max: 1. 
    newGuess := (guess * guess + self) // 2 // guess. 
    (guess * guess < self) 
        ifTrue: [aBlock := [newGuess <= guess]] 
        ifFalse: [aBlock := [newGuess >= guess]]. 
    [aBlock value] 
        whileFalse: [ 
            guess := newGuess. 
            newGuess := (guess * guess + self) // 2 // guess]. 
    ^guess!
timesRepeat: aBlock
        "Evaluate aBlock n number of times,
         where n is the receiver."
    | anInteger |
    anInteger := self.
    [anInteger > 0] whileTrue: [
        anInteger := anInteger - 1.
        aBlock value]!
asBoolean
        "Answer true if the receiver is non-zero."
    ^self ~= 0!
asUnsigned
        "Answer self as a 32-bit unsigned number; assumes
        the receiver is a 32-bit quantity."
    self positive
        ifTrue: [ ^self ]
        ifFalse: [ ^self + 4294967296. ]     " ( 2 raisedToInteger: 32 ) "! 
rightMost: aNumber
        "Answer the number which appears closest to the right
         side of the screen between the receiver and aNumber."
    ^(self max: aNumber)!  
ceiling
        "Answer the integer nearest the
         receiver towards positive infinity."
    | anInteger |
    anInteger := self // 1.
        "truncates >> negative infinity"
    anInteger = self ifTrue: [^anInteger].
    ^anInteger + 1!
asParameter
        "Answer self as the appropriate parameter form for
         making system API calls."
    ^self!   
+ aNumber
        "Answer the sum of the receiver and aNumber."
    ^self implementedBySubclass!
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    ^self implementedBySubclass!   
sign
        "Answer 1 if the receiver is greater than zero,
         answer -1 if the receiver is less than zero,
         else answer zero."
    self strictlyPositive
        ifTrue: [^1].
    self negative
        ifTrue: [^-1].
    ^0!   
\\ aNumber
        "After dividing the receiver by aNumber
        with truncation towards negative infinity,
        answer the integer remainder."
    ^(self - (self // aNumber * aNumber)) !  
even
        "Answer true if the integer part of
         the receiver is even, else answer false."
    ^self \\ 2 = 0!
isNumber
        "Answer true if receiver is a kind of Number."
    ^true!  
asFixedPoint: scale
	"Convert the receiver into a FixedPoint number with the stated scale."

	^FixedPoint
		numerator: self numerator
		denominator: self denominator
		scale: scale!   
radiansToDegrees
        "Answer the receiver converted
         from radians to degrees."
    ^self asFloat radiansToDegrees! 
degreesToRadians
        "Answer the receiver converted
         from degrees to radians."
    ^self asFloat degreesToRadians! 
integerSin
        "Answer the integer sine of the receiver
         angle, measured in degrees, scaled by 100."
    | q r |
    r := self rounded \\ 360.
    q := r // 90.
    r := r \\ 90 + 1.
    q = 0 ifTrue: [
        ^SinValues at: r].
    q = 1 ifTrue: [
        ^SinValues at: 92 - r].
    q = 2 ifTrue: [
        ^0 - (SinValues at: r)].
    q = 3 ifTrue: [
        ^0 - (SinValues at: 92 - r)]!
log: aNumber
        "Answer a Float which is the log
         base aNumber of the receiver."
    ^self asFloat ln / aNumber asFloat ln!   
abs
        "Answer the absolute value of the receiver."
    self < self class additiveIdentity
        ifTrue: [^self negated].
    ^self!   
printFraction: numberFractionDigits
        "Answer a string, the ASCII representation
         of the receiver truncated to numberFractionDigits
         decimal places."
    ^self printFraction: numberFractionDigits
        decimalSeparator: NationalLanguage decimalSeparator!   
roundTo: aNumber
        "Answer the receiver rounded to the
         nearest multiple of aNumber."
    (self < 0)
        ifTrue: [^self - (aNumber/2) truncateTo: aNumber]
        ifFalse: [^self + (aNumber/2) truncateTo: aNumber]! 
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reconstructed."
    self printOn: aStream!  
isRightEqualOf: aNumber
        "Answer true if the receiver is right or equal on the screen
         than aNumber, else answer false."
    ^self >= aNumber!  
truncateTo: aNumber
        "Answer the receiver truncated (towards
         zero) to the nearest multiple of aNumber."
    ^(self quo: aNumber) * aNumber!
isLeftOf: aNumber
        "Answer true if the receiver is left on the screen
         than aNumber, else answer false."
    ^self < aNumber!   
deepCopy
        "Answer the receiver."
    ^self!  
left: aNumber
        "Answer the location left aNumber of positions from
        the receiver."
    ^self - aNumber!  
printFraction: numberFractionDigits decimalSeparator: decimalString
        "Answer a string, the ASCII representation
         of the receiver truncated to numberFractionDigits
         decimal places, using decimalString as the
         decimal separator."
   | stream fraction integer |
    numberFractionDigits < 0
        ifTrue: [self error: 'Negative digit count'].
    stream := WriteStream on: (String new: 16).
    integer := self truncated.
    (self > -1) & (self < 0)
        ifTrue: [stream show: '-0']
        ifFalse: [integer printOn: stream].
    numberFractionDigits > 0
      ifTrue: [stream nextPutAll: decimalString].
    fraction := (self - integer) abs.
    integer := 0.
    numberFractionDigits timesRepeat: [
        fraction := (fraction - integer) * 10.
        stream nextPut: ( Character digitValue: (integer := fraction // 1) ) ].
    ^stream contents!  
raisedTo: aNumber
        "Answer a Float which is the receiver
         raised to the power of aNumber."
    aNumber = 0 ifTrue: [^1.0]. "Anything to 0 power is 1"
    ((self = 0) and: [aNumber > 0]) ifTrue: [^0.0].
    self positive ifTrue: [^(aNumber * self abs ln) exp].
    aNumber isInteger ifTrue:  [ ^(self raisedToInteger: aNumber) asFloat].
    ^ArithmeticError signal: 'Float invalid operation'! 
= aNumber
        "Answer true if the receiver is equal
         to aNumber, else answer false."
    <primitive: 47>
    aNumber isFloat
        ifTrue: [ ^self floatError ]
        ifFalse: [
            (aNumber isNumber)
                ifTrue: [^self = aNumber asFloat]
                ifFalse: [^false]]!
exponent
        "Answer the floating point number whose value
         is the exponent part of the floating
         point representation of the receiver."
    <primitive: 53>
    ^self floatError!   
replaceBytesFrom: byteStart
    to: byteStop
    with: aVariableByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aVariableByteObject beginning at index
         position repStart.  Answer the receiver."
    | srcIndex |
    <primitive: 80>
    srcIndex := byteRepStart.
    byteStart to: byteStop do: [ :dstIndex |
        self   " must use basicAt: so DoubleByteString parm handled properly "
            at: dstIndex
            put: (aVariableByteObject basicAt: srcIndex) asInteger.
        srcIndex := srcIndex + 1].!   
+ aNumber
        "Answer sum of the receiver and aNumber."
    <primitive: 41>
    aNumber isFloat
        ifTrue: [ ^self floatError ]
        ifFalse: [ ^self + aNumber asFloat ]!   
printOn: aStream
        "Append the ASCII representation
         (maximum of 8 digits) of
         the receiver to aStream."
    self printOn: aStream
        decimalSeparator: NationalLanguage decimalSeparator!
asFixedPoint: scale
    "Convert the receiver into a FixedPoint number with the stated scale."

    ^self asRational asFixedPoint: scale!  
radiansToDegrees
        "Answer the number of degrees the
         receiver represents in radians."
    ^self * 180.0 / self class pi!
degreesToRadians
        "Answer the number of radians the
         receiver represents in degrees."
    ^self * self class pi / 180.0!
> aNumber
        "Answer true if the receiver is greater
         than aNumber, else answer false."
    ^aNumber asFloat < self!  
>= aNumber
        "Answer true if the receiver is greater than
         or equal to aNumber, else answer false."
    ^( self < aNumber asFloat ) not! 
printFraction: numberFractionDigits
        "Answer a string, the ASCII representation
         of the receiver truncated to numberFractionDigits
         decimal places."
    | fraction digits |
    digits := 10 raisedToInteger: numberFractionDigits.
    fraction := ((self *  digits) rounded) / digits.
    ^fraction printFraction: numberFractionDigits!
abs
        "Answer the absolute value of the receiver."
    self < 0.0
        ifTrue: [^ 0.0 - self ].
    ^self!   
hash
        "Answer the integer hash value for the receiver." 
        "If the receiver is equal to an Integer, answer the
        corresponding Integer's hash value.  Otherwise
        compute a value based on the integer part and
        the most significant bits of the fraction part."
    | intPart fracPart fracInt shifter mask |
    intPart := self truncated.
    fracPart := (self - intPart asFloat) abs.
    fracPart = 0.0
        ifTrue: [^intPart hash].
    shifter := 16r40000000.        "use only 30 bits for hash values?"
    mask := 16r3FFFFFFF.
    fracInt := (shifter * fracPart * (2.0 raisedTo: fracPart exponent abs)) truncated.
    ^(intPart abs bitXor: fracInt) bitAnd: mask!
printFraction: numberFractionDigits decimalSeparator: aString
        "Answer a string, the ASCII representation
         of the receiver truncated to numberFractionDigits
         decimal places, using decimalString as the
         decimal separator."
    | fraction digits |
    digits := 10 raisedToInteger: numberFractionDigits.
    fraction := ((self *  digits) rounded) / digits.
    ^fraction printFraction: numberFractionDigits decimalSeparator: aString!
floatError
        "Private - query the floating point coprocessor as
         to the type of exception and report it."
    | status |
    status := self class status.
    (status bitAnd: 8) ~= 0
        ifTrue: [^ArithmeticError signal: 'Float overflow exception'].
    (status bitAnd: 16r10) ~= 0
        ifTrue: [^ArithmeticError signal: 'Float underflow exception'].
    (status bitAnd: 4) ~= 0
        ifTrue: [ ^self zeroDivisor ].
    (status bitAnd: 2) ~= 0
        ifTrue: [^ArithmeticError signal: 'Float denormalized operand'].
    (status bitAnd: 1) ~= 0
        ifTrue: [^ArithmeticError signal: 'Float invalid operation'].
    (status bitAnd: 16r80) ~= 0
        ifTrue: [^ArithmeticError signal: 'Math coprocessor missing'].
    ^ArithmeticError signal: 'Float undefined exception'!
- aNumber
        "Answer the difference between
         the receiver and aNumber."
    <primitive: 42>
    aNumber isFloat
        ifTrue: [ ^self floatError ]
        ifFalse: [ ^self - aNumber asFloat ]! 
negated
        "Answer the receiver subtracted from zero."
    ^0.0 - self!
strictlyPositive
        "Answer true if the receiver is
         greater than zero, else answer false."
    ^self > 0.0!  
truncated
        "Answer the receiver as a kind of
         Integer truncating the fraction part."
    | answer float scale partialInt |
    <primitive: 51>
    self negative ifTrue: [ ^ self abs truncated negated ].
    scale := self exponent truncated.
    float := self timesTwoPower: scale \\ 13 - scale.
    answer := float truncated.
    float := float - answer asFloat.
    scale // 13 timesRepeat: [
        float := float timesTwoPower: 13.
        partialInt := float truncated.
        answer := answer * 8192 + partialInt.
        float := (float - partialInt asFloat)].
    ^answer!   
asRational
	"Answer a Rational number (Integer or Fraction) representing the receiver.
    This conversion uses the continued fraction method to approximate
    a floating point number."

	| num1 denom1 num2 denom2 int frac newD temp limit |
	limit := 1.0e14.
	num1 := self truncated. "The first of two alternating numerators"
	denom1 := 1. "The first of two alternating denominators"
	num2 := 1. "The second numerator"
	denom2 := 0. "The second denominator--will update"
	int := num1. "The integer part of self"
	frac := self - num1. "The fractional part of self"
	[frac = 0]
		whileFalse:
			[ "repeat while the fractional part is not zero"
			newD := 1.0 / frac. "Take reciprocal of the fractional part"
			int := newD truncated. "get the integer part of this"
			frac := newD - int. "and save the fractional part for next time"
			temp := num2. "Get old numerator and save it"
			num2 := num1. "Set second numerator to first"
			num1 := num1 * int + temp. "Update first numerator"
			temp := denom2. "Get old denominator and save it"
			denom2 := denom1. "Set second denominator to first"
			denom1 := int * denom1 + temp. "Update first denominator"
			limit < denom1
				ifTrue:
					[ "Is ratio past float precision?  If so, pick which
                    of the two ratios to use"
					num2 = 0.0
						ifTrue:
							[ "Is second denominator 0?"
							^Fraction numerator: num1 denominator: denom1].
					^Fraction numerator: num2 denominator: denom2]].
	"If fractional part is zero, return the first ratio"
	denom1 = 1
		ifTrue:
			[ "Am i really an Integer?"
			^num1 "Yes, return Integer result"]
		ifFalse:
			[ "Otherwise return Fraction result"
			^Fraction numerator: num1 denominator: denom1]!   
reciprocal
        "Answer one divided by the receiver."
    ^1.0 / self!   
printOn: aStream decimalSeparator: decimalString
        "Append the ASCII representation
         (maximum of 8 digits) of
         the receiver to aStream
         using decimalString as the decimal
         separator."
    | digitCount integer number rounder scale n integerString |
    (number := self) < 0.0
        ifTrue: [
            aStream nextPut: $-.
            number := self negated].
    number = 0.0
        ifTrue: [^aStream nextPut: $0; nextPutAll: decimalString; nextPut: $0].
    scale := ( number log: 10 ) truncated.
    number := number / (( scale asFloat * 10.0  ln) exp ).
    rounder :=  5.0e-9.
    number := number + rounder.
    number >= 10.0
        ifTrue: [
            number := number /10.0.
            scale := scale + 1].
    scale = 0
        ifFalse: [
            (scale > 7 or: [
            scale < -7 or: [
            scale < 0 and: [
            n := number * (( (scale+ 7) asFloat * 10.0  ln) exp ).
            ((n - n truncated) * (( scale negated * 10.0  ln) exp)) truncated ~= 0]]])
                ifFalse: [
                    number := number * (( scale asFloat * 10.0  ln) exp ).
                    rounder := rounder * (( scale * 10.0  ln) exp).
                    scale := 0]].
    integer := number truncated.
    number := number - integer.
    integerString := '                    '.
    digitCount := integerString size.
    [ integer >= 10 ] whileTrue: [
        integerString at: digitCount put: ( Character digitValue: ( integer \\ 10 ) ).
        digitCount := digitCount - 1.
        integer := integer // 10].
    integerString at: digitCount put: ( Character digitValue: ( integer \\ 10 ) ).
    digitCount to: integerString size do: [:i|
        aStream nextPut: ( integerString at: i ) ].
    digitCount := 9 - (integerString size - digitCount + 1).
    aStream nextPutAll: decimalString.
    rounder := rounder * 2.0.
    [number := number * 10.0.
    integer := number truncated.
    number := number - integer.
    aStream nextPut: (Character digitValue: integer).
    (digitCount := digitCount - 1) > 0 and:
    [(rounder := rounder * 10.0 )  <= number]]
        whileTrue: [].
    scale = 0
        ifFalse: [
            aStream nextPut: $e.
            scale printOn: aStream]!  
exp
        "Answer the exponential of the receiver."
    <primitive: 45>
    ^self floatError!
coerce: aNumber
	"Private - answer aNumber coerced to the same numeric class as the receiver."

	^aNumber asFloat! 
significand
        "Answer the floating point number whose value
         is the significand part of the floating
         point representation of the receiver."
    <primitive: 52>
    ^self floatError! 
cos
        "Answer the cosine of the receiver.  The
         receiver is an angle measured in radians"
    <primitive: 30>
    ^self floatError! 
asFloat
        "Answer the receiver as a floating
         point number."
    ^self!  
negative
        "Answer true if the receiver is less
         than zero, else answer false."
    ^self < 0.0! 
sqrt
        "Answer the square root of the receiver."
    <primitive: 44>
    ^self floatError!   
tan
        "Answer the tangent of the receiver.  The
         receiver is an angle measured in radians"
    <primitive: 83>
    ^self floatError!
isFloat
        "Answer true if receiver is a kind of Float."
    ^true!
/ aNumber
        "Answer the result of dividing
         the receiver by aNumber."
    <primitive: 50>
    aNumber isFloat
        ifTrue: [ ^self floatError ]
        ifFalse: [ ^self / aNumber asFloat ]!  
// aNumber
        "Answer the integer quotient after dividing
         the receiver by aNumber with truncation
         towards negative infinity."
    | answer quotient |
    quotient := self / aNumber.
    answer := quotient truncated.
    quotient < 0
        ifTrue: [
            answer = quotient
                ifFalse: [^answer - 1]].
    ^answer!  
ln
        "Answer the natural log of the receiver."
    <primitive: 46>
    ^self floatError! 
< aNumber
        "Answer true if the receiver is less
         than aNumber, else answer false."
    <primitive: 43>
    aNumber isFloat
        ifTrue: [ ^self floatError ]
        ifFalse: [^self < aNumber asFloat]!  
<= aNumber
        "Answer true if the receiver is less than
         or equal to aNumber, else answer false."
    ^(aNumber asFloat < self) not!  
replaceFrom: start
    to: stop
    with: aString
    startingAt: repStart
        "Private - For use by ObjectFiler to load Float values."
    | srcIndex |
    <primitive: 105>
    srcIndex := repStart.
    start to: stop do: [ :dstIndex |
        self at: dstIndex put: (aString at: srcIndex) asInteger.
        srcIndex := srcIndex + 1].!   
generality
	"Answer the number representing the ordering of the receiver in the
    generality hierarchy.  Anything else should be coerced to a Float."

	^80!
timesTwoPower: anInteger
        "Answer 2 to the exponent anInteger
         multiplied by the receiver."
    <primitive: 54>
    ^self * ( 2 raisedToInteger: anInteger ) asFloat.! 
* aNumber
        "Answer the result of multiplying
         the receiver by aNumber."
    <primitive: 49>
    aNumber isFloat
        ifTrue: [ ^self floatError ]
        ifFalse: [ ^self * aNumber asFloat ]!   
positive
        "Answer true if the receiver is greater
         than or equal to zero, else answer false."
    ^self >= 0.0! 
sin
        "Answer the sine of the receiver.  The
         receiver is an angle measured in radians"
    <primitive: 48>
    ^self floatError!   
arcTan
        "Answer the arc-tangent, an angle in
         radians, of the receiver."
    <primitive: 85>
    ^self floatError! 
denominator
        "Answer the denominator of the receiver.  Default
         is one which can be overridden by the subclasses."
    ^1!  
- aNumber
        "Answer the difference between
         the receiver and aNumber."
    ^self + aNumber negated!  
negated
        "Answer the negation of the receiver."
    ^self class additiveIdentity - self! 
quo: aNumber
        "Answer the integer quotient
         with truncation toward zero."
     ^(self / aNumber) truncated! 
squared
        "Answer the receiver multiplied by the receiver."
    ^self * self! 
strictlyPositive
        "Answer true if the receiver is
         greater than zero, else answer false."
    ^self > self class additiveIdentity!  
zeroDivisor
        "An attempt was made to divide the receiver by zero."
    ^ZeroDivide dividend: self!   
odd
        "Answer true if the integer part of
         the receiver is odd, else answer false."
    ^self \\ 2 = 1!  
@ aNumber
        "Answer a point with the receiver as the
         x-coordinate and aNumber as the y-coordinate."
    ^Point basicNew
        x: self;
        y: aNumber!  
leftMost: aNumber
        "Answer the number which appears closest to the left
         side of the screen between the receiver and aNumber."
    ^(self min: aNumber)!
floor
        "Answer the integer nearest the receiver
         truncating towards negative infinity."
    ^self // 1! 
reciprocal
        "Answer one divided by the receiver."
    ^self class multiplicativeIdentity / self! 
shallowCopy
        "Answer the receiver."
    ^self!   
exp
        "Answer a Float which is the
         exponential of the receiver."
    ^self asFloat exp! 
truncated
        "Answer the integer that is closest to the receiver towards zero."   
    ^self truncateTo: 1!
printRounded: numberFractionDigits
        "Answer a string, the ASCII representation
         of the receiver rounded to numberFractionDigits
         decimal places."
    | rounder |
    numberFractionDigits > 9
        ifTrue: [
            rounder := (10 raisedToInteger: numberFractionDigits + 1)
                reciprocal]
        ifFalse: [
            rounder := 1/(#(1 10 100 1000 10000
                100000 1000000 10000000
                100000000 1000000000 )
                    at: numberFractionDigits + 1)].
    ^(self roundTo: rounder)
        printFraction: numberFractionDigits!  
to: aNumber do: aBlock
        "Evaluate the one argument block aBlock for the
         numbers between the receiver and the argument
         aNumber where each number is the previous number
         plus 1."
    | index |
    index := self.
    [index <= aNumber]
        whileTrue: [
            aBlock value: index.
            index := index + 1]!
raisedToInteger: anInteger
        "Answer the receiver raised
         to the power of anInteger."
    | answer multiplier leftToDo |
    (anInteger isInteger)
        ifFalse: [ ^self error: 'raisedToInteger needs integer power' ].
    anInteger < 0
        ifTrue: [ ^ (self raisedToInteger: 0 - anInteger ) reciprocal ].

    answer := self class multiplicativeIdentity.
    anInteger == 0 ifTrue: [ ^ answer ].

    multiplier := self.
    anInteger == 1 ifTrue: [ ^multiplier ].
    anInteger == 2 ifTrue: [ ^multiplier squared ].

    leftToDo := anInteger.
    [ leftToDo > 0 ] whileTrue: [
        ( leftToDo bitAnd: 1 ) = 1
            ifTrue: [ answer := answer * multiplier ].
        leftToDo := leftToDo bitShift: -1.
        multiplier := multiplier squared. ].
    ^answer.!  
cos
        "Answer a Float which is the cosine of the receiver.
         The receiver is an angle measured in radians."
    ^self asFloat cos!
right: aNumber
        "Answer the location right aNumber of positions 
          from the receiver." 
    ^self + aNumber!
asInteger
        "Answer self rounded to the nearest Integer."
    ^self rounded!  
negative
        "Answer true if the receiver is less
         than zero, else answer false."
    ^self < self class additiveIdentity! 
to: aNumber
        "Answer an Interval for the numbers between
         the receiver and the argument aNumber where
         each number is the previous number plus 1."
    ^Interval from: self to: aNumber!   
numerator
        "Answer the numerator of the receiver.  Default
         is the receiver which can be overridden by the
         subclasses."
    ^self!
rem: aNumber
        "Answer the integer remainder after dividing
         the receiver by aNumber with truncation
         towards zero."
    ^self - ((self quo: aNumber) * aNumber)!   
sqrt
        "Answer a Float which is the
         square root of the receiver."
    ^self asFloat sqrt!   
tan
        "Answer a Float which is the tangent of
         the receiver.  The receiver is an angle
         measured in radians."
    ^self asFloat tan!
/ aNumber
        "Answer the result of dividing
         the receiver by aNumber."
    ^self implementedBySubclass!   
// aNumber
        "Answer the integer result of dividing the
         receiver by aNumber with truncation
         towards negative infinity."
    ^self implementedBySubclass!  
arcCos
        "Answer the arc-cosine, an angle in
         radians, of the receiver."
    ^(Float pi / 2.0 ) - self arcSin!   
isLeftEqualOf: aNumber
        "Answer true if the receiver is left or equal on the screen
         than aNumber, else answer false."
    ^self <= aNumber!
ln
        "Answer a Float which is the
         natural log of the receiver."
    ^self asFloat ln!   
isRightOf: aNumber
        "Answer true if the receiver is right on the screen
         than aNumber, else answer false."
    ^self > aNumber! 
rounded
        "Answer the nearest integer to the receiver."
    ^self + self + self sign quo: 2!  
to: sNumber by: iNumber
        "Answer an Interval for the numbers between
         the receiver and the argument sNumber where each
         number is the previous number plus the argument
         iNumber."
    ^Interval from: self to: sNumber by: iNumber!  
timesTwoPower: anInteger
        "Answer the result of multiplying the
         receiver by 2 to the exponent anInteger."
    ^self asFloat timesTwoPower: anInteger!  
asShortParameter
        "Answer the appropriate short parameter out of self for
         making system API calls."
    ^self \\ 65536!
* aNumber
        "Answer the result of multiplying
         the receiver by aNumber."
    ^self implementedBySubclass!
positive
        "Answer true if the receiver is greater
         than or equal to zero, else answer false."
    ^self >= self class additiveIdentity! 
integerCos
        "Answer the integer cosine of the receiver
         angle, measured in degrees, scaled by 100."
    | q r |
    r := self rounded \\ 360.
    q := r // 90.
    r := r \\ 90 + 1.
    q = 0 ifTrue: [
        ^SinValues at: 92 - r].
    q = 1 ifTrue: [
        ^0 - (SinValues at: r)].
    q = 2 ifTrue: [
        ^0 - (SinValues at: 92 - r)].
    q = 3 ifTrue: [
        ^SinValues at: r]!  
sin
        "Answer a Float which is the sine of the receiver.
         The receiver is an angle measured in radians."
    ^self asFloat sin!  
to: sNumber by: iNumber do: aBlock
        "Evaluate the one argument block aBlock for the
         numbers between the receiver and the argument
         sNumber where each number is the previous number
         plus the argument iNumber."
    | index |
    index := self.
    iNumber > 0
        ifTrue: [
            [index <= sNumber] whileTrue: [
                aBlock value: index.
                index := index + iNumber]]
        ifFalse: [
            [sNumber <= index] whileTrue: [
                aBlock value: index.
                index := index + iNumber]]!
arcSin
        "Answer the arc-sine, an angle in
         radians, of the receiver."
    | value |
    value := self asFloat.
    ( value > 1.0 or: [value < -1.0 ])
        ifTrue: [^self error: 'receiver of arcSin out of range'].
    value = 1.0
        ifTrue: [^Float pi / 2.0 ].
    value = -1.0
        ifTrue: [^(Float pi / 2.0 ) negated].
    ^(value / (1.0 - ( value  * value )) sqrt) arcTan!   
arcTan
        "Answer the arc-tangent, an angle in
         radians, of the receiver."
    ^self asFloat arcTan!  
hasMessagePattern
        "Private - answer whether the receiver has a message pattern."
	^true!
hideSource
        "Hide the source code for the receiver."
    self sourceObject: nil! 
classField
        "Answer the class to which the receiver belongs."
    ^class!
selector
        "Answer the Symbol used as the receiver's selector."
    ^selector!
replaceBytesFrom: byteStart
    to: byteStop
    with: aVariableByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aVariableByteObject beginning at index
         position repStart.  This message is not valid
         for symbols, since they are not allowed to change."
    ^self invalidMessage!  
replaceFrom: start to: stop withObject: aCharacter
        "Replace the characters of the receiver
         at index positions start through stop
         with aCharacter.  This message is not valid
         for symbols, since they are not allowed to change."
    ^self invalidMessage!
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."
    ^self asString asParameter
!   
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    aStream nextPutAll: self!  
evaluateFor: anObject
        "Evaluate the receiver, using anObject as the receiver
        of the receiver as a message send."
    ^anObject perform: self!  
asString
        "Answer a String of the characters
         contained by the receiver."
    ^(String new: self size)
        replaceFrom: 1
        to: self size
        with: self!  
storeOn: aStream
        "Append the text representation of the
         receiver to aStream from which the
         receiver can be reconstructed."
    aStream
        nextPut: $#;
        nextPutAll: self! 
hash
        "Answer the integer hash
         of the receiver."
    <primitive: 93>!  
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable.  Because
         symbols are unique (cannot be copied),
         answer the receiver."
     ^self!  
replace: count with: aCollection
        "Replace count elements of the receiver
         with elements of aCollection.  This
         message is not valid for symbols, since they
         are not allowed to change."
    ^self invalidMessage!   
species
        "Answer class String as the
         species of symbols."
    ^String! 
asSymbol
        "Answer a Symbol for the receiver.  The receiver
         itself is answered since it is a Symbol."
    ^self!
isSymbol
        "Answer true if receiver is an instance of class
         Symbol or one of its subclasses, else answer false."
    ^true! 
shallowCopy
        "Answer a shallow copy of the receiver.
         Because symbols are unique (cannot be
         copied), answer the receiver."
    ^self! 
at: anInteger put: aCharacter
        "Replace the character in the receiver indexed by
         anInteger with the argument aCharacter.  This
         message is not valid for symbols, since they
         are not allowed to change."
    ^self invalidMessage!  
initContents: aString
        "Private - initialize the receiver to contain
         the character sequence in aString."
    super
        replaceFrom: 1 to: aString size
        with: aString
        startingAt: 1! 
asCompactString
        " Answer the most compact string containing the
         characters of the receiver. "
    ^self asString! 
asMixedString
        "Answer the receiver as a String in mixed-encoding."
    ^self asString!  
asNormalizedString
        "Private - Does not apply to DoubleByteString."
    ^self invalidMessage
!  
asNormalizedString: leadByteFlags
        "Private - Does not apply to DoubleByteString."
    ^self invalidMessage
!   
asExistingSymbolOrNil
        "If a symbol already exists that represents the same string as
        the receiver, return the existing symbol.  Otherwise return nil"
	^self!  
basicHash
        "Answer the integer hash
         of the receiver."
    ^self hash!  
replaceFrom: start
    to: stop
    with: aString
    startingAt: repStart
        "Replace the characters of the receiver at index
         positions start through stop with consecutive
         characters of aString beginning at index
         position repStart.  This message is not valid
         for symbols, since they are not allowed to change."
    ^self invalidMessage!   
asExternalString
        "Answer the receiver as a String in mixed-encoding."
    ^self asString!   
findKeyIndex: key for: client
    "Private- Answer the index position of a key in the 
	receiver or the first empty key position."

    | index indexedObject lastIndex |
    lastIndex := self size.
    index := ( ( key basicHash ) bitAnd: ( lastIndex // 2 - 1 ) ) * 2 + 1.

    [ ( indexedObject := self at: index ) == nil
            or: [ indexedObject == key ] ]
        whileFalse:
            [ ( index := index + 2 ) > lastIndex
                ifTrue: [ index := 1. ] 
			].
    ^index!   
atKey: key
put: element
for: client
	"Associate <key> with <element> if <key> is not already present.  Answer nil if a new association was added, otherwise answer the existing key. The <client> is responsible for computing hash values."

	| index |
	index := self findKeyIndex: key for: client.
	^(self at: index) == nil
		ifTrue:
			[self at: index put: key.
			self at: index + 1 put: element.
			nil]
		ifFalse:
			[self at: index + 1 put: element.
			key]!
lookUpValue: key for: client ifAbsent: exceptionBlock
    "Answer the value associated with <key> if it is present in the receiver, otherwise result of <exceptionBlock>. The <client> is responsible for computing hash values."

    | index |
    ^(self at: (index := self findKeyIndex: key for: client)) == nil
        ifTrue: [exceptionBlock value]
        ifFalse: [self at: index + 1]! 
privateAtKey: key
put: element
for: client
	"Private - Associate <key> with <element>, assuming that the element is a valid element and that <key> is not already in the receiver. The <client> is responsible for computing hash values."

	| index |
	self at: (index := self findKeyIndex: key for: client) put: key.
	self at: index + 1 put: element! 
removeKey: element
for: client
ifAbsent: exceptionBlock
	"Remove an element equal to the given <element> from the receiver. If the receiver does not contain an element equal to the element to be removed, return the result of evaluating the <exceptionBlock>. The <client> is responsible for computing hash values."

	| lastIndex testIndex testObject searchIndex |
	testIndex := self findKeyIndex: element for: client.
	(self at: testIndex) == nil
		ifTrue: [^exceptionBlock value].
	self at: testIndex put: nil.
	self at: testIndex + 1 put: nil.
	lastIndex := self size.
	[(testIndex := testIndex + 2) > lastIndex
			ifTrue: [testIndex := 1].
		(testObject := self at: testIndex) == nil]
		whileFalse:
			[(self at: (searchIndex := self findKeyIndex: testObject for: client)) == nil
				ifTrue:
					[self at: searchIndex put: testObject.
					self at: searchIndex + 1 put: (self at: testIndex + 1).
					self at: testIndex put: nil.
					self at: testIndex + 1 put: nil]]! 
lookUpValue: key for: client
    "Answer the value associated with <key>, or signal an error if not present. The <client> is responsible for computing hash values."

    | index |
    ^(self at: (index := self findKeyIndex: key for: client)) == nil
        ifTrue: [client errorAbsentKey]
        ifFalse: [self at: index + 1]! 
privateAtSlot: slot
putKey: key
element: element
	"Private"

	self at: slot put: key.
	self at: slot + 1 put: element!  
keysAndValuesDo: iterationBlock
	"Evaluate the <iterationBlock> once for each key/value pair in the receiver. The key will be the first argument, the value will be the second argument to the block. If the receiver is empty, the block will not be evaluated."

	| key |
	1 to: self size by: 2
			do:
				[:index |
				(key := self at: index) == nil
					ifFalse: [iterationBlock value: key value: (self at: index + 1)]]!
loadFactorExceeded: count
		"Answer true if (count / self size) exceeds a fixed load factor."
		"Implementation note: this forumla is related to the one in other implementors of the 				message, and in Set>>allocationForSize:."

	^(count * 200) >= (self size * 75)! 
count
	"Answer the number of elements in the receiver."

	| n |
	n := 0.
	1 to: self size by: 2
			do:
				[:i |
				(self at: i) == nil
					ifFalse: [n := n + 1]].
	^n!  
lookUpKey: element for: client
    "Answer <element> if it is present in the receiver, otherwise nil. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    ^self at: ( self findKeyIndex: element for: client )!   
privateAtKey: key
putValue: value
for: client
	"Private - Add a new <value> to the receiver at <key>."

	^self privateAtKey: key
		put: value
		for: client!   
elementsDo: iterationBlock
	"Evaluate the <iterationBlock> once for each element in the receiver. If the receiver is empty, the block will not be evaluated."

	| value |
	1 to: self size by: 2
			do:
				[:index |
				(value := self at: index) == nil
					ifFalse: [iterationBlock value: (Association key: value value: (self at: index + 1))]]!   
findKeyIndex: key
for: client
	"Private"
	"Answer the index position of an <key> in the receiver or the first empty key position. The <client> is responsible for computing hash values."

	| index indexedObject lastIndex |
	lastIndex := self size.
	index := ((client computeHash: key) \\ (lastIndex // 2)) * 2 + 1.
	[(indexedObject := self at: index) == nil or: [client compare: key candidate: indexedObject]]
		whileFalse:
			[(index := index + 2) > lastIndex
				ifTrue: [index := 1]].
	^index!   
copyFrom: bucket
for: client
    "Private - copy the contents of bucket to the receiver.
    Answer the number of elements copied."

    | count |
    count := 0.
    bucket
        keysAndValuesDo:
            [:key :value |
            count := count + 1.
            self
                    privateAtKey: key
                    put: value
                    for: client].
    ^ count! 
isLiteral
	"Answer <true> if the receiver has a literal representation."

	^false! 
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    | answer |
    answer := self class basicNew: self size.
    answer replaceFrom: 1
        to: self size
        with: self
        startingAt: 1.
    ^answer! 
bucketClass
    "Answer the class of hash table buckets the receiver uses."

    ^LinearSymbolHashTable!   
flushFromCache: aSymbol
        "Private - Flush the method selector from the cache
         so that method lookup uses the most current method
         dictionaries."
    <primitive: 113>! 
adjustSize
    "Private"
    "If the receiver is getting full, expand it to accomodate more objects."

    (self contents loadFactorExceeded: self elementCount)
        ifTrue: [self grow]!
flushAllFromCache
        "Flush all method selectors defined by the receiver from the cache
        so that method lookup uses the most current method  dictionaries."
    self keysDo: [ :k | self flushFromCache: k ]!  
classField
        "Answer the class to which the receiver belongs."
    ^class!
newContents: alloc
    "Private"
    "Answer the collection used to hold the contents of the receiver when the receiver needs <alloc> slots."

    ^self bucketClass new: alloc!  
isMethodDictionary
        "Answer true if receiver is an instance of class
         MethodDictionary or one of its subclasses, else answer false."
    ^true! 
classField:  aClass
        "Set the class to which the receiver belongs to aClass."
    class := aClass!   
shallowCopy
        "Answer a copy of the receiver which shares
         the receivers elements."
    ^super shallowCopy classField: self classField.! 
do: iterationBlock
    "Evaluate the <iterationBlock> once for each element in the receiver. If the receiver is empty, the block will not be evaluated."

    self contents keysAndValuesDo:
        [:key :value |
        iterationBlock value: value]!
at: key put: element
        "Associate element with key."

    key == nil
        ifTrue: [ ^self error: 'Key cannnot be nil.' ].
    ( self contents atKey: key put: element for: self ) == nil
        ifTrue: [self incrementElementCount].
    ^element!  
bucketClass
    "Answer the class of hash table buckets the receiver uses."

    ^LinearIdentityHashTable! 
associationAt: aKey
        "Answer the Association whose key equals aKey
         from the receiver.  If not found,
         report an error."
    ^self
        associationAt: aKey
        ifAbsent: [self errorAbsentKey]!  
associationAt: key ifAbsent: exceptionBlock
    "Answer an Association with the given key whose value is the
    value associated with that key by the receiver. If there is
    no value associated with the key, answer the result of evaluating
    the exceptionBlock."
    | value |
    value := self contents
        lookUpValue: key for: self ifAbsent: [ ^exceptionBlock value ].
    ^self associationClass key: key value: value!
keyCollectionClass
    "Private - answer the class used to collect key values."

    ^IdentitySet! 
adjustSize
    "Private"
    "If the receiver is getting full, expand it to accomodate more objects.  #newContents: ensures that contents with size >= #maxHash is a BucketIdentityHashTable."

    (self contents class == LinearIdentityHashTable or: [self contents size < self maxHash])
        ifTrue:
            [(self contents loadFactorExceeded: self elementCount)
                ifTrue: [self grow]]!  
indexOf: element
ifAbsent: exceptionBlock
    "Answer the first index associated with the <element>, in the order defined by #do:. If the element is not in the receiver, return the result of evaluating the <exceptionBlock>."

    self keysAndValuesDo:
        [:key :value |
        value = element
            ifTrue: [^key]].
    ^exceptionBlock value!
keys
    "Answer a Set containing all of the keys in the receiver."

    | answer |
    answer := self keyCollectionClass new: self size.
    self keysAndValuesDo:
        [ :key :value |
        answer add: key
        ].
    ^answer    !  
maxHash
    "Private - Answer the maximum expected hash value.  This is used to inhibit growth -- once contents have reached this size it must be bucket-based and no longer may grow."

    ^65535  "0 <= identity hash <= 32767 (VMac only)"!
add: anAssociation
        "Answer anAssociation.  Add anAssociation to the
         receiver."
    self
        at: anAssociation key
        put: anAssociation value.
    ^anAssociation!
associationsDo: iterationBlock
    "Evaluate the <iterationBlock> once for each key/value pair, represented as an Association, in the receiver. If the receiver is empty, the block will not be evaluated."

    self contents keysAndValuesDo:
        [:key :value |
        iterationBlock value:
            (Association key: key value: value)]!  
changeAllocation: newSize
    "Private"
    "Expand or contract the receiver to accomodate at least <newSize> elements."

    | dictionary |
    dictionary := self class new: newSize.
    self keysAndValuesDo:
        [:key :value |
        dictionary privateAt: key put: value for: self].
    self contents: dictionary contents!
computeHash: object
        "Answer the hash value of object."
    ^object basicHash!   
keysAndValuesDo: iterationBlock
    "Evaluate the <iterationBlock> once for each key/value pair in the receiver. The key will be the first argument, the value will be the second argument to the block. If the receiver is empty, the block will not be evaluated."

    self contents keysAndValuesDo: iterationBlock!   
values
        "Answer a non-indexable collection containing all of the values associated
         with some key in the receiver."

    | answer |
    answer := Bag new.
    self do:
        [:element |
        answer add: element].
    ^answer!
keysDo: iterationBlock
    "Evaluate the <iterationBlock> once for each key in the receiver. If the receiver is empty, the block will not be evaluated."

    self contents keysAndValuesDo:
        [:key :value |
        iterationBlock value: key]!  
keyAtValue: anObject ifAbsent: aBlock
        "Answer the key in the receiver whose paired value
         equals anObject.  If not found, evaluate aBlock
         (with no arguments)."
    1 to: contents size by: 2 do: [ :index |
        (contents at: index + 1) = anObject
            ifTrue: [
                (contents at: index) == nil
                    ifFalse: [^contents at: index]]].
    ^aBlock value! 
addAll: aCollection
        "Add each element of aCollection to the receiver,
        returning the collection of elements that were added."
    aCollection isDictionary
        ifTrue: [ aCollection associationsDo: [ :a | self add: a ] ]
        ifFalse: [ aCollection do: [ :o | self add: o ] ].
    ^aCollection! 
associationAt: key ifAbsent: exceptionBlock
        "Answer an Association with the given key whose value is the value associated
        with that key by the receiver. If there is no value associated with the key, answer
        the result of evaluating the exceptionBlock."

	| association |
    ^( association := self contents lookUpKey: key for: self ) isNil
		ifTrue: [ exceptionBlock value]
		ifFalse: [ association] !  
includesKey: key
        "Answer true if the receiver contains aKey,
         else answer false."
    ^ (self contents lookUpKey: key for: self ) notNil!  
removeAll
        "Answer aCollection.  Remove all the elements
         contained in the receiver collection."
    contents atAllPut: nil.
    elementCount := 0.!   
keys
    "Answer a Set containing all of the keys in the receiver."

    | answer |
    answer := self keyCollectionClass new: self size.
    self associationsDo:
        [ :association |
        answer add: association key
        ].
    ^answer ! 
extractKey: object
    "Answer the hash key of <object>."

    ^object key!
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    | firstTime |
    firstTime := true.
    aStream
        nextPutAll: '((';
        nextPutAll: self class name;
        nextPutAll: ' new)'.
    self associationsDo: [ :assoc |
        firstTime
            ifFalse: [aStream nextPut: $;].
        aStream
            cr;
            nextPutAll: 'add: ('.
        assoc storeOn: aStream.
        aStream nextPut: $).
        firstTime := false].
    firstTime
        ifFalse: [aStream nextPut: $; ; cr; nextPutAll: 'yourself'].
    aStream nextPut: $)!
removeAssociation: anAssociation
        "Answer the receiver after anAssociation has been
         removed from it.  If anAssociation is not in the
         receiver, report an error."
    self removeKey: anAssociation key!  
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each element."
    | answer |
    answer := self species new.
    self associationsDo: [:element |
        answer add: element copy].
    ^answer! 
associationAt: aKey
        "Answer the Association whose key equals aKey
         from the receiver.  If not found,
         report an error."

    | association |
    ^( association := self contents lookUpKey: aKey for: self ) isNil
        ifTrue: [ self errorAbsentKey ]
        ifFalse: [ association]!   
at: key ifAbsent: exceptionBlock
        "Answer the value associated with the key. If the index is
        not valid for the receiver, answer the result of evaluating
        the exceptionBlock."

    ^self contents lookUpValue: key for: self ifAbsent: exceptionBlock!
keyCollectionClass
    "Private - answer the class used to collect key values."

    ^Set! 
select: aBlock
        "For each key/value pair in the receiver, evaluate
         aBlock with the value part of the pair as the argument.
         Answer a new object containing those key/value pairs
         for which aBlock evaluates to true."
    | answer |
    answer := self species new.
    self associationsDo: [ :each |
        (aBlock value: each value)
            ifTrue: [answer add: each]].
    ^answer!   
add: anAssociation
        "Add anAssociation to the receiver. Answer anAssociation."
    | element |
    ( element := self contents atKey: anAssociation key put: anAssociation for: self ) == nil
        ifTrue: [self incrementElementCount]
        ifFalse: [element value: anAssociation value].
    ^anAssociation! 
changeAllocation: newSize
    "Private"
    "Expand or contract the receiver to accomodate at least <newSize> elements."

    | dictionary |
    dictionary := self class new: newSize.
    self associationsDo:
        [:association |
        dictionary privateAt: association key put: association for: self].
    self contents: dictionary contents!  
keysAndValuesDo: aBlock
        "For each key in the receiver, evaluate <aBlock> with
         the key as the first argument and the value as the
         second argument."
    self associationsDo: [ :anAssociation |
        aBlock value: anAssociation key value: anAssociation value ]!   
associationsSelect: aBlock
        "For each key/value pair in the receiver, evaluate
         aBlock with the association as the argument.
         Answer a new object containing those key/value pairs
         for which aBlock evaluates to true."
    | answer |
    answer := self species new.
    self associationsDo: [ :each |
        (aBlock value: each)
            ifTrue: [answer add: each]].
    ^answer!
errorAbsentKey
        "Private - Report an error to the effect
         that the desired key was not found in the
         receiver."
    self error: 'Key is missing'!  
keyAtValue: anObject ifAbsent: aBlock
        "Answer the key in the receiver whose paired value
         equals anObject.  If not found, evaluate aBlock
         (with no arguments)."
    self associationsDo: [ :anAssociation |
        anAssociation value = anObject
            ifTrue: [^anAssociation key]].
    ^aBlock value!  
do: aBlock
        "Answer the receiver.  For each value
         in the receiver, evaluate aBlock with
         that value as the argument."
    super do: [ :association |
        aBlock value: association value]!   
at: key put: element
        "Associate the element with the key."

    self add: ( self associationClass key: key value: element ).
    ^element!
compare: key candidate: candidate
    "Answer true if <key> and <candidate> satisfy the comparison test for the receiver."

    ^key = candidate key!  
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    | answer |
    answer := self species new.
    self associationsDo: [:element |
        answer add: element].
    ^answer!
at: aKey ifAbsentPut: valueBlock
        "Answer the value of the key/value pair whose key
         equals aKey from the receiver.  If not found, add a new
         key/value pair where the value is given by evaluating the value block"

     ^self at: aKey ifAbsent: [ self at: aKey put: valueBlock value ]!  
associationsDo: iterationBlock
    "Evaluate the <iterationBlock> once for each key/value pair, represented as an Association, in the receiver. If the receiver is empty, the block will not be evaluated."

    ^self contents elementsDo: iterationBlock!
at: key
        "Answer the value of the key/value pair whose key equals
        key from the receiver.  If  not found, report an error."

    ^self contents lookUpValue: key for: self! 
remove: anObject ifAbsent: aBlock
        "Remove the key/value pair whose value is anObject
         from the receiver dictionary.  This method
         reports an error since the values are
         not unique in a dictionary, the keys are."
    ^self invalidMessage!
keysDo: aBlock
        "Answer the receiver.  For each key
         in the receiver, evaluate aBlock with
         the key as the argument."
    self associationsDo: [ :anAssociation |
        aBlock value: anAssociation key]!   
isDictionary
        "Answer whether the receiver is a Dictionary."
    ^true!  
removeKey: aKey
        "Answer the receiver with the key/value pair whose
         key equals aKey removed.  If such a pair is not found,
         report an error."
    self removeKey: aKey ifAbsent: [self errorAbsentKey]!   
includes: anObject
        "Answer true if the receiver contains the
         key/value pair whose value equals anObject,
         else answer false."
    self do: [ :element |
        element = anObject
            ifTrue: [^true]].
    ^false!  
privateAt: key put: element for: client
    "Private - Associate the <element> with the <key>."

    self contents privateAtKey: key put: element for: client.
    self elementCount: self elementCount + 1.
    ^element!   
associationClass
        "Answer the class of associations used by the receiver."
    ^Association! 
keyAtValue: anObject
        "Answer the key in the receiver whose paired value
         equals anObject.  If not found, answer nil."
    ^self keyAtValue: anObject ifAbsent: [nil]!  
occurrencesOf: anObject
        "Answer the number of key/value pairs in the receiver,
         whose values are equal to anObject."
    | answer |
    answer := 0.
    self do: [ :element |
        element = anObject
            ifTrue:  [answer := answer + 1]].
    ^answer!  
values
        "Answer a Bag containing all the values of the
         key/value pairs in the receiver."
    | answer |
    answer := Bag new.
    self associationsDo: [ :assoc |
        answer add: assoc value].
    ^answer!  
removeKey: key ifAbsent: exceptionBlock
        "Remove the association between the key and any value associated with it from
         the receiver. If the receiver does not associate any value with the key,  answer
        the result of evaluating the exceptionBlock."

    self contents
        removeKey: key
        for: self
        ifAbsent: [ ^exceptionBlock value ].
    self decrementElementCount.
    ^key!
extractKey: object
    "Answer the hash key of <object>."

    ^object!
contents: anArray
        "Private- set the contents of the receiver to anArray."
    contents := anArray!  
grow
    "Private"
    "Expand the receiver to accomodate more elements."

    self changeAllocation: self elementCount * 2!  
pack
    "Optimize space requirements."

    self rehash!  
add: element
    "Add element to the receiver, answering the added element."

    element == nil
        ifTrue: [^element].
    (self contents atKey: element put: element for: self) == nil
        ifTrue: [self incrementElementCount].
    ^element!  
changeAllocation: newSize
    "Private"
    "Expand or contract the receiver to accomodate at least <newSize> elements."

    | aSet |
    aSet := self class new: newSize.
    self do:
        [:element |
        aSet privateAdd: element].
    self contents: aSet contents.
    self elementCount: aSet elementCount! 
computeHash: object
        "Answer the hash value of object."
    ^object hash!
size
        "Answer the number of elements contained
         in the receiver."
    ^elementCount!
initialSize: initialSize
    "Private- Initialize the receiver to be an empty collection with initialSize slots.
     (Note that it will not hold initialSize elements because some amount of free
    space is required for efficient hashing)."

    self elementCount: 0.
    self contents: ( self newContents: initialSize )!  
compare: key candidate: candidate
    "Answer true if <key> and <candidate> satisfy the comparison test for the receiver."

    ^key = candidate!  
do: iterationBlock
    "Evaluate the <iterationBlock> once for each element in the receiver. If the receiver is empty, the block will not be evaluated."

    self contents elementsDo: iterationBlock!
at: anInteger put: anObject
        "Replace the element at index position anInteger
         in the receiver with anObject.  This method
         reports an error since sets are not indexable."
    ^self errorNotIndexable!   
maxLinearSlots
    "Private - Answer the maximum number of slots allowed by a linear representation.  This is approximately equal to the largest LinearHashTable that will be created."

    ^8192!
rehash
    "Private"
    "Rehash the receiver."

    self changeAllocation: self elementCount!
adjustSize
    "Private- If the receiver is getting full, expand it to accomodate more objects."

    (self contents loadFactorExceeded: self elementCount)
        ifTrue: [self grow]!  
at: anInteger
        "Access the element at index position anInteger
         in the receiver.  This method reports
         an error since sets cannot be indexed."
    ^self errorNotIndexable!
decrementElementCount
        "decrement the actual number of elements in the receiver to an integer."
    elementCount := elementCount - 1.!   
elementCount: anInteger
        "Private- Set the actual number of elements in the receiver to an integer."
    elementCount := anInteger.! 
newContents: alloc
    "Private"
    "Answer the collection used to hold the contents of the receiver when the receiver needs <alloc> slots."

    ^alloc > self maxLinearSlots
        ifTrue: [BucketHashTable new: alloc]
        ifFalse: [self bucketClass new: alloc]!
remove: element
ifAbsent: exceptionBlock
    "Remove an element equal to the given <element> from the receiver, answering the element that was removed. If the receiver does not contain an element equal to the element to be removed, return the result of evaluating the <exceptionBlock>."

    self contents
        removeKey: element
        for: self
        ifAbsent: [ ^exceptionBlock value ].
    self decrementElementCount.
    ^element!
incrementElementCount
        "increment the actual number of elements in the receiver to an integer."
    elementCount := elementCount+1.
    self adjustSize.!   
includes: element
    "Answer <true> if the receiver contains an element equal to the <element>."

    ^ (self contents lookUpKey: element for: self) notNil!  
privateAdd: element
    "Private"
    "Add a new <element> to the receiver, assuming that the element is a valid element and that it is not already in the receiver. Return the added element."

    self elementCount: self elementCount + 1.
    self contents privateAtKey: element put: element for: self.
    ^element!
bucketClass
    "Answer the class of hash table buckets the receiver uses."

    ^LinearHashTable! 
occurrencesOf: anObject
        "Answer 1 if the receiver includes anObject as
         one of its elements, else answer zero."
    (self includes: anObject)
        ifTrue: [^1].
    ^0!  
contents
        "Private - Answer an Array containing
         contents of the receiver."
    ^contents!  
elementCount
        "Private-Answer the number of elements in the receiver."
    ^elementCount!
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    | limit |
    (RecursiveSet includes: self)
        ifTrue: [^self printRecursionOn: aStream].
    RecursiveSet add: self.
    limit := aStream position + self printLimit.
    aStream nextPut: $(.
    1 to: self size - 1 do: [ :element |
        (aStream position > limit)
            ifTrue: [
                '...etc...)' printOn: aStream.
                RecursiveSet remove: self ifAbsent: [].
                ^self].
        (self at: element) printOn: aStream.
        aStream space].
    self isEmpty
        ifFalse: [
            self last printOn: aStream].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: []! 
asArray
        "Answer an Array containing all
         the elements of the receiver."
    ^self! 
isArray
        "Answer true if receiver is an instance of class
         Array or one of its subclasses, else answer false."
    ^true!   
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."
    | size index firstTime |
    (RecursiveSet includes: self)
        ifTrue: [
            RecursiveSet := Set new.
            ^self error: 'recursive storeOn: not allowed'].
    RecursiveSet add: self.
    size := self size.
    aStream
        nextPutAll: '((';
        nextPutAll: self class name;
        nextPutAll: ' new: '.
    size printOn: aStream.
    aStream nextPut: $).
    index := 1.
    firstTime := true.
    [index <= size]
        whileTrue: [
            firstTime
                ifFalse: [aStream nextPut: $;].
            firstTime := false.
            aStream nextPutAll: ' at: '.
            index printOn: aStream.
            aStream nextPutAll: ' put: '.
            (self at: index) storeOn: aStream.
            index := index + 1].
    firstTime
        ifFalse: [aStream nextPutAll: '; yourself'].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: [ nil ]!
name
        "Answer a String containing the receiver name."
    | cName aString |
    cName := self instanceClass name.
    aString := String new: cName size + 6.
    cName isDoubleByteString 
        ifTrue: [ aString := DoubleByteString fromString: aString ].
    aString
        replaceFrom: 1
        to: cName size
        with: cName.
    ^aString
        replaceFrom: cName size + 1
        to: cName size + 6
        with: ' class'!   
newNameSymbol: aSymbol
        "Obsolete - Change the name of the receiver to be aSymbol.
        Ignored for MetaClasses."
    self obsoleteMethod!   
instanceClass
        "Private - Answer the instance of the receiver."
    ^instanceClass!  
instanceClass: aClass
        "Private - Set the instance class of the receiver."
    instanceClass := aClass!  
classPool
        "Answer the pool dictionary of
         the only instance (a class) of the
         receiver (a metaclass)."
    ^self instanceClass classPool! 
sharedPools
        "Answer an Array of symbols of pool dictionary
         names referred to by the receiver."
    ^self instanceClass sharedPools!   
subclasses
        "Answer an Array of subclasses of the receiver."
    ^instanceClass isNil
        ifTrue: [ Array new ]
        ifFalse: [ instanceClass subclasses collect: [ :c | c class ] ]!   
classVarNames
        "Answer a Set of the class variable
         names defined in the receiver."
    ^self instanceClass classVarNames!  
subclasses: aCollection
        "Ignored for MetaClass objects."
    self obsoleteMethod!   
symbol
        "Private - Answer the symbol for
         the class name of the receiver."
    ^self instanceClass symbol!  
hash
        "Answer the integer hash value of the receiver."
    ^self instanceClass hash! 
isMetaClass
        "Answer true if receiver is an instance of class
         MetaClass or one of its subclasses, else answer false."
    ^true!   
isBytes
        "Answer true if instances of the receiver contain
         8 bit byte values, else answer false."
    ^self isPointers not!
withAllSubclasses: includeHidden
        "Private - Answer an OrderedCollection of the receiver and
         all of its subclasses in hierarchical order. If includeHidden
         is true, then classes that begin with a blank character are
         included, else they are not."
    | answer |
    answer := OrderedCollection with: self.
    self allSubclasses do: [ :each |
        ( includeHidden or: [ each name first ~= $  ] )
            ifTrue: [ answer add: each ] ].
    ^answer! 
withAllSuperclassesDo: aOneArgumentBlock
        "Evaluate the <aOneArgumentBlock> once for the receiver and any
        superclasses of the receiver."
    ^self withAllSuperclasses do: aOneArgumentBlock!   
printOn: aStream
        "Print the name of the receiver on aStream."
    aStream nextPutAll: self name.!   
basicNew: anInteger
        "Private - Answer an instance of the receiver.
         Allocate anInteger number of indexed instance
         variables.  If the receiver does not have indexed
         instance variables an error is reported.  This
         method should never be reimplemented in any
         subclass of Behavior since it is the primitive
         object allocation message."
    <primitive: 71>
    self isFixed
        ifTrue: [^self errorNotIndexable].
    ^self primitiveFailed!  
instanceVariableString
        "Answer a String containing all the instance variable
         names defined by the receiver.  The names are separated
         with spaces."
    | aStream |
    aStream := WriteStream on: (String new: 16).
    self instVarNames do: [ :each |
        aStream
            space;
            nextPutAll: each ].
    aStream position = 0 ifFalse: [ aStream space ].
    ^aStream contents!   
addSubclass: aClass
        "Add aClass to the subclasses of the receiver.
         Make the receiver the superclass of aClass."
    ( ( self subclasses includes: aClass ) or: [ aClass isBehavior not ] )
        ifTrue: [ ^self ].
    self subclasses: ( self subclasses copyWith: aClass ).
    aClass superclass: self!  
allSubclasses
        "Answer an OrderedCollection of all the subclasses
         of the receiver in hierarchical order.  Classes at
         the same hierarchical level are sorted
         alphabetically."
    | answer sortedSubclasses |
    answer := OrderedCollection new.
    sortedSubclasses := SortedCollection
        sortBlock: Class sortBlock.
    sortedSubclasses addAll: self subclasses.
    sortedSubclasses do: [ :each |
        answer
            add: each;
            addAll: each allSubclasses].
    ^answer!   
superclass: aClass
        "Private - Change the superclass
         of the receiver to aClass."
    superClass := aClass !
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable.  Because
         classes are unique (cannot be copied),
         answer the receiver."
    ^self!   
removeSelector: aSymbol
        "Remove the method named aSymbol from
         the methods defined in the receiver."
    self methodDictionary
        removeKey: aSymbol
        ifAbsent: []!  
isPointers
        "Answer true if instances of the receiver
         contain object pointers instead of 8 bit
         values, else answer false."
    ^( structure bitAnd: InstPointerBit ) ~= 0!   
selectors
        "Answer a Set of symbols of the names
         of the methods defined by the receiver."
    ^self methodDictionary keys! 
isBits
        "Answer true if instances of the receiver contain
         8 bit values instead of object pointers,
         else answer false."
    ^self isPointers not! 
methodDictionary
        "Answer the dictionary of methods
         defined in the receiver."
    ^dictionaryArray at: 1!  
canUnderstand: aSymbol
        "Answer true if the receiver or any of the receiver
         superclasses implement the method named aSymbol, else
         answer false."
    (self methodDictionary includesKey: aSymbol)
        ifTrue: [^true].
    self allSuperclasses
        detect: [ :each | each includesSelector: aSymbol]
        ifNone: [^false].
    ^true!  
compiledMethodAt: aSymbol
        "Answer the compiled code of the method
         named aSymbol defined in the receiver."
    ^self methodDictionary at: aSymbol ifAbsent: [^nil]!
instVarNames
        "Answer the array of instance variable
         names defined by the receiver."
    instances isNil ifTrue: [ ^Array new: 0 ].
    instances isArray ifTrue: [ ^instances ].
    ^instances asArrayOfSubstrings!
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver instance variables.  Because
         classes are unique (cannot be copied),
         answer the receiver."
    ^self! 
methodDictionaries
        "Private - Answer an Array of method
         dictionaries for the receiver."
    ^dictionaryArray! 
isFixed
        "Answer true if instances of the receiver do not
         contain indexed instance variables, else
         answer false."
    ^( structure bitAnd: InstIndexedBit ) = 0! 
isZeroTerminated
        "Answer true if instances of the receiver
         are zero terminated byte objects."
    ^( structure bitAnd: InstZeroTerminatedBit ) ~= 0!  
structure
        "Answer the integer that describes the structure
         of instances of the receiver.  Refer to the
         class variables of Behavior for a definition
         of this integer."
    ^structure! 
structure: anInteger
        "Private - Change the structure that new instances
         of the receiver will have.  The new structure is
         defined by anInteger.  Refer to the class variables
         of Behavior for a description of this integer."
    structure := anInteger!  
includesSelector: aSymbol
        "Answer true if the message dictionary of the
         receiver includes a method of name aSymbol,
         else answer false."
    ^self methodDictionary includesKey: aSymbol!
basicNew
        "Private - Answer an instance of the receiver.  If the
         receiver is indexable, then allocate zero indexed
         instance variables.  This method should never be
         reimplemented in any subclass of Behavior since it
         is the primitive object allocation message."
    <primitive: 70>
    self isVariable
        ifTrue: [^self basicNew: 0].
    ^self primitiveFailed!   
computeInstSize
        "Private - Compute the number of named instance variables
         for instances of the receiver and adjust the receiver
         structure instance variable accordingly.  The number is
         based on the instances array and the instance variables
         defined by the receiver superclass."
    | size |
    size := self superclass isNil
        ifTrue: [ 0 ]
        ifFalse: [ self superclass instSize ].
    self structure: self structure - self instSize + size + self instVarNames size!
classVariableString
        "Answer a String of all the class variable names
         defined by the receiver.  The names are separated
         with blanks."
     | answer |
     answer := String new.
    self classVarNames asSortedCollection do: [ :each |
        answer := answer ,  ' ', each ].
    answer isEmpty ifFalse: [ answer := answer, ' ' ].
     ^answer!  
errorNotIndexable
        "Private - When trying to make an instance of the
         receiver with indexed instance variables and the
         receiver is not indexable,  produce a walkback."
    ^self error:
        self name, 's do not have indexed instance variables'!  
inheritsFrom: aClass
        "Answer true if receiver can inherit methods
         from aClass, else answer false."
    | class |
    class := self.
    [class == nil] whileFalse: [
        (class == aClass)
            ifTrue: [^true].
        class := class superclass].
    ^false! 
instSize
        "Answer the number of named instance variables
         contained in instances of the receiver."
    ^self isPointers
        ifFalse: [0]
        ifTrue: [structure bitAnd: InstNumberMask]!  
allClassVarNamesGrouped
        "Answer an ordered collection of all instance and class
        variable names grouped per class and separated by
        class name."
    | answer names |
    answer := self classVarNames asSortedCollection asOrderedCollection.
    answer notEmpty
        ifTrue: [
            answer := ( Array with: ( ' -- ', self name, ' class --' ) ),
                answer].
    self allSuperclasses do: [ :each |
        ( names := each classVarNames asSortedCollection ) notEmpty
            ifTrue: [
                answer := answer,
                    (Array with: (' -- ', each name, ' class --')),
                    names ] ].
    ^answer!  
allSuperclasses
        "Answer an OrderedCollection of all the superclasses
         of the receiver.  The superclasses are in inverse
         hierarchical order, i.e class Object is last."
    | answer superclass |
    answer := OrderedCollection new.
    ( superclass := self superclass ) notNil ifTrue: [
        answer add: superclass.
        answer addAll: superclass allSuperclasses ].
    ^answer!  
methodDictionaries: anArray
        "Private - Change the receiver's array of
         method dictionaries to anArray."
    anArray isArray
        ifFalse: [^self error: 'must be an Array'].
    dictionaryArray := anArray!  
pools
        "Private - Answer an OrderedCollection of pool dictionaries
         for the receiver, including both the class variables
         and the pool dictionaries."
    | pools |
    pools := OrderedCollection with:  self classPool.
    pools 
        addAll: ( self allSuperclasses collect:
                [ :c | c classPool ] );
        addAll: ( self sharedPools collect: 
            [ :pool | Smalltalk at: pool
                ifAbsent: [ ^self error: 'Pool Dictionary ', pool, ' undefined.' ]
            ] ).
    ^pools!
allClasses
        "Answer a Set of all of the classes
         contained in Smalltalk."
    | answer |
    answer := Set new.
    Smalltalk associationsDo: [ :each |
        (each value isBehavior)
            ifTrue: [
                (each value name first = $ )
                    ifFalse: [answer add: each value]]].
    ^answer! 
removeSubclass: aClass
        "Private - Remove aClass as a
         subclass of the receiver."
    self subclasses:
        (self subclasses asSet
            remove: aClass
                ifAbsent: [];
            yourself)!   
kindOfSubclass
        "Private - Answer a string describing the receiver type.
         The choices are: 'subclass:', 'variableSubclass:',
         and 'variableByteSubclass:'."
    self isFixed    ifTrue:[^'subclass:'].
    self isBytes    ifTrue:[^'variableByteSubclass:'].
    self isPointers ifTrue:[^'variableSubclass:'].
    self error: 'unknown kind of class'!   
withAllSuperclasses
        "Answer a collection containing the receiver and any superclasses
        of the receiver."
    | answer |
    answer := OrderedCollection with: self.
    self allSuperclasses do: [ :each |
        answer add: each ].
    ^answer! 
addSelector: aSymbol withMethod: aCompiledMethod
        "Add aCompiledMethod to the receiver messageDictionary
         using aSymbol as the key.  If aSymbol is not
         a Symbol report an error."
    Symbol mustBeSymbol: aSymbol.
    self methodDictionary
        at: aSymbol put: aCompiledMethod! 
allInstVarNames
        "Answer an Array of strings of all of the instance
         variable names defined in the receiver and
         its superclasses."
    | answer |
    answer := self instVarNames.
    self allSuperclasses do: [ :each |
        answer := each instVarNames , answer].
    ^answer! 
allInstVarNamesGrouped
        "Answer an Array of strings of all of the instance
         variable names defined in the receiver and
         its superclasses, grouped by class."
    | list names |
    self instSize = 0 ifTrue: [^Array new].
    list := self instVarNames asSortedCollection asArray.
    self allSuperclasses do: [ :each |
        ( names := each instVarNames asSortedCollection ) notEmpty
            ifTrue: [
                list := list,
                    (Array with: (' -- ', each name, ' --')),
                    names]].
    ^list! 
superclass
        "Answer the superclass of the receiver."
    ^superClass!
withAllSubclassesDo: aOneArgumentBlock
        "Evaluate aOneArgumentBlock with the receiver and
        each of the receiver's nested subclasses as an argument
        in turn."
    ^self withAllSubclasses do: aOneArgumentBlock! 
isVariable
        "Answer true if instances of the receiver contain
         indexed instance variables, else answer false."
    ^self isFixed not!   
new
        "Answer an instance of the receiver.  If the receiver is
         indexable, then allocate zero indexed instance
         variables.  This method is frequently reimplemented
         as a class message in classes that need special
         initialization of their instances."
    <primitive: 70>
    self isVariable ifTrue: [ ^self new: 0 ].
    ^self primitiveFailed!  
new: anInteger
        "Answer an instance of the receiver.  Allocate anInteger
         number of indexed instance variables.  If the receiver
         does not have indexed instance variables an error is
         reported.  This method is frequently reimplemented
         as a class message in classes that need special
         initialization of their instances."
    <primitive: 71>
    self isFixed ifTrue: [ ^self errorNotIndexable ].
    ^self primitiveFailed! 
allInstancesPrim
        "Private - Answer an Array of all of
         the instances of the receiver."
    <primitive: 38>
    self primitiveFailed!  
sharedVariableString
        "Private - Answer a String containing
         all of the pool dictionary names
         referred to by the receiver.  The
         names are separated with blanks."
    | aStream |
    aStream := WriteStream on: (String new: 16).
    self sharedPools asSortedCollection do: [ :each |
        aStream
            space;
            nextPutAll: each ].
    aStream position = 0 ifFalse: [ aStream space ].
    ^aStream contents!  
isBehavior
        "Answer true if receiver is an instance of class
         Behavior or one of its subclasses, else answer false."
    ^true! 
setInstVarNames: aCollection
        "Private - Change the instance variables of the receiver to
        <aCollection>.  Perform no error checking.  Recompute the
        number of named instance variables for instances of the
        receiver and instances of all the subclasses of the receiver."
    instances := aCollection isEmpty
        ifTrue: [ nil ]
        ifFalse: [ String fromArrayOfSubstrings: aCollection asArray separatedBy: $ ].
    self computeInstSize.
    self allSubclasses do: [ :c | c computeInstSize ]!   
withAllSubclasses
        "Answer an OrderedCollection of the receiver and
         all of its subclasses in hierarchical order."
    ^self withAllSubclasses: false!  
allClassVarNames
        "Answer a Set of strings of all of the class
         variable names defined in the receiver and
         its superclasses."
    | answer |
    answer := self classVarNames.
    self allSuperclasses do: [:each |
        answer addAll: each classVarNames].
    ^answer! 
allInstances
        "Answer an Array of all of
         the instances of the receiver."
    | int answer |
    int := Process enableInterrupts: false.
    Smalltalk unusedMemory.
    answer := self allInstancesPrim.
    Process enableInterrupts: int.
    ^answer!  
allInstAndClassVarNamesGrouped
        "Answer an ordered collection of all instance and class
        variable names grouped by class and separated by
        class name."
    ^self allInstVarNamesGrouped, self allClassVarNamesGrouped.! 
from: beginningInteger to: endInteger
        "Answer an Interval from beginningInteger to
         endInteger incrementing by one."
    ^self basicNew
        initBegin: beginningInteger
        end: endInteger
        incr: 1!
from: beginningInteger
    to: endInteger
    by: incrementInteger
        "Answer an Interval from beginningInteger to
         endInteger incrementing by incrementInteger."
    ^self basicNew
        initBegin: beginningInteger
        end: endInteger
        incr: incrementInteger! 
with: firstObject with: secondObject
        "Answer a collection of two elements,
         firstObject and secondObject."
    | answer |
    answer := self new: 2.
    answer at: 1 put: firstObject.
    answer at: 2 put: secondObject.
    ^answer!   
with: firstObject with: secondObject with: thirdObject
        "Answer a collection of three elements,
         firstObject, secondObject, and thirdObject."
    | answer |
    answer := self new: 3.
    answer at: 1 put: firstObject.
    answer at: 2 put: secondObject.
    answer at: 3 put: thirdObject.
    ^answer! 
with: firstObject
    with: secondObject
    with: thirdObject
    with: fourthObject
        "Answer a collection of four elements, firstObject,
         secondObject, thirdObject, and fourthObject."
    | answer |
    answer := self new: 4.
    answer at: 1 put: firstObject.
    answer at: 2 put: secondObject.
    answer at: 3 put: thirdObject.
    answer at: 4 put: fourthObject.
    ^answer! 
with: anObject
        "Answer a collection with only
         one element, anObject."
    | answer |
    answer := self new: 1.
    answer at: 1 put: anObject.
    ^answer!   
withAll: collection
    "Answer an instance of the receiver containing the same elements as the given <collection>."

    | instance index |
    instance := self new: collection size.
    index := 1.
    collection do: [:each |
        instance at: index put: each.
        index := index + 1].
    ^instance!
with: firstObject with: secondObject
        "Answer a collection of two elements,
         firstObject and secondObject."
    ^self new
        add: firstObject;
        add: secondObject;
        yourself! 
with: firstObject with: secondObject with: thirdObject
        "Answer a collection of three elements,
         firstObject, secondObject, and thirdObject."
    ^self new
        add: firstObject;
        add: secondObject;
        add: thirdObject;
        yourself!
with: firstObject
    with: secondObject
    with: thirdObject
    with: fourthObject
        "Answer a collection of four elements, firstObject,
         secondObject, thirdObject, and fourthObject."
    ^self new
        add: firstObject;
        add: secondObject;
        add: thirdObject;
        add: fourthObject;
        yourself! 
with: anObject
        "Answer a collection with only
         one element, anObject."
    ^self new
        add: anObject;
        yourself!
name
        "Answer a String containing the receiver name."
    ^name asString!
newNameSymbol: aSymbol
        "Private - Change the name of
         the receiver to be aSymbol."
    Symbol mustBeSymbol: aSymbol.
    name := aSymbol! 
instanceClass
        "Private - Answer the receiver."
    ^self!   
setSharedPools: aCollection
        "Private - Change the shared pool dictionaries to be <aCollection>.
        Perform no error checking"
    aCollection isEmpty
        ifTrue: [ sharedPools := nil ]
        ifFalse: [
            sharedPools := aCollection asSet asArray collect: [ :poolName |
                poolName asSymbol ] ]!
isClass
        "Answer true if receiver is an instance of class
         Class or one of its subclasses, else answer false."
    ^true!   
removeFromSystem
        "Remove the receiver from Smalltalk.  Report
         an error if there are any subclasses or
         instances of the receiver."
    ^self removeFromSystem: true! 
setClassVarNames: aCollection
        "Private - Change the class variables defined to be <aCollection>.  Perform
        no error checking."
    classPool isNil ifTrue: [ classPool := Dictionary new ].
    classPool keys do: [ :oldKey |
        ( aCollection includes: oldKey )
            ifFalse: [ classPool removeKey: oldKey ] ].
    aCollection do: [ :newKey |
        ( classPool includesKey: newKey )
            ifFalse: [ classPool at: newKey put: nil ] ].
    classPool isEmpty ifTrue: [ classPool := nil ].! 
classPool
        "Answer the dictionary containing the class
         variables defined in the receiver."
    classPool isNil ifTrue: [ ^Dictionary new ].
    ^classPool!   
sharedPools
        "Answer a collection of symbols of pool dictionary
         names referred to by the receiver."
    sharedPools isNil ifTrue: [ ^Array new ].
    ^sharedPools asSet! 
subclasses
        "Answer an Array of subclasses of the receiver."
    ^subclasses isNil
        ifTrue: [ Array new ]
        ifFalse: [
            Smalltalk isRunTime
                ifTrue: [ subclasses select: [ :s | s notNil ] ]  "skip nil dev classes"
                ifFalse: [ subclasses ] ]! 
classVarNames
        "Answer a Set of class variable
         names defined in the receiver."
    ^self classPool keys!   
subclasses: aCollection
        "Private - Change the subclasses of the receiver
         to be the classes in aCollection."
    aCollection isEmpty
        ifTrue: [subclasses := nil]
        ifFalse:[subclasses := aCollection asArray]!
symbol
        "Private - Answer the symbol for
         the class name of the receiver."
    ^name!   
hash
        "Answer the integer hash value of the receiver."
    ^name hash!   
initializeClass
        "Private - Initialize the instance
         variables of the receiver to describe
         a default class with no methods or instance
         variables."
    dictionaryArray :=
        Array with: ( ( MethodDictionary new:2 ) classField: self ).
    self structure: (self superclass == nil
        ifTrue: [Object structure]
        ifFalse:[
            dictionaryArray := dictionaryArray
                , self superclass methodDictionaries.
            self superclass structure]).
    instances := nil! 
newFile: aString
    "Answer a FileStream for the file named 
         aString in the receiver directory.  If the file 
         exists, it will be removed and a new file 
         will be created."

    | file |
    file := self fileNamed: aString.
    file exists
        ifTrue: [file remove].
    file create.
    ^file writeStream!   
finalize
	"If the receiver in not referenced by any object in the system and it has asked to receive this message so it can do final clean up.  Do it now.  Default is do nothing."! 
propertyAt: aPropertyName
	"Answer the value of the receiver's property identified by <aPropertyName> or nil if none."

	^self propertyTable at: aPropertyName ifAbsent: [nil]!
propertyTable
	"Private - answer the property table for the receiver, which maps property names to values."

	^SystemWeakRegistries current properties at: self ifAbsent: [ IdentityDictionary new ]!  
synchronize
        "Make the external volume represented by the receiver consistent
        with the changes that have been made to its contents."!
bindOnceSpaceType
	"Private - Answer the type for a space that
	is just bound once."

	^1!
platformExtension
	"Private - answer a String indicating the current platform."

	^String with: self platformLetter!   
versionAndPlatformExtension
	"Private - answer a String indicating the current version and platform."

	^self versionExtension, self platformExtension!
constructEventsTriggered
        "Private - answer all the events which can be triggered
         by instances of the receiver. "
    ^super constructEventsTriggered
        add: #aboutToUnbind ;
        add: #unbind ;
        yourself!
platformLetter
	"Private - Answer a letter indicating the platform"

	^Smalltalk platform first asLowerCase!   
sourceFileExtension
	"Answer the default file name extension for source files."

	^'.sml'! 
formatVersionRoot
	"Private - Answer the root of the format version string."

	^'VOL1000'! 
new
		"Answer a new instance of the receiver."
	^super new initialize!  
fileExtension
	"Answer the default file name extension for library files."

	^'.sll'!  
versionExtension
    "Private - answer a String indicating the current version."

    ^'31'!   
formatVersion
	"Private - Answer the format version string."

	^self formatVersionRoot, ( String with: self platformLetter )!  
bindManySpaceType
	"Private - Answer the type for a space that
	can be bound repeatedly."

	^0!   
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."

	| s |
	s := name.
    s size = 0 ifTrue: [ s := self fileName ].
    s size = 0 ifTrue: [ s := 'nil' ].
    aStream nextPutAll: self class name, '(', s, ')'.!  
referenceCount
	"Private - Answer the reference count for the receiver."

	^metaInfo at: 'refCount' ifAbsent: [ 0 ].!  
uses
    "Private - Answer the Set of libraries used by the receiver."

    ^metaInfo at: 'uses' ifAbsentPut: [ Set new ].!
releaseEventTable
    "Private"
    "Break all connections to eventTable."

    eventTable := nil!
integralSource
	"Answer true if source code is in the receiver, false
	if separate."

	^metaInfo at: 'integralSource' ifAbsent: [ true ].!
formatVersion: aString
	"Private - Set the formatVersion of the receiver."

	self metaInfo at: 'formatVersion' put: aString!   
formatVersion
	"Answer et the formatVersion of the receiver."

	^self metaInfo at: 'formatVersion'!
root
    "Answer the root object."

    ^root! 
version
	"Answer the receiver's version."

	^version!  
version: aString
	"Set the receiver's version."

	version := aString.
	self metaInfo at: 'version' put: aString.! 
initialize
	"Private - Initialize the receiver."

	metaInfo := Dictionary new.!
sourceBase
	"Answer the file position for the receiver's source code."

	^metaInfo at: 'sourceBase' ifAbsent: [ nil ]! 
objects
	"Answer the receiver's objects."

	^objects!  
objects: anObject
	"Private - Set the objects for the receiver.
	This is used by the binder and builder classes."

	objects := anObject!  
prevMethods
        "Answer a collection of the previous methods which are
        overridden by the receiver."

    ^root at: 'PrevMethods' ifAbsent: [ nil ]!   
file: anObject
	"Set the receiver's physical location."

	file := anObject!
decrementReferenceCount
	"Private - Decrease the reference count for the receiver."

	metaInfo at: 'refCount' put: ( self referenceCount - 1 )!
fileName: aString
	"Private - Set the file name for the receiver."

	file := File fromPath: aString!   
incrementReferenceCount
	"Private - Bump the reference count for the receiver."

	metaInfo at: 'refCount' put: ( self referenceCount + 1 )!
name
	"Answer the receiver's name."

	^name isNil ifTrue: [ self fileName ] ifFalse: [ name ]! 
name: aName
	"Set the receiver's name."

	name := aName!   
shapes
	"Answer the class shapes for the receiver."

	^self metaInfo at: 'shapes' ifAbsent: [ nil ].!  
file
	"Answer the receiver's physical location."

	^file!  
fileName
	"Answer the file name of the receiver's file, without
	any path or extension."

	self file isNil ifTrue: [ ^nil ].
	^( FileSystemPath fromString: self file pathName ) entityName fileName!
root: anObject
    "Set the root object."

    root := anObject!   
metaInfo
	"Answer the receiver's meta information."

	^metaInfo!   
eventTableForEdit
    "Private"
    "Answer a Dictionary mapping event names to actions,
    allocate it if necessary."

    eventTable == nil
        ifTrue: [eventTable := self eventTableCreate].
    ^eventTable! 
sourceReference
	"Answer a StreamReference for the receiver's source code."

	^metaInfo at: 'sourceReference' ifAbsent: [ nil ]!   
description
	"Answer the description for the receiver."

	^self metaInfo at: 'description' ifAbsent: [ nil ].! 
description: aString
	"Set the description for the receiver."

	self metaInfo at: 'description' put: aString!  
contents
	"Answer a dictionary describing the contents of the receiver."

	^self metaInfo at: 'contents' ifAbsent: [ nil ].!   
eventTable
    "Private"
    "Answer a Dictionary mapping event names to actions
    for the receiver."

    ^eventTable == nil
        ifTrue: [self eventTableCreate]
        ifFalse: [eventTable]! 
isFraction
        "Answer true if receiver is a kind of Fraction."
    ^false! 
notifier
	"Private - Answer the notifier WeakRegistry."

	^notifier!   
initialize
    "Private - Initialize class inst vars."

    finalizer := WeakRegistry new action: [:object | object finalize ].
    externalResources := WeakRegistry new action: [:object | object finalize ].
    properties := WeakKeyedRegistry new.
    events := WeakKeyedRegistry new.
    notifier :=
        WeakKeyedRegistry new
            action: [:assoc |
                ( assoc notNil and: [ assoc value notNil ] ) ifTrue: [
                    assoc value do: [:each | each finalize: assoc key ].
                    assoc value: nil ] ].!  
properties
	"Private - Answer the properties WeakRegistry."

	^properties! 
exit
	"Private - Process the externalResources registry.
	This should be preceded by a gc compact."

	externalResources do: [:object | object aboutToExitSession ].!  
finalizer
	"Answer the simple finalization WeakRegistry."

	^finalizer!
events
	"Private - Answer the events WeakRegistry."

	^events! 
startUp
	"Private - Process the externalResources registry.
	This should be preceded by a gc compact."

	externalResources do: [:object | object startingSession ].!  
aboutToSaveImage
	"Private - Process the externalResources registry.
	This should be preceded by a gc compact."

	externalResources do: [:object | object aboutToSaveImage ].!
externalResources
	"Answer the externalResources WeakRegistry."

	^externalResources!  
do: aBlock
    "Evaluate <aBlock> with each object of the receiver as its argument."

    [self ephemerons keysDo: aBlock]
        evaluateWithoutInterrupts! 
action
    "Answer the action that is evaluated when an object managed by the receiver is finalized."

    ^action!
notEmpty
        "Answer whether the receiver contains one or more elements."
    ^self ephemerons notEmpty!
action: anEvaluableAction
    "Set the action that is evaluated when an object managed by the receiver is finalized.
	The action takes one argument which for a WeakRegistry is the object being finalized
	and for a WeakKeyedRegistry is an Association where the key is the object being
	finalized."

    action := anEvaluableAction!  
mayBeFinalized: anObject
    "Private - Answer true if <anObject> is finalizable."

    anObject isSmallInteger
        ifTrue: [^false].
    (nil == anObject or: [true == anObject or: [false == anObject]])
        ifTrue: [^false].
    ^true!
actionArg: anEphemeron
	"Private - Answer the argument to the receiver's action."
	
	^anEphemeron key
!   
initialize
    "Private - Initialize the receiver."

    super initialize.
    (ephemerons := EphemeronDictionary new) manager: self! 
isEmpty
        "Answer whether the receiver contains no elements."
    ^self ephemerons isEmpty!   
remove: anObject
    "Remove <anObject> from the registry."

    ^self remove: anObject ifAbsent: []!  
add: anObject
    "Add <anObject> to the receiver."

    [ self ephemerons at: anObject put: nil ]
        evaluateWithoutInterrupts.
	^anObject!
remove: anObject ifAbsent: aBlock
    "Remove <anObject> from the registry."

    ^[self ephemerons removeKey: anObject ifAbsent: aBlock]
        evaluateWithoutInterrupts!  
size
        "Answer the number of elements contained in the receiver."
    ^self ephemerons size!  
ephemerons
    "Private - answer the EphemeronDictionary."

    ^ephemerons!   
includes: anObject
    "Answer true if the receiver includes <anObject>, else false."

    ^self ephemerons includesKey: anObject! 
rescue: anEphemeron
    "Private - The object that is the key of <anEphemeron> is no longer referenced.  Remove it from the registry and evaluate its action (which may cause it to be added again)."

    | object extension evaluableAction args |
    object := anEphemeron key.
    extension := anEphemeron value.
    self remove: object.
    evaluableAction := self action.
    evaluableAction == nil ifTrue: [^self].
    args := Array with: ( self actionArg: anEphemeron ).
    evaluableAction evaluateWithArguments: args.
    evaluableAction isContext
        ifTrue:
            [args at: 1 put: nil.
            evaluableAction evaluateWithArguments: args].
    args := nil!  
atKey: key
put: element
for: client
	"Associate <key> with <element> if <key> is not already present.  Answer nil if <element> was added, otherwise answer the existing object. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

	| index object |
	index := self findKeyIndex: key for: client.
	^(object := self at: index) == nil
		ifTrue:
			[self at: index put: element.
			nil]
		ifFalse:
			[object]!   
lookUpValue: key for: client ifAbsent: exceptionBlock
    "Answer the value associated with <key> if it is present in the receiver, otherwise the result of <exceptionBlock>l. The <client> is responsible for computing hash values."

    | assoc |
    assoc := self at: (self findKeyIndex: key for: client).
    ^assoc == nil
        ifTrue: [exceptionBlock value]
        ifFalse: [assoc value]! 
privateAtKey: key
put: element
for: client
	"Add a new <element> to the receiver, assuming that the element is a valid element and that it is not already in the receiver. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

	self at: (self findKeyIndex: key for: client) put: element! 
removeKey: element for: client ifAbsent: exceptionBlock
        "Remove an element equal to the given element from the receiver.
        If the receiver does not contain an element equal to the element to
        be removed, return the result of evaluating the exceptionBlock.
        The client is responsible for computing hash values, extracting the key
        of an element, and comparing candidates."

    | lastIndex testIndex testObject searchIndex |
    testIndex := self findKeyIndex: element for: client.
    ( self at: testIndex ) == nil
        ifTrue: [ ^exceptionBlock value ].
    self at: testIndex put: nil.
    lastIndex := self size.
    [ ( testIndex := testIndex + 1 ) > lastIndex
        ifTrue: [ testIndex := 1 ].
    ( testObject := self at: testIndex ) == nil ]
        whileFalse:
            [ "test next object for relocation"
            searchIndex := self findKeyIndex: ( client extractKey: testObject ) for: client.
            ( self at: searchIndex ) == nil
                ifTrue:
                    [ "found object to move "
                    self at: searchIndex put: testObject.
                    self at: testIndex put: nil
                    ]
            ]!   
lookUpValue: key for: client
    "Answer the value associated with <key>, or signal an error if not present. The <client> is responsible for computing hash values."

    | assoc |
    assoc := self at: (self findKeyIndex: key for: client).
    ^assoc == nil
        ifTrue: [client errorAbsentKey]
        ifFalse: [assoc value]!  
privateAtSlot: slot
putKey: key
element: element
	"Private"

	self at: slot put: element!
keysAndValuesDo: iterationBlock
	"Evaluate the <iterationBlock> once for each key/value pair in the receiver. The key will be the first argument, the value will be the second argument to the block. If the receiver is empty, the block will not be evaluated."

	| value |
	1 to: self size
		do:
			[:index |
			(value := self at: index) == nil
				ifFalse: [iterationBlock value: value key value: value value]]! 
loadFactorExceeded: count
		"Answer true if (count / self size) exceeds a fixed load factor."	
		"Implementation note: this forumla is related to the one in other implementors of the 				message, and in Set>>allocationForSize:."

	^(count * 100) >= (self size * 75)!
count
	"Answer the number of elements in the receiver."

	^self
		inject: 0
		into:
			[:n :x |
			x == nil
				ifTrue: [n]
				ifFalse: [n + 1]]!   
lookUpKey: element for: client
    "Answer <element> if it is present in the receiver, otherwise nil. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    ^ self at: (  self findKeyIndex: element for: client )! 
privateAtKey: key
putValue: value
for: client
	"Private - Add a new <value> to the receiver at <key>."

	self at: (self findKeyIndex: key for: client) put: ( client associationClass key: key value: value )!   
elementsDo: iterationBlock
	"Evaluate the <iterationBlock> once for each element in the receiver. If the receiver is empty, the block will not be evaluated."

	| value |
	1 to: self size
		do:
			[:index |
			(value := self at: index) == nil
				ifFalse: [iterationBlock value: value]]!
findKeyIndex: element for: client
    "Private"
    	"Answer the index position of an element in the receiver or the first empty
	 	element position. The client is responsible for computing hash values, 
		extracting the key of an element, and comparing candidates."
    | index indexedObject lastIndex |
    lastIndex := self size.
    index := (client computeHash: element) \\ lastIndex + 1.
    [(indexedObject := self at: index) == nil
            or: [client compare: element candidate: indexedObject]]
        whileFalse:
            [(index := index + 1) > lastIndex
                ifTrue: [index := 1]].
    ^index! 
copyFrom: bucket
for: client
    "Private - copy the contents of bucket to the receiver.
    Answer the number of elements copied."

    | count |
    count := 0.
    bucket
        elementsDo:
            [:each |
            count := count + 1.
            self
                    privateAtKey: (client extractKey: each)
                    put: each
                    for: client].
    ^ count!   
at: anObject put: aValue
    "Add <anObject> to the receiver."

    ^[self ephemerons at: anObject put: aValue]
        evaluateWithoutInterrupts!
at: anObject ifAbsent: aBlock
    "Answer the value associated with <anObject> if one exists, otherwise answer the value of <aBlock>."

    ^[self ephemerons at: anObject ifAbsent: aBlock]
        evaluateWithoutInterrupts!   
actionArg: anEphemeron
	"Private - Answer the argument to the receiver's action."
	
	^anEphemeron
!   
at: anObject ifAbsentPut: aBlock
    "Answer an value associated with <anObject>. If not found, add <anObject>
	whose value is given by the result of evaluating <aBlock>."

    ^[self ephemerons at: anObject ifAbsentPut: aBlock]
        evaluateWithoutInterrupts!  
associationsDo: aBlock
    "Evaluate <aBlock> with each association of the receiver as its argument."

    [self ephemerons associationsDo: aBlock]
        evaluateWithoutInterrupts!
removeKey: anObject ifAbsent: aBlock
    "Remove <anObject> from the registry if it exists, otherwise evaluate <aBlock>."

    ^self remove: anObject ifAbsent: aBlock!
at: anInteger put: aNumber
        "Replace the number in the receiver indexed by
         anInteger with the argument aNumber.  This message is
         not valid for intervals since interval collections
         are implicitly defined (the elements are computed)."
    ^self invalidMessage! 
+ amount
        "Answer a new Interval whose elements are
         the original ones plus amount."
    ^beginning + amount
        to: end + amount
        by: increment!  
species
        "Answer class Array as the species
         of Interval."
    ^Array!  
- amount
        "Answer a new Interval whose elements are
         the original ones minus amount."
    ^beginning - amount
        to: end - amount
        by: increment! 
at: anInteger
        "Answer the number at index position
         anInteger in the receiver interval."
    | answer |
    anInteger > 0
        ifTrue: [
            answer := beginning + (increment * (anInteger - 1)).
            (increment < 0
                and: [answer between: end and: beginning])
                    ifTrue: [^answer].
            (increment > 0
                and: [answer between: beginning and: end])
                    ifTrue: [^answer]].
    ^self errorInBounds: anInteger!  
initBegin: beginningInteger
    end: endInteger
    incr: incrementInteger
        "Private - Answer the receiver after initializing
         the beginning, end and increment instance variables."
    beginning := beginningInteger.
    end := endInteger.
    increment := incrementInteger.
    increment = 0
        ifTrue: [^self error: 'interval increment is 0']! 
reversed
        "Answer a new object containing the
        elements of the receiver in reverse order."
    ^self class
        from: end
        to: beginning
        by: increment negated! 
size
        "Answer the number of elements of the receiver."
    ^0 max: end - beginning // increment + 1! 
increment
        "Answer the increment of the receiver Interval."
    ^increment!  
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver elements."
    ^self objectShallowCopy!  
size
    "Answer the size of the receiver."

	^self fileId == nil
		ifTrue: [self directory fileSizeForFileNamed: self name]
		ifFalse: [self fileId endByte].!  
setEndOfFile: handle
    <api: SetEndOfFile ulong boolean>
    ^self invalidArgument!   
isDigit: aCharacter
        "Answer true if aCharacter is a digit, else answer false."
    | anInteger |
    anInteger := aCharacter asInteger.
    ( anInteger > 0 and: [ anInteger < 256 ] )
        ifTrue: [ ^( isDigit at: anInteger ) asBoolean ].
    ^false!
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^false!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
eventsTriggered
        "Answer all the events which can be triggered
        by instances of the receiver."
    eventsTriggered isNil ifTrue: [ self initializeEventsTriggered ].
    ^eventsTriggered!  
eventsTriggered: aCollection
        "Private - specify all the events which can be triggered
        by instances of the receiver."
    eventsTriggered := aCollection!   
initializeEventsTriggered
        "Private - initialize all the events which can be triggered
        by instances of the receiver."
    self eventsTriggered: self constructEventsTriggered!  
dateFormatDMY
        "Private - answer the constant used to represent Day/Month/Year
        date format."
    ^1!
smallestNegative
        "Answer the smallest (negative) integer value that can be
        represented as a SmallInteger."
    ^(-1 bitShift: 30 )!
largestPositive
        "Answer the largest (positive) integer value that can be
        represented as a SmallInteger."
    ^( 1 bitShift: 30 ) - 1!  
readFrom: aStream
        "Read an integer from <aStream> and return it"
    | value char |
    value := 0.
    [ ( char := aStream peek ) ~~ nil and: [ char isDigit ] ]
        whileTrue: [
            value := value * 10 + char digitValue.
            aStream next ].
    char == $r
        ifFalse: [ ^value ].
    aStream next. "skip the r"
    ^self readFrom: aStream radix: value! 
readFrom: aStream radix: radix
        "Private - Read an integer from <aStream> and return it"
    | value char |
    value := 0.
    [ ( char := aStream peek ) ~~ nil and: [ char isDigit or: [ char isUpperCase ] ] ]
        whileTrue: [
            radix <  char digitValue
                ifTrue: [ ^value ].
            value := value * radix + char  digitValue.
            aStream next ].
    ^value!  
initialize
		"Private - initialize the class variable SinValues."
	SinValues :=  #(
		0 2 3 5 7 9 10 12 14 16 17 19 21 23 24 26 28
		29 31 33 34 36 37 39 41 42 44 45 47 48 50 52
		53 54 56 57 59 60 62 63 64 66 67 68 69 71 72
		73 74 75 77 78 79 80 81 82 83 84 85 86 87 87
		88 89 90 91 91 92 93 93 94 95 95 96 96 97 97
		97 98 98 98 99 99 99 99 100 100 100 100 100 100
	)! 
new
        "Answer an instance of the receiver.
         This method reports an error."
    ^self invalidMessage! 
new: anInteger
        "Answer an instance of the receiver.
         This method reports an error."
    ^self invalidMessage!  
additiveIdentity
        "Answer the additive identity element for instances of the
        receiver: the number which, when added to any other number
        yields the other number."
    ^0!  
fromString: aString
        "Answer aString as a number."
    |  specialChar s num denom arrayOfSpecialChar decimalSep |
    decimalSep := NationalLanguage decimalSeparator first.
    arrayOfSpecialChar := (Array with: decimalSep), #( $/ $e $E).
    specialChar := (aString
        detect: [ :c | arrayOfSpecialChar includes: c]
        ifNone: [nil]).
    specialChar isNil
        ifTrue: [^aString asInteger].
    (specialChar = $/)
        ifTrue: [
            s := ReadStream on: aString.
            num := s upTo: $/.
            denom := s upTo: nil.
            ^num asInteger / denom asInteger
            ].
    ^aString asFloat!
multiplicativeIdentity
        "Answer the multiplicative identity element for instances of
        the receiver: the number which, when multiplied by any other
        number yields the other number."
    ^1! 
= aNumber
        "Answer true if the receiver is equal
         to aNumber, else answer false."
    <primitive: 27>
    ^aNumber = self! 
bitAnd: anInteger
        "Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    <primitive: 34>
    ^anInteger bitAnd: self! 
+ aNumber
        "Answer the sum of the receiver and aNumber."
    <primitive: 21>
    ^aNumber + self!   
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    | value divisor |
    (value := self) < 0
        ifTrue: [
            aStream nextPut: $-.
            value := 0 - self].
    divisor := 10.
    [divisor > value]
        whileFalse: [divisor := divisor * 10].
    [(divisor := divisor // 10) > 1]
        whileTrue: [
            aStream nextPut:
                (Character digitValue: value // divisor).
            value := value \\ divisor].
    aStream nextPut: (Character digitValue: value)! 
\\ aNumber
        "After dividing the receiver by aNumber
        with truncation towards negative infinity,
        answer the integer remainder."
    <primitive: 31>
    aNumber == 0
        ifTrue: [^self zeroDivisor].
    aNumber isLargeInteger
        ifTrue: [
            ( aNumber positive == self positive )
                ifTrue: [ ^self ] ].
    ^super \\ aNumber!  
> aNumber
        "Answer true if the receiver is greater
         than aNumber, else answer false."
    <primitive: 24>
    ^aNumber < self! 
>= aNumber
        "Answer true if the receiver is greater than
         or equal to aNumber, else answer false."
    <primitive: 26>
    ^aNumber <= self!   
byteSize
    "Private - Answer the number of bytes required for
     LargeInteger format."
    | value |
    value := self abs.
    value < 256 ifTrue: [ ^1 ].
    value < 65536 ifTrue: [ ^2].
    value < 16777216 ifTrue: [ ^3].
    ^4!  
& anInteger
        "Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    <primitive: 34>
    ^anInteger & self.!
bitShift: anInteger
        "Answer an integer which is the
         receiver shifted left anInteger
         number of bit positions if anInteger
         is positive, or shifted right for
         anInteger negated number of bit
         positions if anInteger is negative."
    <primitive: 37>
    ^super bitShift: anInteger!  
| anInteger
        "Answer an Integer representing the receiver bits ORed with
        the argument anInteger."
    <primitive: 35>
    ^anInteger | self!   
printString
        "Answer the ASCII representation
         of the receiver to aStream."
    | value digits i |
    (value := self) < 0
        ifTrue: [ ^'-', ( 0 - self ) printString ].

    digits := String new: 12.
    i := digits size.
    [ value >= 10 ] whileTrue: [
        digits at: i put: ( Character digitValue: ( value \\ 10 ) ).
        i := i  - 1.
        value := value // 10].
    digits at: i put: ( Character digitValue: ( value \\ 10 ) ).
    ^ digits copyFrom: i to: digits size.!
- aNumber
        "Answer the difference between
         the receiver and aNumber."
    <primitive: 22>
    ^( aNumber - self ) negated! 
absoluteLessThan: aNumber
    "Private - LargeInteger arithmetic support.
     Answer true if the absolute value of
      self is less than the absolute value of aNumber."
    ( aNumber isLargeInteger and: [self > -16r40000000 ] )
        ifTrue: [ ^true ].
    ^super absoluteLessThan: aNumber! 
reduce
        "Private - Answer the receiver in its smallest integer representation."
    ^self!   
quo: aNumber
        "Answer the integer quotient of the receiver
         divided by aNumber with truncation toward zero."
    <primitive: 33>
    aNumber = 0 ifTrue: [ ^self zeroDivisor ].
    ( aNumber isInteger and: [ self absoluteLessThan: aNumber ] )
        ifTrue: [ ^ 0 ]
        ifFalse: [ ^( self / aNumber ) truncated ].!  
at: index put: anObject
        "SmallIntegers have no contents.
         This method reports an error."
    ^self invalidMessage! 
highBit
    "Private - Answer the position of the most significant
     non-zero bit in the receiver.  Used by LargeInteger
     divide."
    self < 0
        ifTrue: [ ^self error: 'Negative number invalid.' ].

    self < 128 ifTrue: [
        " ^( (0 to: 127) collect: [:i| i highBit ] ) at: self + 1 "
         ^ #(0 1 2 2 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7)
            at: self + 1 ].

    self < 256 ifTrue: [ ^8 ].

    ^self highDigit highBit + ( ( self byteSize - 1 ) * 8 )!   
at: index
        "Private - Answer the index'th byte of the receiver."
    <primitive: 12>
    index <= 0
    ifTrue: [ self error: 'byteAt: index must be greater than zero' ].

    ^( self abs bitShift: 1 - index * 8 ) bitAnd: 16rFF.!
bitOr: anInteger
        "Answer an Integer representing the receiver
         bits ORed with the argument anInteger."
    <primitive: 35>
    ^anInteger bitOr: self!
~= aNumber
        "Answer true if the receiver is not
         equal to aNumber, else answer false."
    <primitive: 28>
    ^aNumber ~= self!   
rem: aNumber
        "Answer the integer remainder after dividing
         the receiver by aNumber with truncation
         towards zero."
    <primitive: 20>
    aNumber = 0 ifTrue: [ ^self zeroDivisor ].
    ^self - ( ( self quo: aNumber ) * aNumber )!  
// aNumber
        "Answer the quotient of dividing the receiver by
        aNumber with truncation towards negative infinity."
    | answer quotient |
    <primitive: 32>
    aNumber == 0 ifTrue: [ ^self zeroDivisor ].
    aNumber isInteger ifTrue: [
        self = 0  |  ( self positive = aNumber positive )
            ifTrue: [ ^ 0 ]
            ifFalse: [ ^-1 ] ].

    quotient := self / aNumber.
    answer := quotient truncated.
    ( ( quotient < 0 ) and: [ quotient ~= answer ] )
        ifTrue:  [ ^answer - 1 ]
        ifFalse: [ ^answer ].  !
bitXor: anInteger
        "Answer the receiver bit XORed
        with the argument anInteger."
    <primitive: 36>
    ^anInteger bitXor: self!   
isSmallInteger
        "Answer true if receiver is a kind of SmallInteger."
    ^true!  
< aNumber
        "Answer true if the receiver is less
         than aNumber, else answer false."
    <primitive: 23>
    ^aNumber > self!
<= aNumber
        "Answer true if the receiver is less than
         or equal to aNumber, else answer false."
    <primitive: 25>
    ^aNumber >= self!  
absAt: index
        "Private - Answer the index'th byte of the absolute value
         of the receiver."
    index <= 0
        ifTrue: [ self error: 'byteAt: index must be greater than zero' ].
    ^( self abs bitShift: 1 - index * 8 ) bitAnd: 16rFF.!
* aNumber
        "Answer the result of multiplying
         the receiver by aNumber."
    <primitive: 29>
    ^aNumber * self!   
bitAt: anInteger
        "Answer 0 if the bit at index position anInteger
         in the receiver is 0, else answer 1."
    1 > anInteger
        ifTrue: [ self error: 'bitAt: index must be greater than zero' ].
    ^self >= 0
        ifTrue: [ 1 bitAnd: ( self bitShift: 1 - anInteger ) ]
        ifFalse: [ 1 - ( 1 bitAnd: ( self bitInvert bitShift: 1 - anInteger ) ) ]!  
thousandsSeparator
        "Answer the current system value
        for the thousands separator."
    thousandsSeparator isNil
        ifTrue: [ thousandsSeparator := self queryNationalProfileString: 'sThousand' default: ',' ].
    ^thousandsSeparator! 
asMixedFileStream: leadBytes
        " Make the receiver a character-oriented MixedFileStream
        which interprets mixed string encodings using the specified
        leadBytes flag array.  Answer the receiver. "
    | mixedStream |
    mixedStream := MixedFileStream new.
    1 to: self class instSize do: [ :i |
        mixedStream instVarAt: i put: ( self instVarAt: i ) ].
    mixedStream leadBytes: leadBytes.
    self become: mixedStream.
    ^mixedStream!   
getCommandLineString
        "Answer the command line as a single string."
    | address |
    address := ExternalAddress fromInteger: KernelLibrary getCommandLine.
    ^String fromAddress: address!
dateFormatMDY
        "Private - answer the constant used to represent Month/Day/Year
        date format."
    ^0!
lineDelimiter
        "Answer the default line delimiter, carriage-return."
    ^Cr!
sizeInBytes
	^32!
inspectorFields
        "Answer the names of structure fields contained in the receiver."
    ^self inspectorClass fields: #(
        #dwLength
        #dwMemoryLoad
        #dwTotalPhys
        #dwAvailPhys
        #dwTotalPageFile
        #dwAvailPageFile
        #dwTotalVirtual
        #dwAvailVirtual )!
atAddress: anExternalAddress
        "Answer a new instance of the receiver whose
         bytes are at the address identified by anExternalAddress."
    | answer |
    answer := super new.
    answer contents: anExternalAddress.
    ^answer.! 
fromAddress: anAddress
        "Answer an instance of the receiver with appropriate
         byte size and fill its contents from data at anAddress."
    | result |
    ( result := self new: self sizeInBytes )
        fillFromAddress: anAddress.
    ^result!  
new
        "Answer a new instance of the receiver
         with the size taken from the receiver."
    ^self new: self sizeInBytes!   
new: anInteger
        "Answer a new instance of the receiver with
         size anInteger bytes."
    ^self basicNew initialSize: anInteger!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^0!   
usingBytes: aByteObject
        "Answer a new instance of the receiver using aByteObject
         as its contents."
    | answer |
    answer := self new.
    answer contents: aByteObject.
    ^answer.!  
fromInteger: anInteger
        "Private - Answer a new Instance of the receiver
         with value anInteger."
    ^self new
        longAtOffset: 0 put: anInteger;
        yourself!  
fromBytes: aByteObject
        "Answer a new instance of the receiver with contents copied
         from aByteObject."
    | answer |
    answer := self new: aByteObject size.
    answer contents
        replaceFrom: 1
        to: aByteObject size
        with: aByteObject
        startingAt: 1.
    ^answer.!  
dwAvailVirtual
    ^self uLongAtOffset: 28!  
dwTotalVirtual
    ^self uLongAtOffset: 24!  
dwMemoryLoad
    ^self uLongAtOffset: 4! 
dwAvailPageFile
    ^self uLongAtOffset: 20! 
dwTotalPageFile
    ^self uLongAtOffset: 16! 
dwAvailPhys
    ^self uLongAtOffset: 12! 
dwLength
    ^self uLongAtOffset: 0! 
dwTotalPhys
    ^self uLongAtOffset: 8!  
shortAtOffset: anInteger
        "Answer a signed short integer (16 bits) at anInteger in the
         receiver.  Offsets are zero relative."
    | answer |
    <primitive: 18>
    answer := self uShortAtOffset: anInteger.
    answer > 32767 ifTrue: [ answer := answer - 65536 ].
    ^answer!   
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host system procedure call."
    ^contents asParameter!   
uLongAtOffset: anInteger
        "Answer the double word (32 bits) at anInteger in the receiver.
         Offsets are zero relative."
    | total off |
    <primitive: 78>
    off := anInteger + 1.
    total := 0.
    3 to: 0 by: -1 do: [ :i |
        total := ( total bitShift: 8 ) + ( self contents at: off + i ) ].
    ^total!
contents: aByteArray
        "Set the contents of the receiver to aByteArray."
    contents :=  aByteArray! 
copyToAddress: anAddress
        "Copy the bytes of the receiver to
         host memory at anAddress."
    anAddress replaceFrom: 1
        to: contents size
        with: contents
        startingAt: 1!
byteAtOffset: anInteger put: anObject
        "Store anObject at anInteger in the receiver.
         Offsets are zero relative."
    ^self contents at: anInteger + 1 put: anObject!   
handleAtOffset: anInteger put: anExternalHandle
        "Store anExternalHandle at anInteger in the receiver.
         Offsets are zero relative."
    ^contents replaceFrom: (anInteger + 1)
        to: (anInteger + anExternalHandle size)
        with: anExternalHandle
        startingAt: 1! 
longAtOffset: anInteger put: anObject
        "Store anObject at anInteger in the receiver.
         Offsets are zero relative."
    | off low high |
    <primitive: 99>
    ( anObject between: -2147483648 and: 2147483647 )
        ifFalse: [ ^self error: 'anObject must be between -2147483648  and +2147483647' ].
    low := anObject bitAnd: 16rFFFF.
    high := anObject bitShift: -16.
    off := anInteger + 1.
    self contents at: off put: ( low bitAnd: 16rFF ).
    self contents at: off + 1 put: ( low bitShift: -8 ).
    self contents at: off + 2 put: ( high bitAnd: 16rFF ).
    self contents at: off + 3 put: ( ( high bitShift: -8 ) bitAnd: 16rFF ).
    ^anObject!  
bitXor: anInteger
        "Answer an Integer representing the receiver
         bits XORed with the argument anInteger."
    | result size dig1 dig2 dig3 carry1 carry2 carry3 comp2 comp3 |
    anInteger isInteger
        ifFalse: [ ^anInteger bitAnd: self ].

    size := self byteSize max: anInteger byteSize.
    carry1 := 1.
    anInteger positive
        ifTrue:  [
            carry2 :=0.
            comp2 := 0.
            carry3 := 1.
            comp3 := 16rFF.
            result  := self class new: size.]
        ifFalse: [
            carry2 := 1.
            comp2 := 16rFF.
            carry3 := 0.
            comp3 := 0.
            result  := self class negativeClass new: size.].

    1 to: size do:
        [ :index |
        dig1 := ((self absAt: index) bitXor: 16rFF) + carry1.
        dig2 := ((anInteger absAt: index) bitXor: comp2) + carry2.
        dig3 := ((dig1 bitXor: dig2) bitXor: comp3) + carry3.
        result at: index put: ( dig3 bitAnd: 16rFF).
        dig1 = 256 ifFalse: [ carry1 := 0.].
        dig2 = 256 ifFalse: [ carry2 := 0.].
        dig3 = 256 ifFalse: [ carry3 := 0.].
        ].
    carry3 ~= 0
        ifTrue: [
            result := (self class new: (size + 1))
                 replaceFrom: 1 to: size with: result startingAt: 1.
            result at: size+1 put: carry3].
    ^result reduce!   
bitAnd: anInteger
        "Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    | result size dig1 dig2 dig3 carry1 carry2 carry3 comp2 comp3 |
    anInteger isInteger
        ifFalse: [ ^anInteger bitAnd: self ].

    size := self byteSize max: anInteger byteSize.
    carry1 := 1.
    anInteger positive
        ifTrue:  [
            carry2 := 0.
            comp2 := 0.
            carry3 := 0.
            comp3 := 0.
            result := self class negativeClass new: size.
            ]
        ifFalse: [
            carry2 :=1.
            comp2 := 16rFF.
            carry3 :=1.
            comp3 := 16rFF.
            result := self class new: size.
            ].

    1 to: size do:
        [ :index |
        dig1 := ((self absAt: index ) bitXor: 16rFF) + carry1.
        dig2 := ((anInteger absAt: index ) bitXor: comp2) + carry2.
        dig3 := ((dig1 bitAnd: dig2) bitXor: comp3) + carry3.
        result at: index put: ( dig3 bitAnd: 16rFF ).
        dig1 = 256 ifFalse: [ carry1 := 0.].
        dig2 = 256 ifFalse: [ carry2 := 0.].
        dig3 = 256 ifFalse: [ carry3 := 0.].
        ].
    carry3 ~= 0
        ifTrue: [
            result := (self class new: (size + 1))
                 replaceFrom: 1 to: size with: result startingAt: 1.
            result at: size+1 put: carry3].
    ^result reduce.!  
sign
        "Answer -1 because the receiver is less than zero"
    ^-1!
printOn: aStream
        "Append a text representation of the receiver to aStream."
    aStream nextPut: $-.
    self negated printOn: aStream!
\\ divisor
        "After dividing the receiver by divisor
        with truncation towards negative infinity,
        answer the integer remainder."
    | answer |

    divisor = 0 ifTrue: [ ^ self zeroDivisor ].
    ( divisor isFloat )       ifTrue:  [ ^ self asFloat \\ divisor ].
    ( divisor isFraction )  ifTrue:  [ ^ super \\ divisor ].
    ( divisor isInteger )    ifFalse: [ ^ self error: 'can''t divide' ].

    divisor negative
    ifTrue:
        [
        self > divisor  ifTrue: [ ^ self ].
        ^ ( ( self primitiveDiv: divisor type: self class negativeClass ) at: 2 )
        ].

   ( self absoluteLessThan: divisor )
        ifTrue: [ ^ divisor + ( ( self primitiveDiv: divisor type: self class ) at: 2 ) ].
    answer := (self primitiveDiv: divisor type: self class) at: 2.
    answer = 0
        ifTrue: [ ^answer]
        ifFalse:[ ^ divisor + answer ].!  
< aNumber
        "Answer true if the receiver is less
         than aNumber, else answer false."
    aNumber isInteger
        ifFalse: [ ^( aNumber > self ) ].

    aNumber positive
        ifTrue: [ ^true ].

    ^aNumber absoluteLessThan: self.!
<= aNumber
        "Answer true if the receiver is less than
         or equal to aNumber, else answer false."
    aNumber isInteger
        ifFalse: [ ^( aNumber >= self ) ].

    aNumber positive
        ifTrue: [ ^true ].

    ^( self absoluteLessThan: aNumber ) not.!  
bitOr: anInteger
        "Answer an Integer representing the receiver
         bits ANDed with the argument anInteger."
    | result size dig1 dig2 dig3 carry1 carry2 carry3 comp2 |
    anInteger isInteger
        ifFalse: [ ^anInteger bitAnd: self ].

    size := self byteSize max: anInteger byteSize.
    result := self class new: size.

    carry1 := 1.
    anInteger positive
        ifTrue:  [
            carry2 := 0.
            comp2 := 0.
            ]
        ifFalse: [
            carry2 :=1.
            comp2 := 16rFF.
            ].
    carry3 := 1.

    1 to: size do:
        [ :index |
        dig1 := ((self absAt: index ) bitXor: 16rFF) + carry1.
        dig2 := ((anInteger absAt: index ) bitXor: comp2) + carry2.
        dig3 := ((dig1 bitOr: dig2 ) bitXor: 16rFF) + carry3.
        result at: index put: ( dig3 bitAnd: 16rFF ).
        dig1 = 256 ifFalse: [ carry1 := 0.].
        dig2 = 256 ifFalse: [ carry2 := 0.].
        dig3 = 256 ifFalse: [ carry3 := 0.].
        ].
    carry3 ~= 0
        ifTrue: [
            result := (self class new: (size + 1))
                 replaceFrom: 1 to: size with: result startingAt: 1.
            result at: size+1 put: carry3].
    ^result reduce.! 
negated
        "Answer the negative value of the receiver."
    ^self copyInto: ( LargePositiveInteger new: self size ).!  
negative
        "Answer true because the receiver is less
         than zero."
    ^true! 
positive
        "Answer false because the receiver is less
         than zero."
    ^false!   
reduce
        "Answer self, but as a SmallInteger if possible"
    | result smallInt factor |
    result := super reduce.        " trash leading zeros "

    ( result size > 4 )
         ifTrue: [ ^result ].

    ( ( result at: 4 ) = 64 )
        ifTrue:
            [
            "All values of result are Large except
              for < 0 0 0 64 > which is Small for
              negative numbers, large for positive."
            ( (self at: 1) = 0 and: [
              (self at: 2) = 0 and: [
              (self at: 3) = 0 ]] )
                ifTrue: [ ^-1073741823 - 1 ]
                ifFalse: [ ^result ].
            ].

    smallInt := 0.
    factor := 1.
    1 to: result size do:
        [ : index |
        smallInt := smallInt - ( ( result at: index ) * factor ).
        factor := factor * 256.
        ].

    ^smallInt.!   
strictlyPositive
        "Answer true if the receiver is
         greater than zero, else answer false."
    ^false!   
abs
        "Answer the absolute value of the receiver."
    ^self negated.!
asUnsigned
        "Answer self as a 32-bit unsigned number; assumes
        the receiver is a 32-bit quantity."
     ^self + 4294967296.     " ( 2 raisedToInteger: 32 ) "!   
addressAtOffset: anInteger
        "Answer the bytes starting at anInteger (0 based offset)
        as anExternalAddress."
    | bytes |
    bytes := self bytesAtOffset: anInteger count: ExternalAddress sizeInBytes.
    ^ExternalAddress usingBytes: bytes!  
booleanAtOffset: anInteger
        "Answer the boolean (true if non zero) at anInteger in the receiver.
         Offsets are zero relative."
    ^( self uShortAtOffset: anInteger ) ~= 0
        ifTrue: [ true ]
        ifFalse: [ false ]!   
isValid
        "Answer whether the receiver is valid (accessible)."
    ^self isInExternalMemory not or: [ self contents isValid ]!
releaseContents
        "Free the resources associated with the receiver."
    self isInExternalMemory ifTrue: [ self contents release ]!   
uShortAtOffset: anInteger put: anObject
        "Store a word, anObject, at anInteger in the receiver.
         Offsets are zero relative."
    | off |
    <primitive: 89>
    off := anInteger + 1.
    self contents at: off put: ( anObject bitAnd: 16rFF ).
    self contents at: off + 1 put: ( ( anObject bitShift: -8 ) bitAnd: 16rFF ).
    ^anObject!   
size
        "Answer the size in bytes of the structure contents."
    ^contents size!  
bytesAtOffset: anInteger count: anInteger2
        "Answer a ByteArray with anInteger2 bytes copied
         from the receiver starting at anInteger.
         Offsets are zero relative."
    ^self contents copyFrom: (anInteger + 1) to: (anInteger + anInteger2)! 
bytesAtOffset: anInteger put: aByteObject
        "Store aByteObject at anInteger in the receiver.
         Offsets are zero relative."
    ^self contents replaceFrom: (anInteger + 1)
        to: (anInteger + aByteObject size)
        with: aByteObject
        startingAt: 1! 
initialSize: anInteger
        "Private - initialize the contents instance variable to
        an appropriately sized ByteArray."
    self contents: ( ByteArray new: anInteger )! 
floatAtOffset: anInteger put: aFloat
        "Store the 8-byte floating point value at offset <anInteger> in the receiver.
        Offsets are zero relative."
    self bytesAtOffset: anInteger put: aFloat!  
byteAtOffset: anInteger
        "Answer the byte at anInteger in the receiver. Offsets
         are zero relative."
    ^self contents at: anInteger + 1!  
longAtOffset: anInteger
        "Answer the signed double word (32 bits) at
         anInteger in the receiver. Offsets are zero relative."
    | off total |
    <primitive: 59>
    off := anInteger + 1.
    total := 0.
    ( contents at: off + 3 ) >= 16r80
        ifTrue: [   "negative"
            3 to: 0 by: -1 do: [ :i |
                total := ( total bitShift: 8 ) + ( ( contents at: off + i ) bitXor: 16rFF ) ].
            total := ( total + 1 ) negated ]
        ifFalse: [
            3 to: 0 by: -1 do: [ :i |
            total := ( total bitShift: 8 ) + ( contents at: off + i ) ] ].
    ^total! 
fillFromAddress: anAddress
        "Fill the receiver by copying bytes from
         host memory at anAddress."
    contents replaceFrom: 1
        to: contents size
        with: anAddress
        startingAt: 1!
shortAtOffset: anInteger put: anInteger2
        "Store anInteger2 at anInteger in the receiver.
         Offsets are zero relative."
    <primitive: 88>
    (anInteger2 between: -32768 and: 32767)
        ifFalse: [^self error: 'anInteger2 must be between -32768 and +32767'].
    ^self uShortAtOffset: anInteger put: anInteger2!  
uLongAtOffset: anInteger put: anObject
        "Store anObject at anInteger in the receiver.
         Offsets are zero relative."
    | off low high |
    <primitive: 126>
    low := anObject bitAnd: 16rFFFF.
    high := anObject bitShift: -16.
    off := anInteger + 1.
    self contents at: off put: ( low bitAnd: 16rFF ).
    self contents at: off + 1 put: ( low bitShift: -8 ).
    self contents at: off + 2 put: ( high bitAnd: 16rFF ).
    self contents at: off + 3 put: ( ( high bitShift: -8 ) bitAnd: 16rFF ).
    ^anObject!   
isInExternalMemory
		"Answer whether the receiver's contents stored in external memory."
	^self contents isExternalAddress! 
handleAtOffset: anInteger
        "Answer an ExternalHandle from the receiver starting at anInteger.
         Offsets are zero relative."
    ^ExternalHandle fromBytes: ( self bytesAtOffset: anInteger count: 4 )!   
addressAtOffset: anInteger put: anExternalAddress
        "Set the bytes starting at anInteger (0 based offset)
        from the contents of anExternalAddress."
    self bytesAtOffset: anInteger put: anExternalAddress contents!
booleanAtOffset: anInteger put: aBoolean
        "Set the value at anInteger in the receiver to aBoolean.
         Offsets are zero relative."
    self uShortAtOffset: anInteger put: aBoolean asParameter!   
uShortAtOffset: anInteger
        "Answer the word (16 bits) at anInteger in the receiver.
         Offsets are zero relative."
    | off |
    <primitive: 19>
    off := anInteger + 1.
    ^( self contents at: off ) + ( ( self contents at: off + 1 ) bitShift: 8 )!   
contents
        "Answer the contents of the receiver."
    ^contents!  
floatAtOffset: anInteger
        "Answer the 8-byte floating point value at offset <anInteger> in the receiver.
        Offsets are zero relative."
    | aFloat |
    aFloat := Float new.
    aFloat replaceFrom: 1
        to: aFloat size
        with: self contents
        startingAt: anInteger + 1.
    ^aFloat!
eventsTriggered
        "Answer all the events which can be triggered
        by instances of the receiver."
    ^self constructEventsTriggered!   
isBlockClosure
	"Answer whether the receiver is a BlockClosure."

	^false! 
asExternalGlobalAddress
        "Answer the receiver as an ExternalGlobalAddress."
    ^ExternalGlobalAddress fromBytes: self!  
fromLocator: aFileSystemLocator
	"Private - private instance creation method used primarily by FileSystemLocators to create instances of the appropriate FileSystemEntity subclass."
 
	| new |
	new := self new.
	new fileSystemLocator: aFileSystemLocator asFileSystemLocator.
	^new

!
fromPath: path in: parentDirectory
    "Answer an instance of a subclass of the receiver representing an entity with the given path. If the path is an absolute path, the parent directory is ignored. If the path is a relative path the path name is assumed to be relative to the parentDirectory."

	self implementedBySubclass!   
fromPath: path 
    "Answer an instance of a subclass of the receiver representing an entity with the given path."

	self implementedBySubclass!   
osError: aSystemErrorCode
	"Signal the HostFileSystemError exception with <aSystemErrorCode>."

	^HostFileSystemError signalWith: aSystemErrorCode!
moveFile: oldFile as: newName
    "Private - Move <oldFile> and anything it contains to the receiver, renaming it to <newName>."

    self implementedBySubclass!  
entitiesDo: iterationBlock
	"Evaluate the <iterationBlock> once for each entity contained within the receiver. Each entity passed to the iteration block should be released by the iteration block if it is not retained in some way.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated entities."

	self implementedBySubclass!   
removeAll
    "Remove the receiver and anything it contains from the file system."

    self removeContents.
    self remove! 
entityNamesDo: iterationBlock
    "Evaluate the <iterationBlock> once with the name of each entity contained within the receiver.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated entities."

    | entityName |
	self
        entitiesDo:
            [:entity |
			entityName := entity name.
			entity release.
            iterationBlock value: entityName]
!
isEmpty
	"Answer <true> if the receiver does not contain any entities."

	self
		entitiesDo:
			[:entity |
			entity release.
			^false].
	^true! 
copyDirectory: oldDirectory as: newName
    "Private - Copy <oldDirectory> and anything it contains to the receiver, renaming it to <newName>."

    self implementedBySubclass!   
isContainerEntity
    "Answer <true> if the receiver is a file system container."

	^true! 
copyFile: oldFile as: newName
    "Private - Copy <oldFile> and anything it contains to the receiver, renaming it to <newName>."

    self implementedBySubclass!  
hasEntityNamed: entityName
    "Answer <true> if the receiver contains an entity named <entityName>."

    | searchResult |
    [ searchResult := self findFirst: entityName.
        searchResult notNil
            ifTrue: [ ^true ]
            ifFalse: [ ^false ] ]
        ensure: [ searchResult isNil ifFalse: [ self endSearch: searchResult ] ]!   
entities
	"Answer a collection of the entities contained within the receiver."

	| entities |
	entities := OrderedCollection new.
	self
		entitiesDo:
			[:entity |
			entities add: entity].
	^entities!
entityNames
    "Answer a collection of the names of the entities contained within the receiver."

    | names |
    names := OrderedCollection new.
    self
        entityNamesDo:
            [:name |
            names add: name].
    ^names!  
moveDirectory: oldDirectory as: newName
    "Private - Move <oldDirectory> and anything it contains to the receiver, renaming it to <newName>."

    self implementedBySubclass!   
existingEntityNamed: entityName
    "Answer the file system entity representing the entity named <entityName> contained within the receiver. Answer <nil> if the name does not define an existing entity within the receiver."

    ^self
        existingEntityNamed: entityName
        ifAbsent: [nil]!   
existingEntityNamed: entityName
ifAbsent: exceptionBlock
    "Answer the file system entity representing the entity named <entityName> contained within the receiver. If the name does not define an existing entity within the receiver, answer the result of evaluating the <exceptionBlock>."

    | realName |
    realName := entityName.
    self
        entitiesDo:
            [:entity |
            entity name = realName
                ifTrue: [^entity]
				ifFalse: [entity release]].
    ^exceptionBlock value
!  
removeContents
    "Remove anything contained in the receiver from the file system."

    self entities
        do:
            [:fileSystemEntity |
            fileSystemEntity isContainerEntity
                ifTrue: [fileSystemEntity removeAll]
                ifFalse: [fileSystemEntity remove].
            fileSystemEntity release]!  
directory
    "Answer the Directory in which the receiver is contained."

    ^self fileSystemLocator parentPath asDirectory!  
= aFileSystemComponent
    "Answer <true> if the receiver and <anObject> are equal. Two objects are equal if they have the same behavior at the current point in time. Objects that are equal at one time may not be equal at some later time.
        Invariants:
        -    Two objects that compare equal must have equal hash values."

    self implementedBySubclass!
asFileSystemPath
    "Answer a path that will resolve to the same entity as the receiver."

    ^self asFileSystemLocator asFileSystemPath!
remove
    "Remove the receiver from the file system."

    self implementedBySubclass!
permissionViolation
    "An attempt has been made to access the receiver in a way that is not allowed for the current user. Signal a FileSystemPermissionViolation error."

    FileError
        signal: 'Insufficient permissions'
        with: self! 
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    super printOn: aStream.
    aStream nextPutAll: ' on: '.
    self fileSystemLocator printOn: aStream.!   
isComponentEntity
    "Answer <true> if the receiver is a file system component."

    ^false! 
pathRelativeTo: targetContainer
    "Answer the path of the receiver relative to the given <directory>, or the absolute path of the receiver if there is no relative path."

    | absolutePath relativePath |
    absolutePath := self absolutePath.
    relativePath := absolutePath relativeTo: targetContainer absolutePath.
    relativePath == nil
        ifTrue: [^absolutePath].
    ^relativePath!  
fileSystemLocator
	"Answer the fileSystemLocator that was used to create the receiver."

	^fileSystemLocator!  
fileSystemLocator: aFileSystemLocator
    "Answer the FileSystemLocator that was used to create the receiver."

    fileSystemLocator := aFileSystemLocator!   
hash
    "Answer an integer hash value for the receiver.
        Invariants:
        -    The hash value of an object must be constant over time.
        -    Two objects that compare equal must have equal hash values.
        Implementation Comments:
        -    The standard implementation is to return the result of sending the message #basicHash to the receiver."

    self implementedBySubclass! 
moveTo: targetContainer
    "Move the receiver and anything it contains to the <targetContainer>."

    self moveTo: targetContainer as: self name!
isContainerEntity
    "Answer <true> if the receiver is a file system container."

    ^false! 
cannotBeCreated
    "An attempt to create the receiver has failed. Signal a FileError."

    FileError
        signal: 'Cannot be created'
        with: self!   
create
    "Create the entity represented by the receiver."

    self implementedBySubclass!   
name
    "Answer the name of the receiver."

	^self fileSystemLocator entityName!  
renameAs: newName
    "Change the name of the receiver to be the <newName>."

   	self copyTo: self directory as: newName.
    self remove.
	self fileSystemLocator: self fileSystemLocator parentPath , newName!
lastAccessTime
    "Answer the TimeStamp of the date and time at which the receiver was last accessed. If the last access time cannot be obtained from the file system, answer the result of sending the message #lastModificationTime to the receiver."

    ^self lastModificationTime!  
exists
    "Answer <true> if the receiver represents an existing component on the file system."

	self implementedBySubclass!  
doesNotExist
    "An attempt to use the receiver has failed because the referenced entity does not exist. Signal a FileError."

    FileError
        signal: self asFileSystemPath asString , ' does not exist'
        with: self! 
asFileSystemLocator
    "Answer a file system locator that will resolve to the same entity as the receiver."

	^self fileSystemLocator!
creationTime
    "Answer the date and time (as a TimeStamp) at which the receiver was created."

    self implementedBySubclass!   
osError: aSystemErrorCode
	"Signal the HostOSError exception with <aSystemErrorCode>."

	^self class osError: aSystemErrorCode!
lastModificationTime
    "Answer a TimeStamp of the date and time at which the receiver was last modified."

    self implementedBySubclass!   
copyTo: targetContainer
as: newName
    "Copy the receiver and anything it contains to the <targetContainer>, renaming it to the <newName>."

    self implementedBySubclass! 
copyTo: targetContainer
    "Copy the receiver and anything it contains to the <targetContainer>."

    self copyTo: targetContainer as: self name!
moveTo: targetContainer
as: newName
    "Move the receiver and anything it contains to the <targetContainer>, renaming it to the <newName>."

    self implementedBySubclass! 
absolutePath
	"Answer the absolute path to the receiver."

	^self fileSystemLocator absolutePath!  
isVolume
    "Answer <true> if the receiver is a volume."

    ^false! 
at: aSymbol put: anObject
        "Answer anObject.  Enter anObject at key aSymbol in the receiver.
        Ensure that aSymbol is a symbol."

    | old |
    Symbol mustBeSymbol: aSymbol.
    ( old := self at: aSymbol ifAbsent: [ nil ] ) isClass
        ifTrue:
            [ anObject == old
                ifTrue: [ ^self ]
                ifFalse: 
					[ old symbol == aSymbol
						ifTrue: [ ^self error: 'Cannot assign to a class' ] ] ].
    ^super at: aSymbol put: anObject!   
attributesForFileNamed: fileName
        "Answer the attributes of the file named in <fileName>."

    self searchResultsDo:
        [:searchResult |
            (searchResult entityName equalsIgnoreCase: fileName)
                ifTrue: [^searchResult fileAttributes] ].
    ^nil! 
setDate: anArray
    "Set the time and date of the receiver file to anArray (in DOS format)."

    | wasOpen |
    wasOpen := self isOpen.
    [wasOpen
            ifFalse: [self open].
        (WinFileTime fromDosDateTime: anArray) toFile: self]
        ensure:
            [wasOpen
                ifFalse: [self close]]! 
fromInteger: anInteger
        "Private - Answer a new Instance of the receiver
         with value anInteger."
    ^self new uShortAtOffset: 0 put: anInteger; yourself!  
new
    "Answer a new instance of the receiver."

    ^super new initialize!   
eventTable
        "Private - answer a Dictionary mapping event names to actions
        for the receiver."
    ^EventHandlers
        at: self
        ifAbsent: [self eventTableCreate]!   
new: anInteger
        "Answer a new instance of the receiver whose size is at least <anInteger>."
    ^( super new: anInteger )
        makeWeakArray: true;
        yourself!   
COMMENT
"Instances of WeakLinearHashTable are used as the internal representation of WeakSets and the SymbolSet.  WeakLinearHashTables refer to all of their contained objects weakly, i.e. the weak linear hash table is a kind of weak array object.  As such all references can be garbaged collected if there are no normal references to the contained objects from elsewhere.  When a contained object is garbage collected, the reference is turned into a reference to the residue object, see class ResidueObject.  The client is responsible for computing the hash value of its elements, extracting the key from an element, and for comparing a candidate with a look-up key.  The client must respond to #computeHash:, #compare:candidate:, and #extractKey:  Hash collisions are resolved by storing a colliding object in the next empty slot, which is either nil or the residue object.  "!   
partiallyPrime: n
	"Answer true if <n> has no divisors within the first few primes.  Note that this method is only used when creating a hash table whose size is greater than the twice the size of the prime lookup table, PrimeDeltas."

	| primes |
	primes := #(3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127).
	1 to: primes size
		do:
			[:k |
			n \\ (primes at: k) = 0
				ifTrue: [^false]].
	^true!  
new
	"Answer a new instance of the receiver."

	^self new: 1!  
new: anInteger
    "Answer a new instance of the receiver whose size is at least <anInteger>."

    ^super new: (self hashModulusFor: anInteger)!  
hashModulusFor: size
	"Private - Answer a prime number equal to or greater than <size> for use as hash modulus (and allocation size, except for LinearIdentityHashTable).  If <size> is too large to directly translate into a prime number then try to at least make it a number partially prime wrt the first few primes.  If that fails then at least ensure that it is odd."

	| n |
	n := size bitOr: 1.
	n <= MaxDeltaIndex
		ifTrue: [^(PrimeDeltas at: n // 2 + 1) + n].
	n to: n + 20 by: 2
			do:
				[:p |
				(self partiallyPrime: p)
					ifTrue: [^p]].
	^n!   
atKey: key put: element for: client
    "Associate <key> with <element> if <key> is not already present.  Answer what used to be associated with <key>. There are three possible results:
    nil - nothing was associated with the key and a new slot was used.
    resdue object - nothing was associated with the key and an existing slot was reused.
    anObject - the object that used to be associated with the key.
The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    | index object |
    key isResidue ifTrue: [ ^key ].
    index := self findKeyIndex: key for: client.
    (object := self at: index) isResidueOrNil
        ifTrue: [self at: index put: element].
    ^object! 
makeWeakArray: aBoolean
    "Private - If <aBoolean> is true, make the receiver a holder of weak object references, otherwise make the receiver a holder of normal object references.  The receiver must be an indexable object with no named instance variables.  Weak object references will not keep the referenced object from being garbage collected. If the only references to an object are weak references, the referenced object is garbaged collected and the reference is changed to a special object, the residue.  Answer the previous state of the weak array boolean.  See the class ResidueObject"
    <primitive: 154>
    ^ self primitiveFailed
! 
lookUpValue: key for: client ifAbsent: exceptionBlock
    "Answer the value associated with <key> if it is present in the receiver, otherwise the result of <exceptionBlock>l. The <client> is responsible for computing hash values."

    | assoc |
    assoc := self at: (self findKeyIndex: key for: client).
    ^assoc isResidueOrNil
        ifTrue: [exceptionBlock value]
        ifFalse: [assoc value]! 
removeKey: element for: client ifAbsent: exceptionBlock
    "Remove an element equal to the given <element> from the receiver. If the receiver does not contain an element equal to the element to be removed, return the result of evaluating the <exceptionBlock>. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    | lastIndex testIndex testObject searchIndex |
    testIndex := self findKeyIndex: element for: client.
    (self at: testIndex) isResidueOrNil
        ifTrue: [^exceptionBlock value].
    self at: testIndex put: nil.
    lastIndex := self size.
    [testIndex := testIndex == lastIndex ifTrue: [1] ifFalse: [testIndex + 1].
    (testObject := self at: testIndex) == nil]
        whileFalse:
            ["test next object for relocation"
            testObject isResidue
                ifTrue: [
                    self at: testIndex put: nil.
                    client decrementElementCount]
                ifFalse:
                    [searchIndex := self findKeyIndex: (client extractKey: testObject) for: client.
                    (self at: searchIndex) isResidueOrNil
                        ifTrue:
                            ["found object to move"
                            self at: searchIndex put: testObject.
                            self at: testIndex put: nil]]]!
lookUpValue: key for: client
    "Answer the value associated with <key> if it is present in the receiver, otherwise send errorAbsentKey to <client>l. The <client> is responsible for computing hash values."
    | assoc |
    assoc := self at: (self findKeyIndex: key for: client).
    ^assoc isResidueOrNil
        ifTrue: [client errorAbsentKey]
        ifFalse: [assoc value]!  
keysAndValuesDo: iterationBlock
    "Evaluate the <iterationBlock> once for each key/value pair in the receiver. The key will be the first argument, the value will be the second argument to the block. If the receiver is empty, the block will not be evaluated."

    | value |
    1 to: self size do:
        [:index |
        (value := self at: index) isResidueOrNil
            ifFalse: [iterationBlock value: value key value: value value]]! 
count
    "Answer the number of elements in the receiver."

    ^self inject: 0 into: [:n :x | x isResidueOrNil ifTrue: [n] ifFalse: [n + 1]]! 
lookUpKey: element for: client
    "Answer <element> if it is present in the receiver, otherwise nil. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    | temp |
    temp := self at: ( self findKeyIndex: element for: client ).
    temp isResidueOrNil ifTrue: [ ^nil ].
    ^temp!   
elementsDo: iterationBlock
    "Evaluate the <iterationBlock> once for each element in the receiver. If the receiver is empty, the block will not be evaluated."

    | value |
    1 to: self size do:
        [:index |
        (value := self at: index) isResidueOrNil
            ifFalse: [iterationBlock value: value]]!
findKeyIndex: element for: client
    "Private - Answer the index position of an <element> in the receiver or the first empty element position. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    | index indexedObject lastIndex emptyIndex |
    lastIndex := self size.
    emptyIndex := 0.
    index := (client computeHash: element) \\ lastIndex + 1.
    [(indexedObject := self at: index) == nil]
        whileFalse:
            [(client compare: element candidate: indexedObject)
                ifTrue: [ ^index ].
             (indexedObject isResidue and: [emptyIndex == 0])
                ifTrue: [emptyIndex := index].
            index := index == lastIndex ifTrue: [1] ifFalse: [index + 1]].
    ^emptyIndex == 0 ifTrue: [ index ] ifFalse: [ emptyIndex ].

! 
new: anInteger
    "Answer a new instance of the receiver capable of holding at least <anInteger> elements."

    ^self basicNew: ( self hashModulusFor: anInteger )  * 2! 
partialReadThreshold: anInteger
        "Set the partial read size (bytes)."
    PartialReadThreshold := anInteger.!
on: aFile
        "Answer a new instance of a file stream on aFile."
    ^((NationalLanguage isDoubleByteCp
        ifTrue: [MixedFileStream] ifFalse: [self])
            new)
        setCollection: aFile;
        setLimits!
binaryOn: aFile
        "Answer a new instance of a binary file stream on aFile."
    ^super on: aFile! 
defaultLineDelimiter
        "Answer the default line delimiter character used on this
        platform."
    ^Cr! 
partialReadHeaderSize
        "Answer the partial read header size (bytes)."
    ^PartialReadHeaderSize!
partialReadHeaderSize: anInteger
        "Set the partial read header size (bytes)."
    PartialReadHeaderSize := anInteger.!   
partialReadThreshold
        "Answer the partial read size (bytes)."
    ^PartialReadThreshold! 
crString
        "Answer a carriage return / line feed string."
    ^String with: Cr with: Lf!  
on: anIndexedCollection
        "Answer a new instance of the
         receiver on anIndexedCollection."
    ^(self new)
        setCollection: anIndexedCollection;
        setLimits!  
next
        "Answer the next character accessible by the receiver
         and advance the stream position.  Report an error
         if the receiver stream is positioned at end."
    | char |
    char := self nextOneByteCharacter.
    (char isLeadByte: leadBytes)
        ifTrue: [char := Character
            leadByte: char
            trailByte: self nextOneByteCharacter].
    ^char!   
nextPutAll: aCollection
        "Write each of the characters in
         aCollection to the receiver stream."
    ^super nextPutAll:
        ((aCollection isDoubleByteString)
            ifTrue: [aCollection asMixedString]
            ifFalse: [aCollection])!
leadBytes: leadByteFlags
        "Set the leadBytes flag array for normalizing mixed strings."
    leadBytes := leadByteFlags.! 
leadBytes
        "Answer the leadBytes flag array currently in use
        for normalizing mixed strings."
    ^leadBytes!
upTo: anObject
        "Answer the collection of objects from the receiver
         starting with the next accessible object and up to
         but not including anObject.  Set the position beyond
         anObject.  If anObject is not present, answer the
         remaining elements of the stream."
    ^self
        copyFrom: self position + 1
        to: ((self skipTo: anObject)
                ifTrue: [self position - (self sizeOf: anObject)]
                ifFalse: [self position])! 
setLimits
        "Private - Initialize the stream size and position."
    self leadBytes: NationalLanguage leadBytes.
    ^super setLimits!   
next: anInteger
        "Answer the next anInteger number of items from
         the receiver, returned in a collection of the
         same species as the collection being streamed
         over."
    | aStream |
    aStream := WriteStream on:
        (self collection species new: anInteger).
    anInteger timesRepeat: [
        aStream nextPut: self next].
    ^aStream contents! 
nextOneByteCharacter
        " Private - answer the next byte. "
    ^super next!   
reverseContents
        "Answer a collection of the same species as the
         receiver collection, with the contents in
         reverse order."
    ^self invalidMessage! 
asByteFileStream
        " Make the receiver a byte-oriented FileStream.
        Answer the receiver. "
    | byteStream |
    byteStream := FileStream new.
    1 to: FileStream instSize do: [ :i |
        byteStream instVarAt: i put: (self instVarAt: i)].
    self become: byteStream.
    ^byteStream!
asByteFileStreamCopy
        "Answer a copy of the receiver as a byte-oriented (single-byte) FileStream."
    | byteStream |
    byteStream := FileStream new.
    1 to: FileStream instSize do: [ :i |
        byteStream instVarAt: i put: ( self instVarAt: i ) ].
    ^byteStream!  
asMixedFileStream: leadByteFlags
        " Make the receiver a character-oriented MixedFileStream
        which interprets mixed string encodings using the specified
        leadBytes flag array.  Answer the receiver. "
    leadByteFlags == leadBytes ifTrue: [ ^self ].
    leadBytes := leadByteFlags.
    ^self!
setLineDelimiterFromFirstPage
        " Private - find the first line ending in the file. "
    | inDBC char c currentPosition |
    lineDelimiter == nil ifFalse: [ ^ self ].
    self validate.
    currentPosition := self position.
    self reset.
    lineDelimiter := Cr.
    c := self collection.
    inDBC := false.
    1 to: readLimit do: [ :i |
        inDBC
            ifTrue: [inDBC := false]
            ifFalse: [
                char := c at: i.
                (char isLeadByte: leadBytes)
                    ifTrue: [inDBC := true]
                    ifFalse: [
                        (char == Cr) ifTrue: [
                            lineDelimiter := Cr.
                                self position: currentPosition.
                            ^self].
                        (char == Lf) ifTrue: [
                            lineDelimiter := Lf.
                                self position: currentPosition.
                            ^self].
                        ]]].
    self position: currentPosition.! 
copyFrom: first to: last
        "Answer a string containing the characters of the
         receiver stream from byte positions first to last."
    ^(super copyFrom: first to: last)
        asNormalizedString: leadBytes!  
nextByte
        "Answer the next byte accessible by the receiver
         and advance the stream position.  Report an error
         if the stream is positioned at end."
    ^self nextOneByteCharacter asciiValue! 
nextWord
        "Answer a String containing the next word in the
         receiver stream.  A word starts with a letter,
         followed by a sequence of letters and digits."
    | first aChar |
    [self atEnd ifTrue: [^nil].
    (aChar := self next) isAlphaNumeric]
        whileFalse: [].  "skip separators"
    first := (aChar isDoubleByte
        ifTrue: [self position - 1]
        ifFalse: [self position]).
    [self atEnd
        ifTrue: [^self copyFrom: first to: self position].
     (aChar := self next) isAlphaNumeric]
        whileTrue: [].
    self backupOver: aChar.
    ^self copyFrom: first to: self position!
next
        "Answer the next character accessible by the receiver
         and advance the stream position.  Report an error
         if the receiver stream is positioned at end."
    <primitive: 65>
    self position: self position.
    self atEnd
        ifTrue: [
            ^self error: 'read beyond end of stream']
        ifFalse: [
            (position := position + 1) > readLimit
                ifTrue: [self error: 'position outside of stream'].
            ^self collection at: position]!   
position
        "Answer the current receiver stream position."
    ^pageStart + position - 1.! 
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    super printOn: aStream.
    aStream nextPutAll: ' on: '.
    self file name printOn: aStream.!   
isFileStream
        "Answer whether the receiver is a kind of FileStream."
    ^true!  
getBytesFor: aByteObject from: start to: stop
        " Directly copy from the stream to aByteObject.
          start and stop are byte indices into aByteObject. "
    | objectIndex writeTo bufferLeft |
    ( stop - start + 1 ) > self collection size ifTrue: [ ^self getBytesForFast: aByteObject from: start to: stop ].
    writeTo := objectIndex := start - 1.
    [(objectIndex := writeTo) < stop] whileTrue: [
        bufferLeft := collection size - position.
        writeTo := writeTo + bufferLeft min: stop.
        aByteObject
            replaceBytesFrom: objectIndex + 1
            to: writeTo
            with: collection
            startingAt: position + 1.
        self position: self position + writeTo - objectIndex]!
asByteFileStream
        "Make the receiver a byte-oriented FileStream.
        Answer the receiver."
    ^self!   
copyFrom: first to: last
        "Answer a String containing the characters of the
         receiver stream from positions first to last."
    | string savePosition index putIndex number size |
    string := self collection species new: last - first + 1.
    savePosition := self position.
    size := self size.
    putIndex := 1.
    index := first.
    [index <= last]
        whileTrue: [
            index > size
                ifTrue: [^self error: 'copy beyond end of file'].
            self position: index - 1.
            number := (last min: pageStart + readLimit - 1)
                - index + 1.
            string
                replaceFrom: putIndex
                to: putIndex + number - 1
                with: collection
                startingAt: position + 1.
            putIndex := putIndex + number.
            index := index + number].
    self position: savePosition.
    ^string!   
nextLine
        "Answer a String consisting of the characters of
        the receiver up to the next line delimiter."
    | line |
    line := self upTo: self lineDelimiter.
    self lineDelimiter == Cr
        ifTrue: [self peekFor: Lf].
    ^line! 
cr
        "Write the line terminating character
         (carriage-return line-feed pair or
         line-feed) to the receiver stream."
    self lineDelimiter == Cr
        ifTrue: [self nextPut: Cr].
    self nextPut: Lf!
sizeOf: aCharacter
        "Private - answer the size in bytes of aCharacter."
    ^(aCharacter isDoubleByte ifTrue: [2] ifFalse: [1])! 
partialContents
        "Answer the partial contents of the file,
        up to the current partial read threshold."
    ^self partialContents: self class partialReadThreshold
        headerSize: self class partialReadHeaderSize! 
partialContents: threshold
        "Answer the partial contents of the file,
        up to threshold bytes."
    ^self partialContents: threshold
        headerSize: self class partialReadHeaderSize!   
atEnd
        "Answer true if the receiver is positioned at the
         end (beyond the last object), else answer false."
    (position < readLimit or:
        [(pageStart + position) <= self updateLastByte])
            ifTrue: [^false]
            ifFalse:[^true]! 
skip: anInteger
        "Increment the position of the
         receiver by anInteger."
    self position:
        ((self position + anInteger
            min: self readLimit) max: 0)! 
flush
        "Guarantee that any writes to the receiver stream
         are physically recorded on disk."
    | pos |
    pos := self position.
    self
        setToEnd;
        readLimit;
        writePage.
    file flush.
    self position: pos!   
lineDelimiter
        "Answer the line delimiter character for the
         receiver file stream, either carriage-return
         or line-feed."
    lineDelimiter isNil ifTrue: [ self setLineDelimiterFromFirstPage ].
    ^lineDelimiter! 
lineDelimiter: aCharacter
        "Change the line delimiter character to aCharacter."
    lineDelimiter := aCharacter! 
backupOver: previousChar
        "Reposition the receiver to before the previous character.
        previousChar is the last character obtained from the receiver."
    self position:
        (self position - (self sizeOf: previousChar))! 
setLimits
        "Private - Initialize the stream size and position."
    file := collection.
    collection := String new: File pageSize.
    writeLimit := collection size.
    readLimit := file
        readBuffer: collection
        atPosition: 1.
    position := 0.
    pageStart := 1.
    writtenOn := false.
    lastByte := file size.!  
file
        "Answer the file over which the receiver is
         streaming."
    ^file!   
putBytesFrom: aByteObject from: start to: stop
        " Write the contents of aByteObject to the receiver.
          aByteObject can be a ByteArray or a String.
          start and stop are byte indices into aByteObject. "
    | writeTo objectLeft objectIndex |
    aByteObject isNil ifTrue: [ ^nil ].
    objectIndex := start - 1.
    [objectIndex < stop] whileTrue: [
        objectLeft := stop - objectIndex.
        writeTo := self collection size min: position + objectLeft.
        collection
            replaceBytesFrom: position + 1
            to: writeTo
            with: aByteObject
            startingAt: objectIndex + 1.
        objectIndex := objectIndex + writeTo - position.
        writtenOn := true.
        position := writeTo.
        self position: pageStart + position - 1]!
asMixedFileStream
        " Make the receiver a character-oriented MixedFileStream
        which interprets mixed string encodings using the lead bytes
        of the current national language.  Answer the receiver. "
    ^self asMixedFileStream: NationalLanguage leadBytes!
setLineDelimiterFromFirstPage
        "Private - find the first line ending in the file."
    | currentPosition buffer c i |
    lineDelimiter == nil ifFalse: [ ^self ].
    self validate.
    currentPosition := self position.
    self reset.
    buffer := self collection.
    i := 0.
    [lineDelimiter == nil and: [(i := i + 1) < readLimit]] whileTrue: [
        c := buffer at: i.
        c == Cr ifTrue: [ lineDelimiter := Cr ].
        c == Lf ifTrue: [ lineDelimiter := Lf ] ].
    lineDelimiter isNil ifTrue: [ lineDelimiter := Cr ].
    self position: currentPosition.!  
validate
    "Private - Initialize the stream size and position."

    collection notNil ifTrue: [ ^self ].
    file isOpen ifFalse: [ ^self error: 'file not open' ].
    collection := String new: File pageSize.
    readLimit := file
        readBuffer: collection
        atPosition: pageStart.
    writeLimit := collection size.
    lastByte := file size.!  
writePage
        "Private - Write the current page
         to the file, if it has changed."
    writtenOn
        ifTrue: [
            file
                writeBuffer: self collection
                ofSize: readLimit
                atPosition: pageStart.
            writtenOn := false]!
partialContents: threshold headerSize: headerSize
        "Answer the partial contents of the file,
        up to the threshold bytes."
    | crString nBytes startMessage endMessage fileHead fileTail |

    crString := self class crString.
    nBytes := headerSize min: threshold.
    startMessage :=
        'File size is greater than ', threshold printString,
            ' bytes (', file size printString, ')', crString,
        'first ', nBytes printString, ' bytes are ...', crString.
    fileHead := self copyFrom: 1 to: nBytes.

    nBytes := threshold - headerSize.
    nBytes <= 0
        ifTrue: [^startMessage, fileHead].
    endMessage :=
        crString,
        '***********************', crString,
        'last ', nBytes printString, ' bytes are ...', crString.
    fileTail := self
        copyFrom: self size - nBytes
        to: self size.
    ^startMessage, fileHead, endMessage, fileTail! 
pathName
        "Answer the complete pathname of the file
         over which the receiver is streaming."
    ^ self file pathName!   
nextPutAll: aCollection
        "Write each of the characters in aCollection to the
        receiver stream."
    | stopIndex |
    aCollection isDoubleByteString
        ifTrue: [ ^self putBytesFrom: aCollection ].
    stopIndex := position + aCollection size.
    stopIndex <= writeLimit
        ifTrue: [
            self collection
                replaceFrom: position + 1
                to: stopIndex
                with: aCollection
                startingAt: 1.
            position := stopIndex.
            writtenOn := true.
            ^aCollection ].
    self putBytesFrom: aCollection.
    ^aCollection!
position: anInteger
        "Set the receiver stream position to anInteger."
    self readLimit.
    ((anInteger + 1) < pageStart
        or: [(pageStart + self collection size) <= (anInteger + 1)])
            ifTrue: [
                self writePage.
                pageStart := ((anInteger // self collection size)
                    * collection size) + 1.
                readLimit := file
                    readBuffer: collection
                    atPosition: pageStart].
    position := anInteger - pageStart + 1.
    self updateLastByte!  
readLimit
        "Private - Answer the size of the receiver file."
    self validate.
    readLimit := readLimit max: position.
    ^self updateLastByte!
updateLastByte
        "Private - Answer the position of the last byte in
         the file, and update the instance variable."
    ^lastByte := lastByte max: position + pageStart - 1!   
collection
        "Private - Answer the collection over which
         the receiver is streaming."
    self validate.
    ^collection!   
copyFrom: first to: last into: aByteObject
        "Copy the characters of the receiver stream
         from positions first to last into an object
         containing bytes."
    | index putIndex number size |
    size := self size.
    putIndex := 1.
    index := first.
    [index <= last]
        whileTrue: [
            index > size
                ifTrue: [^self error: 'copy beyond end of file'].
            self position: index - 1.
            number := (last min: pageStart + readLimit - 1)
                - index + 1.
            aByteObject
                replaceBytesFrom: putIndex
                to: putIndex + number - 1
                with: self collection
                startingAt: position + 1.
            putIndex := putIndex + number.
            position := position + number.
            index := index + number]!
truncate
        "Set the size of the receiver stream to
         its current position."

    super truncate.
    self file setEndOfFileTo: self position!   
next: anInteger
        "Answer the next anInteger number of items from
         the receiver, returned in a collection of the
         same species as the collection being streamed
         over."

    self validate.
    ^super next: anInteger!  
close
        "Close the file associated with the receiver stream
         after writing all the data to the file."
    file isOpen ifTrue: [
        self readLimit.
        self writePage.
        file close ].
    collection := nil.!
getBytesForFast: aByteObject from: start to: stop
        " Directly copy from the stream to aByteObject.
          start and stop are byte indices into aByteObject. "
    | bytes |
    bytes := stop - start + 1.
    file fileId
        position: self position;
        read: bytes into: aByteObject.
    self position: self position + bytes.!   
asByteFileStreamCopy
        "Answer a copy of the receiver as a byte-oriented (single byte) FileStream."
    ^self copy!   
nextPut: aCharacter
        "Write aCharacter to the receiver stream."
    writtenOn := true.
    ^self primitiveNextPut: aCharacter!  
next
        "Answer the next object accessible by the receiver
         and advance the stream position.  Report an error
         if the receiver stream is positioned at end."
    | index |
    <primitive: 65>
    self atEnd
        ifTrue: [
            ^self error: 'read beyond end of stream']
        ifFalse: [
            index := self position + 1.
            self position: index.
            ^self collection at: index]!  
nextPutAll: aCollection
        "Write each of the objects in aCollection
         to the receiver stream.  Answer aCollection."
    super nextPutAll: aCollection.
    readLimit < position
        ifTrue: [readLimit := position].
    ^aCollection! 
nextUShort
        "Answer the next two bytes as a ushort integer."
    ^self nextByte + (self nextByte * 256)! 
setToEnd
        "Set the position of the receiver stream to
         the end."
    self position: self readLimit! 
setLimits
        "Private - Initialize the receiver's size and position."
    position := 0.
    readLimit := writeLimit := collection size!  
truncate
        "Set the size of the receiver stream to
         its current position."
    readLimit := position!
getInteger
        "Answer the next Integer encoded in the receiver."
    | answer |
    (answer := self next asciiValue) >= 128
        ifTrue: [^self getInteger * 128 + answer - 128]
        ifFalse: [^answer]! 
nextULong
        "Answer the next four bytes as a uLong integer."
    | answer |
    answer := 0.
    #( 1 256 65536 16777216 ) do: [ : n |
        answer := answer + (self nextByte * n)].
    ^answer!  
contents
        "Answer the collection over which the
         receiver is streaming."
    ^self copyFrom: 1 to: self readLimit!  
getBytesFor: aByteObject from: start to: stop
        "Directly copy from the stream to aByteObject.
        start and stop are indices into aByteObject. "
    | stopIndex |
    stopIndex := position + (stop - start + 1).
    (stopIndex > readLimit)
        ifTrue: [^self error: 'read beyond end of stream'].
    aByteObject
        replaceBytesFrom: start
        to: stop
        with: self collection
        startingAt: position + 1.
    self position: stopIndex.
    ^aByteObject!   
getBytesFor: aByteObject
        "Directly copy from the stream to aByteObject.
        basicSize used instead of size because of NLS/DBCS functionality. "
    self getBytesFor: aByteObject from: 1 to: aByteObject basicSize!   
nextByte
        "Answer the next byte accessible by the receiver
         and advance the stream position.  Report an error
         if the stream is positioned at end."
    ^self next asciiValue! 
nextPut: anObject
        "Write anObject to the receiver stream.
         Answer anObject."
    readLimit := self position + 1 max: readLimit.
    ^super nextPut: anObject! 
cr
        "Write the line terminating character (carriage-line-feed)
         to the receiver stream."
    self nextPut: Cr;
        nextPut: Lf!
position: anInteger
        "Set the receiver stream position to anInteger.
         Report an error if anInteger is outside the
         bounds of the receiver collection."
    (0 <= anInteger and: [anInteger <= writeLimit])
        ifFalse: [^self error: 'position outside of stream'].
    position := anInteger!  
nextPutAll: aCollection
        "Write each of the objects in aCollection to the
         receiver stream.  Answer aCollection."
    | stopIndex |
    ( aCollection isString
        and: [ aCollection containsDBCharacter
        and: [ collection isString
        and: [ collection isDoubleByteString not ]]] )
        ifTrue: [ collection := DoubleByteString fromString: collection ].
    stopIndex := position + aCollection size.
    stopIndex <= writeLimit
        ifTrue: [
            collection
                replaceFrom: position + 1
                to: stopIndex
                with: aCollection
                startingAt: 1.
            position := stopIndex.
            ^aCollection].
    ^aCollection do: [ :element |
        self nextPut: element]! 
putInteger: anInteger
        "Store an encoding of anInteger on the receiver.
        anInteger is expected to be unsigned. "
    anInteger < 128
        ifTrue: [self nextPut: anInteger asCharacter]
        ifFalse: [
            self nextPut: (anInteger \\ 128 + 128) asCharacter;
                putInteger: anInteger // 128]! 
putBytesFrom: aByteObject
        "Write the contents of aByteObject to the receiver.
        aByteObject can be a ByteArray or a String.
        basicSize used instead of size because of NLS/DBCS functionality."
    self putBytesFrom: aByteObject from: 1 to: aByteObject basicSize!
setToEnd
        "Set the position of the receiver stream to
         the end."
    self position: self writeLimit!
setLimits
        "Private - Initialize the receiver's size and position."
    readLimit := position := 0.
    writeLimit := collection size!  
space
        "Write a space character to the receiver stream."
    self nextPut: Space!
nextULongPut: anInteger
        "Write anInteger to the receiver stream as a uLong integer.
         Answer anInteger."
    self nextFourBytesPut: anInteger.
    ^anInteger! 
putBytesFrom: aByteObject from: start to: stop
        "Write the contents of aByteObject to the receiver.
        aByteObject can be a ByteArray or a String.
        start and stop are byte indices into aByteObject. "
    | stopIndex |
    aByteObject isNil ifTrue: [ ^nil ].
    stopIndex := position + (stop - start + 1).
    [stopIndex > writeLimit] whileTrue: [
        self grow ].
    collection
        replaceBytesFrom: position + 1
        to: stopIndex
        with: aByteObject
        startingAt: start.
    position := stopIndex.
    readLimit < position
        ifTrue: [readLimit := position].
    ^aByteObject!  
alignTo: numberOfBytes
        "Align the receiver to a boundary of numberOfBytes, by
         putting the correct number of pad bytes."
    | increment |
    increment := numberOfBytes - ( self position \\ numberOfBytes ).
    increment timesRepeat: [ self nextPut: 0 asCharacter ]!  
nextUShortPut: anInteger
        "Write anInteger to the receiver stream as a uShort integer.
         Answer anInteger."
    self nextTwoBytesPut: anInteger.
    ^anInteger!
nextBytePut: aByte
        "Write the character whose ASCII value is aByte
         to the receiver stream.  Answer aByte."
    aByte < 0
        ifTrue: [self  nextPut: aByte negated asCharacter]
        ifFalse: [self nextPut: aByte asCharacter].
    ^aByte!
contents
        "Answer a collection representing the
         contents of the stream."
    ^self copyFrom: 1 to: self position!  
nextFourBytesPut: anInteger
        "Write anInteger as the next four bytes of the
         receiver stream."
    self
        nextBytePut: (anInteger bitAnd: 16rFF);
        nextBytePut: ((anInteger bitShift: -8) bitAnd: 16rFF);
        nextBytePut: ((anInteger bitShift: -16) bitAnd: 16rFF);
        nextBytePut: ((anInteger bitShift: -24) bitAnd: 16rFF)!  
nextTwoBytesPut: anInteger
        "Write anInteger as the next two bytes of the
         receiver stream."
    self
        nextBytePut: (anInteger bitAnd: 255);
        nextBytePut: ((anInteger bitShift: -8) bitAnd: 255)!  
skip: anInteger
        "Increment the position of the
         receiver by anInteger."
    [ self position + anInteger > writeLimit ] whileTrue: [ self grow ].
    self position: ( ( self position + anInteger ) max: 0 )! 
tab
        "Write a tab character to the receiver stream."
    self nextPut: Tab!  
tab: tabCount
        "Write <tabCount> tab characters to the receiver stream."
    self next: tabCount put: Tab!   
writeLimit
        "Private - Answer the size of the receiver collection."
    ^writeLimit! 
nextPut: anObject
        "Write anObject to the receiver stream.
         Answer anObject."
    | index |
    <primitive: 66>
    index := position + 1.
    index > writeLimit
        ifTrue: [ self grow ].
    position := index.
    (anObject isCharacter
        and: [ anObject isDoubleByte
        and: [ collection isString
        and: [ collection isDoubleByteString not ]]])
        ifTrue: [ collection := DoubleByteString fromString: collection ].
    collection at: index put: anObject.
    ^anObject!   
grow
        "Private - Answer the receiver expanded
         to accommodate more elements."
    | size new |
    size := self collection size * 2 + 10.
    new := collection species new: size.
    new replaceFrom: 1
        to: collection size
        with: collection.
    collection := new.
    writeLimit := collection size.!   
setCollection: aCollection
        "Private - Set the receiver stream collection
         to aCollection."
    collection := aCollection.! 
position
        "Answer the current receiver stream position."
    ^position!  
copyFrom: firstIndex to: lastIndex
        "Answer the subcollection of the collection over
         which the receiver is streaming, from firstIndex
         to lastIndex."
    ^self collection copyFrom: firstIndex to: lastIndex.!   
countBlanks
        "Skip over blank and tab characters.  Answer the
         number of character positions skipped, counting
         1 for blanks and 4 for tabs."
    | answer char |
    answer := 0.
    [self atEnd]
        whileFalse: [
            char := self next.
            char == $ 
                ifTrue: [answer := answer + 1]
                ifFalse: [
                    char == Tab
                        ifTrue: [answer := answer + 4]
                        ifFalse: [
                            self backupOver: char.
                            ^answer]]].
    ^answer!   
nextLine
        "Answer a String consisting of the characters of
         the receiver up to the next line delimiter
         (line-feed or carriage-return line-feed)."
    | line |
    line := self upTo: Lf.
    line size > 0 ifTrue: [
        (line at: line size) == Cr
            ifTrue: [^line copyFrom: 1 to: line size - 1]].
    ^line!  
setToEnd
        "Set the position of the receiver stream to
         the end."
    self position: self readLimit! 
nextChunk
        "Answer a String up to '!!', undoubling embedded !!'s.
        Trailing non-printing characters are skipped.  The methods in
        sources.sml and change.log are in chunk format."
    | answer |
    answer := self upTo: $!! .       "assumes !!'s are rare"
    [ self atEnd or: [ ( self peekFor: $!! ) not ] ] whileFalse: [
        answer := answer, ( String with: $!! ), ( self upTo: $!! ) ].
    "skip any non-printing characters (space, tab, ctrl-Z, etc.)"
    [ self atEnd not and: [ self peek asciiValue <= 32 ] ]
        whileTrue: [ self next ].
    ^answer!   
isEmpty
        "Answer true if the receiver stream contains no
         elements, else answer false."
    ^self size = 0! 
reverseContents
        "Answer a collection of the same species as the
         receiver collection, with the contents in
         reverse order."
    | aStream savePosition |
    self collection class isVariable
        ifTrue: [
            aStream := WriteStream on:
                (collection species new: self readLimit)]
        ifFalse: [
            aStream := WriteStream on:
                (collection copy)].
    savePosition := self position.
    self readLimit - 1 to: 0 by: -1 do: [ :i |
        self position: i.
        aStream nextPut: self next].
    self position: savePosition.
    ^aStream contents!  
atEnd
        "Answer true if the receiver is
         positioned at the end (beyond
         the last object), else answer
         false."
    <primitive: 67>
    ^readLimit <= self position!   
size
        "Answer the size of (number of objects in) the
         receiver stream."
    ^self readLimit!
skip: anInteger
        "Increment the position of the
         receiver by anInteger."
    self position:
        ((self position + anInteger
            min: self readLimit) max: 0)! 
peekFor: anObject
        "Answer true if the next object to be accessed in
         the receiver stream equals anObject, else answer
         false.  Only advance the stream position if the
         answer is true."
    | nextObject |
    self atEnd
        ifTrue: [^false]
        ifFalse: [
            anObject = (nextObject := self next)
                ifTrue: [^true]
                ifFalse:[
                    self backupOver: nextObject.
                    ^false]].!
lineDelimiter: aCharacter
        "Change the line delimiter character
         to aCharacter.  Ignore for non-file
         streams."!
do: aBlock
        "Evaluate aBlock once for each element in the
         receiver, from the current position to the end."
    [self atEnd]
        whileFalse: [aBlock value: self next]!
backupOver: previousObject
        "Reposition the receiver to before the previous object (single/DB character).
        previousObject is the last object obtained from the receiver."
    self position: self position - 1!  
nextInteger
        "Answer the next Integer from the receiver; the value
        may include a radix."
    ^Integer readFrom: self!   
isStream
        "Answer true if receiver is a kind of Stream."
    ^true!  
show: aCollection
        "Equivalent to nextPutAll: for streams.  For text
         editor windows, causes immediate display on screen."
    ^self nextPutAll: aCollection!   
skipTo: anObject
        "Advance the receiver position beyond the next
         occurrence of anObject, or if none, to the end of
         stream.  Answer true if anObject occurred, else
         answer false."
    [self atEnd]
        whileFalse: [
            self next = anObject
                ifTrue: [^true]].
    ^false!
peek
        "Answer the next object in the receiver stream
         without advancing the stream position.  If the
         stream is positioned at the end, answer nil."
    | anObject |
    self atEnd
        ifTrue: [^nil]
        ifFalse: [
            anObject := self next.
            self backupOver: anObject.
            ^anObject]!  
indexOf: aCollection
        "Answer the position of the first occurrence
         of aCollection in the receiver.  If no such element
         is found, answer zero."
    | savePos index2 limit2 |
    limit2 := aCollection size.
    [self atEnd]
        whileFalse: [
            (self next) = (aCollection at: 1)
                ifTrue: [
                    savePos := self position.
                    index2 := 2.
                    [(index2 <= limit2
                        and: [self atEnd not])
                        and: [ (self next) =
                            ( aCollection at: index2 ) ] ]
                        whileTrue: [index2 := index2 + 1].
                    index2 > limit2
                        ifTrue: [^savePos]
                        ifFalse: [self position: savePos]]].
    ^0!  
nextMatchFor: anObject
        "Access the next object in the receiver.  Answer
         true if it equals anObject, else answer false."
    ^(self next) = anObject!  
nextWord
        "Answer a String containing the next word in the
         receiver stream.  A word starts with a letter,
         followed by a sequence of letters and digits."
    | first aChar |
    [self atEnd ifTrue: [^nil].
    self next isAlphaNumeric]
        whileFalse: [].  "skip separators"
    first := self position.
    [self atEnd
        ifTrue: [^self copyFrom: first to: self position].
     (aChar := self next) isAlphaNumeric]
        whileTrue: [].
    self backupOver: aChar.
    ^self copyFrom: first to: self position! 
position: anInteger
        "Set the receiver stream position to anInteger.
         Report an error if anInteger is outside the
         bounds of the receiver collection."
    (0 <= anInteger and: [anInteger <= readLimit])
        ifFalse: [^self error: 'position outside of stream'].
    position := anInteger!   
readLimit
        "Private - Answer the size of
         the receiver collection."
    ^readLimit! 
upTo: anObject
        "Answer the collection of objects from the receiver
         starting with the next accessible object and up to
         but not including anObject.  Set the position beyond
         anObject.  If anObject is not present, answer the
         remaining elements of the stream."
    <primitive: 82>
    ^self
        copyFrom: self position + 1
        to: ((self skipTo: anObject)
                ifTrue: [self position - 1]
                ifFalse: [self position])!  
collection
        "Private - Answer the collection over which
         the receiver is streaming."
    ^collection!   
next: anInteger
        "Answer the next anInteger number of items from
         the receiver, returned in a collection of the
         same species as the collection being streamed
         over."
    | startIndex endIndex result |
    startIndex := self position + 1.
    endIndex := startIndex + anInteger - 1.
    endIndex > self readLimit ifTrue: [
        self position: self readLimit.
        ^self error: 'read beyond end of stream'].
    result := self copyFrom: startIndex to: endIndex.
    self position: endIndex.
    ^result!  
close
        "Close the stream.  Do nothing
         for non-file streams."!   
contents
        "Answer the collection over which
         the receiver is streaming."
    ^self implementedBySubclass!   
next: anInteger put: anObject
        "Answer anObject.  Put anObject to the
         receiver stream anInteger number of times."
    anInteger timesRepeat: [
        self nextPut: anObject].
    ^anObject!   
nextPiece
        "File sources.sml consists of compressed sequences
         of characters called pieces.  Answer a String containing
         the next piece of text to be compressed from the
         receiver stream."
    | first aCharacter |
    self atEnd
        ifTrue: [^nil].
     (aCharacter := self next) == Lf
        ifTrue: [^String with: Lf].
    aCharacter asInteger > 127
        ifTrue: [^String with: 128 asCharacter with: aCharacter].
    first := self position.
    aCharacter isLetter
        ifTrue: [
            [self atEnd
                ifTrue: [^self copyFrom: first to: self position].
             ((aCharacter := self next) isLowerCase)]
                whileTrue: []]    "skip over letters"
        ifFalse: [
            aCharacter isDigit
                ifTrue: [
                    [self atEnd
                        ifTrue: [^self copyFrom: first to: self position].
                     (aCharacter := self next) isDigit]
                        whileTrue: []]   "skip digits"
                ifFalse: [
                    [self atEnd
                        ifTrue: [^self copyFrom: first to: self position].
                     (aCharacter := self next) isAlphaNumeric or: [aCharacter == Lf
                        or: [aCharacter asInteger > 127]]]
                        whileFalse: []]].   "skip over whats between words"
    self backupOver: aCharacter.
    ^self copyFrom: first to: self position!  
reset
        "Position the receiver stream to the beginning."
    self position: 0!
newHeap: heapSize
        "Answer an instance of the receiver
         with heapSize bytes available for allocation."
    | heap |
    heap := super new initialSize: heapSize.
    [   Heaps isNil
            ifTrue: [ Heaps := OrderedCollection new ].
        HeapUseCounts isNil
            ifTrue: [ HeapUseCounts := Dictionary new ].
        Heaps addFirst: heap.
        HeapUseCounts at: heap put: 0 ] evaluateWithoutInterrupts.
    ^heap!   
newHeap
        "Answer an instance of the receiver."
    ^self newHeap: self defaultHeapSize!  
defaultHeap
        "Private - Answer the default heap on which to allocate
         ExternalHeapAddresses."
    ^Heaps isNil
        ifTrue: [ self newHeap: self defaultHeapSize ]
        ifFalse: [ Heaps first ]!   
defaultHeapSize
        "Each heap is 64k by default"
    ^16r10000!
exit
        "Private - Free all the addresses allocated from the heaps,
         and then free the heaps."
    [
        Heaps notNil ifTrue: [
            Heaps do: [ :heap | heap free ].
            Heaps := nil.
            HeapUseCounts := nil ] ] evaluateWithoutInterrupts!
startUp
        "Private - Initialize the list of allocated heaps at startup."
    Heaps := nil.
    HeapUseCounts := nil! 
fromInteger: anInteger
        "Private - Answer a new Instance of the receiver
         with value anInteger."
    | new |
    new := self new.
    anInteger isLargeInteger
        ifTrue: [ new replaceFrom: 1 to: new size with: anInteger startingAt: 1 ]
        ifFalse: [ new uLongAtOffset: 0 put: anInteger ].
    ^new!   
nullValue
        "Answer an instance of the receiver class which represents
        an invalid (uninitialized) value."
    ^NullHandle!   
new
        "Answer a new handle which is of the appropriate size."
      ^self basicNew: self byteSize!
byteSize
        "Private - answer the size in bytes of objects of
       the receiver class."
    ^4! 
fromBytes: aByteObject
        "Private - Answer a new handle with bytes from aByteObject."
    ^(self basicNew: aByteObject size)
        replaceFrom: 1
        to: aByteObject size
        with: aByteObject
        startingAt: 1! 
= anExternalHandle
        "Answer whether anExternalHandle is the same class and contains
        the same bytes as the receiver."
    | index |
    self == anExternalHandle ifTrue: [ ^true ].
    ( self class == anExternalHandle class ) ifFalse: [ ^false ].
    ( index := self size ) ~= anExternalHandle size ifTrue: [ ^false ].
    [ index <= 0 ] whileFalse: [
        ( self at: index ) = ( anExternalHandle at: index )
            ifFalse: [ ^false ].
        index := index - 1 ].
    ^true! 
allocBytes: anInteger
        "Private - Allocate a block of anInteger bytes
         and answer the address of the block."
    | blockAddress |
    blockAddress := ExternalHeapAddress new.
    self allocate: blockAddress ofSize: anInteger.
    blockAddress memoryHandle: self.
    blockAddress memorySize: anInteger.
    ^blockAddress!  
hash
        "Private - Answer the integer hash of the receiver."
    ^self basicHash!  
= aHandle
        "Answer true if the receiver is the same as aHandle."
    <primitive: 55>
    aHandle isExternalHandle ifFalse: [ ^false ].
    ^self asInteger = aHandle asInteger!
asExternalGlobalAddress
        "Answer the receiver as an ExternalGlobalAddress."
    ^ExternalGlobalAddress fromBytes: self!  
asHandleParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a Windows procedure call.
         In this case, answer the receiver.  Use this method when
         the parameter must be a handle and cannot be nil."
    ^self!  
isExternalHandle
        "Answer whether the receiver is an instance of
        ExternalHandle or one of its subclasses."
    ^true!   
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host system procedure call."
    ^self!   
replaceBytesFrom: byteStart
    to: byteStop
    with: aByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aByteObject beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 80>
    aByteObject class isBytes
        ifFalse: [self error: 'source must be a byte object'].
    (self == aByteObject and: [byteRepStart < byteStart])
        ifTrue: [ "do backward move for same object"
            index2 := byteRepStart + byteStop - byteStart.
            index1 := byteStop.
            [byteStart <= index1]
                whileTrue: [
                self
                    at: index1
                    put: (aByteObject basicAt: index2) asInteger.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := byteRepStart.
    index1 := byteStart.
    [index1 <= byteStop]
        whileTrue: [
            self
                at: index1
                put: (aByteObject basicAt: index2) asInteger.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
uLongAtOffset: anInteger
        "Answer the double word (32 bits) at anInteger in the receiver.
         Offsets are zero relative."
    | total offset |
    <primitive: 78>
    offset := anInteger + 1.
    total := 0.
    3 to: 0 by: -1 do: [ :i |
        total := ( total bitShift: 8 ) + ( self at: offset + i ) ].
    ^total!
printOn: aStream
        "Private - Append the ASCII representation of
         the receiver to aStream."
    aStream nextPutAll: self class name, '{'.
    1 to: self basicSize do: [:i | (self at: i) printOn: aStream. aStream space].
    aStream nextPut: $}.!  
uShortAtOffset: anInteger
        "Answer the word (16 bits) at anInteger in the receiver.
         Offsets are zero relative."
    <primitive: 19>
    ^( self at: anInteger + 1 ) + ( ( self at: anInteger + 2 ) bitShift: 8 )! 
fillFromAddress: anAddress
        "Fill the receiver by copying bytes from memory at anAddress."
    self replaceFrom: 1
          to: self size
          with: anAddress
          startingAt: 1! 
isValid
        "Answer whether the receiver is a valid (non-NULL)
         handle."
    ^self ~= self class nullValue!
replaceFrom: start
    to: stop
    with: aVariableByteObject
    startingAt: repStart
        "Replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aVariableByteObject beginning at index
         position repStart.  Answer the receiver."
    <primitive: 105>
    ^self primitiveFailed!
uLongAtOffset: anInteger put: anObject
        "Store anObject at anInteger in the receiver.
         Offsets are zero relative."
    | off low high |
    <primitive: 126>
    low := anObject bitAnd: 16rFFFF.
    high := anObject bitShift: -16.
    off := anInteger + 1.
    self at: off put: ( low bitAnd: 16rFF ).
    self at: off + 1 put: ( low bitShift: -8 ).
    self at: off + 2 put: ( high bitAnd: 16rFF ).
    self at: off + 3 put: ( ( high bitShift: -8 ) bitAnd: 16rFF ).
    ^anObject!   
uShortAtOffset: anInteger put: anObject
        "Store anObject at anInteger in the receiver.
         Offsets are zero relative."
    | off |
    <primitive: 89>
    off := anInteger + 1.
    self at: off put: ( anObject bitAnd: 16rFF ).
    self at: off + 1 put: ( ( anObject bitShift: -8 ) bitAnd: 16rFF ).
    ^anObject!  
asInteger
        "Answer the receiver converted to an Integer."
	^self asUnsignedInteger!  
asExternalAddress
        "Answer the receiver as an ExternalAddress."
    ^ExternalAddress fromBytes: self!
asUnsignedInteger
        "Answer the receiver converted to an Integer."
        "if large, do special case processing"
    ( ( self at: 4 ) bitAnd: 2r01000000 ) ~= 0
        ifTrue: [ ^( LargePositiveInteger new: 4 ) replaceFrom: 1 to: 4 with: self startingAt: 1 ].

        "otherwise, small"
    ^self uLongAtOffset: 0! 
asExternalHandle
        "Answer the receiver as an ExternalHandle."
    ^self! 
hash
        "Private - Answer the integer hash of the receiver."
    ^self asInteger!  
decimalPlace
        "Answer the current system value for the number of digits
         following the decimal point in a number."
    decimalPlace isNil
        ifTrue: [ decimalPlace := self queryNationalProfileInt: 'iDigits' default: 2 ].
    ^decimalPlace!  
named: aLibraryName
    "Answer the bound SmalltalkLibrary named aLibraryName,
    or nil if not bound."

    ^SmalltalkLibraryBinder named: aLibraryName!
byteSize
        "Private - answer the size in bytes of objects of
       the receiver class."
    ^2! 
pathName: aString in: aDirectory attribute: fileAttr mode: openMode 
        "Answer a FileStream with path name aString 
         with default directory aDirectory with attribute anAttr 
         and aMode as the file open mode. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details." 
    | file | 
    file := self fromPath: aString in: aDirectory. 
    ^file directory 
            file: file name
                attribute: fileAttr 
                mode: openMode! 
fromAddress: anExternalAddress
        "Answer a string whose bytes are copied from
         memory at anExternalAddress."
    | length |
    length := 1.
    [(anExternalAddress at: length) = 0]
        whileFalse: [length := length + 1].
    ^self fromAddress: anExternalAddress length: length - 1.
!
readFrom: stream
        "Read (and return) a string from <stream>.   A string comprises
         all of the characters between quotes.  Two quote marks together
         put a quote into the string"
    | writeStream |
    writeStream := WriteStream on: ( self new: 50 ).
    stream upTo: $'.
    [ writeStream nextPutAll: ( stream upTo: $' ).
    stream peek == $' ] whileTrue: [
        writeStream nextPut: stream next ].
    ^writeStream contents!
fromArrayOfSubstrings: arrayOfStrings
        "Create a String by appending all of the Strings in
         <arrayOfStrings> with Space between each String"
    ^self fromArrayOfSubstrings: arrayOfStrings separatedBy: $ !   
fromAddress: anExternalAddress length: anInteger
        "Answer a normalized string with anInteger bytes
        copied from system memory at anExternalAddress."
    | t |
    t := self new: anInteger.
    t replaceFrom: 1
          to: anInteger
          withAddress: anExternalAddress
          startingAt: 1.
   ^t asNormalizedString!  
fromAddressUnchanged: anExternalAddress length: anInteger
        "Answer a string of size anInteger with bytes
         copied from system memory at anExternalAddress."
    | t |
    t := self new: anInteger.
    t replaceFrom: 1
          to: anInteger
          withAddress: anExternalAddress
          startingAt: 1.
   ^t!  
fromArrayOfSubstrings: arrayOfStrings separatedBy: separatorChar
        "Create a String by appending all of the Strings in
         <arrayOfStrings> with <separatorChar> between each String"
    | aStream |
    aStream := WriteStream on: (self new: 200).
    arrayOfStrings
        do: [ :string | aStream nextPutAll: string asString ]
        andBetweenDo: [ aStream nextPut: separatorChar ].
    ^aStream contents!
isDoubleByteString
        "Answer true if receiver is a kind of DoubleByteString."
    ^false! 
eventHandlers
        "Private - answer the event handlers table."
    ^EventHandlers!  
fromLocator: aFileSystemLocator
    "Private - private instance creation method used primarily by FileSystemLocators to create instances of the appropriate FileSystem Class."
 
    | new |
    new := self new.
    new fileSystemLocator: aFileSystemLocator asFileSystemLocator.
    ^new
!
named: volumeName
        "Answer an instance of the receiver representing the volume
        named volumeName, signaling an error if the specified volume
        does not exist."
    ^self
        named: volumeName
        ifAbsent: [ FileError signal: 'Volume ', volumeName printString, ' does not exist' with: nil ]! 
fromPath: path
    "Answer an instance of the receiver representing an entity with the given path."

	^self fromLocator: ( FileSystemPath fromString: path )!  
named: volumeName ifAbsent: exceptionBlock
        "Answer an instance of the receiver representing the volume
        named volumeName."
    ^self volumes
        detect: [ :vol | vol name asUpperCase = volumeName asUpperCase ]
        ifNone: exceptionBlock! 
lineEndSequence
        "Answer a string containing the preferred line-end sequence for
        files residing in this operating environment."
    lineEndSequence == nil
        ifTrue: [ lineEndSequence := String with: Cr with: Lf.].
    ^lineEndSequence.
!  
volumesDo: iterationBlock
        "Evaluate the iterationBlock once for each of the volumes that are
        currently accessible."
    self volumes do: iterationBlock!   
fileName
        "Answer the receiver's file name."
    ^'kernel32'!
getCurrent
        "Private - get (open) an instance of the receiver."
    ^KernelLibrary!  
apiPrimitiveMap
        "Private - answer a Dictionary mapping API calling
         conventions to their API call primitive number."
    ^Dictionary new
        at: 'ole:' put: 164;
        at: 'api:' put: 94;
        at: 'stdcall:' put: 94;
        at: 'c:' put: 94;
        at: 'pascal:' put: 10;
        at: 'pascal16:' put: 9;
        at: 'c16:' put: 8;
        yourself!
typeIndex: aTypeSymbol
        "Private - Answer the integer corresponding to aTypeSymbol."
    ^Types at: aTypeSymbol.!
getCurrent
        "Private - get (open) an instance of the receiver."
    ^self open!  
apiPrimitiveFor: aCallingConvention
        "Private - answer the primitive number to be used when
         making an API call using the calling convention
         named by aString, or nil if the given calling convention
         is not supported by the receiver class."
    ^self apiPrimitiveMap at: aCallingConvention ifAbsent: [ nil ]!  
resultTypeOfMethod: apiMethod
         " Answer the symbolic name  of the result type
         for the API primitive method <apiMethod>. "

    ^self resultTypeForNumber: apiMethod apiTypes last ifAbsent: [ nil ]
!   
currentOrNil
        "Private - answer the current open instance of the receiver class if set,
        otherwise nil."
    ^current!   
primitiveCall: dll proc: procName arguments: anArray types: typeArray returns: returnType
        "Private - Do a generic API call."
    <primitive: 95>
    self error: 'Dynamic Link Library call error'!
argumentTypeForNumber: aTypeIndex ifAbsent: aBlock
        " Private - answer the symbolic name of the argument type <aTypeIndex>.
        Answer the result of evaluating <aBlock> if this is not a supported argument type. "

    ^Types keyAtValue: aTypeIndex ifAbsent: aBlock!  
getHandle
        "Answer a handle to the specified Dynamic Link Library."
    ^self getHandle: self fileName!  
moduleHandle
        "Answer the module handle for the receiver."
    ^self current!
apiPrimitives
        "Private - Answer a collection of the API
         call primitive numbers."
    ^self apiPrimitiveMap values!
clearCachedAddresses
        "Private - Clear cached API addresses."
    | dllClasses |
    "clear API addresses for this class and any other dll superclasses."
    dllClasses := ( Array with: self ), self allSuperclasses.
    dllClasses := dllClasses copyFrom: 1 to: ( dllClasses indexOf: DynamicLinkLibrary ) - 1.

    dllClasses do: [ :dllClass |
        dllClass methodDictionary do: [ :m |
            m isAPIMethod ifTrue: [
                ( m at: 2 ) replaceFrom: 1 to: 4 withObject: 16rFF ] ].
        dllClass class methodDictionary do: [ :m |
            m isAPIMethod ifTrue: [
                ( m at: 2 ) replaceFrom: 1 to: 4 withObject: 16rFF ] ] ]!  
exceptionForArgumentErrorIn: apiMethod arguments: arguments ifNone: aBlock
        " Answer the exception which should be signaled to report an
        argument error invoking the API primitive method <apiMethod>
        with the given <arguments> values.  Answer the result of
        evaluating <aBlock> if no argument type error is found. "

    | types arg type |
    types := apiMethod apiTypes.
    types := types copyFrom: 6 to: types size - 1.
    1 to: types size do: [ :i |
        arg := arguments at: i.
        type := self argumentTypeForNumber: ( types at: i )
            ifAbsent: [ ^APICallInvalidArgumentType
                ofExpectedType: #undefined
                forArgumentNumber: i ].
        ( self isValidArgument: arg type: type )
            ifFalse: [
            ^APICallInvalidArgumentType
                ofExpectedType: type
                forArgumentNumber: i ].
        ].
    ^aBlock value!
exceptionForArgumentNumberIn: apiMethod argumentNumber: argNumber ifNone: aBlock
        "Answer the exception which should be signaled to report an
        argument error invoking the API primitive method <apiMethod>
        with the given <arguments> values.  Answer the result of
        evaluating <aBlock> if no argument type error is found."
    | types type |
    types := apiMethod apiTypes.
    types := types copyFrom: 6 to: types size - 1.
    type := self argumentTypeForNumber: ( types at: argNumber ) ifAbsent: [ #undefined ].
    ^APICallInvalidArgumentType
        ofExpectedType: type
        forArgumentNumber: argNumber!
isValidArgument: arg type: type
        " Answer whether the argument value <arg> is valid
        for an argument type whose symbolic name is <type>.
        Validity is determined by what the VM will allow. "

    | firstSlot |

    ( type = #short or: [ type = #ushort ] )
        ifTrue: [
            ^arg isNil
            or: [ ( arg isSmallInteger
                    and: [ type = #short or: [ arg positive ] ] )
            or: [ arg class isBytes and: [ arg size <= "2" 4 ] ] ] ].
    ( type = #long or: [ type = #ulong ] )
        ifTrue: [
            ^arg isNil
            or: [ ( arg isSmallInteger
                    and: [ type = #long or: [ arg positive ] ] )
            or: [ arg class isBytes and: [ arg size <= 4 ] ] ] ].
    type = #boolean
        ifTrue: [
            ^arg isNil or: [ arg isBoolean ] ] .
    type = #handle
        ifTrue: [
            ^arg isNil
            or: [ arg class isBytes and: [ arg size between: 1 and: 4 ] ] ].
    ( #( #struct #structValue #structIn #structOut ) includes: type )
        ifTrue: [
            ^arg isNil
            or: [ arg class isBytes
            or: [ " ExternalBuffer with bytes or external address contents "
                arg class isPointer
                and: [ ( firstSlot := arg instVarAt: 1 ) class isBytes  " structure with local bytes "
                        or: [ ( firstSlot := firstSlot instVarAt: 1 ) class isBytes
                                and: [ firstSlot size = 4 ] ] ]  " structure addressing bytes in external memory "
                 ] ] ].
    ^false!   
argumentTypesOfMethod: apiMethod
         " Answer an array containing the symbolic names of the
         argument types for the API primitive method <apiMethod>. "

    | types |
    types := apiMethod apiTypes.
    ^( types copyFrom: 6 to: types size - 1 ) asArray
        collect: [ :argIndex | self argumentTypeForNumber: argIndex ifAbsent: [ nil ] ]!
resultTypeForNumber: aTypeIndex ifAbsent: aBlock
        " Private - answer the symbolic name of the result type <aTypeIndex>.
        Answer the result of evaluating <aBlock> if this is not a supported result type. "

    ^Types keyAtValue: aTypeIndex ifAbsent: aBlock!
current
        "Answer the current open instance of the receiver class."
    current isNil ifTrue: [ current := self getCurrent ].
    ^current!  
current: aDynamicLinkLibrary
        "Private - set the current open instance of the receiver class."
    current := aDynamicLinkLibrary!   
typeIndex: aTypeSymbol ifAbsent: aBlock
        "Private - Answer the integer corresponding to aTypeSymbol."
    ^Types at: aTypeSymbol ifAbsent: aBlock.!  
open
        "Answer a handle to the specified Dynamic Link Library."
    ^self open: self fileName!
new: anInteger
        "Private -  Answer an instance of the receiver."    
    ^self basicNew: anInteger!  
handle: exceptionClass with: handlerBlock during: userBlock
        "Create an exception handler and activate it during evaluation
        the user block."

    ^(self new
           exception: exceptionClass;
           response: handlerBlock;
           activateDuring: userBlock)!
retryToken
        "Private - Return the value that is used to indicate that the protected
        block should be reevaluated."

    ^retryToken!
evaluateResponseBlock: responseBlock for: anException
        "Private - evaluate the first argument as the exception
        block but first setup a continuation for result value."

    responseBlock argumentCount = 0
        ifTrue: [ ^responseBlock value ]
        ifFalse: [
           self resultContinuation: [ :result | ^result ].
           ^responseBlock value: anException]!  
response
        "Private - Answer the block that is evaluated if this handler is activated."

    ^block! 
resultContinuation: aOneArgumentBlock
        "Private - Remember a block whose evaluation will terminate execution of the handler block. Its argument is the value to be return by the exception handler."

    resultContinuation := aOneArgumentBlock!  
exception
        "Private - Answer the class of exception that this handler deals with"

    ^exception!  
exception: anExceptionClass
        "Private - Remember what exception (class) this handler deals with."

    exception := anExceptionClass!   
resume: result
        "Return the argument as the value of the message
        that signaled the exception processed by  this handler."

    self resultContinuation value: result "never returns"!  
passFrom: theException
        "Activate any enclosing handlers for the argument exception."

    | result currentResultContinuation |
    currentResultContinuation := self resultContinuation.
    result := theException handle.
    theException activeHandler: self.
    self resultContinuation: currentResultContinuation.
    ^result!
retryBlock
        "Private - Return the block that will be evaluated as the protected
        block if the handler is instructed to do a retry."

    ^retryBlock!   
findHandler: anException
        "If an active exception handler exists for the argument, activate it.
        Otherwise activate the default handler for the argument."

    | hndlr result oldH |
    hndlr := self.
	oldH := CurrentProcess exceptionEnvironment.
    " use default environment if an exception occurs while searching for handler "
    CurrentProcess exceptionEnvironment: nil.
    [hndlr == nil] whileFalse:
        [(hndlr exception handles: anException)
            ifTrue: [
                CurrentProcess exceptionEnvironment: oldH.
                ^hndlr handle: anException].
          hndlr := hndlr previous].

	CurrentProcess exceptionEnvironment: anException signalEnvironment.
    result := anException defaultAction.
	CurrentProcess exceptionEnvironment: oldH.
	^result!
continuation
        "Private - Answer the value of continuation."

    ^continuation! 
return: result
        "Return the argument as the value of the block
        that is protected by this handler."

    self continuation value: result "never returns"!   
response: aBlock
        "Private - Remember the block that should be evaluated if this
        handler is activated."

    block := aBlock!  
retry
        "Abort the current exception processing
        and reattempt the evaluation of the protected block."

    self continuation value: self class retryToken  "never returns"! 
retry: aBlock
        "Abort the current exception processing and reattempt it using
        the argument as the protected block."

    self retryBlock: aBlock.
    self retry! 
previous: aValue
        "Private - Remember the exception handling environment that was active
        before the receiver was activated"

    previous := aValue!   
activateDuring: userBlock
        "Private - activate the receiver as an exception handler during
        the execution of the argument block"

    | oldH result |
    oldH := CurrentProcess exceptionEnvironment.
    self previous: oldH.
    self retryBlock: userBlock.
    [ CurrentProcess exceptionEnvironment: self.
      [(result := self evaluateProtectedBlock: self retryBlock) == self class retryToken]
            whileTrue: [].
    ] invisibleEnsure: [CurrentProcess exceptionEnvironment: oldH].
    ^result!  
evaluateProtectedBlock: userBlock
        "Private - evaluate the block that is protected by the receiver,
        but first establish a block that can be used to continue execution
        with our sender."

     self continuation: [:result| ^result].
     ^userBlock value! 
continuation: aValue
        "Private - Set the value of continuation."

    continuation := aValue!   
handle: anException
        "Private - the receiver is a handler for the argument exception. Handle the exception."

    | result environment |
    environment := CurrentProcess exceptionEnvironment.
    [CurrentProcess exceptionEnvironment: self previous.
     anException activeHandler: self.
     result := self evaluateResponseBlock: self response for: anException
	] invisibleEnsure:
		[anException activeHandler: nil.
		CurrentProcess exceptionEnvironment: environment].
    anException isResumable ifTrue: [^result].
    self continuation value: result        "never returns"!   
previous
        "Private - return the exception handling environment that was active
        before the receiver was activated."

    ^previous! 
resultContinuation
        "Private - Answer a block whose evaluation will terminate execution of the handler block. Its argument is the value to be return by the exception handler."

    ^resultContinuation!   
retryBlock: aBlock
        "Private - Remember the block that will be evaluated as the protected
        block if the handler is instructed to do a retry."

    retryBlock := aBlock!
propertyAt: aPropertyName put: anObject
	"Set the value of the receiver's property identified by <aPropertyName> to <anObject>."

	self propertyTableForEdit at: aPropertyName put: anObject!  
asExternalAddress
        "Answer the receiver as an ExternalAddress."
    ^ExternalAddress fromBytes: self!
isMDIClient
        "Answer true if receiver is an instance of class
         MDIChild, else answer false."
    ^false!
addLibrary: fileHandle name: aString version: aString2
	<api: AddLibrary ulong self self ushort> 
    ^self invalidArgument!
moveFileEx: oldName to: newName flags: flags
    <api: MoveFileA struct struct ulong boolean>
    ^self invalidArgument!
dateFormat
        "Answer the current system value for date format.
         Answer DfMDY = Month-Day-Year
                     DfDMY = Day-Month-Year
                     DfYMD = Year-Month-Day."
    dateFormat isNil
        ifTrue: [ dateFormat := self queryNationalProfileInt: 'iDate' default: 0 ].
    ^dateFormat!
new
         "Answer an empty instance of the receiver."
    ^self new: self defaultInitialSize!
new: size
        "Answer an empty instance of the receiver that is initially
        capable of holding <size> elements."
    ^self basicNew
        initialSize: ( self allocationForSize: size )!  
defaultInitialSize
        "Private-  Answer the default initial size for instances being created
        without an initial size being given."
    ^5!
allocationForSize: anInteger
    "Private"
    "Answer the number of slots required to hold <anInteger> elements in an optimally packed instance of the receiver."
    "Implementation note: this formula is related to one in HashTable>>loadFactorExceeded: (and its subclasses)."

    ^((100 * anInteger) // 75) + 1!
withAll: aCollection
        "Answer an instance of the receiver containing all the elements of the receiver."
    ^( self new: aCollection size )
        addAll: aCollection;
        yourself.!
decimalLeadZero
        "Answer the current system value for decimal lead zero.
         Answer 0 = no leading zero (.7)
                      1 = leading zero (0.7)."
    decimalLeadZero isNil
        ifTrue: [ decimalLeadZero := self queryNationalProfileInt: 'iLZero' default: 1 ].
    ^decimalLeadZero!   
dependsOn: anObject
        "Add the receiver to anObject's
         collection of dependents."
    anObject addDependent: self!   
asDate
        "Answer a Date representing the date
         described by the receiver.  The receiver
         must contain first the day number then
         the month name and then the year
         separated by blanks."
    ^Date fromString: self!  
getDate
	"Answer an Array of time and date of the file."

	| wasOpen ar |
	wasOpen := self isOpen.
	[ wasOpen
        ifFalse: [ self openReadOnly ].
        ar := ( WinFileTime fromFile: self ) asDosDateTime ]
            ensure: [ wasOpen ifFalse: [ self close ] ].
	^ar!
isReadOnly
	"Answer true if the file is readonly (the file itself, not the open handle)."

	^self attributes includes: $r! 
filesNamed: filterString
        "Answer a collection of file names from
         the receiver directory, filtered using filterString,
         e.g. '*.txt'."

	^self fileNamesMatching: (Pattern new: filterString asUppercase)!   
allFileNamesDo: iterationBlock
    "Evaluate the <iterationBlock> once with the name of each file contained within the receiver or any of its subdirectories.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated files."

    self fileNamesDo: iterationBlock.
    self directoriesDo: [ : aDir |
        aDir allFileNamesDo: iterationBlock.].!
for: anObject
        "Answer a ConstantAccessor which answers <anObject>
        when it is evaluated. "
    ^self new object: anObject!  
printOn: aStream
        "Append the ASCII representation
        of the receiver to aStream."
    self class printOn: aStream.
    aStream nextPutAll: ' (', object printString, ')'.!   
object: anObject
        "Private - set the object."
    object := anObject.!   
evaluate
        "Answer the receiver's object."
    ^object!   
evaluateWithArguments: evaluationArguments
        "Answer the receiver's object."
    ^object! 
asActionSequence
        "Answer an action sequence containing the receiver."
    ^ActionSequence with: self!   
eventsHandled
        "Answer the events for which there are actions
        registered in the receiver's event table."
    ^self eventTable keys! 
pathName: aString 
    in: aDirectory 
    action: anAction 
    fileSize: aFileSize 
    attribute: fileAttr 
    flags: fileFlags 
    mode: openMode 
        "Answer a FileStream with path name aString 
         with default directory aDirectory with the specified attributes. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details." 
    | file | 
    file := self fromPath: aString in: aDirectory. 
    ^file directory 
            file: file name
                action: anAction 
                fileSize: aFileSize 
                attribute: fileAttr 
                flags: fileFlags 
                mode: openMode!  
copyToNonSmalltalkMemory: aVariableByteObject withAllocFlag: allocFlags
        "Private - Copy aVariableByteObject to an allocated host memory
        segment with allocFlags and answer the address of that memory."
    | address sizeInBytes |
    aVariableByteObject isNil ifTrue: [ ^self new ].
    sizeInBytes := aVariableByteObject isDoubleByteString
        ifTrue: [ aVariableByteObject basicSize ]
        ifFalse: [ aVariableByteObject size ].
    address := self allocateMemory: sizeInBytes flags: allocFlags.
    self copyFrom: aVariableByteObject to: address count: sizeInBytes.
    ^address! 
volumeRelative: components
    "Answer an instance of the receiver representing the relative path whose components are the elements of the list of <components>."

    | path |
    path := self new.
    path absolute: #volumeRelative.
    path componentNames: components.
    ^path!  
addBehavior: methodDictionary
	"Add <methodDictionary> as instance specific behavior for the receiver."
	"If the method dictionary is not instance specific, do not add it (instance specific method dictionaries have a nil classField)"
	"ASSUMPTIONS:
		The methods in methodDictionary do not directly reference instance variables"

	methodDictionary classField == nil
		ifFalse: [^nil].
	self methodDictionaryArray: (Array with: methodDictionary with: self methodDictionaryArray).!   
unmount
        "Unmount the volume represented by the receiver.  If the volume is
        already unmounted, do nothing."
    self cannotBeUnmounted! 
fileName
    ^'vtk32', SmalltalkLibrary versionAndPlatformExtension! 
handles: anException
        "Answer true if a handler for the receiver
        can handle the argument exception. This
		message is sent by the exception handling
		system while choosing a handler for a
		signaled exception.  The default implementation
		performs an #isKindOf:  test of the argument
		relative to the receiver.  This permits a handler for
		an exception to also handle subclasses of
		the exception.  Subclasses may override
		this method to impose a different test for
		selecting a handler"

    ^anException isKindOf: self! 
signal: msg
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

   ^(self new messageText: msg) signal!
, arg
    "Answer a new instance of ExceptionSet containing the receiver and the argument."

    ^(ExceptionSet with: self) , arg! 
signal
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence."

    ^self new signal!  
signalEnvironment
	"Return the exception environment that was active at the time the exception is signaled"

	^signalEnvironment!  
defaultDescriptionString
        "Private - Return a textual description of the
        exception if an explicit description has not been provided.
        Subclass will frequently override this method."
    ^self class name! 
isResumable
	"Return <true> if this is a resumable exception.
	 The standard implementation returns false.  This
	 should be overridden by subclasses that define
	 resumable exceptions to return <false>"

    ^false!
resume
        "Return nil as the value of the message that signaled this exception."

    self resume: nil!   
signalEnvironment: anExceptionEnvironment
	"Private - Remember that exception environment at the time the exception is signaled"

	signalEnvironment := anExceptionEnvironment!
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it."

    Process
        queueWalkback: self description
        makeUserIF: CurrentProcess isUserIF
        resumable: ( self isResumable ifTrue: [ 2 ] ifFalse: [ 1 ] )!   
activateHandler: env
        "Private - Find and activate a handler"

	self resignalContinuation == nil ifTrue: [
		self resignalContinuation: [^self resignalContinuation]]. "the block serves as its own flag value"
	^env == nil
		ifTrue: [self defaultAction]
		ifFalse: [env findHandler: self].


!  
replacementException
	"Private - Return the exception that is to be signaled in place of the receiver"

	^resignalException!   
resignalContinuation
	"Private - Return a block whose evaluation causes a resignal"

	^resignalBlock!  
signal
        "Signal that this exception has occurred,
        find and execute the appropriate handler."

    self isActive ifTrue: [
        ^ControlError signal: 'Signaling an already signaled exception'].
	self signalEnvironment: CurrentProcess exceptionEnvironment.
    ^self handle! 
activeHandler
        "Private - Answer the exception handler that is currently active"
    ^currentHandler!
activeHandler: handler
        "Remember the exception handler that is currently active."
    currentHandler := handler!
pass
        "This handler does not want to handle the exception so
        activate any enclosing handlers."

    ^self exit: (self activeHandler passFrom: self)!   
exit: value
        "Return the argument as the value of the handler block,
        as if it was the value of the last expression in the block.  If
        the exception is resumable this will be equivalent to #resume:.
        If the exception is non-resumable this is equivalent to #return:."
    self isResumable
        ifTrue: [self resume: value]
        ifFalse: [self return: value]!
messageText
        "Answer the message text associated with this exception."
    ^messageText! 
messageText: aValue
        "Remember the argument as a message to associate with this exception"
    messageText := aValue!
resignalAs: anException
        "Abort the current exception handler, restoring the exception environment
        and the evaluation stack (executing necessary ensure:/ifCurtailed: blocks)
        to its orginal state as it existed when this exception was first signaled.
        Then signal the argument exception.  This causes the argument exception
        to function as if it had been originally signaled in place of the receiver"

    self replacementException: anException.
    self resignalContinuation value   "never returns!!"
!   
resignalContinuation: aBlock
	"Private - Remember a block whose evaluation causes a resignal"

	resignalBlock := aBlock!   
retry
        "Abort the current exception handler and reattempt the evaluation
        of the protected block."

    self activeHandler retry!   
isActive
        "Private - return <true> if this exception is currently being handled."
    ^self activeHandler ~~ nil!
outer
        "Activate the enclosing hander for this exception. Afterwards,
        if this exception is resumable, the current handler will continue
        executing with the resumption value from the enclosing handler
        returned as the value of this message."

    ^self activeHandler passFrom: self!  
handle
        "Private - find the active handler for this exception and activate it."

	| result |
	result := self activateHandler: CurrentProcess exceptionEnvironment.
	result == self resignalContinuation
		ifTrue: [ ^self replacementException signal ].
	self isResumable ifFalse: [ CurrentProcess terminate ].
	^result


!  
replacementException: anException
	"Private - Remember the exception that is to be signaled in place of the receiver"

	resignalException := anException!  
return
        "Return nil as the value of the block guarded by the active
        exception handler."

    self return: nil! 
resume: value
        "Return the argument as the value of the message that signaled
        this exception."

    self isResumable ifFalse: [
        ControlError
            signal: 'Attempt to resume from a non-resumable exception'].
    self activeHandler resume: value  "will not return"!  
retryUsing: aBlock
        "Abort the current exception handler, replace the protected block
        with the argument, and then evaluate the new protected block
        under the protection of the handler."

    self activeHandler retry: aBlock!   
description
    "Return a textual description of the exception"

    | msg |
    (msg := self messageText) == nil
        ifTrue: [^self defaultDescriptionString]
        ifFalse: [^msg]! 
return: value
        "Return the argument as the value of the block guarded by the
        active exception handler."

    self activeHandler return: value! 
close
	"Close the receiver."

	self fileId notNil
		ifTrue:
			[self fileId close.
			fileId := nil]!   
string: aString1 isLessThanOrEqualTo: aString2
        "Answer true if aString1 is before or equal to aString2
         in the current sort sequence, else answer false.
         The comparison is not case sensitive."
    ^(self compareStringi: aString1 withString: aString2) <= 0!  
topFrame: aProcessIndex
        "Private - set the top stack frame"
    ^topFrame := ( ( ( endPosition - aProcessIndex ) + 1 ) - startPosition )
        * self class frameBiasUnit!   
fileNamesDo: iterationBlock
    "Evaluate the <iterationBlock> once with the name of each file contained within the receiver.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated files."

	self searchResultsDo: [:searchResult |
		searchResult isFile
			ifTrue: [iterationBlock value:searchResult entityName]]!   
currentTimeInto: anArray
        "Private - anArray is set to the current time.
         anArray is of size 4.  The elements in order
         contain hours, minutes, seconds and milliseconds."
    | systemTime |
    systemTime := WinSystemTime new.
    KernelLibrary getLocalTime: systemTime asParameter.
    ^anArray
        at: 1 put: systemTime wHour;
        at: 2 put: systemTime wMinute;
        at: 3 put: systemTime wSecond;
        at: 4 put: systemTime wMilliseconds;
        yourself!  
exception
	"Private - Answer an exception describing the api error."

	| method process arguments |
	process := Process copyStack.
	method := process methodAt: 2.
	arguments := (1 to: method apiArgumentCount) collect: [ :index |
        process argAt: 2 number: index].
	^self exceptionForMethod: method arguments: arguments! 
apiFailureReason
        "Answer a value indicating why the last API primitive call made in the receiver process failed."
    ^CurrentProcess apiFailureReason! 
call: procName arguments: anArray types: typeArray returns: returnType
        "Private - Call the procedure named procName in the
         receiver's dynamic link library, passing
         it the arguments anArray whose types are described by
         typeArray and whose return parameter is returnType.
         The number of elements in anArray and typeArray must
         match."
    | intTypes intRetType |
    intTypes := Array new: typeArray size.
    1 to: typeArray size do: [ :i |
        intTypes at: i put: ( self class typeIndex: ( typeArray at: i ) ) ].
    intRetType := self class typeIndex: returnType.
    ^self class
        primitiveCall: self
        proc: procName asParameter
        arguments: anArray
        types: intTypes
        returns: intRetType!   
invalidArgument
	"Private - Initiate a walkback indicating an invalid argument."

    ^self exception signal!  
convertArray: typeArray
        "Private - Answer an array of integer types
         corresponding to the symbols in typeArray."
    | intTypes |
    intTypes := Array new: typeArray size.
    1 to: typeArray size do: [ :i |
        intTypes at: i put: ( self class typeIndex: ( typeArray at: i ) ) ].
    ^intTypes!   
convertResult: returnType
        "Private - Answer an integer type
         corresponding to the returnType symbol."
    ^self class typeIndex: returnType!   
exceptionForMethod: method arguments: arguments
    "Private - Answer an exception for the given method and arguments"

    | failureReason name |

    failureReason := self apiFailureReason.
    failureReason isNil
        ifTrue: [   " old API failure primitive code "
            name := method apiName.
            ( self queryProcAddr: name ) isInteger
               ifTrue: [ ^APICallEntryPointNotFound in: self entryPointName: name ].
            ^self class
                exceptionForArgumentErrorIn: method
                arguments: arguments
                ifNone: [ APICallUnknownPrimitiveFailure new ]
            ].

    failureReason = 3
        ifTrue: [ self error: 'bad dll handle' ].
    failureReason = 4
        ifTrue: [ ^APICallEntryPointNotFound in: self entryPointName: method apiName ].

    ( failureReason >= 8 and: [ ( failureReason bitAnd: 16r80000000 ) = 0 ] )
        ifTrue: [
            ^self class
                exceptionForArgumentNumberIn: method
                argumentNumber: ( failureReason bitShift: -4 )
                ifNone: [ APICallError new messageText: 'API argument error' ] ].

    ( self class resultTypeOfMethod: method ) = #hresult
        ifTrue: [ ^self exceptionForHresult: failureReason ].
    ^APICallUnknownPrimitiveFailure new!   
call: procName arguments: anArray types: typeArray returns: returnType dllName: aString
        "Private - Call the procedure named procName in the
         dynamic link library named aString, passing
         it the arguments anArray whose types are described by
         typeArray and whose return parameter is returnType.
         The number of elements in anArray and typeArray must
         match."
    | intTypes intRetType |
    intTypes := Array new: typeArray size.
    1 to: typeArray size do: [ :i |
        intTypes at: i put: ( self class typeIndex: ( typeArray at: i ) ) ].
    intRetType := self class typeIndex: returnType.
    ^self class
        primitiveCall: aString asParameter
        proc: procName asParameter
        arguments: anArray
        types: intTypes
        returns: intRetType!
isDynamicLinkLibrary
        "Answer true if receiver is an instance of class
         DynamicLinkLibrary or one of its subclasses, else answer false."
    ^true! 
exceptionForHresult: hresult
        " Private - answer an exception for the HRESULT error code <hresult>. "

    ^APICallError new messageText: 'HRESULT error: ', ( hresult radix: 16 )! 
isCollection
        "Answer true if receiver is a kind of Collection."
    ^false! 
osErrorMessage: anInteger
        "Private - answer a String which contains the appropriate error description
        for the host error identified by anInteger."
    ^OperatingSystem getErrorMessage: anInteger!
new
	"Private - Answer an initialized instance of the receiver."

	^super new initialize!  
current
	"Answer the current instance of the receiver class."

    Current isNil ifTrue: [ Current := self new ].
    ^Current!   
externalResources
	"Answer the externalResources WeakRegistry."

	^self current externalResources! 
finalizer
	"Answer the simple finalization WeakRegistry."

	^self current finalizer!   
getImageName: aBuffer
    <api: PrGetImageName self none>
    ^self invalidArgument!
libraryName: anInteger
    <api: LibraryName ulong ulong>
    ^self invalidArgument!
setUserConfigurationOption: index value: valueInteger
        "Set system setting to valueInteger. All values take effect
        the next time the virtual machine uses them.
        0 - Set nominal flip size
        1 - Set GC padding size
        2 - Set Residue object."
    <primitive: 153>! 
registerResidue: aResidueObject
	    "Private - Register aResidueObject as the special object in the
        virtual Machine that garbage collected weak array references
        are changed to."
	self setUserConfigurationOption: 2 value: aResidueObject! 
nominalFlipSizeBytes: anInteger
        "Set the minimum amount of bytes that the garbage collector
        must flip before objects are tenured; default = 4096.
        This takes effect immediately."
    self setUserConfigurationOption: 0 value: anInteger!
closeSignOn
        "Private - Send close to the sign-on DLL so that
         it knows how to clean up its act."
    <api: CloseStartupDialog boolean>
    ^self invalidArgument! 
objectAtAddress: anAddress
    <api: ObjectAtAddress ulong self>
    ^self invalidArgument! 
paddingSizeBytes: anInteger
        "Set the amount of bytes that the garbage collector
        allocates beyond the end of old space to help recognize
        low memory situations; default = 32768.
        This takes effect during the next compact of object space."
    self setUserConfigurationOption: 1 value: anInteger! 
buildIdentifier
        "Private - answer the build identifier of the receiver."
    | address |
    ( address := self queryProcAddr: 'vmBuildID' ) = 0 ifTrue: [ ^nil ].
    ^String fromAddress: ( ExternalAddress fromAddress: address )!  
getObjectAddress: index
    <api: getObjectAddress ushort ulong>
    ^self invalidArgument! 
dllNumber: anInteger
    <api: DllNumber self ulongReturn>
    ^self invalidArgument!   
removeObjectLibrary: anInteger
    <api: RemoveObjectLibrary ulong boolean>
    ^self invalidArgument!  
resizeCodeCache: anInteger
        "Set the size of the compiled code cache to anInteger kilobytes.
        anInteger should be between 256 and 4096 KB."
    <primitive: 139>
    ^self error: 'argument out of range'!  
clearCodeCache
        "Clear the cache of executable code for all CompiledMethods."
    <primitive: 138>
    ^self primitiveFailed!   
rightTopUnit
        "Answer the right top corner for a one-unit rectangle."
    ^1@0!  
add: newObject after: oldObject
        "Answer newObject.  Insert newObject immediately after
         the element oldObject in the receiver collection.  If
         oldObject is not in the collection, report an error."
    | index |
    index := 1.
    [index <= self size]
        whileTrue: [
            oldObject = (self at: index)
                ifTrue: [^self add: newObject afterIndex: index].
            index := index + 1].
    ^self errorAbsentElement! 
removeIndex: anInteger
        "Answer the receiver.  Remove the element of the receiver
         at index position anInteger.  If anInteger is an invalid
         index for the receiver, report an error."
    | index |
    index := anInteger + startPosition - 1.
    (index between: startPosition and: endPosition)
        ifFalse: [^self errorAbsentElement].
    [index < endPosition]
        whileTrue: [
            contents
                at: index
                put: (contents at: index + 1).
            index := index + 1].
    contents at: endPosition put: nil.
    endPosition := endPosition - 1!  
startPosition: start endPosition: end
        "Private - Answer the receiver.  Set the position
         of the first and last elements of the receiver,
         to the arguments start and stop respectively."
    startPosition := start.
    endPosition := end! 
add: anObject afterIndex: anInteger
        "Answer anObject.  Insert anObject at index position
         anInteger + 1 in the receiver collection.  If anInteger
         is out of the collection bounds, report an error."
    self putSpaceAfter: anInteger.
    ^self at: anInteger + 1 put: anObject!  
add: newObject before: oldObject
        "Answer newObject.  Insert newObject immediately before
         the element oldObject in the receiver collection.  If
         oldObject is not in the collection, report an error."
    | index |
    index := 1.
    [index <= self size]
        whileTrue: [
            oldObject = (self at: index)
                ifTrue: [^self add: newObject beforeIndex: index].
            index := index + 1].
    ^self errorAbsentElement!  
before: anObject ifNone: aBlock
        "Answer the element that immediately precedes
         anObject in the receiver collection.  If anObject
         is not an element of the receiver, aBlock is
         evaluated (with no arguments)."
    | index |
    index := startPosition + 1.
    [index <= endPosition]
        whileTrue: [
            anObject = (contents at: index)
                ifTrue: [^contents at: index - 1].
            index := index + 1].
    ^aBlock value!  
copyFrom: beginning to: end
        "Answer an OrderedCollection containing the
         elements of the receiver from index position
         beginning through index position end."
    | answer endPos |
    ( endPos := end - beginning + 1 ) negative ifTrue: [ self errorInBounds: endPos ].
    ( answer := self species new: self size )
        startPosition: 1
        endPosition: endPos.
    ^answer
        replaceFrom: 1
        to: endPos
        with: self
        startingAt: beginning!   
, aCollection
        "Answer an OrderedCollection containing all
         the elements of the receiver followed by
         all the elements of aCollection."
    aCollection isCollection ifFalse: [ self error: 'Argument must be a Collection' ].
    ^self copy
        addAll: aCollection;
        yourself
!  
add: anObject beforeIndex: anInteger
        "Answer anObject.  Insert anObject at index position
         anInteger - 1 in the receiver collection.  If anInteger
         is out of the collection bounds, report an error."
    self putSpaceAfter: anInteger - 1.
    ^self at: anInteger put: anObject! 
putSpaceAfter: anInteger
        "Private - Answer the receiver with room for an
         element immediately after index position anInteger."
    | index |
    endPosition = contents size
        ifTrue: [self putSpaceAtEnd].
    anInteger = 0
        ifTrue: [
            startPosition = 1
                ifTrue: [self putSpaceAtStart].
            startPosition := startPosition - 1.
            ^self].
    endPosition := endPosition + 1.
    index := self size - 1.
    [index > anInteger]
        whileTrue: [
            self
                at: index + 1
                put: (self at: index).
            index := index - 1]!   
grow
        "Private - Answer the receiver expanded in
         size to accommodate more elements."
    self growTo: contents size + self growSize!   
addFirst: anObject
        "Answer anObject.  Add anObject before
         the first element of the receiver."
    startPosition = 1
        ifTrue: [self putSpaceAtStart].
    startPosition := startPosition - 1.
    contents at: startPosition put: anObject.
    ^anObject!  
after: anObject ifNone: aBlock
        "Answer the element that immediately follows
         anObject in the receiver collection.  If anObject
         is not an element of the receiver, aBlock is
         evaluated (with no arguments)."
    | index |
    index := startPosition.
    [index < endPosition]
        whileTrue: [
            anObject = (contents at: index)
                ifTrue: [^contents at: index + 1].
            index := index + 1].
    ^aBlock value! 
at: anInteger ifAbsent: aBlock
        "Answer the element of the receiver at index
         position anInteger.  If anInteger is an invalid
         index for the receiver collection, return the result
         of evaluating aBlock."
    | index |
    index := anInteger + startPosition - 1.
    ( startPosition <= index and: [ index <= endPosition ] )
        ifFalse: [ ^aBlock value ].
    ^contents at: index!   
removeAbsoluteIndex: anInteger
        "Private - Answer the receiver.  Remove the element of the receiver
         at absolute index position anInteger.  If anInteger is an invalid
         index for the receiver, report an error."
    | index |
    (anInteger between: startPosition and: endPosition)
        ifFalse: [^self errorAbsentElement].
    index := anInteger.
    [index < endPosition]
        whileTrue: [
            contents
                at: index
                put: (contents at: index + 1).
            index := index + 1].
    contents at: endPosition put: nil.
    endPosition := endPosition - 1!   
replaceFrom: start to: stop with: aCollection
        "Answer a new OrderedCollection containing the
         receiver whose elements at index position start
         through stop have been replaced by the elements
         of aCollection."
    | finalSize size index |
    size := aCollection size.
    finalSize := self size + size -
        (stop - start + 1).
    finalSize > contents size
        ifTrue: [self growTo: finalSize + (finalSize // 3 + 10)].
    self
        startPosition: startPosition
        endPosition: contents size.
    self
        replaceFrom: start + size
        to: finalSize
        with: self
        startingAt: stop + 1.
    self
        replaceFrom: start
        to: start + size - 1
        with: aCollection
        startingAt: 1.
    self
        startPosition: startPosition
        endPosition: startPosition + finalSize - 1.
    index := endPosition + 1.
    [index <= contents basicSize]
        whileTrue: [
            contents at: index put: nil.
            index := index + 1].
    ^self! 
add: anObject
        "Answer anObject.  Add anObject after the
         last element of the receiver collection."
    endPosition = contents size
        ifTrue: [self putSpaceAtEnd].
    endPosition := endPosition + 1.
    contents at: endPosition put: anObject.
    ^anObject!
addAllLast: aCollection
        "Answer aCollection.  Add all the elements
         contained in aCollection to the receiver
         after its last element."
    | index size |
    size := aCollection size.
    index := 1.
    [index <= size]
        whileTrue: [
            self addLast: (aCollection at: index).
            index := index + 1].
    ^aCollection! 
size
        "Answer the number of elements contained by
         the receiver collection."
    ^endPosition - (startPosition - 1)!
putSpaceAtEnd
        "Private - Answer the receiver with room for more
         elements following the last element of the collection."
    | size index start |
    startPosition = 1
        ifTrue: [^self grow]
        ifFalse: [
            size := self size.
            start := startPosition // 2.
            index := 0.
            [index < size]
                whileTrue: [
                    contents
                        at: start + index
                        put: (contents at: startPosition + index).
                    index := index + 1].
            startPosition := start.
            endPosition := startPosition + size - 1].
    index := contents size.
    [index > endPosition]
        whileTrue: [
            contents at: index put: nil.
            index := index - 1]!   
initialSize: anInteger
        "Private - Answer the receiver after initializing
         it to be an empty OrderedCollection with
         anInteger number of slots."
    startPosition := 1.
    endPosition := 0.
    contents := Array new: anInteger! 
before: anObject
        "Answer the element that immediately precedes
         anObject in the receiver collection.  If anObject
         is not an element of the receiver, report an error."
    ^self
        before: anObject
        ifNone: [^self errorAbsentElement]!  
do: aBlock
        "Answer the receiver.  For each element in the receiver,
         evaluate aBlock with that element as the argument."
    | index |
    index := startPosition - 1.
    [(index := index + 1) <= endPosition]
        whileTrue: [aBlock value: (contents at: index)]!   
at: anInteger put: anObject
        "Answer anObject.  Replace the element of the
         receiver at index position anInteger with the
         anObject.  If anInteger is an invalid index
         for the receiver collection, report an error."
    | index |
    index := anInteger + startPosition - 1.
    (startPosition <= index and: [index <= endPosition])
        ifFalse: [
            ^self errorInBounds: anInteger].
    contents at: index put: anObject.
    ^anObject!  
putSpaceAtStart
        "Private - Answer the receiver with room for more
         elements before the first element of the collection."
    | size index end |
    endPosition = contents size
        ifTrue: [self grow].
    size := self size.
    end := contents size + endPosition + 1 // 2.
    index := 0.
    [index < size]
        whileTrue: [
            contents
                at: end - index
                put: (contents at: endPosition - index).
            index := index + 1].
    startPosition := end - size + 1.
    endPosition := end.
    index := 1.
    [index < startPosition]
        whileTrue: [
            contents at: index put: nil.
            index := index + 1]!  
removeFirst
        "Remove and answer the first element of the receiver.
         If the collection is empty, report an error."
    | answer |
    startPosition > endPosition
        ifTrue: [^self errorAbsentElement].
    answer := contents at: startPosition.
    contents at: startPosition put: nil.
    startPosition := startPosition + 1.
    ^answer!  
asOrderedCollection
        "Answer an OrderedCollection containing
         the elements of the receiver."
    ^self! 
addAllFirst: aCollection
        "Answer aCollection.  Add all the elements
         contained in aCollection to the receiver
         before its first element."
    | index |
    index := aCollection size.
    [index <= 0]
        whileFalse: [
            self addFirst: (aCollection at: index).
            index := index - 1].
    ^aCollection!
addLast: anObject
        "Answer anObject.  Add anObject after
         the last element of the receiver."
    endPosition = contents size
        ifTrue: [self putSpaceAtEnd].
    endPosition := endPosition + 1.
    contents at: endPosition put: anObject.
    ^anObject!   
after: anObject
        "Answer the element that immediately follows
         anObject in the receiver collection.  If anObject
         is not an element of the receiver, report an error."
    ^self
        after: anObject
        ifNone: [^self errorAbsentElement]! 
at: anInteger
        "Answer the element of the receiver at index
         position anInteger.  If anInteger is an invalid
         index for the receiver collection, report an error."
    | index |
    index := anInteger + startPosition - 1.
    (startPosition <= index and: [index <= endPosition])
        ifFalse: [
            ^self errorInBounds: anInteger].
    ^contents at: index!
remove: anObject ifAbsent: aBlock
        "Answer anObject.  Remove the element anObject from
         the receiver collection.  If anObject is not an
         element of the receiver, aBlock is evaluated
         (with no arguments)."
    | index |
    index := startPosition.
    [index <= endPosition]
        whileTrue: [
            anObject = (contents at: index)
                ifTrue: [
                    self removeIndex: index - startPosition + 1.
                    ^anObject].
            index := index + 1].
    ^aBlock value!
errorAbsentElement
        "Private - Produce a walkback to the effect
         that the desired object was not in the collection."
    ^self error:
        'attempt to access absent element'!  
includes: anObject
        "Answer true if the receiver contains an element
         equal to anObject, else answer false."
    | index |
    index := startPosition - 1.
    [(index := index + 1) > endPosition]
        whileFalse: [
            anObject = (contents at: index)
                ifTrue: [^true]].
    ^false!   
growTo: anInteger
        "Private - Answer the receiver expanded
         to accommodate anInteger number of elements."
    | aCollection |
    aCollection := Array new: anInteger.
    aCollection
        replaceFrom: startPosition
        to: endPosition
        with: contents
        startingAt: startPosition.
    contents := aCollection! 
removeLast
        "Remove and answer the last element of the receiver.
         If the collection is empty, report an error."
    | answer |
    startPosition > endPosition
        ifTrue: [^self errorAbsentElement].
    answer := contents at: endPosition.
    contents at: endPosition put: nil.
    endPosition := endPosition - 1.
    ^answer!
fromString: aString
        " Answer the point corresponding to aString. "
    | s x y |
    s := ReadStream on: aString trimBlanks.
    x := (s upTo: $@) asNumber.
    s atEnd ifTrue: [^nil].
    y := (s upTo: nil) trimBlanks asNumber.
    ^x @ y!   
= aPoint
        "Answer true if the x and y coordinates of the
         receiver are equal to the x and y coordinates
         of aPoint, respectively, else answer false."
    ^aPoint isPoint and: [ x = aPoint x and: [ y = aPoint y ] ]! 
leftAndDown: delta
        "Answer a new Point which is delta away from the
         receiver.  delta can be a number or a
         Point.  If it is a number, it is treated like a point
         with the same two coordinates. The new point
         is to the left and below the receiver."
    ^delta isPoint
        ifTrue: [ ( x left: delta x ) @ ( y down: delta y ) ]
        ifFalse: [ ( x left: delta ) @ ( y down: delta ) ]! 
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host procedure call."
    ^self asPointParameter! 
+ delta
        "Answer a new Point which is the sum of the
         receiver and delta.  Delta can be a number or a
         Point.  If delta is a Point, the x-coordinates
         are added and the y-coordinates are added."
    ^delta isPoint
        ifTrue: [ ( x + delta x ) @ ( y + delta y ) ]
        ifFalse: [ ( x + delta ) @ ( y + delta ) ]! 
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    (x isInteger or: [x isFloat])
        ifTrue: [x printOn: aStream]
        ifFalse: [
            aStream nextPut: $(.
            x printOn: aStream.
            aStream nextPut: $)].
    aStream nextPutAll: ' @ '.
    (y isInteger or: [y isFloat])
        ifTrue: [y printOn: aStream]
        ifFalse: [
            aStream nextPut: $(.
            y printOn: aStream.
            aStream nextPut: $)].
!
\\ scale
        "Answer a new Point which is the integer
         remainder of the receiver Point divided
         by scale.  Scale can be a number or a
         Point.  If scale is a Point, the x-coordinates
         are divided and the y-coordinates are divided."
    ^scale isPoint
        ifTrue: [ ( x \\ scale x ) @ ( y \\ scale y ) ]
        ifFalse: [ ( x \\ scale ) @ ( y \\ scale ) ]!   
transpose
        "Answer a Point with x-coordinate equal to the
         receiver's y-coordinate and y-coordinate equal
         to receiver's x-coordinate."
    ^y @ x!
mapFromWindow: aWindow
        "Map the receiver from aWindow's client-area coordinates
        to screen coordinates."
    ^self mapClientToScreen: aWindow!  
> aPoint
        "Answer true if the x and y coordinates of the
         receiver are greater than the x and y coordinates
         of aPoint, respectively, else answer false."
    ^(x > aPoint x) and: [self y > aPoint y]!
>= aPoint
        "Answer true if the x and y coordinates of the receiver
         are greater than or equal to the x and y coordinates of
         aPoint, respectively, else answer false."
    ^(aPoint x <= x) and: [aPoint y <= y]!  
rightAndUp: delta
        "Answer a new Point which is delta away from the
         receiver.  delta can be a number or a
         Point.  If it is a number, it is treated like a point
         with the same two coordinates. The new point
         is to the right and above the receiver."
    ^delta isPoint
        ifTrue: [ ( x right: delta x ) @ ( y up: delta y ) ]
        ifFalse: [ ( x right: delta ) @ ( y up: delta ) ]!   
abs
        "Answer a Point with coordinates that are the absolute
         value of the x and y coordinates of the receiver."
    ^x abs @ y abs! 
extent: aPoint
        "Answer a Rectangle with origin equal to the receiver
         and extent equal to aPoint."
    | p |
    p := aPoint isPoint ifTrue: [ aPoint ] ifFalse: [ aPoint @ aPoint ].
    ^Rectangle origin: self extent: p
!   
mapToScreen: aWindow
        "Map the receiver from aWindow's client-area coordinates
        to screen coordinates."
    ^self mapClientToScreen: aWindow!
hash
        "Answer the integer hash value of the receiver."
    ^x hash bitXor: y hash!   
rightMostAndLowest: aPoint
        "Answer a Point with the right-most x-coordinates
         and the bottom-most y-coordinates of the receiver
         and aPoint."
    ^(x rightMost: aPoint x) @ (y lowerOf: aPoint y)!   
truncateTo: truncatingBase
        "Answer the point whose x- and y-coordinates are
        the result of truncating the x- and y-coordinates of
        the receiver to the <truncatingBase>."
    ^( self x truncateTo: truncatingBase ) @ ( self y truncateTo: truncatingBase )!   
extentFromLeftTop: aPoint
        "Answer a Rectangle with left top corner equal to the receiver
         and extent equal to aPoint."
    ^Rectangle
        leftTop: self
        rightBottom: (self rightAndDown: aPoint)!
isBefore: aPoint
        "Answer true if receiver is text-wise earlier
         than aPoint, else answer false."
    ^aPoint y > y
        or: [aPoint y = y
            and: [aPoint x > x]]!   
moveBy: aPoint
        "Answer the receiver with its x-coordinate
         incremented by aPoint x and y-coordinate
         incremented by aPoint y."
    x := x + aPoint x.
    y := y + aPoint y! 
left: anInteger
        "Answer a new Point which is anInteger number of
         units to the left of the receiver."
    ^ (x left: anInteger) @  y!  
leftMostAndLowest: aPoint
        "Answer a Point with the left-most x-coordinates
         and the bottom-most y-coordinates of the receiver
         and aPoint."
    ^(x leftMost: aPoint x) @ (y lowerOf: aPoint y)!  
- delta
        "Answer a new Point which is the difference of the
         receiver and delta.  delta can be a number or a
         Point.  If delta is a Point, the x-coordinates are
         subtracted and the y-coordinates are subtracted."
    ^delta isPoint
        ifTrue: [ ( x - delta x ) @ ( y - delta y ) ]
        ifFalse: [ ( x - delta ) @ ( y - delta ) ]!
mapFromWindow: fromWindow to: toWindow
        "Answer a rectangle which is the receiver converted from
         one window coordinate to another."
    ^(self mapToScreen: fromWindow) mapToWindow: toWindow! 
negated
        "Answer a Point with the x and y coordinates of
         the receiver negated."
    ^x negated @ y negated!
extentFromLeftBottom: aPoint
        "Answer a Rectangle whose origin is the receiver
         at the bottom-left corner and extent is aPoint."
    ^Rectangle
        leftTop: (self x @ (self y up: aPoint y))
        rightBottom: ((self x right: aPoint x) @ self y)!   
between: aPoint and: bPoint
        "Answer true if the receiver is greater than or equal to
         aPoint and less than or equal to aPoint, else
         answer false."
    ^aPoint <= self
        and: [self <= bPoint]!   
rightMostAndHighest: aPoint
        "Answer a Point with the right-most x-coordinates
         and the bottom-most y-coordinates of the receiver
         and aPoint."
    ^(x rightMost: aPoint x) @ (y higherOf: aPoint y)! 
mapToWindow: aWindow
        "Map the receiver from screen coordinates to
         client-area coordinates. Retained for compatibility."
    ^self mapScreenToClient: aWindow! 
corner: aPoint
        "Answer a Rectangle with origin equal to the receiver
         and corner equal to aPoint."
    ^Rectangle origin: self corner: aPoint! 
isRightAndAbove: aPoint
        "Answer true if the x and y coordinates of the
         receiver are above and to the right of the x and y coordinates
         of aPoint, respectively, else answer false."
    ^(x isRightOf: aPoint x) and: [self y isAbove: aPoint y]!
dotProduct: aPoint
        "Answer a number which is the sum of the product
         of the x-coordinates and the product of the
         y-coordinates of the receiver and aPoint."
    ^(x * aPoint x) + (y * aPoint y)!
isLeftAndAbove: aPoint
        "Answer true if the x and y coordinates of the
         receiver are above and to the left of the x and y coordinates
         of aPoint, respectively, else answer false."
    ^(x isLeftOf: aPoint x) and: [y isAbove: aPoint y]!
isLeftAndBelow: aPoint
        "Answer true if the x and y coordinates of the
         receiver are below and to the left of the x and y coordinates
         of aPoint, respectively, else answer false."
    ^(x isLeftOf: aPoint x) and: [y isBelow: aPoint y]!
truncated
        "Answer a Point which has the receiver coordinates
         truncated to integers."
    ^x truncated @ y truncated!  
leftMostAndHighest: aPoint
        "Answer a Point with the left-most x-coordinates
         and the top-most y-coordinates of the receiver
         and aPoint."
    ^(x leftMost: aPoint x) @ (y higherOf: aPoint y)!   
rightAndDown: delta
        "Answer a new Point which is delta away from the
         receiver.  delta can be a number or a
         Point.  If it is a number, it is treated like a point
         with the same two coordinates. The new point
         is to the right and below the receiver."
    ^delta isPoint
        ifTrue: [ ( x right: delta x ) @ ( y down: delta y ) ]
        ifFalse: [ ( x right: delta ) @ ( y down: delta ) ]! 
rightBottom: aPoint
        "Answer a Rectangle with topLeft equal to the receiver
         and bottomRight equal to aPoint."
    ^Rectangle leftTop: self rightBottom: aPoint!
right: anInteger
        "Answer a new Point which is anInteger number of
         units to the right of the receiver."
    ^ (x right: anInteger) @  y!   
up: anInteger
        "Answer a new Point which is anInteger number of
         units above the receiver."
    ^ x @ ( y up: anInteger)!   
x
        "Answer the receiver's x-coordinate."
    ^x! 
x: aNumber
        "Answer the receiver.  Set the receiver's
         x-coordinate to aNumber."
    x := aNumber!  
/ scale
        "Answer a new Point which is the receiver Point
         divided by scale.  Scale can be a number or a
         Point.  If scale is a Point, the x-coordinates
         are divided and the y-coordinates are divided."
    ^scale isPoint
        ifTrue: [ ( x / scale x ) @ ( y / scale y ) ]
        ifFalse: [ ( x / scale ) @ ( y / scale ) ]!   
// scale
        "Answer a new Point which is the receiver Point
         divided by scale.  Scale can be a number or a
         Point.  If scale is a Point, the x-coordinates
         are divided and the y-coordinates are divided."
    ^scale isPoint
        ifTrue: [ ( x // scale x ) @ ( y // scale y ) ]
        ifFalse: [ ( x // scale ) @ ( y // scale ) ]!  
asPoint
        "Answer the receiver."
    ^self!   
isRightAndBelow: aPoint
        "Answer true if the x and y coordinates of the
         receiver are below and to the right of the x and y coordinates
         of aPoint, respectively, else answer false."
    ^(x isRightOf: aPoint x) and: [y isBelow: aPoint y]! 
down: anInteger
        "Answer a new Point which is anInteger number of
         units below the receiver."
    ^ x @ ( y down: anInteger)!   
rightTop: aPoint
        "Answer a Rectangle with left bottom equal to the receiver
         and right top equal to aPoint."
    ^Rectangle leftBottom: self rightTop: aPoint! 
isPoint
        "Answer true if receiver is a kind of Point."
    ^true!
rounded
        "Answer a Point which has the receiver coordinates
         rounded to integers."
    ^x rounded @ y rounded!  
< aPoint
        "Answer true if the x and y coordinates of the receiver
         are less than the x and y coordinates of aPoint,
         respectively, else answer false."
    ^(x < aPoint x) and: [y < aPoint y]!
<= aPoint
        "Answer true if the x and y coordinates of the
         receiver are less than or equal to the x and y
         coordinates of aPoint, respectively, else
         answer false."
    ^(x <= aPoint x) and: [y <= aPoint y]!   
y
        "Answer the receiver's y-coordinate."
    ^y! 
y: aNumber
        "Answer the receiver.  Set the receiver's
         y-coordinate to aNumber."
    y := aNumber!  
leftAndUp: delta
        "Answer a new Point which is delta away from the
         receiver.  delta can be a number or a
         Point.  If it is a number, it is treated like a point
         with the same two coordinates. The new point
         is to the left and above the receiver."
    ^delta isPoint
        ifTrue: [ ( x left: delta x ) @ ( y up: delta y ) ]
        ifFalse: [ ( x left: delta ) @ ( y up: delta ) ]!   
max: aPoint
        "Answer a Point with the maximum of the x-coordinates
         and the maximum of the y-coordinates of the receiver
         and aPoint."
    ^(x max: aPoint x) @ (y max: aPoint y)! 
* scale
        "Answer a new Point which is the product of
         the receiver and scale.  Scale can be a
         number or a Point.  If scale is a Point, the
         x-coordinates are multiplied and the
         y-coordinates are multiplied."
    ^scale isPoint
        ifTrue: [ ( x * scale x ) @ ( y * scale y ) ]
        ifFalse: [ ( x * scale ) @ ( y * scale ) ]! 
min: aPoint
        "Answer a Point with the minimum of the x-coordinates
         and the minimum of the y-coordinates of the receiver
         and aPoint."
    ^(x min: aPoint x) @ (y min: aPoint y)! 
windowTitleBarHeight
        "Answer the default height of a title bar."
    ^self getSystemValue: SystemValueTitleBarHeight!   
frameOffset
        "Private - Answer the stack frame offset."
    ^( frameOffset asUnsigned * 2  )
        bitAnd: 16rFFFFFFFF!   
frameOffset: anInteger
        "Private - Change the stack frame offset
        to anInteger."
    frameOffset := ( anInteger isNil
        ifTrue: [ nil ]
        ifFalse: [ anInteger negated // 2 ] )!   
asActionSequence
        "Answer the receiver as an element of an ActionSequence."
    ^self invalidMessage!
method
        "Private - Answer the receiver's method."
    ^method!   
method: aMethod
        "Private - Set the receiver's method."
    method := aMethod!   
receiver
        "Answer the receiver of the message that created the receiver."
    ^receiver! 
isContext
        "Private - Answer whether the receiver isKindOf Context."
    ^true!  
numberOfArguments
        "Answer the number of arguments expected by the
         receiver; reimplemented by subclasses."
    ^self implementedBySubclass!
homeContext
        "Private - Answer the homeContext."
    ^homeContext!   
asActionSequence
        "Answer the receiver as an element of an ActionSequence."
    ^ActionSequence with: self!  
receiver
        "Answer the receiver of the message that created the receiver."
    ^self homeContext receiver!
argumentCount
        "Answer the number of arguments expected by the receiver."
    ^self numberOfArguments!   
validateNumberOfArguments: anInteger
        "Private - indicate an error if anInteger is an inappropriate
         number of arguments for the receiver."
    anInteger ~= self numberOfArguments
        ifTrue: [ self invalidArgumentCount: anInteger ].! 
whileFalse
        "Repeatedly evaluate the receiver until the receiver
        evaluates to <true>. Answer <nil>."
    ^[ self value ] whileFalse: [ ]!   
whileTrue
        "Repeatedly evaluate the receiver until the receiver
        evaluates to <false>. Answer <nil>."
    ^[ self value ] whileTrue: [ ]!
invalidArgumentCount: argCount
        "Private - display an error message indicating that the
         receiver does not support the given number of arguments."
    ^self error: self class printString,
        ' did not expect ', argCount printString, ' arguments'!
maximumExtensionLength
    "Answer the maximum length of the extension portion of a file name."

    ^3!   
binder: aBinder shapeInfo: anAssoc
	"Signal that aBinder encountered a class shape mismatch."

    ^self new
		binder: aBinder;
		shapeInfo: anAssoc;
		signal! 
binder: aBinder text: aString
	"Signal that aBinder encountered an error
	while binding."

    ^self new
		binder: aBinder;
		messageText: aString;
		signal!  
copyFrom: srcObject to: destObject count: bytes
        "Private - Copy bytes from srcObject to destObject. srcObject
         and destObject must be either aVariableByteObject or
         anAddress."
    ^destObject replace: bytes with: srcObject.! 
initialize
        "Private - cache a null value of this class."
    nullValue := self new! 
defaultMemoryClassThreshold
        "Private - answer a number representing the number of
         bytes which is the cutoff between suballocated and
         globally allocated memory."
    ^16r2000!  
copyToNonSmalltalkMemory: aVariableByteObject
        "Copy aVariableByteObject to allocated host memory
        and answer the address of that memory."
    | address bytes extra memoryClass |
    bytes := aVariableByteObject isDoubleByteString
        ifTrue: [ aVariableByteObject basicSize ]
        ifFalse: [ aVariableByteObject size ].
    memoryClass := ( self defaultMemoryClass: bytes ).
    aVariableByteObject isNil ifTrue:  [ ^memoryClass new ].
    extra := aVariableByteObject isString ifTrue: [ 1 ] ifFalse: [ 0 ].
    address := memoryClass allocateMemory: bytes + extra.
    address
        at: bytes + extra put: 0;
        replaceBytes: bytes with: aVariableByteObject.
   ^address!   
copyToNonSmalltalkMemoryZ: aVariableByteObject
        "Private - Copy aVariableByteObject plus a zero byte
         at the end to allocated memory
         and answer the address of that memory."
    | zObject |
    zObject := aVariableByteObject isString
        ifTrue: [ (aVariableByteObject copyWith: 0 asCharacter) asExternalString ]
        ifFalse: [ aVariableByteObject copyWith: 0 ].
    ^self copyToNonSmalltalkMemory: zObject!
allocateMemory: size
        "Allocate size number of bytes in host memory.
         Answer an Address for the allocated memory."
    ^( self defaultMemoryClass: size ) allocateMemory: size! 
nullValue
        "Answer an instance of the receiver class which represents
        an invalid (uninitialized) value."
    ^nullValue!
defaultMemoryClass: numberOfBytes
        "Private - answer the class of memory object which should
         be used to satisfy allocation request of size numberOfBytes.
         If it is 'small', use suballocated memory to save wasted
         storage, otherwise just use global memory."
    self == ExternalAddress ifFalse: [ ^self ].
    ^numberOfBytes < self defaultMemoryClassThreshold
        ifTrue: [ ExternalHeapAddress ]
        ifFalse: [ ExternalGlobalAddress ]!
checkGlobalAddress
        "Private - indicate an error to the user if the receiver class
         to which the memory request is being made is neither
         ExternalAddress nor ExternalGlobalAddress."
    ( self == ExternalAddress or: [ self == ExternalGlobalAddress ] )
        ifFalse: [ ^self invalidMessage ]!
lowHalf: anInteger1 highHalf: anInteger2
        "Answer an instance of the receiver whose
         low half is anInteger1 and whose high half
         is anInteger2."
    ^self new
        lowHalf:  anInteger1;
        highHalf: anInteger2;
        yourself!
integerFrom: aString
        "Answer the Integer contained in aString.
         This method can be used to convert a ULong return parameter
         (returned as a 4 byte String) to an Integer."
    | total i |
    total := 0.
    i := aString size + 1.
    [(i := i - 1) > 0] whileTrue: [
      total:= (total * 256)
                  + (aString at: i)asciiValue].
    ^total!   
fromString: aString
        "Answer the receiver converted from the 4-byte aString.
        This method can be used to convert a ULong return parameter
        (returned as a 4 byte String) to an ExternalLong."
    | winLong |
    winLong := self new.
    winLong contents
        replaceFrom: 1
        to: 4
        with: aString
        startingAt: 1.
   ^winLong!
hiWordFrom: aString
        "Answer the high word of aString
         which must be 4 characters long."
    | answer|
    aString size = 4 ifTrue: [
          answer:=  (aString at: 4) asciiValue * 256
          + (aString at: 3) asciiValue. ].
    ^ answer.!
sizeInBytes
         "Private - Answer the default size in bytes."
    ^4!  
loWordFrom: aString
        "Answer the low word of aString
         which must be 4 characters long."
    | answer|
    aString size = 4 ifTrue: [
          answer:=  (aString at: 2) asciiValue * 256
          + (aString at: 1) asciiValue ].
    ^ answer.!  
fromUnsignedInteger: anInteger
        "Answer a new instance of the receiver with value <anInteger>
        in ULONG format of a 4-byte unsigned integer."
    ^self new
        uLongAtOffset: 0 put: anInteger;
        yourself! 
= anAddress
        "Private - answer whether the receiver represents the
         same memory location as anAddress."
    ^ self class == anAddress class and: [ self contents = anAddress contents ]!
replaceBytesFrom: byteStart
    to: byteStop
    with: aVariableByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aVariableByteObject beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 80>
    index2 := byteRepStart.
    index1 := byteStart.
    [index1 <= byteStop]
        whileTrue: [
            self   " must use basicAt: so DoubleByteString parm handled properly "
                at: index1
                put: (aVariableByteObject basicAt: index2) asInteger.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a host system procedure call."
    ^contents !  
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream."
    | address |
    aStream nextPutAll: self class name, '{'.
	address := ( self isValid
		ifTrue: [ self asInteger printPaddedWith: $0 to: 8 base: 16 ]
		ifFalse: [ 'invalid' ] ).
    aStream nextPutAll: address.
    aStream nextPut: $}!   
finalize
	"The receiver is no longer referenced by any object in the system and is about to be destroyed.
	Free the memory referenced by the receiver, if appropriate."

	^self release!  
atAddr: anInteger
        "Private - answer the byte at the zero relative offset anInteger
        from the receiver."
    <primitive: 15>
    ^self primitiveFailed! 
asExternalAddress
        "Answer the receiver as an ExternalAddress."
    ^self!   
asFlatAddress
        "Answer a 32 bit flat memory model address which refers to the
        same memory location as the receiver."
    ^self! 
releaseMemory
        "Private - Release the memory at the receiver's address, if apporpriate.  For ExternalAddress do nothing.  Subclasses that can release memory will override this method"
	!   
copyFrom: start to: stop
        "Answer a new collection containing the elements
         of the receiver indexed from start through stop."
    | size |
    size := stop - start + 1.
    ^(ByteArray new: size)
        replaceFrom: 1
        to: size
        with: self
        startingAt: start; yourself!   
hash
        "Private - Answer the integer hash of the receiver."
    ^contents hash!   
isExternalAddress
        "Answer whether the receiver is an instance
         of class ExternalAddress or one of its subclasses."
    ^true!  
replace: count with: aCollection
        "Replace count elements of the receiver
         with elements of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    <primitive: 79>
    (aCollection isDoubleByteString)
        ifTrue: [
            ^self replaceBytes: count with: aCollection].
    ^self primitiveFailed!   
finalizationRegistry
    "Private - Answer the WeakRegistry to be used for finalizing instances of the receiver."

    ^SystemWeakRegistries externalResources!
isValid
        "Answer whether the receiver is a valid (non-NULL) address."
    ^self ~= self class nullValue! 
at: anInteger put: aByte
        "Replace the byte at index position anInteger 
         in the memory addressed by the receiver with
         aByte."
    ^self atAddr: anInteger - 1 put: aByte!
atAddr: anInteger put: aByte
        "Private - set the byte at the zero relative offset anInteger
        in the receiver to aByte."
    <primitive: 16>
    ^self primitiveFailed!  
asInteger
        "Answer the receiver as an large positive integer."
    ^self asUnsignedInteger!  
at: anInteger
        "Answer the byte at index position anInteger
         in the memory addressed by the receiver."
    ^self atAddr: anInteger - 1! 
release
	"Release the memory at the receiver's address."

	self releaseMemory.
	self invalidate!  
replaceBytes: count with: aCollection
        "Private - replace count bytes of the receiver
         with bytes of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    <primitive: 81>
    ^self primitiveFailed!  
invalidate
		"Set the receiver to be invalid."

	self initialSize: self class sizeInBytes! 
asSegmentedAddress
        "Answer a 16:16 address from the 0:32 receiver"
    ^ExternalSegmentedAddress fromFlatAddress: self! 
replaceFrom: start
    to: stop
    with: aString
    startingAt: repStart
        "Private - Replace the bytes of the receiver at index
         positions start through stop with consecutive
         characters of aString beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 105>
    (aString isDoubleByteString)
        ifTrue: [
            ^self
                replaceBytesFrom: start to: stop
                with: aString
                startingAt: (aString byteIndexOfCharAt: repStart)].
    index2 := repStart.
    index1 := start.
    [index1 <= stop]
        whileTrue: [
            self
                at: index1
                put: (aString at: index2) asInteger.
            index1 := index1 + 1.
            index2 := index2 + 1]!  
startingSession
	"Private - Starting a session, clear handle."

	self invalidate!  
free
        "Free the receiver."
    self release.
	self doesNotNeedFinalization.!
asExternalGlobalAddress
        "Answer the receiver as an ExternalGlobalAddress."
    ^ExternalGlobalAddress fromBytes: contents!  
+ aNumber
        "Answer a new instance of the receiver which
         holds the sum of the receiver and aNumber."
    ^self class fromInteger: ( self asInteger + aNumber ).
!  
highHalf
        "Private - Answer the high half word."
    ^self uShortAtOffset: 2!
asExternalLong
        "Answer the receiver as an ExternalLong."
    ^self! 
highHalf: anInteger
        "Private - Set the high half word."
    self uShortAtOffset: 2 put: anInteger!  
printOn: aStream
        "Append a text representation of the receiver to aStream."
    aStream nextPutAll: self class name, ': ', self asInteger printString!  
lowHalf
        "Private - Answer the low half word."
    ^self uShortAtOffset: 0!  
lowHalf: anInteger
        "Private - Set the low half word."
    self uShortAtOffset: 0 put: anInteger!
- anInteger
        "Answer a copy of the receiver with bytes that represent
        the value anInteger less than the receiver."
    ^self class fromInteger: self asInteger - anInteger! 
asInteger
        "Answer the receiver as an integer.
        If the high bit is on a negative number is returned."
    ^self longAtOffset: 0! 
asExternalAddress
        "Answer the receiver as an ExternalAddress."
    ^ExternalAddress fromBytes: contents!
asUnsignedInteger
        "Answer the receiver as a positive integer."
    ^self uLongAtOffset: 0!  
asBoolean
        "Private - Answer the receiver as a boolean."
    ^(self asInteger ~= 0).!
currencyFormat
        "Answer the current system value for currency format."
    currencyFormat isNil
        ifTrue: [ currencyFormat := self queryNationalProfileInt: 'iCurrency' default: 0 ].
    ^currencyFormat!   
exit
    <api: DLLapiExit16 ushort>
    ^self invalidArgument!  
setupMutators
        "Private - answer a collection of mutators for the receiver and
        all its subclasses."
	| muts |
	muts := OrderedCollection new:50.
	muts add: (ObjectMutator from: self).
	self subclasses do: [:sub|
		muts addAll: (sub setupMutators)].
	^muts!   
open: aString
        "Answer an instance of the receiver which refers
         to the Dynamic Link Library named aString."
    | answer |
    ( answer := KernelLibrary loadLibrary: aString asParameter ) = 0
        ifTrue: [ ^self osError ].
   ^self fromInteger: answer!
open: create
attributes: attributes
	"Open the file with a new file handle."

	self isOpen
		ifTrue: [self close].
	self
		fileId:
			(FileHandle
				open: self name
				in: self directory
				access: GenericRead | GenericWrite
				share: FileShareRead | FileShareWrite
				create: create
				attributes: attributes)!   
removeActionsSatisfying: aOneArgBlock forEvent: aSymbol
        "Remove all actions for the event <aSymbol> that satisfy <aOneArgBlock>."
    self
        setActionList:
            ((self actionListForEvent: aSymbol)
                reject: [:anAction | aOneArgBlock value: anAction])
        forEvent: aSymbol!
volumeLabel
        "Answer the volume label of the disk
         containing the receiver."
    | volName |
    volName := String new: 255.
    ( KernelLibrary
        getVolumeInformation: (self fileSystemLocator volumePath printString) asParameter
        name: volName
        nameSize: volName size
        serialNumber: nil
        maximumComponentLength: nil
        fileSystemFlags: nil
        fileSystemName: nil
        fileSystemNameSize: nil )
            ifFalse: [ self osNotification ].
    ^volName trimNullTerminator asNormalizedString!  
copyToExternalMemory
        "Copy the receiver to external (non-Smalltalk) memory,
        and answer an instance of ExternalAddress."
    ^ExternalAddress copyToNonSmalltalkMemory: self asParameter!   
signal: messageText
hostErrorCode: errorCode
    "Signal that the exception represented by the receiver has occurred; create an instance to represent this specific occurrence. Associate the <messageText>, <fileSystemEntity> and host <errorCode> with the occurrence."

    | exception |
    exception := self new.
    exception messageText: messageText.
    exception hostErrorCode: errorCode.
    exception signal!
signal: messageText
with: fileSystemEntity
    "Signal that the exception represented by the receiver has occurred; create an instance to represent this specific occurrence. Associate the <messageText> and <fileSystemEntity> with the occurrence."

    | exception |
    exception := self new.
    exception messageText: messageText.
    exception entity: fileSystemEntity.
    exception signal!
signal: messageText
with: fileSystemEntity
hostErrorCode: errorCode
    "Signal that the exception represented by the receiver has occurred; create an instance to represent this specific occurrence. Associate the <messageText>, <fileSystemEntity> and host <errorCode> with the occurrence."

    | exception |
    exception := self new.
    exception messageText: messageText.
    exception entity: fileSystemEntity.
    exception hostErrorCode: errorCode.
    exception signal!   
hostErrorCode
    "Answer the platform-dependent error code that caused the receiver to be generated."

    ^hostErrorCode!
entity: fileSystemEntity
    "Private"
    "Associate the <fileSystemEntity> with the receiver."

    entity := fileSystemEntity! 
hostErrorCode: errorCode
    "Private"
    "Set the platform-dependent error code that caused the receiver to be generated to be the given <errorCode>."

    hostErrorCode := errorCode! 
entity
    "Answer the file system entity that was associated with the error. This is typically the receiver of the original request."

    ^entity!   
openReadOnly: aString in: aDirectory
        "Open the file named aString with read only access in aDirectory;
        the file must already exist; answer the file handle."
    ^self
        open: aString
        in: aDirectory
        access: GenericRead
        share: FileShareRead | FileShareWrite
        create: OpenExisting
        attributes: FileAttributeNormal
!
release
        "Perform any actions required before the receiver becomes
        unreferenceable."
    self releaseEventTable!
isResidueOrNil
	"Answer true since the receiver is nil."

	^true!  
hInstanceExe
        "Private - Answer the hInstance of the executing
         application."
    ^hInstanceExe!
creationTime
    "Answer a TimeStamp of the date and time at which the receiver was created."

    ^self lastModificationTime! 
frameIndexAt: walkbackFrame
        "Private - Answer the process index of the frameIndex + 1 stack frame."
    | processIndex nextFrame |
    processIndex := self topFrame.
    walkbackFrame timesRepeat: [
    nextFrame := self nextFrameFrom: processIndex.
    processIndex = nextFrame
        ifTrue: [
        self error: 'End of stack frame chain'].
    processIndex := nextFrame].
    ^processIndex!
evaluateFor: anObject
        "Evaluate the receiver, passing anObject as the evaluation argument."
    ^self evaluateWithArguments: ( Array with: anObject )!  
numberOfArguments
        "Answer the number of arguments expected by the
         receiver."
    ^1!  
evaluate
        "Indicate an error, since the receiver does not expect
        0 arguments."
    ^self invalidArgumentCount: 0!   
evaluateWithArguments: argumentArray
        "Evaluate the receiver with the elements of the <argumentArray>
        as the argument values.  Error Conditions: If the number of
        arguments required by the receiver is different from the size
        of the argument array, send the message #invalidArgumentCount:
        to the receiver with the number of arguments provided as the
        argument."
    self validateNumberOfArguments: argumentArray size.
    ^self value: ( argumentArray at: 1 )!   
value: anObject
        "Answer the result of evaluating the one argument block
         described by the receiver."
    <primitive: 39>!  
entityName
        "Answer the name of the entity which was last found during a search."
	^self findData cFileName! 
new
	"This method is invalid since only one instance of the receiver is ever needed."
	^self invalidMessage!
startUp
	"Private - Register the special instance of the receiver as the object to which 
	all garbage collected weak references are transformed."

	VirtualMachineLibrary registerResidue: self residue! 
residue
	"Answer the instance of the receiver to use as the distinguished object: residue. 
	Create it if necessary."

	residue isNil
		ifTrue: [ residue := self basicNew ].
   ^residue!  
isResidueOrNil
	"Answer true since the receiver is the distiguished object: residue"

	^true!  
isResidue
	"Answer true since the receiver is the distiguished object: residue"

	^true!   
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^Set with: #changed! 
pathNameReadOnly: aString
        "Answer a read only FileStream with path name aString."
    ^self pathNameReadOnly: aString in: Disk! 
drive: drive path: path file: fileName
        "Answer the full path name of the file name."
    ^(String with: drive with: $:),
        path,
        (path last == $\
            ifTrue: [fileName]
            ifFalse: [(String with: $\), fileName]).!
isCDROM
		"Answer whether the receiver is a CD-ROM drive."
    ^self getDriveType = DriveCdrom! 
file: aString attribute: anAttr mode: aMode 
        "Answer a FileStream for the file named 
         aString in the receiver directory with attribute anAttr 
         and aMode as the file open mode. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details.  If the file 
         does not exist, it will be created." 

    ^FileStream on: (File open: aString in: self 
        attribute: anAttr mode: aMode)! 
new
        "Private - Disallow the instantiation
         of booleans because there is only one
         true and one false."
    ^self invalidMessage!  
new: anInteger
        "Private - Disallow the instantiation
         of booleans because there is only one
         true and one false."
    ^self invalidMessage!   
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable.  Because
         there is only one true and  one false,
         answer the receiver."
    ^self!   
isBoolean
        "Answer true if receiver is a kind of Boolean."
    ^true!
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    aStream nextPutAll:
        (self
            ifTrue: ['true']
            ifFalse:['false'])!  
storeOn: aStream
        "Answer the receiver.  Append the character
         sequence of the receiver to aStream from
         which the receiver can be reconstructed."
    self printOn: aStream!  
asBoolean
        "Answer the receiver."
    ^self! 
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver instance variables.  Because
         there is only one true and one false, answer
         the receiver."
    ^self!  
broadcast: aSymbol with: anObject
        "Send the argument aSymbol as a keyword message with
         argument anObject to all of the receiver's dependents."
    self dependents do: [ :dependent |
        dependent perform: aSymbol with: anObject]!
mount
        "Mount the volume represented by the receiver.  If the volume is already
        mounted, do nothing."
    self isMounted
        ifFalse: [ self cannotBeMounted.].!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
new: anInteger
        "Answer an instance of the receiver."
    ^self new! 
do: aBlock
        "For each element in the receiver, evaluate
         aBlock with that element as the argument."
    | value |
    elements associationsDo: [ :association |
        value := association value.
        [value > 0]
            whileTrue: [
                aBlock value: association key.
                value := value - 1]]! 
at: anInteger put: anObject
        "Replace the element of the receiver at index
         position anInteger with anObject.  Report an
         error, since bags are not indexable."
    self errorNotIndexable!
occurrencesOf: anObject
        "Answer the number of elements of
         the receiver equal to anObject."
    ^elements at: anObject ifAbsent: [^0]! 
initialize
        "Private - initialize the receiver to be empty."
    elements := Dictionary new! 
add: anObject
        "Answer anObject.  Add anObject
         to the elements of the receiver."
    elements
        at: anObject
        put: (self occurrencesOf: anObject) + 1.
    ^anObject!  
at: anInteger
        "Answer the element of the receiver at index
         position anInteger.  Report an error since
         bags are not indexable."
    self errorNotIndexable!  
remove: anObject ifAbsent: aBlock
        "Answer anObject.  Remove one occurrence of
         anObject from the receiver collection.  If
         anObject is not an element of the receiver,
         evaluate aBlock (with no arguments)."
    | occurrences |
    (occurrences := elements
        at: anObject
        ifAbsent: [^aBlock value]) = 1
            ifTrue: [elements removeKey: anObject]
            ifFalse: [
                elements at: anObject
                put: occurrences - 1].
    ^anObject! 
size
        "Answer the number of elements
         in the receiver collection."
    | answer |
    answer := 0.
    elements associationsDo: [ :element |
        answer := answer + element value].
    ^answer!
asBag
        "Answer a Bag containing the
         elements of the receiver."
    ^self!  
elements
        "Answer elements in the receiver."
    ^elements!  
add: anObject withOccurrences: anInteger
        "Answer anObject.  Add anObject to the elements
         of the receiver anInteger number of times."
    elements
        at: anObject
        put: (elements at: anObject ifAbsent: [0])
            + anInteger.
    ^anObject! 
includes: anObject
        "Answer true if the receiver contains an
         element equal to anObject, else answer false."
    elements at: anObject ifAbsent: [^false].
    ^true!  
at: key put: element
	"Associate the element with the key. For Visualworks compatability,
	symbol keys are converted to strings."

	self add: (self associationClass key: key asString value: element).
	^element!   
at: key ifAbsent: exceptionBlock
	"Answer the value associated with the key. If the index is
	not valid for the receiver, answer the result of evaluating
	the exceptionBlock."

	^self contents
		lookUpValue: key asString
		for: self
		ifAbsent: exceptionBlock!  
includesKey: key
	"Answer true if the receiver contains aKey, else answer false."

	^(self contents lookUpKey: key asString for: self) notNil! 
add: anAssociation
	"Add anAssociation to the receiver. Answer anAssociation.
	To ease porting of code developed using VisualWorks the use of
	a symbol as pool key is reported as an error"

	anAssociation key isSymbol
		ifTrue: [self error: 'Pool dictionary keys must be strings'].
	^super add: anAssociation!  
at: key
	"Answer the value of the key/value pair whose key equals
	key from the receiver.  If  not found, report an error."

	^self contents lookUpValue: key asString for: self! 
removeKey: key ifAbsent: exceptionBlock
	"Remove the association between the key and any value associated with it from
	the receiver. If the receiver does not associate any value with the key,  answer
	the result of evaluating the exceptionBlock."

	self contents
		removeKey: key asString
		for: self
		ifAbsent: [^exceptionBlock value].
	self decrementElementCount.
	^key!  
splitPath: aString in: aDirectory
        "Private - Answer an array of three elements,
         the first is the device character or network name
         string, the second is the directory path and
         the third is the file name."
    | startPathIndex startFilenameIndex str drive dirString fileString |
    str := aString trimBlanks.
    startPathIndex := 0.
    ( str size >= 2 )                        "Check for drive or network name"
        ifTrue: [
            ( (str at: 2) = $: )
                ifTrue: [                    "Copy drive letter (A:)"
                    drive := str first.
                    startPathIndex := 2.
                ]
                ifFalse: [
                    startPathIndex := self lengthOfNetworkNameIn: str.
                    (startPathIndex > 0)         "Copy network name (\\SRV\RES)"
                        ifTrue: [ drive := str copyFrom: 1 to: startPathIndex ].
                ].
        ].
   startPathIndex := startPathIndex + 1.
    ( startPathIndex <= str size )
        ifTrue: [
            startFilenameIndex := self indexOfFilenameIn: str.
            ( startFilenameIndex = 0 )
                 ifTrue: [
                                                              "Entire str is path specification"
                    dirString := str copyFrom: startPathIndex to: str size.
                ]
                ifFalse: [
                    (startFilenameIndex > startPathIndex)     "Copy path (if any), then filename"
                        ifTrue: [ dirString := str copyFrom: startPathIndex to: startFilenameIndex - 1 ].
                    ( startFilenameIndex <= str size )
                        ifTrue: [ fileString := str copyFrom: startFilenameIndex to: str size ].
                ].
        ].
    "Now fill in any missing data with defaults from aDirectory"
    ( drive isNil )                                                 "No drive explicitly specified"
        ifTrue: [ drive := aDirectory drive ].
    ( dirString isNil )                                          "No path explicitly specified"
        ifTrue: [
            ( drive = aDirectory drive )
                ifTrue:  [ dirString := aDirectory pathName ]
                ifFalse: [ dirString := String new ].
        ]
        ifFalse: [
            ( (('/\' includes: dirString first) not) & (drive = aDirectory drive) )
                ifTrue: [                                              "Fill in relative path information"
                    ( aDirectory pathName notEmpty and: [ '/\' includes: aDirectory pathName last ] )
                        ifTrue: [ dirString := aDirectory pathName, dirString ]
                        ifFalse: [ dirString := aDirectory pathName, (String with: $\), dirString ].
                ].
        ].
    ( (dirString size > 0) and: [ '/\' includes: dirString last ] )
         "Remove trailing $\ from path"
        ifTrue: [ dirString := dirString copyFrom: 1 to: dirString size - 1 ].
    ( fileString isNil )
         ifTrue: [ fileString := String new ].

    ^Array
        with: drive
        with: dirString
        with: fileString trimBlanks.!   
defaultAction
        "Default action for Notification exceptions is to do nothing."
    ^self! 
isResumable
        "Return true if this is a resumable exception."
    ^true!  
ofExpectedType: aType forArgumentNumber: index
	"Private - Set the receiver's instance variables."

	^self new setExpectedType: aType argumentNumber: index!   
messageText
	"Answer the message text associated with this exception."

	^'Invalid argument #', argumentNumber printString, '. Expected #', expectedType!  
setExpectedType: aType argumentNumber: index
	"Private - Set the receiver's instance variables."

	expectedType := aType.
	argumentNumber := index!   
bytesTenured
		"Answer the number of bytes tenured during the last
		flip or compact."
	^bytesTenured! 
terminateActive
        "Terminate the active process."
    Process enableInterrupts: false.
    self suspendActive.!  
oldSpaceThresholdIncrement
        "Private - Answer the amount by which the oldSpaceThreshold
         is kept above the number of oldSpacePages."
    ^OldSpaceThresholdIncrement!   
lowPriority
        "Answer the priority for a user process to be run
         when the user interface process is waiting."
    ^2!
printStatusOn: aStream
        "Print the current status of the receiver on <aStream>."
    | readyQueues queue |
    aStream nextPutAll: 'Processor Status'; cr; cr.
    readyQueues := self readyToRun.
    1 to: readyQueues size
        do:
            [:priority |
            aStream nextPutAll: priority printString.
            queue := readyQueues at: priority.
            queue isEmpty
                ifTrue: [aStream tab; nextPutAll: '<none>'; cr].
            queue
                do:
                    [:process |
                    aStream tab.
                    process printOn: aStream.
                    aStream cr]]! 
schedule: process
        "Private - add the <process> to the queue of runnable processes."
    | queue |
    queue := self readyToRun at: process priority.
    queue addLast: process!  
flip
        "Private - a scavenge event has occurred, check
        memory for trouble or panic."
    | finalizerInterface |
    self rebalance.
    ( finalizerInterface := self class finalizerInterface ) notNil
        ifTrue: [ finalizerInterface flip ].
    self triggerEvent: #flip!
readyToRun
        "Answer the receiver's OrderedCollection of ready to run processes."
    ^readyProcesses!
topPriority
        "Answer the highest allowable priority for any process."
    ^7!
unschedule: process
        "Private - if the <process> is in the queue of runnable
        processes, remove it."
    | queue |
    queue := self readyToRun at: process priority.
    queue remove: process ifAbsent: []!  
newSpacePages
		"Answer the number of pages consumed by new space."
	^newSpacePages!
oldSpacePages
		"Answer the number of pages consumed by old space."
	^oldSpacePages!
oldSpaceThresholdIncrement: anInteger
        "Private - Set the amount by which the oldSpaceThreshold
         is kept above the number of oldSpacePages."
    | prev |
    prev := OldSpaceThresholdIncrement.
    OldSpaceThresholdIncrement := anInteger.
    oldSpaceThreshold := oldSpacePages + OldSpaceThresholdIncrement.
    self configure.
    ^prev! 
lowUserPriority
        "Obsolete - answer the lowest priority for user processes."
    ^self lowPriority!  
standardPriority
        "Answer the standard priority for user processes."
    ^self userPriority! 
realTimePriority
        "Answer the priority for real time processing."
    ^6!
schedule
        "Schedule the highest priority ready process, or if none,
        create the idle process. Called with interrupts disabled."
    | processQueues queue process |
    processQueues := self readyToRun.
    processQueues size to: 1 by: -1
        do:
            [:index |
            queue := processQueues at: index.
            queue isEmpty
                ifFalse:
                    [process := queue removeFirst.
                    process resume]].

    "No process is ready to run (i.e. we lost the idle process) so create a new idle process."
    CurrentProcess := Process new.
    CurrentProcess priority: 1.
    CurrentProcess name: 'Idle Task'.
    CurrentProcess evaluate: (Message
        receiver: self
        selector: #idleLoop)!   
status
        "Private - Read the current virtual machine memory manager status
         into myself."
    <primitive: 91>
    self primitiveFailed! 
bytesFlipped
		"Answer the number of bytes flipped during the last
		flip."
	^bytesFlipped!
yield
        "Give other processes at the priority of the currently running
        process a chance to run."
    Process enableInterrupts: false.
    self schedule: CurrentProcess.
    self suspendActive!   
fork: forkBlock
        "Create a new process to execute the <forkBlock> and schedule it at
        the same priority as the active process."
    ^self
        fork: forkBlock
        at: CurrentProcess priority! 
fork: forkBlock at: priorityLevel
        "Create a new process to execute the <forkBlock> and schedule
        it at the given <priorityLevel>."
    | oldProcess firstTime newProcess |
    [ firstTime ].
    (Process enableInterrupts: false)
        ifFalse:
            [Process enableInterrupts: true.
            ^self error: 'fork with interrupts disabled'].
    oldProcess := CurrentProcess.
    CurrentProcess := Process new priority: priorityLevel.
    firstTime := true.
    self copyStack.
    firstTime
        ifTrue:
            [firstTime := false.
            (readyProcesses at: priorityLevel)
                addLast: CurrentProcess.
            newProcess := CurrentProcess.
            CurrentProcess := oldProcess.
            CurrentProcess priority <= priorityLevel
                ifTrue: [Processor yield]
                ifFalse: [Process enableInterrupts: true].
            ^newProcess]
        ifFalse:
            [CurrentProcess evaluate: (Message
                receiver: forkBlock
                selector: #value)]!  
codeCacheCleared
		"Private - the code cache was cleared."
    self triggerEvent: #codeCacheCleared!
suspendActive
        "Suspend the active process and schedule the highest
         priority ready process, if any. Called with interrupts
         disabled and CurrentProcess already entered in proper
         waiting queue."
    | firstTime |
    [ firstTime ].
    firstTime := true.
    self copyStack.
    firstTime
        ifTrue:
            [firstTime := false.
            self schedule]! 
idleTaskPriority
        "Answer the priority of the system idle task."
    ^1! 
configure
        "Private - Configure the virtual machine memory manager."
    <primitive: 92>
    self primitiveFailed!  
traceMode: anInteger
        "Private - set the trace mode."
    traceMode := anInteger.
    self configure
! 
backgroundPriority
        "Answer the priority for background processing."
    ^2! 
copyStack
        "Private - Answer a process object
         for the current process."
    ^Process copyStack!
compact
        "Private - a compact event has occurred, check
        memory for trouble or panic."
    | finalizerInterface |
    self rebalance.
    ( finalizerInterface := self class finalizerInterface ) notNil
        ifTrue: [ finalizerInterface compact ].
    self triggerEvent: #compact!
resume: aProcess
        "Add aProcess to the process scheduler's
         queue of ready processes.  If aProcess
         has the highest priority, make it the
         current process."
    | priority |
    Process enableInterrupts: false.
    priority := aProcess priority.
    (readyProcesses at: priority)
        addLast: aProcess.
    CurrentProcess priority < priority
        ifTrue: [
            Processor currentProcessIsRecursive
                ifTrue: [HaveBeenSignals:= true.
                             Process enableInterrupts: true]
                ifFalse: [Processor yield]]
        ifFalse: [Process enableInterrupts: true]!   
idleLoop
        "Private - Loop forever, because no other process wants to run."
    SessionModel current isGui
        ifTrue: [ self idleLoopGui ]
        ifFalse: [ self idleLoopNoGui ]!
bytesCollected
		"Answer the number of bytes garbage collected during the last
		flip or compact."
	^bytesCollected!   
highPriority
        "Answer the priority for a user process to be run
         at a higher priority than the user interface process."
    ^6! 
highUserPriority
        "Obsolete - answer the highest priority for user processes."
    ^self highPriority!   
rebalance
        "Private - If oldSpace is too large, do a compact."
    unboundComponents isNil ifTrue: [
        unboundComponents := SmalltalkLibraryBinder unboundK ].
    SmalltalkLibraryBinder unboundK > ( unboundComponents + 1000 ) ifTrue: [
        "some libs were unbound since last time, so try to free them."
        unboundComponents := SmalltalkLibraryBinder unboundK.
        SmalltalkLibraryBinder compact.
        unboundComponents := SmalltalkLibraryBinder unboundK ].
    oldSpacePages > oldSpaceThreshold
        ifTrue: [
            oldSpaceThreshold := oldSpacePages + 10.
            SmalltalkLibraryBinder unboundCount > 0
                ifTrue: [ SmalltalkLibraryBinder compact ]
                ifFalse: [ Smalltalk unusedMemory ].
            self status.
            oldSpaceThreshold := oldSpacePages + OldSpaceThresholdIncrement.
            self configure
        ].
    oldSpaceThreshold > (oldSpacePages + OldSpaceThresholdIncrement)
        ifTrue: [
            oldSpaceThreshold := oldSpacePages + OldSpaceThresholdIncrement.
            self configure
        ].!  
clearProcesses
        "Private - discard all processes and make
         the currentProcess the user interface
         process."
    | intState |
    intState := Process enableInterrupts: false.
    readyProcesses := nil.
    readyProcesses := Array new: self topPriority.
    1 to: self topPriority do: [ :index |
        readyProcesses
            at: index
            put: OrderedCollection new].
    Process enableInterrupts: intState!
currentProcessIsRecursive
        "Private - Answer true if the current process has been
         re-entered due to a host message."
    <primitive: 68>!  
asStringWithVolume: withVolumeBoolean
    "Answer a string representation of the receiver in the native syntax.
        Invariants:
        -   The result must be in a form accepted by the method #fromString:,
            as implemented by the class of the receiver, and the path created
            by #fromString: when passed the result of this method must be equal to the receiver."

    | components directorySeparator pathStream startIndex |
    components := self componentNames.
    directorySeparator := self class directorySeparator.
    pathStream := WriteStream on: (String new: self class maximumPathLength).
    self isAbsolute
        ifTrue:
            [withVolumeBoolean
                ifTrue:
                    [pathStream
                        nextPutAll: (components at: 1);
                        nextPutAll: self class volumeSeparator].
            startIndex := 2]
        ifFalse:
            [startIndex := 1].
    (self isAbsolute and: [components size = 1])
        ifTrue:
            [pathStream nextPutAll: directorySeparator]
        ifFalse:
            [(self isVolumeRelative and: [self isEmpty])
                ifTrue:
                    [pathStream nextPutAll: directorySeparator]
                ifFalse:
                    [startIndex to: components size
                        do:
                            [:componentIndex |
                            ((startIndex = componentIndex) and: [self isDirectoryRelative])
                                ifFalse: [pathStream nextPutAll: directorySeparator].
                            pathStream nextPutAll: (components at: componentIndex)]]].
    ^pathStream contents!
date: aDate time: aTime
        "Answer a new instance based on the given date and time."
    ^self new
        date: aDate;
        time: aTime;
        yourself!  
initialize
        "Initialize the receiver by discarding
         all processes and then creating a new
         user interface process."
    self clearProcesses.
    SessionModel current isGui ifTrue: [ SessionModel current runNotifier ]! 
key: aKey value: anObject
        "Answer an instance of class Association
         whose key is initialized to aKey and
         whose value is initialized to anObject."
    ^(self key: aKey) value: anObject! 
key: anObject
        "Answer an instance of class Association
         whose key is initialized to anObject."
    ^self new key: anObject!
searchResultsDo: iterationBlock
    "Private - Raw traversal of directory contents ... searchResult contains interesting information"

	^self searchResultsDo: iterationBlock onPattern: '*.*'!
removeBehavior: methodDictionary from: mda containedIn: parentMda
	"Private"
	"Remove <methodDictionary> from <mda>.  <parentMda> is either the method dictionary array that contains <mda>, or nil if none exists.  If the methodDictionary is not found, then answer nil."

	|  newMda |
	mda do: [:methodDictionaryOrArray |
		methodDictionaryOrArray == methodDictionary
			ifTrue: 
				[newMda := mda copyWithout: methodDictionary.
				newMda first isArray
					ifTrue: [newMda := newMda first].
				^parentMda == nil
					ifTrue: [self methodDictionaryArray: newMda]
					ifFalse: 
						 [parentMda at: (parentMda indexOf: mda) put: newMda.
						methodDictionary flushAllFromCache]]
			ifFalse: 
				[methodDictionaryOrArray isArray
					ifTrue: [^self removeBehavior: methodDictionary from: methodDictionaryOrArray containedIn: mda]]].
	^nil
			!
asFileSystemPath
   "Answer a file system path constructed by interpreting the receiver as a path name in the native file system format.
        Implementation Comments:
        -   The standard implementation is to send the message #fromString: to the class FileSystemPath with the receiver as the argument."

	^FileSystemPath fromString: self!
addEventHandlers: anEventHandlerDictionary
        "Append the event handlers to the receiver's event handlers."
    | actions event eventHandler |
    anEventHandlerDictionary associationsDo: [ :assoc |
        event := assoc key.
        eventHandler := assoc value.
        actions := self actionListForEvent: event.
        ( actions includes: eventHandler ) ifFalse: [
            self setActionList: ( actions copyWith: eventHandler ) forEvent: event ] ]! 
current
        "Answer the current session event manager instance."
    ^CurrentSession!   
errorLogFileName
		"Private - answer the name of the error log file."
	^ErrorLogFileName isNil ifTrue: [ 'error.log' ] ifFalse: [ ErrorLogFileName ]!   
diskSpaceRequiredToCompressChanges: backupBoolean
        "Private - answer the number of bytes required to compress the
        change.log (and save the image), and to backup the current image
        and change.log if backupBoolean is true."
    | changesSize bytesRequired backupFileName |
    bytesRequired := self
        diskSpaceRequiredToSaveImage: self current imageName
        backup: backupBoolean.
    changesSize := ( File fromPath: 'change.log' ) size.
    bytesRequired := bytesRequired + changesSize.  "estimated size of the new change.log file - usually takes less"
    backupBoolean ifTrue: [
        backupFileName := 'change.bak'.
        bytesRequired := bytesRequired + changesSize.  "backup will be the same size as current change.log"
        ( File exists: backupFileName )
            ifTrue: [ bytesRequired := bytesRequired - ( File fromPath: backupFileName ) size ] ].
    ^bytesRequired! 
diskSpaceRequiredToCompressSources: backupBoolean
        "Private - answer the number of bytes required to compress the
        sources.sml file (and change.log file and save the image), and to
        backup the current image, change.log, and sources.sml if backupBoolean
        is true."
    | sourcesSize bytesRequired backupFileName |
    bytesRequired := self diskSpaceRequiredToCompressChanges: backupBoolean.
    sourcesSize := ( File exists: 'sources.sml' )
        ifTrue: [ ( File fromPath: 'sources.sml' ) size ]
        ifFalse: [ ( File fromPath: 'change.log' ) size ].
    bytesRequired := bytesRequired + sourcesSize.  "estimated size of the new sources.sml file"
    backupBoolean ifTrue: [
        backupFileName := 'sources.bak'.
        bytesRequired := bytesRequired + sourcesSize.  "backup will be the same size as current sources.sml"
        ( File exists: backupFileName )
            ifTrue: [ bytesRequired := bytesRequired - ( File fromPath: backupFileName ) size ] ].
    ^bytesRequired! 
diskSpaceRequiredToSaveImage: imageName backup: backupBoolean
        "Private - answer the number of bytes required to save the image
        to the specified image file name, and to backup the current image
        if backupBoolean is true."
    | imageSize bytesRequired backupFileName |
    imageSize := ( File fromPath: self current imageName ) size.
    bytesRequired := Processor oldSpacePages * 4096.  "estimated size of the new image file"
    Smalltalk platformIsWin32
        ifTrue: [ bytesRequired := bytesRequired * 2 ].  "estimated size of temp coff files"
    backupBoolean ifTrue: [
        backupFileName := ( imageName upTo: $. ), '.bak'.
        bytesRequired := bytesRequired + imageSize.  "backup size = current image size"
        ( File exists: backupFileName )
        ifTrue: [ bytesRequired := bytesRequired - ( File fromPath: backupFileName ) size ] ].
    ^bytesRequired!
errorLogFileName: aString
		"Private - set the name of the error log file to aString."
	ErrorLogFileName := aString!
useBindProgressDialog
    "Indicate that the bindLibraries processing
    should display the progress dialog.
    Also see #noBindProgressDialog."

    self bindProgress: true! 
getGui
        "Private - Answer true if the current environment has a GUI."
    <primitive: 172>!  
closeBindProgressDialog
    "Private - Done with binding libraries."

    ( self bindProgress isNil or: [ self bindProgress == true ] ) ifTrue: [ ^self ].
    self bindProgress close.
    self bindProgress: nil.
    self
        removeActionsWithReceiver: self
        forEvent: #libraryBound:.!   
closeSignOn
        "Private - Close the sign on screen."
    ( Message new
        receiver: VirtualMachineLibrary
        selector: #closeSignOn
        arguments: Array new ) performDeferred!   
startUpSampleApplication
        "Private - start the sample runtime application."
    self isGui
        ifTrue: [ self startUpSampleGuiApplication ]
        ifFalse: [ self startUpSampleNonGuiApplication ]!  
isGui
        "Answer whether the system is running with GUI support."
    ^self gui and: [ self guiLoaded ]!   
startupBase
        "Private - perform base smalltalk startup."
    | save |
    save := ProcessScheduler finalizerInterface.
    ProcessScheduler finalizerInterface: nil.
    Processor clearProcesses.
    CurrentProcess := Process new.
    CurrentProcess makeUserIF.
    ResidueObject startUp.
    Ephemeron allInstancesPrim do: [ :e |
        ( e manager includes: e key )
            ifTrue: [ e activateEphemeronBehavior: true ] ].
    SystemWeakRegistries current startUp.
    ProcessScheduler finalizerInterface: save.
    Process initializeFrameMarker.
    OperatingSystemInformation startUp.
    self gui: nil  "call the primitive each time on startup"! 
bindLibraries
        "Private - Bind any libraries specified in the .bnd file."

    self isRunTime ifFalse: [ self useBindProgressDialog ].
    self bindLibraries: self exeName, '.bnd'.!  
bindLibraries: bindFileName
        "Private - Bind libraries specified in bindFileName."

    SmalltalkLibraryBinder groupBind: [
        self bindLibrariesPrivate: bindFileName ].
    self closeBindProgressDialog.! 
startUpSampleNonGuiApplication
    | consoleClassName consoleLibraryName consoleClass |
    consoleClassName := #Console.
    consoleLibraryName := 'Console'.  "logical library name, mapped to physical name via map file."
    ( ( Smalltalk includesKey: consoleClassName ) and: [ ( Smalltalk at: consoleClassName ) smalltalkLibraryOrdinal = 0 ] )
        ifTrue: [ consoleClass := Smalltalk at: consoleClassName ]
        ifFalse: [
            SmalltalkLibraryBinder bindTo: consoleLibraryName.
            consoleClass := Smalltalk at: consoleClassName ].
    consoleClass test.
    self exitSampleApplication! 
startUpApplication
        "Start the runtime application."
    | libs name index bound |
    libs := self commandLine.
    bound := false.
    libs size > 1 ifTrue: [
        index := 1.
        [ index := index + 1.  index <= libs size ] whileTrue: [
            ( ( name := libs at: index )  equalsIgnoreCase: '/lang' )
                ifTrue: [ index := index + 1 ] "skip the vm message dll if present"
                ifFalse: [
                    ( #( $/ $- ) includes: name first )
                         ifFalse: [ SmalltalkLibraryBinder bindTo: name. bound := true ] ] ] ].
    ( bound not and: [ ( File findFileName: self exeName, '.bnd' ) isNil ] )
        ifTrue: [ self startUpSampleApplication ].
    self triggerEvent: #startUpApplication!  
startupSession
        "Private - start the session."
    | oldWindows |
    Process enableInterrupts: false.
    self startupBase.
    self startupKernel.
    self initializeImageName.
    self gui ifTrue: [
        self guiLoaded
            ifFalse: [ SmalltalkLibraryBinder bindTo: SmalltalkLibraryBinder guiLibName ].
        oldWindows := self startupWindowSystem ].

    CurrentProcess isNil ifTrue:
        [ CurrentProcess := Process basicNew makeUserIF ].
    Process enableInterrupts: true.

    self isRunTime
        ifTrue: [ self isGui ifTrue: [ Smalltalk privateAt: #Transcript put: ( WriteStream on: String new ) ] ]
        ifFalse: [ self startupDevelopment ].

    self isGui ifTrue: [ self closeSignOn ].
    self triggerEvent: #startup.
    self noBindProgressDialog.
    self bindLibraries.
    self startUpApplication: oldWindows.
    self triggerEvent: #started.
    self isGui ifTrue: [ self runNotifier ]!
bindLibrariesPrivate: bindFileName
        "Private - Bind libraries specified in bindFileName."

    | file errorLog errorMessage aLibraryName firstChar |

    file := File fromPath: bindFileName.
    file exists ifFalse: [ ^self ].
    file := file readStream.
    [ file atEnd ] whileFalse: [
        firstChar := file peek.
        firstChar = $@
            ifTrue: [
                file next.
                self bindLibrariesPrivate: ( file nextLine upTo: $; ) trimBlanks ]
            ifFalse: [
        firstChar = $;
            ifTrue: [ file nextLine ]
            ifFalse: [
                aLibraryName := ( file nextLine upTo: $; ) trimBlanks.
                aLibraryName isEmpty ifFalse: [
                ( SmalltalkLibraryBinder isBound: aLibraryName )
                    ifFalse: [
                        self bindLibsProgress: aLibraryName.
                        [ SmalltalkLibraryBinder bindTo: aLibraryName ]
                            on: BindError, FileError, ProgressNotification
                            do: [ :anException |
                                ( ProgressNotification handles: anException )
                                    ifTrue: [
                                        self bindLibsProgress: anException description ]
                                    ifFalse: [
                                errorMessage :=
                                    'Unable to bind component ', aLibraryName,
                                    ' (', anException description, ').'.
                                errorLog := File pathName: 'error.log'.
                                errorLog
                                    setToEnd;
                                    cr;
                                    nextPutAll: 'Problem during startup while binding components from ', bindFileName, ' :'; cr;
                                    nextPutAll: '    ', errorMessage; cr;
                                    cr.
                                errorLog close.
                                ( self isNoGui or: [ ( ( Smalltalk at: #MessageBox ) confirm: errorMessage, '  Continue execution?' ) not ] )
                                    ifTrue: [ file close. ^Smalltalk exit ] ] ] ] ] ] ] ].
    file close.!  
initialize
        "Private - initialize the receiver."
    self runningApplications: Dictionary new!   
isNoGui
        "Answer whether the system is running without GUI support."
    ^self isGui not!
bindDevelopment
    "Private - bind the development library, if not already bound."

    | binder devLibName |
    devLibName := SmalltalkLibraryBinder devLibName.
    ( SmalltalkLibraryBinder isBound: devLibName ) ifFalse: [
        binder := SmalltalkLibraryBinder currentClass new.
        binder file: devLibName.
        [ binder bind ]
            on: UnresolvedExternal
            do: [:except |
                Warning signal: 'Unresolved external: ', except external printString, ' while binding library ', devLibName.
                except resume ] ]!   
bindProgress: aProgressDialog
        "Private - set the current bind progress dialog to aProgressDialog."
    bindProgress := aProgressDialog! 
bindLibsProgress: aLibOrNameOrPercent
    "Private - Provide bind progress feedback."

    | s dialog |
    self isNoGui ifTrue: [ ^self ].
    dialog := self bindProgressDialog.
    dialog isNil ifTrue: [ ^self ].
    s := aLibOrNameOrPercent.
    s isNumber ifTrue: [
        dialog showPercent.
        ^dialog percent: s ].
    s isString ifFalse: [ s := s name ].
    dialog message: s.!  
exitSampleApplication
        "Private - exit the sample application; if in the runtime
        system, exit Smalltalk."
    self isRunTime ifTrue: [ self exitSession ]!  
gui
        "Private - answer the gui setting."
    gui isNil ifTrue: [ gui := self getGui ].
    ^gui!
gui: aBoolean
        "Private - set the gui setting to aBoolean."
    gui := aBoolean! 
imageName
        "Private - Answers the name of the image.  For the runtime
        application, this is the name of the exe."
    ^imageName!
imageName: aString
        "Private - set the name of the image file."
    imageName := aString!
initializeImageName
        "Private - Initialize commandLine, exeName, and imageName variables.
        The commandLine variable is an array of substrings which contain the
        command line arguments (including the exe name).  The exeName variable
        is the name of the exe that started this session.  The imageName is the name
        of the image (which defaults to V.EXE if not specified) following the exeName,
        or the name of the runtime EXE."
    | name cmdLineString token |
    cmdLineString := self getCommandLineString.
    ( cmdLineString includes: $" )
        ifTrue: [
            token := cmdLineString asArrayOfSubstringsSeparatedBy: $".
            self commandLine: ( token asOrderedCollection reject: [ :subStr | subStr = '' or: [ subStr = ' ' ] ] ) asArray ]
        ifFalse: [ self commandLine: cmdLineString asArrayOfSubstrings ].
    self exeName: self commandLine first fileNameLessPath fileName.
    name := String new: 255.
    VirtualMachineLibrary getImageName: name.
    self imageName: name trimBlanks!
startUpApplication: oldWindows
        "Private - start up the application, using the saved list of oldWindows
        to restore the system state if necessary (in development)."
    self isRunTime
        ifTrue: [ self startUpApplication ]
        ifFalse: [ self resumeDevelopment: oldWindows ]!   
exitSession
        "Private - Exit the session."
    self triggerEvent: #shutdown.
    self isRunTime ifFalse: [ self exitDevelopment ].
    self isGui ifTrue: [ self exitWindowSystem1 ].
    SystemWeakRegistries current exit.
    self isGui ifTrue: [ self exitWindowSystem2 ].
    self exitKernel.
    self exitBase!
bindProgress
        "Private - answer the current bind progress dialog or setting (Boolean)."
    ^bindProgress!   
runningApplications
        "Private - answer a Dictionary of running applications."
    ^runningApplications!  
guiLoaded
		"Private - answer whether the GUI library has been loaded."
	^guiLoaded!
guiLoaded: aBoolean
		"Private - set whether the GUI library has been loaded to aBoolean."
	guiLoaded := aBoolean!  
runningApplications: aDictionary
        "Private - set the Dictionary of running applications to aDictionary."
    runningApplications := aDictionary! 
savedTimeStamp
        "Private - answer the timestamp corresponding to the last image save."
    ^( File fromPath: self imageName ) lastModificationTime!  
startupDevelopment
        "Private - start up the development system."
    self bindDevelopment.
    self openSourceFiles.
    self fileInGoFile.
    ( Smalltalk includesKey: #SmalltalkEmulator )
        ifTrue: [ ( Smalltalk at: #SmalltalkEmulator ) startUp ]!  
commandLine
        "Private - answer the command line."
    ^commandLine!  
commandLine: commandLineArray
        "Private - set the command line to commandLine."
    commandLine := commandLineArray! 
exeName
        "Answer the name of the exe that started this session."
    ^exeName!   
exeName: aString
        "Private - set the name of the exe that started this session to aString."
    exeName := aString!  
isRunTime
        "Private - Answer true if the current environment
         is the run-time system."
    <primitive: 77>! 
noBindProgressDialog
    "Indicate that the bindLibraries processing
    should NOT display the progress dialog.
    Also see #useBindProgressDialog."

    self bindProgress: nil!  
getCommandLine
        "Answer arguments from the command line, as an Array containing the
        executable name followed by its command line arguments."
    ^self getCommandLineString asArrayOfSubstrings!
releaseEventTable
    "Private"
    "Break all connections to event handlers."

    handlers := nil!  
eventTable
    "Private"
    "Answer a Dictionary mapping event names to actions
    for the receiver."

    ^handlers == nil
        ifTrue: [self eventTableCreate]
        ifFalse: [handlers]! 
eventTableForEdit
    "Private"
    "Answer a Dictionary mapping event names to actions,
    allocate it if necessary."

    handlers == nil
        ifTrue: [handlers := self eventTableCreate].
    ^handlers!   
smalltalkLibraryName
    "Answer the name of the SmalltalkLibrary which contains
    the receiver, or nil if the receiver is in the base library
    or the image."

    | n bound |
    n := self smalltalkLibraryOrdinal.
    n <= 1 ifTrue: [ ^nil ].
    bound := SmalltalkLibraryBinder bound.
    bound isNil ifTrue: [ ^nil ].
    ^( bound at: ( n - 1 ) ) name copy!   
hasSubdirectory
        "Answer true if the receiver has a
         subdirectory."

	self directoriesDo: [:dir | ^true].
	^false!
origin
        "Answer a Point, the top left
         corner of the receiver."
    ^self leftTop!  
newTemporaryFile
        "Create and answer a new temporary File."

        | tempNum tempName tempFile |
    tempNum := Time current asSeconds.
    [ tempFile == nil ] whileTrue:
        [ tempNum := (tempNum + 1 )  \\ 16rFFFFF.
        tempName := WriteStream on: (String new: 12).
        tempName nextPutAll: 'TMP'.
        tempNum printOn: tempName base: 16 showRadix: false.
        tempName nextPutAll: '.DAT'.
        tempFile := self  newFileNamed: (tempName contents)
            ifExists: [ :excpt | excpt return]].
    ^tempFile.!   
isIndexedCollection
        "Answer whether the receiver is a kind of IndexedCollection."
    ^false!   
postFastCopy: original 
        "update the receiver which has just been copied from the argument "
	contents := contents copy! 
move: oldString to: newString
        "Move the file or directory named oldString to newString. Cross volume moving is allowed."
 
    ( KernelLibrary
        moveFileEx: oldString asParameter
        to: newString asParameter
		 flags: 1 "MOVEFILE_COPY_ALLOWED")
            ifFalse: [ ^self osError ]!
fileNamesMatching: pattern
    "Answer a collection of the names of the files contained within the receiver that match the given <pattern>."

	| names matchPoint uppercasePattern |
    names := OrderedCollection new.
    uppercasePattern := Pattern new: pattern input asUpperCase.
	self
		fileNamesDo:
			[:name |
			(matchPoint := uppercasePattern match: name asUpperCase index: 1) ~~ nil
				ifTrue: [(matchPoint x = 1 and: [matchPoint y = name size])
							ifTrue: [names add: name]]].
	^names!
shortDateFormat: aString
        "Private - Set the current system value for short date format."
    shortDateFormat := aString!
decimalLeadZero: anInteger
        "Private - Set the current system value for decimal lead zero.
                Set 0 = no leading zero (.7)
                      1 = leading zero (0.7)."
    decimalLeadZero := anInteger!   
collateTablei
        "Answer the current collate-sequence (sorting weight) table.
         This is a case insensitive table."
    ^collateTablei! 
collateTablei: aCollateTablei
        "Replace the current collate-sequence (sorting weight) table.
         This is a case insensitive table."
    collateTablei := aCollateTablei.

    "Load table used by string comparison primitive."
    self loadCollateTable: collateTablei!   
character: aCharacter1 isGreaterThan: aCharacter2
        "Answer true if aCharacter1 is greater
         than aCharacter2, else answer false."
    (aCharacter1 isDoubleByte or: [aCharacter2 isDoubleByte])
        ifTrue: [
            ^self string: (String with: aCharacter1)
            isGreaterThan: (String with: aCharacter2)]
        ifFalse: [
            ^(collateTable at: (aCharacter1 asInteger + 1)) >
            (collateTable at: (aCharacter2 asInteger + 1))]!
loadCollateTable: aCollateTable
        "Private -Load collating sequence table used
        in the string comparison primitive.
        Answer true if the table is loaded successfully."
    <primitive: 128>
    ^self primitiveFailed!   
initCountryInfo
        "Private - Clear instance variables holding self-initializing
         country-dependent formatting information. This forces the
         values to be refreshed when the settings are changed
         through the ControlPanel."
    collateTable notNil ifTrue: [
         country := nil.
         codePage := nil.
         dateFormat := nil.
         dateSeparator := nil.
         timeFormat := nil.
         timeSeparator := nil.
         currencyFormat := nil.
         currency := nil.
         thousandsSeparator := nil.
         decimalPlace := nil.
         decimalSeparator := nil.
         dataSeparator := nil.
         time1159 := nil.
         time2359 := nil.
         countryName := nil.
         language := nil.
         measurementSystem := nil.
         timeLeadZero := nil.
         shortDateFormat := nil.
         longDateFormat := nil.
         currencyDigits := nil.
         negativeCurrencyFormat := nil.
         decimalLeadZero := nil ]!
allLowerCase: aString
        "Private - set the allLowerCase instance variable to aString."
    allLowerCase := aString!   
allUpperCase: aString
        "Private - set the allUpperCase instance variable to aString."
    allUpperCase := aString!   
collateTable: aCollateTable
        "Replace the current collate-sequence (sorting weight) table.
         This is a case sensitive table."
    collateTable := aCollateTable! 
timeLeadZero: anInteger
        "Private - Set the current system value for time lead zero.
                Set 0 = no leading zero (9:15:24)
                      1 = leading zero (09:15:24)."
    timeLeadZero := anInteger!  
character: aCharacter1 isLessThanOrEqualTo: aCharacter2
        "Answer true if aCharacter1 is less than
         or equal to aCharacter2, else answer false."
    (aCharacter1 isDoubleByte or: [aCharacter2 isDoubleByte])
        ifTrue: [
            ^self string: (String with: aCharacter1)
                isLessThanOrEqualTo: (String with: aCharacter2)]
        ifFalse: [
            ^(collateTable at: (aCharacter1 asInteger + 1)) <=
                (collateTable at: (aCharacter2 asInteger + 1))]!  
longDateFormat: aString
        "Private Set the current system value for long date format."
    longDateFormat := aString! 
leadBytes
        " Answer the current leadBytes flag array."
    ^leadBytes!   
character: aCharacter1 isLessThan: aCharacter2
        "Answer true if aCharacter1 is less than
         aCharacter2, else answer false."
    (aCharacter1 isDoubleByte or: [aCharacter2 isDoubleByte])
        ifTrue: [
            ^self string: (String with: aCharacter1)
            isLessThan: (String with: aCharacter2)]
        ifFalse: [
            ^(collateTable at: (aCharacter1 asInteger + 1)) <
            (collateTable at: (aCharacter2 asInteger + 1))]! 
isAlphaNumeric: aCharacter
        "Answer true if aCharacter is a
         letter or digit, else answer false."
    ^((self isLetter: aCharacter) or: [self isDigit: aCharacter])!
asLowerCase: aCharacter
        "Answer the lower-case value of aCharacter
         if it is a letter, else answer aCharacter."
    | anInteger |
    anInteger := aCharacter asInteger.
    ((anInteger > 0) and: [anInteger < 256])
        ifTrue: [^self allLowerCase at: anInteger].
    ^aCharacter! 
asUpperCase: aCharacter
        "Answer the upper-case value of the aCharacter
         if it is a letter, else answer the aCharacter."
    | anInteger |
    anInteger := aCharacter asInteger.
    ((anInteger > 0) and: [anInteger < 256])
        ifTrue: [^self allUpperCase at: anInteger].
    ^aCharacter! 
isDoubleByteCp
        "Answer whether the current system is double-byte."
    ^isDoubleByteCp! 
isLowerCase: aCharacter
        "Answer true if aCharacter is a
         lower-case letter, else answer false."
    | anInteger |
    anInteger := aCharacter asInteger.
    ((anInteger > 0) and: [anInteger < 256])
        ifTrue: [^(self allUpperCase at: anInteger) ~= aCharacter].
    ^false!  
isUpperCase: aCharacter
        "Answer true if aCharacter is a
         upper-case letter, else answer false."
    | anInteger |
    anInteger := aCharacter asInteger.
    (anInteger > 0 and: [aCharacter ~= DoubleByteSpace])
        ifFalse: [^false].
    (anInteger < 256)
        ifTrue: [^(self allLowerCase at: anInteger) ~= aCharacter].
    ^true  "All double-byte characters are upper-case letters."!  
= aCharacter
        "Answer true if the receiver code point value
         is equal to the code point value of aCharacter,
         else answer false."
    ^aCharacter isCharacter and: [ asciiInteger = aCharacter asciiValue ]!   
digitValue
        "Answer a number corresponding to
         the digit value of the receiver."
    (asciiInteger > 47 and: [asciiInteger < 58])
        ifTrue: [ "$0..$9 become 0..9"
            ^asciiInteger - 48].
    (asciiInteger > 64 and: [asciiInteger < 91])
        ifTrue: [ "$A..$Z become 10..35"
            ^asciiInteger - 55].
    self error: 'digitValue requires characters $0..$9, $A..$Z'! 
+ intOrChar
        "Answer a character whose asciiValue is the sum of
         the receiver's asciiValue and the argument (or its asciiValue)"
    | value |
    value := self asciiValue +
        ( intOrChar isInteger ifTrue: [ intOrChar ] ifFalse: [ intOrChar asciiValue ] ).
    ^self class value: value! 
printOn: aStream
        "Append the character representation of
         the receiver to aStream."
    aStream nextPut: $$.
    (NationalLanguage isDoubleByteCp not and: [self isDoubleByte])
        ifTrue: [aStream nextPut: self leadByte; nextPut: self trailByte]
        ifFalse: [aStream nextPut: self]! 
isSeparator
        "Answer true if the receiver character is either a
         space, tab, carriage-return, line-feed, form-feed
         character, or double-byte space, else answer false."
    ^self == Space
        or: [self == Tab
            or: [self == Cr
                or: [self == Lf
                    or: [self == Ff
                        or: [self = DoubleByteSpace]]]]]!
asString
        "Answer a one character String containing
         the receiver."
    ^String with: self! 
isSymbolCharacter
        "Answer true if the receiver is a valid Symbol
         character, otherwise false."
    ^self isAlphaNumeric or: [ self == $: or: [ self == $_ ] ]! 
> aCharacter
        "Answer true if the receiver occurs after aCharacter
         in the current sort sequence, else answer false."
    ^NationalLanguage character: self  isGreaterThan: aCharacter! 
>= aCharacter
        "Answer true if the receiver occurs at the same position
         or after aCharacter in the current sort sequence,
         else answer false."
    ^NationalLanguage character: self  isGreaterThanOrEqualTo: aCharacter! 
isLeadByte: leadByteFlags
        " Answer whether the receiver is the lead byte of a DBC
        encoding.  The leadByteFlags is an array [1..255] of Booleans,
        indexed by the receiver's code point value. "
    (asciiInteger = 0) ifTrue: [^false].
    (asciiInteger > 255)
        ifTrue: [^self error: 'Character out of byte range [1..255]'].
    ^leadByteFlags at: asciiInteger!   
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reconstructed."
    self printOn: aStream!  
hash
        "Answer the integer hash."
    <primitive: 75>!
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable.  Because
         characters are immutable (cannot instantiate
         a copy), answer the receiver."
    ^self!
isLeadByte
        " Answer whether the receiver is a lead byte code
        in the current national language. "
    ^self isLeadByte: (NationalLanguage leadBytes)!   
- intOrChar
        "If intOrChar is a character, answer the difference between
         the receiver's asciiValue and intOrChar's asciiValue; if it
         is an integer, answer the difference between the receiver's
         asciiValue and intOrChar"
    ^intOrChar isCharacter
        ifTrue: [ self asciiValue - intOrChar asciiValue ]
        ifFalse: [ self asciiValue - intOrChar ]!   
isDoubleByte
        "Answer whether the receiver is a double-byte character."
    ^asciiInteger > 255! 
between: min and: max
        "Answer true if the receiver is greater than or
         equal to min and less than or equal to max,
         else answer false."
    ^(min asciiValue <= asciiInteger) and: [asciiInteger <= max asciiValue]!  
leadByte
        "Answer the character corresponding to the receiver's lead byte."
    ^(asciiInteger bitShift: -8) asCharacter!
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver instance variables.  Because
         characters are immutable (cannot instantiate
         a copy), answer the receiver."
    ^self!  
asLowercase
        "Answer the lower case value of the receiver
         if it is a letter, else answer the receiver."
    ^NationalLanguage asLowerCase: self!   
asLowerCase
        "Answer the lower case value of the receiver
         if it is a letter, else answer the receiver."
    ^self asLowercase! 
asUppercase
        "Answer the upper case value of the receiver
         if it is a letter, else answer the receiver."
    ^NationalLanguage asUpperCase: self!   
asUpperCase
        "Answer the upper case value of the receiver
         if it is a letter, else answer the receiver."
    ^self asUppercase! 
asCharacter
        "Answers the receiver."
    ^self!  
isSingleByte
        "Answer whether the receiver is a single-byte character."
    ^asciiInteger < 256! 
to: aCharacter do: aBlock
        "Evaluate the one argument block aBlock for the
         characters between the receiver and the argument
         aCharacter where each character has an asciiValue
         one higher than the previous character"
    | index |
    index := self.
    [index <= aCharacter]
        whileTrue: [
            aBlock value: index.
            index := index + 1]!   
isDigit
        "Answer true if the receiver is in the range
         of characters from 0 to 9 or any other character
         as defined by the current system language,
         else answer false."
    ^(asciiInteger > 47 and: [asciiInteger < 58])
        ifTrue: [true]
        ifFalse: [NationalLanguage isDigit: self].!   
isLetter
        "Answer true if the receiver is in the range of
         characters from a and z or in the range from
         A and Z or a letter as defined by the current
         system language, else answer false."
    ^((asciiInteger > 96 and: [asciiInteger < 123])
        or: [asciiInteger > 64 and: [asciiInteger < 91]])
        ifTrue: [true]
        ifFalse: [NationalLanguage isLetter: self]!  
isLowercase
        "Answer true if the receiver is in the range of
         character from a to z or a lower-case character
         as defined by the current system language,
         else answer false."
    ^( asciiInteger > 96 and: [ asciiInteger < 123 ] )
        ifTrue: [ true ]
        ifFalse: [ NationalLanguage isLowerCase: self ]! 
isLowerCase
        "Answer true if the receiver is in the range of
         character from a to z or a lower-case character
         as defined by the current system language,
         else answer false."
    ^self isLowercase! 
asInteger
        "Answer the number corresponding to the code point
         value of the receiver."
    ^asciiInteger!   
isCharacter
        "Answer true if receiver is a kind of Character."
    ^true!
isUpperCase
        "Answer true if the receiver is in the range
         of character from A to Z or an upper-case character
         as defined by the current system language,
         else answer false."
    ^self isUppercase!
isUppercase
        "Answer true if the receiver is in the range
         of character from A to Z or an upper-case character
         as defined by the current system language,
         else answer false."
    ^( asciiInteger > 64 and: [ asciiInteger < 91 ] )
        ifTrue: [ true ]
        ifFalse: [ NationalLanguage isUpperCase: self ]! 
asciiValue
        "Answer the number corresponding to
         the ASCII encoding of the receiver."
    ^asciiInteger!
to: aCharacter
        "Answer an Interval for the characters between
         the receiver and the argument aCharacter where
         each character has an asciiValue one greater
         than the previous character"
    ^Interval from: self to: aCharacter!   
isDigitBase: digitBase
    "Answer <true> if the receiver is in the range of characters whose digit
    values are between zero (0) and <digitBase> minus one."

    | upperBound |
    upperBound := self class digitValue: digitBase - 1.
    digitBase <= 10
        ifTrue: [^self between: $0 and: upperBound].
    ^(self between: $0 and: $9)
        or: [self between: $A and: upperBound]! 
isVowel
        "Answer true if the receiver is any one of the
         characters a,A,e,E,i,I,o,O,u,U, else answer false."
    ^'aAeEiIoOuU' includes: self!  
isWhitespace
        "Answer true if the receiver is white space,
        else answer false."
    ^self asInteger <= 32 "Space asInteger"
        or: [ asciiInteger = DoubleByteSpace asInteger ]!   
< aCharacter
        "Answer true if the receiver occurs before aCharacter
         in the current sort sequence, else answer false."
    ^NationalLanguage character: self  isLessThan: aCharacter!   
<= aCharacter
        "Answer true if the receiver occurs before or at the same
         position as aCharacter in the current sort sequence,
         else answer false."
    ^NationalLanguage character: self  isLessThanOrEqualTo: aCharacter!
to: sChar by: iNumber
        "Answer an Interval for the characters between
         the receiver and the argument sChar where each
         character has an asciiValue iNumber higher than
         the previous character"
    ^Interval from: self to: sChar by: iNumber!   
trailByte
        "Answer the character corresponding to the receiver's trail byte."
    ^(asciiInteger \\ 256) asCharacter!
to: sChar by: iNumber do: aBlock
        "Evaluate the one argument block aBlock for the
         characters between the receiver and the argument
         sChar where each character has an asciiValue
         iNumber greater than the previous character"
    | index |
    index := self.
    iNumber > 0
        ifTrue: [
            [index <= sChar] whileTrue: [
                aBlock value: index.
                index := index + iNumber]]
        ifFalse: [
            [sChar <= index] whileTrue: [
                aBlock value: index.
                index := index + iNumber]]!  
isAlphaNumeric
        "Answer true if the receiver is an alphanumeric
         character, else answer false."
    ^self isDigit or: [self isLetter]!  
allUpperCase
        "Private - answer the allUpperCase instance variable,
        initializing if necessary."
    allUpperCase isNil ifTrue: [ self initializeAllUpperCase ].
    ^allUpperCase! 
measurementSystem: anInteger
        "Private - Set the current system value for measurement system.
         Set 0 = metric
               1 = english."
    measurementSystem := anInteger! 
character: aCharacter1 isGreaterThanOrEqualTo: aCharacter2
        "Answer true if aCharacter1 is greater than
         or equal to aCharacter2, else answer false."
    (aCharacter1 isDoubleByte or: [aCharacter2 isDoubleByte])
        ifTrue: [
            ^self string: (String with: aCharacter1)
            isGreaterThanOrEqualTo: (String with: aCharacter2)]
        ifFalse: [
            ^(collateTable at: (aCharacter1 asInteger + 1)) >=
            (collateTable at: (aCharacter2 asInteger + 1))]! 
negativeCurrencyFormat: anInteger
        "Private - Set the current system value for negative currency format.
                Set 0 = ($1)
                      1 = -$1
                      2 = $-1
                      3 = $1-
                      4 = (1$)
                      5 = -1$
                      6 = 1-$
                      7 = 1$-."
    negativeCurrencyFormat := anInteger!  
language: aString
        "Private - Set the current system value for language."
    language := aString!   
allLowerCase
        "Private - answer the allLowerCase instance variable,
        initializing if necessary."
    allLowerCase isNil ifTrue: [ self initializeAllLowerCase ].
    ^allLowerCase! 
collateTable
        "Answer the current collate-sequence (sorting weight) table.
         This is a case sensitive table."
    ^collateTable! 
countryName: aString
        "Private - Set the current system value for country name."
    countryName := aString! 
add: anAssociation
        "Answer anAssociation.  Add anAssociation to
         receiver.  Ensure that the key is a symbol."
    Symbol mustBeSymbol: anAssociation key.
    ^DefinitionInstaller current
		add: anAssociation 
		inGlobalDictionary: self!
microsecondsToRunPrivate: aBlock
        "Private - answer the number of microseconds which elapse during
        the evaluation of aBlock.  Hardware must support a high-resolution
        performance counter."
    | frequency time1 time2 delta |
    frequency := ExternalBuffer new: 8.
    ( KernelLibrary queryPerformanceFrequency: frequency asParameter )
        ifFalse: [ ^self error: 'High-resolution performance counter not available.' ].
    frequency := ( ( frequency longAtOffset: 4 ) bitShift: 32 ) +
        ( frequency uLongAtOffset: 0 ).  "counts per second"
    time1 := ExternalBuffer new: 8.
    time2 := ExternalBuffer new: 8.
    KernelLibrary queryPerformanceCounter: time1 asParameter.
    aBlock value.
    KernelLibrary queryPerformanceCounter: time2 asParameter.
    time1 := ( ( time1 longAtOffset: 4 ) bitShift: 32 ) + ( time1 uLongAtOffset: 0 ).
    time2 := ( ( time2 longAtOffset: 4 ) bitShift: 32 ) + ( time2 uLongAtOffset: 0 ).
    delta := time2 - time1.  "number of counts"
    ^delta * 1000000 // frequency!   
fileNamed: fileName
    "Answer the file named <fileName> contained within the receiver. If the name does not define an existing file within the receiver, return a file object that can be used to create the external file.
        Error Conditions:
        -   If there is a file entity with the same name in the receiver, send the message #doesNotExist to the object representing the file that does not exist."

	^[(self absolutePath , fileName) asFile] 
		on: FileError
		do: [FileError signal: 'File does not exist' with: (self absolutePath , fileName)]!   
memoryHandleFrom: aVariableByteObject
        "Private - Copy aVariableByteObject into non-smalltalk memory
         by doing a globalAlloc. "
    | handle address |
    address:= self copyToNonSmalltalkMemory: aVariableByteObject.
    address doesNotNeedFinalization.
    handle := address memoryHandle.
    KernelLibrary globalUnlock: handle.
    ^handle! 
winClassName
        "Private - answer the name of the class registered for
        use by windows created by the system."
    ^winClassName trimNullTerminator!   
signal: msg with: aSystemErrorCode
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

	| new |
	new := self new.
	new errorCode: aSystemErrorCode.
	new messageText: msg.
	^new signal!   
signalWith: aSystemErrorCode
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence."

	| new |
	new := self new.
	new errorCode: aSystemErrorCode.
	^new signal!
mapErrorCode: aSystemErrorCode to: exceptionClass
	"Map the <aSystemErrorCode> to the <excp\eptionClass>, making the default behavior for unhandled instances be to signal the exception class. This mechanism is intented to allow the general system error handling mechanism to be made more specific for errors that user code wishes to handle specially."

	self errorMap at: aSystemErrorCode put: exceptionClass!  
mappingFor: aSystemErrorCode
	"Answer the Exception class to which the <aSystemErrorCode> is mapped, or <nil> if there is none."

	^self errorMap at: aSystemErrorCode ifAbsent: [nil]!
signal: msg
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

	self invalidMessage!  
errorMap
	"Private - Answer the mapping from system error codes to the Exception classes."

	ErrorMap == nil 
		ifTrue: [ErrorMap := Dictionary new].
	^ErrorMap!
signal
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence."

	self invalidMessage!  
directory: aDirectory
searchHandle: aSearchHandle
findData: aFindData
        "Answer a new instance of the receiver based on the specified attributes."
	^self new
			directory: aDirectory
			searchHandle: aSearchHandle
			findData: aFindData!
removeFromSystem: checkForInstances
        "Private - Remove the receiver from Smalltalk.  Report
         an error if there are any subclasses or
         instances of the receiver. If checkForInstances
         is true then we check if there are any instances of the
         receiver."
    ((OrderedCollection new
        add: UndefinedObject;
        add: Class;
        add: True;
        add: False;
        add: DeletedClass;
        add: EmptySlot;
        add: SmallInteger;
        yourself)
            includes: self)
                ifTrue: [^self error: 'Class cannot be removed.'].
    checkForInstances ifTrue: [
        self allInstances notEmpty ifTrue:
        [^self error: 'Has instances'] ].
    self allSubclasses notEmpty ifTrue:
        [^self error: 'Has subclasses'].

    DefinitionInstaller current removeClass: self!
shortDateFormat
        "Answer the current system value for short date format."
    shortDateFormat isNil
        ifTrue: [ shortDateFormat := self queryNationalProfileString: 'sShortDate' default: 'M/d/yy' ].
    ^shortDateFormat!  
isDoubleByteSymbol
        "Answer true if receiver is a kind of DoubleByteSymbol."
    ^false! 
initializeIsLetterIsDigit
        "Private - initialize isLetter & isDigit inst vars."
    | aString isAlpha |
    isLetter := ByteArray new: 255.
    isDigit := ByteArray new: 255.
    aString := String new: 4.
    1 to: 255 do: [ :cp |
        isAlpha := UserLibrary isCharAlpha: cp.
        isLetter at: cp put: isAlpha asParameter.
        isDigit at: cp put: ( isAlpha
            ifTrue: [ false asParameter ]
            ifFalse: [ ( UserLibrary isCharAlphaNumeric: cp ) asParameter ] ) ]!   
entityNamesDo: iterationBlock
    "Evaluate the <iterationBlock> once with the name of each entity contained within the receiver.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated entities."

	self
		searchResultsDo:
			[:searchResult |
			iterationBlock value: searchResult entityName]! 
on: aClass matching: aStringPattern
	"Create a instance of this class that will detect exceptions of type <aClass> whose
	descrption matches <aStringPattern>.  The resulting object can be used to establish an exception
	handler"

	^self new
		exceptionClass: aClass;
		filterPattern: aStringPattern!
lastOsError
        "Private - answer the last Integer error code
        which was set by the host OS."
    ^KernelLibrary getLastError!  
asExternalGlobalAddress
        "Answer the receiver as an ExternalGlobalAddress."
    ^self!   
memoryHandle
        "Answer the memory handle of the memory block
         the receiver points to.  Maintained for backward compatibility."
    memoryHandle isNil ifTrue: [ ^0 ].
    ^memoryHandle asInteger!  
memorySize: anInteger
        "Private - set the size of the receiver's memory block."
    memorySize := anInteger! 
memoryHandleObject
        "Answer the memory handle of the memory block
         the receiver points to"
    ^memoryHandle!   
memorySize
        "Answers the size of the receiver's memory block."
    ^memorySize!  
invalidate
	"Private - Set the receiver to be invalid."

	super invalidate.
	memoryHandle := memorySize := nil.!  
memoryHandleObject: aGlobalHandle
        "Private - set the handle of the memory object for the
        receiver to aGlobalHandle"
    memoryHandle := aGlobalHandle! 
isByteArray
        "Answer true if receiver is a kind of ByteArray."
    ^false!   
asDirectory
    "Answer the directory referenced by the receiver.
        Error Conditions:
        -   If the receiver cannot be resolved to a directory, send the message #cannotBeResolved to the receiver. Resolution will fail if the entity referenced by the receiver does not exist, is not accessible, or is not a directory."

    ^self asFileSystemPath asDirectory! 
asFileSystemPath
    "Answer a path that will resolve to the same entity as the receiver."

    self implementedBySubclass!
cannotBeResolved
    "An attempt to resolve the receiver has failed. Signal a FileError."

    FileError
        signal: 'Cannot be resolved'
        with: self!
entityName
	"Answer the name of the entity represented by the receiver"

	^self implementedBySubclass! 
asFileSystemLocator
    "Answer a file system locator that will resolve to the same entity as the receiver."

    ^self!   
canBeResolved
    "Answer <true> if the receiver can be resolved in the current environment."

	^true! 
asFile
    "Answer the file referenced by the receiver.
        Error Conditions:
        -   If the receiver cannot be resolved to a file, send the message #cannotBeResolved to the receiver. Resolution will fail if the entity referenced by the receiver does not exist, is not accessible, or is not a file."

    ^self asFileSystemPath asFile!  
resolve
    "Answer the entity referenced by the receiver.
        Error Conditions:
        -   If the receiver cannot be resolved, send the message #cannotBeResolved to the receiver. Resolution will fail if the entity referenced by the receiver does not exist or is not accessible."

    ^self asFileSystemPath resolve!
indexOfDirectoryIn: aString startingAt: anIndex
        "Private - Answer the index of the start of the next subdirectory
         in aString, zero if there are no more."
    | pos |
    pos := anIndex.
    [ pos < aString size ]
        whileTrue: [
              pos := pos + 1.
              ( '/\' includes: (aString at: pos) )
                    ifTrue: [ ^ pos ].
        ].
    ^ 0.!
allocate: numberOfBytes in: aHeap
        "Private - allocate an ExternalHeapAddress in aHeap.
        Answer nil if allocation request fails (heap full)."
    | answer |
    answer := self new: self sizeInBytes.
    aHeap allocate: answer ofSize: numberOfBytes.
    answer isValid ifFalse: [ ^nil ].
	answer needsFinalization.
    answer memoryHandle: aHeap.
    answer memorySize: numberOfBytes.
    ^answer!  
allocateMemory: size
        "Allocate size number of bytes in host memory.
         Answer an ExternalAddress for the allocated memory."
    | heap heapSize address |
    heap := ExternalHeapHandle defaultHeap.
    ( address := self allocate: size in: heap ) isNil ifTrue: [
        heapSize := ExternalHeapHandle defaultHeapSize max: size.
        heap := ExternalHeapHandle newHeap: heapSize.
        address := self allocate: size in: heap ].
    ^address! 
memoryHandle: aHeapHandle
        "Private - set the handle of the heap to which the
        receiver belongs to aHeapHandle."
    memoryHandle := aHeapHandle!
memoryHandle
        "Private - answer the handle of the heap to which
         the receiver belongs."
    ^memoryHandle!  
memorySize: anInteger
        "Private - set the size of the receiver's memory block
        to anInteger."
    memorySize := anInteger!   
memorySize
        "Answer the size of the data associated with
         the receiver"
    ^memorySize!
releaseMemory
	"Private - Release the memory at the receiver's address."

    self isValid ifFalse: [ ^self ].
    self memoryHandle freeAddress: self size: self memorySize.!
invalidate
	"Private - Set the receiver to be invalid."

	super invalidate.
	memoryHandle := memorySize := nil.!  
allFileNames
    "Answer a collection of the names of the files contained within the receiver or any of its subdirectories."

    | names |
    names := OrderedCollection new.
    self
        allFileNamesDo:
            [:name |
            names add: name].
    ^names!  
triggerEvent: eventName with: argument
        "Trigger the event <eventName> using the given
        <argument> as the argument.  Answer the value
        returned by the most recently defined event handler action."
    ^self
        triggerEvent: eventName
        withArguments: (Array with: argument)!   
hasEntity
        "Answer true if the receiver has any contained entities."
	self entitiesDo: [:dir | ^true].
	^false! 
currencyDigits
        "Answer the current system value for the number of digits
         following the decimal point in a currency amount."
    currencyDigits isNil
        ifTrue: [ currencyDigits := self queryNationalProfileInt: 'iCurrDigits' default: 2 ].
    ^currencyDigits! 
bytesFree
        "Answer the number of bytes of free space on the receiver."
    | path sectorsPerCluster bytesPerSector freeClusters totalClusters |
    path := self asFileSystemPath volumePath asString.
    sectorsPerCluster := ExternalLong new.
    bytesPerSector := ExternalLong new.
    freeClusters := ExternalLong new.
    totalClusters := ExternalLong new.

    ( KernelLibrary getDiskFreeSpace: path asParameter
        sectorsPerCluster: sectorsPerCluster asParameter
        bytesPerSector: bytesPerSector asParameter
        freeClusters: freeClusters asParameter
        totalClusters: totalClusters asParameter )
            ifFalse: [ self osError ].

    ^freeClusters asInteger * sectorsPerCluster asInteger * bytesPerSector asInteger! 
with: anException
	"Create an instance of the receiver with <anException> as its sole member."

	| new |
	new := self new.
	new exceptions add: anException.
	^new! 
stepInterrupt
        "Private - Implement debugger
        step interrupt."
    CurrentProcess debugger isNil
        ifFalse: [ CurrentProcess debugger singleStep ]!   
ioErrorInterrupt
        "A dummy handler for this interrupt"!   
memoryPanicInterrupt
        "Private - virtual machine low memory  interrupt."
    self enableInterrupts: true.
    Warning signal: 'Low on memory. Process terminated'.
    self errorNoWalkback.
    ^self!   
osEventInterrupt
        "Private - handle an OS event (message)."
    SessionModel current isGui ifTrue: [ self osEventInterruptGui ]! 
overrunInterrupt
        "Private - give a bell warning when interrupt queue overruns."
    self enableInterrupts: true.
    OperatingSystem beep! 
terminateActive
        "Private - terminate the active process."
    self current terminateWhileActive!
unknownInterrupt
        "Private - Process an unknown interrupt."!  
protectionViolationInterrupt
        "A protection violation occurred in an API call;
         display a walkback window indicating the error"
    ^self error: 'Protection Violation'!
initializeFrameMarker
        "Private - initialize the unique instance of ProtectedFrameMarker,
        and store it as FrameMarker."
    FrameMarker := self initializeFrameMarker: ProtectedFrameMarker methodDictionaries! 
initializeFrameMarker: methodDictionaryArray
        "Private - ask the virtual machine to allocate the unique instance of
        ProtectedFrameMarker, using the given methodDictionaryArray.
        Answer the allocated instance."
    <primitive: 4>
    ^self primitiveFailed!
stackOverflowInterrupt
        "Private - the Smalltalk stack has overflowed."
    self enableInterrupts: true.
    CurrentProcess stackOverflow!  
queueWalkback: aString makeUserIF: isUserIF resumable: resumeLevel
        "Enter a walkback for current process in pending event queue.
        Create new user interface process if ifBoolean is true."
    | process firstTime callBack guiClass |
    [ firstTime ] yourself.  "this method must have a block."
    ( guiClass := Smalltalk at: #CursorManager ifAbsent: [ nil ] ) notNil
        ifTrue: [ guiClass normal change ].
    self enableInterrupts: false.
    CurrentProcess isBeingDebugged
        ifTrue: [ ^CurrentProcess debugger takeControl: aString ].
    self traceOff.
    firstTime := true.
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
                ifTrue: [ self error: 'process not resumable' ] ]!
controlBreakInterrupt
        "Private - initiate a control-break walkback."
    self enableInterrupts: true.
    SessionModel current isGui
        ifTrue: [ ( Smalltalk at: #KeyboardInterrupt ) signal ]! 
codeCacheClearedInterrupt
        "Private - the generated code cache in the virtual machine
        was cleared."
    self enableInterrupts: true.
    Processor status codeCacheCleared!
gcCompactInterrupt
        "Private - virtual machine memory compact event has happened, check
        for low memory."
    Processor status compact.
    self enableInterrupts: true!
debuggerAvailable
        "Private - answer whether there is a debugger in the current environment.
        Make sure the debugger is 'alive enough' to respond (in case there was
        an error binding the dev component)."
    ^Smalltalk isRunTime not and: [
        ( Smalltalk includesKey: #Debugger ) and: [
            ( Smalltalk at: #Debugger ) respondsTo: #default ] ]!  
frameBiasUnit
        "Private - Answer the amount to change
        frameBias by one pointer."
    ^4!
unwindAt: aMethod
        "Private - Resume the process at the method."
    <primitive: 123>!   
dropSenderChain
        "Discard stacked message sends (sent but not
        answered) to outermost send, the input
        request loop."
    <primitive: 109>!  
enableInterrupts: aBoolean
        "Answer the previous interrupt enable
        state.  Set the interrupt enable
        state to aBoolean."
    <primitive: 118>!   
gcFlipInterrupt
        "Private - virtual machine memory scavenge event has happened, check
        for low memory."
    Processor status flip.
    self enableInterrupts: true! 
copyStack
        "Answer a Process object containing
        the current stack contents."
    <primitive: 108>!   
traceOff
        "Private - Turn off tracing."
    Processor traceMode: 0!  
evaluateProtectionBlock
        "Private - cause the active process to evaluate the first protection block."
    CurrentProcess evaluateProtectionBlock!
unwindRecursion: workProcess
        "Private - Unwind workProcess."
    | m |
    m := ( Smalltalk at: #NotificationManager ) compiledMethodAt: #recursiveMessage.
    self unwindAt: m! 
current
        "Answer the active process."
    ^CurrentProcess!   
errorNoWalkback
        "Private - an error occurred for which we want no walkback window.
        Drop the sender chain and restart the Notifier."
    | process |
    OperatingSystem cleanUpAfterError.
    self enableInterrupts: false.
    CurrentProcess isUserIF ifFalse: [ ^CurrentProcess terminate ].
    process := self copyStack.
    CurrentProcess := self new.
    CurrentProcess makeUserIF.
    process terminate.
    SessionModel current isGui ifTrue: [ SessionModel current runNotifier ]! 
interrupt: interruptNumber
        "Put an interrupt number in the virtual
        machine queue."
    <primitive: 114>
    ^self primitiveFailed!
new
        "Answer a new Process."
    ^super new initialize!  
new
        "Answer an instance of OrderedCollection
         capable of holding 12 elements initially."
    ^self new: 12!
new: anInteger
        "Answer an initialized instance of OrderedCollection
         capable of holding anInteger number of elements."
    ^self basicNew initialSize: anInteger!  
withAll: aCollection
        "Answer an instance of the receiver containing all the elements of the receiver."
    ^( self new: aCollection size )
        addAll: aCollection;
        yourself! 
printOn: aStream
        "Print a textual representation of the receiver on <aStream>."
    aStream
        nextPutAll: self class name;
        nextPutAll: '({';
        nextPutAll: self name;
        nextPutAll: '} Priority: ';
        nextPutAll: self priority printString.
    self isUserIF
        ifTrue: [aStream nextPutAll: ', user interface'].
    self debugger == nil
        ifFalse: [aStream nextPutAll: ', being debugged'].
    aStream nextPutAll: ')'! 
icAt: frameIndex
        "Private - Answer the instruction counter for the stack frame at frameIndex."
    ^self frameAt: frameIndex offset: ReturnOffset!  
methodAt: frameIndex put: compiledMethod
        "Private - Update the compiled method for the stack frame at frameIndex."
    self
        frameAt: frameIndex
        offset: MethodOffset
        put: compiledMethod!
apiFailureReason
        "Answer a value indicating why the last API call made in the receiver process failed."
    ^self protectionBlock!  
printWalkbackArgument: anObject
        "Private - answer a String containing the printable form of anObject for
        a walkback containing message arguments."
    | string |
    anObject isNumber ifTrue: [ ^anObject printString ].
    anObject isString ifTrue: [ string := anObject ].
    string notNil ifTrue: [
        ^anObject size <= 20
            ifTrue: [ string storeString ]
            ifFalse: [ ^( ( string copyFrom: 1 to: ( string size min: 20 ) ), '...' ) storeString ] ].
    ^( anObject class name first isVowel ifTrue: [ 'an' ] ifFalse: [ 'a' ] ), anObject class name!  
environmentArgAt: frameIndex number: argNumber put: anObject
    "Private - Set the arg argNumber from the environment
    of the stack frame at frameIndex to anObject."

    | argCount environment |
    argCount := self argumentCount: frameIndex.
    argNumber > argCount ifTrue: [ self argNumberTooBig: argNumber ].
    environment := self contextFor: frameIndex.
    ^environment isBlockClosure
        ifTrue: [ environment at: argNumber put: anObject ]
        ifFalse: [ environment at: ( ( argCount - argNumber + 1 ) + ( self methodAt: frameIndex ) tempCount ) put: anObject ]!
homeFrameOfClosure: aBlockClosure
        "Private - Answer the stack frame index of the associated method
        frame for the block or method frame identified by frameIndex."
    | offset index lastOffset home |
    home := aBlockClosure methodEnvironment.
    home isNil ifTrue: [ ^0 ].
    offset := self processIndexFromBPLink: self topFrame.
    lastOffset := 0.
    index := 0.
    [ offset = lastOffset ] whileFalse: [
        lastOffset := offset.
        offset := self nextFrameFrom: offset.
        index := index + 1.
        ( home = ( self contextFor: index ) ) ifTrue: [ ^index ] ].
    ^0! 
homeFrameOfContext: aBlock
        "Private - Answer the stack frame index of the associated method
        frame for the block or method frame identified by frameIndex."

    ^aBlock isBlockClosure
        ifTrue: [ self homeFrameOfClosure: aBlock ]
        ifFalse: [ self bpToFrameIndex: aBlock homeContext frameOffset ]!
runable: anInteger
        "Private - Set the receiver's resume level."
    runable := anInteger!   
makeUserIF
        "Make the receiver be the user interface process."
    isUserIF := true.
    name := 'User I/F'.
    priority := Processor userPriority.
    UserInterfaceProcess := self!
argumentCount: frameIndex
    "Private - Answer the number of arguments for the frame at <frameIndex>."

    | environment |
    " With old blocks, the block args are not really args, but rather method temps, so
    we use the method to count args. With BlockClosures, the block args really are args."
    ( self isBlockFrame: frameIndex )
        ifTrue: [
            environment := self contextFor: frameIndex.
            environment isBlockClosure
                ifFalse: [ environment := self methodAt: frameIndex ] ]
        ifFalse: [ environment := self methodAt: frameIndex ].
    ^environment argumentCount!   
walkbackListTo: stopSelector maxLevels: aNumber
        "Private - Answer a collection of stacked message sends."
    
	^self walkbackListTo: stopSelector maxLevels: aNumber filtered: true arguments: false! 
priority
        "Answer an integer representing the receiver process priority."
    ^priority! 
terminationBlock
        "Private - answer the block to be evaluated when the receiver is both
        active and in the process of being terminated."
    ^terminationBlock!  
interruptICAt: frameIndex
        "Private - Answer the instruction counter for the stack frame at frameIndex."
    ^self frameAt: frameIndex offset: ReturnOffset+6!   
visibleWalkbackClassForFrame: frameIndex filtered: filtered
    "If the activation record at the argument frame index <frameIndex> should be visible in a walkback, return the class of the message receiver.  Return nil if the frame should not be displayed.  When <filtered> is false all activation records are visible. <filtered> must always be false during application delivery"

    | aClass method |
    aClass := (self receiverAt: frameIndex) class.
    method := self methodAt: frameIndex.
    filtered
        ifTrue: [(aClass isActivationVisibleForInstanceSelector: method selector)
            ifFalse: [^nil]].
    ^aClass!  
debugger
        "Answer the debugger associated with the receiver, or nil if none."
    ^debugger! 
restartable: aBoolean
        "Private - Make the receiver restartable if aBoolean is true."
    runable := aBoolean ifTrue: [1] ifFalse: [0]
    "1 means restartable, not resumable
      0 means not restartable, not resumable"!  
runTimeError: aString resume: resumeLevel
        "Private - An error has occurred in a runtime app, so write a walkback
        to a log file and display a message box, or invoke a runtime debugger.
        Answer a Boolean indicating whether the receiver process should be terminated."
    | stream pendingEvents |
    ( Smalltalk includesKey: #RuntimeDebugger )
        ifTrue: [
            "If Runtime Debugger is installed then the gui is around"
            pendingEvents := Smalltalk at: #PendingEvents.
            pendingEvents add: ( Message new
                selector: #runtimeErrorIn:label: ;
                arguments: ( Array with: self with: aString ) ).
            ^false ]
        ifFalse: [
            stream := String new asStream.
            stream nextPutAll: 'Runtime error: ', aString; cr; cr.
            self walkbackOn: stream maxLevels: 50 stopSelector: nil filtered: false arguments: true.
            Smalltalk logError: stream contents.

            stream := String new asStream.
            stream nextPutAll: 'Runtime Error: ', aString; cr; nextPutAll: '(see error.log for more information)'.
            Warning signal: stream contents.
            ^true ]!   
homeFrameOf: frameIndex
        "Private - Answer the stack frame index of the associated method
        frame for the block or method frame identified by frameIndex."
    | context homeOffset offset index lastOffset |
    ( context := self contextFor: frameIndex ) isNil
        ifTrue: [ ^frameIndex ].
    context isBlockClosure ifTrue: [ ^self homeFrameOfClosure: context ].
    ( homeOffset := context frameOffset ) = 0
        ifTrue: [ ^0 ].  "already exited"
    homeOffset := ( self stackPointerToProcessIndex: homeOffset ).
    offset := self processIndexFromBPLink: self topFrame.
    lastOffset := 0.
    index := 0.
    [ offset = lastOffset ] whileFalse: [
        lastOffset := offset.
        offset := self nextFrameFrom: offset.
        index := index + 1.
        offset = homeOffset ifTrue: [ ^index ] ].
    ^0!
findFrameIndexOf: aCompiledMethod
        "Private - Answer the frame index of the last occurrence of aCompiledMethod,
        or 0 if none."
    | answer frameIndex index |
    frameIndex := answer := 0.
    index := self processIndexFromBPLink: self topFrame.
    [(self at: index) = 0]
    whileFalse: [
        aCompiledMethod ==
        (self at: index + MethodOffset)
            ifTrue: [
            answer := frameIndex].
        frameIndex := frameIndex + 1.
        index := self nextFrameFrom: index ].
    ^answer! 
debugger: aDebugger
        "Set receiver's debugger to aDebugger."
    debugger := aDebugger!  
firstProtectionBlockWithin: frameCount removeMark: removeMark
        "Private - answer the first protection block within the top
        <frameCount> frames or <nil> if there is none. If a protection
        block is found and <removeMark> is <true>, remove the mark
        on the block indicating that it must be evaluated."
    | count index protectedBlockIndex |
    count := 0.
    index := self processIndexFromBPLink: self topFrame.
    [(self at: index) ~= 0 and: [(count := count + 1) <= frameCount]]
        whileTrue:
            [FrameMarker == (self at: index + ReceiverOffset)
                ifTrue:
                    [protectedBlockIndex := index.
                    index := self nextFrameFrom: index.
                    removeMark
                        ifTrue:
                            [self
                                at: protectedBlockIndex + ReceiverOffset
                                put: (self at: index + ReceiverOffset)].
                        ^self at: index + ArgumentOffset].
            index := self nextFrameFrom: index].
    ^nil!  
frameToProcessIndex: frameIndex
        "Private - Answer the process index of the frameIndex + 1 stack frame."
    ^self processIndexFromBPLink: ( self frameIndexAt: frameIndex )!
numberOfArgsAt: aFrameIndex
        "Private - answer the number of arguments for the method at aFrameIndex."
    ^(self methodAt: aFrameIndex) argumentCount!  
returnOffsetAt: frameIndex
        "Private - Answer the instruction counter for the stack frame at frameIndex."
    ^self frameAt: frameIndex offset: ReturnOffset!
walkbackIndex: index filtered: filtered
    "Calculate real frame index index from debugger index <index>;
         skips methods not displayed in Debugger when <filtered> is true."

    | frameIndex count |
    frameIndex := 0.
    count := 0.
    [count = index]
        whileFalse:
            [frameIndex := frameIndex + 1.
            (self visibleWalkbackClassForFrame: frameIndex filtered: filtered) ~~ nil
                ifTrue: [count := count + 1]].
    ^frameIndex! 
walkbackOn: collector maxLevels: aNumber stopSelector: stopSelector filtered: filtered arguments: arguments
        "Private - display the stacked message sends for the receiver on the collector stream.
        The list will have at most <aNumberElements>.
        The list will terminates after an activation for the selector <stopSelector> is encountered.
        If <filtered> is true, activations for certain system methods are not included in the list.
        If <arguments> is true, message arguments will be included."
    ( self walkbackListTo: stopSelector maxLevels: aNumber filtered: filtered arguments: arguments )
		do: [ :line | collector nextPutAll: line; cr ]!  
initialize
        "Private - Initialize the receiver."
    priority := CurrentProcess priority.
    isUserIF := false.
    name := 'Background'.
    runable := 2.
    interruptFrame := 0.
    terminationBlock :=
        [CurrentProcess isUserIF
            ifTrue: [
                CurrentProcess := self class new.
                CurrentProcess makeUserIF.
                SessionModel current isGui
                    ifTrue: [ SessionModel current runNotifier ] ]
            ifFalse: [ Processor schedule ] ]!   
isBlockFrame: frameIndex
        "Private - Answer true if the frame at <frameIndex> is a block activation frame."

    | context |
    context := self contextFor: frameIndex.
    context isNil ifTrue: [ ^false ].
    context isBlockClosure ifTrue: [ ^true ].
    context class == HomeContext ifFalse: [ ^false ].
    ^( self homeFrameOf: frameIndex ) ~= frameIndex!
terminationBlock: aBlock
        "Private - set the block to be evaluated when the receiver is both
        active and in the process of being terminated to be <aBlock>."
    terminationBlock := aBlock! 
isBeingDebugged
        "Answer whether the receiver is being debugged."
    ^self debugger ~~ nil! 
name
        "Answer the process name."
    ^name!  
name: aString
        "Set the process name to aString."
    name := aString!   
protectionBlock
        "Private - answer the protection block to be evaluated by the receiver."
    ^protectionBlock!  
isUserIF
        "Answer true if receiver is a user interface process."
    ^isUserIF!  
methodAt: frameIndex
        "Private - Answer the compiled method for the stack frame at frameIndex."
    ^self frameAt: frameIndex offset: MethodOffset!  
sendFrame
        "Private - Answer the
         receiver sendFrame."
    ^sendFrame * 2!  
returnOffsetAt: frameIndex put: anOffset
        "Private - Set the instruction counter for the stack frame at frameIndex."
    ^self frameAt: frameIndex offset: ReturnOffset put: anOffset!   
contextFor: frameIndex
        "Private - Answer the context object from
         the stack frame at frameIndex."
    ^( self methodAt: frameIndex) hasBlock
        ifTrue: [ self frameAt: frameIndex offset: ContextOffset ]
        ifFalse: [ nil ]!
evaluateProtectionBlock
        "Private - the receiver must evaluate a protection block in
        order to drop a frame."
    self class enableInterrupts: true.
    self protectionBlock value.
    Processor traceMode: 0.
    self debugger notNil
        ifTrue: [ self debugger debuggingProcess resume ]! 
resume: aFrameIndex
        "Private - Resume the receiver process at aFrameIndex stack frame."
    <primitive: 104>
    ^self primitiveFailed!
receiverAt: frameIndex
        "Private - Answer the receiver from the stack frame at frameIndex."
    ^self frameAt: frameIndex offset: ReceiverOffset!
safelyEvaluate: aMessage
        "Private - evaluate <aMessage> after setting up the termination block
        so that the receiver can be terminated."
    self terminationBlock: [
        self class enableInterrupts: true.
        ^ProcessTermination signal ].
    self class enableInterrupts: true.
    aMessage evaluate!
frameAt: frameIndex offset: offset
        "Private - Answer the instance variable of the frameIndex + 1
        stack frame indicated by offset."
    | index |
    index := self frameToProcessIndex:
    frameIndex.
    ^self at: index + offset!   
stackTempAt: frameIndex number: tempNumber put: anObject
    "Private - Set the tempNumber'th temporary variable
    from the stack frame at frameIndex to anObject."

    | tempOffset |
    tempOffset := TemporaryOffset.
    ( self methodAt: frameIndex ) hasBlock ifTrue: [ tempOffset := tempOffset - 2 ].
    ^self
        frameAt: frameIndex
        offset: ( tempOffset - tempNumber )
        put: anObject!  
= anObject
        "This is the default equality test.  Answer true
         if the receiver and anObject are the same object,
         else answer false."
    ^self == anObject!
terminateWithoutProtection
        "Terminate the receiver without causing protection
        blocks to be executed."
    Processor unschedule: self.
    self == CurrentProcess ifTrue: [ Processor schedule ]!  
resume
        "Resume the receiver process."
    CurrentProcess := self.
    self isUserIF ifTrue: [UserInterfaceProcess := self].
    self resume: 0!   
stackTempAt: frameIndex number: tempNumber
    "Private - Answer the tempNumber'th temporary variable
    from the stack frame at frameIndex."

    | tempOffset |
    tempOffset := TemporaryOffset.
    ( self methodAt: frameIndex ) hasBlock ifTrue: [ tempOffset := tempOffset - 2 ].
    ^self
        frameAt: frameIndex
        offset: ( tempOffset - tempNumber )!
hash
        "Answer the integer hash value of the receiver.  This
         is the default implementation which uses the object
         hash value assigned at the creation time."
    ^self basicHash!  
terminateWhileActive
        "Private - terminate the receiver."
    self terminationBlock value!   
restartAt: frameIndex
        "Private - Restart the process at the method described
        in the stack frame at frameIndex."
    frameIndex  timesRepeat: [ self dropFrame ].
    self debugger notNil ifTrue: [
        self debugger setDebuggedProcess: nil.
        self debugger debuggingProcess: nil.
        self debugger: nil ].
    self resume!
walkbackListTo: stopSelector maxLevels: aNumber filtered: filtered arguments: arguments
        "Private - answer a collection of stacked message sends.
        The list will have at most <aNumberElements>.
        The list will terminate after an activation for the selector <stopSelector> is encountered.
        If <filtered> is true, activations for certain system methods are not included in the list.
        If <arguments> is true, arguments will be included."
    | filtering lastSelector collection currentLine frameIndex count aClass blockActivation method keywords arg |
    filtering := Smalltalk isRunTime not & filtered.
    filtering
        ifTrue: [lastSelector := stopSelector]
        ifFalse: [lastSelector := Object new "matches nothing"].
    collection := OrderedCollection new.
    currentLine := WriteStream on: (String new: 50).
    frameIndex := count := 0.
    [frameIndex := frameIndex + 1.
    count >= aNumber or: [(self frameAt: frameIndex offset: 0) = 0]]
        whileFalse:
            [aClass := self visibleWalkbackClassForFrame: frameIndex filtered: filtering.
            aClass == nil
                ifFalse:
                    [currentLine reset.
                    count := count + 1.
                 (blockActivation := self isBlockFrame: frameIndex)
                     ifTrue: [currentLine nextPutAll: '[] in ']
                        ifFalse: [currentLine nextPutAll: aClass name].
                    (method := self methodAt: frameIndex) == nil
                        ifTrue: [ currentLine nextPutAll: '>>-unknown selector-' ]
                        ifFalse: [
                            blockActivation
                                ifTrue: [ currentLine nextPutAll: method classField name ]
                                ifFalse: [ method classField = aClass ifFalse: [
                                    currentLine
                                        nextPut: $(;
                                        nextPutAll: method classField name;
                                        nextPut: $)] ].
                            currentLine nextPutAll: '>>'.
                            ( ( method selector includes: $: ) not or: [ arguments not or: [ blockActivation ] ] )
                                ifTrue: [ currentLine nextPutAll: method selector ]
                                ifFalse: [
                                    keywords := method selector asArrayOfSubstringsSeparatedBy: $: .
                                    1 to: keywords size do: [ :argIndex |
                                        arg := self argAt: frameIndex number: argIndex.
                                        arg := self printWalkbackArgument: arg.
                                        currentLine nextPutAll: ( keywords at: argIndex ), ': <', arg, '> ' ] ].
                            (method selector = lastSelector and: [blockActivation not])
                                ifTrue:
                                    [collection add: currentLine contents.
                                    ^collection]].
                    collection add: currentLine contents]].
    ^collection! 
runable
        "Private - Answer the receiver's resume level."
    ^runable!   
resumeWithInterrupt: interruptSymbol
        "Private - resume the receiver process, and generate a VM
        interrupt with the <interruptSymbol> as the argument. When
        the message #vmInterrupt: is received, interrupts will be enabled."
    self class enableInterrupts: false.
    CurrentProcess := self.    "This line is a workaround until the primitive is fixed."
    CurrentProcess isRecursive
        ifTrue: [ CurrentProcess terminateWithoutProtection ].
    self runable: 16.
    self primitiveResumeWithInterrupt: interruptSymbol!   
exceptionEnvironment
        "Private - answer the head of the list of active exception handlers."
    ^exceptionEnvironment!   
evaluateOneProtectionBlock
        "Private - the receiver must evaluate a protection block in order
        to drop a frame."
    | firstTime |
    [ firstTime ] yourself.
    firstTime := true.
    self class copyStack.
    firstTime ifTrue: [
        firstTime := false.
        self resumeWithInterrupt: #evaluateProtectionBlock ]!  
flushExceptionEnvironment
        "Private - flush the list of active exception handlers associated
        with the receiver."
    self exceptionEnvironment: nil!
argNumberTooBig: argNumber
    "Private - Signal an error."

    self error: 'argNumber too big: ',argNumber printString!  
terminate
        "Terminate the receiver, causing all protection blocks to be executed."
    | firstTime |
    [ firstTime ].  "this method must have a block."
    self == UserInterfaceProcess ifTrue: [
        "make sure we still have an active UI process"
        isUserIF := false.
        [ CurrentProcess makeUserIF.
            SessionModel current isGui ifTrue: [ SessionModel current runNotifier ] ] fork ].
    self == CurrentProcess
        ifTrue: [ ^self terminateWhileActive ].
    firstTime := true.
    self class copyStack.
    firstTime
        ifTrue: [
            firstTime := false.
            Processor schedule: CurrentProcess.
            self resumeWithInterrupt: #terminateActive ]
        ifFalse: [ self class enableInterrupts: true ]!   
walkbackOn: collector maxLevels: aNumber stopSelector: stopSelector
        "Private - Display the stacked message sends for the receiver on the
        collector stream."
	( self walkbackListTo: stopSelector maxLevels: aNumber filtered: true arguments: false )
		do: [ :line | collector nextPutAll: line; cr ]
! 
walkbackIndex: index
	"Private- Calculate real index from debugger index;
         skips methods not displayed in Debugger."
	^self walkbackIndex: index filtered: true!   
environmentArgAt: frameIndex number: argNumber
    "Private - Answer arg argNumber from the environment
    of the stack frame at frameIndex."

    | argCount environment |
    argCount := self argumentCount: frameIndex.
    argNumber > argCount ifTrue: [ self argNumberTooBig: argNumber ].
    environment := self contextFor: frameIndex.
    ^environment isBlockClosure
        ifTrue: [ environment at: argNumber ]
        ifFalse: [ environment at: ( ( argCount - argNumber + 1 ) + ( self methodAt: frameIndex ) tempCount ) ]!   
restartable
        "Private - Answer true if the receiver can be restarted."
    ^runable > 0! 
isRecursive
        "Private - Answer true if the receiver has been called
         recursively by the host OS."
    | method |
    SessionModel current isGui ifFalse: [ ^false ].
    method := ( Smalltalk at: #NotificationManager ) compiledMethodAt: #recursiveMessage.
    ^( ( self findFrameIndexOf: method ) = 0 ) not!   
stackArgAt: frameIndex number: argNumber
    "Private - Answer arg argNumber from the stack frame at frameIndex."

    | argCount |
    argCount := self argumentCount: frameIndex.
    argNumber > argCount ifTrue: [ self argNumberTooBig: argNumber ].
    ^self
        frameAt: frameIndex
        offset: ( ArgumentOffset + ( argCount - argNumber ) )!
environmentTempAt: frameIndex number: tempNumber
    "Private - Answer the tempNumber'th temporary variable
    from the environment of the stack frame at frameIndex."

    ^( self contextFor: frameIndex ) at: tempNumber! 
stackArgAt: frameIndex number: argNumber put: anObject
    "Private - Set arg argNumber from the stack frame at frameIndex to anObject."

    | argCount |
    argCount := self argumentCount: frameIndex.
    argNumber > argCount ifTrue: [ self argNumberTooBig: argNumber ].
    ^self
        frameAt: frameIndex
        offset: ( ArgumentOffset + ( argCount - argNumber ) )
        put: anObject!  
frameAt: frameIndex offset: offset put: value
        "Private - Set the instance variable of the frameIndex + 1
         stack frame indicated by offset to value."
    | index |
    index := self frameToProcessIndex:
    frameIndex.
    self at: index + offset put: value!   
primitiveResumeWithInterrupt: interruptSymbol
        "Private - resume the receiver process, and generate a VM interrupt
        with the <interruptSymbol> as the argument. When the message
        #vmInterrupt: is received, interrupts will be enabled."
    <primitive: 3>
    ^self primitiveFailed! 
bpToFrameIndex: aStackPointer
        "Private - Answer the process index
        of the frameIndex + 1 stack frame."
    | processIndex biasUnit nextFrame index bpIndex|
    biasUnit := self class frameBiasUnit.
    bpIndex := self stackPointerToProcessIndex: aStackPointer.
    processIndex := self processIndexFromBPLink: self topFrame.
    index := 0.
    [processIndex = bpIndex] whileFalse: [
        nextFrame := self nextFrameFrom: processIndex.
        processIndex = nextFrame
            ifTrue: [self error: 'End of stack frame chain'].
        processIndex := nextFrame.
        index := index + 1].
    ^index!
argAt: frameIndex number: argNumber
        "Private - Answer arg argNumber from
        stack frame at frameIndex."
    | context method argCount |
    method := self methodAt: frameIndex.
    argCount:= method argumentCount.
    argNumber > argCount ifTrue: [
        self error: 'argNumber too big: ' ,argNumber printString ].
    context := self contextFor: frameIndex.
    context class == HomeContext
        ifTrue: [ "access from context"
            ^context at: ( ( argCount - argNumber + 1 ) + method tempCount ) ]
        ifFalse: [ "access from stack"
            ^self frameAt: frameIndex offset: (  ArgumentOffset + ( argCount - argNumber ) ) ].!
stackOverflow
        "Private - Pop-up a walkback window describing the stack overflow
        condition (too many stacked message sends).  This message is sent by
        the virtual machine."
    self error: 'stack overflow'!  
exceptionEnvironment: exceptionHandler
        "Private - set the head of the list of active exception handlers
        to be the given <exceptionHandler>."
    exceptionEnvironment := exceptionHandler! 
dropTo: aCompiledMethod
        "Private - discard all stack entries preceding the last occurrence
        of <aCompiledMethod>."
    | dropCount |
    dropCount := self findFrameIndexOf: aCompiledMethod.
    self dropFrames: dropCount - 1! 
environmentTempAt: frameIndex number: tempNumber put: anObject
    "Private - Set the tempNumber'th temporary variable
    from the environment of the stack frame at frameIndex to anObject."

    ^( self contextFor: frameIndex ) at: tempNumber put: anObject!
protectionBlock: aBlock
        "Private - set the protection block to be evaluated by the receiver to be <aBlock>."
    protectionBlock := aBlock! 
interruptFrame: aFramePointer
        "Private - Set the interrupt
         frame to aFramePointer."
    interruptFrame:= aFramePointer // 2!  
dropFrame
        "Private - discard the top stack frame from the receiver's stack.
        Requires that the receiver not be active."
    self dropFrames: 1! 
dropFrames: frameCount
        "Private - discard the top <frameCount> stack frames
        from the receiver's stack. Requires that the receiver
        not be active.  Assumes the receiver is being debugged."
    | topFrameBeforeResumption sendFrameBeforeResumption runableBeforeResumption |
    self == CurrentProcess
        ifTrue: [ ^self error: 'cannot drop frames from the active process.' ].
    frameCount = 0 ifTrue: [ ^self ].
    self class enableInterrupts: false.
    sendFrameBeforeResumption := sendFrame.
    topFrameBeforeResumption := self topFrame.
    runableBeforeResumption := self runable.
    self sendFrame: ( self processIndexToStackPointer: topFrameBeforeResumption ).
    self debugger notNil
        ifTrue: [ self debugger debuggingProcess: CurrentProcess ].
    [ self protectionBlock: ( self
        firstProtectionBlockWithin: frameCount
        removeMark: true ).
        self protectionBlock ~~ nil ]
            whileTrue: [
                self debugger notNil
                    ifTrue: [ self debugger expandFrame: ( self homeFrameOfContext: self protectionBlock ) ].
                self evaluateOneProtectionBlock ].
    self debugger notNil
        ifTrue: [ self debugger debuggingProcess: nil ].
    self runable: runableBeforeResumption.
    self topFrame = topFrameBeforeResumption ifTrue: [
        frameCount timesRepeat: [ self dropFrameWithoutProtection].
        sendFrame := sendFrameBeforeResumption]!
priority: aNumber
        "Change the priority of the receiver process to aNumber."
    ( aNumber between: 1 and: 8 )
        ifFalse: [ self error: 'priority ', aNumber printString, ' is out of range' ].
    priority := aNumber! 
evaluate: aMessage
        "Private - force the receiver, which MUST be the current process,
        to evaluate <aMessage>, forgetting everything else it was doing before."
    self class enableInterrupts: false.
    self class dropSenderChain.
    self class copyStack.
    self flushExceptionEnvironment.
    self safelyEvaluate: aMessage.
    self terminationBlock: [
        Notification signal: 'Process already terminated'.
        self terminateWithoutProtection ].
    self runable: 0.
    "Do not trace in the debugger past this point."
    self class enableInterrupts: false.
    self terminateWithoutProtection.
    Processor schedule!
sendFrame: aFramePointer
        "Private - Set the receiver
         send frame to aFramePointer."
    sendFrame := aFramePointer // 2!   
dropFrameWithoutProtection
        "Private - discard the top stack frame from the receiver's stack without running
        any protection blocks. Requires that the receiver not be active."
    | amountToPop newTopFrame method currentHomeContext |
    newTopFrame := self nextFrameAt: 0.
    "Amount above frame to pop."
    amountToPop := self frameToProcessIndex: 0.
    method := self methodAt: 0.
    method hasBlock
        ifTrue: [currentHomeContext := self frameAt: 0 offset: -3].
    self frameBiasDelta: amountToPop - 1.
    self topFrame: newTopFrame.
    currentHomeContext isNil
        ifTrue: [currentHomeContext := self removeFirst]
        ifFalse: [self removeFirst].
    amountToPop - 1
        timesRepeat: [self removeFirst].
    self addFirst: currentHomeContext!
walkbackOn: collector maxLevels: aNumber
        "Private - display the stacked message sends for
        the receiver on the collector stream.  Maintained for
        backward compatibility."
    ^self walkbackOn: collector maxLevels: aNumber stopSelector: nil filtered: false arguments: false!   
rightBottomUnit
        "Answer the right bottom corner for a one-unit rectangle."
    ^1@1!
initCollateTable
        "Private - Initialize the receiver's collateTable with
          the character collate sequence for the current
          host system settings. The table is a byte array
          of 256 elements. The index is the value of the
          character and the contents is its collate weight.
          The collate weight is the value used to determine
          if a character appears before or after another
          character in a sorted list."

    | collection aString bString n |
    ( (NationalLanguage collateTable) notNil
        and: [(self country = NationalLanguage country)
        and: [self language = NationalLanguage language]] )
        ifTrue: [
            self collateTable: (NationalLanguage collateTable).
            self collateTablei: (NationalLanguage collateTablei).]
        ifFalse: [
           aString := String new: 4.
           bString :=  String new: 4.

            "Make case sensitive table for character comparison"
           collection := SortedCollection sortBlock: [ :a :b |
               aString at: 1 put: a.
               bString at: 1 put: b.
               (self string: aString isLessThan: bString)].
           0 to: 255 do: [ :i | collection add: (i asCharacter)].
           collateTable := ByteArray new: 256.
           1 to: 256 do: [ :i |
               collateTable at: ((collection at: i) asInteger + 1) put: (i - 1)].

            "Make case insensitive table for string comparison"
            collateTablei := ByteArray new: 256.
            n := 0.
            collateTablei at: ((collection at: 1) asInteger + 1) put: n.
            2 to: 256 do: [ :i |
                aString at: 1 put: (collection at: i - 1 ).
                bString at: 1 put: (collection at: i ).
                (self string: aString isGreaterThanOrEqualTo: bString)
                     ifFalse: [ n := n + 1 ].
                collateTablei at: ((collection at: i) asInteger + 1) put: n ].
            self collateTablei: collateTablei.
        ].!  
open: anAttr mode: aMode 
        "Open the file with a new file handle with attribute anAttr 
         and aMode as the file open mode. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details." 

    self isOpen ifTrue: [self close].
    self fileId: (FileHandle open: self name in: self directory 
        attribute: anAttr mode: aMode)! 
initializeSystemColors
        "Private - clear cached SystemColors."
    SystemColors := Dictionary new!   
messageText
	"Answer the message text associated with this exception."

	^'API failed in API startup primitive for an unknown reason'! 
uShortAtOffset: anInteger put: anObject
        "Store anObject at anInteger in the receiver.
         Offsets are zero relative."
    | off low |
    low := anObject bitAnd: 16rFFFF.
    off := anInteger + 1.
    self at: off put: ( low bitAnd: 16rFF ).
    self at: off + 1 put: ( low bitShift: -8 ).
    ^anObject! 
drive: aCharacter
        "Initialize the drive for the
         receiver to aCharacter."
    
	fileSystemLocator == nil
		ifTrue: [ self fileSystemLocator: ( FileSystemPath absolute: ( Array with: ( String with: aCharacter ) ) ) ]
		ifFalse: [ self fileSystemLocator: ( ( FileSystemPath absolute: ( Array with: ( String with: aCharacter ) ) ), self fileSystemLocator pathName ) ]!   
setDBCSInfo
        "Private - set DBCS state for current national language. "
    | flag |
    leadBytes := Array new: 255.  " indexed by code point value [1..255] "
    isDoubleByteCp := false.
    1 to: 255 do: [ :cp |
        flag := KernelLibrary isDBCSLeadByte: cp.
        flag ifTrue: [ isDoubleByteCp := true ].
        leadBytes at: cp put: flag].
    ( isDoubleByteCp )
        ifTrue: [ ^self ].

   "Double-Byte system Windows 3.1 + Win32:
    This is a workaround for a bug in isDBCSLeadByte
    API returning false for the entire range. "
   ( self country = 886 )        "Chinese (Traditional)"
    ifTrue: [
        161 to: 198 do: [ :cp | leadBytes at: cp put: true ].
        201 to: 249 do: [ :cp | leadBytes at: cp put: true ].
        isDoubleByteCp := true. ^self].
   ( self country = 86 )         "Chinese (Simplified)"
    ifTrue: [
        161 to: 169 do: [ :cp | leadBytes at: cp put: true ].
        176 to: 247 do: [ :cp | leadBytes at: cp put: true ].
        isDoubleByteCp := true. ^self].

   ( self country = 81 )         "Japanese"
    ifTrue: [
        129 to: 159 do: [ :cp | leadBytes at: cp put: true ].
        224 to: 252 do: [ :cp | leadBytes at: cp put: true ].
        isDoubleByteCp := true. ^self].

   ( self country = 82 )         "Korean"
    ifTrue: [
        161 to: 172 do: [ :cp | leadBytes at: cp put: true ].
        176 to: 200 do: [ :cp | leadBytes at: cp put: true ].
        202 to: 253 do: [ :cp | leadBytes at: cp put: true ].
        isDoubleByteCp := true. ^self].!
filesDo: iterationBlock
    "Evaluate the <iterationBlock> once for each file contained within the receiver. Each file passed to the iteration block should be released by the iteration block if it is not retained in some way.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated files."

	self searchResultsDo: [:searchResult |
		searchResult isFile
			ifTrue: [iterationBlock value:searchResult entity]]!   
memoryHandleFrom: aVariableByteObject
        "Private - Copy aVariableByteObject into non-Smalltalk memory
         by doing a GlobalAlloc.  Maintained for backward compatibility."
    self checkGlobalAddress.
    ^ExternalGlobalAddress memoryHandleFrom: aVariableByteObject!  
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it."

    Process
        queueWalkback: self description
        makeUserIF: CurrentProcess isUserIF
        resumable: 1!   
queryProcAddr: aString
        "Answer the address of the function named aString in the
         receiver DLL (a WinAddress), or an Integer error code (0)"
    | address |
    address := KernelLibrary getProcAddress: self procName: aString asParameter.
    ( address := ExternalAddress fromString: address ) asInteger = 0
        ifTrue: [ ^address asInteger ].
    ^address!
fileSystem
        "Private - answer the name of the file system for this volume."
	^self volume fileSystem!
removeActionsForEvent: eventName
        "Remove all actions for the event named <eventName>."
    | table |
    table := self eventTable.
    table removeKey: eventName asSymbol ifAbsent: [].
    table isEmpty
        ifTrue: [self releaseEventTable]!
allocateMemory: size flags: allocFlags
        "Allocate <size> number of bytes in host global memory with <allocFlags>.
         Answer an Address for the allocated memory."
    | handle addressPtr address |
    ( handle := KernelLibrary globalAlloc: allocFlags bytes: size ) = 0
        ifTrue: [ ^self osError ].
    ( addressPtr :=  KernelLibrary globalLock: handle ) = 0
        ifTrue: [ ^self osError ].
    address := self fromInteger: addressPtr.
    address memoryHandleObject: ( ExternalGlobalHandle fromInteger: handle ).
    address memorySize: size.
    address needsFinalization.
    ^address!  
lastModificationTime
    "Answer a TimeStamp of the date and time at which the receiver was last modified."

    ^self directory lastWriteTimeForEntityNamed: self name!   
makeCurrent
    "Make the receiver be the current directory."
 
    ( KernelLibrary setCurrentDirectory: self absolutePathString asParameter )
        ifFalse: [ ^self osError ]!
ifCurtailed: exceptionBlock
        "Return the result of evaluating the receiver. If a block attempts
        to return from a method which (indirectly) invoked the receiver,
        either directly or indirectly, evaluate the <exceptionBlock>
        before returning from the enclosing method. The exception block
        will not be evaluated if the receiver is allowed to return normally.
        Implementation Comments:  The receiver is evaluated by sending
        the receiver the message #value."
    ^self
        setUnwind:
            [:aContext :returnValue |
            exceptionBlock value.
            aContext return: returnValue]!
defaultInitialSize
        "Private-  Answer the default initial size for instances being created
        without an initial size being given."

    ^4!  
newSize: anInteger
        "Obsolete, use new: instead - Answer an IdentityDictionary
         capable of containing anInteger number of elements."
    ^(super new: anInteger * 2)!   
initialSize
        "Private - Answer the initial number of elements
         that a new instance of IdentityDictionary
         contains."
    ^8!   
directorySeparator
    "Answer a string containing the characters used to separate the name of a directory from the name of a contained entity in a path string."

    ^'\'!   
isClass
        "Answer true if receiver is a kind of Class."
    ^false!   
isSmallInteger
        "Answer true if receiver is a kind of SmallInteger."
    ^false! 
down: aNumber
        "Answer the difference between
         the receiver and aNumber."
    ^self + aNumber!  
lastWriteTimeForEntityNamed: aString
    "Answer the last write time (as a TimeStamp) for the entity in the receiver named <aString>"

    self
        searchResultsDo:
            [:searchResult |
            (searchResult entityName equalsIgnoreCase: aString)
                ifTrue: [^searchResult lastWriteTime]].
    ^nil!   
new: aString
        "Answer a new pattern with aString
         as the pattern to match."
    ((aString includes: WildcardChar)
        or: [aString includes: (String with: WildcardChar)])
            ifTrue: [^WildPattern new: aString]
            ifFalse: [^super new build: aString]! 
wildcardChar
        "Answer the wild card character."
    ^WildcardChar!   
reset
        "Reset the receiver to start matching
         at the beginning of the pattern."
    state := 1! 
build: aCollection
        "Private - Initialize the receiver to
         match the pattern aCollection."
    | prevIn prevFail |
    state := 1.
    matchBlock := [].
    input := aCollection.
    fail := Array new: aCollection size.
    input size = 0 ifTrue: [^self].
    first := aCollection at: 1.
    fail at: 1 put: 1.
    input size = 1 ifTrue: [^self].
    fail at: 2 put: 1.
    3 to: input size do: [ :i |
        prevIn := input at: i - 1.
        prevFail := fail at: i - 1.
        [(input at: prevFail) = prevIn or: [
            prevFail = 1]]
            whileFalse: [prevFail := fail at: prevFail].
        (aCollection at: prevFail) = prevIn
            ifTrue: [fail at: i put: prevFail + 1]
            ifFalse: [fail at: i put: 1]]!   
input
        "Private - Answer the pattern string to
         which the input is compared."
    ^input!   
matchBackward: aCollection index: anInteger
        "Answer a Point representing the start and
         stop of the subcollection within aCollection
         that matches the receiver starting at index
         position anInteger.  Answer nil if no match."
    ^self matchBackward: aCollection index: anInteger
        each: [:x | x]!  
match: aCollection index: anInteger
        "Answer a Point representing the start and
         stop of the subcollection within aCollection
         that matches the receiver starting at index
         position anInteger.  Answer nil if no match."
    ^self match: aCollection index: anInteger
        each: [:x | x]!  
failAt: aState with: aCharacter
        "Private - Answer the next state
         after the match failed at aState
         with aCharacter."
    | curState |
    curState := aState.
    [true] whileTrue: [
        curState := fail at: curState.
        (input at: curState) = aCharacter
            ifTrue: [^curState + 1].
        curState = 1
            ifTrue: [^1]]!   
matchBlock: aBlock
        "Set the match block of the receiver to
         aBlock.  This block will be evaluated
         when the pattern is fully matched."
    matchBlock := aBlock!  
match: aCollection index: anInteger each: aOneArgumentBlock
        "Answer a Point representing the start and
         stop of the subcollection within aCollection
         that matches the receiver starting at index
         position anInteger.  Evaluate aOneArgumentBlock
         for each element of aCollection.  Answer nil if no match."
    | firstChar index |
    input size = 0 ifTrue: [^nil].
    state := 1.
    firstChar := input at: 1.
    index := anInteger.
    [true] whileTrue: [
        index > aCollection size ifTrue: [^nil].
        (aOneArgumentBlock value: (aCollection at: index)) = firstChar ifTrue: [
            state := state + 1.
            [state > input size
                ifTrue: [^index + 1 - input size @ index].
             (index := index + 1) > aCollection size
                ifTrue: [^nil].
             (input at: state) = (aOneArgumentBlock value: (aCollection at: index))
                ifTrue: [
                    state := state + 1]
                ifFalse: [
                    state := (self failAt: state with:
                        (aOneArgumentBlock value: (aCollection at: index)))].
             state = 1]
                whileFalse: []].
        index := index + 1]!  
match: anObject
        "Compare anObject against the pattern.
         If anObject completes the matching of
         the pattern, evaluate the match block."
    state <= input size
        ifTrue: [
            state == 1
                ifTrue: [
                    first = anObject
                        ifTrue: [state := 2]
                        ifFalse: [^false]]
                ifFalse: [
                    anObject = (input at: state)
                        ifTrue: [state := state + 1]
                        ifFalse: [
                            state := fail at: state.
                            ^self match: anObject]]].
    state > input size
        ifFalse: [^false].
    state := 1.
    matchBlock value.
    ^true! 
matchBackward: aCollection index: anInteger each: aOneArgumentBlock
        "Answer a Point representing the start and
         stop of the subcollection within aCollection
         that matches the receiver starting at index
         position anInteger.  Evaluate aOneArgumentBlock
         for each element of aCollection.  Answer nil if no match."
    | lastChar index inputSize |
    (inputSize := input size) = 0 ifTrue: [^nil].
    state := inputSize.
    lastChar := input at: inputSize.
    index := anInteger.
    [index > 0] whileTrue: [
        index > aCollection size ifTrue: [^nil].
        (aOneArgumentBlock value: (aCollection at: index)) = lastChar ifTrue: [
            state := state - 1.
            [state < 1
                ifTrue: [^index @ (index + inputSize - 1)].
             (index := index - 1) < 1
                ifTrue: [^nil].
             (input at: state) = (aOneArgumentBlock value: (aCollection at: index))
                ifTrue: [
                    state := state - 1]
                ifFalse: [
                    state := inputSize].
             state ~= inputSize]
                whileTrue: []].
        index := index - 1].
    ^nil!
message: msg
        "Signal that the argument message was not understood."
    ^(self new message: msg) signal!
defaultClass
        "Private - answer the default exception class."
    DefaultClass isNil ifTrue: [ ^self ].
    ^DefaultClass isClass
        ifTrue: [ DefaultClass ]
        ifFalse: [ Smalltalk at: DefaultClass ]!   
defaultClass: aClassOrSymbol
        "Private - set the default exception class."
    DefaultClass := aClassOrSymbol!   
message
        "Answer the object that describes the unsuccessful message send."
    ^message! 
message: aMessage
        "Set the object that describes the unsuccessful message send."
    message := aMessage!   
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it."
    Process
        queueWalkback: self defaultDescriptionString
        makeUserIF: CurrentProcess isUserIF
        resumable: 2.
    ^self message perform!
defaultDescriptionString
        "Private - this is used to obtain a textual description of the
        exception if an explicit description has not been provided.
        Subclass will frequently override this method."
    ^'"' , self message selector , '" not understood'!
isResumable
        "Return true if this is a resumable exception."
    ^true!  
dependents
        "Answer the collection containing the dependents of the receiver.
        This method assumes that the actions for the changed event
        are always either a Message or an ActionSequence that contains
        only Messages."
    ^(self actionListForEvent: self changedEventName)
        collect:
            [:each |
            each receiver]!
fromAddress: anExternalAddress
        "Answer a DoubleByteString whose bytes are copied
        from memory at anExternalAddress."
    | s charIndex byteIndex |
    s := self new: 1.
    charIndex := 1.
    byteIndex := 1.
    [s replaceBytesFrom: 1
          to: 2
          with: anExternalAddress
          startingAt: byteIndex.
    (s at: 1) asciiValue = 0] whileFalse: [
        charIndex := charIndex + 1.
        byteIndex := byteIndex + 2].
    ^self fromAddress: anExternalAddress length: charIndex - 1.! 
fromMixedString: aString
        " Answer a DoubleByteString representing aString.  The
        single-byte characters of aString are interpreted as a
        mixed-string encoding using the current leadByte array."
    ^(NationalLanguage isDoubleByteCp)
        ifTrue: [self fromMixedString: aString leadBytes: NationalLanguage leadBytes]
        ifFalse: [self fromString: aString].!  
fromAddress: anExternalAddress length: anInteger
        "Answer a DoubleByteString of size anInteger characters
         whose bytes are copied from memory at anExternalAddress."
    | t |
    t := self new: anInteger.
    t replaceFrom: 1
          to: anInteger
          withAddress: anExternalAddress
          startingAt: 1.
   ^t!
new: anInteger
        " Answer a new DoubleByteString containing anInteger characters. "
    ^super new: (anInteger * 2)!  
fromString: aString
        " Answer a DoubleByteString containing the characters
        of aString. "
    | stringSize dbString dbByteIndex |
    aString isDoubleByteString ifTrue: [ ^aString ].
    stringSize := aString size.
    (stringSize = 0) ifTrue: [^self new].  " degenerate case "
    dbString := self new: stringSize.
    dbByteIndex := 0.
    aString do: [ :trailByte |
        dbByteIndex := dbByteIndex + 2.  " lead byte is already 0 "
        dbString basicAt: dbByteIndex put: trailByte].
    ^dbString!  
fromMixedString: aString leadBytes: leadByteFlags
        " Answer a DoubleByteString representing aString.  The
        single-byte characters of aString are interpreted as a
        mixed-string encoding, based on the given leadByteFlags
        array of Booleans. "
    | stringSize aDBString |
    stringSize := aString size.
    (stringSize = 0) ifTrue: [^self new].
    aDBString := self new: (aString sizeOfNormalizedString: leadByteFlags).
    aDBString fromMixedString: aString leadBytes: leadByteFlags.
    ^aDBString!
byteIndexOfCharAt: anInteger
        "Private - answer the index of the lead byte of
          the character at anInteger in the receiver. "
    ^(anInteger * 2) - 1! 
charIndexOfByteAt: anInteger
        " Private - answer the index of the character containing
          the byte anInteger in the receiver. "
    ^(anInteger + 1) // 2!   
replaceBytesFrom: byteStart
    to: byteStop
    with: aCollection
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aCollection beginning at index
         position repStart.  Answer the receiver."
    | index1 index2 |
    <primitive: 80>
    (aCollection class isBytes)
        ifFalse: [
            ^super
                replaceFrom: (self charIndexOfByteAt: byteStart)
                to: (self charIndexOfByteAt: byteStop)
                with: aCollection
                startingAt: byteRepStart].
    " primitive failure on large byte objects "
    (self == aCollection and: [byteRepStart < byteStart])
        ifTrue: [ "do backward move for same object"
            index2 := byteRepStart + byteStop - byteStart.
            index1 := byteStop.
            [byteStart <= index1]
                whileTrue: [
                self
                    basicAt: index1
                    put: (aCollection basicAt: index2) asCharacter.
                index1 := index1 - 1.
                index2 := index2 - 1].
            ^self].
    "do forward move"
    index2 := byteRepStart.
      index1 := byteStart.
      [index1 <= byteStop]
           whileTrue: [
              self
                   basicAt: index1
                put: (aCollection basicAt: index2) asCharacter.
               index1 := index1 + 1.
              index2 := index2 + 1].!  
asByteArray
        "Answer a ByteArray whose contents are the
         bytes of the receiver.  Each character in the
         receiver is represented by two bytes in the
         ByteArray, where the first byte of each pair
         is the high-order lead byte of the character
         and the second byte is the low-order trail
         byte of the character."
    | b |
    b := ByteArray new: self basicSize.
    ^b replaceFrom: 1 to: b size with: self startingAt: 1.!   
asParameter
        "Answer the receiver in a form suitable for passing
         as a parameter to a procedure call."
    ^self asExternalString!  
replaceFrom: start to: stop withObject: aCharacter
        "Replace the characters of the receiver
         at index positions start through stop
         with aCharacter.  Answer aCharacter."
    | index |
    index := start.
    [index <= stop]
        whileTrue: [
            self at: index put: aCharacter.
            index := index + 1].
    ^aCharacter!   
containsDBCharacter
        " Answer whether the receiver contains
        any double-byte characters. "
    <primitive: 132>
    ^self primitiveFailed!  
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each element."
    | copy aClass elements |
    aClass := self class.
    elements := self size.
    copy := aClass new: elements.
    1 to: elements do: [ :index |
        copy at: index put: (self at: index)].
    ^copy!   
replace: count with: aCollection
        "Replace count characters of the receiver
         with characters of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    | sourceClass sourceBytes |
    sourceClass := aCollection class.
    sourceBytes :=
        ((sourceClass == String) or: [sourceClass == Symbol])
            ifTrue: [self class fromString: aCollection]
            ifFalse: [aCollection].
    self replaceBytes: (count * 2) with: sourceBytes!   
asSymbol
        "Answer a symbol whose characters
         are the same as the receiver string."
    ^self containsDBCharacter
        ifTrue: [DoubleByteSymbol intern: self]
        ifFalse: [Symbol intern: self asMixedString]!
size
        " Answer the number of characters in the receiver string. "
    ^super size // 2!  
fromMixedString: aString leadBytes: leadByteFlags
        " Private - Fills the receiver with characters of aString
        interpreted as a mixed-length encoding, based on the
        given leadByteFlags array of Booleans.  Answers
        the number of double-byte characters filled."
    <primitive: 129>
    ^self primitiveFailed!  
asAsciiZ
        "Answer a new String containing the characters
         of the receiver in mixed-string encoding, followed
         by one character of code point value zero. "
    ^self asMixedStringWithNull: true!  
do: aBlock
        "Answer the receiver.  For each character in the receiver,
         evaluate aBlock with that character as the argument."
    | byteIndex lastCharByteIndex |
    byteIndex := 1.
    lastCharByteIndex := self basicSize - 1.
    [byteIndex > lastCharByteIndex]
        whileFalse: [
            aBlock value: (Character
                leadByte: (self basicAt: byteIndex)
                trailByte: (self basicAt: (byteIndex + 1))).
            byteIndex := byteIndex + 2]! 
at: anInteger put: aCharacter
        "Answer aCharacter.  At index position
         anInteger in the receiver put the
         character aCharacter."
    | byteIndex |
    self checkIndex: anInteger.
    self checkCharacter: aCharacter.
    byteIndex := self byteIndexOfCharAt: anInteger.
    self
        basicAt: byteIndex put: aCharacter leadByte;
        basicAt: (byteIndex + 1) put: aCharacter trailByte.
    ^aCharacter!  
sizeOfMixedString
        "Answer the size of an equivalent
         string in a mixed-length encoding."
    <primitive: 134>
    ^self primitiveFailed!  
asMixedStringWithNull: appendNull
        " Private - answer a new String containing
        all the characters of the receiver in
        mixed-length encoding.  Optionally append
        a null-terminator byte."
    | sizeInBytes mixedString stringIndex |
    sizeInBytes := self sizeOfMixedString.
    mixedString := String new:
                (sizeInBytes + (appendNull ifTrue: [1] ifFalse: [0])).
    stringIndex := self asMixedString: mixedString.
    appendNull ifTrue: [
        stringIndex := stringIndex + 1.
        mixedString at: stringIndex put: 0 asCharacter].
     ^mixedString.! 
at: anInteger
        "Answer the character at position
         anInteger in the receiver string."
    | byteIndex |
    self checkIndex: anInteger.
    byteIndex := self byteIndexOfCharAt: anInteger.
    ^Character
        leadByte: (self basicAt: byteIndex)
        trailByte: (self basicAt: (byteIndex + 1))!  
isDoubleByteString
        "Answer true if receiver is a kind of DoubleByteString."
    ^true!  
replaceBytes: count with: aCollection
        "Private - replace count bytes of the receiver
         with bytes of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  Answer the receiver."
    <primitive: 81>
    ^self primitiveFailed!  
asCompactString
        " Answer the most compact string containing the
         characters of the receiver. "
    ^self containsDBCharacter
        ifTrue: [self]
        ifFalse: [self asMixedString]   " produces a single-byte String "!   
asMixedString
        "Answer a new String containing the characters
         of the receiver in the host system string encoding. "
    ^self asExternalString!
asMixedString: aMixedString
        "Private - Fill aMixedString with the characters
         of the receiver in mixed-string encoding. Answer
         the byte equivalents of the number of characters filled "
    <primitive: 133>
    ^self primitiveFailed!
asNormalizedString
        "Private - Does not apply to DoubleByteString."
    ^self invalidMessage!
asNormalizedString: leadByteFlags
        "Private - Does not apply to DoubleByteString."
    ^self invalidMessage! 
replaceFrom: start
    to: stop
    with: aCollection
    startingAt: repStart
        "Replace the characters of the receiver at index
         positions start through stop with consecutive
         characters of aCollection beginning at index
         position repStart.  Answer the receiver."
    | byteStart byteStop sourceBytes byteRepStart |
    " replace 16-bit characters [start..stop] in the receiver "
    byteStart := self byteIndexOfCharAt: start.
    byteStop := (self byteIndexOfCharAt: stop) + 1.
    aCollection isDoubleByteString ifTrue: [
        sourceBytes := aCollection.
        byteRepStart := self byteIndexOfCharAt: repStart]
     ifFalse: [
        (aCollection isString) ifTrue: [
            sourceBytes := self class fromString: aCollection.
            byteRepStart := sourceBytes byteIndexOfCharAt: repStart]
        ifFalse: [   " could be ByteArray or ExtrenalAddress... "
            sourceBytes := aCollection.
            byteRepStart := repStart]].
    self
        replaceBytesFrom: byteStart
        to: byteStop
        with: sourceBytes
        startingAt: byteRepStart! 
asExternalString
        "Answer a new String containing the characters
         of the receiver in host system mixed-string encoding. "
    ^self asMixedStringWithNull: false!   
close
        "Close the file identified by the receiver."
    ( KernelLibrary closeHandle: self asParameter )
        ifFalse: [ ^self osError ].
    FileHandles remove: self ifAbsent: [ nil ]!
maximumComponentLength
    "Answer the maximum length of component names."

    ^self maximumBaseNameLength + 1 + self maximumExtensionLength! 
isResidue
	"Answer true if the receiver is the distinguished object: residue, otherwise false."

	^false!  
computeHash: object
        "Answer the hash value of object."
    ^object basicHash!   
compare: key candidate: candidate
    "Answer true if <key> and <candidate> satisfy the comparison test for the receiver."

    ^key == candidate! 
pathName: aString
        "Answer a FileStream with path name aString."
    ^self pathName: aString in: Disk!   
getResourceString: resourceType id: resourceId
        "Private - answer a string containing the resource of type resourceType
        at id resourceId. Resource must be null terminated."
    | hrsrc hglb resource str id|
    id := resourceId.
    id isInteger ifTrue:[
        id := ExternalAddress new lowHalf: id].
    hrsrc := KernelLibrary
        findResource: self asParameter
        name: id asParameter
        type: ( ExternalLong new lowHalf:resourceType ) asParameter.
    hrsrc = 0 ifTrue: [
        self osWarning.
        ^nil ].
    ( hglb := KernelLibrary loadResource: self asParameter hrsrc:hrsrc asParameter ) = 0
        ifTrue: [ ^self osError ].
    ( resource := KernelLibrary lockResource: hglb ) = 0
        ifTrue: [ ^self osError ].
    resource := ExternalAddress fromString: resource.
    str := String fromAddress: resource.
    ^str!
openNew: aString in: aDirectory
        "Open the file named aString with read/write access in aDirectory,
        creating a new file (even if one already exists); answer the file handle."
    ^self
        open: aString
        in: aDirectory
        access: GenericRead | GenericWrite
        share: FileShareRead | FileShareWrite
        create: CreateAlways
        attributes: FileAttributeNormal!  
privateRemoveKey: aSymbol ifAbsent: aBlock
        "Answer aSymbol.  Remove entry with key aSymbol from the receiver.  If
        aSymbol is not a key of the receiver, evaluate aBlock (with no arguments).
        Flush the method cache.
        Don't use this message: improper usage can cause the system
         to break in non-obvious ways."
    | aDictionary intState |
    (self includesKey: aSymbol)
        ifFalse: [^aBlock value].
    aDictionary := self species new.
    self keysAndValuesDo: [ :selector :method |
        selector == aSymbol
            ifFalse: [
                aDictionary privateAt: selector put: method]].
    intState := Process enableInterrupts: false.
    contents := aDictionary contents.
    elementCount := aDictionary size.
    Process enableInterrupts: intState.
    self flushFromCache: aSymbol.
    ^aSymbol!
actionListForEvent: eventName
        "Answer an editable list of actions that get evaluated
        when the event named <eventName> is triggered."
    ^(self eventTable
        at: eventName asSymbol
        ifAbsent: [^ActionSequence new])
            asActionSequence!
directoryNamed: directoryName
	"Answer the directory named <directoryName> contained within the receiver. If the name does not define an existing directory within the receiver, return a directory object that can be used to create the external directory.
        Error Conditions:
        -   If there is a non-directory entity with the same name in the receiver, send the message #doesNotExist to the object representing the directory that does not exist."

	^[(self asFileSystemPath , directoryName) asDirectory] 
		on: FileError
		do: [FileError signal: 'Directory does not exist' with: (self absolutePath , directoryName)]! 
isDate
        "Answer whether the receiver is a Date. "
    ^false!
finalizationRegistry
	"Answer the WeakRegistry for finalizing the receiver."

	^SystemWeakRegistries finalizer!
isRemote
		"Answer whether the receiver is a remove (network) drive."
    ^self getDriveType = DriveRemote! 
file: aString 
    action: anAction 
    fileSize: aFileSize 
    attribute: anAttr 
    flags: openFlags 
    mode: aMode 
        "Answer a FileStream for the file named 
         aString in the receiver directory with DosOpen parameters 
         anAction, aFileSize, anAttr, openFlags, and aMode. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details." 
    ^FileStream on: (File open: aString in: self 
        action: anAction fileSize: aFileSize 
        attribute: anAttr flags: openFlags mode: aMode)!   
subclassOf: aClass
        "Private - Answer a new metaclass that is a subclass of the
        metaclass for <aClass>."
    | newMeta superclass |
    newMeta := self basicNew.
    superclass := aClass isNil ifTrue: [ Class ] ifFalse: [ aClass class ].
    newMeta
        structure: superclass structure;
        superclass: superclass;
        methodDictionaries:
            ( Array with: ( ( MethodDictionary newSize: 2 ) classField: newMeta ) ),
                superclass methodDictionaries.
    ^newMeta!   
flushRegistry
        "Private - flush the current global registry so that it will be recreated,
        possibly with a new format."
    GlobalRegistry := nil!   
globalRegistry: aServiceRegistry
        "Private - set the global registry."
    GlobalRegistry := aServiceRegistry!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
globalRegistry
        "Answer the instance of the receiver that is used as the root
        of the registry hierarchy."
    GlobalRegistry isNil ifTrue: [ self globalRegistry: self newGlobalRegistry ].
    ^GlobalRegistry!   
triggerEvent: eventName with: firstArgument with: secondArgument
        "Trigger the event <eventName> using the <firstArgument>
        and <secondArgument> as the arguments.  Answer the
        value returned by the most recently defined event
        handler action."
    ^self
        triggerEvent: eventName
        withArguments: (Array
            with: firstArgument
            with: secondArgument)!   
rename: oldString to: newString
        "Rename the file named oldString to newString."
    ( KernelLibrary
        moveFile: oldString asParameter
        to: newString asParameter )
            ifFalse: [ ^self osError ]!  
isUnmountable
        "Answer whether the receiver can ever be unmounted."
    ^false!  
processIndexToStackPointer: aProcessIndex
        "Private - convert aProcessIndex, an index into the receiver, into
        an absolute address into the stack."
    | launchFrame  |
    launchFrame := self class new getLaunchFrame * 2.
    ^( ( aProcessIndex - endPosition + ( startPosition - 1 ) )
        *  self class frameBiasUnit ) + launchFrame!
objectProperties: aDictionary
    "Private - Set the propertyTable for the receiver."

    ^SystemWeakRegistries current properties at: self put: aDictionary! 
origin: originPoint corner: cornerPoint
        "Change the receiver's top left corner to
         originPoint and its bottom right corner to
         cornerPoint."
    self leftTop: originPoint rightBottom: cornerPoint!  
printBoundLibrariesOn: aStream
    "Append a description of the bound libraries to aStream"

    | basDescription basVersion |
    aStream nextPutAll: self basLibName.
    ( basDescription := self descriptionOf: self basLibName ) notNil
        ifTrue: [ aStream nextPutAll: ' (', basDescription, ')' ].
    ( basVersion := self versionOf: self basLibName ) notNil
        ifTrue: [ aStream nextPutAll: ', version = ', basVersion, ')' ].
    aStream cr.

    self bound do: [ :lib |
        lib isInteger not ifTrue: [
            aStream nextPutAll: lib name.
            lib description notNil
                ifTrue: [ aStream nextPutAll: ' (', lib description, ')' ].
            aStream nextPutAll: ', version = ', lib version; cr ] ]!  
descriptionOf: aLibraryName
	"Answer a string listing the description string for
	the library in aLibraryName."

	| fileStream description path |
    ( path := File findFileName: aLibraryName ) isNil ifTrue: [ ^nil ].
	fileStream := ( File fromPath: path ) readStream.
	fileStream skip: 12.
	fileStream skip: fileStream nextULong.
	description := fileStream next: ( fileStream nextULong ).
	fileStream close.
	^description!
unboundCount
    "Answer the number of unbound libraries."

    Bound isNil ifTrue: [ ^0 ].
    ^( Bound select: [:x | x isInteger ] ) size!  
bindTo: aLibraryName
    "Bind to the library identified by
    aLibraryName. aLibraryName can
    be either a logical name or a file name.
    Answer the Library object."

    | answer duplicateName |
    answer := self currentClass new.
    answer file: aLibraryName.
    [ answer bind ]
        on: BindDuplicate
        do: [:except |
            duplicateName := except name.
            ( Smalltalk at: duplicateName asSymbol ifAbsent: [nil] ) isBehavior
                ifTrue: [ except pass ]
                ifFalse: [ except resume: duplicateName ] ].
        "For backward compatibility, we allow globals to
        override (ie. we ignore duplicates), but duplicate
        classes cause an error. If you want more control,
        do not use this method, but instead use the #bind
        instance method directly."
    ^answer objectStore!
okToSaveImage
    "Private - Check for unbound libs."

    | names answer |
    self unboundCount = 0 ifTrue: [ ^true ].
    self compact.
    self unboundCount = 0 ifTrue: [ ^true ].
    names := OrderedCollection new: self unboundCount.
    1 to: Bound size do: [:i |
        ( Bound at: i ) isInteger ifTrue: [ names add: ( self libraryName: i ) ] ].
    answer := ( Smalltalk at: #MessageBox ) threeStateNotify: 'Warning - Unbound Libraries!!'
        withText: 'These libraries are unbound but still have objects pointing into them: ',
        names asArray printString, '.
You can:
(1) Not continue saving the image (Cancel).
(2) Have Smalltalk "nil-out" all the pointers to the libraries, then proceed with saving the image (Yes).
(3) Proceed with saving the image (No). If you proceed, the saved image will still be bound to these libraries and these libraries will need to be on the PATH to restart the saved image.'.
    answer isNil ifTrue: [ ^false ].
    answer ifFalse: [ ^true ].
    self severAllTies.
    ^self okToSaveImage!
allReferencesTo: anInteger
    "Answer a collection of all objects which contain
    pointers into the library identified by anInteger.
    The argument is the same as in #liveObjectsIn:."

    <primitive: 162>
    ^self primitiveFailed!   
attemptBindTo: aLibraryName
    "Attempt to bind to aLibraryName. Answer true
    if it worked, false if it did not."

    [ self bindTo: aLibraryName ]
        on: BindError, FileError
        do: [ ^false ].
    ^true!   
printBoundLibraries
    "Print a description of the bound libraries."
    | stream |
    stream := String new asStream.
    self printBoundLibrariesOn: stream.
    ^stream contents!
severTiesTo: aLibraryOrdinal
    "Private - For a library that has been unbound, but still
    has objects pointing into it, sever all those pointers so
    the library will really be removed."

    ( Bound at: aLibraryOrdinal ) isInteger ifTrue: [
        ( self liveObjectsIn: aLibraryOrdinal ) do: [:obj |
            ( obj isArray and: [ obj notEmpty and: [ obj first isMethodDictionary ] ] )
                ifTrue: [ obj become: Object methodDictionaries ]
                ifFalse: [ obj become: nil ] ] ].!
nextSourceIndex
    "Private - Answer the next available source index."

    1 to: IndexToLib size do: [:i |
        IndexToLib at: i ifAbsent: [ ^i ] ].
    ^IndexToLib size + 1!  
libraryForSourceIndex: anIndex
    "Private - Answer the library for source index anIndex."

    ^IndexToLib at: anIndex!  
unBind: aLibraryName
        "Unbind the Library named by aLibraryName."

    | lib |
    ( lib := self named: aLibraryName ) isNil
        ifTrue: [ ^self error: aLibraryName, ' not bound.' ].
    lib unBind.!  
contentsOf: aLibraryName
	"Answer a dictionary describing the contents of aLibraryName."

	| lib |
	lib := self named: aLibraryName.
	^lib isNil
		ifTrue: [ ( self new file: aLibraryName ) contents ]
		ifFalse: [ lib contents ].!  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
	| answer |
	answer := super constructEventsTriggered.
	answer add: #compact.
	^answer!   
severAllTies
    "Private - Sever all pointers to unbound libraries."

    1 to: Bound size do: [:i | self severTiesTo: i ].!  
addBoundForSource: aLibrary
    "Private - Populate the source index tables for aLibrary."

    | anIndex |
    LibToIndex == nil ifTrue: [ LibToIndex := IdentityDictionary new ].
    IndexToLib == nil ifTrue: [ IndexToLib := Dictionary new ].
    LibToIndex at: aLibrary put: ( anIndex := self nextSourceIndex ) .
    IndexToLib at: anIndex put: aLibrary.!  
addBoundNames: aLibrary
    "Private - Keep track of names of bound libraries."

    BoundNames isNil ifTrue: [ BoundNames := Dictionary new ].
    BoundNames at: aLibrary name asLowercase put: aLibrary.
    BoundNames at: ( self nameWithExtension: aLibrary name ) asLowercase put: aLibrary.
    BoundNames at: aLibrary fileName asLowercase put: aLibrary.
    BoundNames at: ( self nameWithExtension: aLibrary fileName ) asLowercase put: aLibrary.!   
currentClass
    "Private - Answer the current binder class."

    CurrentClass isNil ifTrue: [ CurrentClass := self ].
    ^CurrentClass!
sourceIndexFor: aLibrary
    "Private - Answer the source index for aLibrary."

    ^LibToIndex at: aLibrary ifAbsent: [0]!
currentClass: aClass
    "Private - Set the current binder class."

    CurrentClass := aClass!
basLibName
	"Private - Answer the file name of the base library."

	^'vbas', SmalltalkLibrary versionAndPlatformExtension, SmalltalkLibrary fileExtension! 
devLibName
	"Private - Answer the file name of the development library."

	^'vdev', SmalltalkLibrary versionAndPlatformExtension, SmalltalkLibrary fileExtension!  
indexToLib
    "Private - answer the map between source indices and libraries."

    ^IndexToLib!  
guiLibName
	"Private - Answer the file name of the gui library."

	^'vgui', SmalltalkLibrary versionAndPlatformExtension, SmalltalkLibrary fileExtension!  
named: aLibraryName
    "Answer the bound Library named aLibraryName,
    or nil if not bound."

    Bound isNil ifTrue: [ ^nil ].
    ^BoundNames at: aLibraryName asLowercase ifAbsent: [
        BoundNames at: ( self nameWithExtension: aLibraryName ) asLowercase ifAbsent: [ nil ] ].!   
compact
	"Recover the memory from unbound libraries."

	self triggerEvent: #compact.
	Smalltalk unusedMemory.
	self compactPrim.!
isBound: aLibraryName
    "Answer true if a library named
    aLibraryName is already bound."

    ^( self named: aLibraryName ) notNil!  
nameMapAt: aLogicalName put: aFileName
	"Register a mapping from aLogicalName to aFileName,
	so that if a request is made to bind aLogicalName, then
	aFileName will be the library that is bound."

	self nameMap at: aLogicalName put: aFileName.
	self savedNameMap at: aLogicalName put: aFileName.!
unboundK
    "Private - Answer the total size in KBytes of the unbound libraries."

    Bound isNil ifTrue: [ ^0 ].
    ^Bound inject: 0 into: [:sum :each | sum + ( each isInteger ifTrue: [ each ] ifFalse: [0] ) ].!   
liveObjectsIn: anInteger
	"Private - Answer a collection of the live objects
	in the library identified by anInteger."

	<primitive: 161>
	^self primitiveFailed!
bound
    "Answer the collection of bound Libraries."

    ^Bound! 
libToIndex
    "Private - answer the map between libraries and their source indices."

    ^LibToIndex!
versionOf: aLibraryName
	"Answer a string listing the version string for
	the library in aLibraryName."

	| fileStream version path |
    ( path := File findFileName: aLibraryName ) isNil ifTrue: [ ^nil ].
	fileStream := ( File fromPath: path ) readStream.
	fileStream skip: 12.
	version := fileStream next: ( fileStream nextULong ).
	fileStream close.
	^version! 
new
		"Answer a new instance of the receiver."
	^super new initialize!  
constructEventsTriggered
        "Private - answer all the events which can be triggered
         by instances of the receiver. "
    ^super constructEventsTriggered
        add: #metaInfoAvailable ;
        add: #objectsAvailable ;
        add: #externalsResolved ;
        add: #done ;
        yourself! 
skipPostBindCleanUp: aBoolean
	"If aBoolean is true, then keep
	the intermediate data structures used
	just for binding. The default is to go
	ahead and remove these objects
	to save space."

	skipPostBindCleanUp := aBoolean.! 
initialize
    "Private - Initialize the receiver."

	super initialize.
    objectStore := SmalltalkLibrary new.
	skipPostBindCleanUp := false.! 
file: aLibraryName
	"Set the file from which to read the library."

	super file: ( self class nameMap at: aLibraryName ifAbsent: [ aLibraryName ] ).
	objectStore name: aLibraryName.
!  
removeMethods
        "Private - Remove loose methods that were added by this library."

    | methods prevMethods m prevMethod |
    methods := objectStore methods.
    prevMethods := objectStore prevMethods.
    1 to: methods size do: [:i |
        m := methods at: i.
        ( ( m classField compiledMethodAt: m selector ) = m ) ifTrue: [
            " Method from this library is still there. "
            prevMethod := prevMethods at: m ifAbsent: [ nil ].
            prevMethod notNil
                ifTrue: [ m classField methodDictionary at: m selector put: prevMethod ]
                ifFalse: [ m classField removeSelector: m selector ] ] ].! 
bind
    "Bind the receiver. Answer the bound Library."

    | lib |
    lib := self class named: objectStore name.
    lib notNil ifTrue: [
        lib incrementReferenceCount.
        ^self ].
    ( Smalltalk isRunTime and: [ objectStore name equalsIgnoreCase: self class devLibName ] )
        ifTrue: [ ^self error: 'Cannot bind development library in runtime.' ].
    self open.
    [ self
        checkVersion ;
        getMeta ;
        doPrerequisites ;
        check ;
        resolveExternals ;
        getObjects.
        Smalltalk isRunTime ifFalse: [ self setSourceBase ].
    ] ifCurtailed: [ self removeDummyGlobals; close ].
    self close.
    Smalltalk isRunTime not ifTrue: [ self setSource ].
    self doBinding.
    self evaluateInitAction.
    self triggerEvent: #done.
    SessionModel current
        triggerEvent: #objectLibraryBound: with: objectStore;  " OBSOLETE "
        triggerEvent: #libraryBound: with: objectStore.
    skipPostBindCleanUp ifFalse: [ objectStore postBindCleanUp ].
    self close. "doBinding can cause it to open again, if TeamV is present"
    ^objectStore!
abortUnbind
		"Use this message to prevent unbinding a library
		in response to the #aboutToUnbind event."

    VetoAction signal!
objectStore
	"Answer the ObjectStore for the receiver."

	^objectStore!
readSpace: bytes type: type
	"Private - Read a space from the stream."

	| space |
	type = ObjectStore bindManySpaceType
		ifTrue: [ space := ByteArray new: bytes ]
		ifFalse: [ space := self allocateMemory: bytes ].
	self stream getBytesFor: space from: 1 to: bytes.
	^space
!
readSpaceHeader
	"Private - Read a space header from the stream."

	^Array with: self stream nextULong with: self stream nextULong!
stream: aStream
	"Set the stream from which to read the objectStore."

	objectStore file: aStream! 
file: aFileName
	"Set the file from which to read the store."

	objectStore fileName: ( self class nameWithExtension: aFileName )! 
globalNameSpace
    "Answer the global name space used during
    resolving of externals."

    ^globalNames! 
globalNameSpace: aDictionary
    "Set the global name space used during
    resolving of externals."

    globalNames := aDictionary.
    ObjectStoreExternal globalNameSpace: globalNames.
!   
addObjectEventTables
    "Private - Restore object eventTables."

    | events |
    events := objectStore root at: 'ObjectEventTables' ifAbsent: [ nil ].
    events == nil ifTrue: [ ^nil ].
    events associationsDo: [:a |
        a key objectEventTable: a value ].!
addObjectProperties
    "Private - Restore object properties."

    | props |
    props := objectStore root at: 'ObjectProperties' ifAbsent: [ nil ].
    props == nil ifTrue: [ ^nil ].
    props associationsDo: [:a |
        a key objectProperties: a value ].!   
metaInfo
	"Answer a Dictionary containing the meta information
	about the objectStore."

    ( self class isBound: objectStore name ) ifFalse: [
		self open.
		[ self checkVersion; getMeta ] ensure: [ self close ] ].
	^objectStore metaInfo!   
libraryDependencies
    "Private - Answer the collection of libraries
    that the receiver depends on."

    ^objectStore uses!  
contents
	"Answer a Dictionary describing the contents of the receiver's store."

	^self metaInfo at: 'contents'!  
copyFile: oldFile as: newName
    "Private - Copy <oldFile> and anything it contains to the receiver, renaming it to <newName>."

    | newLocator newFile readOnly |
    newLocator := self asFileSystemPath , newName.

    "workaround Win32s bug: OS leaks if source doesn't exist"
    oldFile exists ifFalse: [ ^self cannotBeCreated].

    "workaround Win32s bug: doesn't recognize invalid destFile name"
    self exists ifFalse: [ ^self cannotBeCreated].

    oldFile class 
        copyFileNamed: oldFile absolutePath asString
        to: newLocator absolutePath asString.
    newFile :=  newLocator asFile.

    "under Win32s, copying a file does not preserve its timestamp"
    self osWorkaround.
    OperatingSystem isWin32s ifTrue: [
        "need write access to change date."
        ( readOnly := newFile isReadOnly ) ifTrue: [
            File changeModeOf: newFile pathName to: ( newFile attributes reject: [ :c | c = $r ] ) ].
        newFile setDate: oldFile getDate.
        readOnly ifTrue: [ File changeModeOf: newFile pathName to: ( newFile attributes, 'r' ) ] ].

    ^newFile!  
dateFormatYMD
        "Private - answer the constant used to represent Year/Month/Day
        date format."
    ^2!
open: aString
        "Answer an instance of the receiver which refers
         to the Dynamic Link Library (16-bit) named aString."
    | answer fileName |
    fileName := aString.
    ( fileName includes: $. ) ifFalse: [ fileName := fileName, '.DLL' ].
    ( answer := KernelLibrary16 loadLibrary: fileName asParameter ) < 32
        ifTrue: [ ^self osError ].
    ^self fromInteger: answer! 
pathName: aString
	"Set the receiver directory path name to aString."

	fileSystemLocator == nil
		ifTrue: [self fileSystemLocator: (FileSystemPath fromString: aString)]
		ifFalse: [self fileSystemLocator: (self fileSystemLocator volumePath , (FileSystemPath fromString: aString))]!   
isBoolean
        "Answer true if receiver is a kind of Boolean."
    ^false!   
isSystem
	"Answer true if the file is a system file."

	^self attributes includes: $s! 
new
        "Answer a new instance of the receiver class.
        Overridden to not call initialize."
    ^self basicNew!  
with: aZeroArgumentBlock
        "Answer an instance of the receiver with its
         initializing block set to aZeroArgumentBlock.
         aZeroArgumentBlock should initialize a
         variable if it has not already been initialized.
         For example:
            T := SelfInitializingObject with: [
                T := MyDLL open]."
    ^self new block: aZeroArgumentBlock!  
vmInterrupt: aSymbol
        "Private - Process virtual machine interrupt.  This method is called
        by the virtual machine.  It is entered with interrupts disabled.  The
        interrupt handler should enable interrupts at the appropriate time."
    Process perform: aSymbol.
    ^self!
selfInitializingBlock
        "Private - Answer the receiver's block."
    ^block!  
doesNotUnderstand: aMessage
        "Private - Evaluate the block and forward
         the message to its result."
    | answer |
    answer := block isNil ifTrue: [nil] ifFalse: [block value].
    ^(aMessage receiver: answer) perform.! 
isSelfInitializingObject
        "Answer true if receiver is a kind of SelfInitializingObject."
    ^true!  
block: aZeroArgumentBlock
        "Private - Set block to aZeroArgumentBlock."
    block := aZeroArgumentBlock! 
asExternalLong
        "Answer the receiver as an ExternalLong."
    ^ExternalLong fromBytes: self! 
isMetaClass
        "Answer true if receiver is a kind of MetaClass."
    ^false!   
close
        "Free the DLL."
    ( KernelLibrary freeLibrary: self )
        ifFalse: [ ^self osError ].
    self class clearCachedAddresses.
    self == self class currentOrNil ifTrue: [ self class current: nil ]!  
volumePath
	"Answer a path that resolves to the volume of the receiver"

	^self isAbsolute
		ifTrue: [
			self isNetworkPath
				ifTrue: [ self class absolute: ( self componentNames copyFrom: 1 to: 2 ) ]  "server & volume"
				ifFalse: [ self class absolute: ( Array with: self componentNames first ) ] ]
		ifFalse: [Directory default asFileSystemPath volumePath]!  
fileReadOnly: aString
        "Answer a FileStream for the file named
         aString in the receiver directory.  If the file
         does not exist, it will be created. The file opened
         will be read only."
    ^File pathNameReadOnly: aString in: self!   
removeBehavior: methodDictionary
	"Remove the instance specific behavior <methodDictionary> from the receiver.  If the method dictionary was not removed, answer nil. "
	"If the method dictionary is not instance specific, do not remove it (instance specific method dictionaries have a nil classField)"
	"ASSUMPTIONS:
		No empty method dictionary arrays exist
		Instance specific method dictionary arrays are not shared"

	methodDictionary classField == nil
		ifFalse: [^nil].
	^self removeBehavior: methodDictionary from: self methodDictionaryArray containedIn: nil

	

!   
userPriority
        "Answer the priority of the user interface process."
    ^4!   
propertyTableForEdit
	"Private - answer the property table for the receiver.
	Allocate if necessary so that updates can be stored."

	^SystemWeakRegistries current properties at: self ifAbsentPut: [ IdentityDictionary new ]!  
asFileSystemLocator
    "Answer a file system locator that will resolve to the same entity as the receiver."

	^self asFileSystemPath! 
smalltalkLibrary
    "Answer the Library which contains the receiver, or nil
    if the receiver is in the base library or the image."

    | n |
    n := self smalltalkLibraryOrdinal.
    n <= 1 ifTrue: [ ^nil ].
    ^SmalltalkLibraryBinder bound at: ( n - 1 )! 
fromString: aString
        "Answer the fraction conversion of aString.
         aString is expected to have the format 1000/100.
         A default Fraction of 0 will be returned if aString is invalid. "

    | pos fractionSeparator numerator denominator numeratorStr denominatorStr |
    fractionSeparator := $/.
    numerator := 0.
    denominator := 1.
    ( ( aString occurrencesOf: fractionSeparator ) = 1 )
        ifTrue: [
            pos := aString indexOf: fractionSeparator.
            numeratorStr := aString copyFrom: 1 to: (pos - 1).
            denominatorStr := aString copyFrom: (pos + 1) to: aString size.
            ( numeratorStr reject: [ :char | char isDigit ] ) isEmpty
                ifTrue: [ numerator := numeratorStr asInteger ].
            ( denominatorStr reject: [ :char | char isDigit ] ) isEmpty
                ifTrue: [ denominator:= denominatorStr asInteger ].
                    ].
    ^self numerator: numerator denominator: denominator!   
numerator: n denominator: d
        "Answer an instance of class Fraction and
         initialize both numerator and denominatior
         instance variables to n and d respectively."
    ^self basicNew numerator: n denominator: d!   
= aNumber
        "Answer true if the receiver is equal
         to aNumber, else answer false."

 ^aNumber isNumber and:
  [aNumber generality <= self generality
   ifTrue: [numerator = aNumber numerator and:
     [denominator = aNumber denominator]]
   ifFalse: [(aNumber coerce: self) = aNumber]]!  
+ aNumber
        "Answer sum of the receiver and aNumber."
    ^aNumber generality <= self generality
        ifTrue: [((numerator * aNumber denominator) +
                (denominator * aNumber numerator)) /
                    (denominator * aNumber denominator)]
        ifFalse: [(aNumber coerce: self) + aNumber]! 
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    numerator printOn: aStream.
    aStream nextPut: $/.
    denominator printOn: aStream!   
> aNumber
        "Answer true if the receiver is greater
         than aNumber, else answer false."

    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber denominator) >
                    (denominator * aNumber numerator)]
        ifFalse: [(aNumber coerce: self) > aNumber]!  
>= aNumber
        "Answer true if the receiver is greater than
         or equal to aNumber, else answer false."

    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber denominator) >=
                    (denominator * aNumber numerator)]
        ifFalse: [(aNumber coerce: self) >= aNumber]!   
hash
        "Answer the integer hash value for the receiver."
    ^numerator hash + denominator hash!  
numerator: n
denominator: d
    "Private - Answer the receiver.  The numerator
         and denominator of the receiver are set to the
         n and d arguments respectively."

    d = 0
        ifTrue: [^self zeroDivisor].
    d negative
        ifTrue:
            [numerator := n negated.
            denominator := d negated]
        ifFalse:
            [numerator := n.
            denominator := d]! 
denominator
        "Answer the denominator of the receiver."
    ^denominator! 
- aNumber
        "Answer the difference between
         the receiver and aNumber."
    ^aNumber generality <= self generality
        ifTrue: [((numerator * aNumber denominator) -
                (denominator * aNumber numerator)) /
                    (denominator * aNumber denominator)]
        ifFalse: [(aNumber coerce: self) - aNumber]!   
negated
        "Answer an instance of class Fraction
         which is the negative of the receiver."
    ^self class
        numerator: self numerator negated
        denominator: self denominator!  
squared
        "Answer the receiver multiplied by the receiver."
    ^self class
        numerator: numerator squared denominator: denominator squared!   
truncated
        "Answer the receiver as a kind of
         Integer truncating the fraction part."
    ^numerator quo: denominator!   
asRational
	"Answer a Rational number (Fraction or Integer) - representing the receiver."

	^self! 
reciprocal
        "Answer the reciprocal of the receiver by
         dividing the denominator by the numerator."
    | n d |
    numerator positive
        ifTrue: [ d := numerator.
            n := denominator]
        ifFalse: [
            d := numerator negated.
            n := denominator negated].
    d = 1
        ifTrue: [ ^n ]
        ifFalse: [
            ^self class
                numerator: n
                denominator: d ]
!
coerce: aNumber
	"Private - answer aNumber coerced to the same numeric class as the receiver."

	^aNumber asRational!  
asFloat
        "Answer the receiver as
         a floating point number."
    ^numerator asFloat / denominator asFloat!   
numerator
        "Answer the numerator of the receiver."
    ^numerator!   
/ aNumber
        "Answer the result of dividing
         the receiver by aNumber."
    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber denominator) /
                (denominator * aNumber numerator)]
        ifFalse: [(aNumber coerce: self) / aNumber]! 
// aNumber
        "Answer the integer quotient after dividing
         the receiver by aNumber with truncation
         towards negative infinity."
    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber denominator) //
                (denominator * aNumber numerator)]
        ifFalse: [(aNumber coerce: self) // aNumber]! 
isFraction
        "Answer true if receiver is an instance of class
         Fraction, else answer false."
    ^true!  
< aNumber
        "Answer true if the receiver is less
         than aNumber, else answer false."

    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber denominator) <
                    (denominator * aNumber numerator)]
        ifFalse: [(aNumber coerce: self) < aNumber]! 
<= aNumber
        "Answer true if the receiver is less than
         or equal to aNumber, else answer false."

    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber denominator) <=
                    (denominator * aNumber numerator)]
        ifFalse: [(aNumber coerce: self) <= aNumber]!  
generality
	"Answer the number representing the ordering of the receiver in the
    generality hierarchy.  Fractions should be coerced to FixedPoints,
    but Integers should be coerced to Fractions."

	^60!  
* aNumber
        "Answer the result of multiplying
         the receiver by aNumber."
    ^aNumber generality <= self generality
        ifTrue: [(numerator * aNumber numerator) /
                (denominator * aNumber denominator)]
        ifFalse: [(aNumber coerce: self) * aNumber]!  
queryNationalProfileInt: aKeyName default: defaultValue
        "Answer the integer value of key aKeyName in
        the [Intl] application section of the WIN.INI profile file.
        Answer defaultValue if aKeyName cannot be found."
    | answer |
    answer := KernelLibrary getProfileInt: 'Intl' asParameter
        keyName: aKeyName asParameter
        default: -1 asUnsigned.
    ^answer = -1 asUnsigned
        ifTrue: [ defaultValue ]
        ifFalse: [ answer ]! 
asSegmentedAddress
        "Answer the receiver, since it is already a 16:16 address"
    ^self!
asFlatAddress
        "Answer a 32 bit flat memory model address which refers to the
        same memory location as the receiver. If the OS is Win95, the
        created address must be at some point be sent #releaseFlatAddress."
    ^flatAddress notNil
        ifTrue: [ flatAddress ]
        ifFalse: [ ExternalAddress fromSegmentedAddress: self ]! 
flatAddress: aFlatAddress
        "Private - save the original flat address in case
        the user wants it back later."
    flatAddress := aFlatAddress!
hInstancePrev
        "Private - Answer the previous instance of the
         executing application."
    | address |
    address := VirtualMachineLibrary getObjectAddress: VmHinstprev.
    ^ExternalHandle fromBytes: ( address copyFrom: 1 to: 2 )!  
isDictionary
        "Answer whether the receiver is a Dictionary."
    ^false! 
time2359
        "Answer the current system value
        for time string describing PM."
    time2359 isNil
        ifTrue: [ time2359 := self queryNationalProfileString: 's2359' default: 'PM' ].
    ^time2359!  
pathName 
        "Answer a String representing the path name 
         of the receiver directory (drive letter not 
         included)." 

    ^self fileSystemLocator pathName!
fastCopy 
        "Answer a copy of the receiver which shares
         the receiver elements."
	| c |
	c := self objectShallowCopy.
	c postFastCopy: self.
    ^c!  
removeAllActionsWithReceiver: anObject
        "Remove all actions for all events in the receiver's event table
        that have <anObject> as their receiver."
    self eventTable keys do: [ :event |
        self removeActionsWithReceiver: anObject forEvent: event ]!  
entityNamesMatching: pattern
    "Answer a collection of the names of the entities contained within the receiver that match the given <pattern>."

	| names matchPoint uppercasePattern |
	names := OrderedCollection new.
    uppercasePattern := Pattern new: pattern input asUpperCase.
	self
		entityNamesDo:
			[:name |
			(matchPoint := uppercasePattern match: name asUpperCase index: 1) ~~ nil
				ifTrue: [(matchPoint x = 1 and: [matchPoint y = name size])
							ifTrue: [names add: name asUppercase]]].
	^names!
uLargeIntegerAtOffset: anInteger put: anIntegerValue
        "Set the 8-byte unsigned integer at offset <anInteger> in the receiver to <anIntegerValue>.
         Offsets are zero relative."
    ( anIntegerValue between: 0 and: 16rFFFFFFFFFFFFFFFF )
        ifFalse: [ ^self error: 'ULARGE_INTEGER value must be between 0  and +18446744073709551615' ].
    self
        uLongAtOffset: anInteger put: ( anIntegerValue bitAnd: 16rFFFFFFFF );
        uLongAtOffset: anInteger + 4 put: ( ( anIntegerValue bitShift: -32 ) bitAnd: 16rFFFFFFFF ).
    ^anIntegerValue!   
from: aBehavior
	"Create a mutator for instances of the argument class"

	|mutator|
	mutator :=  self new
		targetClass: aBehavior;
		setOldClass: aBehavior infoCopy;
		setBinary: (aBehavior isBytes);
		setIndexable: (aBehavior isVariable);
		setOldMethodDictionaryArray: aBehavior methodDictionaries;
		setOldVars: (aBehavior allInstVarNames).
	aBehavior recomputeMethodArray.
	^mutator
		
	!   
prototypeForMutationDoesNotUnderstand: aMessage
    "This is a prototype of the doesNotUnderstand: method that is installed as the sole (normal) method for objects that are instances of obsolete class definitions.  The purpose of this method is to trigger the mutation process for updating obsolete instance to the current definition.  The method that is actually installed is a copy of this method with the following transformations made to the method literals:
    The symbol #methodArray: is replaced with ('##methodArray:' asSymbol).
    The symbol #methodArray is replaced with ('##methodArray' asSymbol).
    The string 'method array' is replaced with the actual method array that provides
        behavior for the object during the mutation process.
    The string 'placeholder for mutator' is replaced with the actual instance of
        ObjectMutator that knows how to mutate this object.

If this method is modified, the instance method, #triggerMethod, must also be modified to make the necessary transformations."

    | state mutator mda mutated |
    mutated := false.
    state := Process enableInterrupts: false.
    [mutator := 'placeholder for mutator'.
    "if methodArray or methodArray: are not understood, then the mda must have already been replaced, and mutation must have already occurred"
    [mda := self methodArray.
    "set the receiver's method array to support mutation methods"
    self methodArray: 'method array']
        on: MessageNotUnderstood
        do: [mutated := true].
    "transform the receiver into its new representation (if not mutated already)"
    mutated ifFalse: [mutator transform: self with: mda]]
        ensure: [Process enableInterrupts: state].
    "resend the message that triggered the mutation"
    ^aMessage perform!  
prototypeForMutationMethodDictionaryArray
"This is a prototype of the methodDictionaryArray method that is installed in the method dictionary for objects that are instances of obsolete class definitions.  This method must be present so that the object's method dictionary array can be updated by the doesNotUnderstand method.

To insure that this method is not executed by a normal message send of #methodDictionaryArray (which should trigger doesNotUnderstand and the mutation process) the method is installed using an invalid method selector."

    <primitive: 96>
    self primitiveFailed!
prototypeForMutationMethodDictionaryArray: mda
"This is a prototype of the methodDictionaryArray: method that is installed in the method dictionary for objects that are instances of obsolete class definitions.  This method must be present so that the object's method dictionary array can be updated by the doesNotUnderstand method.

To insure that this method is not executed by a normal message send of #methodDictionaryArray: (which should trigger doesNotUnderstand and the mutation process) the method is installed using an invalid method selector."

    <primitive: 97>
    self primitiveFailed! 
enableMutation
	"change the behavor for existing instances to trigger mutation"

	| state oldMethods triggerDict targetClass oldDict |
	self oldClass newNameSymbol: ('Obsolete ' , self oldClass symbol) asSymbol.
	oldMethods := self oldMethodDictionaryArray.
	triggerDict := self triggerMethods.
	triggerDict classField: (targetClass := self targetClass).
	state := Process enableInterrupts: false.
	[oldMethods size to: 1 by: -1 do: [:indx |
		oldDict := oldMethods at: indx.
		oldMethods at: indx put: triggerDict.
		oldDict flushAllFromCache " flush cache after swapping dictionaries"].
	targetClass yourself. "force mutation of MetaClass"]
		ensure: [Process enableInterrupts: state]! 
oldMethodDictionaryArray
	"return the original method dictionary array that defined the original behavior of the instances"
	^oldMethodArray !  
createSuccessorFor: anObject
	"Answer the object that will replace the argument object.  Create a new object if the existing object will not suffice"

	| newClass |
	(self isMutationNecessaryFor: anObject)
		ifFalse: [^anObject].
	newClass := self targetClass.
	newClass isVariable
		ifTrue: [^newClass basicNew: anObject basicSize]
		ifFalse: [^newClass basicNew]
	! 
transform: anObject
	"Obsolete"
	"replace the argument object with a new instance that reflects the current definition of the object's class.  If possible, transfer the state of the old instance to the new instance"
	
	self transform: anObject with: anObject methodDictionaryArray! 
methodArraySelector
    "Answer the selector that is used instead of #methodArray: within the #doesNotUnderstand: method.  The leading #'s ensures that this selector is not sent by any normally created method."

    ^'##MethodArray:' asSymbol!
mutationMethodArray
    "Answer the method dictionary array that is used by obsolete object's during their
    transformation process.  Basically, they have generic object behavior and know their class"

    | mda |
    mda := Array new: 2.
    mda at: 1 put: ( MethodDictionary new classField: self oldClass ).
    mda at: 2 put: Object methodDictionary.
    ^mda! 
transferStateFrom: oldInstance
to: newInstance
	"try to preserve all instance state for the old instance by copying it to the new instance.  This includes the hash value,  all instance variables and any indexable state"

	newInstance basicHash: oldInstance basicHash.
	self targetClass isVariable
		ifTrue: 
			["discard any old indexable state if new instance is not indexable"
			self transferIndexableStateFrom: oldInstance to: newInstance].
	self targetClass instSize > 0
		ifTrue: [self transferNamedStateFrom: oldInstance to: newInstance].
	!   
methodArrayAccessSelector
    "Answer the selector that is used instead of #methodArray within the #doesNotUnderstand: method.  The leading #'s ensures that this selector is not sent by any normally created method."

    ^'##MethodArray' asSymbol!
forceMutation: oldObject
	"Force <oldObject> to be mutated by the receiver immediately.  If oldObject has been enabled for mutation, then sending methodDictionaryArray to it will cause the mutation to occur, and the subsequent test will return false"

	| mda |
	mda := oldObject methodDictionaryArray.
	(self hasOldMethodDictionaryArray: mda)
		ifTrue: 
			[oldObject methodDictionaryArray: self mutationMethodArray.
			self transform: oldObject with: mda]! 
hasOldMethodDictionaryArray: currentMethodDictionaryArray
	"Answer true if the currentMethodDictionaryArray is or contains the old method dictionary array for the receiver.  This is the case if mutation has not occurred yet"

	| mda |
	mda := self oldMethodDictionaryArray.
	currentMethodDictionaryArray == mda
		ifTrue: [^true].
	currentMethodDictionaryArray do: [:each |
		each isArray
			ifTrue: [^self hasOldMethodDictionaryArray: each]].
	^false! 
isMutationNecessaryFor: anObject
	"Answer true if <anObject> has changed shape.  <anObject> could be examined to determine if the indexable part is non empty"
	
	| newClass |
	newClass := self targetClass.	
	newClass allInstVarNames = self oldVariableNames 
		ifFalse: [^true].
	newClass isBytes = self wasBinary
		ifFalse: [^true].
	newClass isVariable = self wasIndexable
		ifFalse: [^true].
	^false! 
setOldVars: anArray
	"remember the instance variable names from the old class definition"
	oldVariableNames := anArray! 
setBinary: boolean
	"remember whether the old class definition specified byte indexable"
	wasBinary := boolean! 
setIndexable: boolean
	"remember whether the old class definition specified indexable"
	wasIndexable := boolean!
setOldMethodDictionaryArray: mda
	"remember the original method dictionary array that defined the original behavior of the instances"
	oldMethodArray := mda!   
oldClass	
"return a copy of the target class before it was redefined"
	^oldClass!   
wasBinary
	"answer true if the old class definition specified binary indexable objects"
	^wasBinary!
createSuccessorFor: anObject with: existingMethodDictionaryArray
	"Answer the object that will replace the argument object"

	| newInstance |
	newInstance := self createSuccessorFor: anObject.
	self updateMethodDictionaryArrayFor: newInstance with: existingMethodDictionaryArray.
	^newInstance!  
methodArrayAccessMethod
	"Answer the compiled method that can be inserted into the method dictionary of obsolete instances to answer their method array"

	| copy |
	copy := (self class class compiledMethodAt: #prototypeForMutationMethodDictionaryArray) copy.
	copy selector: self methodArrayAccessSelector.
	copy primitive: nil.
	^copy!   
updateMethodDictionaryArrayFor: anObject with: existingMethodDictionaryArray
	"Set the methodDictionaryArray for <anObject> to be the currently active mda for the class"

	self oldMethodDictionaryArray == existingMethodDictionaryArray
		ifTrue: [anObject methodDictionaryArray: self targetClass methodDictionaries]
		ifFalse: 
			[self updateContainedMethodDictionaryArrayFor: existingMethodDictionaryArray.
				"reinstall the existing method dictionary array, but copy it to guarantee no cache hits"
			anObject methodDictionaryArray: existingMethodDictionaryArray copy]!  
setOldClass: aBehavior
	"remember a copy of the target class before it was redefined"
	oldClass := aBehavior!   
oldVariableNames
	"answer an array of the (string) names of the instance variables for the old class
	definition.  The array index of each name corresponds to its position in the old instance"
	^oldVariableNames!   
wasIndexable
	"answer true if the old class definition specified indexable objects"
	^wasIndexable! 
updateContainedMethodDictionaryArrayFor: existingMethodDictionaryArray
	"Modify the element of existingMethodDictionaryArray that corresponds to the old method dictionary array to be the currently active mda for the class"

	| mda methodDictionaryOrArray |
	mda := self oldMethodDictionaryArray.
	1 to: existingMethodDictionaryArray size do: [:index |
		(methodDictionaryOrArray := existingMethodDictionaryArray at: index) == mda
			ifTrue: [^existingMethodDictionaryArray at: index put: self targetClass methodDictionaries]
			ifFalse: 
				[methodDictionaryOrArray isArray
					ifTrue: [^self updateContainedMethodDictionaryArrayFor: methodDictionaryOrArray]]]
			!
transform: anObject with: existingMethodDictionaryArray
	"replace the argument object with a new instance that reflects the current definition of the object's class.  If possible, transfer the state of the old instance to the new instance"
	
	|newInstance|
	newInstance := self createSuccessorFor: anObject with: existingMethodDictionaryArray.
	newInstance == anObject
		ifTrue: [^self].
	self transferStateFrom: anObject to: newInstance.
	anObject become: newInstance! 
oldMethodDictionaryArray: mda
	"return the original method dictionary array that defined the original behavior of the instances"
	^oldMethodArray ! 
transferIndexableStateFrom: oldInstance
to: newInstance
	"Transfer the state of any indexable fields from the old instance to the new instance. No state is preserved if the class has change from binary indexable to pointer indexable or visa-versa"

	self wasBinary = self targetClass isBytes
		ifTrue:
			["don't transfer between binary indexable and pointer indexable"
			1 to: newInstance basicSize do: [:i |
				 "we allocated newInstance so its size is the same as old instance"
				newInstance basicAt: i put: (oldInstance basicAt: i)]]!   
targetClass
	"return the class whose instances are transformed by this object"
	^class! 
methodArrayMethod
	"Answer the compiled method that can be inserted into the method dictionary of obsolete instances to change their method array"

	| copy |
	copy := (self class class compiledMethodAt: #prototypeForMutationMethodDictionaryArray:) copy.
	copy selector: self methodArraySelector.
	copy primitive: nil.
	^copy!  
targetClass: aBehavior
	"record the class whose instance are transformed by this object"
	class := aBehavior!   
transferNamedStateFrom: oldInstance to: newInstance
	"Copy values of named instances variables from the old instance to the new instance"
	"This implementation preserves the values of any old instances variables that still exist in the new instance, even if their relative positions have changed"

	| targetPositions targetNames newPosition |
	"build a dictionary that maps instance variable names to offsets in new instance"
	targetNames := self targetClass allInstVarNames.
	targetPositions := Dictionary new: targetNames size.
	targetNames inject: 1 into: [:position :name|
		targetPositions at: name put: position.
		position + 1].

	"Copy the value of each instance variable in the old instances for which
	an identically named instance variable exists in the new instance."
	self oldVariableNames inject: 1 into: [:position :name|
		newPosition := targetPositions at: name ifAbsent: [0].
		newPosition ~= 0 
			ifTrue: [newInstance instVarAt: newPosition put: (oldInstance instVarAt: position)].
		position + 1].
!   
triggerMethod
	"Answer the method that triggers the mutation process.  It is installed as the #doesNotUnderstand: method of obsolete instances of the target class."

	| copy |
	copy := (self class class compiledMethodAt: #prototypeForMutationDoesNotUnderstand:) copy.
	copy selector: #doesNotUnderstand:.
	copy primitive: nil.
	1 to: copy size do: [:lit|
			"save a reference to ourself in the literal frame"
		(copy at: lit) = 'placeholder for mutator' ifTrue: [copy at: lit put: self].
			"put a reference to the behavor that support mutation in to the literal frame"
		(copy at: lit) = 'method array' ifTrue: [copy at: lit put: self mutationMethodArray].
			"change the selector used to access method dictionary arrays"
		(copy at: lit) == #methodArray ifTrue: [copy at: lit put: self methodArrayAccessSelector].
			"change the selector used to install method dictionary arrays"
		(copy at: lit) == #methodArray: ifTrue: [copy at: lit put: self methodArraySelector]].
	^copy
	! 
triggerMethods
	"Answer the method dictionary that defines the COMPLETE behavior for obsolete  objects that have not been transformed into their new class definition.  The only normal method selector in the dictionary is #doesNotUnderstand:   All selectors for methods that support the does not understand method must have 'syntactically invalid' selectors so that they do not get accidently executed"

	|dict|
	dict := MethodDictionary new.
	dict at: #doesNotUnderstand: put: self triggerMethod.
	dict at: self methodArraySelector put: self methodArrayMethod.
	dict at: self methodArrayAccessSelector put: self methodArrayAccessMethod.
	^dict!  
removeKey: aSymbol ifAbsent: aBlock
        "Answer aSymbol.  Remove entry with key aSymbol from the receiver.  If
        aSymbol is not a key of the receiver, evaluate aBlock (with no arguments).
        Flush the method cache."
  	
	^DefinitionInstaller current 
		removeKey: aSymbol 
		ifAbsent: aBlock 
		fromMethodDictionary: self! 
existingFileNamed: fileName
ifAbsent: exceptionBlock
    "Answer the file named <fileName> contained within the receiver. If the name does not define an existing file within the receiver, answer the result of evaluating the <exceptionBlock>."

    | realName |
    realName := fileName.
    self
        fileNamesDo:
            [:name |
            (name equalsIgnoreCase: realName)
                ifTrue: [^self fileNamed: name]].
    ^exceptionBlock value
! 
microsecondsToRun: aBlock
        "Answer the number of microseconds to run aBlock.  Adjust the
        return value for overhead from calculation (block evaluation).
        Hardware must support a high-resolution performance counter."
    ^( self microsecondsToRunPrivate: aBlock ) -
        ( self microsecondsToRunPrivate: [ ] )!
writeStream
    "Answer a WriteStream streaming over the contents of the receiver."

	self implementedBySubclass!  
isComponentEntity
    "Answer <true> if the receiver is a file system component."

	^true! 
readStream
   "Answer a ReadStream streaming over the contents of the receiver."

	self implementedBySubclass! 
creationTime
    "Answer a TimeStamp of the date and time at which the receiver was created."

    ^self lastModificationTime! 
open: access
share: share
create: create
attributes: attributes
	"Open the file with a new file handle."

	self isOpen
		ifTrue: [self close].
	self
		fileId:
			(FileHandle
				open: self name
				in: self directory
				access: access
				share: share
				create: create
				attributes: attributes)!  
open: aString in: aDirectory access: access share: share create: create attributes: attributes
        "Open or create the specified file using the specified parameters;
        answer the file handle."
    | pathName |
    pathName := aDirectory fullDirName, aString.
    ^self
        open: pathName
        access: access
        share: share
        create: create
        attributes: attributes
!  
cleanHandles
        "Private - Clean up dead unclosed file
         handles.  Answer true if any found."
    | newHandles files answer |
    newHandles := Set new.
    answer := false.
    files := File allInstances collect: [ :eachFile |
        eachFile fileId ].
    FileHandles do: [ :each |
        ( files includes: each )
            ifTrue: [ newHandles add: each ]
            ifFalse: [
                each = NullHandle ifFalse: [ each close ].
                answer := true ] ].
    FileHandles := newHandles.
    ^answer!   
osError: aSystemErrorCode
    "Signal the HostFileSystemError exception with <aSystemErrorCode>."

    ^HostFileSystemError signalWith: aSystemErrorCode!  
startUp
        "Private - Invalidate all existing file handles; set file handle
         count to the default."
    self setLimit: 100.
    FileHandles := Set new!  
fork
        "Create and schedule a new process for the expression
        in the receiver block, at the current priority.  Answer the
        forked Process."
    ^Processor fork: self.!   
numberOfArguments
        "Answer the number of arguments expected by the
         receiver."
    ^0!  
evaluateWithArguments: argumentArray
        "Evaluate the receiver with the elements of the <argumentArray>
        as the argument values. Error Conditions: If the number of
        arguments required by the receiver is different from the size
        of the argument array, send the message #invalidArgumentCount:
        to the receiver with the number of arguments provided as the
        argument."
    self validateNumberOfArguments: argumentArray size.
    ^self value! 
evaluateFor: anObject
        "Evaluate the receiver, ignoring the argument anObject."
    ^self evaluate!  
whileFalse: aBlock
        "Repetitively evaluate the receiver block and aBlock,
         until the result of receiver block evaluation is
         true.  Answer nil."
    [ self value ] whileFalse: [ aBlock value ].
    ^nil!   
evaluateWithoutInterrupts
        "Disable interrupts, evaluate the receiver, enable interrupts, and
        answer the result of the evaluation."
    | int |
    int := Process enableInterrupts: false.
    ^self ensure: [ Process enableInterrupts: int ]!  
forkAt: aNumber
        "Create and schedule a new process for the expression
        in the receiver block, at priority aNumber.  Answer the
        forked Process."
    ^Processor fork: self at: aNumber.!
evaluate
        "Answer the result of evaluating the receiver."
    ^self value!   
value
        "Answer the result of evaluating the no argument block
         described by the receiver."
    <primitive: 39>! 
whileTrue: aBlock
        "Repetitively evaluate the receiver block and aBlock,
         until the result of receiver block evaluation is
         false.  Answer nil."
    [ self value ] whileTrue: [ aBlock value ].
    ^nil!
memoryHandleFrom: aVariableByteObject withAllocFlag: allocFlag
        "Copy aVariableByteObject into non-smalltalk memory
        with allocFlags by doing a globalAlloc. "
    | handle address |
    address := self copyToNonSmalltalkMemory: aVariableByteObject withAllocFlag: allocFlag.
    address doesNotNeedFinalization.
    handle := address memoryHandle.
    KernelLibrary globalUnlock: handle.
    ^handle! 
removeSharedPool: aSymbol
        "Obsolete - Remove the reference in the receiver to
         the shared pool dictionary named aSymbol."

	| poolName |
	poolName := aSymbol asSymbol.
	(self sharedPools includes: poolName)
		ifFalse: [self error: self name , ' does not include pool named ' , aSymbol].
	self superclass
		subclass: self symbol
   		instanceVariableNames: self instanceVariableString
    	classVariableNames: self classVariableString
		poolDictionaries: (String fromArrayOfSubstrings: (self sharedPools asArray copyWithout: poolName) separatedBy: $ )
		isVariable: self isVariable
		isPointers: self isPointers! 
drivePrefix
        "Answer a string that contains the logical drive.
         (e.g. <drive>: for real drives, or '\\SERVER\ALIAS'
         for network drive names)."

    ( self hasNetworkName )
        ifTrue:  [ ^ self drive ]
        ifFalse: [ ^ String with: self drive with: $: ].!
string: aString1 isGreaterThanOrEqualTo: aString2
        "Answer true if aString1 is after or equal to aString2
         in the current sort sequence, else answer false.
         The comparison is not case sensitive."
    ^(self compareStringi: aString1 withString: aString2) >= 0!
name
        "Answer the name of the receiver."
    ^self fileSystemLocator drive!  
privateAt: aSymbol put: anObject
        "Answer anObject.  Enter anObject at key aSymbol in the receiver.
		Don't use this message: improper usage can cause the system
		 to break in non-obvious ways."
    self privateAdd: ( self associationClass key: aSymbol value: anObject ).
    ^anObject!   
aboutToExitSession
	"Private - Exiting the session. Default is do nothing."

	^self!   
isTimeStamp
        "Answer whether the receiver is a TimeStamp. "
    ^false!  
<= aString
        "Answer true if the receiver is before or equal to
         aString in the current sort sequence, else answer false."
    ^NationalLanguage string: self isLessThanOrEqualTo: aString!  
writeBuffer: aString ofSize: n atPosition: anInteger 
        "Write the first n bytes of aString into 
         the receiver file at position anInteger." 

    self fileId 
        writeFrom: aString 
        toPosition: anInteger - 1 
        for: n!   
existingDirectoryNamed: directoryName
ifAbsent: exceptionBlock
    "Answer the directory named <directoryName> contained within the receiver. If the name does not define an existing directory within the receiver, answer the result of evaluating the <exceptionBlock>."

    | realName |
    realName := directoryName.
    self
        directoryNamesDo:
            [:name |
            (name equalsIgnoreCase: realName)
                ifTrue: [^self directoryNamed: name]].
    ^exceptionBlock value
! 
changed: aspect with: firstParameter with: secondParameter
        "Something related to the dependents of the receiver
        has changed.  Send the message #update:with:with: to
        all of the receiver's dependents with the <aspect> as the
        first argument and the <firstParameter> and <secondParameter>
        as the second and third arguments.  The aspect is intended
        to inform the dependents of the nature of the change.  The
        parameters may be needed by the dependents in order to
        respond to the change."
    self
        updateEvent: self changedEventName
        selector: #update:with:with:
        arguments: (Array with: aspect with: firstParameter with: secondParameter)!
fileName
        "Answer the receiver's file name."
    ^OperatingSystem isWin32s
        ifTrue: [ 'vvm', SmalltalkLibrary versionAndPlatformExtension, '.exe' ]
        ifFalse: [ 'vvm', SmalltalkLibrary versionAndPlatformExtension, '.dll' ].!  
enumResourceNames: hModule type: typeId enumProc: pfnEnumProc param: lParam
    <api: EnumResourceNamesA ulong ulong ulong long boolean>
    ^self invalidArgument! 
findNextFile: searchHandle findData: win32FindData
    <api: FindNextFileA ulong struct boolean>
    ^self invalidArgument! 
lockFile: handle offsetLow: int1 offsetHigh: int2 lengthLow: int3 lengthHigh: int4
    <api: LockFile ulong ulong ulong ulong ulong boolean>
    ^self invalidArgument! 
findResource: hInst nameInteger: nameInteger type: type
    <api: FindResourceA ulong ulong ulong ulongReturn>
    ^self invalidArgument!   
getPrivateProfileString: sectionName
        keyName: keyName
        default: defaultStr
        returnedString: retStr
        size: anInt
        iniFileName: iniFileName
    <api: GetPrivateProfileStringA struct struct struct struct ulong struct ulongReturn>
    ^self invalidArgument
!
getPrivateProfileInt: sectionName
        keyName: keyName
        default: defaultInt
        iniFileName: iniFileName
    <api: GetPrivateProfileIntA struct struct long struct ulongReturn>
    ^self invalidArgument
!  
getLogicalDrives
	<api: GetLogicalDrives ulongReturn>
	^self invalidArgument!   
globalAlloc: flags bytes: bytes
    <api: GlobalAlloc ulong ulong ulongReturn>
    ^self invalidArgument!   
dosDate: dosDate time: dosTime toFileTime: fileTime
    <api: DosDateTimeToFileTime ushort ushort struct boolean>
    ^self invalidArgument!
getProcAddress: hModule procName: lpProcName
     <api: GetProcAddress ulong struct ulong>
     ^self invalidArgument!  
exitProcess: exitCode
    <api: ExitProcess ulong none>
    ^self invalidArgument!  
readFile: handle
        bufferString: buffer
        bytesToRead: anInteger
        bytesRead: aWinLong
        overlapped: overlapped
    <api: ReadFile ulong struct ulong struct struct boolean>
    ^self invalidArgument! 
getModuleHandle: aString
    <api: GetModuleHandleA struct ulongReturn>
    ^self invalidArgument!  
outputDebugString: aString
    <api: OutputDebugStringA struct none>
    ^self invalidArgument! 
localFree: aHandle
    <api: LocalFree ulong ulongReturn>
    ^self invalidArgument!
fileTime: fileTime toSystemTime: systemTime
    <api: FileTimeToSystemTime struct struct boolean>
    ^self invalidArgument!
multiByteToWideCharCp: cp flags: flags lpstr: lpstr cchstr: cchstr lpwstr: lpwstr cchwstr: cchwstr
        "Convert the multi-byte string encoding in <lpstr> to a Unicode encoding in <lpwstr>."

    " int MultiByteToWideChar(
        UINT  CodePage,    // code page
        DWORD  dwFlags,    // character-type options
        LPCSTR  lpMultiByteStr,    // address of string to map
        int  cchMultiByte,    // number of characters in string
        LPWSTR  lpWideCharStr,    // address of wide-character buffer
        int  cchWideChar     // size of buffer
        );"

    <api: MultiByteToWideChar ulong ulong structIn long structOut long ulongReturn>
    ^self invalidArgument!   
getSystemDirectory: buffer length: anInteger
     <api: GetSystemDirectoryA struct ulong ulongReturn>
     ^self invalidArgument!   
readFile: handle
        bufferAddress: buffer
        bytesToRead: anInteger
        bytesRead: aWinLong
        overlapped: overlapped
    <api: ReadFile ulong ulong ulong struct struct boolean>
    ^self invalidArgument! 
beginUpdateResource: lpszModule
    <api: BeginUpdateResourceA struct ulongReturn>
    ^self invalidArgument!   
getSystemTime: systemTime
    <api: GetSystemTime struct none>
    ^self invalidArgument!   
findResource: hInst nameString: nameString type: type
    <api: FindResourceA ulong struct ulong ulongReturn>
    ^self invalidArgument!
getEnvironmentVariable: name buffer: buffer length: bufsize
    <api: GetEnvironmentVariableA struct struct ulong ulongReturn>
    ^self invalidArgument!   
getLocalTime: systemTime
    <api: GetLocalTime struct none>
    ^self invalidArgument! 
heapFree: hHeap flags: flags address: lpMem
    <api: HeapFree ulong ulong ulong boolean>
    ^self invalidArgument!
heapSize: hHeap flags: flags address: lpMem
    <api: HeapSize ulong ulong ulong ulongReturn>
    ^self invalidArgument!
setFilePointer: handle
        offset: anInteger
        offsetHigh: aWinLong
        move: flags
    <api: SetFilePointer ulong long struct ulong ulongReturn>
    ^self invalidArgument!   
setSystemTime: systemTime
    <api: SetSystemTime struct boolean>
    ^self invalidArgument!
wideCharToMultiByteCp: codePage
    flags: dwFlags
    lpwstr: lpWideCharStr
    cchwstr: cchwstr
    lpstr: lpstr
    cchlpstr: cchlpstr
    default: default
    defaultUsed: defaultUsed
        "Convert the Unicode encoding in <lpWideCharStr> to a multi-byte string encoding in <lpstr>."

    "int WideCharToMultiByte(
        UINT  CodePage,    // code page
        DWORD  dwFlags,    // performance and mapping flags
        LPCWSTR  lpWideCharStr,    // address of wide-character string
        int  cchWideChar,    // number of characters in string
        LPSTR  lpMultiByteStr,    // address of buffer for new string
        int  cchMultiByte,    // size of buffer
        LPCSTR  lpDefaultChar,    // address of default for unmappable characters
        LPBOOL  lpUsedDefaultChar     // address of flag set when default char. used
        );"

    <api: WideCharToMultiByte ulong ulong structIn long structOut long structIn structOut ulongReturn>
    ^self invalidArgument!  
setLocalTime: systemTime
    <api: SetLocalTime struct boolean>
    ^self invalidArgument!  
deleteFile: path
    <api: DeleteFileA struct boolean>
    ^self invalidArgument!   
findResource: hInst name: name type: type
    name isString
        ifTrue: [ ^self findResource: hInst nameString: name type: type ]
        ifFalse: [ ^self findResource: hInst nameInteger: name type: type ]! 
freeLibrary: hLib
    <api: FreeLibrary ulong boolean>
    ^self invalidArgument!   
getCurrentDirectory: count buffer: buffer
    <api: GetCurrentDirectoryA ulong struct ulongReturn>
    ^self invalidArgument!   
getDiskFreeSpace: rootPath
    sectorsPerCluster: winLong1
    bytesPerSector: winLong2
    freeClusters: winLong3
    totalClusters: winLong4
        "Private - work around an OS bug in the real API, when called using UNC path names, by
        creating a temporary drive mapping."
    | path mappedPath driveMap mapIndex result realRootPath |

    path := ( rootPath size >= 2 and: [ ( rootPath copyFrom: 1 to: 2 ) = '\\' ] )
        ifTrue: [
            self osWorkaround.
            "workaround for bug in GetFreeDiskSpace API: API fails when given a UNC name
            (error 50 = 'the network request is not supported'); so temporarily map it to a drive
            letter, use that, and then destroy the mapped connection."

            "get next available drive letter"
            driveMap := self getLogicalDrives.
            mapIndex := 3.  "skip b:"
            [ ( driveMap bitAt: mapIndex ) = 1 ] whileTrue: [ mapIndex := mapIndex + 1 ].
            mappedPath := String with: ( mapIndex + 64 ) asCharacter with: $: .

            "make temporary drive mapping to that volume"
            "note: Windows 95 requires a trailing '\' character, Windows and Windows NT do not"
            realRootPath := OperatingSystem isWindows95
                ifTrue: [ rootPath, '\' ]
                ifFalse: [ rootPath ].
            ( WNetDLL current
                wNetAddConnection: realRootPath
                password: nil
                localName: mappedPath ) = 0 ifFalse: [ ^false ].
            mappedPath ]
        ifFalse: [ rootPath ].

    result := KernelLibrary getDiskFreeSpaceReal: path
        sectorsPerCluster: winLong1
        bytesPerSector: winLong2
        freeClusters: winLong3
        totalClusters: winLong4.

    mappedPath notNil ifTrue: [
        "release the temporary drive mapping"
        ( WNetDLL current wNetCancelConnection: mappedPath fForce: true ) = 0 ifFalse: [ ^false ] ].

    ^result!  
getFreeSpace: wFlags
        "Return the same nonsense value as Win32 macro does."
    ^16r100000!  
getFileSize: fileHandle fileSizeHigh: anExternalLong
    <api: GetFileSize ulong struct ulongReturn>
    ^self invalidArgument! 
getProfileString: appName keyName: keyName default: defaultStr returnedString: retStr size: anInt
    <api: GetProfileStringA struct struct struct struct ulong ulongReturn>
    ^self invalidArgument! 
getTempFileName: path prefix: prefix unique: anInteger fileName: buffer
    <api: GetTempFileNameA struct struct ulong struct ulongReturn>
    ^self invalidArgument!   
getWindowsDirectory: buffer length: anInteger
     <api: GetWindowsDirectoryA struct ulong ulongReturn>
     ^self invalidArgument! 
heapAlloc: hHeap flags: flags size: cbAlloc
    <api: HeapAlloc ulong ulong ulong ulongReturn>
    ^self invalidArgument!   
isDBCSLeadByte: aChar
    <api: IsDBCSLeadByte ushort boolean>
    ^self invalidArgument!   
localFileTime: aLocalFileTime toFileTime: aFileTime
    <api: LocalFileTimeToFileTime struct struct boolean>
    ^self invalidArgument! 
readFile: handle
        buffer: buffer
        bytesToRead: anInteger
        bytesRead: aWinLong
        overlapped: overlapped
    ^buffer isExternalAddress
        ifTrue: [
            self readFile: handle
                bufferAddress: buffer asParameter
                bytesToRead: anInteger
                bytesRead: aWinLong
                overlapped: overlapped ]
        ifFalse: [
            self readFile: handle
                bufferString: buffer
                bytesToRead: anInteger
                bytesRead: aWinLong
                overlapped: overlapped ].!
getCurrentThreadId
    <api: GetCurrentThreadId ulongReturn>
    ^self invalidArgument! 
lStrCmp: aString1 withString: aString2
        "Private - the comparison is case-sensitive."
    <api: lstrcmpA struct struct long>
    ^self invalidArgument! 
findFirstFile: fileSpec findData: win32FindData
    <api: FindFirstFileA struct struct ulongReturn>
    ^self invalidArgument!  
heapCreate: fdwHeap initialSize: cbInitial maximumSize: cbMaximum
    <api: HeapCreate ulong ulong ulong ulongReturn>
    ^self invalidArgument!
lStrCmpi: aString1 withString: aString2
        "Private - the comparison is case-insensitive."
    <api: lstrcmpiA struct struct long>
    ^self invalidArgument! 
copyFile: lpszExistingFile to: lpszNewFile ifExists: fFailIfExists
    <api: CopyFileA struct struct boolean boolean>
    ^self invalidArgument!
getVolumeInformation: rootPath
    name: volumeNameBuffer
    nameSize: volumeNameSize
    serialNumber: serialNumber
    maximumComponentLength: maximumComponentLength
    fileSystemFlags: fileSystemFlags
    fileSystemName: fileSystemName
    fileSystemNameSize: fileSystemNameSize
    <api: GetVolumeInformationA struct struct ulong struct struct struct struct ulong boolean>
    ^self invalidArgument!
fileTime: pFileTime toLocalFileTime: pLocalFileTime
    <api: FileTimeToLocalFileTime struct struct boolean>
    ^self invalidArgument! 
setHandleCount: anInteger
    <api: SetHandleCount ulong ulongReturn>
    ^self invalidArgument!
setErrorMode: errorModeConstant
    <api: SetErrorMode ulong ulongReturn>
    ^self invalidArgument!
winExec: cmdLine cmdShow: int
    <api: WinExec struct ulong ulongReturn>
    ^self invalidArgument!
fileTime: aFileTime toDosDate: dosDate dosTime: dosTime
    <api: FileTimeToDosDateTime struct struct struct boolean>
    ^self invalidArgument!
closeHandle: handle
    <api: CloseHandle ulong boolean>
    ^self invalidArgument! 
getTickCount
    <api: GetTickCount ulongReturn>
    ^self invalidArgument! 
loadResource: hInst hrsrc:hrsrc
    <api: LoadResource ulong ulong ulongReturn>
    ^self invalidArgument!  
lwrite: aFileHandle string: aString size: anInteger
    <api: '_lwrite' long struct ulong ulongReturn>
    ^self invalidArgument!   
lockResource: hglb
    <api: LockResource ulong ulong>
    ^self invalidArgument!   
getDriveType: rootString
        "Note: this API changed significantly from Windows 3.1; the parameter
         specifies the root directory of the disk in question, as opposed to
         an Integer specifying the disk number"
     <api: GetDriveTypeA struct ulongReturn>
     ^self invalidArgument! 
setFileAttributes: name attributes: anInteger
    <api: SetFileAttributesA struct ulong boolean>
    ^self invalidArgument! 
setLastError: anInteger
    <api: SetLastError ulong none>
    ^self invalidArgument!   
sizeofResource: hModule hrsrc: hResource
    <api: SizeofResource ulong ulong ulongReturn>
    ^self invalidArgument!   
getDiskFreeSpaceReal: rootPath
        sectorsPerCluster: winLong1
        bytesPerSector: winLong2
        freeClusters: winLong3
        totalClusters: winLong4
    <api: GetDiskFreeSpaceA struct struct struct struct struct boolean>
    ^self invalidArgument!   
getVersion
    <api: GetVersion ulongReturn>
    ^self invalidArgument! 
getCommandLine
    <api: GetCommandLineA ulongReturn>
    ^self invalidArgument!
moveFile: oldName to: newName
    <api: MoveFileA struct struct boolean>
    ^self invalidArgument! 
createProcess: imageName
    commandLine: commandLine
    processSecurity: processSecurity
    threadSecurity: threadSecurity
    inheritHandles: aBoolean
    createFlags: createFlags
    environment: environmentString
    currentDir: directoryString
    startInfo: startupInfo
    processInfo: processInfo

    <api: CreateProcessA struct struct struct struct boolean ulong struct struct struct struct boolean >
    ^self invalidArgument!   
getLastError
    <api: GetLastError ulongReturn>
    ^self invalidArgument! 
globalHandle: aSegSelector
    <api: GlobalHandle ulong ulongReturn>
    ^self invalidArgument! 
updateResource: hUpdate
        type: lpszType
        name: lpszName
        language: idLanguage
        data: lpData
        cbData: cbData
    <api: UpdateResourceA ulong ulong ulong ushort ulong ulong boolean>
    ^self invalidArgument!  
globalAddAtom: lpString
    <api: GlobalAddAtomA struct ushort>
    ^self invalidArgument!  
globalGetAtomName: nAtom buffer: lpBuffer size: nSize
    <api: GlobalGetAtomNameA ushort struct ulong ulongReturn>
    ^self invalidArgument!  
queryPerformanceCounter: pInteger
    <api: QueryPerformanceCounter struct boolean>
    ^self invalidArgument!  
formatMessage: flags
        source: source
        message: messageId
        language: languageId
        buffer: buffer
        size: size
        arguments: arguments
    <api: FormatMessageA ulong ulong ulong ulong struct ulong ulong ulongReturn>
    ^self invalidArgument!
getProfileInt: appName keyName: keyName default: anInt
    <api: GetProfileIntA struct struct ulong ulongReturn>
    ^self invalidArgument! 
openFile: aString reopenBuffer: aByteArray style: anInteger
    <api: OpenFile struct struct ulong long>
    ^self invalidArgument! 
unmapViewOfFile: externalLong
    <api: UnmapViewOfFile ulong boolean>
    ^self invalidArgument!   
globalUnlock: aHandle
    <api: GlobalUnlock ulong ulongReturn>! 
writeFile: handle
        buffer: buffer
        bytesToWrite: anInteger
        bytesWritten: aWinLong
        overlapped: overlapped
    ^buffer isExternalAddress
        ifTrue: [
            self writeFile: handle
                bufferAddress: buffer asParameter
                bytesToWrite: anInteger
                bytesWritten: aWinLong
                overlapped: overlapped ]
        ifFalse: [
            self writeFile: handle
                bufferString: buffer
                bytesToWrite: anInteger
                bytesWritten: aWinLong
                overlapped: overlapped ].! 
endUpdateResource: hUpdate discard: aBoolean
    <api: EndUpdateResourceA ulong boolean boolean>
    ^self invalidArgument! 
getFileAttributes: name
    <api: GetFileAttributesA struct ulongReturn>
    ^self invalidArgument! 
searchPath: lpszPath
        file: lpszFile
        extension: lpszExtension
        bufSize: cchReturnBuffer
        buffer: lpszReturnBuffer
        filePart: plpszFilePart
    <api: SearchPathA struct struct struct ulong struct struct ulongReturn>
    ^self invalidArgument!  
writeFile: handle
        bufferString: buffer
        bytesToWrite: anInteger
        bytesWritten: aWinLong
        overlapped: overlapped
    <api: WriteFile ulong struct ulong struct struct boolean>
    ^self invalidArgument!   
openFileMapping: dwDesiredAccess bInheritHandle: bInheritHandle lpName: lpName
    <api: OpenFileMappingA ulong boolean struct ulongReturn>
    ^self invalidArgument!  
createFile: name
        access: readWriteMode
        shareMode: shareMode
        securityAttributes: securityAttributes
        create: createFlags
        attributes: attributes
        templateFile: templateFile
    <api: CreateFileA struct ulong ulong struct ulong ulong ulong ulongReturn>
    ^self invalidArgument!
queryPerformanceFrequency: pInteger
    <api: QueryPerformanceFrequency struct boolean>
    ^self invalidArgument!  
heapDestroy: hHeap
    <api: HeapDestroy ulong boolean>
    ^self invalidArgument!  
globalReAlloc: handle bytes: bytes flag: flag
    <api: GlobalReAlloc ulong ulong ulong ulongReturn>
    ^self invalidArgument! 
createDirectory: path securityAttributes: securityAttributes
    <api: CreateDirectoryA struct struct boolean>
    ^self invalidArgument!   
flushFileBuffers: aFileHandle
    <api: FlushFileBuffers ulong boolean>
    ^self invalidArgument!  
getFileTime: handle creation: fileTime1 lastAccess: fileTime2 lastWrite: fileTime3
    <api: GetFileTime ulong struct struct struct boolean>
    ^self invalidArgument! 
loadLibrary: aLibFileName
    <api: LoadLibraryA struct ulongReturn>
    ^self invalidArgument! 
removeDirectory: path
    <api: RemoveDirectoryA struct boolean>
    ^self invalidArgument! 
setFileTime: handle creation: fileTime1 lastAccess: fileTime2 lastWrite: fileTime3
    <api: SetFileTime ulong struct struct struct boolean>
    ^self invalidArgument! 
systemTime: systemTime toFileTime: fileTime
    <api: SystemTimeToFileTime struct struct boolean>
    ^self invalidArgument!
createFileMapping: hFile lpsa: securityAttributes fdwProtect: anInteger1 dwMaximumSizeHigh: anInteger2 dwMaximumSizeLow: anInteger3 lpszMapName: aString
    <api: CreateFileMappingA handle struct ulong ulong ulong struct ulongReturn>
    ^self invalidArgument!
globalDeleteAtom: nAtom
    <api: GlobalDeleteAtom ulong ulongReturn>
    ^self invalidArgument!
globalFree: aHandle
    <api: GlobalFree ulong ulongReturn>
    ^self invalidArgument!  
globalLock: aHandle
    <api: GlobalLock ulong ulongReturn>
    ^self invalidArgument!  
globalSize: aHandle
    <api: GlobalSize ulong ulongReturn>
    ^self invalidArgument!  
findClose: searchHandle
    <api: FindClose ulong boolean>
    ^self invalidArgument!   
globalMemoryStatus: memoryStatus
    <api: GlobalMemoryStatus struct none>
    ^self invalidArgument!   
enumResourceTypes: hModule enumProc: pfnEnumProc param: lParam
    <api: EnumResourceTypesA ulong ulong long boolean>
    ^self invalidArgument!
setCurrentDirectory: path
    <api: SetCurrentDirectoryA struct boolean>
    ^self invalidArgument! 
writeFile: handle
        bufferAddress: buffer
        bytesToWrite: anInteger
        bytesWritten: aWinLong
        overlapped: overlapped
    <api: WriteFile ulong ulong ulong struct struct boolean>
    ^self invalidArgument!   
unlockFile: handle offsetLow: int1 offsetHigh: int2 lengthLow: int3 lengthHigh: int4
    <api: UnlockFile ulong ulong ulong ulong ulong boolean>
    ^self invalidArgument! 
beep: frequency for: duration
    <api: Beep ulong ulong boolean>
    ^self invalidArgument!
getModuleFileName: hModule name: aString size: anInteger
    <api: GetModuleFileNameA ulong struct ulong ulongReturn>
    ^self invalidArgument!
asExternalAddress
        "Answer the receiver as an ExternalAddress."
    ^ExternalAddress fromBytes: self!
smallIconSize
        "Answer the default size (a Point) of a small icon."
    ( OperatingSystem isWin32 and: [ OperatingSystem versionMajor = 4 ] ) ifFalse: [ ^16@16 ].
    ^( self getSystemValue: SmCxsmicon ) @ ( self getSystemValue: SmCysmicon )!  
isDirectory
    "Answer <true> if the receiver is a directory."

    ^true!
copyDirectory: oldDirectory as: newName
    "Private - Copy <oldDirectory> and anything it contains to the receiver, renaming it to <newName>."

    | newDirectory |
    newDirectory := self newDirectoryNamed: newName.
    newDirectory == nil
        ifTrue: [^oldDirectory cannotBeCreated].
    oldDirectory
        entitiesDo:
            [:entity |
            entity copyTo: newDirectory.
            entity release].
	^newDirectory! 
newDirectoryNamed: directoryName
ifExists: exceptionBlock
    "Answer a file system entity representing a newly created directory named <directoryName> contained within the receiver. If an entity with the given name already exists, or if the directory cannot be created for other reasons, answer the result of evaluating the <exceptionBlock>."

    ^[self newDirectoryNamed: directoryName]
        on: FileError
        do: exceptionBlock! 
existingDirectoryNamed: directoryName
    "Answer the existing directory named <directoryName> contained within the receiver. Answer <nil> if the name does not define an existing directory within the receiver."

    ^self
        existingDirectoryNamed: directoryName
        ifAbsent: [nil]! 
moveDirectory: oldDirectory as: newName
    "Private - Move <oldDirectory> and anything it contains to the receiver, renaming it to <newName>."

   	self moveEntity: oldDirectory as: newName!
hasFileNamed: fileName
    "Answer <true> if the receiver contains a file named <fileName>."

    | searchResult |
    [ searchResult := self findFirst: fileName.
        searchResult notNil
            ifTrue: [ ^searchResult entity isFile ]
            ifFalse: [ ^false ] ]
        ensure: [ searchResult isNil ifFalse: [ self endSearch: searchResult ] ]!
newFileNamed: fileName
    "Answer a file system entity representing a newly created file named <fileName> contained within the receiver.
        Error Conditions:
        -   If an entity with the given name already exists, or if the file cannot be created for other reasons, send the message #cannotBeCreated to an object representing the file whose creation was requested."

    | file |
    file := (self asFileSystemPath , fileName) asFile.
    file exists
        ifTrue: [^file cannotBeCreated].
    file create.
    ^file!  
newFileNamed: fileName
ifExists: exceptionBlock
    "Answer a file system entity representing a newly created file named <fileName> contained within the receiver. If an entity with the given name already exists, or if the file cannot be created for other reasons, answer the result of evaluating the <exceptionBlock>."

   ^[self newFileNamed: fileName]
        on: FileError
        do: exceptionBlock! 
size
    "Answer the number of entities contained in the receiver."

	^self entities size! 
existingFileNamed: fileName
    "Answer the existing file named <fileName> contained within the receiver. Answer <nil> if the name does not define an existing file within the receiver."

    ^self
        existingFileNamed: fileName
        ifAbsent: [nil]!
moveFile: oldFile as: newName
    "Private - Move <oldFile> and anything it contains to the receiver, renaming it to <newName>."

   	self moveEntity: oldFile as: newName!
files
    "Answer a collection of the files contained in the receiver."

    | files |
    files := OrderedCollection new.
    self
        filesDo:
            [:file |
            files add: file].
    ^files!  
fileNames
    "Answer a collection of the names of the files contained within the receiver."

    | names |
    names := OrderedCollection new.
    self
        fileNamesDo:
            [:name |
            names add: name].
    ^names! 
directoryNotEmpty
    "An attempt was made to remove a directory that is not empty. Signal a FileError."

    FileError
        signal: 'Directory not empty'
        with: self!
copyTo: targetContainer
as: newName
    "Copy the receiver and anything it contains to the <targetContainer>, renaming it to the <newName>."

    ^targetContainer copyDirectory: self as: newName!   
directories
    "Answer a collection of the directories contained in the receiver."

    | directories |
    directories := OrderedCollection new.
    self
        directoriesDo:
            [:directory |
            directories add: directory].
    ^directories!  
moveEntity: oldEntity as: newName
    "Private - Move <oldEntity> and anything it contains to the receiver, renaming it to <newName>."

    | copy |
    (oldEntity privateMoveTo: self as: newName)
        ifFalse:
            [copy := oldEntity copyTo: self as: newName.
            oldEntity remove.
			oldEntity fileSystemLocator: copy fileSystemLocator]! 
moveTo: targetContainer
as: newName
    "Move the receiver and anything it contains to the <targetContainer>, renaming it to the <newName>."

    targetContainer moveDirectory: self as: newName!
directoryNames
    "Answer a collection of the names of the directories contained within the receiver."

    | names |
    names := OrderedCollection new.
    self
        directoryNamesDo:
            [:name |
            names add: name].
    ^names! 
hasDirectoryNamed: directoryName
    "Answer <true> if the receiver contains a directory named <directoryName>."

    | searchResult |
    [ searchResult := self findFirst: directoryName.
        searchResult notNil
            ifTrue: [ ^searchResult entity isDirectory ]
            ifFalse: [ ^false ] ]
        ensure: [ searchResult isNil ifFalse: [ self endSearch: searchResult ] ]!  
newDirectoryNamed: directoryName
    "Answer a file system entity representing a newly created directory named <directoryName> contained within the receiver.
        Error Conditions:
        -   If an entity with the given name already exists, or if the directory cannot be created for other reasons, send the message #cannotBeCreated to an object representing the directory whose creation was requested."

    | dir |
    dir := (self asFileSystemPath , directoryName) asDirectory.
    dir exists
        ifTrue: [^dir cannotBeCreated].
    dir create.
    ^dir!
= path
    "Answer <true> if the receiver and the given <path> are equal. Two paths are equal if they specify the same list of components in the same order.
        Invariants:
        -    Two objects that compare equal must have equal hash values."

    | realPath |
    [realPath := path asFileSystemPath]
        on: MessageNotUnderstood
        do: [^false].
    ^self isAbsolute == realPath isAbsolute
        and: [self asString equalsIgnoreCase: realPath asString]!   
asDirectory
    "Answer the directory referenced by the receiver."

    ^Directory fromLocator: self!  
asFileSystemPath
    "Answer a path that will resolve to the same entity as the receiver."

    ^self! 
entityName
    "Answer the name of the entity represented by the receiver."

    | idx |
    idx := self entityNameIndex.
    idx = 0
        ifTrue: [
            self isVolumeRelative
                ifTrue: [ ^self class directorySeparator ].
            " . or .. "
            ^self componentNames last ]
        ifFalse: [
            ( idx = 1 and: [ self isAbsolute ] )
                ifTrue: [ ^self class directorySeparator ].
            ^self componentNames at: idx ]!   
printOn: aStream
    "Print a textual description of the receiver on <aStream>."

    aStream nextPutAll: self asString!   
absoluteWithin: path
	"Answer the result of concatenating the reciever with the argument <path> resulting in an absolute path. If the argument is a relative path, the result will be relative to the receiver concatentated with the argument relative to the current directory. If the reciever is absolute, answer the receiver."

	| realPath newPath |
	self isAbsolute
		ifTrue: [^self].
	realPath := path asFileSystemPath.
	self isVolumeRelative
		ifTrue:
			[realPath isAbsolute
				ifTrue: [newPath := realPath volumePath , self]
				ifFalse: [newPath := Directory default asFileSystemPath volumePath , realPath , self]]
		ifFalse:
			[realPath isAbsolute
				ifTrue: [newPath := realPath , self]
				ifFalse: [newPath := Directory default asFileSystemPath , realPath , self]].
	^newPath!   
commonPrefixWith: path
	"Answer a path representing the longest common prefix between the receiver and the given <path>. Ignore the volume for comparison purposes. Answer <nil> if there is no common path for the recievers."

	| realPath newComponents newPath |
	realPath := path asFileSystemPath.
	self absolute == realPath absolute
		ifFalse: [^nil].
	newComponents := self componentNames copyFrom: 1 to: (self sizeOfCommonPrefixWith: realPath).
	self isAbsolute
		ifTrue:
			[newComponents isEmpty
				ifTrue: [^nil].
			newPath := self class absolute: newComponents]
		ifFalse:
			[self isVolumeRelative
				ifTrue:
					[newPath := self class volumeRelative: newComponents]
				ifFalse:
					[newComponents isEmpty
						ifTrue: [^nil].
					newPath := self class relative: newComponents]].
	^newPath!
hash
    "Answer an integer hash value for the receiver.
        Invariants:
        -    The hash value of an object must be constant over time.
        -    Two objects that compare equal must have equal hash values."

    ^self componentNames hash! 
, path
	"Answer the result of concatenating the relative <path> with the receiver. If the argument is a relative path, the result will be relative if the receiver is relative and absolute if the receiver is absolute. If the argument is an absolute path, return the argument."

	| realPath newComponents newPath |
	realPath := path asFileSystemPath.
	realPath isAbsolute
		ifTrue: [^realPath].
	newComponents := self componentNames , realPath componentNames.
	self isAbsolute
		ifTrue:
			[newPath := self class absolute: newComponents]
		ifFalse:
			[self isVolumeRelative
				ifTrue: [newPath := self class volumeRelative: newComponents]
				ifFalse: [newPath := self class relative: newComponents]].
	^newPath!   
copy
	"Answer an object that is similar to the receiver, but for which changes in the state of either the receiver or the resulting copy do not affect the other. The definition of similar is intentionally unspecified. The copy may be identical to the receiver only if the receiver is either unique or immutable."

	^super copy componentNames: self componentNames copy!   
isEmpty
    "Answer <true> if the receiver is empty (has no components)."

    ^self componentNames isEmpty!   
absolute: aSymbol
    "Private"
    "Mark the receiver as being an absolute path if aSymbol is <#absolute>, relative to a volume (leading directory separator)  if aSymbol is <#volumeRelative>, or relative to a directory if aSymbol is <#directoryRelative>."

    absolute := aSymbol
!  
relativeTo: path
    "Answer a relative path which, when concatenated to the given <path>,
    would result in a path equal to the receiver.
    Answer <nil> if a relative path cannot be constructed."

    | realPath start newComponents |
    realPath := path asFileSystemPath.
    (self isAbsolute and: [realPath isAbsolute])
        ifFalse: [^nil].
    "This assumes that firstComponents size >= secondComponents size.
    If this condition does not hold, we need to add an appropriate
    number of (parent directory) references to the component list."
    start := self sizeOfCommonPrefixWith: realPath.
    start < realPath componentNames size
        ifTrue:
            [ "realPath must completely match in order for there to be
              a relative component"
            ^nil].
    newComponents := self componentNames
        copyFrom: start + 1
        to: self componentNames size.
    ^self class relative: newComponents!  
asFile
    "Answer the file referenced by the receiver."

	^File fromLocator: self!
componentNames: componentNameArray
    "Private"
    "Set the internal collection of component names to be those in the <componentNameArray>."

    componentNames := componentNameArray! 
componentNames
    "Private"
    "Answer the internal collection of component names."

    ^componentNames!   
sizeOfCommonPrefixWith: path
    "Private"
    "Answer the number of components that the receiver and the given <path> share as a common prefix. This number is probably only interesting if the receiver and argument are either both absolute or both relative."

    | firstComponents secondComponents maxComponentSize componentIndex |
    firstComponents := self componentNames.
    secondComponents := path componentNames.
    maxComponentSize := firstComponents size min: secondComponents size.
    componentIndex := 1.
    [componentIndex <= maxComponentSize
            and: [(firstComponents at: componentIndex) equalsIgnoreCase: (secondComponents at: componentIndex)]]
        whileTrue:
            [componentIndex := componentIndex + 1].
    ^componentIndex - 1! 
isVolumeRelative
    "Private - Answer true if the receiver is relative AND has a leading directory separator.  On unix, windows and OS2, this means that the path is absolute on the current volume.  On the Mac it means that the path is relative to Disk."

    ^self absolute == #volumeRelative
!   
absolute
    "Private"
    "Answer <#absolute> if the receiver is an absolute path, <#volumeRelative> if the receiver is relative to the volume (leading directory separator), or <#directoryRelative> if the receiver is relative to a directory."

    ^absolute
! 
components
    "Answer a collection containing the components of the receiver."

	^self componentNames copy!   
asFileWithin: baseDirectory
    "Answer the file referenced by the receiver, relative to the <baseDirectory>. If the receiver is absolute, the argument is ignored."

	^File fromLocator: (self absoluteWithin: baseDirectory)!
resolveWithin: baseDirectory
    "Answer the entity referenced by the receiver, relative to the <baseDirectory>. If the receiver is absolute, the argument is ignored.
        Error Conditions:
        -   If the receiver cannot be resolved, send the message #cannotBeResolved to the receiver. Resolution will fail if the entity referenced by the receiver does not exist or is not accessible."

	| entity |
	self isAbsolute
		ifTrue: [^self resolve].
	entity := (Directory fromLocator:(baseDirectory asFileSystemPath , self parentPath)) existingEntityNamed: self entityName ifAbsent: [^self cannotBeResolved].
	^entity
! 
parentPath
	"Answer a path that resolves to the parent directory of the receiver"

	| newComponents newPath |
	self isAbsolute
		ifTrue:
			[self componentNames size <= 1
				ifTrue: [^self]
				ifFalse: [newComponents := self componentNames copyFrom: 1 to: (self componentNames size - 1)].
			newPath := self class absolute: newComponents]
		ifFalse:
			[(self isEmpty and: [self isVolumeRelative])
				ifTrue: [^self].
			self componentNames size = 1
				ifTrue: [^(self absoluteWithin: Disk) parentPath]
				ifFalse: [newComponents := self componentNames copyFrom: 1 to: (self componentNames size - 1)].
			newPath := self class relative: newComponents].
	^newPath! 
entityName: aString
    "Set the name of the entity represented by the receiver to <aString>."

    | idx |
    idx := self entityNameIndex.
    idx = 0
        ifFalse: [self componentNames at: idx put: aString]!   
absolutePath
        "Answer the receiver as an absolute path."
	self isAbsolute
		ifTrue: [^self].
	^self isVolumeRelative
		ifTrue: [Directory default asFileSystemPath volumePath , self]
		ifFalse: [Directory default asFileSystemPath , self]!
isAbsolute
    "Answer <true> if the receiver is an absolute path."

	^self absolute == #absolute! 
isRelative
    "Answer <true> if the receiver is a relative path."

    ^self isAbsolute not!  
asDirectoryWithin: baseDirectory
	"Answer the directory referenced by the receiver, relative to the <baseDirectory>. If the receiver is absolute, the argument is ignored."

	^Directory fromLocator: (self absoluteWithin: baseDirectory)!
resolve
    "Answer the entity referenced by the receiver.
        Error Conditions:
        -   If the receiver cannot be resolved, send the message #cannotBeResolved to the receiver. Resolution will fail if the entity referenced by the receiver does not exist or is not accessible."

	| entity |
	self isRelative
		ifTrue: [^(self absoluteWithin: Directory default) resolve].
	entity := (Directory fromLocator: self parentPath) existingEntityNamed: self entityName ifAbsent: [^self cannotBeResolved].
	^entity! 
findKeyIndex: key
for: client
		"Private-  Answer the index position of an <key> in the receiver or the first empty key 
		position. The <client> is responsible for computing hash values."
	| index indexedObject lastIndex |
	lastIndex := self size.
	index := ( ( key basicHash ) \\ ( lastIndex // 2 ) ) * 2 + 1.
	[ ( indexedObject := self at: index ) == nil or: [ indexedObject == key ] ]
		whileFalse:
			[ ( index := index + 2 ) > lastIndex
				ifTrue: [ index := 1 ] 
			].
	^index! 
copyright
        "Answers the copyright information embedded in the
          image."
    | fileStream signatureString copyrightString |
    fileStream := File pathNameReadOnly: SessionModel current imageName.
    fileStream position: 11265.
    ( signatureString := fileStream next: 2 ) = 'CR'
        ifFalse: [ ^self error: 'Invalid image file' ].
    fileStream next.  "copyright seal is 'VCRV', skip past it"
    copyrightString := fileStream upTo: 0 asCharacter.
    fileStream close.
    ^copyrightString!  
freeDiskSpace
        "Answer the free space in bytes on the disk
         containing the current directory."

    ^self volume bytesFree!
volumeLabel
        "Answer the volume label of the disk
         containing the receiver."
	^self volume volumeLabel! 
numberOfArguments
        "Answer the number of arguments expected by the
         receiver."
    ^2!  
evaluate
        "Indicate an error, since the receiver does not expect
        0 arguments."
    ^self invalidArgumentCount: 0!   
evaluateWithArguments: argumentArray
        "Evaluate the receiver with the elements of the <argumentArray>
        as the argument values.  Error Conditions: If the number of
        arguments required by the receiver is different from the size
        of the argument array, send the message #invalidArgumentCount:
        to the receiver with the number of arguments provided as the
        argument."
    self validateNumberOfArguments: argumentArray size.
    ^self
        value: ( argumentArray at: 1 )
        value: ( argumentArray at: 2 )!  
value: arg1 value: arg2
        "Answer the result of evaluating the two argument block
         described by the receiver."
    <primitive: 39>!  
current
        "Answer the current instance which manages definition installation."
    Current isNil ifTrue: [ Current := self on: Smalltalk ].
    ^Current!
current: aDefinitionInstaller
        "Set the instance which manages definition installation to aDefinitionInstaller."
    Current := aDefinitionInstaller!
on: globalDictionary
	"Create an instance of the receiver that will create classes in <globalDictionary>"

	^self new
		setDefaultGlobalDictionary: globalDictionary! 
isBelow: aNumber
        "Answer true if the receiver is lower on the screen
         than aNumber, else answer false."
    ^self > aNumber!   
fromModule: aModuleName id: anInteger
        "Load the String from the module
        aModuleName with anInteger id."
    | modHandle numBytes stringBuffer |
    modHandle := DynamicLinkLibrary open: aModuleName.
    modHandle isDynamicLinkLibrary ifFalse: [
        ^self error: 'cannot open module'].
    stringBuffer := self new: 256.
    ( numBytes := UserLibrary loadString: modHandle
        id: anInteger
        buffer: stringBuffer
        maxChars: stringBuffer size ) = 0
            ifTrue: [ self osWarning. modHandle close. ^nil ].
    modHandle close.
    ^( stringBuffer copyFrom: 1 to: numBytes ) asNormalizedString!  
frameBias
        "Private - answer the process index of the frame bias."
    ^( endPosition - ( frameBias // self class frameBiasUnit ) + 1 )
        - ( startPosition - 1 )!
isNetworkPath
	"Answer true if the receiver represents a network entity"

	^false! 
evaluate
        "Answer the result of evaluating the receiver, or the receiver itself if
        it does not have any execution semantics."
    ^self!
fromPrintString: aString
        "Answer the CompiledMethod with the given printString,
        of the form ClassName>>selector, or nil if the specified method
        does not exist."
    | stream class selector |
    stream := aString asStream.
    ( ( class := stream upTo: $> ) includes: $ )
        ifTrue: [ class := ( Smalltalk at: ( class asStream nextWord ) asSymbol ) class ]
        ifFalse: [ class := Smalltalk at: class asSymbol ].
    stream next.
    selector := stream nextLine asSymbol.
    ^class compiledMethodAt: selector!
new
		"Answer a new instance of the receiver."
	^super new initialize!  
new: anInteger
        "Private - answer a new instance of the receiver class with the
        given number of literal slots."
    ^( super new: anInteger ) initialize!   
copy: sourcePath
to: destPath
	"Copy the file named oldFile to the
         file named newFile; answer true if successful,
         otherwise false."

	| source dest |
	[source := sourcePath asFileSystemPath asFileWithin: (Directory fromPath: Disk drivePathName).
		dest := destPath asFileSystemPath asFileWithin: (Directory fromPath: Disk drivePathName).
		dest exists
			ifTrue: [dest remove].
		source copyTo: dest directory as: dest name] on: FileError do: [^false].
	^true!
corner
        "Answer a Point, the bottom right
         corner of the receiver."
    ^self rightBottom!  
asUnicodeString
        "Answer a Unicode copy of the receiver."

    ^self asUnicodeStringNullTerminated: false!  
isMDIFrame
        "Answer true if receiver is an instance of class
         MDIFrame, else answer false."
    ^false! 
exists: aFileName
in: aDirectory
    "Answer true if the file or subdirectory specified
         by aFileName exists, else return false."

    ^(Directory fromPath: aDirectory drivePathName) hasEntityNamed: aFileName!
asExternalGlobalAddress
        "Answer the receiver as an ExternalGlobalAddress."
    ^ExternalGlobalAddress fromInteger: self!
allFilesDo: iterationBlock
    "Evaluate the <iterationBlock> once for each file contained within the receiver or any of its subdirectories. Each file passed to the iteration block should be released by the iteration block if it is not retained in some way.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated files."

    self filesDo: iterationBlock.
    self directoriesDo: [ : aDir |
        aDir allFilesDo: iterationBlock].! 
startupVolume
        "Answer an instance of the receiver representing the volume containing
        the currently executing operating system."
    | dirString |
    dirString := String new: 256.
    KernelLibrary
        getSystemDirectory: dirString asParameter
        length: dirString size asParameter.
    ^self named: ( FileSystemPath fromString: dirString ) drive!  
noFlushAt: selector put: compiledMethod inMethodDictionary: methodDictionary
    "Install <compiledMethod> into <methodDictionary>"

    ^methodDictionary privateAt: selector put: compiledMethod!
renameFrom: oldName to: newName inGlobalDictionary: globalDictionary
	"Rename the global named <oldName> to <newName>.  Quietly 
	do nothing if <oldName> is not defined"

	| association |
	association := globalDictionary associationAt: oldName ifAbsent: [^self].
	globalDictionary removeKey: oldName.
	association key: newName.
	globalDictionary privateAdd: association!
add: globalAssociation inGlobalDictionary: globalDictionary
	"Add <globalAssocation> to <globalDictionary>."

	^globalDictionary privateAdd: globalAssociation!
at: selector put: compiledMethod inMethodDictionary: methodDictionary
    "Install <compiledMethod> into <methodDictionary>"

    | answer |
    answer := methodDictionary privateAt: selector put: compiledMethod.
    methodDictionary flushFromCache: selector.
    ^answer!
removeClass: class
    "Remove <class> from the system."

    self defaultGlobalDictionary privateRemoveKey: class symbol ifAbsent: [].
    class class superclass == nil ifFalse:
        [class class superclass
             removeSubclass: class class].
    class superclass == nil ifFalse:
        [class superclass removeSubclass: class].
    class makeDeletedClass! 
defaultGlobalDictionary
	"Answer the global dictionary the receiver creates definitions in"

	^defaultGlobalDictionary!
at: globalName put: globalValue inGlobalDictionary: globalDictionary
	"Define the global variable <globalName>, initially set to <globalValue>"

	^globalDictionary privateAt: globalName put: globalValue!
removeKey: globalName ifAbsent: aBlock fromGlobalDictionary: globalDictionary
	"Remove the global variable <globalName>; if it does not exist answer the result of evaluating <aBlock>"

	^globalDictionary privateRemoveKey: globalName ifAbsent: aBlock! 
removeKey: selector ifAbsent: aBlock fromMethodDictionary: methodDictionary
	"Remove the compiled method named <selector> from <methodDictionary>"

	^methodDictionary privateRemoveKey: selector ifAbsent: aBlock!
renameClass: class to: aSymbol inGlobalDictionary: globalDictionary
	"Rename <class> to <aSymbol> in <globalDictionary>."

	class privateRename: aSymbol in: globalDictionary
		! 
setDefaultGlobalDictionary: aDictionary
	"Private"
	"Set the global dictionary for all classes, globals, etc created by the receiver to be <aDictionary>"

	defaultGlobalDictionary := aDictionary!   
writeFrom: aString toPage: anInteger for: size pageSize: sizeInteger
        "Private - Write size bytes of aString to
         the receiver file at page number anInteger.
         Page size is sizeInteger."
    | long |
    long := ExternalLong fromInteger: 0.
    ( KernelLibrary
        setFilePointer: self asParameter
        offset: anInteger * sizeInteger
        offsetHigh: long asParameter
        move: FileBegin ) = 16rFFFFFFFF
            ifTrue: [ ^self osError ].
    ( KernelLibrary
        writeFile: self asParameter
        buffer: aString
        bytesToWrite: size
        bytesWritten: long asParameter
        overlapped: nil )
            ifFalse: [ ^self osError ]
!
networkSeparator
    "Answer a string containing the characters used to denote the name of a network name (i.e., \\Server\file)."

    ^'\\'!  
isCharAlpha: aChar
    <api: IsCharAlphaA ushort boolean>
    ^self invalidArgument!
loadString: instHandle id: anInteger buffer: lpStringBuffer maxChars: anInteger2
    <api: LoadStringA ulong ulong struct long long>
    ^self invalidArgument! 
isCharAlphaNumeric: aChar
    <api: IsCharAlphaNumericA ushort boolean>
    ^self invalidArgument!  
messageBeep: anInteger
    <api: MessageBeep ulong boolean>
    ^self invalidArgument!  
isCharLower: aChar
    <api: IsCharLowerA ushort boolean>
    ^self invalidArgument!
isCharUpper: aChar
    <api: IsCharUpperA ushort boolean>
    ^self invalidArgument!
charLower: aString
    <api: CharLowerA ulong ulongReturn>
    ^self invalidArgument!   
getSysColor: anIndex
    <api: GetSysColor long ulong>
    ^self invalidArgument!   
charUpper: aCharacter
    <api: CharUpperA ulong ulongReturn>
    ^self invalidArgument!
getSystemMetrics: nIndex
    <api: GetSystemMetrics long long>
    ^self invalidArgument!   
getClipboardFormatName: cfFormat buffer: nameBuffer length: anInteger
    <api: GetClipboardFormatNameA ulong structOut long ulongReturn>
    ^self invalidArgument  !  
binder: aBinder external: anExternal
	"Signal that aBinder encountered an unresolved external."

    ^self new
		binder: aBinder;
		external: anExternal;
		signal! 
external
	"Answer the receiver's external."

	^external!   
messageText
        "Answer the message text associated with this exception."

    ^self class name, '( ', external printString, ' ) while binding ', self binder objectStore printString! 
external: anExternal
	"Private - Set the receiver's external."

	external := anExternal!   
isResumable
        "Return true if this is a resumable exception."
    ^true!  
binder
	"Answer the receiver's binder."

	^binder! 
binder: aBinder
	"Private - Set the receiver's binder."

	binder := aBinder!   
asPoint
        "Answer a Point containing the receiver as its x and y components."
    ^self @ self!   
asNumber
        "Answer the receiver as a number."
    ^Number fromString: self!   
targetBucketSize
    "Answer the number of elements expected per bucket.  This number should be large to conserve space, but small to reduce collisions (and conserve time)."

    ^127!   
new: anInteger
        "Answer a new instance of the receiver whose size is at least anInteger."

    ^ self basicNew: ( self hashModulusFor: ( anInteger // self targetBucketSize ) ) * 2!
shapeInfo: anAssociation
	"Private - Set the shape info for the receiver."

	shapeInfo := anAssociation!   
isResumable
        "Return true if this is a resumable exception."
    ^true!  
shapeInfo
	"Answer an Association whose key is the name
	of the class and whose value is the Dictionary
	of shape information."

	^shapeInfo!
initializeSystemValues
        "Private - clear cached SystemValues."
    SystemValues := Dictionary new!   
compareString: aString1 withString: aString2
        "Answer a constant representing the result of comparing 
         two strings. The comparison is case-sensitive.
         Answer < 0 if aString1 is less than aString2
                      = 0 if aString1 is identical to aString2
                      > 0 if aString1 is greater than aString2."
    ^KernelLibrary
        lStrCmp: aString1 asParameter
        withString: aString2 asParameter!
memoryHandleFrom: aVariableByteObject withAllocFlag: allocFlag
        "Private - copy aVariableByteObject into non-Smalltalk memory
         with allocFlags by doing a GlobalAlloc.  Maintained for
         backward compatibility."
    self checkGlobalAddress.
    ^ExternalGlobalAddress
        memoryHandleFrom: aVariableByteObject
        withAllocFlag: allocFlag!
canTriggerEvent: eventName
        "Answer whether instances of the receiver can trigger
         an event named <eventName>."
    ^self eventsTriggered includes: eventName asSymbol! 
sizeInBytes
    ^16! 
fromDate: aDate time: aTime
        "Private - answer a WinSystemTime based on the
       specified date and time."
    ^self new
        wMonth: aDate monthIndex;
        wDay: aDate dayOfMonth;
        wYear: aDate year;
        wHour: aTime hours;
        wMinute: aTime minutes;
        wSecond: aTime seconds;
        wMilliseconds: 0!
lastAccessTime: aTimeStamp
    "Set the TimeStamp of the date and time at which the receiver was last accessed."

    | wasOpen fileTime |
    [ ( wasOpen := self isOpen ) ifFalse: [ self open ].
        fileTime := WinFileTime fromDate: aTimeStamp date time: aTimeStamp time.
        fileTime := WinFileTime fromLocalFileTime: fileTime.
        ( KernelLibrary
            setFileTime: self fileId
            creation: nil
            lastAccess: fileTime asParameter
            lastWrite: nil )
                ifFalse: [ ^self osError ] ] ensure: [ wasOpen ifFalse: [ self close ] ]!  
isDynamicLinkLibrary
        "Answer true if receiver is a kind of DynamicLinkLibrary."
    ^false! 
wMinute: anInteger
    self uShortAtOffset: 10 put: anInteger!   
asFileTime
        "Private - answer the receiver converted to a WinFileTime."
    | fileTime |
    fileTime := WinFileTime new.
    KernelLibrary systemTime: self asParameter toFileTime: fileTime asParameter.
    ^fileTime! 
asTime
        "Private - answer a Time object which contains the
        same time as the receiver."
    ^Time
        hours: self wHour
        minutes: self wMinute
        seconds: self wSecond
!
wDayOfWeek
    ^self uShortAtOffset: 4!  
wSecond
    ^self uShortAtOffset: 12!
wSecond: anInteger
    self uShortAtOffset: 12 put: anInteger!   
printOn: aStream
    aStream nextPutAll: self class name, ' { ', self asTimeStamp printString, ' }'! 
wYear
    ^self uShortAtOffset: 0!   
wYear: anInteger
    self uShortAtOffset: 0 put: anInteger!  
wDayOfWeek: anInteger
    self uShortAtOffset: 4 put: anInteger! 
wMonth: anInteger
    self uShortAtOffset: 2 put: anInteger! 
asDate
        "Private - answer a Date object which contains the
        same date as the receiver."
    ^Date
        newDay: self wDay
        month: ( Date nameOfMonth: self wMonth )
        year: self wYear
!  
wHour
    ^self uShortAtOffset: 8!   
wHour: anInteger
    self uShortAtOffset: 8 put: anInteger!  
asTimeStamp
        "Answer the receiver converted to a TimeStamp object."
    ^TimeStamp date: self asDate time: self asTime!  
wMilliseconds
    ^self uShortAtOffset: 14!  
wDay
    ^self uShortAtOffset: 6!
wMilliseconds: anInteger
    self uShortAtOffset: 14 put: anInteger! 
wMonth
    ^self uShortAtOffset: 2!  
wDay: anInteger
    self uShortAtOffset: 6 put: anInteger!   
wMinute
    ^self uShortAtOffset: 10!
new
        "Create a new instance of the receiver.  Disallowed
         for this class because there is only a single
         instance, nil."
    ^self invalidMessage! 
new: anInteger
        "Create a new instance of the receiver.  Disallowed
         for this class because there is only a single
         instance, nil."
    ^self invalidMessage!  
isNil
        "Answer true because the receiver is nil."
    ^true! 
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable.  Because
         there is only one nil, answer the receiver."
    ^self! 
asParameter
        "Answer the receiver in a form suitable for
         passing as a parameter to a host procedure call."
    ^self!  
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    aStream nextPutAll: 'nil'! 
notNil
        "Answer false because the receiver is nil."
    ^false!  
storeOn: aStream
        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reconstructed."
    self printOn: aStream!  
shallowCopy
        "Answer a copy of the receiver which shares
         the receiver instance variables.  Because
         there is only one nil, answer the receiver."
    ^self!   
library
    "Obsolete - Answer the Library which contains the receiver, or nil
    if the receiver is in the base library or the image."

    ^self smalltalkLibrary! 
openReadOnly
        "Open the file with a new file handle."

    self isOpen ifTrue: [ self close ].
    self fileId: ( FileHandle openReadOnly: self name in: self directory )! 
win32sVersion
        "Answer the version number of Win32s, as a String.
        If the host operating environment is not Win32s,
        answer nil."
    | sysDir length win32sVer |
    self isWindows ifFalse: [ ^nil ].
    sysDir := String new: 80.
    ( length := KernelLibrary getSystemDirectory: sysDir length: sysDir size ) = 0
        ifTrue: [ ^self osError ].
    sysDir := sysDir copyFrom: 1 to: length.
    win32sVer := String new: 80.
    length := KernelLibrary
        getPrivateProfileString: 'Win32s'
        keyName: 'Version'
        default: '<unknown>'
        returnedString: win32sVer
        size: win32sVer size
        iniFileName: sysDir, '\win32s.ini'.
    win32sVer := win32sVer copyFrom: 1 to: length.
    ^win32sVer! 
quit
        "Private - terminate the Smalltalk session"
    KernelLibrary exitProcess: 0!  
asParameter
        "Answer the receiver in a form suitable for passing as
         a parameter to a host procedure call."
    ^1! 
eqv: aBoolean
        "Answer true if the receiver is equivalent
         to aBoolean, else answer false."
    ^aBoolean!  
not
        "Answer true if the receiver
         is false, else answer false."
    ^false!
| aBoolean
        "Answer true if either the receiver or
         aBoolean are true, else answer false."
    ^true!   
ifTrue: trueBlock ifFalse: falseBlock
        "If the receiver is true, answer the result of
         evaluating trueBlock, else answer the result
         of evaluating falseBlock.  Both block are
         evaluated with no arguments."
    ^trueBlock value!   
basicHash
        "Private - Answer the hash of true."
    ^16r3FFE!
ifFalse: falseBlock ifTrue: trueBlock
        "If the receiver is true, answer the result of
         evaluating trueBlock, else answer the result
         of evaluating falseBlock.  Both blocks are
         evaluated with no arguments."
    ^trueBlock value!  
ifTrue: aBlock
        "If the receiver is true, answer the result of
         evaluating aBlock (with no arguments), else
         answer nil."
    ^aBlock value!   
xor: aBoolean
        "Answer true if the receiver is not equivalent
         to aBoolean, else answer false."
    ^aBoolean not!  
or: aBlock
        "If the receiver is false, answer the result
         of evaluating aBlock, else answer true."
    ^true!   
and: aBlock
        "If the receiver is true, answer the result of
         evaluating aBlock (with no arguments), else
         answer false."
    ^aBlock value!
hash
        "Answer the hash of true."
    ^16r3FFE!   
ifFalse: aBlock
        "If the receiver is false, answer the result of
         evaluating aBlock (with no arguments), else
         answer nil."
    ^nil!  
& aBoolean
        "Answer true if both the receiver and
         aBoolean are true, else answer false."
    ^aBoolean!
isValid
	"Answer true, since ByteArrays are always valid as bit holders for data structures."

	^true! 
leftBottomUnit
        "Answer the left bottom corner for a one-unit rectangle."
    ^0@1!  
replaceEscapeCharacters
        "Replace any C-style escape sequences
        with their literal character equivalents."
    | inStream outStream char |
    inStream := self asStream.
    outStream := ( self species new ) asStream.
    [ inStream atEnd ] whileFalse: [
        ( char := inStream next ) == $\
            ifTrue: [
                char := inStream next.
                char == $n
                    ifTrue: [ outStream nextPut: Lf ].
                char == $t
                    ifTrue: [ outStream tab ].
                char == $u
                    ifTrue: [ outStream nextPut: $& ].
            ]
            ifFalse: [ outStream nextPut: char ] ].
    ^outStream contents!  
triggerEvent: eventName ifNotHandled: exceptionBlock
        "Trigger the event named <eventName>.  If the event is
        not handled, answer the value of <exceptionBlock>,
        otherwise answer the value returned by the
        most recently defined event handler action."
    ^(self eventTable
        at: eventName asSymbol
        ifAbsent: [^exceptionBlock value])
            evaluate!  
fileSizeForFileNamed: aString
	"Answer the size of the file in the receiver named <aString>"

	self
		searchResultsDo:
			[:searchResult |
			(searchResult entityName equalsIgnoreCase: aString)
				ifTrue: [^searchResult fileSize]].
	^nil!   
hash
    "Answer an integer hash value for the receiver.
        Invariants:
        -    The hash value of an object must be constant over time.
        -    Two objects that compare equal must have equal hash values.
        Implementation Comments:
        -    The standard implementation is to return the result of sending the message #basicHash to the receiver."

    ^self absolutePath asString hash!   
trim: nameString
to: maximumLength
discardingIf: discardBlock
    "Private"
    "Answer a string derived from the <nameString> that is as close as possible to the <maximumLength>. The resulting string will only contain characters for which the <discardBlock> evaluates to <false>."

    | result index character |
    result := nameString.
    index := result size.
    [ index > 0 and: [result size > maximumLength ] ]
        whileTrue: [
            character := result at: index.
            ( discardBlock value: character )
                ifTrue: [result := result copyReplaceFrom: index to: index with: '' ].
            index := index - 1 ].
    ^result!
isValidComponentCharacter: character
    "Private"
    "Answer <true> if the given <character> is a valid part of a component name."

    ^true!  
relative: components
    "Answer an instance of the receiver representing the relative path whose components are the elements of the list of <components>."

    | path |
    path := self new.
    path absolute: #directoryRelative.
    path componentNames: components.
    ^path! 
validBaseName: baseName
extension: extension
    "Private"
    "Answer a valid component name derived from the <baseName> and <extension>, separated by the extension separator, or <nil> if a valid name cannot be derived."

    | separator validExtension maxBaseLength validBase |
    separator := self extensionSeparator.
    validExtension := self
        validNameFrom: extension
        maximumLength: self maximumExtensionLength.
    maxBaseLength := self maximumBaseNameLength.
    validExtension isEmpty
        ifFalse: [maxBaseLength := maxBaseLength min: self maximumComponentLength - validExtension size - separator size].
    validBase := self
        validNameFrom: baseName
        maximumLength: maxBaseLength.
    validBase isEmpty
        ifTrue: [^nil].
    validExtension isEmpty
        ifTrue: [^validBase].
    ^validBase , separator , validExtension!  
extensionSeparator
    "Answer a string containing the character(s) used to separate the base name of a file from the file extension."

    ^'.'!  
fromString: pathString
startingAt: startingAt
volume: volumeName
    "Private"

    | separator where components relativePath path |
    separator := self directorySeparator.
    where := pathString indexOfString: separator startingAt: startingAt.
    where = 0
        ifTrue:
            [relativePath := volumeName == nil.
            components := relativePath
                ifTrue: [Array with: pathString trimBlanks]
                ifFalse:
                    ["Happens when only drive name given for path - a:"
                    Array new]]
        ifFalse:
            [relativePath := (where - startingAt) > 0.
            components := relativePath
                ifTrue: [self splitPath: pathString startingAt: startingAt]
                ifFalse: [self splitPath: pathString startingAt: where + (separator size)]].
    relativePath
        ifTrue:
            [path := self relative: components]
        ifFalse:
            [volumeName == nil
                ifTrue: [path := self volumeRelative: components]
                ifFalse: [path := self absolute: (Array with: volumeName) , components]].
    ^path! 
absolute: components
    "Answer an instance of the receiver representing the absolute path whose components are the elements of the list of <components>."

    | path |
    path := self  new.
    path absolute: #absolute.
    path componentNames: components.
    ^path! 
baseName: baseName
extension: extension
    "Answer an instance of the receiver representing a relative path whose sole component is a valid name derived from the <baseName> and <extension>, separated by the extension separator."

    ^self relative: (Array with: (self 
        validBaseName: baseName
        extension: extension))!  
validNameFrom: nameString
maximumLength: maximumLength
    "Private"
    "Answer a string derived from the <nameString> containing only valid characters that is not longer than the <maximumLength>."

    | validCharacters |
    "Begin by discarding illegal characters."
    validCharacters := nameString
        select:
            [:each |
            self isValidComponentCharacter: each].
    validCharacters size <= maximumLength
        ifTrue: [^validCharacters].

    "Then discard non alpha-numeric characters."
    validCharacters := self
        trim: validCharacters
        to: maximumLength
        discardingIf: [:character | character isAlphaNumeric not].
    validCharacters size <= maximumLength
        ifTrue: [^validCharacters].

    "Then disard lowercase vowels."
    validCharacters := self
        trim: validCharacters
        to: maximumLength
        discardingIf: [:character | character isLowercase and: [character isVowel]].
    validCharacters size <= maximumLength
        ifTrue: [^validCharacters].

    "Finally, truncate."
    ^validCharacters copyFrom: 1 to: (validCharacters size min: maximumLength)! 
splitPath: pathString
startingAt: startIndex
    "Private"
    "Split the <pathString> at occurances of the directory separator. Ignore the characters before the <startIndex>."

    | components separator separatorSize start end limit |
    components := OrderedCollection new.
    separator := self directorySeparator.
    separatorSize := separator size.
    start := startIndex.
    limit := pathString size.
    [start <= limit]
        whileTrue:
            [end := pathString indexOfString: separator startingAt: start.
            end = 0
                ifTrue: [end := limit + 1].
            components add: (pathString copyFrom: start to: end - 1) trimBlanks.
            start := end + separatorSize].
    ^components! 
isTimeFormat12Hour
        "Answer whether the current system time format is 12-hour."
    ^self timeFormat = 0!
asString
	"Answer a string representation of the receiver in the native syntax.
        Invariants:
        -   The result must be in a form accepted by the method #fromString:, as implemented by the class of the receiver, and the path create by #fromString: when passed the result of thi method must be equal to the receiver."

	^self asStringWithVolume: true!
isAboveEqual: aNumber
        "Answer true if the receiver is higher or equal on the screen
         than aNumber, else answer false."
    ^self <= aNumber!   
sortBlock
        "Answer a sort block for sorting
         classes alphabetically."
    ^[ :a :b | a symbol <= b symbol ]!
relative: components
    "Answer an instance of the receiver representing the relative path whose components are the elements of the list of <components>."

    self invalidMessage!  
volumeRelative: components
    "Answer an instance of the receiver representing the relative path whose components are the elements of the list of <components>."

    self invalidMessage!
asString
	"Answer a string representation of the receiver in the native syntax.
        Invariants:
        -   The result must be in a form accepted by the method #fromString:, as implemented by the class of the receiver, and the path create by #fromString: when passed the result of thi method must be equal to the receiver."

	| components directorySeparator pathStream startIndex |
	components := self componentNames.
	directorySeparator := self class directorySeparator.
	pathStream := WriteStream on: (String new: self class maximumPathLength).
	pathStream
		nextPutAll: self class networkSeparator;
		nextPutAll: (components at: 1).
	startIndex := 2.
	components size = 1
		ifTrue:
			[pathStream nextPutAll: directorySeparator]
		ifFalse:
			[startIndex to: components size
				do:
					[:componentIndex |
					((startIndex = componentIndex) and: [self isRelative])
						ifFalse: [pathStream nextPutAll: directorySeparator].
					pathStream nextPutAll: (components at: componentIndex)]].
	^pathStream contents!
isNetworkPath
	"Answer true if the receiver represents a network entity"

	^true!  
releaseMemory
        "Private - Release the memory at the receiver's address."
    self isValid ifTrue: [
        KernelLibrary globalUnlock: memoryHandle asParameter.
        ( KernelLibrary globalFree: memoryHandle asParameter ) = 0
            ifFalse: [ ^self osError ] ]!
dateAndTimeNow
        "Answer an Array of two elements containing
         the current date and the current time."
    ^Date dateAndTimeNow!  
hours: anInteger1 minutes: anInteger2 seconds: anInteger3
        "Answer a Time which represents the given
         number of hours, minutes, and seconds from
         midnight of the current day."
    ^self new
        seconds: (anInteger1 * 60 + anInteger2 * 60 + anInteger3)!  
millisecondsToRun: aBlock
        "Answer the number of milliseconds it
         takes to evaluate aBlock."
    | startTime deltaTime |
    startTime := self millisecondClockValue.
    aBlock value.
    deltaTime := self millisecondClockValue - startTime.
    deltaTime negative
        ifTrue: [ deltaTime := deltaTime +  86400000 "24 * 60 * 60 * 1000" ].
    ^deltaTime! 
fromSeconds: anInteger
        "Answer a Time which represents anInteger
         number of seconds from midnight."
    | secondsInDay |
    secondsInDay := 24 * 60 * 60.
    ^self new seconds:
        (anInteger < 0
            ifTrue: [secondsInDay - (anInteger abs \\ secondsInDay)]
            ifFalse: [anInteger \\ secondsInDay])!  
current
        "Answer the current time."
    ^TimeStamp current time! 
millisecondClockValue
        "Answer the number of milliseconds from midnight
         of the current day to the current time."
    self currentTimeInto: ValueArray.
    ^( ( ValueArray at: 1 ) * 60 * 60 * 1000 )
        + ( ( ValueArray at: 2 ) * 60 * 1000 )
            + ( ( ValueArray at: 3 ) * 1000 )
                + ( ValueArray at: 4 )! 
fromString: aString
        "Answer a Time for the value given by aString.
        aString must be in the form specified by the
        current system time format."
    | aStream hh mm ss timeSeparator timeId |
    aStream := ReadStream on: aString.
    timeSeparator := NationalLanguage timeSeparator at: 1.
    hh := (aStream upTo: timeSeparator) asInteger.       " hours "
    ((NationalLanguage isTimeFormat12Hour and: [hh = 0 or: [hh > 12]])
     or: [(NationalLanguage isTimeFormat12Hour = false) and: [hh > 23]])
        ifTrue: [^self error: 'error in hours'].
    mm := (aStream upTo: timeSeparator) asInteger.    " minutes "
    (mm > 59) ifTrue: [^self error: 'error in minutes'].
    ss := (aStream upTo: $ ) asInteger.                            " seconds "
    (ss > 59) ifTrue: [^self error: 'error in seconds'].
    timeId := aStream next: ((aStream readLimit) - (aStream position)).
    timeId := timeId trimBlanks.
    (NationalLanguage isTimeFormat12Hour)
        ifTrue: [                "12 hours"
            (hh = 12) ifTrue: [hh := 0].
            (timeId = NationalLanguage time1159)
                ifFalse: [
                    (timeId = NationalLanguage time2359)
                        ifTrue: [ hh := hh + 12]
                        ifFalse: [^self error: 'error in time string']]]
        ifFalse: [                "24 hours"
            (timeId size > 0) ifTrue: [^self error: 'invalid time string format']].
    ^self fromSeconds: ( hh * 60 + mm * 60 + ss)!  
mouseClockValue
        "Private - Answer the current second and
         millisecond clock value as milliseconds
         (used for timing mouse events)."
    self currentTimeInto: ValueArray.
    ^( ValueArray at: 3 ) * 1000 + ( ValueArray at: 4 )!   
now
        "Answer a Time representing the
         current time in seconds."
    ^self current!  
seconds: anInteger
        "Answer the receiver.  Set the number
         of seconds in the receiver to anInteger."
    seconds := anInteger!  
= aTime
        "Answer true if the receiver is
         equal to aTime, else answer false."
    ^aTime isTime and: [ self asSeconds = aTime asSeconds ]!  
addTime: timeAmount
        "Answer a Time which is timeAmount
         seconds past the receiver time."
    ^self class fromSeconds:
        (self asSeconds + timeAmount asSeconds)!
asTime
        "Answer the receiver as an instance of Time."
    ^self! 
subtractTime: timeAmount
        "Answer the time that is timeAmount
         seconds before the receiver time."
    ^self class fromSeconds:
        (self asSeconds - timeAmount asSeconds)!
printOn: aStream
        "Append a string representing the receiver time
         to aStream in the form specified by the current
         system time format."
    | time am |
    am := true.
    time := self hours.
    NationalLanguage isTimeFormat12Hour ifTrue: [
        time > 12
            ifTrue: [
                time := time - 12.
                am := false]
            ifFalse: [
                (time = 12)
                    ifTrue: [am := false]
                    ifFalse: [ time = 0 ifTrue: [time := 12]]]].
    (time < 10) ifTrue: [aStream nextPut: $0 ].
    time printOn: aStream.
    aStream nextPutAll: NationalLanguage timeSeparator.
    time := self minutes.
    (time < 10) ifTrue: [aStream nextPut: $0 ].
    time printOn: aStream.
    aStream nextPutAll: NationalLanguage timeSeparator.
    time := self seconds.
    (time < 10) ifTrue: [aStream nextPut: $0 ].
    time printOn: aStream.
    (NationalLanguage isTimeFormat12Hour)
        ifTrue: [
            aStream nextPutAll: ' '.
            am
                ifTrue: [aStream nextPutAll: NationalLanguage time1159]
                ifFalse: [aStream nextPutAll: NationalLanguage time2359]].!   
isTime
        "Answer whether the receiver is a Time. "
    ^true! 
< aTime
        "Answer true if the receiver is less than
         aTime, else answer false."
    ^self asSeconds < aTime asSeconds!   
<= aTime
        "Answer true if the receiver is less than
         or equal to aTime, else answer false."
    ^self asSeconds <= aTime asSeconds! 
hours
        "Answer an Integer representing
         the number of hours of
         the receiver time."
    ^self asSeconds // 3600!   
minutes
        "Answer an Integer representing
         the number of minutes past
         the hour in the receiver time."
    ^self asSeconds \\ 3600 // 60!   
> aTime
        "Answer true if the receiver is greater than
         aTime, else answer false."
    ^self asSeconds > aTime asSeconds!
>= aTime
        "Answer true if the receiver is greater than
         or equal to aTime, else answer false."
    ^aTime asSeconds <= self asSeconds!  
hash
        "Answer the integer hash value for the receiver."
    ^seconds hash!   
asSeconds
        "Answer an Integer representing
         the number of seconds of
         the receiver time."
    ^seconds!
seconds
        "Answer an Integer representing
         the number of seconds past
         the minute in the receiver time."
    ^self asSeconds \\ 60! 
isNumber
        "Answer true if receiver is a kind of Number."
    ^false! 
isCompiledMethod
        "Answer true if receiver is a kind of CompiledMethod."
    ^false! 
osWorkaround
        "A marker for methods in the system that contain workarounds to
        host operating system bugs / limitations."!
when: eventName send: selector to: anObject with: argument
        "Form an action with <anObject> as the receiver,
        a <selector> as the message selector, and <argument>
        as the argument and append it to the actions
        list for the event named <eventName>."
    self
        when: eventName
        send: selector
        to: anObject
        withArguments: (Array with: argument)! 
fromCollection: aCollection
        "Answer an instance of the receiver whose elements
        are the elements of <aCollection>."

    | new idx |
    new := self new: aCollection size.
    idx := 0.
    aCollection do: [ :each |
        new at: ( idx := idx + 1 ) put: each ].
    ^new! 
asMinimalRepresentation
        "Answer the minimal representation of the receiver."

    ^self isEmpty
        ifTrue: [ nil ]
        ifFalse: [ self size = 1
            ifTrue: [ self at: 1 ]
            ifFalse: [ self ] ]!   
evaluateWithArguments: anArray
        "Answer the result of evaluating the elements of the receiver
        with <anArray> as the arguments."

    | answer |
    self do: [ :each |
        answer := each evaluateWithArguments: anArray ].
    ^answer!
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    | limit |
    (RecursiveSet includes: self)
        ifTrue: [^self printRecursionOn: aStream].
    RecursiveSet add: self.
    limit := aStream position + self printLimit.
    self class printOn: aStream.
    aStream nextPutAll: ' ('.
    1 to: self size - 1 do: [ :element |
        (aStream position > limit)
            ifTrue: [
                '...etc...)' printOn: aStream.
                RecursiveSet remove: self ifAbsent: [].
                ^self].
        (self at: element) printOn: aStream.
        aStream space].
    self isEmpty
        ifFalse: [
            self last printOn: aStream].
    aStream nextPut: $).
    RecursiveSet remove: self ifAbsent: []!  
asActionSequence
        "Answer the receiver."

    ^self!
evaluate
        "Answer the result of evaluating the elements of the receiver."

    | answer |
    self do: [ :each |
        answer := each evaluate ].
    ^answer! 
evaluateWithSelector: aSymbol withArguments: anArray
        "Answer the result of evaluating the elements of the receiver
        with <aSymbol> as the selector and <anArray> as the arguments.
        The elements must be Messages.  Use only when processing
        updates due to a #changed event."

    | answer |
    self do: [ :each |
        answer := each receiver
            perform: aSymbol
            withArguments: anArray ].
    ^answer!
asArray
        "Answer an Array containing all
         the elements of the receiver."

    | answer index |
    answer := Array new: self size.
    index := 1.
    self do: [ :element |
        answer at: index put: element.
        index := index + 1].
    ^answer!
eventTableForEdit
        "Private - answer the table of event handlers for the receiver.
        Allocate if necessary so that updates can be stored."
    ^EventHandlers
        at: self
        ifAbsentPut: [self eventTableCreate]!
freeAddress: anAddress size: anInteger
        "Private - Free a block of memory at anAddress
         suballocated from the receiver."
    | count result |
    [
        count := ( HeapUseCounts at: self ) - 1.
        HeapUseCounts at: self put: count.
        ( count = 0 and: [ Heaps size > 1 ] ) ifTrue: [
            HeapUseCounts removeKey: self ifAbsent: [ nil ].
            Heaps remove: self ] ] evaluateWithoutInterrupts.
    result := KernelLibrary
        heapFree: self asParameter
        flags: 0
        address: anAddress asParameter.
    result ifFalse: [ ^self osError ]!
exists
    "Answer <true> if the receiver represents an existing component on the file system."

    ^self class exists: self absolutePath asString!   
create
    "Create the entity represented by the receiver."

    self class createDirectoryNamed: self absolutePath asString!  
isLargeInteger
        "Answer true if receiver is a kind of LargeInteger."
    ^false! 
isBehavior
        "Answer true if receiver is a kind of Behavior."
    ^false! 
current
    "Answer an instance of the receiver representing the directory used to access the file system when no directory is specified."

    | aString length |
    aString := String new: 255.
    ( length := KernelLibrary getCurrentDirectory: aString size buffer: aString ) = 0
        ifTrue: [ ^self osError ].
    aString := ( aString copyFrom: 1 to: length ) asNormalizedString.
    ^self fromPath: aString!
ensure: terminationBlock
        "Return the result of evaluating the receiver. Before returning,
        but after evaluating the receiver, evaluate the <terminationBlock>.
        The value of the termination block is ignored. If a block attempts
        to return from a method which (indirectly) invoked the receiver,
        either directly or indirectly, evaluate the termination block before
        returning from the enclosing method.
        Implementation Comments:  The receiver is evaluated by sending
        the receiver the message #value."
    | result |
    result := self
        setUnwind:
            [:aContext :returnValue |
            terminationBlock value.
            aContext return: returnValue].
    terminationBlock value.
    ^result!   
fromString: pathString
	"Answer an instance of the receiver representing the path whose native representation is given by the <pathString>. Note that if the path string is in non-native format it will not be interpreted correctly.
        Invariants:
        -   This method must accept the strings resulting from sending the message #asString to an instance of the receiver."

	| separator where driveName |
	separator := self networkSeparator.
	pathString size > 2
		ifTrue:
			[where := pathString indexOfString: separator.
			where = 1
				ifTrue:
					[where := pathString indexOfString: self directorySeparator startingAt: 3.
					where = 0
						ifTrue: [
                         driveName := pathString copyFrom: 3 to: pathString size.
                         where := pathString size]
						ifFalse: [driveName := pathString copyFrom: 3 to: where - 1].
					^NetworkFilePath
							fromString: pathString
							startingAt: where
							volume: driveName]].
	separator := self volumeSeparator.
	where := pathString indexOfString: separator.
	where = 0
		ifTrue: [driveName := nil]
		ifFalse: [driveName := pathString copyFrom: 1 to: where - 1].
	where := where + 1.
	^self
			fromString: pathString
			startingAt: where
			volume: driveName!   
handles: anException
	"Answer <true> if a any of the exceptions in this exception
	set can handle <anException>."

	self exceptions
		detect:
			[:ex | ex handles: anException]
		 ifNone: [^false].
	^true! 
, arg
	"Answer the receiver with arg added to its list of exceptions"

	self exceptions add: arg!  
exceptions
	"Private - Answer a collection of exceptions in the ExceptionSet"

	exceptions == nil
		ifTrue: [exceptions := Set new].
	^exceptions!   
apiPrimitiveMap
        "Private - answer a Dictionary mapping API calling
         conventions to their API call primitive number."
    ^Dictionary new
        at: 'api:' put: 9;
        at: 'pascal:' put: 9;
        at: 'pascal16:' put: 9;
        at: 'c:' put: 8;
        at: 'c16:' put: 8;
        yourself!  
setCompilationOptions: aCompilerInterface
	"The message is sent when a compiler interface object is being created
	that will process method definitions within the receiver.  The receiver may
	add or modify any compilation options by sending appropriate message to 
	the argument"

	aCompilerInterface addOption: #ApiFormat with: 'DLL16'!   
currency
        "Answer the current system value for currency symbol."
    currency isNil
        ifTrue: [ currency := self queryNationalProfileString: 'sCurrency' default: '$' ].
    ^currency!  
fromPath: path
    "Answer an instance of a subclass of the receiver representing an entity with the given path."

	^path asFileSystemLocator asFile!  
fromPath: path
in: parentDirectory
	"Answer an instance of a subclass of the receiver representing an entity with the given path. If the path is an absolute path, the parent directory is ignored. If the path is a relative path the path name is assumed to be relative to the parentDirectory."

	| locator |
	locator := path asFileSystemLocator.
	locator isRelative
		ifTrue: [^locator asFileWithin: parentDirectory]
		ifFalse: [^locator asFile]!  
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^true!   
hasFinalization
    "Answer whether the receiver is registered for finalization."

    ^self finalizationRegistry includes: self!  
recomputeMethodArray
        "generate a new method array for this class containing
        a copy of the current local method dictionary"

	| newBehavior |
	newBehavior := Array with: self methodDictionary fastCopy.
	self superclass == nil
		ifFalse: [newBehavior := newBehavior , self superclass methodDictionaries].
	self methodDictionaries: newBehavior
!   
drive
        "Answer the disk drive letter of the receiver." 

	^self absolutePath components first!  
isMemberOf: aClass
        "Answer true if the receiver is an instance
         of aClass, else answer false."
    ^self class == aClass!  
isString
        "Answer true if receiver is a kind of String."
    ^false! 
isModulePE: aPathName
        "Private - answer whether the named file is a valid
        PE (Win32 executable module)."
    | stream signature peSignature |
    peSignature := 'PE' asAsciiZ asAsciiZ.
    stream := ( File fromPath: aPathName ) binaryReadStream.
    stream readLimit < 16r80 ifTrue: [ ^false ].
    stream position: 16r80.
    signature := stream next: 4.
    stream close.
    ^signature = peSignature! 
negativeClass
        "Private - answer the class to use when negating instances of
        this class."
    ^LargePositiveInteger!
negativeClass
        "Private - answer the class to use when negating instances of
        this class."
    ^LargeNegativeInteger!
valid 
        "Answer true if the receiver is valid." 

	^self exists!
hash
    "Answer an integer hash value for the receiver.
        Invariants:
        -    The hash value of an object must be constant over time.
        -    Two objects that compare equal must have equal hash values.
        Implementation Comments:
        -    The standard implementation is to return the result of sending the message #basicHash to the receiver."

    ^self absolutePathString hash!  
isResidueOrNil
	"Answer true if the receiver is the distinguished object: residue or nil, otherwise false."

	^false!  
windowSizingBorderSize
        "Answer a Point which specifies the sizing border size."
    ^( self getSystemValue: SystemValueWindowSizingBorderWidth )
        @ ( self getSystemValue: SystemValueWindowSizingBorderHeight )!   
open: aString
in: aDirectory
attribute: anAttr
mode: aMode
	"Answer a File opened on a file 
         named aString in aDirectory with attribute anAttr 
         and aMode as the file open mode. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details."

	^(aDirectory fileNamed: aString) open: anAttr mode: aMode! 
changedEventName
        "Private - answer the name of the event to generate when a
        changed message is received."
    ^#changed!   
openDevice: aString
        "Answer a FileHandle for the device named aString."
    ^self
        open: aString
        access: GenericRead | GenericWrite
        share: 0
        create: OpenExisting
        attributes: FileAttributeNormal!  
fileName
        "Answer the receiver's file name."
    ^'user32'!  
getCurrent
        "Private - get (open) an instance of the receiver."
    ^UserLibrary!
classes
		"Answer a collection of the classes which are
        included in the receiver."

	^root at: 'Classes' ifAbsent: [ #() ].!  
moduleHierarchy
	"Answer an array of Strings or nil. The first n-1 strings in <anArrayOfStrings> define the cluster structure to be created (or used) when the library is bound into a VSE image. The nth string is the name of the package that all new methods will be loaded into."

	^self metaInfo at: 'moduleHierarchy' ifAbsent:[nil]!  
postBindCleanUp
	"Private - Release unnecessary objects."

	self root
		removeKey: 'InitAction' ifAbsent: [] ;
		removeKey: 'Globals' ifAbsent: [] ;
		removeKey: 'HiddenGlobals' ifAbsent: [] ;
		removeKey: 'InitAction' ifAbsent: [].
	self metaInfo
		removeKey: 'imports' ifAbsent: [ ] ;
		"removeKey: 'prereqs' ifAbsent: [ ] ; keep them for unbind"
		removeKey: 'shapes' ifAbsent: [ ].! 
hiddenClasses
		"Private - Answer a collection of the hidden classes which are
        included in the receiver."

	^root at: 'HiddenClasses' ifAbsent: [ Array new ].!   
previousMethodOf: aMethod
        "Answer the method which aMethod replaced
        when the receiver was bound (if any)."

    | prevMethods |
    prevMethods := self prevMethods.
    prevMethods isNil ifTrue: [ ^nil ].
    ^prevMethods at: aMethod ifAbsent: [ nil ].!  
hiddenGlobals
		"Private - Answer a collection of the hidden globals which are
        included in the receiver."

    ^root at: 'HiddenGlobals' ifAbsent: [ nil ].!  
abortUnbind
        "Use this message to prevent unbinding a library
        in response to the #aboutToUnbind event."

    VetoAction signal!
bindAction
        " Answer the bind action of the receiver. "

    ^root at: 'InitAction' ifAbsent: [ nil ]!  
prerequisites
    "Private - Answer the prerequisites for the receiver."

    ^self metaInfo at: 'prereqs' ifAbsent: [ nil ].! 
reallyUnBind
    "Private - Remove the receiver from the system."

    self root isEmpty ifTrue: [ ^BindError signal:  'cannot unbind because unbind info has been released' ].
    SmalltalkLibraryBinder currentClass new
        objectStore: self;
        unBind!  
unBindAction
        " Answer the unBind action of the receiver. "

    ^root at: 'UnBindAction' ifAbsent: [ nil ]!
releaseUnbindInfo
	"Release objects that would be used for an unBind.
	Sending this message is an assertion that the receiver will not be unbound."

	| sourceRef sourceBase integralSource refCount moduleHierarchy |
	self root: Dictionary new.
	refCount := self referenceCount.
	Smalltalk isRunTime ifFalse: [
		sourceRef := self sourceReference.
		sourceBase := self sourceBase.
		integralSource := self integralSource.
		moduleHierarchy := self moduleHierarchy ].
	metaInfo := Dictionary new.
	metaInfo at: 'refCount' put: refCount.
	Smalltalk isRunTime ifFalse: [
		metaInfo at: 'sourceReference' put: sourceRef.
		metaInfo at: 'sourceBase' put: sourceBase.
		metaInfo at: 'integralSource' put: integralSource.
		metaInfo at: 'moduleHierarchy' put: moduleHierarchy ]!   
methods
	"Answer a collection of the methods which are
	included in the receiver."

	^root at: 'Methods' ifAbsent: [ nil ].!  
unBind
        "Unbind the receiver."

	self decrementReferenceCount.
	self referenceCount <= 0 ifTrue: [ self reallyUnBind ].!   
globals
		"Answer a collection of the globals which are
        included in the receiver."

    ^root at: 'Globals' ifAbsent: [ nil ].!   
ISSUE
        "Mark a method which needs to be reviewed and possibly corrected to resolve a
        design or implementation issue.  Typically sent to self and followed by a
        comment describing the issue."!  
writeStream
    "Answer a WriteStream streaming over the contents of the receiver."

	| copy |
	copy := self copy.
	copy fileSystemLocator: self fileSystemLocator absolutePath.
	^FileStream on: copy open!
searchResultsDo: iterationBlock onPattern: filterString
    "Private - Raw traversal of directory contents ... searchResult
contains interesting information"

    | searchResult |
    searchResult := self findFirst: filterString.
    [searchResult notNil
            ifTrue:
                [(searchResult isInteresting) ifTrue: [iterationBlock
value: searchResult].
                [(self findNext: searchResult) notNil]
                    whileTrue:
                        [searchResult isInteresting
                            ifTrue: [iterationBlock value: searchResult]]].
        ] ensure: [searchResult == nil ifFalse: [self endSearch:
searchResult]].! 
valueMarked
        "Private - evaluate the receiver after marking the sending
        method as having created a protected block. Only one method
        may be so marked."
    <primitive: 1>
    ^self primitiveFailed!  
lastModificationTime
    "Answer a TimeStamp of the date and time at which the receiver was last modified."

    ^self directory lastWriteTimeForEntityNamed: self name!   
queryNationalProfileString: aKeyName default: defaultValue
        "Answer the string value of key aKeyName in
        the [Intl] application section of the WIN.INI profile file.
        Answer defaultValue if aKeyName cannot be found."
    | extString result |
    extString := ( String new: 80 ) asParameter.
    result := KernelLibrary getProfileString: 'Intl' asParameter
        keyName: aKeyName asParameter
        default: '' asParameter
        returnedString: extString
        size: extString size.
    ^result > 0
        ifTrue: [ ( extString copyFrom: 1 to: result ) asNormalizedString ]
        ifFalse: [ defaultValue ]! 
currentDisk
        "Answer the current default drive
         (0 = A, 1 = B, etc.)."
    ^self current drive asciiValue - $A asciiValue!  
notifyWhenFinalizable: anObject
	"Mark <anObject> so that when it is no longer referenced the message #finalize: will be sent to the receiver with <anObject> as the argument."

	| notifier list |
	notifier := SystemWeakRegistries current notifier.
	(notifier mayBeFinalized: anObject)
		ifFalse: [^self].
	list := notifier at: anObject ifAbsentPut: [ Array new ].
	list := list copyWith: self.
	notifier at: anObject put: list.! 
actionForEvent: eventName
        "Answer the action to evaluate when the event
        named <eventName> is triggered by the receiver."
    ^self eventTable
        at: eventName asSymbol
        ifAbsent: [nil]!
existingSymbolFor: aDBString
        "Answer true if the symbol, corresponding to the argument string already exists"
    | symbol |
    symbol := (super new: aDBString size) initContents: aDBString.
    ^(SymbolTable symbolAt: symbol)
!
directoriesDo: iterationBlock
	"Evaluate the <iterationBlock> once for each directory contained within the receiver. Each directory passed to the iteration block should be released by the iteration block if it is not retained in some way.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated directories."

	self searchResultsDo: [:searchResult |
		searchResult isDirectory
			ifTrue: [iterationBlock value:searchResult entity]]!   
fileName
        "Answer the receiver's file name."
    ^'vvmt', SmalltalkLibrary versionAndPlatformExtension!  
compiledMethodList
	"Private - Answer the list of methods in the code cache."

	| temp |
	temp := VirtualMachineLibrary objectAtAddress: ( 
		( ExternalBuffer atAddress: (
			( VirtualMachineLibrary queryProcAddr: 'ObjectStore' ) + 172 ) ) addressAtOffset: 4 ) asParameter.
	^temp copyFrom: 1 to: ( temp indexOf: nil ) - 1!
binder: aBinder name: aString
	"Signal that aBinder encountered an object named
	aString that already exists in the image."

    ^self binder: aBinder text: aString
!   
messageText
	"Private - Answer a string description of the receiver."

	^'Name already exists: ', messageText! 
name
	"Private - Answer the duplicate name."

	^messageText!   
isResumable
        "Return true if this is a resumable exception."
    ^true!  
privateAt: aSymbol put: aMethod
        "Private - Associate <aMethod> with <aSymbol>.
        Don't use this message: improper usage can cause the system
         to break in non-obvious ways."

    | intState |
    intState := Process enableInterrupts: false.
    super at: aSymbol put: aMethod.
    Process enableInterrupts: intState.
    ^aMethod!  
newFile: aString
	"Answer a FileStream with path name aString."

	^self newFile: aString in: (Directory fromPath: Disk drivePathName)! 
smalltalkLibraryOrdinal
    "Answer the ordinal number of library the receiver is contained in.
    Zero indicates the receiver is not in a library (i.e., it is in the image)."

    ^VirtualMachineLibrary dllNumber: self! 
releaseFlatAddress
        "Release the flat address. Only to be used after creating a
         flat address using ExternalSegmentedAddress>>asFlatAddress
         in Windows 95, when the flat address is no longer needed."
    OperatingSystem isWindows95
        ifTrue: [ ThunkWin95DLL current release32BitAddress: self asInteger ]!
update: aParameter
        "An object on whom the receiver is dependent
         has changed.  The receiver updates its status
         accordingly (the default behavior is to do nothing).
         The argument aParameter usually identifies the
         kind of update."!  
isFloat
        "Answer true if receiver is a kind of Float."
    ^false!   
longDateFormat
        "Answer the current system value for long date format."
    longDateFormat isNil
        ifTrue: [ longDateFormat := self queryNationalProfileString: 'sLongDate' default: nil ].
    longDateFormat isNil
        ifTrue: [ longDateFormat := 'dddd, MMMM dd, yyyy' ]
        ifFalse: [ longDateFormat := longDateFormat copyWithout: $' ].
    ^longDateFormat!  
when: eventName send: selector to: anObject with: firstArgument with: secondArgument
        "Form an action with <anObject> as the receiver,
        a <selector> as the message selector, and the
        <firstArgument> and <secondArgument> as the
        arguments and append it to the actions
        list for the event named <eventName>."
    self
        when: eventName
        send: selector
        to: anObject
        withArguments:
            (Array with: firstArgument with: secondArgument)!
lowerOf: aNumber
        "Answer the number which appears closest to the bottom
         of the screen between the receiver and aNumber."
    ^(self max: aNumber)!
osWarning
        "Create a notification for the warning indicated by the host operating
        system.  Ask the host operating system for the last error that occurred."
    | msg |
    msg := 'OS Warning: ', ( self osErrorMessage: self lastOsError ).
    ^LoggedWarning signal: msg! 
execute: aPathName
        "Execute the file named aPathName (an EXE or PIF file);
         to run a batch file, specify 'command.com /c xxx.bat' "
    | startupInfo processInfo |
    startupInfo := SelfDefinedStructure named: 'STARTUPINFO'.
    startupInfo cb: 68;
        showWindow: 1.
    processInfo := SelfDefinedStructure named: 'PROCESSINFORMATION'.
    ( KernelLibrary
        createProcess: nil
        commandLine: aPathName asParameter
        processSecurity: nil
        threadSecurity: nil
        inheritHandles: false
        createFlags: 0
        environment: nil
        currentDir: nil
        startInfo: startupInfo asParameter
        processInfo: processInfo asParameter )
            ifFalse: [ ^self osError ]!   
close
        "Free the DLL."
    KernelLibrary16 freeLibrary: self.
    self class clearCachedAddresses.
    self == self class currentOrNil ifTrue: [ self class current: nil ]!
isSymbol
        "Answer true if receiver is a kind of Symbol."
    ^false! 
codePage
        "Answer the current code-page identifier."
    codePage isNil ifTrue: [ codePage := 0 ].
    ^codePage!   
initializeAllLowerCase
        "Private - initialize allLowerCase inst var."
    allLowerCase := String new: 255.
    1 to: 255 do: [ :cp |
        allLowerCase at: cp put: ( UserLibrary charLower: cp ) asCharacter ].
    ^allLowerCase! 
remove: aString ifAbsent: aBlock
        "Erase the file named aString; if the file does not exist,
        answer the result of evaluating aBlock."
    | error |
    ( KernelLibrary deleteFile: aString asFileSystemPath asString asParameter ) ifFalse: [
        error := KernelLibrary getLastError.
        (#(2 3 15 18 21) includes: error) "ERROR_FILE_NOT_FOUND, ERROR_PATH_NOT_FOUND, ERROR_INVALID_DRIVE, ERROR_NO_MORE_FILES, ERROR_NOT_READY"
            ifTrue: [ ^aBlock value ]
            ifFalse: [ ^self osError ] ]!  
isMounted
        "Answer whether the receiver is currently mounted."
    ^self class volumes includes: self.
!
creationTime
    "Answer the file's creation date and time stamp."

    | data ct |
    data := self findData.
    ct := data ftCreationTime.
    ^TimeStamp date: ct asDate time: ct asTime!   
fileName
        "Answer the receiver's file name."
    ^'vthk', SmalltalkLibrary versionAndPlatformExtension!  
addr16To32: a16BitAddress
    <api: addr16To32 ulong ulongReturn>
    ^self invalidArgument!
addr32To16: a32BitAddress
    <api: addr32To16 ulong ulongReturn>
    ^self invalidArgument!
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^true!   
nextChunk
        "Answer a String up to '!!!!', undoubling embedded !!!!'s.
         Trailing white space is skipped.  The methods in
         sources.sml and change.log are in chunk format."
    | answer in str |
    answer := super nextChunk.
    self lineDelimiter == Cr ifTrue: [^answer].
    in := ReadStream on: answer.
    answer := WriteStream on: (String new: answer size).
    [in atEnd] whileFalse: [
        str := in upTo: Lf.
        (str at: str size) = Cr
            ifTrue: [str := str copyFrom: 1 to: str size - 1].
        answer nextPutAll: str].
    ^answer contents!  
startupKernel
        "Private - perform OS kernel startup."
    DynamicLinkLibrary startUp.  "note: loads partial USER, since needed even in non-GUI"
    ExternalHeapHandle startUp.
    NationalLanguageSupport startUp. "needed?"
    Disk := Directory current.
    FileHandle startUp!
isLetter: aCharacter
        "Answer true if aCharacter is a letter, else answer false."
    | anInteger |
    anInteger := aCharacter asInteger.
    ( anInteger > 0 and: [ aCharacter ~= DoubleByteSpace ] )
        ifFalse: [ ^false ].
    anInteger < 256
        ifTrue: [ ^( isLetter at: anInteger ) asBoolean ].
    ^true  "All double-byte characters are upper-case letters."!   
language
        "Answer the current system value for language."
    language isNil
        ifTrue: [ language := self queryNationalProfileString: 'sLanguage' default: '' ].
    ^language!  
perform: aSymbol with: anObject
        "Answer the result of sending a binary message to
         the receiver with selector aSymbol and argument
         anObject.  Report an error if the number of arguments
         expected by the selector is not one."
	<primitive: 158>
	^self perform: aSymbol withArguments: ( Array with: anObject )! 
objectProperties
    "Private - Answer the propertyTable for the receiver, or nil if it has no properties."

    ^SystemWeakRegistries current properties at: self ifAbsent: [nil]!
getHandle: aString
        "Private - Answer an instance of the receiver which refers
         to the Dynamic Link Library (16-bit) named aString."
    | answer |
    ( answer := KernelLibrary16 getModuleHandle: aString asParameter ) = 0
        ifTrue: [ ^self osError ].
    ^self fromInteger: answer! 
eventTableCreate
        "Private - answer an empty dictionary for use as an event table."
    ^IdentityDictionary new: 2!  
decimalSeparator
        "Answer the current system value for decimal separator."
    decimalSeparator isNil
        ifTrue: [ decimalSeparator := self queryNationalProfileString: 'sDecimal' default: '.' ].
    ^decimalSeparator! 
fileName
	^'mpr'!
pathNameReadOnly: aString in: aDirectory
        "Answer a read only FileStream for the file named aString
         in aDirectory."

	^(self fromPath: aString in: aDirectory) readStream!
usesBlockClosure
	"Private - Answer true if the receiver uses a BlockClosure.
	This is how we distinguish 'old' methods from 'new' ones."

	^self type > 3!   
isHidden
	"Answer true if the file is hidden."

	^self attributes includes: $h!
removeKey: aSymbol ifAbsent: aBlock
        "Answer aSymbol.  Remove the key/value pair whose key
         equals aSymbol from the receiver.  If such a pair
         is not found, evaluate aBlock (with no arguments)."
        "If the object is a class, prompt for confirmation before deleting."
    | class |
    ( ( class := self at: aSymbol ifAbsent: [ ^aBlock value ] ) isClass and: [ class symbol == aSymbol ] )
        ifTrue: [
            ( SessionModel current isNoGui or: [
            ( ( Smalltalk at: #MessageBox ) confirm: 'Remove class ', class name, '?' ) ] )
                ifTrue: [ class removeFromSystem ].
            ^aSymbol ].
    ^DefinitionInstaller current
        removeKey: aSymbol
        ifAbsent: aBlock
        fromGlobalDictionary: self!
asExternalHandle
        "Answer the receiver as an ExternalHandle."
    ^ExternalHandle fromBytes: self!   
readBuffer: aString atPosition: anInteger
        "Read the page of the receiver file containing
         the position anInteger into aString.
         Answer the number of bytes read."
    | answer |
    answer := self fileId readInto: aString atPosition: anInteger - 1.
    answer < 0 ifTrue: [self error: 'error reading file'].
    ^answer!
asNullTerminatedUnicodeString
        "Private - Answer a Unicode copy of the receiver with NULL termination."
    ^( self asMixedString ) asUnicodeStringNullTerminated: true! 
description
        "Return a textual description of the exception"
    | msg |
    (msg := self messageText) isNil
        ifTrue: [^self defaultDescriptionString]
        ifFalse: 
		["Put error code in all messages for now"
		^msg , '
(error code: ' , self errorCode printString , ')']! 
defaultAction
        "This is the action that is performed if this exception is
        signaled and there is no active handler for it."

    | errorClass |
    errorClass := self class mappingFor: self errorCode.
    errorClass ~~ nil ifTrue: [^errorClass signal].
    "For now this code only applies to FileErrors...probably useful to do this in the long run anyway"
    ^FileError signal: self defaultDescriptionString hostErrorCode: self errorCode! 
defaultDescriptionString
        "Private - this is used to obtain a textual description of the
        exception if an explicit description has not been provided.
        Subclass will frequently override this method."

    ^'OS Error: ', ( self osErrorMessage: self errorCode )! 
errorCode
	"Answer the Integer system error code for the exception"

	^errorCode!  
errorCode: aSystemErrorCode
	"Set the Integer system error code for the exception"

	errorCode := aSystemErrorCode!
asExternalGlobalAddress
        "Answer the receiver as an ExternalGlobalAddress."
    ^ExternalGlobalAddress fromBytes: self!  
addObjectSpace: address size: byteSize library: library externals: externalsArray objects: objectsArray
	<api: AddObjectSpace ulong ulong ulong self self self> 
    ^self invalidArgument! 
open: aString in: aDirectory
        "Open the file named aString in aDirectory with read/write access;
        if the file does not exist, it will be created; answer the file handle."
    ^self
        open: aString
        in: aDirectory
        access: GenericRead | GenericWrite
        share: FileShareRead | FileShareWrite
        create: OpenAlways
        attributes: FileAttributeNormal! 
needsFinalization
    "The receiver needs to be sent the message #finalize when it is no loner referenced."

    | finalizer |
    finalizer := self finalizationRegistry.
    (finalizer mayBeFinalized: self)
        ifFalse: [^self].
    finalizer add: self! 
methodDictionaries
        "Private - answer an ordered list of the receiver's method dictionaries."
    | methodDictionaries mdArray index entry |
    methodDictionaries := OrderedCollection new.
    mdArray := self methodDictionaryArray.
    index := 0.
    [ index < mdArray size ] whileTrue: [
        index := index + 1.
        entry := mdArray at: index.
        entry isArray
            ifTrue: [ mdArray := entry. index := 0 ]
            ifFalse: [ methodDictionaries add: entry ] ].
    ^methodDictionaries!   
revertToClassBehavior
	"Remove all instance specific behavior from the receiver.  To do this, find the class of the receiver, and install its method dictionary array"

	self methodDictionaryArray: self class methodDictionaries

!
file: aString 
        "Answer a FileStream for the file named 
         aString in the current directory.  If the file 
         does not exist, it will be created." 

    ^FileStream on: (File open: aString in: self)!  
unwind
        "Private - Unwind the current process."
    | workProcess |
    workProcess := self copyStack.
    self unwindRecursion: workProcess!  
isExternalHandle
        "Answer whether the receiver is an instance of
        ExternalHandle or one of its subclasses."
    ^false!  
makeDefault
	"Make the receiver be the default directory. Portable file operations use the default directory to resolve relative path names.
		Note: this is independent of any 'current directory' supported by the host."

	self asFileSystemPath isAbsolute
		ifTrue: [Disk := self]
		ifFalse:
    		[FileError
        		signal: self asFileSystemPath asString , ' is not absolute'
        		with: self]! 
isOpen
	"Answer <true> if the receiver is open"

	^(self fileId == nil) not!   
addSharedPool: aSymbol
        "Obsolete - Add the shared pool named aSymbol to
         the receiver shared pool references."

	self superclass
		subclass: self symbol
   		instanceVariableNames: self instanceVariableString
    	classVariableNames: self classVariableString
		poolDictionaries: self sharedVariableString , aSymbol
		isVariable: self isVariable
		isPointers: self isPointers! 
fromPath: path
    "Answer an instance of a subclass of the receiver representing an entity with the given path."

	^path asFileSystemLocator asDirectory! 
default
	"Answer the default directory. Portable file operations use the default directory to resolve relative path names.
		Note: this is independent of any 'current directory' supported by the host."

	^Disk!
fromPath: path in: parentDirectory
    "Answer an instance of a subclass of the receiver representing an entity with the given path. If the path is an absolute path, the parent directory is ignored. If the path is a relative path the path name is assumed to be relative to the parentDirectory."

	^path asFileSystemLocator asDirectoryWithin: parentDirectory! 
drives
        "Answer the pathName strings of all the known drives."
	^FileVolume volumes collect: [ :vol |
		( vol rootDirectory absolutePathString copyFrom: 1 to: 2 ) asLowerCase ]!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
maximumPathLength
    "Answer the maximum length of paths, in characters, including volume, directory and extension separators."

    ^63! 
allocationForSize: anInteger
    "Private"

    ^( super allocationForSize: anInteger ) * 2!   
processIndexFromBPLink: aBPLink
	"Private - Answer a process index from <aBPLink>."

	^aBPLink!
attributes
    "Private - Answer a String containing attribute flags for
    the receiver file. Attributes are: 'r' read only, 'h' hidden, 's' system,
    and 'a' archive.the attributes of the receiver."

    ^self directory attributesForFileNamed: self name!  
fullPathName: fileName
        "Answer the full path name of the file name."

	   ^(self fromPath: fileName in: (Directory fromPath: Disk drivePathName)) absolutePath asString!   
nextFrameAt: frameIndex
        "Private - Answer the process index of the nextFrame entry from
        the stack frame at frameIndex."
    | nextFrame |
    nextFrame := self topFrame.
    0 to: frameIndex do: [:i|
        nextFrame := self nextFrameFrom: nextFrame ].
    ^nextFrame!  
formatted 
        "Answer a collection of arrays of file information 
         for the receiver directory.  Each array has four 
         entries: file name, size, date/time and attributes." 
    ^self formatted: '*.*'!  
hInstanceDLL
        "Private - Answer the module handle of the virtual
        machine DLL."
    ^hInstanceDLL!   
baseDay
        "Private - Answer a constant to reduce (possibly)
         the date instance variable to a SmallInteger."
    ^30300!  
checkDay: dInteger year: yInteger
        "Private - Check the validity of the day number
         dInteger for the year yInteger.  If the date is
         invalid, report the error."
    (dInteger < 1 or: [ dInteger >
        ((self leapYear: yInteger) + 365)])
        ifTrue: [^self errorInDay]!  
nameOfMonth: anInteger
        "Answer the month name as a Symbol corresponding
         to the month index anInteger (January for index
         1, to December for index 12)."
    | aName |
    (anInteger > 12 or: [anInteger < 1])
        ifTrue: [self errorInMonth].
    MonthNames associationsDo: [ :assoc |
        (anInteger = assoc value) ifTrue: [
            aName isNil
                ifTrue: [ aName := assoc key ]
                ifFalse: [
                    ^(aName size > assoc key size)     "answer long name"
                        ifTrue: [ aName ]
                        ifFalse: [ assoc key]]]].
    aName isNil
        ifTrue: [ self errorInMonth]
        ifFalse: [ ^aName ].!
today
        "Answer the current date."
    ^self current! 
fromDays: anInteger
        "Answer a Date that is anInteger number
         of days before or after January 1, 1901
         depending on the sign of anInteger."
    ^self new day: anInteger!  
indexOfMonth: aSymbol
        "Answer a number from 1 to 12 indicating
         the month index for the aSymbol."
    ^self indexOfMonth: aSymbol ifAbsent: [self errorInMonth]!   
shortNameOfMonth: anInteger
        "Answer the short month name as a Symbol corresponding
         to the month index anInteger (Jan for index 1,
         to Dec for index 12)."
    | aName |
    (anInteger > 12 or: [anInteger < 1])
        ifTrue: [self errorInMonth].
    MonthNames associationsDo: [ :assoc |
        (anInteger = assoc value) ifTrue: [
            aName isNil
                ifTrue: [ aName := assoc key ]
                ifFalse: [
                    ^(aName size < assoc key size)     "answer short name"
                        ifTrue: [ aName ]
                        ifFalse: [ assoc key]]]].
    aName isNil
        ifTrue: [ self errorInMonth]
        ifFalse: [ ^aName ].! 
dayOfWeek: aSymbol
        "Answer a number from 1 to 7 indicating the
         weekday number for aSymbol (1 meaning Monday,
         to 7 meaning Sunday)."
    ^DayNames at: aSymbol
        ifAbsent: [ self errorInDay ]!   
replaceDayNames: aDictionary
        "Attempt to replace the class variable that contain
         the associations between the day name and the
         day index. The day name must be a symbol
         and the day index must be between 1 and 7.
         Answer whether successful. "
    aDictionary associationsDo: [ :assoc |
        (assoc key isSymbol and: [assoc value >= 1 and: [assoc value <= 7]])
            ifFalse: [^false]].
    DayNames := aDictionary.
    ^true.!
checkDay: dInteger month: aSymbol year: yInteger
        "Private - Check the validity of the day number
         dInteger for the month aSymbol in the year yInteger.
         If the date is invalid, report the error."
    (dInteger < 1 or: [ dInteger >
        (self daysInMonth: aSymbol forYear: yInteger)])
        ifTrue: [^self errorInDay]!   
nameOfDay: anInteger
        "Answer the weekday name as a Symbol corresponding
         to the weekday index anInteger (Monday for
         index 1, to Sunday for index 7)."
    | aName |
    (anInteger > 7 or: [anInteger < 1])
        ifTrue: [self errorInDay].
    DayNames associationsDo: [ :assoc |
        (anInteger = assoc value) ifTrue: [
            aName isNil
                ifTrue: [ aName := assoc key ]
                ifFalse: [
                    ^(aName size > assoc key size)     "answer long name"
                        ifTrue: [ aName ]
                        ifFalse: [ assoc key]]]].
    aName isNil
        ifTrue: [ self errorInDay ]
        ifFalse: [ ^aName ].!
daysInYear: anInteger
        "Answer the total number of days
         for the year anInteger."
    ^365 + (self leapYear: anInteger)!
errorInDay
        "Private - Report the error that a particular
         method argument, representing a day, is in error."
    ^self error: 'error in day argument'! 
shortNameOfDay: anInteger
        "Answer the short weekday name as a Symbol
         corresponding to the weekday index anInteger
         (Mon for index 1, to Sun for index 7)."
    | aName |
    (anInteger > 7 or: [anInteger < 1])
        ifTrue: [self errorInDay].
    DayNames associationsDo: [ :assoc |
        (anInteger = assoc value) ifTrue: [
            aName isNil
                ifTrue: [ aName := assoc key ]
                ifFalse: [
                    ^(aName size < assoc key size)     "answer short name"
                        ifTrue: [ aName ]
                        ifFalse: [ assoc key]]]].
    aName isNil
        ifTrue: [ self errorInDay ]
        ifFalse: [ ^aName ].!  
errorInMonth
        "Private - Report the error that a particular
         method argument, representing a month, is in error."
    ^self error: 'error in month argument'!   
newDay: dInteger month: aSymbol year: yInteger
        "Answer a Date of the day dInteger in the
         month aSymbol for the year yInteger."
    | daysToMonth index |
    self checkDay: dInteger month: aSymbol year: yInteger.
    index := self indexOfMonth: aSymbol.
    daysToMonth := #(0 31 59 90 120 151 181 212 243 273 304 334)
        at: index.
    (index > 2 and:
        [(self leapYear: yInteger) = 1])
            ifTrue: [daysToMonth := daysToMonth + 1].
    daysToMonth := daysToMonth + dInteger.
    ^self newDay: daysToMonth year: yInteger! 
calendarForMonth: aSymbol year: anInteger
        "Answer a String containing the formatted calendar
         for the month name aSymbol in the year anInteger."
    | aStream index daysInMonth firstDayIndex daysBlank |
    firstDayIndex := (self newDay: 1 month: aSymbol
        year: anInteger) dayIndex.
    aStream := WriteStream on: (String new: 200).
    daysInMonth := self daysInMonth: aSymbol
        forYear: anInteger.
    #(7 1 2 3 4 5 6) do: [ :i |
        aStream nextPutAll: (((self nameOfDay: i) asString) copyFrom: 1 to: 2).
        aStream nextPut: $ ].
    aStream cr.
    daysBlank := firstDayIndex \\ 7.
    index := 1.
    [index <= daysBlank ]
        whileTrue: [
            aStream nextPutAll: '   '.
            index := index + 1].
    1 to: 9 do: [ :i |
        index > 7
            ifTrue: [
                index := 1.
                aStream cr].
        aStream space.
        i printOn: aStream.
        aStream space.
        index := index + 1].
    10 to: daysInMonth do: [ :i |
        index > 7
            ifTrue: [
                index := 1.
                aStream cr].
        i printOn: aStream.
        aStream space.
        index := index + 1].
    ^aStream contents!   
daysInMonth: aSymbol forYear: anInteger
        "Answer the total number of days for the
         month aSymbol in the year yInteger."
    | index |
    (index := self indexOfMonth: aSymbol) = 2
        ifTrue: [ ^28 + (self leapYear: anInteger)].
    ^#(31 28 31 30 31 30 31 31 30 31 30 31)
        at: index! 
fromString: aString
        "Answer a Date specified by aString.  aString
         must represent a date in one of three formats:
         'Jan 2, 1990'  or '2 Jan, 1990' or '02-01-90'
         but the delimiters between the month, day and
         year can be any sequence of non-alphanumeric
         characters."
    | aStream field1 field2 field3 month year |
    aStream := aString asStream.
    field1 := aStream nextWord.
    (DayNames includesKey: field1 asSymbol)
        ifTrue: [field1 := aStream nextWord].
    field2 := aStream nextWord.
    (field2 equalsIgnoreCase:  'of')
        ifTrue: [field2 := aStream nextWord].
    field3 := aStream nextWord.
    year := field3 asInteger.
    year < 100 ifTrue: [year := year + 1900].

    field1 first isLetter                            " 'Jan 2, 1990' format"
        ifTrue: [
            month := self monthNameFromString: field1.
            ^self
                newDay: field2 asInteger
                month: month
                year: year].

    field2 first isLetter                             " '2 Jan, 1990' format"
        ifTrue: [
            month := self monthNameFromString: field2.
            ^self
                newDay: field1 asInteger
                month: month
                year: year].

        "Must be '02-01-90' or 02-01-1990' style"
    (NationalLanguage dateFormat) = NationalLanguageSupport dateFormatMDY
        ifTrue: [
            ^self
                newDay: field2 asInteger
                month: (self nameOfMonth: field1 asInteger)
                year: year]
        ifFalse: [
            (NationalLanguage dateFormat) = NationalLanguageSupport dateFormatDMY
                ifTrue: [
                    ^self
                        newDay: field1 asInteger
                        month: (self nameOfMonth: field2 asInteger)
                        year: year]
                ifFalse: [                                          "dateFormatYMD"
                    year := field1 asInteger.
                    year < 100 ifTrue: [year := year + 1900].
                    ^self
                        newDay: field3 asInteger
                        month: (self nameOfMonth: field2 asInteger)
                        year: year]].!   
monthNameFromString: aString ifAbsent: aBlock
        "Answer a Symbol for a month name corresponding
         to the month name in aString.  Evaluate aBlock
         if there is no such month."
    | aName |
    aName := aString trimBlanks asSymbol.
    MonthNames associationsDo: [ :assoc |
        (assoc key equalsIgnoreCase: aName)
            ifTrue: [ ^assoc key ]].
    ^aBlock value! 
monthNames
        "Answer the class variable that contain
         the associations between the month name
         as symbols and the month indices."
    ^MonthNames.! 
replaceMonthNames: aDictionary
        "Attempt to replace the class variable that contain
         the associations between the month name and the
         month index. The month name must be a symbol
         and the month index must be between 1 and 12.
         Answer whether successful. "
    aDictionary associationsDo: [ :assoc |
        (assoc key isSymbol and: [assoc value >= 1 and: [assoc value <= 12]])
            ifFalse: [^false]].
    MonthNames := aDictionary.
    ^true.!  
dateAndTimeNow
        "Answer an Array of two elements.  The first
         element is a Date representing the current
         date and the second element is a Time
         representing the current time."
    | timestamp |
    timestamp := TimeStamp current.
    ^Array with: timestamp date with: timestamp time!
current
        "Answer the current date."
    ^TimeStamp current date! 
dayNames
        "Answer the class variable that contain
         the associations between the day name
         as symbols and the day indices."
    ^DayNames.! 
leapYear: anInteger
        "Answer 1 if the year anInteger is
         a leap year, else answer 0."
    (anInteger \\ 4 = 0
        and: [anInteger \\ 100 > 0
            or: [anInteger \\ 400 = 0]])
                ifTrue:  [^1]
                ifFalse: [^0]!  
leapYearsTo: anInteger
        "Answer the number of leap years from 1901
         to the year number before anInteger."
    | prior |
    prior := anInteger - 1.
    ^(prior // 4) + (prior // 400) -
        (prior // 100) - 460!   
newDay: dInteger year: yInteger
        "Answer a Date of the day dInteger
         in the year yInteger."
    self checkDay: dInteger year: yInteger.
    ^self new day: yInteger - 1901 *
        365 + (self leapYearsTo: yInteger) + dInteger - 1!   
monthNameFromString: aString
        "Answer a Symbol for a month name corresponding
         to the month name in aString."
    ^self monthNameFromString: aString
        ifAbsent: [self errorInMonth]!
indexOfMonth: aSymbol ifAbsent: aBlock
        "Answer a number from 1 to 12 indicating
         the month index for the aSymbol.  If there
         is no such month, evaluate aBlock."
    ^MonthNames at: aSymbol
        ifAbsent: [aBlock value]!   
printLongOn: aStream
        "Append a string representing the receiver date
         to aStream in the form specified by the current
         system long date format."
    self printOn: aStream
        withPicture: (NationalLanguage longDateFormat)!   
= aDate
        "Answer true if the receiver
         is the same as aDate."
    ^aDate isDate and: [ self day = aDate day ]!  
printOn: aStream
        "Append a string representing the receiver date
         to aStream in the form specified by the current
         system date format."
    self printOn: aStream
        inFormat: NationalLanguage dateFormat
        twoDigitYear: true.!
elapsedDaysSince: aDate
        "Answer the number of elapsed days
         between the receiver and aDate."
    ^self day - aDate day!
daysLeftInYear
        "Answer number of days remaining
         in the receiver year."
    ^self daysInYear - self dayOfYear! 
printOn: aStream inFormat: aFormat twoDigitYear: aBoolean
        "Append a string representing the receiver date
         to aStream in the form specified by aFormat
        and aBoolean."
    self printOn: aStream
        inFormat: aFormat
        twoDigitYear: aBoolean
        dateSeparator: NationalLanguage dateSeparator.!   
> aDate
        "Answer true if the receiver
         is after aDate."
    ^self day > aDate day!  
>= aDate
        "Answer true if the receiver
         is the same or after aDate."
    ^aDate day <= self day!
daysInYear
        "Answer the total number of
         days for the receiver year."
    ^self class daysInYear: self year!
dayOfYear
        "Answer a number from 1 to 366 indicating
         the day within the year of the receiver."
    | anInteger |
    anInteger := self year.
    ^self day - (anInteger - 1901 * 365 +
        (self class leapYearsTo: anInteger)) + 1!
asSeconds
        "Answer the number of seconds that have elapsed
         from January 1, 1901 to the receiver."
    ^self elapsedSecondsSince:
        (self class newDay: 1 year: 1901)!   
daysInMonth
        "Answer the total number of
         days for the receiver month."
    ^self class
        daysInMonth: self monthName
        forYear: self year!   
hash
        "Answer the integer hash
         value for the receiver."
    ^day hash! 
subtractDate: aDate
        "Answer the number of days between
         the receiver and aDate."
    ^self day - aDate day!
addDays: anInteger
        "Answer a Date that is anInteger
         number of days after the receiver."
    ^self class fromDays: self day + anInteger!   
subtractDays: anInteger
        "Answer the date that is anInteger number
         of days before the receiver Date."
    ^self class fromDays: self day - anInteger!  
year
        "Answer the year number of receiver Date."
    | numOfDays n400 r400 n100 r100 n4 r4 n1 temp |
    numOfDays := self day + (1900 * 365 + 460).
        "693960 is the number of days from year 0
         to year 1900 leap year days included"
    temp := 400 * 365 + 97.
    n400 := numOfDays // temp * 400.
    r400 := numOfDays \\ temp min: temp - 2.
    temp := 100 * 365 + 24.
    n100 := r400 // temp * 100.
    r100 := r400 \\ temp.
    n4 := r100 // 1461 * 4.
        "1461 = 4 * 365 + 1"
    r4 := r100 \\ 1461 min: 1459.
    n1 := r4 // 365.
    ^n400 + n100 + n4 + n1 + 1!  
printShortOn: aStream
        "Append a string representing the receiver date
         to aStream in the form specified by the current
         system short date format."
    self printOn: aStream
        withPicture: (NationalLanguage shortDateFormat)!
asDate
        "Answer the receiver as an instance of Date."
    ^self! 
daysLeftInMonth
        "Answer number of days remaining
         in the receiver month."
    | daysToMonth dayNumber index|
    daysToMonth := (self class leapYear: self year) = 0
        ifTrue: [#(31 59 90 120 151 181 212 243 273 304 334 365)]
        ifFalse: [#(31 60 91 121 152 182 213 244 274 305 335 366)].
    dayNumber := self dayOfYear.
    index := 1.
    [dayNumber > (daysToMonth at: index)]
        whileTrue: [index := index + 1].
    ^(daysToMonth at: index) - dayNumber!   
printOn: aStream
  inFormat: aFormat
  twoDigitYear: aBoolean
  dateSeparator: dateSeparatorString
        "Append a string representing the receiver date
         to aStream in the form specified by aFormat
        and aBoolean. Use dateSeparatorString as the
        date separator"
    | field1 field2 field3 year |
    year := self year.
    aBoolean ifTrue: [year := year \\ 100].
    aFormat = NationalLanguageSupport dateFormatMDY
        ifTrue: [
            field1 := self monthIndex.
            field2 := self dayOfMonth.
            field3 := year]
        ifFalse: [
            aFormat = NationalLanguageSupport dateFormatDMY
                ifTrue: [
                    field1 := self dayOfMonth.
                    field2 := self monthIndex.
                    field3 := year]
                ifFalse: [                                "dateFormatYMD"
                    field1 := year.
                    field2 := self monthIndex.
                    field3 := self dayOfMonth ]].
    field1 <= 9 ifTrue: [ aStream nextPut: $0 ].
    field1 printOn: aStream.
    aStream nextPutAll: dateSeparatorString.
    field2 <= 9 ifTrue: [ aStream nextPut: $0 ].
    field2 printOn: aStream.
    aStream nextPutAll: dateSeparatorString.
    field3 <= 9 ifTrue: [ aStream nextPut: $0 ].
    field3 printOn: aStream.! 
isDate
        "Answer whether the receiver is a Date. "
    ^true! 
dayOfMonth
        "Answer a number from 1 to 31 indicating the
         day number within the  month of the receiver."
    ^self dayOfYear - self firstDayInMonth + 1!
elapsedMonthsSince: aDate
        "Answer the number of elapsed months
         between the receiver and aDate."
    ^self year - aDate year * 12 +
        (self monthIndex - aDate monthIndex)! 
elapsedSecondsSince: aDate
        "Answer the number of elapsed seconds
         between the receiver and aDate."
    ^(self subtractDate: aDate) * 86400
        "86400 is the number of seconds in a day"! 
firstDayInMonth
        "Answer the number of the first day in the
         receiver month relative to the beginning
         of the receiver year."
    | index daysToMonth |
    index := self monthIndex.
    daysToMonth :=
        #(1 32 60 91 121 152 182 213 244 274 305 335)
            at: index.
    index > 2
        ifTrue: [
            ^daysToMonth := daysToMonth +
                (self class leapYear: self year)].
    ^daysToMonth!  
firstDayOfMonth
        "Answer a Date representing the
         first day in the receiver month."
    ^self class
        newDay: 1
        month: self monthName
        year: self year! 
previousWeekday: aSymbol
        "Answer a Date reflecting the most recent
         day name represented by aSymbol preceding
         the receiver."
    | dayIndex dayIndexPrev daysToSub |
    dayIndex := self dayIndex.
    dayIndexPrev := self class dayOfWeek: aSymbol.
    daysToSub := dayIndex - dayIndexPrev.
    dayIndex <= dayIndexPrev
        ifTrue: [daysToSub := daysToSub + 7].
    ^self class fromDays: (self day - daysToSub)!  
dayIndex
        "Answer a number from 1 to 7 indicating
         the weekday number of the receiver
         (1 meaning Monday, to 7 meaning Sunday)."
    ^self day + 1 \\ 7 + 1!   
monthIndex
        "Answer a number from 1 to 12 indicating
         the month of the receiver."
    | daysToMonth dayNumber index|
    daysToMonth :=
        #(31 59 90 120 151 181 212 243 273 304 334 365).
    dayNumber := self dayOfYear.
    dayNumber > 59
        ifTrue: [
            dayNumber := dayNumber -
                (self class leapYear: self year)].
    index := 1.
    [dayNumber > (daysToMonth at: index)]
        whileTrue: [index := index + 1].
    ^index!
monthName
        "Answer a Symbol representing the
         month name of the receiver."
    ^self class nameOfMonth: self monthIndex!
printOn: aStream withPicture: aString
        "Private - Append a string representing the receiver date
         to aStream in the form specified by the aString
         date format picture."
    | m d y value length pictureStream |
    m := self monthIndex.
    d := self dayOfMonth.
    y := self year.
    pictureStream := aString asStream.

    [ pictureStream atEnd ] whileFalse: [
        value := pictureStream next.
        (value = $M or: [value = $d or: [value = $y]])
            ifFalse: [ aStream nextPut: value ]
            ifTrue: [
                pictureStream backupOver: value.
                value := pictureStream nextWord.
                length := value size.
                (value at: 1) = $M ifTrue: [
                    length = 1 ifTrue: [ m printOn: aStream ].
                    length = 2 ifTrue: [
                        m <= 9 ifTrue: [ aStream nextPut: $0 ].
                        m printOn: aStream ].
                    length = 3 ifTrue: [
                        (self  class shortNameOfMonth: m) printOn: aStream ].
                    length = 4 ifTrue: [
                        (self  class nameOfMonth: m) printOn: aStream ] ]
                ifFalse: [
                    (value at: 1) = $d ifTrue: [
                        length = 1 ifTrue: [ d printOn: aStream ].
                        length = 2 ifTrue: [
                            d <= 9 ifTrue: [ aStream nextPut: $0 ].
                            d printOn: aStream ].
                        length = 3 ifTrue: [
                            (self  class shortNameOfDay: self dayIndex) printOn: aStream ].
                        length = 4 ifTrue: [
                            (self  class nameOfDay: self dayIndex) printOn: aStream ] ]
                    ifFalse: [
                        (value at: 1) = $y ifTrue: [
                            length = 2
                                ifTrue: [ y \\ 100 printOn: aStream ]
                                ifFalse: [ y printOn: aStream ] ] ].
                ].
            ].
        ].! 
formPrint
        "Answer a string representing the receiver date in
         the form specified by the current system date format."
    ^self printString!
< aDate
        "Answer true if the receiver
         is before aDate."
    ^self day < aDate day! 
<= aDate
        "Answer true if the receiver is
         before or the same as aDate."
    ^self day <= aDate day!
dayName
        "Answer the name of the
         weekday of the receiver."
    ^self class nameOfDay: self dayIndex!   
day
        "Answer the number of days from the
         receiver to January 1, 1901."
    ^day + self class baseDay!  
day: dayCount
        "Private - Set the day instance variable
         of the receiver to dayCount number of
         days.  Answer the receiver."
    day := dayCount - self class baseDay! 
printInFormat: aFormat twoDigitYear: aBoolean
        "Answer a string representing the receiver date in
         the form specified by the aFormat."
    | aStream |
    aStream := WriteStream on: (String new: 8).
    self
        printOn: aStream
        inFormat: aFormat
        twoDigitYear: aBoolean.
    ^aStream contents! 
isCharacter
        "Answer true if receiver is a kind of Character."
    ^false!   
origin: aPoint
        "Obsolete"
        "Change the corner of the receiver nearest the origin
        of the coordinate system to be <aPoint>."
    self topLeft: aPoint!   
isDirectory
        "Answer true if receiver is a kind of Directory."
    ^false!   
timeSeparator
        "Answer the current system value for time separator."
    timeSeparator isNil
        ifTrue: [ timeSeparator := self queryNationalProfileString: 'sTime' default: ':' ].
    ^timeSeparator!   
isDirectoryRelative
    "Answer <true> if the receiver is a directory relative path."

    ^self absolute == #directoryRelative!   
idleLoopNoGui
        "Private - Loop forever, because no other process wants to run."
    [ true ] whileTrue: [ ]! 
removeActionsWithReceiver: anObject forEvent: eventName
        "Remove all actions for the event named <eventName>
        in the receiver's event table which have <anObject>
        as their receiver."
    self
        removeActionsSatisfying: [ :anAction |
            ( anAction respondsTo: #receiver ) and: [ anAction receiver == anObject ] ]
        forEvent: eventName!   
at: aSymbol put: aMethod
        "Private - Answer aMethod.  Enter aSymbol and
         aMethod as a key/value pair in the
         receiver.  Flush the method cache
         in case an old method has changed."

   (aSymbol isSymbol)
        ifFalse: [^self error: 'key must be Symbol'].
    ^DefinitionInstaller current
		at: aSymbol 
		put: aMethod 
		inMethodDictionary: self!
asUnicodeString
        "Private - Answer a Unicode copy of the receiver."
    ^( self asMixedString ) asUnicodeStringNullTerminated: false!
existingEntityNamed: entityName
ifAbsent: exceptionBlock
    "Answer the file system entity representing the entity named <entityName> contained within the receiver. If the name does not define an existing entity within the receiver, answer the result of evaluating the <exceptionBlock>."

    | realName |
    realName := entityName.
    self
        searchResultsDo:
            [:searchResult |
            (realName equalsIgnoreCase: searchResult entityName)
                ifTrue: [^searchResult entity]].
    ^exceptionBlock value
!   
asTime
        "Answer a Time representing the receiver."
    ^Time fromString: self!   
pageSize 
        "Answer the number of bytes 
         in a file page." 

    FilePageSize == nil ifTrue: [FilePageSize := 4096].
	^FilePageSize!   
largeIntegerAtOffset: anInteger put: anIntegerValue
        "Set the 8-byte signed integer at offset <anInteger> in the receiver to <anIntegerValue>.
         Offsets are zero relative."
    | off value low high |
    ( anIntegerValue between: -9223372036854775808 and: 9223372036854775807 )
        ifFalse: [ ^self error: 'LARGE_INTEGER value must be between -9223372036854775808  and +9223372036854775807' ].
    value := ( anIntegerValue positive
        ifTrue: [ anIntegerValue ]
        ifFalse: [ anIntegerValue negated - 1 ] ).
    low := value bitAnd: 16rFFFFFFFF.
    high := value bitShift: -32.
    off := anInteger + 1.
    self contents at: off put: ( low bitAnd: 16rFF ).
    self contents at: off + 1 put: ( ( low bitShift: -8 ) bitAnd: 16rFF ).
    self contents at: off + 2 put: ( ( low bitShift: -16 ) bitAnd: 16rFF ).
    self contents at: off + 3 put: ( low bitShift: -24 ).
    self contents at: off + 4 put: ( high bitAnd: 16rFF ).
    self contents at: off + 5 put: ( ( high bitShift: -8 ) bitAnd: 16rFF ).
    self contents at: off + 6 put: ( ( high bitShift: -16 ) bitAnd: 16rFF ).
    self contents at: off + 7 put: ( ( high bitShift: -24 ) bitAnd: 16rFF ).
    anIntegerValue negative
        ifTrue: [
            0 to: 7 do: [ :i |
                self contents at: off + i
                    put: ( ( self contents at: off + i ) bitXor: 16rFF ) ].
            ].
    ^anIntegerValue!
getDriveType
        "Private - answer the drive type."
    ^KernelLibrary getDriveType: self fileSystemLocator asString!   
dataSeparator
        "Answer the current system value for data or list separator."
    dataSeparator isNil
        ifTrue: [ dataSeparator := self queryNationalProfileString: 'sList' default: ',' ].
    ^dataSeparator!   
indexOfFilenameIn: aString
        "Private - Answer the index of the start of a filename  in aString.
         Answer zero if no filename exists (i.e. the string ends
         with a $\ $/ or $:)."
    | pos |
    pos := aString size.
    [ pos > 0 ]
        whileTrue: [
              ( '/\:' includes: (aString at: pos) )
                    ifTrue: [
                        ( pos = aString size )
                            ifTrue:  [ ^ 0 ]
                            ifFalse: [ ^ pos + 1 ]
                    ].
              pos := pos - 1.
        ].
    ^ 1.!   
maximumBaseNameLength
    "Answer the maximum length of the base portion of a file name."

    ^8! 
byteSize
        "Answer the total space in bytes on the disk
        described by the receiver. If the receiving volume
        cannot be accessed then return zero."
    | path totalClusters freeClusters sectorsPerCluster bytesPerSector |
    path := self asFileSystemPath asString.
    sectorsPerCluster := ExternalLong new.
    bytesPerSector := ExternalLong new.
    freeClusters := ExternalLong new.
    totalClusters := ExternalLong new.

    ( KernelLibrary getDiskFreeSpace: path asParameter
        sectorsPerCluster: sectorsPerCluster asParameter
        bytesPerSector: bytesPerSector asParameter
        freeClusters: freeClusters asParameter
        totalClusters: totalClusters asParameter )
            ifFalse: [ self osError ].

    ^totalClusters asInteger * sectorsPerCluster asInteger * bytesPerSector asInteger!
create
    "Create the entity represented by the receiver."

    self class createFileNamed: self absolutePath asString!   
lengthOfNetworkNameIn: aString
        "Private - Answer the index of the last character of the
         network name in aString (e.g. \\SERVER\ALIAS).  Return
         zero if there is no network name."
    | p |
    ( ( aString size >= 2 ) and: [ ( '/\' includes: aString first) & ('/\' includes: (aString at: 2)) ]  )
        ifFalse: [ ^ 0 ].
    p := self indexOfDirectoryIn: aString startingAt: 2.
    ( p > 0 )
        ifTrue: [ p := self indexOfDirectoryIn: aString startingAt: p ].
    ( p > 0 )
        ifTrue:  [ ^ p - 1 ]
        ifFalse: [ ^ aString size ].!   
character: aCharacter
        "Private - Answer a new instance of the receiver
         which represents aCharacter."
    ^self new
        type: CharacterExternal value: aCharacter asInteger!  
metaMethodDictionaryArray: aMethodDictionaryArray
        "Private - Answer a new instance of the receiver
         which represents aMethodDictionaryArray."
    ^self new
        type: MetaMethodDictionaryArrayExternal value: aMethodDictionaryArray first classField symbol asString!   
true
        "Private - Answer a new instance of the receiver
         which represents true."
    ^self new
        type: TrueExternal value: nil!   
global: anObject
        "Private - Answer a new instance of the receiver
         which represents anObject."

    ^self globalNamed: ( self globalNameSpace keyAtValue: anObject )! 
compiledMethod: aMethod
        "Private - Answer a new instance of the receiver
         which represents the expression aMethod."
    ^self new
        type: CompiledMethodExternal value: aMethod printString!
poolVar: anAssociation in: aPoolName
        "Private - Answer a new instance of the receiver
         which represents anAssociation which is a
         pool variable in aPoolName."
    ^self new
        type: PoolVariableExternal
        value: ( Array with: anAssociation key with: aPoolName asString )!  
class: aClass
        "Private - Answer a new instance of the receiver
         which represents aClass."
    ^self new
        type: GlobalExternal value: aClass name!  
methodDictionary: aMethodDictionary
        "Private - Answer a new instance of the receiver
         which represents aMethodDictionary."
    aMethodDictionary classField isNil ifTrue: [ ^nil ].
    aMethodDictionary classField isMetaClass
        ifTrue: [ ^self metaMethodDictionary: aMethodDictionary ].
    ^self new
        type: MethodDictionaryExternal value: aMethodDictionary classField symbol asString!  
classVar: anAssociation in: aClass
        "Private - Answer a new instance of the receiver
         which represents anAssociation which is a
         class variable inherited by aClass."
    ^self new
        type: ClassVariableExternal
        value: ( Array with: anAssociation key with: aClass symbol asString )!   
symbol: aSymbol
        "Private - Answer a new instance of the receiver
         which represents aSymbol."
    ^self new
        type: SymbolExternal value: aSymbol asString!  
metaMethodDictionary: aMethodDictionary
        "Private - Answer a new instance of the receiver
         which represents aMethodDictionary."
    ^self new
        type: MetaMethodDictionaryExternal value: aMethodDictionary classField symbol asString!  
methodDictionaryArray: aMethodDictionaryArray
        "Private - Answer a new instance of the receiver
         which represents aMethodDictionaryArray."
    aMethodDictionaryArray first classField isMetaClass
        ifTrue: [ ^self metaMethodDictionaryArray: aMethodDictionaryArray ].
    ^self new
        type: MethodDictionaryArrayExternal value: aMethodDictionaryArray first classField symbol asString!
metaClass: aMetaClass
        "Private - Answer a new instance of the receiver
         which represents aMetaClass."
    ^self new
        type: MetaClassExternal value: aMetaClass instanceClass name! 
globalNameSpace
	"Answer the global name space used
	for resolving instances of the receiver."

	^systemDictionary!   
globalNameSpace: aDictionary
	"Set the global name space used
	for resolving instances of the receiver."

	systemDictionary := aDictionary!   
globalAssoc: anAssociation
        "Private - Answer a new instance of the receiver
         which represents anAssociation."

    ^self globalNamed: anAssociation key!  
markedFrame
        "Private - Answer a new instance of the receiver
         which represents the marked frame."
    ^self new
        type: MarkedFrameExternal value: nil! 
standardBlockClosure: anInteger
        "Private - Answer a new instance of the receiver."
    ^self new
        type: StandardBlockClosureExternal value: anInteger!  
expression: aString
        "Private - Answer a new instance of the receiver
         which represents the expression aString."
    ^self new
        type: ExpressionExternal value: aString!
nil
        "Private - Answer a new instance of the receiver
         which represents nil."
    ^self new
        type: NilExternal value: nil!  
createIt: aByteObject
        "Private - Answer a new instance of the receiver
         which represents aByteObject."
    | s |
    s := ( String new: aByteObject size * 2 ) asStream.
    s nextPutAll: aByteObject class name.
    1 to: aByteObject basicSize do: [:i |
        s nextPut: $ ; nextPutAll: ( aByteObject at: i ) printString ].
    ^self new
        type: CreateItExternal value: s contents.!
commonByteArray: anInteger
        "Private - Answer a new instance of the receiver."
    ^self new
        type: CommonByteCodeArrayExternal value: anInteger!
globalNamed: aGlobalName
        "Private - Answer a new instance of the receiver
         which represents the global object named: <aGlobalName>."

    ^self new type: GlobalExternal value: aGlobalName asString! 
assoc: anAssociation
        "Private - Answer a new instance of the receiver
         which represents anAssociation."
    ^self new
        type: AssocExternal value: anAssociation key printString!   
false
        "Private - Answer a new instance of the receiver
         which represents false."
    ^self new
        type: FalseExternal value: nil!
residue
        "Private - Answer a new instance of the receiver
         which represents the residue object."
    ^self new
        type: ResidueExternal value: nil!   
string: aString1 isGreaterThan: aString2
         "Answer true if aString1 is after aString2
         in the current sort sequence, else answer false.
         The comparison is not case sensitive."
    ^(self compareStringi: aString1 withString: aString2) > 0! 
= aDirectory
    "Answer <true> if the receiver and <anObject> are equal. Two objects are equal if they have the same behavior at the current point in time. Objects that are equal at one time may not be equal at some later time.
        Invariants:
        -    Two objects that compare equal must have equal hash values."

    aDirectory isDirectory ifFalse: [ ^false ].
    ^self absolutePathString equalsIgnoreCase: aDirectory absolutePathString!   
setUnwind: twoArgumentBlock
        "Private - evaluate the receiver. If the system attempts to
        return from a method which (indirectly) invoked this one,
        evaluate the <twoArgumentBlock>. The first argument to
        the block is the context for the method being returned from,
        the second is the value being returned from that method.
        Implementation Comments: What will happen if the
        argument block is invoked and does not provide an explicit
        return is intentionally undefined."
    ^self valueMarked!
endSearch: aSearchResult
        "Private - close the opened search handle,
         in order to free it."

    ( KernelLibrary findClose: aSearchResult searchHandle )
        ifFalse: [ self osNotification ]!
drive 
        "Answer the disk drive letter of the receiver." 

    ^self fileSystemLocator drive first!  
higherOf: aNumber
        "Answer the number which appears closest to the top
         of the screen between the receiver and aNumber."
    ^(self min: aNumber)!  
isTime
        "Answer whether the receiver is a Time. "
    ^false!
directory
        "Answer the directory over which the receiver iterates."
	^directory! 
isFile
	"Answer true if the search resulted in finding a file"

	 ^self isDirectory not!   
isInteresting
    "exclude the directories '.' and '..'"

    ^(self isDirectory and: [self entityName last = $.]) not
!  
searchHandle
        "Answer the host-specific search handle for the last search request."
	^searchHandle!  
directory: aDirectory
searchHandle: aSearchHandle
findData: aFindData
        "Initialize the receiver based on the specified attributes."
	directory := aDirectory.
	searchHandle := aSearchHandle.
	findData := aFindData.!   
entity
        "Answer the entity which was encountered in the last search request
        (find first, find next)."
	^(self isDirectory
		ifTrue: [Directory]
		ifFalse: [File]) fromPath: (self directory absolutePath , self entityName)! 
findData
        "Answer the findData host-specific structure for the last search
        request (find first, find next)."
	^findData!
findData: aFindData
        "Set the host-specific findData structure to aFindData."
	findData := aFindData!
entityNameIndex
    "Answer the index of the name of the entity represented by the receiver."

    | comp idx name |
    comp := self components.
    idx := comp size.
    [idx > 0] whileTrue:
        [name := comp at: idx.
        name = '.'
            ifTrue: [idx := idx - 1]
            ifFalse: [name = '..'
                ifTrue: [idx := idx - 2]
                ifFalse: [^idx]]].
    ^0!
leftBottom: leftBottomPoint rightTop: rightTopPoint
        "Answer a Rectangle with leftBottom and rightTop points
         described by leftBottomPoint and rightTopPoint."
    ^self new leftBottom: leftBottomPoint rightTop: rightTopPoint!   
leftTop: leftTopPoint rightBottom: rightBottomPoint
        "Answer a Rectangle with leftTop and rightBottom points
         described by leftTopPoint and rightBottomPoint."
    ^self new leftTop: leftTopPoint rightBottom: rightBottomPoint!   
leftBottom: leftBottomPoint extent: extentPoint
        "Answer a Rectangle whose leftBottom and
         extent (width and height) are
         described by leftBottomPoint and
         extentPoint."
    ^self new leftBottom: leftBottomPoint extent: extentPoint!  
leftTop: leftTopPoint extent: extentPoint
        "Answer a Rectangle whose leftTop and
         extent (width and height) are
         described by leftTopPoint and
         extentPoint."
    ^self new leftTop: leftTopPoint extent: extentPoint!
origin: originPoint extent: extentPoint
        "Answer a Rectangle whose origin and
         extent (width and height) are
         described by originPoint and
         extentPoint."
    ^self new origin: originPoint extent: extentPoint!  
origin: originPoint corner: cornerPoint
        "Answer a Rectangle with origin and corner points
         described by originPoint and cornerPoint."
    ^self new origin: originPoint corner: cornerPoint!   
= aRectangle
        "Answer true if leftTop and rightBottom Point of the
         receiver are equal to the leftTop and rightBottom
         coordinates of aRectangle, respectively, else
         answer false."
    ^aRectangle isRectangle
        and: [leftTop = aRectangle leftTop
            and: [rightBottom = aRectangle rightBottom]]!   
asRectangle
        "Answer the receiver."
    ^self!   
rightTop
        "Answer the right top Point."
    ^self right @ self top!  
asParameter
        "Answer the receiver in a form suitable for passing
        as a parameter to a host system procedure call."
    ^self asRectangleParameter!   
merge: aRectangle
        "Answer a Rectangle representing the area in
         which the receiver and aRectangle merged together."
    aRectangle isNil ifTrue: [^self].
    ^(leftTop leftMostAndHighest: aRectangle leftTop)
        rightBottom: (rightBottom rightMostAndLowest: aRectangle rightBottom)!   
contains: rectangle
        "Answer <true> if the <rectangle> lies completely
        within or on the edge of the receiver."
    ^(self left isLeftEqualOf: rectangle left)
        and: [(rectangle right isLeftEqualOf: self right)
        and: [(self bottom isBelowEqual: rectangle bottom)
        and: [rectangle top isBelowEqual: self top]]]!
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    leftTop printOn: aStream.
    aStream nextPutAll: ' rightBottom: '.
    rightBottom printOn: aStream!
isRectangle
        "Answer true if receiver is a kind of Rectangle."
    ^true!
width
        "Answer a number representing the receiver width."
    ^(rightBottom x - leftTop x) abs!  
width: anInteger
        "Change the receiver width to anInteger."
    rightBottom x: (leftTop x right: anInteger)! 
height
        "Answer a number representing
         the receiver height."
    ^(leftTop y - rightBottom y) abs!  
insetBy: delta
        "Answer a Rectangle which is the receiver
         inset by delta, where delta is a Rectangle,
         a Point or a Number."
    delta isRectangle
        ifTrue: [
            ^(leftTop rightAndDown: delta leftTop)
                rightBottom: (rightBottom leftAndUp: delta rightBottom)]
        ifFalse: [
            ^(leftTop rightAndDown: delta)
                rightBottom: (rightBottom leftAndUp: delta)]!
scaleTo: aRectangle
        "Answer a Rectangle whose size is
         proportional to the receiver with
         ratios specified by aRectangle."
    ^(aRectangle scaleBy: self extent) truncated
        moveBy: self origin! 
extent
        "Answer a Point representing the
         receiver width and height."
    ^self width @ self height!
origin: originPoint extent: extentPoint
        "Change the receiver's top left corner to
         originPoint and its extent to extentPoint."
    self
        origin: originPoint
        corner: originPoint + extentPoint!   
extent: aPoint
        "Change the extent of receiver to aPoint."
    self width: aPoint x.
    self height: aPoint y! 
mapToScreen: aWindow
        "Answer a rectangle which is the receiver converted from
         client-area coordinates to screen coordinates."
    ^self mapClientToScreen: aWindow!   
hash
        "Private - answer the integer hash of the receiver."
    ^leftTop hash bitXor: rightBottom hash!   
mapClientToScreen: aWindow
        "Answer a rectangle which is the receiver converted from
         client-area coordinates to screen coordinates."
    ^(leftTop mapClientToScreen: aWindow)
        rightBottom: (rightBottom mapClientToScreen: aWindow)! 
rightCenter
        "Answer a point whose coordinates are the same
        as the center of the right edge of the receiver."
    ^self right @ self center y!  
leftBottom: leftBottomPoint rightTop: rightTopPoint
        "Change the receiver to match leftBottomPoint
        and rightTopPoint."
    leftTop := leftBottomPoint x @ rightTopPoint y.
    rightBottom := rightTopPoint x @ leftBottomPoint y.!
moveBy: aPoint
        "Private- Increment the receiver origin
         and corner by aPoint."
    leftTop := leftTop + aPoint.
    rightBottom := rightBottom + aPoint!  
bottom
        "Answer the y-coordinate of
         the bottom of the receiver."
    ^rightBottom y!   
moveTo: aPoint
        "Move the receiver to aPoint."
    self moveBy: (aPoint - leftTop)"abs "!
left: xCoordinate
        "Change the left edge of the receiver to the
        given <xCoordinate>."
    self topLeft: xCoordinate @ self topLeft y!   
topCenter
        "Answer a point whose coordinates are the same
        as the center of the top edge of the receiver."
    ^self center x @ self top!
top
        "Answer the y-coordinate of
         the top side."
    ^leftTop y!
mapFromWindow: fromWindow to: toWindow
        "Answer a rectangle which is the receiver converted from
         one window coordinate to another."
    ^(self mapToScreen: fromWindow) mapToWindow: toWindow! 
top: yCoordinate
        "Change the top edge of the receiver to be the
        given <yCoordinate>."
    self topLeft: self topLeft x @ yCoordinate!  
scaleBy: delta
        "Answer a Rectangle with the receiver
         origin and corner multiplied by delta,
         where delta is either a Number or a Point."
    ^leftTop * delta
        rightBottom: rightBottom * delta! 
translateBy: delta
        "Answer a Rectangle which is the receiver with
         position incremented by delta, where delta is
         either a Number or a Point."
    ^( leftTop + delta ) rightBottom: ( rightBottom + delta )! 
bottomLeft: aPoint
        "Change the bottom-left corner of the receiver
        to be <aPoint>."
    self topLeft: aPoint x @ self topLeft y.
    self bottomRight: self bottomRight x @ aPoint y!  
topRight: aPoint
        "Change the top-right corner of the receiver to be <aPoint>."
    self topLeft: self topLeft x @ aPoint y.
    self bottomRight: aPoint x @ self bottomRight y!   
mapToWindow: aWindow
        "Answer a rectangle which is the receiver converted from
         screen-relative coordinates to aWindow-relative coordinates."
    ^self mapScreenToClient: aWindow! 
corner: aPoint
        "Change the receiver so that its corner is aPoint
        without changing its extent."
    self moveBy: aPoint - self corner!  
leftTop
        "Answer the left top Point."
    ^leftTop!  
expandBy: delta
        "Answer a Rectangle which is the receiver expanded
         by delta, where delta is a Rectangle, a Point or
         a Number."
    delta isRectangle
        ifTrue: [
            ^(leftTop leftAndUp: delta leftTop)
                rightBottom: (rightBottom rightAndDown: delta rightBottom)]
        ifFalse: [
            ^(leftTop leftAndUp: delta)
                rightBottom: (rightBottom rightAndDown: delta)]!
leftTop: aPoint
        "Set the left top point to aPoint."
    leftTop := aPoint!  
topRight
        "Answer a point whose coordinates are the same
        as the top-right corner of the receiver."
    ^self right @ self top!  
truncated
        "Answer the receiver with the coordinates of
         its origin and corner truncated to integers."
    leftTop := leftTop truncated.
    rightBottom := rightBottom truncated.
    ^self! 
leftBottom: leftBottomPoint
        "Change the receiver's left bottom to leftBottomPoint."
    leftTop := leftBottomPoint x @ self top.
    rightBottom := self right @ leftBottomPoint y.!   
leftCenter
        "Answer a point whose coordinates are the same
        as the center of the left edge of the receiver."
    ^self left @ self center y! 
rightBottom
        "Answer the Point of the right bottom corner."
    ^rightBottom!
rightBottom: aPoint
        "Set the right bottom corner to aPoint."
    rightBottom := aPoint! 
right
        "Answer the x-coordinate of the
         receiver's right side."
    ^rightBottom x! 
right: xCoordinate
        "Change the right edge of the receiver to be the
        given <xCoordinate>."
    self bottomRight: xCoordinate @ self bottomRight y!  
bottom: yCoordinate
        "Change the receiver so that the bottom edge is at the
        given <yCoordinate>."
    self bottomRight: self bottomRight x @ yCoordinate
! 
areasOutside: aRectangle
        "Answer a collection of rectangles representing the
        regions of the receiver that do not intersect with
        <aRectangle>."
    | areas |
    (self intersects: aRectangle)
        ifFalse: [^Array with: self].
    ((aRectangle containsPoint: self topLeft) and: [aRectangle containsPoint: self bottomRight])
        ifTrue: [^#()].
    areas := OrderedCollection new: 4.
    (aRectangle top isBelow: self top)
        ifTrue: [areas add: (self topLeft rightBottom: self right @ aRectangle top)].
    (aRectangle bottom isAbove: self bottom)
        ifTrue: [areas add: (self left @ aRectangle bottom rightBottom: self bottomRight)].
    (aRectangle left isRightOf: self left)
        ifTrue: [areas add: (self left @ (self top lowerOf: aRectangle top) rightBottom: aRectangle left @ (self bottom higherOf: aRectangle bottom))].
    (aRectangle right isLeftOf: self right)
        ifTrue: [areas add: (aRectangle right @ (self top lowerOf: aRectangle top) rightBottom: self right @ (self bottom higherOf: aRectangle bottom))].
    ^areas! 
bottomRight
        "Answer a point whose coordinates are the same
        as the bottom-right corner of the receiver."
    ^rightBottom!  
bottomRight: aPoint
        "Set the bottom right corner to be <aPoint>."
    rightBottom := aPoint!
intersects: aRectangle
        "Answer true if the receiver and aRectangle have
         any area in common, else answer false."
    ^(leftTop isLeftAndAbove: aRectangle rightBottom)
        and: [aRectangle leftTop isLeftAndAbove: rightBottom]! 
nonIntersections: aRectangle
        "Answer an OrderedCollection of
         rectangles describing areas of
         the receiver outside aRectangle."
    | areas |
    (self intersects: aRectangle)
        ifFalse: [^Array with: self].
    ((aRectangle containsPoint: leftTop)
        and: [aRectangle containsPoint: rightBottom])
            ifTrue: [ ^#() ].
    areas := OrderedCollection new: 4.
    (aRectangle top isBelow: self top)
        ifTrue: [ areas add:
            (leftTop rightBottom: (rightBottom x @ aRectangle top))].
    (aRectangle bottom isAbove: self bottom)
        ifTrue: [ areas add:
            (leftTop x @ aRectangle bottom rightBottom: rightBottom)].
    (aRectangle left isRightOf: self left)
        ifTrue: [ areas add:
            ((leftTop x @ (leftTop y lowerOf: aRectangle top))
                rightBottom:
                    (aRectangle left
                        @ (rightBottom y higherOf: aRectangle bottom)))].
    (aRectangle right isLeftOf: self right)
        ifTrue: [ areas add:
            ((aRectangle right @ (leftTop y lowerOf: aRectangle top))
                rightBottom:
                    (rightBottom x
                        @ (rightBottom y higherOf: aRectangle bottom)))].
    ^areas! 
containsPoint: aPoint
        "Answer true if aPoint is contained within
         the receiver, else answer false."
    ^( self left isLeftEqualOf: aPoint x )
        and: [ ( aPoint x isLeftOf: self right )
        and: [ ( self bottom isBelow: aPoint y )
        and: [ aPoint y isBelowEqual: self top ] ] ]!  
deviceToLogical: aPen
        "Answer a new Rectangle which is the receiver mapped from device
         to logical units."
    ^self class
        leftTop: ( leftTop deviceToLogical: aPen )
        rightBottom: ( rightBottom deviceToLogical: aPen )!
left
        "Answer the x-coordinate of the left side."
    ^leftTop x!
leftTop: leftTopPoint rightBottom: rightBottomPoint
        "Change the receiver's top left corner to
         leftTopPoint and its bottom right corner to
         rightBottomPoint."
    leftTop := leftTopPoint.
    rightBottom := rightBottomPoint.!
rightTop: rightTopPoint
        "Change the receiver's right top to rightTopPoint."
    leftTop := self left @ rightTopPoint y.
    rightBottom := rightTopPoint x @ self bottom!  
leftBottom
        "Answer the Point of the left bottom corner."
    ^self left @ self bottom!  
mapScreenToClient: aWindow
        "Answer a rectangle which is the receiver converted from
         screen-relative coordinates to aWindow-relative coordinates."
    ^(leftTop mapScreenToClient: aWindow)
        rightBottom: (rightBottom mapScreenToClient: aWindow)!   
bottomCenter
        "Answer a point whose coordinates are the same
        as the center of the bottom edge of the receiver."
    ^self center x @ self bottom!   
topLeft
        "Answer a point whose coordinates are the same
        as the top-left corner of the receiver."
    ^leftTop!  
leftBottom: leftBottomPoint extent: extentPoint
        "Change the receiver to match leftBottomPoint and extent."
    self
        leftTop: (leftBottomPoint up: extentPoint y)
        rightBottom: (leftBottomPoint right: extentPoint x).!
topLeft: aPoint
        "Set the top left corner to be <aPoint>."
    leftTop := aPoint!
rounded
        "Answer the receiver with the coordinates of
         its origin and corner rounded to integers."
    leftTop := leftTop rounded.
    rightBottom := rightBottom rounded.
    ^self! 
center
        "Answer a Point, the
         center of the receiver."
    ^(leftTop + rightBottom) // 2!   
intersect: aRectangle
        "Answer a Rectangle representing the area in
         which the receiver and aRectangle overlap."
    aRectangle isNil ifTrue: [ ^self ].
    ^(leftTop rightMostAndLowest: aRectangle leftTop)
        rightBottom: (rightBottom leftMostAndHighest: aRectangle rightBottom)! 
leftTop: leftTopPoint extent: extentPoint
        "Change the receiver's top left corner to
         leftTopPoint and its extent to extentPoint."
    self
        leftTop: leftTopPoint
        rightBottom: (leftTopPoint rightAndDown: extentPoint).! 
area
        "Answer the area of the receiver in square units."
    ^self height * self width!  
bottomLeft
        "Answer a point whose coordinates are the same
        as the bottom-left corner of the receiver."
    ^self left @ self bottom!
compareStringi: aString1 withString: aString2
        "Answer a constant representing the result of comparing 
         two strings. The comparison is case-insensitive.
         Answer < 0 if aString1 is less than aString2
                      = 0 if aString1 is identical to aString2
                      > 0 if aString1 is greater than aString2."
    ^KernelLibrary
        lStrCmpi: aString1 asParameter
        withString: aString2 asParameter!
asParameter
        "Answer the receiver in a form suitable for passing as
         a parameter to a host procedure call."
    ^0! 
eqv: aBoolean
        "Answer true if the receiver is equivalent
         to aBoolean, else answer false."
    ^aBoolean not!  
not
        "Answer true if the receiver is false,
         else answer false."
    ^true! 
| aBoolean
        "Answer true if either the receiver or
         aBoolean are true, else answer false."
    ^aBoolean!   
ifTrue: trueBlock ifFalse: falseBlock
        "If the receiver is true, answer the result of
         evaluating trueBlock, else answer the result
         of evaluating falseBlock.  Both block are
         evaluated with no arguments."
    ^falseBlock value!  
basicHash
        "Private - answer the hash value of false."
    ^0!   
ifFalse: falseBlock ifTrue: trueBlock
        "If the receiver is true, answer the result of
         evaluating trueBlock, else answer the result
         of evaluating falseBlock.  Both blocks are
         evaluated with no arguments."
    ^falseBlock value! 
ifTrue: aBlock
        "If the receiver is true, answer the result of
         evaluating aBlock (with no arguments), else
         answer nil."
    ^nil!
xor: aBoolean
        "Answer true if the receiver is not equivalent
         to aBoolean, else answer false."
    ^aBoolean!  
or: aBlock
        "If the receiver is false, answer the result of
         evaluating aBlock (with no arguments), else
         answer true."
    ^aBlock value! 
and: aBlock
        "If the receiver is true, answer the result of
         evaluating aBlock (with no arguments), else
         answer false."
    ^false!   
hash
        "Answer the hash of false."
    ^0!
ifFalse: aBlock
        "If the receiver is true, answer the result of
         evaluating aBlock (with no arguments), else
         answer nil."
    ^aBlock value!  
& aBoolean
        "Answer true if both the receiver and
         aBoolean are true, else answer false."
    ^false!   
privateAdd: anAssociation
        "Answer anAssociation.  Add anAssociation to receiver.
		Don't use this message: improper usage can cause the system
		 to break in non-obvious ways."

    ^super add: anAssociation! 
fullDirName
        "Private - Answer a String representing the path
         name of the receiver directory (including drive
        letter). There is always a \ at end."

	| str |
	str := self absolutePath asString.
	str last = $\
		ifFalse: [str := str , '\'].
	^str!   
directoryNamesDo: iterationBlock
    "Evaluate the <iterationBlock> once with the name of each directory contained within the receiver.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated directories."

	self searchResultsDo: [:searchResult |
		searchResult isDirectory
			ifTrue: [iterationBlock value:searchResult entityName]]!  
aboutToSaveImage
	"Private - If necessary, save the receiver's value so it can be restored
	when the image is restarted. Default is do nothing."

	^self! 
isExternalAddress
        "Answer whether the receiver is an instance of class
         ExternalAddress or one of its subclasses."
    ^false! 
objectEventTable
    "Private - Answer the eventTable for the receiver, or nil if it has none."

    ^SystemWeakRegistries current events at: self ifAbsent: [nil]!
initialize
        "Private - Initialize the receiver."
    self initializeIsLetterIsDigit.
    self initCountryInfo.
    self initCollateTable.
    self setDBCSInfo.
    self changed  "notify event handlers on self"!   
execute: aCompiledMethod for: anObject
        "Private - evaluate aCompiledMethod using anObject as the
        message receiver."
    | message |
    message := self new.
    message receiver: anObject.
    message method: aCompiledMethod.
    ^message evaluate!   
receiver
        "Private - answer the receiver of the method."
    ^receiver!  
receiver: anObject
        "Private - set the receiver of the method to anObject."
    receiver := anObject!
evaluate
        "Private- evaluate the receiver"
    | class result |
    class := self receiver class.
    method classField: class.
    method selector: #Doit.
    class addSelector: #Doit withMethod: method.
    [ result := self receiver Doit ]
        ensure: [ class removeSelector: #Doit ].
    ^result!   
method: aCompiledMethod
        "Private - set the method instance variable to aCompiledMethod."
    method := aCompiledMethod! 
methodClass
        "Private - answer the class of the receiver's method."
    ^method classField!  
initStandardTemplates
    "Set up an array of the most common BlockClosure templates which are used to save space."
    standardTemplates := Array new: 40.

    standardTemplates
        at: 1 put: ( self fromArray: #(  268435456  0));
        at: 2 put: ( self fromArray: #(  268435456  2048  nil  402653184));
        at: 3 put: ( self fromArray: #(  268435456  2048));
        at: 4 put: ( self fromArray: #(  268435456  0  134217728  402653184));
        at: 5 put: ( self fromArray: #(  268435456  0  134217728));
        at: 6 put: ( self fromArray: #(  268435456  1));
        at: 7 put: ( self fromArray: #(  268435456  0  nil  402653184));
        at: 8 put: ( self fromArray: #(  268435456  0  134217728  402653184  536870913));
        at: 9 put: ( self fromArray: #(  268435456  2048  134217728));
        at: 10 put: ( self fromArray: #(  268435456  2048  134217728  402653184));
        at: 11 put: ( self fromArray: #(  268435456  2048  nil  nil  536870913));
        at: 12 put: ( self fromArray: #(  268435456  1  134217728));
        at: 13 put: ( self fromArray: #(  268435456  1  nil  402653184));
        at: 14 put: ( self fromArray: #(  268435456  0  134217728  nil  536870913));
        at: 15 put: ( self fromArray: #(  268435456  2  134217728  671088644));
        at: 16 put: ( self fromArray: #(  268435456  2048  nil  402653184  536870913));
        at: 17 put: ( self fromArray: #(  268435456  2049));
        at: 18 put: ( self fromArray: #(  268435456  2049  nil  402653184));
        at: 19 put: ( self fromArray: #(  268435456  2049  134217728));
        at: 20 put: ( self fromArray: #(  268435456  1  134217728  402653184));
        at: 21 put: ( self fromArray: #(  268435456  2049  134217728  402653184));
        at: 22 put: ( self fromArray: #(  268435456  1  134217728  671088644));
        at: 23 put: ( self fromArray: #(  268435456  2048  134217728  402653184  536870913));
        at: 24 put: ( self fromArray: #(  268435456  0  nil  402653184  536870913));
        at: 25 put: ( self fromArray: #(  268435456  2050));
        at: 26 put: ( self fromArray: #(  268435456  2));
        at: 27 put: ( self fromArray: #(  268435456  0  nil  nil  536870913));
        at: 28 put: ( self fromArray: #(  268435456  2050  134217728  402653184));
        at: 29 put: ( self fromArray: #(  268435456  2050  nil  402653184));
        at: 30 put: ( self fromArray: #(  268435456  0  134217728  402653184  536870913  536870914));
        at: 31 put: ( self fromArray: #(  268435456  2050  134217728));
        at: 32 put: ( self fromArray: #(  268435456  2049  nil  671088644));
        at: 33 put: ( self fromArray: #(  268435456  2051  nil  402653184));
        at: 34 put: ( self fromArray: #(  268435456  1  nil  671088644));
        at: 35 put: ( self fromArray: #(  268435456  0  134217728  402653184  536870914  536870913));
        at: 36 put: ( self fromArray: #(  268435456  1  134217728  nil  536870913));
        at: 37 put: ( self fromArray: #(  268435456  2048  134217728  nil  536870913));
        at: 38 put: ( self fromArray: #(  268435456  1  134217728  671088644  671088645));
        at: 39 put: ( self fromArray: #(  268435456  0  134217728  nil  536870913  536870914));
        at: 40 put: ( self fromArray: #(  268435456  1  nil  nil  536870913));
        yourself.
! 
fromArray: anArray
        "Private - answer an instance of the receiver class, whose indexed instance
        variables are filled with the indexed instance variables of anArray."
    | result |
    result := self new: anArray size.
    result initFromArray: anArray.
    ^result!   
isActivationVisibleForInstanceSelector: aSymbol
	"Return true if activation of the argument symbol sent as a message to instances of this class should be visible in the debugger. Only selected message to instance of Context are normally invisible"

   ^#invisibleEnsure: ~~ aSymbol! 
standardTemplates
        "Private - answer an Array of commonly used BlockClosure
        instances which are shared among multiple methods."
    ^standardTemplates! 
initialize

    "  BlockClosure initialize   "

    self initStandardTemplates!   
frameBiasDelta: anInteger
	"Private - Change the frameBias by <anInteger> slots."

	self frameBias: self frameBias + anInteger!
isPoint
        "Answer true if receiver is a kind of Point."
    ^false!   
privateAdd: aSymbol
        "Private - Add a Symbol using
         Set add during growing."
    ^super add: aSymbol!   
bucketClass
    "Answer the class of hash table buckets the receiver uses."

    ^WeakLinearHashTable! 
species
    "Private"
    "Answer class Set as the species of SymbolTable."

    ^Set  !  
symbolAt: aSymbol
        "Private-  Answer the symbol in the receiver corresponding to
        <aSymbol>, or <nil> if none."

    ^self contents lookUpKey: aSymbol for: self!   
add: aSymbol
    "Add <aSymbol> to the receiver if the receiver does not already contain it."

    Symbol mustBeSymbol: aSymbol.
    ^super add: aSymbol! 
computeHash: object
        "Answer the hash value of object."
    ^object basicHash!   
newContents: alloc
    "Private"
    "Answer the collection used to hold the contents of the receiver when the receiver needs <alloc> slots."

    ^BucketHashTable new: alloc  "vm depends on this class"!   
asArray
        "Answer an Array containing all
         the elements of the receiver."
   ^self asOrderedCollection asArray!  
compare: key candidate: candidate
    "Answer true if <key> and <candidate> satisfy the comparison test for the receiver."

    ^key equals: candidate!
atKey: key put: element for: client
    "Add element to the receiver if it is not already present.  Answer nil if element was added,
    otherwise answer the existing object. The client is responsible for computing hash values,
    extracting the key of an element, and comparing candidates."

    | index found bucket |
    index := self computeBucketIndex: key for: client.
    ( bucket := self at: index ) == nil
        ifTrue:
    [ bucket := client bucketClass new: self initialBucketSize.
          self at: index put: bucket.
          self at: index - 1 put: 0.
    ].

    ( found := bucket atKey: key put: element for: client ) == nil
        ifTrue: [ self incrementBucketAt: index for: client ].
    ^found!  
lookUpValue: key for: client ifAbsent: exceptionBlock
    "Answer the value associated with <key> if it is present in the receiver, otherwise the result of the <exceptionBlock>. The <client> is responsible for computing hash values."

    | bucket |
    ^(bucket := self at: (self computeBucketIndex: key for: client)) == nil
        ifTrue: [exceptionBlock value]
        ifFalse: [bucket lookUpValue: key for: client ifAbsent: exceptionBlock]!   
privateAtKey: key
put: element
for: client
	"Add a new <element> to the receiver, assuming that the element is a valid element and that it is not already in the receiver. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

	^self
			atKey: key
			put: element
			for: client!  
bucketCapacityExceeded: bucketIndex
		"Answer true if bucket exceeds a fixed load factor."

	^(self at: bucketIndex) loadFactorExceeded: (self at: bucketIndex - 1)!   
initialBucketSize
    "Private - Answer the initial size of a hash bucket."

    ^1!   
removeKey: key for: client ifAbsent: exceptionBlock
		"Remove an element whose key is key from the receiver. If the receiver 
		does not contain a key equal to the key to be removed, return the result 
		of evaluating the exceptionBlock. The client is responsible for computing 
		hash values, extracting the key of an element, and comparing candidates."

	| bucket index |
	( bucket := self at: ( index := self computeBucketIndex: key for: client ) ) == nil
		ifTrue:
			[ ^exceptionBlock value ]
		ifFalse:
			[ bucket
					removeKey: key
					for: client
					ifAbsent: exceptionBlock.
			self decrementBucketAt: index for: client
			]!   
lookUpValue: key for: client
    "Answer the value associated with <key>, or signal an error if not present. The <client> is responsible for computing hash values."

    | bucket |
    ^(bucket := self at: (self computeBucketIndex: key for: client)) == nil
        ifTrue: [client errorAbsentKey]
        ifFalse: [bucket lookUpValue: key for: client]!
keysAndValuesDo: iterationBlock
		"Evaluate the iterationBlock once for each key/value pair in the receiver. 
		The key will be the first argument, the value will be the second argument 
		to the block."

	| bucket |
	1 to: self size // 2
		do:
			[ :index |
			( bucket := self at: index * 2 ) == nil
				ifFalse: [ bucket keysAndValuesDo: iterationBlock ]
			]!
loadFactorExceeded: count
        "Answer true if (count / self size) exceeds a fixed load factor."
        "Implementation note: this forumla is related to the one in other
        implementors of the message, and in Set>>allocationForSize:."

    ^ count >= (self size * self class targetBucketSize * 2)!   
computeBucketIndex: element for: client
		"Private- Answer the index of the bucket that holds element. The client is responsible 
		for computing hash values."

    ^( ( client computeHash: element ) \\ ( self size // 2 ) + 1 ) * 2!  
decrementBucketAt: index for: client
        "Private - decrement the count of elements in bucket # index."
    | countIndex |
    countIndex := index - 1.
    self at: countIndex put: ((self at: countIndex) - 1).!
lookUpKey: key for: client
    "Answer the association whose key is <key> if it is present in the receiver, otherwise nil. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    | bucket |
    ^(bucket := self at: (self computeBucketIndex: key for: client)) == nil
        ifTrue: [nil]
        ifFalse: [bucket lookUpKey: key for: client]!  
growBucketAt: bucketIndex for: client
    "Private - Make bucket at <bucketIndex> larger. The <client> is responsible for computing hash values, extracting the key of an element, and comparing candidates."

    | new bucket count |
    bucket := self at: bucketIndex.
    count := bucket count.
    new := bucket class new: count * 3.
    count := new copyFrom: bucket for: client.
    self at: bucketIndex put: new.
    self at: bucketIndex - 1 put: count!
elementsDo: iterationBlock
		"Evaluate the iterationBlock once for each element in the receiver. If the receiver is empty, 
		the block will not be evaluated."

	| bucket |
	1 to: self size // 2
		do:
			[ :bucketIndex |
			( bucket := self at: bucketIndex * 2 ) == nil
				ifFalse: [ bucket elementsDo: iterationBlock ]
			]!  
incrementBucketAt: index for: client
    "Private - Increment the element count associated with the bucket at <index> in the receiver."
    | countIndex |
    countIndex := index - 1.
    self at: countIndex put: ((self at: countIndex) + 1).
    (self bucketCapacityExceeded: index)
        ifTrue: [self growBucketAt:index for: client].!  
stackPointerToProcessIndex: aStackPointer
        "Private - convert aStackPointer, an absolute address into the
        stack, into an index into the receiver."
    | launchFrame stackBaseOffset |
    launchFrame := self getLaunchFrame  * 2.
    stackBaseOffset := launchFrame asUnsigned - aStackPointer asUnsigned.
    ^( endPosition - ( stackBaseOffset  // self class frameBiasUnit ) )
        - ( startPosition - 1 )!  
maxValueUnsigned
        " Answer a ULARGE_INTEGER containing the maximum value that it can represent. "

    ^self fromUnsignedInteger: 16rFFFFFFFFFFFFFFFF!  
sizeInBytes
         "Private - Answer the default size in bytes."
    ^8!  
maxValue
        " Answer a LARGE_INTEGER containing the maximum value that it can represent. "

    ^self fromUnsignedInteger: 16r7FFFFFFFFFFFFFFF!   
fromInteger: anInteger
        " Answer a new instance of the receiver with value <anInteger>
        in LARGE_INTEGER format of an 8-byte signed integer. "

    ^self new
        largeIntegerAtOffset: 0 put: anInteger;
        yourself!   
fromUnsignedInteger: anInteger
        " Answer a new instance of the receiver with value <anInteger>
        in ULARGE_INTEGER format of an 8-byte unsigned integer. "

    ^self new
        uLargeIntegerAtOffset: 0 put: anInteger;
        yourself!   
highHalf
        "Private - Answer the high half double-word."

    ^self uLongAtOffset: 4!
highHalf: anInteger
        "Private - Set the high half double-word."

    self uLongAtOffset: 4 put: anInteger.! 
lowHalf
        "Private - Answer the low half double-word."

    ^self uLongAtOffset: 0!  
lowHalf: anInteger
        "Private - Set the low half double-word."

    self uLongAtOffset: 0 put: anInteger.!   
highHalfUnsigned
        "Private - Answer the high half double-word."

    ^self uLongAtOffset: 4!
asInteger
        " Answer the receiver as an integer.
        If the high bit is on a negative number is returned."

    ^self largeIntegerAtOffset: 0!  
asUnsignedInteger
        " Answer the receiver as a positive integer. "

    "^( self highHalf bitShift: 32 ) + self lowHalf"
    ^self uLargeIntegerAtOffset: 0!
highHalfUnsigned: anInteger
        "Private - Set the high half double-word."

    self uLongAtOffset: 4 put: anInteger.! 
uShortAtOffset: anInteger
        "Answer the word (16 bits) at anInteger in the receiver.
         Offsets are zero relative."
    | total offset |
    offset := anInteger + 1.
    total := 0.
    1 to: 0 by: -1 do: [ :i |
        total := ( total bitShift: 8 ) + ( self at: offset + i ) ].
    ^total!   
pathName: aString
	"Answer a Directory described by the
         complete path name in aString."

	^self fromPath: aString!   
findFileName: fileName on: path
        "Private - answer the full path of the file named fileName,
        searching along the given path."
    | buffer ptr answer |
    ptr := ExternalAddress new.
    buffer := String new: 255.
    answer := KernelLibrary
        searchPath: path asParameter
        file: fileName asParameter
        extension: nil
        bufSize: buffer size
        buffer: buffer
        filePart: ptr asParameter.
    answer = 0 ifTrue: [ ^nil ].
    buffer := ( buffer copyFrom: 1 to: answer ) asNormalizedString.
    ^buffer isEmpty ifTrue: [ nil ] ifFalse: [ buffer ]!  
timeLeadZero
        "Answer the current system value for time lead zero.
         Answer 0 = no leading zero (9:15:24)
                      1 = leading zero (09:15:24)."
    timeLeadZero isNil
        ifTrue: [ timeLeadZero := self queryNationalProfileInt: 'iTLZero' default: 0 ].
    ^timeLeadZero!   
getErrorMessage: anInteger
        "Private - answer the error message string corresponding to
        the host error code anInteger."
    | message count |
    message := String new: 255.
    ( count := KernelLibrary
        formatMessage: FormatMessageFromSystem
        source: 0
        message: anInteger
        language: 0
        buffer: message
        size: message size
        arguments: 0 ) = 0
            ifTrue: [ ^self osError ].
    message := message copyFrom: 1 to: count - 2.  "chop off trailing CR/LF"
    message := message replaceAll: Stream crString with: ( String with: $ ).  "replace hard linefeeds"
    ^message!  
drivePathName
        "Answer a String representing the drive and path name
         of the receiver directory."

    ^self absolutePath asString
!  
in: aDLL entryPointName: apiName
	"Answer an instance of the receiver."

	^self new setDLL: aDLL entryPoint: apiName!  
removeClassVarName: aString
        "Obsolete - Remove the class variable
         named aString from the receiver."

	(self classPool includesKey: aString)
		ifFalse: [self error: self name , ' does not define class variable named ' , aString].
	self superclass
		subclass: self symbol
   		instanceVariableNames: self instanceVariableString
    	classVariableNames: (String fromArrayOfSubstrings: (self classPool keys asArray copyWithout: aString) separatedBy: $ )
		poolDictionaries: self sharedVariableString
		isVariable: self isVariable
		isPointers: self isPointers! 
propertyAt: aPropertyName ifAbsent: aBlock
    "Answer the value of the receiver's property identified by <aPropertyName>
    or the result of evaluating <aBlock> if none."

    ^self propertyTable at: aPropertyName ifAbsent: aBlock! 
hashModulusFor: size
    "Private - Answer a power of two equal to or greater than size for use as an allocation size."
    | last |
    PowerTwo do:
        [ :number | size < number ifTrue: [ ^number ] ].
    last := PowerTwo last.
    [ size < last ]
        whileFalse: [ last := last * 2 ].
    ^last!
asExternalHandle
        "Answer the receiver as an ExternalHandle."
    ^ExternalHandle fromBytes: self!   
allocateMemory: size
        "Allocate size number of bytes in host memory.
         Answer an Address for the allocated memory."
    ^self allocateMemory: size flags: GmemMoveable | GmemZeroinit!   
named: aString
        "Answer an instance of a Win struct named aString
        which was previously defined using #define:withFields:.
        This object will understand messages
        sent to it which match the field name symbols
        in the definition (see #define:withFields:).  Use the
        exact field name as a message selector to
        retrieve the value of a field.  Append a colon to
        the field name to set the value of a field."
    | definition sds md |
    definition := Definitions at: aString.
    sds := ( self new: ( definition at: #sizeInBytes ) )
        definition: definition.
    md := MethodDictionaries at: aString ifAbsent: [ nil ].
    md notNil ifTrue: [ sds addBehavior: md ].
    ^sds!  
nameOf: aSelfDefinedStructure
        "Answer the name aSelfDefinedStructure."
    ^Definitions 
        keyAtValue: aSelfDefinedStructure definition
        ifAbsent: [ 'UNKNOWN' ]!
store: structureName on: aStream
        "Append the ASCII representation of the
         structure named structureName to aStream,
         suitable for using with #define:withFields: ."
    | sorted |
    aStream
        nextPutAll: 'SelfDefinedStructure define: ';
        nextPutAll: structureName printString;
        nextPutAll: ' withFields:
    ( IdentityDictionary new'; cr.
    sorted := SortedCollection sortBlock: [:a :b |
        ( a value at: 1 ) <= ( b value at: 1 )].
    ( Definitions at: structureName ) associationsDo: [:a |
        ( a key last = $: or: [ a key = #sizeInBytes ]) ifFalse: [
            sorted add: a]].
    sorted do: [:a |
            aStream
                tab; tab;
                nextPutAll: 'at: #';
                nextPutAll: a key;
                nextPutAll: ' put: #';
                nextPutAll: a value printString;
                nextPutAll: ';' ; cr].
    aStream tab; tab; nextPutAll: 'yourself ).';cr.! 
isCompiled: aString
        "Answer whether the structure named aString
         has compiled field accessors."
    ^MethodDictionaries includesKey: aString!  
undefine: aString
        "Remove the SelfDefinedStructure named aString from the
        list of known definitions; if the structure named aString does
        not exist, ignore the request."
    self definitions removeKey: aString! 
named: aString atAddress: anAddress
        "Answer an instance of a struct named aString
        which was previously defined using #define:withFields:,
        whose bytes are at the address identified by anAddress."
    | sds md |
    sds := self new
        contents: anAddress;
        definition: ( Definitions at: aString ).
    md := MethodDictionaries at: aString ifAbsent: [ nil ].
    md notNil ifTrue: [ sds addBehavior: md ].
    ^sds!
define: aString withFields: aDictionary
        "Define a memory structure.  aString is the
        name of the structure (to be used later as the
        argument to SelfDefinedStructure named:).  aDictionary
        describes the fields of the structure.  The
        dictionary keys are the symbol names of the fields
        and the values are 3 element Arrays.  The
        first element is the byte offset of the field (zero based)
        within the structure.  The second element is a
        field type symbol (for 1, 2, and 4 byte fields) or
        an integer indicating the number of bytes in the
        field (for larger fields).  The allowable field type symbols
        are:  #byte, #short, #ushort, #long, #ulong, #handle, #address.
        The third element is a selector.  When retrieving a
        field, the value is first extracted in 'raw' form, then
        the selector specified in the third array
        element is sent to this 'raw' field value
        and the resulting object is returned for the field
        value.  For all the field types except #handle, the
        raw value is an integer and so the third
        element of the array can simply be #yourself.
        For field type #handle the raw value is a 4
        element ByteArray so the third element of the
        array will typically be #asWindowHandle,
        #asExternalHandle, #asExternalAddress, etc.
        When the field type (the second array element) is an
        integer (for larger fields), the raw value is a
        ByteArray so the third element of the array
        might be #asString."
    | d max sizes sizeInBytes |
    d := IdentityDictionary new.
    max := Association key: nil value: #(0 0).
    aDictionary associationsDo: [:a |
        d at: a key asSymbol put: a value.
        d at: (a key, (String with: $:)) asSymbol put: a value.
        ((a value at: 1) >= (max value at: 1)) ifTrue: [max := a]].
    "Compute size in bytes."
    sizes := Dictionary new.
    sizes
        at: #byte put: 1;
        at: #short put: 2;
        at: #ushort put: 2;
        at: #long put: 4;
        at: #ulong put: 4;
        at: #handle put: 4;
        at: #address put: 4.
    sizeInBytes := ((max value at: 1) +
        (sizes at: (max value at: 2) ifAbsent: [max value at: 2])).
    sizeInBytes := sizeInBytes \\ 2 + sizeInBytes.
    d at: #sizeInBytes put: sizeInBytes.
    Definitions at: aString put: d
!  
definitions
        "Private - answer the Dictionary of SDS definitions."
    ^Definitions! 
sizeInBytesOf: aString
        "Answer the size of the SelfDefinedStructure named aString in bytes."
    ^( Definitions at: aString ) at: #sizeInBytes! 
at: aSymbol put: anObject
        "Set the field named aSymbol to anObject."
    | field |
    field := definition at: aSymbol
        ifAbsent: [^super doesNotUnderstand: (Message new
            receiver: self selector: aSymbol arguments: #())].
    self privateAt: field put: anObject.!   
offsetOf: aSymbol
        "Answer the field offset for aSymbol from the receiver."
    ^ ( definition at: aSymbol ifAbsent: [ ^nil ] ) at: 1!   
privateAt: aField put: anObject
        "Private - Set the field described by aField to anObject."
    | s |
    s := AtPutSelectors at: (aField at: 2) ifAbsent: [
        ^self bytesAtOffset: (aField at: 1) put: anObject].
    ^self perform: s
        with: (aField at: 1)
        with: anObject.! 
definition: aDefinitionDictionary
        "Private - Set the definition for the receiver."
    definition := aDefinitionDictionary! 
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream.  This is the default implementation which
         prints 'a' ('an') followed by the receiver class name."
    | aString |
    aString := self class nameOf: self.
    (aString at: 1) isVowel
        ifTrue: [aStream nextPutAll: 'an ']
        ifFalse: [aStream nextPutAll: 'a '].
    aStream nextPutAll: aString!  
respondsTo: aSymbol
        "Answer whether the receiver will respond to the given message selector."
    ^( super respondsTo: aSymbol ) or: [ self definition includesKey: aSymbol ]!  
definition
        "Private - Answer the definition for the receiver."
    ^definition! 
at: aSymbol
        "Answer the field named aSymbol from the receiver."
    | field |
    field := definition at: aSymbol
        ifAbsent: [^super doesNotUnderstand: (Message new
            receiver: self selector: aSymbol arguments: #())].
    ^self privateAt: field.! 
privateAt: aField
        "Private - Answer the field described by aField."
    | s |
    s := AtSelectors at: (aField at: 2) ifAbsent: [
        ^(self bytesAtOffset: (aField at: 1) count: (aField at: 2))
            perform: (aField at: 3)].
    ^(self perform: s with: (aField at: 1))
        perform: (aField at: 3).!  
sizeInBytes
        "Answer the size of the receiver structure in bytes."
    ^definition at: #sizeInBytes! 
doesNotUnderstand: aMessage
        "Private - See if the message selector is one of the
         field names of the receiver.  If so, access that field."
    | field s |
    s := aMessage selector.
    field := definition at: s
        ifAbsent: [^super doesNotUnderstand: aMessage].
    s last = $:
        ifTrue: [self privateAt: field put: aMessage arguments first]
        ifFalse: [^self privateAt: field].!   
binaryWriteStream
    "Answer a binary WriteStream streaming over the contents of the receiver."

	| copy |
	copy := self copy.
	copy fileSystemLocator: self fileSystemLocator absolutePath.
	^FileStream binaryOn: copy open! 
asPoint
        "Answer the receiver as a Point."
    ^Point fromString: self!  
exceptionClass: anExceptionClass
	"Private-Set the class of exceptions we filter"

	exceptionClass := anExceptionClass!
filterPattern
	"Private-Return a pattern that can be used to filter exceptiions"

	^filterPattern! 
filterPattern: aString
	"Private-Set the string filter pattern"

	filterPattern := Pattern new: aString!   
handles: anException
	"Answer <true> if a handler for the receiver can handle <anException>.
	This message is sent by the exception handling system while choosing
	a handler for a particular exception.

	An ExceptionFilter handles an exception if the fileClass would handle the
	exception and if the filterPatter matches the exception's description."

	^(self exceptionClass handles: anException) and: [self match: anException description]!  
exceptionClass
	"Private-Return the class of exceptions we filter"

	^exceptionClass!  
, arg
	"Answer a new instance of ExceptionSet containing the reciever and the argument."

	^(ExceptionSet with: self) , arg!   
match: aString
	"Private-If the filter pattern matches the argument return true, otherwise return false"

	| matchResult |
	matchResult := self filterPattern reset match: aString index: 1.
	matchResult isNil
		ifTrue: [^false].
	^matchResult x = 1 and: [matchResult y = aString size]!   
windowBorderSize
        "Answer a Point which specifies the border size."
    ^( self getSystemValue: SystemValueWindowBorderWidth )
        @ ( self getSystemValue: SystemValueWindowBorderHeight )!
update: firstParameter with: secondParameter with: thirdParameter
        "An object on whom the receiver is dependent
         has changed.  The receiver updates its status
         accordingly (the default behavior is to do nothing).
         The argument firstParameter usually identifies the
         kind of update and the secondParameter is a unary
         message defined in the receiver protocol."! 
height: aNumber
        "Change the receiver height to aNumber."
    rightBottom y: (leftTop y down: aNumber)!  
removeAction: anAction forEvent: eventName
        "Remove the first occurrence of <anAction> from the list of
        actions for the event named <eventName>."
    self
        removeActionsSatisfying: [:action | action = anAction]
        forEvent: eventName!
= anExternal
	"Answer true if the receiver and anExternal refer to the same external object."

	anExternal class == self class ifFalse: [ ^false ].
	^anExternal typeField = type
		and: [ anExternal value = value ]!   
printOn: aStream
        "Append the ASCII representation of the receiver
         to aStream."

	type == nil ifTrue: [ ^super printOn: aStream ].
	aStream nextPutAll: ( ObjectStoreExternalTypes keyAtValue: type ), ' ( ', value printString, ' )'.!  
resolveStandardBlockClosure
        "Private - Resolve the receiver."
    ^BlockClosure standardTemplates at: value asInteger!  
resolveMethodDictionaryArray
        "Private - Resolve the receiver."
    ^(self getClass: value asSymbol ifAbsentOrNil: [ ^self ]) methodDictionaries!
resolveTrue
        "Private - Resolve the receiver."
	^true!   
hash
	"Answer the receiver's hash."

	^type hash + value hash! 
resolveNil
        "Private - Resolve the receiver."
	^nil! 
resolveClassVariable
        "Private - Resolve the receiver."
    | class |
    class := self getClass: ( value at: 2 ) asSymbol ifAbsentOrNil: [ ^self ].
    ^class classPool associationAt: ( value at: 1 ) ifAbsent: [ ^self ]!  
resolveCommonByteArray
        "Private - Resolve the receiver."
    ^CommonByteCodeArrays at: value asInteger! 
resolveAssoc
        "Private - Resolve the receiver."
    ^self class getAssoc: value asSymbol ifAbsent: [ ^self ]!
resolveMetaMethodDictionaryArray
        "Private - Resolve the receiver."
    ^(self getClass: value asSymbol ifAbsentOrNil: [ ^self ]) class methodDictionaries!  
resolveMethodDictionary
        "Private - Resolve the receiver."
    ^(self getClass: value asSymbol ifAbsentOrNil: [ ^self ]) methodDictionary!   
resolveCreateIt
        "Private - Resolve the receiver."
    | answer class temp |
    temp := value asArrayOfSubstrings.
    class := self class globalNameSpace at: ( temp at: 1 ) asSymbol ifAbsent: [ ^self ].
    answer := class new: ( temp size - 1 ).
    1 to: answer size do: [:i |
        answer at: i put: ( ( temp at: ( i + 1 ) ) asInteger ) ].
    ^answer!
resolveGlobal
        "Private - Resolve the receiver."
    ^self getClass: value asSymbol ifAbsent: [ ^self ]! 
resolveMarkedFrame
	"Private - Resolve the receiver."

	^FrameMarker!  
resolveMethod
        "Private - Resolve the receiver."
    ^CompiledMethod fromPrintString: value! 
resolveSymbol
        "Private - Resolve the receiver."
    ^value asSymbol!
typeField
	"Answer the type field."

    ^type!
resolveCharacter
	"Private - Resolve the receiver."

	^value asCharacter!  
resolveMetaMethodDictionary
        "Private - Resolve the receiver."
    ^(self getClass: value asSymbol ifAbsentOrNil: [ ^self ]) class methodDictionary! 
type: anInteger
        "Private - Set the type of the receiver."
    type := anInteger!
resolveMetaClass
        "Private - Resolve the receiver."
    ^(self getClass: value asSymbol ifAbsentOrNil: [ ^self ]) class! 
resolveResidue
        "Private - Resolve the receiver."
    ^ResidueObject residue!
type
        "Answer a string that represents the type of the
         receiver."
    ^ObjectStoreExternalTypes keyAtValue: type!  
<= anExternal
	"Private - Answer true if the receiver sorts less than
	or equal to anExternal."

	^type <= anExternal typeField
		and: [ value isString 
		and: [ anExternal value isString 
		and: [ value <= anExternal value ] ] ]! 
type: anInteger value: aString
        "Private - Set the type and value of the receiver."
    type := anInteger.
    value := aString.!   
value
        "Private - Answer the value of the receiver."
    ^value! 
originalName
	"Answer a user-sensible string for the receiver."

	| typeString |
	typeString := ObjectStoreExternalTypes keyAtValue: type.
	typeString := typeString copyFrom: 1 to: typeString size - 'External' size.
    ^value, ' ', typeString!
value: aString
        "Private - Set the value of the receiver."
    value := aString! 
resolveFalse
        "Private - Resolve the receiver."
	^false! 
resolvePoolVariable
        "Private - Resolve the receiver."
    | pool |
    pool := self getClass: ( value at: 2 ) asSymbol ifAbsentOrNil: [ ^self ].
    ^pool associationAt: ( value at: 1 ) ifAbsent: [ ^self ].!   
resolve
        "Private - Resolve the receiver."
    | resolvedValue |
    type = 0 ifTrue: [ ^value ].  "Already done."
    resolvedValue := self perform: ( #(
        #resolveSymbol
        #resolveAssoc
        #resolveGlobal
        #resolveMetaClass
        #resolveMethodDictionary
        #resolveMetaMethodDictionary
        #resolveExpression
        #resolveClassVariable
        #resolveMethodDictionaryArray
        #resolveMetaMethodDictionaryArray
        #resolveCreateIt
        #resolvePoolVariable
        #resolveCommonByteArray
        #resolveNil
        #resolveTrue
        #resolveFalse
        #resolveMarkedFrame
        #resolveCharacter
        #resolveMethod
        #resolveResidue
        #resolveStandardBlockClosure )
            at: type).
    ( resolvedValue == self ) ifTrue: [ ^self ].
    type := 0.
    value := resolvedValue.
    ^value!  
setEndOfFileTo: anInteger
        "Truncate or extend the end-of-file position of the receiver."

	 self fileId setEndOfFileTo: anInteger! 
evaluateWithArguments: anArray
        "Answer the result of evaluating the receiver, or the receiver itself if
        it does not have any execution semantics."
    ^self!  
unicodeStringAsAscii
        "Answer the receiver represented in Unicode format
         as an ASCII string."
    ^self unicodeStringAsAscii: self length: self size // 2! 
frameBias: aProcessIndex
        "Private - set the frame bias from a processIndex."
    ^frameBias := ( ( endPosition - aProcessIndex + 1 )  -  ( startPosition - 1 ) )
        * self class frameBiasUnit!   
findNext: aSearchResult
        "Private - find the next entry in the directory search;
        answer the findData structure, or nil if no next element."

    | findData |
    findData := Win32FindData new.
    ( KernelLibrary findNextFile: aSearchResult searchHandle findData: findData asParameter )
        ifTrue: [ ^aSearchResult findData: findData ].
    KernelLibrary getLastError = 18   "ERROR_NO_MORE_FILES"
        ifTrue: [ ^nil ]
        ifFalse: [ ^self osError ]
! 
for: anElementName
        "Answer a CollectionAccessor which
        answers the specified element from the
        collection with which it is evaluated."
    ^self new elementName: anElementName!
lastAccessTimeForEntityNamed: aString
    "Answer the last access time (as a TimeStamp) for the entity in the receiver named <aString>"

    self
        searchResultsDo:
            [:searchResult |
            (searchResult entityName equalsIgnoreCase: aString)
                ifTrue: [^searchResult lastAccessTime]].
    ^nil!
evaluateWithArguments: evaluationArguments
        "Answer the element which the receiver accesses
        from the collection in the evaluationArguments."
    ^evaluationArguments at: elementName!  
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
    self class printOn: aStream.
    aStream nextPutAll: ' (', elementName printString, ')'.! 
elementName
        "Answer the name of the collection element which
        the receiver accesses."
    ^elementName! 
elementName: anElementName
        "Specify the name of the collection element to be accessed."
    elementName := anElementName.!  
evaluate
        "Evaluate the receiver with no evaluation arguments."
    self error: 'no collection provided'!
hasNetworkName
        "Private - Answer true if the drive specifier is a string representing
          a network drive (e.g. '\\SVR\ALIAS'), false for a drive letter. "

    ^ self fileSystemLocator isNetworkPath!
says: aStringPattern
	"Create an exception filter for that class that handles exceptions
	whose description matches the argument string"

	^ExceptionFilter
		on: self
		matching: aStringPattern!  
errorBadSelector: badSelector
        "Private - indicate that the message selector is not valid."
    self error: 'Message selector ', badSelector printString, ' must be a Symbol.'!  
changed
        "The receiver changed in some general way.
        Inform all of the receiver's dependents by sending
        each dependent an update message."
    self triggerEvent: self changedEventName!
status
        "Answer the status of the floating point
         coprocessor as a small integer (refer to
         coprocessor status word definition)."
    <primitive: 86>! 
maxExponent
        "Private - the maximum exponent for a decimal number that will fit in a floating point number for this system. This value is the maximum exponent for an IEEE 754 double precision number."

    ^309

    "IEEE extended precision ^4933"
    "IEEE double precision ^309"
    "IEEE single precision ^39"!   
pi
        "Answer the floating point representation
         of pi."
    ^3.14159265358979323846.    " 1 arcTan * 4  "!   
fromString: aString decimalSeparator: decimalString
        "Answer the floating point conversion of the receiver,
          using decimalString as the decimal separator.
         The receiver is expected to be a sequence of
         the form [(+|-)] [digits] [decSep [digits] ] [(E|e) [(+|-) digits]]."
    | string integer fraction exponent char index |
    aString size = 0 ifTrue: [^0.0].
    (char := aString at: 1) = $-
        ifTrue: [ ^(aString copyFrom: 2 to: aString size) asFloat negated].
    string := aString, decimalString, 'Ez'.
    integer := index := 0.
    char = $+
        ifTrue: [index := 1].
    [(char := string at: (index := index + 1)) isDigit]
        whileTrue: [integer := integer * 10 + char digitValue].
    fraction := 1.
    char = (decimalString at: 1)
        ifTrue: [
            [(char := string at: (index := index + 1)) isDigit]
                whileTrue: [
                    integer := integer * 10 + char digitValue.
                    fraction := fraction * 10]].
    (char = $E or: [char = $e])
        ifTrue: [exponent := (string copyFrom: index+1 to: string size) asInteger]
        ifFalse: [
            integer = 0 ifTrue: [^0.0].
            exponent := 0].
    integer = 0 ifTrue: [^0.0].
    exponent >= self maxExponent
        ifTrue: [^ArithmeticError signal: 'Float overflow exception'].
    exponent := 10 raisedToInteger: exponent.
    ^((integer / fraction) * exponent) asFloat!
clearExceptionFlags
        "Answer the status of the floating point
         coprocessor as a boolean. True means 
         at least one coprocessor status word 
         exception bit is set. False means the
         exception bits are all clear. This method 
         will clear all the exception bits."
    <primitive: 163>
    ^self primitiveFailed!
new
        "Private - Answer a new instance of the receiver."
    ^self new: 8!
additiveIdentity
    "Answer the additive identity element for instances of the
    receiver: the number which, when added to any other number
    yields the other number."

    ^0.0!  
fromString: aString
        "Answer the floating point conversion of the receiver;
         the receiver is expected to be a sequence of
         the form [(+|-)] [digits] [decSep [digits] ] [(E|e) [(+|-) digits]]."
    ^self fromString: aString
        decimalSeparator: NationalLanguage decimalSeparator!   
new: anInteger
        "Private - Answer a new instance of the receiver with the appropriate
        number of bytes."
    ^self basicNew: anInteger!  
multiplicativeIdentity
    "Answer the multiplicative identity element for instances of
    the receiver: the number which, when multiplied by any other
    number yields the other number."

    ^1.0! 
fromInteger: anInteger
        "Answer a floating point representation
         of the argument anInteger."
    <primitive: 40>
    ^0.0 floatError!  
loadLibrary: aString 
    <api: LoadLibrary struct ushort>
    ^self invalidArgument!   
freeLibrary: hLib
    <api: FreeLibrary ushort none>
    ^self invalidArgument! 
getProcAddress: hModule procName: lpProcName
     <api: GetProcAddress ushort struct ulong>
     ^self invalidArgument! 
freeSelector: wSelector
    <api: FreeSelector ushort none>
    ^self invalidArgument!  
getModuleHandle: aString
    <api: GetModuleHandle struct ushort>
    ^self invalidArgument!
relativeTo: aRectangle
        "Private - Answer a Rectangle whose coordinates
        are proportionally relative to aRectangle."
    | anExtent |
    anExtent := aRectangle extent.
    (aRectangle extent x = 0 or: [aRectangle extent y = 0])
        ifTrue: [ ^self ].
    ^(leftTop - aRectangle leftTop) / anExtent
        extent: self extent / anExtent!  
lastAccessTime
    "Answer the last access time as a TimeStamp."

    | data lat |
    data := self findData.
    lat := data ftLastAccessTime asLocalFileTime.
    ^TimeStamp date: lat asDate time: lat asTime!   
free
        "Free the memory associated with the receiver."
    [
        HeapUseCounts removeKey: self ifAbsent: [ nil ].
        HeapUseCounts isEmpty
            ifTrue: [ HeapUseCounts := nil ].
        Heaps remove: self ifAbsent: [ nil ].
        Heaps isEmpty
            ifTrue: [ Heaps := nil ] ] evaluateWithoutInterrupts.
    ( KernelLibrary heapDestroy: self asParameter )
        ifFalse: [ ^self osError ].
    self uLongAtOffset: 0 put: 0!
primitiveNextPut: aCharacter
        "Private - Write aCharacter to the receiver stream.
         Answer aCharacter."
    <primitive: 66>
    aCharacter isDoubleByte ifTrue: [
        self primitiveNextPut: aCharacter leadByte.
        self primitiveNextPut: aCharacter trailByte.
        ^aCharacter].
    self position: self position.
    position := position + 1.
    writtenOn := true.
    self collection at: position put: aCharacter.
    ^aCharacter!  
asNullTerminatedUnicodeString
        "Answer a Unicode copy of the receiver with NULL termination."

    ^self asUnicodeStringNullTerminated: true!   
finalizerInterface: aFinalizerInterface
        "Private - set the finalizer interface that should be notified when
        a flip or compact occurs to aFinalizerInterface."
    Finalizer := aFinalizerInterface!
finalizerInterface
        "Private - answer the finalizer interface that should be notified when
        a flip or compact occurs."
    ^Finalizer!   
constructEventsTriggered
        "Private - Construct the set of events triggered by instances
        of the receiver."
    ^super constructEventsTriggered
        add: #codeCacheCleared ;
        add: #compact ;
        add: #flip ;
        yourself!   
lastWriteTime
    "Answer the a files last write time as a TimeStamp."

    | data ct |
    data := self findData.
    ct := data ftLastWriteTime asLocalFileTime.
    ^TimeStamp date: ct asDate time: ct asTime!  
isArray
        "Answer true if receiver is a kind of Array."
    ^false!   
remove
    "Remove the receiver from the file system."

    self class remove: self absolutePath asString! 
setLimit: anInteger
        "Set the maximum number of open file handles
         allowed by the OS for this process; this has no
         effect under NT."
    KernelLibrary setHandleCount: anInteger.
    MaxHandles := anInteger!   
unlock
        "Unlock the memory at the receiver's address."
    KernelLibrary globalUnlock: memoryHandle asParameter! 
uLargeIntegerAtOffset: anInteger
        "Answer the 8-byte unsigned integer at offset <anInteger> in the receiver.
         Offsets are zero relative."
    ^( ( self uLongAtOffset: anInteger + 4 ) bitShift: 32 ) + ( self uLongAtOffset: anInteger )!  
= aTimeStamp
        "Answer true if the receiver is
        equal to aTimeStamp, else answer false."
    ^aTimeStamp isTimeStamp
        and: [ self date = aTimeStamp date and: [ self time = aTimeStamp time ] ]!  
asTime
        "Answer the receiver as an instance of Time."
    ^self time!
date
        "Answer the date of the receiver."
    ^date!  
printOn: aStream
        "Append a text representation of the receiver to aStream."
    self date printOn: aStream.
    aStream nextPutAll: ' '.
    self time printOn: aStream!  
time
        "Answer the time of the receiver."
    ^time!  
time: aTime
        "Private - set the time of the receiver."
    time := aTime!
< aTimeStamp
        "Answer true if the receiver is less than
        aTimeStamp, else answer false."
    ^self date < aTimeStamp date
        or: [ self date = aTimeStamp date and: [ self time < aTimeStamp time ] ]! 
<= aTimeStamp
        "Answer true if the receiver is less than
        or equal to aTimeStamp, else answer false."
    ^self date < aTimeStamp date
        or: [ self date = aTimeStamp date and: [ self time <= aTimeStamp time ] ]!   
dateAndTime
        "Answer a two element Array containing the date and time."
    ^Array with: self date with: self time!  
asDate
        "Answer the receiver as an instance of Date."
    ^self date!
date: aDate
        "Private - set the date of the receiver."
    date := aDate!
asTimeStamp
        "Answer the receiver as an instance of TimeStamp."
    ^self!   
> aTimeStamp
        "Answer true if the receiver is greater than
        aTimeStamp, else answer false."
    ^self date > aTimeStamp date
        or: [ self date = aTimeStamp date and: [ self time > aTimeStamp time ] ]!  
>= aTimeStamp
        "Answer true if the receiver is greater than
        or equal to aTimeStamp, else answer false."
    ^self date > aTimeStamp date
        or: [ self date = aTimeStamp date and: [ self time >= aTimeStamp time ] ]!
hash
        "Answer the integer hash value for the receiver."
    ^self date hash bitXor: self time hash!  
isTimeStamp
        "Answer whether the receiver is a TimeStamp. "
    ^true!   
leftTopUnit
        "Answer the left top corner for a one-unit rectangle."
    ^0@0!
fromSegmentedAddress: aSegmentedAddress
        "Answer a 0:32 address from a 16:16 address.
        If the OS is Win95, the returned address must be
        released explicitly using #releaseFlatAddress."
    | flatAddress |
    flatAddress := OperatingSystem isWindows95
        ifTrue: [ ThunkWin95DLL current addr16To32: aSegmentedAddress asParameter ]
        ifFalse: [ ThunkWin32sDLL current addr16To32: aSegmentedAddress asParameter ].
    ^self fromInteger: flatAddress!   
isMDIChild
        "Answer true if receiver is an instance of class
         MDIChild, else answer false."
    ^false! 
asExternalAddress
        "Answer the receiver as an ExternalAddress."
    ^ExternalAddress fromInteger: self!  
isThere: fileName
        "Private - answer true if file named fileName
         exists else answer false."
    ^File exists: fileName!
finalize: anObject
    "The receiver has asked to be notified if <anObject> is finalized.  It has.  Default is do nothing."! 
copyToExternalMemory
        "Copy the receiver to external (non-Smalltalk) memory,
        and answer an instance of ExternalAddress."
    ^ExternalAddress copyToNonSmalltalkMemory: self asParameter!   
changed: aspect
        "Something related to the dependents of the receiver
        has changed.  Send the message #update: to all of the
        receiver's dependents with the <aspect> as the argument.
        The aspect is intended to inform the dependents of the
        nature of the change."
    self
        updateEvent: self changedEventName
        selector: #update:
        arguments: (Array with: aspect)!
fileName
        "Answer the receiver's file name."
    ^'KERNEL'!  
getCurrent
        "Private - get (open) an instance of the receiver."
    ^KernelLibrary16!
position: anInteger
    "Private - Position the file to anInteger."

    ( KernelLibrary
        setFilePointer: self asParameter
        offset: anInteger
        offsetHigh: ( ExternalLong fromInteger: 0 ) asParameter
        move: FileBegin ) = 16rFFFFFFFF
            ifTrue: [ ^self osError ].!   
stashInstVarNames: aCollection
        "Private - Change the instance variables of the receiver to
        <aCollection>.  This method is only sent when a class is
       deleted to record the hierarchy of instance variables for the
       receiver"

    instances := aCollection isEmpty
        ifTrue: [ nil ]
        ifFalse: [ String fromArrayOfSubstrings: aCollection asArray separatedBy: $ ]!
freeSpace
        "Answer an integer which is the number of bytes of unused
        memory available for object storage.  The returned number
        corresponds to the number of bytes of available virtual memory."
    | status |
    status := WinMemorystatus new.
    KernelLibrary globalMemoryStatus: status asParameter.
    ^status dwAvailVirtual

! 
kernelHandle
        "Private - Answer the handle of the Kernel DLL,
         as initialized in the virtual machine."
    ^kernelHandle!   
remove
    "Remove the receiver from the file system."

    self class removeFileNamed: self absolutePath asString!
hasActionForEvent: eventName
        "Answer whether the receiver has an action registered for the
        event named <eventName>."
    ^self eventTable includesKey: eventName asSymbol! 
hasVersion: version ofServiceNamed: serviceName
        "Answer <true> if a given <version> of the service named <serviceName>
        is registered with the receiver."
    ^( self versionOf: serviceName ) = version!   
serviceMap
        "Answer a Dictionary mapping service names to services."
    ^serviceMap!
serviceNamed: serviceName
        "Answer the service registered under the <serviceName>. If there is
        no service registered under that name, answer nil."
    ^self serviceNamed: serviceName ifNone: [ ]! 
versionMap
        "Answer a Dictionary mapping service names to versions."
    ^versionMap!
hasServiceNamed: serviceName
        "Answer <true> if the service named <serviceName> is registered with the receiver."
    ^self serviceMap includesKey: serviceName! 
initialize
        "Private - initialize the receiver."
    serviceMap := IdentityDictionary new.
    versionMap := IdentityDictionary new!
register: service withName: serviceName version: version
        "Register the given <version> of the <service> named
        <serviceName> with the receiver."
    self serviceMap at: serviceName put: service.
    self versionMap at: serviceName put: version!   
registeredServices
        "Answer a collection of the names of all services registered with
        the receiver."
    ^self serviceMap keys! 
serviceNamed: serviceName ifNone: exceptionBlock
        "Answer the service registered under the <serviceName>. If there is
        no service registered under that name, answer the result of evaluating
        the <exceptionBlock>."
    ^self serviceMap at: serviceName ifAbsent: exceptionBlock! 
unregister: serviceName
        "Register with the receiver that the service named <serviceName>
        is no longer available."
    self serviceMap removeKey: serviceName.
    self versionMap removeKey: serviceName! 
versionOf: serviceName
        "Answer the version of the service registered under the <serviceName>.
        Answer <nil> if there is no service registered under that name>."
    ^self versionMap at: serviceName ifAbsent: [ nil ]!
absolutePathString
    "Private - Answer the absolute path to the receiver as a <String>.  Includes the drive name, but no trailing separator character."

	^self absolutePath asString!   
printOn: aStream
        "Append the ASCII representation
         of the receiver to aStream."
     aStream nextPutAll: 'a Smalltalk expression'.!
hasMessagePattern
        "Private - answer whether the receiver has a message pattern."
    ^false!
readInto: aString atPage: anInteger pageSize: sizeInteger
        "Private - Read a page (sizeInteger bytes) or less
         (if at end of file) at page number anInteger from
         the receiver file into aString.  Answer the number
         of bytes read.  aString size must be >= sizeInteger."
    | long |
    long := ExternalLong fromInteger: 0.
    ( KernelLibrary
        setFilePointer: self asParameter
        offset: anInteger * sizeInteger
        offsetHigh: long asParameter
        move: FileBegin ) = 16rFFFFFFFF
            ifTrue: [ ^self osError ].
    ( KernelLibrary
        readFile: self asParameter
        buffer: aString
        bytesToRead: sizeInteger
        bytesRead: long asParameter
        overlapped: nil )
            ifFalse: [ ^self osError ].
    ^long asInteger!  
initializeEvents
	"Initialize the event mechanism."

    EventHandlers := SystemWeakRegistries current events.!
messageText
	"Answer the message text associated with this exception."

	^'Entry point ', entryPoint, ' not found in DLL: ', dll printString!  
setDLL: aDLL entryPoint: apiName
	"Private - Set the receiver's instance variables."

	dll := aDLL.
	entryPoint := apiName.!  
privateMoveTo: targetDirectory
as: newName
    "Private - Move the receiver and anything it contains to the <targetDirectory>, renaming it to the <newName>.  Answer false if system is unable to perform move directly."

    | newLocator |
    newLocator := targetDirectory asFileSystemPath , newName.
    self class 
        move: self absolutePath asString
        to: newLocator absolutePath asString.
    self fileSystemLocator: newLocator.
    ^true!   
exists: aPathName
        "Answer true if the directory specified by aPathName
         exists, otherwise false"

    | attributes |
    attributes := KernelLibrary getFileAttributes: aPathName asParameter.
    attributes = InvalidHandleValue
        ifTrue: [ ^false ].
    ^attributes & FileAttributeDirectory = FileAttributeDirectory! 
binaryReadStream
   "Answer a binary ReadStream streaming over the contents of the receiver."

	| copy |
	copy := self copy.
	copy fileSystemLocator: self fileSystemLocator absolutePath.
	^FileStream binaryOn: copy openReadOnly!
diskSize
    "Answer the amount of actual disk space occupied by the reciever."

	^self size!  
lastModificationTime: aTimeStamp
    "Set the TimeStamp of the date and time at which the receiver was last modified."

    | wasOpen fileTime |
    [ ( wasOpen := self isOpen ) ifFalse: [ self open ].
        fileTime := WinFileTime fromDate: aTimeStamp date time: aTimeStamp time.
        fileTime := WinFileTime fromLocalFileTime: fileTime.
        ( KernelLibrary
            setFileTime: self fileId
            creation: nil
            lastAccess: nil
            lastWrite: fileTime asParameter )
                ifFalse: [ ^self osError ] ] ensure: [ wasOpen ifFalse: [ self close ] ]!
fileName: nString extension: eString
        "Answer a String which is a file name abbreviated
         from nString and eString. Lower case
         vowels are dropped from the right of nString
         until it is less than or equal to 8 characters."
    | size aString fileName maxLength |
    maxLength := OperatingSystem isWindows95 ifTrue: [ 255 ] ifFalse: [ 8 ].
    ( nString detect: [ :c | c isAlphaNumeric not ] ifNone: [ nil ] ) notNil
        ifTrue: [ fileName := 'untitled' ]
        ifFalse: [
            size := nString size.
            aString :=
                (nString reversed select: [ :char |
                (char isVowel and: [char isLowerCase])
                    ifTrue: [(size := size - 1) < maxLength]
                    ifFalse: [true]]) reversed, '       '.
            size := 0.
            fileName := aString select: [ :char |
                ((char isDoubleByte)
                    ifTrue: [size := size + 2]
                    ifFalse: [size := size + 1]) <= maxLength].
            fileName := fileName trimBlanks ].
    ^eString isEmpty
        ifTrue: [ fileName ]
        ifFalse: [ fileName, '.', ( eString, '   ' copyFrom: 1 to: 3 ) trimBlanks ]!   
ASSERT: aBoolean
        "Determine whether some condition which is asserted to be the case is in fact true.
        If the assertion is incorrect,  create a resumable walkback window warning that a
        correctness assertion failed.  Answer whether the assertion is satisfied."
    ( SessionModel current isRunTime not and: [ aBoolean not ] ) ifTrue: [
        Process
            queueWalkback: 'correctness assertion failed'
            makeUserIF: CurrentProcess isUserIF
            resumable: 2 ].
    ^aBoolean!
changeModeOf: aString to: attrString
        "Change the attributes of the file named aString
         to those of attrString.  Attributes are:
         $r - read only, $h - hidden, $s - system,
         $a - archive."
    | flags |
    flags := 0.
    ( attrString includes: $r ) ifTrue: [ flags := flags | FileAttributeReadonly ].
    ( attrString includes: $h ) ifTrue: [ flags := flags | FileAttributeHidden ].
    ( attrString includes: $s ) ifTrue: [ flags := flags | FileAttributeSystem ].
    ( attrString includes: $a ) ifTrue: [ flags := flags | FileAttributeArchive ].
    ( KernelLibrary
        setFileAttributes: aString asParameter
        attributes: flags )
            ifFalse: [ ^self osError ]!  
newFile: aString
in: aDirectory
	"Answer a FileStream with path name aString
        in aDirectory."

	| new |
	new := self fromPath: aString in: aDirectory.
	new exists
		ifTrue: [new remove].
	new create.
	^new writeStream!   
when: eventName send: selector to: anObject withArguments: argumentList
        "Form an action with <anObject> as the receiver,
        a <selector> as the message selector, and the
        elements of the <argumentList> as the arguments
        and append it to the actions list for the event
        named <eventName>."
    | arguments |
    selector isSymbol
        ifFalse: [^self errorBadSelector: selector].
    arguments := Array new: (Message numberOfArgumentsFor: selector).
    arguments
        replaceFrom: 1
        to: (arguments size min: argumentList size)
        with: argumentList
        startingAt: 1.
    self
        when: eventName
        evaluate:
            (((Message numberOfArgumentsFor: eventName) = 0
                    ifTrue: [Message] ifFalse: [LinkMessage])
                receiver: anObject
                selector: selector
                arguments: arguments)!  
fileSystem
        "Private - answer the name of the file system for this volume."
    | fileSystemName |
    fileSystemName := String new: 255.
    ( KernelLibrary
        getVolumeInformation: self asFileSystemPath asString asParameter
        name: nil
        nameSize: nil
        serialNumber: nil
        maximumComponentLength: nil
        fileSystemFlags: nil
        fileSystemName: fileSystemName
        fileSystemNameSize: fileSystemName size )
            ifFalse: [ self osNotification ].
    ^fileSystemName trimNullTerminator asNormalizedString!  
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^true!   
up: aNumber
        "Answer the location up aNumber of positions from
         the receiver."
    ^self - aNumber! 
osWarning: anInteger
        "Create a notification for the warning #anInteger raised by
        the last API call."
    | msg |
    msg := ( self osErrorMessage: anInteger ), ' ( OS warning ', ( anInteger radix: 16 ), ' )'.
    ^LoggedWarning signal: msg! 
exit
        "Clean up 16-bit thunk if running under Windows
        (dll opened in virtual machine)."
    | dll |
    dll := self open.
    ( OperatingSystem isWindows and: [ OperatingSystem isWindows95 not ] )
        ifTrue: [ dll exit ].
    dll close. "for open above"
    dll close  "for open in vm"!
triggerEvent: eventName withArguments: argumentList ifNotHandled: exceptionBlock
        "Trigger the event <eventName> using the elements of
        the <argumentList> as the arguments.  If the event is
        not handled, answer the value of <exceptionBlock>,
        otherwise answer the value returned by the most
        recently defined event handler action."
    ^(self eventTable
        at: eventName asSymbol
        ifAbsent: [^exceptionBlock value])
            evaluateWithArguments: argumentList!  
new
        "Disallow the instantiation of characters
         because characters are immutable."
    ^self invalidMessage!
digitValue: anInteger
        "Answer the character representation
         of the digit anInteger."
    anInteger >= 0
        ifTrue: [
            anInteger < 10
                ifTrue: [ ^ '0123456789' at: anInteger+1 ].
            anInteger <= 35
                ifTrue: [  ^self value: anInteger + 55] ].
    ^ self error: 'digitValue not in range 0..35'.!  
leadByte: aCharacter1 trailByte: aCharacter2
        "Answer the character whose high-order byte
         is the code point value of aCharacter1 and
         whose low-order byte is the code point value
         of aCharacter2."
    ^self value:
        ((aCharacter1 asInteger bitShift: 8) + aCharacter2 asInteger)!
value: anInteger
        "Answer the character whose code point
         value is anInteger."
    (0 > anInteger or: [65535 < anInteger])
        ifTrue: [self error: 'Character value out of range 0..65535'].
    (255 < anInteger)
        ifTrue: [  " double-byte characters may not be unique "
            ^(self basicNew) instVarAt: 1 put: anInteger; yourself].
    "The following takes advantage of the fact that in our system
        consecutive characters in the ASCII sequence [0..255] have
        consecutive object pointer numbers"
    ^AllCharacters at: (anInteger + 1)!   
fileSize
	"Answer the a files size in bytes."

	| data |
	data := self findData.
	^(data nFileSizeHigh bitShift: 32) + data nFileSizeLow!
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^true!   
exitBase
        "Private - perform base smalltalk shutdown."
    VirtualMachineDLL exit.
    self quit!   
eventHandlers: anEventTable
        "Private - set the event handlers to anEventTable."
    EventHandlers := anEventTable!  
new: anInteger
        "Answer a SortedCollection capable of
         holding anInteger number of elements
         which will sort in ascending order."
    ^( super new: anInteger )
        ascendingOrder!   
sortBlock: aBlock
        "Answer a SortedCollection which will
         sort in the order defined by aBlock."
    ^(super new: 10) sortBlock: aBlock! 
add: newObject after: oldObject
        "Add newObject after the element oldObject in the
         receiver.  This method reports an error since
         the sortBlock determines element order."
    ^self invalidMessage!  
addAll: aCollection
        "Answer aCollection.  Add all the elements
         in aCollection to the receiver in sorted
         order."
    aCollection do: [ :element |
        super addLast: element].
    self reSort.
    ^aCollection! 
add: newObject before: oldObject
        "Add newObject before the element oldObject in the
         receiver.  This method reports an error since
         the sortBlock determines element order."
    ^self invalidMessage!
copyFrom: beginning to: end
        "Answer a SortedCollection containing the
         elements of the receiver from index position
         beginning through index position end."
    | answer |
    answer := self species new: self size.
    answer sortBlock: sortBlock.
    beginning to: end do: [:i |
        answer add: (self at: i)].
    ^answer!   
grow
        "Private - Answer the receiver doubled in
         size to accommodate more elements."
    | aBlock |
    aBlock := sortBlock.
    super grow.
    sortBlock := aBlock!
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each element."
    | answer |
    answer := self species sortBlock: sortBlock.
    self do: [ :element | answer add: element copy ].
    ^answer!   
addFirst: anObject
        "Add anObject before the first element of the
         receiver.  This method reports an error since
         the sortBlock determines element order."
    ^self invalidMessage!   
select: aBlock
        "For each element in the receiver, evaluate
         aBlock with that element as the argument.
         Answer a new collection containing those elements
         of the receiver for which aBlock evaluates to true."
    | answer |
    answer := self species new.
    answer sortBlock: sortBlock copy.
    self do: [ :element |
        (aBlock value: element)
            ifTrue: [answer add: element]].
    ^answer! 
descendingOrder
        "Sort the elements in descending order."
    self sortBlock:
        ( Message new
            receiver: self
            selector: #is:greaterThanOrEqualTo:
            arguments: ( Array new: 2 ) )!
sortBlock
        "Answer the block that determines sort
         ordering for the receiver."
    ^sortBlock!  
sortBlock: aBlock
        "Answer the receiver.  Set the sort block for
         the receiver to aBlock and resort the receiver."
    sortBlock := aBlock.
    self reSort!   
value: object1 value: object2
        "Private - Answer true if object1 is less than object2."
    ^object1 <= object2! 
add: anObject
        "Answer anObject.  Add anObject to the
         receiver in sorted position."
    | index element |
    endPosition = contents size
        ifTrue: [self putSpaceAtEnd].
    index := endPosition.
    endPosition := endPosition + 1.
    [index < startPosition]
        whileFalse: [
            element := contents at: index.
            (sortBlock
                    value: anObject
                    value: element)
                ifFalse: [
                    ^contents at: index + 1
                        put: anObject].
            contents at: index + 1 put: element.
            index := index - 1].
     ^contents at: index + 1 put: anObject! 
addAllLast: aCollection
        "Add all the elements of aCollection to the
         receiver after its last element.  This
         method reports an error since the sortBlock
         determines element order."
    ^self invalidMessage!   
sort: lower to: upper
        "Private - Sort the elements in the receiver
         that are between lower and upper index positions."
    | t terminate mid low up swapper i lastLow |
    low := lower.
    up := upper.
    [(terminate := (i := up - low) <= 1)
        ifTrue: [ "only 0, 1 or 2 elements"
            i = 1
                ifTrue: [ "2 elements"
                    (sortBlock
                        value: (i := contents at: up)
                        value: (swapper := contents at: low))
                        ifTrue: [ "exchange"
                            contents at: low put: i.
                            contents at: up put: swapper]]]
        ifFalse: [
            mid := low + up // 2.
            t := contents at: mid.
            contents at: mid put: (contents at: low).
            i := lastLow := low.
            [i := i + 1.
            (sortBlock value: (contents at: i)
                    value: t)
                ifTrue: [
                    (lastLow := lastLow + 1) = i
                        ifFalse: [
                            swapper := contents at: i.
                            contents at: i
                                put: (contents at: lastLow).
                            contents at: lastLow
                                put: swapper]].
            i < up]
                whileTrue: [].
            contents at: low put: (contents at: lastLow).
            contents at: lastLow put: t.
            mid < lastLow
                ifTrue: [
                    self sort: lastLow + 1 to: up.
                    up := lastLow - 1]
                ifFalse: [
                    self sort: low to: lastLow - 1.
                    low := lastLow + 1]].
    terminate]
        whileFalse: []!  
shallowCopy
        "Answer a copy of the receiver containing each element
        that the receiver contains."
    | answer |
    answer := self species sortBlock: sortBlock.
    answer addAll: self.
    ^answer!   
at: anInteger put: anObject
        "Replace the element at index position anInteger
         in the receiver collection with anObject.  This
         method reports an error since the sortBlock
         determines element order."
    ^self invalidMessage! 
asOrderedCollection
        "Answer an OrderedCollection containing
        the elements of the receiver.  Override the
        implementation defined in the superclass
        which optimizes by answering the receiver."
    ^(OrderedCollection new: self size)
        addAll: self;
        yourself!   
addAllFirst: aCollection
        "Add all the elements of aCollection to the
         receiver before its first element.  This
         method reports an error since the sortBlock
         determines element order."
    ^self invalidMessage!
addLast: anObject
        "Add anObject after the last element of the
         receiver.  This method reports an error since
         the sortBlock determines element order."
    ^self invalidMessage!  
ascendingOrder
        "Sort the elements in ascending order."
        "Implementation note: this uses a private implementation of #value:value: 
        as a performance optimization."
    self sortBlock: self!   
asSortedCollection
        "Answer a SortedCollection containing
         the elements of the receiver sorted
         in ascending order."
    ^self!
reSort
        "Private - Answer the receiver collection
         resorted according to sortBlock."
    self sort: startPosition to: endPosition!  
is: object1 greaterThanOrEqualTo: object2
        "Answer true if object1 is greater than or equal to object2."
    ^object1 >= object2!
open: pathName access: access share: share create: create attributes: attributes
        "Private - open or create the specified file using the specified parameters;
        answer the file handle."
    |  result fileHandle |
    ( result := KernelLibrary
        createFile: pathName asParameter
        access: access
        shareMode: share
        securityAttributes: nil
        create: create
        attributes: attributes
        templateFile: nil ) = InvalidHandleValue
            ifTrue:
                [^[self osError]
                    on: TooManyOpenFiles, FileSharingViolation
                    do:
                        [:ex |
                            (MaxHandles < 255 or: [self cleanHandles])
                                ifTrue:
                                    [self setLimit: ((MaxHandles + 20) min: 255).
                                    self
                                        open: pathName
                                        access: access
                                        share: share
                                        create: create
                                        attributes: attributes]
                                ifFalse: [ex pass]] ].

    fileHandle := self fromInteger: result.
    FileHandles isNil ifTrue: [ FileHandles := Set new ].
    FileHandles add: fileHandle.
    ^fileHandle! 
sizeInBytes
         "Private - Answer the default size in bytes."
    ^142!
fFixedDisk
    ^self byteAtOffset: 1!
reserved1
    ^self shortAtOffset: 4!
szPathName
    ^( self bytesAtOffset: 8 count: 134 ) asString asNormalizedString!
nErrCode
        "Private - Answer the OpenFile error code."
    ^self shortAtOffset: 2!
cBytes
    ^self byteAtOffset: 0!
reserved2
    ^self shortAtOffset: 6!
isInBase
        "Private - Answer true if the receiver is in the base system."

    ^#( 1 2 ) includes: self smalltalkLibraryOrdinal! 
addObjects: byteArray externals: externalsArray objects: objectsArray
    <api: AddObjects self self self self>
    ^self invalidArgument!  
dialogProc
        "Private - Answer the Smalltalk
         dialog proc address."
    ^dialogProc! 
getSystemColor: aSystemColorConstant
        "Private - answer the color value for the color constant identified
        by aSystemColorConstant."
    | value aString |
    ^SystemColors
        at: aSystemColorConstant
        ifAbsent: [
            aString := UserLibrary getSysColor: aSystemColorConstant.
            value := ( ExternalLong fromString: aString ) asInteger.
            SystemColors at: aSystemColorConstant put: value ]!   
getSystemValue: aSystemValueConstant
        "Answer the system value for the given
        identifier aSystemValueConstant."
    | value |
    ^SystemValues
        at: aSystemValueConstant
        ifAbsent: [
            value := UserLibrary getSystemMetrics: aSystemValueConstant.
            SystemValues at: aSystemValueConstant put: value ]!   
version
        "Answer the version number of the host
         operating system (as aString)."
    ^self versionMajor printString, '.', self versionMinor printString!
versionMajor
        "Answer the major version number of the host
         operating system (as an Integer)."
    | version |
    version := KernelLibrary getVersion lowWord.
    ^version bitAnd: 16rFF!   
versionMinor
        "Answer the minor version number of the host
         operating system (as an Integer)."
    | version |
    version := KernelLibrary getVersion lowWord.
    ^version bitShift: -8!
initialize
        "Private - Initialize receiver."
    hInstanceExe := ExternalHandle new.
    hInstanceDLL := ExternalHandle new.
    dialogProc := ByteArray new: 4.
    kernelHandle := KernelDLL new.
    winClassName := String new: 128! 
isWin32
        "Answer whether this system is running on a Win32 OS."
    ^true!   
isWin32s
        "Answer whether this system is running on Windows with
        Win32s (as opposed to Windows NT or Windows 95)."
    ^self isWindows and: [ self isWindows95 not ]!   
isWindowsNT
        "Answer whether this system is running on Windows NT
         (as opposed to Windows)."
    ^self isWindows not!   
name
        "Answer the name of the host operating system."
    ^self isWindows
        ifTrue: [ 'Windows' ]
        ifFalse: [ 'Windows NT' ]! 
isOS2
        "Answer whether this system is running on OS/2."
    ^false!  
beep
        "Beep the speaker"
    ( UserLibrary messageBeep: -1 )
        ifFalse: [ ^self osError ]!
isWindows95
        "Answer whether this system is running on Windows 95."
    ^self isWindows and: [ self versionMajor >= 4 ]! 
isWindows
        "Answer whether this system is running on Windows (as
         opposed to Windows NT)."
    ^( KernelLibrary getVersion bitAnd: 16r80000000 ) = 16r80000000! 
getIt
        "Private - Fill the instance variables of
         the receiver."
    <primitive: 125>!  
exitKernel
        "Private - perform OS kernel shutdown."
    ExternalHeapHandle exit! 
= aFile
    "Answer <true> if the receiver and <aFile> are equal. Two objects are equal if they have the same behavior at the current point in time. Objects that are equal at one time may not be equal at some later time.
        Invariants:
        -    Two objects that compare equal must have equal hash values."

    aFile isFile ifFalse: [ ^false ].
    ^self absolutePath asString equalsIgnoreCase: aFile absolutePath asString!
new
		"Answer a new instance of the receiver."
	^super new initialize!  
waitPrim
        "Force the current process to be suspended until the
        receiver semaphore is signaled. Upon exit, interrupts
        are always enabled."
    <primitive: 117>
    Process enableInterrupts: false.
    (signalCount := signalCount - 1) < 0
        ifTrue: [
            waitingProcesses addLast: CurrentProcess.
            Processor suspendActive].
    Process enableInterrupts: true!   
wait
        "Force the current process to be suspended until the
        receiver semaphore is signaled. Upon exit, interrupts
        are always enabled."
    Processor currentProcessIsRecursive
        ifTrue: [ ^self error: 'wait not allowed during call-back' ].
    ^self waitPrim!  
hasSignals
        "Answer true if there have been more
         signals than waits, else answer false."
    ^signalCount > 0! 
initialize
        "Private - Initialize the receiver
         with an empty waiting queue and
         zero signal count."
    waitingProcesses := OrderedCollection new.
    signalCount := 0! 
signal
        "Increment the receiver's signal count.
         If there are processes waiting on the
         semaphore, resume the longest waiting.
         Upon exit, interrupts are always enabled"
    <primitive: 116>
    Process enableInterrupts: false.
    (signalCount := signalCount + 1) < 1
        ifTrue: [
            Processor resume:
                waitingProcesses removeFirst].
    Process enableInterrupts: true! 
asFloat
        "Answer an instance of Float which is a conversion self;
         self is expected to be a sequence of
         the form [(+|-)] [digits] [decSep [digits] ] [(E|e) [(+|-) digits]]."
    ^Float fromString: self!
country
        "Answer the current system value for country identifier."
    country isNil
        ifTrue: [ country := self queryNationalProfileInt: 'iCountry' default: 0 ].
    ^country! 
cleanUpAfterError
    "Clean up any operating system specific items after
    an error occurs."

    SessionModel current isGui ifTrue: [ self cleanUpAfterGuiError ]!
validFile: aFileName
        "Answer true if aFileName is a file or
         subdirectory in this directory."

    ^self hasEntityNamed: aFileName!   
alreadyRunning: aUniqueApplicationName
    "Answer true if a Smalltalk application by the name
    <aUniqueApplicationName> is already running."

    | handle |
    handle := KernelLibrary
        openFileMapping: PageReadonly
        bInheritHandle: false
        lpName: aUniqueApplicationName.
    handle ~= 0
        ifTrue: [ KernelLibrary closeHandle: handle. ^true ]
        ifFalse: [
            handle := KernelLibrary
                createFileMapping: 16rFFFFFFFF
                lpsa: nil
                fdwProtect: PageReadonly
                dwMaximumSizeHigh: 0
                dwMaximumSizeLow: 1
                lpszMapName: aUniqueApplicationName.
            self runningApplications at: aUniqueApplicationName put: handle.
        ^false ]!   
printBuildInformationOn: aStream
        "Append information about the system build to aStream."
    | vmId |
    ( vmId := VirtualMachineLibrary buildIdentifier ) notNil ifTrue: [
        aStream nextPutAll:
            VirtualMachineLibrary class fileName,
            ' (', ' Visual Smalltalk Virtual Machine), version = ', vmId; cr ].
    SmalltalkLibraryBinder printBoundLibrariesOn: aStream!  
versionNumberString
        "Answer the patch release version number as a string."
    | numbers |
    numbers := self versionNumbers.
    ^( numbers at: 1 ) printString, '.', ( numbers at: 2 ) printString, '.', ( numbers at: 3 ) printString!
version
        "Answer the version number of this Smalltalk product as a string."
    ^self versionNumberString!   
unusedMemory
        "Do a full garbage collection compaction. Answer an integer which
         is the number of bytes of unused memory available for object
         storage."
    | cursorManager |
    ( cursorManager := Smalltalk at: #CursorManager ifAbsent: [ nil ] ) notNil
        ifTrue: [ cursorManager execute changeFor: [ self unusedMemoryPrim: 1 ] ]
        ifFalse: [ self unusedMemoryPrim: 1 ].
    ^self freeSpace!
isEnterprise
        "Answer whether the system is the enterprise edition."
    ^ServiceRegistry globalRegistry hasServiceNamed: #TeamVServices
!  
product
        "Answer the name of this product."
    ^self isEnterprise ifFalse: [ 'Visual Smalltalk' ] ifTrue: [ 'Visual Smalltalk Enterprise' ]!
platformIsWin32
        "Answer whether the OS platform is Win32."
    ^self platform = 'Win32'!
privateRemoveKey: aKey ifAbsent: aBlock
        "Private - Remove the global whose key is aKey."
    ^super removeKey: aKey ifAbsent: aBlock!   
unusedMemoryPrim: anInteger
        "Private - Perform a full garbage collection compaction. Answer
          an integer which is the number of bytes // 512 of unused memory
          available for object storage."
    <primitive: 112>!  
imageName
        "Private - Answers the name of the image.  For the runtime
         application, this is the name of the exe."
    ^SessionModel current imageName!  
versionNumbers
        "Answer the product version, as an Array of 3 Integers (major, minor, maintenance)."
    ^Array with: 3 with: 1 with: 0! 
rootClasses
        "Answer an OrderedCollection of all the classes
        that are subclasses of nil.  Classes are sorted in
        alphabetical order."
    | classes |
    classes := self select: [:x |
        x isClass and: [ x superclass isNil ] ].
    classes := classes asSortedCollection: Class sortBlock.
    ^classes!  
logError: aString
        "Private - log the error message aString to the error logging file."
    | aStream timeStamp |
    timeStamp := 'Error log timestamp ',
        Date today dayName, ' ', Date today printString, ' ',
        Time now printString.
    ( aStream := File pathName: SessionModel errorLogFileName )
        setToEnd;
        lineDelimiter: Cr;
        cr;
        cr;
        nextPutAll: timeStamp;
        cr;
        cr;
        nextPutAll: aString;
        close!  
exit
        "Private - Exit the session."
    SessionModel current exitSession!
platformIsOS2
        "Answer whether the OS platform is OS/2."
    ^self platform = 'OS/2'!
platform
        "Answer the name of the OS platform."
    ^( ServiceRegistry globalRegistry serviceNamed: #Platform )
        serviceNamed: #PlatformName!
launch
        "Private - Launch the session."
    ErrorCode := 0.
    Launching ifFalse: [ self recursiveMessage ].
    Launching := false.
    SessionModel current startupSession
!  
isRunTime
        "Private - Answer true if the current environment
         is the run-time system."
    ^SessionModel current isRunTime! 
printBuildInformation
        "Print information about the system build."
    | stream |
    stream := String new asStream.
    self printBuildInformationOn: stream.
    ^stream contents!  
largeIntegerAtOffset: anInteger
        "Answer the 8-byte signed integer at offset <anInteger> in the receiver.
        If the high bit is on a negative number is returned.
        Offsets are zero relative."
    | off total |
    off := anInteger + 1.
    total := 0.
    ( contents at: off + 7 ) >= 16r80
        ifTrue: [   "negative"
            7 to: 0 by: -1 do: [ :i |
                total := ( total bitShift: 8 ) + ( ( contents at: off + i ) bitXor: 16rFF ) ].
            total := ( total + 1 ) negated ]
        ifFalse: [
            7 to: 0 by: -1 do: [ :i |
            total := ( total bitShift: 8 ) + ( contents at: off + i ) ] ].
    ^total!   
queryProcAddr: aString
        "Answer the address of the function named aString in the
         receiver DLL, or an Integer error code (0)"
    | address |
    address := KernelLibrary16 getProcAddress: self procName: aString asParameter.
    ( address := ExternalAddress fromString: address ) asInteger = 0
        ifTrue: [ ^address asInteger ].
    ^address! 
volumeSeparator
    "Answer a string containing the characters used to separate the name of a drive from the rest of the path string."

    ^':'!  
isAssociation
        "Answer true if receiver is a kind of Association."
    ^false!   
return: anObject
        "Private - return to the method that caused Smalltalk
        to be reentered. An error has occurred, so the stack needs
        to be unwound, with any guaranteed execution blocks 
        evaluated."
    Process unwind!   
allFiles
    "Answer a collection of the files contained in the receiver or any of its subdirectories."

    | files |
    files := OrderedCollection new.
    self
        allFilesDo:
            [:file |
            files add: file].
    ^files!   
invisibleEnsure: terminationBlock
        "This method's function is identical to #ensure: but is used by
		system code for ensures that need not showup in walkbacks or in
		the debugger. If the definition of ensure: is modified, the corresponding
		changes must also be made to this method.

		Return the result of evaluating the receiver. Before returning,
        but after evaluating the receiver, evaluate the <terminationBlock>.
        The value of the termination block is ignored. If a block attempts
        to return from a method which (indirectly) invoked the receiver,
        either directly or indirectly, evaluate the termination block before
        returning from the enclosing method.
        Implementation Comments:  The receiver is evaluated by sending
        the receiver the message #value."
    | result |
    result := self
        setUnwind:
            [:aContext :returnValue |
            terminationBlock value.
            aContext return: returnValue].
    terminationBlock value.
    ^result! 
open: aString in: aDirectory 
        "Answer a File opened on a file 
         named aString in aDirectory." 

	^(aDirectory fileNamed: aString) open!   
isFile
        "Answer true if receiver is a kind of File."
    ^false! 
createFileNamed: fileName
    "Create a file named <fileName>."

	| fileHandle |
	fileHandle := FileHandle 
		open:  fileName asParameter
		access: GenericRead | GenericWrite
		share: 3
		create: CreateNew
		attributes: FileAttributeNormal.
	"recycle the fileHandle"
	fileHandle close.
	self osWorkaround.
	"set archive bit, because for network volumes Win32 doesn't set it"
	self changeModeOf: fileName to: 'a'!
dateSeparator
        "Answer the current system value for date separator."
    dateSeparator isNil
        ifTrue: [ dateSeparator := self queryNationalProfileString: 'sDate' default: '/' ].
    ^dateSeparator!   
isMethodDictionary
        "Answer true if receiver is a kind of MethodDictionary."
    ^false! 
mustBeSymbol: aSymbol
        "Report an error if aSymbol is not a Symbol."
    aSymbol isSymbol
        ifFalse: [^self error: 'Must be a Symbol']!   
new: ignoreArgument
        "Private - Answer an instance of the receiver.
         This method reports an error."
    ^self invalidMessage!   
intern: aDBString
        "Private - Answer a DoubleByteSymbol whose character
         sequence is the same as that of aDBString."
    | answer symbol |
    symbol := (super new: aDBString size) initContents: aDBString.
    (answer := SymbolTable symbolAt: symbol) == nil
        ifTrue: [
            answer := symbol.
            SymbolTable add: symbol].
    ^answer!  
timeFormat
        "Answer the current system value for time format."
    timeFormat isNil
        ifTrue: [ timeFormat := self queryNationalProfileInt: 'iTime' default: 0 ].
    ^timeFormat!   
= aSymbol
        "Answer true if the receiver object is the
         argument aSymbol, else answer false."
    <primitive: 110>!  
at: anInteger put: aCharacter
        "Private - replace the character in the receiver indexed by
         anInteger with the argument aCharacter.  This
         message is not valid for symbols, since they
         are not allowed to change."
    ^self invalidMessage!
initContents: aDBString
        "Private - initialize the receiver to contain
         the character sequence in aDBString."
    super
        replaceBytesFrom: 1 to: aDBString basicSize
        with: aDBString
        startingAt: 1!   
deepCopy
        "Answer a copy of the receiver with shallow
         copies of each instance variable.  Because
         symbols are unique (cannot be copied),
         answer the receiver."
     ^self!  
isDoubleByteSymbol
        "Answer true if receiver is an instance of class
         DoubleByteSymbol or one of its subclasses, else answer false."
    ^true! 
replace: count with: aCollection
        "Private - replace count elements of the receiver
         with elements of aCollection.  This
         message is not valid for symbols, since they
         are not allowed to change."
    ^self invalidMessage! 
replaceBytesFrom: byteStart
    to: byteStop
    with: aVariableByteObject
    startingAt: byteRepStart
        "Private - replace the bytes of the receiver at index
         positions start through stop with consecutive
         bytes of aVariableByteObject beginning at index
         position repStart.  This message is not valid
         for symbols, since they are not allowed to change."
    ^self invalidMessage!  
printOn: aStream
        "Append the ASCII representation of
         the receiver to aStream."
    aStream nextPutAll: self!  
replaceFrom: start to: stop withObject: aCharacter
        "Private - replace the characters of the receiver
         at index positions start through stop
         with aCharacter.  This message is not valid
         for symbols, since they are not allowed to change."
    ^self invalidMessage!  
containsDBCharacter
        " Answer whether the receiver contains any double-byte characters. "
    ^true! 
basicHash
        "Answer the integer hash
         of the receiver."
    ^self hash!  
replaceFrom: start
    to: stop
    with: aString
    startingAt: repStart
        "Private - replace the characters of the receiver at index
         positions start through stop with consecutive
         characters of aString beginning at index
         position repStart.  This message is not valid
         for symbols, since they are not allowed to change."
    ^self invalidMessage! 
species
        "Answer class DoubleByteString as the
         species of double-byte symbols."
    ^DoubleByteString! 
asString
        "Answer a String of the characters
         contained by the receiver."
    ^(DoubleByteString new: self size)
        replaceFrom: 1
        to: self size
        with: self!
asSymbol
        "Answer a Symbol for the receiver.  The receiver
         itself is answered since it is a Symbol."
    ^self!
replaceBytes: count with: aCollection
        "Private - replace count bytes of the receiver
         with bytes of aCollection.  aCollection
         may be either a Smalltalk byte object or
         an instance of ExternalAddress.  This
         message is not valid for symbols, since they
         are not allowed to change."
    ^self invalidMessage!
id: anInteger
        "Private - Set the id of the
         receiver to anInteger."
    <primitive: 76>!   
hash
        "Answer the integer hash
         of the receiver."
    <primitive: 93>!  
asCompactString
        " Answer the most compact string containing the
         characters of the receiver. "
    ^self asString! 
isSymbol
        "Private - Answer true if receiver is an instance of class
         Symbol or one of its subclasses, else answer false."
    ^true!   
shallowCopy
        "Answer a shallow copy of the receiver.
         Because symbols are unique (cannot be
         copied), answer the receiver."
    ^self! 
isRemovable
		"Answer whether the receiver is a removable drive."
    ^self getDriveType = DriveRemovable!  
volumes
        "Answer a list of the volumes that are currently accessible."
    | driveMap drives |
    drives := OrderedCollection new.
    driveMap := KernelLibrary getLogicalDrives.
    1 to: 26 do: [ :index |
        ( driveMap bitAt: index ) = 1
            ifTrue: [ drives add: ( String with: ( index + 64 ) asCharacter with: $: with: $\ ) ] ].
    ^drives collect: [ :dirName | self fromLocator: ( FileSystemPath fromString: dirName ) ]!   
entitiesDo: iterationBlock
	"Evaluate the <iterationBlock> once for each entity contained within the receiver. Each entity passed to the iteration block should be released by the iteration block if it is not retained in some way.
        Warnings:
        -   Modifications to the receiver's contents while executing this method may lead to missed or duplicated entities."

	self
		searchResultsDo:
			[:searchResult |
			iterationBlock value: searchResult entity]! 
return: anObject
        "Private - return from the receiver with the given value. Used
        to simulate explicit (^) returns from a contained block."
    ^self
        return: anObject
        numberOfArgs: self method argumentCount!
findFirst: aString
    "Private - search in the current directory for an entry
        (File or directory) matching the filespec aString; answer
        an Array containing the findData structure and a search handle
        if found, otherwise nil.  The caller must call #endSearch: with the
        search handle as an argument when done searching."

    | aFindData aSearchHandle error |
    aFindData := Win32FindData new.
    aSearchHandle := KernelLibrary findFirstFile: (self fileSystemLocator , aString) absolutePath asString asParameter findData: aFindData asParameter.
    aSearchHandle = InvalidHandleValue
        ifTrue:
            [error := KernelLibrary getLastError.
            "ignore the following errors:
            ERROR_FILE_NOT_FOUND
            ERROR_PATH_NOT_FOUND
            ERROR_INVALID_DRIVE
            ERROR_NO_MORE_FILES
            ERROR_NOT_READY"
            (#(2 3 15 18 21) includes: error)
                ifFalse: [self osNotification].
            ^nil].
    ^FileSearchResults
            directory: self
            searchHandle: aSearchHandle
            findData: aFindData! 
copyFileNamed: oldString to: newString
        "Copy the file oldString to newString. Fail if the file represented by <newString> already exists."

    ( KernelLibrary
        copyFile: oldString asParameter
        to: newString asParameter
        ifExists: true)
            ifFalse: [ ^self osError ]
!
validDrive
        "Answer true if the receiver's drive is valid."
    ^self volume isMounted!  
perform: aSymbol
        "Answer the result of sending a unary message to
         the receiver with selector aSymbol.  Report an
         error if the number of arguments expected by the
         selector is not zero."
	<primitive: 152>
	^self perform: aSymbol withArguments: #()!   
defaultAction
        "Display a notifier and then continue."
    ^SessionModel current isGui
        ifTrue: [ ( Smalltalk at: #MessageBox ) warning: self description ]
        ifFalse: [ true ]!  
open 
        "Open the file with a new file handle." 

    self isOpen ifTrue: [ self close ].
    self fileId: ( FileHandle open: self name in: self directory )!   
update: firstParameter with: secondParameter
        "An object on whom the receiver is dependent
         has changed.  The receiver updates its status
         accordingly (the default behavior is to do nothing).
         The argument firstParameter usually identifies the
         kind of update and the secondParameter is a unary
         message defined in the receiver protocol."!  
addr16To32: a16BitAddress
    ^self addr16To32: a16BitAddress size: 65536 fProtected: 1! 
addr16To32: a16BitAddress size: numBytes fProtected: flags
    <api: DLLTCaddr16To32 ulong ushort ulong ulongReturn>
    ^self invalidArgument! 
addr32To16: a32BitAddress
    <api: DLLTCaddr32To16 ulong ulongReturn>
    ^self invalidArgument!   
release16BitAddress: a16BitAddress
    <api: release16BitAddress ulong none>
    ^self invalidArgument! 
release32BitAddress: a32BitAddress
    <api: release32BitAddress ulong none>
    ^self invalidArgument! 
measurementSystem
        "Answer the current system value for measurement system.
         Answer 0 = metric
                      1 = english."
    measurementSystem isNil
        ifTrue: [ measurementSystem := self queryNationalProfileInt: 'iMeasure' default: 1 ].
    ^measurementSystem! 
topFrame
        "Answer the process index of the top stack frame."
    ^( endPosition - ( topFrame // self class frameBiasUnit ) + 1 ) - startPosition!
isRectangle
        "Answer true if receiver is a kind of Rectangle."
    ^false!   
subdirectories
    "Answer an OrderedCollection of arrays, where
     each Array contains the complete path name and
     the file name of a subdirectory of the receiver."

    | coll |
    coll := SortedCollection sortBlock: [:a :b | (a at: 2) <= (b at: 2)].
    self directoriesDo: [:dir |
        coll add: (Array with: dir pathName with: dir name)].
    ^coll asOrderedCollection! 
time1159
        "Answer the current system value
        for time string describing AM."
    time1159 isNil
        ifTrue: [ time1159 := self queryNationalProfileString: 's1159' default: 'AM' ].
    ^time1159!  
read: bytes into: aStringOrBuffer
    "Private - Read <bytes> bytes from the file into
    aStringOrBuffer."

    | long |
    long := ExternalLong fromInteger: 0.
    ( KernelLibrary
        readFile: self asParameter
        buffer: aStringOrBuffer
        bytesToRead: bytes
        bytesRead: long asParameter
        overlapped: nil )
            ifFalse: [ ^self osError ].
    ^long asInteger! 
reallocateMemory: newSize
        "Change the receiver's memory size to <newSize> bytes."
    | addressPtr handle |
    handle := KernelLibrary globalReAlloc: self memoryHandle 
		bytes: newSize 
		flag: GmemMoveable.
    addressPtr := KernelLibrary globalLock: handle.
    self longAtOffset: 0 put: addressPtr.
    self memoryHandleObject: ( ExternalGlobalHandle fromInteger: handle ).
    self memorySize: newSize.!
return: anObject numberOfArgs: argumentCount
        "Private - return from the receiver, the home context for
        a method with <argumentCount> arguments, with the given
        value. Used to simulate explicit (^) returns from a contained
        block."
    <primitive: 2>
    ^self primitiveFailed!  
isAbove: aNumber
        "Answer true if the receiver is higher on the screen
         than aNumber, else answer false."
    ^self < aNumber!  
propertyAt: aPropertyName ifAbsentPut: aBlock
    "Answer the value of the receiver's property identified by <aPropertyName>;
    if absent, put the result of evaluating <aBlock> at <aPropertyName> and
    answer the result."

    ^self propertyTable at: aPropertyName ifAbsentPut: aBlock!
allocate: blockAddress ofSize: numberOfBytes
        "Private - Allocate a block of numberOfBytes
         and initialize the blockAddress to point to it. Answer
         the result code.  If the request cannot be fulfilled,
         the blockAddress will = NullHandle."
    | result |
    result := KernelLibrary
        heapAlloc: self asParameter
        flags: 0
        size: numberOfBytes.
    result = 0 ifTrue: [ ^self osError ].
    blockAddress uLongAtOffset: 0 put: result.
    HeapUseCounts at: self put: ( HeapUseCounts at: self ) + 1.
    ^result!
asExternalLong
        "Answer the receiver as an ExternalLong."
    ^ExternalLong fromBytes: self! 
initialSize: initialSize
        "Private - Initialize the receiver."
    | result |
    result := KernelLibrary
        heapCreate: HeapNoSerialize
        initialSize: initialSize
        maximumSize: 0.
    result = 0 ifTrue: [ ^self osError ].
    self uLongAtOffset: 0 put: result!
dividend: aNumber
        "Signal that an attempt was make to divide the argument by zero."
    | ex |
    ex := self new.
    ex dividend: aNumber.
    ^ex signal! 
dividend
        "Answer the value of dividend."
    ^dividend! 
dividend: aValue
        "Private - Set the value of dividend."
    dividend := aValue! 
isResumable
        "Return true if this is a resumable exception."
    ^true!  
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^self isSingleByte!  
new: aCollection
        "Answer a new WildPattern with
         aCollection as the pattern to match."
    ^self basicNew build: aCollection!  
matchBackward: aCollection index: anInteger each: aOneArgumentBlock
        "Answer a Point representing the start and
         stop of the subcollection within aCollection
         that matches the receiver starting at index
         position anInteger.  Evaluate aOneArgumentBlock
         for each element of aCollection.  Answer nil if no match."
    | end aPoint index |
    end := 1.
    index := anInteger.
    index > aCollection size ifTrue: [^nil].
    patternCollection reverseDo: [ :pat |
        pat input isEmpty
            ifTrue: [aPoint := index @ (index + 1)]
            ifFalse: [
                (aPoint := pat matchBackward: aCollection index: index each: aOneArgumentBlock )
                    isNil ifTrue: [^nil]].
        end := aPoint y max: end.
        index := aPoint x - 1].
    (patternCollection at: 1)
        input isEmpty
            ifTrue: [aPoint x: 1].
    ^aPoint y: end!   
reset
        "Reset the receiver to start matching
         at the beginning of the pattern."
    state := 1.
    patternCollection do: [ :pattern | pattern reset]! 
match: anObject
        "Compare anObject against the pattern.
         If this object completes the matching of
         the pattern, evaluate the match block."
    state > patternCollection size
        ifFalse: [
            ((state == 1
                ifTrue: [first]
                ifFalse: [patternCollection at: state])
                    match: anObject)
                        ifTrue: [state := state + 1]
                        ifFalse: [^false]].
    state > patternCollection size
        ifTrue: [
            self reset.
            matchBlock value.
            ^true]
        ifFalse: [^false]!  
build: aCollection
        "Private - Initialize the receiver to
         match the pattern aCollection."
    | index |
    state := 1.
    input isNil
        ifTrue: [input := aCollection].
    matchBlock := [].
    patternCollection isNil
        ifTrue: [patternCollection := OrderedCollection new].
    index := aCollection indexOf: WildcardChar
        ifAbsent: [
        index := aCollection
            indexOf: (String with: WildcardChar)
            ifAbsent: [
                patternCollection add:
                    (Pattern new: aCollection).
                first := patternCollection at: 1.
                ^self]].
    patternCollection add:
        (Pattern new:
            (aCollection copyFrom: 1 to: index - 1)).
    first := patternCollection at: 1.
    self build:
        (aCollection
            copyFrom: index + 1
            to: aCollection size)! 
match: aCollection index: anInteger each: aOneArgumentBlock
        "Answer a Point representing the start and
         stop of the subcollection within aCollection
         that matches the receiver starting at index
         position anInteger.  Evaluate aOneArgumentBlock
         for each element of aCollection.  Answer nil if no match."
    | start aPoint index |
    start := aCollection size.
    index := anInteger.
    index > aCollection size ifTrue: [^nil].
    patternCollection do: [ :pat |
        pat input isEmpty
            ifTrue: [aPoint := index @ (index - 1)]
            ifFalse: [
                (aPoint := pat match: aCollection index: index each: aOneArgumentBlock )
                    isNil ifTrue: [^nil]].
        start := aPoint x min: start.
        index := aPoint y + 1].
    (patternCollection at: patternCollection size)
        input isEmpty
            ifTrue: [aPoint y: aCollection size].
    ^aPoint x: start! 
lastAccessTime
    "Answer a TimeStamp of the date and time at which the receiver was last accessed."

    ^self directory lastAccessTimeForEntityNamed: self name!
hInstance
        "Private - Answer the hInstance of the executing application"
    ^hInstanceExe!  
open: aString
in: aDirectory
action: anAction
fileSize: aFileSize
attribute: anAttr
flags: openFlags
mode: aMode
	"Answer a File opened on a file named aString in
        aDirectory with parameters anAction, aFileSize, anAttr,
        openFlags, and aMode.  See FileHandle
        open:in:action:fileSize:attribute:flags:mode: for more
        details."

	^(aDirectory fileNamed: aString)
			open: anAction
			fileSize: aFileSize
			attribute: anAttr
			flags: openFlags
			mode: aMode!  
creationTime: aTimeStamp
    "Set the TimeStamp of the date and time at which the receiver was created."

    | wasOpen fileTime |
    [ ( wasOpen := self isOpen ) ifFalse: [ self open ].
        fileTime := WinFileTime fromDate: aTimeStamp date time: aTimeStamp time.
        fileTime := WinFileTime fromLocalFileTime: fileTime.
        ( KernelLibrary
            setFileTime: self fileId
            creation: fileTime asParameter
            lastAccess: nil
            lastWrite: nil )
                ifFalse: [ ^self osError ] ] ensure: [ wasOpen ifFalse: [ self close ] ]!  
fromFlatAddress: aFlatAddress
        "Answer a 16:16 pointer from a 0:32 pointer.
        If the OS is Win95, the returned address must be
        explicitly released using #releaseSegmentedAddress."
    | segmentedAddress |
    segmentedAddress := OperatingSystem isWindows95
        ifTrue: [ ThunkWin95DLL current addr32To16: aFlatAddress asParameter ]
        ifFalse: [ ThunkWin32sDLL current addr32To16: aFlatAddress asParameter ].
    segmentedAddress := self fromInteger: segmentedAddress.
    segmentedAddress flatAddress: aFlatAddress.
    ^segmentedAddress!   
exponentCharacter
	"Answer the Character that precedes the exponent in the printed form for instances"

	^$s!  
numerator: numInteger denominator: denInteger scale: scale
	"Answer a new FixedPoint numInteger/denInteger."

	^self basicNew
		setNumerator: numInteger
		denominator: denInteger
		scale: scale!  
coerce: value precision: precision
	"Coerce the value to an instance of the receiver, if
    appropriate.  If the receiver supports the idea of
    controllable precision, such as FixedPoint numbers,
    then 'precision' defines how many digits should
    follow the decimal point."
	"This is a support routine for Number class>>readFrom:,
    and may change or disappear from release to release."

	^self
		numerator: value numerator
		denominator: value denominator
		scale: precision!   
coerce: value to: class precision: precision
	"Coerce the value to be an instance of 'class', or
    if the receiver is a concrete subclass of Number, it
    should coerce the number to itself.  'precision' is
    the number of digits after the decimal point that a
    FixedPoint number should print."
	"This is a support routine for Number class>>readFrom:,
    and may change or disappear from release to release."

	^self coerce: value precision: precision!
= aNumber
	"Answer whether the receiver is equal to the argument."

	^aNumber isNumber and: [
		aNumber class == self class
			ifTrue: [aNumber equalFromFixedPoint: self]
			ifFalse: [self retry: #= with: aNumber]]! 
reduced
	"Answer a FixedPoint determined by finding the greatest common
    divisor of the numerator and denominator of the receiver."

	| gcd |
	gcd := numerator gcd: denominator.
	gcd = 1
		ifTrue: [^self].
	^self class
		numerator: numerator // gcd
		denominator: denominator // gcd
		scale: self scale! 
+ aNumber
	"Answer the sum of the receiver and the argument, aNumber."

	^aNumber class == self class
		ifTrue: [aNumber sumFromFixedPoint: self]
		ifFalse: [self retry: #+ with: aNumber]! 
printOn: aStream
	"Append to the argument, aStream, the appropriate
    representation of the receiver.  The syntax is similar to
    Floats, but we never go to the exponential notation,
    and trailing zeros after the decimal point are always
    printed if they lie within the number's scale."

	| denom n quo rem |
	denom := 10 raisedToInteger: scale.
	n := numerator * denom + (denominator bitShift: -1) // denominator.
	numerator < 0
		ifTrue:
			[aStream nextPut: $-.
			n := n negated].
	quo := n // denom.
	rem := n \\ denom.
	quo printOn: aStream.
	aStream nextPut: $..
	scale
		timesRepeat:
			[rem := rem * 10.
			aStream nextPut: (Character digitValue: rem // denom).
			rem := rem \\ denom].
	aStream nextPut: self class exponentCharacter!  
asFixedPoint: newScale
    "Convert the receiver into a FixedPoint number with the stated scale."

	^self withScale: newScale! 
withScale: newScale
	"Answer an instance of the receiver class with the same numerator and
	denominator, and the specified <newScale>."

	^self class
		numerator: numerator
		denominator: denominator
		scale: newScale! 
> aNumber
	"Answer whether the receiver is greater than the argument."

	^aNumber class == self class
		ifTrue: [aNumber < self]
		ifFalse: [self retry: #> with: aNumber]!  
>= aNumber
	"Answer whether the receiver is greater than or equal to the argument."

	^aNumber class == self class
		ifTrue: [(self < aNumber) not]
		ifFalse: [self retry: #>= with: aNumber]!  
hash
    "Answer the integer hash value for the receiver."

	^numerator hash bitXor: denominator hash! 
denominator
	"Answer the denominator of the receiver."

	^denominator! 
lessFromFixedPoint: aFixedPoint
	"Answer whether aFixedPoint is less than the receiver."

	^aFixedPoint numerator * denominator < (numerator * aFixedPoint denominator)!   
- aNumber
	"Answer the difference between the receiver and the argument, aNumber."

	^aNumber class == self class
		ifTrue: [aNumber differenceFromFixedPoint: self]
		ifFalse: [self retry: #- with: aNumber]!  
negated
	"Answer a FixedPoint that is the negation of the receiver."

	^self class
		numerator: numerator negated
		denominator: denominator
		scale: scale!
equalFromFixedPoint: aFixedPoint
	"Answer whether aFixedPoint is equal to the receiver."

	^aFixedPoint numerator = numerator and: [aFixedPoint denominator = denominator]!
differenceFromFixedPoint: aFixedPoint
	"Answer the result of subtracting the receiver from aFixedPoint."

	denominator = aFixedPoint denominator
		ifTrue:
			[^(self species
				numerator: aFixedPoint numerator - numerator
				denominator: denominator
				scale: (self scale max: aFixedPoint scale)) reduced].
	^(self species numerator: aFixedPoint numerator * denominator - (numerator * aFixedPoint denominator)
		denominator: denominator * aFixedPoint denominator
		scale: (self scale max: aFixedPoint scale)) reduced!   
asRational
	"Answer a Rational number (Fraction or Integer) - representing the receiver."

	^Fraction numerator: numerator denominator: denominator!   
reciprocal
	"Answer 1 divided by the receiver."

	^self class
		numerator: denominator
		denominator: numerator
		scale: scale! 
roundedToScale
	"Answer a new instance of the receiver class whose value is rounded to
    the receiver's scale."

	| denom num |
	denom := 10 raisedToInteger: scale.
	num := numerator * denom + (denominator bitShift: -1) // denominator.
	^(self class
		numerator: num
		denominator: denom
		scale: scale) reduced!  
truncated
	"Answer an Integer nearest the receiver toward zero."

	^numerator quo: denominator!
quotientFromFixedPoint: aFixedPoint
	"Answer the result of dividing the aFixedPoint by the receiver."

	^(self species
		numerator: aFixedPoint numerator * denominator
		denominator: aFixedPoint denominator * numerator
		scale: (self scale max: aFixedPoint scale)) reduced!   
scale
	"Answer the scale of the receiver (the number of decimals)."

	^scale!  
truncatedToScale
	"Answer a new instance of the receiver class whose value is truncated to
    the receiver's scale."

	| denom num |
	denom := 10 raisedToInteger: scale.
	num := numerator * denom quo: denominator.
	^(self class
		numerator: num
		denominator: denom
		scale: scale) reduced! 
coerce: aNumber
	"Private - answer aNumber coerced to the same numeric class as the receiver."

	^aNumber asFixedPoint: scale! 
setNumerator: nInteger denominator: dInteger scale: pInteger
	"Initialize the instance variables. Fail if the denominator is zero."

	dInteger = 0
		ifTrue:
			[^self class
				raise: #divisionByZeroSignal
				receiver: nInteger
				selector: #/
				arg: dInteger
				errorString: 'Can''t create a FixedPoint with a zero denominator']
		ifFalse:
			[numerator := nInteger truncated.
			denominator := dInteger truncated abs.
			scale := pInteger truncated.
			dInteger < 0
				ifTrue:
					[ "keep sign in numerator"
					numerator := numerator negated]]! 
asFloat
	"Answer a new Float that represents the same value as does the receiver."

	^self asRational asFloat! 
numerator
	"Answer the numerator of the receiver."

	^numerator!   
sumFromFixedPoint: aFixedPoint
	"Answer the result of adding the receiver with aFixedPoint."

	denominator = aFixedPoint denominator
		ifTrue:
			[^(self species
				numerator: numerator + aFixedPoint numerator
				denominator: denominator
				scale: (self scale max: aFixedPoint scale)) reduced].
	^(self species
		numerator: numerator * aFixedPoint denominator + (aFixedPoint numerator * denominator)
		denominator: denominator * aFixedPoint denominator
		scale: (self scale max: aFixedPoint scale)) reduced!
/ aNumber
	"Answer the result of dividing receiver by the argument, aNumber."

	^aNumber class == self class
		ifTrue: [aNumber quotientFromFixedPoint: self]
		ifFalse: [self retry: #/ with: aNumber]! 
// aNumber
	"Answer the integer quotient after dividing
    the receiver by aNumber with truncation
    towards negative infinity."

	| answer quotient |
	quotient := self / aNumber.
	answer := quotient truncated.
	quotient < 0
		ifTrue:
			[answer = quotient
				ifFalse: [^answer - 1]].
	^answer!
productFromFixedPoint: aFixedPoint
	"Answer the result of multiplying the receiver with aFixedPoint."

	^(self species
		numerator: aFixedPoint numerator * numerator
		denominator: aFixedPoint denominator * denominator
		scale: (self scale max: aFixedPoint scale)) reduced!   
< aNumber
	"Answer whether the receiver is less than the argument."

	^aNumber class == self class
		ifTrue: [aNumber lessFromFixedPoint: self]
		ifFalse: [self retry: #< with: aNumber]!   
<= aNumber
	"Answer whether the receiver is less than or equal to the argument."

	^aNumber class == self class
		ifTrue: [(self > aNumber) not]
		ifFalse: [self retry: #<= with: aNumber]! 
generality
	"Answer the number representing the ordering of the receiver in the
    generality hierarchy.  Fractions should be coerced to FixedPoints,
    but FixedPoints should be coerced to Floats."

	^70!  
* aNumber
	"Answer the result of multiplying the receiver by the argument, aNumber."

	^aNumber class == self class
		ifTrue: [aNumber productFromFixedPoint: self]
		ifFalse: [self retry: #* with: aNumber]!   
retry: selector with: argument
	"Private - retry the binary arithmetic operation specified by <selector>
	with specified argument coerced to the same numeric type as the receiver."

	^argument generality < self generality
		ifTrue: [self perform: selector with: (self coerce: argument)]
		ifFalse: [(argument coerce: self) perform: selector with: argument]!   
renameAs: newName
    "Change the name of the receiver to be the <newName>."

    | newLocator |
    newLocator := self fileSystemLocator parentPath , newName.
    self class 
        move: self absolutePath asString
        to: newLocator absolutePath asString.
    self fileSystemLocator: newLocator!
defaultIconSize
        "Answer the default size (a Point) of an icon."
    ^( self getSystemValue: SystemValueIconWidth )
        @ ( self getSystemValue: SystemValueIconHeight )!   
when: eventName send: selector to: anObject
        "Form an action with <anObject> as the receiver and
        a <selector> as the message selector and append
        it to the actions list for the event named <eventName>."
   | arguments |
    selector isSymbol
        ifFalse: [^self errorBadSelector: selector].
    arguments := Array new: (Message numberOfArgumentsFor: selector).
    self
        when: eventName
        evaluate:
            (Message
                receiver: anObject
                selector: selector
                arguments: arguments)! 
changed: aspect with: firstParameter
        "Something related to the dependents of the receiver
        has changed.  Send the message #update:with: to all of
        the receiver's dependents with the <aspect> as the first
        argument and the <firstParameter> as the second
        argument.  The aspect is intended to inform the dependents
        of the nature of the change. The parameter may be needed
        by the dependents in order to respond to the change."
    self
        updateEvent: self changedEventName
        selector: #update:with:
        arguments: (Array with: aspect with: firstParameter)!  
readInto: aString atPosition: anInteger
        "Read a page or less (if at end of file)
         at position anInteger modulo aString size
         from the receiver file into aString.
         Answer the number bytes read."
    ^self readInto: aString
        atPage: anInteger // aString size
        pageSize: aString size!
writeFrom: aString toPosition: anInteger for: size
        "Write size bytes of aString to the receiver
         file at position anInteger modulo aString size."
    ^self writeFrom: aString
        toPage: anInteger // aString size
        for: size
        pageSize: aString size!  
osError: aSystemErrorCode
    "Signal the HostOSError exception with <aSystemErrorCode>."

    ^self class osError: aSystemErrorCode!  
isMessage
        "Answer whether the receiver is a kind of Message."
    ^false!   
creationTimeForEntityNamed: aString
	"Private - Answer the creationTime (Date and Time) for the entity in the receiver named <aString>"

	self
		searchResultsDo:
			[:searchResult |
			(searchResult entityName equalsIgnoreCase: aString)
				ifTrue: [^searchResult creationTime]].
	^nil!
position
    "Private - Answer the current file position."
    | pos |
    ( pos := KernelLibrary
        setFilePointer: self asParameter
        offset: 0
        offsetHigh: ( ExternalLong fromInteger: 0 ) asParameter
        move: FileCurrent ) = 16rFFFFFFFF
            ifTrue: [ ^self osError ]
            ifFalse: [ ^pos ]!  
makeDeletedClass
    "Private - Convert the receiver into a deleted class.
    Redefine the class to know about all of its inherited
    instance variables so that if a superclass changes shape,
    the state of the instance will be preserved."

    | mda md allClassInstVarNames class isDeletedClassMethod |
    self class newNameSymbol: ('Deleted ' , self symbol) asSymbol.
    md := Object class methodDictionary fastCopy.
    isDeletedClassMethod := (Object compiledMethodAt: #notNil) copy.
    isDeletedClassMethod
        selector: #isDeletedClass;
        primitive: nil;
        classField: self class;
        sourceObject: nil.
    md at: #isDeletedClass put: isDeletedClassMethod.
    mda := self class methodDictionaries.
    md classField: self class.
    mda at: 1 put: md.
    mda at: 2 put: Object class methodDictionaries.
    3 to: mda size do: [:index | mda at: index put: #()].
    class := self class.
    allClassInstVarNames :=  class instVarNames.
    [class := class superclass.
    class == Class]
        whileFalse: [allClassInstVarNames := class instVarNames , allClassInstVarNames].
    self class stashInstVarNames: allClassInstVarNames.
    self class superclass: Object class.

    self newNameSymbol: ('Deleted ' , self symbol) asSymbol.
    mda := self methodDictionaries.
    md := Object methodDictionary fastCopy.
    md classField: self.
    mda at: 1 put: md.
    2 to: mda size do: [:index | mda at: index put: #()].
    self stashInstVarNames: self allInstVarNames.
    self superclass: Object!  
isRamdisk
		"Answer whether the receiver is a Ramdisk drive."
    ^self getDriveType = DriveRamdisk!
renameAs: newName
    "Change the name of the receiver to be the <newName>."

    | newLocator |
    newLocator := self fileSystemLocator parentPath , newName.
    self class 
        move: self absolutePath asString
        to: newLocator absolutePath asString.
    self fileSystemLocator: newLocator!
startingSession
	"Private - Starting a session. Default is do nothing."

	^self!   
current
        "Answer the current single instance of the receiver class."
    ^NationalLanguage!  
current: aNationalLanguageSupport
        "Private - set the current single instance of the receiver class."
    NationalLanguage := aNationalLanguageSupport!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
startUp
        "Private - initialize a global instance of the receiver class."
    | old new |
    old := self current.
    new := self new.
    ( old codePage = new codePage and: [ old language = new language ] ) ifTrue: [
        new allLowerCase: old allLowerCase.
        new allUpperCase: old allUpperCase ].
    self current: new! 
isInteger
        "Answer true if receiver is a kind of Integer."
    ^false!   
next
        "Answer the next object accessible by the receiver
         and advance the stream position.  Report an error
         if the receiver stream is positioned at end."
    <primitive: 65>
    position < readLimit
        ifTrue: [
            position := position + 1.
            ^self collection at: position]
        ifFalse: [
            ^self error: 'read beyond end of stream']! 
contents
        "Answer the collection over which
         the receiver is streaming."
    ^self collection copyFrom: 1 to: readLimit!
setLimits
        "Private - Initialize the stream size and position."
    position := 0.
    readLimit := collection size!
pathName
        "Answer a string that contains the entire path
         name (drive:\path\fileName.ext)."

	^self absolutePath asString! 
canTriggerEvent: eventName
        "Answer <true> if the receiver can trigger an event
        named <eventName>."
    ^self class canTriggerEvent: eventName! 
on: exception do: handlerBlock
        "During the evaluation of the receiver, establish an
        exception handler that will execute the handlerBlock
        if the argument exception occurs."

    ^ExceptionHandler
        handle: exception
        with: handlerBlock
        during: self! 
wNetCancelConnection: lpszName fForce: fForce
	<api: WNetCancelConnectionA struct boolean ulongReturn>
	^self invalidArgument!  
wNetAddConnection: lpszRemoteName password: lpszPassword localName: lpszLocalName
	<api: WNetAddConnectionA struct struct struct ulongReturn>
	^self invalidArgument!   
setActionList: actionSequence forEvent: eventName
        "Set the list of actions that get evaluated when
        the event named <eventName> is triggered by
        the receiver to <actionSequence>."
    | action |
    action := actionSequence asMinimalRepresentation.
    action == nil
        ifTrue: [ self removeActionsForEvent: eventName ]
        ifFalse: [
            self eventTableForEdit
                at: eventName asSymbol
                put: action ]! 
osError
        "Create a walkback window describing an error condition
        that was returned from the host operating system.  Ask
        the operating system for the last error that occurred."
    ^self osError: self lastOsError!   
isDirectory
	"Answer true if the search resulted in finding a directory"

	 ^self findData dwFileAttributes & FileAttributeDirectory ~= 0! 
updateEvent: eventName selector: selector arguments: argumentList
        "Private - trigger the event named <eventName> using <selector>
        as the message selector and the elements of the <argumentList>
        as the arguments."
    (self eventTable at: eventName asSymbol ifAbsent: [^nil])
        asActionSequence
            evaluateWithSelector: selector
            withArguments: argumentList! 
libraryOrdinal
    "Obsolete - Answer the ordinal number of library the receiver is contained in.
    Zero indicates the receiver is not in a library (i.e., it is in the image)."

    ^self smalltalkLibraryOrdinal!
receiver: anObject selector: aSymbol
        "Set the receiver to anObject and selector to aSymbol."
    ^self new receiver: anObject; selector: aSymbol!   
numberOfArgumentsFor: aSelector
        "Answer the number of arguments required by a message whose
        selector is <aSelector>, assuming <aSelector> is a legal
        method selector."
    aSelector first isLetter
        ifTrue: [ ^aSelector occurrencesOf: $: ].
   ( #(
         #= #~= #== #~~ #> #>= #< #<=   " comparison operations "
        #+ #- #*  #/ #\\  #//                    " arithmetic operations "
       #& #|                                 " logical operations "
       #@ #,                                " miscellaneous "
        ) includes: aSelector asSymbol)
            ifTrue: [^1].
    ^aSelector occurrencesOf: $:! 
receiver: receiver selector: selector
        "Answer an instance of the receiver representing a message
        sent to the <receiver> with the given message <selector> and
        no arguments."
    ^self new
        receiver: receiver
        selector: selector
        arguments: (Array new: (self numberOfArgumentsFor: selector))!
receiver: receiver selector: selector arguments: argumentArray
        "Answer an instance of the receiver representing a message
        sent to the <receiver> with the given message <selector>
        and the arguments in the <argumentArray>."
    ^self new
        receiver: receiver
        selector: selector
        arguments: argumentArray!
= aMessage
        "Answer whether the receiver and <aMessage> are equal.
        Two objects are equal if they have the same behavior
        at the current point in time.  Objects that are equal at one
        time may not be equal at some later time.
        Invariants: two objects that compare equal must have equal
        hash values."
    ^(self == aMessage)
    or: [self class == aMessage class
        and: [self receiver == aMessage receiver
        and: [self selector == aMessage selector
        and: [self arguments = aMessage arguments
        and: [self resultAction = aMessage resultAction]]]]]!
numberOfArguments
        "Private - answer the number of arguments required
        to evaluate the receiver."
    ^self class numberOfArgumentsFor: self selector!   
arguments: anArray
        "Set the arguments array for the message."
    self validateArguments: anArray for: self selector.
    super arguments: anArray.!   
evaluateWithArguments: evaluationArguments
        "Answer the result of evaluating the receiver with
        the given evaluationArguments."
    | result |
    result := receiver
        perform: selector
        withArguments: ( self collectArguments: evaluationArguments ).
    resultAction notNil
        ifTrue: [ result := resultAction evaluateWithArguments: ( Array with: result ) ].
    ^result!  
forwardResultSending: messageName to: anObject
        "Send messageName to anObject with the result of
        the receiver when the receiver has been evaluated."
    self forwardResultUsing:
        (self class
            receiver: anObject
            selector: messageName asSymbol).!   
collectArguments: evaluationArguments
        "Private - collect the action arguments by executing the
        argument collectors with the current evaluation values."
    ^self arguments collect: [ :anAction |
        anAction evaluateWithArguments: evaluationArguments]!  
receiver: anObject selector: aSymbol arguments: anArray
        "Set the message receiver, selector, and arguments."
    self validateArguments: anArray for: aSymbol.
    super receiver: anObject selector: aSymbol arguments: anArray!  
argumentAt: argumentIndex putInput: inputIndex
        "Set the argumentIndex-th argument value
        when the receiver is evaluated to
        the inputIndex-th input value."
    self argumentAt: argumentIndex put:
        (CollectionAccessor for: inputIndex).! 
argumentAt: argumentIndex send: messageName to: anObject
        "Set the argumentIndex-th argument value when the receiver
        is evaluated to the result of evaluating the message <messageName>
        to <anObject> using the evaluation arguments."
    self
        argumentAt: argumentIndex
        put: (self class
            receiver: anObject
            selector: messageName asSymbol).!
argumentAt: argumentIndex
    send: messageName
    to: anObject
    withArguments: anArray
        "Set the argumentIndex-th argument value when the receiver is
        evaluated to the result of evaluating the message <messageName>
        to <anObject> using the evaluation arguments and <anArray>."
    self
        argumentAt: argumentIndex
        put: (self class
            receiver: anObject
            selector: messageName asSymbol
            arguments: anArray).!
forwardResultUsing: anAction
        "Specify an action which will be evaluated with the result of
        the receiver when the receiver has been evaluated."
    self resultAction: anAction.!   
allocateArguments
        "Private - allocate properly sized arguments array."
   super arguments:  (Array new: self numberOfArguments).!   
evaluate
        "Answer the result of evaluating the receiver."
    ^self evaluateWithArguments: #()!  
resultAction
        "Answer the action which is evaluated with the
        result of the receiver when it has been evaluated."
    ^resultAction! 
perform
        "Perform the expression."
    ^self evaluateWithArguments: #()! 
resultAction: anAction
        "Specify the action which is evaluated with the
        result of the receiver when it has been evaluated."
    resultAction := anAction.!  
validateArguments: anArray for: aSelector
        "Private - verify that anArray is the right size for aSelector."
    (anArray size = (self class numberOfArgumentsFor: aSelector))
        ifFalse: [self error: 'wrong number of arguments'].!  
hash
        "Answer an integer hash value for the receiver.
        Invariants: the hash value of an object must be constant over
        time; two objects that compare equal must have equal hash
        values."
     ^self receiver hash
        + self selector hash
        + self arguments hash
        + self resultAction hash!   
selector: aSymbol
        "Set the message selector."
    self arguments isNil
        ifTrue: [
            super selector: aSymbol.
            self allocateArguments ]
        ifFalse: [
            self validateArguments: self arguments for: aSymbol.
            super selector: aSymbol ].!
= aMessage
        "Answer <true> if the receiver and <aMessage> are equal.
        Two objects are equal if they have the same behavior at the
        current point in time. Objects that are equal at one time may
        not be equal at some later time.
        Invariants: two objects that compare equal must have equal
        hash values."
    ^self == aMessage
        or: [self class == aMessage class
            and: [self receiver == aMessage receiver
            and: [self selector == aMessage selector
            and: [self arguments = aMessage arguments]]]]!   
arguments
        "Answer the arguments array for the message."
    ^arguments! 
arguments: anArray
        "Set the arguments array for the message."
    arguments := anArray! 
evaluateWithArguments: anArray
        "Answer the result of sending the message represented by
        the receiver."
    ^self receiver
        perform: self selector
        withArguments: (self collectArguments: anArray)!
isMessage
        "Answer whether the receiver is a kind of Message."
    ^true!
evaluateFor: anObject
        "Evaluate the receiver, passing anObject as the evaluation argument."
    ^self evaluateWithArguments: ( Array with: anObject )!  
printOn: aStream
        "Append a text representation of the receiver to aStream."
    aStream nextPutAll: self class name,
        '(', receiver class printString, '>>',
        selector printString, ')'!
collectArguments: evaluationArguments
        "Private - answer the action arguments with which to evaluate
        the receiver, collecting from the <evaluationArguments>
        and the predefined arguments in the receiver. "
    | predefinedArgs |
    predefinedArgs := self arguments.
    ^(evaluationArguments size = predefinedArgs size)
        ifTrue: [evaluationArguments]
        ifFalse:
            [( predefinedArgs isNil
                ifTrue: [ predefinedArgs := Array new: (self class numberOfArgumentsFor: selector) ]
                ifFalse: [predefinedArgs copy] )
                    replaceFrom: 1
                    to: (evaluationArguments size min: predefinedArgs size)
                    with: evaluationArguments
                    startingAt: 1]!   
receiver: anObject selector: aSymbol arguments: anArray
        "Set the recevier to anObject, selector to aSymbol,
         and arguments to anArray."
    receiver := anObject.
    selector := aSymbol.
    arguments := anArray.!
value: value1 value: value2
        "Answer the result of evaluating the receiver with two arguments. "
    arguments at: 1 put: value1.
    arguments at: 2 put: value2.
    ^self perform!  
argumentAt: anIndex put: anObject
        "Set the argument at position <anIndex> to <anObject>."
    self arguments at: anIndex put: anObject! 
argumentAt: anIndex
        "Answer the argument at position <anIndex>."
    ^self arguments at: anIndex!   
evaluate
        "Answer the result of sending the message represented by the receiver."
    ^self perform! 
receiver
        "Answer the receiver of the message."
    ^receiver!   
perform
        "Answer the result of sending the message represented by the receiver."
    ^self receiver
        perform: self selector
        withArguments: self arguments!  
receiver: anObject
        "Set the receiver to anObject."
    receiver := anObject!
selector
        "Answer the message selector."
    ^selector!  
hash
        "Answer an integer hash value for the receiver. Invariants:
        the hash value of an object must be constant over time;
        two objects that compare equal must have equal hash values."
     ^self receiver hash + self selector hash + self arguments hash!
selector: aSymbol
        "Set the message selector."
    selector := aSymbol!  
setEndOfFileTo: anInteger
    "Truncate or extend the end-of-file position of the receiver."

    self position: anInteger.
    ( KernelLibrary setEndOfFile: self asParameter )
        ifFalse: [ ^self osError ]! 
byteSize
        "Answer the number of bytes allocated for the receiver."
	^self size!  
fileId: aFileHandle
        "Private - Set the receiver 
         file handle to aHandle." 

	fileId := aFileHandle!  
fileId
        "Answer the file handle 
         used to access the receiver." 

	^fileId!
isFile
    "Answer <true> if the receiver is a file."

    ^true!  
baseName
    "Answer the base portion of the name of the receiver."

    | name sep index |
    name := self fileSystemLocator entityName.
    sep := self fileSystemLocator class extensionSeparator.
    index := name indexOfCollection: sep.
    ^index = 0
        ifTrue: [name]
        ifFalse: [name copyFrom: 1 to: index - 1]!
bytesAllocated
        "Answer the amount of actual disk space occupied by the receiver."

        | allocSize |
    allocSize := self volume allocationUnit.
    ^((self byteSize + allocSize - 1) // allocSize) * allocSize!   
copyTo: targetContainer
as: newName
    "Copy the receiver and anything it contains to the <targetContainer>, renaming it to the <newName>."

   ^targetContainer copyFile: self as: newName! 
moveTo: targetContainer
as: newName
    "Move the receiver and anything it contains to the <targetContainer>, renaming it to the <newName>."

    targetContainer moveFile: self as: newName! 
extension
    "Answer the extension portion of the name of the receiver."

    | name sep index |
    name := self fileSystemLocator entityName.
    sep := self fileSystemLocator class extensionSeparator.
    index := name indexOfCollection: sep.
    ^index = 0
        ifTrue: ['']
        ifFalse: [name copyFrom: index + 1 to: name size]!
isFixedObject
        "Answer whether the receiver is a fixed object."
    ^true!   
errorBadEvent: eventName
        "Private - signal an unsupported event."
    ^UnregisteredEvent signal: 'Event not supported: ', eventName!
countryName
        "Answer the current system value for country name."
    countryName isNil
        ifTrue: [ countryName := self queryNationalProfileString: 'sCountry' default: 'United States' ].
    ^countryName!  
infoCopy
        "return a copy containing essential information that describes instances"
	| c |
	c := self objectShallowCopy.
	c subclasses: Array new.
	^c!   
pathName
        "Answer a String representing the path name 
         of the receiver directory (drive letter not 
         included)." 

	self isDirectoryRelative ifTrue: [^self absolutePath pathName].
	^self asStringWithVolume: false!   
defaultAction
        "Log the error in ERROR.LOG."
    | crString |
    crString := Stream crString.
    [ Smalltalk logError: self description ]
        on: self class
        do: [ "ignore any errors that would cause recursion" ]!   
doNotNotifyWhenFinalizable: anObject
	"The receiver no longer wants to receive the #finalize: message when <anObject> is not referenced."

	| notifier list |
	notifier := SystemWeakRegistries current notifier.
	list := notifier at: anObject ifAbsent: [].
	list isNil ifTrue: [ ^self ].
	list := list reject: [:object | object == self ].
	list isEmpty ifTrue: [ ^notifier remove: anObject ].
	notifier at: anObject put: list.!
isKindOf: aClass
        "Answer true if receiver is an instance of aClass
         or one of its subclasses, else answer false."
    ^self class inheritsFrom: aClass!
asInteger
        "Answer the integer conversion of the receiver;
         the receiver is expected to be a sequence of
         digits with optional leading minus sign."
    | answer char |
    answer := 0.
    self size = 0 ifTrue: [^answer].
    (self at: 1) = $-
        ifTrue: [
            ^(self copyFrom: 2 to: self size)
                asInteger negated].
    (self at: 1) = $+
        ifTrue: [
           ^(self copyFrom: 2 to: self size)
                asInteger ].
    1 to: self size do: [ :index |
        (char := self at: index) isDigit
            ifFalse: [^answer].
        answer := answer * 10 + char digitValue].
    ^answer!
objectEventTable: aDictionary
    "Private - Set the eventTable for the receiver."

    ^SystemWeakRegistries current events at: self put: aDictionary!
alreadyRunning
        "Answer true if any Smalltalk application is already running."
    ^self alreadyRunning: 'Visual Smalltalk'! 
triggerEvent: eventName withArguments: argumentList
        "Trigger the event <eventName> using the
        elements of the <argumentList> as the arguments.
        Answer the value returned by the most recently
        defined event handler action."
    ^(self actionForEvent: eventName)
        evaluateWithArguments: argumentList!  
doesNotUnderstand: message
        "Sent to the receiver by the virtual machine when the <message>
        sent to the receiver was not implemented by the receiver."
    ^MessageNotUnderstood defaultClass message: message! 
isFixed
		"Answer whether the receiver is a fixed (disk) drive."
    ^self getDriveType = DriveFixed!   
startUp
        "Private - initialize global DLL handles on image startUp."
    self allSubclasses do: [ :dllClass | dllClass current: nil ].
    KernelLibrary := OperatingSystem kernelHandle.
    KernelLibrary setErrorMode: SemFailcriticalerrors | SemNoopenfileerrorbox.
    UserLibrary := UserDLL getHandle.
    VirtualMachineLibrary := VirtualMachineExe open!  
unicodeStringAsAscii: aUnicodeBuffer length: nChars
        " Private - Answer a String containing the first <nChars> characters
        of the Unicode string in <aUnicodeBuffer>."
    | aString result |
    aString := String new: nChars * 2.  "Make it twice the size, in case all the characters are double-byte."
    result := KernelLibrary
        wideCharToMultiByteCp: 0 "CP_ACP"
        flags: 0
        lpwstr: aUnicodeBuffer
        cchwstr: nChars * 2
        lpstr: aString
        cchlpstr: aString size
        default: nil
        defaultUsed: nil.
    ^aString trimNullTerminator asNormalizedString!
current
        "Answer the current date and time as a TimeStamp."
    | systemTime |
    systemTime := WinSystemTime new.
    KernelLibrary getLocalTime: systemTime asParameter.
    ^self date: systemTime asDate time: systemTime asTime!
asExistingSymbolOrNil
	    "If a symbol already exists that represents the same string
        as the receiver, return the existing symbol.  Otherwise return nil"
	 ^self containsDBCharacter
        ifTrue: [DoubleByteSymbol existingSymbolFor: self]
        ifFalse: [Symbol existingSymbolFor: self asMixedString]
	!
open: aString in: aDirectory attribute: anAttr mode: openMode
        "Answer a file handle for an opened file named aString in aDirectory
        whose creation attribute is anAttr and open access mode is openMode."

    ^self open: aString
        in: aDirectory
        action: ( ExternalBuffer new: 2 ) asParameter
        fileSize: 0
        attribute: anAttr
        flags: OfRead | OfCreate
        mode: openMode!   
open: aString
    in: aDirectory
    action: anAction
    fileSize: aFileSize
    attribute: anAttr
    flags: openFlags
    mode: openMode
        "Open the specified file with the specified parameters, and
         answer its FileHandle.  Parameters are as follows, where
         the relevant constants are defined in FileConstants:

            anAction - for output, currently not used.
            aFileSize - in bytes, currently not used.
            anAttr - FileNormal, FileReadonly, FileHidden, FileSystem, FileArchived (same as FileNormal)
            openFlags - FileCreate, FileOpen, FileTruncate
            openMode -
                OpenAccessReadonly, OpenAccessReadwrite, OpenAccessWriteonly
                OpenShareDenynone, OpenShareDenyread,
                OpenShareDenyreadwrite, OpenShareDenywrite."
    | aHandle answer fileName buf |
    fileName := ( aDirectory fullDirName, aString ) asParameter.
    ( self isThere: fileName )
        ifTrue: [
            buf := WinOfstruct new.
            answer := KernelLibrary
                openFile: fileName
                reopenBuffer: buf asParameter
                style: openMode.
            answer = -1 ifTrue: [
                self osWarning.
                buf nErrCode = 32
                    ifTrue: [
                        self cleanHandles
                            ifTrue: [  "cleanup handles and retry"
                                ( answer := KernelLibrary
                                    openFile: fileName
                                    reopenBuffer: buf asParameter
                                    style: openMode ) = -1
                                        ifTrue: [ ^self osError ] ]
                            ifFalse: [ ^self osError ] ]
                    ifFalse: [
                        [ buf nErrCode = 4 and: [ MaxHandles < 255 ] ] "out of file handles, bump and try again"
                            whileTrue: [
                                self setLimit: ( ( MaxHandles + 20 ) min: 255 ).
                                ^self open: aString
                                    in: aDirectory
                                    action: anAction
                                    fileSize: aFileSize
                                    attribute: anAttr
                                    flags: openFlags
                                    mode: openMode ].
                        ^self osError ] ] ]
        ifFalse: [
            ( openFlags bitAnd: OfCreate ) ~= 0
                ifTrue: [
                    ( answer := KernelLibrary
                        lcreat: fileName
                        style: anAttr ) < 0
                            ifTrue: [
                                MaxHandles < 255 "maybe out of file handles, bump and try again"
                                    ifTrue: [
                                        self setLimit: ( ( MaxHandles + 20 ) min: 255 ).
                                        answer := KernelLibrary
                                            lcreat: fileName
                                            style: anAttr ].
                                answer < 0 ifTrue: [ ^self error: 'file creation failed' ] ]
                            ifFalse: [ "reopen in the right mode"
                                ( KernelLibrary closeHandle: answer )
                                    ifFalse: [ ^self osError ].
                                answer := KernelLibrary
                                    lopen: fileName
                                    style: openMode ] ]
                ifFalse: [ ^self error: 'file open error' ] ].

    aHandle := self fromInteger: answer.
    FileHandles isNil ifTrue: [ FileHandles := Set new ].
    FileHandles add: aHandle.
    ^aHandle!
perform: aSymbol with: firstObject with: secondObject
        "Answer the result of sending a keyword message to
         the receiver with selector aSymbol and arguments
         firstObject and secondObject.  Report an error if
         the number of arguments expected by the selector
         is not two."
	<primitive: 159>
	^self perform: aSymbol withArguments: ( Array with: firstObject with: secondObject )! 
pageSize: anInteger 
        "Set the page size to anInteger 
         for the files opened from now on." 
    FilePageSize := anInteger!  
negativeCurrencyFormat
        "Answer the current system value for negative currency format.
         Answer 0 = ($1)
                      1 = -$1
                      2 = $-1
                      3 = $1-
                      4 = (1$)
                      5 = -1$
                      6 = 1-$
                      7 = 1$-."
    negativeCurrencyFormat isNil
        ifTrue: [ negativeCurrencyFormat := self queryNationalProfileInt: 'iNegCurr' default: 0 ].
    ^negativeCurrencyFormat!  
formatted: filterString
    "Answer a collection of arrays of file information
         for the receiver directory, filtered using filterString,
         e.g. '*.txt'.  Each array has four entries:
         file name, size, date/time and attributes."

    | answer anArray timeStamp timeStream |
    answer := OrderedCollection new.
    self
        searchResultsDo:
            [:searchResult |
            searchResult isFile
                ifTrue:
                    [timeStamp := searchResult lastWriteTime.
                    timeStream := WriteStream on: String new.
                    timeStream
                        nextPutAll: (timeStamp date) printString;
                        space;
                        nextPutAll: (timeStamp time) printString.
                    anArray := Array new: 5.
                    anArray
                        at: 1 put: searchResult entityName;
                        at: 2 put: searchResult fileSize;
                        at: 3 put: timeStream contents;
                        at: 4 put: searchResult fileAttributes;
                        at: 5 put: "This entry is only used to sort by date"
                            ((timeStamp date) asSeconds + (timeStamp time) asSeconds).
                    answer add: anArray]]
        onPattern: filterString.
    ^answer! 
constructEventsTriggered
        "Private - answer all the events which can be triggered
         by instances of the receiver. "
    ^super constructEventsTriggered
        add: #aboutToSaveImage ;
        add: #device:change: ;  "first argument is device type, second is event type"
        add: #displayChanged ;  "display resolution changed"
        add: #libraryBound: ;    "argument is the SmalltalkLibrary object itself"
        add: #libraryUnbind: ;  "argument is the SmalltalkLibrary object itself"
        add: #libraryUnbound: ;  "argument is the name of the library"
        add: #objectLibraryBound: ;
        add: #powerChange: ;  "argument is the type of power event"
        add: #savedImage ;
        add: #startup ;
        add: #startUpApplication ;
        add: #started ;
        add: #shutdown ;
        yourself! 
nextFrameFrom: processIndex
        "Private - Answer the process index of the nextFrame entry from
        the stack frame at processIndex."
    ^processIndex + ( ( self at: processIndex ) // self class frameBiasUnit )!   
endByte
        "Answer the size in bytes of the file identified by the receiver."
    | size |
    size := KernelLibrary getFileSize: self asParameter fileSizeHigh: nil.
    ( size = 16rFFFFFFFF and: [ KernelLibrary getLastError ~= 0 ] )
        ifTrue: [ ^self osError ].
    ^size!
remove: aString
        "Remove the directory with the path name aString."

    ( KernelLibrary removeDirectory: aString asParameter )
        ifFalse: [ ^self osError ]!
lastAccessTime
    "Answer a TimeStamp of the date and time at which the receiver was last accessed."

    ^self directory lastAccessTimeForEntityNamed: self name!
string: aString1 isLessThan: aString2
        "Answer true if aString1 is before aString2
        in the current sort sequence, else answer false.
        The comparison is not case sensitive."
    ^(self compareStringi: aString1 withString: aString2) < 0!  
removeDependent: anObject
        "Remove <anObject> as a dependent of the receiver."
    self
        removeActionsWithReceiver: anObject
        forEvent: self changedEventName!   
releaseEventTable
        "Private - break all connections to event handlers."
    EventHandlers removeKey: self ifAbsent: []!  
readStream
   "Answer a ReadStream streaming over the contents of the receiver."

	| copy |
	copy := self copy.
	copy fileSystemLocator: self fileSystemLocator absolutePath.
	^FileStream on: copy openReadOnly!   
error: errorMessage
        "Signal an exception indicating that an error has occurred."
   ^Error signal: errorMessage!
asUnicodeStringNullTerminated: aNullTerminatorBoolean
        "Private - Answer a Unicode copy of the receiver with or without
        a NULL terminator appended as specified by <aNullTerminatorBoolean>. "
    | sizeInBytes unicodeBuffer nChars |
    sizeInBytes := self size * 2.
    aNullTerminatorBoolean
        ifTrue: [ sizeInBytes := sizeInBytes + 2 ].
    unicodeBuffer := String new: sizeInBytes.
    nChars := KernelLibrary
        multiByteToWideCharCp: 0 "CP_ACP"
        flags: 0
        lpstr: self
        cchstr: self size
        lpwstr: unicodeBuffer
        cchwstr: sizeInBytes.
    nChars < self size
        ifTrue: [ self error: 'unicode translation failed' ].
    ^unicodeBuffer!  
canBeUnmounted
        "Answer whether the receiver can in fact be unmounted.  If this method
        returns false, it may still be possible to unmount the receiver at a later
        time."
    ^false!   
isArchived
	"Answer true if the file is archived."

	^self attributes includes: $a!
fill: aDictionary fromModule: aModuleName idDictionary: idDictionary
        "Fill string dictionary aDictionary from a module
         aModuleName using the string identifiers given
         in the idDictionary. Contents of aModuleName must
         be in compiled resource format."
    | aString loadDictionary modHandle stringBuffer numBytes |
    modHandle := DynamicLinkLibrary open: aModuleName.
    modHandle isDynamicLinkLibrary ifFalse: [
        ^self error: 'cannot open module'].
    stringBuffer := String new: 256.
    "Create a temporary load dictionary in case there is an error."
    loadDictionary := Dictionary new.
    idDictionary associationsDo: [ :assoc |
        numBytes := UserLibrary loadString: modHandle
            id: assoc value
            buffer: stringBuffer
            maxChars: 256.
        numBytes = 0 ifTrue: [
            modHandle close.
            ^self osError ].
        aString := ( stringBuffer copyFrom: 1 to: numBytes ) asNormalizedString.
        loadDictionary at: assoc key put: aString].
    modHandle close.
    loadDictionary associationsDo: [ :assoc |
        aDictionary at: assoc key put: assoc value ].
    ^self!   
addClassVarName: aString
        "Obsolete - Add a new class variable named aString to the receiver."
 
	self superclass
		subclass: self symbol
   		instanceVariableNames: self instanceVariableString
    	classVariableNames: self classVariableString , aString
		poolDictionaries: self sharedVariableString
		isVariable: self isVariable
		isPointers: self isPointers!  
allocationUnit
        "Private - Answer the minimum number of bytes which is allocated for the receive's files."
    | path totalClusters freeClusters sectorsPerCluster bytesPerSector |
    path := self asFileSystemPath volumePath asString.
    sectorsPerCluster := ExternalLong new.
    bytesPerSector := ExternalLong new.
    freeClusters := ExternalLong new.
    totalClusters := ExternalLong new.

    ( KernelLibrary getDiskFreeSpace: path asParameter
        sectorsPerCluster: sectorsPerCluster asParameter
        bytesPerSector: bytesPerSector asParameter
        freeClusters: freeClusters asParameter
        totalClusters: totalClusters asParameter )
            ifFalse: [ self osError ].

    ^sectorsPerCluster asInteger * bytesPerSector asInteger!  
findFileName: fileName
        "Answer the full path of the file named fileName,
        located on the path, or nil if not found."
    ^self findFileName: fileName on: nil!  
triggerEvent: eventName
        "Trigger the event named <eventName>. Answer the value returned
        by the most recently defined event handler action."
   ^( self actionForEvent: eventName ) evaluate!   
osNotification
        "Create a notification for the informational warning indicated by
        the host operating system.  Ask the host operating system for
        the last error code."
    | msg |
    msg := 'OS Notification: ', ( self osErrorMessage: self lastOsError ).
    ^Notification signal: msg!  
create: newPathName
        "Create a directory named newPathName."

	^self createDirectoryNamed: newPathName! 
when: eventName do: aBlock
        "Append <aBlock> to the list of actions to evaluate when
        the receiver triggers the event named <eventName>."

    self
        when: eventName
        evaluate: aBlock! 
isInLibrary
        "Answer true if the receiver is in a library."

    ^self smalltalkLibraryOrdinal > 1  " must be consistent with #libraryName "!   
osError: anInteger
        "Create a walkback window describing an error condition
        that was returned from the host operating system, as
        indicated by anInteger"
    ^Error signal: ( self osErrorMessage: anInteger ), ' ( OS error ', ( anInteger radix: 16 ), ' )'! 
perform: aSymbol
    with: firstObject
    with: secondObject
    with: thirdObject
        "Answer the result of sending a keyword message to
         the receiver with selector aSymbol and arguments
         firstObject, secondObject and thirdObject.  Report
         an error if the number of arguments expected by the
         selector is not three."
    ^self perform: aSymbol withArguments:
        (Array
            with: firstObject
            with: secondObject
            with: thirdObject)! 
copyToNonSmalltalkMemory: aVariableByteObject withAllocFlag: allocFlag
        "Private - Copy aVariableByteObject to allocated
         memory with allocFlags and
         answer the address of that memory."
    self checkGlobalAddress.
    ^ExternalGlobalAddress
        copyToNonSmalltalkMemory: aVariableByteObject
        withAllocFlag: allocFlag!   
flush
        "Force all data written to the receiver to be
         recorded on disk."

    self fileId == nil
		ifTrue: 
			["We're not open so we can't be flushed"
			^self].
	( KernelLibrary flushFileBuffers: self fileId ) ifFalse: [ self osError ]! 
fromLocalFileTime: aLocalFileTime
        "Private - answer a copy of the receiver converted from local time
        to UTC (Coordinated Universal Time) time."
    | fileTime |
    fileTime := self new.
    ( KernelLibrary
        localFileTime: aLocalFileTime asParameter
        toFileTime: fileTime asParameter )
            ifFalse: [ ^self osError ].
    ^fileTime!   
fromDate: aDate time: aTime
        "Private - answer a WinFileTime based on the
       specified date and time."
    ^( WinSystemTime fromDate: aDate time: aTime ) asFileTime!   
fromDosDateTime: anArray
        "Private - answer a WinFileTime from the two (16-bit) integers
        in anArray (time is first element, date is second) in DOS format."
    | winFileTime |
    winFileTime := self new.
    ( KernelLibrary
        dosDate: ( anArray at: 2 )
        time: ( anArray at: 1 )
        toFileTime: winFileTime asParameter )
            ifFalse: [ ^self osError ].
    ^winFileTime!  
fromDosDate: dateInteger time: timeInteger
        "Private - answer a WinFileTime from the two (16-bit) integers
        which represent the receiver date/time in DOS format."
    ^self fromDosDateTime: ( Array with: timeInteger with: dateInteger )! 
fromFileHandle: aFileHandle
        "Private - answer a WinFileTime object representing the
        date the specified file was last written."
    | winFileTime |
    winFileTime := self new.
    ( KernelLibrary getFileTime: aFileHandle asParameter
        creation: nil
        lastAccess: nil
        lastWrite: winFileTime asParameter )
            ifFalse: [ ^self osError ].
    ^winFileTime!   
sizeInBytes
    ^8!  
fromFile: aFile
        "Private - answer a WinFileTime object representing the
        date the specified file was last written."
    ^self fromFileHandle: aFile fileId! 
asSystemTime
        "Private - answer the receiver converted to a WinSystemTime."
    | systemTime |
    systemTime := WinSystemTime new.
    KernelLibrary fileTime: self asParameter toSystemTime: systemTime asParameter.
    ^systemTime!   
asTime
        "Answer the Time of the last write to the file
        corresponding to the receiver."
    ^self asSystemTime asTime!   
dwHighDateTime
    ^self uLongAtOffset: 4!   
dwHighDateTime: anInteger
    self uLongAtOffset: 4 put: anInteger!  
asLocalFileTime
        "Private - answer a copy of the receiver converted from UTC (Coordinated Universal
        Time) time to local time."
    | localFileTime |
    localFileTime := self class new.
    ( KernelLibrary
        fileTime: self asParameter
        toLocalFileTime: localFileTime asParameter )
            ifFalse: [ ^self osError ].
    ^localFileTime! 
printOn: aStream
    aStream nextPutAll: self class name, ' { ', self asTimeStamp printString, ' }'! 
asDate
        "Answer the Date of the last write to the file
        corresponding to the receiver."
    ^self asSystemTime asDate!   
toFileHandle: aFileHandle
        "Private - write the receiver date and time as the last write
        time for the file specified by aFileHandle."
    ( KernelLibrary
        setFileTime: aFileHandle asParameter
        creation: nil
        lastAccess: nil
        lastWrite: self asParameter )
            ifFalse: [ ^self osError ]

! 
asDosDateTime
        "Private - answer an array of two (16-bit) integers which represent the
        receiver date in DOS format."
    | dosDate dosTime |
    dosDate := ExternalBuffer new: 2.
    dosTime := ExternalBuffer new: 2.
    ( KernelLibrary
        fileTime: self asParameter
        toDosDate: dosDate asParameter
        dosTime: dosTime asParameter )
            ifFalse: [ ^self osError ].
    ^Array with: ( dosTime uShortAtOffset: 0 ) with: ( dosDate uShortAtOffset: 0 )!   
asTimeStamp
        "Answer the receiver converted to a TimeStamp object."
    ^TimeStamp date: self asDate time: self asTime!  
dwLowDateTime
    ^self uLongAtOffset: 0!
dwLowDateTime: anInteger
    self uLongAtOffset: 0 put: anInteger!   
toFile: aFile
        "Private - write the receiver date and time as the last write
        time for the file specified by aFile."
    self toFileHandle: aFile fileId!
addDependent: anObject
        "Make <anObject> be a dependent of the receiver."
    self
        when: self changedEventName
        send: #update
        to: anObject!
deviceWrite: aString
        "Write aString to the receiver device."
    | extString long |
    extString := aString asExternalString.
    long := ExternalLong new.
    ( KernelLibrary
        writeFile: self asParameter
        buffer: extString
        bytesToWrite: extString basicSize
        bytesWritten: long asParameter
        overlapped: nil )
            ifFalse: [ ^self osError ]

!  
getHandle: aString
        "Private - Answer an instance of the receiver which refers
         to the Dynamic Link Library named aString."
    | answer |
    ( answer := KernelLibrary getModuleHandle: aString asParameter ) = 0
        ifTrue: [ ^self osError ].
    ^self fromInteger: answer!
asExistingSymbolOrNil
        "If a symbol already exists that represents the same string
        as the receiver, return the existing symbol.  Otherwise return nil"
	 ^self
	!  
volume
        "Answer the FileVolume on which the receiver resides."
    | locator |
    locator := FileSystemPath absolute: ( Array with: self fileSystemLocator componentNames first ).
    ^FileVolume fromLocator: "locator" self fileSystemLocator volumePath!  
createDirectoryNamed: newPathName
        "Create a directory on disk with complete path name
        newPathName."

    ( KernelLibrary
        createDirectory: newPathName asParameter
        securityAttributes: nil )
            ifFalse: [ ^self osError ].
    ^self fromPath: newPathName!  
virtualAlloc: lpAddress size: dwSize allocationType: dwAllocationType protect: dwProtect
    <api: VirtualAlloc ulong ulong ulong ulong ulongReturn>
    ^self invalidArgument! 
knownDefinition
	"Answer the definition for the compiled method associated with the receiver.
	Answer nil if the receiver doesn't know an appropriate definition
	(This message is sent to the source object of compiled methods.)"

	^nil!  
sizeInBytes
    ^318!
startUp
        "Private - initialize the receiver upon image startUp."
    OperatingSystem := self new getIt.
    ( Smalltalk includesKey: #WIN )
        ifTrue: [ Smalltalk at: #WIN put: OperatingSystem ].
    self initializeSystemColors! 
exists
    "Answer <true> if the receiver represents an existing component on the file system."

	^self directory hasFileNamed: self name! 
getLaunchFrame
        "Private - get the base address of the Smalltalk stack for the receiver."
    <primitive: 5>!
= aVolume
        "Answer whether the receiver and aVolume are equal."
    ^[ self rootDirectory = aVolume rootDirectory ]
        on: MessageNotUnderstood do: [ ^false ]!
asFileSystemPath
    "Answer a path that will resolve to the same entity as the receiver."

    ^self asFileSystemLocator asFileSystemPath!
printOn: aStream
        "Append a text representation of the receiver to aStream."
    super printOn: aStream.
    aStream nextPutAll: ' on: '.
    self fileSystemLocator printOn: aStream! 
fileSystemLocator
    "Answer the fileSystemLocator that was used to create the receiver."

    ^fileSystemLocator
!  
fileSystemLocator: aFileSystemLocator
    "Answer the FileSystemLocator that was used to create the receiver."

    fileSystemLocator := aFileSystemLocator
! 
hash
        "Answer the hash value for the receiver."
    ^self rootDirectory hash!
mountPoint
        "Answer the root directory for the hierarchy of entities residing on
        the receiver."
    ^self rootDirectory!
cannotBeMounted
       "An attempt to mount the receiver has failed.  Signal a FileError."
    FileError
        signal: 'Cannot be mounted'
        with: self!  
rootDirectory
        "Answer the root directory of the hierarchy containing the receiver's
        mount point."
    ^Directory fromLocator: self fileSystemLocator!  
asFileSystemLocator
    "Answer a file system locator that will resolve to the same entity as the receiver."

    ^self fileSystemLocator! 
bytesAllocated
        "Answer the number of bytes of space on the receiver
        that have been allocated."
    ^self bytesUsed!
bytesUsed
        "Answer the number of bytes of space on the receiver
        that have been allocated."
    ^self byteSize - self bytesFree! 
isVolume
    "Answer <true> if the receiver is a volume."

    ^true!  
volume
        "Answer the FileVolume on which the receiver resides."
    ^self!
cannotBeUnmounted
       "An attempt to unmount the receiver has failed.  Signal a FileError."
    FileError
        signal: 'Cannot be unmounted'
        with: self!
open: anAction
    fileSize: aFileSize
    attribute: anAttr
    flags: openFlags
    mode: aMode
        "Private - Open the file with the specified
        parameters."
    self isOpen ifTrue: [self close].
    self fileId: ( FileHandle open: self name in: self directory
        action: anAction fileSize: aFileSize
        attribute: anAttr flags: openFlags mode: aMode)! 
allDependents
        "Answer a Set containing all the
         dependents of the receiver."
    | answer toProcessNow toProcessNext |
    answer := Set new.
    toProcessNow := self dependents.
    [toProcessNow isEmpty]
        whileFalse: [
            toProcessNext := Set new.
            toProcessNow do: [ :dependent |
                (answer includes: dependent)
                    ifFalse: [
                        answer add: dependent.
                        toProcessNext addAll: dependent dependents]].
            toProcessNow := toProcessNext].
    ^answer!
isStream
        "Answer true if receiver is a kind of Stream."
    ^false! 
broadcast: aSymbol
        "Send the argument aSymbol as a unary
         message to all of the receiver's dependents."
    self dependents do: [ :dependent | dependent perform: aSymbol]!
ftLastAccessTime
    ^WinFileTime usingBytes: ( self bytesAtOffset: 12 count: WinFileTime sizeInBytes )! 
cAlternateFileName
    ^( self bytesAtOffset: 304 count: 14 ) asString trimNullTerminator asNormalizedString!
dwFileAttributes
    ^self uLongAtOffset: 0! 
ftCreationTime
    ^WinFileTime usingBytes: ( self bytesAtOffset: 4 count: WinFileTime sizeInBytes )!
cFileName
    ^( self bytesAtOffset: 44 count: 260 ) asString trimNullTerminator asNormalizedString! 
cFileName: aString
    self bytesAtOffset: 44 put: aString asByteArray!  
ftCreationTime: winFileTime
    self bytesAtOffset: 4 put: winFileTime contents! 
nFileSizeLow
    ^self uLongAtOffset: 32!
ftLastAccessTime: winFileTime
    self bytesAtOffset: 12 put: winFileTime contents!  
nFileSizeHigh
    ^self uLongAtOffset: 28!   
dwFileAttributes: anInteger
    self uLongAtOffset: 0 put: anInteger!
nFileSizeHigh: anInteger
    self uLongAtOffset: 28 put: anInteger!  
nFileSizeLow: anInteger
    self uLongAtOffset: 32 put: anInteger!   
cAlternateFileName: aString
    self bytesAtOffset: 304 put: aString asByteArray!
ftLastWriteTime
    ^WinFileTime usingBytes: ( self bytesAtOffset: 20 count: WinFileTime sizeInBytes )!  
ftLastWriteTime: winFileTime
    self bytesAtOffset: 20 put: winFileTime contents!   
exists: aFileName
        "Answer true if the file or subdirectory specified
         by aFileName exists, else return false."
    | entity directory |
    entity := aFileName asFileSystemPath.
    directory := Directory fromPath: entity parentPath.
    ^directory hasEntityNamed: entity entityName! 
osNotification: anInteger
        "Create a notification for the informational warning #anInteger
        raised by the last API call."
    | msg |
    msg := ( self osErrorMessage: anInteger ), ' ( OS notification ', ( anInteger radix: 16 ), ' )'.
    ^Notification signal: msg!  
when: eventName evaluate: anAction
        "Append <anAction> to the list of actions to evaluate
        when the receiver triggers the event named <eventName>."
    | actions |
    (self canTriggerEvent: eventName)
        ifFalse: [self errorBadEvent: eventName].
    actions := self actionListForEvent: eventName.
    (actions includes: anAction)
        ifTrue: [^self].
    self
        setActionList: (actions copyWith: anAction)
        forEvent: eventName!   
libraryName
    "Obsolete - Answer the name of the SmalltalkLibrary which contains
    the receiver, or nil if the receiver is in the base library
    or the image."

    ^self smalltalkLibraryName!   
perform: aSymbol withArguments: anArray
        "Answer the result of sending a message to the receiver
         with selector aSymbol and arguments the elements of
         anArray.  Report an error if the number of arguments
         expected by the selector is not equal to anArray size."
    | aString |
    <primitive: 84>
    aSymbol isSymbol
        ifFalse: [
            aString := aSymbol class name.
            ^self error: 'perform: expects a Symbol, not ',
                ((aString at: 1) isVowel
                    ifTrue: ['an ' , aString]
                    ifFalse: ['a ' , aString])].
    ^self error:
        'perform: ' , self class name , ' ' , aSymbol ,
        ' did not expect ' , anArray size printString ,
        ' arguments'!
releaseSegmentedAddress
        "Release the segmented address. Only to be used after creating a
        segmented address using ExternalAddress>>asSegmentedAddress
        in Windows 95, when the segmented address is no longer needed."
    OperatingSystem isWindows95
        ifTrue: [ ThunkWin95DLL current release16BitAddress: self asInteger ]!  
openForExclusiveReadOnly
        "Private - Open the file with a new file handle and a file mode that is ExclusiveReadOnly."

    self isOpen ifTrue: [ self close ].
    self fileId: ( FileHandle
        open: self name
        in: self directory
        access: GenericRead
        share: 0
        create: OpenExisting
        attributes: FileAttributeNormal )! 
isBelowEqual: aNumber
        "Answer true if the receiver is lower or equal on the screen
         than aNumber, else answer false."
    ^self >= aNumber!
doesNotNeedFinalization
	"The receiver no loner needs to be sent the #finalize message when it is not referenced anymore."

	self finalizationRegistry remove: self!   
pathName: aString in: aDirectory 
        "Answer a FileStream with path name aString 
         with default directory aDirectory." 

	^(self fromPath: aString in: aDirectory) writeStream!  
isFileStream
        "Answer whether the receiver is a kind of FileStream."
    ^false! 
existingSymbolFor: aString
        "Answer true if the symbol, corresponding to the argument string already exists"
    | symbol |
    symbol := (super new: aString size) initContents: aString.
    ^(SymbolTable symbolAt: symbol)
    !  
internPrim: aString table: aSymbolSet class: symbolClass
        "Private - Answer a Symbol whose character sequence
         is the same as that of aString."

    | answer symbol |
    <primitive: 173>
    "primitive failure code. do it the old way..."
    symbol := (super new: aString size) initContents: aString.
    (answer := aSymbolSet symbolAt: symbol) == nil
        ifTrue: [
            answer := symbol.
            aSymbolSet add: symbol].
    ^answer! 
mustBeSymbol: aSymbol
        "Private - Report an error if aSymbol is not a Symbol."
    (aSymbol isSymbol)
        ifFalse: [^self error: 'Must be a Symbol']!   
new: ignoreArgument
        "Private - Answer an instance of the receiver.
         This method reports an error."
    ^self invalidMessage!   
intern: aString
        "Private - Answer a Symbol whose character sequence
         is the same as that of aString."

    ^self internPrim: aString table: SymbolTable class: self!  
directoryNamesMatching: pattern
	"Answer a collection of the names of the directories contained within the receiver that match the given <pattern>."

	| names matchPoint uppercasePattern |
	names := OrderedCollection new.
    uppercasePattern := Pattern new: pattern input asUpperCase.
	self
		directoryNamesDo:
			[:name |
			(matchPoint := uppercasePattern match: name asUpperCase index: 1) ~~ nil
				ifTrue: [(matchPoint x = 1 and: [matchPoint y = name size])
							ifTrue: [names add: name asUppercase]]].
	^names!  
fill: aDictionary fromStringTable: aFileName
        "Fill string dictionary aDictionary from a text
         file aFileName. Contents of aFileName must
         be in resource string table format."
    | aStream |
    aStream := File pathNameReadOnly: aFileName.
    self new
        fileName: aFileName;
        fill: aDictionary from: aStream.
    aStream close.
    ^self!
createIdDictionary: aFileName
        "Create a string identifier dictionary from a text
          file aFileName with dictionary keys being string
          identifiers and values being integer values.
          Contents of aFileName must be in
          standard C Language (.H) header file format."
    | aStream aDictionary|
    aStream := File pathNameReadOnly: aFileName.
    aDictionary := Dictionary new.
    self new
        fileName: aFileName;
        load: aDictionary from: aStream.
    aStream close.
    ^aDictionary! 
nextToken
        "Private - Answer the next string token from the
          receiver's file. A token is a set of characters
          separated by leading white space and trailing
          white space or end-of-file."
    | startPosition |
    self skipComments.
    (self nextNonBlank) isNil ifFalse: [
        startPosition := fileStream position.
        fileStream do: [ :character |
            (character isSeparator) ifTrue: [
                fileStream backupOver: character.
                ^fileStream
                    copyFrom: startPosition to: (fileStream position)]].
        "Must have reached end-of-file"
        ^fileStream
            copyFrom: startPosition to: (fileStream position)].
    ^nil! 
warning: aString
        "Private - Display warning message aString."
    Warning signal: aString.
    ^nil!   
load: aDictionary from: aStream
        "Read dictionary entries from a text file stream
         aStream. Contents of aStream must be in
         standard C Language (.H) header file format."
    | key value |
    dictionary := Dictionary new.
    fileStream := aStream.
    [self nextFind: '#define'] whileTrue: [
        key := self nextToken.
        (key isNil or: [key includes: $#]) ifTrue: [
            ^self fileError: 'Missing string identifier.'].
        value := self nextToken.
        (value isNil or: [(value := self asInteger: value) = 0]) ifTrue: [
            ^self fileError: ('Identifier "', key, '" missing value.')].
        dictionary at: key put: value].
    dictionary isEmpty
        ifTrue: [^ self fileError: 'No Id definitions found.']
        ifFalse: [ dictionary associationsDo: [ :assoc |
            aDictionary at: assoc key put: assoc value]].!  
nextFind: aString
        "Private - Find next occurrence of statement
         or directive aString in the receiver's file.
         Answer true if found, else answer false."
    | token  |
    [(token := self nextToken) isNil] whileFalse: [
        (token = aString) ifTrue: [^true]].
    ^false! 
nextNonBlank
        "Private - Answer the next non-blank character,
          else answer nil. Blanks are white space characters
          with code point value less than or equal to Space."
    fileStream do: [ :character |
        (character isSeparator) ifFalse: [ ^character]].
    ^nil!
skipComments
        "Private - Skip any comments that follow in the
          receiver's file. Comments are as defined by
          standard C Language."
    | character |
    [(character := self nextNonBlank) = $/] whileTrue: [
        fileStream skipTo: $/].
    character isCharacter ifTrue: [
        fileStream backupOver: character].! 
asInteger: aString
        "Private - Answer aString as integer value.
        <aString> must represent a valid ANSI C Integer Constant.
        Long (l or L) and Unsigned (u or U) suffixes are silently ignored."
    ( aString at: 1 ) = $0
        ifTrue: [
            ( ( aString at: 2 ) = $x or: [ ( aString at: 2 ) = $X ] )
                ifTrue: [ ^Integer readFrom: ( aString copyFrom: 3 to: aString size ) asUpperCase asStream radix: 16 ]
                ifFalse: [ ^Integer readFrom: ( aString copyFrom: 2 to: aString size ) asStream radix: 8 ] ]
        ifFalse: [ ^aString asInteger ]! 
readTable
        "Private - Read string table from the receiver's
         file and add to the temporary dictionary."
    | key string|
    (self nextFind: 'BEGIN') ifFalse: [
        ^self fileError: 'Bad string table.'].
    [(key :=self nextToken) isNil] whileFalse: [
        key = 'END' ifTrue: [^true].
        (string := self nextString) isNil ifTrue: [
            ^self fileError: 'Missing text for string identifier "', key,'".'].
        dictionary at: key put: string].
    ^self fileError: 'Bad string table.'!   
fileError: aString
        "Private - Report an error in the receiver's file."
    Warning signal: fileName asUpperCase, ': ', aString.
    ^nil!  
nextString
        "Private - Answer the next string definition
          from the receiver's file."
    | string startPosition lastPosition  |
    string := String new.
    (self nextNonBlank) = $" ifTrue: [
        startPosition := fileStream position + 1.
        lastPosition := startPosition - 1.
        fileStream do: [ :character |
            (character = $") ifTrue: [
                string := string, (fileStream copyFrom: startPosition to: lastPosition).
                (fileStream peekFor: $")
                    ifTrue: [startPosition := fileStream position]
                    ifFalse: [^string asCompactString]].
            lastPosition := fileStream position]].
    ^nil!  
fileName: aFileName
        "Private - Set the receiver's file name to aFileName."
    fileName := aFileName.!  
fill: aDictionary from: aStream
        "Read dictionary entries from a text file stream
         aStream and update/add values to aDictionary.
         Contents of aStream must be in resource
         string table format."
    dictionary := Dictionary new.
    fileStream := aStream.
    [self nextFind: 'STRINGTABLE'] whileTrue: [
        (self readTable) isNil ifTrue: [
            ^self warning: 'String dictionary was not changed.']].
    dictionary isEmpty
        ifTrue: [^self fileError: 'No string definitions found.']
        ifFalse: [dictionary associationsDo: [ :assoc |
            aDictionary at: assoc key put: assoc value]].! 
runtimeResourceDLLName
        "Private - answer the name of the DLL which contains
        resources (cursors, icons, etc.) for runtime and
        development."
    ^VirtualMachineExe fileName!   
asStream
        "Answer a ReadWriteStream on the receiver."
    ^ReadWriteStream on: self! 
fileAttributes
	"Answer a String containing attribute flags from the DTA in
    aString. Attributes are: 'r' read only, 'h' hidden, 's' system,
    and 'a' archive."

    | answer aByte |
    answer := String new.
    aByte := self findData dwFileAttributes.
    (aByte bitAnd: 1) > 0
        ifTrue: [answer := 'r'].
    (aByte bitAnd: 2) > 0
        ifTrue: [answer := answer, 'h'].
    (aByte bitAnd: 4) > 0
        ifTrue: [answer := answer, 's'].
    (aByte bitAnd: 32) > 0
        ifTrue: [answer := answer, 'a'].
	^answer! 
initializeAllUpperCase
        "Private - initialize allUpperCase inst var."
    allUpperCase := String new: 255.
    1 to: 255 do: [ :cp |
        allUpperCase at: cp put: ( UserLibrary charUpper: cp ) asCharacter ].
    ^allUpperCase! 
pathName: aString
attribute: fileAttr
mode: openMode
	"Answer a FileStream with path name aString 
         with attribute anAttr and aMode as the file open mode. 
         See FileHandle open:in:action:fileSize:attribute:flags:mode: 
         for more details."

	^self
			pathName: aString
			in: Disk
			attribute: fileAttr
			mode: openMode! 
remove: aString
        "Erase the file named aString."
    ( KernelLibrary deleteFile: aString asFileSystemPath asString asParameter )
        ifFalse: [ ^self osError ]!
removeFileNamed: aString
        "Erase the file named aString."

    ( KernelLibrary deleteFile: aString asFileSystemPath asString asParameter )
        ifFalse: [ ^self osError ]! 
asInteger
        "Answer the receiver converted to an Integer."
    ^self uShortAtOffset: 0!