3.1.0.106
   
associationClass

        "Private - Answer the class of associations used by the receiver -
        a Dictionary requirement."

    ^ObjectPropertyAccessor!
set: anAction

    "Set the action for storing the property to <anAction>."

    value at: 2 put: anAction!   
image
    "Answer the image of the page."

    ^ image!
getValueFor: anObject

    "Private - Answer the value of the property."

    | anAction |
    ( anAction := self getAction )
        isNil ifTrue: [
            ^ self isBooleanFormat ifTrue: [ false ] ifFalse: [ nil ] ].
    ^ PropertyManager performAction: anAction object: anObject arguments: nil.!
getValueFor: anObject

    "Private - Answer the value of the property."

    ^ value!
dragTarget
    "Answer true if can be the target of a drag."

    ^ dragTarget!
getPages

    "Answer a collection of all the PropertyPages under property '~pages'.
      If the property is missing, answer a collection of one PropertyPage
      containing all primary property names."

    ^ self metaProperties getProperty: self nameForPage
        for: nil
        ifAbsent: [
            Array with:
                ( PropertyPage new
                    label: 'Properties';
                    description: 'All properties';
                    items: self keysAsArray;
                    yourself )
            ]!   
addItems: anArray

    "Add items <anArray> to the receiver."

    items isNil ifTrue: [
		items := OrderedCollection new ].
	items := items, anArray!  
format

    "Private - Answer the format of the property."

    value size < 5
        ifTrue: [ ^ nil ]
        ifFalse: [ ^ value at: 5 ]!
setValue: aValue for: anObject

    "Private - Set the value of the property."

    self implementedBySubclass!   
name: aString
style: poolItemKey
pool: aPool
	"Create an Accessor with the name <aString>.
    <poolItemKey> is the style constant name and
    <aPool> is the Smalltalk pool."

	^self
		new name: aString;
		style: poolItemKey;
		pool: aPool !  
cachedHandlers

    "Private - Answer all the cached property handlers."

    ^ CachedHandlers isNil
        ifTrue: [ CachedHandlers := IdentityDictionary new ]
        ifFalse: [ CachedHandlers ]!  
windowPolicyClass
    "Answer the class of window policy for the receiver."

    ^NoMenusWindowPolicy! 
dragSource: aBoolean
    "Set dragSource to aBoolean."

    dragSource := aBoolean!
editorForFont

   "Answer the editor for changing font."

    ^ Message receiver: self selector: #edit:font:! 
setValue: aValue for: anObject

    "Private - Set the value of the property."

    | anAction |
    ( anAction := self setAction )
        isNil ifTrue: [ ^ aValue ].
    PropertyManager performAction: anAction object: anObject arguments: ( Array with: aValue ).!   
items: anOrderedCollection

    "Set items within a page which is an
      Array of property names."

    items := anOrderedCollection!  
editor

    "Private - Answer the editor for the property."

    ^ value size >= 3
        ifTrue: [ value at: 3 ]
        ifFalse: [ nil ]!
editProperty: name
value: oldValue
for: anObject
apply: applyMessage
	"Edit a specific property with its built-in editor. The property's current value is <oldValue>.  Some editor has the feature of 'apply' which can use the <applyMessage> to ask the object to update itself with the new value.  The editor only has to supply the first argument (new edited value) to <applyMessage>."

	^(self associationAt: name)
			edit: oldValue
			for: anObject
			apply: applyMessage!  
name: aString get: getSelector set: setSelector editor: anEditor validator: aValidator
	"Create an Accessor with the name <aString>.
    The property is retrieved by <getSelector> which
    has 0 arguments and modified by <setSelector>
    which has 1 argument. <anEditor> and <aValidator> is used to
    edit and validate the property value."

	^self
		new key: aString;
		get: getSelector;
		set: setSelector;
		editor: anEditor;
		validator: aValidator!  
supportedFormats
	"Answer a Dictionary of supported formats
    with their corresponding controls."

	^Dictionary
		new at: 'String' put: PARTSEntryFieldPart;
		at: 'Boolean' put: PARTSCheckBoxPart;
		at: 'Currency' put: PARTSCurrencyEntryFieldPart;
		at: 'Float' put: PARTSFloatEntryFieldPart;
		at: 'Integer' put: PARTSIntegerEntryFieldPart;
		at: 'Phone' put: PARTSPhoneNumberEntryFieldPart;
		"at: 'Expression' put: PARTSExpressionEntryField;"  "not runtime"
		at: 'List' put: PARTSListPanePart;
		yourself!  
initEvents: events

    "Private - Set all the initializing events."

    initEvents := events!   
new

    "Create a new instance with initialization."

    ^ super new initialize!
