"3.0.0.14"
! 

OrderedCollection subclass: #WBOrderedCollection
  instanceVariableNames: 
    ' properties wbProperties wbPartEvents wbPartMessages wbEventTable '
  classVariableNames: ''
  poolDictionaries: ''!

WBObject subclass: #FramingParameters
  instanceVariableNames: 
    ' initialExtent bottom top right left bottomRel topRel rightRel leftRel centerX centerY indent clientRect duHeight duWidth '
  classVariableNames: 
    ' InitializationSelector '
  poolDictionaries: 
    ' OperatingSystemConstants '!

!ControlPane methods !   
isCompatible: anObject

    "Private: Added by Objectshare.
     Is an<Object> compatible with the receiver"

    #addedByOSI.
    self obsoleteMethod.
    ^false! !

!Bitmap class methods !   
oldMemoryContext
    "Answer the old bitmap device context."

    #addedByOSI.
    ^OldMemoryContext! !

!FramingParameters methods !   
dialogUnit
		"Private - Answer the receiver's dialog units."
    ^self dialogUnitWidth @ self dialogUnitHeight! !

!TopPane methods ! 
defaultStyle
	"Private - Answer the default frame style for the receiver."

	#addedByOSI.
	^self frameStyleFromPStyle ifNil: [super defaultStyle]! !

!WBOrderedCollection methods !
wbPropertyAt: key ifAbsent: aBlock
        "Private - Answer the value associated with key
	        in the properties dictionary; if absent, 
	        answer the result of evaluating aBlock."
    wbProperties isNil ifTrue: [ ^aBlock value ].
    ^wbProperties at: key ifAbsent: aBlock! !

!TopPane methods !
pStyle: s

    "Added by OSI"
    #addedByOSI.
    self propertyAt: #pStyle put: s.! !

!FramingParameters methods !
xC
    "Private"

    centerX := true.! !

!FramingParameters methods !  
rightProportional: x
    "Private"

    self rP: x! !

!WBOrderedCollection methods !
wbEventTable
		"Private - Answer the event table."
	^wbEventTable! !

!TopPane methods !  
pStyle

    "Added by OSI"
    #addedByOSI.
    ^self propertyAt: #pStyle! !

!WBOrderedCollection methods !
wbReleaseEventTable
    "Private"
    "Break all connections to event handlers."

    wbEventTable := nil! !

!FramingParameters methods !  
storeForDialogTopPaneOn: aStream indentString: indentString
	"Append the definition of the receiver to aStream."

	self storeOn: aStream indentString: indentString.! !

!FramingParameters methods !
iDUE
    "Private"

    ^(initialExtent / self dialogUnit ) rounded! !

!FramingParameters methods ! 
alignDialogLeftTop: aPoint
	"Align the left top of the receiver to aPoint."

	self alignWindowLeftTop: aPoint.! !

!FramingParameters methods !  
isWBFramingContext
		"Answer true if the receiver is WB framing parameters or a framing context.
		PARTS Support"
    ^true! !

!WBOrderedCollection methods !   
wbPropertyAt: key 
        "Private - Answer the value associated with key
	        in the properties dictionary."
    wbProperties isNil ifTrue: [ ^nil ].
    ^wbProperties at: key ifAbsent: [ nil ]! !

!OrderedCollection methods !
wbPartEvents
		"Answer the window builder part events."
	#addedByOSI.
	^nil! !

!FramingParameters methods ! 
isPARTSRectangle
		"Answer true because the receiver will sort-of act like a parts rectangle.
			PARTS Support - allows SubPane>>initialRectangleFor: to work because Parts overwrites it"
	^true! !

!FramingParameters methods !   
clientRect
    "Private"

    ^clientRect! !

