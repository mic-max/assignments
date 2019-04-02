3.1.0.106
   
new
	"Answer an initialized new instance."

    ^ super new initialize!
popOut
    "Draw the field as popped out."

    self type: #popOut!
name
        "Answer the status field name."

    ^name!   
name: aSymbol
	"Set the status field name to <aSymbol>."

    name := aSymbol! 
parent: aStatusWindow
    "Private - Set parent to the containing status window."

    parent := aStatusWindow!
update
	"Private - The receiver had changed. Ask
	the parent to update."

	parent notNil ifTrue: [
		parent updateStatusField: self ]!   
ownerDraw
    "Make the field drawn by the owner."

    self type: #ownerDraw! 
width
	"Answer the width of the field in pixels."

    ^width! 
width: pixels
    "Set the field width to <pixels> which can be -1 indicating it goes
    all the way to right edge."

    width := pixels.
	( parent notNil and: [ parent isValid ] )
		ifTrue: [ parent setInnerParts ]!  
caveIn
    "Draw the field as caved in."

    self type: #caveIn!  
initialize
	"Private - Initialization"
    type := 0   "with caved in border"!  
noboarder
    "Draw the field as no boarder."

    self type: #noboarder!  
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to anExpressionModel to set the attributes
        of a new instance of the class of the receiver."
    anExpressionModel
        addSelectorIfNotNil: #contents: with: self contents;
        addSelectorIfNotNil: #name: with: self name;
        addSelectorIfNotNil: #type: with: self type;
        addSelectorIfNotNil: #width: with: self width
!
contents
	"Answer the contents which can be a string or bitmap."

	^ contents! 
type: typeSymbol
    "Private - Set type to <typeSymbol> which can be #caveIn, #popOut, #noborder,
    or #ownerDraw (this type currently does not work
    due to wrong ctlType from system)"

    type := typeSymbol.
    self update
!  
contents: anObject
	"Set the contents to <anObject> which can be a string or bitmap."

	contents := anObject.
	"parent simpleMode: false."  "this may have been turned to true by help"
	self update!
type
    "Private - Answer the type which can be #caveIn, #popOut, #noborder,
    or #ownerDraw (this type currently does not work
    due to wrong ctlType from system)"

    ^ type
! 
constructEventsTriggered
	"Private - answer the set of events that instances of the
        receiver can trigger."

	^super
		constructEventsTriggered add: #drawItem:;
		yourself! 
windowClass
	"Private - Answer the system control class."

    ^ Statusclassname!  
affectsFreeClientArea
    "Private - Answer whether the receiver reduces the amount of
    free client area in its parent for the receiver's siblings."

	^ true! 
fieldGet: aSymbol arguments: arguments
        " Private - "
  | field |

    ^(field := self fieldNamed: aSymbol asString) notNil
        ifTrue: [ field contents ]
        ifFalse: [self reportException: 'field not defined' ]
       !   
fieldSet: aSymbol arguments: arguments
        " Private - "
    | field aValue |
    aValue := arguments at: 1.
    field := self fieldNamed: (aSymbol copyFrom: 4 to: aSymbol size - 1).
    field notNil
       ifTrue: [
          field contents: aValue.
          ^aValue]
       ifFalse: [self reportException: 'field is not defined']

    !
height
    "Answer the minimum height of the status bar."

    ^ minimumHeight!
contents: statusFields
	"Replace the contents of the receiver
	with <statusFields>."

    innerParts := statusFields.
    statusFields do: [ :aField | aField parent: self ].
	self isValid ifTrue: [
		self setInnerParts ].
	self simpleMode: false!
freeClientArea: box
    "Private - Set the client area left over."

    ( self isValid not or: [ self isHidden ] ) ifTrue: [ ^box ].
	self isAtTop
		ifTrue: [ box top: ( box top down: self frameRectangle height ) ]
		ifFalse: [ box bottom: ( box bottom up: self frameRectangle height ) ].
    ^box! 
height: pixels
    "Set the minimum height of the receiver to <pixels>."

    minimumHeight := pixels.
    self isValid
        ifTrue: [ self setMinimumHeightPrivate: pixels ]!
