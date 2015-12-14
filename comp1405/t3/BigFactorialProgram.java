import java.math.BigInteger;

public class BigFactorialProgram {

	public static void main(String[] args) {
		int num = 200;
		BigInteger sum = new BigInteger(Integer.toString(num));
		for(int i = 2; i < num; i++)
			sum = sum.multiply(BigInteger.valueOf(i));
		System.out.println(sum);
	} 
}