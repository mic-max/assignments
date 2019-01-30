3.1.0.106
   
sizeInBytes
    ^44! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #hdr #iItem #iSubItem #uNewState #uOldState #uChanged #ptAction #lParam )!   
lParam
    ^self longAtOffset: 40!   
iSubItem
    ^self longAtOffset: 16! 
iItem
    ^self longAtOffset: 12!
uChanged
    ^self uLongAtOffset: 28!
ptAction
    ^WinPoint usingBytes: ( self bytesAtOffset: 32 count: WinPoint sizeInBytes )!   
uNewState
    ^self uLongAtOffset: 20!   
uOldState
    ^self uLongAtOffset: 24!   
isListViewItem
		"Answer whether the receiver is a kind of ListViewItem."
	^false!  
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    ^Dictionary new
        at: NmClick put: #notifyClick: ;
        at: NmDblclk put: #notifyDblclk: ;
        at: NmRclick put: #notifyRClick: ;
        at: LvnItemchanged put: #notifyItemchanged: ;
        at: LvnColumnclick put: #notifyColumnclick: ;
        at: LvnBeginlabeledit put: #notifyBeginlabeledit: ;
        at: LvnEndlabeledit put: #notifyEndlabeledit: ;
        at: LvnGetdispinfo put: #notifyGetdispinfo: ;
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
        add: #needsSmallImageFor: ;
        add: #needsColumnsFor: ;

        add: #aboutToEditLabel: ;
        add: #aboutToChangeLabel:to: ;
        add: #changedLabel:to: ;

        add: #columnClicked: ;
        add: #changed: ;
        add: #clicked: ;
        add: #clickedIndex: ;
        add: #doubleClicked: ;
        add: #doubleClickedIndex: ;
        add: #selected: ;

        add: #characterTyped: ;
        yourself!
triggerAboutToEditLabel: item
        "Private - trigger the aboutToEditLabel: event."
    self triggerEvent: #aboutToEditLabel: with: item object! 
notifyDblclk: address
        "Private - handle host notification of a mouse double-click."
    | index |
    ( index := self getFocusedIndex ) isNil ifTrue: [ ^self ].
    self triggerEvent: #doubleClickedIndex: with: index.
    self triggerEvent: #doubleClicked: with: ( self items at: index ) object.
    ^nil!   
sortByColumn: index
        "Set the index of the column which is used to sort by to index."
    self propertyAt: #sortByColumn put: index! 
setHeadings
        "Private - apply the receiver's column headings to the host control."
    | lvColumn heading |
    1 to: self headings size do: [ :index |
        heading := self headings at: index.
        lvColumn := heading asWinLvColumn.
        lvColumn iSubItem: index.
        UserLibrary
            sendMessage: self handle
            msg: LvmInsertcolumn
            wparam: index - 1
            lparamStruct: lvColumn asParameter.
        lvColumn address free ]!  
isExtendedSelect
        "Answer whether the receiver is of the extended select style."
    ^( self hasStyle: LvsSinglesel ) not!   
getSmallImageFor: aListViewItem
        "Private - answer the small image for aListViewItem,
        retrieving via the #needsSmallImageFor: event if necessary."
    | image |
    aListViewItem smallImage notNil ifTrue: [ ^aListViewItem smallImage ].
    image := self
        triggerEvent: #needsSmallImageFor:
        withArguments: ( Array with: aListViewItem object )
        ifNotHandled: [ nil ].
    aListViewItem smallImage: image.
    ^image! 
selectedIndices
        "Answer the indices of the items selected.  Assumes the receiver is extended selection."
    self isHandleOk ifTrue: [ self getSelection ].
    ^self valueAttribute!  
selectedItems
        "Answer the currently selected items.  Assumes the receiver is extended selection."
	^self selectedIndices collect: [ :index | ( self items at: index ) object ]! 
imageList
        "Private - answer the (normal) image list."
    ^imageList!   
setImageLists
        "Private - apply the receiver's image lists to the host control."
    self imageList notNil ifTrue: [ self setImageList: self imageList type: LvsilNormal ].
    self smallImageList notNil ifTrue: [ self setImageList: self smallImageList type: LvsilSmall ]! 
