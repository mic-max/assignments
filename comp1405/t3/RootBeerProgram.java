public class RootBeerProgram {

	public static void main(String[] args) {
		int rb = 99;
		while(rb > 0) {
			System.out.println(rb + " bottles of root beer on the wall, " + rb + " bottles of root beer.");
			System.out.println("Take one down, pass it around, " + --rb + " bottles of root beer on the wall.");
		}
	}
}