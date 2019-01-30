3.1.0.106
   
setFontRow
        "Private - set the font of the selected row."
    | newFont |
    newFont := self getFont: selectedRowAttributes font.
    newFont notNil ifTrue: [
        selectedRowAttributes font: newFont.
        self rowAttributesChanged.
        self rowsDefaultColorsAndFontButton enable ]!   
width
		" Private "
    ^WindowDialog entryHeight * 20! 
columnsTypeDropDownList
		"Private - answer the columns type drop down list."
	^self paneAt: 'ColumnsTypeDropDownList'! 
indexedColumnsNot: aRadioButton
		" Private "
    self addChangeMessage: ( Message new
        receiver: tablePane
        selector: #propertyIndexedColumns:
        arguments: ( Array with: aRadioButton value not ))!
clientAreaTop
	| rect |
	rect := 0@0 extent: self initWindowSize.
	^rect top!  
oldColumnAttributes: aDictionary
        "Private - set the old column attributes.  These are the attributes
        that will take affect when the user undoes previously set attributes."
    oldColumnAttributes := aDictionary!
getColor: currentColor
        "Private - pop up the color dialog with currentColor selected
		and answer the color the user selected or nil if cancelled."
	^( ColorDialog new
        color: currentColor;
        open ) chosen!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^280!  
columnsDefaultColorsAndFontButton
        "Private - answer the columns default colors and font check box."
    ^self paneAt: 'ColumnsDefaultColorsAndFont'!
rowsDefaultColorsAndFontButton
        "Private - answer the rows default colors and font check box."
    ^self paneAt: 'RowsDefaultColorsAndFont'! 
columnsWidthEntryField
        "Private - answer the columns width entry field."
    ^self paneAt: 'ColumnsDimensionEntryField'!
rowsListBox 
		"Private - answer the rows list box."
	^self paneAt: 'RowsListBox'!  
aboutToChangeRow
        "Private - the user selected a new row from the list box.
        Gather the input from the entry fields."
    selectedRowAttributes isNil ifTrue: [ ^self ].
    self canChangeRow ifFalse: [ ^self abortChangeRow ].
    self rowsLabelEntryField modified ifTrue: [
        self setLabelRow: self rowsLabelEntryField value ].
    self rowsNameEntryField modified ifTrue: [
        self setNameRow: self rowsNameEntryField value ].
    self rowsHeightEntryField modified ifTrue: [
        self setDimensionRow: self rowsHeightEntryField value ]!  
addChangeMessage: aMessage
		"Private - add a change message."
	changeMessages add: aMessage!   
setReadOnlyRow
        "Private - set the selected row's read only attribute."
    selectedRowAttributes readOnly: self rowsReadOnlyCheckBox value.
    self rowAttributesChanged! 
setModified
        "Private - mark the receiver as being modified."
    modified := true!  
columnsForeColorButton
		"Private - answer the columns fore color button."
	^self paneAt: 'ColumnsForeColorButton'! 
setTypeRow: aString
        "Private - set the selected row's type."
    self setType: selectedRowAttributes with: aString.
    self rowAttributesChanged! 
setType: anAttributes with: aString
        "Private - set anAttributes's type."
    | type |
    columnRowTypeInfo do: [ :a |
        aString = a first ifTrue: [ type := a last ]].
    type isNil ifTrue: [ self error: ' unknown cell editor type' ].
    anAttributes type: type.
    self setModified!   
gapY
		"Private"
    ^WindowDialog dialogUnit x // 4!   
setTypeColumn: aString
        "Private - set the selected column's type."
    self setType: selectedColumnAttributes with: aString.
	self columnAttributesChanged!
rowAttributesChanged
        "Private - the selected row attributes have been
        changed.  Store them in the dictionary that will be used
        to update the table pane."
    rowAttributes at: currentRow put: selectedRowAttributes.
    self setModified! 
namedRows: aRadioButton
		" Private "
    newValue at: #indexedRows put: aRadioButton selection not.
    self setModified: true.!  
checkBoxesTopOffset
        "Private - answer the distance from the top of the receiver's
		rectangle and the top of the top most check box."
    ^self accessGroupBoxTopOffset + self accessGroupBoxExtent y + self gapY! 
indexedRowsNot: aRadioButton
		" Private "
    self addChangeMessage: ( Message new
        receiver: tablePane
        selector: #propertyIndexedRows:
        arguments: ( Array with: aRadioButton value not ))!  
rowAttributesFor: anInteger
        "Private - answer the row attributes for anInteger."
    | attributes |
    attributes := self getRowAttributesFor: anInteger.
    originalRowAttributes at: anInteger put: attributes copy.
    ^attributes!
oldRowAttributes
        "Private - answer the old row attributes.  These are the attributes
        that will take affect when the user undoes previously set attributes."
    ^oldRowAttributes! 
setNameColumn: aString
        "Private - set the selected columns's name."
    selectedColumnAttributes name: aString.
	self columnAttributesChanged! 
radioFrameFor: i with: j
        "Private - anwer the framing block for a radio button.
		If i = 1, then it is a left column radio button.  If j = 1,
		then it is a top radio button."
	| groupFrame |
	^[ :b |
		groupFrame := ( self groupFrameFor: i ) value: b.
		( groupFrame leftTop rightAndDown: self gapY @ ( self entryFieldHeight * j ))
			extentFromLeftTop: self radioButtonExtent ]!  
columnsFontButton
		"Private - answer the columns font button."
	^self paneAt: 'ColumnsFontButton'! 
initialize
        "Private - initialize the receiver."
    changeMessages := OrderedCollection new.
    undoMessages := OrderedCollection new.
    newColumnAttributes := Dictionary new.
    newRowAttributes := Dictionary new.
    oldColumnAttributes := Dictionary new.
    oldRowAttributes := Dictionary new.
    ^super initialize!  
