3.1.0.106
   
isRepositoryComponentInstalled
        " Answer whether the Team/V repository component is installed "

    ^( ServiceRegistry globalRegistry
        serviceNamed: #RepositoryServices
        ifNone: [ nil ] )
            notNil!   
startupMessages
    "Private - Answer the messages to be executed during
    image startup."

    ^OrderedCollection with:
        ( Message receiver: self
            selector: #resetSearchPathRepositories ).!  
aboutToDisconnectRepository: aRepository
    "Private - <aRepository> is about to be disconnected.
    Disallow if it is on the search path, to maintain workbench
    environment integrity."

    ( PARTSFile currentSearchPath
        detect: [ :aDirectory |
            aDirectory isPARTSTeamVDirectory
                and: [ aDirectory repository == aRepository ]]
        ifNone: [ nil ]) notNil
        ifTrue: [
            VetoAction signal: 'the repository is on the Parts Workbench search path.' ]
!
entityAssured
    "Answer entity based on the receiver's repository and entity
    names.  If the entity is not there, create one."
    | aRepository anEntity |

    ( anEntity := self realEntity ) notNil
        ifTrue: [ ^anEntity ].

    ( aRepository := self repository ) isNil
        ifTrue: [ ^nil ].

    anEntity := PARTSTeamVInterface
        entityAssured: self entityName repository: aRepository.

    ^self realEntity: anEntity!   
resetSearchPathRepositories
    "Private - Flush the repositories to remove
    references to obsolete temp files"

    PARTSFile currentSearchPath do: [ :aDirectory |
        aDirectory isPARTSTeamVDirectory
            ifTrue: [
                [ aDirectory repository
                    close;
                    open ] on: RepositoryAccessDeniedError do: [ :e | self repositoryError: e ]
            ]
    ]
!   
repositoryFromPath: repositoryPath
    "Answer a repository for the repository on <repositoryPath>."

    [ ^self repositoryFromPath: repositoryPath ifAbsent: [ nil ]]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
!
handlesOperation: anOperation
    "Answer whether the receiver handles <anOperation>"

    PARTSTeamVInterface hasRepositoryService
        ifFalse: [ ^false ].

    ^( anOperation = #open or: [
    anOperation = #openLatest ])!   
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "
    | information |

    super initializePartValues.
    information := (( title indexOfString: 'Link' ) > 0 )
        ifTrue: [ 'Linked nested parts always use the latest revision on the search path' ]
        ifFalse: [ 'The latest revision will be selected' ].
    application information: information.! 
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.
    ( startFile notNil and: [
        startFile isPARTSTeamVFileDescriptor ])
        ifTrue: [ self setEnterCommentString ].!  
displayName
    "Answer a repository name, entity name, and revision number"
    | aNumber |

    self revisionNumber isNil
        ifTrue: [ self insureCurrent ].

    ( aNumber := self revisionNumber ) isNil
        ifTrue: [ aNumber := '' ].

    ^'(', self repositoryName, ') ',
        self entityName,'; ',
        aNumber.!
fileName
    "Answer the file name. The name looks like a standard
    dos file name."

    ^self entityName! 
installRevisionSupportLibrary
    " Library bind method. "

    | myLibraryName myLibrary |

    ( ( myLibraryName := self libraryName ) notNil
    and: [ ( myLibrary := SmalltalkLibrary named: myLibraryName ) notNil ] )
        ifTrue: [
            myLibrary
                when: #aboutToUnbind
                    send: #aboutToUnbind: to: self with: myLibrary;
                when: #unbind
                    send: #removeRevisionSupport to: self.
            ].

    self isRepositoryComponentInstalled
            ifTrue: [
                self checkRepositoryComponentUnbind.
                self initializeRevisionSupport ]
            ifFalse: [
                 SessionModel current
                    when: #libraryBound:
                    send: #checkForRepositoryComponent: to: self.
                ^nil ].!
repository: aRepository
    "Set the repository and directory."

    self realRepository: aRepository.
    directory :=                                     "Set super class var."
        ( aRepository notNil
            ifTrue: [ PARTSTeamVDirectory fromPath: aRepository path ]
            ifFalse: [ nil ] ).
    ^aRepository!  
revisionAssured: aRevisionNumber repositoryEntity: anEntity
    "Answer the entity revision associated with the
    parameters.  If the revision does not exist, create it."
    | entityRevisionSpec entityRevision |

    [ "Error handler"

    entityRevisionSpec :=
        EntityRevisionSpecClass new
            revisionNumber:
                ( RepositoryRevisionNumberClass fromString: aRevisionNumber );
            yourself.

    entityRevision :=
        entityRevisionSpec asEntityRevisionWithin: anEntity.
    entityRevision exists
        ifFalse: [ entityRevision create ].

    ^entityRevision

    ] "Error handler"
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^nil ].
!  
branchRevision: revisionString repositoryEntity: aRepositoryEntity
    "Answer the branched revision of <revisionString> within the revisions
    of <aRepositoryEntity>."

    [ ^(( RepositoryRevisionNumberClass fromString: revisionString )
        branchIn: aRepositoryEntity revisionNumberList ) asString ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
! 
repositories
    "Answer the valid repositories in the image."

    RepositoryService isNil
        ifTrue: [ ^OrderedCollection new ].

    ^RepositoryService repositories select: [ :aRepository |
         self isValidRepository: aRepository ]!  
getNextRevision: aFileDescriptor between: aRepositoryEntity
    "Given the <aFileDescriptor> of the previously loaded file,
    and the <aRepositoryEntity> of the desired save file,
    determine what the next revision should be.  If the two
    files aren't the same, bump the latest revision of the save file."
    | revision descriptorName entityName same path |

    aRepositoryEntity isNil     "New repository."
        ifTrue: [ ^PARTSTeamVInterface defaultRevisionValue ].

    aFileDescriptor isPARTSTeamVFileDescriptor not   "Old file is not repository entity."
        ifTrue: [ same := false ]
        ifFalse: [
            "Check if names are the same."
            descriptorName := aFileDescriptor fullPathName.
            ( path := PARTSTeamVInterface pathFromContainer: aRepositoryEntity ) isNil
                ifTrue: [ ^PARTSTeamVInterface defaultRevisionValue ].
            entityName :=
                PARTSTeamVFileDescriptor fromString: aRepositoryEntity in: path.
            same := descriptorName equalsIgnoreCase: entityName ].

    ( same not or: [
        ( revision := aFileDescriptor revisionNumber ) isNil ])
        ifTrue: [
            revision := PARTSTeamVInterface
                lastRevisionNumberIn: aRepositoryEntity ].
    revision isNil
        ifTrue: [ ^PARTSTeamVInterface defaultRevisionValue ].

    ^PARTSTeamVInterface
        incrementRevision: revision
        repositoryEntity: aRepositoryEntity! 
initializeRevisionSupport
    "Initialize the repository service when the repository
    component is bound.
    PARTSTeamVInterface initializeRevisionSupport
    "
    | repositoryComponent |

    RepositoryRevisionNumberClass := Smalltalk at: #RepositoryRevisionNumber.
    RepositorySystemPathClass := Smalltalk at: #RepositorySystemPath.
    RepositoryEntitySpecClass := Smalltalk at: #RepositoryEntitySpec.
    EntityRevisionSpecClass := Smalltalk at: #EntityRevisionSpec.
    RepositoryVolumeClass := Smalltalk at: #RepositoryVolume.
    RepositoryServicesClass := Smalltalk at: #RepositoryServices.
    ObsoleteRepositoryConnectionsAllowedError := Smalltalk at: #ObsoleteRepositoryConnectionsAllowed.
    RepositoryAccessDeniedError := Smalltalk at: #RepositoryAccessDenied.

    RepositoryService := RepositoryServicesClass current.
"    RepositoryService := ServiceRegistry globalRegistry
        serviceNamed: #PARTSRepositoryServices
        ifNone: [
            ServiceRegistry globalRegistry
                register: RepositoryServicesClass new
                    withName: #PARTSRepositoryServices
                    version: '1.0';
                serviceNamed: #PARTSRepositoryServices ]."

"    RepositoryService currentVolume: self partsRepositoryVolume."

    RepositoryService
        when: #aboutToDisconnectRepository:
        send: #aboutToDisconnectRepository:
        to: self.

    ( repositoryComponent := RepositoryService libraryName ) notNil
        ifTrue: [
            repositoryComponent
                when: #unbind
                send: #removeRevisionSupport to: self.
            ].

    " refresh the search path to reset any repository entries "
    PARTSFile setSearchPath: ( PARTSFile currentSearchPath
        collect: [ :aDirectory |
            PARTSDosDirectory fromPath: aDirectory absolutePathString ] ).

    SessionModel current isRunTime
        ifFalse: [
            self startupMessages do: [ :msg |
                SessionModel current
                    when: #started
                    evaluate: msg ]].

    ^RepositoryService
!   
insureCurrent
    "Insure that the current revisionNumber is the same as the
    latest in the entity.
        Answer whether the descriptor was current."
    | aRepositoryEntity latestRevision |

    ( aRepositoryEntity := self entity ) isNil ifTrue: [ ^false ].

    latestRevision := PARTSTeamVInterface
        lastRevisionWithBranchesIn: aRepositoryEntity.
    latestRevision ~= self revisionNumber
        ifTrue: [
            self revisionNumber: latestRevision.
            ^false ].
    ^true! 
revisionNumber: revisionString
    "Set the revisionNumber.  If it is different than the previous revision,
    reset the entityRevision"

    self revisionNumber ~= revisionString
        ifTrue: [
            self realEntityRevision: nil.
            revisionNumber := revisionString ].

    ^revisionString!   
opened
    

    super opened.

    ( startFile notNil and: [
        ( startFile isPARTSTeamVFileDescriptor and: [
        ( repositoryEntity := startFile entity ) notNil ])])
            ifTrue: [
                application selectFile: startFile entityName asLowerCase ]!   
fileType
    "Answer the abstract fileType. The type looks like a standard
    dos file extension."

    ^fileType!   
setCommentString: aString
    "Private - Set the comment and clear the comment heading.
    Copied to PARTSPartBrowser."

    application
        setRevisionHeading: nil;
        setComment: aString! 
opened
    | revision |

    super opened.

    "Show the comment and revision heading for the previous revision."

    ( startFile notNil
        and: [ ( revision := startFile revisionNumber ) notNil
        and: [ ( repositoryEntity := startFile entity ) notNil ]])
        ifTrue: [
            application setProposedRevision:
                ( PARTSTeamVInterface
                    incrementRevision: revision
                    repositoryEntity: repositoryEntity ).
            application derivedRevision:
                '(derived from revision: ',revision,')'.

            "Focus changes clobber the comment selection: perform deferred."
            ( Message new
                receiver: application;
                selector: #selectComment;
                yourself ) performDeferred ].

    ( self selectedDirIsRepository and: [
        application proposedRevision isNil ])
        ifTrue: [
            application setProposedRevision:
                PARTSTeamVInterface defaultRevisionValue ]!  
loadFromRepository: aRepository entity: aRepositoryEntity
    "Load a PARTSApplication whose external storage is
    <aRepositoryEntity> in <aRepository>, using the latest revision.
        <aRepository> can be either a repository name or
    a directory."

    ^self loadFromRepository: aRepository entity: aRepositoryEntity revision: nil!
okSave
    | fileName extension type |

    ( fileName := self fileNameField ) isEmpty
        ifTrue: [ ^nil ].

    (fileName includes: $*)
        ifTrue: [
            ^application fileNameChanged: fileName ].

    answer := self getPathName: fileName.
    extension := fileName fileExtension asUpperCase.
    ( PARTSDosDirectory exists: answer fileNamePath )
        ifFalse: [ ^answer := nil ].

    answer := PARTSFileDescriptor pathName: answer.
    type := ( fileTypes detect: [ :each | each pattern equalsIgnoreCase: pattern ] ) type.
    (( self validExtension: type between: extension descriptor: answer ) and: [
        ( self okToSave: answer )] )
        ifFalse: [ ^answer := nil ].

    answer isPARTSTeamVFileDescriptor
        ifTrue: [
            ( self revisionNumber: answer fileName: fileName ) isNil
                ifTrue: [ ^answer := nil ].

            answer proposedComment: (
                application userCommented
                    ifTrue: [ application comment trimBlanks ]
                    ifFalse: [ nil ])].

    self class lastDirectoryUsed: selectedDirectory.
    application closeWindow!   
entityName
    "Answer the entity name. The name looks like a standard
    dos file name."

    ^entityName notNil
        ifTrue: [ entityName ]
        ifFalse: [ '' ]!  
checkRepositoryComponentUnbind
    "Set up the unbind handlers for the repository component."

    | libraryName aLibrary |

    libraryName := ( ServiceRegistry globalRegistry
        serviceNamed: #RepositoryServices
        ifNone: [ nil ] ) class libraryName.
    aLibrary := SmalltalkLibrary named: libraryName.

    aLibrary
        when: #aboutToUnbind
            send: #aboutToUnbind: to: self with: aLibrary;
        when: #unbind
            send: #removeRevisionSupport to: self.!
loadFromRepository: aRepository entity: aRepositoryEntity revision: revisionNumber
    "Load a PARTSApplication whose external storage is
    <aRepositoryEntity> in <aRepository>, revision <revisionNumber>.
        <aRepository> can be either a repository name or
    a directory."

    ^self loadFromRepository: aRepository
        entity: aRepositoryEntity
        revision: revisionNumber
        context: ( PARTSLoadContext new )!   
fileReadOnly: fileName
        "Answer a FileStream for the file named
         <fileName> in the receiver directory.  If the file
         does not exist, nil will be answered. The file opened
         will be read only."

    ^( PARTSTeamVFileDescriptor
            fileName: fileName in: self ) asReadStream!
partsRepositoryVolumeName
    "Answer the repository volume name to be used with
    the PARTS Workbench"

    ^RepositoryService currentVolume name

"    ^'PARTSWorkbench'"!  
restoreComment
    "When returning to a repository selection from a non-repository
    selection, set the comment pane to the prior comment.  If there
    is a selected revision, don't change the comment since the comment
    reflects the revision."

    application revisionListNumber notNil
        ifTrue: [ application selectComment ]
        ifFalse: [
            commentHolder isNil
                ifTrue: [ self setEnterCommentString ]
                ifFalse: [ self setCommentString: commentHolder ].
            commentHolder := nil ].!  
branch
    "Handle the #branch event for the dialog."
    | list revision |

    repositoryEntity isNil        "New entity"
        ifFalse: [
            list := application revisionList.
            ( revision := application revisionListNumber ) isNil
                ifTrue: [ revision := list first ].
            application setProposedRevision:
                ( PARTSTeamVInterface branchRevision: revision
                    repositoryEntity: repositoryEntity ) ]!  
backupComment
	"Save the user comment when the user selects a non-repository
	and the notRepositoryEntityString is displayed."

	application userCommented
		ifTrue: [ commentHolder := application comment trimBlanks ]!
aboutToUnbind: aLibrary
       " Private - a library necessary for repository support is about to be unbound.
    If repositories are in use, give the user a chance to abort."
    | repositoriesInUse |

    self isRepositoryComponentInstalled
        ifFalse: [ ^self ].

    repositoriesInUse :=
        ( ( ( PARTSFile currentSearchPath
            detect: [ :each | each isPARTSTeamVDirectory ]
            ifNone: [ nil] )
                notNil )
        or: [ PARTSTeamVFileDescriptor allInstances size > 0 ] ).

    repositoriesInUse
        ifTrue: [
            ( MessageBox confirm: 'Repositories are in use, do you really want to unbind ',
                 aLibrary name, '?' )
                ifFalse: [ aLibrary abortUnbind ]].

"#####
    MessageBox warning: 'Repositories will be removed from the search path.  ',
        'References to applications in repositories will no longer be supported.'
###"!  
isValidRepository: aRepository
    "Private"

    [ ^( aRepository notNil and: [
        aRepository isRepository and: [
        aRepository isOldStyleRepository not and: [
        aRepository exists ]]]) ]
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^false ]
!
isRepository: repositoryOrPathName
    "Given a potential name or path, answer whether it is a repository."
    | repository |

    (( repository :=
        self repositoryNamed: repositoryOrPathName ) notNil or: [
    ( repository :=
        self repositoryFromPath: repositoryOrPathName ) notNil ] )
        ifFalse: [ ^false ].

    ^self isValidRepository: repository!
setCommentForRevision: aRevisionNumber
    "Private - Given a revision number, set the author, time, and comment.
    Copied to PARTSPartBrowser."
    | author time comment anEntityRevision |

    repositoryEntity isNil
        ifTrue: [
            self setCommentString: self notRepositoryEntityString.
            ^nil ].

    ( anEntityRevision :=
        PARTSTeamVInterface
            revision: aRevisionNumber repositoryEntity: repositoryEntity ) isNil
        ifTrue: [
            comment := 'Comment could not be accessed' ]
        ifFalse: [
            comment := PARTSTeamVInterface commentFromRevision: anEntityRevision.
            ( comment isNil or: [ comment isEmpty ])
                ifTrue: [ comment := 'No comment' ]].

    ( anEntityRevision isNil
        or: [ ( author := PARTSTeamVInterface authorFromRevision: anEntityRevision ) isNil ])
        ifTrue: [ author := 'Author could not be accessed' ].

    ( anEntityRevision isNil
        or: [ ( time := PARTSTeamVInterface timeFromRevision: anEntityRevision ) isNil ])
        ifTrue: [ time := 'Time could not be accessed' ]
        ifFalse: [
            time := time dateAndTime.
            time := ( time at: 1 ) asString, ' ', ( time at: 2 ) asString ].

    application
        setRevisionHeading: 'By: ',author,' on: ',time;
        setComment: comment.!  
cleanUp
    "The receiver is being removed from the Workbench
    environment.  Remove the repository from the repository
    volume.  If there are any workbenches or nested parts or
    part accessors open on the repository, cancel the operation
    answer answer nil."
    | repositoryReference editors fileDescriptor |

    ( repositoryReference :=
        ( editors := PARTSEditor activeEditors ) detect: [ :anEditor |
            (( fileDescriptor := anEditor appFileDescriptor ) notNil
                and: [ fileDescriptor isPARTSTeamVFileDescriptor
                and: [ fileDescriptor repository = self repository ]])]
            ifNone: [ nil ]) isNil
        ifTrue: [
            editors detect: [ :anEditor |
                anEditor application notNil
                    ifTrue: [
                        repositoryReference := anEditor application componentDictionary
                            detect: [ :aComponent |
                                (( aComponent isPARTSNestedPart
                                    and: [ aComponent isLinked ])
                                or: [ aComponent isPARTSPartAccessorPart ])
                                    and: [( fileDescriptor := aComponent fileDescriptor ) notNil
                                    and: [ fileDescriptor isPARTSTeamVFileDescriptor
                                    and: [ fileDescriptor repository = self repository ]]]]
                                ifNone: [ nil ]].
                repositoryReference notNil ]
                    ifNone: [ nil ]].

    repositoryReference notNil
        ifTrue: [
            MessageBox warning: 'Could not close repository ''',
                self repository name,''' because it is referenced by ',
                ( repositoryReference isPARTSEditor
                    ifTrue: [ 'an editor' ]
                    ifFalse: [
                        repositoryReference isPARTSNestedPart
                            ifTrue: [ 'a linked nested part' ]
                            ifFalse: [ 'a part accessor part' ]]),'.'.
            ^nil ].

    super cleanUp.
    PARTSTeamVInterface removeRepository: self repository.!   
revisionChanged: revision
    "Private - Change the version comment.
    Copied to PARTSTeamVPartBrowser"

    revision notNil
        ifTrue: [ self setCommentForRevision: revision ]! 
COMMENT
"This is an abstract class defining extended behavior to the basic open and save file protocols by adding repository support. "! 
commentFromRevision: anEntityRevision
    "Extract the check-in comment from <anEntityRevision>."
    | aComment |

    [ ^( aComment := anEntityRevision comment ) notNil
        ifTrue: [ aComment ]
        ifFalse: [ '' ] ]
            on: RepositoryAccessDeniedError
            do: [ :e | self repositoryError: e. ^nil ]
!   
loadFromRepository: aRepository
entity: anRepositoryEntity
revision: revisionNumber
context: aPARTSStoreContext
    "Load a PARTSApplication whose external storage is
    <anRepositoryEntity> in <aRepository>, revision <revisionNumber>.
    NOTE: This loads an executable part and does not have all the workbench information.
        <aRepository> can be either a repository name or
    a directory."

    ^ ( self new
                forRepository: aRepository
                entity: anRepositoryEntity
                revision: revisionNumber )
        loadForExecuteWithContext: aPARTSStoreContext!  
realRepository: aRepository
    "Set the repository variable with no side effects."

    repository := aRepository!
repositoryName: repositoryOrName
    "Assign the value to repositoryName."
    | aRepository |

	repositoryOrName isNil
		ifTrue: [ ^nil ].

    repositoryOrName isString not
        ifTrue: [ "Repository"
            repositoryName := repositoryOrName name.
            aRepository := repositoryOrName ]
        ifFalse: [
            ( aRepository :=
                PARTSTeamVInterface repositoryNamed: repositoryOrName ) isNil
				ifTrue: [ ^nil ] ].

    self repository: aRepository.
    ^self repositoryName!  
nameFromContainer: aRepositorySystemContainer
    "Answer the name for <aRepositorySystemContainer>."

    [ ^aRepositorySystemContainer name ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ].
!   
isPARTSTeamVFileDescriptor
        "Answer whether the receiver is an instance of class
         isPARTSTeamVFileDescriptor or one of its subclasses."

    ^true!
revisionNumbersFromEntity: aRepositoryEntity
    "Answer a collection of revision strings."

    [ ^aRepositoryEntity revisionNumbers ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ].
!   
writeToStream: aWriteBlock
    "Evaluate the <aWriteBlock> with a writeStream.  Upon
    completion of the block, the revision associated with
    the receiver is committed and will be unable to write
    to the stream again."
    |  aStream anEntityRevision anEntity
        revisionNumbers revision |

    ( anEntity := self entityAssured ) isNil
            ifTrue: [ ^nil ].

    self revisionNumber isNil
        ifTrue: [
            self revisionNumber:
                (( revision := PARTSTeamVInterface
                    lastRevisionWithBranchesIn: anEntity ) notNil
                    ifTrue: [ revision ]
                    ifFalse: [ PARTSTeamVInterface defaultRevisionValue ])].

    revisionNumbers :=
        PARTSTeamVInterface
             revisionNumbersFromEntity: anEntity.
    ( revisionNumbers notNil and: [
        revisionNumbers notEmpty and: [
        revisionNumbers includes: self revisionNumber ]])
            ifTrue: [    "Can't overwrite existing version.  Bump number."
                self revisionNumber:
                    ( PARTSTeamVInterface
                        incrementRevision: self revisionNumber
                        repositoryEntity: anEntity )].

    [     anEntityRevision :=
            ( self realEntityRevision:
                ( PARTSTeamVInterface
                    revisionAssured: self revisionNumber
                    repositoryEntity: anEntity )).
        anEntityRevision isNil ifTrue: [ ^nil ].

        anEntityRevision comment: self proposedComment.

        ( aStream := self asWriteStream ) notNil
            ifTrue: [
                aWriteBlock value: aStream.
                aStream close ].

        anEntityRevision commit ]
            ifCurtailed: [
                anEntityRevision abort.
                aStream notNil ifTrue: [ aStream close ]].

    self proposedComment: nil.        "Don't need this anymore."!  
userName
    "Private - Answer the user name defined by Team/V"

    ^RepositoryService currentUser name!  
fileNameChanged: fileName
    "Private - When selecting files, display the revision list
    of the file.  Set the appropriate proposed revision for the
    selected file. Answer a repository entity if the name is valid."

    | aRepositoryEntity list proposedRevision |

    (( aRepositoryEntity := ( super fileNameChanged: fileName )) notNil and: [
            "Don't change anything if user selected 'ok' already"
        (self partNamed: 'OkButton') hasFocus not ])
        ifTrue: [
            ( list := PARTSTeamVInterface revisionNumbersFromEntity: aRepositoryEntity ) size > 0
                ifTrue: [ application setRevisionList: list reversed ].
            self setEnterCommentString.

            "Set the proposed revision"
            startFile isPARTSTeamVFileDescriptor
               ifTrue: [
                    ( selectedDirectory ~= startFile directory and: [
                        startFile revisionNumber notNil ])
                            ifTrue: [ "Not derived from current workbench app."
                                proposedRevision := list isEmpty
                                    ifTrue: [ nil ] ifFalse: [ list last ]]
                            ifFalse: [ "Increment current workbench app."
                                proposedRevision := startFile revisionNumber ]]
               ifFalse: [
                    proposedRevision := list isEmpty
                        ifTrue: [ nil ] ifFalse: [ list last ]].

            proposedRevision := proposedRevision isNil
                ifTrue: [ PARTSTeamVInterface defaultRevisionValue ]
                ifFalse: [
                    PARTSTeamVInterface
                        incrementRevision: proposedRevision
                        repositoryEntity: aRepositoryEntity ].
            application setProposedRevision: proposedRevision ]

        ifFalse: [ "New file"
            self selectedDirIsRepository
                ifTrue: [
                    application userCommented
                        ifFalse: [
                            application setComment: self enterCommentString ].
                    application
                        setRevisionList: nil;
                        setProposedRevision:
                            PARTSTeamVInterface defaultRevisionValue ]].

    ^aRepositoryEntity!
initializePartValues
        " Private - the dialog window application is about to be
        opened.  Initialize the items in the dialog based on the
        current values of the part. "

    super initializePartValues.

    application
        commentDisable;
        clearRevisionList.
    self setRevisionLabel.
! 
handlesOperation: anOperation
    "Answer whether the receiver handles <anOperation>"

    PARTSTeamVInterface hasRepositoryService
        ifFalse: [ ^false ].

    ^anOperation = #save! 
fileNameChanged: fileName
    "Private - Handle the file name changed event.
    Answer the repository entity for the file."
    | name |

    ( name := super fileNameChanged: fileName ) isNil
        ifTrue: [
            self setCommentString: nil.
            ^nil ].

    self selectedDirIsRepository
        ifTrue: [
            (( repositoryEntity :=
                PARTSTeamVInterface
                    entity: name
                    repository: selectedDirectory repository ) isNil )
                ifTrue: [
                    self existingFilesOnly
                        ifTrue: [
                            MessageBox message: 'File is not an archive.'.
                            ^nil ]
                        ifFalse: [ ^nil ]].
            ^repositoryEntity ]
        ifFalse: [ "Flat file"
            self setCommentString: self notRepositoryEntityString ].

    ^nil!   
entityAssured: anEntityName repository: aRepository
    "Answer an entity with the name <anEntityName> in
    <aRepository>.  If the entity doesn't exist yet, create it."
    | repositoryEntitySpec repositoryEntity |

    [ "Error handler"

    repositoryEntitySpec :=
        RepositoryEntitySpecClass new
            name: anEntityName asUpperCase;
            type: self partsRepositoryEntityType;
            yourself.

    repositoryEntity := repositoryEntitySpec asRepositoryEntityWithin: aRepository.
    repositoryEntity exists
        ifTrue: [ repositoryEntity open ]
        ifFalse: [ repositoryEntity create ].

    ^repositoryEntity

    ] "Error handler"
         on: RepositoryAccessDeniedError
         do: [ :e | self repositoryError: e. ^nil ].
!  
isPARTSTeamVDirectory
    "Answer whether the receiver is an instance of class
    PARTSTeamVDirectory or one of its subclasses."
    ^true!   
partMirrorCopyReal: aDictionary
    "Don't copy entity, repository, entityRevision, or directory
    They will be recreated when needed."

    self realRepository notNil
        ifTrue: [ aDictionary at: repository put: nil ].
    self realEntity notNil
        ifTrue: [ aDictionary at: entity put: nil ].
    self realEntityRevision notNil
        ifTrue: [ aDictionary at: entityRevision put: nil ].
	directory notNil
		ifTrue: [ aDictionary at: directory put: nil ].

    ^super partMirrorCopyReal: aDictionary.! 
repositoryFromPath: aPath ifAbsent: aBlock
    "Answer a repository on <aPath>. Evaluate <aBlock>
    if not found.  Open the repository if it is not opened.
    If the repository associated with <aPath> has the
    same name as an existing repository with a different
    path, close the existing repository and reconnect to
    the new one.
        <aPath> can also be a directory."
    | repository existingRepository dir |
    RepositoryService isNil
        ifTrue: [ ^aBlock value ].

    dir := aPath isDirectory
        ifTrue: [ aPath ]
        ifFalse: [ Directory pathName: aPath ].
    [( repository :=
        dir asRepositoryInRepositoryVolume: self partsRepositoryVolume ) exists
            ifFalse: [ ^aBlock value ]]
        on: ObsoleteRepositoryConnectionsAllowedError
        do: [ :ex | ex resume: false ].  "Prevent searching through obsolete repositories"

    [ "Error handler"

    repository isOpen
        ifFalse: [
            (( existingRepository :=
                    self partsRepositoryVolume repositoryNamed: repository name ) isNil
                or: [ existingRepository pathString equalsIgnoreCase: aPath ])
                ifFalse: [
                    existingRepository notNil
                        ifTrue: [ "old: existingRepository close"
                           existingRepository isOldStyleRepository
                               ifTrue: [ ^aBlock value ].
                           MessageBox warning:
                               'Repository conflict.  Existing repository on ',
                                   existingRepository pathString, ' will be used.'.
                            ^existingRepository  ]].
            repository isOldStyleRepository
                ifTrue: [ ^aBlock value ].
            repository open ].

    repository isOldStyleRepository
        ifTrue: [ ^aBlock value ].

    ^repository

    ] "Error handler"
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ].
! 
directory
    "Answer the directory.  If nil, load the repository,
    which will set the directory."

    directory isNil
        ifTrue: [ self repository ].
    ^directory! 
setRevisionLabel

    application setRevisionLabel: 'Existing revisions:'!  
repository
    "Answer the repository. If the repository is not loaded,
    reload it by setting the repository name again.
    If it still doesn't exist after that, answer nil."
    | aRepository |

    aRepository := self realRepository.

    aRepository isNil
        ifTrue: [
            self repositoryName: self repositoryName.
            aRepository := self realRepository ].

    ^aRepository!  
lastRevisionWithBranchesIn: aRepositoryEntity
    "Answer the latest revision in <aRepositoryEntity>.  This provides
    an alternative to the PVCS convention, and treats a revision's
    branches as being later than the revision itself."
    | max |

    [ "Error handler"

    max := RepositoryRevisionNumberClass fromString: self defaultRevisionValue.
    aRepositoryEntity revisionNumberList do: [ :aNumber |
        max := max max: aNumber ].
    ^max asString

    ] "Error handler"
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
! 
timeStamp
    "Answer the check in time stamp of the latest revision.  Latest,
    in this instance will be defined as the largest revision on the
    main     branch.  If that revision has branches, find the latest
    revision in the branches.
        NOTE: This method has the side effect of updating the receiver's
    revision value.  Use timeStamp: to avoid this side effect."
    | checkInTime |

    self insureCurrent.

    self entityRevision isNil
        ifTrue: [ ^nil ].

    ( checkInTime :=
        PARTSTeamVInterface timeFromRevision: self entityRevision ) isNil
        ifTrue: [ ^nil ].

    ^PARTSTimeStamp
        date: ( checkInTime date )
        time: ( checkInTime time )!
repositorySystemPathClass
    ^RepositorySystemPathClass!
checkForRepositoryComponent: aComponent
        " Private - a component has just been installed "

    self isRepositoryComponentInstalled
        ifTrue: [
            SessionModel current
                removeActionsWithReceiver: self
                forEvent: #libraryBound: .
            self checkRepositoryComponentUnbind.
            self initializeRevisionSupport ].! 
fileInUpgrade: anObjectFiler
        " Private - upgrade the receiver into the form expected in
        the current system.  Answer the upgraded object. "

    directory notNil
        ifTrue: [ directory := nil ].!  
setEnterCommentString
    "Set the comment prompt and highlight it.
	Special case: if comment holder is nil, don't set the
	enter comment string.  The user wants to see the
	user entered comment, which will be displayed later."

	commentHolder isNil
		ifTrue: [
		    self setCommentString: self enterCommentString.
		    application selectComment ].!  
existingFilesOnly
    "Answer whether the dialog should only allow
    existing files to be entered in the entry field."

    ^false! 
fromDisplayName: aDisplayName
    "Answer an instance of the receiver if <aDisplayName>
    corresponds to the display format answered by the
    method displayName"
    | displayName repository |

    displayName := aDisplayName trimBlanks.
    ^ ( displayName first = $( and: [
        displayName last = $) ])
        ifTrue: [
           ( repository := PARTSTeamVInterface repositoryNamed:
               ( displayName copyFrom: 2 to: displayName size - 1 )) isNil
               ifTrue: [ ^nil ].
            self fromPath: repository path ]
        ifFalse: [ nil ]!   
defaultRevisionValue
    "Answer the default initial value for a new revision"

    ^'0.1'!
incrementRevision: revisionString repositoryEntity: aRepositoryEntity
    "Answer the incremented revision of <revisionString> within the revisions
    of <aRepositoryEntity>."

    [ ^(( RepositoryRevisionNumberClass fromString: revisionString )
        incrementIn: aRepositoryEntity revisionNumberList ) asString ]
            on: RepositoryAccessDeniedError
            do: [ :e | self repositoryError: e. ^nil ]
!
hasFileNamed: fileName
    "Private - Answer <true> if the receiver contains a file
    named <fileName>. This class shows virtual entities,
    hiding repository specific implementation from users of this class."

    ^self hasEntityNamed: fileName!   
initializeEventHandlers
    " Private - the dialog window application has just been loaded.
        Register the event handlers for the items in the dialog."

    self initializeEventHandlersForSave.
    super initializeEventHandlers!   
latestRevision
    "Answer the latest revision number in the receiver's file.
    This does not set the receiver's revisionNumber"
    | aRepositoryEntity |

    ( aRepositoryEntity := self entity ) isNil
        ifTrue: [ ^nil ].

    ^PARTSTeamVInterface lastRevisionNumberIn: aRepositoryEntity! 
validExtension: selectedType between: fileNameType descriptor: aFileDescriptor

    ( selectedType = PARTSFileDescriptor fileTypeForAll type or: [
           fileNameType equalsIgnoreCase: selectedType ])
        ifTrue: [ ^true ].

    ^MessageBox confirm: 'File extension does not conform to the format
requested, save as type: ', fileNameType, '?'!
detachFilingSystem
    "Release references to filing system entities.
    Will be reloaded when necessary"

    self realEntity: nil.
    self realEntityRevision: nil.
    self realRepository: nil.!  
partsRepositoryEntityType
    "Answer the universal type for all repository
    entities created by PARTS Workbench."

    ^'PARTSWorkbench'! 
fileName: aName
    "Set the file name. The name looks like a standard
    dos file name."

    self entityName: aName!   
initializeEventHandlers
    " Private - the dialog window application has just been loaded.
    Register the event handlers for the items in the dialog."

    self initializeEventHandlersForOpen.
    super initializeEventHandlers.!  
revisionNumber: anAnswer fileName: fileName
    "Private - Validate and assign the answer's revision number
    to be saved.  If there is no revision number specified,
    increment the latest one."
    | aRepositoryEntity aRevisionNumber |

    aRevisionNumber := application proposedRevision.
    ( self isValidRevision: aRevisionNumber )
        ifFalse: [ ^nil ].

    aRevisionNumber isNil
        ifTrue: [
            ( aRepositoryEntity :=
                PARTSTeamVInterface
                    entity: fileName
                    repositoryPath: selectedDirectory absolutePathString ) isNil
                ifTrue: [ ^nil ].
            aRevisionNumber :=
                self getNextRevision: self startFile between: aRepositoryEntity ].

    answer revisionNumber: aRevisionNumber.!   
forRepository: aRepositoryOrNameOrDir entity: anEntityName
    "Answer an instance of the receiver. <aRepositoryOrNameOrDir> can be
	either a repository name or a directory or a repository. This does not
	check if the entity is valid."
	| repositoryOrName |

	repositoryOrName :=
		aRepositoryOrNameOrDir isDirectory
			ifTrue: [
				PARTSTeamVInterface repositoryFromPath: aRepositoryOrNameOrDir ]
			ifFalse: [
				aRepositoryOrNameOrDir ].

    ^ self new forRepository: repositoryOrName entity: anEntityName revision: nil!   
existingFilesOnly
    "Answer whether the dialog should only allow
    existing files to be entered in the entry field."

    ^true!  
repositoryError: anError
    "Private - Handle <anError> and return an error string"

    MessageBox message: anError defaultDescriptionString.

    ^anError defaultDescriptionString!  
initializeEventHandlersForSave
    "Initialize the events specific to #save"

    application
        when: #ok
            send: #okSave to: self;
        when: #revisionChanging
            send: #revisionChanging to: self;
        when: #increment
            send: #increment to: self;
        when: #branch
            send: #branch to: self;
        when: #release
            send: #release to: self!  
getRevisionList: aRepositoryEntity
    "Answer the revision list for the <aRepositoryEntity>"

    ^OrderedCollection with:
        ( PARTSTeamVInterface lastRevisionNumberIn: aRepositoryEntity )!  
entityRevision
    "Answer the entity revision.  If it is not loaded, set
    it based on all the names."

    | anEntityRevision aRepository aRepositoryEntity |

    ( anEntityRevision := self realEntityRevision ) notNil
        ifTrue: [ ^anEntityRevision ].

    ( aRepository := self repository ) isNil
        ifTrue: [ ^nil ].

    ( aRepositoryEntity := self entity ) isNil
        ifTrue: [ ^nil ].

    self revisionNumber isNil
        ifTrue: [ "get latest"
            self revisionNumber: ( PARTSTeamVInterface
                lastRevisionNumberIn: aRepositoryEntity ) ].

    anEntityRevision := PARTSTeamVInterface
        revision: self revisionNumber repositoryEntity: aRepositoryEntity.

    ^self realEntityRevision: anEntityRevision!  
loadForExecuteWithContext: aContext
    "Assign self as the application's file descriptor, instead
    of the temporary working file descriptor.  (Loading
    automatically sets the descriptor to the stream).
        Note: If this descriptor was created for a flat file in a
    repository, no app will be loaded and nil wil be answered.
    Flat files in repositories are not allowed and will be
    loaded incorrectly."
    | newApp |

    newApp := super loadForExecuteWithContext: aContext.
    newApp notNil
        ifTrue: [ newApp fileDescriptor: self ].
    ^newApp!   
repository: aRepository
    "Private"

    repository := aRepository!  
fileName
        " Private - Answer the name of the part file
        containing the dialog window. "

    ^'PWSAVREV.PAR'!   
notRepositoryEntityString
    ^'Not a repository entity.'!   
directorySelected: dir
    "A directory has been selected. Update the file list,
    the name field, and comment pane."

    super directorySelected: dir.

    self selectedDirIsRepository
        ifTrue: [
            application revisionEnable.
			self restoreComment.
			application proposedRevision isEmpty
				ifTrue: [ "Set initial value"
					application setProposedRevision:
						PARTSTeamVInterface defaultRevisionValue ] ]
        ifFalse: [
			self backupComment.
            self setCommentString: self notRepositoryEntityString.
            application revisionDisable ].!   
handlesOperation: anOperation
    "Answer whether the receiver handles <anOperation>."

    ^false!
validRevision: aRevisionNumberString
    "Answer whether <aRevisionString> is a
    valid format."

    [ ^( RepositoryRevisionNumberClass
        fromString: aRevisionNumberString ) isValid ]
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^false ].
!  
releaseRevision: revisionString repositoryEntity: aRepositoryEntity
    "Answer the next release revision of <revisionString> within the revisions
    of <repositoryEntity:>."

    [ ^(( RepositoryRevisionNumberClass fromString: revisionString )
        releaseIn: aRepositoryEntity revisionNumberList ) asString ]
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^nil ].
!  
fileNamesDo: iterationBlock
    "Private -Evaluate the <iterationBlock> once with the name of each file
     contained within the receiver.
        This class shows virtual files, hiding repository specific
     implementation to be hidden from users of this class.
        Warnings:
    - Modifications to the receiver's contents while executing this method may
    lead to missed or duplicated files."
    | path repositoryEntities |

    path := PARTSTeamVInterface repositorySystemPathClass
        volumeName: PARTSTeamVInterface partsRepositoryVolumeName
        repositoryName: ( PARTSTeamVInterface nameFromContainer: repository )
        repositoryEntityName: ''
        repositoryEntityType: PARTSTeamVInterface partsRepositoryEntityType
        revisionString: ''.

    ( repositoryEntities := PARTSTeamVInterface resolveMatchingInPath: path ) isNil
        ifTrue: [ ^nil ].
    repositoryEntities do: [ :aRepositoryEntity |
        iterationBlock value:
            ( PARTSTeamVInterface nameFromContainer: aRepositoryEntity ) ].
!
defaultFileName
    "Private - Answer the filename that first appears
    when the dialog opens."

    ^startFile isNil
        ifTrue: [ pattern]
        ifFalse: [ startFile fileName ]! 
allowBackUp
    "Do not allow backup since version is already kept."

    ^false!  
clearReferences
    "Private"

    self realEntity: nil.
    self realEntityRevision: nil.
    self realRepository: nil.
    self directory: nil.
!
revisionChanging
    "A new revision has been selected from the list.  Check
    if the user has modified the comment and wishes to
    discard the comment entry."

    ( application userCommented and: [
        ( MessageBox confirm:
            'The comment has been modified.  Discard changes?' ) not ])
        ifTrue: [ application abortRevisionChange ]!
removeRepository: aRepository
    "Private"

    [ aRepository remove ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
!
operation: anOperation title: aTitle
    "Prompt for file to open, allowing any revision to be selected"

    ^PARTSFileDescriptor promptForOpen: aTitle!  
pathFromContainer: aRepositorySystemContainer
    "Answer the path name for the repository, or
    containing repository."
    | aRepository |

    aRepository :=
        aRepositorySystemContainer isRepositoryEntity
            ifTrue: [
                self repositoryForEntity: aRepositorySystemContainer ]
            ifFalse: [
                aRepositorySystemContainer ].

    aRepository isNil ifTrue: [ ^nil ].

    ^aRepository pathString!   
repositoryForEntity: aRepositoryEntity
    "Answer the repository for <aRepositoryEntity>"

    [ ^aRepositoryEntity repository ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
!  
realRepository
    "Answer the repository variable without side effects"

    ^repository! 
displayName
    "Private - Answer the name to be shown when
    displaying the receiver.  A repository name will
    be answered"

    ^'(',(PARTSTeamVInterface nameFromContainer: repository), ') '!   
relativeDisplayName
    "Private - Answer the repository name of the
    receiver."

    ^'(',(PARTSTeamVInterface nameFromContainer: repository), ') '!  
getCopyWithExtension: anExtension
        "Private - answer a copy of the receiver with
        a stream with an extension of aString."
    | fileDescriptor |

    fileDescriptor := super getCopyWithExtension: anExtension.
    fileDescriptor revisionNumber: self revisionNumber copy.
    fileDescriptor detachFilingSystem.
    ^fileDescriptor!   
authorFromRevision: anEntityRevision
    "Answer the author of <anEntityRevision>"

    [ ^anEntityRevision author ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
!   
removeRevisionSupport
    "Remove the repository service.
    PARTSTeamVInterface removeRevisionSupport
    "

    PARTSFile setSearchPath:
        ( PARTSFile currentSearchPath select: [ :each | each isPARTSTeamVDirectory not ] ).

"    RepositoryVolumeClass closeVolumeNamed: self partsRepositoryVolumeName."

    RepositoryService
        removeActionsWithReceiver: self
        forEvent: #aboutToDisconnectRepository:.

"    ServiceRegistry globalRegistry
        unregister: #PARTSRepositoryServices."

    RepositoryService := nil.
    RepositoryRevisionNumberClass := nil.
    RepositorySystemPathClass := nil.
    RepositoryEntitySpecClass := nil.
    EntityRevisionSpecClass := nil.
    RepositoryVolumeClass := nil.
    RepositoryServicesClass := nil.
    ObsoleteRepositoryConnectionsAllowedError := nil.
    RepositoryAccessDeniedError := nil.

    self startupMessages do: [ :msg |
        SessionModel current
            removeAction: msg
            forEvent: #started ].
!  
realEntityRevision
    "Private - Answer the entity revision variable without side effects"

    ^entityRevision!  
timeStamp: aRevisionNumber
    "Answer the check in time stamp of <aRevisionNumber> version.
    The receiver's revision number is not modified.  This is an
    alternative to the timeStamp method."
    | aRepositoryEntity anEntityRevision checkInTime |

    ( aRepositoryEntity := self entity ) isNil ifTrue: [ ^nil ].

    anEntityRevision := PARTSTeamVInterface
        revision: aRevisionNumber repositoryEntity: aRepositoryEntity.
    anEntityRevision isNil
        ifTrue: [ ^nil ].

    ( checkInTime :=
        PARTSTeamVInterface timeFromRevision: anEntityRevision ) isNil
        ifTrue: [ ^nil ].

    ^PARTSTimeStamp
        date: ( checkInTime at: 1 )
        time: ( checkInTime at: 2 )!  
hash
    "Answer the integer hash value
    for the revision number of the receiver."
    ^( directory isNil
        ifTrue: [ self repositoryName ]
        ifFalse: [ self fullPathName ]) hash + self revisionNumber hash!
= aPathNameOrDescriptor
    "In addition to normal file descriptor comparison, check if
        revision numbers are the same."
	directory isNil
		ifTrue: [
			aPathNameOrDescriptor class == PARTSTeamVFileDescriptor
				ifFalse: [ ^false ].
			^self repositoryName = aPathNameOrDescriptor repositoryName ].

    ( super = aPathNameOrDescriptor )
        ifFalse: [ ^false ].

    ^self revisionNumber = aPathNameOrDescriptor revisionNumber!  
isValidRevision: aRevisionNumber
    "Answer whether <aRevisionNumber> is a valid
    format.  Nil is ok."

    aRevisionNumber isNil
        ifTrue: [ ^true ].

    ( application revisionList includes: aRevisionNumber )
        ifTrue: [
            MessageBox message: 'Cannot overwrite an existing version.'.
            ^false ].

    ( PARTSTeamVInterface validRevision: aRevisionNumber )
        ifFalse: [
            MessageBox message: 'Invalid revision number.'.
            ^false ].
    ^true! 
partMirrorCopyReal: aDictionary

	self ASSERT: false.  "Shouldn't mirror copy this"!
stringFrom: aFileNameOrEntity in: aPathOrContainer
    "Answer the virtual absolute path with the parameters"
    | fileName directoryPath |

    fileName := aFileNameOrEntity isString
        ifTrue: [ aFileNameOrEntity ]
        ifFalse: [ aFileNameOrEntity name ].

    aPathOrContainer isNil ifTrue: [ ^fileName ].

    directoryPath := aPathOrContainer isRepository
        ifTrue: [
            PARTSTeamVInterface pathFromContainer: aPathOrContainer ]
        ifFalse: [
            aPathOrContainer ].

    directoryPath isNil ifTrue: [ ^'' ].

    ^super stringFrom: fileName in: directoryPath
!   
selectedDirIsRepository
    "Answer whether the selected dir is a repository.
    The directory list is a list of directory objects.
    Copied to PARTSPartBrowser"

	^( selectedDirectory notNil and: [
    	selectedDirectory isPARTSTeamVDirectory ])!  
fileType: aFileType
    "Assign the file type. The type looks like a standard
    dos file extension."

    fileType := aFileType asUpperCase.!   
okToSave: aFileDescriptor
    "Can't overwrite a repository entity.  Can only append.
    Can't save a non-editable file type into a repository."

    ( self selectedDirIsRepository and: [
        ( PARTSFileProcessor getProcessorFor: aFileDescriptor ) class canEdit not ])
        ifTrue: [
            MessageBox message:
                'Cannot save type ',aFileDescriptor fileType,' into a repository.'.
            ^false ].

    aFileDescriptor isPARTSTeamVFileDescriptor
        ifTrue: [ ^true ].

    ( PARTSFile exists: aFileDescriptor )
        ifTrue: [
            ^( MessageBox confirm:
                answer displayName, ' already exists.  Replace file?' )].

    ^true.!
proposedComment: aComment
    "This sets the comment to be used when the
    proposed revision is committed."

    proposedComment := aComment.
    ^aComment!   
entity
    "Answer the entity.  If it is not set, retrieve it from the
    repository."
    | anEntity aRepository |

    ( anEntity := self realEntity ) notNil
        ifTrue: [ ^anEntity ].

    ( aRepository := self repository ) isNil
        ifTrue: [ ^nil ].

    anEntity := PARTSTeamVInterface
        entity: self entityName repository: aRepository.

    ^self realEntity: anEntity!  
forRepository: aRepositoryOrName entity: anEntityName revision: aRevisionNumber
    "Answer an instance of the receiver. <aRepositoryOrName> can be either a
    repository name or a directory pathName or a repository."

    ( self repositoryName: aRepositoryOrName ) isNil
        ifTrue: [ ^nil ].

    self entityName: anEntityName.
    self revisionNumber: aRevisionNumber.
    self fileType: anEntityName fileExtension.! 
fileName
        " Private - Answer the name of the part file
        containing the dialog window. "

    ^'PWOPNREV.PAR'!   
getRevisionList: aRepositoryEntity
    "Answer the revision list for the <aRepositoryEntity>"

    ^PARTSTeamVInterface revisionNumbersFromEntity: aRepositoryEntity.! 
release
    "Handle the #release event for the dialog."
    | revision |

    application setProposedRevision:
        ( repositoryEntity notNil
            ifTrue: [
                ( revision := application revisionListNumber ) isNil
                    ifTrue: [ revision := application revisionList first ].
                PARTSTeamVInterface
                    releaseRevision: revision
                    repositoryEntity: repositoryEntity ]
            ifFalse: [    "New entity"
                '1.0' ])!  
hasRepositoryService
    "Answer whether the repository component has been installed."

    ^RepositoryService notNil! 
handlesOperation: anOperation
    "Answer whether the receiver handles <anOperation>"

    PARTSTeamVInterface hasRepositoryService
        ifFalse: [ ^false ].

    ^anOperation = #openLatest or: [ anOperation = #import ]! 
hasEntityNamed: entityName
    "Private - Answer <true> if the receiver contains an entity
    named <entityName>. This class shows virtual entities,
    hiding repository specific implementation from users of this class."

    self fileNamesDo: [ :aRepositoryEntityName |
        ( aRepositoryEntityName equalsIgnoreCase: entityName )
            ifTrue: [ ^true ]].

    ^false! 
initializeEventHandlers
        " Private - the application has just been loaded.
        Register event handlers for parts in the application."

    super initializeEventHandlers.
    application
        when: #revisionChanged:
            send: #revisionChanged: to: self! 
repositoryNamed: aRepositoryName
    "Search the open repositories for a valid repository whose
    name matches <aRepositoryName>.
        Note: The repository may exist, but must have a connection
    established by 'repositoryFromPath:' first."

    RepositoryService isNil
        ifTrue: [ ^nil ].

    [ ^RepositoryService repositoryNamed: aRepositoryName ifAbsent: [ nil ]]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ].
!
revisionNumber
    "Answer the revision number."

    ^revisionNumber! 
store: aPart libraryMappings: libraryMappings
    "Save <aPart> into the external storage described
    by the receiver.  <libraryMappings> is a dictionary
    mapping classes to their library names."
    | application |

        ( application :=
            super
                store: aPart
                libraryMappings: libraryMappings ) isNil
            ifTrue: [ self revisionNumber: nil ]. "Save failed"

    ^ application!
forRepository: aRepositoryOrName entity: anEntityName revision: aRevisionNumber
    "Answer an instance of the receiver. <aRepositoryOrName> can be either a
    repository name or a directory pathName or a repository. This does not check
	if the entity is valid."

    ^ self new forRepository: aRepositoryOrName entity: anEntityName revision: aRevisionNumber! 
lastRevisionNumberIn: aRepositoryEntity
    "Answer the latest revision number in <aRepositoryEntity>."
    | numbers |

    [ ^( numbers := aRepositoryEntity revisionNumberList ) notEmpty
        ifTrue: [ numbers last asString ]
        ifFalse: [ nil ] ]
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^nil ]
!   
repository
    "Private - Answer the repository represented by the receiver."

    ^repository!
asWriteStream
    "Answer the file descriptor's file as a write stream."
    | anEntityRevision |

    ( anEntityRevision := self entityRevision ) isNil
        ifTrue: [ ^nil ].

    ^anEntityRevision writeStream asByteFileStream.!   
entityName: anEntityName
    "Private -
    Assign a new entity name.  The name will correspond
    to a standard dos file name."

	entityName ~= anEntityName
		ifTrue: [
		    entityName := anEntityName.
		    self realEntity: nil.
		    self revisionNumber: nil ].

    ^anEntityName! 
entity: anEntityName repository: aRepository
    "Answer an existing entity named <anEntityName>
    in <aRepository>.  Answer nil if no entity exists."
    | repositoryEntitySpec aRepositoryEntity |

    [ "Error handler"

    ( self isValidRepository: aRepository )
        ifFalse: [ ^nil ].

    repositoryEntitySpec :=
        RepositoryEntitySpecClass new
            name: anEntityName asUpperCase;
            type: self partsRepositoryEntityType;
            yourself.

    aRepositoryEntity := repositoryEntitySpec asRepositoryEntityWithin: aRepository.
    ^aRepositoryEntity exists
        ifTrue: [ aRepositoryEntity ]
        ifFalse: [ nil ]

    ] "Error handler"
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
!  
timeFromRevision: anEntityRevision
    "Answer the time stamp of the revision's check in.
    It will be a two element array with a date object at
    position one, and a time object at position two."

    [ ^anEntityRevision timeStamp ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ].
!   
loadForEditWithContext: aContext
    "Assign self as the application's file descriptor, instead
    of the temporary working file descriptor.  (Loading
    automatically sets the descriptor to the stream).
        Note: If this descriptor was created for a flat file in a
    repository, no app will be loaded and nil wil be answered.
    Flat files in repositories are not allowed and will be
    loaded incorrectly."
    | newApp |

    newApp := super loadForEditWithContext: aContext.
    newApp notNil
        ifTrue: [ newApp fileDescriptor: self ].
    ^newApp! 
okOpen
    " Private - the OK button has been pressed in an
    Open File dialog. "
    | fileName fileTypeForAll typeDetected allTypeExists |

    ( fileName := self fileNameField ) isEmpty
        ifTrue: [ ^nil ].

    (fileName includes: $*)
        ifTrue: [
            ^application fileNameChanged: fileName ].

    answer :=
        PARTSFileDescriptor
            pathName: ( self getPathName: fileName )
            in: selectedDirectory.

    "Detect if answer type isn't in the file type list and can't edit the type"
    fileTypeForAll := PARTSFileDescriptor fileTypeForAll.
    allTypeExists := false.
    typeDetected := ( fileTypes detect: [ :aPartFileType |
        aPartFileType type = fileTypeForAll type
            ifTrue: [ allTypeExists := true ].
        aPartFileType type = answer fileType ] ifNone: [ nil ]) notNil.
    ( typeDetected or: [
        ( allTypeExists
            and: [ ( PARTSFileProcessor getProcessorFor: answer ) class canEdit ])])
        ifFalse: [
            MessageBox warning: 'Loading a file of type ',
                answer fileType,' is not supported.'.
            ^answer := nil ].

    answer isPARTSTeamVFileDescriptor
        ifTrue: [    "If revisionNumber is nil, latest will be opened."
            answer revisionNumber: application revisionListNumber ].
        self class lastDirectoryUsed: selectedDirectory.
    self setCommentString: nil.
    application closeWindow.!
directorySelected: dir
    "A directory has been selected.  Update the file list.
    Copied to PARTSPartBrowser."
    | filename |

    super directorySelected: dir.

    self selectedDirIsRepository
        ifTrue: [
            filename := self fileNameField.
            ( selectedDirectory validFile: filename )
                ifTrue: [
                    "Select the file in the file list and explicitly trigger
                        the changed event to update the comment pane,
                        since a changed event only occurs if the value is
                        different."
                    application selectFile: filename.
                    application fileNameChanged: filename ]
                ifFalse: [
                    application clearRevisionList ]]
        ifFalse: [ application setRevisionList: nil ].! 
realEntity
    "Private - Answer the entity variable without any side effects."

    ^entity!  
realEntityRevision: anEntityRevision
    "Private - Set and answer the entity revision variable
    without side effects."

    entityRevision := anEntityRevision.
    ^anEntityRevision!   
resolveMatchingInPath: aRepositorySystemPath
    "Private - Answer the list of entities referenced by the receiver."

    ^[ aRepositorySystemPath resolveMatching ]
        on: RepositoryAccessDeniedError
        do: [ :e | self repositoryError: e. ^nil ]
!   
proposedComment
    "Answer the comment associated with the receiver.
    This is used during save time."

    ^proposedComment isNil
        ifTrue: [ '' ]
        ifFalse: [ ^proposedComment ]! 
repositoryName
    "Answer the repository name.  This is not a pathname."

    ^repositoryName!
revision: revisionString repositoryEntity: aRepositoryEntity
    "Answer an entity revision with the revision number
    <revisionString> in the entity <aRepositoryEntity>."

    [ ^aRepositoryEntity revisionForRevisionNumber:
        ( RepositoryRevisionNumberClass fromString: revisionString )]
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^nil ]
! 
partsRepositoryVolume
    "Answer the repository volume to be used with
    the PARTS Workbench.  Open it if not opened yet."

    ^RepositoryService currentVolume  "Default volume"

    "    [ ^RepositoryVolumeClass openVolumeNamed:
        self partsRepositoryVolumeName ]
    on: RepositoryAccessDeniedError
    do: [ :e | self repositoryError: e. ^nil ]"
!
entity: anEntityName repositoryPath: repositoryPath
    "Answer an entity for the <repositoryPath> and <anEntityName>."
    | aRepository |

    ( repositoryPath isNil or: [ anEntityName isNil ])
        ifTrue: [ ^nil ].

    aRepository := self repositoryFromPath: repositoryPath.
        "Check for nil done below"
    ^self entity: anEntityName repository: aRepository!
initializeEventHandlersForOpen
    "Initialize the events specific to #open"

    application
        when: #ok
            send: #okOpen to: self!  
setRevisionLabel

    application setRevisionLabel: '  Latest revision:'!   
operation: anOperation title: aTitle
    "Prompt for file to open, allowing any revision to be selected"
    | fileTypes |
    fileTypes := PARTSFileDescriptor fileTypesForEditing.
    anOperation = #import
        ifTrue: [ fileTypes add: PARTSFileDescriptor fileTypeForExecutablePart ].
    fileTypes add: PARTSFileDescriptor fileTypeForAll.

    ^PARTSFileDescriptor
        promptDialog: #openLatest
        initialFile: nil
        fileTypes: fileTypes
        defaultPattern: fileTypes first pattern
        title: aTitle! 
enterCommentString

    ^'Enter a comment for the proposed revision'!   
realEntity: aRevisonEntity
    "Private - Assign the entity variable without side effects."

    entity := aRevisonEntity.

    ^aRevisonEntity! 
asReadStream
    "Answer the file descriptor's file as a read stream."
    | anEntityRevision stream |

    ( anEntityRevision := self entityRevision ) isNil
        ifTrue: [ ^nil ].

    stream := anEntityRevision readStream asByteFileStream.

    stream reset.

    ^stream!  
fileNameChanged: fileName
    "Private - When selecting files, display the latest comment of
    the selected file.  Answer a repository entity if fileName is
    valid."
    | aRepositoryEntity list |

    ( aRepositoryEntity := ( super fileNameChanged: fileName )) notNil
        ifTrue: [
            ( list := self getRevisionList: aRepositoryEntity ) size = 0
                ifTrue: [ application clearRevisionList ]
                ifFalse: [
                    application
                        setRevisionList: list reversed;
                        setRevisionListNumber: list last ]].
    ^aRepositoryEntity!  
directorySelected: dir
    "A directory has been selected. Update the file list,
    the name field, and comment pane."


    super directorySelected: dir.

    self selectedDirIsRepository
        ifTrue: [
            "Clear the old comment unless the comment was set by super
                because file name exists in selected directory"
            ( selectedDirectory validFile: self fileNameField )
                ifFalse: [ self setCommentString: nil ]]
        ifFalse: [
            application setRevisionList: nil.
            self setCommentString: self notRepositoryEntityString ].! 
increment
    "Handle the #increment event for the dialog."
    | revision |

    repositoryEntity isNil        "New entity"
        ifFalse: [
            ( revision := application revisionListNumber ) isNil
                ifTrue: [ revision := application revisionList first ].
            application setProposedRevision:
                ( PARTSTeamVInterface
                    incrementRevision: revision
                    repositoryEntity: repositoryEntity ) ]!
fromLocator: aFileSystemLocator
    "Private - private instance creation method used primarily by FileSystemLocators to
        create instances of the appropriate FileSystemEntity subclass."
    | dir repository |

    repository := PARTSTeamVInterface
        repositoryFromPath: aFileSystemLocator asFileSystemPath absolutePath asString.

    repository notNil
        ifTrue: [
            dir := self basicFromLocator:aFileSystemLocator.
            dir repository: repository ]
        ifFalse: [
            dir := nil ].

    ^dir!