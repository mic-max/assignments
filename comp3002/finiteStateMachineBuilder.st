
Object subclass: #FiniteStateMachineBuilder
  instanceVariableNames: 
    ' parser tree map '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Example Parser Users'
!


!FiniteStateMachineBuilder class methodsFor: 'instance creation'!
   
new

    ^super new initialize! !

!FiniteStateMachineBuilder class methodsFor: 'raw tables'!
   
rawParserTables
    "FiniteStateMachineBuilder rawParserTables"
    self halt: 'Task 1: Copy the SMALLTALK portion of fsmBuildingParserTables.txt over #() below'.
    ^#()!

rawScannerTables
    "FiniteStateMachineBuilder rawScannerTables"
    self halt: 'Task 2: Copy the SMALLTALK portion of fsmBuildingScannerTables.txt over #() below'.
    ^#()! !

!FiniteStateMachineBuilder class methodsFor: 'examples'!
  
promptForFiniteStateMachines
    "FiniteStateMachineBuilder promptForFiniteStateMachines"
    | fileName file |
    fileName :=  FileDialog promptTitle: 'File of finite state machines'.
    fileName isNil ifTrue: [^self]. "User cancelled"
    Transcript cr; cr; << 'Building finite state machines for file '; << fileName printString.
    file := File pathNameReadOnly: fileName.
    ^FiniteStateMachineBuilder new process: file contents! !


!FiniteStateMachineBuilder methodsFor: 'initializing'!
  
initialize
    parser := Parser new.
    map := Dictionary new.
    self setupSponsorAndTables.!
 
setupSponsorAndTables
    "The compiler needs a parser and a scanner for it's language to be set up."
    | parsingTables |
    
    "Set up the user (or sponsor) of the scanner and parser."
    parser sponsor: self. parser scanner sponsor: self.
    
    "Give the keywords to the screener and the remaining tables to the parser..."
    parsingTables := self class rawParserTables.
    parser screener keywords: parsingTables first rest.
    parser tables: parsingTables rest.
    
    "Give the entire set of scanner tables to the scanner..."
    parser scanner tables: self class rawScannerTables.! !

!FiniteStateMachineBuilder methodsFor: 'processing'!

process: text
    tree := parser parse: text.
    self walkTree: tree!

walkTree: aTree
    ^self perform: aTree label with: aTree! !

!FiniteStateMachineBuilder methodsFor: 'tree walking'!

walkList: aTree
    "Note: Since none of the walk routines are there (except this one), running will stop as soon
    as a new one that you must implement is reached."
    
    | name fsm outputIndex |
    "If there is too much output, just change the index. If it's 10, you start outputting at fsm 10."
    outputIndex := 1. self halt: 'Task 4: Take a look at the tree...'.
    
    1 to: aTree children size by: 2 do: [:index |
        "Child index must be a walkIdentifier: token and child index+1 must be a finite state machine tree."
        name := (aTree child: index) symbol.
        fsm := self walkTree: (aTree child: index+1).
        (index+1)/2  >= outputIndex ifTrue: [
            Transcript cr; << 'FSM for '; << name; << ' = '; cr; << fsm].
        map at: name put: fsm].! !

!FiniteStateMachineBuilder methodsFor: 'semantic actions'!

processTypeNow: parserOrScanner    
    self halt: 'Task 3: What''s the parameter? It tells you if you are processing a parser or a scanner'! !

FiniteStateMachineBuilder comment: ''!
