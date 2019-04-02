3.1.0.106
   
setAttrs: aPen
        "Private - Restore the attributes of aPen."
    aPen downState
        ifTrue: [aPen selectObject: aPen logicalTool handle].
    aPen place: aPen locationVar
!   
pen: anInteger for: aHandle medium: aGraphicsMedium
        "Answer a Commander initialized
         to anInteger number of pens."
    ^self new
        initialize;
        handle: aHandle;
        graphicsMedium: aGraphicsMedium;
        initialize: anInteger!  
cursorLocation
        "Private - Answer the mouse cursor location
         relative to the receiver."
    ^Cursor sense mapScreenToClient: self!  
stretch: anInteger
        "Private - AnimationPane cannot handle stretched
         graphics translations."
    (anInteger ~= 0) & active ifTrue: [
        ^MessageBox message: 'Not allowed for AnimationPane'].
    super stretch: anInteger.!   
displayObject: anObject
        "Private - Display anObject.  anObject must
         already be in the receiver's collection."
    | rect |
    rect := (anObject previousPosition min: anObject position)
        corner: ((anObject position max: anObject previousPosition)
            + anObject boundingBox extent).
    self restore: rect.
    intermediate isNil ifTrue: [ self makeBackup ].
    anObject displayWith: intermediate pen.
    objects do: [ :sibling |
        sibling == anObject ifFalse: [
            (sibling boundingBox intersects: rect)
                ifTrue: [
                    sibling displayWith: intermediate pen]]].
    self post: rect to: rect origin! 
active
        "Answer true if the receiver is active."
    ^active!
restore: aRectangle
        "Private - Copy aRectangle from backup to intermediate."
    intermediate pen
        copyBitmap: backup
        from: aRectangle
        to: aRectangle!
step
        "Private - Move each object one step."
    | rect intermediateRegion paneRegion intState temp |
    (needBackup isNil or: [backup isNil])
        ifTrue: [^self].
    intState := Process enableInterrupts: false.
    intermediateRegion := intermediate pen emptyRegion.
    paneRegion := graphicsTool emptyRegion.
    activeSet do: [ :child |
        rect := child nextRect.
        intermediate pen
            addRegion: (temp := intermediate pen createRegion: rect)
                to: intermediateRegion;
            destroyRegion: temp.
        graphicsTool
            addRegion: (temp := graphicsTool createRegion: rect)
                to: paneRegion;
            destroyRegion: temp].
    intermediate pen
        setClipRegion: intermediateRegion;
        copyBitmap: backup
        from: backup boundingBox
        to: backup boundingBox.
    objects do: [ :child |
        child displayWith: intermediate pen].
    intermediate pen destroyRegion: intermediateRegion.
    graphicsTool
        setClipRegion: paneRegion;
        copyBitmap: intermediate
            from: intermediate boundingBox
            to: intermediate boundingBox;
        destroyRegion: paneRegion.
    Process enableInterrupts: intState.!   
clear
        "Stop all animation and remove all objects."
    self stopAll; hide.
    objects := OrderedCollection new!   
contents: aCollection
        "Set the receiver's collection of animated objects
         to aCollection."
    | wasActive |
    wasActive := self stop.
    objects := aCollection.
    objects do: [:object |
        object parent: self].
    wasActive ifTrue: [self go]!
hide: aRectangle
        "Private - Display aRectangle from the receiver's backup."
    graphicsTool
        copyBitmap: backup
        from: aRectangle
        to: aRectangle! 
makeActive: anAnimatedObject
        "Make anAnimatedObject active, but do not
         start it animating."
    activeSet add: anAnimatedObject.! 
aboutToSaveImage
        "Private - The image is about to be saved.
         Save the contents of the graph pane."
    self stop.
    super aboutToSaveImage! 
addObject: anAnimatedObject
        "Add anAnimatedObject to the receiver's
         collection of animated objects."
    | wasActive |
    wasActive := self stop.
    objects isNil
        ifTrue: [objects := OrderedCollection new].
    objects add: anAnimatedObject.
    anAnimatedObject parent: self.
    wasActive ifTrue: [self go]! 
initialize
        "Private - Initialize the receiver."
    super initialize.
    active := false.
    activeSet := Set new.
    stepSemaphore := Semaphore new.
    objects := OrderedCollection new.
    intermediate := backup := nil!  
