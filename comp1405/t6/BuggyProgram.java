import java.util.Scanner;
import java.util.Arrays;

public class BuggyProgram {
	public static final int ARRAY_SIZE = 5;

	public static void main(String[] args) {
		int[] numbers = new int[ARRAY_SIZE];
		int currentNumber = 0;
		System.out.println("Enter non-negative integers.");
		System.out.println("Entering -1 will print the last four numbers entered.");
		System.out.println("Entering -2 will end the program.");
		int inputNumber;
		Scanner input = new Scanner(System.in);    
		while((inputNumber = input.nextInt()) != -2) {
			if(inputNumber >= 0) {
				if(currentNumber > ARRAY_SIZE - 1) {
					for(int i = 0; i < ARRAY_SIZE - 1; i++)
						numbers[i] = numbers[i + 1];
					numbers[ARRAY_SIZE - 1] = inputNumber;
				} else
					numbers[currentNumber++] = inputNumber;
			} else if(inputNumber == -1)
				System.out.println(Arrays.toString(numbers));
			else if(inputNumber != -2)
				System.out.println("You did not enter a valid integer.");
		}
		System.out.println("Thank you. Please run again.");
	}
}