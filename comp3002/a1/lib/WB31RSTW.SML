"3.0.0.3"
!

!StatusPane methods ! 
leftJustifiedFixed
    "Added by OSI"
    #addedByOSI.
    self
        leftJustified;
        fixedSize! !

!StatusPane methods ! 
rightJustifiedFixed
    "Added by OSI"
    #addedByOSI.
    self
        rightJustified;
        fixedSize! !

!StatusPane methods !   
justified

    #addedByOSI.
    ^justified! !

!StatusPane methods ! 
framingBlock: aBlock
    "Added by OSI"
    #addedByOSI.
    aBlock isContext ifTrue: [
        super framingBlock: aBlock
    ] ifFalse: [
        self propertyAt: #wbFramer put: aBlock
    ].! !

!StatusPane methods !  
tabStop
    "Added by OSI because StatusPanes may not be tabstops"
    #addedByOSI! !

!StatusPane methods !  
startGroup
    "Added by OSI because StatusPanes may not be tabstops"
    #addedByOSI! !

!StatusPane methods !   
initSize: aRectangle
    "Added by OSI"
    | fp |
    #addedByOSI.
    (self parent isMDIFrame not and: [
    (fp := self propertyAt: #wbFramer) notNil]) ifTrue: [
        super framingBlock: fp
    ].
    super initSize: aRectangle! !

!StatusPane methods ! 
isWsGroup
    "Added by OSI"
    #addedByOSI.
    ^true! !

!StatusBox methods ! 
storeOn: aStream indentString: indentString
    "Added by OSI"

    | indent |
	#addedByOSI.
    indent := indentString, '    '.

    aStream nextPutAll: indentString, self class name, ' new'.
    aStream cr; nextPutAll: indent, 'space: ', self space asString.

    self width > 0 ifTrue: [
        aStream nextPutAll: ';'; cr; nextPutAll: indent, 'width: ', self width asString.
    ].
    (self contents notNil and: [ self contents hasContent ]) ifTrue: [
        aStream nextPutAll: ';'; cr; nextPutAll: indent, 'contents: ', self contents asQuotedString.
    ].
    (self name notNil and: [ self name hasContent ]) ifTrue: [
        aStream nextPutAll: ';'; cr; nextPutAll: indent, 'name: #', self name asString.
    ].! !

!StatusPane methods ! 
height: anInteger
        "Set the receiver's height."

    | aFont |
	#modifiedByOSI.
    self framingBlock: [ :box |
        Rectangle leftBottom: ( box leftBottom up: 1 ) extent: box width @ (
            "Fix StatusPane height in Dialogs."
            self superWindow isDialog
                ifTrue: [anInteger // (WindowDialog dialogUnit / WindowDialog unitMultiplier) y]
                ifFalse: [anInteger])].
    aFont := NationalLanguage isDoubleByteCp
        ifTrue: [ Font systemFont ]
        ifFalse: [
			#modifiedByOSI.
			"Account for decender."
            Font new
                faceName: self class defaultFontName;
                charSize: ( 0 @ ( ( anInteger - ( 2 * inset ) ) * 2 // 3 ) );
                fixedWidth: false ].
    self font: aFont! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!