addField: aStatusField
	"Add <aStatusField> to the end."

	aStatusField parent: self.
	"innerParts isNil
		ifTrue: [innerParts := OrderedCollection new]."
	innerParts add: aStatusField.
	self isValid
		ifTrue: [self setInnerParts].
	self updateStatusField: aStatusField!   
simpleMode: aBoolean
	"Switch the receiver to simple mode if <aBoolean> is true.
	The simple mode shows only one status field whose
	text is maintained separately from the non-simple mode
	fields."

	self propertyAt: #simpleMode put: aBoolean.
	self isHandleOk ifFalse: [ ^self ].
	UserLibrary
        sendMessage: self handle
        msg: SbSimple
        wparam: aBoolean asParameter
        lparam: 0!  
simpleModeText
	"Private - Answer simple mode text."

	^ self propertyAt: #simpleModeText! 
initialize
        "Private - Initialize the receiver.  Set the default
        framing block to all of the outer frame."
    super initialize.
	innerParts := OrderedCollection new! 
buildWindow: parentWindow
    "Private"
    CommonControlsDLL current.  "ensure open & initialized"
    ^ super buildWindow: parentWindow.!
relocateFixedPosition
	"Private - relocate controls with fixed location like toolbar or status bar."

	| freeArea rect |
	freeArea := self freeClientAreaBeforeSelf.
	rect := self frameRelativeRectangle.
	self isAtTop
		ifTrue:
			[rect leftTop = freeArea leftTop
				ifFalse:
					[self resizeToRectangle: (freeArea leftTop extentFromLeftTop: rect extent).
					self superWindow invalidateRect: ( rect merge: self frameRelativeRectangle ). "w/o this, the overlapped normal controls (e.g. TextPane)
        won't invalidate the overlapped portion"
					]]
		ifFalse:
			[rect leftBottom = freeArea leftBottom
				ifFalse:
					[self resizeToRectangle: (freeArea leftBottom extentFromLeftBottom: rect extent).
					self superWindow invalidateRect: ( rect merge: self frameRelativeRectangle ). "w/o this, the overlapped normal controls (e.g. TextPane)
        won't invalidate the overlapped portion"
					]].
	!
reportException: aString
    "Private - Report exception <aString>."

    ^self triggerEvent: #exception:
        withArguments: (Array with: aString)
        ifNotHandled: [
            MessageBox
                notify: 'PARTS Status Window'
                withText: aString ].! 
showHelp: text
	"Set and display the help text in simple mode."

	text isNil
		ifTrue: [^self].
	self
		simpleModeText: text;
		simpleMode: true!  
includeSizeGrip: aBoolean
    "Include a size grip at the end of the status window."
    aBoolean
        ifTrue: [ self addStyle: SbarsSizegrip ]
        ifFalse: [ self removeStyle: SbarsSizegrip ]!  
resize: aRectangle
	"Private - Resize the receiver."

	rectangle := 0 @ 0 extent: 0 @ 0. "let system figure out
        the position and size."
	self resizeWindow.
	self sendInputEvent: #relocateFixedPosition. "This is needed since system puts it at the wrong place"! 
resizeLaterSiblings
    "Private - Resize siblings who will not affect the freeClientArea."

    | freeArea siblings pick |
    self superWindow isApplicationWindow ifFalse: [ ^ self ].
    freeArea := self freeClientAreaBeforeSelf.
    freeArea := self freeClientArea: freeArea.
    pick := false.
    siblings := self superWindow childrenAffectingClientArea select: [ :subpane |
        subpane == self
            ifTrue: [ pick := true. false ]  "don't resize self again"
            ifFalse: [ pick ] ].  "resize guys after me"
    siblings do: [ :subpane |
        subpane resize: freeArea.
        freeArea := subpane freeClientArea: freeArea ].
    "resize all normal siblings"
    self superWindow children do: [ :subpane |
        subpane affectsFreeClientArea
            ifFalse: [ subpane resize: freeArea ] ]! 
