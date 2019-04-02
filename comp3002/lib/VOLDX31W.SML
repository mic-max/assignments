3.1.0.106
   
initialize
		" Private - initialize class state. "

	FontDispatchTable := #( 
		#get_Name: #put_Name: 
		#get_Size: #put_Size: 
		#get_Bold: #put_Bold:
		#get_Italic: #put_Italic: 
		#get_Underline: #put_Underline:  
		#get_Strikethrough: #put_Strikethrough:
		#get_Weight: #put_Weight: 
		#get_Charset: #put_Charset: ).

	FontDispatchTypes := Array new: 8.
	FontDispatchTypes
		at: 1 put: VT_BSTR;
		at: 2 put: VT_CY;
		at: 3 put: VT_BOOL;
		at: 4 put: VT_BOOL;
		at: 5 put: VT_BOOL;
		at: 6 put: VT_BOOL;
		at: 7 put: VT_I2;
		at: 8 put: VT_I2;
		yourself.!
constructVTableDescription
		" Private - construct a description of the receiver's VTable.
		Answer an array of entry point descriptions, in VTable order,
		of the receiver's VTable functions.  The argument types describe
		the value to be constructed by the virtual machine when a
		callback to the entry point is invoked by an external caller. "

	| vtableDescription eptDescription |

	vtableDescription := super constructVTableDescription.

	" install special callback argument handling for POINTL #structValue values "
	eptDescription := vtableDescription detect: [ :ept | ept name = 'put_Size' ].
	self ASSERT: eptDescription argumentTypes = #( #structValue ).
	eptDescription argumentTypes: #( #ulong #ulong ).
	^vtableDescription! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
callbackSelectorFor: eptDescription
		" Private - answer the selector which is sent to instances
		of the receiver when the entry point described by
		<eptDescription> is invoked by an external caller. "

	eptDescription selector = #put_Size:
		ifTrue: [ ^#invokePut_Size:_: ].  " special callin handling of POINT arg "
	^super callbackSelectorFor: eptDescription!   
" OLE Control Development - library removal "

    " remove pool dictionaries as constant pools "
    OLESessionManager removeConstantPoolNames: 
        #( #OLEControlConstants ).
!   
" OLE Control Development - library installation "

    " install pool dictionaries as constant pools "
    OLESessionManager registerConstantPoolNames: 
        #( #OLEControlConstants ).
!   
initialize
        " Private - initialize the class state. "

    self registerStructureName.! 
initialize
		" Private - initialize class state. "

	AmbientDispatchTable := #( #getAmbBackColor: #getAmbDisplayName: #getAmbFont:
		#getAmbForeColor: #getAmbLocaleID: #getAmbMessageReflect: #getAmbScaleUnits:
		#getAmbTextAlign: #getAmbUserMode: #getAmbUIDead: #getAmbShowGrabHandles:
		#getAmbShowHatching: #getAmbDisplayAsDefaultButton:
		#getAmbSupportsMnemonics: #getAmbAutoClip: ).

	AmbientPropertyNames := Dictionary new.
	AmbientPropertyNames
		at: 'BackColor' put: DISPID_AMBIENT_BACKCOLOR;
		at: 'DisplayName' put: DISPID_AMBIENT_DISPLAYNAME;
		at: 'Font' put: DISPID_AMBIENT_FONT;
		at: 'ForeColor' put: DISPID_AMBIENT_FORECOLOR;
		at: 'LocaleID' put: DISPID_AMBIENT_LOCALEID;
		at: 'MessageReflect' put: DISPID_AMBIENT_MESSAGEREFLECT;
		at: 'ScaleUnits' put: DISPID_AMBIENT_SCALEUNITS;
		at: 'TextAlign' put: DISPID_AMBIENT_TEXTALIGN;
		at: 'UserMode' put: DISPID_AMBIENT_USERMODE;
		at: 'UIDead' put: DISPID_AMBIENT_UIDEAD;
		at: 'ShowGrabHandles' put: DISPID_AMBIENT_SHOWGRABHANDLES;
		at: 'ShowHatching' put: DISPID_AMBIENT_SHOWHATCHING;
		at: 'DisplayAsDefaultButton' put: DISPID_AMBIENT_DISPLAYASDEFAULT;
		at: 'SupportsMnemonics' put: DISPID_AMBIENT_SUPPORTSMNEMONICS;
		at: 'AutoClip' put: DISPID_AMBIENT_AUTOCLIP;
		yourself.! 
initialize
        " Private - initialize the class state. "

    self registerStructureName.!