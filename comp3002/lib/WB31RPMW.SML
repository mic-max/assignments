"3.0.0.23"
! 

WBObject subclass: #WBPoolManager
  instanceVariableNames: 
    ' pools allowDuplicateKeys updateSource '
  classVariableNames: ''
  poolDictionaries: ''!  
WBPoolManager class instanceVariableNames: ' currentManager systemManager '!  

WBPoolManager subclass: #WBFontManager
  instanceVariableNames: 
    ' generatePortableFontCode '
  classVariableNames: ''
  poolDictionaries: ''!  

WBObject subclass: #WBPool
  instanceVariableNames: 
    ' pool poolName manager fileName subPools activeCategory '
  classVariableNames: ''
  poolDictionaries: ''!

WBPool subclass: #WBFontPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

Dictionary subclass: #WBSubPool
  instanceVariableNames: 
    ' fileName category owner '
  classVariableNames: ''
  poolDictionaries: ''!  

WBSubPool subclass: #WBFontSubPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!  

Error subclass: #WBPoolError
  instanceVariableNames: 
    ' manager pool subPool '
  classVariableNames: ''
  poolDictionaries: ''!

WBPoolError subclass: #WBPoolErrorAbsentKey
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''! 

WBPoolError subclass: #WBPoolErrorInvalidKey
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

WBPoolError subclass: #WBPoolErrorDuplicateKey
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!  

WBPoolManager subclass: #WBNLSManager
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!   

WBPool subclass: #WBNLSPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''! 

WBSubPool subclass: #WBNLSSubPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!   

WBPoolError subclass: #WBPoolErrorInvalidValue
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!  

WBPoolError subclass: #WBPoolErrorInvalidCategory
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!   

WBPoolError subclass: #WBPoolErrorInvalidPoolName
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!   

WBPoolError subclass: #WBPoolErrorDuplicatePoolName
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''! 

WBPoolError subclass: #WBPoolErrorInvalidPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!   

StringDictionaryReader subclass: #WBNLSDictionaryReader
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''! 

WBPoolManager subclass: #WBBitmapManager
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

WBSubPool subclass: #WBBitmapSubPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

WBPool subclass: #WBBitmapPool
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!  

WBPoolError subclass: #WBPoolErrorInvalidFile
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

!WBPoolManager methods !   
at: aKey in: aCategory ifAbsent: aBlock
	"Answer the pool variable value at aKey.
		If not found then answer aBlock evaluated."

	self pools do: [:each |
		(each includesKey: aKey) ifTrue: [
			^each at: aKey in: aCategory ifAbsent: aBlock]].
	^aBlock value! !

!WBPool methods !  
errorInvalidValue: anObject
	"Report the error that aKey is invalid."

	WBPoolErrorInvalidValue signal: anObject pool: self.! !

!WBPoolErrorInvalidKey class methods !  
messageTextFor: aKey
	"Answer the error message text."

	^'Invalid pool key: ', aKey printString! !

!WBBitmapPool class methods !   
fileInPoolNameFrom: aStream
	"Answer the pool name stored in aStream."

	| tag pos line answer |
	tag := self managerClass tagPoolName.
	pos := aStream position.
	line := aStream nextLine.
	(line beginsWith: tag) ifFalse: [
		aStream position: pos.
		^nil].
	answer := line copyFrom: tag size + 1 to: line size.
	answer := answer trimBlanks.
	^answer! !

!WBPool class methods !  
managerClass

	^WBPoolManager! !

!WBPool methods !   
subPools
	"Answer a collection of sub pools."

	^subPools! !

!WBSubPool class methods ! 
poolClass

	^WBPool! !

!WBPoolManager methods !  
addPoolNamed: aPoolName
	"Add a pool named aSymbol to the receiver's collection of pools."

	| newPool newPoolName |
	(self isValidPoolName: aPoolName) ifFalse: [^self errorInvalidPoolName: aPoolName].
	newPoolName := aPoolName asSymbol.
	(self poolFor: newPoolName) notNil ifTrue: [^self errorDuplicatePoolName: aPoolName].
	newPool := self poolClass named: newPoolName for: self.
	self pools at: newPoolName put: newPool.
	self triggerPoolAdded: newPoolName.
	^newPool! !

!WBPool methods !  
at: aKey in: aCategory put: anObject
	"Set the pool variable value at aKey.
		Report an error if the key exists in another pool."

	| oldValue |
	(self isValidKey: aKey) ifFalse: [^self errorInvalidKey: aKey].
	(self isValidValue: anObject) ifFalse: [^self errorInvalidValue: anObject].
	oldValue := self at: aKey in: aCategory ifAbsent: [
		(self includesKey: aKey) ifFalse: [
			(self manager isValidNewKey: aKey) ifFalse: [^self errorDuplicateKey: aKey].
			self basicAt: aKey in: aCategory put: anObject.
			self triggerKeyAdded: aKey.
			self triggerValueChanged: anObject at: aKey in: aCategory.
			^anObject].
		nil].
	(self is: oldValue equalTo: anObject) ifFalse: [
		self basicAt: aKey in: aCategory put: anObject.
		self triggerValueChanged: anObject at: aKey in: aCategory].
	^anObject! !

!WBPool methods !   
asExistingWBPoolIn: aWBPoolManager
	"Answer the pool for aWBPoolManager, or nil."

	^self manager == aWBPoolManager
		ifTrue: [self] ifFalse: [nil]! !

!WBSubPool methods !
managerClass

	^self class managerClass! !

!WBPool class methods !   
subPoolClass

	^WBSubPool! !

!WBBitmapPool class methods !   
fileInFileNameFrom: aStream
	"File in the file name."

	| tag pos line answer |
	tag := self managerClass tagFileName.
	pos := aStream position.
	line := aStream nextLine.
	(line beginsWith: tag) ifFalse: [
		aStream position: pos.
		^nil].
	answer := line copyFrom: tag size + 1 to: line size.
	answer := answer trimBlanks.
	^answer! !

!String methods ! 
asExistingWBPoolIn: aWBPoolManager
	"Answer the pool for aWBPoolManager, or nil."

	#addedByOSI.
	^(self asExistingSymbolOrNil ifNil: [^nil])
		asExistingWBPoolIn: aWBPoolManager! !

!WBPoolManager methods !
keyAtValue: anObject
	"Answer the key in the receiver whose paired value
		 equals anObject.  If not found, answer nil."

	^self keyAtValue: anObject ifAbsent: [nil]! !

!WBPool methods ! 
triggerKeyAdded: newKey

	self
		triggerEvent: #keyAdded:
		with: newKey.
	self manager
		triggerKeyAdded: newKey
		pool: self.! !

!WBPoolManager methods ! 
poolClass

	^self class poolClass! !

!WBSubPool class methods !  
fileInCategoryFrom: aStream
	"File in the category."

	^nil! !

!WBPoolManager methods ! 
allowDuplicateKeys

	^allowDuplicateKeys ifNil: [false]! !

!WBPool methods ! 
removeKey: aKey
	"Remove the specified key.
		If not found then report an error."

	^self removeKey: aKey ifAbsent: [self errorAbsentKey: aKey]! !

!WBPoolManager methods !
addCategory: aCategory
	"Add the specified category for all of the receiver's pools."

	self pools do: [:each | each addCategory: aCategory].! !

!WBSubPool class methods ! 
named: aCategory for: aWBPool
	"Answer an instance of the receiver with the specified category."

	^self new category: aCategory! !

!WBPool methods !   
categories
	"Answer the receiver's categories."

	^self subPools asArray collect: [:each | each category]! !

!WBPoolManager methods !   
includesKey: aKey
	"Answer true if the receiver includes aKey."

	self pools do: [:each |
		(each includesKey: aKey) ifTrue: [
			^true]].
	^false! !

!WBSubPool methods !   
errorInvalidFile: aStream
	"Report the error that aStream is invalid."

	WBPoolErrorInvalidFile signal: aStream subPool: self! !

