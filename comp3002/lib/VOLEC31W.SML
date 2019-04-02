3.1.0.106
   
invokeOnInPlaceDeactivate
        " Private - invoke the IOleInPlaceSite::OnInPlaceDeactivate function for an external caller. "

	"virtual HRESULT __stdcall OnInPlaceDeactivate( void) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnInPlaceDeactivate.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
sizeInBytes
         "Private - Answer the default size in bytes."

    ^136!  
new: anInteger
        "Answer a new instance of the receiver with
         size anInteger bytes."

	^( super new: anInteger )
		cbStruct: anInteger;
		yourself!   
dvAspect: anInteger
        " Set the aspect of the object to <anInteger>
        either DVASPECT_CONTENT or DVASPECT_ICON. "

    self uLongAtOffset: 100 put: anInteger

!
cClsidExclude: anInteger
        " Private - Set the number of CLSIDs in lpClsidExclude to <anInteger>. "

    self uLongAtOffset: 132 put: anInteger.


!  
clsidActivateDefault: aGuid
        " Set the Class ID to use as the default class when 'Activate As' is selected to <aGuid>. "

    self guidAtOffset: 68 put: aGuid
!   
lpClsidExcludeOffset
        " Private - answer the offset of the address of the list of CLSIDs to exclude from listing. "

	^132


!   
releaseResources
		" Private - release resources owned by the receiver. "

    self
        releaseDefaultLabel;
        "releaseUserType;"     "This is released by the dialog on exit."
        releaseClsidExclude.
	super releaseResources.!   
releaseDefaultLabel
        " Private "

    | anAddress |
    ( anAddress := self lpszDefLabel ) notNil
        ifTrue: [
            anAddress free.
            self lpszDefLabel: nil ].!  
lpszDefLabel
        " Private -  Answer the address of default label to use for the icon. "

    lpszDefLabel notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 128 ) asInteger = lpszDefLabel asInteger ].
    ^lpszDefLabel

!  
defaultLabel: aString
        " Set the default label to use for the icon to <aString>. "

    self lpszDefLabel notNil
        ifTrue: [ self releaseDefaultLabel ].
    self lpszDefLabel: ( self stringExternalCopy: aString ).


!
releaseUserType
        " Private "

    | anAddress |
    ( anAddress := self lpszUserType ) notNil
        ifTrue: [
            anAddress free.
            self lpszUserType: nil ].!  
clsidNew
        " Answer the Class ID of the selected class. "

    ^self guidAtOffset: 84
! 
dvAspect
        " Answer the aspect of the object. "

    ^self uLongAtOffset: 100

!   
lpszUserType: anAddress
        "  Private - Set the address of the user type name of the object to be converted or activated to <anAddress>. "

    self addressAtOffset: 116 put: anAddress.
    lpszUserType := anAddress.

!
defaultLabel
        " Answer the default label to use for the icon. "

    ^self stringAtAddress: self lpszDefLabel

!  
lpszDefLabel: anAddress
        " Private - Set the address of the default label to use for the icon to <anAddress>. "

    self addressAtOffset: 128 put: anAddress.
    lpszDefLabel := anAddress.

! 
userType: aString
        " Set the user type name of the object to be converted or activated to <aString>. "

    self lpszUserType notNil
        ifTrue: [ self releaseUserType ].
    self lpszUserType: ( self stringExternalCopy: aString ).
!
hMetaPict: hMetaPict
        " Set the handle to the METAFILEPICT containing the icon to <hMetaPict>. "

    ^self handleAtOffset: 112 put: hMetaPict


!   
hMetaPict
        " Answer the handle of the METAFILEPICT containing iconic aspect. "

    ^self handleAtOffset: 112

!  
clsid: aGuid
        " Set the Class ID of the object to be converted or activated to <aGuid>. "

    self guidAtOffset: 36 put: aGuid
!  
clsid
        " Answer the Class ID of the object to be converted or activated. "

    ^self guidAtOffset: 36
!   
fObjectsIconChanged
        " Answer TRUE if the object's icon changed. (ie., if ChangeIcon was called
        and not cancelled.). "

    ^self booleanAtOffset: 120

!
clsidConvertDefault: aGuid
        " Set the Class ID to use as the default class when 'Convert To' is selected to <aGuid>. "

    self guidAtOffset: 52 put: aGuid
! 
lpszUserType
        " Private - Answer the address of user type name of the object to be converted or activated. "

    lpszUserType notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 116 ) asInteger = lpszUserType asInteger ].
    ^lpszUserType

!   
fIsLinkedObject: aBoolean
        " Set to TRUE if the object is linked. "

    self booleanAtOffset: 108 put: aBoolean

!   
userType
        " Answer the user type name of the object to be converted or activated. "

    ^self stringAtAddress: self lpszUserType
!
wFormat: anInteger
        " Set the data format of the object to be converted or activated to <anInteger>. "

    self longAtOffset: 104 put: anInteger

!  
lpszTemplate: anAddress
        " Set the address of a null-terminated string that specifies the name of the
        resource file for the dialog box template that is to be substituted for the standard
        Insert Object dialog box template to <anAddess>. "

    self addressAtOffset: 28 put: anAddress.
    lpszTemplate := anAddress.!  
lpszTemplate
        " Answer the address of a null-terminated string that specifies the name of the
        resource file for the dialog box template that is to be substituted for the standard
        Insert Object dialog box template. "

    lpszTemplate notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 28 ) asInteger = lpszTemplate asInteger ].
    ^lpszTemplate!   
dwFlags: anInteger
		" Set the flag values to <anInteger>. "

	self uLongAtOffset: 4 put: anInteger.!  
dwFlags
		" Answer the flag values. "

	^self uLongAtOffset: 4!
allocateExternalStringBuffer: anInteger
		" Private - allocate a buffer in external memory which can contain
		a string of <anInteger> characters.  Include room for trailing NULL char.
		Answer the external address. "

	^ExternalAddress allocateMemory: ( OLEDialogDLL useUnicode
		ifTrue: [ anInteger * 2 + 2 ]
		ifFalse: [ anInteger + 1 ] )! 
hWndOwner: aWindowHandle
		" Set the owner window to <aWindowHandle>. "

	self handleAtOffset: 8 put: aWindowHandle.!  
hInstance: aWindowHandle
        " Set the instance handle of a dialog box template specified by the lpszTemplate member to <aWindowHandle>. "

    self handleAtOffset: 24 put: aWindowHandle.!   
hInstance
        " Answer the instance handle of a dialog box template specified by the lpszTemplate member. "

    ^self handleAtOffset: 24! 
releaseResources
		" Private - release resources owned by the receiver. "

    self releaseHook.
	self releaseCaption.
	self releaseContents.!   
lpClsidExcludeOffset
        " Private - answer the offset of the address of the list of CLSIDs to exclude from listing. "

	self implementedBySubclass!   
hookMessage: aMessage
        " Set up a hook function based on the message <aMessage>.
        This hook function processes messages intended for the dialog box.
        The hook function must return zero to pass a message that it didn't
        process back to the dialog box procedure in the library. The hook
        function must return a nonzero value to prevent the library's dialog
        box procedure from processing a message it has already processed. "

    " The message is similar to the Windows wm messages, for example
    #wmSelector:with: requiring two arguments wParam & lParam. "

    hookCallBack := CallBack
        registerMessage: aMessage
        parameterTypes: #( #ulong #ulong )
        returnType: #long
        callingConvention: #api.

    self lpfnHook: hookCallBack asParameter.!
hWndOwner
		" Answer the owner window. "

	^self handleAtOffset: 8!
releaseClsidExclude
        " Private - release external resource for the list of class ID exclude. "

    | anAddress |
    ( anAddress := self lpClsidExclude ) notNil
        ifTrue: [
            anAddress free.
            self lpClsidExclude: nil ].!
cbStruct: anInteger
		" Set the size in bytes of the data structure to <anInteger>. "

	self uLongAtOffset: 0 put: anInteger.! 
dialogCaption: aString
        " Set the dialog caption for the title bar to <aString>. "

    self lpszCaption notNil
        ifTrue: [ self releaseCaption ].
    self lpszCaption: ( self stringExternalCopy: aString ).! 
dialogCaption
		" Answer the dialog caption for the title bar. "

	^self stringAtAddress: self lpszCaption!
excludeClasses: aListOfCLSIDs
        " Set the list of classes to exclude from the list to <aListOfCLSIDs>. "

    | count elementSize clsidBuffer index |
    count := aListOfCLSIDs size.
    elementSize := GUID sizeInBytes.
    clsidBuffer := ExternalBuffer new: count * elementSize.
    index := 0.
    1 to: count do: [ :i |
        clsidBuffer guidAtOffset: index
            put: ( aListOfCLSIDs at: i ).
        index := index + elementSize ].
    self
        cClsidExclude: count;
        lpClsidExclude: ( ExternalAddress
            copyToNonSmalltalkMemory: clsidBuffer asParameter ).
!
lpszCaption: anAddress
		" Private - Set the address of the dialog caption string to <anAddress>. "

	self addressAtOffset: 12 put: anAddress.
	lpszCaption := anAddress.!
lpfnHook
        " Private - Answer the address of the hook function. "

    ^self addressAtOffset: 16.!   
lpszCaption
		" Private - Answer the address of the dialog caption string. "

	lpszCaption notNil
		ifTrue: [ self ASSERT: ( self addressAtOffset: 12 ) asInteger = lpszCaption asInteger ].
	^lpszCaption!  
lCustData
        " Answer the application-defined data that is passed to the
        hook function pointed to by the lpfnHook member. "

    ^self uLongAtOffset: 20!
lCustData: anInteger
        " Set the application-defined data that is passed to the
        hook function pointed to by the lpfnHook member. "

    self uLongAtOffset: 20 put: anInteger.! 
lpClsidExclude: anExternalAddress
        " Private - set the address of a list of CLSIDs to exclude from listing. "

	self addressAtOffset: self lpClsidExcludeOffset put: anExternalAddress.!
cbStruct
		" Answer the size in bytes of the data structure. "

	^self uLongAtOffset: 0!   
stringExternalCopy: aString
		" Private - copy the string <aString> to external memory
		and answer the external address. "

	^( OLEDialogDLL useUnicode
		ifTrue: [ aString asUnicode ]
		ifFalse: [ aString ] )
			copyToExternalMemory! 
lpfnHook: anAddress
        " Private - Set the address of the hook function to <anAddress>. "

    self addressAtOffset: 16 put: anAddress.!  
releaseHook
        " Private - release the hook callback function. "

    ( self lpfnHook ) notNil
        ifTrue: [
            hookCallBack release.
            self lpfnHook: nil ].!  
stringAtAddress: anExternalAddress
		" Private - answer a String containing the characters at address <anExternalAddress>. "

	anExternalAddress isNil
		ifTrue: [ ^nil ].
	^OLEDialogDLL useUnicode
		ifTrue: [ ( UnicodeStringBuffer atAddress: anExternalAddress ) asString ]
		ifFalse: [ String fromAddress: anExternalAddress ]! 
hResource: aWindowHandle
        " Set the customized template handle to <aWindowHandle>. "

    self handleAtOffset: 32 put: aWindowHandle.!  
hResource
        " Answer the customized template handle. "

    ^self handleAtOffset: 32!
releaseCaption
        " Private - release external resource for caption string. "

    | anAddress |
    ( anAddress := self lpszCaption ) notNil
        ifTrue: [
            anAddress free.
            self lpszCaption: nil ].! 
lpClsidExclude
        " Private - answer the address of the list of CLSIDs to exclude from listing. "

    ^self addressAtOffset: self lpClsidExcludeOffset!  
container: aContainer
		" Private - set the receiver's container object to <aContainer>. "

	container := aContainer.! 
setModified
        " Set the receiver to modified."

    self modified: true.!
SetLinkUpdateOptions: dwLink _: updateOption
        " Private - implement the IOleUILinkContainer::SetLinkUpdateOptions    function.
        Set the receiver's link update options to <updateOption>. Answer the result code."

    | siteObject oleObject oleLink |

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].
    siteObject := container sites at: dwLink.

    oleObject := siteObject oleObject.
    oleLink := oleObject queryInterface: IID_IOleLink.
    oleLink setUpdateOptions: updateOption.
    oleLink release.
    self setModified.
    ^S_OK! 
container
		" Answer the container object with which the receiver is associated. "

	^container!   
container: aContainerObject
		" Specify the container object with which the receiver is associated. "

	container := aContainerObject.!
allocatedInterfacesDo: aOneArgBlock
		" Private - enumerate the interfaces supported by the receiver
		which have been allocated during its lifetime and
		evaluate <aOneArgBlock> with each. "

	super allocatedInterfacesDo: aOneArgBlock.
	iOleUILinkContainer notNil
		ifTrue: [ aOneArgBlock value: iOleUILinkContainer ].!   
getInterfaceForIID: iid
		" Private - answer the interface identified by the GUID <iid>.
		Answer nil if the requested interface is not supported by the receiver. "

	iid = IID_IOleUILinkContainer
		ifTrue: [ ^iOleUILinkContainer ].
	^nil! 
GetLinkSource: dwLink
    _: resultRefDisplayName
    _: resultRefLenFileName
    _: resultRefFullLinkType
    _: resultRefShortLinkType
    _: resultReffSourceAvailable
    _: resultReffIsSelected
        " Private - implement the IOleUILinkContainer::GetLinkSource function.
        Retrieve information about link identified by <dwLink>. Answer the result code."

    | siteObject oleObject oleLink moniker fullClassName shortClassName fileNameSize displayName |

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].
    siteObject := container sites at: dwLink.

    oleObject := siteObject oleObject.
    oleLink := oleObject queryInterface: IID_IOleLink.
    moniker := oleLink getSourceMoniker.
    fullClassName := oleObject getUserFullClassName.
    shortClassName := oleObject getUserShortClassName.
    fileNameSize := self sizeFilePrefixOfMoniker: moniker.
    displayName := oleLink getSourceDisplayName.
    moniker release.
    oleLink release.

    resultRefDisplayName value: displayName.
    resultRefLenFileName value: fileNameSize.
    resultRefFullLinkType value: fullClassName.
    resultRefShortLinkType value: shortClassName.
    resultReffSourceAvailable value: siteObject linkAvailable.
    resultReffIsSelected value: siteObject active.

    ^S_OK!   
initializeInterfaces
		" Private - Allocate any interfaces which are expected to be required 
		during the object's lifetime. "

	super initializeInterfaces.
	iOleUILinkContainer := self createIOleUILinkContainer.!   
SetLinkSource: dwLink _: displayName _: lenFileName _: resultReference _: fValidateSource
        " Private - implement the IOleUILinkContainer::SetLinkSource function.
        Set the soure of the link identified by <dwLink>. Answer the result code. "

    | siteObject oleLink bindContext clsid moniker oleObject fileName
    fileMoniker itemName itemMoniker compositeMoniker |

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].
    siteObject := container sites at: dwLink.

    siteObject linkAvailable: false.     "For use by GetLinkSource."
    oleObject := siteObject oleObject.
    oleLink := oleObject queryInterface: IID_IOleLink.
    fValidateSource
        ifTrue: [
            bindContext := IBindCtx newBindContext.
            moniker := IMoniker
                fromDisplayName: displayName
                bindContext: bindContext
                charsConsumed: resultReference.
            oleObject := moniker
                bindToObject: bindContext
                monikerToLeft: nil
                iid: IID_IOleObject.
            clsid := oleObject getUserClassID.
            oleObject release.
            bindContext release.
            siteObject linkAvailable: ( clsid ~= CLSID_NULL) ]
        ifFalse: [
            fileName := displayName copyFrom: 1 to: lenFileName.
            fileMoniker := IMoniker createFileMoniker: fileName.
            ( fileMoniker notNil and: [ displayName size > lenFileName ] )
                ifTrue: [
                    itemName := displayName
                        copyFrom: lenFileName + 1
                        to: displayName size.
                    itemMoniker := IMoniker createItemMoniker: itemName delimiterString: '\\'.
                    itemMoniker notNil
                        ifTrue: [
                            compositeMoniker := IMoniker createGenericCompositeMoniker: fileMoniker
                                    with: itemMoniker.
                            moniker := compositeMoniker.
                            itemMoniker release ].
                    fileMoniker release ]
                ifFalse: [
                    moniker := fileMoniker ] ].
    moniker isNil
        ifTrue: [ oleLink setSourceDisplayName: displayName ]
        ifFalse: [
            oleLink setSourceMoniker: moniker classID: clsid.
            moniker release ].
    oleLink release.
    siteObject oleObject update.

    siteObject
        saveObject;
        displayObject.
    self setModified.
    ^S_OK!
resetAllocatedInterfaces
		" Private - reset the references to the interfaces supported by the receiver. "

	super resetAllocatedInterfaces.
	iOleUILinkContainer := nil.!
CancelLink: dwLink
        " Private - implement the IOleUILinkContainer::CancelLink function.
        Cancel the link identified by <dwLink>.  Answer the result code."

    | siteObject oleObject oleLink dataObject |

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].
    siteObject := container sites at: dwLink.

    oleObject := siteObject oleObject.
    oleLink := oleObject queryInterface: IID_IOleLink.
    oleLink setSourceMoniker: nil classID: CLSID_NULL.
    oleLink release.

    dataObject := oleObject queryInterface: IID_IDataObject.
    siteObject pasteStaticObject: dataObject.
    dataObject release.

    siteObject displayObject.
    self setModified.
    ^S_OK!  
GetNextLink: dwLink
        " Private - implement the IOleUILinkContainer::GetNextLink function.
        Query the receiver to enumerate the links in the container.  If <dwLink> is 0,
        then the container returns the first link. If <dwLink> identifies the last link in
        the container, then the container returns 0. "

	| nObject maxSites |
	nObject := dwLink + 1.
	maxSites := container sites size.
	nObject <= maxSites
		ifTrue: [
			nObject to: maxSites do: [ :i |
        		( container sites at: i ) containsLinkObject
            		ifTrue: [ ^i ] ] ].
    ^0!
getFirstMoniker: anIMoniker
        " Private - Answer the first piece of the moniker <anIMoniker>.
        If <anIMoniker> is not a GenericCompositeMoniker; addRef it
        and answer the same moniker separately referenced. "

    | enumMoniker firstMoniker |
    anIMoniker isCompositeMoniker
        ifTrue: [
            enumMoniker := anIMoniker elementsEnumerator.
            firstMoniker := enumMoniker next: 1.
            enumMoniker release.
            ^firstMoniker ].
    anIMoniker addRef.
    ^anIMoniker separateReference!
UpdateLink: dwLink _: fErrorMessage _: fErrorAction
        " Private - implement the IOleUILinkContainer::UpdateLink function.
        Update the link identified by <dwLink>. Answer the result code. "

    | oleObject siteObject |

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].
    siteObject := container sites at: dwLink.

    oleObject := siteObject oleObject.
    oleObject isUpToDate
		ifFalse: [
			[ oleObject update ]
				on: OLEError
				do: [ :ex | 
					fErrorMessage
						ifTrue: [ MessageBox notify: container name withText: 'Could not update link.' ].
                 siteObject linkAvailable: false.
					^ex hresult ].
			siteObject displayObject ].

	siteObject linkAvailable: true.
	self setModified.
	^S_OK!   
OpenLinkSource: dwLink
        " Private - implement the IOleUILinkContainer::OpenLinkSource function.
        Open the source of the link identified by <dwLink>. Answer the result code. "

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].
	( container sites at: dwLink )
		activateObjectVerbOpen;
		linkAvailable: true.
    ^S_OK!
clearModified
        " Clear the receiver's modified flag."

    self modified: false!
modified
        "Answer true if the receiver has been modified."

    ^modified!  
modified: aBoolean
        "Set the receiver's modified state to <aBoolean>."

    modified := aBoolean.!  
sizeFilePrefixOfMoniker: anIMoniker
        " Private -  If the first piece of the Moniker <anIMoniker>
        is a FileMoniker, then answer the length of the filename string."

    | firstMoniker displayName |
    firstMoniker := self getFirstMoniker: anIMoniker.
    firstMoniker isFileMoniker
        ifTrue: [ displayName := firstMoniker getDisplayName ].
    firstMoniker release.
    ^displayName size!
initialize
        " Private - initialize the receiver. "

    super initialize.
    modified := false.!  
createIOleUILinkContainer
		" Private - create an IOleUILinkContainer interface on the receiver. "

	^IOleUILinkContainer on: self!
myOleUILinkContainer
        " Private - answer the receiver's IOleUILinkContainer interface.
        This is not a separately reference counted copy; it is the original guy. "

    ^self interfaceForIID: IID_IOleUILinkContainer! 
GetLinkUpdateOptions: dwLink _: resultReference
        " Private - implement the IOleUILinkContainer::GetLinkUpdateOptions function.
        Retrieve the receiver's link update options of the object identified by <dwLink>
        and store it into <resultReference>.  Answer the result code."

    | oleObject oleLink updateOption |

    ( dwLink = 0 or: [ dwLink > (container sites size) ] )
        ifTrue: [ ^E_FAIL ].

    oleObject := (container sites at: dwLink) oleObject.
    oleLink := oleObject queryInterface: IID_IOleLink.
    updateOption := oleLink getUpdateOptions.
    oleLink release.
    resultReference value: updateOption.

    ^S_OK!   
displayWarning: aMessage
		" Private - display the warning message <aMessage>. "

	self displayWarning: aMessage titled: 'OLE Problem'!
sizeInBytes
         "Private - Answer the default size in bytes."

    ^60 + ( OLEDialogDLL useUnicode  " appended szIconExe path name "
        ifTrue: [ MAX_PATH * 2 ]
        ifFalse: [ MAX_PATH ] )

!  
szIconExe: aString
        " Set the source path of the icon to <aString: MAX_PATH>. "

    | tempString |
    tempString := ( OLEDialogDLL useUnicode
        ifTrue: [ aString asUnicode ]
        ifFalse: [ aString ] ).

	tempString size > MAX_PATH
        ifTrue: [ 
            "tempString := tempString copyFrom: 1 to: MAX_PATH"
            self error: 'path name too long' ].

    self bytesAtOffset: 56 put: tempString.
    self cchIconExe: tempString size.
!  
clsid: aGuid
        " Set the CLSID of the default icon to <aGuid>. "

    self guidAtOffset: 40 put: aGuid


!
cchIconExe
        " Answer the number of characters in szIconExe field size: MAX_PATH "

    ^self longAtOffset: (self class sizeInBytes - 4)

!
cchIconExe: anInteger
        " Set the number of characters in szIconExe field size: MAX_PATH "

    ^self longAtOffset: (self class sizeInBytes - 4) put: anInteger

! 
hMetaPict: hMetaPict
        " Set the handle to the Metafile containing the icon to <hMetaPict>. "

    self handleAtOffset: 36 put: hMetaPict

!   
hMetaPict
        " Answer the handle to the Metafile containing the icon. "

    ^self handleAtOffset: 36

!
clsid
        " Answer the CLSID of the default icon. "

    ^self guidAtOffset: 40

!   
doubleClickedClientSite: aClientSitePane
        " Private - the client site <aClientSitePane> has been selected by the user.
        Set the input focus and provide selection feedback and perform the primary verb. "

    self selectedClientSite: aClientSitePane.
    aClientSitePane siteObject containsEditableObject
        ifTrue: [
            self activateClientSite: aClientSitePane siteObject
                objectVerb: OLEIVERB_PRIMARY ].!  
invokeOnPosRectChange: lprcPosRect
        " Private - invoke the IOleInPlaceSite::OnPosRectChange function for an external caller. "

    "virtual HRESULT __stdcall OnPosRectChange(
            /* [in] */ LPCRECT lprcPosRect) = 0"

    | hresult rect |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    lprcPosRect isValid
        ifFalse: [^E_INVALIDARG].
    rect := ( WinRectangle atAddress: lprcPosRect ) asRectangle.
    hresult := self dispatchOnPosRectChange: rect.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
pasteSpecialIntoClientSite: aClientSite
        " Private - allow the user to invoke the Paste Special dialog
        to paste data in a specific format from the clipboard into <aClientSite>. "

    | anIDataObject ps listOfPasteEntry listOfLinkType aFormatEtc |

    anIDataObject := IDataObject getClipboardObject.
    anIDataObject isNil
        ifTrue: [ ^nil ].  " clipboard doesn't contain OLE object "
    [
    listOfPasteEntry := self pasteSpecialEntries.
    listOfLinkType := self pasteSpecialLinks.
    ps := OLEPasteSpecialDialog new
        sourceDataObject: anIDataObject;
        pasteEntries: listOfPasteEntry;
        linkTypes: listOfLinkType;
        open.
    ( ps selectedIndex notNil )
        ifTrue: [
            aFormatEtc := (listOfPasteEntry at: ps selectedIndex) fmtetc.
            aFormatEtc dwAspect: ( ( ps style & PSF_CHECKDISPLAYASICON > 0 )
                ifTrue: [ DVASPECT_ICON ]
                ifFalse: [ DVASPECT_CONTENT ] ).
            aClientSite formatEtc: aFormatEtc.
            CursorManager execute changeFor: [
                ps linkFlag
                    ifTrue: [ aClientSite pasteLinkedObject: anIDataObject ]
                    ifFalse: [ aClientSite pasteEmbeddedObject: anIDataObject ].
                ].
            ].
    listOfPasteEntry do: [ :pasteEntry | pasteEntry release ].
    anIDataObject release.
    self releaseMetaPict: ps hMetaPict.
    ]
        on: OLEError
        do: [ :ex |
            aClientSite deleteContent.
            anIDataObject notNil
                ifTrue: [ anIDataObject release ].
            listOfPasteEntry do: [ :pasteEntry | pasteEntry release ].
            self releaseMetaPict: ps hMetaPict.
            self displayWarning: ex description titled: 'Paste Special Problem' ].!
openContainer
        " Private - open the receiver's container and its sites. "

    fileName isNil
        ifTrue: [   " opening a new empty container window "
            self newContainerFile ]
        ifFalse: [ " opening a container window on a specified file "
            ( self openContainerFile: fileName )
                ifFalse: [  " open failed "
                    self fileName: nil.
                    self newContainerFile ] ].!
TranslateAccelerator: lpmsg _: wID
		" Invoke the IOleInPlaceFrame::TranslateAccelerator function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT TranslateAccelerator(
            /* [in] */ LPMSG lpmsg,
            /* [in] */ WORD wID); "

    <ole: 14 structIn short hresult>
    ^self vtableDispatchFailed!   
EnableModeless: fEnable
		" Invoke the IOleInPlaceFrame::EnableModeless function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT EnableModeless(
            /* [in] */ BOOL fEnable); "

    <ole: 13 boolean hresult>
    ^self vtableDispatchFailed!  
SetStatusText: pszStatusText
		" Invoke the IOleInPlaceFrame::SetStatusText function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSetStatusText: ( self asUnicodeParameter: pszStatusText )!
invokeSetStatusText: pszStatusText
		" Private - invoke the IOleInPlaceFrame::SetStatusText function. "

	" HRESULT SetStatusText(
            /* [in] */ LPCOLESTR pszStatusText); "

    <ole: 12 structIn hresult>
    ^self vtableDispatchFailed
!
RemoveMenus: hmenuShared
		" Invoke the IOleInPlaceFrame::RemoveMenus function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeRemoveMenus: hmenuShared asParameter!   
invokeSetMenu: hmenuShared _: holemenu _: hwndActiveObject
		" Private - invoke the IOleInPlaceFrame::SetMenu function. "

	" HRESULT SetMenu(
            /* [in] */ HMENU hmenuShared,
            /* [in] */ HOLEMENU holemenu,
            /* [in] */ HWND hwndActiveObject); "

    <ole: 10 handle handle handle hresult>
    ^self vtableDispatchFailed
!
SetMenu: hmenuShared _: holemenu _: hwndActiveObject
		" Invoke the IOleInPlaceFrame::SetMenu function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSetMenu: hmenuShared asParameter
		_: holemenu asParameter
		_: hwndActiveObject asParameter! 
invokeRemoveMenus: hmenuShared
		" Private - invoke the IOleInPlaceFrame::RemoveMenus function. "

	" HRESULT RemoveMenus(
            /* [in] */ HMENU hmenuShared); "

    <ole: 11 handle hresult>
    ^self vtableDispatchFailed
!
InsertMenus: hmenuShared _: lpMenuWidths
		" Invoke the IOleInPlaceFrame::InsertMenus function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeInsertMenus: hmenuShared asParameter 
		_: lpMenuWidths!   
invokeInsertMenus: hmenuShared _: lpMenuWidths
		" Private - invoke the IOleInPlaceFrame::InsertMenus function. "

	" HRESULT InsertMenus(
            /* [in] */ HMENU hmenuShared,
            /* [out][in] */ LPOLEMENUGROUPWIDTHS lpMenuWidths); "

    <ole: 9 handle struct hresult>
    ^self vtableDispatchFailed
!  
GetBorder: resultReference
		" Invoke the IOleInPlaceUIWindow::GetBorder function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue result |
	resultValue := WinRectangle new.
	result := self invokeGetBorder: resultValue.
	resultReference value: ( result = S_OK
		ifTrue: [ resultValue asRectangle ]
		ifFalse: [ nil ] ).
	^result!   
invokeSetBorderSpace: pborderwidths
		" Private - invoke the IOleInPlaceUIWindow::SetBorderSpace function. "

	" HRESULT SetBorderSpace(
            /* [unique][in] */ LPCBORDERWIDTHS pborderwidths); "

	<ole: 7 structIn hresult>
	^self vtableDispatchFailed! 
SetBorderSpace: borderWidthsRectangle
		" Invoke the IOleInPlaceUIWindow::SetBorderSpace function.
		Raise an exception if an error occurs.  Answer the result code. "		

	^self invokeSetBorderSpace: borderWidthsRectangle asParameter! 
SetActiveObject: anIOleInPlaceActiveObject _: pszObjName
		" Invoke the IOleInPlaceUIWindow::SetActiveObject function.
		Raise an exception if an error occurs.  Answer the result code. "		

	^self invokeSetActiveObject: anIOleInPlaceActiveObject asParameter
		_: ( self asUnicodeParameter: pszObjName )!  
invokeSetActiveObject: pActiveObject _: pszObjName
		" Private - invoke the IOleInPlaceUIWindow::SetActiveObject function. "

	" HRESULT SetActiveObject(
            /* [unique][in] */ IOleInPlaceActiveObject *pActiveObject,
            /* [unique][string][in] */ LPCOLESTR pszObjName); "

	<ole: 8 handle structIn hresult>
	^self vtableDispatchFailed!  
RequestBorderSpace: borderWidthsRectangle
		" Invoke the IOleInPlaceUIWindow::RequestBorderSpace function.
		Raise an exception if an error occurs.  Answer the result code. "		

	^self invokeRequestBorderSpace: borderWidthsRectangle asParameter! 
invokeRequestBorderSpace: pborderwidths
		" Private - invoke the IOleInPlaceUIWindow::RequestBorderSpace function. "

	" HRESULT RequestBorderSpace(
            /* [unique][in] */ LPCBORDERWIDTHS pborderwidths); "

	| hresult |
	<ole: 6 structIn hresult>
	hresult := self dispatchFailureReason.
	hresult = INPLACE_E_NOTOOLSPACE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!
invokeGetBorder: lprectBorder
		" Private - invoke the IOleInPlaceUIWindow::GetBorder function. "

	" HRESULT GetBorder(
            /* [out] */ LPRECT lprectBorder); "

	| hresult |
	<ole: 5 structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = INPLACE_E_NOTOOLSPACE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!
GetWindow: resultReference
		" Invoke the IOleWindow::GetWindow function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult  |
	resultValue := WindowHandle new.
	hresult := self invokeGetWindow: resultValue.
	resultReference value: resultValue.
	^hresult! 
invokeGetWindow: phwnd
		" Private - invoke the IOleWindow::GetWindow function. "

	" HRESULT GetWindow(
            /* [out] */ HWND *phwnd); "

	<ole: 3 structOut hresult>
	^self vtableDispatchFailed! 
ContextSensitiveHelp: enterHelpMode
		" Invoke the IOleWindow::ContextSensitiveHelp function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT ContextSensitiveHelp(
            /* [in] */ BOOL fEnterMode); "

	<ole: 4 boolean hresult>
	^self vtableDispatchFailed!
OleSetMenuDescriptor: hOleMenu _: hwndFrame _: hwndActiveObject _: anIOleInPlaceFrame _: anIOleInPlaceActiveObject
		" Install or remove dispatching code from the container's frame window.
		Used by the container for the composite menu during in-place activation. 
		<hOleMenu> is the composite menu descriptor (NULL to remove).
		The container's in-place frame object's interface and window handle
		are specified by <anIOleInPlaceFrame> and <hwndFrame>.
		The in-place active object's interface and window handle
		are specified by <anIOleInPlaceActiveObject> and <hwndActiveObject>. "

	^self invokeOleSetMenuDescriptor: hOleMenu asParameter
		_: hwndFrame asParameter
		_: hwndActiveObject asParameter
		_: anIOleInPlaceFrame asParameter
		_: anIOleInPlaceActiveObject!
DiscardUndoState
	"Invoke the IOleInPlaceSite::DiscardUndoState function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchDiscardUndoState)!
initialize
        " Private - Initialize the receiver. "

	self initializeContainer.
	super initialize.
!   
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #OLEINPLACEFRAMEINFO for: self.!   
displayWarning: aMessage titled: title
		" Private - display the warning message <aMessage>. "

	MessageBox
		notify: title
		withText: aMessage.!   
CancelLink: dwLink
		" Invoke the IOleUILinkContainer::CancelLink function.
		Raise an exception if an error occurs.  Answer the result code. "

    " HRESULT CancelLink(
                /* [in] */ DWORD dwLink) ;"

    <ole: 10 ulong hresult>
    ^self vtableDispatchFailed
! 
SetLinkUpdateOptions: dwLink _: dwUpdateOpt
		" Invoke the IOleUILinkContainer::SetLinkUpdateOptions function.
		Raise an exception if an error occurs.  Answer the result code. "

    " HRESULT SetLinkUpdateOptions(
                /* [in] */ DWORD dwLink,
                /* [in] */ DWORD dwUpdateOpt);"

    <ole: 4 ulong ulong hresult>
    ^self vtableDispatchFailed
! 
invokeSetLinkSource: dwLink _: lpszDisplayName _: lenFileName _: pchEaten _: fValidateSource
        " Private - invoke the IOleUILinkContainer::SetLinkSource function. "

    " HRESULT SetLinkSource(
                /* [in] */ DWORD dwLink,
                /* [in] */ LPWSTR lpszDisplayName,
                /* [in] */ ULONG lenFileName,
                /* [out] */ ULONG FAR* pchEaten,
                /* [in] */ BOOL fValidateSource) ;"

    <ole: 6 ulong structIn ulong structOut boolean hresult>
    ^self vtableDispatchFailed!   
GetNextLink: dwLink
		" Invoke the IOleUILinkContainer::GetNextLink function.
		Raise an exception if an error occurs.  Answer the result code. "

    " DWORD GetNextLink(
           /* [in] */ DWORD dwLink);"

    <ole: 3 ulong ulongReturn>
    ^self vtableDispatchFailed
!   
GetLinkUpdateOptions: dwLink _: resultReference
		" Invoke the IOleUILinkContainer::GetLinkUpdateOptions function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := ExternalLong new.
    hresult :=  self
        invokeGetLinkUpdateOptions: dwLink
        _: resultValue asParameter.
    resultValue := resultValue asUnsignedInteger.
    resultReference value: ( resultValue = 0
        ifTrue: [ nil ]
        ifFalse: [ resultValue ] ).
    ^hresult
!  
UpdateLink: dwLink _: fErrorMessage _: fErrorAction
		" Invoke the IOleUILinkContainer::UpdateLink function.
		Raise an exception if an error occurs.  Answer the result code. "

    " HRESULT UpdateLink(
                /* [in] */ DWORD dwLink,
                /* [in] */ BOOL fErrorMessage,
                /* [in] */ BOOL fErrorAction) ;"

    <ole: 9 ulong boolean boolean hresult>
    ^self vtableDispatchFailed
!  
invokeGetLinkUpdateOptions: dwLink _: lpdwUpdateOpt
        " Private - invoke the IOleUILinkContainer::GetLinkUpdateOptions function. "

    " HRESULT GetLinkUpdateOptions(
                /* [in] */ DWORD dwLink,
                /* [out] */ DWORD FAR* lpdwUpdateOpt);"

    <ole: 5 ulong structOut hresult>
    ^self vtableDispatchFailed!  
SetLinkSource: dwLink _: displayName _: lenFileName _: resultReference _: fValidateSource
		" Invoke the IOleUILinkContainer::SetLinkSource function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := ExternalLong new.
    hresult :=  self
        invokeSetLinkSource: dwLink
        _: ( self asUnicodeParameter: displayName )
        _: lenFileName
        _: resultValue asParameter
        _: fValidateSource.
    resultValue := resultValue asUnsignedInteger.
    resultReference value: ( resultValue = 0
        ifTrue: [ nil ]
        ifFalse: [ resultValue ] ).
    ^hresult
! 
GetLinkSource: dwLink
    _: resultRefDisplayName
    _: resultRefLenFileName
    _: resultRefFullLinkType
    _: resultRefShortLinkType
    _: resultReffSourceAvailable
    _: resultReffIsSelected
		" Invoke the IOleUILinkContainer::GetLinkSource function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValueLenFileName resultValueDisplayName resultValueFullLinkType
    resultValueShortLinkType resultValuefSourceAvailable resultValuefIsSelected hresult |
    resultValueLenFileName := ExternalLong new.
    resultValueDisplayName := self createStringResultValue.
    resultValueFullLinkType := self createStringResultValue.
    resultValueShortLinkType := self createStringResultValue.
    resultValuefSourceAvailable := ExternalLong new.
    resultValuefIsSelected := ExternalLong new.
    hresult := self
        invokeGetLinkSource: dwLink
        _: resultValueDisplayName
        _: resultValueLenFileName
        _: resultValueFullLinkType
        _: resultValueShortLinkType
        _: resultValuefSourceAvailable
        _: resultValuefIsSelected.
    resultRefLenFileName value: resultValueLenFileName asUnsignedInteger.
    resultRefDisplayName value: ( self stringFromResultValue: resultValueDisplayName ).
    resultRefFullLinkType value: ( self stringFromResultValue: resultValueFullLinkType ).
    resultRefShortLinkType value: ( self stringFromResultValue: resultValueShortLinkType ).
    resultReffSourceAvailable value: resultValuefSourceAvailable asBoolean.
    resultReffIsSelected value: resultValuefIsSelected asBoolean.
    ^hresult
!   
invokeGetLinkSource: dwLink
    _: lplpszDisplayName
    _: lplenFileName
    _: lplpszFullLinkType
    _: lplpszShortLinkType
    _: lpfSourceAvailable
    _: lpfIsSelected
        " Private - invoke the IOleUILinkContainer::GetLinkSource function. "

    " HRESULT GetLinkSource(
                /* [in] */ DWORD dwLink,
                /* [out] */ LPWSTR FAR* lplpszDisplayName,
                /* [out] */ ULONG FAR* lplenFileName,
                /* [out] */ LPWSTR FAR* lplpszFullLinkType,
                /* [out] */ LPWSTR FAR* lplpszShortLinkType,
                /* [out] */ BOOL FAR* lpfSourceAvailable,
                /* [out] */ BOOL FAR* lpfIsSelected) ;"

    <ole: 7 ulong structOut structOut structOut structOut structOut structOut hresult>
    ^self vtableDispatchFailed! 
OpenLinkSource: dwLink
		" Invoke the IOleUILinkContainer::OpenLinkSource function.
		Raise an exception if an error occurs.  Answer the result code. "

    " HRESULT OpenLinkSource(
                /* [in] */ DWORD dwLink) ;"

    <ole: 8 ulong hresult>
    ^self vtableDispatchFailed
!  
initializeContainer
		" Private - initialize the receiver's container object. "

	self container: ( self createContainerNamed: self containerName ).!  
createClientSitePaneIn: aWindow 
	for: aContainerCoordinator 
	name: aSiteName 
	framing: aSizeSpecification
        " Private - create a new OLE client site pane in <aWindow>.
		Set the site pane's owner to <aContainerCoordinator> and its
		framing specification <aSizeSpecification>.
		Answer the client site pane. "

    | aSitePane |

	aSitePane := OLEClientSitePane new.
	self 
		installSitePane: aSitePane
		in: aWindow 
		for: aContainerCoordinator 
		name: aSiteName 
		framing: aSizeSpecification.

	aSitePane
		when: #clicked:
			send: #selectedClientSite: to: aContainerCoordinator with: aSitePane;
		 when: #doubleClicked
			send: #doubleClickedClientSite: to: aContainerCoordinator with: aSitePane;
		yourself.
    ^aSitePane!  
haccel
        " Answer the container's accelerator table handle. "

    ^self handleAtOffset: 12! 
activeSite
		" Private - answer the currently selected site in the receiver. "

	^activeSite!  
getAdvise
		" Answer the existing advisory connection of the object, if any. "

	| resultReference |
	resultReference := IAdviseSink new asValueReference.
	interface GetAdvise: nil _: nil _: resultReference.
	^resultReference value!
freezeContentView
		" Freeze the content view aspect of the object.
		Answer a token identifying the frozen object. "

	^self freezeView: DVASPECT_CONTENT!   
drawContentOn: aDeviceContext bounds: aRectangle
		" Render the object on the device context <aDeviceContext>
		in the bounding box specified by <aRectangle. "

	interface Draw: DVASPECT_CONTENT
		_: -1
		_: nil
		_: nil
		_: nil   " default target device "
		_: aDeviceContext
		_: aRectangle
		_: nil
		_: nil
		_: 0!  
registerAdviseSink: anAdviseSink aspects: aspects adviseFlags: advFlags
        " Register a view advise sink on the view object.
        Answer the token which identifies the connection (nil if not established). "

    interface SetAdvise: aspects _: advFlags _: anAdviseSink.!
freezeView: drawAspect
		" Freeze the view aspect of the object that is specified by 
		the DVASPECT value <drawAspect>.
		Answer a token identifying the frozen object. "

	| hresult resultReference |
	resultReference := nil asValueReference.
	interface Freeze: drawAspect
	    _: -1
	    _: nil
	    _: resultReference.
	hresult = VIEW_S_ALREADY_FROZEN
		ifTrue: [ OLEResultNotification hresult: hresult ].
	^resultReference value! 
unregisterAdviseSink
        " Delete the current advise connection on the view object. "

    interface SetAdvise: 0 _: 0 _: nil! 
getColorSet: dwDrawAspect
    targetDevice: anOLEDvTargetDevice
    hicTargetDevice: hicTargetDev
        " Answer the color set that would be used by a call to IViewObject::Draw
         with the corresponding parameters.  The DVASPECT value <drawAspect> 
		specifies the object view and <anOLEDvTargetDevice> the target device."

    | resultReference |
    resultReference := nil asValueReference.
    interface GetColorSet: dwDrawAspect
        _: -1
        _: nil
        _: anOLEDvTargetDevice
        _: hicTargetDev
        _: resultReference.
    ^resultReference value!   
setContentViewAdviseSink: anAdviseSink flags: advf
		" Register <anAdviseSink> with the receiver. "

	interface SetAdvise: DVASPECT_CONTENT _: advf _: anAdviseSink.!  
getAdvise: aspectsReference flags: adviseFlagsReference
		" Retrieve the existing advisory connection, if any, on the object
		and store it into the <resultReference>.  The values of the aspect
		and ADVF parameters of the most recent SetAdvise call can be obtained."

	| resultReference |
	resultReference := IAdviseSink new asValueReference.
	interface GetAdvise: aspectsReference
	    _: adviseFlagsReference
	    _: resultReference.
	^resultReference value!   
unfreeze: freezeToken
		" Unfreeze a previously frozen drawing. "

	interface Unfreeze: freezeToken!   
setAdvise: aspects flags: advf adviseSink: anAdviseSink
		" Set up an advisory connection between the view object and the advisory
		sink <anAdviseSink> through which the sink can be notified of changes
		made to the object's drawings.  The DVASPECT aspect in <aspects>
		specifies the view for which the advise connection is established.
		The ADVF flags in <advf> specify information about the connection. "

	interface SetAdvise: aspects _: advf _: anAdviseSink.! 
draw:dwDrawAspect
    targetDevice: ptd
    hicTargetDevice: hicTargetDev
    hdcDraw: hdcDraw
    rectangleBounds: lprcBounds
    rectangleWBounds: lprcWBounds
    functionContinue: pfnContinue
    continueValue: dwContinue
		" Render the object on the device context <hdcDraw>. "

	interface Draw: dwDrawAspect
		_: -1
		_: nil
		_: ptd
		_: hicTargetDev
		_: hdcDraw
		_: lprcBounds
		_: lprcWBounds
		_: pfnContinue
		_: dwContinue!   
enableItems: itemList in: aMenu
		" Private - enable the specified items in <aMenu>. "

	itemList do: [ :aMenuItem | aMenu enableItem: aMenuItem ].!   
saveContainerFile: aPathName
        " Private - Save the container storage to the file named <aPathName>. "

    [ self container saveDocumentFile: aPathName signature: self fileSignature ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Container File Save Problem' ].
!  
installSitePane: aSitePane
	in: aWindow 
	for: aContainerCoordinator 
	name: aSiteName 
	framing: aSizeSpecification
        " Private - install a new OLE site pane in <aWindow>.
		Set the site pane's owner to <aContainerCoordinator> and its
		framing specification <aSizeSpecification>. "

    aWindow
        addSubpane: ( aSitePane
            owner: aContainerCoordinator;
            setName: aSiteName;
            framingBlock: aSizeSpecification;
            yourself ).
    aContainerCoordinator container 
		registerSite: aSitePane siteObject.
    aContainerCoordinator activeSite: aSitePane siteObject.
! 
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
new
		" Answer a new instance of the receiver. "

	^super new needsFinalization!   
sizeInBytes
         "Private - Answer the default size in bytes."

    ^84

!   
invokeGetWindowContext: ppFrame _: ppDoc _: lprcPosRect _: lprcClipRect _: lpFrameInfo
        " Private - invoke the IOleInPlaceSite::GetWindowContext function for an external caller. "

    "HRESULT GetWindowContext(
            /* [out] */ IOleInPlaceFrame **ppFrame,
            /* [out] */ IOleInPlaceUIWindow **ppDoc,
            /* [out] */ LPRECT lprcPosRect,
            /* [out] */ LPRECT lprcClipRect,
            /* [out][in] */ LPOLEINPLACEFRAMEINFO lpFrameInfo)"

    | hresult frameRef docWindowRef posRef clipRef frameInfoRef |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    (ppFrame isValid and: [ppDoc isValid and: [lprcPosRect isValid
            and: [lprcClipRect isValid and: [lpFrameInfo isValid]]]])
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: ppFrame.
    self clearResultValueAtAddress: ppDoc.
    self clearResultStructureAtAddress: lprcPosRect
        type: WinRectangle.
    self clearResultStructureAtAddress: lprcClipRect
        type: WinRectangle.

    frameRef := nil asValueReference.
    docWindowRef := nil asValueReference.
    posRef := nil asValueReference.
    clipRef := nil asValueReference.
    frameInfoRef := nil asValueReference.
    hresult := self dispatchGetWindowContext: frameRef
        _: docWindowRef
        _: posRef
        _: clipRef
        _: frameInfoRef.
    ( HRESULT succeeded: hresult )
        ifTrue: [
            self interfaceResultAtAddress: ppFrame put: frameRef value.
            self interfaceResultAtAddress: ppDoc put: docWindowRef value.
            self structureResultAtAddress: lprcPosRect put: posRef value.
            self structureResultAtAddress: lprcClipRect put: clipRef value.
            self structureResultAtAddress: lpFrameInfo put: frameInfoRef value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
dispatchCanInPlaceActivate
		" Private - dispatch the IOleInPlaceSite::CanInPlaceActivate function. "

	^( functionHandlers at: 6 ) evaluate!  
closed: aWindow
        " Private - the window has been closed.  Close down the application.
        Shut down the process if there are no more windows open. "

	self container release.  " decrement the artifical ref count "
	self container: nil.

    SessionModel current isRunTime
        ifTrue: [ self exitIfLastWindow ].!
windowTitle
        " Private - answer the window title. "

	| title |
	title := self containerName.
	self fileName notNil
		ifTrue: [ title := title, ' - ', fileName fileNameLessPath fileName ].
	^title
! 
editPasteSpecial
        " Private - Perform the Edit menu Paste Special operation. "

    self pasteSpecialIntoClientSite: self activeSite.
!
convertObjectInClientSite: aClientSite
        " Private - allow the user to invoke the Convert dialog
        to convert the object in <aClientSite> from one class to another. "

    | formatAndUserType hMetaPict dataObject formatEtc stgMedium ct |

    [
    formatAndUserType := aClientSite storage readClipboardFormatAndUserType.
    hMetaPict := NullHandle.
    DVASPECT_ICON == aClientSite aspect
        ifTrue: [
            dataObject := aClientSite oleObject queryInterface: IID_IDataObject.
            formatEtc := ( OLEStructure classForStructureNamed: #FORMATETC )
                formatNamed: 'Metafile'.
            formatEtc dwAspect: DVASPECT_ICON.
            stgMedium := dataObject getData: formatEtc.
            hMetaPict := ExternalHandle fromInteger: stgMedium hGlobal.
            stgMedium release.
            dataObject release ].

    ct := OLEConvertDialog new
        isLinkedObject: aClientSite containsLinkObject;
        dvAspect: aClientSite aspect;
        clsid: aClientSite oleObject getUserClassID;
        wFormat: ( formatAndUserType at: 1 );
        hMetaPict: hMetaPict.
    ct open.
	CursorManager execute
		changeFor: [ 
    		( ( ct style & CF_SELECTCONVERTTO > 0 )
      		and: [ ct clsid ~= ct clsidNew ] )
				ifTrue: [ aClientSite convertObjectToClass: ct clsidNew activate: false ].
			( ( ct style & CF_SELECTACTIVATEAS > 0 )
			and: [ ct clsid ~= ct clsidNew ] )
				ifTrue: [ aClientSite activateObjectAsClass: ct clsidNew activate: true ].
		].
    self releaseMetaPict: hMetaPict.
    ]
        on: OLEError
        do: [ :ex |
            self releaseMetaPict: hMetaPict.
            self displayWarning: ex description titled: 'Convert Problem' ].!  
enableDisableObjectVerbMenuIn: aMenu
        " Private - enable/disable the Edit Object verb menu items in <aMenu>. "

    | anOleObject |

    aMenu window isNil ifTrue: [ ^self ].

    anOleObject := self activeSite oleObject.

    anOleObject isNil
        ifTrue: [ IOleObject clearObjectVerbMenu: aMenu ]
        ifFalse: [
            self activeSite canDoConvert
                ifTrue: [
                    anOleObject addVerbMenuTo: aMenu
                         whenVerbSelectedSend: #editObjectVerb:
                         whenConvertSelectedSend: #editConvertObject
                         to: self ]
                ifFalse: [
                    anOleObject addVerbMenuTo: aMenu
                         whenVerbSelectedSend: #editObjectVerb:
                         to: self ] ].

    self activeSite containsEditableObject
        ifFalse: [ self enableItems: 'Object' in: aMenu ].!  
pasteSpecialEntries
        " Private - Answer an list of desired paste entry for the Paste Special dialog.
        Each entry in the list contains a OLEUIPasteEntry structure for
        a specific format."

    | listOfPasteEntry |
    listOfPasteEntry := Array new: 2.
    listOfPasteEntry at: 1 put: ( OLE_OLEUIPASTEENTRY new
        fmtetc: ( ( OLEStructure classForStructureNamed: #FORMATETC )
            formatNamed: 'Embedded Object' );
        formatName: '%s Object' ;
        resultText: '%s Object' ;
        dwFlags: OLEUIPASTE_PASTE "| OLEUIPASTE_ENABLEICON";   "Paste iconic not yet supported."
        yourself ).
    listOfPasteEntry at: 2 put: ( OLE_OLEUIPASTEENTRY new
        fmtetc: ( ( OLEStructure classForStructureNamed: #FORMATETC )
            formatNamed: 'Metafile'  );
        formatName: 'Picture (Metafile)' ;
        resultText: 'a Picture (Metafile)' ;
        dwFlags: OLEUIPASTE_PASTEONLY;
        yourself ).
    ^listOfPasteEntry
!   
GetMiscStatus: dwAspect _: resultReference
        " Invoke the IOleObject::GetMiscStatus function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self
		invokeGetMiscStatus: dwAspect
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!
invokeSetHostNames: szContainerApp _: szContainerObj
		" Private - invoke the IOleObject::SetHostNames function. "

	" HRESULT SetHostNames(
            /* [in] */ LPCOLESTR szContainerApp,
            /* [unique][in] */ LPCOLESTR szContainerObj); "

    <ole: 5 structIn structIn hresult>
    ^self vtableDispatchFailed! 
invokeGetMoniker: dwAssign _: dwWhichMoniker _: ppmk
		" Private - invoke the IOleObject::GetMoniker function. "

	" HRESULT GetMoniker(
            /* [in] */ DWORD dwAssign,
            /* [in] */ DWORD dwWhichMoniker,
            /* [out] */ IMoniker **ppmk); "

    <ole: 8 ulong ulong structOut hresult>
    ^self vtableDispatchFailed! 
invokeGetClientSite: ppClientSite
		" Private - invoke the IOleObject::GetClientSite function. "

	" HRESULT GetClientSite(
            /* [out] */ IOleClientSite **ppClientSite); "

    <ole: 4 structOut hresult>
    ^self vtableDispatchFailed!  
GetExtent: dwDrawAspect _: resultReference
        " Invoke the IOleObject::GetExtent function.
        Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := WinPoint new.
    hresult := self
        invokeGetExtent: dwDrawAspect
        _: resultValue.
    " Return the point in HIMETRICS "
    resultReference value: resultValue asPoint.
    ^hresult!  
invokeGetClipboardData: dwReserved _: ppDataObject
		" Private - invoke the IOleObject::GetClipboardData function. "

	" HRESULT GetClipboardData(
            /* [in] */ DWORD dwReserved,
            /* [out] */ IDataObject **ppDataObject); "

    <ole: 10 ulong structOut hresult>
    ^self vtableDispatchFailed! 
invokeSetClientSite: pClientSite
		" Private - invoke the IOleObject::SetClientSite function. "

	" HRESULT SetClientSite(
            /* [unique][in] */ IOleClientSite *pClientSite); "

   <ole: 3 handle hresult>
    ^self vtableDispatchFailed!  
DoVerb: iVerb
    _: lpmsg
    _: anIOleClientSite
    _: lindex
    _: hwndParent
    _: aRectangle
        " Invoke the IOleObject::DoVerb function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self
        invokeDoVerb: iVerb
        _: lpmsg
        _: anIOleClientSite asParameter
        _: lindex
        _: hwndParent asParameter
        _: aRectangle asParameter! 
Unadvise: dwConnection
		" Invoke the IOleObject::Unadvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Unadvise(
            /* [in] */ DWORD dwConnection); "

    <ole: 20 ulong hresult>
    ^self vtableDispatchFailed! 
EnumVerbs: resultReference
        " Invoke the IOleObject::EnumVerbs function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumOLEVERB.
	hresult := self invokeEnumVerbs: resultValue asParameter.
    ( HRESULT succeeded: hresult )
		ifTrue: [ resultReference value: resultValue ].
	^hresult!  
Close: saveOption
		" Invoke the IOleObject::Close function.
		Raise an exception if an error occurs.  Answer the result code. "

	"  HRESULT Close(
            /* [in] */ DWORD dwSaveOption); "

	| hresult |
	<ole: 6 ulong hresult>
	hresult := self dispatchFailureReason.
	hresult = OLE_E_PROMPTSAVECANCELLED
		ifTrue: [ ^hresult ].
	^self vtableDispatchFailed!
invokeDoVerb: iVerb
    _: lpmsg
    _: pActiveSite
    _: lindex
    _: hwndParent
    _: lprcPosRect
		" Private - invoke the IOleObject::DoVerb function. "

	" HRESULT DoVerb(
            /* [in] */ LONG iVerb,
            /* [unique][in] */ LPMSG lpmsg,
            /* [unique][in] */ IOleClientSite *pActiveSite,
            /* [in] */ LONG lindex,
            /* [in] */ HWND hwndParent,
            /* [unique][in] */ LPCRECT lprcPosRect); "

    <ole: 11 long structIn handle long handle structIn hresult>
    ^self vtableDispatchFailed!
invokeInitFromData: pDataObject _: fCreation _: dwReserved
		" Private - invoke the IOleObject::InitFromData function. "

	" HRESULT InitFromData(
            /* [unique][in] */ IDataObject *pDataObject,
            /* [in] */ BOOL fCreation,
            /* [in] */ DWORD dwReserved); "

    <ole: 9 handle boolean ulong hresult>
    ^self vtableDispatchFailed!
invokeEnumVerbs: ppEnumOleVerb
		" Private - invoke the IOleObject::EnumVerbs function. "

	" HRESULT EnumVerbs(
            /* [out] */ IEnumOLEVERB **ppEnumOleVerb); "

	| hresult |
	<ole: 12 structOut hresult>
	hresult := self dispatchFailureReason.
	( hresult = OLEOBJ_E_NOVERBS
	or: [ hresult = REGDB_E_CLASSNOTREG ] )
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!   
GetMoniker: dwAssign _: dwWhichMoniker _: resultReference
        " Invoke the IOleObject::GetMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IMonikerPointer forReturnValue.
	hresult := self 
		invokeGetMoniker: dwAssign 
		_: dwWhichMoniker 
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!   
invokeGetUserClassID: pClsid
		" Private - invoke the IOleObject::GetUserClassID function. "

	" HRESULT GetUserClassID(
            /* [out] */ CLSID *pClsid); "

    <ole: 15 structOut hresult>
    ^self vtableDispatchFailed!
SetExtent: dwDrawAspect _: aPoint
        " Invoke the IOleObject::SetExtent function.
        Raise an exception if an error occurs.  Answer the result code. "

   | hresult aPointInHimetrics |

    aPointInHimetrics := aPoint.  " point in Himetrics "
    hresult := self
        invokeSetExtent: dwDrawAspect
        _: aPointInHimetrics asParameter.
    ^hresult!  
SetMoniker: whichMoniker _: aMoniker
        " Invoke the IOleObject::SetMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self 
		invokeSetMoniker: whichMoniker 
		_: aMoniker asParameter!
invokeAdvise: pAdvSink _: pdwConnection
		" Private - invoke the IOleObject::Advise function. "

	" HRESULT Advise(
            /* [unique][in] */ IAdviseSink *pAdvSink,
            /* [out] */ DWORD *pdwConnection); "

    <ole: 19 handle structOut hresult>
    ^self vtableDispatchFailed!
IsUpToDate
		" Invoke the IOleObject::IsUpToDate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT IsUpToDate( void); "

    <ole: 14 hresult>
    ^self vtableDispatchFailed! 
invokeEnumAdvise: ppenumAdvise
		" Private - invoke the IOleObject::EnumAdvise function. "

	" HRESULT EnumAdvise(
            /* [out] */ IEnumSTATDATA **ppenumAdvise); "

    <ole: 21 structOut hresult>
    ^self vtableDispatchFailed!   
Update
		" Invoke the IOleObject::Update function.
		Raise an exception if an error occurs.  Answer the result code. "

	"  HRESULT Update( void); "

    <ole: 13 hresult>
    ^self vtableDispatchFailed!
invokeGetExtent: dwDrawAspect _: psizel
		" Private - invoke the IOleObject::GetExtent function. "

	" HRESULT GetExtent(
            /* [in] */ DWORD dwDrawAspect,
            /* [out] */ SIZEL *psizel); "

    <ole: 18 ulong structOut hresult>
    ^self vtableDispatchFailed! 
invokeSetExtent: dwDrawAspect _: psizel
		" Private - invoke the IOleObject::SetExtent function. "

	" HRESULT SetExtent(
            /* [in] */ DWORD dwDrawAspect,
            /* [in] */ SIZEL *psizel); "

    <ole: 17 ulong structIn hresult>
    ^self vtableDispatchFailed!   
GetClientSite: resultReference
        " Invoke the IOleObject::GetClientSite function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IOleClientSitePointer forReturnValue.
	hresult := self invokeGetClientSite: resultValue asParameter.
	resultReference value: ( resultValue isValid
		ifTrue: [ resultValue ]
		ifFalse: [ nil ] ).
	^hresult! 
SetHostNames: containerApplicationName _: containerObjectName
        " Invoke the IOleObject::SetHostNames function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeSetHostNames: ( self asUnicodeParameter: containerApplicationName )
        _: ( self asUnicodeParameter: containerObjectName )!
invokeGetUserType: dwFormOfType _: pszUserType
		" Private - invoke the IOleObject::GetUserType function. "

	" HRESULT GetUserType(
            /* [in] */ DWORD dwFormOfType,
            /* [out] */ LPOLESTR *pszUserType); "

    <ole: 16 ulong structOut hresult>
    ^self vtableDispatchFailed!  
Advise: anAdviseSink _: resultReference
		" Invoke the IOleObject::Advise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult :=  self
        invokeAdvise: anAdviseSink asParameter
        _: resultValue.
	resultValue := resultValue asUnsignedInteger.
	resultReference value: ( resultValue = 0
		ifTrue: [ nil ]
		ifFalse: [ resultValue ] ).
    ^hresult!  
GetClipboardData: dwReserved  _: resultReference
        " Invoke the IOleObject::GetClipboardData function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IDataObjectPointer forReturnValue.
	hresult := self 
		invokeGetClipboardData: dwReserved
		_: resultValue asParameter.
	resultReference value: resultValue.
	^hresult!  
GetUserClassID: resultReference
		" Invoke the IOleObject::GetUserClassID function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := GUID forReturnValue.
	hresult := self invokeGetUserClassID: resultValue.
	resultReference value: resultValue.
	^hresult!
EnumAdvise: resultReference
		" Invoke the IOleObject::EnumAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumSTATDATA.
	hresult := self invokeEnumAdvise: resultValue asParameter.
	resultReference value: resultValue.
	^hresult! 
SetClientSite: aClientSite
        " Invoke the IOleObject::SetClientSite function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeSetClientSite: aClientSite asParameter! 
InitFromData: aDataObject _: creationFlag _: dwReserved
        " Invoke the IOleObject::InitFromData function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self 
		invokeInitFromData: aDataObject asParameter 
		_: creationFlag 
		_: dwReserved!
SetColorScheme: aPalette
        " Invoke the IOleObject::GetMiscStatus function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT SetColorScheme(
            /* [in] */ LOGPALETTE *pLogpal); "

    <ole: 23 structIn hresult>
    ^self vtableDispatchFailed!  
invokeSetMoniker: dwWhichMoniker _: pmk
		" Private - invoke the IOleObject::SetMoniker function. "

	" HRESULT SetMoniker(
            /* [in] */ DWORD dwWhichMoniker,
            /* [unique][in] */ IMoniker *pmk); "

    <ole: 7 ulong handle hresult>
    ^self vtableDispatchFailed!  
invokeGetMiscStatus: dwAspect _: pdwStatus
		" Private - invoke the IOleObject::GetMiscStatus function. "

	" HRESULT GetMiscStatus(
            /* [in] */ DWORD dwAspect,
            /* [out] */ DWORD *pdwStatus); "

    | hresult |
    <ole: 22 ulong structOut hresult>
    hresult := self dispatchFailureReason.
    ( hresult = REGDB_E_CLASSNOTREG
    or: [ hresult = REGDB_E_READREGDB ] )
        ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!   
GetUserType: dwFormOfType _: resultReference
        " Invoke the IOleObject::GetUserType function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
    resultValue := self createStringResultValue.
	hresult := self invokeGetUserType: dwFormOfType _: resultValue.
	resultReference value: ( self stringFromResultValue: resultValue ). 
	^hresult!  
createContainerFile: aPathName
        " Private - Create a new container storage file named <aPathName>. "

    [ self container newDocumentFile: aPathName ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Container File Create Problem' ].
!
fileSave
        " Private - Perform the File menu Save operation. "

    self fileName isNil
        ifTrue: [ self fileSaveAs ]
        ifFalse: [ 
            CursorManager execute changeFor: [ self saveContainerFile ] ].!   
OleDestroyMenuDescriptor: hOleMenu
		" Destroy the shared menu descriptor used during in-place activation. "

	^self invokeOleDestroyMenuDescriptor: hOleMenu asParameter! 
openContainerFile: aPathName
        " Private - Open the container storage file named <aPathName>.
        Answer whether the file was opened succesfully"

    | openSucceeded |

    ( OLECompoundFile isStorageFile: aPathName )
        ifFalse: [
            self displayWarning: 'The file ', aPathName, ' does not exist or does not contain a doc file.'
                titled: 'File Open Problem'.
            ^false ].

    [ openSucceeded := self container openDocumentFile: aPathName signature: self fileSignature ]
        on: OLEError
        do: [ :ex |
            self displayWarning: ex description titled: 'Container File Open Problem'.
            ^false ].
    openSucceeded
        ifFalse: [
            self displayWarning: 'The file ', aPathName, ' does not contain a valid doc file for ', self class name, '.'
                titled: 'File Open Problem' ].
    ^openSucceeded!  
opened: aWindow
        " Private - the window has just been opened. "

	self container addRef.  " artificially reference count the container
		while the window is open (needed for IPA support) "
	self openContainer.!
containerMenuGroupWidth
		" Answer the number of items in the container's container menu group. "

	^self longAtOffset: 8! 
duplicateData: hSource format: cfFormat flags: uiFlags
        " Duplicate the metafile, bitmap, or global memory resource
        specified by the host resource handle <hSource>.
        The clipboard format of the source data is specified by <cfFormat>.
        <uiFlags> specified the flags to use in global memory allocation.
        Answer a handle of the same type as the source data. "

    ^OLEDLL current OleDuplicateData: hSource _: cfFormat _: uiFlags!
createDataCache
        " Create a cache object and answer a new instance of the receiver on it. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current CreateDataCache: nil
        _: CLSID_NULL
        _: self iid
        _: resultReference.
    ^resultReference value!  
updateCache: anIDataObject flags: cacheUpdateFlags
		" Update the cache with <anIDataObject> (which can be nil)
		according to the UPDF values in <cacheUpdateFlags>. 
		Answer whether all caches were updated. "

	| hresult |
	hresult := interface UpdateCache: anIDataObject 
		_: cacheUpdateFlags 
		_: nil.
	hresult = S_OK   " CACHE_S_SOMECACHES_NOTUPDATED, CACHE_E_NOCACHE_UPDATED "
		ifFalse: [ OLEResultNotification hresult: hresult ].
	^hresult = S_OK!  
discardCache: discardOptions
		" Flush the cache(s) that are in memory.  Subsequent IDataObject::GetData
		calls will be satisified by reverting to disk-based data.
		The <discardOptions> settings specifies whether to save dirty data
		in the cache before it is discarded.. "

	interface DiscardCache: discardOptions!   
discardCache
		" Flush the cache(s) that are in memory.  Discard any changes. "

	interface DiscardCache: DISCARDCACHE_NOSAVE! 
saveAndDiscardCache
		" Flush the cache(s) that are in memory.  Save any changes. "

	interface DiscardCache: DISCARDCACHE_SAVEIFDIRTY!
initCache: anIDataObject
		" Fill the cache using the data provided by <anIDataObject>,
		a data transfer object from the clipboard or a drag/drop operation. "

	| hresult |
	hresult := interface InitCache: anIDataObject.
	hresult = S_OK   " CACHE_S_SOMECACHES_NOTUPDATED "
		ifFalse: [ OLEResultNotification hresult: hresult ]!   
cacheConnectionsEnumerator
		" Answer an enumerator on the current connections in the cache. 
		Answer nil if there are currently no connections. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumSTATDATA ) asValueReference.
	interface EnumCache: resultReference.
	^resultReference value!
setData: aFormatEtc storageMedium: aStgMedium release: fRelease
		" Fill the cache using the data contained in the storage medium <aStgMedium>
		according to the format specified by <aFormatEtc>.
		If <fRelease> is true, the callee takes ownership of the medium and releases
		it whn it is finished.  Otherwise, the caller retains ownership is responsible for
		freeing the medium; the callee can only use the storage for the duration of the call."

	interface SetData: aFormatEtc _: aStgMedium _: fRelease!
uncache: connectionToken
		" Delete the cache connection identified by <connectionToken>. "

	interface Uncache: connectionToken!  
cacheConnections
		" Answer the current connections in the cache. "

	| anEnumerator contents |
	anEnumerator := self cacheConnectionsEnumerator.
	anEnumerator isNil
		ifTrue: [ ^#( ) ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!
cache: aFormatEtc adviseFlags: adviseFlags
		" Specify the formats and other data to be cached inside an embedded object.
		The data formats that are to be cached are specified by <aFormatEtc>.
		The ADVF values in <adviseFlags> specify information about the cache connection.
		Answer a connection token identifying the cache connection. "

	| hresult resultReference |
	resultReference := nil asValueReference.
	interface Cache: aFormatEtc _: adviseFlags _: resultReference.
	hresult = S_OK   " CACHE_S_FORMATETC_NOTSUPPORTED, CACHE_S_SAMECACHE "
		ifFalse: [ OLEResultNotification hresult: hresult ].  
	^resultReference value! 
getGraphicsTool
        "Private - Answer a graphics tool for the receiver."

    graphicsTool isNil
        ifTrue: [
            graphicsTool := self graphicsToolClass for: nil medium: self]
        ifFalse: [
            firstTime := false].
    ^graphicsTool!   
loadOnReference: aBoolean
        " Private - specify whether the site object needs to be loaded from its backing store. "

    ^self propertyAt: #loadOnReference
        put: ( aBoolean == true ifTrue: [ true ] ifFalse: [ nil ] ).!  
dragSourceCutDefault: dragSession
		"Private - handle the source cut by removing the selection
		from the receiver."

	siteObject deleteContent.! 
loadOnReference
        " Private - answer whether the site object needs to be loaded from its backing store. "

    ^self propertyAt: #loadOnReference ifAbsent: [ false ]!   
defaultStyle
        "Private - Answer the default check box window style."

	^WsBorder!   
siteObject: aSiteObject
		" Set the site object associated with the receiver. "

	siteObject := aSiteObject.!  
siteObject
		" Answer the site object associated with the receiver. "

	^siteObject!   
enableEmbeddedObjectDrop
        " Enable dragging an embedded object contained in the receiver's site
        out of its container. "

    self
        dragTargetForFormats: #( 'Embedded Object' 'Embed Source')
        operations: #( #move #copy #link ).!
enableDragDrop
		" Enable drag/drop on the receiver. "

	self
		dragSource;
		dragTarget;
		dragSessionClass: WinDragDropSession.!  
graphicsToolClass
        "Private - Answer the graphics tool class used by the receiver."

    ^OLEPen!   
initialize
        " Private - initialize the receiver "

    super initialize.
    self createSiteObject.
! 
basicStyle
        "Private - Answer an Integer with appropriate
         constants combination for basic window style."

	^WsVisible | WsChild | WsClipsiblings
		| WsClipchildren	"use clip children for in-place activation"! 
close
        "Private - Close the receiver."

	self siteObject release.
    ^super close!
copyObjectToClipboard
        " Copy the contained object to the clipboard. "

    self siteObject isEmpty
        ifTrue: [ ^self ].
    self siteObject copyObjectToClipboard.
!  
enableDragOnly
		" Enable dragging out of the receiver; can't drop on him, however. "

	self
		dragSource;
		dragSessionClass: WinDragDropSession.!  
enableDropOnly
		" Enable dropping on the receiver; cannot drag out of him, however. "

	self
		dragTarget;
		dragSessionClass: WinDragDropSession.! 
createSiteObject
		"Private - create the site object for the receiver. "

    self siteObject: ( self siteObjectClass new
        sitePane: self;
        yourself )!
displayWindow
        " Private - Let the owner process the display event
        or draw all the retained segments."

    ( ( self handlesEvent: #display )
     or: [ self hasActionForEvent: #display ] )
        ifTrue: [
            self event: #display.
            self triggerEvent: #display ]
        ifFalse: [
            self siteObject displayObject ].! 
erase
        "Private - Erase the contents of the receiver pane."

    graphicsTool notNil
        ifTrue: [ graphicsTool erase ].!  
siteObjectClass
		"Private - answer the class which is used for the receiver's site. "

    ^OLEClientSiteObject!  
setName: aString
        "Set the name of the pane to <aString>."

    super setName: aString.
    self siteObject name: aString.
!  
isValidFlag: aBoolean
        " Private - specify whether the site object is valid for rendering.
        This is an alternative to adding another instance variable to the site object. "

    ^self propertyAt: #isValidFlag
        put: ( aBoolean == false ifTrue: [ false ] ifFalse: [ nil ] ).!   
isValidFlag
        " Private - answer whether the site object is valid for rendering.
        This is an alternative to adding another instance variable to the site object. "

    ^self propertyAt: #isValidFlag ifAbsent: [ true ]!   
open
        "Private - Open the subpane."

	self siteObject addRef.
	^super open.!   
enableDisableEditMenu: aMenu
        " Private - enable/disable operations in the Edit menu <aMenu>
		according to the current state of the application. "

	self 
		enableDisableEditOperationsIn: aMenu;
		enableDisableObjectOperationsIn: aMenu.!   
getObject: itemName
		" Answer the IOleObject interface of the object named <itemName>.
		Answer nil if the object does not exist or does not support the requested interface. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: IID_IOleObject.
    interface GetObject: itemName
       _: BINDSPEED_INDEFINITE
       _: nil
       _: IID_IOleObject
       _: resultReference.
    ^resultReference value!  
isItemRunning: pszItem
		" Answer whether the item <pszItem> in this item container is running. "

	^( interface IsRunning: pszItem ) = S_OK!  
isRunning: anItemName
		" Dtermine whether the item <anItemName> in this item container is running. "

	interface IsRunning: anItemName!   
getObjectStorage: anItemName iid: iid
		" Answer the interface specified by the Guid <iid> of the storage of the object 
		specified by <anItemName> during item moniker binding.
		Return nil if the object does not have an independently identifiable piece of storage
		or does not support the requested interface. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
    interface GetObjectStorage: anItemName
       _: nil
       _: iid
       _: resultReference.
    ^resultReference value!   
getObjectStorage: anItemName
		" Answer the IStorage interface of the storage of the object 
		specified by <anItemName> during item moniker binding.
		Return nil if the object does not have an independently identifiable piece of storage. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: IID_IStorage.
    interface GetObjectStorage: anItemName
       _: nil
       _: IID_IStorage
       _: resultReference.
    ^resultReference value!
getObject: anItemName bindSpeed: dwSpeedNeeded bindContext: aBindContext iid: iid
		" Query the receiver for the object named <anItemName> and 
		store the interface specified by the Guid <iid> into <resultReference>.
		This function is called as part of the item moniker binding process.
		The BINDSPEED value <dwSpeedNeeded> indicates how long the 
		caller is willing to wait to get to the object.  The IBindContext
		interface <aBindContext> is the bind context for the operation.
		Answer nil if the object does not exist or does not support the requested interface. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
    interface GetObject: anItemName
       _: dwSpeedNeeded
       _: aBindContext
       _: iid
       _: resultReference.
    ^resultReference value!  
getObject: itemName iid: iid
		" Answer the interface specifed by the Guid <iid> of the object named <itemName>.
		Answer nil if the object does not exist or does not support the requested interface. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
    interface GetObject: itemName
       _: BINDSPEED_INDEFINITE
       _: nil
       _: iid
       _: resultReference.
    ^resultReference value!   
getObject: itemName bindSpeed: speedNeeded iid: iid
		" Answer the interface specifed by the Guid <iid> of the object named <itemName>.
		The BINDSPEED value <speedNeeded> indicates how long the 
		caller is willing to wait to get to the object.
		Answer nil if the object does not exist or does not support the requested interface. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
    interface GetObject: itemName
       _: speedNeeded
       _: nil
       _: iid
       _: resultReference.
    ^resultReference value! 
getObjectStorage: anItemName bindContext: aBindContext iid: iid
		" Obtain the storage of the object specified by <anItemName> during item moniker binding.
		Obtain the interface specified by the Guid <iid>, usually IStorage or IStream, 
		and store it into <resultReference>. 	The IBindContext interface <aBindContext>
       is the bind context for the operation. Return nil if the object does
		not have an independently identifiable piece of storage. "

    | resultReference |
    resultReference := OLEInterfaceValueReference forReturnValueWithIID: iid.
    interface GetObjectStorage: anItemName
       _: aBindContext
       _: iid
       _: resultReference.
    ^resultReference value!   
unlockContainer
		" Unlock the container. "

	interface LockContainer: false.! 
embeddedObjectsEnumerator
		" Answer an enumerator on the embedded objects in the container. "

	^self objectsEnumeratorFor: OLECONTF_EMBEDDINGS!  
objectsEnumeratorFor: grfFlags
		" Answer a new IEnumUknown enumerator that can be used to
		enumerate the objects container in the receiver of the type 
		specified in the OLECONTF value <grfFlags>. "

    | resultReference |
    resultReference := ( IEnum forIID: IID_IEnumUnknown ) asValueReference.
    interface EnumObjects: grfFlags _: resultReference.
    ^resultReference value!
lockContainer
		" Lock the container. "

	interface LockContainer: true.!  
embeddedObjects
		" Answer a collection of the embedded objects in the container. "

	| anEnumerator contents |
	anEnumerator := self embeddedObjectsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!
linkedObjects
		" Answer a collection of the linked objects in the container. "

	| anEnumerator contents |
	anEnumerator := self linkedObjectsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!  
linkedObjectsEnumerator
		" Answer an enumerator on the linked objects in the container. "

	^self objectsEnumeratorFor: OLECONTF_LINKS!   
fileSaveAs
        " Private - Perform the File menu Save As... operation. "

    | aPathName  |

    aPathName := ( FileDialog new
        addFilter: '*.', self fileExtension 
            description: 'Container Files (*.', self fileExtension asUppercase, ')';
        saveTitle: 'SaveAs'
        fileName: self defaultFileName )
            file.
	aPathName isNil
        ifTrue: [ ^self ].   " user cancelled "

    CursorManager execute changeFor: [
        self
            saveContainerFile: aPathName;
            fileName: aPathName.
        ].!   
new: anInteger
        "Answer a new instance of the receiver with
         size anInteger bytes."

	^( super new: anInteger )
		cbStruct: anInteger;
		yourself!   
supportsInPlaceActivation
		" Private - answer whether in-place activation should be supported
		in the receiver's view. "

	^true !  
createViewFor: aCoordinator
        "Create and configure a window for <aCoordinator>.
        The main window of a container application has an
        OLE container object associated with it. "

    | aWindow |

    aWindow := super createViewFor: aCoordinator.
    aWindow
        owner: aCoordinator;
        container: aCoordinator container;  " find or create "
        yourself.

    aWindow
        when: #opened
            send: #opened: to: aCoordinator with: aWindow;
        when: #aboutToClose
            send: #aboutToClose: to: aCoordinator with: aWindow;
        when: #closed
            send: #closed: to: aCoordinator with: aWindow;
        yourself.

    self supportsInPlaceActivation
        ifTrue: [
            "in-place active container window must use WS_CLIPCHILDREN
                 so that its painting does not interfere with the painting
                 of the server's in-place active child window."
            aWindow addClipchildrenStyle.
            ].
	^aWindow!  
format: anOLEFormatEtc name: nameString
        " Answer a default OLEUIPASTEENTRY with the format
        <anOLEFormateEtc> with the format name <nameString>.  "

    ^self new
        fmtetc: anOLEFormatEtc;
        formatName: nameString;
        resultText: nameString;
        dwFlags: OLEUIPASTE_PASTEONLY;
        yourself!   
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
format: anOLEFormatEtc name: nameString resultText: resultString
        " Answer a default OLEUIPASTEENTRY with the format
        <anOLEFormateEtc>. The format name is <nameString>
        and the result text is <resultString>. "

    ^self new
        fmtetc: anOLEFormatEtc;
        formatName: nameString;
        resultText: resultString;
        dwFlags: OLEUIPASTE_PASTEONLY;
        yourself!   
formatNamed: formatNameString resultText: resultTextString
        " Answer a default OLEUIPASTEENTRY with the format
        described by <formatNameString> with the result text <resultTextString>. "

    ^self new
        fmtetc: ( ( OLEStructure classForStructureNamed: #FORMATETC )
            formatNamed: formatNameString );
        formatName: formatNameString;
        resultText: resultTextString;
        dwFlags: OLEUIPASTE_PASTEONLY;
        yourself! 
formatNamed: formatNameString
        " Answer a default OLEUIPASTEENTRY with the format
        described by <formatNameString>. "

    ^self
        formatNamed: formatNameString
        resultText: formatNameString!  
sizeInBytes
         "Private - Answer the default size in bytes."

    ^36

!   
clientSiteIsSelected
		" Private - Answer whether an OLE client site is the current selection in the receiver. "

	^self activeSite notNil!
dispatchOnInPlaceActivate
		" Private - dispatch the IOleInPlaceSite::OnInPlaceActivate function. "

	^( functionHandlers at: 7 ) evaluate!
includeFindReplaceOperations
		" Private - answer whether the receiver includes the find/replace operations
		in its Edit menu. "

	^true!
objectVerbsMenuCreate
        " Answer a new Object verbs menu. "

	^Menu new
		title: '\uObject' replaceEscapeCharacters;
		appendItem: '\uEdit' replaceEscapeCharacters 
			selector: #editEditObject; 
		appendItem: '\uOpen' replaceEscapeCharacters 
			selector: #editOpenObject; 
		yourself! 
insertMenu
        "Answer the standard Insert menu for an OLE container window."

    | aMenu |
    aMenu := Menu new
        title: '\uInsert' replaceEscapeCharacters;
        appendItem: '\uObject...' replaceEscapeCharacters
            selector: #insertObject;
        yourself.
    ^aMenu!   
viewMenu
        "Answer the standard View menu for an OLE container window."

    | aMenu |
    aMenu := Menu new
        title: '\uView' replaceEscapeCharacters;
        appendItem: '\uShow Objects' replaceEscapeCharacters
            selector: #viewShowObjects;
        yourself.
    ^aMenu!   
editMenu
        "Answer the standard Edit menu for an OLE container window."

    | selectorMap aMenu |

    aMenu := super editMenu.
    selectorMap := Dictionary new
        at: #undo put: #editUndo;
        at: #cutSelection put: #editCut;
        at: #copySelection put: #editCopy;
        at: #pasteSelection put: #editPaste;
        at: #clearSelection put: #editClear;
        at: #selectAll put: #editSelectAll;
        at: #restore put: #editRestore;
        at: #findReplace put: #editFindReplace;
        at: #again put: #editAgain;
        yourself.
    selectorMap associationsDo: [ :assoc |
        aMenu changeItem: assoc key selector: assoc value ].

    aMenu insertItem: 'Paste \uSpecial...' replaceEscapeCharacters
        selector: #editPasteSpecial
        accelKey: nil
        accelBits: nil
        after: ( aMenu getIndex: #editPaste ).
    self includeFindReplaceOperations
        ifFalse: [
            aMenu
                deleteItem: #editFindReplace;
                deleteItem: #editAgain ].
    self appendObjectOperationsTo: aMenu.
    ^aMenu!
fileMenu
        "Answer the standard File menu for an OLE container window."

	| selectorMap aMenu |
	selectorMap := Dictionary new
		at: #newFile put: #fileNew;
		at: #openFile put: #fileOpen;
		at: #accept put: #fileSave;
		at: #saveAs put: #fileSaveAs;
		at: #sendFile put: #fileSend;
		at: #print put: #filePrint;
		yourself.
	aMenu := super fileMenu.
	selectorMap associationsDo: [ :assoc |
		aMenu changeItem: assoc key selector: assoc value ].
	^aMenu!   
appendObjectOperationsTo: aMenu
		" Private - append the object editing operations to <aMenu>. "

	self includeFindReplaceOperations
		ifTrue: [ aMenu appendSeparator ].
	aMenu
        appendItem: '\uLinks...' replaceEscapeCharacters
            selector: #editLinks;
        "Not yet supported:
        appendItem: 'Object P\uroperties...\tAlt+Enter' replaceEscapeCharacters
            selector: #editProperties
            accelKey: ExecuteKey  accelBits: AfAlt;
        "
        appendSubMenu: self objectVerbsMenuCreate;
        yourself.!   
activateClientSite: aClientSite objectVerb: anInteger
        " Private - activate the object in <aClientSite> as specified by the object verb <anInteger>. "

	[ 
	CursorManager execute
		changeFor: [ aClientSite activateObjectVerb: anInteger ].
	]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Activate Object Problem' ].!   
closeContainer
        " Private - close the receiver's container and its sites. "

    self container close.! 
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #OLEMENUGROUPWIDTHS.!
editEditObject
        " Private - Perform the Edit menu Edit Object operation. "

	self editClientSite: self activeSite.
!   
editOpenObject
        " Private - Perform the Edit menu Object Open operation. "

	self openClientSite: self activeSite.
!   
cb
		" Answer the size in bytes of the receiver. "

	^self uLongAtOffset: 0!   
useUnicode: aBoolean
		" Specify whether to use the Unicode variants of the common OLE UI dialogs. "

	UseUnicode := aBoolean.
	self validateUnicodeDependentConstants.!  
fileName
        "Answer the receiver's file name."

     ^'oledlg.dll'!   
open: fileName
        "Answer an instance of the receiver which refers
         to the Dynamic Link Library named aString."

    OLESessionManager isContainerSupportAvailable
        ifFalse: [
            MessageBox
                notify: 'Unsupported Platform'
                withText: 'The OLE container feature is not supported on this operating system.'.
            ^self error: 'not a supported operating system' ].
    OLEDLL current.  " ensure that OLE is initialized "
    ^super open: fileName
! 
validateUnicodeDependentConstants
		" Verify that the constants whose settings depend on the Unicode usage
		are set correctly.
			OLEDialogDLL validateUnicodeDependentConstants
		"

	| sensitiveConstants stringTypeSuffix uiConstants |
	sensitiveConstants := #(
		'IDD_SERVERNOTREG'
		'IDD_LINKTYPECHANGED'
		).
	stringTypeSuffix := ( self useUnicode ifTrue: [ 'W' ] ifFalse: [ 'A' ] ).
	uiConstants := Smalltalk at: #OLEUIConstants.
	sensitiveConstants do: [ :constantName |
		( uiConstants at: constantName ) = ( uiConstants at: constantName, stringTypeSuffix )
			ifFalse: [
				MessageBox
					notify: 'Incorrrect OLEUIConstants Value'
					withText: 'Constant ', constantName, 
						' should now be set to ', constantName, stringTypeSuffix ] ].
	! 
useUnicode
		" Answer whether to use the Unicode variants of the common OLE UI dialogs. "

	^UseUnicode!   
oleUIEditLinksW: lpEL
        " Private - invoke the Unicode entry point to open the OLE IEdit Links dialog.
            STDAPI_(UINT) OleUIEditLinksW(LPOLEUIEDITLINKSW);"

    <api: OleUIEditLinksW struct ulongReturn>
    ^self apiCallFailed!  
OleUIBusy: lpBZ
        "Invokes the standard OLE Busy dialog box allowing the user manage concurrency.
        The <lpBZ> is a pointer to an OLEUIBUSY in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIBusyW: lpBZ ]
        ifFalse: [ self oleUIBusyA: lpBZ ]!   
oleUIChangeIconA: lpCI
        " Private - invoke the ASCII entry point to open the OLE Change Icon dialog.
            STDAPI_(UINT) OleUIChangeIconA(LPOLEUICHANGEICONA);"

    <api: OleUIChangeIconA struct ulongReturn>
    ^self apiCallFailed!
oleUIChangeIconW: lpCI
        " Private - invoke the unicode entry point to open the OLE Change Icon dialog.
            STDAPI_(UINT) OleUIChangeIconW(LPOLEUICHANGEICONW);"

    <api: OleUIChangeIconW struct ulongReturn>
    ^self apiCallFailed!  
oleUIObjectPropertiesA: lpOP
        " Private - invoke the ASCII entry point to open the OLE Object Properties dialog.
            STDAPI_(UINT) OleUIObjectPropertiesA(LPOLEUIOBJECTPROPSA);"

    <api: OleUIObjectPropertiesA struct ulongReturn>
    ^self apiCallFailed!   
oleUIObjectPropertiesW: lpOP
        " Private - invoke the unicode entry point to open the OLE Object Properties dialog.
            STDAPI_(UINT) OleUIObjectPropertiesW(LPOLEUIOBJECTPROPSW);"

    <api: OleUIObjectPropertiesW struct ulongReturn>
    ^self apiCallFailed! 
OleUIObjectProperties: lpOP
        "Invokes the standard OLE Object Properties dialog.
        The <lpOP> is a pointer to an OLEUIOBJECTPROPS in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIObjectPropertiesW: lpOP ]
        ifFalse: [ self oleUIObjectPropertiesA: lpOP ]!
oleUIUpdateLinksA: lpOleUILinkCntr _: hwndParent _:lpszTitle _: cLinks
        " Private - invoke the ASCII entry point for Update Links.
            STDAPI_(BOOL) OleUIUpdateLinksW(
                LPOLEUILINKCONTAINERW lpOleUILinkCntr,
                HWND hwndParent,
                LPWSTR lpszTitle,
                int cLinks);"

    <api: OleUIUpdateLinksA handle handle struct long boolean>
    ^self apiCallFailed!  
oleUIUpdateLinksW: lpOleUILinkCntr _: hwndParent _:lpszTitle _: cLinks
        " Private - invoke the unicode entry point for Update Links.
            STDAPI_(BOOL) OleUIUpdateLinksW(
                LPOLEUILINKCONTAINERW lpOleUILinkCntr,
                HWND hwndParent,
                LPWSTR lpszTitle,
                int cLinks);"

    <api: OleUIUpdateLinksW handle handle struct long boolean>
    ^self apiCallFailed!
OleUIEditLinks: lpEL
        "Invokes the standard OLE Links dialog box allowing the user to make modifications
         to a container's linked objects.
        The <lpEL> is a pointer to an OLEUIEDITLINKS in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIEditLinksW: lpEL ]
        ifFalse: [ self oleUIEditLinksA: lpEL ]! 
oleUIBusyA: lpBZ
        " Private - invoke the ASCII entry point to open the OLE Busy dialog.
            STDAPI_(UINT) OleUIBusyA(LPOLEUIBUSYA);"

    <api: OleUIBusyA struct ulongReturn>
    ^self apiCallFailed!   
oleUIBusyW: lpBZ
        " Private - invoke the unicode entry point to open the OLE Busy dialog.
            STDAPI_(UINT) OleUIBusyW(LPOLEUIBUSYW);"

    <api: OleUIBusyW struct ulongReturn>
    ^self apiCallFailed! 
OleUIAddVerbMenu: anOleObject
	_: shortType 
	_: hMenu
	_: uPos
	_: uIDVerbMin
	_: uIDVerbMax
	_: bAddConvert
	_: idConvert
	_: resultReference
		" Add the Verb menu for the specified object to the given menu.  If the object has one verb,
		directly add the verb to the given menu.  If the object has multiple verbs we create a cascading
		sub-menu. Store the new menu handle into <resultReference>.
		Answer whether successful."		

	| resultValue succeeded |
	resultValue := WindowHandle new.  "?? type of a menu handle ??"
	succeeded := self class useUnicode
		ifTrue: [ 
			self invokeOleUIAddVerbMenuW: anOleObject asParameter 
				_: ( self asUnicodeParameter: shortType ) 
				_: hMenu 
				_: uPos 
				_: uIDVerbMin 
				_: uIDVerbMax
				_: bAddConvert 
				_: idConvert
				_: resultValue ]
		ifFalse: [ 
			self invokeOleUIAddVerbMenuA: anOleObject asParameter 
				_: shortType asParameter 
				_: hMenu 
				_: uPos 
				_: uIDVerbMin 
				_: uIDVerbMax
				_: bAddConvert 
				_: idConvert
				_: resultValue ].
	succeeded
		ifTrue: [ resultReference value: resultValue ].
	^succeeded
!  
oleUIInsertObjectA: lpIO
        " Private - invoke the ASCII entry point to open the OLE Insert Object dialog.
            STDAPI_(UINT) OleUIInsertObjectA(LPOLEUIINSERTOBJECTA);"

    <api: OleUIInsertObjectA struct ulongReturn>
    ^self apiCallFailed!  
oleUIConvertW: lpCV
        " Private - invoke the unicode entry point to open the OLE Convert dialog.
            STDAPI_(UINT) OleUIConvertW(LPOLEUICONVERTW);"

    <api: OleUIConvertW struct ulongReturn>
    ^self apiCallFailed!  
oleUIInsertObjectW: lpIO
        " Private - invoke the Unicode entry point to open the OLE Insert Object dialog.
            STDAPI_(UINT) OleUIInsertObjectW(LPOLEUIINSERTOBJECTW);"

    <api: OleUIInsertObjectW struct ulongReturn>
    ^self apiCallFailed!
OleUIChangeSource: lpCS
        "Invokes the standard OLE Change Source dialog.
        The <lpCS> is a pointer to an OLEUICHANGESOURCE in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIChangeSourceW: lpCS ]
        ifFalse: [ self oleUIChangeSourceA: lpCS ]!   
OleUIPasteSpecial: lpPS
        "Invokes the standard OLE Paste Special dialog box which allows the user to select
        the format of the clipboard object to be pasted or paste linked.
        The <lpPS> is a pointer to an OLEUIPASTESPECIAL in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIPasteSpecialW: lpPS ]
        ifFalse: [ self oleUIPasteSpecialA: lpPS ]!  
OleUIUpdateLinks: lpOleUILinkCntr _: hwndParent _: lpszTitle _: cLinks
        "Invokes the standard OLE Updated Links dialog box. "

	^self class useUnicode
		ifTrue: [ self 
			oleUIUpdateLinksW: lpOleUILinkCntr asParameter 
			 _: hwndParent asParameter
			_: ( self asUnicodeParameter: lpszTitle )
			_: cLinks
			]
		ifFalse: [ self 
			oleUIUpdateLinksA: lpOleUILinkCntr asParameter 
			 _: hwndParent asParameter
			_: lpszTitle asParameter
			_: cLinks
			]! 
oleUIPasteSpecialW: lpPS
        " Private - invoke the unicode entry point to open the OLE Paste Special dialog.
            STDAPI_(UINT) OleUIPasteSpecialA(LPOLEUIPASTESPECIALW);"

    <api: OleUIPasteSpecialW struct ulongReturn>
    ^self apiCallFailed!
oleUIPasteSpecialA: lpPS
        " Private - invoke the ASCII entry point to open the OLE Paste Special dialog.
            STDAPI_(UINT) OleUIPasteSpecialA(LPOLEUIPASTESPECIALA);"

    <api: OleUIPasteSpecialA struct ulongReturn>
    ^self apiCallFailed!  
oleUIEditLinksA: lpEL
        " Private - invoke the ASCII entry point to open the OLE Edit Links dialog.
            STDAPI_(UINT) OleUIEditLinksA(LPOLEUIEDITLINKSA);"

    <api: OleUIEditLinksA struct ulongReturn>
    ^self apiCallFailed! 
OleUIInsertObject: lpIO
        "Invokes the standard OLE Insert Object dialog box allowing the user to select an object
        source and classname as well as the option to display the object as itself or as an icon.
        The <lpIO> is a pointer to an OLEUIINSERTOBJECT in-out structure for this dialog. "

	^self class useUnicode
		ifTrue: [ self oleUIInsertObjectW: lpIO ]
		ifFalse: [ self oleUIInsertObjectA: lpIO ]!  
oleUIChangeSourceA: lpCS
        " Private - invoke the ASCII entry point to open the OLE Change Source dialog.
            STDAPI_(UINT) OleUIChangeSourceA(LPOLEUICHANGESOURCEA);"

    <api: OleUIChangeSourceA struct ulongReturn>
    ^self apiCallFailed!  
oleUIChangeSourceW: lpCS
        " Private - invoke the unicode entry point to open the OLE Change Source dialog.
            STDAPI_(UINT) OleUIChangeSourceW(LPOLEUICHANGESOURCEW);"

    <api: OleUIChangeSourceW struct ulongReturn>
    ^self apiCallFailed!
invokeOleUIAddVerbMenuA: lpOleObj _: lpszShortType 
	_: hMenu _: uPos _: uIDVerbMin _: uIDVerbMax
	_: bAddConvert _: idConvert
	_: lphMenu
		" Private - invoke the Unicode entry point for Add Verb Menu
		STDAPI_(BOOL) OleUIAddVerbMenuA(
			LPOLEOBJECT lpOleObj, LPCSTR lpszShortType,
			HMENU hMenu, UINT uPos, UINT uIDVerbMin, UINT uIDVerbMax,
			BOOL bAddConvert, UINT idConvert, HMENU FAR *lphMenu); "

	<api: OleUIAddVerbMenuA handle structIn handle ulong ulong ulong boolean ulong structOut boolean>
	^self apiCallFailed! 
invokeOleUIAddVerbMenuW: lpOleObj _: lpszShortType 
	_: hMenu _: uPos _: uIDVerbMin _: uIDVerbMax
	_: bAddConvert _: idConvert
	_: lphMenu
		" Private - invoke the Unicode entry point for Add Verb Menu
			STDAPI_(BOOL) OleUIAddVerbMenuW(
				LPOLEOBJECT lpOleObj, LPCWSTR lpszShortType,
				HMENU hMenu, UINT uPos, UINT uIDVerbMin, UINT uIDVerbMax,
				BOOL bAddConvert, UINT idConvert, 
				HMENU FAR *lphMenu); "

	<api: OleUIAddVerbMenuW handle structIn handle ulong ulong ulong boolean ulong structOut boolean>
	^self apiCallFailed!  
OleUIConvert: lpCV
        "Invokes the standard OLE Change Type dialog box allowing the user to change the type
        of the single specified object, or change the type of all OLE objects of a specified type.
        The <lpCV> is a pointer to an OLEUICONVERT in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIConvertW: lpCV ]
        ifFalse: [ self oleUIConvertA: lpCV ]! 
OleUIChangeIcon: lpCI
        "Invokes the standard OLE Change Icon dialog box allowing the user to select
        an icon from an icon file, executable, or DLL.
        The <lpCI> is a pointer to an OLEUICHANGEICON in-out structure for this dialog. "

    ^self class useUnicode
        ifTrue: [ self oleUIChangeIconW: lpCI ]
        ifFalse: [ self oleUIChangeIconA: lpCI ]!  
oleUIConvertA: lpCV
        " Private - invoke the ASCII entry point to open the OLE Convert dialog.
            STDAPI_(UINT) OleUIConvertA(LPOLEUICONVERTA);"

    <api: OleUIConvertA struct ulongReturn>
    ^self apiCallFailed!
invokeScroll: x _: y
        " Private - invoke the IOleInPlaceSite:Scroll function for an external caller. "

	"virtual HRESULT __stdcall Scroll( 
            /* [in] */ SIZE scrollExtant) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchScroll: x @ y.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
editLinks
        " Private - Perform the Edit menu Links operation.
        Open the standard OLE Edit Links dialog. "

    self editLinksInContainer: self container.!  
getBorder
		" Answer the outer rectangle (relative to the window) in which the
		object can put toolbars and similar controls when it is active in place. 
		Answer nil if the object is not allowed to install toolbars on this window. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetBorder: resultReference.
	^resultReference value!
setBorderSpace: borderWidthsRectangle
		" Allocate space for the border requested by IOleInPlaceUIWindow::RequestBorderSpace.
		The <borderWidthsRectangle> is nil if the object does not need space. "

	interface SetBorderSpace: borderWidthsRectangle!
requestBorderSpace: borderWidthsRectangle
		" Determine whether tools can be installed around the object's frame window
		while the object is active in place.  Called by the object to determine
		whether tools can be allocated between the rectangle returned
		by IOleInPlaceUIWindow::GetBorder and <borderWidthsRectangle>. "

	interface RequestBorderSpace: borderWidthsRectangle! 
canHaveBorderSpace: borderWidthsRectangle
		" Answer whether tools can be installed around the object's frame window
		while the object is active in place.  Called by the object to determine
		whether tools can be allocated between the rectangle returned
		by IOleInPlaceUIWindow::GetBorder and <borderWidthsRectangle>. "

	^( interface RequestBorderSpace: borderWidthsRectangle ) = S_OK!
setActiveObject: anIOleInPlaceActiveObject name: objectName
		" Register <anIOleInPlaceActiveObject> as the in-place active object
		in the document or frame window. "

	interface SetActiveObject: anIOleInPlaceActiveObject _: objectName! 
removeBorderSpace
		" Deallocate space for the border. "

	interface SetBorderSpace: nil!  
getWindow
		"Answer the window handle of a window participating in in-place
		activation (frame, document, parent, or in-place object window). "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetWindow: resultReference.
	^resultReference value!   
exitContextSensitiveHelpMode
		"Exit context-sensitive help mode during an in-place
		activation session. "

	interface ContextSensitiveHelp: false.! 
enterContextSensitiveHelpMode
		"Enter context-sensitive help mode during an in-place
		activation session. "

	interface ContextSensitiveHelp: true.!
contextSensitiveHelp: aBoolean
		"Enter or exit context-sensitive help mode during an in-place
		activation session. "

	interface ContextSensitiveHelp: aBoolean!
objectMenuGroupWidth
		" Answer the number of items in the objects's object menu group. "

	^self longAtOffset: 12!
OnUIDeactivate: bool
	"Invoke the IOleInPlaceSite::OnUIDeactivate function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchOnUIDeactivate: bool)!  
ShowObject
		" Invoke the IOleClientSite::ShowObject function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: self dispatchShowObject!  
dispatchRequestNewObjectLayout
		" Private - dispatch the IOleClientSite::RequestNewObjectLayout function. "

    ^( functionHandlers at: 9 ) evaluate!
invokeGetMoniker: dwAssign _: dwWhichMoniker _: ppmk
        "Private - invoke the IOleClientSite::GetMoniker function for an external caller. "

    " HRESULT GetMoniker(
            /* [in] */ DWORD dwAssign,
            /* [in] */ DWORD dwWhichMoniker,
            /* [out] */ IMoniker **ppmk); "

    | hresult resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ppmk isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: ppmk.

    resultReference := nil asValueReference.
    hresult := self dispatchGetMoniker: dwAssign
        _: dwWhichMoniker
        _: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppmk put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'Moniker: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult!  
OnShowWindow: fShow
		" Invoke the IOleClientSite::OnShowWindow function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchOnShowWindow: fShow )!   
dispatchOnShowWindow: fShow
		" Private - dispatch the IOleClientSite::OnShowWindow function. "

    ^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
		with: fShow )!  
GetMoniker: dwAssign _: dwWhichMoniker _: resultReference
        " Invoke the IOleClientSite::GetMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchGetMoniker: dwAssign _: dwWhichMoniker _: resultReference )!   
dispatchGetContainer: resultReference
        " Private - dispatch the IOleClientSite::GetContainer function. "

    ^( functionHandlers at: 6 ) evaluateWithArguments: ( Array
		with: resultReference )!
invokeGetContainer: ppContainer
        " Private - invoke the IOleClientSite::GetContainer functionfor an external caller. "

    " HRESULT GetContainer(
            /* [out] */ IOleContainer **ppContainer); "

    | hresult resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ppContainer isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: ppContainer.

    resultReference := nil asValueReference.
    hresult := self dispatchGetContainer: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppContainer put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'Container: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult!
invokeSaveObject
		"Private - invoke the IOleClientSite::SaveObject function for an external caller. "

	" HRESULT SaveObject( void); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchSaveObject.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
RequestNewObjectLayout
		" Invoke the IOleClientSite::RequestNewObjectLayout function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: self dispatchRequestNewObjectLayout!  
dispatchShowObject
		" Private - dispatch the IOleClientSite::ShowObject function. "

    ^( functionHandlers at: 7 ) evaluate!
dispatchSaveObject
		" Private - dispatch the IOleClientSite::SaveObject function. "

    ^( functionHandlers at: 4 ) evaluate!
invokeOnShowWindow: fShow
		"Private - invoke the IOleClientSite::OnShowWindow function for an external caller. "

	" HRESULT OnShowWindow(
            /* [in] */ BOOL fShow); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnShowWindow: fShow.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
invokeRequestNewObjectLayout
		"Private - invoke the IOleClientSite::RequestNewObjectLayout function for an external caller. "

	" HRESULT RequestNewObjectLayout( void); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchRequestNewObjectLayout.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
GetContainer: resultReference
        " Invoke the IOleClientSite::GetContainer function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchGetContainer: resultReference )! 
dispatchGetMoniker: dwAssign _: dwWhichMoniker _: resultReference
        " Private - dispatch the IOleClientSite::GetMoniker function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
        with: dwAssign
        with: dwWhichMoniker
        with: resultReference )!  
invokeShowObject
		"Private - invoke the IOleClientSite::ShowObject function for an external caller. "

	" HRESULT ShowObject( void); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchShowObject.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
SaveObject
		" Invoke the IOleClientSite::SaveObject function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: self dispatchSaveObject!  
saveContainerFile
		" Private - Save the container storage file. "

    [ self container saveDocument ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Container File Save Problem' ].!   
changesHandled
        " Private - answer whether changes have been handled.
        The user is typically allowed to choose whether to save or discard
        any changes or whether to cancel the operation in progress. "

	self implementedBySubclass.! 
editClear
        "Private - Perform the Edit menu Clear operation."

    self clearClientSite: self activeSite.!  
exitIfLastWindow
        " Private - Shut down the application if there are no more windows open. "

    Notifier windows
        detect: [ :w | w isApplicationWindow or: [ w isDialogWindow ] ]
        ifNone: [ ^Smalltalk exit ]!   
invokeGetBoundSource: ppunk
		" Private - invoke the IOleLink::GetBoundSource function. "

	" HRESULT GetBoundSource(
            /* [out] */ IUnknown **ppunk); "

	| hresult |
	<ole: 11 structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = E_FAIL
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!
SetUpdateOptions: dwUpdateOpt
		" Invoke the IOleLink::SetUpdateOptions function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT SetUpdateOptions(
            /* [in] */ DWORD dwUpdateOpt); "

   <ole: 3 ulong hresult>
    ^self vtableDispatchFailed!   
GetSourceDisplayName: resultReference
		" Invoke the IOleLink::GetSourceDisplayName function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := self createStringResultValue.
    hresult := self invokeGetSourceDisplayName: resultValue.
    resultReference value: ( self stringFromResultValue: resultValue ).
    ^hresult!
invokeSetSourceMoniker: pmk _: rclsid
		" Private - invoke the IOleLink::GetUpdateOptions function. "

	" HRESULT SetSourceMoniker(
            /* [unique][in] */ IMoniker *pmk,
            /* [in] */ REFCLSID rclsid); "

	<ole: 5 handle structIn hresult>
	^self vtableDispatchFailed!  
UnbindSource
		" Invoke the IOleLink::UnbindSource function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT UnbindSource( void); "

	<ole: 12 hresult>
    ^self vtableDispatchFailed!
invokeGetSourceDisplayName: ppszDisplayName
		" Private - invoke the IOleLink::GetSourceDisplayName function. "

	" HRESULT GetSourceDisplayName(
            /* [out] */ LPOLESTR *ppszDisplayName); "

	<ole: 8 structOut hresult>
	^self vtableDispatchFailed!  
SetSourceDisplayName: aDisplayName
		" Invoke the IOleLink::SetSourceDisplayName function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeSetSourceDisplayName: ( self asUnicodeParameter: aDisplayName )!  
invokeSetSourceDisplayName: pszDisplayName
		" Private - invoke the IOleLink::SetSourceDisplayName function. "

	" HRESULT SetSourceDisplayName(
            /* [in] */ LPCOLESTR pszStatusText); "

	<ole: 7 structIn hresult>
	^self vtableDispatchFailed!   
invokeBindToSource: bindflags _: pbc
		" Private - invoke the IOleLink::BindToSource function. "

	" HRESULT BindToSource(
            /* [in] */ DWORD bindflags,
            /* [unique][in] */ IBindCtx *pbc); "

	<ole: 9 ulong handle hresult>
	^self vtableDispatchFailed!  
invokeGetUpdateOptions: dwUpdateOpt
		" Private - invoke the IOleLink::GetUpdateOptions function. "

	" HRESULT GetUpdateOptions(
            /* [out] */ DWORD *pdwUpdateOpt); "

	<ole: 4 structOut hresult>
	^self vtableDispatchFailed!
invokeUpdate: pbc
    " Private - invoke the IOleLink::Update function. "

	" HRESULT Update(
            /* [unique][in] */ IBindCtx *pbc); "

	<ole: 13 handle hresult>
	^self vtableDispatchFailed! 
invokeGetSourceMoniker: ppmk
		" Private - invoke the IOleLink::GetSourceMoniker function. "

	" HRESULT GetSourceMoniker(
            /* [out] */ IMoniker **ppmk); "

	<ole: 6 structOut hresult>
	^self vtableDispatchFailed!   
BindToSource: bindflags _: anIBindCtx
		" Invoke the IOleLink::BindToSource function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeBindToSource: bindflags _: anIBindCtx asParameter! 
SetSourceMoniker: anIMoniker _: clsid
		" Invoke the IOleLink::SetSourceMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self invokeSetSourceMoniker: anIMoniker asParameter
        _: clsid!
GetBoundSource: resultReference
		" Invoke the IOleLink::GetBoundSource function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult  |
    resultValue := IUnknownPointer forReturnValue.
    hresult := self invokeGetBoundSource: resultValue asParameter.
    resultReference value: ( ( HRESULT succeeded: hresult )
		ifTrue: [ resultValue ]
		ifFalse: [ nil ] ).
    ^hresult! 
Update: anIBindCtx
		" Invoke the IOleLink::Update function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeUpdate: anIBindCtx asParameter!
BindIfRunning
		" Invoke the IOleLink::BindIfRunning function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT BindIfRunning( void); "

   <ole: 10 hresult>
    ^self vtableDispatchFailed!   
GetSourceMoniker: resultReference
		" Invoke the IOleLink::GetSourceMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult  |
    resultValue := IMonikerPointer forReturnValue.
    hresult :=  self invokeGetSourceMoniker: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!
GetUpdateOptions: resultReference
		" Invoke the IOleLink::GetUpdateOptions function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
    resultValue := ExternalLong new.
    hresult :=  self invokeGetUpdateOptions: resultValue.
    resultValue := resultValue asUnsignedInteger.
    resultReference value: ( resultValue = 0
        ifTrue: [ nil ]
        ifFalse: [ resultValue ] ).
    ^hresult
!   
dragSourceNeedsObject: dragSession sitePane: aSitePane
        "Private - a drag operation is being commenced, set the contents
        of the drag into the dragSession."

    | dragDropObject |
    aSitePane siteObject isEmpty
        ifTrue: [ ^self ]. "site does not contain an object"
    dragDropObject := dragSession objectClass new
        format: 'Embedded Object' data: aSitePane siteObject cloneOleObject;
        yourself.
    dragSession objects: ( Array with: dragDropObject ).
!   
removeStructureName
        " Private - remove the host data structure name represented by the receiver. "

    OLEStructure removeStructureName: #OLEINPLACEFRAMEINFO.!   
IsRunning: anItemName
		" Invoke the IOleItemContainer::IsRunning function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self isRunning: ( self asUnicodeParameter: anItemName )
! 
invokeGetObject: pszItem _: dwSpeedNeeded _: pbc _: riid _: ppvObject
		" Private - invoke the IOleItemContainer::GetObject function. "

	" HRESULT GetObject(
            /* [in] */ LPOLESTR pszItem,
            /* [in] */ DWORD dwSpeedNeeded,
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObject); "

	| hresult |
    <ole: 6 structIn ulong handle structIn structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = E_NOINTERFACE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed
!  
GetObjectStorage: anItemName _: aBindContext _: iid _: resultReference
		" Invoke the IOleItemContainer::GetObjectStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self 
		invokeGetObjectStorage: ( self asUnicodeParameter: anItemName )
		_: aBindContext asParameter
		_: iid
		_: resultValue asParameter.
	resultReference value: ( ( HRESULT succeeded: hresult )
		ifTrue: [ resultValue ]
		ifFalse: [ nil ] ).
	^hresult!  
invokeIsRunning: pszItem
		" Private - invoke the IOleItemContainer::IsRunning function. "

	" HRESULT IsRunning(
            /* [in] */ LPOLESTR pszItem); "

    <ole: 8 structIn hresult>
    ^self vtableDispatchFailed
! 
GetObject: anItemName _: dwSpeedNeeded _: aBindContext _: iid _: resultReference
		" Invoke the IOleItemContainer::GetObject function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := OLEInterfacePointer forReturnValueWithIID: iid.
	hresult := self 
		invokeGetObject: ( self asUnicodeParameter: anItemName )
		_: dwSpeedNeeded 
		_: aBindContext asParameter
		_: iid
		_: resultValue asParameter.
	resultReference value: ( ( HRESULT succeeded: hresult )
		ifTrue: [ resultValue ]
		ifFalse: [ nil ] ).
	^hresult! 
invokeGetObjectStorage: pszItem _: pbc _: riid _: ppvStorage
		" Private - invoke the IOleItemContainer::GetObjectStorage function. "

	" HRESULT GetObjectStorage(
            /* [in] */ LPOLESTR pszItem,
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvStorage); "

	| hresult |
    <ole: 7 structIn handle structIn structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = MK_E_NOSTORAGE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed
!  
LockContainer: fLock
		" Invoke the IOleContainer::LockContainer function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT LockContainer(
            /* [in] */ BOOL fLock); "

    <ole: 5 boolean hresult>
    ^self vtableDispatchFailed! 
EnumObjects: grfFlags _: resultReference
        " Invoke the IOleContainer::EnumObjects function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumUnknown.
	hresult := self
        invokeEnumObjects: grfFlags
        _: resultValue asParameter.
	resultReference value: resultValue.
    ^hresult!  
invokeEnumObjects: grfFlags _: ppenum
		" Private - invoke the IOleContainer::EnumObjects function. "

	" HRESULT EnumObjects(
            /* [in] */ DWORD grfFlags,
            /* [out] */ IEnumUnknown **ppenum); "

    <ole: 4 ulong structOut hresult>
    ^self vtableDispatchFailed! 
invokeGetExtent: dwDrawAspect _: lindex _: ptd _: lpsizel
		" Private - invoke the IViewObject2::GetExtent. "

	" HRESULT GetExtent(
            /* [in] */ DWORD dwDrawAspect,
            /* [in] */ LONG lindex,
            /* [in] */ DVTARGETDEVICE *ptd,
            /* [out] */ LPSIZEL lpsizel); "

    <ole: 9 ulong long structIn structOut hresult>
    ^self vtableDispatchFailed
!   
GetExtent: dwDrawAspect _: lindex _: ptd _: resultReference
		" Invoke the IViewObject2::GetExtent function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := WinPoint new.
	hresult := self invokeGetExtent: dwDrawAspect 
		_: lindex 
		_: ptd
		_: resultValue.
	resultReference value: resultValue.
	^hresult!   
Draw:dwDrawAspect
    _: lindex
    _: pvAspect
    _: ptd
    _: hdcTargetDev
    _: hdcDraw
    _: lprcBounds
    _: lprcWBounds
    _: pfnContinue
    _: dwContinue
        " Invoke the IViewObject::Draw function.
        Raise an exception if an error occurs.  Answer the result code. "

    self ISSUE.  " Need a civilized protocol for pass pfnContinue.
        Take a Message argument here and convert it a callback function?     [JK 05-Apr-94] "

    ^self
        invokeDraw:dwDrawAspect
        _: lindex
        _: pvAspect asParameter
        _: ptd asParameter
        _: hdcTargetDev asParameter
        _: hdcDraw asParameter
        _: lprcBounds asParameter
        _: lprcWBounds asParameter
        _: pfnContinue asParameter
        _: dwContinue!  
invokeGetColorSet: dwDrawAspect
    _: lindex
    _: pvAspect
    _: ptd
    _: hdcTargetDev
    _: ppColorSet
		" Private - invoke the IViewObject::GetColorSet function. "

	"  HRESULT GetColorSet(
            /* [in] */ DWORD dwDrawAspect,
            /* [in] */ LONG lindex,
            /* [unique][in] */ void *pvAspect,
            /* [in] */ DVTARGETDEVICE *ptd,
            /* [in] */ HDC hicTargetDev,
            /* [out] */ LOGPALETTE **ppColorSet); "

    <ole: 4 ulong long structIn structIn handle structOut hresult>
    ^self vtableDispatchFailed!
invokeDraw:dwDrawAspect
    _: lindex
    _: pvAspect
    _: ptd
    _: hdcTargetDev
    _: hdcDraw
    _: lprcBounds
    _: lprcWBounds
    _: pfnContinue
    _: dwContinue
		" Private - invoke the IViewObject::Draw function. "

	" HRESULT Draw(
            /* [in] */ DWORD dwDrawAspect,
            /* [in] */ LONG lindex,
            /* [unique][in] */ void *pvAspect,
            /* [unique][in] */ DVTARGETDEVICE *ptd,
            /* [in] */ HDC hdcTargetDev,
            /* [in] */ HDC hdcDraw,
            /* [in] */ LPCRECTL lprcBounds,
            /* [in] */ LPCRECTL lprcWBounds,
            /* [in] */ BOOL ( *pfnContinue ) ( DWORD dwContinue),
            /* [in] */ DWORD dwContinue); "

    <ole: 3 ulong long structIn structIn handle handle structIn structIn structIn ulong hresult>
    ^self vtableDispatchFailed!   
invokeGetAdvise: pAspects
    _: pAdvf
    _: ppAdvSink
		" Private - invoke the IViewObject::GetAdvise function. "

	" HRESULT GetAdvise(
            /* [out] */ DWORD *pAspects,
            /* [out] */ DWORD *pAdvf,
            /* [out] */ IAdviseSink **ppAdvSink); "

    <ole: 8 structOut structOut structOut hresult>
    ^self vtableDispatchFailed!  
GetColorSet: dwDrawAspect
    _: lindex
    _: pvAspect
    _: ptd
    _: hdcTargetDev
    _: resultReference
		" Invoke the IViewObject::GetColorSet function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := WinLogPalette new.
	hresult := self
		invokeGetColorSet: dwDrawAspect
		_: lindex
		_: pvAspect
		_: ptd asParameter
		_: hdcTargetDev asParameter
		_: resultValue.
	resultReference value: resultValue.
	^hresult! 
SetAdvise: aspects _: advf _: anAdviseSink
		" Invoke the IViewObject::SetAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self
        invokeSetAdvise: aspects
        _: advf
        _: anAdviseSink asParameter!   
Unfreeze: freezeToken
		" Invoke the IViewObject::Unfreeze function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Unfreeze(
            /* [in] */ DWORD dwFreeze); "

    <ole: 6 ulong hresult>
    ^self vtableDispatchFailed!  
GetAdvise: aspectsReference
    _: adviseFlagsReference
    _: resultReference
		" Invoke the IViewObject::GetAdvise function.
		Raise an exception if an error occurs.  Answer the result code. "

	| aspectsValue adviseFlagsValue resultValue hresult |
	aspectsReference notNil
		ifTrue: [ aspectsValue := ExternalLong new ].
	adviseFlagsReference notNil
		ifTrue: [ adviseFlagsValue := ExternalLong new ].
	resultReference notNil
		ifTrue: [ resultValue := IAdviseSinkPointer forReturnValue ].
	hresult := self
		invokeGetAdvise: aspectsValue
		_: adviseFlagsValue
		_: resultValue asParameter.
	aspectsReference notNil
		ifTrue: [ aspectsReference value: aspectsValue asUnsignedInteger ].
	adviseFlagsReference notNil
		ifTrue: [ adviseFlagsReference value: adviseFlagsValue asUnsignedInteger ].
	( resultReference notNil
	and: [ resultValue isValid ] )  " necessary? "
		ifTrue: [ resultReference value: resultValue ].
	^hresult!
invokeSetAdvise: aspects
    _: advf
    _: pAdvSink
		" Private - invoke the IViewObject::SetAdvise function. "

	" HRESULT SetAdvise(
            /* [in] */ DWORD aspects,
            /* [in] */ DWORD advf,
            /* [unique][in] */ IAdviseSink *pAdvSink); "

    <ole: 7 ulong ulong handle hresult>
    ^self vtableDispatchFailed! 
Freeze: dwDrawAspect
    _: lindex
    _: pvAspect
    _: resultReference
		" Invoke the IViewObject::Freeze function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self 
		invokeFreeze: dwDrawAspect
		_: lindex
		_: pvAspect
		_: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult!
invokeFreeze: dwDrawAspect
    _: lindex
    _: pvAspect
    _: pdwFreeze
		" Private - invoke the IViewObject::Freeze function. "

	" HRESULT Freeze(
            /* [in] */ DWORD dwDrawAspect,
            /* [in] */ LONG lindex,
            /* [unique][in] */ void *pvAspect,
            /* [out] */ DWORD *pdwFreeze); "

    <ole: 5 ulong long structIn structOut hresult>
    ^self vtableDispatchFailed!
fileOpen
        " Private - Perform the File menu Open... operation. "

    | aPathName fileType |

    self changesHandled ifFalse: [^nil].
    fileType := '*.', self fileExtension.
    aPathName := (FileDialog new
        addFilter: fileType description: 'Container Files (', fileType asUppercase, ')';
        defFilter: fileType;
        openFile: fileType)
            file.
    aPathName isNil ifTrue: [ ^self ].

	CursorManager execute changeFor: [
		( self openContainerFile: aPathName )
			ifTrue: [ self fileName: aPathName ]
			ifFalse: [
				self
					newContainerFile;
					fileName: nil;
					setWindowTitle ].
		].
!   
DeactivateAndUndo
	"Invoke the IOleInPlaceSite::DeactivateAndUndo function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchDeactivateAndUndo)! 
dispatchGetWindow: phwnd
		" Private - dispatch the IOleWindow::GetWindow function. "

	^( functionHandlers at: 4 ) evaluateWithArguments: ( Array 
		with: phwnd )!  
dispatchContextSensitiveHelp: enterHelpMode
		" Private - dispatch the IOleWindow::ContextSensitiveHelp function. "

	^( functionHandlers at: 5 ) evaluateWithArguments: ( Array 
		with: enterHelpMode )!
invokeContextSensitiveHelp: bool
        " Private - invoke the IOleWindow::ContextSensitiveHelp function for an external caller. "

	"virtual HRESULT __stdcall ContextSensitiveHelp( 
            /* [in] */ BOOL fEnterMode) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchContextSensitiveHelp: bool.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!  
GetWindow: resultReference
	"Invoke the IOleWindow::GetWindow function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchGetWindow: resultReference)!
invokeGetWindow: phwnd
        " Private - invoke the IOleWindow::GetWindow function for an external caller. "

    "/* [input_sync] */ HRESULT GetWindow(
            /* [out] */ HWND *phwnd)"

    | resultReference hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    phwnd isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: phwnd.
    resultReference := nil asValueReference.
    hresult := self dispatchGetWindow: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self windowHandleResultAtAddress: phwnd put: resultReference value ].
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
ContextSensitiveHelp: enterHelpMode
	"Invoke the IOleWindow::ContextSensitiveHelp function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchContextSensitiveHelp: enterHelpMode)!   
checkFlags
        "Private - check user action."

    self style: self flags.
    hMetaPict := oleUIChangeIconStruct hMetaPict.


!   
szIconExe: aString
        " Set the source path of the icon to <aString: MAX_PATH>. "

    oleUIChangeIconStruct szIconExe: aString.
!   
owner: anOwner
        "Sets the owner of the Dialog box."

    super owner: anOwner.
    owner isWindow
        ifTrue: [ parent := owner ]
        ifFalse: [
            parent := owner mainView.
            parent isWindow ifFalse: [
                parent := Notifier findWindow: WindowHandle queryActive ]].
    oleUIChangeIconStruct hWndOwner: parent asParameter.
!
flags: dwFlags
        "Set the dialog box creation flags value."

    oleUIChangeIconStruct dwFlags: dwFlags.
   self style: dwFlags.

!   
flags
        "Answers the dialog box current flags value."

    ^oleUIChangeIconStruct dwFlags

!   
open: titleString
        " Invoke the standard OLE Change Icon dialog."

    | result |
    [ hLibrary := OLEDialogDLL current ]
        on: Error
        do: [
            MessageBox warning: 'Could not find ', OLEDialogDLL fileName asUppercase, '.
You must have this DLL to invoke the standard OLE Change Icon dialog.'.
            ^self ].
    parent isWindow ifFalse: [
        parent := Notifier findWindow: WindowHandle queryActive.
        oleUIChangeIconStruct hWndOwner: parent asParameter ].
    style notNil
        ifTrue: [ oleUIChangeIconStruct dwFlags: style ].
    titleString notNil
        ifTrue: [ oleUIChangeIconStruct dialogCaption: titleString ].

    result := hLibrary OleUIChangeIcon: oleUIChangeIconStruct.
    "Transcript cr; show: result printString."
    result = OLEUI_SUCCESS
        ifTrue: [ self checkFlags ].
    self cleanUp.
!  
cleanUp
        "Private - Free oleUIChangeIconStruct."

    self style: self flags.
    oleUIChangeIconStruct release.
    oleUIChangeIconStruct := nil.
! 
hMetaPict: aHandle
        " Set the handle to a METAFILEPICT containing the icon to <aHandle>. "

    oleUIChangeIconStruct hMetaPict: aHandle
! 
initialize
        "Private - Initialize oleChangeIconStruct."

    super initialize.
    oleUIChangeIconStruct := OLE_OLEUICHANGEICON new.
    self style: CIF_SELECTCURRENT.
!
hMetaPict
        "Answer the content of cached hMetaPict field."

    ^hMetaPict
!   
clsid: aGuid
        " Set the class ID of the default icon to <aGuid>. "

    oleUIChangeIconStruct clsid: aGuid.
!  
open
        " Invoke the standard OLE Change Icon dialog."

    ^self open: nil
!
editConvertObject
        " Private - Perform the Edit menu Object convert operation. "

    self convertObjectInClientSite: self activeSite.! 
cClsidExclude: anInteger
        " Private - Set the number of CLSIDs in lpClsidExclude to <anInteger>. "

    self uLongAtOffset: 56 put: anInteger.
!   
lpClsidExcludeOffset
        " Private - answer the offset of the address of the list of CLSIDs to exclude from listing. "

	^60!  
pasteEntries: aListOfOleUIPasteEntry
        " Set the list of acceptable link types to <aListOfOleUIPasteEntry>. "

    | count elementSize pasteEntriesBuffer index |
    count := aListOfOleUIPasteEntry size.
    elementSize := OLE_OLEUIPASTEENTRY sizeInBytes.
    pasteEntriesBuffer := ExternalBuffer new: count * elementSize.
    index := 0.
    1 to: count do: [ :i |
        pasteEntriesBuffer bytesAtOffset: index
            put: ( aListOfOleUIPasteEntry at: i ) contents.
        index := index + elementSize ].
    self
        cPasteEntries: count;
        arrPasteEntries: ( ExternalAddress
            copyToNonSmalltalkMemory: pasteEntriesBuffer asParameter ).
!   
releaseResources
        " Private - release resources owned by the receiver. "

    self
        releaseLinkTypes;
        releasePasteEntries;
        releaseClsidExclude.
    super releaseResources.! 
nSelectedIndex
        " Answer the user selected index.
        This is a zero based index."

    ^self longAtOffset: 64!
lpSrcDataObj: anInterface
        " Set the source IDataObject interface on the clipboard to <anInterface>. "

    self interfaceAtOffset: 36 put: anInterface


!  
cLinkTypes: anInteger
        " Set the number of link types to <anInteger>. "

    self longAtOffset: 52 put: anInteger.
!   
sizel
        " Answer  the size of the object as displayed in its source.
         If the user chooses a different aspect, then sizel.cx and sizel.cy are both set to zero. "

    ^Point new
        x: ( self uLongAtOffset: 76 );
        y: ( self uLongAtOffset: 80 );
        yourself
!   
lpSrcDataObj
        " Answer the source IDataObject interface on the clipboard. "

	^self interfaceAtOffset: 36 type: IDataObject



!
arrPasteEntries
        " Answer the address of an array of acceptable formats. "

    arrPasteEntries notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 40 ) asInteger = arrPasteEntries asInteger ].
    ^arrPasteEntries



! 
arrPasteEntries: anAddress
        " Set the address of an array of acceptable formats is stored to <anAddress>. "

	self addressAtOffset: 40 put: anAddress.
	arrPasteEntries := anAddress.


!   
cPasteEntries: anInteger
        " Set the number of OLEUIPASTEENTRY entries in arrPasteEntries to <anInteger>. "

    self longAtOffset: 44 put: anInteger.
!
arrLinkTypes
        " Answer the address of an array of acceptable link types. "

    arrLinkTypes notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 48 ) asInteger = arrLinkTypes asInteger ].
    ^arrLinkTypes


!
linkTypes: aListOfOleUIPasteFlag
        " Set the list of acceptable link types to <aListOfOleUIPasteFlag>. "

    | count elementSize linkTypesBuffer index |
    count := aListOfOleUIPasteFlag size.
    elementSize := ExternalLong sizeInBytes.
    linkTypesBuffer := ExternalBuffer new: count * elementSize.
    index := 0.
    1 to: count do: [ :i |
        linkTypesBuffer uLongAtOffset: index
            put: ( aListOfOleUIPasteFlag at: i ).
        index := index + elementSize ].
    self
        cLinkTypes: count;
        arrLinkTypes: ( ExternalAddress
            copyToNonSmalltalkMemory: linkTypesBuffer asParameter ).
!
hMetaPict
        " Answer the handle of the METAFILEPICT containing the icon. "

    ^self handleAtOffset: 72

!
releasePasteEntries
        " Private "

    | anAddress |
    ( anAddress := self arrPasteEntries ) notNil
        ifTrue: [
            anAddress free.
            self arrPasteEntries: nil ].
!  
arrLinkTypes: anAddress
        " Set the address of an array of acceptable link types is stored to <anAddress>. "

	self addressAtOffset: 48 put: anAddress.
	arrLinkTypes := anAddress.

!
releaseLinkTypes
        " Private "

    | anAddress |
    ( anAddress := self arrLinkTypes ) notNil
        ifTrue: [
            anAddress free.
            self arrLinkTypes: nil ].
!   
fLink
        " Answer a  boolean indicating whether Paste or Paste Link was selected by the user. "

    ^self booleanAtOffset: 68
! 
helpMenuGroupWidth: anInteger
		" Set the number of items in the objects's help menu group. "

	self longAtOffset: 20 put: anInteger.! 
open
        " Invoke the standard OLE Busy dialog."

    ^self open: nil.!
open: titleString
        " Invoke the standard OLE Busy dialog."

    | result |
    [ hLibrary := OLEDialogDLL current ]
        on: Error
        do: [
            MessageBox warning: 'Could not find ', OLEDialogDLL fileName asUppercase, '.
You must have this DLL to invoke the standard OLE Busy dialog.'.
            ^self ].
    parent isWindow ifFalse: [
        parent := Notifier findWindow: WindowHandle queryActive.
        oleUIBusyStruct hWndOwner: parent asParameter ].
    style notNil
        ifTrue: [ oleUIBusyStruct dwFlags: style ].
    titleString notNil
        ifTrue: [ oleUIBusyStruct dialogCaption: titleString ].

    result := hLibrary OleUIBusy: oleUIBusyStruct.
    result = OLEUI_SUCCESS
        ifTrue: [ self checkFlags ].
    self cleanUp.
!  
cleanUp
        "Private - Free oleUIBusyStruct."

    self style: self flags.
    oleUIBusyStruct release.
    oleUIBusyStruct := nil.
!   
owner: anOwner
        "Sets the owner of the Dialog box."

    super owner: anOwner.
    owner isWindow
        ifTrue: [ parent := owner ]
        ifFalse: [
            parent := owner mainView.
            parent isWindow ifFalse: [
                parent := Notifier findWindow: WindowHandle queryActive ]].
    oleUIBusyStruct hWndOwner: parent asParameter.
!  
flags
        "Answers the dialog box current flags value."

    ^oleUIBusyStruct dwFlags! 
flags: dwFlags
        "Set the dialog box creation flags value."

    oleUIBusyStruct dwFlags: dwFlags.
    self style: dwFlags.!
hWndDialog: hWnd
        " Set the dialog handle to <hWnd>. "

    oleUIBusyStruct hWndDialog: hWnd
! 
initialize
        "Private - Initialize oleUIBusyStruct."

    super initialize.
    oleUIBusyStruct := OLE_OLEUIBUSY new.
    self style: 0.
!
hTask: hTask
        " Set the handle of the blocking task to <hTask>. "

    oleUIBusyStruct hTask: hTask.
! 
checkFlags
        "Private - check user action."

    self style: self flags.!
checkFlags
        "Private - check user action."

    self style: self flags.

	"Disable the following - it is causing problems with finalization."
	"sourceDataObject := oleUIPasteSpecialStruct lpSrcDataObj."

    selectedIndex := oleUIPasteSpecialStruct nSelectedIndex + 1.   "Convert to one based index."
    linkFlag := oleUIPasteSpecialStruct fLink.
    hMetaPict := oleUIPasteSpecialStruct hMetaPict.
    objectSize := oleUIPasteSpecialStruct sizel.
! 
owner: anOwner
        "Sets the owner of the Dialog box."

    super owner: anOwner.
    owner isWindow
        ifTrue: [ parent := owner ]
        ifFalse: [
            parent := owner mainView.
            parent isWindow ifFalse: [
                parent := Notifier findWindow: WindowHandle queryActive ]].
    oleUIPasteSpecialStruct hWndOwner: parent asParameter.
!  
pasteEntries: aListOfOleUIPasteEntry
        " Set the list of acceptable link types to <aListOfOleUIPasteEntry>. "

    oleUIPasteSpecialStruct pasteEntries: aListOfOleUIPasteEntry.
!  
selectedIndex
        " Answer the user selected index. "

    ^selectedIndex


!   
excludeClasses: aListOfCLSIDs
        " Set the list of classes to exclude from the list to <aListOfCLSIDs>. "

    oleUIPasteSpecialStruct excludeClasses: aListOfCLSIDs.
!  
flags
        "Answers the dialog box current flags value."

    ^oleUIPasteSpecialStruct dwFlags
!   
flags: dwFlags
        "Set the dialog box creation flags value."

    oleUIPasteSpecialStruct dwFlags: dwFlags.
    self style: dwFlags.
!  
objectSize
        " Answer the size of the object as displayed in its source. "

    ^objectSize

! 
open: titleString
        " Invoke the standard OLE Paste Special dialog."

    | result |
    [ hLibrary := OLEDialogDLL current ]
        on: Error
        do: [
            MessageBox warning: 'Could not find ', OLEDialogDLL fileName asUppercase, '.
You must have this DLL to invoke the standard OLE Paste Special dialog.'.
            ^self ].
    parent isWindow ifFalse: [
        parent := Notifier findWindow: WindowHandle queryActive.
        oleUIPasteSpecialStruct hWndOwner: parent asParameter ].
    style notNil
        ifTrue: [ oleUIPasteSpecialStruct dwFlags: style ].
    titleString notNil
        ifTrue: [ oleUIPasteSpecialStruct dialogCaption: titleString ].

    result := hLibrary OleUIPasteSpecial: oleUIPasteSpecialStruct.
    result = OLEUI_SUCCESS
        ifTrue: [ self checkFlags ].
    self cleanUp.
!
sourceDataObject: anIDataObject
        " Set the source data object to <anIDataObject>. "

    oleUIPasteSpecialStruct lpSrcDataObj: anIDataObject
! 
cleanUp
        "Private - Free oleUIPasteSpecialStruct."

    self style: self flags.
    oleUIPasteSpecialStruct release.
    oleUIPasteSpecialStruct := nil.
!   
linkFlag
        "Answer whether Paste Link was chosen."

    ^linkFlag

!   
sourceDataObject
        " Answer the source IDataObject interface on the clipboard. "

    ^sourceDataObject
!   
linkTypes: aListOfOleUIPasteFlag
        " Set the list of acceptable link types to <aListOfOleUIPasteFlag>. "

    oleUIPasteSpecialStruct linkTypes: aListOfOleUIPasteFlag.
!   
hMetaPict
        "Answer the content of cached hMetaPict field."

    ^hMetaPict

! 
initialize
        "Private - Initialize oleUIConvertStruct."

    super initialize.
    oleUIPasteSpecialStruct := OLE_OLEUIPASTESPECIAL new.
    self style: PSF_SELECTPASTE | PSF_DISABLEDISPLAYASICON.!  
open
        " Invoke the standard OLE Paste Special dialog."

    ^self open: nil!
fileMenuGroupWidth: anInteger
		" Set the number of items in the container's file menu group. "

	self longAtOffset: 0 put: anInteger.!
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
new
		" Answer a new instance of the receiver. "

	^super new needsFinalization!   
sizeInBytes
         "Private - Answer the default size in bytes."

    ^112!  
dispatchLockContainer: fLock
		" Private - dispatch the IOleContainer::LockContainer function. "

    ^( functionHandlers at: 6 ) evaluateWithArguments: ( Array
		with: fLock )! 
LockContainer: fLock
		" Invoke the IOleContainer::LockContainer function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchLockContainer: fLock )! 
invokeLockContainer: fLock
		"Private - invoke the IOleContainer::LockContainer function for an external caller. "

	" HRESULT LockContainer(
            /* [in] */ BOOL fLock); "

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchLockContainer: fLock.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
dispatchEnumObjects: grfFlags _: resultReference
        " Private - dispatch the IOleContainer::EnumObjects function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
        with: grfFlags
        with: resultReference )! 
EnumObjects: grfFlags _: resultReference
        " Invoke the IOleContainer::EnumObjects function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
		( self dispatchEnumObjects: grfFlags _: resultReference )! 
invokeEnumObjects: grfFlags _: ppenum
        "Private - invoke the IOleContainer::EnumObjects function for an external caller. "

    " HRESULT EnumObjects(
            /* [in] */ DWORD grfFlags,
            /* [out] */ IEnumUnknown **ppenum); "

    | hresult resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    ppenum isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: ppenum.

    resultReference := nil asValueReference.
    hresult := self dispatchEnumObjects: grfFlags _: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppenum put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'IEnumUnknown: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult!
windowMenuGroupWidth: anInteger
		" Set the number of items in the container's window menu group. "

	self longAtOffset: 16 put: anInteger.!   
editPaste
        " Private - Perform the Edit menu Paste operation. "

    self pasteClientSite: self activeSite.
!  
activeSite: aClientSite
        " Private - set the currently selected site in the receiver to <aClientSite>. "

    activeSite notNil
        ifTrue: [ activeSite deactivate ].
    activeSite := aClientSite.
    aClientSite activate.! 
registerStructureName
        " Private - register the host data structure name represented by the receiver. "

    OLEStructure registerStructureName: #OLEMENUGROUPWIDTHS for: self.!
SetTranslateAccelerator: wmsg _: wID
	"Invoke the IOleInPlaceFrame::TranslateAccelerator function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchTranslateAccelerator: wmsg _: wID)!  
SetRemoveMenus: menu
	"Invoke the IOleInPlaceFrame::RemoveMenus function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchRemoveMenus: menu)!   
dispatchEnableModeless: bool
		" Private - dispatch the IOleInPlaceFrame::EnableModeless function. "

	^(functionHandlers at: 14) evaluateWithArguments: (Array with: bool)!   
invokeRemoveMenus: hmenuShared
        " Private - invoke the IOleInPlaceFrame::RemoveMenus function for an external caller. "

	"virtual HRESULT __stdcall RemoveMenus( 
            /* [in] */ HMENU hmenuShared) = 0"

	| hresult menu |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	menu := self menuHandleFromHandle: hmenuShared.
	hresult := self dispatchRemoveMenus: menu.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
dispatchTranslateAccelerator: wmsg _: wID
        " Private - dispatch the IOleInPlaceFrame::TranslateAccelerator function. "

    ^( functionHandlers at: 15 ) evaluateWithArguments: ( Array
        with: wmsg
        with: wID ) !  
SetEnableModeless: bool
	"Invoke the IOleInPlaceFrame::EnableModeless function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchEnableModeless: bool)!  
invokeTranslateAccelerator: lpmsg _: wID
        " Private - invoke the IOleInPlaceFrame::TranslateAccelerator function for an external caller. "

	"virtual HRESULT __stdcall TranslateAccelerator( 
            /* [in] */ LPMSG lpmsg,
            /* [in] */ WORD wID) = 0"

	| hresult wmsg |

	self ifOLETraceEnabled: [ self logCallbackEntry ].

	lpmsg isValid
		ifFalse: [^E_INVALIDARG].
	wmsg := WinMessage atAddress: lpmsg.
	hresult := self dispatchTranslateAccelerator: wmsg _: wID.

	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
dispatchInsertMenus: menu _: widths
		" Private - dispatch the IOleInPlaceFrame::InsertMenus function. "

	^( functionHandlers at: 10 ) evaluateWithArguments: ( Array
		with: menu
		with: widths )!
dispatchRemoveMenus: menu
		" Private - dispatch the IOleInPlaceFrame::RemoveMenus function. "

	^( functionHandlers at: 12 ) evaluateWithArguments: ( Array
		with: menu )!  
invokeSetMenu: hMenuShared _: holemenu _: hwndActiveObject
        " Private - invoke the IOleInPlaceFrame::SetMenus function for an external caller. "

    "virtual /* [input_sync] */ HRESULT __stdcall SetMenu(
            /* [in] */ HMENU hmenuShared,
            /* [in] */ HOLEMENU holemenu,
            /* [in] */ HWND hwndActiveObject) = 0"

    | menu oleMenu window hresult |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    menu := self menuHandleFromHandle: hMenuShared.
    oleMenu := self menuHandleFromHandle: holemenu.
    window := self windowHandleFromHandle: hwndActiveObject.
    hresult := self dispatchSetMenu: menu _: oleMenu _: window.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].

    ^hresult!   
dispatchSetMenu: menu _: olemenu _: hwndActive
		" Private - dispatch the IOleInPlaceFrame::SetMenu function. "

	^( functionHandlers at: 11 ) evaluateWithArguments: ( Array
		with: menu
		with: olemenu
		with: hwndActive )!
InsertMenus: menu _: widths
	"Invoke the IOleInPlaceFrame::InsertMenus function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchInsertMenus: menu _: widths)!  
invokeInsertMenus: hmenuShared _: lpMenuWidths
        " Private - invoke the IOleInPlaceFrame::InsertMenus function for an external caller. "

    "HRESULT InsertMenus(
            /* [in] */ HMENU hmenuShared,
            /* [out][in] */ LPOLEMENUGROUPWIDTHS lpMenuWidths)"

    | hresult menu resultReference |

    self ifOLETraceEnabled: [self logCallbackEntry].

    lpMenuWidths isValid
        ifFalse: [ ^E_INVALIDARG ].
    menu := self menuHandleFromHandle: hmenuShared.
    resultReference := nil asValueReference.
    hresult := self dispatchInsertMenus: menu
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self structureResultAtAddress: lpMenuWidths put: resultReference value ].
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
dispatchSetStatusText: string
		" Private - dispatch the IOleInPlaceFrame::SetStatusText function. "

	^( functionHandlers at: 13 ) evaluateWithArguments: ( Array
		with: string )!  
invokeSetStatusText: pszStatusText
        " Private - invoke the IOleInPlaceFrame::SetStatusText function for an external caller. "

	"virtual /* [input_sync] */ HRESULT __stdcall SetStatusText( 
            /* [in] */ LPCOLESTR pszStatusText) = 0"

	| hresult string |

	self ifOLETraceEnabled: [ self logCallbackEntry ].

	( string := self stringAtAddress: pszStatusText ) isNil
		ifTrue: [ ^E_INVALIDARG ].
	hresult := self dispatchSetStatusText: string.

	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
SetSetStatusText: string
	"Invoke the IOleInPlaceFrame::SetStatusText function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchSetStatusText: string)! 
invokeEnableModeless: aBoolean
        " Private - invoke the IOleInPlaceFrame::EnableModeless function for an external caller. "

	"virtual HRESULT __stdcall EnableModeless( 
            /* [in] */ BOOL fEnable) = 0"

	| hresult |
	self ifOLETraceEnabled: [self logCallbackEntry].
	hresult := self dispatchEnableModeless: aBoolean.
	self ifOLETraceEnabled: [self logCallbackExit: hresult].
	^hresult!   
SetMenu: menu _: olemenu _: hwndActive
	"Invoke the IOleInPlaceFrame::SetMenu function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchSetMenu: menu _: olemenu _: hwndActive)!
invokeSetBorderSpace: pborderwidths
        " Private - invoke the IOleInPlaceUIWindow::SetBorderSpace function for an external caller. "

    "virtual /* [input_sync] */ HRESULT __stdcall SetBorderSpace(
            /* [unique][in] */ LPCBORDERWIDTHS pborderwidths) = 0"

    | hresult widths |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    widths := ( pborderwidths isValid )
        ifTrue:  [ ( WinRectangle atAddress: pborderwidths ) asRectangle ]
        ifFalse: [ nil ].
    hresult := self dispatchSetBorderSpace: widths.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
SetBorderSpace: pborderwidths
	"Invoke the IOleInPlaceUIWindow::SetBorderSpace function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchSetBorderSpace: pborderwidths)!
dispatchSetBorderSpace: pborderwidths
		" Private - dispatch the IOleInPlaceUIWindow::SetBorderSpace function. "

	^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
		with: pborderwidths )!
dispatchRequestBorderSpace: pborderwidths
		" Private - dispatch the IOleInPlaceUIWindow::RequestBorderSpace function. "

	^( functionHandlers at: 7 ) evaluateWithArguments: ( Array 
		with: pborderwidths )!   
SetActiveObject: activeObject _: objectName
	"Invoke the IOleInPlaceUIWindow::SetActiveObject function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchSetActiveObject: activeObject _: objectName)!   
invokeRequestBorderSpace: pborderwidths
        " Private - invoke the IOleInPlaceUIWindow::RequestBorderSpace function for an external caller. "

	"virtual /* [input_sync] */ HRESULT __stdcall RequestBorderSpace( 
            /* [unique][in] */ LPCBORDERWIDTHS pborderwidths) = 0"

	| hresult widths |

	self ifOLETraceEnabled: [ self logCallbackEntry ].

	pborderwidths isValid
		ifFalse: [^E_INVALIDARG].
	widths := WinRectangle atAddress: pborderwidths.
	hresult := self dispatchRequestBorderSpace: widths.

	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!
invokeGetBorder: lprectBorder
        " Private - invoke the IOleInPlaceUIWindow::GetBorder function for an external caller. "

    "/* [input_sync] */ HRESULT GetBorder(
            /* [out] */ LPRECT lprectBorder)"

    | hresult resultReference |

    self ifOLETraceEnabled:  [self logCallbackEntry ].

    lprectBorder isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultStructureAtAddress: lprectBorder
        type: WinRectangle.

    resultReference := nil asValueReference.
    hresult := self dispatchGetBorder: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self structureResultAtAddress: lprectBorder put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult
!
dispatchSetActiveObject: activeObject _: objectName
		" Private - dispatch the IOleInPlaceUIWindow::SetBorderSpace function. "

	^( functionHandlers at: 9 ) evaluateWithArguments: ( Array
		with: activeObject
		with: objectName )!   
dispatchGetBorder: rect
		" Private - dispatch the IOleInPlaceUIWindow::GetBorder function. "

	^( functionHandlers at: 6 ) evaluateWithArguments: ( Array
		with: rect )!
GetBorder: rect
	"Invoke the IOleInPlaceUIWindow::GetBorder function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchGetBorder: rect)! 
invokeSetActiveObject: pActiveObject _: pszObjName
        " Private - invoke the IOleInPlaceUIWindow::SetActiveObject function for an external caller. "

    "virtual HRESULT __stdcall SetActiveObject(
            /* [unique][in] */ IOleInPlaceActiveObject __RPC_FAR *pActiveObject,
            /* [unique][string][in] */ LPCOLESTR pszObjName) = 0"

    | hresult activeObject name |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    name := self stringAtAddress: pszObjName.
    activeObject := self interfaceAtAddress: pActiveObject 
        type: IOleInPlaceActiveObject.
    hresult := self dispatchSetActiveObject: activeObject _: name.

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
RequestBorderSpace: pborderwidths
	"Invoke the IOleInPlaceUIWindow::RequestBorderSpace function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchRequestBorderSpace: pborderwidths)!
invokeDiscardUndoState
        " Private - invoke the IOleInPlaceSite::DiscardUndoState function for an external caller. "

	"virtual HRESULT __stdcall DiscardUndoState( void) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchDiscardUndoState.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
enableClientSiteDropOnlyOn: aClientSitePane for: aContainerCoordinator
		" Enable drag/drop on <aClientSitePane> to support dropping on 
		the pane.  (Do not support dragging an embedded object out of it.)
		Register <aContainerCoordinator> as the handler for the drag/drop events. "

	aClientSitePane
		enableDropOnly;
		when: #dragTargetDrop:
			evaluate: ( Message
				receiver: aContainerCoordinator
				selector: #dragTargetDrop:sitePane:
				arguments: ( Array with: nil  "dragSession" with: aClientSitePane ) );
		yourself.!   
hwndFrame: aWindowHandle
        " Set the container's frame window handle. "

    self handleAtOffset: 8 put: aWindowHandle. !
usesFinalization
		" Private - answer whether instances of the receiver may use
		finalization to ensure release of resources. "

	^true! 
sizeInBytes
         "Private - Answer the default size in bytes."

    ^44
! 
lphWndDialog: anAddress
        " Private - set the address of the dialog handle to <anAddress>. "

    self addressAtOffset: 40 put: anAddress.
    lphWndDialog := anAddress.
!
releaseHandleAddress
        " Private "

    | anAddress |
    ( anAddress := self lphWndDialog ) notNil
        ifTrue: [
            anAddress free.
            self lphWndDialog: nil ].
!   
releaseResources
		" Private - release resources owned by the receiver. "

	self releaseHandleAddress.
	super releaseResources.!  
lphWndDialog
        " Private - answer the address of the dialog handle. "

    lphWndDialog notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 40 ) asInteger = lphWndDialog asInteger ].
    ^lphWndDialog
!  
hWndDialog: hWnd
        " Set the dialog handle to <hWnd>. "

    | anExternalLong anAddress |
    self lphWndDialog notNil
        ifTrue: [ self releaseHandleAddress ].
    anExternalLong := ExternalLong fromInteger: hWnd.
    anAddress := ExternalAddress copyToNonSmalltalkMemory: anExternalLong contents.
    self lphWndDialog:  anAddress.
!   
hTask: hTask
        " Set the handle of the blocking task to <hTask>. "

    self handleAtOffset: 36 put: hTask
!
hTask
        " Answer the handle of the blocking task. "

    ^self handleAtOffset: 36
! 
activeSite
		" Private - answer the currently selected site in the receiver. "

	self implementedBySubclass!   
openContainer
        " Private - open the receiver's container and its sites. "

	self implementedBySubclass.!
OnInPlaceActivate
	"Invoke the IOleInPlaceSite::OnInPlaceActivate function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchOnInPlaceActivate)! 
open
        " Invoke the standard OLE Edit Links dialog."

    ^self open: 'Edit Links'

!  
open: titleString
        " Invoke the standard OLE Edit Links dialog."

    | result |
    [ hLibrary := OLEDialogDLL current ]
        on: Error
        do: [
            MessageBox warning: 'Could not find ', OLEDialogDLL fileName asUppercase, '.
You must have this DLL to invoke the standard OLE Edit Links dialog.'.
            ^self ].
    parent isWindow ifFalse: [
        parent := Notifier findWindow: WindowHandle queryActive.
        oleUIEditLinksStruct hWndOwner: parent asParameter ].
    style notNil
        ifTrue: [ oleUIEditLinksStruct dwFlags: style ].
    titleString notNil
        ifTrue: [ oleUIEditLinksStruct dialogCaption: titleString ].

    result := hLibrary OleUIEditLinks: oleUIEditLinksStruct.
    result = OLEUI_SUCCESS
        ifTrue: [ self checkFlags ].
    self cleanUp.
! 
cleanUp
        "Private - Free oleUIEditLinksStruct."

    self style: self flags.
    oleUIEditLinksStruct release.
    oleUIEditLinksStruct := nil.
!
owner: anOwner
        "Sets the owner of the Dialog box."

    super owner: anOwner.
    owner isWindow
        ifTrue: [ parent := owner ]
        ifFalse: [
            parent := owner mainView.
            parent isWindow ifFalse: [
                parent := Notifier findWindow: WindowHandle queryActive ]].
    oleUIEditLinksStruct hWndOwner: parent asParameter.

!   
flags: dwFlags
        "Set the dialog box creation flags value."

    oleUIEditLinksStruct dwFlags: dwFlags.
    self style: dwFlags.


! 
oleUILinkContainer: anIOleUILinkContainer
        "Set the IOleUILinkContainer interface of the container."

    oleUIEditLinksStruct lpOleUILinkContainer: anIOleUILinkContainer.
!  
flags
        "Answers the dialog box current flags value."

    ^oleUIEditLinksStruct dwFlags

!
initialize
        "Private - Initialize oleUIEditLinksStruct."

    super initialize.
    oleUIEditLinksStruct := OLE_OLEUIEDITLINKS new.
    self style: 0.!   
checkFlags
        "Private - check user action."

    self style: self flags.
!  
dispatchOnInPlaceDeactivate
		" Private - dispatch the IOleInPlaceSite::OnInPlaceDeactivate function. "

	^( functionHandlers at: 12 ) evaluate!   
setLinkUpdateOptionsOnCall: dwLink
        " Set update option of the link identified by <dwLink> to Manual."

    interface SetLinkUpdateOptions: dwLink _: OLEUPDATE_ONCALL! 
getLinkSource: dwLink
    displayName: resultRefDisplayName
    fileName: resultRefLenFileName
    fullLinkType: resultRefFullLinkType
    shortLinkType: resultRefShortLinkType
    sourceAvailableFlag: resultReffSourceAvailable
    isSelectedFlag: resultReffIsSelected
        " Retrieve information about link identified by <dwLink>.
        This function is called during dialog initialization and after
		 returning from the Change Source dialog. "

	interface GetLinkSource: dwLink
    	_: resultRefDisplayName
		_: resultRefLenFileName
    	_: resultRefFullLinkType
    	_: resultRefShortLinkType
		_: resultReffSourceAvailable
		_: resultReffIsSelected!  
cancelLink: dwLink
        " Cancel the link identified by <dwLink>.
        Called when Break Link button is selected from the Links dialog. "

	interface CancelLink: dwLink!   
getLinkSource: dwLink
        " Retrieve information about link identified by <dwLink>. "

	| resultRefDisplayName resultRefLenFileName resultRefFullLinkType
    resultRefShortLinkType resultReffSourceAvailable resultReffIsSelected |

    resultRefDisplayName := nil asValueReference.
    resultRefLenFileName := nil asValueReference.
    resultRefFullLinkType := nil asValueReference.
    resultRefShortLinkType := nil asValueReference.
    resultReffSourceAvailable := nil asValueReference.
    resultReffIsSelected := nil asValueReference.

	interface GetLinkSource: dwLink
    	_: resultRefDisplayName
		_: resultRefLenFileName
    	_: resultRefFullLinkType
    	_: resultRefShortLinkType
		_: resultReffSourceAvailable
		_: resultReffIsSelected.

	^( Array new: 6 )
		at: 1 put: resultRefDisplayName value;
		at: 2 put: resultRefLenFileName value;
		at: 3 put: resultRefFullLinkType value;
		at: 4 put: resultRefShortLinkType value;
		at: 5 put: resultReffSourceAvailable value;
		at: 6 put: resultReffIsSelected value.
!
setLinkUpdateOptions: dwLink updateOption: dwUpdateOpt
        " Set update option of the link identified by <dwLink> to <dwUpdateOpt>. "

	interface SetLinkUpdateOptions: dwLink _: dwUpdateOpt! 
getNextLink: dwLink
        " Answer the next link. If <dwLink> is NULL, then return the first link,
        if it identifies the last link in the container, then answer NULL. "

	^interface GetNextLink: dwLink!   
updateLink: dwLink errorMessage: fErrorMessage errorAction: fErrorAction
        " Update the link identified by <dwLink>.
        Called when Update Link button is selected from the Links dialog. "

	interface UpdateLink: dwLink _: fErrorMessage _: fErrorAction!   
setLinkSource: dwLink 
	displayName: displayName
	fileNameSize: lenFileName
	validateSource: fValidateSource
        " Set the source of the link identified by <dwLink>.
        Store the number of characters successfully parsed in displayName into <resultReference>. "

    | resultReference |
    resultReference := nil asValueReference.
	interface SetLinkSource: dwLink _: displayName _: lenFileName _: resultReference _: fValidateSource.
    ^resultReference value!   
openLinkSource: dwLink
        " Open the source of the link identified by <dwLink>.
        Called when Open Source button is selected from the Links dialog. "

	interface OpenLinkSource: dwLink!  
getLinkUpdateOptions: dwLink
        " Answer the link update options of the link identified by <dwLink>."

    | resultReference |
    resultReference := nil asValueReference.
    interface GetLinkUpdateOptions: dwLink _: resultReference.
    ^resultReference value! 
setLinkUpdateOptionsAlways: dwLink
        " Set update option of the link identified by <dwLink> to Automatic."

    interface SetLinkUpdateOptions: dwLink _: OLEUPDATE_ALWAYS!  
pasteSpecialLinks
        " Private - Answer an list of desired paste link types for the Paste Special dialog.
        Each entry in the list contains a valid registered clipboard format."

    | listOfLinkType |

    listOfLinkType := Array
        with: ( Clipboard registerFormat: 'Link Source' ).
    ^listOfLinkType! 
container
		" Private - answer the receiver's container object. "

	self implementedBySubclass!
sizeInBytes
         "Private - Answer the default size in bytes."
    ^24! 
editUndo
        " Private - Perform the Edit menu Undo operation. "

	self implementedBySubclass.!
oleSetMenuDescriptor: hOleMenu
	hwndFrame: hFrame
	hwndActiveObject: hActiveObject
	oleInPlaceFrame: anIOleInPlaceFrame
	oleInPlaceActiveObject: anIOleInPlaceActiveObject
		" Install or remove dispatching code from the container's frame window. "

    OLEDLL current
        OleSetMenuDescriptor: hOleMenu
        _: hFrame
        _: hActiveObject
        _: anIOleInPlaceFrame
        _: anIOleInPlaceActiveObject.! 
enableModeless: aBoolean
		" Enable or disable a frame's modeless dialog boxes. "

	interface EnableModeless: aBoolean!
insertMenus: compositeMenuHandle menuWidths: menuWidthsInfo
		" Allow the container to insert its menu groups into the composite menu
		that is to be used during an in-place active session. 
		The <compositeMenuHandle> is an empty menu handle into which
		the container's menus should be inserted.  The group width information
		about the inserted menus is stored into the OLEINPLACEFRAMEINFO
		structure <menuWidthsInfo>. "

	interface InsertMenus: compositeMenuHandle _: menuWidthsInfo!  
setStatusText: aString
		" Set the status text to <aString>. "

	| hresult |
	hresult := interface SetStatusText: aString.
	hresult = S_OK    " S_TRUNCATED "
		ifFalse: [ OLEResultNotification hresult: hresult ].!   
enableModelessDialogs
		" Enable a frame's modeless dialog boxes. "

	interface EnableModeless: true!  
removeMenus: compositeMenuHandle 
		" Allow the container to remove its menu elements from the in-place 
		composite menu <compositeMenuHandle>. "

	interface RemoveMenus: compositeMenuHandle!  
disableModelessDialogs
		" Disable a frame's modeless dialog boxes. "

	interface EnableModeless: false!   
translateAccelerator: aHostMessage commandId: commandId
		" Translate accelerator keystrokes intended for the container's frame
		while an object is active in-place. "

	^interface TranslateAccelerator: aHostMessage _: commandId! 
isTranslateAccelerator: aHostMessage commandId: commandId
		" Translate accelerator keystrokes intended for the container's frame
		while an object is active in-place.  Answer whether the keystroke was used. "

	^( interface TranslateAccelerator: aHostMessage _: commandId ) = S_OK!
setMenu: compositeMenuHandle 
	oleMenu: oleMenu
	activeObjectWindow: activeObjectWindow
		" Install the composite menu <compositeMenuHandle> into the window 
		containing the object being activated in place. 
		The <activeObjectWindow> is the handle of the window owned by the
		in-place active object and to which menu messages, commands, and
		accelerators are to be sent. "

	interface SetMenu: compositeMenuHandle _: oleMenu _: activeObjectWindow!  
dispatchOnPosRectChange: rect
		" Private - dispatch the IOleInPlaceSite::OnPosRectChange function. "

	^( functionHandlers at: 15 ) evaluateWithArguments: ( Array
		with: rect )!   
haccel: hAccel
        " Set the container's accelerator table handle. "

    self handleAtOffset: 12 put: hAccel. !   
insertObject
        " Private - Perform the Insert menu Insert Object operation.
        Insert an OLE object at the active site. "

    self insertObjectIntoClientSite: self activeSite.!  
windowPolicyClass
		"Answer the class of window policy for the receiver."

    ^OLEContainerWindowPolicy!  
fileSignature
        " Private - Answer the backing storage file signature. "

	self implementedBySubclass.
!
invokeOnUIActivate
        " Private - invoke the IOleInPlaceSite::OnUIActivate function for an external caller. "

    "virtual HRESULT __stdcall OnUIActivate( void) = 0"

    | hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    hresult := self dispatchOnUIActivate.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
drawShadingBorder: aRectangle width: widthInPixel outside: outBoolean
        " Draw shading border around the OLE object being edited.
        Shade border of width <widthInPixel>. The boolean <outBoolean>
        specifie whether to draw outside (true) or inside (false) the rectangle."

    | hatchBits hatchBitsAddress hBitmap hBrush hBrushOld foreColorOld backColorOld rectangle |
    hatchBits :=  ExternalBuffer new: 16.
    hatchBits
        uLongAtOffset: 0 put: 16r00220011;
        uLongAtOffset: 4 put: 16r00880044;
        uLongAtOffset: 8 put: 16r00220011;
        uLongAtOffset: 12 put: 16r00880044.
    hatchBitsAddress := ExternalAddress copyToNonSmalltalkMemory: hatchBits asParameter.
    hBitmap := Bitmap createBitmap: 8
        height: 8
        planes: 1
        bitCount: 1
        bits: hatchBitsAddress asParameter.
    hatchBitsAddress free.
    hBrush := GDILibrary createPatternBrush: hBitmap.
    hBrushOld := GDILibrary selectObject: self handle with: hBrush.
    foreColorOld := GDILibrary setTextColor: self handle with: Color white asParameter.
    backColorOld := GDILibrary setBkColor: self handle with: Color black asParameter.

    rectangle := outBoolean
        ifTrue: [ aRectangle expandBy: widthInPixel - 1 ]
        ifFalse: [ aRectangle ].

    self patternFill: ( rectangle origin extent: ( rectangle width @ widthInPixel ) )
        rule: 16r00A000C9.  "aRopContants /* DPa */"

    self patternFill: ( rectangle origin extent: ( widthInPixel @ rectangle height ) )
        rule: 16r00A000C9.  "aRopContants /* DPa */"

    self patternFill: ( ( (rectangle right - widthInPixel) @ rectangle origin x ) extent: ( widthInPixel @ rectangle height ) )
        rule: 16r00A000C9.  "aRopContants /* DPa */"

    self patternFill: ( ( rectangle left @ (rectangle bottom - widthInPixel) ) extent: ( rectangle width @ widthInPixel ) )
        rule: 16r00A000C9.  "aRopContants /* DPa */"

    GDILibrary setTextColor: self handle with: foreColorOld asParameter.
    GDILibrary setBkColor: self handle with: backColorOld asParameter.
    GDILibrary selectObject: self handle with: hBrushOld.
    GDILibrary deleteObject: hBrush.
    GDILibrary deleteObject: hBitmap.
!
eraseHandles: aRectangle
        " Erase selection handles around the OLE object being selected. "

    self drawHandles: aRectangle
        size: self defaultHandleSize
        outside: false
        border: true
        invert: false
        erase: true
!
drawFrame: aRectangle
        " Draw a frame border around the rectangle <aRectangle>. "

    | backModeOld hBrush |
    backModeOld := self setBackMode: BackgroundMixTransparent.
    hBrush := self selectStockObject: BlackBrush.
    UserLibrary
        frameRect: self handle
        in: aRectangle asParameter
        brush: hBrush.
    self setBackMode: backModeOld.
!
setBackMode: aMode
        "Set the receiver's background mode used with text,
        hatched brushes, or any pen style that is not a solid line.
        <aMode> can be Opaque or Transparent.
        Answer the the previous mode."

    | previousMode |
    ( previousMode := GDILibrary
        setBkMode:  self handle
        mode: aMode ) = 0
            ifTrue: [ ^self osError ].
    ^previousMode
!   
drawHandles: aRectangle
    size: sizeInPixel
    outside: outBoolean
    border: borderBoolean
    invert: invertBoolean
    erase: eraseBoolean
        " Draw selection handles around the OLE object being selected.
        The size of the handle box is <sizeInPixel>. The booleans
        <outBoolean> specifie whether to draw outside (true) or inside (false) the rectangle;
        <borderBoolean> specifie whether to draw a frame border (true) or not;
        <invertBoolean> specifie whether to invert retangle or not;
        <eraseBoolean> specifie whether to draw (false) or erase (true) the handle."

    | backModeOld rectangle allPoints |
    backModeOld := self setBackMode: BackgroundMixTransparent.
    rectangle := outBoolean
        ifTrue: [ aRectangle expandBy: sizeInPixel - 1 ]
        ifFalse: [ aRectangle ].
    allPoints := ( Array
        with: rectangle leftTop
        with: ( rectangle left @ ( rectangle top + ( rectangle height - sizeInPixel // 2 ) ) )
        with: ( rectangle left @ (rectangle bottom - sizeInPixel) )
        with: ( (rectangle left + (rectangle width - sizeInPixel // 2 ) ) @ rectangle top ) ) , ( Array
        with: ( (rectangle left + (rectangle width - sizeInPixel // 2 ) ) @ ( rectangle bottom - sizeInPixel ) )
        with: ( ( rectangle right - sizeInPixel ) @ rectangle top )
        with: ( (rectangle right - sizeInPixel ) @  ( rectangle top + (rectangle height - sizeInPixel // 2 ) ) )
        with: ( (rectangle right - sizeInPixel ) @  ( rectangle bottom - sizeInPixel ) ) ).
    allPoints do: [ :point |
        self drawHandle: point
            size: sizeInPixel
            invert: invertBoolean
            erase: eraseBoolean ].
    self setBackMode: backModeOld.

    borderBoolean
        ifTrue: [
            eraseBoolean
                ifTrue: [ self eraseFrame: rectangle ]
                ifFalse: [ self drawFrame: rectangle ] ].!  
drawHandles: aRectangle
        " Draw selection handles around the OLE object being selected. "

    self drawHandles: aRectangle
        size: self defaultHandleSize
        outside: false
        border: true
        invert: false
        erase: false
! 
drawHandle: aPoint size: sizeInPixel invert: invertBoolean erase: eraseBoolean
        " Draw a handle at the specified point <aPoint>.
        The size of the handle box is <sizeInPixel>. The boolean
        <invertBoolean> indicates whether to invert retangle or not,
        and <eraseBoolean> indicates whether to draw (false) or erase
        (true) the handle."

    | aRectangle hPenOld hBrushOld |
    aRectangle := Rectangle
        leftTop: ( aPoint x @ aPoint y )
        rightBottom: (aPoint x + sizeInPixel) @ (aPoint y + sizeInPixel).
    invertBoolean
        ifTrue: [
            ( UserLibrary
                invertRect: self handle
                in: aRectangle asParameter )
                    ifFalse: [ ^self osError ].
            ^nil ].
    eraseBoolean
        ifTrue: [
            self backColor: nil.
            hPenOld := self selectStockObject: WhitePen.
            hBrushOld := self selectStockObject: WhiteBrush]
        ifFalse: [
            hPenOld := self selectStockObject: BlackPen.
            hBrushOld := self selectStockObject: BlackBrush ].
    self rectangleFilled: aRectangle.
    self selectObject: hBrushOld.
    self selectObject: hPenOld.
!   
eraseFrame: aRectangle
        " Erase the frame border around the rectangle <aRectangle>. "

    | backModeOld hBrush |
    backModeOld := self setBackMode: BackgroundMixTransparent.
    hBrush := self selectStockObject: WhiteBrush.
    UserLibrary
        frameRect: self handle
        in: aRectangle asParameter
        brush: hBrush.
    self setBackMode: backModeOld.
!
drawFocus: aRectangle
        " Draw a focus border around the rectangle <aRectangle>. "

    UserLibrary
        drawFocusRect: self handle
        rectangle: aRectangle asParameter.! 
showObject: aRectangle isLink: isLinkBoolean
        " Draw the OLE standard show object effect around the OLE object.
         The boolean <isLinkBoolean> indicates whether the object is linked or embedded."

    | hPenOld |
    hPenOld := isLinkBoolean
        ifTrue: [
            self setPenStyle: LineTypeShortDash
                color: Color black
                width: 1 ]
        ifFalse: [
            self selectStockObject: BlackPen ].
    self rectangle: aRectangle.
    self selectObject: hPenOld.
! 
resetAttributes
        "Private - set the attributes of the device context."

    super resetAttributes.
    self setTextAlign: TaTop.!  
drawShading: aRectangle
        " Draw shading on the OLE object being edited.
         Shade the whole rectangle <aRectangle>."

    | hatchBits hatchBitsAddress hBitmap hBrush hBrushOld foreColorOld backColorOld |
    hatchBits :=  ExternalBuffer new: 16.
    hatchBits
        uLongAtOffset: 0 put: 16r00220011;
        uLongAtOffset: 4 put: 16r00880044;
        uLongAtOffset: 8 put: 16r00220011;
        uLongAtOffset: 12 put: 16r00880044.
    hatchBitsAddress := ExternalAddress copyToNonSmalltalkMemory: hatchBits asParameter.
    hBitmap := Bitmap createBitmap: 8
        height: 8
        planes: 1
        bitCount: 1
        bits: hatchBitsAddress asParameter.
    hatchBitsAddress free.
    hBrush := GDILibrary createPatternBrush: hBitmap.
    hBrushOld := GDILibrary selectObject: self handle with: hBrush.
    foreColorOld := GDILibrary setTextColor: self handle with: Color white asParameter.
    backColorOld := GDILibrary setBkColor: self handle with: Color black asParameter.

    self patternFill: aRectangle rule: 16r00A000C9.  "aRopContants /* DPa */"

    GDILibrary setTextColor: self handle with: foreColorOld asParameter.
    GDILibrary setBkColor: self handle with: backColorOld asParameter.
    GDILibrary selectObject: self handle with: hBrushOld.
    GDILibrary deleteObject: hBrush.
    GDILibrary deleteObject: hBitmap.
!   
defaultHandleSize
        " Answer the default handle size. "

    ^7! 
sizeInBytes
         "Private - Answer the default size in bytes."

    ^40
! 
CanInPlaceActivate
	"Invoke the IOleInPlaceSite::CanInPlaceActivate function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchCanInPlaceActivate)!  
setWindowTitle
        " Private - set the window title. "

	self triggerEvent: #titleChanged: with: self windowTitle.
!  
enableClientSiteDragDropOn: aClientSitePane for: aContainerCoordinator
		" Enable drag/drop on <aClientSitePane> to support dropping on 
		the pane and dragging an embedded object out of it.
		Register <aContainerCoordinator> as the handler for the drag/drop events. "

	aClientSitePane
		enableDragDrop;
		enableEmbeddedObjectDrop;
		when: #dragSourceNeedsObject:
			evaluate: ( Message
				receiver: aContainerCoordinator
				selector: #dragSourceNeedsObject:sitePane:
				arguments: ( Array with: nil  "dragSession" with: aClientSitePane ) );
		when: #dragTargetDrop:
			evaluate: ( Message
				receiver: aContainerCoordinator
				selector: #dragTargetDrop:sitePane:
				arguments: ( Array with: nil  "dragSession" with: aClientSitePane ) );
		yourself.!   
copyClientSite: aClientSite
        " Private - copy the object contained in <aClientSite> to the clipboard."

    aClientSite copyObjectToClipboard.

! 
fileMenuGroupWidth
		" Answer the number of items in the container's file menu group. "

	^self longAtOffset: 0!   
GetWindowContext: ppFrame _: ppDoc _: posRect _: clipRect _: frameInfo
	"Invoke the IOleInPlaceSite::GetWindowContext function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult:
		(self dispatchGetWindowContext: ppFrame _: ppDoc _: posRect _: clipRect _: frameInfo)! 
aboutToClose: aWindow
        " Private - the window is about to close. "

	self changesHandled
        ifFalse: [ ^aWindow abortClose ].

	" must be done before window closes to handle IPA site properly "
	self closeContainer.
! 
constructEventsTriggered
        "Private - Construct the set of events triggered by instances
        of the receiver."

    ^super constructEventsTriggered
        add: #titleChanged: ;
        yourself!   
getContentExtent
		" Answer the extent of the content view of the object. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetExtent: DVASPECT_CONTENT _: -1 _: nil _: resultReference.
	^resultReference value!
getExtent: drawAspect targetDevice: aTargetDevice
		" Answer the extent of the DVASPECT view aspect <drawAspect>
		for the target device specified by <aTargetDevice>. "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetExtent: drawAspect 
		_: -1 
		_: aTargetDevice 
		_: resultReference.
	^resultReference value!  
getIconExtent
		" Answer the extent of the icon view of the object "

	| resultReference |
	resultReference := nil asValueReference.
	interface GetExtent: DVASPECT_ICON _: -1 _: nil _: resultReference.
	^resultReference value!  
new: anInteger
        "Answer a new instance of the receiver with
         size anInteger bytes."

	^( super new: anInteger )
		cb: anInteger;
		yourself! 
invokeOnUIDeactivate: bool
        " Private - invoke the IOleInPlaceSite::OnUIDeactivate function for an external caller. "

	"virtual HRESULT __stdcall OnUIDeactivate( 
            /* [in] */ BOOL fUndoable) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchOnUIDeactivate: bool.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!  
dispatchGetWindowContext: ppFrame _: ppDoc _: posRect _: clipRect _: frameInfo
		" Private - dispatch the IOleInPlaceSite::GetWindowContext function. "

	| args |
	args := Array new: 5.
	args at: 1 put: ppFrame.
	args at: 2 put: ppDoc.
	args at: 3 put: posRect.
	args at: 4 put: clipRect.
	args at: 5 put: frameInfo.
	^( functionHandlers at: 9 ) evaluateWithArguments: args!  
activeSite: aClientSitePane
		" Private - set the currently selected site in the receiver to <aClientSitePane>. "

	self implementedBySubclass!
editRestore
        " Private - Perform the Edit menu Restore operation. "

	self implementedBySubclass.!  
createContainerNamed: containerName
		" Private - answer a new container object with its name set to <containerName>. "

	^OLEContainerObject new
		name: containerName;
		yourself! 
SaveObject
		" Invoke the IOleClientSite::SaveObject function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT SaveObject( void); "

   <ole: 3 hresult>
    ^self vtableDispatchFailed!   
GetMoniker: dwAssign _: dwWhichMoniker _: resultReference
        " Invoke the IOleClientSite::GetMoniker function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult  |
    resultValue := IMonikerPointer forReturnValue.
    hresult := self
        invokeGetMoniker: dwAssign
        _: dwWhichMoniker
        _: resultValue asParameter.
    resultReference value: resultValue.
    ^hresult!
invokeGetContainer: ppContainer
		" Private - invoke the IOleClientSite::GetContainer function. "

	" HRESULT GetContainer(
            /* [out] */ IOleContainer **ppContainer); "

	| hresult |
	<ole: 5 structOut hresult>
	hresult := self dispatchFailureReason.
	hresult = E_NOINTERFACE
		ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed! 
invokeGetMoniker: dwAssign _: dwWhichMoniker _: ppmk
		" Private - invoke the IOleClientSite::GetMoniker function. "

	" HRESULT GetMoniker(
            /* [in] */ DWORD dwAssign,
            /* [in] */ DWORD dwWhichMoniker,
            /* [out] */ IMoniker **ppmk); "

   <ole: 4 ulong ulong structOut hresult>
    ^self vtableDispatchFailed!  
GetContainer: resultReference
        " Invoke the IOleClientSite::GetContainer function.
		Raise an exception if an error occurs.  Answer the result code. "

    | resultValue hresult  |
    resultValue := IOleContainerPointer forReturnValue.
	hresult :=  self invokeGetContainer: resultValue asParameter.
	resultReference value: ( hresult =  E_NOINTERFACE
		ifTrue: [ nil ]
		ifFalse: [ resultValue ] ).
    ^hresult! 
OnShowWindow: fShow
		" Invoke the IOleClientSite::OnShowWindow function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnShowWindow(
            /* [in] */ BOOL fShow); "

   <ole: 7 boolean hresult>
    ^self vtableDispatchFailed!
RequestNewObjectLayout
		" Invoke the IOleClientSite::RequestNewObjectLayout function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT RequestNewObjectLayout( void); "

   <ole: 8 hresult>
    ^self vtableDispatchFailed!   
ShowObject
		" Invoke the IOleClientSite::ShowObject function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT ShowObject( void); "

   <ole: 6 hresult>
    ^self vtableDispatchFailed!   
containerMenuGroupWidth: anInteger
		" Set the number of items in the container's container menu group. "

	self longAtOffset: 8 put: anInteger.!  
addFileMenu
        "Private - add the File menu to the menu bar."

	| aMenu |
	aMenu := self class fileMenu.
	aMenu owner: window owner.
	self disableUnsupportedItemsIn: aMenu
		owner: window owner
		mandatorySelectors: #(
			#fileNew #fileOpen #fileSave #fileSaveAs
			#close
			).
	window menuWindow addMenu: aMenu.!   
addInsertMenu
        "Private - add the Insert menu to the menu bar."

    | aMenu |
    aMenu := self class insertMenu.
    aMenu owner: window owner.
    window menuWindow addMenu: aMenu.! 
addApplicationMenus
        "Private - add the menus for the panes of the window
         <aWindow> to the menu bar <aMenuBar>."

    self addViewMenu.
    self addInsertMenu.
	super addApplicationMenus.!
addEditMenu
        "Private - add the Edit menu to the menu bar."

    | aMenu menuOwner |
    aMenu := self class editMenu.
    menuOwner := window owner.
    aMenu owner: menuOwner.
    ( aMenu getMenuItem: 'Object' ) submenu owner: menuOwner.
    window menuWindow addMenu: aMenu.
	self enableDisableEditMenu: aMenu.

!
addViewMenu
        "Private - add the View menu to the menu bar."

    | aMenu |
    aMenu := self class viewMenu.
    aMenu owner: window owner.
    window menuWindow addMenu: aMenu.!   
addStandardLeftMenus
        "Private - add the menus that are to be located
         on the menu bar before any application-specific
         menus (File, Edit, View & Insert)."

    self addFileMenu.
    self addEditMenu.!
disableUnsupportedItemsIn: aMenu owner: owner mandatorySelectors: mandatorySelectors
        " Private - disable any operations in <aMenu> which aren't supported
        by its <owner>, other than those listed as <mandatorySelectors>. "

    | aSelector |
    aMenu items do: [ :aMenuItem |
        aSelector := aMenuItem selector.
        ( ( mandatorySelectors includes: aSelector ) not
        and: [ ( owner respondsTo: aSelector ) not ] )
            ifTrue: [ aMenu disableItem: aSelector ] ].! 
enableDisableEditMenu: aMenu
		" Private - initialize the enablement state of operations in the Edit menu. "

    aMenu owner enableDisableEditMenu: aMenu.
    window menuWindow
        when: #aboutToDisplayMenu
        send: #enableDisableEditMenu: to: aMenu owner with: aMenu.

! 
getContainerMoniker
		" Answer the moniker of the receiver's container (if any). "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: self defaultMonikerAssignment
		_: OLEWHICHMK_CONTAINER 
		_: resultReference.
    ^resultReference value!
getObjectMoniker
		" Answer the absolute moniker of the object. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: self defaultMonikerAssignment
		_: OLEWHICHMK_OBJFULL 
		_: resultReference.
    ^resultReference value!   
saveObject
		" Save the object attached to this client site.  IOleClientSite::SaveObject 
		is synchronous; by the time it returns, the save will be completed. 
		This message is sent by objects when the user chooses the File Update
		or Exit commands."

	interface SaveObject!   
showObject
		" Request the container to position the object so it is visible to the user.
		This method ensures that the container itself is visible and not minimized. "

        "It is possible that the container is not able to position the object so it is either partially or
        completely visible at the present time. Therefore, when ShowObject returns, the object
        cannot rely on its degree of visibility. The intent of ShowObject is to respond to the request
        for visibility whenever possible."

	interface ShowObject!   
getMoniker: dwAssign whichMoniker: whichMoniker
        " Answer a moniker which can be used to connect to the object.
        The OLEGETMONIKER value in <dwAssign> determines how the moniker is
        assigned. The OLEWHICHMK value in <whichMoniker> specifies the
        requested form of the moniker. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: dwAssign _: whichMoniker _: resultReference.
    ^resultReference value! 
getObjectRelativeMoniker
		" Answer the relative moniker of the object within its container. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: self defaultMonikerAssignment
		_: OLEWHICHMK_OBJREL 
		_: resultReference.
    ^resultReference value!   
onShowWindow: aBoolean
		" Notify the container when an object's window has become visible or invisible,
		as indicated by <aBoolean>.  This message is sent when an object is open 
		in its own window (as opposed to being in-place active). "

	interface OnShowWindow: aBoolean!
getContainer
		" Answer the IOleContainer interface of the receiver's container. "

    | resultReference |
    resultReference := IOleContainer new asValueReference.
    interface GetContainer: resultReference.
    ^resultReference value! 
defaultMonikerAssignment
		" Private - Answer the default OLEGETMONIKER value used to obtaining monikers. "

	^OLEGETMONIKER_ONLYIFTHERE!  
onObjectWindowVisible
        " Notify the container that the object's windows became visible. "

	interface OnShowWindow: true.!  
requestNewObjectLayout
        " Request new layout information for a compound document object
		which needs more or less room. "

        "OLE2 v2.01: There is no standard mechanism by which a container would engage in a
        negotiation process to determine how much room the object would like. When such a
        mechanism is defined, responding to it will be optional on containers' part."

	interface RequestNewObjectLayout! 
onObjectWindowNotVisible
        " Notify the container that the object's windows are no longer visible. "

	interface OnShowWindow: false.!   
enableDisableEditOperationsIn: aMenu
        " Private - enable/disable the standard edit operations in the Edit menu <aMenu>. "

    | itemList |
    itemList := #( #editPaste #editPasteSpecial ).
    self activeSite canPasteFromClipboard
        ifTrue: [ self enableItems: itemList in: aMenu ]
        ifFalse: [ self disableItems: itemList in: aMenu ].
    itemList := #( #editCut #editCopy #editClear ).
    self activeSite notEmpty
        ifTrue: [ self enableItems: itemList in: aMenu ]
        ifFalse: [ self disableItems: itemList in: aMenu ].
!  
fileName
        " Answer the receiver's compound document file name."

    ^fileName! 
fileName: aFileName
        " Set the receiver's compound document file name to <aFileName>."

    fileName := aFileName.
    self setWindowTitle.
! 
enableClientSiteDragOnlyOn: aClientSitePane for: aContainerCoordinator
		" Enable drag/drop on <aClientSitePane> to support dragging an 
		embedded object out of it.  (Do not support dropping on the pane.)
		Register <aContainerCoordinator> as the handler for the drag/drop events. "

	aClientSitePane
		enableDragOnly;
		enableEmbeddedObjectDrop;
		when: #dragSourceNeedsObject:
			evaluate: ( Message
				receiver: aContainerCoordinator
				selector: #dragSourceNeedsObject:sitePane:
				arguments: ( Array with: nil  "dragSession" with: aClientSitePane ) );
		yourself.!
newContainerFile
        " Private - Create a new temporary container storage file. "

    [ self container newDocumentFile ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Container Storage Create Problem' ].
!  
editMenuGroupWidth
		" Answer the number of items in the objects's edit menu group. "

	^self longAtOffset: 4! 
containerName
        " Answer the name of the receiver's container. "

    ^'OLE Container'
!
invokeOnInPlaceActivate
        " Private - invoke the IOleInPlaceSite::OnInPlaceActivate function for an external caller. "

    "virtual HRESULT __stdcall OnInPlaceActivate( void) = 0"

    | hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    hresult := self dispatchOnInPlaceActivate.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!   
invokeInitCache: pDataObject
		" Private - invoke the IOleCache::InitCache function. "

	" HRESULT InitCache(
            /* [unique][in] */ IDataObject *pDataObject); "

   <ole: 6 handle hresult>
    ^self vtableDispatchFailed!  
EnumCache: resultReference
		" Invoke the IOleCache::EnumCache function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := IEnumPointer forReturnValue: IID_IEnumSTATDATA.
	hresult := self invokeEnumCache: resultValue asParameter.
	resultValue isValid  " NULL returned if there are currently no connections "
		ifTrue: [ resultReference value: resultValue ].
	^hresult! 
invokeEnumCache: ppenumSTATDATA
		" Private - invoke the IOleCache::EnumCache function. "

	" HRESULT EnumCache(
            /* [out] */ IEnumSTATDATA **ppenumSTATDATA); "

   <ole: 5 structOut hresult>
    ^self vtableDispatchFailed! 
SetData: pformatetc _: pmedium _: fRelease
		" Invoke the IOleCache::SetData function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT SetData(
            /* [unique][in] */ FORMATETC *pformatetc,
            /* [unique][in] */ STGMEDIUM *pmedium,
            /* [in] */ BOOL fRelease); "

   <ole: 7 structIn structIn boolean hresult>
    ^self vtableDispatchFailed!
InitCache: anIDataObject
		" Invoke the IOleCache::InitCache function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeInitCache: anIDataObject asParameter!
Cache: aFormatEtc _: adviseFlags _: resultReference
		" Invoke the IOleCache::Cache function.
		Raise an exception if an error occurs.  Answer the result code. "

	| resultValue hresult |
	resultValue := ExternalLong new.
	hresult := self invokeCache: aFormatEtc 
		_: adviseFlags
		 _: resultValue.
	resultReference value: resultValue asUnsignedInteger.
	^hresult
! 
Uncache: connectionToken
		" Invoke the IOleCache::Uncache function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT Uncache(
            /* [in] */ DWORD dwConnection); "

   <ole: 4 ulong hresult>
    ^self vtableDispatchFailed!
invokeCache: pformatetc _: advf _: pdwConnection
		" Private - invoke the IOleCache::Cache function. "

	" HRESULT Cache(
            /* [unique][in] */ FORMATETC *pformatetc,
            /* [in] */ DWORD advf,
            /* [out] */ DWORD *pdwConnection); "

   <ole: 3 structIn ulong structOut hresult>
    ^self vtableDispatchFailed!
helpMenuGroupWidth
		" Answer the number of items in the objects's help menu group. "

	^self longAtOffset: 20!
openClientSite: aClientSite
		" Private - open the object in <aClientSite>. "

    [ aClientSite activateObjectVerbOpen ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Open Object Problem' ].! 
dispatchSetLinkSource: dwLink _: displayName _: lenFileName _: resultReference _: fValidateSource
        " Private - dispatch the IOleUILinkContainer::SetLinkSource function. "

    ^( functionHandlers at: 7 ) evaluateWithArguments: ( Array
        with: dwLink
        with: displayName
        with: lenFileName
        with: resultReference ), ( Array
        with: fValidateSource )!  
invokeCancelLink: dwLink
        " Private - invoke the IOleUILinkContainet::CancelLink function for an external caller. "

    " HRESULT CancelLink(
                /* [in] */ DWORD dwLink) ;"

    | hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    hresult := self dispatchCancelLink: dwLink.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
SetLinkUpdateOptions: dwLink _: dwUpdateOpt
        " Invoke the IOleUILinkContainer::SetLinkUpdateOptions function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchSetLinkUpdateOptions: dwLink _: dwUpdateOpt )!
dispatchCancelLink: dwLink
        " Private - dispatch the IOleUILinkContainer::CancelLink function. "

    ^( functionHandlers at: 11 ) evaluateWithArguments: ( Array
        with: dwLink )!  
dispatchUpdateLink: dwLink _: fErrorMessage _: fErrorAction
        " Private - dispatch the IOleUILinkContainer::UpdateLink function. "

    ^( functionHandlers at: 10 ) evaluateWithArguments: ( Array
        with: dwLink
        with: fErrorMessage
        with: fErrorAction )!
invokeGetLinkUpdateOptions: dwLink _: lpdwUpdateOpt
        " Private - invoke the IOleUILinkContainer::GetLinkUpdateOptions function for an external caller. "

    " HRESULT GetLinkUpdateOptions(
                /* [in] */ DWORD dwLink,
                /* [out] */ DWORD * lpdwUpdateOpt);"

    | hresult resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    lpdwUpdateOpt isValid
        ifFalse: [ ^E_INVALIDARG ].
    self clearResultValueAtAddress: lpdwUpdateOpt.

    resultReference := nil asValueReference.
    hresult := self dispatchGetLinkUpdateOptions: dwLink
        _: resultReference.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: lpdwUpdateOpt put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
GetLinkSource: dwLink
    _: resultRefDisplayName
    _: resultRefLenFileName
    _: resultRefFullLinkType
    _: resultRefShortLinkType
    _: resultReffSourceAvailable
    _: resultReffIsSelected
        " Invoke the IOleUILinkContainer::GetLinkSource function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchGetLinkSource: dwLink
            _: resultRefDisplayName
            _: resultRefLenFileName
            _: resultRefFullLinkType
            _: resultRefShortLinkType
            _: resultReffSourceAvailable
            _: resultReffIsSelected )!   
SetLinkSource: dwLink _: displayName _: lenFileName _: resultReference _: fValidateSource
        " Invoke the IOleUILinkContainer::SetLinkSource function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchSetLinkSource: dwLink
            _: displayName
            _: lenFileName
            _: resultReference
            _: fValidateSource )!   
invokeSetLinkUpdateOptions: dwLink _: dwUpdateOpt
        " Private - invoke the IOleUILinkContainet::SetLinkUpdateOptions function for an external caller. "

    " HRESULT SetLinkUpdateOptions(
            /* [in] */ DWORD dwLink,
            /* [in] */ DWORD dwUpdateOpt); "

    | hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    hresult := self dispatchSetLinkUpdateOptions: dwLink _: dwUpdateOpt.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult! 
dispatchGetLinkSource: dwLink
    _: resultRefDisplayName
    _: resultRefLenFileName
    _: resultRefFullLinkType
    _: resultRefShortLinkType
    _: resultReffSourceAvailable
    _: resultReffIsSelected
        " Private - dispatch the IOleUILinkContainer::GetLinkSource function. "

    ^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
        with: dwLink
        with: resultRefDisplayName
        with: resultRefLenFileName
        with: resultRefFullLinkType ), ( Array
        with: resultRefShortLinkType
        with: resultReffSourceAvailable
        with: resultReffIsSelected )!
CancelLink: dwLink
        " Invoke the IOleUILinkContainer::CancelLink function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchCancelLink: dwLink )!
GetNextLink: dwLink
        " Invoke the IOleUILinkContainet::GetNextLink function.
        Raise an exception if an error occurs.  Answer the result value. "

    ^self dispatchGetNextLink: dwLink!
dispatchGetLinkUpdateOptions: dwLink _: resultReference
        " Private - dispatch the IOleUILinkContainer::GetLinkUpdateOptions function. "

    ^( functionHandlers at: 6 ) evaluateWithArguments: ( Array
        with: dwLink
        with: resultReference )! 
dispatchSetLinkUpdateOptions: dwLink _: dwUpdateOpt
        " Private - dispatch the IOleUILinkContainer::SetLinkUpdateOptions function. "

    ^( functionHandlers at: 5 ) evaluateWithArguments: ( Array
        with: dwLink
        with: dwUpdateOpt )! 
UpdateLink: dwLink _: fErrorMessage _: fErrorAction
        " Invoke the IOleUILinkContainer::UpdateLink function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchUpdateLink: dwLink _: fErrorMessage _: fErrorAction )!  
invokeUpdateLink: dwLink _: fErrorMessage _: fErrorAction
        " Private - invoke the IOleUILinkContainet::UpdateLink function for an external caller. "

    " HRESULT UpdateLink(
                /* [in] */ DWORD dwLink,
                /* [in] */ BOOL fErrorMessage,
                /* [in] */ BOOL fErrorAction) ;"

    | hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    hresult := self dispatchUpdateLink: dwLink _: fErrorMessage _: fErrorAction.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult! 
OpenLinkSource: dwLink
        " Invoke the IOleUILinkContainer::OpenLinkSource function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchOpenLinkSource: dwLink )!
invokeSetLinkSource: dwLink _: lpszDisplayName _: lenFileName _: pchEaten _: fValidateSource
        " Private - invoke the IOleUILinkContainer::SetLinkSource function for an external caller. "

    " HRESULT SetLinkSource(
                /* [in] */ DWORD dwLink,
                /* [in] */ LPWSTR lpszDisplayName,
                /* [in] */ ULONG lenFileName,
                /* [out] */ ULONG FAR* pchEaten,
                /* [in] */ BOOL fValidateSource) ;"

    | hresult displayName resultReference |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    pchEaten isValid
        ifFalse: [ ^E_INVALIDARG ].
    lpszDisplayName isValid
        ifTrue: [
            displayName := OLEDialogDLL useUnicode
                ifTrue: [ self stringAtAddress: lpszDisplayName ]
                ifFalse: [ String fromAddress: lpszDisplayName ] ].
    self clearResultValueAtAddress: pchEaten.

    resultReference := nil asValueReference.
    hresult := self dispatchSetLinkSource: dwLink
            _: displayName
            _: lenFileName
            _: resultReference
            _: fValidateSource.
    ( HRESULT succeeded: hresult )
        ifTrue: [ self uLongResultAtAddress: pchEaten put: resultReference value ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult! 
dispatchGetNextLink: dwLink
        " Private - dispatch the IOleUILinkContainet::GetNextLink function. "

    ^( functionHandlers at: 4 ) evaluateWithArguments: ( Array
        with: dwLink )! 
invokeGetNextLink: dwLink
        " Private - invoke the IOleUILinkContainet::GetNextLink function for an external caller. "

    " DWORD GetNextLink (
            /* [in] */ DWORD dwLink); "

    | resultLinkIdentifier |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    resultLinkIdentifier := self dispatchGetNextLink: dwLink.
    self ifOLETraceEnabled: [ self logReturnValue: 'Link ID: ', resultLinkIdentifier printString ].
    ^resultLinkIdentifier!   
invokeGetLinkSource: dwLink
    _: lplpszDisplayName
    _: lplenFileName
    _: lplpszFullLinkType
    _: lplpszShortLinkType
    _: lpfSourceAvailable
    _: lpfIsSelected
        " Private - invoke the IOleUILinkContainer::GetLinkSource function for an external caller. "

    " HRESULT GetLinkSource(
                /* [in] */ DWORD dwLink,
                /* [out] */ LPWSTR FAR* lplpszDisplayName,
                /* [out] */ ULONG FAR* lplenFileName,
                /* [out] */ LPWSTR FAR* lplpszFullLinkType,
                /* [out] */ LPWSTR FAR* lplpszShortLinkType,
                /* [out] */ BOOL FAR* lpfSourceAvailable,
                /* [out] */ BOOL FAR* lpfIsSelected) ;"

    | hresult resultRefDisplayName resultRefLenFileName resultRefFullLinkType
    resultRefShortLinkType resultReffSourceAvailable resultReffIsSelected |

    self ifOLETraceEnabled: [ self logCallbackEntry ].

    "Note: lpfIsSelected argument is not being validated here as it is allowed to be NULL in some cases. "
    ( lplpszDisplayName isValid and: [ lplenFileName isValid
        and: [ lplpszFullLinkType isValid and: [ lplpszShortLinkType isValid
        and: [ lpfSourceAvailable isValid "and: [ lpfIsSelected isValid ]"]]]] )
            ifFalse: [ ^E_INVALIDARG ].

    self clearResultValueAtAddress: lplpszDisplayName.
    self clearResultValueAtAddress: lplenFileName.
    self clearResultValueAtAddress: lplpszFullLinkType.
    self clearResultValueAtAddress: lplpszShortLinkType.
    self clearResultValueAtAddress: lpfSourceAvailable.
    lpfIsSelected isValid
        ifTrue: [ self clearResultValueAtAddress: lpfIsSelected ].

    resultRefDisplayName := nil asValueReference.
    resultRefLenFileName := nil asValueReference.
    resultRefFullLinkType := nil asValueReference.
    resultRefShortLinkType := nil asValueReference.
    resultReffSourceAvailable := nil asValueReference.
    resultReffIsSelected := nil asValueReference.
    hresult := self dispatchGetLinkSource: dwLink
            _: resultRefDisplayName
            _: resultRefLenFileName
            _: resultRefFullLinkType
            _: resultRefShortLinkType
            _: resultReffSourceAvailable
            _: resultReffIsSelected.

    ( HRESULT succeeded: hresult )
        ifTrue: [
            self addressResultAtAddress: lplpszDisplayName
                put: ( OLEMemoryAddress copyToNonSmalltalkMemory: resultRefDisplayName value ).   "ASCII string"
"                put: ( UnicodeStringBuffer newExternalBufferFromString: resultRefDisplayName value ) contents."
            self uLongResultAtAddress: lplenFileName put: resultRefLenFileName value.
            self addressResultAtAddress: lplpszFullLinkType
                put: ( OLEMemoryAddress copyToNonSmalltalkMemory: resultRefFullLinkType value ).   "ASCII string"
"                put: ( UnicodeStringBuffer newExternalBufferFromString: resultRefFullLinkType value ) contents."
            self addressResultAtAddress: lplpszShortLinkType
                put: ( OLEMemoryAddress copyToNonSmalltalkMemory: resultRefShortLinkType value ).   "ASCII string"
"                put: ( UnicodeStringBuffer newExternalBufferFromString: resultRefShortLinkType value ) contents."
            self booleanResultAtAddress: lpfSourceAvailable put: resultReffSourceAvailable value.
             lpfIsSelected isValid
                 ifTrue: [ self booleanResultAtAddress: lpfIsSelected put: resultReffIsSelected value]  ].

    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!
GetLinkUpdateOptions: dwLink _: resultReference
        " Invoke the IOleUILinkContainer::GetLinkUpdateOptions function.
        Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult:
        ( self dispatchGetLinkUpdateOptions: dwLink _: resultReference )!
invokeOpenLinkSource: dwLink
        " Private - invoke the IOleUILinkContainet::OpenLinkSource function for an external caller. "

    " HRESULT OpenLinkSource(
                /* [in] */ DWORD dwLink) ;"

    | hresult |
    self ifOLETraceEnabled: [ self logCallbackEntry ].
    hresult := self dispatchOpenLinkSource: dwLink.
    self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
    ^hresult!  
dispatchOpenLinkSource: dwLink
        " Private - dispatch the IOleUILinkContainer::OpenLinkSource function. "

    ^( functionHandlers at: 9 ) evaluateWithArguments: ( Array
        with: dwLink )!   
insertObjectIntoClientSite: aClientSite
        " Private - allow the user to invoke the Insert object dialog
        to insert an embedded or linked object into <aClientSite>. "

	| io |
	[
	io := OLEInsertObjectDialog new open.
	( io clsid isNil and: [ io fileName isNil ] )
		ifTrue: [ ^self ].

	CursorManager execute changeFor: [ 
        aClientSite aspect:( ( io style & IOF_CHECKDISPLAYASICON > 0 )
            ifTrue: [ DVASPECT_ICON ]
            ifFalse: [ DVASPECT_CONTENT ] ).
        ( io style & IOF_SELECTCREATENEW > 0 )
            ifTrue: [ aClientSite insertEmbeddedObject: io clsid hMetaPict: io hMetaPict ]
            ifFalse: [
                ( io style & IOF_SELECTCREATEFROMFILE > 0 )
                    ifTrue: [
                        ( io style & IOF_CHECKLINK > 0 )
                            ifTrue: [ aClientSite insertLinkedFileObject: io fileName hMetaPict: io hMetaPict  ]
                            ifFalse: [ aClientSite insertEmbeddedFileObject: io fileName hMetaPict: io hMetaPict ] ] ].
		].
	self releaseMetaPict: io hMetaPict.
	]
        on: OLEError
        do: [ :ex |
            aClientSite deleteContent.
            self displayWarning: ex description titled: 'Insert Object Problem' ].!   
rectangleInPixelsToHimetric: aRectangle
        " Convert <aRectangle> in device coordinate system to logical HiMetric units.
        Answer rectangle in logical HiMetric."

    ^self rectangleInPixelsToHimetric: aRectangle
        deviceContext: Display deviceContext!
oleStdSwitchDisplayAspect: anOleObject
    currentAspect: oldAspect
    newAspect: newAspect
    hMetaPict: hMetaPict
    deleteOldAspect: deleteOldAspectBoolean
    setupViewAdvise: setupViewAdviseBoolean
    adviseSink: anIAdviseSink
    mustUpdate: resultReference

        " Switch the currently cached display aspect between DVASPECT_ICON and DVASPECT_CONTENT.
        When setting up icon aspect, any currently cached content cache is discarded and any advise
        connections for content aspect are broken."

    | oleCache anIViewObject connection adviseFlags aFormatEtc aStgMedium cacheConnections |

    resultReference value: false.
    oleCache := anOleObject queryInterface: IID_IOleCache.
    oleCache isNil
        ifTrue: [ ^E_INVALIDARG ].

    aFormatEtc := ( OLEStructure classForStructureNamed: #FORMATETC )
        format: 0
        medium: TYMED_NULL.
    aFormatEtc dwAspect: newAspect.

    adviseFlags := ( newAspect == DVASPECT_ICON and: [ hMetaPict notNil ] )
        ifTrue: [ ADVF_NODATA ]
        ifFalse: [ ADVF_PRIMEFIRST ].

    connection := oleCache cache: aFormatEtc adviseFlags: adviseFlags.

    ( newAspect == DVASPECT_ICON and: [ hMetaPict notNil ] )
        ifTrue: [
            aFormatEtc := ( OLEStructure classForStructureNamed: #FORMATETC )
                formatNamed: 'Metafile'.
            aFormatEtc dwAspect: newAspect.

            aStgMedium := ( OLEStructure createStructureNamed: #STGMEDIUM )
                tymed: TYMED_MFPICT;
                hGlobal: hMetaPict;
                pUnkForRelease: nil;
                yourself.

            oleCache setData: aFormatEtc
                storageMedium: aStgMedium
                release: false ]
        ifFalse: [ resultReference value: true ].

    setupViewAdviseBoolean ifTrue: [
            anIViewObject := anOleObject queryInterface: IID_IViewObject.
            anIViewObject registerAdviseSink: anIAdviseSink
                aspects: newAspect
               adviseFlags: 0.
            anIViewObject release ].

    deleteOldAspectBoolean ifTrue: [
        cacheConnections := oleCache cacheConnections.
        cacheConnections do: [ :statData |
            ( statData formatEtc dwAspect = oldAspect )
                ifTrue: [ oleCache uncache: statData dwConnection ] ].
        cacheConnections do: [ :statData | statData release ] ].

    oleCache release.
    ^S_OK!
pointInPixelsToHimetric: aPoint deviceContext: hDC
        " Convert <aPoint> in device coordinate system to logical HiMetric units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used.  The conversion formula is as follows:
        DistanceInHiMetric = (HiMetricsPerInch * DistanceInPixels) / PixelsPerLogicalInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsXPerLogicalInch pixelsYPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].
    pixelsXPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsx.
    pixelsYPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsy.
    ^Point new
       x: ( aPoint x * 2540 ) // pixelsXPerLogicalInch;
       y: ( aPoint y * 2540 ) // pixelsYPerLogicalInch;
       yourself.
!  
oleStdMarkPasteEntryList: anIDataObject pasteEntries: listOfPasteEntry
        " Mark each entry in the PasteEntryList <listOfPasteEntry> if its format is available from
        the source IDataObject <anIDataObject>. The dwScratchSpace field of each PasteEntry
        is set to TRUE if available, else FALSE. "

    | cf cfEmbeddedObject cfEmbedSource cfFileName cfLinkSource listOfFormatEtc |
    cfEmbeddedObject := Clipboard registerFormat: 'Embedded Object'.
    cfEmbedSource := Clipboard registerFormat: 'Embedd Source'.
    cfFileName := Clipboard registerFormat: 'FileName'.
    cfLinkSource := Clipboard registerFormat: 'Link Source'.

    listOfPasteEntry do: [ :pe |
        pe dwScratchSpace: false asParameter .
        cf := pe fmtetc cfFormat.
        cf = 0
            ifTrue: [ pe dwScratchSpace: true asParameter ]
            ifFalse: [
                ( cf = cfEmbeddedObject
                or: [ cf = cfEmbedSource
                or: [ cf = cfFileName ] ] )
                    ifTrue: [
                        anIDataObject canCreateEmbeddedObject
                            ifTrue: [ pe dwScratchSpace: true asParameter ] ]
                    ifFalse: [
                        cf = cfLinkSource
                            ifTrue: [
                                anIDataObject canCreateLinkedObject
                                    ifTrue: [ pe dwScratchSpace: true asParameter ] ] ] ].
    ].

    listOfFormatEtc := anIDataObject getDataFormats.
    ( listOfFormatEtc isNil or: [ listOfFormatEtc size = 0 ] )
        ifTrue: [ ^self ].  "unable to get format enumerator"

    listOfFormatEtc do: [ :fe |
        listOfPasteEntry do: [ :pe |
            ( pe dwScratchSpace not and: [ fe contents = pe fmtetc contents ] )
                ifTrue: [ pe dwScratchSpace: true asParameter ] ].
    ].!  
oleStdDoConvert: anIStorage clsid: clsidNew
        " Convert the object in the specified storage <anIStorage> to a class
        specified by <clsidNew>. "

    | clsidOld formatAndUserTypeOld formatOld userTypeOld userTypeNew |

    clsidOld := anIStorage readCLSID.
    CLSID_NULL = clsidOld
        ifTrue: [ ^self ].

    formatAndUserTypeOld := anIStorage readClipboardFormatAndUserType.
    formatOld := formatAndUserTypeOld at: 1.
    userTypeOld := formatAndUserTypeOld at: 2.
    userTypeNew := OLERegistryInterface getUserTypeFull: clsidNew.
    [
    anIStorage
        writeCLSID: clsidNew;
        writeClipboardFormat: formatOld userType: userTypeNew;
        setConvertStg.
    ] on: OLEError
        do: [ :ex |
            anIStorage
                writeCLSID: clsidOld;
                writeClipboardFormat: formatOld userType: userTypeOld.
            ex pass ].!  
oleStdGetPriorityClipboardFormat: anIDataObject
    priorityList: listOfPasteEntry
        " Retrieve the first clipboard format in a list for which data exists in the  source IDataObject. 
        Answer the index of the first acceptable match in the priority list, else answer -1 if no match is found. "

    | pe |
    "Mark all entries that the Source provides "
    self oleStdMarkPasteEntryList: anIDataObject pasteEntries: listOfPasteEntry.

    1 to: listOfPasteEntry size do: [ :i |
        pe := listOfPasteEntry at: i.
        ( pe dwFlags ~= OLEUIPASTE_PASTEONLY
        and: [ (pe dwFlags bitAnd: OLEUIPASTE_PASTE) = 0 ] )
            ifFalse: [
                pe dwScratchSpace > 0
                    ifTrue: [ ^i ] ] ].
    ^-1! 
widthInPixelsToHimetric: width deviceContext: hDC
        " Convert <width> in device coordinate system to logical HiMetric units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used.  The conversion formula is as follows:
        DistanceInHiMetric = (HiMetricsPerInch * DistanceInPixels) / PixelsPerLogicalInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].

    pixelsPerLogicalInch := GDILibrary
        getDeviceCaps: hdc
        index: Logpixelsx.

    ^( width * 2540 ) // pixelsPerLogicalInch.!   
heightInHimetricToPixels: height deviceContext: hDC
        " Convert <height> in logical HiMetric to device coordinate system units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used. The conversion formula is as follows:
        DistanceInPixels := (DistanceInHiMetric * PixelsPerLogicalInch) / HiMetricsPerInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].

    pixelsPerLogicalInch := GDILibrary
        getDeviceCaps: hdc
        index: Logpixelsy.

    ^( height * pixelsPerLogicalInch ) // 2540.
! 
rectangleInHimetricToPixels: aRectangle deviceContext: hDC
        " Convert <aRectangle> in logical HiMetric to device coordinate system units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used.  The conversion formula is as follows:
        DistanceInPixels := (DistanceInHiMetric * PixelsPerLogicalInch) / HiMetricsPerInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsXPerLogicalInch pixelsYPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].
    pixelsXPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsx.
    pixelsYPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsy.
    ^Rectangle
       leftBottom: 0 @ 0
       rightTop: ( aRectangle extent * ( pixelsXPerLogicalInch @ pixelsYPerLogicalInch ) ) // 2540.
!  
pointInPixelsToHimetric: aPoint
        " Convert <aPoint> in device coordinate system to logical HiMetric units.
        Answer a point in logical HiMetric."

    ^self pointInPixelsToHimetric: aPoint
        deviceContext: Display deviceContext
!
pointInHimetricToPixels: aPoint
        " Convert <aPoint> in logical HiMetric to device coordinate system units.
        Answer point in pixels."

    ^self pointInHimetricToPixels: aPoint
        deviceContext: Display deviceContext
!
pointInHimetricToPixels: aPoint deviceContext: hDC
        " Convert <aPoint> in logical HiMetric to device coordinate system units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used.  The conversion formula is as follows:
        DistanceInPixels := (DistanceInHiMetric * PixelsPerLogicalInch) / HiMetricsPerInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsXPerLogicalInch pixelsYPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].
    pixelsXPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsx.
    pixelsYPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsy.
    ^Point new
       x: ( aPoint x * pixelsXPerLogicalInch ) // 2540;
       y: ( aPoint y * pixelsYPerLogicalInch ) // 2540;
       yourself.
! 
rectangleInHimetricToPixels: aRectangle
        " Convert <aRectangle> in logical HiMetric to device coordinate system units.
        Answer a rectangle in pixels."

    ^self rectangleInHimetricToPixels: aRectangle
        deviceContext: Display deviceContext
!  
widthInHimetricToPixels: width
        " Convert <width> in  logical HiMetric to screen coordinate system units.
        Answer width in pixels."

    ^self widthInHimetricToPixels: width
        deviceContext: Display deviceContext!
heightInPixelsToHimetric: height
        " Convert <height> in screen coordinate system to logical HiMetric units.
        Answer height in logical HiMetric."

    ^self heightInPixelsToHimetric: height
        deviceContext: Display deviceContext! 
rectangleInPixelsToHimetric: aRectangle deviceContext: hDC
        " Convert <aRectangle> in device coordinate system to logical HiMetric units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used.  The conversion formula is as follows:
        DistanceInHiMetric = (HiMetricsPerInch * DistanceInPixels) / PixelsPerLogicalInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsXPerLogicalInch pixelsYPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].
    pixelsXPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsx.
    pixelsYPerLogicalInch := GDILibrary getDeviceCaps: hdc index: Logpixelsy.
    ^Rectangle
       leftBottom: 0 @ 0
       rightTop: ( aRectangle extent * 2540 ) // ( pixelsXPerLogicalInch @ pixelsYPerLogicalInch ).
!   
heightInHimetricToPixels: height
        " Convert <height> in  logical HiMetric to screen coordinate system units.
        Answer height in pixels."

    ^self heightInHimetricToPixels: height
        deviceContext: Display deviceContext
!
widthInHimetricToPixels: width deviceContext: hDC
        " Convert <width> in logical HiMetric to device coordinate system units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used. The conversion formula is as follows:
        DistanceInPixels := (DistanceInHiMetric * PixelsPerLogicalInch) / HiMetricsPerInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].

    pixelsPerLogicalInch := GDILibrary
        getDeviceCaps: hdc
        index: Logpixelsx.

    ^( width * pixelsPerLogicalInch ) // 2540.!   
heightInPixelsToHimetric: height deviceContext: hDC
        " Convert <height> in device coordinate system to logical HiMetric units.
        The device context <hDC> provide reference to the pixel mapping.
        If NULL, a screen DC is used.  The conversion formula is as follows:
        DistanceInHiMetric = (HiMetricsPerInch * DistanceInPixels) / PixelsPerLogicalInch.
        Where HiMetricsPerInch := 2540. "

    | hdc pixelsPerLogicalInch |
    hdc := hDC isNil
        ifTrue: [ Display deviceContext ]
        ifFalse: [ hDC ].

    pixelsPerLogicalInch := GDILibrary
        getDeviceCaps: hdc
        index: Logpixelsy.

    ^( height * 2540 ) // pixelsPerLogicalInch.!   
widthInPixelsToHimetric: width
        " Convert <width> in screen coordinate system to logical HiMetric units.
        Answer width in logical HiMetric."

    ^self widthInPixelsToHimetric: width
        deviceContext: Display deviceContext!   
oleStdDoTreatAsClass: userType clsid: clsidOld clsid: clsidNew
        " Establish or remove an emulation from one object class to another.
        The <clsidNew> specifies the CLSID of the object class that should emulate
        <clsidOld> replacing any existing emulation. It can be CLSID_NULL, in which
        case any existing emulation for <clsidOld> is removed."

    | hresult |
    hresult := OLEDLL current CoTreatAsClass: clsidOld _: clsidNew.
    ( HRESULT succeeded: hresult )
        ifFalse: [
            self ISSUE.  "self notYetImplemented." ].
	^hresult! 
DeactivateAndUndo
		"Private-The control is deactivating due to undo. Inform the container."

    ^self unimplementedFunction! 
unregisterAllNotification
        " Private - Delete all registered notifications on the receiver object."

    self unregisterOLENotification.
    self unregisterViewNotification.
    self unregisterDataNotification.!   
container: aContainerObject
		" Specify the container object with which the receiver is associated. "

	container := aContainerObject.!
container
		" Answer the container object with which the receiver is associated. "

	^container!   
releaseResources
        " Private - release resources associated with the receiver. "

    self
        releaseInPlaceObject;
        releaseOleObject;
        releaseStorage.
    super releaseResources.!  
createBackingStore
        " Private - Answer a new backing store for the receiver. "

    self setContainerModified.
    ^self docFileStorage newStorage: self name! 
CanInPlaceActivate
        " Private - Answer S_OK if IPA is supported, S_FALSE otherwise."

    ^self canInPlaceActivate
        ifTrue: [ S_OK ]
        ifFalse: [ S_FALSE ]! 
createFromDataObject: anIDataObject
        " Private - create an embedded object form data specified by <anIDataObject>."

    | anIOleObject |
    self deleteContent.
    [
    anIOleObject := IOleObject createFromData: anIDataObject
        rendering: OLERENDER_DRAW
        format: nil "self formatEtc"
        clientSite: nil
        storage: self storage.
    ] on: OLEError
        do: [ :ex |
            self deletePersistentState.
            ex pass ].
    self
        clearIsValid;
        oleObject: anIOleObject.
    ^anIOleObject!  
clearIsValid
        " Private - the receiver is not valid. "

    self sitePane isValidFlag: false.!  
formatEtc
        " Private - Answer the object's data/presentation format a OLEFORMATETC structure. "

    formatEtc isNil
        ifTrue: [
            formatEtc := ( OLEStructure classForStructureNamed: #FORMATETC )
                format: 0
                medium: TYMED_NULL ].
    ^formatEtc!
OnUIActivate
		"Private-The control's UI is being activated. Inform the container so it can remove its own UI components."

    ^S_OK
!   
formatEtc: anOleFormatEtc
        " Private - Set the object's data/presentation format to <anOleFormatEtc> a OLEFORMATETC structure. "

    ( anOleFormatEtc isKindOf: ( OLEStructure classForStructureNamed: #FORMATETC ) )
        ifTrue: [ formatEtc := anOleFormatEtc ].!   
showObjectType
        " Answer whether the site object is rendered
        with the OLE standard UI show object type effect. "

    ^self container isNil
        ifTrue: [ false ]
        ifFalse: [ self container showObjects ]!   
registerForDataNotification
        " Private - register to receive data notification (OnDataChange) on the receiver object."

    | anIDataObject |
    anIDataObject := oleObject queryInterface: IID_IDataObject.
    dataConnection := anIDataObject registerAdviseSink: self myAdviseSink
        format: self formatEtc
        adviseFlags: ADVF_PRIMEFIRST.
    anIDataObject release.!   
OnPosRectChange: posRect
		"Private-The control's position rectangle has changed. Inform the container."

    inPlaceObject setObjectRectangle: posRect clippingRectangle: sitePane rectangle.
    ^S_OK! 
isValid
        " Private - answer whether the receiver has been fully constructed. "

    ^self oleObject notNil
        and: [ self sitePane isValidFlag ]! 
canInPlaceActivate
        " Answer whether the object in the receiver can be in-place activated. "

    ^self aspect == DVASPECT_CONTENT! 
OnInPlaceActivate
		"Private - The control is being activated. Inform the container."

    inPlaceObject := oleObject queryInterface: IID_IOleInPlaceObject.
    ^S_OK
! 
getObjectExtent
        " Private - answer the extent size of the receiver object. "

    | extentInHimetric |
	extentInHimetric := self oleObject getExtent: self aspect.
	^self class pointInHimetricToPixels: extentInHimetric.!  
unregisterDataNotification
        " Private - Delete last registered data notification (OnDataChange) on the receiver object."

    | anIDataObject |
    dataConnection notNil
        ifTrue: [
            anIDataObject := oleObject queryInterface: IID_IDataObject.
            anIDataObject unregisterAdviseSink: dataConnection.
            dataConnection := nil.
            anIDataObject release ]!   
setLinkAvailable
        " Private - Set the contained object's link source available state."

    linkAvailable := true.! 
pasteEmbeddedObject: anIDataObject hMetaPict: hMetaPict
        " Paste the object specified by <anIDataObject> into the pane associated with
        the receiver. Render the object as an icon if <hMetaPict> contains a valid handle. "

    | embeddedObjectType |

    ( embeddedObjectType := anIDataObject embeddedObjectType ) isNil
        ifTrue: [ ^self error: 'No supported formats' ].

    embeddedObjectType = 'static'
        ifTrue: [ self createStaticFromDataObject: anIDataObject ]
        ifFalse: [ self createFromDataObject: anIDataObject ].
    self connectObjectToSite: hMetaPict.
    self saveObject.
    self displayObject.  "Force to show it self"
!
oleObject: anIOLEObject
        "Set the receiver's IOleObject interface to <anIOLEObject>."

	oleObject := anIOLEObject.! 
switchDisplayAspectToIcon: hMetaPict
        " Private - Switch the currently cached display aspect to DVASPECT_ICON."

    self switchDisplayAspect: DVASPECT_CONTENT
        to: DVASPECT_ICON
        metaPict: hMetaPict.!   
openBackingStore
        " Private - Open the backing store of the receiver. "

    ^self docFileStorage openStorage: self name!   
oleObject
        "Answer the receiver's IOleObject interface."

    ^oleObject!   
containsEditableObject
        " Answer whether the receiver contains an editable OLE object. "

    ^self notEmpty and: [ self oleObject isStaticObject not ]!
createObject: objectClsid
        " Private - create an embedded object specified by the class id <objectClsid>."

    | anIOleObject |
    self deleteContent.
    [
    anIOleObject := IOleObject create: objectClsid
        rendering: OLERENDER_DRAW
        format: self formatEtc
        clientSite: nil
        storage: self storage.
    ] on: OLEError
        do: [ :ex |
            self deletePersistentState.
            ex pass ].
    self
        clearIsValid;
        oleObject: anIOleObject.
    ^anIOleObject!   
linkAvailable: aBoolean
        "Private - set the contained object's link source available state to <aBoolean>."

    linkAvailable := aBoolean.! 
linkAvailable
        " Private - answer true if the container object's link source is available."

    ^linkAvailable!
setObjectExtent
        "Private - Set the extent size of the receiver object. "

	| extentInHimetric |
	extentInHimetric := self class 
		pointInPixelsToHimetric: ( self displayRectangle extent ).
	self oleObject
		setExtent: self aspect 
		point: extentInHimetric.!   
cloneOleObject
        " Private - Create a clone of the ole object in the receiver.
          Answer the cloned ole object. "

    | tempStorage iPersistStorage clonedOleObject |
    " create a sub-storage for the object "
     tempStorage := OLECompoundFile createTemporaryFile.
    " make a clone of the object "
     oleObject notNil
        ifTrue: [
            iPersistStorage := oleObject queryInterface: IID_IPersistStorage.
            iPersistStorage isNil ifTrue: [ ^self error: 'object must support IPersistStorage' ].
            tempStorage doesNotNeedFinalization.
            tempStorage interfaceBinding doesNotNeedFinalization.
            iPersistStorage saveTo: tempStorage sameAsLoad: false.
            iPersistStorage release ]
        ifFalse: [    " object not loaded "
            self storage copyTo: tempStorage ].
    clonedOleObject := IOleObject loadFromStorage: tempStorage oleClientSite: nil.
    ^clonedOleObject!   
pasteEmbeddedObject: anIDataObject
        " Paste the object specified by <anIDataObject> 
		into the pane associated with the receiver."

    self pasteEmbeddedObject: anIDataObject hMetaPict: nil
! 
activate
        " Set the receiver's active flag."

    self active: true.
    self displayObject.

!  
insertLinkedFileObject: aFileName hMetaPict: hMetaPict
        " Insert the object specified by <aFileName> into the pane associated with
        the receiver. If <hMetaPict> contains a valid handle then display as an icon. "

    self
        createLinkToFileObject: aFileName;
        connectObjectToSite: hMetaPict.
    self saveObject.
    self displayObject.  "Force to show it self"! 
OnShowWindow: fShow
        " Private - implement the IOleClientSite::OnShowWindow function.
        Notify the container when an object's windows become visible or invisible.
        The boolean <fShow> indicates whether or not an object window is becoming visible.
        Answer the result code. "

    fShow
        ifTrue: [
            self container window disable.
            self setEditing.
            self displayObject ]
        ifFalse: [
            self container window enable.
            self container window bringToFront.
            self sitePane setFocus.
            self clearEditing.
            self displayObject ].
    ^S_OK!  
isInPlaceActivated
        "Answer true if the receiver contains an IPA object else false."

    ^inPlaceObject notNil
!  
clearContent
        " Private - clear the content of the site associated with the receiver. "

    self isEmpty
        ifTrue: [ ^self ].
    self sitePane erase.
    self clearIsValid.
    self
        releaseInPlaceObject;
        releaseOleObject;
        releaseStorage.
    editing := false.
    linkAvailable := false.
    formatEtc := nil.
!  
OnClose
		" Private - implement the IAdviseSink::OnClose function.
		Notify the receiver that the calling object has closed (transitioned from
		the running to the loaded state) and is shutting down.
		The notification is asynchronous.
		Do nothing (keep the backing objectStorage open). "

    self unregisterOLENotification.
!  
aspect
        " Answer the object's data/presentation aspect a DVASPECT value. "

    ^self formatEtc dwAspect!   
objectRectangle
        " Answer the object's current rectangle. "

    | extentInHimetrics extentInPixels |
    extentInHimetrics := self oleObject getExtent: self aspect.
    extentInPixels := self class pointInHimetricToPixels: extentInHimetrics.
    ^(self sitePane rectangle origin) extent: extentInPixels
!   
sitePane: aPane
        " Set the receiver's viewing pane to <aPane>. "

    sitePane := aPane.!   
setObjectName
        " Private - Inform the object of the name in the container."

    oleObject
        setHostNames: self container name
        documentName: self name.
!  
pasteLinkedObject: anIDataObject hMetaPict: hMetaPict
        " Paste a link to the object specified by <anIDataObject> into the pane associated with
        the receiver. Render the object as an icon if <hMetaPict> contains a valid handle. "

    anIDataObject canCreateLinkedObject
        ifFalse: [ ^self error: 'No supported link formats' ].
    self
        createLinkFromDataObject: anIDataObject;
        connectObjectToSite: hMetaPict.
    self saveObject.
    self displayObject.  "Force to show it self"! 
clearEditing
        " Clear the receiver's editing flag."

    self editing: false.!  
switchDisplayAspectToContent
        " Private - Switch the currently cached display aspect to DVASPECT_CONTENT."

    | mustUpdate |
    mustUpdate := self switchDisplayAspect: DVASPECT_ICON
        to: DVASPECT_CONTENT
        metaPict: nil.
    mustUpdate ifTrue: [ self displayObject ].!
connectObjectToSite: hMetaPict
        " Private - connect the OLE object to its containing site.
        Switch object display to iconic if <hMetaPict> contains a valid handle. "

    self registerForViewNotification.
    self oleObject setClientSite: self myOleClientSite.
    self oleObject isStaticObject
        ifFalse: [
            self registerForOLENotification.
            self setObjectName ].
    self oleObject isLinkObject
        ifTrue: [ self setLinkAvailable ].
    self oleObject setContainedObject.

    ( hMetaPict notNil and: [ hMetaPict isValid ] )
        ifTrue: [ self switchDisplayAspectToIcon: hMetaPict ].
    self setIsValid.!
setLoadOnReference
        " Private - the receiver should be loaded from its persistent state "

    self sitePane loadOnReference: true.!
GetWindow: reference
		"Private-Get the window for the control. Store it into <reference>."

    reference value: self sitePane.
    ^S_OK!   
pasteLinkedObject: anIDataObject
        " Paste a link to the object specified by <anIDataObject> 
		into the pane associated with the receiver."

    self pasteLinkedObject: anIDataObject hMetaPict: nil! 
canPasteFromClipboard
        " Answer whether the current contents of the clipboard can 
		be pasted into the pane associated with the receiver. "

    | anIDataObject canPaste |
    anIDataObject := IDataObject getClipboardObject.
    anIDataObject isNil ifTrue: [ ^false ].
    canPaste := self canPasteFrom: anIDataObject.
    anIDataObject release.
    ^canPaste! 
deletePersistentState
        " Private - delete the persistent state of the receiver object from the backing storage. "

    self hasPersistentState ifFalse: [ ^self ].
    self releaseStorage.
    self docFileStorage destroyElement: self name.
    self setContainerModified.!   
myOleClientSite
		" Private - answer the receiver's IOleClientSite interface.
		This is not a separately reference counted copy; it is the original guy. "

	^self interfaceForIID: IID_IOleClientSite!   
deactivateInPlaceObject
        "Deactive the in place object."

    inPlaceObject isNil
        ifTrue: [ ^self ].
    self ISSUE. "Need to handle deactivation of inside-out object."
    self ISSUE. "If inside-out call inPlaceObject uiDeactivate else"
    [ inPlaceObject inPlaceDeactivate ]
        on: OLEError
        do: [ :ex | 
            "Case of the object server not able to deactivate. This is seen
                when trying to deactivate while editing a cell in an Excel Spreadsheet."
            ^self ].

    oleObject closeSaveIfDirty. "Make sure the object persistent state is updated."
    self displayObject.
!   
containsStaticObject
        " Answer whether the receiver contains a static OLE object. "

    ^self notEmpty and: [ self oleObject isStaticObject ]! 
activateObjectVerbOpen
        " Activate the receiver object with verb OLEIVERB_OPEN."

    self activateObjectVerb: OLEIVERB_OPEN.!  
showActiveState
        " Private - Draw the UI feedback for current selection state on the receiver object. "

    self isEmpty ifTrue: [ ^self ].

    self active
        ifTrue: [ self sitePane graphicsTool drawFrame: self objectRectangle ]
        ifFalse: [ self sitePane graphicsTool eraseFrame: self objectRectangle ].! 
docFileStorage
        " Private - answer the container's backing storage. "

    ^self container isNil
        ifTrue: [ nil ]
        ifFalse: [ self container storage ]! 
unregisterOLENotification
        " Private - Delete last registered OLE notifications (OnRename, OnSave, and OnClose) on the receiver object."

    oleConnection notNil
        ifTrue: [
            oleObject unregisterAdviseSink: oleConnection.
            oleConnection := nil ]!  
setInPlaceObjectRectangle
        "Private - Set the rectangular size of the receiver object in-place. "

	| rectangleInPixels |
	rectangleInPixels := self displayRectangle.
	inPlaceObject 
		setObjectRectangle: rectangleInPixels
		clippingRectangle: rectangleInPixels.! 
displayRectangle
        " Answer the display rectangle of the receiver. "

    ^self sitePane rectangle!  
createInterfaceForIID: iid
        " Private - answer a new instance of the interface identified by the GUID <iid>
        on the receiver.  Answer nil if the interface is not supported. "

    iid = IID_IOleClientSite
        ifTrue: [ ^IOleClientSite on: self ].
    iid =  IID_IAdviseSink
        ifTrue: [ ^IAdviseSink on: self ].
    iid = IID_IOleInPlaceSite
        ifTrue: [ ^IOleInPlaceSite on: self ].
    ^nil!   
convertObjectToClass: clsidNew activate: aBoolean
        " Private - Convert the receiver's object into an object of class specified by <clsidNew>.
        If <aBoolean> is TRUE the object is activated after it is successfully converted. "

    | anIStorage |

    anIStorage := self storage separateReference.
    self
        releaseInPlaceObject;
        releaseOleObject;
        releaseStorage.
    self formatEtc: nil.
    self class oleStdDoConvert: anIStorage clsid: clsidNew.
    anIStorage commit.
    anIStorage release.
    anIStorage := nil.
    self loadObjectFromStorage.
    self displayObject.
    self setContainerModified.
    aBoolean
        ifTrue: [ self activateObjectVerbShow ].
!   
getPersistenceInterface
		" Private - answer the persistence interface of the receiver's control. "

	self storage isStorage
		ifTrue: [ ^self oleObject queryInterface: IID_IPersistStorage ].
	self storage isStream
		ifTrue: [ ^self oleObject queryInterface: IID_IPersistStream ].
	^nil!
switchDisplayAspect: currentAspect to: newAspect metaPict: hMetaPict
        " Private - Switch the currently cached display aspect between DVASPECT_ICON and DVASPECT_CONTENT."

    | resultReference hresult |

    resultReference := false asValueReference.
    hresult := self class oleStdSwitchDisplayAspect: self oleObject
        currentAspect: currentAspect
        newAspect: newAspect
        hMetaPict: hMetaPict
        deleteOldAspect: false
        setupViewAdvise: false "true"
        adviseSink: nil "self myAdviseSink"
        mustUpdate: resultReference.
    hresult = S_OK
        ifTrue: [ self aspect: newAspect ].
    ^resultReference value.
!  
deactivate
        " Clear the receiver's active flag."

    self active: false.
    self displayObject.
!   
hasPersistentState
        " Private - answer whether the receiver has saved a
        persistent reprensentation of its state in a backing store. "

    ^self docFileStorage isNil
        ifTrue: [ false ]
        ifFalse: [ self docFileStorage hasElementNamed: self name ]! 
releaseStorage
        " Private - release the storage used by the receiver.. "

    | interfaceBeingReleased |
    self isStorageOpen
        ifTrue: [
            interfaceBeingReleased := storage.
            storage := nil.
            interfaceBeingReleased release ].!
OnUIDeactivate: undoable
		"Private-The control's UI has been deactivated. Inform the container that it may
		restore its UI components. If control supports undo <undoable> is <true>."

    self container
        frameSetMenu: nil _: nil _: nil;
        frameSetBorderSpace: 0.  
    ^S_OK
!   
setContainerModified
        " Private - Set the container associated with receiver to modified."

    ^self container isNil
        ifTrue: [ nil ]
        ifFalse: [ self container setModified ]!
pasteStaticObject: anIDataObject
        " Paste the static object specified by <anIDataObject>
        into the pane associated with the receiver."

    self
        createStaticFromDataObject: anIDataObject;
        connectObjectToSite: nil.
    self saveObject.
    self displayObject.  "Force to show it self"!
showEditingState
        " Private - Draw the UI feedback for current editing state on the receiver object. "

    self isEmpty ifTrue: [ ^self ].

    ( self editing and: [ self aspect ~= DVASPECT_ICON ] )
        ifTrue: [ self sitePane graphicsTool drawShading: self objectRectangle ]
        ifFalse: [ self displayObject ].
!
displayObject
        " Render the presentation of the receiver object."

    self displayObject: self aspect.!
activateObjectVerb: iVerb
        " Activate the receiver object as specified by the object verb <iVerb>.
        If the object is in the passive state then transition the object state to loaded."

    self isEmpty
        ifTrue: [ self loadObjectFromStorage ].

    self containsStaticObject
        ifFalse: [
            self oleObject doVerb: iVerb
                clientSite: self myOleClientSite
                hwndParent: self sitePane handle
                rectangle: self sitePane rectangle ].
!  
displayObject: dwAspect
        " Render the presentation of the receiver object.
        The DVASPECT value in <dwAspect> specifies the view aspect of the object."

    ^self displayObject: dwAspect site: self sitePane!  
storage
        " Private - Answer the backing storage of the receiver. "

    storage isNil
        ifTrue: [ self storage: self createBackingStore ].
    ^storage!
storage: aStorageElement
        " Private - Set the backing storage of the receiver. "

    storage := aStorageElement.!  
canDoConvert
        " Private - Answer whether the object in the receiver can be converted. "

    self containsStaticObject
        ifTrue: [ ^false ].
    [
        ( ( self storage notNil ) and: [ self storage isStorage ] )
            ifTrue: [
                self storage readClipboardFormatAndUserType.
                ^true ]
            ifFalse: [ ^false ].
    ]
        on: OLEError
        do: [ :ex | ^false ].!
OnDataChange:aFormatEtc _: aStgMedium
		" Private - implement the IAdviseSink::OnDataChange function.
		Notify the receiver that the data in the calling object has changed. "

        "The FORMATETC format information that the receiver provided
        when this data advise was established via IDataObject::DAdvise is
        provided in <aFormatEtc>. The changed data in the specified format
        is provided in <aStgMedium>.  The notification is asynchronous.
        The arguments belong to the caller and are valid only for the duration of this call. "

        " Not all containers register for data change notifications.
        An example of a container that would register for data change
        notifications is one that does not use OLE caching support."
!  
OnViewChange: dwAspect _: lindex
        " Private - implement the IAdviseSink::OnViewChange function.
        Notify the receiver that the view of the calling object described by
        the DVASPECT value in <dwAspect> has changed.
        The notification is asynchronous and the arguments belong to the caller.

        In OLE 2.0.1, <dwAspect> must be a single value and <lindex> must be -1. "

    self editing
        ifTrue: [ self displayObject: dwAspect ]. ! 
insertEmbeddedObject: objectClsid hMetaPict: hMetaPict
        " Insert the object specified by <objectClsid> into the pane associated with
        the receiver. If <hMetaPict> contains a valid handle then display as an icon. "

    self
        createObject: objectClsid;
        connectObjectToSite: hMetaPict.
    self saveObject.
    self activateObjectVerbShow.!   
active
        "Answer true if the receiver is currently active."

    ^active!
GetMoniker: dwAssign _: whichMoniker _: resultReference
        " Private - implement the IOleClientSite::GetMoniker function.
        Query the receiver for the moniker specified by the OLEWHICHMK
        value in <whichMoniker>, which can be the container's moniker
        or the relative or absolute moniker of the object.  The OLEGETMONIKER
        value in <dwAssign> specifies the type of moniker to be returned.
        Store the IMoniker interface which is obtained into <resultReference>.
        Answer the result code. "

    | moniker |
    whichMoniker == OLEWHICHMK_CONTAINER
        ifTrue: [  moniker := self getFullDocumentMoniker: dwAssign ]
        ifFalse: [
            whichMoniker == OLEWHICHMK_OBJREL
                ifTrue: [  moniker := self getRelativeObjectMoniker: dwAssign ]
                ifFalse: [
                    whichMoniker == OLEWHICHMK_OBJFULL
                        ifTrue: [  moniker := self getFullObjectMoniker: dwAssign ] ] ].
    moniker isNil
        ifTrue: [ ^E_FAIL ].
    resultReference value: moniker.
    ^S_OK!   
aspect: dvAspect
        " Set the object's data/presentation aspect to <dvAspect> a DVASPECT value. "

    self formatEtc dwAspect: dvAspect! 
registerForOLENotification
        " Private - register to receive OLE notifications (OnRename, OnSave, and OnClose) on the receiver object."

    oleConnection := oleObject registerAdviseSink: self myAdviseSink.!  
getRelativeObjectMoniker: dwAssign
        " Private - Answer the moniker of the object relative to the container. The OLEGETMONIKER
        value in <dwAssign> specifies the type of moniker to be returned. "

    | moniker |
    dwAssign == OLEGETMONIKER_UNASSIGN
        ifTrue: [ ^nil ].
    moniker := IMoniker createItemMoniker: self storage name delimiterString: '\\'.
    dwAssign == OLEGETMONIKER_FORCEASSIGN
        ifTrue: [
            oleObject setMoniker: OLEWHICHMK_OBJREL moniker: moniker.
            self setContainerModified ].
    ^moniker!   
doVerb: iVerb
        " Private - Do verb specified by <iVerb> on the receiver object."

    ( oleObject isNil ) ifTrue: [ ^self ].

    oleObject doVerb: iVerb
        clientSite: self myOleClientSite
        hwndParent: self sitePane handle
        rectangle: self sitePane rectangle
!  
insertEmbeddedObject: objectClsid
        " Insert the object specified by <objectClsid> 
		into the pane associated with the receiver."

    self insertEmbeddedObject: objectClsid hMetaPict: nil.
!   
insertLinkedFileObject: aFileName
        " Insert the object specified by <aFileName> 
		into the pane associated with the receiver."

    self insertLinkedFileObject: aFileName hMetaPict: nil.!   
getFullObjectMoniker: dwAssign
        " Private - Answer the full moniker of the object and its container document. The OLEGETMONIKER 
        value in <dwAssign> specifies the type of moniker to be returned. "

	| moniker monikerDocument monikerItem |
	monikerDocument := self getFullDocumentMoniker: dwAssign.
	monikerDocument isNil
		ifTrue: [ ^nil ].
	monikerItem := self getRelativeObjectMoniker: dwAssign.
	monikerItem notNil
		ifTrue: [ 
			moniker := IMoniker createGenericCompositeMoniker: monikerDocument
				with: monikerItem.
			monikerItem release ].
	monikerDocument release.
	^moniker!  
insertEmbeddedFileObject: aFileName hMetaPict: hMetaPict
        " Insert the object specified by <aFileName> into the pane associated with
        the receiver. If <hMetaPict> contains a valid handle then display as an icon. "

    self
        createFileObject: aFileName;
        connectObjectToSite: hMetaPict.
    self saveObject.
    self displayObject.  "Force to show it self"
!   
insertEmbeddedFileObject: aFileName
        " Insert the object specified by <aFileName> into the pane 
		associated with the receiver."

    self insertEmbeddedFileObject: aFileName hMetaPict: nil
!  
editing: aBoolean
        "Set the receiver's editing state to <aBoolean>."

    editing := aBoolean.! 
editing
        "Answer true if the receiver is being edited."

    ^editing!  
active: aBoolean
        "Set the receiver's active state to <aBoolean>."

    active := aBoolean.!
OnRename: anIMoniker
		" Private - implement the IAdviseSink::OnRename function.
		Notify the receiver that the name of the calling object has changed to <anIMoniker>.
		The notification is asynchronous and the arguments belong to the caller. "

	"Although the container and the OLE link object typically receive this notification, the
		container can ignore it. The link object, however, must update its moniker. 
		If the callee retains the interface argument, it must be explicitly copied
		and independently reference counted.
		Most containers will not need to register for OLE advise notifications."!   
showObjectType: aBoolean
        " Render the OLE standard UI show object type effect on the receiver object.
        The flag <aBoolean> specifies whether to set or remove the display effect. "

    self isEmpty ifTrue: [ ^self ].

    aBoolean
        ifTrue: [
            self sitePane graphicsTool
                showObject: self objectRectangle
                isLink: self containsLinkObject ]
        ifFalse: [ self displayObject ].!
displayObject: dwAspect site: aPane
        " Render the presentation of the receiver object in the site pane <aPane>.
        The DVASPECT value in <dwAspect> specifies the view aspect of the object."

    | aRectangle |

    " check for first reference to a demand-loaded site "
    self sitePane loadOnReference
        ifTrue: [
            "self ASSERT: self isEmpty."
            self sitePane loadOnReference: false.
            self hasPersistentState
                ifTrue: [ self loadObjectFromStorage ].
            ].

    aPane erase.

    self isValid not  " empty or not properly connected "
        ifTrue: [ ^self ].

    "If object is in-place activated, let the server render the object."
    inPlaceObject notNil
        ifTrue: [ ^self ].

    aRectangle := self objectRectangle.
    self oleObject display: dwAspect
        on: aPane
        in: aRectangle.
    self active
       ifTrue: [ aPane graphicsTool drawFrame: aRectangle ].
    self editing
        ifTrue: [ aPane graphicsTool drawShading: aRectangle ].
    self showObjectType
        ifTrue: [
            aPane graphicsTool
                showObject: aRectangle
                isLink: self containsLinkObject ].!
initialize
        " Private - initialize the receiver. "

    super initialize.
    editing := false.
    active := false.
    linkAvailable := false.
!  
isEmpty
        " Answer whether the receiver currently contains nothing. "

    ^self oleObject isNil!
OnInPlaceDeactivate
        "Private - The control is no longer IPA. Inform the container."

    self releaseInPlaceObject.
    ^S_OK
!  
deleteContent
        " Private - delete the receiver object from the backing storage and clear the site. "

    self hasPersistentState
        ifTrue: [
            self deletePersistentState.
            self clearContent ].!
ContextSensitiveHelp: boolean
		"Private - Enter help mode if <boolean> is <true>, exit if <false>."

    ^self unimplementedFunction! 
Scroll: extent
		"Private-Ask the container to scroll the control by <extent>."

    ^self unimplementedFunction!  
createFileObject: aFileName
        " Private - create an embedded file object specified by <aFileName>."

    | anIOleObject |
    self deleteContent.
    [
    anIOleObject := IOleObject createFromFile: aFileName
        rendering: OLERENDER_DRAW
        format: self formatEtc
        clientSite: nil
        storage: self storage.
    ] on: OLEError
        do: [ :ex |
            self deletePersistentState.
            ex pass ].
    self
        clearIsValid;
        oleObject: anIOleObject.
    ^anIOleObject! 
GetWindowContext: frameRef
	_: windowRef
	_: positionRef
	_: clipRef 
	_: frameInfoRef
    "Private - The control needs its window context. Fill the parameters with required data.
        <frameRef> a value holder that get set to a IOleInPlaceFrame interface
        <windowRef> a value holder that gets set to a IOleInPlaceUIWindow interface
        <positionRect> a value holder that gets set to the control's position
        <clipRect> a value holder that gets set to the clipping rectangle
        <frameInfoRef> a value holder for an OLE_OLEINPLACEFRAMEINFO that needs to be filled"

    frameRef value: (self container queryInterface: IID_IOleInPlaceFrame ).
    ( Smalltalk includesKey: #MDISystem ) ifTrue: [
        ( Smalltalk at: #MDISystem ) isActive ifTrue: [
            windowRef value: (self container queryInterface: IID_IOleInPlaceUIWindow ) ] ].
    positionRef value: self objectRectangle.
    clipRef value: self sitePane rectangle.
    frameInfoRef value: container frameInfo.
    ^S_OK
!   
GetContainer: resultReference
        " Private - implement the IOleClientSite::GetContainer function.
		Query the receiver for the embedding container's IOleContainer interface.
		Store the address of the IOleContainer interface into <resultReference>.
		Increment the reference count for that interface.
		Answer the result code. "

    "## Linked objects support."
	"TO DO: remember to do addRef when we return a container interface here "
    ^self unimplementedFunction!  
getFullDocumentMoniker: dwAssign
        " Private - Answer the full moniker of the document. The OLEGETMONIKER 
        value in <dwAssign> specifies the type of moniker to be returned. "

    ^IMoniker createFileMoniker: self container storage name.!  
createLinkToFileObject: aFileName
        " Private - create a linked file object specified by <aFileName>."

    | anIOleObject |
    self deleteContent.
    [
    anIOleObject := IOleObject createLinkToFile: aFileName
        rendering: OLERENDER_DRAW
        format: self formatEtc
        clientSite: nil
        storage: self storage.
    ] on: OLEError
        do: [ :ex |
            self deletePersistentState.
            ex pass ].
    self
        clearIsValid;
        oleObject: anIOleObject.
    ^anIOleObject!
ShowObject
        " Private - implement the IOleClientSite::ShowObject function.
		Request the receiver to position the object so it is visible to the user.
		Answer the result code. "

    self container window bringToFront.
    self sitePane setFocus.
    ^S_OK!  
createLinkFromDataObject: anIDataObject
        " Private - create a linked object form data specified by <anIDataObject>."

    | anIOleObject |
    self deleteContent.
    [
    anIOleObject := IOleObject createLinkFromData: anIDataObject
        rendering: OLERENDER_DRAW
        format: nil "self formatEtc"
        clientSite: nil
        storage: self storage.
    ] on: OLEError
        do: [ :ex |
            self deletePersistentState.
            ex pass ].
    self
        clearIsValid;
        oleObject: anIOleObject.
    ^anIOleObject! 
name: aString
		" Set the receiver's name to <aString>. "

	name := aString.!  
name
		" Answer the receiver's name. "

	^name!
containsLinkObject
        " Answer whether the receiver contains an OLE link object. "

    ^self notEmpty and: [ self oleObject isLinkObject ]!  
notEmpty
        " Answer whether the receiver currently contains an OLE object. "

    ^self oleObject notNil!
SaveObject
        " Private - implement the IOleClientSite::SaveObject function.
        Save the object attached to this client site. "

    [
        self saveObject.
        self setContainerModified.
    ]
        on: OLEError
        do: [ ^S_FALSE ].
    ^S_OK
!  
createStaticFromDataObject: anIDataObject
        " Private - create a static object from a data transfer object specified by <anIDataObject>."

    | anIOleObject |
    self deleteContent.
    [
    anIOleObject := IOleObject createStaticFromData: anIDataObject
        rendering: OLERENDER_DRAW
        format: nil "self formatEtc"
        clientSite: nil
        storage: self storage.
    ] on: OLEError
        do: [ :ex |
            self deletePersistentState.
            ex pass ].
    self
        clearIsValid;
        oleObject: anIOleObject.
    ^anIOleObject!   
activateObjectAsClass: clsidNew activate: aBoolean
        " Private - Activate the receiver's object as an object of class specified by <clsidNew>.
        If <aBoolean> is TRUE the object is activated after it is successfully converted. "

    | activate clsidOld userType hresult |
    activate := aBoolean.
    clsidOld := self storage readCLSID.
    userType := OLERegistryInterface getUserTypeFull: clsidOld.
    hresult := self class oleStdDoTreatAsClass: userType clsid: clsidOld clsid: clsidNew.
"    hresult := OLEDLL currect CoTreatAsClass: clsidOld _: clsidNew."
    ( HRESULT succeeded: hresult )
        ifTrue: [
            self
                releaseInPlaceObject;
                releaseOleObject;
                releaseStorage;
                loadObjectFromStorage.
            activate := true ].
    activate
        ifTrue: [ self activateObjectVerbShow ].! 
isStorageOpen
        " Private - answer whether the receiver has a backing store open. "

    ^storage notNil!
setIsValid
        " Private - the receiver is now valid. "

    self sitePane isValidFlag: true.! 
canPasteFrom: anIDataObject
        " Answer whether <anIDataObject> can be pasted into the
		pane associated with the receiver. "

    ^anIDataObject canCreateEmbeddedObject!   
loadObjectFromStorage
        " Load the receiver's object from its persistent backing store."

    | anIOleObject |
    self hasPersistentState
        ifFalse: [ ^self ].
    anIOleObject := self loadObject.  " load errors are handled quietly to allow demand-load of sites "
    anIOleObject isNil
        ifTrue: [ ^self ].
    self connectObjectToSite: nil.
! 
connectToLinkObject
        " Private - Connect to the linked object if source is running. "

    | oleLink |
    oleLink := oleObject queryInterface: IID_IOleLink.
    oleLink bindIfRunning.
    oleLink release.
    self linkAvailable: true.!
loadObject
        " Private - load the receiver's object from its persistent backing store."

    | anIOleObject |
    self clearIsValid.  " disable rendering during construction "
    [
    self isStorageOpen
        ifFalse: [ self storage: self openBackingStore ].
    anIOleObject := IOleObject loadFromStorage: self storage oleClientSite: nil.
    ] on: OLEError
        do: [ :ex |
            self releaseStorage.
            ^nil ].
    self oleObject: anIOleObject.
    ^anIOleObject!  
DiscardUndoState
		"Private-The control cannot undo the last change. Inform the container."

    ^self unimplementedFunction!  
isStateModified
		" Answer whether the contained object's state has been modified
		since it was loaded or last saved. "

	| aPersistenceInterface stateIsModified |
	self isValid
		ifFalse: [ ^false ].
	aPersistenceInterface := self getPersistenceInterface.
	stateIsModified := aPersistenceInterface isDirty.
	aPersistenceInterface release.
	^stateIsModified! 
releaseOleObject
        " Private - release the OLE object held by the receiver. "

    | interfaceBeingReleased |
    oleObject notNil
        ifTrue: [
            oleObject closeNoSave.
            interfaceBeingReleased := oleObject.
            oleObject := nil.
            interfaceBeingReleased release ].!  
saveObject
        " Private - Save the object attached to this client site. "

    self oleObject saveToStorage: self storage sameAsLoad: true.
    self storage commit.!
RequestNewObjectLayout
        " Private - implement the IOleClientSite::RequestNewObjectLayout function.
		Request new layout information for compound document object.
		Answer the result code. "

    ^self unimplementedFunction!   
releaseInPlaceObject
        " Private - release the OLE in-place object held by the receiver. "

    | interfaceBeingReleased |
    inPlaceObject notNil
        ifTrue: [
            inPlaceObject inPlaceDeactivate.
            interfaceBeingReleased := inPlaceObject.
            inPlaceObject := nil.
            interfaceBeingReleased release ].!   
setEditing
        " Set the receiver's editing flag."

    self editing: true.!   
registerForViewNotification
        " Private - register to receive view notification (OnViewChange) on the receiver object."

    | anIViewObject |
    anIViewObject := oleObject queryInterface: IID_IViewObject.
    anIViewObject registerAdviseSink: self myAdviseSink
       aspects: self aspect
       adviseFlags: ADVF_PRIMEFIRST.
    anIViewObject release.! 
sitePane
        " Answer the receiver's viewing pane to <aPane>. "

    ^sitePane!
myAdviseSink
		" Private - answer the receiver's IAdviseSink interface.
		This is not a separately reference counted copy; it is the original guy. "

	^self interfaceForIID: IID_IAdviseSink!
copyObjectToClipboard
        " Private - copy the object contained by the receiver to the clipboard."

    | dataTransferObject |
    dataTransferObject := OLEDataTransferObject new.
    dataTransferObject setObject: self cloneOleObject format: 'Embedded Object'.
    dataTransferObject copyToClipboard.!   
unregisterViewNotification
        " Private - Delete last registered view notification (OnViewChange) on the receiver object."

    | anIViewObject |
    anIViewObject := oleObject queryInterface: IID_IViewObject.
    anIViewObject unregisterAdviseSink.
    anIViewObject release.!  
activateObjectVerbShow
        " Activate the receiver object with verb OLEIVERB_SHOW."

    self activateObjectVerb: OLEIVERB_SHOW.
!
OnSave
		" Private - implement the IAdviseSink::OnSave function. 
		Notify the receiver that the calling object has been saved to persistent storage.
		The notification is asynchronous."!
sizeInBytes
         "Private - Answer the default size in bytes."
    ^20! 
defaultFileName
        " Private - answer the default name. "

    ^'Untitled.', self fileExtension!  
validateHandler: aHandler for: eptDescription
        " Private - validate the function handler <aHandler> which
        has been registered for the interface function described
        by <eptDescription>. "

    ( #( 'Scroll' ) includes: eptDescription name )
        ifFalse: [ ^super validateHandler: aHandler for: eptDescription ].

    " special guys with #structValue arg splitup for POINTL "
    ( aHandler isMessage
    and: [ ( Message numberOfArgumentsFor: aHandler selector ) ~= ( eptDescription argumentTypes size - 1 ) ] )
        ifTrue: [
            MessageBox warning:
                self name,
                ' VTable handlers problems: argument count mismatch for ',
                eptDescription name ].!   
" OLE Container Support - library removal "

    " remove interface classes "
    IOleCachePointer removeIID.
    IOleCache2Pointer removeIID.
    IOleClientSitePointer removeIID.
    IOleLinkPointer removeIID.
    IOleObjectPointer removeIID.
    IOleUILinkContainerPointer removeIID.
    IOleWindowPointer removeIID.
    IOleInPlaceActiveObjectPointer removeIID.
    IOleInPlaceObjectPointer removeIID.
    IOleInPlaceSitePointer removeIID.
    IOleInPlaceUIWindowPointer removeIID.
    IOleInPlaceFramePointer removeIID.
    IOleContainerPointer removeIID.
    IOleItemContainerPointer removeIID.
    IViewObjectPointer removeIID.
    IViewObject2Pointer removeIID.
    IOleCache removeIID.
    IOleCache2 removeIID.
    IOleClientSite removeIID.
    IOleLink removeIID.
    IOleObject removeIID.
    IOleUILinkContainer removeIID.
    IOleWindow removeIID.
    IOleInPlaceActiveObject removeIID.
    IOleInPlaceObject removeIID.
    IOleInPlaceSite removeIID.
    IOleInPlaceUIWindow removeIID.
    IOleInPlaceFrame removeIID.
    IOleContainer removeIID.
    IOleItemContainer removeIID.
    IViewObject removeIID.
    IViewObject2 removeIID.
    IOleClientSiteImplementation removeIID.
    IOleUILinkContainerImplementation removeIID.
    IOleWindowImplementation removeIID.
    IOleInPlaceSiteImplementation removeIID.
    IOleInPlaceUIWindowImplementation removeIID.
    IOleInPlaceFrameImplementation removeIID.
    IOleContainerImplementation removeIID.
    IOleItemContainerImplementation removeIID.

    " remove host structures "
    OLE_OLEINPLACEFRAMEINFO removeStructureName.
    OLE_OLEMENUGROUPWIDTHS removeStructureName.

    " remove development environment support "
    OLESessionManager unbindDevelopmentLibrary: 'VOLDC31W.sll'.
!   
editObjectVerb: iVerb
        " Private - Perform the Edit menu Object verb operation. "

    self activateClientSite: self activeSite objectVerb: iVerb.! 
cAccelEntries
        " Answer the number of entries in the container's accelerator table. "

    ^self uLongAtOffset: 16! 
Scroll: extent
	"Invoke the IOleInPlaceSite::Scroll function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchScroll: extent)!  
dragTargetDrop: aWinDragSession sitePane: aSitePane
        "Private - Process the drop operation."

    | dragObject anIDataObject |
    dragObject := aWinDragSession objects first.
    anIDataObject := dragObject format: 'Embedded Object'
        ifAbsent: [ dragObject format: 'Embed Source' ifAbsent: [ ^nil ] ].
    anIDataObject isNil
		ifTrue: [ ^self ].

    [ 
	CursorManager execute 
		changeFor: [ 
			aSitePane siteObject pasteEmbeddedObject: anIDataObject
		].
	]
        on: OLEError
        do: [ :ex | 
			aSitePane siteObject deleteContent.
			self displayWarning: ex description titled: 'Drag/Drop Problem' ].
! 
OnUIActivate
	"Invoke the IOleInPlaceSite::OnUIActivate function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchOnUIActivate)!
open
        " Invoke the standard OLE Insert Object dialog."

    ^self open: nil!
scode
        "Answer the result of the creation calls."

    ^scode!  
owner: anOwner
        "Sets the owner of the Dialog box."

    super owner: anOwner.
    owner isWindow
        ifTrue: [ parent := owner ]
        ifFalse: [
            parent := owner mainView.
            parent isWindow ifFalse: [
                parent := Notifier findWindow: WindowHandle queryActive ]].
    oleUIInsertObjectStruct hWndOwner: parent asParameter.!
fileName
        "Answer the fileName that was chosen."

    ^fileName!
storage: anIStorage
        "Set the object storage."

    oleUIInsertObjectStruct lpIStorage: anIStorage.!
iid: aGuid
        "Set the fied for requested interface ID."

    oleUIInsertObjectStruct iid: aGuid.!
excludeClasses: aListOfCLSIDs
        " Set the list of classes to exclude from the list to <aListOfCLSIDs>. "

    oleUIInsertObjectStruct excludeClasses: aListOfCLSIDs.!
oleClientSite: anIOleClientSite
        "Set the object site."

    oleUIInsertObjectStruct lpIOleClientSite: anIOleClientSite.!   
flags
        "Answers the dialog box current flags value."

    ^oleUIInsertObjectStruct dwFlags! 
flags: dwFlags
        "Set the dialog box creation flags value."

    oleUIInsertObjectStruct dwFlags: dwFlags.
   self style: dwFlags.! 
formatEtc: anOLEFormatEtc
        "Set the format desired."

    oleUIInsertObjectStruct lpFormatEtc: anOLEFormatEtc.! 
copyStruct
        "Private - copy the oleUIInsertObjectStruct to nonSmalltalk memory"

	 "The dialog does not work if MAX_PATH is used. "
    oleUIInsertObjectStruct allocateFileNameBuffer: 256 "MAX_PATH".

    oleUIInsertObjectStruct allocateObjectInterfaceBuffer.! 
open: titleString
        " Invoke the standard OLE Insert Object dialog."

    | result |
    [ hLibrary := OLEDialogDLL current ]
        on: Error
        do: [
            MessageBox warning: 'Could not find ', OLEDialogDLL fileName asUppercase, '.
You must have this DLL to invoke the standard OLE Insert Object dialog.'.
            ^self ].
    self copyStruct.
    parent isWindow ifFalse: [
        parent := Notifier findWindow: WindowHandle queryActive.
        oleUIInsertObjectStruct hWndOwner: parent asParameter ].
    style notNil
        ifTrue: [ oleUIInsertObjectStruct dwFlags: style ].
    titleString notNil
        ifTrue: [ oleUIInsertObjectStruct dialogCaption: titleString ].

    result := hLibrary OleUIInsertObject: oleUIInsertObjectStruct.
    result = OLEUI_SUCCESS
        ifTrue: [ self checkFlags ].
    self cleanUp.
!  
oleRender: anInteger
        "Set the render option."

    oleUIInsertObjectStruct oleRender: anInteger.!  
cleanUp
        "Private - Free oleUIInsertObjectStruct."

    self style: self flags.
    oleUIInsertObjectStruct release.
    oleUIInsertObjectStruct := nil.! 
hMetaPict
        "Answer the content of cached hMetaPict field."

    ^hMetaPict! 
initialize
        "Private - Initialize oleUIInsertObjectStruct."

    super initialize.
    oleUIInsertObjectStruct := OLE_OLEUIINSERTOBJECT new.
    self style: IOF_SELECTCREATENEW  | IOF_DISABLEDISPLAYASICON.!
clsid
        "Answer the class ID that was chosen."

    ^clsid!  
objectInterface
        " Answer the requested object interface."

    ^oleUIInsertObjectStruct objectInterface!   
checkFlags
        "Private - check user action."

    self style: self flags.
    clsid := oleUIInsertObjectStruct clsid.
    fileName := oleUIInsertObjectStruct fileName.
    hMetaPict := oleUIInsertObjectStruct hMetaPict.
    scode := oleUIInsertObjectStruct sc.! 
hookMessage: aMessage
        " Set up a hook function based on the message <aMessage>.
        This hook function processes messages intended for the dialog box.
        The hook function must return zero to pass a message that it didn't
        process back to the dialog box procedure in the library. The hook
        function must return a nonzero value to prevent the library's dialog
        box procedure from processing a message it has already processed. "

    " The message is similar to the Windows wm messages, for example
    #wmSelector:with: requiring two arguments wParam & lParam. "

    hookCallBack := CallBack
        registerMessage: aMessage
        parameterTypes: #( #ulong #ulong )
        returnType: #long
        callingConvention: #api.

    self lpfnHook: hookCallBack asParameter.!
cbStruct
		" Answer the size in bytes of the data structure. "

	^self uLongAtOffset: 0!   
dwFlags: anInteger
		" Set the flag values to <anInteger>. "

	self uLongAtOffset: 4 put: anInteger.!  
dwFlags
		" Answer the flag values. "

	^self uLongAtOffset: 4!
lpfnHook
        " Private - Answer the address of the hook function. "

    ^self addressAtOffset: 16.!   
releaseResources
		" Private - release resources owned by the receiver. "

    self releaseHook.
	self releaseContents.!  
cbStruct: anInteger
		" Set the size in bytes of the data structure to <anInteger>. "

	self uLongAtOffset: 0 put: anInteger.! 
lpfnHook: anAddress
        " Private - Set the address of the hook function to <anAddress>. "

    self addressAtOffset: 16 put: anAddress.!  
lCustData
        " Answer the application-defined data that is passed to the
        hook function pointed to by the lpfnHook member. "

    ^self uLongAtOffset: 20!
releaseHook
        " Private - release the hook callback function. "

    ( self lpfnHook ) notNil
        ifTrue: [
            hookCallBack release.
            self lpfnHook: nil ].!  
lCustData: anInteger
        " Set the application-defined data that is passed to the
        hook function pointed to by the lpfnHook member. "

    self uLongAtOffset: 20 put: anInteger.! 
" OLE Container Support - library installation "

    " install interface classes "
    IOleCachePointer registerIID.
    IOleCache2Pointer registerIID.
    IOleClientSitePointer registerIID.
    IOleLinkPointer registerIID.
    IOleObjectPointer registerIID.
    IOleUILinkContainerPointer registerIID.
    IOleWindowPointer registerIID.
    IOleInPlaceActiveObjectPointer registerIID.
    IOleInPlaceObjectPointer registerIID.
    IOleInPlaceSitePointer registerIID.
    IOleInPlaceUIWindowPointer registerIID.
    IOleInPlaceFramePointer registerIID.
    IOleContainerPointer registerIID.
    IOleItemContainerPointer registerIID.
    IViewObjectPointer registerIID.
    IViewObject2Pointer registerIID.
    IOleCache registerIID.
    IOleCache2 registerIID.
    IOleClientSite registerIID.
    IOleLink registerIID.
    IOleObject registerIID.
    IOleUILinkContainer registerIID.
    IOleWindow registerIID.
    IOleInPlaceActiveObject registerIID.
    IOleInPlaceObject registerIID.
    IOleInPlaceSite registerIID.
    IOleInPlaceUIWindow registerIID.
    IOleInPlaceFrame registerIID.
    IOleContainer registerIID.
    IOleItemContainer registerIID.
    IViewObject registerIID.
    IViewObject2 registerIID.
    IOleClientSiteImplementation registerIID.
    IOleUILinkContainerImplementation registerIID.
    IOleWindowImplementation registerIID.
    IOleInPlaceSiteImplementation registerIID.
    IOleInPlaceUIWindowImplementation registerIID.
    IOleInPlaceFrameImplementation registerIID.
    IOleContainerImplementation registerIID.
    IOleItemContainerImplementation registerIID.

    " register host structures "
    OLE_OLEINPLACEFRAMEINFO registerStructureName.
    OLE_OLEMENUGROUPWIDTHS registerStructureName.

    " install development environment support "
    OLESessionManager bindDevelopmentLibrary: 'VOLDC31W.sll'
        for: 'OLE Container Support library VOLEC31W.sll'.
! 
OnInPlaceDeactivate
	"Invoke the IOleInPlaceSite::OnInPlaceDeactivate function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchOnInPlaceDeactivate)!   
cAccelEntries: anInteger
        " Set the number of entries in the container's accelerator table. "

    self uLongAtOffset: 16 put: anInteger. ! 
editMenuGroupWidth: anInteger
		" Set the number of items in the objects's edit menu group. "

	self longAtOffset: 4 put: anInteger.!  
enableDisableObjectOperationsIn: aMenu
        " Private - enable/disable Edit menu items in <aMenu>. "

    | itemList |
    itemList := #( #editLinks).
    self container containsLinkObject
        ifTrue: [ self enableItems: itemList in: aMenu ]
        ifFalse: [ self disableItems: itemList in: aMenu ].
    "Not yet supported:
    itemList := #( editProperties ).
    self activeSite containsEditableObject
        ifTrue: [ self enableItems: itemList in: aMenu ]
        ifFalse: [ self disableItems: itemList in: aMenu ].
    "
    self enableDisableObjectVerbMenuIn: aMenu.! 
createViewFor: aCoordinator
        "Create and configure a window for <aCoordinator>.
        The main window of a container application has an
        OLE container object associated with it. "

    | aWindow |
    aWindow := super createViewFor: aCoordinator.
    aWindow labelWithoutPrefix: aCoordinator windowTitle.
    aCoordinator
        when: #titleChanged:
        send: #labelWithoutPrefix: to: aWindow.
    ^aWindow!   
clearClientSite: aClientSite
		" Private - clear the contents of <aClientSite> and delete it from
		the backing document storage. "

    aClientSite deleteContent.!  
selectedClientSite: aClientSitePane
        " Private - the client site <aClientSitePane> has been selected by the user. "

    self activeSite ~= aClientSitePane siteObject
		ifTrue: [ self activeSite: aClientSitePane siteObject ].! 
editClientSite: aClientSite
        " Private - edit the object in <aClientSite>. "

    [
	self activateClientSite: aClientSite 
		objectVerb: OLEIVERB_SHOW.
	]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Edit Object Problem' ].!  
editLinksInContainer: aContainer
        " Private - allow the user to invoke the Edit Links dialog
        to modify the link attributes of the linked object in the container <aContainer>. "

    | uiLinkContainer el |

    uiLinkContainer := ( OLEUILinkContainerObject new )
        container: aContainer.
    [
        uiLinkContainer addRef.
        el := OLEEditLinksDialog new
            oleUILinkContainer: uiLinkContainer myOleUILinkContainer;
            open.
        uiLinkContainer modified
            ifTrue: [ aContainer setModified ].
        uiLinkContainer release.
    ]
        on: OLEError
        do: [ :ex | self displayWarning: ex description titled: 'Edit Links Problem' ].

!
dispatchScroll: extent
		" Private - dispatch the IOleInPlaceSite::Scroll function. "

	^( functionHandlers at: 10 ) evaluateWithArguments: ( Array
		with: extent )! 
loadFromStream: anIStream
        " Load an embedded or linked object from the stream <anIStream>.
        Answer a new instance of the receiver on the loaded object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleLoadFromStream: anIStream
        _: self iid
        _: resultReference.
    ^resultReference value!  
clearObjectVerbMenu: aMenu
		" Clear the object verb submenu in <aMenu>. "

	| objectMenu objectMenuIndex idVerbMin idVerbMax
	  resultReference |

    objectMenu := ( aMenu getMenuItem: 'Object' ) submenu.
    objectMenuIndex :=  aMenu getIndex: 'Object' .
    idVerbMin := objectMenu menuItem id.
    idVerbMax := idVerbMin + 100.

    resultReference := nil asValueReference.
    OLEDialogDLL current OleUIAddVerbMenu: nil
        _: nil
        _: aMenu window handle
        _: objectMenuIndex - 1
        _: idVerbMin
        _: idVerbMax
        _: false
        _: idVerbMax + 1   "idConvert"
        _: resultReference.
	^resultReference value!
create: clsid
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create an embedded object of the class specified by the Guid <clsid>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreate: clsid
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!   
createLink: anIMoniker
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create a linked object containing <anIMoniker>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreateLink: anIMoniker
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!   
createLinkToFile: aFileName
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create a linked object which references the file specified by <aFileName>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreateLinkToFile: aFileName
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!  
loadFromStorage: anIStorage oleClientSite: anIOleClientSite
        " Load an embedded or linked object from the storage <anIStorage>
        and set its client site to <anIOleClientSite>.
        Answer a new instance of the receiver on the loaded object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleLoad: anIStorage
        _: self iid
        _: anIOleClientSite
        _: resultReference.
    ^resultReference value!   
createFromFile: fullPathName
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create an embedded object from the contents of the file named <fullPathName>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreateFromFile: CLSID_NULL
        _: fullPathName
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!  
createFromData: anIDataObject
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create an embedded object from the data transfer object <anIDataObject>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreateFromData: anIDataObject
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!
createStaticFromData: anIDataObject
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create a static object from the data transfer object <anIDataObject>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreateStaticFromData: anIDataObject
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!   
createLinkFromData: anIDataObject
    rendering: oleRender
    format: aFormatEtc
    clientSite: anIOleClientSite
    storage: anIStorage
        " Create a linked object from the data transfer object <anIDataObject>.
        The caching that the container desires is specified by the OLERENDER value <oleRender>.
        Answer a new instance of the receiver on the object. "

    | resultReference |
    resultReference := self new asValueReference.
    OLEDLL current OleCreateLinkFromData: anIDataObject
        _: self iid
        _: oleRender
        _: aFormatEtc
        _: anIOleClientSite
        _: anIStorage
        _: resultReference.
    ^resultReference value!   
objectMenuGroupWidth: anInteger
		" Set the number of items in the objects's object menu group. "

	self longAtOffset: 12 put: anInteger.! 
setUpdateOnCall
		" Set the link update options for the linked object to update
		only when IOleObject::Update function is called.  This option
		supports the Manual link update option in the Links dialog box. "

	interface SetUpdateOptions: OLEUPDATE_ONCALL.! 
getSourceMoniker
        " Answer the moniker for the current link source."

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetSourceMoniker: resultReference.
    ^resultReference value! 
getSourceDisplayName
		" Answer the display name of the linked object's source."

	| resultReference |
	resultReference := nil asValueReference.
	interface GetSourceDisplayName: resultReference.
	^resultReference value! 
bindToSource
		" Bind the moniker contained within the linked object. "

    interface BindToSource: OLELINKBIND_EVENIFCLASSDIFF _: nil!   
getBoundSource
		" Answer the IUnknown of the object to which this link source is 
		currently connected, if any source is present."

	| resultReference |
	resultReference := IUnknown new asValueReference.
	interface GetBoundSource: resultReference.
	^resultReference value! 
getUpdateOptions
        " Answer the link update options previously set with IOleLink::SetUpdateOptions."

    | resultReference |
    resultReference := nil asValueReference.
    interface GetUpdateOptions: resultReference.
    ^resultReference value!   
update: aBindContext
		" Update the linked object with the latest data from the link source.
		This function finds the link source if necessary and gets a new
		presentation from the source.  This process may require the running
		of one or more object applications. "

	| hresult |
    interface Update: aBindContext.
	hresult = S_OK    " cache update info "
		ifFalse: [ OLEResultNotification hresult: hresult ]. 
!   
bindIfRunning
		" Bind the moniker contained within the linked object to the link source
		using IOleLink::BindToSource ( NULL, NULL ) if the source is currently running. "

    interface BindIfRunning!
bindToSourceEvenIfClassDiff
		" Bind the moniker contained within the linked object. "

    interface BindToSource: OLELINKBIND_EVENIFCLASSDIFF _: nil!
setUpdateOptions: updateOption
		" Set the link update options for the linked object. 
		The OLEUPDATE value in <updateOption> controls when 
		the data and/or presentation cache on the link consumer is updated. "

    interface SetUpdateOptions: updateOption! 
bindToSource: bindflags bindContext: aBindContext
		" Bind the moniker contained within the linked object. 
		The OLELINKBIND value in <bindflags> controls the behavior of the binding operation. "

    interface BindToSource: bindflags _: aBindContext!  
setUpdateAlways
		" Set the link update options for the linked object to update whenever possible.
		This option supports the Automatic link update option in the Links dialog box. "

	interface SetUpdateOptions: OLEUPDATE_ALWAYS! 
unbindSource
		" Unbind a currently linked object from the link source. "

    interface UnbindSource! 
setSourceMoniker: aMoniker classID: clsid
        " Set the moniker that indicates the source of the link inside of the
        linked object to <aMoniker>.  The Guid <clsid> specifies the class ID of the moniker."

    interface SetSourceMoniker: aMoniker _: clsid.!   
setSourceDisplayName: aDisplayName
		" Set the display name of the new link source to <aDisplayName>. "

    interface SetSourceDisplayName: aDisplayName! 
fileExtension
		" Answer the backing storage file extension. "

	^'stg'!   
changesHandled
        " Private - answer whether changes have been handled.
        Allow user to save or discard. "

    | saveChanges |
    self container modified 
        ifFalse: [ ^true ].   " no changes "
    saveChanges := MessageBox
        threeStateNotify: 'Please confirm'
        withText: 'Save changes to document?'.
    saveChanges isNil ifTrue: [ ^false ].  " cancelled "
    saveChanges ifTrue: [ self fileSave ].
    ^true!   
invokeSetObjectRects: lprcPosRect _: lprcClipRect
		" Private - invoke the IOleInPlaceObject::SetObjectRects function. "

	" HRESULT SetObjectRects(
            /* [in] */ LPCRECT lprcPosRect,
            /* [in] */ LPCRECT lprcClipRect); "

	<ole: 7 structIn structIn hresult>
	^self vtableDispatchFailed!
UIDeactivate
		" Invoke the IOleInPlaceObject::UIDeactivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT UIDeactivate( void); "

	<ole: 6 hresult>
	^self vtableDispatchFailed!   
SetObjectRects: positionRectangle _: clippingRectangle
		" Invoke the IOleInPlaceObject::SetObjectRects function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self
		invokeSetObjectRects: positionRectangle asParameter
		_: clippingRectangle asParameter! 
ReactivateAndUndo
		" Invoke the IOleInPlaceObject::ReactivateAndUndo function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT ReactivateAndUndo( void); "

	<ole: 8 hresult>
	^self vtableDispatchFailed!
InPlaceDeactivate
		" Invoke the IOleInPlaceObject::InPlaceDeactivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT InPlaceDeactivate( void); "

	<ole: 5 hresult>
	^self vtableDispatchFailed!
invokeDeactivateAndUndo
        " Private - invoke the IOleInPlaceSite::DeactivateAndUndo function for an external caller. "

	"virtual HRESULT __stdcall DeactivateAndUndo( void) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchDeactivateAndUndo.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult! 
OnPosRectChange: rect
	"Invoke the IOleInPlaceSite::OnPosRectChange function.
	Raise an exception if an error occurs.  Answer the result code."

	^self checkHresult: (self dispatchOnPosRectChange: rect)!   
windowMenuGroupWidth
		" Answer the number of items in the container's window menu group. "

	^self longAtOffset: 16!  
pasteClientSite: aClientSite
        " Private - paste the contents of the clipboard into <aClientSite>. "

    | anIDataObject |
    anIDataObject := IDataObject getClipboardObject.
    anIDataObject isNil
        ifTrue: [ ^nil ].  " clipboard doesn't contain OLE object "
    [
	CursorManager execute
		changeFor: [
    		aClientSite pasteEmbeddedObject: anIDataObject.
			anIDataObject release.
		].
    ]
        on: OLEError
        do: [ :ex |
			anIDataObject notNil
				ifTrue: [ anIDataObject release ].
			aClientSite deleteContent.
			self displayWarning: ex description titled: 'Paste Object Problem' ].
!
hwndFrame
        " Answer the container's frame window handle. "

    ^self handleAtOffset: 8!
getNextSiteName
		" Answer a unique name for a new client site in the receiver. "

	^self generateSiteName

!
releaseResources
	" Private - release resources associated with the receiver. "

	| interfaceToRelease |

	"Note: not using accessors for activeObject because of more stringent release requirements."
	activeObject == nil
		ifFalse:
			[interfaceToRelease := activeObject.
			activeObject := nil.
			interfaceToRelease release].
	super releaseResources.!  
saveDocument
        " Commit changes to current compound document storage. "

    self saveAllSites.
    self storage commit.
    self clearModified.
!
signatureStreamName
        " Private - Answer the file signature stream name in the backing storage. "

    ^'File Signature'!
objectListStreamName
        " Private - Answer the contained object list stream name in the backing storage. "

    ^'Object List'!   
window
        " Answer the window in which the receiver is being viewed. "

    ^window!  
LockContainer: fLock
        " Private - implement the IOleContainer::LockContainer function.
		Used by an embedded object to manually control the running of its container.
        The boolean <fLock> specifies  whether to lock (true) or unlock (false) the container.
		Answer the result code. "

        "The container must keep track of whether and how many calls to LockContainer
       (true) have been made. Each call to LockContainer with fLock set to true must be
        balanced by a call to LockContainer with fLock set to false. Object applications
        typically need not call LockContainer; the default handler makes these calls
        automatically for object applications implemented as .EXEs as the object transitions to
        and from the running state. Object applications not using the default handler,
       such as DLL object applications, must make the calls directly. "

	^self unimplementedFunction!  
activeObject
		"Answer the IOleInPlaceActiveObject interface of the
		current in-place active object or nil if none."

	^activeObject!
inPlaceAccelerators
        "Private - answer the accelerators to use during in-place activation."

    | virtKey accelerators menus accels |
    menus := self inPlaceActiveMenus.
    menus size = 0 ifTrue: [ ^nil ].
    accelerators := OrderedCollection new.
    menus do: [: each |
        accels := each accel.
        accels size > 0 ifTrue: [
            accels do: [: accelArray |
                ( accelArray isArray and: [ accelArray size = 2 ] )
                    ifTrue: [
                        ( ( accelArray at: 1 ) notNil and: [ ( accelArray at: 2 ) notNil ] )
                            ifTrue: [
                                virtKey := ( ( accelArray at: 2 ) bitAnd: Fcontrol ) > 0
                                    ifTrue: [ ( accelArray at: 2 ) | Fvirtkey ] "must add this flag for control characters."
                                    ifFalse: [ accelArray at: 2 ].
                                accelerators add: ( Array with: virtKey with: ( accelArray at: 1 ) ) ] ] ] ] ].
    ^accelerators!
frameResizeBorder: borderRectangle
		"The frame has been resized, notify the object that it needs
		to resize its border space. Note, this will cause all sites to be resized."

    | inPlaceFrame |
    inPlaceFrame := self interfaceForIID: IID_IOleInPlaceFrame.
    activeObject
        resizeBorder: borderRectangle
        uiWindow: inPlaceFrame
        isFrameWindow: true! 
showObjects: aBoolean
        " Private - Render the OLE standard UI show object type effect on the object in the receiver.
        The flag <aBoolean> specifies whether to set or remove the display effect. "

    showObjects := aBoolean.
    self sites do: [ :aSite | aSite showObjectType: aBoolean ].!  
showObjects
        " Private - Answer true if the receiver show objects option is enabled. "

    ^showObjects!   
windowGetBorder: rectRef
		" Private - Set the values of <rectangle> to the window border."

    rectRef value: window rectangle.
    ^S_OK!  
frameWindow
        "Private - answer the receiver's top most frame window."

    ( Smalltalk includesKey: #MDISystem )
		ifTrue: [
			( Smalltalk at: #MDISystem ) isActive
				ifTrue: [ ^window frame ] ].
    ^window! 
windowSetActiveObject: activeObjectInterface _: objectName
		" Private - Set the active object to <activeObject>. Its name is <objectName>."

    activeObject notNil ifTrue: [ activeObject release ].
    activeObject := activeObjectInterface.
    activeObjectInterface notNil ifTrue: [ activeObject addRef ].
    ^S_OK! 
frameSetMenu: sharedMenu _: olemenu _: hwndActiveObject
		" Private - Set the menubar to <sharedMenu>, unless it is nil in which case restore the
		original (non in-place active) menubar.  Call OleSetMenuDescriptor to install/uninstall
		the OLE dispatching code."
 
    | hMenu |
    sharedMenu notNil
        ifTrue: [
            hMenu := sharedMenu.
            originalMenu := UserLibrary getMenu: self frameWindow handle  ]
        ifFalse: [    "restore original menubar"
            originalMenu == nil
                ifTrue: [^S_OK].
            hMenu := originalMenu.
            originalMenu := nil ].

    UserLibrary setMenu: self frameWindow handle menu: hMenu.
    IOleInPlaceFrame
        oleSetMenuDescriptor: olemenu
            hwndFrame: self frameWindow handle
            hwndActiveObject: hwndActiveObject
            oleInPlaceFrame: nil
            oleInPlaceActiveObject: nil.
    ^S_OK! 
activeObject: anInterface
		"Set the IOleInPlaceActiveObject interface of the current
		in-place active object to <anInterface>."

	activeObject == nil
		ifFalse: [activeObject release].
	activeObject := anInterface.
	activeObject == nil
		ifFalse: [activeObject addRef]!   
clearAllSites
        " Private - clear all sites in the receiver. "

    sites do: [ :aSite | aSite clearContent ].!  
getHandleOfAcceleratorTable
        " Private - Answer the handle of the accelerator table.
		Create an accelerator table if one does not exist."

    haccel isNil
		ifTrue: [ haccel := self createAcceleratorTable ].
	^haccel!  
inPlaceActiveMenus
        "Private - answer the File, Container, and Window ( if MDI mode ) menus."

    | menu |
    menu := self frameWindow menuWindow menuTitled: 'File'.
    menu isNil ifTrue: [ ^nil ].

    self ISSUE.  "Note from Lam: The following code is incomplete, its purpose is to
    collect all the container menus not just the file menu. [JK 09-Nov-95]"

    "
    menus := self frameWindow menuWindow menus.
    ^menus reject: [: m |
        title := m title reject: [:c| c = $& | (c = $~)].
        ( ( title equalsIgnoreCase: 'Edit' ) or: [
            ( title equalsIgnoreCase: 'View' ) or: [
            ( title equalsIgnoreCase: 'Insert' ) or: [
            title equalsIgnoreCase: 'Help' ] ] ] ) ]
    "
    ^Array with: menu
!
frameEnableModeless: bool
		" Private - Enable modeless dialog boxes if <bool> is <true>, disable otherwise."

	^self unimplementedFunction!   
setModified
        " Set the receiver to modified."

    self modified: true.!
generateSiteName: rootName
        " Private - Answer a unique site name in the context of the receiver. "

    | aSiteName count currentSiteNames |
	currentSiteNames := self sites collect: [ :aClientSite | aClientSite name ].
    count := 1.
    [ currentSiteNames includes: 
        ( aSiteName := rootName, count printString ) ]
            whileTrue: [ count := count + 1 ].
    ^aSiteName

!   
deactivateInPlaceObject: aPoint
        "Deactivate the current active in-place object. Triggered by a button down in
         one of the container's child windows. <aPoint> is the mouse location of the
         button down relative the container window."

    | inPlaceActiveSite child |
    inPlaceActiveSite := sites detect: [: site | site isInPlaceActivated ] ifNone: [ ^nil ].
    child := Notifier findWindow: ( UserLibrary
        windowFromPoint: ( aPoint mapToScreen: window ) asParameter ).
    child isNil ifTrue: [ ^ nil ].
    inPlaceActiveSite sitePane == child ifFalse: [ inPlaceActiveSite deactivateInPlaceObject ]
!   
closeDocument
        " Private - close current compound document storage without committing changes. "

    self clearAllSites.
    self releaseDocument.

!   
clearModified
        " Clear the receiver's modified flag."

    self modified: false.!   
modified
        " Answer whether the receiver's has been modified
        since it was loaded or last saved. "

    modified ifTrue: [ ^true ].
    sites do: [ :aSite |
        aSite isStateModified
            ifTrue: [ ^true ] ].
    ^false!  
windowContextSensitiveHelp: enterHelpMode
		" Private - Enter help mode if <enterHelpMode> is <true>, exit otherwise."

	^self unimplementedFunction!  
destroyAcceleratorTable
        " Private - Destroy the accelerator table used during in-place activation."

    ( haccel notNil and: [ haccel isValid ] )
        ifTrue: [ UserLibrary destroyAcceleratorTable: haccel ].!  
createInterfaceForIID: iid
        " Private - Answer a new instance of the interface identified by <iid>
        on the receiver.  Answer nil if the interface is not supported. "

    iid = IID_IOleContainer
        ifTrue: [ ^IOleContainer on: self ].
    iid = IID_IOleInPlaceFrame
        ifTrue: [ ^self createInPlaceFrameInterface ].
    iid = IID_IOleInPlaceUIWindow
        ifTrue: [ ^self createInPlaceUIWindowInterface ].
    ^nil!   
loadAllSites
        " Private - load all sites in the receiver from the storage. "

    sites do: [ :aSite |
        aSite loadObjectFromStorage.
        aSite displayDocument ].! 
gettingFocus
        " The container is getting focus. If the receiver has an in-place active
         object, set the focus to the object's window. "

    | windowHandle |
    activeObject notNil ifTrue: [
        windowHandle := activeObject getWindow.
        UserLibrary setFocus: windowHandle asParameter ].

!  
close
        " Private - close the receiver and its sites."

	self
		destroyAcceleratorTable;
		closeDocument;
		removeAllSites.
	self window container: nil.
	self window: nil.!
newDocumentFile: aFileName
        " Create a new compound document storage in the
        file system named <aFileName>. "

    storage notNil
        ifTrue: [ self closeDocument ].
    self storage: ( OLECompoundFile newFile: aFileName ).
    self clearModified.! 
newDocumentFile
        " Create a new temporary compound document storage in the
        file system named <aFileName>. "

    storage isNil
        ifFalse: [ self closeDocument ].
    self storage: OLECompoundFile createTemporaryFile.
    self clearModified.! 
sites
		" Private - answer the sites in the receiver. "

	^sites!  
frameSetBorderSpace: borderWidths
        " Private - Adjust the border to accomadate the requested <borderWidths>."

    | rect |
    borderWidths notNil
        ifTrue: [
            rect := self frameWindow rectangle.
            rect := rect insetBy: borderWidths.
            self frameWindow children size > 0 ifTrue: [
                self frameWindow children do: [: child | child resize: rect ] ] ].
    ^S_OK
!   
saveAllSites
        " Private - save all sites in the receiver. "

    sites do: [ :aSite |
        aSite isStateModified
            ifTrue: [ aSite saveObject ] ].!  
defaultSiteNamePrefix
		" Private - answer the default client site name prefix. "

	^'Object'! 
windowGetWindow: reference
		" Private - Put the window's WindowHandle into <reference>."

	reference value: window handle.
	^S_OK!   
frameRequestBorderSpace: borderwidths
		" Private - Adjust the border to accomadate the requested <borderwidths>."

    ^S_OK! 
storage: aStorage
		" Set the receiver's storage to <aStorage>. "

	storage := aStorage.!  
storage
		" Answer the receiver's storage. "

	^storage!   
modified: aBoolean
        "Set the receiver's modified state to <aBoolean>."

    modified := aBoolean.!  
registerSite: aSiteObject
		" Register <aSiteObject> as being contained in the receiver. "

	aSiteObject container: self.
	self sites add: aSiteObject.!  
window: aTopPane
        " Specify the window in which the receiver is being viewed. "

    window := aTopPane.!   
removeSite: aSiteObject
        " Private - remove <aSiteObject> from being contained in the receiver. "

    self sites remove: aSiteObject 
		ifAbsent: [ 
			OLEDevelopmentWarning signal: 'Request to remove unregistered site object from container.' ].
    aSiteObject container: nil.!  
frameSetActiveObject: activeObjectInterface _: objectName
		" Private - Set the active object to <activeObject>. Its name is <objectName>.
     <activeObject> and <objectName> are nil when deactivating."

    activeObject notNil ifTrue: [ activeObject release ].
    activeObject := activeObjectInterface.  "set to nil if interface is nil"
    activeObjectInterface notNil ifTrue: [ activeObject addRef ].
    ^S_OK
! 
initialize
        " Private - initialize the receiver. "

    sites := OrderedCollection new.
    showObjects := false.
    modified := false.
    super initialize.!  
frameContextSensitiveHelp: enterHelpMode
		" Private - Enter help mode if <enterHelpMode> is <true>, exit otherwise."

	^self unimplementedFunction!   
openDocumentFile: aFileName signature: aString
        " Open an existing compound document storage in the file system name <aFileName>
         with an identifying file signature stream containing <aString>. "

    | aDocFile validDocFile aStream |
    storage notNil
        ifTrue: [ self closeDocument ].
    aDocFile := OLECompoundFile pathName: aFileName.
    validDocFile := false.
    ( aDocFile streamNames includes: self signatureStreamName )
        ifTrue: [
            aStream := ( aDocFile openStream: self signatureStreamName ) asStream.
            validDocFile := ( aStream contents = aString ).
            aStream release ].
    validDocFile
        ifFalse: [
            aDocFile release.
            ^false ].
    self
        storage: aDocFile;
        clearModified;
        displayDocument.
    ^true! 
getCountOfAcceleratorTable
        " Private - Answer the number of accelerators available.
		Answer 0 if  an accelerator table does not exist."

    ^( haccel notNil and: [ haccel isValid ] )
        ifTrue: [ UserLibrary copyAcceleratorTable: haccel to: nil count: 0  ]
        ifFalse: [ 0 ].!
displayDocument
        " Private - Display the document in the container window. "

    " demand-load sites at first view (lazy loading) "
    sites do: [ :aSite |
        aSite setLoadOnReference ].
    self window realInvalidateRect: nil. "Force site to load if visible."! 
saveDocumentFile: aFileName signature: aString
        " Save the content of the container to a new compound document storage file name <aFileName>.
         with an identifying file signature stream containing <aString>.  "

    | newStorage aStream |

    newStorage := OLECompoundFile newFile: aFileName.
    self storage copyTo: newStorage.
    ( newStorage streamNames includes: self signatureStreamName )
        ifFalse: [
            aStream := ( newStorage createStream: self signatureStreamName ) asStream.
            aStream nextPutAll: aString.
            aStream commit.
            aStream release ].
    newStorage commit.

    self closeDocument.
    self
        storage: newStorage;
        clearModified;
        displayDocument.
! 
createInPlaceUIWindowInterface
		"Private - Answer an IOleInPlaceUIWindow on an IOleInPlaceUIWindowImplementation
		that forwards its callbacks to the receiver."

	^IOleInPlaceUIWindow on: self
			selectors: self standardIUnknownSelectors, #(
				#windowGetWindow:
				#windowContextSensitiveHelp:
				#windowGetBorder:
				#windowRequestBorderSpace:
				#windowSetBorderSpace:
				#windowSetActiveObject:_:)!  
name: aString
		" Set the receiver's name to <aString>. "

	name := aString.!  
name
		" Answer the receiver's name. "

	^name!
containsLinkObject
        " Answer whether the receiver contains any linked object. "

    sites do: [ :aSite | 
		aSite containsLinkObject
			ifTrue: [ ^true ] ].
	^false!   
frameRemoveMenus: hmenuShared
		" Private - Remove the container's menus from <hmenuShared>."

    hmenuShared isNil ifTrue: [ ^NOERROR ].
    [  ( UserLibrary getMenuItemCount: hmenuShared ) > 0  ]
        whileTrue: [ UserLibrary removeMenu: hmenuShared position: 0 flag: MfByposition ].
    ^S_OK


!  
releaseDocument
        " Private - release current compound document storage without committing changes. "

    | interfaceBeingReleased |
    storage notNil
        ifTrue: [
            interfaceBeingReleased := storage.
            storage := nil.
            interfaceBeingReleased release ].!
removeAllSites
        " Private - remove all sites registered with the receiver. "

    sites do: [ :aSite | self removeSite: aSite ].!   
createInPlaceFrameInterface
		"Private - Answer an IOleInPlaceFrame on an IOleInPlaceFrameImplementation
		that forwards its callbacks to the receiver."

	^IOleInPlaceFrame on: self
			selectors: self standardIUnknownSelectors, #(
				#frameGetWindow:
				#frameContextSensitiveHelp:
				#frameGetBorder:
				#frameRequestBorderSpace:
				#frameSetBorderSpace:
				#frameSetActiveObject:_:
				#frameInsertMenus:_:
				#frameSetMenu:_:_:
				#frameRemoveMenus:
				#frameSetStatusText:
				#frameEnableModeless:
				#frameTranslateAccelerator:_:)!  
generateSiteName
        " Private -  Answer a unique site name in the context of the receiver. "

    ^self generateSiteName: self defaultSiteNamePrefix
!   
frameInsertMenus: sharedMenu _: widthsRef
        " Private - Insert the container's menus into <sharedMenu> and fill <widthsRef>
        elements 0, 2, & 4 with the number of items in the File, View, and Window menus."

    | menuWidths menus |
    menus := self inPlaceActiveMenus.
    menus size = 0 ifTrue: [^self unimplementedFunction].
    menus do: [: each |
        UserLibrary
            appendMenu: sharedMenu
            flags: MfByposition | MfPopup
            id: each window handle
            contents: each title asParameter ].
    menuWidths := OLEStructure createStructureNamed: #OLEMENUGROUPWIDTHS.
    menuWidths
        fileMenuGroupWidth: 1;
        containerMenuGroupWidth: 0;
        windowMenuGroupWidth: 0.
    widthsRef value: menuWidths.
    ^S_OK! 
windowSetBorderSpace: borderWidths
		" Private - Adjust the border to accomadate the requested <borderwidths>."

    | rect |
    borderWidths notNil ifTrue: [
        rect := window rectangle.
        rect := rect insetBy: borderWidths.
        sites do: [: siteObject | siteObject sitePane resize: rect ] ].
    ^S_OK
!
createAcceleratorTable
        " Private - Create an accelerator table for use during in-place activation.
         Answer the handle of the accelerator table."

    | accelerators accel accelArray |
    ( accelerators := self inPlaceAccelerators ) isNil ifTrue: [ ^nil ].
    accelArray := Array new: accelerators size.
    1 to: accelArray size do: [: i |
        accel := ExternalBuffer new: 6.
        accel
            uShortAtOffset: 0 put: ( ( accelerators at: i ) at: 1 );
            uShortAtOffset: 2 put: ( ( accelerators at: i ) at: 2 );
            uShortAtOffset: 4 put: 256 + i.
        accelArray at: i put: accel ].
    accel := WinStructArray fromCollection: accelArray.
    ^ExternalHandle fromInteger: (
        UserLibrary createAcceleratorTable: accel asParameter size: accelArray size ).
! 
ParseDisplayName: aDisplayName
	_: aBindContext 
	_: charsConsumedReference
	_: resultReference
        " Private - Parse the object display name <aDisplayName> into a moniker to the object.
        <aBindContext> points to the bind context to be used to accumulate bound objects.
        <charsConsumedReference> points to the number of characters parsed 
        from the display name.  Answer the moniker. "

	^self unimplementedFunction!
frameGetWindow: reference
		" Private - Put the window's WindowHandle into <reference>."

    reference value: self frameWindow handle.
	^S_OK!   
frameSetStatusText: string
		" Private - Display <string> in the status pane."

	^self unimplementedFunction!  
frameGetBorder: rectRef
		" Private - Set the values of <rectangle> to the window border."

    rectRef value: self frameWindow rectangle.
    ^S_OK
!   
EnumObjects: grfFlags _: resultReference
        " Private - implement the IOleContainer::EnumObjects function.
		Enumerate the objects in this container with OLECONTF enumeration
		values <grfFlags>.  Obtain a pointer to a new IEnumUnknown interface 
		and store it into the <resultReference>. 
		Answer the result code. "

       " EnumObjects should be implemented to allow programmatic clients the ability to find
        out what elements the container holds. It is not called in standard linking scenarios."

	"To do: remember to addRef the returned interface here "
	^self unimplementedFunction! 
windowRequestBorderSpace: borderwidths
		" Private - Adjust the border to accomadate the requested <borderwidths>."

    ^S_OK!
frameInfo
        " Private - answer an OLEINPLACEFRAMEINFO structure for use in
        in-place activation. "

    | frameInfo mdi handle count |
    mdi := ( Smalltalk includesKey: #MDISystem )
        ifTrue: [ ( Smalltalk at: #MDISystem ) isActive ]
        ifFalse: [ false ].
    handle := self getHandleOfAcceleratorTable.
    count := self getCountOfAcceleratorTable.
    frameInfo := OLEStructure createStructureNamed: #OLEINPLACEFRAMEINFO.
    frameInfo
        fMDIApp: mdi;
        hwndFrame: self frameWindow handle;
        haccel: handle;
        cAccelEntries: count.
    ^frameInfo!  
frameTranslateAccelerator: wmsg _: wID
        " Private - Translate the keystroke accelerator for the control."

    wmsg hwnd: self frameWindow handle asInteger.
    ^( Notifier translateAccelerator: wmsg )
        ifTrue: [  S_OK ]
        ifFalse: [ S_FALSE ]
!  
DiscardCache: discardOptions
		" Invoke the IOleCache2::DiscardCache function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT DiscardCache(
            /* [in] */ DWORD dwDiscardOptions); "

   <ole: 9 ulong hresult>
    ^self vtableDispatchFailed! 
UpdateCache: anIDataObject _: grfUpdf _: pReserved
		" Invoke the IOleCache2::UpdateCache function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeUpdateCache: anIDataObject asParameter
		_: grfUpdf 
		_: pReserved!  
invokeUpdateCache: pDataObject _: grfUpdf _: pReserved
		" Private - invoke the IOleCache2::UpdateCache function. "

	" HRESULT UpdateCache(
            /* [in] */ LPDATAOBJECT pDataObject,
            /* [in] */ DWORD grfUpdf,
            /* [in] */ LPVOID pReserved); "

    | hresult |
    <ole: 8 handle ulong structIn hresult>
    hresult := self dispatchFailureReason.
    hresult = CACHE_E_NOCACHE_UPDATED
        ifTrue: [ ^hresult ].
    ^self vtableDispatchFailed!   
dispatchOnUIDeactivate: bool
		" Private - dispatch the IOleInPlaceSite::OnUIDeactivate function."

	^( functionHandlers at: 11 ) evaluateWithArguments: ( Array
		with: bool )!  
fMDIApp: aBoolean
		" Specify whether this is an MDI application. "

	self booleanAtOffset: 4 put: aBoolean.!  
dispatchDiscardUndoState
		" Private - dispatch the IOleInPlaceSite::DiscardUndoState function. "

	^( functionHandlers at: 13 ) evaluate! 
invokeOleCreateMenuDescriptor: hmenuCombined _: lpMenuWidths
        "Private - WINOLEAPI_(HOLEMENU) OleCreateMenuDescriptor (
                                HMENU hmenuCombined,
                                LPOLEMENUGROUPWIDTHS lpMenuWidths); "

    <api: OleCreateMenuDescriptor handle structIn ulongReturn>
    ^self apiCallFailed!  
editCut
        " Private - Perform the Edit menu Cut operation. "

    | aClientSite |
    aClientSite := self activeSite.
    self 
        copyClientSite: aClientSite;
	    clearClientSite: aClientSite.! 
checkFlags
        "Private - check user action."

    self style: self flags.
    clsid := oleUIConvertStruct clsid.
    clsidNew := oleUIConvertStruct clsidNew.
    dvAspect := oleUIConvertStruct dvAspect.
    hMetaPict := oleUIConvertStruct hMetaPict.
    objectsIconChanged := oleUIConvertStruct fObjectsIconChanged.
    defaultLabel := oleUIConvertStruct defaultLabel.

!   
open
        " Invoke the standard OLE Convert dialog."

    ^self open: nil!  
dvAspect: anInteger
        " Set the aspect of the object to <anInteger>
        either DVASPECT_CONTENT or DVASPECT_ICON. "

    oleUIConvertStruct dvAspect: anInteger
!  
owner: anOwner
        "Sets the owner of the Dialog box."

    super owner: anOwner.
    owner isWindow
        ifTrue: [ parent := owner ]
        ifFalse: [
            parent := owner mainView.
            parent isWindow ifFalse: [
                parent := Notifier findWindow: WindowHandle queryActive ]].
    oleUIConvertStruct hWndOwner: parent asParameter.
!   
clsidActivateDefault: aGuid
        " Set the Class ID to use as the default class when 'Activate As' is selected to <aGuid>. "

    oleUIConvertStruct clsidActivateDefault: aGuid
! 
excludeClasses: aListOfCLSIDs
        " Set the list of classes to exclude from the list to <aListOfCLSIDs>. "

    oleUIConvertStruct excludeClasses: aListOfCLSIDs.
!   
defaultLabel: aString
        " Set the default label to use for the icon to <aString>. "

    oleUIConvertStruct defaultLabel: aString
! 
clsidNew
        "Answer the class ID that was chosen."

    ^clsidNew



!
isLinkedObject: aBoolean
        " Set to TRUE if the object is linked. "

    oleUIConvertStruct fIsLinkedObject: aBoolean
! 
flags
        "Answers the dialog box current flags value."

    ^oleUIConvertStruct dwFlags

!  
flags: dwFlags
        "Set the dialog box creation flags value."

    oleUIConvertStruct dwFlags: dwFlags.
    self style: dwFlags.



! 
dvAspect
        " Answer the cached aspect of the object. "

    ^dvAspect
! 
open: titleString
        " Invoke the standard OLE Convert dialog."

    | result |
    [ hLibrary := OLEDialogDLL current ]
        on: Error
        do: [
            MessageBox warning: 'Could not find ', OLEDialogDLL fileName asUppercase, '.
You must have this DLL to invoke the standard OLE Convert dialog.'.
            ^self ].
    parent isWindow ifFalse: [
        parent := Notifier findWindow: WindowHandle queryActive.
        oleUIConvertStruct hWndOwner: parent asParameter ].
    style notNil
        ifTrue: [ oleUIConvertStruct dwFlags: style ].
    titleString notNil
        ifTrue: [ oleUIConvertStruct dialogCaption: titleString ].

    result := hLibrary OleUIConvert: oleUIConvertStruct.
    result = OLEUI_SUCCESS
        ifTrue: [ self checkFlags ].
    self cleanUp.
! 
defaultLabel
        " Answer the cached default label to use for the icon. "

    ^defaultLabel
!
userType: aString
        " Set the user type name of the object to be converted or activated to <aString>. "

    oleUIConvertStruct userType: aString
! 
cleanUp
        "Private - Free oleUIConvertStruct."

    self style: self flags.
    oleUIConvertStruct release.
    oleUIConvertStruct := nil.
!  
hMetaPict: aHandle
        " Set the handle to the METAFILEPICT containing the icon to <aHandle>. "

    oleUIConvertStruct hMetaPict: aHandle
!  
hMetaPict
        "Answer the content of cached hMetaPict field."

    ^hMetaPict
!   
initialize
        "Private - Initialize oleUIConvertStruct."

    super initialize.
    oleUIConvertStruct := OLE_OLEUICONVERT new.
    self style: CF_DISABLEDISPLAYASICON.
! 
clsid: aGuid
        " Set the Class ID of the object to be converted or activated. "

    oleUIConvertStruct clsid: aGuid
!  
clsid
        " Answer the Class ID of the object to be converted or activated. "

    ^clsid



! 
clsidConvertDefault: aGuid
        " Set the Class ID to use as the default class when 'Convert To' is selected to <aGuid>. "

    oleUIConvertStruct clsidConvertDefault: aGuid
!
wFormat: anInteger
        " Set the data format of the object to be converted or activated to <anInteger>. "

    oleUIConvertStruct wFormat: anInteger
!
viewShowObjects
        " Private - Toggle the View menu Show Objects mode."

    | viewMenu |
    viewMenu := self container window menuTitled: 'View'.
    self container showObjects
        ifTrue: [
            viewMenu notNil ifTrue: [ viewMenu uncheckItem: #viewShowObjects ].
            self container showObjects: false ]
        ifFalse: [
            viewMenu notNil ifTrue: [ viewMenu checkItem: #viewShowObjects ].
            self container showObjects: true ]! 
dispatchDeactivateAndUndo
		" Private - dispatch the IOleInPlaceSite::DeactivateAndUndo function. "

	^( functionHandlers at: 14 ) evaluate!   
dataAdviseConnectionsEnumerator
		" Answer an enumerator on the collection of STATDATA structures which 
		describe the data advise connections currently established on the OLE object. "

	| resultReference |
	resultReference := ( IEnum forIID: IID_IEnumSTATDATA ) asValueReference.
	interface EnumAdvise: resultReference.
	^resultReference value!
unregisterAdviseSink: connectionToken
        "Delete an advisory connection previous established using IOleObject::Advise,
        identified by the connection token <connectionToken> returned by that operation. "

    interface Unadvise: connectionToken!  
getMiscStatus: dwAspect
        " Answer the receiver's OLEMISC status value specified by the DVASPECT
        value in <dwAspect>. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetMiscStatus: dwAspect _: resultReference.
    ^resultReference value!  
run
        " Place the receiver object into the running state if it is not already running. "

    OLEDLL current OleRun: self.!  
display: dvAspect on: aPane in: aRectangle
        " Draw the display aspect of the receiver specified by the
        DVASPECT value <dvAspect> on the window <aPane>.
        The rectangle <aRectangle> indicates the rectangle
        in which the object should  be drawn; this parameter controls
        the positioning and stretching of the object. "

    | hDC hresult |
    [ hDC := aPane getDC.
    hresult := OLEDLL current OleDraw: self
        _: dvAspect
        _: hDC
        _: aRectangle
    ] ensure: [
        hDC == nil ifFalse: [ aPane releaseDC: hDC ] ].
    ^hresult
!
getClipboardData
        " Query the receiver for a data transfer object that contains exactly what
        would have been passed to OleSetClipboard in a copy operation.
        Answer the new data object."

    | resultReference |
    resultReference := IDataObject new asValueReference.
    interface GetClipboardData: 0 _: resultReference.
    ^resultReference value!   
isStaticObject
        " Answer whether the receiver is a Static object."

    ^( ( self getMiscStatus: DVASPECT_CONTENT )
        bitAnd: OLEMISC_STATIC ) > 0!  
getContainerMoniker
		" Answer the moniker of the receiver's container (if any). "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: self defaultMonikerAssignment
		_: OLEWHICHMK_CONTAINER 
		_: resultReference.
    ^resultReference value!
isLinkObject
        " Answer whether the receiver is a Link object."

    ^( ( self getMiscStatus: DVASPECT_CONTENT )
        bitAnd: OLEMISC_ISLINKOBJECT ) > 0!
update
		" Ensure that any data or view caches maintained within the object are up-to-date. "

	interface Update!  
setContainedObject
        " Notify OLE that the receiver is contained as an embedded object. "

    OLEDLL current OleSetContainedObject: self _: true.!  
setContainerMoniker: aMoniker
		" Notify the object that its container's moniker is <aMoniker>. "

	interface SetMoniker: OLEWHICHMK_CONTAINER _: aMoniker!
getClientSite
        " Answer the receiver's current client site within its container. "

    | resultReference |
    resultReference := IOleClientSite new asValueReference.
    interface GetClientSite: resultReference.
    ^resultReference value!
isOnlyIconicObject
        " Answer whether the receiver is only an Iconic object."

    ^( ( self getMiscStatus: DVASPECT_CONTENT )
        bitAnd: OLEMISC_ONLYICONIC ) > 0!
setClientSite: aClientSite
		" Set the client site within the container for the newly created or
		loaded embedded object to <aClientSite>.  Each embedded object 
		has an associated client site through which the object communicates 
		with its container.  IOleObject::SetClientSite must be called whenever
		an embedded object is created or loaded. "

	interface SetClientSite: aClientSite!
saveToStream: anIStream
        " Save the object to the stream object <anIStream>. "

    | anIPersistStream |
    anIPersistStream := self queryInterface: IID_IPersistStream.
    anIPersistStream isNil
        ifTrue: [ anIPersistStream := self queryInterface: IID_IPersistStreamInit ].
    anIPersistStream saveToStream: anIStream.
    anIPersistStream release.! 
getIconExtent
        " Answer the current extent of the object's icon. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetExtent: DVASPECT_ICON _: resultReference.
    ^resultReference value!  
getMoniker: dwAssign whichMoniker: whichMoniker
        " Answer a moniker which can be used to connect to the object.
        The OLEGETMONIKER value in <dwAssign> determines how the moniker is
        assigned. The OLEWHICHMK value in <whichMoniker> specifies the
        requested form of the moniker. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: dwAssign _: whichMoniker _: resultReference.
    ^resultReference value! 
doVerb: verbIndex
    message: lpmsg
    clientSite: anOleClientSite
    lindex: lindex
    hwndParent: hwndParent
    rectangle: aRectangle
        " Request the receiver to perform one of its verb identified by <verbIndex>. "

	interface DoVerb: verbIndex
		_: lpmsg
		_: anOleClientSite
		_: lindex
		_: hwndParent
		_: aRectangle!   
getObjectRelativeMoniker
		" Answer the relative moniker of the object within its container. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: self defaultMonikerAssignment
		_: OLEWHICHMK_OBJREL 
		_: resultReference.
    ^resultReference value!   
verbsEnumerator
		" Answer an enumerator on the collection of OLEVERB structures which 
		describe the object's verbs, in increasing order by verb number. "

	| hresult resultReference |
	resultReference := ( IEnum forIID: IID_IEnumOLEVERB ) asValueReference.
	hresult := interface EnumVerbs: resultReference.
	hresult = S_OK
		ifFalse: [ OLEResultNotification signal: hresult ].
	^resultReference value! 
setExtent: dwDrawAspect point: aPoint
        " Set the extent limits (in Himetrics) that an object has available
        in the container.  The DVASPECT value in <dwDrawAspect> specifies the
        aspect of the object and the <aPoint> specifies the extent of the object. "

    interface SetExtent: dwDrawAspect _: aPoint!
verbs
		" Answer a collection of OLEVERB structures which 
		describe the object's verbs, in increasing order by verb number. "

	| anEnumerator contents |
	anEnumerator := self verbsEnumerator.
	anEnumerator isNil
		ifTrue: [ ^#( ) ].
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!  
closePromptSave
        " Close the receiver object application and transition an embedded
        object back to the loaded state. Prompt whether the object should be
        saved.  Answer whether the user saved the object. "

	^( interface Close: OLECLOSE_PROMPTSAVE ) = S_OK  " false if cancelled "
!
close: saveOption
		" Close the receiver object application and transition an embedded
		object back to the loaded state. The OLECLOSE value in <saveOption>
		determines if the object is saved as part of the transition to the loaded state. "

	interface Close: saveOption! 
closeSaveIfDirty
        " Close the receiver object application and transition an embedded
        object back to the loaded state. Save the object if it is dirty. "

    interface Close: OLECLOSE_SAVEIFDIRTY!
getUserShortClassName
		" Answer the short name of the object's class as a user-presentable string. 
		The short class name is used in popup menus and the Links dialog box."

    | resultReference |
    resultReference := nil asValueReference.
    interface GetUserType: USERCLASSTYPE_SHORT _: resultReference.
    ^resultReference value! 
getExtent: dwDrawAspect
        " Answer the object's current extent, the extent that the object will actually use.
        The DVASPECT value in <dwDrawAspect> specifies the aspect of the object. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetExtent: dwDrawAspect _: resultReference.
    ^resultReference value! 
isRunning
        " Answer whether the receiver object is running. "

    ^OLEDLL current OleIsRunning: self.! 
setObjectRelativeMoniker: aMoniker
		" Notify the object that its container-relative moniker is <aMoniker>. "

	interface SetMoniker: OLEWHICHMK_OBJREL _: aMoniker!   
addVerbMenuTo: aMenu 
	whenVerbSelectedSend: verbSelector
	whenConvertSelectedSend: convertSelector
	to: anObject
		" Add the Object Verb menu for the receiver to <aMenu>.
		If the receiver has only one verb, add it directly to <aMenu>,
		otherwise create a cascaded submenu.  
		Optionally include the Convert... menu item.
		Answer the verb menu handle. "

	| objectMenu objectMenuIndex idVerbMin idVerbMax oleVerbs
	  resultReference |

    " Here is some special code to replicate in Smalltalk the representation of the real verb submenu
    added by the oleUIAddVerbMenu helper function, such that, the Windows wmCommand messages
    gets properly handled in the MenuWindow>>performMenuItem: code. "

	" Here we recreate the submenu each time because the active object may have changed.
        This is rather expensive but works for now. "

    objectMenu := ( aMenu getMenuItem: 'Object' ) submenu.
    objectMenuIndex :=  aMenu getIndex: 'Object' .
    idVerbMin := objectMenu menuItem id.
    idVerbMax := idVerbMin + 100.

	" Note: Cannot use deleteAll here because it assumes the menu was built 
		which is not the case here. This are kind of a dummy smalltalk menu."
	objectMenu items copy do: [ :mi | objectMenu deleteItem: mi label ].
	oleVerbs := self verbs.
	oleVerbs do: [ :anOleVerb |
		objectMenu
			appendItem: anOleVerb verbName
			selector: ( Message receiver: anObject
				selector: verbSelector
				arguments: ( Array with: anOleVerb iVerb ) ) ].
	convertSelector notNil
		ifTrue: [
                objectMenu
                    appendItem: '\uConvert...' replaceEscapeCharacters
                    selector: ( Message receiver: anObject selector: convertSelector ) ].
	idVerbMax := idVerbMin + oleVerbs size - 1.
	oleVerbs do: [ :anOleVerb | anOleVerb release ].

    resultReference := nil asValueReference.
    OLEDialogDLL current OleUIAddVerbMenu: self
        _: nil
        _: aMenu window handle
        _: objectMenuIndex - 1
        _: idVerbMin
        _: idVerbMax
        _: convertSelector notNil
        _: idVerbMax + 1   "idConvert"
        _: resultReference.
	^resultReference value! 
dataAdviseConnections
		" Answer a collection of STATDATA structures which describe
		the data advise connections currently established on the OLE object. "

	| anEnumerator contents |
	anEnumerator := self dataAdviseConnectionsEnumerator.
	contents := anEnumerator contents.
	anEnumerator release.
	^contents!
registerAdviseSink: anAdviseSink
        " Register an advise connection between the object and the
        advisory sink <anAdviseSink> through which the sink can
        be informed of close, save, rename and link source change
        events which happen in the object.
        Answer the connection token which identifies the advise connection (nil if not established). "

    | resultReference |
    resultReference := nil asValueReference.
    interface Advise: anAdviseSink _: resultReference.
    ^resultReference value
!  
advise: anAdviseSink
		" Create an advise connection between the object and the
		advisory sink <anAdviseSink> through which the sink can
		be informed of close, save, rename and link source change
		events which happen in the object.  
		Store the connection token into the <resultReference>. "

    | resultReference |
    resultReference := nil asValueReference.
    interface Advise: anAdviseSink _: resultReference.
    ^resultReference value!
saveToStorage: anIStorage sameAsLoad: fSameAsLoad
        " Save the object to the storage object <anIStorage>.
        The boolean <fSameAsLoad> is TRUE if <anIStorage>
        is the same storage object from which the object was loaded or created;
        it is FALSE if <anIStorage> is a different storage object. "

    | anIPersistStorage |
    anIPersistStorage := self queryInterface: IID_IPersistStorage.
    anIPersistStorage saveTo: anIStorage sameAsLoad: fSameAsLoad.
    anIPersistStorage release.!   
addVerbMenuTo: aMenu 
	whenVerbSelectedSend: aSelector
	to: anObject
		" Add the Object Verb menu for the receiver to <aMenu>.
		If the receiver has only one verb, add it directly to <aMenu>,
		otherwise create a cascaded submenu.  
		Do not include the Convert... menu item.
		Answer the verb menu handle. "

	^self addVerbMenuTo: aMenu 
		whenVerbSelectedSend: aSelector
		whenConvertSelectedSend: nil
		to: anObject!   
setHostNames: containerApplicationName documentName: containerDocumentName
		" Set the window title when the receiver object is open for editing.
		The string <containerApplicationName> is the user-presentable 
		name of the container application.  <containerDocumentName> is 
		the name of the container document that contains this object. "

	interface SetHostNames: containerApplicationName _: containerDocumentName! 
getUserClassID
		" Answer the class ID of the object. "

        "GetUserClassID returns the CLSID as the user knows it. For embedded
        objects, this is always the CLSID that is persistently stored and is returned
        by IPersist::GetClassID. For linked objects, this is the CLSID of the last
        bound link source."

    | resultReference |
    resultReference := nil asValueReference.
    interface GetUserClassID: resultReference.
    ^resultReference value!
initFromData: aDataObject creationFlag: creationFlag
		" Initialize the contents of the object with data from <aDataObject>.
		The boolean <creationFlag> is set to indicate the initial creation of the object;
		it is false to indicate a more general programmatic data transfer. 
		Answer whether the object was successfully initialized. "

	^( interface InitFromData: aDataObject _: creationFlag _: 0 ) = S_OK!  
initFromData: aDataObject
        " Initialize the contents of the object with data from <aDataObject>.
		Answer whether the object was successfully initialized. "

	^( interface InitFromData: aDataObject _: false _: 0 ) = S_OK!  
createFromData: aDataObject
		" Initialize the contents of a newly created object with data from <aDataObject>. 
		Answer whether the object was successfully initialized. "

	^( interface InitFromData: aDataObject _: true _: 0 ) = S_OK!  
setContentExtent: aPoint
        " Set the extent limits (in Himetrics) that the object's
        content has available     in the container. "

    interface SetExtent: DVASPECT_CONTENT _: aPoint! 
getObjectFullMoniker
		" Answer the absolute moniker of the object. "

    | resultReference |
    resultReference := IMoniker new asValueReference.
    interface GetMoniker: self defaultMonikerAssignment
		_: OLEWHICHMK_OBJFULL 
		_: resultReference.
    ^resultReference value!   
setColorScheme: aPalette
		" Set the color palette that the object application should use when
		it edits the receiver object. The LOGPALETTE structure in
		<aWinLogPalette> specifies the recommended  palette. "

	interface SetColorScheme: aPalette!
getContentExtent
        " Answer the current extent of the object's content. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetExtent: DVASPECT_CONTENT _: resultReference.
    ^resultReference value! 
setMoniker: whichMoniker moniker: aMoniker
		" Notify the object of either its own moniker or it's container's moniker,
		according to the OLEWHICHMK value in <whichMoniker>. "

	interface SetMoniker: whichMoniker _: aMoniker!
doVerb: verbIndex
    clientSite: anOleClientSite
    hwndParent: hwndParent
    rectangle: aRectangle
        " Request the receiver to perform one of its verb identified by <verbIndex>. "

	interface DoVerb: verbIndex
		_: nil
		_: anOleClientSite
		_: 0
		_: hwndParent
		_: aRectangle!  
getUserApplicationName
		" Answer the name of the application servicing the class as a user-presentable string. 
		The application name is in the Result text in dialogs."

    | resultReference |
    resultReference := nil asValueReference.
    interface GetUserType: USERCLASSTYPE_APPNAME _: resultReference.
    ^resultReference value!  
getUserFullClassName
		" Answer the full name of the object's class as a user-presentable string. "

    | resultReference |
    resultReference := nil asValueReference.
    interface GetUserType: USERCLASSTYPE_FULL _: resultReference.
    ^resultReference value! 
closeNoSave
        " Close the receiver object application and transition an embedded
        object back to the loaded state. Do not save the object regardless
        of whether its dirty or not. "

    interface Close: OLECLOSE_NOSAVE!  
unadvise: connectionToken
		"Delete an advisory connection previous established using IOleObject::Advise,
		identified by the connection token <connectionToken> returned by that operation."

	interface Unadvise: connectionToken!  
defaultMonikerAssignment
		" Answer the default OLEGETMONIKER value used to obtaining monikers. "

	^OLEGETMONIKER_ONLYIFTHERE!
isUpToDate
        " Check the object recursively to determine whether it is up-to-date. "

	^interface IsUpToDate = S_OK! 
DeactivateAndUndo
		" Invoke the IOleInPlaceSite::DeactivateAndUndo function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT DeactivateAndUndo( void); "

	<ole: 13 hresult>
	^self vtableDispatchFailed! 
invokeOnPosRectChange: lprcPosRect
		" Private - invoke the IOleInPlaceSite::OnPosRectChange function. "

	" HRESULT OnPosRectChange(
            /* [in] */ LPCRECT lprcPosRect); "

	<ole: 14 structIn hresult>
	^self vtableDispatchFailed! 
CanInPlaceActivate
		" Invoke the IOleInPlaceSite::CanInPlaceActivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	"  HRESULT CanInPlaceActivate( void); "

	<ole: 5 hresult>
	^self vtableDispatchFailed!  
invokeGetWindowContext: ppFrame _: ppDoc _: lprcPosRect _: lprcClipRect _: lpFrameInfo
		" Private - invoke the IOleInPlaceSite::GetWindowContext function. "

	" HRESULT GetWindowContext(
            /* [out] */ IOleInPlaceFrame **ppFrame,
            /* [out] */ IOleInPlaceUIWindow **ppDoc,
            /* [out] */ LPRECT lprcPosRect,
            /* [out] */ LPRECT lprcClipRect,
            /* [out][in] */ LPOLEINPLACEFRAMEINFO lpFrameInfo); "

	<ole: 8 structOut structOut structOut structOut struct hresult>
	^self vtableDispatchFailed! 
invokeScroll: scrollExtant
		" Private - invoke the IOleInPlaceSite::Scroll function. "

	" HRESULT Scroll(
            /* [in] */ SIZE scrollExtant); "

	<ole: 9 structValue hresult>
	^self vtableDispatchFailed!   
DiscardUndoState
		" Invoke the IOleInPlaceSite::DiscardUndoState function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT DiscardUndoState( void); "

	<ole: 12 hresult>
	^self vtableDispatchFailed!
OnUIActivate
		" Invoke the IOleInPlaceSite::OnUIActivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnUIActivate( void); "

	<ole: 7 hresult>
	^self vtableDispatchFailed! 
OnPosRectChange: lprcPosRect
		" Invoke the IOleInPlaceSite::OnPosRectChange function.
		Raise an exception if an error occurs.  Answer the result code. "

	self invokeOnPosRectChange: lprcPosRect asParameter! 
OnInPlaceDeactivate
		" Invoke the IOleInPlaceSite::OnInPlaceDeactivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnInPlaceDeactivate( void); "

	<ole: 11 hresult>
	^self vtableDispatchFailed!   
Scroll: scrollExtent
		" Invoke the IOleInPlaceSite::Scroll function.
		Raise an exception if an error occurs.  Answer the result code. "

	self invokeScroll: scrollExtent asParameter!  
OnInPlaceActivate
		" Invoke the IOleInPlaceSite::OnInPlaceActivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnInPlaceActivate( void); "

	<ole: 6 hresult>
	^self vtableDispatchFailed!  
GetWindowContext: anIOleInPlaceFrameReference
    _: anIOleInPlaceUIWindowReference
    _: positionRectangleReference
    _: clippingRectangleReference
    _: frameInfoReference
        " Invoke the IOleInPlaceSite::GetWindowContext function.
        Raise an exception if an error occurs.  Answer the result code. "

    | anIOleInPlaceFrame anIOleInPlaceUIWindow
      positionRectangle clippingRectangle frameInfo hresult |
    anIOleInPlaceFrame := IOleInPlaceFramePointer forReturnValue.
    anIOleInPlaceUIWindow := IOleInPlaceUIWindowPointer forReturnValue.
    positionRectangle := WinRectangle new.
    clippingRectangle := WinRectangle new.
    frameInfo := OLEStructure forReturnValue: #OLEINPLACEFRAMEINFO.
    hresult := self invokeGetWindowContext: anIOleInPlaceFrame asParameter
        _: anIOleInPlaceUIWindow asParameter
        _: positionRectangle
        _: clippingRectangle
        _: frameInfo.
    anIOleInPlaceFrameReference value: anIOleInPlaceFrame.
    anIOleInPlaceUIWindow isValid  " NULL if doc and frame window are the same "
        ifTrue: [ anIOleInPlaceUIWindowReference value: anIOleInPlaceUIWindow ].
    positionRectangleReference value: positionRectangle asRectangle.
    clippingRectangleReference value: clippingRectangle asRectangle.
    frameInfoReference value: frameInfo.
    ^hresult!
OnUIDeactivate: fUndoable
		" Invoke the IOleInPlaceSite::OnUIDeactivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnUIDeactivate(
            /* [in] */ BOOL fUndoable); "

	<ole: 10 boolean hresult>
	^self vtableDispatchFailed! 
dispatchGetObjectStorage: anItemName _: aBindContext _: iid _: resultReference
		" Private - dispatch the IOleItemContainer::GetObjectStorage function. "

    ^( functionHandlers at: 8 ) evaluateWithArguments: ( Array
            with: anItemName
            with: aBindContext
            with: iid
            with: resultReference )!   
IsRunning: anItemName
		" Invoke the IOleItemContainer::IsRunning function.
		Raise an exception if an error occurs.  Answer the result code. "

     ^self checkHresult: 
		( self dispatchIsRunning: anItemName )! 
invokeGetObject: pszItem _: dwSpeedNeeded _: pbc _: riid _: ppvObject
        "Private - invoke the IOleItemContainer::GetObject function for an external caller. "

    "TO DO: Move the immediately following comment into an OLEContainerObject implementation..."
        " Private - Query the receiver for the object represented by the item pointed
        to by <lpszItem>. This function is called as part of the item moniker binding
        process. Store the address of the interface identified by the IID in <riid>
        into <anExternalAddress>. Increment the reference count for that interface.
        The value <dwSpeedNeeded> indicates how long the caller is willing to wait
        to get to the object. Valid values are from the enumeration BINDSPEED.
        The pointer <pbc> points to an instance of the IBindCtx interface which
        contains the acutal bind context.
        Answer the result.  If there is any error, store NULL into <anExternalAddress>
        and return the error."

    " HRESULT GetObject(
            /* [in] */ LPOLESTR pszItem,
            /* [in] */ DWORD dwSpeedNeeded,
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvObject); "

    | hresult anItemName anIBindContext iid resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackHeader ].

    pbc = 0  " NULL interface pointer "
        ifTrue: [ ^E_INVALIDARG ].
    ( pszItem isValid
    and: [ riid isValid
    and: [ ppvObject isValid ] ] )
        ifFalse: [ ^E_INVALIDARG ].
    anItemName := self stringAtAddress: pszItem.
    anIBindContext := self interfaceAtAddress: pbc
        type: IBindCtx.
    iid := self guidAtAddress: riid.
    self clearResultValueAtAddress: ppvObject.

    self ifOLETraceEnabled: [
        self oleTRACE: '    pszItem: ', anItemName.
        self logIID: iid ].

    resultReference := nil asValueReference.
    hresult := self dispatchGetObject: anItemName
        _: dwSpeedNeeded
        _: anIBindContext
        _: iid
        _: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppvObject put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'Interface: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult! 
GetObjectStorage: anItemName _: aBindContext _: iid _: resultReference
		" Invoke the IOleItemContainer::GetObjectStorage function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: 
		( self dispatchGetObjectStorage: anItemName _: aBindContext _: iid _: resultReference )! 
invokeIsRunning: pszItem
		"Private - invoke the IOleItemContainer::IsRunning function for an external caller. "

	" HRESULT IsRunning(
            /* [in] */ LPOLESTR pszItem); "

	| hresult anItemName |

	self ifOLETraceEnabled: [ self logCallbackHeader ].

	pszItem isValid 
		ifFalse: [ ^E_INVALIDARG ].
	anItemName := self stringAtAddress: pszItem.
	self ifOLETraceEnabled: [ self oleTRACE: '    pszItem: ', anItemName ].
	hresult := self dispatchIsRunning: anItemName.

	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult!   
GetObject: anItemName _: dwSpeedNeeded _: aBindContext _: iid _: resultReference
		" Invoke the IOleItemContainer::GetObject function.
		Raise an exception if an error occurs.  Answer the result code. "

    ^self checkHresult: 
		( self dispatchGetObject: anItemName _: dwSpeedNeeded _: aBindContext _: iid _: resultReference )!
dispatchIsRunning: anItemName
		" Private - dispatch the IOleItemContainer::IsRunning function. "

     ^( functionHandlers at: 9 ) evaluateWithArguments: ( Array
		with: anItemName )
!
invokeGetObjectStorage: pszItem _: pbc _: riid _: ppvStorage
        "Private - invoke the IOleItemContainer::GetObject function for an external caller. "

    "TO DO: Move the immediately following comment into an OLEContainerObject implementation..."
        " Private - Query the receiver for access to the object's storage using the
        interface pointed to by <riid>. <lpszItem> points to the item name for the
        object whose storage access is being requested. <pbc> points to the
        bind context, can be ignored by most container. Store the address of
        the interface identified by the IID in <riid> into <anExternalAddress>.
        Increment the reference count for that interface.
        Answer the result.  If there is any error, store NULL into <anExternalAddress>
        and return the error."

    " HRESULT GetObjectStorage(
            /* [in] */ LPOLESTR pszItem,
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppvStorage); "

    | hresult anItemName anIBindContext iid resultReference resultDescription |

    self ifOLETraceEnabled: [ self logCallbackHeader ].

    pbc = 0  " NULL interface pointer "
        ifTrue: [ ^E_INVALIDARG ].
    ( pszItem isValid
    and: [ riid isValid
    and: [ ppvStorage isValid ] ] )
        ifFalse: [ ^E_INVALIDARG ].
    anItemName := self stringAtAddress: pszItem.
    anIBindContext := self interfaceAtAddress: pbc
        type: IBindCtx.
    iid := self guidAtAddress: riid.
    self clearResultValueAtAddress: ppvStorage.

    self ifOLETraceEnabled: [
        self oleTRACE: '    pszItem: ', anItemName.
        self logIID: iid ].

    resultReference := nil asValueReference.
    hresult := self dispatchGetObjectStorage: anItemName
        _: anIBindContext
        _: iid
        _: resultReference.
    self ifOLETraceEnabled: [
        resultDescription := self interfaceResultDescription: resultReference ].
    ( HRESULT succeeded: hresult )
        ifTrue: [ self interfaceResultAtAddress: ppvStorage put: resultReference value ].

    self ifOLETraceEnabled: [
        self logReturnValue: 'Interface: ', resultDescription.
        self logCallbackExit: hresult ].
    ^hresult
! 
dispatchGetObject: anItemName _: dwSpeedNeeded _: aBindContext _: iid _: resultReference
		" Private - dispatch the IOleItemContainer::GetObject function. "

    ^( functionHandlers at: 7 ) evaluateWithArguments: ( ( Array
            with: anItemName
            with: dwSpeedNeeded
            with: aBindContext
            with: iid ), ( Array
            with: resultReference ) )!
releaseMetaPict: hMetaPict
        " Private - release the metafile <hMetePict> resource."

    ( hMetaPict notNil and: [ hMetaPict isValid ] ) 
		ifTrue: [
            ( GDILibrary deleteMetaFile: hMetaPict )
                ifFalse: [ self osWarning ] ].
! 
container: aContainer
		" Private - set the receiver's container object to <aContainer>. "

	self implementedBySubclass!   
invokeCanInPlaceActivate
        " Private - invoke the IOleInPlaceSite::CanInPlaceActivate function for an external caller. "

	"virtual HRESULT __stdcall CanInPlaceActivate( void) = 0"

	| hresult |
	self ifOLETraceEnabled: [ self logCallbackEntry ].
	hresult := self dispatchCanInPlaceActivate.
	self ifOLETraceEnabled: [ self logCallbackExit: hresult ].
	^hresult
!   
dispatchOnUIActivate
		" Private - dispatch the IOleInPlaceSite::OnUIActivate function. "

	^( functionHandlers at: 8 ) evaluate!  
fMDIApp
		" Answer whether this is an MDI application. "

	^self booleanAtOffset: 4!   
invokeOleDestroyMenuDescriptor: holemenu
        "Private - WINOLEAPI OleDestroyMenuDescriptor (HOLEMENU holemenu); "

    <api: OleDestroyMenuDescriptor handle none>
    ^self apiCallFailed!   
editCopy
        "Private - Perform the Edit menu Copy operation."

	self copyClientSite: self activeSite.!
lpOleUILinkContainer
        " Answer the IOleUILinkContainer interface used to manipulate links. "

    " this is an input value, so ownership is taken care of "
	^self interfaceAtOffset: 36 type: IOleUILinkContainer


!  
lpOleUILinkContainer: anInterface
        " Set the IOleUILinkContainer interface used to manipulate links to <anInterface>. "

    self interfaceAtOffset: 36 put: anInterface

!   
container
		" Private - answer the receiver's container object. "

	^container!
cb: anInteger
		" Set the size in bytes of the receiver. "

	self uLongAtOffset: 0 put: anInteger.!
invokeOleSetMenuDescriptor: holemenu _: hwndFrame _: hwndActiveObject _: lpFrame _: lpActiveObj
        "Private - WINOLEAPI OleSetMenuDescriptor (
                                HOLEMENU holemenu, HWND hwndFrame,
                                HWND hwndActiveObject,
                                LPOLEINPLACEFRAME lpFrame,
                                LPOLEINPLACEACTIVEOBJECT lpActiveObj); "

    <api: OleSetMenuDescriptor handle handle handle structIn handle hresult>
    ^self apiCallFailed!  
disableItems: itemList in: aMenu
		" Private - disable the specified items in <aMenu>. "

	itemList do: [ :aMenuItem | aMenu disableItem: aMenuItem ].!
cClsidExclude: anInteger
		" Private - Set the number of CLSID's in the exclude list to <anInteger>. "

	self uLongAtOffset: 60 put: anInteger.!   
lpClsidExcludeOffset
        " Private - answer the offset of the address of the list of CLSIDs to exclude from listing. "

	^64!  
cClsidExclude
		" Private - Answer the number of CLSID's in the exclude list. "

	^self uLongAtOffset: 60! 
releaseResources
		" Private - release resources owned by the receiver. "

    self
        releaseFileName;
        releaseObjectInterface;
        releaseClsidExclude.
	super releaseResources.!
cchFile: anInteger
		" Private - Set the size of lpszFile buffer: MAX_PATH "

	self uLongAtOffset: 56 put: anInteger.! 
cchFile
		" Private - Answer the size of lpszFile buffer: MAX_PATH "

	^self uLongAtOffset: 56!
fileName
		" Answer the name of the file containing the object to insert or link. "

	^self stringAtAddress: self lpszFile!
lpIStorage: anInterface
		" Set the IStorage used for the object to <anInterface>. "

	self interfaceAtOffset: 96 put: anInterface.!   
iid: iid
		" Set the IID of the interface to obtain on the new object to <iid>. "

	self guidAtOffset: 68 put: iid.!   
lpFormatEtc: aFormatEtc
		" Set the desired format to be inserted "

	self addressAtOffset: 88 put: aFormatEtc asParameter.!   
ppvObj: anAddress
        " Private - Set the address where the requested interface is to be returned to <anAddress>. "

	self addressAtOffset: 100 put: anAddress.
	ppvObj := anAddress.
	self needsFinalization.!  
iid
		" Answer the IID of the interface to obtain on the new object. "

	^self guidAtOffset: 68!   
lpszFile
        " Private - Answer the address of the file name containing the object to insert or link. "

    lpszFile notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 52 ) asInteger = lpszFile asInteger ].
    ^lpszFile!
allocateFileNameBuffer: anInteger
		" Allocate a buffer of <anInteger> characters for the file name return value. "

	| anAddress |
    anAddress := self allocateExternalStringBuffer: anInteger.
    self
        lpszFile: anAddress;
        cchFile: anAddress memorySize.!   
releaseFileName
        " Private "

    | anAddress |
    ( anAddress := self lpszFile ) notNil
        ifTrue: [
            anAddress free.
            self lpszFile: nil ].!  
lpIOleClientSite
		" Answer the IOleClientSite interface to be used for the object. "

	" this is an input value, so ownership is taken care of "
	^self interfaceAtOffset: 92 type: IOleClientSite!  
oleRender: anInteger
		" Set the rendering option to <anInteger>. "

	self uLongAtOffset: 84 put: anInteger.!  
oleRender
		" Answer the rendering option. "

	^self uLongAtOffset: 84!
lpszFile: anAddress
		" Private - Set the address of the file name containing the object to insert or link to <anAddress>. "

	self addressAtOffset: 52 put: anAddress.
	lpszFile := anAddress.!  
allocateObjectInterfaceBuffer
		" Allocate the object interface buffer in which an interface pointer is to be returned. "

	| anAddress |
    anAddress := ExternalAddress allocateMemory: OLEInterfacePointer sizeInBytes.
    self ppvObj: anAddress.! 
ppvObj
		" Private - answer the address of the interface of the inserted object. "

	ppvObj notNil
		ifTrue: [ self ASSERT: ( self addressAtOffset: 100 ) asInteger = ppvObj asInteger ].
	^ppvObj!  
lpIStorage
		" Answer the IStorage used for the object. "

	" this is an input value, so ownership is taken care of "
	^self interfaceAtOffset: 96 type: IStorage!
hMetaPict
		" Answer the metafile aspect (METAFILEPICT) of the inserted object "

	^self handleAtOffset: 108!  
sc
		" Answer the result of the creation call "

	^self uLongAtOffset: 104!
lpIOleClientSite: anInterface
		" Set the IOleClientSite interface to be used for the object to <anInterface>. "

	self interfaceAtOffset: 92 put: anInterface!
clsid
		" Answer the CLSID of the object to insert. "

	^self guidAtOffset: 36!
releaseObjectInterface
		" Private "

	interfacePointerReference notNil
		ifTrue: [ 
			interfacePointerReference release.
			interfacePointerReference := nil ].
	ppvObj notNil
		ifTrue: [
			ppvObj free.
			self ppvObj: nil ].!
objectInterface
        " Answer the requested object interface."

	( interfacePointerReference isNil and: [ ppvObj notNil ] )
		ifTrue: [
			self ASSERT: ( self addressAtOffset: 100 ) asInteger = ppvObj asInteger.
			interfacePointerReference := ( OLEInterface classForIID: self iid ifNone: [ IAnonymous ] )
				forTemporaryInterfacePointerAtAddress: ppvObj.
			interfacePointerReference := interfacePointerReference separateReference.  
				" OUT parameter that needs to be released "
			].
	^interfacePointerReference!  
fileName: aString
        " Set the name of the file containing the object to insert or link to <aString>. "

    self lpszFile notNil
        ifTrue: [ self releaseFileName ].
    self lpszFile: ( self stringExternalCopy: aString ).!   
fileNew
        " Private - Perform the File menu New operation. "

    self class open.!  
OleCreateMenuDescriptor: hmenuCombined _: anOleMenuGroupWidths
		" Create and return a descriptor for OLE to use when dispatching
		menu messages and command during in-place activation. 
		The handle of the combined menu created by the in-place active object
		is given by <hmenuCombined>.  The menu group information for
		the combined menu constructed by the container and the object
		is given by <anOleMenuGroupWidths>. "

	| hOleMenu |
	hOleMenu := self invokeOleCreateMenuDescriptor: hmenuCombined asParameter 
		_: anOleMenuGroupWidths.
	^hOleMenu = 0
		ifTrue: [ nil ]
		ifFalse: [WindowHandle fromInteger: hOleMenu ]!   
initialState: aPathName
		"Private - set the initial state of the receiver to <aPathName>. 
		The argument <aPathName> is the parameter to the #openOn: message
		sent to the class."

	fileName := aPathName.!  
dwFlags
        " Answer the flags value. "

    ^self uLongAtOffset: 28

!  
lpstrFormatName: anAddress
        " Private - set the address of the format name of the object/data to paste to <anAddress>. "

    self addressAtOffset: 20 put: anAddress.
    lpstrFormatName := anAddress.
    self needsFinalization.! 
dwFlags: anInteger
        " Set the flags value to <anInteger>. "

    self uLongAtOffset: 28 put: anInteger.

!
lpstrFormatName
        " Private - answer the address of the format name of the object/data to paste. "

    lpstrFormatName notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 20 ) asInteger = lpstrFormatName asInteger ].
    ^lpstrFormatName


!
releaseResultText
        " Private "

    | anAddress |
    ( anAddress := self lpstrResultText ) notNil
        ifTrue: [
            anAddress free.
            self lpstrResultText: nil ].!  
releaseResources
		" Private - release resources owned by the receiver. "

    self
        releaseFormatName;
        releaseResultText.
	super releaseResources.
!   
dwScratchSpace: anInteger
        " Set the scratch space value to <anInteger>. "

    self uLongAtOffset: 32 put: anInteger.

! 
formatName: aString
        " Set the format name of the object/data to paste to <aString>. "

    self lpstrFormatName notNil
        ifTrue: [ self error: 'previous format name string not deallocated' ].
    self lpstrFormatName: ( self stringExternalCopy: aString ).





!   
fmtetc: anOLEFormatEtc
        " Specify the acceptable format. "

    ^self bytesAtOffset: 0 put: anOLEFormatEtc contents

!
resultText: aString
        " Set the result text of the dialog to <aString>. "

    self lpstrResultText notNil
        ifTrue: [ self error: 'previous result text string not deallocated' ].
    self lpstrResultText: ( self stringExternalCopy: aString ).


!   
resultText
        " Answer the result text of the dialog. "

    ^self stringAtAddress: self lpstrResultText



! 
dwScratchSpace
        " Answer the scratch space value. "

    ^self uLongAtOffset: 32.

!  
fmtetc
        " Answer the acceptable format. "

    ^self structureAtOffset: 0 type: #FORMATETC! 
lpstrResultText: anAddress
        " Private - set the address of the result text of the dialog to <anAddress>. "

    self addressAtOffset: 24 put: anAddress.
    lpstrResultText := anAddress.
    self needsFinalization.!   
lpstrResultText
        " Private - answer the address of the result text of the dialog. "

    lpstrResultText notNil
        ifTrue: [ self ASSERT: ( self addressAtOffset: 24 ) asInteger = lpstrResultText asInteger ].
    ^lpstrResultText


!  
formatName
        " Answer the format name of the object/data to paste. "

    ^self stringAtAddress: self lpstrFormatName



!   
releaseFormatName
        " Private "

    | anAddress |
    ( anAddress := self lpstrFormatName ) notNil
        ifTrue: [
            anAddress free.
            self lpstrFormatName: nil ].
!
TranslateAccelerator: lpmsg
		" Invoke the IOleInPlaceActiveObject::TranslateAccelerator function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT TranslateAccelerator(
            /* [in] */ LPMSG lpmsg); "

	<ole: 5 structIn hresult>
	^self vtableDispatchFailed!  
EnableModeless: fEnable
		"Invoke the IOleInPlaceActiveObject::EnableModeless function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT EnableModeless(
            /* [in] */ BOOL fEnable); "

	<ole: 9 boolean hresult>
	^self vtableDispatchFailed!   
ResizeBorder: prcBorder _: pUIWindow _: fFrameWindow
		" Invoke the IOleInPlaceActiveObject::ResizeBorder function.
		Raise an exception if an error occurs.  Answer the result code. "

	^self invokeResizeBorder: prcBorder asParameter
		 _: pUIWindow asParameter
		_: fFrameWindow!
OnDocWindowActivate: fActivate
		" Invoke the IOleInPlaceActiveObject::OnDocWindowActivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnDocWindowActivate(
            /* [in] */ BOOL fActivate); "

	<ole: 7 boolean hresult>
	^self vtableDispatchFailed!   
invokeResizeBorder: prcBorder _: pUIWindow _: fFrameWindow
		" Private - invoke the IOleInPlaceActiveObject::ResizeBorder function. "

	" HRESULT ResizeBorder(
            /* [in] */ LPCRECT prcBorder,
            /* [unique][in] */ IOleInPlaceUIWindow *pUIWindow,
            /* [in] */ BOOL fFrameWindow); "

	<ole: 8 structIn handle boolean hresult>
	^self vtableDispatchFailed!
OnFrameWindowActivate: fActivate
		"Invoke the IOleInPlaceActiveObject::OnFrameWindowActivate function.
		Raise an exception if an error occurs.  Answer the result code. "

	" HRESULT OnFrameWindowActivate(
            /* [in] */ BOOL fActivate); "

	<ole: 6 boolean hresult>
	^self vtableDispatchFailed!  
enableModeless: aBoolean
		" Enable or disable the object's permission to display modeless dialog boxes. "

	interface EnableModeless: aBoolean!   
enableModelessDialogs
		" Notify the object that it is allowed to display modeless dialog boxes. "

	interface EnableModeless: true.!  
onFrameWindowActivate: aBoolean
		" Notify the active in-place object when the container's top-level frame 
		window gains or loses activation. "

	interface OnFrameWindowActivate: aBoolean!
onFrameWindowActivated
		" Notify the object when the container's top-level frame window is activated. "

	interface OnFrameWindowActivate: true.! 
resizeBorder: borderRectangle 
	uiWindow: uiWindow 
	isFrameWindow: isFrameWindow
		" Notify the object that it needs to resize its border space to the new
		outer rectangle <borderRectangle>.  The IOleInPlaceUIWindow whose
		border has changed is given in <uiWindow>, with <isFrameWindow>
		set according to whether this is a frame or a document window. "		

	interface ResizeBorder: borderRectangle _: uiWindow _: isFrameWindow.!   
onDocWindowDeactivated
		" Notify the object when the container's document window is deactivated. "

	interface OnDocWindowActivate: false.!   
translateAcceleratorIn: aHostMessage
		" Translate a message from the active object's message queue.
		Answer whether the message contained an accelerator that was translated. "

	^( interface TranslateAccelerator: aHostMessage ) = S_OK! 
translateAccelerator: aHostMessage
		" Translate a message from the active object's message queue. "

	interface TranslateAccelerator: aHostMessage!   
disableModelessDialogs
		" Notify the object that it is not allowed to display modeless dialog boxes. "

	interface EnableModeless: false.!
onDocWindowActivated
		" Notify the object when the container's document window is activated. "

	interface OnDocWindowActivate: true.!
onDocWindowActivate: aBoolean
		" Notify the active in-place object when the container's document 
		window gains or loses activation. "

	interface OnDocWindowActivate: aBoolean!   
onFrameWindowDeactivated
		" Notify the object when the container's top-level frame window is deactivated. "

	interface OnFrameWindowActivate: false.!
uiDeactivate
		" Deactivate and remove the user interface that supports in-place activation. "

	interface UIDeactivate!   
reactivateAndUndo
		" Reactivate a previously deactivated object, undoing its last state. "

	interface ReactivateAndUndo! 
setObjectRectangle: positionRectangle clippingRectangle: clippingRectangle
		" Notify the in-place object of how much of it is visible.
		The object's position rectangle and clipping rectangle
		are specified in client coordinates within the parent window. "

	interface SetObjectRects: positionRectangle _: clippingRectangle.!  
inPlaceDeactivate
		" Deactivate an active in-place object and discard its undo state. "

	interface InPlaceDeactivate!
canBeInPlaceActivated
		" Answer whether the container can activate the object in place. "

	^( interface CanInPlaceActivate ) = S_OK! 
onInPlaceDeactivate
		" Notify the container that the object is no longer active in place. "

	interface OnInPlaceDeactivate!  
scroll: scrollExtent
		" Notify the container to scroll the objects by the number of
		pixels specified by the Point <scrollExtent>. "

	interface scroll: scrollExtent!  
onInPlaceActivate
		" Notify the container that one of its objects is being activated in place. "

	interface OnInPlaceActivate!   
deactivateAndUndo
		" Notify the container that the user has invoked Undo just after activating the object. "

	interface DeactivateAndUndo!   
getWindowContext: anIOleInPlaceFrameReference 
	oleInPlaceUIWindow: anIOleInPlaceUIWindowReference
	positionRectangle: positionRectangleReference 
	clipRectangle: clipRectangleReference 
	frameInfo: frameInfoReference
		" Enable the in-place object to retrieve the window interfaces
		that form the window object hierarchy and the position
		in the parent window where the object's in-place
		activation window should be placed. "

	| inPlaceFrameRef inPlaceWindowRef |
	inPlaceFrameRef := IOleInPlaceFrame new asValueReference.
 	inPlaceWindowRef := IOleInPlaceUIWindow new asValueReference.
	interface GetWindowContext: inPlaceFrameRef 
		_: inPlaceWindowRef
		_: positionRectangleReference 
		_: clipRectangleReference 
		_: frameInfoReference.
	anIOleInPlaceFrameReference value: inPlaceFrameRef value.
	anIOleInPlaceUIWindowReference value: inPlaceWindowRef value.
!   
discardUndoState
		" Notify the container that it should discard its Undo state because 
		the active object is performing some action that would discard the 
		Undo state of the object. "

	interface DiscardUndoState!   
onPosRectChange: lprcPosRect
		" Notify the container that the in-place active object's extents have changed. "

	interface OnPosRectChange: lprcPosRect!  
onUIActivate
		" Notify the container that the object is about to be activated in-place
		and that the object is going to replace the container's main menu
		with the in-place composite menu. "

	interface OnUIActivate!  
onUIDeactivate: objectCanUndo
		" Notify the container that the in-place active object has been deactivated
		and the container should reinstall its user interface and take focus.
		The <objectCanUndo> flag is set if the object is able to undo changes. "

	interface OnUIDeactivate: objectCanUndo!
canInPlaceActivate
		" Determine whether the container can activate the object in place. "

	interface CanInPlaceActivate!