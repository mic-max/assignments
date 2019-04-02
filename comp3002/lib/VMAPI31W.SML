3.1.0.106
   
sizeInBytes
        "Private - Answer the default size in bytes."
    ^ 12! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector 
		fields: #(
			#second
			#minute
			#hour
			#day
			#month
			#year
			#isdst
			#tmzone
			)
		conversions: #(
			#asDate
			#asTime
			#asTimeStamp
		    )!
bcc: anOrderedCollection
		"Set the 'Bcc:' addressees instance variable."
	bcc := anOrderedCollection!  
to
		"Answer the 'To:' addressees."
	^to!   
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': '.
	self to notNil ifTrue: [
		aStream nextPutAll: 'to: '.
		self to do: [ :a | aStream nextPutAll: a name ] andBetweenDo: [ aStream nextPutAll: ', ' ].
		aStream nextPutAll: '; ' ].
	self cc notNil ifTrue: [
		aStream nextPutAll: 'cc: '.
		self cc do: [ :a | aStream nextPutAll: a name ] andBetweenDo: [ aStream nextPutAll: ', ' ] ]!
cc: anOrderedCollection
		"Set the 'Cc:' addressees instance variable."
	cc := anOrderedCollection! 
to: anOrderedCollection
		"Set the 'To:' addressees instance variable."
	to := anOrderedCollection! 
bcc
		"Answer the 'Bcc:' addressees."
	^bcc!
cc
		"Answer the 'Cc:' addressees."
	^cc!   
sizeInBytes
        "Private - Answer the default size in bytes."
    ^8!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
		#itemCode
		#flags
    )!
setupExtSupport
		"Private - Create an array of CMCXComSupport extension structures."

	| extList extSupport extSize extListSize extByteArray extAddr |
	
	ExtAddresses := OrderedCollection new. "Initialize class variable."
	extList := OrderedCollection new.

	"Request the message extension priority."
	extSupport := CMCXComSupport new
		itemCode: CMCXComPriority;
		flags: CMCExtRequired.

	extList add: extSupport.
		
	"Create a pointer to an array of extension structures."
	extSize := CMCXComSupport sizeInBytes.
	extListSize := extList size.
	( extListSize > 0 )
		ifTrue: [
			extByteArray := ByteArray new: (extListSize * extSize).
			1 to: extListSize do: [ :i |
				extByteArray replaceFrom: ((i - 1)*extSize + 1) to: (i*extSize) with: (extList at: i) contents startingAt: 1 ].
			extAddr := extByteArray copyToExternalMemory doesNotNeedFinalization ]
		ifFalse: [ extAddr := ExternalAddress new ].

	ExtAddresses add: extAddr.
	^extAddr!
logonUserProfile: aString password: aPasswordString
		"Establishes a session with the messaging service for the user aString with password aPasswordString."

    | id result session |

	id := ExternalLong new.

	result := MAPIDLL current
		cmcLogon: nil asParameter 
		user: aString asParameter 
		password: aPasswordString asParameter 
		charSet: nil asParameter
		uiId: 0
		cmcVersion: CMCVersion
		logonFlags: CMCLogonUiAllowed | CMCErrorUiAllowed
		session: id asParameter
		extensions: nil asParameter.

	result = 0
		ifTrue: [ 
			session := self new id: id asInteger.
			session folders: OrderedCollection new ].
	^session!  
logon
		"Establishes a session with the messaging service."

    | id result pExtArray session |

	id := ExternalLong new.

	pExtArray := self setupExtensionRequest.

	result := MAPIDLL current
		cmcLogon: nil asParameter 
		user: nil asParameter 
		password: nil asParameter 
		charSet: nil asParameter
		uiId: 0
		cmcVersion: CMCVersion
		logonFlags: CMCLogonUiAllowed | CMCErrorUiAllowed
		session: id asParameter
		extensions: pExtArray asParameter.

	( result = 0 and: [ self checkExtSupport: pExtArray ] )
		ifTrue: [ 
			session := self new id: id asInteger.
			session folders: OrderedCollection new ].
	ExtAddresses := nil.
	^session!  
checkExtSupport: anAddress
		"Private - Check the flags of the requested extensions and raise an error if one is not supported." 
	| ext extRef supportExt supportFlags |
	anAddress isValid
		ifTrue: [
			"Retrieve extension structure"
			ext := CMCExtension fromAddress: anAddress.
			extRef := ext itemReference.
			
			"Retrieve support extension structure"
			supportExt := CMCXComSupport fromAddress: extRef asExternalAddress.
			supportFlags := supportExt flags.

			( supportFlags & CMCXComSupported ) = 0 
				ifTrue: [ ^ true ]
				ifFalse: [ ^ MessageBox confirm: 'The Priority extension is not supported. Do you want to continue?' ] ]
!
logonUserProfile: aString
		"Establishes a session with the messaging service for the user aString."

    | id result session |

	id := ExternalLong new.

	result := MAPIDLL current
		cmcLogon: nil asParameter 
		user: aString asParameter 
		password: nil asParameter 
		charSet: nil asParameter
		uiId: 0
		cmcVersion: CMCVersion
		logonFlags: CMCLogonUiAllowed | CMCErrorUiAllowed
		session: id asParameter
		extensions: nil asParameter.

	result = 0
		ifTrue: [ 
			session := self new id: id asInteger.
			session folders: OrderedCollection new ].
	^session!  
setupExtensionRequest
		"Private - Create an array of CMCExtension structures."

	| extList ext extSize extListSize extByteArray extAddr externalAddresses refAddrExtSupport |

	refAddrExtSupport := self setupExtSupport.

	ext := CMCExtension new	
		itemCode: CMCXComSupportExt;
		itemData: 1;
		itemReference: refAddrExtSupport;
		extensionFlags: CMCExtRequired | CMCExtLastElement.

	extList := OrderedCollection new.
	extList add: ext.

	"Create a pointer to an array of extension structures."
	extSize := CMCExtension sizeInBytes.
	extListSize := extList size.
	( extListSize > 0 )
		ifTrue: [
			extByteArray := ByteArray new: (extListSize * extSize).
			1 to: extListSize do: [ :i |
				extByteArray replaceFrom: ((i - 1)*extSize + 1) to: (i*extSize) with: (extList at: i) contents startingAt: 1 ].
			extAddr := extByteArray copyToExternalMemory doesNotNeedFinalization ]
		ifFalse: [ extAddr := ExternalAddress new ].

	ExtAddresses add: extAddr.
	^extAddr!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
session: aMailSession
		"Private - set the receiver's session to aMailSession."
	session := aMailSession!   
name
		"Answer name of the receiver."
	^name!   
name: aString
		"Set name of the receiver."
	name := aString!   
renameTo: aString
		"Rename the receiver to aString."
	self name: aString!  
deleteMessage: aMailMessage
		"Delete aMailMessage from the receiver and the service provider."
	messages remove: aMailMessage ifAbsent: [ ^self ].

	"If the message id is nil, the message hasn't been sent yet, i.e. hasn't recieved a valid
	id, so that the message doesn't need to be removed from the service provider."

	aMailMessage id isNil 
		ifFalse: [ aMailMessage delete ]
		ifTrue: [ aMailMessage invalidate ]!   
messages
		"Answer summary information about all messages in the receiver."
	^messages! 
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': ', self name printString!
addMessage: aMailMessage
		"Add aMailMessage to the receiver."
	messages add: aMailMessage! 
initialize
		"Private - Initializes the folder to its default values."
	messages := OrderedCollection new.! 
messages: anOrderedCollection
		"Answer summary information about all messages in the receiver."
	anOrderedCollection isNil
		ifFalse: [	messages := anOrderedCollection ]!
