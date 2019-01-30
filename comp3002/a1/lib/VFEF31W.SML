3.1.0.106
   
formatUSPhoneNumber: input
        "Answer the input as a formatted US phone number.
            Format is: (999) 999-9999 or 999-9999."
    | formattedOutput |
    formattedOutput := input.
    input size = 7
        ifTrue:[
            formattedOutput := (input copyFrom: 1 to: 3) ,
                                        '-', (input copyFrom: 4 to: 7)]
        ifFalse:[
            input size = 10
                ifTrue:[
                    formattedOutput := '(', (input copyFrom: 1 to: 3),
                            ') ', (input copyFrom: 4 to: 6),
                            '-', (input copyFrom: 7 to: 10)]
                ifFalse:[
                    input size = 0
                        ifFalse:[
                            MessageBox message: 'Invalid Phone Number']]].
    ^ formattedOutput! 
validateCurrency: input withChar: ch position: pos
        "Validates whether ch is a acceptable character for a
            dollar currency in input string at position pos.
            Answers true if it is acceptable else false."
    | decimalPos |
    (self validateFloat: input
        withChar: ch
        position: pos)
        ifTrue:[
            decimalPos := input
                indexOf: NationalLanguage decimalSeparator
                ifAbsent: [1 + input size ].
            (pos > (decimalPos + NationalLanguage decimalPlace))
                ifTrue:[ ^ false]]
        ifFalse:[ ^ false].
    ^ true! 
validateInteger: input withChar: ch position: pos
        "Validates whether ch is a acceptable character for a
            Integer in input string at position pos.
            Answers true if it is acceptable else false."
    ((ch = $- or: [ch = $+]) and:[ pos = 1])
       ifTrue:[^true].
    ^self
        validatePositiveInteger: input
        withChar: ch
        position: pos!  
validatePositiveInteger: input withChar: ch position: pos
        "Validates whether ch is a acceptable character for a
            Positive Integer in input string at position pos.
            Answers true if it is acceptable else false."
    ch isDigit
         ifTrue:[^true].
    ^false! 
formatDate: input
        "Answer the input as a formatted date.
         Format is based on the current system date format.
         For example:
            MM(dateSep)DD(dateSep)YY,
            DD(dateSep)MM(dateSep)YY, or
            YY(dateSep)MM(dateSep)DD. "
    | formattedOutput |
    input size = 0 ifTrue: [ ^formattedOutput ].
    formattedOutput := input.
    input size = 6
        ifTrue: [
            formattedOutput := (input copyFrom: 1 to: 2) ,
                NationalLanguage dateSeparator, (input copyFrom: 3 to: 4),
                NationalLanguage dateSeparator, (input copyFrom: 5 to: 6) ].

    "Check date - wrap it with an exception in case there is an error"
    [ Date fromString: formattedOutput ]
        on: Error
        do: [
            MessageBox message: 'Invalid Date.'.
            ^formattedOutput := nil ].

    ^formattedOutput!   
formatFloat: input
        "Answer the input formatted as a Float.
        Format is: (negativeSign)999(thousandSeparator)999(decimalSeparator)99."
    ^input asFloat printString!
formatCurrency: input
        "Answer the input as a formatted currency.
         Format is: (Currency)999(thousandSep)999(thousandSep)99"
    | formattedOutput pos bNeg decimalSeparator
    currency minusCurrency|
    decimalSeparator := NationalLanguage decimalSeparator first.
    currency := NationalLanguage currency , ' '.
    minusCurrency := '- ', currency.
    input class = String ifFalse:[^ String new].

    "Round digits beyond NationalLanguage decimalPlace."
    formattedOutput := (input asFloat
        roundTo: (0.1 raisedTo: NationalLanguage decimalPlace)) printString.
    (formattedOutput at: 1) = $- 
        ifTrue:[
            bNeg := true.
            formattedOutput := 
                formattedOutput copyFrom: 2 to: formattedOutput size]
    ifFalse:[ bNeg := false ].

    "Insert thousandSeparators."
    pos := (formattedOutput findLast:[:ch| ch = decimalSeparator]) - 3.
    pos > 1 ifTrue:[
        pos to: 2 by: -3 do:[:i|
            formattedOutput := (formattedOutput copyFrom: 1 to: i - 1),
                 NationalLanguage thousandsSeparator,
                 (formattedOutput copyFrom: i  to: formattedOutput size)]].

    "Prepend the currency and possible minus sign."
    formattedOutput := bNeg 
        ifTrue:[ minusCurrency, formattedOutput ]
        ifFalse:[ currency, formattedOutput ].

    "Add up to NationalLanguage decimalPlace extra 0's
    to the right of the decimalSeparator if necessary."
    [(formattedOutput findLast: [:ch| ch = decimalSeparator ])
        > (formattedOutput size - NationalLanguage decimalPlace)] 
      whileTrue:[ formattedOutput := formattedOutput, '0' ].

    "...or remove the extra 0 always inserted by aFloat printString."
    NationalLanguage decimalPlace = 0
        ifTrue: [ formattedOutput :=
            formattedOutput copyFrom: 1 to: (formattedOutput size - 2) ].
    ^ formattedOutput!   
