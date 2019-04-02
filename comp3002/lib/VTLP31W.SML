3.1.0.106
   
isToolPane
        "Answer whether the receiver is a ToolPane."
    ^false! 
display
        "Private - Display its contents."
    toolsBitmap isNil ifTrue: [ self setContents ].  
    buttonState := false.
    graphicsTool copyBitmap: toolsBitmap from: toolsBitmap boundingBox at: 0@0! 
windowClass
    "Private- answer the receiver's window class"

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
    address := ExternalAddress copyToNonSmalltalkMemory: className asParameter.
    wndClass style:CsDblclks.
    wndClass hIcon: 0;
        hBrush: ( GDILibrary getStockObject: WhiteBrush );
        className: address asParameter.
    UserLibrary registerClass: wndClass asParameter.
    address free.
    ^className!   
fromBitmap: aBitmap
        "Answer a new tool. aFileName is a .BMP file name."

    ^self new fromBitmap: aBitmap!
new
		"Answer a new instance of the receiver."
	^super new initialize!  
defaultExtent
        "Private - Answer the default height/width of a tool."
    ^25 @ 22!  
fromFile:aFileName
        "Answer a new tool. aFileName is a .BMP file name."

    ^self new fromFile:aFileName!  
fromModule:aFileName id:aString
        "Answer a new tool. aFileName is a DLL file name.
        aString is a BITMAP name in this DLL."
    ^self new fromModule:aFileName id:aString!
selector: aSymbol
        "Set the receiver's selector. It can be either
        aSymbol or a message."
    selector := aSymbol!   
sysColors
        "Private - Answer the System colors for push button."
    ^Dictionary new
        at: 4 put: Color buttonText;
        at: 8 put: Color buttonShadow;
        at: 9 put: Color buttonFace;
        "at: 16 put: self class colorButtonHighlight;"
        yourself!  
bitmap
        "Answer the bitmap for the receiver."
	^bitmap!  
name
        "Answer the tool name.  Tool's name is established by
         sending the 'name:' message to the tool."
    ^name!   
name: aSymbol
        "Set the tool name to aSymbol
         which can be a Symbol or a String."
    name := aSymbol!  
rectangle
        "Private - Answer the receiver's rectangle."
    ^rectangle!  
owner
        "Answer the receiver's owner."
    ^owner!
owner: anOwner
        "Set the receiver's owner."
    owner := anOwner!
rectangle: aRectangle
        "Private - Set the receiver's rectangle."
    rectangle := aRectangle!
fromBitmap: aBitmap
        "Set the receiver's bitmap."
    bitmap := aBitmap! 
space
        "Answer the receiver's offset in pixel unit."
    ^space! 
space: anInteger
        "Set the receiver's offset to anInteger
        pixel units.
        An offset specifies the distance between a tool and the previous one."
    space := anInteger!  
initialize
        "Private - Initialize the receiver's instance variable."
    extent := self defaultExtent!   
defaultExtent
        "Private - Answer the default height/width of the receiver's tools."
    ^self class defaultExtent!   
extent
        "Answer the receiver's extent."
    ^extent! 
fromModule:aFileName id:bitmapId
        "Set the receiver's bitmap."
    bitmap := self bitmapClass fromModule: aFileName id: bitmapId!
selector
        "Answer the receiver's selector."
    ^selector!   
extent: aPoint
        "Set the receiver's extent."
    extent := aPoint!   
fromFile: aFileName
        "Set the receiver's bitmap."
    bitmap := self bitmapClass fromFile: aFileName!
colorChange
        "Private - do nothing for now."! 
supportedEvents
        "Obsolete - answer the Set of events that ToolPanes can notify
         their owners about."
    self obsoleteMethod.
    ^super supportedEvents
        remove: #childClicked;
        add: #doubleClicked;
        yourself! 
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
   ^super constructEventsTriggered
        add: #doubleClicked ;
        yourself!   
isToolPane
        "Answer true if receiver is an instance of class
         ToolPane, else answer false."
    ^true!  
contents: aToolCollection
        "Set the receiver's contents.
        aToolCollection is a collection of Tool objects."
    tools := aToolCollection.
    self isHandleOk ifTrue: [
        self setContents.
        self invalidateRect: nil ]! 
freeClientArea: box
    "Private - Set the client area left over."
    self isHidden ifTrue: [ ^box ].
    box leftTop: ( box leftTop down: self height + 1 ).
    ^box!  
