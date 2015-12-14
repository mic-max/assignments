import java.util.Scanner;

public class CellPhoneProgram {

	static final int X1 = 100, X2 = 250, X3 = 340, X4 = 230;
	static final int Y1 = 360, Y2 = 360, Y3 = 250, Y4 = 140;

	public static int getRange(int c) {
		System.out.print("Enter maximum cellular range of city " + c + " in km: ");
		return new Scanner(System.in).nextInt();
	}

	public static double distance(int xa, int ya, int xb, int yb) {
		return Math.sqrt(Math.pow(xb - xa, 2) + Math.pow(yb - ya, 2));
	}

	public static void main(String[] args) {
		int r1 = getRange(1);
		int r2 = getRange(2);
		int r3 = getRange(3);
		int r4 = getRange(4);
		if(distance(X1, Y1, X2, Y2) < r1 + r2 && distance(X2, Y2, X3, Y3) < r2 + r3 && distance(X3, Y3, X4, Y4) < r3 + r4)
			System.out.println("Complete Cellular Service!");
		else
			System.out.println("Incomplete Cellular Service.");
	}
}