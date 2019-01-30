3.1.0.106
   
insertPageLast: aNotebookPage
        "Private - insert aNotebookPage into the receiver as the last page."
    ( self isHandleOk not and: [ self deferUntilValid ])
        ifTrue: [
            ^self whenValid: #insertPageLast:
                withArguments: ( Array with: aNotebookPage )].
    self insertPage: aNotebookPage afterIndexOrPage: nil.
    aNotebookPage updateDisplay!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #page #turnToPage: #pageNumber #turnToPageNumber:
            #firstPage #lastPage #nextPage #previousPage
            #abortChange )
        separators: #( 3 7 11 )
        defaultItem: #turnToPage:!   
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
   " ^SysFont width * 30 @
        (SysFont height *
            ( self partsIfOS2Do: [ 14 ] partsIfWindowsDo: [ 7 ]))"
    ^ self partFontOrSysFont charSize * (32 @ 12)!  
partSetContents: anArray
        " Set the PARTS contents of the receiver.
        Set the major, minor tabs, page buttons extent."
    | major minor button |
    major := anArray at: 1.
    minor := anArray at: 2.
    button := anArray at: 3.
    major notNil ifTrue: [self majorTabExtent: major ].
    minor notNil ifTrue: [self minorTabExtent: minor].
    button notNil ifTrue: [self pageButtonExtent: button]!
pageKey: aString
    "Set by the part property dialog."

    self mainPage key: aString.!  
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
   " ^SysFont width * 12 @ (SysFont height * 5)"
    ^ self partFontOrSysFont charSize * (15 @ 6) + (0 @ 6)!  
PARTSNotebookPart removePartRuntimeLibrary!   
addInterestInChild: aPane
        " Private - do nothing "!  
