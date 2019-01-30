3.1.0.106
   
defaultStyle
        "Private - answer the default style for a button list box."
    ^WsVscroll | WsBorder | LbsNointegralheight |
        LbsHasstrings | LbsOwnerdrawfixed | LbsNotify | LbsDisablenoscroll! 
drawItem: aDrawStruct highlight: aBoolean
        "Private - draw the specified item, highlighting if aBoolean
        indicates that the item should be highlighted."
    | item itemBox checkBitmap str itemHeight backColor oldForeColor oldBackColor imageIndex image buttonOffset imageOffset stringOffset font |
    item := self list at: self drawIndex.
    str := self getStringFor: item.
    ( self useImages and: [ self images notEmpty ] )
        ifTrue: [ imageIndex := self images at: self drawIndex ].  "assumes all have images"
    font := self font isNil ifTrue: [ self defaultFont ] ifFalse: [ self font ].
    checkBitmap := self imageForValue: ( self getStateFor: item ).

    itemBox := aDrawStruct boundingBox.

    buttonOffset := 2 @ ( ( itemBox height - checkBitmap height + 1 ) // 2 ).
    imageIndex isNil
        ifTrue: [
            stringOffset := itemBox origin right: ( buttonOffset x * 2 + checkBitmap width ) ]
        ifFalse: [
            image := self class buttonImages at: imageIndex.
            imageOffset := ( buttonOffset x right: checkBitmap width ) + 4 @
                ( ( itemBox height - image height - 2 ) // 2 ).
            stringOffset := ( imageOffset x right: image width + 4 ) @
                ( itemBox top down: ( ( itemBox height - font height + 1 ) // 2 ) ) ].

    itemHeight := self itemHeight.
    aBoolean
        ifTrue: [
            oldBackColor := self graphicsTool backColor.
            oldForeColor := self graphicsTool foreColor.
            self graphicsTool backColor: Color highlightBackground.
            self graphicsTool foreColor: Color highlightText.
            backColor := Color highlightBackground ]
        ifFalse: [ backColor := self backColor isNil ifTrue: [ self defaultBackColor ] ifFalse: [ self backColor ] ].

    self graphicsTool
        fill: aDrawStruct boundingBox color: backColor;
        setTextAlign: TaTop;
        displayText: str at: stringOffset.
    aBoolean ifTrue: [
        self graphicsTool backColor: oldBackColor.
        self graphicsTool foreColor: oldForeColor ].
    self graphicsTool
        copyBitmap: checkBitmap
            from: checkBitmap boundingBox
            at: ( self drawBox origin + buttonOffset ).
    imageIndex notNil ifTrue: [
        self imageList
            display: imageIndex
            at: ( self drawBox origin + imageOffset )
            with: self graphicsTool ]!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
uninitializedValue
        "Private - answer the value which is used to represent the uninitialized state
        (as opposed to nil), for state."
    UninitializedValue isNil ifTrue: [ UninitializedValue := 0 ].
    ^UninitializedValue! 
state
        "Answer the item state of the receiver: false = unchecked, true =
        checked, nil = indeterminate."
    ^state! 
state: trueFalseOrNil
        "Set the item state of the receiver: false = unchecked, true =
        checked, nil = indeterminate."
    state := trueFalseOrNil!   
initialize
		"Private - initialize state."
	self state: self class uninitializedValue!  
isButtonListBoxItem
		"Answer whether the receiver is a kind of ButtonListBoxItem."
	^true! 
image
        "Answer the image for the receiver (an Icon or Bitmap,
        usually 16x16 pixels)."
    ^image!   
image: anImage
        "Set the image for the receiver to anImage (an Icon or Bitmap,
        usually 16x16 pixels)."
    image := anImage!
wmLbuttondown: wparam with: lparam
        "Private - process clicks within item buttons."
    | aPoint |
    aPoint := ( WinPoint fromInteger: lparam ) asPoint.
    self testButtonClick: aPoint.
    ^super wmLbuttondown: wparam with: lparam!   
loadButtonImages
        "Private - load system defined button images into an Array, to be used for
        drawing items."
    | bmp buttonBitmap images cx cy |
    bmp := Bitmap fromModule: nil id: ObmCheckboxes.
    cx := bmp width // 4.
    cy := bmp height // 3.
    images := Array new: 12.
    1 to: 3 do: [ :y |
        1 to: 4 do: [ :x |
            buttonBitmap := Bitmap
                fromHandle: bmp handle
                offset: ( ( x - 1 ) * cx ) @ ( ( y - 1 ) * cy )
                extent: cx @ cy.
            images at: y - 1 * 4 + x put: buttonBitmap ] ].
    bmp release.
    images := ( Array new: 5 )
        at: 1 put: ( images at: 1 );  "unchecked"
        at: 2 put: ( images at: 2 );  "checked"
        at: 3 put: ( images at: 10 );  "indeterminate"
        at: 4 put: ( images at: 5 );  "unselected radio"
        at: 5 put: ( images at: 6 );  "selected radio"
        yourself.
    ^images
!
setImageLists
        "Private - set the image list for the receiver, if required."
        "also sets item states from adaptor, if present."
    | imageIndices image imageIndex object |
    self images: Array new.
    self useImages ifFalse: [ ^self ].

    self images: OrderedCollection new.
    imageIndices := Array new: self listAttribute size.
    1 to: self listAttribute size do: [ :itemIndex |
        object := self listAttribute at: itemIndex.
        ( image := self getImageFor: object ) notNil ifTrue: [
            ( imageIndex := self images indexOf: image ) ~= 0
                ifTrue: [ imageIndices at: itemIndex put: imageIndex ]
                ifFalse: [
                    self images add: image.
                    imageIndices at: itemIndex put: self images size ] ] ].

    self images isEmpty ifTrue: [ ^self ].
    self imageList: ( ImageList fromImages: self images ).
    self images: imageIndices!  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #needsStringFor: ;
        add: #needsImageFor: ;
        add: #needsStateFor: ;

        add: #checked: ;
        add: #checkedIndex: ;
        add: #unchecked: ;
        add: #uncheckedIndex: ;
        add: #indeterminate: ;
        add: #indeterminateIndex: ;
        remove: #drawItem: ;
        remove: #drawFocus: ;
        remove: #drawSelection: ;
        remove: #measureItem: ;
        yourself!
buttonImagesAttribute
        "Private - answer the ButtonImages class variable."
    ^ButtonImages!
buttonImages
        "Private - answer an Array containing the system defined button images, loading
        if necessary."
    ButtonImages isNil ifTrue: [ ButtonImages := self loadButtonImages ].
    ^ButtonImages!  
initialize
        "Private - reinitialize the receiver class."
    ButtonExtent := nil.
    ButtonImages := nil!  
unbound
		"Private - when uninstalled, unregister for interest in #aboutToSaveImage event."
    SessionModel current
        removeActionsWithReceiver: self forEvent: #aboutToSaveImage!  
bound
		"Private - when installed, register for interest in #aboutToSaveImage event."
    SessionModel current
        when: #aboutToSaveImage send: #aboutToSaveImage to: self!   
buttonExtent
        "Private - answer the extent (a Point) of each system defined button image."
    ButtonExtent isNil ifTrue: [ ButtonExtent := self buttonImages first extent ].
    ^ButtonExtent!
aboutToSaveImage
        "Private - when the image is saved, release and clear
        the list of button images, so that they are recreated
        appropriately depending on what OS is running."
	self buttonImagesAttribute notNil ifTrue: [
		self buttonImagesAttribute do: [ :image | image release ].
		self initialize ]! 
updateIndex: anInteger
        "Private - redraw the item corresponding to index anInteger."
    self invalidateRect: ( self lineToRect: anInteger )!   
getImageFor: aButtonListBoxItem
        "Private - answer the image for aButtonListBoxItem,
        retrieving via the #needsImageFor: event if necessary."
    | image |
    aButtonListBoxItem image notNil ifTrue: [ ^aButtonListBoxItem image ].
    image := self
        triggerEvent: #needsImageFor:
        withArguments: ( Array with: aButtonListBoxItem object )
        ifNotHandled: [ nil ].
    aButtonListBoxItem image: image.
    ^image!   
getStateFor: aButtonListBoxItem
        "Private - answer the item state for aButtonListBoxItem,
        retrieving via the #needsStateFor: event if necessary."
    | state |
    aButtonListBoxItem state ~~ ButtonListBoxItem uninitializedValue
        ifTrue: [ ^aButtonListBoxItem state ].
    state := self
        triggerEvent: #needsStateFor:
        withArguments: ( Array with: aButtonListBoxItem object )
        ifNotHandled: [ false ].
    aButtonListBoxItem state: state.
    ^state!  
contents: aCollection
        "Set the receiver's contents to aCollection."
    | items |
    self contents = aCollection ifFalse: [ self releaseImageList ].
    Process enableInterrupts: false.
    items := aCollection isNil
        ifTrue: [ aCollection ]
        ifFalse: [ aCollection collect: [ :o |
            o isButtonListBoxItem
                ifTrue: [ o ]
                ifFalse: [ ButtonListBoxItem new object: o; state: false ] ] ].
    super contents: items.
    Process enableInterrupts: true!   
buttonRectangleForIndex: itemIndex
        "Private - Answer a Rectangle that surrounds the
        item in the list indexed by itemIndex."
    | itemRectangle offset buttonExtent rect |
    itemRectangle := self lineToRect: itemIndex.
    buttonExtent := self class buttonExtent.
    offset := 2 @ ( ( self itemHeight - buttonExtent y + 1 ) // 2 ).
    ^Rectangle
        leftTop: ( itemRectangle leftTop rightAndDown: offset )
        extent: buttonExtent!   
triggerCheckedEvents: index value: aValue
        "Private - trigger the check state change events for the given index
        and check state value."
    | indexEvent itemEvent |
    aValue == true ifTrue: [
        indexEvent := #checkedIndex: .
        itemEvent := #checked: ].
    aValue == false ifTrue: [
        indexEvent := #uncheckedIndex: .
        itemEvent := #unchecked: ].
    aValue isNil ifTrue: [
        indexEvent := #indeterminateIndex: .
        itemEvent := #indeterminate: ].
    self triggerEvent: indexEvent with: index.
    self triggerEvent: itemEvent with: ( self stringForItem: ( self list at: index ) )! 
images: aCollection
        "Private - set the collection of image indices to aCollection."
    images := aCollection!  
checkIndex: anInteger
        "Set the state of the item indexed by anInteger to checked, and redraw the item."
    ( self listAttribute at: anInteger ) state: true.
    self isHandleOk ifTrue: [ self updateIndex: anInteger ]! 
drawItem: aDrawStruct
        "Private - draw the specified item."
    self drawItem: aDrawStruct highlight: false! 
getStringFor: aButtonListBoxItem
        "Private - answer the string for aButtonListBoxItem,
        retrieving via the #needsStringFor: event if necessary."
    | string |
    aButtonListBoxItem string notNil ifTrue: [ ^aButtonListBoxItem string ].
    string := self
        triggerEvent: #needsStringFor:
        withArguments: ( Array with: aButtonListBoxItem object )
        ifNotHandled: [ aButtonListBoxItem object asString ].
    aButtonListBoxItem string: string.
    ^string! 
imageList: anImageList
        "Private - set the image list to anImageList."
    imageList := anImageList! 
images
        "Private - answer the collection of image indices."
    ^images! 
isThreeState
        "Private - answer whether the receiver is of three state style (default is false)."
    ^self propertyAt: #threeState ifAbsent: [ false ]! 
drawHighlight: aDrawStruct
        "Private - highlight the specified item."
    self drawItem: aDrawStruct highlight: true!
indeterminateIndex: anInteger
        "Set the state of the item indexed by anInteger to indeterminate, and redraw the item."
    ( self listAttribute at: anInteger ) state: nil.
    self isHandleOk ifTrue: [ self updateIndex: anInteger ]!
imageList
        "Private - answer the image list."
    ^imageList!
font: aFont
		"Set the font for the receiver to aFont.  Override the
		superclass implementation to cause a font change after
		the host window was created to update the item height."
    | oldFont |
	oldFont := self font.
	self itemHeight: nil.
	super font: aFont.
	( self isHandleOk and: [ oldFont ~~ aFont ] ) ifTrue: [ self recreateWindow ]! 
uncheckIndex: anInteger
        "Set the state of the item indexed by anInteger to unchecked, and redraw the item."
    ( self listAttribute at: anInteger ) state: false.
    self isHandleOk ifTrue: [ self updateIndex: anInteger ]!
releaseImageList
		"Private - release the receiver's image list."
	self imageList notNil ifTrue: [ self imageList release ]!
threeState
        "Set whether the receiver is a three-state style button
        list box (default is false)."
    self threeState: true!
uncheckItem: anObject
        "Set the state of the item anObject to unchecked, and redraw the item."
    self uncheckIndex: ( self indexOf: anObject )!
toggleState: itemIndex
        "Private - toggle the check state of the item with the given index."
    | currentValue |
    currentValue := ( self listAttribute at: itemIndex ) state.
    currentValue := self isThreeState
        ifFalse: [ currentValue == false ]
        ifTrue: [ currentValue == true ifTrue: [ nil ] ifFalse: [ currentValue notNil ] ].
    ( self listAttribute at: itemIndex ) state: currentValue.
    self invalidateRect: ( self buttonRectangleForIndex: itemIndex ).
    self triggerCheckedEvents: itemIndex value: currentValue!   
useImages
        "Answer whether any specified images in the list contents are to be used
        in displaying the list items (default is true if images have been supplied)."
    ^self propertyAt: #useImages ifAbsent: [ true ]!  
useImages: aBoolean
        "Determinate whether any specified images in the list contents are to be used
        in displaying the list items (default is true if images have been supplied)."
    self useImages = aBoolean ifTrue: [ ^self ].
    self propertyAt: #useImages put: aBoolean.
    self isHandleOk ifTrue: [ self releaseImageList; recreateWindow ]!   
validate
        "Private - The host window for the receiver was
        just created or recreated."
    self setImageLists.
    super validate!  
indeterminateItem: anObject
        "Set the state of the item anObject to indeterminate, and redraw the item."
    self indeterminateIndex: ( self indexOf: anObject )!
checkItem: anObject
        "Set the state of the item anObject to checked, and redraw the item."
    self checkIndex: ( self indexOf: anObject )!  
threeState: aBoolean
        "Set whether the receiver is a three-state style button
        list box (default is false)."
    self isThreeState = aBoolean ifTrue: [ ^self ].
    self propertyAt: #threeState put: aBoolean!
imageIndexForValue: aValue
        "Private - answer the index of the button image corresponding to aValue in the
        button images array."
    aValue == true ifTrue: [ ^2 ].
    aValue isNil ifTrue: [ ^3 ].
    ^1!  
close
		"Private - release the image list before closing the receiver."
	self releaseImageList.
	super close!  
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process space bar as check state change."
    aKeyboardInputEvent character = $ 
        ifTrue: [ self toggleState: self selectedIndex ].
    ^super keyboardInput: aKeyboardInputEvent! 
testButtonClick: aPoint
        "Private - check to see if aPoint is inside an item checkbox; if so, update the
        item's (check) state, redraw it, and trigger check state change events."
    | itemIndex buttonRectangle |
    itemIndex := self itemIndexFromPoint: aPoint.
    buttonRectangle := self buttonRectangleForIndex: itemIndex.
    ( buttonRectangle containsPoint: aPoint )
        ifTrue: [ self toggleState: itemIndex ]!
imageForValue: aValue
        "Private - answer the button image that is used to draw the value aValue."
    ^self class buttonImages at: ( self imageIndexForValue: aValue )!  
isButtonListBoxItem
		"Answer whether the receiver is a kind of ButtonListBoxItem."
	^false!