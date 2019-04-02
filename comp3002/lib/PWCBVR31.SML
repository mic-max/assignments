3.1.0.106
   
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private "
    self
        partPrintForecolorOn: aStream margin: aString;
        partPrintBackcolorOn: aStream margin: aString;
        partPrintFontOn: aStream margin: aString.! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy dial: (dial partMirrorCopy: aMirrorCopyDictionary).
    ^copy! 
resizeWindow
        "Private - Change the size of the window
         for the receiver."
    self  partsIfOS2Do: [ rectangle := self rectangleWithoutMargin: rectangle ].
    super resizeWindow!
setMask
        "Private - Set the blank mask if the receiver has a
         pictureMask."
    pictureMask notNil ifTrue: [
        self setTextLimit: self unformattedTextLimit.
        self setWindowText: self stringWithProtectedCharacters ]!  
formatString: aString
        "Private - Answer aString with the correct dateSeparator."
    |char|
    char := NationalLanguage dateSeparator first.
    self dateSeparator = char
        ifTrue: [ "Don't need to replace the date separator."
            ^aString]
        ifFalse: [
            ^aString replaceCharacter: char from: 1 to: aString size withString: self dateSeparator.
             ]!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #turnOn #turnOff
            #label #setLabel: )
        separators: #(3 7 )
        defaultItem: #value! 