commitSelection
	"Private - Answer true if the receiver should
         commit to selection change.  PARTSNotebookPageParts
	    retain values between pages changes, don't prompt to
	    discard changes."

	^true!   
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."
    | aRectangle |

    aRectangle := self rectangle.
    ^( aRectangle leftBottom
        extentFromLeftTop:
            ( aRectangle extent x @
                (( self font notNil ifTrue: [ self font ] ifFalse: [ SysFont ]) height * 3 // 2 )))
            mapFromWindow: self
            to: self partEditor workbenchPane.!  
partUndoDirectEdit: originalValue
        "Undo a direct edit operation on the receiver."
    self setStatusText: originalValue.!   
partOpen
        " Display the receiver when it is being edited
        in a PARTS Workbench.  Validate to make
        combo box appear when duplicate notebook
        page [2/22/93 MT] "
    self validate.! 
setTabTextWithMnemonics: aString
        "Set the receiver's tab text to be aString
        replacing any occurances of '\u' with
        the character that indicates following
        character is the mnemonic character."
    self setTab: aString replaceEscapeCharacters! 
backupNotebookFrom: aSourceNotebook with: aMirrorCopyDictionary
    "Backup <aSourceNotebook> into the receiver's whenValid
    property so that it can be recreated during a validate.  This
    used for both workbench delete (no mirror copy dictionary needed)
    and    mirror copy."
    | nullHandle saveHandle page |

    self partsVosOnly.  " Only used on VOS"

    self propertyAt: #whenValid put: nil.  "Dependency on base prop."
    nullHandle := WindowHandle nullValue.
    page := aSourceNotebook queryFirstPage.
    saveHandle := handle.
    [ page notNil ] whileTrue: [
        handle := nullHandle.  "trick the appendPage into using whenValid"
        self appendPage:
            ( aMirrorCopyDictionary notNil
                ifTrue: [ page partMirrorCopy: aMirrorCopyDictionary ]
                ifFalse: [ page ]).
        handle := saveHandle.
        page := aSourceNotebook queryPageAfter: page ].! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #selected
            #rightClicked
            )
        separators: #( 1 )
        defaultItem: #rightClicked!   
resizeChildren
        "Private - Resize all children."
    self partsIfOS2Do: [ ^super resizeChildren ].
    self partsVwOnly.  " Only used on VW"

    children size = 0 ifTrue: [ ^self ].

    "During run-time, nested parts are built during the initial resize."
    self childrenInBuildOrder do: [ :subpane | subpane resize: rectangle ]!   
partMirrorCopyChildren: aDictionary to: copy
        " Private - do nothing for notebook part.
        Children of copy are created by initialize.
        The real child is notebookPage. "
	self partsIfOS2Do: [^super partMirrorCopyChildren: aDictionary to: copy]!   
updateHorizontalSlider
        "Private - Update the slider box in the horizontal scrollBar."!   
orderChildrenAndDisplay: aCollection
    "Private - Set the orderedChildren and update
    the display to reflect the new order"

    self orderedChildren: aCollection.
    aCollection reversed do: [ :aSibling |
        aSibling partBringSubPaneToTop ].

    self invalidateRect: nil.! 
installPartRuntimeLibrary
        " Private - install the notebook parts runtime library.
        Load the workbench support library if appropriate. "

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Notebook Parts'.!  
defaultFramer
        " Private - Answer the framer for the notebook page part "
    ^PARTSFramer new
        useAllInset;
        left: 0 bottom: 0 right: 0 top: 0! 
addNotebookPage: aNotebookPage
    "Private -
        Add <aNotebookPage> to the list of pages which the
        receiver is used to display."

        "PARTSNotebookPagePart only has one notebook page.
    During workbench duplicate, need to clear old notebook page
    from copy."
    notebookPages notEmpty
       ifTrue: [ notebookPages := OrderedCollection new ].

    super addNotebookPage: aNotebookPage!
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
initializePageAttributes
        "Private - initialize the receiver's page attributes."

    PARTSNotebookPageAttributes new window: self

"the #window: messages will indirectly cause the above
created PARTSNotebookPageAttributes to be added to
the receiver."!   
notebookPages: anOrderedCollection
    "Private - Set the notebook pages."

	notebookPages :=
		anOrderedCollection isNil
			ifTrue: [ OrderedCollection new ]
			ifFalse: [ anOrderedCollection ].!
partIsDragable
        "Answer true if dragable and resizable."
    ^false! 
initialize
        "Private - intialize the receiver."
    super initialize.
    self framingBlock: self defaultFramer!
partContainingWindow
        "Answer the non-frame visible window containing the receiver."

    ^self containingNotebook! 
constructEventsTriggered
        " Private - answer the set of events that instances of the
        receiver can trigger. "
    ^super constructEventsTriggered
        addAll: #(
            #selected
            );
         yourself! 
partFrameRectangleFrom: aRectangle
        " Private - answer the framing rectangle
       to use for the receiver part, given aRectangle. "

    ^self defaultFramer!
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a notebook "!  
partDirectEditValue
        "Answer the direct edit value of the receiver."

    ^self mainPage statusText!
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.

    copy notebookPages: ( notebookPages partMirrorCopy: aMirrorCopyDictionary).
    ^copy!
removeSubpane: aWindow
        "Private - Remove aWindow from the receiver."
    | currentPage pageToDelete |

    aWindow isPARTSNotebookPagePane
        ifFalse: [^super removeSubpane: aWindow].

    "Look for a page that is the current selection."
    currentPage := self selection.
    pageToDelete :=
        ( aWindow notebookPages detect: [ :aPage |
            aPage == currentPage ]
            ifNone: [ nil ]).
    pageToDelete isNil
        ifTrue: [ pageToDelete := aWindow mainPage].
    self deletePage: pageToDelete.

    self
        partsIfOS2Do: [super removeSubpane: aWindow]
        partsIfWindowsDo: [aWindow superWindow removeSubpane: aWindow].

    "1) Don't remove the page so that 'undo delete' will work.  A notebook part
    should always have notebook page parts.
    2) Notebook page parts should always have a one-to-one correspondence
    between page and its window, so that there will only be one notebook
    page for each window.
    -- destroy the window only if no other pages are mapped onto it --
    aWindow notebookPages remove: pageToDelete.
    aWindow notebookPages size = 0
        ifTrue: [
            self
                partsIfOS2Do: [super removeSubpane: aWindow]
                partsIfWindowsDo: [aWindow superWindow removeSubpane: aWindow]]."!
removePartRuntimeLibrary
        " Private - remove the notebook parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!  
addPageWindow: pageWindow
        "Private - Insert a new page with pageWindow as the
          new page window. Answer the pageWindow wrapper."
    | page |

    pageWindow isPARTSNotebookPagePane
        ifFalse: [ ^self ].
    self addSubpane: pageWindow.
    self isHandleOk ifTrue: [
        self partsIfOS2Do: [
                pageWindow
                    adjustFraming: ( 0 @ 0 extent: self calcPageRect extent );
                    buildWindow: self]
            partsIfWindowsDo: [
                pageWindow
                    initSize: (0 @ 0 extent: self calcPageRect extent);
                    open;
                    buildWindow: self;
                    resize: (0 @ 0 extent: self calcPageRect extent) ] ].

    page :=
        (( pageWindow notebookPages notEmpty )
            ifTrue: [ "Undo deleting this page.  Use existing info."
                pageWindow notebookPages first ]
            ifFalse: [
                PARTSNotebookPageAttributes new
                    window: pageWindow;
                    yourself ]).
    self selection isNil
        ifTrue: [
            "selection isNil when constructing a notebook from a .CLS file,
            and we want to preserve the order."
            self insertPageLast: page ]
        ifFalse: [ self insertPage: page after: self selection ].
    self selectPage: page!  
