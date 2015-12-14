import java.util.Scanner;

public class HypotenuseCircleProgram {

	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		System.out.println("Enter 2 integers (hit enter after each):");
		int a = sc.nextInt();
		int b = sc.nextInt();
		double r = Math.sqrt(a * a + b * b);
		System.out.println("Radius: " + r + "\nDiameter: " + 2 * r + "\nCircumference: " + 2 * Math.PI * r + "\nArea: " + Math.PI * r * r);
	}
}