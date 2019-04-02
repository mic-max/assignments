3.1.0.106
   
imageListGetIcon: hImageList index: i style: flags
    <api: ImageList_GetIcon ulong long ulong ulongReturn>
    ^self invalidArgument! 
imageListGetBkColor: hImageList
    <api: ImageList_GetBkColor ulong ulongReturn>
    ^self invalidArgument!
imageListSetDragCursorImage: hImageList index: iDrag dxHotspot: dxHotspot dyHotspot: dyHotspot
<api: ImageList_SetDragCursorImage ulong long long long boolean>
    ^self invalidArgument!  
imageListExtractIcon: hInstance imageList: hImageList index: i
    ^self imageListGetIcon: hImageList index: i style: 0! 
imageListSetBkColor: hImageList color: clrBk
    <api: ImageList_SetBkColor ulong ulong ulongReturn>
    ^self invalidArgument! 
string: aString
        "Set the string for the receiver to aString."
    string := aString!
object: anObject
        "Set the object for the receiver to anObject."
    object := anObject! 
string
        "Answer the string for the receiver."
    ^string!   
isListItem
		"Answer whether the receiver is a kind of ListItem."
	^true!   
object
        "Answer the object for the receiver."
    ^object!   
imageListDraw: hImageList index: anInteger hdc: hdc x: x y: y style: styleInteger
    <api: ImageList_Draw ulong long ulong long long ulong boolean>
    ^self invalidArgument! 
imageListAdd: hImageList hBitmap: hbmImage hMaskBitmap: hbmMask
    <api: ImageList_Add ulong ulong ulong long>
    ^self invalidArgument!  
loadImage: hInstance nameInteger: name type: uType cx: cx cy: cy flags: fuLoad
    <api: LoadImageA ulong ulong ulong long long ulong ulongReturn>
    ^self invalidArgument!   
imageListReplaceIcon: hImageList index: i hIcon: hIcon
    <api: ImageList_ReplaceIcon ulong long ulong long>
    ^self invalidArgument!
imageListWrite: hImageList stream: lpStream
    <api: ImageList_Write ulong ulong boolean>
    ^self invalidArgument!   
imageListCreateCx: cx cy: cy flags: flags cInitial: cInitial cGrow: cGrow
    <api: ImageList_Create long long ulong long long ulong>
    ^self invalidArgument!
imageListDragMoveX: x y: y
    <api: ImageList_DragMove long long boolean>
    ^self invalidArgument!   
loadImage: hInstance nameString: name type: uType cx: cx cy: cy flags: fuLoad
    <api: LoadImageA ulong struct ulong long long ulong ulongReturn>
    ^self invalidArgument!   
imageListLoadBitmap: hInstance id: resourceId cx: cx cGrow: cGrow maskColor: maskColor
    ^self
        imageListLoadImage: hInstance
        id: resourceId
        cx: cx
        cGrow: cGrow
        maskColor: maskColor
        type: 0 "ImageBitmap - needs to be added to OperatingSystemConstants"
        flags: 0!
imageListRead: lpStream
    <api: ImageList_Read ulong ulongReturn>
    ^self invalidArgument!  
fromImages: collectionOfImages
        "Answer a new ImageList containing the images from
        collectionOfImages."
    | list |
    list := self new.
    collectionOfImages do: [ :icon | list add: icon ].
    ^list! 
new
		"Answer a new instance of the receiver."
    ^super new initialize!   
createWithExtent: extentPoint masked: maskedBoolean
        "Private - create the host image list, with the given extent and mask flag.
        The extent extentPoint will only be applied if extent has not previously been
        set (adding an image only sets the image list extent if is has not been
        explicitly set beforehand)."
    | dll h |
    extent isNil ifTrue: [ self extent: extentPoint ].
    self masked: maskedBoolean.
    dll := CommonControlsDLL current.
    ( h := dll
        imageListCreateCx: self extent x
        cy: extentPoint y
        flags: maskedBoolean asParameter
        cInitial: self defaultInitialSize
        cGrow: self defaultGrowThreshold ) = 0
            ifTrue: [ ^self error: 'API ImageList_Create failed' ].
    handle := ExternalHandle fromInteger: h.
    self handle: handle!  
