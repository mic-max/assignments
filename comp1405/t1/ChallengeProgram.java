import java.util.Scanner;

public class ChallengeProgram {

	public static void main(String[] args) {
		System.out.print("Enter full name: ");
		String[] name = new Scanner(System.in).nextLine().toUpperCase().split("\\s+");
		System.out.println(name[2] + ", " + name[0].charAt(0) + name[0].substring(1).toLowerCase() + ' ' + name[1].charAt(0) + '.');
		int a = name[0].length();
		int b = name[2].length();
		double c = Math.sqrt(a * a + b * b);
		System.out.println("A: " + a + " -> " + (int) Math.toDegrees(Math.asin(a / c)) + "°\nB: " + b + " -> " + (int) Math.toDegrees(Math.asin(b / c)) + "°\nC: " + c + " -> 90°");
	}
}