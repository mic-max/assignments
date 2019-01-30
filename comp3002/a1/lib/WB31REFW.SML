"3.0.0.5"
!  

EntryField subclass: #EnhancedEntryField
  instanceVariableNames: 
    ' case justification character field getFocus '
  classVariableNames: ''
  poolDictionaries: 
    ' CharacterConstants OperatingSystemConstants VirtualKeyConstants '!

!EnhancedEntryField methods ! 
justification
		"Private"
    ^justification! !

!EnhancedEntryField methods !
okNumber

    "Validates whether aChar is a acceptable character for a
         Integer in input string at position pos"
    "Courtesy of Cargill"

    | answer |
    self contents: (answer :=self contents asFloat printString).
    ^true ! !

!EnhancedEntryField methods !
okZipCodeUS
    "Answer the input as a zip code.
    Format is: 99999 or 99999-9999."
    | input |
    input := self contents select: [ :aChar | aChar isDigit ].
    input size = 5 ifTrue:[
        self contents: input.
        ^true
    ] ifFalse: [ input size = 9 ifTrue: [
        self contents:
            (input copyFrom: 1 to: 5), '-',
            (input copyFrom: 6 to: 9).
        ^true
    ] ifFalse: [ input size = 0 ifTrue:[
        ^true
    ] ifFalse:[
        ^false
    ]]].! !

!EnhancedEntryField methods !  
okPositiveInteger: aChar
    "Validates whether aChar is a acceptable character for a
    Positive Integer"

    ^aChar isDigit! !

!EnhancedEntryField methods !   
ok7Comma2: aChar

    "Validates whether aChar is a acceptable
        character for a Positive Integer"
    "Courtesy of Cargill"

   aChar == $-
        ifTrue: [^false].
    ^self
            okFixed: aChar
            leading: 7
            trailing: 2! !

!EnhancedEntryField methods !   
selectFirst
	    "Place cursor at beginning of the text."
    self selectFrom: 1 to: 0! !

!EnhancedEntryField methods !  
okAlphaNumericNoSpace: aChar
    "Validates whether aChar is a acceptable alpha character
     ( $A - $Z, $a - $z, $0 - $9)"

    ^aChar isLetter or: [ aChar isDigit ]! !

!EnhancedEntryField methods !   
okNumeric: aChar
    "Validates whether aChar is a acceptable character for a
     Number in input string at position pos"
    | pos |
    pos := self getSelection x.
    ((aChar == $- or: [ aChar == $+ ]) and: [ pos == 1 ]) ifTrue: [ ^true ].
    (aChar == $. and: [ (self contents select: [ :c | c == $. ]) size < 1 ]) ifTrue: [ ^true ].
    ^self okPositiveInteger: aChar! !

