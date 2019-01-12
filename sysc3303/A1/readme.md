# Assignment 1 - Mini "TFTP" System


## Files
- Server.java: Replies to any valid TFTP requests with either 0301 or 0400 
- Proxy.java: Acts as a middle-man between client and server
- Client.java: Makes 11 TFTP requests to the server: reads, writes and an invalid
- TFTPPacket.java: Holds some helper functions related to the TFTP packets

## Setup Instructions
1. Import from archive file
2. Run Server
3. Run Proxy
4. Run Client


## UML Diagrams

The UML diagrams are located in the diagrams folder. The `sequence.html` file represents the transfer of data between the three instances of Server, Proxy and Client over time. The 
UML class diagram file named `class.html` shows the parts of the system and how they are related to each other and share access to certain parts of the code.


## TODO
- javadoc commenting
- test by running on multiple PCs, will have to change localhost in code
- test on lab PCs
- complete UMLs
- clean code more, make use of threads, common interface Listener, onReceive ...
