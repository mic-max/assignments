"3.0.0.3"
!  

DrawnButton subclass: #ActionButton
  instanceVariableNames: 
    ' action '
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!   

DrawnButton subclass: #LinkButton
  instanceVariableNames: 
    ' link type '
  classVariableNames: ''
  poolDictionaries: 
    ' OperatingSystemConstants '!  

WBObject subclass: #WBAction
  instanceVariableNames: 
    ' receiver originator script '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '!

!LinkButton methods !  
performAction
        "Private - Deferred control message handling routine."

    [ self perform: self type ]
        on: Error
        do: [ :error |
            self linkClass isNil ifTrue: [
                ^MessageBox message: 'Missing Link [',self link asString,']!!'. ].
            (self respondsTo: self type) ifFalse: [
                ^MessageBox message: 'Invalid link type [',self type asString,']!!!!' ].
            error defaultAction ]! !

!ActionButton methods !   
action: aSymbol
		"Specify the action to be performed by the button when it is clicked.
			To get a list of available actions do the following:
			WBAction listActions inspect. New actions may be created with
			the ActionButton attribute editor."
    action := aSymbol! !

!ActionButton methods !  
performAction
        "Private - Deferred control message handling routine."

    self action notNil ifTrue: [
        WBAction
            perform: self action
            on: self topParent owner
            with: self ].! !

!LinkButton class methods !  
supportedEvents
        "Private - Answer the Set of events that LinkButtons can notify
         their owners about."
    ^super supportedEvents
        remove: #clicked;
        yourself! !

!Menu methods !
wbAction
    "Added by OSI"
    #addedByOSI.
	#obsoleteMethod.
    ^WBAction! !

!LinkButton methods !  
notifyDoubleClicked: aParameter
        "Private - Deferred control message handling routine."

    self performAction.! !

!LinkButton methods !
type: aSymbol
		"Specify the type of link that should be performed.
			The allowable choices are: #Independent, #Child, and #Sibling."
    type := aSymbol! !

!Menu methods !   
appendItem: aLabelString action: aSymbol acceleratorString: aString
    "Added by OSI - create a menu item that performs an action"
    | aMessage |
    #addedByOSI.
	self obsoleteMethod.
    aMessage := (Message new)
            receiver: (self wbAction window: self owner action: aSymbol)
            selector: #perform
            arguments: #()
            yourself.

    self appendItem: aLabelString selector: aMessage acceleratorString: aString! !

!WBAction methods !  
isWBAction

    ^true! !

!WBAction methods ! 
actionCancel
"
Created by OSI - Jan 26, 1993
"
"Close the window"
    ^self window close! !

!WBAction methods !   
receiver: anObject

    receiver := anObject.
    ^self! !

!LinkButton methods !
link
		"Answer the ViewManager subclass to which the button should link."
    ^link! !

!WBAction methods !   
originator: anObject

    originator := anObject.
    ^self! !

!LinkButton methods !
notifyClicked: aParameter
        "Private - Deferred control message handling routine."

    self performAction.! !

!LinkButton methods !  
Sibling
    "Private - Open the link as an sibling window."

    ^self linkClass new openWithMyParent: self owner! !

!WBAction class methods !  
perform: aSymbol on: aViewManager

    ^(self window: aViewManager action: aSymbol) perform! !

!WBAction methods !   
receiver

    ^receiver! !

!Menu methods !   
appendItem: aLabelString link: aViewManagerClassName type: linkType acceleratorString: aString
    "Added by OSI - create a menu item that links to another window"
    | aMessage |
    #addedByOSI.
    self obsoleteMethod.
    (Smalltalk includesKey: aViewManagerClassName asSymbol) ifFalse: [
        aMessage := (Message new)
            receiver: MessageBox selector: #message:
                arguments: #('Link Menu Error!!');
            yourself.
    ] ifTrue: [
        aMessage := Message new.
        aMessage receiver: (Smalltalk at: aViewManagerClassName asSymbol).
        linkType asSymbol == #Child ifTrue: [
            aMessage selector: #openWithParent:; arguments: (Array with: self owner).
        ] ifFalse: [ linkType asSymbol == #Sibling ifTrue: [
            aMessage selector: #openWithMyParent:; arguments: (Array with: self owner).
        ] ifFalse: [ linkType asSymbol == #MDIChild ifTrue: [
            aMessage selector: #openWithMDIParent:; arguments: (Array with: self owner).
        ] ifFalse: [
            aMessage selector: #open; arguments: #().
        ]]].
    ].
    self appendItem: aLabelString selector: aMessage acceleratorString: aString! !

!WBAction class methods !   
receiver: anObject

    ^self new receiver: anObject! !

