# Assignment 2 - Sandwich Making Chefs

This is an implementation of the classic Cigarette Smokers Problem, but with PB & Js.  
The output from the console is expected to be somewhat out of order due to each of the components running in separate threads. The delays in the program happen because the Consumer that needs the ingredients added by the Producer onto the Table is currently eating (Thread has been put to sleep for an amount of time). 

## Files
- `Main.java`: Runs 1 producer and 3 consumers using the same table.
- `Table.java`: Is used as a holding place for 2 ingredients, using synchronized get and put methods.
- `Producer.java`: Adds 2 random ingredients to the table whenever it can [20 times].
- `Consumer.java`: Each has an ingredient they have an unlimited supply of. They will execute as long as their producer is or the table has ingredients on it. If the table has the other 2 ingredients they need, they take it and then spend some time eating before they are able to get anything else from the table.

## Setup Instructions
1. Import from archive file
2. Right-click Main.java > Run As > Java Application.

## Output
TODO - Around 10% of the time the chef takes the wrong ingredients from the table...  
This can result in the program not exiting.  

```
 << [PeanutButter, Jam]
Bread Chef takes [PeanutButter, Jam]
 << [PeanutButter, Jam]
Bread Chef ate their sandwich.
Bread Chef takes [PeanutButter, Jam]
 << [Bread, PeanutButter]
 << [Bread, PeanutButter]
Jam Chef takes [Bread, PeanutButter]
Bread Chef ate their sandwich.
Jam Chef ate their sandwich.
Jam Chef takes [Bread, PeanutButter]
 << [Bread, PeanutButter]
 << [Bread, Jam]
PeanutButter Chef takes [Bread, PeanutButter] ---------- ERROR
Jam Chef ate their sandwich.
PeanutButter Chef ate their sandwich.
PeanutButter Chef takes [Bread, Jam]
 << [PeanutButter, Jam]
Bread Chef takes [PeanutButter, Jam]
 << [PeanutButter, Jam]
PeanutButter Chef ate their sandwich.
Bread Chef ate their sandwich.
Bread Chef takes [PeanutButter, Jam]
 << [Bread, Jam]
PeanutButter Chef takes [Bread, Jam]
 << [Bread, Jam]
Bread Chef ate their sandwich.
PeanutButter Chef ate their sandwich.
PeanutButter Chef takes [Bread, Jam]
Jam Chef takes [PeanutButter, Jam] --------------------- ERROR
 << [PeanutButter, Jam]
 << [PeanutButter, Jam]
 << [PeanutButter, Jam]
Bread Chef takes [PeanutButter, Jam]
PeanutButter Chef ate their sandwich.
Jam Chef ate their sandwich.
Bread Chef ate their sandwich.
Bread Chef takes [PeanutButter, Jam]
 << [Bread, PeanutButter]
Jam Chef takes [Bread, PeanutButter]
PeanutButter Chef takes [Bread, Jam]
 << [Bread, Jam]
 << [Bread, Jam]
Bread Chef ate their sandwich.
Jam Chef ate their sandwich.
PeanutButter Chef ate their sandwich.
PeanutButter Chef takes [Bread, Jam]
 << [PeanutButter, Jam]
Bread Chef takes [PeanutButter, Jam]
 << [Bread, Jam]
Jam Chef takes [Bread, Jam] ---------------------------- ERROR
 << [PeanutButter, Jam]
PeanutButter Chef ate their sandwich.
Bread Chef ate their sandwich.
Jam Chef ate their sandwich.
Bread Chef takes [PeanutButter, Jam]
 << [PeanutButter, Jam]
Bread Chef ate their sandwich.
Bread Chef takes [PeanutButter, Jam]
PeanutButter Chef is full.
Jam Chef is full.
Bread Chef ate their sandwich.
Bread Chef is full.
```