containingNotebook
        "Private - Answer the notebook that contains the receiver.
        Note: The notebook pages are generated at validate time,
    so using the notebook pages to find the containing notebook
    won't always work.
        If it is nil, then trying to add the receiver to the workbench
    without the notebook.  Can't do this, but give a dummy notebook
    so that infinite walkbacks don't occur."
    | notebook |

    notebook := super containingNotebook.
    ^notebook isNil
        ifTrue: [ PARTSNotebook new ]
        ifFalse: [ notebook ]!   
defaultStyle
        "Private - Answer the default style flags for a control."
    ^DefaultStyle isNil
        ifTrue: [super defaultStyle]
        ifFalse: [DefaultStyle]!  
removeSubpane: aWindow
        "Remove aWindow from tabing info."

    self orderedChildren remove: aWindow ifAbsent: [].
    super removeSubpane: aWindow.!  
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."

    "Can't select if not in a notebook (User opened the part in the catalog)"
    ^super containingNotebook notNil!   
partContents
    ^Array
        with: self majorTabExtent deepCopy
        with: self minorTabExtent deepCopy
        with: self pageButtonExtent deepCopy!   
setStatusText: aString
	"Set by the part property dialog. Have the notebook set
		actual page's property."
    | str |

    aString isString
        ifTrue: [str := aString]
        ifFalse: [
            aString isNil
                ifTrue: [str := '']
                ifFalse: [str := aString printString]].
    self mainPage setStatusText:str.!   
partMessages
        " Answer the PARTS message interface of the receiver. "

    ^PARTSInterfaceList emptyList!   
initialize
        " Private - class initialization. "

    self
        initializeEventsTriggered;
        initializePropertyOptions.!  
clientFramingBlock
        " Private - Answer the framing block for the notebook client area pane "

    | max framer left bottom right top |
    self partsVwOnly.  " Only used on VW"

    max := self font height max: self pageButtonExtent y.
    framer := PARTSFramer new useAllInset; yourself.

    left := 2.
    top := 2.
    bottom := max + self marginExtent y + 2.
    right := self marginExtent x + 2.

    left := framer pixelToScaleUnitHorizontal: left.
    bottom := framer pixelToScaleUnitVertical: bottom.
    right := framer pixelToScaleUnitHorizontal: right.
    top := framer pixelToScaleUnitVertical: top.

    framer left: left bottom: bottom right: right top: top.
    ^framer!   
partSelectIn: anEditor
    " The receiver has been selected in a PARTS workbench.
    If the receiver is not the current editor selection, bring the
    page to the top of the notebook and select it."

    self containingNotebook selectedPage window ~= self
        ifTrue: [ self containingNotebook selectPage: self mainPage ].
    ^anEditor workbenchPane lafSelectDefault: self!   
selected: aNotebookPage
    "Perform any actions required when the owner page
        <aNotebookPage> has been selected."
    | partEditor selected |

    super selected: aNotebookPage.
    self triggerEvent: #selected.

    "Make the receiver the current editor selection if its sibling
    is the current selection.  (Not true during undo delete notebook)"
    ( self partIsEditing and: [
        self containingNotebook isVisible ])
        ifTrue: [
            partEditor := self partEditor.
            (( selected := partEditor selectedComponents ) notEmpty and: [
                selected first isPARTSNotebookPagePane ])
            ifTrue: [ partEditor selectAndBringToTop: self update: false ]].!   
partSetDirectEditValue: text
        " Set the direct-edit property value of the receiver
        to text and update the receiver appropriately. "

	self mainPage setStatusText: text.!  
partDirectEditInitialValue
        "Answer the initial value to be used to direct-edit
        the receiver in a PARTS Workbench. "

    ^self partDirectEditValue!   
