3.1.0.106
   
scrollVerticalPixels: anInteger
        "Private - Scroll the pane up by anInteger
         number of rows (if positive) or down by
         the absolute value of anInteger (if negative)."
	self
		partsIfOS2Do: [ self vos2ScrollVerticalPixels: anInteger ]
		partsIfWindowsDo: [ self vwScrollVerticalPixels: anInteger ]! 
scrollTopCornerTo: aNewCorner
        "Private - Scroll topCorner to aNewCorner"
    | offset |
    offset := topCorner - aNewCorner.
    self scrollTopCorner: offset!   
textOriginYTop
        "Private - answer the y coordinate
        of the text origin for text at the top of the receiver."
    ^boundingBox top down: self font height * 4 // 3!   
propertyDisplayColumnLabels
	^self getBooleanProperty: #propertyDisplayColumnLabels! 
horizontalGridLineType
        "Private - answer the line type constant for the receiver's
        horizontal grid lines."
    ^self propertyAt: #horizontalGridLineType ifAbsent: [
        LineTypeSolid ]! 
rectangleForCornerLabel
        "Private - answer the rectangle of the left top corner label."
    | rect top |
	top := rectangle top.
	self partsIfWindowsDo: [ top := top up: 1 ].
    rect := ( rectangle left  left: 1 ) @ top rightBottom:
        ( self rowLabelsRight right: 1 ) @ ( self columnLabelsBottom down: 1 ).
    ^self clippingBoxForRect: rect!
readOnly: aBoolean
        "Set the receiver to be read only if aBoolean
        is true."
    readOnly := aBoolean!   
displayLabel
        "Display the reciever as a label."! 
wordSelectionLeftAt: anInteger
        "Private - answer the index of the begining of
        the word at char index anInteger."
    | answer stringContents |
	anInteger = 0 ifTrue: [ ^0 ].
    answer := anInteger.
    stringContents := self stringContents.
    ( stringContents at: anInteger ) = Space
        ifTrue: [
            [ answer > 0 and: [
                ( stringContents at: answer ) = Space ]] whileTrue: [
                    answer := answer - 1 ]].
    [ answer > 0 and: [
        ( stringContents at: answer ) ~= Space ]] whileTrue: [
            answer := answer - 1 ].
    ^answer!
propertyRowLabelWidth
	^rowLabelsWidth!  
tablePane: aTablePane
        "Set the receiver's tablePane."
    tablePane := aTablePane!  
computeCellsInRectangle
        "Private - compute which cells are in the receiver's
        rectangle (wholly or partially) and store the result
        in cellsInRectangle."
    rectangle isNil ifTrue: [ ^self ].
    cellsInRectangle := self computeCellsInRectangle: rectangle!  
defaultCellHeight
    ^defaultCellHeight!
font
        "Answer the receiver's font."
    ^font isNil
        ifTrue: [ super font ]
        ifFalse: [ font ]!  
adjustCellsExtentForContents
        "Private - the receiver's contents has changed.
        adjust the cells extent to insure it the
        size accomodates the new contents."
    | width height |
    height := contents size.
    width := 0.
    contents do: [ :row |
        width := width max: row size ].
    width > self numberOfColumns ifTrue: [
        self newNumberOfColumns: width ].
    height > self numberOfRows ifTrue: [
        self newNumberOfRows: height ].
    self updateSliders!  
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( (self setCellMessages, self getCellMessages ) includes: aSelector )
        ifTrue: [ PARTSAliasLink ]
          ifFalse: [ super partLinkClassFor: aSelector ]!
whiteSpaceColor
        "Private - answer the color to be used
        to fill the area not occupied by cells."
    ^PARTSHostInterface colorBackground!   
updateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollbar."
    self resizeActiveEditor.
    ^super updateHorizontalSlider!  
rowTop: aRowAddress
        "Private - answer the pixel y coordinate that is
        the left border of aRowAddress disregarding
        the scroll offset and colum labels height."
    ^aRowAddress = 1
        ifTrue: [ 0 ]
        ifFalse: [ rowBottoms at: aRowAddress - 1 ]!
setCell: setColumnName arguments: anArray
    | columnNumber value |
    columnNumber := self setCellMessages indexOf: setColumnName
        ifAbsent: [^nil].
    value := anArray first.
    "set the entire column if value is of type Collection excluding String."

    (value isCollection and: [value isString not])
        ifTrue: [
            self
                columnAt: (self indexedColumns
                    ifTrue: [columnNumber]
                    ifFalse: [columnNames at: columnNumber])
                put: value ]
        ifFalse: [self cellAtPoint: columnNumber @ currentRow show: value]!  
scrollVertical: anInteger
        "Scroll the pane up by anInteger
         number of rows (if positive) or down by
         the absolute value of anInteger (if negative)."
    | amountToScroll offset |
    anInteger positive
        ifTrue: [
            amountToScroll := ( anInteger min: topCorner y - 1 negated ) negated ]
        ifFalse: [
            amountToScroll := anInteger negated.
            topCorner y to: topCorner y + amountToScroll do: [ :row |
                offset := ( self bottomOfRow: row ) - ( self bottomOfRow: topCorner y ).
                ( self bottomRowBottom - offset isAbove: rectangle bottom )
                    ifTrue: [ ^self scrollVerticalReal: ( row - topCorner y ) negated ]]].
    self scrollVerticalReal: amountToScroll negated.
	self updateVerticalSlider!  
columnLabelEditorClass
        "Private - answer the class of the receiver's column label editors."
	^PARTSTableColumnLabelEditor!  
initialize
        "Private - initialize the receiver."
    readOnly := false.
	self initializeTextAlignment.
    self reinitialize!  
partIsEditing
        "Answer whether the receiver is being
        edited in a PARTS Workbench. "
    ^super partIsEditing
        ifTrue: [ ( self partEditor isDirectEditing: self ) not ]
        ifFalse: [ false ]!
textOriginX
        "Private - answer the x coordinate of the text origin."
    ^self perform: textOriginXSelector! 
gettingFocus
        "Private - the receiver's pane has received focus.
		Activate the receiver."!  
columnNumber
		"Private - answer the column number of the receiver."
	^cellAddress! 
popUpMenuAt: aPoint
		"Private - the user has performed the mouse
		operation to pop up a menu.  Do nothing."!  
