"3.0.0.12"
! 

WBObject subclass: #WBTool
  instanceVariableNames: 
    ' file bitmap pen bitmapSelector selector rbSelector state numSpaces rectangle boundingBox enableSelector owner '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '!  

SubPane subclass: #WBToolPalette
  instanceVariableNames: 
    ' selection size cellSize tpStyle elements cacheRedraw cachedElements useSystem '
  classVariableNames: 
    ' AutoScale '
  poolDictionaries: 
    ' OperatingSystemConstants '!  

WBToolPalette subclass: #WBToolBar
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

!WBTool methods ! 
owner

    ^owner! !

!WBToolPalette methods !
ownerAt: key
		"Returns the owner of the button with the index aKey."
    | element |
    (self validSelection: key) ifFalse: [^nil].
    ^((element := self elementAt: key) isNil
            ifTrue: [nil]
            ifFalse: [element owner]) ifNil: [self owner].! !

!WBToolPalette methods !  
preAutomatic
		"Set the postAutomatic style.
			This will cause the buttons to return to their unpressed
			states before the action they initiate takes place."
    tpStyle := #preAutomatic! !

!WBToolPalette methods !  
cacheRedrawOn
		"Private"
    self cacheRedraw: true.! !

!WBTool methods !   
isDisabled

    ^self state == #disabled! !

!WBToolPalette methods ! 
updateEnabled

	| changedElements |
	changedElements := self elements select: [:each |
		each updateEnabled].
	changedElements do: [:each |
		self displayKey: each selector].! !

!WBToolPalette methods !   
resizeWindow
        "The window has changed size, so invalidate the element rectangles."
    super resizeWindow.
    self elements do: [ :elem | elem rectangle: nil ].! !

!WBTool methods !   
up

    self state: #up! !

!WBToolBar methods !  
add: aBitmapOrSelector rbSelector: rbSelector
		"Add a button to the toolbar.
			Its right button selector is rbSelector."
    ^self
		add: (aBitmapOrSelector isBitmap ifTrue: [ aBitmapOrSelector ] ifFalse: [ nil ])
		selector: (aBitmapOrSelector isBitmap ifTrue: [ nil ] ifFalse: [ aBitmapOrSelector ])
		rbSelector: rbSelector! !

!WBTool methods !
printOn: aStream

    super printOn: aStream.
    aStream nextPut: $>; nextPutAll: self selector asString! !

!WBToolPalette methods !   
tpStyle: aSymbol
        "Private"
    tpStyle := aSymbol! !

!WBToolBar methods !
isMDISupportPane
        "Answer true if receiver is a support pane for MDI."
    ^self tpStyle == #mdiToolBar! !

!WBToolBar methods !   
disableElements
		"Disable all of the buttons."
    1 to: self elements size do: [ :key |
        self disable: key ].! !

!WBToolPalette class methods !
supportedEvents

    ^super supportedEvents
        add: #select;
        add: #selecting;
        add: #doubleClick;
        add: #gettingFocus;
        add: #showHelp;
        yourself! !

!WBTool methods !
boundingBox

    boundingBox ifNil: [
        boundingBox := IdentityDictionary new.
        boundingBox
            at: #up put: self upBoundingBox;
            at: #down put: self downBoundingBox;
            at: #disabled put: self disabledBoundingBox.
    ].
    ^boundingBox at: self state ifAbsent: [ 0@0 extent: 0@0 ].! !

!WBTool methods !
isEnabled

    ^self isDisabled not! !

!WBToolPalette methods !  
enable: key
		"Private"
    | element |
    (element := self elementAt: key) isNil ifFalse: [
        element isEnabled ifFalse: [
            element up.
            self handle isValid ifTrue: [ self displayKey: key ]
        ]
    ].! !

!WBToolPalette methods !   
enable
        "Enable the receiver and all its children."
    super enable.
    self enableElements.! !

!WBToolBar methods !   
rbEventFor: key
		"Private"
    | selector |

    selector := self rbSelectorAt: key.

    (selector notNil and: [ selector isSymbol ])
        ifTrue: [
            (self owner class canUnderstand: selector)
                ifTrue: [
                    (selector includes: $:)
                        ifTrue: [self owner perform: selector with: self]
                        ifFalse: [self owner perform: selector]]].! !

!WBTool methods !   
selector: aSymbol

    selector := aSymbol.
    bitmapSelector ifNil: [ bitmapSelector := selector ].! !

!WBTool methods !  
pen: aPen

    pen := aPen! !

!WBTool methods !  
boundingBox: aRectangle

    boundingBox := aRectangle! !

