"3.0.0.53"
!
   
Smalltalk at: #PMToWinKeyMap ifAbsentPut: [ nil ]!
  
Smalltalk at: #WinToPMKeyMap ifAbsentPut: [ nil ]!
  
Smalltalk at: #RGBColorChiseledGray ifAbsentPut: [ nil ]!
   
Smalltalk at: #WBMonthStrings ifAbsentPut: [ nil ]!
 
Smalltalk at: #WBBitmaps ifAbsentPut: [ Dictionary new ]!
   
Smalltalk at: #WBSystemBitmaps ifAbsentPut: [ Dictionary new ]!
 
Smalltalk at: #WBFontClass ifAbsentPut: [ nil ]!

Smalltalk at: #WBBitmapClass ifAbsentPut: [ nil ]!

EventManager subclass: #WBObject
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

TopPane subclass: #WBDialogTopPane
  instanceVariableNames: 
    ' sem dialogOwner '
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!   

ViewManager subclass: #WBWindowDialog
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!   

ComboBox subclass: #WBComboBox
  instanceVariableNames: 
    ' fullList disabled isListVisible isListSizeDynamic '
  classVariableNames: 
    ' IsListSizeDynamicDefault '
  poolDictionaries: 
    ' OperatingSystemConstants '! 

ComboEntryField subclass: #WBComboEntryField
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: 
    ' CharacterConstants VirtualKeyConstants '!  

WBObject subclass: #WBDisplayContext
  instanceVariableNames: 
    ' window pen justification boundingBox cellBox cellInset cellBorder wrap borderColor scale '
  classVariableNames: 
    ' TextJustificationConstants '
  poolDictionaries: 
    ' OperatingSystemConstants '!  
WBDisplayContext class instanceVariableNames: ' cellInset justification '!

!Collection methods !   
asByteArray
        "Added by OSI - Answer a ByteArray whose contents are the
         bytes of the receiver."
    | byteArray index |
    #addedByOSI.
    index := 0.
    byteArray := ByteArray new: self size.
    self do: [ :each | byteArray at: (index := index + 1) put: each ].
    ^byteArray! !

!Window methods !  
iconFile
    "Supports attatching icons to windows"
    #addedByOSI.
    ^self propertyAt: #iconFile! !

!WBDisplayContext methods ! 
wrap

    ^wrap ifNil: [self defaultWrap]! !

!KeyboardInputEvent class methods ! 
keyUpFromWmKeyup: wparam with: lparam
        "Private - answer an instance of the receiver class corresponding to
        the host WM_CHAR message described by the arguments."
    #addedByOSI.
    ^self fromWmChar: wparam with: lparam! !

!Window methods !   
addTabInfoFor: aPane
        "Private - Add tabbing information for aPane to
        the receiver."
    (aPane canTab and: [aPane affectsFreeClientArea not])
        ifTrue: [self orderedChildren add: aPane].
    #modifiedByOSI.
    "Save the child order information."
    self owner isWBWindow & aPane affectsFreeClientArea not
        ifTrue: [
            (self
                propertyAt: #childrenInBuildOrder
                ifAbsentPut: [self childrenInBuildOrder select: [:child |
                    child isMDIClient]]) add: aPane].! !

!WBDisplayContext methods !  
window

    ^window! !

!Bitmap methods ! 
bitmapHandle
    "Added by OSI - Answer the handle of the receiver without
     bringing it to life. This fix was provided by Digitalk"
    #addedByOSI.
    ^bitmapHandle! !

!WBDisplayContext methods !  
defaultScale

    ^true! !

!Window methods ! 
wbDisplayContext
    "Answer a new window builder display context for the receiver."

    #addedByOSI.
    ^self wbDisplayContextClass for: self! !

!WBComboBox methods !  
disableItem: anItem

    self getSelection.
    ((fullList indexOf: anItem) = value) ifTrue: [
        value := value + 1.
        (value > list size) ifTrue: [
            value := 1.
        ].
        self selectIndex: value.
    ].

    disabled add: anItem.

    self buildList.! !

!ViewManager methods ! 
execute: aBlock withTopPane: aTopPaneClass
    "Added by OSI to support openning windows as MDI
     parents and children. MDI support must be loaded."
    | result |
    #addedByOSI.
    Smalltalk at: #TopPaneClass put: aTopPaneClass.
    result := aBlock value.
    Smalltalk removeKey: #TopPaneClass.
    ^result! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!File class methods !  
findOrPromptFileName: fileName
        "Answer the full path of the file named fileName.
		 Search the current search path, and if not found
		 then prompt the user."
	^self findOrPromptFileName: fileName in: OrderedCollection new! !

!WBDisplayContext methods !  
defaultCellInset

    ^self class cellInset! !

!DrawnButton methods !
cpContents
	"Return the label of the button or the file name in which its bitmap is stored."

	#addedByOSI.
	^self propertyAt: #fileName ifAbsent: [self contents]! !

