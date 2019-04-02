"3.0.0.1"
!

Smalltalk at: #WBDefaultColors ifAbsentPut: [ nil ]!

!Color methods !  
wbColorSelector
	"Answer the selector for the receiver or nil."

	#addedByOSI.
	Color wbDefaultColors associationsDo: [:each | each value == self ifTrue: [^each key]].
	^Color defaultColorClass defaultColors keyAtValue: self ifAbsent: [nil]! !

!Color class methods !
wbClearDefaultColors

	WBDefaultColors := nil.! !

!Color class methods ! 
wbDefaultColors
	"Answer a dictionary mapping color selectors to colors."

	#addedByOSI.
	WBDefaultColors notNil ifTrue: [^WBDefaultColors].
	(Message receiver: self selector: #wbClearDefaultColors) performDeferred.
	WBDefaultColors := self wbConstructDefaultColors.
	^WBDefaultColors! !

!Color class methods !  
wbConstructDefaultColors

	| answer selector |
	#addedByOSI.
	answer := Dictionary new.
	answer addAll: Color defaultColorClass defaultColors.
	SystemColorConstants keysDo: [:eachKey |
		selector :=
			((eachKey copyFrom: 12 to: 12) asLowercase,
			(eachKey copyFrom: 13 to: eachKey size)) asSymbol.
		answer at: selector put: (Color perform: selector)].
	^answer! !
   
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!