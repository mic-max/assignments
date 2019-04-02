3.1.0.106
   
propertyInterface: aPropertyInterface

    "Private - Set propertyInterface."

    propertyInterface := aPropertyInterface!   
partEditProperties

    "Open an editor on the PARTS properties of the receiver. "

    ( self propertyManager ) editFor: self!   
object

    "Private - Answer the object being
    property edited."

    ^ self propertyInterface object!   
okToClose
	"Private - Answer true for closing the property dialog.  This is
	usually sent when the object's workbench is closed."

	^ true!   
initializeObject: anObject

    "Do property edit for <anObject>.
    Queue up 'object:' message so that window
    opening can be finished first."

    [   CurrentEvents add: ( Message new
            receiver: self
            selector: #object:
            arguments: ( Array with: anObject ) ) ] evaluateWithoutInterrupts.
    OSEventSemaphore signal! 
getPropertyEditor

    "Answer the property editor file name."

    ^ editorFileName! 
eventToProperty: anEvent
    "Private - Convert an event name to its property name."

    generatedEvents associationsDo: [ :assoc |
        ( assoc value includes: anEvent )
            ifTrue: [ ^ assoc key ]
        ].
    ^ nil
! 
partMessages

        " Answer the PARTS message interface of the receiver. "

    ^PARTSInterfaceList new
        items: #( #initializeObject: #storePropertyValues #evaluate: #supportedEditors #supportedValidators #editPropertyFile: ),
            self propertyInterface setMessages asSortedCollection
        separators: #( 6 )
        defaultItem: #setObject!
partEvents
    "Answer the PARTS event interface of the receiver. "

    | events |
	events := self allGeneratedEvents.
	events isNil ifTrue: [
		MessageBox message: 'You need to construct properties first before you can see events.'.
		^ PARTSInterfaceList new ].
    ^PARTSInterfaceList new
        items: ( events := self allGeneratedEvents )
        separators: #()
        defaultItem: ( generatedEvents size = 0
            ifTrue: [ nil ]
            ifFalse: [ events first ] )
! 
createLinksTo: propSheet in: app
    "Private - Create links between the interface part
    and controls in <app>."

    | okButton applyButton |
    "Create OK and Cancel buttons links"
    okButton := app componentNamed: 'Ok'.
    self
            partLinkFrom: okButton
            when: #clicked
            send: #storePropertyValues
            to: self.
    self
            partLinkFrom: okButton
            when: #clicked
            send: #close
            to: propSheet.
    "cancelButton := app componentNamed: 'Cancel'.
    self
            partLinkFrom: cancelButton
            when: #clicked
            send: #close
            to: propSheet."
    applyButton := app componentNamed: 'Apply'.
    self
            partLinkFrom: applyButton
            when: #clicked
            send: #storePropertyValues
            to: self. "Create links"
    self
            partLinkFrom: self partApplication
            when: #openOn:
            send: #OpenFloat
            to: propSheet.
    self
            partLinkFrom: self
            when: #WindowTitle:
            send: #setLabel:
            to: propSheet.!
createEvent: aName

    "Private - Make aName into a legitimate event name."

    ^ ( aName select: [ :char | char isWhitespace not ] )!  
