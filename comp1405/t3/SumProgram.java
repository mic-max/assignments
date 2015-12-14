import java.util.Scanner;

public class SumProgram {

	public static void main(String[] args) {
		int sum = 0, i;
		Scanner sc = new Scanner(System.in);
		System.out.println("Keep adding values and enter -1 to quit: ");
		while((i = sc.nextInt()) != -1)
			sum += i;
		System.out.println(sum);
	}
}