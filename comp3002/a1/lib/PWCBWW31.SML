3.1.0.106
   
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | newName |

    newName := Prompter
        prompt: 'Enter new part name:'
        default: self partWrapper name.
    newName isNil ifTrue: [^self].
    self partName: newName.!   
partDragTargetDrawEmphasis: aDragSession
    "Private - A menu item is being dragged over the menu.
    Draw visual feedback for insertion point."

    self basicDrawMark: self currentItemIndex.

    super partDragTargetDrawEmphasis: aDragSession
!   
partPropertyHasFrameCreationFlags
    "Answer whether the property set style should modify
        the frame creation flags instead of the style."

    self partsVosOnly.
    ^true!
findIndex: aPoint in: components
    "Private - Answer the index of the menu item at <aPoint>.
    <aPoint> is relative to the receiver."

    self implementedBySubclass!
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'PpWinOpn.par'! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.

    self
        initializeOpeningSizeParts;
        initializeOpeningPositionParts;
        initializeOpenHiddenParts.

	self partsIfOS2Do: [
        self initializeOpenAsDesktopChildParts ].! 
shouldExpand
    "Private"

    ^self partWrapper components size > 0
        and: [
            ( self partWrapper components last object
                frameRectangle bottom down: self gapHeight )
                    isBelow: self frameRectangle bottom ]! 
