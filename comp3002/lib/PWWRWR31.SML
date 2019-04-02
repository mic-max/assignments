3.1.0.106
   
location: aPoint
        "Private - Answer a point.  X is the starting point of the
        receiver, y is the relative distance from the previous
        report item."
    ^location := aPoint rounded.!
currentColumn: ignore
        "Private - Do nothing.  Currently, only report table and
        table break care about columns"! 
initialize
    super initialize.
    self
        tickMarks: (Dictionary new
            at: 1 put: 2;
            at: 5 put: 5;
            at: 10 put: 10;
            yourself);
        font: self class font.!   
place: aPoint
        "Position the pen at aPoint."
    location := aPoint.
    storedPicture isNil
        ifTrue: [super place: aPoint]
        ifFalse: [storedPicture pen place: aPoint]!
adjustFraming: rectangleInParent
        "Private - React to the user draging/resizing the pane.
        make sure the pane spans the whole width of the parent."
    | partsFramer |
    super adjustFraming: rectangleInParent.
    partsFramer := self framingBlock.
    partsFramer
        left: 0
        stretched: false
        right: 0
        stretched: false.
    self resizeToRectangle: ( partsFramer scaleFrom: self superWindow freeClientArea ).
    self reportFrameParent notNil
        ifTrue: [
            self reportFrameParent leftMarginPane invalidateRect: nil.
            self reportFrameParent rightMarginPane invalidateRect: nil.]!   
reportFrame
    ^self!   
decimalDigits
    ^decimalDigits!
leftJustify
    " Private - Set the the justification to left."
    self justification: #left.! 
