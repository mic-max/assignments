3.1.0.106
   
partIsWindow
	"Private - When the a PARTSMenuPart is shrunk inside
        a PARTSWorkbench it is represented by an icon,
        and it is not to behave like a window."

	^self partIsShrunk not!  
tools
	" Return an ordered collection of tools contained in the receiver."

	| newTool control |
	(self partWrapper isNil)
		ifFalse:
			[tools := OrderedCollection new.
			self toolContainers
				do:
					[:c |
					c components
						do:
							[:each |
							newTool := (each object isPARTSToolbarItem
								ifTrue:
									[each object tool]
								ifFalse:
									[
									"Strip the index of non-toolbaritems because they are only valid within the Toolbox which contains them "
									control := each object.
									control index: nil.
									control]).
							tools add: newTool]].
			].
	^tools deepCopy !  
partCanBeNestedChild: aNestedPart
	"Private -  Answer whether the receiver could be a child
    of the nested part <aNestedPart>."

	^false!