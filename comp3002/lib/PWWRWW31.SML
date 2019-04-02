3.1.0.106
   
resizeFromHeightAndPosition
        "Private - Update the width and position."
    self framingBlock
        top: self framingBlock top stretched: false height: reportField height / 100 stretched: false.
    self isValid ifTrue: [
        self resizeToRectangle: ( self framingBlock
            scaleFrom: self superWindow rectangle ) ]!   
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "
    super initializePartValues.
    self breakFieldMultipleChoiceList
        setList: self part fieldsToBreakOn;
        setValue: self part breakFields keysAsArray.
    self haveRunningReportCheckbox setValue: self part haveRunningReport! 
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        groupBreaks: (groupBreaks partMirrorCopy: aDict);
        numberOfColumns: (numberOfColumns partMirrorCopy: aDict);
        trailingHeight: (trailingHeight partMirrorCopy: aDict).
    ^copy!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "!
groupBreaks: aCollection
    groupBreaks := aCollection! 
pageHeaderFont
        "Private - Answer the font used for the automatically generated page Header."
    ^ Font new
        faceName: (self partsIfOS2Do: ['Helv'] partsIfWindowsDo: ['MS Sans Serif']);
        pointSize: 8;
        fixedWidth: false;
        bold: true;
        italic: false;
        yourself.!   
partDefaultExtent
    ^200 @ 2!  
itemWidth: formItem font: aFont
    ^(aFont stringWidth: formItem labelItem visualPart label , '<>')
        max: formItem partItem itemExtent x.!  
addReportFooter: aReportFrame
    | reportFrameBody reportTextPart height aRect width|
    reportFrameBody := aReportFrame reportFrameBody.
    reportTextPart := self class reportTextPart.
    reportTextPart
        setValue: 'Report Footer';
        justification: #center;
        font: self class reportFooterFont.
    height := self lineHeight.
    width := (reportTextPart font stringWidth:
        reportTextPart value) + 10.
    aRect := (reportFrameBody rectangle leftTop
        rightAndDown: (reportFrameBody rectangle width - width) // 2 @ (height * 8))
        extentFromLeftTop: width @ height.
    aRect := aRect
        mapFromWindow: reportFrameBody
        to: aReportFrame partEditor workbenchPane.
    self pastePart: reportTextPart
        in: reportFrameBody
        rect: aRect
        name: 'ReportFooter'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'ReportTextPart' ).!
partSetDirectEditAttribute: aString
    self fieldName: aString.
    self invalidateRect: nil!  
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.
    self breakFieldMultipleChoiceList value ~= self part breakFields
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #breakFieldsFromNames:
                    arguments: (Array with: self breakFieldMultipleChoiceList value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #breakFields:
                    arguments: (Array with: self part breakFields) ) ].
    self haveRunningReportCheckbox value ~= self part haveRunningReport
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #haveRunningReport:
                    arguments: (Array with: self haveRunningReportCheckbox value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #haveRunningReport:
                    arguments: (Array with: self part haveRunningReport) ) ].!
addRecordFrame: columns summaryFields: summaryFields breakFields: breakFields in: aReportFrame
    | aRect reportFrameBody recordFrame reportColumnPart height |
    reportFrameBody := aReportFrame reportFrameBody.
    height := self lineHeight.
    aRect := (reportFrameBody rectangle leftTop down: (4 * height))
        extentFromLeftTop: 0 @ (4 * height).
    "The width will later be set to the width of the reportFrameBody."
    aRect := aRect
        mapFromWindow: reportFrameBody
        to: aReportFrame partEditor workbenchPane.
    recordFrame := self recordFrame.
    self pastePart: recordFrame
        in: reportFrameBody
        rect: aRect
        name: 'RecordFrame'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'RecordFrame' ).
    aRect := aRect leftTop
        extentFromLeftTop: 0 @ height.
    columns do: [:formItem |
        reportColumnPart := self class reportColumnPart: formItem.
        aRect width: reportColumnPart rectangle width.
        "Align it under the corresponding report column header."
        aRect leftTop x: formItem partItem visualPart rectangleAttribute left.
        self pastePart: reportColumnPart
            in: recordFrame
            rect: aRect
            name: (reportColumnPart fieldName , 'Column')
            helpInfo: ( Array
                with: 'PARTS.HLP'
                with: 'ReportColumnPart' ).
        aRect := aRect moveBy: (reportColumnPart rectangle width + self spaceBetweenColumns) @ 0].
    self addGroupFrame: summaryFields breakFields: breakFields in: recordFrame! 
leftMarginPane
        "Private - "
    self children do: [:child |
        child name == #leftMargin ifTrue: [^child]
        ].!
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'Pprwdisp.par'! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    self initializeTextPartValues.
   self fieldNameEntryField setValue: part fieldName.
    self functionListPane
        setList: part reportField functionNames;
        setValue: part function.! 
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. "
    self partName: text! 
numberOfColumns: anInteger
    numberOfColumns := anInteger.
    self handle isValid
        ifTrue: [self invalidateRect: nil ].! 
reportColumnPart: formItem
        "Private - Answer an instance of a PARTSReportColumnPart based on
        formItem an instance of PARTSFormGeneratorItem."
    | reportColumnPart aRect |
    reportColumnPart := (PARTSApplication fromFile: 'REPCOLMN.PAR') solePart.
    reportColumnPart fieldName: formItem labelItem visualPart label.
    aRect := 0 @ 0 extentFromLeftTop: 0 @ 0.
    aRect width: (self itemWidth: formItem font: self pageHeaderFont).
    reportColumnPart
        rectangleAttribute: aRect;
        font: self columnFont.
    (formItem partItem isKindOf: PARTSNumericField)
        ifTrue: [reportColumnPart justification: #right].
    ^reportColumnPart!  
reportWidthFromUser: aNumber
        "Private - Accept the report width aNumber specified by user
        in system settings measurement."
    self reportWidth: (self measurementFromUser: aNumber).
    self validateReportWidth!   
groupFrame
        "Private - Answer an instance of a PARTSReportFramePart to be
        added to the workbench."
    ^(PARTSApplication fromFile: 'GRUPFRAM.PAR') solePart!   
fieldNameEntryField
    ^self partNamed: 'FieldNameEntryField'!  
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "
    super constructApplyActions.
    self constructTextApplyActions.
    self fieldNameEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #fieldName:
                    arguments: (Array with: self fieldNameEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #fieldName:
                    arguments: (Array with: self part fieldName) ) ].
    self doNotRepeatCheckbox value ~= self part doNotRepeat
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #doNotRepeat:
                    arguments: (Array with: self doNotRepeatCheckbox value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #doNotRepeat:
                    arguments: (Array with: self part doNotRepeat) ) ].!
columnSummaryPart: formItem
        "Private - Answer an instance of a PARTSColumnSummaryPart based on
        formItem an instance of PARTSFormGeneratorItem."
    | columnSummaryPart aRect |
    columnSummaryPart := (PARTSApplication fromFile: 'REPSMMRY.PAR') solePart.
    columnSummaryPart fieldName: formItem labelItem visualPart label.
        "set the width to the wider of the label and the field."
    aRect := 0 @ 0 extent: 0 @ 0.
    aRect width: (self itemWidth: formItem font: self columnFont).
    columnSummaryPart
        rectangleAttribute: aRect;
        font: self columnFont.
    ^columnSummaryPart!
partDirectEditInitialValue
        "Answer the direct edit value of the receiver."
    ^self partName!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "
    super fileInUpgrade: anObjectFiler.
    children notNil ifTrue: [   "children are created at open time."
        self children: nil ]!   
measurmentUnitStaticText
    ^self partNamed: 'MeasurmentUnitStaticText'!
captionBackColor
        "Private - Answer the color used in the caption area as
        the shadow of the receiver."
    ^Color red!  
bottomMarginForUser
        "Private - Answer the bottom margin in system
        settings measurement units."
    ^self measurementForUser: bottomMargin! 
reportOnFirstPageCheckbox
    ^self partNamed: 'ReportOnFirstPageCheckbox'!  
removeSubpane: aSubpane
        "Private - Redisplay the ruler panes after the subpane is
        removed so the captions will be removed as well."
    super removeSubpane: aSubpane.
    aSubpane isPARTSReportStructure
        ifTrue: [
            self reportFrameParent leftMarginPane invalidateRect: nil.
            self reportFrameParent rightMarginPane invalidateRect: nil.]!  
wordwrapCheckbox
    ^self partNamed: 'WordwrapCheckbox'!
breakFields: aCollection
    breakFields := aCollection! 
partDefaultExtent
        "Private - The eventual width is the width of the containing
        frame"
    ^100 @ 4!
removeRulers
        "Private - Remove the ruler panes.  Used when saving
        for execution."
    self children do: [:child |
        child isPARTSReportFrameBody
            ifFalse: [
                self children removeKey: (self children keyAtValue: child ifAbsent: [])]]!
display
        "Private - display the receiver."
    self pen
        setMapMode;
        backColor: self backColor;
        rectangleFilled: self reportRectangle! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "
    super initializePartValues.
    self reportOnFirstPageCheckbox setValue: part reportOnFirstPage.!   
partShrinkWrap
        "Private - Answer the parent window which can be shrunk in
        the parts window."
    ^self!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #function: with: self function;
        addSelectorIfNotNil: #fieldName: with: self fieldName!  
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "
    
    super constructApplyActions.
    self widthEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #widthFromUser:
                    arguments: (Array with: self widthEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #widthFromUser:
                    arguments: (Array with: self part widthForUser) ) ].
    self positionEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #positionFromUser:
                    arguments: (Array with: self positionEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #positionFromUser:
                    arguments: (Array with: self part positionForUser) ) ].!  
