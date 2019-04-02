3.1.0.106
   
tabStop
        "Make the dialog item recieve the focus when the user
        presses the TAB key.  Ignored for static controls because they
        can never be a tabstop."! 
canTab
        "Private - Progress Bars are read-only and cannot receive the focus, so cannot
        be tabbed into."
    ^false! 
isATabStop
        "Private - Answer whether the receiver is a tabstop"
    ^false! 
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^super constructEventsTriggered
        remove: #nextLine ;
        remove: #previousLine ;
        yourself! 
windowClass
        "Private - Answer the window class for the receiver."
    ^ProgressClass!   
setMaximum
        "Private - update the host control's maximum value."
    self setRange!  
setMinimum
        "Private - update the host control's minimum value."
    self setRange!  
setRange
        "Private - update the host control's range (minimum and maximum)."
    UserLibrary
        sendMessage: self handle
        msg: PbmSetrange
        wparam: 0
        lparam: ( ExternalLong lowHalf: self minimum highHalf: self maximum ) asParameter!  
buildWindow: parentWindow
        "Private - Create the window for the receiver, initializing the
        common controls library if necessary."
    CommonControlsDLL current.
    ^super buildWindow: parentWindow! 
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsBorder!
setLineIncrement
        "Private - set the host control's line increment (step value)."
    UserLibrary
        sendMessage: self handle
        msg: PbmSetstep
        wparam: self lineIncrement
        lparam: 0! 
lineIncrement: anInteger
        "Set the line increment to anInteger."
    super lineIncrement: anInteger.
    self isHandleOk ifTrue: [ self setLineIncrement ]! 
validate
        "Private - The host window for the receiver was
        just created or recreated."
    super validate.
    self setLineIncrement!   
setPosition
        "Private - Set the position of the host control."
    UserLibrary
        sendMessage: self handle
        msg: PbmSetpos
        wparam: self position
        lparam: 0!  
noTabStop
        "Make the receiver not be a tabstop.  Ignored
        for static controls because they can never be a tabstop."!