wmSingleselect: mp1 with: mp2
        "Private - the user has performed a mouse  single
        select operation."
    | selector |
    self partsVosOnly.
    Notifier isControlKeyDown
        ifTrue: [ selector := #singleSelectControlAt: ]
        ifFalse: [
            Notifier isShiftKeyDown
                ifTrue: [ selector := #singleSelectShiftAt: ]
                ifFalse: [ selector := #singleSelectAt: ]].
    self sendInputEvent: selector with: mp1 asPoint.
    ^nil!  
indexedColumns: aBoolean
        "Set whether the receiver uses indexed columns access."
    self propertyAt: #indexedColumns put: ( aBoolean ifTrue: [ true ] ifFalse: [ nil ] ).
    self updateAccess!  
setCell: aCell editor: aCellEditor
        "Private - set aCell to have aCellEditor as it's editor."
    cellEditorMap isNil ifTrue: [ self createCellEditorMap ].
    cellEditorMap defineCellEditor: aCellEditor forCellAddress: aCell!  
defaultFont
        "Private - answer the default font table panes."
    ^PARTSHostInterface defaultPartFont!   
rebuildColumnRights
		"Private - reconstruct the columnRights variable."
	| columnRight |
	columnRights := Array new: numberOfColumns.
	columnRight := defaultCellWidth.
	1 to: columnRights size do: [ :i |
		columnRights at: i put: columnRight.
		columnRight := columnRight + defaultCellWidth ]! 
activeEditor
        "Private - answer the active cell editor."
	^activeEditor! 
display
		"Do nothing."! 
isRowLabelVisible: aRowNumber
        "Private - answer if the label for aRowNumber is visible."
    ^self cellsInRectangle origin y <= aRowNumber and: [
        self cellsInRectangle corner y >= aRowNumber ]!  
newNumberOfRows: anInteger
        "Private - the number of rows has changed.
        If the number of rows has increased, create
        a new rowBottoms Array of the proper size."
    | newRowBottoms currentRowBottom |
    anInteger = numberOfRows ifTrue: [ ^self ].
    anInteger > rowBottoms size
        ifTrue: [
            newRowBottoms := Array new: anInteger.
            1 to: ( rowBottoms size min: anInteger ) do: [ :i |
                newRowBottoms at: i put: ( rowBottoms at: i ) ].
            currentRowBottom := rowBottoms size = 0
                ifTrue: [ self defaultCellHeight ]
                ifFalse: [ rowBottoms last + self defaultCellHeight ].
            rowBottoms size + 1 to: newRowBottoms size do: [ :i |
                newRowBottoms at: i put: currentRowBottom.
                currentRowBottom := currentRowBottom + self defaultCellHeight ].
            rowBottoms := newRowBottoms ].
    numberOfRows := anInteger!
computeCellsWhollyInRectangle: aRectangle
        "Private - answer which cells are wholly in aRectangle.
        aRectangle is window coordinates.
        The answer is cell coordinates (i.e. origin left top)."
    | origin left top width height right bottom |
    origin := self topLeftCellAddress.
    left := origin x.
    top := origin y.
    [ left < self numberOfColumns and: [
        ( self leftOfColumn: left + 1 ) isLeftEqualOf: aRectangle left ]]
            whileTrue: [ left := left + 1 ].
    [ top < self numberOfRows and: [
        ( self topOfRow: top + 1 ) isAboveEqual: aRectangle top ]]
            whileTrue: [ top := top + 1 ].
    width := 0.
    [ right := width + left + 1.
        right <= self numberOfColumns and: [
            ( self rightOfColumn: right ) isLeftOf: aRectangle right ]]
                whileTrue: [ width := width + 1 ].
    height := 0.
    [ bottom := height + top + 1.
        bottom <= self numberOfRows and: [
            ( self bottomOfRow: bottom ) isAbove: aRectangle bottom ]]
                whileTrue: [ height := height + 1 ].
    ^left @ top extent: width @ height
!   
columnAt: anIntegerOrName put: aCollection
        "Put aCollection at column anIntegerOrName."
    | columnNumber columnId row rect |
    self setModified.
    self indexedColumns
        ifTrue: [ columnNumber := columnId := anIntegerOrName ]
        ifFalse: [
            anIntegerOrName isInteger
                ifTrue: [
                    columnNumber := anIntegerOrName. "integer here"
                    columnNames size < columnNumber
                        ifTrue: [
                            columnNames := columnNames, ( Array new: columnNumber - columnNames size ) ].
                    columnId := columnNames at: columnNumber.
                    columnId isNil ifTrue: [
                        columnId := 'column', columnNumber printString ]]
                ifFalse: [
                    columnId := anIntegerOrName. "string here"
                    columnNumber := columnNames
                        indexOf: columnId
                        ifAbsent: [ "add column name"
                            columnNames := columnNames, ( Array with: columnId ).
                            columnNames size ]]].
    self insureRows: aCollection columns: columnNumber.
    self clearAllSelections.
    self rowsDo: [ :i |
        row := contents at: i.
        row at: columnId put: ( aCollection at: i ifAbsent: [ nil ] ) ].
    self setModified.
    rect := ( self leftOfColumn: columnNumber ) @ self columnLabelsBottom
                    rightBottom: ( self leftOfColumn: columnNumber + 1 ) @ rectangle bottom.
    graphicsTool execute: [ self displayIn: ( 0 @ 0 extent: self extent ) ] clipRect: rect

!   
displayColumnLabel: anInteger
        "Private - Display the column label."
	( self columnLabelEditorFor: anInteger ) display!  
isLegalContentsDefault: aString
        "Private - answer whether or not aString
        can be the contents of the receiver."
    ^self isNumberEditor
        ifTrue: [ self isLegalNumberContents: aString ]
        ifFalse: [ true ]!   
displayLabels
        "Display the row and column labels if the
        receiver has them."
	self pen font: self labelFont; foreColor: self foreColor.
    self hasCornerLabel
        ifTrue: [ self displayCornerLabel ].
    self hasColumnLabels
        ifTrue: [ self displayColumnLabels ].
    self hasRowLabels
        ifTrue: [ self displayRowLabels ]!  
keyboardInputEnd: aKeyboardInputEvent
        "Private - the <end> key was pressed."
	( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
		ifTrue: [
			^self releaseActiveEditor ].
    selectedCell isNil ifTrue: [ ^self userInputRejected ].
    aKeyboardInputEvent isControlKeyDown
        ifTrue: [ self selectCellAddress: numberOfColumns @ numberOfRows ]
        ifFalse: [ self selectCellAddress: numberOfColumns @ selectedCell y ].
    self insureSelectedCellIsVisible! 
bottomRowBottom
        "Private - answer the pixel coordinate of the
        bottom of the bottom most Row."
    ^self bottomOfRow: self numberOfRows!
wmKillfocus: wordInteger with: longInteger
        "Private - Process the kill focus message."
    
    self partsVwOnly.
    self destroyCaret.
    ^super wmKillfocus: wordInteger with: longInteger.! 
propertyNumberOfColumns: anInteger
	^self newNumberOfColumns: anInteger! 
numberOfColumns
        "Answer the number of columns in the receiver."
    ^numberOfColumns!   
intersects: aRectangle
    ^aRectangle left <= last and: [
        aRectangle right > first]!   
defaultLabelEditorClass
        "Private - answer the default class of the receiver's label editors."
	^PARTSTableLabelEditor!  
rowSelectionClass
        "Private - answer the class of row selections the receiver uses."
    ^PARTSRowsSelection!
displayRaisedRectangle: aRectangle
        "Private - do graphics to visually raise aRectangle."
	| insetRect |
	insetRect := self insetRectangleFor: aRectangle.
    self pen
        foreColor: Color white;
        place: insetRect leftBottom;
        goto: insetRect leftTop;
        goto: insetRect rightTop;
        foreColor: Color darkGray;
        goto: insetRect rightBottom;
        goto: insetRect leftBottom! 
rowLabelFor: anInteger
        "Answer the label for row number anInteger."
    | answer |
    ^anInteger > rowLabels size
        ifTrue: [ anInteger printString ]
        ifFalse: [
            answer := rowLabels at: anInteger.
            answer isNil
                ifTrue: [ anInteger printString ]
                ifFalse: [ answer ]]!  
selectAll
        "Select every cell."
    selectedGroup := PARTSEncompassingSelection on: self.
    selectedGroup display!
selectionEnd: anInteger
		"Private - set the receiver's selection end."
	selectionEnd := anInteger! 
initializeTextAlignment
		"Private - initialize the receiver's text alignment parameters."
	self
		setTextAlignLeft;
		setTextAlignBottom!
vwScrollVerticalPixels: anInteger
        "Private - Scroll the pane up by anInteger
         number of pixels (if positive) or down by
         the absolute value of anInteger (if negative)."
    | clipRect |
    self partsVwOnly.
    clipRect := 0 @ ( self columnLabelsBottom down: 1 ) rightBottom:
        rectangle rightBottom.
    self
        scrollBy: 0 @ anInteger
        scrollRect: clipRect
        clipRect: clipRect
        flags: SwScrollChildren.
	self updateWindow!
hasHorizontalGridLines: aBoolean
        "Set the receiver as to whether it
        has horizontal grid lines."
    self propertyAt: #hasHorizontalGridLines put: aBoolean!
insureCellsExtent: aTablePoint
    | oldRow newRow column |
    self insureRowsSize: aTablePoint y.
    oldRow := self rowAt: aTablePoint y.
    oldRow == nil ifTrue: [ ^self ].        "back out if row does not exist."
    self indexedColumns
        ifTrue: [        "indexed columns"
            oldRow size < aTablePoint x
                ifTrue: [
					newRow := Array new: aTablePoint x.
					newRow replaceFrom: 1 to: oldRow size with: oldRow.
                    self atRow: aTablePoint y put: newRow ]]
        ifFalse: [        "named columns"
            1 to: aTablePoint x do: [: i |
                column := columnNames at: i ifAbsent: [nil].
                column == nil ifFalse: [
                	oldRow at: column ifAbsent: [
                        oldRow at: column put: nil ]]]]!
createCaretAt: aPoint height: anInteger
        "Private - Create a flashing caret."
    self
        partsIfOS2Do: [
            self vos2CreateCaretAt: aPoint height: anInteger ]
        partsIfWindowsDo: [
            self vwCreateCaretAt: aPoint height: anInteger ]!  
removePartRuntimeLibrary
        " Remove the TablePane part runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!
propertyNumberOfRows: anInteger
	^self newNumberOfRows: anInteger!   
propertyIndexedColumns
        "Answer whether the receiver uses indexed columns access."
    ^self indexedColumns! 
textOriginXCentered
        "Private - answer the x coordinate
        of the text origin for centered text."
    ^ boundingBox center x left: self stringWidth // 2!  
reverse: aRow
    pane reverseRowNumber: aRow!   
showCaret
        "Private - show the caret."
    tablePane showCaret!  
defineColumnEditor: aCellEditor forColumnAddress: aColumnAddress
        "Private - define the cell editor for the column at aColumnAddress."
    columnEditors isNil ifTrue: [
        columnEditors := Dictionary new ].
    columnEditors at: aColumnAddress put: aCellEditor! 
columnAccessorFor: anIntegerOrName
        "Private - answer an object for accessing a column based on anIntegerOrName."

    ^self indexedColumns
        ifTrue: [
            anIntegerOrName isInteger
                ifFalse: [ self error: 'Illegal table column accessing object.' ].
            anIntegerOrName ]
        ifFalse: [
            anIntegerOrName isInteger
                ifTrue: [ self columnNameForInteger: anIntegerOrName ]
                ifFalse: [ anIntegerOrName ]]
!   
cornerLabelEditorClass
        "Private - answer the class of the receiver's corner label editors."
	^PARTSTableCornerLabelEditor!  
checkMouseResizeRowsAt: aPoint selectionButton: aBoolean
        "Private - answer if a mouse resize operation should
        occur at aPoint.  aBoolean indicates whether the
        selection mouse button is to be used.  Perform the
        mouse sizing action if appropriate."
    | row |
    aBoolean
        ifTrue: [
            self propertySelectionMouseButtonResizes
                ifFalse: [ ^false ]]
        ifFalse: [
            self propertyOtherMouseButtonResizes
                ifFalse: [ ^false ]].
    row := self rowToSizeAt: aPoint y.
    row isNil ifTrue: [ ^false ].
    row = 0
        ifTrue: [ self mouseResizeColumnLabelsHeightAt: aPoint selectionButton: aBoolean ]
        ifFalse: [ self mouseResizeRow: row at: aPoint selectionButton: aBoolean ].
    ^true!
propertySelectMouseButtonResizes: aBoolean
		"Private - set whether the mouse
		selection button resizes rows and
		columns."
	^self
		propertyAt: #propertySelectMouseButtonResizes
		put: ( aBoolean ifTrue: [ true ] ifFalse: [ nil ] )! 
displayTextInteractive
        "Private - the receiver is being edited.  Display the receiver's
        text knowing the text may be scrolled right or left."
    | text |
    cellContents isNil ifTrue: [ ^self ].
    text := self stringContents.
    self displayTextInteractive: text!
keyboardInputControlTab: aKeyboardInputEvent
        "Private - the tab key was pressed with the control
        key held down."
    aKeyboardInputEvent isShiftKeyDown
        ifFalse: [
            [ ( self tabScope nextTabStop: self ) setFocus ]
                on: Error
                do: [ :e | ^self  "Stack overflow because no valid tab stop " ]]
        ifTrue:  [
           [ ( self tabScope previousTabStop: self ) setFocus ]
            on: Error
            do: [ :e | ^self ]]!   
makeGetSelectorFor: aString at: aColumnIndex
    | answer |
    aString isString ifTrue: [
        answer := aString select: [ :c | c isAlphaNumeric]].
    ((answer size = 0) or: [answer first isDigit]) ifTrue: [
        answer := 'column', aColumnIndex printString].
    ^answer asSymbol!   
rectangleForCell: aCellAddress
        "Private - answer the bounding box of aCellAddress."
    | left right top bottom |
    left := self leftOfColumn: aCellAddress x.
    right := self rightOfColumn: aCellAddress x.
    top := self topOfRow: aCellAddress y.
    bottom := self bottomOfRow: aCellAddress y.
    ^Rectangle leftBottom: left @ bottom rightTop: right @ top!
namedRowsNamedColumns
        "Private - configure the internal contents storage to support
        access by name for both rows and columns."
    | rowName row oldRow oldContents |
    oldContents := contents.
    contents := Dictionary new.
    oldContents isArray
        ifTrue: [
            1 to: oldContents size do: [ :i |
                oldRow := oldContents at: i.
                row := self convertRowToNamedAccess: oldRow.
                rowName := self rowNameForInteger: i.
                contents at: rowName put: row ]]
        ifFalse: [
            oldContents associationsDo: [ :assoc |
                rowName := assoc key.
                oldRow := assoc value.
                 row := self convertRowToNamedAccess: oldRow.
                contents at: rowName put: row ]]!  
editorForCellContents: anObject
        "Answer a cell editor for a cell containing anObject."
    ^self defaultCellEditor! 
beginSelectAt: aPoint
        "Private - the user has begun a mouse selection
        in the receiver.  Do nothing."!   
clear
    self display!  
keyboardInputBacktab: aKeyboardInputEvent
        "Private - the tab key was pressed with the shift key
        held down."
    ( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
        ifTrue: [
            ^self releaseActiveEditor ].
    ( selectedCell notNil and: [ selectedCell x > 1 | ( selectedCell y > 1) ] )
        ifTrue: [
            selectedCell x > 1
                ifTrue: [
                    self selectCellAddress: selectedCell x - 1 @ selectedCell y ]
                ifFalse: [
                    self selectCellAddress: numberOfColumns @ ( selectedCell y - 1 ) ].
            self insureSelectedCellIsVisible ]
        ifFalse: [
            self tabKeyInput: aKeyboardInputEvent ]!
currentCursorAt: aPoint
        "Private - Answer the mouse cursor that's
         appropriate for the receiver."
	^Cursor!
scrollHorizontal: anInteger
        "Scroll the pane left by anInteger
         number of rows (if positive) or right by
         the absolute value of anInteger (if negative)."
    | amountToScroll offset |
    anInteger positive
        ifTrue: [
            amountToScroll := ( anInteger min: ( topCorner x - 1 )  ) negated ]
        ifFalse: [
            amountToScroll := anInteger negated.
            topCorner x to: topCorner x + amountToScroll do: [ :column |
                offset := ( self rightOfColumn: column ) - ( self rightOfColumn: topCorner x ).
                ( self rightColumnRight - offset isLeftOf: rectangle right )
                    ifTrue: [ ^self scrollHorizontalReal: ( column - topCorner x ) negated ]]].
    self scrollHorizontalReal: amountToScroll negated.
	self updateHorizontalSlider.!   
propertyUpdateRowAttributes: aDictionary
        "Private - update the receiver's row attributes
        as per aDictionary.  The keys in aDictionary are
        row numbers, the values are PARTSTableCellAttributes."
    aDictionary associationsDo: [ :assoc |
        self updateRow: assoc key attributes: assoc value ]! 
selectColumnNumber: anInteger
        "Select the column numbered anInteger."
    | column |
	self propertyEditColumnLabels ifTrue: [
		^self editColumnLabel: anInteger ].
    self clearAllSelections.
    selectedGroup := ( self columnSelectionClass on: self ) column: anInteger.
    selectedGroup display.
    ( self hasActionForEvent: #columnSelected: )
        ifTrue: [
            column := self indexedColumns
                ifTrue: [ anInteger ]
                ifFalse: [ columnNames at: anInteger ifAbsent: [ nil ]].
             self triggerEvent: #columnSelected: with: column ]!  
propertyRowLabelWidth: anInteger
	rowLabelsWidth := anInteger!   
hasHorizontalGridLines
        "Answer whether the receiver has horizontal grid lines."
    ^self propertyAt: #hasHorizontalGridLines ifAbsent: [ true ]!   
backColor: aColor
        "Set the receiver's backColor."
    backColor := aColor!  
convertRowToIndexedAccess: anArrayOrDictionary
        "Private - answer a row representation or anArrayOrDictionary
        that supports named column access."
    | answer columnName columnValue |
    anArrayOrDictionary isArray ifTrue: [ ^anArrayOrDictionary ].
    answer := Array new: columnNames size.
    1 to: columnNames size do: [ :i |
        columnName := self columnNameForInteger: i.
        columnValue := anArrayOrDictionary at: columnName ifAbsent: [ nil ].
        answer at: i put: columnValue ].
    ^answer!
defaultFont
        "Answer the default font for all cell editors."
    DefaultFont isNil ifTrue: [ self defaultFont: self createDefaultFont ].
    ^DefaultFont!  
cellAtPoint: aPoint
        "Answer the value in the table pane at aPoint. aPoint is cell coordinates."
    | row |
    row := self rowAt: aPoint y.
    row size = 0 ifTrue: [ ^nil ].
    self indexedColumns
        ifTrue: [ ^row at: aPoint x ifAbsent: [ nil ]]
        ifFalse: [ ^row at: ( columnNames at: aPoint x ifAbsent: [ nil ] ) ifAbsent: [ nil ]]!  
extendTo: anInteger
    self extendToOffset: anInteger!  
indexedRows: aBoolean
        "Set whether the receiver uses indexed rows access."
    self propertyAt: #indexedRows put: ( aBoolean ifTrue: [ true ] ifFalse: [ nil ] ).
    self updateAccess!   
displayBackgroundInteractive
        "Private - the reciever is being edited.
        Blank the background."
    self pen fill: boundingBox color: self backColor! 
displayCell: aCellAddress
        "Display the contents of the cell at aCellAddress."
    | cellContents cellEditor |
    cellContents := self cellAtPoint: aCellAddress.
    cellEditor := self editorForCellAddress: aCellAddress.
    cellEditor isNil ifTrue: [
        ^self ].
    cellEditor display!   
setTextAlignTop
		"Configure the receiver to display and edit text at the
		top of the receiver's bounding box."
	textOriginYSelector := #textOriginYTop!  
vos2ClippingBoxForRect: aRectangle
        "Private - answer a clipping box which clips to the INSIDE
        of aRectangle."
   ^( aRectangle leftTop right: 1 ) rightBottom: ( aRectangle rightBottom up: 1 )!   
columnLabelEditorFor: anInteger
        "Private - answer a column label editor for anInteger."
     | answer cellRectangle |
    	answer :=  self columnLabelEditorClass new.
    cellRectangle := self rectangleForColumnLabel: anInteger.
    answer
		columnNumber: anInteger;
		cellContents: ( self columnLabelFor: anInteger );
		tablePane: self;
		boundingBox: cellRectangle.
	^answer!   
singleSelectTopLeftCornerAt: aPoint
        "Private - the user has performed a mouse  single
        select operation."
	self superPartIsEditing ifTrue: [
		^self editCornerLabel ].
	self propertyEditColumnLabels | self propertyEditRowLabels
		ifTrue: [ ^self editCornerLabel ].
    self clearAllSelections; selectAll!
keyboardInputRight
        "Private - the right arrow key was pressed.
        Do nothing."!
reverse: aColumn
    pane reverseColumnNumber: aColumn!  
isCellVisible: aCellAddress
        "Answer if the cell at aCellAddress is visible."
    | left right top bottom |
    left := self cellsInRectangle origin x.
    right := self cellsInRectangle corner x.
    top := self cellsInRectangle origin y.
    bottom := self cellsInRectangle corner y.
    ^aCellAddress x >= left and: [
        aCellAddress x <= right and: [
            aCellAddress y >= top and: [
                aCellAddress y <= bottom ]]]!   
stringContents
        "Private - answer a string representing the receiver's contents."
    ^cellContents isNil
        ifTrue: [ String new ]
        ifFalse: [
            cellContents isString
                ifTrue: [ cellContents ]
                ifFalse: [
                    cellContents isAssociation
                        ifTrue: [ cellContents key ]
                        ifFalse: [ self convertToString: cellContents ]]]! 
propertyEditRowLabels
	^self getBooleanProperty: #propertyEditRowLabels! 
columnLabels
        "Answer the column labels of the receiver."
    ^columnLabels! 
createDefaultFont
        "Private - create and answer the default font for all cell editors."
    ^PARTSHostInterface defaultPartFont! 
propertyCellWidth: anInteger
	self
		defaultCellWidth: anInteger;
		rebuildColumnRights!   
paneRectangle
        "Private - answer a rectangle in pane coordinates."
    ^pane paneRectForCellRect: rectangle! 
reverseRectangle: aRectangle
        "Private - reverse aRectangle."
	(( aRectangle left isLeftOf: aRectangle right ) and: [
		aRectangle top isAbove: aRectangle bottom ] )
			ifFalse: [ ^self ].
    self doGraphics: [
        graphicsTool reverse: aRectangle ]!  
rowLabelsWidth: anInteger
        "Private - set the width of the the row labels."
    rowLabelsWidth := anInteger! 
isRightJustified
        "Private - answer true if the receiver is right justified."
    ^textOriginXSelector == #textOriginXRight! 
copySelection
		"Copy the selected text to the clip board."
	Clipboard setString: self selectedText!
rowLabelsColor: aColor
        "Set the color of the row labels."
    self propertyAt: #rowLabelsColor put: aColor! 
display
        "Display the receiver's contents."
	self configurePen.
	self pen
		execute: [
			self
				displayBackground;
				displayText ]
		clipRect: boundingBox!   
hasVerticalGridLines
        "Answer whether the receiver has vertical grid lines."
    ^self propertyAt: #hasVerticalGridLines ifAbsent: [ true ]! 
pane: aTablePane
        "Private - set the receiver's table pane."
    pane := aTablePane! 
keyboardInputLeft
        "Private - the left arrow key was pressed.
        Move the caret."
    insertionOffset = 0 ifTrue: [ ^self userInputRejected ].
    self hideCaret.
    self clearSelection.
    insertionOffset := insertionOffset - 1.
    [ self insertionOffsetPixelX isLeftOf: self clippingBox left ]
        whileTrue: [ self scrollRight: 1 ].
    self updateCaret! 
propertyLabelFont
        "Answer the receiver's label font."
    ^self
        propertyAt: #propertyLabelFont
        ifAbsent: [ self font ]!   
propertySelectMouseButtonResizes
		"Private - answer whether the mouse
		selection button resizes rows and
		columns."
	^self propertyAt: #propertySelectMouseButtonResizes ifAbsent: [ false ]!  
wmEnddrag: mp1 with: mp2
        "Private - a mouse drag operation has just ended."
    self sendInputEvent: #endDragAt: with: mp1 asPoint.
    ^super wmEnddrag: mp1 with: mp2!   
deleteKey
        "Private - the user has  typed the <delete> key."
    | stringContents left right |
    self selectedText size > 0 ifTrue: [ ^self removeSelectedText ].
    stringContents := self stringContents.
    insertionOffset = stringContents size ifTrue: [ ^self ].
    left := stringContents copyFrom: 1 to: insertionOffset.
    right := stringContents copyFrom: insertionOffset + 2 to: stringContents size.
    stringContents := left, right.
    self stringContents: stringContents.
    self updateCaret.
    self updateDisplay.!   
clippingBoxForRect: aRectangle
        "Private - answer a clipping box which clips to the INSIDE
        of aRectangle."
    ^self
        partsIfOS2Do: [ self vos2ClippingBoxForRect: aRectangle ]
        partsIfWindowsDo: [ self vwClippingBoxForRect: aRectangle ]!   
updateDisplayColumn: aColumn
        "Private - update the display for aColumn."
    self canUpdateDisplay ifTrue: [
        self invalidateRect: ( self rectangleForColumn: aColumn ) ]!  
updateDisplay
        "Private - update the display of the receiver."
    ( self stringWidthOf: self stringContents ) +
		self textOriginLeftOffset + self textOriginRightOffset
			< self clippingBox width
        			ifTrue: [ displayOffset := 0 ].
    self isCellVisible ifTrue: [ self displayInteractive ]! 
defineCornerLabelEditor: anEditor
		"Private - set the corner label editor."
	cornerLabelEditor := anEditor!
wmSetfocus: wordInteger with: longInteger
        "Private - Process the set focus message."

    self
        partsIfOS2Do: [
            longInteger asBoolean
                ifTrue: [
                    self disabled ifFalse: [
                        self createCaretAt: -200@0.
                        self showCaret ]]
                ifFalse: [ self destroyCaret ]]
        partsIfWindowsDo: [
            self createCaretAt: -200@0.
            self showCaret ].
    ^super wmSetfocus: wordInteger with: longInteger.!  
button2Down: aPoint
        "Private - The user pressed down button2 at aPoint."
    self partsIfWindowsDo: [
        self setFocus.
        self beginDragAt: aPoint ]!  
cellAtRow: aRow column: aColumn
        "Answer the value in the cell identified by the named
         aRow - aColumn. ."
    | row columnId |
    row := self rowAt: aRow.
    row == nil ifTrue: [ ^nil ].
    columnId := self columnAccessorFor: aColumn.
    ^row at: columnId ifAbsent: [ nil ]! 
extendTo: anInteger
    self extendToOffset: anInteger!  
setRowLabels: anArray
    rowLabels := anArray.
    self displayLabels! 
popUpMenuAt: aPoint
		"Private - the user has performed the mouse operation to pop up a menu."!  
displayOffset: anInteger
		"Private - set the receiver's display offset."
	displayOffset := anInteger!  
directEditCellsAt: aPoint
        "Private - the user has performed a direct edit
        operation with the mouse.  This is typically the
		result of left mouse button down with the alt
		key held down.  Do nothing."!
row
    ^anchorIndex!
textOriginXSelector
        "Private - answer the receiver's text origin x selector."
    ^textOriginXSelector! 
resizeCells
		"Private - something has happened to cause
		the cells to recompute their sizes."
	self computeCellsInRectangle! 
mouseResizeColumn: anInteger at: aPoint selectionButton: aBoolean
        "Private - the user is using the mouse to resize
        the column at anInteger with the mouse starting
        hotspot at aPoint."
    | newRightBorder oldRightBorder offset updateRectangle |
    newRightBorder := self mouseMoveColumnRight: anInteger from: aPoint selectionButton: aBoolean.
    oldRightBorder := self rightOfColumn: anInteger.
    offset := oldRightBorder - newRightBorder.
    offset = 0 ifTrue: [ ^self ].
    anInteger to: columnRights size do: [ :i |
        columnRights at: i put: ( columnRights at: i ) - offset ].
    updateRectangle := ( self leftOfColumn: anInteger ) @ rectangle top
        rightBottom: rectangle rightBottom.
    self invalidateRect: updateRectangle; updateSliders; computeCellsInRectangle.!
columnLabelsColor: aColor
        "Set the color of the column labels."
    self propertyAt: #columnLabelsColor put: aColor!
directEditTopLeftCornerAt: aPoint
        "Private - the user has performed a direct edit
        operation with the mouse.  This is typically the
		result of left mouse button down with the alt
		key held down."
	self propertyAltClickEditLabels ifFalse: [ ^self ].
    self editCornerLabel! 
virtualColumnLabelsHeight
        "Private - answer the virtual colum labels height.
        If the reveiver doesn't display column labels answer
        0.  We do not store 0 in the columnLabelsHeight
        var because the developer may want to switch back
        to showing labels so we remember the old
        columnLabelsHeight."
    ^self propertyDisplayColumnLabels
        ifTrue: [ columnLabelsHeight ]
        ifFalse: [ -2 ]!  
propertyAdjustRowHeights
	^self getBooleanProperty: #propertyAdjustRowHeights!   
partSetContents: aDictionary
        "Set the row and column information of the receiver.
        This is not a well named method.  Do nothing as this
        is handled by the PARTSPropertyTablePane in the
        property structure."!  
objectContents
        "Private - answer the object displayed by the receiver."
    ^cellContents isAssociation
        ifTrue: [ cellContents value ]
        ifFalse: [ cellContents ]! 
getCell: columnName arguments: anArray
    | columnNumber |
    columnNumber := self getCellMessages indexOf: columnName
        ifAbsent: [^nil].
    ^self cellAtPoint: columnNumber @ currentRow!  
indexedRowsIndexedColumns
        "Private - configure the internal contents storage to support
        access by index for both rows and columns."
    | oldContents oldRow row rowName rowIndex |
    oldContents := contents.
    oldContents isArray
        ifTrue: [
            contents := Array new: oldContents size.
            1 to: oldContents size do: [ :i |
                oldRow := oldContents at: i.
                row := self convertRowToIndexedAccess: oldRow.
                contents at: i put: row ]]
        ifFalse: [
            contents := Array new: rowNames size.
            oldContents associationsDo: [ :assoc |
                rowName := assoc key.
                rowIndex := rowNames indexOf: rowName.
                oldRow := assoc value.
                 row := self convertRowToIndexedAccess: oldRow.
                contents at: rowIndex put: row ]]!
defaultLabelBackColor
        "Private - answer the receiver's default label background color."
    ^Color buttonFace!  
openItemColumnLabelsAt: aPoint
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click) on one of the receiver's column labels."
    | column |
    column := self columnNumberFor: aPoint x.
	self indexedColumns ifFalse: [
		column := self columnNameFor: column ].
    self triggerEvent: #doubleClickedOnColumn: with: column! 
getBooleanProperty: aSymbol
		"Private - answer the boolean property aSymbol."
	^( self propertyAt: aSymbol ) notNil!   
displaySelection
        "Private - display the receiver's selected text, if any."
    self selectedText size > 0 ifFalse: [ ^self ].
    self reverseSelection!   
displayClipOption
        " Private - platform-dependent drawing options "
    ^DtoClipText!
rowLabelEditor: aRowNumber
		"Private - answer the row label editor for aRowNumber,
		if any."
	rowLabelEditors isNil ifTrue: [ ^nil ].
	^rowLabelEditors at: aRowNumber ifAbsent: [ nil ]!   
partRealSelectorFor: aSelector
        " Answer the message to send for an alias link
        to access a field of the current record. "

    ( self setCellMessages includes: aSelector )
        ifTrue: [ ^#setCell:arguments: ].
    ( self getCellMessages includes: aSelector )
        ifTrue: [ ^#getCell:arguments: ].
    ^aSelector!   
verticalGridLineColor
        "Answer the vertical grid line color."
    ^self propertyAt: #verticalGridLineColor ifAbsent: [
        self foreColor isNil
            ifTrue: [ SystemColorWindowText ]
            ifFalse: [ self foreColor ]]!   
keyboardInputTab: aKeyboardInputEvent
        "Private - the tab key was pressed."
    ( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
        ifTrue: [
            ^self releaseActiveEditor ].
    aKeyboardInputEvent isControlKeyDown
        ifTrue: [
            ^self keyboardInputControlTab: aKeyboardInputEvent ].
    self
        triggerEvent: #tabbed
           ifNotHandled: [
            self keyboardInputTabDefault: aKeyboardInputEvent ]!
newSelectedRectangle: newSelectedRectangle old: oldSelectedRectangle
        "Private - the selected rectangle has been adjusted.  Update the display."
     | paneNew paneOld intersect selectedCellRect |
    paneNew := newSelectedRectangle paneRectangle.
    oldSelectedRectangle notNil
        ifTrue: [
            paneOld := oldSelectedRectangle paneRectangle.
            intersect := paneNew intersect: paneOld ]
        ifFalse: [
                intersect := paneNew ].
    intersect rightBottom: ( intersect rightBottom left: 1 ).
    (( intersect left isLeftOf: intersect right ) and: [
        intersect top isAbove: intersect bottom ] )
            ifTrue: [
                intersect leftTop: ( intersect leftTop down: 1 ).
                graphicsTool excludeClipRect: intersect ].
    (selectedCell notNil "and: [ visibleRect containsPoint: selectedCell ]" )
        ifTrue: [
            selectedCellRect := self selectedCellExcludeRectangle.
            graphicsTool excludeClipRect: selectedCellRect ].
    paneOld notNil ifTrue: [ self reverseRectangle: paneOld ].
    self reverseRectangle: paneNew.
    graphicsTool setClipRect: nil!   
columnWidth: anInteger
        "Answer the width of column number anInteger."
    ^( self rightOfColumn: anInteger ) - ( self leftOfColumn: anInteger )!
directEditAt: aPoint
        "Private - the user has initiated a direct edit operation
        (typically Alt-left mouse button click).  Do nothing."!  
beginSelectTopLeftCornerAt: aPoint
       "Private - the user has performed a mouse begin selection operation."
    ( self propertySelectionMouseButtonResizes or: [
		self superPartIsEditing ] )
        ifTrue: [
            ( self checkMouseResizeColumnsAt: aPoint selectionButton: true )
                ifTrue: [ ^self ].
            ( self checkMouseResizeRowsAt: aPoint selectionButton: true )
                ifTrue: [ ^self ]].
	self superPartIsEditing ifTrue: [
		^self editCornerLabel ].
    self singleSelectTopLeftCornerAt: aPoint! 
setColumn: aColumnNumber attributes: aCellAttributes
        "Private - set the column aColumnNumber to have
        the attributes defined in aCellAttributes."
    | editor |
    editor := aCellAttributes asCellEditor.
    self setColumn: aColumnNumber editor: editor!
selectionButtonUpSelector
        "Private - answer the selector for the
        message that will be sent to indicate
        the conclusion of a mouse selection
        operation."
    ^self
        partsIfOS2Do: [ #endSelectAt: ]
        partsIfWindowsDo: [ #button1Up: ]!
mouseResizeRow: anInteger at: aPoint selectionButton: aBoolean
        "Private - the user is using the mouse to resize
        the row at anInteger with the mouse starting
        hotspot at aPoint.  aBoolean indicates whether or
		not the mouse selection button is being used."
    | newBottomBorder oldBottomBorder offset updateRectangle |
    newBottomBorder := self mouseMoveRowBottom: anInteger from: aPoint selectionButton: aBoolean.
    oldBottomBorder := self bottomOfRow: anInteger.
    offset := oldBottomBorder - newBottomBorder.
    offset = 0 ifTrue: [ ^self ].
    anInteger to: rowBottoms size do: [ :i |
        rowBottoms at: i put: (( rowBottoms at: i ) up: offset ) ].
    updateRectangle := rectangle left @ ( self topOfRow: anInteger )
        rightBottom: rectangle rightBottom.
    self invalidateRect: updateRectangle; updateSliders; computeCellsInRectangle.!
extendLesser
    mobileIndex > anchorIndex ifTrue: [self reverse: mobileIndex].
    mobileIndex := mobileIndex - 1.
    mobileIndex < anchorIndex ifTrue: [self reverse: mobileIndex]! 
propertyLabelBackColor
        "Answer the receiver's label background color."
    ^self
        propertyAt: #propertyLabelBackColor
        ifAbsent: [ self defaultLabelBackColor ]!
validationMessage
		"Answer the message that will be evaluated
		to test if an input is acceptable."
	^validationMessage!  
displayAsActiveCell
        "Private - display the receiver with the visual
        cues to indicate that it is the active cell."
    self displayInteractive.
    self displayFocusedCell.!  
initializeBooleanPropertiesMap
		"Private - initialize the receiver's boolean properties map.
		This dictionary maps "! 
propertySelectionMouseButtonResizes: aBoolean
        "Private - set whether the mouse
        selection button resizes rows and
        columns."
    ^self setBooleanProperty: #propertySelectionMouseButtonResizes to: aBoolean!   
propertyDisplayRowLabels
	^self getBooleanProperty: #propertyDisplayRowLabels!   
selectCellAddress: aCellAddress
        "Select the cell at aCellAddress."
    | cellContents selectedIndex |
    self clearAllSelections.
    cellContents := self cellAtPoint: aCellAddress.
    self activeEditor: ( self editorForCellAddress: aCellAddress ) copy.
    self
        activeEditor cellContents: cellContents;
            reinitialize.
    selectedCell := aCellAddress.
    self activeEditor displayFocusedCell.
    self activateSelectedCellEditor.
    selectedIndex := self selectedIndex. "compute this before triggering the events"
    self
        triggerEvent: #selectedCell: with: cellContents;
        triggerEvent: #selectedPoint: with: aCellAddress;
        triggerEvent: #selectedIndex: with: selectedIndex
!
deactivate
        "Private - deactivate the receiver and store the contents
		of the receiver back into that table pane."
	self storeContents!
validationMessage: aMessage
		"Set the message that will be evaluated
		to test if an input is acceptable.  Prior to
		evaluation, this message's arguments will
		be set to an Array of one which contains
		the candidate new contents."
	validationMessage := aMessage!  
columnRights: anArray
        "Private - set the column rights array."
    columnRights := anArray! 
contents
    | paneContents answer row rowIndex columnName |
    paneContents := pane contents.
    answer := pane indexedRows
        ifTrue: [Array new: paneContents size]
        ifFalse: [Dictionary new].
    pane rowsDo: [ : i |
        pane indexedColumns
            ifTrue: [
                row := Array new: last - first + 1.
                1 to: row size do: [ :ri |
                rowIndex := pane indexedRows
                    ifTrue: [ i]
                    ifFalse: [pane rowNames indexOf: i ifAbsent: [^nil]].
                    row at: ri put: (pane cellAtPoint: (ri + first - 1) @ rowIndex)]]
            ifFalse: [
                row := Dictionary new.
                first to: last do: [: ci |
                    columnName := pane columnNames at: ci ifAbsent: [nil].
                    columnName isNil ifTrue: [^nil].
                    row at: columnName put: (
                        pane cellAtRow: i column: columnName)]].
        answer at: i put: row].
    ^answer!  
selectedCellContents
        "Answer the contents of the selected cell."
    ^self cellAtPoint: selectedCell!   
drawInvertVerticalLineAt: anXCoordinate
        "Private - draw a vertical line at anXCoordinate
        using an inert draw operation."
    | top bottom |
    top := anXCoordinate @ rectangle top.
    bottom := anXCoordinate @ ( rectangle bottom higherOf: self bottomRowBottom ).
    graphicsTool
    "    setMix: MixRuleInvertSurface;"
		setForegroundMode: MixRuleInvertSurface;
        place: top;
        goto: bottom;
    "    setMix: MixRuleDefault"
        setForegroundMode: MixRuleDefault!
cellAddressFor: aPoint
        "Private - answer the cell address for aPoint.
        aPoint is in window coordinates."
    | row column |
    column := self columnNumberFor: aPoint x.
    column isNil ifTrue: [ ^nil ].
    row := self rowNumberFor: aPoint y.
    row isNil ifTrue: [ ^nil ].
    ^column @ row!
foreColor: aColor
        "Set the receiver's foreColor."
    foreColor := aColor!  
wordSelectionRightAt: anInteger
        "Private - answer the index of the end of
        the word at char index anInteger."
    | answer stringContents |
    answer := anInteger max: 1.
    stringContents := self stringContents.
    ( stringContents at: answer ) = Space
        ifFalse: [
            [ answer < stringContents size and: [
                ( stringContents at: answer ) ~= Space ]] whileTrue: [
                    answer := answer + 1 ]].
    [ answer < stringContents size and: [
        ( stringContents at: answer + 1 ) = Space ]] whileTrue: [
            answer := answer + 1 ].
    ^answer!   
rectangle
		"Private - answer the reciever's rectangle,
		which is cell addresses."
	^rectangle!   
defaultFont: aFont
        "Set the default font for all cell editors."
    DefaultFont := aFont!   
columnLeft: aColumnAddress
        "Private - answer the pixel x coordinate that is
        the left border of aColumnAddress disregarding
        the scroll offset and row labels width."
    ^aColumnAddress = 1
        ifTrue: [ 0 ]
        ifFalse: [ columnRights at: aColumnAddress - 1 ]! 
hasCornerLabel
        "Answer whether receiver has a corner label."
    ^ self hasRowLabels and: [ self hasColumnLabels ]! 
display
    self displayIn: rectangle!   
displayEncompassingSelection: anEncompassingSelection
        "Private - display anEncompassingSelection."
    graphicsTool reverse: rectangle! 
row: anInteger
    anchorIndex := mobileIndex := first := last := anInteger! 
setValue: aCollection
        "Set the receiver's rows to aCollection.  The value can
          be an indexable collection or a nameable collection.
         Answer aCollection. "
    self clearAllSelections.
    topCorner := 1@1.
    self contents: aCollection.
	self invalidateRect: nil.
    ^aCollection!   
losingFocus
        "Private -  receiver's pane has lost the input focus."
    super losingFocus.
    self storeContents!  
isLegalContentsDefault: aString
        "Private - answer whether or not aString
        can be the contents of the receiver."
    ^self isNumberEditor
        ifTrue: [ self isLegalNumberContents: aString ]
        ifFalse: [ true ]!   
currentRowDown
    currentRow := currentRow + 1 min: numberOfRows!   
isColumnLabelVisible: aColumnNumber
        "Private - answer if the label for aColumnNumber is visible."
    ^self cellsInRectangle left <= aColumnNumber and: [
        self cellsInRectangle right >= aColumnNumber ]!  
propertyOtherMouseButtonResizes: aBoolean
        "Private - set whether the non-selection
        mouse button resizes rows and columns."
    ^self setBooleanProperty: #propertyOtherMouseButtonResizes to: aBoolean!
activateSelectedCellEditor
        "Private - activate the cell editor for the selected cell."
    self activeEditor isNil ifTrue: [ ^self ].
    self privateReadOnly ifTrue: [
        self activeEditor readOnly: true ].
    self activeEditor activate! 
displayHorizontalGridLines: gridRectangle
        "Private - display the horizontal grid lines."
    | y start stop |
    cellsToDisplay isNil ifTrue: [ ^self "receiver is not visible" ].
    self hasHorizontalGridLines ifFalse: [ ^self ].
    graphicsTool
        foreColor: self horizontalGridLineColor;
        setLineType: self horizontalGridLineType;
        place: gridRectangle leftTop;
        goto: gridRectangle rightTop.
    cellsToDisplay origin y to: ( cellsToDisplay corner y min: self numberOfRows ) do: [ :rowNumber |
        y := self bottomOfRow: rowNumber.
        start := gridRectangle left @ y.
        stop := gridRectangle right @ y.
        graphicsTool
            place: gridRectangle left @ y;
            down;
            goto: gridRectangle right @ y ]! 
wmBegindrag: mp1 with: mp2
        "Private - the user has performed a mouse begin selection operation."
    self partsVosOnly.
    self sendInputEvent: #beginDragAt: with: mp1 asPoint.
    ^nil!   
displayFocusedCell
        "Private - display the reciever with the visual cues
        to indicate that it is the selected cell."
    self isCellVisible ifTrue: [
        tablePane displaySelectedCellFocusDefaultIn: self focusRectangle ]!   
displayBackground
        "Display the receiver's background."
    graphicsTool
        fill: rectangle
        color: self backColor!
insertionOffsetPixelX
        "Private - answer the pixel x coordinate of the
        insertionOffset."
    ^self pixelXForOffset: insertionOffset!
isLegalContents: aString
        "Private - answer whether or not aString
        can be the contents of the receiver."
    validationMessage isNil ifTrue: [ ^self isLegalContentsDefault: aString ].
    validationMessage arguments size > 0
        ifTrue: [ validationMessage arguments at: 1 put: aString ]
        ifFalse: [ validationMessage arguments: ( Array with: aString ) ].
    ^validationMessage evaluate! 
contents
    ^pane contents! 
lafStopEdit
        "Private - stop direct editing. "
    self clearAllSelections.
    self frameWindow realInvalidateRect: nil!   
paneRectForCellRect: aCellRectangle
        "Private - answer a rectangle in terms pane coordinates.
        aCellRectangle is a rectangle in of cell address coordinates.
        This rectangle, when filled, will fill inside the left and top grid
        lines and on top of the right and bottom grid lines."
    | cellLeft cellRight cellTop cellBottom left top right bottom |
    cellLeft := ( aCellRectangle left min: aCellRectangle right ) max: 1.
    cellRight := aCellRectangle left max: aCellRectangle right.
    cellTop := ( aCellRectangle top min: aCellRectangle bottom ) max: 1.
    cellBottom := aCellRectangle top max: aCellRectangle bottom.
    left := ( self leftOfColumn: cellLeft ) rightMost: self rowLabelsRight.
    top := ( self topOfRow: cellTop ) lowerOf: self columnLabelsBottom.
    right := self rightOfColumn: cellRight.
    bottom := self bottomOfRow: cellBottom.
    self
        partsIfOS2Do: [
            left := left right: 1.
            bottom := bottom down: 1 ]
        partsIfWindowsDo: [
            left := left right: 1.
            bottom := bottom down: 1 ].
    ^left @ top rightBottom: right @ bottom!  
insureRowsSize: anIntOrCollection
        "Private - insure that the receiver's contents atleast
        as large as anIntOrCollection."
    | newRows row b rowSize |
    self indexedRows
        ifTrue: [        "indexed rows"
            rowSize := anIntOrCollection isInteger
                ifTrue: [anIntOrCollection]
                ifFalse: [anIntOrCollection size].
            contents size < rowSize
                ifTrue: [
                    newRows := Array new: rowSize.
                    newRows replaceFrom: 1 to: contents size with: contents.
                       contents size + 1 to: rowSize do: [ :i |
                          newRows at: i put: (
                            self indexedColumns
                                ifTrue: [Array new]
                                ifFalse: [Dictionary new])].
                    contents := newRows]]
        ifFalse: [        "named rows"
            b := [: rowName |
                contents at: rowName ifAbsent: [
                    contents at: rowName put: (
                            self indexedColumns
                                ifTrue: [ Array new ]
                                ifFalse: [ Dictionary new ] ) ]].
            anIntOrCollection isInteger
                ifTrue: [
                    1 to: anIntOrCollection do: [: i |
                        row := rowNames at: i ifAbsent: [ i printString ].
                        row == nil ifFalse: [ b value: row ]]]
                ifFalse: [
                    anIntOrCollection keysDo: [ :name |
                        row := rowNames indexOf: name  ifAbsent: [nil].
                        row == nil ifFalse: [b value: name]]]]!   
updateDisplayRow: aRow column:  aColumn
        "Private - update the display for the cell at aRow and aColumn."
	| x y |
	self indexedRows
		ifTrue: [ y := aRow ]
		ifFalse: [
			aRow isInteger
				ifTrue: [ y := aRow ]
				ifFalse: [
					y := rowNames indexOf:  aRow ifAbsent: [ ^nil ]]].
	self indexedColumns
		ifTrue: [ x := aColumn ]
		ifFalse: [
			aColumn isInteger
				ifTrue: [ x := aColumn ]
				ifFalse: [
					x := columnNames indexOf:  aColumn ifAbsent: [ ^nil ]]].
	self updateDisplayCell: x @ y!  
defaultInitialCellsExtent
        "Private - answer the default initial extent of the cells."
    ^100 @ 100!   
beginSelectColumnLabelsAt: aPoint
       "Private - the user has performed a mouse begin selection operation."
    | selector columnNumber newColumnNumber newPoint endSelectSelector |
    ( self propertySelectionMouseButtonResizes or: [
        self superPartIsEditing ] )
        ifTrue: [
            ( self checkMouseResizeColumnsAt: aPoint selectionButton: true )
                ifTrue: [ ^self ]].
    columnNumber := self columnNumberFor: aPoint x.
    columnNumber isNil ifTrue: [ ^self ].
    self superPartIsEditing ifTrue: [
        ^self editColumnLabel: columnNumber ].
    self propertyEditColumnLabels ifTrue: [
        ^self editColumnLabel: columnNumber ].
    self selectColumnNumber: columnNumber.
    endSelectSelector := self selectionButtonUpSelector.
    self captureMouseInput.
    selectionIsInProgress := true.
    Notifier consumeInputUntil: [ :e |
        e receiver == self ifFalse: [ e evaluate ].
        selector := e selector.
        ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
            ifTrue: [
                newPoint := e arguments first.
                newColumnNumber := self columnNumberFor: newPoint x.
                newColumnNumber isNil ifTrue: [
                    newColumnNumber := self numberOfColumns ].
                newColumnNumber := newColumnNumber max: 1.
                newColumnNumber = columnNumber ifFalse: [
                    selectedGroup extendTo: newColumnNumber.
                    columnNumber := newColumnNumber ]].
        selector == endSelectSelector ].
    self clearMouseCapture.
    selectionIsInProgress := false!  
superPartIsEditing
        "Private - answer the response to the inherited
        implementation of #partIsEditing."
    ^super partIsEditing!
copy
		"Answer a copy of the receiver."
	^self class new
		boundingBox: boundingBox;
		cellAddress: cellAddress;
		cellContents: cellContents;
		tablePane: tablePane;
		updateMessage: updateMessage;
		yourself!
textOriginXSelector: aSymbol
		"Private - set the receiver's text origin x selector."
	textOriginXSelector := aSymbol!  
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received."
    | virtualKey character |
    aKeyboardInputEvent isToggleKey ifTrue: [ ^self ].
    character := aKeyboardInputEvent character.
    virtualKey := aKeyboardInputEvent virtualKey.
    virtualKey = InsertKey ifTrue: [
        aKeyboardInputEvent isControlKeyDown
            ifTrue: [ ^self keyBoardInputControlInsert ]].
    self readOnly ifTrue: [ ^self userInputRejected ].
    character = Bs ifTrue: [ ^self backSpaceKey ].
    virtualKey = DeleteKey ifTrue: [ ^self deleteKey ].
    virtualKey = InsertKey ifTrue: [
        aKeyboardInputEvent isShiftKeyDown
            ifTrue: [ ^self keyBoardInputShiftInsert ].
        aKeyboardInputEvent isControlKeyDown
            ifTrue: [ ^self keyBoardInputControlInsert ].
        ^self ].
    ( aKeyboardInputEvent shiftState notNil and: [ aKeyboardInputEvent isControlKeyDown ] ) ifTrue: [
        ^tablePane controlKeyInput: aKeyboardInputEvent editor: self ].
    character isNil ifTrue: [ ^self ].
    aKeyboardInputEvent isControlKeyDown ifTrue: [
        ^tablePane controlKeyInput: aKeyboardInputEvent editor: self ].
    self insertString: ( String with: character )!
cornerLabelColor: aColor
        "Set the color of the top left corner label."
    self propertyAt: #cornerLabelColor put: aColor!  
convertToString: anObject
        "Private - answer a string representing anObject."
    ^anObject isFraction
        ifTrue: [
"            self makeFractionEditor."
            anObject printFraction ]
        ifFalse: [
            anObject isNil
                ifTrue: [ String new ]
                ifFalse: [ anObject asString ]]!
vwClippingBoxForRect: aRectangle
        "Private - answer a clipping box which clips to the INSIDE
        of aRectangle."
    ^( aRectangle leftTop rightAndDown: 1 ) rightBottom: aRectangle rightBottom!   
selectScrollDown
        "Private - the user is mouse selecting and is causing a scroll."
    ( self bottomRowBottom isAbove: rectangle bottom )
        ifFalse: [
            self
                scrollVertical: -1 ]!   
installPartRuntimeLibrary
        " Install the TablePane part runtime library.
        Load the workbench support library if appropriate. "

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'TablePane Part'.!
canScrollLeft
        "Private - answer if the receiver can
        scroll left."
    ^self rightColumnRight isRightOf: rectangle right!   
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received."
    | virtualKey character |
    self disabled ifTrue: [ ^nil ].
    character := aKeyboardInputEvent character.
    virtualKey := aKeyboardInputEvent virtualKey.
    aKeyboardInputEvent character == Cr ifTrue: [ ^self keyboardInputCr ].
    virtualKey == UpKey ifTrue: [ ^self keyboardInputUp ].
    virtualKey == DownKey ifTrue: [ ^self keyboardInputDown ].
    virtualKey == LeftKey ifTrue: [ ^self keyboardInputLeft ].
    virtualKey == RightKey ifTrue: [ ^self keyboardInputRight ].
    virtualKey == TabKey ifTrue: [ ^self keyboardInputTab: aKeyboardInputEvent ].
    virtualKey == BacktabKey ifTrue: [ ^self keyboardInputBacktab: aKeyboardInputEvent ].

    virtualKey == HomeKey ifTrue: [ ^self keyboardInputHome: aKeyboardInputEvent ].
    virtualKey == EndKey ifTrue: [ ^self keyboardInputEnd: aKeyboardInputEvent ].

    virtualKey == PageUpKey ifTrue: [ ^self scrollVertical: self amountToPageUp ].
    virtualKey == PageDownKey ifTrue: [ ^self scrollVertical: self amountToPageUp negated ].
    self activeEditor notNil
        ifTrue: [
            self activeEditor keyboardInput: aKeyboardInputEvent ]!   
hide
        "Private - hide the receiver."
    self display.!  
pixelXForOffset: anOffset
        "Private - answer the pixel x coordinate for a text offset
        of anOffset."
	| textOriginX substring substringWidth |
	textOriginX := self textOriginXInteractive.
	substring := self stringContents copyFrom: 1 to: anOffset.
	substringWidth := self stringWidthOf: substring.
	^textOriginX right: substringWidth!   
insertionOffsetAt: aPoint
        "Private - answer the character insertion index at aPoint."
	| x candidateX oldCandidateX |
	x := aPoint x.
	0 to: self stringContents size do: [ :i |
		candidateX := self pixelXForOffset: i.
		( candidateX isRightOf: x )
			ifTrue: [
				oldCandidateX isNil ifTrue: [ ^i ].
				^candidateX - x > ( x - oldCandidateX )
					ifTrue: [ i - 1 ]
					ifFalse: [ i ]]
			ifFalse: [
				oldCandidateX := candidateX ]].
	^self stringContents size!  
mouseSelectAt: aPoint
        "Private - the user has performed a mouse selection
        in the receiver."
    self clearSelection.
    self updateInsertionOffsetAt: aPoint.
    self updateCaret! 
reinitialize
        "Private - reinitialize the receiver."
    displayOffset := 0.
    insertionOffset := 0.
    modified := false.
    caretIsVisible := false.
    selectionEnd := nil!  
intersect: aRectangle
    ^aRectangle "copy?"!   
displaySelections
        "Display the selected cell and selected group."
    self displaySelectedGroup.
    self pen setForegroundMode: MixRuleDefault!   
isNumberEditor
        "Private - answer true if the receiver is a number editor."
    ^textOriginXSelector == #textOriginXRight and: [
        validationMessage isMessage and: [
            validationMessage selector == #isLegalNumberContents: ]]!  
undefineColumnEditor: aColumnAddress
        "Private - undefine the cell editor for the column at aColumnAddress."
    columnEditors isNil ifTrue: [ ^self ].
    columnEditors removeKey: aColumnAddress ifAbsent: [ ]!  
reactivateSelectedCellEditor
        "Private - the selected cell editor has been deactivated,
        because of an operation (like scrolling) that required it
        to be temporarily deatcivated. Reactivate it."!   
updateMessage: aMessage
		"Set the receiver's update message."
	updateMessage := aMessage!  
initialize
        "Private - initialize the receiver."
    ^super initialize!  
displaySelectedGroup
        "Display the selected group, if any."
    selectedGroup notNil ifTrue: [
        selectedGroup display ]! 
columnLabelsBottom
		"Private - answer the y coordinate of the bottom of the reciever's column labels."
    ^rectangle top down: self virtualColumnLabelsHeight!
topOffset
    ^0!
reactiveEditors: aCollection
		"Private - set the collection of cell editors that are reactive."
	^self propertyAt: #reactiveEditors put: aCollection!  
vwUpdateVerticalSlider
        "Private - Update the slider box in the vertical scrollbar."
    self partsVwOnly.
    ^super updateVerticalSlider! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    | list |
    list :=  #(
        #changed:
        #cellChanged:
        #cellChangedAtRow:column:value:
        #cellEnteredAtRow:column:value:
        #rowEntered:

        #rightClicked
        #tabbed

        #doubleClickedOnCell:
        #doubleClickedOnColumn:
        #doubleClickedOnRow:
        #rowSelected:
        #columnSelected:
        #selectedCell:
        #selectedPoint:
        #selectedGroup:
        #selectedIndex:

        #userInputRejected ).

    ^PARTSInterfaceList new
        items: list
        separators: #(5 7 16 )
        defaultItem: #cellChanged:.!   
textOriginXInteractive
        "Private - answer the x coordinate of the text origin when the receiver is active."
    ^self textOriginX left: displayOffset!   
keyboardInputRight
        "Private - the right arrow key was pressed.
        Move the caret."
    insertionOffset = self stringContents size ifTrue: [ ^self userInputRejected ].
    self hideCaret.
    self clearSelection.
    insertionOffset := insertionOffset + 1.
    [ self insertionOffsetPixelX isRightOf: self clippingBox right ]
        whileTrue: [ self scrollLeft: 1 ].
    self updateCaret!   
clippingBoxForCell: aCellAddress
        "Private - answer the bounding box of aCellAddress."
    ^self clippingBoxForRect: ( self rectangleForCell: aCellAddress )!
numberValidationMessage
        "Private - answer a message to validate number input."
    ^Message
        receiver: self
        selector: #isLegalNumberContents:
        arguments: #( 1 )!  
displayBackground
        "Display the background of the cell.  Do nothing."!
setRowNames: anArray
        "Set the names of the receiver's rows."
    rowNames := anArray!   
update
        "Update the receiver."
    | newContents |
    updateMessage isNil ifTrue: [ ^self ].
    newContents := updateMessage evaluate.
    newContents = cellContents ifFalse: [
        cellContents := newContents.
        self changed: newContents ]!
displayVerticalGridLines: gridRectangle
        "Private - display the vertical grid lines."
    | x |
    cellsToDisplay isNil ifTrue: [ ^self "receiver is not visible" ].
    self hasVerticalGridLines ifFalse: [ ^self ].
    graphicsTool
        foreColor: self verticalGridLineColor;
        setLineType: self verticalGridLineType;
        place: gridRectangle leftTop;
        goto: gridRectangle leftBottom.
   cellsToDisplay origin x to: ( cellsToDisplay corner x min: self numberOfColumns ) do: [ :columnNumber |
        x := self rightOfColumn: columnNumber.
        graphicsTool
            place: x @ gridRectangle top;
            down;
            line: x @ gridRectangle bottom ]!  
scrollBarHeight
        "Answer the height of a horizontal scroll bar."
    ^OperatingSystem getSystemValue: SystemValueHorizontalScrollBarHeight!  
insertionOffset: anInteger
		"Private - set the receiver's insertionOffset."
	insertionOffset := anInteger! 
beginSelectAt: aPoint
       "Private - the user has performed a mouse begin selection operation."
    | regionSymbol |
	( self activeEditor notNil and: [
		self activeEditor boundingBox containsPoint: aPoint ] )
			ifTrue: [ ^self activeEditor beginSelectAt: aPoint ].
    regionSymbol := self regionSymbolAt: aPoint.
    regionSymbol == #topLeftCorner ifTrue: [
        ^self beginSelectTopLeftCornerAt: aPoint ].
    regionSymbol == #columnLabels ifTrue: [
        ^self beginSelectColumnLabelsAt: aPoint ].
    regionSymbol == #rowLabels ifTrue: [
        ^self beginSelectRowLabelsAt: aPoint ].
    regionSymbol == #cells ifTrue: [
        ^self beginSelectCellsAt: aPoint ]!
column: anInteger
    anchorIndex := mobileIndex := first := last := anInteger!  
keyboardInputHome: aKeyboardInputEvent
        "Private - the <home> key was pressed."
	( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
		ifTrue: [
			^self releaseActiveEditor ].
    selectedCell isNil ifTrue: [ ^self userInputRejected ].
    aKeyboardInputEvent isControlKeyDown
        ifTrue: [ self selectCellAddress: 1 @ 1 ]
        ifFalse: [ self selectCellAddress: 1 @ selectedCell y ].
    self insureSelectedCellIsVisible!  
currentCursorAt: aPoint
        "Private - answer the cursor that should be displayed
        while the cursor is over the receiver."
    ^CursorManager text! 
createCaretAt: aPoint
        "Create a flashing caret."
	| fontHeight |
	fontHeight := self font height.
    tablePane createCaretAt: aPoint height: self font height!   
storeContents
        "Private - store the contents of the receiver back
        into the table pane."
    modified ifTrue: [
        modified := false.
        tablePane cellAtPoint: cellAddress primitivePut: self objectContents ]! 
rowAt: anIntegerOrName
        "Answer an array of values at row anInteger or name."
     | rowName |
    self indexedRows
        ifTrue: [^contents at: anIntegerOrName ifAbsent: [nil]]
        ifFalse: [
            rowName := anIntegerOrName isInteger
                ifTrue: [rowNames at: anIntegerOrName ifAbsent: [nil]]
                ifFalse: [anIntegerOrName].
            rowName == nil
                ifTrue: [^nil]
                ifFalse: [^contents at: rowName ifAbsent: [nil]]]! 
scrollHorizontalPixels: anInteger
        "Private - Scroll the pane left by anInteger
         number of pixels (if positive) or right by
         the absolute value of anInteger (if negative)."
	self
		partsIfOS2Do: [ self vos2ScrollHorizontalPixels: anInteger ]
		partsIfWindowsDo: [ self vwScrollHorizontalPixels: anInteger ]!  
vos2CreateCaretAt: aPoint height: anInteger
        "Private - Create a flashing caret."
    self partsVosOnly.
    PARTSHostInterface hostWindowLibrary
        createCursor2: handle
         x:  aPoint x
         y:  aPoint y
        cx: 0
        cy: anInteger
        rgf: CursorFlash
        clip: nil!  
beginSelectAt: aPoint
        "Private - the user has begun a mouse selection
        in the receiver."
    | newSelectionEnd selector newPoint stringContents
        scrollRight scrollLeft endSelectionSelector jiggleMessage movementSelectors |
    stringContents := self stringContents.
    self mouseSelectAt: aPoint.
    selectionEnd := insertionOffset.
    self hideCaret.
    endSelectionSelector := tablePane selectionButtonUpSelector.
    jiggleMessage := Message
        receiver: self
        selector: #yourself.
    scrollRight := scrollLeft := false.
    movementSelectors := #( #mouseMove: #button1Move:
        #button2Move: ), ( Array with: jiggleMessage selector ).
    Notifier consumeInputUntil: [ :e |
        e receiver == tablePane ifFalse: [ e evaluate ].
        selector := e selector.
        ( movementSelectors includes: selector )
            ifTrue: [
                tablePane captureMouseInput.
                e arguments size > 0 ifTrue: [
                    newPoint := e arguments first ].
                newSelectionEnd := self insertionOffsetAt: newPoint.
                scrollRight := ( newPoint x isLeftOf: boundingBox left ) and: [
                     ( self pixelXForOffset: 0 ) isLeftOf: boundingBox left ].
                scrollLeft := ( newPoint x isRightOf: boundingBox right ) and: [
                    ( self pixelXForOffset: stringContents size ) isRightOf: boundingBox right ].
                ( newSelectionEnd ~= selectionEnd or: [ scrollRight | scrollLeft ] )
                    ifTrue: [
                        scrollRight
                            ifTrue: [
                                self scrollRight.
                                newSelectionEnd := self insertionOffsetAt: newPoint.
                                self reverseFrom: insertionOffset to: selectionEnd ].
                        scrollLeft
                                ifTrue: [
                                    self scrollLeft.
                                    selectionEnd := self insertionOffsetAt: newPoint.
                                    self reverseFrom: insertionOffset to: selectionEnd ].
                        ( scrollRight | scrollLeft )
                            ifTrue: [ "no input stops continuous scroll on Windows so post jiggle message"
                                 Notifier postInputEvent: jiggleMessage ]
                            ifFalse: [
                                    self reverseFrom: newSelectionEnd to: selectionEnd ].
                                    selectionEnd := self insertionOffsetAt: newPoint ]].
        selector == endSelectionSelector ].
    tablePane clearMouseCapture.
    selectionEnd = insertionOffset ifTrue: [
        selectionEnd := nil ].
    self updateCaret!
endSelectAt: aPoint
        "Private - the user has just completed a mouse
        selection operation.  Do nothing as this event
        will be consumed by a Notifier consumeInputUntil:
        loop."!   
defaultBottomOffset
        "Private - answer the default bottom text offset,
        the distance between the bottom border
        of a cell and the text."
    ^self class defaultBottomOffset!
release
        "Private - the receiver is no longer the active editor."
    modified ifTrue: [
       self storeContents ].
    self hideCaret; reinitialize.
    super release.
    self isCellVisible ifTrue: [
        self stringContents: ( self convertToString: self objectContents ).
                "update string contents so the redisplay is a formatted
                version of the string contents, as in the case of the user
                inputting something like '99.', we want it to display
                '99.0' when the cell is released."

        self displayInteractive ]!   
columnEditorAtColumn: aColumNumber
        "Answer an appriate cell manager for aColumNumber."
    ^columnEditors isNil
        ifTrue: [
            nil ]
        ifFalse: [
            columnEditors at: aColumNumber ifAbsent: [ nil ]]!   
stringContents: aString
        "Private - set the receiver's contents to be that
        represented by aString."
    cellContents := aString.
    tablePane setRow: self cellAddress label: aString!
singleSelectRowLabelsAt: aPoint
        "Private - the user has performed a mouse  single
        select operation."
    | rowNumber |
    ( self rowToSizeAt: aPoint y ) notNil
        ifTrue: [ ^self ].
    rowNumber := self rowNumberFor: aPoint y.
    rowNumber isNil ifTrue: [ ^self ].
	self superPartIsEditing ifTrue: [
		^self editRowLabel: rowNumber ].
    self selectRowNumber: rowNumber! 
insureSelectedCellIsVisible
        "Private - insure that the selected cell is visible."
    | rect scrolled |
"self halt."
    scrolled := false.
    [   rect := self computeCellsWhollyInRectangle: rectangle.
        selectedCell x > rect corner x and: [ topCorner x < numberOfColumns ]] whileTrue: [
            scrolled := true.
            topCorner := ( topCorner x + 1 ) @ topCorner y ].
    [   rect := self computeCellsWhollyInRectangle: rectangle.
        selectedCell x < rect origin x and: [ topCorner x > 1 ]] whileTrue: [
            scrolled := true.
            topCorner := ( topCorner x - 1 max: 1 ) @ topCorner y ].

    [   rect := self computeCellsWhollyInRectangle: rectangle.
        selectedCell y > rect corner y and: [ topCorner y < numberOfRows ]] whileTrue: [
            scrolled := true.
            topCorner := topCorner x @ ( topCorner y + 1 ) ].
    [   rect := self computeCellsWhollyInRectangle: rectangle.
        selectedCell y < rect origin y and: [ topCorner y > 1 ]] whileTrue: [
            scrolled := true.
            topCorner := topCorner x @ ( topCorner y - 1 max: 1 ) ].

    scrolled ifTrue: [
        self invalidateRect: nil; computeCellsInRectangle; updateSliders ]
! 
atPoint: aTablePoint put: anObject
        "Private - put anObject in the receiver at aTablePoint."
    self insureCellsExtent: aTablePoint.
    self atRow: aTablePoint y column: aTablePoint x put: anObject.
    self setModified.
    self triggerCellChanged: anObject at: aTablePoint! 
modified
        "Private - answer whether the receiver has been modified.
        Default behavior is to assume the receiver's contents
        is immutable, hence not modified."
    ^false!   
isExtendedTextEditor
		"Private - answer if the receiver is capable of
		having extended text attributes."
	^true! 
isLeftJustified
        "Private - answer true if the receiver is left justified."
    ^textOriginXSelector == #textOriginXLeft!
setTableCellEditor: aCellEditor
        "Set aCellEditor to be the cell editor for the entire table.
        Editors set for individual cells, columns or rows will take precedence
        over this one."
    tableCellEditor := aCellEditor!   
scrollRight
        "Private - scroll the receiver right one character."
    self scrollRight: 1!   
reverseFrom: start to: stop
        "Private - reverse the text from start to stop.
        start and stop are text offsets."
    | top bottom right left rect clippingBox |
    clippingBox := self activeClippingBox.
    bottom := ( self textOriginY down: self font descender ) higherOf: clippingBox bottom.
    top := ( bottom up: self font height ) lowerOf: clippingBox top.
    left := ( self pixelXForOffset: ( start min: stop )) rightMost: clippingBox left.
    left := left leftMost: clippingBox right.
    right := ( self pixelXForOffset: ( start max: stop )) leftMost: clippingBox right.
    right := right rightMost: clippingBox left.
    rect := left @ top rightBottom: right @ bottom.
    tablePane reverseRectangle: rect!  
intersect: aRectangle
    | left right |
    left := first max: aRectangle left.
    right := last + 1 min: aRectangle right.
    ^left @ aRectangle top rightBottom: right @ aRectangle bottom!  
setRow: aRowNumber label: aString
        "Set the label of row aRowNumber."
    rowLabels isNil ifTrue: [ rowLabels := Array new: aRowNumber ].
    rowLabels size < aRowNumber ifTrue: [
        rowLabels := rowLabels, ( Array new: aRowNumber - rowLabels size ) ].
    rowLabels at: aRowNumber put: aString!  
propertyInfoColumnRowTypes

    ^#(
        #( 'Left justified' #leftJustified )
        #( 'Right justified' #rightJustified )
        #( 'Centered' #centered )
        #( 'Number' #number )
        )! 
totalWidth
        "Private - answer the total width of the receiver.
        This is used to compute the size and position of the
        scroll bar thumbs."
    ^self numberOfColumns! 
hasVerticalGridLines: aBoolean
        "Set the receiver as to whether it
        has vertical grid lines."
    self propertyAt: #hasVerticalGridLines put: aBoolean!  
isLabelEditor
		"Private - answer whether the receiver is a label editor."
	^false! 
displayIn: aRectangle
        "Display the receiver."
    cellsToDisplay := self computeCellsInRectangle: aRectangle.
    self
        displayBackground;
        displayGrid;
        displayLabels;
        displayCells;
        displayActiveEditor;
        displaySelections;
        yourself.
    self pen setClipRect: nil!   
attributesEquals: aCellEditor
        "Private - answer true if aCellEditor has the same attributes as the receiver."
    ^aCellEditor class == self class
        and: [ aCellEditor editorType = self editorType
            and: [ aCellEditor readOnly = self readOnly
                and: [ aCellEditor textOriginXSelector = self textOriginXSelector
                    and: [ aCellEditor textOriginYSelector = self textOriginYSelector
                        and: [ aCellEditor validationMessage = self validationMessage ]]]]]!
stringContents: aString
        "Private - set the receiver's contents to be that
        represented by aString."
    cellContents isAssociation
        ifTrue: [ cellContents key: aString; value: ( self convertFromString: aString ) ]
        ifFalse: [ cellContents := Association key: aString value: ( self convertFromString: aString ) ].
    modified := true! 
foreColor: aForeColor backColor: aBackColor font: aFont
        "Answer an instance of the receiver."
    ^self new
        foreColor: aForeColor;
        backColor: aBackColor;
        font: aFont!   
columnNames: anArray
        "Private - set the receiver's column names."
    columnNames := anArray!   
propertyLabelBackColor: aColor
        "Set the receiver's label background color."
    self propertyAt: #propertyLabelBackColor put: aColor!   
caretPositionY
        "Private - answer the caret positon y coordinate of the receiver."
    | y |
    y := self textOriginY down: tablePane font descender.
    ^self
        partsIfOS2Do: [ y ]
        partsIfWindowsDo: [ y up: tablePane font height ]!  
doPopupMenuAt: aPoint
		"Private - the user has performed the mouse operation to pop up a menu."
    | regionSymbol |
	( self activeEditor notNil and: [
		self activeEditor boundingBox containsPoint: aPoint ] )
			ifTrue: [ ^self activeEditor popUpMenuAt: aPoint ].
    regionSymbol := self regionSymbolAt: aPoint.
    regionSymbol == #topLeftCorner ifTrue: [
        ^self popUpMenuOnLeftTopCornerAt: aPoint ].
    regionSymbol == #columnLabels ifTrue: [
        ^self popUpMenuOnColumnLabelsAt: aPoint ].
    regionSymbol == #rowLabels ifTrue: [
        ^self popUpOnRowLabelsMenuAt: aPoint ].
    regionSymbol == #cells ifTrue: [
        ^self popUpMenuOnCellsAt: aPoint ]!
invalidateRect: aRectangle
        "Invalidate aRectangle area in the receiver
         thus force the area to be repainted."
	"Make sure the handle is good before forcing a redisplay.
	Null handle is the desktop, so redisplaying the null handle
	make the whole system flash.
	 When the implementation in Window does the check,
	we can remove this method."
	self handle ==  WindowHandle nullValue 
		ifFalse: [super invalidateRect: aRectangle]! 
selectedCellExcludeRectangle
        "Private - answer a rectangle surrounding the selected cell
        to exclude when reversing the selected group."
    | rect |
    selectedCell isNil ifTrue: [ ^nil ].
    rect := self rectangleForCell: selectedCell.
    rect := rect leftTop rightBottom: ( rect rightBottom rightAndDown: 1 ).
    ^rect!  
editorForCellAddress: aCellAddress
        "Answer a cell editor for aCellAddress."
    | cellEditor cellContents cellRectangle |
    cellContents := self contentsAt: aCellAddress.
    cellEditor := cellEditorMap isNil
        ifTrue: [
               tableCellEditor isNil
                    ifTrue: [ tableCellEditor := self defaultCellEditor ].
                tableCellEditor ]
        ifFalse: [ cellEditorMap editorForCellAddress: aCellAddress ].
"    cellEditor isNil ifTrue: [
        cellEditor := self editorForCellContents: cellContents ]."
    cellEditor isNil ifTrue: [
        cellEditor := tableCellEditor ].
    cellRectangle := self clippingBoxForCell: aCellAddress.
    cellEditor
        tablePane: self;
        cellAddress: aCellAddress;
        cellContents: cellContents;
        boundingBox: cellRectangle.
    ^cellEditor!  
displayBackground
        "Display the background of the cell."
    tablePane pen fill: boundingBox color: self backColor!  
verticalGridLineDotted
        "Set the receiver to have dotted vertical grid lines."
    self propertyAt: #verticalGridLineType put: LineTypeDot!  
setColumn: aColumn font: aFont
        "Set aColumn to have aFont as back color."
    | columnEditor |
    columnEditor := self extendedEditorForColumn: aColumn.
    columnEditor font: aFont!   
leftOfColumn: aColumnAddress
        "Private - answer the pixel x coordinate that is
        the left border of aColumnAddress."
    ^self rowLabelsRight right:
        ( self columnLeft: aColumnAddress ) - ( self columnLeft: self topLeftCellAddress x ) + 1!   
setCell: aCell font: aFont
        "Set aCell to have aFont as back color."
    | cellEditor |
    cellEditor := self extendedEditorForCell: aCell.
    cellEditor font: aFont.
    self updateDisplayCell: aCell!   
singleSelectAt: aPoint
		"Private - the user performed a mouse single select operation."!
copySelection
    "Put in clipboard"
    | selection maxWidth object row |

    maxWidth := 0.
    first to: last do: [ :r |
        maxWidth := maxWidth max: (pane rowAt: r ) size].

    selection := OrderedCollection new.
    first to: last do: [ :y |
        row := OrderedCollection new.
        selection addLast: row.
        1 to: maxWidth do: [ :x |
            object := pane atPoint: x@y.
            row addLast: object ]].

    Clipboard setObject: selection

"Excel format
    | stream object maxWidth |
    stream := WriteStream on: String new.
    maxWidth := 0.
    first to: last do: [ :i |
        maxWidth := maxWidth max: (pane atRow: i) size].
    first to: last do: [ :y |
        1 to: maxWidth do: [ :x |
            object := pane cellAtPoint: x@y.
            object notNil ifTrue: [
                object isString
                    ifFalse: [object := object printString].
                stream nextPutAll: object].
            x = maxWidth ifFalse: [
                stream nextPut: Tab]].
        stream nextPut: Cr; nextPut: Lf].
    Clipboard setString: stream contents
"!
intersect: aRectangle
    | top bottom |
    top := first max: aRectangle top.
    bottom := last + 1 min: aRectangle bottom.
    ^aRectangle left @ top rightBottom: aRectangle right @ bottom!  
setTextAlignCenteredHorizontally
		"Configure the receiver to display and edit text
		centered horizontally."
	textOriginXSelector := #textOriginXCentered!
scrollRightNoUpdateDisplay: anInteger
        "Private - scroll the receiver right."
    | string scroll |
    string := self stringContents.
    string size = 0 ifTrue: [ displayOffset := 0 ].
    string := string copyFrom: 1 to: ( 1 min: string size ).
    scroll := self stringWidthOf: string.
    displayOffset := displayOffset - scroll!  
cellAtPoint: aPoint show: anObject
        "Set the value in the table pane at aPoint.
        aPoint is cell coordinates."
    self cellAtRow: aPoint y column: aPoint x put: anObject!   
extendToOffset: anOffset
    [anOffset < mobileIndex] whileTrue: [self extendLesser].
    [anOffset > mobileIndex] whileTrue: [self extendGreater].
    first := anchorIndex min: mobileIndex.
    last := anchorIndex max: mobileIndex.! 
contents
        "Answer the contents of the receiver."
    self activeEditor notNil ifTrue: [ self activeEditor storeContents ].
    ^contents!   
cursor
        "Private - answer the cursor that should be displayed
        while the cursor is over the receiver."
    ^Cursor!  
scrollLeft
        "Private - scroll the receiver left."
    self scrollLeft: 1!
directEditColumnLabelsAt: aPoint
        "Private - the user has performed a direct edit
        operation with the mouse.  This is typically the
		result of left mouse button down with the alt
		key held down."
	| columnNumber |
	self propertyAltClickEditLabels ifFalse: [ ^self ].
    columnNumber := self columnNumberFor: aPoint x.
	self editColumnLabel: columnNumber!   
defaultBackColor
        "Answer the default background color of the receiver."
    ^Color entryFieldBackground!
displayInteractive
		"Private - display the receiver with the visual
		cues to indicate that it is the active cell."
	self display!
atRow: aRow column: aColumn put: anObject
        "Private - Put anObject at row aRow and column aColumn."
    | row column |
	self setModified.
    row := self rowAt: aRow.
    row == nil ifTrue: [^self].
    column := self indexedColumns
        ifTrue: [aColumn]
        ifFalse: [columnNames at: aColumn ifAbsent: [nil]].
    column == nil ifFalse: [row at: column put: anObject]! 
mouseResizeRowLabelsWidthAt: aPoint selectionButton: aBoolean
        "Private - the user is resizing the row labels width with the mouse."
    | currentX newX selector mouse leftLimit endSelector |
    endSelector := aBoolean
        ifTrue: [ self selectionButtonUpSelector ]
        ifFalse: [ self otherButtonUpSelector ].
    currentX := aPoint x.
    leftLimit := 0.
    selectionIsInProgress := true.
    self drawInvertVerticalLineAt: currentX.
    CursorManager sizeHorizontal change.
    Notifier consumeInputUntil: [ :e |
        selector := e selector.
        ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
            ifTrue: [
                self captureMouseInput.
                mouse := e arguments first.
                newX := mouse x.
                newX := newX rightMost: leftLimit.
                newX = currentX
                    ifFalse: [
                        self drawInvertVerticalLineAt: currentX.
                        currentX := newX.
                        self drawInvertVerticalLineAt: currentX ]].
        e selector = endSelector ].
    self drawInvertVerticalLineAt: currentX.
    self clearMouseCapture.
    CursorManager normal change.
    selectionIsInProgress := false.
    rowLabelsWidth := currentX.
    self invalidateRect: nil; updateSliders; computeCellsInRectangle.!   
displayActiveEditor
		"Private - display the active editor."
	( self activeEditor notNil and: [
		self activeEditor isCellVisible ] )
			ifTrue: [ activeEditor displayAsActiveCell ]!
editorForCellAddress: aCellAddress
        "Answer an appriate cell editor for aCellAddress."
    ^self checkCellEditors: aCellAddress! 
containsPoint: aPoint
    ^self containsOffset: aPoint x!
computeCellsInRectangle: aRectangle
        "Private - answer which cells are in aRectangle
        (wholly or partially).  aRectangle is window coordinates.
        The answer is cell coordinates (i.e. origin left top)."
    | origin left top width height right bottom |
    origin := self topLeftCellAddress.
    left := origin x.
    top := origin y.
    [ left < self numberOfColumns and: [
        ( self leftOfColumn: left + 1 ) isLeftEqualOf: aRectangle left ]]
            whileTrue: [ left := left + 1 ].
    [ top < self numberOfRows and: [
        ( self topOfRow: top + 1 ) isAboveEqual: aRectangle top ]]
            whileTrue: [ top := top + 1 ].
    width := 0.
    [ right := width + left.
        right < self numberOfColumns and: [
            ( self rightOfColumn: right ) isLeftOf: aRectangle right ]]
                whileTrue: [ width := width + 1 ].
    height := 0.
    [ bottom := height + top.
        bottom < self numberOfRows and: [
            ( self bottomOfRow: bottom ) isAbove: aRectangle bottom ]]
                whileTrue: [ height := height + 1 ].
    ^left @ top extent: width @ height
!   
propertyCellWidth
	^self defaultCellWidth!   
hasRowLabels
        "Answer whether receiver has row labels."
    ^ self propertyDisplayRowLabels! 
selectedRectangleClass
        "Private - answer the class to be used to model a
        selected rectangle of cells."
    ^PARTSRectangleSelection!   
columnNames
        "Answer the receiver's column names."
    ^columnNames! 
setColumn: aColumn backColor: aColor
        "Set aColumn to have aColor as back color."
    | columnEditor |
    columnEditor := self extendedEditorForColumn: aColumn.
    columnEditor backColor: aColor!  
cellAddressInBoundsFor: aPoint
        "Private - answer the cell address for aPoint.
        aPoint is in window coordinates.  If a cell coordinate
        is out of cell bounds, answer the
        closest coordinate that is in cell bounds."
    | row column |
    column := self columnNumberFor: aPoint x.
    column isNil ifTrue: [ column := self numberOfColumns ].
	column := column max: topCorner x.
    row := self rowNumberFor: aPoint y.
    row isNil ifTrue: [ row := self numberOfRows ].
	row := row max: topCorner y.
    ^column @ row! 
propertyReadOnly
	^self getBooleanProperty: #propertyReadOnly!   
displaySelection
    self display!   
cellContents: anObject
        "Set the receiver's cellContents."
    cellContents := anObject! 
propertySelectionMouseButtonResizes
        "Private - answer whether the mouse
        selection button resizes rows and
        columns."
    ^self getBooleanProperty: #propertySelectionMouseButtonResizes!   
getCellMessages
        "Private - answer a collection of selectors
        to get the cell at a given column at the current row."
    | answer columnName getSelector |
    answer := OrderedCollection new.
    1 to: columnNames size do: [ :i |
        columnName := columnNames at: i.
        columnName notNil ifTrue: [
            getSelector := self makeGetSelectorFor: columnName at: i.
            answer add: getSelector ]].
    ^answer asArray! 
openItemAt: aPoint
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click)."
    | regionSymbol |
	( self activeEditor notNil and: [
		self activeEditor boundingBox containsPoint: aPoint ] )
			ifTrue: [ self activeEditor openItemAt: aPoint ].
    regionSymbol := self regionSymbolAt: aPoint.
    regionSymbol == #topLeftCorner ifTrue: [
        ^self openItemTopLeftCornerAt: aPoint ].
    regionSymbol == #columnLabels ifTrue: [
        ^self openItemColumnLabelsAt: aPoint ].
    regionSymbol == #rowLabels ifTrue: [
        ^self openItemRowLabelsAt: aPoint ].
    regionSymbol == #cells ifTrue: [
        ^self openItemCellsAt: aPoint ]!  
