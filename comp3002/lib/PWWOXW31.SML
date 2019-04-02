3.1.0.106
   
warningNoControlSupport
		" Private - display a warning  message to the user that property editing of the control is not available. "

	OLEWarning signal: 
		'OLE control support is not available on this operating system.'!   
partIsLiteral
		"Private - answer true if the receiver can be expressed in source code as a literal.
		(The receiver's #storeOn: method will be used). "

	^true! 
propertyCLSID: aGUID
        " Private - install the property value for the control name. "

    aGUID = self clsid
        ifTrue: [ ^self ].
    self siteObject notEmpty
        ifTrue: [ self siteObject clearContent ].
	self propertyChangeControl: aGUID.
	( Message new   " undo/redo not yet supported "
		receiver: self partEditor;
		selector: #recordUndoPlaceholder )
			performDeferred.!  
partPropertyEditDone: aPropertyStructure
        " Private - property changes applied "

    ( aPropertyStructure partContext at: #controlChanged )
        ifTrue: [
            (Message new
                receiver: self partEditor
                selector: #validateLinksAttachedTo:
                arguments: (Array with: self))
                    performDeferred ].!  
propertyChooseControlDialog
		" Private - answer a new instance of the dialog which
		allows the user to choose the control class to which the
		receiver is connected. "

	^OLEControlChoiceDialog new
		font: PARTSSettings current fontDialogs;
		yourself! 
partPropertyEditProperties: aButtonProperty
        " Private - Edit properties... property button handler "

	self editProperties.
    aButtonProperty newValue: 'changed'.  " this is a hint to check for property changes "!   
propertyDisableFont: aPropertyStructure
		" Private - disable the ambient font property. "

	" unpleasant private tweaking required here "
	( aPropertyStructure dialogWindow children
		detect: [ :w | w name = 'Font' ]
		ifNone: [ ^nil ] )
			disable.!
partProperties
        " Private - answer a PARTS property structure containing
        the receiver's editable properties. "

	| isOLEAvailable aPropertyStructure |
	isOLEAvailable := OLESessionManager isOLEAvailable.
    aPropertyStructure := PARTSPropertyStructure on: self.
    aPropertyStructure partContext
        at: #controlChanged put: false.
    aPropertyStructure
        when: #editDone
        send: #partPropertyEditDone: to: self with: aPropertyStructure.
	self siteObject supportsAmbientFont
		ifFalse: [
			aPropertyStructure
				when: #opened
				send: #propertyDisableFont: to: self with: aPropertyStructure ].
    aPropertyStructure
        putProperty: ( PARTSPropertyEditButton new
            label: 'Change OLE control...';
            value: self clsid;
            enabled: ( OLESessionManager isContainerSupportAvailable and: [ isOLEAvailable ] );
            clickedSelector: #partPropertyChangeControl: ;
            changeSelector: #propertyCLSID: ;
            yourself );
        at: #propertyControlName putProperty: ( PARTSPropertyStaticText new
            label: ( self propertyControlNameOf: self clsid );
            makeSameLine;
            yourself );
        at: #editPropertiesButton putProperty: ( PARTSPropertyEditButton new
            label: 'Control properties...';
            value: 'original';
            enabled: ( 
                OLESessionManager isContainerSupportAvailable
                and: [ isOLEAvailable 
                and: [ self siteObject notEmpty
                and: [ self siteObject storage isStream ] ] ] );
            clickedSelector: #partPropertyEditProperties: ;
            changeSelector: #propertyControlState: ;
            yourself );
        putProperty: ( self partPropertyWindowStyle: 'Border'
            constant: WsPaneBorder );
		yourself.
	self partPropertyAddColorAndFont: aPropertyStructure.
	aPropertyStructure
		putProperty: #( #interface #sizeWindow ).
	OLESessionManager isContainerSupportAvailable
		ifFalse: [
			( Message
				receiver: self
				selector: #warningNoControlSupport )
					performDeferred ].
	isOLEAvailable
		ifFalse: [ 
			( Message
				receiver: self
				selector: #warningNoOLE:
				arguments: #( 'edit the control properties of' ) )
					performDeferred ].
	( isOLEAvailable 
	and: [ self clsid notNil
	and: [ self isControlClassAvailable not ] ] )
		ifTrue: [ 
			( Message
				receiver: self
				selector: #warningNoControl:
				arguments: #( 'edit the control properties of' ) )
					performDeferred ].
	^aPropertyStructure! 
codeGenerationAddAttributeMessagesTo: anExpressionModel
        "Add messages to <anExpressionModel> to set the attributes
        of a new instance of the class of the receiver."

    | aCodeGenerator byteCreationSelector cgExpression  |

    super codeGenerationAddAttributeMessagesTo: anExpressionModel.

    anExpressionModel addSelectorIfNotNil: #clsid: with: self clsid.

    self hasPersistentState
        ifTrue: [  " partition potential large byte array into separate method "
            aCodeGenerator := anExpressionModel codeGenerator.
            self persistentStateIsStream
                ifTrue: [
                    byteCreationSelector := aCodeGenerator storeByteArray: self persistentStateStream.
                    cgExpression := ( anExpressionModel addSelector: #setPersistentStateStream: ) 
				            newExpressionArgument ]
                ifFalse: [
                    byteCreationSelector := aCodeGenerator storeByteArray: self persistentStateStorage.
                    cgExpression := ( anExpressionModel addSelector: #setPersistentStateStorage: ) 
				            newExpressionArgument ].
            cgExpression
                setReceiverToSelf; "self is the genned class"
                addSelector: byteCreationSelector.
            anExpressionModel addSelector: #yourself ].!
partIsArrayElementLiteral
		"Private - answer true if the receiver can be expressed in source code within a literal Array."

	^false!  
propertyChangeControl: aCLSID
		" Private - change the control referenced by the receiver
		to the control class identified by the GUID <aCLSID>.  
		Load the control. "

	CursorManager execute changeFor: [
	    self
	        propertyInstallCLSID: aCLSID;
	        loadControl.
		self siteObject isStateModified
			ifTrue: [ self siteObject saveObject ].
		self siteObject isValid
			ifFalse: [ ^nil ].
		self siteObject disableControlWindows.
		"self ASSERT: self controlState isNil." 
		].
	self siteObject storage isStream
		ifFalse: [ self warningNoPropertyEdit ].!
propertyControlNameOf: aGUID
        " Private - answer the property value for the control name. "

    | controlClassName |
    controlClassName := ( aGUID isNil
        ifTrue: [ '( ... no OLE control chosen yet ... )' ]
        ifFalse: [ self siteObjectClass clsidUserName: aGUID ] ).
    ^'Control: ', controlClassName!   
propertyInstallCLSID: aGUID
		" Private - reset the receiver's CLSID to <aGUID>
		and adjust related attributes accordingly.
		Note that we assume the class is at least registered at this point. "

    self
        clsid: aGUID;
        isControlClassAvailable: true;  " at least, we know its class is registered at this point "
        deletePersistentState.
!
propertyControlState: controlPropertiesEdited
        " Private - install the property value for the control name. "

	| controlStateChanged |
    controlPropertiesEdited = 'changed'
        ifTrue: [
            controlStateChanged := self siteObject saveStateChanges.
            controlStateChanged 
                ifTrue: [ ( Message new   " undo/redo not yet supported "
                    receiver: self partEditor;
                    selector: #recordUndoPlaceholder )
                        performDeferred ].
            ].
    controlPropertiesEdited = 'reset'
        ifTrue: [
            self deletePersistentState.
            ( Message new   " undo/redo not yet supported "
                receiver: self partEditor;
                selector: #recordUndoPlaceholder )
                    performDeferred.
            ].!   
partEditDirect
        "Private-Edit the directly visible part properties of the receiver."

    | aCLSID controlStateChanged |
    OLESessionManager isContainerSupportAvailable
        ifFalse: [
            self warningNoControlSupport.
            ^nil ].
    self clsid isNil
        ifTrue: [
            OLESessionManager isOLEAvailable
                ifFalse: [
                    self warningNoOLE: 'direct edit'.
                    ^nil ].
            aCLSID := self propertyChooseControlDialog
                open.
            aCLSID notNil
                ifTrue: [
                    self propertyChangeControl: aCLSID.
                    self partEditor recordUndoPlaceholder ].
            ]
        ifFalse: [
            self siteObject isEmpty
                ifTrue: [
                    self warningNoControl: 'direct edit the properties of'.
                    ^nil ].
            self siteObject storage isStream
                ifFalse: [
                    self warningNoPropertyEdit.
                    ^nil ].
            self editProperties.
            controlStateChanged := self siteObject saveStateChanges.
            controlStateChanged
                ifTrue: [ self partEditor recordUndoPlaceholder ].
            ].!   
partPropertyChangeControl:  aButtonProperty
        " Private - Change control property button handler "

    | currentCLSID newCLSID controlChanged aPropertyStructure editPropertiesButton |

    currentCLSID := aButtonProperty newValue.

    newCLSID := self propertyChooseControlDialog
        initialSelection: currentCLSID;
        open.
    ( newCLSID isNil or: [ newCLSID = currentCLSID ] )
        ifTrue: [ ^self ].  " cancelled or no change "

	controlChanged := ( newCLSID ~= self clsid ).
    aPropertyStructure := aButtonProperty propertyStructure.
    ( aPropertyStructure propertyAt: #propertyControlName )
        label: ( self propertyControlNameOf: newCLSID ).
	editPropertiesButton := aPropertyStructure propertyAt: #editPropertiesButton.
	editPropertiesButton
        newValue: ( controlChanged not
            ifTrue: [ 'original' ]
            ifFalse: [ 'reset' ] ).
	controlChanged
		ifTrue: [ editPropertiesButton disable ]
		ifFalse: [ editPropertiesButton enable ].
    aButtonProperty newValue: newCLSID.
    aPropertyStructure partContext
        at: #controlChanged put: controlChanged.!   
validate
        "Private - The host window for the receiver was
         just created or recreated."

	super validate.
	self isInEditMode
		ifTrue: [ self siteObject disableControlWindows ].!
warningNoPropertyEdit
		" Private - display a warning  message to the user that property editing of the control is not available. "

	MessageBox
		notify: 'OLE Control Warning'
		 withText:
			'Property editing is not supported for ', self partName,
			' (the control ', self controlClassUserName,
			' does not use a stream backing store).'.
!