!WBPoolError class methods !   
signal: msg manager: aWBPoolManager pool: aWBPool subPool: aWBSubPool
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

   ^(self new
		manager: aWBPoolManager;
		pool: aWBPool;
		subPool: aWBSubPool;
		messageText: (
			self messageTextFor: msg)) signal! !

!WBPoolErrorInvalidFile class methods !
messageTextFor: aStream
	"Answer the error message text."

	^'Invalid file format for ', aStream printString! !

!WBPool class methods ! 
named: aSymbol for: aWBPoolManager
	"Answer an instance with the specified name."

	^self new
		manager: aWBPoolManager;
		poolName: aSymbol! !

!WBPoolManager methods !  
load: aFileName
	"Load the file named into the receiver."

	| path stream |
	(path := File findOrPromptFileName: aFileName) isNil ifTrue: [^self].
	stream := File pathName: path.
	[self fileInFrom: stream] ensure: [stream close].! !

!Symbol methods !   
asExistingWBPoolIn: aWBPoolManager
	"Answer the pool for aWBPoolManager, or nil."

	#addedByOSI.
	^aWBPoolManager pools
		at: self
		ifAbsent: [nil]! !

!WBPool class methods !  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
		addAll: #(
			#activeCategoryChanged:
			#categoryAdded:
			#categoryRemoved:
			#fileNameChanged:
			#fileNameChanged:in:
			#keyAdded:
			#key:renamed:
			#keyRemoved:
			#valueChanged:at:in: )! !

!WBPoolErrorDuplicatePoolName class methods !  
messageTextFor: aPoolName
	"Answer the error message text."

	^'Duplicate pool name: ', aPoolName printString! !

!WBBitmapPool methods !
fileInFrom: aStream
    "File in the receiver's contents."

    | pos |
    [    pos := aStream position.
        aStream nextLine = self managerClass tagPoolEnd
    ] whileFalse: [
        aStream position: pos.
        (self subPoolClass fileInFrom: aStream for: self) ifNil: [^self]].! !

!WBPool methods !   
keyAtValue: anObject ifAbsent: aBlock
	"Answer the key in the receiver whose paired value
		 equals anObject.  If not found, answer aBlock evaluated."

	^self pool keyAtValue: anObject ifAbsent: aBlock! !

!WBBitmapManager methods !
anyBitmap
	"Answer any bitmap or nil if none loaded."

	self pools do: [:each | each pool do: [:eachBitmap | ^eachBitmap]].
	^nil! !

!WBPool methods ! 
at: aKey ifAbsent: aBlock
	"Answer the pool variable value at aKey.
		If not found then answer aBlock evaluated."

	^self pool at: aKey ifAbsent: aBlock! !

!WBPoolManager methods !   
triggerActiveCategoryChanged: aCategory

	self
		triggerEvent: #activeCategoryChanged: with: aCategory;
		changed.! !

!WBPool methods !
subPoolNamed: aCategory
	"Answer the sub pool named aCategory,
		and create it if it does not exist."

	^(self subPoolFor: aCategory) ifNil: [self addCategory: aCategory]! !

!WBPool methods !
triggerCategoryAdded: newCategory

	self
		triggerEvent: #categoryAdded:
		with: newCategory.
	self manager
		triggerCategoryAdded: newCategory
		pool: self.! !

!WBNLSManager methods !
defaultValueFor: aKey
	"Answer the default value for aKey.
		If not found then answer a default value."

	^'<???>'! !

!WBPool methods !
activeCategoryPrim: aCategory
	"Set the active category.
		Answer true if successful."

	| aSubPool |
	(aSubPool := self subPoolFor: aCategory) notNil ifTrue: [
		activeCategory := aCategory.
		aSubPool copyToPool: self pool.
		^true].
	aCategory isNil ifTrue: [
		activeCategory := nil.
		^true].
	^false! !

!WBSubPool methods !  
fileName: aString
	"Set the file name associated with the receiver."

	fileName := aString.! !

!WBPool methods !
isValidCategory: aCategory
	"Answer true if the aCategory is a valid category."

	^self manager isValidCategory: aCategory! !

!WBPoolManager methods !  
poolFor: aPoolRef
	"Answer the pool associated with aPoolRef,
		or nil if there is not one."

	^aPoolRef asExistingWBPoolIn: self! !

!WBPoolError class methods !  
signal: msg pool: aWBPool
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

	^self signal: msg manager: nil pool: aWBPool subPool: nil! !

!WBSubPool methods !
category: aString
	"Private - Set the receiver's category."

	category := aString.! !

!WBFontManager methods !  
fileInFrom: aStream
	"File in to the receiver."

	aStream fileIn.! !

!WBPool methods !  
triggerFileNameChanged: aFileName in: aCategory

	self
		triggerEvent: #fileNameChanged:in:
		withArguments: (Array with: aFileName with: aCategory).
	self manager
		triggerFileNameChanged: aFileName
		in: aCategory
		pool: self.! !

!WBPoolManager methods !  
activeCategory: aCategory
	"Set the active category for all of the receiver's pools."

	| changed |
	changed := false.
	self pools do: [:each |
		(each activeCategory: aCategory) ifTrue: [
			changed := true]].
	changed ifTrue: [
		self triggerActiveCategoryChanged: aCategory].! !

!WBPoolManager methods !
removeKey: aKey ifAbsent: aBlock
	"Remove the pool variable value at aKey."

	self pools do: [:each |
		(each includesKey: aKey) ifTrue: [
			^each removeKey: aKey]].
	^aBlock value! !

!WBPoolManager methods !
isValidPool: aDictionary
	"Answer true if the aDictionary is a valid pool."

	^self class isValidPool: aDictionary! !

!WBPoolManager methods !  
is: oldValue equalTo: newValue
	"Answer true if oldValue is equal to newValue."

	^oldValue = newValue! !

!WBPoolErrorAbsentKey class methods ! 
messageTextFor: missingKey
	"Answer the error message text."

	^'Missing pool key: ', missingKey printString! !

!WBPoolManager class methods !  
isValidKey: aString
	"Answer true if aString is a valid pool variable name."

	^aString isString and: [
		(self validKey: aString) = aString and: [
			(self invalidKeys includes: aString asString) not]]! !

!WBPoolManager class methods !  
system
	"Answer the system pool manager."

	^systemManager ifNil: [self constructSystemManager]! !

!WBPoolError class methods ! 
messageTextFor: anObject
	"Answer the error message text."

	^'Pool error: ', anObject printString! !

!WBBitmapManager methods !
addFixedBitmapPoolNamed: aSymbol
	"Add a bitmap pool to the receiver."

	#obsoleteMethod.
	"Retained for compatibility."
	^self addBitmapPoolNamed: aSymbol! !

!WBNLSPool methods !   
fileInFrom: aStream
	"File in the receiver's contents."

	(self stringDictionaryReaderClass new
		fileStream: aStream;
		findNextPoolBegin)
			ifTrue: [super fileInFrom: aStream].! !

!WBPoolError methods !
pool

	^pool ifNil: [
		self subPool isNil
			ifTrue: [nil]
			ifFalse: [pool := self subPool owner]]! !

!WBPool methods !
fileNameFor: aCategory put: aString
	"Set the category's file name."

	| aSubPool oldFileName |
	aSubPool := self subPoolNamed: aCategory.
	aSubPool fileName = aString ifFalse: [
		oldFileName := aSubPool fileName.
		aSubPool fileName: aString.
		self triggerFileNameChanged: fileName in: aCategory].! !

!WBPoolManager methods !   
associationsDo: iterationBlock
	"Evaluate the <iterationBlock> once for each key/value pair, represented
		as an Association, in the receiver. If the receiver is empty,
		the block will not be evaluated."

	self pools do: [:each | each pool associationsDo: iterationBlock].! !