newMessage
		"Answer a new MailMessage and add it to the receiver."
	| msg |
	msg := MailMessage new	
		initialize;
		session: self session.
	self addMessage: msg.
	^msg! 
invalidate
		"Private - Invalidate receiver."
	self initialize.
	name := nil!  
session
		"Private - answer the receiver's session."
	^session! 
new
		"Answer a new instance of the receiver."
	^super new initialize!  
session
		"Private - answer the receiver's session."
	^session! 
session: aMailSession
		"Private - set the receiver's session to aMailSession."
	session := aMailSession!   
name
		"Answer name of the receiver."
	^name!   
name: aString
		"Set name of the receiver."
	name := aString!   
open: aString
		"Open the address book named aString."
	| result pExtensionArray pRecipList counter |
	pExtensionArray := self setupLookupExtensions: aString.
	counter := ExternalLong new uLongAtOffset: 0 put: 0.
	pRecipList := ExternalAddress new.

	result := MAPIDLL current
		cmcLookUp: self session id
		recipientIn: nil asParameter
		lookUpFlags: CMCLookupAddressingUi
		uiId: 0
		count: counter asParameter
		recipinetOut: pRecipList asParameter
		lookUpExtensions: pExtensionArray asParameter.

	result = 0
		ifTrue: [ self addresseesFrom: pRecipList ]
		ifFalse: [ self session osError: result ]!
addressees
		"Answer the selected addressees from the address book as an instance of MailAddressList."
	^addressees!
retrieveAddressee: aRecipStruct
		"Private - Retrieve the addressee information from the structure and answer a MailAddressee instance."
	| addressee |
	addressee := MailAddressee new.
	addressee 
		name: aRecipStruct name;
		address: aRecipStruct address.

	aRecipStruct role = CMCRoleOriginator
		ifTrue: [ addressee role: 'originator' ]
		ifFalse: [ 
			aRecipStruct role = CMCRoleTo
				ifTrue: [ addressee role: 'To:' ]
				ifFalse: [
					aRecipStruct role = CMCRoleCc
						ifTrue: [ addressee role: 'Cc:' ]
						ifFalse: [ 
							aRecipStruct role = CMCRoleBcc
								ifTrue: [ addressee role: 'Bcc:' ]
								ifFalse: [ 
									aRecipStruct role =  CMCRoleAuthorizingUser
										ifTrue: [ addressee role: 'authorizer' ] ] ] ] ].
	
	aRecipStruct nameType = CMCTypeGroup
		ifTrue: [ addressee type: 'group' ]
		ifFalse: [ 
			aRecipStruct nameType = CMCTypeIndividual
				ifTrue: [ addressee type: 'individual' ]
				ifFalse: [ addressee type: 'unknown' ] ].
	^addressee!  
setupLookupExtensions: aString
		"Private - Answer the pointer to an array of CMCExtension structures and set the dialog title to aString."
	| extList extListSize ext extSize extByteArray extAddr str1 str2 refByteArray length refAddr |

	"Create a pointer to an array of two strings for the extension structure."
    str1 := aString.  "Caption for the AddressBook dialog. Not yet supported by MAPI beta 5."
    str2 := ''.  "Label for recipient field. Haven't discovered it yet in the MAPI beta 5."
    length := str1 size + str2 size .
    refByteArray := ByteArray new: length.
    refByteArray replaceFrom: 1 to: str1 size with: str1 startingAt: 1.
    refByteArray replaceFrom: (str1 size + 1) to: length with: str2 startingAt: 1.
	refAddr := refByteArray copyToExternalMemory doesNotNeedFinalization.
	externalAddresses add: refAddr.

	extList := OrderedCollection new.

	"Create extension structure for the address book feature."
	ext := CMCExtension new	
		itemCode: CMCXMsAddressUi;
		itemData: 2;
		itemReference: refAddr;
		extensionFlags: CMCExtLastElement.

	extList add: ext.
		
	"Create a pointer to an array of extension structures."
	extSize := CMCExtension sizeInBytes.
	extListSize := extList size.
	( extListSize > 0 )
		ifTrue: [
			extByteArray := ByteArray new: (extListSize * extSize).
			1 to: extListSize do: [ :i |
				extByteArray replaceFrom: ((i - 1)*extSize + 1) to: (i*extSize) with: (extList at: i) contents startingAt: 1 ].
			extAddr := extByteArray copyToExternalMemory doesNotNeedFinalization ]
		ifFalse: [ extAddr := ExternalAddress new ].
	externalAddresses add: extAddr.

	^extAddr!   
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': ', self name printString!
initialize
		"Private - Initialize to the default values."
	externalAddresses := Set new.
	addressees := MailAddressList new!  
addresseesFrom: pRecipientList
		"Private - Set the addressees inst var to an instance of MailAddressList."
	| recipListTo recipListCc recipListBcc recipient i recipientAddr |

	(recipientAddr := pRecipientList) isNil
		ifTrue: [ ^nil ].

	addressees := MailAddressList new.
	recipListTo := OrderedCollection new.
	recipListCc := OrderedCollection new.
	recipListBcc := OrderedCollection new.

	"The elements in the array are the recipients."
	recipient := CMCRecipient fromAddress: recipientAddr.
	i := 1.
	[ ( recipient recipFlags & CMCRecipLastElement) = 0 ]
		whileTrue: [ 
			recipient role = CMCRoleTo
				ifTrue: [ recipListTo add: ( self retrieveAddressee: recipient ) ]
				ifFalse: [
					recipient role = CMCRoleCc
						ifTrue: [ recipListCc add: ( self retrieveAddressee: recipient ) ]
						ifFalse: [ recipListBcc add: ( self retrieveAddressee: recipient ) ] ].
			recipient := CMCRecipient fromAddress: ( recipientAddr + ( i * (CMCRecipient sizeInBytes) ) ).
			i := i + 1 ].
	recipient role = CMCRoleTo
		ifTrue: [ recipListTo add: ( self retrieveAddressee: recipient ) ]
		ifFalse: [
			recipient role = CMCRoleCc
				ifTrue: [ recipListCc add: ( self retrieveAddressee: recipient ) ]
				ifFalse: [ recipListBcc add: ( self retrieveAddressee: recipient ) ] ].

	addressees 
		to: recipListTo asArray;
		cc: recipListCc asArray;
		bcc: recipListBcc asArray!
lookUp: aName
		"Look up addressing information for aName."

	| inRecipStruct count outRecipStruct result |

	inRecipStruct := CMCRecipient new initialize.
	inRecipStruct name: aName.

	count := ExternalLong new.
	outRecipStruct := ExternalAddress new.

	result := MAPIDLL current
		cmcLookUp: self session id 
		recipientIn: inRecipStruct asParameter
		lookUpFlags: CMCLookupDetailsUi | CMCErrorUiAllowed 
		uiId: 0 
		count: count asParameter
		recipinetOut: outRecipStruct asParameter
		lookUpExtensions: nil asParameter.

	result = 0
		ifTrue: [ 
			outRecipStruct isValid     "MAPI beta 5 doesn't return a valid value here."
				ifTrue: [^self retrieveAddressee: (CMCRecipient fromAddress: outRecipStruct ) ] 
				ifFalse: [^nil] ]
		ifFalse: [ self session osError: result ] !   
open
		"Open an address book."
	^( self open: '' )
!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
fromMessage: aMsg
        "Private - Fill a CMCMessage structure with the data provided by the aMsg."

	| cmcMsg |

	cmcMsg := self new.
	cmcMsg messageReference: aMsg id.
	cmcMsg messageType: nil.
	cmcMsg subject: aMsg subject.
	cmcMsg timeSent: aMsg timeSent.
	cmcMsg textNote: aMsg body.
	cmcMsg messageFlags: 0.

	cmcMsg addresseesFrom: aMsg.
	cmcMsg attachmentsFrom: aMsg.
	cmcMsg extensionsFrom: aMsg.

	^cmcMsg
