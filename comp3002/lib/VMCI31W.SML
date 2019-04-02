3.1.0.106
   
deviceName
        "Private - answer the name of this type of device."
    ^'AviVideo'! 
new
		"Answer a new instance of the receiver."
	^super new initialize!  
constructEventsTriggered
        "Private - answer the set of events that instances of the
        receiver can trigger."
    ^Set with: #playCompleted!   
deviceName
        "Private - answer the name of this type of device."
    self implementedBySubclass!  
unbound
		"Private - when uninstalled, unregister interest in the MM_MCINOTIFY message."
    OperatingSystemEvents removeKey: 16r3B9 "MmMcinotify" ifAbsent: [ nil ]!   
openDevices
        "Private - answer the Set of currently open MCI devices."
    OpenDevices isNil ifTrue: [ OpenDevices := Dictionary new ].
    ^OpenDevices!   
bound
		"Private - when installed, register for interest in the MM_MCINOTIFY message."
    OperatingSystemEvents at: 16r3B9 "MmMcinotify" put: #mmMcinotify:with:!  
getNextAliasIndex
        "Private - answer the next available alias index."
    | count |
    count := 1.
    [ self openDevices includesKey: count ] whileTrue: [ count := count + 1 ].
    ^count!
isTimeFormatFrames
		"Answer whether the time format is Frames."
	^self timeFormat = 'frames'!  
show
		"Show the receiver's window."
	self windowHandle showWindow! 
stringAsRectangle: aString
		"Private - convert the rectangle contained in aString, in the format
		handled by mci, to a Smalltalk Rectangle."
    | pieces |
    pieces := aString asArrayOfSubstrings collect: [ :s | s asInteger ].
    ^( ( pieces at: 1 ) @ ( pieces at: 2 ) )
        extentFromLeftTop: ( ( pieces at: 3 ) @ ( pieces at: 4 ) )! 
windowHandle
		"Private - answer a WindowHandle for the receiver's window."
	| int |
	int := ( self sendString: 'status ', self alias, ' window handle' ) asInteger.
	^WindowHandle fromInteger: int! 
resetForPlay
		"Private - reset the receiver to prepare for playing; for a video,
		reset to the beginning, in order to make play-to-end followed
		by another play not be a no-op."
	self reset! 
initialize
		"Initialize the value of reverse to false."
	self reverse: false!  
parentWindow
		"Answer the receiver's parent window."
    ^parentWindow!
playModifiers
		"Private - answer a String containing modifiers to the play command."
	^' notify', ( self reverse ifTrue: [ ' reverse' ] ifFalse: [ '' ] )! 
destinationRectangle: aRectangle
		"Set the current destination rectangle to aRectangle."
    self sendString: 'put ', self alias, ' destination at ', ( self rectangleAsString: aRectangle )!  
restoreWindowRectangle
		"Restore the window rectangle to its original position and size."
    self sendString: 'put ', self alias, ' window'

!  
realizePalette
		"Realize the receiver's palette."
	self sendString: 'realize ', self alias, ' normal'! 
restoreDestinationRectangle
		"Restore the destination rectangle to its original position and size."
    self sendString: 'put ', self alias, ' destination'!   
speed
		"Answer the playback speed ratio (1 is normal, less than 1 is slower, greater
		than 1 is faster)."
	^( self sendString: 'status ', self alias, ' speed' ) asInteger / 1000!   
speed: aNumber
		"Set the playback speed ratio to aNumber (1 is normal, less than 1 is slower,
		greater than 1 is faster)."
	^self sendString: 'set ', self alias, ' speed ', ( aNumber * 1000 ) truncated asString!  
hide
		"Hide the receiver's window."
	self windowHandle hideWindow! 
reverse
		"Answer whether playback is to be reversed."
	^reverse!   
configure
		"Open the device configuration dialog."
	self sendString: 'configure ', self alias! 
reverse: aBoolean
		"Set whether playback is to be reversed, according to aBoolean."
	reverse := aBoolean!  
sourceRectangle
		"Answer the current source rectangle."
    ^self stringAsRectangle: ( self sendString: 'where ', self alias, ' source' )! 
sourceRectangle: aRectangle
		"Set the current source rectangle to aRectangle."
    self sendString: 'put ', self alias, ' source at ', ( self rectangleAsString: aRectangle )! 
