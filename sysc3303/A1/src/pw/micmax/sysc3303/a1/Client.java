package pw.micmax.sysc3303.a1;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.SocketException;
import java.nio.ByteBuffer;

public class Client {

	private static final int PORT = 23;
	private static final int BUF_SIZE = 32;

	private DatagramSocket socket;
	private ByteBuffer buffer;

	public Client() {
		try {
			socket = new DatagramSocket();
			socket.connect(new InetSocketAddress("localhost", PORT));
		} catch (SocketException e) {
			e.printStackTrace();
		}
		buffer = ByteBuffer.allocate(BUF_SIZE);
	}

	private void buildRequest(short reqType) {
		buffer.putShort(reqType);
		buffer.put("test.txt".getBytes());
		buffer.put((byte) 0);
		buffer.put("netascii".getBytes()); // convert to upper or lower..
		buffer.put((byte) 0);
	}

	public void run() {
		for (int i = 0; i < 11; i++) {
			buildRequest(i % 2 == 0 ? TFTPPacket.RRQ : TFTPPacket.WRQ);
			if (i == 10)
				buffer.put(0, (byte) 0xff); // corrupt data of packet #11
			DatagramPacket packet = new DatagramPacket(buffer.array(), buffer.limit());
			System.out.println(TFTPPacket.str(packet.getData(), buffer.position()));
			try {
				socket.send(packet);
				buffer.clear();
				socket.receive(packet);
				System.out.println(TFTPPacket.str(packet.getData(), packet.getLength()));
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static void main(String[] args) {
		new Client().run();
	}
}