post: aRectangle to: aPoint
        "Private - Display aRectangle of intermediate at aPoint."
    graphicsTool
        copyBitmap: intermediate
        from: aRectangle
        at: aPoint! 
display
        "Private - Display the receiver."
    backup isNil ifTrue: [self makeBackup].
    ((self isActive and: [needBackup isNil or: [needBackup]])
        and: [self isOffScreen]) ifTrue: [
        needBackup := false.
        ^self invalidateRect: nil].
    backup notNil ifTrue: [self hide].
    super display.
    (stretch ~= 0 and: [objects notEmpty])
        ifTrue: [self stretch: 0; setScale].
    (needBackup isNil or: [
    needBackup]) ifTrue: [
        self makeBackup.
        needBackup := true.
        (self isActive and: [self isOffScreen not])
            ifTrue: [needBackup := false]].
    objects do: [ :child |
        (activeSet includes: child) ifFalse: [child display]].!
resize: aRectangle
        "Private - Make a backup when resized."
	self isHandleOk ifFalse: [ ^nil ].
    super resize: aRectangle.
    needBackup := true!  
makeBackup
        "Private - Make a bitmap copy of the window
         and store in backup."
    self mainWindow minimized ifTrue: [^self].
    backup notNil ifTrue: [backup release].
    intermediate notNil ifTrue: [intermediate release].
    backup := Bitmap new screenExtent: graphicsTool extent.
    intermediate := Bitmap new screenExtent: graphicsTool extent.
    backup pen
        copy: graphicsTool
        from: (graphicsTool boundingBox)
        at: 0 @ 0.
    objects do: [:ao| ao display].!  
hide
        "Private - Hide all the objects."
    objects do: [ :child | child hide]!  
fromBackup: aBitmap rect: aRectangle
        "Private - Copy a portion of the receiver's
         backup into aBitmap."
    aBitmap pen
        copyBitmap: backup
        from: aRectangle
        to: aRectangle! 
childAt: aPoint
        "Private - Answer the object containing aPoint, or nil."
    objects do: [ :object |
        (object boundingBox containsPoint: aPoint)
            ifTrue: [^object]].
    ^nil!
deanimate: anAnimatedObject
        "Stop anAnimatedObject from continuously moving."
    | wasActive |
    wasActive := self stop.
    activeSet remove: anAnimatedObject.
    wasActive ifTrue: [self go]! 
isActive: anAnimatedObject
        "Answer true if anAnimatedObject is being animated."
    ^active and: [activeSet includes: anAnimatedObject]!
validate
        "Private - The receiver was just created, make a backup."
    needBackup := nil.
    super validate!  
animate: anAnimatedObject
        "Start anAnimatedObject moving continuously."
    (objects includes: anAnimatedObject)
        ifFalse: [^self error: 'Not my child, cannot animate.'].
    self stop.
    self makeActive: anAnimatedObject.
    self go!
close
        "Private - Release the bitmaps."
    self stop.
    backup notNil ifTrue: [backup release].
    intermediate notNil ifTrue: [intermediate release].
    super close.!  
updateSliders
        "Private - Reimplemented here because AnimationPanes
         have no scrollbars."!   
contents
        "Answer the receiver's collection of animated objects."
    ^objects!  
stopAll
        "Stop all objects from animating."
    self stop.
    activeSet := Set new!
wmActivate: mp1 with: mp2
        "Private - Process the activate message."
    ^nil!   
stop
        "Private - Stop all objects from animating."
    active ifFalse: [^false].
    active := false. "cause run loop to end"
    (process notNil and: [process debugger notNil])
         ifTrue: [^false].
    stepSemaphore wait.   "wait for end of run loop"
    Notifier setPeekCount: 1000.
    ^true   "was active"!   
displayWith: aPen
        "Private - Display the receiver using aPen."
    | oldColor |
    color notNil ifTrue: [
        oldColor := aPen foreColor.
        aPen foreColor: color].
    aPen
        copyBitmap: self currentFrame
        from: self currentFrame boundingBox
        at: position
        rule: Srcand.
    color notNil ifTrue: [aPen foreColor: oldColor]!  
dragon: anInteger
        "Private - Draw a dragon pattern where anInteger
          is the recursion factor."
    | length |
    length := height // 100.
    anInteger = 0
        ifTrue: [
            self go: length]
        ifFalse: [
            anInteger > 0
                   ifTrue: [
                         self dragon: anInteger - 1.
                         self turn: 90.
                         self dragon: 1 - anInteger]
                    ifFalse: [
                         self dragon: -1 - anInteger.
                         self turn: -90.
                         self dragon: 1 + anInteger]]! 