validateAlpha: input withChar: ch position: pos
        "Validates whether ch is a acceptable alpha character
            ( $A - $Z, $a - $z or space) in input string at position pos.  
            Answers true if it is acceptable else false."
    ^( ch isLetter or: [ ch asciiValue = SpaceKey] )! 
validateFloat: input withChar: ch position: pos
        "Validates whether ch is a acceptable character for a
            Float in input string at position pos.
            Answers true if it is acceptable else false."
    | decimalSeparator |
    decimalSeparator := NationalLanguage decimalSeparator first.
    (ch = decimalSeparator
         and: [(input includes: decimalSeparator) not] )
        ifTrue:[ ^ true].
    ^self
        validateInteger: input
        withChar: ch
        position: pos!   
acceptBlock: aBlock
        "Set accept block to aBlock.  When FormattedStaticText
            gets a new value, aBlock is evaluated with the new
            value as the argument.  If the new value is accepted,
            aBlock should return the new value as formatted output.
            If the new value is not accepted, aBlock should inform
            the user of the problem and just return the new value."

    acceptBlock := aBlock.!   
formatAsCurrency
        "Sets the FormattedStaticText to format 
         its contents as currency."
    self acceptBlock:[ :input |
        FormattedEntryField formatCurrency: input ].!   
formatOutput: newValue
        "Private - Answers the formatted output of newValue."
    formattedOutput := newValue.
    acceptBlock notNil
        ifTrue: [formattedOutput := acceptBlock value: newValue].
    ^ formattedOutput!
formatAsUSPhoneNumber
        "Sets the FormattedStaticText to format 
         its contents as US phone number."
    self acceptBlock:[ :input |
        FormattedEntryField formatUSPhoneNumber: input ].!  
formatAsDate
        "Sets the FormattedStaticText to 
         format its contents as date."
    self acceptBlock:[ :input |
        FormattedEntryField formatDate: input].!
contents: newValue
        "Set the String associated with this control."
    |aOutput|
    aOutput := self formatOutput: newValue.
    super contents: aOutput.

    "Must reset the value with newValue
      Because value was set with aOutput in superClass"
    label := newValue.! 
formatAsDollar
        "Sets the FormattedStaticText to format 
         its contents as dollar currency."
    self acceptBlock:[ :input |
        FormattedEntryField formatCurrency: input ].!  
formattedOutput
        "Answers formatted output string of the FormattedStaticText."
    formattedOutput notNil
        ifTrue:[ ^ formattedOutput ].
    ^ label!   
contents: input
        "Set the String associated with this control."
    | anOutput |
    anOutput := self formatOutput: input.
    unformattedValue := anOutput isNil
        ifTrue: [ String new ]
        ifFalse: [ input ].
    super contents: anOutput!  
wmChar: wParam with: lParam
        "Private - Only allow valid characters to get through."
    ( self validateCharacter: wParam asCharacter ) ifTrue: [
        unformattedValue := self windowText.
        ^nil ].
    ^false!
