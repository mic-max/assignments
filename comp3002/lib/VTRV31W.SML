3.1.0.106
   
sizeInBytes
    ^40! 
inspectorFields
    ^self inspectorClass fields: #( #mask #hItem #state #stateMask #pszText #cchTextMax #iImage #iSelectedImage #cChildren #lParam )!
lParam
    ^self longAtOffset: 36!   
mask
    ^self uLongAtOffset: 0! 
pszText
    ^self uLongAtOffset: 16! 
cchTextMax: anInteger
    self longAtOffset: 20 put: anInteger!  
pszText: anInteger
    self uLongAtOffset: 16 put: anInteger!
cchTextMax
    ^self longAtOffset: 20!   
hItem
    ^self uLongAtOffset: 4!
hItem: anInteger
    self uLongAtOffset: 4 put: anInteger!   
iSelectedImage
    ^self longAtOffset: 28!   
state
    ^self uLongAtOffset: 8!
state: anInteger
    self uLongAtOffset: 8 put: anInteger!   
iImage
    ^self longAtOffset: 24!   
iImage: anInteger
    self longAtOffset: 24 put: anInteger!  
cChildren
    ^self longAtOffset: 32!
cChildren: anInteger
    self longAtOffset: 32 put: anInteger!   
lParam: anInteger
    self longAtOffset: 36 put: anInteger!  
stateMask
    ^self uLongAtOffset: 12!   
stateMask: anInteger
    self uLongAtOffset: 12 put: anInteger!  
mask: anInteger
    self uLongAtOffset: 0 put: anInteger!
iSelectedImage: anInteger
    self longAtOffset: 28 put: anInteger!  
sizeInBytes
    ^18! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #hdr #wVKey #flags )!
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    ^Dictionary new
        at: NmDblclk put: #notifyDblclk: ;
        at: NmRclick put: #notifyRClick: ;
        at: TvnBeginlabeledit put: #notifyBeginlabeledit: ;
        at: TvnEndlabeledit put: #notifyEndlabeledit: ;
        at: TvnItemexpanding put: #notifyItemexpanding: ;
        at: TvnSelchanging put: #notifySelchanging: ;
        at: TvnSelchanged put: #notifySelchanged: ;
        at: TvnBegindrag put: #notifyBegindrag: ;
        at: TvnBeginrdrag put: #notifyBeginrdrag: ;
        yourself!
defaultFont
        "Answer the default font for the receiver pane."
    ^ListFont! 
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #needsStringFor: ;
        add: #needsImageFor: ;
        add: #needsSelectedImageFor: ;
        add: #needsHasChildrenFor: ;
        add: #needsChildrenFor: ;

        add: #aboutToEditLabel: ;
        add: #aboutToChangeLabel:to: ;
        add: #changedLabel:to: ;

        add: #changed: ;
        add: #doubleClicked: ;
        add: #expanded: ;
        add: #collapsed: ;

        add: #characterTyped: ;
        yourself!
sizeInBytes
    ^104!
inspectorFields
    ^self inspectorClass fields: #( #hdr #action #itemOld #itemNew #ptDrag )!
windowClass
        "Private - Answer the window class for the receiver."
    ^WcTreeview!  
dummyItemLabel
        "Private - answer the label (String) of a dummy item (an item that is
        used as a placeholder for child items until an expand request is made)."
    ^'XdummyX'!  
triggerAboutToEditLabel: item
        "Private - trigger the aboutToEditLabel: event."
    self triggerEvent: #aboutToEditLabel: with: item object! 
deleteDummyItem: parentItem
        "Private - delete the dummy child item of parentObject, if one exists.
        Answer whether the item was deleted."
    | parentHandle itemHandle item hasDummy |
    ( parentHandle := self handleFromItem: parentItem ) isNil ifTrue: [ ^false ].
    itemHandle := UserLibrary
        sendMessage: self handle
        msg: TvmGetnextitem
        wparam: TvgnChild
        lparam: parentHandle.
    itemHandle = 0 ifTrue: [ ^false ].  "no children"
    "convert from signed return value to unsigned"
    itemHandle := ( ExternalLong fromInteger: itemHandle ) asUnsignedInteger.
    ( item := self itemFromHandle: itemHandle ) isNil ifTrue: [ ^false ].
    ( hasDummy := item = self dummyItemLabel ) ifTrue: [
        UserLibrary
            sendMessage: self handle
            msg: TvmDeleteitem
            wparam: 0
            lparam: itemHandle ].
    ^hasDummy!  
