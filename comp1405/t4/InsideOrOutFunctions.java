public class InsideOrOutFunctions {
	
	public static boolean isInsideCircle(double x0, double y0, double r, double x, double y) {
		return Math.pow(x - x0, 2) + Math.pow(y - y0, 2) < r * r;
	}

	public static boolean isInsideRectangle(double x1, double y1, double x2, double y2, double x, double y) {
		return x > x1 && x < x2 && y > y1 && y < y2;
	}
}