# Assignment 4 - Reverse Engineer UML

## Files
- `uml-class-diagram.png`: The system's UML class diagram with annotated synchronization and relationships.
- `uml-communication-diagram.png`: Communincation between diagrams numbered by order
- `uml-sequence-diagram.png`: Shows the order of of communication over time between different components.

## Notes
Class
- Constructors must be sequential in Java so were left unlabelled in this regard.
- Similarly, abstract methods have no implementation so were left unlabelled.
- WorkerThread is an inner class to WorkQueue but this concept does not adapt well for the high level UML class diagrams, therefore I gave the class a «private» stereotype.

Sequence
- After main function terminates the other threads created from it will continue to execute normally.