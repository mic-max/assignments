3.1.0.106
   
sizeInBytes
    ^super sizeInBytes + 92! 
inspectorFields
    ^#( #hdr #lpszText #szText #hinst #uFlags )! 
hinst
    ^self uLongAtOffset: 96!   
hinst: inst
    self uLongAtOffset: 96 put: inst!
szText
    ^self bytesAtOffset: 16 count: 80!
szText: aString
    ^self bytesAtOffset: 16 put: aString!
lpszText
    ^self uLongAtOffset: 12!
uFlags
	^self uLongAtOffset: 100!
uFlags: anInteger
	self uLongAtOffset: 100 put: anInteger!   
lpszText: aStringPtr
    self uLongAtOffset: 12 put: aStringPtr! 
toolTipOrNil
        "Private - answer the ToolTip of the receiver, or nil if none."
    ^self propertyAt: #toolTip!
toolTip: aToolTip
        "Private - set the ToolTip for the receiver to aToolTip."
    self propertyAt: #toolTip put: aToolTip!
toolTip
        "Private - answer the ToolTip for the receiver, creating one if necessary."
    ^self
        propertyAt: #toolTip
        ifAbsentPut: [ ToolTip new buildWindow: self ]!
sizeInBytes
    ^40! 
inspectorFields
    ^self inspectorClass fields: #( #cbSize #uFlags #hwnd #uId #rect #hinst #lpszText )! 
destroyToolTip
        "Private - destroy the host tool tip control."
    | toolTip |
    ( toolTip := self toolTipOrNil ) notNil
        ifTrue: [ toolTip destroy ].
    self toolTip: nil!
hinst
    ^self uLongAtOffset: 32!   
hinst: anInteger
    self uLongAtOffset: 32 put: anInteger!  
hwnd: anInteger
    self uLongAtOffset: 8 put: anInteger!
hwnd
    ^self uLongAtOffset: 8! 
cbSize: anInteger
    self uLongAtOffset: 0 put: anInteger!  
cbSize
    ^self uLongAtOffset: 0!   
lpszText
    ^self uLongAtOffset: 36!
uFlags
    ^self uLongAtOffset: 4!   
rect
    ^( WinRectangle
        usingBytes: ( self bytesAtOffset: 16 count: WinRectangle sizeInBytes ) ) asRectangle!  
uFlags: anInteger
    self uLongAtOffset: 4 put: anInteger!  
uId
    ^self uLongAtOffset: 12! 
uId: anInteger
    self uLongAtOffset: 12 put: anInteger!
lpszText: anInteger
    self uLongAtOffset: 36 put: anInteger!   
rect: aRectangle
    self bytesAtOffset: 16 put: aRectangle asRectangleParameter!
unbound
		"Private - remove registration info."
	ServiceRegistry globalRegistry unregister: #ToolTip!   
bound
		"Private - install registration info."
	ServiceRegistry globalRegistry
		register: ServiceRegistry new
		withName: #ToolTip
		version: '3.1'
!  
tipText: aString
        "Set the tip text for the receiver to aString."
    self propertyAt: #tipText put: aString.
    self isHandleOk
        ifTrue: [ self mainWindow toolTip window: self text: self tipText ]! 
tools
        "Private - answer the list of tools managed by the receiver."
    ^tools! 
tools: aCollection
        "Private - set the list of tools which the receiver manages to aCollection."
    tools := aCollection!   
windowClass
        "Private - answer the host window class identifier for the receiver."
    ^TooltipsClass!   
destroy
		"Destroy the receiver's window.  Free addresses of tip text copied to
		external memory before destroying."
	self tools do: [ :tool | ( tool at: 2 ) free ].
	super destroy!
initialize
        "Private - initialize the tools list."
    super initialize.
    self tools: Dictionary new!
basicStyle
        "Private - answer the basic window style of the receiver."
    ^WsPopup! 
