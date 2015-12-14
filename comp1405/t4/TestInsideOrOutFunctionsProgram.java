public class TestInsideOrOutFunctionsProgram {

	public static void main(String[] args) {
		System.out.println("Testing isInsideCircle()");
		System.out.println("------------------------");
		System.out.println("test  ( x0  ,  y0 )  rad  ( x   ,  y   )  expected  got");
		System.out.println(" 1     0.0  , 0.0    1.0   0.1  , 0.2       true   " + InsideOrOutFunctions.isInsideCircle(0, 0, 1, .1, .2));
		System.out.println(" 2     0.0  , 0.0    1.0   1.1  , 0.2       false  " + InsideOrOutFunctions.isInsideCircle(0, 0, 1, 1.1, .2));
		System.out.println(" 3     0.0  , 0.0    1.0   0.0  , 1.0       false  " + InsideOrOutFunctions.isInsideCircle(0, 0, 1, 0, 1));
		System.out.println(" 4     1.9  ,-3.4   12.0  12.1  ,-10.2      false  " + InsideOrOutFunctions.isInsideCircle(1.9, -3.4, 12, 12.1, -10.2));
		System.out.println(" 5     1.9  ,-3.4   12.0  12.1  , -9.2      true   " + InsideOrOutFunctions.isInsideCircle(1.9, -3.4, 12, 12.1, -9.2));
		System.out.println("Testing isInsideRectangle()");
		System.out.println("---------------------------");
		System.out.println("test  ( x1  ,  y1 )   ( x2  ,  y1 )   ( x   ,  y   )  expected  got");
		System.out.println(" 1     0.0  , 0.0      1.0  , 1.0       0.5 , 0.5       true   " + InsideOrOutFunctions.isInsideRectangle(0, 0, 1, 1, .5, .5));
		System.out.println(" 2     0.0  , 0.0      1.0  , 1.0       1.5 , 0.5       false  " + InsideOrOutFunctions.isInsideRectangle(0, 0, 1, 1, 1.5, .5));
		System.out.println(" 3     0.0  , 0.0      1.0  , 1.0       0.0 , 1.0       false  " + InsideOrOutFunctions.isInsideRectangle(0, 0, 1, 1, 0, 1));
	}
}