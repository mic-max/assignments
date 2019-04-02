"3.0.0.2"
!  

PRealWidgetControl subclass: #POLEClientSitePane
  instanceVariableNames: 
    ' clsid controlState controlClassUserName serverName controlEvents '
  classVariableNames: ''
  poolDictionaries: 
    ' OLEConstants '!

WBAttributeEditor subclass: #WBOLEControlPartEditor
  instanceVariableNames: 
    ' oleControlPart container controlServer eventsButton propertiesButton methodsButton controlPropertiesButton controlNameLabel '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '!   

WBAbstractAddInModule subclass: #WBOLESupportAddInModule
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

!WBOLEControlPartEditor methods !   
controlServer
        " Private - answer the description of the control's server application. "

    ^controlServer ifNil: ['']! !

!POLEClientSitePane methods !
importantEvents

    ^(self controlEvents isEmpty
        ifTrue: [self realClass eventsTriggered select: [:event | event first isUppercase]]
        ifFalse: [self controlEvents]) asSortedCollection! !

!WBOLEControlPartEditor methods !   
controlServer: aString
        " Private - set the description of the control's server application. "

    controlServer := aString.! !

!WBOLEControlPartEditor methods !   
preInitWindow

    self mainView container: self container.
    container registerSite: self activeSite! !

!POLEClientSitePane methods !
serverName: aString
        " Private - set the server name of the control. "

    serverName := aString.! !

!POLEClientSitePane methods !  
displayWith: aPen clipRect: clipRect

    | aName region innerRect default |
    aName := (self realClass name, '\<', self controlClassUserName, '>\') withCrs, self serverName.
    innerRect := self lookPolicy
        displayWithBorder: aPen
        rect: self rect
        backColor: self backColor.
    default := WBLookPolicy default.
    region := aPen setClipRect: ((rect insetBy: 1) intersect: clipRect).
    aPen
        setBackgroundModeTransparent;
        setTextAlign: WBDisplayContext defaultTextAlign;
        font: self wbEditorClass editorFont;
        backColor: self backColor;
        foreColor: Color white;
        winDrawText: aName
            in: (innerRect insetBy: 3)
            format: default leftJustification | default wordBreak;
        foreColor: Color black;
        winDrawText: aName
            in: (innerRect insetBy: 2)
            format: default leftJustification | default wordBreak;
        destroyRegion: region.! !

!POLEClientSitePane methods !
controlState
        " Private - answer the saved state of the control. "

    ^controlState! !

!WBOLEControlPartEditor methods !   
createContainerNamed: containerName
        " Private - answer a new container object with its name set to <containerName>. "

    ^OLEContainerObject new
        name: containerName;
        yourself! !

!POLEClientSitePane methods ! 
clsid
        " Answer the CLSID of the OLE control to which the receiver is connected. "

    ^clsid! !

!WBOLEControlPartEditor methods !  
container
        " Private - answer the receiver's container object. "

    ^container! !

!POLEClientSitePane methods !
storeSpecificsOn: aStream indentString: indentString

    | bitmapKey |
    self clsid isNil
        ifFalse: [
            aStream
                nextPutAll: ';'; cr; nextPutAll: #clsid:;
                nextPutAll: ' (GUID fromBytes: '; nextPutAll: self clsid hexByteString; nextPut: $)].
    self controlState isNil
        ifFalse: [
            aStream
                nextPutAll: ';'; cr; nextPutAll: #setPersistentStateStream:; space;
                nextPutArrayOfBytes: (self controlState at: 2)].
! !

!POLEClientSitePane methods ! 
postEdit: aWindowBuilder

    aWindowBuilder updateEvents: true.
    ^true! !

