3.1.0.106
   
undeclaredAccess: error
        "The compiler has found a reference to an undeclared variable"
    self checkDefineGlobal: error!   
undeclaredAssignment: error
        "The compiler has found an assignment to an undeclared variable"
    self checkDefineGlobal: error! 
teamIsInstalled
        " Private - answer whether TeamV is currently installed. "

    | globalRegistry teamRegistry |
    globalRegistry := ServiceRegistry globalRegistry.
    teamRegistry := globalRegistry serviceNamed: #TeamVServices 
		ifNone: [ ^false ].
    teamRegistry serviceNamed: #TeamInstallation
		ifNone: [ ^false ].
    ^true!   
checkDefineGlobal: error
        " Private - disallow assignment to globals in a PARTS script. "
    self fatalError: error.!   
scriptCompilationClass
        " Answer the class which defines the compilation
        context of a PARTS script. "

	^PARTSScript scriptClassField! 
setApplicationNameScopeOf: aCompiler for: aComponentDictionary
        " Private - install the component name space with
        scoping precedence over the global name space. "

    aCompiler nameScope: (
        ( aCompiler scopeForApplication: aComponentDictionary ),
        aCompiler nameScope,
        aCompiler scopeForHostConstants )! 
restartable
    "Private"
    "Answer true if the process is restartable."

    super restartable
        ifFalse: [ ^false ].
    ( partsDebugger notNil
    and: [ ( partsDebugger okToRestartProcess: self debuggedProcess at: self  processWalkbackIndex  ) not ] )
        ifTrue: [
            MessageBox warning: 'Can''t restart link firing.'.
            ^false ].
    self prepareToResume.
    ^true!   
suspendTimers
        " Private - suspend any timers in this application. "

    application isNil ifTrue: [ ^self ].
    suspendedTimers := PARTSTimerWindow activeTimers
        select: [ :aTimerPart | aTimerPart partApplication == application ].
    suspendedTimers do: [ :aTimerPart | aTimerPart stopTimer ].!
walkbackFor: aProcess label: aString
        "Pop-up a walkback window with label equal
         to aString.  Display the stacked message
         sends for the receiver in the window.
         The client process being debugged may
         have PARTS links firing in its
         call stack and may be executing script(s).
         Method debugging must be synchronized
         with the PARTS link debugger. "

    | partsInfoAssoc |
    partsInfoAssoc := aProcess partsWalkbackInfo.
    partsInfoAssoc notNil
        ifTrue: [ self partsDebugger: partsInfoAssoc key ].
    self suspendTimers.
    super walkbackFor: aProcess label: aString.
    self registerCancelActionFor: logger.!
generateCompilationResultFor: aScript
    sourceString: sourceString
    errorHandler: anErrorHandler
        " Answer the compilation result of compiling <sourceString>
        in the context of <aScript>. "

    | componentDictionary aCompiler aCompilationResult newScript |

    componentDictionary := aScript componentNameDictionary.

    "self ASSERT: aScript classField == self scriptCompilationClass."
    aCompiler := self
        forClass: self scriptCompilationClass
        errorHandler: anErrorHandler.
    aCompilationResult := self
        compile: sourceString
        using: aCompiler
        componentDictionary: componentDictionary.
    aCompilationResult wasSuccessful
        ifFalse: [ ^aCompilationResult ].

    newScript := self
        scriptFromCompilationResult: aCompilationResult
        source: sourceString
        componentDictionary: componentDictionary
        part: aScript scriptPart.
    aCompilationResult compiledMethod: newScript.
    ^aCompilationResult!
setSourceString: newSource
        "Record <newSource> as the new source string for the
        receiver.  It is assumed that this source corresponds
        to the current executable"

    self compiledMethod sourceString: newSource.!  
sourceString: newSource notifying: requestor
        "Associate new source with the receiver.
        Answer <nil> if the source cannot be accepted,
        or the definition if it can be.  Associating source
        with a definition may require compilation, and the
        definition answered when successful may not be
        the receiver.  If compilation is required and any
        errors are detected, notify the <requestor>."

    | result newDefinition |
    result := self
        sourceString: newSource
        errorHandler: ( requestor == nil
            ifTrue: [ SilentErrorHandler new ]
            ifFalse: [ PARTSTextPaneErrorHandler new pane: requestor ] ).
    ( result == nil or: [ result wasSuccessful not ] )
        ifTrue: [ ^nil ].
    result selector == self selector
        ifTrue: [
            self compiledMethod: result method.
            newDefinition := self ]
        ifFalse: [
            newDefinition := result method definition ].
    newDefinition setSourceString: newSource.
    ^newDefinition!   