initializePropertyOptions
        " Private - class initialization. "

    " properties supported on all platforms "

    TabAlignmentLabels := Array
        with: (Array with: 'Left' with: NbksTabLeftAlignedText)
        with: (Array with: 'Center      ' with: NbksTabCenteredText)
        with: (Array with: 'Right' with: NbksTabRightAlignedText).
   TabAlignmentValues := Array
        with: NbksTabLeftAlignedText
        with: NbksTabCenteredText
        with: NbksTabRightAlignedText.

    StatusAlignmentLabels := Array
        with: (Array with: 'Left' with: NbksLeftAlignedStatusText)
        with: (Array with: 'Center         ' with: NbksCenteredStatusText)
        with: (Array with: 'Right' with: NbksRightAlignedStatusText).
   StatusAlignmentValues := Array
        with: NbksLeftAlignedStatusText
        with: NbksCenteredStatusText
        with: NbksRightAlignedStatusText.

    " platform-dependent properties "
    self partsIfWindowsDo: [
        DefaultStyle := nil.
        BackPagesPositionLabels := BackPagesPositionValues := nil.
        MajorTabPositionLabels := MajorTabPositionValues := nil.
        BinderStyleLabels := BinderStyleValues := nil.
        TabShapeLabels := TabShapeValues := nil.
        ].
    self partsIfOS2Do: [
        DefaultStyle := WsInitiallyVisible |
                    "WsClipChildren"
            WsClipSiblings   |
                    NbksBackPagesBottomRight |
            NbksMajorTabRight |
                    NbksSquareTabs |
            NbksTabCenteredText |
                    NbksLeftAlignedStatusText.

            " generalized layout only supported by CUA notebook "
            BackPagesPositionLabels := Array
                with: (Array with: 'Bottom right' with: NbksBackPagesBottomRight)
                with: (Array with: 'Bottom left' with: NbksBackPagesBottomLeft)
                with: (Array with: 'Top right' with: NbksBackPagesTopRight)
                with: (Array with: 'Top left' with: NbksBackPagesTopLeft).
            BackPagesPositionValues := Array
                with: NbksBackPagesBottomRight
                with: NbksBackPagesBottomLeft
                with: NbksBackPagesTopRight
                with: NbksBackPagesTopLeft.
            MajorTabPositionLabels := Array
                with: (Array with: 'Right' with: NbksMajorTabRight)
                with: (Array with: 'Left' with: NbksMajorTabLeft)
                with: (Array with: 'Top' with: NbksMajorTabTop)
                with: (Array with: 'Bottom' with: NbksMajorTabBottom).
            MajorTabPositionValues := Array
                with: NbksMajorTabRight
                with: NbksMajorTabLeft
                with: NbksMajorTabTop
                with: NbksMajorTabBottom.
        " binder styles and tab shapes "
            BinderStyleLabels := Array
                with: (Array with: 'Solid ' with: NbksSolidBound)
                with: (Array with: 'Spiral ' with: NbksSpiralBound).
           BinderStyleValues := Array
                with: NbksSolidBound
                with: NbksSpiralBound.
            TabShapeLabels := Array
              with: (Array with: 'Square' with: NbksSquareTabs)
               with: (Array with: 'Rounded' with: NbksRoundedTabs)
               with: (Array with: 'Polygon' with: NbksPolygonalTabs).
        TabShapeValues := Array
            with: NbksSquareTabs
            with: NbksRoundedTabs
            with: NbksPolygonalTabs.
        ].!  
partIsSizable
        "Answer whether the receiver can be resized
        in a PARTS workbench. "
    ^false!  
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private - do nothing for a notebook page "! 
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "

   ^super partMirrorCopyPropertiesToExclude,
        #( #orderedChildren )!
partAboutToRemove
        "The receiver is about to be removed from the PARTSEditor.
          If there are more than one page referecing the receiver then
          don't remove the receiver just delete the page.
          Answer true if a page was deleted without removing
          the receiver else answer false."
    | notebook topPage |

    notebook := self containingNotebook.
    notebookPages size > 1
        ifTrue: [ "Page to delete should be the top page."
            topPage := notebook selectedPage.
            notebook deletePage:
                (( notebookPages includes: topPage )
                    ifTrue: [ topPage ]
                    ifFalse: [ self mainPage ]).
            ^true ].
    ^false! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToChange
            #changedPage: #changedPageNumber:
            #rightClicked
            #tabbed)
        separators: #( 3 )
        defaultItem: #changedPage:!