!ApplicationCoordinator methods !
paneNamed: paneName
    "Added by OSI to return the pane named <paneName>"
    #addedByOSI.
    ^self isWBWindow
        ifTrue: [self triggerEvent: #wbNeedsPaneNamed: with: paneName]
        ifFalse: [nil]! !

!WBComboBox methods !   
entryFieldClass
        "Private - answer the class of the entry field part of the receiver."
    ^WBComboEntryField! !

!Array methods ! 
convertBytesToString
        "Added by OSI - Answer a String whose contents are the
         bytes of the receiver."
    #addedByOSI.
    ^self asByteArray asString! !

!WBComboBox methods !  
contents: aCollection

    disabled := Set new.
    fullList := aCollection.

    ^super contents: aCollection! !

!LargePositiveInteger methods ! 
lowHalf

    " ** Added by Objectshare ** "
    "Answer the low half of the receiver."

    #addedByOSI.
    ^(ExternalLong fromInteger: self) lowHalf! !

!WBComboBox methods !  
enableItem: anItem

    disabled remove: anItem ifAbsent: [].

    self buildList.! !

!WBDialogTopPane methods !   
closeView

    dialogOwner isWindow
        ifTrue: [
            dialogOwner enable.
            dialogOwner makeActive ].
    super closeView.
    Processor currentProcessIsRecursive ifTrue: [
        ^self].   "no semaphore wait"
   sem notNil ifTrue: [
        sem signal.
        sem := nil.
        Processor terminateActive.]! !

!WBDialogTopPane methods ! 
initSize
        "Private - Answer the initial size of the receiver."
    | size |
    size := self initWindowSize.
    ^(size isRectangle
            ifTrue: [size]
            ifFalse: [
                size isPoint
                    ifTrue: [self boxOfSize: size]
                    ifFalse: [0 @ 0 extent: 100@100]]).! !

!SubPane methods !
wmKeyup: wordInteger with: longInteger
        "Private - Process the character input message."
    | event |
    self needsKeyUpInput ifTrue: [
        #addedByOSI.
        (event := KeyboardInputEvent keyUpFromWmKeyup: wordInteger with: longInteger) notNil ifTrue: [
            self sendInputEvent: #keyUpInput: with: event ] ].
    ^super wmKeyup: wordInteger with: longInteger! !

!Window methods !  
childrenInBuildOrder
	"Private - answer the child panes in the order they should be built."

	#modifiedByOSI.
	"If there is a build order defined then answer it,
		else answer the default ordering."
	^self propertyAt: #childrenInBuildOrder ifAbsent: [
		self orderedChildren , self unorderedChildren]! !

!TextTool methods ! 
winDrawText: str in: aRect format: f

    "Added by OSI"
    #addedByOSI.
    self allHandles do: [:h |
        UserLibrary
            drawText: h
            text: str asParameter
            length: str size
            rect: (WinRectangle fromRectangle: aRect) asParameter
            format: f asParameter
    ].! !

!WBDisplayContext methods !
pen: aPen

    pen := aPen.! !

!WBComboBox methods ! 
setInitialContents
        "Private - set the receiver's contents and selection."
    self contents: list.
    value notNil ifTrue: [ self setSelection ]! !

!Window methods !  
removeSubpaneDynamically: aSubPane
    "Remove a subpane from a window dynamically."
	| id |
    #addedByOSI.
	(id := self children keyAtValue: aSubPane ifAbsent: [nil])
		notNil ifTrue: [ self children removeKey: id ].
    self orderedChildren remove: aSubPane ifAbsent: [ ].
    aSubPane closeDynamically.! !

!Context methods !   
isWBFramingContext
    "Added by OSI - Answer true if the receiver is WB
     framing parameters or a framing context."
    #addedByOSI. "PARTS Support"
    ^true! !

!IndexedCollection methods ! 
endsWith: aCollection
	    "Answer true if the receiver ends with aCollection of objects."
	#addedByOSI.
    self size < aCollection size ifTrue: [ ^false ].
    self size = aCollection size ifTrue: [ ^aCollection = self ].
    ^aCollection = (self copyFrom: self size - aCollection size + 1 to: self size)! !

!Window methods !   
iconFile: aString
    "Added by OSI - supports attatching icons to windows"
    | path |
    #addedByOSI.
    self propertyAt: #iconFile put: aString.
	path := (File exists: aString)
		ifTrue: [ aString ]
		ifFalse: [ File findFileName: aString fileNameLessPath ].
	path notNil ifTrue: [
        self icon: (Icon fromFile: path) ].! !

!ApplicationCoordinator methods !  
mainView
    "Added by OSI to return the receiver's view"
    #addedByOSI.
    ^self isWBWindow
        ifTrue: [self triggerEvent: #wbNeedsView]
        ifFalse: [nil]! !

!Date class methods ! 
validateString: aString
    "Added by OSI - Validate whether aString represents
     a valid date"

    | array |
    #addedByOSI.
    array := self dateArray: aString.
    ^self validateDay: (array at: 1) month: (array at: 2) year: (array at: 3)! !

!LayoutFrame methods !
alignWindowLeftTop: aPoint
	"Align the left top of the receiver to aPoint."

	self
		alignWindowLeftTop: aPoint
		boundingBox: Display boundingBox.! !

!SubPane methods ! 
horizontalScrollMinRange
        "Private - Answer the horizontal scrollbar's max range"
    | minPos |
	#addedByOSI.
	"Copied from GraphPane."
    ( UserLibrary
        getScrollRange: self handle asParameter
        bar: SbHorz
        lpMinPos: ( minPos := ExternalLong new ) asParameter
        lpMaxPos: ExternalLong new asParameter )
            ifFalse: [ ^self osError ].
    ^minPos asInteger! !

!DrawnButton methods ! 
wmErasebkgnd: wordInteger with: longInteger
        "Private - Added by OSI.  Process the erase background message."
    #addedByOSI.
    "If the button is invisible, then don't erase its background."
    drawSelector = #invisible ifTrue: [ ^1 ].
    ^super wmErasebkgnd: wordInteger with: longInteger! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!WBComboBox methods !   
hasDynamicListSizeStyle
		"Dynamically size the receiver's frame based on the
			number of elements in the receiver's list."
	^isListSizeDynamic = true! !

!Menu methods !  
removeAllItemsDynamically
		"Delete all menu items."
    #addedByOSI.
     self deleteAll.

     "#### Old Code ####
    items reverseDo: [ :item |
        self removeItemDynamically: item contents ].
    items := OrderedCollection new.
    accel := OrderedCollection new.
     ################"! !

!WBDisplayContext methods !   
boundingBoxForBitmap: aBitmap

    | extent ratio leftTop |
    extent := aBitmap extent.
    (extent x > 0) & (extent y > 0) & self scale ifTrue: [
        ratio := self boundingBox extent / extent.
        ratio := (ratio x min: ratio y) min: 1.
        extent := (extent * ratio) truncated].
    leftTop := self boundingBox leftTop.
    self justification = #center ifTrue: [leftTop := leftTop right: (self boundingBox width - extent x) // 2].
    self justification = #right ifTrue: [leftTop := leftTop right: self boundingBox width - extent x].
    ^leftTop extentFromLeftTop: extent! !

!DrawnButton methods !  
invisible: ignore
	    "Private - Draw the invisible button"
    #addedByOSI.! !

!WBComboBox methods !   
initialize
		"Private - Initialize the receiver."
    super initialize.
    disabled := Set new.
    fullList := list.
	isListVisible := false.
	isListSizeDynamic := self class hasDynamicListSizeStyle.! !

!TextTool methods ! 
centerWinText: aString at: aPoint

    "Added by OSI"
    #addedByOSI.
    self winDrawText: aString
        at: aPoint -
            ((font wbStringWidth: aString)
                @ font height // 2)! !

!WBComboBox methods !   
syncControlEvent: anEvent with: aParameter
        "Private - Process anEvent produced
         by the host system. The default is to
         requeue the operation for deferred handling."

    anEvent = CbnDropdown ifTrue: [
        self resizeWithDropDownList.
        self sendInputEvent: #forkListHiddenWatcher.
        ^1 ].

    ^super syncControlEvent: anEvent with: aParameter! !

!Button methods !
isCancelPushButton
        "Private - Answer true if the receiver is the
        cancel pushbutton."
    #addedByOSI.
    ^(self propertyAt: #cancelPushButton) = true! !

!Pen methods !   
draw3DRect: aRect leftTopColor: aLeftTopColor rightBottomColor: aRightBottomColor

    "Added by OSI"
    | theHandle leftRight1 leftRight2 rightLeft2 rightLeft3
	topDown1 topDown2 bottomUp2 bottomUp3 oldColor |
    #addedByOSI.
    theHandle := self handle.
    leftRight1 := aRect left right: 1.
    leftRight2 := aRect left right: 2.
    rightLeft2 := aRect right left: 2.
    rightLeft3 := aRect right left: 3.
    topDown1 := aRect top down: 1 + Rectangle leftTopUnit y.
    topDown2 := topDown1 down: 1.
    bottomUp2 := aRect bottom up: 1 + Rectangle rightBottomUnit y.
    bottomUp3 := bottomUp2 up: 1.
	oldColor := self foreColor.

    self
        foreColor: aLeftTopColor;
        quickLineFrom: leftRight1 @ topDown1 to: rightLeft2 @ topDown1 using: theHandle;
        "quickLineFrom: leftRight1 @ topDown2 to: rightLeft3 @ topDown2 using: theHandle;"
        quickLineFrom: leftRight1 @ topDown1 to: leftRight1 @ bottomUp2 using: theHandle;
        "quickLineFrom: leftRight2 @ topDown1 to: leftRight2 @ bottomUp3 using: theHandle;"
        foreColor: aRightBottomColor;
        quickLineFrom: leftRight1 @ bottomUp2 to: (aRect right left: 1) @ bottomUp2 using: theHandle;
        "quickLineFrom: leftRight2 @ bottomUp3 to: rightLeft2 @ bottomUp3 using: theHandle;"
        quickLineFrom: rightLeft2 @ topDown1 to: rightLeft2 @ (aRect bottom up: 1) using: theHandle;
        "quickLineFrom: rightLeft3 @ topDown2 to: rightLeft3 @ bottomUp2 using: theHandle;"
        foreColor: oldColor.! !

!WBDialogTopPane methods ! 
openWindow
    "Open the dialog box modal to the
     current active window."
    ^ self openModal: nil! !

!Object methods !
add: aWindow interestIn: name
	    "Private"
	#addedByOSI.
	"PARTS implements this in Window,
		so we reimplement it here so that
		CompositePanes work without PARTS installed."! !

!ViewManager methods !   
setOwner: aWindow
	"Added by OSI"

	#addedByOSI.
	self mainView setOwner: aWindow! !

!WBDialogTopPane methods !
processInput
        "Private - Make the receiver modal to its owner window.
         This method doesn't return until close has been
         sent to the receiver.  parent should be disabled before
         calling this method."
    sem := Semaphore new.
    [CurrentProcess makeUserIF. Notifier run] fork.
    sem notNil ifTrue: [sem wait].  "diag may be closed before
        getting here"
    CurrentProcess makeUserIF! !

!Font methods ! 
fromByteArray: aLogFontByteArray
	"Added by OSI - Create a font from the bytes of a logical font"

	#addedByOSI.
	logicalFont := WinLogFont fromBytes: (
		aLogFontByteArray isByteArray
			ifTrue: [aLogFontByteArray]
			ifFalse: [aLogFontByteArray asByteArray]).
	"changed := true."
	self makeFont.! !

!WBDisplayContext methods !  
displayDuring: aBlock

	| region answer |
	self displayCell.
	region := self pen setClipRect: self boundingBoxClipped.
	answer := aBlock evaluateFor: self pen.
	self pen
		setClipRect: nil;
		destroyRegion: region.! !

!Window methods !
hasTransparentStyle
        "Answer whether the receiver has the transparent style."
    #addedByOSI.
    ^(self propertyAt: #transparent) = true! !

!ListBox methods ! 
dragTargetFormatsDefault
		"Private - answer the formats of drag objects that the receiver will accept."
	#addedByOSI.
	^#( 'string' )! !

!WindowDialog methods !   
openViews
    "Added by OSI"
    #addedByOSI.
    ^ self isModal
        ifTrue: [ self openWindow ]
        ifFalse: [ self openModeless ].! !

!WBComboBox methods ! 
dynamicListHeight
        "Answer the dynamic list height."
    | ef |
    ^self dynamicListSize * self font height + 10 + (
        (ef := self entryField) notNil
            ifTrue: [ ef rectangle height ]
            ifFalse: [ self font height + 8 ] )! !

!Font methods !   
stringExtent: aString
        "Answer the extent of aString using the receiver font."
    #addedByOSI.
    ^(self wbStringWidth: aString) @ self height! !

!Window methods !
paneName

    "Added by OSI"
    #addedByOSI.

    ^self propertyAt: #myOwnName ifAbsent: [ '' ].

    "For compatibility with V/Win, use the following instead:"

    "^self propertyAt: #paneName"! !

!Window methods ! 
wbDisplayContextClass
    "Answer a the window builder display context class for the receiver."

    #addedByOSI.
    ^WBDisplayContext! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!WBDisplayContext methods !
splitCellLeftRatio: aRatio
    "Split the cell into two parts based on aRatio.
        Set the cellBox and answer the other."

    ^self splitCellLeftInset: self cellBox width * aRatio! !

!WBDisplayContext methods !
displayRightBorder

    | oldColor |
    oldColor := self pen foreColor.
    self pen
        blank: self cellBox;
        foreColor: self borderColor;
        place: (self cellBox rightTop left: 1);
        line: (self cellBox rightBottom left: 1);
        foreColor: oldColor.! !

!ApplicationCoordinator methods !   
isWBWindow
    "Added by OSI"
    #addedByOSI.
    ^self class wbCreated! !

!File class methods !   
findOrPromptFileName: aFileName filters: filterCollection in: aCollectionOfDir
       "Answer the full path of the file named fileName.
       Searching in aCollectionOfDir first, then the current search path,
		then prompt the user.  If the user specifies a directory that is not
		in aCollectionOfDir, then add that directory to aCollectionOfDir.
		filterCollection is a collection of associations whose
		keys are the filter (e.g. '*.*') and values are the filter
		descriptions (e.g. 'All files (*.*)')."

	| fileName dialog answer defFilter allFilters |
	#addedByOSI.
	(self exists: aFileName) ifTrue: [^aFileName].
	fileName := aFileName fileNameLessPath.
	aCollectionOfDir do: [ :each |
		answer := each drivePathName, '\', fileName.
		(self exists: answer) ifTrue: [ ^answer ] ].
	(answer := self findFileName: fileName) notNil ifTrue: [ ^answer ].

	(defFilter := '*.', fileName fileExtension trimBlanks)
		= '*.' ifTrue: [ defFilter := '*.*' ].
	allFilters := OrderedCollection new
		addAll: filterCollection;
		yourself.
	allFilters
		detect: [ :assoc | assoc key = '*.*' ]
		ifNone: [ allFilters add: '*.*' => 'All files (*.*)' ].
	allFilters
		detect: [ :assoc | assoc key = defFilter ]
		ifNone: [ allFilters add: defFilter => ('Related files (', defFilter, ')') ].
	
	dialog := FileDialog new
		title: 'Where is "', fileName, '" ?';
		fileSpec: fileName;
		hideReadonly.
	allFilters do: [ :assoc |
		dialog addFilter: assoc key description: assoc value ].
	dialog
		defFilter: defFilter;
		open.

	(answer := dialog file) notNil ifTrue: [
		(self exists: answer) ifFalse: [
			MessageBox message: '"', answer fileNameLessPath, '" does not exist'.
			answer := nil ] ].
	^answer! !

!WBComboBox methods !  
isDropdownVisible
        "Answer true if the drop down list is visible."
    ^isListVisible! !

!String methods !
wbDisplayWith: aWBDisplayContext
	"Display a representation of the receiver using aWBDisplayContext."

	#addedByOSI.
	aWBDisplayContext displayText: self.! !

!Object methods !
wbOldVersionSupport
	"Private - Support old versions of WB."

	#addedByOSI.! !

!LayoutFrame methods !   
alignDialogCenter: aPoint
	"Align the center of the receiver to aPoint."

	| du extent |
	du := (SysFont width / 4) @ (SysFont height / 8).
	extent := (self valueForDialogTopPane: Display boundingBox) extent * du.
	self alignDialogLeftTop: (aPoint leftAndUp: extent // 2)! !

!WBDisplayContext methods !   
displayText: aString

	self displayDuring: [:aPen |
		aPen
			setTextAlign: self textAlign;
			setBackgroundModeTransparent;
			winDrawText: aString
				in: self boundingBox
				justification: self textFlags].! !

!WBDisplayContext class methods ! 
constructTextJustificationConstants
    "Construct a dictionary mapping justification to platform specific constant."

    "
    WBDisplayContext textJustificationConstants: nil.
    "

    ^IdentityDictionary new
        at: #left put: SsLeft;
        at: #center put: SsCenter;
        at: #right put: SsRight;
        yourself! !

!EntryField methods !  
removeTextChangedEvent
		"Remove the #textChanged event from the event queue."
	#addedByOSI.
	Notifier removeLastCurrentEventFor: self using: [ :eachEvent |
		eachEvent selector == #asyncControlEvent:with:
			and: [ eachEvent arguments first = EnChange ] ].! !

!Date class methods !
validateDay: dInteger month: mInteger year: yInteger
    "Added by OSI - Check the validity of the day number
     dInteger for the month aSymbol in the year yInteger.
     If the date is invalid, report the error."

    #addedByOSI.
    ^(mInteger < 1 or: [
        mInteger > 12 or: [
        dInteger < 1 or: [
        dInteger > (self
            daysInMonth: (self nameOfMonth: mInteger)
            forYear: yInteger)]]]) not! !

!Object class methods !  
wbBasicVersion
        "Private - Answer the window builder version."
    #addedByOSI.
    ^nil! !

!SubPane methods !   
definedIn
        "Answer the selector of the creation method."
	#addedByOSI.
    ^self propertyAt: #definedIn! !

!Object methods ! 
openWindow
	"Added by OSI"

	#addedByOSI.! !

!Font methods !
fromBytes: aLogFontByteArray
        "Logical fonts from V/Win do not translate. Use the
        System font instead. V/Win32 uses #fromByteArray: instead."
    #addedByOSI.
    ^SysFont! !

!IndexedCollection methods ! 
beginsWith: aCollection

    #addedByOSI.
    self size < aCollection size ifTrue: [ ^false ].
    self size = aCollection size ifTrue: [ ^aCollection = self ].
    ^aCollection = (self copyFrom: 1 to: aCollection size)! !

!WBDisplayContext class methods !  
for: aWindow

    ^self new window: aWindow! !

!ViewManager methods !
createViewsFor: target owner: owner
    "Added by OSI - Dummy method that returns nil."
    #addedByOSI.
    ^nil! !

!Menu methods !
removeItemDynamically: stringOrInteger

	"Added by OSI"

	| pos mi |

	#addedByOSI.
	stringOrInteger isInteger
		ifTrue: [
			mi := items at: stringOrInteger.
			pos := stringOrInteger]
		ifFalse: [
			mi := (items select: [:i | i label = stringOrInteger]) first.
			pos := items indexOf: mi].
	items removeIndex: pos.
	accel removeIndex: pos.
	window notNil ifTrue: [
		window deleteItem: mi].

	"##### Old Code #####
	UserLibrary
		deleteMenu: window asParameter
		position:  pos - 1
		flag: MfByposition.
	##### ##### #####"! !

!Object methods !   
wbCreated
	"Added by OSI - Was the receiver created by WindowBuilder Pro?"

	#addedByOSI.
	^false! !

!WBDisplayContext methods !   
defaultForeColor

	^Color windowText! !

!WBDisplayContext class methods !
cellInset

    ^cellInset ifNil: [
        cellInset := self defaultCellInset]! !

!GraphicsTool methods !   
setBackgroundModeOpaque
		"Set the background mode."
	#addedByOSI.
	self setBackgroundMode:  2. "(GraphicsConstants at: 'BackgroundMixOpaque')"
! !

!SubPane methods ! 
horizontalScrollMaxRange
        "Private - Answer the horizontal scrollbar's max range"
    | maxPos |
	#addedByOSI.
	"Copied from GraphPane."
    ( UserLibrary
        getScrollRange: self handle asParameter
        bar: SbHorz
        lpMinPos: ExternalLong new asParameter
        lpMaxPos: ( maxPos := ExternalLong new ) asParameter )
            ifFalse: [ ^self osError ].
    ^maxPos asInteger! !

!ViewManager methods ! 
paneNamed: aPaneName
	"Added by OSI - Answer the named pane or nil."

	| pane string |
	#addedByOSI.
	views do: [:v |
		(pane := v wbPaneNamed: aPaneName) notNil
			ifTrue: [^pane]].
	string := aPaneName asString.
	views do: [:v |
		(pane := v wbPaneNamed: string) notNil
			ifTrue: [^pane]].
	^nil! !

!SubPane methods !   
horizontalScrollPos
        "Private - Answer the horizontal scrollbar's position"
    | pos |
	#addedByOSI.
	"Copied from GraphPane."
    ( pos := UserLibrary getScrollPos: self handle asParameter bar: SbHorz ) = 0
        ifTrue: [ self osWarning ].
    ^pos! !

!Window methods !   
wmCommand: wordInteger with: longInteger
        "Private - Process the command message."
    | control answer |
    ( self helpModeCommand: wordInteger ) notNil ifTrue: [ ^0 ].
    ( longInteger > 0 or: [ self isDialogTopPane ] )
        ifTrue: [                    "= 0 for 'enter' key"
            ( wordInteger == Idcancel and: [ longInteger == 0 ] )
                ifTrue: [ self sendInputEvent: #close. ^nil ].  "cancel"
            control :=  self childAtId: wordInteger lowWord.
            control notNil
                ifTrue: [

                    #modifiedByOSI.
                    "Modified by OSI to return an integer if desired."
                    answer :=  control syncControlEvent: wordInteger highWord with: longInteger.
                    answer isInteger ifFalse: [answer := nil].

                ] ]
        ifFalse: [
            self sendInputEvent: #performMenuItem:
                with: wordInteger lowWord ].
    ^answer! !

!Button methods !   
setWindowText: aString
        "Private - set the window text of the receiver."
    #addedByOSI.
    super setWindowText: (
		aString isString
			ifTrue: [aString withPlatformMnemonic]
			ifFalse: [aString]).! !

!WBWindowDialog methods !
openModalTo: aWindow
        "Open the dialog box modal to ownerTopPane."
	self wbPreOldVersionSupport.
    self createViews.
    self mainView openModal: aWindow mainView! !

!ViewManager methods !  
viewNamed: aSymbol
	"Added by OSI"

	| string |
	#addedByOSI.
	views do: [:v | v paneName = aSymbol ifTrue: [^v]].
	string := aSymbol asString.
	views do: [:v |v paneName = string ifTrue: [^v]].
	^nil! !

!Menu methods !
appendItemDynamically: anObject selector: aSelector
	"Added by OSI."

	#addedByOSI.
	self insertItemDynamically: anObject selector: aSelector atIndex: nil.! !

!Object methods !   
when: eventName send: selector to: anObject withArgument: anArgument
    "Added by OSI - Form an action with <anObject> as the receiver, a
     <selector> as the message selector, and <anArgumente> as the last argument
     and append it to the actions list for the event named <eventName>."
    | arguments size |
    #addedByOSI.
    selector isSymbol
        ifFalse: [^self errorBadSelector: selector].
    arguments := Array new: (size := Message numberOfArgumentsFor: selector).
    arguments at: size put: anArgument.
    self
        when: eventName
        evaluate:
            (Message
                receiver: anObject
                selector: selector
                arguments: arguments)! !

!Window methods !  
wmGettext: wParam
with: lParam
    "Added by OSI"

    #addedByOSI.
    ^nil! !

!WBDisplayContext methods !   
backColor: aColor

    self pen backColor = aColor ifFalse: [
        self pen backColor: aColor].! !

!WBDialogTopPane methods !
openModal: anOwner
        "Open the dialog box modal to the
         current active window."
    | cursor |

    Processor currentProcessIsRecursive ifTrue: [
        self error: 'Cannot do modal dialog during recursion.'].

    cursor := Cursor.
    CursorManager execute change.
    dialogOwner := anOwner ifNil: [ Notifier activeMainWindow ].

    "Disable parent now to ensure that there are no further activities at parent."
    dialogOwner isWindow ifTrue:[ dialogOwner disable ].
	self setOwner: dialogOwner.

    super openWindow.
    self event: #opened.
    CursorManager normal change.
    Processor currentProcessIsRecursive ifFalse: [ self processInput ].
    cursor change.! !

!Pen methods ! 
draw3DRect: aRect
depth: depth
style: style
    "Added by OSI"

    | back fore l r t b |

    #addedByOSI.
    style == #outline
        ifTrue:
            [^self
                foreColor: Color white;
                drawRectangle: (Rectangle leftTop: (aRect leftTop rightAndDown: 1) rightBottom:
aRect rightBottom);
                foreColor: Color buttonShadow;
                lineFrom: (aRect leftTop down: 1) to: aRect leftBottom;
                lineFrom: (aRect leftTop down: 1) to: (aRect rightTop down: 1);
                lineFrom: (aRect rightBottom leftAndUp: 2 @ 1) to: (aRect left right: 2) @ (aRect
bottom up: 1);
                lineFrom: (aRect rightBottom leftAndUp: 2) to: (aRect right left: 2) @ (aRect top
down: 3)].
    style = #in
        ifTrue:
            [back := Color white.
            fore := Color buttonShadow.
            ]
        ifFalse:
            [back := Color buttonShadow.
            fore := Color white.
            ].
    1 to: depth
        do:
            [:i |
			l := aRect left right: i.
			r := aRect right left: i + 1.
			t := aRect top down: i + Rectangle leftTopUnit y.
			b := aRect bottom up: i + Rectangle rightBottomUnit y.
			self
                foreColor: back;
                lineFrom: l @ b to: r @ b;
                lineFrom: r @ t to: r @ b;
                foreColor: fore;
                lineFrom: l @ t to: l @ b;
                lineFrom: l @ t to: r @ t.
			].! !

!Font methods !  
wbClearStringWidthCache
	"Clear the string width cache."

	self propertyTable removeKey: #wbStringWidthCache ifAbsent: [ ].! !

!WBDisplayContext methods !  
justification: aSymbol

    justification := aSymbol.! !

!WBDisplayContext methods ! 
defaultTextAlign

	^self class defaultTextAlign! !

!GraphicsTool methods !   
lineFrom: p1 to: p2

    "Added by OSI"
    #addedByOSI.
    self place: p1;
        line: p2.! !

!ViewManager methods !  
releaseEventTable
	"Release the receiver's event table."

	#addedByOSI.
	self propertyAt: #wbEventTable put: nil.! !

!WBDisplayContext methods !   
cellBorder: aSymbol
    "Set true if a cell border should be drawn."

    cellBorder := aSymbol.! !

!WBComboBox methods !   
dynamicListBottom
        "Answer the bottom coordinate of the dynamic list."
    ^(rectangle top down: self dynamicListHeight)
        higherOf:
            (Display boundingBox mapScreenToClient: self parent) bottom! !

!ViewManager methods !
openCenteredOnScreen
    "Added by OSI - Open the receiver centered over the mouse."

	| newInstance |
	self wbPreOldVersionSupport.
    newInstance := self createViews.
    newInstance notNil ifTrue: [
        newInstance
            centeredOnScreen;
            openViews.
    ] ifFalse: [
        #addedByOSI.
        MessageBox message:
            self class name,' does not have a #createViews method or its own #open method.'
    ].
    ^newInstance! !

!ViewManager class methods !   
openCenteredOnMouse
    "Added by OSI - Open a new instance of the receiver centered over the mouse."
    #addedByOSI.
    ^self new openCenteredOnMouse! !

!ApplicationCoordinator class methods ! 
windowId
        "Private - Answer the default dialog id for any
        DialogTopPane owned or implemented by a
        subclass of ApplicationCoordinator."
    ^1! !

!WindowDialog methods !
openWindow
        "Open the dialog box modal to the
         current active window."

    #modifiedByOSI.
    "Modified by OSI to support preInitWindow"
    self wbOldVersionSupport.
	self wbLinkPartEvents.
    self preInitWindow.

    self mainView open! !

!DrawnButton methods !
cpContents: labelOrFileName
    "Set the contents of the button. If aString is a valid bitmap file name (.BMP),
        the button will display the bitmap. If not, the button will look like a simple
        Button with aString as its label."

    #addedByOSI.
    labelOrFileName isString ifFalse: [^self contents: labelOrFileName].
    self propertyAt: #fileName put: labelOrFileName.
    (File exists: labelOrFileName)
        ifTrue: [
            bitmap := WBBitmapClass fromFile: labelOrFileName]
        ifFalse: [
            self removeStyle: self defaultStyle.
            self pushButton.
            super contents: labelOrFileName].! !

!RGBColor class methods !
chiseledGray
        "Answer the chiseledGray color."
    #addedByOSI.
    ^RGBColorChiseledGray! !

!ViewManager methods !  
openWindow
	"Open all the views."
	"Modified by OSI to support preInitWindow
		and remove #respondsTo: message"

	#modifiedByOSI.
	self wbOldVersionSupport.
	self wbLinkPartEvents.
	self preInitWindow.
	views do: [:each | each openWindow].! !

!WBComboBox methods !  
contents

    ^fullList! !

!TextTool methods !   
winDrawText: str at: aPoint

    "Added by OSI"
    #addedByOSI.
    self winDrawText: str in: (aPoint extentFromLeftTop: 30000@30000) format: 0.! !

!TextPane methods !   
wmGetdlgcode: wparam with: lparam
        "Private - process WM_GETDLGCODE message."

    #modifiedByOSI.
    self owner isWBWindow ifTrue: [^DlgcWantallkeys].

    ^ DlgcWantchars! !

!Number methods !
wbDisplayWith: aWBDisplayContext
    "Display a representation of the receiver using aWBDisplayContext."

    #addedByOSI.
    aWBDisplayContext
        defaultJustification: #right
        during: [super wbDisplayWith: aWBDisplayContext]! !

!ApplicationCoordinator methods !  
open
	    "Build and open a window for a new instance of the receiver."
    #addedByOSI.
    self class open: self.! !

!WBDisplayContext methods !  
foreColor

    ^self pen foreColor! !

!WBComboBox methods !  
resize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
    self isHandleOk ifFalse: [ ^nil ].
    self isSimpleList ifTrue: [ ^super resize: aRectangle ].
    self resizeWithoutDropDownList.! !

!File class methods ! 
findOrPromptFileName: fileName filters: filterCollection
       "Answer the full path of the file named fileName.
		filterCollection is a collection of associations whose
		keys are the filter (e.g. '*.*') and values are the filter
		descriptions (e.g. 'All files (*.*)')."

	#addedByOSI.
	^self
		findOrPromptFileName: fileName
		filters: filterCollection
		in: #( )! !

!ViewManager methods !
openWithMDIParent: aViewManager
    "Added by OSI - Open the receiver with aViewManager as an MDI Parent."
    | newInstance frame |
    (Smalltalk includesKey: #MDIChild) ifFalse: [
        MessageBox message: 'Cannot open ',self class name,
            ' because the MDI support is not installed.'.
        ^nil
    ].
	((aViewManager respondsTo: #frame)
		and: [ (frame := aViewManager frame) notNil ]
	) ifFalse: [
        MessageBox message: 'Cannot open ',self class name,
            ' because the parent window does not have an MDI Frame.'.
        ^nil
    ].
	self wbPreOldVersionSupport.
    newInstance := self
        execute: [ self createViews ]
        withTopPane: #MDIChild.
    newInstance notNil ifTrue: [
        self views do: [ :view |
            view frame: frame.
        ].
        newInstance openViews.
    ] ifFalse: [
        #addedByOSI.
        MessageBox message:
            self class name,' does not have a #createViews method.'
    ].
    ^newInstance! !

!SubPane methods !   
wmKeydown: wordInteger with: longInteger
        "Private - Process the key down message.  WM_KEYDOWN is generated when
        a key is pressed while the ALT key IS NOT DOWN."
    | event |
    self needsKeyDownInput ifTrue: [
        #addedByOSI.
        (event := KeyboardInputEvent keyDownFromWmKeydown: wordInteger with: longInteger) notNil ifTrue: [
            self sendInputEvent: #keyDownInput: with: event ] ].
    ^super wmKeydown: wordInteger with: longInteger! !

!Button methods !  
cancelPushButton
    "Set the cancel push button style so that this button
		is 'clicked' when the escape key is pressed."
    #addedByOSI.
    self propertyAt: #cancelPushButton put: true.! !

!String methods ! 
mnemonicChar

    "Added by OSI.  Scan for the mnenomic character (& or ~), and
     answer the character following it.  If no mnemonic, answer nil."

    | index size ch |
    #addedByOSI.
    index := 1.
    size := self size.
    [ index < size ] whileTrue: [
        (ch := self at: index) = $& | (ch = $~) ifTrue: [
            ^(self at: index + 1) asUpperCase ].
        index := index + 1 ].
    ^nil! !

!OrderedCollection methods !  
wbEventTable: anObject
		"Set the window builder event table."
	#addedByOSI.
	^anObject! !

!Object methods !
isCompositePane

    "Added by OSI"
    #addedByOSI.
    ^false! !

!Number methods !   
distanceLeft: aNumber
        "Answer the distance between the receiver and aNumber
            where right and down are positive."
    #addedByOSI.
	^aNumber distanceRight: self! !

!Object methods !
=> anObject
        "Answer a new instance of an Association
        with key the receiver and value anObject."

    "** Courtesy OTI (added)"

	#addedByOSI.
    ^Association key: self value: anObject! !

!Font class methods !   
wbClearAllStringWidthCaches
	"Clear the string width cache for all Fonts."

	"
	Font wbClearAllStringWidthCaches.
	"

	#addedByOSI.
	self allInstances do: [:each | each wbClearStringWidthCache].! !

!Window methods !
wbDisplayContextPenFor: aWBDisplayContext
    "Private - Answer the window builder display context pen for the receiver.
		DO NOT create one if it does not already exist.  The pen must already
		be created during window validation *OR* the caller must use the display context
		inside a #doGraphics: block then clear the pen of the display context."

    #addedByOSI.
	^(graphicsTool ifNil: [^nil])
		foreColor: (self foreColor ifNil: [aWBDisplayContext defaultForeColor]);
		backColor: (self backColor ifNil: [aWBDisplayContext defaultBackColor]);
		yourself! !

!WBDisplayContext class methods ! 
textJustificationConstants: aDictionary
    "Set the dictionary mapping justification to platform specific constant."

    TextJustificationConstants := aDictionary.! !

!Menu methods !
allMenuItems

	| allItems |
	(allItems := OrderedCollection new)
		addAll: self items.
	self items do: [:item |
		item submenu isNil
			ifFalse: [allItems addAll: item submenu allMenuItems]].
	^allItems! !

!UndefinedObject methods !   
ifNil: aBlock

    "Added by OSI. This replaces the construct 'isNil ifTrue: []'.
     In the case self IS nil"

    #addedByOSI.
    ^aBlock value! !

!ViewManager class methods !  
open
    "Added by OSI - Open a new instance of the receiver."
    #addedByOSI.
    ^self new open! !

!Rectangle methods !  
rightAndDown: aPoint
        "Answer a rectangle right and down of the receiver by aPoint."
    #addedByOSI.
    ^(self topLeft rightAndDown: aPoint)
        rightBottom: (self rightBottom rightAndDown: aPoint)! !

!WBComboBox methods !
buildList

    super contents: (fullList select: [ :el | (disabled includes: el) not ]).
    self selectIndex: value.! !

!Window class methods !
wbRunBaseUnbind
	"Unbind the base runtime for Win32."

	#addedByOSI.
	OperatingSystemEvents
		at: 13  put: nil;
		at: 1123 put: nil.
	ColorConstants
		removeKey: 'ClrChiseledgray' ifAbsent: [ ].
	IndexedColor defaultColors
		removeKey: #paleGray ifAbsent: [ ].! !

!Color class methods !   
paleGray
        "Answer an instance of the receiver representing the color paleGray."
    #addedByOSI.
    ^self defaultColorNamed: #paleGray! !

!Rectangle class methods !
topBottomUnit
        "Answer the signed unit from top to bottom."
	#addedByOSI.
    ^1! !

!Date class methods !
monthStrings
    "Added by OSI"
    #addedByOSI.
	^WBMonthStrings! !

!WBDisplayContext methods !
backColor

    ^self pen backColor! !

!Object class methods !
wbVersion
    "Answer the window builder version (or nil)."
    #addedByOSI.
    ^self wbBasicVersion ifNil: [
        self wbCreated
            ifTrue: [1.0]
            ifFalse: [nil]]! !

!SubPane methods !
basicKeyboardInput: aKeyboardInputEvent
	"Added by OSI: Provide support for Escape key"

	| button |
	#addedByOSI.
	self owner isWBWindow ifTrue: [
		aKeyboardInputEvent virtualKey == EscapeKey ifTrue: [
			(button := self mainWindow cancelPushButton) notNil ifTrue: [
				button disabled not ifTrue: [
					button click]]]].
	^super basicKeyboardInput: aKeyboardInputEvent! !

!WBDisplayContext class methods !   
defaultJustification

    ^#left! !

!Point methods ! 
distanceRightAndDown: aPoint
        "Answer the distance between the receiver and aPoint
            where right and down are positive."
    #addedByOSI.
    ^(x distanceRight: aPoint x) @ (y distanceDown: aPoint y)! !

!WBDisplayContext methods !
textFlags

    | answer |
    answer := self class textJustificationConstantFor: self justification.
    self wrap ifTrue: [answer := answer | DtWordbreak].
    answer := answer | DtNoprefix.
    ^answer! !

!LargePositiveInteger methods !   
highHalf

    " ** Added by Objectshare ** "
    "Answer the high half of the receiver."

    #addedByOSI.
    ^(ExternalLong fromInteger: self) highHalf! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!Font methods !
wbStringWidthCache
	"Answer the string width cache."

	| answer |
	#addedByOSI.
	answer := self propertyAt: #wbStringWidthCache.
	answer isNil ifTrue: [
		answer := self wbConstructStringWidthCache.
		self propertyAt: #wbStringWidthCache put: answer].
	^answer! !

!ApplicationWindow methods !  
validateShow
    "Private - Perform validates and show window."

    self performWhenValids.
    children do: [:each |
        each isApplicationWindow
            ifTrue: [each validateShow]
            ifFalse: [each validate]].

    #modifiedByOSI.
    self owner initWindow.
    (self owner isWBWindow and: [self container notNil])
        ifTrue: [self container deactivateInPlaceObject: 1@1].

    self zoomed ifTrue: [
        self children do: [:each | each zoomed ifFalse: [each hideWindow]]].
    collapsed isNil ifTrue: [collapsed := 0].
    self isHidden ifFalse: [
        collapsed isRectangle
            ifTrue: [self showMaximizedWindow]
            ifFalse: [collapsed < 0
                ifTrue: [self showIconicWindow]
                ifFalse: [self showWindow]]].

    self sendDeferredEvent: #subclassRecursively.
    self sendDeferredEvent: #triggerOpenedEvent! !

!WBDisplayContext methods !
font: aFont

    self pen font = aFont ifFalse: [
        self pen font: aFont].! !

!ViewManager methods !  
centeredOnMouse
    "Added by OSI - Open the receiver centered over the mouse.
     Call this method from within #preInitWindow"

	| center |
	#addedByOSI.
	center := CursorManager cursorPosition.
	self mainView isDialog
		ifTrue: [self mainView framingBlock alignDialogCenter: center]
		ifFalse: [self mainView framingBlock alignWindowCenter: center].! !

!Menu methods !   
selectorOf: id
        "Private - Answer the selector for the item whose id is id."

    #modifiedByOSI.
    "Modified by OSI to prevent walkback when id is out of bounds."
    (id \\ 256 between: 1 and: items size) ifFalse: [^nil].

    ^( items at: ( id \\ 256 ) ) selector! !

!SubPane methods !   
verticalScrollMaxRange
        "Private - Answer the vertical scrollbar's max range"
    | maxPos |
	#addedByOSI.
	"Copied from GraphPane."
    ( UserLibrary
        getScrollRange: self handle asParameter
        bar: SbVert
        lpMinPos: ExternalLong new asParameter
        lpMaxPos: ( maxPos := ExternalLong new ) asParameter )
            ifFalse: [ ^self osError ].
    ^maxPos asInteger! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!Object methods ! 
isFramingParameters
    "Answer true if the receiver is FramingParameters."
		#addedByOSI.
    ^false! !

!String methods !  
withPlatformMnemonic
    #addedByOSI.
    ^self collect: [:char | char = $~
        ifTrue: [$&]
        ifFalse: [char]].! !

!WBDisplayContext class methods !
justification

    ^justification ifNil: [
        justification := self defaultJustification]! !

!ViewManager methods !
positionRelativeTo: aViewManager offset: aPoint
	"Added by OSI - Open the receiver relative to <aViewmanager>.
		 Call this method from within #preInitWindow"

	| leftTop |
	leftTop :=
		(aViewManager isWindow ifTrue: [aViewManager] ifFalse: [aViewManager mainView])
			frameRectangle leftTop rightAndDown: aPoint.
	self mainView isDialog
		ifTrue: [self mainView framingBlock alignDialogLeftTop: leftTop]
		ifFalse: [self mainView framingBlock alignWindowLeftTop: leftTop].! !

!GraphicsTool methods !
quickLineFrom: p1 to: p2 using: aHandle

    "Added by OSI for 3D rects."
    #addedByOSI.
    GDILibrary moveToEx: aHandle x: p1 x y: p1 y oldPosition: nil.
    GDILibrary lineTo: aHandle x: p2 x y: p2 y.! !

!ControlPane class methods ! 
constructSynchronousNotifications
	"Private - Construct a Dictionary mapping between host control
		notification codes and corresponding Smalltalk event notifications."

	#addedByOSI.
	^Dictionary new! !

!LayoutFrame methods !
alignDialogLeftTop: aPoint
	"Align the left top of the receiver to aPoint."

	| du aBox duBox duPoint oldRect newRect offset |
	du := (4 / (SysFont width roundTo: 2)) @ (8 / SysFont height).
	aBox := Display boundingBox.
	duBox := aBox scaleBy: du.
	duPoint := aPoint * du.
	oldRect := self valueForDialogTopPane: aBox.
	newRect :=
		((aPoint * du
			rightMostAndLowest: duBox leftTop)
			leftMostAndHighest: (duBox rightBottom leftAndUp: oldRect extent))
			extentFromLeftTop: oldRect extent.
	offset := oldRect leftTop distanceRightAndDown: newRect leftTop.
	self leftInset: (self leftInset + offset x).
	self topInset: (self topInset + offset y).
	self rightInset: (self rightInset - offset x).
	self bottomInset: (self bottomInset - offset y).! !

!WBWindowDialog methods ! 
topPaneClass
    "Private - Answer the defalut top pane class."
    ^WBDialogTopPane! !

!Number methods !
distanceRight: aNumber
        "Answer the distance between the receiver and aNumber
            where right and down are positive."
    #addedByOSI.
    ^(aNumber - self) * Rectangle leftRightUnit! !

!Object methods ! 
minWindowSize
    "Added by OSI"
    #addedByOSI. "PARTS Support"
    ^nil! !

!MessageBox class methods !   
yesNoCancelTitled: title text: text
        "Added by OSI - Answer #yes, #no, or nil"
    | answer |
    #addedByOSI.
    answer := self threeStateNotify: title withText: text.
    answer = true ifTrue: [ answer := #yes ].
    answer = false ifTrue: [ answer := #no ].
    ^answer! !

!WBDisplayContext methods ! 
defaultPen
    "Private - Answer the window builder display context pen for the receiver.
		DO NOT create one if it does not already exist.  The pen must already
		be created during window validation *OR* the caller must use the display context
		inside a #doGraphics: block then clear the pen of the display context."

    ^self window wbDisplayContextPenFor: self! !

!SubPane methods !  
keyUpInput: aKeyboardInputEvent
        "Private - A key up event was received."
    #addedByOSI.! !

!ViewManager methods !  
centeredOnScreen
    "Added by OSI - Open the receiver centered on the screen.
     Call this method from within #preInitWindow"

	| center |
	#addedByOSI.
	center := Display boundingBox center.
	self mainView isDialog
		ifTrue: [self mainView framingBlock alignDialogCenter: center]
		ifFalse: [self mainView framingBlock alignWindowCenter: center].! !

!WBDisplayContext methods ! 
cellBoxClipped

    ^self cellBox intersect: self windowBox! !

!Object methods ! 
preInitWindow
	"Added by OSI"

	#addedByOSI.! !

!WBDisplayContext class methods !   
justification: aSymbol

    justification := aSymbol.! !

!Menu methods ! 
uncheckAll
    "Added by OSI - Uncheck all items for the receiver."
    #addedByOSI.
    items do: [ :mi |
        mi hasSubmenu ifTrue: [ mi submenu uncheckAll ].
        (self isChecked:mi selector) ifTrue: [ self uncheckItem: mi selector ]].! !

!Window methods ! 
paneNamed: aPaneName

    "Added by OSI"

    #addedByOSI.
    ^( self wbPaneNamed: aPaneName ) ifNil: [
        self wbPaneNamed: aPaneName asString ]! !

!LayoutFrame methods !
alignWindowLeftTop: aPoint boundingBox: aBox
	"Align the left top of the receiver to aPoint."

	| oldRect newRect offset |
	oldRect := self value: aBox.
	newRect :=
		((aPoint
			rightMostAndLowest: aBox leftTop)
			leftMostAndHighest: (aBox rightBottom leftAndUp: oldRect extent))
			extentFromLeftTop: oldRect extent.
	offset := oldRect leftTop distanceRightAndDown: newRect leftTop.
	self leftInset: (self leftInset + offset x).
	self topInset: (self topInset + offset y).
	self rightInset: (self rightInset - offset x).
	self bottomInset: (self bottomInset - offset y).! !

!ApplicationCoordinator methods !   
topPaneClass
		"Answer the receiver's top pane class."
    #addedByOSI.
    ^self class windowClass! !

!ViewManager methods !   
initializeAgain
        "Private - Initialize the receiver after a close.
            For PARTS support."
    #addedByOSI.
    views removeAll.
    self
        wbUnlinkPartEvents;
        wbUnlinkPartMessages.! !

!WBComboBox class methods !   
hasDynamicListSizeStyle: aBoolean
		"Set the default value for the dynamic list size style."
	IsListSizeDynamicDefault := aBoolean = true.! !

!ControlPane class methods !   
synchronousNotifications
	"Private - Answer a Dictionary mapping between host control
		notification codes and corresponding Smalltalk event notifications."

	#addedByOSI.
	^self constructSynchronousNotifications! !

!WBComboBox methods ! 
initSize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
	| h |
    super initSize: aRectangle.
    self isSimpleList ifFalse: [
		h := self heightWithoutDropDownList.
		OperatingSystem isOS2 ifTrue: [
			self topParent isDialog ifTrue: [
				h := h // (SysFont height / 8).
				self framingBlock isFramingParameters ifFalse: [
					self propertyAt: #resizeWithoutDropDownListArg put: aRectangle]]].
        rectangle := rectangle leftTop extentFromLeftTop: rectangle width @ h].! !

!WindowDialog methods !   
openModeless
        "Open the dialog box as a modeless window."

    #modifiedByOSI.
    "Modified by OSI to support preInitWindow"
    self wbOldVersionSupport.
	self wbLinkPartEvents.
    self preInitWindow.

    self mainView openModeless! !

!Object methods !   
ifNil: aBlock

    "Added by OSI. This replaces the construct 'isNil ifTrue: []'.
     In this case self is NOT nil"

    #addedByOSI.
    ^self! !

!Pen methods !   
draw3DButtonRect: aRect leftTopColor: aLeftTopColor rightBottomColor: aRightBottomColor

    "Added by OSI"
    | theHandle leftRight1 leftRight2 rightLeft2 rightLeft3
	topDown1 topDown2 bottomUp2 bottomUp3 oldColor |
    #addedByOSI.
    theHandle := self handle.
    leftRight1 := aRect left right: 1.
    leftRight2 := aRect left right: 2.
    rightLeft2 := aRect right left: 2.
    rightLeft3 := aRect right left: 3.
    topDown1 := aRect top down: 1.
    topDown2 := aRect top down: 2.
    bottomUp2 := aRect bottom up: 2.
    bottomUp3 := aRect bottom up: 3.
	oldColor := self foreColor.

    self
        foreColor: aLeftTopColor;
        quickLineFrom: leftRight1 @ topDown1 to: rightLeft2 @ topDown1 using: theHandle;
        quickLineFrom: leftRight1 @ topDown2 to: rightLeft3 @ topDown2 using: theHandle;
        quickLineFrom: leftRight1 @ topDown1 to: leftRight1 @ bottomUp2 using: theHandle;
        quickLineFrom: leftRight2 @ topDown1 to: leftRight2 @ bottomUp3 using: theHandle;
        foreColor: aRightBottomColor;
        quickLineFrom: leftRight1 @ bottomUp2 to: (aRect right left: 1) @ bottomUp2 using: theHandle;
        quickLineFrom: leftRight2 @ bottomUp3 to: rightLeft2 @ bottomUp3 using: theHandle;
        quickLineFrom: rightLeft2 @ topDown1 to: rightLeft2 @ (aRect bottom up: 1) using: theHandle;
        quickLineFrom: rightLeft3 @ topDown2 to: rightLeft3 @ bottomUp2 using: theHandle;
        foreColor: oldColor.! !

!WBDisplayContext methods !  
wrap: aBoolean

    wrap := aBoolean.! !

!Object methods !   
isWBWindow

    "Added by OSI."
    #addedByOSI.
    ^false! !

!WBDisplayContext methods ! 
splitCellLeftInset: anInteger
    "Split the cell into two parts based on anInteger.
        Set the cellBox and answer the other."

    | box x |
    box := self cellBox.
    x := box left right: anInteger truncated.
    self cellBox: (box leftTop rightBottom: x @ box bottom).
    ^x @ box top rightBottom: box rightBottom! !

!WBComboEntryField methods !   
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process tab key."

	super keyboardInput: aKeyboardInputEvent.
	self basicKeyboardInput: aKeyboardInputEvent.! !

!Font methods !
wbStringExtent: aString
        "Answer the extent of aString using the receiver font."
    | stream width lines pos line |
	#addedByOSI.
    aString isNil ifTrue: [ ^0 ].
	stream := ReadStream on: aString.
	width := 0.
	lines := 0.
	[stream atEnd] whileFalse: [
		pos := stream position.
		line := stream nextLine.
		width := width max: (self wbStringWidth: line).
		lines := lines + 1].
	lines := lines max: 1.
	line notNil ifTrue: [
		stream position - pos > line size ifTrue: [
			lines := lines + 1]].
	^width @ (lines * self height)! !

!ViewManager methods !  
createViewsOnce
    "Create the views only if not already created.
        For PARTS support."

    #addedByOSI.
    views isEmpty
        ifTrue: [self createViews]
        ifFalse: [
            "Reset the rectangle of each closed view because the rectangle
                was being inset by the border size each time it was reopened."
            views do: [:each |
                each isHandleOk ifFalse: [
                    each rectangleAttribute: (
                        each framingRectangleFor: Display boundingBox)]]].! !

!ViewManager methods !  
openWithMyParent: aViewManager
	"Added by OSI - Open a the receiver as a child of
		 aViewManager's parent (a sibling)."

	#addedByOSI.
	aViewManager mainView wbOwner isNil
		ifTrue: [^self open]
		ifFalse: [^self openWithParent: aViewManager mainView wbOwner]! !

!ViewManager class methods !
openAsMDIParent
    "Added by OSI - Open a new instance of the receiver
     as an MDI parent."
    #addedByOSI.
    ^self new openAsMDIParent! !

!ViewManager methods !   
openViewsWithOwner: aViewManager
      "Added by OSI"
    #addedByOSI.
    self
        parent: aViewManager;
        openViews;
        setOwner: aViewManager.! !

!ApplicationCoordinator class methods !  
wbSpecialEvents
    "Added by OSI to support special needs"
    #addedByOSI.
    ^#(#wbNeedsView #wbNeedsPaneNamed: #wbNeedsMenuNamed:)! !

!WBDisplayContext methods !  
displayCell

	| region |
	region := self pen setClipRect: self cellBoxClipped.
	self perform: self cellBorder.
	self pen 
		setClipRect: nil;
		destroyRegion: region.! !

!GraphicsTool methods !   
fill: aRectangle bitmap: aBitmap

    "Added by OSI"

    | oldBrush newBrush |
    #addedByOSI.
    newBrush := GDILibrary createPatternBrush: aBitmap handle.

    oldBrush := self selectObject: newBrush.
    self patternFill: aRectangle
        rule: Patcopy.
    self selectObject: oldBrush.
    self deleteObject: newBrush! !

!ViewManager methods !   
openAsMDIParent
    "Added by OSI - Open the receiver as an
     MDI parent window."
    | newInstance |
    (Smalltalk includesKey: #MDIChild) ifFalse: [
        MessageBox message: 'Cannot open ',self class name,
            ' because the MDI support is not installed.'.
        ^nil
    ].
	self wbPreOldVersionSupport.
    newInstance := self
        execute: [ self createViews ]
        withTopPane: #MDIFrame.
    newInstance notNil ifTrue: [
        (newInstance menuWindow menus isEmpty and: [
        (newInstance mainView handlesEvent: #menuBuilt) not ]) ifTrue: [
            newInstance menuWindow addMenu:
                (Menu new title: '&MDI'; owner: self; yourself)
        ].
        newInstance openViews.
    ] ifFalse: [
        #addedByOSI.
        MessageBox message:
            self class name,' does not have a #createViews method or its own #open method.'
    ].
    ^newInstance! !

!Point methods !   
distanceLeftAndDown: aPoint
        "Answer the distance between the receiver and aPoint
            where left and down are positive."
    #addedByOSI.
    ^(x distanceLeft: aPoint x) @ (y distanceDown: aPoint y)! !

!WBComboBox methods ! 
addDynamicListSizeStyle
		"Dynamically size the receiver's frame based on the
			number of elements in the receiver's list."
	isListSizeDynamic := true.! !

!WindowDialog methods ! 
isModal
    "Added by OSI - is the receiver modal or not"
    #addedByOSI.
    ^(self mainView hasStyle: (OperatingSystemConstants at: 'DsModalframe'))
		| (self mainView hasStyle: (OperatingSystemConstants at: 'DsSysmodal'))! !

!TopPane methods !
cancelPushButton: aButton
        "Private - Set the subpane which is the cancel push button."
    #addedByOSI.
    ^self propertyAt: #cancelPushButton put: aButton! !

!DrawnButton methods !  
invisible
    "Makes the button invisible (no label or bitmap). This is useful
		for creating 'sense regions' on top of other visual objects.
		For this to work properly, exclude the widget from the tab order."
    #addedByOSI.
    drawSelector := #invisible:.! !

!Object methods ! 
dialogTemplate: ignore
    "Added by OSI"
    #addedByOSI.
    ^self! !

!Object methods !   
wbUnlinkPartEvents
        "Private - Unlink the parts events from the subpanes to the receiver."
    #addedByOSI.! !

!Window methods !  
addSubpaneDynamically: aSubPane
    "Added by OSI - Add a subpane to a window dynamically"
    #addedByOSI.
    self addSubpane: aSubPane.
    aSubPane open;
        initSize: self rectangle;
        buildWindow: self;
        resize: self rectangle;
        subclassRecursively;
        validate.! !

!Window methods !
paneName: aName

    "Added by OSI"
    #addedByOSI.

    ^self setName: aName

    "For compatibility with V/Win, use the following instead:"

    "^self propertyAt: #paneName put: aName"! !

!SubPane methods !
wmNchittest: wParam with: lParam
	"Private - Process Non-client mouse hit test message."

	#addedByOSI.
	self hasTransparentStyle ifTrue: [^Httransparent].
	^super wmNchittest: wParam with: lParam! !

!Pen methods !
draw3DButtonRectReversed: aRect
	    "Added by OSI"
	#addedByOSI.
	self
		draw3DButtonRect: aRect
		leftTopColor: Color buttonShadow
		rightBottomColor: Color buttonHighlight.! !

!Pen methods !
draw3DButtonRect: aRect
	    "Added by OSI"
	#addedByOSI.
	self
		draw3DButtonRect: aRect
		leftTopColor: Color buttonHighlight
		rightBottomColor: Color buttonShadow.! !

!WBDisplayContext methods !   
displayNoBorder

    self pen blank: self cellBox.! !

!SubPane methods ! 
dragTargetOperationsDefault
		"Private - answer the operations that the receiver can accept."
	#addedByOSI.
	^#( #move #copy )! !

!ViewManager methods !
openCenteredOnMouse
    "Added by OSI - Open the receiver centered over the mouse."

	| newInstance |
	self wbPreOldVersionSupport.
    newInstance := self createViews.
    newInstance notNil ifTrue: [
        newInstance
            centeredOnMouse;
            openViews.
    ] ifFalse: [
        #addedByOSI.
        MessageBox message:
            self class name,' does not have a #createViews method or its own #open method.'
    ].
    ^newInstance! !

!WBDisplayContext methods !  
justification

    ^justification ifNil: [
        justification := self defaultJustification]! !

!RadioButton methods !
notifyClicked: aParameter
        "Private - the host signaled a clicked event."
	#addedByOSI.
	super notifyClicked: aParameter.
	self selection: true.! !

!TextTool methods ! 
winDrawText: aString in: aRect justification: just
        "Added by OSI"
    #addedByOSI.
    ^self winDrawText: aString in: aRect format: just! !

!WBComboBox methods !   
forkListHiddenWatcher
		"Private - OS/2 does not notify us when the the drop down list
			is hidden again, so fork a process to watch for the list being hidden."
	| done oldFrame |
	done := false.
	oldFrame := self rectangle.
	[	[	[	self isHandleOk
					ifTrue: [
						self isDropdownVisible ifFalse: [
							oldFrame = self rectangle ifFalse: [
								self superWindow invalidateRect: oldFrame].
							self resizeWithoutDropDownList.
							done := true]]
					ifFalse: [done := true].
			] evaluateWithoutInterrupts.
			done
		] whileFalse: [Processor yield].
	] forkAt: self class forkListHiddenWatcherPriority.! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!WBDisplayContext methods !
displayBorder

    | oldColor |
    oldColor := self pen foreColor.
    self pen
        blank: self cellBox;
        foreColor: self borderColor;
        drawRectangle: self cellBox;
        foreColor: oldColor.! !

!ViewManager methods ! 
openWithParent: aViewManager
	"Added by OSI - Open the receiver with aViewManager as Parent."

	| newInstance |
	#addedByOSI.
	self wbPreOldVersionSupport.
	newInstance := self createViews.
	newInstance notNil
		ifTrue: [
			newInstance openViewsWithOwner: aViewManager]
		ifFalse: [
			MessageBox message:
				self class name,' does not have a #createViews method.'].
	^newInstance! !

!GroupBox methods ! 
wbAddToBack
    "Private - Answer true if the receiver should be added to the back."

    #addedByOSI.
    ^true! !

!WBComboBox methods !  
dynamicListSize
		"Private - Answer the # of elements in the receiver's list."
	^super contents size max: 3! !

!SubPane methods !
verticalScrollMinRange
        "Private - Answer the vertical scrollbar's min range"
    | minPos |
	#addedByOSI.
	"Copied from GraphPane."
    ( UserLibrary
        getScrollRange: self handle asParameter
        bar: SbVert
        lpMinPos: ( minPos := ExternalLong new ) asParameter
        lpMaxPos: ExternalLong new asParameter )
            ifFalse: [ ^self osError ].
    ^minPos asInteger! !

!UndefinedObject methods !
osiIgnoredInitializerSource !

!WBDisplayContext methods !   
defaultJustification: aSymbol during: aBlock

    | answer |
    justification notNil ifTrue: [^aBlock value].
    justification := aSymbol.
    answer := aBlock value.
    justification := nil.
    ^answer! !

!Date class methods ! 
nameOfMonthAbbreviated: anInteger
        "Answer the month name as a Symbol corresponding
         to the month index anInteger (January for index
         1, to December for index 12)."
    | aName |
    (anInteger > 12 or: [anInteger < 1])
        ifTrue: [self errorInMonth].
    MonthNames associationsDo: [ :assoc |
        (anInteger = assoc value) ifTrue: [
            aName isNil
                ifTrue: [ aName := assoc key ]
                ifFalse: [
                    ^(aName size < assoc key size)     "answer short name"
                        ifTrue: [ aName ]
                        ifFalse: [ assoc key]]]].
    aName isNil
        ifTrue: [ self errorInMonth]
        ifFalse: [ ^aName ].! !

!Integer methods !
bitIsOn: n

    "Added by OSI"

    #addedByOSI.
    ^(self bitAnd: n) = n! !

!LayoutFrame methods !  
alignWindowCenter: aPoint
	"Align the Center of the receiver to aPoint."

	| box |
	box := Display boundingBox.
	self
		alignWindowLeftTop: (aPoint leftAndUp: ((self value: box) extent // 2))
		boundingBox: box.! !

!SubPane methods !   
setScrollRanges
        "Private - Set the ranges for the horizontal and vertical
          scroll bars."
    | rangeRect minHorz maxHorz minVert maxVert |
	#addedByOSI.
	"Copied from GraphPane."
    rangeRect := self scrollingRectangle
        insetBy: (self rectangle extent // 2).
    minHorz := rangeRect left.
    maxHorz := rangeRect right.
    minVert := rangeRect top.
    maxVert := rangeRect bottom.
    (self style bitAnd: WsHscroll) = 0
        ifTrue: [minHorz := maxHorz := 0].
    (self style bitAnd: WsVscroll) = 0
        ifTrue: [minVert := maxVert := 0].
    ( UserLibrary
        setScrollRange: self asParameter
        bar: SbHorz
        min: minHorz
        max: maxHorz
        redraw: false )
            ifFalse: [ ^self osError ].
    ( UserLibrary
        setScrollRange: self asParameter
        bar: SbVert
        min: minVert
        max: maxVert
        redraw: false )
            ifFalse: [ ^self osError ]! !

!WBDisplayContext class methods !   
defaultCellInset

    ^1 @ 0 rightBottom: 2 @ 0! !

!File class methods ! 
findOrPromptFileName: fileName in: aCollectionOfDir
        "Answer the full path of the file named fileName.
        Searching in aCollectionOfDir first, then the current search path,
		 then prompt the user.  If the user specifies a directory that is not
		 in aCollectionOfDir, then add that directory to aCollectionOfDir."

	#addedByOSI.
	^self
		findOrPromptFileName: fileName
		filters: #( )
		in: aCollectionOfDir! !

!ViewManager methods !   
isModal

    "Added by OSI"
    #addedByOSI.
    ^false! !

!WBDisplayContext methods ! 
displayVerticalBorder

	| oldColor |
	oldColor := self pen foreColor.
	self pen
		blank: self cellBox;
		foreColor: self borderColor;
		setClipRect: nil;
		place: (self cellBox right left: 1) @ self windowBox top;
		line: (self cellBox right left: 1) @ self windowBox bottom;
		foreColor: oldColor.! !

!KeyboardInputEvent class methods !
keyDownFromWmKeydown: wparam with: lparam
        "Private - answer an instance of the receiver class corresponding to
        the host WM_CHAR message described by the arguments."
    #addedByOSI.
    ^self fromWmChar: wparam with: lparam! !

!Button methods !   
initialText
        "Private - Answer the receiver's initial text string"
	| answer |
    #addedByOSI.
	(answer := super initialText) isString ifTrue: [
		answer := answer withPlatformMnemonic].
	^answer! !

!String methods ! 
stripMnemonic

    "Added by OSI"
    #addedByOSI.
    ^self reject: [ :c | (c = $~) | (c = $&) ]! !

!WBDisplayContext methods !   
window: aWindow
    "Set the window associated with the receiver
        and answer the receiver."

    window := aWindow.! !

!WBDisplayContext class methods !
defaultTextJustificationConstant
    "Answer the default text justification constant."

    ^0! !

!OrderedCollection methods !  
wbEventTable
		"Answer the window builder event table."
	#addedByOSI.
	^nil! !

!WBDisplayContext methods !  
textAlign

	^self defaultTextAlign! !

!WBDialogTopPane methods ! 
open
    "Open the dialog box modal to the
     current active window."
    ^ self openModal: nil! !

!String methods !  
asProperNoun
    "Added by OSI. Answer a String containing the receiver
     with alphabetic characters in mixed proper case."
    | answer size index aCharacter |
    #addedByOSI.
    size := self size.
    answer := String new: size.
    index := 1.
    [index <= size]
        whileTrue: [
            aCharacter := self at: index.
            (index == 1 or: [
            (self at: index - 1) isWhitespace and: [
            aCharacter isLowerCase ]])
                ifTrue: [aCharacter := aCharacter asUpperCase].
            answer at: index put: aCharacter.
            index := index + 1].
    ^answer! !

!OrderedCollection methods !   
wbPropertyAt: key 
        "Private - Answer the value associated with key
	        in the properties dictionary."
	#addedByOSI.
	^nil! !

!ViewManager methods !   
views
    "Added by OSI"

    #addedByOSI.
    ^views! !

!WBDisplayContext class methods ! 
textJustificationConstantFor: aSymbol
    "Answer the text justification constant (platform specific) for the specified justification."

    ^self textJustificationConstants
        at: aSymbol
        ifAbsentPut: [self defaultTextJustificationConstant]! !

!SubPane methods !  
tabGroupMembers
        "Answer the members of the tab group
        that the receiver belongs to."
    | orderedChildren radioGroupLeader index groupLeader group size |

    "Moved this method from RadioButton to SubPane so others can use it..."
    #addedByOSI.

    self tabScope isNil   "New window initializing controls (no parent yet)."
        ifTrue: [ ^OrderedCollection new.].
    orderedChildren := self tabScope orderedChildren.
    orderedChildren size = 0
        ifTrue: [ ^orderedChildren ].  " shouldn't happen... "
    radioGroupLeader := 1.
    groupLeader := 1.
    index := 0.
    orderedChildren do: [ :child |
        index := index + 1.
        child isAGroupLeader
            ifTrue: [ groupLeader := index ].
        child == self
            ifTrue: [ radioGroupLeader := groupLeader ] ].

    group := OrderedCollection new.
    group add: ( orderedChildren at: radioGroupLeader ).
    index := radioGroupLeader + 1.
    size := orderedChildren size.
    [  index <= size and:
        [ ( orderedChildren at: index ) isAGroupLeader not ] ]
    whileTrue: [
        group add: ( orderedChildren at: index ).
        index := index + 1 ].

    ^group! !

!WBDisplayContext methods !  
cellInset

    ^cellInset ifNil: [
        cellInset := self defaultCellInset]! !

!Object methods ! 
wbLinkPartEvents
	"Private - Link the parts events from the subpanes to the receiver."

	#addedByOSI.! !

!Font methods !
wbConstructStringWidthCache
	"Answer a new string width cache."

	| oldFont answer |
	oldFont := Display pen font.
	Display pen font: self.
	answer := (0 to: 255) collect: [:index |
		self
			charWidth: (Character value: index)
			graphicsMedium: Display].
	Display pen font: oldFont.
	^answer! !

!ViewManager methods ! 
openWithOwner: aViewManager
	"Added by OSI - Open the receiver with aViewManager as owner of
		all the subpanes (the target of the #when:perform: messages). This
		method can only be used in conjunction with the 'Power Views' Add-In."

	| newInstance |
	#addedByOSI.
	newInstance := self createViewsFor: self owner: aViewManager.
	newInstance notNil
		ifTrue: [
			newInstance openViews; setOwner: aViewManager]
		ifFalse: [
			MessageBox message:
				self class name,' does not have a #createViewsFor:owner: method.'].
	^newInstance! !

!Object methods !   
wbUnlinkPartMessages
        "Private - Unlink the parts messages from the subpanes to the receiver."
    #addedByOSI.! !

!GraphicsTool methods !
setBackgroundModeTransparent
		"Set the background mode."
	#addedByOSI.
	self setBackgroundMode: 1. "(GraphicsConstants at: 'BackgroundMixTransparent')"
! !

!ViewManager methods !
open
    "Added by OSI - Open the receiver."
    | newInstance |
    self wbPreOldVersionSupport.
    newInstance := self createViewsOnce.
    newInstance notNil
        ifTrue: [newInstance openViewsOnce]
        ifFalse: [
            #addedByOSI. #generated.
            MessageBox message:
                self class name,' does not have a #createViews method or its own #open method.'].
    ^newInstance! !

!Window methods !   
wbAddToBack
    "Private - Answer true if the receiver should be added to the back."

    #addedByOSI.
    ^false! !

!WBWindowDialog methods ! 
close
        "Close all the views."
    views do: [:v | v close]! !

!WBDisplayContext class methods !   
defaultTextAlign

	^TaTop | TaLeft! !

!WBDisplayContext methods !
defaultBorderColor

    ^(self backColor = Color gray) | (self backColor = Color paleGray)
        ifTrue: [Color darkGray]
        ifFalse: [Color gray]! !

!Menu methods !   
clearPopup
    "Added by OSI"
    #addedByOSI.
    popup := nil.! !

!MenuWindow methods !   
wbMenuTitled: aString

    "Added by OSI - Search through all menus, including
      submenus, for the menu described below."

        "Answer the menu whose title is aString. Case is ignored
         and aString can include $&, $~, or neither."
    | plainString |
    #addedByOSI.
    plainString := aString stripMnemonic.
    allMenus do: [:m |
        (m title stripMnemonic equalsIgnoreCase: plainString)
            ifTrue: [^m]].
    menus do: [:m |
        (m title stripMnemonic equalsIgnoreCase: plainString)
            ifTrue: [^m]].
    ^nil! !

!WBDisplayContext methods !  
cellBorder
    "Answer true if a cell border should be drawn."

    ^cellBorder ifNil: [self defaultCellBorder]! !

!WBDisplayContext methods !  
borderColor: aColor

    borderColor := aColor.! !

!WinDialogInfo class methods !
itemTemplateStyle: style extendedStyle: extendedStyle x: x y: y cx: cx cy: cy id: id className: className text: text extraData: extraData
        "Private - Calculate the size of a dialog item template
         and answer a new item template with attributes
         set from the arguments."
    | size dlgItemTemplate extraDataSizeOffset textOffset unicodeClass unicodeText |

	#addedByOSI.
	"Added for support of extraData (last argument of this method)."

    unicodeClass := className isNil
        ifTrue: [ ByteArray new: 2 ]
        ifFalse: [ className asExternalString asNullTerminatedUnicodeString ].
    unicodeText := text isNil
        ifTrue: [ ByteArray new: 2 ]
        ifFalse: [ text asExternalString asNullTerminatedUnicodeString ].

    size := 18.         "Base DLGITEMTEMPLATE size"
    textOffset := size := size + unicodeClass size.
    extraDataSizeOffset := size := size + unicodeText size.
    size := size + extraData size + 2.
    size := ( size - 1 truncateTo: 4 ) + 4.  "item templates must be DWORD aligned"

    dlgItemTemplate := self new: size.
    dlgItemTemplate uLongAtOffset:  0 put: style.
    dlgItemTemplate uLongAtOffset: 4 put: extendedStyle.
    dlgItemTemplate uShortAtOffset: 8 put: x truncated.
    dlgItemTemplate uShortAtOffset: 10 put: y truncated.
    dlgItemTemplate uShortAtOffset: 12 put: cx truncated.
    dlgItemTemplate uShortAtOffset: 14 put: cy truncated.
    dlgItemTemplate uShortAtOffset: 16 put: id.

    dlgItemTemplate bytesAtOffset: 18 put: unicodeClass.
    dlgItemTemplate bytesAtOffset: textOffset put: unicodeText.
    dlgItemTemplate uShortAtOffset: extraDataSizeOffset put: extraData size.
    dlgItemTemplate bytesAtOffset: extraDataSizeOffset + 2 put: extraData contents.

    ^dlgItemTemplate! !

!WBComboBox methods !  
notifyListVisible: aParameter
        "Private - the host signaled that the list was dropped down."
    self isSimpleList ifFalse: [
        self resizeWithDropDownList.
        self forkListHiddenWatcher ].
    super notifyListVisible: aParameter.! !

!Window class methods !   
wbRunBaseBind
	"Initialize the base runtime for Win32."

	#addedByOSI.
	OperatingSystemEvents
		at: 13  put: #wmGettext:with:;
		at: 1123 put: #wmUser99:with:.
	ColorConstants
		at: 'ClrChiseledgray' put: 14737632.
	IndexedColor defaultColors
		at: #paleGray put: (
			IndexedColor index: (
				ColorConstants at: 'ClrPalegray')).! !

!Number methods !
distanceDown: aNumber
        "Answer the distance between the receiver and aNumber
            where right and down are positive."
    #addedByOSI.
    ^(aNumber - self) * Rectangle topBottomUnit! !

!Rectangle class methods ! 
leftRightUnit
        "Answer the signed unit from left to right."
	#addedByOSI.
    ^1! !

!WBComboBox methods !
textAttribute
	"Private - answer the stored value of the text field."

	^super textAttribute ifNil: ['']! !

!SubPane methods !  
closeDynamically
        "Private - Close the subpane dynamically."
    #addedByOSI.
    self close.
    self destroy.
    owner := parent := handlers := properties := nil.! !

!ApplicationCoordinator methods ! 
menuNamed: menuName
    "Added by OSI to return the menu named <menuName>"
    #addedByOSI.
    ^self isWBWindow
        ifTrue: [self triggerEvent: #wbNeedsMenuNamed: with: menuName]
        ifFalse: [nil]! !

!Object class methods ! 
wbCreated
    "Answer whether this class is WindowBuilder generated."
    #addedByOSI.
    ^self wbBasicVersion notNil! !

!WBDisplayContext methods !   
cellInset: aRectangleOrPoint

    cellInset := aRectangleOrPoint.
    boundingBox := nil.! !

!Date methods !
monthNameAbbreviated
        "Answer a Symbol representing the
         month name of the receiver."
    ^self class nameOfMonthAbbreviated: self monthIndex! !

!StaticBox methods !
wbAddToBack
    "Private - Answer true if the receiver should be added to the back."

    #addedByOSI.
    ^true! !

!OrderedCollection methods !   
wbReleaseEventTable
	    "Private"
	    "Break all connections to event handlers."
	#addedByOSI.! !

!WBDisplayContext class methods !   
textJustificationConstants
    "Answer a dictionary mapping justification to platform specific constant."

    ^TextJustificationConstants ifNil: [
        TextJustificationConstants := self constructTextJustificationConstants]! !

!ViewManager class methods !
openWithMyParent: aViewManager
    "Added by OSI - Open a new instance of the receiver
     as a child of aViewManager's parent (a sibling)."
    #addedByOSI.
    ^self new openWithMyParent: aViewManager! !

!Window methods !   
redraw
    "Added by OSI. Redraw the entire window."
    #addedByOSI.
    self isHandleOk ifTrue: [ self invalidateRect: nil ].! !

!UserDLL methods !   
drawText: hDC text: t length: l rect: r format: f
	"The other drawText method is part of the PARTS runtime support
		so we need an independent method for non-parts applications."
    <api: DrawTextA ulong struct long struct ulong long>

    #addedByOSI.
    ^self invalidArgument! !

!WBDisplayContext methods !   
display3DBorder

    self pen
        blank: self cellBox;
        draw3DRect: self cellBox.! !

!WBDialogTopPane methods ! 
defaultStyle
	"Private - Answer the default frame style for the receiver."

	#addedByOSI.
	^super defaultStyle | DsModalframe! !

!ApplicationCoordinator methods ! 
views
    #addedByOSI.
    ^Array with: self mainView! !

!Font methods ! 
clearFontHandle
        "Private - Invalidate  the font handle.
        Called during startup."
    handle := nil.
    graphicsMedium := Display.

	#modifiedByOSI.
	self wbClearStringWidthCache.! !

!MessageBox class methods !   
messageNote: aString
    "Added by OSI  to avoid the 'Information' title"
    #addedByOSI.
    ^self new
        title: '';
        message: aString;
        iconInformation;
        ok;
        open! !

!WBDisplayContext methods ! 
splitCellRightInset: anInteger
    "Split the cell into two parts based on anInteger.
        Set the cellBox and answer the other."

    | box x |
    box := self cellBox.
    x := box right left: anInteger truncated.
    self cellBox: (box leftTop rightBottom: x @ box bottom).
    ^x @ box top rightBottom: box rightBottom! !

!WBDisplayContext methods !   
foreColor: aColor

    self pen foreColor = aColor ifFalse: [
        self pen foreColor: aColor].! !

!SubPane methods !
dragTargetFormats
        "Private - answer the formats of drag objects that the receiver will accept."
    #addedByOSI.
    ^super dragTargetFormats ifNil: [ self dragTargetFormatsDefault ]! !

!WBDisplayContext methods !   
font

    ^self pen font! !

!WBComboBox class methods !  
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    ^super constructNotifications
        at: CbnCloseup put: #notifyListHidden: ;
        yourself! !

!WBDisplayContext methods !
defaultBoundingBox

    ^self cellBox insetBy: self cellInset! !

!Menu methods ! 
insertItemDynamically: string selector: aSelector atIndex: index
	"Added by OSI"
	| mi |
	#addedByOSI.
	self insertItem: string
		selector: aSelector
		accelKey: nil
		accelBits: nil
		after: index.
	window notNil ifTrue: [
		(mi := self getMenuItem: string)
			id: (self menuItem id - 1) + items size.
		window
			insertItem: mi
			label: string].! !

!GroupBox methods !  
addClipsiblingsStyle
		"Ignore this"
	#addedByOSI.! !

!Object methods !  
isPARTSInstalled
		"Answer true if PARTS is installed in the image."
    #addedByOSI.
	^Smalltalk includesKey: #PARTSApplication! !

!UndefinedObject methods !  
displayHelp: ignore
    #addedByOSI.! !

!NotificationManager methods !
removeFirstCurrentEvent: anEventSelector for: aWindow
		"Private - Remove the first queued event for aWindow
			having the specified event selector."
	#addedByOSI.
	self
		removeFirstCurrentEventFor: self
		using: [ :eachEvent | eachEvent selector = anEventSelector ].! !

!ApplicationCoordinator methods !
canTriggerEvent: eventName
        "Answer <true> if the receiver can trigger an event
        named <eventName>."
    #addedByOSI.
    ^(super canTriggerEvent: eventName)
        or: [self class wbSpecialEvents includes: eventName asSymbol]! !

!ViewManager methods !   
close
        "Close all the views."

	| allClosed |
	#modifiedByOSI.
	"For PARTS support, close views only once."
	self isWBWindow ifTrue: [
		allClosed := true.
		views do: [:v |
			v isHandleOk ifTrue: [
				v close.
				v isHandleOk ifTrue: [
					allClosed := false]]].
		allClosed ifTrue: [self initializeAgain].
		^self].

    views do: [:v | v close]! !

!Window methods !
topParent
        "Answer the top most parent."
    #addedByOSI.
    ^parent topParent! !

!WBDisplayContext methods !   
clearPen
    "Private - Clear the cached window builder display context pen for the receiver.
		If the pen was *created* (ie it did not already exist as a result of window validation)
		inside a #doGraphics: block then the pen MUST be cleared upon exiting the block."

	pen := nil.! !

!ViewManager methods !   
openRelativeTo: aViewManager offset: aPoint
    "Added by OSI - Open the receiver relative to <aViewManager>."

	| newInstance |
	self wbPreOldVersionSupport.
    newInstance := self createViews.
    newInstance notNil ifTrue: [
        newInstance
            positionRelativeTo: aViewManager offset: aPoint;
            openViews.
    ] ifFalse: [
        #addedByOSI.
        MessageBox message:
            self class name,' does not have a #createViews method or its own #open method.'
    ].
    ^newInstance! !

!SubPane methods !
needsKeyUpInput
        "Private - Answer true if the receiver processes key-up events."
    #addedByOSI.
    ^false! !

!WBDisplayContext methods ! 
defaultBackColor

	^OperatingSystem isOS2
		ifTrue: [Color entryFieldBackground]
		ifFalse: [Color windowBackground]! !

!TopPane methods ! 
cancelPushButton
        "Private - Answer the subpane which is the cancel
        push button."
    #addedByOSI.
    ^self propertyAt: #cancelPushButton! !

!WBDisplayContext methods !   
scale

    ^scale ifNil: [self defaultScale]! !

!Object methods !
wbDisplayWith: aWBDisplayContext
	"Display a representation of the receiver using aWBDisplayContext."

	#addedByOSI.
	self printString wbDisplayWith: aWBDisplayContext.! !

!Color class methods ! 
chiseledGray
        "Answer the chiseledGray color."
    #addedByOSI.
    ^RGBColor chiseledGray! !

!ApplicationWindow methods !   
frameStyleFromPStyle
    "Added by OSI - Reimplemented by subclasses"
    #addedByOSI.
    ^nil! !

!ViewManager methods !   
activate

    self mainView minimized
        ifTrue: [self mainView showRestoredWindow]
        ifFalse: [self mainView bringToTop].! !

!ApplicationWindow methods !  
viewName: aName

    "Added by OSI"

    #addedByOSI.
    self paneName: aName! !

!NotificationManager methods !  
removeFirstCurrentEventFor: aWindow using: aBlock
		"Private - Remove the first queued event for aWindow
			for which aBlock evaluated with the event returns true."
	| found |
	#addedByOSI.
	found := false.
	self
		removeFirstEventsFor: aWindow
		in: CurrentEvents
		using: [ :eachEvent |
			found not and: [
				found := aBlock value: eachEvent ] ].
	^found! !

!WBComboBox methods !
resizeWithoutDropDownList
        "Private - Resize the receiver to exclude the drop down list."
    isListVisible := false.
    rectangle := self framingRectangleFor: self parent rectangle.
	self topParent isDialog ifTrue: [
		self framingBlock isFramingParameters ifFalse: [
			rectangle := rectangle scaleBy: WindowDialog dialogUnit y / WindowDialog unitMultiplier y]].
    rectangle := rectangle leftTop extentFromLeftTop:
        rectangle width @ (
            self heightWithoutDropDownList min: rectangle height ).
    rectangle extent: (rectangle extent max: 0@0).
    self resizeWindow.! !

!ViewManager methods !  
openViews
    "Added by OSI"
    #addedByOSI.
    ^self openWindow! !

!ComboBox methods !   
notifySelectedPrim: aParameter
	"Skip the 'self previousValue: self value.' message
		in notifySelected:.  This is used when a WBComboBox
		is set to drop down list style so that the #changed:
		event is correctly fired."

	#addedByOSI.
    super notifySelected: aParameter.! !

!NotificationManager methods !
removeLastCurrentEvent: anEventSelector for: aWindow
		"Private - Remove the last queued event for aWindow
			having the specified event selector."
	#addedByOSI.
	self
		removeLastCurrentEventFor: self
		using: [ :eachEvent | eachEvent selector = anEventSelector ].! !

!ViewManager class methods !
openWithParent: aViewManager
    "Added by OSI - Open a new instance of the receiver
     as a child of aViewManager."
    #addedByOSI.
    ^self new openWithParent: aViewManager! !

!WBDisplayContext methods !  
defaultJustification

    ^self class justification! !

!SubPane methods !
extraDialogItemData
    "Added by OSI - Answer the extra dialog item data as a
     WinStructure or nil if there is none."
    #addedByOSI.
    ^nil! !

!LayoutFrame methods ! 
valueForDialogTopPane: aRectangle
	"Correctly answer a rectangle for an OS/2 DialogTopPane
		such that it can be centered on the screen using the same
		ratio expression as windows."

	| answer duFrame |
	answer := self value: aRectangle.
	OperatingSystem isOS2 ifTrue: [
		duFrame := aRectangle scaleBy: (4 / SysFont width) @ (8 / SysFont height).
		answer := (
			duFrame leftTop
				rightAndDown: (aRectangle leftTop distanceRightAndDown: answer leftTop))
				extentFromLeftTop: answer extent.
		answer rounded].
	^answer! !

!WBDisplayContext methods !  
boundingBox
    "Answer the box in which the object should draw itself."

    ^boundingBox ifNil: [
        boundingBox := self defaultBoundingBox]! !

!OrderedCollection methods !
wbPropertyAt: key ifAbsent: aBlock
        "Private - Answer the value associated with key
	        in the properties dictionary; if absent, 
	        answer the result of evaluating aBlock."
	#addedByOSI.
    ^aBlock value! !

!Object methods !  
isWBFramingContext
    "Added by OSI - Answer true if the receiver is WB
     framing parameters or a framing context."
    #addedByOSI. "PARTS Support"
    ^false! !

!WBDisplayContext methods ! 
cellBox

    ^cellBox ifNil: [
        cellBox := self defaultCellBox]! !

!Object methods ! 
wbPreOldVersionSupport
        "Private - Support old versions of WB."
    #addedByOSI.! !

!Object methods ! 
dialogTemplate
    "Added by OSI"
    #addedByOSI.
    ^nil! !

!WBDisplayContext class methods !
cellInset: aRectangleOrPoint

    cellInset := aRectangleOrPoint.! !

!Bitmap methods !   
wbDisplayContextPenFor: aWBDisplayContext
    "Private - Answer the window builder display context pen for the receiver."

    #addedByOSI.
	^self pen
		foreColor: aWBDisplayContext defaultForeColor;
		backColor: aWBDisplayContext defaultBackColor;
		yourself! !

!Menu methods !  
appendItem: aLabelString
    selector: aSelector
    acceleratorString: aString
        "Append an item with label aLabelString and
         selector aSelector to the receiver menu.  Parse the
         accelerator info from aString.  aString has the following
         syntax:
            One or more of 'Ctrl', 'Alt', or 'Shift'.
            A plus sign (+).
            A single character (indicating Ctrl+S for example)
                or an integer (indicating Ctrl+Del for example).
            Examples:
                'Ctrl+S' means Control key and the S key.
                'AltShift+C' means Alt and Shift keys and the C key.
                'Ctrl+27' means Control and the Del key (VkDelete = 27)."
    | s bits bitsString key keyString |
    aString isEmpty ifTrue: [
        ^self appendItem: aLabelString selector: aSelector
            accelKey: nil accelBits: nil ].
    s := aString asStream.
    bitsString := s upTo: $+.
    keyString := s upTo: $+.
    keyString first isDigit
        ifTrue: [
            key := 0.
            1 to: keyString size do: [:i |
                key := key * 10 + ( keyString at: i ) digitValue ].

            #modifiedByOSI.
            "Convert from OS/2 Codes to Windows codes."
            key := PMToWinKeyMap at: key.

            bits := AfVirtualkey ]
        ifFalse: [
            key := keyString first.
            bits := AfChar ].
    ( bitsString includes: $C ) ifTrue: [ bits := bits | AfControl ].
    ( bitsString includes: $A ) ifTrue: [ bits := bits | AfAlt ].
    ( bitsString includes: $S ) ifTrue: [ bits := bits | AfShift ].
    ^self appendItem: aLabelString selector: aSelector
           accelKey: key accelBits: bits! !

!WBDisplayContext methods !
pen
    "Private - Answer the window builder display context pen for the receiver.
		DO NOT create one if it does not already exist.  The pen must already
		be created during window validation *OR* the caller must use the display context
		inside a #doGraphics: block then clear the pen of the display context."

    ^pen ifNil: [pen := self defaultPen]! !

!WinDialogInfo class methods !  
buildItemsFor: aDialogTopPane
        "Private - Build the control items within the dialog box.  Answer
         an array of item templates."
    | answer rect text template style extendedStyle extraData |
    answer := OrderedCollection new.
    aDialogTopPane childrenInBuildOrder do: [ :subpane |
        subpane isSubPane ifTrue: [
            ( rect := subpane framingBlock ) isRectangle
                ifFalse: [

                    #modifiedByOSI.
                    "Support for FramingParameters."
                    rect := rect isFramingParameters
                        ifTrue: [ rect valueDU: ( 0@0 extent: aDialogTopPane rectangleAttribute extent ) ]
                        ifFalse: [ rect value: ( 0@0 extent: aDialogTopPane rectangleAttribute extent ) ] ].

            ( text := subpane initialText ) isString ifFalse: [ text := nil ].
            ( style := subpane style ) isNil
                ifTrue: [ style := subpane getStyle ].
            ( extendedStyle := subpane extendedStyle ) isNil
                ifTrue: [ subpane extendedStyle: ( extendedStyle := subpane defaultExtendedStyle ) ].

            #modifiedByOSI.
            "Added support for extra data."
            (extraData := subpane extraDialogItemData) notNil
                ifTrue: [
                    template := WinDialogInfo
                        itemTemplateStyle: style
                        extendedStyle: extendedStyle
                        x: rect left
                        y: rect top
                        cx: rect extent x
                        cy: rect extent y
                        id: subpane id
                        className: subpane windowClass
                        text: text
                        extraData: extraData]
                ifFalse: [
                    template := WinDialogInfo
                        itemTemplateStyle: style
                        extendedStyle: extendedStyle
                        x: rect left
                        y: rect top
                        cx: rect extent x
                        cy: rect extent y
                        id: subpane id
                        className: subpane windowClass
                        text: text].

            answer add: template.
            subpane style: style.
            subpane initSize: rect ] ].
    ^answer! !

!Date class methods !
dateArray: aString
        "Added by OSI - Answer an array containg the
         the elements of Date specified by aString.  aString
         must represent a date in one of three formats:
         'Dec 31, 1989' or '31 Dec 1989' or '12/31/89'
         but the delimiters between the month, day and
         year can be any sequence of non-alphanumeric
         characters. The array is ordered #( day Month Year )"
    | aStream field1 field2 field3 month year |
    #addedByOSI.
    aStream := aString asStream.
    field1 := aStream nextWord.
    (DayNames includesKey: field1 asSymbol)
        ifTrue: [field1 := aStream nextWord].
    field1 isNil ifTrue: [ ^#(0 0 0)].
    field2 := aStream nextWord.
    (field2 equalsIgnoreCase:  'of')
        ifTrue: [field2 := aStream nextWord].
    field2 isNil ifTrue: [ ^#(0 0 0)].
    field3 := aStream nextWord.
    field3 isNil ifTrue: [ ^#(0 0 0)].
    year := field3 asInteger.
    year < 100 ifTrue: [year := year + (year < 60 ifTrue: [2000] ifFalse: [1900])].

    field1 first isLetter                            " 'Jan 2, 1990' format"
        ifTrue: [
            month := MonthNames at: (self monthStrings at: field1 ifAbsent: [ 0 ]) 
ifAbsent: [ 0 ].
			^Array
            	with: field2 asInteger
            	with: month
            	with: year].

    field2 first isLetter                             " '2 Jan, 1990' format"
        ifTrue: [
            month := MonthNames at: (self monthStrings at: field2 ifAbsent: [ 0 ]) 
ifAbsent: [ 0 ].
        	^Array
            	with: field1 asInteger
            	with: month
            	with: year].

        "Must be '02-01-90' or 02-01-1990' style"
    (NationalLanguage dateFormat) = NationalLanguageSupport dateFormatMDY
        ifTrue: [
            ^Array
                with: field2 asInteger
                with: field1 asInteger
                with: year]
        ifFalse: [
            (NationalLanguage dateFormat) = NationalLanguageSupport 
dateFormatDMY
                ifTrue: [
                    ^Array
                        with: field1 asInteger
                        with: field2 asInteger
                        with: year]
                ifFalse: [                                          "dateFormatYMD"
                    year := field1 asInteger.
                    year < 100 ifTrue: [year := year + (year < 60 ifTrue: [2000] ifFalse: [1900])].
                    ^Array
                        with: field3 asInteger
                        with: field2 asInteger
                        with: year]].! !

!ApplicationCoordinator class methods !   
preInitWindow: aView forModel: aCoordinator
        "Preform any window initialization."
    #addedByOSI.! !

!WBComboBox class methods ! 
forkListHiddenWatcherPriority
		"Answer the process priority for the watcher."
	^Processor backgroundPriority! !

!OrderedCollection methods !
wbPropertyAt: key put: aValue
        "Private - Set the value associated with key
	        in the properties dictionary."
	#addedByOSI.
   ^aValue! !

!StaticBox methods !
basicStyle
        "Private - Answer an Integer with appropriate
         bits for basic control style."
        "Added by OSI: added the WsClipsiblings style
        to support overlapping panes."
    #addedByOSI.
    ^super basicStyle | WsClipsiblings! !

!WBDisplayContext methods ! 
displayBitmap: aBitmap

	self displayDuring: [:aPen |
		aPen
			copyBitmap: aBitmap
			from: aBitmap boundingBox
			to: (self boundingBoxForBitmap: aBitmap)].! !

!Pen methods ! 
draw3DButton: aString rect: aRect font: aFont foreColor: fore backColor: back
    "Added by OSI - draw a 3D button"
    | bottom right top left region |
    #addedByOSI.
    bottom := aRect bottom up: 1.
    right := aRect right left: 1.
    top := aRect top down: 1.
    left := aRect left right: 1.
    self
        setBackgroundModeOpaque;
        fill: (aRect insetBy: 3) color: back;
        draw3DButtonRect: aRect;
        foreColor: Color black;
        lineFrom: aRect left @ top to: aRect left @ bottom;
        lineFrom: right @ top to: right @ bottom;
        lineFrom: left @ aRect top to: right @  aRect top;
        lineFrom: left @ bottom to: right @ bottom.
    region := self setClipRect: (aRect insetBy: 4).
    self
        setBackgroundModeTransparent;
        font: (aFont ifNil: [ SysFont "Font fromFont: ButtonFont" ]);
        setTextAlign: WBDisplayContext defaultTextAlign;
        foreColor: fore;
        centerWinText: aString at: aRect center;
        setBackgroundModeOpaque;
        destroyRegion: region.! !

!ViewManager methods !  
maxWindowSize
    "Added by OSI"
    #addedByOSI.
    ^nil! !

!GroupBox methods !   
basicStyle
        "Private - Answer an Integer with appropriate
         bits for basic control style."

    #modifiedByOSI.
    "Added the WsClipsiblings style to support overlapping panes."
    ^WsChild | WsVisible | WsGroup | WsClipsiblings! !

!Object methods !
maxWindowSize
    "Added by OSI"
    #addedByOSI. "PARTS Support"
    ^nil! !

!SubPane methods !
definedIn: aSelector
        "Set the selector of the creation method."
	#addedByOSI.
    self propertyAt: #definedIn put: aSelector! !

!Pen methods !  
drawFocusRect: aRect

    "Added by OSI"
    #addedByOSI.
    self allHandles do: [: h |
        UserLibrary
            drawFocusRect: h
            rectangle: aRect asParameter
    ].! !

!WBDisplayContext methods !   
defaultCellBox
    "Answer the default cell box."

    | drawStruct box |
    self window isBitmap
        ifTrue: [
            box := self windowBox]
        ifFalse: [
            drawStruct := self window ownerDrawStruct.
            box := drawStruct notNil
                ifTrue: [drawStruct boundingBox]
                ifFalse: [self windowBox]].
    ^box leftTop extentFromLeftTop: box width + 1 @ box height! !

!SubPane methods !   
needsKeyDownInput
        "Private - Answer true if the receiver processes key-down events."
    #addedByOSI.
    ^false! !

!WBDisplayContext methods ! 
windowBox
    "Answer the window's rectangle."

    ^0 @ 0 extent: self window extent! !

!TopPane methods ! 
wbOwner
		"Answer the window builder owner."
	#addedByOSI.
	^self propertyAt: #wbOwner! !

!WBComboBox methods ! 
removeDynamicListSizeStyle
		"Do not dynamically size the receiver's frame based on the
			number of elements in the receiver's list."
	isListSizeDynamic := false.! !

!WBDisplayContext methods !  
defaultCellBorder
    "Answer true if a cell border should be drawn."

    ^#displayVerticalBorder! !

!WBComboEntryField methods !  
basicKeyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received."
        "Provide support for Escape key"
        "Provide Enter key support for all WB windows including Dialogs."
    | button |
    aKeyboardInputEvent virtualKey == EscapeKey ifTrue: [
        (button := self mainWindow cancelPushButton ) notNil ifTrue: [
            button disabled not ifTrue: [
                button click ]]].
    aKeyboardInputEvent character == Cr ifTrue: [
        (button := self mainWindow defaultPushButton) notNil ifTrue: [
            button disabled not ifTrue: [
                button click ]]].! !

!SubPane methods ! 
contents
    "Added by OSI to speed dialog opening"
    #addedByOSI.
    ^nil! !

!Point methods !   
distanceRightAndUp: aPoint
        "Answer the distance between the receiver and aPoint
            where right and up are positive."
    #addedByOSI.
    ^(x distanceRight: aPoint x) @ (y distanceUp: aPoint y)! !

!NotificationManager methods !   
removeFirstEventsFor: aWindow in: aQueue using: aBlock
		"Private - Remove queued events for aWindow.
			Use aBlock to determine which events to remove."
	| eachEventIndex eachEvent |
	#addedByOSI.
	[	eachEventIndex := 1.
		[ eachEventIndex <= aQueue size ] whileTrue: [
			((eachEvent := aQueue at: eachEventIndex) receiver == aWindow | aWindow isNil
				and: [ aBlock value: eachEvent ])
					ifTrue: [ aQueue removeIndex: eachEventIndex ]
					ifFalse: [ eachEventIndex := eachEventIndex + 1 ] ].
	] evaluateWithoutInterrupts! !

!WBComboBox methods !   
notifyListHidden: aParameter
        "Private - the host signaled that the list was closed up."
    isListVisible := false.! !

!DialogTopPane methods !  
buildWindow: aParentWindow
        "Private - Create the dialog window for the receiver."
    | result |
    style isNil ifTrue: [ style := self getStyle ].
    framingBlock isNil
        ifTrue: [
            rectangle := self initSize.
            framingBlock := rectangle ]
        ifFalse: [

            #modifiedByOSI.

            "Correctly handle the case when parent is nil,
				and WB aligns dialogs to screen not parent..."
            rectangle := parent isNil | self owner isWBWindow
                ifTrue: [ Display boundingBox ]
                ifFalse: [ parent rectangle ].

            "Return dialog units from framing parameters."
            rectangle :=
                framingBlock isFramingParameters
                    ifTrue: [ framingBlock valueToDU: rectangle ]
                    ifFalse: [ framingBlock value: rectangle ] ].

    NotificationManager newWindow: self.
    result := UserLibrary
        createDialogIndirect: OperatingSystem hInstanceExe
        dialogTemplate: ( WinDialogInfo dialogTemplateFor: self ) asParameter
        parent: parent asParameter
        dialogFunction: DialogProcInstance asParameter.
    NotificationManager newWindow: nil.
    result = 0 ifTrue: [ ^self osError ].
    handle := WindowHandle fromInteger: result.
    self
        receiveMessages;
        buildDialogItems.

    #modifiedByOSI.
    owner initWindow.

    PoppedModelessWindows add: handle.
    self isHidden ifFalse: [ self showWindow ].
    self sendDeferredEvent: #subclassRecursively! !

!ViewManager methods !  
isWBWindow

    "Added by OSI"
    #addedByOSI.
    ^self class wbCreated! !

!ViewManager methods !
openWithOwnerParent: aViewManager
	"Added by OSI - Open the receiver with aViewManager as Parent
		and owner of all the subpanes. This method can only be used in
		conjunction with the 'Power Views' Add-In."

	| newInstance |
	#addedByOSI.
	newInstance := self createViewsFor: self owner: aViewManager.
	newInstance notNil
		ifTrue: [
			newInstance openViewsWithOwner: aViewManager]
		ifFalse: [
			MessageBox message:
				self class name,' does not have a #createViewsFor:owner: method.'].
	^newInstance! !

!Button methods !   
validate
        "Private - The host window for the receiver was
         just created or recreated."
    | mainWindow |
    ( self isDefaultPushButton and: [ ( mainWindow := self mainWindow ) ~~ self ] )
        ifTrue: [ mainWindow defaultPushButton: self ].

    #modifiedByOSI.
    ( self isCancelPushButton and: [ ( mainWindow := self mainWindow ) ~~ self ] )
        ifTrue: [ self mainWindow cancelPushButton: self ].

    super validate! !

!ViewManager class methods !
openWithMDIParent: aViewManager
    "Added by OSI - Open a new instance of the receiver
     as an MDI child of aViewManager."
    #addedByOSI.
    ^self new openWithMDIParent: aViewManager! !

!ApplicationWindow methods !  
topParent
        "Answer the top most parent."
    #addedByOSI.
    ^self! !

!Object methods ! 
initWindow
    "Added by OSI"
    #addedByOSI.! !

!WBDisplayContext methods !
scale: aBoolean

    scale := aBoolean.! !

!Window methods ! 
removeTransparentStyle
    "Remove a style that allows mouse clicks to pass through
        the receiver to panes below it."

    #addedByOSI.
    self propertyAt: #transparent put: nil.! !

!ViewManager methods !  
minWindowSize
    "Added by OSI"
    #addedByOSI.
    ^nil! !

!NotificationManager methods !
removeLastEventsFor: aWindow in: aQueue using: aBlock
		"Private - Remove queued events for aWindow.
			Use aBlock to determine which events to remove."
	| eachEvent |
	#addedByOSI.
	[	aQueue size to: 1 by: -1 do: [ :eachEventIndex |
			((eachEvent := aQueue at: eachEventIndex) receiver == aWindow | aWindow isNil
				and: [ aBlock value: eachEvent ])
					ifTrue: [ aQueue removeIndex: eachEventIndex ] ].
	] evaluateWithoutInterrupts! !

!Window methods ! 
addTransparentStyle
    "Add a style that allows mouse clicks to pass through
        the receiver to panes below it."

    #addedByOSI.
    self propertyAt: #transparent put: true.! !

!ApplicationCoordinator class methods !  
open: aCoordinator
    "Build and open a window for <aCoordinator>."

    | view |
    view := self constructViewFor: aCoordinator.

    #modifiedByOSI.
	"Support for preInitWindow."
    aCoordinator isWBWindow ifTrue: [
        self preInitWindow: view forModel: aCoordinator.
        aCoordinator preInitWindow ].

    view open! !

!WBDisplayContext methods !  
borderColor

    ^borderColor ifNil: [
        borderColor := self defaultBorderColor]! !

!WBDisplayContext methods !   
boundingBoxClipped
    "Answer the box in which the object should draw itself."

    ^self boundingBox intersect: self windowBox! !

!SubPane methods !  
dragTargetOperations
        "Private - answer the operations that the receiver can accept."
    #addedByOSI.
    ^super dragTargetOperations ifNil: [ self dragTargetOperationsDefault ]! !

!Pen methods ! 
drawRectangle: aRectangle

    "Added by OSI since rectangle: fills."

    #addedByOSI.
    self place: aRectangle origin.
    self box: aRectangle corner.! !

!SubPane methods !
getPopupMenu

    "Added by OSI"
    #addedByOSI.
    ^popup! !

!Point methods !   
distanceLeftAndUp: aPoint
        "Answer the distance between the receiver and aPoint
            where left and up are positive."
    #addedByOSI.
    ^(x distanceLeft: aPoint x) @ (y distanceUp: aPoint y)! !

!WBComboBox methods !   
heightWithoutDropDownList
        "Answer the height of the receiver when the drop down list is hidden."
    ^(self font ifNil: [ SysFont ]) height + 6! !

!Pen methods !
drawRect3DLight: aRect
      "Added by OSI."
    #addedByOSI.
    self
        foreColor: Color buttonHighlight;
        lineFrom: (aRect left @ (aRect top down: 1)) to: ((aRect right left: 1) @ (aRect top down: 1));
        lineFrom: ((aRect left right: 1) @ (aRect top down: 1)) to: ((aRect left right: 1)@ (aRect bottom up: 1));
        foreColor: Color buttonShadow;
        lineFrom: (aRect left right: 1) @ (aRect bottom up: 2) to: (aRect rightBottom leftAndUp: 1@2);
        lineFrom: (aRect right left: 2) @ (aRect top down: 1) to: (aRect rightBottom leftAndUp: 2@1).! !

!ViewManager methods ! 
openViewsOnce
        "Open the window once.
            For PARTS support."
    #addedByOSI.
    self mainView isHandleOk
        ifTrue: [ self mainView bringToTop ]
        ifFalse: [ self openViews ].! !

!NotificationManager methods !   
activeWindow

    "Added by OSI to support keyboard translation for MDI windows"
        "Answer the active toppane."

    | win newWin |
    #addedByOSI.
    (win := self activeMainWindow) isMDIFrame ifTrue: [
        (newWin := win mdiGetActive) notNil ifTrue: [
            ^newWin
        ].
    ].

    ^win! !

!TopPane methods !
setOwner: aWindow
      "Set the receiver's owner and parent."
    #addedByOSI.
    self propertyAt: #wbOwner put: aWindow.! !

!Font methods !  
wbStringWidth: aString
        "Answer the width of aString using the receiver font."
    | cache answer |
    #addedByOSI.
    aString isNil ifTrue: [^0].
    aString isString
        ifTrue: [
            cache := self wbStringWidthCache.
            answer := aString stripMnemonic inject: 0 into: [:w :ch | w + (cache at: ch asciiValue + 1)]]
        ifFalse: [
            answer := self
                stringWidth: aString stripMnemonic
                graphicsMedium: Display].
    #osiHack.
    "This seems to help."
    self italic ifTrue: [answer := answer + 6].
    ^answer! !

!WBComboBox methods ! 
selectedItem
        "Answer the item selected in the receiver."
    ( self getSelection ) isNil
        ifTrue: [ ^nil ]
        ifFalse: [ ^list at: value ]! !

!ViewManager methods !   
eventTable
	"Private - answer a Dictionary mapping event names to actions for the receiver."

	#addedByOSI.
	^(self propertyAt: #wbEventTable) ifNil: [self eventTableCreate]! !

!ApplicationCoordinator class methods !   
constructViewFor: aCoordinator
    "Create a new view of the application <aCoordinator> and define its structure."

    | view |
    view := self createViewFor: aCoordinator.

    #modifiedByOSI.
    "Modified by OSI to add special event handlers for WB windows"
    aCoordinator isWBWindow
        ifTrue: [
            view owner: aCoordinator.
            aCoordinator
                when: #wbNeedsView send: #yourself to: view;
                when: #wbNeedsPaneNamed: send: #paneNamed: to: view;
                when: #wbNeedsMenuNamed: send: #wbMenuTitled: to: view menuWindow].

    self buildView: view forModel: aCoordinator.
    ^view! !

!Window methods !
wmUser99: wparam
with: lparam
    "Added by OSI"

    #addedByOSI.
    ^nil! !

!SubPane methods ! 
keyDownInput: aKeyboardInputEvent
        "Private - A key down event was received."
    #addedByOSI.! !

!Window methods !   
wbPaneNamed: aPaneName

    "Added by OSI"

    | pane |

    #addedByOSI.
    self paneName = aPaneName ifTrue: [ ^self ].

    children notNil ifTrue: [
        children do: [ :c |
            (pane := c wbPaneNamed: aPaneName) notNil ifTrue: [
                ^pane ] ] ].

    ^nil! !

!WBComboBox methods !   
selectItem: anObject
        "Private - Select the item anObject. anObject can
        be an index or a string."
    anObject isInteger
        ifTrue: [ self selectIndex: anObject ]
        ifFalse: [ self selectIndex: ( self indexOf: anObject ) ]! !

!SubPane methods !
verticalScrollPos
        "Private - Answer the vertical scrollbar's position"
    | pos |
	#addedByOSI.
	"Copied from GraphPane."
    ( pos := UserLibrary getScrollPos: self handle asParameter bar: SbVert ) = 0
        ifTrue: [ self osWarning ].
    ^pos! !

!Pen methods !  
drawBorder3DLight: aRect
      "Added by OSI."
    #addedByOSI.
    self
        foreColor: Color buttonShadow;
        lineFrom: aRect leftTop to: aRect rightTop;
        lineFrom: aRect leftTop to: aRect leftBottom;
        foreColor: Color black;
        lineFrom: (aRect leftBottom up: 1) to: (aRect rightBottom leftAndUp: 1);
        lineFrom: (aRect rightTop left: 1) to: (aRect rightBottom left: 1).! !

!WBComboBox methods !   
notifySelected: aParameter
	"When the receiver is emulating a drop down list,
		use #notifySelectedPrim: so that the #changed:
		event is correctly fired."

	self isDropDownList
		ifTrue: [self notifySelectedPrim: aParameter]
		ifFalse: [super notifySelected: aParameter].! !

!Pen methods !  
draw3DButton: aString rect: aRect font: aFont
    "Added by OSI - draw a 3D button"
    #addedByOSI.
    self draw3DButton: aString rect: aRect font: aFont
        foreColor: Color black
        backColor: Color buttonFace! !

!WBDisplayContext methods ! 
cellBox: aRectangle

    cellBox := aRectangle.
    boundingBox := nil.! !

!NotificationManager methods !   
removeLastCurrentEventFor: aWindow using: aBlock
		"Private - Remove the last queued event for aWindow
			for which aBlock evaluated with the event returns true."
	| found |
	#addedByOSI.
	found := false.
	self
		removeLastEventsFor: aWindow
		in: CurrentEvents
		using: [ :eachEvent |
			found not and: [
				found := aBlock value: eachEvent ] ].
	^found! !

!WBComboBox class methods ! 
hasDynamicListSizeStyle
		"Answer the default value for the dynamic list size style."
	^IsListSizeDynamicDefault = true! !

!ViewManager methods !
eventTableForEdit
	"Private - answer the table of event handlers for the receiver.
		Allocate if necessary so that updates can be stored."

	| answer |
	#addedByOSI.
	^(self propertyAt: #wbEventTable) ifNil: [
		answer := self eventTableCreate.
		self propertyAt: #wbEventTable put: answer.
		answer]! !

!SubPane methods !
dragTargetFormatsDefault
        "Private - answer the formats of drag objects that the receiver will accept."
    #addedByOSI.
    ^nil! !

!WBComboBox methods !   
resizeWithDropDownList
		"Private - Resize the receiver to include the drop down list."
	isListVisible := true.
	rectangle := self framingRectangleFor: self parent rectangle.
	self topParent isDialog ifTrue: [
		self framingBlock isFramingParameters ifFalse: [
			rectangle := rectangle scaleBy: WindowDialog dialogUnit y / WindowDialog unitMultiplier y]].
	self hasDynamicListSizeStyle ifTrue: [
		rectangle := rectangle leftTop rightBottom: (
			rectangle right @ self dynamicListBottom)].
	rectangle extent: (rectangle extent max: 0@0).
	self resizeWindow.
! !

!Pen methods ! 
draw3DRectReversed: aRect
	    "Added by OSI"
	#addedByOSI.
	self
		draw3DRect: aRect
		leftTopColor: Color buttonShadow
		rightBottomColor: Color buttonHighlight.! !

!SubPane methods !
removeDynamically
    "Added by OSI - Remove a subpane from a window dynamically"
    #addedByOSI.
    self superWindow removeSubpaneDynamically: self.! !

!Pen methods !   
draw3DRect: aRect
	    "Added by OSI"
	#addedByOSI.
	self
		draw3DRect: aRect
		leftTopColor: Color buttonHighlight
		rightBottomColor: Color buttonShadow.! !

!WBDisplayContext methods !   
defaultWrap

    ^false! !

!ViewManager methods !
createViews
    "Added by OSI - Default #createViews method."
    #addedByOSI.
    ^self createViewsFor: self owner: self! !

!Bitmap methods !  
wbDisplayWith: aWBDisplayContext
    "Display a representation of the receiver using aWBDisplayContext."

    #addedByOSI.
    aWBDisplayContext displayBitmap: self.! !

!ViewManager methods !
propertyAt: aPropertyName ifAbsent: aBlock
	"Answer the value associated with key in the properties dictionary;
		if absent, answer the result of evaluating aBlock."

	#addedByOSI.
	^self propertyTable at: aPropertyName ifAbsent: aBlock! !

!Number methods ! 
distanceUp: aNumber
        "Answer the distance between the receiver and aNumber
            where right and down are positive."
    #addedByOSI.
    ^aNumber distanceDown: self! !
   
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!

Smalltalk at: #PMToWinKeyMap put: (
    Compiler evaluate:
'	"Win32 <--> OS/2 virtual key mapping"

    IdentityDictionary new
        at: 5 put: 8;    "VkBack"
        at: 6 put: 9;    "VkTab"
        at: 9 put: 16;    "VkShift"
        at: 13 put: 19;    "VkPause"
        at: 15 put: 27;    "VkEscape"
        at: 16 put: 32;    "VkSpace"
        at: 17 put: 33;    "VkPrior"
        at: 18 put: 34;    "VkNext"
        at: 19 put: 35;    "VkEnd"
        at: 20 put: 36;    "VkHome"
        at: 21 put: 37;    "VkLeft"
        at: 22 put: 38;    "VkUp"
        at: 23 put: 39;    "VkRight"
        at: 24 put: 40;    "VkDown"
        at: 26 put: 45;    "VkInsert"
        at: 27 put: 46;    "VkDelete"
        at: 29 put: 144;    "VkNumlock"
        at: 32 put: 112;    "VkF1"
        at: 33 put: 113;    "VkF2"
        at: 34 put: 114;    "VkF3"
        at: 35 put: 115;    "VkF4"
        at: 36 put: 116;    "VkF5"
        at: 37 put: 117;    "VkF6"
        at: 38 put: 118;    "VkF7"
        at: 39 put: 119;    "VkF8"
        at: 40 put: 120;    "VkF9"
        at: 41 put: 121;    "VkF10"
        at: 42 put: 122;    "VkF11"
        at: 43 put: 123;    "VkF12"
        at: 44 put: 124;    "VkF13"
        at: 45 put: 125;    "VkF14"
        at: 46 put: 126;    "VkF15"
        at: 47 put: 127;    "VkF16"
        yourself.' )!
   
Smalltalk at: #WinToPMKeyMap put: (
    Compiler evaluate:
'	"Win32 <--> OS/2 virtual key mapping"

	| answer |
	answer := IdentityDictionary new.
	PMToWinKeyMap
		associationsDo: [ :each |
			answer
				at: each value
				put: each key ].
	answer' )!

Smalltalk at: #RGBColorChiseledGray put: (
    Compiler evaluate:
'RGBColor fromInteger: 16rE0E0E0.' )!
 
Smalltalk at: #WBMonthStrings put: (
    Compiler evaluate:
'Dictionary new
	at: ''jan'' put: #Jan;
	at: ''january'' put: #Jan;
	at: ''feb'' put: #Feb;
	at: ''february'' put: #Feb;
	at: ''mar'' put: #Mar;
	at: ''march'' put: #Mar;
	at: ''apr'' put: #Apr;
	at: ''april'' put: #Apr;
	at: ''may'' put: #May;
	at: ''jun'' put: #Jun;
	at: ''june'' put: #Jun;
	at: ''jul'' put: #Jul;
	at: ''july'' put: #Jul;
	at: ''aug'' put: #Aug;
	at: ''august'' put: #Aug;
	at: ''sep'' put: #Sep;
	at: ''september'' put: #Sep;
	at: ''oct'' put: #Oct;
	at: ''october'' put: #Oct;
	at: ''nov'' put: #Nov;
	at: ''november'' put: #Nov;
	at: ''dec'' put: #Dec;
	at: ''december'' put: #Dec;
	yourself' )!
 
Smalltalk at: #WBFontClass put: (
    Compiler evaluate:
'"Perform initialization only if the receiver is nil."

	WBFontClass isNil
		ifTrue: [Font]
		ifFalse: [WBFontClass]' )!
   
Smalltalk at: #WBBitmapClass put: (
    Compiler evaluate:
'"Perform initialization only if the receiver is nil."

    WBBitmapClass isNil
        ifTrue: [Bitmap]
        ifFalse: [WBBitmapClass].' )!
   
Window wbRunBaseBind!