createColumnItems
	| rect initWindowSize |
	initWindowSize := self initWindowSize.
	rect := 0 @ self clientAreaTop rightBottom:
		( initWindowSize x // 2 ) @ self clientAreaBottom.
	self createItemsTitled: 'Columns' in: rect!
rowsHeightEntryField
        "Private - answer the rows height entry field."
    ^self paneAt: 'RowsDimensionEntryField'!   
columnAttributesFor: anInteger
        "Private - answer the column attributes for anInteger."
    | attributes |
    attributes := self getColumnAttributesFor: anInteger.
    originalColumnAttributes at: anInteger put: attributes copy.
    ^attributes!
rowsFontButton
		"Private - answer the rows font button."
	^self paneAt: 'RowsFontButton'!  
booleanAttribute: aSymbol from: aCheckBox
		"Private - aCheckBox's value has change.  Add
		a change message."
	self addChangeMessage: ( Message new
		receiver: tablePane
		selector: ( aSymbol, ':' ) asSymbol
		arguments: ( Array with: aCheckBox value ))! 
updateFixedRows: numberOfRows
        " Private - the value in the entry field has changed. "
    numberOfRows > 0
        ifTrue: [
            newValue at: #fixedRows put: numberOfRows.
            self setModified: true ]!
type: aSymbol
		"Private - set the receiver's type."
	type := aSymbol!  
partPropertyEditContents: aPropertyUnit
        " Private - Edit contents property button handler. "
    self partPropertyEditRowColumnAttributes: aPropertyUnit propertyStructure! 
setBackColorRow
        "Private - set the back color of the selected row."
    | newColor |
    newColor := self getColor: selectedRowAttributes backColor.
    newColor notNil ifTrue: [
        selectedRowAttributes backColor: newColor.
        self rowAttributesChanged.
        self rowsDefaultColorsAndFontButton enable ]! 
fixedRows: aBoolean
        "Private - The fixed dimension check box has been clicked.
         Enable/disable the row and column entry fields."
    aBoolean
        ifTrue: [(idMap at: #numberRows) enable]
        ifFalse: [(idMap at: #numberRows) disable].
    self setModified: true.! 
columnsLabelEntryField
		"Private - answer the columns label entry field."
	^self paneAt: 'ColumnsLabelEntryField'! 
columnsReadOnlyCheckBox
		"Private - answer the columns read only check box."
	^self paneAt: 'ColumnsReadOnlyCheckBox'! 
undoChanges
        " Private - reset the value if it has been changed. "
    self shouldApplyChange ifTrue: [
        undoMessages do: [ :message |
            message receiver isNil ifTrue: [
                message receiver: tablePane ].
            message evaluate ] ].
    oldColumnAttributes size > 0 ifTrue: [
        tablePane propertyUpdateColumnAttributes: oldColumnAttributes ].
    oldRowAttributes size > 0 ifTrue: [
        tablePane propertyUpdateRowAttributes: oldRowAttributes ].
    tablePane propertiesHaveChanged.!
staticTextExtentIn: aRectangle
        "Private - answer the extent of the receiver's static texts."
    | width |
    width := aRectangle width // 2
        - self numberFieldExtent x
            - self labelEntryFieldGap
                - ( self gapY * 6 ).
    ^width @ self entryFieldFrameHeight!   
type
        "Private - answer the receiver's type."
    ^type! 
foreColor
        "Private - answer the receiver's foreColor."
    ^foreColor!  
abortChangeColumn
        "Private - abort the users attempted change of
        the selected column."
    ^self columnsListBox abortChange!   
idMap
		" Private "
    ^idMap! 
indexedColumns: aRadioButton
		" Private "
    self addChangeMessage: ( Message new
        receiver: tablePane
        selector: #propertyIndexedColumns:
        arguments: ( Array with: aRadioButton value ))!   
windowOpened
        "Private - the window has just been opened."
    self columnsListBox contents: ( tablePane columnNumbers collect: [ :n | n asString ] ).
    self rowsListBox contents: ( tablePane rowNumbers collect: [ :n | n asString ] )!
clientAreaBottom
	| rect |
	rect := 0@0 extent: self initWindowSize.
	^rect bottom up: WindowDialog entryHeight * 2!   
leftEntryFrameFor: anInteger
        "Private - answer the framing block for entry field number anInteger."
    | leftTopX leftTopY |
    ^[ :b |
        leftTopX := b center x left: self numberFieldExtent x.
        leftTopY := b top down: ( self entryFrameTopOffsetFor: anInteger ).
        leftTopY := leftTopY down: leftTop y.
        leftTopX @ leftTopY extentFromLeftTop: self numberFieldFrameExtent ]!   
setDefaultColorsAndFontRow
        "Private - the user has clicked on the button that means
        use default colors and font for the selected row."
    self rowsDefaultColorsAndFontButton disable.
    selectedRowAttributes setDefaultColorsAndFont.
    self rowAttributesChanged!
newRowAttributes
        "Private - answer the new row attributes.  These are the attributes
        that will take affect when the user clicks OK on the properties
        dialog."
    ^newRowAttributes!  
extendedEditorClass
        "Private - answer the class of extended editors."
    ^PARTSTableCellExtendedTextEditor!
currentColumnNumber
        "Private - answer the currently selected column number."
	^self columnsListBox selectedIndex!   
columnAttributesChanged
        "Private - the selected column attributes have been
        changed.  Store them in the dictionary that will be used
        to update the table pane."
    columnAttributes at: currentColumn put: selectedColumnAttributes.
    self setModified!  
asCellEditor
        "Private - answer a table cell editor with
        the attributes of the receiver."
    | answer |
    self hasExtendedAttributes
        ifTrue: [
            answer := self extendedEditorClass new.
            answer
                foreColor: foreColor;
                backColor: backColor;
                font: font ]
        ifFalse: [
            answer := self editorClass new ].
    answer
        readOnly: readOnly;
        editorType: type.
    ^answer!   
setDisableState
        "Private - The window is open.  Set the disable state 
		of the receiver's display items. "

   " self
        fixedColumns: (idMap at: #fixedColumns) value;
        fixedRows: (idMap at: #fixedRows) value."!
accessGroupBoxSubExtent
        "Private - answer the extent of the 'access by' sub group boxes."
    | parentExtent |
    parentExtent := self accessGroupBoxExtent.
    ^parentExtent x // 2 - 5 @ ( parentExtent y - PARTSDialog standardEntryHeight )!
tablePane: aTablePane
		" Private "
    tablePane := aTablePane!
hasExtendedAttributes
        "Private - answer whether the receiver has any
        extended attributes.  Extended attributes are
        foreColor, backColor, and font."
    ^foreColor notNil or: [
        backColor notNil or: [
            font notNil ]]!  
columnAttributesFor: anInteger
        "Private - answer the column attributes for row anInteger."
    | editor attributes |
    editor := self columnEditorFor: anInteger.
    attributes := PARTSTableCellAttributes new.
    editor isExtendedTextEditor
        ifTrue: [
            attributes
                    font: editor font;
                    foreColor: editor foreColor;
                    backColor: editor backColor ].
    attributes
        name: ( self columnNameFor: anInteger );
        label: ( self columnLabelFor: anInteger );
        readOnly: editor readOnly;
        type: editor editorType;
        dimension: ( self columnWidth: anInteger ).
    ^attributes!  
indexedRows: aRadioButton
		" Private "
    self addChangeMessage: ( Message new
        receiver: tablePane
        selector: #propertyIndexedRows:
        arguments: ( Array with: aRadioButton value ))! 
readOnly
        "Private - answer the receiver's readOnly attribute."
    ^readOnly!   
staticTextFrameFor: anInteger
        "Private - answer the framing block for static text number anInteger."
    | entryFieldRect leftTopPoint |
    ^[ :b |
        entryFieldRect := ( self entryFrameFor: anInteger ) value: b.
        leftTopPoint := entryFieldRect leftTop.
        leftTopPoint := leftTopPoint left: ( self staticTextExtentIn: b ) x.
        leftTopPoint := leftTopPoint left: self labelEntryFieldGap.
        leftTopPoint extentFromLeftTop: ( self staticTextExtentIn: b ) ]! 
accessGroupSubExtent
        "Private - answer the extent of the 'access by' top group box."
    ^40 @ ( 2 * PARTSDialog standardEntryHeight )! 
newRowAttributes: aDictionary
        "Private - set the new row attributes.  These are the attributes
        that will take affect when the user clicks OK on the properties
        dialog."
    newRowAttributes := aDictionary!  
integerAttribute: aSymbol from: anEntryField
		" Private "
    | value |
    value := anEntryField contents asInteger.
    value <= 0   "Don't allow zero value. Retain current value."
        ifTrue: [ ^self ].
	self addChangeMessage: ( Message new
		receiver: tablePane
		selector: ( aSymbol, ':' ) asSymbol
		arguments: ( Array with: value ))!
setLabelRow: aString
        "Private - set the selected row's label."
    selectedRowAttributes label: aString.
    self rowAttributesChanged!
foreColor: aColor
		"Private - set the receiver's foreColor."
	foreColor := aColor! 
rowsLabelEntryField
		"Private - answer the rows label entry field."
	^self paneAt: 'RowsLabelEntryField'!  
setForeColorColumn
        "Private - set the fore color of the selected column."
    | newColor |
    newColor := self getColor: selectedColumnAttributes foreColor.
    newColor notNil ifTrue: [
        selectedColumnAttributes foreColor: newColor.
        self columnAttributesChanged.
        self columnsDefaultColorsAndFontButton enable ]!   
getRowAttributesFor: anInteger
        "Private - answer the row attributes for anInteger."
    | attributes |
    ^( rowAttributes at: anInteger ifAbsent: [
        attributes := originalRowAttributes at: anInteger ifAbsent: [ nil ].
        attributes isNil
            ifTrue: [
                attributes := tablePane rowAttributesFor: anInteger ].
        attributes ] ) copy! 
setForeColorRow
        "Private - set the fore color of the selected row."
    | newColor |
    newColor := self getColor: selectedRowAttributes foreColor.
    newColor notNil ifTrue: [
        selectedRowAttributes foreColor: newColor.
        self rowAttributesChanged.
        self rowsDefaultColorsAndFontButton enable ]! 
namedColumns: aRadioButton
		" Private "
    newValue at: #indexedColumns put: aRadioButton selection not.
    self setModified: true.!
newColumnAttributes
        "Private - answer the new column attributes.  These are the attributes
        that will take affect when the user clicks OK on the properties
        dialog."
    ^newColumnAttributes! 
rowsTypeDropDownList
		"Private - answer the rows type drop down list."
	^self paneAt: 'RowsTypeDropDownList'!  
initialize
        "Private - initialize the receiver."
    modified := false.
    rowAttributes := Dictionary new.
    columnAttributes := Dictionary new.
    originalRowAttributes := Dictionary new.
    originalColumnAttributes := Dictionary new.
    ^super initialize!
columnsListBox 
		"Private - answer the columns list box."
	^self paneAt: 'ColumnsListBox'! 
rowsBackColorButton
		"Private - answer the rows back color button."
	^self paneAt: 'RowsBackColorButton'!  
fixedColumns: aBoolean
        "Private - The fixed dimension check box has been clicked.
         Enable/disable the row and column entry fields."
    aBoolean
        ifTrue: [(idMap at: #numberColumns) enable]
        ifFalse: [(idMap at: #numberColumns) disable].
    self setModified: true.!
aboutToChangeColumn
        "Private - the user selected a new column from the list box.
        Gather the input from the entry fields."
    selectedColumnAttributes isNil ifTrue: [ ^self ].
    self canChangeColumn ifFalse: [ ^self abortChangeColumn ].
    self columnsLabelEntryField modified ifTrue: [
        self setLabelColumn: self columnsLabelEntryField value ].
    self columnsNameEntryField modified ifTrue: [
        self setNameColumn: self columnsNameEntryField value ].
    self columnsWidthEntryField modified ifTrue: [
        self setDimensionColumn: self columnsWidthEntryField value ]!  
abortChangeRow
        "Private - abort the users attempted change of
        the selected row."
    ^self rowsListBox abortChange!
dimension: anInteger
		"Private - set the receiver's dimension."
	dimension := anInteger!   
setDefaultColorsAndFontColumn
        "Private - the user has clicked on the button that means
        use default colors and font for the selected column."
    self columnsDefaultColorsAndFontButton disable.
    selectedColumnAttributes setDefaultColorsAndFont.
    self columnAttributesChanged! 
font
        "Private - answer the receiver's font."
    ^font! 
openOn: aTablePane tablePaneProperties: aTablePaneProperty
        "Private - open a row and column editor."
    tablePane := aTablePane.
    propertyTablePane := aTablePaneProperty.
    columnRowTypeInfo := tablePane propertyInfoColumnRowTypes.
    columnAttributes := propertyTablePane newColumnAttributes copy.
    rowAttributes := propertyTablePane newRowAttributes copy.
    originalColumnAttributes := propertyTablePane oldColumnAttributes copy.
    originalRowAttributes := propertyTablePane oldRowAttributes copy.
    self
        createView;
        openWindow! 
entryFrameTopOffsetFor: anInteger
         "Private - answer top offset for entry field number anInteger."
   ^anInteger - 1 * ( self entryFieldHeight + self verticalGap )!
accessGroupBoxFramer
        "Private - answer the framing block for the 'Access by' group box."
    ^[ :b |
        ((( b leftTop right: self horizontalGap ) down:  self accessGroupBoxTopOffset )
			rightAndDown: leftTop ) extentFromLeftTop:
                self accessGroupBoxExtent ]!  
groupFrameFor: anInteger
        "Private - answer the framing block of one of the 'access by'
        sub group boxes.  If anInteger = 1 then it is the left on, if
        anInteger = 2 then it is the right one."
    | parentBox top left |
    ^[ :b |
        parentBox := self accessGroupBoxFramer value: b.
        top := parentBox top down: ( self verticalGap * ( PARTSDialog standardEntryHeight - 2 )).
         anInteger = 1
            ifTrue: [ left := parentBox left ]
            ifFalse: [ left := parentBox center x ].
        left := left right: self gapY.
        left @ top extentFromLeftTop: self accessGroupBoxSubExtent ]!   
addUndoMessage: aMessage
		"Private - add an undo message."
	undoMessages add: aMessage!
rowsWidthEntryField
        "Private - answer the rows width entry field."
    ^self paneAt: 'RowsDimensionEntryField'! 
backColor
        "Private - answer the receiver's back color."
    ^backColor! 
checkBoxFrameFor: anInteger
        "Private - answer the framing block for the check box numbered anInteger."
    ^[ :b | (((( b leftTop right: self horizontalGap )
		down: self checkBoxesTopOffset )
		down: anInteger - 1 * ( self checkBoxHeight + self gapY )) rightAndDown: leftTop )
        extentFromLeftTop:
            self width // 2 @ self checkBoxHeight ]!   
canChangeRow
        "Private - answer true if the current row attributes
        are acceptable and the user can select another row."
    | name nameField |
    nameField := self rowsNameEntryField.
    name := nameField contents.
    nameField modified
        ifTrue: [
            ( self canAcceptRowName: name )
                ifTrue: [ ^true ]
                ifFalse: [
                    MessageBox message: '''',name,''' is already used as a row name.'.
                    ^false ]]
        ifFalse: [ ^true ]!   
setLabelColumn: aString
        "Private - set the selected columns's label."
    selectedColumnAttributes label: aString.
	self columnAttributesChanged!  
radioButtonExtent
        "Private - anwer the extent of the receiver's radio buttons."
    ^self accessGroupBoxSubExtent x - 5 @ self radioButtonHeight!   
ok
        "Private - the user clicked the OK button."
    [ self
        aboutToChangeColumn;
        aboutToChangeRow ] on: VetoAction do: [ ^self ].
    modified ifFalse: [ ^super ok ].
    propertyTablePane
        newColumnAttributes: columnAttributes;
        oldColumnAttributes: originalColumnAttributes;
        newRowAttributes: rowAttributes;
        oldRowAttributes: originalRowAttributes.
    ^super ok!  
columnsNameEntryField
		"Private - answer the columns name entry field."
	^self paneAt: 'ColumnsNameEntryField'!
addRowColumnAttributeMessagesTo: anExpressionModel
        "Private - code generation - add message models to anExpressionModel
        to rebuild the receiver's row and column attributes."
    | editor |
    1 to: numberOfRows do: [ :i |
        editor := self rowEditorFor: i.
        editor isExtendedTextEditor ifTrue: [
            anExpressionModel
                addSelector: #setRow:foreColor: with: i with: editor foreColor;
                addSelector: #setRow:backColor: with: i with: editor backColor;
                addSelector: #setRow:font: with: i with: editor font;
                addSelector: #setRow:readOnly: with: i with: editor readOnly;
                addSelector: #setRow:type: with: i with: editor editorType ]].
    1 to: numberOfColumns do: [ :i |
        editor := self columnEditorFor: i.
        editor isExtendedTextEditor ifTrue: [
            anExpressionModel
                addSelector: #setColumn:foreColor: with: i with: editor foreColor;
                addSelector: #setColumn:backColor: with: i with: editor backColor;
                addSelector: #setColumn:font: with: i with: editor font;
                addSelector: #setColumn:readOnly: with: i with: editor readOnly;
                addSelector: #setColumn:type: with: i with: editor editorType ]]!  
createItemsTitled: aString in: aRectangle
        "Private - create the controls for one side of the receiver."
    | listTop staticDownFudge staticTextHeight entryFieldWidth staticTextExtent
        entryFieldDownFudge firstEntryFieldLabelTop buttonTop
        rows topPane gap buttonWidth buttonHeight
        listBottom listRight font entryFieldHeight entryFieldExtent entryFieldSpacer |
    ( #( 'Columns' 'Rows' ) includes: aString ) ifFalse: [
        self error: 'argument string must be ''Rows'' or ''Columns''.' ].
    rows := aString = 'Rows'.
    font := self font.
    gap := WindowDialog charWidth.
    staticDownFudge := 1.
    entryFieldDownFudge := PARTSDialog standardEntryHeight.
    buttonHeight := WindowDialog entryHeight.
    buttonWidth := buttonHeight * 7 // 2.
    listTop := aRectangle top down: PARTSDialog standardEntryHeight + gap.
    listRight := aRectangle left right: aRectangle width // 4.
    entryFieldHeight := PARTSDialog standardEntryHeight.
    entryFieldSpacer := PARTSDialog standardEntryHeight * 2 + 1.
    staticTextHeight := PARTSDialog standardEntryHeight - 1.
    entryFieldWidth :=  aRectangle right - listRight - ( gap * 3 ).
    entryFieldExtent := entryFieldWidth @ entryFieldHeight.
    staticTextExtent := entryFieldWidth @ staticTextHeight.
    firstEntryFieldLabelTop := listTop down: PARTSDialog standardEntryHeight.
    listBottom := firstEntryFieldLabelTop down: entryFieldSpacer * 3 + entryFieldDownFudge + entryFieldHeight + 1.
    buttonTop := listBottom down: gap + gap.
    topPane := self mainView.
    topPane
        addSubpane: ( StaticText new
            contents: aString;
            font: font;
            framingBlock: [ :b |
                ( aRectangle leftTop rightAndDown: gap ) extentFromLeftTop:
                    staticTextExtent ] );
        addSubpane: ( ListBox new
            setName: aString, 'ListBox';
            font: font;
            when: #aboutToChange
                send: ( rows ifTrue: [ #aboutToChangeRow ] ifFalse: [ #aboutToChangeColumn ] )
                to: self;
            when: #changedIndex:
                send: ( rows ifTrue: [ #selectRow: ] ifFalse: [ #selectColumn: ] )
                to: self;
            framingBlock: [ :b | (( aRectangle left right: gap ) @ listTop )
                rightBottom: listRight @ listBottom ] );
        addSubpane: ( CheckBox new
            setName: aString, 'ReadOnlyCheckBox';
            label: 'Read only';
            font: font;
            disable;
            when: #checked
                send: ( rows ifTrue: [ #setReadOnlyRow ] ifFalse: [ #setReadOnlyColumn ] )
                to: self;
            when: #unchecked
                send: ( rows ifTrue: [ #setReadOnlyRow ] ifFalse: [ #setReadOnlyColumn ] )
                to: self;
            framingBlock: [ :b |
                listRight + gap @ listTop
                   extentFromLeftTop: staticTextExtent ] );

        addSubpane: ( StaticText new
            contents: 'Label';
            font: font;
            framingBlock: [ :b |
                listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 0 )
                    extentFromLeftTop: staticTextExtent ] );
        addSubpane: ( PARTSEntryFieldPart new
            setName: aString, 'LabelEntryField';
            font: font;
            disable;
            framingBlock: [ :b |
               listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 0 + entryFieldDownFudge )
                   extentFromLeftTop: entryFieldExtent ] );

        addSubpane: ( StaticText new
            contents: 'Name';
            font: font;
            framingBlock: [ :b |
                 listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 1 )
                   extentFromLeftTop: staticTextExtent ] );
        addSubpane: ( PARTSEntryFieldPart new
            setName: aString, 'NameEntryField';
            font: font;
            disable;
            framingBlock: [ :b |
               listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 1 + entryFieldDownFudge )
                   extentFromLeftTop: entryFieldExtent ] );

        addSubpane: ( StaticText new
            contents: ( rows ifTrue: [ 'Height' ] ifFalse: [ 'Width' ] );
            font: font;
            framingBlock: [ :b |
                listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 2 )
                   extentFromLeftTop: staticTextExtent ] );
        addSubpane: ( PARTSIntegerEntryFieldPart new
            parent: topPane;
            setName: aString, 'DimensionEntryField';
            font: font;
            disable;
            framingBlock: [ :b |
               listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 2 + entryFieldDownFudge )
                   extentFromLeftTop: entryFieldExtent ] );

        addSubpane: ( StaticText new
            contents: 'Format';
            font: font;
            framingBlock: [ :b |
                listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 3 )
                   extentFromLeftTop: staticTextExtent ] );
        addSubpane: ( DropDownList new
            setName: aString, 'TypeDropDownList';
            font: font;
            contents: ( columnRowTypeInfo collect: [ :a | a first ] );
            disable;
            when: #changed:
                send: ( rows ifTrue: [ #setTypeRow: ] ifFalse: [ #setTypeColumn: ] )
                to: self;
            framingBlock: [ :b |
               listRight + gap @ ( firstEntryFieldLabelTop down: entryFieldSpacer * 3 + entryFieldDownFudge )
                   extentFromLeftTop: entryFieldExtent x @ ( entryFieldExtent y * 5 ) ] );

        addSubpane: ( Button new
            setName: aString, 'ForeColorButton';
            label: 'Forecolor...';
            font: font;
            disable;
            when: #clicked
                send: ( rows ifTrue: [ #setForeColorRow ] ifFalse: [ #setForeColorColumn ] )
                to: self;
            framingBlock: [ :b |
                (( aRectangle left right: gap ) right: buttonWidth + gap * 0 ) @ buttonTop
                    extentFromLeftTop: buttonWidth @ buttonHeight ] );
        addSubpane: ( Button new
            setName: aString, 'BackColorButton';
            label: 'Backcolor...';
            font: font;
            disable;
            when: #clicked
                send: ( rows ifTrue: [ #setBackColorRow ] ifFalse: [ #setBackColorColumn ] )
                to: self;
            framingBlock: [ :b |
                (( aRectangle left right: gap ) right: buttonWidth + gap * 1 ) @ buttonTop
                    extentFromLeftTop: buttonWidth @ buttonHeight ] );
        addSubpane: ( Button new
            setName: aString, 'FontButton';
            label: 'Font...';
            font: font;
            disable;
            when: #clicked
                send: ( rows ifTrue: [ #setFontRow ] ifFalse: [ #setFontColumn ] )
                to: self;
            framingBlock: [ :b |
                (( aRectangle left right: gap ) right: buttonWidth + gap * 2 ) @ buttonTop
                    extentFromLeftTop: buttonWidth @ buttonHeight ] );

        addSubpane: ( Button new
            setName: aString, 'DefaultColorsAndFont';
            label: 'Default colors and font';
            font: font;
            disable;
            when: #clicked
                send: ( rows ifTrue: [ #setDefaultColorsAndFontRow ] ifFalse: [ #setDefaultColorsAndFontColumn ] )
                to: self;
            framingBlock: [ :b |
                ( aRectangle left right: gap ) @ ( buttonTop down: buttonHeight + gap )
                       extentFromLeftTop: ( buttonWidth * 3 + ( gap * 2 )) @ buttonHeight ] );

        yourself!   
accessGroupBoxTopOffset
        "Private - answer the distance between the top of the
        receiver's rectangle and the top of the 'access by' group box."
    ^3 * PARTSDialog standardEntryHeight!
entryFrameFor: anInteger
        "Private - answer the framing block for entry field number anInteger."
    ^[ :b | ((( b rightTop left: self numberFieldExtent x + self horizontalGap )
        down: ( self entryFrameTopOffsetFor: anInteger )) down: leftTop y )
            extentFromLeftTop: self numberFieldFrameExtent ]!
backColor: aColor
		"Private - set the receiver's backColor."
	backColor := aColor! 
setDefaultColorsAndFont
        "Private - set the receiver's forecolor, backcolor,
        and font to the defaults."
    foreColor := nil.
    backColor := nil.
    font := nil!  
getColumnAttributesFor: anInteger
        "Private - answer the column attributes for anInteger."
    | attributes |
    ^( columnAttributes at: anInteger ifAbsent: [
        attributes := originalColumnAttributes at: anInteger ifAbsent: [ nil ].
        attributes isNil
            ifTrue: [
                attributes := tablePane columnAttributesFor: anInteger ].
        attributes ] ) copy!  
oldColumnAttributes
        "Private - answer the old column attributes.  These are the attributes
        that will take affect when the user undoes previously set attributes."
    ^oldColumnAttributes!
canChangeColumn
        "Private - answer true if the current column attributes
        are acceptable and the user can select another column."
    | name nameField |
    nameField := self columnsNameEntryField.
    name := nameField contents.
    nameField modified
        ifTrue: [
            ( self canAcceptColumnName: name )
                ifTrue: [ ^true ]
                ifFalse: [
                    MessageBox message: '''',name,''' is already used as a column name.'.
                    ^false ]]
        ifFalse: [ ^true ]! 
rowsForeColorButton
		"Private - answer the rows fore color button."
	^self paneAt: 'RowsForeColorButton'!  
rowsNameEntryField
		"Private - answer the rows name entry field."
	^self paneAt: 'RowsNameEntryField'! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | subMethodPrefix parentClassModel methodName methodModel
      argumentExpression messageModel |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    parentClassModel := anExpressionModel parentClassModel.
    subMethodPrefix := self partIsPart
        ifTrue: [ self partName copy ]
        ifFalse: [ 'tablePane' ].
    subMethodPrefix at: 1 put: ( subMethodPrefix at: 1 ) asLowerCase.
        "subMethodPrefix is used to prefix methods that reconstruct
        the receiver that are factored out of the main method."
    anExpressionModel
        addSelector: #newNumberOfRows: with: numberOfRows;
        addSelector: #newNumberOfColumns: with: numberOfColumns;
        addSelector: #defaultCellHeight: with: defaultCellHeight;
        addSelector: #defaultCellWidth: with: defaultCellWidth.
    columnRights size > 0 ifTrue: [
        methodName := subMethodPrefix, 'ColumnRights'.
        methodModel := parentClassModel newClassMethodNamed: methodName.
        methodModel comment: 'Private - Answer the column right offsets for a table pane.'.
        methodModel newLiteralModelFor: columnRights.
        messageModel := anExpressionModel addSelector: #columnRights:.
        argumentExpression := messageModel newExpressionArgument.
        argumentExpression
            setReceiverToSelf;
            addSelector: methodName ].
    rowBottoms size > 0 ifTrue: [
        methodName := subMethodPrefix, 'RowBottoms'.
        methodModel := parentClassModel newClassMethodNamed: methodName.
        methodModel comment: 'Private - Answer the row bottom offsets for a table pane.'.
        methodModel newLiteralModelFor: rowBottoms.
        messageModel := anExpressionModel addSelector: #rowBottoms:.
        argumentExpression := messageModel newExpressionArgument.
        argumentExpression
            setReceiverToSelf;
            addSelector: methodName ].

    anExpressionModel
        addSelector: #contents: with: contents;
        addSelector: #rowLabels: with: rowLabels;
        addSelector: #columnLabels: with: columnLabels;
        addSelector: #columnNames: with: columnNames;
        addSelector: #rowNames: with: rowNames;
        addSelector: #columnLabelsHeight: with: columnLabelsHeight;
        addSelector: #rowLabelsWidth: with: rowLabelsWidth;

       addSelector: #propertyAdjustColumnWidths: with: self propertyAdjustColumnWidths;
       addSelector: #propertyAdjustRowHeights: with: self propertyAdjustRowHeights;
       addSelector: #propertyDisplayColumnLabels: with: self propertyDisplayColumnLabels;
       addSelector: #propertyDisplayRowLabels: with: self propertyDisplayRowLabels;
       addSelector: #propertyEditColumnLabels: with: self propertyEditColumnLabels;
       addSelector: #propertyEditRowLabels: with: self propertyEditRowLabels;

       addSelectorIfFalse: #indexedColumns: with: self indexedColumns;
       addSelectorIfFalse: #indexedRows: with: self indexedRows;

        yourself.

    self addRowColumnAttributeMessagesTo: anExpressionModel
!
label: aString
        "Private - set the receiver's label."
    label := aString!  
createRowItems
	| rect initWindowSize |
	initWindowSize := self initWindowSize.
	rect := ( initWindowSize x // 2 ) @ self clientAreaTop rightBottom:
		initWindowSize x @ self clientAreaBottom.
	self createItemsTitled: 'Rows' in: rect!   
leftStaticTextFrameFor: anInteger
        "Private - answer the framing block for the left static text
        numbered anInteger."
    | entryFieldRect leftTopPoint |
    ^[ :b |
        entryFieldRect := ( self leftEntryFrameFor: anInteger ) value: b.
        leftTopPoint := entryFieldRect leftTop.
        leftTopPoint := leftTopPoint left: ( self staticTextExtentIn: b ) x.
        leftTopPoint := leftTopPoint left: self labelEntryFieldGap.
        leftTopPoint extentFromLeftTop: ( self staticTextExtentIn: b ) ]! 
enableRowControls
        "Private - enable the row controls."
    self rowsLabelEntryField enable.
    self rowsListBox enable.
    self rowsNameEntryField enable.
    self rowsReadOnlyCheckBox enable.
    self rowsTypeDropDownList enable.
    self rowsWidthEntryField enable.
    self rowsBackColorButton enable.
    self rowsFontButton enable.
    self rowsForeColorButton enable.!
editorClass
        "Private - answer the class of nonextended editors."
    ^PARTSTableCellTextEditor! 
label
        "Private - answer the receiver's label."
    ^label!  
initWindowSize
        "Private - Answer the default window size."
    ^300 @ ( 17 * PARTSDialog standardEntryHeight )! 
createView
        " Private - create the window "
    | charSize entryHeight font gap topPane |

    font := self font.
    charSize := WindowDialog unitMultiplier.
    gap := WindowDialog dialogUnit x.
    entryHeight := WindowDialog entryHeight.

    self addView: ((topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: (self dialogTitle: 'TablePane' modifier: 'Edit');
        when: #opened send: #windowOpened to: self;
        yourself).

    self
        createColumnItems;
        createRowItems.

    topPane addSubpane: (Button new
        defaultPushButton;
        font: font;
        label: 'OK';
        when: #clicked send: #ok to: self;
        framingBlock: [ :b |
                (b left right: gap) @ (b bottom up: entryHeight // 2)
                    extentFromLeftBottom: entryHeight * 5 @ (entryHeight )]);
        addSubpane: (Button new
            font: font;
            label: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b |
                (b left right: gap * 2 + (entryHeight * 5)) @ (b bottom up: entryHeight // 2)
                    extentFromLeftBottom: entryHeight * 5 @ (entryHeight )]).!
addToWindow: aTopPane
        " Private - create panes in <aTopPane> to represent
        the receiver's value. "

    | r numberEFs c anEntryField font
         vwAdjust booleanPropertyInfo array currentValue numberPropertyInfo |
    vwAdjust := 3.
    idMap := IdentityDictionary new.
    font := self font.
    booleanPropertyInfo := tablePane propertyInfoBooleans.
    numberPropertyInfo := tablePane propertyInfoIntegers.
    1 to: numberPropertyInfo size do: [ :i |
        array := numberPropertyInfo at: i.
        currentValue := tablePane perform: array last.
        self addUndoMessage: ( Message new
            receiver: tablePane
            selector: ( array last, ':' ) asSymbol
            arguments: ( Array with: currentValue )).
        anEntryField := PARTSEntryFieldPart new.
        aTopPane
            addSubpane: (anEntryField
                owner: self;
                font: font;
                contents: currentValue printString;
                when: #changed:
                    send: #integerAttribute:from:
                    to: self
                    with: array last with: anEntryField;
                framingBlock: (
                    i odd
                        ifTrue: [self leftEntryFrameFor: i - 1 // 2 + 1]
                        ifFalse: [self entryFrameFor: i - 1 // 2 + 1]));
            addSubpane: (StaticText rightJustified
                font: font;
                contents: array first , ':';
                framingBlock: (
                    i odd
                        ifTrue: [self leftStaticTextFrameFor: i - 1 // 2 + 1]
                        ifFalse: [self staticTextFrameFor:  i - 1 // 2 + 1]))].

    numberEFs := numberPropertyInfo size - 1 // 2 + 1.

    aTopPane addSubpane: (GroupBox new
        contents: 'Access by';
        font: font;
        framingBlock: self accessGroupBoxFramer ).

    aTopPane
"columns"
        addSubpane: ( GroupBox new
            startGroup;
            contents: 'Columns';
            font: font;
            framingBlock: ( self groupFrameFor: 1 ));
        addSubpane: (( r := RadioButton new )
            font: font;
            contents: 'Index';
            selection: tablePane indexedColumns;
            when: #clicked:
                send: #indexedColumns: to: self with: r;
            framingBlock: (self radioFrameFor: 1 with: 1 ));
        addSubpane: (( r := RadioButton new )
            font: font;
            contents: 'Name';
            selection: tablePane indexedColumns not;
            when: #clicked:
                send: #indexedColumnsNot: to: self with: r;
            framingBlock: (self radioFrameFor: 1 with: 2 ));
"rows"
        addSubpane: ( GroupBox new
            startGroup;
            contents: 'Rows';
            font: font;
            framingBlock: ( self groupFrameFor: 2 ));
        addSubpane: (( r := RadioButton new )
            startGroup;
            font: font;
            contents: 'Index';
            selection: tablePane indexedRows;
            when: #clicked:
                send: #indexedRows: to: self with: r;
            framingBlock: (self radioFrameFor: 2 with: 1 ));
        addSubpane: (( r := RadioButton new )
            font: font;
            contents: 'Name';
            selection: tablePane propertyIndexedRows not;
            when: #clicked:
                send: #indexedRowsNot: to: self with: r;
            framingBlock: (self radioFrameFor: 2 with: 2 )).
    numberEFs := numberEFs + (9/2) .
    1 to: booleanPropertyInfo size do: [ :i |
        array := booleanPropertyInfo at: i.
        currentValue := tablePane perform: array last.
        self addUndoMessage: ( Message new
            receiver: tablePane
            selector: ( array last, ':' ) asSymbol
            arguments: ( Array with: currentValue )).
           c := CheckBox new.
        aTopPane
            addSubpane: (c
                font: font;
                owner: self;
                value: currentValue;
                contents: array first;
                when: #clicked:
                    send: #booleanAttribute:from:
                    to: self
                    with: array last with: c;
                framingBlock: (
                    i odd 
                        ifTrue: [self checkBoxFrameFor: i - 1 // 2 + 1 ]
                        ifFalse: [self rightCheckBoxFrameFor: i - 1 // 2 + 1 ] )) ]!
columnsColumnsEntryField
		"Private - answer the columns width entry field."
	^self paneAt: 'ColumnsDimensionEntryField'!   
oldRowAttributes: aDictionary
        "Private - set the old row attributes.  These are the attributes
        that will take affect when the user undoes previously set attributes."
    oldRowAttributes := aDictionary! 
name
        "Private - answer the receiver's name."
    ^name! 
setDimensionRow: anInteger
        "Private - set the selected row's dimension."
    selectedRowAttributes dimension: anInteger.
    self rowAttributesChanged!
doChanges
        " Private - apply the value if it has been changed. "
    self shouldApplyChange ifTrue: [
        tablePane propertiesAboutToChange.
        changeMessages do: [ :message |
            message receiver isNil ifTrue: [
                message receiver: tablePane ].
            message evaluate ].
    newColumnAttributes size > 0 ifTrue: [
        tablePane propertyUpdateColumnAttributes: newColumnAttributes ].
    newRowAttributes size > 0 ifTrue: [
        tablePane propertyUpdateRowAttributes: newRowAttributes ].
        tablePane propertiesHaveChanged ]! 
newColumnAttributes: aDictionary
        "Private - set the new column attributes.  These are the attributes
        that will take affect when the user clicks OK on the properties
        dialog."
    newColumnAttributes := aDictionary! 
columnsBackColorButton
		"Private - answer the columns back color button."
	^self paneAt: 'ColumnsBackColorButton'! 
rightCheckBoxFrameFor: anInteger
        "Private - answer the framng block for the right column check box
        numbered anInteger."
    ^[ :b | (((( b rightTop left: self width // 2 + self horizontalGap )
		down:  self checkBoxesTopOffset )
		down: anInteger - 1 * ( self checkBoxHeight + self gapY ))
        rightAndDown: leftTop) extentFromLeftTop:
            self width * 3 // 7 @ self checkBoxHeight ]!   
rowAttributesFor: anInteger
        "Private - answer the row attributes for row anInteger."
    | editor attributes |
    editor := self rowEditorFor: anInteger.
    attributes := PARTSTableCellAttributes new.
    editor isExtendedTextEditor
        ifTrue: [
            attributes
                    font: editor font;
                   foreColor: editor foreColor;
                    backColor: editor backColor ].
    attributes
        name: ( self rowNameFor: anInteger );
        label: ( self rowLabelFor: anInteger );
        readOnly: editor readOnly;
        type: editor editorType;
        dimension: ( self rowHeight: anInteger ).
    ^attributes!
rowsReadOnlyCheckBox
		"Private - answer the rows read only check box."
	^self paneAt: 'RowsReadOnlyCheckBox'!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Table Pane'!
shouldApplyChange
        " Private - answer whether the receiver's value has
        been changed and should be applied to the part. "

    ^changeMessages size > 0 or: [
        newColumnAttributes size > 0 or: [
            newRowAttributes size > 0 ]]!
selectRow: anInteger
        "Private - row number anInteger has been selected."
    | type |
    currentRow := anInteger.
    self enableRowControls.
    selectedRowAttributes := self rowAttributesFor: anInteger.
    type := selectedRowAttributes type.
    columnRowTypeInfo do: [ :a |  "find string for symbol"
        a last = type ifTrue: [ type := a first ]].
    self rowsReadOnlyCheckBox setValue: selectedRowAttributes readOnly.
    self rowsLabelEntryField contents: selectedRowAttributes label.
    self rowsNameEntryField contents: selectedRowAttributes name.
    self rowsTypeDropDownList selectItem: type.
    self rowsHeightEntryField contents: selectedRowAttributes dimension.
    selectedRowAttributes hasExtendedAttributes
        ifTrue: [ self rowsDefaultColorsAndFontButton enable ]
        ifFalse: [ self rowsDefaultColorsAndFontButton disable ]!  
updateFixedColumns: numberOfColumns
        " Private - the value in the entry field has changed. "
    numberOfColumns > 0
        ifTrue: [
            newValue at: #fixedColumns put: numberOfColumns.
            self setModified: true ]! 
font: aFont
		"Private - set the receiver's font."
	font := aFont!  
setNameRow: aString
        "Private - set the selected row's name."
    selectedRowAttributes name: aString.
    self rowAttributesChanged!   
canAcceptColumnName: aString
        "Private - answer true aString can be used as a column name."
    | attrs |
    aString size = 0 ifTrue: [ ^true ].
    1 to: tablePane numberOfColumns do: [ :i |
        i = currentColumn
            ifFalse: [
                attrs := self getColumnAttributesFor: i.
                attrs name = aString ifTrue: [
                    ^false ]]].
    ^true! 
partPropertyEditRowColumnAttributes: aPropertyStructure
        " Private - edit the reciever's row and column attributes. "
    ^( PARTSTableRowColumnEditor new
        openOn: self
        tablePaneProperties: ( aPropertyStructure propertyAt: #tablePane ))
            partsExceptionIfNil!  
currentRowNumber
        "Private - answer the currently selected row number."
	^self rowsListBox selectedIndex!
name: aString
        "Private - set the receiver's name."
    name := aString! 
setDimensionColumn: anInteger
        "Private - set the selected column's dimension."
    selectedColumnAttributes dimension: anInteger.
    self columnAttributesChanged!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        at: #tablePane putProperty: (PARTSPropertyTablePane new
            tablePane: self );
        putProperty: PARTSPropertyColorAndFont new;
        putProperty: #( #interface #sizeWindow #editContents )!
partPropertyHasFrameCreationFlags
    "Answer whether the property set style should modify
        the frame creation flags instead of the style."
    self partsVosOnly.
    ^true!  
accessGroupBoxExtent
        "Private - answer the extent of the 'Access by' top group box."
    ^100 @ ( 4 * PARTSDialog standardEntryHeight )!
dimension
        "Private - answer the receiver's dimension."
    ^dimension!  
computeHeight
        "Private - compute and answer the height of the receiver."

    | numberBooleans numberNumbers entryRows checkBoxRows heightAccessBox  |
    numberBooleans := tablePane propertyInfoBooleans size.
    numberNumbers := tablePane propertyInfoIntegers size.
    entryRows := numberNumbers + 1 // 2.
    checkBoxRows := numberBooleans + 1 // 2.
    heightAccessBox := self accessGroupBoxExtent y.
    ^ ( entryRows * ( self entryFieldHeight + self verticalGap )) +
        heightAccessBox +
            ( checkBoxRows * ( self checkBoxHeight + self verticalGap ))
            + ( self verticalGap * 10 )! 
canAcceptRowName: aString
        "Private - answer true aString can be used as a row name."
    | attrs |
    aString size = 0 ifTrue: [ ^true ].
    1 to: tablePane numberOfRows do: [ :i |
        i = currentRow
            ifFalse: [
                attrs := self getRowAttributesFor: i.
                attrs name = aString ifTrue: [
                ^false ]]].
    ^true!
enableColumnControls
        "Private - enable the column controls."
    self columnsLabelEntryField enable.
    self columnsListBox enable.
    self columnsNameEntryField enable.
    self columnsReadOnlyCheckBox enable.
    self columnsTypeDropDownList enable.
    self columnsWidthEntryField enable.
    self columnsBackColorButton enable.
    self columnsForeColorButton enable.
    self columnsFontButton enable.!   
setReadOnlyColumn
        "Private - set the selected column's read only attribute."
    selectedColumnAttributes readOnly: self columnsReadOnlyCheckBox value.
	self columnAttributesChanged! 
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^true!   
getFont: aFont
        "Private - bring up the font dialog with currentFont selected.
        Answer the font the user selected or nil if cancelled."
    | currentFont |
    currentFont := aFont isNil
        ifTrue: [ tablePane font ]
        ifFalse: [ aFont ].
    ^FontDialog new
        sampleFont: currentFont;
        open;
        chosen!  
selectColumn: anInteger
        "Private - column number anInteger has been selected."
    | type |
    currentColumn := anInteger.
    self enableColumnControls.
    selectedColumnAttributes := self columnAttributesFor: anInteger.
    type := selectedColumnAttributes type.
    columnRowTypeInfo do: [ :a |  "find string for symbol"
        a last = type ifTrue: [ type := a first ]].
    self columnsReadOnlyCheckBox setValue: selectedColumnAttributes readOnly.
    self columnsLabelEntryField contents: selectedColumnAttributes label.
    self columnsNameEntryField contents: selectedColumnAttributes name.
    self columnsTypeDropDownList selectItem: type.
    self columnsWidthEntryField contents: selectedColumnAttributes dimension.
    selectedColumnAttributes hasExtendedAttributes
        ifTrue: [ self columnsDefaultColorsAndFontButton enable ]
        ifFalse: [ self columnsDefaultColorsAndFontButton disable ]!  
setFontColumn
        "Private - set the font of the selected column."
    | newFont |
    newFont := self getFont: selectedColumnAttributes font.
    newFont notNil ifTrue: [
        selectedColumnAttributes font: newFont.
        self columnAttributesChanged.
        self columnsDefaultColorsAndFontButton enable ]! 
setBackColorColumn
        "Private - set the back color of the selected column."
    | newColor |
    newColor := self getColor: selectedColumnAttributes backColor.
    newColor notNil ifTrue: [
        selectedColumnAttributes backColor: newColor.
        self columnAttributesChanged.
        self columnsDefaultColorsAndFontButton enable ]!   
readOnly: aBoolean
		"Private - set the receiver's read only attribute."
	readOnly := aBoolean!