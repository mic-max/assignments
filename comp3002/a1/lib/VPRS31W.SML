3.1.0.106
   
defaultBackColor
        "Answer the default background color for windows of
         this class."
    ^( OperatingSystem isWindows95 or: [ self ctl3dEnabled ] )
        ifTrue: [ Color buttonFace ]
        ifFalse: [ super defaultBackColor ]!  
tabControl
	"Answer the TabControl contained in the receiver."

	^ tabControl
!   
initWindowSize
        "Private - Answer default initial window extent."
	^ 50 @ 25 * (SysFont charSize)!   
open: aParent
    "Open the dialog box modeless but float on top of the
    window <aParent>."

     CursorManager execute changeFor: [
        self addButtons.
        self openWindow ].

!
triggerApply
	"Private - Trigger apply event."

	| pages |
	pages := self tabControl pages.
	pages size > 0 ifTrue: [
		pages do: [ :page |
			page triggerEvent: #apply: with: page ] ].
	applyButton disable!   
isHelpButtonNeeded
	"Private - Answer true if help button is needed."

	^ self propertyAt: #helpButton ifAbsent: [ false ]!
cancel
	"Close the receiver window.
	This method is called after the Cancel button is pressed."


	self close!   
hasSmalltalkMenuBar
        "Answer whether the window should have the
        the default Smalltalk menu bar."
    ^false!
addTabControl
	"Private - Create the TabControl."

    | charSize font labelHeight gap |
    font := DialogTopPane platformDefaultFont.
    self font: font.
    charSize := font charSize.
    labelHeight := font height * 2.
	gap := charSize x @ charSize y.
    self
        addSubpane: ( 
			( tabControl := TabControl new )
				tabStop;
            		font: font;
            		multipleLines: true;
        			layoutFrame: ((LayoutFrame topLeftRatio: 0 @ 0 bottomRightRatio: 1 @ 1)
					topLeftInset: gap ;
					bottomInset: labelHeight + gap y + gap y;
					rightInset: gap x );
				when: #changed send: #pageChanged to: self;
				when: #inputOccurred send: #inputOccurred to: self;
				yourself )!  
buildWindow
        "Private - Create the host window for the receiver."
	( self propertyAt: #needOwnerWindow ) notNil 
		ifTrue: [
			parent := self getWindowToDisable: nil. "float on top of parent"
			super buildWindow.
			parent := nil ]
		ifFalse: [ super buildWindow ].
!  
initialize
    "Private - Initialize the receiver."

    super initialize.
    self addTabControl.
    self propertyAt: #needOwnerWindow put: true
!
needHelpButton: aBoolean
	"Request the help button to be present if <aBoolean> is true."

	self propertyAt: #helpButton put: aBoolean! 
addPage: aPage
	"Add <aPage> to the TabControl contained in the receiver."

	( aPage isKindOf: TabControlItem )
		ifFalse: [ ^ self error: 'The page must be kind of TabControlItem or TabControlPage' ].
	self tabControl addPage: aPage
! 
apply
	"Trigger the apply event and disable the apply button.
	This method is called after the Apply button is pressed."

	self triggerApply! 
pageChanged
	"Private - Page had been changed, change
	the window title if necessary."

	| currentPage |
	currentPage := self tabControl currentPage.
	currentPage titleForParent notNil 
		ifTrue: [ self label: currentPage titleForParent ]
		ifFalse: [ self label: self label ]
	
!
defaultStyle
        "Private - Answer the default frame style for the receiver."
    ^ 
        "WsVisible"
            WsDlgframe |
            WsCaption |
            WsSysmenu |
            WsPopup
!   
addButtons
	"Private - Add push buttons."

	| charSize font labelHeight buttonWidth gap column |
	children size > 1
		ifTrue: [^self]. "buttons already added."
	font := self font.
	charSize := font charSize.
	labelHeight :=  font height * 2.
	buttonWidth := (charSize x * 6) + (font stringWidth: 'Cancel').
	gap := charSize x @ charSize y.
	column := gap x.
	self isHelpButtonNeeded
		ifTrue:
			[self
				addSubpane:
					((helpButton := Button new)
					contents: '&Help';
					when: #clicked
						send: #help
						to: self;
					layoutFrame:
						((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
						topInset: (labelHeight + gap y) negated;
						leftInset: (column + buttonWidth) negated;
						bottomInset: gap y;
						rightInset: column);
					yourself).
			column := column + gap x + buttonWidth].
	self
		addSubpane:
			((applyButton := Button new)
			contents: '&Apply';
			disable;
			when: #clicked
				send: #apply
				to: self;
			layoutFrame:
				((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
				topInset: (labelHeight + gap y) negated;
				leftInset: (column + buttonWidth) negated;
				bottomInset: gap y;
				rightInset: column);
			yourself).
	column := column + gap x + buttonWidth.
	self
		addSubpane:
			(Button
			new contents: '&Cancel';
			when: #clicked
				send: #cancel
				to: self;
			layoutFrame:
				((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
				topInset: (labelHeight + gap y) negated;
				leftInset: (column + buttonWidth) negated;
				bottomInset: gap y;
				rightInset: column);
			yourself).
	column := column + gap x + buttonWidth.
	self
		addSubpane:
			(Button
			new contents: '&OK';
			when: #clicked
				send: #ok
				to: self;
			layoutFrame:
				((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
				topInset: (labelHeight + gap y) negated;
				leftInset: (column + buttonWidth) negated;
				bottomInset: gap y;
				rightInset: column);
			yourself).
	!   
inputOccurred
	"Private - Input occurred in the tab control."

	applyButton notNil ifTrue: [ applyButton enable ]! 
getWindowToDisable: aParent
        " Private - answer the window to disable when the receiver is opened. "
    ^aParent isNil
        ifTrue: [ Notifier findWindow: WindowHandle queryActive ]
        ifFalse: [ aParent ]!
turnToPageNumber: aNumber
    "Turn to page <aNumber>."

    self tabControl turnToPageNumber: aNumber
!  
ok
	"Trigger the apply event and close the window.
	This method is called after the OK button is pressed."

	self triggerApply.
	self close! 
help
	"Trigger the help event for the current page.
	This method is called after the Help button is pressed."

	self tabControl currentPage triggerEvent: #help: with: self tabControl currentPage!   
open
	"Open the dialog box modeless but float on top of the
	current active window."

     self open: nil
!