! 
new
		"Answer a new instance of the receiver."
	^super new initialize!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^ 32 + (CMCTime sizeInBytes)! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
       #messageReference
		#messageType
		#subject
		#timeSent
		#textNote
		#recipients
		#attachments
		#messageFlags
		#messageExtensions
    )! 
messages
		"Answer summary information about all messages."
	self messages: ( self retrieveMessagesWithFlags: 0 ).
	^messages! 
newMessage
		"Answer a MailMessage for this session.
		For the Inbox the system is providing the messages.
		You cannot create a new one for the Inbox yourself."
	MessageBox message: 'You cannot create a new message for the Inbox.'.! 
unreadMessages
		"Answer summary information about all unread messages."
	^( self retrieveMessagesWithFlags: CMCListUnreadOnly )
! 
addMessage: aMailMessage
		"Add aMailMessage to the receiver. 
		For the Inbox the system is providing the messages and
		you cannot add them yourself."
	MessageBox message: 'You cannot add a message to the Inbox.'.!  
retrieveMessagesWithFlags: flags
		"Private - Retrieve the type of messages defined by flags."
	| countBuffer pResultList result count resultList message |
	countBuffer := ExternalLong new.
	pResultList := ExternalAddress new.

	result := MAPIDLL current
		cmcList: self session id 
		msgType: nil asParameter 
		listFlags: CMCErrorUiAllowed | flags
		seed: nil asParameter 
		count: countBuffer asParameter
		uiId: 0 
		msgResult: pResultList asParameter 
		listExtensions: nil asParameter.

	result = 0
		ifTrue: [  
			count := countBuffer asInteger.
			resultList := OrderedCollection new: count.
			0 to: count - 1 do: [ :i |
				message := ( CMCMessageSummary fromAddress: pResultList asExternalAddress + ( i * CMCMessageSummary sizeInBytes ) ) asMessage.

				message session: self session.
				resultList add: message ].
			^resultList ]
		ifFalse: [ self session osError: result ]
!
isUIAvailable
		"Queries if a UI is provided and available by the CMC implementation."
    | buffer result |

	buffer := ExternalLong new.

    result := MAPIDLL current cmcQueryConfiguration: self id 
		item: CMCConfigUiAvail 
		buffer: buffer asParameter 
		extensions: nil asParameter.

	^buffer asInteger > 0
	!   
inboxFolder
		"Answer the Inbox MailFolder."
	| inbox |
	inbox := Inbox new
		session: self;
		name: 'Inbox'.
	self addFolder: inbox.
	^inbox! 
folders: anOrderedCollection
		"Private - Set the folders inst var to anOrderedCollection of all the folders for this session."
	folders := anOrderedCollection!
folders
		"Answer all the folders for this session."
	^folders! 
logoff
		"Terminates a session with the messaging service."

	| result |

	result := MAPIDLL current cmcLogoff: self id 
		uiId: 0 
		logoffFlags: 0 
		extensions: nil asParameter.
	result = 0
		ifTrue: [ self id: 0. MAPIDLL current close ]
		ifFalse: [ self osError: result ]!  
newFolder: folderName
		"Answer a MailFolder with the name folderName."
	| folder |
	folder := MailFolder new
		session: self;
		name: folderName.
	self addFolder: folder.
	^folder!  
isValid
		"Answers true if the receiver is a valid session."
	^self id notNil!  
newMessage
		"Answer a MailMessage for this session."
	^MailMessage new
		initialize;
		session: self!
osError: anInteger
		"Create a walkback window describing an error condition
        that was returned by MAPI, as indicated by anInteger"
	^Error signal: 'MAPI Error: ', anInteger printString!  
id: anInteger
		"Private - set the id associated with the receiver."
	id := anInteger

!  
deleteFolder: aMailFolder
		"Delete aMailFolder from the session and all its messages from the service provider."
	aMailFolder messages isEmpty
		ifFalse: [ 
			( MessageBox confirm: 'Do you really want to delete this folder with all its messages?' )
				ifFalse: [ ^self ] ].
		folders remove: aMailFolder ifAbsent: [ ^self ].
		aMailFolder messages do: [ :msg |
			aMailFolder deleteMessage: msg ].
		aMailFolder invalidate!   
id
		"Private - answer the id associated with the receiver."
	^id!  
addFolder: aMailFolder
		"Add aMailFolder to the collection of folders of this session."
	folders add: aMailFolder! 
addressBookNamed: addressBookName
		"Answer the MailAddressBook whose name is addressBookName."
	^MailAddressBook new
		session: self;
		name: addressBookName!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^20!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
		#attachTitle
		#attachType
		#attachFilename
		#attachFlags
		#attachExtensions
    )!
new
		"Answer a new instance of the receiver."
	^super new initialize!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^16!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
		#itemCode
		#itemData
		#itemReference
		#extensionFlags
    )!
extensionFlags: anInteger
		"Private - Set the extension flags."
	self uLongAtOffset: 12 put: anInteger!
initialize
		"Private - Initialize some default values."
	externalAddresses := Set new.!
itemReference
		"Private - Answer the item reference for the extension. The specification of the extension describes the interpretation of this field."
	^(ExternalAddress fromInteger: (self uLongAtOffset: 8)) contents.
!   
itemReference: aReference
		"Private - Set the item reference for the extension. The specification of the extension describes the interpretation of this field."
	aReference isNil
		ifTrue: [ self uLongAtOffset: 8 put: 0 ]
		ifFalse: [ 	self uLongAtOffset: 8 put: (externalAddresses add: (ExternalAddress copyToNonSmalltalkMemory: aReference)) asInteger ]!   
itemCode: anInteger
		"Private - Set the code that uniquely identifies extended functionality for a function or data structure."
	self uLongAtOffset: 0 put: anInteger
!   
extensionFlags
		"Private - Answer the extension flags."
	^self uLongAtOffset: 12!  
itemData: anInteger
		"Private - Set the item data for the extension. The specification of the extension describes the interpretation of this field."
	self uLongAtOffset: 4 put: anInteger!
itemData
		"Private - Answer the item data for the extension. The specification of the extension describes the interpretation of this field."
	^self uLongAtOffset: 4!  
itemCode
		"Private - Answer the code that uniquely identifies extended functionality for a function or data structure."
	^self uLongAtOffset: 0!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^ 24! 
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
		#name
		#nameType
		#address
		#role
		#recipFlags
		#recipExtensions
    )! 
flags
		"Private - Answer the CMCXComSupport flags."
	^self uLongAtOffset: 4!   
flags: anInteger
		"Set the CMCXComSupport flags."
	self uLongAtOffset: 4 put: anInteger!   
itemCode
		"Private - Answer the CMCXComSupport item code."
	^self uLongAtOffset: 0!
itemCode: anInteger
		"Private - Set the CMCXComSupport item code."
	self uLongAtOffset: 0 put: anInteger!  
pad1: anInteger
		"Private - Unused field; needed to align structure on 4-byte boundary."
	self byteAtOffset: 7 put: anInteger
!   
asTime
		"Answer a Time representing the time described by the receiver."
	^Time hours: self hour minutes: self minute seconds: self second!
minute: anInteger
		"Private - Set the minute of when the message was sent; range 0 - 59."
	self byteAtOffset: 1 put: anInteger
!  
pad2: anInteger
		"Private - Unused field; needed to align sturcture on 4-byte boundary."
	self shortAtOffset: 10 put: anInteger
! 
year: anInteger
		"Private - Set the year since 1900 of when the message was sent."
	self byteAtOffset: 5 put: anInteger