!WBOLEControlPartEditor methods ! 
updateControlDescription
        " Private - update the information about the control in the view. "

    | serverName controlClassUserName |
    controlClassUserName := self activeSite controlClassUserName ifNil: ['Unspecified'].
    CursorManager execute changeFor: [
        serverName := OLERegistryInterface serverNameOf: self activeSite controlCLSID].
    self controlServer: (serverName isNil
        ifTrue: ['(server information not found in registry)']
        ifFalse: [serverName]).
    controlNameLabel setValue: ('Control: ', controlClassUserName, '\', 'Server: ') withCrs, self controlServer ! !

!WBOLEControlPartEditor methods ! 
initializeContainer
        " Private - initialize the receiver's container object. "

    self container: (self createContainerNamed: self containerName).! !

!POLEClientSitePane methods !
serverName
        " Private - answer the server name of the control."

    ^serverName ifNil: ['']! !

!POLEClientSitePane methods !
controlClassUserName
        " Private - answer the control class name of the control."

    ^controlClassUserName ifNil: ['Unspecified']! !

!WBOLEControlPartEditor methods !  
aboutToClose
        " Private - close the receiver's container and its sites. "

    self container close.! !

!WBOLEControlPartEditor methods !
showMethods
        " Private - describe the methods supported by the control. "

    | aStream |
    aStream := ReadWriteStream on: String new.
    self
        describeControlOn: aStream;
        describeControlMethodsOn: aStream.
    TextWindow new
        label: self activeSite controlClassUserName, ' Methods';
        openOn: aStream contents.! !

!POLEClientSitePane methods !  
clsid: aCLSID
        " Set the CLSID of the OLE control to which the receiver is connected to the GUID <aCLSID>. "

    clsid := aCLSID.! !

!POLEClientSitePane methods !  
controlClassUserName: aString
        " Private - set the name of the control. "

    controlClassUserName := aString.! !

!WBOLEControlPartEditor methods ! 
changeControl
        "Private - allow the user to invoke the Choose control dialog
        to insert an OLE control into <aControlSite>. "

    | clsid children |
    clsid := OLEControlChoiceDialog new
        title: 'Insert OLE Control';
        open.
    (clsid isNil or: [oleControlPart clsid = clsid])
        ifTrue: [^self].
    self activeSite notEmpty
        ifTrue: [
            children := self mainView children.
            self mainView children: nil.
            self activeSite clearContent.
            self mainView children: children].
    [CursorManager execute
        changeFor: [
            oleControlPart
                propertyInstallCLSID: clsid;
                loadControl.
            self activeSite isStateModified
                ifTrue: [self activeSite saveObject].
            self activeSite disableControlWindows.
            self activeSite storage isStream
                ifFalse: [oleControlPart warningNoPropertyEdit]]]
        on: OLEError
        do: [:ex | self displayWarning: ex description titled: 'Insert Control Problem'].
    self updateControlDescription.! !

!WBOLEControlPartEditor methods !  
indent
        " Private - answer the indent in description reports. "

    ^'    '! !

!WBOLESupportAddInModule class methods ! 
commonName

    ^'OLE Support'! !

!WBOLEControlPartEditor methods !  
ok

    self activeSite saveStateChanges.
    thePane
        clsid: oleControlPart clsid;
        controlState: oleControlPart controlState copy;
        controlClassUserName: self activeSite controlClassUserName;
        serverName: (OLERegistryInterface serverNameOf: self activeSite controlCLSID);
        controlEvents: self activeSite controlEvents.
    self close! !

!WBOLESupportAddInModule class methods !
modifiesPalette
    "Does this add-in modify the palette?"

    ^true! !

!WBOLEControlPartEditor methods !  
editProperites

    self activeSite editProperties! !

!WBOLEControlPartEditor methods !  
containerName
        " Answer the name of the receiver's container. "

    ^'OLE Container'! !

!WBOLEControlPartEditor methods !   
inspectControl

    oleControlPart inspect
! !

!WBOLESupportAddInModule class methods ! 
loaded
    "Answer the value of loaded."

    ^loaded ifNil: [loaded := true].! !

!WBOLEControlPartEditor methods ! 
describeControlPropertiesOn: aStream
        " Private - describe the properties supported by the control on <aStream>. "

    | propertyNames indent indent2 indent3 aSpecificationTable
      aDispatchSpecification parameterNames parameterTypes |

    propertyNames := self activeSite controlProperties.
    aStream
        nextPutAll: 'Properties supported by ',
            self activeSite controlClassUserName, ':'; cr.
    propertyNames isEmpty
        ifTrue: [
            aStream nextPutAll: '   (no properties are supported by this control)'; cr; cr.
            ^self ].

    indent := self indent.
    indent2 := indent, indent.
    indent3 := indent, indent, indent.
    aSpecificationTable := self activeSite propertyDispatcher specificationTable.
    propertyNames asSortedCollection do: [ :aPropertyName |
        aDispatchSpecification := aSpecificationTable at: aPropertyName.
        aStream
            cr;
            nextPutAll: indent, aDispatchSpecification name; cr;
            nextPutAll: indent2, 'DISPID: ', aDispatchSpecification memberID printString; cr.
        aDispatchSpecification isReadOnly
            ifTrue: [ self ASSERT: aDispatchSpecification setSelector isNil ].
        aDispatchSpecification isWriteOnly
            ifTrue: [ self ASSERT: aDispatchSpecification getSelector isNil ].
        aStream
            nextPutAll: indent2, 'Get selector: ',
                ( aDispatchSpecification getSelector isNil
                    ifTrue: [ '(none - writeOnly property)' ]
                    ifFalse: [ '#', aDispatchSpecification getSelector ] ) ; cr;
            nextPutAll: indent2, 'Set selector: ',
                ( aDispatchSpecification setSelector isNil
                    ifTrue: [ '(none - readOnly property)' ]
                    ifFalse: [ '#', aDispatchSpecification setSelector ] ); cr.
        aDispatchSpecification hasParameters
            ifTrue: [
                parameterNames := aDispatchSpecification parameterNames.
                parameterTypes := aDispatchSpecification parameterTypes.
                aDispatchSpecification isReadOnly
                    ifFalse: [
                        self ASSERT: parameterNames size = ( parameterTypes size - 1).
                        self ASSERT: parameterTypes last = aDispatchSpecification typeCode.
                        parameterNames := parameterNames, #( 'value (set only)' ) ].
                self describeParameters: parameterNames
                    types: parameterTypes
                    on: aStream ].
        aStream nextPutAll: indent2, 'Value: ',
            ( self typeCodeDescriptionOf: aDispatchSpecification typeCode ); cr.
        ].
    aStream
        cr;
        nextPutAll: '( ', propertyNames size printString, ' properties )'; cr;
        cr.! !

!WBOLEControlPartEditor methods !  
inspectSite

    self activeSite inspect.! !

!WBOLEControlPartEditor methods !   
showProperties
        " Private - describe the properties supported by the control. "

    | aStream |
    aStream := ReadWriteStream on: String new.
    self
        describeControlOn: aStream;
        describeControlPropertiesOn: aStream.
    TextWindow new
        label: self activeSite controlClassUserName, ' Properties';
        openOn: aStream contents.! !

!POLEClientSitePane methods !  
controlState: aValue
        " Private - set the saved state of the control. "

    controlState := aValue.! !

!WBOLEControlPartEditor methods !
initWindow

    self container addRef.  " artificially reference count the container
        while the window is open (needed for IPA support) "
    self newContainerFile.
    oleControlPart
        propertyInstallCLSID: thePane clsid;
        controlState: thePane controlState copy;
        loadControl.
    self activeSite disableControlWindows.
    self updateControlDescription.! !

!WBOLEControlPartEditor methods ! 
activeSite

    ^oleControlPart siteObject! !

!WBOLEControlPartEditor methods !  
showEvents
        " Private - describe the events supported by the control. "

    | aStream |
    aStream := ReadWriteStream on: String new.
    self
        describeControlOn: aStream;
        describeControlEventsOn: aStream.
    TextWindow new
        label: self activeSite controlClassUserName, ' Events';
        openOn: aStream contents.! !

!WBOLEControlPartEditor methods !  
describeControlEventsOn: aStream
        " Private - describe the events supported by the control on <aStream>. "

    | events  indent indent2 indent3 aSpecificationTable
      aDispatchSpecification |

    events := self activeSite controlEvents.
    aStream
        nextPutAll: 'Events triggered by ',
            self activeSite controlClassUserName, ':'; cr.
    events isEmpty
        ifTrue: [
            aStream nextPutAll: '   (no events are supported by this control)'; cr; cr.
            ^self ].

    indent := self indent.
    indent2 := indent, indent.
    indent3 := indent, indent, indent.
    aSpecificationTable := self activeSite eventSink specificationTable.
    events asSortedCollection do: [ :anEventSelector |
        aDispatchSpecification := aSpecificationTable detect: [ :anEventSpec |
            anEventSpec selector = anEventSelector ].
        aStream
            cr;
            nextPutAll: indent, aDispatchSpecification name; cr;
            nextPutAll: indent2, 'DISPID: ', aDispatchSpecification memberID printString; cr;
            nextPutAll: indent2, 'Event name: #', aDispatchSpecification selector; cr.
        self describeParameters: aDispatchSpecification parameterNames
            types: aDispatchSpecification parameterTypes
            on: aStream.
        aStream nextPutAll: indent2, 'Return type: ',
            ( self typeCodeDescriptionOf: aDispatchSpecification typeCode ); cr.
        ].
    aStream
        cr;
        nextPutAll: '    ( ', events size printString, ' events )'; cr;
        cr.! !

!WBOLEControlPartEditor methods ! 
typeCodeDescriptionOf: aTypeCode
        " Private - answer a string description of <aTypeCode>. "

    aTypeCode isInteger
        ifFalse: [ ^aTypeCode printString ].  " GUID can be in here... "
    ^OLEVariant typeCodeDescriptionOf: aTypeCode! !

!POLEClientSitePane methods !
controlEvents
        " Private - answer the events of the control. "

    ^controlEvents ifNil: [#()]! !

!POLEClientSitePane methods ! 
attributeEditor

    ^WBOLEControlPartEditor! !

!POLEClientSitePane methods !
backColor

    ^Color gray! !

!WBOLESupportAddInModule class methods !   
modifyPalette: thePalette
    "Modify the palette"

    self
        insertMenu: #('\uOLEControlPart' 'OLEControlPart' '')
            in: thePalette
            after: 'StatusPane'! !

!WBOLEControlPartEditor methods !   
container: aContainer
        " Private - set the receiver's container object to <aContainer>. "

    container := aContainer.! !

!WBOLESupportAddInModule class methods !  
comment

    ^'Adds the OLEControlPart
widget to the WBPro palette.
Warning: OLEControlPart may
only be used under Windows 95'! !

!WBOLEControlPartEditor methods !   
newContainerFile
        " Private - Create a new temporary container storage file. "

    [ self container newDocumentFile ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Container Storage Create Problem' ].! !

!WBOLEControlPartEditor class methods !   
wbBasicVersion

    "Private - Answer the WindowBuilder Pro version.
        Generated in: Visual Smalltalk Enterprise 3.1.0 Win32"

    ^3.1! !

!WBOLEControlPartEditor methods !
describeControlOn: aStream
        " Private - append a description of the control to <aStream>. "

    aStream
        nextPutAll: 'Control: ', self activeSite controlClassUserName; cr;
        nextPutAll: 'Server: ', self controlServer; cr;
        cr.! !

!WBOLEControlPartEditor methods !  
describeControlMethodsOn: aStream
        " Private - describe the methods supported by the control on <aStream>. "

    | methodSelectors indent indent2 indent3 aSpecificationTable
      aDispatchSpecification |

    methodSelectors := self activeSite controlMethodSelectors.
    aStream
        nextPutAll: 'Methods supported by ',
            self activeSite controlClassUserName, ':'; cr.
    methodSelectors isEmpty
        ifTrue: [
            aStream nextPutAll: '   (no methods are supported by this control)'; cr; cr.
            ^self ].

    indent := self indent.
    indent2 := indent, indent.
    indent3 := indent, indent, indent.
    aSpecificationTable := self activeSite methodDispatcher specificationTable.
    methodSelectors asSortedCollection do: [ :aSelector |
        aDispatchSpecification := aSpecificationTable at: aSelector.
        aStream
            cr;
            nextPutAll: indent, aDispatchSpecification name; cr;
            nextPutAll: indent2, 'DISPID: ', aDispatchSpecification memberID printString; cr;
            nextPutAll: indent2, 'Selector: #', aDispatchSpecification selector; cr.
        self describeParameters: aDispatchSpecification parameterNames
            types: aDispatchSpecification parameterTypes
            on: aStream.
        aStream nextPutAll: indent2, 'Return type: ',
            ( self typeCodeDescriptionOf: aDispatchSpecification typeCode ); cr.
        ].
    aStream
        cr;
        nextPutAll: '( ', methodSelectors size printString, ' methods )'; cr;
        cr.! !

!WBOLEControlPartEditor methods ! 
createViews

    "WARNING!! This method was automatically generated by
    WindowBuilder. Code you add here which does not conform to
    the WindowBuilder API will probably be lost the next time
    you save your layout definition."

    | cancelButton changeControlButton inspectControlButton
    inspectSiteButton mainView okButton xDU yDU |

    #generated.
    xDU := (SysFont width + 1 roundTo: 2) / (SysFont width roundTo: 2).
    yDU := 1.
    mainView := self topPaneClass new.

        "Instance Variables"
    controlNameLabel := StaticText new.
    controlPropertiesButton := Button new.
    eventsButton := Button new.
    methodsButton := Button new.
    oleControlPart := (Smalltalk at: #OLEControlPart) new.
    propertiesButton := Button new.

        "Temporary Variables"
    cancelButton := Button new.
    changeControlButton := Button new.
    inspectControlButton := Button new.
    inspectSiteButton := Button new.
    okButton := Button new.

    mainView
        owner: self;
        setName: 'mainView';
        alignRelativeToScreen;
        when: #aboutToClose send: #aboutToClose to: self;
        when: #closed send: #closed to: self;
        addModalBorderStyle;
        labelWithoutPrefix: 'OLE Control Part Editor';
        noSmalltalkMenuBar;
        framingBlock:
            (LayoutFrame new
                leftRatio: 1/2 / ((SysFont width roundTo: 2) / 4);
                leftInset: -135 * xDU;
                topRatio: 1/2 / (SysFont height / 8);
                topInset: -75 * yDU;
                rightRatio: 1/2 / ((SysFont width roundTo: 2) / 4);
                rightInset: -135 * xDU;
                bottomRatio: 1/2 / (SysFont height / 8);
                bottomInset: -75 * yDU).
    self addView: mainView.

    changeControlButton "Button"
        owner: self;
        setName: 'changeControlButton';
        when: #clicked send: #changeControl to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 4 * xDU;
                topRatio: 0; topInset: 4 * yDU;
                rightRatio: 0; rightInset: -94 * xDU;
                bottomRatio: 0; bottomInset: -20 * yDU);
        contents: 'Change OLE Control...';
        startGroup;
        font: SysFont.
    mainView
        addSubpane: changeControlButton;
        subPaneWithFocus: changeControlButton.

    controlPropertiesButton "Button"
        owner: self;
        setName: 'controlPropertiesButton';
        when: #clicked send: #editProperites to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 4 * xDU;
                topRatio: 0; topInset: 22 * yDU;
                rightRatio: 0; rightInset: -94 * xDU;
                bottomRatio: 0; bottomInset: -38 * yDU);
        contents: 'Control Properties...';
        startGroup;
        font: SysFont.
    mainView addSubpane: controlPropertiesButton.

    inspectControlButton "Button"
        owner: self;
        setName: 'inspectControlButton';
        when: #clicked send: #inspectControl to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 98 * xDU;
                topRatio: 0; topInset: 22 * yDU;
                rightRatio: 0; rightInset: -180 * xDU;
                bottomRatio: 0; bottomInset: -38 * yDU);
        contents: 'Inspect Control';
        startGroup;
        font: SysFont.
    mainView addSubpane: inspectControlButton.

    inspectSiteButton "Button"
        owner: self;
        setName: 'inspectSiteButton';
        when: #clicked send: #inspectSite to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 184 * xDU;
                topRatio: 0; topInset: 22 * yDU;
                rightRatio: 0; rightInset: -266 * xDU;
                bottomRatio: 0; bottomInset: -38 * yDU);
        contents: 'Inspect Site';
        startGroup;
        font: SysFont.
    mainView addSubpane: inspectSiteButton.

    methodsButton "Button"
        owner: self;
        setName: 'methodsButton';
        when: #clicked send: #showMethods to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 4 * xDU;
                topRatio: 0; topInset: 132 * yDU;
                rightRatio: 0; rightInset: -58 * xDU;
                bottomRatio: 0; bottomInset: -148 * yDU);
        contents: 'Methods...';
        startGroup;
        font: SysFont.
    mainView addSubpane: methodsButton.

    propertiesButton "Button"
        owner: self;
        setName: 'propertiesButton';
        when: #clicked send: #showProperties to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 62 * xDU;
                topRatio: 0; topInset: 132 * yDU;
                rightRatio: 0; rightInset: -116 * xDU;
                bottomRatio: 0; bottomInset: -148 * yDU);
        contents: 'Properties...';
        startGroup;
        font: SysFont.
    mainView addSubpane: propertiesButton.

    eventsButton "Button"
        owner: self;
        setName: 'eventsButton';
        when: #clicked send: #showEvents to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 120 * xDU;
                topRatio: 0; topInset: 132 * yDU;
                rightRatio: 0; rightInset: -174 * xDU;
                bottomRatio: 0; bottomInset: -148 * yDU);
        contents: 'Events...';
        startGroup;
        font: SysFont.
    mainView addSubpane: eventsButton.

    okButton "Button"
        owner: self;
        setName: 'okButton';
        when: #clicked send: #ok to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 190 * xDU;
                topRatio: 0; topInset: 132 * yDU;
                rightRatio: 0; rightInset: -226 * xDU;
                bottomRatio: 0; bottomInset: -148 * yDU);
        defaultPushButton;
        contents: 'OK';
        startGroup;
        font: SysFont.
    mainView addSubpane: okButton.

    cancelButton "Button"
        owner: self;
        setName: 'cancelButton';
        when: #clicked send: #cancel to: self;
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 230 * xDU;
                topRatio: 0; topInset: 132 * yDU;
                rightRatio: 0; rightInset: -266 * xDU;
                bottomRatio: 0; bottomInset: -148 * yDU);
        cancelPushButton;
        contents: 'Cancel';
        startGroup;
        font: SysFont.
    mainView addSubpane: cancelButton.

    oleControlPart
        owner: self;
        setName: 'oleControlPart';
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 4 * xDU;
                topRatio: 0; topInset: 40 * yDU;
                rightRatio: 0; rightInset: -266 * xDU;
                bottomRatio: 0; bottomInset: -130 * yDU);
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: oleControlPart.

    controlNameLabel "StaticText"
        owner: self;
        setName: 'controlNameLabel';
        framingBlock:
            (LayoutFrame new
                leftRatio: 0; leftInset: 98 * xDU;
                topRatio: 0; topInset: 4 * yDU;
                rightRatio: 0; rightInset: -266 * xDU;
                bottomRatio: 0; bottomInset: -20 * yDU);
        contents: 'Control:
