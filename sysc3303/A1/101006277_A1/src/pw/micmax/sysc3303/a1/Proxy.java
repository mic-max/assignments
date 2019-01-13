package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;
import java.util.concurrent.*;

public class Proxy implements Callable<Void> {

	public static final int PORT = 23;

	private DatagramSocket socket;
	private DatagramPacket packet;
	private SocketAddress  serverAddress;

	public Proxy(String hostname, DatagramPacket packet) throws SocketException {
		socket = new DatagramSocket();
		socket.setSoTimeout(Client.TIMEOUT);
		serverAddress = new InetSocketAddress(hostname, Server.PORT);
		this.packet = packet;
	}

	@Override
	public Void call() throws IOException {
		// Save the address of the client to send the next response to.
		SocketAddress clientAddress = packet.getSocketAddress();
		byte[] data = Arrays.copyOf(packet.getData(), packet.getLength());
		TFTPPacket.received(packet.getSocketAddress(), data);
		packet.setSocketAddress(serverAddress);
		socket.send(packet); // Send to server.
		TFTPPacket.sent(packet.getSocketAddress(), data);

		socket.receive(packet); // Receive from server.
		data = Arrays.copyOf(packet.getData(), packet.getLength());
		TFTPPacket.received(packet.getSocketAddress(), data);
		packet.setSocketAddress(clientAddress);
		socket.send(packet); // Send to client.
		TFTPPacket.sent(packet.getSocketAddress(), data);
		return null;
	}

	public static void main(String[] args) throws Exception {
		if (args.length < 1) {
			System.out.println("Usage: java Proxy <hostname>");
			System.exit(1);
		}

		ExecutorService executor = new ScheduledThreadPoolExecutor(5);
		@SuppressWarnings("resource")
		DatagramSocket socketIn = new DatagramSocket(PORT);
		System.out.printf("Proxy waiting at %s:%d ...\n", InetAddress.getLocalHost(), socketIn.getLocalPort());

		while (true) {
			byte[] data = new byte[Client.MAX_SIZE];
			DatagramPacket packet = new DatagramPacket(data, data.length);
			socketIn.receive(packet); // Receive from client.
			Future<Void> future = executor.submit(new Proxy(args[0], packet));
			try {
				future.get();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}