

Object subclass: #SampleCompiler
  instanceVariableNames: 
    ' parser tree codeIfCompiler expressionsIfEvaluator compilationOperatorMap evaluationOperatorMap '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Compiler/Evaluator'
!

Object subclass: #Table
  instanceVariableNames: 
    ' transducer '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Table subclass: #AcceptTable
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Table subclass: #SemanticTable
  instanceVariableNames: 
    ' action parameters goto '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Table subclass: #ShiftbackTable
  instanceVariableNames: 
    ' shift goto '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Table subclass: #TableWithTransitions
  instanceVariableNames: 
    ' transitions '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

TableWithTransitions subclass: #ReadaheadTable
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

TableWithTransitions subclass: #ReadbackTable
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

TableWithTransitions subclass: #ReduceTable
  instanceVariableNames: 
    ' nonterminal '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

TableWithTransitions subclass: #ScannerReadaheadTable
  instanceVariableNames: ''
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Object subclass: #Token
  instanceVariableNames: 
    ' label symbol '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Object subclass: #Transducer
  instanceVariableNames: 
    ' sponsor tables '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Transducer subclass: #Parser
  instanceVariableNames: 
    ' scanner screener tokenStack tableNumberStack treeStack left right tableNumber newTree '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Transducer subclass: #Scanner
  instanceVariableNames: 
    ' input token keptCharacters '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Transducer subclass: #Screener
  instanceVariableNames: 
    ' keywords '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Object subclass: #Tree
  instanceVariableNames: 
    ' label children '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Scanner/Parser'
!

Object subclass: #SampleCompiler
  instanceVariableNames: 
    ' parser tree codeIfCompiler expressionsIfEvaluator compilationOperatorMap evaluationOperatorMap '
  classVariableNames: ''
  poolDictionaries: ''
  category: 'Compiler/Evaluator'
!


!SampleCompiler class methodsFor: 'instance creation'!

new

    ^super new initialize! !

!SampleCompiler class methodsFor: 'raw tables'!
  
rawParserTables
    "Tables generated from GrammarBuilder class>>parserGrammar"
    ^