configurePen: aPen
        "Private - configure aPen with any special attributes."
    | foreColor backColor font |
    foreColor := self foreColor.
	backColor := self backColor.
	font := self font.
    aPen foreColor = foreColor ifFalse: [
        aPen foreColor: foreColor ].
	aPen backColor = backColor ifFalse: [
		aPen backColor: self backColor ].
	aPen font = font ifFalse: [
		aPen font: self font ]!
cellsInRectangle
        "Private - answer the rectangle of the cell addresses of
        the cells in (whole or partially) the receiver's rectangle."
    cellsInRectangle isNil ifTrue: [ self computeCellsInRectangle ].
    ^cellsInRectangle!
indexedRows
        "Answer true if the rows are addressed by integers."
    ^( self propertyAt: #indexedRows ) notNil! 
openItemRowLabelsAt: aPoint
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click) on one of the receiver's row labels."
    | row |
    row := self rowNumberFor: aPoint y.
	self indexedRows ifFalse: [
		row := self rowNameFor: row ].
    self triggerEvent: #doubleClickedOnRow: with: row!  
insureRows: anIntOrCollection columns: anInteger
        "Private - Insure the size of the receiver to hold anIntOrCollection
           rows and anInteger columns."
    | oldRow newRow |
    self insureRowsSize: anIntOrCollection.
    self indexedColumns
        ifTrue: [        "indexed columns"
            self rowsDo: [: row |
                oldRow := contents at: row.
                oldRow size < anInteger
                    ifTrue: [
                        newRow := Array new: anInteger.
                          newRow replaceFrom: 1 to: oldRow size with: oldRow.
                        self atRow: row put: newRow]]]! 