windowRectangle
		"Answer the current window rectangle."
    ^self stringAsRectangle: ( self sendString: 'where ', self alias, ' window' )! 
windowRectangle: aRectangle
		"Set the current window rectangle to aRectangle."
    self sendString: 'put ', self alias, ' window at ', ( self rectangleAsString: aRectangle )

! 
destinationRectangle
		"Answer the current destination rectangle."
    ^self stringAsRectangle: ( self sendString: 'where ', self alias, ' destination' )!  
audio
		"Answer whether audio output is enabled."
    ^( self sendString: 'status ', self alias, ' audio' ) = 'on'! 
audio: aBoolean
		"Turn audio output on or off, according to aBoolean."
    self sendString: 'set ', self alias, ' audio all ', ( aBoolean ifTrue: [ 'on' ] ifFalse: [ 'off' ] )!   
openCommandString
		"Private - answer the command string used to open the receiver."
    | command |
    command := super openCommandString.
    self parentWindow isNil
        ifTrue: [ command := command, ' style popup' ]
        ifFalse: [ command := command, ' style child parent ', self parentWindow handle asInteger asString ].
	^command!   
parentWindow: aWindow
		"Set the receiver's parent window to aWindow."
    parentWindow := aWindow! 
rectangleAsString: aRectangle
		"Private - answer the specified rectangle in the string format
		expected by mci."
    ^aRectangle left printString, ' ', aRectangle top printString, ' ',
        aRectangle width printString, ' ', aRectangle height printString!  
video
		"Answer whether video output is enabled."
    ^( self sendString: 'status ', self alias, ' video' ) = 'on'! 
timeFormatFrames
		"Set the time format to Frames."
	self timeFormat: 'frames'! 
video: aBoolean
		"Turn video output on or off, according to aBoolean."
    self sendString: 'set ', self alias, ' video ', ( aBoolean ifTrue: [ 'on' ] ifFalse: [ 'off' ] ).
    self parentWindow notNil ifTrue: [ self parentWindow invalidateRect: nil ]!  
restoreSourceRectangle
		"Restore the source rectangle to its original position and size."
    self sendString: 'put ', self alias, ' source'!  
open
		"Open the receiver, and display the first frame."
	super open.
	self position: 0; show! 
filename
		"Answer the current filename."
	^filename!   
openCommandString
		"Private - answer the command string used to open the receiver."
	^'open "', self filename, '" alias ', self alias! 
filename: aString
        "Set the current filename to aString."
    | open |
    ( open := self isOpen ) ifTrue: [ self close ].
    filename := aString.
    ( aString notNil and: [ open ] ) ifTrue: [ self open ]!   
open
		"Open the receiver, and cue to the first frame."
    super open.
    self position: 0!  
position
		"Answer the current position, in units of the current time format."
	^self sendString: 'status ', self alias, ' position'

!   
isReady
		"Answer whether the device state is 'Ready'."
	^( self sendString: 'status ', self alias, ' ready' ) = 'true'!
resume
		"Resume playback from the current position, following a pause."
    self sendString: 'resume ', self alias!
startPosition
		"Private - answer the starting position, in the current time format."
	^self sendString: 'status ', self alias, ' start position'!  
pause
		"Pause the receiver."
    self sendString: 'pause ', self alias!
resetForPlay
		"Private - reset the receiver to prepare for playing; do nothing
		for most MCI devices."!   
timeFormat
		"Answer a String which indicates the current time format."
	^self sendString: 'status ', self alias, ' time format'!   
playFrom: startFrame
		"Begin playing the receiver starting at the position indicated by startFrame."
    self sendString: 'play ', self alias, ' from ', startFrame printString, self playModifiers!   
playFrom: startFrame to: endFrame
		"Begin playing the receiver starting at the position indicated by startFrame, and
		stop playing when the position reaches endFrame."
    self sendString: 'play ', self alias, ' from ', startFrame printString, ' to ', endFrame printString, self playModifiers!
play
        "Begin playing the receiver starting at the current position."
    self isOpen ifFalse: [ self open ].
    self resetForPlay.
    self sendStringPrivate: 'play ', self alias, self playModifiers!   
playModifiers
		"Private - answer a String containing modifiers to the play command."
	^' notify'!  
