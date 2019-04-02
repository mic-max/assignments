3.1.0.106
   
buildView: view forModel: aCoordinator
    "Private"
    "Create the structure of the <aCoordinator> within the given <view>."

    | horizontalMargin verticalMargin labelHeight font row left |
    verticalMargin := 6.
    horizontalMargin := 6.
    font := SysFont.
    labelHeight := (WindowDialog inDialogUnits: 0 @ font height) y * 3 // 2.

        "Bullet style"
    left := horizontalMargin +  (WindowDialog inDialogUnits: ( font stringWidth: 'Alignment:') + ( 2 * font width ) @ 0) x.
    view addPane: (CheckBox new
        label: 'Bullet style';
       setName: #bullet;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: verticalMargin;
                leftInset: horizontalMargin;
                bottomInset: (verticalMargin + labelHeight) negated;
                rightInset: horizontalMargin)).

        "Indentation - left, right, first line"
    row := verticalMargin + ( 3 * labelHeight // 2 ).
    view addPane: (GroupBox new
        label: 'Indentation (inches)';
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: horizontalMargin - 4;
                bottomInset: (row + ( labelHeight * 6)) negated;
                rightInset: horizontalMargin - 4)).
    row := row +  ( 3 * labelHeight // 2 ).
    view addPane: (StaticText new
        contents: 'Left:';
        font: font;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: (row + labelHeight) negated;
                rightInset: left negated)).
    view addPane: (EntryField new
       setName: #left;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: left;
                bottomInset: (row + labelHeight) negated;
                rightInset: horizontalMargin)).
    row := row +  ( 3 * labelHeight // 2 ).
    view addPane: (StaticText new
        contents: 'Right:';
        font: font;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: (row + labelHeight) negated;
                rightInset: left negated)).
    view addPane: (EntryField new
       setName: #right;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: left;
                bottomInset: (row + labelHeight) negated;
                rightInset: horizontalMargin)).
    row := row +  ( 3 * labelHeight // 2 ).
    view addPane: (StaticText new
        contents: 'First line:';
        font: font;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: (row + labelHeight) negated;
                rightInset: left negated)).
    view addPane: (EntryField new
       setName: #firstLine;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: left;
                bottomInset: (row + labelHeight) negated;
                rightInset: horizontalMargin)).

        "Alignment"
    row := row +  ( 2 * labelHeight ).
    view addPane: (StaticText new
        contents: 'Alignment:';
        font: font;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: (row + labelHeight) negated;
                rightInset: left negated)).
    view addPane: (DropDownList new
       setName: #alignment;
        contents: ( Array with: 'left' with: 'right' with: 'center' );
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: left;
                bottomInset: (6 * labelHeight + row) negated;
                rightInset: horizontalMargin)).

    row := row +  ( 2 * labelHeight ).
    view addPane: (Button new
        label: 'OK';
        defaultPushButton;
        when: #clicked send: #paragraphFormatOK: to: aCoordinator with: view;
        when: #clicked send: #close to:view;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: ( row + labelHeight) negated;
                rightInset: left negated )).
    view addPane: (Button new
        label: 'Cancel';
        when: #clicked send: #close to:view;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: left + 5;
                bottomInset: ( row + labelHeight) negated;
                rightInset: ( left + 5 + left ) negated)).
    view
        initialSize:
            (( left * 5 // 2 ) @ ( row +  ( 2 * labelHeight ) ) )
                * WindowDialog dialogUnit / WindowDialog unitMultiplier;
        labelWithoutPrefix: 'Paragraph format'!   
openOn: paraInfo
    "Open a paragraph format dialog
    with initial information <paraInfo>.  When the
    result of the dialog is accepted by the user, <aMessage>
    will be performed with a Dictionary of paragraph information."

    | coordinator view |
    view := self constructViewFor: ( coordinator := self new ).
    view children do: [:pane |
        ( pane name size > 0 and: [ pane respondsTo: #value: ] ) ifTrue: [
            pane value: ( paraInfo at: pane name ) ] ].
    view open.
    ^ coordinator
!   
paragraphFormatOK: aView
    "Private - OK button pressed."

    result := Dictionary new.
    aView children do: [:pane |
        ( pane name size > 0 and: [ pane respondsTo: #value ] ) ifTrue: [
            result at: pane name put: ( pane value ) ] ].
!   
result
    " Answer a Dictionary as the result
    of user input."

    ^ result
!   
sizeInBytes
    ^60! 
cbSize: size
	"Private - Set the size of the font to <size>."
    self uLongAtOffset: 0 put: size!  
dwMask
        "Answer the mask CfmBold, CfmColor, CfmFace, CfmItalic, CfmOffset, CfmProtected,
        CfmSize, CfmStrikeout, or CfmUnderline."
    ^ self uLongAtOffset: 4!  
dwMask: aMask
        "Set the mask to CfmBold, CfmColor, CfmFace, CfmItalic, CfmOffset, CfmProtected,
        CfmSize, CfmStrikeout, or CfmUnderline."
    self uLongAtOffset: 4 put: aMask!  
bCharSet: aByte
	"Private - Set the char set to <aByte>."
    self byteAtOffset: 24 put: aByte! 
bPitchAndFamily
	"Private - Answer the pitch and family of the font."
    ^self byteAtOffset: 25!   
bPitchAndFamily: aByte
        "Private - Set the lfPitchAndFamily field
        to FixedPitch, or VariablePitch."
    self byteAtOffset: 25 put: aByte asParameter!   
dwEffects
        "Private - Answer the effect CfeAutocolor, CfeBold, CfeItalic, 
		CfeStrikeout, CfeUnderline, or CfeProtected."
    ^ self uLongAtOffset: 8! 
dwEffects: effects
        "Private - Set the effect to CfeAutocolor, CfeBold, CfeItalic, 
		CfeStrikeout, CfeUnderline, or CfeProtected."
    self uLongAtOffset: 8 put: effects! 
szFaceName
         "Private - Set the szFaceName field."
    | string |
    string := String new: self class sizeInBytes - 26 - 1.
    26 to: self class sizeInBytes - 2 do: [ :i |
        string at: i - 25 put: ( self byteAtOffset: i ) asCharacter ].
    ^ string trimBlanks!
szFaceName: aString
         "Private - Set the szFaceName field."
   1 to: aString size do:
     [ :i | self byteAtOffset: (26 + i - 1) put: (aString at: i) asciiValue ].
   ( aString size + 26 ) to: contents size - 1 do:
     [ :i | self byteAtOffset: i put: 0 ].!   
yOffset: anInteger
        "Private - Set Character offset to <anInteger>."
    self longAtOffset: 16 put: anInteger!   
crTextColor: aColor
	"Private - Set text color to <aColor>."
    self byteAtOffset: 20 put: aColor red;
        byteAtOffset: 21 put: aColor green;
        byteAtOffset: 22 put: aColor blue!
asFont
	"Answer the font represented by the receiver."
    | aFont effects |
    aFont := Font
        face: self szFaceName
            size: self yHeight // 20
            fixedWidth:  ( self bPitchAndFamily = 0 )
            attributes: 0.
    effects := self dwEffects.
    aFont
        bold: ( effects bitAnd: CfeBold ) > 0;
        italic:  ( effects bitAnd: CfeItalic ) > 0;
        strikeOut:  ( effects bitAnd: CfeStrikeout ) > 0;
        underscore:  ( effects bitAnd: CfeUnderline ) > 0.
    ^ aFont!
initialSize: size
	"Private - Set the size of the structure."
    super initialSize: size.
    self cbSize: self class sizeInBytes!
yHeight
        "Private - Answer Character height."
    ^ self longAtOffset: 12!   
yHeight: anInteger
        "Private - Set Character height to <anInteger>."
    self longAtOffset: 12 put: anInteger!   
sizeInBytes
    ^ 48!
hdc: aHandle
    "Private - set the device to render to."
    self uLongAtOffset: 0 put: aHandle asParameter!   
chrg: charRange
    "Private - set the range of text to the Point <charRange>."

	self bytesAtOffset: 40 put: ( WinPoint fromPoint: charRange ) asParameter!   
hdcTarget: aHandle
    "Private - set the target device to format for."
    self uLongAtOffset: 4 put: aHandle asParameter! 
rc: aRect
    "Private - set the area to render to."

	self bytesAtOffset: 8 put: ( WinRectangle fromRectangle: aRect ) asParameter!   
rcPage: aRect
    "Private - set the entire area of the rendering device."

	self bytesAtOffset: 24 put: ( WinRectangle fromRectangle: aRect ) asParameter!
formatMenu
	"Answer a menu providing all the text formatting functions."

    ^Menu new
        title: 'F\uormat' replaceEscapeCharacters;
        appendItem: '\uFont...' replaceEscapeCharacters selector: #changeFont;
        appendItem: '\uColor...' replaceEscapeCharacters selector: #changeColor;
        appendItem: '\uParagraph...' replaceEscapeCharacters selector: #changeParagraph;
        appendItem: '\uTabs...' replaceEscapeCharacters selector: #changeTabs;
        appendItem: '\uIncrease size' replaceEscapeCharacters selector: #growTextLimit;
        yourself!
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #fileException:
            #modifiedIsTrue
             );
         yourself! 
popupMenu
        "Private - Answer the popup Menu for the receiver."

    ( self owner isPARTSApplication
    or: [ self owner isPARTSEditor ] )
        ifTrue: [^nil].

    ^super popupMenu!   
fileOutOn: aFileStream
	"Write the pane data out on <aFileStream> in rich text format."

	self fileOutOn: aFileStream format: SfRtf!   
windowClass
	"Private-external"
	"Answer the Window class."

	"There is no pool var for Richedit class name"
    ^'Richedit'!
getSelection
        "Private - gets the starting and ending character positions
        of the current selection of the entry field.  The result is
        stored in the selection instance variable, and is a Point
        indicating the first selected character and the last selected
        character.  Indices are one-based."
    | winPoint aPoint |
    winPoint := WinPoint new.
    UserLibrary
        sendMessageInt: handle
        msg: EmExgetsel
        wparam: 0
        lparamStruct: winPoint asParameter.
    aPoint := winPoint asPoint.
    ^ selection := ( aPoint x + 1 ) @ ( aPoint y )
!   
growTextLimit
	"Increase the text limit by 32K bytes."

	Terminal bell.  "feedback for growing"
	self setTextLimit: ( self getTextLimit + 32768 )!
backColor: aColor
    "Set back ground color to <aColor>. Set
    to default color if <aColor> is nil."

	super backColor: aColor.
	self isValid ifTrue: [
		UserLibrary
			sendMessage: handle
			msg: EmSetbkgndcolor
			wparam: ( aColor isNil ifTrue: [ 1 ] ifFalse: [ 0 ] )   "1 means default sys color"
			lparam: ( aColor isNil ifTrue: [ 0 ] ifFalse: [ aColor asRGBColor asInteger ] ) ]!
findSearchString
	"Private - do a pattern match on the receiver's current
         text, according to the current settings of the receiver class
         (SearchString, Forward, & CaseSensitive).  Answer a Point
         describing the (start,end) location of the found match,
         or nil if no match found."

	| toSelect pattern matchBlock startIndex |
	CursorManager execute
		changeFor:
			[self getSelection. "set selection inst var"
			startIndex := Forward
				ifTrue:
					[(selection x + (selection y < selection x
						ifTrue: [0]
						ifFalse: [1])) max: 1]
				ifFalse:
					[(selection y - (selection y < selection x
						ifTrue: [0]
						ifFalse: [1])) max: 1].
			self getText. "set value inst var"
			toSelect := Forward
				ifTrue:
					[self
							findText: SearchString
							range: startIndex @ -1
							matchCase: CaseSensitive
							wholeWord: false]
				ifFalse:
					[pattern := Pattern new: SearchString asLowerCase.
					matchBlock := [:char |
					char asLowerCase].
					pattern
							matchBackward: value
							index: startIndex
							each: matchBlock]].
	^toSelect! 
selectedItem
    "Answer a String containing the
    text selected in clipboard format."

    | aString |
    self getSelection.
    aString := String new: ( selection y - selection x + 1 ).
    UserLibrary
        sendMessageInt: handle
        msg: EmGetseltext
        wparam: 0
        lparamStruct: aString asParameter.
    ^aString
!  
changeColor
	"Bring up the color dialog and
	set the selected characters to
	the selected color."

    | dialog newColor |
    dialog := ColorDialog new
        openOn: Color black.
    newColor:= dialog chosen.
    newColor notNil
        ifTrue: [
            ^ self setCharColor: newColor ]
        ifFalse: [ ^self ]. "Canceled or same color "!  
clear
        "Clear the contents of the receiver."
    self deleteAll;
		modified: false.!
contents: aStreamOrString
    "Set contents to formatted text from <aStreamOrString>."

    ^ self formattedContents: aStreamOrString
!   
fileOutCallback: cookie buffer:buffer size:bufferSize bytesWritten: bytesPointer
    "Private - Callback routine for file out."

    | bytesWritten aStream aString |
    bytesWritten := ExternalLong new.
	aStream := cookies at: cookie.
	aStream isFileStream
		ifTrue: [
		    ( KernelLibrary
		        writeFile: aStream file fileId asParameter
		        bufferAddress: buffer
		        bytesToWrite: bufferSize
		        bytesWritten: bytesWritten
		        overlapped: nil )
					ifFalse: [ ^ 1 ].
		    ExternalAddress copyFrom: bytesWritten asParameter 
				to: (  ExternalAddress fromInteger: bytesPointer ) count: 4 ]
		ifFalse: [
			aString := String new: bufferSize.
			ExternalAddress copyFrom: (  ExternalAddress fromInteger: buffer ) 
				to: aString count: bufferSize.
			aStream nextPutAll: aString.
		     ExternalAddress copyFrom: ( ExternalLong fromInteger: aString size ) asParameter 
				to: (  ExternalAddress fromInteger: bytesPointer ) count: 4
			].
    ^ 0
!   
setParagraphFormat: aParaFormat
    "Private - Send a system message to set
    the paragraph format for the currently
    selected paragraphs."

    ( UserLibrary
            sendMessage: self handle
            msg: EmSetparaformat
            wparam: 0
            lparamStruct: aParaFormat asParameter )
            = 0 ifTrue: [ "self error: 'Set paragraph format failed'" ].
            "Note- error check fails when the cursor is at end"
!
setParagraphOffset: aNumber
    "Set indentation of the second and subquent
    lines in the paragraph relative to the starting
	indentation."

    self setParagraphFormat:
        ( WinParaFormat new
            dwMask: PfmOffset;
            dxOffset: aNumber ).
!   
aboutToSaveImage
        "Private - Save the receiver's value
        so it can be restored when the image
        is restarted."
    super aboutToSaveImage.
    self whenValid: #formattedContents: with: value.
    self whenValid: #setSelection.
!
fileInCallback: cookie buffer:buffer size:bufferSize bytesRead: bytesPointer
    "Private - Callback routine for file in."

    | bytesRead aStream aString |
    bytesRead := ExternalLong fromInteger: 0.
	aStream := cookies at: cookie.
	aStream isFileStream
		ifTrue: [
		    ( KernelLibrary
		        readFile: aStream file fileId asParameter
		        bufferAddress: buffer
		        bytesToRead: bufferSize
		        bytesRead: bytesRead asParameter
		        overlapped: nil )
		            ifFalse: [ ^ 1 ].
		    ExternalAddress copyFrom: bytesRead asParameter to: (  ExternalAddress fromInteger: bytesPointer ) count: 4 ]
		ifFalse: [
			aString := aStream next: ( bufferSize min: aStream readLimit - aStream position ).
			ExternalAddress copyFrom: aString asParameter to: (  ExternalAddress fromInteger: buffer ) count: aString size.
		     ExternalAddress copyFrom: ( ExternalLong fromInteger: aString size ) asParameter 
				to: (  ExternalAddress fromInteger: bytesPointer ) count: 4
			].
    ^ 0
!
changeTabs
    "Open the change tab dialog to
    change tab stop positions."

    | newInfo |
    newInfo := ( RichEditTabStopDialog openOn: self getTabStops ) result.
    newInfo notNil
        ifTrue: [ self setTabStops:
            ( newInfo collect: [:each | self inchToTwip: each ] ) ]

!  
getTabStops
    "Private - Answer an array of tab stop positions in inches."

    | paragraphFormat |
    paragraphFormat := WinParaFormat new.
    UserLibrary
            sendMessage: self handle
            msg: EmGetparaformat
            wparam: 0
            lparamStruct: paragraphFormat asParameter.
    ^ paragraphFormat rgxTabs collect: [:stop |
		self twipToInch: stop ]
!
wmLbuttondblclk: wordInteger with: longInteger
        "Private - Button 1 has been double clicked, use default."
    ^ nil
!  
setParagraphNumbering: aNumber
    "Private - <aNumber> can be 0 or PfnBullet."

    self setParagraphFormat:
        ( WinParaFormat new
            dwMask: PfmNumbering;
            wNumbering: aNumber ).
!   
fileTextOutOn: aFileStream
	"Write the pane data out on <aFileStream> in plain text format."

	self fileOutOn: aFileStream format: SfText! 
formattedContents
    "Answer a String containing formatted contents."

    ^ self streamContents collection
!
formattedContents: aStreamOrString
    "Set contents to formatted text from <aStreamOrString>."

    | aStream |
    aStreamOrString isNil ifTrue: [ ^ self ].
	value := aStreamOrString.
    aStreamOrString size = 0 ifTrue: [ ^ self unformattedContents: '' ].
    aStream := aStreamOrString isStream
        ifTrue: [ aStreamOrString ]
        ifFalse: [ ReadStream on: aStreamOrString ].
    self isHandleOk
        ifTrue: [ self fileInFrom: aStream ]
        ifFalse: [ self whenValid: #formattedContents: with: aStream ]
!
setTabStops: aList
	"Set tab stop positions to <aList> in twips."
	
	self propertyAt: #tabStops put: aList.
	self setParagraphFormat:
        ( WinParaFormat new 
			dwMask: PfmTabstops;
			rgxTabs: aList )!
initialText
	"Private - Answer the receiver's initial text string.
	Since RichEdit can't be set during creation time,
	answer empty string."
    ^''! 
buildWindow: parentWindow
	"Private - Create the control."

    RichEdit32DLL current.
    ^super buildWindow: parentWindow!  
recreateWindow
    "Private. Transfer data saved in the window to the value
    ivar before the window is destroyed. Otherwise, the text pane,
    after a change in style (border, scroll bars) looses it's contents."

    self getText.
    super recreateWindow.
	self contents: value!
setCharFont: aFont
	"Set the font of selected characters to <aFont>."

    | charFormat mask effects |
    charFormat :=  WinCharFormat new.
    mask := CfmFace + CfmSize + CfmBold + CfmItalic + CfmStrikeout + CfmUnderline.
    effects := 0.
    aFont bold ifTrue: [ effects := effects + CfeBold ].
    aFont italic ifTrue: [ effects := effects + CfeItalic ].
    aFont strikeOut ifTrue: [ effects := effects + CfeStrikeout ].
    aFont underscore ifTrue: [ effects := effects + CfeUnderline ].

    charFormat
        dwMask: mask;
        dwEffects: effects;
        bCharSet: aFont charSet;
        bPitchAndFamily: aFont fixedWidth;
        yHeight: aFont pointSize * 20;   "each point is 20 twips"
        szFaceName: aFont faceName.

	self setCharFormat: charFormat!  
losingFocus
        "Private - The receiver is losing focus. "
    self isReadOnly ifFalse: [
        ( self "value ~= self previousValue" modified ) ifTrue: [  "For performance reason, can't compare values"
           " ( self isOkToChangeTo: self value ) ifFalse: [ ^self ]."
            ( self hasActionForEvent: #changed: )
                ifTrue: [ self triggerChanged ].
            "self previousValue: self value" ] ].
	self triggerLosingFocus
!
unformattedContents
    "Answer a String containing unformatted contents."

    ^ super contents
!
newCookieFor: aStream
	"Private - Create a new entry in cookie for
	<aStream> and answer its number."

	cookies isNil ifTrue: [ cookies := OrderedCollection new ].
	1 to: cookies size do: [ :index |  "try to reuse the released ones."
		( cookies at: index ) isNil ifTrue: [
			cookies at: index put: aStream.
			^ index ]].
	cookies add: aStream.
	^ cookies size! 
unformattedContents: aString
    "Set contents to unformatted text from <aString>."

    ^ super contents: aString
!  
fileInFrom: aFileStream
	"Refresh the pane data with the current contents of <aFileStream> in rich text format. 
	The text limit will be increased automatically to accomodate the size of <aFileStream>. 
	If the contents of <aFileStream> is not in valid rich text format, it will be read as plain text."

	self fileInFrom: aFileStream format: SfRtf! 
fileOutOn: aStream format: format
    "Write the pane data out on <aStream> in <format>
    which can be SfText, SfRtf, SfRtfnoobjs, or SfTextized."

    | callback message editStream written cookie |
    CursorManager execute changeFor: [
	aStream isFileStream ifTrue: [
		aStream file fileId position: aStream position ].  "This is necessary since fileStream auto read first buffer"

    message := Message new
        receiver: self;
        selector: #fileOutCallback:buffer:size:bytesWritten: ;
        yourself.
    callback := CallBack
        registerMessage: message
        parameterTypes: #( #ulong #ulong #long #ulong )
        returnType: #ulong
        callingConvention: #api.
    editStream := WinEditStream new
        dwCookie:  ( cookie := self newCookieFor: aStream );
        pfnCallback: callback asParameter.

    written := UserLibrary
            sendMessage: self handle
            msg: EmStreamout
            wparam: format
            lparamStruct: editStream asParameter.

"Transcript cr; show: 'written ', written printString."
    callback release.
	self releaseCookie: cookie.
	editStream dwError = 0
		ifFalse: [ ^self error: 'Save file error: ', editStream dwError printString ].
	self modified: false.
	]!  
font: aFont
	"Do nothing since
	this will overwrite all individual font settings."! 
getParagraphFormat
    "Private - Answer a dictionary of  paragraph formats."

    | paragraphFormat |
    paragraphFormat := WinParaFormat new.
    UserLibrary
            sendMessage: self handle
            msg: EmGetparaformat
            wparam: 0
            lparamStruct: paragraphFormat asParameter.

    ^ Dictionary new
        at: #bullet put: ( paragraphFormat wNumbering ~= 0 );
        at: #left put: ( self twipToInch: ( paragraphFormat dxStartIndent + paragraphFormat dxOffset ) ) asString;
        at: #right put: ( self twipToInch: ( paragraphFormat dxRightIndent ) ) asString;
        at: #firstLine put: ( self twipToInch: ( paragraphFormat dxOffset negated ) ) asString;
        at: #alignment put: ( #('left' 'right' 'center') at: ( ( Array with: PfaLeft with: PfaRight with: PfaCenter )
            indexOf: ( paragraphFormat wAlignment ) ) );
        yourself
!  
paragraphFormatOK: aDict
    "Private - User pressed OK in the paragraph
    formator."

    | name left start bullet |
    bullet := aDict at: #bullet.
    start := self inchToTwip: (aDict at: #firstLine) asFloat.
    left := self inchToTwip: (aDict at: #left) asFloat.
    self setParagraphRightIndent: (self inchToTwip: (aDict at: #right) asFloat).
    self
        setParagraphAlignment:
            ((Array
                with: PfaLeft
                with: PfaRight
                with: PfaCenter) at: (#('left' 'right' 'center') indexOf: (aDict at: #alignment))).
    (bullet and: [(self getParagraphFormat at: #bullet) not])
        ifTrue:
            [ "bullet turned on"
            start >= 0
                ifTrue:
                    [left := left + start + (self inchToTwip: 0.25).
                    start := 0 - (self inchToTwip: 0.25)]]. "Otherwise, bullet won't show"
    self setParagraphStartIndent: left + start.
    self setParagraphOffset: start negated.
    self setParagraphToBullet: bullet.
    !  
streamContents
	"Answer a ReadWriteStream containing formatted contents."

	| answer |
	answer := ReadWriteStream on: (String new:  self getTextLength * 13 // 10). "estimate formatted text length"
	self fileOutOn: answer.
	answer position: 0.  "rewind"
	^ answer!
inchToTwip: inch
    "Private - Convert inch to twip."

    ^ ( inch * 1440 ) asInteger!   
isModified
	"Answer whether the pane has been modified.  
	Trigger the modifiedIsTrue event if so."

    self modified
        ifTrue: [
            self triggerEvent: #modifiedIsTrue.
            ^true].
    ^false!  
saveToFile: aPathName
	"Save the contents to the file named aPathName in rich text
	format. Trigger the event fileExecption: if any error is 
	encountered processing the file with <aPathName>. "

	| fileStream |
	aPathName isNil
		ifTrue: [^nil].
	[fileStream := File newFile: aPathName.
	self fileOutOn: fileStream.
	fileStream close] on: Error do: [self triggerEvent: #fileException: with: aPathName]! 
setParagraphOffsetIndent: aNumber
    "<aNumber> is added to the start of
	indentation of each paragraph selected."

    self setParagraphFormat:
        ( WinParaFormat new
            dwMask: PfmOffsetindent;
            dxStartIndent: aNumber ).
!
twipToInch: twip
    "Private - Convert twop to inch."

    ^ twip asFloat / 1440
!   
setParagraphRightIndent: aNumber
    "Set the size of the right indentation to <aNumber> which is 
	relative to the right margin."

    self setParagraphFormat:
        ( WinParaFormat new
            dwMask: PfmRightindent;
            dxRightIndent: aNumber ).
!  
defaultStyle
        "Private - Answer the default style for text edit control."

	^ super defaultStyle | EsAutovscroll!   
print
	"Open a printer dialog and print the contents
	on the selected printer."

    | dialog hDCPrinter printer |
    dialog := PrintDialog new
        noSelection;
        noPages;
        open.
    ( hDCPrinter := dialog hDCPrinter ) isNil ifTrue: [ ^self ].
    printer := Printer fromDC: hDCPrinter.

	self printOn: printer title: nil inset: ( 1 @ 1 rightBottom: 1 @ 1 ).! 
fileTextInFrom: aFileStream
	"Refresh the pane data with the current
	contents of <aFileStream> in plain text format. 
	The text limit will be increased automatically to 
	accomodate the size of <aFileStream>."

	self fileInFrom: aFileStream format: SfText!   
findText: aString range: aPoint matchCase: caseBoolean wholeWord: wordBoolean

    "Private - Find the next match of <aString>.  Select the next match.
    <aPoint> is the range containing the search.
    Answer a Point whose x coordinate is the 1 based position of
    the first matched character and y coordinate the position of
    the last matched character.  Answer nil if no match.
    Find is case sensitive if <caseBoolean> is true and the match
    has to be whole word if <wordBoolean> is true."

    | result address |
     result := UserLibrary
        sendMessage: handle
        msg: EmFindtext
        wparam: ( ( caseBoolean ifTrue: [ "FtMatchcase" 4 ] ifFalse: [ 0 ] )
            + ( wordBoolean ifTrue: [ "FtWholeword" 2 ] ifFalse: [ 0 ] ) )
        lparamStruct: ( WinPoint fromPoint: aPoint ) asParameter,
            ( address := aString copyToExternalAddress ) asParameter.
    address free.
    ^ result >= 0
        ifTrue: [ result + 1 @ (result + aString size ) ]
        ifFalse: [ nil ]! 
getTextLimit
	"Private - Answer the maximal number of characters allowed."

	^ UserLibrary
            sendMessage: self handle
            msg: EmGetlimittext
            wparam: 0
            lparam: 0
! 
printOn: aControl target: targetControl drawRect: drawRect pageRect: pageRect
    "Private - Print text on <aControl> format for <targetControl> in <drawRect>.
    And <pageRect> is the entire rectangle of <aControl> in twips."

    | textLength textPrinted formatRange |

    textLength := self getTextLength.
    formatRange := WinFormatRange new
        hdc: aControl deviceContext asParameter;
        hdcTarget: targetControl deviceContext asParameter;
        rc: drawRect;
        rcPage: pageRect;
        chrg: ( 0 @ -1 ).

    [ textPrinted := UserLibrary
            sendMessage: self handle
            msg: EmFormatrange
            wparam: true asParameter
            lparamStruct: formatRange asParameter.
    textPrinted < textLength ]
        whileTrue: [
            formatRange chrg: ( textPrinted @ -1 ).
            ( aControl isKindOf: Printer )
                ifTrue: [ aControl endPage; startPage ]
                ifFalse: [ aControl cr; cr; cr ].  "simulate form feed"
            ].
    self formatCleanUp
!   
printOn: aPrinter title: aTitle inset: insetRect
    "Print the contents on <aPrinter> with <aTitle>.
	<insetRect> specifies the four inset margins
	in inches."

    | rect |
    aPrinter startPrintJob: aTitle.

    rect := 0 @ 0 extent: (
        (( GDILibrary getDeviceCaps: aPrinter deviceContext index: Horzres ) * 1440 //
            aPrinter horizontalPixelsPerInch )
        @ (( GDILibrary getDeviceCaps: aPrinter deviceContext index: Vertres ) * 1440 //
            aPrinter verticalPixelsPerInch ) ).

	CursorManager execute changeFor: [
		self printOn: aPrinter
		target: aPrinter
		drawRect: ( rect insetBy: ( insetRect scaleBy: 1440 ) )
		pageRect: rect ].

	aPrinter endPage; 
		endPrintJob!
releaseCookie: number
	"Private - Release the slot <number> in
	cookies so that it can be reused."

	cookies at: number put: nil! 
setCharColor: newColor
	"Set the color of selected characters to <newColor>."

    | charFormat |
    charFormat := WinCharFormat new.
    charFormat
        dwMask: CfmColor;
        crTextColor: newColor.
    	self setCharFormat: charFormat!   
setParagraphStartIndent: aNumber
    "Set the size of the indentation
	in the first line of the paragraph to <aNumber>."

    self setParagraphFormat:
        ( WinParaFormat new
            dwMask: PfmStartindent;
            dxStartIndent: aNumber ).
!
setParagraphToBullet: aBoolean
	"Set paragraph to bullet style if <aBoolean> is true."

	self setParagraphNumbering: 
		( aBoolean ifTrue: [ PfnBullet ] ifFalse: [ 0 ] )

!
changeFont
	"Bring up the font dialog and
	set the selected characters to
	the selected font."

    | newFont |
    newFont := FontDialog new
        sampleFont: self getCharFormat asFont;
        open;
        chosen.
    newFont  isNil ifTrue: [ ^self ].
    self setCharFont: newFont!
validate
	"Private - The host window for the receiver was
	 just created or recreated."

	super validate.
	self backColor: self backColor "RichEdit does not use controlColor message"!  
fileInFrom: aStream format: format
        "Private - Refresh the pane data with the current
         contents of <aStream> in <format>
        which can be SfText, or SfRtf."
    | callback message editStream bytes cookie oldPosition |
    CursorManager execute changeFor: [

    self setTextLimit: ( aStream size + 32768 ).
	oldPosition := aStream position.
	aStream isFileStream ifTrue: [
		aStream file fileId position: oldPosition ].  "This is necessary since fileStream auto read first buffer"
    message := Message new
        receiver: self;
        selector: #fileInCallback:buffer:size:bytesRead: ;
        yourself.
    callback := CallBack
        registerMessage: message
        parameterTypes: #( #ulong #ulong #long #ulong )
        returnType: #ulong
        callingConvention: #api.
    editStream := WinEditStream new
        dwCookie: ( cookie := self newCookieFor: aStream );
        pfnCallback: callback asParameter.

    bytes := UserLibrary
            sendMessage: self handle
            msg: EmStreamin
            wparam: format
            lparamStruct: editStream asParameter.

"Transcript cr; show: 'read ', bytes printString."
    callback release.
	self releaseCookie: cookie.
	aStream position: oldPosition.
	editStream dwError = 0
		ifFalse: [
			( editStream dwError = -16 and: [ format = SfRtf ] )
				ifTrue: [ self fileTextInFrom: aStream. ^ self ]
				ifFalse: [ ^self error: 'Read stream error: ', editStream dwError printString ].
			].
    self modified: false.
    ]!
setTextLimit
	"Private - Set the allowed text length of the receiver to textLimit."

    UserLibrary
        sendMessage: handle
        msg: EmExlimittext
        wparam: 0
        lparam: ( self textLimit ).! 
textLimit
	"Answer the maximal number of characters allowed."

	| limit |
	( limit := super textLimit ) isNil
		ifTrue: [ ^ self getTextLimit ]
		ifFalse: [ ^ limit ]
!   
changeParagraph
    "Open the paragraph format dialog to
    change paragraph formats."

    | newInfo |
    newInfo := ( RichEditParagraphFormatDialog openOn: self getParagraphFormat ) result.
    newInfo notNil ifTrue: [
        self paragraphFormatOK: newInfo ]

!  
setTabStop
	"Private - Set the tabstop in the host control."

	self setTabStops: ( self propertyAt: #tabStops ifAbsent: [ ^ self ] )!  
getCharFormat
    "Private - Answer the current character format."

    | charFormat |
    charFormat := WinCharFormat new.
    UserLibrary
            sendMessage: self handle
            msg: EmGetcharformat
            wparam: 1
            lparamStruct: charFormat asParameter.
    ^charFormat!  
formatCleanUp
    "Private - Required house keeping after the formatting."

    UserLibrary
            sendMessage: self handle
            msg: EmFormatrange
            wparam: false asParameter
            lparam: nil.   "clean up"
! 
contents
    "Answer a String containing formatted contents."

    ^ self formattedContents
! 
setParagraphAlignment: aNumber
    "Set the paragraph alignment to <aNumber> 
	which can be PfaLeft, PfaRight, or PfaCenter."

    self setParagraphFormat:
        ( WinParaFormat new
            dwMask: PfmAlignment;
            wAlignment: aNumber ).
!
getText
        "Set the value instance variable from the host control's value.
        Assumes 'handle = NullHandle' is false."
    ^value := self contents!  
setCharFormat: aCharFormat
    "Private - Send a system message to
    set the character format for the
    currently selected characters."

    ( UserLibrary
            sendMessage: self handle
            msg: EmSetcharformat
            wparam: ScfSelection
            lparamStruct: aCharFormat asParameter )
            = 0 ifTrue: [ self error: 'Set character format failed' ].!   
setFromFile: aPathName
	" Set the contents with
        the text in the file named <aPathName>.
        Trigger the changed event. "

	| fileStream |
	aPathName isNil
		ifTrue: [^nil].
	(File exists: aPathName)
		ifFalse:
			[self triggerEvent: #fileException: with: aPathName.
			^nil].
	fileStream := File pathNameReadOnly: aPathName.
	self fileInFrom: fileStream.
	fileStream close.
	self triggerChanged.
	^aPathName!  
sizeInBytes
    ^ 28 + ( self maxTabStops * 4 )! 
maxTabStops
    "Answer the max number of tab stops
    allowed as defined in the header file."

    ^ 32!
cbSize: size
    "Private - set the number of bytes in receiver."
    self uLongAtOffset: 0 put: size!  
dwMask
        "Private - CfmBold, CfmColor, CfmFace, CfmItalic, CfmOffset, CfmProtected,
        CfmSize, CfmStrikeout, or CfmUnderline."
    ^ self uLongAtOffset: 4!
dwMask: aMask
    "Private - Set the mask on what options requested."
    ^self uLongAtOffset: 4 put: aMask!
wNumbering: aNumber
    "Private - Set numbering option - 0 for number
    or PfnBullet for bullet."
    self uShortAtOffset: 8 put: aNumber!  
dxOffset
    "Private - Answer the indentation of the second and
    subsequent lines."
    ^ self longAtOffset: 20
! 
cTabCount
    "Private - Answer the number of tab stops."

    ^ self shortAtOffset: 26!   
cTabCount: aNumber
    "Private - Set the number of tab stops."

    aNumber > self class maxTabStops
        ifTrue: [ ^self error: 'Tab stops exceeded maximum of ', self class maxTabStops printString ].
    self shortAtOffset: 26 put: aNumber!
wAlignment: aNumber
    "Private - Set the paragraph alignment: PfaLeft, PfaRight, or PfaCenter."
    self uShortAtOffset: 24 put: aNumber! 
rgxTabs
    "Private - Answer a collection of tab stop positions."

    | count startIndex array |
    count := self cTabCount.
    startIndex := 28.
	array := Array new: count.
    1 to: count do:  [ :index |
        array at: index put: ( self longAtOffset: startIndex ).
        startIndex := startIndex + 4 ].
	^ array! 
rgxTabs: aCollection
    "Private - Set tab stops to <aCollection> of positions."

    | startIndex |
    self cTabCount: aCollection size.
    startIndex := 28.
    1 to: aCollection size do:  [ :index |
        self longAtOffset: startIndex put: ( aCollection at: index ).
        startIndex := startIndex + 4 ].!   
dxRightIndent
    "Private - Answer the size of the right indentation."
    ^ self longAtOffset: 16!
dxRightIndent: aNumber
    "Private - Set the size of the right indentation."
    self longAtOffset: 16 put: aNumber!   
dxStartIndent
    "Private - Answer the indentation of the first
    line in a paragraph."
    ^ self longAtOffset: 12!
dxStartIndent: aNumber
    "Private - Set the indentation of the first
    line in a paragraph."
    self longAtOffset: 12 put: aNumber!   
wAlignment
    "Private - Answer the paragraph alignment: PfaLeft, PfaRight, or PfaCenter."
    ^ self uShortAtOffset: 24!  
dxOffset: aNumber
    "Private - Set the indentation of the second and
    subsequent lines."
    self longAtOffset: 20 put: aNumber!  
initialSize: anInteger
        "Private - initialize the contents instance variable to
        an appropriately sized ByteArray."
    super initialSize: anInteger.
    self cbSize: self class  sizeInBytes! 
wNumbering
    "Private - Answer numbering option - 0 for number
    or PfnBullet for bullet."
    ^ self uShortAtOffset: 8!   
sizeInBytes
    ^ 12!
buildView: view forModel: aTabContainer
    "Private"
    "Create the structure of the <paraFormator> within the given <view>."

    | horizontalMargin verticalMargin labelHeight buttonWidth comboBox font row column |
    verticalMargin := 6.
    horizontalMargin := 6.
	font := SysFont.
    labelHeight := (WindowDialog inDialogUnits: 0 @ font height) y * 3 // 2.
	buttonWidth := ( WindowDialog inDialogUnits: ( font width * 12 ) @ 0 ) x.

	row := verticalMargin.
    view addPane: (GroupBox new
        label: 'Tab stop position (inches)';
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: horizontalMargin - 3;
                bottomInset: (row + ( labelHeight * 8)) negated;
                rightInset: horizontalMargin - 3)).
	row := row + labelHeight.
    view addPane: (( comboBox := ComboBox new )
        removeStyle: CbsDropdown;
        addStyle: CbsSimple;
		setName: #tabStops;
        font: font;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: (row + ( labelHeight * 5 )) negated;
                rightInset: horizontalMargin )).

	"set, clear, and clear all"
	row := row +  ( 11 * labelHeight // 2 ).
	column := horizontalMargin.
    view addPane: (Button new
        label: 'Set';
        when: #clicked send: #setAStop: to: aTabContainer with: comboBox;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: column;
                bottomInset: ( row + labelHeight) negated;
                rightInset: ( column + buttonWidth ) negated )).
	column := column + buttonWidth + ( horizontalMargin // 2 ).
    view addPane: (Button new
        label: 'Clear';
        when: #clicked send: #clearAStop: to: aTabContainer with: comboBox;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: column;
                bottomInset: ( row + labelHeight) negated;
                rightInset: ( column + buttonWidth ) negated )).
	column := column + buttonWidth + ( horizontalMargin // 2 ).
    view addPane: (Button new
        label: 'Clear all';
        when: #clicked send: #clearAllStops: to: aTabContainer with: comboBox;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: column;
                bottomInset: ( row + labelHeight) negated;
                rightInset: ( column + buttonWidth ) negated )).

	row := row +  ( 5 * labelHeight // 2  ).
    view addPane: (Button new
        label: 'OK';
        defaultPushButton;
        when: #clicked send: #tabStopsOK: to: aTabContainer with: comboBox;
        when: #clicked send: #close to:view;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: horizontalMargin;
                bottomInset: ( row + labelHeight) negated;
                rightInset: buttonWidth negated )).
	column := horizontalMargin + buttonWidth + ( horizontalMargin // 2 ).
    view addPane: (Button new
        label: 'Cancel';
        when: #clicked send: #close to:view;
        layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 0 @ 0)
                topInset: row;
                leftInset: column;
                bottomInset: ( row + labelHeight) negated;
                rightInset: ( column + buttonWidth ) negated)).
    view 
		initialSize:
			(( buttonWidth * 7 // 2 ) @ ( row +  ( 2 * labelHeight ) ) )
				* WindowDialog dialogUnit / WindowDialog unitMultiplier;
		labelWithoutPrefix: 'Tabs'! 
openOn: tabStops
    "Open a tab stop dialog
    with initial <tabStops> information.
    When the dialog is accepted by the user,
    perform <aMessage> with the new tab stops information."

    | coordinator view |
    view := self constructViewFor: (coordinator := self new).
    (view children
        detect:
            [:pane |
            (pane name = #tabStops)]) contents: tabStops.
    view open.
    ^ coordinator!   
setAStop: aDropDown
    "Private - external"
    "Insert the current input in
    <aDropDown> as a tab stop."

    aDropDown contents:
        ( aDropDown list asSortedCollection
            add: aDropDown value asFloat;
            yourself )!  
tabStopsOK: aComboBox
    "Private - external"
    "Set tab stop positions to aList in inches."

    result := aComboBox list!
clearAllStops: aDropDown
    "Private - external"
    "clear all tab stops in <aDropDown>."

    aDropDown contents: Array new!   
clearAStop: aDropDown
    "Private - external"
    "clear the current selection in
    <aDropDown> as a tab stop."

    aDropDown deleteItem: aDropDown value asFloat!   
dwCookie: aValue
    "Private - Set the application defined value for callback."
    ^ self longAtOffset: 0 put: aValue!
pfnCallback: anAddress
    "Private - Set the address of the callback routine."
    ^ self longAtOffset: 8 put: anAddress!  
dwError
    "Private - Answer the error code."
    ^ self longAtOffset: 4!  
fileName
        "Answer the receiver's file name."
     ^'riched32'!