"3.0.0.1"
!

!StatusPane class methods !   
wbConstructPropertyManager
    "Construct the WindowBuilder property manager
        based on the Digitalk property manager."

    #addedByOSI.
    ^super wbConstructPropertyManager
        wbAddEvent: (
            WBEventDescription new
                event: #doubleClicked ;
                argumentNames: #( ));
        yourself! !

!MDIFrame class methods !   
wbConstructPropertyManager
    "Construct the WindowBuilder property manager
        based on the Digitalk property manager."

    #addedByOSI.
    ^super wbConstructPropertyManager
        wbAddEvent: (
            WBEventDescription new
                event: #mdiMenuBarBuilt ;
                argumentNames: #( ));
        wbAddEvent: (
            WBEventDescription new
                event: #childActivated ;
                argumentNames: #( ));
        wbAddEvent: (
            WBEventDescription new
                event: #childDeactivated ;
                argumentNames: #( ));
        wbAddEvent: (
            WBEventDescription new
                event: #childClosed ;
                argumentNames: #( ));
        wbAddEvent: (
            WBEventDescription new
                event: #keyToggled ;
                argumentNames: #( ));
        yourself! !

!MDIChild class methods !  
wbConstructPropertyManager
    "Construct the WindowBuilder property manager
        based on the Digitalk property manager."

    #addedByOSI.
    ^super wbConstructPropertyManager
        wbAddEvent: (
            WBEventDescription new
                event: #keyToggled ;
                argumentNames: #( ));
        yourself! !
 
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!