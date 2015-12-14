import java.util.Scanner;

public class ReverseProgram {
	
	public static void main(String [] args) {
		int[] int_arr = new int[10];
		Scanner keyboard = new Scanner(System.in);
		System.out.println("Enter 10 integers: ");
		for(int i = 0; i < int_arr.length; i++)
			int_arr[i] = keyboard.nextInt();
		for(int i = int_arr.length - 1; i >= 0; i--)
			System.out.println(int_arr[i]);
	}
}