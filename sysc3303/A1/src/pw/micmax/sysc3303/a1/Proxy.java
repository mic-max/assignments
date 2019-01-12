package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;

public class Proxy {

	public static final int PORT = 23;

	private DatagramSocket socketIn, socketOut;
	private SocketAddress serverAddress;

	public Proxy(String hostname) throws SocketException {
		socketIn = new DatagramSocket(PORT);
		socketOut = new DatagramSocket();
		socketOut.setSoTimeout(1000);
		serverAddress = new InetSocketAddress(hostname, Server.PORT);
	}

	private void run() {
		System.out.printf("Proxy waiting on port %d ...\n", socketIn.getLocalPort());
		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			try {
				socketIn.receive(packet); // Receive from client.
				// Save the address of the client to send the next response to.
				SocketAddress clientAddress = packet.getSocketAddress();
				data = Arrays.copyOf(packet.getData(), packet.getLength());
				TFTPPacket.received(packet.getSocketAddress(), data);
				packet.setSocketAddress(serverAddress);
				socketOut.send(packet); // Send to server.
				TFTPPacket.sent(packet.getSocketAddress(), data);

				socketOut.receive(packet); // Receive from server.
				data = Arrays.copyOf(packet.getData(), packet.getLength());
				TFTPPacket.received(packet.getSocketAddress(), data);
				packet.setSocketAddress(clientAddress);
				socketIn.send(packet); // Send to client.
				TFTPPacket.sent(packet.getSocketAddress(), data);
			} catch (IOException e) {
				e.printStackTrace();
				System.exit(2);
			}
		}
	}

	public static void main(String[] args) throws SocketException {
		if (args.length != 1) {
			System.out.println("Usage: java Proxy <hostname>");
			System.exit(3);
		}
		new Proxy(args[0]).run();
	}
}