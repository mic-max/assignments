#include "a8Defs.h"

int gMySocket, gMyListenSocket;

int main() {
	while(1) {
		char input[MAX_STR];
		printf("Enter 'wait', 'talk', or 'exit': ");
		readString(input);
		if(!strcmp(input, "wait"))
			wait();
		else if(!strcmp(input, "talk"))
			talk();
		else if(!strcmp(input, "exit"))
			break;
		else 
			printf("Entered invalid command: %s\n", input);
	}
	return 0;
}

/*
	Function: wait
	 Purpose: runs a server that will wait for a client to connect, if successful, it will enter 'talk mode'
*/
void wait() {

	/* create socket */
	gMyListenSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (gMyListenSocket < 0) {
		printf("Couldn't open socket\n");
		return; // back to menu
	}

	/* setup my server address */
	struct sockaddr_in  myAddr;
	memset(&myAddr, 0, sizeof(myAddr));
	myAddr.sin_family = AF_INET;
	myAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	myAddr.sin_port = htons((unsigned short) SERVER_PORT);

	/* bind my listen socket */
	int i = bind(gMyListenSocket, (struct sockaddr *) &myAddr, sizeof(myAddr));
	if (i < 0) {
		printf("Couldn't bind socket\n");
		return; // back to menu
	}

	/* listen */
	i = listen(gMyListenSocket, 5);
	if (i < 0) {
		printf("Couldn't listen\n");
		return; // back to menu
	}

	/* wait for connection request */
	struct sockaddr_in clientAddr;
	int addrSize = sizeof(clientAddr);
	printf("Waiting for a user to connect...\n");
	gMySocket = accept(gMyListenSocket, (struct sockaddr *) &clientAddr, &addrSize);
	if (gMySocket < 0) {
		printf("Couldn't accept the connection\n");
		return; // back to menu
	}

	printf("User connected!\n");
	talkMode(1); // 1 -> receive first message
}

/*
	Function: talk
	 Purpose: asks for an IP address to connect to, then attempts to enter 'talk mode' with the other host
*/
void talk() {
	char ipAddress[MAX_STR];
	printf("Enter the server's IP Address [127.0.0.1]: ");
	readString(ipAddress);
	if(!strcmp(ipAddress, ""))
		strcpy(ipAddress, "127.0.0.1");

	printf("Attempting to connect to %s\n", ipAddress);
	/* create socket */
	gMySocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (gMySocket < 0) {
		printf("Couldn't open socket\n");
		return; // back to menu
	}

	/* setup address */
	struct sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(ipAddress);
	addr.sin_port = htons((unsigned short) SERVER_PORT);

	/* connect to server */
	int i = connect(gMySocket, (struct sockaddr *) &addr, sizeof(addr));
	if (i < 0) {
		printf("Client could not connect!\n");
		return; // back to menu
	}

	printf("Successfully connected to the server!\n");
	talkMode(0); // 0 -> send first message
}

/*
	Function: talkMode
	 Purpose: allows 2 users to chat back and forth.
	          can delay a user from entering a message for a certain amount of iterations
	      in: delay
*/
void talkMode(char delay) {
	printf("-------- TALK MODE --------\n");
	printf("# Type 'close' to exit talk mode.\n");
	char server = delay; // used to tell if the program is a client or server

	int bytesRcv;
	while(1) {
		// declare buffer every iteration to avoid unwanted data carrying over to the next iteration
		char buffer[MAX_STR];
		
		// only ask for input first if the the counter is greater than 0
		if(delay <= 0) {
			printf("YOU : ");
			readString(buffer);
			send(gMySocket, buffer, strlen(buffer), 0);

			if(!strcmp(buffer, "close"))
				break;
		}
		
		// Block and wait to receive data from the other user
		bytesRcv = recv(gMySocket, buffer, sizeof(buffer), 0);
		buffer[bytesRcv] = 0;
		// Check to see if the other user entered 'close' before printing it out
		if(!strcmp(buffer, "close"))
			break;
		printf("THEM: %s\n", buffer);
		delay--; // decrement counter so the server will receive a message
	}
	printf("-------- CLOSING CHAT --------\n");
	close(gMySocket);
	if(server)
		close(gMyListenSocket);
}