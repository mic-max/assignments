3.1.0.106
   
shellOpen: aPathName
        "Open the file named by aPathName, using the program associated
        with that file's file type in the Registration Database (as specified using
        the Windows File Manager)."
    ^self shellExecute: aPathName operation: 'open'! 
findExecutable: aPathName
        "Answer the filename of the program associated with the file type
        of the file specified by aPathName in the Registration Database
        (as specified using the Windows File Manager)."
    | buffer array result dirName fileName |
    array := self splitPath: aPathName in: Disk.
    dirName := ( ( String with: ( array at: 1 ) with: $: ),
        ( ( array at: 2 ) isEmpty ifTrue: [ '\' ] ifFalse: [ array at: 2 ] ) ).
    fileName := array at: 3.
    buffer := String new: 255.
    result := ShellDLL current findExecutable: fileName dir: dirName buffer: buffer.
    result < 32
        ifTrue: [
            result = 31 ifTrue: [ ^nil ]. "no association exists"
            ^self osError: result ]
        ifFalse: [ ^buffer trimNullTerminator ]!
shellExecute: hwndParent
        operation: operation
        file: fileName
        params: params
        dir: dirName
        show: swConst
    <api: ShellExecuteA ulong struct struct struct struct short ulongReturn>
    ^self invalidArgument! 
shellExecute: aPathName operation: operation
        "Private - perform the given operation (open or print) on the file named
        by aPathName, using the program associated with that file's file type
        in the Registration Database (as specified using the Windows File Manager)."
    | array fileName dirName owner result |
    array := self splitPath: aPathName in: Disk.
    dirName := ( ( String with: ( array at: 1 ) with: $: ),
        ( ( array at: 2 ) isEmpty ifTrue: [ '\' ] ifFalse: [ array at: 2 ] ) ).
    fileName := array at: 3.
    owner := Notifier activeMainWindow.
    result := ShellDLL current
        shellExecute: owner handle
        operation: operation
        file: fileName
        params: nil
        dir: dirName
        show: SwShow.
    result < 32 ifTrue: [
        result = 31 ifTrue: [ ^nil ].  "no association found"
        self osError: result ]!
shellPrint: aPathName
        "Print the file named by aPathName, using the program associated
        with that file's file type in the Registration Database (as specified using
        the Windows File Manager)."
    | result |
    ( result := self shellExecute: aPathName operation: 'print' ) isNil ifTrue: [
        ( MessageBox confirm: 'No association exists for this file.  Print using Notepad?' ) ifTrue: [
            result := self.
            self execute: 'notepad.exe /p ', aPathName ] ].
    ^result!  
findExecutable: fileName dir: dirName buffer: buffer
    <api: FindExecutableA struct struct struct ulongReturn>
    ^self invalidArgument!