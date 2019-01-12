package pw.micmax.sysc3303.a1;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

public class Server {
	
	public static final int PORT = 69;

	private DatagramSocket socket;

	public Server() {
		try {
			socket = new DatagramSocket(PORT);
		} catch (SocketException e) {
			e.printStackTrace();
		}
	}
	
	private void receiveData(DatagramPacket packet) {
		byte[] data = packet.getData();

		// print received packet info
//		if (!TFTPPacket.isValid(packet))
//			throw new IOException("Malformed TFTP Request");
		if (data[1] == TFTPPacket.RRQ)
			packet.setData(new byte[] { 0, 3, 0, 1 });
		else if (data[1] == TFTPPacket.WRQ)
			packet.setData(new byte[] { 0, 4, 0, 0 });
		// print response packet info

		try {
			socket.send(packet);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void run() {
		System.out.printf("TFTP Server started on port %d ...", socket.getLocalPort());
		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			try {
				socket.receive(packet);
				new Thread(() -> receiveData(packet)).start();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static void main(String[] args) throws Exception {
		Server server = new Server();
		server.run();
		server.socket.close();
	}
}