sourceStringForDebuggerCompilation: sourceString
        "Private - Answer the string to use to compile <sourceString>
        for debugging.  If the debugger doesn't cope well with tabs
        in method source in the current environment, answer
        a copy of <scriptSource> with 4 spaces substituted
        for each embedded tab.  This is a workaround for
        debugger highlighting problems with tab characters.
        The PARTS script editor uses a TextPaneControl, but the
        development environment tools in VWin32 use the old
        TextPane. "

    | copy destIndex nTabs tabWidth |

    "DebuggerHandlesTabs
        ifTrue: [ ^sourceString ]."
    ( SmalltalkToolInterface current textPaneClass new respondsTo: #setTabStop )
        ifTrue: [ ^sourceString ].
    nTabs := sourceString occurrencesOf: Tab.
    tabWidth := 4.
    copy := String new: sourceString size + (tabWidth - 1 * nTabs).
    destIndex := 1.
    sourceString do: [ :c |
        c = Tab ifTrue: [
            1 to: tabWidth do: [ :i |
                copy at: destIndex put: Space.
                destIndex := destIndex + 1 ] ]
        ifFalse: [
            copy at: destIndex put: c.
            destIndex := destIndex + 1 ] ].
    ^copy
!
compile: sourceString
    for: aPart
    componentDictionary: componentDictionary
    errorHandler: anErrorHandler
        " Compile the text in <sourceString> as a
        PARTS script.  Answer the new script if successful.
        Answer nil if the compilation failed. "

    | aCompiler aCompilationResult |
    aCompiler := self
        forClass: self scriptCompilationClass
        errorHandler: anErrorHandler.
    aCompilationResult := self
        compile: sourceString
        using: aCompiler
        componentDictionary: componentDictionary.
    aCompilationResult wasSuccessful
        ifFalse: [ ^nil ].
    ^self
        scriptFromCompilationResult: aCompilationResult
        source: sourceString
        componentDictionary: componentDictionary
        part: aPart!   
sourceString: newSource errorHandler: errorHandler
        "Private - Compile and install <newSource> for the receiver.
        Answer the compilation result derived from the compilation
        or nil if there is no source."

    | compilerInterface result |
    newSource isNil
        ifTrue: [ ^nil ].
    compilerInterface := self compilerInterfaceClass.
    compilerInterface isNil
       ifTrue: [ ^nil ].  " incomplete installation, cannot proceed "
    result := compilerInterface
        generateCompilationResultFor: self compiledMethod
        sourceString: newSource
        errorHandler: errorHandler.
    result wasSuccessful
        ifTrue: [
            "self ASSERT: result method selector isSymbol."
            self saveNewScript: result method ].
    ^result!   
findPartForScript: aScript
        " Private - answer the part to which aScript is attached. "

    | containingApplication |
    containingApplication := aScript sourceObject componentDictionary
        detect: [ :aPart | aPart isPARTSApplication ].
   containingApplication partWrapper withAllChildren do: [ :aWrapper |
        ( aWrapper scripts includes: aScript )
            ifTrue: [ ^aWrapper object ].
        ].
    ^nil! 
isValidScriptSelector: aSelector for: anObject scriptNames: existingScriptNames
        "Private - Answer whether <aSelector> is a valid script name
        for the <anObject>. "
    | workbenchSettingsClass |

    ( existingScriptNames includes: aSelector )
        ifTrue: [ ^true ].
    aSelector first isUpperCase
        ifFalse: [ ^false ].
    " check for overrides "
    ( ( anObject respondsTo: aSelector )
    or: [ anObject partMessages items includes: aSelector ] )
        ifTrue: [
            workbenchSettingsClass := Smalltalk at: #PARTSSettings
                ifAbsent: [ nil ].
            ( workbenchSettingsClass notNil
            and: [ workbenchSettingsClass current isDeveloper ] )
                ifTrue: [
                    ^MessageBox confirm: 'Override existing method?' ]
                ifFalse: [
                    MessageBox
                        notify: 'Illegal Script name'
                        withText: 'Cannot use ', aSelector asString,
                            ' as script name'.
                    ^false ].
                ].
    ^true
!  
prepareToResume
        " Private - the process is about to be restarted or resumed. "

    | aBrowser |
    aBrowser := ( logger notNil
        ifTrue: [ logger ]
        ifFalse: [ self ] ).
    partsDebugger := nil.
    self removeCancelActionFor: aBrowser.
    aBrowser mainView
        when: #closed
        send: #resumeTimers to: self.!
removeTeamScriptSupport
        " Private - Team/V is about to be unbound - get rid of
        the PARTS TeamV script support. "

    | teamScriptLibraryName aLibrary |
    ( (teamScriptLibraryName := self teamScriptLibraryName ) notNil
    and: [ (aLibrary := SmalltalkLibrary named: teamScriptLibraryName ) notNil ] )
        ifTrue: [ aLibrary unBind ].!  
COMMENT
"
PARTSDeveloperDebugger provides script debugging
capability in the Smalltalk development environment
debugger.  It must be installed as the standard debugger
in order for scripts to be supported properly in a
development image.
"!   
compiledMethodDefinitionClass
	"Answer the class of definition to use for the receiver, if none is known"

	^PARTSScriptDefinition!
scriptFromCompilationResult: aCompilationResult
    source: sourceString
    componentDictionary: aComponentDictionary
    part: aPart
        " Private - answer the PARTSScript resulting from
        aCompilationResult. "

	^PARTSScript
		fromMethod: aCompilationResult method
    	source: sourceString
    	componentDictionary: aComponentDictionary
    	part: aPart!   
checkDefineGlobal: error
        " Private - disallow assignment to globals in a PARTS script. "
    self fatalError: error.!   
poolVariableScope
        "Return a scope containing all of the pools for
        a PARTS Script."

    | aPool poolVariableScope |
    poolVariableScope := MultiplePoolScope new.
    self scriptPoolNames do: [ :aPoolName |
        aPool := Smalltalk at: aPoolName ifAbsent: [ nil ].
        aPool == nil 
            ifFalse: [ 
                poolVariableScope add:
                    ( self scopeForPool: aPool named: aPoolName ) ].
        ].
    ^poolVariableScope! 
scriptPart
       " Private - answer the part to which this script belongs. "

   ^self compiledMethod scriptPart! 
debug
    "Private"
    "Close the walkback window and open a debugger window
    on the process."

    self removeCancelActionFor: logger.  " process is not being cancelled yet "
    super debug.
    self registerCancelActionFor: self.!  
saveNewScript: aScript
        " Private - save <aScript> in the script dictionary of its part. "
    | application scriptPart |

    scriptPart := self scriptPart.
    application := scriptPart partApplication.

    ( PARTSScript
        isValidScriptSelector: aScript selector
        for: scriptPart
        scriptNames:
            ( application componentScriptsFor: scriptPart ) keysAsArray )
        ifFalse: [ ^nil ].

    application
        addScript: aScript selector
        method: aScript
        to: scriptPart.

    self propagateScriptEdit: aScript.! 
teamScriptLibraryName
        " Private - answer the name of the library which
        provides PARTS script support for Team/V. "

    | scriptLibraryName |
    scriptLibraryName := self smalltalkScriptLibraryName.
    scriptLibraryName isNil
        ifTrue: [ ^nil ].
    ^( scriptLibraryName copyFrom: 1 to: 5 ), 'T', ( scriptLibraryName copyFrom: 7 to: 8 )! 
compile: scriptSourceString
    using: aCompiler
    componentDictionary: aComponentDictionary
        " Private - compile the text in scriptSourceString as a
        PARTS script.  Answer the compilation result. "

    self
        setApplicationNameScopeOf: aCompiler
        for: aComponentDictionary.
    ^aCompiler compile: scriptSourceString! 
evaluate: scriptExpressionString
    for: aPart
    componentDictionary: aComponentDictionary
    errorHandler: anErrorHandler
        " Evaluate the text in scriptExpressionString as a
        PARTS script context expression.  Answer the new method if successful.
        Answer nil if the compilation failed. "

    | aCompiler compilationResult |

    aCompiler := self
        forClass: self scriptCompilationClass
        errorHandler: anErrorHandler.
    self
        setApplicationNameScopeOf: aCompiler
        for: aComponentDictionary.
    "doItScript := 'DoIt ', scriptExpressionString."
    compilationResult := aCompiler compileForEvaluation: scriptExpressionString.
    compilationResult wasSuccessful
        ifFalse: [ ^nil ].
    compilationResult method selector: #DoIt.
    ^self
        scriptFromCompilationResult: compilationResult
        source: scriptExpressionString
        componentDictionary: aComponentDictionary
        part: aPart!  
installSmalltalkScriptSupport
        " Install the standard Smalltalk development script support  "

    Debugger default: PARTSDeveloperDebugger.
"    PARTSScriptCompilerInterface setDebuggerTabInfo."
    SessionModel current
        when: #libraryBound:
        send: #teamDetector: to: self.!   
smalltalkScriptLibraryName
        " Private - answer the name of the library which
        provides PARTS script support in a Smalltalk
        development image. "

    | libraryName |
    ^( libraryName := PARTSDeveloperDebugger libraryName ) isNil
        ifTrue: [ nil ]
        ifFalse: [ libraryName fileNameLessPath fileName ]!   
removeCancelActionFor: aBrowser
        " Private - remove the cancellation handler
        which notifies the PARTS link debugger
        operating on the process being debugged
        if the process is cancelled. "

    partsDebugger isNil ifTrue: [^self].
    aBrowser mainView
        removeActionsWithReceiver: self
        forEvent: #aboutToClose.!  
scopeForApplication: aComponentDictionary
        " Private - answer a name scope for the component
        parts in a PARTS application.  The part name scope
        has precedence over the global name space. "

    | compilationComponentDictionary |
    compilationComponentDictionary := Dictionary new.
    aComponentDictionary associationsDo: [ :assoc |
        assoc value isPARTSTransientPart
            ifFalse: [ compilationComponentDictionary add: assoc ] ].
    ^self scopeForDictionary: compilationComponentDictionary!  
installDeveloperComponent
        " Install the PARTS development environment component
            PARTSDevelopmentSessionManager installDeveloperComponent
        "

    

	self 
		initializeDevelopmentData;
		registerSmalltalkMenuCommand.

    self teamIsInstalled
        ifTrue: [    " Smalltalk/V development environment + TeamV "
            self installTeamScriptSupport.
            ]
        ifFalse: [    " standard Smalltalk/V development environment "
            self installSmalltalkScriptSupport.
            ].! 
resumeTimers
        " Private - resume any suspended timers in this application. "

    suspendedTimers notNil
        ifTrue: [
            suspendedTimers do: [ :aTimer | aTimer startTimer ].
            suspendedTimers := nil ].!   
partsDebugger: aPARTSDebugger
        " Set the associated PARTS link debugger.
        Must be set before opening the walkback. "

    partsDebugger := aPARTSDebugger.
    partsDebugger notNil
        ifTrue: [ application := partsDebugger application ].!
recompile
        "Private - Recompile the receiver.  Answer the compilation
         result or nil if there was no source"

    self error: 'not supported for scripts'! 
compilerInterfaceClass
       " Private - answer the compiler interface class
       for a PARTS script. "

    ^PARTSScript compilerInterfaceClass!  
fixReferencesIn: aComponentDictionary
        "Private - code generation reconstruction - the receiver
        is being installed onto a part but has references to a place holder
        pool dictionary that need to be directed to aComponentDictionary."
    | slot name assoc |
    1 to: self size do: [ :i |
        slot := self at: i.
        slot isAssociation
            ifTrue: [
                name := slot key.
                assoc := aComponentDictionary
                    associationAt: name
                    ifAbsent: [ nil ].
                assoc notNil ifTrue: [
                    self at: i put: assoc ]]]!  
scopeForHostConstants
    " Answer a name scope for the host platform OS constants "

   ^self scopeForPool: OperatingSystemConstants
        named: #OperatingSystemConstants!   
installTeamScriptSupport
        " Install the PARTS + TeamV development environment package
            PARTSSessionManager installTeamScriptSupport
        "

    | teamScriptLibraryName teamLibrary |

    teamScriptLibraryName := self teamScriptLibraryName.
    ( teamScriptLibraryName isNil
     or: [ ( [ SmalltalkLibraryBinder bindTo: teamScriptLibraryName ]
                    on: FileError, BindError do: [ :e | nil ] ) isNil ] )
        ifTrue: [
            MessageBox
                notify: 'PARTS Installation Problem'
                withText: 'Unable to bind ',
                    ( teamScriptLibraryName isNil
                        ifTrue: [ 'PARTSTeamDebugger component' ]
                        ifFalse: [ teamScriptLibraryName ", SmalltalkLibrary fileExtension" ] ),
                    ' - PARTS scripts cannot be debugged until this component is bound.' ].

"    PARTSScriptCompilerInterface setDebuggerTabInfo."
    ( teamLibrary := self teamDebuggerLibrary ) notNil
        ifTrue: [    " plug PARTS debugger in if TeamV ever goes away "
            teamLibrary
                when: #unbind
                send: #restoreDeveloperDebugger to: self ].! 
registerSmalltalkMenuCommand
        " Private - register the PARTS Workbench command in the
        standard Smalltalk tool menu. "

    SmalltalkWindowPolicy
        addToolItem: 'N',PARTSEditMenu mnemonic,'ew Workbench\tCtrl+Q' copy replaceEscapeCharacters 
        action: ( Message receiver: PARTSEditor selector: #open )
        commandKey: $Q! 
scopeForReadOnlyDictionary: dict
    "Answer a name scope appropiate for this compile that represents the names that are the keys of
    the argument dictionary.  The keys of the dictionary should normally be strings, not Symbols.
    If the keys are symbols, the message #useSymbolKeys should be explicitly send to the object
    returned from this method"

    ^GlobalPoolScope for: dict bindingClass:
        ( self compiler readOnlyAssociationBindingClass )! 
undeclaredAccess: error
        "The compiler has found a reference to an undeclared variable"
    self checkDefineGlobal: error!   
registerCancelActionFor: aBrowser
        " Private - register the cancellation handler
        which notifies the PARTS link debugger
        operating on the process being debugged
        if the process is cancelled. "

    partsDebugger isNil ifTrue: [ ^self ].
    aBrowser notNil
        ifTrue: [
            aBrowser mainView
                when: #aboutToClose
                send: #cancelPartsDebugger to: self ].!  
removeDeveloperComponent
        " Remove the PARTS development environment component
            PARTSDevelopmentSessionManager removeDeveloperComponent
        "

    | teamLibrary |

	self removeSmalltalkMenuCommand.

    SessionModel current
        removeActionsWithReceiver: self
        forEvent: #libraryBound: .
    ( teamLibrary := self teamDebuggerLibrary ) notNil
        ifTrue: [    " plug PARTS debugger in if TeamV ever goes away "
            teamLibrary
                removeActionsWithReceiver: self
                forEvent: #unbind ].

    Debugger default:
        ( self teamIsInstalled
            ifTrue: [ self teamDebuggerClass ]
            ifFalse: [ nil ] ).!   
scriptPoolNames
        " Private - answer the names of the pool dictionaries
        accessible in a PARTS script. "

    ^#(
        #CharacterConstants
        #ColorConstants
        #GraphicsConstants
        #VirtualKeyConstants
        "OperatingSystemConstants"  " handled in special scope "
        )!  
debugInfo
        "Answer debug information for the receiver"

    | compilerInterface |
    compilerInterface := self compilerInterfaceClass.
    compilerInterface isNil
       ifTrue: [ ^nil ].  " incomplete installation, cannot proceed "
    ^compilerInterface
        generateCompilationResultFor: self compiledMethod
        sourceString: ( compilerInterface sourceStringForDebuggerCompilation: self sourceString )
        errorHandler: PARTSSilentErrorHandler new!  
PARTSDevelopmentSessionManager  removeDeveloperComponent! 
removeSmalltalkMenuCommand
		" Private - remove the PARTS Workbench command in the
		standard Smalltalk tool menu. "

	SmalltalkWindowPolicy removeToolItem: 'PARTS Workbench'.

	( Notifier mainWindowsSelect: [ :aWindow | true ] ) do: [ :aWindow |
		( aWindow menuTitled: 'Smalltalk' ) 
			changeItem: 'PARTS Workbench' selector: #yourself;  " NOP "
			disableItem: 'PARTS Workbench'.
		].!   
propagateScriptEdit: newScript
        " Private - the receiver has just been edited.
        Propagate the script change to appropriate places,
        notably to the original application in the workbench.
        This implementation does not attempt to update any
        open script browsers, nor does it detect if the script
        being updated is in a linked nested part which is referenced
        multiple times in the containing application (believed to be rare). "

    | originalApplication originalPart |

    " Fix script in originating application if open in a workbench "
    originalApplication := self scriptPart partApplication workbenchSource.
    ( originalApplication notNil
    and: [ originalApplication partEditor application == originalApplication ] )
        ifTrue: [
            originalPart := originalApplication componentNamed: self scriptPart partName.
            originalPart partDefineScript: newScript sourceString.
            originalApplication partEditor recordUndoPlaceholder.
            ].! 
scopeForClass: aClass
        "Answer a name scope appropriate for the compiler that
        represents the names defined for code compiled in the
        scope of the given <class>.  This includes only pool
        variables for a PARTS script; no instance or class
        variables are allowed.  The class scope does not
        include globally defined names. "

    aClass == self class scriptCompilationClass
        ifFalse: [ ^self error: 'invalid class for PARTS script' ].
    ^( self scopeForReservedSymbolsExcluding: #( 'super' ) ),
        self poolVariableScope!   
teamDebuggerClass
        " Private - answer the TeamV debugger. "

    ^self teamIsInstalled
        ifTrue: [ ObjectStoreExternal getClass: #TeamDebugger ifAbsent: [ nil ] ]
        ifFalse: [ nil ]!
undeclaredAssignment: error
        "The compiler has found an assignment to an undeclared variable"
    self checkDefineGlobal: error! 
restoreDeveloperDebugger
        " Private - TeamV is going away - reset the debugger
        for PARTS script support in a standard Smalltalk/V
        development image.  Requeue as a precaution, since
        this is invoked at #unbind time of removing TeamV. "

    ( Message
        receiver: self
        selector: #installSmalltalkScriptSupport )
            performDeferred.!  
teamDetector: aLibrary
        " Private - figure out if TeamV is arriving. "

    self teamIsInstalled
        ifTrue: [
            ( Message receiver: self selector: #installTeamScriptSupport )
                performDeferred.  " plug in PARTSTeamDebugger after TeamV is installed "
            SessionModel current
                removeActionsWithReceiver: self
                forEvent: #libraryBound: .
            ].!   
initializeDevelopmentData
        " Private - initialize classes which have
        to be done at installation time (certain
        class vars which couldn't be put in the component). "

	PARTSScriptCompilerInterface initialize.!   
resumable
    "Private"
    "Answer true if the process is resumable."

    super resumable
        ifFalse: [ ^false ].
    self prepareToResume.
    ^true!  
scopeForGlobals
        "Answer a name scope appropiate for this compile that
        represents the names of globals in the default global name
        space (normally, the SystemDictionary Smalltalk). "

    ^( self scopeForReadOnlyDictionary: self defaultGlobalDictionary )
        useSymbolKeys;
        description: 'global variable';
        yourself! 
cancelPartsDebugger
        " Private - the debugger is being closed.  If there
        is an associated PARTS link debugger, it needs
        to be told the process is being killed.  Restart
        and resume must clear partsDebugger so that
        this guy is a NOP when reached. "

    partsDebugger notNil
        ifTrue: [
            partsDebugger cancelProcessing.
            partsDebugger := nil ].!  
teamDebuggerLibrary
        " Private - answer the library containing the Team/V debugger. "

    | teamDebuggerClass |
    ( teamDebuggerClass := self teamDebuggerClass ) isNil
        ifTrue: [ ^nil ].
    ^teamDebuggerClass library!