#(
   (keywords where)
   (ReadaheadTable 1 (Integer 'RSN' 27) (Identifier 'RSN' 4) ('(' 'RS' 5))
   (ReadaheadTable 2 ('+' 'RS' 6) (EndOfFile 'L' 24))
   (ReadaheadTable 3 ('*' 'RS' 7) ('+' 'L' 25) (EndOfFile 'L' 25) (';' 'L' 25) (')' 'L' 25) (',' 'L' 25))
   (ReadaheadTable 4 ('(' 'RS' 8) ('=' 'RS' 9) ('+' 'L' 27) ('*' 'L' 27) (EndOfFile 'L' 27) (';' 'L' 27) (')' 'L' 27) (',' 'L' 27))
   (ReadaheadTable 5 (Integer 'RSN' 27) (Identifier 'RSN' 11) ('(' 'RS' 5))
   (ReadaheadTable 6 (Identifier 'RSN' 11) ('(' 'RS' 5) (Integer 'RSN' 27))
   (ReadaheadTable 7 (Identifier 'RSN' 11) ('(' 'RS' 5) (Integer 'RSN' 27))
   (ReadaheadTable 8 (')' 'RS' 31) (Integer 'RSN' 27) (Identifier 'RSN' 11) ('(' 'RS' 5))
   (ReadaheadTable 9 (Integer 'RSN' 27) (Identifier 'RSN' 11) ('(' 'RS' 5))
   (ReadaheadTable 10 (')' 'RS' 28) ('+' 'RS' 6))
   (ReadaheadTable 11 ('(' 'RS' 8) ('+' 'L' 27) ('*' 'L' 27) (EndOfFile 'L' 27) (';' 'L' 27) (')' 'L' 27) (',' 'L' 27))
   (ReadaheadTable 12 ('*' 'RS' 7) ('+' 'L' 29) (EndOfFile 'L' 29) (';' 'L' 29) (')' 'L' 29) (',' 'L' 29))
   (ReadaheadTable 13 ('+' 'RS' 6) (',' 'RS' 15) (')' 'RS' 31))
   (ReadaheadTable 14 ('+' 'RS' 6) (';' 'RS' 16))
   (ReadaheadTable 15 (Integer 'RSN' 27) (Identifier 'RSN' 11) ('(' 'RS' 5))
   (ReadaheadTable 16 (Identifier 'RSN' 18) (EndOfFile 'L' 32))
   (ReadaheadTable 17 ('+' 'RS' 6) (',' 'RS' 15) (')' 'RS' 31))
   (ReadaheadTable 18 ('=' 'RS' 9))
   (ReadbackTable 19 (('(' 8) 'RS' 22) ((Expression 13) 'RSN' 33) ((Expression 17) 'RSN' 34))
   (ReadbackTable 20 ((Expression 10) 'RSN' 39) ((Expression 17) 'RSN' 39) ((Expression 2) 'RSN' 39) ((Expression 13) 'RSN' 39) ((Expression 14) 'RSN' 39))
   (ReadbackTable 21 ((Term 12) 'RSN' 40) ((Term 3) 'RSN' 40))
   (ReadbackTable 22 ((Identifier 4) 'RSN' 41) ((Identifier 11) 'RSN' 41))
   (ReadbackTable 23 ((Identifier 4) 'RSN' 42) ((Identifier 18) 'RSN' 32))
   (ShiftbackTable 24 1 36)
   (ShiftbackTable 25 1 35)
   (ShiftbackTable 26 1 37)
   (ShiftbackTable 27 1 38)
   (ShiftbackTable 28 3 38)
   (ShiftbackTable 29 2 20)
   (ShiftbackTable 30 2 21)
   (ShiftbackTable 31 1 19)
   (ShiftbackTable 32 3 23)
   (ShiftbackTable 33 1 22)
   (ShiftbackTable 34 3 22)
   (ReduceTable 35 Expression (1 'RSN' 2)(5 'RSN' 10)(8 'RSN' 13)(9 'RSN' 14)(15 'RSN' 17))
   (ReduceTable 36 Grammar (1 'RSN' 43))
   (ReduceTable 37 Term (1 'RSN' 3)(5 'RSN' 3)(6 'RSN' 12)(8 'RSN' 3)(9 'RSN' 3)(15 'RSN' 3))
   (ReduceTable 38 Primary (1 'RSN' 26)(5 'RSN' 26)(6 'RSN' 26)(7 'RSN' 30)(8 'RSN' 26)(9 'RSN' 26)(15 'RSN' 26))
   (SemanticTable 39 buildTree: '+' 35)
   (SemanticTable 40 buildTree: '*' 37)
   (SemanticTable 41 buildTree: send 38)
   (SemanticTable 42 buildTree: '<-' 36)
   (AcceptTable 43))!

