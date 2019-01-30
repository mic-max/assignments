3.1.0.106
   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Vertical Scroll Bar'!   
partPropertyValidate: aPropertyStructure
        " Private - finish validating the properties. "
    | newMin newMax newInit |

    newMin := (aPropertyStructure propertyAt: #minimum) value.
    newMin isNil
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The minimum value must be a numeric value.'.
            ^aPropertyStructure propertiesValid: false ].
    newMax := (aPropertyStructure propertyAt: #maximum) value.
    newMax isNil
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The maximum value must be a numeric value.'.
            ^aPropertyStructure propertiesValid: false ].
    newInit := (aPropertyStructure propertyAt: #initialValue) value.
    newInit isNil
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The initial value must be a numeric value.'.
            ^aPropertyStructure propertiesValid: false ].

    newMin > newMax
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The minimum value must be less than the maximum value.'.
            ^aPropertyStructure propertiesValid: false ].
    ( newInit < newMin or: [newInit > newMax] )
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The initial value must between the minimum and the maximum values.'.
            ^aPropertyStructure propertiesValid: false ].!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #vertical!   
partPropertySelectBackColor: aPropertyUnit
    " Private - Bring up the ColorDialog and set backColor of the receiver. "

    | oldColor selectedColor partProperties |

    oldColor := self backColor  .
   selectedColor := ColorDialog new
        openOn: oldColor;
		chosen.

	selectedColor notNil
		ifTrue: [ " new color "
    		partProperties := aPropertyUnit propertyStructure.
    		partProperties
        		addAction: (Message new
            		receiver: self;
            		selector: #backColor:;
            		arguments: (Array with: selectedColor))
        		undo: (Message new
            		receiver: self;
            		selector: #backColor: ;
            		arguments: (Array with: oldColor))]
		ifFalse: [ ^self  ]. " Canceled or same color "!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        when: #aboutToAcceptChanges:
            send: #partPropertyValidate: to: self;
        at: #initialValue putProperty: ( PARTSPropertyNumber new
            label: 'Initial value:';
            value: self value;
            changeSelector: #value: );
        at: #minimum putProperty: ( PARTSPropertyNumber new
            label: 'Minimum:';
            value: self minimum;
            changeSelector: #minimum: );
        at: #maximum putProperty: ( PARTSPropertyNumber new
            label: 'Maximum:';
            value: self maximum;
            changeSelector: #maximum: );
        putProperty: #( #setBackColor );
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #horizontal! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Scroll Bar'!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Horizontal Scroll Bar'! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    anObjectFiler objectVersion < 12
        ifTrue: [
            "Upgrade pre 3.1 scroll bar to use #changing: event, which is triggered
                in the same places that the old #changed: event was triggered."
            self partWrapper
                fileInUpgradeEventNames:
                    ( Dictionary new
                        at: #changed: put: #changing:;
                        yourself )
                objectFiler: anObjectFiler ].
    ^super fileInUpgrade: anObjectFiler!