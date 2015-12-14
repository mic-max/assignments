public class SquareProgram {

	public static void main(String[] args) {
		int rows = 9;
		for(int i = 0; i < rows; i++) {
			for(int j = 0; j < rows; j++)
				System.out.print('#');
			System.out.println(' ' + i);
		}
	}
}