copySelection
    "Put in clipboard"
    | selection row rows object  |

    selection := OrderedCollection new.
    rows := pane contents size.
    1 to: rows do: [ :y |
        row := OrderedCollection new.
        selection addLast: row.
        first to: last do: [ :x |
            object := pane cellAtPoint: x@y.
            row addLast: object ]].

    Clipboard setObject: selection

"Excel format
    | stream object maxWidth |
    stream := WriteStream on: String new.
    maxWidth := 0.
    first to: last do: [ :i |
        maxWidth := maxWidth max: (pane atRow: i) size].
    first to: last do: [ :y |
        1 to: maxWidth do: [ :x |
            object := pane atPoint: x@y.
            object notNil ifTrue: [
                object isString
                    ifFalse: [object := object printString].
                stream nextPutAll: object].
            x = maxWidth ifFalse: [
                stream nextPut: Tab]].
        stream nextPut: Cr; nextPut: Lf].
    Clipboard setString: stream contents
"!  
setColumnWidths: aColumnWidthArray
    "Set the columnWidths and columnLefts from the parameter.
        The parameter only represents widths that have changed since
        the contents were last edited via property dialog."
    | fontWidth font newRight newWidth oldColRight delta |
    font := self font.
    font isNil ifTrue: [font := SysFont].
    self
        partsIfOS2Do: [
            fontWidth := font stringWidth: 'W'. "don't use Font>>width
                on OS/2 because it gives very inaccurate answer for some fonts." ]
        partsIfWindowsDo: [
            fontWidth := font width * 7 // 4].
    columnRights size <= aColumnWidthArray size
        ifTrue: [
            columnRights := Array new: aColumnWidthArray size ]
        ifFalse: [
            oldColRight := columnRights at: aColumnWidthArray size ].
    newRight := 0.
    1 to: aColumnWidthArray size do:  [ :aColumnIndex |
        newWidth := ( aColumnWidthArray at: aColumnIndex ) * fontWidth.
        newRight := newRight + newWidth.
        columnRights at: aColumnIndex put: newRight ].
    oldColRight notNil ifTrue: [ "adjust all the columnRights right of the last new col right"
        delta := ( columnRights at: aColumnWidthArray size ) - oldColRight.
        aColumnWidthArray size + 1 to: columnRights size do: [ :i |
            columnRights at: i put: ( columnRights at: i ) + delta ]].
    self resizeActiveEditor.
    self realInvalidateRect: nil!
losingFocus
        "Private - The receiver is losing the input focus."
    self activeEditor notNil ifTrue: [
        activeEditor modified
            ifTrue: [
                self triggerCellChanged: activeEditor objectContents at: selectedCell ].
        self activeEditor losingFocus ].
    self modified ifTrue: [
        modified := false.
        self triggerEvent: #changed:  with: contents ]!  
isNumberEditor
		"Private - answer true if the receiver is a number editor."
	^type = #number!  
scrollHorizontalReal: anInteger
        "Private - Scroll the pane left by anInteger
         number of rows (if positive) or right by
         the absolute value of anInteger (if negative)."
    | pixelsToScroll oldTopCornerX |
    oldTopCornerX := topCorner x.
    topCorner := ( topCorner x - anInteger max: 1 ) @ topCorner y.
    topCorner x = oldTopCornerX ifTrue: [ ^self ].
    pixelsToScroll := ( self leftOfColumn: oldTopCornerX ) - ( self leftOfColumn: topCorner x ).
    self computeCellsInRectangle; resizeActiveEditorShowCaret: false. "must compute size before scrolling."
    self scrollHorizontalPixels: pixelsToScroll.! 
cornerLabel: aString
        "Private - set the top left corner label."
	cornerRowLabel := aString! 
rowLabels: anArray
        "Private - set the receiver's row labels."
    rowLabels := anArray! 
contents
        "Private - answer the contents of the receiver."
    | rect left right top bottom |
    left := rectangle left min: rectangle right.
    right := rectangle right max: rectangle left.
    top := rectangle top min: rectangle bottom.
    bottom := rectangle bottom max: rectangle top.
    rect := left @ top rightBottom: right @ bottom.
    ^pane selectedGroupIn: rect!   
partMirrorCopyReal: aDictionary
        " Private - add a mirror copy of the receiver
        to aDictionary.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDictionary.
    copy
        contents: ( contents isNil ifTrue: [] ifFalse: [ contents deepCopy ] );
        rowBottoms: rowBottoms copy;
        columnRights: columnRights copy;
		cornerLabel: self cornerLabel;
        rowLabels: rowLabels copy;
        columnLabels: columnLabels copy;
        columnLabelsHeight: columnLabelsHeight;
        rowLabelsWidth: rowLabelsWidth;
        defaultCellWidth: defaultCellWidth;
        defaultCellHeight: defaultCellHeight;
        setNumberOfRows: numberOfRows;
        setNumberOfColumns: numberOfColumns;
        setColumnNames: columnNames copy;
        setRowNames: rowNames copy;
        indexedRows: self indexedRows;
        indexedColumns: self indexedColumns;
		cellEditorMap: ( cellEditorMap partMirrorCopy: aDictionary );
        yourself.
    ^copy!
columnNameFor: anInteger
        "Private - answer the name of column anInteger."
    ^columnNames at: anInteger ifAbsent: [ ]! 
hasRowLabels: aBoolean
        "Set whether receiver has row labels."
    self propertyDisplayRowLabels: aBoolean!  
cornerLabel
        "Private - answer the top left corner label."
	^cornerRowLabel isNil
		ifTrue: [ String new ]
		ifFalse: [ cornerRowLabel ]!  
initializeForPlatform
        "Private - initialize the receiver as per the current platform."
    self
        partsIfOS2Do: [ self vos2Initialize ]
        partsIfWindowsDo: [ self vwInitialize ]!
regionSymbolAt: aPoint
       "Private - answer a symbol for the region of the receiver containing aPoint.
        This can be #topLeftCorner, #columnLabels, #rowLabels, or #cells."
    ^ #( #topLeftCorner #columnLabels #rowLabels #cells ) at:
            ( self regionIndexAt: aPoint )!   
foreColor
        "Answer the receiver's foreColor."
    ^foreColor isNil
        ifTrue: [ super foreColor ]
        ifFalse: [ foreColor ]! 
cursor
        "Private - answer the cursor that should be displayed
        while the cursor is over the receiver."
    ^CursorManager text!  
checkCellEditors: aCellAddress
        "Answer an appriate cell manager for aCellAddress."
    ^cellEditors isNil
        ifTrue: [
            self checkRowEditors: aCellAddress ]
        ifFalse: [
            cellEditors at: aCellAddress ifAbsent: [ self checkRowEditors: aCellAddress ]]! 
amountToPageLeft
        "Private - Answer the amount for
         horizontal page scrolling."
    ^self cellsInRectangle width - 2 max: 1!
singleSelectAt: aPoint
		"Private - the user performed a mouse single select operation."
    self mouseSelectAt: aPoint.!   
propertyReadOnly: aBoolean
	self setBooleanProperty: #propertyReadOnly to: aBoolean! 
undefineRowEditor: aRowAddress
        "Private - undefine the cell editor for the row at aRowAddress."
    rowEditors isNil ifTrue: [ ^self ].
    rowEditors removeKey: aRowAddress ifAbsent: [ ]!   
stringWidth
		"Private - answer the width of the receiver's text."
	^ self stringWidthOf: self stringContents!  
bottomOfRow: aRowAddress
        "Private - answer the pixel y coordinate that is
        the bottom border of aRowAddress."
    ^self topOfRow: aRowAddress + 1!  
vwInsetForRectangle: aRectangle
        "Private - answer aRectangle inset so that drawing
		that inset (with place:; goto; goto; etc.) will draw immediately
		inside aRectangle."
	^Rectangle
		leftBottom: ( aRectangle leftBottom rightAndUp: 1 @ 1  )
        rightTop: ( aRectangle rightTop leftAndDown: 1 @ 0  )!   
setRow: aRow backColor: aColor
        "Set aRow to have aColor as back color."
    | rowEditor |
    rowEditor := self extendedEditorForRow: aRow.
    rowEditor backColor: aColor!  
vos2Initialize
        "Private - perform initialization for the
        receiver existing on OS/2 platform."
    self
        propertySelectionMouseButtonResizes: false;
        propertyOtherMouseButtonResizes: true!
propertyHorizontalScrollBar: aBoolean
        "Add a horizontal scroll bar to the receiver if aBoolean is true,
        remove it if aBoolean is false."
    self setBooleanProperty: #propertyHorizontalScrollBar to: aBoolean.
    aBoolean
        ifTrue: [ self addHorizontalScrollbarStyle ]
        ifFalse: [ self removeHorizontalScrollbarStyle ]!
displaySelectedCellFocusDefaultIn: aRectangle
        "Private - display the visual cues
        to indicate the selected cell."
	| insetRect |
	insetRect := self insetRectangleFor: aRectangle.
    self reverseRectangleOutline: insetRect!   
isVisible
        "Private - answer if any part of the receiver is visible."
    ^pane isCellRectangleVisible: rectangle!   
topLeftCellAddress
        "Private - answer the address of the top left visible cell."
    ^topCorner! 
storeContents
        "Private - store the contents of the receiver back
        into the table pane."
    modified ifTrue: [
        tablePane setRow: self rowNumber label: self stringContents ]!  
convertCellNameToPoint: aPointName
    "Answer the table point for the point name in format:
        1) 'RnCn'
        2) 'An' "
    | ucName stream y |
    ucName := aPointName asUpperCase.
    ((ucName includes: $R) and: [ucName includes: $C])
        ifTrue: [  "R1C1 format"
            stream := ucName asStream.
            stream upTo: $R.
            y := (stream upTo: $C) asInteger.
            ^ stream nextWord asInteger @ y ]
        ifFalse: [  "A1 format"
            ^(ucName first asciiValue - 64) @
                (ucName copyFrom: 2 to: ucName size) asInteger]!   
rowNames: anArray
        "Private - set the receiver's row names."
    rowNames := anArray!
scrolledOrResized
		"Private - the reciever has either been resized, scrolled
		or had it's rows or columns resized.  Update the necessary
		data."!   
verticalGridLineColor: aColor
        "Set the vertical grid line color."
    ^self propertyAt: #verticalGridLineColor put: aColor! 
propertyLabelFont: aFont
        "Set the receiver's label font."
    self propertyAt: #propertyLabelFont put: aFont!   
namedRowsIndexedColumns
        "Private - configure the internal contents storage to support
        access by name for rows and access by index for columns."
    | rowName row oldRow oldContents |
    oldContents := contents.
    contents := Dictionary new.
    oldContents isArray
        ifTrue: [
            1 to: oldContents size do: [ :i |
                oldRow := oldContents at: i.
                row := self convertRowToIndexedAccess: oldRow.
                rowName := self rowNameForInteger: i.
                contents at: rowName put: row ]]
        ifFalse: [
            oldContents associationsDo: [ :assoc |
                rowName := assoc key.
                oldRow := assoc value.
                 row := self convertRowToIndexedAccess: oldRow.
                contents at: rowName put: row ]]! 
propertyColumnLabelHeight
	^columnLabelsHeight!  
updateCaret
        "Private - move the caret."
    | caretPosition |
    caretPosition := self caretPosition.
    tablePane moveCaret: self caretPosition.
    self isCellVisible ifFalse: [ ^self hideCaret ].
    (( caretPosition x isRightOf: self clippingBox left ) and: [
        caretPosition x isLeftOf: self clippingBox right ] )
            ifTrue: [ self showCaret ]
            ifFalse: [ self hideCaret ]!   
displayWhiteSpace
        "Private - Display area of the receiver not occupied
        by cells, if any."
    | right bottom rightRect bottomRect |
    right := self rightColumnRight.
    ( right isLeftOf: rectangle right )
        ifTrue: [
            rightRect := right @ rectangle top rightBottom:
                rectangle rightBottom ].
    bottom := self bottomRowBottom.
    ( bottom isAbove: rectangle bottom )
        ifTrue: [
            bottomRect := rectangle left @ bottom rightBottom:
                rectangle rightBottom ].
    rightRect notNil ifTrue: [
        self pen fill: rightRect color: self whiteSpaceColor ].
    bottomRect notNil ifTrue: [
        self pen fill: bottomRect color: self whiteSpaceColor ]!
defaultLeftOffset
        "Answer the default left text offset,
        the distance between the left border
        of a cell and the left most character."
    DefaultLeftOffset isNil ifTrue: [
        self initDefaultOffsets ].
    ^DefaultLeftOffset!   
rowAt: anIntegerOrName put: aCollection
        "Put aCollection at row anIntegerOrName."
    | rowNumber rowId rect |
    self setModified.
    self indexedRows
        ifTrue: [ rowNumber := rowId := anIntegerOrName ]
        ifFalse: [
            anIntegerOrName isInteger
                ifTrue: [
                    rowNumber := anIntegerOrName. "integer if here."
                    rowNumber > rowNames size
                        ifTrue: [
                            rowNames := rowNames, ( Array new: rowNumber - rowNames size ) ].
                    rowId := rowNames at: rowNumber.
                    rowId isNil ifTrue: [
                        rowId := 'row', rowNumber printString.
                        rowNames at: rowNumber put: rowId ]]
                ifFalse: [
                    rowId := anIntegerOrName. "string if here."
                        rowNumber := rowNames
                        indexOf: anIntegerOrName
                        ifAbsent: [     "add row name"
                            rowNames := rowNames, ( Array with: rowId ).
                            rowNames size ]]].
    self insureRows: rowNumber columns: aCollection size.
    self clearAllSelections.
    contents at: rowId put: aCollection.
    self setModified.
    rect := ( self leftOfColumn: 1 ) @ ( self topOfRow: rowNumber )
                    rightBottom: rectangle right @
                        ( self topOfRow: rowNumber + 1 ).
    graphicsTool execute: [ self displayIn: ( 0 @ 0 extent: self extent ) ] clipRect: rect!   
button1Down: aPoint
        "Private - The user pressed down button1 at aPoint."
	self partsIfWindowsDo: [
   		self setFocus.
		Notifier isAltKeyDown
			ifTrue: [
				^self directEditAt: aPoint ].
    		self beginSelectAt: aPoint ]!  
caretPosition
        "Private - answer the caret positon of the receiver."
    ^self insertionOffsetPixelX @ self caretPositionY!  
propertyEditColumnLabels: aBoolean
	self setBooleanProperty: #propertyEditColumnLabels to: aBoolean! 
setRow: aRowNumber readOnly: aBoolean
        "Set the read only attribute of row aRowNumber."
    | rowEditor |
    rowEditor := self extendedEditorForRow: aRowNumber.
    rowEditor readOnly: aBoolean.!   
vos2ScrollHorizontalPixels: anInteger
        "Private - Scroll the pane left by anInteger
         number of pixelx (if positive) or right by
         the absolute value of anInteger (if negative)."
     | pmRect rect clipRect hRgn |
    self partsVosOnly.
    hRgn := PARTSHostInterface hostGraphicsLibrary
        createRegion: graphicsTool handle
        count: 0 rectangles: nil.
    pmRect :=(Smalltalk at: #PMRectangle) new.
    clipRect := ( self rowLabelsRight right: 1 ) @ rectangle top rightBottom:
        rectangle rightBottom.
    PARTSHostInterface hostWindowLibrary
        scrollWindow: handle
        dx: anInteger
        dy: 0
        rclScroll: clipRect asParameter
        rclClip: clipRect asParameter
        hrgnUpdate: hRgn
        rclUpdate: nil
        fs: SwScrollChildren.   "//SwInvalidatergn//"
    ( PARTSHostInterface hostGraphicsLibrary
        setClipRegion: graphicsTool handle
        rgn: hRgn prgn: nil ) = RegionError
            ifTrue: [^self osError.  " 'setClipRegion error' " ].
    PARTSHostInterface hostGraphicsLibrary queryClipBox: self pen handle box:
        pmRect asParameter.
    rect := pmRect asRectangle expandBy: 1.
    self displayIn: rect.
    PARTSHostInterface hostGraphicsLibrary setClipRegion: graphicsTool handle rgn: nil prgn: nil.
    PARTSHostInterface hostGraphicsLibrary destroyRegion: graphicsTool handle hrgn: hRgn.!   
propertyCellHeight
	^self defaultCellHeight! 
keyBoardInputShiftInsert
        "Private - the insert key was pressed with shift held down.
        Paste the text in the clipboard, if any."
	self pasteSelection!   
button1DoubleClick: aPoint
        "Private - The user double clicked at aPoint."
	self partsIfWindowsDo: [
    	self openItemAt: aPoint ]!
boundingBox: aRectangle
        "Set the receiver's boundingBox."
    boundingBox := aRectangle!
vwUpdateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollbar."
    self partsVwOnly.
    ^super updateHorizontalSlider!   
singleSelectControlAt: aPoint
        "Private - the user has performed a mouse single
        select operation with the control key down."!
setTextAlignLeft
		"Configure the receiver to display and edit text
		left justified."
	textOriginXSelector := #textOriginXLeft!   
columnLabelFor: anInteger
        "Answer the label for column number anInteger."
    | answer |
    ^anInteger > columnLabels size
        ifTrue: [ anInteger printString ]
        ifFalse: [
            answer := columnLabels at: anInteger.
            answer isNil
                ifTrue: [ anInteger printString ]
                ifFalse: [ answer ] ]! 
wmEndselect: mp1 with: mp2
    self partsVosOnly.
    self sendInputEvent: #endSelectAt: with: mp1 asPoint.
    ^nil!  
scrollLeft: anInteger
        "Private - scroll the receiver left."
    self scrollLeftNoUpdateDisplay: anInteger.
    self updateDisplay.!
pasteSelection
		"Paste the string in the clipboard into the receiver."
    | string |
    string := Clipboard getStringOrNil.
    string isNil ifTrue: [ ^self userInputRejected ].
    self insertString: string!  
containsPoint: aPoint
    ^true! 
beginSelectRowLabelsAt: aPoint
       "Private - the user has performed a mouse begin selection operation."
    | selector rowNumber newRowNumber newPoint endSelectSelector |
    ( self propertySelectionMouseButtonResizes or: [
        self superPartIsEditing ] )
        ifTrue: [
            ( self checkMouseResizeRowsAt: aPoint selectionButton: true )
                ifTrue: [ ^self ]].
    rowNumber := self rowNumberFor: aPoint y.
    rowNumber isNil ifTrue: [ ^self ].
    self superPartIsEditing ifTrue: [
        ^self editRowLabel: rowNumber ].
    self propertyEditRowLabels ifTrue: [
        ^self editRowLabel: rowNumber ].
    self selectRowNumber: rowNumber.
    endSelectSelector := self selectionButtonUpSelector.
    self captureMouseInput.
    selectionIsInProgress := true.
    Notifier consumeInputUntil: [ :e |
        e receiver == self ifFalse: [ e evaluate ].
        selector := e selector.
        ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
            ifTrue: [
                newPoint := e arguments first.
                newRowNumber := self rowNumberFor: newPoint y.
                newRowNumber isNil ifTrue: [
                    newRowNumber := self numberOfRows ].
                newRowNumber := newRowNumber max: 1.
                newRowNumber = rowNumber ifFalse: [
                    selectedGroup extendTo: newRowNumber.
                    rowNumber := newRowNumber ]].
        selector == endSelectSelector ].
    self clearMouseCapture.
    selectionIsInProgress := false!
vos2UpdateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollbar."
    | bar h offset percentage scrollRange virtualWidth thumbSize |
    self partsVosOnly.
    bar := self horizontalScrollbar.
    bar isHandleOk ifFalse: [ ^self ].
    virtualWidth := columnRights at: self numberOfColumns.
    scrollRange := virtualWidth - ( rectangle width - rowLabelsWidth ).
    offset := self rightColumnRight - rectangle right + 1.
    offset := offset max: 0.
    percentage := scrollRange <= 0
		ifTrue: [ 0 ]
		ifFalse: [ ( scrollRange - offset * 100 / scrollRange ) ceiling ].
    thumbSize := ( rectangle width min: self rightColumnRight ) - rowLabelsWidth + 1 +
        ( virtualWidth bitShift: 16 ).
    h := bar handle.
    PARTSHostInterface hostWindowLibrary
        sendMsg: h
        msg: SbmSetThumbSize
        mp1: thumbSize
        mp2: 0.
    PARTSHostInterface hostWindowLibrary
        sendMsg: h
        msg: SbmSetPosition
        mp1: percentage
        mp2: 0!
backColor
        "Answer the receiver's backColor."
    ^backColor isNil
		ifTrue: [ super backColor ]
		ifFalse: [ backColor ]! 
columnEditorFor: anInteger
        "Private - answer the cell editor for column anInteger."
    | answer |
    cellEditorMap isNil
        ifTrue: [
                answer := self defaultCellEditor ]
        ifFalse: [
            answer := cellEditorMap columnEditorAtColumn: anInteger.
            answer isNil ifTrue: [
                answer := self defaultCellEditor ]].
	answer tablePane: self.
    ^answer!  
defineLabelEditor: anEditor forRow: anInteger
		"Private - set the row label editor for anInteger."
	rowLabelEditors isNil
		ifTrue: [ rowLabelEditors := Dictionary new ].
	rowLabelEditors at: anInteger put: anEditor! 
cornerLabelEditor
        "Private - answer an editor for the top left corner label."
     | answer |
    	answer :=  self cornerLabelEditorClass new.
    answer
		cellContents: self cornerLabel;
		tablePane: self;
		resize.
	^answer!
setRow: aRowNumber type: aSymbol
        "Set the type of row aRowNumber."
    | rowEditor |
    rowEditor := self extendedEditorForRow: aRowNumber.
    rowEditor editorType: aSymbol!   
propertyAdjustColumnWidths: aBoolean
	self setBooleanProperty: #propertyAdjustColumnWidths to: aBoolean! 
setColumnNames: anArray
        "Set the names of the receiver's columns."
    columnNames := anArray!  
rebuildRowBottoms
		"Private - reconstruct the rowBottoms variable."
	| rowBottom |
	rowBottoms := Array new: numberOfRows.
	rowBottom := defaultCellHeight.
	1 to: rowBottoms size do: [ :i |
		rowBottoms at: i put: rowBottom.
		rowBottom := rowBottom + defaultCellHeight ]!  
setTextAlignBottom
        "Configure the receiver to display and edit text at the
        bottom of the receiver's bounding box."
    textOriginYSelector := #textOriginYBottom!  
objectContents: anObject
        "Private - set the object displayed by the receiver."
    cellContents isAssociation
        ifTrue: [ cellContents value: anObject ]
        ifFalse: [
            cellContents := Association
                key: ( self convertToString: anObject )
                value: anObject ]!   
initialize
        "Private - initialize the receiver."! 
setTextAlignCenteredVertically
		"Configure the receiver to display and edit text
		centered vertically."
	textOriginYSelector := #textOriginYCentered!
propertyVerticalScrollBar: aBoolean
        "Add a vertical scroll bar to the receiver if aBoolean is true,
        remove it if aBoolean is false."
    self setBooleanProperty: #propertyVerticalScrollBar to: aBoolean.
    aBoolean
        ifTrue: [ self addVerticalScrollbarStyle ]
        ifFalse: [ self removeVerticalScrollbarStyle ]!  
selectedCell
    ^selectedCell isNil
        ifTrue: [ nil ]
        ifFalse: [ self cellAtPoint: selectedCell ]!  
openItemAt: aPoint
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click)."!
displayRowLabels
        "Private - Display the receiver's row labels."
    cellsToDisplay isNil ifTrue: [ ^self "receiver is not visible" ].
    cellsToDisplay origin y to: ( cellsToDisplay corner y min: self numberOfRows ) do: [ :rowNumber |
        self displayRowLabel: rowNumber ]!
hideCaret
        "Hide the receiver's caret."
	caretIsVisible ifTrue: [
		caretIsVisible := false.
    	self showCaret: false]!  
rowHeight: anInteger
        "Answer the height of row number anInteger."
	^self
		partsIfOS2Do: [
    			( self topOfRow: anInteger ) - ( self bottomOfRow: anInteger ) ]
		partsIfWindowsDo: [
    			( self bottomOfRow: anInteger ) - ( self topOfRow: anInteger ) ]!   
userInputRejected
        "Private - the user has inputted something
        which cannot be accomodated."
    tablePane userInputRejected!
propertyCellHeight: anInteger
	self
		defaultCellHeight: anInteger;
		rebuildRowBottoms!   
hideSelection
        "Private - remove the highlight on the receiver's selected text."
    self selectedText size > 0 ifFalse: [ ^self ].
    self reverseSelection!  
defaultCellWidth: anInteger
        "Private - set the default cell width."
    defaultCellWidth := anInteger!  
font
        "Private - answer the receiver's font."
    ^tablePane labelFont!  
displayAsActiveCell
        "Private - display the receiver with the visual
        cues to indicate that it is the active cell."
    super displayAsActiveCell.
    self displaySelection!   
rowNameFor: anInteger
        "Private - answer the name of row anInteger."
    ^rowNames at: anInteger ifAbsent: [ ]!  
propertyInfoIntegers
        "Private - answer an Array of Arrays.  The subArrays
        will be of size 2, the first element is the printed name
        of one of the receiver's integer properties, the second
        will be a selector with which to query the receiver as
        to the state of that property.  The receiver must implement
        messages to set each of these properties, the selectors
        for these messages must be the corresponding query
        selector with a ':' at the end.  This is used by class
        PARTSTablePaneStuff to implement the table pane
        part property dialog.  The entry fields for these properties
        will be laid out left, right, left, right, etc."
    ^#(
        #( 'Cell width' #propertyCellWidth ) #( 'Row label width' #propertyRowLabelWidth )
        #( 'Cell height' #propertyCellHeight ) #( 'Column label height' #propertyColumnLabelHeight )
        #( 'Number of rows' #propertyNumberOfRows ) #( 'Number of columns' #propertyNumberOfColumns )
        )!
