3.1.0.106
   
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^0!   
backColor
        "Answer the background color of the receiver"
    | f |
    f := super backColor.
    f isNil ifTrue:[ f := OperatingSystem getSystemColor: SystemColorWindowBackground].
    ^f!  
nextPage
        "Bring the next page of the notebook to the top."
    | next |

    ( next := self queryPageAfter: self selection ) notNil
        ifTrue: [ self selectPage: next  ].! 
displayMinorTabsWith: aPen
        "Private - Display the major tabs receiver"

    | rect tabRectangle flags backTabRectangle
    nTabs topMinorPage basicFlags |

    tabRectangle := (rectangle leftBottom leftAndUp: 0 @ marginExtent y) extent: self minorTabExtent.
    tabRectangle moveBy: ((self numberOfBackPages * 3) + 2) @ -1.
    backTabRectangle := tabRectangle translateBy: (0 @ (self numberOfBackPages * 3)).
    self isScrollMinorTabButtonsVisible ifTrue:[
        tabRectangle moveBy: (self tabSpace x + 16) @ 0.
        backTabRectangle moveBy: (self tabSpace x + 16) @ 0].

    aPen setTextAlign: TaNoupdatecp.
    basicFlags := DtVcenter | DtSingleline.
    flags := DtCenter | basicFlags .
    self isTabTextRight ifTrue:[ flags := DtRight | basicFlags ].
    self isTabTextLeft ifTrue:[ flags := DtLeft | basicFlags ].
    nTabs := 0.
    topMinorPage := self topMinorPage.
    self visibleMinorTabs do:[: minorPage |
        topMinorPage = minorPage
            ifTrue:[ rect := tabRectangle ]
            ifFalse:[ rect := backTabRectangle].
        rect := rect translateBy:  ((self minorTabExtent x + self tabSpace x) * nTabs) @ 0.
        aPen
            foreColor: self colorBorder;
            backColor: self colorMinorTabBackground;
            setLineWidth: 1;
            rectangleFilled: rect.
        topMinorPage = minorPage ifTrue:[
            aPen
                foreColor: self colorPageBackground;
                place: rect leftTop;
                goto: rect rightTop].
        minorPage tab isString
            ifTrue:[
                aPen
                    foreColor: self colorMinorTabText;
                    displayText: minorPage tab
                        in: ( rect insetBy: self focusSpace )
                        options: flags ]
            ifFalse:[
                aPen
                    copyBitmap: minorPage tab
                    from: minorPage tab boundingBox
                    to: ( rect insetBy: self focusSpace )].

        minorPage tabRectangle: rect.
        nTabs := nTabs + 1].!
queryFirstPage
        "Answer the first page."

    ^self queryPage: BkaFirst beside: nil!
key
    "Answer the key value of the receiver."

    ^key! 
supportedEvents
        " Private - answer the set of events that instances of the
        receiver can trigger.  Obsolete (retained for compatibility). "
    ^Set new!   
getMnemonicHandler: char
    "Answer an object to handle the mnemonic <char>."
    | mnemonicHandler |

    orderedPages do: [ :anOrderedPage |
        ( mnemonicHandler :=
            anOrderedPage getMnemonicHandler: char ) notNil
            ifTrue: [ ^mnemonicHandler ]].
    ^nil! 
displayMajorTabsWith: aPen
        "Private - Display the major tabs receiver"

    | rect tabRectangle flags
    backTabRectangle nTabs topMajorPage basicFlags |
    tabRectangle := (rectangle rightTop leftAndUp: marginExtent x @ 0) extent: self majorTabExtent.
    tabRectangle moveBy: -1 @ (self numberOfBackPages * 3).
    backTabRectangle := tabRectangle translateBy: ((self numberOfBackPages * 3) @ 0).
    self isScrollMajorTabButtonsVisible ifTrue:[
        tabRectangle moveBy: 0 @ (self tabSpace y + 16).
        backTabRectangle moveBy: 0 @ (self tabSpace y + 16)].

    aPen setTextAlign: TaNoupdatecp.
    basicFlags := DtVcenter | DtSingleline.
    flags := DtCenter | basicFlags.
    self isTabTextRight ifTrue:[ flags := DtRight | basicFlags].
    self isTabTextLeft ifTrue:[ flags := DtLeft | basicFlags].
    nTabs := 0.
    topMajorPage := self topMajorPage.
    self visibleMajorTabs do:[:each |
        topMajorPage = each
            ifTrue:[ rect := tabRectangle ]
            ifFalse:[ rect := backTabRectangle].
        rect := rect translateBy: 0 @ ((self majorTabExtent y + self tabSpace y) * nTabs).
        aPen
            foreColor: self colorBorder;
            backColor: self colorMajorTabBackground;
            setLineWidth: 1;
            rectangleFilled: rect.
        topMajorPage = each ifTrue:[
            aPen
                foreColor: self colorPageBackground;
                place: rect leftTop;
                goto: rect leftBottom].
        each tab isString
            ifTrue:[
                aPen
                    foreColor: self colorMajorTabText;
                    displayText: each tab
                        in: ( rect insetBy: self focusSpace )
                        options: flags ]
            ifFalse:[
                aPen
                    copyBitmap: each tab
                    from: each tab boundingBox
                    to: ( rect insetBy: self focusSpace ) ].

        each tabRectangle: rect.
        nTabs := nTabs + 1].!
hasNotebookStyle: aStyle

    ^(self notebookStyle bitAnd: aStyle) = aStyle!
isTabTextLeft
        "Private - Answer true if the receiver has the tabtextleft style
        else answer false"

    ^( self notebookStyle bitAnd: NbksTabLeftAlignedText ) =
        NbksTabLeftAlignedText!  
previousSelection
    "Before the page selection has been accepted, this
        method can be used to determine the page previously
        on top.
    After the notebook has accepted the selection (isOkToChange),
        this method will answer the current selection."

    ^self selectedPage!
getMnemonicHandler: char
    "Answer an object to handle the mnemonic <char>.
    This is platform dependent.  Since, on Windows,
    mnemonic:typedIn: is queued, the receiver must be
    a window.  Answer the receiver's window."
    | index |
    (tab notNil and: [ tab isString ])
        ifFalse: [ ^nil ].
    ^(( index := ( tab indexOf: '\u' replaceEscapeCharacters first )) ~= 0
        and: [( tab at: index + 1 ) asLowerCase == char asLowerCase ])
        ifTrue: [ window ]
        ifFalse: [ nil ]!   
initialize
        "Private - Initialize the receiver.
    Platform dependent"

	tab := String new.
	style := self defaultStyle! 
previousPage
        "Bring the previous page of the notebook to the top."
    | prev |

    ( prev := self queryPageBefore: self selection ) notNil
        ifTrue: [ self selectPage: prev ].! 
supportedEvents
        "Answer the Set of events that Sliders can notify
         their owners about."

    ^super supportedEvents
        add: #select;
        add: #button2Up;
        yourself!   
addToPages: aNotebookPage after: anIndexOrPage
    " Private -
        Add <aNotebookPage> to the page structure(s) after
            <anIndexOrPage>.  If nil, add to the end."

"    pages at: aNotebookPage id put: aNotebookPage."

    anIndexOrPage isNil
        ifTrue: [
            orderedPages addLast: aNotebookPage ]
        ifFalse: [
            anIndexOrPage isInteger
                ifTrue: [
                    orderedPages add: aNotebookPage afterIndex: anIndexOrPage ]
                ifFalse: [
                    orderedPages add: aNotebookPage after: anIndexOrPage ]].!  
initialize
    "Private"

    super initialize.
    self notebookPages: OrderedCollection new.!   