arePropertiesValid
        " Private - answer whether  the values of the properties are valid.
        If not valid, notify the user of the problem and answer false.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #arePropertiesValid to super."

    ^super arePropertiesValid
        and: [self isDecimalDigitsPropertyValid]! 
haveRunningReport: aBoolean
    haveRunningReport := aBoolean!   
addReportHeader: aReportFrame
    | reportFrameBody reportTextPart height aRect width|
    reportFrameBody := aReportFrame reportFrameBody.
    reportTextPart := self class reportTextPart.
    reportTextPart
        setValue: 'Report Header';
        justification: #center;
        font: self class reportHeaderFont.
    height := self lineHeight.
    width := (reportTextPart font stringWidth:
        reportTextPart value) + 10.
    aRect := (reportFrameBody rectangle leftTop
        right: (reportFrameBody rectangle width - width) // 2)
        extentFromLeftTop: width @ height.
    aRect := aRect
        mapFromWindow: reportFrameBody
        to: aReportFrame partEditor workbenchPane.
    self pastePart: reportTextPart
        in: reportFrameBody
        rect: aRect
        name: 'ReportHeader'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'ReportTextPart' ).!  
pageHeader
        "Private - Answer an instance of a PARTSPageBreakPart to be
        added to the reportFrame."
    ^(PARTSApplication fromFile: 'REPPGHDR.PAR') solePart!   
measurementForUser: aNumber
        "Private - Convert the aNumber from system settings
        measurement units to 0.1 mm."
    ^(aNumber *
        (self unit ==  self basicUnit
            ifTrue: [0.01]
            ifFalse: [0.00393700787]))  printRounded: 2! 
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'Pprwrecd.par'! 
pastePart: aPart
    in: destWindow
    rect: aRect
    name: partName
    helpInfo: helpInfo
        " Private - paste aPart in aWindow. "
    | isVisualPart |
        " Override super class because the following test fails for
        report parts.
        ( destWindow partCanWindow: destWindow haveChild: EntryField new )
            ifFalse: [ ^nil ]."
    isVisualPart := aPart isWindow.
    destWindow partEditor
        addComponent: aPart
        in: destWindow
        box: aRect
        contents: nil
        name: partName copy
        icon: ( isVisualPart
            ifTrue: [ nil ]
            ifFalse: [ aPart partIcon ] )
        helpInfo: helpInfo.!  
functionListPane
    ^self partNamed: 'FunctionListPane'!
captureReportItems
        "Private - Scan the children and create the reportLines."
    | sortedFields lastBottom line lineTop |
    reportLines := OrderedCollection new.
    lineTop := lastBottom := self frameTop.
    line := OrderedCollection new.
    sortedFields := self fields.
    sortedFields do: [:f |
        ((f frameRelativeRectangle top isBelow: lastBottom)
            or: [f isPARTSReportStructure]) "report panes are on their own line."
            ifTrue: [
            line isEmpty ifFalse: [reportLines add: line].
            line := OrderedCollection new.
            lineTop := lastBottom].
        f reportEverytime ifTrue: [line add: f reportField].
        lastBottom := lastBottom lowerOf: f frameRelativeRectangle bottom.
        f reportField location y:
            (self verticalPixelsToLowMetric: (f verticalPosition - lineTop) abs).
    "Each report frame is on its own line, regardless of overlap."
        f isPARTSReportStructure ifTrue: [
            line isEmpty ifFalse: [reportLines add: line].
            line := OrderedCollection new.
            lineTop := lastBottom]].
    "add the last line."
    line isEmpty ifFalse: [reportLines add: line].
    "take care of empty space at the bottom of self."
    self trailingHeight: (self verticalPixelsToLowMetric:
        (sortedFields isEmpty
            ifTrue: [self rectangle height]
            ifFalse: [(self rectangle bottom - (self rectangle bottom higherOf:
                self children asSortedCollection asOrderedCollection last
                    frameRelativeRectangle bottom)) abs])) abs.
    ^reportLines!   
display
    | reportRectangle |
    reportRectangle := self reportRectangle.
    self pen
        fontInDifferentMapMode: self font;
        setBackgroundMode: BackgroundMixTransparent;
        displayText: self stringToDisplayInWorkbench
            in: reportRectangle
            wordWrap: self
            reportField wordWrap
            justification: reportField justification ;
        setLineType: LineTypeDot;
        "The following usage of #origin is platform independent."
        place: reportRectangle origin;
        box: reportRectangle extent - 1 .! 
doNotRepeatCheckbox
    ^self partNamed: 'DoNotRepeatCheckbox'!  
fieldNameEntryField
    ^self partNamed: 'FieldNameEntryField'!  
partCanHaveParent: aParent
        "Private - answer a boolean if aParent is acceptable."
    ^aParent isPARTSReportStructure!  
hasIconProperty
        " Private - answer whether my part has
        an icon property. "
    ^false! 
firePageHeaders: aBoolean
        "Private - if aBoolean is true, page footers will be generated on the
        current page before starting the new page. "
    firePageHeaders := aBoolean!  
partReportInitColorsFont
        "Private - set the receiver's font and color attributes.
         We are doing this because the base font:,backColor:,foreColor:
         call invalidateRect: which causes the window to be repainted
         numerous times when it is opened. This is a workaround
         until we fix the base."
    | backColor foreColor |
    self partsVosOnly.
    self fontAttribute: self font.
    ( backColor := self backColor ) isNil
            ifTrue: [ backColor := self class defaultBackColor ].
    super backColor: backColor.
    ( foreColor := self foreColor ) isNil
        ifTrue: [ foreColor := self class defaultForeColor ].
    super foreColor: foreColor.
    graphicsTool notNil ifTrue: [
        graphicsTool
            font: self font;
            backColor: backColor;
            foreColor: foreColor.
        self isVisible ifTrue: [ self invalidateRect: nil ] ]! 
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^true!
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self value!   
resizeWithNewPARTSFramer
        "Private - resize the receiver after its framer has been changed."
    self
        resizeToRectangle: (self framingBlock
            scaleFrom: self superWindow rectangle)!
functionListPane
    ^self partNamed: 'FunctionListPane'!
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'PPrwclmn.par'! 
partDirectEditValue
        "Answer the direct edit value of the receiver."
    ^self partName! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: 'LeftMargin: ';
        nextPutAll: self leftMarginForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'RightMargin: ';
        nextPutAll: self rightMarginForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.


    aStream
        nextPutAll: aString;
        nextPutAll: 'TopMargin: ';
        nextPutAll: self topMarginForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'BottomMargin: ';
        nextPutAll: self bottomMarginForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.!  
topMarginFromUser: aNumber
        "Private - Accept the top margin aNumber specified by user
        in system settings measurement."
    topMargin := self measurementFromUser: aNumber.
    self resizeToRectangle: self frameRelativeRectangle.
    self invalidateRect:  nil!   
breakFieldsListPane
        " Private "
    ^'breakFieldsList'! 
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportGroupProperties new openOn: self.! 
reportTextPart
        "Private - Answer an instance of a PARTSReportTextPart to be
        added to the reportFrame."
    ^(PARTSApplication fromFile: 'REPTEXT.PAR') solePart!   
removeField
        " Private - remove the selected field name
        from the list. "
    | listPane selectedItem index |
    listPane := self paneAt: self recordFrameFieldsListPane.
    list := listPane contents.
    selectedItem := listPane selectedItem.
    index := list indexOf: selectedItem.
    list := list reject: [ :item | item = selectedItem].
    listPane contents: list.
    (list size > 0)
        ifTrue: [listPane selectIndex: (index min: list size)]
        ifFalse: [(self paneAt: self removeButtonName) disable].
    (self paneAt: self summaryFieldsListPane)
        deleteItem: selectedItem.
    (self paneAt: self breakFieldsListPane)
        deleteItem: selectedItem.!  
pageHeightEntryField
    ^self partNamed: 'PageHeightEntryField'!
frameParts
    | answer |
    answer := OrderedCollection new.
    self children do: [:child |
        child isPARTSReportStructure
            ifTrue: [answer addAll: child frameParts]].
    ^answer!
initialize
        " Private "
    super initialize.
    self label: 'Create report writer parts...'.! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "
    ^true!   
lineHeight
        "Private - Answer in pixels the height used by a reportTextPart
        having a default font."
    | oldFont pen height aFont |
    pen := Display pen.
    oldFont := pen font.
    pen font: ( ( aFont := self class reportTextPart font ) isNil
        ifTrue: [ PARTSHostInterface defaultPartFont ]
        ifFalse: [ aFont ] ).
    height := pen font lineSpacing.
    pen font: oldFont.
    ^height + 1!
partDirectEditValue
        "Answer the direct edit value of the receiver."
    ^self partName! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: 'Position: ';
        nextPutAll: self positionForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Width: ';
        nextPutAll: self widthForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.!  
