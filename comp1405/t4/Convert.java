import java.util.Scanner;

public class Convert {
	
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		byte h, w;
		double height, weight;
		System.out.println("1. Metres\n2. Centimetres\n3. Feet & Inches");
		h = sc.nextByte();
		switch(h) {
			case 1:
				height = sc.nextDouble();
				break;
			case 2:
				height = sc.nextDouble() / 100;
				break;
			case 3:
				double f = sc.nextDouble();
				double i = sc.nextDouble();
				i += f * 12;
				height = i * .0254;
				break;
			default:
				height = 0;
				break;
		}
		System.out.println("1. Kilograms\n2. Pounds\n3. Pounds & Ounces");
		w = sc.nextByte();
		switch(w) {
			case 1:
				weight = sc.nextDouble();
				break;
			case 2:
				weight = sc.nextDouble();
				weight /= 2.20462;
				break;
			case 3:
				double p = sc.nextDouble();
				double o = sc.nextDouble();
				o += p * 16;
				weight = o * (2.20462 / 16);
				break;
			default:
				weight = 0;
				break;
		}
		double feet = Math.floor(height * 3.28084);
		double inches = (height * 39.3701) % 12;
		System.out.println("\nHeights:\n" + height + " m\n" + height * 100 + " cm\n" + feet + '\'' + inches + '"');
		double pounds = Math.floor(weight * 2.20462);
		double ounces = (weight * 35.274) % 16;
		System.out.println("\nWeights:\n" + weight + " kg\n" + weight * 2.20462 + " lbs\n" + pounds + " lbs " + ounces + " oz");
	}
}