scrollTopTabIcon
        " Private - Answer the icon for the scroll top tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollTopTabIcon ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollTopTabIcon put: ( Icon fromModule: self class resourcesFileName id: 4 )].
    ^(self bitmaps at: #scrollTopTabIcon)!  
visibleMajorTabs
        "Private - Answers all the major tabs for the selected section"
    | visibleTabs majorPages start end |

    majorPages := self majorPages.
    end := ((self majorTabScrollPos + self majorTabRange - 1)
        min: (self majorTabScrollPos + majorPages size - 1)) min: majorPages size.
    start := self majorTabScrollPos.

    visibleTabs := OrderedCollection new: ( end - start + 1 max: 0 ).
    start to: end do: [ :visibleTabIndex |
        visibleTabs add: (majorPages at: visibleTabIndex) ].
    ^visibleTabs!  
display
        " Private - Display the notebook control"
    | bmp |

self doGraphics: [
    "Create new bitmap for display."
    bmp := Bitmap new ownDCScreenExtent: rectangle extent.
    "Copy template of notebook backgroud."
    bmp pen
        copyBitmap: self backgroundBitmap
        from: self backgroundBitmap boundingBox
        at: 0 @ 0.

    "Draw tabs onto bitmap."
    self displayMajorTabsWith: bmp pen.
    self displayMinorTabsWith: bmp pen.
    self displayStatusLineWith: bmp pen.

    "Draw the bitmap on the screen."
    graphicsTool
        copyBitmap: bmp
        from: bmp boundingBox
        at: 0 @ 0.
    bmp release.
]. "doGraphics"

    super hasFocus
        ifTrue: [
            self
                drawFocus;
                displayedFocus: true ].!
appendPage: aNotebookPage
        "Append aNotebookPage at the end of the receiver."
    | pageId |

    ( self isHandleOk not and: [ self deferUntilValid ])
        ifTrue: [
            ^self whenValid: #appendPage: with: aNotebookPage ].

    pageId := self insertPage: aNotebookPage afterIndexOrPage: nil.

    aNotebookPage updateDisplay.

    ^pageId! 
defaultStyle
        "Private - Answer an Integer with appropriate
         constants combination for default control style."
    ^WsChild  | WsClipchildren!  
tabSpace: aPoint
        " Set the gap between a tab and the next on "

    self propertyAt: #tabSpace put: aPoint!
lastPage
        "Bring the last page of the notebook to the top."

    self selectPage: self queryLastPage!   
getDefaultBitmap
        " Private - Answer a bitmap which is used when the resource only
        DLL is not present "
    | bmp |
    bmp := Bitmap screenExtent: 15 @ 15.
    bmp pen backColor: (OperatingSystem getSystemColor: SystemColorButtonFace).
    bmp pen erase.
    ^bmp!   
isPARTSNotebook
        "Answer whether the receiver is a notebook."

    ^true!   
pageNumber
        "Answer the page number for the current page."

    ^self pages indexOf: self selection!
hasMinorTab
        "Answer true if the page has minor tab."

    ^( style bitAnd: BkaMinor ) = BkaMinor!  
button2Up: aPoint
        "Private - Do popup menu."
    super button2Up: aPoint.
    self event: #button2Up!  
resourcesFileName
        " Private - Answer the filename of the resource
        only DLL"
    ^  'PW', OperatingSystem name first asString, 'RES',
        "PARTSSessionManager platformProductVersion, "
        Smalltalk versionNumbers first asString,
        "( Smalltalk versionNumbers at: 2 ) asString" '0',
        '.DLL'!
bitmaps: bmpsDictionary
         " Private - Answer the bitmap dictionary"

    bmps := bmpsDictionary!
pageToSelect: aPage
    "Private -
            Verify that the page selection can take place.
        Answer the page selected or nil if the selection
        can not be done.
            If <aPage> is nil, select the first page."
    | validPage |

    validPage := aPage.
    validPage isNil
        ifTrue: [ validPage := self queryFirstPage ].
    ( validPage notNil and: [
        self isOkToChange ])
        ifFalse: [ ^nil ].

    ^validPage! 
receiveAllWindowMessages
        "Subclass the MS Windows control for the receiver so
         that all MS Windows messages will be received."
"Do nothing for notebook"!  
minorTabExtent
        "Answer the extent of the minor tabs."

    ^self propertyAt: #minorTabExt ifAbsent: [ 30 @ 30 ]!   
initSize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
    | hiddenChildren |

    self demandLoad
        ifTrue: [
            hiddenChildren := self children.
            self children: nil.
            super initSize: aRectangle.
            self children: hiddenChildren ]
        ifFalse: [ super initSize: aRectangle ].!
buildWindow: parentWindow
    "Private - Create the window for the receiver using
        parentWindow as the parent.  To enable demand loading,
        hide the children temporarily so that they are not built.
        (When the page is brought to front, build the children)."
    | hiddenChildren result |

    ( self parent demandLoad )
        ifFalse: [ ^super buildWindow: parentWindow ].

    hiddenChildren := self children.
    self children: nil.
    result := super buildWindow: parentWindow.
    self children: hiddenChildren.

    ^result!
displayedFocus: aBoolean
    "Private - Set whether the focus has already
    been drawn by display"

     ^self propertyAt: #displayedFocus put: aBoolean!   
pagePaneGroup: aWindow
        " Private - Set the receiver's group of notebook page panes"
    pagePaneGroup := aWindow!   
colorMajorTabBackground
        " Answer the background color for major tabs "
    | color |
    color := self propertyAt: #colorMajorTabBackground.
    color isNil ifTrue:[ color := self colorPageBackground ].
    ^color!   
activate

    super activate.
    super hasFocus
        ifTrue: [ self drawFocus ].! 
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #aboutToChange ;
        add: #changedPage: ;
        add: #changedPageNumber: ;
        add: #selectRequested: ;
        yourself!
isTabTextCenter
        "Private - Answer true if the receiver has the tabtextcenter style
        else answer false"

    ^( self notebookStyle bitAnd: NbksTabCenteredText ) =
        NbksTabCenteredText!
minorTabVisible: aMinorPage
    "Private - Answer whether <aMinorPage> is visible"

    self isScrollMinorTabButtonsVisible
        ifFalse: [ ^true ].

    ^self visibleMinorTabs includes: aMinorPage!   
setDims: aBkaConstant extent: aPoint
        "Private - Set the dimensions of part of the receiver.
    Platform dependent "

    aBkaConstant = BkaMajor
        ifTrue: [
            self marginExtent:
                ((self majorTabExtent x + (self numberOfBackPages * 3)) @
                    self marginExtent y) ].

    aBkaConstant = BkaMinor
        ifTrue: [
            self marginExtent:
                (self marginExtent x @
                    (self minorTabExtent y + (self numberOfBackPages * 3))) ].

    aBkaConstant = BkaPagebutton
        ifTrue: [ "Do nothing" ].

    self updateAttributes.!  
tab: aStringOrBitmapOrIcon
        "Set the tab text or bitmap for the receiver.
         An icon's color bitmap will be used as the tab."

    tab notNil
        ifTrue: [
            tab == aStringOrBitmapOrIcon
                ifTrue: [ ^self ].
            tab isBitmap
                ifTrue: [ tab archiveAndRelease ]].

    tab :=
        ( aStringOrBitmapOrIcon isString
            ifTrue: [ aStringOrBitmapOrIcon ]
            ifFalse: [
                aStringOrBitmapOrIcon isBitmap
                    ifTrue: [ aStringOrBitmapOrIcon clone  ]
                    ifFalse: [
                        aStringOrBitmapOrIcon isIcon
                            ifTrue: [ tab colorBitmap clone  ]
                            ifFalse: [ nil ]]])!   
scrollLeftPageBitmap
        " Private - Answer the left page bitmap"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #leftPage ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #leftPage put: ( Bitmap fromModule: self class resourcesFileName id: 15 )].
    ^(self bitmaps at: #leftPage)! 
notebookPages
    "Answer the notebook pages as an orderedCollection"

    ^notebookPages! 
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."

    ^TransparentToMouse!  
majorTabExtent
    " Private - Answer the extent of the major tabs"

    majorTabExtent isNil
        ifTrue: [ majorTabExtent := super majorTabExtent ].        "Has a default value."
    ^majorTabExtent! 
insertPage: aNotebookPage afterIndexOrPage: anIndexOrPage
    "Private -
    Insert <aNotebookPage> after page or index
        <anIndexOrPage>.  If <anIndexOrPage> is 0, the page will be
        inserted at the first position.  If <anIndexOrPage> is nil,
        the page will be inserted at the last position.
        Answer the id of the page.
	Platform dependent "
    | pageId |

    ( pageId := self nextPageId ) = 0
        ifTrue: [ ^self error: 'unable to add page' ].

    self addToPages: ( aNotebookPage id: pageId ) after: anIndexOrPage.
    aNotebookPage notebook: self.

    self selection isNil
        ifTrue:[ self selectPage: aNotebookPage ]
        ifFalse:[ self updateScrollPageState ].

    ^pageId!
defaultBitmaps
        " Private - Make default bmps if the resource only DLL
        is not found "
    | hLibrary |

    self bitmaps isNil
        ifTrue: [ self bitmaps: Dictionary new. ].

    hLibrary := KernelLibrary loadLibrary: self class resourcesFileName asParameter.
    hLibrary < 32
        ifTrue: [ hLibrary := nil ]
        ifFalse: [ KernelLibrary freeLibrary: hLibrary asParameter ].

    hLibrary notNil ifTrue:[ ^self ].

    self bitmaps at: #rightPage put: self getDefaultBitmap.
    self bitmaps at: #rightPageDisabled put: self getDefaultBitmap.
    self bitmaps at: #leftPage put: self getDefaultBitmap.
    self bitmaps at: #leftPageDisabled put: self getDefaultBitmap.
    self bitmaps at: #scrollTopTabIcon put: self getDefaultTabIcon.
    self bitmaps at: #scrollBottomTabIcon put: self getDefaultTabIcon.
    self bitmaps at: #scrollBottomTabIconDisabled put: self getDefaultTabIcon.
    self bitmaps at: #scrollLeftTabIconDisabled put: self getDefaultTabIcon.
    self bitmaps at: #scrollRightTabIconDisabled put: self getDefaultTabIcon.
    self bitmaps at: #scrollTopTabIconDisabled put: self getDefaultTabIcon.
    self bitmaps at: #scrollLeftTabIcon put: self getDefaultTabIcon.
    self bitmaps at: #scrollRightTabIcon put: self getDefaultTabIcon.!   
calcPageRect
        " Private - Answers the client notebook rectangle in screen coordinates "
    | r address |

    self
        partsIfOS2Do: [
            r := (Smalltalk at: #PMRectangle) fromRectangle: self rectangle.
            address := ExternalAddress copyToNonSmalltalkMemory: r asParameter.
            PARTSHostInterface hostWindowLibrary
                sendMsg: self handle
                   msg: NbksCalcPageRect
                   mp1: address asParameter
                   mp2: true asParameter.
            r := (Smalltalk at: #PMRectangle) fromAddress: address.
            address free.
            ^r asRectangle ]
        partsIfWindowsDo: [
            ^self pagePaneGroup frameRectangle ]!
page
        "Answer the page key for the current page."

    ^self selection key! 
tab
    "Answer the tab for the receiver."

    ^tab!  
noTab
        " Make the receiver have no tab. "

    self
        removeStyle: BkaMinor;
        removeStyle: BkaMajor.!
tabStyle: aTabStyle
    "Private - Set the tab style of the receiver. "

    self perform: aTabStyle asSymbol.!
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #selected: ;
        yourself!
arrowIntoPagePane
    "Set the focus on one of the children of the top page.
    Do explicit search for tab stop here, because existing tab code
    expects one of the siblings to have the focus.  If no siblings have the
    focus and none are a tab stop or enabled, get an infinite loop."
    | oc child selectedPage |

    ( selectedPage := self selectedPage ) isNil
        ifTrue: [ ^self ].

    ( oc := selectedPage window orderedChildren ) notEmpty
        ifTrue: [
            ( child := oc detect: [ :anOrderedChild |
                ( anOrderedChild isATabStop and: [ anOrderedChild disabled not ])]
                ifNone: [ nil ]) notNil
            ifTrue: [ child setFocus ]]!
isScrollMajorTabButtonsVisible
        "Private - Answers true if the scroll major tab buttons are visible"

    ^self majorTabRange < self majorPages size!   
wmSetcursor: wParam with: lParam
        "Private - Process the set cursor message."
    | currentCursor |
    (self helpManager notNil and:[self mainWindow helpManager helpMode])
        ifTrue: [ self mainWindow helpManager setHelpCursor. ^1 ].
    lParam lowWord = Htclient
        ifTrue:
            [
            currentCursor := self currentCursor.
            currentCursor isNil
                ifTrue:[ ^nil ].
            currentCursor setCursor.
            ^1
            ]
        ifFalse: [ ^nil ]!   
major
        "Make the receiver have a major tab."

    self removeStyle: BkaMinor.
    self addStyle: BkaMajor.!
demandLoad: aBoolean
        "Set the demand load flag. When this flag is set (on),
         the notebook page contents is not recreated until it is
         page is selected."

    self propertyAt: #demandLoad put: aBoolean!
isStatusTextLeft
        "Private - Answer true if the receiver has the statustextleft style
        else answer false"

    ^( self notebookStyle bitAnd: NbksLeftAlignedStatusText ) =
        NbksLeftAlignedStatusText!  
updateScrollPageState
        " Private - Enable or disable the scroll page buttons"

    self isHandleOk ifFalse: [^self].
    (self pages isEmpty or: [self selection = self pages last])
        ifTrue:[(self childAtId: 200) disable]
        ifFalse:[(self childAtId: 200) enable].
    (self pages isEmpty or: [self selection = self pages first])
        ifTrue:[(self childAtId: 201) disable]
        ifFalse:[(self childAtId: 201) enable].!  
isPARTSTransientPart
        "Answer whether the receiver is a part which exists
        only while its containing application is being edited
        in a PARTS Workbench. "

    ^true!   
arrowFromPagePane
    "Focus is going from the top page's
    page pane to the receiver.
    Platform dependent."

    self focusPage: self selectedPage.
    super setFocus!   
addStyle: styleBits
        "Private - Add the style to the receiver.  The
    notebookk is not  real control and stores its style
    in a private location.   Answer the added styleBits."

    self notebookStyle: self notebookStyle | styleBits.
    ^self notebookStyle!  
removeAllFromPages
    "Private - Remove all pages from the page
        structures.  Close each page."

    orderedPages do: [ :aPage |
        aPage notebook == self        "Make sure not retained by another notebook."
            ifTrue: [ aPage close ]].

"    pages := Dictionary new."
    orderedPages := OrderedCollection new.!   
deactivate

    super deactivate.
    super hasFocus
        ifTrue: [ self eraseFocus ].!
selection: aPage
    "Private -
        Select aPage by bringing it to the top.
        Does not allow selection to be aborted, nor
            triggers any events.
    Platform dependent "
    | pagePane oldWindow selectedPage pageLoaded |

    aPage isNil ifTrue: [^self].
    pageLoaded := false.

    self selectedPage notNil
        ifTrue:[ oldWindow := self selectedPage window ].
    self selectedPage: aPage.
    self isHandleOk
        ifFalse:[^self].

    selectedPage := self selectedPage.
    self focusPage: selectedPage.

    self demandLoad
        ifTrue: [ pageLoaded := selectedPage buildWindow ].

    "Allow pane to be updated before showing."
    self triggerEvent: #selectRequested: with: selectedPage.

    "Hide old window, show new window"
    pagePane := selectedPage window.
    (pagePane ~= oldWindow and: [ oldWindow notNil ] )
        ifTrue:[ oldWindow hideWindow].
    pagePane bringToTop.
    (pagePane notNil and:[pagePane isVisible not])
        ifTrue: [pagePane showWindow].

    self selection hasMajorTab
        ifTrue:[self minorTabScrollPos: 1].
    (self topMajorPage notNil and:[(self visibleMajorTabs includes: self topMajorPage) not])
        ifTrue:[self majorTabScrollPos: (((self majorPages indexOf: self topMajorPage) - (self majorTabRange // 2)) max: 1)].
    (self topMinorPage notNil and:[(self visibleMinorTabs includes: self topMinorPage) not])
        ifTrue:[self minorTabScrollPos: (((self minorPages indexOf: self topMinorPage) - (self minorTabRange // 2)) max: 1)].

    self display.  "Redraw notebook"

    "If pagePane was just built, above 'self display' will have
        already redrawn the page."
    ( pagePane == oldWindow  "Sharing windows"
        and: [ pageLoaded not
        and: [ pagePane notNil ]])
        ifTrue: [ pagePane invalidateRect: nil ].

    self partIsEditing
        ifTrue: [     "Return focus to the workbench"
            owner partEditor workbenchPane setFocus ]
        ifFalse: [  "Retrieve focus from page buttons"
            self setFocus ].

    "Do this after setFocus, or page button with the
        focus will try to go throught the tab scope if it
        is disabled."
    self updateScrollPageState.
    self updateScrollTabState.! 
pageButtonExtent: aPoint
        "Set the size of the page cycle buttons to aPoint
         where x is the width and y is the height."

    pageButtonExtent := aPoint.
    self setDims: BkaPagebutton extent: aPoint.
    self resizePagePaneGroup.!  
partPropertySetStyle: newStyle
        "Private - Change the style of the receiver to newStyle."

    self notebookStyle: newStyle!
pagePaneGroup
        " Private - Answer the receiver notebook page"

    ^pagePaneGroup!  
focusUp
    "Private - Move the focus up to the previous major tab.
    Assumed that focus is on a major tab."
    | majorPages currentMajor |

    majorPages := self majorPages.
    currentMajor := self focusPage.
    majorPages first == currentMajor
        ifTrue: [ ^self ].
    self visibleMajorTabs first == currentMajor
        ifTrue: [ self previousMajorTab ].
    self redrawFocus: ( majorPages before: currentMajor )!   
minorTabExtent: aPoint
        "Set the size of the minor tabs to aPoint
         where x is the width and y is the height."

    minorTabExtent = aPoint
        ifTrue: [ ^self ].

    minorTabExtent := aPoint.
    self setDims: BkaMinor extent: aPoint.
    self resizePagePaneGroup.!
isStatusTextOn
        "Answer true if the receiver has the style StatusTextOn
        else answer false. If this attribute is not specified, the application
        cannot associate a text string with the status area of the page
        being inserted"

    self partsVwOnly.  " Only used on VW"
    ^( style bitAnd: BkaStatustexton ) = BkaStatustexton! 
isStatusTextRight
        "Private - Answer true if the receiver has the statustextright style
        else answer false"

    ^(self notebookStyle bitAnd: NbksRightAlignedStatusText) =
        NbksRightAlignedStatusText!
notebookPages: anOrderedCollection
    "Private - set the notebook pages as an orderedCollection"

    notebookPages := anOrderedCollection.!  
findUnderCursor: aPoint
        "Private - Answer the page underneath aPoint"
    | p |
    p := self visibleMajorTabs detect:[: each |
        each tabRectangle containsPoint: aPoint] ifNone:[ nil ].
    p isNil ifTrue:[
        p := self visibleMinorTabs detect:[: each |
            each tabRectangle containsPoint: aPoint] ifNone:[ nil ]].
    ^p!   
noGroupLeader
        "Make the receiver not be a group leader.  By default
        every subpane is not a group leader."
    super removeStyle: WsGroup!  
drawScrollTopTab: aPane
        " Private - Draw the scroll top tab button "
    | icon |
    icon := self scrollTopTabIcon.
    aPane disabled ifTrue:[
        icon := self scrollTopTabIconDisabled].
    icon displayAt: 2 @ 1 with: aPane graphicsTool!
startGroup
        "Make the receiver the first in a group"
    super addStyle: WsGroup!
tabRectangle: aRectangle
        "Private - Set the receiver's tab rectangle"
    self partsVwOnly.  " Only used on VW" 
    tabRectangle := aRectangle!   
displayForScrolledTab
        " Private - Draw minor and major tabs"

    handle isValid ifFalse:[^self].
    self display.
    self updateScrollTabState!   
topMajorPage
        "Private - Answers the receiver's top major page."
    | topMajorPage |

    topMajorPage := self selection.
    topMajorPage isNil ifTrue:[ ^nil ].
    topMajorPage hasMajorTab ifFalse:[
        topMajorPage := self majorPageBefore: topMajorPage].

    ^topMajorPage!
displayStatusLineWith: aPen
    | statusRect flags|

    self selection isNil ifTrue: [ ^self ].
    self selection isStatusTextOn ifFalse: [ ^self ].
    statusRect := self statusLineBoundingRectangle.
    aPen setTextAlign: TaNoupdatecp.
    flags := 0.
    self isStatusTextRight ifTrue:[ flags := DtRight ].
    self isStatusTextCenter ifTrue:[ flags := DtCenter ].
    aPen
        foreColor: self foreColor;
        backColor: self backColor;
        displayText: self selection statusText
            in: statusRect
            options: flags.!
nextMinorTab
    " Private - The user has clicked the next major tab scroll button.
        Insure the receiver has the focus instead of its scroll
        buttons."

    self partIsEditing not
        ifTrue: [ self setFocus ].
    self minorTabScrollPos: self minorTabScrollPos + 1.
    self displayForScrolledTab.! 
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process page up, page down, etc. keys"
    | virtualKey focusPage |

    ( virtualKey := aKeyboardInputEvent virtualKey ) notNil
        ifTrue: [
            virtualKey == HomeKey ifTrue: [ ^self firstPage ].
            virtualKey == EndKey ifTrue: [ ^self lastPage ].
            virtualKey == PageUpKey ifTrue: [ ^self previousPage ].
            virtualKey == PageDownKey ifTrue: [ ^self nextPage ].

            ( virtualKey == DownKey and: [ Notifier isAltKeyDown ] )
                ifTrue: [ ^self arrowIntoPagePane ].

            ( virtualKey == TabKey or: [ virtualKey == BacktabKey  ] )
                ifTrue: [ ^self tabKeyInput: aKeyboardInputEvent ].

            ( focusPage := self focusPage ) notNil
                ifTrue: [
                    ( virtualKey == UpKey and: [ focusPage hasMajorTab ])
                        ifTrue: [ ^self focusUp ].
                    ( virtualKey == DownKey and: [ focusPage hasMajorTab ])
                        ifTrue: [ ^self focusDown ].
                    ( virtualKey == LeftKey and: [ focusPage hasMinorTab ])
                        ifTrue: [ ^self focusLeft ].
                    ( virtualKey == RightKey and: [ focusPage hasMinorTab ])
                        ifTrue: [ ^self focusRight ].
                    ( virtualKey == ReturnKey )
                        ifTrue: [ ^self selectPage: focusPage ]].
        ].

    aKeyboardInputEvent character == SpaceKey asCharacter
        ifTrue: [ ^self selectPage: self focusPage ].

    super keyboardInput: aKeyboardInputEvent!
mainPage
    "Answer the first notebook page that uses
        the receiver."

    ^self notebookPages first! 
addStyle: styleInteger
        "Private - Add the styleInteger to the style instance
        variable."
    style isNil ifTrue: [ style := self defaultStyle ].
    style := style | styleInteger.
    ^style!   
setWindow: aWindow
    "Set the window of the receiver to <aWindow> and update
        the receiver when it is valid."

    self window: aWindow.
    notebook demandLoad
        ifFalse: [ self updateWindow ].!  
colorMinorTabText: aColor
        " Set the color text for minor tabs "

    self propertyAt: #colorMinorTabText put: aColor!  
colorMinorTabText
        " Answer the color text for minor tabs "
    | color |
    color := self propertyAt: #colorMinorTabText.
    color isNil ifTrue:[ color := self foreColor ].
    ^color!   
marginExtent
        "Private - Set the margin of the notebook
         where x is the width and y is the height."

    ^marginExtent!
minorPageBefore: anotherPage
    | nextPage |

    nextPage := self pages before: anotherPage ifNone:[].
    [nextPage notNil and:[nextPage hasMinorTab not]] whileTrue:[
        nextPage := self pages before: nextPage ifNone:[]].
    ^nextPage!
updateTab
    "Private -
        Update the tab after the page has already
        been added to the notebook.
    Platform dependent"

    ( tab isNil or: [
        notebook isNil or: [
        notebook isHandleOk not ]])
        ifTrue: [ ^nil ].

    notebook doGraphics:[
        self hasMajorTab
            ifTrue:[ notebook displayMajorTabsWith: notebook graphicsTool ].
        self hasMinorTab
            ifTrue:[ notebook displayMinorTabsWith: notebook graphicsTool ]].

    notebook drawFocus!
backgroundBitmap: aBitmap
        " Private - Set the notebook bitmap"
    self propertyAt: #backgroundBitmap put: aBitmap! 
canTab
        "Private - Answer whether the receiver can
        be tabbed into and out of."

    ^false!
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."

    ^false!
redrawFocus: aPage
    "Private - Redraw the focus on <aPage>.
    Set the new focus page"

    aPage isNil ifTrue: [ ^self ].

    self eraseFocus.
    self focusPage: aPage.
    self drawFocus!   
getDefaultTabIcon
        " Private - answer an empty icon "

   ^(Smalltalk at: #PARTSIcon) transparent!  
colorMinorTabBackground: aColor
        " Set the back color for minor tabs "

    self propertyAt: #colorMinorTabBackground put: aColor!  
tabSpace
        " Answer the gap between a tab and the next on "

    ^self propertyAt: #tabSpace!
visibleMinorTabs
        "Private - Answers all the minor tabs for the selected section"
    | visibleTabs minorPages start end |

    minorPages := self minorPages.
    end := ((self minorTabScrollPos + self minorTabRange - 1)
        min: (self minorTabScrollPos + minorPages size - 1)) min: minorPages size.
    start := self minorTabScrollPos.

    visibleTabs := OrderedCollection new: ( end - start + 1 max: 0 ).
    start to: end do: [ :visibleTabIndex |
        visibleTabs add: (minorPages at: visibleTabIndex) ].
    ^visibleTabs!  
isPARTSNotebookClientAreaPane

    ^true!   
removeFromPages: aNotebookPage
    "Private - Remove <aNotebookPage> from the
        page structures."

"    pages removeKey: aNotebookPage id ifAbsent: []."
    orderedPages remove: aNotebookPage ifAbsent: [].

    aNotebookPage notebook == self     "Make sure not retained by another notebook."
        ifTrue: [ aNotebookPage close ]!
majorTabScrollPos
        " Private - Answer the index of the first visible major tab
        in the majorPages collection "

    ^majorTabScrollPos! 
window: newWindow
    "Private -
        Set the window for the receiver.  If a window is already set,
        remove self from the old window's owner pages."

    newWindow isPARTSNotebookPagePane
        ifTrue: [
            window notNil        "old window"
                ifTrue: [ window removeNotebookPage: self ].
            newWindow addNotebookPage: self  ].

    window := newWindow.!  
aboutToSaveImage
        "Private - Do not the bmps when saving the image
    Platform dependent"

    super aboutToSaveImage.
    self backgroundBitmapBasic notNil
        ifTrue: [ self backgroundBitmap release ].
    self backgroundBitmap: nil.
    self bitmaps notNil
        ifTrue: [
            self bitmaps do: [:each | each release ].
            self bitmaps: nil ].!  
colorBorder
        " Answer the background color for major tabs "
    | color |
    color := self propertyAt: #colorBorder.
    color isNil
        ifTrue: [ color := OperatingSystem getSystemColor: SystemColorWindowBorder ].
    ^color!  
close
        " Private - close the receiver. Release the bmps "

    super close.
    self backgroundBitmapBasic notNil ifTrue: [
        self backgroundBitmap release.
        self backgroundBitmap: nil].

    self bitmaps notNil
        ifTrue: [ self bitmaps do: [:each | each archiveAndRelease ]].!  
colorMajorTabBackground: aColor
        " Set the background color for major tabs "

    self propertyAt: #colorMajorTabBackground put: aColor!
new
        "Answer a new instance of the receiver."
    ^super new initialize! 
open
        "Private - Window is opened."
    | pane max|

    self children isEmpty ifFalse: [^ self ].       " Already opened "
    max := self font height max: pageButtonExtent y.
    super addSubpane: pagePaneGroup.
    super addSubpane: (
        (pane := DrawnButton new)
            owner: self;
            style: pane getStyle;
            id: 200;
            addBorderStyle;
            drawAnisotropic;
            when: #clicked
                send: #nextPage to: self;
            when: #drawItem
                send: #drawScrollRightPage: to: self with: pane;
            framingBlock:[:box |
                (((box insetBy: 2 @ 2 ) rightBottom leftAndUp: marginExtent) leftAndUp: pageButtonExtent )
                    extentFromLeftTop: pageButtonExtent]).
    super addSubpane: (
        (pane := DrawnButton new)
            owner: self;
            style: pane getStyle;
            id: 201;
            addBorderStyle;
            drawAnisotropic;
            when: #clicked
                send: #previousPage to: self;
            when: #drawItem
                send: #drawScrollLeftPage: to: self with: pane;
            framingBlock:[:box |
                ((((box insetBy: 2 @ 2 ) rightBottom leftAndUp: marginExtent) leftAndUp: (2 @ 1) *
pageButtonExtent) rightAndUp: 2 @ 0 )
                    extentFromLeftTop: pageButtonExtent]).

    super addSubpane: (
        (pane := DrawnButton new)
            owner: self;
            style: BsOwnerdraw | WsChild ;
            id: 202;
            addBorderStyle;
            drawAnisotropic;
            when: #clicked
                send: #previousMajorTab to: self;
            when: #drawItem
                send: #drawScrollTopTab: to: self with: pane;
            framingBlock:[:box |
                ((box rightTop leftAndDown: marginExtent x @ 0) rightAndDown: self numberOfBackPages *
3)
                    extentFromLeftTop: 16 @ 16]).

    super addSubpane: (
        (pane := DrawnButton new)
            owner: self;
            style: pane getStyle;
            id: 203;
            addBorderStyle;
            drawAnisotropic;
            when: #clicked
                send: #nextMajorTab to: self;
            when: #drawItem
                send: #drawScrollBottomTab: to: self with: pane;
            framingBlock:[:box |
                (((box rightBottom leftAndUp: marginExtent) rightAndDown: self numberOfBackPages * 3)
up: 14)
                    extentFromLeftTop: 16 @ 16]).

    super addSubpane: (
        (pane := DrawnButton new)
            owner: self;
            style: BsOwnerdraw | WsChild ;
            id: 204;
            addBorderStyle;
            drawAnisotropic;
            when: #clicked
                send: #previousMinorTab to: self;
            when: #drawItem
                send: #drawScrollLeftTab: to: self with: pane;
            framingBlock:[:box |
                (((box leftBottom rightAndUp: 0 @ marginExtent y) rightAndDown: self numberOfBackPages
* 3) right: 1)
                    extentFromLeftTop: 16 @ 16]).

    super addSubpane: (
        (pane := DrawnButton new)
            owner: self;
            style: pane getStyle;
            id: 205;
            addBorderStyle;
            drawAnisotropic;
            when: #clicked
                send: #nextMinorTab to: self;
            when: #drawItem
                send: #drawScrollRightTab: to: self with: pane;
            framingBlock:[:box |
                ((((box rightBottom leftAndUp: marginExtent) leftAndDown: 16 @ 0) rightAndDown: (self
numberOfBackPages * 3) ) right: 2)
                    extentFromLeftTop: 16 @ 16]).

    self triggerEvent: #needsContents.
    super open!
queryPage: aBkaConstant beside: aPage
        "Private - Answer the specified page.
    Platform dependent "

    self pages isEmpty
        ifTrue: [ ^nil ].

    aBkaConstant = BkaTop
        ifTrue: [ ^self selectedPage ].
    aBkaConstant = BkaFirst
        ifTrue: [ ^self pages first ].
    aBkaConstant = BkaLast
        ifTrue: [ ^self pages last ].
    aBkaConstant = BkaNext
        ifTrue: [ ^self pages after: aPage ifNone:[ nil ]].
    aBkaConstant = BkaPrev
        ifTrue: [ ^self pages before: aPage ifNone:[ nil ]].! 
initialize
        "Private - Initialize the receiver."

    super initialize.
"    pages := Dictionary new."
    self orderedPages: OrderedCollection new.! 
key: aString
    "Set the key value for the receiver."

    key := aString!
pages
    "Answer an ordered collection of pages in the
        order they appear in the notebook."

    orderedPages isNil
        ifTrue: [ ^OrderedCollection new ].

    ^orderedPages!
buildWindow
    "Build the window on demand.  Answer whether the page was built.
        Platform dependent.  Parent is the client area pane on Windows.
    Need to resize the window on Windows, but on OS/2 not needed."
    | parentWindow parentRect |

    ^ ( window notNil and: [ window isHandleOk not ])
        ifTrue: [
            parentWindow := notebook pagePaneGroup.
            parentRect := ( 0 @ 0 extent: parentWindow extent ).
            window
                open;
                initSize: parentRect;
                buildWindow: parentWindow;
                resize: parentRect;
                validate.
            self
                updateStatus;
                updateWindow.
            true ]
        ifFalse: [ false ]! 
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
        ifTrue: [index := 1].
    ^(child := orderedChildren at: index) hasFocus
        ifTrue: [child]
        ifFalse: [child nextTabStop]!   
style: anInteger
        "Private - Set the style for the receiver to anInteger which
         is composed of Bka constants from NotebookConstants."
    style := anInteger!   
id: anInteger
        "Private - Set the id for the receiver."
    id := anInteger! 
previousMinorTab
    " Private - The user has clicked the previous major tab scroll button.
        Insure the receiver has the focus instead of its scroll
        buttons."

    self partIsEditing not
        ifTrue: [ self setFocus ].
    self minorTabScrollPos: ( self minorTabScrollPos - 1 max: 1 ).
    self displayForScrolledTab.!  
initialize
        " Private - Intialize the notebook "
    super initialize.
    marginExtent := 0 @ 0.
    self numberOfBackPages: 3.
    self majorTabExtent: 30 @ 30.
    self minorTabExtent: 20 @ 20.
    pageButtonExtent := 30 @ 30.
    self propertyAt: #nextPageId put: 0.
    self tabSpace: 2 @ 2.
    self majorTabScrollPos: 1.
    self minorTabScrollPos: 1.
    curFont := self defaultFont.
    ( pagePaneGroup := PARTSNotebookClientAreaPane new )
        owner: self;
        setName: #page;
        style: pagePaneGroup getStyle;
        framingBlock: self clientFramingBlock.
    pagePaneGroup parent: self.! 
updateStatus
    "Private -
        Update the status text after the page has already
    been added to the notebook.
        Platform dependent"

    ( statusText isNil or: [
        notebook isNil or: [
        notebook isHandleOk not ]])
        ifTrue: [ ^nil ].

        notebook invalidateRect: notebook statusLineBoundingRectangle.
        notebook updateWindow.

"    notebook doGraphics:[
        notebook displayStatusLineWith: notebook graphicsTool.]."!   
drawScrollRightTab: aPane
        " Private - Draw the scroll right tab button"
    | icon |
    icon := self scrollRightTabIcon.
    aPane disabled ifTrue:[
        icon := self scrollRightTabIconDisabled].
    icon displayAt: 1 @ 2 with: aPane graphicsTool! 
setStatusText: aString
    | page str |
    aString isString
        ifTrue: [str := aString]
        ifFalse: [
            aString isNil
                ifTrue: [str := '']
                ifFalse: [str := aString printString]].
    page := self selectedPage.
    page statusText: str.
    self containingNotebook setStatus: str page: page!  
addNotebookPage: aNotebookPage
    "Private -
        Add <aNotebookPage> to the list of pages which the
        receiver is used to display."

    notebookPages addLast: aNotebookPage!
focusSpace
    "Private - Answer the space between the tab contents
    and the tab border used to display the focus rect."

    ^4!  
scrollRightTabIconDisabled
        " Private - Answer the icon for the scroll right tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollRightTabIconDisabled ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollRightTabIconDisabled put: ( Icon fromModule: self class resourcesFileName id: 7 )].
    ^(self bitmaps at: #scrollRightTabIconDisabled)!
focusPage
    "Private - Answer the page with focus when the receiver
    has the focus."
    | focusPage allPages tempIndex |

    self partIsEditing
        ifTrue: [ ^nil ].

    ( focusPage := self propertyAt: #focusPage ) notNil
        ifFalse: [
            ( focusPage := self selectedPage ) isNil
                ifTrue: [ ^nil ].
            focusPage hasMajorTab
                ifFalse: [
                    allPages := self pages.
                    tempIndex := allPages indexOf: focusPage.
                    focusPage := nil.
                    [ tempIndex > 0
                        and: [ ( focusPage := allPages at: tempIndex ) hasMajorTab not ]]
                            whileTrue: [ tempIndex := tempIndex - 1 ].
                    tempIndex = 0
                        ifTrue: [ focusPage := self selectedPage ]]].

    self focusPage: focusPage.
    ^focusPage! 
minorPages
        "Private - Answers all the minor tabs for the selected section"
    | topMajorPage minorTabs page|

    topMajorPage := self topMajorPage.
    minorTabs := OrderedCollection new.
    topMajorPage isNil
        ifTrue:[ page := self pages isEmpty ifTrue:[] ifFalse:[ self pages first ]]
        ifFalse:[page := self pages after: topMajorPage ifNone:[]].
    [page notNil and:[page hasMajorTab not]] whileTrue:[
        page hasMinorTab ifTrue:[minorTabs add: page].
        page := self pages after: page ifNone:[]].
    ^minorTabs!   
setStatus: aString page: aPage
        "Set the status line for aPage"

    aPage statusText: aString.
    self isHandleOk ifTrue:[
        self invalidateRect: self statusLineBoundingRectangle.
        self updateWindow].! 
bitmaps
         " Private - Answer the bitmap dictionary"

    ^bmps! 
focusPage: aPage
    "Private - Set the page that has the focus."

    self propertyAt: #focusPage put: aPage! 
updateWindow
    "Private -
        Update the window after the page has already
    been added to the notebook.  On Windows this is not necessary.
        Platform dependent"!  
removeNotebookPage: aNotebookPage
    "Private -
        Remove <aNotebookPage> from the list of pages which the
        receiver is used to display."

    notebookPages remove: aNotebookPage ifAbsent: [ nil ]!   
scrollRightTabIcon
        " Private - Answer the icon for the scroll right tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollRightTabIcon ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollRightTabIcon put: ( Icon fromModule: self class resourcesFileName id: 3 )].
    ^(self bitmaps at: #scrollRightTabIcon)!
gettingFocus
    "Private - Draw the focus"
    super gettingFocus.
    self displayedFocus
        ifFalse: [ self drawFocus ].! 
notebookClientArea


    ^rectangle leftTop extent: (rectangle extent leftAndUp: marginExtent)!
partMirrorCopyReal: aDictionary
        " Private - add a mirror copy of the receiver
        to aDictionary.  Answer the copy. "
    | copy |

    copy := super partMirrorCopyReal: aDictionary.

    copy
        marginExtent: (marginExtent partMirrorCopy: aDictionary);
        majorTabScrollPos: (majorTabScrollPos partMirrorCopy: aDictionary);
        minorTabScrollPos: (minorTabScrollPos partMirrorCopy: aDictionary);
        pagePaneGroup: (self pagePaneGroup partMirrorCopy: aDictionary);
        orderedPages: (orderedPages partMirrorCopy: aDictionary).

    ^copy!   
colorMinorTabBackground
        " Answer the background color for minor tabs "
    | color |
    color := self propertyAt: #colorMinorTabBackground.
    color isNil ifTrue:[ color := self colorPageBackground ].
    ^color!   
scrollRightPageBitmapDisabled
        " Private - Answer the right page bitmap when the scroll right
        button is disabled "

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #rightPageDisabled ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #rightPageDisabled put: ( Bitmap fromModule: self class resourcesFileName id: 17 )].
    ^(self bitmaps at: #rightPageDisabled)! 
focusLeft
    "Private - Move the focus left to the previous minor tab.
    Assumed that focus is on a minor tab."
    | minorPages currentMinor |

    minorPages := self minorPages.
    currentMinor := self focusPage.
    minorPages first == currentMinor
        ifTrue: [ ^self ].
    self visibleMinorTabs first == currentMinor
        ifTrue: [ self previousMinorTab ].
    self redrawFocus: ( minorPages before: currentMinor )!   
window
        "Answer the window for the receiver."
    ^window!   
pageCount
        "Answer the number of pages in the receiver.
	Platform dependent "

    ^self pages size!   
deletePage: aNotebookPage
        "Delete <aNotebookPage> from the receiver.
    Platform dependent "

    aNotebookPage == self queryLastPage
        ifTrue: [ self previousPage ]
        ifFalse: [ self nextPage ].
    self pages remove: aNotebookPage ifAbsent:[].
    self removeFromPages: aNotebookPage.

    self
        updateScrollPageState;
        updateScrollTabState!
updateScrollTabState
        "Private - Hide, show, enable or disable the scroll tab buttons"

    self isScrollMajorTabButtonsVisible
        ifTrue:[
            (self childAtId: 202) showWindow.
            (self childAtId: 203) showWindow.
            self majorTabScrollPos = 1
                ifTrue:[ (self childAtId: 202) disable ]
                ifFalse:[(self childAtId: 202) enable ].
            self majorTabScrollPos + self majorTabRange > self majorPages size
                ifTrue:[ (self childAtId: 203) disable ]
                ifFalse:[(self childAtId: 203) enable ]]
        ifFalse:[(self childAtId: 202) hideWindow. (self childAtId: 203) hideWindow ].

    self isScrollMinorTabButtonsVisible
        ifTrue:[
            (self childAtId: 204) showWindow.
            (self childAtId: 205) showWindow.
            self minorTabScrollPos = 1
                ifTrue:[ (self childAtId: 204) disable ]
                ifFalse:[(self childAtId: 204) enable ].
            self minorTabScrollPos + self minorTabRange > self minorPages size
                ifTrue:[ (self childAtId: 205) disable ]
                ifFalse:[(self childAtId: 205) enable ]]
        ifFalse:[(self childAtId: 204) hideWindow. (self childAtId: 205) hideWindow ].! 
tabRectangle
        "Private - Answer the receiver's tab rectangle"
    self partsVwOnly.  " Only used on VW" 
    ^tabRectangle! 
tabKeyInput: aKeyboardInputEvent
        "Private - Respond to the tab keystroke."
    | allPages aPage start focusPage |

    self triggerEvent: #tabbed
        ifNotHandled: [
            ( focusPage := self focusPage ) isNil
                ifTrue: [ ^self ].
            aKeyboardInputEvent isShiftKeyDown
                ifTrue: [
                   focusPage hasMinorTab
                        ifTrue: [ "Focus goes to minor tab group's major tab"
                            ^self redrawFocus: self topMajorPage ]]
                ifFalse:  [
                    focusPage hasMajorTab
                        ifTrue: [  "Look for a minor tab"
                            start := ( allPages := self pages ) indexOf: self selection.
                            focusPage == self selection
                                ifTrue: [  "Major tab is selected.  Start at next page"
                                    start := start + 1 ].
                            start
                                to: allPages size
                                do: [ :anIndex |
                                    ( aPage := allPages at: anIndex ) hasMinorTab
                                        ifTrue: [ ^self redrawFocus: aPage ].
                                    aPage hasMajorTab
                                        ifTrue: [ ^super tabKeyInput: aKeyboardInputEvent ] ] ] ] ].

    ^super tabKeyInput: aKeyboardInputEvent!   
drawItem: aDrawStruct
        "Private - Process a request to draw a user drawn
         control item.  Answer true if item was painted."

    ^false!
defaultStyle
        "Private - Answer the default style.
    Platform dependent"

     ^BkaStatustexton! 
isPARTSNotebookPagePane
        "Answer whether the receiver is a PARTSNotebookPagePane"

    ^true!   
characterInput: aCharacter
        "This control does not capture keyboard input, so it
        can translate to a mnemonic without the alt key down.
        Try to match with a mnemonic character in a sibling."
    ( self superWindow altKeyInput: aCharacter from: self )
        ifTrue: [ ^self ].  "character handled"
    ^super characterInput: aCharacter!  
backgroundBitmapBasic
        " Private - Answer the notebook bitmap"

    ^self propertyAt: #backgroundBitmap!
validate
        "Private - The host window for the receiver was
         just created or recreated."
    | hiddenChildren |
    self parent demandLoad
        ifTrue: [
            hiddenChildren := self children.
            self children: nil.
            super validate.
            self children: hiddenChildren ]
        ifFalse: [
            super validate ]!
numberOfBackPages
        " Answer the number of backpages to represent the
        3-D effect of the notebook"

    ^self propertyAt: #numberOfPages!
drawWith: aPen
    "Backpages intersection at top left corner"
    | box thickBox |

    aPen
        backColor: self backColor;
        foreColor: self colorBorder;
        erase.

    box := self notebookClientArea.
    thickBox := box translateBy: 3 * self numberOfBackPages.
    aPen
        setLineWidth: 2;
        place: (box leftBottom rightAndUp: 2 @ 1);
        goto: ((box translateBy: (self numberOfBackPages + 1) * 3) leftBottom rightAndUp: 1 @ 2).

    aPen
        setLineWidth: 1.

    0 to: self numberOfBackPages do:[:i |
        aPen
            backColor: self colorPageBackground;
            rectangleFilled: (box translateBy: (self numberOfBackPages - i) * 3)
    ].


    aPen
        setLineWidth: 1;
        place: (box leftBottom rightAndUp: 2 @ 1);
        goto: ((box translateBy: (self numberOfBackPages + 1) * 3) leftBottom rightAndUp: 1 @ 2).

    aPen
        setLineWidth: 3;
        direction: 0;
        place: (thickBox leftBottom rightAndUp: 3 @ 0);
        go: thickBox width - 3;
        direction: 270;
        place: (thickBox rightTop rightAndDown: 0 @ 1);
        go: box height - 1.!
validate
        "Private - Window was just created, set the specified options.
    Platform dependent "
    | page |
    self demandLoad
        ifFalse: [
            self pagePaneGroup children do: [ :each | each hideWindow]].
    self subPaneValidate.
    self scrollTabButtons do: [ :button | button hideWindow].
    self updateScrollPageState.

    page := self selection.
    ( page notNil and: [ page window notNil])
        ifTrue: [
            self demandLoad
                ifTrue: [ page buildWindow ].    "Load on demand."
            page window
                bringToTop;
                showWindow.
            page selected ].   " trigger for compatibility with OS/2 notebook "
    self showWindow.!   
drawScrollBottomTab: aPane
        " Private - Draw the scroll bottom tab button "
    | icon |
    icon := self scrollBottomTabIcon.
    aPane disabled ifTrue:[
        icon := self scrollBottomTabIconDisabled].
    icon displayAt: 2 @ 1 with: aPane graphicsTool!
partRealWindowUnderPoint
        " Answer the real window of interest in a PARTS Workbench. "
    ^self parent! 
scrollTabButtons
        " Private - Answers all the scroll page buttons
        as a collection "
    ^Array
        with: (self childAtId: 202)
        with: (self childAtId: 203)
        with: (self childAtId: 204)
        with: (self childAtId: 205)! 
tabStop
        "Make the dialog item recieve the focus when the user
        presses the TAB key."
    super addStyle: WsTabstop! 
majorTabScrollPos: anInteger
        " Private - Set the index of the first visible major tab
        in the majorPages collection "

    majorTabScrollPos := anInteger! 
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #aboutToChange
            #changedPage:
            #changedPageNumber:
            );
         yourself!
drawScrollRightPage: aPane
        " Private - Draw the scroll right page button "
    | bmp |
    bmp := self scrollRightPageBitmap.
    aPane disabled ifTrue:[
        bmp := self scrollRightPageBitmapDisabled].
    aPane graphicsTool
        copyBitmap: bmp
        from:  bmp boundingBox
        to: aPane boundingBox.!  
insertPage: aNotebookPage after: anotherPage
        "Insert aNotebookPage into the receiver
         after anotherPage.  If anotherPage is nil, then
         put aNotebookPage first."
    | pageId pageBefore |

    ( self isHandleOk not and: [ self deferUntilValid ])
        ifTrue: [
            ^self whenValid: #insertPage:after:
                withArguments: ( Array with: aNotebookPage with: anotherPage )].

    pageBefore :=
        ( anotherPage isNil
            ifTrue: [ 0 ]
            ifFalse: [ anotherPage ]).

    pageId := self insertPage: aNotebookPage afterIndexOrPage: pageBefore.

    aNotebookPage updateDisplay.

    ^pageId!   
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        add: #selected ;
        yourself! 
defaultForeColor
        "Answer the default color for a notebook page."
    ^nil!  
colorMajorTabText
        " Answer the color text for major tabs "
    | color |
    color := self propertyAt: #colorMajorTabText.
    color isNil ifTrue:[ color := self foreColor ].
    ^color!   
id
        "Private - Answer the id of the receiver."
    ^id!  
statusText: aString
    "Private -
        Set the status line text for the receiver."

    statusText := aString!
minorTabExtent
    " Private - Answer the minorTab extent"

    minorTabExtent isNil
        ifTrue: [ minorTabExtent := super minorTabExtent ].        "Has a default value."
    ^minorTabExtent!  
wmErasebkgnd: wordInteger with: longInteger
        "Private - Process the erase background message.
        Ignore it because the background will be repainted by
        the notebook bitmap"

    ^1! 
pageSelected: newPage
    " Private-
        Platform independant code to be executed when the page has changed. "

    self isValid ifFalse: [
        ^self whenValid: #pageSelected: with: newPage ].
    self demandLoad
        ifTrue: [ newPage buildWindow ].
    self
        event: #select;
        triggerEvent: #changedPage:
            with: ( newPage isNil
                ifTrue: [ nil ]
                ifFalse: [ newPage key ]);
        triggerEvent: #changedPageNumber:
            with: ( newPage isNil
                ifTrue: [ nil ]
                ifFalse: [ self pages indexOf: newPage ] ).

    self selectedPage: newPage.
    newPage selected.!   
queryLastPage
        "Answer the last page."

    ^self queryPage: BkaLast beside: nil!   
addTabInfoFor: aPane
       "Private - Add tabing information for aPane to the receiver."

    self partIsEditing ifTrue: [super addTabInfoFor: aPane].!   
button1Down: aPoint
        "Private - Left button is pressed down"
    | p |

    self setFocus.
    p := self findUnderCursor: aPoint.
    p isNil ifTrue:[ ^self].
    self selectPage: p.! 
majorPages
        "Private - Answer all major pages"

    ^self pages select: [:each | each hasMajorTab]! 
addSubpane: aPane
        "Private - Add subpane aPane to the receiver."

    pagePaneGroup addSubpane: aPane! 
focusDown
    "Private - Move the focus down to the next major tab.
    Assumed that focus is on a major tab."
    | majorPages currentMajor |

    majorPages := self majorPages.
    currentMajor := self focusPage.
    majorPages last == currentMajor
        ifTrue: [ ^self ].
    self visibleMajorTabs last == currentMajor
        ifTrue: [ self nextMajorTab ].
    self redrawFocus: ( majorPages after: currentMajor )!  
statusText
    " Answer the status line text for the receiver."

    ^statusText!  
minorTabRange
        " Private - Answer the maximum number of minor tabs
        which can be displayed "
    | r |
    r := self notebookClientArea width // (self minorTabExtent x + self tabSpace x).
    r < self minorPages size ifTrue:[
        r := self notebookClientArea width - (((self childAtId: 202) width + self tabSpace x) * 1) // (self minorTabExtent x + self tabSpace x)].
    ^r!  
isAGroupLeader
        "Private - Answer true if the receiver is a group leader."
    ^super hasStyle: WsGroup! 
setStatusText: aStatusText
    "Set the status text of the receiver to <aStatusText>
        and update the receiver when it is valid."
    | text |
    text := aStatusText notNil
        ifTrue: [ aStatusText ]
        ifFalse: [ '' ].
    self
        statusText: text;
        updateStatus!
scrollLeftPageBitmapDisabled
        " Private - Answer the bitmap for the left page scroll button
        when it's disabled"
    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #leftPageDisabled ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #leftPageDisabled put: ( Bitmap fromModule: self class resourcesFileName id: 19 )].
    ^(self bitmaps at: #leftPageDisabled)! 
tab: aStringOrBitmap
    "Private -
        Set the tab text or bitmap for the receiver."

    tab notNil
        ifTrue: [
            tab == aStringOrBitmap
                ifTrue: [ ^self ].
            tab isBitmap
                ifTrue: [ tab release ]].

    tab := aStringOrBitmap!  
updateAttributes
        " Private - The receiver's attributes have changed. Reflect those changes "

    self isHandleOk ifFalse:[^self].
    self noRedraw: true.
    self children do:[:each | each resize: rectangle ].
    self updateRectangle.
    self noRedraw: false.
    self realInvalidateRect: nil! 
close
    "Private - Release the tab bitmap"

    self tab isBitmap
        ifTrue: [ self tab archiveAndRelease ].!  
eraseFocus
    "Private - Erase the focus feedback."
    | rect color page |

    self partIsEditing
        ifTrue: [ ^self ].

    ( page := self focusPage ) isNil
        ifTrue: [
            ( page := self selectedPage ) isNil
                ifTrue: [ ^self ] ].
    page hasMajorTab
        ifTrue: [
            ( self majorTabVisible: page )
                ifFalse: [ ^self ].
            color := self colorMajorTabBackground ]
        ifFalse: [
            page hasMinorTab
                ifTrue: [
                    ( self minorTabVisible: page )
                        ifFalse: [ ^self ].
                    color := self colorMinorTabBackground ]
                ifFalse: [ "no tab"
                     ^self ]].

    rect := page tabRectangle.

    self doGraphics: [
        self pen
            foreColor: color;
            setLineWidth: 1;
            setLineType: LineTypeSolid;
            rectangle: ( rect insetBy: self focusSpace // 2 );
            setLineType: LineTypeDefault ].

    self displayedFocus: false.!
scrollRightPageBitmap
        " Private - Answer the right page bitmap for the right scroll
        page button"
    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #rightPage ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #rightPage put: ( Bitmap fromModule: self class resourcesFileName id: 13 )].
    ^(self bitmaps at: #rightPage)!
notebook: aNotebook
    "Private - Set the notebook that contains
        the receiver."

    notebook := aNotebook!  
scrollBottomTabIconDisabled
        " Private - Answer the icon for the scroll bottom tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollBottomTabIconDisabled ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollBottomTabIconDisabled put: ( Icon fromModule: self class resourcesFileName id: 5 )].
    ^(self bitmaps at: #scrollBottomTabIconDisabled)!   
close
        "Private - Close the pages."

    self pages do: [ :aPage | aPage close ].

    ^super close!  
syncControlEvent: anEvent
        "Private - Process anEvent produced
         by the host system. The default is to
         requeue the operation for deferred handling."

    self sendInputEvent: #asyncControlEvent:
        with: anEvent!
scrollBottomTabIcon
        " Private - Answer the icon for the scroll bottom tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollBottomTabIcon ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollBottomTabIcon put: ( Icon fromModule: self class resourcesFileName id: 1 )].
    ^(self bitmaps at: #scrollBottomTabIcon)!   
orderedPages: anOrderedCollection
        " Private - set the ordered list of pages. "

   orderedPages := anOrderedCollection.!   
majorTabExtent
        "Answer the extent of the major tabs."

    ^self propertyAt: #majorTabExt ifAbsent: [ 30 @ 30 ]!   
turnToPageNumber: anInteger
    "Turn to page number <anInteger>.  If <anInteger> is out of range,
        select the last page.
	Platform dependent "
    | pageNumber count |

    ( pageNumber := anInteger asInteger  ) > ( count := self pageCount )
        ifTrue: [ pageNumber := count ].
    self selectPage: ( self pages at: pageNumber )!
mnemonic: char typedIn: aPane
        "The receiver's mnemonic was typed in the receiver
        or the receiver's window.  Select the receiver
        This is platform dependent.  Since this method is
        queued on Windows, the receiver must be a window.
        On Os/2, this method is in NotebookPage"

    self containingNotebook selectPage: self mainPage!   
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
        ifTrue: [index := orderedChildren size].
    ^(child := orderedChildren at: index) hasFocus
        ifTrue: [child]
        ifFalse: [child previousTabStop]!
hasMajorTab
        "Answer true if the page has major tab."

    ^( style bitAnd: BkaMajor ) = BkaMajor!  
display
    self partsVwOnly.  " Only used on VW"

    graphicsTool
        backColor: self backColor;  "The color set from beginPaint
            is always a proximate, so reset to exact color."
        blank: ((0@0) extent: self extent)! 
containingNotebook
        " Private -
    Platform dependent"
        | parentWindow |

    ^(parentWindow := self superWindow superWindow ) isPARTSNotebook
        ifTrue: [parentWindow]
        ifFalse: [nil]!   
colorMajorTabText: aColor
        " Set the color text for major tabs "

    self propertyAt: #colorMajorTabText put: aColor!  
isStatusTextCenter
        "Private - Answer true if the receiver has the statustextcenter style
        else answer false"

    ^( self notebookStyle bitAnd: NbksCenteredStatusText ) =
        NbksCenteredStatusText!
noTabStop
        "Make the receiver not be a tabstop.  By default
        every subpane which can be a tabstop is a tabstop.
        Send this message if you want to make it not be a tabstop."
    super removeStyle: WsTabstop!   
makeNotebookBitmap
        " Private - Build the background bitmap"
    self backgroundBitmapBasic notNil
        ifTrue:[ self backgroundBitmap release].
    self backgroundBitmap: (
        Bitmap width: rectangle width height: rectangle height planes: 1 bitCount: 4).
    self drawWith: self backgroundBitmap pen.
    ^self backgroundBitmapBasic!  
canArrowInto
        "Private - Arrow keys cycle the focus inside the
        GroupPane.  Cannot cross the GroupPane boundary
        with the arrow keys."
    ^false!   
controlColor: aDeviceContext
        "Private - Set the background of the receiver."
    | brush backColor foreColor |
    ( foreColor := self mainWindow foreColor ) notNil ifTrue: [
        ( GDILibrary setTextColor: aDeviceContext with: foreColor ) = 16rFFFFFFFF
            ifTrue: [ ^self osError ] ].
    ( backColor := self mainWindow backColor ) isNil ifTrue: [ ^nil ].
    ( brush := WinLogicalBrush style: BsSolid color: backColor hatch: nil )
        isNil ifTrue: [ ^nil ].
    ( GDILibrary setBkColor: aDeviceContext with: backColor ) = 16rFFFFFFFF
        ifTrue: [ ^self osError ].
    ( GDILibrary setBrushOrgEx: aDeviceContext x: 0 y: 0 oldOrigin: nil )
        ifFalse: [ ^self osError ].
    ^brush!
drawFocus
    "Private - Draw the focus feedback."
    | rect page color |

    self partIsEditing
        ifTrue: [ ^self ].

    ( page := self focusPage ) isNil
        ifTrue: [ ^self ].

    page hasMajorTab
        ifTrue: [
            ( self majorTabVisible: page )
                ifFalse: [ ^self ].
            color := self colorMajorTabBackground ]
        ifFalse: [
            page hasMinorTab
                ifTrue: [
                    ( self minorTabVisible: page )
                        ifFalse: [ ^self ].
                    color := self colorMinorTabBackground]
                ifFalse: [ "no tab"
                    ^self ]].

    rect := page tabRectangle.

    self doGraphics: [
        self pen
            foreColor: self colorBorder;
            backColor: color;
            partsDrawFrame: ( rect insetBy: self focusSpace // 2 )].!   
isScrollMinorTabButtonsVisible
        "Private - Answers true if the scroll major tab buttons are visible"

    ^self minorTabRange < self minorPages size!   
notebook
    "Private - Answer the notebook that contains
        the receiver."

    ^notebook!  
demandLoad
        "Answer true if demand load is requested else false."

    ^self propertyAt: #demandLoad ifAbsent: [^false]!
scrollTopTabIconDisabled
        " Private - Answer the icon for the scroll top tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollTopTabIconDisabled ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollTopTabIconDisabled put: ( Icon fromModule: self class resourcesFileName id: 8 )].
    ^(self bitmaps at: #scrollTopTabIconDisabled)!  
isOkToChange
        "Private - answer whether it is OK to change the selection."

    ^( self hasActionForEvent: #aboutToChange )
        ifTrue: [ super isOkToChange ]
        ifFalse: [ self commitSelection ]! 
tabStyle
    "Private - Answer the tab style of the receiver. "
    ^self hasMajorTab
        ifTrue: [ #major ]
        ifFalse: [ self hasMinorTab
            ifTrue: [ #minor ]
            ifFalse: [ #noTab ] ]!  
updateRectangle
        "Private - Update variables depending on the actual size of the StatusPane."

    super updateRectangle.
    self backgroundBitmapBasic notNil
        ifTrue: [ self backgroundBitmap release ].
    self backgroundBitmap: nil.
    self majorTabScrollPos: 1.
    self minorTabScrollPos: 1.
    self updateScrollTabState!   
fileInActivate: anObjectFiler
        " Activate instance which has just been loaded.
    The receiver's page pane needs to reevaluate its
    framing block on this resolution."

    self pagePaneGroup framingBlock: self clientFramingBlock.!
deleteAllPages
        "Delete all pages from the receiver.
    Platform dependent "

"    self pages: nil."
    self selectedPage: nil.
    self pagePaneGroup children do:[:each | each hideWindow].

    self removeAllFromPages.

    self
        updateScrollPageState;
        updateScrollTabState!   
minorTabScrollPos: anInteger
        " Private - Set the index of the first visible major tab
        in the majorPages collection "

    minorTabScrollPos := anInteger! 
partIsEditing
        "Answer whether the receiver is being
        edited in a PARTS Workbench. "

    ^parent partIsEditing!
deferUntilValid
    "Answer whether message should be queued
        until the receiver's handle is valid."

    ^false!  
majorPageBefore: anotherPage
    | nextPage |

    nextPage := self pages before: anotherPage ifNone:[].
    [nextPage notNil and:[nextPage hasMajorTab not]] whileTrue:[
        nextPage := self pages before: nextPage ifNone:[]].
    ^nextPage!
colorPageBackground
        " Answer the background color for page background "
    | color |
    color := self propertyAt: #colorPageBackground.
    color isNil ifTrue:[ color := self backColor ].
    ^color!
style
        "Private - Answer the style for the receiver."
    ^style!
altKeyInput: altCharacter from: aPane
        "An alt-character was typed in <aPane> of
        the receiver.  Search for a child mnemonic.
        Answer whether the mnemonic is handled."
    | superWindow mnemonicHandler |

    orderedPages do: [ :child |
        ( mnemonicHandler := child getMnemonicHandler: altCharacter ) notNil
            ifTrue: [
                mnemonicHandler
                    sendInputEvent: #mnemonic:typedIn:
                    withArgs: (Array with: altCharacter with: aPane).
            ^true ] ].

    ^( superWindow := self superWindow ) isWindow
        ifTrue: [ superWindow altKeyInput: altCharacter from: aPane ]
        ifFalse: [ false ]! 
pageButtonExtent
        "Answer the size of the page cycle buttons to aPoint
         where x is the width and y is the height."

    pageButtonExtent isNil
        ifTrue: [ pageButtonExtent := super pageButtonExtent ].  "Has a default value."
    ^pageButtonExtent!
updateDisplay
    "Private-
        Update all the page's visual items.  The
        receiver must have already been inserted
        into the notebook."

    self
        updateTab.

    notebook demandLoad
        ifFalse: [
            self
                updateStatus;
                updateWindow ].!   
majorTabRange
        " Private - Answer the maximum number of major tabs
        which can be displayed "
    | r |
    r := self notebookClientArea height // (self majorTabExtent y + self tabSpace y).
    r < self majorPages size ifTrue:[
        r := self notebookClientArea height - (((self childAtId: 202) height + self tabSpace y) * 1) // (self majorTabExtent y + self tabSpace y)].
    ^r!   
scrollLeftTabIcon
        " Private - Answer the icon for the scroll right tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollLeftTabIcon ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollLeftTabIcon put: ( Icon fromModule: self class resourcesFileName id: 2 )].
    ^(self bitmaps at: #scrollLeftTabIcon)!
setTab: aStringOrBitmap page: aPage
        "Set the tab for aPage"
    aPage tab: aStringOrBitmap.
    self doGraphics:[
        aPage isMajor ifTrue:[self displayMajorTabsWith: graphicsTool].
        aPage isMinor ifTrue:[self displayMinorTabsWith: graphicsTool]].

    self drawFocus!
drawScrollLeftTab: aPane
        " Private - Draw the scroll left tab button "
    | icon |
    icon := self scrollLeftTabIcon.
    aPane disabled ifTrue:[
        icon := self scrollLeftTabIconDisabled].
    icon displayAt: 1 @ 2 with: aPane graphicsTool!
pageButtonExtent
        "Answer the extent of the page buttons."

    ^self propertyAt: #pageButtonExt ifAbsent: [ 20 @ 20 ]! 
firstPage
        "Set the current page to the first page."

    self selectPage: self queryFirstPage! 
minor
        "Make the receiver have a minor tab."

    self removeStyle: BkaMajor.
    self addStyle: BkaMinor.!
majorTabVisible: aMajorPage
    "Private - Answer whether <aMajorPage> is visible"

    self isScrollMajorTabButtonsVisible
        ifFalse: [ ^true ].

    ^self visibleMajorTabs includes: aMajorPage!   
updateTab: aTab
    | notebook precedingPage selectedPage |
    selectedPage := self selectedPage.
    (notebook := self containingNotebook) isNil
        ifTrue: [^self].
    precedingPage := notebook queryPageBefore: selectedPage.
    notebook deletePage: selectedPage.
    selectedPage tab: aTab.
    notebook
        insertPage: selectedPage after: precedingPage;
        setTab: selectedPage tab page: selectedPage;
        selection: selectedPage.! 
hasFocus

    ^super hasFocus or: [
        ( self children detect: [ :aChild |
            aChild hasFocus ] ifNone: [ nil ]) notNil ]!  
minorTabScrollPos
        " Private - Set the index of the first visible minor tab
        in the visibleMinorTab collection "

    ^minorTabScrollPos!   
findUnderCursor
        " Answer back the page under the cursor "
    | page|
    page := self findUnderCursor: self cursorWindowPosition.
    ^page isNil
        ifTrue: [ self selection ]
        ifFalse: [ page ]!
previousMajorTab
    " Private - The user has clicked the previous major tab scroll button
        Insure the receiver has the focus instead of its scroll
        buttons."

    self partIsEditing not
        ifTrue: [ self setFocus ].
    self majorTabScrollPos: (( self majorTabScrollPos - 1 ) max: 1 ).
    self displayForScrolledTab.!
selected: aNotebookPage
    "Private -
        Perform any actions required when the owner page
        <aNotebookPage> has been selected."

    self triggerEvent: #selected: with: aNotebookPage!  
commitSelection
        "Private - Answer true if the receiver should
         commit to selection change."

    ^self mainWindow textModified not!   
selected
    "Private -
        The receiver has been selected.  Perform appropriate actions."

    self triggerEvent: #selected.
    self window isPARTSNotebookPagePane
        ifTrue: [
            self window selected: self ].! 
colorChange
        "Private - Window's color has changed."

    self makeNotebookBitmap.
    self subPaneColorChange!
isTabTextRight
        "Private - Answer true if the receiver has the tabtextright style
        else answer false"

    ^( self notebookStyle bitAnd: NbksTabRightAlignedText ) =
        NbksTabRightAlignedText!  
wmPaint: wordInteger with: longInteger
        "Private - Process the paint message."
    | displayContext paintStructure oldDC result |
    self graphicsTool isGraphicsTool ifFalse: [ ^nil ].
        "must copy to nonST memory because BeginPaint generates WM_ERASEBKGRND"
    paintStructure := ExternalAddress allocateMemory: WinPaintStructure sizeInBytes.
    result := UserLibrary
        beginPaint: handle
        paintStructure: paintStructure asParameter.
    displayContext := DeviceContext fromInteger: result.
    oldDC := graphicsTool privateHandle.
    self graphicsTool setHandle: displayContext.
    self display.
    self graphicsTool handle: oldDC.

    ( UserLibrary
        endPaint: handle
        paintStructure: paintStructure asParameter )
            ifFalse: [ ^self osError ].
    paintStructure free.
    ^1!
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "

   ^super partMirrorCopyPropertiesToExclude,
        #( #backgroundBitmap #displayedFocus #focusPage )!
numberOfBackPages: anInteger
        " Set the number of backpages to represent the
        3-D effect of the notebook"

    self propertyAt: #numberOfPages put: anInteger!  
selectPage: aPage
    "Programatically select a page.  Will verify that the
        page can be selected and will trigger the events."
    | validPage |

    ( validPage := self pageToSelect: aPage ) notNil
        ifTrue: [
            self selection: validPage.
            self pageSelected: validPage ].!  
deferUntilValid
    "Private -
        Answer whether message should be queued
        until the receiver's handle is valid.
	Platform dependent "

    ^false! 
removeStyle: styleInteger
        "Private - Turn off the style instance variable bits which
        are on in styleInteger."
    ^style := style isNil ifTrue: [0]
        ifFalse: [style bitAnd: (styleInteger bitXor: 16rFFFFFFFF)].! 
notebookStyle
        " Private - Answer the notebook style "
    ^self propertyAt: #notebookStyle
        ifAbsent: [ NbksTabCenteredText | NbksLeftAlignedStatusText ]!  
colorPageBackground: aColor
        " Set the color text for minor tabs "

    self propertyAt: #colorPageBackground put: aColor!  
drawScrollLeftPage: aPane
        " Private - draw the scroll left page button "
    | bmp |
    bmp := self scrollLeftPageBitmap.
    aPane disabled ifTrue:[
        bmp := self scrollLeftPageBitmapDisabled].
    aPane graphicsTool
        copyBitmap: bmp
        from:  bmp boundingBox
        to: aPane boundingBox.!  
isNotebookPagePane
    "Answer whether the receiver is an instance of NotebookPagePane"
    ^true!  
statusLineBoundingRectangle
        " Answer the bounding rectangle of the status line "
    ^((rectangle insetBy: 2 @ 2 ) leftBottom
        leftAndUp: ( 0 @ (marginExtent y + self font height)))
        extentFromLeftTop:
            (rectangle extent x - ((2 @ 1) * pageButtonExtent) x - marginExtent x - 3) @
                 self font height.!
isATabStop
        "Private - Answer true if the receiver is a tabstop"
    ^super hasStyle: WsTabstop! 
subclassWndProc
    "Do nothing for notebook."!  
subPaneColorChange
        "Private - Window's color has changed."

    graphicsTool notNil ifTrue: [
        graphicsTool foreColor: self foreColor.
        graphicsTool backColor: self backColor ].
    children size ~= 0 ifTrue: [
        children do: [ :each |
            each colorChange ] ].

    self invalidateRect: nil!
queryPageBefore: aPage
        "Answer the page before <aPage>."

    ^self queryPage: BkaPrev beside: aPage!  
selectedPage
    "Answer the receiver's value."

    ^value!   
topMinorPage
        "Private - Answers the receiver's top minor page."
    | topMinorPage |

    topMinorPage := self selection.
    topMinorPage isNil ifTrue: [ ^nil ].
    topMinorPage hasMinorTab ifFalse:[
        topMinorPage := self minorPageBefore: topMinorPage].

    ^topMinorPage!   
colorBorder: aColor
        " Set the color border "

    self propertyAt: #colorBorder put: aColor!   
clientFramingBlock
        " Private - Answer the framing block for the notebook client area pane "

    ^[ :box |
        (box insetBy: 2 @ 2 ) leftTop
            extentFromLeftTop:
                (box insetBy: 2 @ 2 ) extent
                - marginExtent
                - (0 @ (self font height max: pageButtonExtent y) ).
            ]!  
queryPageAfter: aPage
        "Answer the page following <aPage>."

    aPage isNil
        ifTrue: [ ^self queryFirstPage ].
    ^self queryPage: BkaNext beside: aPage!
focusRight
    "Private - Move the focus right to the next minor tab.
    Assumed that focus is on a minor tab."
    | minorPages currentMinor |

    minorPages := self minorPages.
    currentMinor := self focusPage.
    minorPages last == currentMinor
        ifTrue: [ ^self ].
    self visibleMinorTabs last == currentMinor
        ifTrue: [ self nextMinorTab ].
    self redrawFocus: ( minorPages after: currentMinor )!
majorTabExtent: aPoint
        "Set the size of the major tabs to aPoint
         where x is the width and y is the height."

    majorTabExtent = aPoint
        ifTrue: [ ^self ].

    majorTabExtent := aPoint.
    self setDims: BkaMajor extent: aPoint.
    self resizePagePaneGroup.!
nextPageId
    "Private - Answer the next available page id"
    | nextId |
    nextId := ( self propertyAt: #nextPageId ) + 1.
    self propertyAt: #nextPageId put: nextId.
    ^nextId!   
losingFocus
    "Private - Clear the focus page so it will be reevaluated
    when the focus returns."

    super losingFocus.
    self eraseFocus.
    self focusPage: nil.!   
setTab: aTab
    "Set the tab of the receiver to <aTab> and update
        the receiver when it is valid."

    self
        tab: aTab;
        updateTab!  
backgroundBitmap
        " Private - Answer the notebook bitmap"
    | b |
    ^ ( b := self backgroundBitmapBasic ) isNil
        ifTrue: [ self makeNotebookBitmap ]
        ifFalse: [ b ]!   
selectedPage: aPage
    "Set the receiver's value."

    value := aPage!   
displayedFocus
    "Private - Answer whether the focus has already
    been drawn by display"

     ^( self propertyAt: #displayedFocus ) == true!
turnToPage: pageKey
        "Turn to the page identified by <pageKey>.
	Platform dependent "
    | pageToSelect |

    pageKey isNil
        ifTrue: [ ^self ].
    pageToSelect := self pages
        detect: [ :aPage | aPage key = pageKey asString]
        ifNone: [ ^self ].
    self selectPage: pageToSelect!   
nextMajorTab
    " Private - The user has clicked the next major tab scroll button.
        Insure the receiver has the focus instead of its scroll
        buttons."

    self partIsEditing not
        ifTrue: [ self setFocus ].
    self majorTabScrollPos: self majorTabScrollPos + 1.
    self displayForScrolledTab.! 
button2Up: aPoint
        "Private - Finish right button scroll or do popup menu."

    "Code from SubPane>>button2Up:"
    "super button2Up: aPoint."  "Handle drag-drop differently"
    self clearMouseCapture.
    self stopTimer: self class rightButtonScrollTimerId.
    Margin = 0 ifTrue: [
        self triggerEvent: #rightClicked
            ifNotHandled: [ self doPopupMenuAt: aPoint ] ]!
scrollLeftTabIconDisabled
        " Private - Answer the icon for the scroll right tab button"

    self bitmaps isNil
        ifTrue:[ self defaultBitmaps ].
    (self bitmaps at: #scrollLeftTabIconDisabled ifAbsent:[]) isNil ifTrue: [
        self bitmaps at: #scrollLeftTabIconDisabled put: ( Icon fromModule: self class resourcesFileName id: 6 )].
    ^(self bitmaps at: #scrollLeftTabIconDisabled)!
subPaneValidate
        "Private - The host window for the receiver was
         just created or recreated.  Note: Assume there
         aren't any ApplicationWindows in the receiver,
         or it will need validateShow instead."

    self performWhenValids.
    children do: [ :each |
        each validate ]!  
notebookStyle: anInteger
        " Private - Set the notebook slyle "
    self propertyAt: #notebookStyle put: anInteger.
    self isHandleOk
        ifTrue: [ self invalidateRect: nil ].!  
resizePagePaneGroup
    "Private - Resize the notebook client area pane"

    pagePaneGroup notNil
        ifTrue: [ "Reevaluate the framer of the client area pane and resize it."
            pagePaneGroup framingBlock: self clientFramingBlock.
            pagePaneGroup isHandleOk
                ifTrue: [
                    pagePaneGroup resize: ( 0@0 extent: self rectangle extent )]].!   
selection
        "Answer the selected page."
    | selectedPage |

    ( selectedPage := self queryPage:  BkaTop beside: nil ) isNil
        ifTrue: [ nil ].

    ^selectedPage! 
marginExtent: aPoint
        "Private - Set the margin of the notebook
    where x is the width and y is the height.  The
    tabs and backpages are displayed in this
    margin."

    marginExtent := aPoint!
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    self partsVosOnly.  " Only used on VOS"!