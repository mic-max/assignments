3.1.0.106
   
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        visual part. "

    ^'PpVslPrt.par'!  
propertiesDo: aBlock
		" Evaluate the one-argument block <aBlock>
		with each property. "

    unitOrdering do: [ :key |
        aBlock value: ( self propertyAt: key ) ].!  
COMMENT
"
A PARTSPropertySequenceChildren property is a push
button property labelled 'Order children...' which opens
the tab order editor.
"!   
editContents
    ^#( 'Edit contents...' #partPropertyEditContents: )!
COMMENT
"
A PARTSPropertyFormGeneratorButton is an abstract
superclass for push button properties which invoke
form generation operations.  The superclass provides
the framework for providing undo/redo support for
form generation operations, which typically create parts
and links in the application.
"!   
left
        " Private - answer the left side of the receiver. "

    ^leftTop x!  
hasIconProperty
        " Private - answer whether my part has
        an icon property. Visual parts generally don't "

    ^false!  
partEditor
        " Answer the PARTS Workbench in which the receiver's part is being edited. "
    ^self part partEditor!  
partParentRectangle
    "Private "
    ^self part first superWindow freeClientArea! 
rightTop
        " Private - answer the rightTop of the receiver. "

    ^leftTop right: extent x! 
newValue
        " Answer the new value of the list. "

    ^listPane contents!
openOn: anOrderedCollection
        " Open a PARTS OrderedCollection editor. "
    oc := anOrderedCollection.
    modified := false.
    answer := PARTSException new.
    self
        createView;
        openWindow.
    ^answer!  
style
		" Answer the style settings value of the receiver. "

    | answer |
    answer := 0.
    labelsMap do: [ :a |
        answer := answer | a last ].
    ^answer!   
createEntryControl
        " Private - initialize the entry part to add to the window.
        Contents must be initialized. "
   self textEntryItem: (   PARTSEntryFieldPart new
        value: self initialValue;
        yourself ).! 
setModified: aBoolean
        " Set the modified state of the receiver to <aBoolean>. "

    modified := aBoolean.!
clickedAdd
        " Private - the add button was pressed "

    | newItem displayedList |
    self setModified: true.
    newItem := self entryField contents.
	( displayedList :=  newValue ) isNil
		ifTrue: [ self newValue: ( displayedList := OrderedCollection new ) ].
    ( displayedList includes: newItem )
        ifTrue: [ ^MessageBox message: newItem, ' is already defined' ].
    validateValueMessage notNil
        ifTrue: [
            ( self validateValueMessage perform )
                ifFalse: [ ^self ] ].
    displayedList add: newItem.
    listPane
        insertItem: newItem;
        selectIndex: displayedList size.
    self entryField 
		contents: String new; 
		setFocus.!   
partEditor
        " Answer the PARTS Workbench in which the receiver's part is being edited. "

    ^partEditor!  
commonVerticalScaleMask
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r001000000000000 = 0 ]
! 
initialize
		" Private - initialize a new instance. "

    super initialize.
    result := PARTSException new.!   
okButton
        " Private - answer the OK button in the dialog window. "

    ^self partNamed: 'OkButton'!
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | controlList g r |
    controlList := Array new: labelsMap size.
    g := GroupBox new
        font: self font;
        owner: self;
        framingBlock: self framingBlock.
    label notNil ifTrue: [g label: label].
    aTopPane addSubpane: g.
    1 to: labelsMap size do: [ :i |
        (r := RadioButton auto)
            font: self font;
            owner: self;
            label: (labelsMap at: i) first;
            when: #clicked:
                send: #clicked: to: self with: r;
            framingBlock: (self framingBlockFor: i).
        "(labelsMap at: i) first = initialSelection"
        initialSelection = i
            ifTrue: [r selection: true].
        aTopPane addSubpane: r.
        i = 1 ifTrue: [r startGroup].
        controlList at: i put: r ].
    self controls: controlList.! 
isStyle
        "Answer whether the receiver represents a window style. "

    ^true!  
disabled
		" Answer whether the property unit is disabled. "

    ^enabled not!
labelToComputeWidth
        "Private - answer a string with which to compute
        the width of the receiver's label."
    ^self label!  
newPartIcon
        " Private - answer the updated part icon. "

    ^newPartIcon! 
setHeight: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        ( aFramer isTopInset and: [ aFramer isBottomInset ] )
            ifTrue: [ aFramer useBottomHeight ].
        aFramer isBottomInset
            ifTrue: [ aFramer useTopStretched: proportional ]
            ifFalse: [ aFramer useBottomStretched: proportional ].
        aFramer changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.

    self commonVerticalScaleMask
        ifFalse: [
            "Vertical attributes are not common. Make them common.
                Changing to bottom won't remove height attribute"
            self setBottom:
                ( framers first isBottomInset
                    ifTrue: [ framers first isBottomStretched ]
                    ifFalse: [ framers first isTopStretched ])].

    self changedVertically
!   
initializeParts
        " Private - the dialog window application has been loaded.
        Register the event handlers and initialize the items in the
        property dialog based on the current values of the part.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #initializeParts to super."

    self
        initializeEventHandlers;
        initializePartValues.!   
canDoChanges
        " Private - answer whether the receiver's changes can be applied. "

    self modified not
        ifTrue: [ ^true ].
    result := self textEntryItem evaluateContents.
    result isPARTSException
        ifTrue: [ ^false ].  " compilation error "
    super canDoChanges
        ifFalse: [ ^false ].
    self newValue: result.
    ^true! 
eventsTriggered
        " Answer all the events which can be triggered
        by instances of the receiver. "

    ^eventsTriggered! 