asParameter
        "Answer the receiver in a form suitable for passing as
        a parameter to a host procedure call."
    ^self handle!
addBitmap: aBitmap
        "Add aBitmap to the receiver."
    self addBitmap: aBitmap maskBitmap: nil!  
removeIndex: anInteger
        "Remove the image with index anInteger from the receiver."
    ( CommonControlsDLL current imageListRemove: self handle index: anInteger - 1 )
        ifFalse: [ self error: 'API ImageList_Remove failed' ].
    self images removeIndex: anInteger! 
display: imageIndex at: aPoint
        "Draw the image at index imageIndex at the given location, using
        the Display pen."
    self display: imageIndex at: aPoint with: Display pen!   
masked
        "Answer whether the receiver contains masked images (masked
        bitmaps, or icons)."
    ^masked!   
extent
        "Answer the extent (a Point) of the images contained in the receiver."
    ^extent!  
handle: anExternalHandle
        "Private - set the host image list handle to anExternalHandle."
    handle := anExternalHandle!
extent: aPoint
        "Set the extent of images contained in the receiver to aPoint.
        If not explicitly set beforehand, the first image added determines
        the receiver's extent (all images must have the same extent)."
    extent := aPoint! 
images: anOrderedCollection
        "Private - set the list of images contained in the receiver to anOrderedCollection."
    images := anOrderedCollection! 
initialize
        "Private - Initialize the receiver."
    self images: OrderedCollection new! 
isEmpty
        "Answer whether the receiver is empty (contains no images)."
    ^self size = 0!
add: anImage
        "Add anImage (which may be either an Icon or Bitmap) to
        the receiver."
    anImage isBitmap ifTrue: [ ^self addBitmap: anImage ].
    anImage isIcon ifTrue: [ ^self addIcon: anImage ].
    ^self error: 'unknown image type'! 
addBitmap: aBitmap maskBitmap: maskBitmap
        "Add aBitmap to the receiver, using maskBitmap as the mask."
    self handle isNil ifTrue: [ self createWithExtent: aBitmap extent masked: maskBitmap notNil ].
    ( CommonControlsDLL current
        imageListAdd: self handle
        hBitmap: aBitmap handle
        hMaskBitmap: ( maskBitmap isNil ifTrue: [ 0 ] ifFalse: [ maskBitmap handle ] ) ) = -1
            ifTrue: [ self error: 'API ImageList_Add failed' ].
    "aBitmap release."
    maskBitmap isNil
        ifTrue: [ self images add: aBitmap ]
        ifFalse: [
            self images add: ( Array with: aBitmap with: maskBitmap ).
            "maskBitmap release" ]! 
size
        "Answer the number of images contained by the receiver."
    self handle isNil ifTrue: [ ^0 ].
    ^CommonControlsDLL current imageListGetImageCount: self handle!
masked: aBoolean
        "Private - set whether the receiver contains masked images."
    masked := aBoolean!   
defaultInitialSize
        "Private - answer the default size that a new instance is created with."
    ^10!
images
        "Private - answer the list of images contained in the receiver."
    ^images!
notEmpty
        "Answer whether the receiver not empty (contains images)."
    ^self isEmpty not!  
display: imageIndex at: aPoint with: aPen
        "Draw the image at index imageIndex at the given location, using
        the given pen."
    ( CommonControlsDLL current
        imageListDraw: self handle
        index: imageIndex - 1
        hdc: aPen handle
        x: aPoint x
        y: aPoint y
        style: 0 ) ifFalse: [ self error: 'API ImageList_Draw failed' ]!
remove: anImage
        "Remove anImage from the receiver."
    self removeIndex: ( self indexOf: anImage )!
