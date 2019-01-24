# Assignment 2 - Sandwich Making Chefs

This is an implementation of the classic Cigarette Smokers Problem, but with PB & Js.  

## Files
- `Main.java`: Runs 1 producer and 3 consumers using the same table.
- `Table.java`: Is used as a holding place for 2 ingredients, using synchronized get and put methods.
- `Producer.java`: Adds 2 random ingredients to the table whenever it can [20 times].
- `Consumer.java`: Each has an ingredient they have an unlimited supply of. They will execute as long as their producer is or the table has ingredients on it. If the table has the other 2 ingredients they need, they take it and then spend some time eating before they are able to get anything else from the table.

## Setup Instructions
1. Import from archive file
2. Right-click Main.java > Run As > Java Application.