!WBToolBar methods !   
add: aBitmapOrSelector spaces: numSpaces rbSelector: rbSelector
		"Add a button to the toolbar.
			It will be numSpaces from its neighbor
			and its right button selector is rbSelector."
    ^self
		add: (aBitmapOrSelector isBitmap ifTrue: [ aBitmapOrSelector ] ifFalse: [ nil ])
		selector: (aBitmapOrSelector isBitmap ifTrue: [ nil ] ifFalse: [ aBitmapOrSelector ])
		spaces: numSpaces
		rbSelector: rbSelector! !

!WBToolBar methods !   
elementAt: key
		"Private"
    ^(key isInteger and: [ key > 0 and: [ key <= self elements size ]])
        ifTrue: [ self elements at: key ]
        ifFalse: [ nil ]! !

!WBToolBar methods !  
add: aBitmapOrSelector selector: aSelector enable: enableSelector owner: anObject spaces: numSpaces
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its enable selector is enableSelector
			Its owner is anObject
			It will be numSpaces from its neighbor."

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: enableSelector 
		owner: anObject 
		spaces: numSpaces 
		rbSelector: nil! !

!WBToolPalette methods ! 
elements
		"Private"
    ^elements! !

!WBToolPalette methods !   
elements: aCollection
		"Private"
    elements := aCollection! !

!WBToolPalette class methods !  
isWBInternalClass

    ^true! !

!WBToolBar methods ! 
add: aBitmapOrSelector
		"Add a button to the toolbar.
			It will not have a right button selector."
    self add: aBitmapOrSelector spaces: 0! !

!WBToolPalette methods !  
collectionType
		"Private - Answer the collection class used to hold the receiver's elements."
    ^Dictionary! !

!WBTool methods !  
rbSelector: aSymbol

    rbSelector := aSymbol! !

!WBToolPalette methods !   
whenX: anEvent perform: aMessage
        "Private - Obsolete??
         Notify the owner whenever anEvent occurs by
         performing aMessage.  For compatibility,
         aMessage can be a one argument selector."
    | m |
	#obsoleteMethod.
	"Is this an obsolete method?"
    m := aMessage.
    "aMessage isSymbol ifTrue: [m := Message new
        receiver: (self owner notNil ifTrue: [self owner]
            ifFalse: [self sender])
        selector: aMessage
        arguments: (Array with: self)]."
    handlers at: anEvent put: m.! !

!WBToolPalette methods !   
selector
		"Returns the left button selector of the selected button."
    ^self selectorAt: selection! !

!WBToolPalette methods !
defaultBackColor

    ^Color buttonFace! !

!WBToolPalette methods !  
bitmapFileAt: key
		"Private"
    | element |
    (self validSelection: key) ifFalse: [ ^nil ].

    ^(element := self elementAt: key) isNil
            ifTrue: [ nil ]
            ifFalse: [ element file ]! !

!WBToolPalette methods !  
cellHeight
		"Answer the height of the buttons."
    ^self cellSize y! !

!WBToolPalette methods !
isEnabled: key
        "Private"
    | element |
    ^(element := self elementAt: key) isNil
            ifTrue: [ false ]
            ifFalse: [ element isEnabled ]! !