addPageFooterIn: aReportFrame
        "Private - Add a page footer which has a page number on the
        lower right"
    | aRect reportFrameBody pageFooter reportTextPart height |
    reportFrameBody := aReportFrame reportFrameBody.
    height := self lineHeight.
    aRect := (reportFrameBody rectangle leftTop down: height * 9)
        extentFromLeftTop: 0 @ (2 * height).
    "The width will later be set to the width of the reportFrameBody."
    aRect := aRect
        mapFromWindow: reportFrameBody
        to: aReportFrame partEditor workbenchPane.
    pageFooter := self pageFooter.
    self pastePart: pageFooter
        in: reportFrameBody
        rect: aRect
        name: 'PageFooter1'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'PageFooter' ).
    aRect := aRect
        moveBy: 10 @ 0;
        height: self lineHeight.
    reportTextPart := self class reportTextPart.
    reportTextPart
        setValue: 'Page Number';
        font: self class pageFooterFont.
    aRect width:
        (reportTextPart font stringWidth: reportTextPart value) + 10.
    self pastePart: reportTextPart
        in: pageFooter
        rect: aRect
        name: 'PageNumberLabel'
        helpInfo: ( Array
            with: 'PARTS.HLP'
            with: 'ReportTextPart' ).
    aRect := aRect moveBy: (reportTextPart width + 10) @ 0.
    reportTextPart := self class reportTextPart.
    reportTextPart
        setValue: 'Page #';
        function: 'Page Number';
        font: self class pageFooterFont.
    aRect width: 100.
    self pastePart: reportTextPart
        in: pageFooter
        rect: aRect
        name: 'PageNumber'
        helpInfo: ( Array
            with: self rwHelpFileName
            with: 'ReportTextPart' ).!
displayCaption: aPen
        "Private - Display the caption in the side ruler using aPen"
    | captionTop aRect captionExtent captionVerticalPosition |
    captionTop := self captionTop.
    aRect := (0 @ captionTop)
        extentFromLeftTop: aPen width @ self height.
    aPen
        fill: aRect color: self captionBackColor.
    captionExtent := aPen width @ aPen font height.
    captionVerticalPosition := self captionTop.
    self caption do: [:string |
        aRect := self
            partsIfOS2Do: [
                0 @ (captionVerticalPosition + aPen font height)
                    extentFromLeftTop: captionExtent x @ (captionExtent y + aPen font height )]
            partsIfWindowsDo: [
                0 @ captionVerticalPosition extentFromLeftTop: captionExtent ].
        aPen
            displayText: string
            in: aRect
            options:  ( self
                partsIfOS2Do: [ "DtRight | DtTextattrs" 512 | 64  ]
                partsIfWindowsDo: [ "DtRight | DtSingleline  | DtNoclip" 290 ] ).
        captionVerticalPosition := captionVerticalPosition down: captionExtent y.]! 
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.
    self reportOnFirstPageCheckbox ~= self part reportOnFirstPage
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #reportOnFirstPage:
                    arguments: (Array with: self reportOnFirstPageCheckbox value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #reportOnFirstPage:
                    arguments: (Array with: self part reportOnFirstPage) ) ].!   
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    self initializeTextPartValues.
    self contentsEntryField setValue: self part value.
    self functionListPane
        setList: part reportField functionNames;
        setValue: part function.!
reportFrameExtent: itemsToBeAdded
        "Private - Answer a first guess for the width, it will be resized later."
    | extent |
    extent := 0 @ (13 * self lineHeight).
    itemsToBeAdded do: [:item |
        extent := extent right: (self class itemWidth: item font: self class pageHeaderFont).
        extent := extent right: self spaceBetweenColumns].
    ^extent! 
initializeSizeWindowButton
        " Private - Don't have size window button, so do nothing. "!  
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject isPARTSColumnSummaryPart
        or: [anObject isPARTSReportTextPart
        or: [anObject isPARTSHardPageBreakPart
        or: [anObject isPARTSReportHorizontalPart]]]]!
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        curFont: ( curFont partMirrorCopy: aDict );
        reportField: (self reportField partMirrorCopy: aDict).
    ^copy!
frameParts
        "Private - Answer a collection of all the
        frame parts contained within."
    ^Array with: self! 
haveRunningReportCheckbox
    ^self partNamed: 'HaveRunningReportCheckbox'!  
widthFromUser: absoluteWidth
        "Private - Set the width based on the units
        the user used to set the width."
    self width: (self measurementFromUser: absoluteWidth asFloat).
    self resizeFromWidthAndPosition! 
partFrameRectangleFrom: aRectangle
    | partsFramer |

    partsFramer := PARTSFramer new.
    partsFramer
            scaleUnit: self basicUnit;
            left: 0
                stretched: false
                right: 0
                stretched: false;
            top: (partsFramer pixelToScaleUnitVertical: aRectangle top)
                stretched: false
                height: (partsFramer pixelToScaleUnitVertical: aRectangle height)
                stretched: false.
    ^partsFramer!   
<= aField
        "Private - Answer true if the receiver comes before
        aField in English text flow sense."
    ^(self frameRelativeRectangle top isAbove: aField frameRelativeRectangle top)
        or: [self frameRelativeRectangle top = aField frameRelativeRectangle top
            and: [self frameRelativeRectangle left isLeftEqualOf: aField frameRelativeRectangle left]]! 
firePageFooters: aBoolean
        "Private - if aBoolean is true, page footers will be generated on the
        current page before starting the new page. "
    firePageFooters := aBoolean!  
captureReportItems
        "Scan the children and create the reportLines."
    super captureReportItems.
    self capturePARTSPageBreakPart.
    ^reportLines!
rightMarginEntryField
    ^self partNamed: 'RightMarginEntryField'!  
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        isPageHeader: (isPageHeader partMirrorCopy: aDict);
        reportOnFirstPage: (reportOnFirstPage partMirrorCopy: aDict);
        trailingHeight: (trailingHeight partMirrorCopy: aDict).
    ^copy!
measurementFromUser: aNumber
        "Private - Answer an integer in 0.1 mm
        by converting aNumber which is measured in system
        settings measurement units."
    ^(aNumber asFloat *
        (self unit == self basicUnit
            ifTrue: [100]
            ifFalse: [254])) rounded.!   
adjustFraming: aRectangle
        "Private - Update the width and position."
    | partsFramer |
    super adjustFraming: aRectangle.
    partsFramer := self framingBlock.
    reportField
        location x: (partsFramer pixelToScaleUnitHorizontal: aRectangle left * 100) rounded.
    "The y location is set during #captureReportItems."
    reportField width: (partsFramer pixelToScaleUnitHorizontal: aRectangle width * 100) rounded! 
captionBackColor
        "Private - Answer the color used in the caption area as
        the shadow of the receiver."
    ^Color green!
initializeFontButton
        "Private - Do nothing.  A horizontal line does not have font."! 
heightEntryField
    ^self partNamed: 'HeightEntryField'!
resizeWithNewPARTSFramer
        "Private - resize the receiver after its framer has been changed."
    self
        resizeToRectangle: (self framingBlock
            scaleFrom: self superWindow rectangle)!
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: 'Field name: ';
        nextPutAll: self fieldName asString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Position: ';
        nextPutAll: self positionForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Width: ';
        nextPutAll: self widthForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.! 
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^false!  
initializeTextPartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "
    self widthEntryField setValue: part widthForUser.
    self decimalDigitsEntryField setValue: part decimalDigits.
    self wordwrapCheckbox setValue: part wordWrap.
    part superWindow isPARTSPageBreakPart
        ifTrue: [self wordwrapCheckbox disable]
        ifFalse: [self wordwrapCheckbox enable].
    self leftRadioButton setValue: part justification = #left.
    self centerRadioButton setValue: part justification = #center.
    self rightRadioButton setValue: part justification = #right.!   
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "
"    ^super havePropertiesChanged
        or: [self pageHeightEntryField modified]"
    ^true!
caption
        "Private - Answer a string which appears in the margins of the
        report frame identifiing what the part is."
    ^Array
        with: 'Page'
        with: (self isPageHeader
            ifTrue: ['Header']
            ifFalse: ['Footer'])!   
rightMarginFromUser: aNumber
        "Private - Accept the right margin aNumber specified by user
        in system settings measurement."
    rightMargin := self measurementFromUser: aNumber.
    self rightMarginPane framingBlock
        right: 0 stretched: false width: rightMargin / 100 stretched: false.
    self reportFrameBody framingBlock
        left: leftMargin / 100 stretched: false right: rightMargin /100 stretched: false.
    self rightMarginPane resizeWithNewPARTSFramer.
    self reportFrameBody resizeWithNewPARTSFramer.!   
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "
    super constructApplyActions.
    self constructTextApplyActions.
    self contentsEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #setValue:
                    arguments: (Array with: self contentsEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #setValue:
                    arguments: (Array with: self part value) ) ].
    self functionListPane value ~= self part function
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #function:
                    arguments: (Array with: self functionListPane value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #function:
                    arguments: (Array with: self part function) ) ].!  
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportColumnProperties new openOn: self.!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #isPageHeader: with: isPageHeader;
        addSelectorIfNotNil: #reportOnFirstPage: with: reportOnFirstPage;
        addSelectorIfNotNil: #trailingHeight: with: trailingHeight!   
partDirectEditValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self fieldName!  
partHint
        "Answer a string which gives a brief description
        of the receiver part. "
    ^ 'ReportText, Function: [' , reportField function asString , ']'!   
numberOfColumnsEntryField
    ^self partNamed: 'NumberOfColumnsEntryField'!  
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
        "Private - do nothing, children are added at open time."
    | application messageModel expressionModel | 
    application := self partApplication.
    messageModel := anExpressionModel addSelector: #addSubpane:.
    expressionModel := messageModel newExpressionArgument.
    expressionModel
        setReceiverToSelf;
        addSelector: ( application selectorForComponentBuild: self reportFrameBody )
            with: application !   