stop
		"Stop playing."
    self sendString: 'stop ', self alias!
isPaused
		"Answer whether the device state is 'Paused'."
	^self mode = 'paused'!   
triggerPlayCompleted
		"Private - trigger the playCompleted event."
	self triggerEvent: #playCompleted! 
timeFormat: aTimeFormatString
		"Set the current time format to aTimeFormatString."
	self sendString: 'set ', self alias, ' time format ', aTimeFormatString!   
isPlaying
		"Answer whether the device state is 'Playing'."
	^self mode = 'playing'!
position: anIntegerOrString
		"Set the current position to anIntegerOrString (in units of the current time format).
		A String is permitted so that non-integer time formats can be specified."
    self sendString: 'seek ', self alias, ' to ', anIntegerOrString asString!  
length
		"Answer the length of the receiver, in the current time format."
	^self sendString: 'status ', self alias, ' length'!  
isStopped
		"Answer whether the device state is 'Stopped'."
	^self mode = 'stopped'!
timeFormatMilliseconds
		"Set the time format to Milliseconds."
	self timeFormat: 'milliseconds'!   
mode
		"Private - answer the current mode."
    ^self sendString: 'status ', self alias, ' mode'!   
playNoReset
        "Begin playing the receiver starting at the current position."
    self isOpen ifFalse: [ self open ].
    self sendStringPrivate: 'play ', self alias, self playModifiers!
isSeeking
		"Answer whether the device state is 'Seeking'."
	^self mode = 'seeking'!
isNotReady
		"Answer whether the device state is 'Not Ready'."
	^self mode = 'not ready'!   
isTimeFormatMilliseconds
		"Answer whether the time format is Milliseconds."
	^self timeFormat = 'milliseconds'!
reset
		"Reset the position to the beginning."
	self position: self startPosition!  
deviceName
        "Private - answer the name of this device."
    ^self class deviceName!  
openCommandString
		"Private - answer the command string used to open the receiver."
	^'open ', self deviceName, ' alias ', self alias! 
sendString: commandString
        "Private - issue the specified mci command, and answer the result string."
    self isOpen ifFalse: [ self open ].
    ^self sendStringPrivate: commandString!   
printOn: aStream
        "Append the ASCII representation of the receiver to aStream."
    super printOn: aStream.
    self alias notNil ifTrue: [ aStream nextPutAll: '{ alias = ', self alias, ' }' ]!   
close
        "Close the receiver."
    | commandString aliasIndex |
    self isOpen ifFalse: [ ^self ].
    commandString := 'close ', self alias.
    self sendStringPrivate: commandString.
    aliasIndex := ( self alias asStream upTo: $. ; nextLine ) asInteger.
    self class openDevices removeKey: aliasIndex.
    self alias: nil!
isOpen
        "Answer whether the receiver device has been opened."
    ^self alias notNil!
alias
		"Private - answer the alias name of the receiver."
    ^alias!  
alias: aString
		"Private - set the alias name of the receiver to aString."
    alias := aString!   
sendStringPrivate: commandString
        "Private - issue the specified mci command, and answer the result string
        (without first attempting to open the device)."
    | dll buffer errorCode |
    dll := MultimediaDLL current.
    buffer := String new: 255.
    errorCode := dll
        mciSendString: commandString asParameter
        return: buffer
        length: buffer size
        callbackWindow: SystemWindow current handle.
    errorCode > 0 ifTrue: [
        dll mciGetErrorString: errorCode buffer: buffer length: buffer size.
        buffer := buffer trimNullTerminator asNormalizedString.
        ^self error: buffer ].
    ^buffer trimNullTerminator asNormalizedString!   
open
        "Open the receiver."
    | aliasIndex |
    aliasIndex := self class getNextAliasIndex.
    self class openDevices at: aliasIndex put: self.
    self alias: self deviceName, '.', aliasIndex asString.
    self sendStringPrivate: self openCommandString!
deviceName
        "Private - answer the name of this type of device."
    ^'WaveAudio'!
deviceName
        "Private - answer the name of this type of device."
	^'CdAudio'! 
audio: aBoolean
		"Turn audio on or off, according to aBoolean."
    self sendString: 'set ', self alias, ' audio all ', ( aBoolean ifTrue: [ 'on' ] ifFalse: [ 'off' ] )!  
