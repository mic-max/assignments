public class ApproximationProgram {

	public static void main(String[] args) {
		double x[] = {-.001, .05, -.1, .2, -.3, .4};
		System.out.println("   x   |  cos(x) | 1-x^2/2 | abs(diff)");
		System.out.println("---------------------------------------");
		for(int i = 0; i < x.length; i++)
			System.out.printf("%+1.3f | %1.5f | %1.5f | %1.5f%n", x[i], Math.cos(x[i]), 1D - x[i] * x[i] / 2D, Math.cos(x[i]) - (1D - x[i] * x[i] / 2D));
	}
}