notifyItemchanged: address
        "Private - process host notification of item state changed."
    | lvNotify index item |
    self selectedIndices.
    lvNotify := WinNmListview atAddress: address.
    ( lvNotify uNewState & LvisSelected ) = LvisSelected ifTrue: [
        index := lvNotify iItem + 1.  "0 based"
        item := self items at: index.
        self triggerEvent: #changed: with: item object ].
    ^nil! 
notifyRClick: address
        "Private - handle host notification of a right button mouse click."
    | aPoint |
    self
        triggerEvent: #rightClicked
        ifNotHandled: [
            aPoint := Cursor sense mapToWindow: self.
            self doPopupMenuAt: aPoint ].
    ^nil!   
createImageLists
        "Private - create the image lists for the receiver."
    self useImages ifFalse: [ ^self ].
    self imageList: ImageList new.
    self smallImageList: ImageList new!   
releaseImageLists
        "Private - release the host resources held onto by image lists."
    self imageList notNil ifTrue: [ self imageList release ].
    self smallImageList notNil ifTrue: [ self smallImageList release ]!   
useImages
        "Answer whether any specified images in the list contents are to be used
        in displaying the list items (default is true if images have been supplied)."
    ^self propertyAt: #useImages ifAbsent: [ true ]!  
setContents
        "Private - set the contents of the host control."
    self contents isNil ifTrue: [ ^self ].
    self
        disableRedraw;
        deleteAllFromControl;
        createImageLists;
        setItems;
        setImageLists;
        deleteAllColumnsFromControl;
        setHeadings;
        setSelection;
        enableRedraw!   
setAlignStyle: alignStyleInteger
        "Private - set and apply alignStyleInteger as the current align style."
    | currentStyle mask |
    currentStyle := self style notNil ifTrue: [ self style ] ifFalse: [ self getStyle ].
    mask := 16rFFFFFFFF bitXor: LvsAlignmask.
    currentStyle := currentStyle bitAnd: mask.
    currentStyle := currentStyle | alignStyleInteger.
    self setStyle: currentStyle!
setItems
        "Private - apply the receiver's items to the host control."
    | item string lvItem address image smallImage imageIndex smallImageIndex |
    1 to: self contents size do: [ :index |
        item := self contents at: index.
        lvItem := WinLvItem new.
        lvItem mask: LvifText | LvifParam.

        string := ( self getStringFor: item ) asParameter.
        address := ExternalAddress copyToNonSmalltalkMemory: string.
        lvItem pszText: address asInteger.

        ( image := self getImageFor: item ) notNil ifTrue: [
            lvItem mask: lvItem mask | LvifImage.
            ( imageIndex := self imageList indexOf: image ) ~= 0
                ifTrue: [ lvItem iImage: imageIndex - 1 ]
                ifFalse: [
                    self imageList add: image.
                    lvItem iImage: self imageList size - 1 ] ].

        ( smallImage := self getSmallImageFor: item ) notNil ifTrue: [
            lvItem mask: lvItem mask | LvifImage.
            ( smallImageIndex := self smallImageList indexOf: smallImage ) ~= 0
                ifTrue: [ lvItem iImage: imageIndex - 1 ]
                ifFalse: [
                    self smallImageList add: smallImage.
                    lvItem iImage: self smallImageList size - 1 ] ].

        lvItem iItem: index - 1.  "0 based"
        lvItem lParam: index.  "used for sorting"

        UserLibrary
            sendMessage: self handle
            msg: LvmInsertitem
            wparam: 0
            lparamStruct: lvItem asParameter.

        address free ]!  
headings
		"Answer the receiver's collection of headings (HeaderItems)."
    ^headings! 
deleteAllFromControl
        "Private - delete the control contents."
    UserLibrary
        sendMessage: self handle
        msg: LvmDeleteallitems
        wparam: 0
        lparam: 0!  
sortAscending: aBoolean
        "Set whether the receiver is supposed to sort ascending (true) or descending (false)."
    self propertyAt: #sortAscending put: aBoolean!   
smallIconView
        "Set and apply the Small Icon View style."
    self setViewStyle: LvsSmallicon!   
iconView
        "Set and apply the (Normal) Icon View style."
    self setViewStyle: LvsIcon!  
notifyBegindrag: address
        "Private - handle host notification of a button drag initiation."
    ^nil!
clearSelectionsPrivate
        "Private - make no items in the host control selected."
    self selectItemIndices: ( 1 to: self items size ) state: false!  
showSelectionAlways: aBoolean
        "Determine whether the receiver displays its selection even when not active,
        according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: LvsShowselalways ]
        ifFalse: [ self removeStyle: LvsShowselalways ]!