contextForItem:aTool
        "Private - The user has clicked a tool
        Answer its context."
    | helpOwner key selector |
    self statusPane isNil ifTrue: [ ^nil ].
    aTool selector isNil ifTrue: [ ^nil ].
    selector := aTool selector.
    selector isMessage
        ifTrue: [
            key := selector selector.
            helpOwner := selector receiver ]
        ifFalse: [
            helpOwner := aTool owner.
            key := aTool selector ].
    helpOwner isNil ifTrue: [ ^nil ].
    key := key asString.
    ^Association key: key value: helpOwner!   
aboutToSaveImage
        "Private - Save the essential information
         so that the image can be restarted.
         Default is do nothing."
    toolsBitmap notNil ifTrue: [ toolsBitmap release ].
    toolsBitmap := nil.
    super aboutToSaveImage!
button1Up:aPoint
        "Private - Left button is pressed up."
    | found |
    buttonPressed isNil ifTrue: [ ^self ].
    ( buttonPressed rectangle containsPoint:aPoint )
        ifTrue: [ found := true ]
        ifFalse: [ found := false ].
    clickState := false.
    self clearMouseCapture.
    buttonState ifTrue: [
        buttonState := false.
        self doGraphics: [ self drawTool: buttonPressed ] ].
    found ifTrue: [ self performSelector: buttonPressed ].
    buttonPressed := nil.
    self eraseHelp! 
setColorChange
        "Private - Window's color has changed.
        Set the new background color "
    colors := self sysColors.
    self backColor: Color buttonFace.
    tools do: [ :each | each colorChange ]! 
height: anInteger
        "Set the receiver's height."
    | cxBorder cyBorder screenWidth |
    cxBorder := OperatingSystem getSystemValue: SystemValueWindowBorderWidth.
    cyBorder := OperatingSystem getSystemValue: SystemValueWindowBorderHeight.
    screenWidth := Display width + ( 2 * cxBorder ).
    self framingBlock: [ :box |
        Rectangle
            leftTop: ( box leftTop leftAndUp: cxBorder @ cyBorder )
            extent: screenWidth @ anInteger ]!  
toolUnderCursor
        "Answer the tool under the cursor."
    ^self toolUnder: ( Cursor sense mapToWindow: self )!
initialize
        "Private - Initialize the receiver."
    super initialize.
    tools := OrderedCollection new.
    self height: self class defaultHeight.
    self backColor: Color buttonFace.
    colors := Array new: 4!  
showHelp: aTool
        "Private - The use has clicked a tool
        Show the help."
    | help context |
    self helpEnabled ifFalse: [ ^self ].
    context := self helpContext.
    context isNil ifTrue: [ ^self ].
    help := context value statusPaneHelp: context key.
    help isNil ifTrue: [ ^self ].
    self statusPane showHelp: help!   
help: aBoolean
        "Display hints when aBoolean is true, else do nothing
        when a button is pressed."
    self propertyAt: #help put: aBoolean!  
colorChange
        "Private - Window's color has changed.
        Set the new background color and create the bitmaps."
    self setColorChange.
    self makeToolsBitmap.
    ^super colorChange!  
toolAt: toolSymbol
        "Answer the first tool with the name toolSymbol."
    ^tools detect: [ :each | each name = toolSymbol ] ifNone: [ nil ]! 
getButtonPressedUnder: aPoint
        " Private - identify the button being pressed. "
    ^buttonPressed := self toolUnder: aPoint!
drawTool:aTool
        "Private - Display the bitmap's tool depending on its state."
    aTool isNil ifTrue: [ ^self ].
    self buttonState
        ifTrue: [ aTool displayToolDownWith: graphicsTool ]
        ifFalse: [ aTool displayToolUpWith: graphicsTool ]! 
button1DoubleClick: aPoint
        "Private - Notify the owner that the user has double clicked."
    self event: #doubleClicked.
    self triggerEvent: #doubleClicked!   
validate
        "Private - The window for the receiver was
       just created or recreated."
    super validate.
    self setColorChange.
    self setContents.
    self isVisible ifTrue: [ self showWindow ]!   