!WBPool methods !
keyAtValue: anObject
	"Answer the key in the receiver whose paired value
		 equals anObject.  If not found, answer nil."

	^self keyAtValue: anObject ifAbsent: [nil]! !

!WBPoolErrorInvalidCategory class methods !   
messageTextFor: aCategory
	"Answer the error message text."

	^'Invalid pool category: ', aCategory printString! !

!WBPoolManager class methods !   
isValidCategory: aCategory
	"Answer true if the aCategory is a valid category."

	^aCategory isString and: [
		aCategory notEmpty and: [
			(self invalidCategories includes: aCategory) not]]! !

!WBBitmapPool class methods !   
subPoolClass

	^WBBitmapSubPool! !

!WBBitmapManager methods !
at: aString put: aBitmap
	"Set the bitmap at aString."

	#obsoleteMethod.
	"Retained for compatibility."
	^self at: aString in: self class defaultCategory put: aBitmap! !

!WBPoolManager methods !   
isValidCategory: aCategory
	"Answer true if the aCategory is a valid category."

	^self class isValidCategory: aCategory! !

!WBSubPool methods !
defaultFileName
	"Answer the default file name."

	^''! !

!WBPoolManager methods !  
associationAt: aKey
	"Answer the Association whose key equals aKey
		 from the receiver.  If not found, report an error."

	self pools do: [:each |
		(each includesKey: aKey) ifTrue: [
			^each associationAt: aKey]].
	^self errorAbsentKey: aKey! !

!Bitmap class methods ! 
named: aKey
	"Answer the bitmap at the specified key."

	^WBBitmapManager current at: aKey! !

!WBNLSPool class methods !
managerClass

	^WBNLSManager! !

!WBBitmapManager methods !   
validBitmapName: aString
	"Answer a valid bitmap name."

	#obsoleteMethod.
	"Retained for compatibility."
	^self class validKey: aString! !

!WBNLSSubPool methods !   
fileInFrom: aStream

	| newValues |
	newValues := Dictionary new.
	self stringDictionaryReaderClass new
		fileStream: aStream;
		dictionary: newValues;
		readNextTable.
	newValues associationsDo: [:each |
		self owner at: each key in: self category put: each value].! !

!WBPool methods !   
is: oldValue equalTo: newValue
	"Answer true if oldValue is equal to newValue."

	^self manager is: oldValue equalTo: newValue! !

!WBNLSPool class methods !
stringDictionaryReaderClass

	^WBNLSManager stringDictionaryReaderClass! !

!WBPool methods ! 
activeCategory

	^activeCategory! !

!WBPool class methods !  
fileInPoolNameFrom: aStream
	"Answer the pool name stored in aStream."

	^nil! !

!WBPool methods !  
fileNameFor: aCategory
	"Answer the category's file name."

	^self fileNameFor: aCategory ifAbsent: ['']! !

!WBPool methods !   
associationAt: aKey
	"Answer the pool variable association at aKey.
		If not found then report an error."

	^self associationAt: aKey ifAbsent: [self errorAbsentKey: aKey]! !

!WBNLSDictionaryReader methods !
readNextCategoryName

	| comment |
	[(comment := self nextComment) notNil] whileTrue: [
		comment = WBNLSManager tagPoolEnd ifTrue: [^nil].
		(comment beginsWith: WBNLSManager tagCategory) ifTrue: [
			^self readStringFrom: comment]].
	^nil! !

!WBPoolError methods !  
subPool: aWBSubPool

	subPool := aWBSubPool.! !

!WBPool methods !
poolName: aPoolName

	poolName := aPoolName.
	pool := self basicPool.
	(self isValidPool: pool) ifFalse: [self errorInvalidPool: aPoolName].
	subPools := Dictionary new.! !

!Font class methods !
named: aKey
	"Answer the font at the specified key."

	^WBFontManager current at: aKey! !

!WBPoolManager methods !  
triggerCategoryRemoved: oldCategory pool: aWBPool

	self
		triggerEvent: #categoryRemoved:pool:
			withArguments: (Array with: oldCategory with: aWBPool);
		changed.! !

!WBPool methods !
managerClass

	^self class managerClass! !

!WBPool methods ! 
at: aKey in: aCategory
	"Answer the pool variable value at aKey.
		If not found then report an error."

	^self at: aKey in: aCategory ifAbsent: [self errorAbsentKey: aKey]! !

!WBPoolError class methods !
signal: msg subPool: aWBSubPool
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

	^self signal: msg manager: nil pool: nil subPool: aWBSubPool! !

!WBPoolManager methods !   
at: aKey in: aCategory put: anObject ifAbsent: aBlock
	"Set the pool variable value at aKey.
		If the key does not already exist, then evaluate aBlock."

	self pools do: [:each |
		(each includesKey: aKey) ifTrue: [
			^each at: aKey in: aCategory put: anObject]].
	^aBlock value! !

!WBPool methods !
removeKey: aKey ifAbsent: aBlock
	"Remove the specified key."

	| codePolicy |
	(self includesKey: aKey) ifFalse: [^aBlock value].
	self subPools do: [:each | each removeKey: aKey ifAbsent: []].
	(codePolicy := Smalltalk at: #WBCodePolicy ifAbsent: [nil]) notNil
		ifTrue: [codePolicy current removeKey: aKey inPoolNamed: self poolName]
		ifFalse: [self pool removeKey: aKey ifAbsent: [ ]].
	self triggerKeyRemoved: aKey.! !

!WBSubPool methods ! 
poolClass

	^self class poolClass! !

!WBPool methods !   
fileInFrom: aStream
	"File in the receiver's contents."

	[(self subPoolClass
		fileInFrom: aStream for: self
			) notNil] whileTrue: [ ].! !

!WBPool methods !   
subPoolClass

	^self class subPoolClass! !

!WBPoolManager class methods !
current
	"Answer the current (user) pool manager."

	^currentManager ifNil: [self constructCurrentManager]! !

!WBBitmapManager class methods !  
poolClass

	^WBBitmapPool! !

!WBPoolManager class methods !  
allTags

	^#(
		'BEGIN'
		'CATEGORY'
		'END'
		'FILENAME'
		'POOLBEGIN'
		'POOLEND'
		'POOLNAME'
		'POOLTABLE'
		'STRINGTABLE'
		'BITMAPS'
		'INCLUDE'
	)! !