autoArrange: aBoolean
        "Enable or disable auto arrange, according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: LvsAutoarrange ]
        ifFalse: [ self removeStyle: LvsAutoarrange ].
    self setStyle: self style! 
selectItemIndices: indices state: aBoolean
        "Private - select or deselect the given item indices."
    | lvItem mask |
    lvItem := WinLvItem new.
    mask := aBoolean ifTrue: [ LvisSelected ] ifFalse: [ 0 ].
    indices do: [ :index |
        lvItem state: mask.
        lvItem stateMask: LvisSelected.
        lvItem mask: LvifState.
        UserLibrary
            sendMessage: self handle
            msg: LvmSetitemstate
            wparam: index - 1
            lparamStruct: lvItem asParameter ]!  
windowClass
        "Private - Answer the window class for the receiver."
    ^WcListview!  
selectedIndex
        "Answer the index of the selected item.  Assumes the receiver is single selection."
    | selectedIndices |
    ^( selectedIndices := self selectedIndices ) isEmpty
        ifTrue: [ nil ]
        ifFalse: [ selectedIndices first ]!   
reportView
        "Set and apply the Details (Report) View style."
    self setViewStyle: LvsReport!   
listView
        "Set and apply the List View style."
    self setViewStyle: LvsList!   
backColor: aColor
        "Set the background color of the receiver."
    self propertyAt: #backColor put: aColor.
    self isHandleOk ifFalse: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: LvmSetbkcolor
        wparam: 0
        lparam: aColor asInteger.
    UserLibrary
        sendMessage: self handle
        msg: LvmSettextbkcolor
        wparam: 0
        lparam: aColor asInteger.
    self invalidateRect: nil!
deselectItem: anObject
        "Deselect anObject in the receiver.  Assumes the receiver is extended selection."
    | index |
    ( index := self indexOf: anObject ) isNil ifTrue: [ ^self ].
    self deselectIndex: index!
foreColor: aColor
        "Set the foreground color of the receiver."
    self propertyAt: #foreColor put: aColor.
    self isHandleOk ifFalse: [ ^self ].
    UserLibrary
        sendMessage: self handle
        msg: LvmSettextcolor
        wparam: 0
        lparam: aColor asInteger.
    self invalidateRect: nil!   
selectedItem
        "Answer the currently selected item.  Assumes the receiver is single selection."
    | index |
    ^( index := self selectedIndex ) isNil
        ifTrue: [ nil ]
        ifFalse: [ ( self items at: index ) object ]! 
contents: aCollection
        "Set the contents of the receiver to aCollection."
    self itemsAttribute: ( aCollection asArray collect: [ :obj |
        obj isListViewItem
            ifTrue: [ obj ]
            ifFalse: [ ListViewItem new object: obj ] ] ).
    self isHandleOk ifTrue: [ self setContents ]!   
deleteItem: anObject
        "Delete anObject from the receiver."
    | index |
    ( index := self indexOf: anObject ) isNil ifTrue: [ ^self ].
    self deleteIndex: index! 
smallImageList: anImageList
        "Private - set the small image list to anImageList."
    smallImageList := anImageList! 
isOkToChangeLabel: item to: newValue
        "Private - answer whether it is OK to change (direct edit) the label
        of the item to the proposed new value.  Triggers the veto-able
        #aboutToChangeLabel:to: event."
    [ self triggerAboutToChangeLabel: item to: newValue ] on: VetoAction do: [ ^false ].
    ^true! 
getTopIndex
        "Answer the index of the first visible item.  Only valid
        in List View and Report View"
    | result |
    self isHandleOk ifFalse: [ ^nil ].
    result := UserLibrary
        sendMessage: self handle
        msg: LvmGettopindex
        wparam: 0
        lparam: 0.
    ^result + 1!   
notifyBeginrdrag: address
        "Private - handle host notification of a right mouse button drag initiation."
    ^nil!   
getStringFor: aListViewItem
        "Private - answer the string for aListViewItem,
        retrieving via the #needsStringFor: event if necessary."
    | string |
    aListViewItem string notNil ifTrue: [ ^aListViewItem string ].
    string := self
        triggerEvent: #needsStringFor:
        withArguments: ( Array with: aListViewItem object )
        ifNotHandled: [ aListViewItem object asString ].
    aListViewItem string: string.
    ^string!
