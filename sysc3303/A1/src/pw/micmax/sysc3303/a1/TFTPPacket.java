package pw.micmax.sysc3303.a1;

import java.net.*;
import java.util.regex.*;
import java.math.BigInteger;

public class TFTPPacket {

	// Regex pattern to specify what makes a valid packet, and to capture the info.
	private static final Pattern VALID_PACKET = Pattern.compile("^00 0[12] (([0-9a-f]{2} )+)00 (([0-9a-f]{2} )+)00 $");

	public static boolean isValid(byte[] data) {
		String str = bytes(data);
		Matcher m = VALID_PACKET.matcher(str);
		if (!m.matches())
			return false;
		// Extract the hex strings from the matches and convert to ASCII.
		String file = asString(bytes(m.group(1)));
		String mode = asString(bytes(m.group(3)));
		// If it follows the packet guide and uses a valid case-insensitive transfer mode.
		return "netascii".compareToIgnoreCase(mode) == 0 || "octet".compareToIgnoreCase(mode) == 0;
	}

	// Undoes bytes(byte[]) -> String.
	// Converts a hex string, with spaces between each byte to ASCII.
	private static byte[] bytes(String str) {
		byte[] res = new byte[str.length() / 3];

		for (int i = 0; i < res.length; i++) {
			String hex = str.substring(i * 3, i * 3 + 2);
			res[i] = new BigInteger(hex, 16).byteValue();
		}
		return res;
	}

	public static void received(SocketAddress addr, byte[] data) {
		msg("received from", addr, data);
	}

	public static void sent(SocketAddress addr, byte[] data) {
		msg("sent to", addr, data);
	}

	private static void msg(String mode, SocketAddress addr, byte[] data) {
		System.out.printf("Packet %s : %s\n", mode, addr);
		System.out.println(toString(data));
	}
	
	private static String toString(byte[] data) {
		return String.format(" String: %s\n Bytes:  %s", asString(data), bytes(data));
	}
	
	// Given a byte array, build a string with either ASCII values or digits for control codes.
	private static String asString(byte[] data) {
		StringBuilder sb = new StringBuilder();
		for (byte b : data)
			sb.append(String.format(b < 10 ? "%d" : "%c", b));
		return sb.toString();
	}

	// Creates a hex string from an array of bytes.
	private static String bytes(byte[] data) {
		StringBuilder sb = new StringBuilder();
		for (byte b : data)
			sb.append(String.format("%02x ", b));
		return sb.toString();
	}
}