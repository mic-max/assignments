package pw.micmax.sysc3303.a1;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.SocketException;

public class Proxy implements Runnable {

	public static final int PORT = 23;
	
	private DatagramSocket socketIn;
	private DatagramSocket socketOut;
	private SocketAddress address;

	public Proxy() {
		try {
			socketIn = new DatagramSocket(PORT);
			socketOut = new DatagramSocket();
		} catch (SocketException e) {
			e.printStackTrace();
		}
		address = new InetSocketAddress("localhost", Server.PORT);
	}

	private void forwardPacket() {

	}

	@Override
	public void run() {
		System.out.printf("TFTP proxy started on port %d ...", socketIn.getLocalPort());
		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packetIn = new DatagramPacket(data, data.length);
			SocketAddress addr;
			try {
				socketIn.receive(packetIn);
				addr = packetIn.getSocketAddress();
				System.out.println(TFTPPacket.str(packetIn.getData(), packetIn.getLength()));
				DatagramPacket packetOut = new DatagramPacket(data, data.length, address);
				socketOut.send(packetOut);

				socketOut.receive(packetIn);
				System.out.println(TFTPPacket.str(packetIn.getData(), packetIn.getLength()));
				packetOut = new DatagramPacket(data, data.length, addr);
				socketOut.send(packetOut);
			} catch (IOException e) {
				e.printStackTrace();
			}

		}
	}

	public static void main(String[] args) {
		new Proxy().run();
	}
}