location
        "Answer a Point indicating the
         position of the first pen."
    self setAttrs: pens first.
    ^pens first location! 
go: anInteger
        "Move all pens a distance of anInteger
         in their current direction."
    | index pen |
    index := 1.
    [index > pens size]
        whileFalse: [
            self setAttrs: (pen := pens at: index).
            pen go: anInteger.
            pen locationVar: pen location.
            index := index + 1].
    ^pens first locationVar! 
height: anInteger
        "Set the height of the receiver and all its pens."
    height := anInteger.
    pens isNil ifTrue: [ ^self ].
    pens do: [ : each | each height: anInteger ].!
place: aPoint
        "Set the position of the first pen to aPoint
         and modify the position of the remaining
         pens by the amount of change in the first pen.
         No drawing takes place."
    | delta |
    delta := aPoint -  pens first locationVar. "pens first location."
    pens do: [ :aPen |
        self setAttrs: aPen.
        aPen place: (aPen location + delta).
        aPen locationVar: aPen location]!   
width: anInteger
        "Set the width of the receiver and all its pens."
    width := anInteger.
    pens isNil ifTrue: [ ^self ].
    pens do: [ : each | each width: anInteger ].!
fanOut
        "Change the direction of each pen by an
         increment of 360 / number of pens."
    2 to: pens size do: [ :index |
        (pens at: index) turn:
            ((index - 1) * (360 / pens size)) rounded]!
direction: anInteger
        "Set the direction of every pen
         to anInteger number of degrees."
    pens do: [ :aPen | aPen direction: anInteger]!  
down
        "Set all the pens down."
    pens do: [ :aPen |
        aPen down]!   
release
        "Delete all the pen objects."
    super release.
    pens do: [: pen |
        pen release]!  
goto: aPoint
        "Move the first pen to aPoint and then move
         the remaining pens by the same distance
         and direction as the first move."
    | delta |
    delta := aPoint - (pens first locationVar). "pens first location."
    pens do: [ :aPen |
        self setAttrs: aPen.
        aPen goto: aPen location + delta.
        aPen locationVar: aPen location]!
up
        "Lift all the pens."
    pens do: [ :aPen |
        aPen up]!   
turn: anInteger
        "Change the direction of all the pens
         by anInteger number of degrees."
    pens do: [ :aPen | aPen turn: anInteger]!  
pen: anInteger forDC: dc medium: aGraphicsMedium
        "Answer a Commander initialized to anInteger number
         of pens. The pens of the commander share the device
         context as the pen of aGraphicsMedium."
    ^self pen: anInteger for: dc medium: aGraphicsMedium!  
resize: rect deferInfo: winPosInfo
        "Private - Make a backup when resized."
    | posInfo |
    posInfo := super resize: rect deferInfo: winPosInfo.
    needBackup := true.
    ^posInfo!
go
        "Start animating all active objects."
    active ifTrue: [^self].
    activeSet isEmpty ifTrue: [^self].
    active := true.
    Notifier setPeekCount: 50.
    [process := CurrentProcess.
     [active] whileTrue: [self step].
        stepSemaphore signal] forkAt: 3! 
mandala: mPoints diameter: mSize color: mColor
        "Answer a new instance of the receiver whose
         frames are mandalas with mPoints vertices
         of size mSize and color mColor."
    | mandala bitmap |
    mandala := self new.
    (Array
        with: 0
        with: 90 // mPoints
        with: 90 // mPoints * 2
        with: 90 // mPoints * 3) do: [ :initDir |
            bitmap := Bitmap screenExtent: mSize @ mSize.
            bitmap pen
                foreColor: mColor;
                home;
                mandala: mPoints diameter: mSize initDir: initDir.
            mandala addFrame: bitmap].
    ^mandala!  
frames: aCollection
        "Answer a new instance of the receiver with its collection
         of frames set to aCollection."
    ^self new frames: aCollection!  
new
		"Answer a new instance of the receiver."
    ^super new initialize!   
