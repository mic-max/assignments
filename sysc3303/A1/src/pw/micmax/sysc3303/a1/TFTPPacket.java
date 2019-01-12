package pw.micmax.sysc3303.a1;

import java.net.*;
import java.util.regex.*;

public class TFTPPacket {

	private static final Pattern VALID_PACKET = Pattern.compile("^00 0[12] ([0-9a-f]{2} )+00 ([0-9a-f]{2} )+00 $");

	public static boolean isValid(byte[] data) {
		String str = bytes(data);
		return VALID_PACKET.matcher(str).matches();
	}

	public static String received() {
		return "";
	}

	public static String sent() {
		return "";
	}

	private static String bytes(byte[] data) {
		StringBuilder sb = new StringBuilder();
		for (byte b : data)
			sb.append(String.format("%02x ", b));
		return sb.toString();
	}

	private static String asString(byte[] data) {
		StringBuilder sb = new StringBuilder();
		for (byte b : data)
			sb.append(String.format(b < 10 ? "%d" : "%c", b));
		return sb.toString();
	}

	public static String toString(byte[] data) {
		return String.format(" String: %s\n Bytes:  %s", asString(data), bytes(data));
	}
}