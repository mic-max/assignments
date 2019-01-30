
"Stub PARTS classes so that
    the Visual Smalltalk PropertyManager (VPROM31.SLL) will bind."!

Smalltalk at: #PARTSApplicationHolder ifAbsent: [
    Object subclass: #PARTSApplicationHolder
      instanceVariableNames: 
        ' application eventTable '
      classVariableNames: 
        ' RecyclingBin '
      poolDictionaries: '' ]!

Smalltalk at: #PARTSCheckBoxPart ifAbsent: [
    CheckBox subclass: #PARTSCheckBoxPart
      instanceVariableNames: ''
      classVariableNames: 
        ' SupportsLabelLeftOfButton '
      poolDictionaries: '' ]!

Smalltalk at: #PARTSCodeGeneratorInterface ifAbsent: [
    Object subclass: #PARTSCodeGeneratorInterface
      instanceVariableNames: 
        ' inputDirectoryName outputDirectoryName logStream fileDescriptor interactive '
      classVariableNames: ''
      poolDictionaries: ''   ]!

Smalltalk at: #PARTSEntryFieldPart ifAbsent: [
    EntryField subclass: #PARTSEntryFieldPart
      instanceVariableNames: 
        ' emptyValue '
      classVariableNames: 
        ' AlignmentLabels AlignmentValues ConvertCharactersLabels ConvertCharactersValues '
      poolDictionaries: ''  ]!

Smalltalk at: #PARTSFormattedEntryField ifAbsent: [
    PARTSEntryFieldPart subclass: #PARTSFormattedEntryField
      instanceVariableNames: 
        ' datum '
      classVariableNames: ''
      poolDictionaries: ''  ]!

Smalltalk at: #PARTSNumericField ifAbsent: [
    PARTSFormattedEntryField subclass: #PARTSNumericField
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''  ]!

Smalltalk at: #PARTSFixedDecimalEntryFieldPart ifAbsent: [
    PARTSNumericField subclass: #PARTSFixedDecimalEntryFieldPart
      instanceVariableNames: 
        ' signed decimalPlace digits '
      classVariableNames: ''
      poolDictionaries: '' ]!

Smalltalk at: #PARTSCurrencyEntryFieldPart ifAbsent: [
    PARTSFixedDecimalEntryFieldPart subclass: #PARTSCurrencyEntryFieldPart
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: '' ]!

Smalltalk at: #PARTSExpressionEntryField ifAbsent: [
    EntryField subclass: #PARTSExpressionEntryField
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''    ]!

Smalltalk at: #PARTSFloatEntryFieldPart ifAbsent: [
    PARTSNumericField subclass: #PARTSFloatEntryFieldPart
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''  ]!

Smalltalk at: #PARTSIntegerEntryFieldPart ifAbsent: [
    PARTSNumericField subclass: #PARTSIntegerEntryFieldPart
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''    ]!

Smalltalk at: #PARTSListPanePart ifAbsent: [
    ListBox subclass: #PARTSListPanePart
      instanceVariableNames: ''
      classVariableNames: 
        ' SupportsShowDisabledScrollbar '
      poolDictionaries: ''    ]!

Smalltalk at: #PARTSPhoneNumberEntryFieldPart ifAbsent: [
    PARTSFormattedEntryField subclass: #PARTSPhoneNumberEntryFieldPart
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: '' ]!

Smalltalk at: #PARTSDialog ifAbsent: [
    WindowDialog subclass: #PARTSDialog
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''    ]!

Smalltalk at: #PARTSTabOrderEditor ifAbsent: [
    PARTSDialog subclass: #PARTSTabOrderEditor
      instanceVariableNames: 
        ' orderedChildren tabStops groupLeaders children answer '
      classVariableNames: ''
      poolDictionaries: ''    ]!

"PARTS methods used by the PropertyManager"!

(Dictionary compiledMethodAt: #keysAsArray) isNil ifTrue: [
    (ClassReader forClass: Dictionary) fileInFrom:
'keysAsArray
        "Answer a collection containing all the keys
         in the receiver."

    | answer |
    answer := OrderedCollection new: self size.
    self associationsDo: [ :assoc |
        answer add: assoc key].
    ^answer' asStream]!

(IdentityDictionary compiledMethodAt: #keysAsArray) isNil ifTrue: [
    (ClassReader forClass: IdentityDictionary) fileInFrom:
'keysAsArray
        "Answer a collection containing all the keys
         in the receiver."

    | answer |
    answer := OrderedCollection new: self size.
    1 to: contents size by: 2 do: [ :index |
        (contents at: index) == nil
            ifFalse: [answer add: (contents at: index)]].
    ^answer' asStream]!