displayLeft
    | rect aPen windowEdge place n |
    self setToCurrentSystem.
    aPen := self pen.
    aPen setBackgroundMode: BackgroundMixTransparent;
        setTextAlign: TextAlignLeft | TextAlignTop.
    self displayCaption.
    rect := self rectangle.
    windowEdge := rect left @ (rect top up: 1).
    tickMarks isNil ifTrue: [^nil].
    "Display ticks"
    tickMarks associationsDo: [:mark |
        place := windowEdge.
        n := -1.
        [place y isAbove: rect bottom] whileTrue: [
            aPen
                place: place;
                line: (place right: mark value).
            place := windowEdge down: (mark key * self pixelsPerVerticalUnit * n ) rounded.
            n := n + 1]].
    "Display numbers"
    windowEdge := windowEdge right: 5.
    0 to: (self rectangle height // self pixelsPerVerticalUnit)
        by: numberIncrements do: [:i |
        aPen
            displayText: i printString
            at: (windowEdge 
				down: ( (i * self pixelsPerVerticalUnit) rounded "+ self font height - 2" )) ]! 
rightMargin: aNumber
        "Private - Set the right margin in 0.1 mm."
    ^rightMargin := aNumber.!  
goToLeftBottom
        "Private - Place the pen at the bottom left of the page."
    self place: (self
        partsIfOS2Do: [0 @ 0]
        partsIfWindowsDo: [0 @ height])! 
partPrintPropertiesOn: aStream margin: aString
        "Private - Append a description of the receiver's
        part properties (except the part name) to aStream.
        Append aString after every new line. "

    super partPrintPropertiesOn: aStream margin: aString.

    aStream
        nextPutAll: aString;
        nextPutAll: 'Function: ';
        nextPutAll: self function asString;
        cr.! 
foreColor
        "Private - Always answer the same color so the color cannot be
        changed from the common property dialog of the multiple selection."
    ^Color black! 
emptyLines: aPen
        "Answer the number of empty lines of text left in the page
        above the page footer."
    ^(self reportFrameBody spaceInPage: aPen) // (aPen font lineSpacing)!  
basicUnit
        "Private - All internal measurements in the report writer
        are kept in centimeter, including the PARTSFramers and
        the width and the positions of the report items."
    ^#centimeter!
height: aNumber
        "Private - Set the height in 0.1mm."
    height := aNumber! 
isWindow
        "Private - When the a MenuListPane is shrunk inside
        a PARTSWorkbench it is represented by an icon,
        and it is not to behave like a window.Retained for backward compatibility."
        ^self partIsShrunk not!   
wordWrap
    ^wordWrap!  
new
        "Answer a new instance of the receiver."
    ^super new initialize! 
displayRight
    | rect aPen windowEdge place n |
    self setToCurrentSystem.
    aPen := self pen.
    rect := self rectangle.
    windowEdge := rect right.
    tickMarks isNil ifTrue: [^nil].
    "Display ticks"
    tickMarks associationsDo: [:mark |
        place := windowEdge @ -1.
        n := -1.
        [place y < rect height] whileTrue: [
            aPen
                place: place;
                line: (place left: mark value).
            place := place y: (mark key * self pixelsPerVerticalUnit * n ) rounded.
            n := n + 1.]].
    "Display numbers"
    windowEdge := windowEdge left: self font width + 6.
    0 to: (self rectangle height // self pixelsPerVerticalUnit)
        by: numberIncrements do: [:i |
        aPen
            displayText: i printString
            at: windowEdge @ ( (i * self pixelsPerVerticalUnit) rounded "+ self font height - 2" ) ]! 
evaluateRunningSummary
    function = #average
        ifTrue: [[runningSummary := runningSummary / runningCount ]
            on: ZeroDivide do: [runningSummary := nil]].
    (function = #varN
        or: [function = #stDevN])
        ifTrue: [
            runningSummary :=
                ([(runningSummary at: #squaredSum) / runningCount ]
                    on: ZeroDivide do: [nil]) -
                ([(runningSummary at: #sum) / runningCount ]
                    on: ZeroDivide do: [nil]) squared].
    (function = #varNMinus1
        or: [function = #stDevNMinus1])
        ifTrue: [
            runningSummary :=
                ([(runningSummary at: #squaredSum) / (runningCount - 1) ]
                    on: ZeroDivide do: [nil]) -
                ((([(runningSummary at: #sum) ]
                    on: ZeroDivide do: [nil]) squared) / ( runningCount *
(runningCount - 1)))].
    (function = #stDevN
        or: [function = #stDevNMinus1])
        ifTrue: [
            runningSummary :=runningSummary sqrt].! 
pageNumber
        "Private - answer an Integer which is the number of the page
        currently being displayed."
    pageNumber isNil
        ifTrue: [pageNumber := 1].
    ^pageNumber! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#aboutToReport:
            )
        separators: #(  )
        defaultItem: #aboutToReport:! 
playPageNumber: requestedPage on: aGraphicsTool
        "Private - Load the page, and display it."
    | bits lastPageLimit pageNumber |
    pageLimits size = 0 ifTrue: [^0].
    aGraphicsTool setMapMode.
    pageNumber := 1 max: (requestedPage min: pageLimits size).
    lastPageLimit := pageNumber = 1
        ifTrue: [0]
        ifFalse: [pageLimits at: (pageNumber - 1)].
    bits := ByteArray new:
       ( (pageLimits at: pageNumber) - lastPageLimit).
    (File pathName: self fileName)
        position: lastPageLimit;
        getBytesFor: bits;
        close.
    self loadFromBits: bits.
    self
        partsIfOS2Do: [ self partsDisplayWith: aGraphicsTool ]
        partsIfWindowsDo: [ super displayWith: aGraphicsTool ].
    ^pageNumber!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #groupValue
            #setGroupValue:
            #runningValue
            #setRunningValue:
            )
        separators: #( 2 )
        defaultItem: #setGroupValue:!   
recordingGraphicsMedium
    ^storedPicture!  
setTopMargin: aNumber
        "Private - Set the top margin to aNumber.
         Resize the top margin pane."
    topMargin := aNumber.
    self resizeToRectangle: self frameRelativeRectangle.! 
pageFooter
    ^super new isPageHeader: false; yourself! 
unit
        "Private - Answer a symbol based on the OS/2 country settings."
    ^NationalLanguage measurementSystem = 1
        ifTrue: [#inch]
        ifFalse: [#centimeter]!  
pageWidthPixels
        "Private - answer the page width in the display pixels."
    ^displayPane width!
foreColor: aColor
        "Set the foreground color of the receiver."
    super foreColor: aColor.
    self displayPane foreColor: aColor.!
scrollTopCorner: aPoint
        "Private - Move the contents of the receiver
         pane by extent aPoint."
    self scrollTopCornerInCurrentPageTo: ( topCorner + aPoint)!  
scrollTopCornerInCurrentPageTo: aPoint
        "Private - "
    | gardBand swp |
    gardBand := 40.
    topCorner := self restrictScrollRange: aPoint.

    "If too far down, jump to next page."
    ( (topCorner y down: self displayPane rectangle height)
         isAbove: (self rectangle bottom up: gardBand) )
        ifTrue: [
            self
                partsIfOS2Do: [
                    pageNumber = self numberOfPages
                        ifTrue: [
                            topCorner y: ( topCorner y min: self displayPane rectangle height ) ]
                    ifFalse: [^self turnToNextPage] ]
                partsIfWindowsDo: [ ^self turnToNextPage ] ].
    "If too far up, jump to previous page."
    (topCorner y isBelow:  (self rectangle top down: gardBand) )
        ifTrue: [^self turnToPreviousPageBottom].
    swp := self         "OS/2 will put frame window on top unless we change ZOrder"
        partsIfOS2Do: [ 2 | 4 "SwpMove | SwpZorder " ]
        partsIfWindowsDo: [ 5 "SwpNozorder | SwpNosize" ].
    self displayPane frameWindow handle setWindowPos: SwpHwndBottom
        rectangle: ( topCorner extentFromLeftTop: self displayPane extent )
        fs: swp.
    self updateSliders !   
basicUnit
        "Private - All internal measurements in the report writer
        are kept in centimeter, including the PARTSFramers and
        the width and the positions of the report items."
    ^#centimeter!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#setValue:)
        separators: #(  )
        defaultItem: #setValue:! 
clear
        "Private - Undo all the drawing done so far."
    storedPicture notNil
        ifTrue: [
            storedPicture clear.
            storedPicture := nil].
    self erase.! 
isReportWriterNonvisualPart
        "Private - Answer if the receiver is one of the
        report writer non-visual parts."
    ^true!
lafInsert: wrapper under: father
        "This method is here to prevent a menu bar to be added,
        also to prevent the label to be set to the application name."
    owner := wrapper application.
    father addSubpane: self.!
drawChain
        "Private - Replay the storedPicture."
    "self eraseNoRecord."
    storedPicture notNil
        ifTrue: [storedPicture playCurrentPage: self]
        ifFalse: [ self erase]! 
setRightMargin: aNumber
        "Private - Set the right margin to aNumber.
         Resize the right margin pane."
    rightMargin := aNumber.
    self rightMarginPane framingBlock
        right: 0 stretched: false width: rightMargin / 100 stretched: false.
    self rightMarginPane resizeWithNewPARTSFramer.!  
valueAsString
        "Private - Answer a formatted String."
    ^self objectAsString: value!   
collate: aBoolean
        "Private - "
    collate := aBoolean! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #report
            #setDocumentName:)
        separators: #( 1 )
        defaultItem: #report! 
startPrintJob: jobTitle
    self deleteFile! 
iterateRow: row stream: aStream
        "Private - Check if need to end the group.  If so
        output to aStream.  Otherwise, remember whatever
        is necessary from row."
    "First, test each break condition,
    and output if a break condition is met."
    self printIfBreakTime: row stream: aStream.
    "Set the current value for all the break conditions, to be
    compare in the next iteration."
    self breakFields associationsDo: [: break|
        break value: (row at: break key ifAbsent: [nil])].
    "Last, update each item (sum, etc.)"
    reportLines do: [:line |
        line do: [:item|
            item visitRow: row]].!   
reportToPen: aPen
        "Private - Replay all the contents of the stored picture onto aPen."
    aPen graphicsMedium startPrintJob.
    self display.
    aPen graphicsMedium endPrintJob.! 
breakIntoLines: aString output: output
        "Private - Set lines to an OrderedCollection of Strings, where
        each string is shorter than the size."
    "currentLineIndex is at first the location of the field, which
     indicates that the pen must be moved down to start reporting,
     once the pen has been moved down, and we are ready to report,
    the currentLineIndex holds an Integer pointing into lines."
    currentLineIndex := self location.
    output font: self font.
    lines := output
        asArrayOfLines: aString
        in: ((0@0) extent: (width @ 0))
        wordWrap: self wordWrap.
    ^lines size!   
fitsInPage: aRectangle pen: aPen
        "Private - Answer a Boolean if there is enough vertical space
        in the current page for aRectangle to fit.  Always answer true if aPen is
        located at the top of the page to avoid inifinte loop."
    ^reportPart superWindow fitsInPage: aRectangle pen: aPen!
uniqueFileName
        "Private - Answer a unique file name"
    | answer root extention count |
    "We can use getTempFileName: path prefix: prefix unique: anInteger fileName: buffer"
    root := 'PTSRW'.
    extention := '.TMP'.
    count := 0.
    answer := root , count asString , extention.
    [File exists: answer] whileTrue:
        [count := count + 1.
        count > 999 ifTrue: [Error signal: 'Too many files temporary report files.'].
        answer := root , count asString , extention].
    ^answer!   
font
    ^font!  
pageHeaders: anOrderedCollection
    pageHeaders := anOrderedCollection.!
average
    groupSummary := groupSummary + value.
    groupCount := groupCount + 1.
    runningSummary := runningSummary + value.
    runningCount := runningCount + 1.!  
lowerOf: point1 and: point2
        "Private - Answer the point which is lower in the page."
	^self 
		partsIfOS2Do: [
			point1 y  < point2 y 
        		ifTrue: [point1]
        		ifFalse: [point2]]
		partsIfWindowsDo: [
			point1 y abs > point2 y abs
        		ifTrue: [point1]
        		ifFalse: [point2]]!   
partMirrorCopyPropertiesToExclude
        " Private - answer the names of any properties
        implemented by the receiver which should be excluded
        when its properties dictionary is mirrorCopied. "

   ^#( #dragSessionClass #dragTarget )! 
horizontalPixelsPerMeter
    ^Display horizontalPixelsPerMeter!  
reprintOn: storedPicture copies: requestedCopies collate: aBoolean
        "Private - Reprint the contents of the storedPicture."
    self startPrintJob: ''.
    aBoolean
        ifTrue: [
            requestedCopies timesRepeat: [
                1 to: storedPicture numberOfPages do: [: pageNumber |
                    storedPicture playPageNumber: pageNumber on: self pen]]]
        ifFalse: [
            1 to: storedPicture numberOfPages do: [: pageNumber |
                requestedCopies timesRepeat: [
                    storedPicture playPageNumber: pageNumber on: self pen]]].
    super endPrintJob.!  
isPARTSPageBreakPart
    ^true!  
horizontalScrollBar
        "Private - Answer an instance of ScrollBar for the horizontal scrollbar."
    ^horizontalScrollBar! 
scrollHorizontal: anInteger
        "Private - Scroll the pane right by anInteger
         number of pixels (if positive) or left by
         the absolute value of anInteger (if negative)."
    self scrollTopCorner: anInteger @ 0!
defaultBackColor
        "Answer the default background color of the receiver."
    ^nil!   
partIsWindow
        "Answer true if the receiver is not shrunken else false."

    ^self partIsShrunk not
!  
verticalScrollBar: aScrollBar
        "Private - set the verticalScrollBar in the receiver to aScrollBar."
    verticalScrollBar := aScrollBar! 
drawScrollTopTab: aPane
        " Private - Draw the scroll Top tab button "
    | points rect color |
    rect := 0 @ 0 extent: aPane extent.
    points := Array
        with: ( rect center leftAndUp: 4 @ 1 )
        with: ( rect center up: 5 )
        with: ( rect center rightAndUp: 4 @ 1 ).
    rect := 0 @ 0 extent: aPane extent.
    color := aPane disabled
        ifTrue: [ Color darkGray ]
        ifFalse: [ Color black ].
    aPane graphicsTool
        fill: (0 @ 0 extent: aPane extent )
        color: Color gray;
        place: rect leftTop;
        line: rect leftBottom;
        line: rect rightBottom;
        foreColor: color;
        backColor: color;
        polygonFilled: points.
    points := points collect: [: each | each down: 6 ].
    aPane graphicsTool polygonFilled: points!  
pageHeader
    ^super new isPageHeader: true; yourself!  
isPARTSReportStructure
    ^true!
pixelsPerVerticalUnit
    ^self unit = #inch
        ifTrue: [Display verticalPixelsPerInch]
        ifFalse: [Display verticalPixelsPerMeter / 100]!  
backColor: aColor
        "Set the background color of the receiver to aColor."
    ^storedPicture isNil
        ifTrue: [super backColor: aColor ]
        ifFalse: [storedPicture pen backColor: aColor ].! 
partsDisplayWith: aPen
        "Private - VOS only method. Can't use super displayWith: because
         we need to modify options for GpiPlayMetaFile to use the settings
         in the metafile instead of defaults."
    | alOpt |
    self partsVosOnly.
	aPen
		handle setCharSet: 0;
		deleteSetId: "LcidAll" -1. "If not done the createLogFont will fail"
    alOpt := ExternalBuffer new: 32.
    alOpt
        longAtOffset: 12 put: "LcLoaddisc" 3;
        longAtOffset: 24 put: "CtabReplace" 3.
    ( ( PARTSHostInterface hostGraphicsLibrary
        playMetaFile: aPen handle
        hmf: self handle
        cOptions: 8
        alOptions: alOpt asParameter
        pcSegments: nil
        cchDesc: 0
        pszDesc: nil ) = 0 )
            ifTrue: [ ^self osError ]!
defaultForeColor
    ^nil!   
initialize
    super initialize.
    isPageHeader := true.
    reportOnFirstPage := true.! 
backColor: aColor
        "Set the background color of the receiver."
    super backColor: aColor.
    self displayPane backColor: aColor.!
pageLeft
        "Private - the user clicked to the left of the slider. Scroll
        a page towards the left."
    self scrollHorizontal: self amountToPageLeft! 
initialize
        "Private - Create all the subpanes which make up the part."
    super initialize.
    pageHeight := 2795.
    pageWidth := 2000.!  
scrollVertical: anInteger
        "Private - Scroll the pane down by anInteger
         number of pixels (if positive) or up by
         the absolute value of anInteger (if negative)."
    self scrollTopCorner:  0 @ anInteger!
location
        "Private - Answer a Point where x is the distance from the left
        edge of the paper, and y is the distance from the bottom of the
        last line of items.  All in 0.1 mm"
    ^location!   
decimalDigits
        "Private - Set the number of digits to the right
        of the decimal separator."
    ^reportField decimalDigits!  
endPrintJob
    self
        appendOnFile;
        release;
       startRecording!
validate
    super validate.
"must be done after validate to overwrite what is done in validate."
    self validatePen.!   
displayPane: aPane
        "Private - set an instance of PARTSReportDisplayPane, where the
        report is actually displayed in."
    ^displayPane := aPane!
frameTop
        "Private - Answer in window coordinates the position of the top of the frame."
    ^self rectangle top!
currentColumn: anInteger
    currentColumn := anInteger! 
createChildren
        "Private - Create the report from body, and the rulers."
    | rulerThickness |
    rulerThickness := 0.5.
    self reportFrameBody isNil
        ifTrue: [
            "main body"
            self addSubpane: (PARTSReportFrameBody new
                framingBlock: (
                    PARTSFramer new
                        scaleUnit: self basicUnit;
                        top: rulerThickness stretched: false bottom: 0 stretched: false;
                        left: leftMargin / 100 stretched: false right: rightMargin / 100 stretched: false;
                        yourself
                        ))].
    self
        "left margin"
        addSubpane: (PARTSReportRulerPane new
            setName: #leftMargin;
            orientation: #left;
            framingBlock: (
                PARTSFramer new
                    scaleUnit: self basicUnit;
                    left: 0 stretched: false width: leftMargin / 100 stretched: false;
                    top: rulerThickness stretched: false bottom: 0 stretched: false;
                    yourself
                    ));
    "right margin"
        addSubpane: (PARTSReportRulerPane new
            "left oriented so ticks still visible even if some of
            the ruler is out of viewing range."
            setName: #rightMargin;
            orientation: #left;
            framingBlock: (
                PARTSFramer new
                    scaleUnit: self basicUnit;
                    right: 0 stretched: false width: rightMargin / 100 stretched: false;
                    top: rulerThickness stretched: false bottom: 0 stretched: false;
                    yourself
                    ));
    "add the ruler"
        addSubpane: (PARTSReportRulerPane new
            orientation: #top;
            framingBlock: (
                PARTSFramer new
                    scaleUnit: self basicUnit;
                    left: 0 stretched: false right: 0 stretched: false;
                    top: 0 stretched: false height: rulerThickness stretched: false;
                    yourself
                    )).! 
font: aFont
        "Pirvate - Each report field has its own font, and it does not
        inherit from the report frame.  The receiver has not text
        to display, so it does not need a font."! 
reportLines: aCollection
    reportLines := aCollection! 
prepareRow: row stream: aStream
    ^self prepareLine: aStream!  
font
        "Private - Answer the font used for the digits."
    ^ Font new
        faceName: (self partsIfOS2Do: ['Helv'] partsIfWindowsDo: ['MS Sans Serif']);
        pointSize: 8;
        fixedWidth: false;
        bold: false;
        italic: false;
        yourself.! 
setLeftMargin: aNumber
        "Private - Set the left margin to aNumber.
         Resize the left margin pane."
    leftMargin := aNumber.
    self leftMarginPane framingBlock
        left: 0 stretched: false width: leftMargin / 100 stretched: false.
    self leftMarginPane resizeWithNewPARTSFramer.!  
prepareLine: aStream
        "Private - Sent to each report field before the reporting to
        give a chance to break the contents into lines, etc."
    "currentLineIndex is at first the location of the field, which
     indicates that the pen must be moved down to start reporting,
     once the pen has been moved down, and we are ready to report,
    the currentLineIndex holds an Integer pointing into lines."
    currentLineIndex := self location.!   
PARTSReportFramePart removePartRuntimeLibrary!
defaultForeColor
    ^Color black!   
numberOfPages
        "Private - Answer an Integer for the number of pages
        stored so far, excluding any currently unfinished page."
    ^pageLimits size!  
setRunningValue: anObject
        "Set the value to be reported for the current group."
    ^self reportField runningSummary: anObject! 
isPARTSGroupFramePart
    ^true! 
endPrintJob
    self checkAbortPrinting.
    copies > 1 ifTrue: [
        self additionalCopies.
        collate ifTrue: [
            copies timesRepeat:
                [self checkAbortPrinting.
                abortDialog setStatus: 'Printing multiple copies'.
                self pen recordingGraphicsMedium displayWith: self pen]].].
    self aborted ifFalse: [abortDialog closeDialog ].
    super endPrintJob.!   
orientation
        "Private - answer orientation to one of the four symbols:
        #(left top right bottom)."
    ^orientation! 
reportFrameParent
    ^self superWindow isPARTSReportFramePart
        ifTrue: [self superWindow ]
        ifFalse: [nil]! 
verticalPosition
        "Private - Answer the position of the receiver which determines
        the starting point in the printing."
    ^self frameRelativeRectangle top.!   
setScrollRange
        "Private - Set the range scroll bars to the invisible portion of
        the displayPane in pixels."
    self verticalScrollBar
        minimum: 0;
        maximum: self totalLength;
        lineIncrement: self amountToScrollUp;
        pageIncrement: self amountToPageUp.
    self horizontalScrollBar
        minimum: 0;
        maximum: self totalWidth;
        lineIncrement: self amountToScrollLeft;
        pageIncrement: self amountToPageLeft.
    self updateSliders.!
previousValue: aValue
        " Private - Set the previous value.  Used for
        supressing repeatitions."
    previousValue := aValue! 
pageHeaders: headers
    self reportFrameBody pageHeaders: headers!  
setDocumentName: aString
        "Private - Set the name of the print job.  The name is used on
        the banner sheet, and in the print queue."
    documentName := aString!
subStringOfSize: aString stream: aPen
    | answer i |

    answer := String new.
    i := 0.
    [i < aString size  and:
        [(self stringWidth: answer stream: aPen ) < width]]
        whileTrue: [
            i := i + 1.
            answer := answer , (String with: (aString at: i))].
    ^answer! 
deleteFile
        "Private - While the report is being displayed, it is backed up in
        a file called fileName.  This file has a section for each page, the offsets
        are kept in pageLimits."
    (File exists: self fileName)
        ifTrue: [File remove: self fileName].!   
totalWidth
        "Private - Answer the total scrollable width of the document in pixels."
    | width |
    width := 1 max: (displayPane rectangle width
        - self rectangle width) rounded.
    ^width!  
verticalPixelsPerMeter
    ^Display verticalPixelsPerMeter!  
prepareLine: aStream
    | numberOfLines |
    self evaluateGroupSummary.
    reportPart triggerEvent: #aboutToGroupReport:
        withArguments: (Array with: groupSummary).
    numberOfLines := self breakIntoLines: self groupSummaryAsString output: aStream.
    self resetGroupSummary.
    ^numberOfLines.!   
initPARTSReportField
        "PARTSReportField is the actual class which at the runtime
        generates the report."
    self implementedBySubclass! 
spaceInPage
        "Pirvate - Answer in logical units the free distance left
        in page."
	^0 max: (self 
		partsIfOS2Do: [location y]
		partsIfWindowsDo: [height - location y abs])! 
location
        "Private - Answer a Point where x is the distance from the left
        edge of the paper, and y is the distance from the bottom of the
        last line of items.  All in 0.1 mm"
    ^reportField location.!  
reportFrameBody
        "Private - Answer the subpane which contains all the report items,
        or nil if it does not exist yet."
    ^self propertyAt: #reportFrameBody ifAbsent: [ nil ]
    "self children do: [:child |
        child isPARTSReportFrameBody ifTrue: [^child]].
    ^nil"!   
bottomMargin
        "Private - Answer the bottom margin in 0.1 mm."
    ^bottomMargin! 
goRight: logicalUnits
        "Private - Move the current position down by height logicalUnits."
    self place: (location right: logicalUnits).!   
amountToScrollLeft
        "Private - Answer the number of pixels
        for horizontal line scrolling."
    ^( Display horizontalPixelsPerMeter / 100 ) rounded! 
initialize
        "Private - Prepare the receiver for receiving graphics operations."
    self
        startRecording;
        fileName: self uniqueFileName.!   
isPageHeader: aBoolean
    isPageHeader := aBoolean! 
turnToNextPage
        "Private - Display the next page alinged at the top.  Do nothing
        if already displaying the last page."
    pageNumber < self numberOfPages
        ifTrue: [self turnToPage: pageNumber + 1 scrolledToPageTop: true].! 
fieldName: aName
        "Private -"
    ^reportField name: aName!  
modified: aBoolean!   
pageHeaderSize
        "Private - Answer in cm the the height that all the page
        headers occupy."
    | answer |
    answer := 0.
    pageHeaders do: [:header |
        answer := answer + header reportHeight].
    ^answer!  
isReportWriterNonvisualPart
        "Private - Answer if the receiver is one of the
        report writer non-visual parts."
    ^true!
setPageButtonEnableState
        "Private - Disable the page buttons if they don't make sense."
    self pageUpButton enable.
    self pageDownButton enable.
    self pageNumber = 1
        ifTrue: [self pageUpButton disable].
    self pageNumber >= self numberOfPages
        ifTrue: [self pageDownButton disable]!
reportField
    ^self!   
clear
        "Clear the contents of the report pane."
    self displayPane clear.
    pageNumber := 0.
    self
        setScrollRange;
        updateSliders;
        setPageButtonEnableState.! 
gettingFocus
        "Private - do nothing. A report ruler pane does not need focus."!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #value
            #setValue:)
        separators: #(  )
        defaultItem: #setValue:!   
previousPageButton
        "Private - Answer the drawn button which has an up arrow on it."
    self children do: [:child |
        child name = 'pageUpButton' ifTrue: [^child]].!
initializeReport: aPen
        "Private - "
    reportLines do: [:line |
        line do: [:item | item initializeReport: aPen]].! 
erase
    self
        partsIfOS2Do: [    "fill: does not work in metafiles"
            self rectangleFilled: (0 @ 0 extent: self extent rounded ) ]
        partsIfWindowsDo: [ super erase ]!  
currentColumn
        "Private - Answer the column currently being reported.
        report tables and table breaks can have more than one column."
    currentColumn isNil
        ifTrue: [currentColumn := 1].
    ^currentColumn!
bottomMargin
        "Private - Answer the top margin in 0.1 mm."
    ^self superWindow bottomMargin!   
prepareLine: aStream
    self evaluateFunction.
    reportPart triggerEvent: #aboutToReport:
        withArguments: (Array with: value).
    ^self breakIntoLines: self valueAsString output: aStream!
clear
        "Private - Get ride fo the current report."
    pageLimits := nil.
    deviceContext notNil ifTrue: [ self stopRecording ].
    self
        release;
        deleteFile";
        startRecording"!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #printReport:
        )
        separators: #( )
        defaultItem: #printReport:!
addToHeadersIfAbsent
        "Private - Add the receiver to pageHeaders of the
        enclosing frame, if it is not already there."
    | pageHeaders |
    ((pageHeaders := self reportFrameBody pageHeaders)
        includes: self)
        ifFalse: [pageHeaders add: self].!  
emptyLines: aPen
        "Answer the number of empty lines of text left in the page.
        In the page footer, there is always one line for each field."
    ^1! 
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process cursor keys."

    aKeyboardInputEvent = TabKey ifTrue: [^self tabKeyInput: aKeyboardInputEvent ].
    aKeyboardInputEvent = UpKey ifTrue: [^self superWindow scrollVertical: self amountToScrollUp].
    aKeyboardInputEvent = DownKey ifTrue: [^self superWindow scrollVertical: self amountToScrollUp negated].
    aKeyboardInputEvent = PageUpKey ifTrue: [^self superWindow turnToPreviousPageTop].
    aKeyboardInputEvent = PageDownKey ifTrue: [^self superWindow turnToNextPage].
    aKeyboardInputEvent = LeftKey ifTrue: [^self superWindow scrollHorizontal: self amountToScrollLeft].
    aKeyboardInputEvent = RightKey ifTrue: [^self superWindow scrollHorizontal: self amountToScrollLeft negated].
    aKeyboardInputEvent = HomeKey ifTrue: [^self superWindow turnToPage: 1].
    aKeyboardInputEvent = EndKey ifTrue: [^self superWindow turnToPage: self superWindow numberOfPages].

     ^super keyboardInput: aKeyboardInputEvent!
verticalPosition
        "Private - Answer the position of the receiver which determines
        the starting point in the printing."
    ^self frameRelativeRectangle top.!   
startPage: aPen
    " Private - Start a new page and write the page headers."
    self reportFrameBody incrementPageNumber.
    self currentColumn: 1.
    aPen
        setBackgroundMode: BackgroundMixTransparent;
        setMapMode;
        goToLeftTop;
        goDown: self topMargin.
    self reportFrameBody pageHeaders do: [:pageHeader |
        pageHeader reportOn: aPen].!  
isPARTSReportColumnPart
    ^false!  
prepareLine: aStream
        "Private - Sent to each report field before the reporting to
        give a chance to break the contents into lines, etc."
    self implementedBySubclass.!   
updateVerticalSlider
        "Private - Update the vertical slider position."
    | vertPosition |
    vertPosition := self pageHeightPixels *
        (self pageNumber - 1)
        up: ( self topCorner y - self rectangle top ) .
    self verticalScrollBar setValue: vertPosition.!
setLineWidth: anInteger
    storedPicture isNil
        ifTrue: [super setLineWidth: anInteger]
        ifFalse: [storedPicture pen setLineWidth: anInteger].! 
isPARTSReportField
    ^false!   
pageHeightPixels
        "Private - answer the page height in the display pixels."
    ^displayPane height! 
runningSummaryAsString
        "Private - Answer a String."
    ^self objectAsString: runningSummary!   
formFeed
        "Private - Append the current content into aFileName."
    self
        release;
       startRecording!  
prepareLine: ignore
        "Answer 1.  Pretend the whole table is a single
        line in the report frame.  Let the table itself
        report multiple lines."
    ^1!   
bottomMargin
    ^self reportFrameParent bottomMargin!   
reportOn: aPen
        "Private - Horizontal line is implemented as a rectangle.
        a one line outline gets the forecolor, and the inside is filled with
        the back color."
    | rectangle oldForeColor oldBackColor |
    currentLineIndex isPoint
        ifTrue: [
            "Future refinement, if going down causes a page break,
            remember how much further need to go down on the next page."
            aPen goDown: currentLineIndex y.
            currentLineIndex := 0].
    rectangle := ( aPen place right: self location x )  extentFromLeftTop:
        (self width @ self height).
    (self fitsInPage: rectangle pen: aPen)
        ifFalse: [^false].
    foreColor notNil
        ifTrue: [
            oldForeColor := aPen foreColor.
            aPen foreColor: foreColor].
    backColor notNil
        ifTrue: [
            oldBackColor := aPen backColor.
            aPen backColor: backColor].
    aPen
        backColor: backColor;
        rectangleFilled: rectangle.
    foreColor notNil
        ifTrue: [aPen foreColor: oldForeColor].
    backColor notNil
        ifTrue: [aPen backColor: oldBackColor].
    aPen goDown: self height.
    ^true!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToReport
            #reportFinished
            #reportCanceled:
            )
        separators: #(  )
        defaultItem: #aboutToReport!  
printIfBreakTime: row stream: aPen
        "Private - Check if need to end the group.  If so
        output to aPen."
    firstTime ifTrue: [^firstTime := false].
    "Move the pen down regardless of reporting or not."
    aPen goDown: self location y.
    (self isBreakTime: row)
        ifTrue: [
            self triggerEvent: #aboutToReport.
            self
                reportFieldsDo: [:item | item prepareLine: aPen]
                withPen: aPen.
            aPen goDown: trailingHeight.
            "Set the previous value for all the break conditions,
            and end this iteration."
            breakFields associationsDo: [: break|
                break value: (row at: break key ifAbsent: [nil])].
            self recordFrame resetAfterGroupBreak]!  
isPARTSHardPageBreakPart
    ^true!  
display
        "Private - "
    self pen drawChain!
reportFrameParent
    | reportFrameBody |
    reportFrameBody := self reportFrameBody.
    ^reportFrameBody notNil
        ifTrue: [reportFrameBody reportFrameParent]
        ifFalse: [nil]!   
fileName
        "Private - The name of the temporary file storing the metafile."
    ^fileName!
reportOn: aPen
        "Private - Generate a report onto aPen."
"Do the page footer."
    self triggerEvent: #aboutToReport:
        withArguments: (Array with: self reportFrameBody pageNumber).
    firePageFooters ifTrue: [self endPage: aPen].
"FormFeed."
    aPen graphicsMedium formFeed.
"Do the page header."
    firePageHeaders ifTrue: [self startPage: aPen].
    ^true "the hard page break is done."!  
pageHeaderBoundry
        "Private - Answer in logical units the the bottom of the last
        page header."
    ^pageHeaderBoundry isNil
        ifTrue: [self topMargin]
        ifFalse: [pageHeaderBoundry]!
checkAbortPrinting
        "Private - Need to set the map mode after feeding
        new page."
    self aborted
        ifTrue: [
            self abortPrintJob.
            Error signal: 'Printing canceled.'].!
abortPrintJob
        "Private - User has requested the print job to be canceled."
    super abortPrintJob.
    abortDialog closeDialog!   
pageFooterBoundry
        "Private - Answer the distance from the bottom where
        the first page footer starts in cm."
    ^self pageFooters isEmpty
        ifTrue: [self bottomMargin]
        ifFalse: [self pageFooters first location y]!  
reportFieldsDo: prepareBlock withPen: aPen
        " Private - Iterate through all the report fields."
    aPen
        goToLeftEdge;
        goRight: (self columnLeftEdge: aPen).
    reportLines do: [:line |
        line do: [:item |
            prepareBlock value: item].
        self reportLine: line on: aPen]!
documentName
    ^self reportFrameBody documentName! 
verticalPixelsPerInch
    ^Display verticalPixelsPerInch!
wmPaint: a with: b
        "Private - process the paint message."
    ^nil! 
isTransparent
        "Private - answer whether the receiver's background
        should be painted with the same background color
        as its parent pane."
    ^true!
reportToPen: aPen
    self reportFrameBody reportToPen: aPen!
breakFields
        "Private - Answer a Dictionary where the key is the name of
        the fields which are to be group forming criteria.  The value
        is used during the runtime to keep track of the values of those
        fields."
    ^breakFields isNil
        ifTrue: [Dictionary new]
        ifFalse: [
            "prune the fields where the column field was deleted."
            breakFields" keysDo: [:keyName|
                (fieldsToBreakOn includes: keyName)
                    ifFalse: [breakFields removeKey: keyName]]"]! 
horizontalPixelsPerInch
    ^Display horizontalPixelsPerInch!
basicUnit
        "Private - All internal measurements in the report writer
        are kept in centimeter, including the PARTSFramers and
        the width and the positions of the report items."
    ^#centimeter!
setTextAlign: anInteger
        "Private - Repeat the operation for the meta file."
    storedPicture isNil
        ifTrue: [super setTextAlign: anInteger]
        ifFalse: [storedPicture pen setTextAlign: anInteger].!
reset
        "Private - A group has just ended.  Do nothing,
        there is nothing for a hard page break to reset."!
setValue: aString
    self reportField setValue: aString!
function
        "Private - Answer a String the name of the function
        to be performed on the domain of the numbers."
    ^reportField function! 
initialize
    super initialize.
    writeReport := false.! 
doNotRepeat: aBoolean
        "Private - aBoolean means do not report if the value of the
        current row is the same as the preivous row starting in the
        current group."
    ^doNotRepeat := aBoolean!   
copies: anInteger
        "Private - "
    copies := anInteger.
    copies > 1 ifTrue: [self pen retainGraphics].! 
functionSelectors
        "Private - Answer an array of Symbold of all the
        functions this part could perform over the domain
        of number it is reporting on."
    ^#(#sum #average #count #minimum #maximum #varN #varNMinus1 #stDevN #stDevNMinus1 #none)! 
setPhysicalMapMode
        "Private - Set the map mode to physical units"
    self
        partsIfOS2Do: [
            self setModelScale: 1 @ 1
                option: "TransformReplace" 0.
            ( storedPicture notNil and: [storedPicture pen notNil])
                ifTrue: [
                    storedPicture pen
                        setModelScale: 1 @ 1
                        option: "TransformReplace" 0.]]
        partsIfWindowsDo: [
            self
                setMapMode:  "MmText" 1;
                setWindowExt: 1 @ 1;
                setViewportExt: 1 @ 1.
            storedPicture isNil
                ifFalse: [
                    storedPicture pen
                    setMapMode: "MmText" 1;
                    setWindowExt: 1 @ 1;
                    setViewportExt: 1 @ 1] ].!   
summaryField
    ^self reportField!  
fontInDifferentMapMode: requestedFont
        "Private - Set the font while worrying about
        the map mode."
    | resolutionFont |
    self setMapMode.
    self
        partsIfOS2Do: [ resolutionFont :=
            Font fromFont: requestedFont graphicsMedium: self graphicsMedium ]
        partsIfWindowsDo: [
            resolutionFont := Font fromLogicalFont: requestedFont logicalFont.
            resolutionFont
                pointSize: resolutionFont pointSize
                graphicsMedium: self graphicsMedium;
                makeFont ].
    self font: resolutionFont.!  
numberOfPages
        "Private - answer an Integer which is the number of pages displayed."
    | recordingGraphicsMedium |
    recordingGraphicsMedium := self displayPane pen recordingGraphicsMedium.
    ^recordingGraphicsMedium isNil
        ifTrue: [0]
        ifFalse: [recordingGraphicsMedium numberOfPages]!   
horizontalPixelsPerLometric
    ^graphicsMedium horizontalPixelsPerMeter / 10000!
horizontalPixelsPerInch
    ^Display horizontalPixelsPerInch!
partIsSelectable
    ^false! 
reportRunningReport: aPen
        "Check if need to end the group.  If so
        output to aStream."
    aPen goDown: self location y.
    self
        reportFieldsDo: [:item | item prepareRunningReport: aPen]
        withPen: aPen.
      aPen goDown: trailingHeight.!  
goToLeftEdge
        "Private - Place the pen at the right edge of the page."

    self place: 0 @ location y.!
pageFooters: footers
    self reportFrameBody pageFooters: footers!  
pageHeight
        "Private - answer the page height which is an Integer in 0.1 mm units."
    ^pageHeight! 
trailingHeight: aNumber
        "Private - Do nothing."! 
prepareLine: ignore
        "Private - Pretend the receiver is a single
        line.  Do the real thing in reportLine:on:"
    ^1!
isPARTSRecordFramePart
    ^false!   
defaultFieldName
    ^'Report Text'! 
displayTop
        "Private - display the receiver along with the tick marks and numbers."
    | rect aPen windowTop place n |
    self setToCurrentSystem.
    aPen := self pen.
    rect := self rectangle.
    windowTop := rect top.
    tickMarks isNil ifTrue: [^nil].
    aPen
        setBackgroundMode: BackgroundMixTransparent;
        font: self font.
"Display ticks"
    tickMarks associationsDo: [:mark |
        n :=place := -1.
        [place < rect width] whileTrue: [
            aPen
                place: (place @ windowTop);
                line: ((place @ windowTop) down: mark value).
                place := (mark key * self pixelsPerHorizontalUnit * n) rounded .
            n := n + 1]].
"Display numbers"
    windowTop := windowTop down: ( aPen font height - 2 ).
    0 to: (self rectangle width // self pixelsPerHorizontalUnit)
        by: numberIncrements do: [:i |
        aPen
            displayText: i printString
            at:( ( i * self pixelsPerHorizontalUnit) rounded + 2 ) @ windowTop] !  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToReport:
            )
        separators: #(  )
        defaultItem: #aboutToReport:!   
printString
    ^'ColumnSummary <' , name , '>' , '  Function: [' , function asString , ']'! 
name: aString
        "Private - Set the field name for the column.
        This name is used to match against the data columns."
    name := aString! 
validate
        "Private - The PM window for the receiver was
         just created or recreated."
    self partsIfWindowsDo: [ ^super validate ].
    self performWhenValids.
    self partReportInitColorsFont.!  
function
        "Private - Answer a Symbol which is the function
      to be performed."
    ^reportField function!   
createGraphicsTool
        "Private - Create a GraphicsTool for the receiver."
	super createGraphicsTool.
	graphicsTool setMapMode.!   
turnToPreviousPageTop
        "Private - Display the previous page alinged at the top.  Do nothing
        if already displaying the first page."
    pageNumber > 1
        ifTrue: [
            self turnToPage: pageNumber - 1 scrolledToPageTop: true].!
turnToPage: requestedPage
        " Load the page, and display it."
    ^self pen turnToPage: requestedPage.!   
initialize
        "Private - "
    self reset.!
visitRow: ignore
        "Private - Ignore."!
location: aPoint
        "Private - Set location to a Point where x is the distance from the left
        edge of the paper, and y is the distance from the bottom of the
        last line of items.  All in 0.1 mm"
    ^reportField location: aPoint.! 
validate
        "Private - The PM window for the receiver was
         just created or recreated."
    self partsIfWindowsDo: [ ^super validate ].
    self performWhenValids.
    self partReportInitColorsFont.!  
setGroupValue: anObject
        "Set the value to be reported for the current group."
    ^self reportField groupSummary: anObject! 
reportLine: line on: aPen
        " Private - Iterate through all the report fields in one
        conceptual line."
    | lineDone lineTop lineBottom |
    lineDone := false.
    lineTop := lineBottom := aPen place.
    [lineDone] whileFalse: [
        lineDone := true.
        "give each item a chance to print all it has, stoping at
        either when finished (answer true) or running out of
        room (answer false)."
        line do: [:item |
           "each item is positioned relative to line top."
            aPen place: lineTop.
            lineDone := (item reportOn: aPen) and: [lineDone].
            item isPARTSHardPageBreakPart ifTrue: [^nil].
            lineBottom := lineBottom x @
                (aPen lowerOf: lineBottom and: aPen place) y].
            lineDone ifFalse: [
                self ranOutOfRoom: aPen.
                lineTop := lineBottom := aPen place.
                ].
        ].
    aPen place: lineBottom.!
initializeReport: aPen
    super initializeReport: aPen.
    groupBreaks do: [:break|
        break initializeReport: aPen]!   
goDown: logicalUnits
        "Private - Move the current position down by height logicalUnits."
    self place: (location down: logicalUnits)!  
justification
        "Private - Answer the justification as a Symbol"
    ^reportField justification!  
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#report)
        separators: #()
        defaultItem: #report! 
isPARTSPageBreakPart
    ^false! 
stDev
    self varN! 
addPageLimit: limit
        "Private - Add Integer limit to the OrderedCollection of end of page
        offsets into the file."
    pageLimits isNil
        ifTrue: [pageLimits := OrderedCollection new].
    pageLimits add: limit!  
isPageHeader
    ^isPageHeader!  
valueAsString
    ^self reportField valueAsString!   
defaultFieldName
        "Private - Answer a String."
    ^'Report Summary'!
formFeed
        "Private - Append the metafile for this page to the file.
        update the pointer data structure."
    | recordingGraphicsMedium |
    recordingGraphicsMedium := self pen recordingGraphicsMedium.
    recordingGraphicsMedium
        appendOnFile;
        formFeed.
    self erase.
    self pen goToLeftTop.!   
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."

    ^self class noScrollbarsFrameStyle! 
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    copy := super partMirrorCopyReal: aDict.
    copy
        orientation: (orientation partMirrorCopy: aDict).
    ^copy!  
function: aString
        "Private - Set the function of the receiver to aString."
    function := (self functionSelectors at:
        (self functionNames indexOf: aString)).
    self reset.!   
initializeReport: aPen
    "Private - Initialize the font with respect to
    the particular printer."
    | printerFont |
    self
        partsIfOS2Do: [
            printerFont := Font partsFromFont: reportPart font graphicsMedium: aPen graphicsMedium ]
        partsIfWindowsDo: [
            printerFont := Font fromLogicalFont: reportPart font logicalFont .
            printerFont
                pointSize: printerFont pointSize
                graphicsMedium: aPen graphicsMedium;
                makeFont ].
    font := printerFont.
    foreColor := reportPart foreColor.
    backColor := reportPart backColor.!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #( )
        separators: #( )
        defaultItem: nil!  
validate
        "Private - The PM window for the receiver was
         just created or recreated."
    self partsIfWindowsDo: [ ^super validate ].
    self performWhenValids.
    self partReportInitColorsFont.
    self updateSliders.
    children size ~= 0 ifTrue: [
        children do: [:each |
            each isApplicationWindow
                ifTrue: [ each validateShow ]
                ifFalse: [ each validate ] ] ]!   
leftMargin: aNumber
        "Private - Set the left margin in 0.1 mm."
    ^leftMargin := aNumber.! 
isPARTSReportStoredPicture
    ^false!   
varNMinus1
        "Private - The difference between two variances is in the
        final denominator."
    self varN!
displayTextNoChangePos: aString at: aPoint in: aRectangle
        "Display aString at aPoint bounded by aRectangle."
    | str |
    self
        partsIfOS2Do: [
            self displayText: aString
                at: aPoint in: aRectangle
                options: TextOptionOpaqueBackground
                adx: nil]
        partsIfWindowsDo: [
            str := aString.
            str size > 8000 ifTrue: [ "size must be < 32k"
                str := (str copyFrom: 1 to: 8000), '...etc...'].
            str := str asExternalString.
        (PARTSHostInterface hostGraphicsLibrary
            textOut: self handle
            x: aPoint x
            y: aPoint y
            text: str asParameter
            length: str size )
                ifFalse: [ ^self osError ] ].! 
evaluateGroupSummary
    ["for on: ZeroDivide"
    function = #average
        ifTrue: [groupSummary := groupSummary / groupCount ].
    (function = #varN
        or: [function = #stDevN])
        ifTrue: [
            groupSummary :=
                ((groupSummary at: #squaredSum) / groupCount ) -
                ((groupSummary at: #sum) / groupCount) squared].
    (function = #varNMinus1
        or: [function = #stDevNMinus1])
        ifTrue: [
            groupSummary :=
                ((groupSummary at: #squaredSum) / (groupCount - 1)) -
                ((groupSummary at: #sum) squared / ( groupCount * (groupCount - 1)))].
    (function = #stDevN
        or: [function == #stDevNMinus1])
        ifTrue: [
            groupSummary :=groupSummary sqrt]
    ] on: ZeroDivide do: [groupSummary := nil].! 
setToCentimeter
        "Private - Make a ruler measuering in Inches"
    self
        tickMarks: (Dictionary new
            at: 1 put: 7;
            at: 1/2 put: 5;
            yourself);
        numberIncrements: 5.!   
pageHeaders
    ^pageHeaders!
defaultForeColor
    ^Color black!   
orientation: aSymbol
        "Private - Set orientation to one of the four symbols:
        #(left top right bottom)."
    orientation := aSymbol.
    orientation == #left
        ifTrue: [self backColor: Color gray].!   
time
        "Private - Used to set the value to the current date
        before printing the value."
    self setValue: Time now asString.!   
pageDownButton
        "Private - Answer the drawn button which has an down arrow on it."
    self children do: [:child |
        child name = 'pageDownButton' ifTrue: [^child]].
    ^self children at: 3!  
spaceInPage: aPen
        "Private - Answer in logical units how much more
        room is available for regular fields, excluding margins
        and page footer."
    ^0 max: (aPen spaceInPage - self pageFooterBoundry )!
reportHeight
        " Private - Answer the height of the break in
        cm."
    | height |
    height := self location y.
    self reportLines do: [:line |
            height := height + line last location y].
    ^height + trailingHeight!
partMirrorCopyChildren: aDictionary to: copy
        " Private - mirror copy the report body but not the rulers - they
          are created at open time. "

    copy children: IdentityDictionary new.
    self reportFrameBody notNil ifTrue: [
        copy children at: self reportFrameBody id put:
            ( self reportFrameBody partMirrorCopyReal: aDictionary ) ]


!
emptyLines: aPen
        "Private - Answer the number of lines left in the page.
        Fields in page headers and footers do not allow wordwarp
        so they are always only one line."
    ^reportPart superWindow emptyLines: aPen!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#aboutToReport:
            )
        separators: #(  )
        defaultItem: #aboutToReport:! 
open
        "Private - create the children."
    super open.
    self children isEmpty ifFalse: [ ^self ]. "already created."
    self createChildren!   
totalLength
        "Private - Answer the total scrollable length of the document in pixels."
    ^1 max: (self pageHeightPixels
        * self numberOfPages
        - self rectangle height) rounded.!  
previousTabStop: aSubPane
        "Private - Answer the first subpane preceding from
        aSubPane which is a tabstop."
    | orderedChildren index |
    orderedChildren := self orderedChildren.
    index := orderedChildren indexOf: aSubPane.
    ^index > 1
        ifTrue: [(orderedChildren at: index - 1) previousTabStop]
        ifFalse: [self superWindow tabScope previousTabStop: self]!
initializeReport: aPen
    self currentColumn: 1.
    pageNumber := 1.
    aPen
        setBackgroundMode: BackgroundMixTransparent;
        setMapMode;
        goToLeftTop;
        goDown: self topMargin.
    self pageHeaders do: [:header|
        header initializeReport: aPen].
    self pageFooters do: [:footer|
        footer initializeReport: aPen].
    super initializeReport: aPen.!
runningSummary: anInteger
    runningSummary := anInteger!   
pageWidth
        "Private - answer the page width which is an Integer in 0.1 mm units."
    ^pageWidth!
partDirectEditFrameRectangle
        "Answer the rectangle representing the area
         for the user to direct-edit a part.  The rectangle
         is relative to the editor pane."
    | rect font |
    font := self font isNil
        ifTrue: [ SysFont ]
        ifFalse: [ self font ].
    rect := super partDirectEditFrameRectangle.
    rect height: ( rect height max: ( font height * 3 // 2 ) ).
    ^rect! 
reset
        " Private - Set the previous value to nil.  Used for
        supressing repeatitions."
    previousValue := nil! 
doNotRepeat
    ^reportField doNotRepeat!
unit
        "Private - Answer a symbol based on the OS/2 country settings."
    ^NationalLanguage measurementSystem = 1
        ifTrue: [#inch]
        ifFalse: [#centimeter]!  
isReportWriterNonvisualPart
        "Private - Answer if the receiver is one of the
        report writer non-visual parts."
    ^true!
display
        "Private - Display a blank background."
    self pen erase! 
resize: aRectangle
        "Private - Change the frame of the receiver pane
         to aRectangle."
    super resize: aRectangle.
    self setScrollRange.
    self updateSliders!  
isPARTSReportHorizontalPart
    ^true!   
wmVScroll: mp1 with: mp2
        "Private - Process the vertical scroll message."
    | w ctrlId slider |
    self
        partsIfOS2Do: [ "end of tracking , event not supported by scroll bar"
            mp2 highHalf = "SbSliderposition" 6
                ifTrue: [
                    slider := mp2 lowHalf + self rectangle height.
                    self thumbScrollTo: ( self topCorner x @ slider ).
                    ^nil ].
            ( ctrlId := mp1 lowHalf ) = "FidVertscroll" 32774 ifTrue: [ ^nil ].
            ( w := self childAtId: ctrlId ) isNil ifTrue: [ ^nil ].
            w syncControlEvent: mp2 highHalf with: mp2 lowHalf ]

        partsIfWindowsDo: [
            mp2 = 0 ifTrue: [ ^nil ].
           mp1 lowWord = "SbThumbposition" 4
               ifTrue: [ "end of tracking , event not supported by scroll bar"
                   slider := mp1 highWord.
                   self thumbScrollTo: (self topCorner x @ slider).
                  ^nil].
            ctrlId := PARTSHostInterface hostWindowLibrary getWindowLong: mp2 index: "GwlId"-12.
            ( w := self childAtId: ctrlId ) isNil ifTrue: [ ^nil ].
            w syncControlEvent: mp1 lowWord with: mp1 highWord ].
    ^nil !
fitsInPage: aRectangle pen: aPen
        "Private - Answer a Boolean if there is enough vertical space
        in the current page for aRectangle to fit.  Always answer true if aPen is
        located at the top of the page to avoid inifinte loop."
    ^((self reportFrameBody spaceInPage: aPen) > aRectangle height)
        or: [self reportFrameBody pageHeaderBoundry = aPen location y]! 
resetAfterGroupBreak
        "Private - Reset all the fields after a group break so
        that the fields which are not repeating their values will
        report their values for the first record of the next group."
    reportLines do: [:line |
        line do: [:item | item reset]].! 
initPARTSReportField
        "Private - PARTSReportField is the actual class which at the runtime
        generates the report."
    reportField := PARTSReportSummary new
            reportPart: self;
            name: 'FieldName';
            width: 300; "in 0.1mm"
            location: (0 @ 0); "0.1mm"
            wordWrap: true;
            rightJustify;
            decimalDigits: 2;
            function: 'Sum';
            yourself.
    ^reportField!   
reset
    "Do nothing"!  
realForeColor
        "Private - Answer answer a color."
    | foreColor |
    ^(foreColor := self foreColor) isNil
        ifTrue: [self defaultForeColor]
        ifFalse: [foreColor]!
unit
        "Private - Answer a symbol based on the OS/2 country settings."
    ^NationalLanguage measurementSystem = 1
        ifTrue: [#inch]
        ifFalse: [#centimeter]!  
groupSummary
    ^groupSummary!  
fitsInPage: aRectangle pen: aPen
        "Private - Answer a Boolean if there is enough vertical space
        in the current page for aRectangle to fit.  Always answer true
        in the page header and footers to end recursion."
    ^true!
fieldName
        "Private -"
    ^reportField name!
horizontalScrollBar: aScrollBar
        "Private - set the horizontal in the receiver to aScrollBar."
    horizontalScrollBar := aScrollBar!
graphicsToolClass
    ^PARTSRecordingPen!
leftMargin
    ^self reportFrameParent leftMargin!   
function
        "Private - Answer a String the name of the function."
    ^self functionNames at:
        (self functionSelectors indexOf: function)! 
height
        " Private  - Answer an Integer which is the height in 0.1mm"
    ^self reportField height!   
defaultBackColor
    ^Color white!   
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."

    ^self class noScrollbarsFrameStyle! 
groupValue
        "Answer the value to be reported for the current group."
    ^self reportField groupSummary! 
function: aString
        "Private - Set the function of the summary part to aString."
    reportField function: aString!   
minimum
    groupSummary isNil
        ifTrue: [groupSummary := value]
        ifFalse: [groupSummary := groupSummary min: value].
    runningSummary isNil
        ifTrue: [runningSummary := value]
        ifFalse: [runningSummary := runningSummary min: value]!   
objectAsString: object
        "Private - Answer a formatted String.  Use printFraction: if
        groupSummary is a number, answer '' if nil otherwise use
        #asString."
        "FixedDecimal used in RDBI part does not implement //
        so #printFraction: cannot be sent to it."
     | str pos decimalSeparator negative |
    ^object isString
        ifTrue: [object]
        ifFalse: [object isNumber
            ifTrue: [object class name = 'FixedDecimal'
                ifTrue: [object asFraction printFraction: decimalDigits]
                ifFalse: [
                    str := object printFraction: decimalDigits.
                    "Check if number is negative. "
                    (str at: 1) = $-
                        ifTrue:[
                            negative := true.
                            str := str copyFrom: 2 to: str size]
                        ifFalse:[ negative := false ].
                    decimalSeparator := NationalLanguage decimalSeparator first.
                    pos := str findLast:[:ch| ch = decimalSeparator] ifAbsent: [str size + 1].
                    pos > 1 ifTrue:[
                        pos - 3 to: 2 by: -3 do:[:i|
                            str := (str copyFrom: 1 to: i - 1),
                                NationalLanguage thousandsSeparator,
                                (str copyFrom: i  to: str size)]].
                    "Add the possible minus sign."
                    negative ifTrue: [ str:= '- ', str].
                    str]]
            ifFalse: [
                object isNil
                    ifTrue: ['']
                    ifFalse: [object asString]]]!   
resizeWindow
        "Private - Change the size of the window
         for the receiver."

    ^super resizeWindow!   
updateHorizontalSlider
        "Private - Do nothing."!  
pageFooters
    ^pageFooters!
foreColor: aColor
        "Set the foreground color of the receiver to aColor."
    ^storedPicture isNil
        ifTrue: [super foreColor: aColor]
        ifFalse: [storedPicture pen foreColor: aColor ].!  
pageFooters
    ^self reportFrameBody pageFooters!   
displayX
        "Private - If the receiver has more than one column, display
        the areas where should not contain a field in a different color."
    
"    aRectangle := self rectangle.
    aRectangle := (aRectangle leftTop right: (1 / self numberOfColumns * aRectangle width) rounded)
        extentFromLeftTop: aRectangle extent.
    self pen fill: aRectangle color: ClrPalegray
"! 
bottomMargin: aNumber
        "Private - Set the bottom margin in 0.1 mm."
    ^bottomMargin := aNumber.!   
amountToScrollUp
        "Private - Answer the number of
         pixels for vertical line scrolling."
    ^0 down: ( Display verticalPixelsPerMeter / 100 ) rounded!  
stringWidth: aString stream: aPen
    aString size = 0 ifTrue: [^0].
    aPen font: self font.
    ^aPen stringWidthOf: aString!   
currentColumn: anInteger
    self recordFrame currentColumn: anInteger!  
removePartRuntimeLibrary
        " Remove the runtime Report Writer parts library.
        Remove the workbench support library if it was installed. "

    self removeUpgradeChangeMaps.
    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).!
partSetGraphics: anIcon
    | oldIcon |

    oldIcon := self partIcon.
    anIcon
        origin: oldIcon origin copy;
        connection: oldIcon connection;
        showLabel: oldIcon showLabel;
        name: oldIcon name.
    self partIcon: anIcon.
    self isShrunk
        ifTrue: [
            anIcon parent: oldIcon parent.
            oldIcon parent
                removeIcon: oldIcon;
                addIcon: anIcon.
            anIcon parent invalidateRect: anIcon frame ].
    oldIcon release.!  
wordWrap: aBoolean
    reportField wordWrap: aBoolean.
    self isHandleOk
        ifTrue: [self invalidateRect: nil]! 
displayWith: aGraphicsTool
        "Private - Replay the whole report on aGraphicsTool."
    1 to: pageLimits size do: [:pageNumber |
        aGraphicsTool graphicsMedium formFeed.
        self playPageNumber: pageNumber on: aGraphicsTool]!  
partsFromLogicalFont: aPMFattrs graphicsMedium: aGraphicsMedium
        "Answer a Font for aGraphicsMedium build from FATTRS structure aPMFattrs .
         Use this method to set lMatch field to zero to use closest-matching
         font selection. "
    | aFont |
    aFont := self new.
    aFont  logicalFont: aPMFattrs.
    ( aGraphicsMedium isKindOf: Printer )
        ifTrue: [   "use closest-matching font selection"
            aFont logicalFont lMatch: 0 ].
    aFont makeFont: aGraphicsMedium.
    ^aFont! 
partHint
        "Answer a string which gives a brief description
        of the receiver part. "
    ^ 'ColumnSummary, Function: [' , reportField function asString , ']'!
ranOutOfRoom: aPen
        "Private - Ran out of room, either snake into a new column, or
        a new page."
    | oldPlace |
    oldPlace := aPen place.
    "Is there another column to snake into?"
    self currentColumn < self numberOfColumns
        ifTrue: ["Move to the next column.  "
            self currentColumn: self currentColumn + 1.
            aPen
                goToLeftTop;
                goRight: (self columnLeftEdge: aPen);
                goDown:  self reportFrameBody pageHeaderBoundry;
                goDown: self location y  ]
        ifFalse: [
            self breakPage: aPen.
            aPen
                goToLeftEdge;
                goRight: (self columnLeftEdge: aPen).].
    (aPen lowerOf: oldPlace and: aPen place ) = oldPlace
        ifFalse: [Error signal: 'Page height is too small for the report.'].!   
pixelRectangle: aPen
        "Private - Answer a rectangle which is based on
        physical coordinates."
    | pixelsPerLomertric |
    pixelsPerLomertric :=
        (aPen horizontalPixelsPerLometric
            @ aPen verticalPixelsPerLometric).
    ^((aPen place right: self location x ) * pixelsPerLomertric)
        rounded
        extentFromLeftTop: ((self width @ self height)
            * pixelsPerLomertric) rounded!
partCanHaveParent: aParent
        "Private - answer a boolean if aParent is acceptable."
    ^aParent isPARTSEditorPane!   
initialize
    super initialize.
    firePageFooters := firePageHeaders := true.!   
moveTopCornerBy: extent
        "Private - Do nothing.  Do not support scrolling
        while the Thumbtracking.  Do the scrolling when
        endTracking."!
leftMargin
        "Private - Answer the left margin in 0.1 mm."
    ^leftMargin!   
endPage: aPen
    " Private - Write the page footer."
    self reportFrameBody pageFooters do: [:pageFooter |
        pageFooter reportOn: aPen].! 
turnToPage: requestedPage
        "Display the page requestePage."
    self turnToPage: requestedPage scrolledToPageTop: true.! 
pageHeight: aNumber
        "Private - aNumber is in 0.1 mm."
    self framingBlock
        top: 0 stretched: false height: aNumber // 100 stretched: false.
    self
        resizeToRectangle: (self framingBlock
            scaleFrom: self superWindow rectangle)! 
verticalPosition
        "Private - Answer the top of the page break in pixels.  For
        page headers, it is measured from the top of the containing frame,
        bottom for the page footers."
    ^self isPageHeader
        ifTrue: [super verticalPosition]
        ifFalse: [(self frameRelativeRectangle top -
            self reportFrameBody rectangle bottom) abs]!
formFeed
        "Private - Display the first page soon as it is completed
        to give the user something to look at."
    pageNumber = 1
        ifTrue: [self turnToPage: 1].
    pageNumber := pageNumber + 1.!   
fill: aRectangle color: aColor
        "Fill aRectangle with aColor. aColor can be an RGB
        value or an index to the color palette."
    storedPicture isNil
        ifTrue: [super fill: aRectangle color: aColor.]
        ifFalse: [storedPicture pen fill: aRectangle color: aColor]!  
initPARTSReportField
        "PARTSReportField is the actual class which at the runtime
        generates the report."
    reportField := PARTSReportText new
            reportPart: self;
            setValue: '';
            width: 300; "in 0.1mm"
            location: (0 @ 0); "in 0.1mm"
            wordWrap: true;
            leftJustify;
            decimalDigits: 0;
            function: 'None';
            yourself.
    ^reportField!  
isPARTSReportStoredPicture
    ^true!
partAddedTo: anApplication
        " The receiver has just been added to anApplication.
        Add a wrapper for the report body, if it does not already have one. "
    super partAddedTo: anApplication.
    self reportFrameBody partWrapper isNil
        ifTrue: [
                self partWrapper application
                    addComponent: self reportFrameBody
                    preferredName: self reportFrameBody class name
                    parent: self
                    rectangle: (0 @ 0 extent: 1 @ 1)
                    helpInfo: ''
                    icon: nil.
                self reportFrameBody owner: self owner ]!  
value
    ^self reportField value!   
goUp: logicalUnits
        "Private - Move the current position up by height logicalUnits."
    self place: (location up: logicalUnits).!   
graphicsToolClass
        "Private - Answer the graphics tool class used by the receiver."
    ^PARTSRecordingPen!  
setValue: aReportWriter
        "Set the display contents of the report pane from the
        aReportWriter."
    aReportWriter reportToPen: self reportPen.!  
setValue: aData
    data := aData!   
pageRight
        "Private - the user clicked to the right of the slider. Scroll
        a page towards the right."
    self scrollHorizontal: self amountToPageLeft negated!  
numberIncrements: anInteger
    numberIncrements := anInteger!   
appendOnFile
        "Private - Append the contents of the metafile at the end of aFileName."
    | count buffer fileStream aFileName |
    self stopRecording.
    aFileName := self fileName.
    "Get the bits."
    self
        partsIfOS2Do: [
            ( count := PARTSHostInterface hostGraphicsLibrary
                queryMetaFileLength: hMetaFile ) = 0
                    ifTrue: [ self osWarning ]
            ]
        partsIfWindowsDo: [
            ( count := PARTSHostInterface hostGraphicsLibrary
                getMetaFileBitsEx: hMetaFile
                bufsize: nil
                pbuf: nil ) = 0
                    ifTrue: [ self osWarning ] ].
    buffer := ByteArray new: count.
    self
        partsIfOS2Do:
            [( PARTSHostInterface hostGraphicsLibrary
                queryMetaFileBits: hMetaFile
                offset: 0
                length: count
                buffer: buffer)
                    ifFalse: [ self osWarning ]]
        partsIfWindowsDo:
            [( PARTSHostInterface hostGraphicsLibrary
                getMetaFileBitsEx: hMetaFile
                bufsize: count
                pbuf: buffer ) = 0
                    ifTrue: [ self osWarning ] ].
    "Copy the bits to the end of the file."
    fileStream := File pathName: aFileName.
    (buffer size > fileStream file directory freeDiskSpace)
        ifTrue: [self error: 'Not enough disk space for temporary file, ' , fileName , '.'].
    fileStream
        setToEnd;
        putBytesFrom: buffer.
    self addPageLimit: fileStream size.
    fileStream close.!
prepareRunningReport: aStream
    | numberOfLines |
    self evaluateRunningSummary.
    reportPart triggerEvent: #aboutToFinalReport:
        withArguments: (Array with: runningSummary).
    numberOfLines := self breakIntoLines: self runningSummaryAsString output: aStream.
    self reset.
    ^numberOfLines.!
wmHScroll: mp1 with: mp2
        "Private - Process the vertical scroll message."
    | w ctrlId slider |
    self
        partsIfOS2Do: [
            mp2 highHalf = "SbSliderposition" 6
                ifTrue: [ "end of tracking , event not supported by scroll bar"
                    slider := mp2 lowHalf.
                    self scrollTopCornerTo: ( slider negated @ self topCorner y ).
                    ^nil ].
            ( ctrlId := mp1 lowHalf ) = "FidHorzscroll" 32775 ifTrue: [ ^nil ].
            ( w := self childAtId: ctrlId ) isNil ifTrue: [ ^nil ].
            w syncControlEvent: mp2 highHalf with: mp2 lowHalf ]

        partsIfWindowsDo: [
            mp2 = 0 ifTrue: [ ^nil ].
            mp1 lowWord = "SbThumbposition" 4
                ifTrue: [ "end of tracking , event not supported by scroll bar"
                    slider := mp1 highWord.
                    self scrollTopCornerTo: (slider negated @ self topCorner y).
                    ^nil ].
            ctrlId := PARTSHostInterface hostWindowLibrary getWindowLong: mp2 index: "GwlId"-12.
            ( w := self childAtId: ctrlId ) isNil ifTrue: [ ^nil ].
            w syncControlEvent: mp1 lowWord with: mp1 highWord ].
    ^nil!  
prepareLine: aStream

    ^1!   
isPARTSReportColumnPart
    ^true!   
isPARTSReportFramePart
    ^true!
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #displayReport:
            #turnToPage:
            #clear)
        separators: #(  )
        defaultItem: #displayReport:!   
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #()
        separators: #()
        defaultItem: nil!
reportToPen: aPen
        " Private - Generate a report and send it to aPen."
    [self reportFrameParent triggerEvent: #aboutToReport.
    aPen graphicsMedium startPrintJob: self documentName.
    aPen width: self reportWidth rounded.
    self initializeReport: aPen.
    self
        reportFieldsDo: [:item | item prepareLine: aPen]
        withPen: aPen.
    aPen graphicsMedium endPrintJob.
    self reportFrameParent triggerEvent: #reportFinished]
        on: Error
        do: [:e|
            (e isKindOf: ControlError) ifTrue: [^e pass].
            self
                reportFrameParent triggerEvent: #reportCanceled:
                withArguments: (Array with: e description)
                ifNotHandled: [MessageBox message: e description]]!   
initialize
    super initialize.
    location := 0 @ 0! 
defaultFrameCreationFlags
        "Private - Answer an Integer with appropriate FCF_ bits in it."
    ^WsNoByteAlign!   
justification: aSymbol
        "Private - Set the justification to aSymbol #(left center right)."
    reportField justification: aSymbol.
    self isValid ifTrue: [self invalidateRect: nil].!
reportField
        "PARTSReportField is the actual instance which at the runtime
        generates the report."
    ^reportField! 
evaluateFunction
    self perform: function! 
reportFrameBody
    ^self superWindow isPARTSReportStructure
        ifTrue: [self superWindow reportFrameBody]
        ifFalse: [nil]!
font: aFont
    ^font := aFont!  
reportPen
        "Answer the pen to be used for reporting."
    | pen |
    pen := self pen.
    pen retainGraphics.
    self erase.
    pen startPage.
    ^pen! 
reportFrameParent
    ^self superWindow isPARTSReportStructure
        ifTrue: [self superWindow reportFrameParent]
        ifFalse: [nil]!
createChildren
        "Private - A report display part has five subpanes: vertical and horizontal
        scrollbars, up and down page buttons and the one report display pane."
    | scrollBarWidth scrollBarHeight pageUp pageDown collection |
    scrollBarWidth := OperatingSystem getSystemValue: VScrollWidth.
    scrollBarHeight := OperatingSystem getSystemValue: HScrollHeight.
    pageUp := DrawnButton new.
    pageUp
        noTabStop;
        setName: 'pageUpButton';
        when: #clicked send: #turnToPreviousPageTop to: self;
        when: #drawItem send: #drawScrollTopTab: to: self with: pageUp;
        framingBlock:
            (PARTSFramer new
                scaleUnit: #pixel;
                bottom:  scrollBarHeight stretched: false height: scrollBarHeight stretched: false;
                right: -1 stretched: false width: scrollBarWidth  stretched: false;
                yourself).

    pageDown := DrawnButton new.
    pageDown
        noTabStop;
        setName: 'pageDownButton';
        when: #clicked send: #turnToNextPage to: self;
        when: #drawItem send: #drawScrollBottomTab: to: self with: pageDown;
        framingBlock:
            (PARTSFramer new
                scaleUnit: #pixel;
                bottom: 0 stretched: false height: scrollBarHeight stretched: false;
                right: -1 stretched: false width: scrollBarWidth stretched: false;
                yourself).

    displayPane := PARTSReportDisplayPane new.

    displayPane framingBlock:
        (PARTSFramer new
            scaleUnit: #centimeter;
            top: 0 stretched: false height: self pageHeight // 100 stretched: false;
            left: 0 stretched: false width: self pageWidth // 100  stretched: false;
            yourself).

    verticalScrollBar := ScrollBar vertical.
    verticalScrollBar
        noTabStop;
        setName: 'verticalScrollBar';
        backColor: Color gray;
        when: #gettingFocus send: #setFocus to: displayPane;
        when: #nextLine send: #scrollVertical: to: self with: self amountToScrollUp negated;
        when: #previousLine send: #scrollVertical: to: self with: self amountToScrollUp;
        when: #nextPage send: #pageDown to: self;
        when: #previousPage send: #pageUp to: self;
        framingBlock:
            (PARTSFramer new
                scaleUnit: #pixel;
                top: -1 stretched: false bottom: ( scrollBarHeight * 2 ) stretched: false;
                right: -1 stretched: false width: scrollBarWidth stretched: false;
                yourself).

    horizontalScrollBar := ScrollBar horizontal.
    horizontalScrollBar
        noTabStop;
        setName: 'horizontalScrollBar';
        backColor: Color gray;
        when: #gettingFocus send: #setFocus to: displayPane;
        when: #nextLine send: #scrollHorizontal: to: self with: self amountToScrollLeft negated;
        when: #previousLine send: #scrollHorizontal: to: self with: self amountToScrollLeft;
        when: #previousPage send: #pageLeft to: self;
        when: #nextPage send: #pageRight to: self;
        framingBlock:
            (PARTSFramer new
                scaleUnit: #pixel;
                bottom: -1 stretched: false height: scrollBarHeight stretched: false;
                left: -1 stretched: false right: (scrollBarWidth - 1) stretched: false;
                yourself).

    self
        addSubpane: verticalScrollBar;
        addSubpane: horizontalScrollBar;
        addSubpane: pageUp;
        addSubpane: pageDown;
        addSubpane: displayPane.

    collection := OrderedCollection new.
    collection
        add: verticalScrollBar;
        add: horizontalScrollBar;
        add: pageUp;
        add: pageDown;
        add: displayPane.
    self orderedChildren: collection! 
goToLeftTop
        "Private - Place the pen at the top left of the page ready
        for starting the page."
    | leftTop |
    self
        partsIfOS2Do: [
            leftTop := graphicsMedium isWindow
                ifTrue: [
                    self
                        convert: 0 @ graphicsMedium boundingBox height
                        from: 5 "CvtcDevice"
                        to: 1 "CvtcWorld" ]
                ifFalse: [ 0 @ height ].
            self place: leftTop ]
        partsIfWindowsDo: [ self place: 0 @ 0 ]!   
reportWidth
        "Private - Answer the width in system settings measurement units."
    ^reportWidth!
defaultFrameCreationFlags
        "Private - answer the default frame creation flags for
        the receiver."
    self partsVosOnly.
    ^WsPaneBorder | WsNoByteAlign! 
updateHorizontalSlider
        "Private - Update the horizontal slider position."
    horizontalScrollBar setValue: self topCorner x abs!   
displayLines: anIndexedCollection
    from: startIndex
    to: endIndex
    in: aRectangle
    justification: justification
    foreColor: newForeColor
    backColor: newBackColor
        "Display Strings in anIndexedCollection starting at startIndex and
        ending at endIndex, clipped within the bounds of aRectangle."

    | charHeight horizontalAlignment  horizontalAnchor oldForeColor oldBackColor origin
      anchor string basePointY fPrinter |
    charHeight := self font lineSpacing.
    fPrinter := self partsIfOS2Do: [ graphicsMedium isKindOf: Printer ] partsIfWindowsDo: [ false ].
    horizontalAlignment := justification = #left
        ifTrue: [TextAlignLeft]
        ifFalse: [justification = #right
            ifTrue: [TextAlignRight]
            ifFalse: [TextAlignCenter]].
    fPrinter ifFalse: [ self setTextAlign: horizontalAlignment  | TextAlignTop ].
    horizontalAnchor := justification = #left
        ifTrue: [aRectangle left]
        ifFalse: [justification = #right
            ifTrue: [aRectangle right]
            ifFalse: [aRectangle left + aRectangle right // 2]].
    newForeColor notNil
        ifTrue: [
            oldForeColor := self foreColor.
            self foreColor: newForeColor].
    newBackColor notNil
        ifTrue: [
            oldBackColor := self backColor.
            self backColor: newBackColor].
    startIndex to: endIndex do: [ :i |
        string := anIndexedCollection at: i.
        anchor := fPrinter
            ifTrue: [
                basePointY := font basePoint y.
                justification = #left
                    ifTrue: [ aRectangle left @ ( aRectangle top down: basePointY ) ]
                    ifFalse: [ justification = #right
                        ifTrue: [ ( aRectangle right - ( self stringWidthOf: string ) ) @ ( aRectangle top down: basePointY ) ]
                        ifFalse: [ ( aRectangle center x - ( ( self stringWidthOf: string ) // 2 ) ) @ ( aRectangle top down: basePointY ) ] ] ]
            ifFalse: [ horizontalAnchor @ aRectangle top ].
        storedPicture isNil
            ifTrue: [
                self
                    font: self font;
                    displayTextNoChangePos: string
                        at: ( origin := anchor x @ ( anchor y down: ( i - startIndex * charHeight ) ) )
                        in: ( Rectangle leftTop: origin extent: ( aRectangle width @ charHeight ) )]
            ifFalse: [
                storedPicture pen font: self font.
                self displayTextNoChangePos: string
                    at: ( origin := anchor x @ ( anchor y down: ( i - startIndex * charHeight ) ) )
                    in: ( Rectangle leftTop: origin extent: ( aRectangle width @ charHeight ) )
                    using: storedPicture pen.].
         ].
    newForeColor notNil
        ifTrue: [ self foreColor: oldForeColor].
    newBackColor notNil
        ifTrue: [ self backColor: oldBackColor].

    self place: aRectangle rightBottom.
! 
wordWrap
    ^reportField wordWrap!  
pageNumber
        "Private - Used to set the value to the current date
        before printing the value."
    self setValue: reportPart reportFrameBody pageNumber.! 
printReport: aReportWriter
        "Get info from the user via a print dialog and then
        print the content of aReportWriter on the selected printer."
    | printDialog hDCPrinter |
    aReportWriter isNil
        ifTrue: [^MessageBox warning: '''printReport:'' is missing an argument.'].
    printDialog := PrintDialog new.
    self partsIfWindowsDo: [
        printDialog noSelection; noPages].
    printDialog open.
    self partsIfWindowsDo: [
        hDCPrinter := printDialog hDCPrinter.
        (  hDCPrinter = 0 or: [ hDCPrinter isNil ] )    "workaround for base bug. hDCPrinter may be zero or nil"
            ifTrue: [ ^ nil  ] ].
    printDialog printer isNil ifTrue: [ ^nil ].
    printer := PARTSReportPrinter fromPrinter: printDialog printer.
    self
        partsIfOS2Do: [
            printer
                collate: false;
                copies: 1]
        partsIfWindowsDo: [
        printer
            copies: printDialog copies;
            collate: printDialog collate].
    aReportWriter isPARTSReportStoredPicture
        ifTrue: [ "report has already been generated."
            printer
                reprintOn: aReportWriter
                copies: printDialog copies
                collate: printDialog collate]
        ifFalse: [
             "Fork the printing, so:
            1. User can go on.
            2. The abort printing dialog can function."
            [aReportWriter reportToPen: printer pen]
                forkAt: 3]!
columnLeftEdge: aPen
    | availableWidth x |
    availableWidth := aPen width
        - (self leftMargin + self rightMargin).
    ^aPen isStream
        ifTrue: [0]
        ifFalse: [
            x := (availableWidth * (self currentColumn - 1) // self numberOfColumns).
            x right: self leftMargin]! 
initializeReport: aPen
    "Private - reset to clear the previousValue."
    super initializeReport: aPen.
    self reset.!
resizeWithNewPARTSFramer
        "Private - resize the receiver after its framer has been changed."
    self
        resizeToRectangle: (self framingBlock
            scaleFrom: self superWindow rectangle)!
trailingHeight: aNumber
        "Private - Set the distance from the last item in the receiver
        to the end of the receiver. i.e. the empty space at the bottom
        in cm."
    trailingHeight := aNumber!  
displayLines: anIndexedCollection from: startIndex to: endIndex in: aRectangle justification: justification
        "Private - display Strings in anIndexedCollection starting at startIndex and
        ending at endIndex, clipped within the bounds of aRectangle."
    | charHeight horizontalAnchor horizontalAlignment origin |
    charHeight := self font lineSpacing.
    horizontalAlignment := justification = #left
        ifTrue: [TextAlignLeft]
        ifFalse: [justification = #right
            ifTrue: [TextAlignRight]
            ifFalse: [TextAlignCenter]].
    self setTextAlign: horizontalAlignment  | TextAlignTop.
    horizontalAnchor := justification = #left
        ifTrue: [aRectangle left]
        ifFalse: [justification = #right
            ifTrue: [aRectangle right]
            ifFalse: [aRectangle left + aRectangle right // 2]].
    startIndex to: endIndex do: [ :i |
        self
            partsIfOS2Do: [
                self
                    displayText: ( anIndexedCollection at: i )
                        at: ( origin := horizontalAnchor @ ( aRectangle top down: ( i - 1 * charHeight ) ) )
                        in: ( anIndexedCollection size =1
                            ifTrue: [ aRectangle ]
                            ifFalse: [ Rectangle leftTop: origin extent: aRectangle width @ charHeight ] )
                        options: TextOptionOpaqueBackground
                        adx: nil ]
            partsIfWindowsDo: [
                self
                    displayText: ( anIndexedCollection at: i  )
                        at: horizontalAnchor @ ( aRectangle top down: ( i - 1 * charHeight ) ) ]
         ].! 
reportLines
    ^reportLines!
isPARTSReportFrameBody
    ^false!   
startPrintJob: jobTitle
    | abortDialogFileName |
    abortDialogFileName := 'RWPAbort.par'.
    super startPrintJob: jobTitle.
    self graphicsTool setMapMode.
    self initExtent.
    (collate and: [copies > 1])
        ifTrue: [self pen recordingGraphicsMedium startPrintJob: jobTitle].
    [abortDialog := PARTSApplication fromFile:  abortDialogFileName.]
        on: Error do: [nil].
    abortDialog isNil
        ifTrue: [Error signal: 'Cannot find ' , abortDialogFileName , ' in the EXE directory.'].
    abortDialog when: #canceled send: #abortPrintJob to: self.
    abortDialog openDialog: jobTitle.! 
sum
    groupSummary := groupSummary + value.
    runningSummary := runningSummary + value.!
updateSliders
        "Private - Update the slider boxes in the scrollbars."
    handle = NullHandle ifTrue: [^self].
    self updateVerticalSlider.
    self updateHorizontalSlider! 
initExtent
        "Private - init the width and height of GraphicsTool for the receiver."
    | hostGraphicsLibrary |
    self partsIfOS2Do: [ ^super initExtent ].
    hostGraphicsLibrary := PARTSHostInterface hostGraphicsLibrary.
    graphicsTool        "get extent in centimeters"
        width: ( hostGraphicsLibrary getDeviceCaps: deviceContext index: "Horzsize" 4 ) * 10;
        height: ( hostGraphicsLibrary getDeviceCaps: deviceContext index: "Vertsize" 6 ) * 10!   
wmNchittest: wParam with: lParam
        "Private - Process Non-client mouse hit test message."
    self partsVwOnly.  " only used on Win32 "
    ^TransparentToMouse! 
reportRectangle
        "Private - Answer a rectangle which is in the logical
        scale of the report."
    | rect framer |
    self
        partsIfOS2Do: [
            rect := self rectangle.
            framer := self framingBlock.
            ^(rect origin up: 0) extent:
                ( ( ( framer pixelToScaleUnitHorizontal: rect width ) * 100 ) @
                ( ( framer pixelToScaleUnitVertical: rect height - 1 ) * 100 ) )  truncated ]
        partsIfWindowsDo: [ ^super reportRectangle ]! 
function: aString
        "Private - Set the function of the receiver to aString."
    function := (self functionSelectors at:
        (self functionNames indexOf: aString))! 
getGraphicsTool
        "Private - Create a GraphicsTool for the receiver."
    super getGraphicsTool.
    self partsIfWindowsDo: [ graphicsTool setMapMode ]! 
initialize
    super initialize.
    documentName := 'PARTS Report Writer'.
    self backColor: Color white!   
registerUpgradeChangeMaps
        " Private - register upgrade mapping specifications for
        the Report Writer parts. "

    " register PWW 2.0 upgrade mapping specifications "
    self upgradeMapsForLoadingPW20 do: [ :aChangeMap |
        PARTSFile
            registerChangeMap: aChangeMap
            forVersion: 'PARTS/Win32 2.0' ].!
verticalPixelsPerLometric
    ^graphicsMedium verticalPixelsPerMeter / 10000!
verticalPixelsPerMeter
    ^Display verticalPixelsPerMeter!  
rectangleFilled: aRect
        "Draw aRect. The interior of aRect is filled with
         the current color."
    storedPicture isNil
        ifTrue: [super rectangleFilled: aRect]
        ifFalse: [storedPicture pen rectangleFilled: aRect].!   
reportFrameBody: aReportFrameBody
        "Private - Answer the subpane which contains all the report items,
        or nil if it does not exist yet."
    self propertyAt: #reportFrameBody put: aReportFrameBody!
topMargin
        "Private - Answer the top margin in 0.1 mm."
    ^topMargin!  
fieldsToBreakOn
    | answer |
    answer := OrderedCollection new.
    self recordFrame children do: [:field |
        field isPARTSReportColumnPart ifTrue: [answer add: field fieldName]].
    ^answer!   
startPage
        "Private - Start the page."
    self goToLeftTop! 
name
        "Private - Answer the a String which is the field name for the
        column.  This name is used to match against the data columns."
    ^name!  
startPrintJob: aTitle
    self pen recordingGraphicsMedium startPrintJob: aTitle.!   
reportEverytime
        "Private - Answer if the part is to report every time it geographically is
        encountered (vs. conditional reporting at special times and places)"
    ^false!
addSubpane: aPane
        "Private - make sure there is only one reportFrameBody."
    aPane isPARTSReportFrameBody
        ifTrue: [
            self reportFrameBody isNil
                ifTrue: [ self reportFrameBody: aPane ]
                ifFalse: [ children removeKey: self reportFrameBody id ]].
    super addSubpane: aPane!   
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#aboutToReport:
            )
        separators: #(  )
        defaultItem: #aboutToReport:! 
doNotRepeat
        "Private - Answer a Boolean to report if the value of the
        current row is the same as the preivous row."
    ^doNotRepeat!  
report
        "Force a group to be created here."
    writeReport := true.!
place
    ^self locationVar! 
clear
        "Private - Clear the pane so a new report can be created."
    self pen notNil
        ifTrue: [self pen clear]! 
isPARTSReportField
    ^true!
pageDown
        "Private -  the user clicked below the slider. Scroll
        a page towards bottom."
    self scrollVertical: self amountToPageUp negated!   
defaultStyle
        "Private - The vertical scroll bar is created from Smalltalk to
        make a little shorter so there will be enough room for the
        the paging buttons."
    ^WsClipChildren | WsChildWindow | WsInitiallyVisible | WsPaneBorder! 
isPARTSReportFramePart
    ^false!   
isPARTSColumnSummaryPart
    ^false! 
partMirrorCopyChildren: aDictionary to: copy
        " Private - do nothing. Children are created at open time. "!   
reportEverytime
        "Private - Answer if the part is to report every time it geographically is
        encountered (vs. conditional reporting at special times and places)"
    ^true! 
reportPen
        "Private - answer an instance of PARTSRecordingPen, which
        causes a meta file to be created.  Do this at the start of a report."
    pageNumber := 1.
    ^self displayPane reportPen!   
prepareRow: row stream: aPen
        "Private - Pretend the receiver is a single
        line.  Do the real thing in reportLine:on:"
    ^1!   
runningValue
        "Answer the value to be reported for the whole report."
    ^self reportField runningSummary!  
groupSummary: anInteger
    groupSummary := anInteger!   
unit
        "Private - Answer a symbol based on the OS/2 country settings."
    ^NationalLanguage measurementSystem = 1
        ifTrue: [#inch]
        ifFalse: [#centimeter]!  
prepareRunningReport: ignore
        "Private - Ignore."!
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToReport:
            )
        separators: #(  )
        defaultItem: #aboutToReport:!   
name: aString
    name := aString!   
reportOn: aPen
    | rectangle lastLine oldLoc |
    currentLineIndex isPoint
        ifTrue: [
            "Future refinement, if going down causes a page break,
            remember how much further need to go down on the next page."
            oldLoc := currentLineIndex x @ currentLineIndex y.
            aPen goDown: currentLineIndex y.
            currentLineIndex := 0].
    aPen font: self font.
    lastLine := lines size min: currentLineIndex + (self emptyLines: aPen).
    rectangle := (aPen place right: self location x)
        extentFromLeftTop: width @ (lastLine - currentLineIndex * self font lineSpacing).
    backColor notNil
        ifTrue: [
            aPen fill: rectangle color: backColor].
    aPen
        displayLines: lines
        from:  currentLineIndex + 1
        to: lastLine
        in: rectangle
        justification: self justification
        foreColor: foreColor
        backColor: backColor.
    currentLineIndex := lastLine.
    currentLineIndex = lines size
        ifTrue: [  ^true ]
        ifFalse: [ currentLineIndex := oldLoc. ^false ]!   
isPARTSHardPageBreakPart
    ^false! 
displayLines: anIndexedCollection in: aRectangle justification: justification
        "Private - display anIndexedCollection of Strings clipped within
        the bounds of aRectangle."
    self
        displayLines: anIndexedCollection
        from: 1
        to: anIndexedCollection size
        in: aRectangle
        justification: justification!
setToCurrentSystem
        "Private - Make a ruler measuering in Inches"
    self unit == #inch
        ifTrue: [^self setToInch].
    self unit == #centimeter
        ifTrue: [^self setToCentimeter].!
initialize
        "Private - ."
    super initialize.
    self initPARTSReportField.
    self setValue: self defaultFieldName!   
formFeed
        "Private - Need to set the map mode after feeding
        new page."
    self checkAbortPrinting.
    copies > 1 ifTrue: [self additionalCopies].
    super formFeed.
    abortDialog notNil
        ifTrue: [ abortDialog increment ]!   
rightMargin
        "Private - Answer the right margin in 0.1 mm."
    ^rightMargin!
scrollTopCornerTo: aPoint
    | thumbedPage |
    thumbedPage := aPoint y abs // self pageHeightPixels + 1.
    thumbedPage ~= pageNumber
        ifTrue: [self turnToPage: thumbedPage].
    self scrollTopCornerInCurrentPageTo: aPoint x @ (aPoint y abs \\ self pageHeightPixels) negated.
    self updateSliders.! 
turnToPage: requestedPage scrolledToPageTop: alignTop
        "Private - Display the page requestePage.  Aling the top of the
        page to the top of the pane if alignTop is true."

    pageNumber := requestedPage isNil
        ifTrue: [1]
        ifFalse: [(1 max: requestedPage asInteger) min: self numberOfPages].
    self displayPane turnToPage: pageNumber.
    self scrollTopCornerInCurrentPageTo: topCorner x @ (
        alignTop
            ifTrue: [self rectangle top]
            ifFalse: [
                self
                    partsIfOS2Do: [ topCorner y - ( self height - self displayPane height ) ]
                    partsIfWindowsDo: [ self height - self displayPane height ] ] ).
    self updateVerticalSlider.
    self setPageButtonEnableState!  
visitRow: row
        "Private - Sent to objects inside a TableBreak for each row.  Update
        your data from the row."
    value := row at: name ifAbsent: [0].
    value isNumber ifFalse: [value := value asNumber].
    reportPart triggerEvent: #aboutToEvaluate: withArguments: (Array with: value).
    self perform: function!  
runningSummary
    ^runningSummary!  
displayText: aString in: aRectangle wordWrap: wordWrapBoolean justification: justification
        "Display aString within the bounds of aRectangle; if
        wordWrapBoolean is true, text will be word wrapped, otherwise
        it will just be clipped within aRectangle."
    | lines |
    lines := self
        asArrayOfLines: aString
        in: aRectangle
        wordWrap: wordWrapBoolean.
    self displayLines: lines in: aRectangle justification: justification!
pageHeight
    ^self superWindow pageHeight! 
function: aString
        "Private - Do nothing, columns have no 'function' to support."!
isPARTSReportTextPart
    ^false!
name
    ^name!  
reportRectangle
        "Private - Answer a rectangle which is in the logical
        scale of the report."
    | rect framer |
    rect := self rectangle.
    framer := self framingBlock.
    "The following line is in fact platform independent."
    ^(rect origin up: 0) extent:
        (((framer pixelToScaleUnitHorizontal: rect width ) * 100) @
        ((framer pixelToScaleUnitVertical: rect height) * 100))  truncated!  
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            )
        separators: #(  )
        defaultItem: nil!
haveRunningReport
    haveRunningReport isNil ifTrue: [haveRunningReport := true].
    ^haveRunningReport!  
realBackColor
        "Private - Answer answer a color."
    | backColor |
    ^(backColor := self backColor) isNil
        ifTrue: [self defaultBackColor]
        ifFalse: [backColor]!
isPARTSColumnSummaryPart
    ^true!  
display
        "Private - display the receiver's contents."
    orientation = #left
        ifTrue: [self displayLeft].
    orientation = #top
        ifTrue: [self displayTop].
    orientation = #right
        ifTrue: [self displayRight]!   
doNotRepeat: aBoolean
    ^reportField doNotRepeat: aBoolean!
count
    groupSummary := groupSummary + 1.
    runningSummary := runningSummary + 1.!  
topMargin
        "Private - Answer the top margin in 0.1 mm."
    ^self superWindow topMargin! 
reportFrameBody
    ^self superWindow isPARTSReportStructure
        ifTrue: [self superWindow reportFrameBody]
        ifFalse: [nil]!
maximum
    groupSummary isNil
        ifTrue: [groupSummary := value]
        ifFalse: [groupSummary := groupSummary max: value].
    runningSummary isNil
        ifTrue: [runningSummary := value]
        ifFalse: [runningSummary := runningSummary max: value]!   
turnToPage: requestedPage
        "Turn to the page nearest to the requestedPage which exists.
        Answer the actual page number."
    ^storedPicture notNil
        ifTrue: [storedPicture playPageNumber: requestedPage on: self]
        ifFalse: [nil]!  
topMargin: aNumber
        "Private - Set the top margin in 0.1 mm."
    ^topMargin := aNumber.!
reportOn: aPen
        "Private - Generate a report onto aPen."
    | firstRow |
    self triggerEvent: #aboutToReport:
        withArguments: (Array with: data).
    firstRow := true.
    self currentColumn: 1.
    aPen goDown: self location y.
    data do: [:row |
    "First see if there is a need for break in the groups."
        self triggerEvent: #aboutToReportRecord:
            withArguments: (Array with: row).
        groupBreaks do: [:break |
            break iterateRow: row stream: aPen].
        "finish the row."
         firstRow
            ifTrue: [firstRow := false]
            ifFalse: [aPen goDown: trailingHeight].
        "Display the current row."
        self
            reportFieldsDo: [:item | item prepareRow: row stream: aPen]
            withPen: aPen].
    "Print the last set of subtotals."
    groupBreaks do: [:break |
        break printIfBreakTime: Dictionary new stream: aPen].
    "finish the last row."
     aPen goDown: trailingHeight.
    "Finally, print the running summary"
    groupBreaks do: [:break |
        break haveRunningReport
            ifTrue: [break reportRunningReport: aPen]].
    ^true   "the report for the table is done."!   
validate
        "Private - create or recreate the receiver."
    
    super validate.
    topCorner := self rectangle leftTop.
    self setPageButtonEnableState!   
setMapMode
        "Private - Set the map mode to a logical 0.1 mm"
    self
        partsIfOS2Do: [
            self
                setModelScale:
                    self horizontalPixelsPerLometric @ self verticalPixelsPerLometric
                option: "TransformReplace" 0.
            ( storedPicture notNil and: [storedPicture pen notNil])
                ifTrue: [
                    storedPicture pen
                        setModelScale:
                            self horizontalPixelsPerLometric @ self verticalPixelsPerLometric
                        option: "TransformReplace" 0.]
                ]
        partsIfWindowsDo: [
            self
                setMapMode: "MmAnisotropic" 8;
                setWindowExt: 1000 @ 1000;
                setViewportExt:
                    ((graphicsMedium horizontalPixelsPerMeter / 10 )
                    @ (graphicsMedium verticalPixelsPerMeter / 10 )) rounded.
            storedPicture isNil
                ifFalse: [
                    storedPicture pen
                    setMapMode: "MmAnisotropic" 8;
                    setWindowExt: 1000 @ 1000;
                    setViewportExt:
                        ((graphicsMedium horizontalPixelsPerMeter / 10 )
                        @ (graphicsMedium verticalPixelsPerMeter / 10 )) rounded]
            ]!   
recordFrame
    ^self superWindow.!  
function: aString
        "Private - Set the function of the text part to aString."
    reportField function: aString!  
setFocus
        "The receiver is never meant to have the focus, set the
        focus on the parent."
    ^self superWindow setFocus! 
partMirrorCopyReal: aDict
        " Private - add a mirror copy of the receiver
        to aDict.  Answer the copy. "
    | copy |
    self partIsEditing
        ifTrue: [self captureReportItems.].
    copy := super partMirrorCopyReal: aDict.
    copy
        reportLines: (reportLines partMirrorCopy: aDict);
        location: (location partMirrorCopy: aDict).
    ^copy!
stDevNMinus1
        "Private - The difference between two stdev's is in the final
        denominator."
    self varN!
initializeReport: aPen
        "Private - override super class because we don't need
          to set font for a report horizontal part."
    foreColor := reportPart foreColor.
    backColor := reportPart backColor.!  
reportWidth: aNumber
        "Private - Set the width in system settings measurement units."
    ^reportWidth := aNumber!   
resetGroupSummary
    groupCount := 0.
    groupSummary := 0.
    (function == #minimum
        or: [function == #maximum])
        ifTrue: [groupSummary := nil].
    (function == #varN
        or: [function == #stDevN
        or: [function == #varNMinus1
        or: [function == #stDevNMinus1]]])
        ifTrue: [
            groupSummary := IdentityDictionary new
                at: #squaredSum put: 0;
                at: #sum put: 0;
                yourself]! 
topMargin
    ^self reportFrameParent topMargin! 
standardDeviation
    self variance! 
reportOnFirstPage
        "Private - Answer a Boolean."
    ^reportOnFirstPage! 
automaticFunction
        "Private - Answer a Symbol which is the function
      to be performed."
    ^reportField automaticFunction! 
isPARTSTransientPart
        "Answer whether the receiver is a part which exists
        only while its containing application is being edited
        in a PARTS Workbench. "

    ^true!   
pageWidth
    ^self superWindow pageWidth!   
displayTextNoChangePos: aString at: aPoint in: aRectangle using: aDifferentPen
        "Display aString at aPoint, and do not change the position afterwards.
        This method really belongs in a different subclass of Pen, but do
        not want to create a new class for this one method only, so pass in
        the aDifferentPen and do it here."
    | str |
    self
        partsIfOS2Do: [
            aDifferentPen
                displayText: aString
                    at: aPoint in: aRectangle
                    options: TextOptionOpaqueBackground
                    adx: nil]
        partsIfWindowsDo: [
            str := aString.
            str size > 8000 ifTrue: [ "size must be < 32k"
            str := (str copyFrom: 1 to: 8000), '...etc...'].
            str := str asExternalString.

            (PARTSHostInterface hostGraphicsLibrary
                textOut: aDifferentPen handle
                x: aPoint x
                y: aPoint y
                text: str asParameter
                length: str size )
                    ifFalse: [ ^self osError ] .
        ]! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToReport:
            #aboutToReportRecord:
            )
        separators: #(  )
        defaultItem: #aboutToReport:!
partIsSelectable
        "Answer whether the receiver is selectable in a PARTS Workbench."

    ^false!
fileName: aString
        "Private - Set name of the temporary file storing the metafile."
    fileName := aString! 
none
        "Private - Do nothing.  This function is used when the user
        is providing the function via a script."!  
verticalScrollBar
        "Private - Answer an instance of ScrollBar for the vertical scrollbar.
        The vertical scroll bar is created using class ScrollBar to gain control
        to make room for the page buttons."
    ^verticalScrollBar! 
location: aPoint
        "Private - Answer a Point where x is the distance from the left
        edge of the paper, and y is the distance from the bottom of the
        last line of items.  All in 0.1 mm"
    location := aPoint rounded!  
isPARTSReportColumnPart
    ^false!  
displayCaption
        "Private - Display captions for the neighboring
        report frame parts."
    | aPen captionExtent |
    aPen := self pen.
    aPen
        fill: aPen backColor;
        font: self font.
    captionExtent := self rectangle width - 1 @ self font height.
    self superWindow reportFrameBody frameParts do: [:frame |
        frame displayCaption: aPen
"        captionStrings := frame caption.
        captionVerticalPosition := frame captionVeritcalPosition.
        captionStrings do: [:string |
            captionVerticalPosition := captionVerticalPosition down: captionExtent y.
            aPen
                displayText: string
                in: ((0 @ captionVerticalPosition)
                    extentFromLeftTop: captionExtent )
                options:  DtRight | DtSingleline  | DtNoclip]"]!
breakPage: aPen
    " Private - Write the page footer + do a formFeed,
    and write the page header."
    self endPage: aPen.
    aPen graphicsMedium formFeed.
    self startPage: aPen.!  
reportFrameBody
    ^self!   
backColor
        "Private - Always answer the same color so the color cannot be
        changed from the common property dialog of the multiple selection."
    ^Color white! 
initialize
    super initialize.
    self setValue: OrderedCollection new.! 
isPARTSRecordFramePart
    ^true!
displayReport: aReportWriter
        "Set the display contents of the report pane from the
        aReportWriter."
    aReportWriter isNil
        ifTrue: [^MessageBox warning: '''displayReport:'' is missing an argument.'].
    CursorManager execute changeFor:
        [aReportWriter reportToPen: self reportPen.]!  
resetRunningSummary
    runningCount := 0.
    runningSummary := 0.
    (function == #minimum
        or: [function == #maximum])
        ifTrue: [runningSummary := nil].
    (function == #varN
        or: [function == #stDevN
        or: [function == #varNMinus1
        or: [function == #stDevNMinus1]]])
        ifTrue: [
            runningSummary := IdentityDictionary new
                at: #squaredSum put: 0;
                at: #sum put: 0;
                yourself]!   
justification: aSymbol
        "Private - Set the justification to aSymbol #(left center right)."
    justification := aSymbol! 
scrollingRectangle
        "Private - Answer the rectangle defining the region
        which can contain graphcis."
    ^rectangle leftTop
        extentFromLeftTop:
            (self pageWidth @ self pageHeight) rounded!
printString
    ^'ReportText [' ,
            (function == #none
                ifTrue: ['''', value , '''']
                ifFalse: [function asString])
            , '] '!  
reportFrameParent
    ^self! 
foreColor
        "Do not inherit color from parent window."
    ^self propertyAt: #foreColor!  
tickMarks: aDictionary
        "tickMarks is a Dictionary where the keys are tick increments
        (Fractions) and values are tick heights (Integer).  For example
        key: 1/10 value: 10 and unit = #centimeter means place a tick mark
        10 pixels high at every milimeter."
    tickMarks := aDictionary!
pageUp
        "Private -  the user clicked above the slider. Scroll
        a page towards the top."
    self scrollVertical: self amountToPageUp!
fromPrinter: aPrinter
        "Private - "
    ^self
        partsIfOS2Do: [
            PARTSReportPrinter new
                driverData: aPrinter driverData;
                name: aPrinter name;
                yourself]
        partsIfWindowsDo: [
            PARTSReportPrinter new
                deviceContext:  aPrinter deviceContext;
                                 getGraphicsTool;
                                 initExtent;
                yourself]! 
installPartRuntimeLibrary
        " Install the runtime Report Writer parts library.
        Load the workbench support library if appropriate. "

    self registerUpgradeChangeMaps.
    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'Report Writer Parts'.! 
retainGraphics
        "Private - Make it so that the pen remembers its graphics."
    storedPicture notNil
        ifTrue: [storedPicture clear; startRecording ]
        ifFalse: [storedPicture := PARTSReportStoredPicture new].! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToReport
            #aboutToExamine:
            )
        separators: #(  )
        defaultItem: #aboutToReport!   
reset
    pageNumber := 0!   
prepareRow: row stream: aStream
        "Private - Break the new value into a set of lines.  Answer
        the number of lines."
    value := row at: name ifAbsent: [''].
    reportPart triggerEvent: #aboutToReport:
        withArguments: (Array with: value).
    (value = previousValue
        and: [self doNotRepeat])
        ifTrue: [value := '']
        ifFalse: [previousValue := value].
    ^self breakIntoLines: self valueAsString output: aStream! 
line: aPoint
    storedPicture isNil
        ifTrue: [super line: aPoint]
        ifFalse: [storedPicture pen line: aPoint].!  
getGraphicsTool
        "Private - Initialize an empty text tool."
    ^self graphicsToolClass for: nil medium: self!   
width
        "Private - Answer the width in 0.1 mm."
    ^width!   
endPrintJob
        "Private - "
    self turnToPage: 1.
    self setScrollRange.! 
thumbScrollTo: aPoint
    | thumbedPage |
    thumbedPage := aPoint y abs // self pageHeightPixels + 1.
    thumbedPage ~= pageNumber
        ifTrue: [self turnToPage: thumbedPage].
    self scrollTopCornerInCurrentPageTo: aPoint x @ ( 0 down: (aPoint y abs \\ self pageHeightPixels) negated).
    "self updateSliders."!
documentName
    ^documentName!  
printString
    name isNil ifTrue: [name := ''].
    ^'ReportColumn <', name , '> '!
reportOn: aPen
        " Private -Write the pagebreak to aPen."
    | pageNumber |
    pageNumber := self reportFrameBody pageNumber.
    (reportOnFirstPage not and: [pageNumber = 1])
        ifTrue: [^true].
    self triggerEvent: #aboutToReport:
        withArguments: (Array with: pageNumber ).
    "position the pen"
    self isPageHeader
        ifTrue: ["relative to field above it."
            aPen
                "goToLeftTop;"
                goDown: self location y.
            self addToHeadersIfAbsent.]
        ifFalse: ["relative to the bottom for the page."
            aPen
                goToLeftBottom;
                goUp: self location y].
    self
        reportFieldsDo: [:item | item prepareLine: aPen]
        withPen: aPen.
    aPen goDown: trailingHeight.
    self isPageHeader
        ifTrue: [self reportFrameBody pageHeaderBoundry: aPen place y].
    ^true "the report for the page break is done."! 
pageHeight: anInteger
        "Private - set the page height which is an Integer in 0.1 mm units."
    ^pageHeight := anInteger!
rightMarginPane
        "Private - "
    self children do: [:child |
        child name == #rightMargin ifTrue: [^child]
        ].!  
basicUnit
        "Private - All internal measurements in the report writer
        are kept in centimeter, including the PARTSFramers and
        the width and the positions of the report items."
    ^#centimeter!
reportHeight
        "Private - Answer the height in 0.1 mm."
    ^self superWindow reportHeight!   
function
        "Private - Answer a String the name of the function."
    ^self functionNames at:
        (self functionSelectors indexOf: function)! 
verticalPixelsPerInch
    ^Display verticalPixelsPerInch!
setDocumentName: aString
    ^self reportFrameBody setDocumentName: aString! 
isBreakTime: row
        "Private - Answer true if it is time to report."
    writeReport := false.
    self triggerEvent: #aboutToExamine:
        withArguments: (Array with: row).
    "writeReport could be set via a link to 'report' "
    writeReport ifTrue: [^true].
    self breakFields associationsDo: [:assoc |
        assoc value isNil "First time in the loop."
            ifTrue: [assoc value: (row at: assoc key ifAbsent: [nil])].
            "See if this break condition is satisfied."
            assoc value = (row at: assoc key ifAbsent: [nil])
            ifFalse: [^true]
        ].
    ^false!  
horizontalPixelsPerMeter
    ^Display horizontalPixelsPerMeter!  
partWindowUnderPoint: ignore
    ^self superWindow reportFrameBody!  
isPARTSReportStructure
    ^false!   
initPARTSReportField
        "PARTSReportField is the actual class which at the runtime
        generates the report."
    reportField := PARTSReportColumn new
            reportPart: self;
            name: 'FieldName';
            width: 300; "in 0.1mm"
            location: (0 @ 0); "0.1mm"
            wordWrap: true;
            doNotRepeat: false;
            leftJustify;
            decimalDigits: 0;
            yourself.
    ^reportField!
width: anInteger
        "Private - Set the width in 0.1 mm."
    width := anInteger!   
variance
    groupCount := groupCount + 1.
    runningCount := runningCount + 1.
    groupSummary
        at: #squaredSum
        put: (groupSummary at: #squaredSum) + value squared;
        at: #sum
        put: (groupSummary at: #sum)  + value.

    runningSummary
        at: #squaredSum
        put: (runningSummary at: #squaredSum) + value squared;
        at: #sum
        put: (runningSummary at: #sum)  + value.! 
isPARTSGroupFramePart
    ^false!
initPARTSReportField
        "PARTSReportField is the actual class which at the runtime
        generates the report."
    reportField := PARTSReportHorizontal new
            reportPart: self;
            width: 300; "0.1mm"
            height: 10; "0.1 mm"
            location: (0 @ 0); "0.1mm"
            yourself.
    ^reportField!
amountToPageUp
        "Private - Answer the number of pixels for
        vertical page scrolling."
    ^0 down: ( super amountToPageUp )! 
date
        "Private - Used to set the value to the current date
        before printing the value."
    self setValue: Date today asString.! 
numberOfColumns
    ^1!  
validatePen
        "Private - Initialize the graphics tool for the receiver"
    self pen
        height: self pageHeight;
        width: self pageWidth!
height
        "Private - Answer the height in 0.1mm."
    ^height! 
wmErasebackground: mp1 with: mp2
        "Private - Display the backColor."
    | backColor |
    self partsVosOnly.
    (backColor := self backColor) notNil
        ifTrue: [graphicsTool handle
            "fill: self rectangle color: backColor"].
    ^false!   
location
        "Private - Answer a point.  X is the starting point of the
        receiver, y is the relative distance from the previous
        report item."
    ^location.!  
upgradeMapsForLoadingPW20
        " Private - answer the upgrade change maps needed to load
        applications from PW/Win32 2.0 containing report writer parts
        into PW 3.0. "

    ^#(
        #PARTSReportDisplayPane
        #PARTSReportDisplayPart
        #PARTSReportRulerPane
        #PARTSReportFieldPart
        #PARTSReportHorizontalPart
        #PARTSReportTextPart
        #PARTSReportColumnPart
        #PARTSColumnSummaryPart
        #PARTSReportFramePart
        #PARTSGroupFramePart
        #PARTSHardPageBreakPart
        #PARTSPageBreakPart
        #PARTSRecordFramePart
        #PARTSReportFrameBody
        ) collect: [ :classSymbol |
            ObjectChangeMap forClassName: classSymbol ]! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #()
        separators: #(  )
        defaultItem: nil!  
incrementPageNumber
        pageNumber := pageNumber + 1.!   
verticalPixelsToLowMetric: pixels
        "Private - The scale unit for the report generating panes
        is fixed to 0.1 mm"
    ^((self framingBlock pixelToScaleUnitVertical: pixels) * 100) rounded! 
displayPane
        "Private - answer an instance of PARTSReportDisplayPane, where the
        report is actually displayed in."
    ^displayPane! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #aboutToEvaluate:
            #aboutToGroupReport:
            #aboutToFinalReport:
            )
        separators: #(  )
        defaultItem: #aboutToEvaluate:!   
rightJustify
    " Private - Set the the justification to right."
    self justification: #right.!  
functionNames
        "Private - Answer an Array of Strings with the name of
        the functions which this part can perform."
    ^#('Date ' 'Time' 'Page Number' 'None')!  
numberOfColumns
        "Private - Table breaks are inside their tables,
        so they can have the same number of columns."
    ^self recordFrame numberOfColumns!  
turnToPreviousPageBottom
        "Private - Display the previous page alinged at the bottom.  Do nothing
        if already displaying the first page."
    pageNumber > 1
        ifTrue: [
            self turnToPage: pageNumber - 1 scrolledToPageTop: false].! 
function
        "Private - Do nothing, columns have no 'function' to support."
    ^nil!   
endPrintJob
    self pen recordingGraphicsMedium endPrintJob.
    self superWindow endPrintJob.!
functionNames
        "Private - Answer an Array of Strings with the name of
        the functions which this part can perform."
    ^#('Sum' 'Average' 'Count' 'Minimum' 'Maximum' 'Var (population n)' 'Var (population n - 1)'
        'StDev (population n)' 'StDev (population n - 1)' 'None')!  
reportOnFirstPage: aBoolean
    reportOnFirstPage := aBoolean!   
wordWrap: aBoolean
    wordWrap := aBoolean! 
unit
        "Private - Answer a symbol based on the OS measurement settings."
    ^NationalLanguage measurementSystem = 1
        ifTrue: [#inch]
        ifFalse: [#centimeter]!
isPARTSReportFrameBody
    ^true!
varN
    groupCount := groupCount + 1.
    runningCount := runningCount + 1.
    groupSummary
        at: #squaredSum
        put: (groupSummary at: #squaredSum) + value squared;
        at: #sum
        put: (groupSummary at: #sum)  + value.

    runningSummary
        at: #squaredSum
        put: (runningSummary at: #squaredSum) + value squared;
        at: #sum
        put: (runningSummary at: #sum)  + value.! 
close
    self clear.
    super close.! 
rightMargin
    ^self reportFrameParent rightMargin! 
pixelsPerHorizontalUnit
    ^self unit = #inch
        ifTrue: [Display horizontalPixelsPerInch]
        ifFalse: [Display horizontalPixelsPerInch * 39 / 100]!
isPARTSReportTextPart
    ^false!
isPARTSReportTextPart
    ^true! 
defaultFrameCreationFlags
        "Private - "
    ^self class noScrollbarsFrameStyle!  
partsFromFont: aFont graphicsMedium: aGraphicsMedium
        "Answer a new font with identical appearance characteristics
        as aFont conditioned for use with aGraphicsMedium. Use this
        method to set lMatch field to zero to use closest-matching
        font selection."
    | newFont |
    newFont := self partsFromLogicalFont: aFont logicalFont graphicsMedium: aGraphicsMedium.
    newFont
        setPointSize: aFont pointSize;
        adjustFontSize.
    ^newFont! 
additionalCopies
        "Private - Take care of the copies beyond the first one.
        If collate is true, back up the contents in a file to be reprinted
        after the first printing is done.  If collate is false, reprint
        each page as it is finished without backing to file."
    | recordingGraphicsMedium |
    recordingGraphicsMedium := self pen recordingGraphicsMedium.
    copies > 1
        ifTrue: [collate
            ifTrue: [recordingGraphicsMedium appendOnFile]
            ifFalse: ["Print additional copies of the current page."
                recordingGraphicsMedium stopRecording.
                copies timesRepeat:
                    [super formFeed.

                    "self pen setMapMode."
                    recordingGraphicsMedium playCurrentPage: self pen]].
        recordingGraphicsMedium formFeed].! 
justification
        "Private - Answer a Symbol one of #(left center right)."
    ^justification!  
restrictScrollRange: aPoint
        "Private - Answer a top left corner for the displayPane such that
        it does not scroll out of range."
    | x y deltaX |
    deltaX := self rectangle width - self displayPane width.
    deltaX > 0 ifTrue: [    "display pane larger than receiver, no need to scroll further"
        deltaX := topCorner x ].
    x := (0 min: aPoint x) max: deltaX.
    y := pageNumber = 1
        ifTrue: [self rectangle top higherOf: aPoint y]
        ifFalse: [pageNumber = self numberOfPages
            ifTrue: [
                ( self rectangle bottom up: self displayPane height )
                lowerOf: aPoint y ]
            ifFalse: [aPoint y]].
    ^x @ y!
removeUpgradeChangeMaps
        " Private - remove upgrade mapping specifications for
        the Report Writer parts. "

    " remove PWW 2.0 upgrade mapping specifications "
    self upgradeMapsForLoadingPW20 do: [ :aChangeMap |
        PARTSFile
            removeChangeMapForClass: aChangeMap sourceClassName
            forVersion: 'PARTS/Win32 2.0' ].!
reset
    self resetGroupSummary; resetRunningSummary!   
functionSelectors
        "Private - Answer an Array of Strings with the name of
        the functions which this part can perform."
    ^#(#date  #time  #pageNumber #none )! 
font: aFont
        "Pirvate - Each report field has its own font, and it does not
        inherit from the report frame.  The receiver has not text
        to display, so it does not need a font."! 
pageUpButton
        "Private - Answer the drawn button which has an up arrow on it."
    self children do: [:child |
        child name = 'pageUpButton' ifTrue: [^child]].
    ^self children at: 2!
pageBreaks
        "Scan the children and create the reportItems."
    ^(self children select: [:child | child isPARTSPageBreakPart])
        asSortedCollection asOrderedCollection.! 
visitRow: row
        "Private - Sent to objects inside a TableBreak.  Update
        your data from the row.  Nothing to update."! 
reportPart: part
    reportPart := part! 
loadFromBits: bits
        "Display the receiver through aGraphicsTool."
    self release.
    self
        partsIfOS2Do: [
            self startRecording; stopRecording.
            PARTSHostInterface
                hostGraphicsLibrary setMetaFileBits: hMetaFile offset: 0 length: bits size buffer: bits  ]
        partsIfWindowsDo: [
            hMetaFile := PARTSHostInterface
                hostGraphicsLibrary setMetaFileBitsEx: bits size buffer: bits]!   
none
        "Private - the 'None' automatic function."! 
initializeReport: aPen
    super initializeReport: aPen.
    firstTime := true.!
stDevN
    self varN!
currentColumn
        "Private - Answer the column currently being reported.
        report frames and page breaks always have one column each."
    ^1!   
rightMargin
        "Private - Answer the right margin in 0.1 mm."
    ^self superWindow rightMargin!   
isPARTSReportTextPart
    ^false!
setToInch
        "Private - Make a ruler measuering in Inches"
    self
        tickMarks: (Dictionary new
            at: 1 put: 12;
            at: 1/2 put: 7;
            at: 1/4 put: 5;
            at: 1/8 put: 3;
            yourself);
        numberIncrements: 1.!  
isReportWriterNonvisualPart
        "Private - Answer if the receiver is one of the
        report writer non-visual parts."
    ^false!   
pageHeaderBoundry: logicalUnits
        "Private - Set the location of the bottom of the last pageHeader
        in logical units.  This is useful for snaking columns report"
    pageHeaderBoundry := logicalUnits.! 
pageNumber
        ^pageNumber!  
drawScrollBottomTab: aPane
        " Private - Draw the scroll bottom tab button "
    | points rect color |
    rect := 0 @ 0 extent: aPane extent.
    points := Array
        with: ( rect center leftAndUp: 4 @ 5 )
        with: ( rect center rightAndUp: 4 @ 5 )
        with: ( rect center up: 1 ).
    color := aPane disabled
        ifTrue:[ Color darkGray ]
        ifFalse: [  Color black ].
    aPane graphicsTool
        fill: ( 0 @ 0 extent: aPane extent )
        color: Color gray;
        foreColor: Color black;
        place: rect rightTop;
        line: rect leftTop;
        line: rect leftBottom;
        foreColor: color;
        backColor: color;
        polygonFilled: points.
    points := points collect: [: each | each down: 6 ].
    aPane graphicsTool polygonFilled: points!  
defaultStyle
        "Private - "
    ^WsPaneBorder | WsClipSiblings!   
report
        "Answer an object which contains the report which is currently
        being displayed in the receiver.  This object can be sent to the
        parts report printer to print it in a WYSIWYG manner."
    ^self displayPane pen recordingGraphicsMedium!  
groupSummaryAsString
        "Private - Answer a String. Use printFraction: if
        groupSummary is a number, answer '' if nil otherwise use
        #asString."
    ^self objectAsString: groupSummary!   
report
        "Answer the report which can be either displayed in
        a report pane or printed in a printer.  The actual generation
        of the report is done when the report is set to its medium,
        which can be either a report pane for screen display or
        a printer."
    ^self! 
isPARTSReportHorizontalPart
    ^false!  
pageWidth: anInteger
        "Private - set the page width which is an Integer in 0.1 mm units."
    ^pageWidth := anInteger!   
prepareRunningReport: aStream
    ^self prepareLine: aStream!
initialize
        "Private - ."
    super initialize.
    self
        foreColor: Color black;
        backColor: Color black!  
currentColumn
        "Private - Answer the column currently being reported.
        report tables and table breaks can have more than one column."
    ^self recordFrame currentColumn!   
setValue: anObject
        "If anObject is not a string, it must implement #asString."
    value := anObject.!  
reportPart
    ^reportPart!  
reportWidth
        "Private - Answer the width in system settings measurement units."
    ^self superWindow reportWidth!   
asArrayOfLines: aString in: aRectangle wordWrap: wordWrapBoolean
        "Private - convert aString into an array of lines; if wordWrapBoolean
        is true, also perform word wrapping on the lines, within aRectangle."
    | line lines stream x0 x1 partialLine leftMargin rightMargin partialLineWidth |
    stream := aString asStream.
    lines := OrderedCollection new.
    wordWrapBoolean ifTrue: [
        leftMargin := aRectangle left.
        rightMargin := aRectangle right ].
    [ stream atEnd ] whileFalse: [
        line := stream nextLine.
        wordWrapBoolean
            ifFalse: [ lines add: line ]
            ifTrue: [
                x0 := x1 := 1. 
                1 to: line size do: [ :i |
                     ( ( line at: i ) asInteger = 32 and: [ ( partialLine := line copyFrom: x0 to: i ) trimBlanks notEmpty ] ) ifTrue: [
                        partialLineWidth := self stringWidthOf: partialLine.
                        ( leftMargin + partialLineWidth ) > rightMargin
                            ifTrue: [
                                partialLine := line copyFrom: x0 to: x1.
                                lines add: partialLine.
                                x0 := x1 + 1].
                            x1 := i  ] ].
                line isEmpty
                    ifTrue: [ lines add: line ]
                    ifFalse: [
                        partialLine := line copyFrom: x0 to:  line size.
                        partialLineWidth := self stringWidthOf: partialLine.
                        ( leftMargin + partialLineWidth ) > rightMargin ifTrue: [
                            partialLine := line copyFrom: x0 to: x1.
                            lines add: partialLine.
                            partialLine := line copyFrom: x1 + 1 to:  line size ].
                        lines add: partialLine ] ] ].
    lines asArray.
    ^super asArrayOfLines: aString in: aRectangle wordWrap: wordWrapBoolean! 
partIsDesktopChild
    "Private - Answer whether the receiver is always a child of the
    workbench desktop."

    ^true!
numberOfColumns
    numberOfColumns isNil
        ifTrue: [numberOfColumns := 1].
    ^numberOfColumns!
wmErasebackground: mp1 with: mp2
        "Private - Display the backColor."
    ^false! 
value
    ^value!
playCurrentPage: aGraphicsTool
        "Private - ."
    self handle notNil
        ifTrue: [
            self
                partsIfOS2Do: [ self partsDisplayWith: aGraphicsTool ]
                partsIfWindowsDo: [ super displayWith: aGraphicsTool ] ]! 
decimalDigits: aNumber
    decimalDigits := aNumber!