validate: object partName: requestedName

    "Private - Validate the part name
    <requestedName> for <object>.  Convert
    it to a legitimate name if it is not."

    | newName |

    object partName = requestedName
        ifTrue: [ ^requestedName ].
    newName := object partApplication
        generatePartNameFor: object
        preference: requestedName trimBlanks.
    ( newName = requestedName )
       ifTrue: [ ^requestedName ]
        ifFalse: [
            ( MessageBox confirm:
                    '''', requestedName,
                    ''' is  not a valid name, is ''', newName, ''' ok?' )
                ifTrue: [ ^ newName ]
                ifFalse: [ ^object partName ] ].! 
propertyManager

    "Answer the property handler associated with
    the receiver."

    ^ self propertyAt: #propertyManager
        ifAbsent: [ super propertyManager ]!  
validator

    "Answer the validator of the property to <anAction>."

    ^ value size >= 4
        ifTrue: [ value at: 4 ]
        ifFalse: [ nil ]!   
mask
	"Private - Answer the mask."

	^ value at: 3!
edit: control orderChildren: aCollection
	"Private - Edit ordered child controls <aCollection> contrained in <control>."

	^ ( Smalltalk at: #PARTSTabOrderEditor ifAbsent: [ ^nil ] )
		new openOn: aCollection! 
items

    "Answer all the property names within the page."

    ^ items! 
object

    "Answer the object whose properties
    are being edited."

    ( object isNil and: [ initiator notNil ] )
        ifTrue: [ initiator updateObject ].
    ^ object!   
object: anObject

    "Set the object whose properties are being edited
    and trigger initialization events."

    self initialState: anObject.
    self triggerInitEvents.!  
name: aName object: anObject

    "Create an Accessor with the name <aName>.
    Use <anObject> as the property's value."

    ^ self key: aName
        value: anObject!   
edit: anObject framingBlock: aFramerInfo

    "Private - Edit the framing bock <aFramer> for <anObject>."

    Smalltalk at: #PARTSWindowSizeEditor ifAbsent: 
		[ ^self error: 'Edit framingBlock is a PARTS only function' ].
    aFramerInfo isArray
            ifTrue: [
                        ^ Array with: ( (Smalltalk at: #PARTSWindowSizeEditor) new
                            openOn: (aFramerInfo at: 1) copy
                            parentRectangle: ( aFramerInfo at: 2 ) )
                        with: ( aFramerInfo at: 2 ) ]
            ifFalse: [ self error: 'Invalid frame information' ].
! 
createSetMessage: aName
    "Private - Create a message for property <aName>.
    It has one argument for setting the property's value.
    The message name is prefixed with 'Edit' or 'Set'
    depending on whether the property has an editor
    associated with it."

    ^ ( propertyHandler hasEditorOfProperty: aName )
        ifTrue: [
                ( 'Edit'
                , ( aName select: [ :char | char isAlphaNumeric ] ) ) asSymbol ]
        ifFalse: [
                ( 'Set'
                , ( aName select: [ :char | char isAlphaNumeric ] )
                , ':'  ) asSymbol ]

!
pool: aPool
	"Private - Set the Smalltalk pool
    containing the style constant."

	value at: 2 put: aPool!  
style

    "Private - Answer the style constant."

    ^ value at: 1! 
supportedEditors

    "Answer all the editors currently supported
    by the receiver."

    ^Dictionary new
        at: 'color' put: #editorForColor;
        at: 'filename' put: #editorForFilename;
        at: 'font' put: #editorForFont;
        at: 'size window' put: #editorForFramingBlock;
        at: 'icon' put: #editorForIcon;
        at: 'bitmap' put: #editorForBitmap;
        "at: 'order children' put: #editorForOrderChildren;"  "not for runtime"
        yourself!  
nameForPartsOnly

    "Private - Property name for parts only properties."

    ^ '_partsOnly'!   
setValue: aValue for: anObject

    "Private - Set the value of the property."

    | anAction |
    ( anAction := self setAction )
        isNil ifTrue: [ ^ aValue ].
    ^ anAction evaluateWithArguments: ( Array with: aValue ).! 
validate: object integer: aNumber

    "Private - Validate <aNumber> for <object>.  If <aNumber>
    is not a number, convert it."

    aNumber isInteger
        ifTrue: [ ^ aNumber ]
        ifFalse: [ ^ aNumber asInteger]!   
format: aFormat

    "Set the format of the property.
    See supportedFormats in PropertyManager
    class for values of <aFormatString>"

    value at: 5 put: aFormat!   
defaultControl

    "Private - Answer the default control for
    this property when generating a dialog."

    ^ self editor isNil
        ifTrue: [
            self isBooleanFormat
                ifTrue: [ CheckBox ]
                ifFalse: [EntryField ]
            ]
        ifFalse: [ Button ]!  
isIntegerFormat

    "Private - Answer true if format is Integer."

    ^ self format = 'Integer'!
initialize
    "Private - initialization."
    value := Array new: 5!   
getPrimaryPropertiesFor: anObject

    "Answer a dictionary of associations of all primary (non-meta)
      property name and value pairs.  Depending on whether anObject
      is a part or not and include parts properties or not accordingly."

    | accessors properties |

    accessors := self getPrimaryAccessorsFor: anObject.
     properties := Dictionary new.
    accessors do: [ :accessor |
        properties add:
                (Association
                    key:  accessor key
                    value: ( accessor getValueFor: anObject ) )
        ].
    ^ properties! 
getAccessorsForPage: aPage
	"Private - Answer accessors for <aPage> sorted by their default
    controls used for data input."

	| accessors classes accessor |
	accessors := OrderedCollection new.
	aPage items
		do:
			[:name |
			accessor := self getAccessor: name ifAbsent: [ nil ].
			accessor isNil
				ifTrue: [ MessageBox warning: name, ' in page ', aPage label, ' is an invalid property name.' ]
				ifFalse: [ accessors add: accessor ] ].
	classes := Array
			with: EntryField
			with: CheckBox
			with: Button.
	^accessors
		asSortedCollection:
			[:a :b |
			(classes indexOf: a defaultControl) <= (classes indexOf: b defaultControl)].!
relayMessage: aSelector
arguments: arguments
	" Forward the message aSelector to value
        with the given arguments (an array of values). "

	| index value name editor oldValue newValue targetObject |
	index := setMessages indexOf: aSelector.
	index = 0
		ifTrue: [^self error: aSelector asString , ' is not a valid message'].
	name := propertyNames at: index.
	targetObject := propertyHandler getAccessor: name ifAbsent: [nil].
	((targetObject isKindOf: SelectorPropertyAccessor) and: [targetObject setAction respondsTo: #receiver])
		ifTrue: [targetObject := targetObject setAction receiver]
		ifFalse: [targetObject := self object].
	(propertyHandler hasEditorOfProperty: name)
		ifTrue:
			[editor := propertyHandler getEditorOfProperty: name.
			value := propertyHandler
					editProperty: name
					value: (self currentValueForProperty: name)
					for: targetObject "NEED to use the receiver of the link as the object in case like framingBlock"
					apply:
						(Message
							receiver: self
							selector: #apply:property:
							arguments: (Array with: nil with: name)).
			value isNil
				ifTrue: [^nil]. "If editor has the apply feature then it should return nil and use apply message
                to return values"
			self apply: value property: name.
			^value]
		ifFalse:
			[value := arguments first.
			newValue := propertyHandler
					validate: name
					with: value
					for: targetObject.
			oldValue := self currentValueForProperty: name.
			(oldValue ~= newValue or: [value ~~ newValue])
				ifTrue: [self setProperty: name to: newValue].
			value ~~ newValue "validator returned a different value"
				ifTrue: [self triggerEvent: (initEvents at: index) with: newValue].
			^newValue].
! 
propertyHandler

    "Answer the property handler associated
    with the object being edited."

    ^ propertyHandler!  
getNonPartsAccessors

    "Private - Answer a collection of accessors of all primary (non-meta)
      non-parts properties."

    | accessors partsProperties |
    accessors := OrderedCollection new.
    partsProperties := self getPropertyNamesInGroup: self nameForPartsOnly.
    self associationsDo: [ :assoc |
        ( partsProperties includes: assoc key ) ifFalse: [
            accessors add: assoc ].
        ].
    ^ accessors!
dragOperations: operations
    "Set drag operations to <operations>."

    dragOperations := operations!   
triggerInitEvents

    "Private - Trigger all the initializing events
    which are used to set the contents of the
    controls in the property dialog."

            self triggerEvent: #WindowTitle: with:
                ( self object partName isNil
                    ifTrue: [ self object asString ]
                    ifFalse: [ self object partName ]
                ) , ' properties'.

            1 to: initEvents size do: [ :index |
                self triggerEvent: ( initEvents at: index ) with: ( oldValues at: ( propertyNames at: index ) ) ].!   
name: aString get: getSelector set: setSelector
	"Create an Accessor with the name <aString>.
    The property is retrieved by <getSelector> which
    has 0 arguments and modified by <setSelector>
    which has 1 argument."

	^self
		new key: aString;
		get: getSelector;
		set: setSelector!  
image: anIcon

    "Set the image of the page to <anIcon>."

    image := anIcon! 
partDragSpec
	"Answer receiver's drag drop spec."

    ^ PARTSDragDropSpec new
		dragSource: self isDragSource;
		dragTarget: self isDragTarget;
		dragFormats: self dragTargetFormats;
		dragOperations: self dragTargetOperations;
		yourself!  
getProperties: propertyNames for: anObject

    "Answer a Dictionary of property name and value Associations
      for <propertyNames>."

    | dict |
    dict := Dictionary new.
    propertyNames do: [ :name |
        dict at: name put: ( self getProperty: name for: anObject ) ].
    ^ dict!
defaultControl

    "Private - Answer the default control for
    this property when generating a dialog."

    ^ RadioButton!   
editor

    "Private - If the subclass is capable of providing an editor
      then it should override this method. An editor can
      be any action or a part file name expecting
      one argument - the object containing the property."

    ^ nil!  
metaPropertiesCreateIfNil

    "Private - Answer meta properties.  Create the meta
    property handler if it is nil."

    metaProperties isNil
        ifTrue: [ metaProperties := PropertyManager new ].
    ^ metaProperties!  
validate: object boolean: aBoolean

    "Private - Validate <aBoolean> for <object>.  If <aBoolean>
    is not a boolean, convert it."

    aBoolean isBoolean
        ifTrue: [ ^ aBoolean ]
        ifFalse: [ ^ false ]!
setValue: aBoolean
for: anObject
	"Private - Set the value of the property."

	| style mask |
	self pool at: self style ifAbsent: [^self error: 'Unknown style']. "error checking"
	style := anObject style.
	style isNil
		ifTrue: [style := anObject getStyle].
	mask := self mask.
	style := (style bitOr: mask) bitXor: mask. "clear by the mask"
	aBoolean
		ifTrue: [
			style := style bitOr: (self pool at: self style).
			anObject setStyle: style "force the new style to show up" ]!
editorForDragDrop
    "Answer the editor for drag drop spec."

    ^ Message receiver: self selector: #edit:dragDrop:! 
editProperty: name value: oldValue for: anObject

    "Edit a specific property with its built-in editor.
      The property's current value is <oldValue>."

    ^ ( self associationAt: name ) edit: oldValue for: anObject!   
setProperty: name to: value

    "Private - Set property <name> to <value> in newValues."

    newValues at: name put: value.
    self triggerEvent: #changed!   
constructEventsTriggered

        "Private - Construct the set of events triggered by instances
        of the receiver."

    ^super constructEventsTriggered
        add: #WindowTitle: ;
        yourself!  
initialize
    "Private - initialization."
    value := Array new: 3!   
setInterface: anObject

    "Private - Set up interfaces between the edited object and
    its property dialog."

    | propertyName |
    object := anObject.
    object isNil ifTrue: [ ^ self ].  "path for clearing object"
    propertyHandler := object propertyManager.
    propertyHandler isNil ifTrue: [
        ^ self error: 'Property handler was not constructed for ', object printString ].
    propertyNames := OrderedCollection new.
    initEvents := OrderedCollection new.
    setMessages := OrderedCollection new.
    ( propertyHandler getPrimaryAccessorsFor: anObject ) do: [ :accessor |
        propertyName := accessor key.
        propertyNames add: propertyName.
        initEvents add: ( self createInitEvent: propertyName ).
        setMessages add: ( self createSetMessage: propertyName ).
        ].! 
edit: anObject
dragDrop: aDragDropSpec
	"Private - Edit the drag drop spec <aDragDropSpec> for <anObject>."

	| app appHolder newFormats |
	appHolder := PARTSApplicationHolder on: 'dragdrop'.
	app := appHolder application.
	app isNil
		ifTrue: [^self error: 'dragdrop.par is missing'].
	app
		defaultUnusedFormats:
			(DragDropObject partAllImplementedFormats
			reject:
				[:x |
				anObject partDragTargetFormatsDefault includes: x]).
	app defaultFormats: (anObject partDragTargetFormatsDefault).
	app defaultAllOperations: (DragDropObject partAllImplementedOperations).
	app defaultOperations: (anObject partDragTargetOperationsDefault).
	app defaultSource: false.
	app defaultTarget: false.
	app source: aDragDropSpec dragSource.
	app target: aDragDropSpec dragTarget.
	app
		formats:
			(newFormats := (aDragDropSpec dragFormats) isNil
			ifTrue: [anObject partDragTargetFormatsDefault]
			ifFalse: [aDragDropSpec dragFormats]).
	app
		unusedFormats:
			(DragDropObject partAllImplementedFormats
			reject:
				[:x |
				newFormats includes: x]).
	app
		operations:
			((aDragDropSpec dragOperations) isNil
			ifTrue: [anObject partDragTargetOperationsDefault]
			ifFalse: [aDragDropSpec dragOperations])
		andAllOperations: (DragDropObject partAllImplementedOperations).
	app open.
	app commitChanges
		ifTrue:
			[^PARTSDragDropSpec
				new dragSource: app source;
				dragTarget: app target;
				dragFormats: app formats;
				dragOperations: app operations asArray;
				yourself]
		ifFalse:
			[^aDragDropSpec].
	! 
setValue: aValue for: anObject

    "Private - Set the value of the property."

    ^ value := aValue!
defaultControlForPart

    "Private - Answer the default control for
    this property when generating a dialog
    in the parts workbench."

    ^ Smalltalk at: #PARTSCheckBoxPart!   
setPropertiesNoValidate: propertyDict for: anObject

    "Set properties contained in <propertyDict> without validation.
    The group of properties for order will be observed."

    | orderedProperties association |

    orderedProperties := self getProperty: self nameForOrder for: anObject ifAbsent: [ nil ].
    orderedProperties size > 0
        ifTrue: [
            orderedProperties do: [ :name |
                association := propertyDict associationAt: name ifAbsent: [ nil ]. "don't use 'at:' since value can be nil"
                association notNil ifTrue: [ self setPropertyNoValidate: association key to: association value for: anObject ]
                ].
            propertyDict associationsDo: [ :assoc |
                ( orderedProperties includes: assoc key ) ifFalse: [
                    self setPropertyNoValidate: assoc key to: assoc value for: anObject ] ]
            ]
        ifFalse: [
            propertyDict associationsDo: [ :assoc |
                self setPropertyNoValidate: assoc key to: assoc value for: anObject ].
            ].
    self runEpilog: propertyDict for: anObject.! 
editorForOrderChildren

   "Answer the editor for ordering child controls."

    ^ Message receiver: self selector: #edit:orderChildren:! 
mask: bits
	"Private - Set the style mask which
	is needed when the style constant
	is a number (e.g. 5) instead of a bit."

	value at: 3 put: bits! 
getValueFor: anObject

    "Private - Answer true if the style property is on."

    ^ anObject hasStyle: ( self pool at: self style ifAbsent: [ ^self error: 'Unknown style' ])! 
initValues
    "Private - Initialize oldValues and newValues."

    newValues := Dictionary new.
    oldValues := propertyHandler getPrimaryPropertiesFor: object.!   
initialState: anObject

    "Private - Set the object whose properties are being edited and initialize its states."

    self setInterface: anObject.
    self initValues!   
groupPartsOnlyAddList: propertyNameList

    "Add <propertyNameList> as properties only applied to a part.
    A part is defined as having a part wrapper."

    self groupAt: self nameForPartsOnly addList: propertyNameList!  
defaultControlForPart

    "Private - Answer the default control for
    this property when generating a dialog
    in the parts workbench."

    ^ self editor isNil
        ifTrue: [
            PropertyManager supportedFormats at: self format
                ifAbsent: [ Smalltalk at: #PARTSEntryFieldPart ]
            ]
        ifFalse: [ Smalltalk at: #PARTSPushButtonPart ]!   
defaultControl

    "Private - Answer the default control for
    this property when generating a dialog."

    ^ CheckBox!  
pool

    "Private - Answer the Smalltalk pool
    containing the style constant."

    ^ value at: 2!   
currentValueForProperty: name

    "Private - Answer the current value for property <name>."

    ^ newValues at: name ifAbsent: [ oldValues at: name ifAbsent: [ nil ] ]!
addGroupValidator: aValidator

    "Add <aValidator> as the validator for all the properties.
    it must be a selector with 1 argument: a Dictionary of
    property names and values.  This is usually used when
    the group of properties has ordering dependencies."

    ( aValidator occurrencesOf: $: ) = 1
        ifFalse: [ ^ self error: 'A validator selector must have 1 argument for property dictionary' ].
    self metaPropertiesCreateIfNil add: (
        ObjectPropertyAccessor
            name: self nameForGroupValidator
            object: aValidator )!  
propertyNames: names

    "Private - Set all the property names
    for the edited object."

    propertyNames := names! 
initialize
    "Private - initialization."
    value := Array new: 2!   
groupValidate: propertyDict for: anObject

    "Invoke the specified group validator to validate properties
    in <propertyDict> for <anObject>.  Answer true if the validation
    is passed or the group validator is not specified in the receiver."

    ^ anObject
        perform: ( self getProperty: self nameForGroupValidator for: anObject ifAbsent: [ ^ true ] )  "true if no validator"
        withArguments: ( Array with: propertyDict )!
performAction: anAction object: anObject arguments: arguments
    "Private - external.
	Perform <anAction> for <anObject> with <arguments>.  <anAction>
    can be a selector, a Parts file name, or any ActionSequence."

    | app args |
    anAction isNil ifTrue: [ ^nil ].
    "anAction isClass
        ifTrue: [ ^ anAction new openOn: anObject with: arguments ]."
    anAction isSymbol
        ifTrue: [
            args := Message numberOfArgumentsFor: anAction.
            ^ anObject perform: anAction withArguments: (
                args = 0
                    ifTrue: [ nil ]
                    ifFalse: [ arguments copyFrom: 1 to: args ] ) ].
    anAction isString
        ifTrue: [
            app := ( Smalltalk at: #PARTSApplication
                ifAbsent: [ ^ self error: 'Since a String represents a part file, class PARTSApplication must exist' ] )
                     fromFile: anAction.
            app isNil ifTrue: [ ^self error: 'File ', anAction, ' can not be loaded' ].
            ^ app openOn: anObject.
            ].
    ( anAction respondsTo: #asActionSequence )
        ifTrue: [
                ^anAction asActionSequence
                    evaluateWithArguments: (Array with: anObject), arguments ]! 
defaultControlForPart

    "Private - Answer the default control for
    this property when generating a dialog
    in the parts workbench."

    ^ Smalltalk at: #PARTSRadioButtonPart!
canTriggerEvent: anEvent

    "Answer true if receiver can trigger <anEvent>."

    ( self initEvents, #( #WindowTitle: #changed #stored )  includes: anEvent )
        ifFalse: [ ^ super canTriggerEvent: anEvent ].
    ^ true!  
openOn: initialState

    "Build and open a window for a new instance of the receiver viewing
    the <initialState> object."

    | coordinator |
    coordinator := self new.
    coordinator initialState: initialState.
    self open: coordinator.
    "coordinator object: initialState."  "get/set values for controls"
    ^coordinator!
removeProperty: name

    "Remove the property with <name>."

    ^ self removeProperty: name ifAbsent: []!   
edit: propertyValue for: anObject apply: applyMessage

    "Private - Invoke editor on <propertyValue>.
      An editor can be any action supported by class PropertyHandler."

    | editor |
    ( editor := self editor )
        isNil ifTrue: [ ^nil ].
    ^ PropertyManager performAction: editor object: anObject arguments: (Array with: propertyValue with: applyMessage).! 
addPage: aPropertyPage

    "Add a property page <aPropertyPage>.
      Note that page info is only useful for default property
      editor since a customized editor would construct its
      own page layout."

    ( aPropertyPage isKindOf: PropertyPage )
        ifFalse: [ ^ self error: 'A page must be kind of PropertyPage' ].
    self groupAt: self nameForPage addList: ( Array with: aPropertyPage ).!   
validatorForPartName

    "Answer the validator for a Part name."

    ^ Message receiver: self selector: #validate:partName:!
getValueFor: anObject

    "Private - Answer the value of the property."

    | anAction |
    ( anAction := self getAction )
        isNil ifTrue: [ ^ nil ].
    ^ anAction evaluateWithArguments: #( ).!
description
    "Answer the description of the page."

    ^ description!  
dragTarget: aBoolean
    "Set dragTarget to aBoolean."

    dragTarget := aBoolean!
nameForPage

    "Private - Property name for page info."

    ^ '_page'! 
buildView: aView forModel: aCoordinator

    "Create the structure of the window <aView> for the application <aCoordinator>."

    | accessors controls control inset cancelButton okButton applyButton font nameIndex buttonWidth |

    accessors := aCoordinator object propertyManager
        getAccessorsSortedByControlFor: aCoordinator object.
    controls := OrderedCollection new: accessors size.
    inset := 10 @ 8.
    accessors do: [ :accessor |
        controls add: ( self controlFor: accessor inset: inset view: aView ).  "inset  is bumped"
        ].
    font := Button defaultFont.
    buttonWidth := ( font stringWidth: 'Cancel' ) + 8.
    inset y: inset y + 8.   "leave a gap"
    aView addPane: ( (okButton := Button new )
        defaultPushButton;
        label: 'OK';
        layoutFrame: (LayoutFrame new
                        topLeftInset: inset;
                        bottomRightInset: (inset +
                            ( buttonWidth @ ( font height + 8 ) ) ) negated );
        when: #clicked send: #storePropertyValues to: aCoordinator;
        when: #clicked send: #close to: aView;
        yourself ).
    inset x: ( inset x + ( font stringWidth: 'Cancel' ) + 8 + 8 ).
    aView addPane: ( (cancelButton := Button new )
        label: 'Cancel';
        layoutFrame: (LayoutFrame new
                        topLeftInset: inset;
                        bottomRightInset: (inset +
                            ( buttonWidth @ ( font height + 8 ) ) ) negated );
        when: #clicked send: #close to: aView;
        yourself ).

    inset x: ( inset x + ( font stringWidth: 'Cancel' ) + 8 + 8 ).
    aView addPane: ( (applyButton := Button new )
        label: 'Apply';
        layoutFrame: (LayoutFrame new
                        topLeftInset: inset;
                        bottomRightInset: (inset +
                            ( buttonWidth @ ( font height + 8 ) ) ) negated );
        disable;
        when: #clicked send: #storePropertyValues to: aCoordinator;
        yourself ).

    aCoordinator when: #changed send: #enable to: applyButton;
        when: #stored send: #disable to: applyButton.

    aView initialSize: ( (buttonWidth * 5) @ (controls size + 2 * ( Button defaultFont height + 16 ) + 16 )).
    1 to: accessors size do: [ :index |
        nameIndex := aCoordinator propertyNames indexOf: ( accessors at: index ) key.
        control := controls at: index.
        control isPushButton ifFalse: [
            aCoordinator when: ( aCoordinator initEvents at: nameIndex ) send: #setValue: to: control ].
        control
            when: ( control isButton
                ifTrue: [
                    control isPushButton
                        ifTrue: [ #clicked ]
                        ifFalse: [ #clicked: ] ]
                ifFalse: [ #changed: ] )
            send: ( aCoordinator setMessages at: nameIndex )
            to: aCoordinator ].
    aCoordinator triggerInitEvents.!  
edit: anObject font: aFont

    "Private - Edit the font <aFont> for <anObject>."

    ^ FontDialog new
                sampleFont: aFont;
                open;
                chosen!   
getAction

    "Private - Answer the action for retrieving the property."

    ^ value at: 1! 
get: anAction

    "Set the action for retrieving the property."

    value at: 1 put: anAction!  
validator: anAction

    "Set the validator of the property to <anAction>."

    value at: 4 put: anAction!   
epilog: anAction

    "Send <anAction> to the object after storing a group
    of properties (not for single property store).
    <anAction> must have one argument which will be a
    Dictionary of property names and values just stored.
    Note that there is not a prolog which can be accomplished
    by providing a group validator."

    self metaPropertiesCreateIfNil add: (
        ObjectPropertyAccessor
            name: self nameForEpilog
            object: anAction )!
dragFormats
    "Answer drag formats."

    ^ dragFormats! 
validator

    "Private - If the subclass is capable of providing a validator
      (which has 2 arguments: new value and object containing
      the property) then it should override this method."

    ^ nil!   
new

    "Create an instance of the receiver."

    ^ super new initialize!   
storeOn: aStream

        "Append the ASCII representation of the
         receiver to aStream from which the
         receiver can be reinstantiated."

    aStream nextPutAll: self class name, ' key: ('.
    key storeOn: aStream.
    aStream nextPutAll: ') value: ('.
    value storeOn: aStream.
    aStream nextPut: $)!   
dragOperations
    "Answer drag operations."

    ^ dragOperations!
addNames: propertyNames toPage: pageLabel
	"Add <propertyNames> to the page with <pageLabel>.
	Create the page if not existing."

	| page |
	page := self getPages detect: [ :aPage | aPage label = pageLabel ]
		ifNone: [ self addPage: ( page := PropertyPage new label: pageLabel ). page ].
	page addItems: propertyNames.!   
getAccessorsSortedByControlFor: anObject

    "Private - Answer primary accessors sorted by their default
    controls used for data input."

    | accessors classes |

    accessors := self getPrimaryAccessorsFor: anObject.
    classes := Array with: EntryField with: CheckBox with: Button.
    ^ accessors asSortedCollection: [:a :b |
        ( classes indexOf: a defaultControl ) <= ( classes indexOf: b defaultControl ) ].! 
setAction

    "Private - Answer the action for storing the property to <anAction>."

    ^ value at: 2!  
isBooleanFormat

    "Private - Answer true if format is Boolean."

    ^ self format = 'Boolean'!
removeList: aCollection

    "Remove <aCollection> of members to the group."

    value isNil
        ifTrue: [ ^ self ].
	( value first isKindOf: PropertyPage )
		ifTrue: [
			aCollection do: [ :element |
				value do: [ :page |
					page removeItem: element ] ] ]
		ifFalse: [
    			aCollection do: [ :element |
        			value remove: element ifAbsent: [] ] ]!
partRealSelectorFor: aSelector
        " Answer the real message to send to the receiver
        for aSelector.  If aSelector isn't part of
        the container's own protocol, map it to the
        relay method which forwards it to the
        contained value. "

    ^( self respondsTo: aSelector)
        ifTrue: [ aSelector ]
        ifFalse: [ #relayMessage:arguments: ]!
validatorForBoolean

    "Answer the validator for a boolean."

    ^ Message receiver: self selector: #validate:boolean:!
getAccessor: propertyName ifAbsent: aBlock

    "Private - Answer the accessor for <propertyName>.
    Evaluate <aBlock> if the accessor is missing."

    ^  ( self associationAt: propertyName ifAbsent: [
        metaProperties isNil
            ifTrue: [ ^ aBlock value ]
            ifFalse: [ ^ metaProperties getAccessor: propertyName ifAbsent: aBlock ]

        "^ aBlock value"
            ]
        )!  
dragSource
    "Answer true if can be the source of a drag."

    ^ dragSource!
partGetWindowSize
        "Get the receiver's framing specification
        as an Array of PARTSFramer and parent Rectangle."

    ^ Array with: self framingBlock with:
        ( self superWindow isNil
            ifTrue: [ Display boundingBox ]
            ifFalse: [ self superWindow freeClientArea ] )
!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    "During edit time, the propertyInterface will be
    reinitiated; during runtime, it is reset with the real object"
    object notNil ifTrue: [ aMirrorCopyDictionary at: object put: nil ].
    oldValues notNil ifTrue: [ aMirrorCopyDictionary at: oldValues put: nil ].
    newValues notNil ifTrue: [ aMirrorCopyDictionary at: newValues put: nil ].
    propertyHandler notNil ifTrue: [ aMirrorCopyDictionary at: propertyHandler put: nil ].

    ^super partMirrorCopyReal: aMirrorCopyDictionary.! 
getEditorOfProperty: propertyName

    "Private - Answer the editor of <propertyName>."

    ^ ( self getAccessor: propertyName ifAbsent: [ ^ nil ] ) editor! 
setMessages

    "Private - Answer all the messages for
    setting the property values."

    ^ setMessages isNil
        ifTrue: [ Array new ]
        ifFalse: [ setMessages ]! 
getValueFor: anObject

    "Private - Answer true if the style property is on."

    | flags |
    flags := anObject style isNil ifTrue: [ anObject getStyle ] ifFalse: [ anObject style ].
    ^( flags bitAnd: self mask ) = ( self pool at: self style ifAbsent: [ ^self error: 'Unknown style' ])!  
propertyManagerDefaultEditor

    "Open the default property editor for the receiver."

    "PropertyInterface openOn: self"
    MessageBox message: 'Editor was not defined.'
!
partDragSpec: aDragDropSpec
	"Set receiver's drag drop spec to <aDragDropSpec>."

    self dragSource: aDragDropSpec dragSource;
		dragTarget: aDragDropSpec dragTarget;
		dragTargetFormats: aDragDropSpec dragFormats;
		dragTargetOperations: aDragDropSpec dragOperations!  
createInitEvent: aName
    "Private - Create an event for property <aName>.
    It passes the property's current value as an
    argument.  The event name is prefixed with 'Init'."

    ^ ( 'Init',
            ( aName select: [ :char | char isAlphaNumeric ] ),
            ':'  )
                asSymbol
!   
newValues

    "Private - Answer all the modified property values."

    ^ newValues! 
orderAccessors: accessors
	"Private - Order <accessors> according to the order group spec."

    |  orderedProperties newAccessors match |

    newAccessors := OrderedCollection new.
    orderedProperties := self getProperty: self nameForOrder for: nil ifAbsent: [ nil ].
    orderedProperties size > 0
        ifTrue: [
            orderedProperties do: [ :name |
				match := accessors detect: [:acc | acc name = name ] ifNone: [nil].
				match notNil ifTrue: [ newAccessors add: match ] ].
                ]
		ifFalse: [ ^ accessors ].


    accessors do: [ :acc |
		( newAccessors includes: acc ) ifFalse: [ 
        		newAccessors add: acc ]
        ].
    ^ newAccessors! 
getProperty: propertyName for: anObject

    "Answer the property value of <propertyName> for <anObject>."

    ^ self getProperty: propertyName for: anObject ifAbsent: [ nil ]! 
setProperty: propertyName to: value for: anObject

    "After validating, set property with propertyName to value."

    | newValue |
     newValue := self validate: propertyName with: value for: anObject.
    self setPropertyNoValidate: propertyName to: newValue for: anObject!  
cacheHandler: aHandler forClass: aClass

    "Private - Cache the property handler <aHandler> for class <aClass>."

    CachedHandlers isNil
        ifTrue: [ CachedHandlers := IdentityDictionary new ].
    CachedHandlers at: aClass put: aHandler.
    ^ aHandler!
edit: anObject filename: aFilename

    "Private - Edit the filename <aFilename> for <anObject>."

    ^FileDialog new
        openFile: aFilename;
        file!   
getPropertyNamesInGroup: groupName

    "Answer an array of property names contained in group <groupName>."

    ^ self metaProperties getProperty: groupName for: nil ifAbsent:
        [ ^ Array new ]!
editorForIcon

   "Answer the editor for changing icon."

    ^ Message receiver: self selector: #edit:icon:apply:!   
editorForColor

    "Answer the editor for changing color."

    ^ Message receiver: self selector: #edit:color:! 
validate: object number: aNumber

    "Private - Validate <aNumber> for <object>.  If <aNumber>
    is not a number, convert it."

    aNumber isNumber
        ifTrue: [ ^ aNumber ]
        ifFalse: [ ^ aNumber asNumber ]! 
label
    "Answer the label of the page."

    ^ label!
removeItem: aName

    "Remove the property <aName> from the page."

    items remove: aName ifAbsent: []!
propertyNames

    "Private - Answer all the property names
    for the edited object."

    ^ propertyNames!
getPrimaryAccessorsFor: anObject
    "Private - Answer a collection of accessors of all primary (non-meta)
      properties.  Depending on whether anObject
      is a part or not and include it or not accordingly."

    | accessors |

    (( anObject respondsTo: #partWrapper ) and:   "This is needed since #partWrapper not available at runtime"
    [ anObject partWrapper isNil ] ) ifTrue: [  "non-parts"
        ^ self orderAccessors: self getNonPartsAccessors ].

    accessors := OrderedCollection new.
    self associationsDo: [ :assoc |
        accessors add: assoc
        ].
    ^ self orderAccessors: accessors!   
setPropertyNoValidate: propertyName to: value for: anObject

    "Private - Set property with propertyName to value.  No validating."

    ( self getAccessor: propertyName ifAbsent: [ ^ self error: 'property does not exist' ] )
        setValue: value for: anObject!   
storePropertyValues
    "Store the modified property values back into the
    edited object after the property dialog is either
    finished or applied."

    | changedOldValues theObject |
    newValues size = 0
        ifTrue: [^nil].
    theObject := self object.
    (theObject isPARTSApplication and: [theObject isNestedApplication])
        ifTrue:
            [ "properties must be stored in nested part.  Also in order
                to sync up with other edits in the nested part, the PropertyStructure
                has to be accomodated."
            [ propertyHandler
                groupValidate: newValues for: theObject ]
            on: Error do: [ :e | 
				MessageBox warning: e messageText.
				^ self ].
            theObject "partWrapper" parent "object" "nested part" applyProperties: newValues.
            ]
        ifFalse:
            [changedOldValues := newValues class new.
            newValues
                keysDo:
                    [:name |
                    changedOldValues add: (oldValues associationAt: name)].
            ( propertyHandler setProperties: newValues for: theObject )
			ifFalse: [ ^ self ].
            theObject partIsEditing
                ifTrue:
                    [theObject partEditor
                            recordUndo:
                                (Message new
                                receiver: propertyHandler
                                selector: #setProperties:for:
                                arguments: (Array with: changedOldValues with: theObject))
                            undoLabel: 'property changes'
                            redo:
                                (Message new
                                    receiver: propertyHandler
                                    selector: #setProperties:for:
                                    arguments: (Array with: newValues with: theObject))
                            redoLabel: 'property changes']].
    self triggerEvent: #stored.
    self initValues
! 
name

    "Answer the property name."

    ^ key! 
editor: anAction

    "Set the editor for the property."

    value at: 3 put: anAction!  
initEvents

    "Private - Answer all the initializing events."

    ^ initEvents isNil
        ifTrue: [ Array new ]
        ifFalse: [ initEvents ]!  
edit: anObject color: aColor

    "Private - Edit the color <aColor> for <anObject>."

    ^ ColorDialog new openOn: aColor; chosen!  
initialize

    "Private - Default is to do nothing."!  
editorForBitmap

   "Answer the editor for changing bitmap."

    ^ Message receiver: self selector: #edit:bitmap:apply:! 
partSetWindowSize: resizeInfo
    "Set the receiver's framing specification
        to aPARTSFramer and resize accordingly."

    | aPARTSFramer |
    aPARTSFramer := resizeInfo at: 1.
    self framingBlock: aPARTSFramer.
    rectangle := nil.  "other main window won't use framingBlock"
    self partWrapper rectangle: aPARTSFramer.
    (self superWindow isWindow and: [self isValid])
        ifTrue:
            [self
                resize: self superWindow freeClientArea;
                bringToTop;
                updateWindow.
            ].
!   
setProperties: propertyDict for: anObject
    "After validating, set properties contained in <propertyDict>.
      Answer true if properties are set, otherwise false."

    [ propertyDict associationsDo: [ :assoc |
            assoc value: ( self validate: assoc key with: assoc value for: anObject ) ].
      self groupValidate: propertyDict for: anObject ]
            on: Error do: [ :e | 
				MessageBox warning: e messageText.
				^false ].

    self setPropertiesNoValidate: propertyDict for: anObject.
    ^true!   
defaultControlForPart

    "Private - Answer the default control for
    this property when generating a dialog
    in the parts workbench."

    ^ self editor isNil
        ifTrue: [
            PropertyManager supportedFormats at: self format
                ifAbsent: [ Smalltalk at: #PARTSEntryFieldPart ]
            ]
        ifFalse: [ Smalltalk at: #PARTSPushButtonPart ]!   
setValue: aBoolean for: anObject

    "Private - Set the value of the property."
    aBoolean
        ifTrue: [ anObject addStyle: ( self pool at: self style ifAbsent: [ ^self error: 'Unknown style' ] ) ]
        ifFalse: [ anObject removeStyle: ( self pool at: self style ifAbsent: [ ^self error: 'Unknown style' ] ) ].
    anObject setStyle: anObject style   "force the new style to show up"!  
runEpilog: propertyDict for: anObject

    "Private - Execute the epilog action if there is one.
    <propertyDict> is a dictionary of property name
    and value pairs just stored into the object"

    ( self metaProperties includesKey: self nameForEpilog )
        ifTrue: [
            self class performAction: ( self getProperty: self nameForEpilog for: anObject )
                object: anObject
                arguments: ( Array with: propertyDict )
            ]!  
setMessages: messages

    "Private - Set all the messages for
    setting the property values."

    setMessages := messages!   
isGroupPropertyAccessor

    "Answer false unless the receiver is a group property.
    Note that this method is not in class Object since
    all elements in a PropertyManager must be kind
    of PropertyAccessor."

    ^ false!  
defaultControl

    "Private - Answer the default control for
    this property when generating a dialog."

    ^ EntryField!
groupAt: groupName addList: aList

    "Add <aList> of property names to group <groupName>.
    A group is maintained as a meta property."

    | accessor newAccessor |
    accessor := self metaPropertiesCreateIfNil getAccessor: groupName
        ifAbsent: [
            metaProperties add:
                (newAccessor := GroupPropertyAccessor new
                    name: groupName ).
            newAccessor
            ].
    accessor addList: aList!  
edit: object bitmap: aBitmap apply: applyMessage

    "Private - Edit the icon <aBitmap> for <object>.  When
    the 'apply' button is pressed, evaluate <applyMessage>."

    | clone |
    Smalltalk at: #PARTSBitEditor ifAbsent: [ ^self error: 'Edit bitmap is a PARTS editing time function' ].
    aBitmap isNil
        ifTrue: [ clone := Bitmap screenExtent: Icon iconSize ]
        ifFalse: [ clone := aBitmap clone ].
    (Smalltalk at: #PARTSBitEditor) new
        openOn: clone saveBlock:
            [ applyMessage evaluateWithArguments: ( Array with: clone ) ].
    ^ nil   "result is handled thru applyMessage"!  
supportedValidators

    "Answer all the validators currently supported
    by the receiver."

    ^ Dictionary new
        at: 'Number' put: #validatorForNumber;
        at: 'Integer' put: #validatorForInteger;
        at: 'Boolean' put: #validatorForBoolean;
        at: 'PartName' put: #validatorForPartName;
        yourself!   
dragFormats: formats
    "Set drag formats to <formats>."

    dragFormats := formats! 
isGroupPropertyAccessor

    "Answer true."

    ^ true!  
hasEditorOfProperty: propertyName

    "Private - Answer true if property of <propertyName> has
      a designated editor."

    ^ ( self getEditorOfProperty: propertyName ) notNil!
initiator: anInitiator

    "Set the initiator who supplied the 'object'."

    initiator := anInitiator! 
nameForOrder

    "Private - Property name for ordering properties."

    ^ '_order'! 
name: aString

    "Set the property name to <aString>."

    key := aString! 
editFor: anObject
	"Open the specified group editor to edit all properties of <anObject>.
    If an editor is not specified, use the default one."

	| editor |
	editor := self getGroupEditor.
	editor isNil
		ifTrue: [editor := #propertyManagerDefaultEditor].
	^PropertyManager
			performAction: editor
			object: anObject
			arguments: nil.!  
style: styleConstant
	"Private - Set the style constant."

	value at: 1 put: styleConstant!
validatorForNumber

    "Answer the validator for a number object."

    ^ Message receiver: self selector: #validate:number:!
editorForFramingBlock

   "Answer the editor for changing the framing block."

    ^ Message receiver: self selector: #edit:framingBlock:!
validatorForInteger

    "Answer the validator for an integer."

    ^ Message receiver: self selector: #validate:integer:!   
apply: value property: name

    "The property <name> is being or has been edited by a built-in
      editor which triggered an #apply event."

    | index newValue |
    index := propertyNames indexOf: name.
    newValue := propertyHandler validate: name with: value for: self object.
    self setProperty: name to: newValue.
    self triggerEvent: ( initEvents at: index ) with: newValue.  "Since app may
                        need to show the result, e.g. icon"! 
metaProperties
    "Answer the property manager for meta properties.
      If metaProperties is nil, answer an empty
      PropertyManager but don't store it back in metaProperties."

    metaProperties isNil
        ifTrue: [ ^ PropertyManager new ].
    ^ metaProperties!  
getProperty: propertyName for: anObject ifAbsent: aBlock

    "Answer the property value of <propertyName> for <anObject>.
    Evaluate <aBlock> if the porperty is missing."

    ^ ( self getAccessor: propertyName ifAbsent: [ ^ aBlock value ] )
                getValueFor: anObject! 
name: aString get: getSelector set: setSelector editor: anEditor
    "Create an Accessor with the name <aString>.
    The property is retrieved by <getSelector> which
    has 0 arguments and modified by <setSelector>
    which has 1 argument. <anEditor> is used to
    edit the property value."

	^self
		new key: aString;
		get: getSelector;
		set: setSelector;
		editor: anEditor! 
groupAt: groupName removeList: aList

    "Remove <aList> of property names from group <groupName>.
    A group is maintained as a meta property."

    | accessor |
    accessor := self metaPropertiesCreateIfNil getAccessor: groupName
        ifAbsent: [ ^ self ].
    accessor removeList: aList!  
getValueFor: anObject

    "Private - Answer the value of the property."

    self implementedBySubclass! 
editorForFilename

   "Answer the editor for changing file."

    ^ Message receiver: self selector: #edit:filename:! 
nameForGroupEditor

    "Private - Property name for the group editor."

    ^ '_groupEditor'!
name: aString get: getSelector set: setSelector editor: anEditor validator: aValidator format: formatString
	"Create an Accessor with the name <aString>.
	The property is retrieved by <getSelector> which
	has 0 arguments and modified by <setSelector>
	which has 1 argument. <anEditor> and <aValidator> are used to
	edit and validate the property value. <format> is used to
	generate the right kind of control for editing the property."

	^self
		new key: aString;
		get: getSelector;
		set: setSelector;
		editor: anEditor;
		validator: aValidator;
		format: formatString!
nameForEpilog

    "Private - Property name for after-store-values."

    ^ '_epilog'!
removeProperty: name ifAbsent: aBlock

    "Remove property with <name> from the receiver and
      group properties containing it.  Evaluate <aBlock> if
      the property is missing."

    | answer |
    answer := self removeKey: name ifAbsent: [
        metaProperties isNil
            ifTrue: [ ^ aBlock value ]
            ifFalse: [ metaProperties removeProperty: name ifAbsent: aBlock ] ].

    self metaProperties associationsDo: [:accessor |
        accessor isGroupPropertyAccessor
            ifTrue: [ accessor removeList: ( Array with: name ) ]
        ].

    ^ answer! 
validate: propertyName with: value for: anObject

    " Raise an error if <value> is not valid.  Otherwise return
      <value> or the recommended value if there is one from the validator."

    | accessor |
    accessor := self getAccessor: propertyName ifAbsent:
        [ ^ self error: 'Property ', propertyName, '  does not exist' ].
    ^ [ accessor validate: value for: anObject ] on: Error do:
            [ ^ self error: 'Invalid value, ', value asString, ', for property, ', propertyName ]!  
edit: object icon: anIcon apply: applyMessage

    "Private - Edit the icon <anIcon> for <object>.  When
    the 'apply' button is pressed, evaluate <applyMessage>."

    | clone |
    Smalltalk at: #PARTSIconEditor ifAbsent: [ ^self error: 'Edit icon is a PARTS only function' ].
    anIcon isNil
        ifTrue: [ clone := (Smalltalk at: #PARTSIcon) fromBitmap: (Bitmap screenExtent: Icon iconSize) ]
        ifFalse: [ clone := anIcon clone ].
    (Smalltalk at: #PARTSIconEditor) new
        openOn: clone saveBlock:
            [ applyMessage evaluateWithArguments: ( Array with: clone ) ].
    ^ nil   "result is handled thru applyMessage"!   
addList: aCollection

    "Add <aCollection> of members to the group."

    value isNil
        ifTrue: [ value := OrderedCollection new ].
    value addAll: aCollection!  
propertyNames

    "Answer all the primary property names."

    ^ self keysAsArray!  
propertyManager

    "Answer the property manager for the receiver."

    "Since the manager is now only used in editing time, cache is not needed"
    " ^ PropertyManager cachedHandlers
        at: self class
        ifAbsent: [
            PropertyHandler
                cacheHandler: self class constructPropertyManager
                forClass: self class ]"

    ^ self class constructPropertyManager!   
groupOrderAddList: propertyNameList

    "Add <propertyNameList> as properties whose
    sequence must be followed during storing time."

    self groupAt: self nameForOrder addList: propertyNameList! 
validate: newValue for: anObject

    "Private - Validate newValue for anObject."

    | validator |
    validator := self validator.
    validator isNil ifTrue: [ ^newValue ].  "no validator, ok"
    ^ PropertyManager performAction: validator object: anObject arguments: ( Array with: newValue ).! 
getGroupEditor

    "Private - Answer an editor for editting all properties."

    ^ self metaProperties getProperty: self nameForGroupEditor for: nil.!  
controlFor: accessor inset: inset view: aView

    "Private - Create the control for the <accessor>
    in <aView> dialog. <inset> is its location."

    | control font origin |
    control := accessor defaultControl new.
    font := control font.
    font isNil ifTrue: [ font := control defaultFont ].
    control class == EntryField
        ifTrue: [
            aView addPane: (
                StaticText new
                    value: accessor key;
                    layoutFrame: (LayoutFrame new
                        topLeftInset: inset;
                        bottomRightInset: ( inset +
                             ( ( font stringWidth: accessor key ) + 4
                            @ ( font height + 8 ) ) ) negated );
                    yourself ).
            aView addPane: (
                control
                    value: accessor key;
                    layoutFrame: (LayoutFrame new
                        topLeftInset: ( origin := inset + ( ( font stringWidth: accessor key ) + 4 @ 0 ) );
                        bottomRightInset: ( origin +
                            ( ( font charSize x * 15 ) + 4
                            @ ( font height + 8 ) ) ) negated );
                    yourself ).
            ]
        ifFalse: [
            aView addPane: (
                control
                    label: accessor key;
                    layoutFrame: (LayoutFrame new
                        topLeftInset: inset;
                        bottomRightInset: (inset +
                            ( ( font stringWidth: accessor key ) +
                                        ( control isPushButton
                                            ifTrue: [ 8 ]
                                            ifFalse: [ SysFont height + 4 ] )  "CheckBox"
                                    @ ( font height + 8 ) ) ) negated );
                     yourself ).
            ].
    inset y: inset y + font height + 8 + 4.
    ^ control! 
label: aString

    "Set the label of the page to <aString>."

    label  := aString! 
clearCachedHandlers

    "Private - Get rid of all the cached property handlers."

    CachedHandlers := nil! 
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super constructPropertyManager
		add:
			(SelectorPropertyAccessor
				name: 'Part name'
				get: #partName
				set: #partName:
				editor: nil
				validator: PropertyManager validatorForPartName);
		add:
			(SelectorPropertyAccessor
				name: 'Backcolor'
				get: #backColor
				set: #backColor:
				editor: PropertyManager editorForColor);
		add:
			(SelectorPropertyAccessor
				name: 'Interface'
				get: nil
				set: nil
				editor: #partEditInterface);
		add:
			(SelectorPropertyAccessor
				name: 'Size window'
				get: #partGetWindowSize
				set: #partSetWindowSize:
				editor: PropertyManager editorForFramingBlock);
		groupPartsOnlyAddList: #('Part name' 'Interface' 'Size window');
		addNames: #( 'Part name' 'Backcolor' 'Interface' 'Size window') toPage: 'General';
		yourself!  
nameForGroupValidator

    "Private - Property name for the group validator."

    ^ '_groupValidator'!   
constructPropertyManager

    "Construct accessors for receiver's properties."

    ^ PropertyManager new!
edit: propertyValue for: anObject

    "Private - Invoke editor on <propertyValue> and set value to its result.
      An editor can be a selector, a part file, or any ActionSequence,

      or an action."
    | editor |
    ( editor := self editor )
        isNil ifTrue: [ ^nil ].
    ^ PropertyManager performAction: editor object: anObject arguments: (Array with: propertyValue).!  
addGroupEditor: anEditor

    "Add a property editor <anEditor> for all the properties.
    <anEditor> can be a selector, a part file name,
    or any ActionSequence."

    self metaPropertiesCreateIfNil add: (
        ObjectPropertyAccessor
            name: self nameForGroupEditor
            object: anEditor )!  
name: aString
style: poolItemKey
pool: aPool
	"Create an Accessor with the name <aString>.
    <poolItemKey> is the style constant name and
    <aPool> is the Smalltalk pool."

	^self
		new name: aString;
		style: poolItemKey;
		pool: aPool !  
description: aString
    "Set the description of the page to <aString>."

    description := aString!  
constructPropertyManager
	"Construct accessors for receiver's properties."

	^super
		constructPropertyManager
		add:
			(SelectorPropertyAccessor
				name: 'Font'
				get: #font
				set: #font:
				editor: PropertyManager editorForFont);
		add:
			(SelectorPropertyAccessor
				name: 'Forecolor'
				get: #foreColor
				set: #foreColor:
				editor: PropertyManager editorForColor);
		addNames: #( 'Font' 'Forecolor' ) toPage: 'General';
		yourself!   
name: aString
style: poolItemKey
pool: aPool
mask: maskBits
	"Create an Accessor with the name <aString>.
    <poolItemKey> is the style constant name and
    <aPool> is the Smalltalk pool. <maskBits> is the
	bit pattern to clear the style before applying
	the new style contstant."

	^self
		new name: aString;
		style: poolItemKey;
		pool: aPool;
		mask: maskBits!