previousValue
        "Answer the previous value of the receiver.
        The previous value is the value prior to any
        user changes (when there is a #changed: handler)
        or the last time previousValue was sent."
    ^self propertyAt: #previousValue ifAbsent: [ self emptyValue ]!
isValidIntegerString: aString
        "Private- Answer true if aString has a valid character for an Integer."
    |str|
    str:= aString.

    "Check if there is a sign character."
    ( ((aString at: 1) = $+) or: [(aString at: 1) = $-])
        ifTrue: [
            aString size = 1 ifTrue: [^false].    "aString only contained a sign character."
            str:= aString copyFrom: 2 to: aString size].

    str do: [:char |
        (self isDigitCharacter: char)
            ifFalse: [^false] ].

    ^true!
partDirectEditTextIsRightJustified
        "Answer whether the receiver's text should be
        right-justified during direct-editing."

    ^self hasStyle: EsRightAlignedText! 
initDial: lowReadInteger
    highReading: highReadInteger
    lowDegree: lInteger
    highDegree: hInteger
        "Initialize the receiver."
    lowDegree := lInteger.
    highDegree := hInteger.
    lowReading :=
    reading := lowReadInteger.
    highReading := highReadInteger.
    readingsPerDegree := highReading - lowReading /
        (self relativeDegree: highDegree)!   
isValidString: aString
        "Private - Answer true if aString is an acceptable date string, else answer false."
    | str |
    str := aString trimBlanks.
    str isEmpty ifTrue: [^true].
    ^( (super isValidString: str) and: [self isValidFormat: str] )!   
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    pen notNil
        ifTrue: [ aMirrorCopyDictionary at: pen put: nil ].
    ^super partMirrorCopyReal: aMirrorCopyDictionary.!  
drawDial: clipRectangle
    center: aPoint
    radius: rInteger
    with: aPen
        "Private - Draw the dial, its tick marks, and labels."
    
    pen := aPen.
    center := aPoint.
    r := rInteger.
    self drawDial: clipRectangle.
    self drawTickMarks!  
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
subclassRecursively
		"Private - no need to subclass at runtime."
    self partIsEditing ifTrue: [
        self subclassWndProc].
	super subclassRecursively! 
close
        "Private - Close the receiver."
    bitmap notNil ifTrue: [bitmap archiveAndRelease].
    super close!   
deleteAll
        "Delete the contents of the receiver."

    self clear.! 
tickIntervalLength
        " Return the length of the tick interval. "
    ^interval at: 2! 
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
numberOfTicks
        " Return the number of ticks in the dial. "
    ^numberOfTicks!   
autoLabels: aBoolean
        " If aBoolean is true, the dial pane will automatically create labels
          for each tick interval; else it will create no labels. "
    autoLabels := aBoolean!  
deleteKey
        "Simulate the delete key being pressed."
    | parm1 parm2 |
    self
        partsIfOS2Do:
            [handle isValid
                ifTrue: [
                    parm1 := ExternalLong
                        lowHalf: KcVirtualKey | KcLoneKey
                        highHalf: 0.
                       parm2 := ExternalLong lowHalf: 0 highHalf: DeleteKey.
                    PARTSHostInterface
                        sendWindowMessageInt: handle
                        msg: WmChar
                        parm1: parm1 asParameter
                        parm2: parm2 asParameter.
                    parm1 lowHalf: KcVirtualKey | KcLoneKey | KcKeyUp.
                    PARTSHostInterface
                        sendWindowMessageInt: handle
                        msg: WmChar
                        parm1: parm1 asParameter
                           parm2: parm2 asParameter]
                 ]
        partsIfWindowsDo:
            [PARTSHostInterface
                sendWindowMessageInt: self handle
                msg: WmKeyDown
                parm1: DeleteKey
                parm2: 0]!   
datum
        "Private - Return the datum of the receiver."
    ^datum! 
partContents
    " Return the dictionary which contains data from the Edit Contents... dialog. "
    ^dial parameters!  
partDroppedControlRectangle
        " Private - Answer the bounding rectangle of the combo box
        including the dropped down listbox "
    self partsVwOnly.  " Only used on VW"

    ^self isHandleOk
        ifTrue: [ super partDroppedControlRectangle ]
        ifFalse: [ self partVirtualFrameRectangle ]! 
pictureCharacterPlaceholder: aCharacter
        " Private - set the character which represents a 
        picture mask character for which no character has been
        entered while editing the unformatted string. "
    pictureCharacterPlaceholder := aCharacter.!  
pictureMask: aString
        "Set picture mask which is used to control the
          value the user types and to protect characters
          in the receiver."
    pictureMask := aString.
    " self isEditing ifTrue: [self setMask] "!  
autoScroll
        " Platform dependent. "
        "^(EsAutoHorizontalScroll bitAnd: style) ~= 0"  "VOS"
    self error: 'no Windows equivalent'!  
partSetValueMessage
        "Answer the selector of the one-argument message
        which can be sent to the receiver to set its value. "
    ^#setValue:!
supportsMaxSizeItem
        "Private - return true if the receiver supports a text limit property. "
    ^true! 
saved
        "Mark the receiver as being not modified."
    self modified: false!  
append: aString
        "Add aString at the end of the
         text in the pane."

    super append: aString.
    aString size > 0
        ifTrue: [ self modified: true ].!   
isLogicalCharacter: aCharacter
        " Private - Answer true if aCharacter is one of 'TtFfYyNn',
        else answer false."
    ^('TtFfYyNn' includes: aCharacter)! 
parameters: aDictionary
        " Private - Set the new properties of the
          receiver set from the Edit contents... dialog. "
    lowReading := aDictionary at: 'lowReading'.
    highReading := aDictionary at: 'highReading'.
    lowDegree := aDictionary at: 'lowAngle'.
    highDegree := aDictionary at: 'highAngle'.
    numberOfTicks := aDictionary at: 'numberOfTicks'.
    defaultSize := aDictionary at: 'defaultSize'.
    interval := aDictionary at: 'tickInterval'.
    autoLabels := aDictionary at: 'autoLabels'.
    ticks := aDictionary at: 'ticks'.
    reading := aDictionary at: 'initSetting'!
isValidCharacter: aCharacter
        " Private - Answer true if aCharacter is acceptable for a
          Float, else answer false."
    |decimalSeparator|
    decimalSeparator := NationalLanguage decimalSeparator first.
    ((aCharacter = $-) or: [aCharacter = $+])
        ifTrue: [^self isValidSign: aCharacter].
    aCharacter = decimalSeparator
        ifTrue: [^self isValidDecimalSeparatorPosition: aCharacter].
    aCharacter isDigit
        ifTrue: [^self isValidDigit: aCharacter].
    ^false! 
wmLbuttondblclk: wParam with: lParam
        "Private - Add a MessageExpression to CurrentEvents
         and return right away."
        " Platform dependent (VW only) "

    self partsVwOnly.  " Only used on VW"
    self disabled ifTrue: [^nil].
    ^super wmLbuttondblclk: wParam with: lParam!   
displayWindow
        "Private - Let the owner process the display event
        or draw all the retained segments."
    | rect |
    self erase.
    dial drawDial: (rect := self rectangle)
            center: rect center
            radius: (rect width // 2
                    min: rect height // 2)
                    - (SysFont height * 2)
           with: graphicsTool.
    dial drawNeedle!   
errorString
    "Return the error string."
    ^'Invalid float '!   
eraseNeedle
        "Private - Erase the current dial reading."
        | oldColor |
    oldColor := pen foreColor.
    pen down;
        foreColor:
            (pen backColor isNil
                ifTrue: [PARTSHostInterface colorBackground]
                ifFalse: [pen backColor]);
        place: center;
        direction: tip y;
        go: tip x;
        foreColor: oldColor!
installPartRuntimeLibrary
        " Private - install the basic visual parts runtime library.
        Load the workbench support library if appropriate. "

    "self initializeRuntimeData." "Taken care of by the ad hoc initializer in this package ... (dkh, 5-4-95)"
    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Basic Visual Parts'.!   
canApplyStyle
    "Private - answer whether the receiver's style can change
    after it has been created.  In Windows, must be false so the border
	works, in OS/2 needs to be false for border and scrollbar."
	^false! 
lowReading
        " Return the low reading of the dial. "
    ^lowReading! 
frameRectangle
	^self 
		partsIfOS2Do: [super frameRectangle]
		partsIfWindowsDo: [
			self partDroppedControlRectangle]! 
createDatumFrom: aValue
        "Private - Answer a String without the protected characters.
        aString may or may not have protected characters.  Using the
        #setValue: message always strips the protected characters
        while the #value: message deals with strings with protected
        characters.  In either case the string has been validated.
        If the string does not have protected characters just return it.
        If the string has protected characters,remove them. "

    | result newValue |
	newValue:= aValue asString.

    " empty or #validate case "
    ( (newValue trimBlanks isEmpty) or: [newValue = self stringWithProtectedCharacters] )
        ifTrue: [^self emptyValue].

    " setValue: case "
    newValue size = self numberOfUnprotectedCharacters
        ifTrue: [^newValue].

    "value: case "
    result := String new.
    1 to: newValue size do: [: index |
        ((self isProtected: (pictureMask at: index)) not)
            ifTrue: [result := result, (String with: (newValue at: index))]].
    ^result! 
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "

   ^super partMirrorCopyPropertiesToExclude,
		#( #listBox )!  
isValidStringWithProtectedCharacters: aString
            " Private - Check if all the protected characters in aString are the same
            as those in picture field. If they are return aString without the
            protected characters, if not return false."
    | str strChar pictureChar answer|
    (aString size ~= self pictureMask size)
        ifTrue: [^false].
    str:= aString asOrderedCollection.
    1 to: aString size do: [: index |
        strChar:= aString at: index.
        pictureChar:= pictureMask at: index.
        (self isProtected: pictureChar)
            ifTrue: [
                pictureChar = strChar
                    ifTrue: [str remove: strChar]
                    ifFalse: [ ^false]]].
    answer:= String new.
    str  do: [:char | answer:= answer, char asString  ].
    ^answer.!
value: aReading
        " Set the dial to aReading. "
    aReading isNil ifTrue: [^nil].
    self isHandleOk ifFalse: [ 	"in case receiver was closed."
        ^dial setReading: aReading asInteger ].
    self doGraphics: [dial setToReading: aReading asInteger].!   
isProtected: aCharacter
        " Private - Answer true if aCharacter is a protected character, ie.
         one that is not included in PictureCharacters."
    ^(PictureCharacters includesKey: aCharacter) not! 
invalidDirectEdit
        "Private - Direct edit yielded an invalid input. Prompt the user
         to fix the problem or ignore it."
    | directEditor |
    directEditor := self partEditorPane directTextEditor.
    directEditor clearMouseCapture.
    self errorMessage
        ifTrue: [
            self partEditorPane currentEditObject: directEditor.
            directEditor
                selectAll;
                captureMouseInput;
                setRetryEntry ]
        ifFalse: [
            directEditor
                hideWindow;
                modified: false;
                underPane: nil.
            self frameWindow realInvalidateRect: nil.
            self partEditor refreshedRectangle: self frameRectangle.
            directEditor resizeToRectangle: (0@0 extent: 0@0).
            self partEditorPane
                captureMouseInput;
                stopEdit ]! 
entryFieldClass
        " Private "
    ^PARTSComboEntryField!  
initialize
        " Private - initialize a new instance. "

    super initialize.
    self autoRadioButton.! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #selectItem: #deselectItem:
                #valueIndices #setValueIndices: #selectIndex: #deselectIndex:
                #deselectAll
            #list #setList: #insertItem: #deleteItem: #deleteAll
            #abortChange
            )
        separators: #( 3 12 17 )
        defaultItem: #value!  
emptyValue: aValue
        " Assign the value of the receiver when its content is empty. "
    emptyValue:= aValue! 
replaceWithChar: aChar at: anInteger
        "Private - Replace the current selection with aChar."
    self replaceWithText: (String with: aChar) at: anInteger!
initialize
        " Private - initialize a new instance. "

    super initialize.
    self dropDown.!
partDirectEditTextIsMultiLine
        "Answer whether the receiver's direct edit text
        can contain multiple lines. "
    ^true! 
highDegree: anInteger
        " Set the high degree of the dial. "
    highDegree := anInteger! 
defaultEmptyValue
        " Private - answer the default empty value "
    ^nil!
saveToFile: aPathName
    "Save the contents of the text pane to
   the file named aPathName. Trigger the event
    fileExecption: if any error is encoutered processing
    the file aPathName. "

    | fileStream |

    aPathName isNil ifTrue: [^nil].
    [
        fileStream := File pathName: aPathName.
        self fileOutOn: fileStream.
        fileStream close
    ] on: Error
        do: [ self triggerEvent: #fileException: with: aPathName ]!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #changed: #fileException: #modifiedIsTrue
            #rightClicked #controlTabbed )
        separators: #( 2 3 )
        defaultItem: #changed:!   
setToReading: anInteger
        "Private - Answer the difference between anInteger
         and old reading. Draw needle to reflect
         the new reading anInteger."
    | newReading |
    newReading := (anInteger max: lowReading "+ lowReading")
        min: highReading.
    lastChange := newReading rounded - reading rounded.
    reading := newReading.
    lastChange = 0
        ifFalse: [
            self eraseNeedle.
            self drawNeedle].
    ^lastChange! 
lastSelection: aString
        " Private "
    self propertyAt: #lastSelection put: aString!
createDatumFromFloatString: aString
    " Private - return a Fraction from aString. "
    | sign decimalSeparator decimalPos denominator numerator fraction str |

    decimalSeparator := NationalLanguage decimalSeparator first.
    denominator := (10 raisedTo: self decimalPlace) rounded.

     "Check for sign."
    (((aString at: 1) = $-) or: [(aString at: 1) = $+])
        ifTrue: [
            sign := aString at: 1.
             str := aString copyFrom: 2 to: (aString size)  ]
       ifFalse:[
            sign := $+.
            str := aString].

    decimalPos := str indexOf: decimalSeparator.
    decimalPos> 0
       ifTrue: [
             numerator := (str copyFrom: 1 to: decimalPos - 1),
                                   (str copyFrom: decimalPos + 1 to: str size).
             decimalPos := str size - decimalPos.
             numerator := numerator asInteger *
                              (10 raisedToInteger: (self decimalPlace - decimalPos))]
       ifFalse: [
            numerator:= (str size = self digits)
                ifTrue: [ str asInteger ]
                ifFalse: [ str asInteger * (10 raisedToInteger: self decimalPlace) ]].

      fraction := Fraction
                            numerator: numerator
                            denominator: denominator.
      sign =  $-  ifTrue: [fraction := fraction negated].
    ^fraction!   
parameters
        " Private - Initialize the dictionary used with the Edit contents... dialog. "
    ^Dictionary new
        at: 'lowReading' put: lowReading;
        at: 'highReading' put: highReading;
        at: 'lowAngle' put: lowDegree;
        at: 'highAngle' put: highDegree;
        at: 'numberOfTicks' put: numberOfTicks;
        at: 'defaultSize' put: defaultSize;
        at: 'tickInterval' put: interval;
        at: 'autoLabels' put: autoLabels;
        at: 'ticks' put: ticks;
        at: 'initSetting' put: reading;
        yourself!
initialize
        " Private - initialize a new instance. "

    super initialize.
    self enableWordWrap.!  
arithmeticErrorMessage
        " Private - Pop- up a message box warning the user of the arithmetic error.
           Return nil. "
    MessageBox
        warning: ' An arithmetic error has been encountered.
Cannot continue the computational operation. '.
    ^nil!   
autoLabels
        " Return true if the dial pane should automatically create labels;
          else return false. "
    ^autoLabels!  
setFromFile: aPathName
        " Set the contents of the text pane with
        the text in the file named aPathName.
        Trigger the changed event. "
    | fileStream |
    aPathName isNil ifTrue: [^nil].
    (File exists: aPathName)
        ifFalse: [
            self triggerEvent: #fileException: with: aPathName.
            ^nil].
    fileStream := File pathNameReadOnly: aPathName.
    self fileInFrom: fileStream.
    fileStream close.
    self triggerChanged.
    ^aPathName!
supportsShowDisabledScrollbarStyle

    ^SupportsShowDisabledScrollbar! 
setEntryField
        "Private - Set the entry field control in the receiver."
    | listBox |
    super setEntryField.
    self partsIfOS2Do: [ ^ self ].
    "The following is needed for VW only. [LN 11-Jul-94]"
    ( self partIsEditing and: [ self hasStyle: CbsVisibleComboBox ] )
        ifTrue: [  " borrow ComboEntryField to get at list box "
            listBox := self entryFieldClass fromInteger: (
                PARTSHostInterface hostWindowLibrary getTopWindow: self handle ).
            listBox isHandleOk ifTrue: [
                listBox
                    parent: self;
                    receiveMessages;
                    receiveAllWindowMessages.
                self listBox: listBox  ] ]! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        decimalPlace: ( decimalPlace partMirrorCopy: aMirrorCopyDictionary );
        signed: ( signed partMirrorCopy: aMirrorCopyDictionary );
        digits: ( digits partMirrorCopy: aMirrorCopyDictionary ).
    ^copy!
lowDegree
        " Return the low degree of the dial. "
    ^lowDegree!
isValidType: anObject
    "Private - Answer true if anObject is a Fraction, else answer false."
    ^anObject isFraction!   
button1Move: aPoint
        " Private - Change the current reading."
    self moveDialTo: aPoint.!  
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    | aFont |
    aFont := self partFontOrSysFont.
    ^aFont width * 6 @ (aFont height + 2)!
computeNewDegree: degree unitsPerScale: unitsPerScale
        " Private  - Draw the tick marks in a clockwise direction. "
    ^degree - unitsPerScale! 
ticks: aDictionary
        " Set the number of ticks in the dial. "
    ticks := aDictionary!   
isValidPositiveIntegerString: aString
        " Private - Answer true if aString has a valid character for a positive Integer."
    | str |
    str := aString trimBlanks.
    str do: [ :char |
        (self isDigitCharacter: char)
            ifFalse: [^false] ].
    ^true! 
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received."
    | virtualKey |

   virtualKey:= aKeyboardInputEvent virtualKey.
	virtualKey isNil ifTrue: [ ^nil ].
	( self handlesVirtualKey: virtualKey )
        ifTrue: [           
			virtualKey == LeftKey ifTrue: [ ^self skipLeft;  skipProtected: false. ].
            virtualKey == RightKey ifTrue: [^self skipRight; skipProtected: true. ].
            virtualKey == DeleteKey
                ifTrue: [
                    self isGapSelection
                        ifTrue: [ ^self backspaceSelection.  ]
                        ifFalse: [ ^self delete. ]].
            virtualKey == BackspaceKey ifTrue: [ ^self backspace. ]].

    ^super keyboardInput: aKeyboardInputEvent!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #clicked
            #rightClicked #tabbed)
        separators: #( 1 )
        defaultItem: #clicked!   
partIsEditing
    ^super partIsEditing
        ifTrue: [ ( self partEditor isDirectEditing: self ) not ]
        ifFalse: [ false ]!   
emptyValue
        " Return the value of the receiver when its content is empty. "
    ^emptyValue! 
initialize
        " Private- Initialize the picture characters. "
    self initializePictureCharacters.!   
initialize
        " Private - Initialize the receiver.  "
   super initialize.
    self
        pictureMask: 'A9NXL!!';
        pictureCharacterPlaceholder: self defaultPictureCharacterPlaceholder.!  
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
setList: aCollection
        "Set the receiver's list to aCollection.  Answer aCollection."
    | newList changed |
    newList := aCollection isString
        ifTrue: [ Array with: aCollection]
        ifFalse: [
            aCollection isNil
                ifTrue: [ Array new ]
                ifFalse: [
                    aCollection isIndexedCollection
                        ifTrue: [ aCollection ]
                        ifFalse: [ Array with: aCollection asString ] ] ].
    changed := self valueAttribute notNil and: [ self listAttribute ~= newList ].
    self list: newList.
    changed ifTrue: [ self triggerChanged ].
    value := nil.
    ^aCollection!
button1Down: aPoint
        " Private - Process the button1Down event."
    super button1Down: aPoint.
    pictureMask notNil ifTrue: [self skipProtected: true]!  
isValidSignPosition: aCharacter
        " Private - Answer true if aCharacater is a valid sign for a float.  Floats can only have a plus
        or minus sign before the mantissa and a minus sign right after the exponent
        character."
    |sign input selectedText pos exponentPos currentPos numSign|
    sign:= aCharacter.
    input:= self windowText asLowerCase.
    pos := self selection.
    (pos x - pos y) abs > 0
        ifTrue: [selectedText := input copyFrom: (pos x)  to: (pos y) - 1].
    currentPos:= pos x.
    exponentPos:= input indexOfString: 'e'.
    numSign:= (input occurrencesOf: $+) + (input occurrencesOf: $-).

    (numSign ~= 2)
        ifTrue: [ "Check if the sign is for the mantissa or the exponent."
            (exponentPos = 0 )
                ifTrue: [ ^self isIntegerCharacter: sign   "Sign is for mantissa."  ]
                ifFalse: [^((currentPos = (exponentPos +1)) and: [sign ~= $+])  ]]
        ifFalse: [
            selectedText == nil
                ifTrue: [^false] "Passed the number of signs allowed."
                ifFalse: ["replacing existing text"
                    ^((currentPos = 1) or: [^currentPos = exponentPos +1 ])]
].!   
wmPaint: mp1 with: mp2
        "Private - Display the receiver."
    | workbenchPane |
    super partIsEditing ifTrue: [
        ((workbenchPane := self partEditor workbenchPane) isDirectEditing: self)
            ifTrue: [workbenchPane showEditBorderDeferred: self]].
    ^super wmPaint: mp1 with: mp2! 
dial: aDial
        "Private - Set the dial pane to be used with the receiver. "
    dial := aDial! 
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a static graphic "!
isValidFloatString: aString
        "Private - Answer true if aString has  valid characters for a float."
    | decimalSeparator str |
    decimalSeparator := NationalLanguage decimalSeparator first.
    ((aString occurrencesOf: decimalSeparator) > 1) ifTrue: [^false].
    str:= aString reject: [:char | char = decimalSeparator] .
    ^self isValidIntegerString: str.!   
isValidDecimalSeparatorPosition: aCharacter
        "Private - Answer true if a decimal separator is being placed in the right position,
         else answer false.  There could only be one decimal separator."
    | decimalSeparator input pos currentPos selectedText signChar |
    self decimalPlace = 0 ifTrue: [^false].
    decimalSeparator:= aCharacter.
    input := self windowText asLowerCase.
    pos := self selection.
    currentPos:= pos x - 1.
   self isGapSelection
        ifTrue: [selectedText := input copyFrom: pos x to: (pos y - 1)].

    (input includes: decimalSeparator)
        ifTrue: [
            selectedText == nil
                ifTrue: [^false]
                ifFalse: [^selectedText includes: decimalSeparator]].

    "Need an extra character if decimal is signed."
    ( ( input includes: $- ) or: [ input includes: $+ ])
        ifTrue: [signChar:= 1]
        ifFalse: [signChar:= 0].
    ^(currentPos <= (self digits - self decimalPlace +  signChar))!
value
        "Answer the value of the receiver as a boolean."
    self selection ifTrue: [self triggerEvent: #valueIsOn].
    ^value! 
skipLeft
        "Private - Skip over a  character by simulating a left
        arrow input"
    |position|
    position := self selection x.
    self selectFrom: (position - 1) to: (position - 2)!
validateWhenLosingFocus: aBoolean
        " Answer whether to validate the value when the
        focus is lost. "
    self propertyAt: #validateWhenLosingFocus put: aBoolean!
recordLastSelection
    self lastSelection: self getLastSelection.!  
isValidFractionString: aString
    " Private - return true if aString is a valid fraction string with the
      format '2000/100' , else return false.  The numerator string cannot
      exceed digits and the denominator string has to contain the same
      number of zeros as decimalPlace. "

    | pos numerator denominator |

    (pos := aString indexOf: $/ ) = 0
        ifTrue: [^false].
    numerator := aString copyFrom: 1 to: (pos - 1).
    denominator := aString copyFrom: (pos + 1) to: aString size.

    "Check the numerator"
    ( self isValidIntegerString: numerator )
        ifFalse: [^false].
    ( self isValidSignString: numerator )
         ifFalse: [^false].
    numerator:= numerator reject: [:char | ( char = $- ) or: [ char = $+ ]].

    "Check the denominator"
    ( self isValidPositiveIntegerString: denominator )
         ifFalse: [^false].
    ( denominator first = $1 )
         ifFalse: [^false].
    denominator:= denominator reject: [:char | char =  $1 ].
    ( (denominator reject: [:ch | ch = $0] ) size = 0 )
        ifFalse: [^false].

    ^ ( ( numerator size <= self digits ) and: [ denominator size = self decimalPlace ] )!
wmChar: mp1 with: mp2
        "Private - Process the character input message."
    ^self 
		partsIfOS2Do: [
			self wmCharOS2: mp1 with: mp2]
		partsIfWindowsDo: [
			self wmCharWindows: mp1 with: mp2]!  
errorPrompt
        "Private - Warn the use about an error condition."
    ^MessageBox warning: self errorString!   
isEndUserEditing: aBoolean
    " Private - If aBoolelan is true, the receiver is in the middle of editing an invalid
       value; else it is not.  Used during the handling of losing focus and getting focus. "
    ^ self propertyAt: #isEndUserEditing put: aBoolean!  
subtract: arg
        "Subtract arg from the contents of the receiver."
    | x y |
    x := self value.
    x isNil ifTrue: [ x := 0 ].
    y := arg.
    y isNumber ifFalse: [ y:= y asString asNumber ].
    [ ^x - y  ]
        on: Error
        do: [^self arithmeticErrorMessage ].!  
errorString
        "Return the error string."
    ^'Invalid integer '! 
labelLeftOfBox
        "Configure the receiver to display its label left of the check box."
    self partsVwOnly.
    self addStyle: BsLeftAlignedText!
wmKeydown: wordInteger with: longInteger
        "Private - Process the key down message."
    | event virtualKey |
    self partsVwOnly.
    super wmKeydown: wordInteger with: longInteger.
    ( event := KeyboardInputEvent fromWmKeydown: wordInteger with: longInteger ) isNil ifTrue: [ ^nil ].
      virtualKey := event virtualKey.
    ^( self handlesVirtualKey: virtualKey )
        ifTrue: [ 1 ]   "The receiver handles the virtual key. "
        ifFalse: [ nil ].! 
isValidCharacter: aCharacter
        " Private - Answer true if aCharacter is acceptable for an
          Integer, else answer false."
    | limit str   |
    ( ( aCharacter = $- or: [ aCharacter = $+ ]) and: [  self selection x = 1] )
        ifTrue: [ ^true].
    limit:= self textLimit.
    limit isNil ifTrue: [ ^aCharacter isDigit ].
    str:= self windowText.
    ( ( str includes: $- )  or: [ str includes:$+ ] )
        ifFalse: [ limit:= limit - 1].
    ^( aCharacter isDigit ) and: [ str size < ( limit  )]!  
getDefaultIcon
        " Return the default icon to be used with the receiver. "
    ^PARTSApplication defaultIcon! 
lowDegree: anInteger
        " Set the low degree of the dial. "
    lowDegree := anInteger!
useSystemFormat
        "When useSystemFormat is true, dateSeparator,
        and format instance variables are ignored, and instead
        the host system settings are used."
    ^useSystemFormat!
activate
    " Private - the receiver has been activated.
    If the receiver is the first of the orderedChildren, the focus was set to it by #setInitialFocus.
    However, it has not been subclassed yet, so  it did not receive the #wmSetFocus:with: (#gettingFocus) message
    and was not able to execute its formatting.  So, execute the #gettingFocus here. "
     ^self partIsEditing
        ifTrue: [ true ]
        ifFalse: [
            ( self hasFocus and: [ self valueAttribute ~= self unformattedString ] )
                ifTrue: [
                    self gettingFocus.
                    super activate ] ].!   
isValidSignString: aString
     " Private - answer true if a sign character is valid for the receiver.
       Sign characters are $+ or $- only.  "
    | sign |
    sign := aString at: 1.
    ^( sign = $+ or: [ sign = $- ] )
        ifTrue: [
            ( self signed ) and: [aString size ~= 1] ]
        ifFalse: [ true ].! 
dateFormat: anInteger
        "Assign the date format."
    dateFormat := anInteger!
getDefaultBitmap
        " Return the default bitmap to be used with the receiver. "
    | bitmap extent |
	extent := Icon iconSize.
    bitmap := Bitmap width: extent x height: extent y planes: 1 bitCount: 4.
    bitmap pen
        fill: bitmap boundingBox
        color: Color blue.
    ^bitmap! 
stretchBitmap: aBoolean
        "Set the stretch bitmap state. If aBoolean is true, the bitmap is
         stretched to fit the graph pane otherwise the bitmap is displayed as is."
    aBoolean
        ifTrue: [ stretch := 1 ]
        ifFalse: [ stretch := 0 ].
    self displayWindow
! 
partSetContents: aString
        " Set the PARTS contents of the receiver. "
    self contents: aString!
partDirectEditTextIsCentered
        "Answer whether the receiver's text should be
        centered during direct-editing."
    ^(style bitAnd: SsCenteredText) ~= 0!  
partEditorPane
        " Private - answer the PARTS Workbench pane
        in which the receiver is being edited.  Answer nil
        if not a part or not being edited. "
    ^parent partEditorPane!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy datum: ( datum partMirrorCopy: aMirrorCopyDictionary ).
    ^copy! 
pasteFromClipboard
        " Paste the bitmap in the clipboard into the receiver. "
    | newBitmap |
    (newBitmap := Clipboard getBitmap) notNil
        ifTrue: [self setBitmap: newBitmap].! 
initializePropertyOptions
        " Private - class initialization. "

    self
        partsIfOS2Do: [
            SupportsBorder := true.
            CanBeDefaultButton := true.
            ]
        partsIfWindowsDo: [
            SupportsBorder := false.
            CanBeDefaultButton := false.
            ].!
isEndUserEditing
    " Private - Return true if the receiver is in the middle of editing an invalid
       value.  Used during the handling of losing focus and getting focus. "
    ^ self propertyAt: #isEndUserEditing ifAbsent: [false].!  
reading
        "Answer the current reading."
    ^reading! 
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
popupMenu
        "Private - Answer the popup Menu for the receiver."

    ( self owner isPARTSApplication
    or: [ self owner isPARTSEditor ] )
        ifTrue: [^nil].

    ^super popupMenu!   
isValidFormat: aString
        "Private - Answer true if aString contains a valid Date object."
    | data day month year |
    data := self extractDayMonthYear: aString.
    day := data at: #day.
    month := data at: #month.
    year := data at: #year.
   " If we have a two digit year, we add 1900 or 2000 before we check it."
    self twoDigitYear
        ifTrue: [year := year +
            (year > 49
                ifTrue: [1900]
                ifFalse: [2000])].
    ^(self checkDay: day month: month year: year).! 
wmKillfocus: wordInteger with: longInteger
    "Private - Process the kill focus message.  Synchronously validate the receiver's input
    and confirm or veto the new value.  If the controls which lost and received the focus do
      not have the same parent, do not execute the validation process.  Instead, leave the
      contents alone, so that the user can come back and finish entering the new value. "
        | subPaneWithFocus result |
        self partsVwOnly.
    subPaneWithFocus := self getSubPaneWithFocus: wordInteger.
    ^( result := self processLosingFocusTo: subPaneWithFocus ) == self
        ifTrue: [
            self subPaneWithFocus: subPaneWithFocus.
            super wmKillfocus: wordInteger with: longInteger ]
        ifFalse: [ result ]!   
wmCharWindows: wordInteger with: longInteger
    | character event leadByte wparam |
    self partsVwOnly.
    wparam := wordInteger.
    NationalLanguage isDoubleByteCp
        ifTrue: [
            ( leadByte := self propertyAt: #lastChar ) isNil
                ifTrue: [
                    character := Character value: wordInteger.
                    character isLeadByte ifTrue: [
                          "Make a doublebyte character so we can validate it"
                        character := Character leadByte: character trailByte: 0.
                        wparam := character asInteger ] ]
                ifFalse: [
                       "For EntryField we normally get only one wmChar message
                       (leadbyte) per doublebyte character. When we choose to return
                       false to this message (reject default processing) the character
                       is not displayed and we end up getting the trailbyte."
                    self propertyAt: #lastChar put: nil.
                    ^false ] ].
    event := KeyboardInputEvent fromWmChar: wparam with: longInteger .
    self sendInputEvent: #keyboardInput: with: event.
    event virtualKey isNil
        ifTrue: [
            ( character := event character ) notNil
                ifTrue: [
                    ( self isValidCharacter: character )
                        ifTrue: [ self sendInputEvent: #characterInput: with: character ]
                        ifFalse: [
                            character isDoubleByte ifTrue: [
                                  "Set to remind us to reject the next trailbyte wmChar message."
                                self propertyAt: #lastChar put: character ].
                            Terminal bell. ^false   ] ] ].
    ^self wmCharResultFor: wparam asCharacter!   
createUnformattedStringFromValue: aValue
        "Private - answer an unformatted string from aValue. "
    ^(aValue == nil or: [aValue = ''])
        ifTrue: ['']
        ifFalse: [self unformatString: (aValue asString)]!
twoDigitYear
        "Returns a boolean which indicates if the receiver accepts a two digit
        or four digit year.
        If aBoolean is true then the receiver accepts a two digit year.
        If aBoolean is false then the receiver accepts a four digit year."
    ^twoDigitYear!
tickInterval
        " Return the number of tick intervals in the dial."
    ^interval at: 1!   
editValue
        " Private - Return the editable string of the receiver. "
    ^self isEndUserEditing
        ifTrue: [ self valueAttribute ]
        ifFalse: [ self unformattedString ].!  
valueFormatted
        "Return datum as a formatted string."
    ^self formattedString! 
initialize
    " Private - initialize class values
        PARTSMultipleChoiceListPart initialize
    "

    SupportsShowDisabledScrollbar := ( self
        partsIfOS2Do: [ false ]
        partsIfWindowsDo: [ true ] ).
    ^super initialize! 
isAlphaNumericCharacter: aCharacter
        " Private - Answer true if aCharacter is an alpha numeric character
         ( $A - $Z, $a - $z, $1 - $9 or other characters defined  as alphanumeric
        by the current system language), else answer false. "
    ^aCharacter isAlphaNumeric!   
isDefaultPushButton
        "Private - Answer true if the receiver is the
        default pushbutton."

    ^self partIsEditing
        ifTrue: [ false ]
        ifFalse: [ super isDefaultPushButton ]!   
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
drawLabel: aString degree: degree
        "Private - Draw the label aString at the current pen
         position in the direction of degree."
    | x y |
    (degree <= 150 and: [degree >= 30])
         ifTrue: [
              y := pen location y up: 3]
         ifFalse: [
            (degree >= 210 and: [degree <= 330])
                ifTrue: [y := (pen location y down: (pen font height) ) up: 2]
                ifFalse: [y := (pen location y down: (pen font height // 2) ) up: 2]].
    x := pen location x.

    (degree == 270 or: [degree == 90])
           ifTrue: [
               x := x - (aString size
                  * pen font width // 2).
              y := y up: 2]
        ifFalse: [
              (degree < 270 and: [degree > 90])
                 ifTrue: [x := x - (aString size
                      * pen font width) - 3.
                    (degree < 225 and: [degree > 135])
                        ifTrue: [x := x - 4]]
                  ifFalse: [x := x + 3]].
    pen displayText: aString
        from: 1
          to: aString size
          at: x @ y!   
createDatumFrom: aValue
        "Private - Answer a Fraction object from aString.
        A valid aString has two possible formats:
            1) Float - contain all digits,an optional sign character and an optional decimal separator.
            2) Fraction - has the form '2000/100'. "
    |  newValue |
	newValue:= ( self isValidType: aValue )
		ifTrue: [ aValue ]
		ifFalse: [ aValue asString ].		
	newValue isString
		ifTrue: [
    		 newValue trimBlanks isEmpty ifTrue: [ ^self emptyValue].
    		^( newValue includes: $/  )
        		ifTrue: [ newValue asNumber ]
       			 ifFalse: [self createDatumFromFloatString: newValue ] ].
	^newValue!
isValidCharacter: aCharacter
        "Private - Answer true if aCharacter is valid, else answer false.
        Should be implemented by subclasses. "!  
isValidType: anObject
    "Private - Answer true if anObject is a Date, else answer false."
    ^anObject class == Date!
degreeToReading: degreeInteger
        " Private - Convert degreeInteger to the receiver
          dial reading."
    | newDegree maxRel |
    maxRel := self relativeDegree: highDegree.
    newDegree := self relativeDegree: degreeInteger.
    newDegree > maxRel
        ifTrue: [
            newDegree > (maxRel // 2 + 180)
                ifTrue: [newDegree := 0]
                ifFalse: [newDegree := maxRel]].
    ^(newDegree * readingsPerDegree) rounded!
losingFocus
        "Private - The receiver is losing focus and it has a new valid value.
        Set the new datum and format the contents."
    | modifiedFlag |
    modifiedFlag:= self modified. 
    self
        setNewDatumWith: ( self createDatumFrom: self windowText trimBlanks );
        " #setNewDatumWith: uses #value: which sets the modified flag to false.
        Need to reset the modified flag to its old state"
        modified: modifiedFlag;
        isEndUserEditing: false;
        setFormattedContents;
        triggerLosingFocus;
       valueHasChanged: false. !  
errorString
    "Return the error string."
    ^'Invalid fixed decimal number '!
formattedString
        " Private - Answer datum as a formatted string."
    ^(datum == nil or: [datum = ''])
        ifTrue: ['']
        ifFalse: [self formatString: (datum asString)]!
processInvalidInput: aString focusPane: subPaneWithFocus
    " Private - <aString> is an invalid input.  Bring up a message box asking the
      user if he/she  wants to input a new string. "

    self valueAttribute: aString.
    self
        partsIfOS2Do: [
            self sendInputEvent: #retry: with: subPaneWithFocus.
                 ^nil ]
        partsIfWindowsDo: [
            "If the validation was caused by a button click it failed, undo the button click."
            subPaneWithFocus isButton
                ifTrue: [ self sendDeferredEvent: #sendWmUser3To: with: subPaneWithFocus handle ].
            self sendInputEvent: #sendButtonUpTo: with: subPaneWithFocus handle.
            ^( self retry: subPaneWithFocus )
                        ifTrue: [ 0 ]
                        ifFalse: [ nil ]].! 
initialize
        " Private - Initialize the receiver "
    super initialize.
    self font: nil.  "GraphPane always sets font to SysFont"
    self dial: self defaultDial.! 
isValidFloatString: aString
    " Private - Answer true if aString contains a valid float string which has
        the correct number of digits and decimalPlace, else answer false. "

   | str decimalSeparator num hasDecimalSeparator |

	str:= aString.

	" Convert aString from scientific notation form. "
	( (aString includes: $e) or: [aString includes: $E] )
		ifTrue: [ str:= aString asFloat printFraction: self decimalPlace ].

     "Check for the sign character."
    ( self isValidSignString: str )
        ifFalse: [^false]. 

    str:= str reject: [:char | char = $- or: [char = $+] ].

    "Check for decimal separator. "
    decimalSeparator := NationalLanguage decimalSeparator first.
    num := str occurrencesOf: decimalSeparator.
    num > 1
        ifTrue: [^false]
        ifFalse: [ hasDecimalSeparator:= (num = 1) ].

    "Check the digits."
    ( (str reject: [: ch | (ch isDigit) or: [ch = decimalSeparator ] ]) size > 0 )
        ifTrue: [ ^false].   "aString is invalid. It contains chars. that are not digits or a decimalSeparator."
    (self digits) > 0
        ifTrue: [
            hasDecimalSeparator
                ifTrue: [ ^str size <= ( self digits + 1) ]
                ifFalse: [ ^str size <= self digits ]].
    ^true!   
supportsShowDisabledScrollbarStyle

    ^SupportsShowDisabledScrollbar! 
partEditDirect
        "Private - place the receiver in direct edit mode."
    | oldReading |
    self
        partsIfOS2Do: [
            oldReading := self value.
            self propertyAt: #lafEditOldValue put: oldReading.
            self partEditorPane currentEditObject: self.
            self realInvalidateRect: nil.  "show edit frame" ]
        partsIfWindowsDo: [
            self partEditor workbenchPane lafEditNone: self ].! 
divide: arg
        "Divide the contents of the receiver by arg."
    | x y |
    x := self value.
    x isNil ifTrue: [ x := 0 ].
    y := arg.
    y isNumber ifFalse: [ y:= y asString asNumber ].
    [^x / y  ]
        on: Error
        do: [^self arithmeticErrorMessage ].! 
sendWmUser3To: aHandle
    "Private - Send a 'WmUser+3' message to the window handle <aHandle>."
    PARTSHostInterface
        sendWindowMessageInt: aHandle
        msg: self wmUser3Message
        parm1: 0
        parm2: 0 .! 
isValidString: aString
        " Private - Answer true if aString is valid for the current pictureMask.
        aString may or may not include the same protected characters in
        picture mask."
    | str picture mask filteredString|
    (pictureMask size = 0) ifTrue: [^false].
    (aString size > pictureMask size) ifTrue: [^false].
    ((aString trimBlanks size = 0) or: [aString = self stringWithProtectedCharacters])  "Initialization time."
        ifTrue: [^true].

    " strings which may include protected characters "
    str:= (aString size = pictureMask size )
        ifTrue: [
            filteredString:= self isValidStringWithProtectedCharacters: aString.
            ( filteredString = false )
                ifTrue: [^false]
                ifFalse: [filteredString ]]
        ifFalse: [aString ].

    " strings which do not include protected characters "
    picture:= self pictureMaskWithoutProtectedCharacters.
    (str size = picture size) ifFalse: [^false].
    1 to: str size do: [:index |
        mask := PictureCharacters at: (picture at: index).
        mask = #asUpperCaseCharacter:
            ifTrue: [ "Replace the character with an upper case character."
                str at: index put: (str at: index) asUpperCase]
            ifFalse: [
                (self perform: mask with: (str at: index))
                    ifFalse: [^false]] ].

    ^true!
partNeedsResizeToContents
        " Private - answer whether the receiver needs to
        be resized to install a property edit change. "
    ^true!  
isValidNumberOfCharacters: aNumber
        "Private - answer true if aNumber matches the required
        number of characters for the receiver, else answer false."
    | limit signChar |
    signChar := ( ( self contents includes: $+ ) or: [self contents includes: $- ] )
        ifTrue: [ 1 ]
        ifFalse: [ 0 ].
    limit := self textLimit.
    ^(( limit isNil ) or: [ limit = 0 ])
        ifTrue: [true]
        ifFalse: [ (aNumber = 0) or: [aNumber <= ( limit + signChar ) ] ] "optional sign char"! 
lowReading: anInteger
        " Set the low reading of the dial. "
    lowReading := anInteger! 
supportsMaxSizeItem
        "Private - return true if the receiver supports a text limit property. "
    ^false!
framingBlock: aPARTSFramer
		"Private - super framingBlock assumes a OneArgumentBlock,
		but the receiver uses PARTSFramer."
	^aPARTSFramer isPARTSRectangle
		ifTrue: [framingBlock := aPARTSFramer]
		ifFalse: [super framingBlock: aPARTSFramer].!
unformattedTextLimit
        " Private - Return the text limit of the receiver's unformatted string. "
    |signChar|
    "Need an extra character if decimal is signed."
    signChar := ( self signed
        ifTrue: [1]
        ifFalse: [0] ).

    ^(self digits) + 1 + signChar   "Digits + a decimal separator + an optional sign character."!
clearBitmap
        " Clear the bitmap displayed by the receiver.  Trigger the changed event."
    self
        bitmap: nil;
        erase;
        triggerEvent: #changed: with: nil "self bitmap."!
activate
    " Private - the receiver has been activated.
    If the receiver is the first of the orderedChildren, the focus was set to it by #setInitialFocus.
    However, it has not been subclassed yet, so  it did not receive the #wmSetFocus:with: (#gettingFocus) message
    and was not able to execute its formatting.  So, execute the #gettingFocus here. "
     ^self partIsEditing
        ifTrue: [ true ]
        ifFalse: [
            self hasFocus
                ifTrue: [
                    self gettingFocus.
                    super activate ] ].!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #bitmap #setBitmap:)
        separators: #( 3 )
        defaultItem: #disable!   
releaseBitmap
        "Private - Release OS resources associated with
        the bitmap."
    | aBitmapOrIcon |
    (aBitmapOrIcon := self propertyAt: #bitmap) notNil
        ifTrue:  [
            aBitmapOrIcon isIcon
                ifTrue: [ aBitmapOrIcon releaseBitmaps ]
                ifFalse: [ aBitmapOrIcon archiveAndRelease ] ].! 
processLosingFocusTo: subPaneWithFocus
    "Private - The receiver is losing focus. Validate the new input.
    If it is valid, set the receiver's new value and trigger the losingFocus event.
    If it is invalid, veto the click event of the control who the focus was lost to <subPaneWithFocus>.
    Reset the focus to the receiver and give the user the option to re-enter a new input."
 
    |  newUnformattedString inputChanged |

    ( self isReadOnly or: [ self validateWhenLosingFocus not ] )
        ifTrue: [
            self triggerLosingFocus.
            ^nil ].

    newUnformattedString := self windowText trimBlanks.
    inputChanged:= newUnformattedString ~= self unformattedString or: [self valueHasChanged].

    ( ( subPaneWithFocus isNil ) or: [ subPaneWithFocus mainWindow ~= self mainWindow ] )
        ifTrue: [
            inputChanged
                ifTrue: [
                    self valueAttribute: newUnformattedString.
                    self isEndUserEditing: true ]
                ifFalse: [
                    self valueAttribute: self unformattedString.
                    self isEndUserEditing: false].
            ^nil ].

    inputChanged
        ifTrue: [ " new value "
            self
                isEndUserEditing: true;
                valueAttribute: newUnformattedString.
            ( self isValidInputtedString: newUnformattedString )
                ifTrue: [ ^self processValidInput: newUnformattedString focusPane: subPaneWithFocus ]
                ifFalse: [ ^self processInvalidInput: newUnformattedString focusPane: subPaneWithFocus ]].

    "There were no changes to the window text, so reset the contents of the receiver
     before it got the focus. "
    self isEndUserEditing: false.
    self valueHasChanged: false.
    self setFormattedContents.
    self triggerLosingFocus.
    ^nil !  
validateWhenLosingFocus
        " Answer whether to validate the value when the
        focus is lost. "
    ^self propertyAt: #validateWhenLosingFocus ifAbsent: [true]!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: )
        separators: #( 3 )
        defaultItem: #value!  
dateFormatProperties
        " Private - answer the date format properties dictionary "
   ^Dictionary new
        at: 'dateSeparator' put: self dateSeparator;
        at: 'format' put: self dateFormat;
        at: 'twoDigitYear' put:  self twoDigitYear;
        at: 'useSystemFormat' put:  self useSystemFormat;
        yourself! 
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
delete
        "Private - Process the delete key."
    |position|
    position:= self selection x .
    position > pictureMask size ifTrue: [^Terminal bell].
    self insert: self pictureCharacterPlaceholder at: position.
    self selectFrom: ( position + 1  ) to: (position ).
    self skipProtected: true.!   
partNewValueEvent
        "Answer the selector of the one-argument event
        which is triggered by the receiver when its value
        has been changed. "
    ^#changedIndex:!   
innerControls
    | myRect hisRect controls |
    myRect := self frameRelativeRectangle.
    controls := OrderedCollection new.
    self superWindow children do: [:sibling |
        (sibling ~~ self and: [
         myRect contains: (hisRect := sibling frameRelativeRectangle)])
            ifTrue: [
                controls add: sibling]].
    ^controls!  
unformattedTextLimit
        " Private - Answer anInteger which is the valid number of
        character for an unFormatted date string."
    ^self twoDigitYear ifTrue: [6] ifFalse: [8]! 
isValidNumberOfCharacters: aNumber
        "Private - Answer true if aNumber matches the required number of characters for the receiver,
        else answer false."
    | limit |
    limit := self textLimit.
    ^( ( limit isNil ) or: [ limit = 0 ] )
        ifTrue: [ true ]
        ifFalse: [ ( aNumber = 0 ) or: [ aNumber <= limit ] ]! 
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
save
    ^self accept!   
setValue: aReading
        " Set the dial to aReading.  Trigger the <changed:>event
        if the value has changed.  Answer aReading. "
    ( aReading = self value )
        ifFalse: [
            self
                value: aReading;
                triggerChanged].
    ^aReading!  
button1Down: aPoint
        " Private - Find the apparatus containing
        the current mouse location and change its reading."
    self moveDialTo: aPoint.
    self setFocus.!
display
        "Private - Display the receiver pane contents."
    firstTime
        ifTrue: [
            self update.
            firstTime := false].
    self displayWindow!   
initializePropertyOptions
        " Private - class initialization. "

    StyleLabels := Array
        with: (Array with: 'Left' with: SsLeftAlignedText)
        with: (Array with: 'Center' with: SsCenteredText)
        with: (Array with: 'Right' with: SsRightAlignedText).
    StyleValues := Array
        with: SsLeftAlignedText
        with: SsCenteredText
        with: SsRightAlignedText.

    self
        partsIfOS2Do: [
            "DEBUG - check ported implementation"
            ( (StyleLabels =  #(#('Left' 0) #('Center' 256) #('Right' 512)) )
            and: [StyleValues =  #(0 256 512) ] )
                ifFalse: [self error: 'bug'].
        ]
        partsIfWindowsDo: [
            "DEBUG - check ported implementation"
            ( (StyleLabels =  #(#('Left' 0) #('Center' 1) #('Right' 2)) )
            and: [StyleValues =  #(0 1 2) ] )
                ifFalse: [self error: 'bug'].
        ].!
highAngle: anInteger
        " Set the high angle of the receiver. "
    dial highDegree: anInteger!
isValidString: aString
        "Private - Answer true if aString contains valid characters
         and the correct number of characters, else answer false. "
    | str |
    aString isString
        ifTrue: [
            str := aString trimBlanks.
            (self isValidNumberOfCharacters: str size)
                ifFalse: [^false].
            str do: [ :char |
                (self isValidCharacter: char)
                    ifFalse: [^false]]]
        ifFalse: [^false].
    ^true! 
bringToTop
        "Do not bring statics to the top."
    self realInvalidateRect: nil! 
createDatumFrom: aValue
        "Private - Answer a Float object from aString."
    |  newValue |
	newValue:= ( self isValidType: aValue )
		ifTrue: [ aValue ]
		ifFalse: [ aValue asString ].		
	newValue isString
		ifTrue: [ 
    		^newValue  trimBlanks isEmpty
        		ifTrue: [self emptyValue]
        		ifFalse: [newValue asFloat] ].
	^newValue! 
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #changed:
            #fileException:
            #modifiedIsTrue
             );
         yourself!  
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        dateSeparator: ( dateSeparator partMirrorCopy: aMirrorCopyDictionary );
        dateFormat: ( dateFormat partMirrorCopy: aMirrorCopyDictionary );
        twoDigitYear: ( twoDigitYear partMirrorCopy: aMirrorCopyDictionary );
        useSystemFormat: ( useSystemFormat partMirrorCopy: aMirrorCopyDictionary ).
    ^copy! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToChange #changed: #changedIndex:
                "doubleClicked:"  " dropped in VWin32, not sensible for drop-down "
            #rightClicked #tabbed)
        separators: #( 3 )
        defaultItem: #changed:!  
isSpaceCharacter: aCharacter
        " Private - Answer true if aCharacter is a space, else answer false."
    ^aCharacter = Space or: [ aCharacter = DoubleByteSpace ]!
isAnyCharacter: aCharacter
    " Private - Answer true for characters which need no validation."
    ^true! 
isGapSelection
        " Private - Answer true if the current selection is a gap selection."
    | aSelection |
    aSelection := self selection.
    ^self
        partsIfOS2Do: [ (aSelection x = aSelection y) not ]
        partsIfWindowsDo: [ aSelection y > aSelection x  ]! 
copyToClipboard
        " Copy the receiver's bitmap to the clipboard. "
    Clipboard setBitmap: self bitmap.! 
isValidSign: aCharacter
        "Private - Answer true if aCharacter is acceptable as a sign, else answer false."
    self signed ifFalse: [  ^false].
    ^self isIntegerCharacter: aCharacter.!  
datum: aDatum       
         "Private - Set the datum of the receiver. "
    datum := aDatum!  
isValidExponentString: aString
        "Private - Answer true if aString is a valid exponent string.  The exponent
        string could only have one $e or $E character followed by a valid integer."
    |str|
    ( ((aString occurrencesOf: $e) > 1) or: [(aString occurrencesOf: $- ) > 1] )
        ifTrue: [^false].
    ((aString indexOf: $e)  = (aString size)) ifTrue: [^false].
    str:= aString reject: [:char | char = $e ] .
    ^self isValidIntegerString: str.!
partDirectEditTextIsCentered
        "Answer whether the receiver's text should be
        centered during direct-editing. "

    ^self hasStyle: EsCenteredText! 
isValidFormat: aString
        "Private- Answer true if aString matches the number of unprotected characters
        in pictureMask, else answer false."
    | str str2 |
    str2 := self stringWithProtectedCharacters.
    aString = str2 ifTrue: [^true]. "no character has been inputted."
    str := aString reject: [ :char | str2 includes: char ].
    ^str size = self numberOfUnprotectedCharacters.!   
isValidExponentSeparatorPosition: aCharacter
        " Private - Answer true if aCharacter is a valid exponent separator.
        The exponent separator is only valid if it follows an integer.
        There could only be one exponent separator.  "
    |exponent input selectedText pos char|
    exponent:= aCharacter asLowerCase.
    input := self windowText asLowerCase.
    pos := self selection.
    pos x = 1 ifTrue: [^false].  "Cannot have $e or $E as the first character."
    (pos x - pos y) abs > 0
        ifTrue: [selectedText := (input copyFrom: pos x to: pos y - 1) asLowerCase].
    char:= input last. "The character to the left of the caret."

    (input includes: exponent) not
        ifTrue: [^char isDigit]
        ifFalse: [
             selectedText == nil
                  ifFalse: [
                        ^((selectedText includes: exponent) and: [char
isDigit] )]].
    ^false!
partSetValueMessage
        "Answer the selector of the one-argument message
        which can be sent to the receiver to set its value. "

    ^#setValueIndices:!   
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "

    ^super constructEventsTriggered
        add: #valueException:;
         yourself!  
handlesVirtualKey: aVirtualKey
	" Private - Return true if the receiver handles the action for aVirtualKey."
	| handledVirtualKeys |
	aVirtualKey isNil ifTrue: [^false].
 	handledVirtualKeys:= Array with: LeftKey with:RightKey with:DeleteKey  with:BackspaceKey .
    ^( handledVirtualKeys includes: aVirtualKey )!
supportsBothBitmapAndIcon
        " Private - Answer if the receiver supports the SsBitmap and SsIcon style. "
    ^StyleValues notNil! 
bitmap: aBitmap
        " Set the bitmap associated with the receiver. "
    self releaseBitmap.
    ^super bitmap: aBitmap!   
signed
        " Return true if the receiver handles a signed (+ or -) value. "
     signed == nil
        ifTrue: [signed:= true].
      ^signed!
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. Remove any formatting characters which the
        direct text editor retained from the previous (formatted)
        contents of the receiver. "
    self value: (self unformatString: text ).!  
wmUser3Message
        "Answer the host message to signify that a button was released."
    ^1027  "Wm_User+3 "!
propertyContents: aString
        "Private - set the receiver's contents to aString. Resize
         the receiver's frame if necessary to display the entire string."
    | w rect |
    self contents: aString.
    " resize the receiver to its text contents "
    w := (self font stringWidth: aString) + 4 +
        self extent x - self partDirectEditFrameRectangle width. "non-text area"
    rect := self frameRelativeRectangle.
    rect := ( self partDirectEditTextIsCentered
        ifTrue: [
            (rect center x left: w // 2) @ rect bottom
                extentFromLeftBottom: w + 6 @ rect height.
                ]
        ifFalse: [
            self partDirectEditTextIsRightJustified
                ifTrue: [
                    Rectangle
                        leftTop: (rect rightBottom leftAndUp:
                            (w + 4 @ rect height))
                        rightBottom: rect rightBottom]
                ifFalse: [
                    rect origin
                        extent: (w + 4 @ rect height) ]
            ] ).
    self
        resizeToRectangle: rect.
    self partsIfOS2Do: [ self sizeChanged: rect extent ].!  
validateSizeAndFormatOfInput
        "Return true if the input is valid, else return false.
        Used by PropertyFormattedString>>canDoChanges
        after typing new text into the Contents: field of the
        Properties dialog .
        Since the formatted field already validates each character,
        this method only needs to check the size and format of the
        string. This is the same scenario when the formatted field is
        losing focus.  For EntryFields, the string size cannot exceed
        the text limit. "
    |str|
    str:= self windowText trimBlanks.
    str isEmpty
        ifTrue: [^true].
    ^(self isValidNumberOfCharacters: str size) and: [self isValidFormat: str]!   
errorString
        "Return the error string of the receiver. "
    ^'Input size exceeds the text limit '!  
unformatString: aString
        " Private - Answer aString without the formatting characters of formatted phone number string.
        For example, if aString is '(999) 999-9999' or '999-9999'  ,  return
        '9999999999' or '9999999' respectively."
    ^aString reject: [:char | #($- $( $) ) includes: char]!  
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^SubPane constructEventsTriggered
        addAll: #(
            #changed:
            );
         yourself!   
partIsEditing
        "Answer whether the receiver is being edited in a PARTS Workbench. 
		 Check parent since receiver does not have a wrapper."
	^parent partIsEditing! 
triggerChanged
        " Private - trigger the changed event. "
    self triggerEvent: #changed: with: self value.! 
defaultTextLimit
        "Return the default text limit of the receiver.  "
    ^80!
createDatumFrom: aValue
        "Private - Answer an Integer object from aString."
    |  newValue |
	newValue:= ( self isValidType: aValue )
		ifTrue: [ aValue ]
		ifFalse: [ aValue asString ].		
	newValue isString
		ifTrue: [
   			 ^newValue trimBlanks isEmpty
        		ifTrue: [self emptyValue ]
        		ifFalse: [newValue asInteger] ].
	^newValue!
digits: anInteger
        " Set the number of digits the receiver can have. "
 digits := anInteger! 
validateInput: aString
        "Return true if the input is valid, else return false.
        Used by PARTSDirectTextEditor>>lafStopEdit
         for validating the input after direct editing.
        For EntryFields check if the size of the
        string is valid. "
    ^self isValidNumberOfCharacters: aString size! 
isValidType: anObject
        "Private - Answer true if anObject has the correct
        object type which the receiver supports, else answer false.
        Default type is a String."
    ^anObject isString!   
showBitmap
        "Private - display the receiver's bitmap"
    | bitmap |
    bitmap := self bitmapIfAbsent: [nil].
    bitmap isNil
        ifFalse: [
            bitmap isIcon ifTrue: [bitmap := bitmap xorMask].
            stretch = 0
                ifTrue: [    "don't stretch bitmap"
                    graphicsTool
                        copyBitmap: bitmap
                        from: bitmap boundingBox
                        at: 0 @ 0 ]
                ifFalse: [
                    graphicsTool
                        copyBitmap: bitmap
                        from: bitmap boundingBox
                        to: (0 @ 0 extent: self extent ) ] ] !  
getLastSelection
		"Private - answer the item that has been last selected
		(the one with the cursor). "
    | index |	
	self 
		partsIfOS2Do: [
    		index := PARTSHostInterface
        		sendWindowMessageInt: handle
        		msg: LbmGetSelection
        		parm1: LblCursor
        		parm2: 0.
    		^( index = LblNone ) ifTrue: [ nil ] ifFalse: [ index + 1 ] ]
		partsIfWindowsDo: [ ^super selection ]! 
arcTan90: aPoint
        "Private - Compute the angle of the vector from
         0@0 to aPoint in the interval 0 to 90
         degrees (adjusting for the screen
         aspect ratio).  This method does not use
         floating point."
    | ratio tan x y |
    (y := aPoint y) = 0 ifTrue: [^0].
    (x := aPoint x) = 0 ifTrue: [^90].
    ratio := y abs * 100 // x abs.
    1 to: 89 do: [ :i |
        tan := i integerSin * 100 // i integerCos.
        ratio <= tan
            ifTrue: [^i]].
    ^90!
isValidCharacter: aCharacter
        " Private - Answer true if aCharacter is valid for the current pictureMask."
    |pos mask|
    pictureMask size > 0
        ifTrue: [  "Field has pictureMask"
            pos := self selection x.
            "Don't let the user type beyond the last picture char."
            pos > pictureMask size ifTrue: [^false].
            mask := PictureCharacters at: (pictureMask at: pos) ifAbsent: [^false].
            ^self perform: mask with: aCharacter]
        ifFalse: [^false]! 
decimalPlace
        " Answer the number of digits following the decimal point. "
    decimalPlace == nil
        ifTrue: [decimalPlace:= 0].
    ^decimalPlace!  
pictureMask
    "Return the pictureMask."
    ^pictureMask! 
partPropertyBeginApply: aPropertyStructure
        " Private - apply property changes to the receiver.
         Apply the text limit change now so that it is done
         in time for the value to be applied. "
    ( self partPropertyMaxSizeChanged: aPropertyStructure )
        ifTrue: [ self setTextLimit: (aPropertyStructure propertyAt: #textLimit) value + 1 ].!
numberOfTicks: anInteger
        " Set the number of tick in the dial to anInteger. "
    numberOfTicks := anInteger!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#changed: #fileException: #clicked: #rightClicked #tabbed)
        separators: #( 1 2 )
        defaultItem: #changed:!
resizeToRectangle: aRect
        " Resize the receiver to aRectangle, whose coordinates
        are relative to my parent."
    | oldIconOrBitmap newIconOrBitmap |
    (oldIconOrBitmap := self value) isBitmap ifTrue: [
        newIconOrBitmap := Bitmap screenExtent: aRect extent.
        newIconOrBitmap pen
            copyBitmap: oldIconOrBitmap
            from: oldIconOrBitmap boundingBox
            to: newIconOrBitmap boundingBox.
        oldIconOrBitmap release.
        self value: newIconOrBitmap].
    super resizeToRectangle: aRect.!   
checkDay: dInteger month: mInteger year: yInteger
        " Private - Check the validity of the day anInt1 for the month mInteger
          in the year yInteger. Answer true if date is valid else false."
    | days |
    (days := self daysInMonth: mInteger forYear: yInteger) = 0
        ifTrue: [^false].
    (dInteger < 1 or: [ dInteger > days])
        ifTrue: [^false].
    ^true!  
defaultSize
        " Answer the default size of the tick marks. "
    ^defaultSize!
contents: aValue
        " Private - Set the receiver's datum and its window text. "
    | textLimit str |
    datum := (aValue isString
        ifTrue: [ self createDatumFrom: aValue trimBlanks ]
        ifFalse: [ aValue ] ).
    "If the receiver has the focus or is used as a property entry field, set its contents as the
    unformatted string. "
     (self hasFocus or: [self validateWhenLosingFocus not])
        ifTrue: [
            textLimit:= self unformattedTextLimit.
            str:= self  unformattedString ]
        ifFalse: [
            textLimit:= self formattedTextLimit.
            str:= self  formattedString ].
    self
        setTextLimit:  textLimit;
        setWindowText: str;
        valueAttribute: str;
        modified;
        modified: false.!
unformatString: aString
    " Private - Answer a string without formatting characters specifically
       the currency symbol.  "
    ^aString reject: [:char | char = ( NationalLanguage currency at: 1 ) ].! 
isDigitCharacter: aCharacter
        " Private - Answer true aCharacter is a digit, else answer false."
    ^aCharacter isDigit!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    handle isValid
        ifTrue: [self value].
    copy
        valueAttribute: (self valueAttribute partMirrorCopy: aMirrorCopyDictionary).
    self isReadOnly
        ifTrue: [ copy readOnly ]
        ifFalse: [ copy readWrite ].
    self isWordWrapEnabled
        ifTrue: [  copy enableWordWrap ]
        ifFalse: [  copy disableWordWrap ].
    ^copy!   
isValidDigit: aCharacter
        " Private - Answer true if aCharacter is an acceptable digit, else answer false."
    | input decimalSeparator decimalPos pos currentPos selectedText  digitsCount
    selectedDigitsCount str |
    input := self windowText.
    decimalSeparator := NationalLanguage decimalSeparator first.
    decimalPos := input indexOf: decimalSeparator.
    digitsCount:= selectedDigitsCount:= 0.
    pos := self selection.
    currentPos:= pos x.
   self isGapSelection
        ifTrue: [selectedText := input copyFrom: pos x to: (pos y - 1)].
    selectedText == nil
        ifTrue: [selectedText:= String new]
        ifFalse: [selectedDigitsCount:= (selectedText select: [:char | char isDigit]) size].
    digitsCount:= ((input select: [:char |char isDigit]) size) - selectedDigitsCount.

    self decimalPlace = 0
        ifTrue: [ ^digitsCount < self digits ].
    (input includes: decimalSeparator) not
        ifTrue: [ ^digitsCount < ( self digits - self decimalPlace ). ].

    ((decimalPos ~= 0) and: [(selectedText includes: decimalSeparator) not])
        ifTrue: [
            (currentPos <= decimalPos)
                ifTrue: [
                    str:= (input upTo: decimalSeparator) select: [:char | char isDigit].   "Don't include sign char."
                    digitsCount:= str size - selectedDigitsCount]
                ifFalse: [
                    str:= input copyFrom: (decimalPos + 1) to: input size.
                    digitsCount:= str size - selectedDigitsCount.
                    ^(digitsCount < self decimalPlace) ]].
    ^(digitsCount < (self digits - self decimalPlace))!   
setValue: anIconOrBitmap
        "Set the value of the receiver to anIconOrBitmap.
        Answer anIconOrBitmap. "

    ( anIconOrBitmap isIcon
    or: [ self supportsBothBitmapAndIcon and: [ anIconOrBitmap isBitmap ] ] )
        ifTrue: [ ^super setValue: anIconOrBitmap ].
    ^anIconOrBitmap  " ignore if not valid "!  
initialize
        "Private - Initialize the receiver.  Set empty value and datum
         to an empty string. "
    super initialize.
    self datum: self defaultEmptyValue.!   
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^self
        partsIfOS2Do: [ super defaultStyle ]
        partsIfWindowsDo: [ WsPaneBorder ]!  
defaultStyle
        "Private - Answer default PM window style of the receiver."
    ^MlsBorder
        | MlsMultipleLines
        | MlsAcceptEnterKey
        | MlsVerticalScrollBar
        | EsAutoVerticalScroll
        | WsInitiallyVisible
        | WsClipChildren!   
bitmap
        "Answer a clone of the bitmap associated with the receiver."
    | bitmap |
    bitmap := self propertyAt: #bitmap.
    bitmap isNil
        ifTrue: [ ^Bitmap screenExtent: self extent ]
        ifFalse: [ ^bitmap clone ]!   
initialize
        " Private - Initialize the receiver."
    super initialize.
    self
        useSystemFormat: true;
        twoDigitYear: true.!  
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a graph pane "!
wordWrapStyle
        "Add the word wrap style to the receiver."
    ^self addStyle: MlsWordWrap!   
isValidCharacter: aCharacter
        " Private - Answers true if aCharacter is acceptable, else answers false. "
    ^self isDigitCharacter: aCharacter!
listBox: aListBox
        "Private - Set the list box control for a simple combo box."
    self propertyAt: #listBox put: aListBox! 
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process cursor keys.
         The receiver uses the left and right keys for moving the needle.
         The receiver does not react to the UpKey, DownKey,PageUpKey
             and PageDownKey. "
    | virtualKey disabledKeys newValue |
    ( virtualKey := aKeyboardInputEvent virtualKey ) isNil ifTrue: [ ^nil ].
    disabledKeys := OrderedCollection new
        add: UpKey; add: DownKey; add: PageUpKey; add: PageDownKey;
            add: RightKey; add: LeftKey; yourself.
    ( disabledKeys includes: virtualKey )
        ifTrue: [
            ( ( virtualKey == RightKey) or: [virtualKey == LeftKey] )
                ifTrue: [
                    newValue := ( virtualKey == RightKey )
                        ifTrue: [ self value + 1. ]
                        ifFalse: [ self value - 1].
                    ^self setValue: newValue]
                        ifFalse: [ "disabled keys - do nothing "
                            ^self ].
                    ].
    ^super keyboardInput: aKeyboardInputEvent!  
setFocus
        "Set the focus to the entry field component of the combobox."

    | hostWindowLibrary |
    super setFocus.
    self
        partsIfOS2Do:
            [hostWindowLibrary := PARTSHostInterface hostWindowLibrary.
            hostWindowLibrary
                setFocus: PARTSHostInterface desktopWindowHandle
                hwnd: (WindowHandle fromBytes: ( hostWindowLibrary
                    queryWindow: handle
                    cmd: QwBottom))]!  
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
isValidNumberOfCharacters: aNumber
        " Private - Answer true if aNumber matches the required number of characters for the receiver,
        else answer false.  Default is true.
        When PictureFields loses focus, let #isValidFormat: validate the string. "
    ^true!  
drawSelector
        " Private "
    ^drawSelector! 
partSetGraphics: aBitmap
        " Private - update the receiver's bitmap. "

    self contents: aBitmap.
    "Old (from VOS):
    self handle isValid ifTrue: [
        self realInvalidateRect: nil].
    "! 
isValidNumberOfCharacters: aString
        " Private "
    ^true!   
initializePropertyOptions
        " Private - class initialization. "

    self
        partsIfOS2Do: [
            StyleLabels := Array
                with: (Array with: 'Bitmap' with: SsBitmap)
                with: (Array with: 'Icon' with: SsIcon).
            StyleValues := Array
                with: SsBitmap
                with: SsIcon.
            "DEBUG - check ported implementation"
            ( (StyleLabels =  #( #('Bitmap' 4 ) #('Icon' 3) ) )
            and: [StyleValues =  #(4 3) ] )
                ifFalse: [self error: 'bug'].
            ]
        partsIfWindowsDo: [  " only icon style supported on VW "
            StyleLabels := StyleValues := nil.
            ].!   
setNewDatumWith: aValue
        " Private - Set the previous value and the new value of datum using aValue.
          aValue could be a String (unformatted) or an object with a supported type.
          Trigger the changed event. "
    self
        value: aValue;
        triggerChanged;
        previousValue: self datum.!
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
retryChange
        "Stop the change process, and set the focus back to allow the user
        to modify the receiver and try again."
    self
        datum: self previousValue;
        tryAgain!  
partSetValueMessage
        "Answer the selector of the one-argument message
        which can be sent to the receiver to set its value. "
    ^#setBitmap:!   
abortChange
        "Reject the new value, and restore to what was present
        before the user started typing."
    self datum: self previousValue.
    self setFormattedContents.
     VetoAction signal!   
setReadingsPerDegree
        "Private - set the readingsPerDegree variable."
    readingsPerDegree := highReading - lowReading /
        (self relativeDegree: highDegree)!
partLibraryClassesToInitialize
        " Private - answer the classes in the library which need to be
        initialized when the library is installed. "

    ^#(
        #PARTSDrawnButtonPart
        #PARTSPushButtonPart
        #PARTSCheckBoxPart
        #PARTSRadioButtonPart
        #PARTSComboEntryField
        #PARTSEntryFieldPart
        #PARTSFormattedEntryField
        #PARTSAlphabeticEntryFieldPart
        #PARTSDateEntryFieldPart
        #PARTSNumericField
        #PARTSFixedDecimalEntryFieldPart
        #PARTSCurrencyEntryFieldPart
        #PARTSFloatEntryFieldPart
        #PARTSIntegerEntryFieldPart
        #PARTSPhoneNumberEntryFieldPart
        #PARTSPictureFieldPart
        "PARTSTextPanePart"  " works as is; initialize not available in runtime environment "
        #PARTSComboBoxPart
        #PARTSDropDownListPart
        #PARTSMultipleChoiceListPart
        #PARTSListPanePart
        #PARTSGroupPanePart
        #PARTSStaticGraphicPart
        #PARTSStaticTextPart
        #PARTSGraphPanePart
        #PARTSDialPanePart
        ) collect: [ :className | Smalltalk at: className ]!
contents: anObject
    self setBitmap: anObject! 
font: aFont
        "Set the font for the receiver to aFont."
    | tabSpaces oldFont screenFont |

    self partsIfWindowsDo: [^super font: aFont].
    self partsVosOnly.  " Only used on VOS"

    aFont isNil ifTrue: [ ^self ].
    oldFont := self font.
    oldFont isNil ifTrue: [ oldFont := self defaultFont ].
    screenFont := Display pen font.

    aFont = oldFont
        ifFalse: [                   "do only when the font has changed"
            self fontAttribute: aFont.
            Display pen font: oldFont.
            tabSpaces := self tabStopInterval isNil
                ifTrue: [ 4 ]
                ifFalse: [ self tabStopInterval // oldFont spaceWidth ].
            Display pen font: aFont.
            self tabStopInterval: aFont spaceWidth * tabSpaces.
                    self isHandleOk ifTrue: [
                       "Check for visible because redrawing + setting
                         attributes has side effect of making pane visible"
                    self isVisible
                    ifTrue: [
                    self disableRedraw.
                    self setFont.
                    "There is a bug in PM TextEdit controls.
                     They reset the tab stops when the font is changed."
                    self setTabStop.
                    self enableRedraw ]
                    ifFalse: [
                    self setFont.
                    self setTabStop  ] ] ]
        ifTrue: [ Display pen font: aFont ].

    Display pen font: screenFont.! 
moveSelection: dir
        "Private - Move the selection to the next unprotected
         character. dir indicates which direction to move."
    | position count index lastIsProtected |
    position := self selection x.
    index := position.
    lastIsProtected := false.
    count := 1.
    dir
        ifTrue: [        "skip to the right"
            [index < pictureMask size and: [(lastIsProtected :=
                self isProtected: (pictureMask at: index + 1))]]
                whileTrue: [
                    count := count + 1.
                    index := index + 1].
            lastIsProtected ifTrue: [^self].
            [count > 0]
                whileTrue: [
                    self skipRight.
                    count := count - 1]]

        ifFalse: [      "move left"
            [index > 1 and: [(lastIsProtected :=
                self isProtected: (pictureMask at: index - 1))]]
                whileTrue: [
                    count := count + 1.
                    index := index - 1].
            (lastIsProtected or: [position = 1]) ifTrue: [^self].
            [count > 0]
                whileTrue: [
                    self skipLeft.
                    count := count - 1]]!   
rectangleWithoutMargin: aRect
        "Answer a rectangle based on aRect without
        extra margin."
    self partsVosOnly.
    ^(self hasStyle: LbsNoIntegralHeight)
        ifTrue: [ aRect ]
        ifFalse: [ aRect insetBy: (0 @ 0 extent: 4 @ 0) ]!   
extractDayMonthYear: aString
        " Private - Return a dictionary which contains the date,
            month and year extracted from aString based on the date format."
    | field1 field2 field3 dFormat day month year size|
    size := aString size.
    field1 := aString copyFrom: 1 to: 2.
    field2 := aString copyFrom: 3 to: 4.
    field3 := aString copyFrom: 5 to: aString size.
    dFormat := self dateFormat.
    dFormat = DfMDY  ifTrue: [
        day := field2 asInteger.
        month := field1 asInteger.
        year := field3 asInteger].
    dFormat = DfDMY ifTrue: [
        day := field1 asInteger.
        month := field2 asInteger.
        year := field3 asInteger].
    dFormat = DfYMD ifTrue: [
        day :=  (aString copyFrom: (size - 1) to: size) asInteger.
        month := (aString copyFrom: (size - 3) to: (size - 2)) asInteger .
        year := (aString copyFrom: 1 to: (size - 4)) asInteger  ].
    ^Dictionary new
        at: #day put: day;
        at: #month put: month;
        at: #year put: year;
        yourself!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy pictureMask: pictureMask copy.
    ^copy!  
inputSize
        "Private - Return the position of the last character that is in the
        current window text.  Necessary for setting the focus on the receiver."
    ^self getTextLength! 
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    ^ self partFontOrSysFont charSize * (15 @ 6) + (0 @ 10)!   
valueHasChanged 
    " Private - answer if the value has changed."
    ^self propertyAt: #valueHasChanged ifAbsent: [false ]. ! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        contents: (bitmap partMirrorCopy: aMirrorCopyDictionary);
        drawSelector: drawSelector copy.
    ^copy!
relativeDegree: degreeInteger
        " Private - Answer the total degrees between
         degreeInteger and lowDegree."
    | sweepAngle |
    sweepAngle := lowDegree - degreeInteger.
    sweepAngle < 0
        ifTrue: [
            sweepAngle = -360
                ifTrue: [sweepAngle := 360]
                ifFalse: [
                    sweepAngle := sweepAngle + 360]].
    ^sweepAngle! 
button1UpShift: aPoint
        "Private - The user released button1 while
         holding down a shift key."
        " Platform dependent implementation "
    self partsVwOnly.
    handle = WindowHandle queryCapture ifFalse: [^self].
    PARTSHostInterface hostWindowLibrary
        killTimer: self handle
        idEvent: nil.
    self clearMouseCapture.
    self mainWindow activeTextPane: self.
    self
        displayChanges;
        showSelection.!  
wmCharOS2: mp1 with: mp2
        "Private event - Add a MessageExpression to CurrentEvents
         and return right away. If the character is valid, process #characterInput:;
             else do nothing. "
        | character event |
    self partsVosOnly.
        ( event := KeyboardInputEvent fromWmChar: mp1 with: mp2 ) isNil ifTrue: [ ^true ].
        self sendInputEvent: #keyboardInput: with: event.
            event virtualKey isNil
                ifTrue: [
                ( character := event character ) notNil
                    ifTrue: [
                       ( self isValidCharacter: character )
                        ifTrue: [ self sendInputEvent: #characterInput: with: character ]
                        ifFalse: [ Terminal bell. ^false ]
                                 ]
                           ].
        ^nil!   
append: aString
        "Add aString at the end of the
         text in the pane."

    self contents: (
        self contents,
        ( aString isNil ifTrue: [ '' ] ifFalse: [ aString asString ] ) )!   
wmCharWindows: wordInteger with: longInteger
        "Private - Process the character input message."
    | character event leadByte wparam position |
    self partsVwOnly.
    wparam := wordInteger.
    NationalLanguage isDoubleByteCp
        ifTrue: [
            ( leadByte := self propertyAt: #lastChar ) isNil
                ifTrue: [
                    character := Character value: wordInteger.
                    character isLeadByte ifTrue: [
                        self propertyAt: #lastChar put: character.
                        ^nil ] ]
                ifFalse: [
                    character := Character leadByte: leadByte trailByte: ( Character value: wordInteger ).
                    self propertyAt: #lastChar put: nil.
                    wparam := character asInteger ] ].
    event := KeyboardInputEvent fromWmChar: wparam with: longInteger .
       self sendInputEvent: #keyboardInput: with: event.
        event virtualKey isNil
                ifTrue: [
                ( character := event character ) notNil
                    ifTrue: [
                        position:= self selection x.
                        ( self isValidCharacter: character )
                                ifTrue: [
                                    (pictureMask at: position) = $!!
                                    ifTrue: [character := character asUpperCase].
                                        self isGapSelection ifTrue: [self backspaceSelection].
                                        self insert: character at: position.
                                        self selectFrom: ( position + 1 )   to: ( position ).
                                        self skipProtected: true.
                                        self sendInputEvent: #characterInput: with: character]
                                ifFalse: [
                                        Terminal bell]]].
    ^false! 
defaultPictureCharacterPlaceholder
        " Private - answer the character which represents a 
        picture mask character for which no character has been
        entered while editing the unformatted string. "
    ^$_!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToChange #changed: 
             #rightClicked #tabbed )
        separators: #( 2 )
        defaultItem: #changed:!   
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
errorString
        "Return the default error string"
    ^'Invalid input'! 
initializeRuntimeData
        " Private - the library has just been installed.  Initialize state. "

    self partLibraryClassesToInitialize do: [ :aClass | aClass initialize ].! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #clear #selectAll
            #value #setValue: #valueFormatted
            #abortChange #retryChange )
        separators: #( 3 5 8  )
        defaultItem: #value!   
dateFormat
        " Answer the date format "
    ^( self useSystemFormat or: [dateFormat isNil] )
        ifTrue: [NationalLanguage dateFormat]
        ifFalse: [dateFormat]!   
initialize
        " Private - initialize a new instance. "

    super initialize.
    self autoCheckBox.!
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."
    self partsVosOnly.  " Only used on VOS"

    ^self class noScrollbarsFrameStyle!
partSetDirectEditAttribute: text
        " Private - set the direct-edit attribute of the receiver
        to text. Remove any formatting characters which the
        direct text editor retained from the previous (formatted)
        contents of the receiver. "
    self value: text .! 
removePartRuntimeLibrary
        " Private - remove the basic visual parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!  
value
        "Answer the value of the receiver as a boolean."
    self selection ifTrue: [self triggerEvent: #valueIsOn].
    ^value! 
highReading: anInteger
        " Set the high reading of the receiver to anInteger. "
    dial highReading: anInteger!  
defaultEmptyValue
        " Private - answer the default empty value "
    ^String new! 
PARTSPushButtonPart removePartRuntimeLibrary! 
subclassRecursively
		"Private - no need to subclass at runtime."
    self partIsEditing ifTrue: [
        self subclassWndProc]!  
commitSelection
        "Private - Answer true if list box should
         commit to selection request.  The commitSelection
        design is obsolete and not supported by PARTS lists
        (use the #aboutToChange event if appropriate). "

    ^true!   
replaceWithText: aString at: anInteger
        "Private - Replace the current selection with aString."
    | text pos |
    text := self windowText.
    pos := anInteger.
    text
        replaceFrom:pos
        to: pos
        with: aString
        startingAt: 1.
    self setWindowText: text.! 
dateFormatProperties: formatDict
        " Private - update the date format properties "
    self
        dateSeparator: (formatDict at: 'dateSeparator');
        dateFormat: (formatDict at: 'format');
        twoDigitYear: (formatDict at: 'twoDigitYear');
        useSystemFormat: (formatDict at: 'useSystemFormat').!  
isValidCharacter: aCharacter
        " Private - Answer true if aCharacter is a positive integer, else answer false."
    ^self isDigitCharacter: aCharacter!   
ticks
        " Answer the number of ticks in the dial. "
    ^ticks!   
isValidInputtedString: aString
    " Private - Answer if aString is a valid inputted string.  Note that since <aString>
      is an inputted string, character validation is not necessary."
    ^( aString isEmpty or: [
                (self isValidNumberOfCharacters: aString size)
                   and: [self isValidFormat: aString] ] )!  
lastSelection
        " Private "
    ^self propertyAt: #lastSelection! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #bitmap #setBitmap: #clearBitmap
                #copyToClipboard #pasteFromClipboard
                #setFromBitmapFile: #setFromIconFile:
            #pen)
        separators: #( 3 10 )
        defaultItem: #bitmap! 
unformatString: aString
        "Private - Answers the unformatted value of aString.  Default behavior is that
        no special formatting is needed.  Should be re-implemented by subclasses."
    ^aString!
setFormattedContents
    " Private - Set the formatted contents and text limit of the receiver."
    self
        setTextLimit: self formattedTextLimit;
        setWindowText: self formattedString.!
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #valueIsOn
            );
         yourself!
drawSelector: aSymbol
        " Private "
    drawSelector := aSymbol.! 
formattedString
        " Private - Return datum as a formatted string."
    ^(datum == nil or: [datum = ''])
        ifTrue: ['']
        ifFalse: [self formatString: (datum printFraction: self decimalPlace) ]!   
digits
        " Return the number of digits the receiver can have. "
    ^digits isNil
        ifTrue: [self defaultTextLimit ]
        ifFalse: [digits]!   
partSetContents: aDict
        " Set the PARTS contents of the receiver.
               aDict contains data from the Edit Contents... dialog. "
    | lowReading highReading lowDegree highDegree |
    lowReading := aDict at: 'lowReading'.
    highReading := aDict at: 'highReading'.
    lowDegree := aDict at: 'lowAngle'.
    highDegree := aDict at: 'highAngle'.
    dial initDial: lowReading
        highReading: highReading
        lowDegree: lowDegree
        highDegree: highDegree;
        numberOfTicks: (aDict at: 'numberOfTicks');
        defaultSize: (aDict at: 'defaultSize');
        interval: (aDict at: 'tickInterval');
        autoLabels: (aDict at: 'autoLabels');
        ticks: (aDict at: 'ticks').
    dial setReading: (aDict at: 'initSetting').
    self erase.
    self display!
lowAngle: anInteger
        " Set the low angle of the receiver. "
    dial lowDegree: anInteger!   
arcTan: aPoint
        "Private - Compute the angle of the vector from
         0@0 to aPoint in the interval 0 to 360
         degrees (adjusting for the screen
         aspect ratio).  This method does not use
         floating point."

    | degree |
    "In Windows the y value for the axis going north is negative (not positive
    like in OS/2)."
    self
        partsIfOS2Do: [
            degree := self arcTan90: aPoint.
            aPoint x < 0
                ifTrue: [
                    aPoint y < 0
                        ifTrue: [^180 + degree]
                        ifFalse: [^180 - degree]]
                ifFalse: [
                    aPoint y < 0
                        ifTrue: [^360 - degree]
                        ifFalse: [^degree]] ]
        partsIfWindowsDo: [
            degree := self arcTan90: aPoint.
            aPoint x < 0
                ifTrue: [
                    aPoint y < 0
                        ifTrue: [^180 - degree]
                        ifFalse: [^180 + degree]]
                ifFalse: [
                    aPoint y < 0
                        ifTrue: [^360 + degree]
                        ifFalse: [^ degree negated]]
                                    ].!   
initialize
    " Private - initialize class values
        PARTSListPanePart initialize
    "

    SupportsShowDisabledScrollbar := ( self
        partsIfOS2Do: [ false ]
        partsIfWindowsDo: [ true ] ).
    ^super initialize!   
add: arg
        "Add the contents of the receiver to arg."
    | x  y |
    x := self value.
    x isNil ifTrue: [ x := 0 ].
    y := arg.
    y isNumber ifFalse: [ y:= y asString asNumber ].
    [ ^ x + y  ]
        on: Error
        do: [ ^self arithmeticErrorMessage ].!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
             #enable #disable #setFocus
             #clear #selectAll
             #value #setValue: #valueFormatted
             #abortChange #retryChange
           #add: #subtract: #multiply: #divide:)
        separators: #( 3 5 8 10 )
        defaultItem: #value! 
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
unformattedTextLimit
        " Private - Return the text limit of the receiver's unformatted String.
          By default the formatted and unformatted text limit is the
          same because there is no extra string formatting needed."
    ^self textLimit!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToChange #changed: #changedIndex: #doubleClicked:
            #rightClicked #tabbed)
        separators: #( 4 )
        defaultItem: #changed:!   
pictureMaskWithoutProtectedCharacters
        "Private - Answer pictureMask without the protected characters.."
    |str |
    str := String new.
    pictureMask do: [:char |
        (self isProtected: char)
            ifFalse: [str:= str, (String with: char)]].
    ^str!  
initialize
        " Private "
    super initialize.
    self contents: 'Text'.!   
pictureCharacterPlaceholder
        " Private - answer the character which represents a 
        picture mask character for which no character has been
        entered while editing the unformatted string. "
    ^pictureCharacterPlaceholder! 
changeReading: anInteger
        "Private - Answer the difference between anInteger
         and old reading. Draw needle to reflect
         the new reading anInteger."
    | newReading |
    newReading := (anInteger max: lowReading) min: highReading.
    lastChange := newReading rounded - reading rounded.
    reading := newReading.
    lastChange = 0
        ifFalse: [
            self eraseNeedle.
            self drawNeedle].
    ^lastChange!
processVirtualKeyInput: anInt
        " Private - answer whether the virtual key anInt is handled by the receiver.
         DialPane uses left and right keys for moving the hand. "
    | disabledKeys |
    disabledKeys := OrderedCollection new
        add: UpKey; add: DownKey; add: PageUpKey; add: PageDownKey; yourself.
    ( disabledKeys includes: anInt )
        ifTrue: [^true].
    anInt = RightKey
        ifTrue: [
            self setValue: self value + 1.
            ^true ].
    anInt = LeftKey
        ifTrue: [
            self setValue: self value - 1.
            ^true ].
    ^false!  
isValidFormat: aString
        "Private- Answer true if aString contains a valid format,else answer false.
        Check that $+, $-, $. and $e are followed by digits."
    | nonDigits str |
    str:= aString asLowerCase.
    nonDigits:= #($+ $- $e).
    ( ( str size = 1 ) and: [ ( str at: 1 ) = $.] )
        ifTrue: [^false].
    ^( ((str size = 1) and: [nonDigits includes: str first]) or: [nonDigits includes: str last]) not!
button1Down: aPoint
        "Private - since control toggles selection, only record it."
    self recordLastSelection.
	^super button1Down: aPoint!
backspace
        "Private - Process the backspace key."
    | position |
    self isGapSelection ifTrue: [^self backspaceSelection].
    self moveSelection: false.
    position := self selection x.
    self insert: self pictureCharacterPlaceholder at: position.
    self selectFrom: (position )  to: (position - 1  )! 
signed: aBoolean
    " If aBoolean is true, the receiver handles a signed (+ or -) value;
        else it does not. "
 signed := aBoolean! 
validate
        "Private - Display the control."
    self valueAttribute: self formattedString.
    super validate.
	self previousValue: self value! 
wmSetfocus: mp1 with: mp2
    "Private - Process the set focus message.  If the receiver is getting the focus,
    execute the super method.  If the receiver is losing the focus,  synchronously validate
    the receiver's input and confirm or veto the new value.  If the controls which lost and
    received the focus do not have the same parent, do not execute the validation process.
    Instead, leave the contents alone, so that the user can come back and finish entering
    the new value. "

    | subPaneWithFocus result |

    self
        partsIfOS2Do: [
            mp2 asBoolean
                ifTrue: [ self gettingFocus. ^nil ]
                ifFalse: [
                    subPaneWithFocus := self getSubPaneWithFocus: mp1.
                    ^( result := self processLosingFocusTo: subPaneWithFocus ) == self
                        ifTrue: [
                            self subPaneWithFocus: subPaneWithFocus.
                            ^super wmSetfocus: mp1 with: mp2  ]
                        ifFalse: [ result ] ] ] .
    ^super wmSetfocus: mp1 with: mp2!
isValidType: anObject
    "Private - Answer true if anObject is an Integer, else answer false."
    ^anObject isInteger!
multiply: arg
        "Multiple the contents of the receiver by arg."
    | x y |
    x := self value.
    x isNil ifTrue: [ x := 0 ].
    y := arg.
    y isNumber ifFalse: [ y:= y asString asNumber ].
    [ ^x * y  ]
        on: Error
        do: [^self arithmeticErrorMessage ].!
createUnformattedStringFromValue: aValue
         "Private - answer an unformatted string from aValue. "
    ^(aValue == nil or: [aValue = ''])
        ifTrue: ['']
        ifFalse: [aValue printFraction: (self decimalPlace)]!
partEvents
        " Answer the PARTS event interface of the receiver. "

    ^PARTSInterfaceList new
        items: #( #mnemonicTyped )
        separators: #( )
        defaultItem: #mnemonicTyped!  
partOverlappedWindow: aPoint
        "Private - Since the receiver has no overlapping siblings
          just answer its parent which is the combo box."
    ^self parent! 
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartTextFont!   
button1Up: aPoint
        "Private - Button 1 has been released.
        Let the owner process the event."
    handle = WindowHandle queryCapture ifFalse: [^self].
    self clearMouseCapture.
    mouse := aPoint.
    self shouldHaveFocus. "O.W. won't get wmChar"
    self event: #button1Up.
    self triggerEvent: #clicked: with: aPoint.!
gettingFocus
        "Private -  the receiver is getting the input focus.
         If the receiver is being used in a situation where it shouldn't format its contents,  leave the
        current window text alone.  These situations are when it is being used as a property field
        and when it's value is being edited: invalid value or retryChange message. "
    | newStr |
    self isReadOnly ifTrue: [^super gettingFocus].
    self setTextLimit: self unformattedTextLimit.
    newStr:= self editValue.
    self validateWhenLosingFocus
        ifTrue: [ self setWindowText: newStr ].
    self partsIfWindowsDo: [
        self selection = (0@0) " the receiver has no text selected"
            ifFalse: [ " Set the caret at the end of the window text. "
                ( self isKindOf: PARTSPictureFieldPart )
                    ifTrue: [newStr:= newStr reject: [:char | char = self pictureCharacterPlaceholder ] ].
                self selectFrom: (newStr size + 1) to: newStr size. ]].
    ^super gettingFocus.!  
dateSeparator: aString
        "Assign the date separator."
    dateSeparator :=  aString!  
isIntegerCharacter: aCharacter
        " Private - Answer true if aCharacter is an acceptable character
          for a Integer, else answer false."
    | pos |
    pos := self selection x.
    ((aCharacter = $- or: [aCharacter = $+]) and:[ pos = 1])
       ifTrue:[^true].
    ^aCharacter isDigit! 
getSubPaneWithFocus: arg1
    " Private - Return the window with the focus by using <arg1>. "
    | window |
    ^self
        partsIfOS2Do: [
            window:= Notifier findWindow: arg1 asWindowHandle asInteger.
            window isNil ifTrue: [ window:= Notifier getFocusWindow].
            window ]
        partsIfWindowsDo: [ Notifier findWindow: arg1  ]
!
isValidDecimalSeparatorPosition: aCharacter
        " Private - Answer true if a decimal separator is being placed in the
        right position.  A decimal separator is only valid in the mantissa meaning
        anywhere before the exponent separator if there is one.  There could only
        be one decimal separator."
    | decimalSeparator input selectedText pos exponentPos currentPos|
    decimalSeparator:= aCharacter.
    input := self windowText asLowerCase.
    pos := self selection.
    (pos x - pos y) abs > 0
        ifTrue: [selectedText := input copyFrom: pos x to: (pos y - 1)].

    (input includes: decimalSeparator) not
        ifTrue: [
            ((exponentPos:= input indexOfString: 'e') = 0 )
                ifTrue: [^true]
                ifFalse: [  "Only valid before the exponent separator."
                    currentPos:= pos x.
                    ^currentPos < (exponentPos - 1)]]
        ifFalse: [
            selectedText == nil
                  ifFalse: [^selectedText includes: decimalSeparator]].
    ^false! 
defaultDial
        " Answer a default dial for the receiver. "
    ^PARTSDial defaultDial! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus #\
            #label #setLabel: )
        separatorMarker: #\
        defaultItem: #disable!
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
button1Move: aPoint
        "Private - The user moved the mouse to aPoint
         while holding down button 1; change the state
         of each item the cursor moves over to match the
         state of the first selected item"
    | cursor last |
    cursor := self getLastSelection.
    ( cursor ~= ( last := self lastSelection ) )
        ifTrue: [
            self recordLastSelection.
            (self isIndexSelected: last)
                ifTrue: [self selectIndexPrivate: cursor]
                ifFalse: [self deselectIndexPrivate: cursor]].
    super button1Move: aPoint!  
createDatumFrom: aValue
        "Private - Answer a data object from aString. A data object
         can be an Integer, a Date, a Float, etc.. The default is a
         String object.  Non string data objects are implemented by
        the subclasses"
	| newValue |
	newValue:= ( self isValidType: aValue )
		ifTrue: [ aValue ]
		ifFalse: [ aValue asString ].		
    ^newValue trimBlanks isEmpty
        ifTrue: [ self emptyValue ]
        ifFalse: [ newValue ].! 
shouldHaveFocus
        "Ensure that the receiver has the input focus."
    self hasFocus ifFalse: [self setFocus]! 
isValidFormat: aString
        " Private- Answer true if aString contains a valid format,else answer false.
        Check that $+ and $- are followed by digits."
    | nonDigits  |
    nonDigits:= #($+ $- ).
    ^( ( aString size = 1 ) and: [ nonDigits includes: ( aString first ) ] ) not!
setValue: anObject
        " Validate and set the datum of the receiver to be anObject.
          anObject could be a String (unformatted) or an object with a supported type.
          Return anObject.  "
    | input changed newValue |
   input := ( anObject isNil
        ifTrue: [String new]
        ifFalse: [anObject] ).
    changed := (
        input isString  "Check if input is different than window text or unformatted string."
            ifTrue: [ (input ~= self windowText) or: [input ~= self unformattedString] ]
            ifFalse: [ input ~= self datum ] ).
   changed
        ifTrue: [
            ( self isValidDatum: input )
                ifTrue: [
                    newValue:= self createDatumFrom: input.
                    self datum: newValue.
                    self triggerAboutToChangeTo: newValue.
                    datum ~= self previousValue ifTrue: [
                        self setNewDatumWith:  newValue ].
                               ]
                ifFalse: [
                    self
                        triggerEvent: #valueException:
                        withArguments: (Array with: input)
                        ifNotHandled: [self errorPrompt] ] ].
    ^anObject! 
formatString: aString
    " Private - Return datum as a string with formatting characters.  In picture fields, the
    formatted and unformatted strings are the same."
    | str pos |
    str:= self stringWithProtectedCharacters copy.
    aString size = 0 ifTrue: [^str].
    pos:= 1.
    1 to: str size do: [:index |
        ((self isProtected: (pictureMask at: index)) not)
            ifTrue: [
                str:= str at: index put: (aString at: pos); yourself.
                pos:= pos + 1]].
    ^str!
close
        "Private - Close the receiver."
    | listBox |
    super close.
    (listBox := self listBox) notNil
        ifTrue: [ listBox stopReceivingMessages ]!   
setPictureMask: aString1 andValue: aString2 of: aPictureField
        " Private - Set the new picture mask (aString1) of aPictureField.
         Try to fit the datum (aString2) into the new picture mask.
         If aString2 is an invalid datum , reset datum."
    |newDatum|
    aPictureField pictureMask: aString1.
    newDatum:= aString2.
    (aPictureField isValidString: newDatum )
        ifFalse: [newDatum:= ''].
    aPictureField value: newDatum.! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        textLimit: (self textLimit partMirrorCopy: aMirrorCopyDictionary);
        emptyValue: (emptyValue partMirrorCopy: aMirrorCopyDictionary).
    ^copy!
partNewValueEvent
        "Answer the selector of the one-argument event
        which is triggered by the receiver when its value
        has been changed. "
    ^#changed:!
bitmap: aBitmap
        "Set the label of the receiver to aBitmap."
    self label: aBitmap.!   
errorString
        "Return the error string"
    ^'Invalid date'!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #clicked: #turnedOn "turnedOff"    "don't get turnedOff event from system"
            #valueIsOn
            #rightClicked #tabbed )
        separators: #(3 4)
        defaultItem: #clicked:!   
partEvents
        " Answer the PARTS event interface of the receiver. " 
    ^PARTSInterfaceList new
        items: #(
               #aboutToChangeTo: #changed: 
                #entered: #rightClicked #backTabbled #tabbed
                #gettingFocus #losingFocus
           #valueException: )
        separators: #( 2 6 8)
        defaultItem: #changed:  !
setToPoint: aPoint
        "Private - Set the reading of the receiver
         dial so the line defined by the
         needle goes through aPoint."
    self setToDegree:
        (self arcTan: aPoint - center)!   
lafStopEdit
        " Private "
    | oldReading newReading |
    oldReading := self propertyAt: #lafEditOldValue.
    newReading := self value.
    oldReading = newReading ifTrue: [^self].
    self partEditor
        recordUndo: (Message new
            receiver: self
            selector: #setValue:
            arguments: (Array with: oldReading))
        undoLabel: 'direct edit'
        redo: (Message new
            receiver: self
            selector: #setValue:
            arguments: (Array with: newReading))
        redoLabel: 'direct edit'.
    "self erase."
    self realInvalidateRect: nil!  
activate
        "Private - the receiver has been activated,
        make it the active text pane (owns the edit
        menu)."

	^self partIsEditing
		ifTrue: [ true ]
		ifFalse: [ super activate ]!   
backspaceSelection
        "Private - Replace the selected text in the pictureMask."
    | start stop position str text |
    position := self selection.
	start:= position x.
	stop:= self 
				partsIfOS2Do: [ position y - 1] 
				partsIfWindowsDo: [position  y ].
    str := pictureMask copyFrom: start to: stop.
    1 to: str size do: [: index |
        (self isProtected: (str at: index))
            ifFalse: [str at: index put: self pictureCharacterPlaceholder]].
    text := self windowText.
    text replaceFrom: start
        to: stop
        with: str .
    self setWindowText: text asParameter.
    self selectFrom: (start - 1) to: (start - 1).
    self skipProtected: true! 
lowReading: anInteger
        " Set the low reading of the receiver. "
    dial lowReading: anInteger!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #valueIndex #setValueIndex:
            #list #setList: #insertItem: #deleteItem: #deleteAll
            #abortChange
            )
        separators: #( 3 7 12 )
        defaultItem: #value!
commitSelection
        "Private - Answer true if list box should
         commit to selection request.  The commitSelection
        design is obsolete and not supported by PARTS lists
        (use the #aboutToChange event if appropriate). "

    ^true!   
moveDialTo: aPoint
        " Private - reset the dial and trigger the changed event.
        Disable interrupts so wmPaint message won' interfere. "
    | interruptState |
    interruptState := Process enableInterrupts: false.
    dial
        lastChange: 0;
        setToPoint: aPoint.
    Process enableInterrupts: interruptState.
    self triggerChanged.!   
setScale
        "Private - don't set the scaling transformation if the
         the receiver has a bitmap."

    self bitmapIfAbsent: [ super setScale ] !   
sendButtonUpTo: aHandle

    "Private - fix needed if a DialogBox is opened in response to an invalid input or the aboutToChangeTo:
    message.  Bringing up the DialogBox prevents the 'button up' message from being processed,
    leaving the control which lost the focus to think that it's mouse button is still down. This can
    prevent acceptance of any keyboard input or highlighting when the mouse is dragged."
    
   " self partsVwOnly. "
    PARTSHostInterface
        sendWindowMessageInt: aHandle
        msg: (PARTSConstants at: 'WmButton1Up' )
        parm1: 0
        parm2: 0 .! 
isValidCharacter: aCharacter
        " Private - Answer true if aCharacter is acceptable for a
          Float, else answer false."
    |decimalSeparator|
    decimalSeparator := NationalLanguage decimalSeparator first.
    ((aCharacter = $-) or: [aCharacter = $+])
        ifTrue: [^self isValidSignPosition: aCharacter].
    aCharacter = decimalSeparator
        ifTrue: [^self isValidDecimalSeparatorPosition: aCharacter].
    ((aCharacter = $e) or: [aCharacter = $E] )
        ifTrue: [^self isValidExponentSeparatorPosition: aCharacter].
    aCharacter isDigit
        ifTrue: [^self isDigitCharacter: aCharacter].
    ^false!  
unformattedTextLimit
        " Private - Return the text limit of the receiver's unformatted string. "
    ^10! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #clear #selectAll
            #value #setValue:
            #abortChange #retryChange )
        separators: #( 3 5 7 )
        defaultItem: #value!
realInvalidateRect: aRectangle
    
    "can't use mainWindow, O.W. notebook page won't work"
    self superWindow isSubPane
        ifTrue: [
            self superWindow realInvalidateRect: nil]
        ifFalse: [super realInvalidateRect: aRectangle]!   
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
errorString
    "Return the error string."
    ^'Invalid currency '!
initialize
        "Private - Initialize the receiver.  Set empty value to the default. "
    super initialize.
    self emptyValue: self defaultEmptyValue.!  
setValue: aValue
        "Set the text contents of the receiver to the string representing
        aValue.  Check if the size of aValue exceeds the textLimit of
        the receiver.  If it does, put up an error message box.  Else,
        set the value, with a possiblity that it may be undone.
        Then, trigger aboutToChangeTo:, where the value may be restored
        to the previous value, or it may be set to an entirly new value.
        At the end, if the final value is different from the beginning value,
        trigger the changed event if the value is changed.
        Answer aValue."
    | newValue |
    newValue := ( aValue isString
        ifTrue: [ aValue ]
        ifFalse: [ aValue isNil ifTrue: [ '' ] ifFalse: [ aValue asString ] ] ).
    ( self isValidNumberOfCharacters: newValue size )
        ifTrue: [ super setValue: newValue ]
        ifFalse: [
            self
                triggerEvent: #valueException:
                withArguments: (Array with: newValue)
                ifNotHandled: [ self errorPrompt ] ] .
    ^aValue! 
initialize
        "Private - set the contents."
    super initialize.
    self supportsBothBitmapAndIcon
        ifTrue: [self value: self getDefaultBitmap ]
        ifFalse: [self value: self getDefaultIcon]!   
setFromIconFile: aPathName
        "Set the bitmap of the receiver from the .ico file
        called aPathName.  Trigger the changed event. "
    | anIcon |
    aPathName isNil ifTrue: [^nil].
    ((File exists: aPathName) not
    or: [ [ (anIcon := Icon fromFile: aPathName) isIcon not ] on: Error do: [ true ] ] )
        ifTrue: [
            self
                triggerEvent: #fileException: withArguments: (Array with: aPathName)
                ifNotHandled: [
                    MessageBox
                        notify: 'GraphPane Problem'
                        withText: 'File ', aPathName,
                            ' does not exist or does not contain an icon.'].
            ^nil].
    self setBitmap: anIcon.
    ^aPathName! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #clicked: #checked #unchecked
            #valueIsOn
            #rightClicked #tabbed )
        separators: #(3 4)
        defaultItem: #clicked:!
validateInput: aString
        "Return true if the input is valid, else return false.
        Used by PARTSDirectTextEditor>>lafStopEdit
         for validating the input after direct editing.
        Since the direct text editor does not validate each character
        we need to validate the whole string. This is the same scenario
        when the message #setValue: is being used. "
    ^self isValidDatum: aString!   
value
        "Answer the text contents of the receiver.
        If the text contents isEmpty return emptyValue. "
    | answer |
    answer := self contents.
    ^( answer isNil or: [ answer isEmpty ])
        ifTrue: [ self emptyValue ]
        ifFalse: [ answer ]!
value
        " Answer the current reading on the dial. "
    ^dial reading!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #label #setLabel: )
        separators: #( )
        defaultItem: #setLabel:!
rightButtonScroll: point
        "Private - Do right button scrolling."
        " Scrolling not supported for receiver. "!  
button1DownShift: aPoint
        "Private - The user pressed down button 1 at aPoint
         while holding down a shift key; change the state of
         all items between the first item selected and
         the item just selected to match the state of the
         first item selected"
    | first firstIsSelected last inc |
    ( first := self lastSelection ) isNil
        ifTrue: [
            first := 1.
            firstIsSelected := true ]
        ifFalse: [firstIsSelected := self isIndexSelected: first].
    last := self getLastSelection.
    "self disableUpdate."
    inc := (first <= last)
        ifTrue: [1]
        ifFalse: [-1].
    firstIsSelected
        ifTrue: [
            self deselectIndexPrivate: last.    "force focus to the last changed one"
            first to: last by: inc do: [ :item | self selectIndexPrivate: item ] ]
        ifFalse: [
            self selectIndexPrivate: last.
            first to: last by: inc do: [ :item | self deselectIndexPrivate: item ] ].
    self recordLastSelection.
    "self enableUpdate"!
initializePropertyOptions
        " Private - class initialization. "

    self
        partsIfOS2Do: [
            SupportsLabelLeftOfButton := false.
            ]
        partsIfWindowsDo: [
            SupportsLabelLeftOfButton := true.
            ].! 
highReading
        " Return the high reading of the dial. "
    ^highReading!  
close
        "Private - Close the receiver and destroy the device context."
    self releaseBitmap.
    ^super close! 
close
        "Private - Close the subpane."
    (value isBitmap or: [value isIcon])
        ifTrue: [ value release ].
    super close.! 
isValidType: anObject
    "Private - Answer true if anObject is a Float, else answer false."
    ^anObject isFloat! 
addCurrencySymbol: str
    " Private - Add the currency symbol according to the current system settings. "
    | currencySymbol currencyFormat |
    currencySymbol  := NationalLanguage currency.
    currencyFormat:= NationalLanguage currencyFormat.
    currencyFormat = 0
        ifTrue: [^currencySymbol, str].
    currencyFormat = 1
        ifTrue: [^str, currencySymbol].
    currencyFormat = 2
        ifTrue: [^currencySymbol,' ', str].
    currencyFormat = 3
        ifTrue: [^str, ' ',currencySymbol].! 
setReading: anInteger
        " Private - Set reading to anInteger without drawing the needle."
    reading := (anInteger max: lowReading) min: highReading!
formattedString
        "Private - Answer datum as a formatted string."
    | date |
    ^( datum == nil or: [datum = ''] )
        ifTrue: ['']
        ifFalse: [
            date := datum
                printInFormat: self dateFormat
                twoDigitYear: self twoDigitYear.
            self formatString: date.]! 
createUnformattedStringFromValue: aValue
        "Private - answer an unformatted string from aValue. "
    |date |
    ^( aValue == nil or: [aValue = ''] )
        ifTrue: ['']
        ifFalse: [
            date := aValue
                printInFormat: self dateFormat
                twoDigitYear: self twoDigitYear.
            self unformatString: date].! 
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^self
        partsIfOS2Do: [ super defaultStyle ]
        partsIfWindowsDo: [
            WsPaneBorder |
            WsHorizontalScrollBar |
            WsVerticalScrollBar "|  WsClipSiblings  can't put in group box with WsClipsiblings"
        ]!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #changed: #entered:
            #rightClicked #tabbed)
        separators: #( 2 )
        defaultItem: #changed:!   
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
partNewValueEvent
        "Answer the selector of the one-argument event
        which is triggered by the receiver when its value
        has been changed. "
    ^#changedIndex:!   
errorString
    "Return the error string."
    ^'Invalid phone number '!
unformatString: aString
    " Private - Return aString with formatting characters.  In picture fields, the
    formatted and unformatted strings are the same."
    ^self formatString: aString!   
bitmap
        "Answer a clone of the receiver's bitmap."
    | aBitmap |
    aBitmap := self contents.
    aBitmap isBitmap
        ifTrue: [ ^aBitmap clone ]
        ifFalse: [ ^nil ]!  
icon: anIcon
        "Answer a new static icon control with the referenced icon."
    ^self icon
        contents: anIcon;
        yourself!  
tryAgain
        " Private - The receiver had invalid input.  Set the focus back to the receiver
          and let the user try again.  Set validateWhenLosingFocus flag so that  #gettingFocus
          knows not to format the receivers' contents.  "
    self
        sendInputEvent: #validateWhenLosingFocus: with: false;
        sendInputEvent: #resetFocus;
        sendInputEvent: #validateWhenLosingFocus: with:  true.! 
formatString: aString
        " Private - Answers the formatted value of aString.  Default behavior is that
        no special formatting is needed.  Should be re-implemented by subclasses."
    ^aString!   
setFromBitmapFile: aPathName
        "Set the bitmap of the receiver from the .bmp file
        called aPathName.  Trigger the changed event. "
    | aBitmap |
    aPathName isNil ifTrue: [^nil].
    ((File exists: aPathName) not
    or: [ [ (aBitmap := Bitmap fromFile: aPathName) isBitmap not ] on: Error do: [ true ] ] )
        ifTrue: [
            self
                triggerEvent: #fileException: withArguments: (Array with: aPathName)
                ifNotHandled: [
                    MessageBox
                        notify: 'GraphPane Problem'
                        withText: 'File ', aPathName,
                            ' does not exist or does not contain a bitmap.'].
            ^nil].
    self setBitmap: aBitmap.
    ^aPathName!   
createUnformattedStringFromValue: aValue
        "Private - answer an unformatted string from aValue. "
    ^self unformatString: aValue!   
eventTableCreate
        "Private - answer an empty dictionary for use as an event table.
		Create a larger than normal dictionary for graph pane part."
    ^IdentityDictionary new: 3!   
formattedTextLimit
        "Private - Return the formatted text limit of the receiver.  By default the
         formatted and unformatted text limit is the same because there is no
         extra string formatting needed.  For formatted entry fields such as
        Currency, Date, Float and Phone in which formatting characters are
        added into the formatted string, return the size of that string.  "
    | limit |
    limit := self unformattedTextLimit.
    ^limit isNil
        ifTrue: [limit]
        ifFalse: [limit max: (self formattedString size)]!  
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - not supported by a drawn button "!
isValidString: aString
        "Private - Answer true if aString contains a valid float value. Floats can
        have three formats: -(+)digits.digits,  -(+)digits.digits e(E)-(+)digits
                                            or -(+)digits e(E)-(+)digits."
    |mantissa str pos exponent|
    str := aString trimBlanks.
    str isEmpty ifTrue: [^true].
    str := str asLowerCase.
    pos := 0.
    (str includes: $e) ifTrue: [pos:= (mantissa:= str upTo: $e) size].
    ( pos = 0 )
        ifTrue: [ ^self isValidFloatString: aString]
        ifFalse: [
            exponent:= str copyFrom:  (pos + 1)  to: str size.
            ^((self isValidMantissaString: mantissa) and: [self isValidExponentString: exponent]) ]!  
valueHasChanged: aBoolean 
    " Private - set if the value has changed."
    ^self propertyAt: #valueHasChanged put: aBoolean !
skipProtected: dir
        "Private - Skip over protected characters in the direction
         indicated by dir from the current selection. "
    | position count lastIsProtected |
    position := self selection x .
    count := 0.
    lastIsProtected := false.
    dir
        ifTrue: [        "skip to the right"
            [position <= pictureMask size and: [lastIsProtected :=
                self isProtected: (pictureMask at: position)]]
                whileTrue: [
                    count := count + 1.
                    position := position + 1].
            ((position = pictureMask size) and:
                [self isProtected: (pictureMask at: position)])
                ifTrue: [self skipLeft.  ^true].
            lastIsProtected ifTrue: [^self].
            [count > 0]
                whileTrue: [
                    self skipRight.
                    count := count - 1]]
        ifFalse: [      "skip to the left"
            [position > 1 and: [lastIsProtected :=
                self isProtected: (pictureMask at: position  )]]
                    whileTrue: [
                        count := count + 1.
                        position := position - 1].
            ((position = 1) and:
                [self isProtected: (pictureMask at: position)])
                ifTrue: [self skipRight.  ^true].
            (lastIsProtected or: [position = 1]) ifTrue: [^self ].
            [count > 0]
                whileTrue: [
                    self skipLeft.
                    count := count - 1]].!   
commitSelection
        "Private - Answer true if list box should
         commit to selection request.  The commitSelection
        design is obsolete and not supported by PARTS lists
        (use the #aboutToChange event if appropriate). "

    ^true!   
processValidInput: aString focusPane: aControl
    " Private - Trigger the #aboutToChangeTo: <aString> event and return 'self' if
        the new value is still valid, else return nil. "
    ^( self isOkToChangeTo: ( self createDatumFrom: aString ) )
        ifTrue: [ self ]
        ifFalse: [
            self sendInputEvent: #sendButtonUpTo: with: aControl  handle.
            self partsIfWindowsDo: [self subPaneWithFocus: aControl. ].
            self sendDeferredEvent: #isEndUserEditing: with: false.  " aborted changes"
            nil ]!  
contents
    "Private - return nothing"
    ^nil!   
isValidFormat: aString
    " Private - Answer true if aString has a valid format, else answer false.
     The number of digits in aString cannot exceed
      the max number of digits and aString can only have a sign
      character if signed is true. "
    | sign str |

    "Check for the sign character."
    str:= aString.
    sign := str at: 1.
    (sign = $+ or: [sign = $-])
        ifTrue: [
           (self signed)  ifFalse: [ ^false].
            str size = 1 ifTrue: [^false].
           str := str copyFrom: 2 to: str size.].

    str:= str select: [:char | char isDigit ].
    ^(str size <= self digits)!
initializePropertyOptions
        " Private - class initialization. "

    self
        partsIfOS2Do: [
            SupportsBorder := true.
            ]
        partsIfWindowsDo: [
            SupportsBorder := false.
            ].!   
unformattedTextLimit
    " Private - Return the text limit of the receiver's unformatted string. "
    ^pictureMask size!   
partNewValueEvent
        "Answer the selector of the one-argument event
        which is triggered by the receiver when its value
        has been changed. "
    ^#clicked:!
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
contents: any
    "Private - do nothing"!
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
stringWithProtectedCharacters
        "Private - Answer a string containing only protected chars."
    | str |
    str := pictureMask copy.
    1 to: str size do: [: index |
        (self isProtected: (str at: index))
            ifFalse: [str at: index put: self pictureCharacterPlaceholder]].
    ^str!   
partPropertySetNewMaxSize: anInteger to: aPropertyUnit
    " Private - set the new text limit to the property. "
    self
        digits: anInteger;
        setTextLimit: self unformattedTextLimit.!
initializePropertyOptions
        " Private - class initialization. "

    self partsIfWindowsDo: [
        AlignmentLabels := AlignmentValues := nil.
        ConvertCharactersLabels := Array
            with: (Array with: 'Upper case' with: EsAllUpperCase)
            with: (Array with: 'Lower case' with: EsAllLowerCase)
            with: (Array with: 'Leave alone' with: EsAnyCase).
        ConvertCharactersValues := Array
            with: EsAllUpperCase
            with: EsAllLowerCase
            with: EsAnyCase.
        "DEBUG - check ported implementation"
        ( (ConvertCharactersLabels =  #( #('Upper case'  8 ) #('Lower case' 16) #('Leave alone' 0) ) )
        and: [ConvertCharactersValues =  #( 8 16 0 ) ] )
            ifFalse: [self error: 'bug'].
        ].
    self partsIfOS2Do: [
        ConvertCharactersLabels := ConvertCharactersValues :=nil.
        AlignmentLabels := Array
            with: (Array with: 'Left' with: EsLeftAlignedText)
            with: (Array with: 'Center' with: EsCenteredText )
            with: (Array with: 'Right' with: EsRightAlignedText ).
        AlignmentValues := Array
            with: EsLeftAlignedText
            with: EsCenteredText
            with: EsRightAlignedText.
        "DEBUG - check ported implementation"
        ( (AlignmentLabels =  #( #('Left'  0) #('Center' 1) #('Right' 2) ) )
        and: [AlignmentValues  =  #( 0 1 2 ) ] )
            ifFalse: [self error: 'bug'].
        ].!  
resizeWindow
        "Private - Change the size of the host window
         for the receiver."
	(self parent isKindOf: DialogTopPane) 
		ifTrue: [^nil]
		ifFalse: [super resizeWindow]! 
partDoesResizeToContents
        "Answer whether the receiver should be resized
         to accomodate changed text entered
         through direct-editing."
    ^true!  
daysInMonth: month forYear: anInteger
        " Private - Answer the total number of days for the
         month month in the year yInteger."
    | index |
    month isInteger
        ifTrue: [
            (month between: 1 and: 12)
                ifTrue: [index := month]
                ifFalse: [^0]]
        ifFalse: [
            index := Date
                indexOfMonth: (Date monthNameFromString: month ifAbsent: [^0])
                ifAbsent: [^0]].
    ^index = 2    "February is a special case"
        ifTrue: [ 28 + (Date leapYear: anInteger)]
        ifFalse: [#(31 28 31 30 31 30 31 31 30 31 30 31)
               at: index]!   
drawDial: clipRectangle
        "Private - Draw the curved outline of the receiver dial on the form."
    | boundingBox |
    pen place: center.
    clipRectangle bottom = center y
        ifTrue: [
            boundingBox := center - r corner: (center + r).
            pen
                chord: r
                minor: r
                angles: 0 @ -180]
        ifFalse: [
            pen circle: r]! 
partAddBorder: aBoolean
        " Private - Windows does not have BsNoborder style"
    SupportsBorder ifFalse: [^self].
    aBoolean
        ifTrue: [self removeStyle: BsNoBorder]
        ifFalse: [self addStyle: BsNoBorder].
    self partPropertySetStyle: style!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    | autoSelector textLeftSelector |
	super codeGenerationAddAttributeMessagesTo: anExpressionModel.
    autoSelector := ( self hasStyle: BsAutoCheckBox )
        ifTrue: [ #autoCheckBox ]
        ifFalse: [ #checkBox ].
	anExpressionModel addSelector: autoSelector.
    ( SupportsLabelLeftOfButton and: [ self hasStyle: BsLeftAlignedText ] )
        ifTrue: [
            anExpressionModel addSelector: #labelLeftOfBox ]!  
formattedString
        " Private - Answer datum as a formatted string."
    ^self formatString: datum! 
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
rectangleWithoutMargin: aRect
        "Answer a rectangle based on aRect without
        extra margin."
    self partsVosOnly.
    ^self hasBorderStyle
        ifTrue: [
            self superWindow isDialogTopPane
                ifTrue: [ aRect ]
                ifFalse: [ aRect insetBy: 3 @ 3 ]]
        ifFalse: [ aRect ]!  
defaultSize: anInteger
        " Set the default size of the tick marks. "
    defaultSize := anInteger!
initializePictureCharacters
        "PictureField initPictureCharacters"
    PictureCharacters := Dictionary new.
    PictureCharacters
        at: $9 put: #isIntegerCharacter: ;
        at: $A put: #isAlphaCharacter: ;
        at: $N put: #isAlphaNumericCharacter: ;
        at: $X put: #isAnyCharacter: ;
        at: $L put: #isLogicalCharacter: ;
        at: $!! put: #asUpperCaseCharacter: ;
        yourself.!  
isValidFormat: aString
        "Private- Answer true if aString contains a valid format, else answer false.
        Should be implemented by subclasses which need special
        ordering of characters in aString.  Default is true.    "
    ^true!   
isValidDatum: anObject
        "Private - Answer true if anObject is acceptable else answer false."
    ^anObject isString
        ifTrue: [self isValidString: anObject]
        ifFalse: [
            (self isValidType: anObject)
                ifTrue: [true]
                ifFalse: [self isValidString: anObject asString] ]!   
resetFocus
    "Private - If the receiver is in a notebook page, insure the
    page is on top."
    | notebookPagePane |
    self partsIfOS2Do: [
    ( notebookPagePane := self superWindow ) isPARTSNotebookPagePane
        ifTrue: [
            notebookPagePane containingNotebook selectPage:
                notebookPagePane mainPage ]].
    self setFocus!   
isValidCharacter: aCharacter
    " Private - Answer true if aCharacter is one of the following characters:
        ( $A - $Z, $a - $z, space or other characters defined  as alphabetic
        by the current system language setting ), else answer false."
    ^((self isAlphaCharacter: aCharacter) or: [self isSpaceCharacter: aCharacter])! 
setToDegree: anInteger
        " Private - Set the reading of the receiver
          dial to anInteger degrees."
    self changeReading: lowReading +
        (self degreeToReading: anInteger)!  
defaultBitmap
        " Private - answer the default bitmap for a new drawn button part "

    | aBitmap |
    aBitmap := Bitmap width: 32 height: 32 planes: 1 bitCount: 4.
    aBitmap pen
        fill: aBitmap boundingBox
        color: Color red.
    ^aBitmap!
unformattedString
        "Private - Answer datum as an unformatted string."
    ^self createUnformattedStringFromValue: datum! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable
            #value #setValue: )
        separators: #( 2 )
        defaultItem: #disable!  
subclassRecursively
		"Private - no need to subclass at runtime."

	self partIsEditing ifTrue: [ self subclassWndProc ] .
	super subclassRecursively! 
dateSeparator
        " Answer the date separator "
    ^( self useSystemFormat or: [dateSeparator isNil] )
        ifTrue: [NationalLanguage dateSeparator]
        ifFalse: [dateSeparator]!
initializePropertyOptions
        " Private - class initialization. "

    self
        partsIfOS2Do: [
            SupportsLabelLeftOfButton := false.
            ]
        partsIfWindowsDo: [
            SupportsLabelLeftOfButton := true.
            ].! 
COMMENT
"
A PARTSDial implements the dial in a DialPane part.
"!   
initialize
        " Private - initialize a new instance. "

    super initialize.
    self label: 'Label'.!  
defaultFont
        "Answer the default font to be used for this
         class of Window, unless otherwise explicitly
         set with #font:"

    ^PARTSHostInterface defaultPartFont!   
defaultDial
        " Answer a dial with default settings "
        " Platform dependent - direction is different in VW."
    ^self new
        initDial: 0
        highReading: 80
        lowDegree: 200
        highDegree: 340;
        defaultSize: 5;
        numberOfTicks: 41;
        interval: (Array with: 10 with: 9);
        autoLabels: true!   
partNewValueEvent
        "Answer the selector of the one-argument event
        which is triggered by the receiver when its value
        has been changed. "
    ^#changedIndex:!   
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^self value isBitmap!
gettingFocus
        " Private - Set the text of the receiver and skip and protected characters.
        Do ot change the text of the receiver."
    self partsIfOS2Do: [ self sendInputEvent: #selectFrom:to: withArgs: ( Array with: 0 with: 0) ].
    self sendInputEvent: #skipProtected: with: true.
    super gettingFocus.!   
defaultTextLimit
        "Return the default text limit of the receiver.  "
    ^20!
commitSelection
        "Private - Answer true if list box should
         commit to selection request.  The commitSelection
        design is obsolete and not supported by PARTS lists
        (use the #aboutToChange event if appropriate). "

    ^true!   
frameRectangle
        "Answer the receiver's frame area including
          the drop down list box as a rectangle."
	^self 
		partsIfOS2Do: [super frameRectangle]
		partsIfWindowsDo: [
			( ( style bitAnd: CbsVisibleComboBox ) = CbsVisibleComboBox )
        	ifTrue: [ super frameRectangle ]
        	ifFalse: [ self partDroppedControlRectangle ]]! 
defaultStyle
        "Private - Answer the default style for a static graphic control."
    ^self supportsBothBitmapAndIcon
        ifTrue: [ SsBitmap | WsInitiallyVisible ]
        ifFalse: [ SsIcon | WsInitiallyVisible ].!  
retry: subPaneWithFocus
    "Private - Post the error message and answer whether the user
    wishes to retry entering a value."

    self errorMessage
        ifTrue: [
           " self partsIfOS2Do: [ self subPaneWithFocus: self ]."
            self isEndUserEditing: true.
            self tryAgain.
            ^false ] " Returning true causes the cursor to disappear"
        ifFalse: [
            self isEndUserEditing: false.
            self setFormattedContents.
            self sendInputEvent: #triggerLosingFocus.
              " After the errror message box closes, set the focus to <subPaneWithFocus>
                instead of the receiver. "
            self subPaneWithFocus: subPaneWithFocus.
            self
                partsIfOS2Do: [ subPaneWithFocus setFocus ]
                partsIfWindowsDo: [ subPaneWithFocus sendInputEvent: #setFocus ].
            ^false ]! 
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
   " ^SysFont width * 24 @ (SysFont height * 10)"
    ^ self partFontOrSysFont charSize * (22 @ 10)!  
partSetValueMessage
        "Answer the selector of the one-argument message
        which can be sent to the receiver to set its value. "
    ^#setValueIndex:!   
partPropertySetNewMaxSize: anInteger to: aPropertyUnit
    " Private - set the new text limit to the property. "
    aPropertyUnit
        textLimit: anInteger + 1;
        setTextLimit: self unformattedTextLimit! 
triggerChanged
        " Private - triggered the changed event. "
     self triggerEvent: #changed:
        with: (self value) rounded!
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #changed:
            #fileException:
            );
         yourself!
isValidMantissaString: aString
        " Private - Answer true if aString is a valid mantissa.  The mantissa could be an
        integer or a float. "
    (aString includes: $.)
        ifTrue: [^self isValidFloatString: aString]
        ifFalse: [^self isValidIntegerString: aString].!   
selectAll
        "Select the entire text of the  receiver."
    self setFocus.
    super selectAll!   
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench.
        This cannot return the unformattedString because it
        contains formatting characters which will cause
        validation of the input to always fail.
        When direct-editing a picture field, no formatting
        or protected characters are used, just use the current datum."
    ^datum!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #check #uncheck
            #label #setLabel: )
        separators: #( 3 7 )
        defaultItem: #value! 
setBitmap: anIconOrBitmap
        " Set the bitmap displayed by the receiver to anIconOrBitmap.
        Clear the receiver's bitmap if anIconOrBitmap is nil.
        Trigger the changed event.  Answer anIconOrBitmap. "

    | newBitmap | 
    self isValid ifFalse: [ ^self bitmap: anIconOrBitmap ].
    ( anIconOrBitmap isNil
    or: [ anIconOrBitmap isIcon not and: [ anIconOrBitmap isBitmap not ] ] )
        ifTrue: [
            self clearBitmap.
            ^nil ].
    newBitmap := ( anIconOrBitmap isBitmap
        ifTrue: [ anIconOrBitmap ]
        ifFalse: [  " icon "
            anIconOrBitmap release.   "release icon, only interested in xor mask."
            self
                partsIfOS2Do: [ anIconOrBitmap colorBitmap ]
                partsIfWindowsDo: [ anIconOrBitmap xorMask ] ] ).
    self
        bitmap: newBitmap;
        showBitmap;
        triggerEvent: #changed: with: newBitmap.
    ^anIconOrBitmap! 
buildAppToBeRun
        "Change children to be siblings since children
         don't get wmControl event correctly."
    | allSons count realFather |
    allSons := children.
    children := nil.
    realFather := self superWindow.
    [realFather isKindOf: GroupBox]
        whileTrue: [realFather := realFather superWindow].
    super buildWindow: realFather.
    count := 0.
    allSons size = 0 ifTrue: [^self].
    allSons do: [:child |
        realFather addSubpane: child.
        count := count + 1.
        allSons size = count ifTrue: [ "last child"
            child addStyle: WsBeginGroup].
        child framingBlock: child partWrapper rectangle.
            "(child framingBlock
                changeContainingRect: rectangle
                    to: (0@0 extent: realFather rectangleVar extent))."
        child buildWindow: realFather ]!   
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #valueIsOn
            );
         yourself!
partPropertyHasFrameCreationFlags
    "Answer whether the property set style should modify
        the frame creation flags instead of the style."

    self partsVosOnly.
    ^true!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy stretch: stretch.
    ^copy!   
partTypeSimpleName
        "Private - answer the name of the receiver's part type.
        THIS METHOD ONLY EXISTS TO SUPPORT READING
        3.0 PARTS WORKBENCH GENERATED .CLS FILES.
        It is used by the class PARTSCreator to create a mapping
        from part names to classes.  PARTSCreator will build this
        mapping by finding all the implementors of this method and
        invoking each one."

    ^'Fixed Decimal Entry Field'! 
decimalPlace
        " Answer the number of digits following the decimal point. "
    ^NationalLanguage currencyDigits! 
highDegree
        " Return the high degree of the dial. "
    ^highDegree! 
isValidNumberOfCharacters: aNumber
        "Private - Answer anInteger which is the valid number of
        character for an unformatted date string."
    (( aNumber isNil ) or: [ aNumber = 0 ])
        ifTrue: [^true].
    ^self twoDigitYear
        ifTrue: [aNumber = 6]
        ifFalse: [aNumber = 8]!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #clear #listValue
            #list #setList: #insertItem: #deleteItem: #deleteAll
            )
        separators: #(3 7)
        defaultItem: #value! 
frameStyle
        "Private - answer the style flags which should be used
         to create the receiver's host window"
    ^SubPane noScrollbarsFrameStyle!  
inputSize
    " Private - Return the size of the current window text excluding
    the picture character placeholder.  Necessary for setting the focus
    at the end of the window text of the receiver."
    | str |
    str := self windowText.
    str =  self stringWithProtectedCharacters ifTrue: [^0].
    ^(str findFirst: [:char | char = self pictureCharacterPlaceholder] ifAbsent: [str size]) - 1.!  
defaultEmptyValue
        " Private - answer the default empty value "
    ^nil!
partDirectEditValue
        "Answer the direct edit value of the receiver."
    ^self value!
interval: anArray
    " Set the number or tick intervals and the tick interval size.
      The first element of anArray is the number of tick intervals
       and the second element is its length. "
    interval := anArray!   
isValidString: aString
        "Private - Answer true if aString is a valid fixed decimal string, else answer false.
        A valid aString has two possible formats:
            1) Float - contain all digits,an optional sign character and an optional decimal separator.
            2) Fraction - has the form '2000/100'.
        The total number of digits cannot exceed digits.  The receiver will automatically
        default the placement of the decimal separator in the appropriate position. "

    |str  |
    (str:= aString trimBlanks) size = 0
        ifTrue: [^true].
    ^( str includes: $/  )
        ifTrue: [ self isValidFractionString: str ]
        ifFalse: [ self isValidFloatString: str ].!   
skipRight
        "Private - Skip over a  character by simulating a right
        arrow input"
    |position|
    position := self selection x.
    self selectFrom: (position + 1) to: (position )! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #value #setValue: )
        defaultItem: #setValue:!  
useSystemFormat: aBoolean
        "When useSystemFormat is true, dateSeparator,
        and format instance variables are ignored, and instead
        the host system settings are used."
    useSystemFormat := aBoolean!   
highReading: anInteger
        " Set the high reading of the dial. "
    highReading := anInteger!  
drawTickMarks
        "Private - Draw the reciever's tick marks and labels."
    | unitsPerScale scale tickInterval  degree label
      tickSize intervalTickSize tempTickSize tempLabel labelString|

    unitsPerScale := (self relativeDegree: highDegree) / (numberOfTicks - 1).
    scale := (highReading - lowReading) abs / numberOfTicks.
    tickInterval := (self tickInterval) max: 1.
    degree := lowDegree.
    label := lowReading.

    0 to: numberOfTicks - 1  do: [:i |
        pen direction: degree rounded;
            place: center;
            up.

        "Determine the tickSize, intervalTickSize and the label specified by the user. "
        tickSize := defaultSize.
        intervalTickSize := self tickIntervalLength.
        ((ticks size > 0) and: [(ticks at: i ifAbsent: [nil]) notNil])
            ifTrue: [
                tempTickSize:= (ticks at: i) at: 1.
                tempTickSize isNumber ifTrue: [tickSize:= intervalTickSize:= tempTickSize].
                tempLabel:= (ticks at: i) at: 2].

        "Draw the tick marks and labels.  Tick intervals have special labels and tick sizes. "
        i \\ tickInterval = 0
            ifTrue: [ "Tick Interval"
                pen
                    go: r - intervalTickSize - 4;
                    down;
                    go: intervalTickSize ;
                    up;
                    go: 4.
                autoLabels
                    ifTrue: [
                        labelString := ( (tempLabel size > 0)
                            ifTrue: [tempLabel]
                            ifFalse: [label printString] ).
                        self drawLabel: labelString degree: degree.
                        label := label + ((tickInterval * scale) rounded)]
                    ifFalse: [ "draw tick interval labels specified by the user."
                        tempLabel size > 0
                            ifTrue: [ self drawLabel: tempLabel degree: degree ]]
                        ]
            ifFalse: [ "Ticks between intervals"
                pen
                    go: r - tickSize - 4;
                    down;
                    go: tickSize.
                tempLabel size > 0
                    ifTrue: [ self drawLabel: tempLabel degree: degree ]
                        ].

        pen down.
        degree := self computeNewDegree: degree unitsPerScale: unitsPerScale.
        degree < 0 ifTrue: [degree := degree + 360].
        tempLabel:= nil.
        ]!   
recreateWindow
    "Private. Transfer data saved in the window to the value
    ivar before the window is destroyed. Otherwise, the text pane,
    after a change in style (border, scroll bars) looses it's contents."

    ( self propertyAt: #deletingText ) isNil ifTrue: [ self getText ].
    super recreateWindow.!  
lastChange
        "Answer the last change."
    ^lastChange!   
errorMessage
        "Private - The contents of the receiver is invalid.
        Display an error message to warn the user.
        Answer whether to retry."
    ^PARTSMessageBox new
        buttonValues: (Array with: true with: false);
        openTitled: self errorString
            withText: 'Retry?'
            style: MbIconQuestion | MbYesNo! 
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "
    ^self unformattedString!   
unformatString: aString
        "Private - Answer aString without formatting characters."
    ^aString select: [:char | char isDigit]!  
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
numberOfUnprotectedCharacters
        "Private - Answer the number of unprotected characters
         in the receiver."
    | count |
    count := 0.
    1 to: pictureMask size do: [: index |
        (self isProtected: (pictureMask at: index))
            ifFalse: [count := count + 1]].
    ^count!   
value 
        "Unlike regular EntryFields, formatted entryfields' #value returns the actual
        object it contains and NOT its string content.  The type of object returned
        depends on the formatted entryfield being used.
        When the receiver has the focus and the window text has changed
        set the new value of datum."
    | anUnformattedValue |
    "Enter key and mouse right click events or the receiver is being used as a property
     entry field. "
    (self hasFocus or: [self validateWhenLosingFocus not])
        ifTrue: [
            anUnformattedValue:= self windowText.
            (anUnformattedValue ~= self unformattedString)
                ifTrue: [ "new value"
                   (self isValidDatum: anUnformattedValue)
                        ifTrue: [
                                datum:= self createDatumFrom: anUnformattedValue.
                                self valueHasChanged: true ]]]. 
    ^datum!
isAlphaCharacter: aCharacter
        " Private- Answer true if aCharacter is an alpha character
         ( $A - $Z, $a - $z or other characters defined  as alphabetic
         by the current system language), else answer false."
    ^aCharacter isLetter!
errorString
        "Return the error string.t"
    ^'Invalid alphabetic string'!   
isModified
        "Answer whether the pane has modified.  Trigger the modified event if so."
    self modified
        ifTrue: [
            self triggerEvent: #modifiedIsTrue.
            ^true].
    ^false!   
bringToTop
        "Do not bring statics to the top."
    self realInvalidateRect: nil! 
decimalPlace: anInteger
        " Specify the number of digits following the decimal point. "
    decimalPlace:= anInteger! 
isValidNumberOfCharacters: aNumber
        " Private - Answer true if aNumber matches the required number of characters for a phone number."
    ^#(0 7 10) includes: aNumber!  
partSetGraphics: anIconOrBitmap
        " Private - set the new value of the receiver from
        selecting the Edit graphic... button. "
    self value: anIconOrBitmap! 
isValidString: aString
        "Private - Answer true if aString contains valid characters
         and the correct number of characters, else answer false. "
    | str |
    str:= aString trimBlanks.
    str isEmpty ifTrue: [^true].
    ^ ( ( self isValidNumberOfCharacters: str size ) and:
        [ self isValidIntegerString: str ] )!  
recreateWindow
        "Private - recreate the host window, because something
         needs to change which cannot be changed dynamically
         by the host OS."
    | listBox |
    ( listBox := self listBox ) notNil
        ifTrue: [   "style has changed from simple to drop down combo box."
            listBox stopReceivingMessages.
            self listBox: nil ].
    super recreateWindow!
deleteText
        "Delete all of the text in the control."

    self propertyAt: #deletingText put: true.
    super deleteText.
    self propertyAt: #deletingText put: nil.!   
partSetGraphics: aBitmap
        " Private - update the receiver's bitmap. "

    self setBitmap: aBitmap! 
insert: aChar at: aPosition
        "Private - Insert aChar in the receiver at position, aPosition."
    self replaceWithChar: aChar at: aPosition.!
formatString: aString
        " Private - Return aString as formatted currency string.
         Format is: 'currency' 999thousandSeparator999decimalSeparator99.  "
    | str negative decimalSeparator  pos |
    aString class = String ifFalse:[^ String new].
    aString size = 0 ifTrue: [^String new].
 
    "Check if the currency is negative. "
    str := aString.
    (str at: 1) = $-
        ifTrue:[
            negative := true.
            str := str copyFrom: 2 to: str size]
        ifFalse:[
            negative := false].

    "Insert thousandSeparators."
    decimalSeparator := NationalLanguage decimalSeparator first.
    pos := (str
        findLast:[:ch| ch = decimalSeparator]
        ifAbsent: [str size + 1]) - 3.    
    pos > 1 ifTrue:[
        pos to: 2 by: -3 do:[:i|
            str := (str copyFrom: 1 to: i - 1),
                        NationalLanguage thousandsSeparator,
                            (str copyFrom: i  to: str size)]].

    "Add the currency symbol. "
    str:= self addCurrencySymbol: str.

    "Add the possible minus sign."
    negative ifTrue: [ str:= '- ', str].

    ^ str!  
createDatumFrom: aValue
        "Private - Answer a Date object from aString."
    |data day month year newValue |
    newValue:= (self isValidType: aValue )
        ifTrue: [ aValue ]
        ifFalse: [ aValue asString ].
    newValue isString
        ifTrue: [
            newValue trimBlanks isEmpty ifTrue: [^self  emptyValue].
            data:= self extractDayMonthYear: newValue.
            day:= data at: #day.
            month:= data at: #month.
            year:= data at: #year.
            self  twoDigitYear
                ifTrue: [ year := year +
                    ( year > 49
                        ifTrue: [ 1900 ]
                        ifFalse: [ 2000 ] ) ].
            ^Date newDay: day
                month: (month isInteger
                    ifTrue: [Date nameOfMonth: month]
                    ifFalse: [Date monthNameFromString: month])
                year: year ].
    ^newValue!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #changed:
            #rightClicked #tabbed )
        separators: #( 1 )
        defaultItem: #changed:!
partSetValueMessage
        "Answer the selector of the one-argument message
        which can be sent to the receiver to set its value. "
    ^#setValueIndex:!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
    ^ self partFontOrSysFont charSize * (15 @ 6) + (0 @ 10) "add 10
        to height so that there won't be spaces after the bottom line"!   
twoDigitYear: aBoolean
        "Assign if the receiver accepts a two digit or four digit year.
        If aBoolean is true then the receiver accepts a two digit year.
        If aBoolean is false then the receiver accepts a four digit year."
    twoDigitYear:= aBoolean.!   
partDirectEditTextIsRightJustified
        "Answer whether the receiver's text should be
        right-justified during direct-editing."
    ^(style bitAnd: SsRightAlignedText) ~= 0! 
formatString: aString
        " Private - Answer aString as a formatted phone number.
        Format is: (999) 999-9999 or 999-9999."
    |formattedString|
    aString size = 7
        ifTrue:[
            formattedString := (aString copyFrom: 1 to: 3) ,
                                        '-', (aString copyFrom: 4 to: 7)]
        ifFalse:[
            aString size = 10
                ifTrue:[
                    formattedString := '(', (aString copyFrom: 1 to: 3),
                            ') ', (aString copyFrom: 4 to: 6),
                            '-', (aString copyFrom: 7 to: 10)]
                ifFalse:[
                    aString size = 0
                        ifTrue:[^String new]
                        ifFalse:[^nil]]].
    ^ formattedString!   
basicStyle
        "Private - Answer an Integer with appropriate
         constants combination for basic subpane style."
    ^self
        partsIfOS2Do: [ super basicStyle ]
        partsIfWindowsDo: [ WsChildWindow | WsInitiallyVisible ]! 
listBox
        "Private - Answer the list box control in a simple combo box."
    ^self propertyAt: #listBox!  
lastChange: anInteger
        "Set the last change
         to anInteger."
    lastChange := anInteger!
wmCharOS2: mp1 with: mp2
        "Private event - Add a MessageExpression to CurrentEvents
         and return right away. If the character is valid, process #characterInput:;
             else do nothing. " 
    | character charIsSpace event position virtualKey |
    self partsVosOnly.
    ( event := KeyboardInputEvent fromWmChar: mp1 with: mp2 ) isNil ifTrue: [ ^true ].
    self sendInputEvent: #keyboardInput: with: event.
    virtualKey:= event virtualKey.
    character:= event character.
    charIsSpace :=  character notNil and: [ character == Space or: [ character == DoubleByteSpace ]   ].
    ( virtualKey isNil or: [ charIsSpace] )
        ifTrue: [
                    position:= self selection x.
                    ( self isValidCharacter: character )
                        ifTrue: [
                            (pictureMask at: position) = $!!
                                ifTrue: [character := character asUpperCase].
                                    self isGapSelection ifTrue: [self backspaceSelection].
                                    self insert: character at: position.
                                    self selectFrom: ( position + 1 )   to: ( position ).
                                    self skipProtected: true.
                                    self sendInputEvent: #characterInput: with: character]
                                ifFalse: [
                                    Terminal bell ].
                    ^false ].
  ^(self handlesVirtualKey: virtualKey )
        ifTrue: [ false ]   "The receiver handles the virtual key. "
        ifFalse: [  nil ].   !  
wordWrap: aBoolean
    aBoolean
        ifTrue: [self enableWordWrap]
        ifFalse: [self disableWordWrap]! 
setBitmap: aBitmap
        "Set the label of the receiver to aBitmap.  Answer aBitmap."
    ^self setLabel: aBitmap!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #valueIndex #setValueIndex:
            #list #setList: #insertItem: #deleteItem: #deleteAll
            #abortChange
            )
        separators: #( 3 7 12 )
        defaultItem: #value!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue: #append: #insert:
                    #setFromFile: #saveToFile:
                    #clear #selectAll
            #selectedText #cutSelection #copySelection
                #pasteSelection #clearSelection #deleteKey
            #undo
            #isModified #clearModified #setModified
            )
        separators: #( 3 11 17 18 )
        defaultItem: #value!   
initialize
        " Private - initialize a new instance. "

    super initialize.
    self
        drawAnisotropic;
        bitmap: self defaultBitmap.!   
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private "
    self
        partPrintFontOn: aStream margin: aString.! 
supportsMaxSizeItem
        "Private - return true if the receiver supports a text limit property. "
    ^false!
initialize
    " Private - Initialize the receiver "
    super initialize.
    self
        digits: self defaultTextLimit;
        signed: true.!
validate
        "Private - Display the control."
    super validate.
    datum size = 0
        ifTrue: [ self setMask].!
performMenuItem: anInteger
	"Private - Perform the menu item whose id is anInteger.
	Only do a menu perform here if a popup is up.  Reset the
	popup to nil so that the popup item states are correctly
	set every time the popup is requested.  Do the reset here
	because popup can't be reset until after an item has been
	selected and performed."

	super performMenuItem: anInteger.
	popup := nil!   
drawNeedle
        "Private - Draw the needle of the receiver at the current reading."
    | dir  |
    dir:= (reading - lowReading = 0)
        ifTrue: [ lowDegree rounded ]
        ifFalse: [ lowDegree - (( reading - lowReading )
            // (readingsPerDegree) ) rounded ] .
    pen down;
        place: center;
        direction: dir;
        go: (tip := (r - 10 max: 2)).
    tip := tip @ dir!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #clicked #\
            #rightClicked #tabbed)
        separatorMarker: #\
        defaultItem: #clicked!   
isValidDigit: aCharacter
        " Private - Answer true if aCharacter is an acceptable digit, else answer false."
    | input decimalSeparator decimalPos pos currentPos selectedText  digitsCount
    selectedDigitsCount str |
    input := self windowText.
    decimalSeparator := NationalLanguage decimalSeparator first.
    decimalPos := input indexOf: decimalSeparator.
    digitsCount:= selectedDigitsCount:= 0.
    pos := self selection.
    currentPos:= pos x.
   self isGapSelection
        ifTrue: [selectedText := input copyFrom: pos x to: (pos y - 1)].
    selectedText == nil
        ifTrue: [selectedText:= String new]
        ifFalse: [selectedDigitsCount:= (selectedText select: [:char | char isDigit]) size].
    digitsCount:= ((input select: [:char |char isDigit]) size) - selectedDigitsCount.

    ((self decimalPlace = 0) or: [(input includes: decimalSeparator) not ])
        ifTrue: [ ^digitsCount < self digits ].

    ((decimalPos ~= 0) and: [(selectedText includes: decimalSeparator) not])
        ifTrue: [
            (currentPos <= decimalPos)
                ifTrue: [
                    str:= (input upTo: decimalSeparator) select: [:char | char isDigit].   "Don't include sign char."
                    digitsCount:= str size - selectedDigitsCount]
                ifFalse: [
                    str:= input copyFrom: (decimalPos + 1) to: input size.
                    digitsCount:= str size - selectedDigitsCount.
                    ^(digitsCount < self decimalPlace) ]].
    ^(digitsCount < (self digits - self decimalPlace))!   
asUpperCaseCharacter: aChar
        "Private - Always return true because the receiver will
          automatically convert all characters to upper case during
            validation. "
    ^true!  
menuTitled: aString
        "Private - workaround for loading shrunken windows with a text pane."

    ^nil!