setInnerParts
	"Private - Create status inner parts."

	| borders rightEdge edgeArray index gapSize |
	borders := self getBorderSizes.
	rightEdge := borders at: 1.
	gapSize := borders at: 3.
	edgeArray := ByteArray new: (innerParts size * 4 max: 4).
	index := 1.
	"innerParts isNil
		ifTrue: [innerParts := OrderedCollection new]."
	innerParts
		do:
			[:aPart |
			rightEdge := aPart width < 0
				ifTrue: [-1]
				ifFalse: [rightEdge + aPart width].
			edgeArray
				at: index put: rightEdge \\ 256;
				at: index + 1
				put:
					(rightEdge < 0
					ifTrue: [255]
					ifFalse: [rightEdge // 256]).
			rightEdge := rightEdge + gapSize.
			index := index + 4].
	UserLibrary
			sendMessage: self handle
			msg: SbSetparts
			wparam:
				(innerParts size = 0
				ifTrue: [1] "pretend there is still one field with 0 width"
				ifFalse: [innerParts size])
			lparamStruct: edgeArray asParameter.
	innerParts
		do:
			[:each |
			self updateStatusField: each]!  
isAtTop
	"Answer true if the receiver is
	postioned at the top of its parent window."

    ^ (style bitAnd: CcsTop) ~= 0! 
updateStatusField: aStatusField
	"Private - aStatusField has been modified."

    self isHandleOk ifFalse: [ ^self ].
    "helpText notNil ifTrue: [ ^self ]."
    UserLibrary
        sendMessage: self handle
        msg: SbSettext
        wparam: ( ( self typeParameter: aStatusField type ) + (self fieldIndexOf: aStatusField) )
        lparamStruct: 
		( aStatusField type = #ownerDraw
			ifTrue: [ String new asParameter ]
			ifFalse: [ aStatusField contents asString asParameter ] ).
	self invalidateRect: nil  "If not do this, type like noBorder won't show"!   
fieldIndexOf: aStatusField
    "Private - Answer the index of <aStatusField>"
    ^ ( innerParts indexOf: aStatusField ) - 1!   
fieldNamed: aSymbol
	"Answer the StatusField with the name <aSymbol>."

	^ innerParts detect: [ :aField | aField name = aSymbol ]
		ifNone: [ nil ]!  
relocateAndResize
	"Private - Relocate self to the right place and
	resize all the later controls."

	self relocateFixedPosition.
	self resizeLaterSiblings! 
getBorderSizes
    "Answer an Array of border horizontal size,
    vertical size, and gap between parts."

    | widths |
    widths := ExternalBuffer usingBytes: ( ByteArray new: 12 ).
    UserLibrary
        sendMessage: self handle
        msg: SbGetborders
        wparam: 0
        lparamStruct: widths asParameter.
    ^ Array
        with: ( widths longAtOffset: 0 )
        with: ( widths longAtOffset: 4 )
        with: ( widths longAtOffset: 8 )!
innerParts: aCollection
	"Private - Set var innerParts to <aCollection>."

	innerParts := aCollection! 
simpleModeText: aString
	"Set simple mode text to <aString>."

	self propertyAt: #simpleModeText put: aString.
    self isHandleOk ifFalse: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: SbSettext
        wparam: 255
        lparamStruct: aString asString asParameter!   
codeGenerationAddAttributeMessagesTo:  anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    super codeGenerationAddAttributeMessagesTo:  anExpressionModel.
    anExpressionModel addSelectorIfNotNil: #height: with: self height.
    innerParts size > 0 ifTrue: [
        innerParts do: [ :field |
            anExpressionModel
                addSelector: #addField: with: field ]]! 
defaultStyle
	"Private - external"
	" Answer the default style."

    ^ 0!
sizeChanged: extent
        "Private - The size of the receiver has been changed
         to extent."
	super sizeChanged: extent.
	self sendInputEvent: #relocateAndResize!   
setMinimumHeightPrivate: pixels
    "Private"
    UserLibrary
        sendMessage: self handle
        msg: SbSetminheight
        wparam: pixels asParameter
        lparam: 0.
    UserLibrary  "WmSize cause it to resize regardless params"
        sendMessage: self handle
        msg: WmSize
        wparam: 0
        lparam: 0.! 
validate
	"Private - Validate the control."

    super validate.
    "border sizes need to be set by whenValid: before the following."

	minimumHeight notNil ifTrue: [
		self height: minimumHeight ].
    self setInnerParts.
    innerParts size > 0 ifTrue: [
        innerParts do: [ :aPart |
            self updateStatusField: aPart ] ].
	self simpleModeText notNil ifTrue: [
		self simpleModeText: self simpleModeText ].
	( self isSimpleMode or: [ innerParts size = 0 ] )
		ifTrue: [ self simpleMode: true ]! 
typeParameter: aType
	"Private - Converty type symbol <aType> which can be caveIn,
	popOut, noBorder, or ownerDraw, to a system parameter."

	| typeSymbol index |
	typeSymbol := aType isString
		ifTrue: [aType asSymbol]
		ifFalse: [aType].
	index := #(#caveIn #popOut #noBorder #ownerDraw) indexOf: typeSymbol.
	index = 0
		ifTrue: [^0].
	^(Array
			with: 0
			with: SbtPopout
			with: SbtNoborders
			with: SbtOwnerdraw) at: index!   
drawControl: aDrawStruct
	"Private - Draw the seleted tab using the image (icon or bitmap)
        in the page."

	| obj |
    self ownerDrawStruct: aDrawStruct.
	(self hasActionForEvent: #drawItem:)
		ifTrue: [^self triggerEvent: #drawItem: with: self drawIndex].
	obj := (innerParts at: self drawIndex) contents.
	( obj isBitmap or: [ obj isIcon ] )
		ifTrue: [ obj displayAt: self drawBox leftTop with: self ownerDrawPen ]
		ifFalse: [ obj asString displayAt: ( self drawBox leftBottom up: 3 )
				with: self ownerDrawPen ]!   
minimumHeight: height
	"Private - Set var minimumHeight to <height>."

	minimumHeight := height!   
setBorderSizesPrivate: anArray
    "Private -
	NOTE - This does not work in the new Win95 anymore.
    anArray has three elements: border horizontal
    size, vertical size, and gap between inner parts."

    "| widths |
    widths := ExternalBuffer usingBytes: ( ByteArray new: 12 ).
    widths
		longAtOffset: 0 put: ( anArray at: 1 );
		longAtOffset: 4 put: ( anArray at: 2 );
		longAtOffset: 8 put: ( anArray at: 3 ).
    UserLibrary
        sendMessage: self handle
        msg: SbSetborders
        wparam: 0
        lparamStruct: widths asParameter"! 
isSimpleMode
	"Private - Answer if the receiver is in simple mode."

	^ self propertyAt: #simpleMode ifAbsent: [ false ]!  
freeClientAreaBeforeSelf
    "Private - Compute the free client area left for the receiver
    before the receiver space is alllocated."

    | remainingClientArea |
    remainingClientArea := self superWindow rectangle.
    self superWindow isApplicationWindow
        ifTrue:
            [self superWindow childrenAffectingClientArea
                do:
                    [:subpane |
                    subpane == self
                        ifTrue: [^remainingClientArea].
                    remainingClientArea := subpane freeClientArea: remainingClientArea]].
    ^remainingClientArea
!   
contents
        "Answer the receiver's contents,
        i.e., a collection of statusField objects."

   ^innerParts !   
placeAtTop
    "Place status window at the top of the containing window."

    self showAtTop: true!   
showAtTop: aBoolean
    " Set where the receiver should be placed in a window."
    aBoolean
        ifTrue: [
            self addStyle: CcsTop ]
        ifFalse: [
            self removeStyle: CcsTop ].
    self isValid ifTrue: [ 
		self setStyle: style.
		self relocateFixedPosition.
		self resizeLaterSiblings ].!  
statusBoxAt: aSymbol
	"Answer the first status field with the name aSymbol.
	 This method is here to be compatible with StatusPane."

	^ self fieldNamed: aSymbol!