editLabels: aBoolean
        "Enable or disable label editing, according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: TvsEditlabels ]
        ifFalse: [ self removeStyle: TvsEditlabels ].
    self setStyle: self style!   
getImageFor: aTreeViewItem
        "Private - answer the image for aTreeViewItem,
        retrieving via the #needsImageFor: event if necessary."
    | image |
    aTreeViewItem = self dummyItemLabel ifTrue: [ ^nil ].
    aTreeViewItem image notNil ifTrue: [ ^aTreeViewItem image ].
    image := self
        triggerEvent: #needsImageFor:
        withArguments: ( Array with: aTreeViewItem object )
        ifNotHandled: [ nil ].
    aTreeViewItem image: image.
    ^image!  
handleItemMap
		"Private - answer the Dictionary which maps between
		item handles and items."
	^handleItemMap!
ensureVisible: anObject
        "Make anObject (an item) visible within the receiver."
    | itemHandle |
    ( itemHandle := self handleFromObject: anObject ) isNil ifTrue: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: TvmEnsurevisible
        wparam: 0
        lparam: itemHandle! 
backColor: aColor
        "Set the background color of the receiver.  Due to a bug in the host
        implementation, just setting the background color and repainting will
        not repaint the tree part of the control correctly; resetting the font causes
        this part of the control to be repainted correctly."
    | font |
    super backColor: aColor.
    self isHandleOk ifFalse: [ ^self ].
    font := self font isNil ifTrue: [ self defaultFont ] ifFalse: [ self font ].
    UserLibrary sendMessage: handle msg: WmSetfont wparam: font fontHandle lparam: 1! 
handleItemMap: aDictionary
		"Private - set the Dictionary which maps between
		item handles and items to aDictionary."
	handleItemMap := aDictionary! 
notifySelchanging: address
        "Private - handle host notification of the selection changing."
    ^nil
