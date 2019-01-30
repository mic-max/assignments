3.1.0.106
   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #(
			#fileMenuGroupWidth
			#editMenuGroupWidth
			#containerMenuGroupWidth
			#objectMenuGroupWidth
			#windowMenuGroupWidth
			#helpMenuGroupWidth )
		!
constructVTableDescription
        " Private - construct a description of the receiver's VTable.
        Answer an array of entry point descriptions, in VTable order,
        of the receiver's VTable functions.  The argument types describe
        the value to be constructed by the virtual machine when a
        callback to the entry point is invoked by an external caller. "

    | vtableDescription eptDescription |

    vtableDescription := super constructVTableDescription.

    " install special callback argument handling for POINTL #structValue values "
    eptDescription := vtableDescription detect: [ :ept | ept name = 'Scroll' ].
    self ASSERT: eptDescription argumentTypes = #( #structValue ).
    eptDescription argumentTypes: #( #ulong #ulong ).
    ^vtableDescription!
" OLE Container Development - library removal "

    " remove pool dictionaries as constant pools "
    OLESessionManager removeConstantPoolNames: 
        #( #OLEUIConstants ).
!  
" OLE Container Development - library installation "

    " install pool dictionaries as constant pools "
    OLESessionManager registerConstantPoolNames: 
        #( #OLEUIConstants ).
!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."

	^self inspectorClass
		fields: #(
			#cb
			#fMDIApp
			#hwndFrame
			#haccel
			#cAccelEntries )
		!  
callbackSelectorFor: eptDescription
        " Private - answer the selector which is sent to instances
        of the receiver when the entry point described by
        <eptDescription> is invoked by an external caller. "

    eptDescription selector = #Scroll:
        ifTrue: [ ^#invokeScroll:_: ].  " special callin handling of POINT arg "
    ^super callbackSelectorFor: eptDescription! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.!