selectedGroupNamedRowsIndexedColumns: aRectangle
        "Private - answer an extraction of the receiver's contents
        based on the cell integer coordinates in aRectangle."
    | answer row answerRow rowName |
    answer := Dictionary new.
    aRectangle top to: aRectangle bottom do: [ :y |
        rowName := self rowNameFor: y.
        rowName notNil ifTrue: [
            row := contents at: rowName ifAbsent: [ ].
            row notNil ifTrue: [
                    answerRow := Array new: aRectangle width + 1.
                    aRectangle left to: aRectangle right do: [ :x |
                    answerRow at: x - aRectangle left + 1 put: ( row at: x ifAbsent: [ ] ) ].
                    answer at: rowName put: answerRow ]]].
    ^answer!
enterKey
        "Private - the user has  typed the <enter> key."
    tablePane keyboardInputCr!
propertyIndexedRows: aBoolean
        "Set whether the receiver uses indexed rows access."
    self indexedRows: aBoolean!  
setColumn: aColumnNumber width: anInteger
		"Set the width of column aColumnNumber."
    | difference |
    difference := ( self columnWidth: aColumnNumber ) - anInteger.
    aColumnNumber to: columnRights size do: [ :i |
        columnRights at: i put: ( columnRights at: i ) - difference ]! 
propertyNumberOfRows
	^self numberOfRows!
makeFractionEditor
        "Configure the receiver to edit fractions."
    self setTextAlignRight; readOnly: true!  
storeContents
        "Private - store the contents of the receiver back
        into the table pane."
    modified ifTrue: [
        tablePane setColumn: self columnNumber label: self stringContents ]!
createCaretAt: aPoint
		"Private - "
	caretIsVisible := false.
	^super createCaretAt: aPoint!  
scrollLeftNoUpdateDisplay: anInteger
        "Private - scroll the receiver left."
    | string scroll |
    string := self stringContents.
    string size = 0 ifTrue: [ displayOffset := 0 ].
    string := string copyFrom: 1 to: ( 1 min: string size ).
    scroll := self stringWidthOf: string.
    displayOffset := displayOffset + scroll!
setColumn: aColumnNumber stringWidth: aString
        "Set the width of column aColumnNumber to be wide enough
        to accommodate aString using the column label font."!
updateRow: anInteger attributes: anAttributes
        "Private - update row number anInteger with anAttributes."
    self
        setRow: anInteger editor: anAttributes asCellEditor;
        setRow: anInteger height: anAttributes dimension;
        setRow: anInteger label: anAttributes label;
        setRow: anInteger name: anAttributes name!
updateColumn: anInteger attributes: anAttributes
        "Private - update column number anInteger with anAttributes."
    self
        setColumn: anInteger editor: anAttributes asCellEditor;
        setColumn: anInteger label: anAttributes label;
        setColumn: anInteger name: anAttributes name;
        setColumn: anInteger width: anAttributes dimension!   
cellContents
		"Private - answer the contents of the receiver."
	^cellContents! 
display
    "Reverse all columns currently selected to normal."
    

    first to: last do: [ :aColumn | self reverse: aColumn ]!
