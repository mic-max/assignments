package pw.micmax.sysc3303.a1;

import java.net.DatagramPacket;
import java.util.regex.Pattern;

public class TFTPPacket {

	public static final short RRQ = 1;
	public static final short WRQ = 2;

	private DatagramPacket packet;
	private byte[] buffer;

	public TFTPPacket() {
		buffer = new byte[Client.MAX_SIZE];
		packet = new DatagramPacket(buffer, buffer.length);
	}

	public void build(short reqType, String filename, String mode) {

	}

	private static String toHexString(byte[] data, int length) {
		StringBuilder sb = new StringBuilder(length * 3);
		for (int i = 0; i < length; i++)
			sb.append(String.format("%02x ", data[i]));
		return sb.toString();
	}

	public static String str(byte[] data, int length) {
		// print first 2 bytes as numbers
		// print string as ascii
		return String.format("Byte: %s", toHexString(data, length));
	}

	public static boolean isValid(DatagramPacket packet) {
//		return true;
		String s = toHexString(packet.getData(), packet.getLength());
		System.out.println(s);
		return Pattern.matches("00 0[12] ([0-9a-f]{2} )+00 ([0-9a-f]{2} )+(00 )+", s);
	}
}
