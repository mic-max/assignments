import java.util.Scanner;

public class DateComparisonProgram {

	public static void main(String[] args) {
		System.out.print("Enter date #1 dd-mm-yyyy: ");
		String date1 = new Scanner(System.in).nextLine();
		System.out.print("Enter date #2 dd-mm-yyyy: ");
		String date2 = new Scanner(System.in).nextLine();

		int d1 = Integer.parseInt(date1.substring(0, 2));
		int d2 = Integer.parseInt(date2.substring(0, 2));
		int m1 = Integer.parseInt(date1.substring(3, 5));
		int m2 = Integer.parseInt(date2.substring(3, 5));
		int y1 = Integer.parseInt(date1.substring(6, 10));
		int y2 = Integer.parseInt(date2.substring(6, 10));
		
		if(y1 * 365 + m1 * 30 + d1 < y2 * 365 + m2 * 30 + d2)
			System.out.println("The date " + date1 + " comes before the date " + date2);
		else
			System.out.println("The date " + date2 + " comes before the date " + date1);
	}
}