!EnhancedEntryField methods ! 
triggerObjectChanged
        "Private - trigger the objectChanged event."
    (self hasActionForEvent: #objectChanged:)
        ifTrue: [self triggerEvent: #objectChanged: with: self objectContents]! !

!EnhancedEntryField methods ! 
ok20Comma10: aChar

    "Validates whether aChar is a acceptable
        character for a Positive Integer"
    "Courtesy of Cargill"

    ^self
            okFixed: aChar
            leading: 20
            trailing: 10! !

!EnhancedEntryField methods !  
okPhoneNumberExtUS
	"Answer the input as a formated phone number.
	 Format is: (999) 999-9999, 999-9999, x999, (999) 999-9999 x999."
	| input dict digitCount isExtChar isExtCharFirst extChar |
	digitCount := 0.
	isExtChar := false.
	isExtCharFirst := false.
	dict := self class phoneConversionDict.
	input := (self contents collect: [ :aChar |
		aChar isAlphaNumeric ifTrue: [
			isExtChar
				ifTrue: [
					isExtChar := false.
					digitCount := digitCount + 1 ]
				ifFalse: [
					(digitCount = 0) & (aChar asLowerCase = $x) ifTrue: [
						isExtChar := true.
						isExtCharFirst := true ].
					(digitCount = 10) & (aChar asLowerCase = $x) ifTrue: [
						isExtChar := true ].
					isExtChar ifFalse: [
						digitCount := digitCount + 1 ]]].
		isExtChar
			ifTrue: [ aChar ]
			ifFalse: [
				dict
					at: aChar asUpperCase
					ifAbsent: [ aChar ]]]
		) select: [ :aChar | aChar isDigit ].
	isExtCharFirst & (input size >= 7) ifTrue: [
		(extChar := dict at: $X ifAbsent: [ nil ]) notNil ifTrue: [
			input := (String with: extChar), input ] ].
	input size >= 10 ifTrue:[
		input size = 10 ifTrue: [
			self contents:
				'(', (input copyFrom: 1 to: 3),
				') ', (input copyFrom: 4 to: 6),
				'-', (input copyFrom: 7 to: 10)
		] ifFalse: [
			self contents:
				'(', (input copyFrom: 1 to: 3),
				') ', (input copyFrom: 4 to: 6),
				'-', (input copyFrom: 7 to: 10),
				' x', (input copyFrom: 11 to: input size)
		].
		^true
	] ifFalse:[ input size >= 7 ifTrue:[
		self contents:
			(input copyFrom: 1 to: 3), '-',
			(input copyFrom: 4 to: 7).
			^true
	] ifFalse: [ input size >= 3 ifTrue:[
		self contents: 'x',input.
		^true
	] ifFalse: [ input size = 0 ifTrue:[
		^true
	] ifFalse:[
		^false
	]]]].! !

!EnhancedEntryField methods !
okCurrency

	self contents: (
		self
			okCurrency: self contents
			decimalPlaces: NationalLanguage currencyDigits ).
	^true! !

!EnhancedEntryField methods !   
okBoolean: aChar
    "Answer true if aChar is one of 'TtFfYyNn'."

    ^'TtFfYyNn' includes: aChar! !

!EnhancedEntryField methods ! 
okAlphaNumeric:  aChar
    "Validates whether aChar is a acceptable alpha-numeric character
     ( $A - $Z, $a - $z, $0 - $9, or space)"

    ^aChar isDigit or: [ self okAlpha: aChar ]! !

!EnhancedEntryField methods !  
centered
		"Set the receiver's text centered before the control is opened."
    self justification: #centered.
    self removeStyle: EsRight.
    self addStyle: EsCenter.
	self addStyle: EsMultiline.
    ^self style.! !

!EnhancedEntryField methods !
close
        "Private - Close the receiver."
    self topParent removeAllActionsWithReceiver: self.
    ^super close! !

!EnhancedEntryField methods !  
previousValue: aValue
        "Set the previous value of the receiver.
			Adjust the case first."
	^super previousValue: (self adjustCase: aValue).! !

!EnhancedEntryField methods !
okRound2
    "Answer the input rounded to 2 decimal places"

    self contents: ((Float fromString: self contents) roundTo: 0.01) asString.
    ^true.! !

!EnhancedEntryField methods !
gettingFocus
        "Private - Select all when getting focus."
	self hasFocus
		ifTrue: [
			self gotFocus.
			super gettingFocus ]
		ifFalse: [
			Notifier
				removeFirstCurrentEvent: #losingFocus
				for: self ].! !

!EnhancedEntryField methods ! 
aboutToClose
        "Private - Check field validation before close. "
    (self isReadOnly not
        and: [self value ~= self previousValue])
        ifTrue: [
            self validateField
                ifTrue: [self triggerChanged]
                ifFalse: [
                    self errorMessage
                        ifTrue: [
                            self sendInputEvent: #contents: with: self contents.
                            self contents: self previousValue.
                            self topParent abortClose]]].! !

!EnhancedEntryField methods !  
noAutoTab
	    "Not supported under Windows"
    ^#noAutoTab! !

!EnhancedEntryField methods !
triggerChanged
        "Private - trigger the changed event."
    super triggerChanged.
    self triggerObjectChanged.! !

!EnhancedEntryField methods ! 
field
		"Answer the field validation selector."
    ^field! !

!EnhancedEntryField methods !  
errorMessage
        "Private - Report an error to the user."
    | focusPane |
    [ Notifier isButton1Down | Notifier isButton2Down ] whileTrue: [ ].
    focusPane := Notifier getFocusWindow.
    (MessageBox confirm: 'Invalid Input. Retry?')
        ifTrue: [
            self sendInputEvent: #setFocus.
            self subPaneWithFocus: self.
            ^true ].
    focusPane notNil
        ifTrue: [
            focusPane setFocus ].
    ^false! !

!EnhancedEntryField methods !  
isAutoTab

	^(self propertyAt: #autoTab) == true! !

!EnhancedEntryField methods !
contents: aString
    "Prevent the textChanged message from
     happening when the contents is set and
     fix the case"

    | string |
    string := self adjustCase: aString asString.
    self contents = string ifTrue: [^self].
    super contents: string.
    self removeTextChangedEvent.! !

!EnhancedEntryField methods ! 
autoTabStyle
		"Set the entry field to automatically tab to the next field
			when the maximum number of characters has been entered.
			Currently not supported under Windows."
    ^self! !

!EnhancedEntryField methods !
isOkToChangeTo: newValue

    | answer |
    ((answer := super isOkToChangeTo: newValue)
        and: [(self hasActionForEvent: #changed:) not])
        ifTrue: [self triggerObjectChanged].
    ^answer.! !

!EnhancedEntryField methods !  
okCurrency: aString decimalPlaces: anInteger

	"Answer a valid money figure."

	| answer isNegative isDecimal format symbol count |
	aString isEmpty ifTrue: [ ^aString ].
	isNegative := aString first = $( and: [ aString last = $) ].
	isDecimal := false.
	answer := aString select: [ :each |
		isNegative := isNegative or: [ each = $- ].
		each isDigit or: [
			isDecimal
				ifTrue: [ false ]
				ifFalse: [ isDecimal := each = $. ] ] ].
	answer isEmpty ifTrue: [ ^answer ].
	anInteger > 0
		ifTrue: [
			isDecimal
				ifTrue: [
					count := answer size - (answer indexOf: $.).
					count > anInteger
						ifTrue: [
							"Could do rounding here"
							answer := answer
								copyFrom: 1
								to: answer size - count + anInteger ].
					count < anInteger
						ifTrue: [
							answer := answer, (
								(String new: anInteger - count)
									atAllPut: $0;
									yourself ) ] ]
				ifFalse: [
					answer := answer, '.', (
						(String new: anInteger)
							atAllPut: $0;
							yourself ) ] ]
		ifFalse: [
			isDecimal
				ifTrue: [
					answer := answer
						copyFrom: 1
						to: (answer indexOf: $.) - 1 ] ].
	symbol := NationalLanguage currency.
	isNegative
		ifTrue: [
			format := NationalLanguage negativeCurrencyFormat.
			format = 0 ifTrue: [ answer := '(', symbol, answer, ')' ].
			format = 1 ifTrue: [ answer := '-', symbol, answer ].
			format = 2 ifTrue: [ answer := symbol, '-', answer ].
			format = 3 ifTrue: [ answer := symbol, answer, '-' ].
			format = 4 ifTrue: [ answer := '(', answer, symbol, ')' ].
			format = 5 ifTrue: [ answer := '-', answer, symbol ].
			format = 6 ifTrue: [ answer := answer, '-', symbol ].
			format = 7 ifTrue: [ answer := answer, symbol, '-' ] ]
		ifFalse: [
			format := NationalLanguage currencyFormat.
			format = 0 ifTrue: [ answer := symbol, answer ].
			format = 1 ifTrue: [ answer := answer, symbol ].
			format = 2 ifTrue: [ answer := symbol,' ', answer ].
			format = 3 ifTrue: [ answer := answer, ' ',symbol ] ].
	^answer! !

!EnhancedEntryField class methods !   
characterConversionMap: characterValidationSymbol

    (#(#okInteger: #okPositiveInteger:)
        includes: characterValidationSymbol) ifTrue: [^Integer].
    (#(#ok20Comma10: #ok7Comma2: #ok7Comma4: #okPositive10Comma10:)
        includes: characterValidationSymbol) ifTrue: [^Float].
    (#(#okNumeric: #okPositiveNumeric:)
        includes: characterValidationSymbol) ifTrue: [^Number].
    (#(#okBoolean:)
        includes: characterValidationSymbol) ifTrue: [^Boolean].
    ^nil! !

!EnhancedEntryField methods !
textChanged
        "Private - handle the changing of text contents."
    super textChanged.
    (self hasActionForEvent: #objectChanging:)
        ifTrue: [self triggerEvent: #objectChanging: with: self objectContents]! !

!EnhancedEntryField methods !   
adjustCase: aString
		"Private - Answer aString with the case adjusted."
    self case notNil ifTrue: [
        self case = #UPPER ifTrue: [ ^aString asUpperCase ].
        self case = #lower ifTrue: [ ^aString asLowerCase ].
        self case = #Proper ifTrue: [ ^aString asProperNoun ]
    ].
    ^aString! !

!EnhancedEntryField methods !
getFocus
		"Answer where the cursor should be placed when the field gets focus."
    ^getFocus! !

!EnhancedEntryField methods !  
okRound3
    "Answer the input rounded to 3 decimal places"

    self contents: ((Float fromString: self contents) roundTo: 0.001) asString.
    ^true.! !

!EnhancedEntryField methods !   
okAny: aChar

    ^true! !

!EnhancedEntryField methods ! 
left
		"Set the receiver's text to the left before the control is opened."
    self justification: #left.
    self removeStyle: EsRight.
    self removeStyle: EsCenter.
	self removeStyle: EsMultiline.! !

!EnhancedEntryField class methods !   
fieldConversionMap: fieldValidationSymbol

    (#(#okInteger)
        includes: fieldValidationSymbol) ifTrue: [^Integer].
    (#(#okCurrency #okCurrencyNoDecimal #okRound2 #okRound3)
        includes: fieldValidationSymbol) ifTrue: [^Float].
    (#(#okNumber)
        includes: fieldValidationSymbol) ifTrue: [^Number].
    (#(#okDate)
        includes: fieldValidationSymbol) ifTrue: [^Date].
    ^nil! !

!EnhancedEntryField methods ! 
case
		"Answer the receiver's case (UPPER/lower)."
    ^case! !

!EnhancedEntryField methods !
autoTab
		"Set the entry field to automatically tab to the next field
			when the maximum number of characters has been entered.
			Currently not supported under Windows."
    ^self autoTabStyle! !

!EnhancedEntryField methods !
losingFocus
        "Private - The receiver is losing focus. "
    self isReadOnly | self hasFocus ifFalse: [
        ( self value ~= self previousValue ) ifTrue: [
			self validateField ifFalse: [
				self errorMessage ifTrue: [
					^self ] ] ] ].
	^super losingFocus! !

!EnhancedEntryField methods !  
case: aSymbol
		"Specify any automatic case conversion that should take place
			when the field looses focus. Allowable values are: #UPPER,
			#lower, #Proper, and #Unchanged."
    case := aSymbol.
    case = #UPPER ifTrue: [
		(self respondsTo: #upperCase) ifTrue: [
			self upperCase ] ].
    case = #lower ifTrue: [
		(self respondsTo: #lowerCase) ifTrue: [
			self lowerCase ] ].! !

!EnhancedEntryField methods ! 
right
		"Set the receiver's text to the right before the control is opened."
    self justification: #right.
    self addStyle: EsRight.
	self addStyle: EsMultiline.
    ^self style.! !

!EnhancedEntryField methods !   
okPositiveNumeric: aChar

    "Validates whether aChar is a acceptable character for a
         Number in input string at position pos"
    "Courtesy of Cargill"

    aChar == $-
        ifTrue: [^false].
     ^self okNumeric: aChar! !

!EnhancedEntryField methods !  
ok7Comma4: aChar

    "Validates whether aChar is a acceptable
        character for a Positive Integer"
    "Courtesy of Cargill"

    ^self
            okFixed: aChar
            leading: 7
            trailing: 4! !

!EnhancedEntryField methods !  
selectLast
	    "Place cursor at end of the text."
    self selectFrom: self contents size + 1 to: self contents size! !

!EnhancedEntryField methods !   
okCurrencyNoDecimal

	self contents: (
		self
			okCurrency: self contents
			decimalPlaces: 0 ).
	^true! !

!EnhancedEntryField methods !
okAlphaNoSpace: aChar
    "Validates whether aChar is a acceptable alpha character
     ( $A - $Z, $a - $z)"

    ^aChar isLetter! !

!EnhancedEntryField methods ! 
validateCharacter: char
    "Private - Validate the character by applying char to
     the character validation function. Returns true if the
     character char is accepted. Returns false if not."

    char isNil | (char = Tab) | (char = Bs) ifFalse: [
        (self
            perform: (self character ifNil: [ #okAny: ])
            with: char
        ) ifFalse: [
            (Smalltalk at: #Terminal) bell.
            ^ false ] ].
    ^true! !

!EnhancedEntryField methods !   
triggerAboutToChangeTo: newValue
        "Private - trigger the aboutToChangeTo: event."
	super triggerAboutToChangeTo: newValue.
	self validateField ifFalse: [ self abortChange ].! !

!EnhancedEntryField methods !   
justification: aSymbol
		"Private"
    justification := aSymbol! !

!EnhancedEntryField methods ! 
validateField
    "Private - Validate the input. Answer true if the input is
     acceptable else answer false."
    self field notNil ifTrue: [
        ^self perform: self field
    ] ifFalse: [
        ^true
    ].! !

!EnhancedEntryField methods !   
character
		"Answer the character validation selector."
    ^character! !

!EnhancedEntryField methods !  
okFixed: aChar
leading: leadingInteger
trailing: trailingInteger

    "Private -  is the char valid for the fixed decimal designation"
    "Courtesy of Cargill"

    | aDecimal tmpContents anIndex pos sel |
    tmpContents := self contents.
    pos := self getSelection x.
    sel := self getSelection y - pos.
    aDecimal := tmpContents
        detect:
            [:each |
            each == $.]
        ifNone:
            [aChar = $.
                ifTrue:
                    [nil]
                ifFalse:
                    [tmpContents size = leadingInteger
                        ifTrue: [^false]]].
    aDecimal isNil
        ifFalse:
            [aChar == $.
                ifTrue:
                    [anIndex := tmpContents indexOf: aDecimal.
                    (anIndex between: pos and: self getSelection y)
                        ifTrue: [^true]]].
    (self okNumeric: aChar)
        ifFalse: [^false].
    aDecimal isNil
        ifFalse:
            [sel = -1
                ifTrue:
                    [anIndex := tmpContents indexOf: aDecimal.
                    ((anIndex = (leadingInteger + 1)) & (pos <= anIndex))
                        ifTrue: [^false].
                    (((tmpContents size - anIndex) = trailingInteger) & (pos > anIndex))
                        ifTrue: [^false]]].

    ^true! !

!EnhancedEntryField methods ! 
validate
        "Private - The host window for the receiver was
         just created or recreated."
    super validate.
    self topParent when: #aboutToClose send: #aboutToClose to: self.! !

!EnhancedEntryField methods !
okPositive10Comma10: aChar
    "Validates whether aChar is a acceptable
        character for a Positive Integer"
    "Courtesy of Cargill"

   aChar == $-
        ifTrue: [^false].
    ^self
            okFixed: aChar
            leading: 10
            trailing: 10! !

!EnhancedEntryField methods ! 
okInteger

    "Validates whether aChar is a acceptable character for a
         Integer in input string at position pos"
    "Courtesy of Cargill"

    | answer |
    self contents: (answer :=self contents asInteger printString).
    ^true ! !

!EnhancedEntryField methods ! 
gotFocus
        "Private - Perform get focus operation."
    self perform: self getFocus.! !

!EnhancedEntryField class methods !
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #objectChanging: ;
        add: #objectChanged: ;
        yourself! !

!EnhancedEntryField methods !   
okPhoneNumberUS
    "Answer the input as a formated phone number.
     Format is: (999) 999-9999, 999-9999, x999, (999) 999-9999 x999."
    | input dict |
    dict := self class phoneConversionDict.
    input := (self contents collect: [ :aChar |
        dict at: aChar asUpperCase ifAbsent: [ aChar ]]) select: [ :aChar | aChar isDigit ].
    input size >= 10 ifTrue:[
        self contents:
            '(', (input copyFrom: 1 to: 3),
            ') ', (input copyFrom: 4 to: 6),
            '-', (input copyFrom: 7 to: 10).
        ^true
    ] ifFalse: [ input size >= 7 ifTrue: [
        self contents:
            (input copyFrom: 1 to: 3), '-',
            (input copyFrom: 4 to: 7).
        ^true
    ] ifFalse: [ input size = 0 ifTrue:[
        ^true
    ] ifFalse:[
        ^false
    ]]].! !

!EnhancedEntryField methods !  
initialize
		"Private - Initialize the receiver."
    self
        getFocus: #selectAll;
        left.
    super initialize! !

!EnhancedEntryField methods !  
field: aSymbol
		"Set the field validation selector."
    field := aSymbol! !

!EnhancedEntryField methods !  
okDate
    "Answer true if contents is a valid date else false."
    | aString answer |
    aString := self contents.
    aString size = 0 ifTrue: [^true].
    answer := [Date validateString: aString] on: Error do: [false].
    answer ifTrue: [self contents: (Date fromString: aString) asString].
    ^answer.! !

!EnhancedEntryField methods !  
okInteger: aChar
    "Validates whether aChar is a acceptable character for a
     Integer in input string at position pos"
    | pos |
    pos := self getSelection x.
    ((aChar == $- or: [ aChar == $+ ]) and: [ pos == 1 ]) ifTrue: [ ^true ].
    ^self okPositiveInteger: aChar! !

!EnhancedEntryField methods ! 
wmCharResultFor: aCharacter
        "Private - Answer the value to return to the host operating system
       character input message when aCharacter is being entered."
	^(super wmCharResultFor: aCharacter) ifNil: [
		(self validateCharacter: aCharacter)
			ifTrue: [ nil ]
			ifFalse: [ 1 ] ]! !

!EnhancedEntryField methods !   
okSSN
    "Answer the input as a social security number.
    Format is: 999-99-9999."
    | input answer |
    input := self contents select: [ :aChar | aChar isDigit ].
    (answer := input size = 9) ifTrue:[
        self contents:
            (input copyFrom: 1 to: 3), '-',
            (input copyFrom: 4 to: 5), '-',
            (input copyFrom: 6 to: 9).
    ] ifFalse: [ input size = 0 ifTrue:[
        ^true
    ]].
    ^answer! !

!EnhancedEntryField methods !   
getFocus: aSymbol
		"Specify where the cursor should be placed when the field gets focus.
			Allowable values include: #selectAll, #selectFirst, and #selectLast."
    getFocus := aSymbol! !

!EnhancedEntryField methods ! 
character: aSymbol
		"Set the character validation selector."
    character := aSymbol! !

!EnhancedEntryField methods !  
objectContents

    | objectClass |
    ^((objectClass := self class fieldConversionMap: self field)
        ifNil: [objectClass := self class characterConversionMap: self character]) isNil
        ifTrue: [self contents]
        ifFalse: [[objectClass fromString: self contents] on: Error do: []]! !

!EnhancedEntryField methods !   
okAlpha: aChar
    "Validates whether aChar is a acceptable alpha character
     ( $A - $Z, $a - $z or space)"

    ^aChar isLetter or: [ aChar = $  ]! !

!EnhancedEntryField class methods !  
phoneConversionDict
    "Return a dictionary mapping letters to digit for
     phone numbers"
	#osiHack.
	"Move this to a initializer in Team/V."
    ^Dictionary new
        at: $A put: $2;
        at: $B put: $2;
        at: $C put: $2;
        at: $D put: $3;
        at: $E put: $3;
        at: $F put: $3;
        at: $G put: $4;
        at: $H put: $4;
        at: $I put: $4;
        at: $J put: $5;
        at: $K put: $5;
        at: $L put: $5;
        at: $M put: $6;
        at: $N put: $6;
        at: $O put: $6;
        at: $P put: $7;
        at: $Q put: $7;
        at: $R put: $7;
        at: $S put: $7;
        at: $T put: $8;
        at: $U put: $8;
        at: $V put: $8;
        at: $W put: $9;
        at: $X put: $9;
        at: $Y put: $9;
        at: $Z put: $9;
        yourself.! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!