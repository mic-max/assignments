3.1.0.106
   
defaultVisualPartExtent
        "Assume the visual part is an EntryField with System font."

	^(30 @ 5) * PARTSHostInterface defaultPartFont charSize! 
defaultVisualPartExtent
        "Assume the visual part is an Numeric with System font."

    ^PARTSFormGeneratorItem extentForEntryPart: 6
         font: PARTSHostInterface defaultPartFont!
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.

    self hasDllNameChanged
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #dllName:
                    arguments: (Array with: self dllName) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #dllName:
                    arguments: (Array with: self part dllName) ) ].

    proceduresChanged
        ifTrue: [
            applyChangesActions
                add: [  " temporary apply action until undo supported "
                    deletedProcedures do: [ :deletedProcName |
                        self part removeProcedure: deletedProcName] .
                    newProcedures associationsDo: [ :assoc |
                        self part defineProcedure: assoc key entryPoint: assoc value ].
                    ].
            "Undo is not yet supported "
            ].!
newReturnType
        " Private "

    ^self returnTypesList value!
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "
    | items types itemType sizes |

    super partPrintPropertiesOn: aStream margin: aString.

    topDataItem notNil
        ifTrue: [
            (( items := topDataItem subItems ) notNil and: [
                items size > 0 ])
                ifTrue: [
                    types := self class fieldTypes.
                    sizes := self class fieldTypeSizes.
                    aStream
                        nextPutAll: aString;
                        nextPutAll: 'Field name: Type (size in bytes)';
                        cr.
                        items do: [ :anItem |
                            itemType := types keyAtValue: anItem class.
                            aStream
                                tab; tab;
                                nextPutAll: anItem name, ': ',itemType,' (';
                                nextPutAll:
                                    (((sizes at: anItem class) asString isInteger )
                                        ifTrue: [ sizes at: anItem class ]
                                        ifFalse: [ anItem itemSize ] "User-specified" ) asString,
                                    ')';
                                cr ]]].! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelectorIfNotNil: #dataOffset: with: self dataOffset;
        addSelectorIfNotNil: #name: with: self name;
        addSelectorIfNotNil: #object: with: self object;
      "  addSelectorIfNotNil: #subItems: with: self subItems;"
     "   addSelectorIfNotNil: #superItem: with: self superItem;"
        addSelectorIfNotNil: #visualPartExtent: with: self visualPartExtent;
        addSelectorIfNotNil: #visualPartFileName: with: self visualPartFileName.
    self subItems do: [ :subItem |
        anExpressionModel addSelectorIfNotNil: #appendSubItem: with: subItem ]
! 
newArgumentTypes
        " Private "

    ^newArgumentTypes!   
dllName
        " Private - answer the new value of the DLL name property "

    ^self dllNameEntryField value trimBlanks! 
formGeneratorItem
        " Private - Answer a PARTSFormGeneratorItem which
        represents the receiver.  "

    | anApplication visualPart helpInfo |

    self subItems isEmpty
        ifFalse: [self error: 'Cannot generate a form part for non-leaf items'].

    [ anApplication :=
        PARTSFile applicationFromFile: self visualPartFileName ]
        on: PARTSApplicationLoadError
        do: [ :e |
            e postMessageBox: 'Generating Form Parts Error'.
            anApplication := nil ].

    anApplication isNil
        ifTrue: [
            PARTSFormGeneratorItem
                warningNotFound: self visualPartFileName
                for: name
                substitute: 'an EntryField'.
            visualPart := PARTSEntryFieldPart new.
            helpInfo := (Array with: '' with: '') ]
        ifFalse: [
            visualPart := anApplication solePart.
            helpInfo := anApplication helpInfo ].

    self setVisualPartAttributes: visualPart.

    ^PARTSFormGeneratorItem
        for: visualPart
        name: name
        extent: self visualPartExtent
        helpInfo: helpInfo
        staticTextLabel: name
        partEvent: visualPart partNewValueEvent
        partMessage: visualPart partSetValueMessage
        sourceEvent: (name , ':') asSymbol
        sourceMessage: ('set' , name , ':') asSymbol!   
arePropertiesValid
        " Private - answer whether the values of the properties are valid.
        If not valid, notify the user of the problem and answer false. "

    "No need for this check at this time.  [DJL 01-Jun-92]
    ( self hasEntryPointNameChanged
    and: [ ( self newEntryPointName detect: [ :c | c isAlphaNumeric not ]
                ifNone: [ nil ] ) notNil ] )
        ifTrue: [
            MessageBox
                notify: 'Properties Problem'
                withText: 'Entry point name must be alphanumeric.'.
            ^false ].
    "
    ^true!  
selectedArgumentName: anArgumentNameIndex
        " Private - an argument has been selected.
        Update the type. "

    selectedArgument := anArgumentNameIndex.
    self argumentTypesList
        value: (self argumentTypeOf: selectedArgument ).!  
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^self hasEntryPointNameChanged
        or: [ self hasCallingConventionChanged
        or: [ self haveArgumentTypesChanged
        or: [ self hasReturnTypeChanged ] ] ]!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #itemSize: with: itemSize!   
returnTypesList
        " Private - answer the return types list in the dialog window. "

    ^self partNamed: 'ReturnTypesList'!  
defaultVisualPartExtent
        "Assume the visual part is an EntryField with System font."
    "Use  '11:33:03 AM' as an example."

    ^PARTSFormGeneratorItem extentForEntryPart: '11:33:03 AM' size + 2 
		font: PARTSHostInterface defaultPartFont! 
defaultVisualPartExtent
        "Private - Answer a width enough for the checking box
        and the label.  The label is a part of the check box itself
        instead of a StaticText in front of it."

	| aFont |
	aFont := PARTSHostInterface defaultPartFont.
    ^(2  * aFont width +
        (PARTSFormGeneratorItem
            extentForEntryPart: name size
            font: aFont)) x @ aFont height! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | m1 itemExpression receiver1 receiver2 receiver3 index |
    externalDataItem notNil ifTrue: [
        index := [ externalDataItem superItem superItem topItem
            subItems indexOf: externalDataItem ] on: Error do: [ nil ].
        index notNil ifTrue: [
            m1 := anExpressionModel addSelector: #externalDataItem:.
            itemExpression := m1 newExpressionArgument.
            receiver1 := itemExpression newReceiverMessageExpressionModel.
            receiver2 := receiver1 newReceiverMessageExpressionModel.
            receiver3 := receiver2 newReceiverMessageExpressionModel.
            receiver3 receiverObject: externalDataItem superItem superItem accessorPart.
            receiver3 addSelector: #externalRecord.
            receiver2 addSelector: #topItem.
            receiver1 addSelector: #subItems.
            itemExpression addSelector: #at: with: index ]].

    anExpressionModel addSelectorIfNotNil: #flags: with: self flags

"for externalDataItem need to generate an expression like:

    ( anApplication componentNamed: 'BtrieveAccessor1' )
        externalRecord topDataItem subItems at: i

because it is shared object and we don't want 2 distinct objects created.

receiver1 is:
    ( anApplication componentNamed: 'BtrieveAccessor1' )
        externalRecord topDataItem subItems
receiver2 is:
    ( anApplication componentNamed: 'BtrieveAccessor1' )
        externalRecord topDataItem
receiver3 is:
    ( anApplication componentNamed: 'BtrieveAccessor1' )
        externalRecord
receiver3's receiver is:
    ( anApplication componentNamed: 'BtrieveAccessor1' )

"!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'External Record'!   
enableProcedureEditButtons
        " Private - a procedure name is selected.
        Enable the edit and delete buttons. "

    self editProcedureButton enable.
    self deleteProcedureButton enable.! 
openOn: aDLLEntryPoint
    procedureName: aProcedureName
    dllName: aDllName
        " Open a properties dialog on aDLLEntryPoint.
        Update its state if appropriate and answer
        the changed aDLLEntryPoint (nil if cancelled). "

    entryPoint := aDLLEntryPoint.
    procedureName := aProcedureName.
    dllName := aDllName.

    argumentNames := entryPoint argumentNames.
    newArgumentTypes := self argumentTypes copy.
    answer := nil.
    self openDialogWindow.
    ^answer!  
newEntryPointName
        " Private "

    ^self entryPointNameEntryField value trimBlanks!
argumentTypes
        " Private "

    ^entryPoint argumentTypes!  
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog. "

    super initializeEventHandlers.

    self procedureNamesList
        when: #doubleClicked:
        send: #editProcedure: to: self.

    self addProcedureButton
        when: #clicked
        send: #addProcedure to: self.
    self deleteProcedureButton
        when: #clicked
        send: #deleteProcedure to: self.
    self editProcedureButton
        when: #clicked
        send: #editProcedure to: self.!  
disableProcedureEditButtons
        " Private - no procedure name is selected.
        Disable the edit and delete buttons. "

    self editProcedureButton disable.
    self deleteProcedureButton disable.!
editProcedure
        " Private - the Edit... button has been pressed. "

    self editProcedure: self procedureNamesList value.!  
supportsUndoRedo
        " Private - answer whether undo/redo action
        sequences can be constructed for the
        receiver's property values. "

    ^false! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #itemSize: with: itemSize!   
procedureNamesList
        " Private - answer the procedure name list in the dialog window. "

    ^self partNamed: 'ProcedureNameList'!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyBtrieve new accessor: self );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface );
        putProperty: ( PARTSPropertyCreateForm new
                makeSameLine );
        yourself.
    ^aPropertyStructure!   
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
    PARTSDLLAccessorPropertiesEditor new openOn: self!   
defaultVisualPartExtent
        "Assume the visual part is an EntryField with System font."

    ^PARTSFormGeneratorItem extentForEntryPart: self itemSize
        font: PARTSHostInterface defaultPartFont!  
editProcedure: aProcedureName
        " Edit the definition of aProcedureName
        for this DLL.  "

    | oldEntryPoint newEntryPoint |

    "self ASSERT: aProcedureName isSymbol."
    oldEntryPoint := newProcedures at: aProcedureName
        ifAbsent: [ self part entryPointFor: aProcedureName ].
    newEntryPoint := self editProcedureDialog
        openOn: oldEntryPoint
        procedureName: aProcedureName
        dllName: self dllName.
    newEntryPoint isNil
        ifTrue: [ ^nil ].  " cancelled or no changes "

    newProcedures at: aProcedureName put: newEntryPoint.
    proceduresChanged := true.
    newEntryPoint selector ~= oldEntryPoint selector
        ifTrue: [ self updateListAndSelect: newEntryPoint selector ].! 
hasReturnTypeChanged
        " Private "

    ^self newReturnType ~= self returnType!  
defaultVisualPartExtent
        "Make it large enough for the DateField. "
    "Assume nn-nn-nn format."

    ^PARTSFormGeneratorItem extentForEntryPart: 8 + 2 
		font: PARTSHostInterface defaultPartFont! 
callingConvention
        " Private "

    ^entryPoint callingConvention!  
entryPointNameEntryField
        " Private - answer the entry point name
        entry field in the dialog window. "

    ^self partNamed: 'EntryPointNameEntryField'!
defaultVisualPartExtent
        "Assume the visual part is an Numeric with System font."

    ^PARTSFormGeneratorItem extentForEntryPart: (self itemSize / 2.5) rounded + 3
         font: PARTSHostInterface defaultPartFont!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system.  Install event handlers 
        in old applications. "

    | loadContext |
    ( loadContext := anObjectFiler clientContext ) isPARTSLoadContext
        ifTrue: [  " upgrade PWO 2.0 applications "
            self partsIfOS2Do: [
                self registerWorkbenchEventHandlers:
                    self partApplication partEditorEventManager ].
            ].
    ^self!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #fileName: with: fileName;
        addSelectorIfNotNil: #externalRecord: with: externalRecord.
    keyFields size > 0 ifTrue: [
        keyFields do: [ :field |
            anExpressionModel
                addSelector: #addKeyField: with: field ]]!   
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup. Register the workbench event handler. "

    self registerWorkbenchEventHandlers:
        self partApplication partEditorEventManager.
    ^super partCodeGenerated: anApplicationBuilder!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #accessorPart: with: accessorWidget;
        addSelectorIfNotNil: #topItem: with: topDataItem!  
hasEntryPointNameChanged
        " Private "

    ^self
        isNewString: self newEntryPointName
        differentFrom: self entryPointName!  
dllNameEntryField
        " Private - answer the DLL name entry field in the dialog window. "

    ^self partNamed: 'DLLNameEntryField'!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyCStructure new accessor: self );
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface );
        putProperty: ( PARTSPropertyCreateForm new
                makeSameLine );
        yourself.
    ^aPropertyStructure!
editProcedureDialog
        " Private - answer the procedure entry point property editor. "

    "
    entryPointEditor isNil
        ifTrue: [ entryPointEditor := PARTSDLLEntryPointEditor new ].
    ^entryPointEditor
    "
    ^PARTSDLLEntryPointEditor new!
acceptProperties
        " Private - accept the validated property values. "

    answer := entryPoint class new
        selector: entryPoint selector;
        entryPointName: self newEntryPointName;
        callingConvention: self newCallingConvention;
        argumentTypes: self newArgumentTypes;
        returnType: self newReturnType;
        yourself.!   
argumentTypesList
        " Private - answer the argument types list in the dialog window. "

    ^self partNamed: 'ArgumentTypesList'!
addProcedure
        " Private - add a new procedure definition to this DLL.
        Update the list accordingly. "

    | newProcName |

    newProcName := Prompter
        prompt: 'Enter a procedure message name:'
        default: 'name:arg:'.
    newProcName size = 0  " nil or empty "
        ifTrue: [ ^nil ].
    newProcName := newProcName asSymbol.

    " determine if valid proc name "
    ( self procedureNames includes: newProcName )
        ifTrue: [
            MessageBox
                notify: 'Add New Procedure'
                withText: 'Procedure ''', newProcName,
                                ''' (already defined).'.
            ^nil ].
    ( self part respondsTo: newProcName )
        ifTrue: [
            MessageBox
                notify: 'Add New Procedure'
                withText: 'Unable to add ''', newProcName,
                                ''' (already defined as script or message).'.
            ^nil ].
    newProcName first isLetter not
        ifTrue: [
            MessageBox
                notify: 'Add New Procedure'
                withText: 'Unable to add ''', newProcName,
                                ''' (first character must be a letter).'.
            ^nil ].
    ( newProcName indexOfString: '::' ) ~= 0
        ifTrue: [
            MessageBox
                notify: 'Add New Procedure'
                withText: 'Unable to add ''', newProcName,
                                ''' (missing an argument).'.
            ^nil ].

    newProcName do: [ :c |
        ( c isAlphaNumeric or: [ c = $: ] )
            ifFalse: [
                MessageBox
                    notify: 'Add New Procedure'
                withText: 'Unable to add ''', newProcName,
                                ''' (cannot use the character ''', (String with: c),
                                ''' in a message name).'.
            ^nil ] ].

    ( ( newProcName indexOfString: ':' ) ~= 0
    and: [ newProcName last ~= $: ] )
        ifTrue: [
            MessageBox
                notify: 'Add New Procedure'
                withText: 'Unable to add ''', newProcName,
                                ''' (missing a '':'' in the last argument).'.
            ^nil].

    " accept the new proc "
    deletedProcedures remove: newProcName ifAbsent: [].
    newProcedures
        at: newProcName asSymbol
        put: ( PARTSDLLEntryPoint forMessage: newProcName ).
    proceduresChanged := true.
    self updateListAndSelect: newProcName.!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'C Struct'!  
argumentNames
        " Private - answer the list of argument names "

    ^argumentNames! 
procedureNames
        " Answer the procedures currently defined in this DLL. "

    | names |
    names := self part procedureNames.
    ( deletedProcedures size = 0
    and: [ newProcedures size = 0 ] )
        ifTrue: [ ^names ].
    names := names asSet.
    deletedProcedures do: [ :oldGuy | names remove: oldGuy ].
    newProcedures keysDo: [ :newGuy | names add: newGuy ].
    ^names asSortedCollection asArray! 
partFormGeneratorNames
        " Answer a collection containing the data item
        names accessed by the receiver. "

    ^self fieldNames!
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    | anEntryPoint indent  names types |

    aStream
        nextPutAll: aString;
        nextPutAll: 'DLL file name: ';
        nextPutAll: ( dllName size = 0
            ifTrue: [ '(undefined)' ]
            ifFalse: [ dllName ] );
        cr.
    entryPointDict notNil
        ifTrue: [
        indent := '    '.
        entryPointDict keysSorted do: [ :key |

            anEntryPoint := entryPointDict at: key.
            names := anEntryPoint argumentNames.
            types := anEntryPoint argumentTypes.

            aStream
                nextPutAll: aString;
                nextPutAll: 'Procedure: ';
                nextPutAll: anEntryPoint selector printString;
                cr;
                nextPutAll: aString;
                nextPutAll: indent, 'Entry point: ';
                nextPutAll: anEntryPoint entryPointName ;
                cr;
                nextPutAll: aString;
                nextPutAll: indent, 'Calling convention: ';
                nextPutAll: anEntryPoint callingConvention ;
                cr.
            names size > 0
                ifTrue: [
                    aStream
                        nextPutAll: aString;
                        nextPutAll: indent, 'Arguments: ';
                        cr.
                        1 to: names size do: [ :i |
                            aStream
                                nextPutAll: indent; tab; tab;
                                nextPutAll: ( names at: i ), ' ', ( types at: i ) printString;
                                cr ].
                    ].
            aStream
                nextPutAll: aString;
                nextPutAll: indent, 'Return type: ';
                nextPutAll: anEntryPoint returnType ;
                cr ] ].!  
haveArgumentTypesChanged
        " Private "

    ^self newArgumentTypes ~= self argumentTypes!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #itemSizeAttribute: with: itemSize!  
selectedArgumentType: anArgumentType
        " Private - an argument type has been selected.
        Record the changed type. "

    "self ASSERT: anArgumentType isSymbol."
    self newArgumentTypes
        at: selectedArgument
        put: anArgumentType.!  
procedureNameDescription
        " Private "

    ^'Procedure ', procedureName,
         ' (',
        ( dllName size = 0
            ifTrue: [ 'unknown DLL' ]
            ifFalse: [ dllName fileNameLessPath fileName, '.DLL' ] ),
        ')'!
hasDllNameChanged
        " Private - answer whether the DLL name property has been changed. "

    ^self isNewString: self dllName differentFrom: self  part dllName! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
addProcedureButton
        " Private - answer the Add... button in the dialog window. "

    ^self partNamed: 'AddProcedureButton'!
procedureNameLabel
        " Private - answer the procedure name label item
        in the dialog window. "

    ^self partNamed: 'ProcedureNameLabel'!   
partFormGeneratorItemsFor: itemNames
        "Answer a collection of PARTS form generator items
        defining the parts to be generated to represent the
        specified fieldNames. "

    ^externalRecord partFormGeneratorItemsFor: itemNames!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #dllName: with: dllName;
        addSelectorIfNotNil: #entryPointDict: with: entryPointDict!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelectorIfNotNil: #argumentTypes: with: argumentTypes;
        addSelectorIfNotNil: #callingConvention: with: callingConvention;
        addSelectorIfNotNil: #entryPointName: with: entryPointName;
        addSelectorIfNotNil: #returnType: with: returnType;
        addSelectorIfNotNil: #selector: with: selector!   
partFormGeneratorItemsFor: fieldNames
        "Answer a collection of PARTS form generator items
        defining the parts to be generated to represent the
        specified fieldNames. "

    | formItems |
    formItems := OrderedCollection new.
    fieldNames do: [ :aName |
        formItems add:
            ( ( self fieldNamed: aName ) formGeneratorItem ).
        ].
    ^formItems!  
returnTypeChoices
        " Private - answer the set of possible return types "

    ^entryPoint class returnTypes!
argumentTypeChoices
         " Answer the set of possible argument types "

   " ^entryPoint class argumentTypes"
    ^#( #short #ushort #long #ulong #boolean #handle #reference #double )!  
entryPointName
        " Private "

    ^entryPoint entryPointName!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Btrieve Accessor'!  
returnType
        " Private "

    ^entryPoint returnType!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'DLL Accessor'!  
initializeEventHandlers
        " Private - the dialog window application has been loaded.
        Register event handlers for the parts in the application. "

    super initializeEventHandlers.

    self argumentNamesList
        when: #changedIndex:
        send: #selectedArgumentName: to: self.
    self argumentTypesList
        when: #changed:
        send: #selectedArgumentType: to: self.!  
deleteProcedure
        " Private - delete the definition of aProcedureName
        and update the procedure list accordingly. "

    | aProcedureName previousContents deletedIndex newSelection |

    aProcedureName := self procedureNamesList value asSymbol.

    previousContents := self procedureNames.
    deletedIndex := previousContents indexOf: aProcedureName.
    newSelection :=
        ((previousContents size = 1)
            ifTrue: [nil]  " nothing left to select "
            ifFalse: [
                previousContents at: ((deletedIndex > 1)
                    ifTrue: [deletedIndex - 1]
                    ifFalse: [deletedIndex + 1])]).
    newProcedures removeKey: aProcedureName ifAbsent: [].
    (self part includes: aProcedureName)
        ifTrue: [deletedProcedures add: aProcedureName].
    proceduresChanged := true.
    self updateListAndSelect: newSelection.! 
callingConventionList
        " Private - answer the calling conventions list in the dialog window. "

    ^self partNamed: 'CallingConventionList'!   
updateListAndSelect: aProcedureName
        " Private - update the procedure names list. "

    | aListPane newList |
    aListPane := self procedureNamesList.
    newList := self procedureNames.
    aListPane setList: newList.
    ( aProcedureName notNil and: [newList size > 0] )
        ifTrue: [
            aListPane value: aProcedureName.
            self enableProcedureEditButtons ]
        ifFalse: [
            self disableProcedureEditButtons ].!
deleteProcedureButton
        " Private - answer the Delete button in the dialog window. "

    ^self partNamed: 'DeleteProcedureButton'!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "
    | items types sizes itemType |

    super partPrintPropertiesOn: aStream margin: aString.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Fields:';
        cr.

    externalRecord topItem notNil
        ifTrue: [
            (( items := externalRecord topItem subItems ) notNil and: [
                items size > 0 ])
                ifTrue: [
                    types := self class fieldTypes.
                    sizes := self class fieldTypeSizes.
                    aStream
                        nextPutAll: aString;
                        nextPutAll: 'Field name: Type (size in bytes)';
                        cr.
                        items do: [ :anItem |
                            itemType := types keyAtValue: anItem class.
                            aStream
                                tab; tab;
                                nextPutAll: anItem name, ': ',itemType,' (';
                                nextPutAll:
                                    (((sizes at: anItem class) isInteger )
                                        ifTrue: [ sizes at: anItem class ]
                                        ifFalse: [ anItem itemSize ] "User-defined size" ) asString,
                                    ')'.
                             aStream nextPutAll:
                                (( self isKey: anItem )
                                        ifTrue: [
                                            ' - Key ',
                                            (( self isUniqueKey: anItem )
                                                ifTrue: [ '(Duplicates allowed)' ]
                                                ifFalse: [ '(Unique values)' ] )]
                                        ifFalse: [ '' ]).
                             aStream cr ]]].!   
initializePartValues
        " Private - the dialog window application has been loaded
        or a used copy from a cache is being reset.
        Initialize the items in the property dialog based on the
        current values of the properties. "

    self procedureNameLabel
        setValue: self procedureNameDescription.

    self entryPointNameEntryField
        setValue: self entryPointName.
    "self ASSERT: self entryPointNameEntryField modified not."

    self callingConventionList
        setList: self callingConventionChoices;
        setValue: self callingConvention.

    self argumentNames size > 0
        ifTrue: [    " avolid #changed: event triggering here (reset cached copy) "
            selectedArgument := 1.
            self argumentNamesList
                setList: self argumentNames;
                valueIndex: selectedArgument;
                enable.
            self argumentTypesList
                setList: self argumentTypeChoices;
                value: ( self argumentTypeOf: selectedArgument );
                enable.
            ]
        ifFalse: [
            selectedArgument := nil.
            self argumentNamesList
                setList: #();
                disable.
            self argumentTypesList
                setList: #();
                disable.
            ].

    self returnTypesList
        setList: self returnTypeChoices;
        setValue: self returnType.!   
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
partFormGeneratorNames
        " Answer a collection containing the data item
        names accessed by the receiver. "

    ^externalRecord partFormGeneratorNames!  
newCallingConvention
        " Private "

    ^self callingConventionList value!   
defaultVisualPartExtent
        "Assume the visual part is an Numeric with System font."

    ^PARTSFormGeneratorItem extentForEntryPart: 12
		font: PARTSHostInterface defaultPartFont!  
partHasDynamicMessages
        " Private - answer whether the part has
        dynamic messages which can change
        when its property values are updated. "

    ^true! 
callingConventionChoices
        " Private - answer the set of possible calling conventions "

    ^entryPoint class callingConventions!   
arePropertiesValid
        " Private - answer whether  the values of the properties are valid.
        If not valid, notify the user of the problem and answer false "

    | propertiesAreValid |

    propertiesAreValid := super arePropertiesValid.

    ( self hasDllNameChanged
    and: [ ( self dllName detect: [ :c | c asInteger <= 32 ]
                ifNone: [nil] ) notNil ] )
        ifTrue: [ "Assume illegal (control) characters have value <= 32"
            self
                reportProblemIn: 'DLL Name'
                message: 'DLL name should not contain control characters.'.
            propertiesAreValid := false ].
    ^propertiesAreValid!   
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'PpDLLAcs.par'! 
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'PPDLLEPT.par'! 
argumentTypeOf: anArgumentIndex
        " Private "

    ^self newArgumentTypes at: anArgumentIndex!   
initializeValues
        " Private - initialize instance variables. "

    proceduresChanged := false.
    deletedProcedures := Set new.   " deletions from original guy "
    newProcedures := Dictionary new.  " new or changed definitions "! 
hasCallingConventionChanged
        " Private "

    ^self newCallingConvention ~= self callingConvention! 
formGeneratorItem
        " Private - Answer a PARTSFormGeneratorItem which
        represents the receiver.  "

    | anApplication visualPart helpInfo |

    self subItems isEmpty
        ifFalse: [self error: 'Cannot generate a form part for non-leaf items'].
    [ anApplication :=
        PARTSFile applicationFromFile: self visualPartFileName ]
        on: PARTSApplicationLoadError
        do: [ :e |
            e postMessageBox: 'Generating Form Parts Error'.
            anApplication := nil ].

    anApplication isNil
        ifTrue: [
            PARTSFormGeneratorItem
                warningNotFound: self visualPartFileName
                for: name
                substitute: 'a CheckBox'.
            visualPart := PARTSCheckBoxPart new.
            helpInfo := (Array with: '' with: '') ]
        ifFalse: [
            visualPart := anApplication solePart.
            helpInfo := anApplication helpInfo ].

    visualPart setLabel: name.
    ^PARTSFormGeneratorItem
        for: visualPart
        name: name
        extent: self visualPartExtent
        helpInfo: helpInfo
        staticTextLabel: nil
        partEvent: visualPart partNewValueEvent
        partMessage: visualPart partSetValueMessage
        sourceEvent: (name , ':') asSymbol
        sourceMessage: ('set' , name , ':') asSymbol!
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [ self hasDllNameChanged
        or: [ proceduresChanged ] ]!  
editProcedureButton
        " Private - answer the Edit... button in the dialog window. "

    ^self partNamed: 'EditProcedureButton'! 
argumentNamesList
        " Private - answer the argument names list in the dialog window. "

    ^self partNamed: 'ArgumentNamesList'!
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    | procedureNames aListPane |

    super initializePartValues.

    self dllNameEntryField
        setValue: self part dllName.

    procedureNames := self procedureNames.
    aListPane := self procedureNamesList.
    procedureNames size > 0
        ifTrue: [
            aListPane
                setList: procedureNames;
                valueIndex: 1.
            self enableProcedureEditButtons ]
        ifFalse: [
            aListPane
                setList: #();
                valueIndex: nil.
            self disableProcedureEditButtons ].!