widthEntryField
    ^self partNamed: 'WidthEntryField'!  
listPaneName
        " Private "
    ^'fieldList'!  
removeButtonName
        " Private "
    ^'removeButton'!   
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [self numberOfColumnsEntryField value ~=
            self part numberOfColumns]!   
trailingHeight: aNumber
        "Private - The height of the blank space from the last item
        to the bottom of the frame."
    trailingHeight := aNumber!
wmErasebkgnd: wordInteger with: longInteger
        "Private - No part of the receiver shows, so there's
        nothing to do."
    ^1!   
spaceBetweenColumns
        "Private - Answer in screen pixels space between columns"
    ^20!  
display
        "Private - Display a black line of the receiver."
    self pen fill: Color black!   
clicked
        " Private - the button has been pressed "

    | aReportWriterGenerator |
    aReportWriterGenerator := PARTSReportWriterGenerator new.
    self createPartsWith: aReportWriterGenerator.
    aReportWriterGenerator createdParts
        ifTrue: [
            forms add: aReportWriterGenerator.
            self setModified: true ].!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #location: with: self location;
        addSelectorIfNotNil: #width: with: self reportField width!  
getPartsListFrom: itemNames
        " Private - Bring up a list dialog box and ask
        the user to choose which of the new parts the
        user wants to be created.  Answer the items."

    itemNames size = 0
        ifTrue: [  " button should have been disabled... "
            MessageBox warning: 'No items available for form creation.'.
            ^nil ].
    ^PARTSRWAssemblyDialog new
        openOn: itemNames
        title: title!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: 'Contents: ';
        nextPutAll: self valueAsString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Position: ';
        nextPutAll: self positionForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Width: ';
        nextPutAll: self widthForUser asString;
        nextPutAll: ' ' , self unit asString;
        cr.!
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    self numberOfColumnsEntryField setValue: self part numberOfColumns!   
partAddUnder: parentWindow wrapper: myWrapper
        "Private - Turn off the wrodWrap if adding into a pagebreak. "
    super partAddUnder: parentWindow wrapper: myWrapper.
    parentWindow isPARTSPageBreakPart
        ifTrue: [self wordWrap: false]!   
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'PPrwhorz.par'! 
initGraphics
        "Private - The receiver does not really need to do any
        displaying, so do not create a valid graphics tool."!   
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsPaneBorder |
        WsClipSiblings!  
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    self heightEntryField setValue: self part heightForUser.! 
initWindowSize
        " Answer the initial window extent of the client
        area in dialog box units. "
    ^clientExtentDlg!  
generateParts
        " Private - generate the parts selected by the user. "

    | dragResult destWindow destRect dialog
      columns columnNames breakFieldNames summaryFields summaryFieldNames |

    dialog := self getPartsListFrom: self getNames.
    columnNames := dialog columnNames.
    columnNames isNil
        ifTrue: [ ^nil ].
    summaryFieldNames := dialog summaryFields.
    breakFieldNames := dialog breakFields.

    self partEditor hideDialog: dialogWindow.
    ( dragResult :=
        (( PARTSDragSession
            source: self partEditor workbenchPane )
            icon: self mouseTrackIcon;
            yourself ) doDragDropAt: Cursor sense ) notNil
        ifTrue: [
            destWindow := dragResult destinationWindow.
            ( destWindow isWindow not
            or: [ destWindow partEditor ~~ self partEditor ] )
                ifTrue: [  " didn't land on a workbench "
                    self partEditor unhideDialog: dialogWindow.
                    ^nil ]].

    destRect := Rectangle
        leftTop: dragResult destinationRectangle leftTop
        rightBottom: destWindow rectangle rightBottom.

    CursorManager execute change.
    columns := self getItemsFor: columnNames.
    summaryFields := OrderedCollection new.
    columnNames do: [:columnName |
        (summaryFieldNames includes: columnName)
            ifTrue: [summaryFields add:
                (columns at: (columnNames indexOf: columnName))]].
    self
        pasteColumns: columns
        summaryFields: summaryFields
        breakFields: breakFieldNames
        in: destWindow
        destRect: destRect.
"   In the first release, do not automatically create links.
    There is not set protocol to link to/from.
    destWindow partEditor == self partEditor
        ifTrue: [ self createLinks: columns ]."
    CursorManager normal change.
    self partEditor unhideDialog: dialogWindow.! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #function: with: self function!  
fields
        "Scan the children and create the reportItems.
        Include report labels, page headers, report tables.
        Do not include report footers."
    ^self children
        asSortedCollection asOrderedCollection.!
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "
    ^true!   
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "
    ^true!   
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.
    self documentNameEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #setDocumentName:
                    arguments: (Array with: self documentNameEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #setDocumentName:
                    arguments: (Array with: self part documentName) ) ].
    self widthEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #reportWidthFromUser:
                    arguments: (Array with: self widthEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #reportWidthFromUser:
                    arguments: (Array with: self part reportWidthForUser) ) ].
    self leftMarginEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #leftMarginFromUser:
                    arguments: (Array with: self leftMarginEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #leftMarginFromUser:
                    arguments: (Array with: self part leftMarginForUser) ) ].
    self rightMarginEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #rightMarginFromUser:
                    arguments: (Array with: self rightMarginEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #rightMarginFromUser:
                    arguments: (Array with: self part rightMarginForUser) ) ].
    self topMarginEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #topMarginFromUser:
                    arguments: (Array with: self topMarginEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #topMarginFromUser:
                    arguments: (Array with: self part topMarginForUser) ) ].
    self bottomMarginEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #bottomMarginFromUser:
                    arguments: (Array with: self bottomMarginEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #bottomMarginFromUser:
                    arguments: (Array with: self part bottomMarginForUser) ) ].!   
width: anInteger
        "Private - Set the width of the field in 0.1 mm."
    reportField width: anInteger!
validate
        "Private - The PM window for the receiver was
         just created or recreated."
    self
        partsIfOS2Do: [
            self performWhenValids.
            self partReportInitColorsFont.
            self updateSliders.
            children size ~= 0 ifTrue: [
                children do: [:each |
                    each isApplicationWindow
                         ifTrue: [ each validateShow ]
                        ifFalse: [ each validate ] ] ] ]
        partsIfWindowsDo: [ super validate ].

    "need to support opening in a shrunken state."
    self partIsShrunk
        ifTrue: [self partShrink ]!  
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsPaneBorder |
        WsClipSiblings!  
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    super codeGenerationAddAttributeMessagesTo:  anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #pageHeight: with: self pageHeight;
        addSelectorIfNotNil: #pageWidth: with: self pageWidth
    "displayPane, and the scrollBars will be created later during initialize."!  
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [self documentNameEntryField modified
        or: [self widthEntryField modified
        or: [self leftMarginEntryField modified
        or: [self rightMarginEntryField modified
        or: [self topMarginEntryField modified
        or: [self bottomMarginEntryField modified ] ] ] ] ] ]!
partDefaultExtent
        " Private - Answer the default extent of the receiver
        in a PARTS application.  The width is going to be set to the
        width of the containing window."
    ^0 @ (PARTSReportTextPart new partDefaultExtent y +  4)!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #height: with: self height!  
widthForUser
        "Private - Answer the width in system settings units."
    ^self measurementForUser: reportField width!
partDirectEditValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self valueAsString!  
isDecimalDigitsPropertyValid
        " Private - answer whether  the decimaldigits property is valid."

    " cannot accept negative number of decimal digits."
    ^self decimalDigitsEntryField value >= 0
        ifTrue: [
            true]
        ifFalse: [
            self
                reportProblemIn: 'Decimal digits'
                message:
                    'Cannot accept negative value.'.
            false ]! 
recordFrameFieldsListPane
        " Private "
    ^'recordFrameFieldList'!  
updateSliders
        "Private - Update the slider boxes in the scrollbars."!
breakFields
    ^breakFields!
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsInitiallyVisible!  
updateSliders
        "Private - Update the slider boxes in the scrollbars."!
display
        "Private - If the receiver has more than one column, display
        the areas where should not contain a field in a different color."
    | aRectangle |
    super display.
    aRectangle := self rectangle.
    aRectangle := (aRectangle leftTop right: (1 / self numberOfColumns * aRectangle width) rounded)
        extentFromLeftTop: aRectangle extent.
    self pen fill: aRectangle color: Color gray! 
recordFrame
        "Private - Answer an instance of a PARTSRecordFramePart to be
        added to the reportFrame."
    ^(PARTSApplication fromFile: 'RECFRAME.PAR') solePart!
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSRecordFramePartProperties new openOn: self.! 
partDirectEditInitialValue
        "Answer the direct edit value of the receiver."
    ^self partName!  
frameParts
    | answer |
    answer := OrderedCollection new.
    answer add: self.
    self children do: [:child |
        child isPARTSReportStructure
            ifTrue: [answer addAll: child frameParts]].
    ^answer! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    self initializeTextPartValues.
    self fieldNameEntryField setValue: part fieldName.
    self doNotRepeatCheckbox setValue: part doNotRepeat.! 
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self valueAsString!   
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    breakFields isEmpty
        ifTrue: [
            aStream
                nextPutAll: aString;
                nextPutAll: 'The records will not be broken into groups.';
                cr.]
        ifFalse: [
            aStream
                nextPutAll: aString;
                nextPutAll: 'Break into groups when following fields change value:';
                cr;
                nextPutAll: aString.
            self breakFields keysAsArray do: [:fieldName |
                aStream
                    nextPutAll: '  ';
                    nextPutAll: fieldName
                ].
            aStream cr].

    aStream
        nextPutAll: aString;
        nextPutAll: (self haveRunningReport
            ifTrue: ['Has final report']
            ifFalse: ['Does not have final report']);
        cr.!
