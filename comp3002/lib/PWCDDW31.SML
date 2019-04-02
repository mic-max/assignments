3.1.0.106
   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'DDE Server'!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | propertyStructure |
    ^(propertyStructure := PARTSPropertyStructure on: self)
        when: #editDone
            send: #partPropertyEditDone: to: self with: propertyStructure;
        putProperty: ( PARTSPropertyString new
            value: (application isNil ifTrue: [''] ifFalse: [application]);
            label: 'Application:';
            changeSelector: #application: );
        putProperty: ( PARTSPropertyString new
            value: (topic isNil ifTrue: [''] ifFalse: [topic]);
            label: 'Topic:';
            changeSelector: #topic: );
        putProperty: ( PARTSPropertyList new
            value: eventItems;
            label: 'Poke Item Events';
            validateValueMessage: #validateItemName: ;
            changeSelector: #eventItems: );
        putProperty: ( PARTSPropertyList new
            value: messageItems;
            label: 'Hot Link Item Messages';
            validateValueMessage: #validateItemName: ;
            changeSelector: #messageItems: )
                makeSameLine;
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!   
partPropertyEditDone: aPropertyStructure
        " Private - property changes applied "
    (Message new
        receiver: self partEditor
        selector: #validateLinksAttachedTo:
        arguments: (Array with: self))
            performDeferred.! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'DDE Client'!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | propertyStructure |
    ^( propertyStructure := PARTSPropertyStructure on: self )
        when: #editDone
            send: #partPropertyEditDone: to: self with: propertyStructure;
        putProperty: ( PARTSPropertyString new
            value: application;
            label: 'Application:';
            changeSelector: #application: );
        putProperty: ( PARTSPropertyString new
            value: topic;
            label: 'Topic:';
            changeSelector: #topic: );
        putProperty: ( PARTSPropertyList new
            value: eventItems;
            label: 'Hot Link Item Events';
            validateValueMessage: #validateItemName: ;
            changeSelector: #eventItems: );
        putProperty: ( PARTSPropertyList new
            value: messageItems;
            label: 'Poke Item Messages';
            validateValueMessage: #validateItemName: ;
            changeSelector: #messageItems: )
                makeSameLine;
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #application: with: application;
        addSelectorIfNotNil: #topic: with: topic;
        addSelectorIfNotNil: #eventItems: with: eventItems;
        addSelectorIfNotNil: #messageItems: with: messageItems!