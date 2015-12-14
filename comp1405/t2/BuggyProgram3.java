public class BuggyProgram3 {

	public static void main(String[] args) {
		boolean b = false;
		if(b)
			System.out.println("How did b become true?");
		else
			System.out.println("b is false as expected");
	}
}