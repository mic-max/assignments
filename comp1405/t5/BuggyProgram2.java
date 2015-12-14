import java.util.Scanner;

public class BuggyProgram2 {

	public static int f(int x) {
		return 2 * x * x - 7 * x - 10;
	}

	public static void main(String[] args) {
		System.out.print("Enter the size of the array: ");
		int[] int_array = new int[new Scanner(System.in).nextInt()];
		for(int i = 0; i < int_array.length; i++)
			int_array[i] = f(i);
		for(int i = 0; i < int_array.length - 1; i++)
			System.out.println("slope at x = " + (i + 1.5) + " is " + ((int_array[i + 1] - int_array[i]) / 1D));
	}
}