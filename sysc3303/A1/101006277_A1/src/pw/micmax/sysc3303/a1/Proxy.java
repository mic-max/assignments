package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;

public class Proxy {

	public static final int PORT = 23;

	private DatagramSocket socketIn, socketOut;
	private SocketAddress  serverAddress;

	public Proxy() throws SocketException {
		socketIn = new DatagramSocket(PORT);
		socketOut = new DatagramSocket();
		socketOut.setSoTimeout(1000);
		serverAddress = new InetSocketAddress("localhost", Server.PORT);
	}

	private void run() throws Exception {
		System.out.printf("Proxy waiting at %s:%d ...\n", InetAddress.getLocalHost(), socketIn.getLocalPort());
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

	public static void main(String[] args) throws Exception {
		new Proxy().run();
	}
}