! 
minute
		"Private - Answer the minute of when the message was sent; range 0 - 59."
	^self byteAtOffset: 1!  
month
		"Private - Answer the month since January of when the message was sent; range 0 - 11."
	"Need to add 1 because of the 0 - 11 range so that January corresponds to 1, etc."
	^( self byteAtOffset: 4 ) + 1! 
month: anInteger
		"Private - Set the month since January of when the message was sent; range 0 - 11."
	self byteAtOffset: 4 put: anInteger
!  
second: anInteger
		"Private - Set the second of when the message was sent; range 0 - 59."
	self byteAtOffset: 0 put: anInteger
!  
tmzone: anInteger
		"Private - Set the time zone from which the message was sent. Measured in minutes relative to
		Greenwich mean time."
	self shortAtOffset: 8 put: anInteger
! 
asDate
		"Answer a Date representing the date described by the receiver."
	^Date newDay: self day month: (Date nameOfMonth: self month) year: self year!
hour
		"Private - Answer the hour since midnight of when the message was sent; range 0 - 23."
	^self byteAtOffset: 2!   
asTimeStamp
		"Answer the receiver as a TimeStamp."
	^TimeStamp date: self asDate time: self asTime!
pad1
		"Private - Unused field; needed to align structure on 4-byte boundary."
	^self byteAtOffset: 7
!
pad2
		"Private - Unused field; needed to align structure on 4-byte boundary."
	^self shortAtOffset: 10!
day
		"Private - Answer the day of the month when the message was sent; range 1 - 31."
	^self byteAtOffset: 3!  
day: anInteger
		"Private - Set the day of the month when the message was sent; range 1 - 31."
	self byteAtOffset: 3 put: anInteger
!  
isdst
		"Private - Answer if daylight savings time is in force."
	^self byteAtOffset: 6
!  
isdst: anInteger
		"Private - Set to a non-zero value if daylight savings time is in force."
	self byteAtOffset: 6 put: anInteger
!
hour: anInteger
		"Private - Set the hour since midnight of when the message was sent; range 0 - 23."
	self byteAtOffset: 2 put: anInteger
!   
tmzone
		"Private - Answer the time zone from which the message was sent. Measured in minutes relative to
		Greenwich mean time."
	^self shortAtOffset: 8! 
year
		"Private - Answer the year since 1900 of when the message was sent."
	^self byteAtOffset: 5! 
second
		"Private - Answer the second of when the message was sent; range 0 - 59."
	^self byteAtOffset: 0!  
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': '.
	self binary notNil ifTrue: [
		aStream nextPutAll: 'binary '.
		self binary do: [ :a | aStream nextPutAll: a filename ] andBetweenDo: [ aStream nextPutAll: ', ' ].
		aStream nextPutAll: '; ' ].
	self text notNil ifTrue: [
		aStream nextPutAll: 'text '.
		self text do: [ :a | aStream nextPutAll: a filename ] andBetweenDo: [ aStream nextPutAll: ', ' ] ]!
text
		"Answer the text attachments."
	^text
! 
binary
		"Answer the binary attachments."
	^binary
!   
text: anOrderedCollection
		"Set the text attachments inst var."
	text := anOrderedCollection
!
binary: anOrderedCollection
		"Set the binary attachments inst var."
	binary := anOrderedCollection
!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^4!   
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
       #length
		#string
    )!
fromAddress: anAddress
        "Answer a CMCCountedString whose bytes are copied from memory at anAddress."
	| length |
	length := ( self atAddress: anAddress ) length.
	^( self new: self sizeInBytes + length ) fillFromAddress: anAddress!
fromString: aString
        "Answer a CMCCountedString containing the characters of aString."
	^( self new: self sizeInBytes + aString size )
		length: aString size;
		string: aString!  
length: anInteger
		"Private - Set the length of the counted string."
	self uLongAtOffset: 0 put: anInteger!
string
		"Private - Answer the counted string."
    ^( self bytesAtOffset: 4 count: self length ) asString! 
length
		"Private - Answer the length of the counted string."
	^self uLongAtOffset: 0!  
string: aString
		"Private - Set the counted string's value."
	self bytesAtOffset: 4 put: aString

!  
fileName
        "Answer the receiver's file name."
    ^'mapi32'!  
cmcActOn: aSessionId msgRef: aMsgStruct operation: anOperation actOnFlags: flags uiId: aUiId actOnExtensions: extensions
	<api: cmc_act_on ulong ulong ulong ulong ulong struct ulongReturn>
	^self invalidArgument!
cmcQueryConfiguration: aSessionId item: itemValue buffer: aBuffer extensions: extensions
    <api: cmc_query_configuration ulong ulong struct struct ulongReturn>
    ^self invalidArgument!
cmcSendDocuments: recipients subject: aSubject textNote: aNote sendFlags: flags filePaths: filePaths attachTitles: attachments delimiter: aDelimiter uiId: aUiId
	<api: cmc_send_documents struct struct struct ulong struct struct struct ulong ulongReturn>
	^self invalidArgument!   
cmcFree: aMemoryHandle
	<api: cmc_free ulong ulongReturn>
	^self invalidArgument!   
cmcSend: aSessionId message: aMsgStruct sendFlags: flags uiId: aUiId extensions: extensions
	<api: cmc_send ulong struct ulong ulong struct ulongReturn>
	^self invalidArgument!
cmcLogoff: aSessionId uiId: aUiId logoffFlags: flags extensions: extensions
	<api: cmc_logoff ulong ulong ulong struct ulongReturn>
	^self invalidArgument! 
cmcLogon: aService user: aUser password: aPassword charSet: aCharSet uiId: aUiId cmcVersion: aVersion logonFlags: flags session: aSessionId extensions: extensions
    <api: cmc_logon struct struct struct struct ulong ushort ulong struct ulong ulongReturn>
    ^self invalidArgument!  
cmcLookUp: aSessionId recipientIn: aRecipStructIn lookUpFlags: flags uiId: aUiId count: anInteger recipinetOut: aRecipStructOut lookUpExtensions: extensions
	<api: cmc_look_up ulong struct ulong ulong struct struct ulong ulongReturn>
	^self invalidArgument!   
cmcList: aSessionId msgType: aMsgType listFlags: flags seed: aMsgRef count: anInteger uiId: aUiId msgResult: aResultRef listExtensions: extensions
	<api: cmc_list ulong struct ulong struct struct ulong struct struct ulongReturn>
	^self invalidArgument!
cmcRead: aSessionId msgRef: aMsgRef readFlags: flags message: aMsgStruct uiId: aUiId readExtensions: extensions
	<api: cmc_read ulong ulong ulong struct ulong struct ulongReturn>
	^self invalidArgument!  
entireMessageFrom: aMsgStruct
		"Private - Fill in the fields for the reciever that were not already provided by the summary information."
	self body: aMsgStruct textNote.
	self addressees: aMsgStruct retrieveAddressees.
	self attachments: aMsgStruct retrieveAttachments!   
forward
		"Forward a message and prompt for new addressees."
	| newMsg |
	newMsg := self class new.

	newMsg addressees: self addressees.
	newMsg subject: self subject.
	newMsg body: self body.
	newMsg attachments: self attachments.

	^newMsg send!
deliveryPriority
		"Answer the message delivery priority."
	self readEntireMessage.
	^deliveryPriority
!  
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': ', self subject printString! 
readEntireMessage
		"Private - Read message aMessage to fill in fields that the message summary didn't provide."

	| result msgStructResult |
	self summary
		ifTrue: [ 
			msgStructResult := ExternalAddress new.
	
			result := MAPIDLL current
				cmcRead: self session id 
				msgRef: self id
				readFlags: CMCErrorUiAllowed 
				message: msgStructResult asParameter 
				uiId: 0 
				readExtensions: nil asParameter.

			result = 0
				ifTrue: [
					self summary: false.
					self entireMessageFrom: (CMCMessage atAddress: msgStructResult) ]
				ifFalse: [ self session osError: result ] ]! 
