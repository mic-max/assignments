3.1.0.106
   
addSmalltalkFileFilters
        "Private - Add Smalltalk filter and descriptions"
    self propertyAt: #smalltalkFileFilters put: true.!
compileAtPutSelector: anAssociation in: aString
        "Private - compile the method specified by anAssociation
         in the structure definition named aString"
    | sourceStream atPutSelector offset firstHalf split type |
    sourceStream := String new asStream.
    sourceStream nextPutAll: anAssociation key, ' anObject'; cr.
    offset := anAssociation value at: 1.
    atPutSelector := ( type := anAssociation value at: 2 ) isInteger
        ifTrue: [ #bytesAtOffset:put: ]
        ifFalse: [ AtPutSelectors at: type ].
    split := atPutSelector indexOf: $: .
    firstHalf := atPutSelector copyFrom: 1 to: split.
    sourceStream nextPutAll: '    self ', firstHalf, ' ', offset printString, ' put: anObject'.
    ^sourceStream contents! 
addHelpMenu
        "Private - add the Help menu to the menu bar."
    | menu |
    ( menu := window helpManager helpMenu ) notNil ifTrue: [
        menu owner: window helpManager.
        window owner == Transcript ifTrue: [
            menu insertSeparatorAfter: 3.
            menu
                insertItem: '\uProfessional Services...' replaceEscapeCharacters
                selector: #professionalServices
                accelKey: nil
                accelBits: nil
                after: 4 ].
        window isMDIFrame
            ifFalse: [ window menuWindow addMenu: menu ]
            ifTrue: [ window mdiMenuWindow addMenu: menu ] ]!
reportFatal: error
	"Private - ignore errors, because they are handled by the client."

	^self!
compiler: aCompilerInterface
	"Porvide the receiver with knowledge of the compiler interface object that it is
	handling errors for."

	compiler := aCompilerInterface!   
checkDefineGlobal: error
        "Private - a potential undeclared global was encountered in
        the compilation; recompile after defining the global if
        necessary."

    | var |
    var := error sourceCode
        copyFrom: error sourceRange first
        to: error sourceRange last.
    (self retryWithVar: var)
        ifTrue: [
            Smalltalk at: var asSymbol put: nil.
            error retry]
        ifFalse: [self fatalError: error]!  
undeclaredAccess: error
	"The compiler has found a reference to an undeclared variable"
	self checkDefineGlobal: error!
retryWithVar: var
        "Private - ask the user whether to define var as global,
        and if so, retry compilation using that global."
    ^(compiler validAsGlobalHead: var first)
        and: [ Smalltalk defineGlobal: var ]!
undeclaredAssignment: error
	"The compiler has found an assignment to an undeclared variable"
	self checkDefineGlobal: error!  
reportWarning: error
	"Private - report warnings and let the user decide whether to continue."

	( MessageBox confirm: 'compilation warning: ',  error errorMessage, ' - continue?' )
		ifFalse: [ error retry ].
	^self!
reportWarning: anError
	"Private-tell the user about the error"
	"SilentErrorHandlers do this silently"

	^self!  
reportFatal: anError
	"Private-tell the user about the error"
	self reportWarning: anError! 
compiler: aCompilerInterface
	"Porvide the receiver with knowledge of the compiler interface object that it is
	handling errors for.  Most handlers don't case so the default implementation
	does nothing"!   
undeclaredAccess: error
	"The compiler has found a reference to an undeclared variable"

	self fatalError: error!  
undeclaredAssignment: error
	"The compiler has found an assignment to an undeclared variable"

	self fatalError: error!
fatalError: error
	"A fatal <error>, one that cannot be recovered, has been found."

	self reportFatal: error.
	error abort!  
reportWarning: anError
	"Private-tell the user about the error"
	self implementedBySubclass!
warning: error
	"The compiler has issued a warning."

	self reportWarning: error.
	error proceed! 
compileAtSelector: anAssociation in: aString
        "Private - compile the method specified by anAssociation
         in the structure definition named aString"
    | sourceStream atSelector offset conversion type |
    sourceStream := String new asStream.
    sourceStream nextPutAll: anAssociation key; cr.
    offset := anAssociation value at: 1.
    conversion := anAssociation value at: 3.
    ( type := anAssociation value at: 2 ) isInteger
        ifTrue: [
            sourceStream nextPutAll: '    ^( self bytesAtOffset: ', offset printString,
                ' count: ', type printString, ' ) ', conversion ]
        ifFalse: [
            atSelector := AtSelectors at: ( anAssociation value at: 2 ).
            sourceStream nextPutAll: '    ^( self ', atSelector, ' ', offset printString, ' ) ', conversion ].
    ^sourceStream contents! 
recompile: aSymbol
		 "Private - Recompile the method named
		aSymbol defined in the receiver."
	| result oldMethod |
	oldMethod := self compiledMethodAt: aSymbol.
	 result := oldMethod definition recompile.
	 result == nil
		ifTrue: [ ^RecompilationNotification signal: 'No source for: ', oldMethod selector forCompiledMethod: oldMethod].
	result wasSuccessful
		 ifFalse: [  ^RecompilationNotification signal: 'Error compiling: ', aSymbol forCompiledMethod: oldMethod].
!   
inspect
        "Open an inspector window on the receiver."
    DoubleByteStringInspector new openOn: self! 
iconId
		"Answer the icon id for this window class."
	^6!   
setInstList
        "Private - Initialize an OrderedCollection of
         instance variable names and/or numbers for
         the list pane."
    instList := OrderedCollection new.
    instList add: 'self'.
    instList := instList,
        object class allInstVarNamesGrouped .
    object class isVariable
        ifTrue: [
            1 to: object basicSize do: [ :index |
                instList add: index printString]]! 
enableInspectItem
        "Private - Enable the Inspect menu item."
    ( self menuTitled: 'Inspect' ) enableItem: #inspectSelection!   
createView
        "Private - create the panes for the receiver window."
    | pane |
    ( instPane := self toolTextPaneClass new )
        owner: self;
        setName: #instance: ;
        when: #help send: #help to: self;
        when: #needsContents send: #instance: to: self with: instPane;
        when: #saved send: #accept: to: self with: instPane;
        dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
        dragTarget: self class dragDropEnabled;
        framingRatio:
            ( ( Rectangle leftTopUnit rightAndDown: ( 1/3 @ 0 ) )
                extentFromLeftTop: 2/3 @ 1 ).
    self
        label: self label;
        owner: self.
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            owner: self;
            setName: #instVarList: ;
            when: #needsContents send: #instVarList: to: self with: pane;
            when: #clicked: send: #selectInstance: to: self with: pane;
            when: #doubleClicked: send: #inspectSelection: to: self with: pane;
            when: #needsMenu send: #inspectMenu: to: self with: pane;
            framingRatio: ( Rectangle leftTopUnit extentFromLeftTop: 1/3 @ 1 ) ).

    self addSubpane: instPane!   
inspectMenu: pane
        "Private - Set the dictionary
         inspector list pane menu."
    | menu |
    menu := ( Menu
        labels: '\uInspect' replaceEscapeCharacters
        lines: Array new
        selectors: #( #inspectSelection ) )
            title: '\uInspect' replaceEscapeCharacters;
            owner: self;
            yourself.
    menu disableItem: #inspectSelection.
    pane setMenu: menu!  
inspectSelection
        "Private - Open an Inspector on the
         selected instance variable."
    | i |
    instIndex = 1
        ifTrue:  [object inspect]
        ifFalse: [
            object class isBytes
                ifTrue: [(object at: (instIndex - 1)) inspect]
                ifFalse: [(i := self getInstVarIndex) ~= 0 ifTrue: [
                    (object instVarAt: i) inspect]]]!  
openOn: anObject
        "Open an inspector window on anObject.  Define
        the pane sizes and behavior, and open the
        window."
    object := anObject.
    self createView.
    self addHelpManager.
    self setInstList.
    self openWindow!   
selectInstance: aListPane
        "Private - Select the instance variable at
         index position anInteger in the list."
    instIndex := aListPane selection.
    self enableInspectItem.
    self changed: #instance:! 
instance: textPane
        "Private - Set the ASCII representation
         of the selected instance variable."
    | i |
    instIndex isNil ifTrue: [^textPane contents: String new].
    instIndex = 1
        ifTrue: [^textPane contents: object printString].
    object class isPointers
       ifTrue: [(i := self getInstVarIndex) ~= 0
            ifTrue: [^textPane contents: (object instVarAt: i) printString]
            ifFalse: [^textPane contents: String new]]
       ifFalse: [^textPane contents: (object at: instIndex - 1) printString]!  
instVarList: pane
        "Private - Set an OrderedCollection of
         instance variable names and/or numbers for
         the list pane."
    pane contents: instList!
doItResult: aTextPane error: aBlock
        "Private - Evaluate the selected text in
         aTextPane in the context of the inspected
         object.  If error, evaluate aBlock."
    | aString selection |
    selection := aTextPane selection.
    aString := aTextPane selectedItem.
    aString  isEmpty
        ifTrue: [
            aTextPane selectLineAtCurrentSelection.
            aString := aTextPane selectedItem ].
    ^CompilerInterface
        evaluate: aString
        in: object class
        to: object
        notifying: aTextPane
        ifFail: aBlock!
accept: textPane
        "Private - Replace the selected instance
         variable with the result of evaluating
         the contents of textPane."
    | result aString |
    instIndex isNil ifTrue: [ ^self ].
    aString := textPane contents.

    SourceManager current
        logEvaluate: aString
        for: [
            result := CompilerInterface
                evaluate: aString
                in: object class
                to: object
                notifying: textPane
                ifFail: [ ^textPane modified: true ] ].

    instIndex = 1
        ifFalse: [
            object class isBytes
                ifTrue: [
                    object
                        at: (instIndex - 1)
                        put: result]
                ifFalse: [
                    object
                        instVarAt: self getInstVarIndex
                        put: result]].
    self changed: #instance:.
    textPane modified: false!
label
        "Private - answer the label of the window."
    ^'Inspecting: ', object class printString!
getInstVarAt: index
        "Private - Answer the content of the selected instance variable
          at index."
    ^object instVarAt: index! 
inspectSelection: aListPane
        "Private - Open an Inspector on the
         selected instance variable."
    instIndex := aListPane selection.
    self inspectSelection!
getInstVarIndex
        "Private - Answer the index of the selected instance variable."
    | t |
    t := instList at: instIndex.
    t first isDigit ifTrue: [^t asInteger + object class instSize].
    ^object class allInstVarNames indexOf: t.!
variableByteSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a variable
        byte subclass of the receiver with the specified class variables
        and pool dictionaries."
	
	^self 
		subclass: className
    	instanceVariableNames: instanceVariables
		classVariableNames: classVariables
    	poolDictionaries: poolDictionaries
		isVariable: true
		isPointers: false!   
matchLeftBracketChar: aChar at: aPoint
        "Private - Select the closest left surrounding brackets, (), []."
    | left right c lookLeft lookRight count answer found charPoint |
    charPoint := self characterCoordinate: aPoint.
    left := charPoint.
    right := charPoint.
    found := false.
    answer := TextSelection new.
    answer origin: left.
    count := 0.
    lookLeft := #($( $[ $" $').
    lookRight := #($) $] $" $').
    lookRight := lookRight at: (lookLeft indexOf: aChar).
    [lookRight notNil] whileTrue: [
            right := right + (1 @ 0).
            [(right x > (self endOfLine: right y)) and: [right y <= self totalLength]] whileTrue: [
                right := 1 @ (right y + 1)].
            (c := textHolder charAt: right) isNil
                ifTrue: [lookRight := nil]
                ifFalse: [
                    ((lookRight = c) and: [count = 0])
                        ifTrue: [
                            (lookRight = $' and:
                            [(textHolder charAt: (right right: 1)) = $'])
                                ifTrue: [right := right right: 1]
                                ifFalse: [
                                    answer corner: right.
                                    lookRight := nil.
                                    found := true]].
                    (aChar =  c) ifTrue: [count := count - 1].
                    (lookRight = c) ifTrue: [count := count + 1]]].
    found
        ifTrue: [
            self
                selectFrom: answer origin to: answer corner;
                showSelection]
        ifFalse: [
            MessageBox message:  'Unmatched $', (String with: aChar)].! 
addCurlyBrackets
        "Private - Bracket the selected text in a pair of {}"
    self addLeftBracket: ${ rightBracket: $}!
addInspectorPanesTo: aBrowser
        "Private - add the inst var / temporary list box/ text pane to
        aBrowser."
    | pane |
    aBrowser addSubpane:
        ( ( pane := ListPane new )
			backColor: Color yellow;
            owner: aBrowser;
            setName: #tempList: ;
            when: #needsContents send: #tempList: to: aBrowser with: pane;
            when: #clicked: send: #selectInstance: to: aBrowser with: pane;
            when: #doubleClicked: send: #inspectSelection: to: aBrowser with: pane;
            when: #needsMenu send: #inspectMenu: to: aBrowser with: pane;
            framingBlock: [ :box |
                ( box leftTop rightAndDown: ( box width // 2 @ self singleLineHeight ) )
                    extentFromLeftTop: ( box width / 4 @ ( box height * self ratio ) ) rounded ] ).
    aBrowser addSubpane:
        ( ( pane := SmalltalkToolInterface current textPaneClass new )
			backColor: Color yellow;
            owner: aBrowser;
            setName: #instance: ;
            when: #needsContents send: #instance: to: aBrowser with: pane;
            when: #saved send: #accept: to: aBrowser with: pane;
                framingBlock: [ :box |
                    ( box leftTop rightAndDown: ( box width * 3 // 4 ) @ self singleLineHeight )
                        extentFromLeftTop: ( box width + 1 / 4 @ ( box height * self ratio ) ) rounded ] )!  
addTextPaneTo: aBrowser
        "Private - add the primary TextPane to aBrowser."
    | pane |
    aBrowser addSubpane:
        ( ( pane := SmalltalkToolInterface current textPaneClass new )
            backColor: Color yellow;
            owner: aBrowser;
            setName: #method: ;
            when: #needsContents send: #method: to: aBrowser with: pane;
            when: #saved send: #take: to: aBrowser with: pane;
            dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
            dragTarget: self dragDropEnabled;
            framingBlock: [ :box | box leftBottom
                extentFromLeftBottom:
                    ( box width @ ( box height * ( 1 - self ratio ) - self singleLineHeight ) ) rounded ] )!   
addSubpanesFor: aDebugger
        "Create the subpanes for aDebugger."
    self addWalkbackPaneTo: aDebugger.
    self addInspectorPanesTo: aDebugger.
    self addGoButtonsTo: aDebugger.
    self addTextPaneTo: aDebugger!
margin
        "Private - answer the number of pixels to indent the button
        groups from the left."
    ^15! 
default
        "Answer the preferred debugger for the current
        environment."
    ^defaultDebuggerClass isNil
        ifTrue: [ self ]
        ifFalse: [ defaultDebuggerClass ]! 
default: debuggerClass
        "Change the preferred debugger for the current
        environment."
    defaultDebuggerClass := debuggerClass! 
addGoButtonsTo: aBrowser
        "Private - add the Hop, Skip, Jump buttons to aBrowser."
    | goButtons margin pane |
    margin := self margin.
    aBrowser addSubpane:
        ( goButtons := GroupPane new
			backColor: Color yellow;
            framingBlock: [ :box |
                ( box leftTop rightAndDown: ( box width // 2 @ 0 ) )
                    rightBottom: ( box rightTop rightAndDown: ( 0 @ self singleLineHeight ) ) ] ).
    goButtons addSubpane:
        ( ( pane := Button new )
            owner: aBrowser;
            contents: 'Hop';
            when: #clicked send: #hop: to: aBrowser with: pane;
            framingBlock: [ :box |
                ( box leftTop rightAndDown: ( ( 2 * margin ) @ 0 ) )
                    extentFromLeftTop: ( box width // 3 - ( 2 * margin ) ) @ box height ] ).
    goButtons addSubpane:
        ( ( pane := Button new )
            owner: aBrowser;
            contents: 'Skip';
            when: #clicked send: #skip: to: aBrowser with: pane;
            framingBlock: [ :box |
                ( box leftTop rightAndDown: ( box width // 3 ) + margin @ 0 )
                    extentFromLeftTop: ( box width // 3 - ( 2 * margin ) ) @ box height ] ).
    goButtons addSubpane:
        ( ( pane := Button new )
            owner: aBrowser;
            contents: 'Jump';
            when: #clicked send: #jump: to: aBrowser with: pane;
            framingBlock: [ :box |
                ( box leftTop rightAndDown: ( box width * 2 // 3 ) @ 0 )
                    extentFromLeftTop: ( box width // 3 - ( 2 * margin ) ) @ box height ] ).!  
ratio
        "Private - answer the ratio of the top panes height to the total
        height of the window."
    ^2 / 5!  
addWalkbackPaneTo: aBrowser
        "Private - add the walkback list to aBrowser."
    | margin pane |
    margin := self margin.
    aBrowser addSubpane:
        ( ( pane := ListPane new )
			backColor: Color yellow;
            owner: aBrowser;
            setName: #walkbackList: ;
            when: #needsContents send: #walkbackList: to: aBrowser with: pane;
            when: #clicked: send: #walkbackSelected: to: aBrowser with: pane;
            when: #needsMenu send: #menu: to: aBrowser with: pane;
            dragSource: self dragDropEnabled;
            when: #dragSourceNeedsObject: send: #methodListSetDragObject: to: aBrowser;
            when: #dragSourceCut: send: #methodListCut: to: aBrowser;
            framingBlock: [ :box |
                ( box leftTop )
                    extentFromLeftTop: box width // 2 @ ( ( box height * self ratio ) rounded + self singleLineHeight ) ] )! 
iconId
        "Answer the icon id for this window class."
    ^4!  
openFor: aBrowser labeled: titleString
        "Create and open a window on <aBrowser>.  The window will be
        labeled with the <titleString>."
    aBrowser owner: aBrowser.
    aBrowser label: titleString.
    self addSubpanesFor: aBrowser.
    aBrowser mainView
        when: #closed
        send: #closed
        to: aBrowser.
    aBrowser backColor: Color yellow.
    aBrowser addHelpManager.
    aBrowser openWindow.
    self setInitialStateOf: aBrowser! 
setInitialStateOf: aBrowser
        "A window has been created on <aBrowser>. Set the initial state of that window."
    aBrowser menuWindow insertMenu: aBrowser goMenu after: 5.
    aBrowser expandTopFrame.
    aBrowser walkback: 1.
    (aBrowser paneAt: #walkbackList:) selection: 1!
singleLineHeight
        "Answer the height, in pixels, of fixed height views displaying a single line of text."
    ^SysFont height + 4!   
openOn: aDebugger labeled: aString
        "Create a view of <aDebugger> and display it."
    self
        openFor: aDebugger
        labeled: aString!   
enableInspectItem
        "Private - Enable the Inspect menu item."
    (self menuTitled: '~Inspect')
        enableItem: #inspectSelection.!  
instancePane
        "Answer the text pane that contains the source for the selected temporary"
    ^self paneAt: #instance:!   
restart
        "Private - restart the process at the selected method."
    | process index |
    self mainView textModified
        ifTrue: [ ^self ]
        ifFalse: [ self mainView clearTextModified ].
    self restartable ifFalse: [ ^self ].
    process := self debuggedProcess.
    index := self processWalkbackIndex.
    process runable: 6.  "restart mode"
    self close.
    process isUserIF ifFalse: [ Processor schedule: CurrentProcess ].
    process restartAt: index!
expandTopFrame
        "Private- Create a debugging version of the top frame."
    self expandFrame: 1.!
browseWalkback: aButton
        "Private - Switch to browse walkback."
    browseWalkback := true.
    "walkbackIndex := nil."
    self changed: #walkbackList: with: #restoreWithRefresh: with: walkbackIndex.
    walkbackIndex == nil
        ifFalse: [self walkback: walkbackIndex].
    self changed: 'Walkback' with: true.
    self changed: 'Breakpoints' with: false!   
methodPane
        "Answer the text pane that contains the source for the selected method"
    ^self paneAt: #method:!  
restartable
        "Private - answer true if the process is restartable."
    | process processIndex |
    process := self debuggedProcess.
    process restartable
        ifFalse:
            [
            MessageBox message: 'Process is not resumable'.
            ^false
            ].
    walkbackIndex isNil ifTrue: [ ^false ].
    processIndex := self  processWalkbackIndex.
    self inBlock ifTrue:
            [
            MessageBox message: 'Can''t restart at block.'.
            ^false
            ].
    ( ( process methodAt: processIndex ) primitiveNumber ) = 0 ifFalse:
        [
        MessageBox message: 'Can''t restart primitive method.'.
        ^false
        ].
    process sendFrame: 0.
    ^true !   
updateMethodText
        "Refresh the text pane with the new text."
    self changed: #method:.!
instance: textPane
        "Private - Set the ASCII representation
         of the selected temporary variable."
    (walkbackIndex isNil or: [instIndex isNil])
        ifTrue: [^textPane contents: String new].
    ^textPane contents: self tempValue printString!   
isResumable
        "Private - answer true if the process is resumable."
    self debuggedProcess restartable
        ifFalse: [ ^false ].
    self debuggedProcess runable = 1
        ifTrue: [ ^false ].
    ^true!  
jump
        "Private - resume process for one jump, i.e., to next breakpoint."
    | process |
    self resumable
        ifFalse: [^self].
    breakpointArray isEmpty
        ifTrue: [^self resume].
    self label: 'jumping to breakpoint'.
    Process enableInterrupts: false.
    process := self debuggedProcess.
    realFrame isNil
        ifFalse:
            [process topFrame: realFrame.
            realFrame := nil].

    process sendFrame: 16r20000000.
    process debugger: self.
    process interruptFrame: 0.
    process runable: (process runable bitOr: 1).
    BreakPoints:= breakpointArray.
    UserInterfaceProcess := (process isUserIF
        ifTrue: [process]
        ifFalse: [nil]).
    CurrentProcess := process.
    process resume: 0!  
resume
        "Private - Resume the process if resumable."
    | process |
    self mainView textModified
        ifTrue: [ ^self ]
        ifFalse: [ self mainView clearTextModified ].
    self resumable ifFalse: [^self].
    process := debuggedProcess.
    self setDebuggedProcess: nil.
    realFrame isNil ifFalse: [
        process topFrame: realFrame.
        realFrame := nil ].

    process runable: (process runable bitAnd: 6).  "Not tracing" 
    self close.
    process
        sendFrame: 0;
        debugger: nil.
    process isUserIF
        ifTrue: [
            CurrentProcess := process.
            process makeUserIF.
            process resume]
        ifFalse: [
            Processor resume: process]!
accept: textPane
    "Private - compile and evaluate the code in textPane. Replace
    the selected temporary variable with the result of the evaluation."

    | aString locals bindings compiler compileResult |
    aString := textPane contents.
    locals := self localVariableList.
    bindings := Dictionary new: locals size.
    1 to: locals size do:
        [:idx |
        bindings at: (locals at: idx) put: (self localVariableAt: idx)].
    compiler := CompilerInterface new.
    compiler errorHandler: (TextPaneErrorHandler new pane: textPane).
    compiler nameScope:
        (compiler scopeForReservedSymbolsExcluding: #('super')) ,
        (compiler scopeForClass: self doItInstance class) ,
        (compiler scopeForDictionary: bindings) ,
        compiler scopeForGlobals.
    SourceManager current
        logEvaluate: aString
        for:
            [compileResult := compiler
                evaluate: aString
                withReceiver: self doItInstance.
            compileResult wasSuccessful
                ifFalse: [^textPane modified: true]].
    instIndex = 1    "same as Inspector..."
        ifFalse: [self localVariableAt: instIndex put: compileResult value].
    self changed: #instance:.
    textPane modified: false!   
dragDropTargetPanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag target."
    ^Array with: #method:! 
maxInfoCacheSize
        "Return the maximum number of elements in the info
        cache."
    ^10!   
tempValue
        "Private - answer the value of the selected temporary variable."

    browseWalkback
        ifFalse: [^String new].
    ^self localVariableAt: instIndex! 
ic
    "Private - Answer the current process ic."

    | process ic processIndex |
    process := self debuggedProcess.
    processIndex := self  processWalkbackIndex.
    ic := process icAt: processIndex - 1.
    ic = 0 ifTrue: [ic := process interruptICAt: processIndex - 1].
    ic > 0 ifTrue: [ic := ic - 1].
    ic < 0 ifTrue: [ic := ic + 1].
    ^ic!
inspectSelection: aListPane
        "Private - Open an Inspector on the
         selected temporary variable."
    instIndex := aListPane selection.
    (walkbackIndex isNil or: [instIndex isNil])
        ifTrue: [^self].
    self tempValue inspect!   
walkback: anInteger
        "Private - select the walkback line at index position anInteger."
    | process sourceInterval start end oldMethod oldActivation processIndex |
    process := self debuggedProcess.
    walkbackIndex := anInteger.
    processIndex := self  processWalkbackIndex.
    oldActivation := self activation.
    oldMethod := self method.
    browseWalkback
        ifTrue: [
            ( process isBlockFrame: processIndex )
                ifTrue: [
                    method := process contextFor: processIndex.
                    method isBlockClosure ifFalse: [ method := process methodAt: processIndex ] ]
                ifFalse: [ method := process methodAt: processIndex ] ]
        ifFalse:
            [ oldMethod := nil.
            method := breakpoints at: walkbackIndex.
            method := method classField
                compiledMethodAt: method selector.
            ].
    ((oldActivation == method) and: [(self methodPane modified not)])
        ifFalse: [self updateMethodText].
    instIndex := nil.
    self changed: #tempList:.
    self changed: #instance:.
    start := end := 1.
    browseWalkback ifTrue: [
        object := process receiverAt: processIndex.
        self
            withInfoFor: self method
            do:
                [:info |
                sourceInterval := info sourceIntervalForProcessIC: self ic.
                start := sourceInterval first.
                end :=sourceInterval last]
              ifAbsent: []].
    self methodPane showSelectionFrom: start to: end.
    self checkMenus.!
debuggingProcess: aProcess
        "Set the process running the debugger to be <aProcess>."
    debuggingProcess := aProcess!   
acceptMethod: textPane using: oldExecutable
        "Accept a method definition from the text pane."

	| result |
	result := oldExecutable definition
		sourceString: textPane contents
		notifying: textPane.
	result == nil
		ifTrue: [ ^nil ].
	^result executable!   
withInfoFor:  key do: aBlock1 ifAbsent: missingBlock
        "Private - evaluate aBlock1 with the info for the method named
        by key as the block argument; if the info is not cached, evaluate
        missingBlock."
    ^aBlock1 value: (self infoCacheAt: key ifAbsent: [^missingBlock value]).!
createCacheInfoFor: anActivation
        "Private - create debug info for anActivation.
        Need to do full compilation for ic's can be translated."

    | c m info old |
    anActivation isCompiledMethod ifTrue: [ m := anActivation ] ifFalse: [ m := anActivation method ].
    m definition isCompilationResult ifTrue: [ ^m definition ].
    old := m hasBlock and: [ m usesBlockClosure not ].
    info := m definition debugInfo.
    info wasSuccessful ifTrue: [
        ^( anActivation isCompiledMethod or: [ old ] )
            ifTrue: [ info ] ifFalse: [ info blockNumbered: anActivation blockNumber ] ].
    " not successful, try again "
    c := CompilerInterface forClass: m classField.
    c addOption: #language with: #backwardCompatible.
    c errorHandler: SilentErrorHandler new.
    info := c compile: m sourceString withMessagePattern: m hasMessagePattern.
    ^( anActivation isCompiledMethod or: [ old or: [ info wasSuccessful not ] ] )
        ifTrue: [ info ] ifFalse: [ info blockNumbered: anActivation blockNumber ].! 
debuggedProcess
        "Answer the process being debugged."
    ^debuggedProcess!  
debuggedProcess: aProcess
        "Set the process being debugged to be <aProcess>."
    self setDebuggedProcess: aProcess.
    self walkback: 1!  
hop
        "Private - resume process for one hop, i.e., to next expression or
        assignment at any method level."
    | process |
    self resumable
        ifFalse: [^self].
    process := self debuggedProcess.
    realFrame == nil
        ifFalse:
            [process topFrame: realFrame.
            realFrame := nil].

    self expandFrame: 2.
    self expandFrame: 3.

    self label: 'hopping'.
    Process enableInterrupts: false.
    process sendFrame: 1.
    process debugger: self.
    process interruptFrame: 0.
    process runable: (process runable bitOr: 1).
    BreakPoints:= breakpointArray.
    UserInterfaceProcess := (process isUserIF
        ifTrue: [process]
        ifFalse: [nil]).
    CurrentProcess := process.
    process resume: 0!
hop: aButton
        "Private - Resume process for one hop, i.e.,
         to next expression or assignment
         at any method level."
    self hop!  
inspectSelection
        "Private - Open an Inspector on the
         selected temporary variable."
    (walkbackIndex isNil or: [instIndex isNil])
        ifTrue: [^self].
    self tempValue inspect! 
activation
    "Private - Answer the current activation object, either a method or a block."

    ^method! 
resetInfoCache
        "Private - throw away cached method info."
    methodInfoCache := nil!   
setDebuggedProcess: aProcess
        "Private - set the process being debugged to be <aProcess>."
    debuggedProcess := aProcess!  
walkbackList: pane
        "Private - Set an OrderedCollection
         of walkback or breakpoint lines."
    pane contents: self walkback!
initialize
        "Private - initialize the receiver"
    self filterActivations: true.
    super initialize.
    self resetInfoCache.
    filterActivations := true.
    browseWalkback := true.
    breakpoints := SortedCollection
        sortBlock:
            [:a :b |
            a classField name < b classField name or:
                [a classField name = b classField name and: [a selector < b selector]]].
    breakpointArray := Array new.!  
method
    "Answer the method for the currently selected frame."

    | answer each |
    ( answer := self activation ) isCompiledMethod ifTrue: [ ^answer ].
    answer isNil ifTrue: [ ^answer ].
    answer := answer method.
    self processWalkbackIndex to: debuggedProcess size do: [:i |
        each := debuggedProcess methodAt: i.
        ( each selector = answer selector and: [ each classField = answer classField ] ) ifTrue: [ ^each ] ].
    ^answer!   
method: textPane
        "Private - Set textPane contents to a string
         containing the source code for the selected
         method in the walkback."
    walkbackIndex isNil
        ifTrue:
            [method := nil.
            ^textPane contents: String new].
    self analyzeMethod: self activation.
    self analyzeMethod: self method.
    textPane contents: self methodSource.!  
localVariableAt: varIndex put: varValue
    "Private - set the value of the variable at <varIndex> to <varValue>."

    varIndex = 1 ifTrue: [^object].
    ^( variables at: varIndex ) valueFrom: self debuggedProcess frame: self processWalkbackIndex put: varValue!   
methodSource
    "Private - Answer the method source string."

    | source |
    (source := self method sourceString) == nil
        ifTrue: [^'-- no source --']
        ifFalse: [^source].! 
skip
        "Private - resume process for one skip, i.e., to next expression
        or assignment at current method level, or to next breakpoint."
    | process processIndex |
    process := self debuggedProcess.
    self resumable ifFalse: [^self].

"    walkbackIndex == nil
        ifTrue: [ walkbackIndex := 1 ].  "
    processIndex := self  processWalkbackIndex.
    self expandFrame: processIndex.
    self expandFrame: processIndex + 1.
    process sendFrame:
        ( process processIndexToStackPointer:
              ( process frameIndexAt: processIndex ) ).

    realFrame isNil
        ifFalse:
            [ process topFrame: realFrame.
            realFrame := nil ].

    self label: 'skipping'.
    Process enableInterrupts: false.
    process debugger: self.
    process interruptFrame: 0.
    process runable: ( process runable bitOr: 1).
    BreakPoints:= breakpointArray.
    UserInterfaceProcess := (process isUserIF
        ifTrue: [process]
        ifFalse: [nil]).
    CurrentProcess := process.
    process resume: 0!   
closeLogger
        "Close the initial logging window"
    logger close.
    logger := nil.!   
doItResult: aTextPane error: aBlock
    "Private - Evaluate the selected text in
         aTextPane in the context of the inspected
         object.  If error, evaluate aBlock."

    | aString compiler locals bindings values compileResult update exec |
    (aString := aTextPane selectedItem).
    aString isEmpty
        ifTrue:
            [aTextPane selectLineAtCurrentSelection.
            aString := aTextPane selectedItem].
    locals := self localVariableList.
    bindings := Dictionary new: locals size.
    values := Array new: locals size.
    1 to: locals size do:
        [:idx |
        values at: idx put: (self localVariableAt: idx).
        bindings at: (locals at: idx) put: (values at: idx)].
    compiler := CompilerInterface new.
    compiler errorHandler: (TextPaneErrorHandler new pane: aTextPane).
    compiler nameScope:
        (compiler scopeForReservedSymbolsExcluding: #('super')) ,
        (compiler scopeForClass: self doItInstance class) ,
        (compiler scopeForDictionary: bindings) ,
        compiler scopeForGlobals.
    compileResult := compiler evaluate: aString withReceiver: self doItInstance.
    compileResult wasSuccessful
        ifFalse: [^aBlock value].
    update := false.
    2 to: self activation argumentCount + 1 do:
        [:idx |
        (bindings at: (locals at: idx)) == (values at: idx)
            ifFalse: [update := true]].
    update
        ifTrue:
            [(MessageBox confirm: 'Restart at beginning of method?')
                ifFalse: [^self].
            exec := self selectedExecutable.
            self dropMethod: exec restartingWith: exec].
    2 to: locals size do:
        [:idx |
        (bindings at: (locals at: idx)) == (values at: idx)
            ifFalse:
                [update := true.
                self localVariableAt: idx put: (bindings at: (locals at: idx))]].
    update ifTrue: [self changed: #instance:].
    ^compileResult value! 
analyzeMethod: aMethod
        "Private - ensure that the cache contains debugging info for aMethod."
    | info |
    self infoCacheAt: aMethod ifAbsent:
        [
        "need to do full compilation so ic's can be translated"
        info := self createCacheInfoFor: aMethod.
        ( info notNil and: [ info wasSuccessful ] )
            ifTrue: [ self cacheInfo: info for: aMethod ]
        ]!  
label
        "Private - Answer the window label."
    ^self mainView label!
label: aString
        "Private - redraw the label with process name and aString."
    self debuggedProcess == nil
         ifTrue: [^super label: aString].
    ( aString includes: ${ )
        ifTrue: [ super labelWithoutPrefix: aString ]
        ifFalse: [ super label: (self makeLabel: aString) ]!
selectedMethodSelector
		"Private - answer the selector for the selected method."
    | executable |
    executable := self selectedExecutable.
    executable isNil ifTrue: [ ^nil ].
    ^executable selector! 
skip: aButton
        "Private - Resume process for one skip, i.e.,
         to next expression or assignment
         at current method level, or to
         next breakpoint."
    self skip!  
cacheInfo: methodInfo for: aMethod
        "Private - cache the compiled method info for later use."
    | cache |
    ( aMethod isCompiledMethod and: [ methodInfo method ~~ aMethod ] )
        ifTrue:
            [methodInfo method info: aMethod info.
            methodInfo flushICTables].
    cache := self getMethodInfoCache.
    self maxInfoCacheSize <= cache size ifTrue: [
        self resetInfoCache.
        cache := self getMethodInfoCache].
    cache at: aMethod put: methodInfo! 
isRestartable
        "Private - answer true if the process is restartable."
    | process processIndex |
    process := self debuggedProcess.
    process restartable
        ifFalse: [ ^false ].
    walkbackIndex isNil ifTrue: [ ^false ].
    self inBlock ifTrue: [ ^false ].
    processIndex := self  processWalkbackIndex.
    ( ( process methodAt: processIndex ) primitiveNumber ) = 0
            ifFalse: [ ^false ].
    ^true!
jump: aButton
        "Private - Resume process for one jump, i.e.,
         to next breakpoint."
    self jump!   
take: textPane
        "Private - accept the contents of textPane as an updated method
        and compile it.  Notify textPane if the compiler detects errors."

    | process oldExecutable result |
    walkbackIndex isNil
        ifTrue: [^textPane modified: false].
    CursorManager execute changeFor: [
        process := self debuggedProcess.
        oldExecutable := self selectedExecutable.
        result := self acceptMethod: textPane using: oldExecutable.
        result == nil
            ifTrue: [^textPane modified: true].
         oldExecutable selector = result selector
            ifFalse: [^textPane modified: false].
        self dropMethod: oldExecutable restartingWith: result ].
    self checkMenus.
    ^textPane modified: false! 
initWindowSize
        "Private - Answer the initial window extent."
    ^Display width * 3 // 4 @
        (Display height * 3 // 4)!  
isDebugger
        "Answer true if the receiver is a debugger"
    ^true!   
tempList: tempsPane
        "Private - Scan the source code of the selected
         method to build an OrderedCollection of the
         method temporary variables and argument names
         in declaration order.  Assign the collection
         to instance variable temps.  Set the contents
         of tempsPane."

     ( walkbackIndex isNil  or:  [ browseWalkback not ] ) ifTrue: [
            method := nil.
            ^tempsPane contents: String new ].
    "instIndex := nil."
    tempsPane contents: self localVariableList.
    tempsPane selectIndex: instIndex!
expandFrame: frame
        "Private - create a debugging version of a frame."
    | process cm dcm offset oldOffset interruptFrame|
    process := self debuggedProcess.
    cm := process methodAt: frame.
    cm isDebuggable
        ifTrue:
            [
            cm sourceIndex >= 3      "method source in dll"
                ifTrue: [ cm sourceObject: ( ( process receiverAt: frame )
                                methodFor: cm selector in: cm classField ) sourceString ]
            ]
        ifFalse:
            [
            interruptFrame := false.
            oldOffset :=  (process returnOffsetAt: frame - 1).
            (oldOffset = 0) ifTrue: [
                 interruptFrame := true.
                 oldOffset := process frameAt: frame - 1 offset: 7].
            (oldOffset = 1) ifTrue: [^self].
            dcm := cm asDebuggableMethod.
            offset := self convert: cm to: dcm offset: oldOffset.
            process methodAt: frame put: dcm.
            interruptFrame ifTrue: [
               process frameAt: frame - 1 offset: 7 put: offset]
                                     ifFalse: [
                 process returnOffsetAt: frame - 1 put: offset ]
             ]!  
inspectMenu: pane
        "Private - Set the dictionary
         inspector list pane menu."
    | menu |
    menu := (Menu
        labels: '~Inspect' withCrs
        lines: Array new
        selectors: #(#inspectSelection))
            title: '~Inspect';
            owner: self;
            yourself.
    menu disableItem: #inspectSelection.
    pane setMenu: menu!
menu: pane
        "Private - set the walkback pane menu for the debugger window."
    pane setMenu: ((Menu
        labels: (
            'More ~Levels\~Filter Stack\' ,
            '~Senders\~Implementors\~Messages\' ,
            '~Resume\Res~tart\Ter~minate\Drop ~Process...') withCrs
        lines: #( 2 5 )
        selectors: #(
            #moreLevels #toggleFilterActivations
            #senders #implementors #messages
            #resume #restart #terminate #dropProcess))
        title: '~Debugger';
        owner: self;
        yourself)!  
selectedExecutable
        "Answer the selected method or nil if none is selected"
    walkbackIndex == nil
        ifTrue: [ ^nil ].
    ^browseWalkback
        ifTrue: [ self debuggedProcess methodAt:  self  processWalkbackIndex ]
        ifFalse: [ breakpoints at: walkbackIndex ]!
inBlock
        "Answer true if the execution is currently in a block."

    ^self activation isCompiledMethod not!
selectInstance: aListPane
        "Private - Select the instance variable at
         index position anInteger in the list."
    instIndex := aListPane selection.
    self enableInspectItem.
    self changed: #instance:! 
debuggingProcess
        "Answer the process running the debugger."
    debuggingProcess isNil ifTrue: [^nil].
    [ debuggingProcess debugger notNil ]
        whileTrue: [ debuggingProcess := debuggingProcess debugger debuggingProcess ].
    ^debuggingProcess!
doItInstance
        "Return 'self'  to evaluate the doIt"
    ^object! 
walkbackFor: aProcess label: aString
        "Pop-up a walkback window with label equal to aString).  Display
        the stacked message sends for the receiver in the window."
    | recursing tmpStream |
    self debuggingProcess: nil.
    self setDebuggedProcess: aProcess.
    maxLevel := 40.
    recursing := RecursionInError notNil.
    RecursionInError notNil
        ifTrue: [
            tmpStream := String new asStream.
            tmpStream nextPutAll: 'Recursive Walkback'; cr.
            tmpStream nextPutAll: '    Original Error:'; cr.
            RecursionInError walkbackOn: tmpStream maxLevels: 100 stopSelector: nil filtered: false arguments: true.
            tmpStream cr; nextPutAll: '    Walkback Error:'; cr.
            aProcess walkbackOn: tmpStream maxLevels: 100  stopSelector: nil filtered: false arguments: true.
            tmpStream cr; nextPutAll: 'End Recursive Walkback Log'; cr.
            Smalltalk logError: tmpStream contents.
            Notifier closeAllHelpWindows.
            ( MessageBox confirm: 'Recursive Walkback: see ERROR.LOG.  Exit Smalltalk?' )
                ifTrue: [ Notifier quit ].
            RecursionInError := nil.
            ^self ]
        ifFalse: [
            RecursionInError := aProcess.
            self label: aString.
            logger := WalkbackWindow openOn: self label: aString.
            logger == nil
                ifTrue: [ "Unable to open a walkback window"
                    RecursionInError := nil.
                    Process enableInterrupts: true.
                    ^self ].
            logger pane disableRedraw ].
    aProcess debugger: self.
    tmpStream := ( String new: 200 ) asStream.
    aProcess walkbackOn: tmpStream maxLevels: maxLevel stopSelector: #Doit filtered: self filterActivations arguments: false.
    logger contents: tmpStream contents.
    RecursionInError := nil.
    Process enableInterrupts: true.
    ( recursing and: [ aString ~= 'Keyboard Interrupt' ] )
        ifTrue: [ ^Smalltalk exit ].
    logger pane selectBefore: 1 @ 1.
    logger pane enableRedraw.
    logger pane modified: false!   
dragDropSourcePanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag source."
    ^Array with: #walkbackList:!   
localVariableList
    "Private - Scan the source code of the selected
         method to build an OrderedCollection of the
         method temporary variables and argument names
         in declaration order."

    (walkbackIndex isNil or: [browseWalkback not])
        ifTrue: [^#()].
    variables := OrderedCollection with: 'self'.
    ( self method hasBlock and: [ self method usesBlockClosure not ] )
        ifTrue: [ variables addAll: self localVariableListOldMethod ]
        ifFalse: [
            self
                withInfoFor: self activation
                do: [:info | variables addAll: ( info debuggerVariablesAt: self ic ) ]
                ifAbsent: [ variables addAll: self localVariableListNoSource ] ].
    ^variables collect: [:v | v isString ifTrue: [ v ] ifFalse: [ v name ] ]!   
localVariableListNoSource
    "Private - Answer a list of invented
    method temporary variables and argument names
    when there is no source for the method."

    ^self localVariableListNoSource: true!
localVariableListNoSource: varsOnStack
    "Private - Answer a list of invented
    method temporary variables and argument names
    when there is no source for the method.
    varsOnStack indicates whether the variables are on the
    stack or in an environment."

    | answer |
    answer := OrderedCollection new.
    1 to: self activation argumentCount do: [:i |
        answer add: ( ( VariableLocatorNoSource forBinding: i )
            name: '.arg' , i printString;
            argument: true ;
            stack: varsOnStack ) ].
    self activation isCompiledMethod ifTrue: [
        1 to: self activation tempCount do: [:i |
            answer add: ( ( VariableLocatorNoSource forBinding: i )
                name: '.temp' , i printString;
                argument: false ;
                stack: varsOnStack ) ] ].
    ^answer!  
walkback
        "Private - answer an OrderedCollection of walkback or
        breakpoint lines."
    browseWalkback
        ifTrue: [walkback := self debuggedProcess walkbackListTo: #Doit maxLevels: maxLevel filtered: self filterActivations arguments: false]
        ifFalse: [
        walkback := OrderedCollection new.
            breakpoints do: [ :meth |
                walkback add:
                    meth classField name,
                        '>>',
                        meth selector]].
    ^walkback! 
infoCacheAt: key ifAbsent: aBlock0
        "Private - answer the cached method info for key."
    "|info|
    (info := key sourceObject) isCompilationResult ifTrue: [^info]."
    ^self getMethodInfoCache at: key ifAbsent: aBlock0!
walkbackMenu
        "Private - answer the walkback pane menu for the walkback window."
    ^(Menu
        labels: '~Debug\~Resume\Drop ~Process...' withCrs
        lines: #(1)
        selectors: #(#debug #resume #dropProcess))
            title: '~Walkback';
            owner: self;
            yourself!
debug
        "Private - close the walkback window and open a debugger
        window on the process."
    | process |
    process := self debuggedProcess.
    self setDebuggedProcess: nil.
    self closeLogger.
    self setDebuggedProcess: process.
    self class openOn: self labeled: self label!
debug: pane
        "Private - Turn walkback window into a debug window."
    self debug!   
dropProcess
        "Drop the process being debugged without running clean-up blocks."
    (MessageBox confirm: 'Really terminate the process without running clean-up blocks?')
        ifFalse: [^self].
    self debuggedProcess debugger: nil.
    self debuggedProcess terminateWithoutProtection.
    self setDebuggedProcess: nil.
    self debuggingProcess: nil.
    self close! 
checkMenus
        "Private - update the states of the hop/skip/jump related menu items."
    | debugMenu goMenu |
    debugMenu := self menuTitled: 'Debugger'.
    goMenu := self menuTitled: 'Go'.
	self filterActivations
		ifTrue: [debugMenu checkItem: #toggleFilterActivations]
		ifFalse: [debugMenu uncheckItem: #toggleFilterActivations].
    self isRestartable
        ifTrue: [ debugMenu enableItem: 'Restart' ]
        ifFalse: [ debugMenu disableItem: 'Restart' ].
    self isResumable
        ifTrue:
            [
            debugMenu enableItem: 'Resume'.
            goMenu enableItem: 'Hop'.
            goMenu enableItem: 'Skip'.
            goMenu enableItem: 'Jump'.
            ( self paneAt: 'Hop' ) enable.
            ( self paneAt: 'Skip' ) enable.
            ( self paneAt: 'Jump' ) enable.
            ]
        ifFalse:
            [
            debugMenu disableItem: 'Resume'.
            goMenu disableItem: 'Hop'.
            goMenu disableItem: 'Skip'.
            goMenu disableItem: 'Jump'.
            ( self paneAt: 'Hop' ) disable.
            ( self paneAt: 'Skip' ) disable.
            ( self paneAt: 'Jump' ) disable.
            ].!   
makeLabel: aString
        "Private - answer expanded label."
    ^'{' , self debuggedProcess name , '} ' , aString!
methodListCut: dragSession
        "Private - cut the dragged method on a move operation."
        "ignore delete requests"!
moreLevels
        "Private - Increase the number
         of walkback lines."
    maxLevel := maxLevel + maxLevel.
    self browseWalkback: nil! 
walkbackSelected: listPane
    "Private - A line in the walkback listPane
         has been selected."

    method := nil.
    self walkback: listPane selection!
filterActivations
	"Answer true if 'hidden' activations should be filtered out of the activation list."

	^filterActivations!  
filterActivations: aBoolean
	"Private."

	filterActivations := aBoolean!   
terminate
        "Private - terminate the debugged process & close the receiver."
    self mainView close! 
toggleFilterActivations
	"Toggle the state of <filterActivations> and redisplay the context stack."

	self filterActivations: self filterActivations not.
	walkbackIndex := 1.
	self checkMenus.
	self browseWalkback: nil! 
close
        "Private - Close the receiver."
    logger == nil
        ifFalse: [^self closeLogger].
    ^super close!   
closed
        "Private - the window on the receiver has been closed."

    | restarting |
    restarting := false.
    self debuggedProcess notNil ifTrue: [
        restarting := self debuggedProcess runable = 6.
        restarting
            ifTrue: [ self debuggedProcess terminateWithoutProtection ]
            ifFalse: [
                self debuggedProcess debugger: nil.
                self debuggedProcess terminate ] ].
    restarting ifFalse: [
        self setDebuggedProcess: nil.
        self debuggingProcess: nil ].!  
localVariableListOldMethod
    "Private - Answer a list of invented
    method temporary variables and argument names
    for 'old' methods (methods that use HomeContext
    instead of BlockClosure)."

    ^self localVariableListNoSource: false!   
processWalkbackIndex
        "Private- translate listbox index to process frame index."
    walkbackIndex isNil  ifTrue: [ ^nil ].
    ^debuggedProcess walkbackIndex: walkbackIndex filtered: self filterActivations! 
convert: aCompiledMethod to: aDebugCompiledMethod offset: anInteger
        "Private - convert aCompiledMethod into aDebugCompiledMethod."
    <primitive: 135>!
hasDebuggerWindow
        "Answer <true> if the receiver is being viewed by a debugger window,
        rather than by a walkback."
    ^logger == nil! 
localVariableAt: varIndex
    "Private - answer the value of the selected temporary variable."

    varIndex = 1 ifTrue: [^object].
    ^( variables at: varIndex ) valueFrom: self debuggedProcess frame: self processWalkbackIndex! 
resumable
        "Private - answer true if the process is resumable."
    self debuggedProcess restartable
        ifFalse:
            [MessageBox message: 'Process is not resumable'.
            ^false].
    self debuggedProcess runable = 1
        ifTrue:
            [MessageBox message: 'Process is not resumable but may be restarted'.
            ^false].
    ^true!   
getMethodInfoCache
        "Private - answer the cache of method info, creating if necessary."
    methodInfoCache == nil ifTrue: [methodInfoCache := IdentityDictionary new].
    ^methodInfoCache!   
dropMethod: oldExecutable restartingWith: newExecutable
    "Private - trim stack to oldExecutable and replace it with newExecutable."

    | process runLevel |
    process := self debuggedProcess.
    runLevel := process runable.
    runLevel > 1
        ifTrue: [process runable: 1].
    process dropTo: oldExecutable.
    process methodAt: 1 put: newExecutable.
    process returnOffsetAt: 0 put: 1.
    (oldExecutable hasBlock ~= newExecutable hasBlock
            or: [oldExecutable tempCount ~= newExecutable tempCount])
        ifTrue: [process dropFrame].
    self
        walkback;
        walkback: 1.
    self
            changed: #walkbackList:
            with: #restoreWithRefresh:
            with: 1!  
selectedMethod
		"Private - answer the selected method."
    ^self selectedExecutable!  
suspendDebuggedProcess
        "Private - the process being debugged has evaluated one
        of the protection blocks to completion. Suspend it, trimming
        the stack as appropriate, and resume the debugging process,
        which is trying to drop frames."
    | process index |
    process := Process copyStack.
    self setDebuggedProcess: process.
    index := 1.
    [(process nextFrameAt: index) = process sendFrame]
        whileFalse: [index := index + 1].
    index
        timesRepeat:
            [process dropFrameWithoutProtection].
    realFrame := process topFrame.
    process topFrame: (process nextFrameAt: 0).

    process runable: 4.
    CurrentProcess := self debuggingProcess.
    CurrentProcess makeUserIF.
    Process enableInterrupts: true.
    CurrentProcess resume: 0!   
goMenu
        "Private - Answer the hop, skip, jump menu."
    ^(Menu
        labels: '~Hop\~Skip\~Jump' withCrs
        lines: #()
        selectors: #(#hop #skip #jump))
            title: '~Go';
            owner: self;
            yourself.!
takeControl: errorMessage
        "Private - the process being debugged has encountered an error,
        described by the <errorMessage>, that would normally bring up
        a debugger. Resume execution of the receiver instead of
        creating a new debugger."
    Processor traceMode: 0.
    Process copyStack.
    self debuggedProcess dropFrameWithoutProtection.
    self debuggingProcess: nil.
    CurrentProcess := Process new.
    CurrentProcess makeUserIF.
    Process enableInterrupts: true.
    self hasDebuggerWindow
        ifTrue: [self browseWalkback: true]
        ifFalse: [self changed: #walkback:].
    self label: errorMessage.
    Notifier run!   
methodListSetDragObject: dragSession
        "Private - set the method to drag."
    | dragDropObject method stream |
    self selectedMethod isNil ifTrue: [ ^nil ].
    method := self selectedMethod.
    dragDropObject := dragSession objectClass new
        object: method;
        format: 'compiledMethod' data: method;
        yourself.
    method sourceString notNil ifTrue: [
        stream := String new asStream.
        ( ClassReader forClass: method classField ) fileOutMethod: method selector on: stream.
        dragDropObject string: stream contents ].
    dragSession objects: ( Array with: dragDropObject )!
enableMethodsMenu
        "Private - Enable the methods menu."
    self methodsMenu enableAll!  
confirmDeletes
		"Private - answer whether deletions are to be prompted for
		confirmation."
    ^true!
classesMenu
        "Private - answer the Classes menu."
	^self menuTitled: 'Class'!
messages
        "Private - Open a browser on the messages sent
         by the selected method."
	| method |
	( method := self selectedMethod ) notNil
		ifTrue: [ SourceManager current messagesIn: method ]!  
fileOutClass
        "Private - Write the source for the selected class
         in chunk file format to a file named with the class
         name reduced to 8 characters, extension 'cls'."
    | class file fileName fileDialog |
	( class := self selectedClass ) isNil ifTrue: [ ^nil ].
	fileName := File fileName: class name extension: 'cls'.
	fileDialog := FileDialog new
		saveTitle: 'File out ', class name, ' class'
		fileName: fileName.
	( file := fileDialog file ) isNil ifTrue: [ ^nil ].
    ( ClassReader forClass: class ) fileOut: file!  
localImplementors
        "Private - Pop-up a window with the
         local implementors of the selected method."
	| class selector |
	( class := self selectedClass ) isNil ifTrue: [ ^nil ].
	( selector := self selectedMethodSelector ) isNil ifTrue: [ ^nil ].
	Smalltalk implementorsOf: selector in: class! 
methodsMenu
        "Private - answer the Methods menu."
	^self menuTitled: 'Method'!   
fileOutClassWithSubclasses
        "Private - Write the source for the selected class
         in chunk file format to a file named with the class
         name reduced to 8 characters, extension 'cls'."
    | class file fileName fileDialog |
	( class := self selectedClass ) isNil ifTrue: [ ^nil ].
	fileName := File fileName: class name extension: 'cls'.
	fileDialog := FileDialog new
		saveTitle: 'File out ', class name, ' class'
		fileName: fileName.
	( file := fileDialog file ) isNil ifTrue: [ ^nil ].
    ( ClassReader forClass: class ) fileOutAll: file! 
compile: aString in: aClass
        "Private - Accept aString as an updated
        method and compile it, logging source to
        the change log if successful."
    | answer |
    CursorManager execute changeFor: [
        answer := aClass compile: aString ].
    answer notNil ifTrue: [
        SourceManager current
            logSource: aString
            forSelector: answer key
            inClass: aClass ].
    ^answer!   
compile: aString notifying: aDispatcher in: aClass
        "Private - Accept aString as an updated
        method and compile it, logging source to
		the change log if successful.  Notify aDispatcher
        if the compiler detects errors."
    | answer |
    CursorManager execute changeFor: [
        answer := aClass compile: aString notifying: aDispatcher ].
	answer notNil ifTrue: [
		SourceManager current
            logSource: aString
            forSelector: answer key
            inClass: aClass ].
    ^answer!   
selectedMethodSelector
		"Private - answer the selector for the selected method."
	self implementedBySubclass!  
fileOutMethod
        "Private - Write the source for the selected method
         in chunk file format to a file named with the method
         name reduced to 8 characters, extension 'mth'."
    | method file fileName fileDialog |
    ( method := self selectedMethod ) isNil ifTrue: [ ^nil ].
    fileName := File fileName: ( method selector reject: [ :c | c = $: ] ) extension: 'mth'.
    fileDialog := FileDialog new
        saveTitle: 'File out ', method selector, ' method'
        fileName: fileName.
    ( file := fileDialog file ) isNil ifTrue: [ ^nil ].
    file := File newFile: file.
    ( ClassReader forClass: method classField ) fileOutMethod: method selector on: file.
    file close.!
selectedClass
		"Private - answer the selected class."
	self implementedBySubclass! 
disableMethodsMenu
        "Private - Disable the methods menu."
    self methodsMenu disableAll!   
localSenders
        "Private - Pop-up a window with the
         local senders of the selected method."
	| class selector |
	( class := self selectedClass ) isNil ifTrue: [ ^nil ].
	( selector := self selectedMethodSelector ) isNil ifTrue: [ ^nil ].
	Smalltalk sendersOf: selector in: class!
selectedMethod
		"Private - answer the selected method."
	self implementedBySubclass!   
senders
        "Private - Pop-up a window with the
         senders of the selected method."
	| selector |
	( selector := self selectedMethodSelector ) notNil
		ifTrue: [ Smalltalk sendersOf: selector ]! 
template
        "Private - Answer the
         template for methods."
    ^'messagePattern
    "comment"

    | temporaries |
    statements'!
implementors
        "Private - Pop-up a window with the
         implementors of the selected method."
	| selector |
	( selector := self selectedMethodSelector ) notNil
		ifTrue: [ Smalltalk implementorsOf: selector ]!  
saveImageNoConfirm
        "Private - Save the image without asking for confirmation."
    | answer |
    CursorManager execute changeFor: [
        answer := self saveImageFile ].
    ^ answer!   
matchBracketChars
        "Private - Select the nearest surrounding brackets."
    | left right char |
    CursorManager execute changeFor: [
        self getText.
        self getSelection.    "Set selection inst var."
        left := selection x.
        right := selection y.
            "Worry if the user has selected a single bounding bracket."
        selection y = selection x ifTrue: [     "Single char selected."
        char := self charAt: selection y.
        ( LeftBrackets includes: char )
            ifTrue: [ left := left + 1 ]
            ifFalse: [
                ( RightBrackets includes: char )
                    ifTrue: [ right := right - 1 ] ] ].
        self matchBracketFrom: left  to: right ]!   
for: anXCBlock
	"Private - Create an instance of the receiver."

	^self new block: anXCBlock!  
isOpenCoded
    "Answer true if the block was converted to inline code by the compiler return false otherwise."

	^block isOpenCoded!  
wasSuccessful
	"Answer <true> if the receiver represents a successful compilation."

	^true!   
debuggerVariablesAt: ic
    "Return a collection of variable locators for variables visible to the method at ic in its execution."

	| xcScope |
	xcScope := block scopeWhoContains: ( block compiler info translateProcessorIC: ic ).
	^( xcScope notNil and: [ xcScope isBlock ] )
		ifTrue: [ ( self class for: xcScope ) debuggerVariables ]
		ifFalse: [ self debuggerVariables ].!   
debuggerVariables
    "Return a collection of variable bindings for variables visible to the block."

	^block isOpenCoded
		ifTrue: [ self debuggerVariablesOpenBlock ]
		ifFalse: [ self debuggerVariablesRealBlock ]!  
debuggerVariablesFor: aScope
    "Private"

    ^aScope dictionary values asOrderedCollection collect: [:var | VariableLocator forBinding: var ]!  
block: anXCBlock
    "Private - Set the receiver's block."

    block := anXCBlock!
debuggerVariablesOpenBlock
    "Return a collection of variable bindings for variables visible to the block."

    | vars eachBlock |
    eachBlock := block.
    vars := OrderedCollection new.
    [ eachBlock isBlock and: [ eachBlock isOpenCoded ] ] whileTrue: [
        vars addAll: ( self debuggerVariablesFor: eachBlock argumentScope ).
        vars addAll: ( self debuggerVariablesFor: eachBlock temporaryScope ).
        eachBlock := eachBlock parent ].
    eachBlock isBlock
        ifTrue: [ vars addAll: ( self class for: eachBlock ) debuggerVariables ]
        ifFalse: [ vars addAll: eachBlock compiler info debuggerVariables ].
    ^vars!
debuggerVariablesRealBlock
    "Return a collection of variable bindings for variables visible to the block. This will include all temporaries, arguments, temporaries or arguments referenced from containing blocks or the method. It will also include any variables from open coded blocks immediately contained within this block."

    | vars scope |
	vars := self debuggerVariablesFor: block argumentScope.
    vars addAll: ( self debuggerVariablesFor: block temporaryScope ).
	scope := block argumentScope.
	[ ( scope := scope enclosingScope ) description = block inheritedScopeName ] whileTrue: [
		vars addAll: ( self debuggerVariablesFor: scope ) ].
	scope := block temporaryScope.
	[ ( scope := scope enclosingScope ) description = block inheritedScopeName ] whileTrue: [
		vars addAll: ( self debuggerVariablesFor: scope ) ].
    ^vars! 
blockNumber
    "Return the block number used by the compiler to identify this in its block closure.  If the block is open coded the block number is nil."

	^block blockID!   
literalNumber
    "<Integer>
Return the index in the literal array for the BlockClosure template that is used to construct the block closure for this block. The structure of the BlockClosure template is defined in the document “Compatible V32 Virtual Machine Architecture Model” by Horstkotte, et. al."! 
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a
        subclass of the receiver with the specifed instance variables,
        class variables, pool dictionaries, and class instance variables."

	^self
		subclass: className
    	instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
    	poolDictionaries: poolDictionaries
		isVariable: self isVariable
		isPointers: self isPointers! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #hwnd
        #msg
        #wparam
        #lparam
        #time
        #pt
    )!   
initWindowSize
        "Private - Answer the window size."
    ^(42 @ 7) * WindowDialog unitMultiplier! 
getBackupImage
        "Private - Set BackupImage flag."
    BackupImage := cbBackupImage selection.!   
openYesNo
        "Private - Open a dialog box Asking user if they want to save a image
          with 'Yes' & 'No' buttons."
	self
		createPanesYesNo;
		openWindow!
createPanesYesNo
        "Private - create the panes for a Yes/No window."
    | font unitMultiplier pane |
    answer := false.
    font := self class platformDefaultFont.
    unitMultiplier := self class unitMultiplier.
    self
        addView: ( self mainView
			owner: self;
            font: font;
            yourself );
        labelWithoutPrefix: 'Save Image';
        addSubpane: ( StaticText new
            contents: 'Existing image will be overwritten. Continue?';
            framingBlock: [ :box | ( box leftTop rightAndDown: 2@1 * unitMultiplier )
                extentFromLeftTop: 39@1 * unitMultiplier ] );
        addSubpane: ( cbBackupImage := CheckBox new
            contents: 'Make Backup';
            selection: BackupImage;
            framingBlock: [ :box | ( box leftTop rightAndDown: 2@(5/2) * unitMultiplier )
                extentFromLeftTop: 20@(3/2) * unitMultiplier ] );
        addSubpane: ( ( pane := Button new )
			setName: #yes;
            defaultPushButton;
            contents: 'Yes';
            when: #clicked send: #yes: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 2@(9/2) * unitMultiplier )
                extentFromLeftTop: 10@2 * unitMultiplier ] );
		addSubpane: ( ( pane := Button new )
			setName: #no;
            contents: 'No';
            when: #clicked send: #no: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 13@(9/2) * unitMultiplier )
                extentFromLeftTop: 10@2 * unitMultiplier ] )
!  
openYesNoCancel
        "Private - Open a dialog box Asking user if they want to save a image
          with 'Yes' & 'No' & 'Cancel' buttons."
    self
		createPanesYesNoCancel;
		openWindow!  
no: aButton
        "Private - No button pushed, close the window."
    answer := false.
    self getBackupImage.
    self mainView close!
cancel: aButton
        "Private - Cancel button pushed, close the window."
    answer := nil.
    self getBackupImage.
    self mainView close!  
answer
        "Private - Answer the id of the button the user pressed.
        Answer nil if the user hit the escape key."
    ^answer!   
yes: aButton
        "Private - Yes button pushed, close the window."
    answer := true.
    self getBackupImage.
    self mainView close.!  
createPanesYesNoCancel
        "Private - create the panes for a Yes/No/Cancel window."
    | font unitMultiplier pane |
    font := self class platformDefaultFont.
    unitMultiplier := self class unitMultiplier.
    self
        addView: ( self mainView
            owner: self;
            font: font;
            yourself );
        labelWithoutPrefix: 'Exiting';
        addSubpane: ( StaticText new
            contents: 'Save image before exiting?';
            framingBlock: [ :box | ( box leftTop rightAndDown: 2@1 * unitMultiplier )
                extentFromLeftTop: 39@1 * unitMultiplier ] );
        addSubpane: ( cbBackupImage := CheckBox new
            contents: 'Make Backup';
            selection: BackupImage;
            framingBlock: [ :box | ( box leftTop rightAndDown: 2@(5/2) * unitMultiplier )
                extentFromLeftTop: 20@(3/2) * unitMultiplier ] );
        addSubpane: ( ( pane := Button new )
            setName: #yes;
            setFocus;
            defaultPushButton;
            contents: 'Yes';
            when: #clicked send: #yes: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 2@(9/2) * unitMultiplier )
                extentFromLeftTop: 10@2 * unitMultiplier ] );
		addSubpane: ( ( pane := Button new )
			setName: #no;
            contents: '\uNo' replaceEscapeCharacters;
            when: #clicked send: #no: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 13@(9/2) * unitMultiplier )
                extentFromLeftTop: 10@2 * unitMultiplier ] );
		addSubpane: ( ( pane := Button new )
			setName: #cancel;
            contents: 'Cancel';
            when: #clicked send: #cancel: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 24@(9/2) * unitMultiplier )
                extentFromLeftTop: 10@2 * unitMultiplier ] )!  
changeSuperclassTo: newSuperclass
        "Change the superclass of the receiver to be <newSuperclass>."
 
	newSuperclass
		subclass: self symbol
   		instanceVariableNames: self instanceVariableString
    	classVariableNames: self classVariableString
		poolDictionaries: self sharedVariableString
		isVariable: self isVariable
		isPointers: self isPointers!   
setIcon: aButton
        "Private - the user selected the Icon button; open a FileDialog
        to prompt for an .ICO file."
    | file |
    file := FileDialog new
        addFilter: '*.ico' description: 'Icon Files (*.ico)';
        open;
        file.
    file isNil ifTrue: [ ^nil ].
    iconFileName := file.
    self changed: #displayIcon:! 
setInstList
        "Private - Initialize an OrderedCollection of instance variable
         names and/or numbers for the list pane."
    instList := OrderedCollection new.
    instList add: 'self'.
    1 to: object size do: [ :index |
        instList add: index printString ]!  
accept: textPane
        "Private - Replace the selected instance variable
         with the result of evaluating the contents of textPane."
    | aString result |
    instIndex isNil ifTrue: [ ^self ].
    aString := textPane contents.

    SourceManager current
        logEvaluate: aString
        for: [
            result := CompilerInterface
                evaluate: aString
                in: object class
                to: object
                notifying: textPane
                ifFail: [ ^textPane modified: true ] ].

    instIndex > 1
        ifTrue: [ object at: ( instIndex - 1 ) put: result ].
    self changed: #instance:.
    textPane modified: false!
inspectSelection
        "Private - Open an Inspector on the selected instance variable."
    instIndex = 1
        ifTrue: [ object inspect ]
        ifFalse: [ ( object at: ( instIndex - 1 ) ) inspect ]! 
instance: textPane
        "Private - Set the ASCII representation of the selected
         instance variable."
    instIndex isNil
        ifTrue: [ ^textPane contents: String new ].
    instIndex = 1
        ifTrue: [ ^textPane contents: object printString ].
    ^textPane contents: ( object at: instIndex - 1 ) printString!
addLeftBracket: leftBracketChar rightBracket: rightBracketChar
        "Private - Put parens around the selection."
    priorSelection := self selection.
    newSelection := selection corner: (textHolder
        replace: (TextSelection
            origin: selection corner + (1 @ 0)
            corner: selection corner)
        withChar: rightBracketChar ).
    textHolder
        replace: (TextSelection
            origin: selection origin
            corner: selection origin - (1 @ 0))
        withChar: leftBracketChar.
    self selectAfter: ( selection corner y = selection origin y
        ifTrue: [ self selection corner + (1@0) ]
        ifFalse: [ selection corner] ).
    modified := true.
    self
        displayChanges;
        forceSelectionOntoDisplay!  
defaultPoolNames
        "Return a collection containing the names of any shared pools that should
        be automatically placed in the compilation name scope of workspaces."
    ^CompilerInterface defaultPoolNames!  
on: aPane
        "Answer a new instance of the receiver attached to aPane."
    ^self new pane: aPane! 
buildCompilationScope
        "Private - create the compilation name scope for this
        workspace.  Note that self and super are NOT allowed in
        expressions."
    | c |
    c := self compiler.
    ^( c scopeForReservedSymbolsExcluding: #( 'super' ) ),
        ( ( c scopeForDictionary: self variableDictionary )
            description: 'workspace variable';
            yourself ),
        self poolScope,
        c scopeForGlobals!   
errorHandlerClass
        "Private - return the class used to handle compilation errors
        when compiling expressions from this workspace."
    ^WorkspaceErrorHandler!   
variableDictionary
        "Return a dictionary of variables that are bound in this workspace."
    variableDictionary == nil
        ifTrue: [ variableDictionary := self dictionaryClass new ].
    ^variableDictionary!
compilerClass
        "Private - return the class used to compile expressions selected
        in this workspace."
    ^CompilerInterface! 
declareVariable: aString
        "Create a workspace variable whose name is specified by aString."
    self variableDictionary at: aString put: nil!
evaluate: aString ifError: errorBlock
        "Private - evaluate aString as compiled Smalltalk source code.
        If a compilation error occurs, answer the result of evaluating
        errorBlock, otherwise answer the result of the evaluation."
    | c compileResult |
    c := self compiler nameScope: self compilationScope.
    SourceManager current
        logEvaluate: aString
        for: [
            compileResult := c evaluate: aString.
            compileResult wasSuccessful ifFalse: [ ^errorBlock value ] ].
    ^compileResult value!   
poolScope
        "Private - return a name scope that binds any pool variables
        that are accessible from this workspace."
    | localPools  poolVariableScope comp |
    ( localPools := self pools ) isEmpty ifTrue: [ ^DictionaryScope new ].
    poolVariableScope := MultiplePoolScope new.
    comp := self compiler.
    localPools associationsDo: [ :assoc |
        poolVariableScope add:
            ( comp scopeForPool: assoc key named: assoc value ) ].
    ^poolVariableScope!   
compilationScope
        "Private - return the name scope used to resolve variable
        references when compiling expressions in this workspace."
    compilationScope == nil
        ifTrue: [ compilationScope := self buildCompilationScope ].
    ^compilationScope!  
compiler
        "Private - return the compiler object that will compile expressions
        for this workspace."
    compiler == nil ifTrue: [ compiler := self buildCompiler ].
    ^compiler!  
defaultPools
        "Private - build the default pools dictionary, and initialize it."
    | d |
    d := Dictionary new.
    self class defaultPoolNames do: [ :name|
        d at: ( Smalltalk at: name asSymbol ) put: name asString ].
    ^d! 
dictionaryClass
        "Private - return the class that is used as a dictionary to hold
        workspace variable associations."
    ^Dictionary!
pools
        "Private - return a dictionary whose keys are the actual
        variable pools (i.e. dictionaries) that are to be included
        within the variable name scope when compiling Smalltalk
        expressions in the context of this pane.  The values are
        the (string) names of the pools."
    pools == nil ifTrue: [ pools := self defaultPools ].
    ^pools!  
buildCompiler
        "Private - create a compiler object with an appropriate
        error handler for this workspace."
    | c |
    c := self compilerClass new.
    c errorHandler: ( self errorHandlerClass new pane: self ).
    ^c!  
pane: aPane
		"Private - set the pane to which the receiver is attached to aPane."
    pane := aPane!   
doItcompilerError: aString at: anInteger in: codeString for: aClass
        "Private - Display the error message aString
         as the selected text at the indicated position
         anInteger in the source codeString."
    | offset xOffset yOffset |
    offset := self pane selection.
    offset := offset isTextSelection
        ifTrue: [
            xOffset := 0.
            yOffset := 1.
            [ yOffset < offset origin y ] whileTrue: [
                xOffset := xOffset + ( self pane lineAt: yOffset ) size + 2.  "cr/lf"
                yOffset := yOffset + 1 ].
            xOffset := xOffset + offset origin x.
            xOffset + anInteger - 2 ]
        ifFalse: [ offset x + anInteger - 2 ].
    self pane
        selectAfter: offset;
        insertAfterSelection: aString! 
evaluate: aString ifError: errorBlock
        "Private - evaluate aString as compiled Smalltalk source code.
        If a compilation error occurs, answer the result of evaluating
        errorBlock, otherwise answer the result of the evaluation."
    | result |
    SourceManager current
        logEvaluate: aString
        for: [
            result := ( pane owner respondsTo: #doItResult:error: )
                ifTrue: [ pane owner doItResult: self pane error: errorBlock ]
                ifFalse: [
                    CompilerInterface
                        evaluate: aString
                        in: UndefinedObject
                        to: nil
                        notifying: self
                        ifFail: errorBlock ] ].
    ^result!  
pane
		"Private - answer the pane to which the receiver is attached."
    ^pane!
saveCompilerError: aString at: anInteger in: codeString for: aClass
        "Private - Display the error message aString
         in reversed form at the indicated
         position anInteger in the source
         codeString."
    self pane
        selectFrom: anInteger to: anInteger;
        insertAfterSelection: aString;
        sendInputEvent: #setFocus!  
compilerError: aString at: anInteger in: codeString for: aClass
        "Private - Display the error message aString
         in reversed form at the indicated
         position anInteger in the source
         codeString."
    pane isReadOnly
        ifTrue: [ ^MessageBox notify: 'Compilation Error' withText: aString ].
    pane evaluating
        ifTrue: [
            self
                doItcompilerError: aString
                at: anInteger
                in: codeString
                for: aClass ]
        ifFalse: [
            self
                saveCompilerError: aString
                at: anInteger
                in: codeString
                for: aClass ]! 
initialize
        "Private - Initialize the receiver class."
    self
        initializeAtSelectors;
        initializeCallingConventions;
        startUp! 
initialize
	"Register the receiver with the HostFileSystemError exception."
	"TooManyOpenFiles initialize"

	HostFileSystemError 
		mapErrorCode: 4
		to: self! 
sourceString: aString
        "Record aString as the current source code for the receiver.
		Perform any bookkeeping work as well (write to the change log,
		for example)"
  	
	self definition setSourceString: aString!   
createView
        "Open a dialog box telling about this product."
    | pane |
    self
        addView: ( ( pane := self mainView )
            owner: self;
            noSmalltalkMenuBar;
            noDefaultStyle;
            addSystemMenuStyle;
            addTitleBarStyle;
            when: #closed send: #close: to: self with: pane;
            when: #timer: send: #timer: to: self with: pane;
            yourself );
        labelWithoutPrefix: 'About ', WindowLabelPrefix;
        addSubpane: ( ( pane := GraphPane new )
            owner: self;
            setName: #graph;
            removeVerticalScrollbarStyle;
            removeHorizontalScrollbarStyle;
            removeBorderStyle;
            when: #display send: #display: to: self with: pane;
            when: #button1Down send: #close to: self;
            framingBlock: [ :box | box ] )!
addCurlyBrackets
        "Private - Bracket the selected text in a pair of {}"
    self addLeftBracket: ${ rightBracket: $}!
variableSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a variable
        subclass of the receiver with the specifed instance variables,
        class variables, and pool dictionaries."

	^self
		subclass: className
    	instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
		poolDictionaries: poolDictionaries
		isVariable: true
		isPointers: true!   
backupImage
        "Private - Make backup of the image file "
    ^self
        backup: self imageName
        sourceIndex: 0
        message: 'Your image could not be saved'! 
initialize
        "Private - initialize the receiver."
	defaultOptions := IdentityDictionary new
		at: #language put: #extended;
		at: #warnObsolete put: false;
		at: #warnQuestionable put: true;
		yourself!
forClass: class errorHandler: errorHandler
	"Answer an instance of the receiver representing a context in which source
	code can be compiled. The context specifies that names are to be resolved
	in a name scope resulting from the composition of a name scope created
	from the <class> and the default global name scope. Errors are to be handled
	by sending messages to the given <errorHandler>."

	|c|
	c :=self forClass: class.
	c	errorHandler: errorHandler.
	^c!
globalDictionary: dictionary
	"Answer an instance of the receiver representing a context in which source
	code can be compiled. The context specifies that names are to be resolved
	in a name scope created from the global <dictionary>. Errors are to be handled
	by sending messages to the  default error handler."

	|c|
	c := self new.
	c	nameScope: (c scopeForDictionary: dictionary);
		errorHandler: c defaultErrorHandler.
	^c!
defaultOptions
	"Answer a Dictionary containing the default compilation options.  The
	default implementation uses combines the receiver's default options with
	the default options provided by any CompilerInterface super classes"

    defaultOptions == nil
        ifTrue:
            [defaultOptions :=
				(self = CompilerInterface)
              	ifTrue: [IdentityDictionary new]
              	ifFalse: [self superclass defaultOptions copy]].
    ^defaultOptions
!  
forClass: class
	"Answer an instance of the receiver representing a context in which source
	code can be compiled. The context specifies that names are to be resolved
	in a name scope resulting from the composition of a name scope created
	from the <class> and the default global dictionary. Errors are to be handled
	by sending messages to the default error handler."

	|c|
	c := self new.
	class setCompilationOptions: c.
	c	nameScope: (c scopeForClass: class) , (c scopeForGlobals).
	c errorHandler: c defaultErrorHandler.
	^c!
environment: nameScope
errorHandler: errorHandler
	"Answer an instance of the receiver representing a context in which source
	code can be compiled. The context specifies that names are to be resolved
	in the given <nameScope> and that errors are to be handled by sending
	messages to the given <errorHandler>."

	| context |
	context := self new.
	context nameScope: nameScope.
	context errorHandler: errorHandler.
	^context!
setDefaultOptionsFrom: compilerInterface
    "Set the default options to be the same as the options defined for the given <compilerInterface>.
     To change the default options for the compiler create a new instance of compiler interface,
     use removeOption:, setOption and setOption:with: to change the compiler options to those
     desired then pass that instance as an argument to this method.
     An example:
        | ciwdo |
        ciwdo := CompilerInterface new.
        ciwdo options do: [ :anOpt| ciwdo removeOption: anOpt.].
        ciwdo addOption: #language with: #extended.
        ciwdo addOption: #warnQuestionable with: true.
        ciwdo addOption: #warnObsolete with: false.
        CompilerInterface setDefaultOptionsFrom: ciwdo.  "

    | newOptions |
    newOptions := compilerInterface getOptions.
    defaultOptions := IdentityDictionary new: newOptions size.
    newOptions
        keysAndValuesDo:
            [:optionName :optionValue |
            defaultOptions at: optionName put: optionValue]!   
addOption: aSymbol
	"Add a compilation option identified by the symbol with true as its value"
	^self addOption: aSymbol with: true!
getOptions
        "Private - this is the accessor for the instance variable
        options.  It is self initializing."
    options == nil ifTrue: [options := self initialOptions].
    ^options!   
errorHandler: anErrorHandler
	"Set or change the error handler that will receive notification
	if any errors are detected to be <anErrorHandler>."

	self setErrorHandler: anErrorHandler.
	anErrorHandler compiler: self!  
nameScope
	"Answer the name scope in which names will be resolved."
	^self getNameScope!   
classVariableScopeFor: aClass
	"return a scope containing all of the class variable
	bindings for the argument class"

	| classVariableScope thisClass|
	aClass isMetaClass
		ifTrue: [thisClass := aClass instanceClass]
		ifFalse: [thisClass := aClass].
	classVariableScope := MultiplePoolScope new.
	classVariableScope add:
		(GlobalPoolScope
			for: thisClass classPool
			bindingClass: (self bindingClassForAssociations)
			description: 'Class Variable for ', thisClass name).
	thisClass allSuperclasses  do: [:c|
		classVariableScope add:
			(GlobalPoolScope
				for: c classPool
				bindingClass: (self bindingClassForAssociations)
				description: 'Class Variable for ', c name)].
	^classVariableScope!
nameScope: aNameScope
	"Set the name scope in which names will be resolved to be <aNameScope>."
	self setNameScope: aNameScope!
resetOptions
	"Reset the options to their default value"
	
	options := self initialOptions!
locateMessagePattern: sourceCode
	"Answer an interval that locates the message pattern within <sourceCode>"
	^self useCompiler
		selectorInterval: sourceCode!
bindingClassForReadOnlyAssociations
	"return the class of binding used to represent read-only association-based variables"
	^self compiler readOnlyAssociationBindingClass! 
compile: sourceCode withMessagePattern: bool
	"Compile the Smalltalk <sourceCode> as a method in the
	context of the receiver. Answer a CompilationResult that
	can be queried to determine the result of the compilation."

	bool
		ifTrue: [^self compile: sourceCode]
		ifFalse: [^self compileForEvaluation: sourceCode]! 
compileForEvaluation: sourceCode
	"Compile an anonymous method (one without a message pattern)
	in a manner intended for evaluation as a do-it or initializer"
	^self useCompiler
		compileForEvaluation: sourceCode!
bindingClassForPoolNamed: aString
	"return the class of binding used to represent elements
	of the pool named by the argument"

	|cp|
	cp := Smalltalk at: #ConstantPoolNames ifAbsent: [IdentityDictionary new].
	(cp includes: aString asSymbol)
		ifTrue: [^self compiler constantAssociationBindingClass]
		ifFalse: [^self compiler associationBindingClass]!
getNameScope
    "Private - this is the accessor for the instance variable selectorScope"

    nameScope == nil ifTrue: [ nameScope := self defaultNameScope].
    ^nameScope!
defaultNameScope
    "Answer the name scope that, by default, is used for compilations out of context.
    it is an empty scope."

    ^ DictionaryScope new description: 'global scope'.!
parseSelector: sourceCode
	"Answer the selector from <sourceCode>"
	^self useCompiler
		parseSelector: sourceCode!
setNameScope: s
	"Private - this is the assignment accessor for the instance
	variable selectorScope"

	nameScope := s!   
evaluate: sourceCode withReceiver: receiver
	"Compile the Smalltalk <sourceCode> as an expression
	in the context of the receiver. If compilation is successful,
	answer the result of of evaluating the resulting executable.
	The pseudo-variable <self> be bound to the receiver."

	|result|
	result := self useCompiler compileForEvaluation: sourceCode.
	result wasSuccessful ifTrue: [result evaluateFor: receiver].
	^result!   
preferedAsGlobalHead: aCharacter
	"Answer true if the argument is prefered as the first character of a global identifier.
    X3J20 allows any identifier to be a global but suggests using Uppercase."

	^aCharacter isUpperCase or: [aCharacter = $_]!  
scopeForInstanceVariableNames: instVarNames
	"Create a name scope binding the instance variable names contained in
	the argument list:
					instVarNames <Collection of: String>"

	|s b p|
	s := DictionaryScope new description: 'instance variable'.
	b := self compiler instanceVarBindingClass.
	p := 0.
	instVarNames do: [:n|
		s declare: n boundTo: (b new name: n position: (p := p + 1))].
	^s! 
scopeForDictionary: dict
	"Answer a name scope appropiate for this compile that represents
	the names that are the keys of the argument dictionary.  The keys
	of the dictionary should normally be strings, not Symbols. If the keys
	are symbols, the message #useSymbolKeys should be explicitly send
	to the object returned from this method"

	^GlobalPoolScope for: dict bindingClass: (self bindingClassForAssociations)! 
scopeForReservedSymbols
	"Answer a name scope appropiate for this compiler that represents the
	reserved symbols within a Smalltalk method. These are:
		nil, true, false,self,super"

	^self scopeForReservedSymbolsExcluding: #()! 
getCompiler
        "Private - this is the accessor for the instance variable
        compiler.  It is self initializing."
    compiler == nil
		ifTrue: [compiler := self defaultCompilerClass new environment: self].
    ^compiler!   
addOption: aSymbol with:value
	"Add a compilation option identified by the symbol with value as its binding"
	^self getOptions at: aSymbol put: value!  
validInIdentifierBody: aCharacter
	"Answer true if the argument is valid as the second or subsequent
	character of an identifier"

	^aCharacter isLetter or: [aCharacter isDigit or: [aCharacter = $_]]!  
poolVariableScopeFor: aClass
    "Return a scope containing all of the pools for the argument aClass." 
    | aPool poolVariableScope pools |
    pools := aClass sharedPools.
    (Smalltalk platform = 'OS/2') ifTrue: [
        "For backwards compatability on OS/2 systems, PMConstants (or OperatingSystemConstants)
        may be referenced as pools at the same time as ColorConstants
        even though these pools contain duplicate entries.  (ColorConstants
        is a strict subset of PMConstants).  This relaxation of an error condition will be removed
        in a future release. "
        ((pools includes: #OperatingSystemConstants) or: [pools includes: #PMConstants])
            ifTrue: [ #( #ColorConstants ) do: [:pn| pools remove: pn ifAbsent: []]]].

    poolVariableScope := MultiplePoolScope new. 
    pools do: [:pn|
        aPool := Smalltalk at: pn ifAbsent: [nil].
        aPool == nil ifFalse: [
            poolVariableScope add:
                (self scopeForPool: aPool named: pn)]].
    ^poolVariableScope! 
options
	"Return a collection of all the option symbols associated with this compilation"
	^self getOptions keys!   
useCompiler
	"Private - Answer the Compiler that should be used for the next actual compilation operation.
	Compiler instance has been cached it will be return, but the cache will also be invalidated hence
	subsequene call to this method will return a differenent instance."

	|c|
	c := self getCompiler.
	compiler := nil.  "invalidate cached instance"
	^c! 
defaultErrorHandler
	"Answer the default error handler for the type of
	compilation context represented by the receiver."

	^SilentErrorHandler new! 
bindingClassForAssociations
	"return the class of binding used to represent association-based variables"
	^self compiler associationBindingClass!   
getErrorHandler
	"Private - this is the accessor for the instance variable errorHandler"
	^errorHandler!
removeOption: aSymbol
	"Remove compilation option identified by the symbol."

	^self getOptions removeKey: aSymbol ifAbsent: []!   
scopeForPool:  aPool named: aString
	"return a scope for the variable pool that is the argument"
	^GlobalPoolScope
		for: aPool
		bindingClass: (self bindingClassForPoolNamed: aString)
		description: 'pool variable within ', aString!
validAsLocalHead: aCharacter
	"Answer true if the argument is valid as the first character of a local identifier
	(instance variable, method arugmet or temp, block argument).
    X3J20 allows any identifier to be a local variable."

	^self validAsIdentifierHead: aCharacter!   
includesOption: aSymbol
	"Return true is aSymbol is an option for this compilation"
	^self getOptions includesKey: aSymbol! 
errorHandler
	"Answer the error handler that will receive notification if any errors are detected."
	^self getErrorHandler!
evaluate: sourceCode
	"Compile the Smalltalk <sourceCode> as an expression in the
	context of the receiver. If compilation is successful, answer the
	result of of evaluating the resulting executable. The pseudo-variable
	<self> will be unbound during evaluation, but it is up to the client to
	exclude it from the name scope"

	|result|
	result := self useCompiler compileForEvaluation: sourceCode.
	result wasSuccessful ifTrue: [result evaluate].
	^result!   
setErrorHandler: h
	"Private - this is the assignment accessor for the instance variable errorHandler"
	errorHandler:=h!
errorClass
	"Retrun the class whose instances represent error
	conditions detected by this compilation"

	^CompilationError!  
scopeForClass: aClass
	"Answer a name scope appropiate for the compile that represents
	the names defined for code compiled in the scope of the given <class>.
	This includes the names of all instance variables, class variables, and
	pool variables, but does not include globally defined names."

	|exclude| 
	exclude := (aClass superclass isNil ifTrue: [#('super')] ifFalse: [#()]).
	^(self scopeForReservedSymbolsExcluding: exclude),
		(self scopeForInstanceVariableNames: aClass allInstVarNames) ,
		(self classVariableScopeFor: aClass) ,
		(self poolVariableScopeFor: aClass)!   
scopeForReservedSymbolsExcluding: aCollection
	"Answer a name scope appropiate for this compiler that represents the
	reserved symbols within a Smalltalk method.  Do not include the identifiers
	that are in the argument list"

	^self compiler specialScopeExcluding: aCollection!   
validAsGlobalHead: aCharacter
	"Answer true if the argument is valid as the first character of a global identifier.
    X3J20 allows any identifier to be a global."

	^self validAsIdentifierHead: aCharacter!   
scopeForGlobals
	"Answer a name scope appropiate for this compile that represents the
	names of globals in the default global name space (normally, the
	SystemDictionary Smalltalk). "

	^(self scopeForDictionary: self defaultGlobalDictionary)
			useSymbolKeys;
			description: 'global variable';
			yourself!  
validAsIdentifierHead: aCharacter
	"Answer true if the argument is valid as the first character of an identifier"

	^aCharacter isLetter or: [aCharacter = $_]!
compile: sourceCode
	"Compile the Smalltalk <sourceCode> as a method in the
	context of the receiver. Answer a CompilationResult that can
	be queried to determine the result of the compilation."

	^self useCompiler
		compileMethod: sourceCode!
compiler
	"Answer a Compiler that can be used by the receiver."
	^self getCompiler!
analyze: sourceCode withMethodPattern: isMethod
	"Parse the Smalltalk <sourceCode> in the context of the receiver. The source
	is a method if <isMethod> is <true>, and an expression if it is <false>.
	The resulting ParseInformation can be queried to determine the result
	of the analysis."

	^isMethod
		ifTrue: [self compiler analyzeMethod: sourceCode]
		ifFalse: [self compiler analyzeForEvaluation: sourceCode]!   
optionValue: aSymbol
	"Return the value of the compilation option identified by the symbol"
	^self getOptions at: aSymbol!  
defaultGlobalDictionary
	"Answer the dictionary that, by default, hold global variable associations"
	^Smalltalk!  
initialOptions
	"create the initial value for the options dictionary"
	|d|
	d := IdentityDictionary new.
	self class defaultOptions associationsDo: [:assoc| d add: assoc].
	^d! 
preferedAsLocalHead: aCharacter
	"Answer true if the argument is valid as the first character of a local identifier
	(instance variable, method argument or temp, block argument).
     X3J20 allows any identifier to be a local but suggests using lower case."

	^aCharacter isLowerCase or: [aCharacter = $_]!   
aboutToSaveImage
        "Private - clean up unused bitmaps, and save backup
         of all Bitmap instances"

    OldMemoryContext := MemoryContext!
defaultClass
        "Private - answer the default class which is instantiated by #forClass: ."
    DefaultClass isNil ifTrue: [ ^self ].
    ^DefaultClass isClass
        ifTrue: [ DefaultClass ]
        ifFalse: [ Smalltalk at: DefaultClass ]!
defaultClass: aClassOrSymbol
        "Private - set the default class which is instantiated by #forClass: ."
    DefaultClass := aClassOrSymbol!
forClass: aClass
        "Answer an instance of the
         receiver for aClass."
    ^self defaultClass new setClass: aClass.!   
fileOutDefinitionOn: aStream
        "Append the class definition message
         for the receiver's class to aStream."
    | aMetaClass |
    class fileOutOn: aStream.
    aStream nextChunkPut: ''.
    aMetaClass := class class.
    aMetaClass instanceVariableString = ''
        ifFalse: [
            aStream cr; cr.
            aMetaClass fileOutOn: aStream.
            aStream nextChunkPut: ''].!
fileOutOn: aStream
        "File out all the methods for the class described
         by the receiver to aStream, in chunk format."
    aStream cr.
    self instanceHeaderOn: aStream.
    class selectors asSortedCollection do: [ :selector |
        aStream
            cr;
            nextChunkPut: (class sourceCodeAt: selector)].
    aStream nextPutAll: ' !!'; cr!   
setClass: aClass
        "Private - Set the class described
         by the receiver to aClass."
    class := aClass!  
instanceHeaderOn: aStream
        "Private - Write a header to aStream which identifies
         the class described by the receiver.  The header
         precedes the source code for the methods."
    aStream
        cr;
        cr;
        nextPut: $!!;
        nextPutAll: class name;
        space;
        nextPutAll: 'methods !!'!
classField
        "Answer the class to which the receiver    
        is connected."
    ^class!  
fileOutClassOn: aStream
        "Write the definition and source code of aClass
        in chunk file format on aStream."
    self fileOutDefinitionOn: aStream.
    (self class forClass: class class) fileOutOn: aStream.
    self fileOutOn: aStream.!
fileOutMethod: aSelector
        "Write the source for aSelector in class
         in chunk file format to a file named with aSelector
         reduced to 8 characters, extension 'mth'."
    | aFileStream |
    CursorManager execute changeFor: [
        aFileStream := Disk newFile:
            (File
                fileName: (aSelector reject: [:c| c = $:])
                extension: 'mth').
        aFileStream lineDelimiter: Cr.
        self fileOutMethod: aSelector on: aFileStream.
        aFileStream close ]! 
fileOut
        "Write the source for the class (including the class definition,
         instance methods, and class methods) in chunk file format
         to a file named with the class name reduced to 8 characters,
         extension 'cls'."
    class isNil ifTrue: [^self].
    ^self fileOut:
        (File
            fileName: class name
            extension: 'cls')!   
fileOut: aFileName
        "Write the source for the class (including the class definition,
         instance methods, and class methods) in chunk file format
         to aFileName."
    | aFileStream |
    class isNil ifTrue: [ ^self ].
    aFileName isNil ifTrue: [ ^self ].
    CursorManager execute changeFor: [
        aFileStream := File newFile: aFileName.
        aFileStream lineDelimiter: Cr.
        self fileOutClassOn: aFileStream.
        aFileStream close ]!  
fileOutAll: aFileName
        "Write the source for the class and all of its subclasses
        (including the class definitions, instance methods, and
        class methods) in chunk file format to aFileName."
    | aFileStream |
    class isNil ifTrue: [ ^self ].
    aFileName isNil ifTrue: [ ^self ].
    CursorManager execute changeFor: [
        aFileStream := File newFile: aFileName.
        aFileStream lineDelimiter: Cr.
        class withAllSubclasses do: [:c |
            ( self class forClass: c ) fileOutClassOn: aFileStream.
            aFileStream cr].
        aFileStream close ]!   
fileOutMethod: aSelector on: aStream 
        "File out the method aSelector for the class described 
         by the receiver to aStream, in chunk format." 
    aStream cr. 
    self instanceHeaderOn: aStream. 
    aStream 
        cr; 
        nextChunkPut: (class sourceCodeAt: aSelector). 
    aStream nextPutAll: ' !!'; cr!  
fileInFrom: aStream
        "Read chunks from aStream until an empty chunk
         (a single '!!') is found.  Compile each chunk
         as a method for the class described by the
         receiver.  Log the source code of the method
         to the change log."
    | aString result |
    [(aString := aStream nextChunk) isEmpty]
        whileFalse:[
            result := class compile: aString.
            result notNil
                ifTrue: [result value sourceString: aString]]!   
category: stringOrNil
	"Set the method category that the methods should be classifed under.
	A nil argument is ignored and the category (if set) is not changed.
	The default implementation ignores methods categories.  Subclass may
	override this in order to explictly manage method categories"

	^self!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #red #green #blue #flags )!  
signal: msg forCompiledMethod: method
        "Signal that the exception represented by this class
        has occurred, create an instance to represent this
        specific occurrence.  Associate the arguments message
        text and the compiled method with the occurrence."

   ^(self new messageText: msg; compiledMethod: method) signal! 
getDescription
	"Private-This is the accessor for the instance variable contextDescription"
	^contextDescription!   
hasDescription
	"return true if this is a context description associated with this object"

	^self getDescription notNil!  
contextDescription
	"Return a string that describes the context within which the compilation
	associated with this error handler is occuring.  This is often a class name
	but may be other descriptive text.  The value returned is the value that was
	the argument of the most recently made send of the #contextDescription:
	message to this object. If #contextDescription: has not been called, the
	value returned by this method is undefined."

	^self getDescription!  
contextDescription: aString
	"Associate with the reciever a string that describes context within which
	the compilation associated with this error handler is occuring.  This is often
	a class name by may be other descriptive text.  The description is the
	argument value.  Subsequent in vocations of #contextDescription will
	return this value"

	self setDescription: aString!   
setDescription: aString
	"Private-This is the assignment accessor for the instance variable
	contextDescription"
	contextDescription := aString!   
reportWarning: error
    "Private-tell the user about the error.
    Over ride the default implementation in order to write the message on the Transcript"
    | source position |
    source := error sourceCode.
    position := error sourcePosition.
    Transcript  cr; nextPutAll: '"--- compilation ', ( error canProceed ifTrue: [ 'warning' ] ifFalse: [ 'error' ] ).
    self hasDescription
        ifTrue:  [Transcript nextPutAll: ' in ' ;  nextPutAll: self contextDescription].
    Transcript nextPutAll: ' ---"';
        cr; nextPutAll: (source copyFrom: 1 to: (0 max: position - 1));
        cr; nextPutAll: '"' , error errorMessage trimBlanks , '--->"';
        cr; nextPutAll: (source copyFrom: (1 max: position) to: error sourceCode size);
        cr; show: '"-------------------------"'!  
inspect
        "Open a FieldInspector on the receiver."
    FieldInspector new openOn: self!   
variableByteSubclass: className
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be
        a variable byte subclass of the receiver with the
        specified class variables and pool dictionaries."
    ^self
        variableByteSubclass: className
        instanceVariableNames: String new
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries!
collisions
		"Answer the number keys whose hash value collide, assuming hash computed 
		by #identityHash."
	| collisions key modulus |
	collisions := 0.
	modulus := self size // 2.
	1 to: self size by: 2
			do:
				[ :index |
				key := self at: index.
				key == nil
					ifFalse:
						[ index = ( ( key basicHash \\ modulus) * 2 + 1 )
							ifFalse: [ collisions := collisions + 1 ] 
						]
				].
	^collisions! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #length
        #flags
        #showCmd
        #ptMinPosition
        #ptMaxPosition
        #rcNormalPosition
    )!
aboutToSaveImage
        "Private - Retrieve the contents of the receiver
         from the host OS when the image is about to be saved."
    self saveBitmap! 
initWindowSize
        "Private - Answer the window size, based on bitmap size"
    | bmpOffset titleHeight borderWidth borderHeight |
    titleHeight := OperatingSystem getSystemValue: SmCycaption.
    borderWidth := OperatingSystem getSystemValue: SmCxdlgframe.
    borderHeight := OperatingSystem getSystemValue: SmCydlgframe.
    bmpOffset := Display extent // 2 - ( bitmap extent // 2 ).
    ^bmpOffset extent: ( bitmap extent + ( ( 2 * borderWidth ) @ ( 2 * borderHeight + titleHeight ) ) )!  
addSingleQuotes
        "Private - Bracket the selected text in a pair of
        single quotes."
    self addLeftBracket: $' rightBracket: $'!
initializePrimeTable: max
    "Initialize the prime lookup table to translate a maximum requested table
     size of <max> directly to the next prime greater than or equal to the requested
     table size.  Size requests greater than <max> will be guaranteed to at least be
    odd, and usually will be partially prime wrt to the first few primes.
    (See hashModulusFor:)
    Note: it is safe to reinitialize the prime table at any time.  Most applications
    will not need to bother, but frequent use of exceptionally large dictionaries may
    benefit from increased prime table size."

    | primes deltas primeIdx aPrime |
    "3 is smallest table size"
    primes := OrderedCollection new: 500.
    primes addFirst: 3.
    "need to get next prime beyond max"
    5 to: max + 250 by: 2 do:  "250 is good up thru max=436273008"
        [:num |
        primes
            detect: [:prime | num \\ prime = 0]
            ifNone: [primes addLast: num]].
    "only record odd integer deltas"
    deltas := ByteArray new: max // 2 + 1.
    primeIdx := 1.
    1 to: max by: 2 do:
        [:int |
        [aPrime := primes at: primeIdx.
        aPrime < int]
            whileTrue: [primeIdx := primeIdx + 1].
        deltas at: int // 2 + 1 put: aPrime - int].
    MaxDeltaIndex := max.
    PrimeDeltas := deltas!   
allMethodsAssigningInstVar: aString
        "Answer a collection of all the methods in the receiver that
        assign the instance variable named aString."
    | answer index allInstances |
    answer := OrderedCollection new.
    allInstances := self allInstVarNames.
    index := allInstances indexOf: aString ifAbsent: [ ^answer ].

    CursorManager execute changeFor: [
        self methodDictionary do:
            [ :method |
            ( method includesSetFor: index )
                    ifTrue: [ answer add: method ]
            ]
        ].
    ^answer.!  
outputToExe: fileName id: aResourceId
        "Output the receiver as a resource in fileName. The receiver
        will be written over the icon resource identified by aResourceId."
    | binder |
    self readOnly ifTrue: [ ^self error: 'Read-only icons not supported.' ].
    ( Smalltalk includesKey: #Coff )
        ifFalse: [ binder := SmalltalkLibraryBinder bindTo: 'vcoff', SmalltalkLibrary versionAndPlatformExtension ].
    self privateOutputToExe: fileName id: aResourceId.
    binder notNil ifTrue: [ binder unBind ]!   
createView
        "Private - create the panes for the receiver window."
    | pane |
    self addSubpane:
        ( ( pane := GraphPane new )
            setName: #graphicInstance: ;
            when: #display send: #graphicInstance: to: self with: pane;
            when: #button1Down send: #setFocus to: pane;
            framingRatio:
                ( ( Rectangle leftTopUnit rightAndDown: ( 1/3 @ 0 ) )
                    extentFromLeftTop: 2/3 @ 1 ) ).
    super createView! 
graphicInstance: aGraphPane
        "Private - Display the receiver in the GraphPane."
    | i pen textOrigin var |
    instIndex isNil ifTrue: [ ^nil ].
    pen := aGraphPane pen.
    pen erase.

    instIndex = 1
        ifTrue: [ var := object ]
        ifFalse: [
            ( i := self getInstVarIndex ) ~= 0
                ifTrue: [
                    var := object instVarAt: i.
                    ( self isGraphicObject: var )
                        ifFalse: [ var := var printString ] ]
                ifFalse: [ var := String new ] ].

    ( self isGraphicObject: var )
        ifTrue: [ var displayAt: 0@0 with: pen ]
        ifFalse: [
            textOrigin := Rectangle leftTopUnit down: pen font height.
            pen displayText: var at: textOrigin ]!  
instance: aTextPane
        "Private - Set the ASCII representation of the selected instance
        variable, and fire the #needsContents handler for the GraphPane."
    super instance: aTextPane.
    self changed: #graphicInstance:!
selectInstance: aListPane
        "Private - Select the instance variable at
         index position anInteger in the list."
    | var i showPane hidePane |
    instIndex := aListPane selection.
    self enableInspectItem.
    instIndex = 1
        ifTrue: [ var := object ]
        ifFalse: [
            ( i := self getInstVarIndex ) ~= 0
                ifTrue: [ var := object instVarAt: i ] ].
    ( self isGraphicObject: var )
        ifTrue: [
            showPane := self paneAt: #graphicInstance: .
            hidePane := self paneAt: #instance:  ]
        ifFalse: [
            showPane := self paneAt: #instance: .
            hidePane := self paneAt: #graphicInstance: ].
    self changed: #instance: .
    hidePane isVisible ifTrue: [ hidePane hideWindow ].
    showPane isVisible ifFalse: [ showPane showWindow ]! 
classInstallerClass
	"Answer the class of class installer to use"

	^ClassInstaller!   
inspect
        "Open a GraphicBrowser on the receiver."
    GraphicInspector new openOn: self! 
initializePartialReadSettings
        "Initialize the default settings for a partial file read."
    PartialReadThreshold := 50000.
    PartialReadHeaderSize := 10000.!   
aboutToSaveImage
        "Private - the image is about to be saved; notify anyone
        who needs to know when this happens."
    self triggerEvent: #aboutToSaveImage.
    SystemWeakRegistries current aboutToSaveImage.
    Notifier aboutToSaveImage.
    SelfInitializingObject aboutToSaveImage.
    Bitmap aboutToSaveImage.
    Icon aboutToSaveImage.
    OperatingSystemInformation aboutToSaveImage.
    Screen aboutToSaveImage.
    Window aboutToSaveImage.
    "this will be removed in a future release, maintained for compatibility."
    ViewManager withAllSubclasses do: [ :c | c aboutToSaveImage ]! 
instanceVariableNames: stringOfInstVarNames
        "Define (or redefine) the set of class instance variables for
        the class which is an instance of the receiver (a MetaClass)."

    self instVarNames = stringOfInstVarNames asArrayOfSubstrings
        ifTrue: [^self instanceClass].
	^DefinitionInstaller current
		setClassInstanceVariableNames: stringOfInstVarNames
		forClass: self instanceClass! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #type
        #headerSize
        #version
        #fileSize
        #noObjects
        #maxRecord
        #noParameters
    )!  
dumpStringBase: radix bytes: oneTwoFour
        "Answer a String which contains a dump of the receiver's bytes
        in the given radix, where oneTwoFour specifies the number
        of bytes per chunk."
    | aStream |
    aStream := String new asStream.
    self dumpOn: aStream base: radix bytes: oneTwoFour.
    ^aStream contents!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #bmType
        #width
        #height
        #byteWidth
        #planes
        #bitsPixel
    )!   
defaultGlobalDictionary
        "Answer the dictionary that, by default, holds global
        variable associations."
    ^Smalltalk!  
name: className
    environment: globalDictionary
    subclassOf: superclassObject
    instanceVariableNames: instanceVariableString
    variable: variableBoolean
    pointers: pointerBoolean
    classVariableNames: classVariableString
    poolDictionaries: poolDictionaryString
        "Create an initialized instance of the receiver"
    | installer |
    installer := self new.
    installer
        className: className;
        environment: globalDictionary;
        superclass: superclassObject;
        instanceVariableNames: instanceVariableString asArrayOfSubstrings;
        isVariable: variableBoolean;
        isPointers: pointerBoolean;
        classVariableNames: classVariableString asArrayOfSubstrings;
        poolNames: poolDictionaryString asArrayOfSubstrings.
    ^installer!   
class: aClass
    classInstanceVariableNames: instanceVariableString
        "Create an initialized instance of the receiver"
    | installer |
    installer := self new.
    installer
        className: aClass symbol;
        setClassObject: aClass;
        classInstanceVariableNames: instanceVariableString asArrayOfSubstrings;
        setClassInstanceVariablesOnly.
    ^installer!   
className: aSymbol
        "Set the name of the class the receiver is installing"
    name := aSymbol!  
validatePoolExistence
        "Answer true if the receiver contains only existing pools"
    | poolName |
    poolName := self symbolPoolNames
        detect: [:symbolPoolName | (self environment at: symbolPoolName ifAbsent: [nil]) isDictionary not]
        ifNone: [^true].
    self environment at: poolName ifAbsent: [^self invalidBecause: 'Pool named ' , poolName , ' does not exist'].
    ^self invalidBecause: 'Pool named ' , poolName , ' is not a pool dictionary'! 
validateSubclassClassVariableNameConflicts
        "Private - Return false if any of the proposed class variable
        names are duplicates of any of the class variables for any
        of the receivers subclasses"
    | aSet |
    aSet := Set new.
    self allSubclasses do: [:subclass |
        aSet addAll: subclass classVarNames].
    self classVariableNames do: [:varName |
        (aSet includes: varName)
            ifTrue: [^self invalidBecause: 'Class variable ' , varName printString , ' is defined in a subclass']].
    ^true!   
editClassInstanceVariables
        "Edit the class instance variables if necessary"
    self classInstanceVariableNames = self classObject class instVarNames
        ifTrue: [^self].
    self classObject class setInstVarNames: self classInstanceVariableNames.
    self classObject class logDefinition.!   
validateSubclassClassInstanceVariableNameConflicts
        "Private - Return a error message if any of the names in the
        argument string are duplicates of the names of any of the
        class instance variables for any of the receivers subclasses.
        If there are no duplicates, return true"
    | aSet |
    aSet := Set new.
    self allSubclasses do: [:subclass |
        aSet addAll: subclass class instVarNames].
    self classInstanceVariableNames do: [:varName |
        (aSet includes: varName)
            ifTrue: [^self invalidBecause: 'Class instance variable ' , varName printString , ' is defined in a subclass']].
    ^true!
classVariableNames: aCollection
        "Record the collection of class variable names that the
        receiver should install"
    classVariableNames := aCollection!
setClassInstanceVariablesOnly
        "Set true if the receiver should only redefine class instance variables and nothing else"
    classInstanceVariablesOnly := true! 
invalidBecause: error
        "Record the error <error> and return false"
    self errorString: error.
    ^false! 
mutators
        "Answer the collection of mutators needed to change the shape
        of the installed class and its subclasses"
    mutators == nil
        ifTrue: [^Array new].
    ^mutators!   
shouldCompileMetaclassSubclasses
        "Answer true if the methods of the receiver's metaclass' subclasses
        need to be recompiled"
    ^shouldCompileMetaclassSubclasses ~~ false!
validateClassVariableCase
        "Answer true if the receiver contains valid class variable names"
    | classVar |
    classVar := self classVariableNames
        detect: [:inst | (self isValidGlobal: inst) not]
        ifNone: [^true].
    ^self invalidBecause: 'Invalid class variable ' , classVar!  
validateSuperclassClassInstanceVariableNames
        "Private - Validate that the class instance variable names
        in the argument string are valid for a subclass of this class.
        If not return an error message string.  If valid, return true"
    | aBag varName superclassClass |
    aBag := Bag new.
    superclassClass :=
        self superclass == nil
            ifTrue: [Class]
            ifFalse: [self superclass class].
    aBag addAll: self classInstanceVariableNames.
    aBag addAll: superclassClass allInstVarNames.
    varName := aBag
        detect: [:each | (aBag occurrencesOf: each) > 1]
        ifNone: [^true].
    ^self invalidBecause: 'Duplicate class instance variable: ' , varName!   
validateClassInstanceVariableCase
        "Answer true if the receiver contains valid class instance variable names"
    | instVar |
    instVar := self classInstanceVariableNames
        detect: [:inst | (self isValidLocal: inst) not]
        ifNone: [^true].
    ^self invalidBecause: 'Invalid class instance variable ', instVar! 
validateSuperclassClassVariableNames
        "Private - Validate that the class variable names proposed
        by the receiver are valid for a subclass of this class"
    | aBag varName |
    self superclass == nil
        ifTrue: [^true].
    aBag := Bag new.
    aBag addAll: self classVariableNames.
    aBag addAll: self superclass allClassVarNames.
    varName := aBag
        detect: [:each | (aBag occurrencesOf: each) > 1]
        ifNone: [^true].
    ^self invalidBecause: 'Duplicate class variable: ' , varName!
isValidLocal: nameString
        "Answer true if <nameString> is a valid local name"

    | possibleStream  nameValidator |
    nameString isEmpty
        ifTrue: [^false].
    possibleStream := ReadStream on: nameString.
    nameValidator := CompilerInterface new.
    (nameValidator validAsLocalHead: possibleStream next)
        ifFalse: [^false].
    [possibleStream atEnd]
        whileFalse:
            [(nameValidator validInIdentifierBody: possibleStream next)
                    ifFalse: [^false]].
    ^true!
compileIfNecessary
        "Recompile the class and metaclass (and subclasses) if necessary"
    self shouldCompileClass
        ifTrue:
            [self recompile: self classObject.
            self shouldCompileSubclasses
				ifTrue:
					[self classObject allSubclasses do: [:subclass |
                		self recompile: subclass]]].
    self shouldCompileMetaclass
        ifTrue:
            [self recompile: self classObject class.
            self shouldCompileMetaclassSubclasses
				ifTrue:
					[self classObject class allSubclasses do: [:subclass |
                		self recompile: subclass]]]!
allSubclasses
        "Answer a collection of all subclasses of the class to be installed."
    self classObject == nil
        ifTrue: [^Array new].
    ^self classObject allSubclasses!
canChangeClass: aClass
        "Answer true if class <aClass> is mutable"
    (self immutableClassNames includes: aClass symbol)
        ifTrue: [^false].
    aClass subclasses
        detect: [:subclass | (self canChangeClass: subclass) not]
        ifNone: [^true].
    ^false!
superclass: aClass
        "Set the superclass of the class to be installed"
    superclass := aClass!  
errorString
        "Answer the error that was detected in the validation process"
    ^errorString!
errorString: aString
        "Cache <aString> as an error that was detected in the validation process"
    errorString := aString!  
immutableClassNames
        "Answer a collection of the names of all classes that cannot be
        mutated.  None of the superclasses of these classes may be
        mutated either"
    ^#(#True #False #UndefinedObject #Character #SmallInteger #String #Process #Array #ByteArray #MethodDictionary #Class)!
classMutationNecessary
        "Answer true if the receiver's class needs to be mutated."
    ^self classObject class allInstVarNames ~= self allClassInstVarNames! 
compilerClass
        "Answer the appropriate compiler class."
    ^CompilerInterface!  
detectInstanceVariableOverflow: class maxVariables: maxCount
        "Answer the <class> or one of its subclasses, that have more than <maxCount> variables defined."

    | variableCount invalidSubclass |
    (variableCount := class instVarNames size) > maxCount
        ifTrue: [^class].
    class subclasses do: [:subclass |
			invalidSubclass := self detectInstanceVariableOverflow: subclass maxVariables: maxCount - variableCount.
			invalidSubclass == nil
				ifFalse: [^invalidSubclass]].
	^nil!   
metaclass
        "Private - Answer a MetaClass for the receiver's class, or if
        it doesn't exist, create a subclass of the superclass"
    | class meta |
    class := self environment
        at: self className
        ifAbsent:
            [meta := MetaClass subclassOf: self superclass.
            meta setInstVarNames: self classInstanceVariableNames.
            ^meta].
    ^class class!   
validateInstanceVariables
        "Answer true if the receiver contains no conflicting instance variable names"
    ^self validateInstanceVariableCase
        and: [self validateMutation
        and: [self validateSuperclassInstanceVariableNames
        and: [self validateSubclassInstanceVariableNameConflicts
        and: [self validateInstanceVariableCount]]]]!
isPointers
        "Answer true if the receiver is installing a class that contains
        object pointers (instead of bytes)"
    ^isPointers!   
isVariable: aBoolean
        "Record true if the receiver is installing a class that
        contains an indexable part"
    isVariable := aBoolean!   
enableMutationIfNecessary
        "Enable all mutators; force mutation on all metaclasses that are mutated"
    self classMutators do: [:mutator |
        mutator forceMutation: mutator targetClass instanceClass].
    self mutators do: [:mutator | mutator enableMutation]!  
validateSubclassInstanceVariableNameConflicts
        "Private - Return a error message if any of the names in the
        argument string are duplicates of the names of any of the
        instance variables for any of the receivers subclasses. If
        there are no duplicates, return true"
    | aSet |
    aSet := Set new.
    self allSubclasses do: [:subclass |
        aSet addAll: subclass instVarNames].
    self instanceVariableNames do: [:varName |
        (aSet includes: varName)
            ifTrue: [^self invalidBecause: 'Instance variable ' , varName printString , ' is defined in a subclass']].
    ^true!
compilerFor: aBehavior
        "Answer a compiler to use to compile <aBehavior>"
    ^self compilerClass
        forClass: aBehavior
        errorHandler:
            (NonInteractiveErrorHandler new
                contextDescription: aBehavior name;
                yourself)!  
mutationNecessary
        "Answer true if existing instances of the receiver's class need to
        be mutated.  This would be a place to test 'allInstances' if it could
        be done quickly."
    ^self classObject allInstVarNames ~= self allInstVarNames
        or: [self classObject isVariable
                and: [self isVariable not or: [self classObject isPointers ~~ self isPointers]]]!   
classInstanceVariablesOnly
        "Answer true if the receiver should only redefine class
        instance variables and nothing else"
    ^classInstanceVariablesOnly == true!   
isValidGlobal: nameString
        "Answer true if <nameString> is a valid global name"

    | possibleStream  nameValidator |
    nameString isEmpty
        ifTrue: [^false].
    possibleStream := ReadStream on: nameString.
    nameValidator := CompilerInterface new.
    (nameValidator validAsGlobalHead: possibleStream next)
        ifFalse: [^false].
    [possibleStream atEnd]
        whileFalse:
            [(nameValidator validInIdentifierBody: possibleStream next)
                    ifFalse: [^false]].
    ^true! 
validatePoolCase
        "Answer true if the receiver contains valid pool names"

    | pool |
    pool := self poolNames
        detect: [:poolName | (self isValidGlobal: poolName) not]
        ifNone: [^true].
    ^self invalidBecause: 'Invalid pool ' , pool!  
isPointers: aBoolean
        "Record true if the receiver is installing a class that contains
        object pointers (instead of bytes)"
    isPointers := aBoolean!  
validateInstanceVariableCount
        "Answer true if the receiver contains a legal number of instance variables"

    | variableCount maxCount invalidSubclass |
    maxCount := self maxInstanceVariables.
    (variableCount := self allInstVarNames size) <= maxCount
        ifFalse: [^self invalidBecause: 'More than ' , maxCount printString , ' instance variables are defined.'].
    self subclasses do: [:subclass |
        invalidSubclass := self detectInstanceVariableOverflow: subclass maxVariables: maxCount - variableCount.
        invalidSubclass == nil
            ifFalse: [^self invalidBecause: 'Subclass named ' , invalidSubclass symbol, ' now has more than ' , maxCount printString , ' instance variables.']].
    ^true!  
recordCompilationRequirements
        "Record whether the class, metaclass, and subclasses need to be compiled."
		"Note that if the class must be compiled, then all of the subclasses
		must be compiled UNLESS the only difference is adding a new pool"
    shouldCompileClass := shouldCompileMetaclass := false.
    self classObject == nil
        ifTrue: [^self].
    (self superclass ~~ self classObject superclass
        or: [(self classVariableNames asSet elementsEqual: self classObject classVarNames) not])
            ifTrue: [shouldCompileClass := shouldCompileMetaclass := true].

    self classInstanceVariableNames ~= self classObject class instVarNames
        ifTrue: [shouldCompileMetaclass := true].
    self instanceVariableNames ~= self classObject instVarNames
        ifTrue: [shouldCompileClass := true].

	shouldCompileSubclasses := shouldCompileClass.
	shouldCompileMetaclassSubclasses := shouldCompileMetaclass.

	(self symbolPoolNames asSet elementsEqual: self classObject sharedPools asSet) not
		ifTrue: [shouldCompileClass := shouldCompileMetaclass := true]! 
classInstanceVariableNames
        "Answer a collection of class instance variable names
        that the receiver should install"
    classInstanceVariableNames == nil
        ifTrue: [classInstanceVariableNames := self createDefaultClassInstanceVariableNames].
    ^classInstanceVariableNames!  
shouldCompileMetaclass
        "Answer true if the class methods of the receiver's class
        need to be recompiled"
    ^shouldCompileMetaclass == true!   
maxInstanceVariables
        "Answer the maximum number of instance variables for a class"

	^Behavior maxInstanceVariables!   
validateClassVariables
        "Answer true if the receiver contains no conflicting class variable names"
    ^self validateClassVariableCase
        and: [self validateSuperclassClassVariableNames
        and: [self validateSubclassClassVariableNameConflicts]]!
createDefaultClassInstanceVariableNames
        "Answer a collection of the class instance variables already
        defined for this class or none if this is a new class"
    | class |
    (class := self classObject) == nil
        ifTrue: [^Array new].
    ^class class instVarNames!   
validateClassName
        "Answer true if the receiver contains a legal class name"

    | class |
    (self isValidGlobal: self className)
        ifFalse: [^self invalidBecause:'Invalid class name ' , self className].
    (self environment includesKey: self className)
        ifTrue:
            [self setClassObject: (class := self environment at: self className).
            (class isClass and: [class symbol == self className])
                ifFalse: [^self invalidBecause: self className , ' is not a class']].
    ^true!
shouldCompileSubclasses
        "Answer true if the methods of the receiver's subclasses
        need to be recompiled"
    ^shouldCompileSubclasses ~~ false! 
validateIndexableType
        "Answer true if the receiver contains a legal indexable type"
    self superclass == nil
        ifTrue: [^true].
    self isPointers
        ifTrue:
            [self superclass isPointers not
                ifTrue: [^self invalidBecause: 'Superclass is non-pointers'].
            (self isVariable or: [self allInstVarNames notEmpty])
                ifTrue:
                    [self allSubclasses
                        detect: [:subclass | subclass isPointers not]
                        ifNone: [^true].
                    ^self invalidBecause: 'Subclass is non-pointers']]
        ifFalse:
            [self instanceVariableNames isEmpty
                ifFalse: [^self invalidBecause: 'Non-pointer class cannot have instance variables'].
            (self superclass instSize ~= 0 or: [self superclass isPointers and: [self superclass isVariable]])
                ifTrue: [^self invalidBecause: 'Superclass has pointers'].
            self allSubclasses
                detect: [:subclass | subclass isPointers]
                ifNone: [^true].
            ^self invalidBecause: 'Subclass has pointers'].
    ^true! 
classVariableNames
        "Answer a collection of class variable names that the
        receiver should install"
    ^classVariableNames! 
poolNames
        "Answer a collection of all pools to be installed in the proposed class"
    ^poolNames!  
poolNames: aCollection
        "Record the collection of pools that the receiver should install"
    poolNames := aCollection!  
shouldCompileClass
        "Answer true if the instance methods of the receiver's class
        need to be recompiled"
    ^shouldCompileClass == true!
classInstanceVariableNames: aCollection
        "Record the collection of class instance variable names
        that the receiver should install"
    classInstanceVariableNames := aCollection asArray!   
validate
        "Answer true if the receiver contains a legal class definition,
        false otherwise"
    ^self validateClassName
        and: [self validateIndexableType
        and: [self validateInstanceVariables
        and: [self validateClassVariables
        and: [self validateClassInstanceVariables
        and: [self validatePoolNames]]]]]!
mutators: aCollection
        "Set the collection of mutators needed to change the shape
        of the installed class and its subclasses"
    mutators := aCollection!   
validateInstanceVariableCase
        "Answer true if the receiver contains valid instance variable names"
    | instVar |
    instVar := self instanceVariableNames
        detect: [:inst | (self isValidLocal: inst) not]
        ifNone: [^true].
    ^self invalidBecause: 'Invalid instance variable ', instVar !  
classObject
        "Answer the class with the same name as the one the receiver is trying to install"
    ^classObject!
setClassObject: aClass
        "Record <aClass> as the existing class that the receiver is modifying"
    classObject := aClass!
environment
        "Answer the environment for name lookup"
    ^environment!  
environment: aDictionary
        "Set the environment for name lookup"
    environment := aDictionary!  
instanceVariableNames
        "Answer a collection of instance variable names that
        the receiver should install"
    ^instanceVariableNames!
instanceVariableNames: aCollection
        "Record the collection of instance variable names
        that the receiver should install"
    instanceVariableNames := aCollection asArray!   
installClassInstanceVariables
        "Validate that the receiver has an acceptable definition.
        If not report an error.  Otherwise recompile the code and
        mutate the class"
    self classInstanceVariableNames = self classObject class instVarNames
        ifTrue: [^self classObject].
    self validateClassInstanceVariables
        ifFalse: [^self reportError].
    self setupForClassInstanceVariables.
    self editClassInstanceVariables.
    self compileIfNecessary.
    self enableMutationIfNecessary.
    ^self classObject!
reportError
        "Report the error that was detected during validation."
    ^self error: self errorString!  
classMutators
        "Answer the collection of mutators needed to change the shape
        of the installed class's class and its subclasses"
    classMutators == nil
        ifTrue: [^Array new].
    ^classMutators!
classMutators: aCollection
        "Set the collection of mutators needed to change the shape
        of the installed class's class and its subclasses"
    classMutators := aCollection! 
allClassInstVarNames
        "Answer an array of all of the instance variables in the
        proposed metaclass"
    | metaclass |
    metaclass := self classObject class.
    ^metaclass superclass allInstVarNames , self classInstanceVariableNames!
allInstVarNames
        "Answer an array of all of the instance variables in the
        proposed class"
    | localNames |
    localNames := self instanceVariableNames asArray.
    self superclass == nil
        ifTrue: [^localNames].
    ^self superclass allInstVarNames , localNames! 
editSubclass
        "Create or change the subclass the receiver should install"
    ^self metaclass
        name: self className
        environment: self environment
        subclassOf: self superclass
        instanceVariableNames: self instanceVariableNames
        variable: self isVariable
        words: true
        pointers: self isPointers
        classVariableNames: self classVariableNames
        poolDictionaries: self poolNames
        comment: String new
        changed: nil! 
setupDefinition
        "Prepare to alter the class definition."
    | superclassDifferent |
    self classObject == nil
        ifTrue: [^self].
    self recordCompilationRequirements.
    superclassDifferent := self classObject superclass ~~ self superclass.
    (self mutationNecessary or: [superclassDifferent])
        ifTrue:
            [self mutators: self classObject setupMutators].
    (self classMutationNecessary or: [superclassDifferent])
        ifTrue:
            [self classMutators: self classObject class setupMutators.
            superclassDifferent
                ifTrue: [self classObject privateChangeSuperclassTo: self superclass]]! 
superclass
        "Answer the superclass of the class to be installed"
    ^superclass!
symbolPoolNames
        "Answer a collection of all pool names as symbols to be
        installed in the proposed class"
    ^self poolNames collect: [:string | string asSymbol]! 
validateDuplicatePoolNames
        "Private - Validate that the pool names in the argument string are 
		valid for a subclass of this class.
        If not return an error message string.  If valid, return true"
    | aBag varName |
    aBag := Bag new.
    aBag addAll: self poolNames.
    varName := aBag
        detect: [:each | (aBag occurrencesOf: each) > 1]
        ifNone: [^true].
    ^self invalidBecause: 'Duplicate pool name: ' , varName!   
validatePoolNames
        "Answer true if the receiver contains no illegal pool names"
    ^self validatePoolCase
		and: [self validateDuplicatePoolNames
		and: [self validatePoolExistence]]!   
isVariable
        "Answer true if the receiver is installing a class that contains
        an indexable part"
    ^isVariable!
validateSuperclassInstanceVariableNames
        "Private - Validate that the instance variable names in the
        argument string are valid for a subclass of this class.  If not
        return an error message string.  If valid, return true"
    | aBag varName |
    self superclass == nil
        ifTrue: [^true].
    aBag := Bag new.
    aBag addAll: self instanceVariableNames.
    aBag addAll: self superclass allInstVarNames.
    varName := aBag
        detect: [:each | (aBag occurrencesOf: each) > 1]
        ifNone: [^true].
    ^self invalidBecause: 'Duplicate instance variable: ' , varName!  
subclasses
        "Answer a collection of the direct subclasses of the class to be installed."
    self classObject == nil
        ifTrue: [^Array new].
    ^self classObject subclasses!   
installNoValidate
        "Create an executable for the described class, and if it
        already exists, recompile the code and mutate instances"
    | subclass |
    (self classObject == nil and: [self environment includesKey: self className])
        ifTrue: [self setClassObject: (self environment at: self className)].
    self setupDefinition.
    subclass := self editSubclass.
    self setClassObject: subclass.
    self editClassInstanceVariables.
    self compileIfNecessary.
    self enableMutationIfNecessary.
    ^subclass! 
recompile: aBehavior
        "Compile all of the methods in <aBehavior>"

    aBehavior methodDictionary isEmpty
        ifTrue: [^nil].
    aBehavior compileAll!   
install
        "Validate that the receiver has an acceptable definition.  If not
        report an error.  Otherwise create it, and if it already exists,
        recompile the code and mutate instances"
    self classInstanceVariablesOnly
        ifTrue: [^self installClassInstanceVariables].
    self validate
        ifFalse: [^self reportError].
    ^self installNoValidate!   
validateMutation
        "Answer true if the receiver contains no conflicting instance variable names"
    (self classObject ~~ nil
        and: [self mutationNecessary
        and: [(self canChangeClass: self classObject) not]])
            ifTrue: [^self invalidBecause: 'System does not allow mutation of class named ' , self classObject name].
    ^true!  
setupForClassInstanceVariables
        "Prepare to edit class instance variables"
    shouldCompileMetaclass := shouldCompileMetaclassSubclasses := true.
    shouldCompileClass := shouldCompileSubclasses :=  false.
    self classMutators: self classObject class setupMutators!  
validateClassInstanceVariables
        "Answer true if the receiver contains no conflicting
        class variable names"
    ^self validateClassInstanceVariableCase
        and: [self validateSuperclassClassInstanceVariableNames
        and: [self validateSubclassClassInstanceVariableNameConflicts]]!   
className
        "Answer the name of the class the receiver is installing"
    ^name!  
singleStep
        "Private - Process single step interrupt."
    | process index oldWalkback pi |
    self debuggingProcess notNil
        ifTrue: [ self debuggingProcess resume ].
    process := Process copyStack.
    self setDebuggedProcess: process.
    pi := process stackPointerToProcessIndex:  process sendFrame.
    index := 1.
    [ ( process nextFrameAt: index ) = pi ]
        whileFalse: [ index := index + 1 ].
    index - 1 timesRepeat: [ process dropFrameWithoutProtection ].
    realFrame := process topFrame.
    process topFrame: ( process nextFrameAt: 0 ).

    process runable: 4.
    CurrentProcess := Process new.
    CurrentProcess makeUserIF.
    oldWalkback := walkback.
    browseWalkback
        ifFalse: [ self browseWalkback: 1 ].
    ( walkbackIndex = 1 and: [ self walkback = oldWalkback ] )
        ifFalse: [ self changed: #walkbackList: with: #restoreWithRefresh: with: 1 ].
    self expandTopFrame.
    self walkback: 1.
    self changed: #instance:.
    self checkMenus.
    Notifier run!   
setCompilationOptions: aCompilerInterface
	"The message is sent when a compiler interface object is being created
	that will process method definitions within the receiver.  The receiver may
	add or modify any compilation options by sending appropriate message to 
	the argument"
	aCompilerInterface addOption: #ApiFormat with: 'DLL32'! 
expressionEvaluator: anExpressionEvaluator
        "Set the instance of ExpressionEvaluator (or subclass)
        which handles evaluations."
    anExpressionEvaluator pane: self.
    self propertyAt: #expressionEvaluator put: anExpressionEvaluator! 
smalltalkMenu
        "Answer the Smalltalk menu."
    ^self mainView menuTitled: 'Smalltalk'!  
on: aCompiledMethod
	"Answer an initialized instance of the receiver"

	^self new
		compiledMethod: aCompiledMethod!  
errorIn: aProcess label: aString
        "Private - open a walkback labeled aString
        on suspended process aProcess."
    CurrentProcess == UserInterfaceProcess ifFalse:[
        'out of sync' displayAt: 0 @ 0.
        UserInterfaceProcess := CurrentProcess ].
    Debugger default new
        walkbackFor: aProcess label: aString!  
isCompilationResult
        "Answer true if this object responds to compilation result protocol."
    ^false!   
conversions
        "Answer the conversions supported by this kind of object."
    ^#(
		#asFileSystemLocator
		#asFileSystemPath )!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #style #width #color )!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #ctlType
        #ctlId
        #itemId
        #itemWidth
        #itemHeight
        #itemData
    )!   
streamReferenceArray
	"Return the array of system stream references"
	StreamReferenceArray == nil
		ifTrue: [self cacheStreamReferenceArray].
	^StreamReferenceArray! 
indexed: fileIndex
	"Answer an instance of the receiver referencing the system file (sources or changes) whose index in the Array SourceFiles is <fileIndex>."

	^self streamReferenceArray at:  fileIndex!
useStreamReference:  aStreamReference
	"Use <aStreamReference> as the default stream reference"

	self streamReferenceArray at: aStreamReference fileIndex put: aStreamReference!  
cacheStreamReferenceArray
	"Save an instance of the receiver  for each of the system stream references"
	StreamReferenceArray := Array new: Sources size.
	1 to: StreamReferenceArray size do: [:index |
		StreamReferenceArray at: index put: (self new fileIndex: index)].! 
sourcesFile
	"Answer an instance of the receiver referencing the system sources file."

	^self indexed: 1! 
defaultSystemReferenceClass
	"Answer the default class of object used to represent a reference to a system file."

	^SystemStreamReference!
indexed: fileIndex
	"Answer an instance of the receiver referencing the system file (sources or changes) whose index in the Array SourceFiles is <fileIndex>."

	^self defaultSystemReferenceClass indexed: fileIndex! 
changesFile
	"Answer an instance of the receiver referencing the system changes file."

	^self indexed: 2! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass
        fields: #( #red #green #blue )
        conversions: #( #asColor #asInteger )! 
evaluate: aString in: aClass to: doitReceiver notifying: requestor ifFail: exceptionBlock
    "Compile and evaluate the method, <aString>, in the context of <aClass>.
    If the method compiles correctly, answer the result of evaluation, with
    <self> bound to <doitReceiver>.  If not, send the message
    #compilerError:at:in:for: to requestor; then return the result of evaluating
    the exception block.  For compatibility purposes, pools of UndefinedObject
    are handled specially"

    | handler compiler result scope pool nilPools |
    handler := TraditionalCompilerErrorHandler new.
    compiler := self new.
    compiler errorHandler: handler.
    aClass == UndefinedObject
        ifFalse: [scope := (compiler scopeForClass: aClass)]
        ifTrue: [
            scope := compiler poolVariableScopeFor: UndefinedObject.
            nilPools := UndefinedObject sharedPools.
            self defaultPoolNames do: [:poolName |
                pool := Smalltalk at: poolName ifAbsent: [nil].
                (pool notNil and: [(nilPools includes: poolName) not])
                    ifTrue: [scope add: (compiler scopeForPool: pool named: poolName)]].
            scope := compiler scopeForReservedSymbols , (compiler classVariableScopeFor: UndefinedObject), scope].
    compiler nameScope:  scope , (compiler scopeForGlobals)  .
    result := compiler evaluate: aString withReceiver: doitReceiver.
    result wasSuccessful
        ifTrue: [^result value]
        ifFalse:
            [^self
                handleOldErrorResult: result
                in: aClass
                for: requestor
                return: exceptionBlock]
! 
initialize
        "Private - Initialize the class variables
         that describe the structure masks and bits."
    InstPointerBit := 16r4000 .
    InstIndexedBit := 16r2000 .
    InstNumberMask  := 127.
    InstZeroTerminatedBit := 16r1000!
inspect
        "Open a ByteArrayInspector on the receiver."
    ByteArrayInspector new openOn: self!   
newGlobalRegistry
        "Private - create and answer a new global registry."
    | windowsRegistry topRegistry |
    windowsRegistry := self new.
    windowsRegistry
        register: 'Win32'
        withName: #PlatformName
        version: '0.1'.
    topRegistry := self new.
    topRegistry
        register: windowsRegistry
        withName: #Platform
        version: '0.1'.
    topRegistry
        register: #LeftHandedCoordinateSystem
        withName: #CoordinateSystem
        version: '0.1'.
    ^topRegistry! 
matchBracketChar: aChar   at: aPoint
        "Private - Select to the brackets character matching aChar."
     (#($( $[ $" $') includes: aChar)
        ifTrue: [self matchLeftBracketChar: aChar at: aPoint]
        ifFalse: [((self matchRightBracketChar: aChar at: aPoint))].!   
rename: aString in: aSystemDictionary
        "Private - Rename the receiver to aString
         in the environment aSystemDictionary."
    | aSymbol |
    aSymbol := aString asSymbol.
    (aSystemDictionary includesKey: aSymbol)
        ifTrue: [
            ^self error: 'can''t rename to existing name'].
    DefinitionInstaller current
        renameClass: self
        to: aSymbol
        inGlobalDictionary: aSystemDictionary
    ! 
initialize
        "Private - Initialize the class variables. "
    LeftBrackets :=    #($( $[ $" $' ${).
    RightBrackets := #($) $] $" $' $}).
    Forward := true.
    CaseSensitive := true!
open
        "Private - open a dialog which allows setting of image
         file save preferences."
    | font multiplier pane |
    font := self class platformDefaultFont.
    multiplier := self class unitMultiplier.
    self
        addView: ( ( pane := self mainView )
            owner: self;
            when: #closed send: #close: to: self with: pane;
            font: font;
            yourself );
        labelWithoutPrefix: 'Save Image As';
        addSubpane: ( StaticText new
            contents: 'File Name:';
            framingBlock: [ :box | ( box leftTop rightAndDown: 1@1 * multiplier )
                extentFromLeftTop: 12@1 * multiplier ] );
        addSubpane: ( EntryField new
            contents: SessionModel current imageName;
            setName: #imageName: ;
            framingBlock: [ :box | ( box leftTop rightAndDown: 14@(1/2) * multiplier )
                extentFromLeftTop: 15@(3/2) * multiplier ] );
        addSubpane: ( StaticText new
            contents: 'Default Icon:';
            framingBlock: [ :box | ( box leftTop rightAndDown: 1@3 * multiplier )
                extentFromLeftTop: 12@1 * multiplier ] );
        addSubpane: ( ( pane := StaticGraphic new )
            owner: self;
            setName: #displayIcon: ;
            when: #needsContents send: #displayIcon: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 14@3 * multiplier )
                extentFromLeftTop: 1@1 * multiplier ] );
        addSubpane: ( StaticText new
            contents: 'Startup Method:';
            framingBlock: [ :box | ( box leftTop rightAndDown: 1@6 * multiplier )
                extentFromLeftTop: 14@1 * multiplier ] );
        addSubpane: ( ( pane := TextPaneControl new )
            owner: self;
            setName: #startUpMethod: ;
            when: #needsContents send: #startUpMethod: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 1@ (15/2) * multiplier )
                extentFromLeftTop: 40@10 * multiplier ] );
        addSubpane: ( ( pane := Button new )
            owner: self;
            defaultPushButton;
            contents: 'OK';
            when: #clicked send: #ok: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 3@(37/2) * multiplier )
                extentFromLeftTop: 10@2 * multiplier ] );
        addSubpane: ( ( pane := Button new )
            owner: self;
            contents: 'Set Icon...';
            when: #clicked send: #setIcon: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 14@(37/2) * multiplier )
                extentFromLeftTop: 12@2 * multiplier ] );
        addSubpane: ( ( pane := Button new )
            owner: self;
            contents: 'Cancel';
            when: #clicked send: #cancel: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 27@(37/2) * multiplier )
                extentFromLeftTop: 10@2 * multiplier ] );
        openWindow!  
compileSizeInBytesSelector: anAssociation
        "Private - compile the #sizeInBytes method specified by anAssociation
        in the structure definition named aString"
    | sourceStream |
    sourceStream := String new asStream.
    sourceStream
        nextPutAll: anAssociation key; cr;
        nextPutAll: '    ^', anAssociation value printString.
    ^sourceStream contents!
imageFileOffset
        "Private - answer the offset into an image file
        where the configuration structure is located."
    ^12304! 
aboutToSaveImage
        "Private - Save the receiver's value
        so it can be restored when the image
        is restarted."
    super aboutToSaveImage.
    self isHandleOk ifTrue: [
        self propertyAt: #topCorner put: self topCorner.
        self getText.
        self getSelection ]!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #style
        #windProc
        #clsExtra
        #wndExtra
        #hInstance
        #hIcon
        #hCursor
        #hBrush
        #menuName
        #className
    )!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass conversions: #( #asInteger #asSegmentedAddress )!   
setImageName: nameString
        "Private - set the name of the image that the receiver
        knows about to aString.  Update the label of the
        Transcript window."
    | name |
    name := nameString trimBlanks.
    name fileExtension isEmpty
        ifTrue: [ name := name, '.EXE' ].
    self imageName: name.
    Transcript setLabel! 
expressionEvaluator
        "Answer the instance of ExpressionEvaluator (or subclass)
        which handles evaluations."
    ^self
        propertyAt: #expressionEvaluator
        ifAbsentPut: [ self expressionEvaluatorClass on: self ]!
saveImage
        "Private - The user selected SaveImage menu item
         from the File menu."
    Smalltalk isRunTime
        ifTrue: [ MessageBox message: 'Cannot save image with the run-time system.']
        ifFalse: [
            SaveImageDialog new openYesNo answer
                ifTrue: [ self saveImageNoConfirm ] ]!   
professionalServices
        "Private - Open a dialog window to show information
        about Professional Services."
    AboutDialog new openProfessionalServices!   
enableInspectItem
        "Private - Enable the Inspect and Remove menu items."
    ( self menuTitled: 'Dictionary' )
        enableItem: #inspectSelection;
        enableItem: #remove! 
inspectMenu: pane
        "Private - Set the dictionary
         inspector list pane menu."
    | menu |
    menu := ( Menu
        labels: '\uInspect\n\uAdd\n\uRemove' replaceEscapeCharacters
        lines: Array new
        selectors: #( #inspectSelection #add #remove ) )
            title: '\uDictionary' replaceEscapeCharacters;
            owner: self;
            yourself.
    menu disableItem: #inspectSelection.
    menu disableItem: #remove.
    pane setMenu: menu! 
inspectSelection
        "Private - Open an Inspector on the value
         object associated with the selected key."
    instIndex isNil
        ifTrue: [^self].
    (object at: (instList at: instIndex) key)
        inspect!   
keyCollectionClass
        "Private - answer the class used to collect key values."
    ^[ object keyCollectionClass ]
        on: MessageNotUnderstood do: [ Set ]  " compatibility support "!
remove
        "Private - Remove the selected key from the dictionary."
    | assoc |
    instIndex isNil ifFalse: [
        assoc := instList at: instIndex.
        object removeKey: assoc key.
        ( object includesKey: assoc key ) ifFalse: [
            instList remove: assoc.
            instIndex := nil.
            self
                changed: #instVarList: with: #restore;
                changed: #instance:.
            self disableInspectItem ] ]!   
disableInspectItem
        "Private - Enable the Inspect and Remove menu items."
    ( self menuTitled: 'Dictionary' )
        disableItem: #inspectSelection;
        disableItem: #remove!  
instance: textPane
        "Private - Set an ASCII representation of
         the value associated with the selected key."
    instIndex isNil
        ifTrue: [^textPane contents: String new].
    ^textPane contents: (object at: (instList at: instIndex) key) printString!  
instVarList: pane
        "Private - Set an OrderedCollection of
         key strings for the list pane."
    pane contents: (instList
        inject: OrderedCollection new
        into: [ :list :assoc |
            list add: assoc value.
            list])! 
add
        "Private - Add a new key to the dictionary
         by prompting for a new key expression."
    | key size index |
    key := Prompter
        prompt: 'new key expression'
        defaultExpression: String new.
    key isNil
        ifTrue: [^self].
    (object includesKey: key)
        ifTrue: [
            MessageBox message: 'key already in dictionary'.
            ^self].
    object at: key put: nil.
    instList add:
        (Association key: key value: key printString).
    size := instList size.
    index := 1.
    [index > size
        or: [(instList at: index) key = key]]
                whileFalse: [index := index + 1].
    instIndex := index.
    self
        changed: #instVarList:
            with: #restoreSelected:
            with: instIndex;
        changed: #instance: ;
        enableInspectItem.!   
accept: textPane
        "Private - Replace the selected instance
         variable with the result of evaluating
         the contents of textPane."
    | result aString |
    instIndex isNil ifTrue: [ ^self ].
    aString := textPane contents.
    result := CompilerInterface
        evaluate: aString
        in: object class
        to: object
        notifying: textPane
        ifFail: [^textPane modified: true].
    object
        at: (instList at: instIndex) key
        put: result.
    self changed: #instance:.
    textPane modified: false! 
setInstList
        "Private - Compute instList, an
         OrderedCollection of key strings
         for the list pane."
    | aSet |
    aSet := self keyCollectionClass new: object size.
    object keysDo: [:aKey |
        aSet add:
            (Association key: aKey value: aKey printString)].
    instIndex := nil.
    (instList := SortedCollection new)
        sortBlock: [:a :b| a value < b value];
        addAll: aSet!   
fileOutOn: aStream
        "Append the class definition message
         for the receiver to aStream."
    | aString |
    aStream cr;
        nextPutAll: self superclass printString; space;
        nextPutAll: self kindOfSubclass; space;
        nextPutAll: self symbol storeString; cr; space; space.
    self isBits
        ifFalse: [
            aStream nextPutAll: 'instanceVariableNames: '.
            (aString := self instanceVariableString) isEmpty
                ifFalse:[aStream cr; nextPutAll: '    '].
            aStream
                nextPutAll: aString storeString;
                cr; space; space].
    aStream
        nextPutAll: 'classVariableNames: '.
    (aString := self classVariableString) isEmpty
        ifFalse:[aStream cr; nextPutAll: '    '].
    aStream
        nextPutAll: aString storeString; cr; space; space;
        nextPutAll: 'poolDictionaries: '.
    (aString := self sharedVariableString) isEmpty
        ifFalse:[aStream cr; nextPutAll: '    '].
    aStream
        nextPutAll: aString storeString!   
referencesToString: aString in: aClass
        "Open a MethodBrowser on all methods whose source code
        includes the substring aString."
    SourceManager current referencesToString: aString in: aClass!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #arenaBytes
        #newSpaceBytes
        #flipSpaceBytes
        #oldSpaceBytes
        #codeSpaceReservedBytes
        #codeSpaceCommittedBytes
        #codeSpaceMaxBytes
        #nominalFlipSizeBytes
        #paddingSizeBytes
        #imageFileStubSize
        #reserved
    )!
fromImage
        "Private - read the virtual machine configuration structure from
        the current image file, and answer an instance of the receiver
        containing its bytes."
        " VirtualMachineConfiguration fromImage "
    ^self fromFile: SessionModel current imageName!   
sizeInBytes
        "Private - answer the size in bytes of the VM config struct."
    ^1024!
initializeImage
        "Private - initialize (zero) all members of the configuration struct
        in the current image."
    self new
        toImage! 
fromFile: pathName
        "Private - answer an instance of the receiver
        read in from the given image file."
    | fileStream bytes |
    fileStream := ( File fromPath: pathName ) binaryReadStream.
    fileStream position: self imageFileOffset.
    bytes := fileStream next: self sizeInBytes.
    fileStream close.
    ^self usingBytes: bytes!   
error: errString sourceRange: interval in: srcString
	"Answer an instance of the receiver representing a compilation error, as
	indicated by the <errString >, that occured at or near the <interval > while
	compiling the source code . The result of compiling the source, to the point
	where the error was found, is contained in <parseInfo> which is a compilation
	result object."

	| error |
	error := self new.
	error errorMessage: errString.
	error errorInterval: interval.
	error sourceCode: srcString.
	^error! 
sourceCode
	"Answer the source code that was being compiled when the receiver
	was discovered."

	^sourceCode!
sourceRange
	"Answer the interval within the source code where the error was discovered"

	^errorInterval! 
sourcePosition
	"Answer the position in the source code at which the error was discovered
	(the best guess as to where the programmer's attention should be focused)."

	^self sourceRange first! 
retryable
	"indicate that the compiler is willing to retry the action that caused this error"
	self setRetryable: true! 
setProceedable: bool
	"Private-This is the assignment accesor for the instance variable proceedable"
	proceedable := bool!  
setReplacementSource: string
	"Private-This is the assignment accesor for the instance
	variable replacementSource"

	replacementSource:= string! 
errorMessage
	"Answer a textual description of the error that is represented by the receiver."

	^errorMessage!
sourceCode: aString
	"Private-Set the reference to the source code that was being compiled by
	the receiver to be <aString>."

	sourceCode:= aString! 
canRetry
	"return true if the compiler is willing to retry the action that caused this error"
	^self getRetryable == true "note, the retryable flag might be nil!!!!"!  
getReplacementSource
	"Private-This is the accessor for the instance variable replacementSource"
	^replacementSource!   
retry
	"Indicate that the compiler should 'back up' and reattempt the action it
	was performing when the error as detected.  Presumably, the cause of
	the error has now been corrected"

	self setProceedable: false  "if we are going to retry then we won't proceed"! 
getProceedable
	"Private-This is the accessor for the instance variable proceedable"
	^proceedable! 
proceedable
	"indicate that this error is proceedable"
	self setProceedable: true!  
recompileWith: newSourceCode
	"abort the current compilation and reattempt it using the argument string
	as the source code to compile"

	self setReplacementSource: newSourceCode.
	self abort! 
getRetryable
	"Private-This is the accessor for the instance variable retryable"
	^retryable!   
hasReplacement
	"Answer true if the error handler has provided a replacement for the source
	code that should be used to reattempt the compilation"

	^self getReplacementSource notNil!  
errorMessage: aString
	"Private-Set the description of the error that is represented by the
	receiver to be <aString>."

	errorMessage := aString!
replacementSource
	"Answer the source code that is to be used in reattempting the compilation"

	^self getReplacementSource!   
canProceed
	"return true if the compiler is willing to proceed after the processing of this error"
	^self getProceedable == true "note, the proceedable flag might be nil!!!!"! 
proceed
	"Indicate that the error should be ignored and that compilation should
	continue as if the error had never been detected"

	self setRetryable: false  "if we are going to proceed, then we won't retry"! 
abort
	"Arrange to abort the compilation when control is returned from the error
	handler to the compiler."

	self setRetryable: false.  "if we are going to abort then we won't retry"
	self setProceedable: false.  "if we are going to abort then we won't proceed"!  
errorInterval: anInterval
	"Private-Set the interval that specifies where in the source string to the
	string that the error occured"

	errorInterval := anInterval!  
setRetryable: bool
	"Private-This is the assignment accesor for the instance variable retryable"
	retryable:= bool! 
privateChangeSuperclassTo: aClass
        "Private - change the superclass of the receiver to be <aClass>.
		Don't use this message: improper usage can cause the system
		 to break in non-obvious ways."
    super privateChangeSuperclassTo: aClass.
    self computeInstSize.
    self allSubclasses do: [ :c |
        c recomputeMethodArray.
        c computeInstSize].!  
saveSessionAs: nameString description: descriptionString
        "Private - save the image to the file named nameString,
         with descriptionString.  Answer true if saved successfully,
         otherwise false."
    | int handles oldImageName primErrorCode buildExeErrorCode result tempDir file illegalChars |
    illegalChars := '<>:|/\?*"'.
    illegalChars do: [ :char |
        ( nameString includes: char ) ifTrue: [
            MessageBox
                notify: 'IMPORTANT WARNING'
                withText: nameString, ' contains an illegal character; the image cannot be saved.'.
            ^false ] ].

    file := File fromPath: nameString.
    ( file exists and: [ file isReadOnly ] ) ifTrue: [
        MessageBox
            notify: 'IMPORTANT WARNING'
            withText: nameString, ' is marked read-only; the image cannot be saved'.
        ^false ].
    ( self class testDiskSpaceRequiredToSaveImage: nameString backup: BackupImage )
        ifFalse: [ ^false ].
    SmalltalkLibraryBinder okToSaveImage ifFalse: [ ^false ].

    CursorManager execute change.
    oldImageName := self imageName.
    [ self aboutToSaveImage ] on: VetoAction do: [ ^self ].
    BackupImage ifTrue: [ self backupImage ifFalse: [ CursorManager normal change. ^false ] ].
    ( Sources at: 2 ) close.

    tempDir := Directory current.
    Disk makeCurrent.

    int := Process enableInterrupts: false.
    handles := IdentityDictionary new.
    File allInstancesPrim do: [ :each |
        handles at: each put: each fileId.
        each fileId: nil ].
    DynamicLinkLibrary withAllSubclasses
        do: [ :class | class clearCachedAddresses ].

    primErrorCode := self primitiveSaveSessionAs: nameString description: descriptionString.
    handles associationsDo: [ :a | a key fileId: a value ].
    Process initializeFrameMarker.
    primErrorCode = 0 ifTrue: [ buildExeErrorCode := self buildExe: nameString fromExe: oldImageName ].
    Process enableInterrupts: int.
    SourceManager current openChangeLogIn: ( Sources at: 2 ) file directory.
    ( primErrorCode = 0 and: [ buildExeErrorCode = 0 ] )
        ifTrue: [
            SourceManager current
                logEvaluate: '"*** saved image on: ', Date today printString, ' ', Time now printString, ' ***"'.
            ( Sources at: 2 ) flush.
            self triggerEvent: #savedImage.
            self setImageName: nameString.
            result := true ]
        ifFalse: [
            self error: 'Save image failed, primitive error code = ', primErrorCode printString,
                ', build exe error code = ', buildExeErrorCode printString.
            result := false ].
    tempDir makeCurrent.
    Notifier clearSavedWindows.
    CursorManager normal change.
    ^result!
defaultSubclass
	"Private - Answer the default concrete subclass."

	^DefaultSubclass! 
defaultSubclass: aClass
	"Private - Set the default concrete subclass."

	DefaultSubclass := aClass!   
fromCompiledMethod: aMethod
	"Answer an instance of the default concrete
	subclass representing the source code
	of aMethod."

	( aMethod sourceObject isKindOf: self ) ifTrue: [ ^aMethod sourceObject ].
	^self defaultSubclass fromCompiledMethod: aMethod!  
asString
	"Answer the String represented by the receiver."

	self implementedBySubclass!   
setClassComment: aString forClass: aClass
	"Capture the string argument as the class comment for the argument class.
	The default implemention discards the string because a storage mechanism is not available.
	Subclasses should override this method if they implement class comments"

	^self!  
conversions
        "Answer the conversions supported by this kind of object."
    ^#(
		#asFileSystemLocator
		#asFileSystemPath )!  
isActivationVisibleForInstanceSelector: aSymbol
	"Return true if activation of the argument symbol sent as a message to instances of this class should be visible in the debugger. Only selected message to instance of ExceptionHandler are normally invisible"

   ^(#(#activateHandler: #handle #signal) includes: aSymbol) not!
saveImageFile
        "Private - Save the current image and
         log the event on the change log."
    ^SessionModel current saveSession!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #key
        #hmf
        #bbox
        #inch
        #reserved
        #checksum
    )!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #dcHandle
        #eraseFlag
        #rectangle
        #fRestore
        #fIncUpdate
        #rgbReserved
    )! 
sourceString
        "Answer the uncompressed source
         code for the receiver."

    ^self source!  
fileInGoFile
        "Private - check for the existence of a file named 'go'
         in the startup directory, and if so, file it in as Smalltalk
         source code."
    ( File exists: 'go' )
        ifTrue: [ ( File pathNameReadOnly: 'go' ) fileIn; close ]!   
allMethodsReferencingInstVar: aString
        "Answer a collection of all the methods in the receiver that
        reference the instance variable named aString."
    | answer index allInstances |
    answer := OrderedCollection new.
    allInstances := self allInstVarNames.
    index := allInstances indexOf: aString ifAbsent: [ ^answer ].

    CursorManager execute changeFor: [
        self methodDictionary do:
            [ :method |
            ( method includesReferenceFor: index )
                    ifTrue: [ answer add: method ]
            ]
        ].
    ^answer.!   
statistics
    "Answer an Array of four statistical measures for the receiver.
        1:    minimum bucket size
        2:    maximum bucket size
        3:    average bucket size
        4:    histogram of number of buckets with same size from 0 to maximum bucket size"

    | min max sum hist bucket count |
    min := self size // 2.
    max := 0.
    sum := 0.
    2 to: self size by: 2 do:
        [:index |
        bucket := self at: index.
        bucket == nil
            ifTrue: [count := 0]
            ifFalse: [count := bucket count].
        min := min min: count.
        max := max max: count.
        sum := sum + count].
    hist := Array new: max + 1.
    hist atAllPut: 0.
    2 to: self size by: 2 do:
        [:index |
        bucket := self at: index.
        bucket == nil
            ifTrue: [count := 0]
            ifFalse: [count := bucket count].
        hist at: count + 1 put: (hist at: count + 1) + 1].
    ^Array
        with: min
        with: max
        with: (sum asFloat / (self size // 2))
        with: hist!
initializeDefaultPoolNames
        "Private - initialize the default pool names."
    DefaultPoolNames := OrderedCollection new
        add: #OperatingSystemConstants;
        add: #CharacterConstants;
        add: #GraphicsConstants;
        add: #VirtualKeyConstants;
        yourself!
saveSessionAs: nameString
        "Private - save the image to the specified image name,
         using a default description.  Answer true if saved successfully,
         otherwise false."
    ^self
        saveSessionAs: nameString
        description: Smalltalk product, ' ', Smalltalk version!   
initializeTranscript
        "Private - Create the system transcript window."
    self new open!
defaultClass
        "Private - answer the class which is used to create the Transcript window
        when reinitialized."
    DefaultClass isNil ifTrue: [ ^self ].
    ^DefaultClass isClass
        ifTrue: [ DefaultClass ]
        ifFalse: [ Smalltalk at: DefaultClass ]!   
defaultClass: aClassOrSymbol
        "Private - set the class which is used to create the Transcript window
        when reinitialized to aClassOrSymbol."
    DefaultClass := aClassOrSymbol! 
iconId
        "Answer the icon id for this window class."
    ^1!  
initialize
        "Private - initialize class variables of the receiver."
    self defaultClass: #TranscriptWindow!
initWindowSize
        "Private - Answer the initial size & position of the receiver."
    | unitMultiplier |
    unitMultiplier := SysFontWidth @ SysFontHeight  .
    ^( Display boundingBox leftTop rightAndDown: 2@2 * unitMultiplier )
        extentFromLeftTop: 53@13 * unitMultiplier!   
createView
        "Private - create the panes for the receiver window."
    | pane |
    self
        setLabel;
        owner: self.
    self mainView when: #aboutToClose send: #close: to: self with: self mainView.
    self addSubpane: ( ( pane := self textPaneClass new )
        setName: #text ;
        when: #saved send: #saveString: to: self with: pane;
        owner: String new;
        dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
        dragTarget: self class dragDropEnabled;
        yourself )! 
saveString: aPane
        "Private - Save the contents of a workspace."
    aPane owner: aPane contents.
    ^aPane modified: false!   
forgetImage
        "Private - Exit without saving the image."
    | changeLog |
    ( changeLog := Sources at: 2 ) isNil
        ifFalse: [ changeLog setToEnd; flush ].
    Smalltalk exit!
close: topPane
        "Private - the receiver is about to close...continue?"
    | answer |
    Transcript isNil ifTrue: [ ^self ].  "during Notifier reinitialize"
    answer := SaveImageDialog new openYesNoCancel answer.
    answer isNil ifTrue: [ ^topPane abortClose ].
    answer
		ifTrue: [ self saveExit ]
		ifFalse: [ self forgetImage ]!  
setLabel
        "Private - set the label of the Transcript; if the image name
        is not V.EXE, show it in the Transcript window label."
    self label: self label!  
label
        "Private - answer the label of the window."
    | string imageName |
    string := 'Transcript'.
    ( ( imageName := SessionModel current imageName ) equalsIgnoreCase: 'V.EXE' )
        ifFalse: [ string := string, ': ', imageName ].
    ^WindowLabelPrefix, ' ', string!   
aboutDialogClass
        "Private - answer the class which defines the AboutDialog (for help manager)."
    ^AboutDialog!   
saveExit
        "Private - Save the current image and exit."
    self mainView saveImageNoConfirm
        ifTrue: [ Smalltalk exit ]! 
saveAs
        "Private - User selected SaveAs..."
    | fileName |
    fileName := (FileDialog new saveFile: 'untitled.txt') file.
    fileName isNil ifTrue: [^nil].
    file := File pathName: fileName.
    self pane fileOutOn: file.
    file close! 
open
        "Create and open the receiver window."
    self createView.
    self addHelpManager.
    Transcript isNil
        ifTrue: [ Transcript := self ]
        ifFalse: [ Transcript become: self ].
    self openWindow!   
exitDevelopment
        "Private - perform pre-exit cleanup required only in development."
    ( Smalltalk includesKey: #SmalltalkEmulator )
        ifTrue: [ ( Smalltalk at: #SmalltalkEmulator ) exit ].
    Sources notNil ifTrue: [
        Sources do: [ :each |
            each isFileStream ifTrue: [ each close ] ] ]!
operationDescriptions: aDictionary
        "Private - set the map between known operation names
        ('move', 'copy', 'link') and their names as they should appear in
        a UI to aDictionary."
    OperationDescriptions := aDictionary! 
rename: aString
        "Rename the receiver to aString."
    self rename: aString in: Smalltalk!   
debuggerVariables
    "Return a collection of variable locators for variables visible to the method. This will include all temporaries and arguments."

	| vars |
	vars := OrderedCollection new.
	vars addAll: ( self getParseTree arguments collect: [:var | VariableLocator for: var ] ).
	vars addAll: ( self getParseTree temporaries collect: [:var | VariableLocator for: var ] ).
	^vars!  
backup: fileName sourceIndex: si message: aString
        "Private - Make backup of the image if needed"
    | bName fileDirectory copied |
    "don't make a backup if no source file exists to backup (such as for save image as...
    to a new EXE name."
    ( File exists: fileName ) ifFalse: [ ^true ].
    bName := fileName copy.
    bName replaceFrom: bName size - 2
            to: bName size
            with: 'BAK'
            startingAt: 1.
    si > 0 ifTrue: [
        fileDirectory := ( Sources at: si ) file directory.
        ( Sources at: si ) close ].
    copied := File copy: fileName to: bName.
    si > 0 ifTrue: [
        Sources at: si
            put: ( fileDirectory file: ( Sources at: si ) file name ).
        ( Sources at: si ) lineDelimiter: Cr ].
    copied ifFalse: [
        MessageBox
            notify: 'IMPORTANT WARNING'
            withText: aString, ' because ',
                fileName, ' could not be backed up to ', bName,
                '.  You should determine the cause of the problem (such as "out of disk space").',
                ' You can set the BackupImage global variable to false or free up disk space WITHOUT exiting Smalltalk and please try again.' ].
    ^copied!  
specialSelectors
        "Private - answer a Dictionary containing names & ids for
        special selectors."
    ^self byteCodeReaderClass specialSelectors! 
initializeWinClassMap
        "Private - initialize a Dictionary mapping host control
         class names to their Smalltalk equivalent ControlPane
         subclasses"
    WinClassMap := Dictionary new
        at: 'Static' put: StaticText;
        at: 'Edit' put: EntryField;
        at: 'Button' put: Button;
        at: 'ScrollBar' put: ScrollBar;
        at: 'ListBox' put: ListBox;
        at: 'ComboBox' put: ComboBox;
        yourself!
buildSystemContextStrings
        "Private - Build the system context strings dictionary"
    SystemContextStrings := Dictionary new
        at: ScTasklist put: 'ScTasklist';
        at: ScMove put: 'ScMove';
        at: ScMinimize put: 'ScMinimize';
        at: ScMaximize put: 'ScMaximize';
        at: ScClose put: 'ScClose';
        at: ScRestore put: 'ScRestore';
        at: ScSize put: 'ScSize';
        at: ScNextwindow put: 'ScNextwindow';
        at: ScHscroll put: 'ScHscroll';
        at: ScVscroll  put: 'ScVscroll';
        yourself.! 
openDiskBrowser
        "Private - The user selected Browse Disk from the Smalltalk menu."
    SmalltalkToolInterface current diskBrowserClass new open!
debuggerVariablesAt: ic
    "Return a collection of variable locators for variables visible to the method at ic in its execution."

	| xcScope |
	xcScope := self getParseTree scopeWhoContains: ( self translateProcessorIC: ic ).
	^xcScope isBlock
		ifTrue: [ ( BlockDescription for: xcScope ) debuggerVariables ]
		ifFalse: [ self debuggerVariables ].!
defineGlobal: aSymbol
        "Private - The compiler performs this method when it finds an undefined global.
         Answer true if name should be a new global.  Answer false if name should
         remain undefined. Raise an exception if the whole fileIn should be canceled."
    | result |
    result := MessageBox
        threeStateNotify: 'Please Confirm'
        withText: 'Define ' , aSymbol printString , ' as global variable?'.
    result == nil
        ifTrue: [ Notification signal: 'Abort Compilation'. ^false ].
    ^result!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #style #color #hatch )!  
initialize
        "Private - Initialize class variables."
    AtSelectors := Dictionary new.
    AtPutSelectors := Dictionary new.
    AtSelectors
        at: #ushort put: #uShortAtOffset: ;
        at: #short put: #shortAtOffset: ;
        at: #ulong put: #uLongAtOffset: ;
        at: #long put: #longAtOffset: ;
        at: #handle put: #handleAtOffset: ;
        at: #byte put: #byteAtOffset:.
    AtPutSelectors
        at: #ushort put: #uShortAtOffset:put: ;
        at: #short put: #shortAtOffset:put: ;
        at: #ulong put: #uLongAtOffset:put: ;
        at: #long put: #longAtOffset:put: ;
        at: #handle put: #handleAtOffset:put: ;
        at: #byte put: #byteAtOffset:put:.
    Definitions := Dictionary new.
    MethodDictionaries := Dictionary new!  
printSummary
	"Private - print a summary of the contents of the receiver."

	| stream |
	stream := String new asStream.
	self printSummaryOn: stream.
	^stream contents!
doIt
        "Do It was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self activeTextPane notNil
        ifTrue: [ self activeTextPane doIt ]!   
initializeEventSystem
        "Initialize the class variables for
         detecting recursive data structures."
    RecursiveSet := Set new.
    RecursionInError := nil.
    self initializeEvents!
fields
		"Answer the names of the fields contained in this kind of object."
    ^#(
		#creationTime
		#directory
		#lastAccessTime
		#lastModificationTime
		#volume
		#volumeLabel
	)!  
openServiceManagerWindow
        "The user selected Browse Services from the Smalltalk menu."
    self mainView openServiceManagerWindow!   
streamReference: aStreamReference position: anInteger
	"Answer an instance of the receiver."

	^self new
		streamReference: aStreamReference ;
		position: anInteger ;
		yourself!  
initialize
	"Private - Initialize class vars."

	StreamIndexBits := 8.
		"we actually want 10 here, but for now we leave it 8
		so that it works with existing images."
	WithMethodIndex := 4.
	InAssociatedFileIndex := 5.!   
sourceWithMethod: aString on: aStream
    "Private - Write aString to aStream
    and answer the encoded integer
    which represents the reference to aString."

    | answer |
    answer := self streamIndex: WithMethodIndex position: (
        SourceManager current getMethodPositionOn: aStream for: aString ).
    aStream nextChunkPut: aString.
    ^answer!  
streamIndex: anInteger1 position: anInteger2
	"Private - Answer an encoded integer."

	anInteger1 >= ( 2 raisedToInteger: StreamIndexBits )
        ifTrue: [ ^self error: 'stream index too big' ].
	^( anInteger2 bitShift: StreamIndexBits ) + anInteger1!
fromCompiledMethod: aMethod
    "Answer an instance of the receiver
    representing the source code of aMethod.
    ASSUMPTION: aMethod sourceObject is an Integer."

    | index position sourceObject lastSpecialIndex |
    sourceObject := aMethod sourceObject.
    index := sourceObject bitAnd: self indexMask.
    position := sourceObject bitShift: StreamIndexBits negated.
    (index between: 1 and: Sources size)
        ifTrue: [ ^self streamReference: ( SystemStreamReference indexed: index ) position: position ].
    lastSpecialIndex := InAssociatedFileIndex.
    ( index = WithMethodIndex or: [ index = InAssociatedFileIndex ] )
        ifTrue: [
            "The source can be found based on the library the method is contained in."
            sourceObject := self streamIndex: aMethod sourceLibraryOrdinal + lastSpecialIndex position: position.
            aMethod sourceObject: sourceObject.    "Fix it so the method's source location is no longer dependent on the method's location."
            ^self streamReference: aMethod sourceLibrary sourceReference position: position ].
    "else index > lastSpecialIndex"
    ^self streamReference: ( SmalltalkLibraryBinder libraryForSourceIndex: index - lastSpecialIndex ) sourceReference position: position.!
indexMask
	"Private - Answer a mask for the index bits."

	^( 2 raisedToInteger: StreamIndexBits ) - 1!
position: anInteger
	"Private - Set the position for the receiver to anInteger."

	position := anInteger!  
asString
    "Answer the string represented by the receiver."

    | s |
    s := streamReference positionedReadStream: position.
    s == nil ifTrue: [ ^nil ].
    ^s nextChunk!  
streamReference: aStreamReference
	"Private - Set the stream reference for the receiver to aStream."

	streamReference := aStreamReference!
setCompilationOptions: aCompilerInterface
	"The message is sent when a compiler interface object is being created
	that will process method definitions within the receiver.  The receiver may
	add or modify any compilation options by sending appropiate message to 
	the argument"

	^self    "the default implementation does not modify any options"! 
aboutToSaveImage
        "Private - save the size of the screen & reinitialize
        cached system colors before saving."
    OriginalScreenExtent := Display extent.
    Color initializeSystemColors! 
justBound
        "Private - the DEV library has been bound, complete its installation."
    ( self class compiledMethodAt: #justBound ) smalltalkLibrary releaseUnbindInfo!
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a
        subclass of the receiver with the specifed instance variables,
        class variables, pool dictionaries, and class instance variables."

	^self
		subclass: className
    	instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
    	poolDictionaries: poolDictionaries
		isVariable: false
		isPointers: true!  
for: anXCVariable
	"Private - Create an instance of the receiver."

	^self new binding: anXCVariable binding!  
forBinding: anXCIdentifierBinding
	"Private - Create an instance of the receiver."

	^self new binding: anXCIdentifierBinding! 
isGraphicObject: anObject
        "Private - answer whether anObject is a graphic object."
    ^anObject isBitmap or: [
        anObject isDIB or: [
        anObject isIcon or: [
        anObject isCursor or: [
        anObject isStoredPicture ] ] ] ]!
initialize
        "Private - Set ColorCount to zero."
    ColorCount := 0! 
argumentTypeNumber: aSymbol ifAbsent: aBlock
        "Private - Answer the argument type number
         for aSymbol.  If aSymbol not a
         valid argument type, evaluate
         aBlock."
    ^Types at: aSymbol ifAbsent: aBlock!
defaultPoolNames
        "Private - answer a collection of pools to use as a default when evaluating
        expressions"
    DefaultPoolNames isNil ifTrue: [ self initializeDefaultPoolNames ].
    ^DefaultPoolNames!  
source
        "Answer a String containing the source
        code for the receiver."
    sourceObject == nil ifTrue: [ ^nil ].
    sourceObject isInteger ifFalse: [ ^sourceObject asString ].
    ^( StringReference fromCompiledMethod: self ) asString!  
saveImageAs
        "Private - The user selected SaveImage menu item
         from the File menu."
    | dialog |
    Smalltalk isRunTime
        ifTrue: [ MessageBox message: 'Cannot save image with the run-time system.' ].
    dialog := SaveImageAsDialog new open!  
initializeControlKeys
        "Private - Add all defined control keys to the control keys set."
    ControlKeys := Set new
		add: Cr;
        add: BackspaceKey;
		add: CapitalKey;
		add: ClearKey;
		add: ControlKey;
		add: DeleteKey;
		add: DownKey;
		add: EndKey;
		add: EscapeKey;
		add: F1Key;
		add: F2Key;
		add: F3Key;
		add: F4Key;
		add: F5Key;
		add: F6Key;
		add: F7Key;
		add: F8Key;
		add: F9Key;
		add: F10Key;
		add: F11Key;
		add: F12Key;
		add: F13Key;
		add: F14Key;
		add: F15Key;
		add: F16Key;

"		add: F17Key;
		add: F18Key;
		add: F19Key;
		add: F20Key;
		add: F21Key;
		add: F22Key;
		add: F23Key;
		add: F24Key;
"
		add: HomeKey;
		add: InsertKey;
		add: NumLockKey;
		add: PageDownKey;
		add: PageUpKey;
		add: PauseKey;
		add: ReturnKey;
		add: RightKey;
		add: ShiftKey;
		add: SnapShotKey;
		add: SpaceKey;
		add: TabKey;
		add: UpKey;
		yourself!
initialize
        "Private - Initialize class variables."
    ValueArray := Array new: 4!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass
        fields: #( #dwLowDateTime #dwHighDateTime )
        conversions: #( #asDate #asDosDateTime #asLocalFileTime #asSystemTime #asTime #asTimeStamp )! 
iconId
		"Answer the icon id for this window class."
	^7!   
listMenu: listPane
        "Private - Set the list pane menu."
    listPane setMenu: ( ( Menu
        labels: '\uDelete\n\uRemove From List\n\uSenders\n\uImplementors\n\uLocal Senders\nLocal Im\uplementors\n\uMessages\nFile O\uut...\nFile Out \uAll...' replaceEscapeCharacters
        lines: #( 2 7 )
        selectors: #( #removeSelector #removeFromList #senders #implementors #localSenders #localImplementors #messages #fileOutMethod #fileOutAll ) )
            title: '\uMethod' replaceEscapeCharacters;
            owner: self;
            yourself )!   
initWindowSize
        "Private - Answer the initial window extent."
    ^( SysFontWidth * 70 ) @ ( SysFontHeight * 20 )!   
fileOutAll
        "Private - Write the source for all methods
         in chunk file format to a file."
    | file fileDialog classReader |
    fileDialog := FileDialog new
        saveTitle: 'File out all methods'
        fileName: 'untitled.st'.
    ( file := fileDialog file ) isNil ifTrue: [ ^nil ].
    file := File newFile: file.
    classReader := ClassReader new.
    CursorManager execute changeFor: [
        methods do: [ :cm |
            classReader setClass: cm classField.
            classReader fileOutMethod: cm selector on: file ] ].
    file close!   
createView
        "Private - create the panes for the receiver window."
    | ratio pane |
    ratio := 2 / 5.
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #methodList: ;
            when: #needsContents send: #methodList: to: self with: pane;
            when: #needsMenu send: #listMenu: to: self with: pane;
            when: #clicked: send: #method: to: self with: pane;
            dragSource: self class dragDropEnabled;
            when: #dragSourceNeedsObject: send: #methodListSetDragObject: to: self;
            when: #dragSourceCut: send: #methodListCut: to: self;
            framingRatio: ( Rectangle leftTopUnit extentFromLeftTop: ( 1 @ ratio ) ) ).
    self addSubpane:
        ( ( methodPane := self toolTextPaneClass new )
            setName: #text: ;
            when: #needsContents send: #text: to: self with: methodPane;
            when: #saved send: #accept: to: self with: methodPane;
            dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
            dragTarget: self class dragDropEnabled;
            framingRatio: ( ( Rectangle leftTopUnit rightAndDown:  0 @ ratio )
                extentFromLeftTop: 1 @ ( 1 - ratio ) ) ).!   
literal: anObject
        "Private - Request highlighting of source code
         that refers to anObject."
    highlightLiteral := anObject!  
openOn: aMethodCollection
        "Create a method browser window on
        aMethodCollection"
    methods := aMethodCollection asOrderedCollection.
    self
        createView;
        addHelpManager;
        openWindow;
        disableMethodsMenu!
method: listPane
        "Private - Display source code for
         the selected method."
    selectedMethod := methods at: listPane selection.
    selectedMethod := selectedMethod classField
        compiledMethodAt: selectedMethod selector.
    selectedMethod isNil
        ifTrue: [self error: 'deleted method'].
    methods at: listPane selection put: selectedMethod.
    self changed: #text:.
    self enableMethodsMenu.
    positions isNil ifFalse: [
        positions isPoint
            ifTrue: [ methodPane showSelectionFrom: positions x to: positions y + 1 ]
            ifFalse: [
                methodPane
                    showSelectionFrom: positions position
                    to: positions endPosition ] ]! 
removeSelector
        "Private - Remove the selected method."
    selectedMethod isNil ifTrue: [ ^nil ].
    SourceManager current
        logEvaluate: selectedMethod classField name, ' removeSelector: #', selectedMethod selector
        for: [ selectedMethod classField removeSelector: selectedMethod selector ].

    methods := methods asOrderedCollection.
    methods remove: selectedMethod.
    selectedMethod := nil.
    self disableMethodsMenu.
    self
        changed: #methodList: ;
        changed: #text:!
dragDropSourcePanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag source."
    ^Array with: #methodList:! 
selectedMethodSelector
		"Private - answer the selector for the selected method."
	^selectedMethod selector!
text: textPane
        "Private - Compile the selected method
         source to determine highlight positions."
    | source string debugInfo|
    positions := nil.
    ( selectedMethod notNil
    and: [ ( source := selectedMethod sourceString ) notNil
    and: [ highlightLiteral notNil ] ] ) ifTrue: [
        highlightLiteral isSymbol
            ifTrue: [
                debugInfo := selectedMethod definition debugInfo.
                positions := debugInfo positionNodes whoContainsLiteral: highlightLiteral.
                string := highlightLiteral asString ]
            ifFalse: [
                string := highlightLiteral.
                string isAssociation ifTrue: [ string := string key ].
                positions := ( Pattern new: string ) match: source index: 1 ].
        ( self paneAt: #text: ) class searchString: string ].
    ( selectedMethod notNil and: [ source isNil ] )
        ifTrue: [ source := '** source code is missing **' ].
    textPane contents: source!   
accept: textPane
        "Private - Accept the contents of textPane as an updated
         method and compile it.  Notify textPane if
         the compiler detects errors."
    | result class aString |
    aString := textPane contents.
    class := selectedMethod classField.
    result := class
        compile: aString
        notifying: textPane.
    result isNil
        ifTrue: [^textPane modified: true]
        ifFalse: [
            SourceManager current
                logSource: aString
                forSelector: result key
                inClass: class.
            result key == selectedMethod selector
                ifTrue: [
                    methods at: (methods indexOf: selectedMethod)
                        put: (selectedMethod := result value)]
                ifFalse: [
                    selectedMethod := result value.
                    methods add: selectedMethod.
                    self
                        changed: #methodList:
                        with: #restoreSelected:
                        with: selectedMethod printString].
            ^textPane modified: false]!  
selectedClass
		"Private - answer the selected class."
	^selectedMethod classField! 
dragDropTargetPanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag target."
    ^Array with: #text:!   
selectedMethod
		"Private - answer the selected method."
	^selectedMethod!  
removeFromList
        "Private - Remove selected method."
    selectedMethod isNil
        ifFalse: [
            methods remove: selectedMethod.
            self
                changed: #methodList:
                with: #restore.
            selectedMethod := nil.
            self changed: #text:]!  
methodList: listPane
        "Private - Set the list of methods."
	methods isNil ifTrue: [ listPane contents: Array new. ^self ].
    listPane contents: ( methods collect: [ :cm | cm printString ] )!
methodListCut: dragSession
		"Private - cut the dragged method on a move operation."
    methods := methods removeIndex: dragSession source selection; yourself.
	self changed: #methodList:!  
install
        "Private - User selected Install... from the File menu."
    | dialog file  dll |
    dialog := FileDialog new.
    dialog
        title: 'Install';
        fileSpec: '*.*';
        addSmalltalkFileFilters;
        addFilter: '*.*' description: 'All Files (*.*)';
        addFilter: '*', SmalltalkLibrary fileExtension
            description: 'Smalltalk Library Files (*', SmalltalkLibrary fileExtension asUpperCase, ')';
        defFilter: '*.*';
        hideReadonly;
        open.

    file := dialog file.
    file isNil ifTrue: [^self].
    ( '.', file fileExtension asUpperCase = SmalltalkLibrary fileExtension asUpperCase
    and: [ ( File findFileName: file fileNameLessPath ) isNil ] )
        ifTrue: [
            ( MessageBox confirm: 'Object libraries must be located in the Smalltalk startup directory or on the PATH.  Copy ', file fileNameLessPath, ' to startup directory (', Disk drivePathName, ')?' )
                ifTrue: [
                    File copy: file to: Disk drivePathName, '\', file fileNameLessPath.
                    ( File exists: file fileName, SmalltalkLibrary sourceFileExtension )
                        ifTrue: [
                            File copy: file fileName, SmalltalkLibrary sourceFileExtension to: Disk drivePathName, '\', file fileNameLessPath fileName, SmalltalkLibrary sourceFileExtension ].
                    file := file fileNameLessPath ]
                ifFalse: [ ^nil ] ].
    file := File pathNameReadOnly: file.
    CursorManager execute changeFor: [
        ('.', file file name fileExtension asUpperCase = SmalltalkLibrary fileExtension asUpperCase )
            ifTrue: [
                dll := file file name fileName trimBlanks.
                file close.
                SourceManager current
                    logEvaluate: 'SmalltalkLibraryBinder bindTo: ', dll storeString
                    for: [ SmalltalkLibraryBinder bindTo: dll ] ]
            ifFalse: [
            ('.', file file name fileExtension asUpperCase = SmalltalkLibrary sourceFileExtension asUpperCase )
                ifTrue: [ ( MessageBox confirm: 'File In a ', SmalltalkLibrary sourceFileExtension, ' file? Are you sure?' )
                    ifFalse: [ file close. ^self ] ].
            file fileIn ] ].
    file close!  
doIt
        "Do It was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self mainView doIt! 
expressionEvaluatorClass
        "Private - answer the class of ExpressionEvaluator
        which is used if not otherwise specified."
    ^ExpressionEvaluator!   
initialize
        "Initialize the class variables of the receiver."
    CurrentSession := self new!
inspect
        "Open a dictionary inspector window
         on the receiver."
    DictionaryInspector new openOn: self!   
primitiveSpecification
	"Answer a string containing the primitive specification found in the
	source code, including the enclosing brackets ('<' and '>').  If the
	source code had no primitive specifiction, the answer is the empty string"

	self implementedBySubclass! 
nonLocalNames
	"Answer a list of the names of all variables referenced but not defined
	within the source."

	self implementedBySubclass! 
wasSuccessful
	"Answer <true> if the receiver represents a successful compilation."

	self implementedBySubclass!  
association
		"Answer an association between the method selector and 
		the compiled method that was created.  Answer nil if the compilation
		was unsuccessful or if what was compiled was not a method"
	|sel meth|
	(sel := self selector) isNil ifTrue: [^nil].
	(meth := self method) isNil ifTrue: [^nil].
	^Association new key: sel asSymbol; value: meth! 
temporaryNames
	"Answer a list of the names of all temporary variables and
	block arguments defined within the source."

	self implementedBySubclass! 
argumentNames
	"Answer a list of the names of all method arguments defined within the source."
	self implementedBySubclass! 
errorMessage
	"if the compilation was unsuccessful then return a string describing the error
	that terminated compilation, otherwise return an empty string"

	self wasSuccessful
		ifTrue: [^'']
		ifFalse: [^self error errorMessage]!
messages
	"Answer a list of the messages sent within the source."
	self implementedBySubclass!  
localNames
	"Answer a list of the names of all variables defined within the source."
	^self argumentNames , self temporaryNames!   
error
	"if the compilation was unsuccessful then return the Compilation Error
	object that describes the error that terminated compilation"

	self implementedBySubclass! 
method
	"Answer the compiled method that was created by the compilation.
	Answer nil if the compilation was unsuccessful"
	self implementedBySubclass!
nameScope
	"Return the name scope within which compilation occured"
	self implementedBySubclass!
wasEvaluated
	"Answer <true> if the compilation was successful, the source code was
	for an expression and its evaluatons has been completed"

	self implementedBySubclass!   
asString
        "Answer the string representing the receiver, which is
        its source code string."
	^self sourceCode!
evaluate
	"If this is the result of a successful compilation of a do-it or initializer,
	then evaluate it, remember and return the result.
	Otherwise the result is undefined"

	self implementedBySubclass! 
unreferencedTemporaryNames
    "Answer a list of the names of all declared method temporaries not referenced by the source."

    self implementedBySubclass!  
selector
	"Answer the method selector by which the compiled method
	would normally be invoked. Answer nil if the an expression was
	compiled or if the compilation was unsuccessful"

	self implementedBySubclass!  
value
	"if the source code was an expressions and it was successfully
	compiled and evaluated answer the result of the evaluation.
	Otherwise the return value is undefined"

	^evaluationResult!
isCompilationResult
        "Answer true if this object responds to compilation result protocol."
    ^true!
sourceCode
	"Answer the source code that was parsed. This may be different
	from the original source code if the source was modified by an error handler."
	self implementedBySubclass!   
privateChangeSuperclassTo: aClass
        "Private - change the superclass of the receiver to be <aClass>.  
		Don't use this message: improper usage can cause the system
		 to break in non-obvious ways."
    self superclass ~~ nil
        ifTrue: [ self superclass removeSubclass: self ].
    self superclass: aClass.
    self superclass ~~ nil
        ifTrue: [ self superclass addSubclass: self ].
    self recomputeMethodArray!  
compileDefinition: aString
        "Convert the structure definition named aString
         into compiled field accessor form."
    | definition sourceString md assoc |
    definition := Definitions
        at: aString
        ifAbsent: [ ^self error: 'Undefined SelfDefinedStructure: ', aString ].

    md := MethodDictionary new.
    definition associationsDo: [ :a |
        sourceString := a key = #sizeInBytes
            ifTrue: [ self compileSizeInBytesSelector: a ]
            ifFalse: [ ( a key includes: $: )
                ifTrue: [ self compileAtPutSelector: a in: aString ]
                ifFalse: [ self compileAtSelector: a in: aString ] ].
            assoc := CompilerInterface compile: sourceString in: self.
            md at: assoc key put: assoc value ].

    MethodDictionaries at: aString put: md! 
isActivationVisibleForInstanceSelector: aSymbol
   "Return true if activation of the argument symbol sent as a message to this class should be visible in the debugger. Instance method inquiries to metaclasses are translated to class method inquiries to the class object"

   ^self instanceClass isActivationVisibleForClassSelector: aSymbol


! 
initializeTranscript
        "Private - create a new Transcript window."
    TranscriptWindow defaultClass initializeTranscript!
libraryOrdinal: anInteger
	"Answer a new instance of the receiver
	which represents the source code stream
	for the library whose ordinal is anInteger."

	^self library: ( SmalltalkLibraryBinder bound at: anInteger )!
library: aLibrary
	"Answer a new instance of the receiver."

	^self new library: aLibrary! 
library: aLibrary
    "Private - Set the cached library for the receiver."

    library := aLibrary.
    self setStream; close.!  
stream: aStream
	"Private - Set the cached stream for the receiver."

	stream :=  aStream! 
readStream
    "Answer the ReadStream referenced by the receiver."

    library == nil ifTrue: [ ^nil ].
    stream == nil ifTrue: [ self setStream ].
    stream == nil ifTrue: [ ^nil ].
    stream file fileId == nil ifTrue: [
		[ stream file openReadOnly ]
			on: FileError
			do: [ ^self setStream; readStream ] ].
    ^stream!   
close
    "Private - Close the file if it is open."

    stream notNil ifTrue: [ stream close ].!  
separateSource
	"Private - Answer a stream for a separate source file."

	| temp sourceFileName sourceFileVersion |
    sourceFileName := File findFileName: ( library fileName, SmalltalkLibrary sourceFileExtension ).
    sourceFileName isNil ifTrue: [ ^nil ].
    temp := File pathNameReadOnly: sourceFileName.
    ( sourceFileVersion := temp nextLine ) = library version
        ifFalse: [ ( MessageBox confirm: 'Source file ', sourceFileName, ' version (', sourceFileVersion, ') does not match library version (', library version,'). Use it anyway?' )
            ifFalse: [ temp close. ^nil ] ].
    ^temp!   
setStream
    "Private - Set the stream for the receiver."

    self stream: ( library integralSource
		ifTrue: [ self integralSource ]
		ifFalse: [ self separateSource ] ).!   
positionedReadStream: anInteger
    "Answer the ReadStream referenced by the receiver,
	positioned to the appropriate place in the stream."

	self readStream == nil ifTrue: [ ^nil ].
    stream position: library sourceBase + anInteger.
    ^stream!
integralSource
    "Private - Answer a stream for source that
	is in with the library file."

    | sourceFileName |
	library file file isOpen ifFalse: [
		[ library file file openReadOnly ]
			on: FileError
			do: [ 
				sourceFileName := File findFileName: ( library fileName, SmalltalkLibrary fileExtension ).
			    sourceFileName isNil ifTrue: [ ^nil ].
			    library file: ( File pathNameReadOnly: sourceFileName ) ] ].
    library file lineDelimiter: Cr.
    ^library file.!   
readStream
	"Answer the ReadStream referenced by the receiver."

	self implementedBySubclass!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #hwndFrom #idFrom #code )!   
createOldResult: result in: aClass
        "Private - support backward compatible compilation result."
    | assoc |
    result wasSuccessful ifFalse: [^nil].
    assoc := result association.
    assoc value classField: aClass.
	assoc value selector: result selector.
    assoc value sourceObject: nil.
    ^assoc!
initialize
        "Private - initialize the global registry."
    self globalRegistry: self newGlobalRegistry! 
setEvaluate: aBoolean
        "Specify whether a compilation for the receiver
        is evaluating an expression or compiling a method."
    self propertyAt: #evaluate put: aBoolean!
openWorkspace
        "Private - The user selected New Workspace from
         the File menu."
    self class textWindowClass new
        label: 'Workspace';
        openOn: ''!
copyright: copyrightString
        "Embeds copyright information contained in aString
        into the image.  aString must be less than 1024 bytes.
        Note: the string will be embedded into the image
        immediately (Saving the image is not required)."
    | fileStream signatureString |
    copyrightString size > 1024
        ifTrue: [ ^self error: 'Copyright string must be 1024 characters or less' ].
    fileStream := File pathName: SessionModel current imageName.
    fileStream position: 11265.
    ( signatureString := fileStream next: 2 ) = 'CR'
        ifFalse: [ ^self error: 'Invalid image file' ].
    fileStream
        next; "copyright seal is 'VCRV', skip past it"
        nextPutAll: copyrightString;
        nextPut: 0 asCharacter;
        close!
decompressionArray
        "Private - answer an Array containing the strings represented
        by compression codes."
    ^DecompressionArray!   
compressionDictionary
        "Private - answer a Dictionary mapping strings to the compression
        codes that represent them."
    | decompressionArray compressionDictionary |
    decompressionArray := self decompressionArray.
    compressionDictionary := Dictionary new: decompressionArray size.
    1 to: decompressionArray size do: [ :index |
        compressionDictionary
            at: ( decompressionArray at: index )
            put: index + 128 ].
    ^compressionDictionary!   
current
        "Answer the current instance which manages Smalltalk sources."
    Current isNil ifTrue: [ Current := self new ].
    ^Current!
current: aSourceManager
        "Set the instance which manages Smalltalk sources to aSourceManager."
    Current := aSourceManager!
addDoubleQuotes
        "Private - Bracket the selected text in a pair
        of double quotes."
    self addLeftBracket: $" rightBracket: $"!
referencesToString: aString
        "Answer a collection of methods in the receiver and its subclasses
        that contain the substring aString."
    | methods source |
    methods := OrderedCollection new: 30.
    self withAllSubclasses do: [ :class |
        class methodDictionary do: [ :method |
            ( source := method sourceString ) notNil ifTrue: [
                ( source indexOfString: aString ) > 0
                    ifTrue: [ methods add: method ] ] ].
        class class methodDictionary do: [ :method |
            ( source := method sourceString ) notNil ifTrue: [
                ( source indexOfString: aString ) > 0
                    ifTrue: [ methods add: method ] ] ] ].
    ^methods!  
saveImage
        "The user selected Save Image... from the File menu."
    self mainView saveImage!
initializeHelp
        "    SmalltalkToolInterface current initializeHelp    "
    | map |
    self helpFileNames: Array new.
    self helpTopics: Array new.
    map := StringDictionaryReader createIdDictionary: '\v32\vwhelp\helpmap.hx'.
    self addHelpFileName: 'vhlp', SmalltalkLibrary versionAndPlatformExtension, '.hlp'.
    self addHelpTopics: map keys.
    map := StringDictionaryReader createIdDictionary: '\v32\eochelp\w32\eoc.h'.
    self addHelpFileName: 'veoc', SmalltalkLibrary versionAndPlatformExtension, '.hlp'.
    self addHelpTopics: map keys!   
openWorkspace
        "The user selected New Workspace from the Smalltalk
        menu."
    self mainView openWorkspace!  
privateRename: aSymbol in: aSystemDictionary
        "Private - Rename the receiver to aSymbol
         in the environment aSystemDictionary.
		Don't use this message: improper usage can cause the system
		 to break in non-obvious ways."
    | association |
    name == nil
        ifTrue: [
            association := Association
                key: aSymbol
                value: self]
        ifFalse: [
            association := aSystemDictionary
                associationAt: name.
            aSystemDictionary privateRemoveKey: name ifAbsent: [].
            association key: aSymbol].
    aSystemDictionary privateAdd: association.
    self newNameSymbol: aSymbol.
    self class newNameSymbol: aSymbol!  
initialize
	"Define the default error mapping."

	ErrorMap := nil.
	self 
		mapErrorCode: 5
		to: FileSystemAccessDenied.
	self 
		mapErrorCode: 80
		to: FileAlreadyExists.
	self 
		mapErrorCode: 32
		to: FileSharingViolation.
    self 
        mapErrorCode: 19
        to: FileErrorWriteProtected.!
compile: codeString notifying: requestor
        "Compile the Smalltalk method contained in codeString.
         The class to use for resolving variables is the receiver.
         If there are no errors, add the method to the receiver
         messageDictionary and answer the Association with the
         message selector as the key and the compiled method
         as the value.  If there is an error the requestor is sent
         a message by the compiler identifying the error and
         this method answers nil."
    | answer messageBoxClass |
    ( self isLogSourcePossible: codeString )
        ifFalse: [ ^nil ].
    answer := CompilerInterface
        compile: codeString
        in: self
        notifying: requestor
        ifFail: [ ^nil ].
  "Check for method defined from a browser if new method
    for class redefines method in superclass.  If so, ask
    for confirmation before installing method."
    ( requestor isWindow and: [ ( self includesSelector: answer key ) not ] )
        ifTrue: [ "from browser and new method"
            ( self canUnderstand: answer key )
                ifTrue: [ "a superclass defines it"
                    ( messageBoxClass := Smalltalk at: #MessageBox ifAbsent: [ nil ] ) notNil ifTrue: [
                        ( messageBoxClass new
                            title: 'Caution';
                            message: 'You are redefining a superclass method';
                            okCancel;
                            iconInformation;
                            open ) ifFalse: [ ^nil ] ] ] ].
    self addSelector: answer key withMethod: answer value.
    ^answer!
inspectorFields
        "Answer the names of structure fields contained in the receiver."
    ^self class inspectorFields!  
dumpOn: aStream base: radix
        "Dump the receiver's bytes onto aStream using
        the given radix."
    ^self dumpOn: aStream base: radix bytes: 1!
addParens
        "Private - Bracket the selected text in a pair of ()."
    self addLeftBracket: $( rightBracket: $)!  
inspect
        "Open a GraphicBrowser on the receiver."
    GraphicInspector new openOn: self! 
compileExpression
        "Private - compile the text in the receiver's entry field
        and answer whether the compilation was successful."
    reply := CompilerInterface
        evaluate: ( self query: #text )
        in: UndefinedObject
        to: nil
        notifying: self
        ifFail: [ ^false ].
    ^true!
iconId
		"Answer the icon id for this window class."
	^2!   
fixHideShowItem: hidden
        "Private - Change the Hide/Show menu item."
    | menu |
    menu := self classesMenu.
    hidden
        ifTrue: [
            menu changeItem: #hideShow label: '\uShow Subclasses' replaceEscapeCharacters.
            menu enableItem: #hideShow]
        ifFalse: [
            selectedClass subclasses isEmpty
                ifTrue: [
                    menu changeItem: #hideShow label: 'Hide/Show'.
                    menu disableItem: #hideShow]
                ifFalse: [
                    menu changeItem: #hideShow label: '\uHide Subclasses' replaceEscapeCharacters.
                    menu enableItem: #hideShow]]!   
createView
        "Private - create the panes for the receiver window."
    | ratio groupPane pane listLineHeight |
    ratio := 2 / 5.
    listLineHeight := ButtonFont height + 4.
    self
        owner: self;
        label: self label.
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #hierarchy: ;
            when: #needsContents send: #hierarchy: to: self with: pane;
            when: #clicked: send: #hierarchySelected: to: self with: pane;
            when: #doubleClicked: send: #hideShow: to: self with: pane;
            when: #needsMenu send: #menu: to: self with: pane;
            when: #characterTyped: send: #hierarchyCharInput: to: self with: pane;
            dragSource: self class dragDropEnabled;
            when: #dragSourceNeedsObject: send: #classListSetDragObject: to: self;
            when: #dragSourceCut: send: #classListCut: to: self;
            dragTargetForFormats: #( 'compiledMethod' ) operations: #( #move #copy );
            dragTarget: self class dragDropEnabled;
            dragTargetEmphasisItem;
            when: #dragTargetDrop: send: #classListDrop: to: self;
            framingRatio:
                ( Rectangle leftTopUnit extentFromLeftTop: 3/8 @ ratio ) ).
    self addSubpane: ( groupPane := GroupPane new
        framingBlock: [:box| (box leftTop rightAndDown: ((box width * 3//8) @ 0))
            rightBottom: ((box width * 5//8)@(box top down: (2 *
                    listLineHeight)))]).
    groupPane addSubpane:
        ( ( pane := RadioButton new )
            contents: 'instance';
            when: #clicked: send: #instanceButton: to: self with: pane;
            selection: true;
            framingRatio: ((Rectangle leftTopUnit rightAndDown: (1/15 @ 0))
                extentFromLeftTop: 14/15 @ (1/2))).
    groupPane addSubpane:
        ( ( pane := RadioButton new )
            contents: 'class';
            when: #clicked: send: #classButton: to: self with: pane;
            framingRatio: ((Rectangle leftTopUnit rightAndDown: (1/15 @ (1/2)))
                extentFromLeftTop: 14/15 @ (1/2))).
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #instanceVars: ;
            when: #needsContents send: #instanceVars: to: self with: pane;
            when: #clicked: send: #instanceVar: to: self with: pane;
            when: #needsMenu send: #instVarsMenu: to: self with: pane;
            framingBlock: [:box|
                (box leftTop rightAndDown: ((box width * 3/8) truncated @ (2 *
                    listLineHeight)))
                  rightBottom: (box width * 5//8) @ ((box top down: box height * ratio) truncated)]).
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #selectors: ;
            when: #needsContents send: #selectors: to: self with: pane;
            when: #clicked: send: #selector: to: self with: pane;
            when: #needsMenu send: #selectorMenu: to: self with: pane;
            dragSource: self class dragDropEnabled;
            when: #dragSourceNeedsObject: send: #methodListSetDragObject: to: self;
            when: #dragTargetOver: send: #methodListDragTargetOver: to: self;
            when: #dragSourceCut: send: #methodListCut: to: self;
            dragTargetForFormats: #( 'compiledMethod' ) operations: #( #move #copy );
            dragTarget: self class dragDropEnabled;
            dragTargetEmphasisPane;
            when: #dragTargetDrop: send: #methodListDrop: to: self;
            framingRatio:
                ( Rectangle leftTopUnit + ( 5/8 @ 0 )
                    extentFromLeftTop: 3/8 @ ratio ) ).
    self addSubpane:
        ( ( pane := self toolTextPaneClass new )
            setName: #text: ;
            when: #needsContents send: #text: to: self with: pane;
            when: #saved send: #accept: to: self with: pane;
            dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
            dragTarget: self class dragDropEnabled;
            framingRatio: ( Rectangle leftBottomUnit
              extentFromLeftBottom: 1 @ ( 1 - ratio ) ) )!
acceptClass: aString from: aPane
        "Private - Accept aString as an updated
         class specification and compile it.  Notify
         aPane if the compiler detects errors."
    | result |
    SourceManager current
        logEvaluate: aString
        for: [
            result := CompilerInterface
                evaluate: aString
                in: nil class
                to: nil
                notifying: aPane
                ifFail: [ ^true ] ].
    result isClass ifTrue: [selectedClass := result].
    self 
        changed: #instanceVars:;
        changed: #text: .
    ^result isClass not!
classListDrop: dragSession
        "Private - handle drag-drop transfers onto the class list."
    | method className class result |
    method := dragSession objects first format: 'compiledMethod'.
	className := ( ( browsedClasses at: dragSession targetSelection )
		asStream upTo: $. ) trimBlanks.
    class := Smalltalk at: className asSymbol.
	method classField isMetaClass ifTrue: [ class := class class ].
 
    ( method source isNil or: [ ( result := self compile: method sourceString in: class ) isNil ] )
        ifTrue: [ ^MessageBox notify: 'Error' withText: 'Compilation Error' ].
	( className = selectedClass name and: [ instanceSelectedLast = class isMetaClass not ] ) ifTrue: [
        selectedMethod := result key.
		methodSelectedLast := true.
        self
            changed: #selectors: with: #restoreSelected: with: selectedMethod;
            enableMethodsMenu;
            changed: #text: ]!   
references
        "Private - Open a MethodBrowser on all references to
         the selected class."
    | aString global |
    global := selectedClass name.
    aString := ( self paneAt: #text: ) selectedItem.
    ( aString notEmpty and: [ Smalltalk includesKey: aString asSymbol ] )
        ifTrue: [ global := aString ].
    global := Prompter prompt: 'Enter a global name: ' default: global.
    global isNil
        ifTrue: [ ^nil ]
        ifFalse: [ global := global asSymbol ].
    ( Smalltalk includesKey: global ) ifFalse: [
        MessageBox notify: 'Error' withText: 'Undefined global: ', global. ^nil ].
    Smalltalk referencesTo: global asSymbol! 
hierarchySelected: hierarchyPane
        "Private - Display the selectors for the
         selected class in the selector list pane."
    | string aClass hidden |
    string := hierarchyPane selectedItem.
    hidden := false.
    string last == $.
        ifTrue: [
            hidden := true.
            string := string copyFrom: 1
                to: string size - 3].
    aClass := Smalltalk
        at: string trimBlanks asSymbol
        ifAbsent: [
            MessageBox message: 'non-existent class'.
            self update.
            ^self].
    methodSelectedLast := false.
    selectedMethod := nil.
    selectedInstVar := nil.
    selectedClass := aClass.
    self enableClassesMenu.
    self fixHideShowItem: hidden.
    self disableMethodsMenu.
    self
        changed: #selectors: ;
        changed: #instanceVars: ;
        changed: #text:!  
checkInstVarMenu
        "Private - Check the appropriate item in the instance
         variables menu."
    | menu |
    menu := self variablesMenu.
    menu
        uncheckItem: #assigned;
        uncheckItem: #used;
        uncheckItem: #bothInstVars.
    assigned & used ifTrue: [ ^menu checkItem: #bothInstVars ].
    assigned ifTrue: [ ^menu checkItem: #assigned ].
    used ifTrue: [ ^menu checkItem: #used ]!   
methodListDragTargetOver: dragSession
        "Private - if dragging a method to its same class, disable drop."
    | method |
    method := ( dragSession objects first ) format: 'compiledMethod' ifAbsent: [ ^nil ].
    ( method classField = selectedClass ) ifTrue: [ ^nil ].
    ^( self paneAt: #selectors: ) dragTargetOverDefault: dragSession!
used
        "Private - The Used menu item was selected."
    used := true.
    assigned := false.
    self checkInstVarMenu.
    self changed: #selectors:! 
hierarchyCharInput: aPane
        "Private - A character is typed, search for the matching
         class."
    | char |
    char := aPane characterTyped asUpperCase.
    [  CurrentEvents add: ( Message new
            receiver: self
            selector: #hierarchySearchFor:in:
            arguments: ( Array with: char with: aPane ) ) ] evaluateWithoutInterrupts.
    ^1!   
accept: textPane
        "Private - Accept the contents of textPane
         as an updated method
         or class specification and compile it."
    | result aClass aString |
    aString := textPane contents.
    methodSelectedLast
        ifFalse: [
            ^textPane modified: (
                self acceptClass: aString from: textPane)].
    aClass := instanceSelectedLast
        ifTrue: [selectedClass]
        ifFalse: [selectedClass class].
    result := self compile: aString
        notifying: textPane
        in: aClass.
    result isNil
        ifTrue: [ textPane modified: true ]
        ifFalse: [
            result key == selectedMethod
                ifFalse: [
                    selectedMethod := result key.
                    self
                        changed: #selectors:
                            with: #restoreSelected:
                            with: selectedMethod;
                        enableMethodsMenu].
            textPane modified: false]
!   
hierarchySearchFor: aChar from: index in: aPane
        "Private - Search for aChar from index (not including)."
    | class |
    index isNil ifTrue: [^nil].
    (index max: 1) to: browsedClasses size do: [:i |
        class := (browsedClasses at: i) trimBlanks.
        ((class at: 1) = aChar and: [i ~= index])
            ifTrue: [
                aPane selection: i.
                self hierarchySelected: aPane.
                ^self ]
            ifFalse: [
                (class last = $.)
                    ifTrue: [
                        (self hierarchySearch: aChar
                            class: (Smalltalk at: (class copyFrom: 1
                                to: class size - 3) asSymbol)
                            index: i
                            in: aPane)
                                notNil ifTrue: [
                                    self hierarchySelected: aPane.
                                    ^self]]]].
    ^nil
!
instanceVars: instVarPane
        "Private - Set the list of instance variables."
    |c|
    selectedClass isNil
        ifTrue: [^instVarPane contents: Array new].
    instanceSelectedLast
        ifTrue: [c := selectedClass]
        ifFalse: [c := selectedClass class].
     self checkMenuForInstanceVariable.
     instVarPane contents: c allInstAndClassVarNamesGrouped.!   
dragDropTargetPanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag target."
    ^Array with: #hierarchy: with: #selectors: with: #text:!   
addSubClass
        "Private - Add a subclass to the selected
         class.  If a class is selected, prompt the
         user for a new class name and add it as a
         subclass to the selected class."
    | newSubclassDialog newName subclassType |
    self textModified ifTrue: [^self].
    selectedClass isNil ifTrue: [selectedClass := Object].
    newSubclassDialog := NewSubclassDialog open: selectedClass.
    newName := newSubclassDialog subclassName.
    (newName isNil or: [newName isEmpty])
        ifTrue: [^nil].
    newName := newName asSymbol.
    (Smalltalk includesKey: newName)
        ifTrue: [^self error: newName, ' already exists'].
    subclassType := newSubclassDialog isFixed
        ifTrue: [#pointer]
        ifFalse: [newSubclassDialog isPointer
            ifTrue: [#indexed]
            ifFalse: [#byte]].
    (subclassType == #pointer and: [selectedClass isVariable])
        ifTrue: [
            (MessageBox confirm: 'Indexed pointer subclass assumed')
                ifFalse: [^self]].
    subclassType == #pointer
        ifTrue: [
            ((selectedClass subclass: newName
                instanceVariableNames: ''
                classVariableNames: ''
                poolDictionaries: '')
                    isClass)
                        ifFalse: [^self]].
    subclassType == #indexed
        ifTrue: [
            ((selectedClass variableSubclass: newName
                instanceVariableNames: ''
                classVariableNames: ''
                poolDictionaries: '')
                    isClass)
                        ifFalse: [^self]].
    subclassType == #byte
        ifTrue: [
            ((selectedClass variableByteSubclass: newName
                classVariableNames: ''
                poolDictionaries: '')
                    isClass)
                        ifFalse: [^self]].
    subclassType isNil ifTrue: [^self].
    selectedClass := Smalltalk at: newName asSymbol.
    CursorManager execute changeFor: [
	    selectedMethod := nil.
	    methodSelectedLast := false.
	    self update: originalClasses.
	    self
	        changed: #hierarchy:
	        with: #restoreSelected:
	        with: ((String new:
	            (Smalltalk at: newName asSymbol)
	                allSuperclasses size * 2)
	                    atAllPut: $ ), newName.
	    self
	        changed: #selectors: ;
	        changed: #instanceVars: ;
	        changed: #text: ]
! 
update: aCollection
        "Private - Recompute the list of
        browsed classes from aCollection."
    originalClasses := aCollection.
    browsedClasses := OrderedCollection new: 120.
    self addClasses: aCollection at: 0!
instanceButton: aButton
        "Private - Change the state of the browser
         so that instance messages are selected."
    self textModified ifTrue: [
        self changed: 'instance' with: instanceSelectedLast.
        self changed: 'class' with: instanceSelectedLast not.
        ^self].
    instanceSelectedLast := true.
    methodSelectedLast := false.
    selectedInstVar := nil.
    self disableMethodsMenu.
    self
        changed: #instanceVars: ;
        changed: #selectors: ;
        changed: #text:!  
selector: selectorPane
        "Private - Display the selected
         method in the text pane."
    selectedMethod := selectorPane isNil
        ifTrue: [nil]
        ifFalse: [selectorPane selectedItem].
    methodSelectedLast := true.
    self changed: #text:.
    self enableMethodsMenu.
    ( ( ( selectedInstVar notNil ) and: [ selectedMethod notNil ] ) and: [ assigned | used ] ) ifTrue: [
        self changed: #text: with: #searchFor: with: selectedInstVar ]!   
findClass
        "Private - Prompt for a class to search for, and position at
         that point in the hierarchy."
    | className class supers blanks |
    self textModified ifTrue: [^self].
    className := ( self paneAt: #text: ) selectedItem.
    ( Smalltalk at: className asSymbol ifAbsent: [ nil ] ) isClass
        ifFalse: [ className := '' ].
    className := self findClass: className.
    (className isNil or: [className isEmpty])
        ifTrue: [ ^ self ].
    className := className asSymbol.
    class := Smalltalk at: className.
    CursorManager execute changeFor: [
        supers := (Array with: class), class allSuperclasses.
        blanks := 0.
        1 to: supers size do: [ :i |
            (originalClasses includes: (supers at: i))
               ifTrue: [ blanks := i ]].
        blanks = 0 ifTrue: [
            ^MessageBox message: 'Class "', className,
                            '" not found in this browser.' ].
        supers do: [ :cl |
            hiddenClasses remove: cl ifAbsent: []].
        self update: originalClasses.
        methodSelectedLast := false.
        selectedMethod := nil.
        selectedInstVar := nil.
        selectedClass := class.
        self changed: #hierarchy:
            with: #restoreSelected:
            with: (((String new: ((blanks - 1 max: 0) * 2)) atAllPut: $ ),
                class name).
        self enableClassesMenu.
        self disableMethodsMenu.
        self
            changed: #instanceVars: ;
            changed: #selectors: ;
            changed: #text: ]!   
findClass: defaultName
		"Private - prompt for the name of an existing class, using defaultName
		as the initial name value; answer the name of the matching class, or
		nil if no match found."
    | name pattern matches pt |
    name := Prompter
        title: 'Find Class'
        prompt: 'Enter a class name:'
        default: defaultName.
    name isNil ifTrue: [ ^nil ].

	"exact match"
    ( ( Smalltalk includesKey: name asSymbol ) and: [ ( Smalltalk at: name asSymbol ) isClass ] )
        ifTrue: [ ^name ].

	"matches beginning of a class"
    pattern := Pattern new: name asUpperCase.
    matches := OrderedCollection new.
    Object allClasses do: [ :class |
		pt := pattern match: class name index: 1 each: [ :e | e asUpperCase ].
		( pt notNil and: [ pt x = 1 ] )
			ifTrue: [ matches add: class name ] ].
    matches size > 1 ifTrue: [
        matches := matches reject: [ :s | s size > name size ] ].

	"if no match found, or too many matches found, forget it"
    matches size ~= 1 ifTrue: [ MessageBox message: 'Class not found'. ^nil ].
	^matches first!
classListCut: dragSession
        "Private - cut the dragged class on a move operation."
    | class |
    class := self selectedClass.
    self confirmDeletes ifTrue: [
        ( MessageBox confirm: 'Delete ', class name, '?' )
            ifFalse: [ ^self ] ].
    class removeFromSystem.
    self update!   
removeSelector
        "Private - Remove the selected method."
    | theClass |
    methodSelectedLast ifFalse: [ ^nil ].
    selectedMethod isNil ifTrue: [ ^nil ].
    theClass := instanceSelectedLast
        ifTrue: [ selectedClass ]
        ifFalse: [ selectedClass class ].

    SourceManager current
        logEvaluate: theClass name, ' removeSelector: #', selectedMethod
        for: [ theClass removeSelector: selectedMethod ].

    methodSelectedLast := false.
    selectedMethod := nil.
    self disableMethodsMenu.
    self
        changed: #selectors: with: #restore;
        changed: #text:
!  
selectors: selectorPane
        "Private - Set the sorted list of method
         selectors for the selected class and
         dictionary type (class or instance)."
    | methods theClass|

    selectedClass isNil
        ifTrue: [^selectorPane contents: Array new].

    theClass := selectedClass.
    instanceSelectedLast
        ifFalse: [theClass := selectedClass class].

    selectedInstVar isNil
        ifTrue: [ ^selectorPane contents: theClass selectors asSortedCollection asArray ].

    ( theClass classPool keys includes: selectedInstVar )
        ifTrue: [  "selected variable was a class variable"
            self checkMenuForClassVariable.
            methods := theClass allMethodsUsingClassVar: selectedInstVar.
            ^selectorPane contents: ( methods collect: [ :m | m selector ] ) asSortedCollection ].

    "selected variable was a instance variable"
    self checkMenuForInstanceVariable.
    methods := assigned
        ifTrue: [
            used
                ifTrue: [theClass allMethodsReferencingInstVar: selectedInstVar]
                ifFalse: [theClass allMethodsAssigningInstVar: selectedInstVar]]
        ifFalse: [
            used
                ifTrue: [theClass allMethodsUsingInstVar: selectedInstVar]
                ifFalse: [theClass methodDictionary asOrderedCollection ]].
    ^selectorPane contents: (methods collect: [:m | m selector]) asSortedCollection.! 
methodListDrop: dragSession
        "Private - handle drag-drop transfers onto the method list."
    | class method result |
    method := dragSession objects first format: 'compiledMethod'.
    class := selectedClass.
    method classField isMetaClass ifTrue: [ class := class class ].

    ( method source isNil or: [ ( result := self compile: method sourceString in: class ) isNil ] )
        ifTrue: [ ^MessageBox notify: 'Error' withText: 'Compilation Error' ].
    instanceSelectedLast = class isMetaClass not ifTrue: [
        selectedMethod := result key.
        methodSelectedLast := true.
        self
            changed: #selectors: with: #restoreSelected: with: selectedMethod;
            enableMethodsMenu;
            changed: #text: ]
!
selectedMethodSelector
		"Private - answer the selector for the selected method."
	^selectedMethod! 
label
        "Private - answer the label of the window."
    ^'Class Hierarchy Browser'!   
selectedClass
		"Private - answer the selected class."
	^selectedClass! 
enableClassesMenu
        "Private - Enable the classes menu."
    self classesMenu
        enableItem: #removeSubClass;
        enableItem: #references;
        enableItem: #fileOutClass;
        enableItem: #fileOutClassWithSubclasses;
        enableItem: #hideShow;
        enableItem: #browse;
        enableItem: #addSubClass!  
bothInstVars
        "Private - The user chose the Both menu item."
    assigned := true.
    used := true.
    self checkInstVarMenu.
    self changed: #selectors:!
checkMenuForClassVariable
        "Private - Check the appropriate item in the instance
         variables menu when a class variable is selected."
    | menu |
    menu := self variablesMenu.
    menu
        uncheckItem: #assigned;
        uncheckItem: #used;
        disableItem: #assigned;
        disableItem: #used;
        checkItem: #bothInstVars.!
initWindowSize
        "Private - Answer the initial
         window extent."
    ^( SysFontWidth * 80 ) @ ( SysFontHeight * 25 )! 
instanceVar: instVarPane
        "Private - An instance variable was selected."
    selectedInstVar := instVarPane selectedItem.
    methodSelectedLast := false.
    self disableMethodsMenu.
    self changed: #selectors:.
    self changed: #text:! 
newMethod
        "Private - Display the text for a new
         method template in the text pane."
    selectedClass isNil
        ifTrue: [self error: 'no class selected'].
    self textModified
        ifFalse: [
            self
                changed: #selectors: ;
                selector: nil;
                disableMethodsMenu.
            ( self paneAt: #text: ) selectAll; setFocus ]!  
setClass: aClass
        "Private - set the currently selected class to aClass."
    | supers blanks |
    self textModified ifTrue: [^self].
    CursorManager execute changeFor: [
        supers := (Array with: aClass), aClass allSuperclasses.
        blanks := 0.
        1 to: supers size do: [ :i |
            (originalClasses includes: (supers at: i))
               ifTrue: [ blanks := i ]].
        blanks = 0 ifTrue: [
            ^MessageBox message: 'Class "', aClass name,
                            '" not found in this browser.' ].
        supers do: [ :cl |
            hiddenClasses remove: cl ifAbsent: []].
        self update: originalClasses.
        methodSelectedLast := false.
        selectedMethod := nil.
        selectedInstVar := nil.
        selectedClass := aClass.
        self changed: #hierarchy:
            with: #restoreSelected:
            with: (((String new: ((blanks - 1 max: 0) * 2)) atAllPut: $ ),
                aClass name).
        self enableClassesMenu.
        self disableMethodsMenu.
        self
            changed: #instanceVars: ;
            changed: #selectors: ;
            changed: #text: ]!
menu: hierarchyPane
        "Private - Set the hierarchy pane menu."
	| menu |
	menu := Menu new
		owner: self;
		title: '\uClass' replaceEscapeCharacters;
		appendItem: '\uNew...' replaceEscapeCharacters selector: #addSubClass;
		appendItem: '\uDelete' replaceEscapeCharacters selector: #removeSubClass;
		appendSeparator;
		appendItem: '\uUpdate' replaceEscapeCharacters selector: #update;
		appendItem: '\uHide/Show' replaceEscapeCharacters selector: #hideShow;
		appendItem: '\uBrowse' replaceEscapeCharacters selector: #browse;
		appendItem: 'R\ueferences...' replaceEscapeCharacters selector: #references;
		appendSeparator;
		appendItem: '\uFind...\tShift+Ctrl+F' replaceEscapeCharacters
			selector: #findClass accelKey: $F accelBits: AfControl | AfShift;
		appendSeparator;
		appendItem: 'File O\uut...' replaceEscapeCharacters selector: #fileOutClass;
		appendItem: 'File Out \uAll...' replaceEscapeCharacters selector: #fileOutClassWithSubclasses;
		yourself.
    hierarchyPane setMenu: menu!   
update
        "Private - Recompute the browsed
         classes and display them."
    self textModified ifTrue: [^self].
    CursorManager execute changeFor: [
        selectedMethod := nil.
        methodSelectedLast := false.
        self update: originalClasses.
        self changed: #hierarchy:.
        self disableClassesMenu.
        self disableMethodsMenu.
        self
            changed: #selectors: ;
            changed: #text: ;
            changed: #instanceVars: ].

    selectedClass isNil
        ifTrue: [^self].
    1 to: browsedClasses size do: [ :i |
        ( selectedClass name = (((browsedClasses at: i) trimBlanks) copyWithout: $.) )
            ifTrue: [
                (self paneAt: #hierarchy:) selection: i.
                self hierarchySelected: (self paneAt: #hierarchy:).
                ^self ] ]!  
openOn: aCollection
        "Create a class hierarchy browser window giving access
         to the classes in aCollection and their subclasses."
    hiddenClasses := Set new.
    ( aCollection includes: Object )
        ifTrue: [
            aCollection do: [ :class |
                class subclasses do: [ :each |
                    each subclasses isEmpty
                        ifFalse: [ hiddenClasses add: each ] ] ] ]
        ifFalse: [
            aCollection do: [ :class |
                class subclasses isEmpty
                    ifFalse: [ hiddenClasses add: class ] ] ].
    self update: aCollection.
    instanceSelectedLast := true.
    methodSelectedLast := false.
    assigned := used := true.

    self
        createView;
        addHelpManager;
        openWindow;
        disableClassesMenu;
        disableMethodsMenu;
        checkInstVarMenu!  
classButton: aButton
        "Private - Change the state of the browser
         so that class messages are selected."
    self textModified ifTrue: [
        self changed: 'class' with: instanceSelectedLast not.
        self changed: 'instance' with: instanceSelectedLast.
        ^self].
    instanceSelectedLast := methodSelectedLast := false.
    selectedInstVar := nil.
    self disableMethodsMenu.
    self
        changed: #instanceVars: ;
        changed: #selectors: ;
        changed: #text:!   
browse
        "Private - Open a ClassBrowser
         on the selected class."
    selectedClass isNil
        ifFalse: [selectedClass edit]! 
selectorMenu: selectorPane
        "Private - Set the selector pane menu."
    selectorPane setMenu: ( ( Menu
        labels: '\uNew\n\uDelete\n\uSenders\n\uImplementors\n\uLocal Senders\nLocal Im\uplementors\n\uMessages\nFile O\uut...' replaceEscapeCharacters
        lines: #( 2 7 )
        selectors: #( #newMethod #removeSelector #senders #implementors #localSenders #localImplementors #messages #fileOutMethod ) )
            title: '\uMethod' replaceEscapeCharacters;
            owner: self;
            yourself )!
dragDropSourcePanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag source."
    ^Array with: #hierarchy: with: #selectors:!
instVarsMenu: instVarPane
        "Private - Set the menu for the instance variables pane."
    instVarPane setMenu: ( ( Menu
        labels: '\uAssigned\n\uUsed\n\uBoth' replaceEscapeCharacters
        lines: #( )
        selectors: #( #assigned #used #bothInstVars ) )
            title: '\uVariable' replaceEscapeCharacters ;
            owner: self;
            yourself )! 
classListSetDragObject: dragSession
        "Private - set the class to drag."
    | dragDropObject class stream |
    class := self selectedClass.
    class isNil ifTrue: [ ^nil ].
    stream := String new asStream.
    class fileOutOn: stream.
    stream nextChunkPut: ''.
    dragDropObject := dragSession objectClass new
        object: class;
        format: 'class' data: class;
        string: stream contents;
        yourself.
    dragSession objects: ( Array with: dragDropObject )! 
hideShow: aPane
        "Private - Change the hide/show state of the hierarchy pane."
    self hideShow!
assigned
        "Private - The user chose the Assigned menu item."
    assigned := true.
    used := false.
    self checkInstVarMenu.
    self changed: #selectors:!   
disableMethodsMenu
        "Private - Disable the methods menu."
	super disableMethodsMenu.
    selectedClass notNil
        ifTrue: [ self methodsMenu enableItem: #newMethod ]! 
checkMenuForInstanceVariable
        "Private - Check the appropriate item in the instance
         variables menu when an instance variable is selected."
    | menu |
    menu := self variablesMenu.
    menu
        enableItem: #assigned;
        enableItem: #used.
    self checkInstVarMenu.!
hierarchySearchFor: aChar in: aPane
        "Private - Search aChar from the selected item in aPane."
    (self hierarchySearchFor: aChar
        from: aPane selectedIndex
        in: aPane) isNil ifTrue: [
            (self hierarchySearchFor: aChar from: 0 in: aPane)]!  
methodListCut: dragSession
        "Private - cut the dragged method on a move operation."
    | method |
    method := self selectedMethod.
    self confirmDeletes ifTrue: [
        ( MessageBox confirm: 'Delete ', method selector printString, '?' )
            ifFalse: [ ^self ] ].
    method classField removeSelector: method selector.
    self changed: #selectors: !   
instance
        "Private - Change the state of the browser
         so that instance messages are selected."
    instanceSelectedLast := true.
    methodSelectedLast := false.
    self
        changed: #selectors: ;
        changed: #text:!  
hideShow
        "Private - Change the hide/show
         status of the selected class."
    selectedClass isNil
        ifTrue: [^nil].
    CursorManager execute changeFor: [
        (hiddenClasses includes: selectedClass)
            ifTrue: [
                hiddenClasses remove: selectedClass.
                self fixHideShowItem: false]
            ifFalse: [
                selectedClass subclasses isEmpty
                    ifFalse: [
                        hiddenClasses add: selectedClass.
                        self fixHideShowItem: true]].
        methodSelectedLast := false.
        selectedMethod := nil.
        self
            update: originalClasses;
            changed: #hierarchy:
                with: #restoreSelected ]!   
addClasses: aCollection at: anInteger
        "Private - Add aCollection of classes to
        browsedClasses, each preceded by anInteger
        number of spaces.  anInteger indicates the
        level in the hierarchy."
   | indent |
    (aCollection asSortedCollection: Class sortBlock)
        do: [ :class |
            (class symbol first = $ )
                ifFalse: [
                    indent := ( String new: anInteger * 2 ) atAllPut: $ .
                    class symbol isDoubleByteString
                        ifTrue: [ indent := DoubleByteString fromString: indent ].
                    browsedClasses add:
                        indent, class symbol.
                    (hiddenClasses includes: class)
                        ifTrue: [
                            browsedClasses add:
                                browsedClasses
                                    removeLast, '...']
                        ifFalse: [
                            self
                                addClasses: class subclasses
                                at: anInteger + 1]]]!
removeSubClass
        "Private - Delete the selected class."
    | classAssoc methods |
    selectedClass isNil
        ifTrue: [^nil].
    (MessageBox confirm: 'Delete Class "', selectedClass name, '"?')
        ifFalse: [^nil].
    CursorManager execute changeFor: [
        classAssoc := Smalltalk associationAt: selectedClass name asSymbol.
        methods := OrderedCollection new.
        Smalltalk rootClasses do: [ :aClass|
            methods := methods, ( aClass sendersOf: classAssoc ) ] ].
    (methods size > 0)
        ifTrue: [
            MethodBrowser new
                label: 'Senders of ', classAssoc printString;
                literal: classAssoc;
                openOn: methods.
            (MessageBox confirm:
                    'There are methods which reference class "',
                    selectedClass name,
                    '".  Do you still wish to delete it?')
                ifFalse: [^nil]].
    CursorManager execute changeFor: [
        selectedClass removeFromSystem.
        selectedMethod := nil.
        methodSelectedLast := false.
        self update: originalClasses.
        self changed: #hierarchy:
            with: #restore.
        selectedClass := nil.
        self
            changed: #selectors: ;
            changed: #instanceVars: ;
            changed: #text: ]
!
hierarchySearch: aChar class: class index: index in: aPane
        "Private - Search for aChar matching subclasses of
         hidden class in aPane."
    | i |
    i := index.
    class allSubclasses do: [:each |
        i := i + 1.
        (each name at: 1) = aChar
            ifTrue: [
                selectedClass := class.
                self hideShow.
                aPane selection: i.
                ^self]].
    ^nil!  
disableClassesMenu
        "Private - Disable the classes menu."
    self classesMenu
        disableItem: #removeSubClass;
        disableItem: #references;
        disableItem: #fileOutClass;
        disableItem: #fileOutClassWithSubclasses;
        disableItem: #hideShow;
        disableItem: #browse;
        disableItem: #addSubClass! 
text: textPane
        "Private - Set the source text for
         the selected method or class definition
         for the selected class."
    | answer aClass |
    selectedClass isNil
        ifTrue: [ ^textPane contents: String new ].
    aClass := instanceSelectedLast
        ifTrue: [ selectedClass ]
        ifFalse: [ selectedClass class ].
    methodSelectedLast ifTrue: [
        selectedMethod isNil
            ifTrue: [ ^textPane contents: self template ]
            ifFalse: [ ^textPane contents: ( aClass sourceCodeAt: selectedMethod ) ] ].
    answer := WriteStream on: ( String new: 100 ).
    aClass fileOutOn: answer.
    textPane contents: answer contents!
variablesMenu
        "Private - answer the Variables menu."
	^self menuTitled: 'Variable'! 
selectedMethod
		"Private - answer the selected method."
	( selectedClass isNil or: [ selectedMethod isNil ] ) ifTrue: [ ^nil ].
	^( instanceSelectedLast ifTrue: [ selectedClass ] ifFalse: [ selectedClass class ] )
		compiledMethodAt: selectedMethod!
hierarchy
        "Private - Answer the indented list of
         classes, an OrderedCollection of strings."
    ^browsedClasses!  
hierarchy: hierarchyPane
        "Private - Set the indented list of
         classes, an OrderedCollection of strings."
    hierarchyPane contents: browsedClasses!   
open
        "Open the receiver on all root classes (subclasses of nil)."
    self openOn: Smalltalk rootClasses!   
initializeDefaultColors
        "Private - initialize a table entries in the default system palette."
    defaultColors := IdentityDictionary new
        at: #black put: ( self red: 0 green: 0 blue: 0 );
        at: #blue put: ( self red: 0 green: 0 blue: self maximumComponentValue );
        at: #brown put: ( self red: self halfComponentValue green: self halfComponentValue blue: 0 );
        at: #cyan put: ( self red: 0 green: self maximumComponentValue blue: self maximumComponentValue );
        at: #darkBlue put: ( self red: 0 green: 0 blue: self halfComponentValue );
        at: #darkCyan put: ( self red: 0 green: self halfComponentValue blue: self halfComponentValue );
        at: #darkGray put: ( self red: self halfComponentValue green: self halfComponentValue blue: self halfComponentValue );
        at: #darkGreen put: ( self red: 0 green: self halfComponentValue blue: 0 );
        at: #darkPink put: ( self red: self halfComponentValue green: 0 blue: self halfComponentValue );
        at: #darkRed put: ( self red: self halfComponentValue green: 0 blue: 0 );
        at: #gray put: ( self red: 204 green: 204 blue: 204 );
        at: #green put: ( self red: 0 green: self maximumComponentValue blue: 0 );
        at: #pink put: ( self red: self maximumComponentValue green: 0 blue: self maximumComponentValue );
        at: #red put: ( self red: self maximumComponentValue green: 0 blue: 0 );
        at: #white put: ( self red: self maximumComponentValue green: self maximumComponentValue blue: self maximumComponentValue );
        at: #yellow put: ( self red: self maximumComponentValue green: self maximumComponentValue blue: 0 );
        yourself! 
compilerError: aString at: anInteger in: codeString for: aClass
        "Private - pass the error onto the current expression evaluator."
    ^self expressionEvaluator
        compilerError: aString at: anInteger in: codeString for: aClass!   
purgeUnusedSymbols
        "Purge unused symbols from symbol table."
    | newSymbolTable |
    [   newSymbolTable := SymbolSet new: SymbolTable size.
        SymbolTable do: [ :sym |
            sym isInLibrary ifTrue: [ newSymbolTable add: sym ] ].
        SymbolTable := nil.
        ( Array with: Symbol with: DoubleByteSymbol ) do: [ : aClass |
            aClass allInstances do: [ :aSymbol |
                newSymbolTable add: aSymbol ] ].
        SymbolTable := newSymbolTable ] evaluateWithoutInterrupts.! 
allMethodsUsingInstVar: aString
        "Answer a collection of all the methods in the receiver that
        use the instance variable named aString."
    | answer index allInstances |
    answer := Set new.
    allInstances := self allInstVarNames.
    index := allInstances indexOf: aString ifAbsent: [ ^answer ].

    CursorManager execute changeFor: [
        self methodDictionary do:
            [ :method |
            ( method includesUseFor: index )
                    ifTrue: [ answer add: method ]
            ]
        ].
    ^answer.!   
helpDirectoryName
        "Answer the path name of the directory that contains
        help files for the development environment."
    ^Disk fullDirName , 'help'!
helpTopics: arrayOfCollections
		"Private - set the array of help topic lists (collections)."
    helpTopics := arrayOfCollections! 
fullHelpPathName: aFileName
        "Answer a String which is the full path name for
        aFileName residing in the standard help directory."
    ^self helpDirectoryName , '\', aFileName! 
helpFileNames
		"Answer the array of help file names.  The first is always the general
        help file, the ones that follow are for EOC help, and may be added to
        when additional class libraries are installed (if such a help file exists)."
    ^helpFileNames! 
addHelpFileName: aString
		"Add a help file to the installed list."
    self helpFileNames: ( self helpFileNames copyWith: aString )!   
helpFileNames: arrayOfStrings
		"Set the array of help file names."
    helpFileNames := arrayOfStrings!
helpTopics
		"Private - answer the list of help topic lists (collections)."
    ^helpTopics!
resourceFileName: aString
        "Set the filename of the module (DLL or EXE) containing
        host resources for the development environment to aString."
    resourceFileName := aString! 
initialize
        "Private - Initialize the receiver."
    self
        textWindowClass: #TextWindow;
        textPaneClass: #TextPaneControl;
        windowPolicyClass: #SmalltalkWindowPolicy;
        resourceFileName: 'vres', SmalltalkLibrary versionAndPlatformExtension!  
diskBrowserClass
        "Answer the disk browser class, binding its library first."
    ^self getGlobalNamed: #DiskBrowser libraryName: self diskBrowserLibraryName!   
addHelpTopics: aCollection
        "Add aCollection (a list of help topics contained in the corresponding help file)
        to the installed list."
    self helpTopics: ( self helpTopics copyWith: aCollection )!   
textWindowClass
        "Answer the default TextWindow class."
    ^textWindowClass isClass
        ifTrue: [ textWindowClass ]
        ifFalse: [ Smalltalk at: textWindowClass asSymbol ]!  
textWindowClass: aClassOrName
        "Set the default TextWindow class. aClassOrName may
		be either a class or the name (symbol) of a class."
    textWindowClass := aClassOrName!   
resourceFileName
        "Answer the filename of the module (DLL or EXE) containing
        host resources for the development environment."
    ^resourceFileName!
getGlobalNamed: globalName libraryName: libraryName
        "Private - retrieve the class or global variable named globalName (a Symbol).
        If it is not currently loaded, first bind its library, named libraryName.
        If it is loaded, and it is located in a library, bind its library again to
        increment its reference count; otherwise (loaded, but not located in a library),
        answer the global without attempting to bind the library."
    ( ( Smalltalk includesKey: globalName ) and: [ ( Smalltalk at: globalName ) smalltalkLibraryOrdinal = 0 ] )
        ifTrue: [ ^Smalltalk at: globalName ].
    SmalltalkLibraryBinder bindTo: libraryName.
    ^Smalltalk at: globalName! 
serviceManagerLibraryName
        "Answer the name of the library that contains the Service Manager."
    ^'vsrv', SmalltalkLibrary versionExtension, SmalltalkLibrary fileExtension!   
serviceManagerWindowClass
        "Answer the ServiceManagerWindow class, binding its library first."
    ^self getGlobalNamed: #ServiceManagerWindow libraryName: self serviceManagerLibraryName!  
windowPolicyClass
        "Answer the WindowPolicy subclass that should
        be used for development tools."
    ^windowPolicyClass isClass
        ifTrue: [ windowPolicyClass ]
        ifFalse: [
            Smalltalk
                at: windowPolicyClass asSymbol
                ifAbsent: [ StandardWindowPolicy ] ]!
windowPolicyClass: aWindowPolicySubclass
        "Set the WindowPolicy subclass that should be
        used for development tools to aWindowPolicySubclass;
        aWindowPolicySubclass may be either a class or the name
        (symbol) of a class."
    windowPolicyClass := aWindowPolicySubclass!
diskBrowserLibraryName
        "Answer the name of the library that contains the disk browser."
    ^'vdisk', SmalltalkLibrary versionExtension, SmalltalkLibrary fileExtension!
textPaneClass
        "Answer the TextPane class that should be used
        for development tools."
    ^textPaneClass isClass
        ifTrue: [ textPaneClass ]
        ifFalse: [ Smalltalk at: textPaneClass asSymbol ]! 
textPaneClass: aClassOrName
        "Set the TextPane class that should be used for
        development tools to aClassOrName; aClassOrName
        may be either a class or the name (symbol) of a class."
    textPaneClass := aClassOrName!
doubleClickBrackets
        "Private - check to see if the last double-click was intended
         to match brackets; if so, perform the matching
         (highlight text) and answer true, otherwise answer false"
    | brackets |
    brackets := LeftBrackets, RightBrackets.
    ( selection x > 0 and: [ ( brackets includes: ( self charAt: selection y ) ) ] )
        ifTrue: [
            self selectIndexFrom: selection x to: selection x.
            self matchBracketChars.
            ^true ].
    ( ( self charAt: selection y ) notNil and: [ ( brackets includes: ( self charAt: selection y + 1 ) ) ] )
        ifTrue: [
            self selectIndexFrom: selection x - 1 to: selection y - 1.
            self matchBracketChars.
            ^true ].
    ^false!  
handleOldErrorResult: result in: aClass for: requestor return: exceptionBlock
	"Private-Process a compilation result in to a traditional interface error result"

	|error |
	error := result error.
	requestor
		compilerError: error errorMessage
		at: error sourcePosition
		in: error sourceCode
		for: aClass.
	^exceptionBlock value! 
asStream
	"Answer the receiver as a Stream."

	^self!  
nextChunkPut: aString
        "Output aString terminated with '!!', doubling
         embedded !!'s and replacing groups of leading
         blanks with tabs.  Destination is receiver
         stream.  The methods in sources.sml and
         change.log are in chunk format."
    aString isEmpty
        ifTrue: [
            self space.
            SourceManager current
                alignSourceAt: SourceAlignFactor
                for: self
                startingAt: self size]
        ifFalse:[
            self lineDelimiter == Cr
                ifTrue: [
                    SourceManager current
                        alignSourceAt: SourceAlignFactor
                        for: self
                        startingAt: self size + 2]
                ifFalse: [
                    SourceManager current
                        alignSourceAt: SourceAlignFactor
                        for: self
                        startingAt: self size + 1].
            self cr].
    aString do: [ :character |
        self nextPut: character.
        character == $!!
            ifTrue: [self nextPut: $!!]].
    self nextPut: $!!.
    ^aString!
inspect
        "Open a GraphicBrowser on the receiver."
    GraphicInspector new openOn: self! 
sourceLibrary
    "Answer the library containing the source code."

    ^self smalltalkLibrary!
setSource
    "Private - Set up the source code info."

    ^self metaInfo
        at: 'sourceReference'
        put: ( LibrarySourceReference library: self )!  
variableByteSubclass: className
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a
        variable byte subclass of the receiver with the specified
        class variables and pool dictionaries."
    ^self
        variableByteSubclass: className
        instanceVariableNames: String new
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries!
referencesToString: aString
        "Open a MethodBrowser on all methods whose source code
        includes the substring aString."
    SourceManager current referencesToString: aString! 
referencesTo: globalSymbol in: aClass
        "Open a MethodBrowser on all methods in aClass or a subclass of aClass
        referencing the global named globalSymbol."
    SourceManager current referencesTo: globalSymbol in: aClass!  
comment: aString
	"Record the argument as the class comment of the reciever"

	DefinitionInstaller current setClassComment: aString forClass: self!
setEvaluate: aBoolean
        "Private - specify whether a compilation for the receiver
        is evaluating an expression or compiling a method."
    self propertyAt: #evaluate put: aBoolean!  
addSquareBrackets
        "Private - Bracket the selected text in a pair of []."
    self addLeftBracket: $[ rightBracket: $]!  
initialize
        "Private - initialize a Dictionary mapping host-specific results
        to result symbols."
    ResultSymbols := Dictionary new
        at: Idok put: #ok;
        at: Idcancel put: #cancel;
        at: Idyes put: #yes;
        at: Idno put: #no;
        at: Idabort put: #abort;
        at: Idretry put: #retry;
        at: Idignore put: #ignore;
        yourself!   
compilerError: aString at: anInteger in: codeString for: aClass
        "Private - pass the error onto the current expression evaluator."
    ^self expressionEvaluator
        compilerError: aString at: anInteger in: codeString for: aClass!   
reinitialize
        "Close all the windows and open a new Transcript;
         deferred because 'DoIt' or 'ShowIt' needs to be returned to."
    | edited |
    edited := windows select: [ :window |
        window isApplicationWindow and: [ window isTextModified ] ].
    edited notEmpty ifTrue: [
        ( MessageBox confirm: 'There are edited windows that have not been saved.  Are you sure you want to close all of them?' )
            ifFalse: [ ^false ].
    edited do: [ :window | window clearTextModified ] ].
    ( Message new
        receiver: self
        selector: #reinitDelayed
        arguments: Array new ) performDeferred.
    ^true!  
reinitDelayed
        "Private - initialize and open a new Transcript."

    HelpManager exit.
    SystemWindow exit.
    ( Smalltalk includesKey: #SmalltalkEmulator )
        ifTrue: [ ( Smalltalk at: #SmalltalkEmulator ) exit ].
    self closeAllWindows.
    self initialize.
    self initializeTranscript.
    ( Smalltalk includesKey: #SmalltalkEmulator )
        ifTrue: [ ( Smalltalk at: #SmalltalkEmulator ) startUp ].
    SystemWindow startUp.
    HelpManager startUp!  
compiledMethod: aCompiledMethod
        "Record the compiled method that couldn't recompile."
    compiledMethod := aCompiledMethod!
defaultAction
        "Default action for Notification exceptions is to do nothing."

	Transcript cr; show: self messageText!  
compiledMethod
        "Answer the compiled method that couldn't recompile."
    ^compiledMethod!   
logDefinition
        "Log the definition of the receiver to the change log"
    | aStream |
    aStream := WriteStream on: (String new: 64).
    self fileOutOn: aStream.
    SourceManager current logSource: aStream contents forClass: self.!
new
        "Answer a new instance of the receiver class."
    ^super new initialize!   
current
        "Answer the current instance of the receiver class."
    Current isNil ifTrue: [ Current := self new ].
    ^Current!  
current: aSmalltalkToolInterface
		"Private - set the current instance of the receiver class."
	Current := aSmalltalkToolInterface! 
initializeCallingConventions
        "Private - Initialize callingConventions class instance variable."
    self callingConventions: ( Dictionary new
        at: #stdcall put: 1;
        at: #api put: 1;
        at: #c put: 2;
        yourself )!  
doIt: errorBlock
        "Private - Compile and execute the selected text.  If no error,
        log it on the change log and answer the result of the evaluation,
        else perform the errorBlock."
    | answer aString |
    self setEvaluate: true.
    ( aString := self selectedItem ) isEmpty
        ifTrue: [
            self selectLineAtCurrentSelection.
            aString := self selectedItem ].
    answer := self expressionEvaluator evaluate: aString ifError: errorBlock.
    selection selectAfter: selection corner.
    self displayChanges.
    selection display.
    ^answer!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #lfHeight
        #lfWidth
        #lfEscapement
        #lfOrientation
        #lfWeight
        #lfItalic
        #lfUnderline
        #lfStrikeOut
        #lfCharSet
        #lfOutPrecision
        #lfClipPrecision
        #lfQuality
        #lfPitchAndFamily
        #szFaceName
    )! 
prompt: questionString defaultExpression: answerString
        "Open a Prompter dialog box with questionString as its
         question and answerString as its default answer.
         Answer the resulting object after evaluating
         the user response."
    ^self new
        evaluating: true;
        prompt: questionString default: answerString!   
variableByteSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a variable
        byte subclass of the receiver with the specified class variables
        and pool dictionaries."
	
	^self 
		subclass: className
    	instanceVariableNames: instanceVariables
		classVariableNames: classVariables
    	poolDictionaries: poolDictionaries
		isVariable: true
		isPointers: false!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass
        fields: #(
            #wYear
            #wMonth
            #wDayOfWeek
            #wDay
            #wHour
            #wMinute
            #wSecond
            #wMilliseconds )
        conversions: #( 
            #asDate
            #asFileTime
            #asTime
            #asTimeStamp )!
doIt
        "Private - Compile and execute the selected text.
         If no error, log it on the change log."
    CursorManager execute changeFor: [
        self doIt: [ self clearMouseCapture. ^self ] ]!
printIt
        "Show It was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self activeTextPane notNil
        ifTrue: [ self activeTextPane printIt ]!   
matchRightBracketChar: aChar at: aPoint
        "Private - Select to the right bracket char matching
        aChar."
    | left right c lookLeft lookRight count answer found charPoint |
    charPoint := self characterCoordinate: aPoint.
    left := charPoint.
    right := charPoint.
    found := false.
    answer := TextSelection new.
    answer corner: right.
    count := 0.
    lookLeft := #($( $[ $" $').
    lookRight := #($) $] $" $').
    lookLeft := lookLeft at: (lookRight indexOf: aChar).
    [lookLeft notNil] whileTrue: [
            left := left - (1 @ 0).
            left x < 1 ifTrue: [
                left := ((self endOfLine: left y - 1) + 1) @ left y - 1].
            (c := textHolder charAt: left) isNil
                ifTrue: [lookLeft := nil]
                ifFalse: [
                    ((lookLeft = c) and: [count = 0])
                        ifTrue: [
                            answer origin: left.
                            lookLeft := nil.
                            found := true].
                    (aChar =  c) ifTrue: [count := count - 1].
                    (lookLeft = c) ifTrue: [count := count + 1]]].
    found
        ifTrue: [
            self
                selectFrom: answer origin to: answer corner;
                showSelection]
        ifFalse: [
            MessageBox message:  'Unmatched $', (String with: aChar)].
!  
iconId
		"Answer the icon id for this window class."
	^3!   
dictionary: aSymbol
        "Private - Change to the selected dictionary type."
    selectedDictionary := ( aSymbol == #class
        ifTrue: [ browsedClass class ]
        ifFalse: [ browsedClass ] ).
    selectedMethod := nil.
    self disableMethodsMenu.
    self
        changed: #selectors:;
        changed: #text:!
newMethod
        "Private - Display the text for a new
         method template in the text pane."
    self textModified
        ifFalse: [
            selectedMethod := nil.
            self
                changed: #selectors: ;
                changed: #text: ;
                disableMethodsMenu.
            ( self paneAt: #text: ) selectAll; setFocus ]!
createView
        "Private - create the SubPanes for the receiver window."
    | twoLineHeight pane group |
    self label: self label.
    twoLineHeight := ListFont height * 2 + 8.
    self addSubpane:
        ( ( group := GroupPane new )
            framingBlock: [ :box |
                box leftTop extentFromLeftTop:
                  box width // 3 @ twoLineHeight ] ).
    group
        addSubpane: ( ( pane := RadioButton new )
            contents: 'instance';
            selection: true;
            when: #clicked: send: #instanceButton: to: self with: pane;
            framingRatio: ( ( Rectangle leftTopUnit rightAndDown: ( 1/15 @ 0 ) )
                extentFromLeftTop: 14/15 @ (1/2) );
            yourself ).
    group
        addSubpane: ( ( pane := RadioButton new )
            contents: 'class';
            when: #clicked: send: #classButton: to: self with: pane;
            framingRatio: ( ( Rectangle leftTopUnit rightAndDown: ( 1/15 @ (1/2) ) )
                extentFromLeftTop: 14/15 @ (1/2) );
            yourself ).
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #selectors: ;
            when: #needsContents send: #selectors: to: self with: pane;
            when: #clicked: send: #selector: to: self with: pane;
            when: #needsMenu send: #selectorMenu: to: self with: pane;
            dragSource: self class dragDropEnabled;
            when: #dragSourceNeedsObject: send: #methodListSetDragObject: to: self;
            when: #dragSourceCut: send: #methodListCut: to: self;
            dragTargetForFormats: #( 'compiledMethod' ) operations: #( #move #copy );
            dragTarget: self class dragDropEnabled;
            dragTargetEmphasisPane;
            when: #dragTargetDrop: send: #methodListDrop: to: self;
            framingBlock: [ :box |
                box leftBottom extentFromLeftBottom:
                  box width // 3 @ ( box height - twoLineHeight ) ] ).
    self addSubpane:
        ( ( pane := self toolTextPaneClass new )
            setName: #text: ;
            when: #needsContents send: #text: to: self with: pane;
            when: #saved send: #accept: to: self with: pane;
            dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
            framingBlock: [ :box |
                ( box leftTop right: ( box width // 3 ) )
                  rightBottom: box rightBottom ] ).!   
openOn: aClass
        "Create a class browser window on aClass.
         Define the type, behavior and relative
         size of each pane and schedule the window."
    aClass isClass ifFalse: [ ^nil ].
    browsedClass := aClass.
    selectedDictionary := browsedClass.
    self
        createView;
        addHelpManager;
        openWindow;
        disableMethodsMenu!   
classButton: aPane
        "Private - the class button was selected."
    self dictionary: #class!  
removeSelector
        "Private - Remove the selected method."
    selectedMethod isNil ifTrue: [ ^nil ].
    SourceManager current
        logEvaluate: selectedDictionary name, ' removeSelector: #', selectedMethod
        for: [ selectedDictionary removeSelector: selectedMethod ].
    selectedMethod := nil.
    self disableMethodsMenu.
    self
        changed: #selectors: with: #restore;
        changed: #text:!   
selectorMenu: selectorPane
        "Private - Set the selector pane menu."
    selectorPane setMenu: ( ( Menu
        labels: '\uNew\n\uDelete\n\uSenders\n\uImplementors\n\uLocal Senders\nLocal Im\uplementors\n\uMessages\nFile O\uut...' replaceEscapeCharacters
        lines: #( 2 7 )
        selectors: #( #newMethod #removeSelector #senders #implementors #localSenders #localImplementors #messages #fileOutMethod ) )
            title: '\uMethod' replaceEscapeCharacters;
            owner: self;
            yourself )!
dragDropSourcePanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag source."
    ^Array with: #selectors:!  
methodListDrop: dragSession
        "Private - handle drag-drop transfers onto the method list."
    | method class result |
    method := dragSession objects first format: 'compiledMethod'.
    class := browsedClass.
	method classField isMetaClass ifTrue: [ class := class class ].

    ( method source isNil or: [ ( result := self compile: method sourceString in: class ) isNil ] )
        ifTrue: [ ^MessageBox notify: 'Error' withText: 'Compilation Error' ].
	class = selectedDictionary ifTrue: [
        selectedMethod := result key.
        self
            changed: #selectors: with: #restoreSelected: with: selectedMethod;
            enableMethodsMenu;
			changed: #text: ]! 
selectors: listPane
        "Private - Fill the selector pane with a sorted
         list of selectors for the selected dictionary
         type (class or instance)."
    listPane contents: selectedDictionary selectors asSortedCollection asArray!
selectedMethodSelector
		"Private - answer the selector for the selected method."
	^selectedMethod! 
label
        "Private - answer the label of the window."
    ^'Class Browser: ', browsedClass name!
accept: aPane
        "Private - Accept the contents of aPane as an updated
         method and compile it.  Notify aDispatcher if
         the compiler detects errors."
    | result aString |
    aString := aPane contents.
    result := selectedDictionary
        compile: aString
        notifying: aPane.
    aPane modified: (result isNil
        ifTrue: [true]
        ifFalse: [
            SourceManager current
                logSource: aString
                forSelector: result key
                inClass: selectedDictionary.
            result key == selectedMethod
                ifFalse: [
                    selectedMethod := result key.
                    self
                        changed: #selectors:
                        with: #restoreSelected:
                        with: selectedMethod].
            false])!  
text: textPane
        "Private - Fill the text pane with source
         text for the selected method."
    selectedMethod isNil
        ifTrue: [ ^textPane contents: self template ].
    textPane contents: ( selectedDictionary sourceCodeAt: selectedMethod )! 
selectedClass
        "Private - answer the selected class."
    ^browsedClass! 
disableMethodsMenu
        "Private - Disable the methods menu."
    super disableMethodsMenu.
    browsedClass notNil
        ifTrue: [ self methodsMenu enableItem: #newMethod ]!   
dragDropTargetPanes
        "Private - answer a collection of pane names defined in the receiver
        which are capable of being a drag target."
    ^Array with: #selectors: with: #text:! 
selectedMethod
		"Private - answer the selected method."
	selectedMethod isNil ifTrue: [ ^nil ].
	^selectedDictionary compiledMethodAt: selectedMethod!
dictionaries: aPane
        "Private - Fill the dictionaries pane with an
         Array of dictionary types (class and instance)."
    aPane contents: #( #class #instance )! 
instanceButton: aPane
        "Private - the instance button was selected."
    self dictionary: #instance! 
methodListCut: dragSession
        "Private - cut the dragged method on a move operation."
	self confirmDeletes
		ifTrue: [ ( MessageBox confirm: 'Delete ', selectedMethod, '?' ) ifFalse: [ ^self ] ].
    selectedDictionary removeSelector: selectedMethod.
    self changed: #selectors:!   
selector: listPane
        "Private - Display the method for the selected
         selector in the text pane."
    selectedMethod := listPane selectedItem.
    self enableMethodsMenu.
    self changed: #text:!
isActivationVisibleForClassSelector: aSymbol
   "Return true if activation of the argument symbol sent as a message to this class should be visible in the debugger"

   ^self name first isUpperCase! 
initialize
	"Initialize the receiver."
	"HashTable initialize"

	self initializePrimeTable: 16385!
conversions: conversionsArray
		"Answer an Array which contains the conversions
		delimiter string, followed by the conversionsArray elements."
	| array |
	array := Array new: conversionsArray size + 1.
	array at: 1 put: ' -- conversions -- '.
	array
		replaceFrom: 2
		to: conversionsArray size + 1
		with: conversionsArray
		startingAt: 1.
	^array! 
fields: fieldsArray
		"Answer an Array which contains the fields
		delimiter string, followed by the fieldsArray elements."
	| array |
	array := Array new: fieldsArray size + 1.
	array at: 1 put: ' -- fields -- '.
	array
		replaceFrom: 2
		to: fieldsArray size + 1
		with: fieldsArray
		startingAt: 1.
	^array! 
fields: fieldsArray conversions: conversionsArray
		"Answer an Array which contains the fields
		delimiter string, followed by the fieldsArray elements,
		followed by the conversions delimiter string,
		followed by the conversionArray elements."
	| array |
	array := Array new: fieldsArray size + conversionsArray size + 2.
	array at: 1 put: ' -- fields -- '.
	array
		replaceFrom: 2
		to: fieldsArray size + 1
		with: fieldsArray
		startingAt: 1.
	array at: fieldsArray size + 2 put: ' -- conversions -- '.
	array
		replaceFrom: fieldsArray size + 3
		to: array size
		with: conversionsArray
		startingAt: 1.
	^array! 
createView
        "Private - create the panes for the receiver window."
    | pane |
    self
        label: self label;
        owner: self.
    ( instPane := self toolTextPaneClass new )
        owner: self;
        setName: #instance: ;
        when: #needsContents send: #instance: to: self with: instPane;
        when: #saved send: #accept: to: self with: instPane;
        dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
        dragTarget: self class dragDropEnabled;
        framingBlock: [ :box | box width // 3 @ box top rightBottom: box rightBottom ].
    self addSubpane:
        ( ( pane := ListPane new )
            setName: #instVarList: ;
            when: #needsContents send: #instVarList: to: self with: pane;
            when: #clicked: send: #selectInstance: to: self with: pane;
            when: #doubleClicked: send: #inspectSelection: to: self with: pane;
            framingBlock: [ :box | box leftTop
                extentFromLeftTop: box width // 3 @ ( box height // 4 ) ] ).
    self addSubpane:
        ( ( pane := ListPane new )
            setName: #fieldList: ;
            when: #needsContents send: #fieldList: to: self with: pane;
            when: #clicked: send: #selectField: to: self with: pane;
            when: #doubleClicked: send: #inspectField: to: self with: pane;
            when: #needsMenu send: #inspectMenu: to: self with: pane;
            framingRatio: ( Rectangle leftBottomUnit extentFromLeftBottom: 1/3 @ ( 3/4 ) ) ).

    self addSubpane: instPane.! 
selectField: aListBox
        "Private - Select the field."
    self enableInspectItem.
    self changed: #instVarList:.
    instIndex := nil.
	fieldSelected := aListBox selectedItem isSymbol
		ifTrue: [ aListBox selectedItem ]
		ifFalse: [ nil ].
    self changed: #instance: .!   
inspectSelection
        "Private - Open an Inspector on the
         selected instance variable."
    fieldSelected isNil
        ifTrue: [^super inspectSelection]
        ifFalse: [ (object perform: fieldSelected ) inspect ].! 
selectInstance: aListPane
        "Private - Select the instance variable at
         index position anInteger in the list."
    self changed: #fieldList:.
    instIndex := aListPane selection.
    fieldSelected := nil.
    self enableInspectItem.
    self changed: #instance:!  
instance: textPane
        "Private - Set the ASCII representation
         of the selected instance variable."
    fieldSelected isNil
        ifTrue: [
            instIndex = 1 ifFalse: [ ^super instance: textPane ].
            textPane contents: object printString ]
        ifFalse: [
            ^textPane contents:
                (object perform: fieldSelected ) printString].!   
instVarList: pane
        "Private - Set an OrderedCollection of
         instance variable names and/or numbers for
         the list pane."
    pane contents: instList.
    instIndex := pane selection.
    self changed: #instance:.!  
accept: textPane
        "Private - Replace the selected instance
         variable with the result of evaluating
         the contents of textPane."
    | result aString |
    instIndex isNil ifTrue: [ ^self ].
    aString := textPane contents.

    SourceManager current
        logEvaluate: aString
        for: [
            result := CompilerInterface
                evaluate: aString
                in: object class
                to: object
                notifying: textPane
                ifFail: [ ^textPane modified: true ] ].

    fieldSelected notNil ifTrue: [
        object perform: (fieldSelected , ':') asSymbol with: result.
        textPane modified: false.
        ^self].
    instIndex = 1
        ifFalse: [
            object class isBytes
                ifTrue: [
                    object
                        at: (instIndex - 1)
                        put: result]
                ifFalse: [
                    object
                        instVarAt: self getInstVarIndex
                        put: result]].
    self changed: #instance:.
    textPane modified: false.! 
fieldList: aListBox
        "Private - show the structure fields."
    aListBox contents: object inspectorFields!   
inspectField: aListBox
        "Private - inspect the field selected."
    | selection |
    ( selection := aListBox selectedItem ) isSymbol
        ifTrue: [ ( object perform: selection ) inspect ]!   
dumpString
        "Dump the receiver's bytes in hex."
    ^self dumpStringBase: 16!
compilerError: aString at: anInteger in: codeString for: aClass
        "Private - There was an error compiling the
         startup method."
    | pane offset |
    pane := self paneAt: #startUpMethod: .
    offset := anInteger - 1.
    pane selectIndexFrom: offset to: offset.
    pane insert: aString.
    pane selectIndexFrom: offset to: offset + aString size.
    pane setFocus!  
initWindowSize
        "Private - Answer the window size."
    ^(42 @ 21) * WindowDialog unitMultiplier!
saveImage
        "Private - save the image to the selected image
         file name."
    CursorManager execute changeFor: [
        iconFileName notNil
            ifTrue: [ Icon runtimeIcon: icon ].
        SessionModel current saveSessionAs: imageFileName.
        iconFileName notNil
            ifTrue: [ icon outputToExe: imageFileName id: 1 ] ]! 
displayIcon: aStaticGraphic
        "Private - update the display of the EXE icon."
    iconFileName notNil ifTrue: [ icon release ].
    icon := iconFileName isNil
        ifTrue: [ Icon new ]
        ifFalse: [ Icon fromFile: iconFileName ].
    aStaticGraphic contents: icon!  
validateImageName
        "Private - validate the name specified for the image
         file; answer true if valid, otherwise false."
    imageFileName := ( self paneAt: #imageName: ) contents trimBlanks.
    ^true!   
close: aButton
        "Private - the window has been closed, cleanup."
    canceled := true.
    iconFileName notNil ifTrue: [ icon release ]!
cancel: aButton
        "Private - Cancel button pushed, close the window."
    self close! 
startUpMethod: aTextEdit
        "Private - set the contents of the startUpApplication method pane."
    | sourceString |
    sourceString := SessionModel sourceCodeAt: #startUpApplication.
    aTextEdit contents: sourceString!   
saveMethod
        "Private - compile & save the startUpApplication method source."
    | methodSource assoc |
    methodSource := ( self paneAt: #startUpMethod: ) contents.
    assoc := NotificationManager
        compile: methodSource
        notifying: self.
    assoc isNil
        ifTrue: [ ^false ]
        ifFalse: [
            SourceManager current
                logSource: methodSource
                forSelector: assoc key
                inClass: NotificationManager.
            ^true ]! 
ok: aButton
        "Private - OK button pushed, close the window."
    canceled := false.
    self saveMethod ifFalse: [ ^self ].
    self validateImageName ifFalse: [ ^self ].
    self sendInputEvent: #saveImage.
    self close!  
canceled
        "Answer whether the user cancelled the dialog."
    ^canceled! 
saveSession
        "Private - save the image to the current image name,
         using a default description.  Answer true if saved successfully,
         otherwise false."
    ^self
        saveSessionAs: self imageName
        description: Smalltalk product, ' ', Smalltalk version!   
virtualKeyName
        "Answer a string describing the virtual key for the receiver."
    | virtualKeyName |
    self virtualKey isNil ifTrue: [ ^nil ].
    ( virtualKeyName := VirtualKeyConstants keyAtValue: self virtualKey ) isNil ifTrue: [ ^nil ].
    self virtualKey == BackspaceKey ifTrue: [ virtualKeyName := 'BackspaceKey' ].
    ^virtualKeyName!   
initialize
        "Private - initialize the class variables of the receiver."
    PowerTwo := #( 4 8 16 32 64 128 256 512 1024 2048 4096 )!
= anObject
	"Answer whether the receiver and the argument represent the same object."

	[ ^self fileIndex == anObject fileIndex ]
		on: MessageNotUnderstood
		do: [ ^false ]!   
fileIndex
	"Answer the index into the SourceFiles array of the stream on the file referenced by the receiver."

	^fileIndex!   
fileIndex: anInteger
	"Set the index into the SourceFiles array of the stream on the file referenced by the receiver to be <anInteger>."

	fileIndex := anInteger! 
readStream
	"Answer the ReadStream referenced by the receiver."

	^Sources at: self fileIndex! 
positionedReadStream: anInteger
    "Answer the ReadStream referenced by the receiver,
	positioned to the appropriate place in the stream."

	^self readStream position: anInteger!   
hash
	"Answer with a SmallInteger unique to the receiver."

	^self fileIndex!  
inspectorFields
        "Answer the names of the fields contained in this object."
    ^self class inspectorFields! 
compileAll
        "Private - Recompile all the methods defined
         in the receiver.  If any methods are recompiled,
         display a message on the Transcript."
    self methodDictionary isEmpty
        ifTrue: [^self].
    Transcript
        cr;
        show: 'recompiling ', self name.
    self selectors do: [ :each |
        self recompile: each]! 
expressionEvaluatorClass
        "Private - answer the class of ExpressionEvaluator to use."
    ^WorkspaceExpressionEvaluator! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #mm
        #xExt
        #yExt
        #hMF
    )! 
references: anObject
        "Private - Answer true if the method includes a
         reference to anObject.  ASSERT: anObject is not
         one of the special selectors."
    | literal |
    1 to: self size do: [ :i |
        literal := self at: i.
        anObject = literal ifTrue: [ ^true ].
        literal isArray
            ifTrue: [ ( literal includes: anObject ) ifTrue: [ ^true ] ] ].
    ^false!   
unbound
    "Private - return the object that is used to indicate that an indetifier
	did not have a binding. This value is used as an internal flag by some
	of the algorithms that search for bindings. This value should not be
	returned outside of this class or its subclasses"

     ^unbound!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
initialize
     "initialize the class"
     unbound := Object new.  "define a marker that is used as an internal
				token to indicate that an identifier does not have a declaration"!
removeLocalBindingFor: id
    "Private - If this scope has a local declaration for id, remove it"
	" Bindings should not be directly added or removed from this type of scope"

    self invalidMessage!  
getScopes
	"this is the accessor method for the instance variable scopes"
	scopes == nil ifTrue: [scopes := OrderedCollection new].
	^scopes!  
localBindingFor: id
    "Private - If this scope has a local declaration for id, return the bound value,
     otherwise return: self unbound"

    | bindings |
    bindings := self allPoolsBinding: id.
    bindings size = 1
        ifTrue: [^bindings first].
    ^self unbound! 
hasInvalidBindingFor: id
	"hasInvalidBindingFor:  <String> ^<Boolean>
	Answer true if the receiver can not provide a binding for the argument,
	because such a binding (if it existed) would be invalid.  
	MultiplePoolScope consider a binding to be invalid if more than one of the
	encapsulated scopes bind the id.
	If this method reports true, then the message describeInvalidBindingFor: id
	will return a string that describes the circumstance."
    
    (self allPoolsBinding: id) size > 1
		ifTrue: [^true]
		ifFalse: [^super hasInvalidBindingFor: id]! 
add: aScope
	"add the argument scope to our collection of scopes"
	self scopes add: aScope! 
localBind: id to: info
    "Private - add an binding to the local scope for id with valueinfo"
	"bindings should not be added to a multiple pool scope.
	They should be added to one of the contained scopes."

    self invalidMessage! 
describeInvalidBindingFor:  id
   "describeInvalidBindingFor:  identifier <String> 	  ^<String>
	Answer a textual description that explains why the scope considers
	the binding for the argument to be invalid"

	^'ambiguous variable, defined in multiple pools'! 
descriptionFor: id
	"return a textual description of the type of scope that binds id"
	| s |
	s := self whoBinds: id.
	s == self unbound
		ifTrue: [^self description]
		ifFalse: [^s descriptionFor: id]!  
whoBinds: id
    "return which ever of the encapuslated scopes binds the argument
	If it is unbound or multiply bound, return the unbound indicator"
	|scp|
	scp := self scopes select: [:s| (s localBindingFor: id) ~~ s unbound].
	scp size = 1 ifTrue: [^scp first].
	^self unbound! 
allPoolsBinding: id
	"Private - Answer a collection of all the pools that bind the argument id"

	| lastBinding |
	^self scopes
		inject: OrderedCollection new
		into:
			[:bindings :s |
			(lastBinding := s localBindingFor: id) ~~ s unbound
				ifTrue: [bindings add: lastBinding].
			bindings].!   
scopes
	"Return a collection of all the scopes that make of this composit scope"
	^self getScopes!  
printOn: aStream
	"Append the ASCII representation of the receiver to aStream."

	| desc |
	super printOn: aStream.
	(desc := self description) = '' ifFalse:
		[aStream
				nextPut: $(;
				nextPutAll: desc;
				nextPut: $)]!
enclosingScope
    "Answer the environment that will be searched if the receiver does not 
	contain a binding for an identifier. "

	^self getEnclosingEnvironment!   
canDeclare: id
	"canDeclare: <String>  ^<Boolean>
	Answer true if the identifier can be declared within the receiver."

	(self hasLocalBindingFor: id)
		ifTrue: [^false].
	self canShadow
		ifTrue: [^true].
	self enclosingScope == nil
		ifTrue: [^true].
	^self enclosingScope allowsBindingOf: id! 
hasInvalidBindingFor: id
	"hasInvalidBindingFor:  <String> ^<Boolean>
	Answer true if the receiver can not provide a binding for the argument,
	because such a binding (if it existed) would be invalid.  Most classes always
	report false for this method because they do not allow invalid bindings.
	If this method reports true, then the message describeInvalidBindingFor: 
	will return a string that describes the circumstance."
    
    |env |
    (self hasLocalBindingFor: id) ifTrue: [^false].
	env := self enclosingScope.
    env notNil ifTrue: [^env hasInvalidBindingFor: id].
    ^false!   
hasBindingFor: id
    "hasBindingFor: <String> ^<Boolean>
    Answer true if the receiver contains a binding for the identifier."
    | env |
    env := self.
    [env notNil] whileTrue: [
        (env hasLocalBindingFor: id) ifTrue: [^true].
        env := env enclosingScope].
    ^false!
allowsRedefinitionOf: id
	"allowsRedefinitionOf: <String> ^<Boolean>
	Answer true if the receiver would allow a contained scope to create a
	binding for the identifier if the receiver already defines the identifier."
   ^false!   
, env
	"this is a binary shorthand for the message composeWith:"
	^self composeWith: env!   
disallowShadowing
    "Do not allow new declarations in this scope to shadow existing
	declarations in enclosing scopes"

	self setShadowFlag: false! 
defaultBindingFor: id
	"Private - return the default value to bind to id, if no value is explicitly
	provided in a declarations"
    ^nil! 
hasLocalBindingFor: id
	"Private - Return true if this scope contains a local declaration of the
	argument identifier"
    ^(self localBindingFor: id) ~~ self unbound!
hasShadowed: id
 	"hasShadowed: <String> ^<Boolean>
	Answer true if the binding for the identifier that is known to the receiver 
	shadows another binding for the same identifier."

   ^self canShadow
        and: [(self hasLocalBindingFor: id)
        and: [self enclosingScope hasBindingFor: id]]!
initialize
	"Private - Initialize an instance.  Default to allow shadowing"
    self allowShadowing!
composeWith: env
	"composeWith: <CompilerNameScope>	^<CompilerNameScope>
	Answer a new binding environment which combines the names defined 
	in the receiver and in the argument environment. When a client looks up 
	the binding for a name, the names in the receiver will be searched before 
	the names in the argument name scope. In other words, name scopes 
	should be composed from most local to most global."
	|s e|
	s := self.
	[(e := s enclosingScope) == nil] whileFalse: [s :=e ].
   	s enclosingScope: env!   
localBind: id to: info
    "Private - add an binding to the local scope for id with valueinfo"

    self implementedBySubclass!
describeInvalidBindingFor:  id
   "describeInvalidBindingFor:  identifier <String> 	  ^<String>
	Answer a textual description that explains why the scope considers the
	binding for the argument to be invalid"

       |env |
 	env := self enclosingScope.
    env notNil ifTrue: [^env describeInvalidBindingFor:  id].
    ^nil! 
declare: id boundTo:info
"	declare: <String> boundTo: <Object>
	Declare the identifier and bind it to some information. Ignore any errors"

    ^self declare: id boundTo: info ifError: []!  
declare: id boundTo:info ifError: exceptionBlock

"	declare: <String> boundTo: <Object> ifError: <Block>
	Declare the identifier and bind it to some information. If the identifier is already 
	declared or cannot be declared, evaluate the exceptionBlock."

    (self canDeclare: id)
       ifTrue: [self localBind: id to: info]
       ifFalse: [exceptionBlock value]!
enclosingScope: aScope
	"Change which environment  will be searched if the receiver does not 
	contain a binding for an identifier. This operatons nornmally is not used
	directly.  Instead use composeWith or #, to build scope hierarchies"

	self setEnclosingEnvironment: aScope!   
describeScopeBinding: id
   "describeScopeBinding:identifier <String> 	  ^<String>
	Answer a textual description of the scope that contains the binding
	for the argument"

	|env b|
    env := self.
    [env notNil] whileTrue: [
        b := env localBindingFor: id.
        b ~~ env unbound ifTrue: [^env descriptionFor: id].
        env := env enclosingScope].
    ^''! 
removeLocalBindingFor: id
    "Private - If this scope has a local declaration for id, remove it"

    self implementedBySubclass! 
getEnclosingEnvironment
    "Private - this is an accessor for the instance variable enclosingEnvironment"
    ^enclosingEnvironment!   
localBindingFor: id
    "Private - If this scope has a local declaration for id, return the bound value,
     otherwise return: self unbound"

    self implementedBySubclass

    "^ self unbound"  "the standard result if a binding is not found"!   
setEnclosingEnvironment: env
    "Private - this is an assignment accessor for the instance variable enclosingEnvironment"
    enclosingEnvironment := env! 
undeclare: id
 	"undeclare: <String>
	Remove the declaration for the identifier from the receiver. "

   (self hasLocalBindingFor: id)
        ifTrue: [self removeLocalBindingFor: id]! 
descriptionFor: id
	"return a textual description of the type of scope that binds id"
	^self description!   
getScopeDescription
    "Private - this is an accessor for the instance variable scopeDescription"
    ^scopeDescription!   
allowShadowing
	"Allow new declarations in this scope to shadow existing declarations in
	enclosing scopes"
    self setShadowFlag: true!  
bind: id to: compilerInfo
    " bind: identifier <String> to: information <Object>
    If id has been declared in this compound scope, store the ccompilerInfo
    with the binding.  It can be retrieved using bindingFor:ifNone:
    If the id has not been declared, do nothing"

    | env |
    env := self.
    [env notNil] whileTrue: [
        (env hasLocalBindingFor: id) ifTrue: [
            env localBind: id to: compilerInfo.
            ^self].
        env := env enclosingScope].!   
allowsBindingOf: id
	"allowsBindingOf: <String> ^<Boolean>
	Answer true if the receiver would allow a contained scope to create a
	binding for the identifier."
    |env |
    env := self.
    [env notNil] whileTrue: [
        (env hasLocalBindingFor: id) 
		ifTrue: 
			[(env allowsRedefinitionOf: id)
				ifFalse: [^false]].
        env := env enclosingScope].
    ^true!  
getShadowFlag
    "Private - this is an accessor for the instance variable shadowFlag"
    ^shadowFlag! 
description
	"return a textual description of the usage of this scope"
	|s|
	s := self getScopeDescription.
	s == nil ifTrue: [s := ''].
	^s!
description: aString
	"remember a textual description of the usage of this scope"
	self setScopeDescription: aString!   
setScopeDescription: env
    "Private - this is an assignment accessor for the instance variable scopeDescription"
    scopeDescription:= env!  
declare: id ifError: exceptionBlock
	"declare: <String> ifError: <Block>
	Declare the identifier and bind it to the result of sending the message 
	bindingFor: to the receiver with the identifier as the argument. If the 
	identifier is already declared or cannot be declared, evaluate the 
	exceptionBlock."

    ^self declare: id
        boundTo:(self defaultBindingFor: id)
        ifError: exceptionBlock! 
bindingFor: id ifNone: exceptionBlock
   "bindingFor: identifier <String> ifNone: exceptionBlock <Block returning: Object>
	  ^<Object>
	Answer the information bound to the identifier. If there is no binding for 
	the identifier within the receiver, return the result of evaluating the 
	exceptionBlock. "

	|env b|
    env := self.
    [env notNil] whileTrue: [
        b := env localBindingFor: id.
        b ~~ env unbound ifTrue: [^b].
        env := env enclosingScope].
    ^exceptionBlock value!   
unbound
    "Private - return the object that is used to indicate that an indetifier did not
	have a binding. This value is used as an internal flag by some of the
	algorithms that search for bindings. This value should not be returned outside
	of this class or its subclasses"

     ^self class unbound!
canShadow
	"Return true if it is possible to create declarations in this scope that hide
	declarations in enclosing scopes.  By definition, such declarations can not
	be made in a scope that does not have an enclosing scope"

    ^self getShadowFlag and: [self getEnclosingEnvironment ~~ nil]!
setShadowFlag: state
    "Private - this is an assignment accessor for the instance variable shadowFlag"
    shadowFlag := state!   
basicInspect
        "Open an inspector window on the receiver."
    Inspector new openOn: self!
uncompileDefinition: aString
        "Convert the SDS definition named aString back
         to uncompiled field accessor form."
    ( Definitions includesKey: aString )
        ifFalse: [ ^self error: 'Undefined SelfDefinedStructure: ', aString ].
    MethodDictionaries removeKey: aString ifAbsent: [ ]!
optionsMenu
        "Answer the Options menu."
    ^self mainView menuTitled: 'Options'!
textPaneClass
        "Return the class of the pane that contains text for this
        window."
    ^TextPaneControl! 
inspectIt
        "Private - Open an inspector on the result of evaluating
         the selected text."
    CursorManager execute changeFor: [
        ( self doIt: [ ^self ] ) inspect ]!
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #ptReserved
        #ptMaxSize
        #ptMaxPosition
        #ptMinTrackSize
        #ptMaxTrackSize
    )!   
primitiveSaveSessionAs: nameString description: descriptionString
        "Private - call the primitive to save the image file
         to a file named nameString, with descriptionString."
    <primitive: 17>!  
aboutToSaveImage
        "Private - before the image is saved, clear
        the cached events triggered lists."
    self withAllSubclasses do: [ :c | c eventsTriggered: nil ]!   
compile: aString in: aClass
	"Compile the method, aString, in aClass.  If the method compiles correctly,
	answer an Association whose key is the method selector and whose value
	is the compiled method.  If not, answer nil and report the error on the Transcript."

	^self compile: aString in: aClass notifying: self ifFail: [^nil]!  
initialize
        "Private - Initialize the class variables."
    LeftBrackets := #($( $[ $" $' ${).
    RightBrackets := #($) $] $" $' $}).
    Forward := true.
    CaseSensitive := true!
parseDotHFile: aFilename
        "Create a method in the receiver (class) which initializes
         the ItemIds class variable to contain a Dictionary of mappings
         from item ids to item names (symbols) and vice versa.
         aFileName is a .h file created by the Dialog Box Editor."
    | file token aDictionary key value anArray index aStream a |
    file := File pathNameReadOnly: aFilename.
    anArray := file contents asArrayOfSubstrings.
    file close.
    aDictionary := Dictionary new.
    index := 1.
    [index < anArray size] whileTrue: [
        token := anArray at: index.
        index := index + 1.
        token = '#define' ifTrue: [
            key := anArray at: index.
            value := anArray at: index + 1.
            index := index + 2.
            (value detect: [:c | c isDigit not] ifNone: [nil]) isNil ifTrue: [
                aDictionary at: key put: value ]
        ]
    ].

    aStream := WriteStream on: String new.
    aStream nextPutAll: 'initItemIds'; cr; nextPutAll: '    ItemIds := Dictionary new'; cr.
    aDictionary keys asSortedCollection do: [:k |
        a := aDictionary associationAt: k.
        aStream nextPutAll: '        at: ', a key printString, ' put: ', a value, ';'; cr.
        aStream nextPutAll: '        at: ', a value, ' put: #', a key, ';'; cr].
    aStream nextPutAll: '        yourself'.

    (self classVarNames includes: 'ItemIds') ifFalse: [
        self addClassVarName: 'ItemIds'].
    (self class compile: aStream contents) isNil
        ifTrue: [^false]
        ifFalse: [
            SourceManager current
                logSource: aStream contents
                forSelector: #initItemIds
                inClass: self class]!
relocateWindows: windowList
        "Private - Relocate windows and readjust their
         extents if screen dimension changed."
    | rect |
    OriginalScreenExtent = Display extent ifFalse: [
        windowList do: [ :w |
            ( rect := w rectangleAttribute ) notNil ifTrue: [
                rect := rect scaleBy: Display extent / OriginalScreenExtent.
				rect leftTop: rect leftTop x truncated @ rect leftTop y truncated.
				rect rightBottom: rect rightBottom x truncated @ rect rightBottom y truncated.
                w rectangleAttribute: rect ] ] ]!
matchBracketChars
        "Private - Select the nearest surrounding brackets."
    | left right sel char |
    CursorManager execute changeFor: [
        sel := self selection.
        left := sel origin.
        right := sel corner.
           "Worry if the user has selected a single bounding bracket."
       right - left = (0@0) ifTrue: [     "Single char selected."
            char := textHolder charAt: right.
            ( LeftBrackets includes: char )
                ifTrue: [ left := left + (1@0) ]
                    ifFalse: [
                        ( RightBrackets includes: char )
                            ifTrue: [ right := right - (1@0) ] ] ].
        self matchBracketFrom: left to: right ]! 
isActivationVisibleForInstanceSelector: aSymbol
	"Return true if activation of the argument symbol sent as a message to instances of this class should be visible in the debugger. All message to instance of ProtectedFrameMarker are normally invisible"

   ^false! 
binding: aBinding
    "Private - Set the binding for the receiver."

    binding := aBinding!  
name
    "Answer the name of the receiver variable."

	^binding name!  
valueFrom: process frame: frameIndex
    "Return the value of the given variable from the invocation of the method or block at stack frame frameIndex in the process given as the second argument. The frame index is a count of the stack frames from the top of the stack with frame zero being the top stack frame. The stack frame must be an invocation of the method or block for which this variable is defined or the results are indeterminate."

	^self isStackAllocated
		ifTrue: [ self isArgument
			ifTrue: [ process stackArgAt: frameIndex number: self offset ]
			ifFalse: [ process stackTempAt: frameIndex number: self offset ] ]
		ifFalse: [
			self isIndirect
				ifTrue: [
					( ( process contextFor: frameIndex ) at: self indirectOffset ) at: self offset ]
				ifFalse: [
					self isArgument
						ifTrue: [ process environmentArgAt: frameIndex number: self offset ]
						ifFalse: [ process environmentTempAt: frameIndex number: self offset ] ] ]! 
indirectOffset
    "If this variable is indirect return an index into the environment for this block where the object which contains the variables value is stored.  If the variable is not indirect then return nil."

	^binding environmentPosition + 1! 
isArgument
    "Answer true if the data associated with this variable is
	an argument to the method or block."

	^binding isArgument! 
printOn: aStream
	"Append a text representation of the receiver to aStream."

	super printOn: aStream.
    aStream nextPutAll: '(', self name, ')'!   
isIndirect
    "Answer true if the data associated with this variable is indirectly accessed through an object stored in the environment for the current block."

	^binding isIndirect!
isEnvironmentAllocated
	"Answer true if the data associated with this variable is
	stored in the environment for the method or block."

	^self isStackAllocated not!  
offset
    "Return the index of the value of the variable in the area where it is stored. This may be in index up or down in the stack or the index of a variable in an environment."

	^binding position! 
isStackAllocated
    "Answer true if the data associated with this variable is
	stored on the smalltalk stack (as opposed to an environment)."

	^binding isContextTemp not!  
valueFrom: process frame:frameIndex put: value
    "Change the value of the given variable from the invocation of the method or block at stack frame frameIndex in the process given as the second argument. The frame index is a count of the stack frames from the top of the stack with frame zero being the top stack frame. The value of the variable is changed and the old value is returned.  The stack frame must be an invocation of the method or block for which this variable is defined or the results are indeterminate."

	^self isStackAllocated
		ifTrue: [ self isArgument
			ifTrue: [ process stackArgAt: frameIndex number: self offset put: value ]
			ifFalse: [ process stackTempAt: frameIndex number: self offset put: value ] ]
		ifFalse: [
			self isIndirect
				ifTrue: [
					( ( process contextFor: frameIndex ) at: self indirectOffset ) at: self offset put: value ]
				ifFalse: [
					self isArgument
						ifTrue: [ process environmentArgAt: frameIndex number: self offset put: value ]
						ifFalse: [ process environmentTempAt: frameIndex number: self offset put: value ] ] ]!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass conversions: #( #asFlatAddress #asInteger )!
sourceCodeAt: aSymbol
        "Answer a String of the source code for the method
         named aSymbol in the receiver."
    | method answer |
    method := self compiledMethodAt: aSymbol.
    method isNil
        ifTrue: [^aSymbol]
        ifFalse:[
            (method isCompiledMethod)
                ifTrue: [
                    answer := method sourceString.
                    answer == nil
                        ifTrue: [^aSymbol, ' can''t access source code']
                        ifFalse:[^answer]]
                ifFalse:[^aSymbol, ' can''t access source code']].!
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
    category: categoryString
        "Create or modify the class named <className> to be a
        subclass of the receiver with the specifed instance variables,
        class variables, pool dictionaries, and class instance variables."

	^self subclass: className
   		instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
   		poolDictionaries: poolDictionaries
!  
isActivationVisibleForInstanceSelector: aSymbol
	"Return true if activation of the argument symbol sent as a message to instances of this class should be visible in the debugger. Only selected message to instance of Context are normally invisible"

   ^#invisibleEnsure: ~~ aSymbol! 
addSquareBrackets
        "Private - Bracket the selected text in a pair of []"
    self addLeftBracket: $[ rightBracket: $]!   
openSourceFiles
        "Private - open the source files."
    | base |
    Sources := Array new: 3.
    ( File exists: 'sources.sml' )
        ifTrue: [ Sources at: 1 put: ( ( File pathNameReadOnly: 'sources.sml' ) lineDelimiter: Cr ) ].
    Sources at: 2 put: ( ( File pathName: 'change.log' ) lineDelimiter: Cr ).
    base := File findFileName:
        'vbas', SmalltalkLibrary versionAndPlatformExtension, SmalltalkLibrary sourceFileExtension.
    Sources at: 3 put: ( base isNil
        ifTrue: [ nil ]
        ifFalse: [ File pathNameReadOnly: base ] )!
sourceIndex: index sourcePosition: integer
        "Record the source code file index and
         integer position in the end of the receiver."
    index > 255 ifTrue: [ ^self error: 'source index must be <= 255' ].
    sourceObject := integer * 256 + index.
    sourceObject = 0 ifTrue: [ self hideSource ]!
collisions
    "Answer the number keys whose hash value collide, assuming 
	hash computed by #basicHash."

    | collisions key modulus |
    collisions := 0.
    modulus := self size // 2 - 1.
    1 to: self size by: 2 do:
        [:index |
        key := self at: index.
        key == nil
            ifFalse: [index = ((key basicHash bitAnd: modulus ) * 2 + 1)
                ifFalse: [collisions := collisions + 1]]].
    ^collisions! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #ctlType
        #ctlId
        #itemId
        #itemAction
        #itemState
        #hwndItem
        #hDC
        #rcItem
        #itemData
    )! 
testDiskSpaceRequiredToCompressChanges: backupBoolean
        "Private - check to see if there is enough available disk space for
        the requested operation, answering a Boolean which indicates whether
        there is enough disk space.  Display a message box with an error
        message if there is not enough disk space."
    | bytesRequired bytesAvailable |
    bytesRequired := self diskSpaceRequiredToCompressChanges: backupBoolean.
    bytesAvailable := Disk freeDiskSpace.
    bytesAvailable < bytesRequired ifTrue: [
        MessageBox notify: 'Error' withText: 'Compressing the change.log file would require at least ',
            bytesRequired printString, ' bytes of disk space on drive ', ( String with: Disk drive ), ':, and you have only ',
            bytesAvailable printString, ' bytes available.'.
        ^false ].
    ^true!
pointer: pointerBoolean
    word: wordBoolean
    variable: variableBoolean
        "Private - Construct the instance structure specification integer as
        defined by the arguments.  Adjust the subclasses of the receiver
        as required."
    | subclassMask allMask |
    allMask := InstIndexedBit bitOr: InstPointerBit.
    subclassMask := 0.
    variableBoolean ifTrue: [
        subclassMask := subclassMask + InstIndexedBit.
        ( pointerBoolean not and: [ self isZeroTerminated ] )
            ifTrue: [ subclassMask := subclassMask + InstZeroTerminatedBit ] ].
    pointerBoolean
        ifTrue: [
            subclassMask := subclassMask + InstPointerBit.
            self structure: subclassMask + self instSize ]
        ifFalse: [ self structure: subclassMask ].
    variableBoolean ifTrue: [
        subclassMask := subclassMask bitAnd: allMask.
        self allSubclasses do: [ :c |
            c structure: ( ( c structure bitAnd: allMask bitInvert ) bitOr: subclassMask ) ] ]!  
addDoubleQuotes
        "Private - Bracket the selected text in a pair
        of double quotes."
    self addLeftBracket: $" rightBracket: $"!
testDiskSpaceRequiredToSaveImage: nameString backup: backupBoolean
        "Private - check to see if there is enough available disk space for
        the requested operation, answering a Boolean which indicates whether
        there is enough disk space.  Display a message box with an error
        message if there is not enough disk space."
    | bytesRequired bytesAvailable |
    bytesRequired := self diskSpaceRequiredToSaveImage: nameString backup: backupBoolean.
    bytesAvailable := Disk freeDiskSpace.
    bytesAvailable < bytesRequired ifTrue: [
        MessageBox notify: 'Error' withText: 'Saving the image file would require at least ',
            bytesRequired printString, ' bytes of disk space on drive ', ( String with: Disk drive ), ':, and you have only ',
            bytesAvailable printString, ' bytes available.'.
        ^false ].
    ^true!
blockNumbered: anInteger
    "Answer the BlockDescription for the block whose number is anInteger."

    self getParseTree allNodesDo: [:node |
		( node isBlock and: [ node blockID = anInteger ] )
			ifTrue: [ ^BlockDescription for: node ] ].
	^nil!   
sendersButton: aPane
        "Private - the senders button was selected."
    self selSenders!  
initWindowSize
        "Private - Answer the initial window extent."
    ^( SysFontWidth * 80 ) @ ( SysFontHeight * 25 )!   
createView
        "Private - create the panes for the receiver window."
    | xRatio yRatio pane oneLineHeight group |
    oneLineHeight := ListFont height + 8.
    xRatio := 2 / 5.
    yRatio := 2 / 5.
    self
        owner: self;
        label: 'Messages in ', selectedMethod printString.
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #selectors: ;
            when: #needsContents send: #selectors: to: self with: pane;
            when: #clicked: send: #selector: to: self with: pane;
            framingBlock: [ :box |
                box leftTop
                    extentFromLeftTop: ( box width * xRatio ) truncated @ ( box height * yRatio ) truncated ] ).
    self addSubpane:
        ( ( group := GroupPane new )
            framingBlock: [ :box |
                ( box leftTop right: ( box width * xRatio ) truncated )
                    extentFromLeftTop: ( box width * ( 1 - xRatio ) ) truncated @ oneLineHeight ] ).
    group
        addSubpane: ( ( pane := RadioButton new )
            contents: 'senders';
            when: #clicked: send: #sendersButton: to: self with: pane;
            framingRatio: ( ( Rectangle leftTopUnit rightAndDown: ( 1/15 @ 0 ) )
                extentFromLeftTop: 7/15 @ 1 );
            yourself ).
    group
        addSubpane: ( ( pane := RadioButton new )
            contents: 'implementors';
            selection: true;
            when: #clicked: send: #implementorsButton: to: self with: pane;
            framingRatio: ( ( Rectangle leftTopUnit rightAndDown: ( 8/15 @ 0 ) )
                extentFromLeftTop: 7/15 @ 1 );
            yourself ).
    self addSubpane:
        ( ( pane := ListPane new )
            addHorizontalScrollbarStyle;
            setName: #methodList: ;
            when: #needsContents send: #methodList: to: self with: pane;
            when: #needsMenu send: #listMenu: to: self with: pane;
            when: #clicked: send: #method: to: self with: pane;
            dragSource: self class dragDropEnabled;
            when: #dragSourceNeedsObject: send: #methodListSetDragObject: to: self;
            when: #dragSourceCut: send: #methodListCut: to: self;
            framingBlock: [ :box |
                ( box leftTop truncated rightAndDown: ( box width * xRatio ) truncated @ oneLineHeight )
                    extentFromLeftTop: ( box width * ( 1 - xRatio ) ) truncated @ ( ( box height * yRatio ) truncated - oneLineHeight ) ] ).
    self addSubpane:
        ( ( methodPane := self toolTextPaneClass new )
            setName: #text: ;
            when: #needsContents send: #text: to: self with: methodPane;
            when: #saved send: #accept: to: self with: methodPane;
            dragTargetForFormats: #( 'string' ) operations: #( #move #copy );
            dragTarget: self class dragDropEnabled;
            framingRatio: ( ( Rectangle leftTopUnit rightAndDown: ( 0 @ yRatio ) )
                extentFromLeftTop: ( 1 @ ( 1 - yRatio ) ) ) )!  
implementorsButton: aPane
        "Private - the implementors button was selected."
    self selImplementors!   
openOn: aMethod
        "Open a browser on the messages sent by aMethod."
    selectedMethod := method := aMethod.
    selectors := ( aMethod messages
        collect: [ :m | m isCompiledMethod
            ifTrue: [ m selector ]
            ifFalse: [ m ] ] ) asSortedCollection.
    self
        createView;
        addHelpManager;
        openWindow;
        disableMethodsMenu!   
selSenders
        "Private - Pop-up a window with the
         senders of the selected selector."
    CursorManager execute changeFor: [
        selectedSelector isNil ifFalse: [
            methods := OrderedCollection new.
            Smalltalk rootClasses do:[:aClass|
                methods := methods, (aClass sendersOf: selectedSelector)].
            self literal: selectedSelector.
            methods isEmpty
                ifTrue: [ self disableMethodsMenu ]
                ifFalse: [ self changed: #methodList: ; enableMethodsMenu ] ] ]!   
selectors: listPane
        "Private - Set the contents of the selectors pane."
    listPane contents: selectors!   
accept: textPane
        "Private - Accept the contents of textPane as an updated
         method and compile it.  Notify textPane if
         the compiler detects errors."
    | result class aString |
    selectedMethod = method
        ifFalse: [^super accept: textPane].

    aString := textPane contents.
    class := method classField.
    result := class
        compile: aString
        notifying: textPane.
    result isNil
        ifTrue: [^textPane modified: true].
    SourceManager current
        logSource: aString
        forSelector: result key
        inClass: class.
    method := selectedMethod := result value.
    selectors := (method messages
        collect: [:m | (m isCompiledMethod)
            ifTrue: [m selector]
            ifFalse: [m]]) asSortedCollection.
    selectedSelector := nil.
    self changed: #selectors: ;
        changed: #methodList: .
    ^textPane modified: false!   
selImplementors
        "Private - Pop-up a window with the
         implementors of the selected selector."
    CursorManager execute changeFor: [
        selectedSelector isNil ifFalse: [
            methods := OrderedCollection new.
            Smalltalk rootClasses do: [ :aClass |
                methods := methods, ( aClass implementorsOf: selectedSelector ) ].
            self literal: nil.
            self changed: #methodList: .
            methods isEmpty
                ifTrue: [ self disableMethodsMenu ]
                ifFalse: [ self enableMethodsMenu ] ] ]! 
selector: listPane
        "Private - An item was selected in the selectors pane."
    | selector |
    selector := listPane selectedItem.
    methods := nil.
    self disableMethodsMenu.
    selectedMethod := method.
    selectedSelector := selector.
    self literal: selector.
    self changed: #methodList: ;
        changed: #text: .
    positions isNil
        ifFalse: [methodPane showSelectionFrom: positions position
            to: positions endPosition].
    ( self paneAt: 'senders' ) selection
        ifTrue: [ self selSenders ]
        ifFalse: [ self selImplementors ]! 
addParens
        "Private - Bracket the selected text in a pair of ()."
    self addLeftBracket: $( rightBracket: $)!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #x #y ) conversions: #( #asPoint )!  
save
        "Private - Save the image to the current name,
         using a default description. Answer true if saved successfully,
         otherwise false. Retained for compatibility."
    ^SessionModel current saveSession!
inspectorFields
        "Answer the names of the fields contained in this object."
    ^self class inspectorFields! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #biSize
        #width
        #height
        #planes
        #bitCount
        #compression
        #sizeImage
        #xPelsPerMeter
        #yPelsPerMeter
        #clrUsed
        #clrImportant
    )! 
printSummaryOn: aStream
	"Private - print a summary of the contents of the receiver on aStream."

	| globals poolVariables classes methods |
	self contents notNil ifTrue: [
		( globals := self contents at: 'globals' ) notNil ifTrue: [
			aStream nextPutAll: 'Globals:'; cr; cr.
			globals asSortedCollection do: [ :g | aStream nextPutAll: g; cr ].
			aStream cr ].
		( poolVariables := self contents at: 'poolVariables' ) notEmpty ifTrue: [
			aStream nextPutAll: 'Pool Variables:'; cr; cr.
			poolVariables do: [ :v | aStream nextPutAll: v first, ' at: ', v last; cr ].
			aStream cr ].
		( classes := self classes ) notEmpty ifTrue: [
			aStream nextPutAll: 'Classes:'; cr; cr.
			( classes asSortedCollection: Class sortBlock ) do: [ :c | aStream nextPutAll: c name; cr ].
			aStream cr ].
		( methods := self methods ) notNil ifTrue: [
			aStream nextPutAll: 'Methods:'; cr; cr.
			( methods asSortedCollection: [ :a :b | a printString < b printString ] ) do: [ :m | aStream nextPutAll: m printString; cr ].
			aStream cr ] ]!
initialize
        "Private - initialize the class instance variable retryToken."

    retryToken := Object new!   
variableSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
        "Create or modify the class named <className> to be a variable
        subclass of the receiver with the specifed instance variables,
        class variables, and pool dictionaries."

	^self
		subclass: className
    	instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
		poolDictionaries: poolDictionaries
		isVariable: true
		isPointers: true!   
doubleClickSmalltalk
        "Private - a double click which does not correspond
         to a bracket-matching request occurred, so
         highlight the appropriate text"
    | currentLine start end lineCoords |
    lineCoords := self lineCoordsAtCharIndex: selection x.
    currentLine := self contents asExternalString copyFrom: ( lineCoords x max: 1 ) to: lineCoords y.

    start := ( selection x - lineCoords x + 1 ) min: currentLine size.
    end := start - 1.
    " check for double-click line selection "
    ( ( currentLine copyFrom: 1 to: start ) detect: [ :c | c isSeparator not ] ifNone: [ nil ] ) isNil
        ifTrue: [ self selectIndexFrom: lineCoords x to: lineCoords y ]
        ifFalse: [
            lineCoords x = 0 ifTrue: [ lineCoords x: 1 ].
            [ start > 1 and: [ ( currentLine at: start - 1 ) isSymbolCharacter ] ]
                whileTrue: [ start := start - 1 ].
            [ end < currentLine size and: [ ( currentLine at: end + 1 ) isSymbolCharacter ] ]
                whileTrue: [ end := end + 1 ].
            self selectIndexFrom: lineCoords x + start - 2 to: lineCoords x + end - 1 ]!
resultTypeNumber: aSymbol ifAbsent: aBlock
        "Private - Answer the result type number
         for aSymbol.  If aSymbol not a
         valid result type, evaluate
         aBlock."
    aSymbol = #struct ifTrue: [ ^aBlock value ].
    ^Types at: aSymbol ifAbsent: aBlock!
fileOutOn: aStream
	"Private - File out the classes and methods of the receiver."

	self contents notNil ifTrue: [
		( self contents at: 'globals' ) do: [:g |
			aStream cr; nextPutAll: 'Smalltalk at: #', g, ' put: '.
			( Smalltalk at: g asSymbol ) storeOn: aStream.
			aStream nextPut: $!! ] ].
	self classes do: [:c | ( ClassReader forClass: c ) fileOutDefinitionOn: aStream ].
	self classes do: [:c |
		( ClassReader forClass: c class ) fileOutOn: aStream.
		( ClassReader forClass: c ) fileOutOn: aStream ].
	self methods notNil ifTrue: [
		self methods do: [:m |
			( ClassReader forClass: m classField ) fileOutMethod: m selector on: aStream ] ].
	self contents notNil ifTrue: [
		( self contents at: 'poolVariables' ) do: [:v |
			aStream cr; nextPutAll: v first, ' at: ', v last printString, ' put: '.
			( ( Smalltalk at: v first asSymbol ) at: v last ) storeOn: aStream.
			aStream nextPut: $!! ] ].!
initialize
        "Private - Initialize the Types dictionary."
    Types := Dictionary new
        at: #short put: 1;
        at: #long put: 2;
        at: #boolean put: 3;
        at: #ushort put: 4;
        at: #ulong put: 5;
        at: #struct put: 6;
        at: #handle put: 7;
        at: #self put: 8;
        at: #none put: 9;
        at: #double put: 10;
        at: #ulongReturn put: 11;
        at: #selfIndirect put: 12;
        at: #structValue put: 13;
        at: #structIn put: 14;
        at: #structOut put: 15;
        at: #hresult put: 16;
        yourself!
addToolItem: aString action: anEvaluableAction commandKey: aCharacter
        "Add the given menu item to the list of tool items in the Smalltalk menu,
        using Ctrl+aCharacter as its accelerator key."
    self toolItems
        add: ( Array with: aString with: anEvaluableAction with: aCharacter )!  
smalltalkMenu: hasTextPane
        "Private - answer a standard Smalltalk menu;
         is hasTextPane is true, add the items that are
         only appropriate for a window with a TextPane."
    | menu |
    menu := Menu new
        title: 'Sm\ualltalk' replaceEscapeCharacters.
    hasTextPane ifTrue: [
        self addSmalltalkEvaluationItemsTo: menu.
        menu appendSeparator ].
    self addSmalltalkToolItemsTo: menu.
    ^menu!
toolItems
        "Private - answer the list of tool items in the Smalltalk menu."
    ToolItems isNil ifTrue: [ ToolItems := OrderedCollection new ].
	^ToolItems!
toolItems: anOrderedCollection
        "Private - set the list of tool items in the Smalltalk menu
        to anOrderedCollection."
    ToolItems := anOrderedCollection!  
removeToolItem: aString
        "Remove the tool whose item text is aString from the list of
        tool items in the Smalltalk menu."
    ToolItems := ToolItems reject: [ :item | ( item at: 1 ) = aString ]!   
editMenu
        "Answer the standard Edit menu for browsers."
    ^super editMenu
        insertSubMenu: self bracketsMenu after: 10;
        insertSeparatorAfter: 11;
        yourself!   
bracketsMenu
        "Answer the insertBracket menu."
    | ctrlBits |
    ctrlBits := AfChar | AfControl.
    ^Menu new
        title: '\uBrackets' replaceEscapeCharacters;
        appendItem: '\uMatch\tCtrl+M' replaceEscapeCharacters selector: #matchBracketChars accelKey: $m accelBits: ctrlBits;
        appendItem: 'Insert [ ]\tCtrl+[' replaceEscapeCharacters selector: #addSquareBrackets accelKey: $[ accelBits: ctrlBits;
        appendItem: 'Insert ( )\tCtrl+(' replaceEscapeCharacters selector: #addParens accelKey: $( accelBits: ctrlBits | AfShift;
        appendItem: 'Insert { }\tCtrl+{' replaceEscapeCharacters selector: #addCurlyBrackets accelKey: ${ accelBits: ctrlBits | AfShift;
        appendItem: 'Insert '' ''\tCtrl+''' replaceEscapeCharacters selector: #addSingleQuotes accelKey: $' accelBits: ctrlBits;
        appendItem: 'Insert " "\tCtrl+"' replaceEscapeCharacters selector: #addDoubleQuotes accelKey: $" accelBits: ctrlBits | AfShift;
        yourself!  
addSmalltalkEvaluationItemsTo: aMenu
        "Private - add menu items related to expression evaluation to aMenu."
    aMenu
        appendItem: '\uShow It\tCtrl+S' replaceEscapeCharacters selector: #printIt accelKey: $S accelBits: AfControl;
        appendItem: '\uDo It\tCtrl+D' replaceEscapeCharacters selector: #doIt accelKey: $D accelBits: AfControl;
        appendItem: '\uInspect It\tCtrl+I' replaceEscapeCharacters selector: #inspectIt accelKey: $I accelBits: AfControl;
        appendItem: 'File It I\un\tCtrl+N' replaceEscapeCharacters selector: #fileItIn accelKey: $N accelBits: AfControl!
addToolItem: aString action: anEvaluableAction
        "Add the given menu item to the list of tool items in the Smalltalk menu."
    self addToolItem: aString action: anEvaluableAction commandKey: nil!  
optionsMenu: supportsWordWrap
        "Answer the standard Options menu; if hasTextPane is
         true, include items that apply only to windows that
         include a TextPane."
    | menu submenu |
    submenu := Menu new
        title: '\uColor' replaceEscapeCharacters;
        appendItem: '\uForeground...' replaceEscapeCharacters selector: #setForegroundColor;
        appendItem: '\uBackground...' replaceEscapeCharacters selector: #setBackgroundColor;
        yourself.
    menu := Menu new
        title: '\uOptions' replaceEscapeCharacters.
    supportsWordWrap ifTrue: [
        menu appendItem: '\uWord Wrap' replaceEscapeCharacters selector: #toggleWrap ].
    menu
        appendItem: '\uZoom\tAlt+Z' replaceEscapeCharacters selector: #zoom accelKey: $Z accelBits: AfAlt;
        appendItem: '\uFont...' replaceEscapeCharacters selector: #setFonts;
        appendItem: '\uDrag Drop' replaceEscapeCharacters selector: #toggleDragDrop;
        appendSubMenu: submenu.
    Browser dragDropEnabled ifTrue: [ menu checkItem: #toggleDragDrop ].
    ^menu!
fileMenu
        "Answer the standard File menu for browsers."
    | menu index |
    menu := super fileMenu.
    menu
        deleteItem: #newFile;
        insertItem: '\uInstall...' replaceEscapeCharacters selector: #install accelKey: nil accelBits: nil after: 1.
    index := ( Smalltalk includesKey: #MailMessage ) ifTrue: [ 5 ] ifFalse: [ 4 ].
    menu insertSeparatorAfter: index.
    menu
        insertItem: 'Sa\uve Image...' replaceEscapeCharacters selector: #saveImage accelKey: nil accelBits: nil after: index + 1;
        insertItem: 'Save I\umage As...' replaceEscapeCharacters selector: #saveImageAs accelKey: nil accelBits: nil after: index + 2.
    ^menu!   
addSmalltalkToolItemsTo: aMenu
        "Private - add menu items that launch development tools to aMenu."
    aMenu
        appendItem: 'New \uWorkspace\tCtrl+W' replaceEscapeCharacters selector: #openWorkspace accelKey: $W accelBits: AfControl;
        appendItem: '\uBrowse Classes\tCtrl+B' replaceEscapeCharacters selector: #openClassBrowser accelKey: $B accelBits: AfControl;
        appendItem: 'Browse Dis\uk\tCtrl+K' replaceEscapeCharacters selector: #openDiskBrowser accelKey: $K accelBits: AfControl;
        appendItem: 'Browse Se\urvices' replaceEscapeCharacters selector: #openServiceManagerWindow.
    self toolItems do: [ :item |
        aMenu appendItem: ( item at: 1 ) action: ( item at: 2 ) commandKey: ( item at: 3 ) ]! 
addFileMenu
        "Private - add the File menu to the menu bar."
    | menu |
    ( menu := self class fileMenu ) notNil ifTrue: [
        menu owner: window owner.
        "( window owner respondsTo: #accept )
            ifFalse: [ menu disableItem: #accept ]."
        ( window owner respondsTo: #saveAs )
            ifFalse: [ menu disableItem: #saveAs ] ].
        window menuWindow addMenu: menu!
addSmalltalkMenu
        "Private - add the menus that are to be located
         on the menu bar before any application-specific
         menus (File, Edit, Smalltalk)."
    | menu textPane |
    textPane := window searchForDefaultTextPane.
    ( menu := self class smalltalkMenu: textPane notNil ) notNil ifTrue: [
        menu allOwners: window owner.
        window menuWindow addMenu: menu ]! 
addStandardLeftMenus
        "Private - add the menus that are to be located
         on the menu bar before any application-specific
         menus (File & Edit)."
    super addStandardLeftMenus.
    self addSmalltalkMenu.! 
addStandardRightMenus
        "Private - add the Options menu to the menu bar."
    | menu textPane wrappable |
    textPane := window searchForDefaultTextPane.
	wrappable := textPane respondsTo: #toggleWrap.
    ( menu := self class optionsMenu: wrappable ) notNil ifTrue: [
        menu allOwners: window owner.
        window menuWindow addMenu: menu.
        ( wrappable and: [ textPane wrap ] ) ifTrue: [ menu checkItem: #toggleWrap ] ].
    super addStandardRightMenus!  
definition
	"Answer the definition for the receiver.
	Assumption: the receiver is currently installed in a method dictionary for an installed class"

	| definition |
	definition := sourceObject knownDefinition.
	definition == nil
		ifFalse: [^definition].
	^self compiledMethodDefinitionClass on: self!
initialize
        "Private - initialize the class variables of the receiver."
    ObjectStoreExternalTypes := PoolDictionary new.
    ObjectStoreExternalTypes
        at: 'ResolvedExternal' put: 0 ;
        at: 'SymbolExternal' put: 1 ;
        at: 'AssocExternal' put: 2 ;
        at: 'GlobalExternal' put: 3 ;
        at: 'MetaClassExternal' put: 4 ;
        at: 'MethodDictionaryExternal' put: 5 ;
        at: 'MetaMethodDictionaryExternal' put: 6 ;
        at: 'ExpressionExternal' put: 7 ;
        at: 'ClassVariableExternal' put: 8 ;
        at: 'MethodDictionaryArrayExternal' put: 9 ;
        at: 'MetaMethodDictionaryArrayExternal' put: 10 ;
        at: 'CreateItExternal' put: 11 ;
        at: 'PoolVariableExternal' put: 12 ;
        at: 'CommonByteCodeArrayExternal' put: 13 ;
        at: 'NilExternal' put: 14 ;
        at: 'TrueExternal' put: 15 ;
        at: 'FalseExternal' put: 16 ;
        at: 'MarkedFrameExternal' put: 17 ;
        at: 'CharacterExternal' put: 18;
        at: 'CompiledMethodExternal' put: 19;
        at: 'ResidueExternal' put: 20;
        at: 'StandardBlockClosureExternal' put: 21.!  
inspectIt
        "Inspect It was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self mainView inspectIt!  
printIt
        "Show It was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self mainView printIt! 
inspectorFields
        "Answer the names of the fields contained in this kind of object."
    ^ExternalBuffer inspectorClass fields: self fields conversions: self conversions!
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #dwFileAttributes
        #ftCreationTime
        #ftLastAccessTime
        #ftLastWriteTime
        #nFileSizeHigh
        #nFileSizeLow
        #cFileName
        #cAlternateFileName
    )! 
hasMessagePattern
	"Answer true if the receiver has a message pattern"

	^self compiledMethod hasMessagePattern!   
compiledMethod
	"Answer the executable corresponding to the receiver"

	^compiledMethod!   
sourceString
        "Answer the uncompressed source
         code for the receiver."

	^self compiledMethod sourceString!
setSourceString: newSource
	"Record <newSource> as the new source string for the receiver.  It is assumed that this source corresponds to the current executable"

    | aStream |
    aStream := Sources at: 2.
    aStream
        setToEnd;
        cr; cr;
        nextPut: $!!;
        nextPutAll: self classObjectOrNil name, ' methods !!'.
    self compiledMethod
        sourceIndex: 2
        sourcePosition: (SourceManager current getMethodPositionOn: aStream for: newSource).
    aStream
        nextChunkPut: newSource;
        nextChunkPut: String new;
        flush! 
debugInfo
	"Answer debug information for the receiver"

	| comp |
	comp := CompilerInterface 
		forClass: self classObjectOrNil 
		errorHandler: SilentErrorHandler new.
	^comp compile: self sourceString withMessagePattern: self hasMessagePattern! 
sourceString: newSource
notifying: requestor
    "Associate new source with the receiver. Answer <nil> if the source cannot be accepted, or the definition if it can be. Associating source with a definition may require compilation, and the definition answered when successful may not be the receiver. If compilation is required and any errors are detected, notify the <requestor>."


    | result newDefinition |
    result := self
        sourceString: newSource
        errorHandler: (requestor == nil
            ifTrue: [SilentErrorHandler new]
            ifFalse: [TextPaneErrorHandler new pane: requestor]).
    (result == nil or: [result wasSuccessful not])
        ifTrue: [^nil].
    result selector == self selector
        ifTrue:
            [self compiledMethod: result method.
            newDefinition := self]
        ifFalse: [newDefinition := result method definition].
    newDefinition setSourceString: newSource.
    ^newDefinition!  
compiledMethod: aCompiledMethod
	"Record the executable corresponding to the receiver"

	compiledMethod := aCompiledMethod!
recompile
        "Private - Recompile the receiver.  Answer the compilation result or nil if there was no source"

    | result oldMethod newMethod |
    oldMethod := self compiledMethod.
	result := self 
		sourceString: oldMethod sourceString 
		errorHandler: SilentErrorHandler new.
	(result == nil or: [result wasSuccessful not])
		ifTrue: [^result].
	newMethod := result method.
	newMethod sourceObject: oldMethod sourceObject.
	^result!
selector
	"Answer the selector for the receiver"

	^self compiledMethod selector!  
executable
	"Answer the executable representation of the receiver"

	^self compiledMethod! 
classObjectOrNil
	"Answer the Smalltalk class with the same name as the receiver"

	^self compiledMethod classField!   
sourceString: newSource
errorHandler: errorHandler
    "Private - Compile and install <newSource> for the receiver. Answer the compilation result derived from thecompilation or nil if there is no source."

    | class compiler result newMethod |
	newSource == nil
		ifTrue: [^nil].
	class := self classObjectOrNil.
	compiler := CompilerInterface 
		forClass: class 
		errorHandler: errorHandler.
	result := compiler compile: newSource withMessagePattern: self hasMessagePattern.
	result wasSuccessful
		ifTrue:		
			[newMethod := result method.
			newMethod classField: class.
			self hasMessagePattern
				ifTrue: [newMethod selector:  result selector]
				ifFalse: [newMethod selector: self selector].
    		class addSelector: newMethod selector withMethod: newMethod].
	^result!
aboutToSaveImage
        "Private - Give all the windows a
         chance to save things."
    self cleanUpWindows.
    self getSavedWindows.
    windows do: [:w |
        w isApplicationWindow ifTrue: [
            w aboutToSaveImage]].!
initializeControlKeys
        "Private - initialize the ControlKeys class variable."
    ControlKeys := Set new
		add: BackspaceKey;
"		add: SpaceKey;"
		add: EscapeKey;
		add: ReturnKey;
		add: TabKey;
		add: BacktabKey;  "for OS/2 compatibility"
		yourself!  
buildExe: newImageName fromExe: oldImageName
        "Private - Assemble an exe from the pieces generated by the virtual
        machine. Answer 0 if it worked, the error code if any errors."
    | binder installer result |
    ( Smalltalk includesKey: #Coff ) ifFalse: [
        installer := DefinitionInstaller current.
        DefinitionInstaller current: nil. "get a default (base) installer."
        binder := SmalltalkLibraryBinder bindTo: 'vcoff', SmalltalkLibrary versionAndPlatformExtension ].
    result := self privateBuildExe: newImageName fromExe: oldImageName.
    binder notNil ifTrue: [ binder unBind ].
    installer notNil ifTrue: [ DefinitionInstaller current: installer ].
    ^result! 
fileOutOn: aStream
        "Append the class definition message for the receiver to <aStream>."
    aStream
        nextPutAll: self name;
        space;
        nextPutAll: 'instanceVariableNames: ';
        nextPutAll: self instanceVariableString storeString!   
help
        "Private - display context sensitive help based on the current selection in
        the browser."
    | pane selection oldHelpFileName hm topics allTopics fileNames contextString helpDir |

    hm := self mainView helpManager.
    pane := self mainView searchForDefaultTextPane.
    pane notNil ifTrue: [ selection := pane selectedItem ].
    selection notNil ifTrue: [
        "check each installed help file for a matching entry."
        allTopics := SmalltalkToolInterface current helpTopics.
        fileNames := SmalltalkToolInterface current helpFileNames.
        2 to: allTopics size do: [ :index |
            topics := allTopics at: index.
            ( topics includes: selection ) ifTrue: [
                oldHelpFileName := hm helpFileName.
                helpDir := SmalltalkToolInterface current helpDirectoryName.
                hm helpFileName: helpDir, '\', ( fileNames at: index ).
                hm displayHelp: selection.
                hm helpFileName: oldHelpFileName.
                ^self ] ] ].

    "doesn't correspond to a context entry, so display regular help."
    contextString := self helpContextStringFor: self mainView helpContext.
    hm displayHelp: contextString.
    self mainView helpContext: nil! 
openChangeLogIn: aDirectory
        "Private - Open the change log in the specified
         directory."
    Sources at: 2 put: ( aDirectory file: 'change.log' ).
    ( Sources at: 2 ) lineDelimiter: Cr!   
alignSourceAt: factor for: aStream startingAt: anInteger
        "Private - Pad aStream with spaces so that next write will be
        aligned at factor boundary. anInteger is the starting size."
    | padding |
    padding := anInteger \\ factor.
    padding > 0 ifTrue: [
        aStream next: factor - padding put: $ ].! 
implementorsOf: aSymbol in: aClass
        "Open a MethodBrowser on all methods
         named aSymbol in aClass and its subclasses.
        aClass can be a class or a collection of classes."
    | methods |
    methods := OrderedCollection new.
    CursorManager execute changeFor: [
        aClass isCollection
            ifTrue: [
                aClass do: [ :class |
                    methods := methods, ( class implementorsOf: aSymbol ) ] ]
           ifFalse: [ methods := aClass implementorsOf: aSymbol ] ].
    MethodBrowser new
        label: 'Implementors of ', aSymbol printString;
        openOn: methods!  
backupChanges
        "Private - Make backup of the change log.
        Don't try to backup if change.log does not yet exist."
   ( Sources at: 2 ) isNil ifTrue: [ ^true ].
    ^SessionModel current 
        backup: ( Sources at: 2 ) pathName
        sourceIndex: 2 
        message: 'Your change log could not be compressed'! 
referencesToString: aString in: aClass
        "Open a MethodBrowser on all methods whose source code
        includes the substring aString."
    | methods |
    methods := OrderedCollection new.
    CursorManager execute changeFor: [
        aClass isCollection
            ifTrue: [
                aClass do: [ :class |
                    methods := methods, ( class referencesToString: aString ) ] ]
           ifFalse: [ methods := aClass referencesToString: aString ] ].
    methods := methods reject: [ :m | m selector = #Doit ].
    MethodBrowser new
        literal: aString;
        label: 'References to ', aString printString;
        openOn: methods!  
messagesIn: aCompiledMethod
        "Open a SelectorBrowser on all messages
        sent from aCompiledMethod."
    SelectorBrowser new openOn: aCompiledMethod!   
logSource: aString forSelector: aSymbol inClass: aClass
        "Private - Append the source code aString to the
         change log for method with selector aSymbol in
         aClass.  Make compiled method point to source
         in change log."
    ( aClass compiledMethodAt: aSymbol ) sourceString: aString! 
putMethod: aCompiledMethod withIndex: anInteger to: aStream
        "Private - Append the source code for
         aCompiledMethod to aStream.  anInteger
         identifies the file number: 1 = source
         file; 2 = change log."
    | source |
    ( source := aCompiledMethod sourceString ) isNil
        ifTrue: [ ^nil ].
    aCompiledMethod
        sourceIndex: anInteger
        sourcePosition: ( self getMethodPositionOn: aStream for: source ).
    aStream nextChunkPut: source!
fileInFromNoCancel: aStream
        "Private - read and execute the Smalltalk source code chunks
        from aStream.  If a chunk starts with !! send it the message
        fileInFrom: aStream"
    | aString toBeFiledIn |
    aStream reset.
    [ aStream atEnd or: [ ( aStream peek asInteger ) > ( $  asInteger ) ] ]
        whileFalse: [ aStream next ].
    [ aStream atEnd ]
        whileFalse: [
            toBeFiledIn := aStream peekFor: $!!.
            aString := aStream nextChunk.
            toBeFiledIn
                ifTrue: [ ( CompilerInterface evaluate: aString ) fileInFrom: aStream ]
                ifFalse: [ CompilerInterface evaluate: aString ] ]!  
compressChangesOf: aClass into: aStream
        "Private - Write latest version of all methods
         in aClass that are in the change log to aStream."
    | method |
    aClass selectors asSortedCollection do: [ :s |
        method := aClass compiledMethodAt: s.
        method sourceIndex = 2 ifTrue: [
            self putHeaderOf: aClass into: aStream.
            self putMethod: method withIndex: 2 to: aStream.
            aStream nextPutAll: ' !!' ] ]!   
fileInFrom: aStream
        "Private - read and execute the Smalltalk source code chunks
        from aStream.  If a chunk starts with !! send it the message
        fileInFrom: aStream"
    [ self fileInFromNoCancel: aStream ] on: Notification do: [ :exception |
        exception messageText = 'Abort Compilation'
            ifTrue: [^nil ].
        exception pass ]! 
logEvaluate: aString
        "Private - Append 'evaluate' followed by
         aString (in chunk format) to the change log."
    self logEvaluate: aString for: [ ]!   
implementorsOf: aSymbol
        "Open a MethodBrowser on all methods
         named aSymbol."
    self implementorsOf: aSymbol in: Smalltalk rootClasses!  
getSourceClasses
        "Private - Answer an OrderedCollection of all
         classes in hierarchical order."
    | classes |
    classes := OrderedCollection new: Smalltalk size.
    Smalltalk rootClasses do: [ :rootClass |
        rootClass withAllSubclasses do: [ :c |
            c name first == Space
                ifFalse: [ classes add: c ] ] ].
    ^classes!   
decompress: aString
        "Private - answer a String which is the decompressed form of
        <aString>. Decompression replaces character values > 128 with
        the string that the character represents."
    ^self
        decompress: aString
        using: self class decompressionArray!   
referencesTo: globalSymbol
        "Open a MethodBrowser on all methods
        referencing the global named globalSymbol."
    self sendersOf: ( Smalltalk associationAt: globalSymbol asSymbol )!
compress: aString
        "Private - answer a String which is the compressed form of
        <aString>."
    ^self compress: aString using: self class compressionDictionary!  
compressSourcesOf: aClass into: aStream
        "Private - Write latest version of all methods
         in aClass to aStream."
    | method firstTime index |
    firstTime := true.
    aClass selectors asSortedCollection do: [ :s |
        method := aClass compiledMethodAt: s.
        ( ( index := method sourceIndex ) = 1 or: [ index = 2 ] ) ifTrue: [
            firstTime ifTrue: [
                self putHeaderOf: aClass into: aStream.
                firstTime := false].
            self putMethod: method withIndex: 1 to: aStream ] ].
    firstTime ifFalse: [ aStream nextPutAll: ' !!' ]! 
compress: aString using: compressionDictionary
        "Private - answer a String which is the compressed form of <aString>.
        Compression uses the <compressionDictionary> to replace frequently
        occurring sequences of characters with a single character > 127.
        Characters > 127 are preceded by the escape character 128."
    | lf nextPiece aStream answer blanks |
    lf := nextPiece := ( String with: 10 asCharacter ).
    aStream := ReadStream on: aString.
    answer := WriteStream on: ( String new: aString size ).
    [ nextPiece = lf
        ifTrue: [
            blanks := aStream countBlanks.
            answer nextPut:
                ( ( blanks min: 126 ) + 129 ) asCharacter.
            answer next: ( ( blanks - 126 ) max: 0 ) put: $ ].
     ( nextPiece := aStream nextPiece ) == nil ]
        whileFalse: [
            ( compressionDictionary includesKey: nextPiece )
                ifTrue: [
                    answer nextPut:
                        ( compressionDictionary at: nextPiece ) asCharacter ]
                ifFalse: [ answer nextPutAll: nextPiece ] ].
    ^answer contents!   
decompress: aString using: decompressionArray
        "Private - answer a String which is the decompressed form of <aString>.
        Decompression replaces character values > 128 with the string from the
        <decompressionArray> that the character represents."
    | lf aStream answer aCharacter index |
    lf := true.
    aStream := ReadStream on: aString.
    answer := WriteStream on: ( String new: 200 ).
    [ aStream atEnd ]
        whileFalse: [
            aCharacter := aStream next.
            ( index := aCharacter asciiValue ) > 128
                ifTrue: [
                    lf
                        ifTrue: [
                            answer next: index - 129 put: $ .
                            lf := false ]
                        ifFalse: [
                            answer nextPutAll:
                                ( decompressionArray at: index - 128 ) ] ]
                ifFalse: [
                    index = 128
                        ifTrue: [ aCharacter := aStream next ].
                    answer nextPut: aCharacter.
                    lf := ( index = 10 ) ] ]. "10 = Lf"
    ^answer contents! 
getMethodPositionOn: aStream for: aString
        "Private - Answer the next method position in aStream for aString."
    | methodPosition |
    methodPosition := aString isEmpty
        ifTrue: [ aStream position + 1 ]
        ifFalse: [
            aStream lineDelimiter == Cr
                ifTrue: [ aStream position + 2 ]
                ifFalse: [ aStream position + 1 ] ].
    ^methodPosition + SourceAlignFactor - 1
        // SourceAlignFactor * SourceAlignFactor!  
putHeaderOf: aClass into: aStream
        "Private - Put a header for aClass which
         identifies the class of the following
         methods to aStream."
    aStream
        cr;
        cr;
        nextPutAll: '!! ', aClass name, ' methods !!'! 
backupSources
        "Private - Make backup of the sources file.
        Don't try to backup if sources.sml does not yet exist."
    ( Sources at: 1 ) isNil ifTrue: [ ^true ].
    ^SessionModel current 
        backup: ( Sources at: 1 ) pathName
        sourceIndex: 1 
        message: 'Your sources could not be compressed'!
compressSources
        "Build a new source file which contains
         the latest version of all methods.
         Build a zero length change log file.
         Save the image to the image file."
    | sourceDirectory stream crm changeLog dialog allClasses class compressionDictionary |
    ( SessionModel testDiskSpaceRequiredToCompressSources: BackupImage )
        ifFalse: [ ^self ].

    BackupImage ifTrue: [ self backupChanges ifFalse: [ ^self error: 'Error backing up change.log' ] ].
    BackupImage ifTrue: [ self backupSources ifFalse: [ ^self error: 'Error backing up sources.sml' ] ].
    dialog := ProgressIndicatorDialog new
        noCancel;
        open: WindowLabelPrefix message: 'Compressing Sources...'.
    compressionDictionary := self class compressionDictionary.
    crm := 'Copyright 1990-1994 Digitalk Inc.  All rights reserved'.
    stream := Disk newFile: 'sources.tmp'.
    stream lineDelimiter: Cr.
    stream nextPutAll: crm.
    allClasses := self getSourceClasses.
    1 to: allClasses size do: [:i |
        class := allClasses at: i.
        self compressSourcesOf: class class into: stream.
        self compressSourcesOf: class into: stream.
        dialog percent: ( i / allClasses size * 100 ) truncated ].
    stream cr; nextPutAll: crm.
    stream close.
    ( Sources at: 1 ) isNil ifTrue: [
        Sources at: 1 put: ( File pathName: 'sources.sml' ) ].
    sourceDirectory := ( Sources at: 1 ) file directory.
    ( Sources at: 1 ) close.
    File remove: ( Sources at: 1 ) pathName.
    Disk drive == sourceDirectory drive
        ifTrue: [ File rename: stream pathName to: ( Sources at: 1 ) pathName ]
        ifFalse: [
            File copy: stream pathName to: ( Sources at: 1 ) pathName.
            File remove: stream pathName ].
    Sources at: 1 put: ( sourceDirectory file: ( Sources at: 1 ) file name ).
    changeLog := ( Sources at: 2 ).
    changeLog close.
    File remove: changeLog pathName.
    Sources at: 2 put: ( changeLog file directory file: changeLog file name ).
    ( Sources at: 2 ) lineDelimiter: Cr.
    dialog message: 'Saving Image File...';
        percent: 0;
        percent: 100;
        close.
    SessionModel current saveSession!
logEvaluate: aString for: aZeroArgumentBlock
        "Private - evaluate aZeroArgumentBlock, and then append
        'evaluate' followed by aString (in chunk format) to the change log.
        Answer the result of the block evaluation."
    | result |
    result := aZeroArgumentBlock value.
    ( Sources at: 2 )
        setToEnd;
        cr;
        cr;
        nextPutAll: '"evaluate"';
        nextChunkPut: aString;
        flush.
    ^result! 
compressChanges
        "Build a new change log file retaining
         only the latest version of changed
         methods in the current change log.
         Save the image to the image file."
    | logDirectory stream dialog allClasses class |
    ( SessionModel testDiskSpaceRequiredToCompressChanges: BackupImage )
        ifFalse: [ ^self ].

    BackupImage ifTrue: [ self backupChanges ifFalse: [ ^self error: 'Error backing up change.log' ] ].
    dialog := ProgressIndicatorDialog new
        noCancel;
        open: WindowLabelPrefix message: 'Compressing Changes...'.
    logDirectory := ( Sources at: 2 ) file directory.
    stream := logDirectory newFile: 'change.tmp'.
    stream lineDelimiter: Cr.
    allClasses := self getSourceClasses.
    1 to: allClasses size do: [ :i |
        class := allClasses at: i.
        self compressChangesOf: class class into: stream.
        self compressChangesOf: class into: stream.
        dialog percent: ( i / allClasses size * 100 ) truncated ].
    stream close.
    ( Sources at: 2 ) close.
    File remove: ( Sources at: 2 ) pathName.
    File rename: stream pathName to: ( Sources at: 2 ) pathName.
    Sources at: 2 put: ( logDirectory file: ( Sources at: 2 ) file name ).
    ( Sources at: 2 ) lineDelimiter: Cr.
    dialog message: 'Saving Image File...';
        percent: 0;
        percent: 100;
        close.
    SessionModel current saveSession!   
referencesTo: globalSymbol in: aClass
        "Open a MethodBrowser on all methods in aClass or a subclass of aClass
        referencing the global named globalSymbol."
    self sendersOf: ( Smalltalk associationAt: globalSymbol asSymbol ) in: aClass!
referencesToString: aString
        "Open a MethodBrowser on all methods whose source code
        includes the substring aString."
    self referencesToString: aString in: Smalltalk rootClasses!
sendersOf: aSymbol in: aClass
        "Open a MethodBrowser on all methods in aClass
        and its subclasses that reference aSymbol.
        aClass can be a class or a collection of classes."
    | methods |
    methods := OrderedCollection new.
    CursorManager execute changeFor: [
        aClass isCollection
            ifTrue: [
                aClass do: [ :class |
                    methods := methods, ( class sendersOf: aSymbol ) ] ]
            ifFalse: [ methods := aClass sendersOf: aSymbol ] ].
    MethodBrowser new
        label: 'Senders of ', aSymbol printString;
        literal: aSymbol;
        openOn: methods!  
sendersOf: aSymbol
        "Open a MethodBrowser on all methods
         that reference aSymbol."
    self sendersOf: aSymbol in: Smalltalk rootClasses!   
logSource: aString forClass: aClass
        "Private - Append the class definition message
         aString for aClass to the change log."
    ( Sources at: 2 )
        setToEnd;
        cr;
        cr;
        nextPutAll: '"define class"';
        nextChunkPut: aString;
        flush!   
saveImageAs
        "The user selected Save Image As... from the File menu."
    self mainView saveImageAs! 
bytes: anInteger
        "Private - anInteger number of bytes was selected from the Bytes
         submenu; update the text pane."
    | menu |
    bytes := anInteger.
    menu := ( ( self menuTitled: '\uInspect' replaceEscapeCharacters )
        getMenuItem: '\uBytes' replaceEscapeCharacters ) submenu.
    menu
        uncheckItem: 1;
        uncheckItem: 2;
        uncheckItem: 4;
        checkItem: anInteger.
    self changed: #instance:! 
radix: anInteger
        "Private - a radix was selected from the Radix
         submenu; update the text pane."
    | radixMenu |
    radix := anInteger.
    radixMenu := ( ( self menuTitled: '\uInspect' replaceEscapeCharacters )
        getMenuItem: '\uRadix' replaceEscapeCharacters ) submenu.
    radixMenu
        uncheckItem: 2;
        uncheckItem: 8;
        uncheckItem: 10;
        uncheckItem: 16;
        checkItem: anInteger.
    self changed: #instance:! 
inspectMenu: pane
        "Private - Set the ByteArrayInspector list pane menu."
    | menu radixMenu bytesMenu |
    radixMenu := Menu new
        title: '\uRadix' replaceEscapeCharacters;
        selector: #radix: ;
        appendItem: '\uBinary' replaceEscapeCharacters selector: 2 ;
        appendItem: '\uOctal' replaceEscapeCharacters selector: 8;
        appendItem: '\uDecimal' replaceEscapeCharacters selector: 10 ;
        appendItem: '\uHexadecimal' replaceEscapeCharacters selector: 16 ;
        checkItem: 16 ;
        yourself.
    bytesMenu := Menu new
        title: '\uBytes' replaceEscapeCharacters;
        selector: #bytes: ;
        appendItem: '1' selector: 1 ;
        appendItem: '2' selector: 2;
        appendItem: '4' selector: 4 ;
        checkItem: 1 ;
        yourself.
    menu := Menu new
        title: '\uInspect' replaceEscapeCharacters;
        appendItem: '\uInspect' replaceEscapeCharacters selector: #inspectSelection;
        appendSubMenu: radixMenu;
        appendSubMenu: bytesMenu;
        yourself.
    menu allOwners: self.
    menu disableItem: #inspectSelection.
    pane setMenu: menu!
instance: aTextPane
        "Private - Set the ASCII representation
         of the selected instance variable."
    | contents |
    instIndex isNil ifTrue: [ ^aTextPane contents: String new ].
    CursorManager execute changeFor: [
        contents := instIndex = 1
            ifTrue: [ object dumpStringBase: radix bytes: bytes ]
            ifFalse: [ ( object at: instIndex - 1 ) radix: radix ] ].
    aTextPane contents: contents!
openOn: anObject
        "Open the receiver an anObject."
    super openOn: anObject.
    radix := 16.
    bytes := 1.
    ( self paneAt: #instance: ) font: Font fixedSystemFont!   
inspect
        "Open a GraphicBrowser on the receiver."
    GraphicInspector new openOn: self! 
reportFatal: error
	"Private - report errors by informing the pane."

	self pane
		compilerError: error errorMessage
		at: error sourcePosition
		in: error sourceCode
		for: nil  " we don't have a class to pass on, fortunately, text panes don't use it"!  
compiler: aCompilerInterface
	"Porvide the receiver with knowledge of the compiler interface object that it is
	handling errors for."

	compiler := aCompilerInterface!   
pane: aTextPane
	"Set the pane in which the error message can be inserted to be <aTextPane>."

	pane := aTextPane! 
promptIfGlobal: error
        "The compiler has found a reference to an undeclared 
          variable.  If it is capitalized prompt for declaration."
    | name |
    name := error sourceCode 
                    copyFrom: error sourceRange first
                    to: error sourceRange last.
    ((compiler validAsGlobalHead: name first) and: [ Smalltalk defineGlobal: name ] )
        ifFalse: [ ^self fatalError: error ].

    self declareGlobal: name.
    error retry.!   
undeclaredAccess: error
        "The compiler has found a reference to an undeclared 
          variable.  Give user a change to declare a global."
    self promptIfGlobal: error!
pane
	"Answer the TextPane in which the error message can be inserted."

	^pane!   
declareGlobal: name
        "Private - define a global named name with value nil."
    Smalltalk at: name asSymbol put: nil!
undeclaredAssignment: error
        "The compiler has found an assignment to an undeclared 
          variable.  Give user a change to declare a global."
    self promptIfGlobal: error!  
reportWarning: error
	"Private - report warnings and let the user decide whether to continue."

	( MessageBox confirm: 'compilation warning: ',  error errorMessage, ' - continue?' )
		ifFalse: [ error retry. self reportFatal: error ].
	^self!   
runtimeIcon: anIcon
        "Private - Set the default runtime icon."
    RuntimeIcon := anIcon!
iconId
		"Answer the icon id for this window class."
	^8!   
openOn: aDebugger label: aString
        "Private - Create a new walkback window
         for aDebugger."
    ^self new
        openOn: aDebugger
        label: aString!
initWindowSize
        "Private - answer the Rectangle within which
         the Walkback window should be opened."
    | extent offset |
    extent := ( 50 * SysFontWidth ) @  ( 18 * SysFontHeight ).
    offset := ( Display extent - extent ) // 2.
    ^offset extent: extent!
resume: aButton
        "Private - Resume pushbutton pressed; close the Walkback
         and resume the debugged process."
    debugger resume!   
terminate: aPane
        "Private - the Terminate pushbutton was selected; close the
        walkback and the debugger."
    self mainView close!  
close: aPane
        "Private - the Cancel pushbutton was selected; close the
        walkback and the debugger."
    debugger closed! 
openOn: aDebugger label: labelString
        "Create the panes for the receiver, initialize,
         and display."
    | groupHeight groupPane pane |
    debugger := aDebugger.
    groupHeight := SysFont height * 3.
    self
        addView: ( ( pane := self topPaneClass new )
            label: labelString;
            foreColor: Color white;
            backColor: Color red;
            owner: self;
            when: #closed send: #close: to: self with: pane;
            noSmalltalkMenuBar ).
    self
        addSubpane: ( self textPaneClass new
            foreColor: Color white;
            backColor: Color red;
            setName: #text;
            contents: String new;
            framingBlock: [ :box | box leftTop
                extentFromLeftTop: box width @ ( box height - groupHeight ) ] ).
    self
        addSubpane: ( groupPane := GroupPane new
            foreColor: Color white;
            backColor: Color red;
            framingBlock: [ :box | ( box leftTop down: ( box height - groupHeight ) )
                extentFromLeftTop: box width @ groupHeight ] ).
    groupPane
        addSubpane: ( ( pane := Button new )
            setName: #debug;
            owner: self;
            contents: '\uDebug' replaceEscapeCharacters;
            when: #clicked send: #debug: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 2 * SysFont width @ ( SysFont height // 2 ) )
                extentFromLeftTop: 10 * SysFont width @ ( 3 * SysFont height // 2 ) ] );
        addSubpane: ( ( pane := Button new )
            setName: #resume;
            owner: self;
            contents: '\uResume' replaceEscapeCharacters;
            when: #clicked send: #resume: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 14 * SysFont width @ ( SysFont height // 2 ) )
                extentFromLeftTop: 10 * SysFont width @ ( 3 * SysFont height // 2 ) ] );
        addSubpane: ( ( pane := Button new )
            setName: #terminate;
            owner: self;
            contents: '\uTerminate' replaceEscapeCharacters;
            when: #clicked send: #terminate: to: self with: pane;
            framingBlock: [ :box | ( box leftTop rightAndDown: 26 * SysFont width @ ( SysFont height // 2 ) )
                extentFromLeftTop: 16 * SysFont width @ ( 3 * SysFont height // 2 ) ] ).
    self mainView subPaneWithFocus: ( self paneAt: #debug ).
    self openWindow!  
debug: aButton
        "Private - Debug pushbutton pressed, close the Walkback
         and open the Debugger."
    debugger debug!
evaluate: aString
	"Compile and evaluate the method, aString, in the context of
	UndefinedObject.  If the method compiles correctly, answer the
	result of evaluation.  If not, answer nil and report the error on the Transcript."
	
	^self evaluate: aString in: UndefinedObject to: nil notifying: self ifFail: [^nil]!   
initializeDefaultColors
        "Private - initialize a table entries in the default system palette."
    defaultColors := IdentityDictionary new
        at: #black put: ( self index: ClrBlack );
        at: #blue put: ( self index: ClrBlue );
        at: #brown put: ( self index: ClrBrown );
        at: #cyan put: ( self index: ClrCyan );
        at: #darkBlue put: ( self index: ClrDarkblue );
        at: #darkCyan put: ( self index: ClrDarkcyan );
        at: #darkGray put: ( self index: ClrDarkgray );
        at: #darkGreen put: ( self index: ClrDarkgreen );
        at: #darkPink put: ( self index: ClrDarkpink );
        at: #darkRed put: ( self index: ClrDarkred );
        at: #gray put: ( self index: ClrPalegray );
        at: #green put: ( self index: ClrGreen );
        at: #pink put: ( self index: ClrPink );
        at: #red put: ( self index: ClrRed );
        at: #white put: ( self index: ClrWhite );
        at: #yellow put: ( self index: ClrYellow );
        yourself!  
undeclaredAssignment: error
        "The compiler has found an assignment to an undeclared
        variable.  Declare the variable within our associated pane
        and retry the reference."
    | id |
    id := error sourceCode
        copyFrom: error sourceRange first
        to: error sourceRange last.
    id first isUpperCase ifTrue: [ ^super undeclaredAssignment: error ].
    self pane declareVariable: id.
    error retry!
inspectorFields
        "Answer the names of the fields contained in this kind of object."
    ^ExternalBuffer inspectorClass fields: self fields conversions: self conversions!
open: aClass
        "Private - Answer an instance of NewSubclassDialog
         where superclassName, subclassName, fixed,
         and pointer have been supplied by the user
         via a dialog box. aClass is the default superclass
         of the new class."
    ^self new open: aClass.!
initialize
        "Private - Initialize the item ids."
    ItemIds := Dictionary new.
    ItemIds at: 3 put: #fixed;
        at: 6 put: #byte;
        at: 1 put: #ok;
        at: 2 put: #cancel;
        at: 'superclass' put: 7;
        at: 'subclass' put: 8;
        at: 'fixed' put: 3;
        at: 'variable' put: 4;
        at: 'pointer' put: 5;
        at: 'byte' put: 6.!  
open: aClass
        "Private - Open the receiver on aClass."
    self fromModule: SmalltalkToolInterface current resourceFileName id: self class windowId.
    self setButton: (ItemIds at: 'fixed') value: aClass isFixed.
    self setButton: (ItemIds at: 'variable') value: aClass isVariable.
    self setButton: (ItemIds at: 'pointer') value: aClass isPointers.
    self setButton: (ItemIds at: 'byte') value: aClass isBytes.
    self setItemText: (ItemIds at: 'superclass')
        string: aClass name.
    self setTextLimit: (ItemIds at: 'subclass') to: 256. "arbitrary"
    self showWindow.
    self processInput!   
byte
        "Private - The user clicked the byte button."
    (self queryButton: (ItemIds at: 'byte'))
        ifTrue: [
            self setButton: (ItemIds at: 'variable') value: true.
            self setButton: (ItemIds at: 'fixed') value: false]! 
fixed
        "Private - The user clicked the fixed button."
    (self queryButton: (ItemIds at: 'fixed'))
        ifTrue: [
            self setButton: (ItemIds at: 'pointer') value: true.
            self setButton: (ItemIds at: 'byte') value: false]!
subclassName
        "Private - Answer the name of the new class."
    ^subclassName!   
isPointer
        "Private - Answer true if the new class is pointers."
    ^pointer!   
itemIds
        "Private - Answer the item ids dictionary."
    ^ItemIds!   
isFixed
        "Private - Answer true if the new class is fixed."
    ^fixed!  
superclassName
        "Private - Answer the name of the superclass."
    ^superclassName!  
ok
        "Private - The user selected OK."
    superclassName :=
        self queryItemText: (ItemIds at: 'superclass').
    subclassName :=
        self queryItemText: (ItemIds at: 'subclass').
    fixed := self queryButton: (ItemIds at: 'fixed').
    pointer := self queryButton: (ItemIds at: 'pointer').
    ^self close! 
rejectComments
        "Answer the receiver string with all of the
         embedded comments deleted."
    | input result |
    input := ReadStream on: self.
    result := input upTo: $" .
    [ input skipTo: $" ] whileTrue: [
        result := result, ( input upTo: $" ) ].
    ^result!  
inspect
        "Open a FieldInspector on the receiver."
    FieldInspector new openOn: self!   
compilerError: msg at: position in: source for: aClass
	"Private-generate a traditional style error message"

	Transcript  cr; nextPutAll: '"--- compilation error '.
	Transcript nextPutAll: ' in ' ;  nextPutAll: aClass name.
	Transcript nextPutAll: ' ---"';
		cr; nextPutAll: (source copyFrom: 1 to: (0 max: position - 1));
		cr; nextPutAll: '"' , msg trimBlanks , '--->"';
		cr; nextPutAll: (source copyFrom: (1 max: position) to: source size);
		cr; show: '"-------------------------"'! 
toggleDragDrop
        "Private - the Drag Drop menu item was selected/deselected;
         set the menu item check mark appropriately & update panes."
    | optionMenu |
    ( optionMenu := self optionsMenu ) isNil ifTrue: [ ^nil ].
    ( optionMenu isChecked: #toggleDragDrop )
        ifTrue: [ optionMenu uncheckItem: #toggleDragDrop. self class dragDropEnabled: false ]
        ifFalse: [ optionMenu checkItem: #toggleDragDrop. self class dragDropEnabled: true ].
    self dragDropSourcePanes do: [ :name |
        ( self paneAt: name ) dragSource: self class dragDropEnabled ].
    self dragDropTargetPanes do: [ :name |
        ( self paneAt: name ) dragTarget: self class dragDropEnabled ]! 
new
	"Answer an instance of the receiver."

	^super new initialize!
name
    "Answer the name of the receiver variable."

	^name!  
name: aString
	"Private - Set the name of the receiver."

	name := aString!
isArgument
    "Answer true if the data associated with this variable is
	an argument to the method or block."

	^argument!   
stack: aBoolean
	"Private - Indicate whether the receiver represents an object on the stack (as opposed to in an environment)."

	stack := aBoolean!   
isIndirect
    "Answer true if the data associated with this variable is indirectly accessed through an object stored in the environment for the current block."

	^false! 
initialize
	"Private - Init the receiver."

	stack := true!
argument: aBoolean
	"Private - Indicate whether the receiver represents an arg or a temp."

	argument := aBoolean! 
offset
    "Return the index of the value of the variable in the area where it is stored. This may be in index up or down in the stack or the index of a variable in an environment."

	^binding!  
isStackAllocated
    "Answer true if the data associated with this variable is
	stored on the smalltalk stack (as opposed to an environment)."

	^stack!  
compile: aString in: aClass notifying: requestor ifFail: exceptionBlock
    "Compile the method, aString, in aClass.  If the method compiles correctly,
    answer an Association whose key is the method selector and whose value
    is the compiled method.  If not, send the message #compilerError:at:in:for:
    to requestor; then return the result ofevaluating the exception block."

    | handler result byteCodeCompiler |
    handler := TraditionalCompilerErrorHandler new.
    byteCodeCompiler := self forClass: aClass errorHandler: handler.
    result := byteCodeCompiler compile: aString.
    ^result wasSuccessful
        ifTrue: [ self createOldResult: result in: aClass ]
        ifFalse: [
            self
                handleOldErrorResult: result
                in: aClass
                for: requestor
                return: exceptionBlock ]!
positionsOf: aString
in: aClass
notifying: requestor
ifFail: exceptionBlock
	"Answer highlighting information for, aString, in aClass.  If the method does
	not compile correctly, notify the requestor and then return the result of
	evaluating the exception block."
	| result |
	result := (self forClass: aClass) compile: aString.
	result wasSuccessful
		ifTrue:
			[^result positionNodes]
		ifFalse:
			[^self
				handleOldErrorResult: result
				in: aClass
				for: requestor
				return: exceptionBlock]!
toolWindowPolicyClass
        "Private - answer the WindowPolicy subclass that
        should be used for development tools."
    ^SmalltalkToolInterface current windowPolicyClass!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #tmHeight
        #tmAscent
        #tmDescent
        #tmInternalLeading
        #tmExternalLeading
        #tmAveCharWidth
        #tmMaxCharWidth
        #tmWeight
        #tmOverhang
        #tmDigitizedAspectX
        #tmDigitizedAspectY
        #tmFirstChar
        #tmLastChar
        #tmDefaultChar
        #tmBreakChar
        #tmItalic
        #tmUnderlined
        #tmStruckOut
        #tmPitchAndFamily
        #tmCharSet
    )!
initialize
        "Private - Initialize the class dictionary variables
         DayNames that contain the associations between
         the day name as symbols and the day indices.
         MonthNames that contain the associations between
         the month names as symbols and the month indices."
    DayNames := Dictionary new.
    DayNames
        at: #Mon put: 1;
        at: #Monday put: 1;
        at: #Tue put: 2;
        at: #Tuesday put: 2;
        at: #Wed put: 3;
        at: #Wednesday put: 3;
        at: #Thr put: 4;
        at: #Thursday put: 4;
        at: #Fri put: 5;
        at: #Friday put: 5;
        at: #Sat put: 6;
        at: #Saturday put: 6;
        at: #Sun put: 7;
        at: #Sunday put: 7.
    MonthNames := Dictionary new.
    MonthNames
        at: #Jan put: 1;
        at: #January put: 1;
        at: #Feb put: 2;
        at: #February put: 2;
        at: #Mar put: 3;
        at: #March put: 3;
        at: #Apr put: 4;
        at: #April put: 4;
        at: #May put: 5;
        at: #Jun put: 6;
        at: #June put: 6;
        at: #Jul put: 7;
        at: #July put: 7;
        at: #Aug put: 8;
        at: #August put: 8;
        at: #Sep put: 9;
        at: #September put: 9;
        at: #Oct put: 10;
        at: #October put: 10;
        at: #Nov put: 11;
        at: #November put: 11;
        at: #Dec put: 12;
        at: #December put: 12! 
setInstList
        "Private - Initialize an OrderedCollection of
         instance variable names and/or numbers for
         the list pane."
    instList := OrderedCollection new: (self size + 1).
    instList add: 'self'.
    1 to: object size do: [ :index |
        instList add: index printString]!
aboutToSaveImage
        "Private - Save the size of the frame window so the receiver
         will open with the right rectangle when the image is restarted.
         Notify the receiver's subpanes too."
    self minimized
        ifTrue: [
            collapsed := -1.
            rectangle := self framingBlock]
        ifFalse: [
            self maximized
                ifTrue: [
                    collapsed isRectangle ifTrue:[
                        rectangle := collapsed]]
                ifFalse: [
                    collapsed := 0.
                    rectangle := self frameRectangle]].
    children do: [:subpane | subpane aboutToSaveImage].
    self propertyAt: #sysMenu put: nil!
fileItIn
        "File It In was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self mainView fileItIn!
compiledMethodDefinitionClass
	"Answer the class of definition to use for the receiver, if none is known"

	^CompiledMethodDefinition! 
loadLogoBitmap
        "Private - load & answer the logo bitmap."
    ^Bitmap fromModule: SmalltalkToolInterface current resourceFileName id: 1!
loadProfessionalServicesBitmap
        "Private - load & answer the Professional Services bitmap."
    ^Bitmap fromModule: SmalltalkToolInterface current resourceFileName id: 20!  
openProfessionalServices
        "Open a dialog box telling about Professional Services."
    bitmap := self class loadProfessionalServicesBitmap.
    self createView.
    self labelWithoutPrefix: 'Professional Services'.
    self openWindow!   
close: aButton
        "Private - Ok button pushed or system menu close selected;
        close the window."
    bitmap release!   
display: aGraphPane
        "Private - display the background bitmap in aGraphPane."
    aGraphPane pen
        copyBitmap: bitmap
        from: bitmap boundingBox
        at: 0@0! 
topPaneClass
        "Private - answer the class of the receiver's TopPane."
    ^TopPane!  
open
        "Open a dialog box telling about this product."
    bitmap := self class loadLogoBitmap.
    self createView.
    self openWindow!   
matchBracketFrom: start  to: end
        "Private - Select the closest surrounding brackets."
    |left right c lookLeft lookRight leftCount rightCount |
    left := start .
    right := end .
    leftCount := rightCount := 0.
    lookLeft := LeftBrackets.
    lookRight := RightBrackets.
    [lookLeft notNil or: [lookRight notNil]] whileTrue: [
        lookLeft notNil ifTrue: [
            left := left - (1@ 0).
            left x < 1 ifTrue: [
                left := ((self endOfLine: left y - 1) + 1) @ left y - 1].
            (c := textHolder charAt: left)   notNil
                ifFalse: [lookLeft := nil. left := nil]
                ifTrue: [
                    ((lookLeft includes: c) and: [leftCount = 0])
                        ifTrue: [
                            lookRight notNil ifTrue: [
                                lookRight := String with: (
                                    lookRight at: (lookLeft indexOf: c))].
                            lookLeft := nil].
                    (LeftBrackets includes: c) ifTrue: [leftCount := leftCount - 1].
                    (RightBrackets includes: c) ifTrue: [leftCount := leftCount + 1]]].
        lookRight notNil ifTrue: [
            right := right + (1 @ 0).
            [(right x > (self endOfLine: right y)) and: [right y <= self totalLength]] whileTrue: [
                right := 1 @ (right y + 1)].
            (c := textHolder charAt: right)   notNil
                ifFalse: [lookRight := nil. right := nil]
                ifTrue: [
                    ((lookRight includes: c) and: [rightCount = 0])
                        ifTrue: [
                            lookLeft notNil ifTrue: [
                                lookLeft := String with: (
                                    lookLeft at: (lookRight indexOf: c))].
                            lookRight := nil].
                        (LeftBrackets includes: c) ifTrue: [rightCount := rightCount - 1].
                        (RightBrackets includes: c) ifTrue: [rightCount := rightCount + 1]]]].
    (left notNil and: [right notNil]) ifTrue: [self selectFrom: left" - (1@ 0)" to: right].
    self showSelection.!  
defineClassNamed: className
subclassOf: superclass
instanceVariableNames: instanceVariables
variable: isVariable
pointers: isPointers
classVariableNames: classVariables
poolDictionaries: poolDictionaries
	"Define (or redefine) the class named <className> in the default global dictionary"

	| classInstaller |
	classInstaller := self classInstallerClass
		name: className
		environment: self defaultGlobalDictionary
		subclassOf: superclass
		instanceVariableNames: instanceVariables
		variable: isVariable
		pointers: isPointers
		classVariableNames: classVariables
		poolDictionaries: poolDictionaries.
	^classInstaller install
		! 
setModuleHierarchy: anArrayOfStrings
	"The first n-1 strings in <anArrayOfStrings> define the cluster structure to be created (or used) when the library is bound into a VSE image. The nth string is the name of the package that all new methods will be loaded into."

	self metaInfo at: 'moduleHierarchy' put: anArrayOfStrings!  
sendersOf: aSymbol in: aClass
        "Open a MethodBrowser on all methods in aClass
        and its subclasses that reference aSymbol.
        aClass can be a class or a collection of classes."
    SourceManager current sendersOf: aSymbol in: aClass!   
textWindowClassDev
        "Private - answer the class of text window to use
        when running the development environment."
    ^SmalltalkToolInterface current textWindowClass!   
abortSaveImage
        "Calling this method during the #aboutToSaveImage
        processing will stop the saveImage before the file is actually written."
    VetoAction signal!   
initialize
        "Private - initialize the state of the receiver class."
    self initializePartialReadSettings.! 
setClassInstanceVariableNames: classInstanceVariables
forClass: class
	"Define the instance variables for <class> to be <classInstanceVariables>."

	| classInstaller |
	classInstaller := self classInstallerClass
		class: class
    	classInstanceVariableNames: classInstanceVariables.
	^classInstaller install
		! 
inspectorFields
        "Answer the names of the fields contained in the receiver definition;
        reimplemented by subclasses."
    ^Array new!
implementorsOf: aSymbol
        "Answer a collection of methods of the receiver and its
         subclasses that implement aSymbol."
    | methods  |
    methods := OrderedCollection new: 30.
    self withAllSubclasses do: [:class |
        (class includesSelector: aSymbol)
            ifTrue: [methods add: (class compiledMethodAt: aSymbol)].
        (class class includesSelector: aSymbol)
            ifTrue: [methods add: (class class compiledMethodAt: aSymbol)]].
    ^methods! 
inspect
        "Open an inspector window on the receiver."
    Inspector new openOn: self! 
fileIn
        "Private - read and execute the Smalltalk source code chunks
        from aStream."
    SourceManager current fileInFrom: self! 
isActivationVisibleForInstanceSelector: aSymbol
	"Return true if activation of the argument symbol sent as a message to instances of this class should be visible in the debugger. Default behavior is to hide all methods of classes with abnormal class names"

	^self name first isUpperCase
! 
buildConstantsDictionary: aFileName
        "Private - Read the #define statements from aFileName
         and answer a dictionary."
    | file key s value dict c getNext found |
    file := File pathName: aFileName.
    dict := Dictionary new.
    getNext := [:stream |
        s := String new.
        c := stream next.
        c = $_ ifTrue: [c := stream next].
        c := c asUpperCase.
        [c isSeparator not] whileTrue: [
            s := s, (String with: c).
            stream atEnd ifTrue: [c := Cr] ifFalse: [
                c := stream next].
            c = $_
                ifTrue: [c := stream next asUpperCase]
                ifFalse: [c := c asLowerCase].
            ].
        s].
    found := false.
    [file atEnd] whileFalse: [
        [found] whileFalse: [
            file skipTo: $#; countBlanks.
            (file indexOf: 'define') = 0 ifTrue: [file close. ^dict].
            found := file countBlanks > 0].
        found := false.
        key := getNext value: file.
        (c = Cr or: [key includes: $(])
            ifTrue: [value := '1']
            ifFalse: [
                file countBlanks.
                value := (file upTo: Cr) trimBlanks asUpperCase.
                file upTo: Lf.
                (value includes: $*) ifTrue: [
                    value := (value copyFrom: 1 to: (value indexOf: $/) - 1) trimBlanks].
                (value includes: Space) ifTrue: [
                    value := value copyFrom: (value indexOf: Space) + 1 to: value size].
                (value first = $( and: [value last = $)]) ifTrue: [
                    value := value copyFrom: 2 to: (value size - 1)].
                value first = $( ifTrue: [
                    value := value copyFrom: ( ( value indexOf: $) ) + 1 ) to: value size ].
                ((value last = $L) and: [value first isDigit
or: [value size > 1 and: [(value at: 2) isDigit]]]) ifTrue: [
                    value := value copyFrom: 1 to: ( value size - 1 ) ].
                ((value size > 15) and: [
                    (value copyFrom: 1 to: 15) = 'MAKEINTRESOURCE']) ifTrue: [
                    value := value copyFrom: 17 to: ( value size - 1 ) ].
                (value includes: $<) ifTrue: [
                    value := ( value copyFrom: 1 to: ( ( value indexOf: $< ) - 1 ) ),
                        ' bitShift: ',
                        ( value copyFrom: ( ( value indexOf: $< ) + 2 ) to: value size ) ].
                (value includes: $>) ifTrue: [
                    value := ( value copyFrom: 1 to: ( ( value indexOf: $> ) - 1 ) ),
                        ' bitShift: -',
                        ( value copyFrom: ( ( value indexOf: $> ) + 2 ) to: value size ) ].
                (value includes: $") ifTrue: [
                    1 to: value size do: [:i| (value at: i) = $"
                        ifTrue: [value at: i put: $']]]].
        value := getNext value: value asStream.
        (dict includesKey: value)
            ifTrue: [value := dict at: value]
            ifFalse: [
                        ((value size > 2 and: [(value at: 1) = $0]) and: [(value at: 2) = $x]) ifTrue: [
                            value := '16r', ((value copyFrom: 3 to: value size) asUpperCase)].
                        value := Compiler
                            evaluate: value
                            in: UndefinedObject
                            to: nil
                            notifying: Transcript mainView activeTextPane
                            ifFail: ["self error: 'unable to parse .h file'"]].
        (key includes: $() ifFalse: [dict at: key put: value]].
    file close.
    ^dict!  
arenaBytes: anInteger
        "Set the size in bytes of the object virtual memory to anInteger;
        default = 100 MB (100 * 1024 * 1024 = 104857600).
        This takes effect the next time the image is started."
    self uLongAtOffset: 0 put: anInteger!
paddingSizeBytes
        "Answer the amount of bytes that the garbage collector
        allocates beyond the end of old space to help recognize
        low memory situations; default = 32768"
    ^self uLongAtOffset: 32!  
flipSpaceBytes: anInteger
        "Set the size in bytes of the object memory flip space regions to
        anInteger; default = 256K (256 * 1024 = 262144).
        New and flip space regions must be the same size.
        This takes effect the next time the image is started."
    self newSpaceBytes: anInteger! 
codeSpaceMaxBytes
        "Answer the maximum size in bytes that the compiled code
        cache can be grown to."
    ^self uLongAtOffset: 24!
codeSpaceMaxBytes: anInteger
        "Set the maximum size in bytes that the compiled code
        cache can be grown to; default = 1MB (1 * 1024 * 1024 = 1048576).
        This takes effect the next time the image is started."
    self uLongAtOffset: 24 put: anInteger!
newSpaceBytes
        "Answer the size in bytes of the object memory new space."
    ^self uLongAtOffset: 4!
newSpaceBytes: anInteger
        "Set the size in bytes of the object memory flip space regions to
        anInteger; default = 256K (256 * 1024 = 262144).
        This takes effect the next time the image is started."
    self uLongAtOffset: 4 put: anInteger.  "semiSpaceA"
    self uLongAtOffset: 8 put: anInteger.  "semiSpaceB"!  
oldSpaceBytes
        "Answer the size in bytes of the object memory old space."
    ^self uLongAtOffset: 12!   
oldSpaceBytes: anInteger
        "Set the size in bytes of the old object memory space to
        anInteger; default = 72 MB (72 * 1024 * 1024 = 75497472).
        This takes effect the next time the image is started."
    self uLongAtOffset: 12 put: anInteger! 
paddingSizeBytes: anInteger
        "Set the amount of bytes that the garbage collector
        allocates beyond the end of old space to help recognize
        low memory situations; default = 32768.
        This takes effect during the next compact of object space"
    self uLongAtOffset: 32 put: anInteger.
    VirtualMachineLibrary paddingSizeBytes: anInteger!
arenaBytes
        "Answer the size in bytes of the object virtual memory."
    ^self uLongAtOffset: 0! 
toFile: pathName
        "Write the receiver into the image file named pathName."
    | fileStream |
    ( MessageBox confirm: 'The image file ', pathName printString,
        ' will be updated immediately.  Make sure you have first backed up this image file.  Continue?' )
        ifFalse: [ ^nil ].
    fileStream := ( File fromPath: pathName ) binaryWriteStream.
    fileStream position: self class imageFileOffset.
    fileStream nextPutAll: contents.
    fileStream close!
flipSpaceBytes
        "Answer the size in bytes of the object memory flip space.
         This should always be the same as newSpaceBytes"
    ^self uLongAtOffset: 8!
codeSpaceCommittedBytes: anInteger
        "Set the number of committed bytes of compiled code cache to
        anInteger; default = 256K (256 * 1024 = 262144).
        This takes effect the next time the image is started."
    self uLongAtOffset: 20 put: anInteger!
codeSpaceCommittedBytes
        "Answer the number of committed bytes of compiled code cache."
    ^self uLongAtOffset: 20! 
codeSpaceReservedBytes
        "Answer the number of reserved bytes of compiled code cache."
    ^self uLongAtOffset: 16!   
imageFileStubSize
        "Private - Answer the size of the stub portion of the image file."
    ^self uLongAtOffset: 36!   
imageFileStubSize: anInteger
        "Private - Set the size of the stub portion of the image file."
    ^self uLongAtOffset: 36 put: anInteger!
codeSpaceReservedBytes: anInteger
        "Set the number of committed bytes of compiled code cache
        to anInteger; default = 512K (512 * 1024 = 524288).
        This takes effect the next time the image is started."
    self uLongAtOffset: 16 put: anInteger! 
nominalFlipSizeBytes: anInteger
        "Set the minimum amount of bytes that the garbage collector
        must flip before objects are tenured; default = 4096.
        This takes effect immediately"
    self uLongAtOffset: 28 put: anInteger.
    VirtualMachineLibrary nominalFlipSizeBytes: anInteger!   
reserved
        "Answer the reserved bytes."
    ^self bytesAtOffset: 40 count: 984!   
reserved: aByteArray
        "Set the reserved bytes to aByteArray."
    aByteArray size > 984 ifTrue: [ ^self error: 'reserved must be 984 bytes or less' ].
    self bytesAtOffset: 40 put: aByteArray!  
nominalFlipSizeBytes
        "Answer the minimum amount of bytes that the garbage collector
        must flip before objects are tenured; default = 4096"
    ^self uLongAtOffset: 28! 
toImage
        "Write the receiver into the current image file."
    self toFile: SessionModel current imageName!  
instVarNames: instNameString
        "Obsolete - The string instNameString contains a new list
         of instance variable names separated with blanks.  Use
         this list to replace the instances array with the new
         names.  Recompute the number of named instance variables
         for instances of the receiver and instances of all the
         subclasses of the receiver."


	^self instanceVariableNames: instNameString!
variableSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
    category: categoryString
         "Create or modify the class named <className> to be a variable
         subclass of the receiver with the specified class variables
        and pool dictionaries."

	^self variableSubclass: className
   		instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
   		poolDictionaries: poolDictionaries
! 
variableByteSubclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
    category: categoryString
         "Create or modify the class named <className> to be a variable
        byte subclass of the receiver with the specified class variables
        and pool dictionaries."

	^self variableByteSubclass: className
   		instanceVariableNames: instanceVariables
    	classVariableNames: classVariables
   		poolDictionaries: poolDictionaries
! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #xLeft #yTop #xRight #yBottom ) conversions: #( #asRectangle )!  
printIt
        "Private - Evaluate the selected text.
         Display the result immediately after
         the text that was evaluated."
    | answer |
    CursorManager execute changeFor: [
        answer := ( self doIt: [ ^self ] ) printString asExternalString.
		self insertAfterSelection: ' ', answer ]! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass
		fields: #( #lowHalf #highHalf )
		conversions: #( #asBoolean #asExternalAddress #asInteger )!   
testDiskSpaceRequiredToCompressSources: backupBoolean
        "Private - check to see if there is enough available disk space for
        the requested operation, answering a Boolean which indicates whether
        there is enough disk space.  Display a message box with an error
        message if there is not enough disk space."
    | bytesRequired bytesAvailable |
    bytesRequired := self diskSpaceRequiredToCompressSources: backupBoolean.
    bytesAvailable := Disk freeDiskSpace. 
    bytesAvailable < bytesRequired ifTrue: [
        MessageBox notify: 'Error' withText: 'Compressing the change.log and sources.sml files would require at least ',
            bytesRequired printString, ' bytes of disk space on drive ', ( String with: Disk drive ), ':, and you have only ',
            bytesAvailable printString, ' bytes available.'.
        ^self ].
    ^true!   
printIt
        "Private - Evaluate the selected text.
         Display the result immediately after
         the text that was evaluated."
    | answer |
    CursorManager execute changeFor: [
        answer := ( self doIt: [ self clearMouseCapture. ^self ] ) printString.
        self isReadOnly ifTrue: [ ^self ].
        self
            selectTo: ( self replaceWithText: ' ', answer ) corner;
            hideSelection;
            displayChanges;
            forceSelectionOntoDisplay.
        modified := true.
        self clearMouseCapture ]! 
openClassBrowser
        "Private - The user selected Browse Classes from
         the File menu."
    ^ClassHierarchyBrowser new openOn: Smalltalk rootClasses!   
expressionEvaluatorClass
        "Private - answer the class of ExpressionEvaluator
        which is used if not otherwise specified."
    ^ExpressionEvaluator!   
dumpStringBase: radix
        "Answer a String which contains a dump of the receiver's bytes
        in the given radix."
    ^self dumpStringBase: radix bytes: 1!
maxInstanceVariables
		"Answer the maximum number of instance variables a class can have"

	^InstNumberMask!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #bfType
        #bfSize
        #reserved1
        #reserved2
        #offBits
    )!  
isActivationVisibleForInstanceSelector: aSymbol
	"Return true if activation of the argument symbol sent as a message to instances of this class should be visible in the debugger. All message to instance of ExceptionHandler are normally invisible"

   ^false! 
matchBracketFrom: start  to: end
        "Private - Select the closest surrounding brackets, (), []."
    | left right c lookLeft lookRight leftCount rightCount |
    left := start .
    right := end .
    leftCount := rightCount := 0.
    lookLeft := LeftBrackets.
    lookRight := RightBrackets.
    [lookLeft notNil or: [lookRight notNil]] whileTrue: [
        lookLeft notNil ifTrue: [
            left := left - 1.
            (c := self charAt: left)   notNil
                ifFalse: [lookLeft := nil. left := nil]
                ifTrue: [
                    ((lookLeft includes: c) and: [leftCount = 0])
                        ifTrue: [
                            lookRight notNil ifTrue: [
                                lookRight := String with: (
                                    lookRight at: (lookLeft indexOf: c))].
                            lookLeft := nil].
                    (LeftBrackets includes: c) ifTrue: [leftCount := leftCount - 1].
                    (RightBrackets includes: c) ifTrue: [leftCount := leftCount + 1]]].
        lookRight notNil ifTrue: [
            right := right +  1.
            (c := self charAt: right)   notNil
                ifFalse: [lookRight := nil. right := nil]
                ifTrue: [
                    ((lookRight includes: c) and: [rightCount = 0])
                        ifTrue: [
                            lookLeft notNil ifTrue: [
                                lookLeft := String with: (
                                    lookLeft at: (lookRight indexOf: c))].
                            lookRight := nil].
                        (LeftBrackets includes: c) ifTrue: [rightCount := rightCount - 1].
                        (RightBrackets includes: c) ifTrue: [rightCount := rightCount + 1]]]].
    (left notNil and: [right notNil]) ifTrue: [self selectIndexFrom: left - 1 to: right]!   
fields
        "Answer the names of the fields contained in this kind of object."
    ^#(
        #bytesAllocated
        #bytesFree
        #byteSize
        #rootDirectory
        #volume
        #volumeLabel
    )!
install
        "The user selected Install... from the File menu."
    self mainView install!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #(
        #cBytes
        #fFixedDisk
        #nErrCode
        #reserved1
        #reserved2
        #szPathName
    )!
fileItIn
        "Private - Compile and evaluate the selected
         text (in change log format)."
    | lineIndex aString |
    CursorManager execute changeFor: [
        ( aString := self selectedItem ) isEmpty
            ifTrue: [
                lineIndex := selection origin y.
                aString := textHolder lineAt: lineIndex.
                selection origin: 1 @ lineIndex corner: aString size @ lineIndex.
                selection display ].
        ( ReadStream on: aString ) fileIn.
        self
            hideSelection;
            selectAfter: self selection corner;
            forceSelectionOntoDisplay ]!  
compilerError: aString at: anInteger in: codeString for: aClass
        "Private - The compiler detected an error when attempting
        to compile the contents of the receiver.  Display the
        error message in the entry field."
    | pane |
    pane := self paneAt: #text.
    pane
        insertSelectedText: aString
        at: anInteger!   
addSingleQuotes
        "Private - Bracket the selected text in a pair of
        single quotes."
    self addLeftBracket: $' rightBracket: $'!
doIt
        "Private - Compile and execute the selected text.
         If no error, log it on the change log."
    CursorManager execute changeFor: [ self doIt: [ ^self ] ]! 
sourceIndex
        "Answer the index into the Sources array (a global
         variable) describing the file containing the
         receiver source code: 1 for source file,
         2 for change log."
    ( sourceObject isNil or: [ sourceObject isInteger not ] ) ifTrue: [ ^0 ].
    ^sourceObject at: 1 " gets the LSB "!  
fields
		"Answer the names of the fields contained in this kind of object."
    ^super fields, #( #name )!  
initialize
        "Private - initialize the class variables of the receiver."
    Open := false!   
doIt: aBlock
        "Private - Compile and execute the selected text.
         If no error, log it on the change log
         and answer the result of the evaluation,
         else perform the aBlock."
    | aString answer |
    self setEvaluate: true.
    ( aString := self selectedItem ) isEmpty ifTrue: [
        self selectLineAtCurrentSelection.
        aString := self selectedItem ].
    answer := self expressionEvaluator evaluate: aString ifError: aBlock.
    self selectAfter: selection y.
    ^answer! 
inspectorClass
		"Answer the class of inspector to use for this kind of object."
	^FieldInspector!  
aboutToSaveImage
        "Private - Save the receiver's value so it can be restored
         when the image is restarted."
    super aboutToSaveImage.
    self getValue! 
methods
        "Answer an instance of ClassReader
         initialized for the receiver."
    ^ClassReader forClass: self!
inspect
        "Open a FieldInspector on the receiver."
    FieldInspector new openOn: self!   
inspectorFields
        "Answer the names of fields in the receiver."
    | sortedFields |
        "sort definitions by offset"
    sortedFields := SortedCollection sortBlock: [ :a :b |
        ( a value at: 1 ) <= ( b value at: 1 ) ].
    self definition associationsDo: [ :a | sortedFields add: a ].
    ^self class inspectorClass fields: ( ( sortedFields asArray collect: [ :a | a key ] ) reject: [ :s | s last == $: ] )!   
addHelpManager
        "Private - add the help manager instance."
    | helpFilePath |
    helpFilePath := SmalltalkToolInterface current helpDirectoryName, '\',
        SmalltalkToolInterface current helpFileNames first.
    HelpManager
        for: self mainView
        title: 'Help for ', WindowLabelPrefix
        file: helpFilePath
        dialogs: Array new
        aboutDlgClass: self aboutDialogClass.
    self mainView when: #help send: #help to: self! 
fromExe: fileName id: aResourceId
        "Extract the icon with id = aResourceId from the executable
        file named fileName; answer the icon."
    | binder icon |
    ( Smalltalk includesKey: #Coff )
        ifFalse: [ binder := SmalltalkLibraryBinder bindTo: 'vcoff', SmalltalkLibrary versionAndPlatformExtension ].
    icon := self privateFromExe: fileName id: aResourceId.
    binder notNil ifTrue: [ binder unBind ].
    ^icon! 
privateChangeSuperclassTo: aClass
        "Private - change the superclass of the receiver to be <aClass>.
		Don't use this message: improper usage can cause the system
		 to break in non-obvious ways."
    | superMeta |
    super privateChangeSuperclassTo: aClass.
    self allSubclasses do: [ :c |
        c recomputeMethodArray].
    aClass == nil
        ifTrue: [superMeta := Object class superclass]
        ifFalse: [superMeta := aClass class].
    self class privateChangeSuperclassTo: superMeta!   
for: dictionary
	"Create a new instance that maps the argument dictionary"
    ^self new dictionary: dictionary!
defaultDictionaryClass
	"Private-Return the class of dictionary to use to contain the bindings
	if one is explicitly specified"
    ^Dictionary!   
dictionary: dictionary
	"make dict be the dictionary that is managed by this scope"
	self setDict: dictionary!  
removeLocalBindingFor: id
    "Private - f this environment has a binding for id, remove it"

    self dictionary removeKey: id ifAbsent: []!  
setDict: d
	"Private - assignment accessor for instance variable dict"
    dict := d!   
localBindingFor: id
    "Private - f this environment has a binding for id, return the bound value,
     otherwise return: self unbound"

    ^self dictionary at: id ifAbsent: [self unbound]!   
dictionary
	"return the dictionary that this scope maps to"
    ^self getDict!  
localBind: id to: compilerInfo
        "Private - add an binding to the local scope for id with valueinfo"
	"Implemented by placing an entry into the mapped dictionary"

	self dictionary at: id put: compilerInfo!  
getDict
	"Private - state accessor for instance variable dict.  Default its value to a
	new dictionary"

    dict == nil ifTrue: [dict := self class defaultDictionaryClass new].
    ^dict! 
inspectIt
        "Inspect It was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self activeTextPane notNil
        ifTrue: [ self activeTextPane inspectIt ]!
initialize
        "Private - Initialize the class."
    UnderScoreChar := $&.
    AuxUnderScoreChar := $~!
reportWarning: anError
	"Private-tell the user about the error"
	"SilentErrorHandlers do this silently"

	^self halt! 
methodsFor: category
    "Private - this method is part of the development environment and cannot be relied on in a run-time image.    Answer an instance of ClassReader initialized for the receiver."

    | reader |
    reader := ClassReader forClass: self.
    reader category: category.
    ^reader!   
expressionEvaluator
        "Answer the instance of ExpressionEvaluator (or subclass)
        which handles evaluations."
    ^self
        propertyAt: #expressionEvaluator
        ifAbsentPut: [ self expressionEvaluatorClass on: self ]!
isLogSourcePossible: sourceString
        "Private - Answer true if there is enough disk space to write
         the sourceString into the change log, otherwise answer false."
    ( (Sources at: 2) file directory freeDiskSpace > (sourceString asExternalString size + 100) )
        ifTrue: [ ^true ].
    Warning signal: 'Insufficient disk space to log changes.
Please free some space and try again.'.
    ^false!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^self inspectorClass fields: #( #version #numEntries #entries )! 
isActivationVisibleForClassSelector: aSymbol
   "Return true if activation of the argument symbol sent as a message to this class should be visible in the debugger.  All class message to ExceptionHandler are normally invisible"

   ^false!
fileItIn
        "Private - Compile and evaluate the selected
         text (in change log format)."
    CursorManager execute changeFor: [
        ( ReadStream on: self selectedItem ) fileIn.
        self selectAfter: selection y ]!
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^super inspectorFields, #( #colorTable )!
aboutToSaveImage
        "Private - clear cached SystemColors & SystemValues."
    self
        initializeSystemValues;
        initializeSystemColors!   
compileAllSubclasses
        "Private - Recompile all the methods defined
         in the receiver or any of its subclass."
     self allSubclasses do: [ :each |
        (each name first = $ )
            ifFalse: [each compileAll]].!   
aboutToSaveImage
        "Private - Save the receiver's value
        so it can be restored when the image
        is restarted."
    super aboutToSaveImage.
    self isHandleOk ifTrue: [ modified := self modified ]! 
windowId
        "Answer the dialog id of the NewSubclassDialog."
    ^'NewClass'!  
allMethodsUsingClassVar: varName
        "Answer a Set of all methods that uses the class variable varName."
    | literal |
    ( Array with: self classPool ), ( self allSuperclasses collect: [ :each | each classPool ] )
        do: [ :pool |
            ( pool includesKey: varName )
                ifTrue: [
                    literal := pool associationAt: varName.
                    ^self methodDictionary inject: Set new into:  [ :result :method |
                        ( method includes: literal ) ifTrue: [ result add: method].
                        result ] ] ].
    ^Set new!  
fields
		"Answer the names of the fields contained in this kind of object."
    ^super fields, #(
		#entities
		#entityNames
		#directories
		#directoryNames
		#files
		#fileNames )!
toolTextPaneClass
        "Private - answer the TextPane class that
        should be used for development tools."
    ^SmalltalkToolInterface current textPaneClass!  
for: dictionary bindingClass: aClass
	"Create a new instance that maps the argument dictionary.
	Return instances of aClass when a binding is requested"

    ^self new dictionary: dictionary bindingClass: aClass!  
for: dictionary bindingClass: aClass description: aString
	"Create a new instance that maps the argument dictionart.
	Return instances of aClass when a binding is requested"

    ^(self new dictionary: dictionary bindingClass: aClass)
			description: aString!  
hasSymbolKeys
	"Return true if the 'pool' dictionary for this scope uses symbols as keys"
	^containsSymbols==true!  
localBindingFor: id
    "Private - if this environment has a binding for id, return the bound value,
     otherwise return: self unbound"
	|b key |
	
	key := self hasSymbolKeys ifTrue: [id asExistingSymbolOrNil] ifFalse: [id]. 
	key == nil ifTrue: [^self unbound].
	b := self dictionary associationAt: key ifAbsent: [^self unbound].
    ^self bindingClass new association: b!   
setBindingClass: c
    "Private - this is the assignment accessor for the instance variable bindingClass"
	bindingClass := c!   
bindingClass
	"Private-Return the class of bindings return by this scope"
	^self getBindingClass!   
useSymbolKeys
	"specify the the associated dictionary uses symbols for its keys."
	containsSymbols := true! 
getBindingClass
    "Private - this is an accessor for the instance variable bindingClass"
	^bindingClass!  
dictionary: d bindingClass: c
	"Private-Set the dictionary and binding class used by this scope"
	self dictionary: d.
	self bindingClass: c!   
bindingClass: c
	"Private-Set the class of bindings return by this scope"
	self setBindingClass: c! 
fileItIn
        "File It In was selected from the Smalltalk menu; pass on the request
        to the active TextPane."
    self activeTextPane notNil
        ifTrue: [ self activeTextPane fileItIn ]!  
name: newName
    environment: aSystemDictionary
    subclassOf: superclass
    instanceVariableNames: instVarNames
    variable: variableBoolean
    words: wordBoolean
    pointers: pointerBoolean
    classVariableNames: classVarNames
    poolDictionaries: poolNames
    comment: commentString
    changed: changed
        "Private - Create or modify the class and the metaclass
         of name newName to be as defined by the arguments."
    | answer |
    (aSystemDictionary includesKey: newName)
        ifTrue: [
            answer := aSystemDictionary at: newName.
            answer superclass == superclass
                ifFalse: [answer privateChangeSuperclassTo: superclass]]
        ifFalse:
            [answer := self basicNew.
            superclass isNil
                ifTrue:
                    [answer superclass: nil]
                ifFalse:
                    [superclass addSubclass: answer.
                    self superclass addSubclass: self].
            answer
                initializeClass;
                privateRename: newName in: aSystemDictionary].
    answer
        pointer: pointerBoolean word: wordBoolean variable: variableBoolean;
        setInstVarNames: instVarNames;
        setClassVarNames: classVarNames;
        setSharedPools: poolNames.
    self instanceClass: answer.
    answer logDefinition.
    ^answer! 
aboutToSaveImage
        "Private - Save the essential information
         so that the image can be restarted.
         Default is do nothing."!  
expressionEvaluator: anExpressionEvaluator
        "Set the instance of ExpressionEvaluator (or subclass)
        which handles evaluations."
    anExpressionEvaluator pane: self.
    self propertyAt: #expressionEvaluator put: anExpressionEvaluator! 
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
	isVariable: variableBoolean
	isPointers: pointersBoolean
        "Private - Create or modify the class named <className> to be a
        subclass of the receiver with the specifed instance variables,
        class variables, pool dictionaries, and indexable state"

	^DefinitionInstaller current
        defineClassNamed: className
        subclassOf: self
        instanceVariableNames: instanceVariables
        variable: variableBoolean
        pointers: pointersBoolean
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries! 
sourceLibraryOrdinal
    "Answer the index of the library containing the source code."

    ^SmalltalkLibraryBinder sourceIndexFor: self sourceLibrary!
addLeftBracket: leftBracketChar rightBracket: rightBracketChar
        "Private - Put parens around the selection."
    | sel |
    self getSelection.
    sel := selection.
    self selectBefore: sel x.
    self insertAfterSelection: ( String with: leftBracketChar ).
    self selectAfter: sel y + 1.  "add 1 to compensate for added left bracket"
	self insertAfterSelection: ( String with: rightBracketChar ).
    self selectIndexFrom: sel x - 1 to: sel y + 2! 
initialize
        "Private - Initialize class
         variables."
    WildcardChar := $*!
edit
        "Open a ClassBrowser window on the receiver."
    ClassBrowser new openOn: self!   
inspect
        "Open an ordered collection inspector window on
         the receiver."
    OrderedCollectionInspector new openOn: self!   
inspect
        "Open a GraphicBrowser on the receiver."
    GraphicInspector new openOn: self! 
aboutToSaveImage
        "Private - Pass this event on to the receiver's children."
    self destroyPopup.
    children size ~= 0 ifTrue: [
        children do: [ :each |
            each aboutToSaveImage ] ]!
purgeUnusedIcons
        "Obsolete - No longer needed due to finalization."! 
inspectIt
        "Private - Open an inspector on the result of evaluating
         the selected text."
    CursorManager execute changeFor: [
        ( self doIt: [ ^self ] ) inspect ]!
subclass: className
    instanceVariableNames: instanceVariables
    classVariableNames: classVariables
    poolDictionaries: poolDictionaries
	isVariable: variableBoolean
	isPointers: pointersBoolean
        "Private - Create or modify the class named <className> to be a
        subclass of the receiver with the specifed instance variables,
        class variables, pool dictionaries, and indexable state"

	^DefinitionInstaller current
        defineClassNamed: className
        subclassOf: self
        instanceVariableNames: instanceVariables
        variable: variableBoolean
        pointers: pointersBoolean
        classVariableNames: classVariables
        poolDictionaries: poolDictionaries! 
aboutToSaveImage
        "Private - the image is about to be saved, so raise an event"
    self event: #aboutToSaveImage.
    ^super aboutToSaveImage! 
positionsOf: aString
in: aClass
	"Answer highlighting information for, aString, in aClass. "
	|handler result|
	handler := NonInteractiveErrorHandler new contextDescription: aClass name.
	result := (self forClass: aClass errorHandler: handler) compile: aString.
	result wasSuccessful
		ifTrue: [^result positionNodes]
		ifFalse: [^nil]! 
referencesTo: globalSymbol
        "Open a MethodBrowser on all methods
        referencing the global named globalSymbol."
    SourceManager current referencesTo: globalSymbol!  
initializeCursorKeys
        "Private - initialize CursorKeys class variable."
    CursorKeys := Set new
        add: LeftKey;
        add: RightKey;
        add: UpKey;
        add: DownKey;
        add: PageUpKey;
        add: PageDownKey;
        add: HomeKey;
        add: EndKey;
        yourself! 
sourcePosition
        "Answer the file position of the
         source code for the receiver."
    ( sourceObject isNil or: [ sourceObject isInteger not ] ) ifTrue: [ ^0 ].
    ^sourceObject bitShift: -8! 
sendersOf: aSymbol
        "Answer a collection of methods of myself and my
        subclasses that send aSymbol."
    | methods special |
    methods := OrderedCollection new: 30.
    special := CompiledMethod specialSelectors includesKey: aSymbol.
    self withAllSubclasses do: [:class |
        class methodDictionary do: [:method |
            special
                ifTrue: [
                    ( method referencesSpecial: aSymbol )
                        ifTrue: [ methods add: method ] ]
                ifFalse: [
                    ( ( method references: aSymbol ) and: [ method selector ~= #Doit ] )
                        ifTrue: [ methods add: method ] ] ].
        class class methodDictionary do: [:method |
            special
                ifTrue: [
                    ( method referencesSpecial: aSymbol )
                        ifTrue: [ methods add: method ] ]
                ifFalse: [
                    ( method references: aSymbol )
                        ifTrue: [ methods add: method ] ] ] ].
    ^methods!   
initialize
        "Private - initialize the class variables of the receiver."
    Smalltalk at: #StackOffsets put: ( Dictionary new
        at: 'MethodOffset' put: -2;
        at: 'ArgumentOffset' put: 2;
        at: 'ContextOffset' put: -4;
        at: 'ReceiverOffset' put: -1;
        at: 'ReturnOffset' put: 1;
        at: 'TemporaryOffset' put: -2;
        at: 'ContextTemp' put: 6;
        yourself ).
    DropStack := false!   
inspect
        "Open an inspector window on the receiver."
    self basicInspect!  
implementorsOf: aSymbol
        "Open a MethodBrowser on all methods
        named aSymbol."
    SourceManager current implementorsOf: aSymbol!
openClassBrowser
        "The user selected Browse Classes from the Smalltalk
        menu."
    self mainView openClassBrowser!   
implementorsOf: aSymbol in: aClass
        "Open a MethodBrowser on all methods
        named aSymbol in aClass and its subclasses.
        aClass can be a class or a collection of classes."
    SourceManager current implementorsOf: aSymbol in: aClass!  
openServiceManagerWindow
        "Private - The user selected Browse Services from the Smalltalk menu."
    SmalltalkToolInterface current serviceManagerWindowClass open!  
getAllInstances
        "Private - Answer all instances of Icon and its subclasses ( if any )."
    | icons iconClasses |
    iconClasses := self withAllSubclasses.
    icons := Array new.
    Smalltalk unusedMemory.     "force a garbage collect."
    iconClasses do: [ :each |
        icons := icons, each allInstancesPrim ].
    ^icons!
dumpOn: aStream base: radix bytes: oneTwoFour
        "Dump the receiver's bytes onto aStream using
        the given radix, and oneTwoFour specifying the number
        of bytes per chunk."
    | fieldWidth string lineLength columnIndex byte asciiStream byteValues |
    byteValues :=  #( 1 256 65536 16777216 ).
    lineLength := 16.
    fieldWidth := ( ( ( 2 raisedToInteger: oneTwoFour * 8 ) - 1 ) radix: radix showRadix: false ) size.
    columnIndex := 0.
    1 to: self size by: oneTwoFour do: [ :byteIndex |
        byte := 0.
        1 to: oneTwoFour do: [:i |
            byteIndex + i - 1 > self size ifFalse: [
                byte := byte + ( ( self at: byteIndex + i - 1 ) * ( byteValues at: i ) ) ] ].
        byteIndex - 1 \\ lineLength = 0 ifTrue: [
            asciiStream := String new asStream.
            string := byteIndex  - 1 printPaddedWith: $0 to: 4 base: 16.
            aStream nextPutAll: '<16r', string, '>  ' ].
        string := byte printPaddedWith: $0 to: fieldWidth base: radix.
        aStream nextPutAll: string, ' '.
        byteIndex \\ 4 = 0 ifTrue: [ aStream nextPutAll: ' ' ].
        1 to: oneTwoFour do: [:i |
            byteIndex + i - 1 > self size ifFalse: [
                byte := self at: byteIndex + i - 1.
                asciiStream nextPut: ( byte < 32 ifTrue: [ $. ] ifFalse: [ byte asCharacter ] ) ] ].
        byteIndex + oneTwoFour - 1 \\ lineLength = 0 ifTrue: [
            aStream nextPutAll: ' ', asciiStream contents; cr ] ].

    self size \\ lineLength = 0 ifFalse: [
        self size + 1 to: ( self size + lineLength truncateTo: lineLength ) do: [ :byteIndex |
            aStream nextPutAll: ( ( String new: fieldWidth + 1 ) atAllPut: $ ).
            byteIndex \\ 4 = 0 ifTrue: [ aStream nextPutAll: ' ' ] ].
        aStream nextPutAll: ' ', asciiStream contents ]! 
sendersOf: aSymbol
        "Open a MethodBrowser on all methods
        that reference aSymbol."
    SourceManager current sendersOf: aSymbol! 
openDiskBrowser
        "The user selected Browse Disk from the Smalltalk
        menu."
    self mainView openDiskBrowser!
initialize
        "Private - initialize class variables."
    self initializeCursorKeys.
    self initializeControlKeys!  
compile: codeString
        "Compile the Smalltalk method contained in codeString.
         The class to use for resolving variables is the receiver.
         If there are no errors, add the method to the receiver
         messageDictionary and answer the Association with the
         message selector as the key and the compiled method
         as the value.  If there is an error, answer nil."
    | answer |
    ( self isLogSourcePossible: codeString )
        ifFalse: [ Notification signal: 'Abort Compilation'. ^nil ].
    answer := CompilerInterface
        compile: codeString
        in: self.
    answer notNil
        ifTrue: [ self addSelector: answer key withMethod: answer value ].
    ^answer!