!WBAction class methods !
window: aViewManager action: aSymbol

    ^(self new)
        receiver: aViewManager;
        script: aSymbol! !

!WBAction class methods ! 
receiver: firstObject originator: secondObject

    ^(self new)
        receiver: firstObject;
        originator: secondObject! !

!WBAction class methods !   
window: aViewManager

    ^self new receiver: aViewManager! !

!LinkButton methods !  
MDIChild
    "Private - Open the link as an MDI child window."

    ^self linkClass new openWithMDIParent: self owner! !

!WBAction methods !
target

    ^receiver! !

!LinkButton methods !   
linkClass
    "Private - Answer the link class of the receiver."

    ^Smalltalk at: self link ifAbsent: [ nil ]! !

!ActionButton methods ! 
notifyClicked: aParameter
        "Private - Deferred control message handling routine."

    self performAction.! !

!ActionButton methods !
notifyDoubleClicked: aParameter
        "Private - Deferred control message handling routine."

    self performAction.! !

!ActionButton methods !  
action
		"Answer the action to be performed by the button when it is clicked."
    ^action! !

!WBAction methods !
button

    ^originator! !

!ActionButton class methods ! 
supportedEvents
        "Private - Answer the Set of events that ActionButtons can notify
         their owners about."
    ^super supportedEvents
        remove: #clicked;
        yourself! !

!WBAction methods !  
perform

    self receiver isNil ifTrue: [
        ^MessageBox message: 'Receiver not defined!!'
    ] ifFalse: [self script isString ifTrue: [
        (self class listActions includes: self script asString) ifTrue: [
            ^self perform: ('action',self script) asSymbol
        ] ifFalse: [
            ^self missingAction: self script
        ]
    ] ifFalse: [ self script isCollection ifTrue: [
        self script do: [ :action |
            (self class listActions includes: action asString) ifTrue: [
                self perform: ('action',action) asSymbol
            ] ifFalse: [
                ^self missingAction: action
            ]
        ].
    ]]].! !

!WBAction methods ! 
actionInspect
"
Created by OSI - Jan 26, 1993
"
"Inspect the window"
    ^self window inspect! !

!WBAction class methods !
performAction: aSymbol

    ^(self new script: aSymbol) perform! !

!WBAction class methods ! 
listActions

    | list class |
	list := OrderedCollection new.
    class := self.
    [ class name = 'Object' ] whileFalse: [
        list addAll:
            ((class methodDictionary keys asSortedCollection select: [ :selector |
                selector beginsWith: 'action' ]) collect: [ :method |
                    method copyFrom: 7 to: method size ]).
        class := class superclass
    ].
    ^list! !

!LinkButton methods !
type
		"Answer the type of link that should be performed."
    ^type! !

!WBAction class methods !
window: aViewManager button: anActionButton action: aSymbol

    ^(self new)
        receiver: aViewManager;
        originator: anActionButton;
        script: aSymbol! !

!LinkButton methods ! 
Independent
    "Private - Open the link as an independent window."

    ^self linkClass new open! !

!WBAction methods !
window

    ^receiver! !

!LinkButton methods !   
Child
    "Private - Open the link as an child window."

    ^self linkClass new openWithParent: self owner! !

!WBAction methods !  
originator

    ^originator! !

!WBAction methods !   
menuItem

    ^originator! !

!WBAction class methods !   
perform: aSymbol on: aViewManager with: anActionButton

    ^(self window: aViewManager button: anActionButton action: aSymbol) perform! !

!WBAction class methods ! 
receiver: firstObject originator: secondObject script: aCollection

    ^(self new)
        receiver: firstObject;
        originator: secondObject;
        script: aCollection! !

!LinkButton methods ! 
link: aSymbol
		"Specify the ViewManager subclass to which the button should link.
			The argument should be specified as a Symbol."
    link := aSymbol! !

!WBAction methods ! 
script: aCollection

    script := aCollection.
    ^self! !

!Menu methods !
appendItem: aLabelString link: aViewManagerClassName type: linkType
    "Added by OSI - create a menu item that links to another window"
    #addedByOSI.
    self obsoleteMethod.
    ^self appendItem: aLabelString link: aViewManagerClassName type: linkType acceleratorString: ''! !

!WBAction methods !  
missingAction
    ^MessageBox message: 'Missing action: ',self script! !

!WBAction methods !  
missingAction: aSymbol
    ^MessageBox message: 'Missing action: ',aSymbol,'!!'! !

!WBAction class methods !  
window: aViewManager button: anActionButton

    ^(self new)
        receiver: aViewManager;
        originator: anActionButton! !

!WBAction methods ! 
script

    ^script! !

UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!