selectRowNumber: anInteger
        "Select the row numbered anInteger."
    | row |
	self propertyEditRowLabels ifTrue: [
		^self editRowLabel: anInteger ].
    self clearAllSelections.
    selectedGroup := ( self rowSelectionClass on: self ) row: anInteger.
    selectedGroup display.
	( self hasActionForEvent: #rowSelected: )
        ifTrue: [
            row := self indexedRows
                ifTrue: [ anInteger ]
                ifFalse: [ rowNames at: anInteger ifAbsent: [ nil ]].
             self triggerEvent: #rowSelected: with: row ]!
setColumn: aColumn editor: aCellEditor
        "Set aCellEditor to be the cell editor for the column at aColumn."
    | columnNumber |
    cellEditorMap isNil ifTrue: [ self createCellEditorMap ].
    aColumn isInteger
        ifTrue: [ columnNumber := aColumn ]
        ifFalse: [
            self indexedColumns
                ifTrue: [ self error: 'Attempt to access indexed columns by non-integer' ]
                ifFalse: [
                    columnNumber := columnNames indexOf: aColumn ]].
    ( aCellEditor attributesEquals: tableCellEditor )
        ifTrue: [
            ^cellEditorMap undefineColumnEditor: columnNumber ].
    cellEditorMap defineColumnEditor: aCellEditor forColumnAddress: columnNumber! 
copy
		"Answer a copy of the receiver."
	^super copy
		backColor: backColor;
		font: font;
		foreColor: foreColor;
		type: type;
		yourself!   
rowBottoms
        "Private - answer the rowBottoms attribute."
    ^rowBottoms!
mouseMoveColumnRight: anInteger from: aPoint selectionButton: aBoolean
        "Private - the user is begining to more a column's
        right border with the mouse.  The mouse window
        hotspot is aPoint.  Answer the x coordinate where
        the mouse button was released.  aBoolean indicates
        whether or not the selection mouse button is used."
    | currentX newX selector mouse leftLimit endSelector |
    endSelector := aBoolean
        ifTrue: [ self selectionButtonUpSelector ]
        ifFalse: [ self otherButtonUpSelector ].
    currentX := aPoint x.
    leftLimit := ( self leftOfColumn: anInteger ) right: SysFontWidth.
    selectionIsInProgress := true.
    self drawInvertVerticalLineAt: currentX.
    CursorManager sizeHorizontal change.
    Notifier consumeInputUntil: [ :e |
        selector := e selector.
        ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
            ifTrue: [
                self captureMouseInput.
                mouse := e arguments first.
                newX := mouse x.
                newX := newX rightMost: leftLimit.
                newX = currentX
                    ifFalse: [
                        self drawInvertVerticalLineAt: currentX.
                        currentX := newX.
                        self drawInvertVerticalLineAt: currentX ]].
        e selector = endSelector ].
    self drawInvertVerticalLineAt: currentX.
    self clearMouseCapture.
    CursorManager normal change.
    selectionIsInProgress := false.
    ^currentX!   
setRow: aRow editor: aCellEditor
        "Set aCellEditor to be the cell editor for the row at aRow."
    | rowNumber |
    cellEditorMap isNil ifTrue: [ self createCellEditorMap ].
    aRow isInteger
        ifTrue: [ rowNumber := aRow ]
        ifFalse: [
            self indexedRows
                ifTrue: [ self error: 'Attempt to access indexed rows by non-integer' ]
                ifFalse: [
                    rowNumber := rowNames indexOf: aRow ]].
    ( aCellEditor attributesEquals: tableCellEditor )
        ifTrue: [
            ^cellEditorMap undefineRowEditor: rowNumber ].
    cellEditorMap defineRowEditor: aCellEditor forRowAddress: rowNumber!   
selectScrollRight
        "Private - the user is mouse selecting and is causing a scroll."
    topCorner x > 1 ifTrue: [
        self
            scrollHorizontal: 1 ]!  
rowEditorAtRow: aRowNumber
        "Answer an appriate cell manager for aRowNumber."
    ^rowEditors isNil
        ifTrue: [
            nil ]
        ifFalse: [
            rowEditors at: aRowNumber ifAbsent: [ nil ]]! 
hasExtStyle: aSymbol
    ^( self propertyAt: aSymbol ) notNil!   
scrollTopCorner: scrollAmtPoint
    | newTopCorner |
    newTopCorner := ( topCorner x - scrollAmtPoint x max: 1 ) @
        ( topCorner y - scrollAmtPoint y max: 1 ).
    newTopCorner x: ( newTopCorner x min: self numberOfColumns ).
    newTopCorner y: ( newTopCorner y min: self numberOfRows ).
    newTopCorner x = topCorner x ifFalse: [
        self scrollHorizontal: ( newTopCorner x - topCorner x ) negated ].
    newTopCorner y = topCorner y ifFalse: [
        self scrollVertical: ( newTopCorner y - topCorner y ) negated ]! 
popUpMenuOnCellsAt: aPoint
		"Private - the user performed a mouse operation
		requesting a popup menu."
	self triggerEvent: #popUpMenuOnCellsAt: with: aPoint!
vos2InsetForRectangle: aRectangle
        "Private - answer aRectangle inset so that drawing
		that inset (with place:; goto; goto; etc.) will draw immediately
		inside aRectangle."
	^Rectangle
		leftBottom: ( aRectangle leftBottom "rightAndUp: 0 @ 0" )
        rightTop: ( aRectangle rightTop leftAndDown: 1 @ 1  )!
labelFont
        "Private - answer the font used for labels."
    ^self propertyLabelFont! 
textOriginYBottom
        "Private - answer the y coordinate
        of the text origin for text at the bottom of the receiver."
    ^boundingBox bottom up: self textOriginBottomOffset!  
hideSelectedCellFocusDefaultIn: aRectangle
        "Private - display the visual cues
        to indicate the selected cell."
    "self displaySelectedCellFocusDefaultIn: aRectangle"
    self invalidateRect: aRectangle!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "

    ^ self partFontOrSysFont charSize * (25 @ 7)!
rectangleForRow: aRow
        "Private - answer the rectangle for aRow
        excluding the row label."
    | top bottom right |
    top := self topOfRow: aRow.
    bottom := self topOfRow: aRow + 1.
    right := self rightColumnRight leftMost: rectangle right.
    ^rectangle left @ top rightBottom: right @ bottom!  
backColor
        "Private - answer the receiver's back color."
    ^tablePane backColor!   
propertyAdjustRowLabelsWidth
    ^self getBooleanProperty: #propertyAdjustRowLabelsWidth!
defineColumnLabelEditor: anEditor forColumn: anInteger
		"Private - set the column label editor for aColumnNumber."
	columnLabelEditors isNil
		ifTrue: [ columnLabelEditors := Dictionary new ].
	columnLabelEditors at: anInteger put: anEditor!
triggerCellChanged: aCellValue at: aCellAddress
        "Private - the cell at aCellAddress has changed.
        Trigger the appropriate events."
    | row column |
    (self hasActionForEvent: #cellChanged:)
        ifTrue: [
            self
                triggerEvent: #cellChanged:
                with: aCellValue ].
    (self hasActionForEvent: #cellChangedAtRow:column:value:)
        ifTrue: [
            row := self indexedRows
                ifTrue: [ aCellAddress y ]
                ifFalse: [ self rowNameForInteger: aCellAddress y ].
            column := self indexedColumns
                ifTrue: [ aCellAddress x ]
                ifFalse: [ self columnNameForInteger: aCellAddress x ].
            self
                triggerEvent: #cellChangedAtRow:column:value:
                withArguments: ( Array
                    with: row
                    with: column
                    with: aCellValue ) ]! 
makeSetSelectorFor: aString at: aColumnIndex
    | answer |
    answer :=
        'set',
        (self makeGetSelectorFor: aString at: aColumnIndex) asString,
        ':'.
    ^answer asSymbol!   
currentRowUp
    currentRow := currentRow - 1 max: 1!
release
        "Private - the receiver is no longer the active editor."
	self isCellVisible ifTrue: [
    	self clearDisplayFocusedCell; display ]!   
popUpOnRowLabelsMenuAt: aPoint
		"Private - the user performed a mouse operation
		requesting a popup menu."
	self triggerEvent: #popUpOnRowLabelsMenuAt: with: aPoint!
isExtendedTextEditor
		"Private - answer if the receiver is capable of
		having extended text attributes."
	^false!
rowNames
        "Answer the receiver's row names."
    ^rowNames!  
propertyAdjustRowLabelsWidth: aBoolean
    self setBooleanProperty: #propertyAdjustRowLabelsWidth to: aBoolean!  
reverseSelection
        "Private - reverse the selected area of the receiver."
    self selectedText size = 0 ifTrue: [ ^self ].
    self reverseFrom: insertionOffset to: selectionEnd!  
reverseColumnNumber: anInteger
        "Private - reverse the column numbered anInteger."
    | rect |
    anInteger < self cellsInRectangle left ifTrue: [ ^self ].
    anInteger > self cellsInRectangle right ifTrue: [ ^self ].
    rect := self rectangleForColumn: anInteger.
    self reverseRectangle: rect!
vwCreateCaretAt: aPoint height: anInteger
        "Private - Create a flashing caret."
    self partsVwOnly.
    ( PARTSHostInterface hostWindowLibrary
        createCaret: self handle
        bitmap: nil
        width: 0
        height: anInteger )
            ifFalse: [ ^self osError ]! 
columnRights
        "Private - answer the columnRights attribute."
    ^columnRights!  
scrollRightNoUpdateDisplay
        "Private - scroll the receiver right."
   self scrollRightNoUpdateDisplay: 1!
canTriggerEvent: aSymbol
        "Answer whether the receiver can trigger the event
        named aSymbol."
    ^true! 
matrixIn: aRectangle
    | answer row xOffset yOffset |
    xOffset := ( aRectangle origin x min: aRectangle corner x ) - 1.
    yOffset := ( aRectangle origin y min: aRectangle corner y ) - 1.
    answer := Array new: aRectangle height + 1.
    1 to: answer size
        do: [ :r |
            row := Array new: aRectangle width + 1.
            answer at: r put: row.
            1 to: row size do: [ :c |
                row at: c put: ( self cellAtPoint: c + xOffset @ ( r + yOffset )) ]].
    ^answer! 
selectedGroupIndexedRowsNamedColumns: aRectangle
		"Private - answer an extraction of the receiver's contents
		based on the cell integer coordinates in aRectangle."
    | answer row answerRow columnName |
	answer := Array new: aRectangle height + 1.
	1 to: answer size do: [ :y |
		row := contents at: y + aRectangle top - 1 ifAbsent: [ Dictionary new ].
		answerRow := Dictionary new.
		aRectangle left to: aRectangle right do: [ :x |
			columnName := self columnNameFor: x.
			answerRow at: columnName put: ( row at: columnName ifAbsent: [ ] ) ].
		answer at: y put: answerRow ].
	^answer!  
foreColor
        "The reciever does not define its own foreColor."
	| answer |
	answer := tablePane notNil
		ifTrue: [ tablePane foreColor ]
		ifFalse: [ nil ].
	^answer isNil
		ifTrue: [ SystemColorWindowText ]
		ifFalse: [ answer ]!   
clear
        self hide! 
columnLabelsColor
        "Answer the color of the column labels."
    ^self propertyAt: #columnLabelsColor ifAbsent: [ SystemColorButtonFace ]!
displayTextInteractive: aString
        "Display aString."
    self pen
        displayText: aString
        at: self textOriginInteractive
        in: self clippingBox
        options: self displayClipOption
        adx: nil! 
on: aTablePane
    ^self new pane: aTablePane!   
movesNorthSouth
    ^true!   
scrollRight: anInteger
        "Private - scroll the receiver right."
    self scrollRightNoUpdateDisplay: anInteger.
    self updateDisplay.! 
setCellMessages
        "Private - answer a collection of selectors
        to set the cell at a given column at the current row."
    | answer columnName setSelector |
    answer := OrderedCollection new.
    1 to: columnNames size do: [ :i |
        columnName := columnNames at: i.
        columnName notNil ifTrue: [
            setSelector := self makeSetSelectorFor: columnName at: i.
            answer add: setSelector ]].
    ^answer asArray! 
columnLabelsHeight: anInteger
        "Private - set the height of the the column labels."
    columnLabelsHeight := anInteger! 
rightColumnRight
        "Private - answer the pixel coordinate of the
        right side of the right most column."
    ^self rightOfColumn: self numberOfColumns!
otherButtonUpSelector
        "Private - answer the selector for the
        message that will be sent to indicate
        the conclusion of a mouse swipe
        operation using the non-selection button."
    ^self
        partsIfOS2Do: [ #endDragAt: ]
        partsIfWindowsDo: [ #button2Up: ]!   
reverseRectangleExcludeSelectedCell: aRectangle
        "Private - reverse aRectangle without reversing the
        selected cell."
    | protectedRectangle |
    self doGraphics: [
        protectedRectangle := self selectedCellExcludeRectangle.
        protectedRectangle notNil ifTrue: [
            self pen excludeClipRect: protectedRectangle ].
        self reverseRectangle: aRectangle.
        self pen setClipRect: nil ]!   
endDragAt: aPoint
        "Private - a mouse drag operation has just ended.
        Do nothing as this event will be consumed by a
        Notifier consumeAllEvents: loop."
    Terminal bell.!  
beginDragAt: aPoint
        "Private - the user is initiating a mouse drag operation."
    | regionSymbol |
	( self activeEditor notNil and: [
		self activeEditor boundingBox containsPoint: aPoint ] )
			ifTrue: [ ^self activeEditor beginDragAt: aPoint ].
    regionSymbol := self regionSymbolAt: aPoint.
    ( regionSymbol = #columnLabels or: [ regionSymbol = #topLeftCorner ] )
        ifTrue: [
            self propertyOtherMouseButtonResizes ifTrue: [
                self checkMouseResizeColumnsAt: aPoint selectionButton: false ]].
    ( regionSymbol = #rowLabels or: [ regionSymbol = #topLeftCorner ] )
        ifTrue: [
            self propertyOtherMouseButtonResizes ifTrue: [
                self checkMouseResizeRowsAt: aPoint selectionButton: false ]]!  
directEditRowLabelsAt: aPoint
        "Private - the user has performed a direct edit
        operation with the mouse.  This is typically the
        result of left mouse button down with the alt
        key held down."
    | rowNumber |
    self propertyAltClickEditLabels ifFalse: [ ^self ].
    rowNumber := self rowNumberFor: aPoint y.
    self editRowLabel: rowNumber!
initialize
        "Private - initialize the receiver."
    modified := false.
    currentRow := 1.
    contents := " Array with:" Array new.
    columnLabelsHeight := SysFont height * 2.
    rowLabelsWidth := SysFont stringWidth: 'row labels width'.
    defaultCellWidth := SysFont stringWidth: 'cell width'.
    defaultCellHeight := SysFontHeight * 6 // 3.
    numberOfColumns := 0.
    numberOfRows := 0.
    columnRights := Array new.
    rowBottoms := Array new.
    self newNumberOfColumns: 20.
    self newNumberOfRows: 20.
    rowNames := Array new.
    columnNames := Array new.
    selectionIsInProgress := false.
    self setTableCellEditor: self defaultCellEditor.
    self indexedColumns: true.
    self indexedRows: true.
    self propertyEditorReceivesArrowKeyInput: true.
    caretIsVisible := false.
    self
        propertyAdjustRowHeights: true;
        propertyAdjustColumnWidths: true.
    self initializeDefaultProperties.
    self initializeForPlatform.
    ^super initialize!  
rowLabels
        "Answer the row labels of the receiver."
    ^rowLabels!  
wmOpen: mp1 with: mp2
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click)."
    self partsVosOnly.
    self sendInputEvent: #openItemAt: with: mp1 asPoint.
    ^nil! 
selectedText
        "Answer the receiver's selected text.
        Answer an empty string if there is none."
    | from to |
    ( selectionEnd isNil or: [
        selectionEnd = insertionOffset ] )
            ifTrue: [ ^String new ].
    from := ( insertionOffset + 1 min: selectionEnd ) max: 1.
    to := insertionOffset - 1 max: selectionEnd.
    ^self stringContents copyFrom: from to: to!   
fileInActivate: anObjectFiler
        "The receiver has just been filed in.  Insure it is properly initialized."
    super fileInActivate: anObjectFiler.
    textOriginXSelector isNil ifTrue: [
        self setTextAlignLeft ].
    textOriginYSelector isNil ifTrue: [
        self setTextAlignBottom ]!   
activeClippingBox
        "Private - answer a clipping box that
        will insure the selected cell highlighting
        will not be overwritten."
    ^boundingBox insetBy: 2! 
columnToSizeAt: anXCoordinate
        "Private - answer the number of the column that
        would be sized if the sizing mouse is button is pressed
        at anXCoordinate and anXCoordiate is closest enough
        to the columns right side.  Answer 0 if the row labels
        width is to be adjusted."
    | columnRight slack |
    slack := self propertyMouseResizeProximity.
    ( self propertyAdjustRowLabelsWidth and: [ self propertyDisplayRowLabels ] )
        ifTrue: [
            ( self rowLabelsRight - anXCoordinate ) abs <= slack
                ifTrue: [ ^0 ]].
    self propertyAdjustColumnWidths ifFalse: [ ^nil ].
    self cellsInRectangle origin x to: self cellsInRectangle corner x do: [ :column |
        columnRight := self rightOfColumn: column.
        ( anXCoordinate - columnRight ) abs < slack ifTrue: [
            ^column ]].
    ^nil!
setColumn: aColumnNumber name: aString
		"Set the name of column aColumnNumber."
    columnNames isNil ifTrue: [ columnNames := Array new: aColumnNumber ].
    columnNames size < aColumnNumber ifTrue: [
        columnNames := columnNames, ( Array new: aColumnNumber - columnNames size ) ].
    columnNames at: aColumnNumber put: aString!
display
        "Display the receiver's contents."
    self implementedBySubclass!  
textOriginBottomOffset
        "Private - answer the bottom text offset,
        the distance between the bottom border
        of a cell and the text."
    ^self defaultBottomOffset!   
columnLabels: anArray
        "Private - set the receiver's column labels."
    columnLabels := anArray!
initDefaultOffsets
        "Initialize the default text offsets."
    DefaultLeftOffset := ( SysFontWidth * 2 // 3 ).
    DefaultBottomOffset := ( SysFontWidth * 2 // 3 )!
objectContents
        "Private - answer the receiver's contents."
    ^cellContents!   
new
        "Private - answer an initialized instance of the receiver."
    ^super new initialize!  
resize
        "Private - resize the receiver."
    super resize.
    ( self stringWidthOf: self stringContents ) < self clippingBox width
        ifTrue: [ displayOffset := 0 ].
    self updateCaret.
    self isCellVisible ifFalse: [ self hideCaret ]!
columnEditorAtAddress: aCellAddress
        "Answer an appriate cell manager for aCellAddress."
    ^self columnEditorAtColumn: aCellAddress x! 
modified
        "Private - answer whether or not the receiver has been modified."
    ^modified!   
editorType
        "Private - answer the type of editor.  Supported types are:
        #leftJustified rightJustified #centered and #number"
    self isNumberEditor ifTrue: [ ^#number ].
    self isLeftJustified ifTrue: [ ^#leftJustified ].
    self isRightJustified ifTrue: [ ^#rightJustified ].
    self isCenteredHorizontally ifTrue: [ ^#centered ].!
rectangle: aRectangle
        "Private - set the receiver's rectangle.
        This origin of this rectangle represents where the selection
        started and the the corner represents where the selection
        ended."
    rectangle := aRectangle!   
vos2ScrollVerticalPixels: anInteger
        "Private - Scroll the pane up by anInteger
         number of rows (if positive) or down by
         the absolute value of anInteger (if negative)."
    | pmRect rect clipRect hRgn |
    self partsVosOnly.
    hRgn := PARTSHostInterface hostGraphicsLibrary
        createRegion: graphicsTool handle
        count: 0 rectangles: nil.
    pmRect := (Smalltalk at: #PMRectangle) new.
    clipRect := 0 @ ( self columnLabelsBottom down: 1 ) rightBottom:
        rectangle rightBottom.
    PARTSHostInterface hostWindowLibrary
        scrollWindow: handle
        dx: 0
        dy: anInteger
        rclScroll: clipRect asParameter
        rclClip: clipRect asParameter
        hrgnUpdate: hRgn
        rclUpdate: nil
        fs: SwScrollChildren.   "//SwInvalidatergn//"
    ( PARTSHostInterface hostGraphicsLibrary setClipRegion: graphicsTool handle
        rgn: hRgn prgn: nil ) = RegionError
            ifTrue: [ ^self osError.  " 'setClipRegion error' " ].
    PARTSHostInterface hostGraphicsLibrary queryClipBox: self pen handle box:
        pmRect asParameter.
    rect := pmRect asRectangle expandBy: 1.
    self displayIn: rect.
    PARTSHostInterface hostGraphicsLibrary setClipRegion: graphicsTool handle rgn: nil prgn: nil.
    PARTSHostInterface hostGraphicsLibrary destroyRegion: graphicsTool handle hrgn: hRgn.!   
propertiesHaveChanged
        "Private - some of the receiver's properties have
        changed.  Update the display."
    | oldStyle scrollStyle |
    oldStyle := self propertyAt: #savedStyleVariable.
    scrollStyle := self scrollStyle.
    oldStyle = scrollStyle ifFalse: [
        self partPropertySetStyle: scrollStyle ].
    self propertyAt: #savedStyleVariable put: nil.
    self updateAccess; invalidateRect: nil; updateSliders! 
convertString: aString
		"Private - convert aString to the receiver's type of object."
	^aString!   
setColumn: aColumn foreColor: aColor
        "Set aColumn to have aColor as fore color."
    | columnEditor |
    columnEditor := self extendedEditorForColumn: aColumn.
    columnEditor foreColor: aColor!  
clearAllSelections
        "Clear the selected cell and selected group."
    self activeEditor notNil ifTrue: [
        activeEditor modified
            ifTrue: [
                self triggerCellChanged: activeEditor objectContents at: selectedCell ].
        self activeEditor release ].
    selectedGroup notNil ifTrue: [
        selectedGroup clear.
        selectedGroup := nil ].
    self activeEditor notNil ifTrue: [
        self activeEditor: nil.
        selectedCell := nil ].
!
rowEditorFor: anInteger
        "Private - answer the cell editor for row anInteger."
    | answer |
    cellEditorMap isNil
        ifTrue: [
                answer := self defaultCellEditor ]
        ifFalse: [
            answer := cellEditorMap rowEditorAtRow: anInteger.
            answer isNil ifTrue: [
                answer := self defaultCellEditor ]].
	answer tablePane: self.
    ^answer!  
singleSelectColumnLabelsAt: aPoint
        "Private - the user has performed a mouse  single
        select operation."
    | columnNumber |
    ( self columnToSizeAt: aPoint x ) notNil
        ifTrue: [ ^self ].
    columnNumber := self columnNumberFor: aPoint x.
    columnNumber isNil ifTrue: [ ^self ].
	self superPartIsEditing ifTrue: [
		^self editColumnLabel: columnNumber ].
    self selectColumnNumber: columnNumber!   
resizeActiveEditorShowCaret: aBoolean
        "Private - notify the active editor to resize."
    self activeEditor notNil ifTrue: [
        self activeEditor resizeShowCaret: aBoolean ]!
virtualRowLabelsWidth
        "Private - answer the virtual row labels width.
        If the reveiver doesn't display row labels answer
        0.  We do not store 0 in the rowLabelsWidth
        var because the developer may want to switch back
        to showing labels so we remember the old
        rowLabelsWidth."
    ^self propertyDisplayRowLabels
        ifTrue: [ rowLabelsWidth ]
        ifFalse: [ -2 ]!   
insetRectangleFor: aRectangle
        "Private - answer aRectangle inset so that drawing
		that inset (with place:; goto; goto; etc.) will draw immediately
		inside aRectangle."
	^self
		partsIfOS2Do: [ self vos2InsetForRectangle: aRectangle ]
		partsIfWindowsDo: [ self vwInsetForRectangle: aRectangle ]!   
popUpMenuOnColumnLabelsAt: aPoint
		"Private - the user performed a mouse operation
		requesting a popup menu."
	self triggerEvent: #popUpMenuOnColumnLabelsAt: with: aPoint!  
activate
        "Private - the receiver's pane has received focus.
        Activate the receiver."
    | clippingBox |
    clippingBox := self clippingBox.
    [ self insertionOffsetPixelX isLeftOf: clippingBox left ] whileTrue: [
        self scrollRightNoUpdateDisplay ].
    self updateDisplay.
    self updateCaret!  
cellAtRow: aRow column: aColumn putNoShow: aValue
    | x y |
    y:= self indexedRows
        ifTrue: [aRow]
        ifFalse: [
			aRow isInteger
				ifTrue: [ aRow ]
				ifFalse: [ rowNames indexOf: aRow ifAbsent: [ ^self ]]].
    x := self indexedColumns
        ifTrue: [aColumn]
        ifFalse: [
			aColumn isInteger
				ifTrue: [ aColumn ]
				ifFalse: [ columnNames indexOf: aColumn ifAbsent: [ ^self ]]].
    self atPoint: x @ y  put: aValue!
horizontalGridLineSolid
        "Set the receiver to have solid horizontal grid lines."
    self propertyAt: #horizontalGridLineType put: LineTypeSolid!
createCellEditorMap
        "Private - create the cell editor map which will remember
        which cell editors are associated with which cells."
    cellEditorMap := PARTSTableCellEditorMap new.!  
updateDisplayCell: aPoint
        "Private - update the display for the cell at cell coordinates aPoint."
    self canUpdateDisplay ifTrue: [
        self invalidateRect: ( self clippingBoxForCell: aPoint ) ]!  
focusRectangle
		"Private - answer the rectangle that is reversed
		to indicate that the receiver is the focused cell."
	^boundingBox! 
textOriginYCentered
        "Private - answer the y coordinate
        of the text origin for text centered vertically."
    ^boundingBox center y down: self font height // 4!
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        addAll: #(
            #changed:
            #cellChanged:
            #cellChangedAtRow:column:value:
            #cellEnteredAtRow:column:value:
                #rowEntered:
                #rightClicked
                #tabbed

                #doubleClickedOnCell:
                #doubleClickedOnColumn:
                #doubleClickedOnRow:

                #rowSelected:
                #columnSelected:

                #selectedCell:
                #selectedPoint:
                #selectedGroup:
                #selectedIndex: );
        yourself!  
singleSelectShiftAt: aPoint
        "Private - the user has performed a mouse  single
        select operation with the alt key down."! 
clippingBox
        "Private - answer the clipping box to be used to
        clip displaying.  This box insures the focus cell
        highlighting will not be overwritten."
    ^( boundingBox leftTop rightAndDown: 2 @ 2 ) rightBottom:
        ( boundingBox rightBottom leftAndUp: 2 @ 2 )!
rowNumberFor: anInteger
        "Private - answer the row number for window y coordinate anInteger."
    |  answer |
    answer := self topLeftCellAddress y.
	[ answer - 1 > self numberOfRows ifTrue: [ ^nil ].
		( self topOfRow: answer ) isAboveEqual: anInteger ]
			whileTrue: [ answer := answer + 1 ].
    ^answer - 1!   
extendedEditorForRow: aRow
        "Private - answer the extented cell editor for aRow.
        Create one and install it if one doesn't already exist."
    | answer |
    cellEditorMap isNil
        ifTrue: [
            answer := PARTSTableCellExtendedTextEditor new.
            self setRow: aRow editor: answer  ]
        ifFalse: [
            answer := cellEditorMap rowEditorAtRow: aRow.
            answer isNil ifTrue: [
                answer := PARTSTableCellExtendedTextEditor new.
                self setRow: aRow editor: answer ]].
    ^answer!  
propertyInfoBooleans
		"Private - answer an Array of Arrays.  The subArrays
		will be of size 2, the first element is the printed name
		of one of the receiver's boolean properties, the second
		will be a selector with which to query the receiver as
		to the state of that property.  The receiver must implement
		messages to set each of these properties, the selectors
		for these messages must be the corresponding query 
		selector with a ':' at the end.  This is used by class
		PARTSTablePaneStuff to implement the table pane
		part property dialog.  The check boxes for these properties
		will be laid out left, right, left, right, etc."
	^#(
		#( 'Adjust column widths' #propertyAdjustColumnWidths ) #( 'Edit column labels' #propertyEditColumnLabels )
		#( 'Adjust row heights' #propertyAdjustRowHeights ) #( 'Edit row labels' #propertyEditRowLabels )
		#( 'Display column labels' #propertyDisplayColumnLabels ) #( 'Vertical scroll bar' #propertyVerticalScrollBar )
		#( 'Display row labels' #propertyDisplayRowLabels ) #( 'Horizontal scroll bar' #propertyHorizontalScrollBar )
		#( 'Read only' #propertyReadOnly )
		)!  
editRowLabel: anInteger
        "Private - edit the row label for row number anInteger."
	self clearAllSelections.
    self activeEditor: ( self rowLabelEditorFor: anInteger ) copy.
	self activeEditor activate!
type: aSymbol
		"Private - set the receiver's type."
	type := aSymbol!  
defaultLeftOffset
        "Private - answer the default left text offset,
        the distance between the left border
        of a cell and the left most character."
    ^self class defaultLeftOffset! 
displayRectangleSelection: aRectangleSelection
        "Private - display aRectangleSelection."
    self reverseRectangleExcludeSelectedCell: aRectangleSelection paneRectangle!
keyboardInputTabDefault: aKeyboardInputEvent
        "Private - the tab key was pressed."
    ( selectedCell notNil and: [ selectedCell x < numberOfColumns | ( selectedCell y < numberOfRows ) ] )
        ifTrue: [
            "In Table pane, always trigger tab, regardless of whether it
            stays inside the table pane or leaves it."
            self triggerEvent: #tabbed.
            selectedCell x < numberOfColumns
                ifTrue: [
                    self selectCellAddress: selectedCell x + 1 @ selectedCell y ]
                ifFalse: [
                    self selectCellAddress: 1 @ ( selectedCell y + 1 ) ].
            self insureSelectedCellIsVisible ]
        ifFalse: [ ( self tabScope nextTabStop: self ) setFocus ]!
reverseRowNumber: anInteger
        "Private - reverse the row numbered anInteger."
    | rect |
    rect := self rectangleForRow: anInteger.
    self reverseRectangle: rect!
beginSelectCellsAt: aPoint
       "Private - the user has performed a mouse begin selection operation."
    | selector anchorCellAddress newPoint oldCellAddress newCellAddress
        newSelectedRectangle oldSelectedRectangle endSelectSelector jiggleMessage scrolling |
    anchorCellAddress := self cellAddressFor: aPoint.
    anchorCellAddress isNil ifTrue: [ ^self ].
    endSelectSelector := self selectionButtonUpSelector.
    self selectCellAddress: anchorCellAddress.
    selectedCell isNil ifTrue: [ ^self ]. "may be nuked by an event handler for cell selection."
    self activeEditor hideCaret.
    oldSelectedRectangle := self selectedRectangleClass new
        pane: self;
        rectangle: ( anchorCellAddress extent: 0 @ 0 ).
    self captureMouseInput.
    selectionIsInProgress := true.
    jiggleMessage := Message
        receiver: self
        selector: #button1Move:
        arguments: ( Array with: aPoint ).
    Notifier consumeInputUntil: [ :e |
        e receiver == self
            ifFalse: [ e evaluate. false ]
            ifTrue: [
                    selector := e selector.
                    ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
                        ifTrue: [
                            self captureMouseInput.
                            newPoint := e arguments first.
                            newCellAddress := self cellAddressInBoundsFor: newPoint.
                            newCellAddress = oldCellAddress ifFalse: [
                            newSelectedRectangle := anchorCellAddress corner: newCellAddress.
                            newSelectedRectangle := self selectedRectangleClass new
                               pane: self;
                                rectangle: newSelectedRectangle.
                            self newSelectedRectangle: newSelectedRectangle old: oldSelectedRectangle.
                            selectedGroup := oldSelectedRectangle := newSelectedRectangle.
                            oldCellAddress := newCellAddress ].
                            scrolling := false.
                            ( newPoint y isAbove: self columnLabelsBottom )
                                ifTrue: [ self selectScrollUp. scrolling := true ].
                            ( newPoint y isBelow: rectangle bottom )
                                ifTrue: [ self selectScrollDown. scrolling := true ].
                            ( newPoint x isLeftOf: self rowLabelsRight )
                                ifTrue: [ self selectScrollRight. scrolling := true ].
                            ( newPoint x isRightOf: rectangle right )
                                ifTrue: [ self selectScrollLeft. scrolling := true ].
                            scrolling
                                ifTrue: [
                                    jiggleMessage arguments: ( Array with: ( Cursor sense mapToWindow: self )).
                                    Notifier postInputEvent: jiggleMessage ]].
                        selector == endSelectSelector or: [
                        selector = #losingFocus ]]].
    selectedGroup := oldSelectedRectangle.
    self clearMouseCapture.
    selectionIsInProgress := false.
    self pen setClipRect: nil.
    self showCaret.
    self activeEditor updateCaret.
    ( self hasActionForEvent: #selectedGroup: ) ifTrue: [
        self triggerEvent: #selectedGroup: with: self selectedGroup ].
! 
scrollBarWidth
        "Answer the width of a vertical scroll bar."
    ^OperatingSystem getSystemValue: SystemValueVerticalScrollBarWidth! 
new
        "Answer an initialized instance of the receiver."
    ^super new initialize!
selectScrollLeft
        "Private - the user is mouse selecting and is causing a scroll."
    (self rightColumnRight isLeftOf: rectangle right )
        ifFalse: [
            self
                scrollHorizontal: -1 ]! 
scrollStyle
        "Private - answer the integer flag with scroll bar info."
    ^self
        partsIfOS2Do: [ self frameCreationFlags ]
        partsIfWindowsDo: [ self style ]!   
isLabelEditor
		"Private - answer whether the receiver is a label editor."
	^true!  
configurePen
    self configurePen: self pen!
textOriginYSelector
        "Private - answer the receiver's text origin y selector."
    ^textOriginYSelector! 
checkRowEditors: aCellAddress
        "Answer an appriate cell manager for aCellAddress."
    ^rowEditors isNil
        ifTrue: [
            self checkColumnEditors: aCellAddress ]
        ifFalse: [
            rowEditors at: aCellAddress y ifAbsent: [ self checkColumnEditors: aCellAddress ]]!
isCellVisible
		"Answer whether the receiver is visible."
	^true!   
defaultCellWidth
    ^defaultCellWidth!  
removeSelectedText
        "Private - remove the selected text."
	self removeSelectedTextNoUpdate.
	self hideCaret.
	self updateDisplay.
	self updateCaret!  
setBooleanProperty: aSymbol to: aBoolean
		"Private - set the boolean property aSymbol to aBoolean."
	^self propertyAt: aSymbol put: ( aBoolean ifTrue: [ true ] ifFalse: [ nil ] )!
intersects: aRectangle
    ^aRectangle top <= last and: [
        aRectangle bottom > first]!   
defaultExtent
        "Answer the receiver's extent based on the number of
         rows and columns, columns widths, row heights, column
        and row label extents (if any)."
    | x y  |
    x := ( self columnLeft: numberOfColumns + 1 ) + self virtualRowLabelsWidth.
	self propertyHorizontalScrollBar
		ifTrue: [ x := x + self scrollBarWidth ].
    y := ( self rowTop: numberOfRows + 1 ) + self virtualColumnLabelsHeight.
	self propertyVerticalScrollBar
		ifTrue: [ y := y + self scrollBarHeight ].
    ^x @ y!
resizeWindow
        "Private - Change the size of the window
         for the receiver."
    super resizeWindow.
    self computeCellsInRectangle.
    self resizeActiveEditor! 
totalLength
        "Private - answer the total length of the receiver.
        This is used to compute the size and position of the
        scroll bar thumbs."
    ^self numberOfRows!  
displayRemoveFocus
        "Private - the reciever is no longer the
        focused cell.  Update the display."
    tablePane displaySelectedCellFocusDefaultIn: self focusRectangle!  
gettingFocus
        "Private - the receiver's pane has received focus.
        Activate the receiver."
    super gettingFocus.
    self updateCaret! 
containsPoint: aPoint
    ^self containsOffset: aPoint y!
showCaret
        "Display the receiver's caret."
	caretIsVisible ifFalse: [
		caretIsVisible := true.
    	self showCaret: true]!
columnSelectionClass
        "Private - answer the class of column selections the receiver uses."
    ^PARTSColumnsSelection!   
extendGreater
    mobileIndex < anchorIndex ifTrue: [self reverse: mobileIndex].
    mobileIndex := mobileIndex + 1.
    mobileIndex > anchorIndex ifTrue: [self reverse: mobileIndex]!
propertyUpdateColumnAttributes: aDictionary
        "Private - update the receiver's column attributes
        as per aDictionary.  The keys in aDictionary are
        column numbers, the values are PARTSTableCellAttributes."
    aDictionary associationsDo: [ :assoc |
        self updateColumn: assoc key attributes: assoc value ]! 
insertString: aString
        "Private - insert aString in the receiver.  If the
        receiver has selected text the selected text will
        be replace with aString.  Update the insertion offset
        to be directly after the last character in aString."
    | stringContents left right |
    stringContents := self stringContents.
    left := stringContents copyFrom: 1 to: insertionOffset.
    right := stringContents copyFrom: insertionOffset + 1 to: stringContents size.
    stringContents := left, aString, right.
    ( self isLegalContents: stringContents ) ifFalse: [ ^self userInputRejected ].
    self removeSelectedTextNoUpdate.
    stringContents := self stringContents.
    left := stringContents copyFrom: 1 to: insertionOffset.
    right := stringContents copyFrom: insertionOffset + 1 to: stringContents size.
    stringContents := left, aString, right.
    self hideCaret.
    self stringContents: stringContents.
    insertionOffset := insertionOffset + aString size.
    [ self insertionOffsetPixelX isRightOf: self clippingBox right ]
        whileTrue: [ self scrollLeftNoUpdateDisplay ].
    self updateDisplay.
    self updateCaret!   
movesEastWest
    ^true! 
selectedGroupIn: aRectangle
		"Private - answer the selected group in aRectangle.
		aRectangel is cell coordinates.  The structure of the
		answer will be based on the structure of the receiver's
		contents."
    ^self indexedRows
        ifTrue: [
            self indexedColumns
                ifTrue: [
                   self matrixIn: aRectangle ]
                ifFalse: [
                    self selectedGroupIndexedRowsNamedColumns: aRectangle ]]
        ifFalse: [
            self indexedColumns
                ifTrue: [
                   self selectedGroupNamedRowsIndexedColumns: aRectangle ]
                ifFalse: [
                    self selectedGroupNamedRowsNamedColumns: aRectangle ]]! 
isCellVisible
		"Answer whether the receiver is visible."
	^tablePane isRowLabelVisible: cellAddress!   
propertyMouseResizeProximity: anInteger
        "Set the row and column mouse resizing
        proximity - the number of pixels the cursor
        can be away from a resizing coordinate and
        still able to resize."
    self propertyAt: #propertyMouseResizeProximity put: anInteger!  
rectangleForColumn: aColumn
        "Private - answer the rectangle for aColumn
        excluding the column label."
    | left right rect bottom |
    left := self leftOfColumn: aColumn.
    right := self leftOfColumn: aColumn + 1.
    bottom := rectangle bottom higherOf: self bottomRowBottom.
    rect := left @ rectangle top rightBottom: right @ bottom.
    ^rect!  
resizeShowCaret: aBoolean
        "Private - resize the receiver."
    self resize.
    ( self stringWidthOf: self stringContents ) < self clippingBox width
        ifTrue: [ displayOffset := 0 ].
    self updateCaret.
"    aBoolean ifTrue: [ self updateCaret ]."
    self isCellVisible ifFalse: [ self hideCaret ]!
rowLabelEditorClass
        "Private - answer the class of the receiver's row label editors."
	^PARTSTableRowLabelEditor!   
setNumberOfRows: anInteger
        "Set the number of row in the receiver."
    self newNumberOfRows: anInteger.
    self releaseActiveEditor.
    topCorner := topCorner x @ 1.
    self computeCellsInRectangle.
    self isVisible
        ifTrue: [
        self sendInputEvent:  #invalidate ].
    self sendInputEvent: #updateSliders


!  
endSelectionSelector
        "Private - answer the selector for the
        message that will be sent to indicate
        the conclusion of a mouse selection
        operation."
    ^self
        partsIfOS2Do: [ #endSelectAt: ]
        partsIfWindowsDo: [ #button1Up: ]! 
propertyAdjustRowHeights: aBoolean
	self setBooleanProperty: #propertyAdjustRowHeights to: aBoolean! 
wmTextedit: mp1 with: mp2
        "Private - the user has performed a direct edit
        operation with the mouse."
    self partsVosOnly.
    self sendInputEvent: #directEditAt: with: mp1 asPoint.
    ^nil! 
setCell: aCell foreColor: aColor
        "Set aCell to have aColor as fore color."
    | cellEditor |
    cellEditor := self extendedEditorForCell: aCell.
    cellEditor foreColor: aColor.
    self updateDisplayCell: aCell!  
editCornerLabel
        "Private - edit the left top corner label."
	self clearAllSelections.
    self activeEditor: self cornerLabelEditor copy.
	self activeEditor activate!
rowLabelEditorFor: anInteger
        "Private - answer a row label editor for anInteger."
     | answer cellRectangle |
    	answer :=  self rowLabelEditorClass new.
    cellRectangle := self rectangleForRowLabel: anInteger.
    answer
		rowNumber: anInteger;
		cellContents: ( self rowLabelFor: anInteger );
		tablePane: self;
		boundingBox: cellRectangle.
	^answer! 
losingFocus
        "Private -  receiver's pane has lost the input focus."!  
singleSelectAt: aPoint
        "Private - the user has performed a mouse  single
        select operation."
    | regionSymbol |
	( self activeEditor notNil and: [
		self activeEditor boundingBox containsPoint: aPoint ] )
			ifTrue: [ ^self activeEditor singleSelectAt: aPoint ].
    regionSymbol := self regionSymbolAt: aPoint.
    regionSymbol == #topLeftCorner ifTrue: [
        ^self singleSelectTopLeftCornerAt: aPoint ].
    regionSymbol == #columnLabels ifTrue: [
        ^self singleSelectColumnLabelsAt: aPoint ].
    regionSymbol == #rowLabels ifTrue: [
        ^self singleSelectRowLabelsAt: aPoint ].
    regionSymbol == #cells ifTrue: [
        ^self singleSelectCellsAt: aPoint ]! 
scrollVerticalReal: anInteger
        "Private - Scroll the pane up by anInteger
         number of rows (if positive) or down by
         the absolute value of anInteger (if negative)."
    | pixelsToScroll oldTopCornerY |
    oldTopCornerY := topCorner y.
    topCorner := topCorner x @ ( topCorner y - anInteger max: 1 ).
    topCorner y = oldTopCornerY ifTrue: [ ^self ].
    pixelsToScroll := ( self topOfRow: oldTopCornerY ) - ( self topOfRow: topCorner y ).
    self computeCellsInRectangle; resizeActiveEditorShowCaret: false. "must compute size before scrolling."
    self scrollVerticalPixels: pixelsToScroll.!
checkColumnEditors: aCellAddress
        "Answer an appriate cell manager for aCellAddress."
    ^columnEditors isNil
        ifTrue: [
            nil ]
        ifFalse: [
            columnEditors at: aCellAddress x ifAbsent: [ nil ]]!   
columnNameForInteger: anInteger
        "Private - answer a column name for anInteger.  If a column name
        has not already been defined for anInteger, create one and answer it."
    | answer |
    answer := columnNames at: anInteger ifAbsent: [ nil ].
    answer isNil ifTrue: [
        answer := 'column', anInteger printString.
        [ columnNames includes: answer ] whileTrue: [
            answer := answer, 'X' ].
        self setColumn: anInteger name: answer ].
    ^answer!   
cellEditorMap: aCellEditorMap
		"Private - set the receiver's cellEditorMap."
	cellEditorMap := aCellEditorMap! 
stringContents: aString
        "Private - set the receiver's contents to be that
        represented by aString."
    cellContents := aString.
    tablePane setColumn: self cellAddress label: aString! 
propertyEditorReceivesArrowKeyInput: aBoolean
        "Set whether the receiver should
        forward arrow key input to the active
        editor."
    self setBooleanProperty: #propertyEditorReceivesArrowKeyInput to: aBoolean! 
propertyHorizontalScrollBar
	^self getBooleanProperty: #propertyHorizontalScrollBar! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    | superMsgs static1 static2 static3 static4 getCellMsgs setCellMsgs seps |
    superMsgs := #(#enable #disable #setFocus).
        "super partMessages items."
    static1 := #(
            #value
            #setValue:
            #clear
            #cellAtName:
            #cellAtPoint:
            #cellAtRow:column:
            #cellAtRow:column:put:
            #columnAt:
            #columnAt:put:
            #rowAt:
            #rowAt:put:
            #matrixIn:
            #setFocusAtRow:column:).
    static2 := #(
            #selectedCell
            #selectedGroup).
    static3 := #(
            #currentRowTop
            #currentRowBottom
            #currentRowUp
            #currentRowDown).
    static4 := #(
            #setNumberOfColumns:
            #setNumberOfRows:
            #setColumnLabels:
            #setColumnNames:
            #setColumnWidths:
            #setRowLabels:
            #setRowNames:).

    getCellMsgs := self getCellMessages.
    setCellMsgs := self setCellMessages.
    seps := OrderedCollection
        with: superMsgs size
        with: superMsgs size + static1 size
        with: superMsgs size + static1 size + static2 size
        with: superMsgs size + static1 size + static2 size + static3 size.
    getCellMsgs size > 0 ifTrue: [
        seps addLast: superMsgs size + static1 size + static2 size + static3 size + static4 size].
    setCellMsgs size > 0 ifTrue: [
        seps addLast: superMsgs size + static1 size + static2 size +
            static3 size + static4 size + getCellMsgs size].
    ^PARTSInterfaceList new
        items: superMsgs, static1, static2, static3, static4, getCellMsgs, setCellMsgs
        separators: seps
        defaultItem: #cellAtPoint:!  
displayCells
        "Display the receiver's cells."
    cellsToDisplay isNil ifTrue: [ ^self "receiver is not visible" ].
    cellsToDisplay origin y to: ( cellsToDisplay corner y min: self numberOfRows ) do: [ :rowNumber |
        cellsToDisplay origin x to: ( cellsToDisplay corner x min: self numberOfColumns ) do: [ :columnNumber |
            self displayCell: columnNumber @ rowNumber ]]!  
amountToScrollUp
        "Private - Answer the number of
         rows for vertical scrolling."
    ^1!
indexedRowsNamedColumns
        "Private - configure the internal contents storage to support
        access by index for rows and access by name for columns."
    | oldContents oldRow row rowName rowIndex |
    oldContents := contents.
    oldContents isArray
        ifTrue: [
            contents := Array new: oldContents size.
            1 to: oldContents size do: [ :i |
                oldRow := oldContents at: i.
                row := self convertRowToNamedAccess: oldRow.
                contents at: i put: row ]]
        ifFalse: [
            contents := Array new: rowNames size.
            oldContents associationsDo: [ :assoc |
                rowName := assoc key.
                rowIndex := rowNames indexOf: rowName.
                oldRow := assoc value.
                 row := self convertRowToNamedAccess: oldRow.
                contents at: rowIndex put: row ]]!
displayNoText
        "Display the receiver without displaying any text."
    | pen |
    pen := tablePane pen.
    self
		configurePen: pen;
		displayBackground!  
clearSelection
        "Private - clear the visual cues that indicate
        the receiver's cell is the selected cell."
    self displaySelection!
vos2UpdateVerticalSlider
        "Private - Update the slider box in the vertical scrollbar."
    | bar h offset percentage scrollRange virtualHeight thumbSize |
    self partsVosOnly.
    bar := self verticalScrollbar.
    bar isHandleOk ifFalse: [ ^self ].
    self numberOfRows = 0
        ifTrue: [ virtualHeight := 0 ]
        ifFalse: [ virtualHeight := rowBottoms at: self numberOfRows ].
    scrollRange := virtualHeight - rectangle height + columnLabelsHeight.
    offset := rectangle bottom - self bottomRowBottom + 1.
    offset := offset max: 0.
    percentage := scrollRange <= 0
		ifTrue: [ 0 ]
		ifFalse: [ ( scrollRange - offset * 100 / scrollRange ) ceiling ].
    thumbSize := ( rectangle height min: rectangle top - self bottomRowBottom ) - columnLabelsHeight + 1 +
        ( virtualHeight bitShift: 16 ).
    h := bar handle.
    PARTSHostInterface hostWindowLibrary
        sendMsg: h
        msg: SbmSetThumbSize
        mp1:  thumbSize
        mp2: 0.
    PARTSHostInterface hostWindowLibrary
        sendMsg: h
        msg: SbmSetPosition
        mp1: percentage
        mp2: 0! 
newNumberOfColumns: anInteger
        "Private - the number of columns has changed.
        If the number of columns has increased, create
        a new columnRights Array of the proper size."
    | newColumnRights currentColumnRight |
    anInteger = numberOfColumns ifTrue: [ ^self ].
    anInteger > numberOfColumns
        ifTrue: [
            newColumnRights := Array new: anInteger.
            1 to: ( columnRights size min: anInteger ) do: [ :i |
                newColumnRights at: i put: ( columnRights at: i ) ].
            currentColumnRight := columnRights size = 0
                ifTrue: [ self defaultCellWidth ]
                ifFalse: [ columnRights last + self defaultCellWidth ].
            columnRights size + 1 to: newColumnRights size do: [ :i |
                newColumnRights at: i put: currentColumnRight.
                currentColumnRight := currentColumnRight + self defaultCellWidth ].
            columnRights := newColumnRights ].
    numberOfColumns := anInteger!
propertyOtherMouseButtonResizes
        "Private - answer whether the non-selection
        mouse button resizes rows and columns."
    ^self getBooleanProperty: #propertyOtherMouseButtonResizes!
setRow: aRow foreColor: aColor
        "Set aRow to have aColor as fore color."
    | rowEditor |
    rowEditor := self extendedEditorForRow: aRow.
    rowEditor foreColor: aColor!  
currentCursor
        "Private - Answer the mouse cursor that's
         appropriate for the receiver window."
    | location regionSymbol selectedCellRectangle row column |
    selectionIsInProgress ifTrue: [ ^Cursor ].
    location := Cursor sense mapToWindow: self.
    ( self activeEditor notNil and: [
        self activeEditor boundingBox containsPoint: location ] )
            ifTrue: [ ^self activeEditor currentCursorAt: location ].
    regionSymbol := self regionSymbolAt: location.
    regionSymbol = #cells ifTrue: [
        selectedCell notNil
            ifTrue: [
                selectedCellRectangle := self rectangleForCell: selectedCell.
                ( selectedCellRectangle containsPoint: location )
                    ifTrue: [ self activeEditor notNil ifTrue: [ ^self activeEditor cursor ]]].
        ^CursorManager normal ].
    ( regionSymbol = #rowLabels  or: [ regionSymbol = #topLeftCorner ] )
        ifTrue: [
            row := self rowToSizeAt: location y.
            row notNil ifTrue: [
                ^CursorManager sizeVertical ]].
    ( regionSymbol = #columnLabels or: [ regionSymbol = #topLeftCorner ] )
        ifTrue: [
            column := self columnToSizeAt: location x.
            column notNil ifTrue: [
                    ^CursorManager sizeHorizontal ]].
    ^CursorManager normal! 
printOn: aStream
        "Print the receiver on aStream."
    self class printOn: aStream.
    aStream nextPut: $(.
    rectangle printOn: aStream.
    aStream nextPut: $)! 
propertyAdjustColumnLabelsHeight
    ^self getBooleanProperty: #propertyAdjustColumnLabelsHeight!
PARTSTablePanePart removePartRuntimeLibrary!  
caretIsVisible: aBoolean
		"Private - set whether or not the receiver's caret (I-beam) is visible."
	caretIsVisible := aBoolean!
verticalGridLineType
        "Private - answer the line type constant for the receiver's
        vertical grid lines."
    ^self propertyAt: #verticalGridLineType ifAbsent: [
        LineTypeSolid ]!   
modified: aBoolean
		"Private - set whether or not the receiver has been modified."
	modified := aBoolean!  
stringWidthOf: aString
        "Private - answer the width in pixels of aString as
        displayed by the receiver."
    | pen |
    pen := tablePane pen.
    pen font: self font.
    ^pen stringWidthOf: aString!  
isCellRectangleVisible: aRectangle
        "Private - answer if any part of aRectangle is visible.
        aRectangle is cell addresses."
    ^( self isCellVisible: aRectangle leftTop ) or: [
        ( self isCellVisible: aRectangle rightTop ) or: [
            ( self isCellVisible: aRectangle rightBottom ) or: [
                ( self isCellVisible: aRectangle leftBottom ) ]]]!   
resizeActiveEditor
        "Private - notify the active editor to resize."
    self activeEditor notNil ifTrue: [
        self activeEditor resize ]!  
popUpMenuOnLeftTopCornerAt: aPoint
		"Private - the user performed a mouse operation
		requesting a popup menu."
	self triggerEvent: #popUpMenuOnLeftTopCornerAt: with: aPoint!
leftOffset
    ^0!   
propertyEditColumnLabels
	^self getBooleanProperty: #propertyEditColumnLabels!   
charsInRow
        "Private - Answer the receiver frame width."
    ^self cellsInRectangle width!   
createRowForNamedColumns
        "Private - create and answer a row object for named columns."
    ^Dictionary new! 
editorType: aSymbol
        "Private - set the type of editor.  Supported types are:
        #leftJustified rightJustified #centered and #number"
    aSymbol == #number ifTrue: [ ^self makeNumberEditor ].
    aSymbol == #leftJustified ifTrue: [ ^self setTextAlignLeft ].
    aSymbol == #rightJustified ifTrue: [ ^self setTextAlignRight ].
    aSymbol == #centered ifTrue: [ ^self setTextAlignCenteredHorizontally ].!
userInputRejected
        "Private - the user has inputted something
        which cannot be accomodated."
    self triggerEvent: #userInputRejected ifNotHandled: [
            Terminal bell ]! 
clearDisplayFocusedCell
        "Private - clear the visual cues that indicate
        the receiver's cell is the selected cell."
    self isCellVisible ifTrue: [
        self displayRemoveFocus ]! 
setColumnLabels: anArray
    columnLabels := anArray.
    self displayLabels!   
indexedColumns
        "Answer true if the columns are addressed by integers."
    ^( self propertyAt: #indexedColumns ) notNil!
columnNumberFor: anInteger
        "Private - answer the column number for window x coordinate anInteger."
    |  answer |
    answer := self topLeftCellAddress x.
    ( anInteger isLeftOf: self rowLabelsRight )
        ifTrue: [ answer := 0 ]
        ifFalse: [
            [ answer - 1 > self numberOfColumns
                    ifTrue: [ ^nil ].
                ( self leftOfColumn: answer ) isLeftEqualOf: anInteger ]
                whileTrue: [ answer := answer + 1 ]].
    ^answer - 1!   
font: aFont
        "Set the receiver's font."
    font := aFont!   
isCellVisible
		"Answer whether the receiver is visible."
	^tablePane isColumnLabelVisible: cellAddress!
cellAtName: aString
        "Answer the contents of the cell named by aString.
        aString is of the format 'R1C1' or 'A1' ."
    ^self cellAtPoint: ( self convertCellNameToPoint: aString )! 
defaultCellEditor
        "Answer a default cell displayer."
    ^PARTSTableCellTextEditor new! 
vwInitialize
		"Private - perform initialization for the
		receiver existing on Win32 platform."
	self
		propertySelectionMouseButtonResizes: true!   
isCellVisible
		"Answer whether the receiver is visible."
	^tablePane isCellVisible: cellAddress!   
defaultCellHeight: anInteger
        "Private - set the default cell height."
    defaultCellHeight := anInteger!   
selectFrom: start to: stop
        "Private - select the text from start to stop."
    self hideCaret.
    insertionOffset := start.
    selectionEnd := stop.
    self reverseSelection.
    self updateCaret! 
updateDisplayRow: aRow
        "Private - update the display for aRow."
    self canUpdateDisplay ifTrue: [
        self invalidateRect: ( self rectangleForRow: aRow ) ]! 
isCenteredHorizontally
        "Private - answer true if the receiver is centered horizontally."
    ^textOriginXSelector == #textOriginXCentered!  
horizontalGridLineColor: aColor
        "Set the horizontal grid line color."
   ^self propertyAt: #horizontalGridLineColor put: aColor!
currentRowBottom
    currentRow := numberOfRows! 
defineLabelEditor: anEditor forColumn: anInteger
		"Private - set the column label editor for anInteger."
	columnLabelEditors isNil
		ifTrue: [ columnLabelEditors := Dictionary new ].
	columnLabelEditors at: anInteger put: anEditor!  
displayCornerLabel
        "Display the corner label of the receiver."
	self cornerLabelEditor display! 
propertyAdjustColumnLabelsHeight: aBoolean
    ^self setBooleanProperty: #propertyAdjustColumnLabelsHeight to: aBoolean! 
hideCaret
        "Private - hide the caret."
    tablePane hideCaret!  
editorType: aSymbol
        "Private - set the type of editor.  Supported types are:
        #leftJustified rightJustified #centered and #number"
    type := aSymbol.
    ^super editorType: aSymbol!
column
    ^anchorIndex! 
singleSelectCellsAt: aPoint
        "Private - the user has performed a mouse  single
        select operation."
    | cellAddress |
    cellAddress := self cellAddressFor: aPoint.
    cellAddress isNil ifTrue: [ ^self ].
    cellAddress = selectedCell ifTrue: [
        ^self activeEditor mouseSelectAt: aPoint ].
    self selectCellAddress: cellAddress!   
columnLabelEditor: aColumnNumber
		"Private - answer the column label editor for aColumnNumber,
		if any."
	columnLabelEditors isNil ifTrue: [ ^nil ].
	^columnLabelEditors at: aColumnNumber ifAbsent: [ nil ]!  
amountToPageUp
        "Private - Answer the amount for
         vertical page scrolling."
    ^self cellsInRectangle height - 2 max: 1!   
propertyIndexedColumns: aBoolean
        "Set whether the receiver uses indexed columns access."
    self indexedColumns: aBoolean! 
selectedIndex
        "Answer the selected index, the index of the selected cell
        counting from left to right, top to bottom, like following
        a text stream."
    ^selectedCell isNil
        ifTrue: [ nil ]
        ifFalse: [ selectedCell y - 1 * numberOfColumns + selectedCell x ]! 
rectangleForRowLabel: anInteger
        "Private - answer the bounding box of row label number anInteger."
    | rect left right top bottom |
    left := rectangle left left: 1.
    right := self rowLabelsRight right: 1.
    top := ( self topOfRow: anInteger ) up: 1.
    bottom := ( self bottomOfRow: anInteger ) up: 0.
    rect := Rectangle leftBottom: left @ bottom rightTop: right @ top.
    ^self clippingBoxForRect: rect!   
currentRowTop
    currentRow := 1!   
defineRowEditor: aCellEditor forRowAddress: aRowAddress
        "Private - define the cell editor for the row at aRowAddress."
    rowEditors isNil ifTrue: [
        rowEditors := Dictionary new ].
    rowEditors at: aRowAddress put: aCellEditor!
backSpaceKey
        "Private - the user has  typed the <backSpace> key."
    | stringContents left right |
    self selectedText size > 0 ifTrue: [ ^self removeSelectedText ].
    insertionOffset = 0 ifTrue: [ ^self ].
    self hideCaret.
    stringContents := self stringContents.
    left := stringContents copyFrom: 1 to: insertionOffset - 1.
    right := stringContents copyFrom: insertionOffset + 1 to: stringContents size.
    stringContents := left, right.
    self stringContents: stringContents.
    insertionOffset := insertionOffset - 1.
    [ self insertionOffsetPixelX isLeftOf: self clippingBox left ]
        whileTrue: [ self scrollRightNoUpdateDisplay ].
    self updateDisplay.
    self updateCaret! 
modified
        "Answer whether or not the receiver has been modified."
    ^modified! 
mouseResizeColumnLabelsHeightAt: aPoint selectionButton: aBoolean
        "Private - the user is resizing the column labels height with the mouse."
    | currentY newY selector mouse topLimit endSelector |
    endSelector := aBoolean
        ifTrue: [ self selectionButtonUpSelector ]
        ifFalse: [ self otherButtonUpSelector ].
    currentY := aPoint y.
    topLimit := rectangle top.
    selectionIsInProgress := true.
    self drawInvertHorizontalLineAt: currentY.
    CursorManager sizeVertical change.
    Notifier consumeInputUntil: [ :e |
        selector := e selector.
        ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
            ifTrue: [
                self captureMouseInput.
                mouse := e arguments first.
                newY := mouse y.
                newY := newY lowerOf: topLimit.
                newY = currentY
                    ifFalse: [
                        self drawInvertHorizontalLineAt: currentY.
                        currentY := newY.
                        self drawInvertHorizontalLineAt: currentY ]].
        e selector = endSelector ].
    self drawInvertHorizontalLineAt: currentY.
    self clearMouseCapture.
    CursorManager normal change.
    selectionIsInProgress := false.
    columnLabelsHeight := rectangle top down: currentY.
    self invalidateRect: nil; updateSliders; computeCellsInRectangle!   
rectangleForColumnLabel: anInteger
        "Private - answer the bounding box of column label number anInteger."
    | rect left right top bottom |
    left := ( self leftOfColumn: anInteger ) left: 1.
    right := ( self rightOfColumn: anInteger ) "right: 1".
    top := rectangle top "up: 1".
	self partsIfWindowsDo: [ top := top up: 1 ].
    bottom := self columnLabelsBottom down: 1.
    rect := Rectangle leftBottom: left @ bottom rightTop: right @ top.
    ^self clippingBoxForRect: rect!   
propertyEditRowLabels: aBoolean
	self setBooleanProperty: #propertyEditRowLabels to: aBoolean!   
setColumn: aColumnNumber type: aSymbol
		"Set the type of column aColumnNumber."
    | columnEditor |
    columnEditor := self extendedEditorForColumn: aColumnNumber.
    columnEditor editorType: aSymbol!  
display
    pane displayEncompassingSelection: self! 
amountToScrollLeft
        "Private - Answer the number of columns
         for horizontal scrolling."
    ^1! 
display
        "Private - display the receiver."
    pane displayRectangleSelection: self! 
setTopLeftCell: aPoint
		"Scoll the receiver so that the top left cell
		address is aPoint."
	self scrollTopCornerTo: aPoint; updateSliders!   
selectedGroupNamedRowsNamedColumns: aRectangle
		"Private - answer an extraction of the receiver's contents
		based on the cell integer coordinates in aRectangle."
    | answer row answerRow rowName columnName |
	answer := Dictionary new.
	aRectangle top to: aRectangle bottom do: [ :y |
		rowName := self rowNameFor: y.
		rowName notNil ifTrue: [
			row := contents at: rowName ifAbsent: [ Dictionary new ].
			answerRow := Dictionary new.
			aRectangle left to: aRectangle right do: [ :x |
				columnName := self columnNameFor: x.
				answerRow at: columnName put: ( row at: columnName ifAbsent: [ ] ) ].
			answer at: rowName put: answerRow ]].
	^answer!   
extendedEditorForColumn: aColumn
        "Private - answer the extented cell editor for aColumn.
        Create one and install it if one doesn't already exist."
    | answer |
    cellEditorMap isNil
        ifTrue: [
            answer := PARTSTableCellExtendedTextEditor new.
            self setColumn: aColumn editor: answer  ]
        ifFalse: [
            answer := cellEditorMap columnEditorAtColumn: aColumn.
            answer isNil ifTrue: [
                answer := PARTSTableCellExtendedTextEditor new.
                self setColumn: aColumn editor: answer ]].
    ^answer!
deleteSelectedText
        "Private - delete selected text, if any, and answer the text that was deleted."
	| selectedText |
	selectedText := self selectedText.
	self removeSelectedText.
	^selectedText!   
setRow: aRowNumber attributes: aCellAttributes
        "Private - set the row aRowNumber to have
        the attributes defined in aCellAttributes."
    | editor |
    editor := aCellAttributes asCellEditor.
    self setRow: aRowNumber editor: editor!  
propertyVerticalScrollBar
	^self getBooleanProperty: #propertyVerticalScrollBar! 
mouseMoveRowBottom: anInteger from: aPoint selectionButton: aBoolean
        "Private - the user is begining to more a row's
        bottom border with the mouse.  The mouse window
        hotspot is aPoint.  Answer the y coordinate where
        the mouse button was released.  aBoolean indicates
        if the mouse selection button is being used."
    | currentY newY selector mouse topLimit endSelector |
    endSelector := aBoolean
        ifTrue: [ self selectionButtonUpSelector ]
        ifFalse: [ self otherButtonUpSelector ].
    currentY := aPoint y.
    topLimit := ( self topOfRow: anInteger ) down: SysFontWidth.
    selectionIsInProgress := true.
    self drawInvertHorizontalLineAt: currentY.
    CursorManager sizeVertical change.
    Notifier consumeInputUntil: [ :e |
        selector := e selector.
        ( #( #mouseMove: #button1Move: #button2Move: ) includes: selector )
            ifTrue: [
                self captureMouseInput.
                mouse := e arguments first.
                newY := mouse y.
                newY := newY lowerOf: topLimit.
                newY = currentY
                    ifFalse: [
                        self drawInvertHorizontalLineAt: currentY.
                        currentY := newY.
                        self drawInvertHorizontalLineAt: currentY ]].
        e selector = endSelector ].
    self drawInvertHorizontalLineAt: currentY.
    self clearMouseCapture.
    CursorManager normal change.
    selectionIsInProgress := false.
    ^currentY! 
propertyAdjustColumnWidths
	^self getBooleanProperty: #propertyAdjustColumnWidths!   
checkMouseResizeColumnsAt: aPoint selectionButton: aBoolean
        "Private - answer if a mouse resize operation should
        occur at aPoint.  aBoolean indicates whether the
        selection mouse button is to be used.  Perform the
        mouse sizing action if appropriate."
    | column |
    aBoolean
        ifTrue: [
            self propertySelectionMouseButtonResizes
                ifFalse: [ ^false ]]
        ifFalse: [
            self propertyOtherMouseButtonResizes
                ifFalse: [ ^false ]].
    column := self columnToSizeAt: aPoint x.
    column isNil ifTrue: [ ^false ].
    column = 0
        ifTrue: [ self mouseResizeRowLabelsWidthAt: aPoint selectionButton: aBoolean ]
        ifFalse: [ self mouseResizeColumn: column at: aPoint selectionButton: aBoolean ].
    ^true!
clear
        "Clear the contents of the table "
	| emptyContents |
    self clearAllSelections.
	self indexedRows
		ifTrue: [
			self indexedColumns
				ifTrue: [
					emptyContents := Array with: Array new ]
				ifFalse: [
					emptyContents := Array with: Dictionary new ]]
		ifFalse: [
			emptyContents := Dictionary new ].
    self setValue: emptyContents!
contents
    | answer min rowName |
    min := first  min: last .
    pane indexedRows
        ifTrue: [
            answer := Array new: (last  - first ) abs + 1.
            min to: (first  max: last ) do: [ :i |
                answer at: i - min + 1 put: (pane rowAt: i)]]
        ifFalse: [
            answer := Dictionary new.
            min to: (first  max: last ) do: [: i |
                rowName := pane rowNames at: i ifAbsent: [nil].
                rowName isNil ifTrue: [^nil].
                answer at: rowName put: (pane rowAt: i)]].
    ^answer!  
storeContents
		"Private - store the contents of the receiver back
		into the table pane.  Default is to do nothing."!  
resize
        "Private - resize the receiver."
	boundingBox := tablePane rectangleForCornerLabel!  
directEditAt: aPoint
        "Private - the user has performed a direct edit
        operation with the mouse.  This is typically the
		result of left mouse button down with the alt
		key held down."
    | regionSymbol |
	( self activeEditor notNil and: [
		self activeEditor boundingBox containsPoint: aPoint ] )
			ifTrue: [ ^self activeEditor directEditAt: aPoint ].
    regionSymbol := self regionSymbolAt: aPoint.
    regionSymbol == #topLeftCorner ifTrue: [
        ^self directEditTopLeftCornerAt: aPoint ].
    regionSymbol == #columnLabels ifTrue: [
        ^self directEditColumnLabelsAt: aPoint ].
    regionSymbol == #rowLabels ifTrue: [
        ^self directEditRowLabelsAt: aPoint ].
    regionSymbol == #cells ifTrue: [
        ^self directEditCellsAt: aPoint ]! 
defaultMouseResizeProximity
        "Answer the default row and column mouse resizing
        proximity - the number of pixels the cursor
        can be away from a resizing coordinate and
        still able to resize."
    ^2!  
value
        "Answer the contents of the receiver."
    ^self contents!
defineCellEditor: aCellEditor forCellAddress: aCellAddress
        "Private - define the cell editor for the cell at aCellAddress."
    cellEditors isNil ifTrue: [
        cellEditors := Dictionary new ].
    cellEditors at: aCellAddress put: aCellEditor!   
editColumnLabel: anInteger
        "Private - edit the row label for column number anInteger."
	self clearAllSelections.
    self activeEditor: ( self columnLabelEditorFor: anInteger ) copy.
	self activeEditor activate!   
verticalGridLineSolid
        "Set the receiver to have solid vertical grid lines."
    self propertyAt: #verticalGridLineType put: LineTypeSolid!  
value: aCollection
        "Set the receiver's rows to aCollection.  The value can
        be an indexable collection or a nameable collection. "
    self contents: aCollection.! 
gettingFocus
        "Private - The receiver is getting the input focus."
	self activeEditor notNil ifTrue: [
		self activeEditor gettingFocus ].
    ^super gettingFocus!
cutSelection
		"Cut the selected text and store it in the clip board."
	| cutText |
	cutText := self deleteSelectedText.
	Clipboard setString: cutText!   
activeEditor: anEditor
        "Private - set the active editor."
	activeEditor := anEditor!
textOriginXLeft
        "Private - answer the x coordinate
        of the text origin for left justified text."
    ^boundingBox left right: self textOriginLeftOffset!
moveTopCornerBy: extent
        "Private - Move top corner by extent and
        display changes."
    | aPoint |
    aPoint := self topCorner moveBy: extent negated.
    self scrollTopCornerTo: aPoint.
	self invalidateRect: nil!   
partEditDirect
        "Private - place the receiver in direct edit mode."
    self partEditor recordUndoPlaceholder.
    self partEditorPane currentEditObject: self.
    self realInvalidateRect: nil.     "show edit frame"!   
setModified
        "Private - mark the receiver as being modified."
    modified := true
!
rowNumbers
		"Private - answer the receiver's row numbers."
	^( 1 to: numberOfRows ) asArray!   
vwScrollHorizontalPixels: anInteger
        "Private - Scroll the pane left by anInteger
         number of pixels (if positive) or right by
         the absolute value of anInteger (if negative)."
    | clipRect |
    self partsVwOnly.
    clipRect := (Smalltalk at: #WinRectangle) fromRectangle:
        ( self rowLabelsRight + 1 @ rectangle top rightBottom: rectangle rightBottom ).
    self
        scrollBy: anInteger @ 0
        scrollRect: clipRect
        clipRect: clipRect
        flags: SwScrollChildren.
	self updateWindow!  
displayRaisedRectangle
        "Private - display a raised rectangle around the receiver."
	^tablePane displayRaisedRectangle: boundingBox! 
initializeDefaultProperties
        "Private - initialize the receiver's default properties."
    self
        propertyCellWidth: SysFontWidth * 12;
        propertyCellHeight: SysFontHeight * 4 // 3;
        propertyRowLabelWidth: SysFontWidth * 8;
        propertyColumnLabelHeight: SysFontHeight * 5 // 3;
        propertyNumberOfRows: 256;
        propertyNumberOfColumns: 256;

        propertyIndexedRows: true;
        propertyIndexedColumns: true;

        propertyAdjustColumnWidths: true;
        propertyAdjustRowHeights: true;
        propertyAdjustRowLabelsWidth: true;
        propertyAdjustColumnLabelsHeight: true;

        propertyDisplayColumnLabels: true;
        propertyDisplayRowLabels: true;
        propertyReadOnly: false;
        propertyEditColumnLabels: false;
        propertyEditRowLabels: false;
        propertyVerticalScrollBar: true;
        propertyHorizontalScrollBar: true;

		propertyAltClickEditLabels: true! 
textOriginYSelector: aSymbol
		"Private - set the receiver's text origin y selector."
	textOriginYSelector := aSymbol!  
canUpdateDisplay
        "Private - answer if the receiver can update it's display."
    ^self isHandleOk!  
keyboardInputRight
        "Private - the right arrow key was pressed."
    self propertyEditorReceivesArrowKeyInput ifTrue: [
        ^self activeEditor notNil ifTrue: [
            self activeEditor keyboardInputRight ]].
    ( selectedCell notNil and: [ selectedCell x < numberOfColumns ] )
        ifTrue: [
            self selectCellAddress:  selectedCell x + 1 @ selectedCell y.
            self insureSelectedCellIsVisible ]
        ifFalse: [
            self userInputRejected ]!   
rowLabelsRight
    ^rectangle left right: self virtualRowLabelsWidth!
setNumberOfColumns: anInteger
    self newNumberOfColumns: anInteger.
    self releaseActiveEditor.
    topCorner := 1 @ topCorner y.
    self computeCellsInRectangle.
    self isVisible
        ifTrue: [
        self sendInputEvent:  #invalidate ].
    self sendInputEvent: #updateSliders

!
contentsAt: aCellAddress
        "Private - answer the object at aCellAddress."
    | row column |
    row := aCellAddress y.
    ( self indexedRows not and: [
        row isInteger ] ) ifTrue: [ row := rowNames at: row ifAbsent: [ ^nil ]].
    column := aCellAddress x.
    ( self indexedColumns not and: [
        column isInteger ] ) ifTrue: [ column := columnNames at: column ifAbsent: [ ^nil ]].
    row := contents at: row ifAbsent: [ ^nil ].
    ^row at: column ifAbsent: [ nil ]! 
font
		"Private - Answer the font of the receiver."
	| font |
	font := tablePane font.
	^font isNil
		ifTrue: [ self class defaultFont ]
		ifFalse: [ font ]!   
setRow: aRow font: aFont
        "Set aRow to have aFont as back color."
    | rowEditor |
    rowEditor := self extendedEditorForRow: aRow.
    rowEditor font: aFont!   
keyboardInputUp
        "Private - the up arrow key was pressed."
	( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
		ifTrue: [
			^self releaseActiveEditor ].
    ( selectedCell notNil and: [ selectedCell y > 1 ] )
        ifTrue: [
            self selectCellAddress:  selectedCell x @ ( selectedCell y - 1 ).
            self insureSelectedCellIsVisible ]
        ifFalse: [
            self userInputRejected ]!
wmBeginselect: mp1 with: mp2
        "Private - the user has performed a mouse begin selection operation."
    self partsVosOnly.
    self sendInputEvent: #beginSelectAt: with: mp1 asPoint.
    ^nil!   
defaultBottomOffset
        "Answer the default bottom text offset,
        the distance between the bottom border
        of a cell and the text."
    DefaultBottomOffset isNil ifTrue: [
        self initDefaultOffsets ].
    ^DefaultBottomOffset!
displayInteractive
        "The receiver is being edited.  Display the receiver
        knowing the text may be scrolled right or left."
    self configurePen.
    self pen
        execute: [
"self halt."
            self
                displayBackgroundInteractive;
                displayTextInteractive ]
        clipRect: self activeClippingBox!  
contents: aCollection
        "Set the receiver's contents."
	modified := false.
    contents := aCollection.
    self adjustCellsExtentForContents!  
topOfRow: aRowAddress
        "Private - answer the pixel y coordinate that is
        the top border of aRowAddress."
    ^self columnLabelsBottom down:
        ( self rowTop: aRowAddress ) - ( self rowTop: self topLeftCellAddress y ) + 1!  
setColumn: aColumnNumber widthTwips: anInteger
        "Set the width of column aColumnNumber."! 
cellAddress
        "Answer the receiver's cellAddress."
    ^cellAddress!  
clearSelection
        "Private - clear the selection."
    self reverseSelection.
    selectionEnd := nil!
hasColumnLabels: aBoolean
        "Set whether receiver has column labels."
    self propertyDisplayColumnLabels: aBoolean! 
columnAt: anIntegerOrName
        "Answer an array of values at column anInteger or Name."
    | answer row element columnId |
    columnId := self columnAccessorFor: anIntegerOrName.
    answer := self indexedRows
        ifTrue: [Array new: contents size]
        ifFalse: [Dictionary new].
    self rowsDo: [ : i |
        row := contents at: i.
        element := row at: columnId ifAbsent: [nil].
        answer at: i put: element].
    ^answer
!   
directEditCellsAt: aPoint
        "Private - the user has performed a direct edit
        operation with the mouse.  This is typically the
		result of left mouse button down with the alt
		key held down.  Do nothing."!
rowsDo: aBlock
        "Private - Iterate over the rows a evaluate aBlock
          for each row."
    self indexedRows
        ifTrue: [
            1 to: contents size do: [: i |
                (contents at: i) == nil ifFalse: [aBlock value: i]]]
        ifFalse: [
            rowNames notNil
                ifTrue: [rowNames do: [: name |
                    (contents at: name ifAbsent: [nil]) == nil
                        ifFalse: [aBlock value: name]]]]!  
vwDisplayRaisedRectangle: aRectangle
        "Private - do graphics to visually raise aRectangle."

    self pen

        foreColor: Color white;
        place: ( aRectangle leftBottom rightAndUp: 1 @ 1  );
        goto: ( aRectangle leftTop rightAndDown: 1 @ 0  );
        goto: ( aRectangle rightTop leftAndDown: 1 @ 0  );

        foreColor: Color darkGray;
        goto: ( aRectangle rightBottom leftAndUp: 1 @ 1  );
        goto: ( aRectangle leftBottom rightAndUp: 1 @ 1  )!  
display
		"Private - display the receiver."
	super display.
	self displayRaisedRectangle!  
drawRectangle: aRectangle
		"Private - draw aRectangle using #place: and #goto:s to
		avoid using platform specific Pen>>rectangle: routines."
	self pen
		place: aRectangle leftBottom;
		goto: aRectangle leftTop;
		goto: aRectangle rightTop;
		goto: aRectangle rightBottom;
		goto: aRectangle leftBottom!  
textOrigin
        "Private - answer the origin of the displayed text."
    ^self textOriginX @ self textOriginY!   
convertFromString: aString
        "Private - convert aString to the receiver's type of object."
    ^self isNumberEditor
        ifTrue: [ aString asNumber ]
        ifFalse: [ aString ]!  
propertyColumnLabelHeight: anInteger
	columnLabelsHeight := anInteger!   
rowNameForInteger: anInteger
        "Private - answer a row name for anInteger.  If a row name
        has not already been defined for anInteger, create one
        and answer it."
    | answer |
    answer := rowNames at: anInteger ifAbsent: [ nil ].
    answer isNil ifTrue: [
        answer := 'row', anInteger printString.
        [ rowNames includes: answer ] whileTrue: [
            answer := answer, 'X' ].
        self setRow: anInteger name: answer ].
    ^answer!   
textOriginInteractive
        "Private - answer the origin of the displayed text when the receiver is active."
    ^self textOriginXInteractive @ self textOriginY! 
updateSliders
        "Private - update the receiver's sliders."
    self resizeActiveEditor.
    super updateSliders.!
rowBottoms: anArray
        "Private - set the row bottoms array."
    rowBottoms := anArray!   
updateVerticalSlider
        "Private - Update the slider box in the vertical scrollbar."
    self resizeActiveEditor.
    ^super updateVerticalSlider!
removeSelectedTextNoUpdate
        "Private - remove the selected text.  Do not update the display."
    | stringContents left right endLeft startRight |
    self selectedText size = 0 ifTrue: [ ^self ].
    stringContents := self stringContents.
    endLeft := ( insertionOffset min: selectionEnd ).
    startRight := ( insertionOffset max: selectionEnd ) + 1.
    left := stringContents copyFrom: 1 to: endLeft.
    right := stringContents copyFrom: startRight to: stringContents size.
    stringContents := left, right.
    self stringContents: stringContents.
    insertionOffset := insertionOffset min: selectionEnd.
    selectionEnd := nil.  "clears selection"!   
textOriginRightOffset
		"Private - answer the right text offset
		for right justified text, the distance
		between the right border of a cell and
		the right most character."
    ^self defaultLeftOffset!  
displayBackground
        "Display the background of the cell.  Do nothing."!
displayText
        "Display the receiver's text."
    | text |
    cellContents isNil ifTrue: [ ^self ].
    text := self stringContents.
    text size = 0 ifTrue: [ ^self ].
    self displayText: text! 
intersects: aRectangle
    ^true!
resizeShowCaret: aBoolean
        "Private - resize the receiver."
    super resize.
    ( self stringWidthOf: self stringContents ) < self clippingBox width
        ifTrue: [ displayOffset := 0 ].
	aBoolean ifTrue: [ self updateCaret ].
    self isCellVisible ifFalse: [ self hideCaret ]!   
setColumn: aColumnNumber readOnly: aBoolean
        "Set the read only attribute of column aColumnNumber."
    | columnEditor |
    columnEditor := self extendedEditorForColumn: aColumnNumber.
    columnEditor readOnly: aBoolean! 
selectScrollUp
        "Private - the user is mouse selecting and is causing a scroll."
    topCorner y > 1 ifTrue: [
        self
            scrollVertical: 1 ]!   
setColumn: aColumnNumber widthPixels: anInteger
        "Set the width of column aColumnNumber."
    | difference |
    difference := ( self columnWidth: aColumnNumber ) - anInteger.
    aColumnNumber to: columnRights size do: [ :i |
        columnRights at: i put: ( columnRights at: i ) - difference ]! 
propertyIndexedRows
        "Answer whether the receiver uses indexed rows access."
    ^self indexedRows!  
columnNumbers
		"Private - answer the receiver's column numbers."
	^( 1 to: numberOfColumns ) asArray!  
display
        "Private - display the receiver by reversing the rows the reciever encompasses."
    first to: last do: [ :aRow | self reverse: aRow ].!
cellAddress: aCellAddress
        "Set the receiver's cellAddress."
    cellAddress := aCellAddress!
resize
        "Private - resize the receiver."
	boundingBox := tablePane rectangleForRowLabel: self rowNumber! 
storeContents
        "Private - store the contents of the receiver back
        into the table pane."
    modified ifTrue: [
        tablePane cornerLabel: self stringContents ]!   
displayRowLabel: anInteger
        "Private - display the row label."
     | cellEditor cellRectangle |
   " cellEditor := self editorForCellAddress: 0 @ 0."
    cellEditor isNil
        ifTrue: [
            cellEditor :=  PARTSTableLabelEditor new ].
    cellRectangle := self rectangleForRowLabel: anInteger.
    cellEditor
        cellContents: ( self rowLabelFor: anInteger );
        tablePane: self;
        boundingBox: cellRectangle;
        display!   
propertyEditorReceivesArrowKeyInput
        "Answer whether the receiver should
        forward arrow key input to the active
        editor."
    ^self getBooleanProperty: #propertyEditorReceivesArrowKeyInput!
defineCornerLabelEditor
		"Private - answer the corner label editor."
	^cornerLabelEditor!  
openItemCellsAt: aPoint
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click) in one of the receiver's cells."
    | targetCell cellContents |
    targetCell := self cellAddressFor: aPoint.
    targetCell isNil ifTrue: [ ^self ].
    cellContents := self cellAtPoint: targetCell.
    self
        triggerEvent: #doubleClickedOnCell: with: cellContents;
        triggerEvent: #doubleClickedOnCell.!   
displayText: aString
        "Display aString."
    self pen
        displayText: aString
        at: self staticTextOrigin
        in: self clippingBox
        options: self displayClipOption
        adx: nil! 
setRow: aRowNumber name: aString
        "Set the name of row aRowNumber."
    rowNames isNil ifTrue: [ rowNames := Array new: aRowNumber ].
    rowNames size < aRowNumber ifTrue: [
        rowNames := rowNames, ( Array new: aRowNumber - rowNames size ) ].
    rowNames at: aRowNumber put: aString!   
textOriginLeftOffset
         "Private - answer the left text offset,
        the distance between the left border
        of a cell and the left most character."
    ^self defaultLeftOffset!   
updateAccess
        "Private - row and/or column access has changed.
        Configure the internal storage appropriately."
    self indexedRows
        ifTrue: [
            self indexedColumns
                ifTrue: [ self indexedRowsIndexedColumns ]
                ifFalse: [ self indexedRowsNamedColumns ]]
        ifFalse: [
            self indexedColumns
                ifTrue: [ self namedRowsIndexedColumns ]
                ifFalse: [ self namedRowsNamedColumns ]]!
horizontalGridLineDotted
        "Set the receiver to have dotted horizontal grid lines."
    self propertyAt: #horizontalGridLineType put: LineTypeDot!
displayColumnLabels
        "Private - Display the receiver's column labels."
    cellsToDisplay isNil ifTrue: [ ^self "receiver is not visible" ].
    cellsToDisplay left to: ( cellsToDisplay right min: self numberOfColumns ) do: [ :columnNumber |
        self displayColumnLabel: columnNumber ]! 
keyboardInputLeft
        "Private - the left arrow key was pressed."
    self propertyEditorReceivesArrowKeyInput ifTrue: [
        ^self activeEditor notNil ifTrue: [
            self activeEditor keyboardInputLeft ]].
    ( selectedCell notNil and: [ selectedCell x > 1 ] )
        ifTrue: [
            self selectCellAddress:  selectedCell x - 1 @ selectedCell y.
            self insureSelectedCellIsVisible ]
        ifFalse: [
            self userInputRejected ]!
stringContents: aString
        "Private - set the receiver's contents to be that
        represented by aString."
    cellContents := aString.
    tablePane cornerLabel: aString!   
numberOfRows
        "Answer the number of rows in the receiver."
    ^numberOfRows!
rightOfColumn: aColumnAddress
        "Private - answer the pixel x coordinate that is
        the right border of aColumnAddress."
    ^self leftOfColumn: aColumnAddress + 1!
propertyDisplayColumnLabels: aBoolean
	self setBooleanProperty: #propertyDisplayColumnLabels to: aBoolean!   
staticTextOrigin
		"Private - answer the origin at which
		text should be displayed."
	^self textOrigin!   
rowLabelsColor
        "Answer the color of the row labels."
    ^self propertyAt: #rowLabelsColor ifAbsent: [ SystemColorButtonFace ]! 
activate
        "Private - activate the receiver.
        Do nothing."!
reactiveEditors
		"Private - answer the collection of cell editors that are reactive."
	^self propertyAt: #reactiveEditors ifAbsent: [ Array new ]! 
rowNumber
		"Private - answer the row number of the receiver."
	^cellAddress!   
textOriginXRight
        "Private - answer the x coordinate
        of the text origin for centered text."
    ^ boundingBox right left: self stringWidth + self textOriginRightOffset!
makeNumberEditor
        "Configure the receiver to edit numbers."
    self setTextAlignRight.
    self validationMessage: self numberValidationMessage!   
rowToSizeAt: aYCoordinate
        "Private - answer the number of the row that
        would be sized if the sizing mouse is button is pressed
        at aYCoordinate and aYCoordiate is closest enough
        to the rows bottom side.  Answer 0 if the column labels
        height is to be adjusted."
    | rowBottom slack |
    slack := self propertyMouseResizeProximity.
    ( self propertyAdjustColumnLabelsHeight and: [ self propertyDisplayColumnLabels ] )
        ifTrue: [
            ( self columnLabelsBottom - aYCoordinate ) abs <= slack
                ifTrue: [ ^0 ]].
    self propertyAdjustRowHeights ifFalse: [ ^nil ].
    self cellsInRectangle origin y to: self cellsInRectangle corner y do: [ :row |
        rowBottom := self bottomOfRow: row.
        ( aYCoordinate - rowBottom ) abs < slack ifTrue: [
            ^row ]].
    ^nil! 
hasColumnLabels
        "Answer whether receiver has column labels."
    ^ self propertyDisplayColumnLabels!
setRow: aRowNumber height: anInteger
        "Set the height of row aRowNumber."
    | difference |
    difference := ( self rowHeight: aRowNumber ) - anInteger.
    aRowNumber to: rowBottoms size do: [ :i |
        rowBottoms at: i put: ( rowBottoms at: i ) - difference ]!   
keyboardInputLeft
        "Private - the left arrow key was pressed.
        Do nothing."!  
propertyMouseResizeProximity
        "Answer the row and column mouse resizing
        proximity - the number of pixels the cursor
        can be away from a resizing coordinate and
        still able to resize."
    ^self
        propertyAt: #propertyMouseResizeProximity
        ifAbsent: [ self defaultMouseResizeProximity ]!   
rowNumber: anInteger
		"Private - set the receiver's row number."
	self cellAddress: anInteger! 
setTextAlignRight
		"Configure the receiver to display and edit text
		right justified."
	textOriginXSelector := #textOriginXRight!
pen
		"Private - answer the pen the
		receiver should use for drawing."
	^tablePane pen!   
keyboardInputCr
        "Private - the <cr> key was pressed."
	| row column cellContents oldSelectedCell |
	( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
		ifTrue: [
			^self releaseActiveEditor ].
	selectedCell notNil ifTrue: [
		oldSelectedCell := selectedCell ].
    ( selectedCell notNil and: [ selectedCell y < numberOfRows ] )
        ifTrue: [
            self selectCellAddress:  1 @ ( selectedCell y + 1 ).
            self insureSelectedCellIsVisible ]
        ifFalse: [
            self userInputRejected ].
	selectedCell notNil ifFalse: [ ^self ].
	cellContents := self cellAtPoint: oldSelectedCell.
	row := self indexedRows
		ifTrue: [ oldSelectedCell y ]
		ifFalse: [ self rowNameFor: oldSelectedCell y ].
	column := self indexedColumns
		ifTrue: [ oldSelectedCell x ]
		ifFalse: [ self columnNameFor: oldSelectedCell x ].
	( self hasActionForEvent: #rowEntered: )
		ifTrue: [
			self
				triggerEvent: #rowEntered:
				with: row ].
	( self hasActionForEvent: #cellEnteredAtRow:column:value: )
		ifTrue: [
			self
				triggerEvent: #cellEnteredAtRow:column:value:
				withArguments: ( Array with: row with: column with: cellContents ) ]!   
selectedGroup
    ^selectedGroup isNil
        ifTrue: [ nil ]
        ifFalse: [ selectedGroup contents ]!
setCell: aCell backColor: aColor
        "Set aCell to have aColor as back color."
    | cellEditor |
    cellEditor := self extendedEditorForCell: aCell.
    cellEditor backColor: aColor.
    self updateDisplayCell: aCell!  
setColumn: aColumnNumber label: aString
		"Set the label of column aColumnNumber."
    columnLabels isNil ifTrue: [ columnLabels := Array new: aColumnNumber ].
    columnLabels size < aColumnNumber ifTrue: [
        columnLabels := columnLabels, ( Array new: aColumnNumber - columnLabels size ) ].
    columnLabels at: aColumnNumber put: aString!   
boundingBox
        "Answer the receiver's boundingBox."
    ^boundingBox!  
cornerLabelColor
        "Answer the color of the top left corner label."
    ^self propertyAt: #cornerLabelColor ifAbsent: [ SystemColorButtonFace ]!  
openItemAt: aPoint
		"Private - the user has performed an open operation with the mouse
		(probably left bottom double click).  Select the word at aPoint."
	| charIndex from to |
	self clearSelection.
	self stringContents size = 0 ifTrue: [ ^self ].
	charIndex := self insertionOffsetAt: aPoint.
	from := ( self wordSelectionLeftAt: charIndex ) max: 0.
	to := self wordSelectionRightAt: charIndex.
	self selectFrom: from to: to! 
cellAtPoint: aPoint put: anObject
        "Set the value in the table pane at aPoint.
        aPoint is INTEGER cell coordinates.  Trigger
        the event that inidicates a cell has changed."
    self
        cellAtPoint: aPoint primitivePut: anObject;
            triggerCellChanged: anObject at: aPoint! 
setFocusAtRow: aRow column: aColumn
        "Set the focus on row aRow and column aColumn."
    | row column |
    row := self indexedRows
        ifTrue: [aRow]
        ifFalse: [rowNames indexOf: aRow ifAbsent: [nil]].
    column := self indexedColumns
        ifTrue: [aColumn]
        ifFalse: [columnNames indexOf: aColumn ifAbsent: [nil]].
    column > numberOfColumns ifTrue: [ ^self ].
    row > numberOfRows ifTrue: [ ^self ].
    (row notNil and: [column notNil]) ifTrue: [
        self selectCellAddress: column @ row.
        "self setFocus" ]! 
cellAtRow: aRow column: aColumn put: aValue
        "Store aValue in the cell at aRow and aColumn."
    self cellAtRow: aRow column: aColumn putNoShow: aValue.
    self updateDisplayRow: aRow column:  aColumn!  
propertyNumberOfColumns
	^self numberOfColumns!  
initializeTextAlignment
		"Private - initialize the receiver's text alignment parameters."
	self
		setTextAlignCenteredHorizontally;
		setTextAlignCenteredVertically!
beginDragAt: aPoint
        "Private - the user has initiated a mouse drag operation.
        Do nothing."! 
regionIndexAt: aPoint
       "Private - answer a number corresponding to the region of the
        receiver containing aPoint.  1 = top left corner, 2 = column labels,
        3 = row labels, 4 = cells."
    ( aPoint y isAboveEqual: self columnLabelsBottom )
        ifTrue: [
            ( aPoint x isLeftEqualOf: self rowLabelsRight )
                ifTrue: [ ^1 ]
                ifFalse: [ ^2 ]].
    ( aPoint x isLeftEqualOf: self rowLabelsRight )
        ifTrue: [ ^3 ].
    ^4!  
keyboardInputDown
        "Private - the down arrow key was pressed."
    ( self activeEditor notNil and: [ self activeEditor isLabelEditor ] )
        ifTrue: [
            ^self releaseActiveEditor ].
    ( selectedCell notNil and: [ selectedCell y < numberOfRows ] )
        ifTrue: [
            self selectCellAddress:  selectedCell x @ ( selectedCell y + 1 ).
            self insureSelectedCellIsVisible ]
        ifFalse: [
            self userInputRejected ]!   
controlKeyInput: aKeyboardInputEvent editor: aCellEditor
		"Private - aKeyboardInputEvent was sent to aCellEditor.
		aKeyboardInputEvent is a control key event, so aCellEditor
		has the table pane (the receiver) decide what to do."
	self
		triggerEvent: #controlKeyInput:editor:
		withArguments: ( Array with: aKeyboardInputEvent with: aCellEditor )
		ifNotHandled: [ self controlKeyInputDefault: aKeyboardInputEvent editor: aCellEditor ]!
horizontalGridLineColor
        "Answer the horizontal grid line color."
    ^self propertyAt: #horizontalGridLineColor ifAbsent: [
        self foreColor isNil
            ifTrue: [ SystemColorWindowText ]
            ifFalse: [ self foreColor ]]! 
backColor
		"Private - answer the receiver's background color."
	^backColor isNil
		ifTrue: [ tablePane propertyLabelBackColor ]
		ifFalse: [ backColor ]!
isLegalNumberContents: aString
        "Private - answer whether aString contains
        a proper number representation for the receiver."
    | decimals digits abs |
    abs := aString first = $-
        ifTrue: [ aString copyFrom: 2 to: aString size ]
        ifFalse: [ aString ].
    decimals := abs select: [ :c | c = $. ].
    digits := abs select: [ :c | c isDigit ].
    ^decimals size <= 1 and: [
        decimals size + digits size = abs size ]!
openItemTopLeftCornerAt: aPoint
        "Private - the user has performed an open operation with the mouse
        (probably left bottom double click) in the top left corner label of
        the receiver.  Default behavior is to do nothing."! 
textOriginY
        "Private - answer the y coordinate of the text origin."
    ^self perform: textOriginYSelector! 
controlKeyInputDefault: aKeyboardInputEvent editor: aCellEditor
		"Private - aKeyboardInputEvent was sent to aCellEditor.
		aKeyboardInputEvent is a control key event, so aCellEditor
		has the table pane (the receiver) decide what to do."
	| char asciiValue |
	char := aKeyboardInputEvent character.
	char isCharacter ifFalse: [ ^self ].
	asciiValue := char asciiValue.
	asciiValue = 3 "Ctrl C" ifTrue: [ ^aCellEditor copySelection ].
	asciiValue = 22 "Ctrl V" ifTrue: [ ^aCellEditor pasteSelection ].!   
popUpMenuAt: aPoint
		"Private - the user has performed the mouse operation to pop up a menu."!  
releaseActiveEditor
		"Private - release the active editor."
	self activeEditor notNil ifTrue: [
		self activeEditor release.
		self activeEditor: nil ].!
resize
        "Private - resize the receiver."
	boundingBox := tablePane rectangleForColumnLabel: self columnNumber!   
isShareable
        "Answer true if the receiver can be used for
        multiple cell addresses."
    ^updateMessage notNil!  
displayGrid
        "Display the lines separating the cells."
    | gridRectangle |
    gridRectangle := self rowLabelsRight + 1 @ ( self columnLabelsBottom down: 1 )
        rightBottom: ( self rightColumnRight leftMost: rectangle right ) @
			( self bottomRowBottom higherOf: rectangle bottom ).
    self
        displayVerticalGridLines: gridRectangle;
        displayHorizontalGridLines: gridRectangle!
containsOffset: anInteger
    ^anInteger <= last and: [
        anInteger >= first]!
keyBoardInputControlInsert
        "Private - the insert key was pressed with control held down.
        Copy selected the text to clipboard.  Leave the selected text
        unaffected."
	self copySelection!  
drawInvertHorizontalLineAt: aYCoordinate
        "Private - draw a horizontal line at aYCoordinate
        using an inert draw operation."
    | left right |
    left := rectangle left @ aYCoordinate.
    right := ( rectangle right leftMost: self rightColumnRight ) @ aYCoordinate.
    graphicsTool
      "  setMix: MixRuleInvertSurface;"
		setForegroundMode: MixRuleInvertSurface;
        place: left;
        goto: right;
        "setMix: MixRuleDefault"
		setForegroundMode: MixRuleDefault! 
reverseRectangleOutline: aRectangle
        "Private - reverse the outline of aRectangle."
    
    graphicsTool
       " setMix: MixRuleInvertSurface;" "OS/2"
        setForegroundMode: MixRuleInvertSurface.
	self drawRectangle: aRectangle.
	graphicsTool
       " rectangle: aRectangle;"
        "setMix: MixRuleDefault"
        setForegroundMode: MixRuleDefault!
privateReadOnly
        "Private - answer true if the receiver is read only
        and not being edited in a PARTS workbench."
    self superPartIsEditing ifTrue: [ ^false ].
    ^self propertyReadOnly!   
wmContextmenu: mp1 with: mp2
        "Private - the user has performed the mouse operation to pop up menu."
    self partsVosOnly.
    self sendInputEvent: #popUpMenuAt: with: mp1 asPoint.
    ^nil!
copy
		"Answer a copy of the receiver."
	^super copy
		caretIsVisible: caretIsVisible;
		displayOffset: displayOffset;
		insertionOffset: insertionOffset;
		modified: modified;
		readOnly: readOnly;
		selectionEnd: selectionEnd;
		textOriginXSelector: textOriginXSelector;
		textOriginYSelector: textOriginYSelector;
		validationMessage: validationMessage copy;
		yourself! 
convertRowToNamedAccess: anArrayOrDictionary
        "Private - answer a row representation or anArrayOrDictionary
        that supports named column access."
    | answer columnName columnValue |
    anArrayOrDictionary isDictionary ifTrue: [ ^anArrayOrDictionary ].
    answer := Dictionary new.
    1 to: anArrayOrDictionary size do: [ :i |
        columnName := self columnNameForInteger: i.
        columnValue := anArrayOrDictionary at: i.
        answer at: columnName put: columnValue ].
    ^answer!
columnNumber: anInteger
		"Private - set the receiver's column number."
	self cellAddress: anInteger!   
resize
        "Private - resize the receiver."
	boundingBox := tablePane clippingBoxForCell: self cellAddress! 
extendedEditorForCell: aCell
        "Private - answer the extented cell editor for aCell.
        Create one and install it if one doesn't already exist."
    | answer |
    cellEditorMap isNil
        ifTrue: [
            answer := PARTSTableCellExtendedTextEditor new.
            self setCell: aCell editor: answer  ]
        ifFalse: [
            answer := cellEditorMap columnEditorAtColumn: aCell.
            answer isNil ifTrue: [
                answer := PARTSTableCellExtendedTextEditor new.
                self setCell: aCell editor: answer ]].
    ^answer!
readOnly
        "Private - answer true if the receiver is read only."
    ^readOnly!   
scrollLeftNoUpdateDisplay
        "Private - scroll the receiver left by 1 character."
    self scrollLeftNoUpdateDisplay: 1!   
propertiesAboutToChange
		"Private - some of the receiver's properties are about to change.
		Save the style variable to compare with the style
		when the #propertiesHaveChanged message is sent."
	self propertyAt: #savedStyleVariable put: self scrollStyle!  
cellAtPoint: aPoint primitivePut: anObject
        "Set the value in the table pane at aPoint.
        aPoint is INTEGER cell coordinates."
    | row rowName columnName |
    self insureCellsExtent: aPoint.
    self indexedRows
        ifTrue: [
            row := contents at: aPoint y.
            self indexedColumns
                ifTrue: [
                    row at: aPoint x put: anObject ]
                ifFalse: [
                    row isNil ifTrue: [
                        row := self createRowForNamedColumns.
                        contents at: aPoint y put: row ].
                    columnName := self columnNameForInteger: aPoint x.
                    row at:  columnName put: anObject ]]
        ifFalse: [
            rowName := self rowNameForInteger: aPoint y.
            row := contents at: rowName ifAbsent: [ nil ].
            row isNil
                ifTrue: [
                    self indexedColumns
                        ifTrue: [
                            row := Array new: aPoint x.
                            row at: aPoint x put: anObject ]
                        ifFalse: [
                            row := self createRowForNamedColumns.
                            columnName := self columnNameForInteger: aPoint x.
                            row at: columnName put: anObject ].
                    contents at: rowName put: row ]
                ifFalse: [
                    self indexedColumns
                        ifTrue: [
                            row at: aPoint x put: anObject ]
                        ifFalse: [
                            columnName := self columnNameForInteger: aPoint x.
                            row at: columnName put: anObject ]]].
    self setModified! 
propertyAltClickEditLabels: aBoolean
    ^self setBooleanProperty: #propertyAltClickEditLabels to: aBoolean! 
updateInsertionOffsetAt: aPoint
        "Private - update the insertionOffset variable to
        be that for window coordinates aPoint."
    insertionOffset := self insertionOffsetAt: aPoint.!  
atRow: aRow  put: anObject
        "Private - Put anObject at row aRow."
    | row |
	self setModified.
    row := self indexedRows
        ifTrue: [aRow]
        ifFalse: [
            aRow isInteger
                ifTrue: [rowNames at: aRow ifAbsent: [nil]]
                ifFalse: [aRow]].
    row notNil ifTrue: [
		self indexedRows
			ifTrue: [
				contents size < row
					ifTrue: [ contents := contents, ( Array new: row - contents size ) ]].
		contents at: row put: anObject ]!
propertyAltClickEditLabels
    ^self getBooleanProperty: #propertyAltClickEditLabels!
propertyDisplayRowLabels: aBoolean
	self setBooleanProperty: #propertyDisplayRowLabels to: aBoolean!