acceptAlpha
        "Sets the FormattedEntryField to only accept alpha
            characters (A - Z, a- z)."

    self strokeBlock: [ :ch |
        self class validateAlpha: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock: nil.
    self setTextLimit: self defaultTextLimit!
acceptBlock: aBlock
        "Set accept block to aBlock.  When FormattedEntryField
            get a new value, aBlock is evaluated with the new
            value as the argument.  If the new value is accepted,
            aBlock should return the new value as formatted output.
            If the new value is not accepted, aBlock should inform
            the user of the problem and just return the new value."

    acceptBlock := aBlock.!
acceptDate
        "Sets the FormattedEntryField to only accept date.
            (6 digit positive integer.)
            The entered value will be shown in date format."

    self strokeBlock: [ :ch |
        self class validatePositiveInteger: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock:[ :input |
        self class formatDate: input ].
    self setTextLimit: 6.! 
acceptUSPhoneNumber
        "Sets the FormattedEntryField to only accept US phone number.
           (either a 7 or 10 digit number.)
            The entered value will be shown in phone number format. "

    self strokeBlock: [ :ch |
        self class validatePositiveInteger: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock:[ :input |
        self class formatUSPhoneNumber: input ].
    self setTextLimit: 10.!  
acceptInteger
        "Sets the FormattedEntryField to only accept integer."

    self strokeBlock: [ :ch |
        self class validateInteger: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock: nil.
    self setTextLimit: self defaultTextLimit!
formatOutput: input
        "Private - Answers the formatted output of input."
    formattedOutput := input.
    acceptBlock notNil
        ifTrue: [formattedOutput := acceptBlock value: input].
    ^formattedOutput! 
validateCharacter: char
        "Private - Validate the character by applying char to
            acceptBlock.
            Returns true if the character char is accepted.
            Returns false if not."

    (char asciiValue =  BackspaceKey)
        ifTrue:[ ^ true].
    strokeBlock notNil
        ifTrue: [(strokeBlock value: char)
                ifTrue:[ ^ true]
                ifFalse:[
                    Terminal bell.
                    ^ false]]
        ifFalse:[ ^true]!  
acceptFloat
        "Sets the FormattedEntryField to only accept floating point
            number."

    self strokeBlock: [ :ch |
        self class validateFloat: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock: [ :input | self class formatFloat: input ].
    self setTextLimit: self defaultTextLimit!  
acceptPositiveInteger
        "Sets the FormattedEntryField to only accept positive integer."

    self strokeBlock: [ :ch |
        self class validatePositiveInteger: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock: nil.
    self setTextLimit: self defaultTextLimit!   
contents
        "Answer a string containing the text of the item."
         "Note: Don't want to get string from entry field
         because it might contain formatted output."
    ^unformattedValue notNil
        ifTrue: [ unformattedValue ]
        ifFalse: [ String new ]!   
textChanged
        "Private - handle the changing of text contents."
    super textChanged.
    self windowText ~= formattedOutput
        ifTrue: [
            self windowText do: [ :c |
                ( self validateCharacter: c )
                    ifFalse: [ ^self contents: self contents ] ] ]! 
value
        "Answer the (formatted) value of the receiver."
    ^self windowText! 
strokeBlock: aBlock
        "Set stroke block to aBlock.  For each key stroke entered,
            aBlock is evaluated with a Character as the argument.
            If the character is accepted aBlock should return true,
            other wise it should return false."
    strokeBlock := aBlock.! 
losingFocus
        "Private - Set the field with formatted output."
    super losingFocus.
    self contents: self windowText.!   
formattedOutput
        "Answers formatted output string of the FormattedEntryField."

    formattedOutput notNil
        ifTrue:[ ^ formattedOutput].
    ^ unformattedValue.!  
acceptCurrency
        "Sets the FormattedEntryField to only accept currency.
            (a floating point number with two decimal places.)
            The entered value will be shown in currency format."

    self strokeBlock: [ :ch |
        self class validateCurrency: self windowText
            withChar: ch
            position: self getSelection x ].
    self acceptBlock:[ :input |
        self class formatCurrency: input ].
    self setTextLimit: self defaultTextLimit!  
gettingFocus
        "Private - Set the field with input string instead of
        formatted output."
    super gettingFocus.
    self windowText ~= unformattedValue ifTrue:[
        super contents: unformattedValue ].
    self selectFrom: 1 to: unformattedValue basicSize!