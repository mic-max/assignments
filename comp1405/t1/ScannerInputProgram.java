import java.util.Scanner;

public class ScannerInputProgram {

	public static void main(String[] args) {
		System.out.println("Enter first, middle & last name (hit enter after each): ");
		System.out.println(new Scanner(System.in).next().toUpperCase().charAt(0) + ". " + new Scanner(System.in).next().toUpperCase().charAt(0) + ". " + new Scanner(System.in).next().toUpperCase().charAt(0) + '.');
	}
}