!WBPool methods !   
renameKey: aKey to: newKey
	"Rename the specified key, keeping the same
		association object and value object."

	| codePolicy assoc |
	(self isValidNewKey: newKey) ifFalse: [
		(self isValidKey: newKey)
			ifTrue: [^self errorDuplicateKey: newKey]
			ifFalse: [^self errorInvalidKey: newKey]].
	(codePolicy := Smalltalk at: #WBCodePolicy ifAbsent: [nil]) notNil
		ifTrue: [
			codePolicy current
				renameKey: aKey to: newKey inPoolNamed: self poolName]
		ifFalse: [
			assoc := self pool associationAt: aKey.
			self pool removeAssociation: assoc.
			assoc key: newKey.
			self pool add: assoc].
			
	self subPools do: [:each |
		(assoc := each associationAt: aKey ifAbsent: [nil]) notNil ifTrue: [
			each removeAssociation: assoc.
			assoc key: newKey.
			each add: assoc]].
	self triggerKey: aKey renamed: newKey.! !

!WBPool methods !   
basicPool
	"Answer the pool or create one if it does not exist."

	| teamV |
	^Smalltalk at: self poolName ifAbsent: [
		(teamV := Smalltalk at: #TeamVInterface ifAbsent: [nil]) notNil ifTrue: [
			teamV current unpackagedPackage addPoolNamed: self poolName].
		Smalltalk at: self poolName ifAbsentPut: [Dictionary new]]! !

!WBBitmapManager class methods !
defaultCategory
	"Answer the default category."

	^'Standard'! !

!WBNLSManager methods !
fileInFrom: aStream
	"File in to the receiver."

	| includeFileName includeStream |
	[aStream atEnd] whileFalse: [
		(includeFileName := self stringDictionaryReaderClass new
			fileStream: aStream;
			nextIncludeFileNameOrNil
		) notNil ifTrue: [
			includeStream := File pathName: includeFileName in: aStream file directory.
			[self fileInFrom: includeStream] ensure: [includeStream close].
		] ifFalse: [self poolClass fileInFrom: aStream for: self]].! !

!Association methods !
asExistingWBPoolIn: aWBPoolManager
	"Answer the pool for aWBPoolManager, or nil."

	#addedByOSI.
	^self key asExistingWBPoolIn: aWBPoolManager! !

!WBPool methods !
errorDuplicateKey: aKey
	"Report the error that aKey is already defined in another pool."

	WBPoolErrorDuplicateKey signal: aKey pool: self.! !

!WBPool methods !   
triggerValueChanged: anObject at: aKey in: aCategory

	self
		triggerEvent: #valueChanged:at:in:
		withArguments: (Array with: anObject with: aKey with: aCategory).
	self manager
		triggerValueChanged: anObject
		at: aKey
		in: aCategory
		pool: self.! !

!WBFontPool class methods !
subPoolClass

	^WBFontSubPool! !

!WBPoolManager class methods !  
tagPoolName

	^'POOLNAME'! !

!WBPoolManager methods !
errorInvalidPoolName: aPoolName
	"Report the error that aPoolName is invalid."

	WBPoolErrorInvalidPoolName signal: aPoolName manager: self.! !

!WBBitmapSubPool class methods !
poolClass

	^WBBitmapPool! !

!WBBitmapManager methods !  
addBitmapsFromFile: aFileName
    "Load the bitmaps in aFileName.
        Answer a dictionary containing the bitmaps loaded or nil."

    | path stream subPool |
    #obsoleteMethod.
    "Retained for compatibility."
    (path := File findOrPromptFileName: aFileName) notNil ifTrue: [
        subPool := self flatPool subPoolNamed: self class defaultCategory.
        stream := File pathName: path.
        [subPool fileInFrom: stream] ensure: [stream close].
        ^self flat].
    ^nil! !

!WBPool methods ! 
at: aKey
	"Answer the pool variable value at aKey.
		If not found then report an error."

	^self at: aKey ifAbsent: [self errorAbsentKey: aKey]! !

!WBPoolManager methods !
updateSourceFor: aKey in: aPool value: anObject
	"If indicated, update the source for the specified pool/key."

	! !

!WBPoolManager class methods ! 
isValidPool: aDictionary
	"Answer true if the aDictionary is a valid pool."

	aDictionary isDictionary ifFalse: [^false].
	aDictionary associationsDo: [:each |
		(self isValidKey: each key) ifFalse: [^false].
		(self isValidValue: each value) ifFalse: [^false]].
	^true! !

!WBNLSDictionaryReader methods !   
nextIncludeFileNameOrNil

	| start comment |
	start := fileStream position.
	self nextNonBlank = $/ ifTrue: [
		fileStream backupOver: $/.
		(comment := self nextComment) notNil ifTrue: [
			(comment beginsWith: 'INCLUDE') ifTrue: [
				^self readStringFrom: comment]]].
	fileStream position: start.
	^nil! !

!WBPoolManager methods !
at: aKey in: aCategory put: anObject
	"Set the pool variable value at aKey.
		If the key does not already exist, then report an error."

	^self at: aKey in: aCategory put: anObject ifAbsent: [self errorAbsentKey: aKey]! !

!WBPoolManager methods ! 
removeKey: aKey
	"Remove the pool variable value at aKey.
		If not found then report an error."

	^self removeKey: aKey ifAbsent: [self errorAbsentKey: aKey]! !

!WBFontPool class methods !   
managerClass

	^WBFontManager! !

!WBPoolError methods !  
manager

	^manager ifNil: [
		self pool isNil
			ifTrue: [nil]
			ifFalse: [manager := self pool manager]]! !

!WBPoolErrorInvalidPool class methods ! 
messageTextFor: aPoolName
	"Answer the error message text."

	^'Invalid pool: ', aPoolName printString! !

!WBBitmapSubPool class methods !  
fileInCategoryFrom: aStream
	"File in the category."

	| tag pos line answer |
	tag := self managerClass tagCategory.
	pos := aStream position.
	line := aStream nextLine.
	(line beginsWith: tag) ifFalse: [
		aStream position: pos.
		^nil].
	answer := line copyFrom: tag size + 1 to: line size.
	answer := answer trimBlanks.
	(WBBitmapManager isValidCategory: answer) ifFalse: [^nil].
	^answer! !

!WBFontManager class methods !
isValidValue: anObject
	"Answer true if anObject is a valid pool variable value."

	^anObject isFont! !

!WBPool methods !   
fileNameFor: aCategory ifAbsent: aBlock
	"Answer the category's file name."

	| aSubPool |
	aSubPool := self subPoolFor: aCategory.
	aSubPool isNil ifTrue: [^aBlock value].
	^aSubPool fileName! !

!WBPoolManager class methods !   
tagCategory
	"Answer the file tag for the file name."

	^'CATEGORY'! !

!WBPoolManager class methods !   
subPoolClass

	^self poolClass subPoolClass! !

!WBNLSDictionaryReader methods !  
readNextTable

    (self nextFind: 'STRINGTABLE') ifTrue: [self readTable].! !

!WBPoolManager class methods !
invalidKeys

	^self allTags! !

!WBPoolManager methods !  
triggerPoolRemoved: aPoolName

	self
		triggerEvent: #poolRemoved: with: aPoolName;
		changed.! !

!WBSubPool methods ! 
owner: aWBPool
	"Private - Set the receiver's owner."

	owner := aWBPool.! !

!WBPoolManager methods !   
at: aKey
	"Answer the pool variable value at aKey.
		If not found then report an error."

	^self at: aKey ifAbsent: [self errorAbsentKey: aKey]! !

!WBPoolManager methods !
activeCategory
	"Answer the active category for all of the receiver's pools."

	| answer |
	self pools do: [:each |
		answer = (each activeCategory ifNil: [^nil]) ifFalse: [
			answer notNil ifTrue: [^nil].
			answer := each activeCategory]].
	^answer! !

!Bitmap class methods ! 
readFileHeader: bitmapFile
        "Private - Read the bitmap file header of a bitmapFile.
         Answer an instance WinBitmapFileHeader."
    | bmpFileHdr |
    #addedByOSI.
    bmpFileHdr := WinBitmapFileHeader new.
    bmpFileHdr bfType: bitmapFile nextUShort.
    bmpFileHdr bfSize: bitmapFile nextULong.
    bitmapFile nextUShort; nextUShort.
    bmpFileHdr offBits: bitmapFile nextULong.
    ^bmpFileHdr! !

!WBFontManager methods !  
defaultValueFor: aKey
	"Answer the default value for aKey.
		If not found then answer a default value."

	^SysFont! !

!WBPoolManager methods ! 
triggerFileNameChanged: aFileName pool: aWBPool

	self
		triggerEvent: #fileNameChanged:pool:
			withArguments: (Array with: aFileName with: aWBPool);
		changed.! !

!WBBitmapManager methods !   
addBitmapsFromModule: moduleName idMap: idMap
	"Load the bitmaps in aFileName.
		Answer a dictionary containing the bitmaps loaded or nil."

	| pool |
	#obsoleteMethod.
	"Retained for compatibility."
	(File findFileName: moduleName) notNil ifTrue: [
		pool := self flatPool.
		idMap associationsDo: [:each |
			pool at: each key in: self class defaultCategory put: (
				WBBitmapClass fromModule: moduleName id: each value)].
		^pool pool].
	^nil! !

!WBBitmapManager methods !  
flatName
	"Answer the receiver's flat name (global pool name)."

	#obsoleteMethod.
	"Retained for compatibility."
	^self == self class current
		ifTrue: [#WBBitmaps]
		ifFalse: [#WBSystemBitmaps]! !

!WBNLSSubPool class methods !
poolClass

	^WBNLSPool! !

!WBPoolManager methods !   
isValidPoolName: aPoolName
	"Answer true if the aPoolName is a valid pool name."

	^self class isValidPoolName: aPoolName! !

!WBNLSPool class methods ! 
subPoolClass

	^WBNLSSubPool! !

!WBPoolManager methods ! 
valueAt: aKey
	"Answer the pool variable value at aKey.
		If not found then answer a default value."

	^self at: aKey ifAbsent: [self defaultValueFor: aKey]! !

!WBPoolManager class methods ! 
validKey: aString
	"Answer a valid pool variable name based on aString."

	| answer |
	(answer := aString) isEmpty ifTrue: [^'APoolVar'].
	(answer detect: [:ch | ch isAlphaNumeric not] ifNone: [nil]) notNil ifTrue: [
		answer := aString select: [:ch | ch isAlphaNumeric]].
	answer first isLetter ifFalse: [answer := 'A', answer].
	answer first isUppercase ifFalse: [
		answer :=
			(String with: answer first asUppercase),
			(answer copyFrom: 2 to: answer size)].
	^answer! !

!WBPoolManager methods !  
removePool: aPoolRef
	"Remove aPoolRef from the receiver's collection of pools.
		aPoolRef can be a key in the Smalltalk system dictionary,
		a pool dictionary in the Smalltalk system dictionary,
		an association in the Smalltalk system dictionary,
		or an instance of WBPool (or its subclasses)."

	| existingPool existingPoolName |
	existingPool := self poolFor: aPoolRef.
	existingPool isNil ifTrue: [^self].
	existingPoolName := existingPool poolName.
	existingPool manager: nil.
	self pools removeKey: existingPoolName.
	self triggerPoolRemoved: existingPoolName.! !

!WBPoolManager methods !  
pools
	"Answer the collection of the receiver's pools."

	^pools! !

!WBPoolManager class methods !  
tagPoolEnd

	^'POOLEND'! !

!WBFontManager methods !  
generatePortableFontCode: aBoolean
	"Set true portable font code should be generated."

	generatePortableFontCode := aBoolean! !

!WBPool methods !  
subPoolFor: aCategory
	"Answer the sub pool named aCategory."

	^self subPools
		at: aCategory
		ifAbsent: [nil]! !

!WBPool methods ! 
triggerKey: oldKey renamed: newKey

	self
		triggerEvent: #key:renamed:
		with: oldKey
		with: newKey.
	self manager
		triggerKey: oldKey
		renamed: newKey
		pool: self.! !

!WBSubPool methods ! 
copyToPool: aDictionary
	"Copy the receiver's contents to aDictionary."

	self associationsDo: [:each |
		aDictionary at: each key put: each value].! !

!WBNLSManager methods !
stringDictionaryReaderClass

	^self class stringDictionaryReaderClass! !

!WBPool methods !   
removeCategory: aCategory
	"Remove the specified category."

	| existingSubPool |
	existingSubPool := self subPoolFor: aCategory.
	existingSubPool isNil ifTrue: [^self].
	existingSubPool owner: nil.
	self activeCategory = existingSubPool category ifTrue: [self activeCategory: nil].
	self subPools removeKey: aCategory.
	self triggerCategoryRemoved: aCategory.! !

!WBNLSPool class methods !
fileInPoolNameFrom: aStream
	"Answer the pool name stored in aStream."

	^self stringDictionaryReaderClass new
		fileStream: aStream;
		readNextPoolName! !

!WBNLSDictionaryReader methods !  
findNextPoolBegin

	| comment |
	[(comment := self nextComment) notNil] whileTrue: [
		comment = 'POOLTABLE' ifTrue: [
			[(comment := self nextComment) notNil] whileTrue: [
				comment = 'POOLBEGIN' ifTrue: [^true]]]].
	^false! !

!WBPool methods !
manager: aWBPoolManager
	"Private - Set the receiver's pool manager."

	manager := aWBPoolManager.! !

!WBPool class methods !   
fileInFileNameFrom: aStream
	"File in the file name."

	^nil! !

!WBFontSubPool class methods !  
poolClass

	^WBFontPool! !

!WBPoolManager methods !  
isValidValue: anObject
	"Answer true if aString is a valid pool variable name."

	^self class isValidValue: anObject! !

!WBPoolError methods !  
pool: aWBPool

	pool := aWBPool.! !

!WBPool methods !
triggerFileNameChanged: aFileName

	self triggerEvent: #fileNameChanged: with: aFileName.
	self manager triggerFileNameChanged: aFileName pool: self.! !

!WBPool methods !  
errorInvalidCategory: aCategory
	"Report the error that aKey is invalid."

	WBPoolErrorInvalidCategory signal: aCategory  pool: self.! !

!WBPoolManager methods !   
triggerKeyRemoved: oldKey pool: aWBPool

	self
		triggerEvent: #keyRemoved:pool:
			withArguments: (Array with: oldKey with: aWBPool);
		changed.! !

!String class methods !  
named: aKey
	"Answer the NLS string at the specified key."

	^WBNLSManager current at: aKey! !

!WBPoolManager methods ! 
isValidKey: aKey
	"Answer true if aString is a valid pool variable name."

	^self class isValidKey: aKey! !

!WBPoolManager methods !
updateSource
	"Answer true if the source should be updated."

	^updateSource ifNil: [false]! !

!WBBitmapManager methods !   
updateSource
	"Answer true if the source should be updated."

	^updateSource ifNil: [(Smalltalk at: #OSITool ifAbsent: [nil]) notNil]! !

!WBSubPool class methods ! 
managerClass

	^self poolClass managerClass! !

!WBPoolError class methods !  
signal: msg manager: aWBPoolManager
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the argument message
        text with the occurrence."

	^self signal: msg manager: aWBPoolManager pool: nil subPool: nil! !

!WBPoolManager methods !   
keys
	"Answer a Set containing all of the keys in the receiver."

	| answer |
	answer := Set new.
	self pools do: [:each | answer addAll: each keys].
	^answer! !

!WBPoolManager methods !   
triggerValueChanged: anObject at: aKey in: aCategory pool: aWBPool

	self
		triggerEvent: #valueChanged:at:in:pool:
			withArguments: (Array with: anObject with: aKey with: aCategory with: aWBPool);
		changed.! !

!WBNLSDictionaryReader methods ! 
readStringFrom: aStringOrStream
	"Answer the quoted string from aStringOrStream."

	| aStream answer |
	aStream := aStringOrStream asStream.
	(aStream skipTo: $"; atEnd) ifTrue: [^nil].
	answer := aStream upTo: $".
	[aStream peekFor: $"] whileTrue: [
		answer := answer, '"', (aStream upTo: $")].
	^answer! !

!WBPool methods !
addCategory: aCategory
	"Add the specified category."

	| newSubPool |
	(newSubPool := self subPoolFor: aCategory) isNil ifTrue: [
		(self isValidCategory: aCategory) ifFalse: [^self errorInvalidCategory: aCategory].
		newSubPool := self subPoolClass named: aCategory for: self.
		newSubPool owner: self.
		self subPools at: aCategory put: newSubPool.
		self triggerCategoryAdded: aCategory.
		self activeCategory isNil ifTrue: [self activeCategory: aCategory]].
	^newSubPool! !

!WBPool methods !
keys
	"Answer the pool keys."

	^self pool keys! !

!WBPool methods !
keyAtValue: anObject in: aCategory
	"Answer the key in the receiver whose paired value
		 equals anObject.  If not found, answer nil."

	^self keyAtValue: anObject in: aCategory ifAbsent: [nil]! !

!WBPool methods ! 
errorInvalidKey: aKey
	"Report the error that aKey is invalid."

	WBPoolErrorInvalidKey signal: aKey pool: self.! !

!WBPoolError methods !  
subPool

	^subPool! !

!WBPoolManager methods !   
removeCategory: aCategory
	"Remove the specified category for all of the receiver's pools."

	self pools do: [:each | each removeCategory: aCategory].! !

!WBBitmapManager class methods !  
isValidValue: anObject
	"Answer true if anObject is a valid pool variable value."

	^anObject isBitmap! !

!WBFontPool methods ! 
fileInFrom: aStream
	"File in the receiver's contents."

	aStream fileIn.! !

!WBPoolManager class methods ! 
poolFor: aPoolRef
	"Answer the managed pool for aPoolRef."

	| answer |
	self managers do: [:each |
		(answer := each poolFor: aPoolRef)
			notNil ifTrue: [^answer]].
	^nil! !

!WBPoolManager class methods !  
poolClass

	^WBPool! !

!WBPoolError methods !
manager: aWBPoolManager

	manager := aWBPoolManager.! !

!WBPool methods !
pool
	"Answer the global pool being managed."

	^pool! !

!WBPoolManager methods !   
fileInFrom: aStream
	"File in to the receiver."

	[aStream atEnd] whileFalse: [
		(self poolClass fileInFrom: aStream for: self) ifNil: [^self]].! !

!WBPool methods ! 
associationAt: aKey ifAbsent: aBlock
	"Answer the pool variable association at aKey.
		If not found then answer aBlock evaluated."

	^self pool associationAt: aKey ifAbsent: aBlock! !

!Bitmap class methods !
fileInFrom: aStream
	"Answer a new instance of the receiver constructed from aStream."

	#addedByOSI.
	^WBBitmapClass fromStream: aStream! !

!WBPool methods ! 
isValidValue: anObject
	"Answer true if the anObject is a valid key."

	^self manager isValidValue: anObject! !

!WBBitmapManager methods !  
flatPool
	"Answer the pool containing the flat representation of the receiver."

	#obsoleteMethod.
	"Retained for compatibility."
	^self poolNamed: self flatName! !

!WBNLSSubPool methods !  
stringDictionaryReaderClass

	^self class stringDictionaryReaderClass! !

!Object methods !   
asExistingWBPoolIn: aWBPoolManager
	"Answer the pool for aWBPoolManager, or nil."

	#addedByOSI.
	^aWBPoolManager pools
		detect: [:each | each pool == self]
		ifNone: [nil]! !

!WBPoolManager class methods !  
isValidPoolName: aPoolName
	"Answer true if the aPoolName is a valid pool name."

	^aPoolName isString and: [
		(self validPoolName: aPoolName) = aPoolName]! !

!WBPoolErrorDuplicateKey class methods !   
messageTextFor: duplicateKey
	"Answer the error message text."

	^'Duplicate pool key: ', duplicateKey printString! !

!WBPoolManager methods !  
keyAtValue: anObject ifAbsent: aBlock
	"Answer the key in the receiver whose paired value
		 equals anObject.  If not found, answer aBlock evaluated."

	self pools do: [:each |
		each pool associationsDo: [:eachAssoc |
			eachAssoc value = anObject ifTrue: [^eachAssoc key]]].
	^aBlock value! !

!WBPool methods !
includesKey: aKey
	"Answer true if aKey is defined in the receiver."

	^self pool includesKey: aKey! !

!WBPool methods !
errorInvalidPool: aPoolName
	"Report the error that aDictionary is an invalid pool."

	WBPoolErrorInvalidPool signal: aPoolName pool: self.! !

!WBPool methods !
isValidKey: aKey
	"Answer true if the aKey is a valid key."

	^self manager isValidKey: aKey! !

!WBNLSDictionaryReader methods !
nextComment
	"Private - Answer the next comment that follows in the
		  receiver's file. Comments are as defined by
		  standard C Language."
	| answer |
	fileStream upTo: $/.
	fileStream atEnd ifTrue: [^nil].
	answer := fileStream upTo: $/.
	answer size >= 2 ifTrue: [
		answer := answer copyFrom: 2 to: answer size - 1].
	^answer trimBlanks! !

!WBPoolManager methods !   
triggerKeyAdded: newKey pool: aWBPool

	self
		triggerEvent: #keyAdded:pool:
			withArguments: (Array with: newKey with: aWBPool);
		changed.! !

!WBPool methods !
isValidPool: aDictionary
	"Answer true if the aDictionary is a valid pool."

	^self manager isValidPool: aDictionary! !

!WBPool methods !   
keyAtValue: anObject in: aCategory ifAbsent: aBlock
	"Answer the key in the receiver whose paired value
		 equals anObject.  If not found, answer aBlock evaluated."

	| aSubPool |
	aSubPool := self subPoolFor: aCategory.
	aSubPool isNil ifTrue: [^aBlock value].
	^aSubPool keyAtValue: anObject ifAbsent: aBlock! !

!WBPoolManager class methods !
tagFileName
	"Answer the file tag for the file name."

	^'FILENAME'! !

!WBPoolManager methods ! 
at: aKey in: aCategory
	"Answer the pool variable value at aKey.
		If not found then report an error."

	^self at: aKey in: aCategory ifAbsent: [self errorAbsentKey: aKey]! !

!WBPoolManager methods !
basicAllowDuplicateKeys: aBoolean

	allowDuplicateKeys := aBoolean.! !

!WBPool methods ! 
at: aKey in: aCategory ifAbsent: aBlock
	"Answer the pool variable value at aKey.
		If not found then answer aBlock evaluated."

	| aSubPool |
	aSubPool := self subPoolFor: aCategory.
	aSubPool isNil ifTrue: [^aBlock value].
	^aSubPool at: aKey ifAbsent: aBlock! !

!WBBitmapSubPool class methods !   
fileInFileNameFrom: aStream
	"File in the file name."

	| tag pos line answer |
	tag := self managerClass tagFileName.
	pos := aStream position.
	line := aStream nextLine.
	(line beginsWith: tag) ifFalse: [
		aStream position: pos.
		^nil].
	answer := line copyFrom: tag size + 1 to: line size.
	answer := answer trimBlanks.
	^answer! !

!WBPoolManager methods !  
triggerFileNameChanged: aFileName in: aCategory pool: aWBPool

	self
		triggerEvent: #fileNameChanged:in:pool:
			withArguments: (Array with: aFileName with: aCategory with: aWBPool);
		changed.! !

!WBPool methods !   
activeCategory: aCategory
	"Set the active category."

	activeCategory = aCategory ifTrue: [^false].
	(self activeCategoryPrim: aCategory) ifFalse: [^false].
	self triggerActiveCategoryChanged: aCategory.
	^true! !

!WBPoolManager class methods !
tagEnd

	^'END'! !

!WBFontManager class methods !
poolClass

	^WBFontPool! !

!WBPoolManager methods !  
allowDuplicateKeys: aBoolean

	| allKeys |
	aBoolean ifFalse: [
		allKeys := Set new.
		self pools do: [:eachPool |
			eachPool keys do: [:eachKey |
				(allKeys includes: eachKey)
					ifTrue: [^self errorDuplicateKey: eachKey]
					ifFalse: [allKeys add: eachKey]]]].
	self basicAllowDuplicateKeys: aBoolean! !

!WBPoolManager methods !
poolNamed: aSymbol
	"Answer the pool named aSymbol
		and create one if one does not exist."

	^(self poolFor: aSymbol) ifNil: [self addPoolNamed: aSymbol]! !

!WBPoolManager methods ! 
defaultValueFor: aKey
	"Answer the default value for aKey.
		If not found then answer a default value."

	^nil! !

!WBPoolManager methods ! 
errorDuplicatePoolName: aPoolName
	"Report the error that aPoolName already exists."

	WBPoolErrorDuplicatePoolName signal: aPoolName manager: self.! !

!WBSubPool methods !
owner
	"Answer the receiver's owner."

	^owner! !

!Bitmap methods ! 
storeOnStream: s
        "Private - WBPro Development.
            Saving bitmaps with the WBBitmapManager."

    | bits fileHeader |
	#addedByOSI.
    bits := self getDIBits.
    bits isNil ifTrue: [^self].
    fileHeader := WinBitmapFileHeader new.
    fileHeader bfType: 'BM';
        bfSize: 14 + bitmapInfo contents size + bits size;
        reserved1: 0;
        reserved2: 0;
        offBits: 14 + bitmapInfo contents size.

    s nextPutAll: fileHeader contents asString.
    bitmapInfo contents do: [: aByte |
        s nextPut: aByte asCharacter].
    bits do: [: aByte |
        s nextPut: aByte asCharacter].! !

!WBPoolManager class methods !  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
		addAll: #(
			#activeCategoryChanged:
			#categoryAdded:pool:
			#categoryRemoved:pool:
			#fileNameChanged:pool:
			#fileNameChanged:in:pool:
			#keyAdded:pool:
			#key:renamed:pool:
			#keyRemoved:pool:
			#poolAdded:
			#poolRemoved:
			#valueChanged:at:in:pool: );
		yourself! !

!WBPoolManager class methods !  
managers
	"Answer the pool managers."

	^Array with: self current with: self system! !

!WBBitmapPool class methods !
managerClass

	^WBBitmapManager! !

!WBNLSManager class methods ! 
isValidValue: anObject
	"Answer true if anObject is a valid pool variable value."

	^anObject isString! !

!WBPool methods ! 
triggerKeyRemoved: oldKey

	self
		triggerEvent: #keyRemoved:
		with: oldKey.
	self manager
		triggerKeyRemoved: oldKey
		pool: self.! !

!WBBitmapSubPool methods ! 
fileInFrom: aStream
    "Read bitmaps from the stream."

    | line lineStream aKey aModule anID |
    aStream nextLine = self managerClass tagBitmaps ifFalse: [^self errorInvalidFile: aStream].
    [aStream atEnd or: [
        line := aStream nextLine.
        line = self managerClass tagEnd
    ]] whileFalse: [
        lineStream := line asStream.
        aKey := lineStream nextWord.
        (aModule := lineStream countBlanks; upTo: $ ) isEmpty
            ifTrue: [
                self owner
                    at: aKey
                    in: self category
                    put: (WBBitmapClass fileInFrom: aStream)]
            ifFalse: [
                anID := lineStream nextWord.
                aModule = '*'
                    ifTrue: [
                        aModule := nil.
                        anID := OperatingSystemConstants at: anID ifAbsent: [anID asInteger]]
                    ifFalse: [anID := anID asInteger].
                self owner
                    at: aKey
                    in: self category
                    put: (
                        WBBitmapClass
                            fromModule: (
                                OperatingSystem isOS2
                                    ifTrue: [aModule fileName]
                                    ifFalse: [aModule])
                            id: anID)]].! !

!WBPool methods ! 
isValidNewKey: aKey
	"Answer true if the aKey is a valid new key."

	^(self includesKey: aKey) not
		and: [self manager isValidNewKey: aKey]! !

!WBPoolManager methods !   
updateSource: aBoolean
	"Set true if the source should be updated."

	updateSource := aBoolean.! !

!WBBitmapManager methods !   
rename: oldBitmapName to: newBitmapName
	"Rename the specified bitmap."

	#obsoleteMethod.
	"Retained for compatibility."
	self pools do: [:eachPool |
		(eachPool includesKey: oldBitmapName) ifTrue: [
			^eachPool renameKey: oldBitmapName to: newBitmapName]].
	^self errorAbsentKey: oldBitmapName! !

!WBNLSDictionaryReader methods !   
readNextPoolFileName

	| comment |
	[(comment := self nextComment) notNil] whileTrue: [
		(comment beginsWith: WBNLSManager tagFileName) ifTrue: [
			^self readStringFrom: comment]].
	^nil! !

!WBPool methods !
triggerCategoryRemoved: oldCategory

	self
		triggerEvent: #categoryRemoved:
		with: oldCategory.
	self manager
		triggerCategoryRemoved: oldCategory
		pool: self.! !

!WBPoolManager methods ! 
errorDuplicateKey: aKey
	"Report the error that aKey is already defined in another pool."

	WBPoolErrorDuplicateKey signal: aKey pool: self.! !

!WBPool class methods ! 
fileInFrom: aStream for: aWBPoolManager
	"Answer a new instance of the receiver."

	| poolName fileName pool |
	(poolName := self fileInPoolNameFrom: aStream) ifNil: [^nil].
	fileName := self fileInFileNameFrom: aStream.
	pool := aWBPoolManager poolNamed: poolName.
	fileName notNil ifTrue: [pool fileName: fileName].
	pool fileInFrom: aStream.
	^pool! !

!WBPoolManager methods !   
triggerCategoryAdded: newCategory pool: aWBPool

	self
		triggerEvent: #categoryAdded:pool:
			withArguments: (Array with: newCategory with: aWBPool);
		changed.! !

!WBPool methods !
triggerActiveCategoryChanged: aCategory

	self triggerEvent: #activeCategoryChanged: with: aCategory.! !

!WBPool methods !   
errorAbsentKey: aKey
	"Report the error that aKey was not found."

	WBPoolErrorAbsentKey signal: aKey pool: self.! !

!WBNLSSubPool class methods !  
fileInCategoryFrom: aStream
	"File in the category."

	^self stringDictionaryReaderClass new
		fileStream: aStream;
		readNextCategoryName! !

!WBPool methods !   
fileName: aString
	"Set the receiver's file name."

	fileName = aString ifFalse: [
		fileName := aString.
		self triggerFileNameChanged: fileName].! !

!WBPoolManager class methods ! 
constructCurrentManager
	"Private - Construct the current (user) pool manager."

	^currentManager := self new initialize! !

!WBPool methods !   
defaultFileName
	"Answer the receiver's default file name."

	^''! !

!WBNLSDictionaryReader methods !   
readNextPoolName

	| comment |
	[(comment := self nextComment) notNil] whileTrue: [
		(comment beginsWith: WBNLSManager tagPoolName) ifTrue: [
			^self readStringFrom: comment]].
	^nil! !

!WBPool methods !
at: aKey in: aCategory ifAbsentPut: aBlock
	"Answer the pool variable value at aKey.
		If not found then put the value from aBlock evaluated."

	^self at: aKey in: aCategory ifAbsent: [
		self at: aKey in: aCategory put: aBlock value]! !

!WBNLSManager class methods !   
stringDictionaryReaderClass

	^WBNLSDictionaryReader! !

!WBPoolManager methods ! 
subPoolClass

	^self class subPoolClass! !

!WBNLSSubPool class methods ! 
stringDictionaryReaderClass

	^WBNLSPool stringDictionaryReaderClass! !

!WBPoolManager class methods !   
validPoolName: aPoolName
	"Answer a valid pool name based on aPoolName."

	aPoolName isEmpty ifTrue: [^'APool'].
	^self validKey: aPoolName! !

!WBPoolManager class methods !  
constructSystemManager
	"Private - Construct the system pool manager."

	^systemManager := self new initialize! !

!Bitmap class methods !   
fromStream: s
	"Answer a new instance of the receiver read from the specified stream."

	| bfh bih rgbColor bytes bits bitmap |
	#addedByOSI.
	bfh := self readFileHeader: s.
	bih := self readBitmapHeader: s.
	bih bitCount = 24 ifFalse: [
		rgbColor := ByteArray new: ((1 bitShift: bih bitCount) * 4).
		1 to: rgbColor size do: [: i |
			rgbColor at: i put: s nextByte
		]
	].
	bih sizeImage = 0 ifTrue: [
		bytes := (((
			bih width * bih bitCount) + 31) // 32 * 4) * bih height
	] ifFalse: [
		bytes := bih sizeImage.
	].
	bits := ByteArray new:  bytes.
	s getBytesFor: bits.

	bitmap := self new.
	bitmap bitmapInfo: (
		rgbColor isNil
			ifTrue: [WinBitmapInfo new contents: bih contents]
			 ifFalse: [
				WinBitmapInfo new contents: bih contents, rgbColor]).
	bitmap createBitmap: bits.
	bitmap
		deviceContext: MemoryContext;
		graphicsTool: (
			Pen forDC: MemoryContext medium: bitmap).
	^bitmap! !

!WBPoolManager methods !  
triggerKey: oldKey renamed: newKey pool: aWBPool

	self
		triggerEvent: #key:renamed:pool:
			withArguments: (Array with: oldKey with: newKey with: aWBPool);
		changed.! !

!WBBitmapManager methods !
size
	"Answer the # of elements in the receiver."

	#obsoleteMethod.
	"Retained for compatibility."
	^self flat size! !

!WBNLSManager class methods ! 
poolClass

	^WBNLSPool! !

!WBPoolManager methods !   
isValidNewKey: aKey
	"Answer true if aString is a valid pool variable name."

	(self isValidKey: aKey) ifFalse: [^false].
	self allowDuplicateKeys ifFalse: [
		(self includesKey: aKey) ifTrue: [^false]].
	^true! !

!WBSubPool class methods ! 
fileInFileNameFrom: aStream
	"File in the file name."

	^nil! !

!WBPoolErrorInvalidPoolName class methods ! 
messageTextFor: aPoolName
	"Answer the error message text."

	^'Invalid pool name: ', aPoolName printString! !

!WBBitmapManager methods !   
name
	"Answer the receiver's name."

	#obsoleteMethod.
	"Retained for compatibility."
	^self flatName! !

!WBPool methods !
fileName
	"Answer the receiver's file name."

	^fileName ifNil: [self defaultFileName]! !

!WBPool methods ! 
basicAt: aKey in: aCategory put: anObject
	"Private - Set the pool variable value at aKey.
		If not found then report an error."

	| aSubPool codePolicy |
	aSubPool := self subPoolNamed: aCategory.
	aSubPool at: aKey put: anObject.
	(self pool includesKey: aKey)
		ifTrue: [
			self activeCategory = aSubPool category ifTrue: [
				self pool at: aKey put: anObject.
				self manager updateSourceFor: aKey in: self value: anObject]]
		ifFalse: [
			(codePolicy := Smalltalk at: #WBCodePolicy ifAbsent: [nil]) notNil ifTrue: [
				codePolicy current addKey: aKey inPoolNamed: self poolName].
			self pool at: aKey put: anObject.
			self manager updateSourceFor: aKey in: self value: anObject].
	^anObject! !

!WBNLSSubPool class methods !   
fileInFileNameFrom: aStream
	"File in the file name."

	^self stringDictionaryReaderClass new
		fileStream: aStream;
		readNextCategoryFileName! !

!WBNLSDictionaryReader methods !   
dictionary: aDictionary

	dictionary := aDictionary.! !

!WBPoolManager methods ! 
triggerPoolAdded: aPoolName

	self
		triggerEvent: #poolAdded: with: aPoolName;
		changed.! !

!WBPoolManager class methods !   
tagBitmaps
	"Answer the bitmaps tag."

	^'BITMAPS'! !

!WBSubPool methods !  
category
	"Answer the receiver's category."

	^category! !

!WBPoolManager methods ! 
at: aKey ifAbsent: aBlock
	"Answer the pool variable value at aKey.
		If not found then answer aBlock evaluated."

	self pools do: [:each |
		(each includesKey: aKey) ifTrue: [
			^each at: aKey]].
	^aBlock value! !

!WBSubPool class methods !  
fileInFrom: aStream for: aWBPool
	"Answer a new instance of the receiver."

	| category fileName subPool |
	(category := self fileInCategoryFrom: aStream) ifNil: [^nil].
	fileName := self fileInFileNameFrom: aStream.
	subPool := aWBPool subPoolNamed: category.
	fileName notNil ifTrue: [subPool fileName: fileName].
	subPool fileInFrom: aStream.
	^subPool! !

!WBBitmapManager methods ! 
flat
	"Answer the flat representation of the receiver."

	#obsoleteMethod.
	"Retained for compatibility."
	^self flatPool pool! !

!WBPool methods !   
manager
	"Private - Answer the receiver's manager."

	^manager! !

!WBNLSDictionaryReader methods !  
readNextCategoryFileName

	| comment |
	[(comment := self nextComment) notNil] whileTrue: [
		(comment beginsWith: WBNLSManager tagFileName) ifTrue: [
			^self readStringFrom: comment]].
	^nil! !

!WBSubPool methods ! 
fileInFrom: aStream! !

!WBPoolManager methods !
initialize

	super initialize.
	pools := Dictionary new.! !

!WBPoolManager class methods !  
isValidValue: anObject
	"Answer true if anObject is a valid pool variable value."

	^true! !

!WBPoolErrorInvalidValue class methods !   
messageTextFor: anObject
	"Answer the error message text."

	^'Invalid pool value: ', anObject printString! !

!WBFontManager methods !  
generatePortableFontCode
	"Answer true portable font code should be generated."

	^generatePortableFontCode
		ifNil: [self wbEditorClass generatePortableFontCode]! !

!WBPool methods !
poolName
	"Answer the name of the global pool being managed."

	^poolName! !

!WBBitmapManager methods ! 
addBitmapPoolNamed: aSymbol
	"Add a bitmap pool to the receiver."

	| newPool |
	#obsoleteMethod.
	"Retained for compatibility."
	newPool := self addPoolNamed: aSymbol.
	newPool pool associationsDo: [:each |
		newPool at: each key in: self class defaultCategory put: each value].! !

!WBPool methods !   
add: anAssociation
	"Add the association to the receiver's pool.
		Report an error if the key is exists or is invalid."

	(self isValidNewKey: anAssociation key) ifFalse: [
		(self isValidKey: anAssociation key)
			ifTrue: [^self errorDuplicateKey: anAssociation key]
			ifFalse: [^self errorInvalidKey: anAssociation key]].
	(self isValidValue: anAssociation value)
		ifFalse: [^self errorInvalidValue: anAssociation value].
	self pool add: anAssociation.
	self triggerKeyAdded: anAssociation key.! !

!WBNLSDictionaryReader methods !  
fileStream: aStream
	"Initialize the receiver."

	fileStream := aStream.
	fileName isNil ifTrue: [
		fileName :=
			[aStream file pathName fileName]
				ifCurtailed: ['?']].! !

!WBPoolManager methods !   
errorAbsentKey: aKey
	"Report the error that aKey was not found."

	WBPoolErrorAbsentKey signal: aKey manager: self.! !

!WBSubPool methods !
fileName
	"Answer the file name associated with the receiver."

	^fileName ifNil: [self defaultFileName]! !

!WBPoolManager class methods !  
invalidCategories

	^self allTags! !

!WBBitmapManager methods !  
isEmpty
	"Answer true if the receiver collection
		 contains no elements, else answer false."

	#obsoleteMethod.
	"Retained for compatibility."
	^self flat isEmpty! !

!WBPoolManager methods !  
categories
	"Answer the receiver's categories."

	| answer |
	answer := Set new.
	self pools do: [:each | answer addAll: each categories].
	^answer! !

!WBNLSPool methods !  
stringDictionaryReaderClass

	^self class stringDictionaryReaderClass! !

!WBNLSPool class methods !  
fileInFileNameFrom: aStream
	"File in the file name."

	^self stringDictionaryReaderClass new
		fileStream: aStream;
		readNextPoolFileName! !
 
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!