partFrameRectangleFrom: aRectangle
    | partsFramer |
 "   partsFramer := PARTSFramer new.
    ^partsFramer
            scaleUnit: self basicUnit;
            left: (partsFramer pixelToScaleUnitVertical: aRectangle left)
                stretched: false
                width: (partsFramer pixelToScaleUnitVertical: aRectangle width)
                stretched: false;
            top: (partsFramer pixelToScaleUnitVertical: aRectangle top)
                stretched: false
                height: (partsFramer pixelToScaleUnitVertical: aRectangle height)
                stretched: false;
        yourself
"

    partsFramer := super partFrameRectangleFrom: aRectangle.
    partsFramer scaleUnit: self basicUnit.
    ^partsFramer! 
ok
        " Private - the OK button has been pressed. "
    (list size > 0)
        ifTrue: [
            columnNames := (self paneAt: self recordFrameFieldsListPane) contents asArray.
            summaryFields := (self paneAt: self summaryFieldsListPane) selectedItems asArray.
            breakFields := (self paneAt: self breakFieldsListPane) selectedItems asArray.
                ].
    self close.! 
heightFromUser: absoluteHeight
        "Private - Set the height based on the units
        the user used to set the height."
    self reportField height: (self measurementFromUser: absoluteHeight asFloat).
    self resizeFromHeightAndPosition!  
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
        "Private - do nothing, children are added at open time." 
!  
defaultFieldName
    ^'Report Column'!   
adjustFraming: aRectangle
        "Private - Update the width and position."
    super adjustFraming: aRectangle.
    reportField height: (self framingBlock
        pixelToScaleUnitVertical: aRectangle height * 100) rounded!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #groupBreaks: with: groupBreaks;
        addSelectorIfNotNil: #numberOfColumns: with: numberOfColumns;
        addSelectorIfNotNil: #trailingHeight: with: trailingHeight
    "currentColumn, data and trailingHeight are used for runtime state."!   
pageFooter
        "Private - Answer an instance of a PARTSPageBreakPart to be
        added to the reportFrame."
    ^(PARTSApplication fromFile: 'REPPGFTR.PAR') solePart!   
measurementFromUser: aNumber
        "Private - Answer an integer in 0.1 mm
        by converting aNumber which is measured in system
        settings measurement units."
    ^(aNumber asFloat *
        (self unit == self basicUnit
            ifTrue: [100]
            ifFalse: [254])) rounded.!   
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'PPrwsmry.par'! 
caption
    ^Array with: 'Record' with: 'Frame'! 
partShrunkenIconFile
        " Private - answer the name of the part file containing
        the icon to display when the receiver is shrunk
        in a PARTS Workbench window. "
    ^'reprtfrm.par'!  
columnFont
        "Private - Answer the font used for the automatically generated tabled columns."
    ^ Font new
        faceName: (self partsIfOS2Do: ['Helv'] partsIfWindowsDo: ['MS Sans Serif']);
        pointSize: 8;
        fixedWidth: false;
        bold: false;
        italic: false;
        yourself.!   
arePropertiesValid
        " Private - answer whether  the values of the properties are valid.
        If not valid, notify the user of the problem and answer false.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #arePropertiesValid to super."

    ^super arePropertiesValid
        and: [self isDecimalDigitsPropertyValid]! 
pageFooterFont
        "Private - Answer the font used for the automatically generated page footer."
    ^ Font new
        faceName: (self partsIfOS2Do: ['Helv'] partsIfWindowsDo: ['MS Sans Serif']);
        pointSize: 8;
        fixedWidth: false;
        bold: false;
        italic: false;
        yourself.!  
createPartsWith: aFormGenerator
        " Private "

    aFormGenerator
        title: 'Choose the report fields';
        generatePartsFor: self part
            fromDialog: self dialogWindow.!  
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    self measurmentUnitStaticText setValue:
        (self part unit = #inch
            ifTrue: ['All measurements in inches']
            ifFalse: ['All measurements in centimeters']).
    self pageHeightEntryField
        value: self part pageHeightForUser.! 
pageFooters: anOrderedCollection
    pageFooters := anOrderedCollection.!
heightForUser
        "Private - Answer the height in system settings units."
    ^self measurementForUser: reportField height! 
breakFieldsFromNames: names
        "Private - Set breakFields to a dictionary.  Key is the name of the
        field to break on, and value is used at run time to keep
        track of the previous value."
    breakFields := Dictionary new.
    names do: [:fieldName |
        breakFields at: fieldName put: nil].! 
captureReportItems
        "Private - Scan the children and create the reportItems."
    
    self captureGroupBreaks.
    super captureReportItems.! 
computeExtent

    ^100 @ self height!  
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'Pprwpgbk.par'! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "
    ^true!   
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportFrameProperties new openOn: self.! 
updateSliders
        "Private - Update the slider boxes in the scrollbars."!
measurementForUser: aNumber
        "Private - Convert the aNumber from system settings
        measurement units to 0.1 mm."
    ^(aNumber *
        (self unit ==  self basicUnit
            ifTrue: [0.01]
            ifFalse: [0.00393700787]))  printRounded: 2! 
hasIconProperty
        " Private - answer whether my part has
        an icon property. "

    ^false!   
addReportFrame: itemsToBeAdded in: aWindow destRect: destRect
        "Private - Add a report frame to the application."
    | aRect reportFrame |
    aRect := destRect leftTop
        extentFromLeftTop: (self reportFrameExtent: itemsToBeAdded).
    reportFrame := self reportFrame.
    self pastePart: reportFrame
        in: aWindow
        rect: aRect
        name: 'ReportFrame1'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'ReportFrame' ).
    ^reportFrame! 
rwHelpFileName
        ^'PARTSRW.HLP'!   
initGraphics! 
addPageHeader: itemsToBeAdded in: aReportFrame
    | aRect reportFrameBody pageHeader reportTextPart location height
    reportFrameWidth |
    reportFrameBody := aReportFrame reportFrameBody.
    height := self lineHeight.
    aRect := (reportFrameBody rectangle leftTop down: (2 * height))
        extentFromLeftTop: 0 @ (2 * height).
    "The width will later be set to the width of the reportFrameBody."
    aRect := aRect
        mapFromWindow: reportFrameBody
        to: aReportFrame partEditor workbenchPane.
    pageHeader := self pageHeader.
    self pastePart: pageHeader
        in: reportFrameBody
        rect: aRect
        name: 'PageHeader'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'PageHeader' ).
    aRect := aRect leftTop
        extentFromLeftTop: 0 @ height.
    location := 0 @ 0.
    itemsToBeAdded do: [:formItem |
        reportTextPart := self class reportTextPart.
        reportTextPart font: self class pageHeaderFont.
        reportTextPart setValue: formItem labelItem visualPart label.
        aRect width: (self class itemWidth: formItem font: reportTextPart font).
        "Save the aRect, so the columns could be placed under the column header"
        formItem partItem visualPart rectangleAttribute: aRect copy.
        self pastePart: reportTextPart
            in: pageHeader
            rect: aRect
            name: (reportTextPart value , 'ColumnHeader')
            helpInfo: ( Array
                with: 'PARTS.HLP'
                with: 'ReportTextPart' ).
        aRect := aRect moveBy: (reportTextPart rectangle width + self spaceBetweenColumns) @ 0].
    reportFrameWidth := reportTextPart reportField location x +
        reportTextPart reportField width +
        aReportFrame leftMargin + aReportFrame rightMargin.
    aReportFrame reportWidth: reportFrameWidth; validateReportWidth.!
reportWidthForUser
        "Private - Answer the report width in system
        settings measurement units."
    ^self measurementForUser: self reportWidth!   
resizeFromWidthAndPosition
        "Private - Update the width and position."
    self framingBlock
        left: reportField location x / 100 stretched: false width: reportField width / 100 stretched: false.
    self
        resizeToRectangle: (self framingBlock
            scaleFrom: self superWindow rectangle)! 
reportFrame
        "Private - Answer an instance of a PARTSReportFramePart to be
        added to the workbench."
    ^(PARTSApplication fromFile: 'REPRTFRM.PAR') solePart!  
partDirectEditInitialValue
        "Answer the direct edit value of the receiver."
    ^self partName!  
open
        "Private - create the children."
    super open. 
    self createChildren !   
decimalDigits: aNumber
        "Private - Set the number of digits to the right
        of the decimal separator."
    reportField decimalDigits: aNumber! 
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. "
    self setValue: text.
    self invalidateRect: nil!  
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "
    ^true!   
positionForUser
        "Private - Answer the position in system settings units."
    ^self measurementForUser: reportField location x
        + self reportFrameParent leftMargin!
arePropertiesValid
        " Private - answer whether  the values of the properties are valid.
        If not valid, notify the user of the problem and answer false.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #arePropertiesValid to super."

    ^super arePropertiesValid
        and: [self isDecimalDigitsPropertyValid]! 
