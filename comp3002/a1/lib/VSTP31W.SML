3.1.0.106
   
displayHelp
        "Private - Display the help."
    | rect xDisplay pen |
    self display3D.
    xDisplay := self font width.
    rect := xDisplay @ 0 corner: rectangle width @ ( rectangle bottom down: 2 ).
    rect := rect insetBy: 0 @ inset.
    pen:=self graphicsTool.
    pen
        displayText: helpText
        at: ( rect leftBottom rightAndUp: self font descender + 1 )
        in: rect
        options: EtoOpaque | EtoClipped
        adx: nil!  
height: anInteger
        "Set the receiver's height."
    | aFont |
    self framingBlock: [ :box |
        Rectangle leftBottom: ( box leftBottom up: 1 ) extent: box width @ anInteger ].    
    aFont := NationalLanguage isDoubleByteCp
        ifTrue: [ Font systemFont ]
        ifFalse: [
            Font new
                faceName: self class defaultFontName;
                charSize: ( 0 @ ( anInteger - ( 2 * inset ) ) );
                fixedWidth: false ].
    self font: aFont!   
updateRectangle
        "Private - Update variables depending on the actual size of the StatusPane."
    super updateRectangle.
    self isLeftJustified
        ifTrue: [ self updateRectangleLeftJustified ]
        ifFalse: [ self updateRectangleRightJustified ]!  
supportedEvents
        "Obsolete - answer the Set of events that ToolPanes can notify
         their owners about."
    self obsoleteMethod.
    ^super supportedEvents
        add: #doubleClicked;
        yourself! 
defaultFontName
        "Private - answer the name of the default font to use in instances
        of the receiver, unless otherwise specified."
    ^NationalLanguage isDoubleByteCp ifTrue: [ 'System' ] ifFalse: [ 'Helv' ]!
defaultHeight
        "Private - answer the default height in pixels for the receiver."
    ^( OperatingSystem getSystemValue: SystemValueTitleBarHeight ) + 6! 
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #doubleClicked ;
        yourself!
rightJustified
        "Set the StatusPane style.  The StatusPane boxes will be rightJustified."
    justified := #right!   
contents: aStatusBoxCollection
        "Set the receiver's contents."
    statusBoxes := aStatusBoxCollection.
    statusBoxes do: [ :each | each statusPane: self ].
    self isHandleOk ifTrue: [ self invalidateRect: nil ]!   
isStatusPane
        "Answer true if receiver is an instance of class
         StatusPane, else answer false."
    ^true!  
freeClientArea: box
        "Private - Set the client area left over."
    ( rectangle isNil or: [ self isHidden ] ) ifTrue: [ ^box ].
    box leftBottom: ( box leftBottom up: self height ).
    ^box!  
resizable
        "Set the StatusPane style.
        The left-most status box in a statusPane rightJusfied
        will be resizable.
        The right-most status box in a leftjustified statusPane
        will be resizable."
    resizable := true!
initialize
        "Private - Initialize instance variables."
    super initialize.
    colors := self sysColors.
    self backColor: Color buttonFace.
    self foreColor: Color buttonText.
    self resizable.
    self rightJustified.
    statusBoxes := OrderedCollection new.
    inset := 3.
    self height: self class defaultHeight! 
showHelp: anObject
        "Private - Set and display the help text."
    ( helpText isNil and: [ anObject isNil ] ) ifTrue: [ ^self ].
    self doGraphics: [
        helpText := anObject.
        helpText isNil
            ifTrue: [ self display ]
            ifFalse: [ self displayHelp ] ]!  
display
        "Private - Display the statusPane."
    self display3D.
    statusBoxes do: [ :each | each displayWith: self graphicsTool ]!   
colorChange
        "Private - Window's color has changed
        Set the new background and foreground color."
    colors := self sysColors.
    self backColor: Color buttonFace.
    self foreColor: Color buttonText.
    ^super colorChange!   
updateStatusBox: aStatusBox
        "Private - aStatusBox has been updated."
    self isHandleOk ifFalse: [ ^self ].
    helpText notNil ifTrue: [ ^self ].
    self doGraphics: [ aStatusBox displayWith: self graphicsTool ]!   
fixedSize
        "Set the StatusPane style.  The StatusPane boxes will be fixed size."
    resizable := false! 
button1DoubleClick: aPoint
        "Private - Left button is double clicked.
         Default is do nothing."
    self event: #doubleClicked.
    self triggerEvent: #doubleClicked!  