!SubPane methods ! 
isATabStop
        "Private - Answer true if the receiver is a tabstop"

    #modifiedByOSI.
    "Digitalk assumes that tabStops are default on,
        WB 3.x assumes the same as DT,
        WB 2.x and previous versions of WB
            assumes tab stops are off by default."
	self owner isWBWindow ifTrue: [
		self owner class wbVersion < 3.0 ifTrue: [
			^(self propertyAt: #noTabStop) = false]].

    ^(self propertyAt: #noTabStop) ~= true! !

!ControlPane methods ! 
tabStop
        "Make the dialog item recieve the focus when the user
        presses the TAB key."
    self addStyle: WsTabstop.

	"Obsolete modification."
	"Call super to set the noTabStop property."
	#modifiedByOSI.
	self obsoleteMethod.
	super tabStop.! !

!FramingParameters methods !  
bottomDialogUnits
	    "Private - Answer the bottom dialog units"
    ^(bottom / self dialogUnitHeight) rounded! !

!FramingParameters methods !  
dialogUnitHeight
        "Private - Answer the receiver's dialog unit height."
    ^duHeight ifNil: [
        "If nil then assume old dialog units."
        duHeight := self class oldDialogUnitHeight ]! !

!WBOrderedCollection methods !
wbPartMessages
		"Private - Answer the part events."
	^wbPartMessages! !

!FramingParameters methods !
newFramerFromNewRect: newRect parentRect: containerRect

    "Create a new framing parameters for this pane, based on the
     values of self (i.e. update the relative values). "

    | newFramer |

    "Easy cases are left and bottom, vs. left and top for windows."

    newFramer := FramingParameters new.

    centerX ifTrue: [
        newFramer xCentered.
    ] ifFalse: [
        left notNil ifTrue: [
           left isInteger ifTrue: [
                (leftRel = #left) ifTrue: [
                    newFramer left: newRect left relativeTo: #left.
                ] ifFalse: [ (leftRel = #center) ifTrue: [
                    newFramer left: newRect left - (containerRect width // 2) relativeTo: #center.
                ] ifFalse: [
                    newFramer left: containerRect width - newRect left relativeTo: #right.
                ]].
            ] ifFalse: [
                newFramer leftProportional: (newRect left / containerRect width).
            ].
        ].

        right notNil ifTrue: [
           right isInteger ifTrue: [
                (rightRel = #left) ifTrue: [
                    newFramer right: newRect right relativeTo: #left.
                ] ifFalse: [ (rightRel = #center) ifTrue: [
                    newFramer right: newRect right - (containerRect width // 2) relativeTo: #center.
                ] ifFalse: [
                    newFramer right: containerRect width - newRect right relativeTo: #right.
                ]].
            ] ifFalse: [
                newFramer rightProportional: (newRect right / containerRect width).
            ].
        ].
    ].

    centerY ifTrue: [
        newFramer yCentered.
    ] ifFalse: [
        top notNil ifTrue: [
           top isInteger ifTrue: [
                (topRel = #top) ifTrue: [
                    newFramer top: newRect top relativeTo: #top.
                ] ifFalse: [ (topRel = #center) ifTrue: [
                    newFramer top: newRect top - (containerRect height // 2) relativeTo: #center.
                ] ifFalse: [
                    newFramer top: containerRect height - newRect top relativeTo: #bottom.
                ]].
            ] ifFalse: [
                newFramer topProportional: (newRect top / containerRect height).
            ].
        ].

        bottom notNil ifTrue: [
           bottom isInteger ifTrue: [
                (bottomRel = #top) ifTrue: [
                    newFramer bottom: newRect bottom relativeTo: #top.
                ] ifFalse: [ (bottomRel = #center) ifTrue: [
                    newFramer bottom: newRect bottom - (containerRect height // 2) relativeTo: #center.
                ] ifFalse: [
                    newFramer bottom: containerRect height - newRect bottom relativeTo: #bottom.
                ]].
            ] ifFalse: [
                newFramer bottomProportional: (newRect bottom / containerRect height).
            ].
        ].
    ].

    newFramer initialExtent: newRect extent.

    ^newFramer! !

!WBOrderedCollection methods ! 
wbPropertyAt: key put: aValue
        "Private - Set the value associated with key
	        in the properties dictionary."
    wbProperties isNil ifTrue: [ wbProperties := IdentityDictionary new ].
    aValue isNil ifTrue: [ ^wbProperties removeKey: key ifAbsent: [ ] ].
    ^wbProperties at: key put: aValue! !

!FramingParameters methods !  
bottom: y relativeTo: aSymbol
    "Private"

    aSymbol == #center
        ifTrue: [ bottom := y ] ifFalse: [ bottom := y abs ].
    bottomRel := aSymbol.! !

!FramingParameters methods !   
bottomProportional: y
    "Private"

    self bP: y! !

!FramingParameters methods ! 
indent: anIndent
    "Private"

    indent := anIndent.! !

!FramingParameters methods ! 
storeForDialogSubPaneOn: aStream indentString: indentString
	"Append the definition of the receiver to aStream."

	self storeOn: aStream indentString: indentString.! !

!FramingParameters methods !
asFramingBlockForWindowFromDialogSubPane

	^self! !

!FramingParameters methods ! 
fromRect: aRect inRect: parentRect

    self left: aRect left relativeTo: #left.
    self right: aRect right relativeTo: #left.
    self top: parentRect top - aRect top relativeTo: #top.
    self bottom: parentRect top - aRect bottom relativeTo: #top.
    initialExtent := aRect extent.! !

!FramingParameters methods !   
initialExtent: e
    "Private"

    initialExtent := e! !

!WBOrderedCollection methods !
wbEventTable: anIdentityDictionary
		"Private - Set the event table."
	^wbEventTable := anIdentityDictionary! !

!FramingParameters methods ! 
centerX: aBoolean
    "Private"

    centerX := aBoolean! !

!FramingParameters methods !
wbFramingEditor
	"Answer the class of the framing editor used to edit the receiver."

	^Smalltalk at: #WBFramingEditor! !

!FramingParameters methods !  
initialExtent
    "Private"

    ^initialExtent! !

!WBOrderedCollection methods !   
wbProperties: anIdentityDictionary
		"Private - Set the receiver's property dictionary."
	wbProperties := anIdentityDictionary.! !

!FramingParameters methods !  
isFramingParameters
		"Answer true if the receiver is FramingParameters."
    ^true! !

!LayoutFrame methods !
asFramingParameters: clientRect

	| rect answer |
	rect := self value: clientRect.
	answer := FramingParameters new
		initialExtent: rect extent;
		clientRect: clientRect.
	self wbLeftProportional
		ifTrue: [answer leftProportional: self leftRatio]
		ifFalse: [
			self leftRatio < (1/3) ifTrue: [
				answer left: (clientRect left distanceRight: rect left) relativeTo: #left].
			((1/3) <= self leftRatio) & (self leftRatio < (2/3)) ifTrue: [
				answer left: (clientRect center x distanceRight: rect left) relativeTo: #center].
			(2/3) <= self leftRatio ifTrue: [
				answer left: (clientRect right distanceLeft: rect left) relativeTo: #right]].
	self wbRightProportional
		ifTrue: [answer rightProportional: self rightRatio]
		ifFalse: [
			self rightRatio < (1/3) ifTrue: [
				answer right: (clientRect left distanceRight: rect right) relativeTo: #left].
			((1/3) <= self rightRatio) & (self rightRatio < (2/3)) ifTrue: [
				answer right: (clientRect center x distanceRight: rect right) relativeTo: #center].
			(2/3) <= self rightRatio ifTrue: [
				answer right: (clientRect right distanceLeft: rect right) relativeTo: #right]].
	self wbTopProportional
		ifTrue: [answer topProportional: self topRatio]
		ifFalse: [
			self topRatio < (1/3) ifTrue: [
				answer top: (clientRect top distanceDown: rect top) relativeTo: #top].
			((1/3) <= self topRatio) & (self topRatio < (2/3)) ifTrue: [
				answer top: (clientRect center y distanceDown: rect top) relativeTo: #center].
			(2/3) <= self topRatio ifTrue: [
				answer top: (clientRect bottom distanceUp: rect top) relativeTo: #bottom]].
	self wbBottomProportional
		ifTrue: [answer bottomProportional: self bottomRatio]
		ifFalse: [
			self bottomRatio < (1/3) ifTrue: [
				answer bottom: (clientRect top distanceDown: rect bottom) relativeTo: #top].
			((1/3) <= self bottomRatio) & (self bottomRatio < (2/3)) ifTrue: [
				answer bottom: (clientRect center y distanceDown: rect bottom) relativeTo: #center].
			(2/3) <= self bottomRatio ifTrue: [
				answer bottom: (clientRect bottom distanceUp: rect bottom) relativeTo: #bottom]].
	(self leftRatio = (1/2)) & (self rightRatio = (1/2)) & (self leftInset = self rightInset)
		ifTrue: [answer xCentered].
	(self topRatio = (1/2)) & (self bottomRatio = (1/2)) & (self topInset = self bottomInset)
		ifTrue: [answer yCentered].
	^answer! !

!OrderedCollection methods !
wbPartMessages
		"Answer the window builder part messages."
	#addedByOSI.
	^nil! !

!FramingParameters methods ! 
tP: y
    "Private"

    y = 1
        ifTrue: [
            top := 0.
            topRel := #bottom ]
        ifFalse: [
        top := y.
        topRel := #top ].! !

!FramingParameters class methods !   
newDialogUnit

    ^self newDialogUnitWidth @ self newDialogUnitHeight! !

!FramingParameters class methods ! 
oldDialogUnitHeight

    ^SysFont height / 32! !

!FramingParameters class methods !  
dialogUnit

    ^self dialogUnitWidth @ self dialogUnitHeight! !

!FramingParameters methods !
asLayout
    "Answer a layout equivalent to the receiver."

    | answer iDUE lDU rDU tDU bDU |
    answer := LayoutFrame new.
    iDUE := (initialExtent * self class newDialogUnit) rounded.
    left notNil ifTrue: [lDU := (left * self class newDialogUnitWidth) rounded].
    right notNil ifTrue: [rDU := (right * self class newDialogUnitWidth) rounded].
    top notNil ifTrue: [tDU := (top * self class newDialogUnitHeight) rounded].
    bottom notNil ifTrue: [bDU := (bottom * self class newDialogUnitHeight) rounded].

    centerX ifTrue: [
        answer
            leftRatio: 1/2; leftInset: (initialExtent x // 2) negated;
            rightRatio: 1/2; rightInset: (initialExtent x // 2) negated.
    ] ifFalse: [
        left isNil ifFalse: [
            left isInteger ifFalse: [
                answer leftRatio: left; leftInset: 0.
            ] ifTrue: [
                (leftRel = #left) ifTrue: [
                    answer leftRatio: 0; leftInset: left.
                ] ifFalse: [ (leftRel = #center) ifTrue: [
                    answer leftRatio: 1/2; leftInset: left.
                ] ifFalse: [
                    answer leftRatio: 1; leftInset: left negated.
                ]].
            ].
        ].

        right isNil ifFalse: [
            right isInteger ifFalse: [
                answer rightRatio: right; rightInset: 0.
            ] ifTrue: [
                (rightRel = #left) ifTrue: [
                    answer rightRatio: 0; rightInset: right negated.
                ] ifFalse: [ (rightRel = #center) ifTrue: [
                    answer rightRatio: 1/2; rightInset: right negated.
                ] ifFalse: [
                    answer rightRatio: 1; rightInset: right.
                ]].
            ].
        ] ifTrue: [
            answer
                rightRatio: answer leftRatio;
                rightInset: (answer leftInset negated - initialExtent x).
        ].

        left isNil ifTrue: [
            answer
                leftRatio: answer rightRatio;
                leftInset: (answer rightInset negated - initialExtent x).
        ].

    ].

    centerY ifTrue: [
        answer
            topRatio: 1/2; topInset: (initialExtent y // 2) negated;
            bottomRatio: 1/2; bottomInset: (initialExtent y // 2) negated.
    ] ifFalse: [

        top isNil ifFalse: [
            top isInteger ifFalse: [
                answer topRatio: top; topInset: 0.
            ] ifTrue: [
                (topRel = #top) ifTrue: [
                    answer topRatio: 0; topInset: top.
                ] ifFalse: [ (topRel = #center) ifTrue: [
                    answer topRatio: 1/2; topInset: top.
                ] ifFalse: [
                    answer topRatio: 1; topInset: top negated.
                ]].
            ].
        ].

        bottom isNil ifFalse: [
            bottom isInteger ifFalse: [
                answer bottomRatio: bottom; bottomInset: 0.
            ] ifTrue: [
                (bottomRel = #top) ifTrue: [
                    answer bottomRatio: 0; bottomInset: bottom negated.
                ] ifFalse: [ (bottomRel = #center) ifTrue: [
                    answer bottomRatio: 1/2; bottomInset: bottom negated.
                ] ifFalse: [
                    answer bottomRatio: 1; bottomInset: bottom.
                ]].
            ].
        ] ifTrue: [
            answer
                bottomRatio: answer topRatio;
                bottomInset: (answer topInset negated - initialExtent y).
        ].

        top isNil ifTrue: [
            answer
                topRatio: answer bottomRatio;
                topInset: (answer bottomInset negated - initialExtent y).
        ].
    ].

    ^answer! !

!FramingParameters methods !  
centerY: aBoolean
    "Private"

    centerY := aBoolean! !

!FramingParameters methods !
alignWindowLeftTop: aPoint
	"Align the left top of the receiver to aPoint."

	| box |
	box := Display boundingBox.
	self
		centerX: false;
		centerY: false;
		left: ((
			aPoint x
				rightMost: box left)
				leftMost: (box right left: initialExtent x))
		relativeTo: #left;
		top: ((
			aPoint y
				lowerOf: box top)
				higherOf: (box bottom up: initialExtent y))
		relativeTo: #top.! !

!ControlPane methods !  
basicStyle
        "Private - Answer an Integer with appropriate
         constants combination for basic control style."

    #modifiedByOSI.
    "Digitalk assumes that tabStops are default on,
        WB 3.x assumes the same as DT,
        WB 2.x and previous versions of WB
            assumes tab stops are off by default."
	self owner isWBWindow ifTrue: [
		self owner class wbVersion < 3.0 ifTrue: [
			^WsChild | WsVisible]].

    ^WsChild | WsVisible | WsTabstop! !

!WBOrderedCollection methods !  
wbPartEvents: aWBPartInterfaceList
		"Private - Set the part events."
	^wbPartEvents := aWBPartInterfaceList! !

!FramingParameters methods ! 
top
    "Private"

    ^top! !

!FramingParameters methods ! 
yCentered
    "Private"

    self yC! !

!FramingParameters methods !
value: containerRect
		"Answer a rectangle based on self's framing parameters
		with a parent rectangle containerRect."

    | realTop realBottom realRight realLeft distance |

    centerX ifTrue: [
        distance := (containerRect extent x - initialExtent x) // 2.
        realLeft := containerRect left right: distance.
        realRight := containerRect right left: distance.
    ] ifFalse: [
        left isNil ifFalse: [
            left isInteger ifFalse: [
                realLeft := containerRect left right: (containerRect width * left) rounded.
            ] ifTrue: [
                (leftRel = #left) ifTrue: [
                    realLeft  := containerRect left right: left.
                ] ifFalse: [ (leftRel = #center) ifTrue: [
                    realLeft  := containerRect center x right: left.
                ] ifFalse: [
                    realLeft := containerRect right left: left.
                ]].
            ].
        ].

        right isNil ifFalse: [
            right isInteger ifFalse: [
                realRight := containerRect left right: (containerRect width * right) rounded.
            ] ifTrue: [
                (rightRel = #left) ifTrue: [
                    realRight  := containerRect left right: right.
                ] ifFalse: [ (rightRel = #center) ifTrue: [
                    realRight  := containerRect center x right: right.
                ] ifFalse: [
                    realRight := containerRect right left: right.
                ]].
            ].
        ] ifTrue: [
            realRight := realLeft right: initialExtent x.
        ].

        left isNil ifTrue: [
            realLeft := realRight left: initialExtent x.
        ].

    ].

    centerY ifTrue: [
        distance := (containerRect extent y - initialExtent y) // 2.
        realTop := containerRect top down: distance.
        realBottom := containerRect bottom up: distance.
    ] ifFalse: [

        top isNil ifFalse: [
            top isInteger ifFalse: [
                realTop := containerRect top down: (containerRect height * top) rounded.
            ] ifTrue: [
                (topRel = #top) ifTrue: [
                    realTop  := containerRect top down: top.
                ] ifFalse: [ (topRel = #center) ifTrue: [
                    realTop  := containerRect center y down: top.
                ] ifFalse: [
                    realTop := containerRect bottom up: top.
                ]].
            ].
        ].

        bottom isNil ifFalse: [
            bottom isInteger ifFalse: [
                realBottom := containerRect top down: (containerRect height * bottom) rounded.
            ] ifTrue: [
                (bottomRel = #top) ifTrue: [
                    realBottom  := containerRect top down: bottom.
                ] ifFalse: [ (bottomRel = #center) ifTrue: [
                    realBottom  := containerRect center y down: bottom.
                ] ifFalse: [
                    realBottom := containerRect bottom up: bottom.
                ]].
            ].
        ] ifTrue: [
            realBottom := realTop down: initialExtent y.
        ].

        top isNil ifTrue: [
            realTop := realBottom up: initialExtent y.
        ].
    ].

    ^(realLeft @ realTop rightBottom: realRight @ realBottom) insetBy: self platformIndent! !

!FramingParameters methods ! 
bDU: y r: aSymbol
    "Private"

    bottom := (y * self dialogUnitHeight) rounded.
    aSymbol == #center ifFalse: [ bottom := bottom abs ].
    bottomRel := aSymbol.! !

!FramingParameters methods !   
printOn: aStream
        "Append a representation of the receiver to aStream."

    centerX ifTrue: [
        aStream nextPutAll: '<xCentered>'; cr.
    ] ifFalse: [
        aStream nextPutAll: 'L:  <', left asString, ',', leftRel asString, '>'; cr.
        aStream nextPutAll: 'R: <', right asString, ',', rightRel asString, '>'; cr.
    ].

    centerY ifTrue: [
        aStream nextPutAll: '<yCentered>'; cr.
    ] ifFalse: [
        aStream nextPutAll: 'T: <', top asString, ',', topRel asString, '>'; cr.
        aStream nextPutAll: 'B: <', bottom asString, ',', bottomRel asString, '>'; cr.
    ].

    aStream nextPutAll: 'indent: ', indent asString; cr.
    aStream nextPutAll: 'clientRect: ', clientRect asString; cr.
    aStream nextPutAll: 'initialExtent: ', initialExtent asString; cr.! !

!FramingParameters methods !   
left
    "Private"

    ^left! !

!FramingParameters methods !   
initialize
	    "Private - Initialize the receiver with dialog units."
    centerX := false.
    centerY := false.
    indent := 0@0.
    initialExtent := 0@0.
	duWidth := self class dialogUnitWidth.
	duHeight := self class dialogUnitHeight.! !

!FramingParameters methods !   
iDUE: e
    "Private"

    initialExtent := (e * self dialogUnit) rounded.! !

!FramingParameters class methods !
newDialogUnitWidth

    ^WindowDialog dialogUnit x  / 4! !

!DialogTopPane methods !  
defaultStyle
        "Private - Answer the default frame style for the receiver."
    | dialogStyle |

    #modifiedByOSI.
    (dialogStyle := self frameStyleFromPStyle) ifNil: [
	    dialogStyle := WsCaption | WsSysmenu | WsPopup | WsVisible.
	    dialogStyle := dialogStyle | ( parent isNil ifTrue: [ WsBorder ] ifFalse: [ DsModalframe ] ) ].
    ( OperatingSystem isWin32 and: [ OperatingSystem versionMajor = 4 ] )
        ifTrue: [ dialogStyle := dialogStyle | Ds3dlook ].
    ^dialogStyle! !

!FramingParameters methods !   
scaleFrom: aRect
		"Answer a Rectangle as a result of applying the receiver framer to aRect.
		PARTS Support"
    ^self value: aRect! !

!FramingParameters methods !
rightDialogUnits
    "Private"

    ^(right / self dialogUnitWidth) rounded! !

!FramingParameters methods ! 
cRDU: aRect
    "Private"

    | newRect |

    #osiHack.
    "########## Fixes bug regarding system incompatible client rects in OS/2
    aRect bottom >= 10 ifTrue: [
        newRect := aRect left @ (aRect top - (aRect bottom - 14)) rightBottom: aRect right @ 8.
    ] ifFalse: [
        newRect := aRect.
    ].
    ################################################"

	#osiHack.
	"Should #rightBottom: be changed to rightTop: ?"
	"Something seems incorrect in this equation."
    newRect :=
		(aRect leftBottom * self dialogUnit) rounded
			rightBottom: (aRect rightTop * self dialogUnit) rounded.

    self clientRect: newRect.! !

!FramingParameters methods ! 
topRel
    "Private"

    ^topRel! !

!TopPane methods ! 
frameStyleFromPStyle

    "Added by OSI"

    | s pStyle |

    (pStyle := self pStyle) isNil ifTrue: [
        #addedByOSI.
        ^nil
    ].

    s := 0.

    (pStyle includes: #maximize) ifTrue: [
        s := s | WsMaximizebox.
    ].
    (pStyle includes: #minimize) ifTrue: [
        s := s | WsMinimizebox.
    ].
    (pStyle includes: #sizable) ifTrue: [
        s := s | WsThickframe.
    ] ifFalse: [
        s := s | WsBorder.
    ].
    (pStyle includes: #sysmenu) ifTrue: [
        s := s | WsSysmenu.
    ].
    (pStyle includes: #titlebar) ifTrue: [
        s := s | WsCaption.
    ] ifFalse: [
        s := s | WsPopup.
    ].
    "Support for secondary views as children"
    (self ~~ self owner and: [self == self owner mainView]) ifFalse: [
        (pStyle includes: #mainViewChild) ifTrue: [
            self parent: self owner mainView
        ].
    ].

    ^s! !

!ControlPane methods !  
getDefaultDragObjects

    "Private: Added by Objectshare."

    | dragObjects |
    #addedByOSI.
    #obsoleteMethod.
    (dragObjects := self propertyAt: #defaultDragObjects) isNil
        ifTrue: [^nil].
    self renderAsObjects
        ifFalse:
            [dragObjects := dragObjects
                collect:
                    [:each |
                    each asString]].
    ^dragObjects! !

!FramingParameters methods !
platformIndent
    "Private - Answer the indent for this platform."

    ^0@0! !

!WBOrderedCollection methods ! 
wbPartEvents
		"Private - Answer the part events."
	^wbPartEvents! !

!FramingParameters methods !
tDU: y r: aSymbol
    "Private"

    top := (y * self dialogUnitHeight) rounded.
    aSymbol == #center ifFalse: [ top := top abs ].
    topRel := aSymbol.! !

!OrderedCollection methods !   
wbPartMessages: anObject
		"Set the window builder part messages."
	#addedByOSI.
	^anObject! !

!FramingParameters methods ! 
bottomRel
    "Private"

    ^bottomRel! !

!FramingParameters methods ! 
alignWindowCenter: aPoint
	"Align the Center of the receiver to aPoint."

	self alignWindowLeftTop: (aPoint leftAndUp: initialExtent // 2).! !

!FramingParameters methods ! 
right
    "Private"

    ^right! !

!FramingParameters methods ! 
lDU: x r: aSymbol
    "Private"

    left := (x * self dialogUnitWidth) rounded.
    aSymbol == #center ifFalse: [ left := left abs ].
    leftRel  := aSymbol.! !

!FramingParameters methods !   
asFramingParameters: aRectangle

	^self! !

!FramingParameters methods !  
asFramingBlockForWindowFromDialogTopPane

	^self! !

!FramingParameters methods ! 
storeOn: aStream indentString: indentString

    aStream
        nextPutAll: 'FramingParameters new';
        indentBy: 1;
        cr; nextPutAll: 'iDUE: ', (initialExtent / self class dialogUnit ) rounded asString;
        endMessage;
        cr.

    centerX
        ifTrue: [aStream nextPutAll: 'xC;'; space]
        ifFalse: [
            left notNil
                ifTrue: [
                    left isFraction
                        ifTrue: [aStream nextPutAll: 'lP: ', left asString]
                        ifFalse: [
                            aStream nextPutAll: 'lDU: ', self leftDialogUnits asString, ' '.
                            aStream nextPutAll: 'r: #',leftRel asString].
                    aStream nextPut: $;; space].
            right notNil
                ifTrue: [
                    right isFraction
                        ifTrue: [aStream nextPutAll: 'rP: ', right asString]
                        ifFalse: [
                            aStream nextPutAll: 'rDU: ', self rightDialogUnits asString, ' '.
                            aStream nextPutAll: 'r: #',rightRel asString].
                    aStream nextPut: $;; space]].

    centerY
        ifTrue: [aStream nextPutAll: 'yC;'; space]
        ifFalse: [
            aStream cr.
            top notNil
                ifTrue: [
                    top isFraction
                        ifTrue: [aStream nextPutAll: 'tP: ', top asString]
                        ifFalse: [
                            aStream nextPutAll: 'tDU: ', self topDialogUnits asString, ' '.
                            aStream nextPutAll: 'r: #',topRel asString].
                    aStream nextPut: $;; space].
            bottom notNil
                ifTrue: [
                    bottom isFraction
                        ifTrue: [aStream nextPutAll: 'bP: ', bottom asString]
                        ifFalse: [
                            aStream nextPutAll: 'bDU: ', self bottomDialogUnits asString, ' '.
                            aStream nextPutAll: 'r: #',bottomRel asString].
                    aStream nextPut: $;; space]].

    clientRect notNil
        ifTrue: [
            centerY ifFalse: [aStream cr].
            aStream nextPutAll: 'cRDU: (',  self cRDU asString, ')']
        ifFalse: [
            indent = (0@0)
                ifTrue: [aStream backup: 2]
                ifFalse: [
                    centerY ifFalse: [aStream cr].
                    aStream nextPutAll: 'indent: ', indent asString]].

    aStream indentBy: -1.! !

!FramingParameters methods !  
bP: y
    "Private"

    y = 1
        ifTrue: [
            bottom := 0.
            bottomRel := #bottom ]
        ifFalse: [
            bottom := y.
            bottomRel := #top ].! !

!FramingParameters methods ! 
valueDU: containerRect
        "Answer a rectangle based on self's framing parameters
         with a parent rectangle containerRect."

    ^self valueToDU: (
        (containerRect leftTop * FramingParameters newDialogUnit) rounded
            rightBottom:
                (containerRect rightBottom * FramingParameters newDialogUnit) rounded )! !

!FramingParameters class methods ! 
oldDialogUnitWidth

    ^SysFont width / 16! !

!WBOrderedCollection methods !
wbPartMessages: aWBPartInterfaceList
		"Private - Set the part events."
	^wbPartMessages := aWBPartInterfaceList! !

!OrderedCollection methods ! 
wbPartEvents: anObject
		"Set the window builder part events."
	#addedByOSI.
	^anObject! !

!FramingParameters class methods !   
newDialogUnitHeight

    ^WindowDialog dialogUnit y / 8! !

!FramingParameters methods !  
yC
    "Private"

    centerY := true.! !

!DialogTopPane methods !  
frameStyleFromPStyle

    "Added by OSI."

    | s pStyle |

    (pStyle := self pStyle) isNil ifTrue: [
        #addedByOSI.
        ^nil
    ].
    s := DsNoidlemsg  | WsPopup.

    (pStyle includes: #sysmenu) ifTrue: [
        s := s | WsSysmenu.
    ].
    (pStyle includes: #titlebar) ifTrue: [
        s := s | WsCaption.
    ].
    (pStyle includes: #sysmodal) ifTrue: [
        s := s | DsSysmodal | DsModalframe.
    ].
    (pStyle includes: #modal) ifTrue: [
        s := s | DsModalframe.
    ] ifFalse: [
        s := s | WsBorder.
    ].

    ^s! !

!FramingParameters methods !  
indent
    "Private"

    ^indent! !

!FramingParameters class methods ! 
dialogUnitHeight

    ^SysFont height / 32! !

!FramingParameters methods !   
leftProportional: x
    "Private"

    self lP: x! !

!FramingParameters methods !   
leftRel
    "Private"

    ^leftRel! !

!FramingParameters class methods !   
dialogUnitWidth

    ^SysFont width / 16! !

!Window methods !
getContentsHandler
    "Added by OSI"
    #addedByOSI.
    self obsoleteMethod.
	^nil! !

!FramingParameters methods !  
right: x relativeTo: aSymbol
    "Private"

    aSymbol == #center
        ifTrue: [ right := x ] ifFalse: [ right := x abs ].
    rightRel := aSymbol.! !

!FramingParameters methods !   
rP: x
    "Private"

    x = 1
        ifTrue: [
            right := 0.
            rightRel := #right ]
        ifFalse: [
            right := x.
            rightRel := #left ].! !

!ControlPane methods !   
renderAsObjects

    "Private: Added by Objectshare.
     Should the receiver deliver objects in a drag & drop
     transfer or the string representations of the objects"

    #addedByOSI.
    self obsoleteMethod.
    ^(self propertyAt: #renderAsObjects) ~~ nil! !

!FramingParameters methods !  
cRDU
    "Private"

    ^(self clientRect leftTop / self dialogUnit) rounded
        rightBottom:
            (self clientRect rightBottom / self dialogUnit) rounded.! !

!FramingParameters methods !
asFramingBlockForDialogSubPaneFromWindow

	^self! !

!WBDialogTopPane methods !   
pStyle

    | pStyle |
    pStyle := super pStyle ifNil: [^nil].
    (pStyle includes: #modal) ifFalse: [
        pStyle := (pStyle asSet add: #modal; yourself) asArray.
    ].
    ^pStyle! !

!FramingParameters methods !
centerY
    "Private"

    ^centerY! !

!FramingParameters methods ! 
xCentered
    "Private"

    self xC! !

!FramingParameters methods !
dialogUnitWidth
        "Private - Answer the receiver's dialog unit width."
    ^duWidth ifNil: [
        "If nil then assume old dialog units."
        duWidth := self class oldDialogUnitWidth ]! !

!FramingParameters methods !   
asFramingBlockForDialogTopPaneFromWindow

	^self! !

!FramingParameters methods ! 
valueToDU: containerRect
        "Answer a rectangle based on self's framing parameters
		 with a parent rectangle containerRect."

	| answer |
	answer := self value: containerRect.
	^(answer leftTop / FramingParameters newDialogUnit) rounded
		rightBottom:
			(answer rightBottom / FramingParameters newDialogUnit) rounded! !

!FramingParameters methods !
centerX
    "Private"

    ^centerX! !

!TextEdit methods !  
getTabStop
    	"Answer tabInterval in number of pels."

    #addedByOSI.
	self obsoleteMethod.
	"Use TextEdit>>tabStopInterfal instead."
    ^self propertyAt: #tabStop! !

!FramingParameters methods ! 
topDialogUnits
    "Private"

    ^(top / self dialogUnitHeight) rounded! !

!FramingParameters methods !
rightRel
    "Private"

    ^rightRel! !

!FramingParameters methods !   
clientRect: e
    "Private"

    clientRect :=  e! !

!FramingParameters methods !   
top: y relativeTo: aSymbol
    "Private"

    aSymbol == #center
        ifTrue: [ top := y ] ifFalse: [ top := y abs ].
    topRel := aSymbol.! !

!FramingParameters methods !   
left: x relativeTo: aSymbol
    "Private"

    aSymbol == #center
        ifTrue: [ left := x ] ifFalse: [ left := x abs ].
    leftRel  := aSymbol.! !

!FramingParameters methods !  
bottom
    "Private"

    ^bottom! !

!FramingParameters methods !   
rDU: x r: aSymbol
    "Private"

    right := (x * self dialogUnitWidth) rounded.
    aSymbol == #center ifFalse: [ right := right abs ].
    rightRel := aSymbol.! !

!FramingParameters methods !
lP: x
    "Private"

    x = 1
        ifTrue: [
            left := 0.
            leftRel := #right ]
        ifFalse: [
        left := x.
        leftRel := #left ].! !

!SubPane methods !   
tabStop
        "Make the dialog item receive the focus when the user
        presses the TAB key.  By default every subpane which
        can be a tabstop is a tabstop"

    #modifiedByOSI.
    "Store false rather than nil."
    self
        propertyAt: #noTabStop put: "nil" false;
        addStyle: WsTabstop.! !

!FramingParameters methods !  
leftDialogUnits
    "Private"

    ^(left / self dialogUnitWidth) rounded! !

!FramingParameters methods !   
alignDialogCenter: aPoint
	"Align the Center of the receiver to aPoint."

	self alignWindowCenter: aPoint.! !

!FramingParameters methods !  
topProportional: y
    "Private"

    self tP: y! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!