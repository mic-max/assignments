import java.util.Scanner;

public class NumbeFunProgram {

	public static void displayNumberInfo(int n) {
		System.out.println("Even: " + (n % 2 == 0));
		System.out.println("Perfect Square: " + (Math.pow(Math.sqrt(n), 2) == n));
		System.out.println("Perfect Cube: " + (Math.pow(Math.cbrt(n), 3) == n));
		boolean isPrime = true;
		for(int j = 2; j < n; j++) {
			if(n % j == 0)
				isPrime = false;
		}
		System.out.println("Prime: " + isPrime);
	}

	public static void main(String[] args) {
		System.out.print("Enter an integer: ");
		displayNumberInfo(new Scanner(System.in).nextInt());
	}
}