updateTab: aTab
    | notebook selectedPage precedingPage |

    selectedPage := self mainPage.
    selectedPage tab: aTab.
    (notebook := self containingNotebook) isNil
        ifTrue: [^self].
	self 
		partsIfOS2Do: [
    		precedingPage := notebook queryPageBefore: selectedPage.
    		notebook
				deletePage: selectedPage;
        		insertPage: selectedPage after: precedingPage.
			selectedPage setTab: aTab.
			notebook selectPage: selectedPage]
		partsIfWindowsDo: [
			notebook display]!
partCanHaveParent: aWindow
        " Answer whether aWindow can be a parent
        window of the receiver. "

    ^( aWindow isPARTSNotebook or: [ aWindow isPARTSNotebookPagePane ])!   
initializePropertyOptions
        " Private - class initialization. "

    TabStyleLabels := Array
        with: (Array with: 'Major' with: NbksMajorTab)
        with: (Array with: 'Minor' with: NbksMinorTab)
        with: (Array with: 'No tab' with: NbksNoTab).
    TabStyleValues := Array
        with: NbksMajorTab
        with: NbksMinorTab
        with: NbksNoTab.

    self
        partsIfOS2Do: [     "DEBUG - check ported implementation"
            ( (TabStyleLabels =  #( #('Major' 64 ) #('Minor' 128) #('No tab' 0) ) )
            and: [TabStyleValues =  #( 64 128 0 ) ] )
                ifFalse: [self error: 'bug'].
            ].!
partAddUnder: parentWindow wrapper: myWrapper
        "Insert the receiver into a PARTS application
        as a child of parentWindow.  Save myWrapper
        if necessary to respond correctly when
        the #partWrapper message is sent. "
    | realParentWindow |

    " from Window "
    self partWrapper: myWrapper.
    owner := myWrapper application.

    " replace SubPane processing with the following "
    realParentWindow := parentWindow.
    [ (realParentWindow isPARTSNotebook)
    or: [realParentWindow isKindOf: TopPane] ]
        whileFalse: [
            realParentWindow := realParentWindow superWindow].
    myWrapper parent
        removeComponent: myWrapper.  "11/3, fix wrapper"
    realParentWindow partWrapper
        addComponent: myWrapper.
    realParentWindow addPageWindow: self.!   
setTab: aTab
        "Private - set the receiver's tab."
    | selectedPage |
    selectedPage := self mainPage.
    selectedPage tab: aTab!  
demandLoad
	"Answer whehter the receiver is in demand load mode.
	Don't allow demand load on the workbench."

	^( self partIsEditing not and: [ super demandLoad ])!  
partUndoDirectEdit: originalValue
        "Undo a direct edit operation on the receiver."
    self partSetContents: originalValue.! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "
    | copy |

    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        minorTabExtent: (self minorTabExtent partMirrorCopy: aMirrorCopyDictionary);
        majorTabExtent: (self majorTabExtent partMirrorCopy: aMirrorCopyDictionary);
        pageButtonExtent: (self pageButtonExtent partMirrorCopy: aMirrorCopyDictionary).

    ^copy! 
pageWindows
        "Private - answer the receiver's page windows."
    | whenValids |
    ^self
        partsIfOS2Do: [
    "At the time this method is called the notebook page attributes
        are not in the orderedPages var so the only place we can extract
        the ordering of the PARTSNotebookPageParts is from the page
        attributes in the whenValid property."
            whenValids := self propertyAt: #whenValid.
            whenValids := whenValids select: [ :message |
                message selector == #appendPage: ].
            whenValids collect: [ :message | message arguments first window ]]
        partsIfWindowsDo: [
            self pages collect: [ :page | page window ]]!  
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."

   ^anObject partIsWindow
        and: [anObject isPARTSWindow not
        and: [anObject isPARTSMenuComponent not
        and: [anObject isPARTSMenuItem not
        and: [anObject isPARTSNotebook not]]]]!  
partCanHaveChild: anObject
        "Answer true if the receiver can contain anObject.
         This is used when dragging a part file icon into
         the workbench or changing a part's parent."
    ^self partIsEditing
        and: [anObject isPARTSNotebookPagePane]!
partAboutToAddTo: anApplication
        "The receiver is about to be added as a part to
        anApplication.  If the wrapper is not nil, about
        to add through a 'duplicate part' function.  The
        duplicate logic resizes the framer to the notebook
        part.  Need the framer to be relative to the client
        area pane."

    self partsIfWindowsDo: [
    self partsVwOnly.  " Only used on VW"
        self partWrapper notNil
            ifTrue: [
                self framingBlock: self defaultFramer.
                self partWrapper rectangle: framingBlock ]].

    ^super partAboutToAddTo: anApplication!