editPropertyFile: aFileName

    "Open a workbench on file <fileName> which will serve
    as the property dialog for receiver's object."

    | editors newEditor interface app |
    (editors := PARTSEditor editorsOnFile:  aFileName ) size > 0
        ifTrue: [ ^ ( editors at: 1 ) mainView bringToTop; setFocus ].
    ( PARTSFile isFileInPath: aFileName )
        ifTrue: [ PARTSEditor openOnFile: aFileName ]
        ifFalse: [
            app := PARTSApplication new fileDescriptor: "assume the new file is in the first search path"
                    ( PARTSFileDescriptor fileName: aFileName in: PARTSFile currentSearchPath first ).
            newEditor := PARTSEditor editorClass new openOn: app.

		self object partApplication fileDescriptor isNil
			ifTrue: [ ^ self error: 'The original application has not been saved in a file yet.' ].
          interface :=  self partCreateControl:  (  PARTSFile applicationFromFile: 'propintr.par'
                    "PARTSPropertyInterface new
                        fileName: aFileName;
                        yourself" )
                    in: newEditor workbenchPane
                    box: ( SysFont charSize * (4 @ 5) extentFromLeftTop: Icon iconSize )
                    name: 'PropertyInterface'.
            interface
                fileName: self object partApplication fileDescriptor fullPathName;
                partGenerateDialog.
            ].!
deletedWrappers: wrappers
	"Private - Close the app if the underline object has been
	deleted from its editor."

	wrappers detect: [ :aWrapper | aWrapper object == propertyInterface object ]
		ifNone: [ ^ self ].
	self getMainWindow close! 
evaluate: expression

    "Evaluate <expression>."

    ^ CompilerInterface
        evaluate: expression
        in: UndefinedObject
        to: nil
        notifying: self
        ifFail: [ ^nil ].!  
partEditProperties

        " Open an editor on the PARTS properties of the receiver. "

    ( self propertyManager ) editFor: self!  
partEnableExecution

        " The application containing the receiver
        is going to be executed.  If value events are surfaced,
        relay its events to any outgoing links. "

    self partWrapper notNil   " backstop in case of multiple enablements "
        ifTrue: [
            self setEventActionsOfValue.
            self partWrapper: nil ].!
partMessages

    "Answer the PARTS message interface of the receiver. "

    ^PARTSInterfaceList new
        items: #( #constructedPropertyHandler )
        separators: #( )
        defaultItem: #constructedPropertyHandler!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelectorIfNotNil: #initEvents: with: initEvents;
        addSelectorIfNotNil: #setMessages: with: setMessages;
        addSelectorIfNotNil: #propertyNames: with: self propertyNames!  
newProperties

    "Private - Answer the new properties
    created by the user."

    ^ newProperties!  
addPage: aPage to: tabControl
	"Private - Add a page <aPage> to the end of <tabControl>."

	| pageControl tabControlPage |
	pageControl := (Smalltalk at: #PARTSTabControlPagePart ) new.
	tabControlPage := (Smalltalk at: #TabControlPage ) new
			label: ''; "force a label so that the page can be selected"
			addSubpane: pageControl;
			yourself.
	pageControl page: tabControlPage.
	self setPageInfo: aPage for: tabControlPage.
	pageControl := self
		partCreateControl: pageControl
			in: tabControl
			box: ( 0@0 extent: 1 @ 1 )
			name: 'Page', ( tabControl pages size + 1 ) asString.
	tabControl selectPage: tabControlPage.
	^ pageControl!
fileName

    "Private - Answer the part file name."

    ^ fileName! 
editorNameFor: propertyName

    "Private - Answer the editor name for <propertyName>."

    ^ ( newProperties at: propertyName ) at: 1!  
supportedEditors

    "Private - Answer all the prebuilt editors
    supported by the property handler."

    ^ #('none'), PropertyManager supportedEditors keysAsArray! 
propertyException: exception
	"Private - Check if any property not there anymore, don't abort"

	| newProperties missingOnes modified |
	newProperties := application propertyManager propertyNames.
	missingOnes := OrderedCollection new.
	(modified := self propertyAt: #applicationProperties ifAbsent: [^self error: exception messageText])
		keysDo:
			[:name |
			(newProperties includes: name)
				ifFalse: [missingOnes add: name]].
	missingOnes isEmpty not
		ifTrue:
			[MessageBox warning: 'Modified properties: ' , missingOnes printString , ' do not exist anymore.'.
			missingOnes
				do:
					[:each |
					modified removeKey: each]].
	!  
fileName: aFileName

    "Private - Set the part file name."

    | app |
    aFileName size = 0 ifTrue: [
        fileName := nil.
        ^ nil ].
    app := PARTSFile applicationFromFile: aFileName.
    app isNil ifTrue: [ ^ nil ].
    fileName := aFileName.
    objectExpression := nil.
    self object: app!  
applyProperties: newProperties
    "Private - Apply the modified properties to the contained part.  These
    properties are carried with the receiver and applied to the contained
    part every time it is loaded."

    | manager oldProperties |
    ( manager := self application propertyManager ) notNil ifTrue: [
        manager setPropertiesNoValidate: newProperties
            for: application ].
    oldProperties := self propertyAt: #applicationProperties ifAbsent: [ Dictionary new ].
    self propertyAt: #applicationProperties put: ( oldProperties addAll: newProperties; yourself )!
createLinksTo: controls accessors: accessors
	"Private - Create links for generated <controls> whose
	property accessors are <accessors>."

	| nameIndex control |
	1 to: accessors size
		do:
			[:index |
			nameIndex := self propertyInterface propertyNames indexOf: (accessors at: index) key.
			control := controls at: index.
			control isPushButton
				ifFalse:  "check box and entry field"
					[self
							partLinkFrom: self
							when: (self propertyInterface initEvents at: nameIndex)
							send: #setValue:
							to: control].
			self
					partLinkFrom: control
					when:
						(control isButton
					ifTrue:
						[control isPushButton
							ifTrue: [#clicked]
							ifFalse: [#clicked:]]
					ifFalse:
						[#changed:])
					send: (self propertyInterface setMessages at: nameIndex)
					to: self].
	!
storePropertyValues
	"Store edited properties back to object.
    This is usually done when the property edit
    is finished, but it can also be done if there
    is an 'apply' button."

	self propertyInterface storePropertyValues!
compilerError: aString at: anInteger in: codeString for: aClass

        "Private - The compiler detected an error when attempting
        to compile the contents of the receiver.  Display the
        error message in the entry field."

    self error: ( codeString copyFrom: 1 to: anInteger - 1 ),
        '''',
        aString,
        '''',
        ( codeString copyFrom: anInteger to: codeString size)!  
editorFor: propertyName

    "Private - Answer the editor for <propertyName>."

    | name |
    name := self editorNameFor: propertyName.
    ^ ( name isNil or: [ name = 'None' ] )
        ifTrue: [ nil ]
        ifFalse: [ PropertyManager perform: ( PropertyManager supportedEditors at: name ) ]!
allGeneratedEvents
	"Private - Answer all generated events."

	| events |
	events := OrderedCollection new.
	generatedEvents size = 0
		ifTrue: [ ^ nil ].
	generatedEvents do: [ :anArray |
		events addAll: anArray ].
	^ events!  
partRealSelectorFor: aSelector

        " Answer the real message to send to the receiver
        for aSelector.  If aSelector isn't part of
        the container's own protocol, map it to the
        relay method which forwards it to the
        contained value. "

    ^( self respondsTo: aSelector)
        ifTrue: [ aSelector ]
        ifFalse: [ #relayMessage:arguments: ]!  
partMirrorCopyReal: aMirrorCopyDictionary
    " Private - add a mirror copy of the receiver
    to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    aMirrorCopyDictionary forExecute
        ifTrue: [
            aMirrorCopyDictionary at: self put: ( copy := self class new ).
            copy partWrapper: ( wrapper partMirrorCopy: aMirrorCopyDictionary ).
            ^ copy ]
            "not for run time, can't just return nil, otherwise
            componentDictionary and partWrapper will have problems."
        ifFalse: [ ^ super partMirrorCopyReal: aMirrorCopyDictionary ]
! 
objectExpressionPrivate: aString

    "Private - Set the expression for deriving the
    edited object."

    objectExpression := aString!   
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelectorIfNotNil: #setPropertyEditor: with: self getPropertyEditor;
        addSelectorIfNotNil: #generatedEvents: with: generatedEvents;
        addSelectorIfNotNil: #newPropertiesAttribute: with: self newProperties!  
setPropertyEditor: aString

    "Private - Set the property editor file name."

    editorFileName := aString!
partControlFor: accessor
inset: inset
view: aView
	"Private - Create controls corresponding to <accessor>
    in <dialog> positioned with <inset> from top left."

	| control width font defaultExtent leftTopCorner |
	control := accessor defaultControlForPart new.
	font := control font.
	font isNil
		ifTrue: [font := control defaultFont].
	leftTopCorner := aView rectangle leftTop.
	(control isKindOf: EntryField)
		ifTrue:
			[self
					partCreateControl:
						(PARTSStaticTextPart
					new value: accessor key , ':';
					yourself)
					in: aView
					box: ( (leftTopCorner rightAndDown: inset + (SysFont height // 4)) extentFromLeftTop: ((width := (font stringWidth: accessor key) 
						+ (SysFont width *  2)) @ (font height + 8)))
					name: accessor key.
			defaultExtent := control partDefaultExtent.
			self
					partCreateControl: control
					in: aView
					box: ((leftTopCorner rightAndDown: inset + (width + 4 @ 0)) extentFromLeftTop: defaultExtent)
					name: accessor key.
			]
		ifFalse:
			[(control respondsTo: #label:)
				ifTrue:
					[control
						label:
							(accessor editor isNil
							ifTrue: [accessor key]
							ifFalse: [accessor key , '...'])].
			defaultExtent := control partDefaultExtent.
			self
					partCreateControl: control
					in: aView
					box: ((leftTopCorner rightAndDown: inset) extentFromLeftTop: (defaultExtent max: ((font stringWidth: accessor key) + (SysFont width * 6)) @ 0))
					name: accessor key.
			].
	inset y: inset y + defaultExtent y + (SysFont height // 2).
	^control!   
new

    "Create an instance and initialize."

    ^ super new initialize!
partRequestDialog: aBoolean
    "Private - Request to generate the property dialog
    if <aBoolean> is true."

    aBoolean ifTrue: [
        requests isNil ifTrue: [ requests := OrderedCollection new ].
        requests addLast: #partGenerateDialog ]!   
newProperties: aDictionary

    "Private - Set the new properties to <aDictionary>
    The value of associations is an array of editor and format."

    newProperties := aDictionary.
    self generateEvents: aDictionary.
    self partEditor validateLinksAttachedTo: self!
setEventActionsOfValue

        " Private - if events from the contained value
        are surfaced in the receiver's application,
        attach the event actions to the actual triggering object.
        This is only done in the executing application,
        where links have already been installed as
        real event table entries. "

    | anAction |
            self propertyInterface initEvents, #( #WindowTitle: #changed #stored ) do: [ :anEvent |
                anAction := self actionForEvent: anEvent.
                anAction notNil
                    ifTrue: [ self propertyInterface when: anEvent evaluate: anAction ].
                ].!
initialize

    "Private - Initialzie."

    newProperties := Dictionary new.!
partLinkFrom: sourcePart when: sourceEvent send: destMsg to: destPart

    "Private - Create a link from <sourcePart> when <sourceEvent> is
    fired to the message <destMsg> of <destPart>."

    self partEditor
        createLinkFrom: sourcePart
        event: sourceEvent
        to: destPart
        message: destMsg
!   
relayMessage: aSelector arguments: arguments

        " Forward the message aSelector to value
        with the given arguments (an array of values). "

    ^ self propertyInterface perform: aSelector withArguments: arguments!   
editApplicationProperty: aPropertyUnit

    "Private - Open the property editor for the application
    contained in the receiver."

    ^ self application partEditExternalProperties!  
supportedEditors

    "Private - Answer all the prebuilt editors
    supported by the property handler."

    ^ PropertyManager supportedEditors keysAsArray!
partDoRequest: propertyDict
    "Execute the requests posted in the property dialog."

    requests size > 0 ifTrue: [
        requests do: [ :selector |
            self perform: selector ].
        requests := nil ]!  
object: anObject

    "Private - Set the object which the property handler will be
      applied to and trigger all the initEvents."

	| mainWindow |
    self partIsEditing
       ifTrue: [
            ( anObject respondsTo: #partWrapper: ) ifTrue: [ "This
                    is necessary since PropertyHandler uses partWrapper
                    to distinguish a part from a non-part"
                anObject partWrapper isNil ifTrue: [
                    anObject partWrapper: PARTSWrapper new ]].
            self propertyInterface setInterface: anObject.
            self partEditor validateLinksAttachedTo: self ]
        ifFalse: [
			( mainWindow := self getMainWindow ) notNil
				ifTrue: [ mainWindow controller: anObject partEditor controllee: self ].
            self propertyInterface object: anObject ].!   
partAddedTo: anApplication
        "Private - The receiver has just been added to anApplication.
        Create any links or register event handlers if desired. "

    ( anApplication externalMessages includes: #propertyManager )
        ifFalse: [ anApplication addExternalMessage: #propertyManager ].
    anApplication partEditor
        createLinkFrom: anApplication
        event: #propertyManager
        to: self
        message: #constructedPropertyHandler.!   
propSheetFileName
    "Private - The part file name for PropertySheet part."
    ^ 'propshet.par'!  
supportedFormats

    "Private - Answer all the names of formats
    supported by the constructor."

    ^ #('none'), PropertyManager supportedFormats keysAsArray!  
supportedValidators

    "Private - Answer all the prebuilt validators
    supported by the property handler."

    ^ PropertyManager supportedValidators keysAsArray!   
formatNameFor: propertyName

    "Private - Answer the format name for <propertyName>."

    ^ ( newProperties at: propertyName ) at: 2!  
constructPropertyManager
   "Construct accessors for receiver's properties."

    ^ super constructPropertyManager
        add: ( SelectorPropertyAccessor name: 'Part name' get: #partName set: #partName: editor: nil
            validator: PropertyManager validatorForPartName );
        add: ( SelectorPropertyAccessor name: 'Icon' get: #partIcon set: #partSetGraphics:
            editor: PropertyManager editorForIcon );
        add: ( SelectorPropertyAccessor name: 'Interface' get: nil set: nil editor: #partEditInterface );
        addNames: #('Part name' 'Icon'  'Interface' ) toPage: 'General';
        yourself! 
generatedEvents: aDictionary
        "Private - set the receiver's generated events variable."
    generatedEvents := aDictionary!  
partEditExternalProperties
    " Open an editor on the PARTS external properties of the receiver. "

    | handler |
    handler := self propertyManager.
    handler isNil
        ifFalse:
            [handler editFor: self. "usually a link"
            ^handler]!  
getMainWindow
	"Private - Answer the main window."

	^ ( self eventTable at: #WindowTitle: ifAbsent: [ ^nil ] ) receiver!  
partLinkClassFor: aSelector

        " Answer the kind of PARTS link to use to
        send the message aSelector to the receiver. "

    ^( self respondsTo: aSelector )
        ifTrue: [ super partLinkClassFor: aSelector ]
        ifFalse: [ PARTSAliasLink ]  " relay to contained value "! 
newPropertiesAttribute: aDictionary

    "Private - Set the new properties to <aDictionary>."

    newProperties := aDictionary.! 
objectExpression

    "Private - The original Smalltalk expression from
    which the edited object is derived."

    ^ objectExpression!
partRequestUpdate: aBoolean

    "Private - Request to update the underline object.
    if <aBoolean> is true."

    aBoolean ifTrue: [
        requests isNil ifTrue: [ requests := OrderedCollection new ].
        requests addFirst: #updateObject ]!  
updateObject

    "Private - Update object from either the part file
    or the object expression."

    fileName notNil ifTrue: [
        self fileName: fileName ].
    objectExpression notNil ifTrue: [
        self objectExpression: objectExpression ]!
constructedPropertyHandler

    "Answer the newly constructed property handler."

    | handler accessor eventName propertyName table |

    handler := PropertyManager new.
    eventTable notNil
        ifTrue: [ table := eventTable ]
        ifFalse: [ table := self wrapper eventHandlersAttribute ].
    table size > 0 ifTrue: [
        table associationsDo: [ :assoc |
                eventName := assoc key.
                propertyName := self eventToProperty: eventName.
                ( newProperties includesKey: propertyName ) ifTrue: [
                    accessor := handler associationAt: propertyName ifAbsent:
                        [ handler add:
                            ( LinkPropertyAccessor new
                                name: propertyName;
                                editor: ( self editorFor: propertyName );
                                format: ( self formatNameFor: propertyName ) ).
                        ].
                    ( ( generatedEvents at: propertyName ) indexOf: eventName ) odd
                        ifTrue: [ accessor get: ( self makeAction: assoc value ) ]
                        ifFalse: [ accessor set: ( self makeAction: assoc value ) ].                    ]
                ]
        ].
    editorFileName notNil
        ifTrue: [ handler addGroupEditor: editorFileName ].
    ^ handler
! 
makeAction: links
    "Private - Answer an action out of a link
    or a collection links."

    ^ links isCollection
        ifTrue: [ ActionSequence fromCollection: links ]
        ifFalse: [ links ]
!
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Private - add message models to rebuild the receiver to anExpressionModel."
    anExpressionModel
        addSelectorIfNotNil: #fileNamePrivate: with: self fileName;
        addSelectorIfNotNil: #objectExpressionPrivate: with: self objectExpression;
        addSelectorIfNotNil: #propertyInterface: with: self propertyInterface!
fileNamePrivate: aFileName

    "Private - Set the part file name."

    fileName := aFileName!   
partCreateControl: aControl in: destWindow box: aRect name: partName

    "Private - Create aControl in <destWindow> with <aRect>
    as its rectanlge and <partName> as its name."

    | editor |
    aControl isWindow ifTrue: [
            aControl frameWindow parent: destWindow ].
    editor := destWindow partEditor.
    ^ ( editor
            addComponent: aControl
            in: destWindow
            box: ( aRect mapFromWindow: destWindow to: destWindow partEditor workbenchPane )
            contents: nil
            name: ( editor application generatePartNameFor: aControl
                preference: partName )
            icon: nil
            helpInfo: nil
        ) object!   
objectExpression: aString

    "Private - Set the expression for deriving the
    edited object."

    objectExpression := aString.
    objectExpression size ~= 0 ifTrue: [
        fileName := nil.
        self object: ( self evaluate: objectExpression ) ]! 
constructPropertyManager

   "Construct accessors for receiver's properties."

    
    ^ super constructPropertyManager
        add: ( SelectorPropertyAccessor name: 'New Properties' get: #newProperties set: #newProperties: );
        add: ( SelectorPropertyAccessor name: 'PropertyEditor' get: #getPropertyEditor set: #setPropertyEditor: );
        add: ( SelectorPropertyAccessor name: 'Supported Editors' get: #supportedEditors set: nil );
        add: ( SelectorPropertyAccessor name: 'Supported Formats' get: #supportedFormats set: nil );
        addGroupEditor: 'pppropco.par';
        yourself! 
generateEvents: aDictionary

    "Private - Generate property accessors form <aDictionary>."

    | name |
    generatedEvents := Dictionary new.
    aDictionary associationsDo: [ :assoc |
        name := assoc key.
        generatedEvents at: name put:
            ( Array
                with: ( 'get', ( self createEvent: name ) ) asSymbol
                with: ( 'set', ( self createEvent: name ), ':' ) asSymbol )
        ]
!   
propertyInterface

    "Private - Answer the PropertyInterface object which
    is used as the model for both Smalltalk and Parts
    default property dialog."

    propertyInterface isNil
        ifTrue: [
            propertyInterface := PropertyInterface new.
            propertyInterface initiator: self ].
    ^ propertyInterface!
partAddedTo: anApplication

        " The receiver has just been added to anApplication.
        Create any links or register event handlers if desired. "

    ( anApplication externalMessages includes: #openOn: )
        ifFalse: [ anApplication addExternalMessage: #openOn: ].
    self
        partLinkFrom: anApplication
        when: #openOn:
        send: #initializeObject:
        to: self!  
createPropertySheetFrom: app for: pages
    "Private - Answer the property sheet created out
    of part <app> whose controls will be created
    out of property <pages>."

    | aRect maxFields charSize defaultExtent dialog |
    maxFields := 0.
    pages do: [ :aPage | maxFields := maxFields max: ( aPage items size ) ].
    charSize := PARTSHostInterface defaultPartFont charSize.
    defaultExtent := PARTSPushButtonPart new partDefaultExtent.
    aRect :=     ( charSize * (10 @ 5) extentFromLeftTop: (defaultExtent x * 4 @
        ((defaultExtent y + (SysFont height // 2)) * ( maxFields + 4 )))).

    dialog := self
        partCreateControl: app
        in: wrapper partEditor workbenchPane
        box: aRect
        name: 'PropSheet'.

    "dialog resizeToRectangle:aRect."
    ^ dialog
! 
partGenerateDialog
	"Private - Create the dialog window for the object's property."

	| propMgr app dialog accessors controls inset  sheet pages page tabControl charSize aSet missing controlPage max tabControlClass |

	"Create dialog"
	propMgr := self object propertyManager.
	pages := propMgr getPages.
	aSet := Set new.
	pages do: [:aPage | aSet addAll: aPage items ].
	propMgr size > aSet size
		ifTrue: [ 
			missing := OrderedCollection new.
			propMgr keysDo: [ :each | ( aSet includes: each ) ifFalse: [ missing add: each ] ].
			MessageBox warning: 'Properties not included in any pages: ', missing asArray printString ].

	app := PARTSFile applicationFromFile: self class propSheetFileName.
	app isNil
		ifTrue: [^self partGenerateDialogFlat].
	dialog := self createPropertySheetFrom: app for: pages. 
	max := 0.

	"Create fields"
	charSize := Button defaultFont charSize.
	controls := OrderedCollection new.
	accessors := OrderedCollection new.  "rebuild in the same order as controls"
	tabControlClass := Smalltalk at: #TabControl ifAbsent: [ ^self partGenerateDialogFlat].
	tabControl := dialog children detect:
		[:pane | pane isKindOf: tabControlClass]. "get TagControl"
	1 to: pages size do: [:index |
		page := pages at: index.
		index > tabControl pages size 
			ifTrue: [ self addPage: page to: tabControl ]
			ifFalse: [
				tabControl turnToPageNumber: index.
				controlPage := tabControl currentPage.
				self setPageInfo: page for: controlPage.
				tabControl updateTab: controlPage.
				tabControl selectPage: controlPage ].
		sheet := tabControl currentPage controls first.
		inset := (2 @ 1) * charSize.
		( propMgr getAccessorsForPage: page ) do:
			[:accessor |
				accessors add: accessor.
				controls add:
					(self
						partControlFor: accessor
						inset: inset
						view: sheet). "inset  is bumped"
			].
		max := max max: inset y.
		].

    dialog resizeToRectangle: ( dialog frameRelativeRectangle height: max + ( SysFont height * 7 ) ).
	tabControl rectangle;
		resizeChildren.  "System does not generate wmSize for tabControl, so force it."
	"Create links"
	self createLinksTo: dialog in: app.
	self createLinksTo: controls accessors: accessors.
	! 
renamedWrapper: aWrapper
	"Private - do nothing.  Called when object is renamed."!   
partGenerateDialogFlat
    "Private - Create the flat (no pages) dialog window for the object's property."

    | dialog accessors controls control inset cancelButton okButton applyButton font nameIndex charSize defaultExtent editorPane leftTopCorner |

    accessors := self object propertyManager
        getAccessorsSortedByControlFor: self object.
    font := Button defaultFont.
    charSize := font charSize.
    defaultExtent := PARTSPushButtonPart new partDefaultExtent.

    "Create dialog"
	editorPane := wrapper partEditor workbenchPane.
	leftTopCorner := editorPane rectangle leftTop.
    dialog :=
        self partCreateControl:  ( PARTSDialogWindowPart new
				  label: 'Properties';
                suspendClient: true;
                openingPosition: #mouse;
                yourself )
            in: editorPane
            box: ( ( leftTopCorner rightAndDown: charSize * (10 @ 5) )
				extentFromLeftTop: ( defaultExtent x *  4 @ (( defaultExtent y + 
					( SysFont height // 2 )) * ( accessors size + 3 ))))
            name: 'Dialog'.

    "Create fields"
    controls := OrderedCollection new: accessors size.
    inset := ( 2 @ 1 ) * charSize.
	leftTopCorner := dialog rectangle leftTop.
    accessors do: [ :accessor |
        controls add: ( self partControlFor: accessor inset: inset view: dialog ).  "inset  is bumped"
        ].

    "Create OK and Cancel buttons"
    inset y: inset y + ( charSize y // 2).   "leave a gap"
    okButton := self
        partCreateControl:  ( PARTSPushButtonPart new defaultPushButton; label: 'OK' )
        in: dialog
        box: ( (leftTopCorner rightAndDown: inset) extentFromLeftTop: defaultExtent )
        name: 'Ok'.
    self partLinkFrom: okButton when: #clicked send: #storePropertyValues to: self.
    self partLinkFrom: okButton when: #clicked send: #close to: dialog.

    inset x: ( inset x + defaultExtent x + ( font width * 2 ) ).
    cancelButton := self
        partCreateControl:  ( PARTSPushButtonPart new label: 'Cancel' )
        in: dialog
        box: ( (leftTopCorner rightAndDown: inset) extentFromLeftTop: defaultExtent )
        name: 'Cancel'.
    self partLinkFrom: cancelButton when: #clicked send: #close to: dialog.

    inset x: ( inset x + defaultExtent x + ( font width * 2 ) ).
    applyButton := self
        partCreateControl:  ( PARTSPushButtonPart new label: 'Apply' )
        in: dialog
        box: ( (leftTopCorner rightAndDown: inset) extentFromLeftTop: defaultExtent )
        name: 'Apply'.
    self partLinkFrom: applyButton when: #clicked send: #storePropertyValues to: self.

    "Create links"
    self
        partLinkFrom: self
        when: #changed
        send: #enable
        to: applyButton.
    self
        partLinkFrom: self
        when: #stored
        send: #disable
        to: applyButton.
    self
        partLinkFrom: self partApplication
        when: #openOn:
        send: #open
        to: dialog.
    self
        partLinkFrom: self
        when: #WindowTitle:
        send: #setLabel:
        to: dialog.
    self
        partLinkFrom: dialog
        when: #opened
        send: #disable
        to: applyButton.

    1 to: accessors size do: [ :index |
        nameIndex := self propertyInterface propertyNames indexOf: ( accessors at: index ) key.
        control := controls at: index.
        control isPushButton ifFalse: [
            self
                partLinkFrom: self
                when: ( self propertyInterface initEvents at: nameIndex )
                send: #setValue:
                to: control ].
        self
            partLinkFrom: control
            when: ( control isButton
                ifTrue: [
                    control isPushButton
                        ifTrue: [ #clicked ]
                        ifFalse: [ #clicked: ] ]
                ifFalse: [ #changed: ] )
            send: ( self propertyInterface setMessages at: nameIndex )
            to: self ].
! 
constructPropertyManager
   "Construct accessors for receiver's properties."

    
    ^ super constructPropertyManager
        add: ( SelectorPropertyAccessor name: 'Application File Name' get: #fileName set: #fileName: );
        add: ( SelectorPropertyAccessor name: 'Object Expression' get: #objectExpression set: #objectExpression: );
        add: ( SelectorPropertyAccessor name: 'Object' get: #object set: #object: );
        add: ( SelectorPropertyAccessor new
            name: 'Generate Dialog';
            set: #partRequestDialog:;
            format: 'Boolean'
             );
        add: ( SelectorPropertyAccessor new
            name: 'Update Object';
            set: #partRequestUpdate:;
            format: 'Boolean'
            );
        epilog: #partDoRequest: ;
        addGroupEditor: 'pppropin.par';
        yourself.!  
partEvents

        " Answer the PARTS event interface of the receiver. "

    ^PARTSInterfaceList new
        items: #( #WindowTitle: #changed #stored ), self propertyInterface initEvents asSortedCollection
        separators: #( 3 )
        defaultItem: #WindowTitle:! 
setPageInfo: aPage for: tabControlPage
	"Private - Copy page info from <aPage> to <tabControlPage>."

	tabControlPage
		label: aPage label;
		image: aPage image;
		tipText: aPage description.
!