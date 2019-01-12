package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;

public class Proxy {

	public static final int PORT = 23;

	private DatagramSocket socketIn, socketOut;
	private SocketAddress serverAddress;

	public Proxy() throws SocketException {
		socketIn = new DatagramSocket(PORT);
		socketOut = new DatagramSocket();
//			socketOut.connect();
		socketOut.setSoTimeout(1000);
		serverAddress = new InetSocketAddress("localhost", Server.PORT);
	}

	private void run() {
		System.out.printf("Proxy waiting on port %d ...\n", socketIn.getLocalPort());
		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			try {
				socketIn.receive(packet);
				SocketAddress clientAddress = packet.getSocketAddress();
				data = Arrays.copyOf(packet.getData(), packet.getLength());
				TFTPPacket.received(packet.getSocketAddress(), data);
				packet.setSocketAddress(serverAddress);
				socketOut.send(packet); // sends to server
				TFTPPacket.sent(packet.getSocketAddress(), data);

				// use socketOut below if server responds on same socket, port 69
				socketOut.receive(packet);
				data = Arrays.copyOf(packet.getData(), packet.getLength());
				TFTPPacket.received(packet.getSocketAddress(), data);
				packet.setSocketAddress(clientAddress);
				socketIn.send(packet);
				TFTPPacket.sent(packet.getSocketAddress(), data);
			} catch (IOException e) {
				e.printStackTrace();
				System.exit(2);
			}
		}
	}

	public static void main(String[] args) throws SocketException {
		new Proxy().run();
	}
}