"3.0.0.9"
!

!EntryField methods ! 
selectAll
        "Select the entire text of the  receiver."

	#modifiedByOSI.
	"Commented out this line to prevent cascading focus changes."
    "self mainWindow activeTextPane: self."

    self isHandleOk
        ifTrue: [ self selectFrom: 1 to: self windowTextLength + 1 ]
        ifFalse: [ self whenValid: #selectAll ]! !

!DialogTopPane methods !   
mainWindow
        "Answer the receiver's main window.  If the DialogTopPane's
          parent is kind of Window then it returns its parent's main
          window else it returns self. (Needed for cases where
          DialogTopPane is a subpane of TopPane.)"
    ^(owner notNil)
        ifTrue: [
			#modifiedByOSI.
			"Avoid asking for a view that hasn't been created."
			(owner views size < 1)
				ifTrue: [self]
				ifFalse: [owner mainView]]
        ifFalse: [self]! !

!Object methods ! 
osError: anInteger
		"Create a walkback window describing an error condition
		that was returned from the host operating system, as
		indicated by anInteger"
	#modifiedByOSI.
	anInteger == 0 ifTrue: [^self]. "No error actually occured!!" 
	^Error signal: (self osErrorMessage: anInteger), ' (OS error ', (anInteger radix: 16), ')'! !

!ApplicationWindow methods !   
closeInnerWindows
        "Private - close the inner windows in the view.
        Answer whether successful."
    | inner |
    inner := OrderedCollection new.
    Notifier windows do: [:w|
        ((w == self) not and: [
        w isApplicationWindow and: [
            w isHandleOk and:[

					"Modified by OSI to fix problem with closing children"
					#modifiedByOSI.
                (self hasDescendant: w) or: [self owner == w parent and: [self owner notNil]]]]])
                    ifTrue: [inner add: w]].

    inner do: [:w| w textModified ifTrue: [^false] ifFalse: [w clearTextModified]].
    inner do: [:w| w close].
    self textModified ifTrue: [^false].
    ^true! !

!StaticPane methods !  
subclassRecursively
        "Private - subclass the children."

	#modifiedByOSI.
	"Use the super method so that #subclassWndProc is called
		and the static pane receives user input events from the OS."
	self owner isWBWindow ifTrue: [^super subclassRecursively].

    children size > 0 ifTrue: [
        children do: [ :child | child subclassRecursively ] ]! !

!String methods !
equalsIgnoreCase: aString
        "Answer true if the receiver is equal to aString, else answer
        false.  The comparison is not case sensitive."

	#modifiedByOSI.
	"Base Image Fix (may be fixed in GA):
		If the receiver or aString is an emtpy string
		and the other is *not* an empty string,
		then the original method would incorrectly return true."
	self size = aString size ifFalse: [^false].

    ^self <= aString and: [(self < aString) not]! !

!Button methods !
restoreDefaultPushButton
        "Private - If the button was not the original default
        push button, then restore the default push button style
        to the original."
    | originalDefaultButton |
    originalDefaultButton := self mainWindow defaultPushButton.
    originalDefaultButton ~~ self
        ifTrue: [ self pushButton; setDefault: false ].
    originalDefaultButton notNil
        ifTrue: [

            "Modified by OSI to fix problem with disabled buttons becoming enabled"
            #modifiedByOSI.
            originalDefaultButton disabled not
                ifTrue: [

                    originalDefaultButton defaultPushButton; setDefault: true ] ]! !
 
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!