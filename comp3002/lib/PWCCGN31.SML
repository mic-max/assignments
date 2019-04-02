3.1.0.106
   
openFile
		"Open a file dialog to allow the user to choose a file.
		Compile the code in this file and answer the resultant class."
    | fileName |
    fileName := (FileDialog new openFile: '*.cls') file.
    fileName isNil ifTrue: [^nil].
    ^self openFile: fileName!  
instanceVariableNamesString
        "Private - answer a string that has the reciever's instance variable names."
    ^String new!   
fixedClass
        "Set the receiver to model a fixed (as opposed to variable) class."
    classDefinitionModel := CodeGenerationFixedClassDefinition new!  
printOn: aStream
    | selectorParts selectorPart argModel arg |
    selectorParts := selector partSelectorParts.
    1 to: selectorParts size do: [ :i |
        selectorPart := selectorParts at: i.
        argModel := argumentModels at: i ifAbsent: [ nil ].
        argModel notNil ifTrue: [
            arg := argModel object ].
        aStream nextPutAll: selectorPart, ' '.
        arg printOn: aStream.
        aStream nextPutAll: ' ' ]!  
isPointers
        "Private - answer true if the receiver models a class
        whose instances contain pointers (as opposed to binary data,
        bytes or words)."
    ^false!   
precedenceLevel
        "Private - answer the precedence level of the receiver.
        The precedence level is the precedence of the evaluation
        of the expression of the receiver.  The precedence levels
        for corresponding expressions are:

            primary or unary message - 1
            binary message - 2
            keyword or cascaded message - 3 "

    ^3!   
classInStream: aStream
		"Compile the code in aStream and answer the resulting class."
    | class |
    class := self fileInFrom: aStream.
    ^class!   
isMeta: aBoolean
        "Private - set whether the receiver is a meta, or class, method."
    isMeta := true!  
codeGenerator: aCodeGenerator
        "Private - set the code generator that is managing the receiver."
    codeGenerator := aCodeGenerator!
setAllSubclassesDirectoryName: aString
		"Private - set the directory name for all the subclasses of the receiver
		to be aString."
    self allSubclasses do: [ :class |
        class setDirectoryName: aString ]!  
object
		"Private - answer the receiver's referenced object."
    ^entry object!
on: aStream
    ^self new stream: aStream!   
indexableType
        "Private - answer a string decribing the structure of instances of the receiver."
    ^'none'!
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    | selectorParts selectorPart argumentModel |
    selectorParts := selector partSelectorParts.
    1 to: selectorParts size do: [ :i |
"The following 2 lines impose a formatting rule:  If there are 2 or more arguments
put every selectorPart/argument pair on a separate line and indent the 2nd and
successive lines in one tab from the first line."
        i = 2 ifTrue: [ aCodeGeneratorStream indent ].
        i >= 2 ifTrue: [ aCodeGeneratorStream cr ].
        selectorPart := selectorParts at: i.
        aCodeGeneratorStream token: selectorPart.
        argumentModel := argumentModels at: i.
        self writeArgumentDefinition: argumentModel on: aCodeGeneratorStream ].
    selectorParts size > 1 ifTrue: [ aCodeGeneratorStream outdent ]!   
initialize
        "Private - initialize the receiver."
    classModels := OrderedCollection new.
    referenceModels := IdentityDictionary new.
    objectsToModels := IdentityDictionary new.
    modelsToObjects := IdentityDictionary new.
    looseMethodModels := IdentityDictionary new.
    specialStorage := OrderedCollection new.
    super initialize!
name
        "Private - answer the receiver's name."
    ^name! 
openFile: aPathName
		"Compile the code in the file specified by aPathName and
		answer the resultant class."
    | file class |
    file := File pathName: aPathName.
    class := self classInStream: file.
    file close.
    ^class!  
referenceFor: anObject
    ^referenceModels at: anObject
        ifAbsent: [
            anObject codeGenerationLanguageIn: self ]!
write: aPARTSApplication on: aStream fileDescriptor: aFileDescriptor
        "Private - write aPARTSApplication as source code on aStream.
        aFileDescriptor is the file descriptor refering to aStream."
    self new write: aPARTSApplication on: aStream fileDescriptor: aFileDescriptor! 
poolName: aString
		"Private - set the name of the pool dictionary that
		contains the value referenced by the receiver."
    poolName := aString! 
addSublanguageModel: aLanguageModel
        "Private - aLanguageModel is being added to the receiver."
    aLanguageModel
        parent: self;
        codeGenerator: self codeGenerator!
getClassName
		"Private - compute and answer the name of the class
		to be generated."
    | answer c |
    answer := self application name, 'Gen'.
    c := 0.
    [ Smalltalk includesKey: answer asSymbol ]
        whileTrue: [
            c := c + 1.
            answer := answer, c printString ].
    ^answer! 
removeAllSubclasses
        "Remove all the subclasses of the receiver."
    self subclasses copy do: [ :class | class == DeletedClass
        ifFalse: [ class removeFromSystem: false ]]!
messagePattern
        "Private - answer the receiver's message pattern deviod of any formatting."
    | nameInStream outStream |
    nameInStream := name asReadStream.
    outStream := WriteStream on: String new.!
isPoolReference
		"Private - answer true if the receiver is a pool variable reference."
    ^false! 
stream: aStream
        "Private - set the receiver's stream."
    libraryBuildingOutput stream: aStream!   
globalNamesUsed
        "Private - answer a list of all the global names currently used by the receiver."
    | answer |
    answer := Set new.
    classModels do: [ :classModel |
        classModel addGlobalsUsedTo: answer ].
    ^answer! 
newExpressionArgument
        "Create and answer a new message expression model
        to be an argument of the receiver."
    | answer |
    answer := CodeGenerationPrivateServices messageExpressionModel new.
    self addArgumentModel: answer.
    ^answer!  
cannotFindEntry: aListOfSubnames
        "Private - the class specified by aListOfSubnames
        cannot be found.  Answer a dummy class to take its place."
    | partName subname simpleName class |
    simpleName := aListOfSubnames last.
    class := Smalltalk at: simpleName asSymbol ifAbsent: [ nil ].
    class isClass ifTrue: [ ^class new ].
    partName := WriteStream on: String new.
    1 to: aListOfSubnames size do: [ :i |
        subname := aListOfSubnames at: i.
        partName nextPutAll: subname.
        i = aListOfSubnames size
            ifFalse: [
                partName nextPutAll: ' @ ' ]].
    ^PARTSUnsupportedPart new
        partTypeSimpleName: aListOfSubnames last!   
nameSeparator
		"Private - answer the character used to delimit
		the subnames of a part name."
    ^$@!   
createPoolNamed: aString
        "Private - create a pool named aString.  Store this so the
        the pool can be removed if the reciever's output is transient.
        If there already is a global named aString, raise an error."
    | poolName pool |
    poolName := aString asSymbol.
    ( Smalltalk includesKey: poolName )
        ifTrue: [
            self error: 'Attempt to create pool named an existing global name.' ].
    pool := Dictionary new.
    Smalltalk at: poolName put: pool.
    poolDictionaries at: poolName put: pool.
    ^pool
!  
reference: anObject withMethodArgumentNamed: aString
    self
        reference: anObject
        with: ( CodeGenerationPrivateServices argumentModel new
            object: anObject;
            name: aString;
            parent: self;
            codeGenerator: self )!
partIsStrictlyLiteral
		"Private - answer whether the receiver is truly a literal object."
    ^false!  
fileInMethodsFrom: aStream
        "Read chunks from aStream until an empty chunk
         (a single '!!') is found.  Compile each chunk
         as a method for the class described by the
         receiver.  Answer true if there were no compilation
        errors, false if there is an error."
    | source compResult compiler method |
    compiler := self getCompiler.
    [ ( source := aStream nextChunk ) isEmpty ]
        whileFalse: [
            compResult := compiler compile: source.
            compResult wasSuccessful
                ifTrue: [
                    method := compResult method.
                    method
                        classField: class;
                        selector: compResult selector;
                        sourceObject: source.
                    class addSelector: compResult selector withMethod: method ]
                ifFalse: [ ^false ]].
    ^true!  
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addRootEntryPointReference: self!  
codeGenerationStoreOn: aCodeGeneratorStream
        "Private - store a souce code representation on aCodeGeneratorStream."
    self storeOn: aCodeGeneratorStream!  
partEmitInArrayOn: aWriter
		"Private - output the actual source code representation
		(as it would appear in a literal Array) of the receiver on
		aCodeGenerator."
    aWriter token: self! 
writeComponentMethods
		"Private - write all the methods for root entry points."
    self writeSomeMethods: rootEntryPointReferences!   
storeMethodSourceDefault: aString forMethod: aMethod
        "Default behavior is to store in compiled method, do not
        waste change log for something assumed to be transient."
    aMethod sourceString: aString!  
generatedClass
        "Private - answer the receiver's generated class."
    ^generatedClass!  
newSelfArgument
        "Create and answer a new message expression model
        to be an argument of the receiver."
    | answer |
    answer := CodeGenerationPrivateServices selfPrimaryModel new.
    self addArgumentModel: answer.
    ^answer!  
componentNamed: aString
		"Private - answer the component named aString."
	^componentsDictionary at: aString ifAbsent: [
		self error: 'Component not found' ]!
isEntryPointReference
		"Private - answer true if the receiver is an entry point reference."
    ^false!
fileDescriptor: aFileDescriptor
    libraryBuildingOutput fileDescriptor: aFileDescriptor!   
pathName: aString
        "Set the full path name of the receiver."
    pathName := aString!
partIsCodeGeneratorExpression
		"Private - answer true if the receiver is a parts code generator expression."
    ^false!   
values
        "Answer an OrderedCollection containing all the values of the
         key/value pairs in the receiver."
    | answer |
    answer := OrderedCollection new: self size.
    self keys do: [ :key |
        answer add: (self at: key) ].
    ^answer!   
