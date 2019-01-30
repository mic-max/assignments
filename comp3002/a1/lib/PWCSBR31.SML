3.1.0.106
   
PARTSScrollBar removePartRuntimeLibrary!  
partPrintColorAndFontPropertiesOn: aStream margin: aString
        " Private "
    self partPrintBackcolorOn: aStream margin: aString.! 
partEvents
        " Answer the PARTS event interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(#changed: #changing: #rightClicked #tabbed)
        separators: #( 1 )
        defaultItem: #changed:! 
partMessages
        " Answer the PARTS message interface of the receiver. "
    ^PARTSInterfaceList new
        items: #(
            #enable #disable #setFocus
            #value #setValue:)
        separators: #( 3 )
        defaultItem: #value!   
selection
        "Answer the position of the slider on the scrollbar control."
   ^self position!  
getValue
         "Private - Get the value of the receiver as a boolean."
    "self ASSERT: (self position = super getValue)."  " Don't need, right? [DJL 09-Jun-93] "
    ^self position! 
initialize
        " Private - initialize a new instance. "

    super initialize.
    self horizontal.!  
initialize
        " Private - initialize a new instance. "

    super initialize.
    self vertical.!
contents: aNumber
        "Set the position of the slider on the scrollbar control."
    | newPosition |

    newPosition := ( aNumber isNumber
        ifTrue: [aNumber]
        ifFalse: [
            (aNumber respondsTo: #asInteger)
                ifTrue: [aNumber asInteger]
                ifFalse: [self position] ] ).
    self position: newPosition.
    ^newPosition!  
contents
        "Answer the position of the slider on the scrollbar control."
    ^self position!  
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
  " ^(SysFont width * 16) @ (SysFont height * 2)"
    ^ self partFontOrSysFont width * 15
        @ ( OperatingSystem getSystemValue:
            ( SystemValueConstants at: 'SystemValueHorizontalScrollBarHeight'))!  
partDirectEditValue
        "Answer the direct edit value of the receiver."
    ^self value!
removePartRuntimeLibrary
        " Private - remove the ScrollBar parts runtime library.
        Remove the workbench support library if it was installed. "

    PARTSSessionManager removeWorkbenchSupportLibrary:
        ( PARTSSessionManager workbenchLibraryNameFor: self libraryName ).! 
partMirrorCopyReal: aMirrorCopyDictionary
        " Private - add a mirror copy of the receiver
        to <aMirrorCopyDictionary>.  Answer the copy. "

    | copy |
    copy := super partMirrorCopyReal: aMirrorCopyDictionary.
    copy
        minimum: self minimum;
        maximum: self maximum;
        lineIncrement: self lineIncrement;
        pageIncrement: self pageIncrement.
    ^copy! 
selection: anInteger
        "Set the position of the slider on the scrollbar control."
    self contents: anInteger!   
setValue: anInteger
        "Set the position of the slider on the scrollbar control to anInteger.
        Trigger the changed event.  Answer anInteger."
    | newValue |
    newValue := anInteger isNumber
        ifTrue: [ anInteger ]
        ifFalse: [
            [ anInteger asInteger ] on: MessageNotUnderstood do: [ :e | value ] ].
    newValue := ( newValue max: self minimum ) min: self maximum.
    ( anInteger ~= self value ) ifTrue: [
        self
            position: newValue;
            triggerChanging;
            triggerChanged ].
    ^anInteger!   
partEditDirect
        "Edit the directly visible part properties of the receiver."

    self partEditor workbenchPane lafEditNone: self.! 
installPartRuntimeLibrary
        " Private - install the ScrollBar parts runtime library.
        Load the workbench support library if appropriate. "

    PARTSSessionManager
        installWorkbenchSupportLibrary:
            ( PARTSSessionManager workbenchLibraryNameFor: self libraryName )
        for: 'ScrollBar Parts'.!
partDefaultExtent
        " Answer the default extent of the receiver
        in a PARTS application. "
  " ^(SysFont width * 4) @ (SysFont height * 6)"
    ^ ( OperatingSystem getSystemValue:
            ( SystemValueConstants at: 'SystemValueVerticalScrollBarWidth'))
        @ ( self partFontOrSysFont height * 6 )!