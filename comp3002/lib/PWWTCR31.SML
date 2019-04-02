3.1.0.106
   
previousTabStop: aSubPane
        "Private - Answer the subpane which has the previous
        tabstop.  Override GroupPane.  The documented
        behavior for tabbing with a notebook page pane is to remain
        within the pane.  Move Window implementation down here."
    | orderedChildren  index startIndex child|
    orderedChildren := self orderedChildren.
    startIndex := orderedChildren indexOf: aSubPane.
    "Circulate through the orderedChildren
        and find the first tabstop."
    index := startIndex - 1.
    index < 1
        ifTrue: [ ^ self superWindow previousTabStop: self ].
    ^(child := orderedChildren at: index) hasFocus
        ifTrue: [child]
        ifFalse: [child previousTabStop]!   
nextTabStop: aSubPane
        "Private - Answer the first suppane following aSubPane
        which is a tab stop.  Override GroupPane.  The documented
        behavior for tabbing with a notebook page pane is to remain
        within the pane.  Move Window implementation down here."
    | orderedChildren  index startIndex child |

    orderedChildren := self orderedChildren.
    startIndex := orderedChildren indexOf: aSubPane.
    "Circulate through the orderedChildren
        and find the first tabstop."
    index := startIndex + 1.
    index > orderedChildren size
        ifTrue: [ ^ self superWindow nextTabStop: self].
    ^(child := orderedChildren at: index) hasFocus
        ifTrue: [child]
        ifFalse: [child nextTabStop]!
hasImage
    "Private - Answer true if tab image is used."

    ^ self image notNil
! 
pages
	"Private - Answer all pages in the parent."

	^ self superWindow pages! 
hasImage: boolean
    "Private - Do not use image if <boolean> is false."

    boolean
        ifFalse: [ self image: nil ]!  
image: anImage
    "Set the page icon/bitmap to <anImage>."

    page image: anImage.
    self modified: true!
label: aString
    "Set the label of the page."

    page label: aString.
    self modified: true!
label
    "Answer the label of the page."
    ^ page label! 
deselected: aNotebookPage

    "Perform any actions required when the owner page
        <aNotebookPage> has been deselected."

    self triggerEvent: #deselected.! 
parentContents: aList
    "Private - Set parent tab controls content to
    pages in <aList>."

    self superWindow reorderPages: aList! 
currentPageNumber
    "Private - Answer the current selected page number in parent."
    ( self superWindow isKindOf: PARTSTabControlPart )
        ifTrue: [ ^ self superWindow pageNumber ]
        ifFalse: [ ^ 1 ]!   
turnToPageNumber: index
    "Turn to page number <index> so that it appears on top."

    ( self superWindow isKindOf: PARTSTabControlPart )
        ifTrue: [ self superWindow turnToPageNumber: index ].!   
nextPage
    "Bring the next item of the receiver to the top.
     Trigger next: event for the current page or
     finished event for the receiver."

    | firstControl |
    firstControl := self currentPage firstControl.
    firstControl notNil ifTrue: [
        self isLastPage ifTrue: [
            ^ self triggerEvent: #finished ].
        ( firstControl hasActionForEvent: #next: )
            ifTrue: [ ^ firstControl triggerEvent: #next: with: firstControl ]
            ifFalse: [ ^ super nextPage ]
        ]!  
pageNumber
    "Answer the page number of the page."
    ( self superWindow isKindOf: PARTSTabControlPart )
        ifTrue: [ ^ self superWindow pageNumberFor: page ]
        ifFalse: [ ^ 1 ]!  
backColor
        "Answer the background color of the receiver."
    | color |
    ^ ( color := self propertyAt: #backColor ) isNil
        ifTrue: [ self class defaultBackColor ]
        ifFalse: [ color ]
!
selected: aNotebookPage

    "Perform any actions required when the owner page
        <aNotebookPage> has been selected."

    self triggerEvent: #selected.!   
updateTab
    "Private - Update the associated tab control."
    | tabControl |

    tabControl := self superWindow.
    ( tabControl isKindOf: PARTSTabControlPart )
        ifFalse: [^self].
    tabControl updateTab: page!
wmCommand: wordInteger with: longInteger
        "Private - Process the command message."

    ( self superWindow class inputCommands includes: wordInteger highWord )
		ifTrue: [ self superWindow triggerEvent: #inputOccurred ].  "used by PropertySheet for apply button"
    ^ super wmCommand: wordInteger with: longInteger!  
button2Up: aPoint
        "Private - Finish right button scroll or do popup menu."

    self clearMouseCapture.
    Margin = 0 ifTrue: [
        (( self handlesEvent: #button2Up )
            or: [ self hasActionForEvent: #rightClicked ] )
        ifTrue: [
            self triggerEvent: #rightClicked ]
        ifFalse: [
            self doPopupMenuAt: aPoint ]]!  
partEditDirect
	"Private - external"
	"Edit the directly visible part properties of the receiver."

	^ self partEditProperties!   
tip: aString
    "Set the tip of the page."

    page tipText: aString.
    self modified: true!  
tabScope
        "Private - Answer the parent window which determines
        the tabbing scope for this control."
    ^self ! 
image
    "Answer the page icon/bitmap."
    ^ page image!  
removeSubpane: aWindow
        "Remove aWindow from tabing info."

    self orderedChildren remove: aWindow ifAbsent: [].
    super removeSubpane: aWindow.!  
page: aTabControlPage
    "Private - Set the page object to <aTabControlPage>."
    page := aTabControlPage!
previousPage
    "Bring the previous page on top.
     Trigger the back: event for the current page control."

    | firstControl |
    firstControl := self currentPage firstControl.
    ( firstControl notNil and: [ firstControl hasActionForEvent: #back: ] )
        ifTrue: [ ^ firstControl triggerEvent: #back: with: firstControl ]
        ifFalse: [ ^ super previousPage ]!  
tip
    "Answer the tip of the page."
    ^ page tipText!