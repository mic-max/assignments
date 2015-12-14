import java.util.Scanner;

public class ChallengeProgram {

	public static boolean validDate(int d, int m, int y) {
		if(d > 31 || d < 1 || m < 1 || m > 12 || y == 0)
			return false;
		else if(m == 2) {
			if(y % 4 == 0 && d > 29)
				return false;
			else if(y % 4 != 0 && d > 28)
				return false;
		} else if(d > 30 && (m == 4 || m == 6 || m == 9 || m == 11))
			return false;
		return true;
	}

	public static void main(String[] args) {
		System.out.print("Enter a valid date [dd/mm/yyyy]: ");
		String date = new Scanner(System.in).nextLine();
		int d, m, y;
		d = Integer.parseInt(date.substring(0, 2));
		m = Integer.parseInt(date.substring(3, 5));
		y = Integer.parseInt(date.substring(6, 10));
		System.out.println(validDate(d, m, y));
	}
}