validate
        "Private - The window for the receiver was
        just created or recreated."
    | newColors |
    super validate.
    helpText := nil.
    newColors := self sysColors.
    newColors = colors ifFalse: [ self colorChange ].
    self isVisible ifTrue: [ self showWindow ]! 
isResizable
        "Answer true if the receiver is left justified, else answer false."

    ^resizable!   
sysColors
        "Private - Answer system colors for StatusPane."
    ^( Array new: 2 )
        at: 1 put: Color buttonFace;
        at: 2 put: Color buttonText;
        yourself! 
isRightJustified
        "Set the StatusPane style - The StatusPane boxes will be rightJustified."
    ^justified = #right! 
updateSliders
        "Private - Reimplemented here because StatusPane
         have no scrollbars."!   
contents
        "Answer the receiver's contents,
        i.e., a collection of statusBox objects."
    ^statusBoxes!  
inset
        "Answer the receiver's inset.
        The height of a StatusBox is the height
        of the statusPane minus two times the inset."
    ^inset! 
inset: anInteger
        "Set the receiver's inset.
        The height of a StatusBox is the height
        of the statusPane minus two times the inset."
    inset := anInteger! 
leftJustified
        "Set the StatusPane style.  The StatusPane boxes will be leftJustified."
    justified := #left!  
isLeftJustified
        "Answer true if the receiver is left justified, else answer false."
    ^justified = #left! 
statusBoxAt: aSymbol
        "Answer the first statusBox with the name aSymbol."
    ^statusBoxes detect: [ :each | each name = aSymbol ] ifNone: [ nil ]!  
updateRectangleLeftJustified
        "Private - Update variables depending on the actual size of the StatusPane."
    | xLeft rect box2 |
    statusBoxes isEmpty ifTrue: [ ^self ].

    xLeft := 0.
    statusBoxes do: [ :box |
        xLeft := xLeft right: box space.
        rect := xLeft @ 0 corner: ( xLeft + box width + 6 ) @ ( rectangle bottom down: 2 ).
        rect := rect insetBy: 0 @ inset.
        box rectangle: rect.
        xLeft := xLeft right: box width + 6 ].

    self isResizable ifFalse: [ ^self ].

    box2 := statusBoxes last.
    xLeft := xLeft left: box2 width + 6.
    rect := xLeft @ 0 corner: ( self rectangle width left: box2 space ) @ ( rectangle bottom down: 2 ).
    rect := rect insetBy: 0 @ inset.
    box2 rectangle: rect!  
updateRectangleRightJustified
        "Private - Update variables depending on the actual size of the StatusPane."
    | xLeft rect box2 |
    statusBoxes isEmpty ifTrue: [ ^self ].

    xLeft := self rectangle width - statusBoxes first space.
    statusBoxes reverseDo: [ :box |
        xLeft := xLeft left: box width + 6.
        rect := xLeft @ 0 corner: ( xLeft + box width + 6 ) @ ( rectangle bottom down: 2 ).
        rect := rect insetBy: 0 @ inset.
        box rectangle: rect.
        xLeft := xLeft left: box space ].

    self isResizable ifFalse: [ ^self ].

    box2 := statusBoxes first.
    xLeft:= xLeft right: box2 space.
    xLeft:= xLeft right: box2 width + 6.
    rect := ( box2 space @ 0 ) corner: xLeft @ ( rectangle bottom down: 2 ).
    rect := rect insetBy: 0 @ inset.
    box2 rectangle: rect!   
displayText: aString with: aPen
        "Private - Display the given string in the bounds of the receiver using aPen."
    | rcDraw string |
    rectangle isNil ifTrue: [ ^self ].
    ( rectangle right isLeftEqualOf: rectangle left ) ifTrue: [ ^self ].
    ( state and: [ aString notNil ] )  "is hidden?"
        ifTrue: [ string := aString isString ifTrue: [ aString ] ifFalse: [ aString printString ] ]
        ifFalse: [ string := '' ].

    rcDraw := rectangle.
    rcDraw := rcDraw insetBy: 1@1.
    aPen
        displayText: string
        at: ( rcDraw leftBottom rightAndUp: ( 1 @ ( aPen font descender + 1 ) ) )
        in: rcDraw
        options: EtoOpaque | EtoClipped
        adx: nil!  
