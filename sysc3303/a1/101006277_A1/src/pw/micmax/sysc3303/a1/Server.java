package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;
import java.util.concurrent.*;

public class Server implements Callable<Void> {

	public static final int PORT = 69;

	private DatagramSocket socket;
	private DatagramPacket packet;

	public Server(DatagramPacket packet) {
		try {
			socket = new DatagramSocket();
			this.packet = packet;
		} catch (SocketException e) {
			e.printStackTrace();
		}
	}

	@Override
	public Void call() throws IOException {
		byte[] data = Arrays.copyOf(packet.getData(), packet.getLength());
		SocketAddress address = packet.getSocketAddress();
		TFTPPacket.received(address, data);

		// If the packet is invalid, the server throws an exception and quits.
		if (!TFTPPacket.isValid(data))
			throw new IOException("Malformed TFTP Packet");

		// Setting response message to 0301 for RRQs & 0400 for WRQs using math.
		try {
			packet.setData(new byte[] { 0, (byte) (data[1] + 2), 0, (byte) (-data[1] + 2) });
			packet.setSocketAddress(address);
			socket.send(packet); // Send to proxy.
			TFTPPacket.sent(packet.getSocketAddress(), packet.getData());
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	public static void main(String[] args) throws SocketException, Exception {
		ExecutorService executor = new ScheduledThreadPoolExecutor(5);
		DatagramSocket socketIn = new DatagramSocket(PORT);
		System.out.printf("TFTP Server waiting at %s:%d ...\n", InetAddress.getLocalHost(), socketIn.getLocalPort());

		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			socketIn.receive(packet); // Receive from proxy.
			Future<Void> future = executor.submit(new Server(packet));
			try {
				future.get();
			} catch (Exception e) {
				System.out.println("TFTP Server shutting down ...");
				e.printStackTrace();
				break;
			}
		}

		executor.shutdown();
		socketIn.close();
	}
}