comboBoxFrameIn: parentRect
		" Private "

    | left top |
    left := parentRect left right: ( leftTop x +  self horizontalGap + ( 3 * self checkBoxWidth + (
        2 * self horizontalGap // 2 ) ) +  self horizontalGap  + self labelWidth + ( self horizontalGap // 2 ) ) .
    top := parentRect top down: ( leftTop y + ( WindowDialog entryHeight * 9 // 8 ) ).
    ^left @ top rightBottom: ( left right: self comboBoxWidth ) @ ( top down: WindowDialog entryHeight * 5 // 2 )!   
gapHeight
        "Private - Answer the gap height between the children."
    | menuItems height |

    height :=
		( menuItems := self children ) size = 0
	        ifTrue: [ 0 ]
	        ifFalse: [
				menuItems asOrderedCollection first
					rectangleAttribute height // 4 ].
	height <= 0
		ifTrue: [ height := SysFont height // 4 ].
	^height! 
partPropertiesIndexOf: anArray
        "Private - Answer the index of the element in anArray
        of style constants which is set in the receiver.
       Check the frame creation flags. "
    | sortedArray |

    self partsIfOS2Do: [
        sortedArray := anArray asSortedCollection: [ :a :b | a >= b].
        ^anArray indexOf:
            (sortedArray
                detect: [ :aStyle | self hasFrameCreationFlag: aStyle]
                ifNone: [^1]) ]

    partsIfWindowsDo: [
        ^super partPropertiesIndexOf: anArray ]!  
lafAddMenuBar
        " Private - create the virtual menu bar for a window part
        being edited in the PW/Win32 workbench window. "

    self partsVwOnly.  " Only used on VW" 
    ( menuWindow notNil and: [ menuWindow isPARTSMenuBar not ] )
        ifTrue: [
            menuWindow := PARTSMenuBar new
                parent: self;
                owner: owner.
            self partApplication
                addComponent: menuWindow
                preferredName: nil
                parent: self
                rectangle: (0 @ 0 extent: 1 @ 1)
                helpInfo: ''
                icon: nil.
            ].
    self lafAddEditPanes.! 
hasBorderStyle: aStyle
    "Private - Answer whether the receiver has
    the dialog border style <aStyle>"

    ^self
        partsIfOS2Do: [ self hasStyle: aStyle ]
        partsIfWindowsDo: [ self hasExtendedStyle: aStyle ]! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #partLabelWithMnemonics: with: self partLabelWithMnemonics.
    accelerator size > 0 ifTrue: [
        anExpressionModel addSelector: #accelerator: with: accelerator ]!   
saveOpenHiddenParts

    settings at: #openHidden put:
        ( self partNamed: 'OpenShownHolder' ) value not.!   
partUndoDirectEdit: originalValue
        "Undo a direct edit operation on the receiver."
    super partUndoDirectEdit: originalValue.
    self display!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: #( #interface )!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  PWO 2.0 label included the
        accelerator; this was split out in PWW 2.0 and
        needs to be upgraded in PWO 3.0. "


    | loadContext oldLabel |

    ( ( loadContext := anObjectFiler clientContext ) isPARTSLoadContext
    and: [ #(
            'LAF/VPM 2.0a'    " PWO 2.0 "
            ) includes: loadContext fileVersion ] )
        ifTrue: [
            accelerator isNil
                ifTrue: [
                    oldLabel := label.
                    label := PARTSMenuPart getLabelFrom: oldLabel.
                    accelerator := PARTSMenuPart getAccelFrom: oldLabel ]
                ifFalse: [
                    accelerator = 'BkSp'
                        ifTrue: [ accelerator := 'BckSp' ]].
"            loadContext loadingExe not
                ifTrue: [ theMenu := nil ]."
             theMenu := nil.
        ].
    ^super fileInUpgrade: anObjectFiler!
expand
    "Private - Expand the receiver to make space for more items"

    self implementedBySubclass!   
partPrintOpenSizePropertiesOn: aStream margin: aString
        " Private "

    aStream
        nextPutAll: aString, 'Initial Visibility: ',
            ( self openHidden
                ifFalse: [ 'Visible' ]
                 ifTrue: [ 'Hidden' ] );
        cr;
        nextPutAll: aString, 'Initial Size: ',
            ( self openingSize = #normal
                ifTrue: [ 'Normal ' ]
                ifFalse: [ self openingSize = #maximized
                    ifTrue: [ 'Maximized' ]
                    ifFalse: [ 'Minimized ' ]]);
        cr.!
partPropertyHelpFile
        "Private - Answer the help file property unit."
    ^ PARTSPropertyString new
        value: self endUserHelpFileName;
        label: 'End-user help file:';
        changeSelector: #endUserHelpFileName: ;
        yourself! 
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup.  Upgrade the frames of the items
        in the receiver. "

    self partsIfOS2Do: [
        self whenValid: #updatePositions ].
    ^super partCodeGenerated: anApplicationBuilder!
saveOpenAsDesktopChildParts

    settings at: #desktopChild put:
        ( self partNamed: 'OpenOnDesktopHolder' ) value.! 
getPosition: anItem after: anchorLabel
    "Private - Answer the new framing rectangle of
    <anItem>.  The rectangle should be positioned
    after the framing rectangle of the <anchorLabel>"

    self implementedBySubclass!   
moveFrom: begin to: end after: anchor
    "Private - Move the items between indicies <begin>
    and <end> after the item <anchor>."
    | front components |
    front := anchor.
    components := self partWrapper components.
    begin to: end do: [:i |
        self position: (components at: i) object
            after: front.
        front := (components at: i) object]!
saveOpeningPositionParts

    ( self partNamed: 'WorkbenchPositionHolder' ) value
        ifTrue: [ ^settings at: #openingPosition put: #workbench ].
    ( self partNamed: 'MousePositionHolder' ) value
        ifTrue: [ ^settings at: #openingPosition put: #mouse ].!   
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyString new
            value: self label;
            label: 'Label:';
            changeSelector: #partSetDirectEditValue: );
        putProperty: #( #interface )! 
partFileInUpgradeLoadedOS2: anObjectFiler
        " Private - finish upgrading subpanes from PW/OS2 2.0.
        Do some cleanup and optimization to get rid of unnecessary stuff. "

    super partFileInUpgradeLoadedOS2: anObjectFiler.

    ( framingBlock isPARTSRectangle
        and: [ framingBlock isBottomInset ])
            ifTrue: [
                framingBlock scaleMask: framingBlock maskForDefault ].!   
expand
    "Private - Expand the receiver to make space for more items"

    self expandBy: (
        Rectangle
            leftTop: ( 0 @ 0 )
            rightBottom:
                ( 0 @ self partWrapper components last object partDefaultExtent y + self gapHeight ) )!
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    super codeGenerationAddAttributeMessagesTo:  anExpressionModel.
    anExpressionModel
        addSelectorIfTrue: #suspendClient: with: self suspendClient

!  
partPropertyValidate: aPropertyStructure
        "Private - Validate the styles specified by the user.
          Ensure that removing the menu bar will not wipe out
          menu labels as well."
    | menuBarProp menuLabels |
    menuBarProp := (aPropertyStructure propertyAt: #hasMenuBar ) value.
    ( self hasMenuBar and: [ menuBarProp not ] )
        ifTrue: [
			self partsIfOS2Do: [ 
				menuLabels := self menuWindow children ]
 			partsIfWindowsDo: [     
				menuLabels := self menuPane children ].

            menuLabels size > 0 ifTrue: [
                ( MessageBox
                    confirm: 'Removing the menu bar will destroy all menu labels. Do you want to proceed ?' )
                    ifTrue: [ ^aPropertyStructure propertiesValid: true ]
                    ifFalse: [ ^aPropertyStructure propertiesValid: false] ] ]!
itemPositionToPoint: row
    "Private - Convert <row> to a Point in the receiver."

    self implementedBySubclass!
getPosition: anItem after: anchorLabel
    "Private - Answer the new framing rectangle of
    <anItem>.  The rectangle should be positioned
    after the framing rectangle of the <anchorLabel>"
    | menuPoint gapX gapY offset extent sizeY |

    menuPoint :=
        (anchorLabel isNil
            ifTrue: [rectangle leftTop]
            ifFalse: [anchorLabel frameRelativeRectangle leftBottom]).
    gapX :=  SysFont width.
    gapY := self gapHeight.
    anItem isPARTSMenuBitmapItemPart
        ifTrue: [
            extent := anItem partSize.
            gapX := rectangle width - extent x // 2]
        ifFalse: [
            extent := rectangle width - (2 * gapX) @
                ( ( sizeY := anItem partSize y ) = 0
                    ifTrue: [ anItem partDefaultExtent y ]
                    ifFalse: [ sizeY ])].
    offset := gapX @ (menuPoint y down: gapY).
    ^(offset extentFromLeftTop: extent)!  
partFileInUpgradeLoaded: anObjectFiler
        " Private - finish upgrading a window part from PARTS Workbench 2.0. "

    super partFileInUpgradeLoaded: anObjectFiler.

    " drop properties which are obsolete or shouldn't be filed "
    self
        propertyAt: #subPaneWithFocus put: nil;
        propertyAt: #sysMenu put: nil.!   
saveOpeningSizeParts

    ( self partNamed: 'NormalHolder' ) value
        ifTrue: [ ^settings at: #openingSize put: #normal ].
    ( self partNamed: 'MaximizedHolder' ) value
        ifTrue: [ ^settings at: #openingSize put: #maximized ].
    ( self partNamed: 'MinimizedHolder' ) value
        ifTrue: [ ^settings at: #openingSize put: #minimized ].!   
drawInsertion: newLoc erase: oldLoc
    "Private - Draw a mark where the item can be
    dropped at <newLoc>.  Erase the old mark at <oldLoc>."

    oldLoc = newLoc
        ifTrue: [ ^nil ].

    oldLoc notNil
        ifTrue: [ self basicDrawMark: oldLoc ].

    self basicDrawMark: newLoc!  
initializeOpeningSizeParts
    "Not allowed for dialog windows."!
partDragTargetReplace: aReplaceSession in: aParent
     "Private - aReplaceSession has just been dropped on the receiver.
    Answer the added part."
    | addedPart |

    addedPart := super partDragTargetReplace: aReplaceSession in: aParent.
    aParent updatePositions.
    ^addedPart!   
partApplicableStylePrefixes
    ^#()!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #partLabelWithMnemonics: with: self partLabelWithMnemonics!  
itemPositionToPoint: row
    "Private - Convert <row> to a Point in the receiver."
    | components |

    ^( row <= 1
        ifTrue: [ rectangle top down: self gapHeight / 2 + 1 ]
        ifFalse: [
                "GetItemYPos"
                components := self partWrapper components.
                "must use the component above the line, since the
                    component just inserted below the line may not be open yet."
                ((components at: row - 1) object
                frameRelativeRectangle bottom down: self gapHeight / 2 ) ]) rounded!
partPropertyAddStyleMinMaxItems: aPropertyStructure
        " Private - add style items for min/max buttons.
        Dialog windows can't minimize nor maximize"!   
partGetGraphics
    "Private"
    self error: 'not supported for dialog window'
!  
partPropertiesToMessagesMap
        "Answer an Array of Arrays.  The sub Arrays have
        three elements - first is a propertyName, second is
        a set selector to set that property, third is the name
        of the pool dictionary (if any) which defines the name of
        the value."
    ^super partPropertiesToMessagesMap,
        #(    #(#icon #icon: '' ) )! 
partUndoDirectEdit: originalValue
        "Undo a direct edit operation on the receiver."
    super partUndoDirectEdit: originalValue.
    self display!   
partDragTargetReplace: aReplaceSession in: aParent
     "Private - aReplaceSession has just been dropped on the receiver.
    Answer the added part."
    | addedPart |
    addedPart := super partDragTargetReplace: aReplaceSession in: aParent.
   aParent updatePositions.
    ^addedPart!  
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        when: #aboutToAcceptChanges:
        send: #partPropertyValidate: to: self.
    aPropertyStructure
        putProperty: self partPropertyLabel;
        putProperty: self partPropertyHelpFile;
        yourself.
    self
        partPropertyAddStyleItems: aPropertyStructure.
    aPropertyStructure
        putProperty: ( PARTSPropertyIcon new
            value: self icon );
        putProperty: #( #setBackColor );
        putProperty: PARTSPropertySequenceChildren new ;
        at: #editButton putProperty: ( PARTSPropertyEditButton new
            label: 'Opening Styles...';
            value: (properties at: #openWindowProperties ifAbsent: [ Dictionary new ]);
            clickedSelector: #partPropertyOpenWindowProperties:   ;
            changeSelector: #partPropertySaveNewValues:  ;
            makeSameLine );
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!   
partPropertySaveNewValues: valuesDict
        "Private - set the new opening window properties of the receiver."

    self
        openingSize: ( valuesDict at: #openingSize ifAbsent: [ #normal ] );
        openingPosition: ( valuesDict at: #openingPosition ifAbsent: [ #workbench ] );
        openHidden: ( valuesDict at: #openHidden ifAbsent: [ false ] ).

    self partsIfOS2Do: [
        self partIsDesktopChild: ( valuesDict at: #desktopChild ifAbsent: [ false ])].!  
partPropertySetAlternateStyles: newStyleDictionary
        "Private - Change the receiver's aternate styles.
    e.g. extendedStyle."
    | extendedStyleAttribute styleAttribute |

    "OS/2 has no alternate styles at this time"
    self partsIfOS2Do: [ ^super partPropertySetAlternateStyles: newStyleDictionary ].

    ( newStyleDictionary includesKey: #extendedStyle )
        ifFalse: [ ^nil ].

    "The alternate style that is valid for the receiver is the dialog border.
    Note: the single line border style goes in 'style' while the dialog
    border style goes in 'extendedStyle' "
    extendedStyleAttribute := newStyleDictionary at: #extendedStyle.
    styleAttribute := ( newStyleDictionary includesKey: #style )
        ifTrue: [ newStyleDictionary at: #style ]
        ifFalse: [ style ].
    ( extendedStyleAttribute bitAnd: WsDialogBorder ) = WsDialogBorder
        ifTrue: [ "Dialog Border goes in extended style, Single line border removed from extended style"
            extendedStyleAttribute :=
                extendedStyleAttribute bitAnd: ( WsNonSizingBorder bitXor: 16rFFFFFFFF )]
        ifFalse: [ "Single line border removed from extended style and added to style"
            extendedStyleAttribute :=
                extendedStyleAttribute bitAnd: ( WsNonSizingBorder bitXor: 16rFFFFFFFF ).
            "styleAttribute := styleAttribute | WsNonSizingBorder" ].

    self extendedStyle: extendedStyleAttribute.
    self setStyle: styleAttribute!  
partPropertyStyle
        "Private - Answer the receiver's style."

    ^self partsIfOS2Do: [
        super partPropertyStyle ]
    partsIfWindowsDo: [
        self partsVwOnly.  " Only used on VW"
        super partPropertyStyle
            at: #extendedStyle
            put: self extendedStyle;
            yourself ]!   
select: selectedItem
    "Private - The selection in the drop down list has changed."

    self setModified: true;
        setAcceleratorString!  
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Menu Item'! 
labelFrameIn: parentRect
		" Private "

    | left top |
    left := parentRect left right: ( leftTop x  + ( self horizontalGap + (
        3 * self checkBoxWidth +  ( 2 * self horizontalGap // 2 ) )  +  self horizontalGap ) ).
    top := ( parentRect top down: leftTop y +  ( WindowDialog entryHeight * 9 // 8 ) ) .
    ^left @ top extentFromLeftTop: self labelWidth @ WindowDialog entryHeight!
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #labelWithoutPrefix: with: self label;
        addSelectorIfNotNil: #framingBlock: with: self framingBlock;
        addSelectorIfNotNil: #openWindowProperties: with: self openWindowProperties.
    self addMenuWindowMessageModelsTo: anExpressionModel
!   
position: anItem after: anchor
    "Private - Position aMenuItem after another menu item, anchor."
    | tempRect oldRect newRect partEditorPane |

    partEditorPane := self partEditorPane.
    ( oldRect := anItem frameRelativeRectangle ) =
        ( tempRect := self getPosition: anItem after: anchor )
        ifTrue: [ ^self ].

    anItem resizeToRectangle: tempRect.
    self partsIfOS2Do: [ anItem sizeChanged: tempRect extent ].
    newRect := anItem frameRectangle mapToWindow: partEditorPane.

    self superWindow isPARTSNestedPart not
        ifTrue: [
            self partEditor linkEditor
                refreshAfterMoveOf: ( Array with: anItem )
                from: ( Array with: ( oldRect mapFromWindow: self superWindow to: partEditorPane ))
                to: ( Array with: newRect ) ].!  
partApplicableStylePrefixes
    ^#()!
clicked: aCheckBox
		" Private "

    self 
		setModified: true;
        setAcceleratorString!   
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | newName |
    newName := Prompter
        prompt: 'Enter new part name:'
        default: self partName.
    newName isNil ifTrue: [^self].
    self partName: newName.! 
partPropertyOpeningStylePropertiesEditor
    "Answer the editor for the window's opening styles."

    ^PARTSOpenDialogWindowPropertiesEditor! 
labelWidth
		" Private "

    ^PARTSDialog horizontalDialogUnitsFromPixels: (self font stringWidth: 'Keystroke:')! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    | oc |

    super partPrintPropertiesOn: aStream margin: aString.

    aStream
        nextPutAll: aString, 'Initial Position: ',
            ( self openingPosition = #workbench
                ifTrue: [ 'Relative to the display' ]
                ifFalse: [ 'Centered on the cursor' ] );
        cr.
    self partPrintOpenSizePropertiesOn: aStream margin: aString.

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
setAcceleratorString
    "Private - Set the new accelerator string (eg. 'Ctrl+BkSp') for the
      menu item. "

    | aStream keys accelChar |
    accelChar := ( self controls at: 4 ) value.
    accelChar = 'None' ifTrue: [
        newValue := nil .
        ^self ].

    aStream := WriteStream on: String new.
    keys := #( 'Ctrl' 'Alt' 'Shift' ).
    1 to: keys size do: [: i |
        ( self controls at: i ) selection ifTrue: [
            aStream nextPutAll: ( ( keys at: i ) , '+' ) ] ].

    "accelChar := Accelerators at: accelChar ifAbsent: [ accelChar ]."
    aStream nextPutAll: accelChar.
    newValue := aStream contents.!   
partPropertyBorderStyle
        "Private - Answer the border styles property unit."
    | selectedIndex |
    selectedIndex :=  (self class borderStyleValues notNil
        ifTrue: [self partPropertiesIndexOf: self class borderStyleValues]
        ifFalse: [
            (self hasBorderStyle: self partPropertyDefaultBorderStyle)
                ifTrue: [1]
                ifFalse: [ 2] ] ).
    ^( self borderPropertyClass new
        label: 'Border';
        labelsMap: self class borderStyleLabels;
        initialSelection: selectedIndex)!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #bitmap: with: self bitmap!  
hasBorderStyle: aStyle
    "Private - Answer whether the receiver has
    the border style <aStyle>"

    ^self hasStyle: aStyle! 
partPropertyAddStyleMinMaxItems: aPropertyStructure
        " Private - add style items for min/max buttons. "

    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: 'Minimize button'
            constant: WsMinimizeButton );
        putProperty: ( self partPropertyWindowStyle: 'Maximize button'
            constant: WsMaximizeButton ).!  
move: anItem to: aPoint
    "Private - Move <anItem> from its
    current position to <aPoint>. <aPoint is relative
    to the receiver."

    self disableRedraw.
    self move: anItem toIndex: (self findIndex: aPoint).
    self realInvalidateRect: nil.
    self enableRedraw.
    self partEditor redisplaySelection.!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Menu'!  
partGetGraphics
    "Private"
    ^self icon
! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Text Menu Item'!
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: ( PARTSPropertyString new
            value: label;
            label: 'Label:';
            changeSelector: #contents: );
        putProperty: ( PARTSPropertyMenuAccelerator new
            value: accelerator;
            changeSelector: #setAccelerator: ;
            yourself );
        putProperty: #( #interface )!
partApplicableStylePrefixes

    ^#()!  
comboBoxWidth
        "Private - Answer the width of the combo box."
    ^WindowDialog entryHeight * 3! 
initializeOpenHiddenParts
    "Set the value holders that initialize the radio buttons."

    settings at: #openHidden ifAbsent: [
        settings at: #openHidden put: nil ].
    ( self partNamed: 'OpenShownHolder' ) setValue:
        ( (settings at: #openHidden) isNil or: [
          (settings at: #openHidden) not ]).! 
refreshItems
    "Refresh all items in the receiver"

    self refreshItems: self shouldExpand.!   
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object.
        Upgrade tab stop and order info in a PWO 2.0 window. "

    | loadContext |

    loadContext := anObjectFiler clientContext.
    loadContext isPARTSLoadContext not
        ifTrue: [ ^super fileInUpgrade: anObjectFiler ].

    " PWO 2.0 application upgrades "
    ( #(
        'LAF/VPM 2.0a'    " PARTS 2.0 for OS/2 "
        )
            includes: loadContext fileVersion )
        ifTrue: [
            anObjectFiler
                when: #loaded
                send: #partUpgradeTabInfoOS2: to: self with: anObjectFiler.
            ].

    anObjectFiler objectVersion <= 8
        ifTrue: [ "Versions up to, but not including 3.0"
            self partsIfOS2Do: [
                #(
                "WsTitleBar" 1
                "WsSystemMenu" 2
                "WsMinimizeButton" 16
                "WsMaximizeButton" 32
                "WsSizingBorder" 8
                "WsNonSizingBorder" 512
                "WsDialogBorder" 256    ) do: [ :aFrameCreationFlag |
                    ( self hasStyle: aFrameCreationFlag )
                        ifTrue: [
                            self removeStyle: aFrameCreationFlag.
                            self addFrameCreationFlags: aFrameCreationFlag ]
                        ifFalse: [
                            self removeFrameCreationFlags: aFrameCreationFlag ]]]].


    ( #(
        'PARTS/Win32 2.0'    " PARTS 2.0 for OS/2 "
        )
            includes: loadContext fileVersion )
        ifTrue: [  "Should not be filed not, nor its parent (PARTSClientAreaPane)"
                self propertyAt: #defaultPushButton put: nil
            ].

    " ensure state is consistent with 3.0 #initialize settings "
    label isNil
        ifTrue: [ label := String new ].
    self icon isNil
        ifTrue: [ self icon: PARTSApplication defaultIcon ].
   ^super fileInUpgrade: anObjectFiler!   
basicDrawMark: row
    "Private - Draw the insertion mark
    at index position <loc>. "
    | roundedPointY pen |

    ( row isNil or: [ row < 1 ])
        ifTrue: [^false].

    roundedPointY := self itemPositionToPoint: row.

    self doGraphics: [
    pen := self pen.
    pen
        foreColor: Color white;
        setForegroundMode: MixRuleInvertSurface;
        place: 1 @ roundedPointY;
        line: (rectangle extent x - 2 @ roundedPointY );
        setForegroundMode: MixRuleDefault ].!   
initializeOpenAsDesktopChildParts
    "Set the value holder that initializes the check button."

    ( settings at: #desktopChild ifAbsent: [ nil ]) isNil
        ifTrue: [ settings at: #desktopChild put: false ].
    ( self partNamed: 'OpenOnDesktopHolder' ) setValue:
        ( settings at: #desktopChild ).!  
partTargetEmphasisRectangle
        "Private - answer a rectangle to be used for
        drag target emphasis. Make the rectangle a little
        bigger than normal to make seeing the insertion
        point easier."

    ^self rectangle! 
checkBoxWidth
		" Private "

    ^PARTSDialog horizontalDialogUnitsFromPixels: ( self font stringWidth:  ' X ','Shift' )!  
partPropertySetStyle: newStyle
        "Private - Change the receiver's style."
    | realStyle |

    self partsIfOS2Do: [
        ^super partPropertySetStyle:  newStyle ]

    partsIfWindowsDo: [
        realStyle := newStyle.
        self setStyle: ( newStyle | WsChildWindow bitAnd: ( WsPopUp bitXor: 16rFFFFFFFF ) ).
        self style: realStyle ]!  
saveOpenHiddenParts
    "Can't hide a dialog window."

    settings at: #openHidden put: false!
openOn: openWindowStyles

    settings := openWindowStyles.
    self openDialogWindow isNil
        ifTrue: [ ^nil ].  " couldn't get the dialog open "

    ( self partNamed: 'OK' ) value   "If OK button clicked, this value holder is set."
        ifFalse: [ ^nil ].

    self
        saveOpeningSizeParts;
        saveOpeningPositionParts;
        saveOpenHiddenParts.

    self partsIfOS2Do: [
        self saveOpenAsDesktopChildParts ].

    ^settings!  
fileName
        " Private - Answer the name of the part file
        containing the property dialog. "

    ^'PpDlgOpn.par'! 
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

    | aPropertyStructure |
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure
        putProperty: self partPropertyLabel;
        yourself.
    self
        partPropertyAddStyleItems: aPropertyStructure.
    aPropertyStructure
        putProperty: ( PARTSPropertyBoolean new
            value: self suspendClient;
            label: 'Wait for answer';
            changeSelector: #suspendClient: ).
    aPropertyStructure
        putProperty: #( #setBackColor );
        putProperty: PARTSPropertySequenceChildren new;
        at: #editButton putProperty: ( PARTSPropertyEditButton new
            label: 'Opening Styles...';
            value: (properties at: #openWindowProperties ifAbsent: [ Dictionary new ]);
            clickedSelector: #partPropertyOpenWindowProperties:   ;
            changeSelector: #partPropertySaveNewValues:  ;
            makeSameLine );
        putProperty: #( #interface #sizeWindow ).
    ^aPropertyStructure!  
isOkToDisable: aWindow
        " Private - answer whether aWindow should really be disabled. "
    | windowOwner w |

    aWindow isNil ifTrue: [ ^true ].
    self modal ifFalse: [ ^false ].

    w := self
        partsIfOS2Do: [ Window isFrameWindow
            ifTrue: [ aWindow child ]
            ifFalse: [ aWindow ] ]
        partsIfWindowsDo: [ aWindow ].
    windowOwner := w owner.
    ( ( windowOwner isPARTSEditor   " don't disable editor when testing!! "
            or: [ windowOwner isPARTSCatalog ] )  " or dragging from catalog "
    and: [ self allowWorkbenchToBeDisabled not ] )
        ifTrue: [ ^false ].
    windowOwner class == PARTSEditor editorClass debuggerClass
        ifTrue: [ ^false ].
    ^true! 
expandBy: delta
        "Private - Expand (resize) the receiver by delta."
    | rect |
    rect := (self frameRectangle expandBy: delta)
        mapToWindow: self superWindow.
    self resizeToRectangle: rect.
    self partsIfOS2Do: [ self sizeChanged: self extent ].
    self invalidateRect: nil! 
partPropertyLabel
        "Private - Answer the label property unit."
    ^PARTSPropertyString new
        value: label;
        label: 'Dialog label:';
        changeSelector: #contents: ;
        yourself! 
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    | loadContext |

    ( loadContext := anObjectFiler clientContext ) isPARTSLoadContext
        ifTrue: [
            " don't need to store actual menu in editable applications "
"            loadContext loadingExe not
                ifTrue: [ menuObject := nil ]."
             menuObject := nil.
        ].

    self
        partsIfOS2Do: [
            anObjectFiler
                when: #loaded
                send: #whenValid:
                to: self
                with: #updatePositions ].
    ^super fileInUpgrade: anObjectFiler!
initializeOpenHiddenParts
    "Not allowed for dialog windows."! 
saveOpeningSizeParts
    "Not allowed on dialog windows. Set to normal."

    settings at: #openingSize put: #normal.! 
partGetGraphics
        "Answer the receiver's bitmap."
    bitmap isNil
        ifTrue: [^Bitmap screenExtent: self partSize]
        ifFalse: [^bitmap]!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Menu Label'!
basicDrawMark: loc
    "Private - Draw the insertion mark at index position <loc>. "

    self implementedBySubclass!  
findIndex: aPoint
    "Private - Answer the index of the item at <aPoint>.
    <aPoint> is relative to the receiver."

    ^self findIndex: aPoint in: ( self partWrapper components ).!  
noMenuBar
        "Configure the receiver to not have a menu bar."
    self menuWindow: nil
!  
partPropertyLabel
        "Private - Answer the label property unit."
    ^ PARTSPropertyString new
        value: label;
        label: 'Window label:';
        changeSelector: #contents: ;
        yourself!
computeWidth
        "Private - compute and answer the width of the receiver."

    ^3 * self checkBoxWidth + self labelWidth + self comboBoxWidth  + ( self horizontalGap * 4 )!  
partPropertyOpeningStylePropertiesEditor
    "Answer the editor for the window's opening styles."

    ^PARTSOpenWindowPropertiesEditor!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Menu Item Separator'!   
partFileInUpgradeLoadedOS2: anObjectFiler
        " Private - finish upgrading subpanes from PW/OS2 2.0.
        Do some cleanup and optimization to get rid of unnecessary stuff. "

    super partFileInUpgradeLoadedOS2: anObjectFiler.

    ( framingBlock isPARTSRectangle
        and: [ framingBlock isBottomInset ])
            ifTrue: [
                framingBlock scaleMask: framingBlock maskForDefault ].!   
addToWindow: aTopPane
		" Private - create panes in <aTopPane> to represent
		the receiver's value. "

    | checkBoxes c cb |
    aTopPane
        addSubpane: (GroupBox new
            owner: self;
            font: self font;
            contents: 'Accelerator';
            framingBlock: self framingBlock ).

    checkBoxes := #( 'Ctrl' 'Alt' 'Shift' ).
    controls := Array new: 4.
    1 to: checkBoxes size do: [: i |
        c := CheckBox new.
        aTopPane addSubpane: ( c
            owner: self;
           when: #clicked:
                send: #clicked: to: self with: c;
            font: self font;
            setName: (checkBoxes at: i);
            contents: (checkBoxes at: i);
            framingBlock: ( self checkBoxFrameFor: i  ) ).
        controls at: i put: c ].

    aTopPane
        addSubpane: (StaticText rightJustified
            owner: self;
            font: self font;
            contents: 'Keystroke:';
            framingBlock: [ :b | self labelFrameIn: b ] );
        addSubpane: ( cb := ComboBox new
            owner: self;
            font: self font;
            contents: VirtualKeys ;
            "selection: (self getSelectionFor: oldValue);"
			when: #aboutToChange send: #aboutToChange: to: self with: cb;
            when: #changed: send: #select: to: self;
            framingBlock: [ :b | self comboBoxFrameIn: b]).
    controls at: 4 put: cb.

    aTopPane
        when: #opened
        send: #setSelections to: self!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    anExpressionModel
        addSelectorIfNotNil: #index: with: self indexAttribute!   
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: #( #interface #editBitmap )!   
gapHeight
        "Private - Answer the gap height."

    self implementedBySubclass!  
partPropertySetStyle: newStyle
    "Private - Change the receiver's style.
        'style:' is used when styles apply to w.b. only, and
        not during runtime"
    | winStyle |

	self partsIfOS2Do: [
		^super partPropertySetStyle:  newStyle ]

    partsIfWindowsDo: [
        winStyle := newStyle.
        (newStyle bitAnd: WsTitleBar) = WsTitleBar
            ifFalse: [
                winStyle := (newStyle | WsPopUp | WsPaneBorder)].
        self setStyle:
                (( newStyle | WsChildWindow | WsPaneBorder )
                    bitAnd: (WsPopUp bitXor: 16rFFFFFFFF )).
            self style: winStyle ]!   
computeHeight
        "Private - compute and answer the height of the receiver."

    ^WindowDialog entryHeight * 5 // 2!  
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^anObject partIsWindow!  
initializeOpeningPositionParts
    "Set the value holders that initialize the radio buttons."

    settings at: #openingPosition ifAbsent: [
        settings at: #openingPosition put: #workbench ].
    ( self partNamed: 'WorkbenchPositionHolder' ) setValue:
        ( (settings at: #openingPosition) isNil or: [
          (settings at: #openingPosition) = #workbench ] ).
    ( self partNamed: 'MousePositionHolder' ) setValue:
        ( (settings at: #openingPosition) = #mouse ).!   
initialize
    "Private - Initialize class variables.
      PropertyMenuAccelerator initialize. "

    VirtualKeys :=
        #('None' 'BckSp' 'PgUp' 'PgDn' 'End' 'Home' 'Left'
            'Right' 'Down' 'Ins' 'Del' 'F2' 'F3' 'F4' 'F5' 'F6'  'F7' 'F8' 'F9'
            'F10' 'F11' 'F12' ).

    "AcceleratorNames :=
        #('None' 'Back Space' 'Page Up' 'Page Down' 'End' 'Home' 'Left'
            'Right' 'Down' 'Insert' 'Delete' 'F2' 'F3' 'F4' 'F5' 'F6'  'F7' 'F8' 'F9'
            'F10' 'F11' 'F12' ).

    Accelerators := Dictionary new.
    Accelerators at: 'Back Space' put: 'BkSp';
        at: 'Page Up' put: 'PgUp';
        at: 'Page Down' put: 'PgDn';
        at: 'End' put: 'End';
        at: 'Home' put: 'Home';
        at: 'Left' put: 'Left';
        at: 'Right' put: 'Right';
        at: 'Down' put: 'Down';
        at: 'Insert' put: 'Ins';
        at: 'Delete' put: 'Del';
        at: 'F2' put: 'F2';
        at: 'F3' put: 'F3';
        at: 'F4' put: 'F4';
        at: 'F5' put: 'F5';
        at: 'F6' put: 'F6';
        at: 'F7' put: 'F7';
        at: 'F8' put: 'F8';
        at: 'F9' put: 'F9';
        at: 'F10' put: 'F10';
        at: 'F11' put: 'F11';
        at: 'F12' put: 'F12';
        yourself
"!   
addMenuWindowMessageModelsTo: anExpressionModel
        "Private - add message models to the menu window to a rebuilt
        version of the receiver.  Dialog windows have no menu window,
        so do nothing."!   
setSelections
    "Private - Set the state for the check boxes and the
      combo box selection."

    | aStream virtualKeys keys acceleratorChar index |
    self originalValue size = 0 
		ifTrue: [ ^self ].
    virtualKeys := OrderedCollection new.
    aStream := ReadStream on: self originalValue.
    [ aStream atEnd ] whileFalse: [
        virtualKeys add: ( aStream upTo: $+ ) trimBlanks ].

    keys := #( 'Ctrl' 'Alt' 'Shift' ).
    virtualKeys do: [: virtualKey |
        ( keys includes: virtualKey ) ifTrue: [
            ( self controls at: ( keys indexOf: virtualKey ) ) check ] ].

    acceleratorChar := virtualKeys last.
    ( keys includes: acceleratorChar ) ifFalse: [
        index := VirtualKeys indexOf: acceleratorChar ifAbsent: [
            "a character"
            ( self controls at: 4 ) setValue: acceleratorChar.
            ^self ].
        ( self controls at: 4) selectIndex: index ]!
partPropertySetMenuBarOS2: aBoolean
        " Private - set the menu bar option of the receiver. "
    | changedRect wrapper aRect labels undoRedoInfo |

    self partsVosOnly.  " Only used on VOS"

    aBoolean
        ifTrue: [    "Add a menu window"
            self propertyAt: #noMenuBar put: nil.
            menuWindow notNil
                ifTrue: [^self].

            menuWindow := PARTSMenuBar new.
            menuWindow
                parent: self;
                owner: owner;
                buildWindow: self frameWindow;
                showWindow.

            wrapper := self partWrapper.
            self partEditor
                addComponentToApplication:  menuWindow name: nil;
                createWrapperFor: menuWindow
                parentWrapper: wrapper
                box: (0 @ 0 extent: 1 @ 1)
                helpInfo: wrapper helpInfo.
            changedRect := menuWindow frameRectangle]

        ifFalse: [ "Remove the menu window"
            self propertyAt: #noMenuBar put: true.
            menuWindow isNil
                ifTrue: [ ^self ].
            changedRect := menuWindow frameRectangle.
            wrapper := menuWindow partWrapper.
            wrapper notNil ifTrue: [
                menuWindow children notNil ifTrue: [
                    (labels := menuWindow children values) size > 0 ifTrue: [
                        (undoRedoInfo :=
                                  self partEditor linkEditor removeLinksAttachedTo: labels) notNil ifTrue: [
                                  self partEditor removedLinks: ( undoRedoInfo at: 3 ) ]]].
                    self partApplication removeComponentsOwnedBy: wrapper].
                menuWindow destroy.
                menuWindow := nil ].

    self partEditor refreshedRectangle: changedRect.
    aRect := self frameRelativeRectangle.
    self resizeToRectangle: (aRect insetBy: 1).
    self resizeToRectangle: (aRect expandBy: 1)! 
lafAddEditPane: anEditPane
        "Private - Add anEditPane to the receiver.
        Used for PW/Win32 menu bar support in workbench. "

    self partsVwOnly.  " Only used on VW"
    self partApplication
        addComponent: anEditPane
        preferredName: anEditPane class name
        parent: self
        rectangle: (0 @ 0 extent: 1 @ 1)    "dummy rectangle"
        helpInfo: ''
        icon: nil.
    self addSubpane: anEditPane.
      "Place at the top (first amoung those that affect client area)"
    self childrenAffectingClientArea
        remove: anEditPane ifAbsent: [ nil ];
        addFirst: anEditPane.
    anEditPane subclassWndProc.!   
refreshItems: expand
    "Refresh all items in the receiver"

    expand
        ifTrue: [ self expand ]
        ifFalse: [ self invalidateRect: nil ].

    self updatePositions! 
draggingOver: aDragSession
    "Private - The item is passing over the receiver.
     Draw the receiver's drop mark."
    | oldItemIndex newItemIndex |

    oldItemIndex := self currentItemIndex.
    newItemIndex := self findIndex: ( aDragSession targetLocation ).
    self currentItemIndex: newItemIndex.
    self drawInsertion: newItemIndex erase: oldItemIndex!   
partDroppedPart: aPart hotSpot: hotSpot origin: origin
    "Private - <aPart> has been dragged into the
    receiver.  <aPart> is either an application or a part.
    Add the menu item at the correct position in the
    menu. <aPoint> is in editor pane coordinates."
    | components originalComponents currentLocation
        insertionPoint menuLabelWrapper |

    hotSpot isNil ifTrue: [ ^self refreshItems ]. "Duplicated <aPart>"

    menuLabelWrapper :=
        aPart isPARTSApplication
            ifTrue: [ aPart mainObjectPrivate partWrapper ]
            ifFalse: [ aPart partWrapper ].
    components := self partWrapper components asOrderedCollection.
    originalComponents :=
        components select: [ :each | each ~= menuLabelWrapper ].
    insertionPoint :=
        hotSpot isNil
            ifTrue: [ originalComponents size + 1 ]
            ifFalse: [
                self findIndex:
                    ( hotSpot mapFromWindow: self partEditor workbenchPane to: self )
                    in: originalComponents ].
    (( currentLocation := components indexOf: menuLabelWrapper ) > 0
        and: [ hotSpot notNil ])
        ifTrue: [ components removeIndex: currentLocation ].
    components add: menuLabelWrapper beforeIndex: insertionPoint.
    self partWrapper components: components.

    self partEditor selectOff: menuLabelWrapper object.

    "Enlarge menu if items go below menu bottom"
    ( originalComponents notEmpty and: [
        (( originalComponents last  object
            frameRectangle bottom down:
            menuLabelWrapper object partSize y +
            ( self gapHeight * 2 ))
            isBelow: self frameRectangle bottom ) ] )
        ifTrue: [ self refreshItems: true ]
        ifFalse: [ self updatePositions ].

    self partEditor select: menuLabelWrapper object.
! 
supportsRecycling
        " Answer whether instances of the receiver
        can be recycled after use. "

    ^true! 
borderPropertyClass
    "Private"
    ^PARTSPropertyButtonGroupWS!  
partDragTargetEraseEmphasis: aDragSession
    "Private - erase drag drop target emphasis.
    The menu item is being dragged away from the
    menu or being dropped in the menu."

    super partDragTargetEraseEmphasis: aDragSession.
    self currentItemIndex: nil.

!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Window'!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system. "

    | loadContext |
    ( loadContext := anObjectFiler clientContext ) isPARTSLoadContext
        ifTrue: [
            " don't need to store actual menu in editable applications "
"            loadContext loadingExe not
                ifTrue: [ theMenu := nil ]."
            theMenu := nil.
        ].
    ^super fileInUpgrade: anObjectFiler!
borderPropertyClass
    "Private"

    ^self
        partsIfOS2Do: [ super borderPropertyClass ]
        partsIfWindowsDo: [
            self partsVwOnly.  " Only used on VW"
            Smalltalk at: #PARTSPropertyButtonGroupWSExtended ifAbsent: [ nil ]]!   
partEditDirect
        "Edit the directly visible part properties of the receiver."
    | undo initValue |
    undo := self partGetGraphics.
    initValue := undo clone.
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
partIsShrinkable
        "Private - Can this part shrink in a PARTS Workbench."

    ^self superWindow isPARTSEditorPane!  
partCodeGenerated: anApplicationBuilder
            "Private - The application containing the receiver has just
            been reconstructed from generated code. Perform any
        finalization or cleanup."
    self partWrapper rectangle: self framingBlock.
    ^super partCodeGenerated: anApplicationBuilder! 
partProperties
        " Private - answer a PARTS property structure containing 
        the receiver's editable properties. "

    ^( PARTSPropertyStructure on: self )
        putProperty: #( #interface )!   
menuLabelParts
        "Private - answer the menu labels in the receiver's menu bar."
    ^menuWindow menuLabelParts!   
aboutToChange: aComboBox
	"Private - do nothing - supress the default about to change notification."!
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Graphical Menu Item'!   
eraseSelection
    "Private - Erase the insertion mark created when an item
    is dragged to the receiver."

    self basicDrawMark: self currentItemIndex!  
partDragTargetEnter: aDragSession
        "Private - aDragSession has just entered the receiver. "

    self currentItemIndex: ( self findIndex: ( aDragSession targetLocation )).

    super partDragTargetEnter: aDragSession! 
lafAddEditPanes
        "Private - Add PARTSMenuPane as a child of the receiver.
        This is needed when editing a window part in the PW/Win32
        workbench in order to support the menu bar because a child
        window (child of the workbench) cannot have a real menu bar. "

    | partEditor menuPane menuWrappers hasMenuBar |

    self partsVwOnly.

    partEditor := self partEditor.

    menuPane := self menuPane.
    hasMenuBar := false.
    (menuWindow notNil and: [menuPane isNil])        "don't create menu pane if one already exist"
         ifTrue: [
            hasMenuBar := true.
            menuPane := partEditor windowsWorkbenchMenuBarClass new.
            self lafAddEditPane: menuPane.
            (menuWrappers := menuWindow partWrapper components) size > 0
                ifTrue: [        "make menuWindow's children child windows of menu pane."
                    menuWrappers copy do: [: menuLabelWrapper |
                        menuPane partWrapper addComponent: menuLabelWrapper.
                        menuPane addSubpane: menuLabelWrapper object.
                        menuWindow partWrapper removeComponent: menuLabelWrapper.
                        menuWindow children removeKey: (
                                    menuWindow children keyAtValue: menuLabelWrapper object)]].
              "Place at the top (first amoung those that affect client area)"
            self childrenAffectingClientArea
                remove: menuPane ifAbsent: [ nil ];
                addFirst: menuPane ].!  
findIndex: aPoint in: components
    "Private - Answer the index of the menu item at <aPoint>.
    <aPoint> is relative to the receiver.
        The index is the position where <aPoint> is between the
    midpoints of the two items beside <loc> in <components>."
    | row |
    row := 1.
    components size > 0 ifTrue: [
        components do: [:aWrapper |
            (( aWrapper object frameRelativeRectangle center) y
                    isAboveEqual: aPoint y)
                ifTrue: [row := row + 1]
                ifFalse: [^row]]].
    ^row! 
partPropertyDefaultBorderStyle
        " Private "
    ^WsDialogBorder! 
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Dialog Window'! 
partPropertyAddStyleItems: aPropertyStructure
        " Private - add style items to the property structure."
    aPropertyStructure
        putProperty: self partPropertyBorderStyle;
        putProperty: ( self partPropertyWindowStyle: 'Title bar'
            constant: WsTitleBar );
        yourself. 
    self supportsMenuBar
        ifTrue: [
            aPropertyStructure
                at: #hasMenuBar
                putProperty: ( PARTSPropertyPseudoStyle new
                    value: self hasMenuBar;
                    label: 'Menu bar';
                    changeSelector: #partPropertySetMenuBar: ) ].
    aPropertyStructure
        putProperty: ( self partPropertyWindowStyle: SystemMenuLabel
            constant: WsSystemMenu );
        yourself.
    self partPropertyAddStyleMinMaxItems: aPropertyStructure!   
partPropertyOpenWindowProperties: aPropertyButton
        "Private - Bring up the editor for properties of opening the window.
         Set the value holders in the editor.
         Store the new values into the
         value of aPropertyButton (Edit Button... ). "
    | settingsDict newValues |

    settingsDict := aPropertyButton newValue.
    newValues := self partPropertyOpeningStylePropertiesEditor new
        openOn: settingsDict deepCopy.

    newValues isNil
        ifTrue: [^self].

    aPropertyButton newValue: newValues.! 
adjustPositionAfterUndoDelete: anItem
    "Private - Adjust the position of aMenuItem after an undo delete."

    self
        move: anItem
        toIndex: (  self findIndex: anItem frameRelativeRectangle leftTop )! 
partPropertySetMenuBar: aBoolean
        " Private - set the menu bar option of the receiver. "

    self partsIfOS2Do: [
        self partPropertySetMenuBarOS2: aBoolean ]

    partsIfWindowsDo: [
        self partPropertySetMenuBarWindows: aBoolean ].

    self partEditor linkEditor redisplayLinks.!   
checkBoxFrameFor: anInteger
		" Private "

    ^[ :box | ( ( box leftTop rightAndDown:  leftTop + ( self horizontalGap @ WindowDialog entryHeight ) )
        right: anInteger - 1 * ( self checkBoxWidth + ( self horizontalGap // 2 ) ) )
            extentFromLeftTop: self checkBoxWidth + ( self horizontalGap // 2 ) @ WindowDialog entryHeight ]!
partPropertySetMenuBarWindows: aBoolean
        " Private - set the menu bar option of the receiver. "

    | partEditor changedRect wrapper labels menuPane undoRedoInfo |

    self partsVwOnly.  " Only used on VW"
    partEditor := self partEditor.

    menuPane := self menuPane.
    aBoolean
        ifTrue: [
            menuWindow notNil
                ifTrue: [^self].
            menuWindow := PARTSMenuBar new
                    parent: self;
                    owner: owner.
            self partApplication
                addComponent: menuWindow
                preferredName: nil
                parent: self
                rectangle: (0 @ 0 extent: 1 @ 1)
                helpInfo: ''
                icon: nil.

            self lafAddEditPane:
                ( menuPane := partEditor windowsWorkbenchMenuBarClass new ).
            menuPane
                buildWindow: self;
                resize: self rectangle;
                validate.
            changedRect := menuPane frameRectangle]
        ifFalse: [
            menuWindow isNil
                ifTrue: [ ^self ].
            wrapper := menuWindow partWrapper.
            wrapper notNil ifTrue: [
                self partApplication removeComponentsOwnedBy: wrapper].
            menuWindow := nil.

            changedRect := menuPane frameRectangle.
            wrapper := menuPane partWrapper.
            wrapper notNil ifTrue: [
                menuPane children notNil ifTrue: [
                    (labels := menuPane children values) size > 0 ifTrue: [
                        ( undoRedoInfo :=
                            self partEditor linkEditor removeLinksAttachedTo: labels ) notNil ifTrue: [
                            self partEditor removedLinks: ( undoRedoInfo at: 3 ) ]]].
                self removeSubpane: menuPane.
                wrapper parent removeComponent: wrapper.
                self owner removeComponentsOwnedBy: wrapper ]].
    self partEditor refreshedRectangle: changedRect.

! 
menuLabelParts
        "Private - answer the receiver's child menu labels in an
        indexed collection in the order that they appear.   Must go
        to the wrapper to find ordering info (?)."
    | wrapper |
    wrapper := self partWrapper.
    wrapper isNil ifTrue: [ self error: 'I need a wrapper for this operation.' ].
    ^wrapper components collect: [ :subwrapper | subwrapper object ]!
partPrintOpenSizePropertiesOn: aStream margin: aString
        " Private - do nothing for a dialog window. "!
partPropertyDefaultBorderStyle
        " Private "
    ^WsSizingBorder! 
initializeOpeningSizeParts
    "Set the value holders that initialize the radio buttons."

    settings at: #openingSize ifAbsent: [
        settings at: #openingSize put: #normal ].
    ( self partNamed: 'NormalHolder' ) setValue:
        ( (settings at: #openingSize) isNil or: [
          (settings at: #openingSize) = #normal ] ).
    ( self partNamed: 'MaximizedHolder' ) setValue:
        ( (settings at: #openingSize) = #maximized ).
    ( self partNamed: 'MinimizedHolder' ) setValue:
        ( (settings at: #openingSize) = #minimized ).!
partFileInUpgradeLoadedWindows: anObjectFiler
        " Private - finish upgrading a window part from PW/Win32 2.0. "

    super partFileInUpgradeLoadedWindows: anObjectFiler.

    " drop properties which are obsolete or shouldn't be filed "
    self
		" obsolete PWO settings installed by PW 2.0 beta source code transfer "
        propertyAt: #PARTSTabStop put: nil;
        propertyAt: #PARTSGroupLeaders put: nil.!   
partDragTargetImport: aDragSession
        "Private - aDragSession has just been dropped on the receiver.
      Answer the part that was placed in the receiver (the copy)."
    | result |

    result := super partDragTargetImport: aDragSession.
    self currentItemIndex: nil.
    ^result!  
addMenuWindowMessageModelsTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    | application messageModel expressionModel menuLabelParts |
    menuWindow isNil
        ifTrue: [
            anExpressionModel addSelector: #noMenuBar.
            ^self ].
    application := self partApplication.
    messageModel := anExpressionModel addSelector: #menuWindow:.
    expressionModel := messageModel newExpressionArgument.
    expressionModel
        setReceiverToSelf;
        addSelector: ( application selectorForComponentBuild: menuWindow )
            with: application.
    menuLabelParts := self menuLabelParts.
    menuLabelParts do: [ :menuLabelPart |
        messageModel := anExpressionModel addSelector: #addMenuLabel:.
        expressionModel := messageModel newExpressionArgument.
        expressionModel
            setReceiverToSelf;
            addSelector: ( application selectorForComponentBuild: menuLabelPart )
                with: application ]
! 
move: anItem toIndex: row
        "Private - Move anItem to row and update the
         receiver."
    | destIndex srcIndex wrapper  anchor components |
    row = 0
        ifTrue: [destIndex := 1]
        ifFalse: [destIndex := row].
    components := self partWrapper components.
    wrapper := self partWrapper findWrapper: anItem.
    srcIndex :=components indexOf: wrapper.
    (srcIndex = destIndex or: [srcIndex = (destIndex - 1)])
        ifTrue: [                         "don't move"
            ^self].
    destIndex > srcIndex
        ifTrue: [                "move down"
            srcIndex = 1
                ifTrue: [anchor := nil]
                ifFalse: [anchor := (components at: srcIndex - 1) object].
            self moveFrom: srcIndex + 1 to: destIndex - 1 after: anchor.
            self position: anItem after: (components at: destIndex - 1) object.
            components replaceFrom: srcIndex
                to: destIndex - 2
                with: components
                startingAt: srcIndex + 1.
            components at: destIndex - 1 put: wrapper]
    ifFalse: [          "move up"
            destIndex = 1
                ifTrue: [anchor := nil]
                ifFalse: [anchor := (components at: destIndex - 1) object].
            self position: anItem after: anchor.
            self moveFrom: destIndex to: srcIndex - 1 after: anItem.
            components replaceFrom: destIndex + 1
                to: srcIndex
                with: components
                startingAt: destIndex.
            components at: destIndex put: wrapper].!
fileInUpgrade: anObjectFiler
        " Upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object. "

    "ensure that PWO 2.0 dialog window has a frame window."
    self partsIfOS2Do: [
        parent isNil ifTrue: [ self initializeFrameWindow ].
        ].
    ^super fileInUpgrade: anObjectFiler!   
partDragTargetOver: aDragSession
        "Private - Draw insertion point as visual feedback."

    self draggingOver: aDragSession.

    super partDragTargetOver: aDragSession!