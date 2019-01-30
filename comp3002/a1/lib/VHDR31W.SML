3.1.0.106
   
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    ^Dictionary new
        at: HdnDividerdblclick put: #notifyDividerdblclick:  ;
        at: HdnEndtrack put: #notifyEndtrack: ;
        at: HdnItemclick put: #notifyItemclick: ;
        at: HdnTrack put: #notifyTrack: ;
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
        add: #needsAlignmentFor: ;
        add: #needsWidthFor: ;

        add: #clicked: ;
        add: #clickedIndex: ;

        add: #resizingIndex:to: ;
        add: #resizedIndex:to: ;
        add: #dividerDoubleClicked: ;
        add: #dividerDoubleClickedIndex: ;
        yourself! 
sizeInBytes
    ^24! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #hdr #iItem #iButton #pItem )!   
notifyTrack: address
		"Private - process the tracking host notification."
    | hdNotify index |
    hdNotify := WinHdNotify atAddress: address.
    index := hdNotify iItem + 1. "0 based"
    self
        triggerEvent: #resizingIndex:to:
        withArguments: ( Array with: index with: hdNotify item cxy ).
    ^nil!
windowClass
        "Private - Answer the window class for the receiver."
    ^WcHeader!
getImageFor: aHeaderItem
        "Private - answer the image for aHeaderItem,
        retrieving via the #needsImageFor: event if necessary."
    | image |
    aHeaderItem image notNil ifTrue: [ ^aHeaderItem image ].
    image := self
        triggerEvent: #needsImageFor:
        withArguments: ( Array with: aHeaderItem object )
        ifNotHandled: [ nil ].
    aHeaderItem image: image.
    ^image! 
contents: aCollection
        "Set the headings to aCollection."
    self headings: aCollection!
getWidthFor: aHeaderItem
        "Private - answer the width for aHeaderItem,
        retrieving via the #needsWidthFor: event if necessary."
    | width |
    aHeaderItem width notNil ifTrue: [ ^aHeaderItem width ].
    width := self
        triggerEvent: #needsWidthFor:
        withArguments: ( Array with: aHeaderItem object )
        ifNotHandled: [ nil ].
    aHeaderItem width: width.
    ^width! 
columnWidths
		"Answer the current widths of heading columns (in pixels)."
    | size hdItem widths r |
    size := UserLibrary sendMessage: self handle msg: HdmGetitemcount wparam: 0 lparam: 0.
    widths := Array new: size.
    1 to: size do: [ :i |
        hdItem := WinHdItem new.
        hdItem mask: HdiWidth.
        r := UserLibrary
            sendMessage: self handle
            msg: HdmGetitem
            wparam: i - 1
            lparamStruct: hdItem contents.
        widths at: i put: hdItem cxy ].
    ^widths
    !   
canTab
        "Private - Answer whether the receiver can
        be tabbed into and out of."
    ^false!  
getStringFor: aHeaderItem
        "Private - answer the string for aHeaderItem,
        retrieving via the #needsStringFor: event if necessary."
    | string |
    aHeaderItem string notNil ifTrue: [ ^aHeaderItem string ].
    string := self
        triggerEvent: #needsStringFor:
        withArguments: ( Array with: aHeaderItem object )
        ifNotHandled: [ aHeaderItem object asString ].
    aHeaderItem string: string.
    ^string!  
headings: aCollection
        "Set the headings to aCollection, where each element in aCollection is either a String
        or a HeaderItem."
    | item aFont |
    aFont := self font isNil ifTrue: [ self defaultFont ] ifFalse: [ self font ].
    aCollection isNil
        ifTrue: [ self headingsAttribute: aCollection ]
        ifFalse: [
            self headingsAttribute: ( aCollection collect: [ :o |
                item := o isHeaderItem
                    ifTrue: [ o ]
                    ifFalse: [ HeaderItem new object: o ].
            item width isNil ifTrue: [ item width: ( item widthForFont: aFont ) ].
                item ] ) ].
    self isHandleOk ifTrue: [ self setContents ]! 
buildWindow: parentWindow
        "Private - Create the window for the receiver, initializing the
        common controls library if necessary."
    CommonControlsDLL current.
    ^super buildWindow: parentWindow! 
