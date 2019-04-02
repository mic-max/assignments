3.1.0.106
   
partPropertyAddTitleTextItems: propertyStructure
        " Private "
    propertyStructure
        putProperty: ( PARTSPropertyString new
            value: self title;
            label: 'Title:';
            changeSelector: #title: );
        putProperty: ( PARTSPropertyString new
            value: self text;
            label: 'Text:';
            changeSelector: #text: );
        yourself.! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | properties |
    ^( properties := PARTSPropertyStructure on: self )
        when: #editDone
            send: #partPropertyEditDone: to: self with: properties;
        at: #class putProperty: self partPropertyClass;
        at: #valueEntryField putProperty: self partPropertyValueNew;
        at: #value putProperty: self partPropertyEditValue;
        at: #valueStatic putProperty: ( PARTSPropertyStaticText new
            label: 'Value:  ', value printString );
        putProperty: ( PARTSPropertyBoolean new
            value: showKeys;
            label: 'Support element messages and events';
            changeSelector: #showKeys: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: self partPropertyClass;
        putProperty: self partPropertyValueNew;
        putProperty: #( #interface )!
partPropertyValidateDelimiters: aButtonGroup
        " Private "
    (aButtonGroup newValue = self currentDelimiters)
        "ifTrue: [ shouldn't get called in this case ] "
        ifFalse: [
            aButtonGroup propertyStructure partContext
                at: 'applyChanges' put: true].
    ^true! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Information Dialog'!
partObjectMessages: selectorsToIgnore
        " Compute the Object-level PARTS message interface
        of the receiver.   There are never any, because
        they can never get past me to the contained value.
        Answer an assoc whose key is the selectors
        and whose value says whether selectors can
        be cached. "
    ^Association key: Array new value: true!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Conversion'!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel addSelectorIfNotNil: #pattern: with: self pattern! 
partDoit: aMethod withArguments: anArray
        "Answer the result of executing aMethod."
    ^self value partDoit: aMethod withArguments: anArray!
partPropertyApplyEdit: aPropertyStructure
        " Private - apply cached changes and check
        for obsolete links. "
    | newDelimiters newTemplate |

    newDelimiters := stringTemplate at: 2.
    newTemplate := stringTemplate at: 3.
    stringTemplate := stringTemplate at: 1.
    (aPropertyStructure partContext at: 'applyChanges')
        ifFalse: [^self].  " no changes "

    "oldParameterMessages := self partMessagesParameters items."
    newDelimiters notNil
        ifTrue: [
            stringTemplate
                startMarker: (String with: newDelimiters first);
                endMarker: (String with: newDelimiters last)].
    stringTemplate template: (newTemplate notNil
        ifTrue: [newTemplate]
        ifFalse: [stringTemplate template]).

    "First attempt:
    (Message new
        receiver: self lafLinkEditor
        selector: #findObsoleteLinksOn:oldEvents:oldMessages:newEvents:newMessages:
        arguments: (OrderedCollection new
            add: self;
            add: #(); add: oldParameterMessages;
            add: #(); add: self partMessagesParameters items;
            yourself) asArray
        ) performDeferred
    "
    (Message new
        receiver: self partEditor
        selector: #validateLinksAttachedTo:
        arguments: (Array with: self))
            performDeferred!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Launch Pad'!
setIconError
        "Configure the reciever to have an error icon."
    self style: MbIconError!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #propertyClass: with: class;
        addSelectorIfNotNil: #propertyValue: with: value!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Printer'!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Computation'!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | propertyStructure |
    propertyStructure := PARTSPropertyStructure on: self.
    propertyStructure
        putProperty: ( PARTSPropertyString new
            value: self pattern;
            label: 'Default pattern:';
            changeSelector: #pattern: );
        yourself.
    self partPropertyAddSuspendItem: propertyStructure.
    propertyStructure
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface ).
    ^propertyStructure!   
partPropertyValueNew
        " Private - answer the properties vector entry
        for the current value. "
    ^PARTSPropertyString new
        value: value;
        label: 'Value:';
        changeSelector: #propertyValue:!   
partPropertyAddStyleItems: propertyStructure
        " Private - add the button style items to propertyStructure. "
    propertyStructure
        putProperty: ( PARTSPropertyButtonGroup new
            label: 'Button labels';
            changeSelector: #style: ;
            labelsMap: ButtonLabelLabels;
            initialSelection: (self partPropertiesIndexOf: ButtonLabelValues) );
        yourself!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Dictionary Holder'! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system.  Answer the upgraded part.
        PW/OS2 2.0 OrderedCollectionHolder has to be mutated 
        into the new part class of PW 3.0. "

    | upgradedPart |

    self
        partsIfOS2Do: [   " Upgrade PWO 2.0 PremadeDiag parts "
            class == OrderedCollection
                ifTrue: [
                    upgradedPart := PARTSOrderedCollectionHolderPart new.
                    upgradedPart partWrapper: wrapper.
                    wrapper object: upgradedPart.
                    "self ASSERT: upgradedPart propertyClass == class."
                    upgradedPart propertyValue: value.                    
                    ^upgradedPart ].
            ].! 
partPropertyValueNew
        " Private - answer the properties vector entry
        for the current value. "
    ^PARTSPropertyExpression new
        value: '';
        label: 'New value:';
        validationMessage: #partPropertyValidateNewValue: ;
        yourself!
propertySetTemplate: aString
        " Private - set the template string. "
    stringTemplate at: 3 put: aString.  " stash for apply edit "!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setCommand: with: commandString!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Link Junction'! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    ( self hasStyle: MbOkCancel )
        ifTrue: [ ^anExpressionModel addSelector: #setChoicesOkCancel ].
    ( self hasStyle: MbRetryCancel )
        ifTrue: [ ^anExpressionModel addSelector: #setChoicesRetryCancel ].
    ( self hasStyle: MbYesNo )
        ifTrue: [ ^anExpressionModel addSelector: #setChoicesYesNo ].!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Confirmer With Cancel Part'!
partPropertyValueNew
        " Private - answer the properties vector entry
        for the current value. "
    ^PARTSPropertyString new
        label: 'Value:';
        value: value asString;
        changeSelector: #propertyValue:!  
partPropertyValidateNewValue: newValueProperty
        " Private "
    | newValue |
    newValueProperty modified
        ifFalse: [^true].
    newValue := newValueProperty value.
    newValue isPARTSException
        ifTrue: [^false].  " compilation error "
    self
        partPropertyUpdateValue: (newValueProperty propertyStructure propertyAt: #value)
        to: newValue.
    ^true!  
partPropertyAboutToEdit: aPropertyStructure
        " Private - prepare to cache changes for deferred
        link checking "
    stringTemplate := Array with: stringTemplate with: nil with: nil.!   
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        at: #printerName putProperty: ( PARTSPropertyFixedList new
            list: Printer printerNames;
            value: self printerName;
            label: 'Printer name';
            changeSelector: #setPrinterName: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface #setFont )!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'String Holder'! 
iconEditorClass
		"Answer the icon editor to use for the receiver. "

	^self partEditor textIconEditorClass!   
setIconInformation
        "Configure the reciever to have an information icon."
    self style: MbIconInformation! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    ( self hasStyle: MbIconError )
        ifTrue: [ ^anExpressionModel addSelector: #setIconError ].
    ( self hasStyle: MbIconInformation )
        ifTrue: [ ^anExpressionModel addSelector: #setIconInformation ].
    ( self hasStyle: MbNoIcon )
        ifTrue: [ ^anExpressionModel addSelector: #setIconNone ].
    ( self hasStyle: MbIconWarning )
        ifTrue: [ ^anExpressionModel addSelector: #setIconWarning ]!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Clipboard Accessor'!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Prompter'!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Collection Holder'! 
partHasOtherMessages
        " Answer whether the receiver can be asked
        for messages other than what it has already
        provided in its partMessages. A ValueHolder
        does not yet support Other messages because we
        do not have the UI support available to differentiate
        between the protocols of the holder and the value, 
        both of which are potentially of interest. "

    ^false!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyNumber new
            label: 'Interval in milliseconds:';
            value: self interval;
            changeSelector: #interval: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #drivePathName: with: self drivePathName;
        addSelectorIfNotNil: #pattern: with: pattern! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | propertyStructure |
    propertyStructure := PARTSPropertyStructure on: self.
    self
        partPropertyAddTitleTextItems: propertyStructure;
        partPropertyAddStyleItems: propertyStructure;
        partPropertyAddSuspendItem: propertyStructure.
    propertyStructure
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface ).
    ^propertyStructure!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyString new
            value: commandString;
            label: 'Command:';
            changeSelector: #setCommand: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'File Accessor'! 
partPropertyValidateNewValue: newValueProperty
        " Private "
    | newValue |
    newValueProperty modified
        ifFalse: [^true].
    newValue := newValueProperty value.
    newValue isPARTSException
        ifTrue: [^false].  " compilation error "
    newValue isNil
        ifTrue: [^true].  " probably empty, so just ignore in a typed value holder "
    newValue class == class
        ifFalse: [
            MessageBox
                notify: 'ValueHolder Problem'
                withText: 'Cannot accept new value (class ',
                    class name, ' is required, but value is ',
                    newValue class name, ').'.
            ^false ].
    self
        partPropertyUpdateValue: (newValueProperty propertyStructure propertyAt: #value)
        to: newValue.
    ^true!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system.  Answer the upgraded part.
        PW/OS2 2.0 parts have to be mutated into the new
        architecture of PW 3.0. "

    | pwo20ClassNames pwo30ClassNames partClass upgradedPart |

	'LAF/VPM 2.0a'  = anObjectFiler clientContext fileVersion 
		ifTrue: [   " Upgrade PWO 2.0 PremadeDiag parts "
            pwo20ClassNames := #(
                #PARTSUpgradeFileDialog
                " message boxes "
                    #PARTSUpgradeConfirmerDialog
                    #PARTSUpgradeConfirmerWithCancelDialog
                    #PARTSUpgradeInfoDialog
                #PARTSUpgradePrompter
                ).
            pwo30ClassNames := #(
                #PARTSFileDialogPart
                " message box parts "
                    #PARTSConfirmerPart
                    #PARTSConfirmerWithCancelPart
                    #PARTSInformationDialogPart
                #PARTSPrompterPart
                ).
            partClass := Smalltalk at:
               ( pwo30ClassNames at:
                   ( pwo20ClassNames indexOf: diagBox class symbol ) ).
            upgradedPart := partClass forPWO20Dialog: diagBox.
            upgradedPart partWrapper: wrapper.
            wrapper object: upgradedPart.
            " transfer the suspendClient value and then validate its setting "
            upgradedPart suspendClientAttribute:
                ( diagBox propertyAt: #suspendClient
                    ifAbsent: [ false ] ).
            upgradedPart fileInValidateSuspendClient: anObjectFiler.
            anObjectFiler registerUpgradeMutationFrom: diagBox 
                to: upgradedPart dialogBoxAttribute.
            ^upgradedPart ].! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Array Holder'!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Timer'! 
partPropertyValidateThreshold: aStringProperty
        " Private - answer whether the threshold is ok. "
    | newThreshold |
    newThreshold := aStringProperty value.
    ^(newThreshold notNil and: [newThreshold < 1])
        ifTrue: [
            MessageBox
                notify: 'Properties Problem'
                withText: 'The partial read threshold must be a positive integer value.'.
                false]
        ifFalse: [true]! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        at: #class putProperty: self partPropertyClass;
        at: #valueEntryField putProperty: self partPropertyValueNew;
        at: #value putProperty: self partPropertyEditValue;
        at: #valueStatic putProperty: ( PARTSPropertyStaticText new
            label: 'Value:  ', value printString );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!
partPropertyEditValue: editButtonProperty
        " Private "
    | newValueProperty newValue |

    newValueProperty := editButtonProperty propertyStructure propertyAt: #valueEntryField
        ifAbsent: [nil].
    ( newValueProperty notNil and: [newValueProperty modified] )
        ifTrue: [
            (self partPropertyValidateNewValue: newValueProperty)
                ifFalse: [^nil].   " problem in new value "
            " edit button value updated with the new value "
            newValueProperty
                contents: String new;
                setModified: false.
            ].

    newValue := editButtonProperty newValue partEditValue.
    newValue isPARTSException
        ifTrue: [^self].
    self partPropertyUpdateValue: editButtonProperty to: newValue.! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel addSelectorIfNotNil: #setSizeThreshold: with: sizeThreshold!   
propertySetDelimiters: aString
        " Private - update the parameter delimiters "
    stringTemplate at: 2 put: aString.  " stash for apply edit "!  
partPropertyValidateTemplate: aTextProperty
        " Private - answer whether the new value of
        aTextProperty can be accepted as the template. "
    | delimiters |
    aTextProperty propertyStructure partContext
        at: 'applyChanges' put: true.
    delimiters := self partPropertyDelimiters: aTextProperty propertyStructure.
    ^self
        isValidTemplate: aTextProperty contents
        startMarker: (String with: delimiters first)
        endMarker: (String with: delimiters last)! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #showKeys: with: showKeys!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Number Holder'! 
setIconWarning
        "Configure the reciever to have an warning icon."
    self style: MbIconWarning! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    ( self hasStyle: MbYesNoCancel )
        ifTrue: [ ^anExpressionModel addSelector: #setChoicesYesNoCancel ].
    ( self hasStyle: MbAbortRetryIgnore )
        ifTrue: [ ^anExpressionModel addSelector: #setChoicesAbortRetryIgnore ]!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'File Dialog'!   
partPropertiesIndexOf: anArray
        "Private - Answer the index of the element in anArray
        of style constants which is set in the receiver. "
    | sortedArray |
    sortedArray := anArray asSortedCollection: [ :a :b | a >= b].
    ^anArray indexOf:
        (sortedArray
            detect: [ :aStyle | self hasStyle: aStyle]
            ifNone: [^1])!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'String Template'!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Speaker'!   
partPropertyUpdateValue: editButtonProperty to: newValue
        " Private - record a new value from either the
        entry field or the edit button. "
    editButtonProperty newValue: newValue.
    (editButtonProperty propertyStructure propertyAt: #valueStatic ifAbsent: [^nil])
        label: 'Value:  ', newValue printString.!  
iconEditorClass
		"Answer the icon editor to use for the receiver. "

	^self partEditor textIconEditorClassNumeric!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: self partPropertyClass;
        putProperty: self partPropertyValueNew;
        putProperty:  #( #interface )!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Value Holder'!  
partPropertyAddStyleItems: propertyStructure
        " Private - add the button style items to propertyStructure. "
    propertyStructure
        putProperty: ( PARTSPropertyButtonGroup new
            label: 'Icon type';
            changeSelector: #style: ;
            labelsMap: IconTypeLabels;
            initialSelection: (self partPropertiesIndexOf: IconTypeValues) );
        yourself!
partPropertyClass
        " Private - answer the property structure entry
        for the class. "
    ^PARTSPropertyStaticText new
        label: 'Class name: ', class name;
        newValue: class;
        setModified: false;
        yourself!  
partPropertyValidateClass: classProperty
        " Private "
    | newClass |
    newClass := classProperty value.
    newClass isPARTSException
        ifTrue: [
            "self ASSERT: false."  "Shouldn't get this far"
            ^false]. " compilation error "
    ( newClass isNil or: [newClass isClass] )
        ifFalse: [
            MessageBox
                notify: 'ValueHolder Problem'
                withText: 'Cannot accept ', newClass printString,
                    ', it must be a class.'.
            ^false ].
    " class changed - force value to do consistency checking "
    (classProperty propertyStructure propertyAt: #value)
        setModified: true.
    ^true!  
setIconNone
        "Configure the reciever to have no icon."
    self style: MbNoIcon! 
partPropertyDelimiters: aPropertyStructure
        " Private - answer the current delimiter string
        from the property dialog. "
    | delimiters |
    delimiters := (aPropertyStructure propertyAt: #delimiters)
        newValue.
    delimiters isNil
        ifTrue: [delimiters := self currentDelimiters].
    ^delimiters!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelector: #connection: with: connection.
    rectangle notNil
        ifTrue: [
            anExpressionModel addSelector: #origin: with: rectangle leftTop ]!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | propertyStructure |
    propertyStructure := PARTSPropertyStructure on: self.
    propertyStructure
        putProperty: ( PARTSPropertyString new
            value: self promptMessage;
            label: 'Prompt:';
            changeSelector: #promptMessage: );
        putProperty: ( PARTSPropertyString new
            value: self defaultMessage;
            label: 'Default:';
            changeSelector: #defaultMessage: );
        putProperty: ( PARTSPropertyBoolean new
            value: self removeBlanks;
            label: 'Remove leading and trailing blanks';
            changeSelector: #removeBlanks: ).
    self partPropertyAddSuspendItem: propertyStructure.
    propertyStructure
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface ).
    ^propertyStructure!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #stringTemplate: with: stringTemplate!   
partPropertyEditDone: aPropertyStructure
        " Private - property changes applied "
    (Message new
        receiver: self partEditor
        selector: #validateLinksAttachedTo:
        arguments: (Array with: self))
            performDeferred.! 
partPropertySelectFont: aPropertyUnit
    " Private - Bring up the FontDialog and set the font of the receiver. "

    | aFontDialog oldFont selectedFont partProperties |
   self printer.  " get one there isn't one yet "
    oldFont := self font.
   aFontDialog := FontDialog new
        sampleFont: oldFont;
        open.

    selectedFont := ( aFontDialog chosen ).
    selectedFont isNil
         ifTrue: [selectedFont:= oldFont].

    partProperties := aPropertyUnit propertyStructure.
    partProperties
        addAction: (Message new
            receiver: self;
            selector: #font: ;
            arguments: (Array with: selectedFont))
        undo: (Message new
            receiver: self;
            selector: #font: ;
            arguments: (Array with: oldFont)).!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setText: with: self text;
        addSelectorIfNotNil: #setTitle: with: self title!
partOtherMessages: selectorsToIgnore
        " Compute the secondary PARTS message interface
        of the receiver as a sorted collection of public
        messages to which the receiver can respond.
        The messages in selectorsToIgnore should
        not be included in the answer; this set is
        updated to add the answered selectors.
        Answer an assoc whose key is the selectors
        and whose value says whether selectors can
        be cached. "
    | aClass |
    (class isNil or: [class == Object])
        ifTrue: [  " nothing can be decided if type not specified "
            ^Association key: Array new value: false].
    " exclude any message I implement (can't be relayed to value) "
    aClass := self class.
    [aClass == nil] whileFalse: [
        selectorsToIgnore addAll: aClass methodDictionary keys.
        aClass := aClass superclass].
    wrapper notNil
        ifTrue: [selectorsToIgnore addAll: wrapper scriptNames].
    " answer what's left as reachable messages of contained value "
    ^Association
        key: (class basicNew partOtherMessages: selectorsToIgnore) key
        value: false  " do not cache, this answer can change "!   
partPropertyEditValue
        " Private - answer the property structure entry
        for the edit value button. "
    ^PARTSPropertyEditButton new
        label: 'Edit value...';
        value: self propertyValue;
        clickedSelector: #partPropertyEditValue: ;
        validationMessage: #partPropertyValidateValue: ;
        changeSelector: #propertyValue: ;
        yourself!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyString new
            value: pattern;
            label: 'Pattern:';
            changeSelector: #pattern: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!   
partPropertyValidateValue: anEditButtonProperty
        " Private "
    | newClass newValue |

    newClass := (anEditButtonProperty propertyStructure propertyAt: #class)
        value.
    newValue := anEditButtonProperty newValue.

    ( newClass isNil  " any value is OK if class not specified "
    or: [newValue isNil  " nil value is OK for any class "
    or: [newValue isKindOf: newClass] ] )
        ifFalse: [
            MessageBox
                notify: 'ValueHolder Problem'
                withText:
                    'Cannot accept new value (class ',
                    newClass name, ' is required, but value is ',
                    newValue class name, ').'.
            ^false ].
    ^true! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Classed Value Holder'!  
partPropertyAddStyleItems: propertyStructure
        " Private - add the button style items to propertyStructure. "
    propertyStructure
        putProperty: ( PARTSPropertyButtonGroup new
            label: 'Button labels';
            changeSelector: #style: ;
            labelsMap: ButtonLabelLabels;
            initialSelection: (self partPropertiesIndexOf: ButtonLabelValues) );
        yourself!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Comparison'!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Confirmer'! 
partPropertyInsertReference: aButtonProperty
        " Private "
    | propertyStructure delimiters newReference |
    propertyStructure := aButtonProperty propertyStructure.
    delimiters := self partPropertyDelimiters: propertyStructure.
    newReference :=
        (String with: delimiters first),
        ' parameter ',
        (String with: delimiters last).
    (propertyStructure propertyAt: #templateField) textEntryItem
        insertAndSelect: newReference;
        setFocus.!
partPropertyValidateName: aStringProperty
        " Private - answer whether new name is valid. "
    | newPrinterName |
    newPrinterName := aStringProperty contents.
    ( Printer isValidName: newPrinterName )
        ifTrue: [ ^true ]
        ifFalse: [
            MessageBox warning:
                newPrinterName, ' is not a known printer name.'.
            ^false ]! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyNumber new
            label: 'Frequency:';
            value: frequency;
            changeSelector: #setFrequency: );
        putProperty: ( PARTSPropertyNumber new
            label: 'Duration:';
            value: duration;
            changeSelector: #setDuration: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Disk Accessor'! 
partPropertyClass
        " Private - answer the property structure entry
        for the class. "
    ^PARTSPropertyExpression new
        value: (class isNil
            ifTrue: [nil]
            ifFalse: [class name]);
        label: 'Class:';
        validationMessage: #partPropertyValidateClass: ;
        changeSelector: #propertyClass: ;
        yourself! 
partHasObjectMessages
        " Answer whether the receiver can be asked
        for messages it has inherited from Object
        other than what it has already provided
        in its partMessages. "
    ^false!
partPropertyAddStyleItems: propertyStructure
        " Private - default is to do nothing.  Reimplemented. "!
partPropertyAddSuspendItem: propertyStructure
        " Private "
    | suspendClientProperty |
    propertyStructure
        putProperty: ( suspendClientProperty := PARTSPropertyBoolean new
            value: self suspendClient;
            label: 'Wait for answer';
            changeSelector: #suspendClient: ).
    self class supportsNonSuspendedInvocation not
        ifTrue: [ suspendClientProperty disable ].! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | properties |
    ( properties := PARTSPropertyStructure on: self )
        when: #aboutToEdit
            send: #partPropertyAboutToEdit: to: self with: properties;
        when: #editDone
            send: #partPropertyApplyEdit: to: self with: properties.
    properties partContext at: 'applyChanges' put: false.
            " validation routines set this if changes need to be made "
    ^properties
        at: #delimiters putProperty: ( PARTSPropertyButtonGroup new
            label: 'Parameter markers';
            labelsMap: #(
                #('[ parameter ]' '[ ]' )
                #('{ parameter }' '{ }' )
                #('( parameter )' '( )' )
                #('< parameter >' '< >' ) );
            initialSelection:
                ( #( '[ ]' '{ }' '( )' '< >' ) indexOf: self currentDelimiters);
            validationMessage: #partPropertyValidateDelimiters: ;
            changeSelector: #propertySetDelimiters: );
        putProperty: ( PARTSPropertyButton new
            label: 'Insert parameter reference';
            clickedSelector: #partPropertyInsertReference: ;
            makeSameLine );
        at: #templateField putProperty: ( PARTSPropertyText new
            textExtent: 45 @ 6;
            label: 'Template:';
            value: self template;
            validationMessage: #partPropertyValidateTemplate: ;
            changeSelector: #propertySetTemplate: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setFrequency: with: frequency;
        addSelectorIfNotNil: #setDuration: with: duration!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        at: #thresholdEntryField putProperty: ( PARTSPropertyNumber new
            value: sizeThreshold;
            label: 'Partial read threshold (bytes):' ;
            validationMessage: #partPropertyValidateThreshold: ;
            changeSelector: #setSizeThreshold: );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #interval: with: interval!