!  
notifyItemexpanding: address
        "Private - handle host notification of an item expanding or contracting."
    | tvNotify tvItem item |
    tvNotify := WinNmTreeview atAddress: address.
    tvItem := tvNotify itemNew.
    ( item := self itemFromHandle: tvItem hItem ) isNil ifTrue: [ ^self ].
    tvNotify action = TveExpand
        ifTrue: [
            self realizeChildrenFor: item.
            item childrenExpanded: true.
            self triggerEvent: #expanded: with: item object ]
        ifFalse: [
            item childrenExpanded: false.
            self triggerEvent: #collapsed: with: item object ].
    ^nil! 
selectedItem
		"Answer the currently selected item."
	^self value!  
expandItem: anObject
        "Expand the children of anObject."
    | itemHandle |
    ( itemHandle := self handleFromObject: anObject ) isNil ifTrue: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: TvmExpand
        wparam: TveExpand
        lparam: itemHandle!   
characterInput: aCharacter
        "Private - Process the character input message."
    self propertyAt: #characterTyped put: aCharacter.
    self triggerEvent: #characterTyped: with: aCharacter!
contents: aCollection
        "Set the contents of the receiver to aCollection."
    self itemsAttribute: ( aCollection asArray collect: [ :obj |
        obj isTreeViewItem
            ifTrue: [ obj ]
            ifFalse: [ TreeViewItem new object: obj ] ] ).
    self isHandleOk ifTrue: [ self setContents ]!   
deleteItem: anObject
        "Delete anObject from the items in the receiver."
    | itemHandle |
    ( itemHandle := self handleFromObject: anObject ) isNil ifTrue: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: TvmDeleteitem
        wparam: 0
        lparam: itemHandle!
getChildrenFor: aTreeViewItem
        "Private - answer the children for aTreeViewItem,
        retrieving via the #needsChildrenFor: event if necessary."
    | childItems |
    aTreeViewItem = self dummyItemLabel ifTrue: [ ^Array new ].
    aTreeViewItem children notNil ifTrue: [ ^aTreeViewItem children ].
    childItems := self
        triggerEvent: #needsChildrenFor:
        withArguments: ( Array with: aTreeViewItem object )
        ifNotHandled: [ Array new ].
    aTreeViewItem children: childItems.
    ^aTreeViewItem children! 
getChildrenExpandedFor: aTreeViewItem
        "Private - answer whether the child items of aTreeViewItem are to
        be initially expanded (a Boolean), retrieving via the #needsChildrenExpandedFor:
        event if necessary."
    | childrenExpanded |
    aTreeViewItem = self dummyItemLabel ifTrue: [ ^false ].
    aTreeViewItem childrenExpanded notNil ifTrue: [ ^aTreeViewItem childrenExpanded ].
    childrenExpanded := self
        triggerEvent: #needsChildrenExpandedFor:
        withArguments: ( Array with: aTreeViewItem object )
        ifNotHandled: [ false ].
    aTreeViewItem childrenExpanded: childrenExpanded.
    ^childrenExpanded! 
getSelectedImageFor: aTreeViewItem
        "Private - answer the selected image for aTreeViewItem,
        retrieving via the #needsSelectedImageFor: event if necessary."
    | image |
    aTreeViewItem = self dummyItemLabel ifTrue: [ ^nil ].
    aTreeViewItem selectedImage notNil ifTrue: [ ^aTreeViewItem selectedImage ].
    image := self
        triggerEvent: #needsSelectedImageFor:
        withArguments: ( Array with: aTreeViewItem object )
        ifNotHandled: [ nil ].
    aTreeViewItem selectedImage: image.
    ^image! 
indent: anInteger
        "Set the indent width (pixels) of the receiver to anInteger."
    self propertyAt: #indent put: anInteger.
    self isHandleOk ifTrue: [ self setIndent ]!   
button1Up: aPoint
    ( self propertyAt: #dragging ) notNil ifTrue: [
        CommonControlsDLL current imageListEndDrag.
"        Cursor showCursor: true."
        self propertyAt: #dragging put: nil ].
    super button1Up: aPoint! 
notifyDblclk: address
        "Private - handle host notification of a mouse double-click."
    self valueAttribute notNil ifTrue: [
        self triggerEvent: #doubleClicked: with: self valueAttribute object ].
    ^nil! 
realizeAllChildrenFor: item
        "Private - expand all children for item, replacing dummy child items with 'real'
        child items along the way."
    | childItems |
    CursorManager execute changeFor: [
        ( self getHasChildrenFor: item ) ifTrue: [
            ( self deleteDummyItem: item ) ifTrue: [
                childItems := self getChildrenFor: item.
                self
                    insert: childItems
                    parent: item
                    parentHandle: ( self handleFromItem: item ).
                childItems do: [ :childItem | self realizeAllChildrenFor: childItem ] ] ] ]!
itemHandleMap
		"Private - answer the IdentityDictionary which maps between
		item handles and their corresponding items."
	^itemHandleMap!
itemHandleMap: anIdentityDictionary
		"Private - set the IdentityDictionary which maps between
		item handles and their corresponding items to anIdentityDictionary."
	itemHandleMap := anIdentityDictionary!  
keyboardInputEventFromKeydown: tvKeydown
        "Private - answer a KeyboardInputEvent whose contents are extracted
        from tvKeydown."
    | event shiftState virtualKey character |
    event := KeyboardInputEvent new.

    shiftState := 0.
    ( Notifier isShiftKeyDown ) ifTrue: [ shiftState := shiftState bitOr: AfShift ].
    ( Notifier isControlKeyDown ) ifTrue: [ shiftState := shiftState bitOr: AfControl ].
    ( Notifier isAltKeyDown ) ifTrue: [ shiftState := shiftState bitOr: AfAlt ].
    event shiftState: shiftState.

    virtualKey := tvKeydown wVKey.
    event virtualKey: virtualKey.
    character := UserLibrary mapVirtualKey: virtualKey mapType: 2.
    ( character > 0 and: [ ( UserLibrary getKeyState: virtualKey ) > 0 ] ) ifTrue: [
        character := Character value: character.
        event characterValue: character ].

    ^event! 
triggerAboutToChangeLabel: item to: newValue
        "Private - trigger the aboutToChangeLabel:to: event."
    self triggerEvent: #aboutToChangeLabel:to: withArguments: ( Array with: item object with: newValue )!
isOkToChangeLabel: item to: newValue
        "Private - answer whether it is OK to change (direct edit) the label
        of the item to the proposed new value.  Triggers the veto-able
        #aboutToChangeLabel:to: event."
    [ self triggerAboutToChangeLabel: item to: newValue ] on: VetoAction do: [ ^false ].
    ^true! 
setImageList
        "Private - apply the receiver's image list to the host control."
    self imageList notNil ifTrue: [
        UserLibrary
            sendMessage: self handle
            msg: TvmSetimagelist
            wparam: TvsilNormal
            lparam: self imageList asParameter ]!  
notifyBeginrdrag: address
        "Private - handle host notification of a right mouse button drag initiation."
    ^nil!   
getHasChildrenFor: aTreeViewItem
        "Private - answer whether aTreeViewItem has any child items (aBoolean),
        retrieving the answer via the #needsHasChildrenFor: event if necessary."
    | hasChildren |
    aTreeViewItem = self dummyItemLabel ifTrue: [ ^false ].
    aTreeViewItem hasChildren notNil ifTrue: [ ^aTreeViewItem hasChildren ].
    hasChildren := self
        triggerEvent: #needsHasChildrenFor:
        withArguments: ( Array with: aTreeViewItem object )
        ifNotHandled: [ ( self getChildrenFor: aTreeViewItem ) notEmpty ].
    aTreeViewItem hasChildren: hasChildren.
    ^hasChildren!
getStringFor: aTreeViewItem
        "Private - answer the string for aTreeViewItem,
        retrieving via the #needsStringFor: event if necessary."
    | string |
    aTreeViewItem = self dummyItemLabel ifTrue: [ ^aTreeViewItem ].
    aTreeViewItem string notNil ifTrue: [ ^aTreeViewItem string ].
    string := self
        triggerEvent: #needsStringFor:
        withArguments: ( Array with: aTreeViewItem object )
        ifNotHandled: [ aTreeViewItem object asString ].
    aTreeViewItem string: string.
    ^string!   
hasLines: aBoolean
        "Determine whether the receiver has lines, according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: TvsHaslines ]
        ifFalse: [ self removeStyle: TvsHaslines ].
    self setStyle: self style!
buildWindow: parentWindow
        "Private - Create the window for the receiver, initializing the
        common controls library if necessary."
    CommonControlsDLL current.
    ^super buildWindow: parentWindow! 
getVisibleCount
        "Private - answer the number of lines currently visible."
    ^UserLibrary
        sendMessage: self handle
        msg: TvmGetvisiblecount
        wparam: 0
        lparam: 0!
initialize
        "Private - Initialize the receiver."
    super initialize.
    self itemHandleMap: IdentityDictionary new.
    self handleItemMap: Dictionary new! 
realizeChildrenFor: item
        "Private - expand immediate children for item, replacing dummy child items with 'real'
        child items along the way."
    | childItems itemHandle |
    CursorManager execute changeFor: [
        ( self deleteDummyItem: item ) ifTrue: [
            childItems := self getChildrenFor: item.
            ( itemHandle := self handleFromItem: item ) isNil ifTrue: [ ^self ].
            self
                insert: childItems
                parent: item
                parentHandle: itemHandle ] ]! 
editItemLabel: anObject
        "Begin direct edit for the specified item."
    | itemHandle |
    ( itemHandle := self handleFromObject: anObject ) isNil ifTrue: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: TvmEditlabel
        wparam: 0
        lparam: itemHandle!
isOkToEditLabel: item
        "Private - answer whether it is OK to direct edit the label
        of the given item.  Triggers the veto-able #aboutToEditLabel: event."
    [ self triggerAboutToEditLabel: item ] on: VetoAction do: [ ^false ].
    ^true!  
imageList
        "Private - answer the (normal) image list."
    ^imageList!   
imageList: anImageList
        "Private - set the (normal) image list to anImageList."
    imageList := anImageList!
itemFromHandle: anItemHandle
		"Private - answer the item corresponding to the given item handle."
	^self handleItemMap at: anItemHandle ifAbsent: [ nil ]! 
notifyEndlabeledit: address
		"Private - process host notification of completion of direct edit."
    | dispinfo tvItem string item |
    dispinfo := WinTvDispinfo atAddress: address.
    tvItem := dispinfo item.
    tvItem pszText = 0 ifTrue: [ ^nil ].  "edit cancelled"
    string := String fromAddress: tvItem pszText asExternalAddress.
    ( item := self itemFromHandle: tvItem hItem ) isNil ifTrue: [ ^self ].
    ( self isOkToChangeLabel: item to: string ) ifFalse: [ ^nil ].
    tvItem mask: LvifText.
    UserLibrary
        sendMessage: self handle
        msg: TvmSetitem
        wparam: 0
        lparamStruct: tvItem asParameter.
    self triggerEvent: #changedLabel:to: withArguments: ( Array with: item object with: string ).
    ^nil

! 
notifySelchanged: address
    | tvNotify tvItem item |
    tvNotify := WinNmTreeview atAddress: address.
    tvNotify action = TvcUnknown ifTrue: [ ^self ].  "only interested in user selection."
    tvItem := tvNotify itemNew.
    item := self itemFromHandle: tvItem hItem.
    self valueAttribute: item. "index not very meaningful here, so save item as selection."
    self triggerEvent: #changed: with: item object.
    ^nil
! 
wmChar: wparam with: lparam
        "Private - Process the character input message."
	| return |
	"to keep control from beeping when Tab / BackTab are pressed,
	return 1 to indicate that we're handling that input."
	wparam = TabKey ifTrue: [ return := 1 ].
	super wmChar: wparam with: lparam.
	^return! 
getSelectedItem
        "Private - retrieve the currently selected item from the host control."
    | itemHandle |
    itemHandle := UserLibrary
        sendMessage: self handle
        msg: TvmGetnextitem
        wparam: TvgnCaret
        lparam: 0.
    "convert return value from signed to unsigned."
    itemHandle := ( ExternalLong fromInteger: itemHandle ) asUnsignedInteger.
    ^self itemFromHandle: itemHandle!  
handleFromObject: anObject
		"Private - answer the item handle for the given object."
	| anItem |
	anItem := self itemHandleMap keys detect: [ :item | item object = anObject ] ifNone: [ ^nil ].
	^self handleFromItem: anItem!  
notifyBeginlabeledit: address
		"Private - process host notification of start of direct edit."
    | dispinfo tvItem item |
    dispinfo := WinTvDispinfo atAddress: address.
    tvItem := dispinfo item.
    ( item := self itemFromHandle: tvItem hItem ) isNil ifTrue: [ ^self ].
    ( self isOkToEditLabel: item ) ifFalse: [ ^true ].  "contrary to Win32 documentation, true aborts"
    ^nil! 
releaseImageList
		"Private - release the receiver's image list."
    self imageList notNil ifTrue: [ self imageList release ]! 
collapseItem: anObject
        "Collapse the children of anObject."
    | itemHandle |
    ( itemHandle := self handleFromObject: anObject ) isNil ifTrue: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: TvmExpand
        wparam: TveCollapse
        lparam: itemHandle! 
handleFromItem: anObject
		"Private - answer the item handle for the given item."
	^self itemHandleMap at: anObject ifAbsent: [ nil ]!  
getCount
        "Private - answer the number of items contained in the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TvmGetcount
        wparam: 0
        lparam: 0!  
defaultStyle
        "Private - Answer the default style for the receiver."
    ^TvsHasbuttons | TvsHaslines | TvsLinesatroot  | TvsShowselalways | WsBorder | WsHscroll | WsVscroll!   
hasLinesAtRoot: aBoolean
        "Set whether the receiver has lines at the root level, according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: TvsLinesatroot ]
        ifFalse: [ self removeStyle: TvsLinesatroot ].
    self setStyle: self style!
notifyRClick: address
        "Private - handle host notification of a right button mouse click."
    | aPoint |
    self
        triggerEvent: #rightClicked
        ifNotHandled: [
            aPoint := Cursor sense mapToWindow: self.
            self doPopupMenuAt: aPoint ].
    ^nil!   
createImageList
        "Private - create the image list for the receiver."
    self useImages ifFalse: [ ^self ].
    self imageList: ImageList new!  
hasButtons: aBoolean
        "Determine whether the receiver has buttons for expanding and collapsing items,
        according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: TvsHasbuttons ]
        ifFalse: [ self removeStyle: TvsHasbuttons ].
    self setStyle: self style!
indent
        "Answer the indent width (pixels) of the receiver."
    ^self propertyAt: #indent!   
itemsAttribute: aCollection
        "Private - set the items attribute to aCollection."
    items := aCollection!   
setContents
        "Private - set the contents of the host control."
    self
        disableRedraw;
        deleteAllFromControl;
        releaseImageList;
        createImageList;
        setItems;
        setImageList;
        enableRedraw! 
useImages
        "Answer whether any specified images in the list contents are to be used
        in displaying the list items (default is true if images have been supplied)."
    ^self propertyAt: #useImages ifAbsent: [ true ]!  
useImages: aBoolean
        "Determinate whether any specified images in the list contents are to be used
        in displaying the list items (default is true if images have been supplied)."
    self useImages = aBoolean ifTrue: [ ^self ].
    self propertyAt: #useImages put: aBoolean.
    self isHandleOk ifTrue: [ self recreateWindow ]! 
validate
        "Private - The host window for the receiver was
        just created or recreated."
    super validate.
    self indent notNil ifTrue: [ self setIndent ].
    self setContents.
    self valueAttribute notNil ifTrue: [ self selectItem: self valueAttribute object ]!   
getIndent
        "Private - answer the indent width of the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TvmGetindent
        wparam: 0
        lparam: 0! 
selection
		"Answer the currently selection."
	^self selectedItem!  
selection: anObject
        "Set the current selection to anObject."
    self selectItem: anObject! 
canApplyStyle
        "Private - answer whether the receiver's style can change
        after it has been created."
    self osWorkaround.  "changing styles via SetWindowLong fails on NT 3.51"
    ^OperatingSystem isWindowsNT not!
selectItem: anObject
		"Set the current selection to anObject."
    | itemHandle |
    itemHandle := self handleFromObject: anObject.
    itemHandle isNil ifTrue: [ "may be buried in not yet created children, so build them and try again"
        self disableRedraw.
        self contents do: [ :item | self realizeAllChildrenFor: item ].
        self enableRedraw.
        ( itemHandle := self handleFromObject: anObject ) isNil ifTrue: [ ^nil ] ].
    self ensureVisible: anObject.
    UserLibrary
        sendMessage: self handle
        msg: TvmSelectitem
        wparam: TvgnCaret
        lparam: itemHandle!
setItems
        "Private - apply the receiver's items to the host control."
    self contents notNil ifTrue: [
        self insert: self contents parent: nil parentHandle: TviRoot ]!
button1Move: aPoint
        "Private - use the button 1 move notification to process drag feedback."
    ( self propertyAt: #dragging ) notNil ifTrue: [
        CommonControlsDLL current
           imageListDragMoveX: aPoint x y: aPoint y ].
    super button1Move: aPoint! 
setIndent
        "Private - apply the current indent setting to the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TvmSetindent
        wparam: self indent
        lparam: 0!  
deleteAllFromControl
        "Private - delete the control contents."
    UserLibrary
        sendMessage: self handle
        msg: TvmDeleteitem
        wparam: 0
        lparam: TviRoot!
setIndent: anInteger
        "Private - apply the indent width anInteger to the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TvmSetindent
        wparam: anInteger
        lparam: 0! 
insert: aCollection parent: parentObject parentHandle: parentHandle
    | tvInsert tvItem string address hasChildObjects childObjects itemHandle expanded image imageIndex |
    aCollection do: [ :object |
        tvItem := WinTvItem new.
        tvItem mask: TvifText | TvifChildren | TvifState.

        expanded := self getChildrenExpandedFor: object.
        expanded ifTrue: [ tvItem state: TvisExpanded. tvItem stateMask: TvisExpanded ].

        string := ( self getStringFor: object ) asParameter.
        address := ExternalAddress copyToNonSmalltalkMemory: string.
        tvItem pszText: address asInteger.

        hasChildObjects := self getHasChildrenFor: object.

        ( self useImages and: [ ( image := self getImageFor: object ) notNil ] ) ifTrue: [
            tvItem mask: tvItem mask | TvifImage.
            ( imageIndex := self imageList indexOf: image ) ~= 0
                ifTrue: [ tvItem iImage: imageIndex - 1 ]
                ifFalse: [
                    self imageList add: image.
                    tvItem iImage: self imageList size - 1 ] ].
        ( self useImages and: [ ( image := self getSelectedImageFor: object ) notNil ] ) ifTrue: [
            tvItem mask: tvItem mask | TvifSelectedimage.
            ( imageIndex := self imageList indexOf: image ) ~= 0
                ifTrue: [ tvItem iSelectedImage: imageIndex - 1 ]
                ifFalse: [
                    self imageList add: image.
                    tvItem iSelectedImage: self imageList size - 1 ] ].

        hasChildObjects
            ifTrue: [
                expanded
                    ifTrue: [
                        childObjects := hasChildObjects ifTrue: [ self getChildrenFor: object ] ifFalse: [ nil ].
                        tvItem cChildren: childObjects size ]
                    ifFalse: [  "if collapsed, insert a dummy initially, and replace with real children when expanded"
                        childObjects := Array with: self dummyItemLabel.
                        tvItem cChildren: 1 ] ]
            ifFalse: [ tvItem cChildren: 0 ].

        tvInsert := WinTvInsertstruct new.
        tvInsert hParent: parentHandle.
        tvInsert hInsertAfter: TviLast.
        tvInsert item: tvItem.
        itemHandle := UserLibrary
            sendMessage: self handle
            msg: TvmInsertitem
            wparam: 0
            lparamStruct: tvInsert asParameter.
        "convert return value from signed to unsigned"
        itemHandle := ( ExternalLong fromInteger: itemHandle ) asUnsignedInteger.
        address free.

        object = self dummyItemLabel
            ifFalse: [ self itemHandleMap at: object put: itemHandle ].
        self handleItemMap at: itemHandle put: object.

        hasChildObjects ifTrue: [ self insert: childObjects parent: object parentHandle: itemHandle ] ]!  
notifyBegindrag: address
        "Private - handle host notification of a drag initiation."
    | nmTreeview himl itemRect level indent |
    nmTreeview := WinNmTreeview atAddress: address.
    himl := UserLibrary
        sendMessage: self handle
        msg: TvmCreatedragimage
        wparam: 0
        lparam: nmTreeview itemNew hItem.
    itemRect := WinRectangle new.
    itemRect uLongAtOffset: 0 put: nmTreeview itemNew hItem.
    UserLibrary
        sendMessage: self handle
        msg: TvmGetitemrect
        wparam: true asParameter
        lparamStruct: itemRect asParameter.
    level := nmTreeview itemNew lParam.
    indent := self getIndent.
    CommonControlsDLL current
        imageListBeginDrag: himl
        hwndLock: self handle
        index: 0
        x: nmTreeview ptDrag x
        y: nmTreeview ptDrag y
        dxHotspot: nmTreeview ptDrag x - ( ( level - 1 ) * indent )
        dyHotspot: nmTreeview ptDrag y - itemRect yTop.
"    Cursor showCursor: false."
    self propertyAt: #dragging put: true.
    ^nil! 
contents
        "Answer the contents of the receiver."
    ^self itemsAttribute!   
defaultExtendedStyle
        "Private - answer the default extended style flags for the
        receiver.  Add the 3d border style."
    ^OperatingSystem versionMajor >= 4 ifTrue: [ WsExClientedge ] ifFalse: [ 0 ]! 
deleteAll
        "Delete the whole list."
    self deleteAllFromControl.
    self itemsAttribute: nil!
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process cursor keys."
    | virtualKey |
    ( virtualKey := aKeyboardInputEvent virtualKey ) notNil ifTrue: [
        ( virtualKey == TabKey or: [ virtualKey == BacktabKey ] )
            ifTrue: [ self tabKeyInput: aKeyboardInputEvent ] ].

    super keyboardInput: aKeyboardInputEvent!   
showSelectionAlways: aBoolean
        "Determine whether the receiver displays its selection even when not active,
        according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: TvsShowselalways ]
        ifFalse: [ self removeStyle: TvsShowselalways ]!
value
        "Answer the current selection."
    ^self valueAttribute isNil ifTrue: [ nil ] ifFalse: [ self valueAttribute object ]!   
itemsAttribute
        "Answer the contents of the receiver."
    ^items!   
restoreSelected: anObject
        "Private - Select anObject."
    self
"        triggerEvent: #needsContents;"
        selection: anObject!  
sizeInBytes
    ^48! 
inspectorFields
    ^self inspectorClass fields: #( #hParent #hInsertAfter #item )!  
ptDrag
    ^WinPoint usingBytes: ( self bytesAtOffset: 96 count: WinPoint sizeInBytes )! 
action
    ^self longAtOffset: 12!   
itemNew
    ^WinTvItem usingBytes: ( self bytesAtOffset: 56 count: WinTvItem sizeInBytes )!  
itemOld
    ^WinTvItem usingBytes: ( self bytesAtOffset: 16 count: WinTvItem sizeInBytes )!  
isTreeViewItem
		"Answer whether the receiver is a kind of TreeViewItem."
	^false!  
sizeInBytes
    ^52! 
inspectorFields
    ^self inspectorClass fields: #( #hdr #item )!
flags
    ^self uLongAtOffset: 14!   
wVKey
    ^self uShortAtOffset: 12!  
item
    ^WinTvItem usingBytes: ( self bytesAtOffset: 12 count: WinTvItem sizeInBytes )! 
item: aWinTvItem
    self bytesAtOffset: 12 put: aWinTvItem contents!
children
        "Answer the child items (instances of the receiver's class) of the receiver."
    ^children!   
printOn: aStream
        "Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, '{'; cr.
	self printOn: aStream indent: 0.
	aStream nextPutAll: '}'; cr!
childrenExpanded
        "Answer a Boolean which indicates whether child items are expanded."
    ^childrenExpanded!
hasChildren: aBoolean
        "Set a Boolean to indicate whether the receiver has any child items."
    hasChildren := aBoolean!
hasChildren
        "Answer a Boolean which indicates whether the receiver has any child items."
    ^hasChildren!  
isTreeViewItem
		"Answer whether the receiver is a kind of TreeViewItem."
	^true!   
children: aCollection
        "Set the child items of the receiver to aCollection; turn any objects
        in aCollection which are not instances of the receiver's class into
        instances of the receiver's class."
    children := aCollection asArray collect: [ :obj |
        obj class == self class ifTrue: [ obj ] ifFalse: [ self class new object: obj ] ]! 
childrenExpanded: aBoolean
        "Set a Boolean to indicate whether child items are expanded."
    childrenExpanded := aBoolean!  
printOn: aStream indent: anInteger
		"Append the string representation of the receiver to aStream, starting at
		the receiver item, assuming that anInteger is the number of levels deep
		in the hierarchy that the receiver is at."
	anInteger * 3 timesRepeat: [ aStream nextPutAll: ' ' ].
	aStream nextPutAll: ( self string isNil ifTrue: [ self object asString ] ifFalse: [ self string ] ).
	aStream cr.
	self children notNil ifTrue: [
		self children do: [ :childItem | childItem printOn: aStream indent: anInteger + 1 ] ]!
selectedImage
        "Answer the selected image for the receiver (an Icon or Bitmap,
        usually 16x16 pixels)."
    ^selectedImage!  
selectedImage: anImage
        "Set the image for the receiver to anImage (an Icon or Bitmap,
        usually 16x16 pixels)."
    selectedImage := anImage!
image
        "Answer the image for the receiver (an Icon or Bitmap,
        usually 16x16 pixels)."
    ^image!   
image: anImage
        "Set the image for the receiver to anImage (an Icon or Bitmap,
        usually 16x16 pixels)."
    image := anImage!
hInsertAfter
    ^self uLongAtOffset: 4! 
item
    ^WinTvItem usingBytes: ( self bytesAtOffset: 8 count: WinTvItem sizeInBytes )!  
hParent
    ^self uLongAtOffset: 0!  
hParent: anInteger
    self uLongAtOffset: 0 put: anInteger! 
hInsertAfter: anInteger
    self uLongAtOffset: 4 put: anInteger!
item: aWinTvItem
    self bytesAtOffset: 8 put: aWinTvItem contents!