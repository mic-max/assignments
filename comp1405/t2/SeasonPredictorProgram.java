import java.util.Scanner;

public class SeasonPredictorProgram {

	public static void main(String[] args) {
		System.out.print("Enter the temperature: ");
		int temp = new Scanner(System.in).nextInt();
		if(temp > 20)
			System.out.println("Summer");
		else if(temp > 10)
			System.out.println("Spring");
		else if(temp > 0)
			System.out.println("Fall");
		else
			System.out.println("Winter");
	}
}