!WBToolBar methods ! 
isPreAutomatic
		"Private"
    ^super isPreAutomatic or: [ tpStyle = #mdiToolBar ]! !

!WBToolPalette methods !   
cellSize: aPoint
		"Set the size of the buttons."
    cellSize := aPoint! !

!WBToolBar methods ! 
enableElements
		"Enable all of the buttons."
    1 to: self elements size do: [ :key |
        self enable: key ].! !

!WBToolPalette methods ! 
currentIndex
		"Return the number of the button currently touched by the mouse.
			The buttons are number from left to right starting at one."
    | point |
    point := Cursor offset mapToWindow: self.
    point := self leftTop distanceRightAndDown: point.
    ^(point x // self cellWidth + 1)
        @ (point y // self cellHeight + 1)! !

!WBTool methods !  
rectangle: aRectangle

    rectangle := aRectangle! !

!WBToolPalette methods !   
at: key selector: aSelector
		"Private - Obsolete"
	#obsoleteMethod.
    ^self at: key put: nil selector: aSelector! !

!WBToolBar methods ! 
freeClientArea: box
    "Private - Set the client area left over."
    self tpStyle == #mdiToolBar ifFalse: [ ^self ].
    self visible ifFalse: [ ^self ].
    box leftTop: (self isVertical
        ifTrue: [ box leftTop rightAndDown: (self cellSize x @ 0) ]
        ifFalse: [ box leftTop rightAndDown: (0 @ self cellSize y) ]).
! !

!WBToolBar methods !   
add: aBitmapOrSelector selector: aSelector owner: anObject spaces: numSpaces rbSelector: rbSelector
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its owner is anObject
			It will be numSpaces from its neighbor.
			and its right button selector is rbSelector"

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: nil 
		owner: anObject 
		spaces: numSpaces 
		rbSelector: rbSelector! !

!WBTool methods !  
upBoundingBox

    ^(0 @ 0 extent: (self bitmap width // self numImages @ self bitmap height))! !

!WBToolBar methods !   
affectsFreeClientArea
    "Private - Answer whether the receiver reduces the amount of
    free client area in its parent for the receiver's siblings."

	^self isMDISupportPane! !

!WBToolBar methods !   
add: aBitmapOrSelector selector: aSelector
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			It will not have a right button selector."
    self add: aBitmapOrSelector selector: aSelector spaces: 0! !

!WBToolPalette methods !   
isAutomatic
        "Private"
    ^(self isPostAutomatic) | (self isPreAutomatic)! !

!WBToolBar methods !
elementAtSelector: aSelector
		"Private"
    ^(1 to: self elements size) detect: [ :key |
        (self selectorAt: key) = aSelector ] ifNone: [ nil ]! !

!WBToolPalette class methods !
autoScale: aBoolean

    AutoScale := aBoolean! !

!WBToolPalette methods !   
cellWidth
		"Answer the width of the buttons."
    ^self cellSize x! !

!WBToolBar methods !  
add: aBitmapOrSelector selector: aSelector spaces: numSpaces rbSelector: rbSelector
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			It will be numSpaces from its neighbor
			and its right button selector is rbSelector."

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: nil
		owner: self owner
		spaces: numSpaces
		rbSelector: rbSelector! !

!WBToolPalette methods !  
initialize
		"Private"
	super initialize.
	self elements: self newPage.
	self backColor: self defaultBackColor.! !

!WBToolPalette class methods !  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #clicked:;
        add: #selecting:;
        add: #doubleClick:;
        add: #showHelp:;
        yourself! !

!WBTool methods ! 
enableSelector

    ^enableSelector! !

!WBToolPalette methods !  
toggle
		"Set the toggle style.
			This will cause the buttons to remain pressed
			until another one is pressed."
    tpStyle := #toggle! !

!WBToolBar methods !  
add: aBitmapOrSelector selector: aSelector rbSelector: rbSelector
		"Add a button to the toolbar.
			Its right button selector is rbSelector."
    ^self
		add: aBitmapOrSelector
		selector: aSelector
		spaces: 0
		rbSelector: rbSelector! !

!WBToolPalette methods !
defaultSelection
		"Private"
    ^1@1! !

!WBTool methods !   
pen

    ^pen ifNil: [ pen := self bitmap pen ].! !

!WBToolPalette methods ! 
button1Down: aPoint
        "Private - left button was pressed"
    | index |

    ( self isLocalDragSource and: [ self isDragButton: 1 ] )
        ifTrue: [ self dragOnMove: true location: aPoint ].

    index := self highlight: selection.
    self event: #gettingFocus.

    self captureMouseInput.
    Notifier consumeInputUntil: [:event |
        index := self highlight: index.
        #osiHack.
        "Code for drag/drop from tool bar."
        event selector = #button1Move: ifTrue: [
            ( self isLocalDragSource
                and: [ self dragOnMove
                    and: [ self isDragSourceInitiation: event arguments first ] ] )
                        ifTrue: [
                            "self clearMouseCapture."
                            self unHighlightBitmap: index.
                            ^self ] ].
        (event notNil and: [ event selector == #button1Up: ])
    ].
    self clearMouseCapture.

    (self isEnabled: index) ifTrue: [
        selection := index.
        self isPreAutomatic ifTrue: [self unHighlightBitmap: selection].
        self generateEventFor: selection.
        self eventFor: selection.
        self event: #select. "Obsolete"
        self triggerEvent: #clicked: with: self selector.
        self isPostAutomatic ifTrue: [self unHighlightBitmap: selection].
        self isAutomatic ifTrue: [ selection := nil ].
    ] ifFalse: [
        self highlightBitmap: selection.
    ].! !

!WBToolPalette methods ! 
creationCellSize

    ^self propertyAt: #creationCellSize ifAbsent: [self cellSize]! !

!WBTool methods ! 
down

    self state: #down! !

!WBToolPalette methods !  
toggleWhite
        "Private"
    tpStyle := #toggleWhite! !

!WBTool methods !   
releaseBitmaps

    self file isEmpty ifFalse: [
        self bitmap release.
        self bitmap: nil
    ].! !

!WBToolPalette methods ! 
width
        "Answer the receiver's width."
    ^self size x! !

!WBTool methods !   
disabledBoundingBox

    ^self upBoundingBox! !

!WBTool methods !
state

    ^state! !

!WBToolPalette methods !
elementAtSelector: aSelector
		"Private"
    ^self elements keys detect: [ :key |
        (self selectorAt: key) = aSelector ] ifNone: [ nil ]! !

!WBToolPalette methods !  
enableItem: aSelector
		"Enable the button with the left button selector aSelector."
    self enable: (self elementAtSelector: aSelector)! !

!WBToolPalette methods !
releaseBitmaps
        "Private - Release all bitmaps."

    self elements do: [ :element | element isNil ifFalse: [ element releaseBitmaps ]].
    self elements: nil.! !

!WBTool methods !   
bitmap

    ^bitmap! !

!WBToolPalette methods !  
add: aBitmapOrSelector selector: aSelector
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			It will not have a right button selector."
    | key point |
    key := self elements size + 1.
    point := ((key - 1)\\(self size x)+1) @ ((key + (self size x - 1))//(self size x )).
    ^self at: point put: aBitmapOrSelector selector: aSelector.! !

!WBToolPalette methods !
close
        "Private - Close the receiver."
    self releaseBitmaps.
    ^super close! !

!WBToolPalette methods ! 
height
	    "Answer the receiver's height."
    ^self size y! !

!WBToolPalette methods ! 
postAutomatic
		"Set the postAutomatic style.
			This will cause the buttons to remain pressed
			until the action they initiate finishes."
    tpStyle := #postAutomatic! !

!WBTool methods ! 
enableSelector: aSymbol

    enableSelector := aSymbol! !

!WBToolBar methods !   
currentIndex
		"Return the number of the button currently touched by the mouse.
			The buttons are number from left to right starting at one."
    | point |
    point := Cursor offset mapToWindow: self.
    1 to: self elements size do: [ :i |
        (((self elementAt: i) rectangle ifNil: [^nil]) containsPoint: point)
            ifTrue: [ ^i ]].
    ^nil.! !

!WBToolPalette methods ! 
cachedElements: aCollection
		"Private"
    cachedElements := aCollection! !

!WBToolBar methods !
updateEnabled: key

	| element |
	element := (self elements ifNil: [^self])
		detect: [:each | each notNil and: [each selector == key]]
		ifNone: [^nil].
	element updateEnabled.
	self displayKey: (self elements indexOf: element).! !

!WBToolPalette methods !   
cacheRedraw
		"Private"
    ^cacheRedraw ifNil: [ cacheRedraw := false ].! !

!WBToolPalette methods !
stateAt: key put: aSymbol
        "Private"
    | element |
    (element := self elementAt: key) isNil ifFalse: [
        element state: aSymbol.
    ].! !

!WBToolBar methods !  
rbSelectorAt: key
		"Returns the right button selector of the button with the index aKey."
    | element |
    (self validSelection: key) ifFalse: [ ^nil ].

    ^(element := self elementAt: key) isNil
            ifTrue: [ nil ]
            ifFalse: [ element rbSelector ]! !

!WBToolPalette methods !   
restoreAllBitmaps

    self elements do: [:tool |
        tool bitmap handle].! !

!WBToolBar methods !  
display
        "Private - The receiver should display its contents."
    self pen blank: self rectangle.
    1 to: self elements size do: [ :i | self displayKey: i ]! !

!WBTool methods ! 
owner: anObject

    owner := anObject! !

!WBToolPalette methods !   
highlightBitmap: key
        "Private"
    | element |
    element := self elementAt: key.
    (element isNil or: [ element isDisabled ]) ifTrue: [ ^nil ].
    element down.
    self displayKey: key.! !

!WBToolBar methods !  
collectionType
		"Private - Answer the collection class used to hold the receiver's elements."
    ^OrderedCollection! !

!WBToolPalette methods !
cellSize
		"Answer the size of the buttons."
    ^cellSize ifNil: [ cellSize := self defaultCellSize ].! !

!WBToolPalette methods !  
selectorAt: key
		"Returns the left button selector of the button with the index aKey."
    | element |
    (self validSelection: key) ifFalse: [ ^nil ].

    ^(element := self elementAt: key) isNil
            ifTrue: [ nil ]
            ifFalse: [ element selector ]! !

!WBToolPalette methods !
unHighlightBitmap: key
        "Private"
    | element |
    element := self elementAt: key.
    (element isNil or: [ element isDisabled ]) ifTrue: [ ^nil ].
    element up.
    self displayKey: key.! !

!WBTool methods ! 
bitmap: aBitmap

    bitmap := aBitmap! !

!WBToolPalette methods !   
button1DoubleClick: aPane
        "Private - The user double clicked button 1 at aPoint."
    self event: #doubleClick. "Obsolete"
    self triggerEvent: #doubleClick: with: self selector! !

!WBToolPalette methods ! 
scrollHorizontal: anInteger
        "Private - Scroll the pane left by anInteger
         number of pixels (if positive) or right by
         the absolute value of anInteger (if negative)."! !

!WBTool methods !  
numSpaces: anInteger

    numSpaces := anInteger! !

!WBToolBar methods ! 
add: aBitmapOrSelector spaces: numSpaces
		"Add a button to the toolbar.
			It will be numSpaces from its neighbor.
			It will have no right button selector."
    ^self
		add: (aBitmapOrSelector isBitmap ifTrue: [ aBitmapOrSelector ] ifFalse: [ nil ])
		selector: (aBitmapOrSelector isBitmap ifTrue: [ nil ] ifFalse: [ aBitmapOrSelector ])
		spaces: numSpaces! !

!WBToolPalette methods ! 
add: aSelector
		"Add a button to the toolbar.
			It will not have a right button selector."
    ^self add: nil selector: aSelector! !

!WBToolPalette methods ! 
validSelection: key
		"Private"
    ^(self elementAt: key) notNil! !

!WBToolPalette methods !
buttonFrom: anBitmapFile size: aPoint
		"Private"
    | aBitmap |
    anBitmapFile isNil
        ifTrue: [
            aBitmap := WBBitmapClass extent: aPoint.
            aBitmap pen centerText: '?' at: aBitmap boundingBox center.
            ^aBitmap ].
    ^((anBitmapFile includes: $*) not and: [File exists: anBitmapFile])
        ifTrue: [ WBBitmapClass fromFile: anBitmapFile ]
        ifFalse: [
            aBitmap := WBBitmapClass screenExtent: aPoint.
            aBitmap pen
                draw3DButton: (self justFileName: anBitmapFile)
                rect: aBitmap boundingBox
                font: self font.
            aBitmap]! !

!WBToolPalette methods ! 
disableItem: aSelector
		"Disable the button with the left button selector aSelector."
    self disable: (self elementAtSelector: aSelector)! !

!WBToolPalette methods ! 
drawDisabledWith: aPen in: aRect
        "Private"
    | d |
    d := 2 @ (2 + Rectangle rightBottomUnit y).
    aPen
        setLineWidth: 1;
        foreColor: Color gray;
        backColor: Color gray;
        drawRectangle: (aRect insetBy: 1);
        lineFrom: (aRect leftBottom rightAndUp: d) to: (aRect rightBottom leftAndUp: d);
        lineFrom: (aRect rightTop leftAndDown: 3@2) to: (aRect rightBottom leftAndUp: 3@2).
! !

!WBToolBar methods !   
add: aBitmapOrSelector selector: aSelector spaces: numSpaces
		"Add a button to the toolbar.
			It will be numSpaces from its neighbor.
			It will have no right button selector."
    ^self add: aBitmapOrSelector selector: aSelector spaces: numSpaces rbSelector: nil! !

!WBToolPalette methods !  
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsChild | WsVisible! !

!WBToolPalette methods !   
at: key put: bitmapSelector
		"Private - Obsolete."
	#obsoleteMethod.
    ^self at: key put: bitmapSelector selector: nil! !

!WBToolBar methods !   
isVertical

    ^(self propertyAt: #vertical) == true
! !

!WBToolBar methods !  
add: aBitmapOrSelector selector: aSelector enable: enableSelector owner: anObject
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its enable selector is enableSelector
			Its owner is anObject"

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: enableSelector 
		owner: anObject 
		spaces: 0 
		rbSelector: nil! !

!WBToolBar methods !   
mdiToolBar

    tpStyle := #mdiToolBar.
    self framingBlock: (self isVertical
        ifTrue:[ [:box | Rectangle leftTopUnit rightBottom: (self cellSize x @ box height) ] ]
        ifFalse: [ [:box | Rectangle leftTopUnit rightBottom: (box width @ self cellSize y) ] ]).
! !

!WBToolPalette methods !
disable
        "Disable the receiver and all its children.
         A disabled window does not receive user input."
    super disable.
    self disableElements.! !

!WBToolPalette methods !  
justFileName: fileName
        "Private"
    ^((File splitPath: fileName in: Disk) at: 3) upTo: $.! !

!WBToolBar methods !   
add: aBitmapOrSelector selector: aSelector enable: enableSelector
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its enable selector is enableSelector"

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: enableSelector 
		owner: self owner 
		spaces: 0 
		rbSelector: nil! !

!WBToolPalette methods !   
newPage
        "Private"
    ^self collectionType new! !

!WBToolBar methods !   
vertical

    self propertyAt: #vertical put: true.
! !

!WBToolPalette class methods !  
autoScale

    ^AutoScale ifNil: [AutoScale := true]! !

!WBToolPalette methods ! 
size
        "Private"
    size isNil ifTrue: [ size := 0@0 ].
    ^size! !

!WBTool methods !   
downBoundingBox

    ^((self bitmap width // self numImages) @ 0 extent: (self bitmap width // self numImages @ self bitmap height))! !

!WBTool methods !
state: aSymbol

    state := aSymbol! !

!WBTool methods !
selector

    ^selector! !

!WBTool methods ! 
file

    ^file ifNil: [ file := '' ]! !

!WBToolBar methods !
defaultCellSize
		"Private"
    ^25@22! !

!WBToolPalette methods !   
eventFor: key
        "Private"
    | selector theOwner |

    selector := self selectorAt: key.
    theOwner := self ownerAt: key.
    (selector notNil and: [ selector isSymbol ])
        ifTrue: [
            (theOwner class canUnderstand: selector)
                ifTrue: [
                    (selector includes: $:)
                        ifTrue: [theOwner perform: selector with: self]
                        ifFalse: [theOwner perform: selector]]].! !

!WBToolPalette methods ! 
updateSliders
        "Private - Update the slider boxes in the scrollbars."! !

!WBToolPalette methods !  
tpStyle
        "Private"
    ^tpStyle! !

!WBToolPalette methods !   
displayKey: key
        "Private"
    self cacheRedraw ifTrue: [
        self cachedElements add: key
    ] ifFalse: [
        self displayBitmap: key
    ].! !

!WBTool methods !   
bitmapSelector

    ^bitmapSelector! !

!WBTool methods ! 
updateEnabled

	^self owner notNil & self enableSelector isSymbol
		ifTrue: [
			(self owner perform: self enableSelector)
				ifTrue: [
					self isDisabled
						ifTrue: [self up. true]
						ifFalse: [false]]
				ifFalse: [
					self isDisabled
						ifTrue: [false]
						ifFalse: [self disabled. true]]]
		ifFalse: [false].! !

!WBToolPalette methods !  
displayBitmap: key
        "Private - Display the specified bitmap."
    | element rect |

    element := self elementAt: key.
    element isNil ifTrue: [ ^nil ].

    self doGraphics: [
        self pen
            copy: element pen
            from: element boundingBox
            to: (rect := self rectForKey: key).
        element isDisabled ifTrue: [ self drawDisabledWith: self pen in: rect ].
    ].! !

!WBToolPalette methods !   
mouseMove: aPoint
    "Moved the pointer."

    | index lastIndex |
    index := self currentIndex.
    lastIndex := self propertyAt: #lastIndex.
    lastIndex = index ifFalse: [
        self propertyAt: #lastIndex put: index.
        self event: #showHelp. "Obsolete"
        self triggerEvent: #showHelp: with: (self selectorAt: index)].! !

!WBToolPalette methods !   
cacheRedrawOff
		"Private"
    self cacheRedraw: false.
    self cachedElements do: [ :element |
        self displayKey: element
    ].
    self cachedElements: nil.! !

!WBToolBar methods !   
defaultSelection
		"Private"
    ^1! !

!WBToolPalette methods !  
isPreAutomatic
        "Private"
    ^tpStyle = #preAutomatic! !

!WBToolPalette methods !
disable: key
		"Private"
    | element |
    (element := self elementAt: key) isNil ifFalse: [
        element isEnabled ifTrue: [
            element disabled.
            self handle isValid ifTrue: [ self displayKey: key ]
        ]
    ].! !

!WBToolBar methods ! 
wbSuggestedExtent
		"Private"
    self elements isEmpty ifTrue: [ ^self cellSize ].
    ^self leftTop distanceRightAndDown:
        elements last rectangle rightBottom! !

!WBTool methods !   
isDown

    ^self state == #down! !

!WBToolPalette methods ! 
size: aPoint
        "Private"
    size := aPoint.! !

!WBToolPalette methods !   
disableElements
		"Disable all of the buttons."
    self elements keysDo: [ :key |
        self disable: key ].! !

!WBToolPalette methods ! 
cachedElements
		"Private"
    ^cachedElements ifNil: [ cachedElements := Set new ]! !

!WBTool methods ! 
newBlankBitmap: aBitmap

    ^WBBitmapClass
            width: aBitmap width // self numImages
            height: aBitmap height
            planes: aBitmap planes
            bitCount: aBitmap bitCount.! !

!WBTool methods !
numImages

    ^2! !

!WBToolPalette methods !
selectedItem
		"Returns the index of the selected button."
    ^selection! !

!WBTool class methods ! 
bitmap: aBitmap selector: aSymbol

    ^(self new)
        state: #up;
        selector: aSymbol;
        bitmap: aBitmap;
        yourself! !

!WBToolPalette methods !  
cacheRedraw: aBoolean
		"Private"
    cacheRedraw := aBoolean! !

!WBToolPalette methods !
useSystem
		"Private - Obsolete"
	#obsoleteMethod.
    ^useSystem ifNil: [ useSystem := false ].! !

!WBToolBar methods !
wbChangesSize
		"Private"
    ^true! !

!WBToolBar methods !  
rectForKey: key
        "Private"
    | element rect |
    key ifNil: [ ^0@0 extent: 0@0 ].
    element := self elementAt: key.
    element ifNil: [ ^self leftTop extentFromLeftTop: 1@1 ].
    element rectangle ifNil: [
        rect := self rectForKey: key - 1.
        element rectangle: ((self isVertical
            ifTrue: [rect leftBottom down: element numSpaces - 1]
            ifFalse: [rect rightTop right: element numSpaces - 1])
                extentFromLeftTop: self cellSize ) ].
    ^element rectangle! !

!WBToolPalette methods !   
stateAt: key
        "Private"
    | element |
    (self validSelection: key) ifFalse: [ ^nil ].

    ^(element := self elementAt: key) isNil
            ifTrue: [ nil ]
            ifFalse: [ element state ]! !

!WBToolPalette methods !
aboutToSaveImage
		"Private - Invalidate the pen before saving the image."
    self elements do: [ :tool | tool pen: nil ].! !

!WBToolBar methods !  
height
	    "Answer the receiver's height."
    ^self cellSize y! !

!WBTool methods !
disabled

    self state: #disabled! !

!WBTool methods ! 
rbSelector

    ^rbSelector! !

!WBTool methods ! 
bitmapSelector: aSymbol

    bitmapSelector := aSymbol! !

!WBTool methods !  
file: aString

    file := aString! !

!WBToolPalette methods !   
isPostAutomatic
        "Private"
    ^tpStyle = #postAutomatic! !

!WBToolPalette methods !  
unHighlightSelection
        "Private"
    self unHighlightBitmap: selection.
    selection := nil.! !

!WBToolBar methods ! 
add: aBitmapOrSelector selector: aSelector owner: anObject spaces: numSpaces
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its owner is anObject
			It will be numSpaces from its neighbor."

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: nil 
		owner: anObject 
		spaces: numSpaces 
		rbSelector: nil! !

!WBToolPalette methods ! 
useSystem: aBoolean
		"Private - Obsolete"
	#obsoleteMethod.
    useSystem := aBoolean! !

!WBTool methods ! 
rectangle

    ^rectangle! !

!WBToolPalette methods !
elementAt: key put: anElementArray
		"Private"
    self elements at: key put: anElementArray! !

!WBToolPalette methods ! 
leftTop
        "Private"
    ^self extent * Rectangle leftTopUnit! !

!WBToolPalette methods !   
fontExtent: aPoint

	| du |
	"FramingParameters dialogUnit"
	self useSystem ifTrue: [^self].
	du := (SysFont width @ SysFont height) / (16@32).
	(aPoint ~= du and: [self class autoScale]) ifTrue: [
		self propertyAt: #creationCellSize put: self cellSize.
		self cellSize: (self cellSize * du / aPoint) rounded].! !

!WBToolBar methods !
generateEventFor: aSelection
		"Private"
    ^nil! !

!WBToolPalette methods !
highlight: currentSelection
        "Private"
    | index |
    index := self currentIndex.
    currentSelection = index ifFalse: [
        self event: #showHelp. "Obsolete"
        self triggerEvent: #showHelp: with: (self selectorAt: index)].
    (self isEnabled: index) ifTrue: [
        (currentSelection = index)
            ifFalse: [
                self unHighlightBitmap: currentSelection.
                self highlightBitmap: index.
                self event: #selecting. "Obsolete"
                self triggerEvent: #selecting: with: (self selectorAt: index)
            ].
    ] ifFalse: [
        self unHighlightBitmap: currentSelection.
        index := nil
    ].
    ^index! !

!WBTool methods !  
isUp

    ^self state == #up! !

!WBToolPalette methods ! 
at: key put: aBitmapOrSelector selector: aSelector
		"Private - Store the bitmap and selector at the specified position."
	| selector bitmap element bitmapDict |
	(bitmap := aBitmapOrSelector) isBitmap ifFalse: [
		"This block supports the obsolete CPBitmapDict..."
		selector := aBitmapOrSelector isString
			ifTrue: [ aBitmapOrSelector ]
			ifFalse: [ aSelector ].
		bitmapDict := Smalltalk at: #CPBitmapDict ifAbsent: [ ^nil ].
		bitmap := self useSystem
			ifTrue: [ bitmapDict sysAt: selector asString ifAbsent: [ ^nil ] ]
			ifFalse: [ bitmapDict at: selector asString ifAbsent: [ ^nil ] ] ].
	cellSize isNil ifTrue: [ self cellSize: (bitmap width // 2) @ bitmap height ].
	self elements at: key put: (element := self wbToolClass bitmap: bitmap selector: aSelector).
	aBitmapOrSelector isBitmap | aBitmapOrSelector isNil
		ifFalse: [ element bitmapSelector: aBitmapOrSelector ].
	^element! !

!WBToolBar methods ! 
add: aBitmapOrSelector selector: aSelector enable: enableSelector owner: anObject spaces: numSpaces rbSelector: rbSelector
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its enable selector is enableSelector
			Its owner is anObject
			It will be numSpaces from its neighbor
			and its right button selector is rbSelector."
    | key element |
    key := self elements size + 1.
    self elements add: nil.
    element := self at: key put: aBitmapOrSelector selector: aSelector.
    element isNil ifTrue: [ ^nil ].
    ^element
        numSpaces: numSpaces;
        rbSelector: rbSelector;
        enableSelector: enableSelector;
        owner: anObject;
        yourself! !

!WBToolBar methods ! 
button2Down: aPoint
        "Private - Capture mouse input in preparation for
         right button scrolling."
    | index |

    ( self isLocalDragSource and: [ self isDragButton: 2 ] )
        ifTrue: [ self dragOnMove: true location: aPoint. ].

    index := self currentIndex.

    (self isEnabled: index) ifTrue: [
        self rbEventFor: index.
    ].! !

!WBToolPalette methods !
elementAt: key
		"Private"
    ^self elements at: key ifAbsent: [ nil ]! !

!WBToolBar methods !  
add: aBitmapOrSelector selector: aSelector owner: anObject
		"Add a button to the toolbar.
			Its left button selector is aSelector.
			Its owner is anObject"

	^self 
		add: aBitmapOrSelector 
		selector: aSelector 
		enable: nil 
		owner: anObject 
		spaces: 0 
		rbSelector: nil! !

!WBToolPalette methods !   
wbToolClass
		"Private - Answer the receiver's element class."
    ^WBTool! !

!WBToolPalette methods !   
defaultCellSize
		"Private"
    ^28@28! !

!WBTool methods !  
numSpaces

    ^numSpaces ifNil: [ numSpaces := 0 ]! !

!WBToolPalette methods !  
rectForKey: key

    | element |
    element := self elementAt: key.
    element ifNil: [^0@0 extent: 0@0].
    element rectangle isNil ifTrue: [
        element rectangle:
            ((self leftTop x right: (key x - 1) * (self cellWidth - 1)) @
            (self leftTop y down: (key y - 1) * (self cellHeight - 1))
            extentFromLeftTop: cellSize) ].
    ^element rectangle! !

!WBToolPalette methods ! 
enableElements
		"Enable all of the buttons."
    self elements keysDo: [ :key |
        self enable: key ].! !

!WBToolPalette methods !
display
        "Private - The receiver should display its contents."
    self pen blank: self rectangle.
    1 to: self width do: [ :x |
        1 to: self height do: [ :y |
            self displayKey: x@y
        ]
    ]! !

!WBToolPalette methods ! 
generateEventFor: aSelection
        "Private"
    self event: (
        'R', aSelection y asString,
        'C', aSelection x asString) asSymbol.! !

!WBToolBar methods ! 
updateEnabled

	| changedElements |
	changedElements := self elements select: [:each |
		each updateEnabled].
	changedElements do: [:each |
		self displayKey: (self elements indexOf: each)].! !

!WBToolPalette methods !   
selectItem: key
		"Select button with the index aKey."
    self unHighlightBitmap: selection.
    selection := key.
    self highlightBitmap: key.! !

!WBToolPalette methods ! 
updateEnabled: key

	((self elementAt: key) ifNil: [^nil]) updateEnabled.
	self displayKey: key.! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!