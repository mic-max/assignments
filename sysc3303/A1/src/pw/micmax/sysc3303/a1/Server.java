package pw.micmax.sysc3303.a1;

import java.io.*;
import java.net.*;
import java.util.Arrays;

public class Server {

   public static final int PORT = 69;

   private DatagramSocket socket;
   private DatagramPacket packet;

   public Server() {
      try {
         socket = new DatagramSocket(PORT);
      } catch (SocketException se) {
         se.printStackTrace();
         System.exit(1);
      }
   }

   private void run() throws Exception {
      System.out.printf("TFTP Server waiting on port %d ...\n", socket.getLocalPort());
      while (true) {
         byte[] data = new byte[Client.MAX_SIZE];
         packet = new DatagramPacket(data, data.length);
         try {
            socket.receive(packet);
            data = Arrays.copyOf(packet.getData(), packet.getLength());
            System.out.println("\nPacket received from: " + packet.getSocketAddress());
            System.out.println(TFTPPacket.toString(data));

            if (!TFTPPacket.isValid(data))
               throw new Exception("Malformed TFTP Packet");

            // TODO create a new socket to send the packet back to the client/proxy
            // DatagramSocket socketOut = new DatagramSocket();
            // socketOut.connect(packet.getSocketAddress());
            packet.setData(new byte[] {0, (byte) (data[1] + 2), 0, (byte) (-data[1] + 2)}); // RRQ -> 0301, WRQ -> 0400
            System.out.println("Packet sent to: " + packet.getSocketAddress());
            System.out.println(TFTPPacket.toString(packet.getData()));
            socket.send(packet);
            // socketOut.close();
         } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
         }
      }
   }

   public static void main(String[] args) {
      Server server = new Server();
      try {
         server.run();
      } catch (Exception e) {
         System.out.printf("\nTFTP Server shutting down - %s\n", e.getMessage());
      }
   }
}