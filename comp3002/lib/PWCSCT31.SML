3.1.0.106
   
installLibrary
        " Private - install the library "

    | teamLibrary |

    self initializeMenuDescriptions.
    Debugger default: self.

    ( teamLibrary := self superclass library ) notNil
        ifTrue: [
            teamLibrary
                when: #aboutToUnbind
                send: #removeTeamScriptSupport to: PARTSDevelopmentSessionManager ].!   
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
    " ISSUE: also need app info from queueWalkback even if no debugger [DJL 17-Jul-92] "
    partsDebugger notNil
        ifTrue: [ application := partsDebugger application ].!  
debug
    "Private"
    "Close the walkback window and open a debugger window
    on the process."

    self removeCancelActionFor: logger.  " process is not being cancelled yet "
    super debug.
    self registerCancelActionFor: self.!  
removeCancelActionFor: aBrowser
        " Private - remove the cancellation handler
        which notifies the PARTS link debugger
        operating on the process being debugged
        if the process is cancelled. "

    partsDebugger isNil ifTrue: [^self].
    aBrowser mainView
        removeActionsWithReceiver: self
        forEvent: #aboutToClose.!  
COMMENT
"
PARTSTeamDebugger provides script debugging
capability in the Team/V development environment
debugger.  It must be installed as the standard debugger
in order for scripts to be supported properly in a
Team/V development image.
"!
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
resumable
    "Private"
    "Answer true if the process is resumable."

    super resumable
        ifFalse: [ ^false ].
    self prepareToResume.
    ^true!  
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
prepareToResume
        " Private the process is about to be restarted or resumed. "

    | aBrowser |
    aBrowser := ( logger notNil
        ifTrue: [ logger ]
        ifFalse: [ self ] ).
    partsDebugger := nil.
    self removeCancelActionFor: aBrowser.
    aBrowser mainView
        when: #closed
        send: #resumeTimers to: self.!  
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
suspendTimers
        " Private - suspend any timers in this application. "

    application isNil ifTrue: [ ^self ].
    suspendedTimers := PARTSTimerWindow activeTimers
        select: [ :aTimer |
            aTimer partWrapper application == application ].
    suspendedTimers do: [ :aTimer | aTimer stopTimer ].!