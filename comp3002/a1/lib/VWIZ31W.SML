3.1.0.106
   
next
	"Select the next page."

	| currentPage |
	currentPage := self tabControl currentPage.
	( currentPage hasActionForEvent: #next: )
		ifTrue: [ currentPage triggerEvent: #next: with: currentPage ]
		ifFalse: [ 
			self tabControl isLastPage 
				ifTrue: [ self close ]
				ifFalse: [ self tabControl nextPage ] ]!   
initialize
    "Private - Initialize the receiver."

    super initialize.
    self needFinishButton: true.
    self tabControl
        wizard.
    self propertyAt: #needOwnerWindow put: nil.
! 
isFinishButtonNeeded
	"Private - Answer true if finish button is needed."

	^ self propertyAt: #finishButton ifAbsent: [ false ]!  
buildWindow
        "Private - Create the dialog window for the receiver."

	super buildWindow.
	self pageChanged!
pageChanged
	"Private - Page had been changed, check if it
	is the first or the last page."

	self tabControl pageCount = 0
		ifTrue: [
			backButton disable.
			nextButton disable.
			^ self ].
	self tabControl isFirstPage
		ifTrue: [ backButton disable ]
		ifFalse: [ backButton enable ].
	self tabControl isLastPage
		ifTrue: [ 
			self isFinishButtonNeeded
				ifTrue: [ nextButton label: '&Finish' ]
			]
		ifFalse: [ 
			self isFinishButtonNeeded
				ifTrue: [ nextButton label: '&Next >' ]
			].
	self label: self getTitle
	
!  
addButtons
	"Private - Add push buttons."

    | charSize font labelHeight buttonWidth gap column |
	children size > 1 ifTrue: [ ^ self ].  "buttons already added."
    font := self font.
    charSize := font charSize.
    labelHeight := font height * 2.
	buttonWidth := (charSize x * 6 ) + ( font stringWidth: 'Cancelx' ).
	gap := charSize x @ charSize y.
	column := gap x.
	self isHelpButtonNeeded ifTrue: [
		self addSubpane:
			( Button new
				contents: '&Help';
				when: #clicked send: #help to: self;
				layoutFrame: ((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
					topInset: ( labelHeight + gap y ) negated;
					leftInset: ( column + buttonWidth ) negated;
					bottomInset: gap y;
					rightInset: column );
	             yourself ).
		column := column + gap x + buttonWidth ].
	self
        addSubpane: ( Button new
            contents: '&Cancel';
            when: #clicked send: #cancel to: self;
			layoutFrame: ((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
				topInset:( labelHeight + gap y ) negated;
				leftInset: ( column + buttonWidth ) negated;
				bottomInset: gap y;
				rightInset: column );
			yourself ).
	column := column + gap x + buttonWidth.
	self
        addSubpane: ( ( nextButton := Button new )
            contents: '&Next >';
            when: #clicked send: #next to: self;
			layoutFrame: ((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
				topInset:( labelHeight + gap y ) negated;
				leftInset: ( column + buttonWidth ) negated;
				bottomInset: gap y;
				rightInset: column );
            yourself ).
	column := column + gap x + buttonWidth.
	self
        addSubpane: ( ( backButton := Button new )
			contents: '< &Back';
			when: #clicked send: #back to: self;
			layoutFrame: ((LayoutFrame topLeftRatio: 1 @ 1 bottomRightRatio: 1 @ 1)
				topInset:( labelHeight + gap y ) negated;
				leftInset: ( column + buttonWidth ) negated;
				bottomInset: gap y;
				rightInset: column );
            yourself ).!   
back
	"Select the previous page."

	| currentPage |
	currentPage := self tabControl currentPage.
	( currentPage hasActionForEvent: #back: )
		ifTrue: [ currentPage triggerEvent: #back: with: currentPage ]
		ifFalse: [ 
			self tabControl previousPage ]! 
getTitle
	"Private - Answer the title."

	^ self tabControl currentPage isNil
		ifTrue: [ String new ]
		ifFalse: [ self tabControl currentPage titleForParent ].
	
!  
needFinishButton: aBoolean
	"Request the finish button to be present
	if <aBoolean> is true."

	self propertyAt: #finishButton put: aBoolean!