caption
    ^Array new!  
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        setDocumentName: (documentName partMirrorCopy: aDict);
        pageHeaders: (pageHeaders partMirrorCopy: aDict);
        pageFooters: (pageFooters partMirrorCopy: aDict).
    ^copy!   
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message."
    | backColor aColor oldDC |
    self partsVwOnly.
    (backColor := self backColor) notNil
        ifTrue: [aColor := backColor]
        ifFalse: [aColor := PARTSHostInterface colorBackground].
    oldDC := graphicsTool privateHandle.
    graphicsTool handle: wordInteger.
    graphicsTool
        "setMapMode;"
        fill: self "reportRectangle" rectangle color: aColor.
    graphicsTool handle: oldDC.
    ^1!   
hasIconProperty
        " Private - answer whether my part has
        an icon property. "

    ^false!   
initialize
        "Private - ."
    super initialize.
    self initPARTSReportField.! 
widthEntryField
    ^self partNamed: 'WidthEntryField'!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #location: with: location.
    "The reportLines is set during #partEnableExecution based on information available
    elsewhere."! 
centerRadioButton
    ^self partNamed: 'CenterRadioButton'!  
leftRadioButton
    ^self partNamed: 'LeftRadioButton'!  
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "
    
    super constructApplyActions.
    self heightEntryField value asString ~= self part heightForUser asString
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #heightFromUser:
                    arguments: (Array with: self heightEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #height:
                    arguments: (Array with: self part reportField height) ) ].!  
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "
    super initializePartValues.
    self documentNameEntryField setValue: part documentName.
    self measurmentUnitStaticText setValue:
        (self part unit = #inch
            ifTrue: ['All measurements in inches']
            ifFalse: ['All measurements in centimeters']).
    self widthEntryField setValue: part reportWidthForUser.
    self leftMarginEntryField setValue: part leftMarginForUser.
    self rightMarginEntryField setValue: part rightMarginForUser.
    self topMarginEntryField setValue: part topMarginForUser.
    self bottomMarginEntryField setValue: part bottomMarginForUser.!
caption
    ^Array with: 'Group' with: 'Frame'!  
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject isPARTSReportTextPart
        or: [anObject isPARTSRecordFramePart
        or: [anObject isPARTSPageBreakPart
        or: [anObject isPARTSHardPageBreakPart
        or: [anObject isPARTSReportHorizontalPart]]]]]! 
partDefaultExtent
        " Private - Answer the default extent of the receiver
        in a PARTS application.  The width is going to be set to the
        width of the containing window."
    ^0  @ (PARTSHostInterface defaultPartFont height * 2 )! 
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'PPrwtxt.par'!  
rightMarginForUser
        "Private - Answer the right margin in system
        settings measurement units."
    ^self measurementForUser: rightMargin!
graphicsToolClass
        "Private - Use PARTSRecordingPen, do not use the
        recording ability, but use the additonal protocol."
    ^PARTSRecordingPen! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "
    ^true!   
measurmentUnitStaticText
    ^self partNamed: 'MeasurmentUnitStaticText'!
captionTop
    ^(self frameRelativeRectangle leftTop 
		mapFromWindow: self superWindow 
		to: self reportFrameBody) y!
initializeFontButton
        "Private - Do nothing.  There is no single font
        associated with the report pane."! 
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject isPARTSReportTextPart
        or: [anObject isPARTSReportHorizontalPart]]!  
adjustFraming: aRectangle

    super adjustFraming: aRectangle.
    reportWidth := self framingBlock pixelToScaleUnitHorizontal: aRectangle width * 100.
"    ^partsFramer
            left: (partsFramer pixelToScaleUnitHorizontal: aRectangle left)
                stretched: false
                width: (partsFramer pixelToScaleUnitHorizontal: aRectangle width)
                stretched: false;
            top: (partsFramer pixelToScaleUnitVertical: aRectangle top)
                stretched: false
                height: (partsFramer pixelToScaleUnitVertical: aRectangle height)
                stretched: false.
"!  
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self fieldName!   
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSPageBreakPartProperties new openOn: self.!   
stringToDisplayInWorkbench
        "Private - Answer a String which is displayed in the workbench.
        Bracket the field name so it is clear that the string is not a literal content."
    ^'<' , self partDirectEditInitialValue , '>'!  
captionBackColor
        "Private - Answer the color used in the caption area as
        the shadow of the receiver."
    ^Color black!
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.
    self numberOfColumnsEntryField value ~= self part numberOfColumns
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #numberOfColumns:
                    arguments: (Array with: self numberOfColumnsEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #numberOfColumns:
                    arguments: (Array with: self part numberOfColumns) ) ].! 
partCanHaveChild: anObject
        "Private - Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject isPARTSGroupFramePart
        or: [anObject isPARTSReportColumnPart
        or: [anObject isPARTSReportTextPart
        or: [anObject isPARTSHardPageBreakPart
        or: [anObject isPARTSReportHorizontalPart]]]]]! 
summaryFields
    ^summaryFields!
partCanHaveParent: aParent
        "Private - answer a boolean if aParent is acceptable."
    ^aParent isPARTSReportStructure!  
hasIconProperty
        " Private - answer whether my part has
        an icon property. "

    ^false!   
frameParts
        "Private - Answer a collection of all the
        frame parts contained within."
    ^Array with: self! 
validateReportWidth
        "Private - Fix the framing block to match the reportWidth."
    | partsFramer |
    partsFramer := self framingBlock.
    partsFramer
        left: (partsFramer pixelToScaleUnitHorizontal:
            self frameRelativeRectangle left)
        stretched: false
        width: reportWidth / 100
        stretched: false.
    self resizeWithNewPARTSFramer!   
stringToDisplayInWorkbench
        "Private - Answer a String which is displayed in the workbench."
    ^self partDirectEditInitialValue!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
"     Do not surface these properties in 3.0, because they seem to be
        of limited value.  If we are going to support them, then uncomment
        the following:
    anExpressionModel
        addSelectorIfNotNil: #firePageFooters: with: firePageFooters;
        addSelectorIfNotNil: #firePageHeaders: with: firePageHeaders "! 
partDirectEditValue
        "Answer the direct edit value of the receiver."
    ^self partName! 
partHint
        "Answer a string which gives a brief description
        of the receiver part. "
    ^'ReportColumn'! 
partCanHaveParent: aParent
        "Private - answer a boolean if aParent is acceptable."
    ^aParent isPARTSReportFrameBody!  
contentsEntryField
    ^self partNamed: 'ContentsEntryField'!
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportTextProperties new openOn: self.!  
partFrameRectangleFrom: aRectangle
    ^(super partFrameRectangleFrom: aRectangle)
        scaleUnit: self basicUnit;
        yourself!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver." 
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #bottomMargin: with: bottomMargin;
        addSelectorIfNotNil: #leftMargin: with: leftMargin;
        addSelectorIfNotNil: #reportWidth: with: reportWidth;
        addSelectorIfNotNil: #rightMargin: with: rightMargin;
        addSelectorIfNotNil: #topMargin: with: topMargin;
        addSelectorIfNotNil: #setDocumentName: with: self documentName;
        addSelectorIfNotNil: #pageFooters: with: self reportFrameBody pageFooters;
        addSelectorIfNotNil: #pageHeaders: with: self reportFrameBody pageHeaders  ";
        addSelectorIfNotNil: #reportLines: with: self reportFrameBody reportLines " ! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "
    super initializePartValues.
    self measurmentUnitStaticText setValue:
        (self part unit = #inch
            ifTrue: ['All measurements in inches']
            ifFalse: ['All measurements in centimeters']).
    self part superWindow isPARTSReportStructure
        ifTrue: [
            self positionEntryField
                enable;
                setValue: self part positionForUser]
        ifFalse: [
            self positionEntryField disable].
    self widthEntryField setValue: part widthForUser.!
leftMarginEntryField
    ^self partNamed: 'LeftMarginEntryField'!
partCanHaveChild: anObject
        "Always answer false, all children must go into reportFrameBody."
    ^false!
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportPanePropertiesEditor new openOn: self.!
partCanHaveParent: aParent
        "Private - answer a boolean if aParent is acceptable."
    ^aParent isPARTSReportFrameBody!  
positionEntryField
    ^self partNamed: 'PositionEntryField'!
