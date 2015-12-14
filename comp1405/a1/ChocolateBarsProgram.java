import java.util.Scanner;

public class ChocolateBarsProgram {
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		int oH, cC, a, s, c;
		System.out.println("1. Oh Henry     $0.65\n2. Coffee Crisp $0.80\n3. Aero         $0.60\n4. Smarties     $0.70\n5. Crunchie     $0.75\n");
		System.out.print("How many boxes of Oh Henry bars would you like (48 bars per box) ?     ");
		oH = sc.nextInt();
		System.out.print("How many boxes of Coffee Crisp bars would you like (48 bars per box) ? ");
		cC = sc.nextInt();
		System.out.print("How many boxes of Aero bars would you like (48 bars per box) ?         ");
		a = sc.nextInt();
		System.out.print("How many boxes of Smarties would you like (48 bars per box) ?          ");
		s = sc.nextInt();
		System.out.print("How many boxes of Crunchie bars would you like (48 bars per box) ?     ");
		c = sc.nextInt();
		double total = oH * 31.2 + cC * 38.4 + a * 28.8 + s * 33.6 + c * 36D;
		System.out.printf("%n%d boxes of Oh Henry     ($0.65 x 48) = $%1.2f", oH, oH * 31.2);
		System.out.printf("%n%d boxes of Coffee Crisp ($0.80 x 48) = $%1.2f", cC, cC * 38.4);
		System.out.printf("%n%d boxes of Aero         ($0.60 x 48) = $%1.2f", a, a * 28.8);
		System.out.printf("%n%d boxes of Smarties     ($0.70 x 48) = $%1.2f", s, s * 33.6);
		System.out.printf("%n%d boxes of Crunchie     ($0.75 x 48) = $%1.2f", c, c * 36D);
		System.out.println("\n----------------------------------------------");
		System.out.printf("Sub Total%28s= $%1.2f%n", "", total);
		System.out.printf("HST%34s= $%1.2f%n", "", total * .13);
		System.out.println("==============================================");
		System.out.printf("Amount%31s= $%1.2f%n", "", total * 1.13);
	}
}