headings: aCollection
        "Set the headings to aCollection."
    self headingsAttribute: ( aCollection collect: [ :o |
        o isHeaderItem
            ifTrue: [ o ]
            ifFalse: [ HeaderItem new object: o ] ] ).
    self isHandleOk ifTrue: [ self setHeadings ]!
initialize
        "Private - set the initial state of the receiver."
    super initialize.
    self valueAttribute: OrderedCollection new!
getFocusedIndex
        "Answer the index of the item with the focus.  Assumes the receiver is extended selection."
	| index |
	index := ( UserLibrary
        sendMessage: self handle
        msg: LvmGetnextitem
        wparam: -1
        lparam: LvniFocused ) + 1.
	^index = 0 ifTrue: [ nil ] ifFalse: [ index ]! 
isOkToEditLabel: item
        "Private - answer whether it is OK to direct edit the label
        of the given item.  Triggers the veto-able #aboutToEditLabel: event."
    [ self triggerAboutToEditLabel: item ] on: VetoAction do: [ ^false ].
    ^true!  
notifyEndlabeledit: address
        "Private - process host notification of completion of direct edit."
    | dispinfo lvItem item string |
    dispinfo := WinLvDispinfo atAddress: address.
    lvItem := dispinfo item.
    lvItem pszText = 0 ifTrue: [ ^self ].  "edit cancelled"
    item := self items at: lvItem iItem + 1.
    string := String fromAddress: lvItem pszText asExternalAddress.
    ( self isOkToChangeLabel: item to: string ) ifFalse: [ ^nil ].  "aborted"

    lvItem mask: LvifText.
    UserLibrary
        sendMessage: self handle
        msg: LvmSetitem
        wparam: 0
        lparamStruct: lvItem asParameter.
    self triggerEvent: #changedLabel:to: withArguments: ( Array with: item object with: string ).
    ^nil!   
notifyItemchanging: address
        "Private - process host notification of item state changing."
    ^nil! 
notifyBeginlabeledit: address
        "Private - process host notification of start of direct edit."
    | dispinfo lvItem item |
    dispinfo := WinLvDispinfo atAddress: address.
    lvItem := dispinfo item.
    item := self items at: lvItem iItem + 1.  "0 based"
    ( self isOkToEditLabel: item )
        ifFalse: [ ^1 ].  "non-zero cancels direct edit, contrary to Win32 control documentation"
    ^nil!   
saveColumnWidths
        "Private - query the current column widths, and store them into the
        width slots of the headings collection."
    | oldStyle viewStyle heading headingWidth |
    "sending LvmGetcolumnwidth in other than Report view will work, but returns all 0 widths."
    oldStyle := UserLibrary getWindowLong: self handle index: GwlStyle.
    viewStyle := oldStyle bitAnd: LvsTypemask.
    viewStyle = LvsReport ifFalse: [ ^self ].

    1 to: self headings size do: [ :headingIndex |
        heading := self headings at: headingIndex.
        headingWidth := UserLibrary
            sendMessage: self handle
            msg: LvmGetcolumnwidth
            wparam: headingIndex - 1
        lparam: 0.
        heading width: headingWidth ]!   
selectIndices: aCollectionOfIntegers
        "Select the item indices in aCollectionOfIntegers."
    self valueAttribute addAll: aCollectionOfIntegers.
    self selectItemIndices: aCollectionOfIntegers state: true! 
notifyColumnclick: address
        "Private - handle host notification of a column heading click."
    | lvNotify |
    lvNotify := WinNmListview atAddress: address.
    self triggerEvent: #columnClicked: with: lvNotify iSubItem + 1.  "0 based"
    ^nil!   
defaultStyle
        "Private - Answer the default style for the receiver."
    ^LvsList | LvsAligntop | LvsShowselalways | LvsSinglesel | WsBorder | WsHscroll | WsVscroll!
selectItem: anObject
        "Select the item anObject."
    | index |
    ( index := self indexOf: anObject ) isNil ifTrue: [ ^self ].
    self selectIndex: index!  