mediaIdentifier
        "Answer a number which uniquely identifies the current media."
    ^( self sendString: 'info ', self alias, ' identity' ) asInteger!
isTimeFormatMsf
		"Answer whether the time format is Minutes/Seconds/Frames."
	^self timeFormat = 'msf'!
audioRight: aBoolean
		"Turn right channel audio on or off, according to aBoolean."
    self sendString: 'set ', self alias, ' audio right ', ( aBoolean ifTrue: [ 'on' ] ifFalse: [ 'off' ] )! 
currentTrack
		"Answer the current track number."
	^( self sendString: 'status ', self alias, ' current track' ) asInteger! 
timeFormatTmsf
		"Set the time format to Tracks/Minutes/Seconds/Frames."
	self timeFormat: 'tmsf'!  
isMediaPresent
        "Answer whether any media is present in the device."
    ^( self sendString: 'status ', self alias, ' media present' ) = 'true'! 
resume
		"Resume playback from the current position, following a pause.
		Superclass implementation overridden, because the mci resume
		command is not supported by the CdAudio device, but can be
		emulated by sending a play command (which resumes from the
		current position)."
	self playNoReset!   
close
        "Close the receiver."
    self stop.  "in case still playing."
    super close!  
currentTrack: trackNumber
        "Set the current track number to trackNumber."
    | timeFormat playing |
    playing := self isPlaying.
    self stop.
    timeFormat := self timeFormat.
    self timeFormatTmsf.
    self positionTrack: trackNumber minute: 0 second: 0 frame: 0.
    playing ifTrue: [ self play ].
    self timeFormat: timeFormat!  
positionMinute: minute second: second frame: frame
		"Set the current position to minute, second, frame (assuming
		the receiver is in msf time format)."
	self position: minute asString, ':', second asString, ':', frame asString!  
isDoorOpen
		"Answer whether the drive door is open."
	^self mode = 'open'! 
isTimeFormatTmsf
		"Answer whether the time format is Tracks/Minutes/Seconds/Frames."
	^self timeFormat = 'tmsf'!   
closeDoor
		"Close the device door."
	self sendString: 'set ', self alias, ' door closed'!  
lengthOfTrack: trackNumber
		"Answer the length of the track specified by trackNumber,
		in units of the current time format."
	^self sendString: 'status ', self alias, ' length track ', trackNumber asString!   
openDoor
		"Open the device door (eject)."
	self sendString: 'set ', self alias, ' door open'!  
numberOfTracks
		"Answer the number of tracks on the current media."
	^( self sendString: 'status ', self alias, ' number of tracks' ) asInteger!   
positionOfTrack: trackNumber
		"Answer the position of the beginning of the track specified by trackNumber,
		in units of the current time format."
	^self sendString: 'status ', self alias, ' position track ', trackNumber asString!
positionTrack: track minute: minute second: second frame: frame
		"Set the current position to track, minute, second, frame (assuming
		the receiver is in tmsf time format)."
	self position: track asString, ':', minute asString, ':', second asString, ':', frame asString!
audioLeft: aBoolean
		"Turn left channel audio on or off, according to aBoolean."
    self sendString: 'set ', self alias, ' audio left ', ( aBoolean ifTrue: [ 'on' ] ifFalse: [ 'off' ] )!
resetForPlay
		"Private - reset the receiver to prepare for playing; do nothing
		for most MCI devices."
	self currentTrack: self currentTrack  "reset to beginning of track"! 
timeFormatMsf
		"Set the time format to Minutes/Seconds/Frames."
	self timeFormat: 'msf'!   
mmMcinotify: wparam with: lparam
        "Private - process MCI notifications."
	| device |
	wparam = 1 "MciNotifySuccessful" ifTrue: [
		device := MciDevice openDevices at: lparam ifAbsent: [ ^nil ].
		device triggerPlayCompleted ].
	wparam = 2 "MciNotifySuperseded" ifTrue: [ ].
	wparam = 4 "MciNotifyAborted" ifTrue: [ ].
	wparam = 8 "MciNotifyFailure" ifTrue: [ ].
    ^nil!   
fileName
        "Answer the receiver's file name."
    ^'winmm.dll'!   
