3.1.0.106
   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | selectedPage selectedIndex |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #majorTabExtent: with: self majorTabExtent;
        addSelectorIfNotNil: #minorTabExtent: with: self minorTabExtent;
        addSelectorIfNotNil: #pageButtonExtent: with: self pageButtonExtent.
    selectedPage := self selectedPage.
    selectedPage notNil
        ifTrue: [
            selectedIndex := self pages indexOf: selectedPage ifAbsent: [ nil ]].
    anExpressionModel
        addSelectorIfNotNil: #turnToPageNumber: with: selectedIndex!  
partAddStylesExpressionsTo: aCodeGeneratorExpression
    super partAddStylesExpressionsTo: aCodeGeneratorExpression.
    ( self partSearch: PARTSNotebookConstants forStylePrefix: 'Nbks' ) do: [ :name |
        aCodeGeneratorExpression
            addSelector: #addStyle:
            arguments: ( Array with:
                ( PARTSCodeGeneratorInterface poolVariableReferenceClass
                    poolName: 'PARTSNotebookConstants' varName: name )) ]!
doChanges
        " Private - apply the value if it has been changed. "

    | tab part |
    self changeSelector isNil ifTrue: [ ^nil ].
    textRadio value
        ifTrue: [ tab := entryField contents ].
    bitmapRadio value
        ifTrue: [            "bitmap selected"
            self modified ifTrue: [ tab := self newValue ] ].
    tab notNil ifTrue: [
        part := self part.
        self propertyStructure
            addAction:  ( Message new
                receiver: part
                selector: self changeSelector
                arguments: ( Array with: tab ) )
            undo:  (Message new
                receiver: part
                selector: self changeSelector
                arguments: ( Array with: self originalValue ) ) ].!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^WindowDialog entryHeight + self horizontalGap * 2!
partPropertiesIndexOf: anArray
        "Private - Answer the index of the element in anArray
        of style constants which is set in the receiver. "
    | sortedArray |
    sortedArray := anArray asSortedCollection: [ :a :b | a >= b].
    ^anArray indexOf:
        (sortedArray
            detect: [ :aStyle | self hasNotebookStyle: aStyle]
            ifNone: [^1])!
fileName
        " Private - answer the file containing the PARTS
        window definition. "

    ^'NtBkEdit.par'!  