setStyle: newStyle
        "Set the receiver's host style to newStyle.  Override the superclass
        implementation to process changes in align style by recreating the
        window (these don't stick when set by SetWindowLong)."
    | oldStyle oldAlign newAlign |
    self style: newStyle.
    self isHandleOk ifTrue: [
        oldStyle := UserLibrary getWindowLong: self handle index: GwlStyle.
        oldAlign := oldStyle bitAnd: LvsAlignmask.
        newAlign := newStyle bitAnd: LvsAlignmask.
        ( self canApplyStyle and: [ oldAlign = newAlign ] )
            ifTrue: [ self applyStyle ]
            ifFalse: [ self recreateWindow ] ]!
setViewStyle: viewStyleInteger
        "Private - set and apply viewStyleInteger as the current view style."
    | currentStyle mask |
    currentStyle := self style notNil ifTrue: [ self style ] ifFalse: [ self getStyle ].
    mask := 16rFFFFFFFF bitXor: LvsTypemask.
    currentStyle := currentStyle bitAnd: mask.
    currentStyle := currentStyle | viewStyleInteger.
    self setStyle: currentStyle
!
defaultExtendedStyle
        "Private - answer the default extended style flags for the
        receiver.  Add the 3d border style."
    ^OperatingSystem versionMajor >= 4 ifTrue: [ WsExClientedge ] ifFalse: [ 0 ]! 
deleteAllColumns
        "Delete all columns (headings) from the receiver."
    self deleteAllColumnsFromControl.
    self headingsAttribute: nil! 
notifyClick: address
        "Private - handle host notification of a mouse click."
    | index |
    ( index := self getFocusedIndex ) isNil ifTrue: [ ^self ].
    self triggerEvent: #clickedIndex: with: index.
    self triggerEvent: #clicked: with: ( self items at: index ) object.
    ^nil!   
getSelection
        "Private - retrieve the collection of selected item indices,
        store them in valueAttribute, and answer the collection."
    | index indices |
    self isHandleOk ifFalse: [ ^OrderedCollection new ].
    indices := OrderedCollection new.
    index := -1.
    [ ( index := UserLibrary
        sendMessage: self handle
        msg: LvmGetnextitem
        wparam: index
        lparam: LvniSelected ) ~= -1 ] whileTrue: [ indices add: index + 1 ].
    ^self valueAttribute: indices!
hasSelection
        "Private - answer whether the receiver has anything selected."
    ^self selectedIndices notEmpty! 
getImageFor: aListViewItem
        "Private - answer the image for aListViewItem,
        retrieving via the #needsImageFor: event if necessary."
    | image |
    aListViewItem image notNil ifTrue: [ ^aListViewItem image ].
    image := self
        triggerEvent: #needsImageFor:
        withArguments: ( Array with: aListViewItem object )
        ifNotHandled: [ nil ].
    aListViewItem image: image.
    ^image! 
setSelection
        "Private - set the selection in the receiver
        to correspond to the value attribute."
    self valueAttribute notEmpty
        ifTrue: [ self selectItemIndices: self valueAttribute state: true ]!
triggerAboutToChangeLabel: item to: newValue
        "Private - trigger the aboutToChangeLabel:to: event."
    self triggerEvent: #aboutToChangeLabel:to: withArguments: ( Array with: item object with: newValue )!
keyboardInputEventFromKeydown: lvKeydown
        "Private - answer a KeyboardInputEvent whose contents are extracted
        from lvKeydown."
    | event shiftState virtualKey character |
    event := KeyboardInputEvent new.

    shiftState := 0.
    ( Notifier isShiftKeyDown ) ifTrue: [ shiftState := shiftState bitOr: AfShift ].
    ( Notifier isControlKeyDown ) ifTrue: [ shiftState := shiftState bitOr: AfControl ].
    ( Notifier isAltKeyDown ) ifTrue: [ shiftState := shiftState bitOr: AfAlt ].
    event shiftState: shiftState.

    virtualKey := lvKeydown wVKey.
    event virtualKey: virtualKey.
    character := UserLibrary mapVirtualKey: virtualKey mapType: 2.
    ( character > 0 and: [ ( UserLibrary getKeyState: virtualKey ) > 0 ] ) ifTrue: [
        character := Character value: character.
        event characterValue: character ].

    ^event! 
sortByColumn
        "Private - answer the index of the column which is the column currently selected for sorting."
    ^self propertyAt: #sortByColumn ifAbsent: [ 1 ]!
extendedSelect
        "Add the extended selection style to the receiver."
    self extendedSelect: true!   
items
        "Answer the items in the receiver."
    ^items!   
buildWindow: parentWindow
        "Private - Create the window for the receiver, initializing the
        common controls library if necessary."
    CommonControlsDLL current.
    ^super buildWindow: parentWindow! 
notifyGetdispinfo: address
        "Private - process host notification of need for display info."
    | dispinfo lvItem item string columns column |
    dispinfo := WinLvDispinfo atAddress: address.
    lvItem := dispinfo item.
    item := self contents at: lvItem iItem + 1.  "0 based"
    string := lvItem iSubItem = 0
        ifTrue: [ self getStringFor: item ]
        ifFalse: [
                columns := self getColumnsFor: item.
                column := columns isNil
                    ifTrue: [ '<undefined>' ]
                    ifFalse: [ columns at: lvItem iSubItem + 1 ].
                 column asString ].
    string := string asParameter.

    "copy the column text into the item structure"
    ( ExternalAddress fromInteger: lvItem pszText )
        replaceFrom: 1 to: string size with: string startingAt: 1;
        at: string size + 1 put: 0.
    ^nil!  
recreateWindow
        "Private - recreate the host window, because something
        needs to change which cannot be changed dynamically
        by the host operating system.  Save column widths into
        header items list before destroying the window."
    self saveColumnWidths.
    super recreateWindow!  
imageList: anImageList
        "Private - set the (normal) image list to anImageList."
    imageList := anImageList!
clearSelections
        "Make no items in the list selected.  Assumes the receiver is extended selection."
    self clearSelectionsPrivate.
    self valueAttribute: OrderedCollection new!
smallImageList
        "Private - answer the small image list."
    ^smallImageList!
alignLeft
        "Set and apply the align left style."
    self setAlignStyle: LvsAlignleft!   
useImages: aBoolean
        "Determinate whether any specified images in the list contents are to be used
        in displaying the list items (default is true if images have been supplied)."
    self useImages = aBoolean ifTrue: [ ^self ].
    self propertyAt: #useImages put: aBoolean.
    self isHandleOk ifTrue: [ self recreateWindow ]! 
getColumnsFor: aListViewItem
        "Private - answer the columns for aListViewItem,
        retrieving via the #needsColumnsFor: event if necessary."
    | columns |
    aListViewItem columns notNil ifTrue: [ ^aListViewItem columns ].
    columns := self
        triggerEvent: #needsColumnsFor:
        withArguments: ( Array with: aListViewItem object )
        ifNotHandled: [ nil ].
    aListViewItem columns: columns.
    ^columns!   
validate
        "Private - The host window for the receiver was
        just created or recreated."
    super validate.
    self imageList: nil.
    self smallImageList: nil.
    self setContents.
    self backColor notNil ifTrue: [ self backColor: self backColor ].
    self foreColor notNil ifTrue: [ self foreColor: self foreColor ]! 
indexOf: anObject
        "Private - answer the index of the list item whose object =
        anObject, or nil if absent."
    | index listItems |
    index := 1.
    listItems := self items.
    [ index <= listItems size and: [ ( listItems at: index ) object ~= anObject ] ]
        whileTrue: [ index := index + 1 ].
    ^index > listItems size ifTrue: [ nil ] ifFalse: [ index ]!
canApplyStyle
        "Private - answer whether the receiver's style can change
        after it has been created."
    self osWorkaround.  "changing styles via SetWindowLong fails on NT 3.51"
    ^OperatingSystem isWindowsNT not!
sortAscending
        "Answer whether the receiver is supposed to sort ascending or descending."
    ^self propertyAt: #sortAscending ifAbsent: [ true ]!   
deselectIndex: itemIndex
        "Deselect the item at itemIndex.  Assumes the receiver is extended selection."
    self isExtendedSelect ifFalse: [ ^self clearSelection ].
    self valueAttribute: ( self valueAttribute copyWithout: itemIndex ).
    self selectItemIndices: ( Array with: itemIndex ) state: false! 
contents
        "Answer the contents of the receiver."
    ^self items!
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process cursor keys."
    | virtualKey |
    ( ( virtualKey := aKeyboardInputEvent virtualKey ) notNil and: [ aKeyboardInputEvent character notNil ] ) ifTrue: [
        ( virtualKey == TabKey or: [ virtualKey == BacktabKey ] )
            ifTrue: [ self tabKeyInput: aKeyboardInputEvent ] ].

    super keyboardInput: aKeyboardInputEvent! 
selectItems: aCollectionOfObjects
        "Select the items contained in aCollectionOfObjects."
    | index aCollectionOfIntegers |
    aCollectionOfIntegers := OrderedCollection new: aCollectionOfObjects size.
    aCollectionOfObjects do: [ :anObject |
        ( index := self indexOf: anObject ) notNil
            ifTrue: [ aCollectionOfIntegers add: index ] ].
    self selectIndices: aCollectionOfIntegers!
deleteIndex: index
        "Delete item number index from the list."
    self itemsAttribute: ( self items asOrderedCollection removeIndex: index; asArray ).
    self valueAttribute remove: index ifAbsent: [ nil ].
    UserLibrary
        sendMessage: self handle
        msg: LvmDeleteitem
        wparam: index - 1
        lparam: 0!   
editLabels: aBoolean
        "Enable or disable label editing, according to the value of aBoolean."
    aBoolean
        ifTrue: [ self addStyle: LvsEditlabels ]
        ifFalse: [ self removeStyle: LvsEditlabels ].
    self setStyle: self style!   
extendedSelect: aBoolean
        "Set whether the user is permitted to select multiple items using extended selection."
    aBoolean
        ifTrue: [ self removeStyle: LvsSinglesel ]
        ifFalse: [ self addStyle: LvsSinglesel ]! 
characterInput: aCharacter
        "Private - Process the character input message."
    self propertyAt: #characterTyped put: aCharacter.
    self triggerEvent: #characterTyped: with: aCharacter!
ensureVisibleIndex: itemIndex
        "Private - make sure the item with the given index
        is visible in the receiver window."
    UserLibrary
        sendMessage: self handle
        msg: LvmEnsurevisible
        wparam: itemIndex - 1
        lparam: false asParameter!   
headingsAttribute: aCollection
        "Private - set the headings variable to aCollection."
    headings := aCollection!   
selectAll
        "Select all the items in the receiver.  Assumes the receiver is extended selection."
    self valueAttribute: ( 1 to: self items size ) asOrderedCollection.
    self selectItemIndices: self valueAttribute state: true!
selectIndex: anInteger
        "Select the item at itemIndex."
    self isExtendedSelect
        ifTrue: [ self valueAttribute: ( self valueAttribute copyWith: anInteger ) ]
        ifFalse: [ 
            self clearSelectionsPrivate.
            self valueAttribute: ( OrderedCollection with: anInteger ) ].
    self selectItemIndices: ( Array with: anInteger ) state: true.
    self ensureVisibleIndex: anInteger!   
sortItems
        "Sort the items using the current sort column and direction."
    | newItems aColumns bColumns sortByColumn sortAscending |
    sortAscending := self sortAscending.
    ( sortByColumn := self sortByColumn ) = 1
        ifTrue: [
            sortAscending
                ifTrue: [ newItems := self items asSortedCollection: [ :a :b | ( self getStringFor: a ) <= ( self getStringFor: b ) ] ]
                ifFalse: [ newItems := self items asSortedCollection: [ :a :b | ( self getStringFor: a ) >= ( self getStringFor: b ) ] ] ]
        ifFalse: [
            newItems := self items asSortedCollection: [ :a :b |
                aColumns := self getColumnsFor: a.
                bColumns := self getColumnsFor: b.
                sortAscending
                    ifTrue: [ ( aColumns at: self sortByColumn ) <= ( bColumns at: self sortByColumn ) ]
                    ifFalse: [ ( aColumns at: self sortByColumn ) >= ( bColumns at: self sortByColumn ) ] ] ].

	self saveColumnWidths.
	self contents: newItems asArray!  
deleteAllColumnsFromControl
        "Private - delete the control headings."
    [ ( UserLibrary
        sendMessage: self handle
        msg: LvmDeletecolumn
        wparam: 0 "column index"
        lparam: 0 ) = 1 ] whileTrue!
itemsAttribute: aCollection
        "Private - set the items attribute to aCollection."
    items := aCollection!   
clearSelection
        "Deselect the currently selected item.  Assumes the receiver
        is single selection."
    self selectItemIndices: ( Array with: self selectedIndex ) state: false.
    self valueAttribute: OrderedCollection new!
alignTop
        "Set and apply the align top style."
    self setAlignStyle: LvsAligntop!  
setImageList: anImageList type: imageListType
        "Private - apply anImageList of type imageListType to the host control."
    UserLibrary
        sendMessage: self handle
        msg: LvmSetimagelist
        wparam: imageListType
        lparam: anImageList asParameter! 
deleteAll
        "Delete all items from the receiver."
    self deleteAllFromControl.
    self itemsAttribute: Array new.
    self valueAttribute: OrderedCollection new!
columns: anIndexedCollection
        "Set the columns of the receiver to anIndexedCollection."
    columns := anIndexedCollection!  
columns
        "Answer the columns of the receiver."
    ^columns! 
isListViewItem
		"Answer whether the receiver is a kind of ListViewItem."
	^true!   
smallImage
        "Answer the small image for the receiver (an Icon or Bitmap, usually
        16x16 pixels)."
    ^smallImage!   
