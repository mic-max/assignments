package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.nio.ByteBuffer;
import java.util.Arrays;

public class Client {

	public static final int MAX_SIZE = 32;

	private DatagramSocket socket;

	public Client() throws SocketException {
		socket = new DatagramSocket();
		socket.connect(new InetSocketAddress("localhost", Proxy.PORT));
		socket.setSoTimeout(1000);
	}

	private byte[] buildRequest(int reqType, String file, String mode) {
		final int SIZE = 4 + file.length() + mode.length();
		if (SIZE > MAX_SIZE)
			throw new IllegalArgumentException();

		final byte ZERO = 0;
		ByteBuffer buffer = ByteBuffer.allocate(SIZE);
		buffer.put(ZERO).put((byte) reqType);
		buffer.put(file.getBytes());
		buffer.put(ZERO);
		buffer.put(mode.getBytes());
		buffer.put(ZERO);
		return buffer.array();
	}

	private void run() {
		for (int i = 0; i < 11; i++) {
			// Creates alternating read and write requests.
			byte[] data = buildRequest((i & 1) + 1, "test.txt", "netASCII");
			if (i == 10)
				data[0] = (byte) 0x4d; // Corrupt data of packet #11.

			System.out.printf("\n%d %s\n", i + 1, "-".repeat(70));
			DatagramPacket packet = new DatagramPacket(data, data.length);
			try {
				socket.send(packet);
				TFTPPacket.sent(socket.getRemoteSocketAddress(), data);
				socket.receive(packet);
				data = Arrays.copyOf(packet.getData(), packet.getLength());
				TFTPPacket.received(packet.getSocketAddress(), data);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static void main(String[] args) throws SocketException {
		new Client().run();
	}
}
