package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;

public class Proxy {

	public static final int PORT = 23;

	private DatagramSocket socketIn, socketOut;

	public Proxy() {
		try {
			socketIn = new DatagramSocket(PORT);
			socketOut = new DatagramSocket();
			socketOut.connect(new InetSocketAddress("localhost", Server.PORT));
			socketOut.setSoTimeout(1000);
		} catch (SocketException se) {
			se.printStackTrace();
			System.exit(1);
		}
	}

	private void run() {
		System.out.printf("Proxy waiting on port %d ...\n", socketIn.getLocalPort());
		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packetIn = new DatagramPacket(data, data.length);
			try {
				socketIn.receive(packetIn);
				SocketAddress address = packetIn.getSocketAddress();
				data = Arrays.copyOf(packetIn.getData(), packetIn.getLength());
				System.out.println("\nPacket received from: " + packetIn.getSocketAddress());
				System.out.println(TFTPPacket.toString(data));
				packetIn.setSocketAddress(socketOut.getRemoteSocketAddress());
				socketOut.send(packetIn); // sends to server

				DatagramPacket packetOut = new DatagramPacket(data, data.length);
				socketOut.receive(packetOut);
				data = Arrays.copyOf(packetOut.getData(), packetOut.getLength());
				packetOut.setSocketAddress(address);
				System.out.println("Packet sent to: " + packetOut.getSocketAddress());
            	System.out.println(TFTPPacket.toString(data));
				socketIn.send(packetOut);
			} catch (IOException e) {
				e.printStackTrace();
				System.exit(2);
			}
		}
	}

	public static void main(String[] args) {
		Proxy proxy = new Proxy();
		proxy.run();
	}
}