import java.util.Scanner;

public class TreeProgram {

	public static void main(String[] args) {
		System.out.print("Enter an odd integer: ");
		int n = new Scanner(System.in).nextInt();
		for(int i = 0; i < n / 2 + 1; i++) {
			for(int j = 0; j < n / 2 - i; j++)
				System.out.print(' ');
			for(int k = 0; k < 2 * i + 1; k++)
				System.out.print('#');
			System.out.println();
		}
		for(int i = 0; i < 2; i++) {
			for(int j = 0; j < n / 2; j++)
				System.out.print(' ');
			System.out.println('#');
		}
	}
}