import java.util.Random;

public class RandomGeneratorProgram {
	
	public static void main(String[] args) {
		Random rand = new Random();
		int sum = 0, loops = 100;
		for(int i = 0; i < loops; i++)
			sum += rand.nextInt(100) + 1;
		System.out.println(sum / loops);
	}
}