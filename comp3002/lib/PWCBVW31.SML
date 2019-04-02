3.1.0.106
   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #font: with: font;
        addSelectorIfNotNil: #printer: with: printer;
        addSelectorIfNotNil: #printerName: with: printerName ";
addSelector: #wrap: with: wrap "!
partPropertyMaxSizeLabel
        " Return the label for the max size property. "
    ^ 'Maximum number of characters'!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure valueDict|
    valueDict:= Dictionary new
        at: 'pictureMask' put: self pictureMask;
        at: 'datum' put: self datum;
        yourself.
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        when: #aboutToEdit
            send: #partPropertyApplyEdit: to: self with: aPropertyStructure.
    self
        partPropertyAddContentsItem: aPropertyStructure;
        partPropertyAddEmptyValueItem: aPropertyStructure;
        partPropertyAddStyleItems: aPropertyStructure;
        partPropertyAddAlignmentItem: aPropertyStructure;
        partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        at: #editButton putProperty: ( PARTSPropertyEditButton new
            label: 'Edit picture...';
            value: valueDict;
            clickedSelector: #partPropertyEditPicture:   ;
            changeSelector: #partPropertySaveNewValue: ).
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #defaultMessage: with: self defaultMessage;
        addSelectorIfNotNil: #promptMessage: with: self promptMessage;
        addSelectorIfNotNil: #removeBlanks: with: self removeBlanks!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #setValue: with: self value.
    self partDirectEditTextIsCentered
        ifTrue: [
            anExpressionModel addSelector: #centered ]
        ifFalse: [
            self partDirectEditTextIsRightJustified
                ifTrue: [
                    anExpressionModel addSelector: #rightJustified ]]!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    self
        partsIfOS2Do: [
            self drawSelector = #drawToFit:
                ifTrue: [ self drawAnisotropic ].
           ].
    ^super fileInUpgrade: anObjectFiler!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Multiple Choice List Pane'! 
addRangeGroup: topPane
        " Private "
    | charSize entryHeight font adjustment|

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.
    font := self font.
    adjustment:= self layoutAdjustmentFactor.

    topPane addSubpane: (GroupBox new
        contents: 'Range';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ (1/2) - adjustment) * charSize rounded)
                extentFromLeftTop: ((35 @ 3 + adjustment ) * charSize)]).
    topPane addSubpane: (StaticText new
        rightJustified;
        contents: 'Minimum:';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (3 @ (3/2) * charSize rounded))
                extentFromLeftTop: (9 @ (3/2) * charSize rounded)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        contents: (dialParameters at: 'lowReading');
        setName: 'min';
        framingBlock: [: box |
            (box leftTop rightAndDown: (13 @ (3/2) * charSize rounded))
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (StaticText new
        rightJustified;
        contents: 'Maximum:';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (19 @ (3/2) * charSize rounded))
                extentFromLeftTop: (9 @ (3/2) * charSize rounded)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'max';
        contents: (dialParameters at: 'highReading');
        framingBlock: [: box |
            (box leftTop rightAndDown: (29 @ (3/2) * charSize rounded))
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).!  
partDragTargetFormatsDefault
    "Private - answer the default drag formats."

    ^#('string').!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    self value size > 0 ifTrue: [
            anExpressionModel addSelector: #setValue: with: self value ].
    self emptyValue size > 0 ifTrue: [
            anExpressionModel  addSelector: #emptyValue: with: self emptyValue ].
    anExpressionModel addSelectorIfNotNil: #setTextLimit: with: self textLimit! 
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."
    self partsVwOnly.
    self partIsEditing ifTrue: [ ^HtClient ].
    ^nil! 
partPropertyAddConvertItem: aPropertyStructure
        " Private - type conversion not supported for formatted entry fields. "!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Dial Pane'! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.

    self labelEntryField
        value: self partLabel.!   
partGetGraphics
        "Answer the receiver's bitmap."
    ^self contents! 
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #editContents ).
    aPropertyStructure
        putProperty: (PARTSPropertyDragDrop new makeSameLine).
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #pictureMask: with: self pictureMask;
        addSelectorIfNotNil: #pictureCharacterPlaceholder: with: self pictureCharacterPlaceholder!
partPropertyAddSignedItem: aPropertyStructure
    "Private - add a checkbox to set signed to true or false.
    Not supported by currency field - signed is always true. "! 
partDragTargetOperationsDefault
    "Private - answer the default drag operations for the receiver."

    ^#(#move #copy).!
ok
        " Private - the OK button was pressed. "
     self partPropertyValidate
        ifFalse: [^nil]. "Do not close the window and let the user fix
                             the invalid values."
    self cleanUpTicksDirectory.
    answer := Dictionary new
        at: 'lowReading' put: (self paneAt: 'min') value;
        at: 'highReading' put: (self paneAt: 'max') value;
        at: 'lowAngle' put: (self paneAt: 'lowAngle') value;
        at: 'highAngle' put: (self paneAt: 'highAngle') value;
        at: 'numberOfTicks' put: (self paneAt: 'ticks') value;
        at: 'defaultSize' put: (self paneAt: 'defaultSize') value;
        at: 'tickInterval' put: ( Array
            with: (self paneAt: 'interval') value
            with: (self paneAt: 'intervalSize') value );
        at: 'autoLabels' put: (self paneAt: 'autoLabels') value;
        at: 'ticks' put: ticks;
        at: 'initSetting' put: (self paneAt: 'initSetting') value;
        yourself.
    self close!  
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.

    self hasLabelChanged
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #label:
                    arguments: (Array with: self labelEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: part
                    selector: #label:
                    arguments: (Array with: self partLabel ) ) ].! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

     | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyString new
            value: self contents;
            label: 'Label:';
            changeSelector: #partSetDirectEditValue: ;
            validationMessage: #partPropertyDirectEditValueIsValid: );
        putProperty: ( PARTSPropertyBinaryStyle new
            value: (self hasStyle: BsAutoRadioButton);
            label: 'Auto radio button';
            constant: BsAutoRadioButton;
            constant2: BsRadioButton );
        yourself.
    SupportsLabelLeftOfButton
        ifTrue: [
            aPropertyStructure
                putProperty: ( self partPropertyWindowStyle: 'Label left of button'
                    constant: BsLeftAlignedText) ].
    aPropertyStructure
        putProperty: ( PARTSPropertyBoolean new
            value: self value;
            label: 'Initially on';
            changeSelector: #value: );
        yourself.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!  
partDragTargetFormatsDefault
    "Private - answer the default drag formats."

    ^#('object' 'string').! 
addTickNumberItem: topPane
        " Private -platform-dependent (use SpinButton where available, else drop-down list) "

    | charSize entryHeight tickPane tickNumbers |

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.

    self
        partsIfOS2Do: [
            topPane addSubpane: (
                (tickPane := (Smalltalk at: #SpinButton) numeric)
                owner: self;
                setName: 'tick';
                when: #changed: send: #tickAt: to: self with: tickPane;
                minimum: 0;
                maximum: (dialParameters at: 'numberOfTicks') - 1;
                framingBlock: [: box |
                    (box leftTop rightAndDown: (7 @ 20) * charSize rounded)
                    extentFromLeftTop: (7 * charSize x @ entryHeight)])
            ]
        partsIfWindowsDo: [
            tickNumbers:= OrderedCollection new.
            0 to: ((dialParameters at: 'numberOfTicks') - 1)
                do: [:i | tickNumbers add: i ].
          topPane addSubpane: (
                (tickPane := DropDownList new)
                owner: self;
                setName: 'tick';
                when: #changed: send: #tickAt: to: self  with: tickPane  ;
                contents: tickNumbers;
                framingBlock: [: box |
                    (box leftTop rightAndDown: (7 @ 20 + self layoutAdjustmentFactor) * charSize rounded)
                        extentFromLeftTop: (7 * charSize x @ ( (tickNumbers size) max: 30))])
            ].!  
PARTSPushButtonPart removePartWorkbenchLibrary!   
partPropertyBeginApply: aPropertyStructure
        " Private - apply property changes to the receiver.
         Apply the text limit change now so that it is done
         in time for the value to be applied. "
    ( self partPropertyMaxSizeChanged: aPropertyStructure )
        ifTrue: [ self setTextLimit: (aPropertyStructure propertyAt: #textLimit) value ].!
removePartWorkbenchLibrary
        " Private - remove the basic visual parts workbench library. "


    self partsIfOS2Do: [
        " platform-dependent prerequisite for the Dial Editor "
        SmalltalkLibraryBinder unBind: 'VSPN31O'.
        ]!  
updateTickSize: aField
        " Private - Update the tick size of each tick specified by the user. "
    aField modified ifFalse: [^self].
    ticks
        at: (self paneAt: 'tick') value
        put: ( Array
            with: aField value
            with: (self paneAt: 'tickText') contents )!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Integer Entry Field'!   
partLabel
        " Private - answer the current label of the part. "

    ^self part label!   
value
        "Answer a clone of the  icon or bitmap displayed by the receiver."
    ^value isNil
        ifTrue: [ nil ]
        ifFalse: [ value clone ]!   
fileInUpgrade: anObjectFiler
        " Private - upgrade the receiver into the form expected
        in the current system. "

    " (over?) zealous upgrade for catalog part; fix PWO 2.0 color "
    ( #( 6 5 ) includes: anObjectFiler objectVersion )
        ifTrue: [ 
            label isNil ifTrue: [ label := 'Text' ].
            "anObjectFiler
                when: #loaded
                 send: #partUpgradeIndexColorsToRGB to: self" ].
    ^super fileInUpgrade: anObjectFiler!   
partPropertySaveNewValue: valueDict
        "Private - set the new picture mask of the receiver."
   | newPictureMask newDatum |
    newPictureMask:= valueDict  at: 'pictureMask'.
    newDatum := valueDict at: 'datum'.
    self
        pictureMask: newPictureMask;
        value: newDatum .!
initWindowSize
        "Private - Answer the default window size."
    | charSize |
    charSize := WindowDialog unitMultiplier.
    ^38 @ 25 * charSize! 
partPropertyBeginApply: aPropertyStructure
        " Private - apply property changes to the receiver.
         Apply the text limit change now so that it is done
         in time for the value to be applied. "
   ( self partPropertyMaxSizeChanged: aPropertyStructure )
        ifTrue: [ self digits: (aPropertyStructure propertyAt: #textLimit) value ].!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setValue: with: self value! 
labelEntryField
        " Private - answer the label entry field in the dialog window. "

    ^self partNamed: 'LabelEntryField'!  
partApplicableStylePrefixes
    ^#()!
tickAt: tickPane
    "Private - set the value of the length and text of each tick."
    |dict|
    dict:= ticks copy.
      ( (ticks at: (tickPane value) ifAbsent: [nil]) notNil )
        ifTrue: [
            (self paneAt: 'tickSize') setValue: ((dict at: (tickPane value)) at: 1).
            (self paneAt: 'tickText') setValue: ((dict at: (tickPane value)) at: 2)]
        ifFalse: [
            (self paneAt: 'tickSize') setValue: nil.
            (self paneAt: 'tickText') setValue: nil].!  
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( self partPropertyWindowStyle: 'Border'
            constant: WsPaneBorder );
        putProperty: ( self partPropertyWindowStyle: 'Vertical scroll bar'
            constant: WsVerticalScrollBar );
        putProperty: ( self partPropertyWindowStyle: 'Horizontal scroll bar'
            constant: WsHorizontalScrollBar );
        putProperty: ( PARTSPropertyBoolean new
            value: ( ( stretch = 0 ) not );
            label: 'Stretch bitmap to fit window';
            changeSelector: #stretchBitmap: );
        putProperty: #( #editGraphic );
        putProperty: #( #interface #sizeWindow )!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Graph Pane'!
partPropertyValidate
        " Private - Return true if the input values are correct, else return false and
        warn the user to correct the values. "
    | newLowReading newHighReading  newInit |
    self partPropertyValidateEmptyFields ifFalse: [^false].
    newLowReading:= (self paneAt: 'min') value.
    newHighReading:= (self paneAt: 'max') value.
    newInit:= (self paneAt: 'initSetting') value.
    newLowReading > newHighReading
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The minimum range must be less than the maximum range.'.
            (self paneAt: 'min') setFocus.
            ^false].
    ( newInit < newLowReading or: [newInit > newHighReading] )
        ifTrue: [
            MessageBox
                notify: 'Invalid Property'
                withText: 'The initial setting must between the minimum and the maximum range.'.
            (self paneAt: 'initSetting') setFocus.
            ^false ].
    ^true!  
partPropertyMaxSizeChanged: aPropertyStructure
        " Private - the text limit property was just changed.
           Set the text limit of the contents field. "
    | textLimitProperty newTextLimit contentsProperty |
    textLimitProperty := ( aPropertyStructure propertyAt: #textLimit ).
    textLimitProperty modified ifFalse: [^false].
    textLimitProperty textEntryItem validateSizeAndFormatOfInput
        ifTrue: [
            newTextLimit:= textLimitProperty value .
            ( ( newTextLimit notNil ) and: [ newTextLimit < 0 ] )
                ifTrue: [
                    self partPropertyMaxSizeErrorMessage.
                    ^false ]
                ifFalse: [
                    textLimitProperty newValue: textLimitProperty value .
                    contentsProperty := ( aPropertyStructure propertyAt: #contents ) textEntryItem.
                    contentsProperty
                        partPropertySetNewMaxSize: newTextLimit to: contentsProperty;
                        modified: true.
                    ^true ]]
        ifFalse: [
            MessageBox warning:
                        'Invalid input in max size field.'.
            ^false ]! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Push Button'!   
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup."
    readingsPerDegree := highReading - lowReading /
        (self relativeDegree: highDegree).
    ^super partCodeGenerated: anApplicationBuilder!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        when: #aboutToEdit
        send: #partPropertyBeginApply: to: self with: aPropertyStructure.
    self
        partPropertyAddContentsItem: aPropertyStructure;
        partPropertyAddStyleItems: aPropertyStructure.
    aPropertyStructure
        at: #dateFormat putProperty: ( PARTSPropertyDateFormat new
            value: self dateFormatProperties;
            changeSelector: #dateFormatProperties: ).
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
installPartWorkbenchLibrary
        " Private - install the basic visual parts workbench library. "


    self partsIfOS2Do: [
        " platform-dependent prerequisite for the Dial Editor "
        PARTSSessionManager
            bindLibrary: 'VSPN31O'
            errorTitle: 'Basic Visual Part Workbench Support Installation Problem'
            neededFor: 'the DialPane property editor'.
        ]!  
partPropertyAddContentsItem: aPropertyStructure
    ^aPropertyStructure
        putProperty: ( PARTSPropertyString new
            value: self contents;
            label: 'Label:';
            changeSelector: #propertyContents:;
            yourself)!
addAngleGroup: topPane
        " Private "
    | charSize entryHeight font adjustment|

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.
    font := self font.
    adjustment:= self layoutAdjustmentFactor.

    topPane addSubpane: (GroupBox new
        contents: 'Range angles';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ 4 - adjustment) * charSize rounded)
                extentFromLeftTop: ((35 @ 4 + adjustment) * charSize) rounded]).
    topPane addSubpane: (StaticText new
        rightJustified;
        contents: 'Minimum:';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (3 @ 5 * charSize rounded))
                extentFromLeftTop: (9 @ (3/2) * charSize rounded)]).
    topPane addSubpane: (StaticText new
        contents: 'Note - 0 is East, 90 is North';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (3 @ (27/4) * charSize rounded))
                extentFromLeftTop: (23 @ 1 * charSize rounded)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        contents: (dialParameters at: 'lowAngle');
        setName: 'lowAngle';
        framingBlock: [: box |
            (box leftTop rightAndDown: (13 @ 5 * charSize rounded))
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (StaticText new
        rightJustified;
        contents: 'Maximum:';
        font: font;
        framingBlock: [: box |
            (box leftTop rightAndDown: (19 @ 5 * charSize rounded))
                extentFromLeftTop: (9 @ (3/2) * charSize rounded)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'highAngle';
        contents: (dialParameters at: 'highAngle');
        framingBlock: [: box |
            (box leftTop rightAndDown: (29 @ 5 * charSize rounded))
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).!   
updateTickText: aField
        " Private - Update the text label of the tick. "
    aField modified ifFalse: [^self].
    ticks
        at: (self paneAt: 'tick') value
        put: ( Array
            with: (self paneAt: 'tickSize') value
            with: aField contents)! 
partPropertyValidateEmptyFields
        " Private - Return true if the fields that need a value are
           not empty, else answer false and warn the user.  "
    | fields paneName paneMessage |
    fields:= OrderedCollection new.
    fields
        add: #( 'min' 'Minimum range' );
        add: #( 'max' 'Maximum range' );
        add: #( 'lowAngle' 'Minimum range angle' );
        add: #( 'highAngle' 'Maximum range angle' );
        add: #( 'ticks' 'Number of ticks ' );
        add: #( 'defaultSize' 'Default tick length' );
        add: #( 'initSetting' 'Initial setting' );
        add: #( 'interval' 'Tick interval' );
        add: #( 'intervalSize' 'Tick length' );
        yourself.
    fields do: [ :array|
        paneName:= array at: 1.
        paneMessage:= array at: 2.
        ((self paneAt: paneName) value) isNil
            ifTrue: [
                MessageBox
                    notify: 'Invalid Property'
                    withText:  paneMessage, ' value cannot be empty.'.
                (self paneAt: paneName) setFocus.
            ^false]].
    ^true! 
partPropertyAddMaxSizeItem: aPropertyStructure
        " Private - add max size item to the property structure. "
    | limit |
    limit:= self textLimit.
    limit isNil
        ifFalse: [ limit:=limit  - 1 ].
    aPropertyStructure
        at: #textLimit putProperty: ( PARTSPropertyNumber new
            value: limit  ;
            label: self partPropertyMaxSizeLabel, ':' ;
            immediateValidationMessage: (Message
                receiver: self
                selector: #partPropertyMaxSizeChanged:
                arguments: (Array with: aPropertyStructure) );
            yourself )!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Static Graphic'!
partPropertySetStyle: newStyle
        " Private - Platform dependent - bitmap style has to be supported
        using a DrawnButton on VW "
    | prevStyle |
    self supportsBothBitmapAndIcon
        ifFalse: [^self].  " only one style, so nothing to change "
    (Message new        "disable undo changing style for now."
        receiver: self partEditor;
        selector: #recordUndoPlaceholder)
        performDeferred.
    prevStyle := style.
    super partPropertySetStyle: newStyle.
    (prevStyle bitAnd: SsBitmap) = SsBitmap
        ifTrue: [        "static bitmap"
            (newStyle bitAnd: SsIcon) = SsIcon
                ifTrue: [
                    self value: (PARTSIcon fromBitmap: self value)]]
        ifFalse: [        "static icon"
            (newStyle bitAnd: SsBitmap) = SsBitmap
                ifTrue: [
                    self value: (self value colorBitmap clone)]]!
partInitializeStyle
        " Private - the receiver is being constructed from PARTS source code.
		Initialize the receiver's style to the default style."

    self style: self class noScrollbarsFrameStyle.!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |

    aPropertyStructure:= PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyString new
            value: self contents;
            label: 'Label:';
            changeSelector: #contents: ).
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
partPropertyAddConvertItem: aPropertyStructure
        " Private "
    ConvertCharactersValues notNil  " VW only "
        ifTrue: [aPropertyStructure
            putProperty: ( PARTSPropertyButtonGroupWS new
                label: 'Convert characters to';
                labelsMap: ConvertCharactersLabels;
                initialSelection: (self partPropertiesIndexOf: ConvertCharactersValues));
            yourself].!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Alphabetic Entry Field'!
partPropertyAddStyleItems: aPropertyStructure
        " Private - add style items to the property structure.
        The border and autoscroll properties are not
        supported on all platforms. "
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'Border'
            constant: EsBorder );
        putProperty: ( self partPropertyWindowStyle: 'Auto scroll'
            constant: EsAutoHorizontalScroll );
        putProperty: ( self partPropertyWindowStyle: 'Read only'
            constant: EsReadOnly );
        putProperty: ( self partPropertyWindowStyle: 'Password'
            constant: EsPassword );
        yourself.!
partEditContents: currentContents properties: aPropertyStructure
        " Private - edit the part contents "
    ^(PARTSDialEditor new
        openOn: currentContents)
            partsExceptionIfNil! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Combo Box'! 
partPropertyAddAlignmentItem: aPropertyStructure
        " Private - add alignment item to the property structure.
        Centered and right-aligned are supported on VOS,
        but on VW are only supported in a multiline edit control. "
    AlignmentValues isNil ifTrue: [^self].
    aPropertyStructure
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Alignment';
            labelsMap: AlignmentLabels;
            initialSelection: (self partPropertiesIndexOf: AlignmentValues) ).!  
partPropertyAddContentsItem: aPropertyStructure
        " Private - add contents item to the property structure. "
    aPropertyStructure
        at: #contents putProperty: ( PARTSPropertyFormattedString new
        	textEntryItem: ( self class new
            	pictureMask: pictureMask copy );
        	value: self value;
        	label: 'Contents:';
        	yourself )!  
partPropertyAddDecimalDigitsItem: aPropertyStructure
    "Private - add an entry field which allows users to set the number of decimal
      digits allowed in the receiver. "
    aPropertyStructure
        at: #decimalPlace putProperty: ( PARTSPropertyNumber new
            value: self decimalPlace;
            label: 'Number of decimal digits: ' ;
            immediateValidationMessage: (Message
                receiver: self
                selector: #partPropertyDecimalPlaceChanged:
                arguments: (Array with: aPropertyStructure) );
            yourself)!   
partPropertyValidate: aPropertyStructure
    " Private - Validate the styles specified by the user.
        The receiver cannot have both the word wrap *AND* the horizontal
        scroll bar style enabled at the same time."
    | wordWrap horizontalScrollBar |
    wordWrap := (aPropertyStructure propertyAt: #wordWrapButton) value.
    horizontalScrollBar := (aPropertyStructure propertyAt: #horizontalScrollBarButton) value.
    (wordWrap and: [horizontalScrollBar] )
        ifTrue: [
            MessageBox
                notify: 'Invalid Property '
                withText: ' A TextPane cannot have Word wrap and Horizontal scrollbar styles at the same time.'.
            ^aPropertyStructure propertiesValid: false]! 
layoutAdjustmentFactor
        " Private - Adjustment necessary to fix layout in PARTS for Windows. "
    ^self
        partsIfOS2Do: [0]
        partsIfWindowsDo: [1/2]!
partDragTargetFormatsDefault
    "Private - answer the default drag formats."

    ^#('string').!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'Border'
            constant: WsPaneBorder ).
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #editContents );
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!
partEditDirect
        "Edit the directly visible part properties of the receiver."

    | editorClass iconOrBitmap initValue |
    iconOrBitmap := self partGetGraphics.
    initValue := iconOrBitmap clone.
    editorClass := ( iconOrBitmap isIcon
        ifTrue: [ PARTSIconEditor ]
        ifFalse: [ PARTSBitEditor ] ).
    editorClass new
        partWrapper: self partWrapper;
        openOn: initValue saveBlock: [
            self partSetGraphics: initValue.
            self partEditor
                recordUndo: ( Message new
                    receiver: self
                    selector: #partUndoDirectEdit:
                    arguments: (Array with: iconOrBitmap) )
                undoLabel: 'direct edit'
                redo: ( Message new
                    receiver: self
                    selector: #partRedoDirectEdit:
                    arguments: (Array with: initValue) )
                redoLabel: 'direct edit' ].! 
partFileInUpgradeLoaded: anObjectFiler
        " Private - finish upgrading subpanes from PARTS Workbench 2.0.
        Do some cleanup and optimization to get rid of unnecessary stuff. "

	super partFileInUpgradeLoaded: anObjectFiler.

    " drop obsolete properties"
    self propertyAt: #parts10 put: nil.!   
partPropertyEditPicture: aPropertyButton
        "Private - Bring up the editor for a picture field.
         Set the pictureMask and the datum of the picture field
         in the properties editor.  Store the new pictureMask and
        datum into the value of aPropertyButton (Edit Button... ). "
    | buttonDict newPictureMask newDatum pictureField |
    buttonDict := aPropertyButton newValue.
    newPictureMask := PARTSPictureMaskEditor new
        openOn: (buttonDict at: 'pictureMask') copy.
    newPictureMask isNil
        ifTrue: [^self].
    pictureField:= (aPropertyButton propertyStructure propertyAt: #contents) textEntryItem.
    newDatum:= pictureField contents.
    self setPictureMask: newPictureMask andValue: newDatum of: pictureField.
    aPropertyButton newValue: (Dictionary new
        at: 'pictureMask' put: newPictureMask copy;
        at: 'datum' put: pictureField value copy;
        yourself).!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Entry Field'!   
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [ self hasLabelChanged ]!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Drawn Button'!  
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
partPropertyAddContentsItem: aPropertyStructure
        " Private - add contents item to the property structure. "
    aPropertyStructure
        at: #contents putProperty: ( PARTSPropertyFormattedString new
             textEntryItem: ( self class new
                setTextLimit: self textLimit );
            value: self value;
            label: 'Contents:';
            changeSelector: #setValue: ;
            yourself ).!
partEditContents: currentContents properties: aPropertyStructure
        " Private - edit the part contents "
    ^(  self partEditTextContents: currentContents ) partsExceptionIfNil! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'List Pane'! 
partPropertyBeginApply: aPropertyStructure
        " Private - apply property changes to the receiver.
         Apply the text limit, decimal place and signed option
         change now so that it is done in time for the value to be applied. "
    self
        digits: (aPropertyStructure propertyAt: #textLimit) value;
        decimalPlace: (aPropertyStructure propertyAt: #decimalPlace) value;
        signed: (aPropertyStructure propertyAt: #signed) value.!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    anObjectFiler objectVersion < 12
        ifTrue: [ stretch := 1 ]. "Upgrade pre 3.1 graph pane to use stretching"
    ^super fileInUpgrade: anObjectFiler
!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected
        in the current system.  Answer the upgraded part.
        PW/OS2 2.0 DropDownList parts have to be
        distinguished from ComboBox parts and mutated
        into the new part class in PW 3.0. "

    | dropDownListClass aDropDownList |
    self textAttribute isNil ifTrue: [ self textAttribute: String new ].
    self partsIfWindowsDo: [ ^super fileInUpgrade: anObjectFiler ].
    self partsIfOS2Do: [
        self isDropDownList
            ifTrue: [
                super fileInUpgrade: anObjectFiler.  " get inherited stuff fixed up "
                dropDownListClass := PARTSDropDownListPart.
                #( #previousValue #modified ) do: [ :aComboBoxProperty |
                    self propertyAt: aComboBoxProperty put: nil ].
                " prune myself into a DropDownList "
                aDropDownList := dropDownListClass basicNew.
                1 to: dropDownListClass instSize do: [ :i |
                    aDropDownList instVarAt: i
                        put: ( self instVarAt: i ) ].
                ^aDropDownList ].
        ].
    ^super fileInUpgrade: anObjectFiler!  
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | propertyStructure |
    propertyStructure := PARTSPropertyStructure on: self.
    CanBeDefaultButton ifTrue: [propertyStructure
        putProperty: ( self partPropertyWindowStyle: 'Default button'
            constant: BsDefaultPushButton ) ].

    propertyStructure
        putProperty: #( #editGraphic );
        putProperty: #( #interface #sizeWindow ).
    ^propertyStructure!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    self
        partPropertyAddContentsItem: aPropertyStructure.
    self supportsMaxSizeItem
        ifTrue: [
            aPropertyStructure
                when: #aboutToEdit
                send: #partPropertyBeginApply: to: self with: aPropertyStructure.
            self partPropertyAddMaxSizeItem: aPropertyStructure].
    self
        partPropertyAddEmptyValueItem: aPropertyStructure;
        partPropertyAddStyleItems: aPropertyStructure;
        partPropertyAddConvertItem: aPropertyStructure;
        partPropertyAddAlignmentItem: aPropertyStructure;
        partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!
partPropertyMaxSizeLabel
        " Private - Return the label for the max size property. "
    ^ 'Maximum number of digits'!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelectorIfNotNil: #autoLabels: with: autoLabels;
        addSelectorIfNotNil: #defaultSize: with: defaultSize;
        addSelectorIfNotNil: #highDegree: with: highDegree;
        addSelectorIfNotNil: #highReading: with: highReading;
        addSelectorIfNotNil: #interval: with: interval;
        addSelectorIfNotNil: #lastChange: with: lastChange;
        addSelectorIfNotNil: #lowDegree: with: lowDegree;
        addSelectorIfNotNil: #lowReading: with: lowReading;
        addSelectorIfNotNil: #numberOfTicks: with: numberOfTicks;
        addSelectorIfNotNil: #setReading: with: reading;
        addSelectorIfNotNil: #ticks: with: ticks;
        addSelector: #setReadingsPerDegree! 
addTickGroup: topPane
    "Private - Add the tick group to the property editor. "
    | charSize entryHeight font anEntryField adjustment |

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.
    font := self font.
    adjustment := self layoutAdjustmentFactor.

    topPane addSubpane: (GroupBox new
        font: font;
        contents: 'Modify individual ticks';
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ 19) * charSize rounded)
                extentFromLeftTop: ((35 @ (7/2)) * charSize) rounded]).
    topPane addSubpane: (StaticText new
        font: font;
        contents: 'Tick:';
        framingBlock: [: box |
            (box leftTop rightAndDown: (3 @ 20 + adjustment) * charSize rounded )
                extentFromLeftTop: (4 @ (3/2) * charSize rounded)]).
    self addTickNumberItem: topPane.
    topPane addSubpane: (StaticText new
        font: font;
        contents: 'Length:';
        framingBlock: [: box |
            (box leftTop rightAndDown: (15 @ 20 + adjustment) * charSize rounded)
                extentFromLeftTop: (6 @ (3/2) * charSize rounded)]).
    topPane addSubpane: ((anEntryField := PARTSIntegerEntryFieldPart new)
        owner: self;
        setName: 'tickSize';
        when: #changed:
            send: #updateTickSize: to: self with: anEntryField;
        framingBlock: [: box |
            (box leftTop rightAndDown: (21 @ 20 + adjustment) * charSize rounded)
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (StaticText new
        font: font;
        contents: 'Text:';
        framingBlock: [: box |
            (box leftTop rightAndDown: (26 @ 20 + adjustment) * charSize rounded)
                extentFromLeftTop: (5 @ (3/2) * charSize rounded)]).
    topPane addSubpane: ((anEntryField := PARTSEntryFieldPart new)
        owner: self;
        setName: 'tickText';
        when: #changed:
        send: #updateTickText: to: self with: anEntryField;
        framingBlock: [: box |
            (box leftTop rightAndDown: ((30@20) + adjustment) * charSize rounded)
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Group Pane'!
partPropertySetStyle: newStyle
        "Private - Change the style of the receiver to newStyle."
    ^super partPropertySetStyle: (
        (newStyle bitAnd: SsLeftAlignedText) > 0
            ifTrue: [newStyle]
            ifFalse: [
                (self hasStyle: SsLeftAlignedTextNoWordWrap)
                    ifTrue: [
                        newStyle bitAnd: (SsLeftAlignedTextNoWordWrap bitXor: 16rFFFFFFFF)]
                    ifFalse: [newStyle]])! 
partPropertySelectFont: aPropertyUnit
        " Private - Bring up the FontDialog and set the font of the receiver. "

    | oldFont selectedFont partProperties |
    oldFont := self font.
	selectedFont := FontDialog new
		sampleFont: oldFont;
		open;
		chosen.

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
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Radio Button'!  
partPropertyAddEmptyValueItem: aPropertyStructure
        " Private - add an empty value item to the property structure. "
    | emptyValueMap initialSelection |
    emptyValueMap := Array
        with: #( 'empty string' '' )
        with: (Array with: 'null' with: nil).
    initialSelection := ( (self emptyValue isString)
        ifTrue: [1]
        ifFalse: [2] ).
    aPropertyStructure
        putProperty: ( PARTSPropertyButtonGroup new
            label: 'Value when empty ';
            changeSelector: #emptyValue: ;
            labelsMap: emptyValueMap;
            initialSelection: initialSelection );
        yourself!   
partPropertyAddContentsItem: aPropertyStructure
        " Private - add contents item to the property structure. "
    aPropertyStructure
        at: #contents putProperty: ( PARTSPropertyFormattedString new
            textEntryItem: (self class new
                decimalPlace: self decimalPlace;
                signed: self signed;
                digits: self digits );
            value: self value;
            label: 'Contents:';
            changeSelector: #setValue: ;
            yourself ).!   
cleanUpTicksDirectory
        "Private - Remove keys out of the ticks directory if its value is empty."
    |array keysToRemove |
    (ticks size > 0)
        ifTrue: [
            keysToRemove:= OrderedCollection new.
            ticks associationsDo: [:assoc |
                array:= assoc value.
                ( (((array at: 1) isNumber) not) and: [(array at: 2) size = 0])
                    ifTrue: [keysToRemove add: assoc key]].
            (keysToRemove size > 0)
                ifTrue: [
                    keysToRemove do: [:key | ticks removeKey: key]].
                    ].!   
addIntervalGroup: topPane
        " Private - Add the group titled Modify ticks by interval "
    | charSize entryHeight font adjustment|

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.
    font := self font.
    adjustment:= self layoutAdjustmentFactor.

    topPane addSubpane: (GroupBox new
        font: font;
        contents: 'Modify ticks by interval';
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ 14) * charSize rounded)
                extentFromLeftTop: ((35 @ (9/2)) * charSize) rounded]).
    topPane addSubpane: (StaticText new
        font: font;
        contents: 'Tick interval:';
        framingBlock: [: box |
            (box leftTop rightAndDown: (3 @ 15 + adjustment * charSize rounded))
                extentFromLeftTop: (10 @ (3/2) * charSize rounded)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'interval';
        contents: ((dialParameters at: 'tickInterval') at: 1);
        framingBlock: [: box |
            (box leftTop rightAndDown: (14 @ 15  + adjustment  * charSize rounded))
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (StaticText new
        font: font;
        contents: 'Tick length:';
        framingBlock: [: box |
            (box leftTop rightAndDown: (20 @15  + adjustment * charSize rounded))
                extentFromLeftTop: (10 @ (3/2) * charSize rounded)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'intervalSize';
        contents: ((dialParameters at: 'tickInterval') at: 2);
        framingBlock: [: box |
            (box leftTop rightAndDown: (30 @ 15  + adjustment  * charSize rounded))
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (CheckBox new
        owner: self;
        font: font;
        value: (dialParameters at: 'autoLabels' );
        contents: 'Automatic labels';
        setName: 'autoLabels';
        framingBlock: [: box |
            (box leftTop rightAndDown: (3 @ 17 * charSize) rounded)
                extentFromLeftTop: (20 @ 1 * charSize rounded)])!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | bitmap |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    bitmap := self bitmapIfAbsent: [ nil ].
    anExpressionModel
        addSelectorIfNotNil: #bitmap: with: bitmap;
        addSelector: #stretch: with: stretch!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure:= PARTSPropertyStructure on: self.
    self
        partPropertyAddContentsItem: aPropertyStructure;
        partPropertyAddAlignmentItem: aPropertyStructure;
        partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
partPropertyEditGraphic: aPropertyUnit
        " Private - edit graphic property button handler "

    | iconOrBitmap isIcon initValue propertyStructure |

    propertyStructure := aPropertyUnit propertyStructure.
    isIcon := ( self supportsBothBitmapAndIcon
        ifTrue: [ (propertyStructure propertyAt: #bitmapOrIcon)
            controls first value not ]
        ifFalse: [true] ).  " only icon style supported "
    iconOrBitmap := self partGetGraphics.
    initValue := iconOrBitmap clone.

    isIcon
        ifTrue: [
            iconOrBitmap isIcon ifFalse: [
                initValue := PARTSIcon fromBitmap: iconOrBitmap].
            PARTSIconEditor new
                partWrapper: self partWrapper;
                openOn: initValue saveBlock: [
                    propertyStructure dialogWindow isNil
                        ifTrue: [MessageBox message:
    'The properties editor is closed.  Changes cannot be applied.']
                        ifFalse: [
                            propertyStructure
                                addAction: (Message new
                                    receiver: self;
                                    selector: #partSetGraphics:;
                                    arguments: (Array with: initValue))
                                undo: (Message new
                                    receiver: self
                                    selector: #partSetGraphics:
                                    arguments: (Array with: iconOrBitmap) )]]]
        ifFalse: [
            iconOrBitmap isIcon ifTrue: [
                initValue := iconOrBitmap colorBitmap clone].
            PARTSBitEditor new
                partWrapper: self partWrapper;
                openOn: initValue saveBlock: [
                    propertyStructure dialogWindow isNil
                        ifTrue: [MessageBox message:
    'The properties editor is closed.  Changes cannot be applied.']
                        ifFalse: [
                            propertyStructure
                                addAction: (Message new
                                    receiver: self;
                                    selector: #partSetGraphics:;
                                    arguments: (Array with: initValue))
                                undo: (Message new
                                    receiver: self
                                    selector: #partSetGraphics:
                                    arguments: (Array with: iconOrBitmap) )]]].!  
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."
    self partsVwOnly.
    self partIsEditing ifTrue: [ ^HtClient ].
    ^nil! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Phone Number Entry Field'!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Date Entry Field'!  
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. The NoBorder style is supported
        on OS/2, but not on Windows. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyString new
            value: self contents;
            label: 'Label:';
            changeSelector: #partSetDirectEditValue: ;
            validationMessage: #partPropertyDirectEditValueIsValid: );
        putProperty: ( self partPropertyWindowStyle: 'Default button'
            constant: BsDefaultPushButton ).
    SupportsBorder
        ifTrue: [aPropertyStructure
            putProperty: ( PARTSPropertyPseudoStyle new
                value: (self hasStyle: BsNoBorder) not;
                label: 'Border';
                changeSelector: #partAddBorder: ) ].
    self "Cannot set color in Windows."
        partsIfOS2Do: [ self partPropertyAddColorAndFont: aPropertyStructure. ]
        partsIfWindowsDo: [ aPropertyStructure putProperty: #(#setFont) ].
    aPropertyStructure putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!
partDragTargetFormatsDefault
    "Private - answer the default drag formats."

    ^#('object' 'string').! 
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | bitmap initValue undo |
    bitmap := self bitmap.
    undo := bitmap.
    initValue := bitmap clone.
    PARTSBitEditor new
        partWrapper: self partWrapper;
        openOn: initValue saveBlock: [
            self partSetGraphics: initValue.
            self partEditor
                recordUndo: ( Message new
                    receiver: self
                    selector: #partUndoDirectEdit:
                    arguments: (Array with: undo) )
                undoLabel: 'direct edit'
                redo: ( Message new
                    receiver: self
                    selector: #partRedoDirectEdit:
                    arguments: (Array with: initValue) )
                redoLabel: 'direct edit' ]! 
partGetGraphics
    ^self bitmapIfAbsent: [ Bitmap screenExtent: self extent ]!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Drop Down List'!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel addSelectorIfNotNil: #datum: with: self datum! 
partPropertyApplyEdit: aPropertyStructure
    " Private - Save the contents of Contents: field into the value
      of editButton, so that the new datum may be applied to the receiver. "
    | contentsField editButton dict|
    contentsField := (aPropertyStructure propertyAt: #contents) textEntryItem.
    contentsField modified
        ifTrue: [contentsField value: contentsField contents].
    editButton := aPropertyStructure propertyAt: #editButton .
    dict := editButton newValue copy.
    editButton newValue: (Dictionary new
        at: 'datum' put: contentsField value copy;
        at: 'pictureMask' put: (dict at: 'pictureMask') copy;
        yourself ).!  
wmHittest: mp1 with: mp2
        "Private - Process mouse hit test message."

    self partsVosOnly.  " only used on Win32 "
    self partIsEditing ifTrue: [
        PARTSEditor currentDragHandler == #excludeGroupBox
            ifTrue: [ ^TransparentToMouse ]
            ifFalse: [
                PARTSEditor currentDragHandler == #includeGroupBox
                    ifTrue: [ ^0	"HtNormal" ] ] ].
    ^nil! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Formatted Entry Field'! 
partGetGraphics
        " Private - Answer the receiver's icon or bitmap."
    ^self value! 
openOn: aString
        " Open a dialog to let the user edit the picture field mask."
    ( self openModalDialog: 'DialogWindow1' on: aString ) isNil
        ifTrue: [ ^nil ].  " couldn't get the dialog open "
    ^(self partNamed: 'Answer') value!  
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    self
        partPropertyAddContentsItem: aPropertyStructure.
    self supportsMaxSizeItem
        ifTrue: [
            aPropertyStructure
                when: #aboutToEdit
                send: #partPropertyBeginApply: to: self with: aPropertyStructure.
            self partPropertyAddMaxSizeItem: aPropertyStructure ].
    self
        partPropertyAddDecimalDigitsItem: aPropertyStructure;
        partPropertyAddSignedItem: aPropertyStructure;
        partPropertyAddEmptyValueItem: aPropertyStructure;
        partPropertyAddStyleItems: aPropertyStructure;
        partPropertyAddConvertItem: aPropertyStructure;
        partPropertyAddAlignmentItem: aPropertyStructure;
        partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!
partPropertyBeginApply: aPropertyStructure
        " Private - apply property changes to the receiver.
         Apply the date format change now so that it is done in time for
        the new value to be applied. "
    | dateFormatProperty |
    dateFormatProperty := aPropertyStructure propertyAt: #dateFormat.
    self dateFormatProperties: dateFormatProperty newValue.!
partPropertySetNewMaxSize: anInteger to: aPropertyUnit
    " Private - set the new text limit to the property. "
    aPropertyUnit
        textLimit: anInteger;
        setTextLimit: self unformattedTextLimit! 
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup."
    dial partCodeGenerated: anApplicationBuilder.
    ^super partCodeGenerated: anApplicationBuilder!  
partPropertySetStyle: newStyle
        "Private - Change the style of the receiver to newStyle."
    (newStyle bitAnd: CbsDropDownList) = CbsDropDownList
            ifTrue: [
            "self ASSERT: false."  " Shouldn't get here now that DropDown
                list is factored out into its own class, right? [DJL 15-Jun-93] "
            ^super partPropertySetStyle: newStyle ].
    super partPropertySetStyle: (
        (newStyle bitAnd: CbsVisibleComboBox) > 0
            ifTrue: [(newStyle bitOr: CbsDropDownComboBox) bitXor: CbsDropDownComboBox]
            ifFalse: [newStyle bitOr: CbsDropDownComboBox] ).! 
partPropertyMaxSizeErrorMessage
        " Private - a max size error has been detected. Pop-up a MessageBox. "
    ^MessageBox warning:
        self partPropertyMaxSizeLabel ,
        ' needs to be greater than 0.' .! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Picture Entry Field'!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Text Pane'! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    " emptyValue new for PWO in 3.0; fix PWO 2.0 color "
    ( #( 6 5 ) includes: anObjectFiler objectVersion )
        ifTrue: [ 
            self emptyValue: self defaultEmptyValue.
            "anObjectFiler
                when: #loaded
                 send: #partUpgradeIndexColorsToRGB to: self" ].
    ^super fileInUpgrade: anObjectFiler!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |

    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        when: #aboutToAcceptChanges:
            send: #partPropertyValidate: to: self;
        at: #wordWrapButton putProperty: ( PARTSPropertyPseudoStyle new
            value: self isWordWrapEnabled;
            label: 'Word wrap';
            changeSelector: #wordWrap: );
        putProperty: ( self partPropertyWindowStyle: 'Read only'
            constant: MlsReadOnly );
        putProperty: ( self partPropertyWindowStyle: 'Border'
            constant: MlsBorder );
        putProperty: ( self partPropertyWindowStyle: 'Vertical scroll bar'
            constant: MlsVerticalScrollBar );
        at: #horizontalScrollBarButton putProperty: ( self partPropertyWindowStyle: 'Horizontal scroll bar'
            constant: MlsHorizontalScrollBar );
        yourself.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #editContents ).
    aPropertyStructure
        putProperty: (PARTSPropertyDragDrop new makeSameLine).
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #decimalPlace: with: self decimalPlace;
        addSelectorIfNotNil: #digits: with: self digits;
        addSelectorIfNotNil: #signed: with: self signed
!
partDragTargetOperationsDefault
    "Private - answer the default drag operations for the receiver."

    ^#(#move #copy).!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "
    self partsIfWindowsDo: [  " synch with PW 3.0 initialize "
        digits isNil ifTrue: [ digits := self defaultTextLimit ].
        signed isNil ifTrue: [ signed := true ].
        ].
    ^super fileInUpgrade: anObjectFiler!  
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | undo initValue |
    undo := bitmap.
    initValue := bitmap clone.
    PARTSBitEditor new
        partWrapper: self partWrapper;
        openOn: initValue saveBlock: [
            self partSetGraphics: initValue.
            self partEditor
                recordUndo: (Message new
                    receiver: self
                    selector: #partSetGraphics:
                    arguments: (Array with: undo))
                undoLabel: 'direct edit'
                redo: (Message new
                    receiver: self
                    selector: #partSetGraphics:
                    arguments: (Array with: initValue))
                redoLabel: 'direct edit']!   
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyBinaryStyle new
            value: (self hasStyle: CbsVisibleComboBox );
            label: 'List box always visible';
            constant: CbsVisibleComboBox;
            constant2: CbsDropDownComboBox ).
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #editContents ).
    aPropertyStructure
        putProperty: (PARTSPropertyDragDrop new makeSameLine).
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
partPropertyAddSignedItem: aPropertyStructure
    "Private - add a checkbox which allows users to set if they want the receiver
     to be signed or not.  If it is signed, then the user can type in the + or - minus
     sign in the receiver in the beginning of the input."
    aPropertyStructure
        at: #signed putProperty: ( PARTSPropertyBoolean new
            value: self signed;
            label: 'Signed' ;
            immediateValidationMessage: (Message
                receiver: self
                selector: #partPropertySignedChanged:
                arguments: (Array with: aPropertyStructure) );
            yourself)! 
partApplicableStylePrefixes
    ^#('Es')!
partPropertyDecimalPlaceChanged: aPropertyStructure
        " Private - the decimal place  property was just changed.
           Set the decimalPlace of the contents field. "
    | newDecimalPlace contentsProperty |
    newDecimalPlace := (aPropertyStructure propertyAt: #decimalPlace) value.
    contentsProperty := aPropertyStructure propertyAt: #contents.
    contentsProperty textEntryItem
        decimalPlace: newDecimalPlace;
        modified: true.
    ^true!  
partPropertyAddAlignmentItem: aPropertyStructure
        " Private "
    aPropertyStructure
         putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Alignment';
            labelsMap: StyleLabels;
            initialSelection: (self partPropertiesIndexOf: StyleValues) ).!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Float Entry Field'! 
partPropertyAddAlignmentItem: aPropertyStructure
        " Private - add alignment item to the property structure.
        Picture fields are always left-aligned. "!   
openOn: aDictionary
        "Private "
    dialParameters := aDictionary.
    ticks := (dialParameters at: 'ticks') deepCopy.
    ticks isNil
        ifTrue: [ticks := IdentityDictionary new].
    answer := PARTSException new.
    self
        createView;
        openWindow.
    ^answer!
partPropertyAddMaxSizeItem: aPropertyStructure
        " Private - add max size item to the property structure. "
    aPropertyStructure
        at: #textLimit putProperty: ( PARTSPropertyNumber new
            value: self digits;
            label: self partPropertyMaxSizeLabel, ':' ;
            immediateValidationMessage: (Message
                receiver: self
                selector: #partPropertyMaxSizeChanged:
                arguments: (Array with: aPropertyStructure) );
            yourself )!
partPropertySignedChanged: aPropertyStructure
        " Private - the signed  property was just changed.
           Set the signed option of the contents field. "
    | newSigned contentsProperty |
    newSigned := (aPropertyStructure propertyAt: #signed) value.
    contentsProperty := aPropertyStructure propertyAt: #contents.
    contentsProperty textEntryItem
        signed: newSigned;
        modified: true.
    ^true!
partPropertyAddContentsItem: aPropertyStructure
        " Private - add contents item to the property structure. "
    aPropertyStructure
        at: #contents putProperty: ( PARTSPropertyFormattedString new
            textEntryItem: (self class new
                dateSeparator: self dateSeparator;
                dateFormat: self dateFormat;
                twoDigitYear:  self twoDigitYear;
                useSystemFormat:  self useSystemFormat );
            value: self value;
            label: 'Contents:';
            changeSelector: #setValue: ;
            yourself ).!   
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'Horizontal scroll bar'
            constant: LbsHorizontalScrollBar ).
    self class supportsShowDisabledScrollbarStyle ifTrue: [
        "This is crowbarred in the middle here to preserve the screen layout so we don't
        have to redo screen shots"
        aPropertyStructure putProperty: ( self partPropertyWindowStyle: 'Show disabled scroll bar'
            constant: LbsDisableNoScroll )
    ].
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'No adjust height'
            constant: LbsNoIntegralHeight );
        yourself.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #editContents ).
    aPropertyStructure
        putProperty: (PARTSPropertyDragDrop new makeSameLine).
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | propertyStructure |
    propertyStructure := PARTSPropertyStructure on: self.
    self supportsBothBitmapAndIcon
        ifTrue: [
            propertyStructure at: #bitmapOrIcon
                putProperty: ( PARTSPropertyButtonGroupWS new
                label: nil;
                labelsMap: StyleLabels;
                initialSelection: (self partPropertiesIndexOf: StyleValues) ) ].
    propertyStructure
        putProperty: #( #editGraphic );
        putProperty: #( #interface #sizeWindow ).
    ^propertyStructure!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setLabel: with: self label! 
partPropertyAddDecimalDigitsItem: aPropertyStructure
    "Private - add a decimal digits entry field.
    Not supported by currency field.  The decimal place for
     a currency field is always set to the system settings.  See
     the method decimalPace. "!
partPropertyAddMaxSizeItem: aPropertyStructure
        " Private - add max size item to the property structure. "
    aPropertyStructure
        at: #textLimit putProperty: ( PARTSPropertyNumber new
            value: self textLimit;
            label: self partPropertyMaxSizeLabel, ':' ;
            immediateValidationMessage: (Message
                receiver: self
                selector: #partPropertyMaxSizeChanged:
                arguments: (Array with: aPropertyStructure) );
            yourself )! 
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'PPGrpPan.par'! 
partPropertyMaxSizeChanged: aPropertyStructure
        " Private - the text limit property was just changed.
           Set the text limit of the contents field. "
    | textLimitProperty newTextLimit contentsProperty |
   textLimitProperty := ( aPropertyStructure propertyAt: #textLimit ) textEntryItem.
    textLimitProperty modified ifFalse: [^false].
    textLimitProperty validateSizeAndFormatOfInput
        ifTrue: [
            newTextLimit:= textLimitProperty contents asInteger.
            ( newTextLimit <= 0 )
                ifTrue: [
                    self partPropertyMaxSizeErrorMessage.
                    ^false ]
                ifFalse: [
                    textLimitProperty value: textLimitProperty contents .
                    contentsProperty := ( aPropertyStructure propertyAt: #contents ) textEntryItem.
                    contentsProperty
                        partPropertySetNewMaxSize: newTextLimit to: contentsProperty;
                        modified: true.
                    ^true ]]
        ifFalse: [
            MessageBox warning:
                        'Invalid input in max size field.'.
            ^false ]!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Static Text'!   
partDragTargetOperationsDefault
    "Private - answer the default drag operations for the receiver."

    ^#(#move #copy).!
hasLabelChanged
        " Private - answer whether the DLL name property has been changed. "

    ^self isNewString: self labelEntryField value differentFrom: self  partLabel!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'Horizontal scroll bar'
            constant: LbsHorizontalScrollBar ).
    self class supportsShowDisabledScrollbarStyle ifTrue: [
        "This is crowbarred in the middle here to preserve the screen layout so we don't
        have to redo screen shots"
        aPropertyStructure putProperty: ( self partPropertyWindowStyle: 'Show disabled scroll bar'
            constant: LbsDisableNoScroll )
    ].
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'No adjust height'
            constant: LbsNoIntegralHeight );
        yourself.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #editContents ).
    aPropertyStructure
        putProperty: (PARTSPropertyDragDrop new makeSameLine).
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
fileName
        " Private - answer the file containing the PARTS
        window definition. "

    ^'PictEdit.par'!  
createView
        " Private - create the dialog window "
    | charSize entryHeight font topPane  |

    charSize := WindowDialog unitMultiplier.
    entryHeight := WindowDialog entryHeight.
    font := self font.

    self addView: ((topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: (self dialogTitle: 'DialPane' modifier: 'Edit');
        yourself ).
    self
        addRangeGroup: topPane;
        addAngleGroup: topPane.
    topPane addSubpane: (StaticText new
        rightJustified;
        font: font;
        contents: 'Number of ticks:';
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ (17/2) * charSize)rounded)
                extentFromLeftTop: (28 * charSize x @ entryHeight)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'ticks';
        value: (dialParameters at: 'numberOfTicks');
        "when: #textChanged send: #updateTicks to: self;"
            " disable event handler, doesn't do anything [DJL 21-Jun-93] "
        framingBlock: [: box |
            (box leftTop rightAndDown: (31 @ (17/2) * charSize) rounded)
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (StaticText new
        rightJustified;
        font: font;
        contents: 'Default tick length (pels):';
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ (21/2) * charSize) rounded)
                extentFromLeftTop: (28 * charSize x @ entryHeight)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'defaultSize';
        value: (dialParameters at: 'defaultSize');
        framingBlock: [: box |
            (box leftTop rightAndDown: (31 @ (21/2) * charSize) rounded)
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    topPane addSubpane: (StaticText new
        font: font;
        rightJustified;
        contents: 'Initial setting (ticks):';
        framingBlock: [: box |
            (box leftTop rightAndDown: (2 @ (25/2) * charSize) rounded)
                extentFromLeftTop: (28 * charSize x @ entryHeight)]).
    topPane addSubpane: (PARTSIntegerEntryFieldPart new
        owner: self;
        setName: 'initSetting';
        value: (dialParameters at: 'initSetting');
        framingBlock: [: box |
            (box leftTop rightAndDown: (31 @ (25/2) * charSize) rounded)
                extentFromLeftTop: (5 * charSize x @ entryHeight)]).
    self
        addIntervalGroup: topPane;
        addTickGroup: topPane.
    topPane addSubpane: (Button new
        defaultPushButton;
        font: font;
        contents: 'OK';
        when: #clicked send: #ok to: self;
        framingBlock: [: box |
            (box leftBottom rightAndUp: (2 @ 2 * charSize))
                extentFromLeftTop: (10 * charSize x @ entryHeight)]).
    topPane addSubpane: (Button new
        font: font;
        contents: 'Cancel';
        when: #clicked send: #cancel to: self;
        framingBlock: [: box |
            (box leftBottom rightAndUp: (13 @ 2 * charSize))
                extentFromLeftTop: (10 * charSize x @ entryHeight)]).!   
partDragTargetOperationsDefault
    "Private - answer the default drag operations for the receiver."

    ^#(#move #copy).!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Numeric Entry Field'!   
partApplicableStylePrefixes
    ^#()!
partPropertyMaxSizeErrorMessage
        " Private - a max size error has been detected. Pop-up a MessageBox. "
    ^MessageBox warning:
        'Maximum number of digits cannot be empty
or less than or equal to 0.'!   
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."

    self partsVwOnly.  " only used on Win32 "
    self partIsEditing ifTrue: [
        PARTSEditor currentDragHandler == #excludeGroupBox
            ifTrue: [ ^TransparentToMouse ]
            ifFalse: [
                PARTSEditor currentDragHandler == #includeGroupBox
                    ifTrue: [ ^HtClient ] ] ].
    ^nil!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Currency Entry Field'!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #dateFormat: with: self dateFormat;
        addSelectorIfNotNil: #dateSeparator: with: self dateSeparator;
        addSelectorIfNotNil: #twoDigitYear: with: self twoDigitYear;
        addSelectorIfNotNil: #useSystemFormat: with: self useSystemFormat
!  
partPropertyAddEmptyValueItem: aPropertyStructure
        " Private - add an empty value item to the property structure.
          Not supported by numeric type formatted entry fields. "! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #dial: with: dial!   
partApplicableStylePrefixes
    ^#('Mls')!   
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
    PARTSGroupPanePropertiesEditor new openOn: self.!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: ( PARTSPropertyString new
            value: self contents;
            label: 'Label:';
            changeSelector: #partSetDirectEditValue: ;
            validationMessage: #partPropertyDirectEditValueIsValid: );
         putProperty: ( PARTSPropertyBinaryStyle new
            value: (self hasStyle: BsAutoCheckBox);
            label: 'Auto check box';
            changeSelector: nil;
            constant: BsAutoCheckBox;
            constant2: BsCheckBox );
           yourself.
    SupportsLabelLeftOfButton
        ifTrue: [
            aPropertyStructure
                putProperty: ( self partPropertyWindowStyle: 'Label left of check box'
                    constant: BsLeftAlignedText ) ].
    aPropertyStructure
        putProperty: ( PARTSPropertyBoolean new
            value: self value;
            label: 'Initially on';
            changeSelector: #value: );
        yourself.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Check Box'!