spider: diameter
        "Answer a new instance of the receiver whose
         frames are spider-like."
    | spider bitmap pen |
    spider := self new.
    bitmap := Bitmap screenExtent: diameter @ diameter.
    pen := bitmap pen.
    pen
        home;
        circle: diameter // 20.
    1 to: 360 by: 45 do: [ :i |
        pen 
            home;
            direction: i;
            setLineWidth: 2;
            go: diameter // 4;
            setLineWidth: 1;
            circle:1;
            go: diameter // 4].
    spider addFrame: bitmap.
    bitmap := Bitmap screenExtent: diameter @ diameter.
    pen := bitmap pen.
    pen
        home;
        circle: diameter // 20.
    22 to: 360 by: 45 do: [ :i |
        pen 
            home;
            direction: i;
            setLineWidth: 2;
            go: diameter // 6;
            setLineWidth: 1;
            circle: 2;
            go: diameter // 6].
    spider addFrame: bitmap.
    spider chaser.
    ^spider!   
initialize: anInteger
        "Private - initialize anInteger number of pens
         for the receiver"
    | pen hPen panePen |
    pens := Array new: anInteger.
    1 to: pens size do: [: each |
        pen := RecordingPen forDC: self handle medium: graphicsMedium.

        panePen := graphicsMedium graphicsTool.
        pen segmentIsOpen: panePen segmentIsOpen;
            segments: panePen segments;
            currentId: panePen currentId;
            setDrawingMode: panePen drawingMode.
        pens at: each put: pen.
        hPen := WinLogicalPen
            style: PsSolid
            color: (GraphicsTool paletteIndex: each)
            width: 0.
        pen logicalTool: hPen ].
    self
        width: graphicsMedium width;
        height: graphicsMedium height!  
turn: anInteger
        "Change the direction of the receiver anInteger
         number of degrees.  If anInteger is positive, it
         turns clockwise, if negative counter-clockwise."
    direction := direction + anInteger \\ 360!
direction: anInteger
        "Change the direction of the receiver to anInteger
         degrees, where 0 is east, 90 is south."
    | x y speed |
    x := jumpIncrement x.
    y := jumpIncrement y.
    direction \\ 180 = 0
        ifTrue: [speed := x]
        ifFalse: [speed := y * 100 // direction integerSin].
    direction := anInteger.
    x := anInteger integerCos * speed + 50 // 100.
    y := anInteger integerSin * speed + 50 // 100.
    jumpIncrement := x @ y!   
position
        "Answer the current position of the receiver."
    ^position!  
boundingBox
        "Private - Answer the bounding box of the
         receiver on its parent."
    ^self currentFrame boundingBox translateBy: self position! 
drag: aPoint
        "Track the receiver with the mouse starting
         at aPoint."
    self perform: dragSelector with: aPoint! 
move
        "Private - Move the receiver one step."
    self perform: adjustPosSelector!   
caughtIt
        "Private - The receiver was caught or finished
         an animateFor:. Perform the endBlock."
    Process enableInterrupts: true.
    [self stop] forkAt: 3.
    endBlock notNil ifTrue: [
        endBlock value: self]! 
active
        "Answer true if the receiver is being animated."
    ^parent isActive: self! 
adjustPosition
        "Private - Move the receiver to its next position."
    self adjustPosition: jumpIncrement!  
bouncerAdjustPosition
        "Private - Compute the next position of a bouncer."
    self adjustPosition.
    self checkHit do: [ :wall |
        wall = 0 ifTrue: [
            jumpIncrement x positive & clockwise
                ifTrue: [clockwise := false.  self reverse].
            jumpIncrement x negative & clockwise not
                ifTrue: [clockwise := true.  self reverse].
            jumpIncrement y: jumpIncrement y abs negated].
        wall = 1 ifTrue: [
            jumpIncrement y negative & clockwise
                ifTrue: [clockwise := false.  self reverse].
            jumpIncrement y positive & clockwise not
                ifTrue: [clockwise := true.  self reverse].
            jumpIncrement x: jumpIncrement x abs negated].
        wall = 2 ifTrue: [
            jumpIncrement x negative & clockwise
                ifTrue: [clockwise := false.  self reverse].
            jumpIncrement x positive & clockwise not
                ifTrue: [clockwise := true.  self reverse].
            jumpIncrement y: jumpIncrement y abs].
        wall = 3 ifTrue: [
            jumpIncrement y positive & clockwise
                ifTrue: [clockwise := false.  self reverse].
            jumpIncrement y negative & clockwise not
                ifTrue: [clockwise := true.  self reverse].
            jumpIncrement x: jumpIncrement x abs]]!
parent
        "Private - Answer receiver's parent."
    ^parent!   
parent: anAnimationPane
        "Private - Set the receiver's parent to anAnimationPane."
    parent := anAnimationPane!
chaserAdjustPosition
        "Private - Compute the next position of a chaser."
    | delta divisor |
    delta := parent cursorLocation - self boundingBox center.
    divisor := ((delta x * delta x) + (delta y * delta y)) intSqrt.
    divisor := divisor // jumpIncrement x.
    divisor = 0
        ifTrue: [self caughtIt]
        ifFalse: [
            self adjustPosition: delta // divisor.
            position := self confine: position]!   
simpleDrag: aPoint
        "Private - Move the receiver with the mouse until the
         mouse button goes up."
    | offset newPoint wasActive |
    wasActive := parent stop.
    offset := aPoint - self boundingBox origin.
    Cursor hide.
    Notifier consumeInputUntil: [ :event |
        newPoint := self confine: parent cursorLocation - offset.
        self jumpTo: newPoint.
        parent captureMouseInput.
        event selector = #button1Up:].
    Cursor display.
    parent clearMouseCapture.
    wasActive ifTrue: [parent go]! 
previousPosition
        "Private - Answer the receiver's position
         before its most recent move."
    ^oldPosition!
initialize
        "Private - Initialize the receiver."
    position := 0@0.
    oldPosition := 0@0.
    jumpIncrement := 1@1.
    direction := 45.
    index := 1.
    shiftRate := 1.
    shiftCount := 1.
    self bouncer.
    goUntil := goCount := 0.
    clockwise := false.!   
color: aColorInteger
        "Set the color of the receiver to aColorInteger."
    color := aColorInteger!  
display
        "Display the receiver."
    parent displayObject: self! 
endBlock: aBlock
        "Set the endBlock to aBlock.  aBlock will be
         evaluated when the receiver object finishes
         goUntil steps or catches the mouse if it is a
         chaser object.  aBlock takes one argument
         which is the animated object."
    endBlock := aBlock!
jumpIncrement: aPoint
        "Set the distance and direction the receiver
         moves on each step."
    jumpIncrement := aPoint!  
chaser
        "Make the receiver be a chaser type of 
         animated object."
    adjustPosSelector := #chaserAdjustPosition.
    dragSelector := #simpleDrag:.
    jumpIncrement := 10 @ 10.!   
stop
        "Stop the receiver from continuously animating."
    parent deanimate: self!   
bouncer
        "Make the receiver be a bouncer type of
         animated object."
    adjustPosSelector := #bouncerAdjustPosition.
    dragSelector := #bouncerDrag:.!   
frames
        "Answer the collection of frames of the receiver."
    ^frames!  
frames: aCollection
        "Set the frames of the receiver to aCollection of Bitmaps."
    frames := aCollection!  
adjustPosition: aPoint
        "Private - Move the receiver to its next position
         by moving aPoint away from the old position."
    oldPosition := position.
    position := position + aPoint!   
go: anInteger
        "Move the receiver anInteger steps."
    parent makeActive: self.
    anInteger timesRepeat: [parent step].
    parent deanimate: self! 
speed: anInteger
        "Change the speed of the receiver to anInteger."
    | x y |
    x := jumpIncrement x.
    y := jumpIncrement y.
    x := direction integerCos * anInteger + 50 // 100.
    y := direction integerSin * anInteger + 50 // 100.
    jumpIncrement := x @ y!
addFrame: aFrame
        "Add aFrame (a Bitmap) to the receiver's frames."
    frames isNil
        ifTrue: [
            frames := Array with: aFrame]
        ifFalse: [
            frames := frames, (Array with: aFrame)]! 
jumpTo: aPoint
        "Move the receiver to aPoint."
    oldPosition := position.
    position := aPoint.
    self display!  
confine: aPoint
        "Private - Confine aPoint to receiver's parents boundingBox."
    ^(aPoint
        max: parent boundingBox origin)
        min: parent boundingBox corner - self boundingBox extent!  
hide
        "Private - Hide the receiver."
    parent hide: self boundingBox!  
animateFor: anInteger
        "Start the movement of the receiver for anInteger
         steps."
    goUntil := anInteger.
    goCount := 0.
    adjustPosSelector = #chaserAdjustPosition
        ifTrue: [10000 timesRepeat: []]. "give you a head start"
    parent animate: self!  
nextFrame
        "Private - Advance the receiver by one frame."
    shiftCount >= shiftRate
        ifTrue: [
            shiftCount := 1.
            index = frames size
                ifTrue: [index := 1]
                ifFalse: [index := index + 1]]
        ifFalse: [
            shiftCount := shiftCount + 1].
    ^frames at: index!
reverse
        "Reverse the rotation direction of the receiver."
    | reversed |
    (frames isCollection) ifFalse: [^self].
    index := frames size - index + 1.
    reversed := frames reversed.
    frames := OrderedCollection new.
    reversed do: [ :frame |
        frames addLast: frame].
    frames := frames asArray! 
stepsPerFrame: anInteger
        "Set the number of steps the receiver performs
         before changing to its next frame."
    shiftRate := anInteger!   
position: aPoint
        "Set the receiver's position to aPoint."
    position := aPoint!   
animate
        "Start the movement of the receiver."
    adjustPosSelector = #chaserAdjustPosition
        ifTrue: [10000 timesRepeat: []]. "give you a head start"
    parent animate: self!
bouncerDrag: aPoint
        "Private - Drag a bouncer object to get it started."
    | offset newPoint delta count trail trailSize trailIndex tempIncrement |
    parent stop.
    offset := aPoint - self boundingBox origin.
    trailSize := 7.
    trailIndex := 1.
    trail := Array new: trailSize.
    trail atAllPut: self boundingBox origin.
    Cursor hide.
    Notifier consumeInputUntil: [ :event |
        newPoint := parent cursorLocation - offset.
        self jumpTo: newPoint.
        trail at: trailIndex put: newPoint.
        trailIndex = trailSize
            ifTrue: [trailIndex := 1]
            ifFalse: [trailIndex := trailIndex + 1].
        event selector = #button1Up:].
    parent clearMouseCapture.
    Cursor display.
    tempIncrement := 0@0.
    count := trailIndex.
    [count = 1
        ifTrue: [count := trailSize]
        ifFalse: [count := count - 1].
    count ~= trailIndex] whileTrue: [
        count = 1
            ifTrue: [delta := (trail at: count) - (trail at: trailSize)]
            ifFalse: [delta := (trail at: count) - (trail at: count - 1)].
        tempIncrement := tempIncrement + delta].
    tempIncrement := tempIncrement * (2 @ 2) //
        (trailSize @ trailSize).
    tempIncrement ~= (0@0)
        ifTrue: [
            self jumpIncrement: tempIncrement; animate].
    parent go! 
currentFrame
        "Private - Answer the current frame."
    ^frames at: index!   
nextRect
        "Private - Answer the receiver's next rectangle."
    | origin corner rect |
    goUntil > 0 ifTrue: [
        goCount := goCount + 1.
        goCount > goUntil ifTrue: [
            self caughtIt.
            goCount := goUntil := 0.
            ^0 @ 0 extent: 0 @ 0]].
    self nextFrame; move.
    origin := oldPosition min: position.
    corner := (position max: oldPosition)
        + self boundingBox extent.
    rect := origin corner: corner.
    ^rect!   
checkHit
        "Private - Answer an array of integers representing the
         border(s) hit (0=top, 1=right, 2=bottom, 3=left)."
    | answer animationBox myBox |
    animationBox := parent boundingBox.
    myBox := self boundingBox.
    answer := OrderedCollection new.
    myBox origin x <= animationBox origin x ifTrue: [
        answer add: 3].
    myBox origin y <= animationBox origin y ifTrue: [
        answer add: 2].
    myBox corner x >= animationBox corner x ifTrue: [
        answer add: 1].
    myBox corner y >= animationBox corner y ifTrue: [
        answer add: 0].
    ^answer!
frameStyle
        "Private - Answer an Integer with appropriate FCF_ bits in it."
    ^WsBorder |
    WsChild   |
    WsVisible |
    WsClipsiblings |
    WsClipchildren! 
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message."
    self erase.
    ^1!  
setScrollRanges
        "Private - Set scroll ranges."
    UserLibrary
        setScrollRange: self asParameter
        bar: SbHorz
        min: 0
        max: 0
        redraw: false.
    UserLibrary
        setScrollRange: self asParameter
        bar: SbVert
        min: 0
        max: 0
        redraw: false!