createView: title
        " Private - compute child control layout and create stuff.
        Window sizing is done in dialog box units. "
    | charWidthDlg marginDlg string
      topPane deltaLeftTop deltaTopLeft2 deltaLeftMarginX
      internalWidthDlg anExtent anExtent2 aListPane |

    charWidthDlg := WindowDialog charWidth.
    "lineHeightDlg := WindowDialog charHeight."
    marginDlg := charWidthDlg.

    self addView:
        (topPane := self topPaneClass new
            owner: self;
            labelWithoutPrefix: title
            "style: self defaultFrameStyle" ).
    deltaLeftMarginX := marginDlg.
    deltaLeftTop := deltaLeftMarginX @ marginDlg.
    internalWidthDlg := self titleBarWidth: title.

    " instructions "
    #(
        'Choose and order record frame fields.'
        'Order by draging items.'
        ) do: [ :aString |
        anExtent := self extentForLabel: aString.
        topPane addSubpane:
            (StaticText new
                font: self font;
                contents: aString;
                framingBlock:
                    (self framingBlock: deltaLeftTop
                        extent: anExtent)).
        internalWidthDlg := internalWidthDlg max: anExtent x.
        deltaLeftTop :=
            deltaLeftMarginX
            @ (deltaLeftTop y + anExtent y)
        ].
    deltaLeftTop :=   " vertical white space below text lines "
        deltaLeftMarginX
        @ (deltaLeftTop y + marginDlg).

    " list of field names "
    aListPane := ExtendedListBox new.
    anExtent := self
        extentForList: list
        in: aListPane
        title: ''
        maxEntriesToShow: 10.
    topPane addSubpane:
        (aListPane
            setName: self recordFrameFieldsListPane;
            contents: list;
            font: self font;
            userCanReorder: true;
            dragButton: PARTSSettings current mouseButtonDrag;
            selectIndex: 1;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: anExtent)).
    deltaTopLeft2 :=
        ( deltaLeftTop x right: (marginDlg + anExtent x) )
        @ deltaLeftTop y.
    deltaLeftTop :=
            deltaLeftMarginX
            @ (deltaLeftTop y + anExtent y).

    " Remove Record field button "
    string := 'Exclude field'.
    anExtent2 := self extentForButton: string.
    topPane addSubpane:
        (Button new
            setName: self removeButtonName;
            font: self font;
            contents: string;
            when: #clicked send: #removeField to: self;
            framingBlock:
                (self framingBlock: deltaTopLeft2 extent: anExtent2)).
    deltaLeftTop :=
            deltaLeftMarginX
            @ (deltaLeftTop y + anExtent2 y).
    internalWidthDlg := internalWidthDlg max:
        (anExtent x + marginDlg + anExtent2 x).

    " instructions "
    #(
        'Select the summary fields:'
    ) do: [ :aString |
        anExtent := self extentForLabel: aString.
        topPane addSubpane:
            (StaticText new
                font: self font;
                contents: aString;
                framingBlock:
                    (self framingBlock: deltaLeftTop
                        extent: anExtent)).
        internalWidthDlg := internalWidthDlg max: anExtent x.
        deltaLeftTop :=
            deltaLeftMarginX
            @ (deltaLeftTop y + anExtent y)
        ].
    deltaLeftTop :=   " vertical white space below text lines "
        deltaLeftMarginX
        @ (deltaLeftTop y + marginDlg).

    " summary field names "
    aListPane := MultipleSelectListBox new.
    anExtent := self
        extentForList: list
        in: aListPane
        title: ''
        maxEntriesToShow: 10.
    topPane addSubpane:
        (aListPane
            setName: self summaryFieldsListPane;
            contents: list;
            font: self font;
            selectIndex: 1;
            framingBlock:
                (self framingBlock: deltaLeftTop  extent: anExtent)).


    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + (anExtent y max: anExtent2 y)
                + marginDlg).

   " instructions "
    #(
        'Select fields to break when field changes value: '
    ) do: [ :aString |
        anExtent := self extentForLabel: aString.
        topPane addSubpane:
            (StaticText new
                font: self font;
                contents: aString;
                framingBlock:
                    (self framingBlock: deltaLeftTop
                        extent: anExtent)).
        internalWidthDlg := internalWidthDlg max: anExtent x.
        deltaLeftTop :=
            deltaLeftMarginX
            @ (deltaLeftTop y + anExtent y)
        ].
    deltaLeftTop :=   " vertical white space below text lines "
        deltaLeftMarginX
        @ (deltaLeftTop y + marginDlg).

    " GroupField names field names "
    aListPane := MultipleSelectListBox new.
    anExtent := self
        extentForList: list
        in: aListPane
        title: ''
        maxEntriesToShow: 10.
    topPane addSubpane:
        (aListPane
            setName: self breakFieldsListPane;
            contents: list;
            font: self font;
            selectIndex: 1;
            framingBlock:
                (self framingBlock: deltaLeftTop  extent: anExtent)).

    deltaLeftTop :=
        deltaLeftMarginX
        @ (deltaLeftTop y + (anExtent y max: anExtent2 y)
                + marginDlg).

    " OK and Cancel buttons "
    anExtent := self
        createOkCancelButtons: topPane
        deltaLeftTop: deltaLeftTop.
    internalWidthDlg := internalWidthDlg max: anExtent x.

    clientExtentDlg :=
        (internalWidthDlg + (2 * marginDlg))
        @ (deltaLeftTop y + anExtent y + marginDlg).
    ^topPane!  
summaryFieldsListPane
        " Private "
    ^'summaryFieldsList'! 
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        topMargin: (topMargin partMirrorCopy: aDict);
        bottomMargin: (bottomMargin partMirrorCopy: aDict);
        leftMargin: (leftMargin partMirrorCopy: aDict);
        rightMargin: (leftMargin partMirrorCopy: aDict);
        reportWidth: (self reportWidth partMirrorCopy: aDict).
    aDict forExecute "remove the rulers"
        ifTrue: [copy removeRulers].
    ^copy!  
partCanHaveParent: aParent
        "Private - answer a boolean if aParent is acceptable."
    ^aParent isPARTSRecordFramePart!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #breakFields: with: breakFields;
        addSelectorIfNotNil: #haveRunningReport: with: haveRunningReport;
        addSelectorIfNotNil: #trailingHeight: with: trailingHeight
        "firstTime and writeReport are used for runtime state."!
openOn: fieldNames title: title
        " Open a dialog which allows the user to
        specify the order of a set of fields. "
    list := fieldNames.
    self
        createView: title;
        openWindow.
    ^self!
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "
    super constructApplyActions.
    self constructTextApplyActions.
    self fieldNameEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #fieldName:
                    arguments: (Array with: self fieldNameEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #fieldName:
                    arguments: (Array with: self part fieldName) ) ].
    self functionListPane value ~= self part function
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #function:
                    arguments: (Array with: self functionListPane value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #function:
                    arguments: (Array with: self part function) ) ].!  
captionTop
    ^(self frameRelativeRectangle leftTop 
		mapFromWindow: self superWindow 
		to: self reportFrameBody) y!
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        pageHeight: ( pageHeight partMirrorCopy: aDict );
        pageWidth: ( pageWidth partMirrorCopy: aDict ).
    ^copy! 
topMarginForUser
        "Private - Answer the top margin in system
        settings measurement units."
    ^self measurementForUser: topMargin!  
addGroupFrame: summaryFields breakFields: breakFields in: aRecordFrame
    | aRect groupFrame columnSummaryPart height |
    height := self lineHeight.
    aRect := (aRecordFrame rectangle leftTop down: (2 * height))
        extentFromLeftTop: 0 @ (2 * height).
    "The width will later be set to the width of the reportFrameBody."
    aRect := aRect
        mapFromWindow: aRecordFrame
        to: aRecordFrame partEditor workbenchPane.
    groupFrame := self groupFrame.
    groupFrame breakFieldsFromNames: breakFields.
    self pastePart: groupFrame
        in: aRecordFrame
        rect: aRect
        name: 'groupFrame'
        helpInfo: ( Array
                with: self rwHelpFileName
                with: 'GroupFrame' ).
    aRect := aRect leftTop
        extentFromLeftTop: 0 @ height.
    summaryFields do: [:formItem |
        columnSummaryPart := self class columnSummaryPart: formItem.
        "Align it under the corresponding report column part."
        aRect leftTop x: formItem partItem visualPart rectangleAttribute left.
        aRect width: columnSummaryPart rectangle width.
        self pastePart: columnSummaryPart
            in: groupFrame
            rect: aRect
            name: (columnSummaryPart fieldName , 'Column')
            helpInfo: ( Array
            with: 'PARTS.HLP'
            with: 'columnSummaryPart' )]! 
reportHeaderFont
        "Private - Answer the font used for the automatically generated report header."
    ^ Font new
        faceName: (self partsIfOS2Do: ['Helv'] partsIfWindowsDo: ['MS Sans Serif']);
        pointSize: 10;
        fixedWidth: false;
        bold: true;
        italic: false;
        yourself.!  
captureGroupBreaks
        "Private -Scan the children and set groupBreaks."
    groupBreaks := (self children select: [:child | child isPARTSGroupFramePart ])
        asSortedCollection asOrderedCollection.
    ^groupBreaks! 
partDefaultExtent
    ^(Display horizontalPixelsPerInch * 0.39 * reportWidth ) rounded
        @ (Display horizontalPixelsPerInch * 0.39 * 4 ) rounded! 
topMarginEntryField
    ^self partNamed: 'TopMarginEntryField'!  
pasteColumns: columns summaryFields: summaryFields breakFields: breakFields in: aWindow destRect: destRect
        " Private - Create all the components of a report writer
        assembly based on the PARTSFormGeneratorItems in
        itemsToBeAdded. "
    | aReportFrame |
    aReportFrame := self
        addReportFrame: columns
        in: aWindow
        destRect: destRect.
    self
        addPageHeader: columns in: aReportFrame;
        addRecordFrame: columns summaryFields: summaryFields breakFields: breakFields in: aReportFrame;
        addPageFooterIn: aReportFrame;
        "add report header here so aReportFrame has right width so the
        report header/footer can be centered."
        addReportHeader: aReportFrame;
        addReportFooter: aReportFrame.!
partSetGraphics: anIcon
        "Private - The icon for the report frame parent is used only
        when the part is shrunken."
    | oldIcon |
    oldIcon := self partShrunkenIcon.
    parent := oldIcon parent.
    anIcon
        parent: oldIcon parent;
        origin: oldIcon origin copy;
        connection: oldIcon connection;
        showLabel: oldIcon showLabel;
        name: oldIcon name.
    anIcon parent notNil ifTrue: [
        anIcon parent
            removeIcon: oldIcon;
            addIcon: anIcon].
    oldIcon release.
    self partShrunkenIcon: anIcon.!  
