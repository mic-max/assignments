import java.util.Scanner;

public class PageProgram {
	static double length = 215.9, width = 279.4, mmPerPoint = 0.352777778;

	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		System.out.print("Font (pt): ");
		int font = sc.nextInt();
		System.out.print("Margin (mm): ");
		int margin = sc.nextInt();
		System.out.println("Max Characters: " + (int) ((length - margin * 2) / mmPerPoint / font) * (int) ((width - margin * 2) / mmPerPoint / font));
	}
}