buildWindow: parentWindow
        "Private - build the host window for the receiver, using parentWindow
        as the parent window."
    | tipHandle |
    CommonControlsDLL current.  "ensure the common controls library is loaded."
    self parent: parentWindow.
    tipHandle := UserLibrary
        createWindowStructEx: self defaultExtendedStyle
        class: self windowClass
        nameStruct: nil
        style: self basicStyle
        x: CwUsedefault
        y: CwUsedefault
        width: CwUsedefault
        height: CwUsedefault
        parent: nil
        menu: nil
        instance: OperatingSystem hInstanceExe
        param: nil.
    tipHandle = 0 ifTrue: [ self osError ].
    self handle: ( WindowHandle fromInteger: tipHandle )!   
relay: message fromWindow: aWindow wparam: wparam lparam: lparam
        "Private - relay the mouse event specified by message and its parameters
        to the host tool tip control for processing."
    | msg |
    msg := WinMessage new.
    msg hwnd: aWindow handle asInteger.
    msg msg: message.
    msg wparam: wparam.
    msg lparam: lparam.
    UserLibrary
        sendMessage: self handle
        msg: TtmRelayevent
        wparam: 0
        lparamStruct: msg asParameter!
removeWindow: aWindow
        "Private - remove aWindow from the list of tools managed by the receiver."
    | toolinfo tool addr |
    tool := self tools at: aWindow handle asInteger ifAbsent: [ nil ].
    tool notNil ifTrue: [ addr := tool at: 2.  addr free ].
    toolinfo := WinToolinfo new.
    toolinfo cbSize: WinToolinfo sizeInBytes.
    toolinfo uFlags: TtfIdishwnd.
    toolinfo uId: aWindow handle asInteger.
    UserLibrary
        sendMessage: self handle
        msg: TtmDeltool
        wparam: 0
        lparamStruct: toolinfo asParameter.
    self tools removeKey: aWindow handle asInteger ifAbsent: [ nil ]!
updateWindow: aWindow
        "Private - update the tip text for aWindow (which is assumed to
        already have been registered with the receiver via addWindow:)."
    | tipText addr toolinfo tool |
    tool := self tools at: aWindow handle asInteger ifAbsent: [ nil ].
    tool notNil ifTrue: [ addr := tool at: 2.  addr free ].
    tipText := aWindow tipText.
    addr := tipText copyToExternalMemory.
    toolinfo := WinToolinfo new.
    toolinfo cbSize: WinToolinfo sizeInBytes.
    toolinfo uFlags: TtfIdishwnd.
    toolinfo uId: aWindow handle asInteger.
    toolinfo lpszText: addr asInteger.
    UserLibrary
        sendMessage: self handle
        msg: TtmUpdatetiptext
        wparam: 0
        lparamStruct: toolinfo asParameter!  
window: aWindow text: aString
        "Add, update, or remove tip text as specified by aString for aWindow.
        If aString is nil, previously registered tip text is removed; otherwise,
        aString adds or updates the tip text for aWindow."
    ( self tools includesKey: aWindow handle asInteger )
        ifTrue: [
            aString isNil
                ifTrue: [ self removeWindow: aWindow ]
                ifFalse: [ self updateWindow: aWindow ] ]
        ifFalse: [ self addWindow: aWindow ]!  
defaultExtendedStyle
        "Private - answer the default extended style of the receiver."
    ^WsExTopmost!   
addWindow: aWindow
        "Private - add aWindow to the list of tools managed by the receiver."
    | tipText addr toolinfo |
    tipText := aWindow tipText.
    addr := tipText copyToExternalMemory.
    toolinfo := WinToolinfo new.
    toolinfo cbSize: WinToolinfo sizeInBytes.
    toolinfo uFlags: TtfIdishwnd.
    toolinfo uId: aWindow handle asInteger.
    toolinfo lpszText: addr asInteger.
    UserLibrary
        sendMessage: self handle
        msg: TtmAddtool
        wparam: 0
        lparamStruct: toolinfo asParameter.
    self tools at: aWindow handle asInteger put: ( Array with: aWindow with: addr )!   
relay: message wparam: wparam lparam: lparam
        "Private - if the receiver has tip text, relay message to the tool tip for processing."
    | toolTip |
    self tipText isNil ifTrue: [ ^self ].
    ( toolTip := self mainWindow toolTipOrNil ) isNil ifTrue: [ ^self ].
    toolTip relay: message fromWindow: self wparam: wparam lparam: lparam!   
tipText
        "Answer the tip text for the receiver."
    ^self propertyAt: #tipText!