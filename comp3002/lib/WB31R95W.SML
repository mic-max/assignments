"3.0.0.3"
!

!UpDown methods ! 
validate
        "Private - The host window for the receiver was
        just created or recreated."
    #modifiedByOSI.
    super validate.
    self buddy notNil ifTrue: [ self setBuddy ].
    "self resize: ( 0@0 extent: parent extent )" "<-- commented out by OSI - this is really stupid!!"
	"workaround to control strangeness when has a buddy"
! !

!HeaderItem methods !
asWinHdItem
        "Private - note: client responsible for freeing this structure (pszText)."
    | hdItem mask fmt address |
    #modifiedByOSI.
    hdItem := WinHdItem new.
    mask := HdiFormat | HdiWidth.
    fmt := self alignmentAsParameter.
    (self string notNil and: [self image isNil]) ifTrue: [
        mask := mask | HdiText.
        fmt := fmt | HdfString.
        address := ExternalAddress copyToNonSmalltalkMemory: self string.
        hdItem pszText: address asInteger.
        hdItem address: address.
        hdItem cchTextMax: self string size ].
    self image notNil ifTrue: [
        mask := mask | HdiBitmap.
        fmt := fmt | HdfBitmap.
        hdItem hbm: self image handle ].
    width isNil ifTrue: [ self width: ( Font systemFont stringWidth: self string ) + 20 ].
    hdItem cxy: width.
    hdItem mask: mask.
    hdItem fmt: fmt.
    ^hdItem   ! !

!TabControl methods ! 
setPages: aCollectionOfTabControlPages

    #addedByOSI.
    self deleteAllPages.
    aCollectionOfTabControlPages isNil ifTrue: [^self].
    aCollectionOfTabControlPages do: [:page |
        self addPage: page].! !
   
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!