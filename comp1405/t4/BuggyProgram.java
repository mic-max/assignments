import java.util.Scanner; 

public class BuggyProgram {

	public static int nextEven(int x) {
		return x % 2 == 1 ? x + 1 : x + 2;
	}

	public static String getName() {
		System.out.print("Enter your name: ");
		return new Scanner(System.in).next();
	}

	public static int getAge() {
		System.out.print("Enter your age: ");
		return nextEven(new Scanner(System.in).nextInt());
	}

	public static void main(String[] args) {
		System.out.println(getName() + "\'s next even age will be " + getAge() + " years old.");
	}
}