openOn: values
        " Open an edit dialog on the values.
        Answer the updated values from the dialog
        (nil if cancelled). "
    ( self openModalDialog: 'DialogTopPane1' on: values ) isNil
        ifTrue: [ ^nil ].  " couldn't get the dialog open "
    ^(self partNamed: 'Answer') value!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | attr hasTab tab |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel addSelector: #initializePageAttributes.
    attr := self mainPage.
    hasTab := false.
    attr hasMinorTab ifTrue: [
        hasTab := true.
        anExpressionModel addSelector: #addMinorTab ].
    attr hasMajorTab ifTrue: [
        hasTab := true.
        anExpressionModel addSelector: #addMajorTab ].
    hasTab ifTrue: [
        tab := attr tab.
        tab isString
            ifTrue: [
                tab := PARTSHostInterface replaceMnemonicCharacters: tab.
                anExpressionModel
                    addSelector: #setTabTextWithMnemonics: with: tab ]
            ifFalse: [
                anExpressionModel
                    addSelector: #setTab: with: tab ]].
    anExpressionModel
        addSelectorIfNotNil: #pageKey: with: attr key;
        addSelectorIfNotNil: #setStatusText: with: attr statusText!
height
        " Private - answer the height of the property unit. "

    ^WindowDialog entryHeight * 12 // 15!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties.  Platform-dependent properties
        are controlled by class variables.  Generalized page/tab layout
        and binder style/tab shape options only supported by CUA
        notebook on OS/2.  Text alignment of tab and status text is
        supported on all platforms. "

    | partProperties majorTabs |
    partProperties := PARTSPropertyStructure on: self.
    BackPagesPositionValues notNil ifTrue: [partProperties
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Back pages';
            labelsMap: BackPagesPositionLabels;
            actions: (Array
                with: [majorTabs enableButton: 'Bottom'; enableButton: 'Right';
                    disableButton: 'Left'; disableButton: 'Top'; selectIfNone: 'Right']
                with: [majorTabs enableButton: 'Bottom'; disableButton: 'Right';
                    enableButton: 'Left'; disableButton: 'Top'; selectIfNone: 'Left']
                with: [majorTabs disableButton: 'Bottom'; enableButton: 'Right';
                    disableButton: 'Left'; enableButton: 'Top'; selectIfNone: 'Right']
                with: [majorTabs disableButton: 'Bottom'; disableButton: 'Right';
                    enableButton: 'Left'; enableButton: 'Top'; selectIfNone: 'Left']);
            initialSelection: (self partPropertiesIndexOf: BackPagesPositionValues) );
        putProperty: (majorTabs := PARTSPropertyButtonGroupWS new
            label: 'Major tabs';
            labelsMap: MajorTabPositionLabels;
            initialSelection: (self partPropertiesIndexOf: MajorTabPositionValues) )
                makeSameLine;
        yourself ].
    partProperties
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Tab alignment';
            labelsMap: TabAlignmentLabels;
            initialSelection: (self partPropertiesIndexOf: TabAlignmentValues) ).
    TabShapeValues notNil ifTrue: [partProperties
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Tabs shape';
            labelsMap: TabShapeLabels;
            initialSelection: (self partPropertiesIndexOf: TabShapeValues) )
                makeSameLine ].
    partProperties
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Status text alignment';
            labelsMap: StatusAlignmentLabels;
            initialSelection: (self partPropertiesIndexOf: StatusAlignmentValues) );
        yourself.
    BinderStyleValues notNil ifTrue: [partProperties
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Binder type';
            labelsMap: BinderStyleLabels;
            initialSelection: (self partPropertiesIndexOf: BinderStyleValues) )
                makeSameLine ].
    partProperties
        putProperty: ( PARTSPropertyBoolean new
            value: super demandLoad;
            label: 'Demand load';
            changeSelector: #demandLoad: ).
    partProperties
        putProperty: #( #interface #sizeWindow #editContents ).
    ^partProperties!
value: aValue
        "Set the value of the property to <aValue>. "

    newValue := oldValue := aValue.!  
bitmapRadioClicked
        " Private - the Bitmap radio button was selected "

    entryField disable.
    bitmapPush enable! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Notebook Page'! 
partAddFramingBlockExpressionTo: aCodeGeneratorExpression
	"Do nothing."!
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | aValue originalValue newValue |
    aValue := PARTSNotebookEditor new openOn: self partContents.
    aValue notNil
        ifTrue: [
            originalValue := self partDirectEditValue.
            self partSetContents: aValue.
            newValue := self partDirectEditValue.
            self partEditor
                recordUndo: ( Message new
                    receiver: self
                    selector: #partSetContents:
                    arguments: (Array with: originalValue) )
                undoLabel: 'direct edit'
                redo: ( Message new
                    receiver: self
                    selector: #partSetContents:
                    arguments: (Array with: newValue) )
                redoLabel: 'direct edit' ]!
partFileInUpgradeLoadedOS2: anObjectFiler
        " Private - finish upgrading subpanes from PARTS OS/2 2.0.
        Do some cleanup and optimization to get rid of unnecessary stuff. "


    | pwo20SortedPages |
    pwo20SortedPages := orderedPages.
    orderedPages := OrderedCollection new.
    pwo20SortedPages size = 0
        ifFalse: [
            pwo20SortedPages do: [ :aPage | self appendPage: aPage ].
            pwo20SortedPages first window notebookPages isEmpty
                ifTrue: [
                    pwo20SortedPages do: [ :aPage |
                        aPage window addNotebookPage: aPage ]]].
    self pages: Dictionary new.

    super partFileInUpgradeLoadedOS2: anObjectFiler.!
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    | application messageModel expressionModel |
    application := self partApplication.
    self pageWindows do: [ :child |
        messageModel := anExpressionModel addSelector: #addPagePart:.
        expressionModel := messageModel newExpressionArgument.
        expressionModel
            setReceiverToSelf;
            addSelector: ( application selectorForComponentBuild: child )
                with: application ]!
computeHeight
        "Private - compute and answer the height of the receiver."

    ^WindowDialog entryHeight * 3!   
partTargetEmphasisRectangle
        "Private - answer a rectangle to be used for
        drag target emphasis."
    ^super partTargetEmphasisRectangle!
addToWindow: aTopPane
        " Private - create panes in <aTopPane> to represent
        the receiver's value. "
    dialog := aTopPane owner.
    aTopPane
        when: #opened
        send: #clearModified to: self.
    aTopPane
        addSubpane: (GroupBox new
            font: self font;
            label: 'Tab style';
            framingBlock: [ :b | (b leftTop rightAndDown:self  leftTop)
                extentFromLeftTop: self pushButtonWidth "+ self gap" @
                    (self height * 7 // 2)]);
        addSubpane: (textRadio := PARTSRadioButtonPart new
            font: self font;
            label: 'Text';
            selection: self originalValue isString;
            startGroup;
            when: #clicked: send: #textRadioClicked to: self;
            framingBlock: [ :b | (b leftTop rightAndDown: self leftTop + ( self horizontalGap + 2 ))
                extentFromLeftTop: self pushButtonWidth * 3 // 4 @ self height]);
        addSubpane: (bitmapRadio := PARTSRadioButtonPart new
            font: self font;
            label: 'Bitmap';
            selection: self originalValue isBitmap;
            when: #clicked: send: #bitmapRadioClicked to: self;
            framingBlock: [ :b | ((b leftTop rightAndDown: self leftTop + ( self horizontalGap + 2 ))
                down: self height " + self gap" )
                    extentFromLeftTop: self pushButtonWidth * 3 // 4 @ self height]);
        addSubpane: (entryField := PARTSEntryFieldPart new
            font: self font;
            contents: (self originalValue isString
                ifTrue: [ self originalValue ]
                ifFalse: [ nil ] );
            framingBlock: [ :b | (((b leftTop rightAndDown: self leftTop) right:
                self pushButtonWidth + ( self horizontalGap "* 2" )) down: self horizontalGap // 2) extentFromLeftTop:
                    self pushButtonWidth @ self entryFieldFrameHeight]);
        addSubpane: (bitmapPush := Button new
            font: self font;
            label: 'Edit bitmap...';
            when: #clicked send: #editBitmap to: self;
            framingBlock: [ :b | (((b leftTop rightAndDown: self leftTop) right:
                self pushButtonWidth + ( self horizontalGap "* 2")) down: self entryFieldHeight + self horizontalGap )
                    extentFromLeftTop: self pushButtonWidth @ self pushButtonHeight ])! 
editBitmap
        " Private "

    | bitmap |
   bitmap := ( self originalValue isBitmap
        ifTrue: [ self originalValue clone ]
        ifFalse: [ Bitmap screenExtent: 24 @ 24 ] ).
    PARTSBitEditor new
        partWrapper: self part partWrapper;
        openOn: bitmap saveBlock: [
            modified := true.
            newValue := bitmap ]! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. Upgrade tab stop and order info
        in a PWO 2.0 window.  "

    | loadContext oldFramingBlock |

    self notebookPages isNil
        ifTrue: [ self notebookPages: OrderedCollection new ].

    loadContext := anObjectFiler clientContext.
    self
        partsIfOS2Do: [
            self notebookPages isNil
                ifTrue: [ self notebookPages: OrderedCollection new ].
            loadContext isPARTSLoadContext not
                ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

            ( #(
                'LAF/VPM 2.0a'    " PARTS 2.0 for OS/2 "
                )
                    includes: loadContext fileVersion )
                ifTrue: [
                    anObjectFiler
                        when: #loaded
                        send: #partUpgradeTabInfoOS2: to: self with: anObjectFiler ]]
        partsIfWindowsDo: [
            ( #( 'PARTS/Win32 2.0'    " PARTS 2.0 for Win32 " )
                includes: loadContext fileVersion )
                    ifTrue: [     " must replace PWW 2.0 framing block with a framer in PW 3.0 "
                    oldFramingBlock := framingBlock.
                    self framingBlock: self defaultFramer.
                            " drop the old block bytecodes out of the fileIn list "
                    anObjectFiler
                        registerUpgradeMutationFrom: oldFramingBlock homeContext
                           to: nil].
            ].
    ^super fileInUpgrade: anObjectFiler!  
addMajorTab
		"Set the receiver to have a major tab."
	self mainPage major! 
partCanBeReplacedBy: aPart
    "Answer whether the receiver can be replaced
    by <aPart> on the workbench.  All links will be
    reattached to <aPart>."

    ^aPart isPARTSNotebookPagePane! 
disable
        " Disable the property unit. "

    super disable.
    bitmapPush disable.
    bitmapRadio disable.
    entryField disable.
    textRadio disable! 
partPropertyStyle
    ^self mainPage style!  
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^false!  
partPropertySetStyle: newStyle
        "Private - Change the style of the receiver to newStyle."
    | page |
    page := self mainPage.
    page
        removeStyle: NbksMajorTab | NbksMinorTab;
        addStyle: newStyle.!
turnToPageNumber: anInteger
    "Turn to page number <anInteger>.  If <anInteger> is out of range,
        select the last page. "

    self isHandleOk
        ifFalse: [ ^self whenValid: #turnToPageNumber: with: anInteger ].

    super turnToPageNumber: anInteger
!
pageButtonHasPoint: aPoint
         "Private - answer true if aPoint is over the scroll buttons."

    | w className |
    self partsVosOnly.   "Only used on VOS"
    PARTSEditor setDragHandler: #includeGroupBox
        execute: [
            w := PARTSHostInterface hostWindowLibrary
               windowFromPoint: self handle asParameter
               pptl: aPoint  asParameter
               fChildren: true
               flock: false ].
    ( PARTSHostInterface hostWindowLibrary isChild: w parent: handle )
         ifTrue: [
              className := String new: 20.
              PARTSHostInterface hostWindowLibrary
                  queryClassName: w
                  chMax: className size
                  buffer: className.
                  className := className trimBlanks.
                  ^(#('#55') includes: className) ]
            "#55 is the window class for the notebook page turn button."
         ifFalse: [ ^false ]!
partDirectEditValue
        "Answer the direct edit value of the receiver."
    ^Array
        with: self majorTabExtent
        with: self minorTabExtent
        with: self pageButtonExtent!  
sequenceChildren
        "Private - Open a dialog to specify the tabbing and
        direction key ordering among the children."
    PARTSTabOrderEditor new openOn: self.!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | page tabStyleIndex partProperties |
    page := self mainPage.
    tabStyleIndex := 3.
    page hasMajorTab ifTrue: [tabStyleIndex := 1].
    page hasMinorTab ifTrue: [tabStyleIndex := 2].
    partProperties := PARTSPropertyStructure on: self.
    partProperties
        putProperty: ( PARTSPropertyString new
            value: page key;
            label: 'Page key:';
            changeSelector: #pageKey:);
        putProperty: ( PARTSPropertyString new
            value: page statusText;
            label: 'Status line text:';
            changeSelector: #setStatusText:);
        putProperty: ( PARTSPropertyButtonGroupWS new
            label: 'Tab';
            labelsMap: TabStyleLabels;
            initialSelection: tabStyleIndex;
            actions: (Array
                with: [(partProperties propertyAt: #tabStyle)
                    setModified: true; enable]
                with: [(partProperties propertyAt: #tabStyle)
                    setModified: true; enable]
                with: [(partProperties propertyAt: #tabStyle)
                    setModified: true; disable] ) );
        at: #tabStyle putProperty: ( PARTSPropertyNotebookTab new
            value: page tab;
            changeSelector: #updateTab:).
    partProperties
        putProperty: #( #interface #sequenceChildren ).
    ^partProperties! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "
    | oc |

    super partPrintPropertiesOn: aStream margin: aString.

    ( oc := self orderedChildren ) size > 0
        ifTrue: [
            aStream
                nextPutAll: aString, 'Tab Order:   * indicates a tab stop';
                cr.
            oc do: [ :child |
                child isAGroupLeader
                    ifTrue: [
                        aStream tab; nextPutAll: aString, 'Group Start' ;cr ].
                    aStream tab; tab; nextPutAll: aString.
                    child isATabStop
                    ifTrue: [
                        aStream nextPutAll: '* ' ].
                    aStream nextPutAll: child partName; cr.
                ] ].! 
setDisableState
        "Private - The window is open.  Set the disable state
        of the receiver's display items. "

    textRadio selection
        ifTrue: [ self textRadioClicked ].
    bitmapRadio selection
        ifTrue: [ self bitmapRadioClicked ].!   
addMinorTab
		"Set the receiver to have a minor tab."
	self mainPage minor! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Notebook'!  
enable
        " Enable the property unit. "

    super enable.
    bitmapRadio enable.
    bitmapRadio value
        ifTrue: [ bitmapPush enable ].
    textRadio enable.
    textRadio value
        ifTrue: [ entryField enable ].!   
textRadioClicked
        " Private - Text radio button was selected "

    bitmapPush disable.
    entryField enable! 
addPagePart: pageWindow
        "Private - Insert a new page with pageWindow as the
          new page window. Answer the pageWindow wrapper."
    | page |
    self addSubpane: pageWindow.
    self isHandleOk ifTrue: [
        self partsIfOS2Do: [
                pageWindow
                    adjustFraming: ( 0 @ 0 extent: self calcPageRect extent );
                    buildWindow: self]
            partsIfWindowsDo: [
                pageWindow
                    initSize: (0 @ 0 extent: self calcPageRect extent);
                    open;
                    buildWindow: self;
                    resize: (0 @ 0 extent: self calcPageRect extent) ] ].

    page :=
        (( pageWindow notebookPages notEmpty )
            ifTrue: [ "Undo deleting this page.  Use existing info."
                pageWindow notebookPages first ]
            ifFalse: [
                PARTSNotebookPageAttributes new
                    window: pageWindow;
                    yourself ]).
    self insertPageLast: page
!
codeGenerationAddFramingBlockMessagesTo: anExpressionModel
        "Private - add messages to anExpressionModel to
        reconstruct and set the receiver's framing block.
        Do nothing for notebook pages."!  
partEditContents: currentContents properties: aPropertyStructure
        " Private - edit the part contents "
    ^( PARTSNotebookEditor new openOn: currentContents ) partsExceptionIfNil! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    self partsIfWindowsDo: [
        " replace PWW 2.0 client area framing block with a framer in PW 3.0 "
        [ self font height ] "getting clientFramingBlock requires a valid font"
            on: Error do: [ :e | curFont := self defaultFont ].
        self pagePaneGroup framingBlock: self clientFramingBlock.
        " change page representation in PW 3.0 "
        " initialize reference to containing notebook in PWW 2.0 pages "
        orderedPages isNil
            ifTrue: [ orderedPages := OrderedCollection new ]
            ifFalse: [
                orderedPages do: [ :aPage |
                    aPage notebook: self.
                    aPage window addNotebookPage: aPage  ]].
        ( value isNil and: [ orderedPages size > 0 ])
            ifTrue: [ value := orderedPages first ]
        ].
    ^super fileInUpgrade: anObjectFiler!