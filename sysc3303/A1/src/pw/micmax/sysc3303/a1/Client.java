package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.nio.ByteBuffer;
import java.util.Arrays;

public class Client {

   public static final int MAX_SIZE = 32;

   private DatagramSocket socket;
   private DatagramPacket packet;

   public Client() {
      try {
         socket = new DatagramSocket();
         socket.connect(new InetSocketAddress("localhost", Proxy.PORT));
         socket.setSoTimeout(1000);
      } catch (SocketException se) {
         se.printStackTrace();
         System.exit(1);
      }
   }

   private byte[] buildRequest(int reqType, String file, String mode) {
   	  final int SIZE = 4 + file.length() + mode.length();
   	  if (SIZE > MAX_SIZE)
   	  	throw new IllegalArgumentException();

   	  ByteBuffer buffer = ByteBuffer.allocate(SIZE);
      buffer.put((byte) 0).put((byte)reqType);
      buffer.put(file.getBytes());
      buffer.put((byte) 0);
      buffer.put(mode.getBytes());
      buffer.put((byte) 0);
      return buffer.array();
   }

   private void run() {
      for (int i = 0; i < 11; i++) {
         byte[] data = buildRequest((i & 1) + 1, "test.txt", "netASCII");
         if (i == 10)
            data[0] = (byte) 0x4d; // Corrupt data of packet #11.

        System.out.printf("\n%d %s\n", i + 1, "-".repeat(70));
         DatagramPacket packet = new DatagramPacket(data, data.length);
         try {
            socket.send(packet);
            System.out.println("Packet sent to: " + socket.getRemoteSocketAddress());
            System.out.println(TFTPPacket.toString(data));

            socket.receive(packet);
            data = Arrays.copyOf(packet.getData(), packet.getLength());
            System.out.println("Packet received from: " + packet.getSocketAddress());
            System.out.println(TFTPPacket.toString(data));
         } catch (IOException e) {
            e.printStackTrace();
         }
      }
      socket.close();
   }

   public static void main(String[] args) {
   	// TODO pass ip:port as args
      Client c = new Client();
      c.run();
   }
}