collectInstanceVarNames
    | name c prefix expression |
    multiReferences := IdentityDictionary new.
    entries do: [ :entry |
        entry requiresVariable
            ifTrue: [
                name := entry name.
                    " Insure no duplicate or illegal names: "
                prefix := name.
                c := 1.
                [ (instVarNames includesKey: name) or: [
                    #('nil' 'true' 'false' 'self' 'super') includes: name ]]
                        whileTrue: [
                            c := c + 1.
                            name := prefix, c printString ].
                expression := entry expression.
                expression notNil
                    ifTrue: [
                        instVarNames at: name put: expression.
                            " Stuff it back in case it changed: "
                        entry name: name.
                        multiReferences
                            at:  entry expression put: name;
                            at: entry expression creationRoot put: name ]]]! 
isCreationExpression
		"Private - answer true if the code expressed by the
		reciever explicitely creates an object."
    ^false!  
buildExpression: aCodeGenerator
        "Private - contstruct and answer the receiver's code
        generator expression."
    ^expression := object partCodeGeneratorExpression: aCodeGenerator! 
mainObject: anObject
        "Set the main object of the library being built."
    objectStore mainObject: anObject!
removeFromSystem: checkForInstances
        "Private - remove the receiver from the system and remove
        any private pools as well."
	|privatePools |
	privatePools := self myPrivatePools.
	super removeFromSystem: checkForInstances.
	privatePools do: [ :symbol |
        Smalltalk removeKey: symbol ifAbsent: [ ]].!
selector: aSelector arguments: anArray
    selector := aSelector.
    anArray do: [ :argument |
        self addArgument: argument ]!  
addClassNamed: aClassName
superclassName: superClassName
indexableType: aBoolean
instanceVariableNames: instanceVariableString
classVariableNames: classVariableString
poolNames: poolNamesString
classInstanceVariableNames: classInstanceVariableNamesString

    "Private - output a class named aClassName."

    | results |

    results := self suboutputsDo: [ :suboutput | suboutput
        addClassNamed: aClassName
        superclassName: superClassName
        indexableType: aBoolean
        instanceVariableNames: instanceVariableString
        classVariableNames: classVariableString
        poolNames: poolNamesString
        classInstanceVariableNames: classInstanceVariableNamesString ].

    ^results detect: [ :e | e isClass ]!
partAddColorExpressionsTo: aCodeGenerator
        "Add fore color and back color code generator
        expressions to aCodeGenerator."
    | colorRef |
    self foreColor notNil ifTrue: [
        colorRef := self partColorArgReferenceFor: self foreColor.
        colorRef notNil ifTrue: [
            aCodeGenerator
                addSelector: #foreColor:
                    arguments: (Array with: colorRef) ]].
    self backColor notNil ifTrue: [
        colorRef := self partColorArgReferenceFor: self backColor.
        colorRef notNil ifTrue: [
            aCodeGenerator
                addSelector: #backColor:
                    arguments: (Array with: colorRef) ]]! 
codeGenerator: aCodeGenerator
        "Private - set the receiver's code generator."
    codeGenerator := aCodeGenerator!   
namePool
		"Private - answer the reciever's name pool, the list of names
		used in the method that recreates the receiver's link."
    ^self isEventLinkExpression
        ifTrue: [ namePool ]
        ifFalse: [ superexpression namePool ]!   
setSourceCode: aString
        "Private - set the receiver's source code.  This absolutely overrides
        any source that might be computed with the argumentModels, comment,
        expressionModels, etc."
    predefinedSource := aString! 
confirm: aString
		"Private - if the reciever is in an interactive mode
		popup a confirmation message box and answer the
		result of the users choice.  If the receiver is not in
		an interactive mode answer false."
    ^interactive
        ifTrue: [
            MessageBox confirm: aString]
        ifFalse: [
            self logStream cr; show: '>> Confirm: ', aString.
            false]!
poolNamesString
        "Private - answer a string containing the reciever's pool names."
    | stream |
    stream := WriteStream on: String new.
    poolNames do: [ :instName |
        stream nextPutAll: instName; nextPut: $  ].
    ^stream contents!
newStream: aStream
        "Private - set the receiver's stream and initialize it."
    stream := aStream.
    startPosition := stream position.
    stream nextFourBytesPut: 0 "place holder for table position"!
addPoolVariableNamed: aString inPoolNamed: aPoolName
        "Private - add a pool variable named aString to the pool named aPoolName."
    | poolVariableNames |
    pools isNil ifTrue: [ pools := Dictionary new ].
    poolVariableNames := pools at: aPoolName ifAbsentPut: [ Set new ].
    poolVariableNames add: aString!
references
		"Private - answer all the references to the receiver's
		object."
    ^references!
currentColumn
		"Answer the current column of the output stream."
	^currentColumn!  
for: anObject
        "Private - answer a kind of the receiver proper for anObject.
        THIS METHOD IS TO SUPPORT 3.0 CODE GENERATION ENABLING
        METHODS."
    ^anObject partIsLiteral
        ifTrue: [
            PARTSCodeGeneratorLiteralReference new object: anObject ]
        ifFalse: [
            anObject isClass
                ifTrue: [
                    PARTSCodeGeneratorClassReference new
                        object: anObject;
                        name: anObject name ]
                ifFalse: [
                     ^PARTSCodeGeneratorExpressionReference new object: anObject ]]! 
instanceVariableNames
        "Private - answer a string that has the reciever's instance variable names."
    self implementedBySubclass!  
initialize
		"Answer an initialized instance of the receiver."
    entry := PARTSCodeGeneratorEntry new!
poolName
		"Private - answer the name of the pool dictionary that
		contains the value referenced by the receiver."
    ^poolName! 
parseSubnames: aString
		"Private - answer an Array of Strings.  These Strings
		are the substrings withing aString delimited by '@'s."
    | answer stream subname |
    answer := OrderedCollection new.
    stream := aString asStream.
    [ stream atEnd ]
        whileFalse: [
            subname := stream upTo: self nameSeparator.
            subname := subname trimBlanks.
            answer add: subname ].
    ^answer!   
arguments: aCollection
    aCollection do: [ :argument |
        self addArgument: argument ]!  
storeMethodSource: aString forMethod: aMethod
    self
        triggerEvent: #storeMethodSource:forMethod:
        withArguments: ( Array with: aString with: aMethod )
        ifNotHandled: [
            self
                storeMethodSourceDefault: aString
                forMethod: aMethod ]!   
close
		"Private - close all of the receiver's output streams."
    resourceFile notNil ifTrue: [
        resourceFile close ].
    stream notNil ifTrue: [
        stream close ]!  
application
		"Private - answer the parts application the reciever
		is generating code for."
    ^rootReference object!   
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    self writeReceiverDefinitionOn: aCodeGeneratorStream.
    self writeMessageDefinitionsOn: aCodeGeneratorStream.
  "  aCodeGeneratorStream outdent"! 
parentClassModel
        "Answer the receiver's parent class model."
    ^self mainClassModel!  
output: aCodeGeneratorOutput
        "Private - set the receiver's output."
    output := aCodeGeneratorOutput! 
spaceWithWord: aString
        "Private - write aString to the receiver insuring the character immediately
        before is whitespace."
    self lastCharacter isWhitespace ifFalse: [ self space ].
    self nextPutAll: aString!  
link: aLink
		"Private - set the receiver's link."
    link := aLink!   
new: aString
		"Private - answer an object specified by aString.
		aString is a part name."
    | class |
    class := self classFor: aString.
    ^class isClass
        ifTrue: [ class new ]
        ifFalse: [ class ]!
writeSomeMethods: aDictionary
		"Private - write a method for every entry in aDictionary."
    | refs |
    refs := Set new.
    aDictionary do: [ :set |
        refs add: set asArray first ].
    (refs asSortedCollection: [ :a :b |
        a name < b name] ) do: [ :ref |
            ref writeMethodOn: self ]!   
addSubexpression: anExpression named: aString
		"Private - add a subexpression to the receiver named aString."
    super addSubexpression: anExpression named: aString.
    anExpression name: aString; superexpression: self.
    self addToNamePool: aString!   
partIsArrayElementLiteral
		"Private - answer true if the receiver can be expressed
		in source code within a literal Array."
    ^false!  
isPointers
        "Private - answer true if the receiver models a class
        whose instances contain pointers (as opposed to binary data,
        bytes or words)."
    ^true!
partInstVarNamed: aString
		"Private - answer the instance variable named aString."
    | index |
    index := self class allInstVarNames indexOf: aString.
    ^self instVarAt: index!   
for: aReference
		"Private - answer an instance of the receiver for aReference."
    ^self new
        object: aReference object;
        addReference: aReference!   
requiresVariable
		"Private - answer true if the reciever's object requires a variable."
    ^true! 
addNewEntry: aCodeGeneratorEntry
		"Private - add a new code generator entry to the receiver."
    | object expression |
    object := aCodeGeneratorEntry object.
    object isNil ifTrue: [
        ^aCodeGeneratorEntry ].
    entries at: object put: aCodeGeneratorEntry.
    object partIsExpressible ifFalse: [
        ^aCodeGeneratorEntry ].
    expression := aCodeGeneratorEntry buildExpression: self.
    self addExpression: expression for: object.
    ^aCodeGeneratorEntry!  
className
        "Private - answer the receiver's class name."
    ^classModel name!   
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
divideMethod
        "Private - the receiver may be too large to compile so break it up
        into two or more smaller methods.  Answer the collection of
        replacement methods."
    | replacement submethodNumber i submethod submethods newCount |
    self breakUpExpressions.
    submethods := OrderedCollection new.
    replacement := self replacementMethod.
    i := self addExpressionsTo: replacement startingAt: 1.
    submethodNumber := 1.
    [ i < expressionModels size ]
        whileTrue: [
            submethod := self submethodNumbered: submethodNumber.
            submethods add: submethod.
            newCount := self addExpressionsTo: submethod startingAt: i + 1.
            i = newCount
                ifTrue: [ self error: 'Method too large to compile, cannot divide' ].
            i := newCount.
            submethodNumber := submethodNumber + 1 ].
    ( replacement newMessageExpression setReceiverToSelf
        addSelector: submethods first name ) argumentModels: argumentModels.
    1 to: submethods size - 1 do: [ :i2 |
        submethod := submethods at: i2.
        ( submethod newMessageExpression setReceiverToSelf
            addSelector: ( submethods at: i2 + 1 ) name ) argumentModels: argumentModels ].
    ^( OrderedCollection with: replacement ), submethods! 
storeByteArray: aByteArrayOrString
        "Store aByteArray in a literal in a method dedicated
        for storing the byte array.  Answer the selector of
        the method."
    | bytes selector method expressionModel |
    bytes := aByteArrayOrString isByteArray
        ifTrue: [ aByteArrayOrString ]
        ifFalse: [ aByteArrayOrString asByteArray ].
    byteStorageCount := byteStorageCount isNil
        ifTrue: [ 1 ]
        ifFalse: [ byteStorageCount + 1 ].
    selector := ( 'getByteArray', byteStorageCount printString ) asSymbol.
    method := self newClassMethodNamed: selector.
    method
        comment: 'Private - answer byte array number ', byteStorageCount printString, '.'.
    expressionModel := method newMessageExpression.
    expressionModel receiverObject: bytes.
    ^selector!  
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator!
createOutputToSmalltalkLibrary
    ^libraryBuildingOutput := CodeGeneratorLibraryBuildingOutput new! 
isPoolReference
		"Private - answer true if the receiver is a pool variable reference."
    ^true!  
isLogSourcePossible: sourceString
        "Private - Answer true if there is enough disk space to write
         the sourceString into the change log, otherwise answer false.
        Answer true for a PARTS application being loaded from source,
        because we don't ever attempt to log anything anyway. "

   ^true! 
keyAtIndex: anInteger
		"Answer the key at index anInteger."
    ^orderedKeys at: anInteger!
writeAnswerMethod
    | selector appName selectors |
    self beginMethod: 'answer' comment:
        'Build the complete application and answer it.'.
    self token: 'self'; indent.
    selectors := #( #buildComponentParts #buildLinks ).
    1 to: selectors size do: [ :i |
        selector := selectors at: i.
        self cr; token: selector; punctuation:
            (i = selectors size ifTrue: ['.'] ifFalse: [';'] ) ].
    appName := multiReferences at: rootReference expression creationRoot.
    self outdent; cr;
        nextPutAll: '^'; token: 'self'; token: appName; endMethod!
period
        "Output a period."
    self nextPut: $.! 
outdent
        "Private - reduce the indention level by 1."
    indentLevel := indentLevel - 1!
isEventLinkExpression
		"Private - answer true if the receiver's link
		is an event link."
    ^link isEventLink!  
name: aString
		"Private - set the receiver's name."
    name := aString!   
hasMultipleReferences
		"Private - answer if there are more than one reference
		to the receiver's object."
    ^references size > 1!  
isVaraibleClass
        "Private - answer true if the receiver models a variable (not fixed) class."
    ^self isFixedClass not!
copyWithoutMessages
        "Private - answer a copy of the receiver that doesn't have any message models."
    ^self class new
        receiverAttribute: receiver;
        receiverModel: receiverModel;
        codeGenerator: codeGenerator;
        object: object;
        parent: parent;
        yourself!
expressionFor: anObject
		"Private - answer the code generator expression for anObject."
    ^expressions at: anObject! 
indent
        "Increment the indent level."
    indentLevel := indentLevel + 1!
setReceiverToSelf
        "Set the reciever to be the special variable 'self'."
    self receiverModel: CodeGenerationSelfPrimary new!  
new
        "Answer an initialized instance of the receiver."
    ^super new initialize!
superexpression: anExpression
		"Private - set the reciever's superexpression."
    superexpression := anExpression!
isUnary
    ^false!  
compilerError: errorMessage
    at: sourcePosition
    in: sourceCode
    for: aClass
        "Private - a compiler error has occurred.  Handle it."
    errorMessage = 'method exceeds maximum size'
        ifTrue: [
            CodeGenerationMethodTooLarge signal "Note: this exception will be caught in the
                method CodeGenerationMethod>>outputOn: (which will be executing
                in the context of the method model that produced the too large
                method), and that method will add the method models to replace the
                too large method to the exception and pass it (the exception)
                to the next outer handler which will be
                CodeGenerationClass>>outputMethods:on: which will take the
                replacement methods and queue them up to be outputted." ]
        ifFalse: [
            "do nothing, ifFail: block of compiler invocation will handle all other cases." ]!
receiver: anObject selector: aSelector arguments: anArray
		"Set the receiver object and the first
		selector/arguments pair of the receiver."
    receiver := anObject.
    self addSelector: aSelector arguments: anArray!  
directoryName
		"Answer the directory that the receiver's class's source
		was from."
	^self class directoryName!  
storeClassDefinitionStringDefault: aString forClass: aClass
        "Default behavior is to do nothing."!
partEmitOn: aWriter
"    aWriter token: 'CurrentResourceFile'"!  
outputOn: aCodeGeneratorOutput
        "Private - output the reciever on aCodeGeneratorOutput."
    aCodeGeneratorOutput
        addClassNamed: name asSymbol
        superclassName: superclassName asSymbol
        indexableType: self indexableType
        instanceVariableNames: self instanceVariableNamesString
        classVariableNames: self classVariableNamesString
        poolNames: self poolNamesString
        classInstanceVariableNames: self classInstanceVariableNamesString! 
traverseModel: aLanguageModel
    ( self isModelTraversed: aLanguageModel )
        ifFalse: [
            self traverseModelReal: aLanguageModel ]!   
outputMethods: aMethodModelsDictionary on: aCodeGeneratorOutput
        "Private - output the methods in aMethodModelsDictionary on aCodeGeneratorOutput."
    | sortedNames methodModel replacementMethods |
    replacementMethods := OrderedCollection new.
    sortedNames := aMethodModelsDictionary keys asSortedCollection.
    sortedNames do: [ :methodName |
        methodModel := aMethodModelsDictionary at: methodName.
        [ methodModel outputOn: aCodeGeneratorOutput ]
            on: CodeGenerationMethodTooLarge
            do: [ :methodTooLargeException |
                replacementMethods addAll: methodTooLargeException replacementMethods.
                methodTooLargeException return ]].
    replacementMethods do: [ :methodModel2 |
        ( methodModel2 isMeta
            ifTrue: [ classMethodModels ]
            ifFalse: [ instanceMethodModels ] )
                at: methodModel2 name asSymbol
                put: methodModel2.
        methodModel2 outputOn: aCodeGeneratorOutput ]!  
nameForObject: anObject
		"Private - answer a name for anObject."
    | expression |
    expression := expressions at: anObject ifAbsent: [].
    ^self nameForExpression: expression!
isFixedClass
        "Private - answer true if the receiver models a fixed (not variable) class."
    ^false!   
addInitialSuboutputs
        "Private - add the receiver's initial suboutputs, if any."

    "do nothing"! 
addToNamePool: aString
		"Private - add the receiver's name to the list of names
		that will be used in the method building the reciever's link."
    self isEventLinkExpression
        ifTrue: [ self addToNamePoolReal: aString ]
        ifFalse: [ superexpression addToNamePool: aString ]!
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    aCodeGeneratorStream
        token: superclassName;
        token: self kindOfSubclass;
        nextPutAll: '#', self name;
        indent;
        cr;
        token: 'instanceVariableNames:';
        indent;
        cr;
        token: '''', self instanceVariableNamesString, '''';
        outdent;
        cr;
        token: 'classVariableNames:';
        indent;
        cr;
        token: '''', self classVariableNamesString, '''';
        outdent;
        cr;
        nextPutAll: 'poolDictionaries:';
        indent;
        cr;
        token: '''', self poolNamesString, '''';
        outdent;
        cr! 
close
        "Close the receiver."
    self suboutputsDo: [ :suboutput | suboutput close ]!
addSelector: aSelector with: anObject with: anObject2 with: anObject3
        "Add a new message to the receiver’s list of messages.  Set the selector
        of the new message to be aSelector and set the arguments of the new
        message to be an array with anObject, anObject2, and anObject3.
        Answer the new message."

    ^( self addSelector: aSelector )
        addArgument: anObject;
        addArgument: anObject2;
        addArgument: anObject3;
        yourself!  
object: anObject
		"Private - set the receiver's referenced object."
    entry
        addReference: self;
        object: anObject!  
object
		"Private - answer the object that the receiver represents."
    ^object!   
cr
		"Private - cause the text output to begin at the next line."
	| margin |
	margin := self margin.
    stream cr; nextPutAll: margin.
	currentColumn := margin size + 1!  
semicolon
        "Output a semicolon."
    self nextPut: $;!   
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addPoolReference: self!
with: aSuboutput
        "Answer an instance of the receiver that contains aSuboutput."
    ^self new
        addSuboutput: aSuboutput!
precedenceLevel
        "Private - answer the precedence level of the receiver.
        The precedence level is the precedence of the evaluation
        of the expression of the receiver.  The precedence levels
        for corresponding expressions are:

            primary or unary message - 1
            binary message - 2
            keyword or cascaded message - 3 "

    ^1!   
outputIsTransient: aBoolean
        "Private - set whether the receiver's output is transient,
        as in the case where the receiver's output is an intermediate
        step in producing an SLL."
    outputIsTransient := aBoolean!
fromStream: aStream
		"Private - answer an instance of the receiver defined
		by the first chunk in aStream."
    | chunk reader |
    [aStream next = $!!] whileFalse: [].
    chunk := aStream nextChunk.
    reader := CompilerInterface evaluate: chunk.
    (reader isKindOf: self) ifFalse: [^nil].
    PARTSResourceFile currentDirectoryName:
        (aStream isFileStream
            ifTrue: [ aStream file directory drivePathName ]
            ifFalse: [ nil ] ).
    ^reader! 
withDoubledBangs: aString
        "Private - answer a copy of aString with all the $!! characters doubled."
    | inStream outStream c |
    inStream := aString asStream.
    outStream := WriteStream on: ( String new: aString size * 3 // 2 ).
    [ inStream atEnd ] whileFalse: [
        c := inStream next.
        outStream nextPut: c.
        c = $!!
            ifTrue: [ outStream nextPut: c ]].
    ^outStream contents!   
computeImports
        "Private - compute any necessary library imports."
    | class |
    libraryMappings isNil ifTrue: [ libraryMappings := IdentityDictionary new ].
    classNamesToWrite do: [ :className |
        class := Smalltalk at: className.
        self computeImportsInClass: class ]!
isKeyword
    ^true! 
partTypeName30
        "Answer the full part type name of the receiver.  This name
        uniquely identifies the part type of the receiver."
    | separator |
    separator := String
        with: $ 
        with: PARTSCreator nameSeparator
        with: $  .
    ^self partManufacturer, separator, self partTypeSimpleName! 
write: aPARTSApplication on: aStream fileDescriptor: aFileDescriptor
        "Private - write aPARTSApplication as source code on aStream.
        aFileDescriptor is the file descriptor refering to aStream."
    | resourceFileDescriptor |
    resourceFileDescriptor := aFileDescriptor getCopyWithExtension: 'CRS'.
    resourceFileDescriptor writeToStream: [ :resourceStream |
        self
            stream: aStream;
            resourceFileStream: resourceStream;
            application: aPARTSApplication.
        className isNil ifTrue: [
            className := self getClassName ].
        self writeSourceCode ]! 
outputInstanceMethodsOn: aCodeGeneratorOutput
        "Private - output the reciever's instance methods on aCodeGeneratorOutput."
    self outputMethods: instanceMethodModels on: aCodeGeneratorOutput!
superCr
        "Invoke the receiver's class' superclass' implementation of #cr."
    currentColumn := 1.
    ^super cr!   
targetSuperClass
        "Answer the class which is
        the super class of all code generated classes."
    ^PARTSCodeGeneratorInterface generatedClassSuperclass! 
margin
		"Private - answer a left margin for the current indent level."
    ^(String new: indentLevel)
        atAllPut: Tab;
        yourself!   
writeRootSendersMethod
    | selector rootSelectors reference |
    self beginMethod: 'buildComponentParts' comment:
        'Build the component parts of the application.'.
    self token: 'self'; indent.
    rootSelectors := OrderedCollection new.
"insure the buildApp selector is first:"
    reference := rootEntryPointReferences values detect: [ :set |
        set asArray first == rootReference ].
    reference := reference asArray first.
    rootSelectors add: reference methodName.
    rootEntryPointReferences associationsDo: [ :assoc |
        reference := assoc value asArray first.
        reference == rootReference ifFalse: [
            rootSelectors add: reference methodName ]].
    1 to: rootSelectors size do: [ :i |
        selector := rootSelectors at: i.
        self cr; token: selector; punctuation:
            (i = rootSelectors size ifFalse: [';'] ) ].
    self endMethod!
logDefinition
        "Log the definition of the receiver to the change log.
        Do nothing if it's a PARTS application being loaded from source. "
    | contextManager |
    contextManager := self partGetExecutionContext.
    contextManager isNil ifTrue: [ ^super logDefinition ]!
owner: anObject
        "Private - set the owner to be anObject."
    owner := anObject!
numberOfArguments
    ^1!
isKeyword
    ^false!
partCodeGenerated: anApplicationBuilder
        "Private - The application containing the receiver has just
        been reconstructed from generated code. Perform any
        finalization or cleanup. Default is that nothing else needs
        to be done. "
!  
indexedPointersObjectStructureString
    ^self objectStructureStringList at: 2!  
printOn: aStream
    aStream nextPutAll: ' ', selector, ' '! 
nameVariable
		"Private - answer the reciever's 'name' instance variable."
    ^name!   
getAllClasses
        "Private - answer all the classes in the system."
    | answer block |
    answer := OrderedCollection new.
    block := [ :class |
        class notNil ifTrue: [
            answer add: class.
            class subclasses do: [ :subclass |
                block value: subclass ]]].
    block value: Object.
    ^answer! 
for: aLink
		"Answer an instance of the receiver for aLink."
    ^self new link: aLink; yourself!   
comment: aString
        "Set the receiver's comment."
    comment := aString!  
printOn: aStream
		"Private - print the receiver on aStream."
    aStream
        nextPutAll: self class name;
        nextPutAll: ' {';
        nextPutAll: name printString;
        nextPutAll: ', ';
        nextPutAll: references size printString;
        nextPutAll: ' refs}'!   
nextPutAll: aString
        "Output aString on the receiver."
    super nextPutAll: aString.
    currentColumn := currentColumn + aString size!
name: aString
		"Set the name of the receiver."
    super name: aString.
    variableName := aString!  
initialize
        "Private - initialize the receiver."
    name := 'UNTITLED.', self class fileExtension.
    seenDictionary := IdentityDictionary new.
    resourceTable := OrderedCollection new!  
pathName
        "Answer the full path name of the receiver."
    ^self class pathName! 
addLiteralReference: aReference
        "Do nothing.  We don't need to keep track of literal references."!   
checkSubclassName: className
        "Private - answer a class name to
        be used to create the class specified
        by the arguments."
    | existingClass answer logStream |
    existingClass := Smalltalk at: className asSymbol ifAbsent: [ ^className ].
    answer := ( existingClass isKindOf: self class )
        ifTrue: [ self checkOverwriteExistingClass: className ]
        ifFalse: [ self promptForNewClassName: className ].
    logStream := self getLogStream.
    logStream notNil ifTrue: [
        logStream cr;
            nextPutAll: 'Changed class name from "', className, '" to "', answer, '"' ].
    ^answer!   
outputPredefinedSourceOn: aCodeGeneratorOutput
    aCodeGeneratorOutput
        addMethodInClassNamed: self className
        meta: isMeta
        sourceString: predefinedSource!
addExpressionReference: aReference
		"Private - add aReference to the receiver."
    | object |
    object := aReference object.
    (expressionReferences at: aReference object ifAbsent: [
        expressionReferences at: aReference object put: Set new ] )
            add: aReference!   
insureNewClassName: aString
		"Private - compute and answer a class name based on
		aString insuring this name is not an existing global variable name."
    | answer |
    interactive ifTrue: [^self insureNewClassNameInteractive: aString].
    aString isNil ifTrue: [^nil].
    answer := aString asSymbol.
    [Smalltalk includesKey: answer asSymbol]
        whileTrue: [answer := answer, 'X'].
    aString asString = answer asString
        ifFalse: [self notify: 'Changed class name ', aString, ' to: ', answer].
    ^answer!
partWithFirstLowerCase
		"Answer a copy of the receiver with the first character
		converted to lower case."
    ^self isEmpty
        ifTrue: [ self copy ]
        ifFalse: [
            self first isLowerCase
                ifTrue: [ self copy ]
                ifFalse: [
                    self copy
                        at: 1 put: self first asLowerCase;
                        yourself ]]!  
mainObject
    ^root at: 'Main Object' ifAbsent: [ nil ]!
addSelector: aSelector with: anObject with: anObject2
        "Add a new message to the receiver’s list of messages.  Set the selector
        of the new message to be aSelector and set the arguments of the new
        message to be an array with anObject and anObject2.  Answer the new message."

    ^( self addSelector: aSelector )
        addArgument: anObject;
        addArgument: anObject2;
        yourself!   
initialize
        "Private - initialize the receiver."
    poolNames := Set new.
    super initialize!
poolNames: aCollection
        "Set the receiver's pool names to anOrderedCollection."
    poolNames := aCollection asOrderedCollection!
subexpressionNames
		"Private - answer the names of the receiver's subexpressions."
    ^subexpressionNames isNil
        ifTrue: [ Array new ]
        ifFalse: [ subexpressionNames ]!  
resourceFile
		"Private - answer a resource file for the receiver."
    ^resourceFile isNil
        ifTrue: [self getResourceFile]
        ifFalse: [resourceFile]!   
endMethod
		"Private - output the text that ends every method."
    self nextPutAll: ' !! '.
    indentLevel := 0.
    self cr!   
addInitialSuboutputs
        "Private - add the receiver's initial suboutputs, if any."
    self addSuboutput: self createOutputToSmalltalkLibrary.
    super addInitialSuboutputs.!   
isVariableReference
		"Private - answer true if the receiver is a variable reference."
    ^false!  
on: aStream
    ^self new stream: aStream!   
new
"    Globals isNil ifTrue: [self initGlobals]."
    ^super new initialize!  
directoryName
		"Answer the directory that the receiver's source was from."
	| pName |
	pName := self pathName.
	pName isNil ifTrue: [ ^nil ].
	^pName fileNamePath! 
initialSize: anInteger
		"Set the initial size of the reciever."
    orderedKeys := OrderedCollection new: anInteger.
    ^super initialSize: anInteger!   
precedenceLevel
        "Private - answer the precedence level of the receiver.
        The precedence level is the precedence of the evaluation
        of the expression of the receiver.  The precedence levels
        for corresponding expressions are:

            primary or unary message - 1
            binary message - 2
            keyword or cascaded message - 3 "

    self implementedBySubclass!   
currentColumn
        "Answer the current column of the reciever."
    ^currentColumn!  
initialize
        "Private - initialize the receiver."
    super initialize.
    currentColumn := 1.
    indentLevel := 0!   
logStream: aStream
        "Private - set the stream to which to report messages."
    logStream := aStream!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    self codeGenerationAddOldPCGXMessageModelsTo: anExpressionModel.

!
selector: aSelector
    | class |
    class := self classForSelector: aSelector.
    ^class new selector: aSelector!   
name
        "Private - answer the name of the receiver."
    ^name asSymbol!   
nameForExpression: anExpression
		"Private - answer a name for anExpression."
    ^multiReferences at: anExpression ifAbsent: []!   
getLogStream
        "Private - get a stream to log messages to from the
        receiver's execution context manager."
    | contextManager |
    contextManager := self partGetExecutionContext.
    ^contextManager isNil
        ifTrue: [
            PARTSTextWindow new
                label: 'PARTS Code Generator Reader Messages';
                openOn: String new ]
        ifFalse: [
            contextManager logStream ]!  
isCascaded
    ^messageModels size > 1!  
partIsArrayElementLiteral
		"Private - answer true if the receiver can be expressed
		in source code within a literal Array."
    ^false!  
importPoolVariableModel: aPoolVariableModel
        "Private - add aPoolVariableModel to the receiver''''s list of
        pool variables that will be imported.  This means the
        pool will be specified in the receiver''''s definition, but
        the pool not be outputted and it will be assumed to exist
        on any target host."
    importedPoolVariables add: aPoolVariableModel!  
maxMessageSends
        "Private - answer the maximum number of message sends the receiver can have."
    ^1200!
receiverAttribute: anObject
        "Private - set the receiver's receiver."
    receiver := anObject!  
instanceVarString: aString
		"Private - set the instance variable string of the receiver."
    instanceVarString := aString!
buildRootNamingDictionary
        "Private - build the dictionary which maps part names
        to classes."
    RootNamingDictionary := Dictionary new.
    self getAllClasses do: [ :c |
        (c includesSelector: #partTypeSimpleName)
            ifTrue: [ self register: c as: c basicNew partTypeName30 ]].
    ^RootNamingDictionary!   
name
        "Private - answer the name of the receiver."
    ^'super'! 
receiver: anObject selector: aSelector
		"Set the receiver's receiver object and a unary selector."
    receiver := anObject.
    self addSelector: aSelector! 
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    aCodeGeneratorStream space.
    contents codeGenerationStoreOn: aCodeGeneratorStream!
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup."
    | shrunkenIcon |
    shrunkenIcon := self partShrunkenIconAttribute.
    shrunkenIcon notNil ifTrue: [
        shrunkenIcon connection: self ].
    ^super partCodeGenerated: anApplicationBuilder! 
addSelector: aSelector with: anObject with: anObject2 with: anObject3 with: anObject4
        "Add a new message to the receiver’s list of messages.  Set the selector
        of the new message to be aSelector and set the arguments of the new
        message to be an array with anObject, anObject2, anObject3, and anObject4.
        Answer the new message."

    ^( self addSelector: aSelector )
        addArgument: anObject;
        addArgument: anObject2;
        addArgument: anObject3;
        addArgument: anObject4;
        yourself!  
getErrorHandler
        "Private - answer a compiler error handler for the receiver."
    ^PARTSCodeGeneratorCompilerErrorHandler new!  
receiver: anObject
		"Set the receiver's receiver object."
    receiver := anObject!
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
stream: aStream
        "Private - create the receiver's Smalltalk library builder and set its stream."
    libraryBuilder := SmalltalkLibraryBuilder new.
    libraryBuilder stream: aStream! 
selector: aSelector arguments: anArray
    | class |
    class := self classForSelector: aSelector.
    ^class new selector: aSelector arguments: anArray! 
register: aClass as: aString
		"Register aClass as the class of objects whose
		part name is aString."
    | subnames dictionary subname |
    subnames := self parseSubnames: aString.
    RootNamingDictionary isNil ifTrue: [
        RootNamingDictionary := Dictionary new ].
    dictionary := RootNamingDictionary.
    1 to: subnames size - 1 do: [ :i |
        subname := subnames at: i.
        dictionary := dictionary at: subname ifAbsent: [
            dictionary at: subname put: Dictionary new ]].
    dictionary at: subnames last put: aClass!
writeLinkSendersMethod
    | selector linkSelectors |
"    self cr; token: 'buildLinks'; indent; cr; token: 'self'; indent."
    self beginMethod: 'buildLinks' comment:
        'Build all the links in the application.'.
    self token: 'self'; indent.
    linkSelectors := linkEntryPointReferences values asArray collect: [ :refs | refs asArray first methodName ].
    1 to: linkSelectors size do: [ :i |
        selector := linkSelectors at: i.
        self cr; token: selector; punctuation:
            (i = linkSelectors size ifFalse: [';'] ) ].
    self endMethod!   
printOn: aStream
		"Private - print the receiver on aStream."
    | selector selectorParts args arg |
    aStream
        nextPutAll: self class name;
        nextPutAll: ' receiver: {';
        nextPutAll: receiver printString;
        nextPut: $}.
    1 to: selectors size do: [ :i |
        aStream cr.
        selector := selectors at: i.
        selectorParts := selector partSelectorParts.
        args := arguments at: i.
        1 to: selectorParts size do: [ :i2 |
            aStream nextPutAll: (selectorParts at: i2); nextPut: $  .
            i2 <= args size ifTrue: [
                arg := args at: i2.
                aStream nextPut: $(.
                arg printOn: aStream.
                aStream nextPutAll: ') ' ]]]! 
codeGenerator
        "Private - answer the receiver's code generator."
    ^codeGenerator! 
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    receiver partIsCodeGeneratorExpression | receiver partIsCodeGeneratorReference
        ifTrue: [ receiver addTo: aCodeGenerator ].
    self addArgumentReferencesTo: aCodeGenerator!  
initialize
    arguments := OrderedCollection new.
    argumentModels := OrderedCollection new.
    super initialize!  
referenceForReal: anObject
    ^nil! 
partsApplication
        "Private - answer the PARTSApplication described by the receiver."
    self obsoleteMethod.
    ^self application!
getResource: resourceId
        " Answer the resource named resourceId."
    | tablePos start stop answer |
    stream reset.
    tablePos := stream nextULong.
    stream position: tablePos + (resourceId - 1 * 8).
    start := stream nextULong.
    stop := stream nextULong.
    answer := self getResourceFrom: start to: stop.
    stream close.
    ^answer!   
traverseModelReal: aLanguageModel
    | object |
    object := aLanguageModel object.
    modelsToObjects at: aLanguageModel put: object.
    object notNil
        ifTrue: [
            objectsToModels at: object put: aLanguageModel ].
    aLanguageModel traverseOn: self.!  
bracketingCharacter: aCharacter
        "Private - output a aCharacter on the receiver's output stream,
        insuring that the character immediately preceeding is either
        the same character or white space."
    self lastCharacter = aCharacter
        ifTrue: [ self nextPut: aCharacter ]
        ifFalse: [ self spaceWithCharacter: aCharacter ]! 
closeParen
        "Private - output a $) to the output stream."
    self bracketingCharacter: $)!  
newReceiverMessageExpressionModel
        "Create and answer a message expression model
        that is to be used a the receiver's receiver."
    | answer |
    answer := CodeGenerationPrivateServices messageExpressionModel new.
    self receiverModel: answer.
    ^answer!  
partIsArrayElementLiteral
		"Private - answer true if the receiver can be expressed
		in source code within a literal Array."
    ^false!  
addOutputToImage
        "Private - add the receiver's output-to-image suboutput."
    self addSuboutput: self createOutputToImage! 
openLogWindow
        "Private-open a window to log error
        message to."
    ^PARTSTextWindow new
        label: 'PARTS Compiler Messages   ', TimeStamp current printString;
        openOn: String new!  
removeOutputFromImage
        "Private - the receiver's output is transient (it may have been created
        only to be put in an SLL).  Remove the receiver's output from the image."
    classesOutputted do: [ :class | class removeFromSystem: false ].
    poolDictionaries keysDo: [ :key |
        Smalltalk removeKey: key ]
! 
methodName
		"Private - answer the method name of the receiver."
    ^methodName!   
close
    "don't let super close or the window will close"!  
setReceiverToSuper
        "Set the reciever to be the special variable 'super'."
    self receiverModel: CodeGenerationSuperPrimary new!   
buildExpression: aCodeGenerator
		"Private - build the reciever's code generator expression."
    ^entry buildExpression: aCodeGenerator!   
name
        "Private - answer the receiver's name."
    ^name! 
name
		"Private - answer the name of the receiver."
    ^name isNil
        ifTrue: [ name := self createName ]
        ifFalse: [ name ]!
requiresParensAsArgumentOf: aMessageExpressionModel
    ^self precedenceLevel >= aMessageExpressionModel precedenceLevel!
application
        "Private - answer the PARTSApplication described by the receiver."
    ^self answer!
name: aString
        "Private - set the name of the receiver."
    name := aString!
defaultPathName
        "Answer a default path name.  This method
        should be implemented by subclasses to
        answer the PARTS application path name
        from the source system."
    ^self implementedBySubclass!
with: suboutput with: suboutput2 with: suboutput3
        "Answer an instance of the receiver with three suboutputs."
    ^self new
        addSuboutput: suboutput;
        addSuboutput: suboutput2;
        addSuboutput: suboutput3! 
addSelectorIfTrue: aSelector with: anObject
        "Add a new message to the receiver’s list of messages only if anObject is true.
        Set the selector of the new message to be aSelector and the arguments to be
        an array with anObject.  Answer the new message if it was added, otherwise
        answer nil."

    anObject
        ifTrue: [ self addSelector: aSelector with: anObject ]!  
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "If this is source reading from the workbench,
        determine if it's OK to create a subclass
        of the receiver named className.  If so call
        super to perform normal class creation
        with the same arguments."
    | classNameToUse contextManager |
    contextManager := self partGetExecutionContext.
    contextManager isNil ifTrue: [ "not loading from workbench"
        ^super
            subclass: className
            instanceVariableNames: instanceVariables
            classVariableNames: classVariables
            poolDictionaries: poolDictionaries ].
    classNameToUse := self checkSubclassName: className.
    classNameToUse isNil ifTrue: [ ^nil ].
    ^super
        subclass: classNameToUse asSymbol
        instanceVariableNames: instanceVariables
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries!  
partSearch: aPoolDictionary forStylePrefix: aString
    | answer subDict constant |
    answer := OrderedCollection new.
    style isNil ifTrue: [^answer].
    subDict := aPoolDictionary associationsSelect: [ :a |
        a key size > aString size and: [
            (a key copyFrom: 1 to: aString size) = aString]].
    subDict associationsDo: [ :a |
        constant := a value.
        constant = 0 ifFalse: [
            (self hasStyle: constant)
                ifTrue: [ answer addLast: a key ]]].
"            (style bitAnd: constant) = constant ifTrue: [
                answer addLast: a key]]]. "
    ^answer! 
addGlobalsUsedTo: aCollection
        "Private - add all the globals used by the receiver to aCollection."
    aCollection add: self name asSymbol.
    pools keys do: [ :poolName |
        aCollection add: poolName asSymbol ]!
creatorClassNames
    ^self subclasses collect: [ :subclass | subclass symbol ]! 
isClassOk: aClass
        "Private - answer whether aClass is a code generator
        produced class."
    ^aClass inheritsFrom: self targetSuperClass!   
new
		"Answer an initialized instance of the receiver."
    ^super new initialize!  
addPoolReference: aReference
		"Private - add aReference to the set of pool references
		seen by the receiver."
    poolReferences add: aReference!
codeGenerationMessageExpressionIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    | answer |
    answer := aCodeGenerator messageExpressionToReference: self.
    self codeGenerationAddAttributeMessagesTo:  answer.
    ^answer!  
closeParen
		"Private - output a $) to the output stream."
    self punctuation: ') '!  
fileIn31From: aStream
        "Private - file in the class in aStream."
    [ aStream fileIn ]
        on: CodeGeneratedClassInstalled
        do: [ :e |
            class := e generatedClass ].
    aStream close.
    ^class!  
requiresParensAsReceiverOf: aMessageExpressionModel
    self precedenceLevel = 3 ifTrue: [ ^true ].
    ^self precedenceLevel > aMessageExpressionModel precedenceLevel!
realStore: anObject
		"Private - store anObject on the reciever."
    | resourceId tableEntry |
    tableEntry := Array new: 2.
    tableEntry at: 1 put: stream position.
    resourceTable addLast: tableEntry.
    resourceId := resourceTable size.
    anObject partStoreResourceOn: self.
    tableEntry at: 2 put: stream position.
    ^seenDictionary at: anObject put: resourceId! 
promptForNewClassName: aClassName
        "Private - aClassName cannot be used
        as the name of a subclass of the receiver.
        Prompt the user for a new one."
    | newName |
    newName := Prompter
        prompt: aClassName, ' cannot be created.  Enter new name:'
        default: aClassName.
    ^newName isNil
        ifTrue: [
            self notifyClassCreationAborted: aClassName.
            nil ]
        ifFalse: [
            self checkSubclassName: newName ]!  
addMethodInClassNamed: aClassName meta: aBoolean sourceString: aString notifying: aCompilerErrorNotifier
        "Add a  method to the class named aClassName.
        Raise a CannotOutputMethod exception if the operation
        cannot be completed."
    | withDoubledBangs |
    withDoubledBangs := self withDoubledBangs: aString.
    ( currentClassName = aClassName and: [
        currentMeta = aBoolean ] )
            ifFalse: [
                currentClassName notNil
                    ifTrue: [
                        stream nextPutAll: ' !! ' ].
                currentClassName := aClassName.
                currentMeta := aBoolean.
                stream
                    cr; cr;
                    nextPutAll: ' !! ', aClassName.
                aBoolean ifTrue: [
                    stream nextPutAll: ' class' ].
                stream nextPutAll: ' methods !! ' ].
    stream
        cr; cr;
        nextPutAll: withDoubledBangs;
        nextPutAll: '   !! '!  
partIsArrayElementLiteral
		"Private - answer true if the receiver can be expressed
		in source code within a literal Array."
    ^false!  
codeGenerationAddEditExpressionTo: aMethodModel
        "Private - add expression models to aMethodModel to
        rebuild the edit information of a reconstructed clone
        of the receiver.  This edit information must not be needed
        for execution."

    self partIsPart
        ifTrue: [
            aMethodModel newMessageExpression
                receiverObject: self;
                addSelector: #partIcon: with: self partIcon;
                addSelector: #partEditRectangle: with: self partWrapper rectangle ]
!
precedenceLevel
        "Private - answer the precedence level of the receiver.
        The precedence level is the precedence of the evaluation
        of the expression of the receiver.  The precedence levels
        for corresponding expressions are:

            primary or unary message - 1
            binary message - 2
            keyword or cascaded message - 3 "

    ^1!   
partAddStylesExpressionsTo: aCodeGeneratorExpression
		"Private -"
	^self!  
requiredClassesString: aString
        "Set requiredClassesString, which defines which classes
        are required before the receiver can proceed with the fileIn."
    requiredClassesString := aString!
writeSingleMessageDefinitionOn: aCodeGeneratorStream
    messageModels size > 0 ifTrue: [
        messageModels first writeDefinitionOn: aCodeGeneratorStream ]!
addPoolNamed: aString
        "Private - add a pool name to the receiver."
    poolNames add: aString!  
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    aCodeGeneratorStream token: selector.
    argumentModels first writeDefinitionOn: aCodeGeneratorStream!  
computeImportsInMethod: aMethod
        "Private - compute any necessary library imports in aMethod."
    | object |
    aMethod do: [ :assoc |
        assoc isAssociation
            ifTrue: [
                object := assoc value.
                object isInBase
                    ifFalse: [
                        libraryMappings at: object put: object smalltalkLibraryName ]]]! 
pathName
        "Answer the full path name of the receiver.."
    ^pathName!   
myPrivatePools
        "Private - answer the names of the pools that are private to the receive."

    ^Array new! 
interactive: aBoolean
		"Private - set whether or not the receiver is interactive."
    interactive := aBoolean!
precedenceLevel
        "Private - answer the precedence level of the receiver.
        The precedence level is the precedence of the evaluation
        of the expression of the receiver.  The precedence levels
        for corresponding expressions are:

            primary or unary message - 1
            binary message - 2
            keyword or cascaded message - 3 "

    ^2!   
deriveNameFrom: preferredNameString avoiding: namesUsedString
        "Private - construct and answer a name from preferredNameString that
        is not included in namesUsedArray."
    ^self class deriveSymbolNameFrom: preferredNameString avoiding: namesUsedString!
addArgumentModel: anArgumentModel
    argumentModels addLast: anArgumentModel.
    self addSublanguageModel: anArgumentModel!   
classesOutputted
        "Private - answer a collection of the classes that have been outputted."
    ^classesOutputted
!  
at: aKey put: anObject
        "Associate the element with the key."
    | oldCount answer |
    oldCount := self size.
    answer := super at: aKey put: anObject.
    oldCount = self size
        ifFalse: [ orderedKeys addLast: aKey ].
    ^answer!  
breakUpExpressions
        "Private - the receiver may be too large to compile and is being
        broken up into two or more smaller methods.  Insure that each
        individual expression is smaller than the max message sends
        limit."
    | newExpressions |
    newExpressions := OrderedCollection new.
    expressionModels do: [ :expression |
        expression numberOfMessageSends > self maxMessageSends
            ifTrue: [
                newExpressions addAll: expression brokenUp ]
            ifFalse: [
                newExpressions add: expression ]].
    expressionModels := newExpressions!   
replacementMethodNamed: aString
        "Private - answer a method that is to replace the recevier.
        The receiver is being replaced because it is too big."
    | answer |
    answer := classModel replacementMethodFor: self named: aString.
    answer
        argumentModels: argumentModels;
        comment: comment;
        isMeta: isMeta;
        name: aString.
    ^answer
!
requiresVariable
		"Private - answer true if the reciever's object requires a variable."
    references do: [ :ref | ref isGlobalReference ifTrue: [ ^ false ]].
    name notNil ifTrue: [ ^true ].
    references do: [ :ref |
        ref requiresVariable ifTrue: [ ^true ]].
    object partIsStrictlyLiteral ifTrue: [ ^false ].
    ^self hasMultipleReferences! 
associationsDo: aBlock
        "Answer the receiver.  For each key/value pair
         in the receiver, evaluate aBlock with that
         pair as the argument."
    orderedKeys do: [ :key |
        aBlock value: (self associationAt: key)]! 
named: aFileName
        "Private - answer an instance of the receiver with
        a file named aFileName.  Answer nil if no file of
        that name exists."
    | dir aFileStream |
    dir := self currentDirectory.
    dir isNil ifTrue: [ ^nil ].
    ( dir hasFileNamed: aFileName )
        ifFalse: [ ^nil ].
    aFileStream := dir fileReadOnly: aFileName.
    ^self new fileStream: aFileStream!
COMMENT
        "An instance of this class will be instantiated whenever the
        PARTSCreater is asked to create a part that whose type
        doens't exist on this platform."!  
createName
        "Private - construct and answer a name for the receiver."
    ^object class name asString!   
partIsStrictlyLiteral
		"Private - answer whether the receiver is truly a literal object."
    ^self partIsLiteral! 
addSubexpression: anExpression named: aString
		"Private - add a subexpression to the receiver named aString."
    subexpressions isNil ifTrue: [
        subexpressions := Dictionary new.
        subexpressionNames := OrderedCollection new ].
    subexpressions at: aString put: anExpression.
    subexpressionNames addLast: aString.!  
writeUnaryMessagePatternOn: aCodeGeneratorStream
        "Private - output the receiver's message pattern on aCodeGeneratorStream."
    aCodeGeneratorStream token: name!   
cr
        "Write the line terminating character sequence and
        indent the next line."
    super cr.
    currentColumn := 1.
    self outputMargin!
isGlobalReference
		"Private - answer true if the receiver is a global reference."
    ^true!   
stream
		"Answer the receiver's stream."
    ^stream!   
initialize
        "Private - initialize the receiver."
    componentsDictionary := Dictionary new.
    objectsDictionary := Dictionary new!   
spaceWithCharacter: aCharacter
    self spaceWithString: ( String with: aCharacter )!
fileInFrom: aStream
        "File in the class in aStream."
    class := self fileInClassFrom: aStream.
    class isNil
        ifTrue: [
                "3.1 genned files have comment as first chunk, evaluate to nil."
            ^self fileIn31From: aStream ].
    ( self isClassOk: class ) ifFalse: [ ^nil ].
    aStream nextChunk; nextChunk. "eat the !! SomeClass methods !! line."
    ( self fileInMethodsFrom: aStream )
        ifTrue: [
            aStream close.
            ^class ]
        ifFalse: [ "compilation error"
            aStream close.
            class removeFromSystem: false.
            self logStream cr; nextPutAll: 'ABORTED loading part due to compilation error.'.
            ^nil ]! 
partsApplication
        "Private - answer the PARTSApplication described by the receiver."
    self obsoleteMethod.
    ^self application!
new
		"Answer an initialized instance of the receiver."
    ^super new initialize!  
variableName: aString
		"Private - set the name of the variable that will
		represent the receiver in the generated source code."
    self name: aString.
    variableName := aString!
addMethodInClassNamed: aClassName
meta: aBoolean
sourceString: aString
notifying: aCompilerErrorNotifier
        "Add a  method to the class named aClassName.
        Raise a CannotOutputMethod exception if the operation
        cannot be completed."
    | class assoc |
    class := Smalltalk at: aClassName asSymbol ifAbsent: [ self error: 'class not in Smalltalk' ].
    aBoolean ifTrue: [ class := class class ].
    assoc := CompilerInterface
        compile: aString
        in: class
        notifying: aCompilerErrorNotifier
        ifFail: [ self error: 'add method failed.' ].
    DefinitionInstaller current
        at: assoc key
        put: assoc value
        inMethodDictionary: class methodDictionary.
    self storeMethodSource: aString forMethod: assoc value.
!   
new
        "Answer an initialized instance of the receiver."
    ^super new initialize
        setCollection: ( String new: 100 );
        setLimits!
sourceVersion: aString
        "Set the sourceVersion to aString, which specifies the source platform."
    sourceVersion := aString!   
addReplacementMethod: aMethodModel
        "Private - an attempt has been made to compile a method that is too
        large to compile.  Replacements for that method model will be added to
        the receiver via this method before the receiver is signalled."
    replacementMethods isNil ifTrue: [ replacementMethods := OrderedCollection new ].
    replacementMethods add: aMethodModel!
addReference: aReference
		"Private - add aReference to the receiver."
    references isNil ifTrue: [ references := OrderedCollection new: 1 ].
    references add: aReference!
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
partLabelWithMnemonics: aString
        "Set the receiver's label to be aString
        replacing any occurances of '\u' with
        the character that indicates following
        character is the mnemonic character."
    | label |
    label := aString isString
        ifTrue: [ aString replaceEscapeCharacters ]
        ifFalse: [ aString ].
    self label: label!  
addExpressionModel: anExpressionModel
        "Private - add an expression model to the receiever."
    self ASSERT: self sender == self.  " privacyViolation"
    expressionModels add: anExpressionModel.
    self addSublanguageModel: anExpressionModel!  
referenceFor: anObject ifAbsent: aBlock
    | reference |
    reference := self referenceForReal: anObject.
    ^reference isNil
        ifTrue: [ aBlock value ]
        ifFalse: [ reference ]!
receiverObject: anObject
        "Set the object whose language model is to be the receiver's receiver.
        anObject must be registered with the receiver's code generator or
        an error will occur."
    | newReceiverModel |
    receiver := anObject.
    newReceiverModel := self codeGenerator referenceFor: anObject.
    self receiverModel: newReceiverModel.
    receiverModel isNil ifTrue: [
        self error: 'Object doesn''t have registered reference.' ]!
arguments
		"Private - answer the receiver's arguments matrix."
    ^arguments! 
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addGlobalReference: self!  
addClassNamed: aClassName
superclassName: superClassName
indexableType: aBoolean
instanceVariableNames: instanceVariableString
classVariableNames: classVariableString
poolNames: poolNamesString
classInstanceVariableNames: classInstanceVariableNamesString

    "Private - output a class named aClassName."

    stream
        cr;
        nextPutAll: superClassName;
        nextPutAll: ' subclass: ';
        nextPutAll: '#', aClassName;
        cr;
        nextPutAll: '    instanceVariableNames: ''';
        nextPutAll: instanceVariableString;
        nextPutAll: '''';
        cr;
        nextPutAll: '    classVariableNames: ''';
        nextPutAll: classVariableString;
        nextPutAll: '''';
        cr;
        nextPutAll: '    poolDictionaries: ''';
        nextPutAll: poolNamesString;
        nextPutAll: '''  !!'; cr! 
NOTES
    "
 * Must decouple building doodad (language models) from the guy
that references the object.


    "!
doesNotUnderstand: aMessage
        "The receiver received a message it does not understand.
        Report this as a warning."
    | string |
    string := 'CodeGenerator warning: ',
        self partTypeName,
            ' does not understand ', aMessage selector printString.
    (Smalltalk at: #Transcript ifAbsent: [nil]) notNil
        ifTrue: [(Smalltalk at: #Transcript) cr; show: string]! 
addNeededClass: aClass
		"Private - add aClass to the set of classes needed to reconstruct
		the PARTSApplication."
    classesNeeded add: aClass! 
setFixed
        "Private - set the receiver to model a fixed (not variable) class."
    self isFixed: true!
defineImportedPools
        "Private - add the receiver''''s imported pools to the receiver''''s definition."
    | importedPools poolNames |
    importedPools := Set new.
    importedPoolVariables do: [ :poolVarModel |
        importedPools add: poolVarModel pool ].
    poolNames := importedPools collect: [ :pool |
        ( Smalltalk keyAtValue: pool ) asString ].
    poolNames do: [ :poolName |
        classDefinitionModel addPoolNamed: poolName ].
"add pools from PARTSScriptContext so scripts can compile:"
    PARTSScriptContext sharedPools do: [ :poolName |
        classDefinitionModel addPoolNamed: poolName ]!   
storeByteArray: aByteArray
        "Store aByteArray as a literal in a dedicated method
        in the receiver's main class model."
    ^self mainClassModel storeByteArray: aByteArray!  
addSelector: aSelector arguments: anArray
        "Add a new message to the receiver’s list of messages.  Set the selector
        of the new message to be aSelector and set the arguments of the new message
        to be anArray.  Answer the new message."

    | answer |
    answer := self addSelector: aSelector.
    answer arguments: anArray.
    ^answer!
objectStructureStringList
    ^#( 'none' 'object-indexable' 'byte-indexable' )!  
traverseOn: aCodeGenerator
        "Private - log the branches of the receiver on aCodeGenerator."
    super traverseOn: aCodeGenerator.
    classDefinitionModel traverseOn: aCodeGenerator.
    instanceMethodModels do: [ :methodModel |
        methodModel traverseOn: aCodeGenerator ].
    classMethodModels do: [ :methodModel |
        methodModel traverseOn: aCodeGenerator ].

"    aCodeGenerator logModel: classDefinitionModel.
    instanceMethodModels do: [ :methodModel |
        aCodeGenerator logModel: methodModel ].
    classMethodModels do: [ :methodModel |
        aCodeGenerator logModel: methodModel ]"!
isUnary
    ^true!   
addLinkEntryPointReference: aReference
		"Private - add a link reference to the receiver."
    | object |
    object := aReference object.
    (linkEntryPointReferences at: object ifAbsent: [
        linkEntryPointReferences at: object put: Set new ] )
            add: aReference!   
partLabelWithMnemonics
        "Answer a translation of the reciever's label
        in which the mnemonic character is replaced by '\u'.
        This translation can be reversed by sending
        #replaceEscapeCharacters to the translated label."
    | label |
    label := self label.
    label isString ifFalse: [ ^label ].
    ^PARTSHostInterface replaceMnemonicCharacters: label! 
setReceiverToNew: aClass
        "Set the reciever to be aClass sent the message #new."
    | newReceiverModel |
    newReceiverModel := CodeGenerationPrivateServices messageExpressionModel new.
    self receiverModel: newReceiverModel.
    newReceiverModel
        receiverObject: aClass;
        addSelector: #new!   
isIndexedPointersObjectStructureString: aString
    ^aString = self indexedPointersObjectStructureString!
messageExpressionToReference: anObject
        "Create and answer a message expression model that will be
        used to reference anObject."
    | messageExpression |
    messageExpression := CodeGenerationPrivateServices messageExpressionModel new.
    messageExpression
        codeGenerator: self;
        setReceiverToNew: anObject class;
        parent: self.
    self reference: anObject with: messageExpression.
    ^messageExpression!
name
		"Private - answer the name of the receiver."
    ^entry name!
close
    stream
        nextPutAll: '  !! '; "closes class"
        cr; cr;
        nextPutAll: 'CodeGeneratedClassInstalled signal: ';
        nextPutAll: currentClassName;
        nextPutAll: ' !!  ';
        cr; cr;
        close.
    super close!  
traverseOn: aCodeGenerator
        "Private - log the branches of the receiver on aCodeGenerator."
    codeGenerator := aCodeGenerator! 
write: aPARTSApplication on: aStream
        "Private - Write the source code for aPARTSApplication on aStream."
    self write: aPARTSApplication on: aStream className: nil!  
superExpression: anExpression
		"Private - set the receiver's superexpression."
    superExpression := anExpression!
writeCascadedMessageDefinitionsOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    | aMessageModel |
    messageModels first numberOfArguments > 1
        ifFalse: [ aCodeGeneratorStream indent; cr ].
    1 to: messageModels size do: [ :i |
        aMessageModel := messageModels at: i.
        aMessageModel writeDefinitionOn: aCodeGeneratorStream.
        i = messageModels size ifFalse: [
            aCodeGeneratorStream semicolon; cr ]].
    messageModels first numberOfArguments > 1
        ifFalse: [ aCodeGeneratorStream outdent ]! 
globalVariableModelNamed: aString
        "Private - answer a global variable model named aString."
    ^CodeGenerationPrivateServices globalVariableModel new name: aString!   
classFor: aString
		"Private - answer the class of objects
		whose part name is aString."
    | subnames subname dictionary |
    RootNamingDictionary isNil ifTrue: [
        self buildRootNamingDictionary ].
    dictionary := RootNamingDictionary.
    subnames := self parseSubnames: aString.
    1 to: subnames size - 1 do: [ :i |
        subname := subnames at: i.
        dictionary := dictionary at: subname ifAbsent: [
            ^self cannotFindDictionary: i in: subnames ]].
    ^dictionary at: subnames last ifAbsent: [
        self cannotFindEntry: subnames ]!  
nextPut: aCharacter
		"Private - output aCharacter to the receiver's output stream."
    stream nextPut: aCharacter.
	currentColumn := currentColumn + 1!  
beginMethod: methodName arguments: anArray comment: aString
        "Private - output the text for the begining of a method."
    | comment selectorParts arg selectorPart |
    selectorParts := methodName partSelectorParts.
    comment := self formatComment: aString.
    self
        cr;
        nextPutAll: selectorParts first.
    1 to: anArray size - 1 do: [ :i |
        arg := anArray at: i.
        selectorPart := selectorParts at: i + 1.
        self
            nextPutAll: arg;
            nextPutAll: ' ';
            nextPutAll: selectorPart ].
    anArray notEmpty
        ifTrue: [
            self
                nextPutAll: ' ';
                nextPutAll: anArray last ].
        self cr; indent.
    aString size > 0
        ifTrue: [
            self
                nextPutAll: comment;
                cr]!
getResourceFile
        "Private - create and answer a resource file."
    | splitPath tprPathName extension |
    extension := 'CRS'.
    splitPath := File splitPath: self pathName in: Disk.
    tprPathName := String new asStream.
    tprPathName
        nextPut: splitPath first;
        nextPut: $:;
        nextPutAll: (splitPath at: 2);
        nextPut: $\;
        nextPutAll: splitPath last fileName;
        nextPutAll: '.', extension.
    tprPathName := tprPathName contents.
    ^resourceFile := PARTSResourceFile new
        pathName: tprPathName;
        name: splitPath last fileName, '.', extension;
        yourself!  
pathName
		"Private - answer the name of the output stream."
    ^stream pathName!  
writeArgumentedMessagePatternOn: aCodeGeneratorStream withArguments: anArray
        "Private - output the receiver's message pattern on aCodeGeneratorStream."
    | selectorParts selectorPart argument |
    selectorParts := name partSelectorParts.
    1 to: selectorParts size do: [ :i |
        selectorPart := selectorParts at: i.
        argument := anArray at: i.
        aCodeGeneratorStream
            token: selectorPart;
            token: argument name ]!   
isCreationExpression
		"Private - answer true if the code expressed by the
		reciever explicitely creates an object."
    ^true!   
referenceForReal: anObject
    argumentModels do: [ :argumentModel |
        argumentModel object == anObject
            ifTrue: [ ^argumentModel ]].
    ^nil!  
writeMessageDefinitionsOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    ( messageModels size > 0 and: [ messageModels first numberOfArguments > 1 ] )
        ifTrue: [ aCodeGeneratorStream indent; cr ].
    self isCascaded
        ifTrue: [
            self writeCascadedMessageDefinitionsOn: aCodeGeneratorStream ]
        ifFalse: [
            self writeSingleMessageDefinitionOn: aCodeGeneratorStream ].
    ( messageModels size > 0 and: [ messageModels first numberOfArguments > 1 ] )
        ifTrue: [ aCodeGeneratorStream outdent ] !  
libraryMappings: libraryMappings
        "Private - set the receiver's library mappings."
    libraryBuildingOutput libraryMappings: libraryMappings!   
isVariableReference
		"Private - answer true if the receiver is a variable reference."
    ^true!   
poolNamesString
        "Private - answer a string containing the reciever's pool  names."
    | stream |
    stream := WriteStream on: String new.
    poolNames do: [ :instName |
        stream nextPutAll: instName; nextPut: $  ].
    ^stream contents!   
fileStream: aFileStream
        " Specify the resource file stream. "

    stream := aFileStream asByteFileStream.!
classForSelector: aSymbol
    ^aSymbol first isSymbolCharacter
        ifTrue: [
            ( aSymbol occurrencesOf: $: ) = 0
                ifTrue: [ CodeGenerationUnaryMessage ]
                ifFalse: [ CodeGenerationKeywordMessage ]]
        ifFalse: [ CodeGenerationBinaryMessage ]!  
openParen
		"Private - output a $( on the receiver's output stream."
    self nextPut: $(!  
nextPutAll: aString
		"Private - output aString on the receiver's output stream."
    stream nextPutAll: aString.
	currentColumn := currentColumn + aString size!  
currentDirectory
		"Private - answer the current directory."
    | contextManager |
    contextManager := self partGetExecutionContext.
	contextManager notNil ifTrue: [
		^contextManager inputDirectory ].
    ^CurrentDirectoryName isNil
        ifTrue: [ nil ]
        ifFalse: [ Directory pathName: CurrentDirectoryName ]!   
poolVarString: aString
		"Private - set the names of pool variables
		required to compile the code in the input stream."
    poolVarString := aString! 
argumentModels: anArray
        "Set the argument names of the receiver."
    argumentModels := anArray.
    argumentModels do: [ :argumentModel |
        self addSublanguageModel: argumentModel ]! 
canTriggerEvent: eventName
        "Allow a parts link to hooked to any event off the receiver."
    ^true! 
classModel
        "Answer the model of the class that the reciever is in."
    ^classModel!
addExpression: anExpression for: anObject
		"Private - add a code generator expression to the receiver."
    expressions at: anObject put: anExpression.
    anExpression addTo: self! 
requiresVariable
		"Private - answer true if the reciever's object requires a variable."
    ^false!
isFixedClass
        "Private - answer true if the receiver models a fixed (not variable) class."
    ^true!
replacementMethodFor: aMethod named: aString
        "Private - answer a method to replace aMethod."
    | answer |
    answer := CodeGenerationMethod new.
    answer name: aString.
    answer isMeta: aMethod isMeta.
"don't put them in the dictionary at this time because this method will execute
    while iterating over that dictionary.  This is now done by
        CodeGenerationClass>>outputMethods:on:"
"    ( aMethod isMeta
        ifTrue: [ classMethodModels ]
        ifFalse: [ instanceMethodModels ] ) at: aString asSymbol put: answer."
    self addSublanguageModel: answer.
    answer classModel: self.
    ^answer!  
writeMisc: nameDict
		"Private - write the initialization expressions contained in nameDict."
    | expression object linkExpressions |
    linkExpressions := Set new.
    nameDict associationsDo: [ :assoc |
        expression := assoc value.
        object := expressions keyAtValue: expression.
        (((entryPointReferences includesKey: object) or: [
            rootEntryPointReferences includesKey: object ] ) or: [
                linkEntryPointReferences includesKey: object ] )
            ifFalse: [
                expression partEmitExpressionOn: self.
                self punctuation: '.'; cr ]].
    self endMethod!  
rootObject
		"Private - answer the root object."
	^self parentClassModel object
!  
messageModelsAttribute: aCollection
        "Private - set the receiver's message models."
    messageModels := aCollection!
registerLibraryMappings
        "Private - compute any necessary library imports and register them with the builder."
    self computeImports.
    ( libraryMappings size > 0 and: [ libraryBuilder notNil ] ) ifTrue: [
        libraryMappings associationsDo: [ :assoc |
            libraryBuilder
                addImport: assoc key
                fromLibrary: assoc value ]]!   
atIndex: anInteger
		"Answer the value at index anInteger."
    ^self at: (orderedKeys at: anInteger)!  
outputClassModels
    classModels do: [ :classModel |
        classModel outputOn: output ]!
new
		"Private - answer an initialized instance of the receiver."
	^super new initialize!   
mainObject: anObject
    ^root at: 'Main Object' put: anObject!  
addArgumentReferencesTo: aCodeGenerator
		"Private - add the reciever's argument references
		to aCodeGenerator."
    arguments notNil ifTrue: [
        arguments do: [ :arrayOfArgRefs |
            arrayOfArgRefs notNil ifTrue: [
                arrayOfArgRefs do: [ :argRef |
                    aCodeGenerator addReference: argRef ]]]].!   
codeGenerationLanguageIn: aCodeGenerator
        "Smalltalk code generation - answer a message expression model of the receiver."
    ^self partIsLiteral
        ifTrue: [ aCodeGenerator literalModelFor: self ]
        ifFalse: [ self codeGenerationMessageExpressionIn: aCodeGenerator ]!   
name: aString
        "Set the receiver's name."
    name := aString!   
mainClassModel
        "Private - answer the receiver's main class model."
    ^classModels first!  
notify: aString
		"Private - output aString as a notification to the log stream."
    interactive
        ifTrue: [MessageBox message: aString]
        ifFalse: [self logStream cr; show: ' >> Notify: ', aString]!  
addSelector: aSelector
        "Add a new message to the receiver’s list of messages.  Set the selector
        of the new message to be aSelector.  Answer the new message."

    | answer |
    answer := CodeGenerationPrivateServices messageModel selector: aSelector.
    self addMessageModel: answer.
    ^answer! 
name
        "Private - answer the name of the receiver."
    ^self classDefinitionModel name!  
checkRequiredClasses
		"Private - answer true if the classes required for compilation exist."
    | newClassesString okName |
    newClassesString := WriteStream on: String new.
    requiredClassesString asArrayOfSubstrings do: [ :className |
        okName := self insureClassExists: className.
        okName isNil ifTrue: [^false].
        newClassesString nextPutAll: okName; nextPut: Space ].
    requiredClassesString := newClassesString contents.
    ^true! 
printOn: aStream
		"Private - print the receiver on aStream."
    aStream
        nextPutAll: self class name;
        nextPutAll: ' named: ';
        nextPutAll: self name printString!
partIsCodeGeneratorExpression
		"Private - answer true if the receiver is a parts code generator expression."
    ^true!
addGlobalReference: aReference
		"Private - add a global reference to the receiver."
    globalReferences add: aReference!  
codeGenerationAddComponentMessageModelsTo: anExpressionModel
        "Private - the receiver is a component of  a parts application.
        Add message models to rebuild the receiver to anExpressionModel."

    self
        codeGenerationAddAttributeMessagesTo:  anExpressionModel;
        codeGenerationAddInstanceEventMessagesTo:  anExpressionModel;
        codeGenerationAddLinkMessageModelsTo: anExpressionModel
!
parent: aLanguageModelOrCodeGenerator
    parent := aLanguageModelOrCodeGenerator!   
selector: aSymbol
    super selector: aSymbol.
    numberOfArguments := aSymbol occurrencesOf: $:!  
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addLinkEntryPointReference: self!  
name: aString
    name := aString asString!  
setDirectoryName: aString
        "Set the directory name of the receiver."
    self pathName: aString, '\', self fileName! 
classModel
        "Answer the model of the class that the reciever is in."
    ^parent classModel! 
partCodeGeneratorExpression: aCodeGenerator
        "Private - Answer an empty part code generator expression.  This is used to
        support customer implementations of this method.  The additions
        to the empty part code generator expression added by customer
        implementations of this method will be transfered to a new style code generator
        message expression.  Digitalk recommends that customer replace
        implementations of this method with a method named
        #codeGeneratorAddAttributeMessagesTo:.  See documentation
        for instructions on how to do that."

    ^PARTSCodeGeneratorInterface expressionClass new receiver:
            ( PARTSCodeGeneratorInterface creationExpressionClass new
                receiver: self class
                selector: #new )!  
reference: anObject with: aReferenceModel
    referenceModels at: anObject put: aReferenceModel.
    aReferenceModel traverseOn: self!  
beginMethod: methodName comment: aString
		"Private - output the text for the begining of a method."
    | comment |
    comment := self formatComment: aString.
    self
        cr;
        nextPutAll: methodName;
        cr;
        indent.
    aString size > 0
        ifTrue: [
            self
                nextPutAll: comment;
                cr]!  
applicationArgumentModels
        "Private - code generation - answer an Array of one
        containing an argument model representing the receiver."
    ^Array with: self applicationArgumentModel! 
outputOn: aCodeGeneratorOutput
        "Private - output the receiver on aCodeGeneratorOutput."
    | stream source |
    predefinedSource notNil
        ifTrue: [
                "predefined source has precedence over computed
                source.  This feature if used for scripts-turned-into-methods."
            ^self outputPredefinedSourceOn: aCodeGeneratorOutput ].
    stream := CodeGenerationPrivateServices codeGeneratorStream new.
    self writeDefinitionOn: stream.
    source := stream contents.
    [ self checkNumberOfMessageSends.
     aCodeGeneratorOutput
        addMethodInClassNamed: self className
        meta: isMeta
        sourceString: source ]
            on: CodeGenerationMethodTooLarge
            do: [ :methodTooLarge |
                methodTooLarge
                    replacementMethods: self divideMethod;
                    pass ] "pass to CodeGenerationClass>>outputMethods:on:
                        so that method can queue up the replacements to the
                        output."!   
addEntry: aCodeGeneratorEntry
		"Private - add a code generator entry to the receiver."
    | object existingEntry |
    object := aCodeGeneratorEntry object.
    object isNil ifTrue: [ ^aCodeGeneratorEntry ].
    existingEntry := entries at: object ifAbsent: [
        ^self addNewEntry: aCodeGeneratorEntry ].
    existingEntry subsume: aCodeGeneratorEntry.
    ^existingEntry!   
partIsCodeGeneratorReference
		"Private - answer true if the receiver is a parts code generator reference."
    ^true!  
writeSourceFile: anApplication stream: aStream  libraryMappings: libraryMappings
        "Private - write the Smalltalk library file described by aFileDescriptor."
    | realMappings |
    output := CodeGeneratorChunkFileOutput on: aStream.
    realMappings := libraryMappings isNil
        ifTrue: [ Dictionary new ]
        ifFalse: [ libraryMappings ].
    anApplication components do: [ :part |
        part class library isNil
            ifFalse: [
                realMappings at: part put: part class library ]].
    output libraryMappings: realMappings.
    self
        write: anApplication
        output: output
!  
removePrivatePools
        "Private - remove from Smalltalk the pools that are private to the receiver."
    self myPrivatePools do: [ :symbol |
        Smalltalk removeKey: symbol ifAbsent: [ ]]!   
partCanChangeFont
        "Private - Answer whether the receiver's font can be changed."
    ^false
!  
getCompiler
        "Private - answers a Compiler for the receiver."
    | compiler |
    compiler := CompilerInterface forClass:
        ( class isNil ifTrue: [ UndefinedObject ] ifFalse: [ class ] ).
    compiler errorHandler: self getErrorHandler.
    ^compiler!   
initializeForOperationOn: aStream
        " Private - initialize state for an operation on aStream. "
	^aStream.
! 
openSquareBracket
        "Private - output a $[ to the output stream."
    self bracketingCharacter: $[!   
logStream
		"Private - answer a stream on which to log messages."
    ^logStream isNil
        ifTrue: [logStream := self getLogStream]
        ifFalse: [logStream]! 
removeSelector: aSelector
		"Private - remove the message associated with aSelector."
    1 to: selectors size do: [ :i |
        (selectors at: i) == aSelector
            ifTrue: [
                selectors removeIndex: i.
                arguments removeIndex: i.
                ^self ]]!   
numberOfMessageSends
        "Private - answer the number of message sends contained in the receiver."
    ^argumentModels inject: 1 into: [ :a :b | a + b numberOfMessageSends ]!  
codeGenerationAddInstanceEventMessagesTo: anExpressionModel
        "Private - the receiver is a component of  a parts application.
        Add  to anExpressionModel message models to set the
        receiver's instance events."
    | instanceEvents wrapper |
    wrapper := self partWrapper.
    wrapper isNil ifTrue: [ ^self ].
    instanceEvents := wrapper instanceEvents.
    instanceEvents do: [ :symbol |
        anExpressionModel
            addSelector: #partDefineEvent: with: symbol ]! 
addClassNamed: aClassName
superclassName: superClassName
indexableType: indexableType
instanceVariableNames: instanceVariableString
classVariableNames: classVariableString
poolNames: poolNamesString
classInstanceVariableNames: classInstanceVariableNamesString

    "Private - output a class named aClassName."

    | class |
"    self insurePoolsExist: poolNamesString."
    class := DefinitionInstaller current
        defineClassNamed: aClassName
        subclassOf: ( Smalltalk at: superClassName asSymbol )
        instanceVariableNames: instanceVariableString
        variable: ( self class isNotIndexedObjectStructureString: indexableType ) not
        pointers: ( self class isIndexedBytesObjectStructureString: indexableType ) not
        classVariableNames: classVariableString
        poolDictionaries: poolNamesString.
    DefinitionInstaller current
        setClassInstanceVariableNames: classInstanceVariableNamesString
        forClass: class.
    classesOutputted add: class.
    ^class!   
write: anObject output: aCodeGeneratorOutput
        "Write the Smalltalk source code that represents anObject on aCodeGeneratorOutput."
    output := aCodeGeneratorOutput.
    anObject addLanguageModelsTo: self.
    self outputLanguageModels.
    output close!
name: aString
		"Private - set the name of the receiver."
    name = aString ifFalse: [
        name := aString.
        references notNil ifTrue: [
            references do: [ :ref | ref name: aString ]]]!  
eventTable
        "Private - answer a Dictionary mapping event names to actions
        for the receiver."
    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]! 
initialize
        "Private - initialize the receiver."
"    self makeFixedClass."
    ^super initialize!  
addEntryTo: aCodeGenerator
		"Private - add the receiver's entry to aCodeGenerator."
    entry := aCodeGenerator addEntry: entry!   
getResourceFrom: start to: stop
        " Private "
    | receiver selector |
    stream position: start.
    stream upTo: $!!.
    receiver := stream upTo: $!!.
    receiver := CompilerInterface evaluate: receiver.
    selector := stream upTo: $!!.
    selector := selector trimBlanks asSymbol.
    stream next.
    ^receiver perform: selector with: stream!  
new
		"Answer an initialized version of the receiver."
    ^super new initialize!   
binaryResourceExpressionFor: anObject ifAbsentExpression: aCodeGeneratorExpression
        "Store anObject in the current resource file and
        answer a code generator expression that will extract
        the object from that file.  The code described by
        aCodeGeneratorExpression will be emited in the
        ifAbsent: block in the generated code which will
        look like this:
            PARTSResourceFile
                named: <aString>
                resource: <anInteger>
                ifAbsent: [ <some code> ].
        When the PARTSApplication is being reconstructed
        from the generated code, if the resource file is not
        found, the result of the evaluate of the ifAbsent: block
        will be substituted for the anObject."
    | aResourceFile resourceId |
    aResourceFile := self resourceFile.
    resourceId := aResourceFile store: anObject.
    ^PARTSCodeGeneratorInterface resourceExpressionClass new
        receiver: resourceFile class
        selector: #named:resource:ifAbsent:
        arguments: ( Array
            with: (  PARTSCodeGeneratorInterface referenceFor: aResourceFile name )
            with: (  PARTSCodeGeneratorInterface referenceFor: resourceId ));
        ifAbsentExpression: aCodeGeneratorExpression!   
punctuation: aString
        "Private - output aString on the receiver's output stream.
        aString is assummed to be punctuation."
    self
        position: ( self position - 1 );
        nextPutAll: aString!   
cannotFindDictionary: index in: subnames
		"Private - the receiver cannot find an entry for
		the index'th subname in subnames."
    ^self cannotFindEntry: subnames!  
name: aString
		"Private - set the receiver's name."
    name := aString!   
objectNamed: aString
		"Private - answer the object named aString."
	^objectsDictionary at: aString ifAbsent: [
		self error: 'Object not found' ]!
variableName
		"Private - answer the name of the variable that
		will be used by the receiver in generated source."
    ^variableName! 
openParen
        "Output a '(' on the receiver's output stream."
    self bracketingCharacter: $(! 
store: anObject
		"Private - store anObject on the receiver if it hasn't already been stored."
    ^seenDictionary at: anObject ifAbsent: [
        self realStore: anObject]! 
keys
    "Answer an OrderedCollection containing all of the keys in the receiver."
    ^orderedKeys copy!   
closeSquareBracket
        "Private - output a $] to the output stream."
    self bracketingCharacter: $]!  
initialize
        "Private - initialize the receiver."
    messageModels := OrderedCollection new.
    super initialize!  
partCanChangeFont
        "Private - Answer whether the receiver's font can be changed."
    ^true

! 
classVariableNamesString
        "Private - answer a string containing the reciever's class
        variable names."
    | stream |
    stream := WriteStream on: String new.
    classVariableNames do: [ :instName |
        stream nextPutAll: instName; nextPut: $  ].
    ^stream contents!   
generateClassName: className
        "Private - there exists a subclass of
        the receiver named className.  Generate
        a class name that doesn't collide with anything."
    | n answer |
    n := 1.
    answer := className.
    [ Smalltalk includesKey: answer asSymbol ]
        whileTrue: [
            answer := className, n printString.
            n := n + 1 ].
    ^answer asSymbol! 
getLogStream
        "Private - get a stream to log messages to from the
        receiver's execution context manager."
    | contextManager |
    contextManager := self partGetExecutionContext.
    ^logStream := contextManager isNil
        ifTrue: [ self openLogWindow ]
        ifFalse: [ contextManager logStream ]!
close
        "Private - close the reciever.  If the receiver's output is transient (as in the
        case where the class was built only to support producing an SLL) remove
        all the classes produced."
    outputIsTransient
        ifTrue: [ self removeOutputFromImage ].
    ^super close
! 
poolName: aPoolName varName: aVarName
		"Answer an instance of the receiver for
		a pool named aPoolName and variable
		named aVarName."
    ^self new poolName: aPoolName; name: aVarName!   
outdent
		"Private - reduce the indention level by 1."
    indentLevel := indentLevel - 1!  
receiverModel: aLanguageModel
        "Private - "
"    self ASSERT: aLanguageModel ~~ self.
    self ASSERT: self sender == self."
  " privacyViolation"
    receiverModel := aLanguageModel.
    self addSublanguageModel: aLanguageModel!
writeMethods: aDictionary
    | set |
    set := Set new.
    aDictionary do: [ :ref |
        [set includes: ref name]
            whileTrue: ["Terminal bell." ref name: ref name, 'X' ].
        set add: ref name].
    (aDictionary asSortedCollection: [ :a :b |
        a name < b name] ) do: [ :ref |
            ref writeMethodOn: self ]!
insureNewClassNameInteractive: aString
		"Private - compute and answer a class name based on
		aString insuring this name is not an existing global variable name."
    | answer global |
    aString isNil ifTrue: [^nil].
    (Smalltalk includesKey: aString asSymbol)
        ifTrue: [
            global := Smalltalk at: aString asSymbol.
            global isClass
                ifTrue: [
                    ^(MessageBox confirm: aString,
                        ' is already a class.  Overwrite it?' )
                            ifTrue: [aString]
                            ifFalse: [
                                answer := Prompter
                                    prompt: 'Enter new class name:'
                                    default: aString, 'X'.
                                self insureNewClassName: answer]]
                ifFalse: [
                    answer := Prompter
                        prompt: aString, ' is already a global.  Enter new name:'
                        default: aString, 'X'.
                    ^self insureNewClassName: answer]]
        ifFalse: [^aString]!  
with: suboutput with: suboutput2
        "Answer an instance of the receiver with two suboutputs."
    ^self new
        addSuboutput: suboutput;
        addSuboutput: suboutput2!   
application: aPARTSApplication
        "Private - Set the application and build the root reference."
    | varName |
    varName := aPARTSApplication name.
    applicationExtent := aPARTSApplication editorVirtualScreenExtent.
    rootReference := ( ( PARTSCodeGeneratorRootEntryPointReference for: aPARTSApplication )
        methodName: 'buildPARTSApplication';
        name: varName;
        comment: 'Build ', varName, ', the PARTS application itselt.').
    self addReference: rootReference!  
codeGenerationAddBuildComponentMethodModelTo: aClassModel
        "Private - add a method model to aClassModel that models the receiver
        as a component of a parts application."
    | methodModel methodName expression application |
    application := self partApplication.
    methodName := application selectorForComponentBuild: self.
    methodModel := aClassModel newClassMethodNamed: methodName.
    methodModel
        isMeta: true;
        argumentModels: application applicationArgumentModels;
        comment: 'Build the component named ', self partName, '.'.
    expression := methodModel newMessageExpression.
    expression receiverObject: self.
    self codeGenerationAddComponentMessageModelsTo: expression.
    expression addSelector: #yourself!   
computeImportsInClass: aClass
        "Private - compute any necessary library imports in aClass."
    aClass methodDictionary do: [ :cm |
        self computeImportsInMethod: cm ].
    aClass class methodDictionary do: [ :cm |
        self computeImportsInMethod: cm ].!  
generatedClass: aClass
        "Private - set the receiver's generated class."
    generatedClass := aClass!
classField: aClass
		"Private - set the class that the receiver
		is filing in."
	class := aClass! 
classVarString: aString
		"Private - set the class variable string of the receiver."
    classVarString := aString! 
insureArgumentModelsBuilt
        "Private - if the reciever doesn't have any argument models
        set, build them from the argument objects.  Unary messages
        have no arguments, so do nothing."!   
expression: anExpression
		"Private - set the code generator expression of the receiver's object."
    expression := anExpression!  
createApplication
    ^self new answer!  
isGlobalReference
		"Private - answer true if the receiver is a global reference."
    ^false!  
submethodNumbered: anInteger
        "Private - the receiver may be too large to be compiled and
        needs to be replaced by two or more smaller methods.  The
        first replacement method will be a truncated version of the
        receiver.  Subsequent replacement methods will be produced
        by this method."
    | subname answer |
    subname := 'x', anInteger printString, name.
    answer := self replacementMethodNamed: subname.
    ^answer!  
partFileName
        "Answer the file name (not full path) of the receiver."
    ^self class partFileName!  
numberOfMessageSends
        "Private - answer the number of message sends contained in the receiver."
    ^1
!
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
isLiteralReference
		"Private - answer true if the receiver is a reference
		to an object that can be expressed as a literal."
    ^true!  
formatComment: aString
        "Answer a copy of aString formatted as you'd see it in method source."
    | lineBuffer answer words margin maxWidth word |
    aString isNil ifTrue: [ ^String new ].
    maxWidth := 60.
    answer := WriteStream on: String new.
    lineBuffer := WriteStream on: String new.
    margin := (String new: 8) atAllPut: $  .
    lineBuffer nextPutAll: margin; nextPut: $".
    words := aString asArrayOfSubstrings.
    1 to: words size do: [ :i |
        word := words at: i.
        lineBuffer position + word size > maxWidth
            ifTrue: [
                answer nextPutAll: lineBuffer contents; cr.
                lineBuffer := WriteStream on: String new.
                lineBuffer nextPutAll: margin].
        lineBuffer nextPutAll: word; nextPut: $ ].
    lineBuffer position = margin size ifFalse: [
        answer nextPutAll: lineBuffer contents].
    answer nextPut: $".
    ^answer contents!  
write: aPARTSApplication on: aStream className: aString
        "Private - Write the source code for aPARTSApplication on aStream
        with class name aString."
    self new write: aPARTSApplication on: aStream className: aString!  
suboutputsDo: aBlock
        "Private - for every suboutput, evaluate a block with that
        suboutput as the block argument."
    | answer |
    answer := OrderedCollection new.
    suboutputs do: [ :suboutput |
        answer add: ( aBlock value: suboutput ) ].
    ^answer!
partSearch: aPoolDictionary forStylePrefix: aString
		"Private - answer the names of all the values in aPoolDictionary
		that are prefixed by aString and whose values are encoded in
		the receiver's style."
    | answer subDict constant style sortedAssocs |
    style := self style.
    answer := OrderedCollection new.
    style isNil ifTrue: [^answer].
    subDict := aPoolDictionary associationsSelect: [ :a |
        a key size > aString size and: [
            (a key copyFrom: 1 to: aString size) = aString]].
    sortedAssocs := SortedCollection sortBlock: [ :a :b | a value >= b value ].
    subDict := subDict associationsDo: [ :assoc | sortedAssocs add: assoc ].
    sortedAssocs do: [ :a |
        constant := a value.
        constant = 0 ifFalse: [
            (self hasStyle: constant)
                ifTrue: [ answer addLast: a key ]]].
    ^answer!   
initialize
    self addInitialSuboutputs!
addEntryPointReference: aReference
		"Private - add an entry point reference to the receiver."
    | object |
    object := aReference object.
    (entryPointReferences at: object ifAbsent: [
        entryPointReferences at: object put: Set new ] )
            add: aReference!   
replacementMethods: aCollection
        "Private - an attempt has been made to compile a method that is too
        large to compile.  Replacements for that method model will be added to
        the receiver via this method before the receiver is signalled."
    replacementMethods := aCollection! 
fileInFrom: aStream
		"Compile the code in aStream."
    ^self new fileInFrom: aStream! 
addSelector: aSelector
        "Add aSelector without any args."
    selectors isNil ifTrue: [
        selectors := OrderedCollection new.
        arguments := OrderedCollection new].
    selectors addLast: aSelector.
    arguments addLast: nil!   
outputPoolsOn: aCodeGeneratorOutput
        "Private - output the pools used by the receiver on aCodeGeneratorOutput."
    | poolsListMethod |
    pools associationsDo: [ :assoc |
        assoc value do: [ :varName |
            aCodeGeneratorOutput
                addPoolVariableNamed: varName
                inPoolNamed: assoc key ]].
        "add a class method to record the private pools:"
    poolsListMethod := self newClassMethodNamed: 'myPrivatePools'.
    poolsListMethod
        comment: 'Private - answer the names of the pools that are private to the receive.';
        newLiteralModelFor: pools keys asArray!  
addClassNamed: aClassName
superclassName: superClassName
indexableType: aBoolean
instanceVariableNames: instanceVariableString
classVariableNames: classVariableString
poolNames: poolNamesString
classInstanceVariableNames: classInstanceVariableNamesString

    "Private - output a class named aClassName."

    "store all class names and write them when the receiver receives the #close message."

    classNamesToWrite isNil ifTrue: [ classNamesToWrite := OrderedCollection new ].
    classNamesToWrite add: aClassName!  
writeSourceCode
        "Private - write the source code the the output stream."
    self writeHeader ifFalse: [ ^nil ].
    self
        writeInitMethod;
        writeAccessorMethods;
        writeMiscMethods;
        writeComponentMethods;
        writeRootSendersMethod;
        writeLinkMethods;
        writeLinkSendersMethod;
        writeAnswerMethod;
        nextPutAll: '  !!'; cr;
        close!
partAddScriptExpressionsTo: aCodeGeneratorExpression
        "PARTS CodeGenerator - Add expressions of the receiver's PARTS
        scripts to aCodeGeneratorExpression."
    | wrapper scripts methodName |
    wrapper := self partWrapper.
    wrapper notNil ifTrue: [
        scripts := wrapper scripts.
        scripts notNil ifTrue: [
            scripts do: [ :cm |
                methodName := 'scriptFor', wrapper name, cm selector.
                methodName := methodName reject: [ :c | c = $: ].
                aCodeGeneratorExpression
                    addSelector: #partDefineScript:
                    arguments: ( Array with:
                     (( PARTSCodeGeneratorInterface entryPointReferenceClass for: cm source )
                                methodName: methodName;
                                comment: 'Answer the source code for script ', wrapper name,
                                '>>', cm selector, '. '))  ]]]! 
notIndexedObjectStructureString
    ^self objectStructureStringList first!   
token: aString
		"Private - output aString on the receiver's output stream."
    self nextPutAll: aString; nextPut: $  .!   
new: aString libraryName: aLibraryName
        "Private - answer an object specified by aString.
        aString is a part name which contains the name of a
        class.  If that class in not in the image, bind the Smalltalk
        library file named aLibraryName."
    | class className names |
    names := self parseSubnames: aString.
    className := names last.
    class := Smalltalk at: className asSymbol ifAbsent: [ nil ].
    class isNil
        ifTrue: [
            SmalltalkLibraryBinder bindTo: aLibraryName.
            class := Smalltalk at: className asSymbol ifAbsent: [ nil ]].
    ^class isClass
        ifTrue: [ class new ]
        ifFalse: [ self cannotFindEntry: names ]! 
addArgument: anObject
    | argumentModel |
    arguments add: anObject.
    argumentModel := self referenceFor: anObject.
    self addArgumentModel: argumentModel!  
isLiteralReference
		"Private - answer true if the receiver is a reference
		to an object that can be expressed as a literal."
    ^false! 
partSelectorParts
        "Answer an Array of Strings, a representation of the
        receiver as it would be expressed as a selector in
        source code."
    | numberColons answer stream first |
    numberColons := self occurrencesOf: $:.
    numberColons < 2 ifTrue: [^Array with: self].
    answer := Array new: numberColons.
    stream := ReadStream on: self.
    first := 1.
    1 to: answer size do: [ :i |
        stream skipTo: $:.
        answer at: i put:
            (stream copyFrom: first to: stream position).
        first := stream position + 1].
    ^answer!   
isRootModel
        "Private - answer whether or not the receiver is a root language model."
    ^false!
name
        "Private - answer the name of the receiver."
    ^'self'!  
tabString: aString
        "Set the string to be used for tabs."
    tabString := aString!  
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
reportWarning: error
    "Private-tell the user about the error.
    Over ride the default implementation in order
    to write the message to receiver's stream."
    | source position |
    logStream isNil ifTrue: [ logStream := self getLogStream ].
    source := error sourceCode.
    position := error sourcePosition.
    logStream  cr; nextPutAll: '"--- compilation error compiling generated source code'.
    logStream nextPutAll: ' ---"';
        cr; nextPutAll: (source copyFrom: 1 to: (0 max: position - 1));
        cr; nextPutAll: '"' , error errorMessage trimBlanks , '--->"';
        cr; nextPutAll: (source copyFrom: (1 max: position) to: error sourceCode size);
        cr; show: '"-------------------------"'! 
createOutputToImage
    ^imageOutput := CodeGeneratorOutputToImage new
        outputIsTransient: true;
        yourself!  
fileName
        "Answer the file name (not full path) of the receiver."
    ^self pathName fileNameLessPath!   
codeGenerationAddColorAndFontMessagesTo:  anExpressionModel
        "Private - add message models to anExpressionModel to rebuild the
        receiver's colors and font."
    anExpressionModel
        addSelectorIfNotNil: #foreColor: with: self foreColor;
        addSelectorIfNotNil: #backColor: with: self backColor.
    self partCanChangeFont ifTrue: [
        anExpressionModel addSelectorIfNotNil: #font: with: self font ]
! 
writeExpressionSeriesOn: aCodeGeneratorStream
        "Private - write the reciever's expressions on aCodeGeneratorStream."
    | expressionModel |
    1 to: expressionModels size do: [ :i |
        expressionModel := expressionModels at: i.
        i = expressionModels size
            ifTrue: [
                aCodeGeneratorStream nextPutAll: '^' ].
        expressionModel writeDefinitionOn: aCodeGeneratorStream.
        i = expressionModels size
            ifFalse: [
                aCodeGeneratorStream nextPut: $.; cr ]]!   
count
    Count isNil ifTrue: [ Count := 0 ].
    ^Count := Count + 1!  
partIsLiteral
        "Private - answer if the receiver is can be expressed in source code
        as a literal."
    self size > 2000 ifTrue: [ ^false ].
    self do: [ :obj |
        obj partIsArrayElementLiteral ifFalse: [ ^false ]].
    ^true! 
outputLanguageModels
    self
        outputClassModels;
        outputLooseMethodModels!  
reference: anObject withMethodArgumentNamed: aString

    self todo!
classInstanceVariableNamesString
        "Private - answer a string containing the reciever's class
        instance variable names."
    | stream |
    stream := WriteStream on: String new.
    classInstanceVariableNames do: [ :instName |
        stream nextPutAll: instName; nextPut: $  ].
    ^stream contents!  
brokenUp
        "Private - the receiver contains more than the maximum number
        of message sends allowed.  Answer a collection of expression
        models, each within the message send limit, that embody the
        semantics of the receiver."
    | answer expression sends someMethodModels |
    answer := OrderedCollection new.
    sends := 0.
    expression := self copyWithoutMessages.
    someMethodModels := OrderedCollection new.
    messageModels do: [ :message |
        sends := sends + message numberOfMessageSends.
        sends >= self maxMessageSends
            ifTrue: [
                expression messageModelsAttribute: someMethodModels.
                answer add: expression.
                sends := message numberOfMessageSends.
                someMethodModels := OrderedCollection with: message.
                expression := self copyWithoutMessages ]
            ifFalse: [
                someMethodModels add: message ]].
    someMethodModels size > 0 ifTrue: [
        expression messageModelsAttribute: someMethodModels.
        answer add: expression ].
    ^answer! 
outputDefinitionOn: aCodeGeneratorOutput
        "Private - output the reciever's definition on aCodeGeneratorOutput"
    classDefinitionModel outputOn: aCodeGeneratorOutput!  
nextPut: aCharacter
        "Output aCharacter on the receiver."
    super nextPut: aCharacter.
    currentColumn := currentColumn + 1!
classModel: aClassModel
        "Private - set the receiver's class model."
    classModel := aClassModel!  
initialize
		"Private - initialize the receiver."
    expressions := PARTSOrderedIdentityDictionary new.
    poolReferences := Set new.
    globalReferences := Set new.
    classReferences := Set new.
    entryPointReferences := PARTSOrderedIdentityDictionary new.
    rootEntryPointReferences := PARTSOrderedIdentityDictionary new.
    linkEntryPointReferences := PARTSOrderedIdentityDictionary new.
    expressionReferences := PARTSOrderedIdentityDictionary new.
    entries := PARTSOrderedIdentityDictionary new.
    classesNeeded := Set new.
    indentLevel := 0.
    instVarNames := Dictionary new.
	currentColumn := 1!
partAddFramingBlockExpressionTo: aCodeGeneratorExpression
		"Private - add messages to aCodeGeneratorExpression to
		reconstruct and set the receiver's framing block."
    aCodeGeneratorExpression
        addSelector: #framingBlock:
            arguments: ( Array with: ( PARTSCodeGeneratorInterface referenceFor:  self framingBlock ))! 
for: aReference in: aCodeGenerator
		"Private - answer an instance of the receiver for
		aReference in aCodeGenerator."
    ^self new
        object: aReference object;
        addReference: aReference;
        expression: ( aReference object partCodeGeneratorExpression: aCodeGenerator )!   
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    aCodeGeneratorStream token: self name!
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addExpressionReference: self!  
name
		"Private - answer the receiver's name."
    ^name!   
printOn: aStream
    | left right |
    left := argumentModels first object.
    right := argumentModels last object.
    left printOn: aStream.
    aStream nextPutAll: ' ', selector, ' '.
    right printOn: aStream!
open
        "Create the PARTSApplication described by the receiver
        and open it."
    ^self application enableExecution open!  
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^denominator partIsLiteral and: [ numerator partIsLiteral ]! 
writeArgumentDefinition: anArgumentModel on: aCodeGeneratorStream
    | requiresParens |
    requiresParens := anArgumentModel requiresParensAsArgumentOf: self.
    requiresParens ifTrue: [ aCodeGeneratorStream openParen ].
    anArgumentModel writeDefinitionOn: aCodeGeneratorStream.
    requiresParens ifTrue: [ aCodeGeneratorStream closeParen ].!
makeFixedClass
        "Set the receiver to model a fixed (not variable) class."
    self setFixed! 
writeFileName: aString
		"Private - write the source code representation of the
		receiver's parts application on the file named aString."
    className isNil ifTrue: [
        className := self getClassName].
    className isNil ifTrue: [^self].
    stream := File newFile: aString.
    self writeSourceCode!  
writeReceiverDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    | requiresParentheses |
    requiresParentheses := messageModels size > 0 and: [
        receiverModel requiresParensAsReceiverOf: self ].
    requiresParentheses ifTrue: [ aCodeGeneratorStream openParen ].
    receiverModel writeDefinitionOn: aCodeGeneratorStream.
    requiresParentheses ifTrue: [ aCodeGeneratorStream closeParen ].!  
object: anObject
		"Private - set the object that the receiver represents."
    object := anObject! 
classInstanceVariableNames: aCollection
        "Set the receiver's class instance variable names to anOrderedCollection."
    classInstanceVariableNames := aCollection asOrderedCollection!   
writeCommentOn: aCodeGeneratorStream
        "Private - write the reciever's comment on aCodeGeneratorStream."
    | text |
    text := comment isNil
        ifTrue: [ 'Private - (no comment supplied)' ]
        ifFalse: [ comment ].
    aCodeGeneratorStream nextPut: $"; nextPutAll: text; nextPut: $"!  
contents: anObject
        "Set the contents of the receiver."
    contents := anObject!
addMethodInClassNamed: aClassName meta: aBoolean sourceString: aString notifying: aCompilerErrorNotifier
        "Add a  method to the class named aClassName.
        Raise a CannotOutputMethod exception if the operation
        cannot be completed.   Do nothing,
        this work will be handled by the receiver's partner,
        a CodeGeneratorOutputToImage."! 
setDirectory: aDirectory
        "Set the directory of the receiver."
    self setDirectoryName: aDirectory drivePathName!  
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    self
        codeGenerationAddColorAndFontMessagesTo: anExpressionModel;
        codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #owner: with: owner;
        addSelectorIfTrue: #dragSource: with: self isDragSource.
    self isDragTarget
        ifTrue: [
            anExpressionModel
                addSelector: #dragTargetForFormats:operations:
                with: self dragTargetFormats
                with: self dragTargetOperations ]

! 
outputOn: aCodeGeneratorOutput
        "Private - output the reciever on aCodeGeneratorOutput"
    self
        defineImportedPools;
        outputPoolsOn: aCodeGeneratorOutput;
        outputDefinitionOn: aCodeGeneratorOutput;
        outputClassMethodsOn: aCodeGeneratorOutput;
        outputInstanceMethodsOn: aCodeGeneratorOutput! 
initialize
        "Private - initialize the receiver."
    classesOutputted := OrderedCollection new.
    outputIsTransient := false.
    poolDictionaries := Dictionary new.
    ^super initialize!
addPoolVariableNamed: aString inPoolNamed: aPoolName
        "Add a pool variable named aString to the pool
        named aPoolName."
    self implementedBySubclass!  
pathName: aPathName
        "Private - answer an instance of the receiver with a
        path name of aPathName."
    ^self new
        newStream: (File newFile: aPathName)! 
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    self implementedBySubclass!   
addReference: aReference
		"Private - add aReference to the receiver."
    aReference object isClass ifTrue: [
        self addNeededClass: aReference object ].
    ^aReference addTo: self! 
newLiteralModelFor: aLiteralObject
        "Add to the receiver's list of expression models a literal
        model for aLiteralObject.  Answer the literal model."
    | literalModel |
    literalModel := CodeGenerationPrivateServices literalModel new.
    literalModel contents: aLiteralObject.
    self addExpressionModel: literalModel.
    ^literalModel!  
addExpressionsTo: aMethod startingAt: anInteger
        "Private - the receiver is likely too large to compile.  aMethod
        is one of two or more methods that will replace the receiver.
        Add the receiver's expression models, starting at anInteger,
        to aMethod.  Do not add enough expression models to aMethod
        to make it to big to compile.  Answer the index of the last
        expression model added to aMethod."
    | messageSends expressionModel answer |
    messageSends := 0.
    anInteger to: expressionModels size do: [ :i |
        answer := i.
        expressionModel := expressionModels at: i.
        messageSends := messageSends + expressionModel numberOfMessageSends.
        messageSends >= self maxMessageSends
            ifTrue: [ ^i - 1 ].
        aMethod privateAddExpressionModel: expressionModel ].
    ^answer!
applicationExtent
		"Private - answer the extent of the parts application."
    ^applicationExtent! 
insureClassExists: aClassName
		"Private - insure a class named aClassName exists.  If it doesn't
		prompt the user to input the name of a replacement class."
    | symbol global newName |
    interactive ifFalse: [
        ^(Smalltalk at: aClassName trimBlanks asSymbol ifAbsent: [])
            isClass
                ifTrue: [aClassName]
                ifFalse: [
                    self notify: 'Required class ', aClassName, ' not found.'.
                    nil]].
    aClassName isNil ifTrue: [^nil].
    symbol := aClassName trimBlanks asSymbol.
    (Smalltalk includesKey: symbol)
        ifTrue: [
            global := Smalltalk at: symbol.
            global isClass
                ifTrue: [^aClassName]
                ifFalse: [
                    newName := self
                        prompt: symbol, ' is not a class, enter new class name'
                        default: symbol asString.
                    ^self insureClassExists: newName]]
        ifFalse: [
            newName := self
                prompt: symbol, ' is not in system, enter new class name'
                default: symbol asString.
            ^self insureClassExists: newName]! 
fileExtension
        "Private - answer the file extension for resource files."
    ^'CRS'! 
object
        "Private - answer the object modelled."
    ^object! 
formatComment: aString
        "Answer a copy of aString formatted as you'd see it in method source."
    | lineBuffer answer words margin maxWidth word |
    aString isNil ifTrue: [ ^String new ].
    maxWidth := 60.
    answer := WriteStream on: String new.
    lineBuffer := WriteStream on: String new.
    margin := (String new: 8) atAllPut: $  .
    lineBuffer nextPutAll: margin; nextPut: $".
    words := aString asArrayOfSubstrings.
    1 to: words size do: [ :i |
        word := words at: i.
        lineBuffer position + word size > maxWidth
            ifTrue: [
                answer nextPutAll: lineBuffer contents; cr.
                lineBuffer := WriteStream on: String new.
                lineBuffer nextPutAll: margin].
        lineBuffer nextPutAll: word; nextPut: $ ].
    lineBuffer position = margin size ifFalse: [
        answer nextPutAll: lineBuffer contents].
    answer nextPut: $".
    ^answer contents!  
do: aBlock checkRecursionWith: aSet
		"Private - iterator through the receiver and its subexpressions.
		Use aSet to check if the receiver has already executed aBlock."
    (aSet includes: self)
        ifTrue: [^self].
    aSet add: self.
    aBlock value: self.
    (receiver isKindOf: PARTSCodeGeneratorInterface expressionClass)
        ifTrue: [receiver do: aBlock checkRecursionWith: aSet].
    arguments notNil ifTrue: [
        arguments do: [ :args |
            args notNil ifTrue: [
                args do: [ :arg |
                    (arg isKindOf: PARTSCodeGeneratorInterface expressionClass)
                        ifTrue: [arg do: aBlock checkRecursionWith: aSet]]]]]!  
kindOfSubclass
        "Private - answer a string describing the type of
        subclass the receiver models.  The choices are:
        'subclass:' and 'variableSubclass:'."
    ^'subclass:'!  
addClassReference: aReference
		"Private - add a class reference to the receiver."
    classReferences add: aReference! 
AAAAddedInstanceVariable
    "named:" byteStorageCount!  
new
    ^super new initialize!   
object: anObject
        "Set the object modelled."
    object := anObject! 
addPoolVariableNamed: aString inPoolNamed: aPoolName
        "Add a pool variable named aString to the pool
        named aPoolName."
    | poolDictionary |
    self insurePoolExists: aPoolName.
    poolDictionary := poolDictionaries at: aPoolName ifAbsentPut: [ Dictionary new ].
    poolDictionary at: aString put: nil
! 
isNotIndexedObjectStructureString: aString
    ^aString = self notIndexedObjectStructureString!  
fileInDirectoryNamed: aDirectoryName
		"Compile all the source code (.CLS) files in the
		directory named aDirectoryName."
    ^self fileInDirectory: (Directory pathName: aDirectoryName)!
deriveSymbolNameFrom: preferredNameString avoiding: namesUsedString
        "Private - construct and answer a name from preferredNameString that
        is not included in namesUsedArray."
    ^( self deriveNameFrom: preferredNameString avoiding: namesUsedString ) asSymbol! 
subsume: aCodeGeneratorEntry
		"Private - subsume aCodeGeneratorEntry into the receiver."
    aCodeGeneratorEntry references do: [ :ref |
        self addReference: ref ].
    name isNil ifTrue: [ self name: aCodeGeneratorEntry nameVariable ].
    expression isNil ifTrue: [
        self expression: aCodeGeneratorEntry expression ].
    object isNil ifTrue: [
        self object: aCodeGeneratorEntry object ]!   
replacementMethod
        "Private - answer a method that is to replace the recevier.
        The receiver is being replaced because it is too big."
    | answer |
    answer := classModel replacementMethodFor: self.
    answer
        argumentModels: argumentModels;
        comment: comment;
        isMeta: isMeta;
        name: name.
    ^answer!  
className: aString
		"Private - set the name of the class to be generated."
    className := aString!   
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    self writeMessagePatternOn: aCodeGeneratorStream.
    aCodeGeneratorStream indent; indent; cr.
    self writeCommentOn: aCodeGeneratorStream.
    aCodeGeneratorStream outdent; cr; cr.
    self writeExpressionSeriesOn: aCodeGeneratorStream.
    aCodeGeneratorStream outdent!
isMeta
        "Private - answer true if the receiver is a class method."
    ^isMeta!  
addSelector: aSelector with: anObject
        "Add a new message to the receiver’s list of messages.  Set the selector
        of the new message to be aSelector and set the arguments of the new
        message to be an array with anObject.  Answer the new message."

    ^( self addSelector: aSelector )
        addArgument: anObject;
        yourself!  
pool: aPool
        "Set the receiver's pool (the actual pool object, not the pool name)."
    pool := aPool!   
addInstanceVariableName: aString
        "Add aString as an instance variable of the class modelled."
    instanceVariableNames add: aString!   
writeTable
		"Private - write the receiver's table of contents."
    resourceTable do: [ :a |
        stream
            nextFourBytesPut: a first;
            nextFourBytesPut: a last ]!  
isEntryPointReference
		"Private - answer true if the receiver is an entry point reference."
    ^true! 
named: aString resource: anInteger ifAbsent: aBlock
        "Answer the binary object in the resource file
        named aString at index anInteger.  If the file cannot
        be found or the file does not contain an object
        at index anInteger answer the result of evaluating
        aBlock."
    | executionContext aPARTSResourceFile |
    executionContext := self partGetExecutionContext.
    executionContext notNil
        ifTrue: [
            aPARTSResourceFile := executionContext resourceFile.
            aPARTSResourceFile notNil
                ifTrue: [ ^aPARTSResourceFile
                    getResource: anInteger
                    ifAbsent: aBlock ]].
    aPARTSResourceFile := self named: aString.
    aPARTSResourceFile isNil ifTrue: [ ^aBlock value ].
    ^aPARTSResourceFile
        getResource: anInteger
        ifAbsent: aBlock!  
partTypeSimpleName: aString
		"Private - set the part type simple name of the receiver."
    partTypeSimpleName := aString! 
variableName: aString
		"Private - set the name of the variable that will
		represent the receiver in the generated source code."
    self name: aString!  
writeMessagePatternOn: aCodeGeneratorStream withArguments: anArray
        "Private - output the receiver's message pattern on aCodeGeneratorStream."
    anArray size = 0
        ifTrue: [
            self writeUnaryMessagePatternOn: aCodeGeneratorStream ]
        ifFalse: [
            self
                writeArgumentedMessagePatternOn: aCodeGeneratorStream
                withArguments: anArray ]!  
outputFileHeader
        "Private - output a header in the form of a comment."
    stream
        nextPut: $";

        nextPutAll: 'PARTS Workbench produced Smalltalk code.';
        cr;
        nextPutAll: 'Visual Smalltalk version: ';
        nextPutAll: Smalltalk versionNumberString;
        cr;
        nextPutAll: Date today printString;
        nextPutAll: ',  ';
        nextPutAll: Time now printString;

        nextPutAll: ' " !! ';
        cr; cr!   
literalModelFor: anObject
        "Private - answer a literal language model for anObject."
    ^CodeGenerationPrivateServices literalModel new contents: anObject! 
ifAbsentExpression: aCodeGeneratorExpression
		"Private - set the expression that describes the
		code to be generated in the ifAbsent: block of
		the receiver's generated code."
	ifAbsentExpression := aCodeGeneratorExpression!   
partInstVarNamed: aString put: anObject
		"Private - set the receiver's instance variable named
		aString to be anObject."
    | index |
    index := self class allInstVarNames indexOf: aString.
    self instVarAt: index put: anObject!  
outputLooseMethodModels
        "Private - do nothing, loose methods are not supported yet."!
parentClassModel
        "Answer the receiver's parent class model.  A class model
        acts as its own parent class model.  Do nothing, answer self."!  
isNamed
		"Private - answer true if the receiver is a named reference."
    ^true!  
partAddInstanceEventExpressionsTo: aCodeGeneratorExpression
        "PARTS CodeGenerator - Add expressions of the receiver's instance
        events to aCodeGeneratorExpression."
    | instanceEvents wrapper |
    wrapper := self partWrapper.
    wrapper isNil ifTrue: [^self].
    instanceEvents := wrapper instanceEvents.
    instanceEvents size = 0 ifTrue: [ ^self ].
    instanceEvents do: [ :symbol |
        aCodeGeneratorExpression
            addSelector: #partDefineEvent:
            arguments: (Array with: ( PARTSCodeGeneratorInterface referenceFor: symbol )) ]! 
space
		"Private - output a space to the receiver's output stream."
    self nextPut: $  .! 
traverseOn: aCodeGenerator
        "Private - log the branches of the receiver on aCodeGenerator."
    super traverseOn: aCodeGenerator.
    argumentModels do: [ :argumentModel |
        argumentModel traverseOn: aCodeGenerator ].
    expressionModels do: [ :expressionModel |
        expressionModel traverseOn: aCodeGenerator ].! 
insurePoolDictionary: aString
    | answer symbol dictionary |
    aString isNil ifTrue: [^nil].
    answer := aString.
    symbol := answer asSymbol.
    (Smalltalk includesKey: symbol)
        ifTrue: [
            dictionary := Smalltalk at: symbol.
            dictionary class == Dictionary
                ifTrue: [^answer " only correct case here " ]
                ifFalse: [
                     answer := self
                        prompt: 'Global named ', aString, ' is not a Dictionary.  Enter new name:'
                        default: answer]]
        ifFalse: [
             answer := self
                prompt: 'No pool named ', aString, '.  Enter new name:'
                default: answer].
    ^self insurePoolDictionary: answer!  
do: aBlock
        "Answer the receiver.  For each value
         in the receiver, evaluate aBlock with
         that value as the argument."
    orderedKeys do: [ :key |
        aBlock value: (self at: key)]!
checkOverwriteExistingClass: className
        "Private - there exists a subclass of
        the receiver named className.  Ask the
        user if it should be overwritten."
    | contextManager |
    contextManager := self partGetExecutionContext.
    ^contextManager notNil
        ifTrue: [
            contextManager interactive
                ifTrue: [ self promptForNewClassName: className ]
                ifFalse: [ self generateClassName: className ]]
        ifFalse: [ self generateClassName: className ]!
partIsArrayElementLiteral
		"Private - answer true if the receiver can be expressed
		in source code within a literal Array."
    ^self partIsLiteral! 
stream: aStream
    aStream close.
    stream := TextWindow
        windowLabeled: 'CG output ', self count printString
        frame: ( Display boundingBox insetBy: Display boundingBox height // 4 )!  
numberOfMessageSends
        "Private - answer the number of message sends contained in the receiver."
    ^messageModels
        inject: receiverModel numberOfMessageSends
        into: [ :a :b | a + b numberOfMessageSends ]!
codeGenerationAddEditExpressionTo: aMethodModel
        "Private - add expression models to aMethodModel to
        rebuild the edit information of a reconstructed clone
        of the receiver.  This edit information must not be needed
        for execution."
    ( self partIsShrunk or: [ self partShrunkenIconAttribute notNil ] )
        ifTrue: [
            aMethodModel newMessageExpression
            receiverObject: self;
            addSelectorIfTrue: #partIsShrunk: with: self partIsShrunk;
            addSelectorIfNotNil: #partShrunkenIcon: with: self partShrunkenIconAttribute;
            addSelector: #partEditRectangle: with: self partWrapper rectangle ]!   
stream: aStream
	"Private - Set up <aStream> as the output
	medium."

    | objectStoreFile |
    objectStoreFile :=  self fileClass new: objectStore.
    objectStoreFile setStream: 
		( self initializeForOperationOn: aStream ).
    objectStore file: objectStoreFile.!  
pathName: aString
        "Private - the receiver was just filed in from the pathName aString.
        do nothing."!
spaceWithString: aString
        "Private - write aString to the receiver insuring the character immediately
        before is whitespace."
    position > 0 and: [
            self lastCharacter isWhitespace ifFalse: [ self space ]].
    self nextPutAll: aString!  
checkNumberOfMessageSends
        "Private - count the number of message sends embodied in the
        receiver and signal a CodeGenerationMethodTooLarge exception
        it there are so many messages sends the method may not compile."
    self numberOfMessageSends > self maxMessageSends
        ifTrue: [ CodeGenerationMethodTooLarge signal ]!   
fileInDirectory: aDirectory
		"Compile all the source code (.CLS) files in aDirectory."
    | fileNames stream |
    fileNames := aDirectory formatted collect: [ :a |
        a first ].
    fileNames := fileNames select: [ :a |
        a fileExtension asUpperCase = 'PSC'].
    fileNames do: [ :fileName |
        stream := aDirectory fileReadOnly: fileName.
        self fileInFromBatch: stream.
        stream close ]!
newClass
        "Create and answer a class model."
    | classModel |
    classModel := CodeGenerationPrivateServices classModel new.
    classModel
        parent: self;
        codeGenerator: self.
    classModels add: classModel.
    ^classModel!
addMethodInClassNamed: aClassName meta: aBoolean sourceString: aString
        "Add a  method to the class named aClassName.
        Raise a CannotOutputMethod exception if the operation
        cannot be completed."
    self
        addMethodInClassNamed: aClassName
        meta: aBoolean
        sourceString: aString
        notifying: self compilerErrorHandler!
writeHeader
        "Private - write the class header."
    | tempStream poolNames requiredClasses moreClasses |
    poolNames := Set new.
    poolReferences do: [ :ref |
        poolNames add: ref poolName].
    tempStream := WriteStream on: String new.
    poolNames asSortedCollection do: [ :poolName |
        tempStream nextPutAll: poolName; nextPut: $  ].
    poolNames := tempStream contents.
    tempStream := WriteStream on: String new.
    self collectInstanceVarNames.
    tempStream := WriteStream on: String new.
    moreClasses := classReferences collect: [ :ref | ref object ].
    classesNeeded addAll: moreClasses.
    (classesNeeded asSortedCollection: Class sortBlock) do: [ :class |
        tempStream nextPutAll: class name; nextPut: $  ].
    requiredClasses := tempStream contents.
    (PARTSCodeGeneratorReader new
        preferredClassName: className;
        instanceVarString: '';
        classVarString: ' ';
        poolVarString: poolNames;
        interactive: true;
        requiredClassesString: requiredClasses;
        yourself) fileOutOn: stream.
    ^true!  
partApplicableStylePrefixes
		"Private - answer the prefixes of the constants
		in PARTSConstants that apply to the receiver's style."
    ^#('Ws')!   
lastCharacter
        "Private - answer the last character written to the receive."
    ^collection at: self position!  
pathName: aPathName
        "Private - set the path name of the receiver."
    ^self newStream: (File newFile: aPathName)!  
do: aBlock
		"Private - iterate through the receiver and all of its
		subexpressions evaluating aBlock."
    self do: aBlock checkRecursionWith: Set new!  
objectsDictionary
        "Private - answer the dictionary used to store objects
        with multiple references."
    ^objectsDictionary!
token: aString
        "Output aString on the receiver's output stream."
    self spaceWithString: aString! 
application
        "Answer the PARTSApplication described by the receiver."
    | answer partsExecutionContext |
    partsExecutionContext := self partGetExecutionContext.
        "partGetExecutionContext will be a PARTSCodeGeneratorReader
        if this is being executed by opening a source file from the workbench,
        otherwise it will be nil."
    partsExecutionContext isNil ifTrue: [
            "Set the resource file current dir so it knows where to look for resource files."
        PARTSCodeGeneratorInterface resourceFileClass currentDirectoryName: self directoryName ].
    answer := self new application.
    self pathName notNil ifTrue: [
        answer fileDescriptor: ( PARTSFileDescriptor pathName: self pathName ) ].
    answer partCodeGenerated: partsExecutionContext.
    ^answer! 
numberOfArguments
    ^0!
libraryMappings: aDictionary
        "Private - set the receiver's library mappings."
    | lib class |
    libraryMappings := aDictionary.
    libraryMappings
        at: CodeGeneratedClassInstalled
        put: CodeGeneratedClassInstalled library.
    libraryMappings associationsDo: [ :assoc |
        lib := assoc value.
        lib notNil ifTrue: [
            class := assoc key.
            class isBehavior
                ifFalse: [ class := class class ].
            stream
                cr;
                nextPutAll: '( Smalltalk includesKey: #', class name, '  )'; cr;
                    nextPutAll: '    ifFalse: [ SmalltalkLibraryBinder bindTo: ''', lib name, ''' ]  !!'; cr ]].
    stream cr; cr!
expression
		"Private - answer the expression associated with the receiver."
    ^expression!   
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
receiverObject
        "Answer the object whose reconstucted clone will be the
        receiver in the expression modelled by the receiver."
    ^receiver!
indent
		"Private - increment the indent level."
    indentLevel := indentLevel + 1!
partIsExpressible
        "PARTS CodeGenerator - Answer whether or not an
        expression should be used to represent the receiver."
    ^false!
write: aPARTSApplication on: aStream className: aString
        "Private - Write the source code for aPARTSApplication on aStream
        with class name aString."
    self
        className: aString;
        write: aPARTSApplication
            on: aStream!  
partColorArgReferenceFor: aColor
    | colorName poolName |
	aColor isNil ifTrue: [ ^nil ].
    ^aColor isRGBColor
        ifTrue: [
            PARTSCodeGeneratorInterface referenceFor: aColor ]
        ifFalse: [
            poolName := 'ColorConstants'.
            colorName := ColorConstants keyAtValue: aColor.
            colorName isNil
                ifTrue: [ "not found "
                    nil ]
                ifFalse: [
					PARTSCodeGeneratorInterface poolVariableReferenceClass
						poolName: poolName varName: colorName ]]!
codeGenerationAddLinkMessageModelsTo: anExpressionModel
        "Private - add to anExpressionModel
        message models to rebuild the receiver's links."
    |  wrapper links |
    wrapper := self partWrapper.
    wrapper notNil ifTrue: [
        wrapper linkTriggers do: [ :event |
            links := wrapper linksTriggeredBy: event.
            links do: [ :link |
                link addLinkMessageModelTo: anExpressionModel ]]]!   
tabString
        "Private - answer a string to used for tabs."
    ^tabString isNil
        ifTrue: [ ( String new: 4 ) atAllPut: Space; yourself ]
        ifFalse: [ tabString ]!  
numberOfMessageSends
        "Private - answer the number of message sends contained in the receiver."
    ^expressionModels inject: 0 into: [ :a :b | a + b numberOfMessageSends ]!
name
        "Private - answer the name of the receiver."
    self implementedBySubclass!   
addMethodInClassNamed: aClassName meta: aBoolean sourceString: aString notifying: aCompilerErrorNotifier
        "Add a  method to the class named aClassName.
        Raise a CannotOutputMethod exception if the operation
        cannot be completed."
    self suboutputsDo: [ :suboutput | suboutput
        addMethodInClassNamed: aClassName
        meta: aBoolean
        sourceString: aString ]!   
addSelector: aSelector arguments: anArray
		"Add aSelector and an arguments Array to the receiver."
    selectors isNil ifTrue: [
        selectors := OrderedCollection new.
        arguments := OrderedCollection new].
    selectors addLast: aSelector.
    arguments addLast: anArray.
    anArray do: [ :arg |
        ( arg isKindOf:  PARTSCodeGeneratorInterface referenceClass )
            ifTrue: [ arg superExpression: self ]]!  
name
        "Private - answer the name of the receiver."
    ^'nil'!   
resourceFileStream: aStream
        "Private - set the stream to receiver binary resource data."
    resourceFile := PARTSResourceFile new.
    resourceFile
        newStream: aStream;
        name: aStream file name!
referenceFor: anObject
        "Private - answer a language model with which to refer to anObject."
    | answer |
    answer := self
        referenceFor: anObject
        ifAbsent: [ parent referenceFor: anObject ].
    answer parent: self.
    ^answer!
receiver
		"Private - answer the receiver's receiver object."
    ^receiver!
addSelectorIfFalse: aSelector with: anObject
        "Add a new message to the receiver’s list of messages only if anObject is
        false.  Set the selector of the new message to be aSelector and the arguments
        to be an array with anObject.  Answer the new message if it was added,
        otherwise answer nil."

    anObject
        ifFalse: [ self addSelector: aSelector with: anObject ]!  
clearNamingDictionary
        "Private - nil out the naming dictionary.
        The dictionary will automatically be rebuilt
        the first time the receiver tries to lookup
        a class."
    RootNamingDictionary := nil!  
selector: aSelector
    selector := aSelector!   
stream: aStream
        "Private - set the receiver's stream and output a header."
    stream := aStream.
    self outputFileHeader!   
name: aString
		"Set - answer the name of the receiver."
    entry name: aString!   
parentClassModel
        "Answer the receiver's parent class model."
    ^parent parentClassModel!  
instanceVariableNames: aCollection
        "Set the receiver's instance variable names to anOrderedCollection."
    instanceVariableNames := aCollection asOrderedCollection!   
stream: aStream
        "Private - set the receiver's stream."
    stream := aStream!   
addInitialSuboutputs
        "Private - add the receiver's initial suboutputs, if any."
    self addOutputToImage.
    ^super addInitialSuboutputs!
applicationExtent: aPoint
		"Private - set the extent of the receiver's parts application."
    applicationExtent := aPoint!
punctuation: aString
		"Private - output aString on the receiver's output stream.
		aString is assummed to be punctuation."
    stream
        position: (stream position - 1);
        nextPutAll: aString.
	currentColumn := currentColumn + aString size - 1!
codeGenerationStoreOn: aCodeGeneratorStream
        "Private - store a souce code representation on aCodeGeneratorStream."
    aCodeGeneratorStream nextPutAll: '#( '.
    self do: [ :element |
        element codeGenerationStoreOn: aCodeGeneratorStream.
        aCodeGeneratorStream nextPutAll: ' '   ].
    aCodeGeneratorStream nextPutAll: ' )'!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^partTypeSimpleName isNil
        ifTrue: [ 'Unknown Type Of Part']
        ifFalse: [ partTypeSimpleName ]!
writeAccessorMethods
        "Private - write the methods used to access objects that have
        multiple references."
    instVarNames keys asSortedCollection do: [ :name |
        self
            beginMethod: name comment: 'Private - answer ', name, '.';
                nextPutAll: '^self objectsDictionary at: ''', name, '''';
            endMethod ]! 
writeLibraryFile: anApplication stream: aStream fileDescriptor: aFileDescriptor libraryMappings: libraryMappings
        "Private - write the Smalltalk library file described by aFileDescriptor."
    [ output := CodeGeneratorOutputToSmalltalkLIbrary on: aStream.
        output libraryMappings: libraryMappings.
        self
            write: anApplication
            output: output ]
                on: AboutToReplaceFile do: [ true "The user has already confirmed replacing file" ]!
writeMessagePatternOn: aCodeGeneratorStream
        "Private - output the receiver's message pattern on aCodeGeneratorStream."
    self writeMessagePatternOn: aCodeGeneratorStream withArguments: argumentModels!  
initialize
        "Private - initialize the receiver."
    expressionModels := OrderedCollection new.
    argumentModels := OrderedCollection new.
    isMeta := false.
    ^super initialize!  
classDefinitionModel
        "Private - answer the class definition model of the receiver."
    ^classDefinitionModel!  
fileOutOn: aStream
        "Store a representation of the receiver on aString."
        "Append the class definition message
         for the receiver to aStream."
    aStream cr;
        nextPutAll: self targetSuperClass name; cr; 
        nextPutAll: '    subclass:'; space;
        nextPutAll: '#', preferredClassName; cr;
		nextPutAll: '    instanceVariableNames: ';
		nextPutAll: instanceVarString storeString; cr;
		nextPutAll: '    classVariableNames: ';
		nextPutAll: classVarString storeString; cr;
        nextPutAll: '    poolDictionaries: ';
		nextPutAll: poolVarString storeString;
		nextPutAll: ' !! ';
		cr; cr;
		nextPutAll: ' !! ', preferredClassName, ' methods !! ';
		cr!   
partApplicableStylePrefixes
		"Private - answer the prefixes of the constants
		in PARTSConstants that apply to the receiver's style."
    ^#()!   
printOn: aStream
    aStream nextPutAll: self class name, ' for: <'.
    receiver printOn: aStream.
    messageModels do: [ :messageModel | messageModel printOn: aStream ].
    aStream nextPutAll: '>'! 
signal: aClass
        "Private - signal an instance of the receiver with aClass."
    self new
        generatedClass: aClass;
        signal!   
newClassMethodNamed: aString
        "Create and answer a class method model belonging to the reciever."
    | answer methodName |
    methodName := aString asSymbol.
    ( classMethodModels includesKey: methodName )
        ifTrue: [ self error: 'class method name collision.' ].
    answer := CodeGenerationMethod new.
    answer name: methodName.
    answer isMeta: true.
    classMethodModels at: methodName put: answer.
    self addSublanguageModel: answer.
    answer classModel: self.
    ^answer!  
indexableType
        "Private - answer a string decribing the structure of instances of the receiver."
    self implementedBySubclass! 
partIsStrictlyLiteral
		"Private - answer whether the receiver is truly a literal object."
    ^false!  
writeLinkMethods
		"Private - write all the methods to contruct the links
		of the application."
    self writeSomeMethods: linkEntryPointReferences!  
replacementMethodFor: aMethod
        "Private - answer a method to replace aMethod."
    ^self replacementMethodFor: aMethod named: aMethod name
!
getResource: resourceId ifAbsent: aBlock
        " Answer the resource named resourceId.  If resource
        number resourceId cannot be found or if there is any
        error answer the result of aBlock evaluated."
    ^[ self getResource: resourceId ]
        on: Error
        do: [
            stream notNil ifTrue: [ stream close ].
            aBlock value ]!
libraryMappings: aDictionary
        "Private - set the receiver's library mappings."
    libraryMappings := aDictionary!   
partInitializeStyle
        " Private - the receiver is being constructed from PARTS source code.
        Initialize the receiver's style to the default style."

    self style: self getStyle.! 
prompt: title default: default
		"Private - prompt the user for input."
    ^interactive
        ifTrue: [
            Prompter prompt: title default: default]
        ifFalse: [
            self logStream cr; show: ' >> Prompt: ', title.
            nil]!   
addMessageModel: aMessageModel
        "Private - "
    self ASSERT: self sender == self.  " privacyViolation"
    messageModels add: aMessageModel.
    self addSublanguageModel: aMessageModel! 
partDefaultPartTextFontExpression: aCodeGenerator
        "The receiver is the default part text font.  Answer a
        PARTSCodeGeneratorExpression describing how the
        receiver can be reconstructed."
    ^PARTSCodeGeneratorInterface creationExpressionClass new
        receiver: PARTSHostInterface;
        addSelector: #defaultPartTextFont!  
close
        "Close the receiver."! 
COMMENT
        "
        This abstract class serves as a specification for the output of the code generator.
        This class implements a number of methods that must be implemented by its
        subclasses.

        This interface should be enough to support any imagined code generation
        output format.  Some imagined output formats are:
            * Class (in image)
            * .CLS file (chunk format)
            * .SLL file
            * Package

        "!   
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^true!   
stream: aStream
		"Private - set the receiver's stream."
    stream := aStream! 
deriveNameFrom: preferredNameString avoiding: namesUsedArray
        "Private - construct and answer a name from preferredNameString that
        is not included in namesUsedArray."
    | candidateName integerString integer index |
    candidateName := preferredNameString.
    [ namesUsedArray includes: candidateName ]
        whileTrue: [
            candidateName last isDigit
                ifTrue: [
                    index := candidateName size.
                    [ ( candidateName at: index ) isDigit ]
                        whileTrue: [ index := index - 1 ].
                    integerString := candidateName copyFrom: index to: candidateName size.
                    integer := integerString asInteger.
                    integer := integer + 1.
                    candidateName := candidateName copyFrom: 1 to: index - 1.
                    candidateName := candidateName, integer asString ]
                ifFalse: [ candidateName := candidateName, '1' ]].
    ^candidateName!   
openStream: aStream
		"Private - compile the code in aStream and answer the resultant class."
    | class |
    class := self fileInFrom: aStream.
    ^class!
writePartFile: partFileName
		"Private - write a source code file for the parts application
		contained in partFileName."
    | object |
    object := PARTSFile applicationFromPathName: partFileName.
    self application: object; writeSourceCode!   
isBinary
    ^false! 
expression
		"Private - answer the expression representing the reciever's
		referenced object."
    ^entry expression! 
currentDirectoryName: aString
        "Set the name of the directory in which to
        to look for .TPR files."
    CurrentDirectoryName := aString! 
isNamed
		"Private - answer true if the receiver is a named reference."
    ^false! 
addPoolVariableNamed: aVarName inPoolNamed: aPoolName
        "Private - add a pool variable named aString to the pool named aPoolName."
    ( poolNames includes: aPoolName )
        ifFalse: [
            poolNames add: aPoolName.
            stream
            nextPutAll: '( Smalltalk includesKey: ';
            nextPutAll: '#', aPoolName;
            nextPutAll: ' ) ifTrue: [';
            cr;
            nextPutAll: '    self error: ''Pool name collides with existing global.'' ] !! ';
            cr;
            nextPutAll: 'Smalltalk at: ';
                nextPutAll: '#', aPoolName;
                nextPutAll: ' put: PoolDictionary new !! '; cr ].
    stream
        nextPutAll: aPoolName;
        nextPutAll: ' at: ''', aVarName, ''' put: nil !! '; cr!  
codeGenerator
        "Private - answer the code generator that is managing the receiver."

    ^codeGenerator!
isIndexedBytesObjectStructureString: aString
    ^aString = self indexedBytesObjectStructureString!  
close
        "Private - do the actual outputting at this point.  Close the receiver."
    | class pool |
    classNamesToWrite isNil ifTrue: [ ^self ].
    self registerLibraryMappings.
    classNamesToWrite do: [ :className |
        class := Smalltalk at: className.
        libraryBuilder addClass: class.
        class sharedPools do: [ :poolName |
        ( PARTSScriptContext sharedPools includes: poolName )
            ifFalse: [  "do not write every single pool variable to the SLL"
                pool := Smalltalk at: poolName.
                pool associationsDo: [ :assoc |
                    libraryBuilder
                        addPoolVariable: assoc value
                        named: assoc key
                        in: poolName  ]]]].
    libraryBuilder
        bindAction: ( Message
            receiver: class
            selector: #removeLiteralsFromLibrary );
        known;
        mainObject: class;
        writeFile.!   
methodName: aString
		"Private - set the method name of the receiver."
    methodName := aString!   
superclassName: aString
        "Set the the receiver's super class to be that identified by aString."
    superclassName := aString!   
precedenceLevel
        "Private - answer the precedence level of the receiver.
        The precedence level is the precedence of the evaluation
        of the expression of the receiver.  The precedence levels
        for corresponding expressions are:

            primary or unary message - 1
            binary message - 2
            keyword or cascaded message - 3 "

    messageModels size = 0 ifTrue: [ ^1 ].

    ^self isCascaded
        ifTrue: [ 3 ]
        ifFalse: [ messageModels first precedenceLevel ]!  
referenceFor: anObject ifNotYetDefined: aBlock
    ^referenceModels at: anObject ifAbsentPut: aBlock!
partIsLiteral
		"Private - answer if the receiver is can be expressed in source code
		as a literal."
    ^false!  
getLogStream
        "Private - get a stream to log messages to from the
        receiver's execution context manager."
    | contextManager |
    contextManager := self partGetExecutionContext.
    ^contextManager isNil
        ifTrue: [ ^nil ]
        ifFalse: [ ^contextManager logStream ]!  
newMessageExpression
        "Create and answer a message expression model.
        Add this model to the receiver's expression models list."
    | answer |
    answer := CodeGenerationPrivateServices messageExpressionModel new.
    self addExpressionModel: answer.
    ^answer!  
outputMargin
        "Private - output a margin to the current
        indent level."
    indentLevel timesRepeat: [ self nextPutAll: self tabString ]!
failTooManyInstanceVariables
        "Private - the class the receiver was about to generate
        requires more than 127 instance variables.  This will not
        compile.  Exit code generation and notify the user."
    | messageText |
    self close.
    messageText := 'Cannot generate source code due to a temporary limitation of ',
        'the maximum size of applications supported by the source generator.'.
    MessageBox
        notify: 'Code Generation Failed'
        withText: messageText.
    ^false!  
compilerErrorHandler
        "Private - answer the class of compiler error handler used by the receiver."
    ^PARTSCodeGeneratorCompilerErrorHandler new!  
write: aPARTSApplication on: aStream
		"Private - write aPARTSApplication in source code form
		on aStream."
    self
       stream: aStream;
       application: aPARTSApplication.
    className isNil ifTrue: [
        className := self getClassName ].
    self writeSourceCode!
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    aCodeGeneratorStream token: selector! 
codeGenerationStoreOn: aStream
        "Private - store a souce code representation on aCodeGeneratorStream."
    self printOn: aStream decimalSeparator: '.'!  
addRootEntryPointReference: aReference
		"Private - add a root entry point reference point to the receiver."
    | object |
    object := aReference object.
    (rootEntryPointReferences at: object ifAbsent: [
        rootEntryPointReferences at: object put: Set new ] )
            add: aReference! 
writeDefinitionOn: aCodeGeneratorStream
        "Private - output a source code representation of the
        receiver on aCodeGeneratorStream."
    aCodeGeneratorStream token: self name!
partIsCodeGeneratorReference
		"Private - answer true if the receiver is a parts code generator reference."
    ^false! 
superexpression
		"Private - answer the reciever's superexpression."
    ^superexpression!  
buildExpression
		"Private - variable references have no expression."
    ^nil! 
printOn: aStream
    self implementedBySubclass! 
instanceVariableNamesString
        "Private - answer a string containing the reciever's instance
        variable names."
    | stream |
    stream := WriteStream on: String new.
    instanceVariableNames do: [ :instName |
        stream nextPutAll: instName; nextPut: $  ].
    ^stream contents!  
close
		"Private - close the receiver."
    | position |
    position := stream position.
    stream
        position: startPosition;
        nextFourBytesPut: position;
        position: position.
    self writeTable.
    stream close! 
maxMessageSends
        "Private - answer the maximum number of message sends the receiver can have."
    ^1200!
indexedBytesObjectStructureString
    ^self objectStructureStringList at: 3! 
streamPosition
		"Answer the position of the receiver's output stream."
	^stream position!  
argumentModels: anArray
    argumentModels := anArray.
    anArray do: [ :argumentModel |
        self addSublanguageModel: argumentModel ]!   
classVariableNames: aCollection
        "Set the receiver's class variable names to anOrderedCollection."
    classVariableNames := aCollection asOrderedCollection!
isRootModel
        "Private - answer whether or not the receiver is a root language model."
    ^true! 
numberOfArguments
    ^numberOfArguments!
partDefaultPartFontExpression: aCodeGenerator
        "The receiver is the default part font.  Answer a
        PARTSCodeGeneratorExpression describing how the
        receiver can be reconstructed."
    ^PARTSCodeGeneratorInterface creationExpressionClass new
        receiver: PARTSHostInterface;
        addSelector: #defaultPartFont!   
replacementMethods
        "Private - an attempt has been made to compile a method that is too
        large to compile.  Answer the smaller methods that will replace the method
        that is too large to compile."
    ^replacementMethods! 
className: className
    superclassName: superclassName
    instanceVariableNames: instanceVariables
    classVariableNames: classVariableNames
    classInstanceVariableNames: classInstanceVariableNames
    poolNames: poolNamesArray
        "Configure the receiver's definition."

    classDefinitionModel := CodeGenerationFixedClassDefinition new.
    classDefinitionModel
        name: className;
        superclassName: superclassName;
        instanceVariableNames: instanceVariables;
        classVariableNames: classVariableNames;
        classInstanceVariableNames: classInstanceVariableNames;
        poolNames: poolNamesArray.
    self addSublanguageModel: classDefinitionModel!   
addPoolVariableNamed: aString inPoolNamed: aPoolName
        "Add a pool variable named aString to the pool
        named aPoolName.  Do nothing,
        this work will be handled by the receiver's partner,
        a CodeGeneratorOutputToImage."
!  
notifyClassCreationAborted: aClassName
		"When the notification framework is done, do something."!   
writeMiscMethods
		"Private - write a method for every entry point reference
		seen by the receiver."
    self writeSomeMethods: entryPointReferences! 
semicolon
		"Private - output a semicolon."
    self punctuation: ';'!  
writeInitMethod
    | creations partCreations nonCreations expression |
    creations := PARTSOrderedIdentityDictionary new.
    partCreations := PARTSOrderedIdentityDictionary new.
    nonCreations := PARTSOrderedIdentityDictionary new.
    self beginMethod: 'initialize' comment:
        'Initialize the receiver''s objects dictionary.'.
    multiReferences associationsDo: [ :assoc |
        expression := assoc key.
        expression isCreationExpression
            ifTrue: [
                expression receiver == PARTSCreator
                    ifTrue: [ partCreations at: assoc value put: expression ]
                    ifFalse: [ creations at: assoc value put: expression ]]
            ifFalse: [ nonCreations at: assoc value put: expression ]].
    self nextPutAll: 'objectsDictionary := Dictionary new.'; cr.
    partCreations keys asSortedCollection do: [ :name |
        self nextPutAll: 'self objectsDictionary at: ''', name, ''' put: ('.
        (partCreations at: name) partEmitExpressionOn: self.
        self punctuation: ').'; cr ].
    creations keys do: [ :name |
        self nextPutAll: 'self objectsDictionary at: ''', name, ''' put: ('.
        (creations at: name) partEmitExpressionOn: self.
        self punctuation: ').'; cr ].
    self writeMisc: nonCreations!   
preferredClassName: aString
		"Private - set the preferred class name.  This may not
		be the name of the resulting class as it might need to be
		changed to not collide with existing global variable names."
    preferredClassName := aString!
isSimpleFileIn
        "Private - answer whether or not the receiver derived
        from a simple Smalltalk fileIn, or is derived from a
        special reader tool.  This determines how things are
        compiled.  If it is a simple fileIn, then the source code
        is stored in the change log like anything else.  If it isn't
        a simple file in, then the code is stored in memory."
    ^owner isNil!  
fileInFromBatch: aStream
		"Private - compile the code in aStream without requiring
		any user interaction."
    | reader |
    reader := self fromStream: aStream.
    reader isNil ifTrue: [
        self logStream cr; show: aStream pathName,
            ' not a CodeGenerator fileIn file.'].
    reader interactive: false.
    ^reader fileInFrom: aStream!  
privateAddExpressionModel: anExpressionModel
        "Private - add an expression model to the receiever."
    expressionModels add: anExpressionModel.
    self addSublanguageModel: anExpressionModel!   
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addEntryPointReference: self!  
creationRoot
		"Private - answer the root expression of the receiver."
    ^receiver creationRoot!  
classVariableNamesString
        "Private - answer a string containing the reciever's class
        variable names."
    | stream |
    stream := WriteStream on: String new.
    classVariableNames do: [ :instName |
        stream nextPutAll: instName; nextPut: $  ].
    ^stream contents!   
requiresVariable
		"Private - answer true if the reciever's object requires a variable."
    ^false!
partTypeName
        "Answer the full part type name of the receiver.  This name
        uniquely identifies the part type of the receiver."
    | separator |
    separator := String
        with: $ 
        with: PARTSCreator nameSeparator
        with: $  .
    ^self partManufacturer, separator, self class name!   
addSuboutput: aSuboutput
        "Add aSuboutput as a suboutput of the receiver."
    suboutputs isNil ifTrue: [
        suboutputs := OrderedCollection new ].
    suboutputs add: aSuboutput!   
addPoolVariableNamed: aString inPoolNamed: aPoolName
        "Add a pool variable named aString to the pool
        named aPoolName."
    self suboutputsDo: [ :suboutput | suboutput
        addPoolVariableNamed: aString
        inPoolNamed: aPoolName ]!
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup."
    self partWrapper rectangle: self framingBlock.
    ^super partCodeGenerated: anApplicationBuilder! 
parent
        "Private - answer the receiver's parent."
    ^parent!   
addSelectorIfNotNil: aSelector with: anObject
        "Add a new message to the receiver’s list of messages only if anObject is
        not nil.  Set the selector of the new message to be aSelector and the
        arguments to be an array with anObject.  Answer the new message if it was
        added, otherwise answer nil."

    anObject notNil
        ifTrue: [ self addSelector: aSelector with: anObject ]! 
fileDescriptor: aFileDescriptor
        "Private - create the receiver's Smalltalk library builder as
        specified by aFileDescriptor."
    | pathName |
    pathName := aFileDescriptor fullPathName.
    libraryBuilder := SmalltalkLibraryBuilder new: pathName.
    libraryMappings size > 0 ifTrue: [
        libraryMappings associationsDo: [ :assoc |
            libraryBuilder
                addImport: assoc key
                fromLibrary: assoc value ]]! 
codeGenerationAddOldPCGXMessageModelsTo: anExpressionModel
        "Private - send #partCodeGeneratorExpression: to the receiver to get a
        parts code generator expression.  Transfer the expression series modelled
        by that old style code generator expression to anExpressionModel.
        A class should implement either #partCodeGeneratorExpression: or
        #codeGenerationAddAttributeMessagesTo:, but not both.
        #codeGeneratorAddAttributeMessagesTo: is the new way of doing things,
        and #partCodeGeneratorExpression is being obselesced."
    | pcgx |
    pcgx := self partCodeGeneratorExpression: anExpressionModel codeGenerator.
    pcgx transferMessagesTo: anExpressionModel!   
addToNamePoolReal: aString
		"Private - add the receiver's name to the list of names
		that will be used in the method building the reciever's link."
    namePool isNil ifTrue: [
        namePool := Set new ].
    (namePool includes: aString)
        ifTrue: [ self error: 'duplicate name' ].
    namePool add: aString!
partDefaultDialogsFontExpression: aCodeGenerator
        "The receiver is the default PARTS dialog font.  Answer a
        PARTSCodeGeneratorExpression describing how the
        receiver can be reconstructed."
    | receiver |
    receiver := PARTSCodeGeneratorInterface creationExpressionClass new.
    receiver
        receiver: PARTSSettings;
        addSelector: #current.
    ^PARTSCodeGeneratorInterface expressionClass new
        receiver: receiver;
        addSelector: #defaultFontDialogs!   
output
        "Answer the receiver's output."
    ^output! 
initialize
        "Private - initialize the receiver."
    self fixedClass.
    instanceMethodModels := IdentityDictionary new.
    classMethodModels := IdentityDictionary new.
    specialStorage := OrderedCollection new.
    importedPoolVariables := OrderedCollection new.
    ^super initialize!  
creationRoot
        "Do nothing, answer self."! 
addClassNamed: aClassName
superclassName: superClassName
indexableType: aBoolean
instanceVariableNames: instanceVariableString
classVariableNames: classVariableString
poolNames: poolNamesString
classInstanceVariableNames: classInstanceVariableNamesString

    "Private - output a class named aClassName."

    self implementedBySubclass!   
fileInClassFrom: aStream
        "Private - read and compile the class definition at
        the begining of aStream."
    | string compiler result |
    aStream reset.
    string := aStream nextChunk.
    compiler := self getCompiler.
    result := compiler evaluate: string.
    class := result value.
    ^class!  
comment: aString
		"Set the receiver's comment.  This is what will show up 
		as the comment of the generated method."
    methodComment := aString!   
transferMessagesTo: aMessageExpressionModel
        "Private - Code Generation - answer a language model with the same semantics as the receiver."
    | selector args |
    1 to: selectors size do: [ :i |
        selector := selectors at: i.
        args := arguments at: i.
        args := args isNil
            ifTrue: [ Array new ]
            ifFalse: [ args collect: [ :ref | ref object ]].
       aMessageExpressionModel
            addSelector: selector
            arguments: args ]!   
name
        "Private - answer the receiver's name."
    ^name! 
partIsPart
		"Answer whether the receiver is a component
		part of a PARTSApplication."
	^self partWrapper notNil! 
outputClassMethodsOn: aCodeGeneratorOutput
        "Private - output the reciever's class methods on aCodeGeneratorOutput."
    self outputMethods: classMethodModels on: aCodeGeneratorOutput! 
isBinary
    ^true!  
partEmitExpressionOn: aCodeGenerator

"self halt."
 ^super partEmitExpressionOn: aCodeGenerator!   
partIsExpressible
        "PARTS CodeGenerator - Answer whether or not an
        expression should be used to represent the receiver."
    ^self partIsLiteral not!   
addSelector: aSelector withVariable: aVariableName inPool: aPool
        "Add to the receiver aSelector with a pool variable as an argument."
    | poolVariableModel |
    poolVariableModel := CodeGenerationPoolVariable new
        name: aVariableName;
        pool: aPool.
    self classModel importPoolVariableModel: poolVariableModel.
    ( self addSelector: aSelector )
        addArgumentModel: poolVariableModel!
isModelTraversed: aLanguageModel
    ^modelsToObjects includesKey: aLanguageModel!   
newInstanceMethodNamed: aString
        "Create and answer a instance method model belonging to the reciever."
    | answer methodName |
    methodName := aString asSymbol.
    ( instanceMethodModels includesKey: methodName )
        ifTrue: [ self error: 'instance method name collision.' ].
    answer := CodeGenerationMethod new.
    answer name: methodName.
    instanceMethodModels at: methodName put: answer.
    self addSublanguageModel: answer.
    answer classModel: self.
    ^answer! 
eventTableForEdit
        "Private - answer a Dictionary mapping event names to actions,
        allocate it if necessary."
    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable!   
for: anObject
		"Private - answer an instance of the receiver for anObject."
    ^self new object: anObject!
new
        "Answer an initialized instance of the receiver."
    ^super new initialize!
variableName
		"Private - answer the name of the variable that
		will be used by the receiver in generated source."
    ^self name!
initialize
        "Private - initialize the receiver."
    "do nothing."!  
addTo: aCodeGenerator
		"Private - add the receiver to aCodeGenerator."
    self addEntryTo: aCodeGenerator.
    aCodeGenerator addClassReference: self!   
insurePoolExists: aPoolName
        "Private - insure the pools named in aPoolNamesString exist.
        Create them if they don't.  If created, store them so they can
        be deleted if the receiver's output is transient."
    | poolName pool |
    poolName := aPoolName asSymbol.
    pool := Smalltalk at: poolName ifAbsentPut: [
        self createPoolNamed: poolName ].
    pool isDictionary ifFalse: [
        self error: 'Attempt to use a pool named ', poolName, ', which is not a pool' ]!