initialize
        "Private - Set margin sizes and create the framebody plust the margin panes."
    leftMargin := 100.
    rightMargin := 100.
    topMargin := 254.
    bottomMargin := 254.
    reportWidth := 6.
    super initialize.
    "self createChildren."   ! 
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'Pprwgrup.par'! 
partsShrunkenIcon
        "Private - Answer the icon used for a shrunken
        window."
    | icon |
    icon := self partIcon.
    "Must set the icon, o.w. wrapper will not give
    back the same icon again:"
    self partIcon: icon.
    icon connection: self;
        showLabel: true.
    icon name: self partName.
    ^icon!  
rightRadioButton
    ^self partNamed: 'RightRadioButton'!
trailingHeight: aNumber
    trailingHeight := aNumber!   
measurementForUser: aNumber
        "Private - Convert the aNumber from system settings
        measurement units to 0.1 mm."
    ^(aNumber *
        (self unit ==  self basicUnit
            ifTrue: [0.01]
            ifFalse: [0.00393700787]))  printRounded: 2! 
adjustFraming: rectangleInParent
        "Private - Do nothing, overwrite the inherited behavior."!  
captionBackColor
        "Private - Answer the color used in the caption area as
        the shadow of the receiver."
    ^Color white!
<= aField
        "Private - Answer true if the receiver comes before
        aField in English text flow sense."
    ^self frameRelativeRectangle top isAbove: aField frameRelativeRectangle top! 
scrollHorizontal: anInt
        "Private - Reimplemented here because GroupPanes do
         not scroll."!  
arePropertiesValid
        " Private - answer whether  the values of the properties are valid.
        If not valid, notify the user of the problem and answer false.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #arePropertiesValid to super."

    ^super arePropertiesValid
        and: [self isNumberOfColumnsPropertyValid]!   
isNumberOfColumnsPropertyValid
        " Private - answer whether  the number of columns property is valid."

    " cannot accept negative number of columns."
    ^self numberOfColumnsEntryField value > 0
        ifTrue: [
            true]
        ifFalse: [
            self
                reportProblemIn: 'Number of columns.'
                message:
                    'Must have at least one column'.
            false ]! 
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part.  If no extension is given, open
        editable .par file; if not found, open non-editable
        .exe part. "

    ^'Pprwfram.par'! 
partDefaultExtent
        " Private - Answer the default extent of the receiver
        in a PARTS application.  The width is going to be set to the
        width of the containing window."
    ^0  @ PARTSHostInterface defaultPartFont height * 4!
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. "
    self partName: text! 
getGraphicsTool
        "Private - The receiver does not really need to do any
        displaying, so do not create a valid graphics tool."
    ^Pen new!  
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [self reportOnFirstPageCheckbox value ~= self part reportOnFirstPage]!  
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    | child |
    "remove any rulers in children; they are created at open time."
    anObjectFiler objectVersion < 12
        ifTrue: [
            self children do: [: each |
                each isPARTSReportFrameBody
                    ifTrue: [ child := each ]
                    ifFalse: [ children removeKey: each id ] ]. "remove rulers"
             child notNil ifTrue: [ self reportFrameBody: child ] ].
    super fileInUpgrade: anObjectFiler! 
constructTextApplyActions
        " Private - construct sequence of apply
        actions which are common to textual report fields,
        vs. graphical fields. "
    | justification |
    self decimalDigitsEntryField modified
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #decimalDigits:
                    arguments: (Array with: self decimalDigitsEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #decimalDigits:
                    arguments: (Array with: self part decimalDigits) ) ].
    self wordwrapCheckbox ~= self part wordWrap
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #wordWrap:
                    arguments: (Array with: self wordwrapCheckbox value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #wordWrap:
                    arguments: (Array with: self part wordWrap) ) ].
    justification := (self leftRadioButton value
        ifTrue: [#left]
            ifFalse: [self centerRadioButton value
                ifTrue: [#center]
                ifFalse: [#right]]).
    justification ~= self part justification
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #justification:
                    arguments: (Array with: justification ) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #justification:
                    arguments: (Array with: self part justification) ) ].!  
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportHorizontalProperties new openOn: self.!
displayCaption: aPen
        "Private - Do nothing."!
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
   PARTSReportSummaryProperties new openOn: self.!   
decimalDigitsEntryField
    ^self partNamed: 'DecimalDigitsEntryField'!  
mouseTrackIcon
        " Answer the icon to display while tracking the mouse
        to the form item drop point in a PARTS workbench. "

    mouseTrackIcon isNil
        ifTrue: [
            mouseTrackIcon := PARTSFile iconFromFile: 'reprtfrm.par'
                ifNone: [ PARTSApplication defaultIcon ].
            ].
    ^mouseTrackIcon!  
measurmentUnitStaticText
    ^self partNamed: 'MeasurmentUnitStaticText'!
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        haveRunningReport: (haveRunningReport partMirrorCopy: aDict);
        breakFields: (self breakFields partMirrorCopy: aDict);
        trailingHeight: (trailingHeight partMirrorCopy: aDict).
    ^copy! 
pageHeightFromUser: aNumber
        "Private - set the page height which is in the system settings
        measurement units (eg. centimeters, inches)."
    self pageHeight: (self measurementFromUser: aNumber).
    self displayPane pageHeight: self pageHeight.! 
breakFieldMultipleChoiceList
    ^self partNamed: 'BreakFieldMultipleChoiceList'!
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.
   " self pageHeightEntryField modified" true
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #pageHeightFromUser:
                    arguments: (Array with: self pageHeightEntryField value) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #pageHeightFromUser:
                    arguments: (Array with: self part pageHeightForUser) ) ].!  
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."
    ^false!  
reportEverytime
        "Private - Answer if the part is to report every time it geographically is
        encountered (vs. conditional reporting at special times and places)"
    ^true! 
documentNameEntryField
    ^self partNamed: 'DocumentNameEntryField'!
bottomMarginEntryField
    ^self partNamed: 'BottomMarginEntryField'!
scrollVertical: anInt
        "Private - Reimplemented here because GroupPanes do
         not scroll."!
leftMarginForUser
        "Private - Answer the left margin in system
        settings measurement units."
    ^self measurementForUser: leftMargin!   
partIsShrinkable
        "Private - Can this part shrink in a PARTS Workbench."
    ^true!  
reportFooterFont
        "Private - Answer the font used for the automatically generated report footer."
    ^ Font new
        faceName: (self partsIfOS2Do: ['Helv'] partsIfWindowsDo: ['MS Sans Serif']);
        pointSize: 8;
        fixedWidth: false;
        bold: false;
        italic: false;
        yourself.!  
pageHeightForUser
        "Private - set the page height which is in the system settings
        measurement units (eg. centimeters, inches)."
    ^self measurementForUser: self pageHeight!  
capturePARTSPageBreakPart
        "Scan the children and create the reportLines."
    | pageBreaks |
    pageHeaders := OrderedCollection new.
    pageFooters := OrderedCollection new.
    pageBreaks := self pageBreaks.
    pageBreaks isEmpty ifTrue: [^nil].
    pageBreaks reversed do: [:pageBreak |
        pageBreak isPageHeader
            ifTrue: [
                "Page headers get added to the pageHeaders after the first time
                they are reported.  That allows the report headers to span many
                pages before the first page header appears.  "
                pageHeaders add: pageBreak.
                "pageBreak location y: ((self verticalPixelsToCentimeters:
                    pageBreak verticalPosition) + self topMargin)"]
            ifFalse: [
                pageFooters add: pageBreak.
                pageBreak location y: ((self verticalPixelsToLowMetric:
                    pageBreak verticalPosition) + self bottomMargin)]].!
captionTop
    ^self frameRelativeRectangle top! 
height: anInteger
        "Private - Set the height in 0.1mm"
    self reportField height: anInteger.
    self resizeFromHeightAndPosition!
positionFromUser: absolutePositon
        "Private - Set the position based on the units
        the user used."
    reportField location x: (self measurementFromUser: absolutePositon asFloat)
        - self reportFrameParent leftMargin.
    self resizeFromWidthAndPosition!   
leftMarginFromUser: aNumber
        "Private - Accept the left margin aNumber specified by user
        in system settings measurement."
    leftMargin := self measurementFromUser: aNumber.
    self leftMarginPane framingBlock
        left: 0 stretched: false width: leftMargin / 100 stretched: false.
    self reportFrameBody framingBlock
        left: leftMargin / 100 stretched: false right: rightMargin / 100 stretched: false.
    self leftMarginPane resizeWithNewPARTSFramer.
    self reportFrameBody resizeWithNewPARTSFramer.! 
reportField: aPARTSReportField
        "PARTSReportField is the object which at the runtime
        generates the report."
    reportField := aPARTSReportField!   
bottomMarginFromUser: aNumber
        "Private - Accept the bottom margin aNumber specified by user
        in system settings measurement."
    bottomMargin := self measurementFromUser: aNumber.
    self resizeToRectangle: self frameRelativeRectangle.
    self invalidateRect:  nil!  
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    | aFont |
    aFont := self partFontOrSysFont.
    ^aFont width * 15 @ (aFont height + 2)!   
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^true!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #setValue: with: self value;
        addSelectorIfNotNil: #justification: with: self justification;
        addSelectorIfNotNil: #wordWrap: with: self wordWrap;
        addSelectorIfNotNil: #function: with: self function! 
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. "
    self partName: text! 
partDirectEditValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self value!  
columnNames
    ^columnNames!
measurementFromUser: aNumber
        "Private - Answer an integer in 0.1 mm
        by converting aNumber which is measured in system
        settings measurement units."
    ^(aNumber asFloat *
        (self unit == self basicUnit
            ifTrue: [100]
            ifFalse: [254])) rounded.!