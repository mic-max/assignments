"3.0.0.6"
!  

Bitmap subclass: #WBBitmap
  instanceVariableNames: ''
  classVariableNames: 
    ' LibraryCloserProcess OpenBitmapLibraries '
  poolDictionaries: ''!

!WBBitmap class methods ! 
libraryNamed: aPathName
	"Answer a bitmap libarary (DLL) with the specified name."

	| result |
	OpenBitmapLibraries isNil ifTrue: [
		self forkLibraryCloser.
		OpenBitmapLibraries := Dictionary new].
	^OpenBitmapLibraries at: aPathName ifAbsent: [
		(result := self openLibraryNamed: aPathName) notNil ifTrue: [
			OpenBitmapLibraries at: aPathName put: result].
		result].! !

!WBBitmap methods !
fromModule: aModuleName id: bitmapName
        "Private - Load the receiver from the module
        aModuleName with id bitmapName."

    | hLibrary bitmapStruct |
	aModuleName notNil ifTrue: [
		hLibrary := self class libraryNamed: aModuleName.
		hLibrary isNil ifTrue: [^self osError]].
    ( bitmapHandle := UserLibrary
        loadBitmap: hLibrary asParameter
        name: bitmapName asParameter ) = 0
            ifTrue: [ ^self osError ].

    "use archive to save dll name and id."
    archive := Array with: aModuleName with: bitmapName.
    GDILibrary
        getObject: bitmapHandle
        count: WinBitmapStruct sizeInBytes
        lpObject: ( bitmapStruct :=  WinBitmapStruct new ) asParameter.
    bitmapInfo := WinBitmapInfo
        width: bitmapStruct width
        height: bitmapStruct height
        planes: 1
        bitCount: bitmapStruct planes * bitmapStruct bitsPixel.
    deviceContext := self class memoryContext.
    graphicsTool := Pen forDC: deviceContext medium: self.
    graphicsTool
        width: bitmapInfo width;
        height: bitmapInfo height.
    self needsFinalization! !

!WBBitmap class methods !   
forkLibraryCloser
	"Private - Fork a low level process to close all open bitmap libraries."

	(Message
		receiver: self
		selector: #forkLibraryCloserPrim
			) performDeferred.! !

!WBBitmap class methods !
openLibraryNamed: aFileOrPathName
	"Private - Open the specified bitmap library (DLL) and answer the handle."

	| path |
	^(self openLibraryNamedPrim: aFileOrPathName) ifNil: [
		(path := File findFileName: aFileOrPathName fileNameLessPath) notNil
			ifTrue: [self openLibraryNamedPrim: path]
			ifFalse: [nil]]! !

!WBBitmap class methods !
closeLibrary: aLibraryHandle
	"Private - Close the specified library."

	(KernelLibrary freeLibrary: aLibraryHandle) ifFalse: [self osError].! !

!WBBitmap class methods !  
openLibraryNamedPrim: aFileOrPathName
	"Private - Open the specified bitmap library (DLL) and answer the handle."

	| answer |
	answer := KernelLibrary loadLibrary: aFileOrPathName asParameter.
	answer = 0 ifFalse: [^answer].
	^nil! !

!WBBitmap class methods ! 
forkLibraryCloserPriority
	"Answer the process priority for the library closer."

	^Processor backgroundPriority! !

!WBBitmap class methods !   
forkLibraryCloserPrim
	"Private - Fork a low level process to close all open bitmap libraries."

	[	[	OpenBitmapLibraries notNil ifTrue: [
				OpenBitmapLibraries do: [:each | self closeLibrary: each].
				OpenBitmapLibraries := nil].
		] evaluateWithoutInterrupts.
	] forkAt: self forkLibraryCloserPriority.! !

!UndefinedObject methods !
osiIgnoredInitializerSource !
 
UndefinedObject removeSelector: #osiIgnoredInitializerSource!
   
"======== Initializers"!

WBBitmapClass := WBBitmap.!