notifyDividerdblclick: address
		"Private - process the divider click host notification."
    | hdNotify index |
    hdNotify := WinHdNotify atAddress: address.
    index := hdNotify iItem + 1. "0 based"
    self triggerEvent: #dividerDoubleClickedIndex: with: index.
    self triggerEvent: #dividerDoubleClicked: with: ( self contents at: index ) object.  "item to left of divider"
    ^nil!   
recreateWindow
        "Private - recreate the host window, because something
        needs to change which cannot be changed dynamically
        by the host operating system.  Save column widths into
        header items list before destroying the window."
    self saveColumnWidths.
    super recreateWindow!  
headingsAttribute: aCollection
		"Private - set the headings instance variable to aCollection."
    headings := aCollection!
font: aFont
        "Set the font for the receiver to aFont.  Reset the contents
        in order to make the host control apply the font change."
    super font: aFont.
    self contents: self contents!   
getAlignmentFor: aHeaderItem
        "Private - answer the alignment for aHeaderItem,
        retrieving via the #needsAlignmentFor: event if necessary."
    | alignment |
    aHeaderItem alignment notNil ifTrue: [ ^aHeaderItem alignment ].
    alignment := self
        triggerEvent: #needsAlignmentFor:
        withArguments: ( Array with: aHeaderItem object )
        ifNotHandled: [ nil ].
    aHeaderItem alignment: alignment.
    ^alignment! 
notifyEndtrack: address
		"Private - process the end track host notification."
    | hdNotify index |
    hdNotify := WinHdNotify atAddress: address.
    index := hdNotify iItem + 1. "0 based"
    self
        triggerEvent: #resizedIndex:to:
        withArguments: ( Array with: index with: hdNotify item cxy ).
    ^nil! 
saveColumnWidths
        "Private - query the current column widths, and store them into the
        width slots of the headings collection."
    | heading hdItem headingWidth |
    1 to: self headings size do: [ :headingIndex |
        hdItem := WinHdItem new.
        hdItem mask: HdiWidth.
        headingWidth := UserLibrary
            sendMessage: self handle
            msg: HdmGetitem
            wparam: headingIndex - 1
            lparamStruct: hdItem asParameter.
        heading := self headings at: headingIndex.
        heading width: hdItem cxy ]! 
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^HdsHorz | HdsButtons | WsBorder! 
validate
        "Private - The host window for the receiver was
        just created or recreated."
    super validate.
    self setContents!
setContents
        "Private - set the contents of the receiver's host control."
    | hdItem |
    self contents isNil ifTrue: [ ^self ].
    self deleteAll.
    self contents do: [ :item |
        self getStringFor: item; getImageFor: item; getAlignmentFor: item; getWidthFor: item.
        hdItem := item asWinHdItem.
        UserLibrary
            sendMessage: self handle
            msg: HdmInsertitem
            wparam: self contents size
            lparamStruct: hdItem asParameter.
        hdItem free ]! 
isATabStop
        "Private - Answer whether the receiver is a tabstop"
    ^false! 
buttons: aBoolean
		"Determine whether the receiver has the button style, according to aBoolean."
    aBoolean
        ifTrue: [ self addStyle: HdsButtons ]
        ifFalse: [ self removeStyle: HdsButtons ].
    self setStyle: self style!   
canApplyStyle
        "Private - answer whether the receiver's style can change
        after it has been created."
    self osWorkaround.  "changing styles via SetWindowLong fails on NT 3.51"
    ^OperatingSystem isWindowsNT not!
headings
		"Answer the receiver's collection of headings (HeaderItems)."
    ^headings! 
