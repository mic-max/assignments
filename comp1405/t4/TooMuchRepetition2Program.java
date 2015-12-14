import java.util.Scanner;

public class TooMuchRepetition2Program {

	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		double[] x = new double[5];
		double sum = 0;
		System.out.println("Enter 5 numbers between 0 and 10 with one decimal place:");
		for(int i = 0; i < x.length; i++) {
			System.out.print(i + ": ");
			x[i] = sc.nextDouble();
			if(x[i] - Math.floor(x[i]) <= .25)
				x[i] = Math.floor(x[i]);
			else if(x[i] - Math.floor(x[i]) < .75)
				x[i] = Math.floor(x[i]) + .5;
			else
				x[i] = Math.ceil(x[i]);
			sum += x[i];
		}
		System.out.println("Numbers entered (rounded to nearest 0.5) are:");
		for(int i = 0; i < x.length; i++)
			System.out.println(i + ": " + x[i]);
		double avg = sum / x.length;
		System.out.println("The average of these rounded numbers is " + avg);
		if(avg - Math.floor(avg) <= 0.25)
			avg = Math.floor(avg);
		else if(avg - Math.floor(avg) < 0.75)
			avg = Math.floor(avg) + 0.5;
		else
			avg = Math.ceil(avg);
		System.out.println("The average rounded to nearest 0.5 is " + avg);
	}
}