rawScannerTables
    "Scanner rawScannerTables"

    "EndOfFileCharacter is 256"
    "Tables for scanner10a.'."
    ^#(
   (ScannerReadaheadTable 1 ((256) 'L' 5) (')' 'RK' 7) ('*' 'RK' 8) ('+' 'RK' 9) (',' 'RK' 10) ('0123456789' 'RK' 2) ('(' 'RK' 6) (';' 'RK' 12) ('=' 'RK' 13) ('ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz' 'RK' 3) ((9 10 12 13) 'R' 4) (' ' 'R' 4))
   (ScannerReadaheadTable 2 ((9 10 12 13 256) 'L' 11) ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_+*=[]{}()^;#:.$ ' 'L' 11) ('0123456789' 'RK' 2))
   (ScannerReadaheadTable 3 ((9 10 12 13 256) 'L' 14) ('+*=[]{}()^;#:.$ ' 'L' 14) ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz' 'RK' 3))
   (ScannerReadaheadTable 4 ((256) 'L' 1) ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789+*=[]{}()^;#:.$' 'L' 1) ((9 10 12 13) 'R' 4) (' ' 'R' 4))
   (SemanticTable 5 buildToken: EndOfFile 1)
   (SemanticTable 6 buildToken: '(' 1)
   (SemanticTable 7 buildToken: ')' 1)
   (SemanticTable 8 buildToken: '*' 1)
   (SemanticTable 9 buildToken: '+' 1)
   (SemanticTable 10 buildToken: ',' 1)
   (SemanticTable 11 buildToken: Integer 1)
   (SemanticTable 12 buildToken: ';' 1)
   (SemanticTable 13 buildToken: '=' 1)
   (SemanticTable 14 buildToken: Identifier 1))! !

!SampleCompiler class methodsFor: 'examples'!
   
evaluateExample1
    "SampleCompiler evaluateExample1"
    ^SampleCompiler new evaluate: '1+ 2*3'!

compileExample1
    "SampleCompiler compileExample1"
    ^SampleCompiler new compile: '1+ 2*3'!
   
promptForEvaluation
    "SampleCompiler promptForEvaluation"
    ^SampleCompiler new 
        evaluate: (Prompter prompt: 'Expression to compile' default: '1+ 2*3')!

promptForCompilation
    "SampleCompiler promptForCompilation"
    ^SampleCompiler new 
        compile: (Prompter prompt: 'Expression to compile' default: '1+ 2*3')! !


!SampleCompiler methodsFor: 'initializing'!

initialize
    parser := Parser new.
    self setupSponsorAndTables.
    codeIfCompiler := WriteStream on: (String new: 1000).
    expressionsIfEvaluator := Dictionary new. "each key is a variable"
    compilationOperatorMap := Dictionary new
        at: #+ put: #compilePlus:;
        at: #- put: #compileMinus:;
        at: #* put: #compileMultiply:;
        at: #/ put: #compileDivide:;
        at: #'<-' put: #compileAssign:;
        at: #'Identifier' put: #compileIdentifier:;
        at: #'Integer' put: #compileInteger:;
        at: #'send' put: #compileFunctionCall:;
        yourself.
    evaluationOperatorMap := Dictionary new
        at: #+ put: #evaluatePlus:;
        at: #- put: #evaluateMinus:;
        at: #* put: #evaluateMultiply:;
        at: #/ put: #evaluateDivide:;
        at: #'<-' put: #evaluateAssign:;
        at: #'Identifier' put: #evaluateIdentifier:;
        at: #'Integer' put: #evaluateInteger:;
        at: #'send' put: #evaluateFunctionCall:;
        yourself!

setupSponsorAndTables
    "The compiler needs a parser and a scanner for it's language to be set up."
    | parsingTables |
    self halt: 'TO DO: Do what the comments say to do...'
    
    "Set up the user (or sponsor) of the scanner and parser."
    "<CODE HERE>"
    
    "Give the keywords to the screener and the remaining tables to the parser..."
    "<CODE HERE  If you run code to get the raw tables (rawParserTables) and inspect it, you will 
     see that it's an array and you will be able to tell where in the array, the 
     keywords are located. Alternatively, browse the method...>"
    
    "Give the entire set of scanner tables to the scanner..."
    "<CODE HERE>"! !

!SampleCompiler methodsFor: 'semantic actions'! !

!SampleCompiler methodsFor: 'get/set'!
   
parser: aParser
    parser := aParser!
 
tree
    ^tree!

tree: aTree
    tree := aTree!
 
parser
    ^parser! !

!SampleCompiler methodsFor: 'compiling/evaluating'!
   
evaluate: text
    | result |
    "If no variables are set up, just return the expression; otherwise, a dictionary of variables."
    tree := parser parse: text.
    result := self evaluateExpressionFor: tree.
    expressionsIfEvaluator size = 0 ifTrue: [^result] ifFalse: [^expressionsIfEvaluator]!
  
compile: text
    tree := parser parse: text.
    self compileExpressionFor: tree.
    ^codeIfCompiler contents! !

!SampleCompiler methodsFor: 'compilation support'!
 
compileExpressionFor: tree
    self perform: (compilationOperatorMap at: tree label asSymbol) with: tree!
  
generate: instruction
    codeIfCompiler cr; << instruction!
   
generate: instruction with: operand
    codeIfCompiler cr; << instruction; << ' '; << operand! !

!SampleCompiler methodsFor: 'evaluation support'!
  
evaluateExpressionFor: tree
    ^self perform: (evaluationOperatorMap at: tree label asSymbol) with: tree! !

!SampleCompiler methodsFor: 'compilation details'!
 
compileAssign: tree
    1 to: tree children size by: 2 do: [:index |
            self compileExpressionFor: (tree child: index + 1).
            self generate: 'POP' with: (tree child: index) symbol]!
 
compileFunctionCall: tree
    tree children rest do: [:child | self compileExpressionFor: child]. 
    self generate: 'FUNCTION_CALL' with: (tree child: 1) symbol!
   
compilePlus: tree
    self compileExpressionFor: (tree child: 1).
    self compileExpressionFor: (tree child: 2).
    self generate: 'ADD'.!
 
compileDivide: tree
    self compileExpressionFor: (tree child: 1).
    self compileExpressionFor: (tree child: 2).
    self generate: 'DIVIDE'.!

compileMultiply: tree
    self compileExpressionFor: (tree child: 1).
    self compileExpressionFor: (tree child: 2).
    self generate: 'MULTIPLY'.!

compileInteger: token
    self generate: 'PUSH' with: token symbol asInteger!
  
compileIdentifier: token
    self generate: 'PUSH' with: token symbol!
 
compileMinus: tree
    self compileExpressionFor: (tree child: 1).
    self compileExpressionFor: (tree child: 2).
    self generate: 'MINUS'.! !

!SampleCompiler methodsFor: 'evaluation details'!
   
evaluatePlus: aTree
    ^(self evaluateExpressionFor: (aTree child: 1)) + (self evaluateExpressionFor: (aTree child: 2))!
  
evaluateInteger: token
    ^token symbol asInteger!

evaluateIdentitifer: token
    | identifier |
    identifier := token symbol.
    ^self expressionsIfEvaluator at: identifier ifAbsent: [self halt: 'Identifier ', identifier printString, ' is not defined'].!
  
evaluateDivide: tree
    | expression1 expression2 |
    expression1 := self evaluateExpressionFor: (tree child: 1).
    expression2 := self evaluateExpressionFor: (tree child: 2).
    ^expression1 / expression2!

evaluateMinus: tree
    | expression1 expression2 |
    expression1 := self evaluateExpressionFor: (tree child: 1).
    expression2 := self evaluateExpressionFor: (tree child: 2).
    ^expression1 - expression2!
 
evaluateAssign: token
    | expression |
    expression := self evaluateExpressionFor: (tree child: 2).
    expressionsIfEvaluator at: (tree child: 1) symbol put: expression!
   
evaluateFunctionCall: tree
    | function parameters |
    function := (tree child: 1) label.
    parameters := tree children rest collect: [:child | self evaluateExpressionFor: child].  
    
    function = #tan ifTrue: [^parameters first tan]. 
    function = #abs ifTrue: [^parameters first abs].
    
    self halt: 'Function ', function printString, ' not yet handled'!

evaluateMultiply: tree
    | expression1 expression2 |
    expression1 := self evaluateExpressionFor: (tree child: 1).
    expression2 := self evaluateExpressionFor: (tree child: 2).
    ^expression1 * expression2! !

SampleCompiler comment: ''!





!Table methodsFor: 'get/set'!
 
transducer: aTransducer
    transducer := aTransducer!
 
transducer
    ^transducer! !

Table comment: ''!



!AcceptTable methodsFor: 'get/set'!
 
table: aTable
    "Do nothing."! !

!AcceptTable methodsFor: 'running'!
  
run
    ^nil "Ensure that parsing does not continue..."! !

AcceptTable comment: ''!



!SemanticTable methodsFor: 'get/set'!

table: aTable
    action := aTable first.
    parameters := aTable copyFrom: 2 to: aTable size - 1.
    goto := aTable last!
 
action: aSymbol
    action := aSymbol!
 
parameters
    ^parameters!

goto
    ^goto!

parameters: aCollection
    parameters := aCollection!
 
goto: aNumber
    goto := aNumber!
 
action
    ^action! !

!SemanticTable methodsFor: 'running'!
 
run
    | recipient |
    recipient := (transducer class canUnderstand: action) ifTrue: [transducer] ifFalse: [transducer sponsor].
    recipient perform: action withArguments: parameters.
    ^goto! !

SemanticTable comment: ''!



!ShiftbackTable methodsFor: 'get/set'!
   
table: aTable
    "Record the data it needs."
    self halt: 'TO DO: ShiftbackTable table: needs implementation'!
   
goto
    ^goto!

goto: aNumber
    goto := aNumber!
 
shift: aNumber
    shift := aNumber!
   
shift
    ^shift! !

!ShiftbackTable methodsFor: 'running'!
  
run
    "Adjust left by the amount specified and return the goto table."
    self halt: 'TO DO: ShiftbackTable table: run implementation'! !

ShiftbackTable comment: ''!



TableWithTransitions comment: ''!



!ReadaheadTable methodsFor: 'get/set'!
  
table: anArray
    "Record the data so you can later perform a fast lookup (or don't if you prefer to search)."
    self halt: 'TO DO: ReadaheadTable table: needs implementation'! !

!ReadaheadTable methodsFor: 'running'!
 
reportSyntaxError
    | token inputTokens inputText position |
            
    token := transducer scannerPeek.
    inputTokens := transducer tokenStack rest. "Skip start stack information."
    
    Transcript cr; << 'Syntax error...'. 
    inputTokens isEmpty 
        ifTrue: [Transcript cr; << 'Did not expect input to start with '. Transcript << token]
        ifFalse: [
            Transcript cr; << 'DID NOT EXPECT'; << (inputTokens size > 6 ifTrue: [' ...'] ifFalse: ['']).
            inputTokens := inputTokens suffix: 6.
            inputTokens do: [:token | Transcript << ' '; << token].
            Transcript cr; << 'TO BE FOLLOWED BY '; << token.
            inputText := transducer scanner input collection. position := transducer scanner input position.
            Transcript << (inputText copyFrom: (position + 1 max: 1) to: (position + 100 min: inputText size))].
    self error: ('Syntax error: Illegal symbol: ', token label)!
  
run
    self halt: 'TO DO: ReadaheadTable run needs implementation'.
    
    "Peek at the next token..."
    "<CODE HERE>"

    "and then search for a transition that matches it. When found, use the attributes to determine
    what to do. If you don't find it, it's a syntax error (see reportSyntaxError). Remember $R means 
    read ($L look), $N means make the token part of a tree, and $S means stack. If we stack, we also 
    need 'right' to refer to the last entry and 'left' to be one more to the right. Finally, returns 
    the corresponding goto state."
    "<CODE HERE>"! !

ReadaheadTable comment: ''!



!ReadbackTable methodsFor: 'get/set'!
 
table: anArray
   "Store the data, symbol/state number pairs. There's probably NO nice way of organizing it to make a fast search."
    self halt: 'TO DO: ReadbackTable table: needs implementation'! !

!ReadbackTable methodsFor: 'running'!
  
run
    "Readback considers the token label in the token stack and the state number in the table number at position 'left - 1'
    and then finds the transition that matches it. When it finds it, it then uses the attribute $R for read, $L for look to
    decide what to do. If it's read, it decrements 'left'. Finally it returns the goto state."
    self halt: 'TO DO: ReadbackTable run needs implementation'!

reportDesignError
    self error:'Design error: reached end of ReadbackTable without having found a suitable transition'! !

ReadbackTable comment: ''!



!ReduceTable methodsFor: 'get/set'!
   
nonterminal: aSymbol
    nonterminal := aSymbol!
   
nonterminal
    ^nonterminal!
  
table: anArray
    "Store the data; namely a nonterminal and a bunch of transition information; triples
    with a 'from table number', attributes, and a 'to table number'."
    self halt: 'TO DO: Reduce table: needs implementation'! !

!ReduceTable methodsFor: 'running'!
  
run
    "This is a 'Reduce to A' table where A is the nonterminal to reduce to. Pick up the new tree
	and simulate a readahead of A where the new tree is associated with A"
    | tree stack children |

    self halt: 'TO DO: Reduce run needs implementation'

    "Pick up the new tree if there is one OR bubble up the one tree in the stack between 
    'left' and 'right' or nil if there isn't one. There better not be 2 or more."
    transducer newTree notNil 
        ifTrue: [
	    tree := transducer newTree. transducer newTree: nil]
            ifFalse: [
               "Just capture the one subtree (if any) and have it ready for stacking."
               stack := transducer treeStack.
               children := (transducer left to: transducer right)
                  collect: [:index | stack at: index] when: [:index | (stack at: index) notNil].
               children size = 0 ifTrue: [tree := nil] ifFalse: [
               children size = 1 ifTrue: [tree := children first] ifFalse: [
               children size > 1 ifTrue: [self halt: 'Design error: more than 1 child in ReduceTable'. tree := children last]]]].

    "Clear the stacks between left and right (inclusive)."

    "<CODE HERE>"

    "Using the top table number on the stack, search the triples ('from table number, attributes, 
    'to table number) and find the one that matches 'from table number'; it's a design error if 
    you can't find it (see reportDesignError). The other table number is to be returned when you're 
    done. Also use  the attributes in the same manner as you did for a readahead table but this time, 
    instead of using the next token,  use a new token you create using the nonterminal as it's symbol. 
    Don't forget to adjust 'right' and 'left' like you did for the readahead table."
    
    "<CODE HERE>"!
 
reportDesignError
    self error: 'Design error: reached end of ReduceTable without having found a suitable transition'! !

ReduceTable comment: ''!



!ScannerReadaheadTable methodsFor: 'get/set'!

table: anArray
    "Record the triples: an integer or character collection, attributes, and goto. The integers
    are unprintable characters or the end of file integer 256, the attributes are $R for read 
    ($L for stack) and $K for keep. It's particularly important here to store the data so that
    given a character or 256, you can perform a fast lookup to find the triple."
    self halt: 'TO DO: ScannerReadaheadTable table: needs implementation'! !

!ScannerReadaheadTable methodsFor: 'running'!

printables
    "The last three printable characters are single quote (represented as two single quotest in a row; i.e. ''),
    double quote (represented as one double quote; the end of comment is a double quote), and a space.
    Note: that it's hard to see the difference between two single quotes and one double quote."
    
    ^'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!!,+-/\*~=@%&?|<>[]{}()^;#:.$_''" '.!
  
run
    "Consider the next input character or integer (it could be 256 for endOfFile).
    Search the transitions for the triple that matches it. Remember: the original
    data was triples: an integer or character collection, attributes, and goto. But
    for fast lookup, you want to just be able to look up the triple using the next
    input as a key... When you find it, the read attribute ($R as opposed to $L)
    indicates that you need to remove it from the input. Otherwise, it stays for future 
    use. If it has the keep attribute ($K), you need to append the character to
    'keptCharacters'. If you can't find it, it a lexical error (see reportLexicalError).
    When you are done, return the goto table."
    self halt: 'TO DO: ScannerReadaheadTable run needs implementation'!
 
reportLexicalError
    | characterAsInteger character printables |

    characterAsInteger := transducer inputPeek.
    characterAsInteger = 256 ifTrue: [self error: 'Lexical error: End of the file encountered unexpectedly'].
    character := characterAsInteger asCharacter.
    
    (self printables includes: character) 
        ifTrue: [self error: 'Lexical error, encountered unexpected character ', character asString]
        ifFalse: [
            self error: 'Lexical error, encountered unexpected unprintable character',
                ' hex ', (character asNumber printStringRadix: 16),
                ' decimal ', character asNumber printString]! !

ScannerReadaheadTable comment: ''!



!Token methodsFor: 'get/set'!

label: aLabel
    label := aLabel!
 
label
    ^label!
  
symbol
    ^symbol!

symbol: aSymbol
    symbol := aSymbol! !

!Token methodsFor: 'printing'!
 
printOn: aStream
    "Make label #Identifier with symbol #hello look like Identifier: hello 
    whereas label #keyword with symbol #keyword looks like keyword."
    self label == self symbol 
        ifTrue: [aStream << self label]
        ifFalse: [aStream << self label; << ': '; << self symbol].!
   
printOn: aStream tabs: tabs
    aStream cr.
    tabs timesRepeat: [ aStream << '   '].
    aStream << self label; << ' ('; << self symbol; << ')'.! !

!Token methodsFor: 'comparing'!
 
= anObject
    self class = anObject class ifFalse: [^false].
    ^self label = anObject label and: [self symbol = anObject symbol]!
  
hash
    ^label hash + symbol hash! !

Token comment: ''!


!Transducer class methodsFor: 'instance creation'!

new

    ^super new initialize! !


!Transducer methodsFor: 'get/set'!
 
tables: aCollection
    tables := aCollection!
 
tables
    ^tables!

sponsor
    ^sponsor!
  
sponsor: anObject
    sponsor := anObject! !

Transducer comment: ''!


!Parser methodsFor: 'initializing'!
   
initialize
    scanner := Scanner new.
    tokenStack := OrderedCollection new add: (Token new label: #'|-'; symbol: #'|-'); yourself.
    treeStack := OrderedCollection new add: nil; yourself.
    tableNumberStack := OrderedCollection new add: 1; yourself! !

!Parser methodsFor: 'get/set'!
   
screener: aScreener
    screener := aScreener!
 
screener
    ^screener!

right
    ^right!
  
tables: aCollection
    "Store the collection of all table objects in tables. Moreover, each type of table will store it's data
    in its own way. So, you had better let the object store it. Note: The collection contains the NAMES for the types
    of table objects, they are not table objects. Also, whoever sent this message had better not have 
    included an entry for a keyword list since that was supposed to have been given to the screener.
    IN OTHER WORDS: Create the appropriate kind of table object, give the table data to that object, and 
    then store that object in the parser's tables."
	
    "HINT: 'Smalltalk at: x' where x is a variable containing the symbol #Apple returns the class object called
    Apple. Once you have a class object, you can say new to it."

    self halt: 'TO DO: Parser tables: needs implementation (the code to create the table objects)'!
  
tokenStack: aCollection
    tokenStack := aCollection!
 
left: aNumber
    left := aNumber!
 
tableNumberStack: aCollection
    tableNumberStack := aCollection!
 
tokenStack
    ^tokenStack!

tableNumberStack
    ^tableNumberStack!

treeStack
    ^treeStack!
  
newTree
    ^newTree!
  
scanner
    ^scanner!
  
right: aNumber
    right := aNumber!
   
treeStack: aCollection
    treeStack := aCollection!
   
tables
    ^tables!

left
    ^left!

newTree: aTree
    newTree := aTree!
   
scanner: aScanner
    scanner := aScanner! !

!Parser methodsFor: 'parsing'!
 
parse: text
    | table |
    "To parse the text, you have to give it to the scanner (say via scan: text).
    It in turn should have the first token set up for you. Next you need
    to execute tables starting from table 1 until you reach an Accept table.
    Once that happen, the tree that was built should be on top of the tree
    stack. Just return it. If you look at the Accept table, you will see
    that it of all the tables, it is the only one that returns nil. You can
    use that information to stop your loop."

    self halt: 'TO DO: Parser parse: needs implementation (the code to parse text)'
    "<CODE HERE. Note: If you place 'self log' at the top of your loop,
    you will get debugging information, useful if something doesn't work.
    For now, add the 'self log' code but comment it out"! !

!Parser methodsFor: 'streaming'!

scannerPeek
    ^screener screen: scanner peek.!
   
scannerNext
    scanner next.! !

!Parser methodsFor: 'semanticActions'!
 
buildTreeFromIndex: index
    "The root for a new tree is already somewhere on the stack..."
    "If index is positive (1, 2, 3, ...) => label is in the token stack relative to the left end; i.e., to the right of left end."
    "If index is negative (-1, -2, -3...) => label is in the token stack relative to the right end; i.e., to the left of right end."
    | children newRootLabel |    
    children := (left to: right) collect: [:index | treeStack at: index] when: [:index | (treeStack at: index) notNil].
    newRootLabel := (index isPositive ifTrue: [tokenStack at: left + index - 1] ifFalse: [tokenStack at: right + index + 1]) symbol.
    newTree := Tree new 
        label: newRootLabel 
        children: children.!
   
buildTree: rootLabel
    | children |
    "Pick up the children from the tree stack between left and right inclusive (provided they're not nil) and build a tree
    with the given label. Store it in instance variable newTree so a reduce table can use it."
    self halt: 'TO DO: Parser buildTree: needs implementation'! !

!Parser methodsFor: 'debugging'!
 
log
    | table useTerseTree |
    true ifTrue: [^self].
    scanner input position < 3700 ifTrue: [^self].
    useTerseTree := true. "Set to false if more details are wanted..."
    table := tables at: tableNumber.

    "Log a preliminary heading..."
    Transcript cr; << self scannerPeek; << ' | left '; << left; << ' right '; << right; << ' |'; << ' Table '; << tableNumber; space; << table.

    "Log state specific information..."
    table class = ReadaheadTable ifTrue: [Transcript << ' SEARCHING FOR '; << self scannerPeek label].
    table class = ReadbackTable ifTrue: [Transcript << ' SEARCHING FOR ';
        << '['; << (tokenStack at: left - 1) label; << ' '; << (tableNumberStack at: left - 1); << ']'].
    table class = ReduceTable ifTrue: [Transcript space; << table nonterminal; << ' SEARCHING FOR ';
        << (tableNumberStack at: left - 1)].
    table class = ShiftbackTable ifTrue: [Transcript << ' SHIFT '; << table shift; << ' GOTO '; << table goto].
    (table class = SemanticTable) ifTrue: [
        Transcript space; << table action. table parameters do: [:parameter | Transcript space; << parameter].
        Transcript << ' GOTO '; << table goto].

    "Log information in the stacks..."
    self treeStack indexedDo: [:index :tree |
        (index = left and: [left <= right]) ifTrue: [Transcript cr; << '       ---------------------------'].
        Transcript cr; << '       '; << index; << ' ['; << (self tokenStack at: index); << ' '; << (self tableNumberStack at: index); << '] '.
        tree isNil ifFalse:[useTerseTree ifTrue: [Transcript << ' Tree ('; << tree label; << ' ...)'] ifFalse: [tree printOn: Transcript tabs: 3]].
        (index = right and: [left > right]) ifTrue: [Transcript cr; << '       ---------------------------'].
        index = right ifTrue: [Transcript cr; << '       ---------------------------'].].! !

Parser comment: ''!



!Scanner methodsFor: 'initializing'!
 
initialize
    token := nil.
    keptCharacters := ''.! !

!Scanner methodsFor: 'get/set'!
  
tables
    ^tables!

tables: aCollection
    "Store the collection of all table objects in tables. Moreover, each type of table will store it's data
    in its own way. So, you had better let the object store it. Note: The Collection contains the NAMES of the 
    types of table objects, they are not table objects. IN OTHER WORDS: Create the appropriate kind of table
    object, give the table data to that object, and then store that object in the scanner's tables."

    "HINT: 'Smalltalk at: x' where x is a variable containing the symbol #Apple returns the class object called
    Apple. Once you have a class object, you can say new to it."

    self halt: 'TO DO: Scanner tables: needs implementation'!

keptCharacters
    ^keptCharacters!

keptCharacters: aString
    keptCharacters := aString!
 
input: aStream
    input := aStream!
   
input
    ^input! !

!Scanner methodsFor: 'scanning'!

scan: text
    self input: (ReadStream on: text).
    self next! !

!Scanner methodsFor: 'streaming'!
   
inputPeek
    ^input atEnd ifTrue:[256] ifFalse:[input peek]!
  
next
    "To discard the current token, set token to nil and execute the tables
    in a loop starting with table 1 until token is no longer nil. Then return 
    nothing. Somewhere during this execution, the semantic action buildToken:
    will execute putting something into variable 'token'."
    self halt: 'TO DO: Scanner next needs implementation'!
 
peek
    ^token!
   
inputNext
    ^input next! !

!Scanner methodsFor: 'semantic actions'!
   
buildToken: label
    "Create a token with the supplied label and the characters in keptCharacters
    and put the result in variable 'token' so peek can return it when requested.
    Reset keptCharacters to an empty string so the process can repeat."

    self halt: 'TO DO: Scanner buildToken: needs implementation'! !

Scanner comment: ''!


!Screener class methodsFor: 'default keywords'! !

!Screener methodsFor: 'get/set'!
  
keywords
    ^keywords!

keywords: aCollection
    keywords := aCollection! !

!Screener methodsFor: 'screening'!
 
screen: aToken
    self halt: 'THERE IS NO CODE TO ADD HERE BUT...: If you carry on by clicking on RESUME and 
    the code doesn''t work, you must have forgotten to give the screener its keywords.'.

    aToken label = #Identifier ifFalse: [^aToken].
    (self keywords includes: aToken symbol) ifFalse: [^aToken].
    ^Token new label: aToken symbol; symbol: aToken symbol.! !

Screener comment: ''!


!Tree class methodsFor: 'instance creation'!
  
new

    ^super new initialize! !


!Tree methodsFor: 'initializing'!
  
initialize
    children := OrderedCollection new.! !

!Tree methodsFor: 'get/set'!
   
children
    ^children!

label: aSymbol
    label := aSymbol!
   
label
    ^label!
  
child: index
    ^children at: index!
  
children: aCollection
    children := aCollection! !

!Tree methodsFor: 'modifying'!
 
addChild: aTree
    children add: aTree! !

!Tree methodsFor: 'printing'!

printOn: aStream
    self printOn: aStream tabs: 0.!
   
printOn: aStream tabs: tabs
    aStream cr.
    tabs timesRepeat: [aStream << '   '].
    aStream << self label.
    children do: [:child | child printOn: aStream tabs: tabs + 1]! !

Tree comment: ''!