smallImage: anImage
        "Set the image for the receiver to anImage (an Icon or Bitmap,
        usually 16x16 pixels)."
    smallImage := anImage!  
image
        "Answer the image for the receiver (an Icon or Bitmap,
        usually 32x32 pixels)."
    ^image!   
image: anImage
        "Set the image for the receiver to anImage (an Icon or Bitmap,
        usually 32x32 pixels)."
    image := anImage!
sizeInBytes
    ^48! 
inspectorFields
    ^self inspectorClass fields: #( #hdr #item )!
item
    ^WinLvItem usingBytes: ( self bytesAtOffset: 12 count: WinLvItem sizeInBytes )! 
item: aWinLvItem
    self bytesAtOffset: 12 put: aWinLvItem contents!
asWinLvColumn
        "Private - note: client responsible for freeing this structure (pszText)."
    | lvColumn mask address aString |
    lvColumn := WinLvColumn new.
    mask := LvcfFmt | LvcfText | LvcfWidth.
    ( aString := self string ) isNil ifTrue: [ aString := self object asString ].
    aString := aString asParameter.
    self width isNil ifTrue: [ self width: ( self widthForString: aString andFont: Font systemFont ) ].
    lvColumn cx: self width.
    lvColumn mask: mask.
    lvColumn fmt: self alignmentAsParameter.
    address := ExternalAddress copyToNonSmalltalkMemory: aString.
    lvColumn pszText: address asInteger.
    lvColumn address: address.
    lvColumn cchTextMax: aString size.
    ^lvColumn   !
