# Assignment 1 - Mini "TFTP" System

This project implements a three-process client-server architecture with the addition of proxies. It makes the use of DatagramSockets and DatagramPackets to transfer byte arrays between seperate machines over UDP/IP.

## Files
- Server.java: Replies to any valid TFTP requests with either 0301 or 0400 
- Proxy.java: Acts as a middle-man between client and server
- Client.java: Makes 11 TFTP requests to the server: reads, writes and an invalid
- TFTPPacket.java: Holds some helper functions related to the TFTP packets

## Setup Instructions
1. Import from archive file
2. Run Server: `java pw.micmax.sysc3303.a1.Server`
3. Run Proxy: `java pw.micmax.sysc3303.a1.Proxy <hostname>`
4. Run Client: `java pw.micmax.sysc3303.a1.Client <hostname>`

In Eclipse run them by right-clicking the file and selecting "Run as... Java Application"  
Make sure to set in the arguments tab of the configuration any command line arguments required.  

## UML Diagrams

The UML diagrams are located in the diagrams folder. The `sequence.html` file represents the transfer of data between the three instances of Server, Proxy and Client over time.  
The UML class diagram file named `class.html` shows the parts of the system and how they are related to each other and share access to certain parts of the code.  
The UCM diagram is named `ucm.html` and the three UML collaboration diagrams are named according to the classes with collab as a prefex, e.g. `collab-client.html`.