release
        "Release the receiver's host resources."
    self handle isNil ifTrue: [ ^self ].
    ( CommonControlsDLL current imageListDestroy: self handle )
        ifFalse: [ self error: 'API ImageList_Destroy failed' ].
    self handle: nil! 
includes: anImage
        "Answer whether anImage is included in the receiver list."
    ^self images includes: anImage!
indexOf: anImage
        "Answer the index of anImage within the receiver, or 0 if absent."
    ^self images indexOf: anImage!  
defaultGrowThreshold
        "Private - answer the default grow threshold that a new instance is created with."
    ^5! 
handle
        "Private - answer the host image list handle."
    ^handle!  
addIcon: anIcon
        "Add anIcon to the receiver."
    self handle isNil ifTrue: [ self createWithExtent: anIcon extent masked: true ].
    ( CommonControlsDLL current
        imageListAddIcon: self handle
        hIcon: anIcon handle ) = -1
            ifTrue: [ self error: 'API ImageList_AddIcon failed' ].
    self images add: anIcon.
    anIcon release! 
imageListLoadImage: hInstance
        id: resourceId
        cx: cx
        cGrow: cGrow
        maskColor: maskColor
        type: uType
        flags: uFlags
    <api: ImageList_LoadImage ulong ulong long long ulong ulong ulong ulongReturn>
    ^self invalidArgument! 
imageListSetOverlayImage: hImageList imageIndex: imageIndex overlayIndex: overlayIndex
    <api: ImageList_SetOverlayImage ulong long long boolean>
    ^self invalidArgument!  
imageListDraw2: hImageList index: i hdc: hdcDst x: x y: y blendColor: rgb style: fStyle
    <api: ImageList_Draw2 ulong long ulong long long ulong ulong boolean>
    ^self invalidArgument!
imageListAddIcon: hImageList hIcon: hIcon
    ^self imageListReplaceIcon: hImageList index: -1 hIcon: hIcon! 
isListItem
		"Answer whether the receiver is a kind of ListItem."
	^false!  
loadImage: hInstance name: name type: uType cx: cx cy: cy flags: fuLoad
    ^name isString
        ifTrue: [ self loadImage: hInstance nameString: name type: uType cx: cx cy: cy flags: fuLoad ]
        ifFalse: [ self loadImage: hInstance nameInteger: name type: uType cx: cx cy: cy flags: fuLoad ]!
imageListDestroy: hImageList
    <api: ImageList_Destroy ulong boolean>
    ^self invalidArgument!  
imageListBeginDrag: hImageList hwndLock: hwndLock index: i x: x y: y dxHotspot: dxHotspot dyHotspot: dyHotspot
    <api: ImageList_BeginDrag ulong ulong long long long long long boolean>
    ^self invalidArgument!   
imageListGetImageCount: hImageList
    <api: ImageList_GetImageCount ulong long>
    ^self invalidArgument! 
imageListMerge: hImageList1 index: i1 secondImageList: hImageList2 index: i2 dx: dx dy: dy
    <api: ImageList_Merge ulong long ulong long long long ulongReturn>
    ^self invalidArgument!
imageListGetImageInfo: hImageList index: i pImageInfo: pImageInfo
    <api: ImageList_GetImageInfo ulong long struct boolean>
    ^self invalidArgument!
imageListRemove: hImageList index: i
    <api: ImageList_Remove ulong long boolean>
    ^self invalidArgument!  
imageListAddMasked: hImageList hBitmap: hbmImage maskColor: crMask
    <api: ImageList_AddMasked ulong ulong ulong long>
    ^self invalidArgument! 
imageListGetIconSize: hImageList pCx: pCx pCy: pCy
    <api: ImageList_GetIconSize ulong struct struct boolean>
    ^self invalidArgument!  
imageListEndDrag
    <api: ImageList_EndDrag none>
    ^self invalidArgument!   
imageListReplace: hImageList index: i hBitmap: hbmImage hMaskBitmap: hbmMask
    <api: ImageList_Replace ulong long ulong ulong boolean>
    ^self invalidArgument!