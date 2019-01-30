3.1.0.106
   
backColor: aColor
        "Set the background color of the receiver.  To work around a bug in the
        host control, recreate the pane to cause the new background color to
        take effect."
    super backColor: aColor.
    self isHandleOk ifTrue: [ self recreateWindow ]!   
pageIncrement: anInteger
        "Set the page increment to be anInteger."
    pageIncrement := anInteger.
    self isHandleOk ifTrue: [ self setPageIncrement ]!  
notifyNextPage: aParameter
        "Private - process the next page notification."
    self valueAttribute: self getPosition.
    self triggerEvent: #nextPage.
    self triggerChanging! 
getLineIncrement
        "Private - retrieve the current line increment from the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TbmGetlinesize
        wparam: 0
        lparam: 0!  
selectionEnd: anInteger
        "Private - set the end of the range selection to anInteger."
    self isHandleOk ifFalse: [ ^self whenValid: #selectionEnd: with: anInteger ].
    UserLibrary
        sendMessage: self handle
        msg: TbmSetselend
        wparam: true asParameter
        lparam: anInteger!  
notifyNextLine: aParameter
        "Private - process the next line notification."
    self valueAttribute: self getPosition.
    self triggerEvent: #nextLine.
    self triggerChanging! 
buildWindow: parentWindow
        "Private - Create the window for the receiver, initializing the
        common controls library if necessary."
    CommonControlsDLL current.
    ^super buildWindow: parentWindow! 
notifySliderTrack: aParameter
        "Private - process the notification which is received while the slider is
        being moved continuously."
    self valueAttribute: self getPosition.
    self triggerChanging!   
notifyHome: aParameter
        "Private - process the Home key notification."
    self valueAttribute: self getPosition.
    self triggerEvent: #home.
    self triggerChanging!  
keyboardInput: aKeyboardInputEvent
        "Private - keyboard input was received.  Process cursor keys."
    | virtualKey |
    ( virtualKey := aKeyboardInputEvent virtualKey ) notNil ifTrue: [
        ( virtualKey == TabKey or: [ virtualKey == BacktabKey ] )
            ifTrue: [ self tabKeyInput: aKeyboardInputEvent ] ].

    super keyboardInput: aKeyboardInputEvent!   
lineIncrement: anInteger
        "Set the line increment to be anInteger."
    lineIncrement := anInteger.
    self isHandleOk ifTrue: [ self setLineIncrement ]!  
ticks: anArray
        "Set the Array of tick mark positions to anArray."
    self ticksAttribute: anArray.
    self isHandleOk ifTrue: [ self setTicks ]! 
ticksAttribute: anArray
        "Private - set the ticks instance variable without notifying the host control."
    ticks := anArray!   
notifySliderPosition: aParameter
        "Private - process the notification which is received when the slider finished moving."
    self valueAttribute: self getPosition! 
notifyPreviousLine: aParameter
        "Private - process the previous line notification."
    self valueAttribute: self getPosition.
    self triggerEvent: #previousLine.
    self triggerChanging! 
notifyEndScroll: aParameter
        "Private - process the notification which signals that scrolling has completed."
    self triggerChanged!   
canApplyStyle
        "Private - answer whether the receiver's style can change
        after it has been created."
    self osWorkaround.  "changing styles via SetWindowLong fails on NT 3.51"
    ^OperatingSystem isWindowsNT not!
ticks
        "Answer the Array of tick mark positions."
    ^ticks!
vertical
        "Answer an instance of a vertical scrollbar."
    ^self new vertical; yourself!
getPageIncrement
        "Private - retrieve the current page increment from the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TbmGetpagesize
        wparam: 0
        lparam: 0!  
selectionStart: anInteger
        "Private - set the start of the range selection to anInteger."
    self isHandleOk ifFalse: [ ^self whenValid: #selectionStart: with: anInteger ].
    UserLibrary
        sendMessage: self handle
        msg: TbmSetselstart
        wparam: true asParameter
        lparam: anInteger!  
constructNotifications
        "Private - answer the mapping between host control
        notification codes and corresponding Smalltalk event
        notifications."
    ^Dictionary new
        at: TbLineup put: #notifyPreviousLine: ;
        at: TbLinedown put: #notifyNextLine: ;
        at: TbPageup put: #notifyPreviousPage: ;
        at: TbPagedown put: #notifyNextPage: ;
        at: TbThumbposition put: #notifySliderPosition: ;
        at: TbThumbtrack put: #notifySliderTrack: ;
        at: TbTop put: #notifyHome: ;
        at: TbBottom put: #notifyEnd: ;
        at: TbEndtrack put: #notifyEndScroll: ;
        yourself!
notifyEnd: aParameter
        "Private - process the End key notification."
    self valueAttribute: self getPosition.
    self triggerEvent: #end.
    self triggerChanging! 
notifyPreviousPage: aParameter
        "Private - process the previous page notification."
    self valueAttribute: self getPosition.
    self triggerEvent: #previousPage.
    self triggerChanging! 
addTick: anInteger
        "Add a tick mark at the given position (which is a position within
        the current range."
    self ticksAttribute: ( self ticks copyWith: anInteger ).
    self isHandleOk ifTrue: [ self setTick: anInteger ]!   
ticksLeft
        "Set the style which indicates that tick marks are displayed on the
        left (vertical)."
    self removeStyle: TbsRight.
    self removeStyle: TbsBoth.
    self addStyle: TbsLeft.
    self setStyle: self style!   
windowClass
        "Private - Answer the receiver's window class."
    ^TrackbarClass! 
ticksTop
        "Set the style which indicates that tick marks are displayed on the
        top (horizontal)."
    self removeStyle: TbsBottom.
    self removeStyle: TbsBoth.
    self addStyle: TbsTop.
    self setStyle: self style!   
getPosition
        "Private - retrieve the current position from the host control."
    ^UserLibrary
        sendMessage: self handle
        msg: TbmGetpos
        wparam: 0
        lparam: 0!  
isHorizontal
        "Answer whether the receiver is horizontal style.
        Query the vertical style bits, since the value of the horizontal
        style is 0 on Win32."
    ^self isVertical not!   
setPosition
        "Private - Set the position of the host control."
    UserLibrary
        sendMessage: self handle
        msg: TbmSetpos
        wparam: true asParameter
        lparam: self position!   
setRange
        "Private - update the host control's range (minimum and maximum)."
    UserLibrary
        sendMessage: self handle
        msg: TbmSetrange
        wparam: true asParameter
        lparam: ( ExternalLong lowHalf: self minimum highHalf: self maximum ) asParameter!   
ticksRight
        "Set the style which indicates that tick marks are displayed on the
        right (vertical)."
    self removeStyle: TbsLeft.
    self removeStyle: TbsBoth.
    self addStyle: TbsRight.
    self setStyle: self style! 
isVertical
        "Answer whether the receiver is vertical style."
    ^self hasStyle: TbsVert!
setMaximum
        "Private - update the host control's maximum value."
    UserLibrary
        sendMessage: self handle
        msg: TbmSetrangemax
        wparam: 0
        lparam: self maximum!
ticksBottom
        "Set the style which indicates that tick marks are displayed on the
        bottom (horizontal)."
    self removeStyle: TbsTop.
    self removeStyle: TbsBoth.
    self addStyle: TbsBottom.
    self setStyle: self style! 
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^TbsHorz! 
vertical
        "Set the vertical style."
    self removeStyle: TbsHorz.
    self addStyle: TbsVert.
    self setStyle: self style!  
validate
        "Private - The host window for the receiver was
        just created or recreated."
    super validate.
    self setLineIncrement.
    self setPageIncrement.
    self setTicks!   
clearTicks
        "Private - clear all tick marks from the host control, without
        changing the current value of the ticks instance variable."
    UserLibrary
        sendMessage: self handle
        msg: TbmCleartics
        wparam: 0
        lparam: 0.
    self invalidateRect: nil!   
horizontal
        "Set the horizontal style."
    self removeStyle: TbsVert.
    self addStyle: TbsHorz.
    self setStyle: self style!  
setMinimum
        "Private - update the host control's minimum value."
    UserLibrary
        sendMessage: self handle
        msg: TbmSetrangemin
        wparam: 0
        lparam: self minimum!
setTick: anInteger
        "Private - add a tick mark to the host control at the specified position."
    UserLibrary
        sendMessage: self handle
        msg: TbmSettic
        wparam: 0
        lparam: anInteger!  
setLineIncrement
        "Private - update the host control's line increment."
    UserLibrary
        sendMessage: self handle
        msg: TbmSetlinesize
        wparam: 0
        lparam: self lineIncrement!   
initialize
        "Private - initialize the receiver instance."
    super initialize.
    self ticksAttribute: Array new! 
setPageIncrement
        "Private - update the host control's page increment."
    UserLibrary
        sendMessage: self handle
        msg: TbmSetpagesize
        wparam: 0
        lparam: self pageIncrement!   
horizontal
        "Answer an instance of a horizontal scrollbar."
    ^self new horizontal; yourself!  
setTicks
        "Private - update the host control's tick marks."
    self clearTicks.
    self ticks do: [ :tick | self setTick: tick ]! 
ticksBoth
        "Set the style which indicates that tick marks are displayed on both
        left and right (vertical) or top and bottom (horizontal)."
    self removeStyle: TbsLeft.  "a.k.a. TbsTop"
    self removeStyle: TbsRight.  "a.k.a. TbsBottom"
    self addStyle: TbsBoth.
    self setStyle: self style!