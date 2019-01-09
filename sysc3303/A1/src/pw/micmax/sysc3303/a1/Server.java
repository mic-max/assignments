package pw.micmax.sysc3303.a1;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

public class Server implements Runnable {

	private DatagramSocket socket;
	private static final int PORT = 23;
	private static final int BUF_SIZE = 32;

	public Server() {
		try {
			socket = new DatagramSocket(PORT);
		} catch (SocketException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void run() {
		while (true) {	
			byte[] data = new byte[BUF_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			try {
				socket.receive(packet);
				data = packet.getData();
	
				// print received packet info
				if (!TFTPPacket.isValid(packet)) {
					System.out.println("Malformed TFTP Request.");
					break;
				}
				if (data[1] == TFTPPacket.RRQ)
					packet.setData(new byte[] { 0, 3, 0, 1 });
				else if (data[1] == TFTPPacket.WRQ)
					packet.setData(new byte[] { 0, 4, 0, 0 });
				// print response packet info
	
				socket.send(packet);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		socket.close();
	}

	public static void main(String[] args) throws Exception {
		new Server().run();
	}
}
