import java.util.Scanner;

public class WeekendPlannerProgram {

	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		System.out.print("It is raining outside: ");
		boolean rain = sc.nextBoolean();
		System.out.print("Hours of sleep: ");
		int sleep = sc.nextInt();
		System.out.print("A COMP 1405 assignment is due Monday: ");
		boolean assignment = sc.nextBoolean();
		if(!rain && sleep >= 2)
			System.out.println("Go outside!");
		else if(sleep < 2)
			System.out.println("Take a nap!");
		else if(assignment && sleep > 3)
			System.out.println("Work on assignment!");
		else
			System.out.println("Work ahead in COMP 1405!");
	}
}