mciSendCommand: deviceID
        message: message
        param1: param1
        param2: param2
    <api: mciSendCommandA ulong ulong ulong ulong ulongReturn>
    ^self invalidArgument!
mciGetErrorString: errorInteger
        buffer: bufferString
        length: anInteger
    <api: mciGetErrorStringA ulong struct ulong boolean>
    ^self invalidArgument!
mciSendString: commandString
        return: returnString
        length: anInteger
        callbackWindow: hwnd
    <api: mciSendStringA struct struct ulong ulong ulongReturn>
    ^self invalidArgument!  
isTimeFormatBytes
		"Answer whether the time format is Bytes."
	^self timeFormat = 'bytes'! 
timeFormatSamples
		"Set the time format to Samples."
	self timeFormat: 'samples'!  
isTimeFormatSamples
		"Answer whether the time format is Samples."
	^self timeFormat = 'samples'!   
samplesPerSecond
		"Answer the number of samples per second for the current media."
	^( self sendString: 'status ', self alias, ' samplespersec' ) asInteger!   
bytesPerSecond
		"Answer the number of bytes per second for the current media."
	^( self sendString: 'status ', self alias, ' bytespersec' ) asInteger! 
timeFormatBytes
		"Set the time format to Bytes."
	self timeFormat: 'bytes'!
bitsPerSample
		"Answer the number of bits per sample for the current media."
	^( self sendString: 'status ', self alias, ' bitspersample' ) asInteger! 
channels
		"Answer the number of channels for the current media."
	^( self sendString: 'status ', self alias, ' channels' ) asInteger!  
amountToPageUp
        "Private - Answer the number of pixels for vertical page scrolling."
    ^self rectangleAttribute height // 2!   
stretch
		"Answer whether the receiver stretches its contents to fit the receiver's
		current size."
	^stretch!
stretch: aBoolean
		"Set whether the receiver stretches its contents to fit the receiver's
		current size, according to the value of aBoolean."
	stretch := aBoolean.
    self isHandleOk ifTrue: [ self resize: self parent rectangle ]! 
amountToScrollLeft
        "Private - Answer the number of pixels for horizontal line scrolling."
    ^self rectangleAttribute width // 8!  
updateVerticalSlider
        "Private - Update the vertical slider position."
   ( UserLibrary
        setScrollPos: self handle
        bar: SbVert
        position: self topCorner y
        redraw: true ) = 0
            ifTrue: [ self osNotification ]!
contents: aVideo
		"Set the contents of the receiver to aVideo."
    self video: aVideo!
scrollTopCornerTo: aNewCorner
        "Private - scroll topCorner to aNewCorner"
    self scrollTopCorner: self topCorner - aNewCorner! 
totalLength
        "Private - Answer the number of vertical units (pixels)."
    ^self video isNil ifTrue: [ 0 ] ifFalse: [ self video windowRectangle height ]!   
canTab
        "Private - VideoPanes do not take focus, so cannot
        be tabbed into."
    ^false! 
initialize
        "Private - Initialize the receiver."
	super initialize.
	self stretch: false!   
updateHorizontalSlider
        "Private - Update the horizontal slider position."
   ( UserLibrary
        setScrollPos: self handle
        bar: SbHorz
        position: self topCorner x
        redraw: true ) = 0
            ifTrue: [ self osNotification ]!
resize: aRectangle
        "Private - The receiver's size was changed, reposition the
        video and update scrollbar settings accordingly."
    super resize: aRectangle.
    ( self video notNil and: [ self video isOpen not ] )
        ifTrue: [ self video: self video ].  "this will open the video"
    self setScrollRanges.
    self video notNil ifTrue: [
        self stretch
            ifTrue: [ self video windowRectangle: self rectangle ]
            ifFalse: [ self video restoreWindowRectangle ] ]!  
scrollTopCorner: aPoint
        "Private - move the contents of the receiver pane by extent aPoint."
    | pt rect newCorner maxCorner |
    Process enableInterrupts: false.
    pt := aPoint.
    newCorner := self topCorner - aPoint.

    maxCorner := self maxTopCorner.
    newCorner x > maxCorner x ifTrue: [
        newCorner x: maxCorner x.
        pt x: ( maxCorner x - self topCorner x ) negated ].
    newCorner x < 1 ifTrue: [
        newCorner x: 1.
        pt x: self topCorner x ].
    newCorner y > maxCorner y ifTrue: [
        newCorner y: maxCorner y.
        pt y: ( maxCorner y - self topCorner y ) negated ].
    newCorner y < 1 ifTrue: [
        newCorner y: 1.
        pt y: self topCorner y ].

    newCorner = self topCorner ifFalse: [
    self topCornerAttribute: newCorner.
    rect := self video destinationRectangle moveBy: pt.
    self video destinationRectangle: rect.
    Process enableInterrupts: true ]!   
