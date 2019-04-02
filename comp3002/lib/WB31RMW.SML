"3.0.0.2"
!  

ListBox subclass: #WBListBox
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''!

DrawnButton subclass: #WBStaticGraphic
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants GraphicsConstants OperatingSystemConstants '!

!EntryField methods !
currency
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #currency.
    self acceptCurrency! !

!WBStaticGraphic methods !  
createBitmap: aString
    "Added by OSI"
    | aPoint aBitmap |
    aPoint := self cpSize.
    aBitmap := WBBitmapClass
        screenWidth: aPoint x
        height: aPoint y.
    aBitmap pen
        fill: self backColor;
        foreColor: self foreColor;
        backColor: self backColor;
        setBackgroundMode: BackgroundMixTransparent;
        setTextAlign: TaTop;
        font: (self font isNil ifTrue: [ self defaultFont ] ifFalse: [ self font ]);
        centerWinText: aString at: aBitmap boundingBox center.
   self contents: aBitmap! !

!WBStaticGraphic methods !   
initialize
    "Added by OSI"
    super initialize.
    self whenValid: #disable.! !

!WBListBox class methods ! 
supportedEvents
        "Answer the Set of events that ListBoxes can notify
         their owners about."
    ^super supportedEvents
        add: #commitSelection;
        add: #highlightItem;
        yourself! !

!EntryField methods !   
phoneNumber
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #phoneNumber.
    self acceptPhoneNumber! !

!WBListBox methods !   
pen
        "Answer the GraphicsTool associated with the receiver."
    ^self graphicsTool! !

!WBStaticGraphic methods ! 
graphicsTool
        "Private - Answer the receiver's graphics tool."
    graphicsTool isNil ifTrue: [ graphicsTool := self getGraphicsTool ].
    ^graphicsTool! !

!EntryField methods !   
integer
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #integer.
    self acceptInteger! !

!EntryField methods !  
alpha
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #alpha.
    self acceptAlpha
! !

!WBListBox methods !   
graphicsTool
        "Private - Answer the receiver's graphics tool."
    graphicsTool isNil ifTrue: [ graphicsTool := self getGraphicsTool ].
    ^graphicsTool! !

!WBListBox methods !
highlight: aDrawStruct

    (self event: #highlightItem) isNil
        ifTrue: [
            self highlight: aDrawStruct].! !

!WBListBox methods ! 
commitSelection

    ^(self event: #commitSelection) ~= false! !

!EntryField methods !   
dollar
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self currency! !

!EntryField methods !  
positiveInteger
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #positiveInteger.
    self acceptPositiveInteger! !

!EntryField methods !  
float
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #float.
    self acceptFloat! !

!EntryField methods !
date
    "Added by OSI for FormattedEntryField support."
    #addedByOSI.
    self propertyAt: #cpStyle put: #date.
    self acceptDate! !
  
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!