Server:';
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: controlNameLabel! !

!POLEClientSitePane methods !  
readSpecificsFrom: aWidget

    self
        clsid: aWidget clsid;
        controlState: aWidget controlState;
        controlClassUserName: aWidget siteObject controlClassUserName;
        serverName: (OLERegistryInterface serverNameOf:aWidget siteObject controlCLSID);
        controlEvents: aWidget siteObject controlEvents! !

!POLEClientSitePane methods ! 
controlEvents: aCollection
        " Private - set the events of the control. "

    controlEvents := aCollection.! !

!WBOLEControlPartEditor methods ! 
initialize
        " Private - Initialize the receiver. "

    self initializeContainer.
    super initialize.! !

!WBOLEControlPartEditor methods !
describeParameters: parameterNames types: parameterTypes on: aStream
        " Private - describe the methods supported by the control on <aStream>. "

    | nParameters indent2 indent3 |

    nParameters := parameterTypes size.
    nParameters = 0
        ifTrue: [
            self ASSERT: parameterNames size = 0.
            ^self ].

    indent2 := self indent, self indent.
    indent3 := indent2, self indent.

    parameterNames size ~= nParameters
        ifTrue: [
            "self ASSERT: false."  " should not ever be... "
            parameterNames size > 0
                ifTrue: [
                    aStream nextPutAll: indent2, 'Parameter names: ',
                        parameterNames printString; cr ].
                parameterTypes size > 0
                    ifTrue: [
                        aStream nextPutAll: indent2, 'Argument types:'; cr.
                        parameterTypes do: [ :aTypeCode |
                            aStream nextPutAll: indent3,
                                ( self typeCodeDescriptionOf: aTypeCode ); cr ] ].
            ^self ].

    aStream nextPutAll: indent2, 'Arguments:'; cr.
    1 to: nParameters do: [ :i |
        aStream
            nextPutAll: indent3, ( parameterNames at: i ), ': ';
            nextPutAll: ( self typeCodeDescriptionOf: ( parameterTypes at: i ) );
            cr ].
! !

!WBOLEControlPartEditor methods !  
closed
        " Private - the window has been closed.  Close down the application.
        Shut down the process if there are no more windows open. "

    self container release.  " decrement the artifical ref count "
    self container: nil.! !
 
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!