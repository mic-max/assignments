public class FactorialProgram {

	public static void main(String[] args) {
		int num = 18;
		long sum = num;
		for(int i = 2; i < num; i++)
			sum *= i;
		System.out.println(sum);
	}
}