dragTarget
    "Private - answer true if the related part has been enabled
    as a drag target."

    ^(self part propertyAt: #dragTarget ifAbsent: [nil]) notNil.!  
selection: aLabel
		" Select the radio button labelled <aLabel>. "

    1 to: labelsMap size do: [ :i |
        ( labelsMap at: i ) first = aLabel
            ifTrue: [ ( self controls at:  i ) setValue: true ] ]!
partEvents

    ^PARTSInterfaceList new
        items: #(
            #changed:
            #changedHorizontally:
            #changedVertically: )
!  
newValue: anObject
        " Update the value of the property.  Mark the receiver as modified. "

    newValue := anObject.
    self setModified: true.!  
selectIfNone: aLabel
		" Specify the label of the radio button to select
		if nothing is selected. "

    self controls do: [ :aRadioButton | 
		aRadioButton value ifTrue: [ ^self ] ].
    1 to: labelsMap size do: [ :i |
        ( labelsMap at: i ) first = aLabel
            ifTrue: [ ( self controls at: i ) setValue: true ] ]! 
initialize
        " Private - initialize a new instance. "

    actions := OrderedCollection new.
    undoActions := OrderedCollection new.
    unitOrdering := OrderedCollection new.
    propertyUnits := IdentityDictionary new.
    partContext := Dictionary new.
    doingValidation := false.!
initChildren
        "Private - Init the children dictionary of (part name -> subpane)."
    children := Dictionary new.
    orderedChildren
        do: [:child |
            children at: child partName put: child]!  
canDoChanges
        " Private - answer whether the receiver's changes can be applied. "
    self modified
        ifTrue: [ self newValue: self value ].
    ^true.! 
editFont
        " Private - open the font edit dialog on the font.
        Set the apply check box if changed. "

    super editFont notNil
        ifTrue: [ self applyFontCheckBox setValue: true ].! 
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog.
        Subclass implementations of this method
        should first send #initializeEventHandlers to super."

    super initializeEventHandlers.
    self
        initializeForeColorButton;
        initializeBackColorButton;
        initializeFontButton;
        initializeSizeWindowButton.!   
partFinalize
        "Finalize the receiver by releasing any system resources."

    oldValue partFinalize.
    newValue partFinalize!
staticTextLabelExtent: anExtent
        " Reset the extent of StaticText part being created
        for the label.  This value does not include the margin. "

    ^self labelItem itemExtent: anExtent!  
pushButtonWidth
    | answer |
    answer := super pushButtonWidth.
    labelsAndSelectors do: [ :a |
        label := a first.
        answer := answer max: ( self widthOfString: label ) ].
    ^answer! 
contentsPane
    " Private - Return the  Contents:  DateEntryField in the properties dialog. "
    ^(self propertyStructure propertyAt: #contents ) textEntryItem!  
commonBottom
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r000000100000000 = 0 ]
!
leftButton2Frame: aRectangle withVerticalUnit: aNumber
        " Return the framing rectangle for the second column
          left buttons used by the editor (ie. 'Cancel' button)."
    | extentUnit |
    extentUnit:= self extentUnit: aRectangle.
    ^ (aRectangle left right: extentUnit x // 2 + self gap) @ (aRectangle bottom up: aNumber) extentFromLeftBottom:
                    extentUnit x - self gap // 2 @ extentUnit y! 
openOn: aPart
        " Open a properties dialog on aPart.
        Answer the updated part (nil if cancelled). "

    self
        part: aPart;
        initializeValues.
    changesAccepted := false.
    self openDialogWindow.
    changesAccepted
        ifFalse: [
            self cancelChanges.
            ^nil ].
    ^part! 
dialogWindow
        " Private - answer the dialog window. "

    ^self partNamed: self dialogWindowName!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^43 * WindowDialog charWidth!  
entryFieldWidth
		" Private "

    ^textExtent x!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self labelWidth!  
canDoChanges
        " Private - answer whether the receiver's changes can be applied. "

    ^self modified not 
		or: [ validationMessage isNil 
		or: [ self validationMessage perform ] ]!   
createEntryControl
        " Private - initialize the entry part to add to the window.
        Contents must be initialized. "

   self textEntryItem: ( PARTSExpressionEntryField new
        value: self initialValue;
        yourself ).!   
rightButton1Frame: aRectangle withVerticalUnit: aNumber
        " Return the framing rectangle for the first column
          right buttons used by the editor (ie. 'Add' button)."
    | rightsLeft extentUnit |
    rightsLeft:= self rightsLeft: aRectangle.
    extentUnit:= self extentUnit: aRectangle.
    ^ rightsLeft @ (aRectangle top down: aNumber)
                extentFromLeftBottom: extentUnit x - self gap // 2 @ extentUnit y! 
labelEntryFieldGap
        "Answer the horizontal distance
        between a static text label and it's associated
        entryField."
    ^4!   
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "
    PARTSPropertiesEditor new openOn: self partProperties.!  
on: aPart
		" Answer a new instance of the receiver which
		is to contain properties of <aPart>. "

    ^self new part: aPart!
value
        " Answer the current value of the expression item. "

    ^self textEntryItem evaluateContents!  
initialize
    "Private - initialize part properties."

    ^super initialize.!
disable
		" Disable the property unit. "

    enabled := false.!   
framer
    "Private"

    ^commonFramer
! 
setWidthValue: aValue
    "Private"
    | width |

    aValue isNil ifTrue: [ ^self ].

    width := aValue asNumber.
    framers do: [ :aFramer |
        aFramer isRightInset
            ifTrue: [ aFramer left: width ]
            ifFalse: [ aFramer right: width ]].
    self updateCommonFramer.
!
cancelChanges
        " Private - the property edit is being cancelled.
        Back out any changes made to the real part.
		Default is to do nothing.  Must be reimplemented by 
		subclasses if they have made any changes to the part
		or the application since the property editor was opened. "!  
partEditValue
        "Open a window to edit the receiver.
        Answer the new value (a PARTSException if cancelled)."
    ^PARTSDictionaryEditor new openOn: self copy!
paneAt: aPane
        "Private - Answer the control named aPane."
    ^(dialogWindow dependents
        at: aPane ifAbsent: [Array with: nil]) first.! 
addToStyle: aDictionary
        " Private - update the style value <anInteger> with
        the receiver's style value and answer the new style. "
    | answer |

    answer := self addToStyleBasic: ( aDictionary at: #style ).
    aDictionary at: #style put: answer.
    ^aDictionary!   
staticTextWidth
		"Private - answer the width of the static text controls
		in the receiver."
	^10!
verticalGap
        "Answer the height of the vertical gap between controls."
    ^self class verticalGap!  
part
        " Answer the part which owns these properties. "

    ^part!  
disableButton: aLabel
		" Disable the radio button labelled <aLabel>. "

    1 to: labelsMap size do: [ :i |
        ( labelsMap at: i ) first = aLabel
            ifTrue: [ ( self controls at: i ) setValue: false; disable ] ]!  
disableItems

    listBox contents size = 0
        ifTrue: [ self removeAllButton disable ].
    self removeButton disable!  
layoutItemClass
        " Private - answer the class which represents a form item. "

    ^LayoutItemClass!
removeAllButtonName
    ^'Remove All...'!
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self labelWidth max: self entryFieldWidth!
createView
        " Private - create the window.  "
    | font verticalUnit topPane |
    font:= self font.
    verticalUnit := self verticalUnit.
    self addView: ((topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: 'PARTS Dictionary Editor';
        yourself ).
    topPane
        addSubpane: ((listBox := ListBox new)
            owner: self;
            font: font;
            when: #needsContents
            send: #listContents: to: self with: listBox;
            when: #changed:
            send: #listSelect: to: self;
            framingBlock:  [ :b | self leftListBoxFrame: b withVerticalUnit: verticalUnit * 2 ]);
        addSubpane: (StaticText new
            font: font;
            value: 'Key:';
            framingBlock: [ :b | self rightFieldsFrame: b withVerticalUnit: verticalUnit ]);
        addSubpane: ((keyField := EntryField new)
            owner: self;
            font: font;
            framingBlock: [ :b | self rightFieldsFrame: b withVerticalUnit: verticalUnit * 2 ]);
        addSubpane: (StaticText new
            font: font;
            value: 'Value:';
            framingBlock: [ :b | self rightFieldsFrame: b withVerticalUnit: verticalUnit * 3 ]);
        addSubpane: ((valueField := EntryField new)
            owner: self;
            font: font;
            framingBlock: [:b | self rightFieldsFrame: b withVerticalUnit: verticalUnit * 4 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: 'Add';
            when: #clicked send: #clickedAdd to: self;
            framingBlock: [ :b | self rightButton1Frame: b withVerticalUnit: verticalUnit * 5 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: 'Remove';
            when: #clicked send: #clickedRemove to: self;
            framingBlock: [ :b | self rightButton2Frame: b withVerticalUnit: verticalUnit * 5 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: 'Remove All...';
            when: #clicked send: #clickedRemoveAll to: self;
            framingBlock: [ :b | self rightFieldsFrame: b withVerticalUnit: verticalUnit * 6 ]);
        addSubpane: (Button new
            defaultPushButton;
            owner: self;
            font: font;
            label: 'OK';
            when: #clicked send: #ok to: self;
            framingBlock: [ :b | self leftButton1Frame: b withVerticalUnit: verticalUnit * 2 // 3 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b | self leftButton2Frame: b withVerticalUnit: verticalUnit * 2 // 3 ]);
        yourself.!
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog. "

    self
        initializeForeColorButton;
        initializeBackColorButton;
        initializeFontButton;
        initializeSizeWindowButton;
        initializeOkCancelButtons.! 
clicked: aButton
		" Private - <aButton> has been clicked. "

    self setModified: true.
    labelsMap detect: [ :a |
        a first = aButton label
            ifTrue: [
                newValue := a last.
                self immediateValidationMessage notNil
                    ifTrue: [ self immediateValidationMessage perform ].
                true]
            ifFalse: [false]].
    actions notNil ifTrue: [
        actions isContext
            ifTrue: [actions value]
            ifFalse: [
                1 to: actions size do: [ :i |
                    aButton label = (labelsMap at: i) first
                        ifTrue: [(actions at: i) value]]]]!   
modified
        " Answer whether the receiver's value has been changed. "

    ^super modified or: [ self textEntryItem modified ]!   
initializeForeColorButton
        " Private - register the event handler for
        the button which opens the color editor
        on the part's foreground color.  Subclasses
        should reimplement this method to do nothing
        if they do not support a foreground color property. "

    self foreColorButton
        when: #clicked
        send: #editForeColor to: self.! 
lastStyleVerticalGap
        "Private - answer the vertical distance between
        the bottom of the lower most style control and the
        bottom of the styles box."

    ^4!  
hasForeColorChanged
        " Private -  answer whether the foreground color has been changed. "

    ^newForeColor ~= #uninitialized! 
sizeButtonClicked
        " Private "
    | newSize newArray |
    newSize := sizeField value.
    newSize isNil
        ifTrue: [
            ^MessageBox
                notify: 'No Size Specified'
                withText: 'Please enter a value for the array size.'. ].
    newSize = array size ifTrue: [^self].
    newSize > array size
        ifTrue: [
            newArray := Array new: newSize.
            newArray
                replaceFrom: 1
                to: array size
                with: array.
            array := newArray]
        ifFalse: [
            array := array
                copyFrom: 1 to: newSize].
    listBox update!  
radioButtonHeight
        "Answer the height of an standard radio button."
    ^PARTSDialog standardEntryHeight - 1!
height
		" Private - answer the height of the property unit. "

    ^self pushButtonHeight!
object
		" Answer the object associated with the properties. "

    ^object!   
hasNameChanged
        " Private - answer whether the part name has been changed.
        Not supported for a multi-part selection. "

    ^false!
entryFieldWidth
        "Private - answer the default width
        of an entry field."
    ^self class entryFieldWidth!   
height
		" Private - answer the height of the property unit. "

    ^self pushButtonHeight!
createLinks: itemsToBeAdded
        "Private - Create links between new parts and the creatorPart. "

    | aLink |
    itemsToBeAdded do: [ :aFormItem |
        ( aFormItem sourceEvent notNil
        and: [ aFormItem partMessage notNil ] )
            ifTrue: [
                aLink := self partEditor
                    createLinkFrom: creatorPart
                    event: aFormItem sourceEvent
                    to: aFormItem part
                    message: aFormItem partMessage.
                links add: aLink ].
        ( aFormItem partEvent notNil
        and: [ aFormItem sourceMessage notNil ] )
            ifTrue: [
                aLink := self partEditor
                    createLinkFrom: aFormItem part
                    event: aFormItem partEvent
                    to: creatorPart
                    message: aFormItem sourceMessage.
                links add: aLink ].
        ].!  
labelsAndSelectors: anArray
		" Private "
    labelsAndSelectors := anArray!
verticalUnit
        " Return a number which represents the vertical unit between panes. "
    ^self class entryHeight + (self gap // 4).!  
orderClicked: aString
    " Private - one of the date order options have been selected.
      Store the order format into newValue."
    | format |
    format := Dictionary new
        at: 'D-M-Y' put: DfDMY;
        at: 'M-D-Y' put: DfMDY;
        at: 'Y-M-D' put: DfYMD;
        yourself.
    newValue at: 'format' put: (format at: aString).
    self contentsPane
        dateFormat: self dateFormat;
        modified: true.
    self sampleUpdate.!   
layoutAfterStylesFrom: anInteger
        " Private - compute item layout "

    | prev col2Left |
    properties from: anInteger to: properties size do: [ :p |
        p column = 1 ifTrue: [
            prev isNil
                ifTrue: [p leftTop:
                     ( self leftMargin @ ( stylesRightBottom y + self verticalGapAfterStyles ))]
                ifFalse: [
                    p sameLine
                        ifTrue: [p leftBottom: (prev rightBottom + (self gapX @ 0))]
                        ifFalse: [p leftTop: (self leftMargin @ (prev bottom + self gapY))]].
            extentFromLeftTop := extentFromLeftTop max: p rightBottom.
            prev := p]].
    col2Left := extentFromLeftTop y + self gapX.
    prev := nil.
    properties from: anInteger to: properties size do: [ :p |
        p column = 2 ifTrue: [
            prev isNil
                ifTrue: [p leftTop:
                    (col2Left @ (stylesRightBottom y + (self gapY )))]
                ifFalse: [
                    p leftTop: (col2Left @ (prev bottom + self gapY))].
            extentFromLeftTop := extentFromLeftTop max: p rightBottom.
            prev := p]]!  
commonScaleUnit
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r100000000000000 = 0 ]
! 
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #constructApplyActions to super."

    self hasNameChanged
        ifTrue: [
            applyChangesActions
                add: ( self applyPartNameActionFor: self newPartName ).
            undoChangesActions
                add: ( self applyPartNameActionFor: self partName ) ].

    self hasIconChanged
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #partSetGraphics:
                    arguments: (Array with:  self newPartIcon) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #partSetGraphics:
                    arguments: (Array with: self partIcon clone) ) ].!   
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Append <aString>
        after every new line. "

    label isNil ifTrue: [ ^self ].
    aStream
        nextPutAll: aString;
        nextPutAll: label;
        nextPutAll: ' ';
        nextPutAll: oldValue printString;
        cr!  
leftTop: aPoint
        " Private - set the leftTop position of the receiver. "

    leftTop := aPoint.!   
applyPartNameActionFor: aPartName
        " Private - answer the action to evaluate to apply
        <aPartName> as the part name. "

    ^Message
        receiver: ( self class basicNew part: self part; yourself )
        selector: #applyPartName:
        arguments: ( Array with: aPartName )! 
windowTitle
        " Private "
    ^object partName, ' Properties'!
controls: visualItems
        " Private - set the controls used to render the
        the receiver's value.  May be either a control
        or a list of controls. "

    controls := visualItems.! 
initializeOrderedChildrenButton
        " Private - register the event handler for
        the button which opens the ordered children editor.
        Subclasses should send this message in their
        initializeEventHandlers method to support ordered
        children editing. "

    self orderChildrenButton
        when: #clicked
        send: #editOrderedChildren to: self.! 
undoChanges
        " Private - reset the value if it has been changed. "

    self shouldApplyChange
        ifTrue: [ self part perform: changeSelector with: self originalValue ].!
value: aValue
        "Set the value of the property to <aValue>. "

    oldValue := aValue.
    newValue := aValue copy asOrderedCollection! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Do nothing for
		an operation button. "! 
addDateYearOptions: aTopPane
        " Private - add the year options for a date format."
    |font cellSize width|
    font := self font.
    cellSize := WindowDialog charWidth @ WindowDialog entryHeight.
    width:= self staticTextWidth.
    aTopPane
        addSubpane: (StaticText rightJustified
            font: font;
            contents: 'Year:';
            framingBlock: [:b |(b leftTop rightAndDown: ((1 @ (16/5)  )*cellSize + self leftTop))
                    extentFromLeftTop: ((width @ 1) * cellSize)]);
        addSubpane: (RadioButton new
            startGroup ;
            setName: 'twoDigitYear';
            contents: 'Two digit ';
            setValue: (oldValue at: 'twoDigitYear');
            when: #clicked: send: #twoDigitYearClicked: to: self;
            font: font;
            framingBlock: [:b |(b leftTop rightAndDown: ( self horizontalGap @ 0 + ( (width @ 3)*cellSize + self leftTop)))
                    extentFromLeftTop: ((width @ 1) * cellSize)]);
        addSubpane: (RadioButton new
            setName: 'fourDigitYear';
            contents: 'Four digit ';
            setValue: (oldValue at: 'twoDigitYear') not;
            when: #clicked: send: #fourDigitYearClicked: to: self;
            font: font;
            framingBlock: [:b |(b leftTop rightAndDown: ( self horizontalGap @ 0 + ( (width*2 @ 3)*cellSize + self leftTop)))
                    extentFromLeftTop: ((width @ 1) * cellSize)])! 
partMessage: aSymbol
        "partMessage is a Symbol which is the message
        for the link from the part to the source part."
    ^partMessage := aSymbol!
pushButtonWidth
        "Answer the default width of the reciever's push button controls."
    ^self class pushButtonWidth! 
enable
		" Enable the property unit. "

    enabled := true.!  
losingFocus: anEntryField
		" Private "

	self isImmediatelyValid
		ifFalse: [ anEntryField setFocus ].!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^widestLabelPELS + self horizontalGap! 
COMMENT

"
PARTSFormGenerator provides support for adding
new parts to a PARTS application in a PARTS Workbench
editor, including optionally creating links.  It is typically
used in the property dialog of a part, such as the
'Create form parts...' capability of the BtrieveAccessor
and CStructure parts.

The form generator facility is used by creating a new
PARTSFormGenerator instance and sending it the
message #generatePartsFor:fromDialog: .

The client part must implement the
following protocol to support form-building:

    partFormGeneratorNames
        Answer a collection containing the names of
        parts which the creators proposes to generate.

    partFormGeneratorItemsFor: partNames
        Answer an ordered collection of PARTSFormGeneratorItem
        instances specifying the parts to be generated to
        represent the specified partNames.

The client should hang on to this instance of PARTSFormGenerator
so if the user clicks on the 'Cancel' button of the part
property dialog, the form generation can be undone by
sending #cancelChanges to the PARTSFormGenerator.
"!   
newValue
        " Answer the new value of the property. "

    ^newValue! 
partEditIcon: anIcon saveBlock: aZeroArgumentBlock
        "Open an Icon Editor to modify anIcon.
        Evaluate aZeroArgumentBlock when the apply
        button is pressed.  The block should save
        the changed icon appropriately. "

    PARTSIconEditor new
        partWrapper: self partWrapper;
        openOn: anIcon saveBlock: aZeroArgumentBlock.!   
rightButton2Frame: aRectangle withVerticalUnit: aNumber
        " Return the framing rectangle for the second column
          right buttons used by the editor (ie. 'Modify' button)."
    | rightsLeft extentUnit |
    rightsLeft := self rightsLeft: aRectangle.
    extentUnit := self extentUnit: aRectangle.
    ^ ((rightsLeft right: extentUnit x + self gap // 2)
                @ aRectangle top down: aNumber ) extentFromLeftBottom:
                    extentUnit x - self gap // 2 @ extentUnit y!   
initialize
        " Reinitialize when set of triggered events is changed. "
    self initializeEventsTriggered.!   
initWindowSize
        "Private - return the initial size of the window"
    ^260@100!  
interface
    ^#( 'Interface...' #partEditInterface )!   
editInterface
        " Private - open an interface browser on the part. "

    self part partEditInterface.!  
addToWindow: aTopPane
    "Private - Add two checkboxes to <aTopPane> to enable
    the receiver to be the source and/or destination for a drag
    drop operation."

    | checkBoxWidth checkBoxHeight gapXPoint offsetX font |
    offsetX := 9.
    checkBoxWidth := self pushButtonWidth.
    checkBoxHeight := self pushButtonHeight.
    gapXPoint:= self gapX @ 0.
    font := self font.
    aTopPane
        addSubpane: ( Button new
            setName: 'Dragdrop';
            contents: 'Drag drop...' ;
            font: font;
            when: #clicked send: #setDragDrop to: self ;
            framingBlock:
                [ :b |
                (b leftTop
                    rightAndDown: ((0 @ 0) + leftTop))
                    extentFromLeftTop: (checkBoxWidth @ checkBoxHeight)]).!  
verticalGap
        "Answer the height of the vertical gap between controls."
"    ^WindowDialog dialogUnit y // 8 + 1"
    ^1!
redoChanges
        " Private - reapply the value if it has been changed. "

    self doChanges.!  
canDoChanges
        " Private - answer whether the receiver's changes can be applied. "

    | msg |
    self modified not
        ifTrue: [ ^true ].
    ( msg := self validationMessage ) isNil
        ifTrue: [
            self textEntryItem validateSizeAndFormatOfInput
                ifTrue: [
                    " We need the contents and *not* the value of the control because
                       we want the current window text not the stored value of the control. "
                    self newValue: controls contents.
                    ^true ]
                ifFalse: [
                    MessageBox warning: 'Invalid input in contents field.'.
                    self textEntryItem sendInputEvent: #setFocus.
                    ^false ] ]
        ifFalse: [ msg perform ]!  
enableButton: aLabel
        " Enable the radio button labelled <aLabel>. "

    1 to: labelsMap size do: [ :i |
        ( labelsMap at: i ) first = aLabel
            ifTrue: [ ( self controls at: i ) enable ] ]!
disable
   		" Disable the boolean item. "

    super disable.
    self checkBoxItem notNil
        ifTrue: [ self checkBoxItem disable ].!  
radioButtonHeight
        "Answer the height of an standard radio button."
    ^self class radioButtonHeight!   
undoChanges
        " Private - reset the value if it has been changed. "

    self modified ifTrue: [ self part partSetGraphics: self originalValue ].!   
setWidth: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        ( aFramer isLeftInset and: [ aFramer isRightInset ] )
            ifTrue: [ aFramer useRightWidth ].
        aFramer isRightInset
            ifTrue: [ aFramer useLeftStretched: proportional ]
            ifFalse: [ aFramer useRightStretched: proportional ].
        aFramer changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.

    self commonHorizontalScaleMask
        ifFalse: [
            "Horizontal attributes are not common. Make them common.
                Changing to right won't change width attribute"
            self setRight:
                ( framers first isRightInset
                    ifTrue: [ framers first isRightStretched ]
                    ifFalse: [ framers first isLeftStretched ])].

    self changedHorizontally

!   
labelWithTabMarker: label
        "Private -."
    ^'* ' , label!   
partParentRectangle
    "Private "
    ^self part superWindow freeClientArea.!  
removeField
        " Private - remove the selected field name
        from the list. "
    | listPane selectedItem index |
    listPane := self paneAt: self listPaneName.
    list := listPane contents.
    selectedItem := listPane selectedItem.
    index := list indexOf: selectedItem.
    list := list reject: [ :item | item = selectedItem].
    listPane contents: list.
    (list size > 0)
        ifTrue: [listPane selectIndex: (index min: list size)]
        ifFalse: [
            listPane selectIndex: 0. "The list is now empty, reflect this in the dialog."
            (self paneAt: self removeButtonName) disable].!
entryFieldFrameHeight
        "Answer the height the frame of an standard entry field."
    ^self class entryFieldFrameHeight!  
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
initWindowSize
        "Private - Answer the default window size."

    ^200 @ 150!
dialog: aPropertyEditor
		" Specify the dialog which is currently operating on the receiver. "

    dialog := aPropertyEditor.!
addToWindow: aTopPane
		" Private - create a check box in <aTopPane> to represent
		the receiver's value. "

	| aCheckBox |
    aTopPane addSubpane: ( ( aCheckBox := CheckBox new )
        font: self font;
        owner: self;
        label: label;
        value: ( oldValue isNil ifTrue: [ false ] ifFalse: [ oldValue ] );
        when: #clicked: send: #clicked: to: self;
        framingBlock: self framingBlock;
		yourself ).
    self disabled
        ifTrue: [ aCheckBox disable ].
	self controls: aCheckBox.!  
listContents: aPane
    | list item |
    list := Array new: array size.
    1 to: list size do: [ :i |
        item := array at: i.
        item := item isNil ifTrue: [''] ifFalse: [item asString].
        list at: i put: (i printString, '.  ', item)].
    aPane contents: list!
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | charSize cellSize font width |
    width:= 9.
    extent:= self computeExtent.
    dialogWindow := aTopPane.
    font := self font.
    cellSize := WindowDialog charWidth @ WindowDialog entryHeight.
    charSize := WindowDialog unitMultiplier.
    newValue:= oldValue.
    aTopPane
        when: #opened send: #disableItems to: self;
        addSubpane: (GroupBox new
            font: font;
            label: 'Format';
            framingBlock: self framingBlock ).
    self
        addDateOrderOptions: aTopPane;
        addDateYearOptions: aTopPane;
        addDateSeparatorOption: aTopPane;
        addDateSampleItem: aTopPane.!  
part
        " Answer the part "
    ^partItem visualPart!  
getItemsFor: selectedNames
        " Private - answer the form items for the selected form items. "

    ^getItemsAction notNil
        ifTrue: [ getItemsAction evaluateWithArguments: (Array with: selectedNames) ]
        ifFalse: [ creatorPart partFormGeneratorItemsFor: selectedNames ]! 
from: start to: stop do: aBlock
        " Evaluate the one-argument block <aBlock>
        with each property between index <start> and <stop>. "

    start to: stop do: [ :i |
        aBlock value: ( self propertyAt: ( unitOrdering at: i ) ) ].!   
dateSeparator: aString
    " Private - the user typed a  new date separator.
      Store the date separator into newValue. "
    newValue at: 'dateSeparator' put: aString.
    self contentsPane
        dateSeparator: aString;
        modified: true.
    self
        sampleUpdate!  
entryField
		" Private "

	^self controls! 
propertiesValid: aBoolean
        " Specify whether the property values are all valid. "

    propertiesValid := aBoolean.!
numberFieldWidth
        "Private - answer the default width
        of a numeric entry field."
    ^48!   
layoutRegularTo: anInteger
		" Private - compute item layout "

    | prev col2Left |
    extentFromLeftTop := 0@0.
    properties from: 1 to: anInteger do: [ :p |
        p column = 1 ifTrue: [
            prev isNil
                ifTrue: [p leftTop: self firstLeftTop]
                ifFalse: [
                    p sameLine
                        ifTrue: [p leftBottom: (prev rightBottom + (self gapX @ 0))]
                        ifFalse: [p leftTop: self leftMargin @ (prev bottom + self gapY)]].
            extentFromLeftTop := extentFromLeftTop max: p rightBottom.
            prev := p]].
    col2Left := extentFromLeftTop y + self gapX.
    prev := nil.
    properties from: 1 to: anInteger do: [ :p |
        p column = 2 ifTrue: [
            prev isNil
                ifTrue: [p leftTop: col2Left @ self firstLeftTop y]
                ifFalse: [
                    p leftTop: col2Left @ (prev bottom + self gapY)].
            extentFromLeftTop := extentFromLeftTop max: p rightBottom.
            prev := p]].! 
applySizes: framers to: parts
    "Private - From Window>>partPropertySetSize:"
    | editor editorPane framer parentRectangle somePart |

    editor := parts first partEditor.
    editorPane := editor workbenchPane.
    editorPane oldSelectionRects:
        ( parts collect: [ :aPart |
            editorPane selectionRect: ( editor getVisibleObjectOf: aPart )]).

    1 to: parts size do: [ :anIndex |
        somePart := parts at: anIndex.
        framer := framers at: anIndex.
        parentRectangle := somePart superWindow freeClientArea.
        somePart partWrapper rectangle: framer.
        somePart
            framingBlock: framer;
            resize: parentRectangle;
            bringToTop;
            updateWindow ].

    editorPane refreshSelectionsAfterMove

!
initializeEventsTriggered
        " Private - initialize all the events which can be triggered
        by instances of the receiver. "

    eventsTriggered := self constructEventsTriggered.!
entryFieldHeight
        "Answer the height of an standard entry field."
    ^PARTSDialog standardEntryHeight!  
fromPartFile: aPartFileName
    name: aPartName
    extent: aPoint
    staticTextLabel: labelString
    partEvent: aPartEvent
    partMessage: aPartMessage
    sourceEvent: aSourceEvent
    sourceMessage: aSourceMessage
    ifAbsent: aZeroArgBlock
        " Answer a new item for the PARTS form generator.
        If the specified part file is not found, use the result
        of evaluating aZeroArgBlock to get a substitute part.
        <aPartName> is the part name of the part.
        <aPoint> is used if this is a visual part.
        If <labelString> is specified a StaticText label will
        be placed to the left of the part. "
    | anApplication aPart helpInfo |

    [ anApplication :=
        PARTSFile applicationFromFile: aPartFileName ]
        on: PARTSApplicationLoadError
        do: [ :e | anApplication := nil ].

    anApplication isNil
        ifTrue: [
            aPart := aZeroArgBlock value.
            helpInfo := nil ]
        ifFalse: [
            aPart := anApplication solePart.
            helpInfo := anApplication helpInfo ].
    ^self new
        part: aPart
            name: aPartName
            extent: aPoint
            helpInfo: helpInfo;
        staticTextLabel: labelString;
        partEvent: aPartEvent;
        partMessage: aPartMessage;
        sourceEvent: aSourceEvent;
        sourceMessage: aSourceMessage;
        yourself!
textExtent: aPoint
        " Set the preferred size (chars @ lines ) "
    textExtent :=
        ((aPoint x * WindowDialog charWidth)
        @ (aPoint y * self lineHeight))
            + self textMargin.!
COMMENT
"
A PARTSPropertyFixedList property presents
a list of choices in a list pane.
"! 
addToStyle: aDictionary
        " Private - update the style value <anInteger> with
        the receiver's style value and answer the new style. "
    | answer |

    answer := self addToStyleBasic: ( aDictionary at: #extendedStyle ).
    aDictionary at: #extendedStyle put: answer.
    ^aDictionary!   
commonRight
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r000010000000000 = 0 ]
! 
createEntryControl
        " Private - initialize the entry part to add to the window.
        Contents must be initialized. "

   self textEntryItem: (
        ( self originalValue isFloat
            ifTrue: [ PARTSFloatEntryFieldPart ]
            ifFalse: [ PARTSIntegerEntryFieldPart ] ) new
        validateWhenLosingFocus: false;
        value: self originalValue;
        yourself ).!
computeHeight
        "Private - compute and answer the height of the receiver."

    ^self height * 7 // 6!   
selectedChild
        "Private - Answer the subpane which is selected
        in the listPane."
    ^children at: (self labelWithoutTabMarker:
            (self paneAt: #children) selectedItem)!
layoutItemClass: aClass
        " Private - specifiy the class which represents a form item. "

    LayoutItemClass := aClass.!
clickedAdd
        " Private - add an element to the collection. "
    | index |
    index := listBox selectedIndex.
    (index = 0  or: [index isNil])
        ifTrue: [
            index := oc size.
            oc add: itemField contents]
        ifFalse: [
            oc add: itemField contents afterIndex: index].
    listBox update.
    listBox setValueIndex: index + 1.

    "Leave disabled because it's selected:
    itemField contents: String new; setFocus.
    "
    modified:= true.! 
ok
        "Private - The OK button has been pressed.
        Accept the new property values to the part and close
        the dialog window if the proposed changes are valid.
        If there is a problem with any values, notify the user
        and leave the dialog open.  Answer whether the
        new properties were accepted. "

    self havePropertiesChanged
        ifFalse: [
            self close.
            ^true ].
    self arePropertiesValid
        ifFalse: [ ^false ].
    self acceptProperties.
    self close.
    ^true!  
setModified: aBoolean
        " Set the modified state of the receiver to <aBoolean>. "

    super setModified: aBoolean.
    self textEntryItem modified: aBoolean.! 
layout
        " Private - compute the layout of the property items. "

    | p styleStart styleEnd |
    1 to: properties size do: [ :i |
        p := properties at: i.
        p isSymbol ifTrue: [properties atIndex: i put: (p := self perform: p)].
        p isStyle
            ifTrue: [styleStart isNil ifTrue: [styleStart := i]]
            ifFalse: [styleStart notNil ifTrue: [
                styleEnd isNil ifTrue: [styleEnd := i - 1]]]].
    (styleStart notNil and: [styleEnd isNil]) ifTrue: [
        styleEnd := properties size].
    self layoutRegularTo: (styleStart isNil ifTrue: [properties size] ifFalse: [styleStart - 1]).
    styleStart notNil ifTrue: [
        self
            layoutStylesFrom: styleStart to: styleEnd;
            layoutAfterStylesFrom: styleEnd + 1]!  
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^true!
entryFieldHeight
		" Private "

    ^textExtent y! 
partNameIsValid
        " Private - answer whether the part name in the property
        dialog is valid. "

    | entryField wrapper requestedName newName |
    wrapper := part partWrapper.
    entryField := ( propertyUnits at: #componentNameField ) textEntryItem.
    requestedName := entryField contents trimBlanks.
    ( requestedName = wrapper name )
        ifTrue: [ ^true ].
    newName := wrapper application
        generatePartNameFor: part
        preference: requestedName.
    ( newName = requestedName )
        ifFalse: [
            ( MessageBox confirm:
                    '''', requestedName,
                    ''' is  not a valid name, is ''', newName, ''' ok?' )
                ifTrue: [ entryField setValue: newName; modified: true ]
                ifFalse: [ ^false ] ].
    ^true! 
partEditValue
        "Open a window to edit the receiver.
        Answer the new value (a PARTSException if cancelled)."
    ^PARTSArrayEditor new openOn: self!  
createView
        " Private - create the window "
    | font topPane |
    font := self font.
    self addView: ((topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: 'PARTS Array Editor';
        yourself ).
    topPane
        addSubpane: ((listBox := ListBox new)
            owner: self;
            font: font;
            when: #needsContents 
                send: #listContents: to: self with: listBox;
            when: #changed: 
                send: #listSelect: to: self;
            framingBlock: [ :b | self listFrame: b]);
        addSubpane: (itemField := PARTSEntryFieldPart new
            owner: self;
            font: font;
            framingBlock: [ :b | self itemFieldFrame: b]);
        addSubpane: (Button new
            owner: self;
            font: font;
            contents: 'Change item';
            when: #clicked send: #changeButtonClicked to: self;
            framingBlock: [ :b | self changeButtonFrame: b]);
        addSubpane: (sizeField := PARTSIntegerEntryFieldPart new
            owner: self;
            font: font;
            value: array size;
            framingBlock: [ :b | self sizeFieldFrame: b]);
        addSubpane: (Button new
            owner: self;
            font: font;
            contents: 'Change size';
            when: #clicked send: #sizeButtonClicked to: self;
            framingBlock: [ :b | self sizeButtonFrame: b]);

        addSubpane: (Button new
            owner: self;
            defaultPushButton;
            label: 'OK';
            font: font;
            when: #clicked send: #ok to: self;
            framingBlock: [ :b | self okButtonFrame: b]);
        addSubpane: (Button new
            owner: self;
            label: 'Cancel';
            font: font;
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b | self cancelButtonFrame: b]);

        yourself.!
checkBoxHeight
        "Private - answer the height of a standard check box."

    ^self class checkBoxHeight! 
supportedLabelPositions
        " Answer the label positions which can be specified. "
    ^#( #left #right #top #bottom )! 
contentsChanged
        " Private - the contents of the entry field changed "

    self setModified: true.
	self isImmediatelyValid
		ifFalse: [ self textEntryItem sendInputEvent: #setFocus ].!
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Append <aString>
        after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: label;
        nextPutAll: ': ';
        nextPutAll: ( oldValue isNil
            ifTrue: [ '<none>' ]
            ifFalse: [ oldValue asArray printString ] );
        cr!  
initialize
        " Private "
    super initialize.
    self label: 'Create form parts...'.!  
addLabelToWindow: aTopPane
		" Private - add the label item to <aTopPane>. "

    aTopPane addSubpane: ( StaticText rightJustified
        font: self font;
        owner: self;
        contents: self label;
        framingBlock: [ :b | self labelFrameIn: b ] )!  
COMMENT
"
A PARTSPropertyPseudoStyle represents a window style as
a boolean value which is displayed using a check box item.
All window style items are presented in a single group
in the property dialog of a visual part.  A pseudo style
is a value which is logically a window style but which
is not represented as bit values in a style setting
and so cannot be applied with the special style handling.
The client of a psuedo style is responsible for registering
a #changeSelector: which applies the value to the part.
"!   
initialize
        " Private "
    super initialize.
    self label: 'Create table part...'.!  
newSize: currentSize
    "Private - Prompt the user for the new size
    with a size window dialog."

    ^PARTSWindowSizeEditor new
        openOn: currentSize
        parentRectangle: self partParentRectangle! 
gapY
		" Private - answer the vertical gap between items. "

    ^PARTSPropertyUnit verticalGap!   
partNameEntryField
        " Private - answer the part name entry field in the dialog window. "

    ^self partNamed: 'PartNameEntryField'!
staticTextLabel: aString
        " Specify the string to display in a StaticText
        label associated with the part.  By default, the
        label is placed to the left of the part. "

    self labelItem: aString.
    (aString notNil and: [ self labelPosition isNil ] )
        ifTrue: [ self labelPosition: self defaultLabelPosition ].! 
bottom
		" Private - answer the bottom position of the receiver. "

    ^leftTop y + self extent y!
changeButtonFrame: aRectangle
    ^((aRectangle leftTop right: aRectangle width // 2 + (self unit * 2))
        down: self verticalSpacing + self unit) extentFromLeftTop:
            (self commonExtent: aRectangle)!
pushButtonWidth
        "Answer the default width of the receiver's push button controls."
    ^super pushButtonWidth * 3 // 4! 
pushButtonExtent
        "Answer the extent of an standard push button."
    ^self pushButtonWidth @ self pushButtonHeight! 
sameLine
        " Specify that the receiver should be rendered on
        the same line as the preceding property unit
        in the containing property structure. "

    ^sameLine!  
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | part action |
    part := self part.
    1 to: labelsAndSelectors size do: [ :i |
        action := (labelsAndSelectors at: i) last.
        aTopPane addSubpane: (Button new
            owner: aTopPane owner;
            font: self font;
            label: (labelsAndSelectors at: i) first;
            when: #clicked
                send: action
                to: part
                withArguments: ( (action last = $:)
                    ifTrue: [Array with: self]
                    ifFalse: [ #() ] );
            framingBlock: (self framingBlockFor: i))]!  
setFont
    ^#( 'Font...' #partPropertySelectFont: )!
addDateOrderOptions: aTopPane
        "Private - add radio buttons for date order options."
    |font cellSize width|
    font := self font.
    cellSize := WindowDialog charWidth @ WindowDialog entryHeight.
    width:= self staticTextWidth.
    aTopPane
        addSubpane: (CheckBox new
            setName: 'useSystemFormat';
            contents: 'Use system settings';
            setValue: (oldValue at: 'useSystemFormat');
            when: #clicked: send: #useSystemFormat: to: self;
            font: font;
            framingBlock: [:b |(b leftTop rightAndDown: ((1 @ 1)*cellSize + self leftTop))
                    extentFromLeftTop: ((20 @ 1) * cellSize)]);
        addSubpane: (StaticText rightJustified
            font: font;
            contents: 'Order:';
            framingBlock: [:b |(b leftTop rightAndDown: ((1 @ (11/5)  )*cellSize + self leftTop))
                    extentFromLeftTop: ((width @ 1) * cellSize)]);
       addSubpane: (RadioButton new
            startGroup;
            setName: 'M-D-Y';
            contents: 'M-D-Y';
            setValue: ((oldValue at: 'format') = DfMDY);
            when: #clicked: send: #orderClicked: to: self;
            font: font;
            framingBlock: [:b |(b leftTop rightAndDown: ( self horizontalGap @ 0 + ((width @ 2)*cellSize + self leftTop)))
                    extentFromLeftTop: ((width @ 1) * cellSize)]);
        addSubpane: (RadioButton new
            setName: 'D-M-Y';
            contents: 'D-M-Y';
            setValue: ((oldValue at: 'format') = DfDMY);
            when: #clicked: send: #orderClicked: to: self;
            font: font;
            framingBlock: [:b |(b leftTop rightAndDown: ( self horizontalGap @ 0 + ((width*2 @ 2)*cellSize + self leftTop)))
                    extentFromLeftTop: ((width @ 1) * cellSize)]);
        addSubpane: (RadioButton new
            setName: 'Y-M-D';
            contents: 'Y-M-D';
            setValue: ((oldValue at: 'format') = DfYMD);
            when: #clicked: send: #orderClicked: to: self;
            font: font;
            framingBlock: [:b |(b leftTop rightAndDown: ( self horizontalGap @ 0 + ((width*3 @ 2 )*cellSize + self leftTop)))
                    extentFromLeftTop: ((width @ 1) * cellSize)])!
partForeColor
        " Private - answer the part's foreground color value.
        Use the value of the first part in the collection. "

    ^self part first foreColor! 
createEntryControl
        " Private - initialize the entry part to add to the window.
        Contents must be initialized. "

   self textEntryItem: ( PARTSTextPanePart new
        enableWordWrap;
        value: self initialValue;
        yourself ).!  
partEvent: aSymbol
        "Private - partEvent is a Symbol which is the event
        for the link from the part to the source part."
    partEvent := aSymbol!   
dialogOpened
        " The dialog window has been opened. "

    self propertiesDo: [: p | p setDisableState].
    self triggerEvent: #opened.!   
initWindowSize
        " Private - return the initial size of the window. "
    ^220@100!   
COMMENT
" Referenced by the part file PpSzWndw "
!  
firstLeftTop
        "Private - answer the point which would be the
        top left corner of the top left control."

    ^self leftMargin @ self gapX!  
disableItems
		" Private - disable the receiver's items. "

    self useSystemFormat
        ifTrue: [
            (self paneAt: 'D-M-Y') disable.
            (self paneAt: 'M-D-Y') disable.
            (self paneAt: 'Y-M-D') disable.
            (self paneAt: 'dateSeparator') disable]
        ifFalse: [
            (self paneAt: 'D-M-Y') enable.
            (self paneAt: 'M-D-Y') enable.
            (self paneAt: 'Y-M-D') enable.
            (self paneAt: 'dateSeparator') enable]!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #setBottom:
            #setBottomValue:
            #setHCenter:
            #setHCenterValue:
            #setHeight:
            #setHeightValue:
            #setLeft:
            #setLeftValue:
            #setRight:
            #setRightValue:
            #setTop:
            #setTopValue:
            #setVCenter:
            #setVCenterValue:
            #setWidth:
            #setWidthValue:

            #fixedInsetFixedSize
            #fixedInsetAll
            #stretchedAll

            #scaleUnit:
            #framer
            #clearFramers
            #framers
        )
        separators: #( 16 19 )
        defaultItem: #setBottom:
!   
partName
        " Private - answer the part's name. "

    ^self part partName!   
currentFont: aFont
        " Private - Assign the current font selected. "
    currentFont := aFont!
rectangle
        " Private - answer the bounding rectangle of the receiver. "

    ^leftTop extentFromLeftTop: extent!
COMMENT
"
A PARTSPropertyDragDrop property provides
check boxes to enable or disable the part as
a DragDrop source and/or target.
"! 
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | rect innerRect g |
    aTopPane
        addSubpane: ( controls := PARTSEntryFieldPart new
            font: self font;
            framingBlock: [ :b |
                rect := self rectangleIn: b.
                innerRect := ( rect leftTop rightAndDown: self horizontalGap // 2 @ ( self horizontalGap * 3 // 2 ))
                    rightBottom: ( rect rightBottom leftAndUp: self horizontalGap // 2 ).
                ( innerRect leftTop rightAndDown: self verticalGap )
                    rightBottom: (( innerRect rightTop leftAndDown: self verticalGap ) down:
						self entryFieldFrameHeight )]);
        addSubpane: ( Button new
            font: self font;
            label: 'Add';
            when: #clicked send: #clickedAdd to: self;
            framingBlock: [ :b |
                rect := self rectangleIn: b.
                innerRect := ( rect leftTop rightAndDown: self horizontalGap // 2 @ ( self horizontalGap * 3 // 2 ))
                    rightBottom: ( rect rightBottom leftAndUp: self horizontalGap // 2 ).
            innerRect leftBottom extentFromLeftBottom: self pushButtonExtent ] );
        addSubpane: ( Button new
            font: self font;
            label: 'Remove';
            when: #clicked send:  #clickedRemove to: self;
            framingBlock: [ :b |
                rect := self rectangleIn: b.
                innerRect := ( rect leftTop rightAndDown: self horizontalGap // 2 @ ( self horizontalGap * 3 // 2 ))
                    rightBottom: ( rect rightBottom leftAndUp: self horizontalGap // 2 ).
            ( innerRect leftBottom right: self pushButtonWidth + ( self horizontalGap // 3))
                extentFromLeftBottom: self pushButtonExtent ]);
        addSubpane: ( ( listPane := ListBox new )  " PW 2.0 used ListPane "
            font: self font;
            owner: self;
            when: #needsContents
                send: #listContents: to: self with: listPane;
            "when: #changed: send: #listSelect: to: self with: listPane;"
            framingBlock: [ :b | (innerRect leftTop down: WindowDialog entryHeight * 4 // 3)
                    rightBottom: (innerRect rightBottom up: self pushButtonHeight * 3 // 2)]);
        addSubpane: (g := GroupBox new
            font: self font;
            framingBlock: [ :b |
                rect := self rectangleIn: b.
                innerRect := ( rect leftTop rightAndDown: self horizontalGap // 2 @ ( self horizontalGap * 3 // 2 ))
                    rightBottom: ( rect rightBottom leftAndUp: self horizontalGap // 2 ).
                rect] ).
    label notNil ifTrue: [g label: label]!   
gapX
		" Private - answer the horizontal gap "
	^PARTSPropertyUnit horizontalGap!   
part: aPart
        " Private - specify the part whose properties are being edited. "

    part := aPart.! 
addPropertyControls: topPane
        " Private - create property items in the dialog window "
    properties propertiesDo: [ :p |
        p addToWindow: topPane].
    stylesLeftTop notNil ifTrue: [
        topPane addSubpane: (GroupBox new
            font: self font;
            owner: self;
            label: 'Styles';
            framingBlock: [ :b | (b leftTop rightAndDown: stylesLeftTop)
                rightBottom: ((b right left: self gapX) @
                    ( b top down: stylesRightBottom y))])].! 
shouldApplyChange
        " Private - answer whether the receiver's value has
        been changed and should be applied to the part. "

    ^self modified and: [ changeSelector notNil ]!   
frameWidth
        "Private - answer the width of the receiver's frame.
        The message #width is used for layout while
        #frameWidth is used for the actual frame rectangle.
        The default frameWidth is the width."
    ^self width!   
labelWidth
        "Private - answer the width of the receiver's label."
    ^( self widthOfString: self labelToComputeWidth ) + 2! 
size
		" Answer the number of properties. "

    ^propertyUnits size!  
ok
        "Private - Add tabStop and groupLeader properties to
            ordered children."
    | ocAnswer listPane index child |
    ocAnswer := OrderedCollection new.
    listPane := self paneAt: #children.

    index := 0.
    listPane contents do: [:item | index := index + 1.
        child := children at: (self labelWithoutTabMarker: item).
        (item indexOfString: self class tabMarker) > 0
            ifTrue: [ child tabStop ]
            ifFalse: [ child noTabStop ].
        (listPane isSeparatorAt: index)
            ifTrue: [
                child startGroup.
                index := index + 1 ]
            ifFalse: [ child noGroupLeader ].
        ocAnswer add: child ].

    "First child is always a groupLeader"
    (ocAnswer size > 0)
        ifTrue: [ ocAnswer first startGroup ].
    answer := ocAnswer.
    self close!  
partOrderedChildren
        " Private - answer the part's ordered children list. "

    ^self part orderedChildren!
widthOfString: aString
        "Private - answer the width of aString in units used
        by the receiver."
    ^PARTSDialog horizontalDialogUnitsFromPixels: ( self widthInPixelsOfString: aString )!   
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #initializePartValues to super."

    super initializePartValues.

    self dialogWindow
        setLabel: self partName, ' Properties'.

    self partNameEntryField
        value: self partName.

    self hasIconProperty
        ifTrue: [ self iconStaticGraphic value: self partIcon ].!   
cancelButtonFrame: aRectangle
        "Answer the rectangle of the cancel button."
    | extent |
    extent := self commonExtent: aRectangle.
    ^((aRectangle rightBottom leftAndUp:
        WindowDialog entryHeight * 2 // 3)
            leftAndUp: extent)
                extentFromLeftTop: extent!   
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self pushButtonWidth * 7 // 3!
getNames
        " Private - answer the list of candidate form item names. "

    ^getNamesAction notNil
        ifTrue: [ getNamesAction evaluate ]
        ifFalse: [ creatorPart partFormGeneratorNames ]!
ok
        " Private - the OK button was pressed. "
    answer := oc.
    self close!  
height
		" Private - answer the height of the property unit. "

    ^self lineHeight + self entryFieldHeight!  
setIcon: aButton
    | newIcon file |
    file := (FileDialog new openFile: '*.ico') file.
    file size = 0 ifTrue: [^self].
    newIcon := PARTSIcon fromFile: file.
    actions addLast: (Message new
        receiver: object;
        selector: #partSetGraphics:;
        arguments: (Array with: newIcon))!
addToWindow: aTopPane
		" Private - create a push button in <aTopPane> to represent
		the receiver's operation. "

    dialogWindow := aTopPane.
    super addToWindow: aTopPane.!   
cancelChanges
		" Cancel any changes "

    propertyUnits do: [ :p | p cancelChanges].
    self triggerEvent: #cancelled.!
childList
        "Private - Answer a list of the children to be
        considered for tabstops and arrow key ordereing.
        Children with a tabstop will have a tabMarker."
    | oc name|
    oc := OrderedCollection new.
    orderedChildren do: [:child |
        name := child partName.
        (child isATabStop)
                ifTrue: [name:= self class tabMarker , name].
        oc add: name].
    ^oc!   
clearTabStop
        "Private - "
    | list item listPane |
    listPane := self paneAt: #children.
    list := listPane contents.
    item := listPane selectedItem.
    list at: (list indexOf: item) put: (self labelWithoutTabMarker: item).
    listPane contents: list;
        selectItem: (self labelWithoutTabMarker: item).
    self disableButtons: listPane!
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
        'Drag items to order the fields.'
        " 'Remove any fields that you do not want.' "
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
            setName: self listPaneName;
            contents: list;
            font: self font;
            userCanReorder: true;
            dragButton: self mouseButtonDrag;
            selectIndex: 1;
            framingBlock:
                (self framingBlock: deltaLeftTop extent: anExtent)).
    deltaTopLeft2 :=
        ( deltaLeftTop x right: (marginDlg + anExtent x) )
        @ deltaLeftTop y.

    " Remove button "
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
    internalWidthDlg := internalWidthDlg max:
        (anExtent x + marginDlg + anExtent2 x).
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
formGenerator
        " Private - answer a new form generator. "

    ^PARTSFormGenerator new! 
dialogWindow
        " Private "
    ^dialogWindow! 
dateFormat
    " Private - Return the current date format specified in the property dialog. "
    ^(newValue at: 'useSystemFormat')
        ifTrue: [ NationalLanguage dateFormat ]
        ifFalse: [ newValue at: 'format' ].!  
addDateSeparatorOption: aTopPane
        " Private - add the date separator property. "
    | font cellSize width |
    font:= self font.
    cellSize := WindowDialog charWidth @ WindowDialog entryHeight.
    width:= self staticTextWidth.
    aTopPane
        addSubpane: (StaticText rightJustified
            font: font;
            contents: 'Separator:';
            framingBlock: [ :b | ( b leftTop rightAndDown: (( 1 @ ( 21/5 )) * cellSize + self leftTop ))
                    extentFromLeftTop: (( width @ 1 ) * cellSize )]);
        addSubpane: ( PARTSEntryFieldPart new
            font: font;
            contents: (oldValue at: 'dateSeparator');
            setName: 'dateSeparator';
            setTextLimit: 1;
            when: #textChanged: send: #dateSeparator: to: self;
            framingBlock: [:b | ( b leftTop rightAndDown: ( self horizontalGap @ 0 + ((width @ 4) * cellSize + self leftTop )))
                    extentFromLeftTop: ( 2 * cellSize x ) @ self entryFieldFrameHeight ] )!   
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self labelWidth + 48! 
currentBackColor: aColor
        " Private - Assign the current backcolor selected. "
    currentBackColor := aColor!   
disableButtons: childrenListPane
        "Private -"
    | selectedItem |

    selectedItem := childrenListPane selectedItem.
    (selectedItem isNil
        or: [(children at: (self labelWithoutTabMarker: selectedItem)) isPARTSNestedPart])
        ifTrue: [
            ( childrenListPane selectedIndex = 1 or: [ selectedItem isNil ])
                ifTrue: ["The first control is always a group leader."
                    (self paneAt: #startGroup) disable.
                    (self paneAt: #clearGroup) disable ]
                ifFalse: [
                    (self paneAt: #startGroup) enable.
                    (self paneAt: #clearGroup) enable ].
            (self paneAt: #setTabStop) disable.
            ^(self paneAt: #clearTabStop) disable ].
    ((self selectedChild isRadioButton) or: [self selectedChild isKindOf: StaticPane])
        ifTrue: ["User does not set tabstops on RadioButtons or StaticPanes"
            (self paneAt: #setTabStop) disable.
            (self paneAt: #clearTabStop) disable]
        ifFalse: [
            (selectedItem includes: $* )
                ifTrue: [
                    (self paneAt: #setTabStop) disable.
                    (self paneAt: #clearTabStop) enable]
                ifFalse: [
                    (self paneAt: #setTabStop) enable.
                    (self paneAt: #clearTabStop) disable]].

    childrenListPane selectedIndex = 1
        ifTrue: ["The first control is always a group leader."
            (self paneAt: #startGroup) disable.
            ^(self paneAt: #clearGroup) disable].

    (childrenListPane separators
        includes: (childrenListPane selectedIndex - 1))
        ifTrue: [
            (self paneAt: #startGroup) disable.
            (self paneAt: #clearGroup) enable]
        ifFalse: [
            (self paneAt: #startGroup) enable.
            (self paneAt: #clearGroup) disable].!  
originalValue
        " Answer the original value of the property. "

    ^oldValue!   
addAction: aMessage
        "Private - add an action that will
        be evaluated when the user clicks on the OK button."
    actions addLast: aMessage! 
value
        " Answer the current value of the property (nil if empty). "

     ^self textEntryItem value!
modified
        " Answer whether the receiver's value has been changed. "

    ^modified! 
computeHeight
        "Private - compute and answer the height of the receiver."

    ^self entryFieldHeight!  
doChanges
		" Private - apply the value if it has been changed. "

    self shouldApplyChange
        ifTrue: [ self part perform: changeSelector with: self newValue ].! 
checkForProblemLinks
        "Private - If the part can dynamically remove events
        or message due to changes in the properties, then some
        existing links can become obsolete.  This method detects
        these links and makes them visible to the user."

    self partHasDynamicMessages
        ifTrue: [ (Message
            receiver: self partEditor
            selector: #validateLinksAttachedTo:
            arguments: ( Array with: self part ) )
                performDeferred ].!
leftBottom
        " Private - answer the leftBottom position of the receiver. "

    ^leftTop x @ ( leftTop y + self extent y )!  
height
    "Private - answer the height of the property unit. "

    ^self pushButtonHeight!   
staticTextLabelPart
        " Answer the StaticText part being created for the label. "

    ^self labelItem isNil
        ifTrue: [ nil ]
        ifFalse: [ self labelItem visualPart ]!   
addToStyle: aDictionary
        " Private - update the style value <anInteger> with
        the receiver's style value and answer the new style. "
    | styleInteger |

    styleInteger := aDictionary at: #style.
    styleInteger := self checkBoxItem value
        ifTrue: [ styleInteger | constant ]
        ifFalse: [ styleInteger bitAnd: ( constant bitXor: 16rFFFFFFFF ) ].
    aDictionary at: #style put: styleInteger.
    ^aDictionary!
layoutManagerClass
		" Private - answer the class which computes the form layout. "

	^LayoutManagerClass! 
top
        " Private - answer the top of the receiver. "

    ^leftTop y! 
partPropertySequenceChildren: aPropertyUnit
        " Private - Order children property button handler "
    | key properties orginalOrderedChildren newOrderedChildren |
    key := #partPropertySequenceChildren.
    properties := aPropertyUnit propertyStructure.
    orginalOrderedChildren := self orderedChildren.

    newOrderedChildren := PARTSTabOrderEditor new
        openOn: ( properties partContext at: key
        ifAbsent: [orginalOrderedChildren] ).
    newOrderedChildren isNil ifTrue: [^self].
    properties partContext at: key put: newOrderedChildren.
    properties
        addAction: (Message new
            receiver: self
            selector: #orderChildrenAndDisplay:
            arguments: (Array with: newOrderedChildren) )
        undo: (Message new
            receiver: self
            selector: #orderChildrenAndDisplay:
            arguments: (Array with: orginalOrderedChildren) )!   
computeHeight
        "Private - compute and answer the height of the receiver."

    ^self iconExtent y max: self pushButtonHeight!   
redoPropertyChanges
        " Private - re-apply the property changes. "

    operation := #redoChanges.
    self triggerEvent: #aboutToEdit.
    self propertiesDo: [ :p | p redoChanges ].
    self styleChanged
        ifTrue: [ self setStyle: newStyle ].
    actions do: [ :m | m perform ].
    self triggerEvent: #editDone.
    operation := nil.!
foreColorButton
        " Private - answer the Forecolor... button in the dialog window. "

    ^self partNamed: 'ForecolorButton'!
commonHorizontalScaleMask
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r010000000000000 = 0 ]
!   
listSelect: selectedItem
        " Private - an entry was selected in the collection. "
    itemField contents: selectedItem.
    self removeButton enable.
    self removeAllButton enable.! 
enabled: aBoolean
		" Set the enabled state of the property unit to <aBoolean>. "

    enabled := aBoolean.!   
clicked
        " Private - the button has been pressed. "
    self part perform: clickedSelector with: self.!  
disable
		" Disable the buttons. "

    super disable.
    controls do: [ :control | control disable ]!   
immediateValidationMessage: aMessage
		" Specify <aMessage> to evaluate when the
		focus is lost from the visual item containing
		the receiver's value. "

    immediateValidationMessage := aMessage.! 
entryField: anEntryField
		" Private "

	self controls: anEntryField.! 
canDoChanges
        " Private - answer whether the receiver's changes can be applied. "

    super canDoChanges
        ifFalse: [ ^false ].
    self modified
        ifTrue: [ self newValue: self textEntryItem value ].
    ^true!
openOn: aDictionary
        " Open a PARTS dictionary editor. "
    dictionary := aDictionary.
    modified := false.
    answer := PARTSException new.
    self
        createView;
        openWindow.
    ^answer! 
computeWidth
        "Private - compute and answer the width of the receiver."

    | buttonWidth |
    buttonWidth := self pushButtonWidth.
    ^buttonWidth * 3 + ( self horizontalGap * 2 )!  
addToWindow: aTopPane
        "Private - Add three buttons to <aTopPane> to set the 
		forecolor, backcolor and font of the receiver. "

    | buttonWidth buttonHeight gapXPoint font |
    buttonWidth := self pushButtonWidth.
    buttonHeight := self pushButtonHeight.
    gapXPoint:= self gapX @ 0.
    font := self font.
    aTopPane
        addSubpane: ( Button new
            setName: 'Forecolor';
            contents: 'Forecolor...' ;
            font: font;
            when: #clicked send: #partPropertySelectColor: to: self with: #foreColor;
            framingBlock: [ :b | (b leftTop rightAndDown: ((0@0) + leftTop))
                    extentFromLeftTop: ( buttonWidth @ buttonHeight )] );
        addSubpane: ( Button new
            setName: 'Backcolor';
            contents: 'Backcolor...' ;
            font: font;
            when: #clicked send: #partPropertySelectColor: to: self with: #backColor;
            framingBlock: [ :b |(b leftTop rightAndDown: ((buttonWidth @ 0) + leftTop + gapXPoint  ))
                    extentFromLeftTop: (buttonWidth @ buttonHeight)] );
         addSubpane: ( Button new
            setName: 'Font';
            contents: 'Font...' ;
            font: font;
            when: #clicked send: #partPropertySelectFont to: self ;
            framingBlock: [ :b |(b leftTop rightAndDown: (((buttonWidth * 2) @0) + leftTop + (gapXPoint * 2)))
                    extentFromLeftTop: (buttonWidth @ buttonHeight)] )!
setDisableState
        "Private - The window is open.  Set the disable state 
		of the receiver's display items. "!
editIconButton
        " Private - answer the Edit icon... button in the dialog window. "

    ^self partNamed: 'EditIconButton'!  
value
        "Return the current value of the receiver."

    ^self checkBoxItem value!   
orderedChildrenEditor
        " Private - answer a new tab order editor. "

    ^PARTSTabOrderEditor new!  
applyProperties
        " Private - apply the validated property values to the part. "

    applyChangesActions := OrderedCollection new.
    undoChangesActions := OrderedCollection new.

    self constructApplyActions.
    applyChangesActions :=
        (ActionSequence fromCollection: applyChangesActions)
            asMinimalRepresentation.
    undoChangesActions :=
        (ActionSequence fromCollection: undoChangesActions)
            asMinimalRepresentation.

    applyChangesActions evaluate.
    self
        registerUndoRedoOperations;
        checkForProblemLinks.!   
framingBlockFor: anInteger
		" Private "
    | gap leftOffset |
    ^[ :box |
        gap := self horizontalGap.
        leftOffset := self pushButtonWidth + gap * ( anInteger - 1 ).
        (( box leftTop rightAndDown: self leftTop ) right: leftOffset )
			extentFromLeftTop: self pushButtonExtent ]!  
editIcon
        " Private - edit the icon "

    
    newValue := oldValue clone.
    PARTSIconEditor new
        partWrapper: self part partWrapper;
        openOn: newValue saveBlock: [
            controls contents: newValue.
            self setModified: true]!   
cancelChanges
        " Cancel the changes made by the receiver.
        Delete all parts and links created in the workbench. "

    self partEditor
        removeLinks: links;
        removeComponents: parts.!  
setStyle: aStyleDict
    "Private - Set the style for the part"

    part
        partPropertySetStyle: ( aStyleDict at: #style );
        partPropertySetAlternateStyles: aStyleDict!   
validationMessage: aMessage
        " Register the validation message to perform.
        A one-argument message selector will be
        sent to the part with this property unit as
        the argument. "
    validationMessage := aMessage! 
partIcon
        " Private - answer the icon of my part.
        Visual parts generally don't have icon property. "
    ^nil!  
initializeWindow
        " Private - the window has been opened. "
    self disableButtons: (self paneAt: #children)!   
setDragSource: source target: target operations: operations formats: formats
    "Private - set all drag drop parameters for the receiver."

    source
        ifTrue: [self part dragSource: true]
        ifFalse: [self part dragSource: false].
    target
        ifTrue:
            [self part
                dragTargetForFormats: formats operations: operations]
        ifFalse:
            [self part
                dragTarget: false;
                dragTargetFormats: formats;
                dragTargetOperations: operations].! 
setDisableState
        "Private - The window is open.  Set the disable state 
		of the receiver's display items. "

    self disabled ifTrue: [ self checkBoxItem disable ].!
hasSizeChanged
        " Private -  answer whether the size has been changed. "

    ^newSize notNil!  
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog.
        Subclass implementations of this method
        should first send #initializeEventHandlers to super."

    self initializeOkCancelButtons.!
COMMENT
"
A PARTSPropertyColorAndFont property
provides a line of push buttons which open
editors on the foreColor, backColor, and font
properties of a part.
"!
hasOrderedChildrenChanged
        " Private -  answer whether the ordered children have been changed. "

    ^newOrderedChildren notNil!   
validationMessage
        " Private - answer the validation message to perform. "
    validationMessage isSymbol
        ifTrue: [^Message new
            receiver: self part
            selector: validationMessage
            arguments: (Array with: self) ].
    ^validationMessage!
entryFieldFrameExtent
        "Private - answer the default extent
        of an entry field."
    ^self entryFieldFrameWidth @ self entryFieldFrameHeight!
eventTable
        "Private - answer a Dictionary mapping event names to actions
        for the receiver."

    ^eventTable isNil
        ifTrue: [ self eventTableCreate ]
        ifFalse: [ eventTable ]!   
partAllImplementedFormats
    "Public - answer an array of all implemented drag drop formats."

    ^#('object' 'string' 'bitmap' 'metafile').    !
partFont
        " Private - answer the part's font.
        Use the value of the first part in the collection. "

    ^self part first font! 
partIcon
        " Private - answer the icon of the part. "

    self implementedBySubclass!   
createViewOn: aString label: aLabelString
        " Private - create the view "

    | unit gap topPane aTextPane |
    unit := self class entryHeight.
    gap := WindowDialog dialogUnit x.
    self addView: (
        ( topPane := self topPaneClass new )
            owner: self;
            labelWithoutPrefix: aLabelString;
            yourself ).
    topPane
        addSubpane: ( ( aTextPane := TextPaneControl new )
            owner: self;
            enableWordWrap;
            addStyle: WsPaneBorder;
            addStyle: MlsAcceptEnterKey;
            contents: aString;
            framingBlock: [ :b |
                (b leftTop rightAndDown: unit // 3)
                    rightBottom: ((b rightBottom up: unit * 2)
                        left: unit // 3)]);
        addSubpane: ( Button new
            owner: self;
            label: 'OK';
            when: #clicked 
                send: #ok: to: self with: aTextPane;
            framingBlock: [ :b |
                (b left right: gap) @ (b bottom up: self class entryHeight // 2)
                    extentFromLeftBottom: unit * 5 @ (unit )]);
        addSubpane: (Button new
            owner: self;
            label: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b |
                (b left right: gap * 2 + (unit * 5)) @ (b bottom up: self class entryHeight // 2)
                    extentFromLeftBottom: unit * 5 @ (unit )]).!  
editGraphic
    ^#( 'Edit graphic...' #partPropertyEditGraphic: )!   
horizontalGap
        "Answer the horizontal distance
        between controls."
    ^PARTSDialog horizontalDialogBaseUnit!
defaultLabelPosition
        " Answer the default position of a label item. "
    ^#left!   
verticalGapAfterStyles
        "Private - answer the vertical distance between
        the bottom of the style box to the top of the control
        below it."
    ^self gapY * 2!   
fromPartFile: aPartFileName
    name: aName
    extent: aPoint
    staticTextLabel: labelString
    partEvent: aPartEvent
    partMessage: aPartMessage
    sourceEvent: aSourceEvent
    sourceMessage: aSourceMessage
        " Answer a new item for the PARTS form generator.
        If the specified part file is not found, substitute an EntryField.
        <aPartName> is the part name of the part.
        <aPoint> is used if this is a visual part.
        If <labelString> is specified a StaticText label will
        be placed to the left of the part. "

    ^self
        fromPartFile: aPartFileName
        name: aName
        extent: aPoint
        staticTextLabel: labelString
        partEvent: aPartEvent
        partMessage: aPartMessage
        sourceEvent: aSourceEvent
        sourceMessage: aSourceMessage
        ifAbsent: [
            self
                warningNotFound: aPartFileName
                for: name
                substitute: 'an EntryField'.
            PARTSEntryFieldPart new ]!
okButtonFrame: aRectangle
        "Answer the rectangle of the OK button."
    ^(aRectangle leftBottom rightAndUp:
        WindowDialog entryHeight * 2 // 3)
            extentFromLeftBottom:
                (self commonExtent: aRectangle)! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
havePropertiesChanged
        " Private - answer whether any of the properties have been changed.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #havePropertiesChanged to super."

    ^self hasNameChanged
        or: [self hasIconChanged]!   
height
		" Private - answer the height of the property unit. "

    ^self extent y!
fontButton
        " Private - answer the Font... button in the dialog window. "

    ^self partNamed: 'FontButton'!   
addToStyle: aDictionary
        " Private - update the style value <anInteger> with
        the receiver's style value and answer the new style.
        Default is to do nothing.  Must be reimplemented by
        property units which represent style bits. "

    ^aDictionary!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties.  A property structure
        automatically includes a property unit for the part name. "

    ^( PARTSPropertyStructure on: self )
        putProperty: self partPropertyEditIcon;
        putProperty: #( #interface )!  
changed
    "Private"

    self triggerEvent: #changed: with: commonFramer.
! 
height
		" Private - answer the height of the property unit. "

    ^self checkBoxHeight!  
changeSelector
		" Answer the selector to send to the property owner
		when a changed value is to be applied. "

    ^changeSelector! 
addAction: aMessage undo: undoMessage
		" Append the action <aMessage> to the receiver's
		action list.  Append a corresponding undo action
		<undoMessage> to the undo list. "

    actions addLast: aMessage.
    undoActions addLast: undoMessage.!  
generatePartsFor: aCreatorPart fromDialog: aDialogWindow
        "Automatically create some parts and add them to the
        workbench where the user clicks.  The creatorPart is the
        part which has the knowledge of what to create.
        The creatorPart needs to implement two methods:
            partFormGeneratorNames
                Answer a collection containing the names of
                parts which the creators proposes to generate.
            partFormGeneratorItemsFor: partNames
                Answer a OrderedCollection of PARTSFormGeneratorItem
                representing the specified partNames.
        aDialogWindow is the dialogWindow from which the
        part generation is initiated.
        Answer whether any parts were created. "

    creatorPart := aCreatorPart.
    partEditor := creatorPart partEditor.
    dialogWindow := aDialogWindow.
    self generateParts.
    dialogWindow := nil.
    ^self createdParts!  
layoutVerticalGroupClass
        " Private - answer the class which represents a vertical group in a form. "

    ^LayoutVerticalGroupClass!   
createPartsWith: aFormGenerator
        " Private "

    aFormGenerator
        title: 'Table Column Layout';
        mouseTrackIcon: ( PARTSFile iconFromFile: 'TABLEPAN.PAR'
            ifNone: [ PARTSApplication defaultIcon ] );
        getNamesAction: [ self part partTableGeneratorNames ];
        getItemsAction: [ :selectedNames |
            Array
                with: ( self part partTableGeneratorItemFor: selectedNames) ];
        generatePartsFor: self part
            fromDialog: self dialogWindow.! 
extent
		" Private - answer the extent of the receiver. "

    extent isNil
        ifTrue: [ extent := self computeExtent ].
	^extent!  
twoDigitYearClicked: aButtonLabel
    " Private - the two digit year option has been selected.
       Set twoDigitYear to true and update
       the sample and contents entryfields. "
    newValue at: 'twoDigitYear' put: true.
    self contentsPane
        twoDigitYear: true;
        modified: true.
    self sampleUpdate.!  
setLeftValue: aValue
    "Private"
    | left |

    aValue isNil ifTrue: [ ^self ].

    left := aValue asNumber.
    framers do: [ :aFramer | aFramer left: left ].
    self updateCommonFramer.
! 
setDisableState
        "Private - The window is open.  Set the disable state 
		of the receiver's display items. "

    self disabled ifTrue: [ self pushButton disable ].!  
adjustPartBorderBy: aPoint
        " Adjust the amount of border area around the part by aPoint.
        A positive x or y value increases the margin area,
        while a negative value decreases the margin. "
    self partItem extent: ( self partItem extent + aPoint )!   
setHCenterValue: aValue
    "Private"
    | hCenter |

    aValue isNil ifTrue: [ ^self ].

    hCenter := aValue asNumber.
    framers do: [ :aFramer | aFramer left: hCenter ].
    self updateCommonFramer.
! 
pushButtonHeight
        "Answer the height of an standard push button."
    ^PARTSDialog standardEntryHeight + 2!  
clickedRemove
        " Private - remove the selected element. "
    oc removeIndex: listBox selectedIndex.
    itemField contents: String new.
    listBox update.
    modified:= true.
    self disableItems! 
height
		" Private - answer the height of the property unit. "

    ^self pushButtonHeight!
clickedSelector: aSymbol
        " Register the one-argument message selector
        to be invoked when this property button is pressed. "
    clickedSelector := aSymbol.!   
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^Set new
        add: #aboutToAcceptChanges: ;
        add: #aboutToEdit ;
        add: #cancelled ;
        add: #closed ;
        add: #editDone ;
        add: #opened ;
        yourself!   
labelFramingBlock
		" Private "

    ^[ :box | ( box leftTop rightAndDown: self leftTop )
        extentFromLeftTop: self extent x @ self entryFieldHeight ]! 
leftButton1Frame: aRectangle withVerticalUnit: aNumber
        " Return the framing rectangle for the first column left
          buttons used by the editor (ie. 'Ok' button)."
    | extentUnit |
    extentUnit:= self extentUnit: aRectangle.
    ^ (aRectangle left right: self gap) @ (aRectangle bottom up: aNumber ) extentFromLeftBottom:
                    extentUnit x - self gap // 2 @ extentUnit y! 
doChanges
		" Private - apply the value if it has been changed. "

    | part |
    part := self part.
    changeSelector isNil
        ifTrue: [
            1 to: labelsMap size do: [ :i |
                ( controls at: i ) selection
                    ifTrue: [
                        ^i = initialSelection
                            ifFalse: [ part perform: ( labelsMap at: i ) last ] ] ] ]
        ifFalse: [
            1 to: labelsMap size do: [ :i |
                ( controls at: i ) selection
                    ifTrue: [
                        ^i = initialSelection
                            ifFalse: [ part perform: changeSelector with: ( labelsMap at: i ) last ] ] ] ]! 
setHeightValue: aValue
    "Private"
    | height |

    aValue isNil ifTrue: [ ^nil ].

    height := aValue asNumber.
    framers do: [ :aFramer |
        aFramer isBottomInset
            ifTrue: [ aFramer top: height ]
            ifFalse: [ aFramer bottom: height ]].
    self updateCommonFramer.
!   
lineHeight
        " Private "
    ^WindowDialog charHeight!
COMMENT
"
A PARTSPropertyUnit is used as an element in a 
PARTSPropertyStructure to represent a part property value.
A property unit is typically a simple item, such as a string,
a boolean, or a collection of choices presented as a list or a 
set of radio buttons.  A property unit is responsible for rendering
the property value given to it by a client part when the properties 
are displayed in a property edit dialog and recording whether
the user has changed the property to a new value.

Most simple property units support a label, which is set when 
the property unit is created using the #label: message. 
Almost all properties manage a value, which is set when the 
property unit is created by sending the #value: message.
The final property value when the dialog is closed can be
obtained using the #newValue message.

In most cases, the creator of a property unit specifies how
the value is to be applied to the part by registering a
#changedSelector: to send to the property owner
when the property dialog is closed and property value changes
need to be applied to the part.  Where appropriate, a
validation handler can be registered for a property unit
to indicate whether a value is acceptable.  Changes are
applied only when the value is accepted by any validation
checking provided by both the property unit and the owner
of the property.
"!  
openOn: aPartPropertyStructure
        " Open a dialog which displays the properties
        in <aPartPropertyStructure>.   Answer a PARTSException
		if the dialog is cancelled by the user. "

    properties := aPartPropertyStructure.
    properties dialog: self.
    actions := OrderedCollection new.
    object := properties part.
    self
        layout;
        createView;
        openWindow.    "hitting the cancel button will
                    set object to be a PARTSException."
    ^object!   
leftMargin
        " Private - answer the width of the left margin "
    ^PARTSPropertyUnit horizontalGap!  
doChanges
		" Private - apply the value if it has been changed. 
		Do nothing (changes are applied by actions registered
		in the button handlers). "! 
listSelect: selectedItem
        " Private - a key was selected in the list. "
    keyField contents: selectedItem.
    valueField contents: (dictionary at: selectedItem) asString!   
partEditValue
        "Open a window to edit the receiver.
        Answer the new value (a PARTSException if cancelled)."
    ^PARTSOrderedCollectionEditor new openOn: self copy! 
at: propertyNameOrIndex putProperty: aProperty
        " Add a property unit to the receiver. "

    | aPropertyUnit |
    aPropertyUnit := ( ( aProperty isKindOf: PARTSPropertyUnit )
        ifTrue: [ aProperty ]
        ifFalse: [ PARTSPropertyLineOfButtons forShorthandItems: aProperty ] ).
    propertyUnits at: propertyNameOrIndex put: aPropertyUnit.
    unitOrdering addLast: propertyNameOrIndex.
    aPropertyUnit propertyStructure: self!
COMMENT
"
A PARTSPropertyWindowStyle represents a window style as
a boolean value which is displayed using a check box item.
All window style items are presented in a single group
in the property dialog of a visual part.  The apply logic
for style properties which are bit settings in a style value
is handled specially, by accumulating the style bits of
all style items in the property structure into a single style 
setting value for the part.
"!
nextId
        "Private - Answer an Integer which will be used as the
        key of an entry which need not be named.  Use negative
        numbers;, positive number are reserved for the user."

    ^nextId := nextId isNil
        ifTrue: [ -1 ]
        ifFalse: [ nextId - 1 ]!
getNamesAction: aZeroArgumentAction
        " Specify the action to evaluate to get the
        list of form item names. "

    getNamesAction := aZeroArgumentAction!
textEntryItem: aPane
        " Set the pane containing the string value. "

    self controls: aPane.! 
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        non-visual part. "

    ^'PpNnvPrt.par'!  
sizeFieldFrame: aRectangle
    ^((aRectangle leftTop right: (aRectangle width // 2) + self unit)
        down: self verticalSpacing * 3)
            extentFromLeftTop: (self textExtent: aRectangle)! 
cancel
        " Private - the Cancel button was pressed. "

    object := PARTSException new.
    properties dialogClickedCancel.
    self close.!  
initialize
        " Private "

    title := 'Form Item Layout'.
    links := OrderedCollection new.
    parts := OrderedCollection new.!
partExtent
        " Answer the extent of the part being created
        for the label.  This value does not include the margin. "

    ^self partItem itemExtent!
editDescription
    ^#( 'Description...' #partPropertyEditDescription: )!
removeAllButton
        " Private "
    ^self paneAt: self removeAllButtonName! 
framers: aCollection
    "Private"

    framers := aCollection.
    self updateCommonFramer.

! 
tabMarker
        "Private - Answer the string which is used to
        indicate to the user that a child has tabstop set."
    ^'* '! 
rightFieldsFrame: aRectangle withVerticalUnit: aNumber
        " Return the framing rectangle of the StaticText and EntryField panes used
          on the right side of the editor "
    | rightsLeft extentUnit |
    rightsLeft:= self rightsLeft: aRectangle.
    extentUnit:= self extentUnit: aRectangle.
   ^rightsLeft @ ( aRectangle top down: aNumber )
                extentFromLeftBottom: extentUnit!
staticTextItem
		" Private "

	^self controls! 
partBackColor
        " Private - answer the part's background color value. "

    ^self part backColor!   
rightBottom
        " Private - answer the rightBottom of the receiver. "

    ^leftTop + self extent! 
part: aPart
        " Private - set the part which owns these properties. "

    part := aPart.
    editor := part partEditor.
    self addPartNameProperty.!
dialogWindow
        " Answer the dialog window which is displaying
        these properties. "

    | dialogWindow |
    dialogWindow := dialog mainView.
    ^dialogWindow isValid
        ifTrue: [ dialogWindow ]
        ifFalse: [ nil ]!   
COMMENT
"
A PARTSPropertyList property presents
an editable list of choices in a list pane.
"!
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self labelWidth + self entryFieldWidth!   
COMMENT
"
This class provides the property dialog framework code
needed to support an 'Order children...' edit button in a
property dialog.  This is primarily useful for a top-level
Window part.
"!   
COMMENT
"
A PARTSPropertyStaticText presents an text string
which cannot be edited by the user in a static text item.
"!  
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

	self implementedBySubclass!   
framingBlock
		" Private - answer the framing block for the receiver's list pane."
    ^[ :box | (( box leftTop rightAndDown: self leftTop ) down: self entryFieldHeight + self verticalGap )
        extentFromLeftTop: self extent x @ ( self extent y - self entryFieldHeight - ( self verticalGap * 2 )) ]!
dialogClickedCancel
        " The dialog is closing after user pressed Cancel. "
    self cancelChanges.!   
COMMENT

"
PARTSPartPropertyDialog is an abstract superclass
which can be subclassed to implement hybrid
part property dialogs.   PARTSPartPropertyDialog
implements standard services for accessing, editing,
and updating such common properties as part name,
nonvisual part icon, and visual part window size.

PARTSPartPropertyDialog has two subclasses:

1) PARTSNonvisualPartPropertyDialog - abstract superclass
        for nonvisual part property dialogs - supports icon property.
2) PARTSVisualPartPropertyDialog - abstract superclass
        for visual part property dialogs - supports window size
        and color/font properties.

If your property dialog contains buttons which open subdialogs,
you may also wish to create a subclass of PARTSPartPropertySubdialog,
generic superclass for property subdialogs classes.

After subclassing the appropriate one of the classes you need
to implement a small number of methods.  Most of these methods
are already implemented in the superclass, where most of the
work common to all properties dialogs are already done.   In your
implementation of these methods you will often need to send a super
first, then perform tasks specific to your property dialog.

Here is a list of the methods you may need to implement, in the order
that they will be sent:

    fileName
         Private - Answer the name of the part file
        containing the property dialog.
        If no extension is given, open editable .par
        file; if not found, open non-editable .exe part.

    initializeValues
         Private - initialize instance variables.
        You will often want to send this message to super first.
        This method is often not needed.

    initializeParts
        Private - Initialize the items in the property dialog application to
        their current values of the part.  Also register any event handlers.
        You should usually send this message to super first.

    dialogWindowName
        Private - Answer the part name of the main dialog window
        inside the part file implementing the property dialog.  This part will be
        sent the message #open to open the property dialog.

    havePropertiesChanged
        Private - This message is sent when the user clicks on the OK
        button.  Answer true if the user has changed any of the items
        in the property dialog.
        You should usually send this message to super first.

    arePropertiesValid
        Private - Answer true if the new values for all the properties
        are acceptable.
        You should usually send this message to super first.

    constructApplyActions
        Private - Construct a sequence of actions which
            apply the new values that the user has specified to
            the part.  Also construct a parallel sequence of
            actions to undo the changes if undo/redo is supported.
        You should usually send this message to super first.

    supportsUndoRedo
        Private - Answer whether undo/redo action sequences
            have been constructed which can be registered
            with the workbench to undo/redo the property changes.
            If false, a NOP is registered which disables undo.

    cancelChanges
        Private - The user has canceled the property changes, so
        backout any changes already made.  Normally, no changes
        are applied by this point, so there is nothing to do.

    partHasDynamicMessages
        Private - answer true if the property values of your part
            can cause changes in its event or message interface.
            This is the case if your part supports dynamic messages
            (e.g., a data-containing part such a CStructure or
            BtrieveAccessor whose interface supports field access
            messages and events).

"!   
warningNotFound: aPartFileName for: itemName substitute: substituteName
        " Post a standard warning message describing
        the action being taken for a missing entry part. "
    MessageBox
        notify: 'PARTS Form Generation Problem'
        withText:
            'Form item 'itemName,' will use ',
            substituteName, ' as a substitute.'.!  
stretchedAll
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer
            useAllStretched;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.
    self changed
!
isStyle
        "Answer whether the receiver represents a window style. "

    ^true!  
entryFieldFrameWidth
        "Private - answer the default width
        of an entry field."
    ^self entryFieldWidth - 8!
doStyleChanges
            " Private - apply style changes. "

    ( oldStyle := part partPropertyStyle ) isDictionary
        ifFalse: [ "Backward compatibility"
            oldStyle :=
                Dictionary new
                    at: #style put: oldStyle;
                    yourself ].
    newStyle := oldStyle deepCopy.
    self propertiesDo: [ :p |
        newStyle := p addToStyle: newStyle ].

    self styleChanged
        ifTrue: [ self setStyle: newStyle ]
!
spinButtonSetMaster
    ^#( 'Set master...' #partPropertySetMaster: )!   
labelWidth
		" Private "

    
    self label size = 0 ifTrue: [ ^0 ].
    ^PARTSDialog horizontalDialogUnitsFromPixels: (self font stringWidth: self label, 'XXxiX')!   
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^self applyForeColorCheckBox value
        or: [ self applyBackColorCheckBox value
        or: [ self applyFontCheckBox value
        or: [ self applySizeCheckBox value ] ] ]!
computeWidth
        "Private - compute and answer the width of the receiver."

    ^88!   
contents: aString
		" Set the current contents of the text entry item. "

	self textEntryItem
		setValue: aString;
		modified: true! 
parentRect: aRect
    "Private - Set the parent area in which the parts
    are being edited."

    parentRect := aRect
!
ok: aTextPane
        " Private - the OK button was pressed "

    answer := ( aTextPane modified
        ifTrue: [ aTextPane contents ]
        ifFalse: [ nil ] ).
    self close.!   
editBackColor
        " Private - open the color edit dialog on the backColor. "
    | newColor |
    newColor := ColorDialog new
        openOn: self currentBackColor;
        chosen.
	" If the user hits cancel, chosen answers nil."
	newColor isNil
		ifFalse: [newBackColor := newColor]!  
hasFontChanged
        " Private -  answer whether the font has been changed. "

    ^newFont notNil!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Do nothing for an icon. "!
checkBoxItem
		" Private - answer the check box representing the value. "

	^self controls!
addToWindow: aTopPane
		" Private - create a push button in <aTopPane> to represent
		the receiver's operation. "

	| aPushButton |
    aTopPane addSubpane: ( ( aPushButton := Button new )
        font: self font;
        owner: self;
        label: label;
        when: #clicked send: #clicked to: self ;
        framingBlock: self framingBlock;
		yourself ).
	self controls: aPushButton.!
computeHeight
        "Private - compute and answer the height of the receiver."

    ^self height!
reportProblemIn: anItemName message: messageString
        " Private - report a problem with the value provided for
        the property named anItemName. "

    MessageBox
        notify: 'Property Problem - ', anItemName
        withText: messageString.!
editBackColor
        " Private - open the color edit dialog on the backcolor.
        Set the apply check box if changed. "

    super editBackColor.
	self hasBackColorChanged
        ifTrue: [ self applyBackColorCheckBox setValue: true ].!   
makeSameLine
        " Specify that the receiver should be rendered on
        the same line as the preceding property unit
        in the containing property structure. "

    sameLine := true.!  
COMMENT
"
A PARTSPropertyStructure is an ordered collection
of part property units describing properties of a
part.  A property structure triggers events corresponding
to interesting occurences in the life cycle of a part property dialog
when the property structure is in use by a property dialog.

Property units in a property structure are an ordered collection.
Rendering and processing of the property units by default
is done according to the order in which they are added to
the structure.  Property units can be named if the client
needs to access them after the initial construction of the
property structure collection.  This is generally done
when the client registers event handlers on the structure.

A property structure is always initialized with the standard
part name property.
"!
enable
		" Enable the buttons. "

    super enable.
    controls do: [ :control | control enable ]!   
rectangleIn: parentRect
        " Private - answer the bounding rectangle of the receiver
        relative to <parentRect>. "

    ^( parentRect leftTop rightAndDown: leftTop )
        extentFromLeftTop: extent!  
dialogWindow
        " Answer the dialog window containing the receiver. "
    ^self propertyStructure dialogWindow!
setTop: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer
            useTopInset;
            useTopStretched: proportional;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.

    self commonVerticalScaleMask
        ifFalse: [
            "Bottom attributes are not common. Make them common.
                Changing to height, won't remove isTop attribute"
            self setHeight: framers first isBottomStretched ].

    self changedVertically
!   
dialogClickedOK
		" The OK button in the dialog has been pressed.
		Answer whether the property changes have
		been successfully applied. "

    self canDoChanges 
		ifFalse: [ ^false ].
    self doChanges; registerUndoRedo.
    ^true!   
editWindowSize
        " Private - open the window Size subdialog. "

    | currentSize |
    currentSize := ( newSize notNil
        ifTrue: [ newSize ]
        ifFalse: [ self partSize ] ).
    currentSize := self newSize: currentSize.
    currentSize isNil ifTrue: [ ^self ].  " cancelled or no change "
    newSize := currentSize.!  
partEditor
        " Private - answer the editor of the part. "

    ^self part first partEditor!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^labelsAndSelectors size * ( self pushButtonWidth + self horizontalGap ) - self horizontalGap! 
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | valueExtent |
    valueExtent := oldValue extent * 2 // 3.
    aTopPane
        addSubpane: ( controls := ( PARTSStaticGraphicPart icon: oldValue "clone" )
            framingBlock: [ :b | ( b leftTop rightAndDown: leftTop )
                extentFromLeftTop: self iconExtent ] );
        addSubpane: ( Button new
            owner: self;
            font: self font;
            label: 'Edit icon...';
            when: #clicked send: #editIcon to: self;
            framingBlock: [ :b | (( b leftTop rightAndDown: leftTop + self iconExtent )
                right: self horizontalGap ) extentFromLeftBottom: self pushButtonExtent ] )! 
labelPosition
        " Answer the position of the StaticText label
        relative to the value-containing part. "
    ^labelPosition!   
setHCenter: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect rounded: false.
        aFramer
            useCenterWidth;
            useLeftStretched: proportional;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.
    "self ASSERT: self commonHorizontalScaleMask = true"

    self changedHorizontally
! 
gap
        "Answer a value to be used as a factor in the layout of the receiver."
    ^WindowDialog dialogUnit x!  
newPartName
        " Private - answer the new value of the part's name "

    ^self partNameEntryField value trimBlanks!  
sourceEvent: aSymbol
        "Private - sourceEvent is a Symbol which is the event
        for the link from the source part to the part."
    ^sourceEvent := aSymbol!
partContents
        "Answer the contents of the receiver."
    ^self contents! 
initWindowSize
        " Answer the initial window extent of the client
        area in dialog box units. "
    ^clientExtentDlg!  
COMMENT
"
A PARTSSimpleTextEditor is an editor dialog for
a multi-line text string.
"!
entryFrameIn: parentRect
        " Private "
    | left top labelHeight |
    labelHeight := self label isNil
    ifTrue: [0]
    ifFalse: [self lineHeight].
    left := parentRect left right: self leftTop x.
    top := (parentRect top down: self leftTop y)
        down: (labelHeight + self textMargin).
    ^left @ top extentFromLeftTop: textExtent!  
useSystemFormat: aValue
        "Private - the 'use system format' box has been selected.
         Store the pane's value (true/false) into newValue. "
    newValue at: 'useSystemFormat' put: aValue.
   self contentsPane
        useSystemFormat: aValue;
        modified: true.
    self
        disableItems;
        sampleUpdate.!  
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self labelWidth max: self pushButtonWidth!
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #initializePartValues to super."!
controls
		" Private - answer the controls used to render the
		the receiver's value. "

    ^controls!   
doChanges
		" Private - apply the value if it has been changed.
        Do nothing for a window style, which is applied specially
		through #addStyle: "

    "Do nothing (property dialog will call addToStyle):
   1 to: labelsMap size do: [ :i |
        (controls at: i) selection
            ifTrue: [self part addStyle: (labelsMap at: i) last]
            ifFalse: [self part removeStyle: (labelsMap at: i) last]].
    "!  
height
		" Private - answer the height of the property unit. "

    ^self entryFieldHeight!
layoutHorizontalGroupClass
        " Private - answer the class which represents a horizontal group in a form. "

    ^LayoutHorizontalGroupClass! 
clickedRemove
        " Private - remove the selected key from the dictionary."
    dictionary removeKey: keyField contents ifAbsent: [^Terminal bell].
    keyField contents: String new.
    valueField contents: String new.
    listBox update.
    modified := true.!  
editForeColor
        " Private - open the color edit dialog on the forecolor.
        Set the apply check box if changed. "

    super editForeColor.
	self hasForeColorChanged
        ifTrue: [ self applyForeColorCheckBox setValue: true ].!   
close
        "Private - Close the window."

    self dialogWindow close.! 
clickedRemoveAll
        " Private - empty the collection. "
    (MessageBox confirm: 'Remove all entries - are you sure?')
        ifTrue: [oc removeAll].
    itemField contents: String new.
    listBox update.
    modified := true.
    self disableItems!   
object: anObject
		" Set the object associated with the properties. "

    object := anObject! 
layoutStylesFrom: firstStyle to: lastStyle
        "Private - layout the units associated with a window style
        and compute the size of the style box."

    | prev leftMargin col2Left myExtent |
    stylesLeftTop := self leftMargin @ (extentFromLeftTop y + self gapY).
    myExtent := stylesLeftTop copy.
    leftMargin := stylesLeftTop x + self gapX.
    properties from: firstStyle to: lastStyle do: [ :p |
        p column = 1 ifTrue: [
            prev isNil
                ifTrue: [p leftTop:
                    stylesLeftTop + ( self gapX @ self firstStyleVerticalGap )]
                ifFalse: [
                    p sameLine
                        ifTrue: [p leftBottom: (prev rightBottom + (self gapX @ 0))]
                        ifFalse: [p leftTop: leftMargin @ (prev bottom + self gapY)]].
            extentFromLeftTop := extentFromLeftTop max: p rightBottom.
            myExtent := myExtent max: p rightBottom.
            prev := p]].
    col2Left := myExtent x + self gapX.
    prev := nil.
    properties from: firstStyle to: lastStyle do: [ :p |
        p column = 2 ifTrue: [
            prev isNil
                ifTrue: [ p leftTop:
                    col2Left @ ( stylesLeftTop y + ( self gapY * 5 ) )]
                ifFalse: [
                    p leftTop: col2Left @ (prev bottom + self gapY ) ].
            extentFromLeftTop := extentFromLeftTop max: p rightBottom.
            prev := p ]].
    stylesRightBottom := extentFromLeftTop + ( self gapX @ self lastStyleVerticalGap ).
    extentFromLeftTop y: (extentFromLeftTop y + (self gapY ))!   
dateSeparator
    " Private - Return the current date separator specified in the property dialog. "
    | newDateSeparator |
    newDateSeparator := newValue at: 'dateSeparator'.
    ^( (newValue at: 'useSystemFormat') or: [newDateSeparator isEmpty] )
        ifTrue: [ NationalLanguage dateSeparator ]
        ifFalse: [ newDateSeparator ].!  
COMMENT
"
A PARTSPropertyString renders an editable text string property
in a single-line entry field.
"! 
propertyAt: anObject
		" Answer the property named <anObject>. "

    ^self propertyAt: anObject 
		ifAbsent: [ self error: 'Property not found' ]!   
sizeButtonFrame: aRectangle
    ^((aRectangle leftTop right: aRectangle width // 2 + (self unit * 2))
        down: self verticalSpacing * 4)
            extentFromLeftTop: (self commonExtent: aRectangle)!  
setBackColor
    ^#( 'Backcolor...' #partPropertySelectBackColor: )! 
editWindowSize
        " Private - open the size edit dialog on the font.
        Set the apply check box if changed. "

    super editWindowSize notNil
        ifTrue: [ self applySizeCheckBox setValue: true ].! 
currentBackColor
        " Private- Answer the current backColor selected. "
    ^currentBackColor == #uninitialized
		ifTrue: [self part backColor]
		ifFalse: [currentBackColor ]!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Append <aString>
        after every new line. "

    self label isNil ifTrue: [ ^self ].
    aStream
        nextPutAll: aString;
        nextPutAll: self label;
        cr! 
editIcon
        " Private - open an Icon editor on the part's icon "

    | newIcon |
    newIcon := ( self newPartIcon notNil
        ifTrue: [self newPartIcon]
        ifFalse: [self partIcon] )
            clone.
    self
        partEditIcon: newIcon
        saveBlock: [
            self newPartIcon: newIcon.
            self iconStaticGraphic value: newIcon ].! 
initialize
        " Private "

    modified := false.
    enabled := true.
    sameLine := false.!  
labelWithoutTabMarker: label
        "Private -."
    ^label first == $*
        ifTrue: [label copyFrom: 3 to: label size]
        ifFalse: [label]! 
listPaneName
        " Private "
    ^'fieldList'!  
partProperties
        " Private - answer a PARTS property structure containing
        the minimal properties that all visual parts have."

    | aPropertyStructure |

    aPropertyStructure:= PARTSPropertyStructure on: self.
    self partPropertyAddColorAndFont: aPropertyStructure.
    aPropertyStructure
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!  
listContents: aListPane
		" Private - set the contents of <aListPane>. "

    aListPane contents: (newValue isNil
        ifTrue: [Array new]
        ifFalse: [newValue copy])! 
forShorthandItems: anIndexedCollection
        " Answer a property unit containing a line of edit buttons. "
    | labelsAndSelectors |
    labelsAndSelectors := Array new: anIndexedCollection size.
    1 to: labelsAndSelectors size do: [ :i |
        labelsAndSelectors
            at: i
            put: (self perform: (anIndexedCollection at: i)) ].
    ^self new labelsAndSelectors: labelsAndSelectors!
partEditor
        " Private - answer the editor of the part. "

    ^self part partEditor!
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
actions: anArray
    actions := anArray! 
COMMENT
"
A PARTSPropertyButton provides a push button element
in a property dialog.  This class should only be used
for a push button which invokes an operation on the
property dialog itself.  A push button which opens a
subdialog should be implemented using a PARTSPropertyEditButton,
which manages the value operated on by the subdialog.

When a push button property is created, send the #label:
message to specify the button label.  Send the
#clickedSelector: message to specify the message
to send to the part when the button is pressed by the user.
"!
leftTop
        " Private - answer the leftTop position of the receiver. "

    ^leftTop!  
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [ self hasOrderedChildrenChanged ]! 
font
		" Private - answer the font to use for the receiver's items. "

    ^PARTSSettings current fontDialogs! 
enable
    " Enable the boolean item. "

    super enable.
    self checkBoxItem enable.! 
scaleUnit: aUnit
    "Private"

    framers do: [ :aFramer |
        aFramer scaleUnit ~= aUnit asSymbol
            ifTrue: [ aFramer scaleUnit: aUnit ]].

    self updateCommonFramer.
    self changed
! 
removeButtonName
        " Private "
    ^'removeButton'!   
openOn: aString label: aLabelString
        " Open an editor dialog on <aString>, with <aLabelString>
        used in the window title bar. "

    self
        createViewOn: aString label: aLabelString;
        openWindow.
    ^answer!
currentForeColor
    " Return the foreColor selected in the dialog.
      If a foreColor has never been selected, return the part's foreColor. "
	^newForeColor == #uninitialized
        ifTrue: [self partForeColor ]
		ifFalse: [newForeColor]!   
adjustLabelBorderBy: aPoint
        " Adjust the amount of border area around the label by aPoint.
        A positive x or y value increases the margin area,
        while a negative value decreases the margin. "
    self labelItem extent: ( self labelItem extent + aPoint )!   
openOn: anArray
    array := anArray copy.
    answer := PARTSException new.
    self
        createView;
        openWindow.
    ^answer!  
getPartsListDialog
        " Answer a dialog which returns a list of parts
        when sent #openOn:title: "

    ^PARTSFieldOrderDialog new!
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Append <aString>
        after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: label;
        nextPutAll: ': '; cr.
    oldValue do: [ :s |
        aStream
            nextPutAll: aString;
            nextPutAll: '  ';
            nextPutAll: s printString;
            cr ].!  
doChanges
		" Private - apply the property changes. "

    operation := #doChanges.
    self triggerEvent: #aboutToEdit.
    self propertiesDo: [ :p | p doChanges ].
    ( part isKindOf: Window )  " don't use isWindow here in case part is shrunken visual part "
        ifTrue: [ self doStyleChanges ].
    actions do: [ :m | m perform ].
    self triggerEvent: #editDone.
    operation := nil.! 
pushButtonWidth
        "Answer the default width of all push button controls."
 "   ^WindowDialog entryHeight * 6"
    ^ 68!  
itemFieldFrame: aRectangle
    ^((aRectangle leftTop right: aRectangle width // 2 + (self unit "* 2"))
        down: self unit) extentFromLeftTop:
            (self textExtent: aRectangle)!  
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
textMargin
        " Private "
    ^WindowDialog entryHeight - WindowDialog charHeight! 
width
        " Private - answer the width of the receiver. "

    ^self extent x! 
setTabStop
        "Private - "
    | list item listPane |
    listPane := self paneAt: #children.
    list := listPane contents.
    item := listPane selectedItem.
    list at: (list indexOf: item) put: (self labelWithTabMarker: item).
    listPane contents: list;
        selectItem: (self labelWithTabMarker: item).
    self disableButtons: listPane!
releaseEventTable
        "Private - break all connections to event handlers."

    eventTable := nil.!
startGroup
        "Private -"
    | listPane |
    listPane := self paneAt: #children.
    listPane addSeparator: (listPane selectedIndex) - 1.
    self disableButtons: listPane!  
acceptProperties
        " Private - accept the validated property values. "

    self implementedBySubclass!  
rightsLeft: aRectangle
        " Return the left top unit for the panes on the right side of the editor."
    ^aRectangle left right: aRectangle width // 2 + self gap.!
immediateValidationMessage
		" Answer the to evaluate when the
		focus is lost from the visual item containing
		the receiver's value. "

    ^immediateValidationMessage!   
extentForEntryPart: nChars font: aFont
        " Answer the extent of an entry field which
        will contain nChars characters in aFont. "

    | string |
    string := String new: nChars.
    string atAllPut: $a.    "not M"
    ^( ( aFont stringWidth: string ) + 8 )
        @ ( aFont lineSpacing + 2 )   " form item height should be equivalent to a line "! 
constant: anInteger
		" Specify the bits which are set in a style when
		the window style represented by the receiver is set. "

    constant := anInteger.!  
entryFieldWidth
		" Private "

    ^self numberFieldWidth! 
clicked
        " Private - the button has been pressed "

    | aFormGenerator |
    aFormGenerator := self formGenerator.
    self createPartsWith: aFormGenerator.
    aFormGenerator createdParts
        ifTrue: [
            forms add: aFormGenerator.
            self setModified: true ].!
arePropertiesValid
        " Private - answer whether  the values of the properties are valid.
        If not valid, notify the user of the problem and answer false.
        Should be reimplemented in each subclass which adds property
        items to the dialog.  The subclass implementation of this method
        should first send #arePropertiesValid to super."

    | propertiesAreValid |
    propertiesAreValid := true.

    (self hasNameChanged
    and: [self isNewPartNameValid not])
        ifTrue: [
            self
                reportProblemIn: 'Part Name'
                message:
                    'Cannot accept ''', self newPartName,
                    ''' as the part name (invalid or duplicate name).'.
            propertiesAreValid := false ].
    ^propertiesAreValid!  
setDisableState
        "Private - The window is open.  Set the disable state 
		of the receiver's display items. "

    self disabled ifTrue: [ self disable ].
    self controls do: [ :aRadioButton |
        aRadioButton selection
            ifTrue: [ ^self clicked: aRadioButton ] ]! 
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'ppszwndw.par'! 
hasIconChanged
        " Private -  answer whether the icon has been changed. "

    ^self newPartIcon notNil! 
defaultPartBorder
    " Answer the default extent of the margin area
    placed around a part. "

    ^2 @ 5! 
pushButtonExtent
        "Answer the default extent of the reciever's push button controls."
    ^self pushButtonWidth @ self pushButtonHeight! 
editBitmap
    ^#( 'Edit bitmap...' #partPropertyEditGraphic: )! 
sampleUpdate
    " Update the sample date pane entryfield. "
    (self paneAt: 'samplePane') contents: self createDateString.
    modified:= true.!
undoChanges
        " Private - reset the value if it has been changed. "

    self shouldApplyChange
        ifTrue: [ self part perform: self changeSelector with: self originalValue ]!
operation
        " Answer the current properties operation "

    ^operation! 
validateValueMessage
        " Private - answer the validation message to perform. "

    validateValueMessage isSymbol
        ifTrue: [^Message new
            receiver: self part
            selector: validateValueMessage
            arguments: (Array with: self entryField contents) ].
    ^validateValueMessage!  
staticTextHeight
		"Private - answer the height of the receiver's
		static text controls."
	^self entryFieldFrameHeight!   
ok
        " Private - the OK button was pressed. "
    answer := dictionary.
    self close!  
value: aValue
        "Set the value of the property to <aValue>. "

    oldValue := aValue.!  
partAllImplementedOperations
    "Public - answer an array of all implemented drag drop operations."

    ^#( #move #copy #link )
!   
propertyStructure
        " Answer the property structure containing this unit. "
    ^propertyStructure!   
styleChanged
    "Private - Answer whether a style has changed"
    | modified |

    modified := false.
    newStyle keysAndValuesDo: [ :key :value |
        modified := modified or: [ ( oldStyle at: key ) ~= value ]].
    ^modified! 
title: aString
        " Specify the title for the dialog which allows the user
        to select the list of parts to be created. "

    title := aString.!  
addLabelToWindow: aTopPane
        " Private - add the label item to <aTopPane>. "

    aTopPane addSubpane: ( StaticText leftJustified
        font: self font;
        owner: self;
        contents: self label;
        framingBlock: [ :b | self labelFrameIn: b ] )! 
canDoChanges
        " Private - answer whether the receiver's changes can be applied. "

    ^true!   
initWindowSize
        "Private - "
    ^( 37 @ 15) * WindowDialog unitMultiplier!  
openOn: fieldNames title: title
        " Open a dialog which allows the user to
        specify the order of a set of fields. "
    list := fieldNames.
    self
        createView: title;
        openWindow.
    ^answer!  
changedHorizontally
    "Private"

    self triggerEvent: #changedHorizontally: with: commonFramer.
! 
contents
		" Answer the current contents of the text entry item. "

    ^self textEntryItem value! 
cancelChanges
        " Private - the property edit is being cancelled.  Remove
		the links and parts created by form generation operations. "

    forms notEmpty
        ifTrue: [
            self partEditor selectOffAll.
            forms do: [ :aFormGenerator |
                aFormGenerator cancelChanges ].
            self partEditor select: self part ].!   
useSystemFormat
        "Private - Return true if useSystemFormat is selected; else return false."
    ^newValue at: 'useSystemFormat'! 
label
		" Answer the label of the property unit. "

    ^label!
gapX
    "Private - answer the horizontal gap."

    ^PARTSPropertyUnit horizontalGap! 
propertyStructure: aPropertyStructure
        " Set the property structure containing this unit. "
    propertyStructure := aPropertyStructure.!
addToWindow: aTopPane
		" Private - create a labeled text entry pane in <aTopPane> to represent
		the receiver's value. "

    self
        addEntryFieldToWindow: aTopPane;
        addLabelToWindow: aTopPane!
createDateString
    "Private - using the requirements in the property dialog,
     return a string representing today's date. "
    |  format dateSeparator str|
    (newValue at: 'useSystemFormat')
        ifTrue: [
            format := NationalLanguage dateFormat.
            dateSeparator := NationalLanguage dateSeparator]
        ifFalse: [
            format:= newValue at: 'format'.
            dateSeparator := newValue at: 'dateSeparator'].
    str:= ReadWriteStream on: String new.
    Date today
        printOn: str
        inFormat: format
        twoDigitYear: (newValue at: 'twoDigitYear')
        dateSeparator: dateSeparator.
    ^str contents!  
framingBlock
		" Private "

    ^[ :box | (box leftTop rightAndDown: self leftTop)
        rightBottom: (box right left: self horizontalGap ) @
            (box top down: self leftTop y + self height)]!   
addToWindow: aTopPane
		" Private - create a static text item in <aTopPane> to represent
		the receiver's value. "

	| aStaticText |
    aTopPane addSubpane: ( aStaticText := StaticText new
        font: self font;
        value: self label;
        framingBlock: self framingBlock ).
	self staticTextItem: aStaticText.! 
setHorizontalScaleMask: aHorizontalMask
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer
            scaleMask: ( aFramer scaleMask & 2r00001111 ) | aHorizontalMask;
            changeRectangle: rect relativeTo: parentRect ].

    self changedHorizontally
!   
entryFieldExtent
        "Private - answer the default extent
        of an entry field."
    ^self entryFieldFrameWidth @ self entryFieldHeight!  
doChanges
		" Private - apply the value if it has been changed.
        Do nothing for a window style, which is applied specially
		through #addStyle: "!  
validateComponentName
        " Private - answer whether the part name property is valid. "

    | isValid |
    doingValidation := true.
    isValid := self partNameIsValid.
    doingValidation := false.
    ^isValid! 
textExtent: aRectangle
    ^aRectangle width // 2 - (self unit * 2) @
        self class entryHeight!   
atIndex: anInteger put: aProperty
        " Add a property unit to the receiver at index <anInteger>. "

    self at: ( unitOrdering at: anInteger ) putProperty: aProperty!   
frameExtent
        "Private - answer the extent of the receiver's frame.
        The message #extent is used for layout while
        #frameExtent is used for the actual frame rectangle."
    ^self frameWidth @ self frameHeight! 
createPartsWith: aFormGenerator
        " Private "

    aFormGenerator
        title: 'Form Item Layout';
        generatePartsFor: self part
            fromDialog: self dialogWindow.!  
cancelChanges
        " Private - cancel any changes made to the part. "!
setDragDrop
    "Private - launch a dialog to set drag drop settings for the receiver."

    | app appHolder formats operations newFormats newOperations source target
    newSource newTarget |
    appHolder := PARTSApplicationHolder on: 'dragdrop'.
    app := appHolder application.

    app defaultUnusedFormats: (DragDropObject partAllImplementedFormats
        reject: [ :x | self part partDragTargetFormatsDefault includes: x]).
    app defaultFormats: (self part partDragTargetFormatsDefault).
    app defaultAllOperations: (DragDropObject partAllImplementedOperations).
    app defaultOperations: (self part partDragTargetOperationsDefault).
    app defaultSource: false.
    app defaultTarget: false.

    source := self dragSource.
    newSource := source.
    app source: newSource.
    target := self dragTarget.
    newTarget := target.
    app target: newTarget.
    (formats := self part dragTargetFormats) isNil
        ifTrue: [newFormats := self part partDragTargetFormatsDefault]
        ifFalse: [newFormats := formats].
    app formats: newFormats.
    app unusedFormats: (DragDropObject partAllImplementedFormats reject:
        [ :x | newFormats includes: x]).
    (operations := self part dragTargetOperations) isNil
        ifTrue: [newOperations := self part partDragTargetOperationsDefault]
        ifFalse: [newOperations := operations].
    app
        operations: newOperations
        andAllOperations: (DragDropObject partAllImplementedOperations).

    app open.
    app commitChanges
        ifTrue:
            [newSource := app source.
            newTarget := app target.
            newFormats := app formats.
            newOperations := app operations asArray]
        ifFalse: [^nil].

    self propertyStructure
        addAction: (Message new
            receiver: self;
            selector: #setDragSource:target:operations:formats: ;
            arguments: (Array
                with: newSource with: newTarget with: newOperations with: newFormats))
        undo: (Message new
            receiver: self;
            selector: #setDragSource:target:operations:formats: ;
            arguments: (Array
                with: source with: target with: operations with: formats)).!  
currentFont
        " Private - Answer the current font selected.  If nothing is selected return
          the font of the part being edited. "
    ^currentFont isNil
        ifTrue: [ self part font ]
        ifFalse: [ currentFont ]!  
staticTextLabelExtent
        " Answer the extent of StaticText part being created
        for the label.  This value does not include the margin. "

    ^self labelItem isNil
        ifTrue: [ nil ]
        ifFalse: [ self labelItem itemExtent]!  
generateParts
        " Private - generate the parts selected by the user. "

    | selectedNames dragResult destWindow destRect
      itemsToBeAdded |

    selectedNames := self getPartsListFrom: self getNames.
    selectedNames isNil
        ifTrue: [ ^nil ].

    self partEditor hideDialog: dialogWindow.
    ( dragResult :=
        (( PARTSDragSession
            source: self partEditor workbenchPane )
            icon: self mouseTrackIcon;
            yourself ) doDragDropAt: Cursor sense ) notNil
        ifTrue: [
            destWindow := dragResult destinationWindow.
            ( destWindow partIsWindow not
            or: [ destWindow partEditor ~~ self partEditor ] )
                ifTrue: [  " didn't land on a workbench "
                    self partEditor unhideDialog: dialogWindow.
                    ^nil ].

            destRect := Rectangle
                leftTop: dragResult destinationRectangle leftTop
                rightBottom: destWindow rectangle rightBottom.

            CursorManager execute change.
            itemsToBeAdded := self getItemsFor: selectedNames.
            ( self
                pasteParts: itemsToBeAdded
                in: destWindow
                destRect: destRect ) notNil
            ifTrue: [
                destWindow partEditor == self partEditor
                    ifTrue: [ self createLinks: itemsToBeAdded ]]].

    CursorManager normal change.
    self partEditor unhideDialog: dialogWindow.!
fileName
        " Answer the name of the part file containing
        the property dialog.  If no file type extension
        is specified, open the first file with the given name
        in the PARTS search path.  If multiple types found in 
        the same directory, open editable .PAR if available, 
        else open the executable .PAX file. "

    self implementedBySubclass!  
eventTableForEdit
    "Private"
    "Answer the table of event handlers for the receiver.
    Allocate if necessary so that updates can be stored."

    eventTable isNil
        ifTrue: [ eventTable := self eventTableCreate ].
    ^eventTable!
initialize
        " Private "
    super initialize.
    forms := OrderedCollection new.!  
registerUndoRedoOperations
        " Private - register the undo and redo operations for this
        property edit with the workbench containing the part. "

    self supportsUndoRedo
        ifTrue: [
            self partEditor
                recordUndo: ( Message
                    receiver: undoChangesActions
                    selector: #evaluate )
                undoLabel: 'property changes'
                redo: ( Message
                    receiver: applyChangesActions
                    selector: #evaluate )
                redoLabel: 'property changes'
            ]
        ifFalse: [ self partEditor recordUndoPlaceholder ].!
addToStyle: aDictionary
        " Private - update the style value <anInteger> with
        the receiver's style value and answer the new style. "
    | styleInteger |

    styleInteger := aDictionary at: #style.
    styleInteger := self checkBoxItem value
        ifTrue: [
            ( styleInteger bitAnd: ( constant2 bitXor: 16rFFFFFFFF ) ) | constant ]
        ifFalse: [
            ( styleInteger bitAnd: ( constant bitXor: 16rFFFFFFFF ) ) | constant2 ].
    aDictionary at: #style put: styleInteger.
    ^aDictionary!
defaultEntryPart: aName
    staticTextLabel: labelString
    sourceEvent: aSourceEvent
    sourceMessage: aSourceMessage
        " Answer a new item for the PARTS form generator
        specifying a default text entry part. "

    | anEntryFieldPart |
    ^self new
        part: ( anEntryFieldPart := PARTSEntryFieldPart new )
            name: aName
            extent: anEntryFieldPart partDefaultExtent
            helpInfo: ( Array
                with: 'PARTS.HLP'
                with: 'EntryField' );
        staticTextLabel: labelString;
        partEvent: anEntryFieldPart partNewValueEvent;
        partMessage: anEntryFieldPart partSetValueMessage;
        sourceEvent: aSourceEvent;
        sourceMessage: aSourceMessage;
        yourself!  
interfaceButton
        " Private - answer the Interface... button in the dialog window. "

    ^self partNamed: 'InterfaceButton'!
recyclingThreshold
        " Private - answer the maximum number of used
        instances of the receiver to keep in the recycling bin. "

    ^2!   
layoutManagerClass: aClass
		" Private - specify the class which computes the form layout. "

	LayoutManagerClass := aClass.!  
enabled
		" Answer whether the property unit is enabled. "

    ^enabled!  
clearModified
        " Private - clear the modified flag "

    self setModified: false.! 
defaultLabelBorder
    " Answer the default extent of the margin area
    placed around a label item. "

    ^2 @ 5!  
computeHeight
        "Private - compute and answer the height of the receiver."

    ^self lineHeight + self entryFieldHeight + self textMargin!  
setRight: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer isRightInset not
            ifTrue: [ "right was the width"
                aFramer
                    left: aFramer right;
                    useLeftStretched: aFramer isRightStretched;
                    useLeftWidth ].
        aFramer
            useRightInset;
            useRightStretched: proportional;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.

    self commonHorizontalScaleMask
        ifFalse: [
            "Left attributes are not common. Make them common.
                Changing to left won't remove Right attribute"
            self setLeft: framers first isLeftStretched ].

    self changedHorizontally
!  
isImmediatelyValid
        " Private - answer whether the immediate validation
        of the receiver indicates that the current value is valid. "

    ^immediateValidationMessage isNil
        or: [ immediateValidationMessage perform ]!   
isNewPartNameValid
        " Private - answer whether the newPartName is
        a valid new name for the part. "

    ^self part partWrapper isValidPartName: self newPartName!  
labelEntryFieldGap
        "Private - answer the horizontal distance
        between a static text label and it's associated
        entryField."
    ^self class labelEntryFieldGap! 
validateComponentNameImmediate
		" Private - answer whether the part name property is valid.
		Invoked when losing focus from the part name property. "

    | isValid |
    doingValidation := true.
    isValid := self partNameIsValid.
    doingValidation 
		ifFalse: [  "tricky stuff here - dialogClickedOK was entered
				in another process and could complete because 
				this process was doing validation.  The doingValidation
				flag was set from the other process to signal this case. "
        	isValid ifTrue: [ "retry the dialog close"
            	CurrentEvents add: ( Message receiver: dialog selector: #ok ) ].
			].
    doingValidation := false.
    ^isValid!  
partEditTextContents: aString
        "Bring up a window to edit the receiver's contents."

    ^PARTSSimpleTextEditor new
        openOn: aString
        label: self partName, ' Properties - Edit'!   
hasIconProperty
        " Private - answer whether the part has
        an icon property. "

    self implementedBySubclass!  
initializeSizeWindowButton
        " Private - register the event handler for
        the button which opens the window size editor.
        Subclasses should reimplement this method to do nothing
        if they do not support  the standard size property. "

    self sizeWindowButton
        when: #clicked
        send: #editWindowSize to: self.! 
editOrderedChildren
        " Private - open the Order Children subdialog. "

    | currentOrderedChildren |
    currentOrderedChildren := ( newOrderedChildren notNil
        ifTrue: [ newOrderedChildren ]
        ifFalse: [ self partOrderedChildren ] ).
    currentOrderedChildren := self orderedChildrenEditor
        openOn: currentOrderedChildren.
    currentOrderedChildren isNil ifTrue: [ ^self ].  " cancelled or no change "
    newOrderedChildren := currentOrderedChildren.!  
setVCenterValue: aValue
    "Private"
    | vCenter |

    aValue isNil ifTrue: [ ^self ].

    vCenter := aValue asNumber.
    framers do: [ :aFramer | aFramer top: vCenter ].
    self updateCommonFramer.
!  
createView
        " Private - create the window.  "
    | font verticalUnit topPane |
    font:= self font.
    verticalUnit := self verticalUnit.
    self addView: ((topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: 'PARTS OrderedCollection Editor' ;
        yourself ).
    topPane
        when: #opened
            send: #disableItems to: self;
        addSubpane: ((listBox := ListBox new)
            owner: self;
            font: font;
            when: #needsContents
            send: #listContents: to: self with: listBox;
            when: #changed:
            send: #listSelect: to: self;
            framingBlock: [ :b | self leftListBoxFrame: b withVerticalUnit: verticalUnit * 2 ]);
        addSubpane: (staticText := StaticText new
            font: font;
            value: 'Item:';
            framingBlock: [ :b | self rightFieldsFrame: b withVerticalUnit: verticalUnit * 2 ]);
        addSubpane: ((itemField := EntryField new)
            owner: self;
            font:  font;
             framingBlock: [ :b | self rightFieldsFrame: b withVerticalUnit: verticalUnit * 3]);
        addSubpane: (Button new
            "defaultPushButton;"
            owner: self;
            font: font;
            label: 'Add';
            when: #clicked send: #clickedAdd to: self;
            framingBlock: [ :b | self rightButton1Frame: b withVerticalUnit: verticalUnit * 4 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: 'Modify';
            when: #clicked send: #clickedModify to: self;
            framingBlock: [ :b | self rightButton2Frame: b withVerticalUnit: verticalUnit * 4 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: self removeButtonName;
            when: #clicked send: #clickedRemove to: self;
            framingBlock: [ :b | self rightButton1Frame: b withVerticalUnit: verticalUnit * 5 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: self removeAllButtonName;
            when: #clicked send: #clickedRemoveAll to: self;
            framingBlock: [ :b | self rightButton2Frame: b withVerticalUnit: verticalUnit * 5 ]);
        addSubpane: (Button new
            defaultPushButton;
            owner: self;
            font: font;
            label: 'OK';
            when: #clicked send: #ok to: self;
            framingBlock: [ :b | self leftButton1Frame: b withVerticalUnit: verticalUnit * 2 // 3 ]);
        addSubpane: (Button new
            owner: self;
            font: font;
            label: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b | self leftButton2Frame: b withVerticalUnit: verticalUnit * 2 // 3 ]);
        yourself.!
clicked: aBoolean
        " Private - the check box has changed state. "

    self isImmediatelyValid
        ifFalse: [ ^self ].  " validation failed "
    self newValue: aBoolean.!   
COMMENT
"
A PARTSPropertyBoolean represents a boolean value.
It is rendered as a check box item.
"!   
enable
        " Enable the button. "

    super enable.
    self pushButton enable.! 
partPropertySetColor: aSymbol with: aColor
    " Private - Set the foreground or background color of the receiver.
      aSymbol is either #foreColor or #backColor. "

    aSymbol == #foreColor
        ifTrue:   [self part foreColor: aColor]
        ifFalse: [self part backColor: aColor].

     self part colorChange.!   
doChanges
		" Private - apply the value if it has been changed.
		Do nothing for an operation button (has no state). "! 
buttonLabels
        "Private - answer the labels of the reciever's buttons."
    ^#( 'Forecolor...' 'Backcolor...' 'Font...' )!
cancel
        "Private - The dialog has been cancelled. "

    self close.!   
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Append <aString>
        after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: label;
        nextPutAll: ': ';
        nextPutAll: ( labelsMap at: initialSelection ) first;
        cr! 
setTopValue: aValue
    "Private"
    | top |

    aValue isNil ifTrue: [ ^self ].

    top := aValue asNumber.
    framers do: [ :aFramer | aFramer top: top ].
    self updateCommonFramer.
!  
validateValueMessage: aMessageName
    "Used to provide a way for the part to validate values before inserting them
        into the listPane."
    validateValueMessage := aMessageName!  
partPropertyEditContents: aPropertyUnit
        " Private - Edit contents property button handler. "
    | propertyStructure oldContents currentContents newContents |

    propertyStructure := aPropertyUnit propertyStructure.
    oldContents := self partContents.
    currentContents := propertyStructure partContext
        at: #editContents
        ifAbsent: [oldContents].
    newContents := self
        partEditContents: currentContents
        properties: propertyStructure.
    newContents isPARTSException ifTrue: [^self].  "bail out if canceled or did not change any"

    propertyStructure partContext
        at: #editContents put: newContents.
    "self ISSUE."  " Convert this to a PropertyEditButton
        and just set newValue: here so we don't need the
        following?? [DJL 07-Jun-93] "
    propertyStructure
        addAction: (Message new
               receiver: self
               selector: #partSetContents:
               arguments: (Array with: newContents))
        undo: (Message new
            receiver: self
            selector: #partSetContents:
            arguments: (Array with: oldContents)).! 
initWindowSize
        "Private - answer the extent of the receiver."

    | width minWidth extent |
    minWidth := PARTSPropertyUnit pushButtonWidth * 2
        + ( PARTSPropertyUnit horizontalGap * 3 ).
    extent := extentFromLeftTop + ( self gapY * 7 @ ( WindowDialog entryHeight * 2 )).
    width := extent x.
    width := width max: minWidth.
    extent x: width.
    ^extent! 
createView
        " Private - create the window "

    | topPane |
    self addView: (
        ( topPane := self topPaneClass new )
            owner: self;
            labelWithoutPrefix: self windowTitle;
            when: #opened 
                send: #dialogOpened to: properties;
            when: #closed
                send: #dialogClosed to: properties;
            yourself ).
    self
		addPropertyControls: topPane;
        addDefaultButtons: topPane.! 
listContents: aPane
        " Private - populate the list. "
    aPane contents:
        (dictionary keys asSortedCollection
            collect: [:key | key isString ifTrue: [key] ifFalse: [key printString]])!
initialize
        " Private "
    super initialize.
    self
        label: ( PARTSPropertyLineOfButtons sequenceChildren at: 1 );
        clickedSelector: ( PARTSPropertyLineOfButtons sequenceChildren at: 2 )!  
applyFontCheckBox
        " Private "

    ^self partNamed: 'ApplyFontCheckBox'!   
partBackColor
        " Private - answer the part's foreground color value..
        Use the value of the first part in the collection. "

    ^self part first backColor!
partExtent: anExtent
        " Reset the extent of the part being created
        for the label.  This value does not include the margin. "

    self partItem itemExtent: anExtent.! 
sequenceChildren
    ^#( 'Order children...' #partPropertySequenceChildren: )!   
partFont
        " Private - answer the part's font. "

    ^self part font!   
entryFieldFrameWidth
        "Answer the frame width of an standard entry field."
"  true ifTrue: [ ^super entryFieldFrameWidth ].
   ^super entryFieldFrameWidth + 6  "
    ^super entryFieldFrameWidth! 
editFont
        " Private - open the font edit dialog on the part's font.
        Answer the new font (nil if cancelled or not changed). "

    | currentFont selectedFont |
    currentFont := ( newFont notNil
        ifTrue: [ newFont ]
        ifFalse: [ self partFont ] ).
	selectedFont := FontDialog new
		sampleFont: currentFont;
		open;
		chosen.
       ( selectedFont isNil or: [ selectedFont = currentFont ] )
         ifTrue: [ ^nil ].
    newFont := selectedFont.
    ^newFont!
numberFieldFrameExtent
        "Private - answer the default extent
        of an number entry field."
    ^self numberFieldWidth @ self entryFieldFrameHeight!
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog.
        Do nothing - already linked properly in the application. "!   
newPartIcon: anIcon
        " Private - record an updated part icon. "

    newPartIcon := anIcon.!
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Append <aString>
        after every new line. "

    aStream
        nextPutAll: aString;
        nextPutAll: label;
        nextPutAll: ': ';
        nextPutAll: ( oldValue ifTrue: [ 'yes' ] ifFalse: [ 'no' ] );
        cr! 
frameHeight
        "Private - answer the height of the receiver's frame.
        The message #height is used for layout while
        #frameHeight is used for the actual frame rectangle."
    ^self
        partsIfOS2Do: [ self height ]
        partsIfWindowsDo: [ self height - 1 ]! 
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'PPCommon.par'! 
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.

    self hasOrderedChildrenChanged
        ifTrue: [
            applyChangesActions
                add: (Message new
                    receiver: self part;
                    selector: #orderChildrenAndDisplay: ;
                    arguments: (Array with: newOrderedChildren)).
            undoChangesActions
                add:  (Message new
                    receiver: self part;
                    selector: #orderChildrenAndDisplay: ;
                    arguments: (Array with: self partOrderedChildren)) ].!  
COMMENT
"
A PARTSPropertyButtonGroup presents
a list of choices with a group of radio buttons.
"! 
mouseTrackIcon: anIcon
        " Specify the icon to display while tracking the mouse
        to the form item drop point in a PARTS workbench. "

    mouseTrackIcon := anIcon.! 
mouseButtonDrag
        " Private - answer the mouse button to use for dragging. "

    ^self
        partsIfOS2Do: [ PARTSHostInterface dragButtonOS2 ]
        partsIfWindowsDo: [ PARTSSettings current mouseButtonDrag ]!
clearGroup
        "Private -"
    | listPane |
    listPane := self paneAt: #children.
    listPane removeSeparator: (listPane selectedIndex) - 1.
    self disableButtons: listPane!   
mouseTrackIcon
        " Answer the icon to display while tracking the mouse
        to the form item drop point in a PARTS workbench. "

    mouseTrackIcon isNil
        ifTrue: [
            mouseTrackIcon := PARTSFile iconFromFile: 'ENTRYFLD.PAR'
                ifNone: [ PARTSApplication defaultIcon ].
            ].
    ^mouseTrackIcon!  
labelFrameIn: parentRect
		" Private "
    | left right top bottom |
    left := parentRect left right: self leftTop x.
    top := (parentRect top down:self  leftTop y)
        "down: self height // 8."
        down: (self textMargin // 2).
    right := left right: (label size * WindowDialog charWidth).
    bottom := top down: self lineHeight.
    ^left @ top rightBottom: right @ bottom!   
setVCenter: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect rounded: false.
        aFramer
            useCenterHeight;
            useTopStretched: proportional;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.
    "self ASSERT: self commonVerticalScaleMask = true"

    self changedVertically
! 
currentBackColor
    " Return the backColor selected in the dialog.
      If a backColor has never been selected, return the part's foreColor. "
	^newBackColor == #uninitialized
        ifTrue: [self partBackColor ]
		ifFalse: [newBackColor]!   
ok
        " Private - the OK button has been pressed. "
    (list size > 0)
        ifTrue: [answer := (self paneAt: self listPaneName) contents asArray].
    self close.!  
extentUnit: aRectangle
        " Return the extent unit. "
    ^aRectangle width // 2 - (self gap * 2) @ self class entryHeight!
framers
    "Private"

    ^framers
! 
addToStyleBasic: aStyle
        " Private - update the style value <anInteger> with
        the receiver's style value and answer the new style. "
    | answer c styleBitArray |

    answer := aStyle.
    styleBitArray := labelsMap collect: [ :a | a last ].
    styleBitArray do: [ :bit |    "Since style bits overlap, need to clear them first"
        answer := answer bitOr: bit.
        answer := answer bitXor: bit].
    1 to: controls size do: [ :i |
        c := controls at: i.
        c value
            ifTrue: [ answer := answer bitOr: ( styleBitArray at: i ) ] ].
    ^answer!
sizeWindowButton
        " Private - answer the Size window... button in the dialog window. "

    ^self partNamed: 'SizeWindowButton'!
initialize
        " Private - Initialize the receiver. "
    super initialize.
    currentBackColor := currentForeColor := #uninitialized!
cancelButton
        " Private - answer the Cancel button in the dialog window. "

    ^self partNamed: 'CancelButton'!
orderChildrenButton
        " Private - answer the order children button in the dialog window. "
	^self partNamed: 'OrderChildrenButton'!   
unit
        "Answer a value to be used as a factor in the layout of the receiver."
    ^WindowDialog entryHeight // 2! 
sizeWindow
    ^#( 'Size window...' #partPropertyEditSize: )!
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog.
        Subclass implementations of this method
        should first send #initializeEventHandlers to super."

    super initializeEventHandlers.

    self hasIconProperty
        ifTrue: [
            self editIconButton
                when: #clicked send: #editIcon to: self ].

    self interfaceButton
        when: #clicked send: #editInterface to: self.!  
pushButtonHeight
        "Answer the height of an standard push button."
    ^self class pushButtonHeight!  
list: aList
		" Specify the list to display. "

    list := aList.!
removeButtonName
    ^'Remove'!  
sourceEvent
        "Private - sourceEvent is a Symbol which is the event
        for the link from the source part to the part."
    ^sourceEvent!
dragSource
    "Private - answer true if the related part has been enabled
    as a drag source."

    ^(self part propertyAt: #dragSource ifAbsent: [nil]) notNil.!  
pushButtonWidth
        "Answer the default width of the reciever's push button controls."
    ^PARTSDialog horizontalDialogUnitsFromPixels: (self font stringWidth: 'Change Icon...XX')!   
labelsMap: anArray
        " Specify the list of radio buttons to display in the pane,
        where <anArray> is an Array of 2 element Arrays, the first
        of each is a button label, the second is the argument
        of the changeSelector"

    labelsMap := anArray.
    widestLabelPELS := 0.
    labelsMap do: [ :a |
        widestLabelPELS := widestLabelPELS
            max: ( self widthOfString: a first, 'XX' ) + ( self horizontalGap * 2 ) ].! 
bottomHeight
        "Answer the height of the bottom border of the dialog
        in dialog units.  This value is constant and disregards
        screen dimensions."
    ^WindowDialog entryHeight * 2! 
initializeEventHandlers
        " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog.
        Subclass implementations of this method
        should first send #initializeEventHandlers to super."

    super initializeEventHandlers.
    self initializeOrderedChildrenButton.!  
entryFieldWidth
        "Answer the default width
        of an entry field."
    ^ 96!
backColorButton
        " Private - answer the Backcolor... button in the dialog window. "

    ^self partNamed: 'BackcolorButton'!
initializeOkCancelButtons
        " Private - the dialog window application has been loaded.
        Register the event handlers for the OK and Cancel buttons. "

    self okButton
        when: #clicked send: #ok to: self.
    self cancelButton
        when: #clicked send: #cancel to: self.!  
gapX
		" Private - answer the horizontal gap between items. "

    ^PARTSPropertyUnit horizontalGap!   
for: aPart
    name: aPartName
    extent: aPoint
    helpInfo: anArray
    staticTextLabel: labelString
    partEvent: aPartEvent
    partMessage: aPartMessage
    sourceEvent: aSourceEvent
    sourceMessage: aSourceMessage
        " Answer a new item for the PARTS form generator.
        <aPart> is an instance of a Smalltalk object which
        will be the part which is added to the application.
        <aPartName> is the part name of the part.
        <aPoint> is used if this is a visual part.
        The help info <anArray> contains two strings elements:
            o help file name
             o help topic name
        If not specified, the part will not have a help panel
        inside the workbench.
        If <labelString> is specified a StaticText label will
        be placed to the left of the part. "

    ^self new
        part: aPart
            name: aPartName
            extent: aPoint
            helpInfo: anArray;
        staticTextLabel: labelString;
        partEvent: aPartEvent;
        partMessage: aPartMessage;
        sourceEvent: aSourceEvent;
        sourceMessage: aSourceMessage;
        yourself! 
computeWidth
        "Private - compute and answer the width of the receiver."

    ^self iconExtent x + self horizontalGap + self pushButtonWidth!
ok
        " Private - the OK button was pressed. "
    answer := array asArray.
    self close!   
leftBottom: aPoint
        " Private - set the leftBottom position of the receiver. "

    leftTop := aPoint x @ ( aPoint y - self extent y ).!
horizontalGap
        "Private - answer the horizontal distance
        between controls."
    ^self class horizontalGap!  
applyPartName: aString
        " Private - set the name of my part to aString.
        Update the icon label of a non-visual part. "

    | icon |
    super applyPartName: aString.
    self hasIconProperty
        ifTrue: [
            icon := self partIcon.
            icon parent
                changeIconLabel: icon
                to: self partName.  " should be aString, but this is safe "
            ].!  
supportsUndoRedo
        " Private - answer whether undo/redo action
        sequences can be constructed for the
        receiver's property values. "

    ^true!  
changeSelector: aSymbol
		" Specify the selector to send to the property owner
		when a changed value is to be applied. "

    changeSelector := aSymbol.!
height
		" Private - answer the height of the property unit. "

    ^WindowDialog entryHeight * 8! 
numberFieldWidth
        "Private - answer the default width
        of a numeric entry field."
    ^self class numberFieldWidth!  
computeHeight
        "Private - compute and answer the height of the receiver."

   ^labelsMap size + 1 * self radioButtonHeight +  ( self radioButtonHeight // 4 )!  
initializeBackColorButton
        " Private - register the event handler for
        the button which opens the color editor
        on the part's background color.  Subclasses
        should reimplement this method to do nothing
        if they do not support a background color property. "

    self backColorButton
        when: #clicked
        send: #editBackColor to: self.! 
value: aValue
        "Set the value of the property to <aValue>. "

    super
        value: aValue;
        newValue: aValue.
    self setModified: false.!   
clickedRemoveAll
        " Private - empty the dictionary.  "
    (MessageBox confirm: 'Remove all entries - are you sure?')
        ifTrue: [dictionary removeAll].
    keyField contents: String new.
    valueField contents: String new.
    listBox contents: Array new.
    modified := true.!   
framingBlock
        "Private - answer the default framingBlock."
    ^[ :box | ( box leftTop rightAndDown: leftTop )
        extentFromLeftTop: self frameExtent ]!   
twoDigitYear
        "Returns a boolean which indicates if the receiver accepts a two digit
        or four digit year.
        If aBoolean is true then the receiver accepts a two digit year.
        If aBoolean is false then the receiver accepts a four digit year."
    ^newValue at: 'twoDigitYear'! 
partEditContents: currentContents properties: aPropertyStructure
        " Private - edit the current part contents "
    self implementedBySubclass!   
COMMENT
"
A PARTSPropertyText renders an editable text string property
in a multi-line text pane.
"!  
setBottom: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer isBottomInset not
            ifTrue: [
                aFramer
                    top: aFramer bottom;
                    useTopStretched: aFramer isBottomStretched;
                    useTopHeight ].
       aFramer
            useBottomInset;
            useBottomStretched: proportional;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.

    self commonVerticalScaleMask
        ifFalse: [
            "Top attributes are not common. Make them common.
                Changing to top won't remove bottom attribute"
            self setTop: framers first isTopStretched ].

    self changedVertically
!
createPartsWith: aFormGenerator
        " Private "
    self implementedBySubclass! 
frameHeight
        "Private - answer the height of the receiver's frame.
        The message #height is used for layout while
        #frameHeight is used for the actual frame rectangle."
    ^self
        partsIfOS2Do: [ self height - 1 ]
        partsIfWindowsDo: [ self height ]! 
commonLeft
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r000100000000000 = 0 ]
!  
isStyle
        "Answer whether the receiver represents a window style. "

    ^true!  
undoPropertyChanges
        " Private - apply the property changes. "

    operation := #undoChanges.
    self triggerEvent: #aboutToEdit.
    self propertiesReverseDo: [ :p | p undoChanges ].
    self styleChanged
        ifTrue: [ self setStyle: oldStyle ].
    undoActions reverseDo: [ :m | m perform ].
    self triggerEvent: #editDone.
    operation := nil.! 
fixedInsetFixedSize
    "Private"
    | rect |

    framers size = 0 ifTrue: [^self].

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer
            useAllFixed;
            useAllInset;
            useRightWidth;
            useBottomHeight;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.
    self changed
!
disable
        " Disable the button. "

    super disable.
    self pushButton disable.! 
clickedRemove
        " Private - the remove button was pressed "
    | item |
    self setModified: true.
    item := listPane selectedItem.
    newValue remove: item ifAbsent: [ Terminal bell ].
    listPane restore.! 
pastePart: aPart
    in: destWindow
    rect: aRect
    name: partName
    helpInfo: helpInfo
        " Private - paste aPart in aWindow. "

    | isVisualPart |

    isVisualPart := aPart partIsWindow.
    ( destWindow partCanWindow: destWindow haveChild: EntryField new )
        ifFalse: [ ^nil ].
    destWindow partEditor
        addComponent: aPart
        in: destWindow
        box: aRect
        contents: nil
        name: partName copy
        icon: ( isVisualPart
            ifTrue: [ nil ]
            ifFalse: [ aPart partIcon ] )
        helpInfo: helpInfo.
    "Don't do this anymore with PARTSFramer:   [DJL 21-Oct-93]
    isVisualPart
        ifTrue: [   //Fix the position and extent //
            aPart framingBlock:
                ( aPart framingBlock
                    scaleFrom: aPart superWindow freeClientArea )
            ].
    "!  
canDoChanges
		" Answer whether all the requested changes
		in the properties can be applied. "

    doingValidation 
		ifTrue: [   "tricky stuff here - toggle doingValidation to flag
            	validateComponentName that we should be trying
            	to exit.  Need this because of Dialog multiprocessing"
        	doingValidation := false.
        	^false ].
    self propertiesValid: true.
    self propertiesDo: [ :p |
        p canDoChanges ifFalse: [ ^false ] ].
    self triggerEvent: #aboutToAcceptChanges: with: self.
    ^self propertiesValid!  
ok
        "Private - The OK button has been pressed.
        Apply the new property values to the part and close
        the dialog window if the proposed changes are valid.
        If there is a problem with any values, notify the user
        and leave the dialog open.  Answer whether the
        new properties were accepted. "

    self havePropertiesChanged
        ifFalse: [
            changesAccepted := true.
            self close.
            ^true ].

    self arePropertiesValid
        ifFalse: [ ^false ].

    self applyProperties.
    changesAccepted := true.
    self close.
    ^true!
value
    ^self newValue!
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    self initializeApplyCheckBoxes.!   
openDialogWindow
        "Private - Open the properties editor dialog window."

    | result |
    result := self openModalDialog: self dialogWindowName.
    ( result notNil and: [ self supportsRecycling ] )
        ifTrue: [ ( Message receiver: self selector: #recycle ) performDeferred ].
    ^result!
constant2: aConstant
		" Specify the bits which are set in a style when
		the window style represented by the receiver is not set. "

    constant2 := aConstant.!
initializeValues
        " Private - initialize instance variables.
         Default is to do nothing. "!   
computeWidth
        "Private - compute and answer the width of the receiver."
    ^self labelWidth * 3!
partPropertyEditGraphic: aPropertyUnit
        " Private - edit graphic property button handler "

    | iconOrBitmap initValue propertyStructure |

    propertyStructure := aPropertyUnit propertyStructure.
    iconOrBitmap := self partGetGraphics.
    initValue := iconOrBitmap clone.

    iconOrBitmap isIcon ifTrue: [
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
                                arguments: (Array with: iconOrBitmap))]]].
    iconOrBitmap isBitmap ifTrue: [
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
                                arguments: (Array with: iconOrBitmap))]]]!   
computeHeight
        "Private - compute and answer the height of the receiver."

    ^newValue extent y // 2! 
partPropertySelectColor: aSymbol
    " Private - Bring up the ColorDialog and set the color of the receiver.
      aSymbol indicates if the user wants to set the #foreColor or #backColor ."

    | originalColor currentColor newColor dialog |
    aSymbol == #foreColor
        ifTrue:   [
            originalColor:= self part foreColor.
            currentColor:= self currentForeColor ]
        ifFalse: [
            originalColor:= self part backColor.
            currentColor:= self currentBackColor ] .
   dialog := ColorDialog new
        openOn: currentColor.
	newColor:= dialog chosen.
   newColor notNil
        ifTrue: [
            (aSymbol == #foreColor)
                ifTrue: [self currentForeColor: newColor]
                ifFalse: [self currentBackColor: newColor] ]
        ifFalse: [ ^self ]. "Canceled or same color "

    self propertyStructure
        addAction: (Message new
            receiver: self;
            selector: #partPropertySetColor:with: ;
            arguments: (Array with: aSymbol with: newColor))
        undo: (Message new
            receiver: self;
            selector: #partPropertySetColor:with: ;
            arguments: (Array with: aSymbol with: originalColor)).!
entryFrameIn: parentRect
		" Private "
    ^( parentRect right left: self entryFieldWidth ) @
        ( parentRect top down: self leftTop y )
            extentFromLeftTop: self entryFieldFrameExtent!  
clearFramers
    "Private"

    commonFramer := nil.
    commonFlag := nil.
    framers := nil.
!   
COMMENT
"
A PARTSPropertiesEditor is a general property editor which 
operates on a collection of property specifications provided
in a PARTSPropertyStructure.  The layout algorithm for rendering
property units is attempts to do a reasonable general layout, but
does not attempt to do totally sophisticated automatic layout.

Alternatively, the property dialog of a part class can be
constructed as a PARTS application with a wrapper class
created as a subclass of PARTSPartPropertyDialog, which
is the recommended framework described in the
PARTS Workbench for Smalltalk Programmers manual.
"!   
layoutVerticalGroupClass: aClass
        " Private - answer the class which represents a vertical group in a form. "

     LayoutVerticalGroupClass := aClass.!
applySizeCheckBox
        " Private "

    ^self partNamed: 'ApplySizeCheckBox'!   
partEvent
        "Private - partEvent is a Symbol which is event
        for the link from the part to the source part."
    ^partEvent!  
part
        " Answer the part responsible for this property. "

    ^propertyStructure part!  
COMMENT
    "This class maps a property unit specified as a list
	of symbols into a  line of one or more push buttons.
    When building a PartPropertyStructure, you can send
	the #putProperty: message with an array of Symbols
	as an argument.  This class is used by the property
	structure to produce a property corresponding to
	the requested operation buttons.  The symbols must
	be implemented as class methods in this class.

	Implementation notes:
	Each symbol is mapped to a 2-element Array which
	provides a shorthand description of an edit button property
	by performing the symbol to obtain the array.
    The first element of the Array is the label of the button,
    the second element is a selector to be performed when
    the button is hit.  New buttons are supported by adding
	new methods to this class to map the Symbol to
	a 2-element array.  This functionality could be provided
    by a dictionary stored in a class var, but this way is
    much faster and actually much easier to maintain.
	"!  
fixedInsetAll
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer
            useAllFixed;
            useAllInset;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.
    self changed

!   
at: anInteger
		" Answer the property at index <anInteger>. "

    ^self propertyAt: ( unitOrdering at: anInteger )!   
entryFieldFrameHeight
        "Answer the height the frame of an standard entry field."
    ^self
        partsIfOS2Do: [ self entryFieldHeight - 2 ]
        partsIfWindowsDo: [ self entryFieldHeight ]!
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    ( self partNamed: 'SizeWindowPart' )
        framers: framers;
        parentRect: parentRect

!   
partSize
        " Private - answer the original size of the part. "

    ^self part framingBlock! 
createEntryControl
        " Private - initialize the entry part to add to the window.
        Contents must be initialized.
        In this case the client has already supplied the field.  "

    self textEntryItem
        validateWhenLosingFocus: false;
        value: self initialValue;
        yourself.!  
undoChanges
        " Private - reset the value if it has been changed.
        Do nothing for an operation button (has no state). "!   
leftListBoxFrame: aRectangle withVerticalUnit: aNumber
        " Return the framing rectangle for the left list pane of the editor. "
    ^(aRectangle leftTop rightAndDown: self gap)
                rightBottom: (aRectangle left right: aRectangle width // 2) @ (aRectangle bottom up: aNumber )! 
createdParts
        " Answer whether any parts were created
        by the form generation operation. "

    ^parts size > 0!
addEntryFieldToWindow: aTopPane
		" Private - add the text entry item to <aTopPane>. "

    self createEntryControl.
    aTopPane addSubpane: ( self textEntryItem
        font: self font;
        owner: self;
        setName: self changeSelector;
        when: #changed: 
			send: #contentsChanged to: self;
        framingBlock: [ :b | self entryFrameIn: b ] ).
    aTopPane
        when: #opened
        send: #clearModified to: self.!
fourDigitYearClicked: aButtonLabel
    " Private - the four digit year option has been selected.
      Set twoDigitYear to false and update
      the sample and contents entryfields. "
    newValue at: 'twoDigitYear' put: false.
    self contentsPane
        twoDigitYear: false;
        modified: true.
    self sampleUpdate!
iconExtent
		" Private "

    ^oldValue extent // 2!   
new
        " Answer a new instance of the receiver. "

    ^super new initialize! 
iconStaticGraphic
        " Private - answer the StaticGraphic item in the dialog window
        which displays the part's icon. "

    ^self partNamed: 'IconStaticGraphic'! 
addPartNameProperty
        " Private - add the standard property item for the part name. "

    self
        at: #componentNameField
        putProperty: ( PARTSPropertyString new
            value: part partName;
            label: 'Part name:';
            immediateValidationMessage: ( Message
                receiver: self
                selector: #validateComponentNameImmediate );
            validationMessage: ( Message
                receiver: self
                selector: #validateComponentName );
            changeSelector: #partName: )! 
commonExtent: aRectangle
        "Answer an extent value to be used by various controls
        in the receiver."
    ^aRectangle width // 2 - (self unit * 3) @
        WindowDialog entryHeight!
atIndex: anInteger
		" Answer the property at index <anInteger>. "

    ^self propertyAt: ( unitOrdering at: anInteger )!  
initialValue
        " Private - answer the initial value to display in the value pane. "

    ^self originalValue isNil 
		ifTrue: [ String new ] 
		ifFalse: [ self originalValue ]!   
partMessage
        "Private - partMessage is a Symbol which is the message
        for the link from the part to the source part."
    ^partMessage!  
computeWidth
    "Private - compute and answer the width of the receiver."

    ^self labelWidth max: self pushButtonWidth.!   
entryFieldHeight
        "Answer the height of an standard entry field."
    ^self class entryFieldHeight!  
listSelect: selectedItem
        " Private - an item was selected in the list "
    | text |
    text := selectedItem asStream.
    text upTo: $.; next; next.
    text := text upTo: Cr.
    itemField contents: text; setFocus!   
sourceMessage
        "Private - sourceMessage is a Symbol which is the message
        for the link from the source part to the part."
    ^sourceMessage!
initialSelection: anInteger
		" Specify the radio button to select initially. "

    initialSelection := anInteger.
    anInteger > 0 ifTrue: [
        oldValue := ( labelsMap at: anInteger ) last ]!  
changedVertically
    "Private"

    self triggerEvent: #changedVertically: with: commonFramer.


! 
partHasDynamicMessages
        " Private - answer whether the part has
        dynamic messages which can change
        when its property values are updated. "

    ^false!
setLeft: proportional
    "Private"
    | rect |

    framers do: [ :aFramer |
        rect := aFramer scaleFrom: parentRect.
        aFramer
            useLeftInset;
            useLeftStretched: proportional;
            changeRectangle: rect relativeTo: parentRect ].

    self updateCommonFramer.

    self commonHorizontalScaleMask
        ifFalse: [
            "Right attributes are not common. Make them common.
                Changing to width, won't remove left attribute"
            self setWidth: framers first isRightStretched ].

    self changedHorizontally.

!  
right
        " Private - answer the right side of the receiver. "

    ^leftTop x right: self extent x!   
checkBoxHeight
        "Answer the height of a standard check box."
    ^PARTSDialog standardEntryHeight - 2!   
propertyAt: anObject ifAbsent: aBlock
		" Answer the property named <anObject>. 
		Evaluate <aBlock> if not found. "

    ^propertyUnits at: anObject ifAbsent: [ aBlock value ]! 
commonTop
    "Private"

    ^commonFlag isNil or: [ commonFlag & 2r000001000000000 = 0 ]
!   
height
		" Private - answer the height of the property unit. "

    ^self entryFieldHeight * 4!
framingBlockFor: anInteger
		" Private - answer the framing block for the <aInteger>-th 
		radio button. "

    ^[ :box | (( box leftTop rightAndDown: self leftTop + self radioButtonHeight )
        down: anInteger - 1 * self radioButtonHeight )
            extentFromLeftTop: widestLabelPELS -
				PARTSDialog horizontalDialogBaseUnit @ self radioButtonHeight ]!
initialize
		"Private - Initialize newBackColor, newForeColor
		so we know if they were set later"
	super initialize.
	newBackColor := newForeColor := #uninitialized.!   
clickedModify
        " Private - update the selected element. "
    | index |
    index := listBox selectedIndex.
    (index = 0  or: [index isNil])
        ifTrue: [^Terminal bell]
        ifFalse: [
            oc at: index put: itemField contents].
    modified := true.
    listBox update.
    listBox selectIndex: index.
    "Leave disabled because it's selected:
    itemField contents: String new; setFocus
    "!
removeButton
        " Private "
    ^self paneAt: self removeButtonName!   
arePropertiesValid
        " Private - answer whether the values of the properties are valid.
        If not valid, notify the user of the problem and answer false. "

    ^true!
partSize
        " Private - answer the part's size."

    ^self part collect: [ :aPart | aPart framingBlock ].
! 
addDefaultButtons: topPane
        "Private - add the OK and cancel buttons to the receiver."
    | unit leftGap middleGap |
    unit := self class entryHeight.
    leftGap := WindowDialog dialogUnit x.
    middleGap := PARTSPropertyUnit horizontalGap.
    topPane
        addSubpane: ( Button new
            defaultPushButton;
            font: self font;
            label: 'OK';
            when: #clicked send: #ok to: self;
            framingBlock: [ :b |
                ( b left right: self leftMargin ) @ ( b bottom up: self class entryHeight // 2 )
                    extentFromLeftBottom: PARTSPropertyUnit pushButtonExtent ] );
        addSubpane: ( Button new
            font: self font;
            label: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b |
                ( b left right: self leftMargin + middleGap +  PARTSPropertyUnit pushButtonExtent x )
                     @ ( b bottom up: self class entryHeight // 2 )
                        extentFromLeftBottom: PARTSPropertyUnit pushButtonExtent ] )!
clickedAdd
        " Private - add an association to the dictionary. "
    dictionary at: keyField contents put: valueField contents.
    listBox update.
    listBox selectItem: keyField contents.
    "Leave disabled because it's selected:
    keyField contents: String new.
    valueField contents: String new.
    "
    modified := true.! 
setRightValue: aValue
    "Private"
    | right |

    aValue isNil ifTrue: [ ^self ].

    right := aValue asNumber.
    framers do: [ :aFramer | aFramer right: right ].
    self updateCommonFramer.
!
initializeFontButton
        " Private - register the event handler for
        the button which opens the font editor
        on the part's font.  Subclasses should
        reimplement this method to do nothing
        if they do not support a font property. "

    self fontButton
        when: #clicked
        send: #editFont to: self.! 
pushButton
		" Private - answer the push button representing
		the receiver's operation. "

	^self controls!  
partPropertySelectFont
    " Private - Bring up the FontDialog and set the font of the receiver. "

    | originalFont newFont |
    originalFont:= self part font.
	newFont := FontDialog new
		sampleFont: self currentFont;
		open;
		chosen.

    ( ((newFont isNil) or: [newFont = self currentFont]) or: [newFont = originalFont] )
        ifTrue: [^self].

    self currentFont: newFont.
    self propertyStructure
        addAction: ( Message new
            receiver: self part;
            selector: #font: ;
            arguments: ( Array with: self currentFont ) )
        undo: ( Message new
            receiver: self part;
            selector: #font: ;
            arguments: ( Array with: originalFont ) ).!
currentForeColor: aColor
        " Private - Assign the current forecolor selected. "
    currentForeColor := aColor!   
clickedSelector: aSymbol
        " Register the one-argument message selector
        to be invoked when this property button is pressed.
        The part must set newValue if value is changed. "
    clickedSelector := aSymbol.!  
style
		" Answer the bits which are set in a style when
		the window style represented by the receiver is set. "

    ^constant!  
label: aString
        "Set the receiver's label.  If the label is too large,
        chop off the end."
    | realLabel etc |
    etc := '...etc...'.
    realLabel := aString size <= self labelMax
        ifTrue: [ aString ]
        ifFalse: [ (aString copyFrom: 1 to: self labelMax - etc size), etc ].
    super label: realLabel.
    self staticTextItem notNil 
		ifTrue: [ self staticTextItem contents: realLabel ].! 
propertiesValid
        " Answer whether the property values are all valid. "

    ^propertiesValid!   
havePropertiesChanged
        " Private - answer whether any of the properties have been changed. "

    ^super havePropertiesChanged
        or: [ self hasForeColorChanged
        or: [ self hasBackColorChanged
        or: [ self hasFontChanged
        or: [ self hasSizeChanged ] ] ] ]!   
openOn: originalOrderedChildren
        "Open the tab and direction key editor."

    orderedChildren := originalOrderedChildren.
    self
        initChildren;
        createView;
        openWindow.
    ^answer! 
getItemsAction: aOneArgumentAction
        " Specify the action to evaluate to get the form
        items to be created.  The evaluation argument
        is the list of form item names. "

    getItemsAction := aOneArgumentAction!   
ok
        "Private - The OK button has been pressed. "

    self implementedBySubclass!   
initializeApplyCheckBoxes
        " Private "

    self applyForeColorCheckBox setValue: false.
    self applyBackColorCheckBox setValue: false.
    self applyFontCheckBox setValue: false.
    self applySizeCheckBox setValue: false.!   
isStyle
        "Answer whether the receiver represents a window style.
		Window styles get special treatment in dialog layout. "

    ^false!
partIcon
        " Private - answer the icon of my part "

   ^self part partIcon! 
computeWidth
        "Private - compute and answer the width of the receiver."

    ^newValue extent x // 2!   
editForeColor
        " Private - open the color edit dialog on the foreColor. "
    | newColor |
    newColor := ColorDialog new
        openOn: self currentForeColor;
        chosen.
	" If the user hits cancel, chosen answers nil."
	newColor isNil 
		ifFalse: [newForeColor := newColor]! 
computeHeight
        "Private - compute and answer the height of the receiver."

    ^self entryFieldHeight * 8 + self verticalGap!   
widthInPixelsOfString: aString
        "Private - answer the width of aString in pixels."
    | pixelWidth |
    Display pen font: self font.
    pixelWidth := Display pen stringWidthOf: aString.
    ^pixelWidth! 
verticalSpacing
        "Answer a value that is used as a factor in the vertical
        positioning of controls."
    ^WindowDialog charHeight * 2!   
propertiesReverseDo: aBlock
		" Evaluate the one-argument block <aBlock>
		with each property, in reverse order. "

    unitOrdering reverseDo: [ :key |
        aBlock value: ( self propertyAt: key ) ].!  
openOn: aFramer parentRectangle: aRect
        " Open a dialog to let the user edit the PARTS framer."
    | newFramers |

    framers := aFramer isCollection
        ifTrue: [ aFramer deepCopy asOrderedCollection ]
        ifFalse: [ OrderedCollection with: aFramer copy ].
    parentRect := aRect.

    self openDialogWindow isNil
        ifTrue: [ ^nil ].  " couldn't get the dialog open "

    ^( newFramers := self application framers ) size = 1
        ifTrue: [ newFramers first ]
        ifFalse: [ newFramers ]
!  
hasIconProperty
        " Private - answer whether my part has
        an icon property. "

    ^true!
labelFrameIn: parentRect
		" Private "

    | left right top bottom |
    left := parentRect left right: self leftTop x.
    top := (parentRect top down: self leftTop y) down: self height // 8.
    right := parentRect right left: self entryFieldWidth + (self height // 2).
    bottom := top down: self height.
    ^left @ top rightBottom: right @ bottom!
addDateSampleItem: aTopPane
        " Private - add the date sample item . "
    | font cellSize width|
    font:= self font.
    cellSize := WindowDialog charWidth @ WindowDialog entryHeight.
    width:= self staticTextWidth.
    aTopPane
        addSubpane: (StaticText rightJustified
            font: font;
            contents: 'Sample:';
            framingBlock: [:b |(b leftTop rightAndDown: ((1 @ (26/5))*cellSize + self leftTop))
                    extentFromLeftTop: ((width @ 1) * cellSize)]);
        addSubpane: (PARTSEntryFieldPart  new
            readOnly;
            setName: 'samplePane';
            font: font;
            contents: self createDateString;
            framingBlock: [:b |(b leftTop rightAndDown: ( self horizontalGap @ 0 + ((width @ (26/5))*cellSize + self leftTop)))
                    extentFromLeftTop: width * cellSize x @ self entryFieldFrameHeight ] )!  
listFrame: aRectangle
    ^((aRectangle leftTop rightAndDown: self unit) rightBottom:
        ((aRectangle leftBottom right: (aRectangle width // 2))
            up: self bottomHeight + self unit))! 
listContents: aPane
        " Private - populate the list. "
    aPane contents: (oc collect: [ :e |
        e isString ifTrue: [e] ifFalse: [e printString]])!
labelPosition: aSymbol
        " Specify the position of the StaticText label
        relative to the value-containing part. "
    ( self class supportedLabelPositions includes: aSymbol )
        ifFalse: [ ^self error: 'unknown label position' ].
    labelPosition := aSymbol!
sourceMessage: aSymbol
        "Private - sourceMessage is a Symbol which is the message
        for the link from the source part to the part."
    ^sourceMessage := aSymbol!
createView
        " Private - create the dialog window. "

    | charSize cell font separators topPane childrenListPane |

    separators := OrderedCollection new.
    orderedChildren do: [ :child |
        child isAGroupLeader
            ifTrue: [ separators add: ( (orderedChildren indexOf: child) - 1) ] ].
    font := self font.
    cell := WindowDialog charWidth @ WindowDialog entryHeight.
    charSize := WindowDialog unitMultiplier.

    self addView: ( (topPane := self topPaneClass new)
        owner: self;
        labelWithoutPrefix: 'Tab and Direction Keys';
        when: #opened send: #initializeWindow to: self;
        yourself ).
    topPane addSubpane:
        ( (childrenListPane := ExtendedListBox new)
            userCanReorder: true;
            dragButton: self mouseButtonDrag;
            setName: #children;
            font: font;
            contents: self childList separators: separators;
            selectIndex: 1;
            when: #changed:
                send: #disableButtons: to: self with: childrenListPane;
            framingBlock: [ :b | ( b leftTop rightAndDown: (1 @ 1) * charSize )
                extentFromLeftTop: ( (20 @ 9) * charSize ) ] );
        addSubpane: ( Button new
            setName: #setTabStop;
            font: font;
            contents: 'Set Tab Stop';
            when: #clicked send: #setTabStop to: self;
            framingBlock: [ :b | ( b leftTop rightAndDown: (22 @ 1) * charSize )
                extentFromLeftTop: ( (14 @ 1) * cell ) ] );
        addSubpane: ( Button new
            setName: #clearTabStop;
            font: font;
            contents: 'Clear Tab Stop';
            when: #clicked send: #clearTabStop to: self;
            framingBlock: [ :b | ( b leftTop rightAndDown: (22 @ 3) * charSize )
                extentFromLeftTop: ( (14 @ 1) * cell ) ] );
        addSubpane: ( Button new
            setName: #startGroup;
            font: font;
            contents: 'Start Group';
            when: #clicked send: #startGroup to: self;
            framingBlock: [ :b | ( b leftTop rightAndDown: (22 @ 5) * charSize)
                extentFromLeftTop: ( (14 @ 1) * cell ) ] );
        addSubpane: ( Button new
            setName: #clearGroup;
            font: font;
            contents: 'Clear Group';
            when: #clicked send: #clearGroup to: self;
            framingBlock: [ :b | ( b leftTop rightAndDown: (22 @ 7) * charSize )
                extentFromLeftTop: ( (14 @ 1) * cell ) ] );
        addSubpane: ( StaticText new
            font: font;
            contents: '* indicates a tabstop';
            framingBlock: [ :b | ( b leftTop rightAndDown: (1 @ 11) * charSize )
                extentFromLeftTop: ( (21 @ 1) * cell ) ] );
        addSubpane: ( Button new
            font: font;
            defaultPushButton;
            contents: 'OK';
            when: #clicked send: #ok to: self;
            framingBlock: [ :b | ( b leftTop rightAndDown: (1 @ 13) * charSize )
                extentFromLeftTop: ( (14 @ 1) * cell ) ] );
        addSubpane: ( Button new
            font: font;
            contents: 'Cancel';
            when: #clicked send: #cancel to: self;
            framingBlock: [ :b | ( b leftTop rightAndDown: (16 @ 13) * charSize )
                extentFromLeftTop: ( (14 @ 1) * cell ) ] ).!  
dialogWindowName
        " Answer the part name of the main dialog window
        inside the part file implementing the property dialog. "

    ^'DialogWindow1'! 
computeExtent
        "Private - compute the width and height of the receiver
		and answer its extent."

    ^self computeWidth @ self computeHeight! 
updateCommonFramer
    "Private"
    | extendedCommonFramer |

    extendedCommonFramer := self extendedCommonFramer.
    commonFramer := extendedCommonFramer copy.
    commonFramer scaleMask:
        extendedCommonFramer scaleMask & 2r000000011111111 .
    commonFlag := extendedCommonFramer scaleMask & 2r111111100000000.

!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties to aStream.  Append aString
        after every new line.  Start at 2 because
        'Part name:' is already printed. "

    2 to: propertyUnits size do: [ :i |
        ( self atIndex: i )
            partPrintPropertiesOn: aStream 
			margin: aString ]! 
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part.
        Do not let superclass do anything, we do it all here. "
    | colorChanged newValue oldSizes parts |

    colorChanged := false.
    self applyForeColorCheckBox value
        ifTrue: [
            newValue := self currentForeColor.
            self part do: [ :aPart |
                applyChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #foreColor:
                        arguments: (Array with: newValue) ).
                undoChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #foreColor:
                        arguments: (Array with: aPart foreColor) ) ].
            colorChanged := true ].

    self applyBackColorCheckBox value
        ifTrue: [
            newValue := self currentBackColor.
            self part do: [ :aPart |
                applyChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #backColor:
                        arguments: (Array with: newValue) ).
                undoChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #backColor:
                        arguments: (Array with: aPart backColor) ) ].
            colorChanged := true ].

    colorChanged
        ifTrue: [
            self part do: [ :aPart |
                applyChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #colorChange ).
                undoChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #colorChange ) ].
            ].

    self applyFontCheckBox value
        ifTrue: [
            newValue := ( newFont notNil
                ifTrue: [ newFont ]
                ifFalse: [ self partFont ] ).
            self part do: [ :aPart |
                applyChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #font:
                        arguments: (Array with: newValue) ).
                undoChangesActions
                    add: ( Message
                        receiver: aPart
                        selector: #font:
                        arguments: (Array with: aPart font) ) ]].

    ( self applySizeCheckBox value and: [ newSize notNil ])
        ifTrue: [
            parts := self part asOrderedCollection copy.
            oldSizes := parts collect: [ :aPart | aPart framingBlock copy ].
            applyChangesActions
                add: ( Message
                    receiver: self
                    selector: #applySizes:to:
                    arguments: ( Array with: newSize with: parts )).
            undoChangesActions
                add: ( Message
                    receiver: self
                    selector: #applySizes:to:
                    arguments: ( Array with: oldSizes with: parts )) ].
!   
doChanges
        " Private - apply the value if it has been changed. "

    self modified ifTrue: [ self part partSetGraphics: newValue ].!   
frameHeight
        "Private - answer the height of the receiver's frame.
        The message #height is used for layout while
        #frameHeight is used for the actual frame rectangle.
        The default frameHeight is the height."
    ^self height!
column
		" Private - answer the column in which the receiver is displayed. "

    ^column isNil
        ifTrue: [ 1 ]
        ifFalse: [ column ]!   
doChanges
		" Private - apply the value if it has been changed. "

    self shouldApplyChange
        ifTrue: [ self part perform: self changeSelector with: self newValue ].!
newValue
        " Answer the new value of the property. "

    ^super newValue isNil
        ifTrue: [ self staticTextItem label ]
        ifFalse: [ super newValue ]! 
constructApplyActions
        " Private - construct the sequence of actions which
        will apply the validatated property values to the part.
        To support undo, construct a parallel set of actions
        which apply the original property values to the part. "

    super constructApplyActions.

    self hasForeColorChanged
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #foreColor:
                    arguments: (Array with: newForeColor) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #foreColor:
                    arguments: (Array with: self partForeColor) ) ].

    self hasBackColorChanged
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #backColor:
                    arguments: (Array with: newBackColor) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #backColor:
                    arguments: (Array with: self partBackColor) ) ].

    ( self hasForeColorChanged or: [ self hasBackColorChanged ] )
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #colorChange ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #colorChange ) ].

    self hasFontChanged
        ifTrue: [
            applyChangesActions
                add: ( Message
                    receiver: self part
                    selector: #font:
                    arguments: (Array with: newFont) ).
            undoChangesActions
                add: ( Message
                    receiver: self part
                    selector: #font:
                    arguments: (Array with: self partFont) ) ].

    self hasSizeChanged
        ifTrue: [
            applyChangesActions
                add: (Message new
                    receiver: self part;
                    selector: #partPropertySetSize: ;
                    arguments: (Array with: newSize)).
            undoChangesActions
                add:  (Message new
                    receiver: self part;
                    selector: #partPropertySetSize: ;
                    arguments: (Array with: self partSize)) ].! 
partForeColor
        " Private - answer the part's foreground color value. "

    ^self part foreColor!   
dialogClosed
        " The dialog window has been closed. "

    self triggerEvent: #closed.
    ^nil!
applyBackColorCheckBox
        " Private "

    ^self partNamed: 'ApplyBackcolorCheckBox'! 
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | aGraphicItem |
    aGraphicItem := newValue isBitmap
        ifTrue: [ PARTSStaticGraphicPart bitmap: newValue ]  " only get to this on VOS "
        ifFalse: [ PARTSStaticGraphicPart icon: newValue ].
    aTopPane addSubpane: ( aGraphicItem
        framingBlock: self framingBlock )!
labelMax
        "Answer the maximum size allowed for the receiver's label."
    "^36"
    ^64!
fileName
        " Private - Answer the name of the part file
        containing the default property dialog for a
        visual part. "

	^'PPOVSPRT.PAR'! 
computeWidth
        "Private - compute and answer the width of the receiver."

    self implementedBySubclass!
partContext
        " Answer a dictionary of context info for the part. 
		The context entries can be used as desired by the client. "

    ^partContext! 
addToWindow: aTopPane
		" Private - create a list pane in <aTopPane> to represent
		the receiver's value. "

	| aListPane |
    aTopPane
        addSubpane: ( StaticText new
            font: self font;
            contents: label;
            framingBlock: self labelFramingBlock );
        addSubpane: ( aListPane := ListBox new
            font: self font;
            owner: self;
            list: list;
            value: (oldValue isNil ifTrue: [nil] ifFalse: [oldValue]);
            when: #changed: send: #select: to: self;
            framingBlock: self framingBlock ).
	self controls: aListPane.!  
textEntryItem
        " Answer the pane containing the string value. "

    ^self controls!
partFinalize
        "Finalize the receiver by releasing any system resources."

    propertyUnits do: [ :p | p partFinalize ].
    actions do: [ :m | m partFinalize ].
    undoActions do: [ :m | m partFinalize ]!
firstStyleVerticalGap
        "Private - answer the vertical distance between
        the top of the styles box and the top of the top
        most style control."
    ^PARTSDialog standardEntryHeight - 1! 
COMMENT
"
A PARTSPropertyEditButton provides a push button element
in a property dialog which opens a subdialog to edit
the value associated with the button.  The edit property
property manages the value.  

The client is responsible for initializing the value when an 
edit button property is created, by sending #value: to the 
edit button property.  Send the #label: message to specify 
the push button label and #clickedSelector to specify the 
message to send to the part when the button is clicked. 
A #changeSelector: message should also be sent when 
the edit button is created to specify the message sent to 
the part when a changed value is applied.

The client is responsible for updating the value when the 
subdialog closes if the property value is changed, by 
sending #newValue: to the edit button.  This is typically done
in the method registered as the #clickedSelector: for the button.
"!
numberFieldExtent
        "Private - answer the default extent
        of an number entry field."
    ^self numberFieldWidth @ self entryFieldHeight!  
COMMENT
"
A PARTSPropertyIcon represents an icon property
with a graphic image and a push button which opens
the PARTS icon editor.
"!   
part
        " Private - answer the part whose properties are being edited. "

    ^part!  
hasBackColorChanged
        " Private -  answer whether the background color has been changed. "

    ^newBackColor ~= #uninitialized! 
applyForeColorCheckBox
        " Private "

    ^self partNamed: 'ApplyForecolorCheckBox'! 
changeButtonClicked
        " Private - the change button was pressed. "
    | index |
    index := listBox selection.
    index isNil ifTrue: [^self].
    array at: index put: itemField contents.
    listBox restoreWithRefresh: index; setFocus!   
staticTextItem: aStaticText
		" Private "

	self controls: aStaticText.!   
setBottomValue: aValue
    "Private"
    | bottom |

    aValue isNil ifTrue: [ ^self ].

    bottom := aValue asNumber.
    framers do: [ :aFramer | aFramer bottom: bottom ].
    self updateCommonFramer.
!   
registerUndoRedo
		" Private - register undo/redo actions with the part's editor. "

	editor isNil ifTrue: [ ^self ].
    editor
		recordUndo: ( Message
            receiver: self
            selector: #undoPropertyChanges )
		undoLabel: 'property changes'
		redo: ( Message
            receiver: self
            selector: #redoPropertyChanges )
        redoLabel: 'property changes'.!
label: aString
		" Specify the label of the property unit. "

    label := aString!
putProperty: aPropertyUnit
        "Store aPropertyUnit in the receiver.  The sender of this
        doesn't feel the need to specifiy a key, so use an arbitrary key.
        Note this relieves the sender of insuring unique keys for entries,
        which can be difficult is the code that builds the receiver is
        spread out over many methods and or classes.  The only
        restriction this imposes is that the sender cannot use negative
        Integers for keys."

    self at: self nextId putProperty: aPropertyUnit!
select: selectedItem
        " Private - an item has been selected in the list. "

    self isImmediatelyValid
        ifFalse: [ ^self ].  " validation failed "
    self newValue: selectedItem.!  
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's 
		property value to <aStream>.  Do nothing for a graphic. "!  
applyPartName: aString
        " Private - set the name of my part to aString. "

    self part partWrapper changeNameTo: aString.!
ok
        " Private - the OK button was pressed. "

    properties dialogClickedOK 
        ifTrue: [ self close ].! 
initWindowSize
        "Private - Answer the default window size."
    ^160 @ 120!  
extendedCommonFramer
        " Private - answer the part's size.
            Answer a special framer with 7 extra bits at
        the front.
            The first bit flags whether the scale units are
        common and should be used.  If it is set, the
        scale units are NOT common.
            The second bit flags whether the horizontal
        attributes are common and should be used, and
        the third bit flags whether the vertcial attributes
        are common and should be used.  If they are set,
        the attributes are NOT common.
            If the attributes are common, the fourth, fifth,
        sixth, and seventh bits flag whether the left, right,
        top, and bottom values, respectively, are common.
        If they are set, the values are NOT common."
    | anExtendedFramer framersCopy
      horizontalAttributesMask verticalAttributesMask
      commonHorizontalScaleMask commonVerticalScaleMask
      commonScaleUnit
      left right top bottom |

    framers size = 1 ifTrue: [ ^framers first ].

    horizontalAttributesMask := 2r11110000.
    verticalAttributesMask := 2r00001111.
    commonHorizontalScaleMask := true.
    commonVerticalScaleMask := true.
    commonScaleUnit := true.

    framersCopy := framers copy.
    anExtendedFramer := framersCopy first copy.
    left := anExtendedFramer left.
    right := anExtendedFramer right.
    top := anExtendedFramer top.
    bottom := anExtendedFramer bottom.

    framersCopy removeFirst.
    framersCopy do: [ :aFramer |
        commonHorizontalScaleMask
            ifTrue: [
                commonHorizontalScaleMask :=
                    ( aFramer scaleMask & horizontalAttributesMask ) =
                        ( anExtendedFramer scaleMask & horizontalAttributesMask ).
                ( left notNil and: [ left ~= aFramer left ]) ifTrue: [ left := nil ].
                ( right notNil and: [ right ~= aFramer right ]) ifTrue: [ right := nil ]].
        commonVerticalScaleMask
            ifTrue: [
                commonVerticalScaleMask :=
                    ( aFramer scaleMask & verticalAttributesMask ) =
                        ( anExtendedFramer scaleMask & verticalAttributesMask ).
                ( top notNil and: [ top ~= aFramer top ]) ifTrue: [ top := nil ].
                ( bottom notNil and: [ bottom ~= aFramer bottom ]) ifTrue: [ bottom := nil ]].
        commonScaleUnit :=
            commonScaleUnit and: [ aFramer scaleUnit = anExtendedFramer scaleUnit ]].

    commonScaleUnit
        ifFalse: [
            anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r100000000000000.
            left := nil.
            right := nil.
            top := nil.
            bottom := nil ].
    commonHorizontalScaleMask
        ifFalse: [
            anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r010000000000000.
            left := nil.
            right := nil ].
    commonVerticalScaleMask
        ifFalse: [
            anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r001000000000000.
            top := nil.
            bottom := nil ].
    left notNil ifTrue: [ anExtendedFramer left: left ].
    right notNil ifTrue: [ anExtendedFramer right: right ].
    top notNil ifTrue: [ anExtendedFramer top: top ].
    bottom notNil ifTrue: [ anExtendedFramer bottom: bottom ].

    left isNil ifTrue: [
        anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r00100000000000 ].
    right isNil ifTrue: [
        anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r00010000000000 ].
    top isNil ifTrue: [
        anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r00001000000000 ].
    bottom isNil ifTrue: [
        anExtendedFramer scaleMask: anExtendedFramer scaleMask | 2r00000100000000 ].

    ^anExtendedFramer
!   
partEditValue
        "Open a window to edit the receiver.
        Answer the new value (a PARTSException if cancelled)."
    ^PARTSPrompter prompt: 'Enter expression:' defaultExpression: self printString!  
hasNameChanged
        " Private - answer whether the part name has been changed. "

    ^self
        isNewString: self newPartName
        differentFrom: self partName.!  
currentForeColor
        " Private - Answer the current foreColor selected. "
    ^currentForeColor == #uninitialized
		ifTrue: [self part foreColor]
		ifFalse: [currentForeColor ]! 
layoutHorizontalGroupClass: aClass
        " Private - specify the class which represents a horizontal group in a form. "

    LayoutHorizontalGroupClass := aClass.!