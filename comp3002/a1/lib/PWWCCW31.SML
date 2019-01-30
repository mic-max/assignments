3.1.0.106
   
ok: aTextPane
        " Private - the OK button was pressed "
    answer := aTextPane streamContents.
		"( aTextPane modified
        ifTrue: [ aTextPane streamContents ]
        ifFalse: [ nil ] )."    "modified is not reliable for RichEdit"
    self close.! 
partMirrorCopyReal: aMirrorCopyDictionary
        "Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy."
    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy pageIncrement: ( self pageIncrement partMirrorCopy: aMirrorCopyDictionary ).
    ^copy!
codeGenerationAddAttributeMessagesTo: anExpressionModel
	"Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."

	super codeGenerationAddAttributeMessagesTo: anExpressionModel.
	anExpressionModel addSelectorIfNotNil: #value: with: self value!
isHidden
	"Answer true if the receiver is enabled, else return false."

	^self tool isHidden!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #image: with: self image;
        addSelectorIfNotNil: #label: with: self label;
        addSelectorIfNotNil: #tipText: with: self tipText

!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #playCompleted
            )
        separators: #( )
        defaultItem: #playCompleted!  
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."

   ^anObject partIsWindow
        and: [anObject isPARTSWindow not
        and: [anObject isPARTSMenuComponent not
        and: [anObject isPARTSMenuItem not
        and: [anObject isPARTSNotebook not]]]]!  
partAboutToAddTo: anApplication
        "The receiver is about to be added as a part to
        anApplication.  If the wrapper is not nil, about
        to add through a 'duplicate part' function.  The
        duplicate logic resizes the framer to the notebook
        part.  Need the framer to be relative to the client
        area pane."

    self partWrapper notNil
            ifTrue: [
                self framingBlock: self defaultFramer.
                self partWrapper rectangle: framingBlock ].

    ^super partAboutToAddTo: anApplication!  
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. "
    self simpleModeText: text.!  
deletePageNumber: index

    "Delete the item with the number <index>."

    self partIsEditing ifTrue: [
        self partEditor selectOffAll ].
    super deletePageNumber: index!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #open #isOpen #close
            #openDoor #closeDoor #pause #play #playFrom: #playFrom:to: #reset #resume #stop
            #length #position #position: #currentTrack #currentTrack: #lengthOfTrack: #positionOfTrack: #numberOfTracks #isTimeFormatMilliseconds #isTimeFormatMsf #isTimeFormatTmsf #timeFormat #timeFormatMilliseconds #timeFormatMsf #timeFormatTmsf #timeFormat:
            #isNotReady #isPaused #isPlaying #isReady #isSeeking #isStopped #isMediaPresent
            #audio: #audioLeft: #audioRight:
        )
        separators: #( 3 12 28 35 38 )
        defaultItem: #play! 
updateTool
	" Private- Update the tool  the receiver is wrapping. "

	tool hide: tool isHidden.
	tool detach: tool isDetached.!   