display3D
        "Private - Display the 3D background of the receiver."
    | rect aPen oldForeColor |
    aPen := self graphicsTool.
    rect := self rectangle.
    oldForeColor := aPen foreColor.
    aPen
        fill: Color buttonFace;
        down;
        foreColor: Color buttonText;
        place: ( rect leftTop leftAndDown: 1@0 ); goto: ( rect rightTop down: 0 );
        foreColor: Color buttonHighlight;
        place: ( rect leftTop leftAndDown: 1@1 ); goto: ( rect rightTop down: 1 );
        foreColor: oldForeColor;
        up! 
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
     ^WsChild |
     WsClipchildren |
     WsClipsiblings!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
name
        "Answer the statusBox name.  A StatusBox's name is established by
         sending the 'name:' message to the statusBox."

    ^name!
name: aSymbol
        "Set the statusBox name to aSymbol
         which can be a Symbol or a String."

    name := aSymbol!   
rectangle
        "Private - Answer the receiver's rectangle."

    ^rectangle!
rectangle: aRectangle
        "Private - Set the receiver's rectangle."

    rectangle := aRectangle!  
displayWith: aPen
        "Private - Display itself with aPen."
    | rcDraw |
    rectangle isNil ifTrue: [ ^self ].
    ( rectangle right isLeftEqualOf: rectangle left ) ifTrue: [ ^self ].

    rcDraw := rectangle.
    aPen fill: ( Rectangle leftBottom: ( rcDraw leftBottom up: 1 ) rightTop: ( rcDraw leftTop right: 1 ) )
        color: Color buttonShadow.
    aPen fill: ( Rectangle leftTop: ( rcDraw leftTop right: 1 ) rightBottom: ( rcDraw rightTop down: 1 ) )
        color: Color buttonShadow.
    aPen fill: ( Rectangle leftBottom: rcDraw leftBottom rightTop: ( rcDraw rightBottom up: 1 ) )
        color: Color buttonHighlight.
    aPen fill: ( Rectangle leftBottom: ( rcDraw rightBottom left: 1 ) rightTop: ( rcDraw rightTop left: 2 ) )
        color: Color buttonHighlight.

    self displayText: contents with: aPen!  
space
        "Answer the receiver's offset in
        pixel units.
        An offset specifies the distance between a box and the previous one."

    ^space!   
space: anInteger
        "Set the receiver's offset to
        anInteger pixel units.
        An offset specifies the distance between a box and the previous one."

    space := anInteger! 
statusPane
        "Private - Answer the receiver's statusPane."

    ^statusPane! 
width
        "Answer the receiver's width in pixel units."

    ^width!   
initialize
        "Private - Initialize the receiver."

    state := true.
    space := 0.
    width := 0.! 
width: anInteger
        "Set the receiver's width. anInteger is in pixel units."

    width := anInteger! 
show: aBoolean
        "Show the receiver's contents if aBoolean is true, else
        hide the receiver's contents."

    state := aBoolean.
    self statusPane notNil
        ifTrue:[self statusPane updateStatusBox: self].!   
contents
        "Answer the receiver's contents."

    ^contents! 
contents: anObject
        "Set the receiver's contents and update the statusPane."

    contents := anObject.
    self statusPane notNil
        ifTrue:[self statusPane updateStatusBox: self].!   
statusPane: aStatusPane
        "Private - Set the receiver's statusPane."

    statusPane := aStatusPane! 
windowClass
    "private- answer the receiver's window class"
    "Same class used for all TopPane"
    | className wndClass address answer |
    className := 'SmalltalkV',self class name.
    wndClass := WinWindowClass new.
    answer := UserLibrary getClassInfo: OperatingSystem hInstanceExe
        className: className asParameter
        wndClass: wndClass asParameter.
    answer ifTrue: [ ^className ].
    UserLibrary getClassInfo: OperatingSystem hInstanceExe
        className: super windowClass asParameter
        wndClass: wndClass asParameter.
    address := ExternalAddress copyToNonSmalltalkMemory: className asAsciiZ.
    wndClass style:CsDblclks.
    (self isRightJustified or:[self isResizable])
            ifTrue:[wndClass style: CsDblclks | CsHredraw].
    wndClass hIcon: 0;
        hBrush: ( GDILibrary getStockObject: WhiteBrush );
        className: address asParameter.
    UserLibrary registerClass: wndClass asParameter.
    address free.
    ^className!