body: aString
		"Set the body of the receiver to aString."
	body := aString!
replyToAll
		"Reply to all addressees of the message and retain their roles."
	| newMsg |
	newMsg := self class new.

	"Retain addressees and their roles"
	newMsg addressees: self addressees.

	"Retain subject line and append prefix 'Re: ' if appropriate"
	( self subject indexOfString: 'Re: ' ) = 1
		ifTrue: [ "message was replied to already"
			newMsg subject: self subject ]
		ifFalse: [ "message needs to add prefix 'Re: ' to subject"
			newMsg subject: 'Re: ', self subject ].

	"Retain message body and attachments"
	newMsg body: self body.
	newMsg attachments: self attachments.

	^newMsg send! 
id: anInteger
		"Private - set the id associated with the receiver."
	id := anInteger

!  
id
		"Private - answer the id associated with the receiver."
	^id!  
session
		"Private - answer the receiver's session."
	^session! 
lowPriority
		"Set the delivery priority of the message to low."
	deliveryPriority := 'low'!
author
		"Answer the author of the reciever."
	^author
!   
author: aString
		"Private - Set the author of the message. (Set by the system)"
	author := aString!
session: aMailSession
		"Private - set the receiver's session to aMailSession."
	session := aMailSession!   
initialize
		"Private - Initializes the message to its default values."
	self normalPriority.
	self addressees: MailAddressList new.
	self attachments: MailAttachmentList new.
	self summary: false!
attachments
		"Answer the attachments instance variable."
	self readEntireMessage.
	^attachments!  
attachments: aMailAttachmentList
		"Set the attachments instance variable."
	aMailAttachmentList isNil
		ifFalse: [ attachments := aMailAttachmentList ]!  
size
		"Answer size of message in bytes."
	^size
! 
summary
		"Private - Answer whether the receiver was created from a message summary."
	^summary!
summary: aBoolean
		"Private - Set aBoolean to indicate whether the receiver was created from a message summary."
	summary := aBoolean! 
isLowPriority
		"Answer true if the delivery priority of the message is low."
	^deliveryPriority equals: 'low'! 
deliveryPriority: aString
		"Set the delivery priority of the message to aString."
	deliveryPriority := aString!
addressees
		"Answer the addressees instance variable."
	self readEntireMessage.
	^addressees! 
send: aString
		"Send a message with aString as its text."
	| msgStruct result |
	self body: aString.
	msgStruct := CMCMessage fromMessage: self.
	result := MAPIDLL current
		cmcSend: self session id 
		message: msgStruct asParameter 
		sendFlags: CMCLogonUiAllowed | CMCSendUiRequested | CMCErrorUiAllowed 
		uiId: 0 
		extensions: nil asParameter.
	result = 0
		ifFalse: [ self session osError: result ]!
sendNoUI: aString
		"Send a message with aString as its text and no default ui."
	| msgStruct result |
	self body: aString.
	msgStruct := CMCMessage fromMessage: self.
	result := MAPIDLL current
		cmcSend: self session id 
		message: msgStruct asParameter 
		sendFlags: CMCLogonUiAllowed | CMCErrorUiAllowed 
		uiId: 0 
		extensions: nil asParameter.
	result = 0
		ifFalse: [ self session osError: result ]!   
addressees: aMailAddressList
		"Set the addressees instance variable."
	aMailAddressList isNil
		ifFalse: [ addressees := aMailAddressList ]!  
replyToAuthor
		"Reply to the author of the message."
	| newMsg |
	newMsg := self class new.

	"Turn originator of message into receiver"
	newMsg addressees to: ( Array with: self author ).

	"Retain subject line and append prefix 'Re: ' if appropriate"
	( self subject indexOfString: 'Re: ' ) = 1
		ifTrue: [ "message was replied to already"
			newMsg subject: self subject ]
		ifFalse: [ "message needs to add prefix 'Re: ' to subject"
			newMsg subject: 'Re: ', self subject ].

	"Retain message body and attachments"
	newMsg body: self body.
	newMsg attachments: self attachments.

	^newMsg send
! 
sendNoUI
		"Send a message without default ui."
	| msgStruct result |
	msgStruct := CMCMessage fromMessage: self.
	result := MAPIDLL current
		cmcSend: self session id 
		message: msgStruct asParameter 
		sendFlags: CMCLogonUiAllowed | CMCErrorUiAllowed 
		uiId: 0 
		extensions: nil asParameter.
	result = 0
		ifFalse: [ self session osError: result ]!  
delete
		"Delete receiver from the system provider."
	| result |
	result := MAPIDLL current
		cmcActOn: self session id 
		msgRef: self id
		operation: CMCActOnDelete 
		actOnFlags: 0 
		uiId: 0 
		actOnExtensions: nil asParameter.
	result = 0
		ifTrue: [ self invalidate ]
		ifFalse: [ self session osError: result ]!
invalidate
			"Private - Invalidate receiver."
	self initialize.
	author := nil.
	body := nil.
	id := nil.
	size := nil.
	subject := nil.
	timeSent := nil.!  
isNormalPriority
		"Answer true if the delivery priority of the message is normal."
	^deliveryPriority equals: 'normal'!
subject
		"Answer the subject of the message."
	^subject
! 
subject: aString
		"Set the subject of the message."
	subject := aString
! 
body
		"Answer the body of the receiver."
	self readEntireMessage.
	^body! 
timeSent: aTimeStamp
		"Private - Set time when message got sent. Provided by system."
	timeSent := aTimeStamp! 
send
		"Send a message using the default ui provided by the service provider back end."
	| msgStruct result |
	msgStruct := CMCMessage fromMessage: self.
	result := MAPIDLL current
		cmcSend: self session id 
		message: msgStruct asParameter 
		sendFlags: CMCLogonUiAllowed | CMCSendUiRequested | CMCErrorUiAllowed 
		uiId: 0 
		extensions: nil asParameter.
	result = 0
		ifFalse: [ self session osError: result ]
!   
timeSent
		"Answer the time the message was sent."
	^timeSent
!
normalPriority
		"Set the delivery priority of the message to normal."
	deliveryPriority := 'normal'!   
urgentPriority
		"Set the delivery priority of the message to urgent."
	deliveryPriority := 'urgent'!   
isUrgentPriority
		"Answer true if the delivery priority of the message is urgent."
	^deliveryPriority equals: 'urgent'!
size: anInteger
		"Private - Set size of message in bytes. (Set by the system)"
	size := anInteger
!   
new
		"Answer a new instance of the receiver."
	^super new initialize!  
name
		"Answer the reciever's name"
	^name! 
name: aString
		"Set the reciever's name"
	name := aString! 
role: aString
		"Set the reciever's role"
	role := aString! 
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': ', self name printString!
initialize
		"Private - Initialize to the default values."
	type := 'Unknown'!  
role
		"Answer the reciever's role"
	^role! 
type: aString
		"Set the reciever's type"
	type := aString! 
type
		"Answer the reciever's type"
	^type! 
address
		"Answer the receiver's address."
	^address!   
address: aString
		"Set the receiver's address."
	address := aString!   
attachExtensions
		"Private - Answer the address to the array of CMCExtension structures."
	^self addressAtOffset: 16!  
attachType: aString
		"Private - Set attachment type for attachment (binary or text)."
	aString isNil
		ifTrue: [ self uLongAtOffset: 4 put: 0 ]
		ifFalse: [ self uLongAtOffset: 4 put: aString copyToExternalMemory asInteger ]!