triggerApplyEvents
	"Trigger apply events for all the page controls."

	| pages |
	pages := self pages.
	pages size > 0 ifTrue: [
		pages do: [ :page |
			page controls first triggerEvent: #apply: with: page controls first ] ].!   
toolLabelAddedTo: aTool
adjustHeight: adjustHeight
	"Private - <aTool> has had a label added.  Update
    the appropriate structures.  Increase the tool height
    if <adjustHeight> is true."

	toolsWithLabels add: aTool.
	toolsWithLabels size = 1
		ifTrue:
			[self toolHeight: aTool frameRectangle height.
			adjustHeight
				ifTrue: [self toolHeight: self toolHeight + 14]]. "Not just moving <aTool>"
	self maxWidth: (self toolWidth max: ((aTool pen stringWidthOf: aTool label) + aTool labelPadding)).
	self refreshItems: adjustHeight.!  
isDetachedContainer: aBoolean
	" Set if the receiver is being used as the detached container "

	self propertyAt: #isDetachedContainer put: aBoolean!  
constructPropertyManager
	^super constructPropertyManager
		add: ( SelectorPropertyAccessor new name: 'Numeric'; get: #isNumeric; set: #numeric: ; format: 'Boolean' );
		add: ( SelectorPropertyAccessor new name: 'Left Justified'; get: #isLeftJustified; set: #leftJustified: ; format: 'Boolean' );
		add: ( SelectorPropertyAccessor new name: 'Centered'; get: #isCentered; set: #centered: ; format: 'Boolean' );
		add: ( SelectorPropertyAccessor new name: 'Right Justified'; get: #isRightJustified; set: #rightJustified: ; format: 'Boolean' );
		addNames: #( 'Left Justified' 'Centered' 'Right Justified' 'Numeric' ) toPage: 'Style';
		addGroupEditor: 'ppspnbtn.par';
		yourself! 
partIsDragable
        "Private - Answer true if dragable and resizable."
    ^false!   
basicDrawMark: slot
	"Private - Draw the insertion mark at the column <col> "

	| components itemColumn gapX gapY rect offsetAfterColumn toolItemRect |
	(slot isNil)
		ifTrue: [^false].
	components := self partWrapper components.
	itemColumn := components size min: slot.
	gapX := self gapWidth // 2.
	gapY := self gapHeight // 2.
	itemColumn = 0
		ifTrue:
			[ "No contents yet"
			rect := self gapWidth @ self gapHeight extent: (self toolWidth @ self toolHeight)]
		ifFalse:
			[toolItemRect := (components at: itemColumn) object frameRelativeRectangle.
			slot > itemColumn
				ifTrue:
					[ "After last column"
					offsetAfterColumn := toolItemRect width + (gapX + 2)]
				ifFalse:
					[offsetAfterColumn := gapX negated].
			rect := toolItemRect moveBy: (offsetAfterColumn @ gapY)].
	" draw an I-beam "
	self
		doGraphics:
			[self
				pen foreColor: Color black;
				setLineWidth: 2;
				setForegroundMode: MixRuleInvertSurface;
				place: (rect leftTop left: gapX);
				line: (rect leftTop right: gapX);
				place: (rect leftTop down: 2);
				line: (rect leftBottom up: 2);
				place: (rect leftBottom left: gapX);
				line: (rect leftBottom right: gapX);
				setForegroundMode: MixRuleDefault]! 
resizeToRectangle: aRect
	" Private - resize the receiver to <aRect>. "

	| oldRect |
	oldRect := self frameRelativeRectangle.
	super resizeToRectangle: aRect.
	oldRect extent = aRect extent
		ifFalse: [self updatePositions]!  
partSetContents: aList
    self contents: aList! 
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "

    ( self propertyManager ) editFor: self!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #pageIncrement: with: self pageIncrement
!  
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."

    "self partsVwOnly."  " only used on Win32 "
    self partIsEditing ifTrue: [
         ^HtClient ].
    ^nil!   
label: aString
	" Set the label of the receiver's tool."

	self tool label: aString.!  
toolClass
	" Return the class which the receiver is representing. "

	^ToolbarSeparator!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    ^ self partFontOrSysFont charSize * (30 @ 15)! 
labelPadding
	"Private - answer the number of pixels"

	^4!
constructPropertyManager

	^super
		constructPropertyManager
		add:
			(StylePropertyAccessor
				name: 'Tab as button'
				style: 'TcsButtons'
				pool: WinCommonControlConstants);
		add:
			(StylePropertyAccessor
				name: 'Multi line tabs'
				style: 'TcsMultiline'
				pool: WinCommonControlConstants);
		add:
			(StylePropertyAccessor
				name: 'Tab fixed width'
				style: 'TcsFixedwidth'
				pool: WinCommonControlConstants);
		add:
			(StylePropertyAccessor
				name: 'Ragged right'
				style: 'TcsRaggedright'
				pool: WinCommonControlConstants);
		add:
			(StylePropertyAccessor
				name: 'Tool tips'
				style: 'TcsTooltips'
				pool: WinCommonControlConstants);
		add:
			(SelectorPropertyAccessor
			new name: 'Tab width';
			get: #getItemWidth;
			set: #setItemWidth:;
			format: 'Integer');
		add:
			(SelectorPropertyAccessor
			new name: 'Tab height';
			get: #getItemHeight;
			set: #setItemHeight:;
			format: 'Integer');
		add:
			(SelectorPropertyAccessor
			new name: 'Order page';
			get: #pagesCopy;
			set: #reorderPages:;
			format: 'List');
		add:
			(SelectorPropertyAccessor
			new name: 'Select page';
			get: #pageNumber;
			set: #turnToPageNumber:;
			format: 'List');
		add:
			(SelectorPropertyAccessor
			new name: 'Demand load';
			get: #demandLoad;
			set: #demandLoad:;
			format: 'Boolean');
		groupOrderAddList: #( 'Order page' 'Select page' );
		addGroupEditor: 'pptabctl.par';
		yourself!  
partMirrorCopyReal: aMirrorCopyDictionary
	" Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

	| copy |
	copy := super partMirrorCopyReal: aMirrorCopyDictionary.
	copy tool: (tool partMirrorCopy: aMirrorCopyDictionary).
	^copy!
partFrameRectangleFrom: aRectangle
	" Private - Answer the receiver's default rectangle when being dropped
      into the Workbench. "

	| partsFramer height |
	partsFramer := PARTSFramer new.
	height := partsFramer pixelToScaleUnitVertical: aRectangle height.
	partsFramer
		left: 0
			stretched: false
			right: 0
			stretched: false;
		top: 0
			stretched: false
			height: height
			stretched: false.
	^partsFramer!   
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self contents isNil
		ifTrue: [ nil ]
		ifFalse: [ self contents collect: [ :item | item string ] ]!
release
	"Private -  release the bitmap."

	tool release.! 
toolContainers
	" Private - answer the wrappers for the ToolContainers of the receiver. "

	^self partWrapper components
		select:
			[:c |
			(c object isPARTSToolContainer)].!   
partEvents
	" Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#needsContents #changed #clicked: #doubleClicked #beginAdjust #endAdjust #reset)
			separators: #(1 4)
			defaultItem: #needsContents!  
toolWidth
	" Answer the toolWidth of the receiver. "
	^toolWidth max: self maxWidth
	! 
enable
	"Enable the receiver.  Answer true if it is successful, else false.
     Trigger the #enabled event. "

	^self tool enable!   
constructPropertyManager
	^super constructPropertyManager
		removeProperty: 'Backcolor';
		removeProperty: 'Forecolor';
		add: ( StylePropertyAccessor name: 'Buttons' style: 'HdsButtons' pool: WinCommonControlConstants );
		addNames: #( 'Buttons' ) toPage: 'Style';
		addGroupEditor: 'ppheader.par';
		yourself!
partDefaultExtentWithLabel
	" Answer the default extent of the receiver
        in a PARTS application when it contains a label..   "

	^ToolbarItem defaultWidth @ (ToolbarItem defaultHeight + 14)! 
gapHeight
	"Private - Answer the gap height between the children."

	^self toolHeight // 4!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #changed: #changedIndex: #changing: #changingIndex:
            #nextLine #previousLine
            #rightClicked #tabbed )
        separators: #( 4 6 )
        defaultItem: #changed:!   
constructPropertyManager
	^super constructPropertyManager
		removeProperty: 'Backcolor';
		removeProperty: 'Forecolor';
		removeProperty: 'Font';
		add: ( SelectorPropertyAccessor new name: 'Stretch'; get: #stretch; set: #stretch: ; format: 'Boolean' );
		addNames: #( 'Stretch' ) toPage: 'Style';
		addGroupEditor: 'ppvidpan.par';
		yourself!   
partMessages
        " Answer the PARTS messages interface of the receiver. "
    | templateInterface |
    templateInterface := PARTSInterfaceList emptyList.
    templateInterface := templateInterface
        concatenateSeparated: ( PARTSInterfaceList new items: #(#simpleModeText: #simpleMode: ) )
        		defaultItem: templateInterface defaultItem.
    ^templateInterface
        concatenateSeparated: self partMessagesFields
        		defaultItem: templateInterface defaultItem! 
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
partEditTextContents: aStream
	"Private - External"
	"Bring up a window to edit the receiver's contents."

    ^PARTSSimpleRichTextEditor new
        openOn: aStream
        label: self partName, ' Properties - Edit'!   
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
defaultBackColor
	"Answer the default background color for the receiver class."
	^Color dialogBackground!   
turnToPageNumber: anInteger
	"Turn to page number <anInteger>.  If <anInteger> is out of range,
       do nothing."

	self partIsEditing
		ifTrue: [self partEditor selectOffAll].
	super turnToPageNumber: anInteger!  
isRightJustified
		"Private - provide a property manager style accessor for rightJustified attribute."
	^self listAttribute notNil and: [ self entryField hasStyle: EsRight ]!  
partRealSelectorFor: aSelector
        " Private - Answer the message to send for an alias link"

    ( self fieldGetMessages includes: aSelector )
        ifTrue: [ ^#fieldGet:arguments: ].
    ( self fieldSetMessages includes: aSelector )
        ifTrue: [ ^#fieldSet:arguments: ].
    ^aSelector!
addTool: aTool
	"Private - add a tool as a child of the receiver."

	super addSubpane: aTool ! 
toolWidth
	" Answer the toolWidth of the tools in the Toolbox "

	^self toolbox toolWidth! 
release
	"Private -  release the bitmap."

	self bitmapClone notNil
		ifTrue: [self bitmapClone archiveAndRelease].
	tool release.
	!   
display
	" Display the receiver. "

	self
		doGraphics:
			[graphicsTool
				backColor: Color menuBackground;
				foreColor: Color menuText;
				font: self displayFont;
				fill: Color menuBackground].
	!
isDetached
	" Answer if the receiver is detached. "

	^self tool isDetached!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #needsContents #needsStringFor: #needsImageFor: #needsSmallImageFor: #needsColumnsFor:
            #changed: #clicked: #clickedIndex: #doubleClicked: #doubleClickedIndex: #selected: #columnClicked:
            #aboutToEditLabel: #aboutToChangeLabel:to: #changedLabel:to: #characterTyped:
            #tabbed )
        separators: #( 5 12 16 )
        defaultItem: #changed:!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.

    copy innerParts: ( innerParts partMirrorCopy: aMirrorCopyDictionary );
        minimumHeight: minimumHeight.
    ^copy!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    self pages notNil ifTrue: [
        self pages do: [ :item |
            anExpressionModel addSelector: #addPage: with: item ]].
    anExpressionModel addSelector: #turnToPageNumber: with: self pageNumber! 
constructPropertyManager
   "Construct accessors for receiver's properties."

    ^super constructPropertyManager
        add: ( SelectorPropertyAccessor name: 'Part name' get: #partName set: #partName: editor: nil
            validator: PropertyManager validatorForPartName );
        add: ( SelectorPropertyAccessor name: 'Icon' get: #partIcon set: #partIcon:
            editor: PropertyManager editorForIcon );
        add: ( SelectorPropertyAccessor name: 'Interface' get: nil set: nil editor: #partEditInterface );
        addNames: #('Part name' 'Icon'  'Interface' ) toPage: 'General';
        addGroupEditor: 'ppmcid.par';
        yourself!  
partDefaultExtent
	"Private - External. Answer the default extent of the receiver
        in a PARTS application. "

	^self partFontOrSysFont charSize * (15 @ 6) + (0 @ 10) "add 10
        to height so that there won't be spaces after the bottom line"! 
partEditProperties
	"Private - Open an editor on the PARTS properties of the receiver. "

	(self propertyManager) editFor: self!   
partDefaultExtent
	" Answer the default extent of the receiver
        in a PARTS application.   "

	^self partSize!  
partEditProperties
	" Open an editor on the PARTS properties of the receiver. "

	(self propertyManager) editFor: self!
partCanHaveChild: anObject
	"Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."

	^anObject isPARTSToolbarItem or: [anObject isSubPane]!   
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
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
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( #needsContents #needsMenu )
        separators: #( )
        defaultItem: #needsContents! 
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject isKindOf: PARTSTabControlPagePart ]! 
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
	"Private - add message models to rebuild the receiver to anExpressionModel."

	| application messageModel expressionModel orderedChildren orderedChildrenSelector methodModel |
	application := self partApplication.
	self childrenInBuildOrder
		do:
			[:child |
			messageModel := anExpressionModel addSelector: #addTool:.
			expressionModel := messageModel newExpressionArgument.
			expressionModel
				setReceiverToSelf;
				addSelector: (application selectorForComponentBuild: child) with: application].
	orderedChildren := self orderedChildren.
	orderedChildren size > 0
		ifTrue:
			[orderedChildrenSelector := ('getOrderedChildrenOf' , self partName , 'In:') asSymbol.
			messageModel := anExpressionModel addSelector: #orderedChildren:.
			expressionModel := messageModel newExpressionArgument.
			expressionModel
				setReceiverToSelf;
				addSelector: orderedChildrenSelector with: self partApplication.
			methodModel := anExpressionModel classModel newClassMethodNamed: orderedChildrenSelector.
			methodModel
				argumentModels: self partApplication applicationArgumentModels;
				comment: 'Private - answer the ordered children of ' , self partName.
			methodModel newMessageExpression receiverObject: orderedChildren]!  
isPARTSToolbarItem
	" Answer whether the receiver is a valid tool which can be  used
       within a Toolbar control."

	^true!   
partSetDirectEditAttributeAddChildItemsFrom: stringCollection startingAt: index to: rootItem level: level
	| string item tabs |
	index > stringCollection size ifTrue: [ ^self ].
	string := stringCollection at: index.
	tabs := string occurrencesOf: 9 asCharacter.
	tabs < level ifTrue: [ ^self ].
	tabs = level
		ifTrue: [
			item := TreeViewItem new
				object: string trimBlanks;
				string: string trimBlanks.
			rootItem children isNil ifTrue: [ rootItem children: OrderedCollection new ].
			rootItem children: ( rootItem children asOrderedCollection add: item; yourself ).
			rootItem childrenExpanded: true.
			self partSetDirectEditAttributeAddChildItemsFrom: stringCollection startingAt: index + 1 to: item level: level + 1.
			self partSetDirectEditAttributeAddChildItemsFrom: stringCollection startingAt: index + 1 to: rootItem level: level  ]
		ifFalse: [
			self partSetDirectEditAttributeAddChildItemsFrom: stringCollection startingAt: index + 1 to: rootItem level: level ]!  
partSize
	" Private - Answer the  extent of the receiver
        in a PARTS application.   "

	^self parent isNil
		ifTrue: [ToolbarItem defaultWidth @ (ToolbarItem defaultHeight)]
		ifFalse: [self parent toolWidth @ self parent toolHeight].!  
disable
	" Disable the receiver.  Answer true if it is successful, else false. "

	^self tool disable.!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #contents #contents:
            #columnWidths )
        separators: #( 3 5 )
        defaultItem: #value!  
partMessages
	"Private - Answer the PARTS message interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#enable #disable #setFocus 
				#value #setValue: #unformattedContents #append: #insert: #setFromFile: #saveToFile: #clear 
				#selectAll #selectedText #cutSelection #copySelection #pasteSelection #clearSelection
				#undo 
				#isModified #clearModified #setModified 
				#changeColor #changeFont #changeParagraph #changeTabs #growTextLimit #print)
			separators: #(3 11 17 18 21)
			defaultItem: #value!
format: aTextPane
    "Private - Pop up the format menu for <aTextPane>."

    | selector |
    selector := ( RichEdit formatMenu owner: aTextPane )
        popUpIn: aTextPane.
    selector notNil ifTrue: [ aTextPane perform: selector ]!   
partEvents
        " Answers the part events interface of the receiver"
    ^PARTSInterfaceList new
        items: #(
            #rightClicked )
        separators: #( )
        defaultItem: #rightClicked!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #image: with: self image;
        addSelectorIfNotNil: #state: with: self state!
partAddUnder: parentWindow wrapper: myWrapper
	"Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "

	| realParentWindow oldRect |
	self partWrapper: myWrapper.
	owner := myWrapper application.
	page isNil
		ifTrue:
			[page := TabControlPage new.
			page label: ''. "force a label so that the page can be selected"
			page addSubpane: self].
	(parentWindow isKindOf: self class)
		ifTrue: [realParentWindow := parentWindow superWindow]
		ifFalse: [realParentWindow := parentWindow].
	(realParentWindow isKindOf: PARTSTabControlPart)
		ifTrue:
			[
			oldRect := realParentWindow rectangle.
			realParentWindow insertPageAtSelection: page.
			myWrapper parent removeComponent: myWrapper. "may have dropped on another page"
			realParentWindow partWrapper addComponent: myWrapper.
			realParentWindow addSubpane: self. 
			oldRect = realParentWindow rectangle
				ifFalse: [ realParentWindow resizeChildren ].
			realParentWindow sendDeferredEvent: #selectPage: with: page
			].
	! 
toolHeight
	" Answer the tool height of the tools in the Toolbox "

	^self toolbox toolHeight! 
partEditDirect
	"Edit the directly visible part properties of the receiver."

	self partEditor workbenchPane lafEditNone: self!
codeGenerationAddAttributeMessagesTo: anExpressionModel
	"Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."

	super codeGenerationAddAttributeMessagesTo: anExpressionModel.
	anExpressionModel
		addSelectorIfNotNil: #autoSaveOnClose: with: self autoSave;
		addSelectorIfNotNil: #bitmapWidth: with: self bitmapWidth;
		addSelectorIfNotNil: #bitmapHeight: with: self bitmapHeight;
		addSelectorIfNotNil: #registrationKeyName: with: self registrationKeyName;
		addSelectorIfNotNil: #registrationValueName: with: self registrationValueName;
		addSelectorIfNotNil: #toolWidth: with: self toolWidth;
		addSelectorIfNotNil: #toolHeight: with: self toolHeight;
		addSelectorIfNotNil: #setItems: with: self tools!   
partIsDragable
	"Private - Answer true if dragable and resizable."

	^false!   
makeIndeterminate
	"Make the receiver indeterminate.  "

	^self tool makeIndeterminate.!   
drawGrid: anInteger
	"Private - Draw grid lines with anInteger spacing on the receiver medium."

	| i width height pen oldForeColor |
	i := 0.
	width := rectangle width.
	height := rectangle height.
	pen := self graphicsTool.
	oldForeColor := pen foreColor.
	pen foreColor: Color white.
	pen
		setLineWidth: 1;
		setForegroundMode: "R2Copypen" 13;
		setLineType: 0.
	[i < width]
		whileTrue:
			[pen
				place: i @ 0;
				goto: i @ height.
			i := i + anInteger].
	i := 0.
	[i < height]
		whileTrue:
			[pen
				place: 0 @ i;
				goto: width @ i.
			i := i + anInteger].
	pen foreColor: oldForeColor!   
partMirrorCopyReal: aMirrorCopyDictionary
        "Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy."
    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy headingsAttribute: ( self headings partMirrorCopy: aMirrorCopyDictionary ).
    ^copy! 
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
   " ^SysFont width * 12 @ (SysFont height * 5)"
    ^ self partFontOrSysFont charSize * (15 @ 6) + (0 @ 6)!  
isDisabled
	"Answer true if the receiver is disabled, else return false."

	^self tool isDisabled! 
defaultFramer
        " Private - Answer the framer for the notebook page part "
    ^PARTSFramer new
        useAllInset;
        left: 0 bottom: 0 right: 0 top: 0! 
addSubpane: aTool
	"Add <aTool> as the child of the receiver."

	(aTool isPARTSToolbarItem and: [(self toolbox toolsWithLabels includes: aTool) not and: [aTool label size > 0 and: [self partIsEditing]]])
		ifTrue:
			[ "Adjust the width of all tool items"
			aTool whenValid: #setLabel: with: aTool label].
	super addSubpane: aTool!   
isLeftJustified
		"Private - provide a property manager style accessor for leftJustified attribute."
	^self listAttribute notNil and: [ self entryField hasStyle: EsLeft ]! 
partGetGraphics
	"Answer the receiver's bitmap."

	bitmap isNil
		ifTrue: [^Bitmap screenExtent: self imageSize]
		ifFalse: [^bitmap]!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "

    ^15@6 * self partFontOrSysFont charSize! 
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
partSetContents: aList
        " Set the PARTS contents of the receiver. "
    self contents: aList!
partSetDirectEditAttribute: stringCollection
        "Private - set the direct-edit attribute of the receiver
        to text."
	| itemList |
	itemList := OrderedCollection new.
	self partSetDirectEditAttributeAddRootItemsFrom: stringCollection to: itemList.
	self contents: itemList.
	^itemList!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
			#minimum #minimum: #maximum #maximum: #position #position: #minimum:maximum: #minimum:maximum:position:
			#decrementPosition #decrementPositionBy: #incrementPosition #incrementPositionBy:
			#lineIncrement #lineIncrement:
            #enable #disable
            #value #setValue: )
        separators: #( 8 12 14 16 )
        defaultItem: #position!   
bitmap
	"Answer the receiver's tool's bitmap."

	self tool bitmap isNil
		ifTrue: [self bitmap: self bitmapClone].
	^self tool bitmap!   
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super
		constructPropertyManager
		add:
			(SelectorPropertyAccessor
			new name: 'Grouped';
			get: #isGrouped;
			set: #group:;
			format: 'boolean');
		add:
			(SelectorPropertyAccessor
			new name: 'Wrapped';
			get: #isWrapped;
			set: #wrap:;
			format: 'Boolean');
		addNames: #('Grouped' 'Wrapped') toPage: 'Style';
		add:
			(SelectorPropertyAccessor
			new name: 'Enabled';
			get: #isEnabled;
			set: #enable:;
			format: 'Boolean');
		add:
			(SelectorPropertyAccessor
			new name: 'Hidden';
			get: #isHidden;
			set: #hide:;
			format: 'Boolean');
		add:
			(SelectorPropertyAccessor
			new name: 'Indeterminate';
			get: #isIndeterminate;
			set: #indeterminate:;
			format: 'Boolean');
		addNames: #('Enabled' 'Hidden' 'Indeterminate') toPage: 'State';
		add:
			(SelectorPropertyAccessor
				name: 'Image'
				get: #bitmap
				set: #setBitmap:
				editor: PropertyManager editorForBitmap);
		add:
			(SelectorPropertyAccessor
			new name: 'Label';
			get: #label;
			set: #setLabel:);
		add:
			(SelectorPropertyAccessor
			new name: 'Tip';
			get: #tip;
			set: #setTip:);
		addNames: #('Image' 'Label' 'Tip') toPage: 'Settings';
		removeProperty: 'Forecolor';
		removeProperty: 'Backcolor';
		removeProperty: 'Font';
		removeProperty: 'Size window';
		addGroupEditor: 'pptoolbt.par';
		yourself!   
numeric: aBoolean
		"Private - provide a property manager style accessor for numeric attribute."
	aBoolean
		ifTrue: [
			self contents: nil.
			self rightJustified ]!  
width
	"Answer the width of the receiver."

	^self tool width! 
isOn
	"Answer true if the receiver is turned on or checked, else return false."

	^self tool isOn! 
pagesCopy
	"Private - Answer a copy of the collection of pages."

	^ items copy!   
partMessagesFields
        " Private - answer the message interface
        for parameter get/set messages "
    | getMessages setMessages |
    ((getMessages := self fieldGetMessages) size = 0)
        ifTrue: [ ^PARTSInterfaceList emptyList ].
    setMessages := self fieldSetMessages.
    ^PARTSInterfaceList new
        items: (getMessages, setMessages)
        separators: (Array with: getMessages size)
        defaultItem: (getMessages at: 1)!  
isEnabled
	"Answer true if the receiver is enabled, else return false."

	^self tool isDisabled not.!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #valueIndex #setValueIndex:
            #list #setList: #minimum: #maximum:
            #master #master:
            )
        separators: #( 3 7 11 )
        defaultItem: #value! 
expand
	"Private - Expand the receiver to make space for more items.
    The receiver has proportional attributes, so need to resize the
    toolbox by an amount that will achieve the desired absolute height."

	self toolbox
		expand:
			((self toolHeight + self gapHeight) / (self framingBlock isBottomStretched
			ifTrue: [1 - self framingBlock bottom]
			ifFalse: [1 - self framingBlock top])) asInteger.! 
updatePositions
	"Private - Update the positions of each item in the receiver."

	self toolContainers
		do:
			[:each |
			each object updatePositions].
	!
isPARTSToolbar
	" Answer whether the receiver is  a Toolbar control."

	^true! 
toolClass
	" Return the class which the receiver is representing. "

	^ToolbarButton!  
partEditProperties
	" Open an editor on the PARTS properties of the receiver. "

	(self propertyManager) editFor: self!
toolClass
	" Return the class which the receiver is representing.
      Should be re-implemented by subclasses. "
	^self implementedBySubclass

	!   
maxWidth: anInteger
	" Private - Set the maximum width of the tools in the receiver "

	maxWidth := anInteger! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #columns: with: self columns;
        addSelectorIfNotNil: #image: with: self image;
        addSelectorIfNotNil: #smallImage: with: self smallImage!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #valueIndex #setValueIndex:
            #list #setList: #insertItem: #deleteItem: #deleteAll
            #checkIndex: #checkItem: #uncheckIndex: #uncheckItem: #indeterminateIndex: #indeterminateItem:
            #abortChange
            )
        separators: #( 3 7 12 18 )
        defaultItem: #value! 
partEditDirect
	"Edit the directly visible part properties of the receiver."

	self partEditor workbenchPane lafEditNone: self!
bitmapClone
	" Private - answer the bitmap of the receiver. "
	^bitmap! 
tool
	" Answer the tool object the receiver is wrapping. "

	tool isNil
		ifTrue: [self createTool].
	^tool! 
partCanBeReplacedBy: aPart
	"Answer whether the receiver can be replaced
    by <aPart> on the workbench.  All links will be
    reattached to <aPart>."

	^false!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #headings: with: self headings;
        addSelectorIfNotNil: #contents: with: self contents


!  
indeterminate: aBoolean
	" Set the indeterminate state of the receiver to aBoolean "

	^self tool indeterminate: aBoolean! 
adjustComponentIndexStartingAt: anIndex
	" Private - a component has just been moved,removed or added,
    adjust the indexes of the components starting at <anIndex> "

	| components |
	components := self partWrapper components.
	anIndex to: components size
		do:
			[:i |
			(components at: i) object index: i].
	! 
fieldSetMessages
        " Private "
    ^innerParts collect: [ :field |
        ( ( ( 'set', field name ) select: [ :char | char isAlphaNumeric ] ) , ':') asSymbol ]!
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
partEvents
	" Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#clicked: #turnedOn #turnedOff)
			separators: #()
			defaultItem: #turnedOn!   
partCanHaveChild: anObject
	"Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."

	^true!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
			#changed:
			#nextLine #previousLine
			#rightClicked #tabbed )
        separators: #( 1 3 )
        defaultItem: #changed:!
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
refreshItems
	"Private - Expand the receiver if necessary to show the
    tools, and update their positions"

	self toolContainers
		do:
			[:each |
			each object refreshItems].
	! 
partEditProperties
	" Open an editor on the PARTS properties of the receiver. "

	(self propertyManager) editFor: self!
hide: aBoolean
	"Hide or show the receiver according to <aBoolean>.  "

	^self tool hide: aBoolean!
isWrapped
	"Answer true if the receiver is word wrapped, else answer false."

	^self tool isWrapped!   
toolLabelRemovedFrom: aTool
oldLabel: aString
	" Private - <aTool>'s label <aString>, has just been removed.  Recalculate
      the tool width and height of the receiver's tools and refresh . "

	| newWidth |
	toolsWithLabels remove: aTool.
	toolsWithLabels size = 0
		ifTrue:
			[ " all tools have no label - reduce their width and height "
			self maxWidth: toolWidth. "toolWidth attribute"
			self toolHeight: aTool frameRectangle height - 14.
			self updatePositions.
			]
		ifFalse:
			[ " find new tool with longest label "
			(((aTool pen stringWidthOf: aString) + aTool labelPadding) = self maxWidth)
				ifTrue:
					[newWidth := 0.
					toolsWithLabels
						do:
							[:tool |
							newWidth := newWidth max: ((tool pen stringWidthOf: tool label) + aTool labelPadding)].
					self maxWidth: (newWidth max: toolWidth).
					self refreshItems: true]]!
removeSubpane: aTool
	"Remove <aTool> from the receiver."

	(aTool isPARTSToolbarItem and: [aTool label size > 0 and: [self partIsEditing]])
		ifTrue:
			[ "Adjust the width of all tool items"
			self toolbox toolLabelRemovedFrom: aTool oldLabel: aTool label].
	super removeSubpane: aTool!  
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "

    ( self propertyManager ) editFor: self!
partIsDragable
        "Answer true if dragable and resizable."
    ^false! 
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super
		constructPropertyManager
		add:
			(StylePropertyAccessor
				name: 'Customizable'
				style: 'CcsAdjustable'
				pool: WinCommonControlConstants);
		add:
			(StylePropertyAccessor
				name: 'Drag with Alt key'
				style: 'TbstyleAltdrag'
				pool: WinCommonControlConstants);
		add:
			(SelectorPropertyAccessor
			new name: 'Place At Top';
			get: #isAtTop;
			set: #showAtTop:;
			format: 'boolean');
		add:
			(StylePropertyAccessor
				name: 'Tool Tip'
				style: 'TbstyleTooltips'
				pool: WinCommonControlConstants);
		add:
			(StylePropertyAccessor
				name: 'Wrapable'
				style: 'TbstyleWrapable'
				pool: WinCommonControlConstants);
		addNames: #('Customizable' 'Drag with Alt key' 'Place At Top' 'Tool Tip' 'Wrapable') toPage: 'Style';
		add:
			(SelectorPropertyAccessor
			new name: 'Bitmap Height (pixels)';
			get: #bitmapHeight;
			set: #bitmapHeight:;
			format: 'Integer');
		add:
			(SelectorPropertyAccessor
			new name: 'Bitmap Width (pixels)';
			get: #bitmapWidth;
			set: #bitmapWidth:;
			format: 'Integer');
		add:
			(SelectorPropertyAccessor
			new name: 'Minimum Tool Height (pixels)';
			get: #toolHeight;
			set: #toolHeight:;
			format: 'Integer');
		add:
			(SelectorPropertyAccessor
			new name: 'Minimum Tool Width (pixels)';
			get: #toolWidth;
			set: #toolWidth:;
			format: 'Integer');
		addNames: #('Bitmap Height (pixels)' 'Bitmap Width (pixels)' 'Minimum Tool Height (pixels)' 'Minimum Tool Width (pixels)') toPage: 'Size';
		add:
			(SelectorPropertyAccessor
			new name: 'Registration Key Name';
			get: #registrationKeyName;
			set: #registrationKeyName:;
			format: 'String');
		add:
			(SelectorPropertyAccessor
			new name: 'Registration Value Name';
			get: #registrationValueName;
			set: #registrationValueName:;
			format: 'String');
		add:
			(SelectorPropertyAccessor
			new name: 'Auto Save On Close';
			get: #autoSave;
			set: #autoSaveOnClose:;
			format: 'Boolean');
		addNames: #('Registration Key Name' 'Registration Value Name' 'Auto Save On Close') toPage: 'Save/Restore';
		removeProperty: 'Font';
		removeProperty: 'Forecolor';
		removeProperty: 'Backcolor';
		removeProperty: 'Size window';
		addGroupEditor: 'pptoolba.par';
		yourself!  
partEditDirect
        "Edit the directly visible part properties of the receiver."
    self partEditor workbenchPane lafEditNone: self!
partEditDirect
	"Private - external"
	"Edit the directly visible part properties of the receiver."

	| aStream originalValue |
	originalValue := self streamContents.
    aStream := self partEditTextContents: originalValue.
    aStream notNil
        ifTrue: [
            self formattedContents: aStream.
            self partEditor
                recordUndo: ( Message new
                    receiver: self
                    selector: #formattedContents:
                    arguments: (Array with: originalValue) )
                undoLabel: 'direct edit'
                redo: ( Message new
                    receiver: self
                    selector: #formattedContents:
                    arguments: (Array with: aStream) )
                redoLabel: 'direct edit' ]! 
bitmap: aBitmap
	"Set the bitmap of the receiver's tool."

	self tool bitmap: aBitmap! 
setBitmap: aBitmap
	" Set the bitmap of the receiver's tool. "

	super setBitmap: aBitmap.
	self tool bitmap: aBitmap!
toolWidth: anInteger
	" Set the toolWidth of the receiver. "

	toolWidth := anInteger! 
currentItemIndex
	"Private - Answer the current drag drop target position"

	^currentItemIndex!
triggerHelpEvent
	"Trigger help event for the current page control."

	self currentPage controls first 
		triggerEvent: #help: 
		with: self  currentPage controls first!
partDroppedPart: aPart
hotSpot: hotSpot
origin: origin
	"Private - <aPart> has been dragged into the
    receiver.  <aPart> is either an application or a part.
    Add <aPart> at the correct position in the
    receiver. <aPoint> is in editor pane coordinates.
    If <hotSpot> is nil, <aPart> was added programatically."

	| components originalComponents currentLocation insertionPoint tool toolWrapper parentRect framer toolRect |
	toolWrapper := aPart isPARTSApplication
		ifTrue: [aPart mainObjectPrivate partWrapper]
		ifFalse: [aPart partWrapper].
	tool := toolWrapper object.
	"Adjust the framingBlock if not a tool item"
	tool isPARTSToolbarItem not
		ifTrue:
			[parentRect := self entireClientArea.
			framer := tool framingBlock.
			"Fixed top inset, fixed height"
			toolRect := framer scaleFrom: parentRect.
			framer
				useTopInset;
				useTopStretched: false;
				useBottomHeight;
				changeRectangle: toolRect relativeTo: parentRect; "Set top inset and height values"
				top: (framer pixelToScaleUnitVertical: self gapHeight);
				bottom: (framer pixelToScaleUnitVertical: self toolHeight)].
	components := self partWrapper components asOrderedCollection.
	originalComponents := components
		select:
			[:each |
			each ~= toolWrapper].
	insertionPoint := hotSpot isNil
		ifTrue: [originalComponents size + 1]
		ifFalse: [self findIndex: (hotSpot mapFromWindow: self partEditor workbenchPane to: self) in: originalComponents].
	(currentLocation := components indexOf: toolWrapper) > 0
		ifTrue: [components removeIndex: currentLocation].
	components add: toolWrapper beforeIndex: insertionPoint.
	self partWrapper components: components.
	self adjustComponentIndexStartingAt: insertionPoint + 1.
	tool detach: (self isDetachedContainer).
	self partEditor selectOff: tool.
	self updatePositions.
	self refreshItems.
	self partEditor select: tool.! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | application messageModel expressionModel |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    controls size > 0 ifTrue: [
        controls do: [ :control |
            application := control partApplication.
               messageModel := anExpressionModel addSelector: #addPagePane:.
                expressionModel := messageModel newExpressionArgument.
                expressionModel
                   setReceiverToSelf;
                    addSelector: ( application selectorForComponentBuild: control )
                        with: application ]]!  
tool: aTool
	" Private- Set the tool  the receiver is wrapping. "

	tool := aTool.
	! 
constructPropertyManager
	^super constructPropertyManager

		removeProperty: 'Font';
		removeProperty: 'Forecolor';
		add: ( SelectorPropertyAccessor name: 'Backcolor' get: #backColor set: #backColor: editor: PropertyManager editorForColor );
		addNames: #( 'Backcolor' ) toPage: 'General';

		add: ( StylePropertyAccessor name: 'Vertical' style: 'TbsVert' pool: ( Smalltalk at: #WinCommonControlConstants ) );
		add: ( StylePropertyAccessor name: 'Horizontal' style: 'TbsHorz' pool: ( Smalltalk at: #WinCommonControlConstants ) );
		addNames: #( 'Vertical' 'Horizontal' ) toPage: 'Orientation';

		add: ( MaskedStylePropertyAccessor name: 'Ticks on Left/Top' style: 'TbsLeft' pool: ( Smalltalk at: #WinCommonControlConstants ) mask: 2r1100 );
		add: ( MaskedStylePropertyAccessor name: 'Ticks on Right/Bottom' style: 'TbsRight' pool: ( Smalltalk at: #WinCommonControlConstants ) mask: 2r1100 );
		add: ( MaskedStylePropertyAccessor name: 'Ticks on Both Sides' style: 'TbsBoth' pool: ( Smalltalk at: #WinCommonControlConstants ) mask: 2r1100 );
		addNames: #( 'Ticks on Left/Top' 'Ticks on Right/Bottom' 'Ticks on Both Sides' ) toPage: 'Ticks';

		addGroupEditor: 'pptrack.par';

		yourself!
partIsShrinkable
	"Private - Can this part shrink in a PARTS Workbench."

	^true!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #contents #contents: #headings #headings:
            #sortByColumn #sortByColumn: #sortItems #sortAscending:
            #abortChange )
        separators: #( 3 7 11 )
        defaultItem: #contents
! 
fieldGetMessages
        " Private "
    ^innerParts collect: [ :field |
        ( field name select: [ :char | char isAlphaNumeric ] ) asSymbol ]!
modified: boolean
    "Private - One or more of the properties got
    modified if <boolean> is true."

    self propertyAt: #modified put: boolean!  
partFencesMoveSession
	"Private - Answer whether the receiver automatically
    allows a move session initiated it to have its
    children moved outside without the shift key being pressed."

	^false!
partSetDirectEditAttribute: text
        "Private - set the direct-edit attribute of the receiver
        to text."
	| substrings |
	substrings := text asArrayOfSubstringsSeparatedBy: "Tab" 9 asCharacter.
	super partSetDirectEditAttribute: substrings!  
maxWidth
	" Answer the maximum width of the tools in the receiver "

	maxWidth isNil
		ifTrue: [^0].
	^maxWidth! 
createViewOn: aStream label: aLabelString
        " Private - create the view "

    | unit gap topPane aTextPane |
    unit := self class entryHeight.
    gap := WindowDialog dialogUnit x.
    self addView: (
        ( topPane := self topPaneClass new )
            owner: self;
            labelWithoutPrefix: aLabelString;
            yourself ).
    aTextPane := RichEdit new.
    topPane
        addSubpane: ( Button new
            owner: self;
            label: 'Format...';
            when: #clicked
                send: #format: to: self with: aTextPane;
            framingBlock: [ :b |
                (b leftTop rightAndDown: unit // 3)
                    extentFromLeftTop: unit * 5 @ (unit )]);
        addSubpane: ( aTextPane
            owner: self;
            enableWordWrap;
            addStyle: WsPaneBorder;
            addStyle: MlsAcceptEnterKey;
            formattedContents: aStream;
            framingBlock: [ :b |
                (b leftTop rightAndDown: unit // 3 + ( 0 @ ( unit * 3 // 2 )))
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
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^false!  
createTool
	" Private - create the tool object which the receiver is wrapping. "

	^tool := self
		class toolClass new setBitmap: bitmap;
		yourself!
partMessages
	" Answer the PARTS message interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#click #enable #disable #hide #show #makeIndeterminate #clearIndeterminate #detach #bitmap #label #tip)
			separators: #(1 7 8)
			defaultItem: #click! 
partFrameRectangleFrom: aRectangle
        " Private - answer the framing rectangle
       to use for the receiver part, given aRectangle. "

    ^self defaultFramer!
setLabel: aString
	" Set the label of the receiver's tool."

	| oldLabel toolbox |
	oldLabel := self tool label.
	self tool label: aString.
	(self partIsEditing and: [(toolbox := self parent toolbox) notNil])
		ifTrue:
			[(aString isNil or: [aString isEmpty])
				ifTrue: [toolbox toolLabelRemovedFrom: self oldLabel: oldLabel]
				ifFalse: [toolbox toolLabelAddedTo: self adjustHeight: oldLabel size = 0]]!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #filename #filename: #open #isOpen #close
            #pause #play #playFrom: #playFrom:to: #reset #resume #stop
            #length #position #position: #isTimeFormatMilliseconds #isTimeFormatBytes #isTimeFormatSamples #timeFormat #timeFormatMilliseconds #timeFormatBytes #timeFormatSamples #timeFormat:
            #isNotReady #isPaused #isPlaying #isReady #isSeeking #isStopped
            #bitsPerSample #bytesPerSecond #channels #samplesPerSecond
        )
        separators: #( 5 12 23 29 )
        defaultItem: #play!   
getPosition: anItem
after: anchorLabel
	"Private - Answer the new framing rectangle of
    <anItem>.  The rectangle should be positioned
    after the framing rectangle of the <anchorLabel>.
    Wrap anItem to the next row, if it falls beyond the size
    of the receiver. "

	| gapX gapY x y anchorLabelRect extent newRect |
	gapX := self gapWidth.
	gapY := self gapHeight.
	anchorLabel isNil
		ifTrue:
			[x := rectangle left right: gapX.
			y := gapY]
		ifFalse:
			[anchorLabelRect := anchorLabel frameRelativeRectangle.
			x := anchorLabelRect right right: gapX.
			y := anchorLabelRect top].
	extent := (anItem isPARTSToolbarItem)
		ifTrue:
			[anItem partSize]
		ifFalse:
			[
			"The initial extent of anItem is incorrect. Determine future extent"
			(anItem framingBlock scaleFrom: self entireClientArea) extent].
	newRect := x @ y extentFromLeftTop: extent.
	newRect right > self extent x
		ifTrue:
			[x := rectangle left right: gapX.
			y := (anchorLabel isNil
				ifTrue: [gapY]
				ifFalse: [anchorLabelRect bottom down: gapY]).
			newRect := x @ y extentFromLeftTop: extent].
	^newRect!   
click
	"Programatically click the receiver."

	^self tool click.!  
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."

    ^( self parent class == SpinButton ) not!  
gapHeight
	"Private - Answer the gap height between the rows."

	^self toolbox gapHeight!  
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
	| strings |
	strings := OrderedCollection new.
	self contents notNil ifTrue: [
		self contents do: [ :rootTreeViewItem |
			self partDirectEditInitialValueAddItemsFrom: rootTreeViewItem to: strings level: 0 ] ].
    ^strings!
partDirectEditInitialValue
        "Private - Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "

    ^self simpleModeText!  
partShrinkWrap
	"Private - Answer the parent window which can be shrunk in
        the parts window."

	^self!
partCanHaveParent: aWindow
	" Answer whether aWindow can be a parent
        window of the receiver. "

	^aWindow isPARTSToolContainer !  
move: anItem
toIndex: row
	"Private - Move anItem to row and update the
         receiver."

	super move: anItem toIndex: row.
	self adjustComponentIndexStartingAt: 1.
	! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
			#changed: #changing:
			#nextLine #previousLine #nextPage #previousPage #home #end
			#rightClicked #tabbed )
        separators: #( 2 8 )
        defaultItem: #changed:!  
partCanHaveParent: aWindow
	" Answer whether aWindow can be a parent
        window of the receiver. "

	^aWindow isPARTSWindow!  
codeGenerationCanHaveScrollBars
        "Private - answer whether the receiver can ever have scroll bars."
    ^false!  
toolHeight
	" Answer the toolHeight of the receiver. "
	^ toolHeight
	!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #clicked: #clickedIndex:
            #resizingIndex:to: #resizedIndex:to:
            #dividerDoubleClicked: #dividerDoubleClickedIndex:
            #tabbed )
        separators: #( 2 4 6 )
        defaultItem: #clicked:! 
initialize
	" Private - initialize the receiver "

	super initialize.
	!  
defaultStyle
	"Private - external"
	" Answer the default style."

    ^ 0!
partCanHaveParent: aWindow
	" Answer whether aWindow can be a parent
        window of the receiver. "

	^aWindow isPARTSEditorPane!  
isCentered
		"Private - provide a property manager style accessor for centered attribute."
	^self listAttribute notNil and: [ self entryField hasStyle: EsCenter ]! 
constructPropertyManager

    ^super
        constructPropertyManager
        add:
            (SelectorPropertyAccessor
                name: 'Order children'
                get: #orderedChildren
                set: #orderChildrenAndDisplay:
                editor: PropertyManager editorForOrderChildren);
        addNames: #('Order children') toPage: 'General';
        add:
            (SelectorPropertyAccessor
                name: 'Tab image'
                get: #image
                set: #image:
                editor: PropertyManager editorForIcon);
        add:
            (SelectorPropertyAccessor new
                name: 'Has tab image';
                get: #hasImage;
                set: #hasImage:;
                format: 'boolean');
        add:
            (SelectorPropertyAccessor
                name: 'Tab label'
                get: #label
                set: #label:);
        add:
            (SelectorPropertyAccessor
                name: 'Tab tip'
                get: #tip
                set: #tip:);
        addNames: #('Tab image' 'Has tab image' 'Tab label' 'Tab tip') toPage: 'Tab';
        add:
            (SelectorPropertyAccessor
            new name: 'Order page';
            get: #pages;
            set: #parentContents:;
            format: 'List');
        add:
            (SelectorPropertyAccessor
            new name: 'Select page';
            get: #currentPageNumber;
            set: #turnToPageNumber:;
            format: 'Integer');
        removeProperty: 'Size window';
        addNames: #('Order page' 'Select page') toPage: 'Page';
        addGroupEditor: 'pptabpg.par';
        epilog: #showChanges:;
        yourself!
toolsWithLabels
	"Private - answer a collection of tools with labels."

	^toolsWithLabels! 
partMessages
	" Answer the PARTS message interface of the receiver.
            Should be reimplemented by subclasses.  "
	self implementedBySubclass

	!
setTip: aString
	" Set the tip string of the receiver's tool."

	self tool setTip: aString!
partEvents
	"Private - Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#changed: #fileException: #modifiedIsTrue #rightClicked #controlTabbed)
			separators: #(2 3)
			defaultItem: #changed:!   
partDirectEditValueIsValid: text
    "Private - Answer whether the text is valid for the object's direct edit attribute."

    ^false! 
expandBy: delta
	"Private - Expand (resize) the receiver by delta."

	| rect |
	rect := (self frameRectangle expandBy: delta) mapToWindow: self superWindow.
	self resizeToRectangle: rect.
	self partsIfOS2Do: [self sizeChanged: self extent].
	self invalidateRect: nil!
isPARTSToolbarItem
	" Answer whether the receiver is a valid tool which can be  used
       within a Toolbar control."

	^false!  
detach: aBoolean
	" Set if the receiver's tool is to be detached. "

	^self tool detach: aBoolean! 
centered: aBoolean
		"Private - provide a property manager style accessor for centered attribute."
	aBoolean
		ifTrue: [
			self centered.
			self listAttribute isNil ifTrue: [ self contents: #( 'one' 'two' 'three' ) ] ]!
partDirectEditInitialValueAddItemsFrom: treeViewItem to: stringCollection level: levelInteger
	stringCollection add: ( ( String new: levelInteger ) atAllPut: 9 asCharacter ), treeViewItem string.
	treeViewItem children notNil ifTrue: [
		treeViewItem children do: [ :childItem |
			self partDirectEditInitialValueAddItemsFrom: childItem to: stringCollection level: levelInteger + 1 ] ]!
hide
	"Hide the receiver.  Answer true if it is successful, else false.
      Trigger the #hidden event ."

	^self tool hide.!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #contents: with: self contents

!  
turnOn
	"Set the receiver's state to on (true).
        Trigger changed event. "

	self tool turnOn!  
gapWidth
	"Private - Answer the gap height between the columns."

	^SysFont width! 
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

    ^( ( aWindow isKindOf: PARTSTabControlPart ) or: [ aWindow isKindOf: PARTSTabControlPagePart ])!   
partEvents
	" Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList new
			items: #(
				#selected 
				#deselected #rightClicked 
				#help: #apply:
				#next: #back:)
			separators: #(1 3 5)
			defaultItem: #rightClicked! 
partMirrorCopyReal: aMirrorCopyDictionary
	" Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

	| copy |
	copy := super partMirrorCopyReal: aMirrorCopyDictionary.
	copy
		autoSaveOnClose: (autoSave);
		bitmapHeight: (self bitmapHeight partMirrorCopy: aMirrorCopyDictionary);
		bitmapWidth: (self bitmapWidth partMirrorCopy: aMirrorCopyDictionary);
		registrationKeyName: (self registrationKeyName partMirrorCopy: aMirrorCopyDictionary);
		registrationValueName: (self registrationValueName partMirrorCopy: aMirrorCopyDictionary);
		toolHeight: (self toolHeight partMirrorCopy: aMirrorCopyDictionary);
		toolWidth: (self toolWidth partMirrorCopy: aMirrorCopyDictionary);
		tools: (self tools partMirrorCopy: aMirrorCopyDictionary);
		style: (style partMirrorCopy: aMirrorCopyDictionary).
	^copy! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    handle isValid
        ifTrue: [self value].
    copy
        formattedContents: (self formattedContents partMirrorCopy: aMirrorCopyDictionary).
    self isReadOnly
        ifTrue: [ copy readOnly ]
        ifFalse: [ copy readWrite ].
    self isWordWrapEnabled
        ifTrue: [  copy enableWordWrap ]
        ifFalse: [  copy disableWordWrap ].
    ^copy! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
	"Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."

	super codeGenerationAddAttributeMessagesTo: anExpressionModel.
	anExpressionModel addSelectorIfNotNil: #tool: with: self tool!  
partMessages
        " Answer the PARTS message interface of the receiver. "


	^PARTSInterfaceList new
			items: #(#pageNumber)
        		separators: #( )
        		defaultItem: #pageNumber!
partMirrorCopyReal: aMirrorCopyDictionary
        "Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy."
    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy itemsAttribute: ( self itemsAttribute partMirrorCopy: aMirrorCopyDictionary ).
    copy indent: ( self indent partMirrorCopy: aMirrorCopyDictionary ).
    ^copy! 
tip
	"Answer the tip text of the receiver's tool."

	^self tool tipText!   
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^false!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
	"Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."

	super codeGenerationAddAttributeMessagesTo: anExpressionModel.
	anExpressionModel
		addSelectorIfNotNil: #bitmap: with: bitmap;
		addSelectorIfNotNil: #detach: with: self isDetached;
		addSelectorIfNotNil: #eventTable: with: eventTable;
		addSelectorIfNotNil: #index: with:  self index;
		addSelectorIfNotNil: #label: with: label;
		addSelectorIfNotNil: #state: with: self state;
		addSelectorIfNotNil: #style: with: self style;
		addSelectorIfNotNil: #tipText: with: self tipText!   
partSetGraphics: aBitmap
	" Private - update the receiver's bitmap. "

	self bitmap: aBitmap.
	self handle isValid
		ifTrue: [self realInvalidateRect: nil]! 
partMirrorCopyReal: aMirrorCopyDictionary
        "Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy."
    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy lineIncrement: ( self lineIncrement partMirrorCopy: aMirrorCopyDictionary ).
    copy minimumAttribute: ( self minimum partMirrorCopy: aMirrorCopyDictionary ).
    copy maximumAttribute: ( self maximum partMirrorCopy: aMirrorCopyDictionary ).
    ^copy!
constructPropertyManager
    "Private - Construct accessors for receiver's properties."

    ^super
        constructPropertyManager
        add:
            (StylePropertyAccessor
                name: 'Read only'
                style: 'EsReadonly'
                pool: OperatingSystemConstants);
        add:
            (StylePropertyAccessor
                name: 'Border'
                style: 'WsBorder'
                pool: OperatingSystemConstants);
        add:
            (SelectorPropertyAccessor
                name: 'Edit contents'
                get: #formattedContents
                set: #formattedContents:
                editor: #partEditTextContents:);
        add:
            (SelectorPropertyAccessor
                name: 'Drag drop'
                get: #partDragSpec
                set: #partDragSpec:
                editor: PropertyManager editorForDragDrop );
        removeProperty: 'Forecolor';
        removeProperty: 'Font';
        addNames: #( 'Edit contents' 'Drag drop') toPage: 'General';
        addNames: #('Read only' 'Border') toPage: 'Style';
        addGroupEditor: 'pprchedt.par';
        yourself
!
partCanHaveParent: aWindow
	" Answer whether aWindow can be a parent
        window of the receiver. "

	^aWindow isPARTSToolbox! 
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super
		constructPropertyManager
		add:
			(SelectorPropertyAccessor
			new name: 'Turned On';
			get: #isOn;
			set: #setValue:;
			format: 'Boolean');
		addNames: #('Turned On') toPage: 'State';
		addGroupEditor: 'pptooltg.par';
		yourself! 
rightJustified: aBoolean
		"Private - provide a property manager style accessor for rightJustified attribute."
	aBoolean
		ifTrue: [
			self rightJustified.
			self listAttribute isNil ifTrue: [ self contents: #( 'one' 'two' 'three' ) ] ]!  
shouldExpand
	"Private - expand the receiver. "

	| rightBound |
	super shouldExpand
		ifTrue: [^true].
	rightBound := self frameRectangle right.
	^(self partWrapper components
		detect:
			[:aWrapper |
			aWrapper object frameRectangle right isRightOf: rightBound]
		ifNone: [nil]) notNil! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
			#minimum #minimum: #maximum #maximum: #position #position: #minimum:maximum: #minimum:maximum:position:
			#decrementPosition #decrementPositionBy: #incrementPosition #incrementPositionBy:
			#lineIncrement #lineIncrement: #pageIncrement #pageIncrement:
            #enable #disable
            #value #setValue: )
        separators: #( 8 12 16 18 )
        defaultItem: #position!
turnOff
	"Set the receiver's state to off (false).
        Trigger changed event. "

	self tool turnOff!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
			#minimum #minimum: #maximum #maximum: #position #position: #minimum:maximum: #minimum:maximum:position:
			#decrementPosition #decrementPositionBy: #incrementPosition #incrementPositionBy:
			#lineIncrement #lineIncrement:
            #value #setValue: )
        separators: #( 8 12 14 )
        defaultItem: #position!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | state |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel addSelectorIfNotNil: #imageList: with: self imageList.
    1 to: self listAttribute size do: [ :i |
        state := ( self listAttribute at: i ) state.
        state == true
            ifTrue: [ anExpressionModel addSelector: #checkIndex: with: i ]
            ifFalse: [
                state == false
                    ifTrue: [ anExpressionModel addSelector: #uncheckIndex: with: i ]
                    ifFalse: [ anExpressionModel addSelector: #indeterminateIndex: with: i ] ] ]!
tool: aTool
	" Private- Set the tool  the receiver is wrapping. "

	aTool bitmap notNil
		ifTrue:
			[self bitmapClone: aTool bitmap clone.
			].
	tool release.
	tool := aTool.
	!  
partEvents
	" Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#clicked)
			separators: #()
			defaultItem: #clicked!  
setValue: aBoolean
	"Set the state of the receiver's to aBoolean.  "

	^self tool setValue: aBoolean!  
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."

    ^false!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #pageNumber #isLastPage #isFirstPage
		   #turnToPageNumber: #firstPage #lastPage #nextPage #previousPage
            #abortChange
		   #triggerApplyEvents #triggerHelpEvent )
        separators: #( 3 6 11 12 )
        defaultItem: #turnToPageNumber:!   
expand: amount
	" Private - Refresh all items in the receiver"

	self expandBy: (Rectangle leftTop: (0 @ 0) rightBottom: (0 @ amount)).
	self updatePositions!
enable: aBoolean
	" Enable or disable the receiver according to <aBoolean>."

	^self tool enable: aBoolean!
partLinkClassFor: aSelector
        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( ( self fieldGetMessages includes: aSelector )
    or: [ self fieldSetMessages includes: aSelector ] )
        ifTrue: [ PARTSAliasLink]
        ifFalse: [ super partLinkClassFor: aSelector ]!
isIndeterminate
	"Answer true if the receiver is indeterminate, else return false."

	^self tool isIndeterminate!  
partIsSizable
	"Answer whether the receiver can be resized
        in a PARTS workbench. "

	^false!  
leftJustified: aBoolean
		"Private - provide a property manager style accessor for leftJustified attribute."
	aBoolean ifTrue: [
		self leftJustified.
		self listAttribute isNil ifTrue: [ self contents: #( 'one' 'two' 'three' ) ] ]!  
partMirrorCopyReal: aMirrorCopyDictionary
		"Private - add a mirror copy of the receiver
		to <aMirrorCopyDictionary>.  Answer the copy."
	| copy |
	copy := super partMirrorCopyReal: aMirrorCopyDictionary.
	copy listAttribute: ( self listAttribute partMirrorCopy: aMirrorCopyDictionary ).
	copy valueAttribute: ( self valueAttribute partMirrorCopy: aMirrorCopyDictionary ).
	copy entryField: ( self entryField partMirrorCopy: aMirrorCopyDictionary ).
	copy setEntryFieldFramingBlock.
	copy upDown: ( self upDown partMirrorCopy: aMirrorCopyDictionary ).
	copy setUpDownFramingBlock.
	^copy!  
partEvents
	" Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList emptyList! 
partEnableExecution
	" The application containing the receiver
        is going to be executed.   "

	self tools.
	"Strip the wrappers if possible"
	(PARTSWrapper keepInExecutable or: [self partWrapper partIsDebugging])
		ifFalse:
			[
			"#myOwnName is the same symbol used by Window>>setName:"
			self propertyAt: #myOwnName put: self partName.
			self partWrapper: nil.
			] "Remove the wrapper for execution."!
toolbox
	" Answer the Toolbox which contains the receiver. "

	^self parent!   
partMessages
	" Answer the PARTS message interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#click #turnOn #turnOff #isOn #enable #disable #hide #show #makeIndeterminate #clearIndeterminate #detach #bitmap #label #tip)
			separators: #(4 10 11)
			defaultItem: #turnOn!   
partAboutToRemove
        "The receiver is about to be removed from the PARTSEditor.
          If there are more than one page referecing the receiver then
          don't remove the receiver just delete the page.
          Answer true if a page was deleted without removing
          the receiver else answer false."
    

    page isNil ifTrue: [ ^false ].
    ( self superWindow isKindOf: PARTSTabControlPart )
        ifTrue: [
			self superWindow sendInputEvent: #deletePage: with: page.  "note: this
				has to be delayed so that PARTSEditor can clean up first by returning false."
			^false ]
        ifFalse: [ ^false ]!
partEditDirect
        "Edit the directly visible part properties of the receiver."
    self partEditor workbenchPane lafEditNone: self!
displayFont
	"Private- Answer the font to be used to draw the receiver's
    label on the workbench"

	^PARTSHostInterface defaultPartFont!   
partEvents
	" Answer the PARTS event interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#aboutToChange #changed: #changedPageNumber: 
				#rightClicked #tabbed #inputOccurred
				#finished)
			separators: #(3 6)
			defaultItem: #changedItem:!
partIsSizable
	"Answer whether the receiver can be resized
        in a PARTS workbench. "

	^false!  
initialize
	" Private - initialize the receiver."

	super initialize.
	self createTool.
	bitmap := Bitmap screenExtent: self imageSize.
	bitmap pen fill: Color menuBackground! 
updatePositions
	"Private - Update the position of each item in the receiver."

	super updatePositions.
	self adjustComponentIndexStartingAt: 1.
	!  
isGrouped
	" Answer if the tool of the receiver has the style TbstyleGroup."

	^self tool isGrouped.!  
partMirrorCopyReal: aMirrorCopyDictionary
        "Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy."
    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy headingsAttribute: ( self headings partMirrorCopy: aMirrorCopyDictionary ).
    copy imageList: ( self imageList partMirrorCopy: aMirrorCopyDictionary ).
    copy itemsAttribute: ( self items partMirrorCopy: aMirrorCopyDictionary ).
    copy smallImageList: ( self smallImageList partMirrorCopy: aMirrorCopyDictionary ).
    ^copy! 
partEvents
	" Answer the PARTS event interface of the receiver. 
            Should be reimplemented by subclasses."
	self implementedBySubclass



	! 
constructPropertyManager
	^super constructPropertyManager
		add: ( SelectorPropertyAccessor new name: 'Page Increment'; get: #pageIncrement; set: #pageIncrement: ; format: 'Integer' );
		addNames: #( 'Page Increment' ) toPage: 'Range';
		yourself!   
partContents
        "Answer the contents of the receiver."
    | partContents |
    ^( partContents := self contents ) isNil
        ifTrue: [ Array new ]
        ifFalse: [ partContents collect: [ :item | item object asString ] ]! 
constructPropertyManager
	| mgr |
	mgr := super constructPropertyManager.
	mgr
		removeProperty: 'Font';
		removeProperty: 'Backcolor';
		removeProperty: 'Forecolor';
		add: ( SelectorPropertyAccessor new name: 'Minimum'; get: #minimum; set: #minimum: ; format: 'Integer' );
		add: ( SelectorPropertyAccessor new name: 'Maximum'; get: #maximum; set: #maximum: ; format: 'Integer' );
		add: ( SelectorPropertyAccessor new name: 'Position'; get: #position; set: #position: ; format: 'Integer' );
		add: ( SelectorPropertyAccessor new name: 'Line Increment'; get: #lineIncrement; set: #lineIncrement: ; format: 'Integer' );
		addNames: #( 'Minimum' 'Maximum' 'Position' 'Line Increment' ) toPage: 'Range'.
	Smalltalk platformIsWin32 ifTrue: [ mgr addGroupEditor: 'pprange.par' ].  "until prop interface works on OS/2"
	^mgr!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #itemsAttribute: with: self itemsAttribute;
        addSelector: #itemHandleMap: with: self itemHandleMap;
        addSelector: #imageList: with: self imageList;
        addSelector: #handleItemMap: with: self handleItemMap

!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #string: with: self string;
        addSelectorIfNotNil: #object: with: self object!
refreshItems: expand
	"Private - Refresh all items in the receiver's"

	| topContainer delta tempDelta |
	expand
		ifTrue:
			[self updatePositions.
			delta := 0.
			self toolContainers
				do:
					[:aToolContainer |
					((tools := aToolContainer components) size > 0 and: [(tempDelta := tools last object frameRelativeRectangle bottom - aToolContainer object height) > 0])
						ifTrue: [delta := delta max: (tempDelta + self gapHeight)]].
			topContainer := (self toolContainers
				detect:
					[:aToolContainer |
					aToolContainer object framingBlock isBottomStretched]) object.
			delta := (delta / (1 - topContainer framingBlock bottom)) asInteger.
			self expandBy: (Rectangle leftTop: (0 @ 0) rightBottom: (0 @ delta))]
		ifFalse:
			[self updatePositions.
			self invalidateRect: nil].
	!  
isPARTSToolbar
	" Answer whether the receiver is  a Toolbar control."

	^false!
findIndex: aPoint
in: components
	"Private - Answer the index of the tool item at <aPoint>.
    <aPoint> is relative to the receiver."

	| tool targetRect |
	components size > 0
		ifTrue:
			[tool := components
				detect:
					[:aWrapper |
					targetRect := (aWrapper object frameRelativeRectangle expandBy: (0 @ self gapHeight // 2)) moveBy: (self gapWidth negated @ 0).
					targetRect containsPoint: aPoint]
				ifNone: [nil].
			^tool isNil
				ifTrue: [components size + 1]
				ifFalse: [tool object index]].
	^1! 
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true! 
constructPropertyManager
	| mgr |
	mgr := super constructPropertyManager.
	mgr
		add: ( SelectorPropertyAccessor new name: 'Three State'; get: #isThreeState; set: #threeState: ; format: 'Boolean' );
		add: ( SelectorPropertyAccessor new name: 'Use Images'; get: #useImages; set: #useImages: ; format: 'Boolean' );
		addNames: #( 'Three State' 'Use Images' ) toPage: 'Style'.
	mgr addGroupEditor: 'ppbtnlst.par'.
	^mgr!
bitmapClone: aBitmap
	" Private - set the bitmap of the receiver. "
	bitmap := aBitmap! 
isPARTSToolContainer
	" Answer if the receiver is a PARTSToolContainer "

	^false! 
adjustPositionAfterUndoDelete: anItem
	"Private - Adjust the position of aMenuItem after an undo delete."

	self updatePositions!  
clearIndeterminate
	"Clear the receiver's indeterminate state. "

	^self tool clearIndeterminate!  
constructPropertyManager
    "Construct accessors for receiver's properties."

    ^super
        constructPropertyManager
        add:
            (StylePropertyAccessor
                name: 'Size Grip'
                style: 'SbarsSizegrip'
                pool: WinCommonControlConstants);
        add:
            (SelectorPropertyAccessor new
                name: 'Place At Top';
                get: #isAtTop;
					set: #showAtTop:;
					format: 'boolean'
					);
        add:
            (SelectorPropertyAccessor
            new name: 'Fields';
            get: #contents;
            set: #contents:);
        add:
            (SelectorPropertyAccessor
            new name: 'Minimum Height';
            get: #height;
            set: #height:;
            validator: PropertyManager validatorForInteger;
            format: 'Integer');
        add:
            (SelectorPropertyAccessor
            new name: 'Simple Mode';
            get: #isSimpleMode;
            set: #simpleMode:);
        add:
            (SelectorPropertyAccessor
            new name: 'Simple Mode Text';
            get: #simpleModeText;
            set: #simpleModeText:);
        removeProperty: 'Size window';
        removeProperty: 'Forecolor'; "These two don't work, like push button"
        removeProperty: 'Backcolor';
        addNames: #('Fields' ) toPage: 'Fields';
        addNames: #('Minimum Height' ) toPage: 'Height';
        addNames: #('Simple Mode' 'Simple Mode Text') toPage: 'Simple Mode';
        addGroupEditor: 'ppstatwi.par';
        yourself!  
isPARTSToolContainer
	" Answer if the receiver is a PARTSToolContainer"

	^true!   
orderChildrenAndDisplay: aCollection
    "Private - Set the orderedChildren and update
    the display to reflect the new order"

    self orderedChildren: aCollection.
    aCollection reversed do: [ :aSibling |
        aSibling partBringSubPaneToTop ].

    self invalidateRect: nil.! 
initSize: aRectangle
	"Private - Change the frame of the receiver pane
         to aRectangle."

	rectangle := self initialRectangleFor: aRectangle.
	rectangle extent: (rectangle extent max: 0 @ 0)!   
partEditDirect
	"Private - external"
	"Edit the directly visible part properties of the receiver."

	^ self partEditProperties!   
codeGenerationAddAddChildrenMessageModelsTo: anExpressionModel
        "Private - add  to anExpressionModel message models to rebuild the
        receiver's children.  Although spin buttons have children, the children
        should not be reconstructed via generated code.  Do nothing."!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #children: with: self children;
        addSelectorIfNotNil: #childrenExpanded: with: self childrenExpanded;
        addSelectorIfNotNil: #hasChildren: with: self hasChildren;
        addSelectorIfNotNil: #image: with: self image;
        addSelectorIfNotNil: #selectedImage: with: self selectedImage!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #minimum: with: self minimum;
        addSelectorIfNotNil: #maximum: with: self maximum;
        addSelectorIfNotNil: #position: with: self position
!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #contents #contents: #video #video: #stretch #stretch: )
        separators: #( 3 )
        defaultItem: #contents:! 
partIsSelectable
	"Answer whether the receiver is selectable in a PARTS Workbench."

	^false!  
currentItemIndex: anIndex
	"Private - Answer the current drag drop target position"

	currentItemIndex := anIndex! 
toolClass
	" Return the class which the receiver is representing. "

	^ToolbarToggleButton!
initialize
	"Private - Initialize the receiver."

	super initialize.
	toolHeight := ToolbarItem defaultHeight.
	toolWidth := ToolbarItem defaultWidth.
	toolsWithLabels := OrderedCollection new.
	!   
show
	"Show the receiver. Answer true if it is successful, else false.
          Trigger the #shown event. "

	^self tool show!   
updateTool
	" Private- Update the tool  the receiver is wrapping. "

	tool bitmap notNil
		ifTrue:
			[self bitmapClone: tool bitmap clone.
			].
	tool hide: tool isHidden.
	tool detach: tool isDetached.
	!   
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super
		constructPropertyManager removeProperty: 'Font';
		removeProperty: 'Forecolor';
		removeProperty: 'Backcolor';
		removeProperty: 'Size window';
		addGroupEditor: 'pptoolbx.par';
		yourself!  
detach
	"Detach the receiver.  Answer true if it is successful, else false."

	^self tool detach!  
group: aBoolean
	" Private - set if the receiver is to have the group style"

	self tool group: aBoolean!  
toolHeight: anInteger
	" Private - Set the toolHeight of the receiver. "

	toolHeight := anInteger!
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true! 
partMessages
	" Answer the PARTS message interface of the receiver. "

	^PARTSInterfaceList new
			items: #(#enable #disable #hide #show #setItems: #items #registrationKeyName #registrationKeyName: #registrationValueName #registrationValueName: #autoSaveOnClose: #customize)
			separators: #(4 6 11)
			defaultItem: #setItems:! 
setWidth: pixels
	" Set the width of the receiver to < pixels> "

	self tool setWidth: pixels.
	! 
partEditDirect
        "Edit the directly visible part properties of the receiver."
    self partEditor workbenchPane lafEditNone: self!
reorderPages: pages
    "Private - Reorder pages"

    | goodPages |
    goodPages := pages select: [ :aPage | self pages includes: aPage ].  "Throw out deleted ones.  This
        is needed because pages can be deleted while property dialog is open"
    self pages = goodPages ifTrue: [ ^self ].  "same order"
    self contents: goodPages
! 
partShrunkenIconFile
	" Private - answer the name of the part file containing
        the icon to display when the receiver is shrunk
        in a PARTS Workbench window. "

	^'toolbox.par'!   
display
	" Private - Display the receiver. "

	graphicsTool
		backColor: Color menuBackground;
		foreColor: Color menuText;
		font: self displayFont;
		fill: Color menuBackground.
	self bitmap notNil
		ifTrue: [self bitmap displayAt: 3 @ 3 with: graphicsTool].
	(self label isEmpty not and: [self frameRectangle height = parent toolHeight])
		ifTrue: [graphicsTool displayText: self label at: ((rectangle leftBottom right: (self labelPadding // 4)) up: 3)].
	self isHidden
		ifTrue: [self drawGrid: 5].
	!   
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true! 
constructPropertyManager
	^super constructPropertyManager
		add: ( StylePropertyAccessor name: 'Direct Edit' style: 'LvsEditlabels' pool: WinCommonControlConstants );
		add: ( StylePropertyAccessor name: 'Auto Arrange' style: 'LvsAutoarrange' pool: WinCommonControlConstants );
		add: ( StylePropertyAccessor name: 'Always Show Selection' style: 'LvsShowselalways' pool: WinCommonControlConstants );
		add: ( SelectorPropertyAccessor new name: 'Use Images'; get: #useImages; set: #useImages: ; format: 'Boolean' );
		addNames: #( 'Direct Edit' 'Auto Arrange' 'Always Show Selection' 'Use Images' ) toPage: 'Style';
		"these need to be mutually exclusive"
		add: ( MaskedStylePropertyAccessor name: 'List' style: 'LvsList' pool: WinCommonControlConstants mask: LvsTypemask );
		add: ( MaskedStylePropertyAccessor name: 'Icon' style: 'LvsIcon' pool: WinCommonControlConstants mask: LvsTypemask );
		add: ( MaskedStylePropertyAccessor name: 'Small Icon' style: 'LvsSmallicon' pool: WinCommonControlConstants mask: LvsTypemask );
		add: ( MaskedStylePropertyAccessor name: 'Report' style: 'LvsReport' pool: WinCommonControlConstants mask: LvsTypemask );
		addNames: #( 'List' 'Icon' 'Small Icon' 'Report' ) toPage: 'View';
		"these need to be mutually exclusive"
		add: ( MaskedStylePropertyAccessor name: 'Left' style: 'LvsAlignleft' pool: WinCommonControlConstants mask: LvsAlignmask );
		add: ( MaskedStylePropertyAccessor name: 'Top' style: 'LvsAligntop' pool: WinCommonControlConstants mask: LvsAlignmask );
		addNames: #( 'Left' 'Top' ) toPage: 'Alignment';
		addGroupEditor: 'pplistvw.par';
		yourself!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #filename #filename: #open #isOpen #close
            #pause #play #playFrom: #playFrom:to: #reset #resume #stop
            #length #position #position: #isTimeFormatMilliseconds #isTimeFormatFrames #timeFormat #timeFormatMilliseconds #timeFormatFrames #timeFormat:
            #isNotReady #isPaused #isPlaying #isReady #isSeeking #isStopped
            #audio #audio: #configure  #reverse #reverse: #speed #speed: #video #video:
            #yourself
        )
        separators: #( 5 12 21 27 36 )
        defaultItem: #play!  
constructPropertyManager
   "Construct accessors for receiver's properties."

    ^super constructPropertyManager
        add: ( SelectorPropertyAccessor name: 'File name' get: #filename set: #filename:
            editor: PropertyManager editorForFilename validator: nil );
        addNames: #( 'File name' ) toPage: 'General';
        addGroupEditor: 'ppmcifs.par';
        yourself! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #alignment: with: self alignment;
        addSelectorIfNotNil: #image: with: self image!
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super
		constructPropertyManager
		add:
			(SelectorPropertyAccessor
			new name: 'Width (pixels)';
			get: #width;
			set: #setWidth:;
			format: 'Integer');
		addNames: #('Width (pixels)') toPage: 'Size';
		removeProperty: 'Forecolor';
		removeProperty: 'Backcolor';
		removeProperty: 'Font';
		removeProperty: 'Size window';
		addGroupEditor: 'pptoolsp.par';
		yourself!  
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.

    copy page: ( page partMirrorCopy: aMirrorCopyDictionary).
    ^copy!  
partEnableExecution
	" The application containing the receiver
        is going to be executed.  Do anything necessary
        to make the receiver behave properly during execution. "

	super partEnableExecution.
	tool isNil
		ifTrue: [self createTool].
	tool eventTable: self eventTable.! 
showChanges: propertyDict

    "If the tab attributes  had been modified, force the page to show it."

    ( self propertyAt: #modified ) == true
        ifTrue: [
            self updateTab.
            self propertyAt: #modified put: nil ]! 
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench."
	| stringWithTabs |
	self contents isNil ifTrue: [ ^nil ].
	stringWithTabs := String new asStream.
	self contents
		do: [ :item | stringWithTabs nextPutAll: item string ]
		andBetweenDo: [ stringWithTabs nextPut: "Tab" 9 asCharacter ].
	^stringWithTabs contents!
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
wrap: aBoolean
	"Wrap or unwrap the receiver's tool according to <aBoolean>."

	^self tool wrap: aBoolean! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | rtfString |
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    rtfString := self formattedContents.
    rtfString size > 0 ifTrue: [
        anExpressionModel addSelector: #formattedContents: with:rtfString ]
!
partEditDirect
	"Edit the directly visible part properties of the receiver."

	self partEditor workbenchPane lafEditNone: self!
isPARTSToolbox
	" Answer if the receiver is a PARTSToolboxPart "

	^true!  
isDetachedContainer
	" Answer if the receiver is being used as the detached container "

	^self propertyAt: #isDetachedContainer ifAbsent: [false].!   
partEditProperties
    "Open an editor on the PARTS properties of the receiver."

    self propertyManager editFor: self!  
partSetContents: aList
    self contents: aList! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #contents #contents:
            #selectedItem #selectItem: #deleteItem: #deleteAll #collapseItem: #expandItem:
            #abortChange )
        separators: #( 3 5 11 )
        defaultItem: #contents
!   
constructPropertyManager
	^super constructPropertyManager
		removeProperty: 'Forecolor';
		add: ( StylePropertyAccessor name: 'Direct Edit' style: 'TvsEditlabels' pool: WinCommonControlConstants );
		add: ( StylePropertyAccessor name: 'Buttons' style: 'TvsHasbuttons' pool: WinCommonControlConstants );
		add: ( StylePropertyAccessor name: 'Lines' style: 'TvsHaslines' pool: WinCommonControlConstants );
		add: ( StylePropertyAccessor name: 'Lines At Root' style: 'TvsLinesatroot' pool: WinCommonControlConstants );
		add: ( SelectorPropertyAccessor new name: 'Indent (pixels)';	get: #getIndent; set: #indent: ; format: 'Integer' );
		add: ( SelectorPropertyAccessor new name: 'Use Images'; get: #useImages; set: #useImages: ; format: 'Boolean' );
		addNames: #( 'Direct Edit' 'Buttons' 'Lines' 'Lines At Root' 'Indent (pixels)' 'Use Images' ) toPage: 'Style';
		addGroupEditor: 'pptreevw.par';
		yourself! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.

    copy pages: ( self pages partMirrorCopy: aMirrorCopyDictionary).
    ^copy!   
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "
	^aWindow isPARTSWindow
!   
partEvents
		"Answer the PARTS event interface of the receiver."
	^PARTSInterfaceList new
		items: #(
			#changed:
		)
		separators: #( )
		defaultItem: #changed:!
label
	" Answer the label of the receiver's tool. "

	^self tool label!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #needsContents #needsStringFor: #needsImageFor: #needsStateFor:
            #aboutToChange #changed: #changedIndex: #doubleClicked:
            #checked: #checkedIndex: #unchecked: #uncheckedIndex: #indeterminate: #indeterminateIndex:
            #rightClicked #tabbed )
        separators: #( 4 8 14 )
        defaultItem: #changed:!
partMessages
	" Answer the PARTS message interface of the receiver. "

	^PARTSInterfaceList emptyList! 
toolbar
	" Answer a Toolbar which is connected to the #tools message of the receiver. "

	| tb links msgArgLink |
	self partEditor isNil
		ifTrue: [^nil].
	tb := self partEditor application componentDictionary
		detect:
			[:each |
			each isPARTSToolbar]
		ifNone: [nil].
	tb isNil
		ifTrue: [^nil].
	links := tb partLinksForEvent: #needsContents.
	links
		do:
			[:link |
			(link messageSelector = #setItems: or: [link messageSelector = #insertItems:])
				ifTrue:
					[msgArgLink := (link messageArgLinks) at: 1.
					msgArgLink notNil
						ifTrue:
							[(msgArgLink receiver = self and: [msgArgLink selector = #tools])
								ifTrue: [^tb]]]].
	^nil!  
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelector: #ticks: with: self ticks
!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
         #needsContents #needsStringFor: #needsImageFor: #needsSelectedImageFor: #needsChildrenFor: #needsHasChildrenFor:
            #changed: #doubleClicked: #expanded: #collapsed:
            #aboutToEditLabel: #aboutToChangeLabel:to: #changedLabel:to: #characterTyped:
            #tabbed )
        separators: #( 6 10 14 )
        defaultItem: #changed:!   
partDirectEditTextIsMultiLine
        "Private - Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true!   
partMessages
	" Answer the PARTS message interface of the receiver. "

	^PARTSInterfaceList new items: #(#tools) defaultItem: #tools!  
imageSize
	" Answer the default extent of the image size of a tool ."

	^ToolbarItem defaultBitmapWidth @ ToolbarItem defaultBitmapHeight! 
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self contents isNil
		ifTrue: [ nil ]
		ifFalse: [ self contents collect: [ :item | item string ] ]!
partSetDirectEditAttributeAddRootItemsFrom: stringCollection to: itemList
	| rootItem string tabs |
	1 to: stringCollection size do: [ :index |
		string := stringCollection at: index.
		( tabs := string occurrencesOf: 9 asCharacter ) = 0 ifTrue: [
			rootItem := TreeViewItem new
				object: string;
				string: string.
			itemList add: rootItem.
			self partSetDirectEditAttributeAddChildItemsFrom: stringCollection startingAt: index + 1 to: rootItem level: tabs + 1 ] ]! 
partSelectIn: anEditor
    "Private - The receiver has been selected in a PARTS workbench.
    If the receiver is not the current editor selection, bring the
    page to the top of the notebook and select it."

   " ( self superWindow isKindOf: PARTSTabControlPart )
        ifTrue: [ self superWindow selectItem: page ]."
    ^anEditor workbenchPane lafSelectDefault: self! 
partEditProperties
        " Open an editor on the PARTS properties of the receiver. "

    ( self propertyManager ) editFor: self.
    "self showChanges"!