notifyItemclick: address
        "Private - process the item (heading) click host notification."
    | hdNotify index |
    hdNotify := WinHdNotify atAddress: address.
    index := hdNotify iItem + 1. "0 based"

    hdNotify iButton = 0 ifTrue: [
        self valueAttribute: nil.
        self triggerEvent: #clickedIndex: with: index.
        self triggerEvent: #clicked: with: ( self contents at: index ) object ].

    ^nil!
contents
		"Answer the contents of the receiver."
    ^self headings!   
deleteAll
    [ ( UserLibrary
        sendMessage: self handle
        msg: HdmDeleteitem
        wparam: 0 "delete first item until no more items"
        lparam: 0 ) asBoolean ] whileTrue: [ ]!  
deleteIndex: index
		"Private - delete the heading at the specified index (one based)."
    UserLibrary
        sendMessage: self handle
        msg: HdmDeleteitem
        wparam: index - 1
        lparam: 0!
centered
        "Set the alignment of the receiver to be centered."
    self alignment: #center!   
width
        "Answer the width of this item (in pixels)."
    ^width!  
width: anInteger
        "Set the width of this item to anInteger (pixels)."
    width := anInteger!
isHeaderItem
		"Answer whether the receiver is a kind of HeaderItem."
	^true!   
asWinHdItem
        "Private - note: client responsible for freeing this structure (pszText)."
    | hdItem mask fmt address aString |
    hdItem := WinHdItem new.
    mask := HdiFormat | HdiWidth.
    fmt := self alignmentAsParameter.
    self image notNil
        ifTrue: [
            mask := mask | HdiBitmap.
            fmt := fmt | HdfBitmap.
            hdItem hbm: self image handle ]
        ifFalse: [
            self string notNil ifTrue: [
                mask := mask | HdiText.
                fmt := fmt | HdfString.
                aString := self string asParameter.
                address := ExternalAddress copyToNonSmalltalkMemory: aString.
                hdItem pszText: address asInteger.
                hdItem address: address.
                hdItem cchTextMax: aString size ] ].

    width isNil ifTrue: [ self width: ( self widthForString: aString andFont: Font systemFont ) ].
    hdItem cxy: width.
    hdItem mask: mask.
    hdItem fmt: fmt.
    ^hdItem   !  
widthForFont: aFont
        "Private - answer the width (in pixels) for the receiver, based on the given font."
    | str |
    str := self string notNil ifTrue: [ self string ] ifFalse: [ self object asString ].
    ^self widthForString: str andFont: aFont!
alignmentAsParameter
        "Private - answer the alignment flag in host terms."
    self alignment == #center ifTrue: [ ^HdfCenter ].
    self alignment == #right ifTrue: [ ^HdfRight ].
    ^HdfLeft! 
rightJustified
        "Set the alignment of the receiver to be right justified."
    self alignment: #right!   
leftJustified
        "Set the alignment of the receiver to be left justified."
    self alignment: #left!  
alignment
        "Answer the alignment for the receiver, either #left, #right, or #center."
    ^alignment!
alignment: aSymbol
        "Set the alignment for the receiver to aSymbol (#left, #right, or #center)."
    alignment := aSymbol!   
widthForString: aString andFont: aFont
        "Private - answer the width (in pixels) for aString, based on the given font."
    ^( aFont stringWidth: aString ) + 20! 
image
        "Answer the image for the receiver (an Icon or Bitmap,
        usually 16x16 pixels)."
    ^image!   
image: anImage
        "Set the image for the receiver to anImage (an Icon or Bitmap,
        usually 16x16 pixels)."
    image := anImage!
sizeInBytes
    ^28! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #mask #cxy #pszText #hbm #cchTextMax #fmt #lParam )! 
hbm
    ^self uLongAtOffset: 12! 
hbm: aHandle
    self uLongAtOffset: 12 put: aHandle!
lParam
    ^self longAtOffset: 24!   
cchTextMax: anInteger
    self longAtOffset: 16 put: anInteger!  
mask
    ^self uLongAtOffset: 0! 
pszText
    ^self uLongAtOffset: 8!  
pszText: anAddress
    self uLongAtOffset: 8 put: anAddress! 
cchTextMax
    ^self longAtOffset: 16!   
cxy
    ^self longAtOffset: 4!   
cxy: anInteger
    self longAtOffset: 4 put: anInteger!  
lParam: anInteger
    self longAtOffset: 24 put: anInteger!  
address
    ^address!
address: anAddress
    address := anAddress! 
fmt
    ^self longAtOffset: 20!  
fmt: anInteger
    self longAtOffset: 20 put: anInteger! 
mask: anInteger
    self uLongAtOffset: 0 put: anInteger!
free
    self address notNil ifTrue: [ self address free ]!  
isHeaderItem
		"Answer whether the receiver is a kind of HeaderItem."
	^false!  
pItem
    ^self uLongAtOffset: 20!   
iButton
    ^self longAtOffset: 16!  
iItem
    ^self longAtOffset: 12!
item
    ^WinHdItem atAddress: ( ExternalAddress fromInteger: self pItem )!