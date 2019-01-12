package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;

public class Server {

	public static final int PORT = 69;

	private DatagramSocket socket;

	public Server() throws SocketException {
		socket = new DatagramSocket(PORT);
	}

	private void run() throws Exception {
		System.out.printf("TFTP Server waiting on port %d ...\n", socket.getLocalPort());
		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			try {
				socket.receive(packet);
				data = Arrays.copyOf(packet.getData(), packet.getLength());
				SocketAddress address = packet.getSocketAddress();
				TFTPPacket.received(address, data);

				if (!TFTPPacket.isValid(data))
					throw new Exception("Malformed TFTP Packet");

				// TODO create a new socket to send the packet back to the client/proxy
				DatagramSocket socketOut = new DatagramSocket();
				packet.setData(new byte[] { 0, (byte) (data[1] + 2), 0, (byte) (-data[1] + 2) });
				packet.setSocketAddress(address);
				socketOut.send(packet);
				TFTPPacket.sent(packet.getSocketAddress(), packet.getData());
				socketOut.close();
			} catch (IOException e) {
				e.printStackTrace();
				System.exit(2);
			}
		}
	}

	public static void main(String[] args) throws SocketException, Exception {
		new Server().run();
	}
}