attachFilename: aString
		"Private - Set the name of the file in which attachment content is located."
	aString isNil
		ifTrue: [ self uLongAtOffset: 8 put: 0 ]
		ifFalse: [	self uLongAtOffset: 8 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!   
attachFilename
		"Private - Answer the name of the file in which the attachment content is contained."
	| addr |
	( addr := self addressAtOffset: 8 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!
attachType
		"Private - Answer type of the attachment."
	| addr |
	( addr := self addressAtOffset: 4 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!   
initialize
		"Private - Initialize some default values."
	externalAddresses := Set new.!
attachExtensions: pExtensionStruct
		"Private - Set the pointer to an CMCExtension."
	self uLongAtOffset: 16 put: pExtensionStruct asInteger!   
attachFlags
		"Private - Answer flags that describe attachment options."
	^self uLongAtOffset: 12!  
attachFlags: anInteger
		"Private - Set the flags that describe attachment options."
	self uLongAtOffset: 12 put: anInteger!
attachTitle
		"Private - Answer title of attachment."
	| addr |
	( addr := self addressAtOffset: 0 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil! 
attachTitle: aString
		"Private - Set optional title for the attachment, e.g., the original file name of the attachment."
	aString isNil
		ifTrue: [ self uLongAtOffset: 0 put: 0 ]
		ifFalse: [ self uLongAtOffset: 0 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!
name
		"Private - Answer recipient's or originator's name."
	| addr |
	( addr := self addressAtOffset: 0 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!   
name: aString
		"Private - Set the recipient's or origitnator's name."
	aString isNil
		ifTrue: [ self uLongAtOffset: 0 put: 0 ]
		ifFalse: [	self uLongAtOffset: 0 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!   
nameType
		"Private - Answer the name type."
	^self longAtOffset: 4!
recipFlags
		"Private - Answer the recipient flags."
	^self uLongAtOffset: 16!  
role: anInteger
		"Private - Set the role of the recipient or originator."
	self longAtOffset: 12 put: anInteger!   
recipFlags: anInteger
		"Private - Set the recipient flags."
	self uLongAtOffset: 16 put: anInteger!
initialize
		"Private - Initialize some default values."
	externalAddresses := Set new.!
role
		"Private - Answer the role of the recipient or originator."
	^self longAtOffset: 12! 
recipExtensions
		"Private - Answer the address to an array of CMCExtension structures."
	^self addressAtOffset: 20!
recipExtensions: pExtensionStruct
		"Private - Set the pointer to an array of CMCExtension structures."
	self uLongAtOffset: 20 put: pExtensionStruct asInteger!
address
		"Private - Answer the recipient's or originator's address."
	| addr |
	( addr := self addressAtOffset: 8 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil! 
address: aString
		"Private - Set the recipient's or originator's address."
	aString isNil
		ifTrue: [ self uLongAtOffset: 8 put: 0 ]
		ifFalse: [ self uLongAtOffset: 8 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!  
nameType: anInteger
		"Private - Set the name type."
	self longAtOffset: 4 put: anInteger!  
new
		"Answer a new instance of the receiver."
	^super new initialize!  
sizeInBytes
        "Private - Answer the default size in bytes."
    ^40!  
inspectorFields
        "Answer the names of the fields contained in this kind of definition."
    ^FieldInspector fields: #(
		#messageReference
		#messageType
		#subject
		#timeSent
		#byteLength
		#originator
		#summaryFlags
		#messageSummaryExtensions
    )! 
timeSent: aTimeStruct
		"Private - Set the time when message got sent."
	self bytesAtOffset: 12 put: aTimeStruct contents!  
messageReference: pMsgRefStruct
		"Private - Set the pointer to the message reference struct which is equal to the 
		CMCCountedString structure."
	self uLongAtOffset: 0 put: pMsgRefStruct asInteger!
retrieveExtensionsFor: aMsg
		"Private - Retrieve the extensions from the reciever for aMsg."
	| extList extensionAddr extension i |

	extList := OrderedCollection new.

	( extensionAddr := self messageSummaryExtensions ) isValid
		ifTrue: [
			extension := CMCExtension fromAddress: extensionAddr.
			i := 1.
			[ ( extension extensionFlags & CMCExtLastElement ) = 0 ]
				whileTrue: [ 
					extension itemCode = CMCXComPriority
						ifTrue: [ aMsg deliveryPriority: ( self priorityAsString: extension itemData ) ].
					extension := CMCExtension fromAddress: ( extensionAddr + (i * (CMCExtension sizeInBytes) ) ).
					i := i + 1 ].
			extension itemCode = CMCXComPriority
				ifTrue: [ aMsg deliveryPriority: ( self priorityAsString: extension itemData ) ] ].! 
originator
		"Private - Answer a CMCRecipient structure for the message originator."
	| addr |
	( addr := self addressAtOffset: 28 ) isValid
		ifTrue: [ ^CMCRecipient fromAddress: addr ].
	^nil!   
typeAsString: anInteger
		"Private - Answer the type as a string."
	anInteger = CMCTypeGroup
		ifTrue: [ ^'group' ]
		ifFalse: [ 
			anInteger = CMCTypeIndividual
				ifTrue: [ ^'individual' ]
				ifFalse: [ ^'unknown' ] ]!
messageReference
		"Private - Answer the pointer to a message reference structure."
	^self uLongAtOffset: 0
!  
retrieveAddressee: aRecipStruct
		"Private - Retrieve the addressee information from the structure and answer a MailAddressee instance."
	| addressee |
	addressee := MailAddressee new.
	addressee 
		address: aRecipStruct address;
		name: aRecipStruct name;
		role: ( self roleAsString: aRecipStruct role );
		type: ( self typeAsString: aRecipStruct nameType ).

	^addressee!  
originator: pRecipientStruct
		"Private - Set the pointer to the message originator sturcture."
	self uLongAtOffset: 28 put: pRecipientStruct asInteger!
timeSent
		"Private - Answer CMCTime structure for message."
	^CMCTime usingBytes: ( self bytesAtOffset: 12 count: CMCTime sizeInBytes )!   
summaryFlags
		"Private - Answer the message summary flags."
	^self uLongAtOffset: 32!  
initialize
		"Private - Initialize some default values."
	externalAddresses := Set new.!
messageSummaryExtensions
		"Private - Answer the address to the array of CMCExtension structures."
	^self addressAtOffset: 36!  
byteLength
		"Private - Answer the message size in bytes."
	^self uLongAtOffset: 24!
priorityAsString: anInteger
		"Private - Answer the priority as a string."
	anInteger  = 0
		ifTrue: [ ^'normal' ]
		ifFalse: [ 
			anInteger = 1
				ifTrue: [ ^'urgent' ]
				ifFalse: [ ^'low' ] ] !
messageSummaryExtensions: pExtensionStruct
		"Private - Set the pointer to an array of CMCExtension structures."
	self uLongAtOffset: 36 put: pExtensionStruct asInteger!   
byteLength: anInteger
		"Private - Set the message size in bytes."
	self uLongAtOffset: 24 put: anInteger!  
summaryFlags: anInteger
		"Private - Set the message summary flags."
	self uLongAtOffset: 32 put: anInteger!
messageType
		"Private - Answer the type of the message."
	| addr |
	( addr := self addressAtOffset: 4 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil! 
messageType: aString
		"Private - Set the type of the message."
	aString isNil
		ifTrue: [ self uLongAtOffset: 4 put: 0 ]
		ifFalse: [ self uLongAtOffset: 4 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!  
subject
		"Private - Answer the subject of the message."
	| addr |
	( addr := self addressAtOffset: 8 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!  
subject: aString
		"Private - Set the subject of the message."
	aString isNil
		ifTrue: [ self uLongAtOffset: 8 put: 0 ]
		ifFalse: [ self uLongAtOffset: 8 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!   
asMessage
		"Private - Answer a MailMessage instance with the available information from a summary structure."	
	| msg |
	msg := MailMessage new.
	msg summary: true.
	msg id: self messageReference.
	msg subject: self subject.
	msg timeSent: self timeSent asTimeStamp.
	msg size: self byteLength.

	msg author: ( self retrieveAddressee: self originator ).

	self retrieveExtensionsFor: msg.
	^msg! 
roleAsString: anInteger
		"Private - Answer the role as a string."
	anInteger = CMCRoleOriginator
		ifTrue: [ ^'originator' ]
		ifFalse: [ 
			anInteger = CMCRoleTo
				ifTrue: [ ^'To:' ]
				ifFalse: [
					anInteger = CMCRoleCc
						ifTrue: [ ^'Cc:' ]
						ifFalse: [ 
							anInteger = CMCRoleBcc
								ifTrue: [ ^'Bcc:' ]
								ifFalse: [ 
									anInteger = CMCRoleAuthorizingUser
										ifTrue: [  ^'authorizer' ] ] ] ] ]!   
textNote
		"Private - Answer the message body string."
	| addr |
	( addr := self addressAtOffset: 24 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!   
priorityAsInteger: aString
		"Private - Answer the priority as the corresponding integer value."
	( aString equals: 'normal' )
		ifTrue: [ ^0 ]
		ifFalse: [
			( aString equals: 'urgent' )
				ifTrue: [ ^1 ]
				ifFalse: [ ^2 ] ]! 
addresseesFrom: aMsg
		"Private - Creates an array of CMCRecipient structures from a list of addressees provided by aMsg."
	| recipList recipListSize recipListTo recipListCc recipListBcc recip recipSize recipByteArray recipAddr |

	recipList := OrderedCollection new.
	
	recipListTo := aMsg addressees to.
	recipListTo isNil
		ifFalse: [
			1 to: recipListTo size do: [ :i |
				recip := CMCRecipient new
					address: (recipListTo at: i) address;
					name: (recipListTo at: i) name;
					role: CMCRoleTo;
					nameType: ( self typeAsInteger: (recipListTo at: i) type ).
			recipList add: recip ] ].

	recipListCc := aMsg addressees cc.
	recipListCc isNil
		ifFalse: [
			1 to: recipListCc size do: [ :i |
				recip := CMCRecipient new
					address: (recipListCc at: i) address;
					name: (recipListCc at: i) name;
					role: CMCRoleCc;
					nameType: ( self typeAsInteger: (recipListCc at: i) type ).
			recipList add: recip ] ].

	recipListBcc := aMsg addressees bcc.
	recipListBcc isNil
		ifFalse: [
			1 to: recipListBcc size do: [ :i |
				recip := CMCRecipient new
					address: (recipListBcc at: i) address;
					name: (recipListBcc at: i);
					role: CMCRoleBcc;
					nameType: ( self typeAsInteger: (recipListBcc at: i) type ).
			recipList add: recip ] ].

	recipList notEmpty
		ifTrue: [ recipList last recipFlags: ( recipList last recipFlags | CMCRecipLastElement ) ].

	recipSize := CMCRecipient sizeInBytes.
	recipListSize := recipList size.
	( recipListSize > 0 )
		ifTrue: [
			recipByteArray := ByteArray new: (recipListSize * recipSize).
			1 to: recipListSize do: [ :i |
				recipByteArray replaceFrom: ((i - 1)*recipSize + 1) to: (i*recipSize) with: (recipList at: i) contents startingAt: 1 ].
			recipAddr := recipByteArray copyToExternalMemory ]
		ifFalse: [ recipAddr := ExternalAddress new ].

	self recipients: recipAddr.! 
messageFlags: anInteger
		"Private - Set message flags."
	self uLongAtOffset: 36 put: anInteger
!  
messageReference: pMsgRefStruct
		"Private - Set the pointer to the message reference struct which is equal to the 
		CMCCountedString structure."
	pMsgRefStruct isNil
		ifTrue: [ self uLongAtOffset: 0 put: 0 ]
		ifFalse: [ self uLongAtOffset: 0 put: pMsgRefStruct asInteger ]

	
! 
initialize
		"Private - Initialize some default values."
	externalAddresses := Set new.!
attachments
		"Private - Answer the address to an array of CMCAttachment structures."
	^self addressAtOffset: 32
	!
attachments: pAttachmentStruct
		"Private - Set the pointer to an array of CMCAttachment structures."
	self uLongAtOffset: 32 put: pAttachmentStruct asInteger

	
!  
recipients: pRecipientStruct
		"Private - Set the pointer to an array of CMCRecipient structures."
	self uLongAtOffset: 28 put: pRecipientStruct asInteger

	
!  
typeAsInteger: aString
		"Private - Answer the type as the corresponding integer value."
	( aString equalsIgnoreCase: 'group' )
			ifTrue: [ ^CMCTypeGroup ]
			ifFalse: [
				( aString equalsIgnoreCase: 'individual' )
					ifTrue: [ ^CMCTypeIndividual ]
					ifFalse: [ ^CMCTypeUnknown ] ]! 
extensionsFrom: aMsg
		"Private - Creates an array of CMCExtension structures from data provided by aMsg."
	| extList extListSize ext extSize extByteArray extAddr |

	extList := OrderedCollection new.

	ext := CMCExtension new	
		itemCode: CMCXComPriority;
		itemData: ( self priorityAsInteger: aMsg deliveryPriority );
		itemReference: nil;
		extensionFlags: CMCExtLastElement.

	extList add: ext.
		
	extSize := CMCExtension sizeInBytes.
	extListSize := extList size.
	( extListSize > 0 )
		ifTrue: [
			extByteArray := ByteArray new: (extListSize * extSize).
			1 to: extListSize do: [ :i |
				extByteArray replaceFrom: ((i - 1)*extSize + 1) to: (i*extSize) with: (extList at: i) contents startingAt: 1 ].
			extAddr := extByteArray copyToExternalMemory ]
		ifFalse: [ extAddr := ExternalAddress new ].

	self  messageExtensions: extAddr!
attachmentsFrom: aMsg
		"Private - Creates an array of CMCAttachments from a list of attachments provided by the aMsg."
	| attList attListBinary attListText attListSize att attSize attByteArray attAddr |

	attList := OrderedCollection new.

	attListBinary := aMsg attachments binary.
	attListBinary isNil
		ifFalse: [
			1 to: attListBinary size do: [ :i |
				att := CMCAttachment new
					attachFilename: (attListBinary at: i) filename;
					attachFlags: (attListBinary at: i) flags;
					attachTitle: (attListBinary at: i) title;
					attachType: CMCAttOidBinary.
				attList add: att ] ].

	attListText := aMsg attachments text.
	attListText isNil
		ifFalse: [
			1 to: attListText size do: [ :i |
				att := CMCAttachment new
					attachFilename: (attListText at: i) filename;
					attachFlags: (attListText at: i) flags;
					attachTitle: (attListText at: i) title;
					attachType: CMCAttOidText.
				attList add: att ] ].

	attList notEmpty
		ifTrue: [ attList last attachFlags: ( attList last attachFlags | CMCAttLastElement ) ].

	attSize := CMCAttachment sizeInBytes.
	attListSize := attList size.
	( attListSize > 0 )
		ifTrue: [
			attByteArray := ByteArray new: (attListSize * attSize).
			1 to: attListSize do: [ :i |
				attByteArray replaceFrom: ((i - 1)*attSize + 1) to: (i*attSize) with: (attList at: i) contents startingAt: 1 ].
			attAddr := attByteArray copyToExternalMemory ]
		ifFalse: [ attAddr := ExternalAddress new ].

	self attachments: attAddr.!  
retrieveAddressee: aRecipStruct
		"Private - Retrieve the addressee information from the structure and answer a MailAddressee instance."
	| addressee |
	addressee := MailAddressee new.
	addressee 
		address: aRecipStruct address;
		name: aRecipStruct name;
		role: ( self roleAsString: aRecipStruct role );
		type: ( self typeAsString: aRecipStruct nameType ).

	^addressee!  
retrieveAddressees
		"Private - Retrieves addressees from the reciever structure	and sorts them out to the respective collections."
	| recipListTo recipListCc recipListBcc recipientAddr recipient i addressees |

	recipListTo := OrderedCollection new.
	recipListCc := OrderedCollection new.
	recipListBcc := OrderedCollection new.

	"The first element in the array is the originator."
	recipientAddr := self recipients.

	"The second and following elements in the array are the recipients."
	recipient := CMCRecipient fromAddress: ( recipientAddr + CMCRecipient sizeInBytes ).
	i := 2.
	[ ( recipient recipFlags & CMCRecipLastElement) = 0 ]
		whileTrue: [ 
			recipient role = CMCRoleTo
				ifTrue: [ recipListTo add: ( self retrieveAddressee: recipient ) ]
				ifFalse: [
					recipient role = CMCRoleCc
						ifTrue: [ recipListCc add: ( self retrieveAddressee: recipient ) ]
						ifFalse: [ recipListBcc add: ( self retrieveAddressee: recipient ) ] ].
			recipient := CMCRecipient fromAddress: ( recipientAddr + ( i * (CMCRecipient sizeInBytes) ) ).
			i := i + 1 ].
	recipient role = CMCRoleTo
		ifTrue: [ recipListTo add: ( self retrieveAddressee: recipient ) ]
		ifFalse: [
			recipient role = CMCRoleCc
				ifTrue: [ recipListCc add: ( self retrieveAddressee: recipient ) ]
				ifFalse: [ recipListBcc add: ( self retrieveAddressee: recipient ) ] ].

	addressees := MailAddressList new
		to: recipListTo asArray;
		cc: recipListCc asArray;
		bcc: recipListBcc asArray.
	^addressees!  
textNote: aString
		"Private - Set the messge body to aString."
	aString isNil
		ifTrue: [ self uLongAtOffset: 24 put: 0 ]
		ifFalse: [ self uLongAtOffset: 24 put: (externalAddresses add: aString copyToExternalMemory) asInteger ]!
messageType
		"Private - Answer message type."
	| addr |
	( addr := self addressAtOffset: 4 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!
messageType: aString
		"Private - Set the type of a message."
	aString isNil
		ifTrue: [ self uLongAtOffset: 4 put: 0 ]
		ifFalse: [	self uLongAtOffset: 4 put: (externalAddresses add: aString copyToExternalMemory) asInteger ].!   
subject: aString
		"Private - Set the subject to aString."
	aString isNil
		ifTrue: [ self uLongAtOffset: 8 put: 0 ]
		ifFalse: [ self uLongAtOffset: 8 put: (externalAddresses add: aString copyToExternalMemory) asInteger ].!  
subject
		"Private - Answer the subject string."
	| addr |
	( addr := self addressAtOffset: 8 ) isValid
		ifTrue: [ ^String fromAddress: addr ].
	^nil!  
roleAsString: anInteger
		"Private - Answer the role as a string."
	anInteger = CMCRoleOriginator
		ifTrue: [ ^'originator' ]
		ifFalse: [ 
			anInteger = CMCRoleTo
				ifTrue: [ ^'To:' ]
				ifFalse: [
					anInteger = CMCRoleCc
						ifTrue: [ ^'Cc:' ]
						ifFalse: [ 
							anInteger = CMCRoleBcc
								ifTrue: [ ^'Bcc:' ]
								ifFalse: [ 
									anInteger = CMCRoleAuthorizingUser
										ifTrue: [  ^'authorizer' ] ] ] ] ]!   
timeSent: aTimeStruct
		"Private - Set the time when message got sent."
	aTimeStruct isNil
		ifTrue: [ self bytesAtOffset: 12 put: CMCTime new contents ]
		ifFalse: [ self bytesAtOffset: 12 put: aTimeStruct contents ]!
typeAsString: anInteger
		"Private - Answer the type as a string."
	anInteger = CMCTypeGroup
		ifTrue: [ ^'group' ]
		ifFalse: [ 
			anInteger = CMCTypeIndividual
				ifTrue: [ ^'individual' ]
				ifFalse: [ ^'unknown' ] ]!
retrieveAttachment: anAttachStruct
		"Private - Retrieve the attachment information from the structure and answer a MailAttachment instance."
	| attachment |
	attachment := MailAttachment new 
		flags: anAttachStruct attachFlags;
		filename: anAttachStruct attachFilename;
		title: anAttachStruct attachTitle;
		type: anAttachStruct attachType.
	^attachment
		!
messageReference
		"Private - Answer the pointer to a message reference structure."
	^self uLongAtOffset: 0
!  
timeSent
		"Private - Answer CMCTime structure for message."
	^CMCTime usingBytes: ( self bytesAtOffset: 12 count: CMCTime sizeInBytes )!   
recipients
		"Private - Answer the address to the array of CMCRecipient structures."
	^self addressAtOffset: 28
	! 
retrieveAttachments
		"Private - Retrieves attachments from the reciever and sorts them out to the respective collections."
	| attListText attListBinary attachmentAddr attachment i attachments |

	attListText := OrderedCollection new.
	attListBinary := OrderedCollection new.

	( attachmentAddr := self attachments ) isValid
		ifTrue: [
			attachment := CMCAttachment fromAddress: attachmentAddr.
			i := 1.
			[ ( attachment attachFlags & CMCAttLastElement ) = 0 ]
				whileTrue: [ 
					attachment attachType = CMCAttOidText
						ifTrue: [ attListText add: ( self retrieveAttachment: attachment ) ]
						ifFalse: [ attListBinary add: ( self retrieveAttachment: attachment ) ].
					attachment := CMCAttachment fromAddress: ( attachmentAddr + (i * (CMCAttachment sizeInBytes) ) ).
					i := i + 1 ].
			attachment attachType = CMCAttOidText
				ifTrue: [ attListText add: ( self retrieveAttachment: attachment ) ]
				ifFalse: [ attListBinary add: ( self retrieveAttachment: attachment ) ] ].

	attachments := MailAttachmentList new
		binary: attListBinary;
		text: attListText.
	^attachments! 
messageFlags
		"Private - Answer message flags."
	^self uLongAtOffset: 36!  
messageExtensions
		"Private - Answer the address to an array of CMCExtension structures."
	^self addressAtOffset: 40
	!   
messageExtensions: pExtensionStruct
		"Private - Set the pointer to an array of CMCExtension structures."
	self uLongAtOffset: 40 put: pExtensionStruct asInteger

	
!   
printOn: aStream
		"Append the string representation of the receiver to aStream."
	aStream nextPutAll: self class name, ': ', self filename printString!
filename
		"Answer the filename in which attachment content is located."
	^filename!
initialize
		"Private - Initialize to the default values."
	flags := 0! 
title
		"Answer the title of the receiver."
	^title!
title: aString
		"Set the title of the receiver."
	title := aString!
type: aString
		"Set the type of the receiver."
	type := aString!   
type
		"Answer the type of the receiver."
	^type!   
flags: anInteger
		"Private - Set the flags that describe the attachment options to anInteger."
	flags := anInteger!
isOwnedByApplication
		"Answer true if the attachment file is owned by the application."
   ( flags & CMCAttAppOwnsFile ) = 0
		ifTrue: [ ^false ]
		ifFalse: [^true ]!   
filename: aString
		"Set the filename in which attachment content is located."
	filename := aString!