sizeInBytes
    ^18! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #hdr #wVKey #flags )!
sizeInBytes
    ^24! 
inspectorFields
    ^self inspectorClass fields: #( #mask #fmt #cx #pszText #cchTextMax #iSubItem )! 
pszText
    ^self uLongAtOffset: 12! 
iSubItem
    ^self longAtOffset: 20! 
mask
    ^self uLongAtOffset: 0! 
cchTextMax: anInteger
    self longAtOffset: 16 put: anInteger!  
cx: anInteger
    self longAtOffset: 8 put: anInteger!   
pszText: anInteger
    self uLongAtOffset: 12 put: anInteger!
cchTextMax
    ^self longAtOffset: 16!   
iSubItem: anInteger
    self longAtOffset: 20 put: anInteger!
address
    ^address!
address: anInteger
    address := anInteger! 
fmt
    ^self longAtOffset: 4!   
fmt: anInteger
    self longAtOffset: 4 put: anInteger!  
mask: anInteger
    self uLongAtOffset: 0 put: anInteger!
cx
    ^self longAtOffset: 8!
flags
    ^self uLongAtOffset: 14!   
wVKey
    ^self uShortAtOffset: 12!  
sizeInBytes
    ^36! 
inspectorFields
    ^self inspectorClass fields: #( #mask #iItem #iSubItem #state #stateMask #pszText #cchTextMax #iImage #lParam )! 
lParam
    ^self longAtOffset: 32!   
iSubItem
    ^self longAtOffset: 8!  
mask
    ^self uLongAtOffset: 0! 
cchTextMax: anInteger
    self longAtOffset: 24 put: anInteger!  
pszText
    ^self uLongAtOffset: 20! 
pszText: anInteger
    self uLongAtOffset: 20 put: anInteger!
cchTextMax
    ^self longAtOffset: 24!   
state
    ^self uLongAtOffset: 12!   
iItem
    ^self longAtOffset: 4! 
iItem: anInteger
    self longAtOffset: 4 put: anInteger!
state: anInteger
    self uLongAtOffset: 12 put: anInteger!  
iImage
    ^self longAtOffset: 28!   
iImage: anInteger
    self longAtOffset: 28 put: anInteger!  
iSubItem: anInteger
    self longAtOffset: 8 put: anInteger! 
lParam: anInteger
    self longAtOffset: 32 put: anInteger!  
stateMask
    ^self uLongAtOffset: 16!   
stateMask: anInteger
    self uLongAtOffset: 16 put: anInteger!  
mask: anInteger
    self uLongAtOffset: 0 put: anInteger!