setContents
        "Private - Set the receiver's contents."
    | leftTopPoint i space |
    i := 0.
    space := 0.
    self height = 0 ifTrue: [ ^nil ]. "receiver does not have size yet, set contents later."
    self contents do: [ :each |
        each space notNil ifTrue: [ space := space + each space ].
        leftTopPoint := ( i * ( each extent x left: 1 ) ) + space @
            ( self boundingBox top down: ( self height - each extent y // 2 ) rounded ).
        each rectangle: ( leftTopPoint extentFromLeftTop: each extent ).
        i := i + 1 ].
    colors := self sysColors.
    self makeToolsBitmap!
performSelector: aTool
		"Private - The user has clicked a tool; perform its selector."
    | anAction |
    ( anAction := aTool selector ) isNil ifTrue: [ ^self ].
    anAction isSymbol
        ifTrue: [
            aTool owner notNil
                ifTrue: [ aTool owner perform: anAction ] ]
        ifFalse: [ anAction evaluate ]!   
sysColors
        "Private - Answer system colors for push buttons."
    ^( Array new: 4 )
        at: 1 put: Color buttonText;
        at: 2 put: Color buttonShadow;
        at: 3 put: Color buttonFace;
        yourself!   
helpEnabled
        "Private - answer whether help is supported."
    ^self propertyAt: #help ifAbsent: [ true ]!   
toolUnder: aPoint
        "Private - answer the tool under aPoint."
    ^tools detect: [ :aTool | aTool rectangle containsPoint: aPoint ] ifNone: [ nil ]!  
button1Move:aPoint
        "Private - Left button is down while the mouse
         is moving. Display the help text in the status bar if any."
    | found |
    buttonPressed isNil ifTrue: [ ^self ].
    ( buttonPressed rectangle containsPoint: aPoint )
        ifTrue: [ found := true ]
        ifFalse: [ found := false ].
    found = buttonState ifTrue: [ ^self ].
    buttonState := found.
    self doGraphics: [ self drawTool: buttonPressed ]!
buttonState
        "Private - Answer the receiver's buttonState."
    ^buttonState!
buttonState: aBoolean
        "Private - Set the receiver's buttonState."
    buttonState := aBoolean!  
close
        "Private - Reimplemented here to release the bitmaps."
    | answer |
    answer := super close.
    toolsBitmap notNil ifTrue: [ toolsBitmap release ].
    ^answer!  
contents
        "Answer the receiver's contents, i.e.
        a collection of Tool objects."
    ^tools!  
eraseHelp
        "Private - a tool has been deselected
        Erase the help text."
    self statusPane isNil ifTrue: [ ^self ].
    self statusPane showHelp: nil! 
makeToolsBitmap
        "Private - Create a bitmap with all the tools."
    | aPen |
    toolsBitmap notNil ifTrue: [ toolsBitmap release ].
    toolsBitmap := Bitmap screenExtent: Display width @ self height.
    aPen := toolsBitmap pen.
    aPen backColor: Color buttonFace.
    aPen erase.
    tools do: [ :each | each displayToolUpWith: aPen ]!  
button1Down:aPoint
        "Private - Left button is pressed down."
    buttonPressed := self getButtonPressedUnder: aPoint.
    buttonPressed isNil
        ifTrue: [ ^super button1Down: aPoint ].
    self helpContext: ( self contextForItem: buttonPressed ).
    ( self helpManager notNil and: [ self helpManager helpMode ] ) ifTrue:[
        self helpManager displayHelp: self helpContext key.
        buttonPressed := nil.
        ^self ].
    buttonState := true.
    clickState := true.
    self captureMouseInput.
    self doGraphics: [ self drawTool: buttonPressed ].
    self showHelp: buttonPressed! 
bitmapClass
        "Private - answer the preferred Bitmap class."
    ^DIB!
displayToolDownWith: aPen
        "Private - Display the tool down bitmap with aPen."
    bitmap isDIB ifTrue: [
        bitmap
            displayWith: aPen
            from: ( ( 0@0 right: self extent x ) extent: self extent )
            to: ( self rectangle origin extent: self extent ) ].

    bitmap isBitmap ifTrue:[
        aPen
            copyBitmap: bitmap
            from: ( ( 0@0 right: self extent x ) extent: self extent )
            at: self rectangle origin ]!   
defaultHeight
        "Private - answer the default height in pixels for the receiver."
    ^Tool defaultExtent y + 10! 
displayToolUpWith: aPen
        "Private - Display the tool up bitmap with aPen."
    bitmap isDIB ifTrue: [
        bitmap
            displayWith: aPen
            from: ( 0@0 extent: self extent )
            to: ( self rectangle origin extent: self extent ) ].

    bitmap isBitmap ifTrue: [
        aPen
            copyBitmap: bitmap
            from: ( 0@0 extent: self extent )
            at: self rectangle origin ]!
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
     ^WsChild |
     WsClipsiblings |
     WsBorder!