setScrollRanges
        "Private - Set the ranges for the horizontal and vertical scroll bars."
    | minHorz maxHorz minVert maxVert maxCorner |
    ( self video isNil or: [ self stretch ] )
        ifTrue: [ minHorz := maxHorz := minVert := maxVert := 0 ]
        ifFalse: [
            maxCorner := self maxTopCorner.
            minHorz := 1.
            maxHorz := maxCorner x.
            maxHorz < 1 ifTrue: [ minHorz := maxHorz := 0 ].
            minVert := 1.
            maxVert := maxCorner y.
            maxVert < 1 ifTrue: [ minVert := maxVert := 0 ].
            ( self hasHorizontalScrollBarStyle ) ifFalse: [ minHorz := maxHorz := 0 ].  "hide scrollbar if not needed"
            ( self hasVerticalScrollBarStyle ) ifFalse: [ minVert := maxVert := 0 ] ].  "hide scrollbar if not needed"
    ( UserLibrary setScrollRange: self handle bar: SbHorz min: minHorz max: maxHorz redraw: false )
        ifFalse: [ ^self osError ].
    ( UserLibrary setScrollRange: self handle bar: SbVert min: minVert max: maxVert redraw: false )
        ifFalse: [ ^self osError ]!
defaultStyle
        "Private - Answer an Integer with appropriate styles in it."
    ^WsBorder | WsHscroll | WsVscroll!
validate
        "Private - The host window for the receiver was just created or recreated."
    super validate.
    self setContents! 
scrollHorizontal: anInteger
		"Private - Scroll the pane right by anInteger number of pixels (if positive)
		or left by the absolute value of anInteger (if negative)."
    self scrollTopCorner: anInteger  @ 0!  
setContents
		"Private - set the initial contents of the receiver."
    self video notNil ifTrue: [ self video: self video ]!   
isATabStop
        "Private - Answer whether the receiver is a tabstop"
    ^false! 
totalWidth
        "Private - Answer the number of horizontal units (pixels)."
    ^self video isNil ifTrue: [ 0 ] ifFalse: [ self video windowRectangle width ]!   
amountToScrollUp
        "Private - Answer the number of pixels for vertical line scrolling."
    ^self rectangleAttribute height // 8! 
close
		"Private - close the receiver."
    self video notNil ifTrue: [ self video close ].
    ^super close!  
contents
		"Answer the contents of the receiver."
    ^self video!  
defaultExtendedStyle
        "Private - answer the default extended style flags for the
        receiver.  Add the 3d border style."
    ^OperatingSystem versionMajor >= 4 ifTrue: [ WsExClientedge ] ifFalse: [ 0 ]! 
video
		"Answer the contents of the receiver."
    ^video!  
video: aVideo
        "Set the contents of the receiver to aVideo."
    ( video notNil and: [ video isOpen ] ) ifTrue: [ video close ].
    video := aVideo.
    ( video notNil and: [ self isHandleOk ] ) ifTrue: [
        video parentWindow: self.
        video open.
        self topCornerAttribute: 1@1.
        self setScrollRanges ]!  
amountToPageLeft
        "Private - Answer the number of pixels for horizontal page scrolling."
    ^self rectangleAttribute width // 2!
maxTopCorner
		"Private - answer a Point which is the maximum value of topCorner,
		given the current video and receiver extent."
    | windowRect videoRect |
    self video isNil ifTrue: [ ^1@1 ].
    windowRect := self rectangleAttribute.
    videoRect := self video sourceRectangle.
    ^( ( videoRect width - windowRect width - 1 ) max: 0 ) @
        ( ( videoRect height - windowRect height - 1 ) max: 0 )!   
mmMcinotify: wparam with: lparam
        "Private - process MCI notifications."
    ^nil!